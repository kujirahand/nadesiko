{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  88138: IdStreamVCLBase.pas
{
{   Rev 1.7    24.09.2004 02:16:30  Andreas Hausladen
{ Added ReadTIdBytesFromStream and ReadCharFromStream function to supress .NET
{ warnings.
}
{
{   Rev 1.6    7/8/04 11:57:06 PM  RLebeau
{ Updated ReadLn() to use new BytesToString() parameters
}
{
{   Rev 1.5    14/06/2004 23:47:30  CCostelloe
{ Bug fix
}
{
{   Rev 1.4    2004.05.23 8:55:16 AM  czhower
{ Conforms to coding conventions.
}
{
    Rev 1.3    5/22/2004 9:57:38 AM  DSiders
  Added TODO for Int64 and LongInt properties and overloaded methods.
  Corrected logic error in implementation of Skip method.
}
{
{   Rev 1.2    2004.05.20 1:40:28 PM  czhower
{ Last of the IdStream updates
}
{
{   Rev 1.1    2004.05.20 12:15:42 PM  czhower
{ IdStream completion
}
{
{   Rev 1.0    2004.05.20 11:23:02 AM  czhower
{ Initial checkin
}
{
{   Rev 1.26    2004.05.20 11:11:58 AM  czhower
{ More IdStream conversions
}
{
{   Rev 1.25    2004.05.20 9:45:36 AM  czhower
{ First phase of cleaning
}
{
{   Rev 1.24    14/03/2004 17:45:58  CCostelloe
{ Bug fix: EOF calculated incorrectly (gave spurious LF at end); FindEOL
{ incorrectly calculated VLineBufSize, causing 1st char to be missing on 2nd &
{ every following line.
}
{
{   Rev 1.23    12.03.2004 18:06:06  ARybin
{ bug: readln, eof
}
{
{   Rev 1.22    2004.03.05 9:52:58 PM  czhower
{ Bug fix to write.
}
{
{   Rev 1.21    2004.03.03 7:13:36 PM  czhower
{ .Net compile fix.
}
{
{   Rev 1.20    2004.03.03 11:55:30 AM  czhower
{ preparation for isolation of VCLStream property
}
{
{   Rev 1.19    2004.03.03 11:39:28 AM  czhower
{ .Net changes
}
{
{   Rev 1.18    2004.02.03 4:16:54 PM  czhower
{ For unit name changes.
}
{
{   Rev 1.17    2003.12.28 1:06:04 PM  czhower
{ .Net changes.
}
{
{   Rev 1.16    25/11/2003 12:24:22 PM  SGrobety
{ various IdStream fixes with ReadLn/D6
}
{
{   Rev 1.15    22/11/2003 12:03:50 AM  GGrieve
{ Fix offset but reading bytes
}
{
{   Rev 1.14    10/26/2003 10:09:24 PM  BGooijen
{ Compiles in DotNet
}
{
    Rev 1.13    10/24/2003 4:22:42 PM  DSiders
  Added RSStreamNotEnoughBytes for exception during stream read.
}
{
{   Rev 1.12    2003.10.24 10:44:52 AM  czhower
{ IdStream implementation, bug fixes.
}
{
{   Rev 1.11    10/21/2003 9:02:38 PM  BGooijen
{ Fixed some methods, compiles in DotNet now
}
{
{   Rev 1.10    2003.10.17 6:15:38 PM  czhower
{ Partial port
}
{
    Rev 1.9    10/15/2003 10:43:10 PM  DSiders
  Added resource strings for exceptions raised in TIdStreamVCLBase and TIdStreamVCLBase.
}
{
{   Rev 1.8    10/11/2003 4:39:28 PM  BGooijen
{ Works in d.net now too
}
{
{   Rev 1.6    9/10/2003 6:19:48 PM  SGrobety
{ removed circular call
}
{
{   Rev 1.4    10/8/2003 9:58:32 PM  GGrieve
{ fix reference to TIdStackBasdBase
}
{
{   Rev 1.3    7/10/2003 6:07:58 PM  SGrobety
{ .net
}
{
{   Rev 1.2    2003.09.30 1:23:06 PM  czhower
{ Stack split for DotNet
}
{
{   Rev 1.1    07/08/2003 01:00:46  CCostelloe
{ Function ReadLnSplit added
}
{
{   Rev 1.0    11/13/2002 08:59:50 AM  JPMugaas
2002-04-10 -Andrew P.Rybin
  -Read*, Write*, ReadLn optimization (for many strings use TIdReadLineStreamProxy)
2002-04-16 -Andrew P.Rybin
  -TIdStreamVCLSafe, TIdStreamVCLLight, TIdReadLineStreamProxy, optimization, misc
}
unit IdStreamVCLBase;

interface

uses
  Classes,
  IdException, IdGlobal, IdStreamRandomAccess;

type
  EIdEndOfStream = class(EIdException);

  {
   TODO:
    Position and Size in TStream are declared as Int64 in later versions of Delphi.

    SetSize and Seek in TStream are overloaded to handle LongInt and Int64 values.

    Eventually the Indy wrapper classes (including TIdStreamRandomAccess) need to
    support the same capabilities.
  }

  TIdStreamVCLBase = class(TIdStreamRandomAccess)
  protected
    FFreeStream: Boolean;
    FVCLStream: TStream;
    //
    function GetPosition: Integer; override;
    function GetSize: Integer; override;
    procedure SetPosition(const AValue: Integer); override;
  public
    constructor Create(
      AStream: TStream;
      AFreeStream: Boolean = False
      ); reintroduce; virtual;
    destructor Destroy;
      override;
    function ReadLn(AMaxLineLength: Integer = -1; AExceptionIfEOF: Boolean = FALSE): string; override;
    procedure Skip(
      ASize: Integer
      ); override;
    //
    property FreeStream: Boolean read FFreeStream write FFreeStream;
    property VCLStream: TStream read FVCLStream;
  end;

implementation

uses
  IdStack, IdResourceStrings,
  SysUtils;

const
  LBUFMAXSIZE = 2048;

constructor TIdStreamVCLBase.Create(
  AStream: TStream;
  AFreeStream: Boolean = False
  );
begin
  inherited Create;
  FVCLStream := AStream;
  FFreeStream := AFreeStream;
end;

function TIdStreamVCLBase.ReadLn(AMaxLineLength: Integer = -1; AExceptionIfEOF: Boolean = FALSE): String;
//TODO: Continue to optimize this function. Its performance severely impacts
// the coders
var
  LBufSize, LStringLen, LResultLen: LongInt;
  LBuf: TIdBytes;
 // LBuf: packed array [0..LBUFMAXSIZE] of Char;
  LStrmPos, LStrmSize: Integer; //LBytesToRead = stream size - Position
  LCrEncountered: Boolean;

  function FindEOL(const ABuf: TIdBytes; var VLineBufSize: Integer; var VCrEncountered: Boolean): Integer;
  var
    i: Integer;
  begin
    Result := VLineBufSize; //EOL not found => use all
    i := 0;
    while i < VLineBufSize do begin
      case ABuf[i] of
        Ord(LF): begin
            Result :=  i; {string size}
            VCrEncountered := TRUE;
            VLineBufSize := i+1;
            break;
          end;//LF
        Ord(CR): begin
            Result := i; {string size}
            VCrEncountered := TRUE;
            inc(i); //crLF?
            if (i < VLineBufSize) and (ABuf[i] = Ord(LF)) then begin
              VLineBufSize := i+1;
            end else begin
              VLineBufSize := i;
            end;
            break;
          end;
      end;
      Inc(i);
    end;
  end;

begin
  SetLength(LBuf, LBUFMAXSIZE);
  if AMaxLineLength < 0 then begin
    AMaxLineLength := MaxInt;
  end;//if
  LCrEncountered := FALSE;
  Result := '';
  { we store the stream size for the whole routine to prevent
  so do not incur a performance penalty with TStream.Size.  It has
  to use something such as Seek each time the size is obtained}
  {4 seek vs 3 seek}
  LStrmPos := VCLStream.Position;
  LStrmSize:= VCLStream.Size;

  if (LStrmSize - LStrmPos) > 0 then begin
    while (LStrmPos < LStrmSize) and not LCrEncountered do begin
      LBufSize := Min(LStrmSize - LStrmPos, LBUFMAXSIZE);
      ReadTIdBytesFromStream(VCLStream, LBuf, LBufSize);
      LStringLen := FindEOL(LBuf, LBufSize, LCrEncountered);
      Inc(LStrmPos, LBufSize);

      LResultLen := Length(Result);
      if (LResultLen + LStringLen) > AMaxLineLength then begin
        LStringLen := AMaxLineLength - LResultLen;
        LCrEncountered := TRUE;
        Dec(LStrmPos,LBufSize);
        Inc(LStrmPos,LStringLen);
      end; //if
      Result := Result + BytesToString(LBuf, 0, LStringLen);
      //SetLength(Result, LResultLen + LStringLen);
      //Move(LBuf[0], PChar(Result)[LResultLen], LStringLen);
    end;//while
    VCLStream.Position := LStrmPos;
  end else begin
    EIdEndOfStream.IfTrue(AExceptionIfEOF, Format(RSEndOfStream, [ClassName, LStrmPos]));
  end;
end;

{
  Moves the current stream position by a relative number of bytes.
  >0 moves toward the end of stream.
  <0 moves toward the stream origin.
  0 does nothing.
}
procedure TIdStreamVCLBase.Skip(ASize: Integer);
begin
  if ASize <> 0 then begin
    VCLStream.Seek(ASize, IdFromCurrent);
  end;
end;

destructor TIdStreamVCLBase.Destroy;
begin
  if FreeStream then begin
    FreeAndNil(FVCLStream);
  end;
  inherited;
end;

function TIdStreamVCLBase.GetPosition: Integer;
begin
  Result := VCLStream.Position;
end;

procedure TIdStreamVCLBase.SetPosition(const AValue: Integer);
begin
  VCLStream.Position := AValue;
end;

function TIdStreamVCLBase.GetSize: Integer;
begin
  Result := VCLStream.Size;
end;

end.
