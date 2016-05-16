{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  57224: IdCompressorZLibEx.pas 
{
{   Rev 1.8    10/24/2004 2:40:28 PM  JPMugaas
{ Made a better fix for the problem with SmartFTP.  It turns out that we may
{ not be able to avoid a Z_BUF_ERROR in some cases.
}
{
{   Rev 1.7    10/24/2004 11:17:08 AM  JPMugaas
{ Reimplemented ZLIB Decompression in FTP better.  It now should work properly
{ at ftp://ftp.smartftp.com.
}
{
{   Rev 1.6    9/16/2004 3:24:04 AM  JPMugaas
{ TIdFTP now compresses to the IOHandler and decompresses from the IOHandler.
{ 
{ Noted some that the ZLib code is based was taken from ZLibEx.
}
{
{   Rev 1.4    9/11/2004 10:58:04 AM  JPMugaas
{ FTP now decompresses output directly to the IOHandler.
}
{
{   Rev 1.3    6/21/2004 12:10:52 PM  JPMugaas
{ Attempt to expand the ZLib support for Int64 support.
}
{
{   Rev 1.2    2/21/2004 3:32:58 PM  JPMugaas
{ Foxed for Unit rename.
}
{
{   Rev 1.1    2/14/2004 9:59:50 PM  JPMugaas
{ Reworked the API.  There is now a separate API for the Inflate_ and
{ InflateInit2_ functions as well as separate functions for DeflateInit_ and
{ DeflateInit2_.  This was required for FTP.  The API also includes an optional
{ output stream for the servers.
}
{
{   Rev 1.0    2/12/2004 11:27:22 PM  JPMugaas
{ New compressor based on ZLibEx.
}
unit IdCompressorZLibEx;

interface
uses Classes, IdException, IdIOHandler, IdZLibCompressorBase, IdZLibEx;

type
  TIdCompressorZLibEx = class(TIdZLibCompressorBase)
  protected
    procedure InternalDecompressStream(LZstream: TZStreamRec; AIOHandler : TIdIOHandler;
      AOutStream: TStream);
  public

    procedure DeflateStream(AStream : TStream; const ALevel : TIdCompressionLevel=0; const AOutStream : TStream=nil); override;
    procedure InflateStream(AStream : TStream; const AOutStream : TStream=nil); override;

    procedure CompressStream(AStream : TStream; const ALevel : TIdCompressionLevel; const AWindowBits, AMemLevel,
      AStrategy: Integer; AOutStream : TStream); override;
    procedure DecompressStream(AStream : TStream; const AWindowBits : Integer; const AOutStream : TStream=nil); override;
    procedure CompressFTPToIO(AStream : TStream; AIOHandler : TIdIOHandler; const ALevel, AWindowBits, AMemLevel,
      AStrategy: Integer); override;
     procedure DecompressFTPFromIO(AIOHandler : TIdIOHandler; const AWindowBits : Integer; AOutputStream : TStream); override;
  end;

  EIdCompressionException = class(EIdException);
  EIdCompressorInitFailure = class(EIdCompressionException);
  EIdDecompressorInitFailure = class(EIdCompressionException);
  EIdCompressionError = class(EIdCompressionException);
  EIdDecompressionError = class(EIdCompressionException);

implementation
uses IdComponent, IdResourceStringsProtocols, IdGlobal, IdGlobalProtocols, SysUtils;

const
  bufferSize = 32768;

{ TIdCompressorZLibEx }

procedure TIdCompressorZLibEx.InternalDecompressStream(
  LZstream: TZStreamRec; AIOHandler: TIdIOHandler; AOutStream: TStream);
{Note that much of this is taken from the ZLibEx unit and adapted to use the IOHandler}
const
  bufferSize = 32768;
var
  zresult  : Integer;
  outBuffer: Array [0..bufferSize-1] of Char;
  inSize   : Integer;
  outSize  : Integer;
  LBuf : TIdBytes;

  function RawReadFromIOHandler(ABuffer : TIdBytes; AOIHandler : TIdIOHandler; AMax : Integer) : Integer;
  begin
    //We don't use the IOHandler.ReadBytes because that will check for disconnect and
    //raise an exception that we don't want.
    repeat
      AIOHandler.CheckForDataOnSource(1);
      Result := AIOHandler.InputBuffer.Size;
      if Result > AMax then
      begin
        Result := AMax;
      end;
      if Result>0 then
      begin
        AIOHandler.InputBuffer.ExtractToBytes(ABuffer,Result,False);
      end
      else
      begin
        if not AIOHandler.connected then
        begin
          break;
        end;
      end;
    until (Result > 0)
  end;

begin
  SetLength(LBuf,bufferSize);
  inSize := RawReadFromIOHandler(LBuf, AIOHandler, bufferSize);
  while inSize > 0 do
  begin
    LZstream.next_in := @LBuf[0];
    LZstream.avail_in := inSize;
    repeat
      LZstream.next_out := outBuffer;
      LZstream.avail_out := bufferSize;

      ZDecompressCheck(inflate(LZstream,Z_NO_FLUSH));
      outSize := bufferSize - LZstream.avail_out;
      AOutStream.Write(outBuffer,outSize);
    until (LZstream.avail_in = 0) and (LZstream.avail_out > 0);
    inSize := RawReadFromIOHandler(LBuf, AIOHandler, bufferSize);
  end;
  { From the ZLIB FAQ at http://www.gzip.org/zlib/FAQ.txt

 5. deflate() or inflate() returns Z_BUF_ERROR

    Before making the call, make sure that avail_in and avail_out are not
    zero. When setting the parameter flush equal to Z_FINISH, also make sure
    that avail_out is big enough to allow processing all pending input.
    Note that a Z_BUF_ERROR is not fatal--another call to deflate() or
    inflate() can be made with more input or output space. A Z_BUF_ERROR
    may in fact be unavoidable depending on how the functions are used, since
    it is not possible to tell whether or not there is more output pending
    when strm.avail_out returns with zero.
}
    repeat
      LZstream.next_out := outBuffer;
      LZstream.avail_out := bufferSize;

      zresult := inflate(LZstream,Z_FINISH);
      if zresult<>Z_BUF_ERROR then
      begin
        zresult := ZDecompressCheck(zresult);
      end;
      outSize := bufferSize - LZstream.avail_out;
      AOutStream.Write(outBuffer,outSize);

    until ((zresult = Z_STREAM_END) and (LZstream.avail_out > 0)) or (zresult = Z_BUF_ERROR);

  ZDecompressCheck(inflateEnd(LZstream));
end;

procedure TIdCompressorZLibEx.DecompressFTPFromIO(AIOHandler: TIdIOHandler;
  const AWindowBits: Integer; AOutputStream: TStream);
{Note that much of this is taken from the ZLibEx unit and adapted to use the IOHandler}
var
  Lzstream: TZStreamRec;
  LWinBits : Integer;
begin
  AIOHandler.BeginWork(wmRead);
  try
    FillChar(Lzstream,SizeOf(TZStreamRec),0);
    {
    This is a workaround for some clients and servers that do not send decompression
    headers.  The reason is that there's an inconsistancy in Internet Drafts for ZLIB
    compression.  One says to include the headers while an older one says do not
    include the headers.

    If you add 32 to the Window Bits parameter, 
    }
    LWinBits := AWindowBits;
    if LWinBits > 0 then
    begin
      LWinBits := Abs( LWinBits) + 32;
    end;
    LZstream.zalloc := zcalloc;
    LZstream.zfree := zcfree;
    ZDecompressCheck(inflateInit2_(Lzstream,LWinBits,ZLIB_VERSION,SizeOf(TZStreamRec)));

    InternalDecompressStream(Lzstream,AIOHandler,AOutputStream);
  finally
    AIOHandler.EndWork(wmRead);
  end;
end;

procedure TIdCompressorZLibEx.CompressFTPToIO(AStream: TStream;
  AIOHandler: TIdIOHandler; const ALevel, AWindowBits, AMemLevel,
  AStrategy: Integer);
{Note that much of this is taken from the ZLibEx unit and adapted to use the IOHandler}
var
  LCompressRec : TZStreamRec;

  zresult  : Integer;
  inBuffer : Array [0..bufferSize-1] of Char;
  outBuffer: Array [0..bufferSize-1] of Char;
  inSize   : Integer;
  outSize  : Integer;
begin
  AIOHandler.BeginWork(wmWrite,AStream.Size);
  FillChar(LCompressRec,SizeOf(TZStreamRec),0);
  ZCompressCheck( deflateInit2_(LCompressRec, ALevel, Z_DEFLATED, AWindowBits, AMemLevel,
      AStrategy, ZLIB_VERSION,  SizeOf(LCompressRec)));

  inSize := AStream.Read(inBuffer,bufferSize);

  while inSize > 0 do
  begin
    LCompressRec.next_in := inBuffer;
    LCompressRec.avail_in := inSize;

    repeat
      LCompressRec.next_out := outBuffer;
      LCompressRec.avail_out := bufferSize;

      ZCompressCheck(deflate(LCompressRec,Z_NO_FLUSH));

      // outSize := zstream.next_out - outBuffer;
      outSize := bufferSize - LCompressRec.avail_out;
      if outsize <>0 then
      begin
        AIOHandler.Write( RawToBytes(outBuffer,outSize));
      end;
    until ( LCompressRec.avail_in = 0) and ( LCompressRec.avail_out > 0);

    inSize := AStream.Read(inBuffer,bufferSize);
  end;

  repeat
    LCompressRec.next_out := outBuffer;
    LCompressRec.avail_out := bufferSize;

    zresult := ZCompressCheck(deflate( LCompressRec,Z_FINISH));

    // outSize := zstream.next_out - outBuffer;
    outSize := bufferSize -  LCompressRec.avail_out;

   // outStream.Write(outBuffer,outSize);
    if outSize <> 0 then
    begin
    AIOHandler.Write( RawToBytes(outBuffer,outSize));
    end;
  until (zresult = Z_STREAM_END) and ( LCompressRec.avail_out > 0);

  ZCompressCheck(deflateEnd(LCompressRec));
  AIOHandler.EndWork(wmWrite);
end;

procedure TIdCompressorZLibEx.CompressStream(AStream : TStream; const ALevel : TIdCompressionLevel; const AWindowBits, AMemLevel,
      AStrategy: Integer; AOutStream : TStream);
var
    LCompressRec: TZStreamRec;
var
  Buffer: array[0..1023] of Char;
   LSendBuf: Pointer;
   LSendCount, LSendSize: Int64;
begin
  if ALevel in [1..9] then
  begin
    LSendSize := 0;
    LSendBuf := nil;
    //initialization
    LCompressRec.zalloc := zcalloc;
    LCompressRec.zfree := zcfree;
    if deflateInit2_(LCompressRec, ALevel, Z_DEFLATED, AWindowBits, AMemLevel,
      AStrategy, ZLIB_VERSION,  SizeOf(LCompressRec)) <> Z_OK then
    begin
      raise EIdCompressorInitFailure.Create(RSZLCompressorInitializeFailure);
    end;
    try
      // Make sure the Send buffer is large enough to hold the input stream data
      if AStream.Size > LSendSize then
      begin
        if AStream.Size > 2048 then
        begin
          LSendSize := AStream.Size + (AStream.Size + 1023) mod 1024
        end
        else
        begin
          LSendSize := 2048;
        end;
        ReallocMem(LSendBuf, LSendSize);
      end;
      // Get the data from the input stream and save it off
      LSendCount := AStream.Read(LSendBuf^, AStream.Size);
      LCompressRec.next_in := LSendBuf;
      LCompressRec.avail_in := LSendCount;
      LCompressRec.avail_out := 0;

      if Assigned(AOutStream) then
      begin
        AOutStream.Size := 0;
      end
      else
      begin
        // reset and clear the input stream in preparation for compression
        AStream.Size := 0;
      end;
      // As long as data is being outputted, keep compressing
      while LCompressRec.avail_out = 0 do
      begin
        LCompressRec.next_out := Buffer;
        LCompressRec.avail_out := SizeOf(Buffer);
        case deflate(LCompressRec, Z_SYNC_FLUSH) of
          Z_STREAM_ERROR,
          Z_DATA_ERROR,
          Z_MEM_ERROR: raise EIdCompressionError.Create(RSZLCompressionError);
        end;

        if Assigned(AOutStream) then
        begin
          AOutStream.Write(Buffer, SizeOf(Buffer) - LCompressRec.avail_out);
        end
        else
        begin
          // Place the compressed data back into the input stream
          AStream.Write(Buffer, SizeOf(Buffer) - LCompressRec.avail_out);
        end;
      end;
    //finalization cleanup
    finally
      deflateEnd(LCompressRec);
      FillChar(LCompressRec, SizeOf(LCompressRec), 0);
      if LSendBuf<>nil then
      begin
        FreeMem(LSendBuf);
      end;
    end;
  end;
end;

procedure TIdCompressorZLibEx.DecompressStream(AStream : TStream; const AWindowBits : Integer; const AOutStream : TStream=nil);
var
  Buffer: array[0..2047] of Char;
  nChars, C: Integer;
  StreamEnd: Boolean;
  LDecompressRec: TZStreamRec;
  LRecvCount, LRecvSize: Int64;
  LRecvBuf: Pointer;
begin
    LRecvCount := 0;
    LRecvSize := 0;
    LRecvBuf := nil;
    //initialization section
    LDecompressRec.zalloc := zcalloc;
    LDecompressRec.zfree := zcfree;
    if inflateInit2_(LDecompressRec, AWindowBits, zlib_Version, SizeOf(LDecompressRec)) <> Z_OK then
    begin
      raise EIdDecompressorInitFailure.Create(RSZLDecompressorInitializeFailure);
    end;
    try
      //decompression
      StreamEnd := False;
      repeat
        nChars := AStream.Read(Buffer, SizeOf(Buffer));
        if nChars = 0 then
        begin
          Break;
        end;
        LDecompressRec.next_in := Buffer;
        LDecompressRec.avail_in := nChars;
        LDecompressRec.total_in := 0;
        while LDecompressRec.avail_in > 0 do
        begin
          if LRecvCount = LRecvSize then
          begin
            if LRecvSize = 0 then
            begin
              LRecvSize := 2048;
            end
            else
            begin
              Inc(LRecvSize, 1024);
            end;
            ReallocMem(LRecvBuf, LRecvSize);
          end;
          LDecompressRec.next_out := PChar(LRecvBuf) + LRecvCount;
          C := LRecvSize - LRecvCount;
          LDecompressRec.avail_out := C;
          LDecompressRec.total_out := 0;
          case inflate(LDecompressRec, Z_NO_FLUSH) of
            Z_STREAM_END:
              StreamEnd := True;
            Z_STREAM_ERROR,
            Z_DATA_ERROR,
            Z_MEM_ERROR:
              raise EIdDecompressionError.Create(RSZLDecompressionError);
          end;
          Inc(LRecvCount, C - LDecompressRec.avail_out);
        end;
      until StreamEnd;
      if Assigned(AOutStream) then
      begin
        AOutStream.Size := 0;
        AOutStream.Write(LRecvBuf^, LRecvCount);
      end
      else
      begin
        AStream.Size := 0;
        AStream.Write(LRecvBuf^, LRecvCount);
      end;
    finally
      //deinitialization
      inflateEnd(LDecompressRec);
      FillChar(LDecompressRec, SizeOf(LDecompressRec), 0);
      if LRecvBuf<>nil then
      begin
        FreeMem(LRecvBuf);
      end;
    end;
end;

procedure TIdCompressorZLibEx.DeflateStream(AStream : TStream; const ALevel : TIdCompressionLevel=0; const AOutStream : TStream=nil);

var 
    LCompressRec: TZStreamRec;
var
  Buffer: array[0..1023] of Char;
   LSendBuf: Pointer;
   LSendCount, LSendSize: Int64;
begin
  if ALevel in [1..9] then
  begin
    LSendSize := 0;
    LSendBuf := nil;
    //initialization
    LCompressRec.zalloc := zcalloc;
    LCompressRec.zfree := zcfree;
    if deflateInit_(LCompressRec, ALevel, ZLIB_VERSION,  SizeOf(LCompressRec)) <> Z_OK then
    begin
      raise EIdCompressorInitFailure.Create(RSZLCompressorInitializeFailure);
    end;
    try
      // Make sure the Send buffer is large enough to hold the input stream data
      if AStream.Size > LSendSize then
      begin
        if AStream.Size > 2048 then
        begin
          LSendSize := AStream.Size + (AStream.Size + 1023) mod 1024
        end
        else
        begin
          LSendSize := 2048;
        end;
        ReallocMem(LSendBuf, LSendSize);
      end;
      // Get the data from the input stream and save it off
      LSendCount := AStream.Read(LSendBuf^, AStream.Size);
      LCompressRec.next_in := LSendBuf;
      LCompressRec.avail_in := LSendCount;
      LCompressRec.avail_out := 0;
      if Assigned(AOutStream) then
      begin
        AOutStream.Size := 0;
      end
      else
      begin
        // reset and clear the input stream in preparation for compression
        AStream.Size := 0;
      end;
      // As long as data is being outputted, keep compressing
      while LCompressRec.avail_out = 0 do
      begin
        LCompressRec.next_out := Buffer;
        LCompressRec.avail_out := SizeOf(Buffer);
        
        case deflate(LCompressRec, Z_SYNC_FLUSH) of
          Z_STREAM_ERROR,
          Z_DATA_ERROR,
          Z_MEM_ERROR: raise EIdCompressionError.Create(RSZLCompressionError);
        end;
        if Assigned(AOutStream) then
        begin
          AOutStream.Write(Buffer, SizeOf(Buffer) - LCompressRec.avail_out);
        end
        else
        begin
          // Place the compressed data back into the input stream
          AStream.Write(Buffer, SizeOf(Buffer) - LCompressRec.avail_out);
        end;
      end;
    //finalization cleanup
    finally
      deflateEnd(LCompressRec);

      FillChar(LCompressRec, SizeOf(LCompressRec), 0);
      if LSendBuf<>nil then
      begin
        FreeMem(LSendBuf);
      end;
    end;
  end;
end;

procedure TIdCompressorZLibEx.InflateStream(AStream : TStream; const AOutStream : TStream=nil);
var
  Buffer: array[0..2047] of Char;
  nChars, C: Integer;
  StreamEnd: Boolean;
  LDecompressRec: TZStreamRec;
  LRecvCount, LRecvSize: Int64;
  LRecvBuf: Pointer;
begin
    LRecvCount := 0;
    LRecvSize := 0;
    LRecvBuf := nil;
    LDecompressRec.adler := 0;
    //initialization section
    LDecompressRec.zalloc := zcalloc;
    LDecompressRec.zfree := zcfree;
    if inflateInit_(LDecompressRec, zlib_Version, SizeOf(LDecompressRec)) <> Z_OK then
    begin
      raise EIdDecompressorInitFailure.Create(RSZLDecompressorInitializeFailure);
    end;
    try
      //decompression
      StreamEnd := False;
      repeat
        nChars := AStream.Read(Buffer, SizeOf(Buffer));
        if nChars = 0 then
        begin
          Break;
        end;
        LDecompressRec.next_in := Buffer;
        LDecompressRec.avail_in := nChars;
        LDecompressRec.total_in := 0;

        while LDecompressRec.avail_in > 0 do
        begin
          if LRecvCount = LRecvSize then
          begin
            if LRecvSize = 0 then
            begin
              LRecvSize := 2048;
            end
            else
            begin
              Inc(LRecvSize, 1024);
            end;
            ReallocMem(LRecvBuf, LRecvSize);
          end;
          LDecompressRec.next_out := PChar(LRecvBuf) + LRecvCount;
          C := LRecvSize - LRecvCount;
          LDecompressRec.avail_out := C;
          LDecompressRec.total_out := 0;
          case inflate(LDecompressRec, Z_NO_FLUSH) of
            Z_STREAM_END:
              StreamEnd := True;
            Z_STREAM_ERROR,
            Z_DATA_ERROR,
            Z_MEM_ERROR:
              raise EIdDecompressionError.Create(RSZLDecompressionError);
          end;

          Inc(LRecvCount, C - LDecompressRec.avail_out);
        end;
      until StreamEnd;
      if Assigned(AOutStream) then
      begin
        AOutStream.Size := 0;
        AOutStream.Write(LRecvBuf^, LRecvCount);
      end
      else
      begin
        AStream.Size := 0;
        AStream.Write(LRecvBuf^, LRecvCount);
      end;
    finally
      //deinitialization
      inflateEnd(LDecompressRec);

      FillChar(LDecompressRec, SizeOf(LDecompressRec), 0);
      if LRecvBuf<>nil then
      begin
        FreeMem(LRecvBuf);
      end;
    end;
end;

end.
