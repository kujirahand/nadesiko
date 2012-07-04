program nakopad;

uses
  Forms,
  frmNakopadU in 'nakopad_unit\frmNakopadU.pas' {frmNakopad},
  gui_benri in 'vnako_unit\gui_benri.pas',
  unit_string in 'hi_unit\unit_string.pas',
  StrUnit in 'hi_unit\strunit.pas',
  hima_types in 'hi_unit\hima_types.pas',
  unit_file in 'hi_unit\unit_file.pas',
  unit_windows_api in 'hi_unit\unit_windows_api.pas',
  CsvUtils2 in 'vnako_unit\CsvUtils2.pas',
  wildcard in 'vnako_unit\wildcard.pas',
  nakopad_types in 'nakopad_unit\nakopad_types.pas',
  frmMakeExeU in 'nakopad_unit\frmMakeExeU.pas' {frmMakeExe},
  unit_pack_files in 'hi_unit\unit_pack_files.pas',
  hima_stream in 'hi_unit\hima_stream.pas',
  jconvertex in 'hi_unit\jconvertex.pas',
  jconvert in 'hi_unit\jconvert.pas',
  MSCryptUnit in 'hi_unit\MSCryptUnit.pas',
  wcrypt2 in 'hi_unit\Wcrypt2.pas',
  unit_string2 in 'hi_unit\unit_string2.pas',
  md5 in 'hi_unit\md5.pas',
  mt19937 in 'hi_unit\mt19937.pas',
  frmFindU in 'nakopad_unit\frmFindU.pas' {frmFind},
  frmReplaceU in 'nakopad_unit\frmReplaceU.pas' {frmReplace},
  unit_guiParts in 'nakopad_unit\unit_guiParts.pas',
  fileDrop in 'vnako_unit\fileDrop.pas',
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  TrackBox in 'component\TrackBox.pas',
  mini_file_utils in 'hi_unit\mini_file_utils.pas',
  unit_blowfish in 'hi_unit\unit_blowfish.pas',
  BlowFish in 'hi_unit\BlowFish.pas',
  CryptUtils in 'hi_unit\CryptUtils.pas',
  EasyMasks in 'hi_unit\EasyMasks.pas',
  nkf in 'hi_unit\NKF.PAS',
  unit_rewrite_icon in 'hi_unit\unit_rewrite_icon.pas',
  SHA1 in 'hi_unit\Sha1.pas',
  vnako_message in 'vnako_unit\vnako_message.pas',
  unit_pack_files_pro in 'pro_unit\unit_pack_files_pro.pas',
  nadesiko_version in 'nadesiko_version.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmNakopad, frmNakopad);
  Application.CreateForm(TfrmMakeExe, frmMakeExe);
  Application.Run;
end.
