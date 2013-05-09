library nako_testunit;

uses
  FastMM4 in 'FastMM4.pas',
  Windows, SysUtils, Classes,
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',

  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  unit_string2 in 'hi_unit\unit_string2.pas',
  mini_file_utils in 'hi_unit\mini_file_utils.pas';


//------------------------------------------------------------------------------
// 以下関数
//------------------------------------------------------------------------------
var test_count: Integer = 0;
var test_ng: Integer = 0;
var test_log: string = '';

function sys_test_reset(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  test_count := 0;
  test_ng := 0;
  test_log := '';
end;

procedure log_writeLn(bOk:Boolean; msg: string);
var
  fname : string;
  lineno, fileno: Integer;
  funcid: DWORD;
  func: string;
begin
  // flineno & lineno
  nako_getLineNo(@fileno, @lineno);
  SetLength(fname, 1024);
  nako_getFilename(fileno, PChar(fname), 1023);
  fname := string(PChar(fname));
  // function
  func := '';
  funcid := nako_getLastUserFuncID;
  if (funcid > 0) then
  begin
    SetLength(func, 2048);
    nako_id2tango(funcid, PChar(func), 2047);
    func := PChar(func);
  end;

  // 総テストカウントを加算
  Inc(test_count);
  if bOk then
  begin
    test_log := test_log + Format('OK,%s(%d),%s,%s',[fname, lineno, func, msg]) + #13#10;
  end else
  begin
    Inc(test_ng);
    test_log := test_log + Format('NG,%s(%d),%s,%s',[fname, lineno, func, msg]) + #13#10;
  end;
end;

function sys_test_ok(h: DWORD): PHiValue; stdcall;
var
  msg: string;
begin
  msg := getArgStr(h, 0, True);
  log_writeLn(True, msg);
  Result := nil;
end;

function sys_test_ng(h: DWORD): PHiValue; stdcall;
var
  msg: string;
begin
  msg := getArgStr(h, 0, True);
  log_writeLn(False, msg);
  Result := nil;
end;

function sys_test_exec(h: DWORD): PHiValue; stdcall;
var
  s1, s2: string;
  res: Boolean;
begin
  s1 := getArgStr(h, 0, True);
  s2 := getArgStr(h, 1);

  res := (s1 = s2);

  if res then
  begin
    log_writeLn(res, s1);
  end else
  begin
    log_writeLn(res, Format('「%s」≠「%s」',[s1,s2]));
  end;
  
  Result := hi_newBool(res);
end;

function sys_test_getResult(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(Format(
      'all=%d'#13#10+
      'ng=%d'#13#10+
      'ok=%d',[test_count, test_ng, (test_count - test_ng)]));
end;

function sys_test_getlog(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(test_log);
end;

function sys_finddll(h: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  s := getArgStr(h, 0);
  s := FindDLLFile(s);
  Result := hi_newBool(FileExists(s));
end;


//------------------------------------------------------------------------------
// 以下絶対に必要な関数
//------------------------------------------------------------------------------
// 関数追加用
procedure ImportNakoFunction; stdcall;
begin
  // なでしこシステムに関数を追加
  // <命令>
  //+テスト支援(nako_testunit.dll)
  //-テスト
  AddFunc('テストリセット', '',   -1, sys_test_reset,             'テスト結果をリセットする',       'てすとりせっと');
  AddFunc('テスト実行', '{=?}AとBで|Bを', -1, sys_test_exec,      'AとBが等しいかテストを実行する', 'てすとじっこう');
  AddFunc('テスト成功', '{=""}Sの|Sで', -1, sys_test_ok,            'テストが１つ成功したことにする', 'てすとせいこう');
  AddFunc('テスト失敗', '{=""}Sの|Sで', -1, sys_test_ng,            'テストが１つ失敗したことにする', 'てすとしっぱい');
  AddFunc('テスト結果取得', '',   -1, sys_test_getResult,         'テスト結果をハッシュで返す。(ALL/NG/OK)」の形式で返す',   'てすとけっかしゅとく');
  AddFunc('テストログ取得', '',   -1, sys_test_getlog,            'テスト結果のログを得る',         'てすとろぐしゅとく');
  AddFunc('プラグインDLL存在', 'FILEの', -1, sys_finddll,         'プラグインフォルダに指定FILEのDLLがあるかどうか調べて、はいかいいえで返す', 'ぷらぐいんDLLそんざい');
  // </命令>
end;

//------------------------------------------------------------------------------
// プラグインの情報
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
const STR_INFO = 'テストユニットプラグイン by クジラ飛行机';
begin
  Result := Length(STR_INFO);
  if (str <> nil)and(len > 0) then
  begin
    StrLCopy(str, STR_INFO, len);
  end;
end;

//------------------------------------------------------------------------------
// プラグインのバージョン
function PluginVersion: DWORD; stdcall;
begin
  Result := 2; // プラグイン自体のバージョン
end;

//------------------------------------------------------------------------------
// なでしこプラグインバージョン
function PluginRequire: DWORD; stdcall;
begin
  Result := 2; // 必ず2を返すこと
end;

procedure PluginInit(Handle: DWORD); stdcall;
begin
  dnako_import_initFunctions(Handle);
  mini_file_utils.DIR_PLUGINS := nako_getPluginsDir;
end;

function PluginFin: DWORD; stdcall;
begin
  Result := 0;
end;



exports
  ImportNakoFunction,
  PluginInfo,
  PluginVersion,
  PluginRequire,
  PluginInit;


begin
end.
