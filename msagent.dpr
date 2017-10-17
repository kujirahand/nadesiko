library msagent;

uses
  FastMM4 in 'FastMM4.pas',
  Windows, SysUtils, Classes,
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',

  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  ms_agent in 'hi_unit\ms_agent.pas',
  dll_msagent_function in 'hi_unit\dll_msagent_function.pas';

//------------------------------------------------------------------------------
// Plug-in import function
procedure ImportNakoFunction; stdcall;
begin
  // 関数を追加する例
  RegistFunction;
end;

//------------------------------------------------------------------------------
// プラグインの情報
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
const STR_INFO = 'MS AGENTプラグイン by クジラ飛行机';
begin
  Result := Length(STR_INFO);
  if (str <> nil)and(len > 0) then
  begin
    StrLCopy(str, STR_INFO, len);
  end;
end;

//------------------------------------------------------------------------------
function PluginVersion: DWORD; stdcall;
begin
  Result := 2;
end;
function PluginRequire: DWORD; stdcall;
begin
  Result := 2;
end;
procedure PluginInit(Handle: DWORD); stdcall;
begin
  dnako_import_initFunctions(Handle);
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

