unit CryptUtils;

interface

uses
  SysUtils, Classes;

type
  TCipher = class
    constructor Create; virtual;
    function Algorithm: string; virtual; abstract;
    function BlockSize: Integer; virtual; abstract;
    procedure Initialize(const Key; KeyBytes: Integer); virtual;
    procedure InitializeString(const Key: string); overload;
    procedure Encode(const Src; var Dst);
    procedure Decode(const Src; var Dst);
    procedure EncodeValue(const Src; var Dst); virtual; abstract;
    procedure DecodeValue(const Src; var Dst); virtual; abstract;
    procedure ValueToStream(const Src; var Dst); virtual;
    procedure StreamToValue(const Src; var Dst); virtual; 
  end;
  TCipherClass = class of TCipher;
  TPaddingMode = (pmStandard, pmOneAndZeroes, pmNull, pmSpace, pmNone);
  TCrypt = class
  private
    procedure Start;
    procedure EncodeBlock(const Src; var Dst); virtual; abstract;
    procedure DecodeBlock(const Src; var Dst); virtual; abstract;
  public
    PaddingMode: TPaddingMode;
    Cipher: TCipher;
    InitialVector: array of Byte;
    Vector: array of Byte;
    TempBlock: array of Byte;
    BufferSize: Integer;
    AutoFree: Boolean;
    constructor Create(Key: string; Cipher: TCipher; const IV; IVSize: Integer; PM: TPaddingMode; AutoFree: Boolean = True); overload;
    constructor Create(const Key; KeySize: Integer; Cipher: TCipher; const IV; IVSize: Integer; PM: TPaddingMode; AutoFree: Boolean = True); overload; virtual;
    destructor Destroy; override;
    procedure StartEncode; virtual;
    procedure StartDecode; virtual;
    function Padding(var Data; Size: Integer; Encode: Boolean): Integer; virtual;
    procedure MovePadding(const Src; var Dst; Size: Integer);
    function BlockSize: Integer;
    function OutputSize(InputSize: Integer): Integer;
    function Decode(const Src; var Dst; Size: Integer): Integer; overload;
    function Encode(const Src; var Dst; Size: Integer): Integer; overload;
    function Decode(Src, Dst: TStream): Integer; overload;
    function Encode(Src, Dst: TStream): Integer; overload;
    function UpdateDecode(const Src; var Dst; Size: Integer): Integer;
    function UpdateEncode(const Src; var Dst; Size: Integer): Integer;
    function FinalDecode(const Src; var Dst; Size: Integer): Integer;
    function FinalEncode(const Src; var Dst; Size: Integer): Integer;
  end;
  TCryptClass = class of TCrypt;
  TCryptECB = class(TCrypt)
    procedure EncodeBlock(const Src; var Dst); override;
    procedure DecodeBlock(const Src; var Dst); override;
  end;
  TCryptCBC = class(TCrypt)
    procedure EncodeBlock(const Src; var Dst); override;
    procedure DecodeBlock(const Src; var Dst); override;
  end;
  TSerialCrypt = class(TCrypt)
    procedure CustomEncodeBlock(const Src; var Dst; Size: Integer); virtual; abstract;
    procedure CustomDecodeBlock(const Src; var Dst; Size: Integer); virtual; abstract;
    procedure EncodeUseVector(const Src; var Dst; N, Size: Integer); virtual; abstract;
    procedure DecodeUseVector(const Src; var Dst; N, Size: Integer); virtual; abstract;
    procedure SerialEncode(const Src; var Dst; Size: Integer; var N: Integer);
    procedure SerialDecode(const Src; var Dst; Size: Integer; var N: Integer);
    procedure EncodeBlock(const Src; var Dst); override;
    procedure DecodeBlock(const Src; var Dst); override;
  end;
  TCryptCFB = class(TSerialCrypt)
    procedure EncodeUseVector(const Src; var Dst; N, Size: Integer); override;
    procedure DecodeUseVector(const Src; var Dst; N, Size: Integer); override;
    procedure CustomEncodeBlock(const Src; var Dst; Size: Integer); override;
    procedure CustomDecodeBlock(const Src; var Dst; Size: Integer); override;
  end;
  TCryptOFB = class(TSerialCrypt)
    procedure StartEncode; override;
    procedure StartDecode; override;
    procedure EncodeUseVector(const Src; var Dst; N, Size: Integer); override;
    procedure DecodeUseVector(const Src; var Dst; N, Size: Integer); override;
    procedure CustomEncodeBlock(const Src; var Dst; Size: Integer); override;
    procedure CustomDecodeBlock(const Src; var Dst; Size: Integer); override;
  end;



implementation

uses
  Math;

