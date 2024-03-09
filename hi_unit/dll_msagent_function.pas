unit dll_msagent_function;

interface

uses
  Windows,
  SysUtils,
  ms_agent,
  shellapi,
  dll_plugin_helper, dnako_import, dnako_import_types;


procedure RegistFunction;

implementation


function cmd_call_marlin(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentLoad('Merlin', 'Merlin.acs');
  ms_agent.AgentShow;
end;

function cmd_fin(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentFin;
end;

function cmd_call(HandleArg: DWORD): PHiValue; stdcall;
var
  pFile, pName: PHiValue;
begin
  Result := nil;
  pFile := nako_getFuncArg(HandleArg, 0);
  pName := nako_getFuncArg(HandleArg, 1);

  ms_agent.AgentLoad(hi_str(pName), hi_str(pFile));
  ms_agent.AgentShow;
end;

function cmd_show(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentShow;
end;

function cmd_hide(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentHide;
end;

function cmd_action(h: DWORD): PHiValue; stdcall;
var s: string;
begin
  Result := nil;

  s := getArgStr(h, 0, True);
  s := DeleteGobi(s);

  if s = '����'     then s := 'Confused' else
  if s = '�j��'     then s := 'Congratulate' else
  if s = '����'     then s := 'Explain' else
  if s = '���A'     then s := 'Greet' else
  if s = '���\'     then s := 'Announce' else
  if s = '��'       then s := 'Read' else
  if s = '��'       then s := 'Write' else
  if s = '�x'       then s := 'RestPose' else
  if s = '��'       then s := 'Surprised' else
  ;
  
  ms_agent.AgentPlay(s);
end;

function cmd_say(HandleArg: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentSpeak(getArgStr(HandleArg, 0, True));
end;

function cmd_move(HandleArg: DWORD): PHiValue; stdcall;
var px,py: PHiValue;
begin
  Result := nil;
  px := nako_getFuncArg(HandleArg, 0);
  py := nako_getFuncArg(HandleArg, 1);
  ms_agent.AgentMoveTo(hi_int(px),hi_int(py));
end;

function cmd_language(h: DWORD): PHiValue; stdcall;
var
  s: string;
  id: Integer;
begin
  Result := nil;
  s := getArgStr(h, 0, True);
  if s = '���{��' then id := $0411 else
  if s = '�p��'   then id := $0409 else
  if s = '������'   then id := $0804 else
  if s = '�؍���'   then id := $0412 else id := StrToIntDef(s, $0411);
  ms_agent.AgentChangeLanguage(id);
end;

function cmd_stop(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentStopAll;
end;

function cmd_size(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentSize(getArgInt(h,0),getArgInt(h,1));
end;

function cmd_waitfor(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentWaitFor;
end;

function cmd_tone(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentSpeakPitch(getArgInt(h,0));
end;

function cmd_speed(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentSpeakSpeed(getArgInt(h,0));
end;

function cmd_info(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(ms_agent.AgentGetInfo);
end;

function cmd_checkComponent(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newBool(ms_agent.AgentCheckInstall);
end;

function cmd_checkLang(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newBool(ms_agent.AgentCheckInstallLanguage(getArgStr(h,0,True)));
end;

function cmd_checkSAPI(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newBool(ms_agent.AgentCheckSAPI);
end;

function cmd_showDownloadWEB(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ShellExecute(0, 'open', 'http://www.microsoft.com/msagent/downloads/user.asp', '', '', SW_SHOW);
end;

procedure RegistFunction;
begin
  //todo: ���ߒǉ�
  //4520-4599
  //<����>
  //+MS Agent(msagent.dll)
  //-MS Agent
  AddFunc('�G�[�W�F���g�}�[��������','',4520,cmd_call_marlin,'MS�G�[�W�F���g�̕W���L�����N�^�[�u�}�[�����v��\������','���[������Ƃ܁[��񂵂傤����');
  AddFunc('�G�[�W�F���g�I��','',4521,cmd_fin,'MS�G�[�W�F���g�̋@�\���I������','���[������Ƃ��イ��傤');
  AddFunc('�G�[�W�F���g����','A����B��|A��B��',4522, cmd_call, '��`�t�@�C��(*.acs)A����L�����N�^�[B��\������','���[������Ƃ��傤����');
  AddFunc('�G�[�W�F���g�\��','',4523, cmd_show, '�G�[�W�F���g��\������','���[������ƂЂ傤��');
  AddFunc('�G�[�W�F���g��\��','',4524, cmd_hide, '�G�[�W�F���g���\���ɂ���','���[������ƂЂЂ傤��');
  AddFunc('�G�[�W�F���g����','{=?}S��',4525, cmd_action, '�G�[�W�F���g��S�̓���()��������','���[������Ƃǂ���');
  AddFunc('�G�[�W�F���g����','{=?}S��|S��',4526, cmd_say, '�G�[�W�F���g��S�𔭐�������','���[������Ƃ���');
  AddFunc('�G�[�W�F���g�ړ�','X,Y��',4527, cmd_move, '�G�[�W�F���g��X,Y�ֈړ�������','���[������Ƃ��ǂ�');
  AddFunc('�G�[�W�F���g����ύX','{=?}S��|S��|S��',4528, cmd_language, '�G�[�W�F���g�̘b�������(���{��|�p��|������|�؍���|���̑���ID)?�ɕύX����','���[������Ƃ��񂲂ւ񂱂�');
  AddFunc('�G�[�W�F���g�~�߂�','',4529, cmd_stop, '�G�[�W�F���g���b���̂��~�߂�B','���[������ƂƂ߂�');
  AddFunc('�G�[�W�F���g�҂�','',4530, cmd_waitfor, '�G�[�W�F���g�̍s�����I���̂�҂B','���[������Ƃ܂�');
  AddFunc('�G�[�W�F���g�T�C�Y�ύX','W,H��|H��',4531, cmd_size, '�G�[�W�F���g�̃T�C�Y��W,H�ɕύX����B','���[������Ƃ������ւ񂱂�');
  AddFunc('�G�[�W�F���g�g�[���ύX','A��',4532, cmd_tone, '�G�[�W�F���g�̐��̃g�[����ύX����B','���[������ƂƁ[��ւ񂱂�');
  AddFunc('�G�[�W�F���g���x�ύX','A��',4533, cmd_speed, '�G�[�W�F���g�̘b��������ύX����B','���[������Ƃ����ǂւ񂱂�');
  AddFunc('�G�[�W�F���g���擾','',4534, cmd_info, '�G�[�W�F���g�̏����擾���ăn�b�V���`���ŕԂ��B','���[������Ƃ��傤�ق�����Ƃ�');
  AddFunc('�G�[�W�F���g����`�F�b�N','',4535, cmd_checkComponent, '�G�[�W�F���g���C���X�g�[������Ă��邩�`�F�b�N���ĕԂ�','���[������Ƃǂ�����������');
  AddFunc('�G�[�W�F���g����`�F�b�N','{=?}S��|S��|S��|S��',4536, cmd_checkLang, '�G�[�W�F���g�̌���(���{��|�p��|������|�؍���|���̑���ID)���C���X�g�[������Ă��邩�`�F�b�N���ĕԂ�','���[������Ƃ��񂲂�������');
  AddFunc('�G�[�W�F���gSAPI�`�F�b�N','',4537, cmd_checkSAPI, '�G�[�W�F���g���b�����Ƃ��ł��邩(SAPI.DLL)�����邩�`�F�b�N���ĕԂ�','���[�������SAPI��������');
  AddFunc('�G�[�W�F���g�_�E�����[�h�T�C�g�J��','',4538, cmd_showDownloadWEB, '�G�[�W�F���g�̃_�E�����[�h�T�C�g���J��','���[������Ƃ������[�ǂ����ƂЂ炭');
  //</����>

end;

end.
