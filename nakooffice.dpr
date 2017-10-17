library nakooffice;

uses
  FastMM4 in 'FastMM4.pas',
  Windows, SysUtils, Classes,
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',

  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  unit_string2 in 'hi_unit\unit_string2.pas',
  dll_office_function in 'hi_unit\dll_office_function.pas',
  unit_office in 'hi_unit\unit_office.pas',
  CsvUtils2 in 'vnako_unit\CsvUtils2.pas',
  StrUnit in 'hi_unit\strunit.pas',
  wildcard in 'hi_unit\wildcard.pas',
  unit_sqlite in 'hi_unit\unit_sqlite.pas',
  OpenOffice in 'hi_unit\OpenOffice.pas',
  mini_file_utils in 'hi_unit\mini_file_utils.pas',
  nkf in 'hi_unit\NKF.PAS',
  unit_dll_helper in 'hi_unit\unit_dll_helper.pas',
  unit_sqlite3 in 'hi_unit\unit_sqlite3.pas';

//------------------------------------------------------------------------------
// Plug-in import function
procedure ImportNakoFunction; stdcall;
begin
  RegistFunction;
end;

//------------------------------------------------------------------------------
// プラグインの情報
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
const STR_INFO = 'MS Office連携プラグイン by クジラ飛行机';
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
  Result := 2;
end;

//------------------------------------------------------------------------------
// なでしこプラグインバージョン
function PluginRequire: DWORD; stdcall;
begin
  Result := 2;
end;

// なでしこプラグインの終了処理
function PluginFin: DWORD; stdcall;
begin
  dll_office_function.PluginFin;
  Result := 0;
end;

//------------------------------------------------------------------------------
// プラグインの初期化
procedure PluginInit(h: DWORD); stdcall;
begin
  dnako_import.dnako_import_initFunctions(h);
  mini_file_utils.DIR_PLUGINS := nako_getPluginsDir;
end;

exports
  ImportNakoFunction,
  PluginInfo,
  PluginVersion,
  PluginRequire,
  PluginFin,
  PluginInit;

begin
end.