const
  DefaultBufferSize = 1024 * 8;

procedure XorArray(var A; const B; Count: Integer);
// A[I] = A[I] xor B[I]   (I = 0..Count - 1)
var
  I: Integer;
  PA, PB: PByteArray;
begin
  PA := @A;
  PB := @B;
  for I := 0 to Count - 1 do
    PA[I] := PA[I] xor PB[I];
end;

procedure XorArray2(var D; const A, B; Count: Integer);
// D[I] = A[I] xor B[I]   (I = 0..Count - 1)
var
  I: Integer;
  PD, PA, PB: PByteArray;
begin
  PA := @A;
  PB := @B;
  PD := @D;
  for I := 0 to Count - 1 do
    PD[I] := PA[I] xor PB[I];
end;

{ TCipher }

constructor TCipher.Create;
begin
  inherited;
end;

procedure TCipher.Decode(const Src; var Dst);
begin
  StreamToValue(Src, Dst);
  DecodeValue(Dst, Dst);
  ValueToStream(Dst, Dst);
end;

procedure TCipher.Encode(const Src; var Dst);
begin
  StreamToValue(Src, Dst);
  EncodeValue(Dst, Dst);
  ValueToStream(Dst, Dst);
end;

procedure TCipher.Initialize(const Key; KeyBytes: Integer);
begin

end;

procedure TCipher.InitializeString(const Key: string);
begin
  Initialize(Key[1], Length(Key));
end;

procedure TCipher.StreamToValue(const Src; var Dst);
begin
  Move(Src, Dst, BlockSize);
end;

procedure TCipher.ValueToStream(const Src; var Dst);
begin
  Move(Src, Dst, BlockSize);
end;

{ TCrypt }

function TCrypt.BlockSize: Integer;
begin
  Result := Cipher.BlockSize;
end;

constructor TCrypt.Create(Key: string; Cipher: TCipher;
  const IV; IVSize: Integer; PM: TPaddingMode; AutoFree: Boolean);
begin
  Create(Key[1], Length(Key), Cipher, IV, IVSize, PM, AutoFree);
end;

constructor TCrypt.Create(const Key; KeySize: Integer; Cipher: TCipher;
  const IV; IVSize: Integer; PM: TPaddingMode; AutoFree: Boolean);
begin
  BufferSize := DefaultBufferSize;
  Self.Cipher := Cipher;
  Cipher.Initialize(Key, KeySize);
  SetLength(InitialVector, BlockSize);
  SetLength(Vector, BlockSize);
  SetLength(TempBlock, BlockSize);
  Move(IV, InitialVector[0], Min(BlockSize, IVSize));
  PaddingMode := PM;
  Self.AutoFree := AutoFree;
end;

destructor TCrypt.Destroy;
begin
  if (AutoFree) then
    Cipher.Free;
  inherited;
end;

procedure TCrypt.MovePadding(const Src; var Dst; Size: Integer);
begin
  Move(Src, Dst, Size);
  Padding(Dst, Size, True);
end;

function TCrypt.OutputSize(InputSize: Integer): Integer;
var
  BS, Count: Integer;
begin
  if (PaddingMode = pmNone) then
  begin
    Result := InputSize;
    Exit;
  end;
  BS := BlockSize;
  Count := (InputSize + BS) div BS;
  Result := Count * BS;
end;

function TCrypt.Padding(var Data; Size: Integer; Encode: Boolean): Integer;
var
  D: PByteArray;
  procedure RaiseError;
  begin
    raise Exception.Create('Crypt Error');
  end;
  procedure Standard;
  begin
    if (Encode) then
    begin
      Result := BlockSIze - Size;
      FillChar(D[Size], Result, Result);
    end else
    begin
      Result := D[Size - 1];
    end;
  end;
  procedure OneAndZeroes;
  const
    One = $80;
  var
    I: Integer;
  begin
    if (Encode) then
    begin
      Result := BlockSize - Size;
      D[Size] := One;
      FillChar(D[Size + 1], Result - 1, 0);
    end else
    begin
      for I := Size - 1 downto 0 do
      begin
        if (D[I] <> 0) then
        begin
          if (D[I] = One) then
          begin
            Result := Size - I;
            Exit;
          end else
            RaiseError;
        end;
      end;
      RaiseError;
    end;
  end;
  procedure Fill(FillValue: Byte);
  var
    I: Integer;
  begin
    if (Encode) then
    begin
      Result := BlockSize - Size;
      FillChar(D[Size], Result, FillValue);
    end else
    begin
      for I := Size - 1 downto 0 do
        if (D[I] <> FillValue) then
        begin
          Result := Size - I - 1;
          Exit;
        end;
      Result := Size;
    end;
  end;
  procedure Null;
  begin
    Fill(0);
  end;
  procedure Space;
  begin
    Fill(Ord(' '));
  end;
