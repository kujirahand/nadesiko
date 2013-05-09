library libvnako;

{%File 'libvnako.bdsproj'}

// define "IS_LIBVNAKO"

uses
  FastMM4 in 'FastMM4.pas',
  Windows, SysUtils, Classes,
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',

  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  mini_file_utils in 'hi_unit\mini_file_utils.pas',
  ABitmap in 'vnako_unit\ABitmap.pas',
  ABitmapFilters in 'vnako_unit\ABitmapFilters.PAS',
  AnimeBox in 'vnako_unit\AnimeBox.pas',
  BigBitmap in 'vnako_unit\BigBitmap.pas',
  BitmapUtils in 'vnako_unit\BitmapUtils.pas',
  bmp_filter in 'vnako_unit\bmp_filter.pas',
  CsvUtils2 in 'vnako_unit\CsvUtils2.pas',
  CsvUtils2Grid in 'vnako_unit\CsvUtils2Grid.pas',
  DIBUtils in 'vnako_unit\DIBUtils.pas',
  EasyMasks in 'vnako_unit\EasyMasks.pas',
  ErrDef in 'vnako_unit\ErrDef.pas',
  fileDrop in 'vnako_unit\fileDrop.pas',
  frmDebugU in 'vnako_unit\frmDebugU.pas' {frmDebug},
  frmErrorU in 'vnako_unit\frmErrorU.pas' {frmError},
  frmHukidasiU in 'vnako_unit\frmHukidasiU.pas' {frmHukidasi},
  frmInputListU in 'vnako_unit\frmInputListU.pas' {frmInputList},
  frmInputNumU in 'vnako_unit\frmInputNumU.pas' {frmInputNum},
  frmInputU in 'vnako_unit\frmInputU.pas' {frmInput},
  frmListU in 'vnako_unit\frmListU.pas' {frmList},
  frmMemoU in 'vnako_unit\frmMemoU.pas' {frmMemo},
  frmPasswordU in 'vnako_unit\frmPasswordU.pas' {frmPassword},
  frmProgressU in 'vnako_unit\frmProgressU.pas' {frmProgress},
  frmSayU in 'vnako_unit\frmSayU.pas' {frmSay},
  frmSelectButtonU in 'vnako_unit\frmSelectButtonU.pas' {frmSelectButton},
  GIFImage in 'vnako_unit\GIFImage.pas',
  gui_benri in 'vnako_unit\gui_benri.pas',
  HimawariFountain in 'vnako_unit\HimawariFountain.pas',
  jvIcon in 'vnako_unit\jvIcon.pas',
  mag in 'vnako_unit\mag.pas',
  MagTypes in 'vnako_unit\MagTypes.pas',
  MedianCut in 'vnako_unit\MedianCut.pas',
  memoXP in 'vnako_unit\memoXP.pas',
  NadesikoFountain in 'vnako_unit\NadesikoFountain.pas',
  nstretchf in 'vnako_unit\nstretchf.pas',
  SPILib in 'vnako_unit\SPILib.pas',
  StrSortGrid in 'vnako_unit\StrSortGrid.pas',
  strunit in 'vnako_unit\strunit.pas',
  unit_nakopanel in 'vnako_unit\unit_nakopanel.pas',
  unit_tree_list in 'vnako_unit\unit_tree_list.pas',
  unit_vista in 'vnako_unit\unit_vista.pas',
  vnako_function in 'vnako_unit\vnako_function.pas',
  wildcard in 'vnako_unit\wildcard.pas',
  frmNakoU in 'frmNakoU.pas' {frmNako},
  dnako_loader in 'hi_unit\dnako_loader.pas',
  {$IFDEF DELUX_VERSION}
  unit_pack_files_pro in 'pro_unit\unit_pack_files_pro.pas',
  {$ENDIF}
  unit_pack_files in 'hi_unit\unit_pack_files.pas',
  hima_stream in 'hi_unit\hima_stream.pas',
  activex_helper in 'vnako_unit\UIWebBrowser\activex_helper.pas',
  ieconst in 'vnako_unit\UIWebBrowser\ieconst.pas',
  intshcut in 'vnako_unit\UIWebBrowser\intshcut.pas',
  javaSctipyHTMLParser in 'vnako_unit\UIWebBrowser\javaSctipyHTMLParser.pas',
  MSHTML_TLB in 'vnako_unit\UIWebBrowser\MSHTML_TLB.pas',
  MSHTMLParser in 'vnako_unit\UIWebBrowser\MSHTMLParser.pas',
  UIFavorites in 'vnako_unit\UIWebBrowser\UIFavorites.pas',
  UIWebBrowser in 'vnako_unit\UIWebBrowser\UIWebBrowser.pas',
  unit_windows_api in 'hi_unit\unit_windows_api.pas',
  unit_dbt in 'hi_unit\unit_dbt.pas',
  unit_base64 in 'hi_unit\unit_base64.pas',
  frmCalendarU in 'vnako_unit\frmCalendarU.pas' {frmCalendar},
  vnako_message in 'vnako_unit\vnako_message.pas';

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Plug-in import function
procedure ImportNakoFunction; stdcall;
var
  p: PHiValue;
  path: string;
  h:HWND;
begin
  // 命令を二重登録しない
  p := nako_getVariable('画面クリア');
  if p <> nil then Exit;
  // OPTION FLAG
  _flag_vnako_exe := False;
  _dnako_success  := True;
  //
  h := GetForegroundWindow;
  // CREATE
  frmNako := TfrmNako.Create(nil);
  Bokan := frmNako;

  vnako_function.RegistCallbackFunction(frmNako.Handle);
  nako_setMainWindowHandle(h);

  path := nako_getPluginsDir;
  try
    if FileExists(path + 'vnako.nako') then
    begin
      nako_eval_str2('!「'+path+'vnako.nako」を取り込む。');
    end else
    begin
      nako_eval_str2('!「vnako.nako」を取り込む。');
    end;
    frmNako.SetBokanHensu;
  except
  end;

end;

//------------------------------------------------------------------------------
// プラグインの情報
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
const STR_INFO = 'libvnakoプラグイン by クジラ飛行机';
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

