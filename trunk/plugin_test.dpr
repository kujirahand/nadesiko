library plugin_test;

uses
  FastMM4 in 'FastMM4.pas',
  Windows, SysUtils, Classes,
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',

  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  hima_types in 'hi_unit\hima_types.pas';

//------------------------------------------------------------------------------
// 登録するテスト関数
//------------------------------------------------------------------------------
function testFunc(h: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  // (1) 引数の取得
  s := getArgStr(h, 0);

  // (2) 処理
  MessageBox(0, 'test', PChar(s), MB_OK);

  // (3) 戻り値の設定 ... 何もしないときは Result := nil を
  Result := hi_newStr(s);
end;

// 足し算を行う関数
function tasizan(h: DWORD): PHiValue; stdcall;
var
  a, b, c: Integer;
begin
  // (1) 引数の取得
  a := getArgInt(h, 0); // 0番目の引数を得る
  b := getArgInt(h, 1); // 1番目の引数を得る

  // (2) 処理
  c := a + b;

  // (3) 戻り値の設定
  Result := hi_newInt( c ); // 整数型の戻り値を指定する
end;



//------------------------------------------------------------------------------
// プラグインとして必要な関数一覧
//------------------------------------------------------------------------------
// 設定するプラグインの情報
const S_PLUGIN_INFO = 'テストプラグイン by クジラ飛行机';

function PluginVersion: DWORD; stdcall;
begin
  Result := 2; //プラグイン自身のバージョン
end;

procedure ImportNakoFunction; stdcall;
begin
  // 関数を追加する例
  AddFunc('テスト表示処理','{=?}Sを',-1,testFunc,'テスト','てすとひょうじしょり');
  AddFunc('テスト足し算','AとBを',-1,tasizan,'足し算','てすとたしざん');
end;

//------------------------------------------------------------------------------
// 決まりきった情報
function PluginRequire: DWORD; stdcall; //なでしこプラグインバージョン
begin
  Result := 2;
end;
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
begin
  Result := Length(S_PLUGIN_INFO);
  if (str <> nil)and(len > 0) then
  begin
    StrLCopy(str, S_PLUGIN_INFO, len);
  end;
end;
procedure PluginInit(Handle: DWORD); stdcall;
begin
  dnako_import_initFunctions(Handle);
end;
function PluginFin: DWORD; stdcall;
begin
  Result := 0;
end;

//------------------------------------------------------------------------------
// 外部にエクスポートとする関数の一覧(Delphiで必要)
exports
  ImportNakoFunction,
  PluginInfo,
  PluginVersion,
  PluginRequire,
  PluginInit,
  PluginFin;

begin
end.