begin
  D := @Data;
  case (PaddingMode) of
  pmStandard:
    Standard;
  pmOneAndZeroes:
    OneAndZeroes;
  pmNull:
    Null;
  pmSpace:
    Space;
  pmNone:
    ;
  end;
end;

procedure TCrypt.Start;
begin
  Move(InitialVector[0], Vector[0], BlockSize);
end;

function TCrypt.Decode(const Src; var Dst; Size: Integer): Integer;
begin
  Assert(Size mod BlockSize = 0);
  StartDecode;
  Result := FinalDecode(Src, Dst, Size);
end;

function TCrypt.Encode(const Src; var Dst; Size: Integer): Integer;
begin
  if (PaddingMode = pmNone) then
    Assert(Size mod BlockSize = 0);
  StartEncode;
  Result := FinalEncode(Src, Dst, Size);
end;

function TCrypt.UpdateDecode(const Src; var Dst; Size: Integer): Integer;
var
  I, BS, Count: Integer;
  S, D: PByte;
begin
  BS := BlockSize;
  Count := Size div BS;
  Result := Count * BS;
  S := @Src;
  D := @Dst;

  for I := 0 to Count - 1 do
  begin
    DecodeBlock(S^, D^);
    Inc(S, BS);
    Inc(D, BS);
  end;
end;

function TCrypt.UpdateEncode(const Src; var Dst; Size: Integer): Integer;
var
  I, BS, Count: Integer;
  S, D: PByte;
begin
  BS := BlockSize;
  Count := Size div BS;
  Result := Count * BS;
  S := @Src;
  D := @Dst;

  for I := 0 to Count - 1 do
  begin
    EncodeBlock(S^, D^);
    Inc(S, BS);
    Inc(D, BS);
  end;
end;

function TCrypt.FinalDecode(const Src; var Dst; Size: Integer): Integer;
var
  Count: Integer;
  S, D: PByte;
begin
  S := @Src;
  D := @Dst;
  Count := UpdateDecode(S^, D^, Size);
  Inc(D, Count - BlockSize);

  Result := Size - Padding(D^, BlockSize, False);
end;

function TCrypt.FinalEncode(const Src; var Dst; Size: Integer): Integer;
var
  Count: Integer;
  S, D: PByte;
begin
  Result := OutputSize(Size);
  S := @Src;
  D := @Dst;
  Count := UpdateEncode(S^, D^, Size);
  if (PaddingMode = pmNone) then
    Exit;

  Inc(S, Count);
  Inc(D, Count);
  MovePadding(S^, D^, Size mod BlockSize);
  EncodeBlock(D^, D^);
end;

function TCrypt.Decode(Src, Dst: TStream): Integer;
var
  B: array of Byte;
  Size: Integer;
  Count: Integer;
begin
  Assert(Src.Size mod BlockSize = 0);
  Size := BufferSize div BlockSize * BlockSize;
  Assert(Size mod BlockSize = 0);
  SetLength(B, OutputSize(Size));
  StartDecode;

  Count := Src.Read(B[0], Size);
  while (Src.Position <> Src.Size) do
  begin
    UpdateDecode(B[0], B[0], Count);
    Dst.Write(B[0], Count);
    Count := Src.Read(B[0], Size);
  end;
  Count := FinalDecode(B[0], B[0], Count);
  Dst.Write(B[0], Count);
  Result := Dst.Position;
end;

function TCrypt.Encode(Src, Dst: TStream): Integer;
var
  B: array of Byte;
  Size: Integer;
  Count: Integer;
begin
  if (PaddingMode = pmNone) then
    Assert(Src.Size mod BlockSize = 0);
  Size := BufferSize div BlockSize * BlockSize;
  Assert(Size mod BlockSize = 0);
  SetLength(B, OutputSize(Size));
  StartEncode;

  Count := Src.Read(B[0], Size);
  while (Src.Position <> Src.Size) do
  begin
    UpdateEncode(B[0], B[0], Count);
    Dst.Write(B[0], Count);
    Count := Src.Read(B[0], Size);
  end;
  Count := FinalEncode(B[0], B[0], Count);
  Dst.Write(B[0], Count);
  Result := Dst.Position;
end;

procedure TCrypt.StartDecode;
begin
  Start;
end;

procedure TCrypt.StartEncode;
begin
  Start;
end;

{ TCryptECB }

procedure TCryptECB.DecodeBlock(const Src; var Dst);
begin
  Cipher.Decode(Src, Dst);
end;

