program extract;

uses
  windows,
  shellapi,
  SysUtils,
  Registry,
  unit_pack_files in 'hi_unit\unit_pack_files.pas',
  hima_types in 'hi_unit\hima_types.pas',
  hima_stream in 'hi_unit\hima_stream.pas',
  unit_string in 'hi_unit\unit_string.pas',
  mt19937 in 'hi_unit\mt19937.pas',
  UnZip32 in 'hi_unit\UnZip32.pas',
  unit_archive in 'hi_unit\unit_archive.pas',
  unit_file in 'hi_unit\unit_file.pas',
  unit_windows_api in 'hi_unit\unit_windows_api.pas',
  unit_dummy in 'hi_unit\unit_dummy.pas',
  Zip32 in 'hi_unit\Zip32.pas',
  mini_file_utils in 'hi_unit\mini_file_utils.pas';

var
  is_test:Boolean = false;
  is_debug: Boolean = false;

procedure RunAsAdmin(hWnd: THandle; aFile: string; aParameters: string);
var
  sei: TShellExecuteInfoA;
begin
  ZeroMemory(@sei, SizeOf(sei));
  sei.cbSize := SizeOf(sei);
  sei.Wnd := hWnd;
  sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  sei.lpVerb := 'runas';
  sei.lpFile := PChar(aFile);
  sei.lpParameters := PChar(aParameters);
  sei.nShow := SW_SHOWNORMAL;
  if not ShellExecuteEx(@sei) then
    raise Exception.Create('�N���Ɏ��s���܂����B(' + aFile + ')');
end;

procedure debug(s: string);
begin
  if is_debug then
  begin
    MessageBox(0, PChar(s), 'DEBUG', MB_OK);
  end;
end;

procedure exec;
var
  dir_temp: string;
  buf: string;
  tempPack: string;
  dirPack: string;
  config: string;
  mem: THMemoryStream;
  e: TFileMixReader;
  r: TRegistry;
const
  REGKEY = '\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Persisted';
begin
  // �p�b�N�t�@�C���̎��o��
  debug('packfile');
  if is_test then
    dir_temp := DesktopDir
  else
    dir_temp := TempDir;
  // get tempPack
  SetLength(buf, 4096);
  GetTempFileName(PChar(dir_temp), 'nak', 0, PChar(buf));
  tempPack := PChar(buf);
  debug('tempPack='+tempPack);
  // extract
  mem := THMemoryStream.Create;
  if is_test then
    ReadPackExeFile('nadesiko_setup.exe', mem, True)
  else
    ReadPackExeFile(ParamStr(0), mem, True);
  mem.SaveToFile(tempPack);
  mem.Free;
  //
  dirPack := tempPack + '_dir\';
  e := TFileMixReader.Create(tempPack);
  try
    try
      e.ExtractAllFile(dirPack);
      e.ReadFileAsString('config.txt', config, False);
      config := Trim(config);
    except
      MessageBox(0, 'Failed to extract.', 'SETUP ERROR', MB_OK or MB_ICONERROR);
    end;
  finally
    e.Free;
  end;
  debug('config='+config);
  // extract
  debug('path='+dirPack);
  unit_archive.PATH_ARCHIVE_DLL := dirPack;
  if (FileExists(dirPack + 'arc.zip')) then
  begin
    zip7_extract(dirPack + 'arc.zip', dirPack);
  end else
  if (FileExists(dirPack + 'ARC.YZ1')) then
  begin
    yz1_extract(dirPack + 'ARC.YZ1', dirPack);
  end else
  begin
    MessageBox(0, 'ERROR','���k�f�[�^������܂���B',MB_OK);
  end;
  // read cofig
  buf := dirPack + config;
  if FileExists(buf) then
  begin
    RunAsAdmin(0, buf, '');
  end;
  // �݊����E�B�U�[�h�𖳌��ɂ���
  if (Pos('setup', ParamStr(0)) > 0)or(Pos('install', ParamStr(0)) > 0) then
  begin
    r := TRegistry.Create;
    try
    r.RootKey := HKEY_CURRENT_USER;
    if r.OpenKey(REGKEY, True) then
    begin
      r.WriteInteger(ParamStr(0), 1);
    end;
    finally
      FreeAndNil(r);
    end;
  end;
end;

{$r extract.RES}

begin
  try
    exec;
    ExitCode := 0;
  except
  end;
end.
