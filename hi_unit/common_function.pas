unit common_function;
// 各プロジェクトで使うちょっとした関数を集めたユニット
interface

uses
  {$IFDEF Win32}
  Windows, 
  imm,
  {$ENDIF}
  SysUtils; 

function ImeStr2ImeMode(s: AnsiString): DWORD;

implementation

{$IFDEF fpc}
const IME_CMODE_ALPHANUMERIC	 = $0000;
const IME_CMODE_NATIVE	 = $0001;
const IME_CMODE_CHINESE	= IME_CMODE_NATIVE;
const IME_CMODE_HANGEUL	= IME_CMODE_NATIVE;
const IME_CMODE_HANGUL	= IME_CMODE_NATIVE;
const IME_CMODE_JAPANESE	= IME_CMODE_NATIVE;
const IME_CMODE_KATAKANA	 = $0002;
const IME_CMODE_LANGUAGE	 = $0003;
const IME_CMODE_FULLSHAPE	 = $0008;
const IME_CMODE_ROMAN	 = $0010;
const IME_CMODE_CHARCODE	 = $0020;
const IME_CMODE_HANJACONVERT	 = $0040;
const IME_CMODE_SOFTKBD	 = $0080;
const IME_CMODE_NOCONVERSION	 = $0100;
const IME_CMODE_EUDC	 = $0200;
const IME_CMODE_SYMBOL	 = $0400;
const IME_CMODE_FIXED	 = $0800;
{$ENDIF}

function ImeStr2ImeMode(s: AnsiString): DWORD;
begin
  s := Copy(s,1,7);
  if s = 'IMEオン' then
  begin
    Result := IME_CMODE_JAPANESE or IME_CMODE_FULLSHAPE;
  end else
  if s = 'IMEオフ' then
  begin
    Result := IME_CMODE_ALPHANUMERIC;
  end else
  if (s = 'IMEひら')or(s = 'IMEかな') then
  begin
    Result := IME_CMODE_JAPANESE or IME_CMODE_FULLSHAPE;
  end else
  if (s = 'IMEカタ')or(s = 'IMEカナ') then
  begin
    Result := IME_CMODE_LANGUAGE or IME_CMODE_FULLSHAPE;
  end else
  if s = 'IME半角' then
  begin
    Result := IME_CMODE_LANGUAGE;
  end else
  begin
    Result := 0;
  end;
end;

end.
