program comp;

uses
  windows,
  SysUtils,
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

procedure make;
var
  path, arcfile, outfile, outpath, inpath, tmp: string;
  config: string;
  e: TFileMixWriter;
begin
  // comp [in.yz1] [out.exe] [config.txt]
  path := ExtractFilePath(ParamStr(0));
  if ParamCount >= 1 then
  begin
    arcfile := ParamStr(1);
  end else begin
    //arcfile := path + 'arc.yz1';
    arcfile := path + 'arc.zip';
  end;
  if ParamCount >= 2 then
  begin
    outfile := ParamStr(2);
  end else begin
    outfile := path + 'setup_xxx.exe';
  end;
  if ParamCount >= 3 then
  begin
    config := ParamStr(3);
  end else begin
    config := path + 'config.txt';
  end;
  // ---
  inpath  := ExtractFilePath(arcfile);
  outpath := ExtractFilePath(outfile);
  tmp := TempDir + 'packfile.bin';
  // ---
  e := TFileMixWriter.Create;
  //e.AddFile(path+'Yz1.dll', 'Yz1.dll', 0);
  e.AddFile(path+'7-zip32.dll', '7-zip32.dll', 0);
  //e.AddFile(arcfile, 'arc.yz1', 0);
  e.AddFile(arcfile, 'arc.zip', 0);
  e.AddFile(config, 'config.txt', 0);
  e.SaveToFile(tmp);
  e.Free;

  WritePackExeFile(outfile, path+'extract.exe', tmp);
  //MessageBox(0, 'create exe', '', MB_OK);
  BEEP;
end;

begin
  try
    make;
  except
  end;
end.
