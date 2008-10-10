unit hima_stream;

// ひま２（なでしこ）で使うストリーム関連のユニット

interface

uses
  Windows, SysUtils;


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
  TSeekOrigin = (soBeginning, soCurrent, soEnd);

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

  THFileStream = class(THStream)
  protected
    FHandle: Integer;
    procedure SetSize(const NewSize: Int64); override;
  public
    constructor Create(const FileName: string; Mode: Word); overload;
    constructor Create(const FileName: string; Mode: Word; Rights: Cardinal); overload;
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    property Handle: Integer read FHandle;
  end;

  THMemoryStream = class(THStream)
  private
    FMemory: Pointer;
    FSize, FPosition: Longint;
    FCapacity: Longint;
    procedure SetCapacity(NewCapacity: Longint);
  protected
    procedure SetPointer(Ptr: Pointer; Size: Longint);
    function Realloc(var NewCapacity: Longint): Pointer; virtual;
    property Capacity: Longint read FCapacity write SetCapacity;
  public
    procedure Clear;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    procedure SetSize(const NewSize: Int64); override;
    property Memory: Pointer read FMemory;
    procedure LoadFromStream(Stream: THStream);
    procedure LoadFromFile(const FileName: string);
    procedure SaveToStream(Stream: THStream);
    procedure SaveToFile(const FileName: string);
  end;


implementation

{ THStream }

function THStream.CopyFrom(Source: THStream; Count: Int64): Int64;
const
  MaxBufSize = $F000;
var
  BufSize, N: Integer;
  Buffer: PChar;
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

{ THFileStream }

constructor THFileStream.Create(const FileName: string; Mode: Word);
begin
  Create(Filename, Mode, 0);
end;

constructor THFileStream.Create(const FileName: string; Mode: Word;
  Rights: Cardinal);
begin
  if Mode = fmCreate then
  begin
    FHandle := FileCreate(FileName, Rights);
    if FHandle < 0 then
      raise EInOutError.CreateFmt('ファイル『%s』の生成エラー',[FileName]);
  end
  else
  begin
    FHandle := FileOpen(FileName, Mode);
    if FHandle < 0 then
      raise EInOutError.CreateFmt('ファイル『%s』の生成エラー',[FileName]);
  end;
end;

destructor THFileStream.Destroy;
begin
  if FHandle >= 0 then FileClose(FHandle);
  inherited;
end;

function THFileStream.Read(var Buffer; Count: Integer): Longint;
begin
  Result := FileRead(FHandle, Buffer, Count);
  if Result = -1 then Result := 0;
end;

function THFileStream.Seek(const Offset: Int64;
  Origin: TSeekOrigin): Int64;
begin
  Result := FileSeek(FHandle, Offset, Ord(Origin));
end;

procedure THFileStream.SetSize(const NewSize: Int64);
begin
  Seek(NewSize, soBeginning);
  //Win32Check(SetEndOfFile(FHandle));
  SetEndOfFile(FHandle);
end;

function THFileStream.Write(const Buffer; Count: Integer): Longint;
begin
  Result := FileWrite(FHandle, Buffer, Count);
  if Result = -1 then Result := 0;
end;

{ THMemoryStream }

const
  MemoryDelta = $2000; { Must be a power of 2 }

procedure THMemoryStream.Clear;
begin
  SetCapacity(0);
  FSize := 0;
  FPosition := 0;
end;

procedure THMemoryStream.LoadFromFile(const FileName: string);
var
  Stream: THStream;
begin
  Stream := THFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure THMemoryStream.LoadFromStream(Stream: THStream);
var
  Count: Longint;
begin
  Stream.Position := 0;
  Count := Stream.Size;
  SetSize(Count);
  if Count <> 0 then Stream.ReadBuffer(FMemory^, Count);
end;

function THMemoryStream.Read(var Buffer; Count: Integer): Longint;
begin
  if (FPosition >= 0) and (Count >= 0) then
  begin
    Result := FSize - FPosition;
    if Result > 0 then
    begin
      if Result > Count then Result := Count;
      Move(Pointer(Longint(FMemory) + FPosition)^, Buffer, Result);
      Inc(FPosition, Result);
      Exit;
    end;
  end;
  Result := 0;
end;

function THMemoryStream.Realloc(var NewCapacity: Integer): Pointer;
begin
  if (NewCapacity > 0) and (NewCapacity <> FSize) then
    NewCapacity := (NewCapacity + (MemoryDelta - 1)) and not (MemoryDelta - 1);
  Result := Memory;
  if NewCapacity <> FCapacity then
  begin
    if NewCapacity = 0 then
    begin
      GlobalFreePtr(Memory);
      Result := nil;
    end else
    begin
      if Capacity = 0 then Result := GlobalAllocPtr(HeapAllocFlags, NewCapacity)
                      else Result := GlobalReallocPtr(Memory, NewCapacity, HeapAllocFlags);
      if Result = nil then raise EOutOfMemory.Create('メモリの再確保に失敗');
    end;
  end;
end;

procedure THMemoryStream.SaveToFile(const FileName: string);
var
  Stream: THStream;
begin
  Stream := THFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure THMemoryStream.SaveToStream(Stream: THStream);
begin
  if FSize <> 0 then Stream.WriteBuffer(FMemory^, FSize);
end;


function THMemoryStream.Seek(const Offset: Int64;
  Origin: TSeekOrigin): Int64;
begin
  case Origin of
    soBeginning : FPosition := Offset;
    soCurrent   : Inc(FPosition, Offset);
    soEnd       : FPosition := FSize + Offset;
  end;
  Result := FPosition;
end;

procedure THMemoryStream.SetCapacity(NewCapacity: Integer);
begin
  SetPointer(Realloc(NewCapacity), FSize);
  FCapacity := NewCapacity;
end;

procedure THMemoryStream.SetPointer(Ptr: Pointer; Size: Integer);
begin
  FMemory := Ptr;
  FSize := Size;
end;

procedure THMemoryStream.SetSize(const NewSize: Int64);
var
  OldPosition: Longint;
begin
  OldPosition := FPosition;
  SetCapacity(NewSize);
  FSize := NewSize;
  if OldPosition > NewSize then Seek(0, soEnd);
end;

function THMemoryStream.Write(const Buffer; Count: Integer): Longint;
var
  Pos: Longint;
begin
  if (FPosition >= 0) and (Count >= 0) then
  begin
    Pos := FPosition + Count;
    if Pos > 0 then
    begin
      if Pos > FSize then
      begin
        if Pos > FCapacity then
          SetCapacity(Pos);
        FSize := Pos;
      end;
      System.Move(Buffer, Pointer(Longint(FMemory) + FPosition)^, Count);
      FPosition := Pos;
      Result := Count;
      Exit;
    end;
  end;
  Result := 0;
end;

end.
