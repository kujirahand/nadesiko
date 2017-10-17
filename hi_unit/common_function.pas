unit common_function;
// 各プロジェクトで使うちょっとした関数を集めたユニット
interface

uses
  Windows, SysUtils, imm;

function ImeStr2ImeMode(s: AnsiString): DWORD;

implementation

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
