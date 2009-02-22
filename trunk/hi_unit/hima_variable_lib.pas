unit hima_variable_lib;

// ひま２特有の型である PHiValue に関する処理をまとめたもの

interface

uses
  hima_variable, hima_variable_ex;


// 文字列 str を 文字列 splitter で分けて配列形式で PHiValue に返す
function hi_split(str, splitter: PHiValue): PHiValue;

implementation

uses hima_string, unit_string;

// 文字列 str を 文字列 splitter で分けて配列形式で PHiValue に返す
function hi_split(str, splitter: PHiValue): PHiValue;
var
  s,  kugiri, res: AnsiString;
  sp: PAnsiChar;
  p: PHiValue;
begin
  s := hi_str(str);
  kugiri := hi_str(splitter);

  // 配列として返す
  Result := hi_var_new;
  hi_ary_create(Result);

  // 区切り処理
  while (s <> '') do
  begin
    res := getToken_s(s, kugiri);
    p := hi_var_new;
    hi_setStr(p, res);
    hi_ary(Result).Add(p);
  end;
end;

end.
