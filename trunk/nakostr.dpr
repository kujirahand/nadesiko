library nakostr;

uses
  FastMM4 in 'FastMM4.pas',
  Windows, SysUtils, Classes,
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',

  dll_str_function in 'hi_unit\dll_str_function.pas',
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  strunit in 'hi_unit\strunit.pas',
  jconvert in 'hi_unit\jconvert.pas',
  jconvertex in 'hi_unit\jconvertex.pas',
  hima_types in 'hi_unit\hima_types.pas',
  unit_string in 'hi_unit\unit_string.pas',
  wildcard in 'hi_unit\wildcard.pas',
  EasyMasks in 'hi_unit\EasyMasks.pas',
  md5 in 'hi_unit\md5.pas',
  CrcUtils in 'hi_unit\CrcUtils.pas',
  unit_string2 in 'hi_unit\unit_string2.pas',
  mt19937 in 'hi_unit\mt19937.pas',
  wildcard2 in 'hi_unit\wildcard2.pas',
  BlowFish in 'hi_unit\BlowFish.pas',
  CryptUtils in 'hi_unit\CryptUtils.pas',
  NKF in 'hi_unit\NKF.PAS',
  unit_blowfish in 'hi_unit\unit_blowfish.pas',
  Sha1 in 'hi_unit\Sha1.pas',
  crypt in 'hi_unit\crypt.pas',
  mini_file_utils in 'hi_unit\mini_file_utils.pas',
  aeslib in 'component\aeslib\aeslib.pas',
  EftGlobal in 'component\aeslib\EftGlobal.pas',
  unit_sha256 in 'hi_unit\unit_sha256.pas';

//------------------------------------------------------------------------------
// Plug-in import function
procedure ImportNakoFunction; stdcall;
begin
  RegistFunction;
end;

//------------------------------------------------------------------------------
// プラグインの情報
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
const STR_INFO = '文字列処理プラグイン by クジラ飛行机';
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
  mini_file_utils.DIR_PLUGINS := dnako_import.nako_getPluginsDir;
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

