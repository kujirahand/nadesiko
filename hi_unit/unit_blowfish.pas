unit unit_blowfish;

interface

uses
  SysUtils, BlowFish, CryptUtils;

function BlowfishKeyCheck(Key: AnsiString): AnsiString;
function BlowfishEnc(s, Key: AnsiString): AnsiString;
function BlowfishDec(s, Key: AnsiString): AnsiString;

implementation

function BlowfishKeyCheck(Key: AnsiString): AnsiString;
begin
  // キーの長さを補完する(短いキーに対する修正)
  Result := 'com.nadesi::' + AnsiString(Trim(string(Key))) + ':nadesiko:pKUkh9Dhgj8m5KZTbkv:';
end;

function BlowfishEnc(s, Key: AnsiString): AnsiString;
const
  IV: array [0..1 - 1] of Int64 = ($1FA3D38A3532AC56);
var
  Src, Dst: AnsiString;
  Size: Integer;
begin
  Key := BlowfishKeyCheck(Key);
  Src := s;
  with (TCryptCBC.Create(Key, TBlowFish.Create, IV, SizeOf(IV), pmStandard)) do
  try
    try
      Size := Length(Src);
      SetLength(Dst, OutputSize(Size));
      Encode(Src[1], Dst[1], Size);  // 暗号化
      //Size := Decode(Dst[1], Dst[1], Size);  // 復号
      //SetLength(Dst, Size);
      //Assert(Src = Dst);
      Result := Dst;
    except
      Result := '';
    end;
  finally
    Free;
  end;
end;

function BlowfishDec(s, Key: AnsiString): AnsiString;
const
  IV: array [0..1 - 1] of Int64 = ($1FA3D38A3532AC56);
var
  Dst: AnsiString;
  Size: Integer;
begin
  Key := BlowfishKeyCheck(Key);
  with (TCryptCBC.Create(Key, TBlowFish.Create, IV, SizeOf(IV), pmStandard)) do
  try
    try
      //Encode(Src[1], Dst[1], Size);  // 暗号化
      Dst := s;
      Size := Length(Dst);
      Size := Decode(Dst[1], Dst[1], Size);  // 復号
      SetLength(Dst, Size);
      //Assert(Src = Dst);
      Result := Dst;
    except
      Result := '';
    end;
  finally
    Free;
  end;
end;

end.
