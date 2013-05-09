library nakofile;

uses
  FastMM4 in 'FastMM4.pas',
  Windows, SysUtils, Classes,
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',

  dll_file_function in 'hi_unit\dll_file_function.pas',
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  unit_file in 'hi_unit\unit_file.pas',
  unit_windows_api in 'hi_unit\unit_windows_api.pas',
  unit_pack_files in 'hi_unit\unit_pack_files.pas',
  hima_stream in 'hi_unit\hima_stream.pas',
  strunit in 'hi_unit\strunit.pas',
  mini_file_utils in 'hi_unit\mini_file_utils.pas',
  mini_func in 'hi_unit\mini_func.pas',
  unit_archive in 'hi_unit\unit_archive.pas',
  UnZip32 in 'hi_unit\UnZip32.pas',
  Zip32 in 'hi_unit\Zip32.pas',
  LanUtil in 'hi_unit\LanUtil.pas',
  unit_text_file in 'hi_unit\unit_text_file.pas',
  unit_kanrenduke in 'hi_unit\unit_kanrenduke.pas',
  EasyMasks in 'hi_unit\EasyMasks.pas',
  unit_blowfish in 'hi_unit\unit_blowfish.pas',
  BlowFish in 'hi_unit\BlowFish.pas',
  CryptUtils in 'hi_unit\CryptUtils.pas',
  unit_pack_files_pro in 'pro_unit\unit_pack_files_pro.pas';

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Plug-in import function
procedure ImportNakoFunction; stdcall;
begin
  RegistFunction;
end;

//------------------------------------------------------------------------------
// プラグインの情報
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
const STR_INFO = 'ファイル処理プラグイン by クジラ飛行机';
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
  mini_file_utils.DIR_PLUGINS := nako_getPluginsDir();
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
