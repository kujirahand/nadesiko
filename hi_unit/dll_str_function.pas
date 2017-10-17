unit dll_str_function;

interface
uses
  windows, dnako_import, dnako_import_types, dll_plugin_helper;

const NAKOSTR_DLL_VERSION = '1.5041';
procedure RegistFunction;

implementation

uses jconvert, jconvertex, StrUnit, hima_types, unit_string, wildcard, md5,
  CrcUtils, unit_string2, SysUtils, Classes, wildcard2,
  nkf, unit_blowfish, SHA1, crypt, mini_file_utils, aeslib, EftGlobal,
  unit_sha256;

function NkfConvertStr(ins, option: string; IsUTF16:Boolean) : string;
begin
  Result := nkf.NkfConvertStr(ins, option, IsUTF16);
end;

function getNakoStrDllVersion(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(NAKOSTR_DLL_VERSION);
end;

function sys_toSJIS(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_newStr(NkfConvertStr(hi_str(s), '--sjis', False));
end;

// old function
{
function sys_nkf(args: DWORD): PHiValue; stdcall;
var
  s: string;
  a, b: string;
  fa,fb: Integer;

  function toCode(s: string): Integer;
  begin
    s := LowerCase(s);
    if s = 'sjis'       then Result := SJIS_OUT else
    if s = 'shift_jis'  then Result := SJIS_OUT else
    if s = 'jis'        then Result := JIS_OUT  else
    if s = 'euc'        then Result := EUC_OUT  else
    if s = 'utf8'       then Result := UTF8_OUT else
    if s = 'utf-8'      then Result := UTF8_OUT else
    if s = 'utf8n'      then Result := UTF8N_OUT else
    if s = 'utf-8n'     then Result := UTF8N_OUT else
    if s = 'unicode'    then Result := UNILE_IN else
    Result := -1;
  end;

begin
  // (1) 引数の取得
  s := getArgStr(args,0, True);
  a := getArgStr(args,1);
  b := getArgStr(args,2);
  // (2) データの処理
  fa := toCode(a);
  fb := toCode(b);

  // (3) 戻り値を設定
  Result := hi_newStr(ConvertJCode(s, fb, fa));
end;
}
{
    --ic=<input_codeset --oc=<output_codeset>>
        入力・出力の漢字コード系を指定します。

        ISO-2022-JP
            いわゆる JIS コード。-j, -J と同じ。

        ISO-2022-JP-1
            RFC 2237 に定められた形式。 JIS X 0212 を含む。

        ISO-2022-JP-3
            RFC 2237 に定められた形式。 JIS X 0213 を含む。

        EUC-JP
            EUC コード。-e, -E と同じ。

        EUC-JISX0213
            文字集合に JIS X 0213:2000 を用いた EUC-JP。

        EUC-JIS-2004
            文字集合に JIS X 0213:2004 を用いた EUC-JP。

        eucJP-ascii
            オープングループ日本ベンダ協議会が定義した eucJP-ascii。 -x
            が暗黙のうちに指定される。

        eucJP-ms
            オープングループ日本ベンダ協議会が定義した euc-JPms。 -x
            が暗黙のうちに指定される。

        CP51932
            Micorosft Code Page 51932。 -x が暗黙のうちに指定される。

        Shift_JIS
            Shift_JIS。 -s, -S と同じ。

        Shift_JISX0213
            文字集合に JIS X 0213:2000 を用いた Shift_JIS。

        Shift_JIS-2004
            文字集合に JIS X 0213:2004 を用いた Shift_JIS。

        CP932
            Micorosft Code Page 932。 -x が暗黙のうちに指定される。

        UTF-8 UTF-8N
            BOM 無しの UTF-8。 -w, -W と同じ。

        UTF-8-BOM
            BOM 付きの UTF-8。-w8 または -W と同じ。

        UTF8-MAC
            UTF8-MAC。互換分解されたひらがな・カタカナ等を結合します。

        UTF-16 UTF-16BE-BOM
            BOM 有りで Big Endian の UTF-16。 -w16B, -W16B と同じ。

        UTF-16BE
            BOM 無しで Big Endian の UTF-16。 -w16B0. -W16B と同じ。

        UTF-16LE-BOM
            BOM 有りで Little Endian の UTF-16。 -w16L, -W16L と同じ。

        UTF-16LE
            BOM 無しで Little Endian の UTF-16。 -w16L0, -W16L と同じ。

}
function sys_nkf(args: DWORD): PHiValue; stdcall;
var
  s, res: string;
  a, b: string;
  isUTF16: Boolean;

begin
  // (1) 引数の取得
  s := getArgStr(args,0, True); // target
  a := getArgStr(args,1);       // incode
  b := getArgStr(args,2);       // outcode
  // (2) 変換
  a := nkf_easy_code(a);
  b := nkf_easy_code(b);
  if UpperCase(b) = 'UTF-16' then isUTF16 := True else isUTF16 := False;
  res := NkfConvertStr(s, Format('--ic=%s --oc=%s',[a, b]), isUTF16);
  // (3) 戻り値を設定
  Result := hi_newStr(PAnsiChar(res+#0));
end;


function sys_nkf32(args: DWORD): PHiValue; stdcall;
var
  ins, opt, res: string;
begin
  // (1) 引数の取得
  ins := getArgStr(args,0, True);
  opt := getArgStr(args,1);
  // (2) データの処理
  res := NkfConvertStr(ins, opt, True);
  // (3) 戻り値を設定
  Result := hi_newStr(res);
end;


function sys_toUTF8(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  // Result := hi_newStr(ConvertJCode(hi_str(s), UTF8_OUT));
  Result := hi_newStr(Trim(NkfConvertStr(hi_str(s), '-w8', False)));
end;
function sys_toUTF8N(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  //Result := hi_newStr(ConvertJCode(hi_str(s), UTF8N_OUT));
  Result := hi_newStr(Trim(NkfConvertStr(hi_str(s), '-w80', False)));
end;

function sys_toUNICODE(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  //Result := hi_newStr(ConvertJCode(hi_str(s), UNILE_OUT));
  Result := hi_newStr(NkfConvertStr(hi_str(s), '-w16L0', True));
end;

function sys_toEUC(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  //Result := hi_newStr(ConvertJCode(hi_str(s), EUC_OUT));
  Result := hi_newStr(NkfConvertStr(hi_str(s), '-e', False));
end;

function sys_toJIS(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  //Result := hi_newStr(ConvertJCode(hi_str(s), JIS_OUT));
  Result := hi_newStr(NkfConvertStr(hi_str(s), '-j', False));
end;

function sys_toUTF8_SJIS(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, Utf8Tosjis(hi_str(s)));
  //Result := hi_newStr(NkfConvertStr(hi_str(s), '--ic=UTF-8 --oc=CP932'));
end;

function sys_toSJIS_UTF8(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, sjisToUtf8(hi_str(s)));
  //Result := hi_newStr(NkfConvertStr(hi_str(s), '--ic=CP932 -w8'));
end;

function sys_toUTF8N_SJIS(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, Utf8NTosjis(hi_str(s)));
  //Result := hi_newStr(NkfConvertStr(hi_str(s), '--ic=UTF-8N --oc=CP932'));
end;

function sys_toSJIS_UTF8N(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, sjisToUtf8N(hi_str(s)));
  //Result := hi_newStr(NkfConvertStr(hi_str(s), '--ic=CP932 -w80'));
end;


function sys_checkCode(args: DWORD): PHiValue; stdcall;
var
  str: string;
  ret: string;
begin
  // (1) 引数の取得
  str := getArgStr(args, 0, True);
  // (2) データの処理
  ret := NkfGuessCode(str);
  // (3) 戻り値を設定
  Result := hi_newStr(ret);
end;

function sys_Base64Encode(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, EncodeBase64(hi_str(s)));
end;
function sys_Base64Decode(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, DecodeBase64(hi_str(s)));
end;
function sys_URLEncode(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, jconvert.URLEncode(hi_str(s),True));
end;
function sys_URLDecode(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, URLDecode(hi_str(s)));
end;
function sys_HEXEncode(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, HEXEncode(hi_str(s)));
end;

function sys_HEXDecode(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, HEXDecode(hi_str(s)));
end;

function x_wsse_header(user, password:string): string;
var
  // s: TStringStream;
  wsse: string;
  nonce: string;
  created: string;
  passwordDigest: string;
begin
  {WSSE認証用の文字列を作る}
  //created                          //T12:00:00+09:00＝
  created := FormatDateTime('yyyy-mm-dd', Now) + 'T' + FormatDateTime('hh:nn:ss+09:00',Now);
  //nonce
  nonce := SHA1StringHex(created + IntToHex(Random(MaxInt), 8));
  //passwordDigest
  passwordDigest := SHA1StringBin(nonce + created + password);
  //wsse
  wsse := Format('X-WSSE: UsernameToken Username="%s", PasswordDigest="%s", Nonce="%s", Created="%s"',
                 [user, EncodeBase64(passwordDigest), EncodeBase64(nonce), created]);
  Result := wsse;
end;


function sys_wsse(args: DWORD): PHiValue; stdcall;
var
  s, user, pass: string;
begin
  user := getArgStr(args, 0, True);
  pass := getArgStr(args, 1);
  s := x_wsse_header(user, pass);
  Result := hi_newStr(s);
end;


function sys_entity_encode(args: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  s := getArgStr(args, 0, True);
  Result := hi_newStr(EntityEncode(s));
end;

function sys_entity_decode(args: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  s := getArgStr(args, 0, True);
  Result := hi_newStr(EntityDecode(s));
end;


function sys_DeleteTag(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_newStr(DeleteTag(hi_str(s)));
end;

function GetTags_ary(html:string; tag: string): PHiValue;
var
  s: string;
begin
  Result := hi_var_new;
  nako_ary_create(Result);

  while html <> '' do
  begin
    s := GetTag(html, tag);
    if s <> '' then begin
      nako_ary_add(Result, hi_newStr(s));
    end;
  end;
end;

function sys_getTags(args: DWORD): PHiValue; stdcall;
var
  s, a: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  a := nako_getFuncArg(args, 1);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := GetTags_ary(hi_str(s),hi_str(a));
end;
function sys_getTagTrees(args: DWORD): PHiValue; stdcall;
var
  ps, pa: PHiValue;
  s: string;
  tags: TStringList;
  i: Integer;
begin
  // (1) 引数の取得
  ps := nako_getFuncArg(args, 0);
  pa := nako_getFuncArg(args, 1);
  if ps = nil then ps := nako_getSore;
  Result := nil;

  // (2) データの処理
  s := hi_str(ps);
  tags := SplitChar('/', hi_str(pa));
  for i := 0 to tags.Count - 1 do
  begin
    if i = (tags.Count-1) then // 最後の１回
    begin
      Result := GetTags_ary(s, tags.Strings[i]);
    end else
    begin
      s := GetTags(s, tags.Strings[i]);
      //'<'をスペースに置き換えて、次のタグ抽出時にこのタグが引っかからないようにする
      //(div/divなどのような同じタグの階層構造に対応するため)
      if Length(s) > 0 then s[1]:=' ';
    end;
  end;
  tags.Free;
end;
function sys_tagAttribute(args: DWORD): PHiValue; stdcall;
var
  s, a, b: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  a := nako_getFuncArg(args, 1);
  b := nako_getFuncArg(args, 2);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_newStr(GetTagAttribute(hi_str(s), hi_str(a), hi_str(b), False));
end;

function sys_tagAttributeList(args: DWORD): PHiValue; stdcall;
var
  s, a: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  a := nako_getFuncArg(args, 1);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_newStr(GetTagAttribute(hi_str(s), hi_str(a), '', True));
end;

function sys_getLink(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  a, img, ss: string;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s = nil then s := nako_getSore;
  ss := hi_str(s);

  // (2) データの処理
  a   := GetTagAttribute(ss, 'A', 'href');
  img := GetTagAttribute(ss, 'IMG', 'src');

  // (3) 戻り値を設定
  Result := hi_newStr(a+img);
end;

function sys_absolutePath(args: DWORD): PHiValue; stdcall;
var
  s, a: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  a := nako_getFuncArg(args, 1);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_newStr(getAbsolutePath(hi_str(s), hi_str(a), '/'));
end;

function sys_getBasePath(args: DWORD): PHiValue; stdcall;
var
  s: string;
  i, start, last: Integer;
begin
  // (1) 引数の取得
  s := getArgStr(args, 0, True);
  // (2) データの処理
  start := Pos('://', s); if start > 0 then start := start + 3;
  last := 0;
  if start <> 0 then
  begin
    for i := start to Length(s) do
    begin
      if s[i] = '/' then last := i;
    end;
  end;

  if last = 0 then
  begin
    // スプリッターがない
    // http://... もない場合
    if start = 0 then s := ''; // 基本パスは空である
  end else
  begin
    s := Copy(s, 1, last);
  end;

  // (3) 戻り値を設定
  Result := hi_newStr(s);
end;

function sys_getUrlFilename(args: DWORD): PHiValue; stdcall;
var
  s: string;
  i, start, last: Integer;
begin
  // (1) 引数の取得
  s := getArgStr(args, 0, True);

  s := getToken_s(s, '?'); // http://xxx/xxx/xxx?a=b&c=d&e=f

  // (2) データの処理
  start := Pos('://', s); if start > 0 then start := start + 3;
  last := 0;
  if start <> 0 then
  begin
    for i := start to Length(s) do
    begin
      if s[i] = '/' then last := i;
    end;
  end;

  if last = 0 then
  begin
    // スプリッターがない
    // http://... もない場合
    if start = 0 then s := ''; // 基本パスは空である
  end else
  begin
    s := Copy(s, last+1, Length(s));
  end;

  // (3) 戻り値を設定
  Result := hi_newStr(s);
end;

function sys_getUrlDomain(args: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  // (1) 引数の取得
  s := getArgStr(args, 0, True);

  // http://xxx:port/xxx/xxx?a=b&c=d&e=f
  //--------------------------
  // プロトコル部分を削除
  getToken_s(s, '//');
  // ディレクトリまでを切り取る
  s := getToken_s(s, '/');
  // ポート番号があれば切り取る
  s := getToken_s(s, ':');

  // (3) 戻り値を設定
  Result := hi_newStr(s);
end;


function sys_toHira(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_newStr(convToHiragana(hi_str(s)));
end;
function sys_toKata(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_newStr(convToKatakana(hi_str(s)));
end;
function sys_toHankaku(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_newStr(convToHalf(hi_str(s)));
end;
function sys_toZenkaku(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_newStr(convToFull(hi_str(s)));
end;
function sys_toHankaku2(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_newStr(convToHalfAnk(hi_str(s)));
end;
function sys_toUpper(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_newStr(UpperCaseEx(hi_str(s)));
end;
function sys_toLower(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_newStr(LowerCaseEx(hi_str(s)));
end;
function sys_toHurigana(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_newStr(ConvToHurigana(hi_str(s), nako_getMainWindowHandle));
end;
function sys_cutline(args: DWORD): PHiValue; stdcall;
var
  s, a: PHiValue;
  res: string;
begin
  s := nako_getFuncArg(args, 0); if s = nil then s := nako_getSore;
  a := nako_getFuncArg(args, 1);
  res := CutLine(hi_str(s), hi_int(a), 4);
  Result := hi_newStr(res);
end;
function sys_toRomaji(args: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  s := getArgStr(args, 0, True);
  Result := hi_newStr(KanaToRomaji(s));
end;
function sys_toRomaji2Kana(args: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  s := getArgStr(args, 0, True);
  Result := hi_newStr(RomajiToKana(s));
end;




function StrXor(s:string; key: string): string;

  //------------------------------------------------------------------------------
  // 簡易乱数ルーチン
  const MAXRNDWORD = 8;
  const init_seed : array [0..MAXRNDWORD-1] of DWORD = ($2378164a, $8478acde, $8f7daf98, $3786daa4, $83748adf, $3428dafa, $89237da1, $3789fda1);
  var rnd_seed  : array [0..MAXRNDWORD-1] of DWORD;

  procedure InitRand;
  var
    i: Integer;
  begin
    for i := 0 to MAXRNDWORD-1 do
      rnd_seed[i] := init_seed[i];
  end;

  function ERand(N: DWORD): DWORD;
  var
    i, r0, r1: Integer;
  begin
    r0 := (rnd_seed[2] shl 7)  + (rnd_seed[3] shr 25);
    r1 := (rnd_seed[6] shl 26) + (rnd_seed[7] shr 6);

    for i := MAXRNDWORD-1 downto 1 do
    begin
      rnd_seed[i] := rnd_seed[i-1];
    end;
    rnd_seed[0] := r0 xor r1;

    Result := rnd_seed[0] mod N;
  end;
  //------------------------------------------------------------------------------

var
  i: Integer;
  b: Byte;
begin
  InitRand;
  if key = '' then key := '_YoNg yUan, wO_ aI youzI';

  for i := 1 to Length(s) do
  begin
    b := Ord(key[i mod Length(key) + 1]) xor ERand(256);
    s[i] := Chr( Ord(s[i]) xor b );
  end;
  Result := s;

end;
//------------------------------------------------------------------------------

function sys_easy_angouka(args: DWORD): PHiValue; stdcall;
var
  ps, pk: PHiValue;
  s, key, res: string;
begin
  ps := nako_getFuncArg(args, 0);
  pk := nako_getFuncArg(args, 1);
  s   := hi_str(ps);
  key := hi_str(pk);

  res := s;
  res := StrXor(res, key);
  res := EncodeBase64(res);
  Result := hi_newStr(res);
end;

function sys_easy_angou_kaijo(args: DWORD): PHiValue; stdcall;
var
  ps, pk: PHiValue;
  s, key, res: string;
begin
  ps := nako_getFuncArg(args, 0);
  pk := nako_getFuncArg(args, 1);
  s   := hi_str(ps);
  key := hi_str(pk);

  res := s;
  res := DecodeBase64(res);
  res := StrXor(res, key);
  Result := hi_newStr(res);
end;


function sys_blowfish_enc(args: DWORD): PHiValue; stdcall;
var
  res, key, s: string;
begin
  s   := getArgStr(args, 0, True);
  key := getArgStr(args, 1);
  res := BlowfishEnc(s, key);
  Result := hi_newStr(res);
end;

function sys_blowfish_dec(args: DWORD): PHiValue; stdcall;
var
  res, key, s: string;
begin
  s   := getArgStr(args, 0, True);
  key := getArgStr(args, 1);
  res := BlowfishDec(s, key);
  Result := hi_newStr(res);
end;


function sys_md5(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(
    md5.MD5Print(md5.MD5String( getArgStr(args, 0, True) ))
  );
end;

function sys_sha1(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(
    SHA1StringHex( getArgStr(args, 0, True))
  );
end;
function sys_sha256(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(
    LowerCase(_GetSHA256( getArgStr(args, 0, True)))
  );
end;

function sys_md5file(args: DWORD): PHiValue; stdcall;
var
  f: string;
begin
  f := getArgStr(args, 0, True);
  if not FileExists(f) then raise Exception.Create('ファイル"'+f+'"が見つかりません。');
  Result := hi_newStr(MD5FileS( f ));
end;

function sys_sha1file(args: DWORD): PHiValue; stdcall;
var
  f: string;
begin
  f := getArgStr(args, 0, True);
  if not FileExists(f) then raise Exception.Create('ファイル"'+f+'"が見つかりません。');
  Result := hi_newStr(SHA1StringHexFile(f));
end;

function sys_crypt(args: DWORD): PHiValue; stdcall;
var
  res, salt, s: AnsiString;
begin
  s   := getArgStr(args, 0, True);
  salt := getArgStr(args, 1);
  res := _crypt(PAnsiChar(s), PAnsiChar(salt));
  Result := hi_newStr(res);
end;

function sys_crc32(args: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
  crc32: TCrc32;
begin
  ps := nako_getFuncArg(args, 0);
  if ps = nil then ps := nako_getSore;

  crc32 := TCrc32R.Create(CRC32_ITU_T, True);
  crc32.Reset;
  crc32.Update(hi_str(ps));
  Result := hi_newFloat(crc32.Value);
  crc32.Free;
end;

function sys_crc16i(args: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
  crc16: TCrc16;
begin
  ps := nako_getFuncArg(args, 0);
  if ps = nil then ps := nako_getSore;

  crc16 := TCrc16R.Create(CRC16_ITU_T, False);
  crc16.Reset;
  crc16.Update(hi_str(ps));
  Result := hi_newInt(crc16.Value);
  crc16.Free;
end;

function sys_crc16a(args: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
  crc16: TCrc16;
begin
  ps := nako_getFuncArg(args, 0);
  if ps = nil then ps := nako_getSore;

  crc16 := TCrc16R.Create(CRC16_ASCII, False);
  crc16.Reset;
  crc16.Update(hi_str(ps));
  Result := hi_newInt(crc16.Value);
  crc16.Free;
end;

function sys_wildMatch(args: DWORD): PHiValue; stdcall;
var
  a, b: PHiValue;
  pat, s, src, res: string;
  pickup: TStringList;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  a   := nako_getFuncArg(args, 0);
  b   := nako_getFuncArg(args, 1);
  if a = nil then a := nako_getSore;

  // (2) データの処理
  s   := hi_str(a);
  pat := hi_str(b);

  pickup := TStringList.Create;
  try
    try
      //res := WildMatch(pat, s, pickup);
      src := s;
      if IsTopMatch(s, pat, pickup) then
      begin
        // マッチした部分を返す
        res := Copy(src, 1, Length(src) - Length(s));
      end else
      begin
        // マッチしなかがったのでそのまま
        s := src;
        res := '';
        pickup.Clear;
      end;
    except on e: Exception do
      raise Exception.Create('『'+pat+'』でマッチできません。' + e.Message);
    end;
    // (3) 戻り値の設定
    // res + pickup
    if (pickup = nil)or(pickup.Count = 0) then
    begin
      hi_setStr(Result, res);
    end else
    begin
      hi_setStr(Result, res+#13#10+pickup.Text);
    end;
    // 残り
    hi_setStr(a, s);
  finally
    pickup.Free;
  end;
end;


function sys_wildMatchBool(args: DWORD): PHiValue; stdcall;
var
  v: PHiValue;
  pickup: TStringList;
  a, b: string;
begin
  // (1) 引数の取得
  a := getArgStr(args, 0, True);
  b := getArgStr(args, 1, False);

  // (2) データの処理
  pickup := nil;
  if wildcard2.IsMatch(a, b, pickup) then
  begin
    Result := hi_newBool(True);
    v := nako_getVariable('抽出文字列');
    hi_setStr(v, pickup.Text);
  end else
  begin
    Result := hi_newBool(False);
  end;
  FreeAndNil(pickup);
end;


function sys_wildcard_replace(args: DWORD): PHiValue; stdcall;
var
  s, a, b: string;
begin
  // (1) 引数の取得
  s := getArgStr(args, 0, True);
  a := getArgStr(args, 1, False);
  b := getArgStr(args, 2, False);

  // (2) データの処理
  Result := hi_newStr( wildcard2.WildReplace(s, a, b, True) );
end;

function sys_wildcard_replace_one(args: DWORD): PHiValue; stdcall;
var
  s, a, b: string;
begin
  // (1) 引数の取得
  s := getArgStr(args, 0, True);
  a := getArgStr(args, 1, False);
  b := getArgStr(args, 2, False);

  // (2) データの処理
  Result := hi_newStr( wildcard2.WildReplace(s, a, b, False) );
end;

function sys_wildcard_split(args: DWORD): PHiValue; stdcall;
var
  s, a: string;
  sl: TStringList;
  i: Integer;
begin
  // (1) 引数の取得
  s := getArgStr(args, 0, True);
  a := getArgStr(args, 1, False);

  // (2) データの処理
  sl := WildSplit(s, a);
  try
    Result := hi_var_new;
    nako_ary_create(Result);
    for i := 0 to sl.Count - 1 do
    begin
      nako_ary_add(Result, hi_newStr(sl.Strings[i]));
    end;
  finally
    sl.Free;
  end;
end;

function sys_wildcard_match(args: DWORD): PHiValue; stdcall;
var
  a, b, v: PHiValue;
  pickup: TStringList;
begin
  // (1) 引数の取得
  a   := nako_getFuncArg(args, 0);
  b   := nako_getFuncArg(args, 1);
  if a = nil then a := nako_getSore;

  // (2) データの処理
  pickup := nil;

  Result := hi_newStr( wildcard2.WildSubMatch(hi_str(a), hi_str(b), pickup) );

  v := nako_getVariable('抽出文字列');
  hi_setStr(v, pickup.Text);

  FreeAndNil(pickup);
end;

function sys_wildcard_getToken(args: DWORD): PHiValue; stdcall;
var
  a, b, v: PHiValue;
  pickup: TStringList;
  s: string;
begin
  // (1) 引数の取得
  a   := nako_getFuncArg(args, 0);
  b   := nako_getFuncArg(args, 1);
  if a = nil then a := nako_getSore;

  // (2) データの処理
  pickup := nil;
  try
    // ワイルドカードでトークン切り出し
    s := hi_str(a);
    Result := hi_newStr( wildcard2.WildGetToken(s, hi_str(b), pickup) );

    // 残りの部分を切り取る
    hi_setStr(a, s);

    // 括りだしがあれば抽出文字列にセット
    v := nako_getVariable('抽出文字列');
    hi_setStr(v, pickup.Text);
  finally
    FreeAndNil(pickup);
  end;
end;

function sys_trimKakomi(args: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
  s: string;
begin
  // (1) 引数の取得
  ps := nako_getFuncArg(args, 0);
  if ps = nil then ps := nako_getSore;
  s := trimCoupleFlag(hi_str(ps));
  // (2) データの処理
  Result := hi_newStr(s);
end;


function AES_EncryptStr(InputStr, MyPassword: string): string;
var
  sSource,sDest : TStringStream;
begin
  Result := '';
  sSource := TStringStream.Create(InputStr);
  sDest   := TStringStream.Create('');
  try
    with TEncryption.Create(MyPassword, defCryptBufSize) do
    begin
      if EncryptStream(sSource, sDest) then begin
        Result := sDest.DataString;
      end else
      begin
        raise Exception.Create('AES Encrypt Error!');
      end;
    end;
  finally
    FreeAndNil(sSource);
    FreeAndNil(sDest);
  end;
end;

function AES_DecryptStr(InputStr, MyPassword: string): string;
var
  sSource: TStringStream;
  sDest  : TStringStream;
begin
  Result := '';
  sSource := TStringStream.Create(InputStr);
  sDest   := TStringStream.Create('');
  try
    with TEncryption.Create(MyPassword, defCryptBufSize) do
    begin
      if DecryptStream(sSource, sDest, sSource.Size) then begin
        //
        Result := sDest.DataString;
      end else
      begin
        raise Exception.Create('Decrypt Error!');
      end;
    end;
  finally
    FreeAndNil(sSource);
    FreeAndNil(sDest);
  end;
end;


function sys_aes_crypt(args: DWORD): PHiValue; stdcall;
var
  res, s, key: string;
begin
  s   := getArgStr(args, 0, True);
  key := getArgStr(args, 1);
  res := AES_EncryptStr(s, key);
  Result := hi_newStr(res);
end;
function sys_aes_decrypt(args: DWORD): PHiValue; stdcall;
var
  res, s, key: string;
begin
  s   := getArgStr(args, 0, True);
  key := getArgStr(args, 1);
  res := AES_DecryptStr(s, key);
  Result := hi_newStr(res);
end;

procedure RegistFunction;
begin
  //todo: 関数の登録
  //<整形処理>
  //+整形処理(nakostr.dll)
  //-文字コード変換
  AddFunc  ('SJIS変換','{文字列=?}Sを',700, sys_toSJIS,'文字列SをSJISに変換して返す','SJISへんかん','nkf32.dll');
  AddFunc  ('EUC変換','{文字列=?}Sを',701, sys_toEUC,'文字列SをEUCに変換して返す','EUCへんかん','nkf32.dll');
  AddFunc  ('JIS変換','{文字列=?}Sを',702, sys_toJIS,'文字列SをJISに変換して返す','JISへんかん','nkf32.dll');
  AddFunc  ('UTF8_SJIS変換','{文字列=?}Sを',703, sys_toUTF8_SJIS,'UTF8の文字列SをSJISに変換して返す','UTF8_SJISへんかん','nkf32.dll');
  AddFunc  ('SJIS_UTF8変換','{文字列=?}Sを',704, sys_toSJIS_UTF8,'SJISの文字列SをUTF8に変換して返す','SJIS_UTF8へんかん','nkf32.dll');
  AddFunc  ('UTF8N_SJIS変換','{文字列=?}Sを',705, sys_toUTF8N_SJIS,'UTF8Nの文字列SをSJISに変換して返す','UTF8N_SJISへんかん','nkf32.dll');
  AddFunc  ('SJIS_UTF8N変換','{文字列=?}Sを',706, sys_toSJIS_UTF8N,'SJISの文字列SをUTF8Nに変換して返す','SJIS_UTF8Nへんかん','nkf32.dll');
  AddFunc  ('文字コード調査','{文字列=?}Sを|Sの|Sから',707, sys_checkCode,'文字列Sの文字コードを調べて返す。(ASCII/BIN/SJIS/JIS/EUC/UTF-8/UTF-8N/UNILE/UNIBE)のいずれかを返す。','もじこーどちょうさ','nkf32.dll');
  AddFunc  ('UTF8変換','{文字列=?}Sを',708, sys_toUTF8,'文字列SをUTF8に変換して返す','UTF8へんかん','nkf32.dll');
  AddFunc  ('UTF8N変換','{文字列=?}Sを',709, sys_toUTF8N,'文字列SをUTF8Nに変換して返す','UTF8へんかん','nkf32.dll');
  AddFunc  ('UNICODE変換','{文字列=?}Sを',718, sys_toUNICODE,'文字列SをUNICODEに変換して返す','UNICODEへんかん','nkf32.dll');
  AddFunc  ('文字コード変換','{文字列=?}SをAからBへ',719, sys_nkf,'文字列Sを文字コードA(sjis|jis|euc|utf8|utf8n|unicode|任意のNKFコード)からBへと変換して返す。','もじこーどへんかん','nkf32.dll');
  AddFunc  ('NKF変換','{文字列=?}SをOPTで|SをOPTから', 740, sys_nkf32,'文字列SをNKFオプションOPTで変換して返す。','NKFへんかん','nkf32.dll');
  //-全角半角カナ変換
  AddFunc  ('かな変換','{文字列=?}Sを',710, sys_toHira,'文字列Sをひらがなに変換して返す','かなへんかん');
  AddFunc  ('カタカナ変換','{文字列=?}Sを',711, sys_toKata,'文字列Sをカタカナに変換して返す','かたかなへんかん');
  AddFunc  ('半角変換','{文字列=?}Sを',712, sys_toHankaku,'文字列Sを半角に変換して返す','はんかくへんかん');
  AddFunc  ('全角変換','{文字列=?}Sを',713, sys_toZenkaku,'文字列Sを全角に変換して返す','ぜんかくへんかん');
  AddFunc  ('英数半角変換','{文字列=?}Sを',714, sys_toHankaku2,'文字列Sを英数文字だけを半角に変換して返す','えいすうはんかくへんかん');
  AddFunc  ('大文字変換','{文字列=?}Sを',715, sys_toUpper,'文字列Sを大文字に変換して返す','おおもじへんかん');
  AddFunc  ('小文字変換','{文字列=?}Sを',716, sys_toLower,'文字列Sを小文字に変換して返す','こもじへんかん');
  AddFunc  ('漢字読み取得','{文字列=?}Sを|Sの',717, sys_toHurigana,'文章SのふりがなをIMEより取得する(コンソール上では機能しない)','かんじよみしゅとく');
  AddFunc  ('カナローマ字変換','{文字列=?}Sを|Sから',722, sys_toRomaji,'文字列Sにあるカタカナをローマ字に変換する','かなろーまじへんかん');
  AddFunc  ('ローマ字カナ変換','{文字列=?}Sを|Sから',723, sys_toRomaji2Kana,'文字列Sにあるローマ字をカタカナに変換する','ろーまじかなへんかん');
  //-エンコード
  AddFunc  ('BASE64エンコード','{文字列=?}Sを',730, sys_Base64Encode,'文字列SをBASE64に変換して返す','BASE64えんこーど');
  AddFunc  ('BASE64デコード','{文字列=?}Sを',731, sys_Base64Decode,'BASE64データSを復元して返す','BASE64でこーど');
  AddFunc  ('URLエンコード','{文字列=?}Sを',732, sys_URLEncode,'文字列SをURLエンコードして返す','URLえんこーど');
  AddFunc  ('URLデコード','{文字列=?}Sを',733, sys_URLDecode,'SをURLデコードして返す','URLでこーど');
  AddFunc  ('HEXエンコード','{文字列=?}Sを',734, sys_HEXEncode,'文字列SをHEXエンコードして返す','HEXえんこーど');
  AddFunc  ('HEXデコード','{文字列=?}Sを',735, sys_HEXDecode,'SをHEXデコードして返す','HEXでこーど');
  AddFunc  ('WSSEヘッダ生成','USERとPASSWORDから', 736, sys_wsse, 'AtomAPIのためにUSERとPASSWORDからX-WSSEヘッダを生成して返す。','WSSEへっださくせい');
  AddFunc  ('HTMLエンティティ変換','{文字列=?}Sを|Sから|Sの', 737, sys_entity_encode, '文字列SをHTMLエンティティに変換して返す','HTMLえんてぃてぃへんかん');
  AddFunc  ('HTMLエンティティ復号','{文字列=?}Sを|Sから|Sの', 738, sys_entity_decode, '文字列SをHTMLエンティティから文字に復号して返す','HTMLえんてぃてぃふくごう');
  //-HTML/XML処理
  AddFunc  ('タグ削除','{文字列=?}Sから|Sの',750, sys_DeleteTag,'Sのタグを削除','たぐさくじょ');
  AddFunc  ('タグ切り出し','{文字列=?}SからAの|SでAを|',751, sys_getTags,'SからAのタグを切り取る','たぐきりだし');
  AddFunc  ('タグ属性取得','{文字列=?}SのAからBを|Sで',752,sys_tagAttribute,'SからタグAの属性Bを取り出す','たぐぞくせいしゅとく');
  AddFunc  ('階層タグ切り出し','{文字列=?}SからAの|SでAを|',755, sys_getTagTrees,'Sから特定階層下のタグAを切り取る。例えば『head/title』『item/link』など','かいそうたぐきりだし');
  AddFunc  ('タグ属性一覧取得','{文字列=?}SからAの|Sで',756, sys_tagAttributeList,'SからタグAにある属性をハッシュ形式で取得する。','たぐぞくせいいちらんしゅとく');
  AddFunc  ('HTMLリンク抽出','{文字列=?}Sから|Sの',753, sys_getLink,'SからHTMLのリンク(A,IMGタグ)を抽出して返す','HTMLりんくちゅうしゅつ');
  AddFunc  ('URL展開','{文字列=?}AをBで',754, sys_absolutePath,'相対パスAを基本パスBでＵＲＬを展開する','URLてんかい');
  AddFunc  ('URL基本パス抽出','{文字列=?}URLから|URLの|URLで',757, sys_getBasePath,'URLから基本パスを抽出して返す','URLきほんぱすちゅうしゅつ');
  AddFunc  ('URLファイル名抽出','{文字列=?}URLから|URLの|URLで',758, sys_getUrlFilename,'URLからファイル名部分を抽出して返す','URLふぁいるめいちゅうしゅつ');
  AddFunc  ('URLドメイン名抽出','{文字列=?}URLから|URLの|URLで',759, sys_getUrlDomain,'URLからドメイン名の部分を抽出して返す','URLどめいんめいちゅうしゅつ');
  //-行揃え
  AddFunc  ('行揃え','{文字列=?}SをAで',780, sys_cutline, '文字列SをA桁で折り返すように出力する','ぎょうそろえ');
  //-ワイルドカード
  AddFunc  ('一致','{=?}AがBに|AをBで', 791, sys_wildMatchBool,'『ワイルドカード一致』と同じ。文字列AがパターンBと完全に一致するか調べ、はい(=1)かいいえ(=0)を返す。カッコで括ると変数『抽出文字列』へ抽出。','いっち');
  AddFunc  ('ワイルドカード一致','{=?}AがBに|AをBで', 797, sys_wildMatchBool,'文字列AがパターンBに完全にマッチするか調べ、はい(=1)かいいえ(=0)で返す。カッコで括ると変数『抽出文字列』へ抽出。','わいるどかーどいっち');
  AddFunc  ('ワイルドカード置換','{=?}SのAをBに|AからBへ', 793, sys_wildcard_replace,'文字列SにあるパターンAを文字列Bにワイルドカードで置換する。機能はVB上位互換。','わいるどかーどちかん');
  AddFunc  ('ワイルドカード単置換','{=?}SのAをBに|AからBへ', 794, sys_wildcard_replace_one,'文字列SにあるパターンAを文字列Bにワイルドカードで１度だけ置換する。機能はVB上位互換。','わいるどかーどたんちかん');
  AddFunc  ('ワイルドカード区切る','{=?}SをAで', 796, sys_wildcard_split,'文字列SをパターンAで区切って配列変数として返す。','わいるどかーどくぎる');
  AddFunc  ('ワイルドカードマッチ','{=?}AがBに|AをBで', 798, sys_wildcard_match,'文字列AがパターンBに部分的にでもマッチすれば、マッチする部分を返す。カッコで括ると変数『抽出文字列』へ抽出。','わいるどかーどまっち');
  AddFunc  ('ワイルドカード切り取る','{参照渡し=?}SのAまでを|SをAまで|SをAで', 799, sys_wildcard_getToken,'文字列SのパターンAまでを切り取って返す。切り取られた部分は文字列Sから削除される。カッコで括ると変数『抽出文字列』へ抽出。','わいるどかーどきりとる');
  //AddStrVar('抽出文字列', '', 795, '『正規表現マッチ』や『ワイルドカード一致』命令後にカッコで括った部分が抽出され代入される。','ちゅうしゅつもじれつ');
  //-簡易暗号化
  AddFunc  ('簡易暗号化',    'SをKEYで',   781, sys_easy_angouka,'文字列SへKEYで暗号をかけて返す。','かんいあんごうか');
  AddFunc  ('簡易暗号化解除','SをKEYで',   782, sys_easy_angou_kaijo,'暗号化した文字列SをKEYで暗号を解除して返す。','かんいあんごうかかいじょ');
  AddFunc  ('BLOWFISH暗号化', 'SをKEYで', 720, sys_blowfish_enc,'文字列SへKEYでBLOWSH暗号をかけて返す。','BLOWFISHあんごうか');
  AddFunc  ('BLOWFISH復号化', 'SをKEYで', 721, sys_blowfish_dec,'文字列SへKEYでBLOWSH暗号を解除して返す。','BLOWFISHふくごうか');
  AddFunc  ('CRYPT暗号化',    'SをSALTで',   788, sys_crypt,'文字列Sへ種SALTでUnix互換のCRYPT(DES)暗号をかけて返す。','CRYPTあんごうか');
  AddFunc  ('AES暗号化',      'SをKEYで',   789, sys_aes_crypt,'文字列SへKEYでAES暗号をかけて返す。','AESあんごうか');
  AddFunc  ('AES復号化',      'SをKEYで',   790, sys_aes_decrypt,'文字列SへKEYでAESの暗号を復号して返す。','AESふくごうか');

  //-チェックサム
  AddFunc  ('MD5取得',  '{=?}Sから|Sで|Sの',  783, sys_md5,     'バイナリSから改ざんの等の確認に使えるMD5文字列(HEX形式)を返す。','MD5しゅとく');
  AddFunc  ('CRC32取得','{=?}Sから|Sで|Sの',  784, sys_crc32,   'バイナリSからCRC32文字列を返す。','CRC32しゅとく');
  AddFunc  ('CRC16取得','{=?}Sから|Sで|Sの',  785, sys_crc16a,  'バイナリSからCRC16(ASCII)文字列を返す。','CRC16しゅとく');
  AddFunc  ('CRC16I取得','{=?}Sから|Sで|Sの', 786, sys_crc16i,  'バイナリSからCRC16(ITU_T)文字列を返す。','CRC16Iしゅとく');
  AddFunc  ('SHA1取得',  '{=?}Sから|Sで|Sの', 787, sys_sha1,    'バイナリSから改ざんの等の確認に使えるSHA-1文字列(HEX形式)を返す。','SHA1しゅとく');
  AddFunc  ('SHA256取得','{=?}Sから|Sで|Sの', 779, sys_sha256,  'バイナリSから改ざんの等の確認に使えるSHA-256文字列(HEX形式)を返す。','SHA256しゅとく');
  AddFunc  ('MD5ファイル取得',  '{=?}FILEから|FILEの', 801, sys_md5file,  'FILEから改ざんの等の確認に使えるMD5文字列(HEX形式)を返す。','MD5ふぁいるしゅとく');
  AddFunc  ('SHA1ファイル取得', '{=?}FILEから|FILEの', 802, sys_sha1file, 'FILEから改ざんの等の確認に使えるSHA-1文字列(HEX形式)を返す。','SHA1ふぁいるしゅとく');
  //-整形支援
  AddFunc  ('囲みトリム','{=?}Sの|Sから|Sで|Sを', 792, sys_trimKakomi,'文字列Sにある`S`や『S』などの囲み記号を消して返す。','かこみとりむ');
  //-nakostr.dll
  AddFunc  ('NAKOSTR_DLLバージョン','',800, getNakoStrDllVersion,'nakostr.dllのバージョンを返す','NAKOSTR_DLLばーじょん');
    //</整形処理>
end;

end.
