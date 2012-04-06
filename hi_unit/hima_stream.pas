unit hima_stream;

// ひま２（なでしこ）で使うストリーム関連のユニット

interface

uses
  Windows, SysUtils, Classes;


{$WARN SYMBOL_PLATFORM OFF}

const
{ THStream seek origins }

  soFromBeginning = 0;
  soFromCurrent   = 1;
  soFromEnd       = 2;

{ TFileStream create mode }

  fmCreate = $FFFF;

type
{ TStream seek origins }
  // TSeekOrigin = (soBeginning, soCurrent, soEnd);

  THStream = class(TObject)
  private
    function GetPosition: Int64;
    procedure SetPosition(const Pos: Int64);
  protected
    function GetSize: Int64; virtual;
    procedure SetSize(const NewSize: Int64); virtual; abstract;
  public
    function Read(var Buffer; Count: Longint): Longint; virtual; abstract;
    function Write(const Buffer; Count: Longint): Longint; virtual; abstract;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; virtual; abstract;
    procedure ReadBuffer(var Buffer; Count: Longint);
    procedure WriteBuffer(const Buffer; Count: Longint);
    function CopyFrom(Source: THStream; Count: Int64): Int64;
    property Position: Int64 read GetPosition write SetPosition;
    property Size: Int64 read GetSize write SetSize;
  end;



implementation

{ THStream }

function THStream.CopyFrom(Source: THStream; Count: Int64): Int64;
const
  MaxBufSize = $F000;
var
  BufSize, N: Integer;
  Buffer: PAnsiChar;
begin
  if Count = 0 then
  begin
    Source.Position := 0;
    Count := Source.Size;
  end;
  Result := Count;
  if Count > MaxBufSize then BufSize := MaxBufSize else BufSize := Count;
  GetMem(Buffer, BufSize);
  try
    while Count <> 0 do
    begin
      if Count > BufSize then N := BufSize else N := Count;
      Source.ReadBuffer(Buffer^, N);
      WriteBuffer(Buffer^, N);
      Dec(Count, N);
    end;
  finally
    FreeMem(Buffer, BufSize);
  end;
end;

function THStream.GetPosition: Int64;
begin
  Result := Seek(0, soCurrent);
end;

function THStream.GetSize: Int64;
var
  Pos: Int64;
begin
  Pos := Seek(0, soCurrent);
  Result := Seek(0, soEnd);
  Seek(Pos, soBeginning);
end;

procedure THStream.ReadBuffer(var Buffer; Count: Integer);
begin
  if (Count <> 0) and (Read(Buffer, Count) <> Count) then
    raise EInOutError.Create('ストリームの読み込みエラー');
end;

procedure THStream.SetPosition(const Pos: Int64);
begin
  Seek(Pos, soBeginning);
end;

procedure THStream.WriteBuffer(const Buffer; Count: Integer);
begin
  if (Count <> 0) and (Write(Buffer, Count) <> Count) then
    raise EInOutError.Create('ストリームの書き込みエラー');
end;

end.
