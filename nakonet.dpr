library nakonet;

uses
  FastMM4 in 'FastMM4.pas',
  Windows, SysUtils, Classes,
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',

  nako_dialog_const in 'hi_unit\nako_dialog_const.pas',
  nako_dialog_function in 'hi_unit\nako_dialog_function.pas',
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  kskFtp in 'hi_unit\kskFtp.pas',
  dll_net_function in 'hi_unit\dll_net_function.pas',
  mini_file_utils in 'hi_unit\mini_file_utils.pas',
  unit_file in 'hi_unit\unit_file.pas',
  unit_windows_api in 'hi_unit\unit_windows_api.pas',
  WSockUtils in 'hi_unit\WSockUtils.pas',
  KPop3 in 'hi_unit\KPop3.pas',
  KSmtp in 'hi_unit\KSmtp.pas',
  mini_func in 'hi_unit\mini_func.pas',
  unit_string2 in 'hi_unit\unit_string2.pas',
  jconvertex in 'hi_unit\jconvertex.pas',
  jconvert in 'hi_unit\jconvert.pas',
  md5 in 'hi_unit\md5.pas',
  ktcp in 'hi_unit\ktcp.pas',
  KTCPW in 'hi_unit\KTCPW.pas',
  Icmp in 'hi_unit\Icmp.pas',
  KHttp in 'hi_unit\KHttp.pas',
  nadesiko_version in 'nadesiko_version.pas',
  UdpUnit in 'hi_unit\UdpUnit.pas',
  unit_eml in 'hi_unit\unit_eml.pas',
  unit_kabin in 'hi_unit\unit_kabin.pas',
  json in 'hi_unit\json.pas',
  unit_content_type in 'hi_unit\unit_content_type.pas',
  unit_date in 'hi_unit\unit_date.pas';

//------------------------------------------------------------------------------
// Plug-in import function
procedure ImportNakoFunction; stdcall;
{
var
  ret: PHiValue;
  s: string;
}
begin
  RegistFunction;
  {
  if nako_evalEx('!「nakonet.nako」を取り込む', ret) = False then
  begin
    SetLength(s, 2049);
    nako_getError(PChar(s), 2048); s := string(PChar(s));
    raise Exception.Create('「nakonet.nako」の取り込みに失敗しました。' + s);
  end;
  }
end;

//------------------------------------------------------------------------------
// プラグインの情報
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
const STR_INFO = 'ネットワーク処理プラグイン by クジラ飛行机';
begin
  Result := Length(STR_INFO);
  if (str <> nil)and(len > 0) then
  begin
    StrLCopy(str, STR_INFO, len);
  end;
end;

//------------------------------------------------------------------------------
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


