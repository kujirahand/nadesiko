program vnako;

{%File 'component\hedit251\heverdef.inc'}
{%File 'vnako.bdsproj'}

uses
  SysUtils,
  Classes,
  Forms,
  frmNakoU in 'frmNakoU.pas' {frmNako},
  vnako_function in 'vnako_unit\vnako_function.pas',
  UIWebBrowser in 'vnako_unit\UIWebBrowser\UIWebBrowser.pas',
  CsvUtils2 in 'vnako_unit\CsvUtils2.pas',
  CsvUtils2Grid in 'vnako_unit\CsvUtils2Grid.pas',
  strunit in 'vnako_unit\strunit.pas',
  mag in 'vnako_unit\mag.pas',
  GIFImage in 'vnako_unit\GIFImage.pas',
  fileDrop in 'vnako_unit\fileDrop.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  dnako_import in 'hi_unit\dnako_import.pas',
  unit_string in 'hi_unit\unit_string.pas',
  unit_pack_files in 'hi_unit\unit_pack_files.pas',
  hima_stream in 'hi_unit\hima_stream.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mini_file_utils in 'hi_unit\mini_file_utils.pas',
  mini_func in 'hi_unit\mini_func.pas',
  unit_windows_api in 'hi_unit\unit_windows_api.pas',
  frmDebugU in 'vnako_unit\frmDebugU.pas' {frmDebug},
  bmp_filter in 'vnako_unit\bmp_filter.pas',
  ABitmap in 'vnako_unit\ABitmap.pas',
  ABitmapFilters in 'vnako_unit\ABitmapFilters.PAS',
  AnimeBox in 'vnako_unit\AnimeBox.pas',
  nstretchf in 'vnako_unit\nstretchf.pas',
  frmMemoU in 'vnako_unit\frmMemoU.pas' {frmMemo},
  frmInputU in 'vnako_unit\frmInputU.pas' {frmInput},
  frmProgressU in 'vnako_unit\frmProgressU.pas' {frmProgress},
  frmErrorU in 'vnako_unit\frmErrorU.pas' {frmError},
  frmInputListU in 'vnako_unit\frmInputListU.pas' {frmInputList},
  frmPasswordU in 'vnako_unit\frmPasswordU.pas' {frmPassword},
  frmSelectButtonU in 'vnako_unit\frmSelectButtonU.pas' {frmSelectButton},
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  unit_tree_list in 'vnako_unit\unit_tree_list.pas',
  frmSayU in 'vnako_unit\frmSayU.pas' {frmSay},
  MagTypes in 'vnako_unit\MagTypes.pas',
  EasyMasks in 'vnako_unit\EasyMasks.pas',
  gui_benri in 'vnako_unit\gui_benri.pas',
  wildcard in 'vnako_unit\wildcard.pas',
  frmInputNumU in 'vnako_unit\frmInputNumU.pas' {frmInputNum},
  frmHukidasiU in 'vnako_unit\frmHukidasiU.pas' {frmHukidasi},
  jvIcon in 'vnako_unit\jvIcon.pas',
  StrSortGrid in 'vnako_unit\StrSortGrid.pas',
  mt19937 in 'hi_unit\mt19937.pas',
  memoXP in 'vnako_unit\memoXP.pas',
  SPILib in 'vnako_unit\SPILib.pas',
  ieconst in 'vnako_unit\UIWebBrowser\ieconst.pas',
  activex_helper in 'vnako_unit\UIWebBrowser\activex_helper.pas',
  unit_dbt in 'hi_unit\unit_dbt.pas',
  unit_base64 in 'hi_unit\unit_base64.pas',
  MedianCut in 'vnako_unit\MedianCut.pas',
  BigBitmap in 'vnako_unit\BigBitmap.pas',
  DIBUtils in 'vnako_unit\DIBUtils.pas',
  BitmapUtils in 'vnako_unit\BitmapUtils.pas',
  ErrDef in 'vnako_unit\ErrDef.pas',
  unit_vista in 'vnako_unit\unit_vista.pas',
  MSHTML_TLB in 'vnako_unit\UIWebBrowser\MSHTML_TLB.pas',
  TrackBox in 'component\TrackBox.pas',
  HEditor in 'component\hedit251\HEditor.pas',
  TntStdCtrls in 'component\TntUnicodeControls\TntStdCtrls.pas',
  TntControls in 'component\TntUnicodeControls\TntControls.pas',
  frmListU in 'vnako_unit\frmListU.pas' {frmList},
  dnako_loader in 'hi_unit\dnako_loader.pas',
  nadesiko_version in 'nadesiko_version.pas',
  unit_nakopanel in 'vnako_unit\unit_nakopanel.pas',
  HViewEdt in 'component\hedit251\HViewEdt.pas' {FormViewEditor},
  HEdtProp in 'component\hedit251\HEdtProp.pas',
  CppFountain in 'component\hedit251\CppFountain.pas',
  DelphiFountain in 'component\hedit251\DelphiFountain.pas',
  EditorExProp in 'component\hedit251\EditorExProp.pas',
  EditorFountain in 'component\hedit251\EditorFountain.pas',
  FountainEditor in 'component\hedit251\FountainEditor.pas' {FormFountainEditor},
  heClasses in 'component\hedit251\heClasses.pas',
  heColorManager in 'component\hedit251\heColorManager.pas',
  heFountain in 'component\hedit251\heFountain.pas',
  heRaStrings in 'component\hedit251\heRaStrings.pas',
  heStrConsts in 'component\hedit251\heStrConsts.pas',
  heStringList in 'component\hedit251\heStringList.pas',
  heUtils in 'component\hedit251\heUtils.pas',
  HimawariFountain in 'component\hedit251\HimawariFountain.pas',
  HPropUtils in 'component\hedit251\HPropUtils.pas',
  Hreplfm in 'component\hedit251\Hreplfm.pas' {FormReplace},
  Hschfm in 'component\hedit251\Hschfm.pas' {FormSearch},
  HStreamUtils in 'component\hedit251\HStreamUtils.pas',
  HStrProp in 'component\hedit251\HStrProp.pas' {FormStringsEditor},
  HTMLFountain in 'component\hedit251\HTMLFountain.pas',
  HtSearch in 'component\hedit251\HtSearch.pas',
  JavaFountain in 'component\hedit251\JavaFountain.pas',
  JSPFountain in 'component\hedit251\JSPFountain.pas',
  NadesikoFountain in 'component\hedit251\NadesikoFountain.pas',
  PerlFountain in 'component\hedit251\PerlFountain.pas',
  gldpng in 'component\gldpng\gldpng.pas',
  GLDPNGStream in 'component\gldpng\GLDPNGStream.pas',
  GLDStream in 'component\gldpng\GLDStream.pas',
  gldzlib in 'component\gldpng\gldzlib.pas',
  SFunc in 'component\gldpng\SFunc.pas',
  TKZLIB in 'component\gldpng\TKZLIB.pas',
  hOleddUtils in 'component\hedit251\hOleddUtils.pas',
  hOledd in 'component\hedit251\hOledd.pas',
  VistaAltFixUnit in 'component\VistaAltFixUnit.pas',
  GraphicEx in 'component\GraphicEx\GraphicEx.pas',
  vnako_message in 'vnako_unit\vnako_message.pas';

{$R *.TLB}

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmNako, frmNako);
  Application.CreateForm(TFormReplace, FormReplace);
  Application.CreateForm(TFormSearch, FormSearch);
  Application.Run;
end.
