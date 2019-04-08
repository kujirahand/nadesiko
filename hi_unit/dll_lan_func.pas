unit dll_lan_func;

interface
uses
  windows, dnako_import, dnako_import_types, dll_plugin_helper,
  unit_pack_files, SysUtils, Classes, shellapi, registry, inifiles,
  shlobj, Variants, ActiveX, hima_types, messages, nadesiko_version;

procedure RegistFunction;

implementation

uses unit_file, unit_windows_api, unit_string, hima_stream, StrUnit,
  mini_file_utils, unit_archive, LanUtil, unit_text_file, ComObj,
  unit_kanrenduke,
  EasyMasks;


function nakolan_getUserName(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(GetUserName);
end;

function nakolan_GetComputerName(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(GetComputerName);
end;

function nakolan_LanEnumDomain(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(LanEnumDomain);
end;

function nakolan_LanEnumComputer(args: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
begin
  // (1) �����̎擾
  a := nako_getFuncArg(args, 0);
  if a = nil then
  begin
    Result := hi_newStr(LanEnumComputer('',True));
  end else
  begin
    Result := hi_newStr(LanEnumComputer(hi_str(a),True));
  end;
end;

function nakolan_LanEnumCommonDir(args: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
begin
  // (1) �����̎擾
  a := nako_getFuncArg(args, 0);
  Result := hi_newStr(LanGetCommonResource(hi_str(a)));
end;

function nakolan_WNetAddConnection2(args: DWORD): PHiValue; stdcall;
var
  drv, dir, pass, user: string;
begin
  Result := nil;
  drv := getArgStr(args, 0, True);
  dir := getArgStr(args, 1);
  user:= getArgStr(args, 2);
  pass:= getArgStr(args, 3);
  //
  drv := Trim(drv);
  drv := UpperCase(Copy(drv,1,1)) + ':';
  dir := ExcludeTrailingPathDelimiter(dir);
  //

  try
    if user = '' then
      AddNetworkDrive(PChar(drv), PChar(dir), nil)
    else
      AddNetworkDrive(PChar(drv), PChar(dir), nil,PChar(pass),Pchar(user));
  except
    on e: Exception do
      raise Exception.Create(Format('"%s"��"%s"�����蓖�Ăł��܂���ł����B' + e.Message,[drv,dir]));
  end;
end;

function nakolan_WNetCancelConnection2(args: DWORD): PHiValue; stdcall;
var
  drv:String;
begin
  Result := nil;
  drv := getArgStr(args, 0, True);
  drv := UpperCase(Copy(drv,1,1)) + ':';
  if WNetCancelConnection2(Pchar(drv),0,False) <> NO_ERROR then
    raise Exception.Create(Format('"%s"�̊��蓖�Ă������ł��܂���ł����B' + GetLastErrorStr,[drv]));
end;


procedure RegistFunction;
begin
  //<����>
  //+LAN(nakolan.dll)
  //-�R���s���[�^�[���
  AddFunc  ('���[�U�[���擾','', 630, nakolan_getUserName,'���O�I�����[�U�[����Ԃ��B','��[���[�߂�����Ƃ�');
  AddFunc  ('�R���s���[�^�[���擾','', 631, nakolan_getComputerName,'�R���s���[�^�[�̋��L����Ԃ�','����҂�[���[�߂�����Ƃ�');
  //-LAN���L�R���s���[�^�[���
  AddFunc  ('�h���C����','', 632, nakolan_LanEnumDomain,'LAN��̃h���C����񋓂��ĕԂ��B','�ǂ߂���������');
  AddFunc  ('�R���s���[�^�[��','{=?}DOMAIN��', 633, nakolan_LanEnumComputer,'LAN���DOMAIN�ɑ�����R���s���[�^�[��񋓂��ĕԂ��B','����҂�[���[�������');
  AddFunc  ('���L�t�H���_��','{=?}COM��', 634, nakolan_LanEnumCommonDir,'LAN���COM�̋��L�t�H���_��񋓂��ĕԂ��B','���傤�䂤�ӂ��邾�������');
  AddFunc  ('�l�b�g���[�N�h���C�u�ڑ�','A��B��{=�u�v}USER��{=�u�v}PASS��|A��B��', 635, nakolan_WNetAddConnection2,'�h���C�uA�Ƀl�b�g���[�N�t�H���_B�����蓖�Ă�B�ڑ����[�U��USER�ƃp�X���[�hPASS�͏ȗ��\�B','�˂��Ƃ�[���ǂ炢�Ԃ�����');
  AddFunc  ('�l�b�g���[�N�h���C�u�ؒf','A��|A��', 636, nakolan_WNetCancelConnection2,'�h���C�uA�Ɋ��蓖�Ă�ꂽ�l�b�g���[�N�t�H���_��ؒf����B','�˂��Ƃ�[���ǂ炢�Ԃ�����');
  //</����>
end;

end.