procedure TCryptECB.EncodeBlock(const Src; var Dst);
begin
  Cipher.Encode(Src, Dst);
end;

{ TCryptCBC }

procedure TCryptCBC.DecodeBlock(const Src; var Dst);
begin
  // Src = Dst ëŒçÙ
  Move(Src, TempBlock[0], BlockSize);
  Cipher.Decode(Src, Dst);
  XorArray(Dst, Vector[0], BlockSize);
  Move(TempBlock[0], Vector[0], BlockSize);
end;

procedure TCryptCBC.EncodeBlock(const Src; var Dst);
begin
  XorArray(Vector[0], Src, BlockSize);
  Cipher.Encode(Vector[0], Vector[0]);
  Move(Vector[0], Dst, BlockSize);
end;

{ TSerialCrypt }

procedure TSerialCrypt.DecodeBlock(const Src; var Dst);
begin
  CustomDecodeBlock(Src, Dst, BlockSize);
end;

procedure TSerialCrypt.EncodeBlock(const Src; var Dst);
begin
  CustomEncodeBlock(Src, Dst, BlockSize);
end;

procedure TSerialCrypt.SerialDecode(const Src; var Dst; Size: Integer;
  var N: Integer);
var
  S, D: PByte;
  R, Count: Integer;
begin
  Assert(N < BlockSize);
  S := @Src;
  D := @Dst;
  if (N <> 0) then
  begin
    R := Min(BlockSize - N, Size);
    DecodeUseVector(Src, Dst, N, R);
    Inc(S, R);
    Inc(D, R);
    Dec(Size, R);
  end;
  Count := UpdateDecode(S^, D^, Size);
  Inc(S, Count);
  Inc(D, Count);
  N := Size mod BlockSize;
  CustomDecodeBlock(S^, D^, N);
end;

procedure TSerialCrypt.SerialEncode(const Src; var Dst; Size: Integer;
  var N: Integer);
var
  S, D: PByte;
  R, Count: Integer;
begin
  Assert(N < BlockSize);
  S := @Src;
  D := @Dst;
  if (N <> 0) then
  begin
    R := Min(BlockSize - N, Size);
    EncodeUseVector(Src, Dst, N, R);
    Inc(S, R);
    Inc(D, R);
    Dec(Size, R);
  end;
  Count := UpdateEncode(S^, D^, Size);
  Inc(S, Count);
  Inc(D, Count);
  N := Size mod BlockSize;
  CustomEncodeBlock(S^, D^, N);
end;

{ TCryptCFB }

procedure TCryptCFB.CustomDecodeBlock(const Src; var Dst; Size: Integer);
begin
  // Src = Dst ëŒçÙ
  Cipher.Encode(Vector[0], Vector[0]);
  DecodeUseVector(Src, Dst, 0, Size);
end;

procedure TCryptCFB.CustomEncodeBlock(const Src; var Dst; Size: Integer);
begin
  Cipher.Encode(Vector[0], Vector[0]);
  EncodeUseVector(Src, Dst, 0, Size);
end;

procedure TCryptCFB.DecodeUseVector(const Src; var Dst; N, Size: Integer);
begin
  Move(Src, TempBlock[N], Size);
  XorArray2(Dst, Src, Vector[N], Size);
  Move(TempBlock[N], Vector[N], Size);
end;

procedure TCryptCFB.EncodeUseVector(const Src; var Dst; N, Size: Integer);
begin
  XorArray2(Dst, Src, Vector[N], Size);
  Move(Dst, Vector[N], Size);
end;

{ TCryptOFB }

procedure TCryptOFB.CustomDecodeBlock(const Src; var Dst; Size: Integer);
begin
  CustomEncodeBlock(Src, Dst, Size);
end;

procedure TCryptOFB.CustomEncodeBlock(const Src; var Dst; Size: Integer);
begin
  Cipher.EncodeValue(Vector[0], Vector[0]);
  Cipher.ValueToStream(Vector[0], TempBlock[0]);
  EncodeUseVector(Src, Dst, 0, Size);
end;

procedure TCryptOFB.DecodeUseVector(const Src; var Dst; N, Size: Integer);
begin
  EncodeUseVector(Src, Dst, N, Size);
end;

procedure TCryptOFB.EncodeUseVector(const Src; var Dst; N, Size: Integer);
begin
  XorArray2(Dst, Src, TempBlock[N], Size);
end;

procedure TCryptOFB.StartDecode;
begin
  inherited;
  Cipher.StreamToValue(Vector[0], Vector[0]);
end;

procedure TCryptOFB.StartEncode;
begin
  inherited;
  Cipher.StreamToValue(Vector[0], Vector[0]);
end;

end.
