library libvnako;

uses
  Windows,
  SysUtils,
  Classes,
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  mini_file_utils in 'hi_unit\mini_file_utils.pas',
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',
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
  Mag in 'vnako_unit\mag.pas',
  MagTypes in 'vnako_unit\MagTypes.pas',
  MedianCut in 'vnako_unit\MedianCut.pas',
  memoXP in 'vnako_unit\memoXP.pas',
  NadesikoFountain in 'vnako_unit\NadesikoFountain.pas',
  nstretchf in 'vnako_unit\nstretchf.pas',
  SPILib in 'vnako_unit\SPILib.pas',
  StrSortGrid in 'vnako_unit\StrSortGrid.pas',
  StrUnit in 'vnako_unit\strunit.pas',
  unit_nakopanel in 'vnako_unit\unit_nakopanel.pas',
  unit_tree_list in 'vnako_unit\unit_tree_list.pas',
  unit_vista in 'vnako_unit\unit_vista.pas',
  vnako_function in 'vnako_unit\vnako_function.pas',
  wildcard in 'vnako_unit\wildcard.pas',
  frmNakoU in 'frmNakoU.pas' {frmNako},
  ActiveIMM_TLB in 'component\TntUnicodeControls\ActiveIMM_TLB.pas',
  TntActnList in 'component\TntUnicodeControls\TntActnList.pas',
  TntAxCtrls in 'component\TntUnicodeControls\TntAxCtrls.pas',
  TntBandActn in 'component\TntUnicodeControls\TntBandActn.pas',
  TntButtons in 'component\TntUnicodeControls\TntButtons.pas',
  TntCheckLst in 'component\TntUnicodeControls\TntCheckLst.pas',
  TntClasses in 'component\TntUnicodeControls\TntClasses.pas',
  TntClipBrd in 'component\TntUnicodeControls\TntClipBrd.pas',
  TntComCtrls in 'component\TntUnicodeControls\TntComCtrls.pas',
  TntControls in 'component\TntUnicodeControls\TntControls.pas',
  TntDB in 'component\TntUnicodeControls\TntDB.pas',
  TntDBActns in 'component\TntUnicodeControls\TntDBActns.pas',
  TntDBClientActns in 'component\TntUnicodeControls\TntDBClientActns.pas',
  TntDBCtrls in 'component\TntUnicodeControls\TntDBCtrls.pas',
  TntDBGrids in 'component\TntUnicodeControls\TntDBGrids.pas',
  TntDBLogDlg in 'component\TntUnicodeControls\TntDBLogDlg.pas',
  TntDialogs in 'component\TntUnicodeControls\TntDialogs.pas',
  TntExtActns in 'component\TntUnicodeControls\TntExtActns.pas',
  TntExtCtrls in 'component\TntUnicodeControls\TntExtCtrls.pas',
  TntExtDlgs in 'component\TntUnicodeControls\TntExtDlgs.pas',
  TntFileCtrl in 'component\TntUnicodeControls\TntFileCtrl.pas',
  TntFormatStrUtils in 'component\TntUnicodeControls\TntFormatStrUtils.pas',
  TntForms in 'component\TntUnicodeControls\TntForms.pas',
  TntGraphics in 'component\TntUnicodeControls\TntGraphics.pas',
  TntGrids in 'component\TntUnicodeControls\TntGrids.pas',
  TntListActns in 'component\TntUnicodeControls\TntListActns.pas',
  TntMenus in 'component\TntUnicodeControls\TntMenus.pas',
  TntRegistry in 'component\TntUnicodeControls\TntRegistry.pas',
  TntStdActns in 'component\TntUnicodeControls\TntStdActns.pas',
  TntStdCtrls in 'component\TntUnicodeControls\TntStdCtrls.pas',
  TntSystem in 'component\TntUnicodeControls\TntSystem.pas',
  TntSysUtils in 'component\TntUnicodeControls\TntSysUtils.pas',
  TntWideStrings in 'component\TntUnicodeControls\TntWideStrings.pas',
  TntWideStrUtils in 'component\TntUnicodeControls\TntWideStrUtils.pas',
  TntWindows in 'component\TntUnicodeControls\TntWindows.pas',
  dnako_loader in 'hi_unit\dnako_loader.pas',
  unit_pack_files in 'hi_unit\unit_pack_files.pas',
  hima_stream in 'hi_unit\hima_stream.pas',
  ActiveX_Helper in 'vnako_unit\UIWebBrowser\activex_helper.pas',
  IEConst in 'vnako_unit\UIWebBrowser\ieconst.pas',
  IntShCut in 'vnako_unit\UIWebBrowser\intshcut.pas',
  javaSctipyHTMLParser in 'vnako_unit\UIWebBrowser\javaSctipyHTMLParser.pas',
  MSHTML_TLB in 'vnako_unit\UIWebBrowser\MSHTML_TLB.pas',
  MSHTMLParser in 'vnako_unit\UIWebBrowser\MSHTMLParser.pas',
  UIFavorites in 'vnako_unit\UIWebBrowser\UIFavorites.pas',
  UIWebBrowser in 'vnako_unit\UIWebBrowser\UIWebBrowser.pas',
  unit_windows_api in 'hi_unit\unit_windows_api.pas',
  unit_dbt in 'hi_unit\unit_dbt.pas',
  unit_base64 in 'hi_unit\unit_base64.pas';

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Plug-in import function
procedure ImportNakoFunction; stdcall;
var
  p: PHiValue;
  path: string;
begin
  // 命令を二重登録しない
  p := nako_getVariable('画面クリア');
  if p <> nil then Exit;
  // OPTION FLAG
  _flag_vnako_exe := False;
  _dnako_success  := True;
  // CREATE
  frmNako := TfrmNako.Create(nil);
  Bokan := frmNako;

  vnako_function.RegistCallbackFunction(frmNako.Handle);

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

