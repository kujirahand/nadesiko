library audiotag;

uses
  FastMM4 in 'FastMM4.pas',
  Windows, SysUtils, Classes,
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',

  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  dll_audiotag_function in 'hi_unit\dll_audiotag_function.pas',
  WAVfile in 'hi_unit\audiotag\WAVfile.pas',
  WMAfile in 'hi_unit\audiotag\WMAfile.pas',
  AACfile in 'hi_unit\audiotag\AACfile.pas',
  APEtag in 'hi_unit\audiotag\APEtag.pas',
  CDAtrack in 'hi_unit\audiotag\CDAtrack.pas',
  FLACfile in 'hi_unit\audiotag\FLACfile.pas',
  fnmatch in 'hi_unit\audiotag\fnmatch.pas',
  ID3v1 in 'hi_unit\audiotag\ID3v1.pas',
  ID3v2 in 'hi_unit\audiotag\ID3v2.pas',
  Monkey in 'hi_unit\audiotag\Monkey.pas',
  MPEGaudio in 'hi_unit\audiotag\MPEGaudio.pas',
  MPEGplus in 'hi_unit\audiotag\MPEGplus.pas',
  OggVorbis in 'hi_unit\audiotag\OggVorbis.pas',
  MP4file in 'hi_unit\audiotag\MP4file.pas',
  sMediaTagReader in 'hi_unit\audiotag\sMediaTagReader.pas',
  TwinVQ in 'hi_unit\audiotag\TwinVQ.pas',
  sMediaTag in 'hi_unit\audiotag\sMediaTag.pas',
  jconvertex in 'hi_unit\jconvertex.pas',
  jconvert in 'hi_unit\jconvert.pas',
  unit_string2 in 'hi_unit\unit_string2.pas';

//------------------------------------------------------------------------------
// Plug-in import function
procedure ImportNakoFunction; stdcall;
begin
  RegistFunction;
end;

//------------------------------------------------------------------------------
// プラグインの情報
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
const STR_INFO = 'オーディオタグ取得プラグイン by クジラ飛行机';
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

