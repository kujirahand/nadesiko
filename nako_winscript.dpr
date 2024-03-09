library nako_winscript;

uses
  FastMM4 in 'FastMM4.pas',
  Windows, SysUtils, Classes,
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',
  ComObj,
  ActiveX,
  Variants,
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas';


//------------------------------------------------------------------------------
// 登録する関数
//------------------------------------------------------------------------------

var scriptObj:Variant;

procedure init_my_script;
begin
  if VarIsNull(scriptObj) then
  begin
    scriptObj := CreateOleObject('MSScriptControl.ScriptControl');
  end;
end;

function procExecJScript(h: DWORD): PHiValue; stdcall;
var
  src, res: string;
  res_v: Variant;
begin
  // (1) 引数の取得
  src := getArgStr(h, 0, True);

  // (2) 処理
  init_my_script;
  scriptObj.Language := 'JScript';
  res_v := scriptObj.Eval(src);
  res := VarToStr(res_v);
  res_v := Unassigned;

  // (3) 戻り値の設定
  Result := hi_newStr(res); // 整数型の戻り値を指定する
end;

function procExecVBScript(h: DWORD): PHiValue; stdcall;
var
  src, res: string;
  vres: Variant;
begin
  // (1) 引数の取得
  src := getArgStr(h, 0, True);

  // (2) 処理
  init_my_script;
  scriptObj.Language := 'VBScript';
  vres := scriptObj.Eval(src);
  res := vres;
  vres := Unassigned;

  // (3) 戻り値の設定
  Result := hi_newStr(res); // 整数型の戻り値を指定する
end;

function procExecVBScriptAddCode(h: DWORD): PHiValue; stdcall;
var
  src: string;
begin
  // (1) 引数の取得
  src := getArgStr(h, 0, True);

  // (2) 処理
  init_my_script;
  scriptObj.Language := 'VBScript';
  scriptObj.addCode(src);

  // (3) 戻り値の設定
  Result := nil; // 整数型の戻り値を指定する
end;



//------------------------------------------------------------------------------
// プラグインとして必要な関数一覧
//------------------------------------------------------------------------------
// 設定するプラグインの情報
const S_PLUGIN_INFO = 'JScript/VBScript ライブラリ by クジラ飛行机';

function PluginVersion: DWORD; stdcall;
begin
  Result := 2; //プラグイン自身のバージョン
end;

procedure ImportNakoFunction; stdcall;
begin
  // 関数を追加する例
  //<命令>
  //+ScriptControl拡張(nako_winscript)
  //-VBSCRIPT/JSCRIPT操作
  AddFunc('JSCRIPTする','{=?}Sを',7300,procExecJScript,'JScriptのプログラムを実行する','JSCRIPTする');
  AddFunc('VBSCRIPTする','{=?}Sを',7310,procExecVBScript,'VBScriptのプログラム(式)を実行する','VBSCRIPTする');
  AddFunc('VBSCRIPTコード追加','{=?}Sを',7311,procExecVBScriptAddCode,'VBScriptのプログラムを定義する','VBSCRIPTこーどついか');
  //</命令>
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
  OleInitialize(nil);
  dnako_import_initFunctions(Handle);
  scriptObj := Null;
end;

function PluginFin: DWORD; stdcall;
begin
  Result := 0;
  if not VarIsNull(scriptObj) then
  begin
    scriptObj := Unassigned;
  end;
  OleUninitialize;
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

{
initialization
  OleInitialize(nil);
finalization
  OleUninitialize;
}

begin
end.

