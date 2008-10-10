unit unit_blowfish;

interface

uses
  SysUtils, BlowFish, CryptUtils;

function BlowfishKeyCheck(Key: string): string;
function BlowfishEnc(s, Key: string): string;
function BlowfishDec(s, Key: string): string;

implementation

function BlowfishKeyCheck(Key: string): string;
begin
  // キーの長さを補完する(短いキーに対する修正)
  Result := 'com.nadesi::' + Trim(Key) + ':nadesiko:pKUkh9Dhgj8m5KZTbkv:';
end;

function BlowfishEnc(s, Key: string): string;
const
  IV: array [0..1 - 1] of Int64 = ($1FA3D38A3532AC56);
var
  Src, Dst: string;
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

function BlowfishDec(s, Key: string): string;
const
  IV: array [0..1 - 1] of Int64 = ($1FA3D38A3532AC56);
var
  Dst: string;
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
