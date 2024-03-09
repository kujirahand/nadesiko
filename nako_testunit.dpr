library nako_testunit;

uses
  FastMM4 in 'FastMM4.pas',
  Windows, SysUtils, Classes,
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',

  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  unit_string2 in 'hi_unit\unit_string2.pas',
  mini_file_utils in 'hi_unit\mini_file_utils.pas';


//------------------------------------------------------------------------------
// �ȉ��֐�
//------------------------------------------------------------------------------
var test_count: Integer = 0;
var test_ng: Integer = 0;
var test_log: string = '';

function sys_test_reset(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  test_count := 0;
  test_ng := 0;
  test_log := '';
end;

procedure log_writeLn(bOk:Boolean; msg: string);
var
  fname : string;
  lineno, fileno: Integer;
  funcid: DWORD;
  func: string;
begin
  // flineno & lineno
  nako_getLineNo(@fileno, @lineno);
  SetLength(fname, 1024);
  nako_getFilename(fileno, PChar(fname), 1023);
  fname := string(PChar(fname));
  // function
  func := '';
  funcid := nako_getLastUserFuncID;
  if (funcid > 0) then
  begin
    SetLength(func, 2048);
    nako_id2tango(funcid, PChar(func), 2047);
    func := PChar(func);
  end;

  // ���e�X�g�J�E���g�����Z
  Inc(test_count);
  if bOk then
  begin
    test_log := test_log + Format('OK,%s(%d),%s,%s',[fname, lineno, func, msg]) + #13#10;
  end else
  begin
    Inc(test_ng);
    test_log := test_log + Format('NG,%s(%d),%s,%s',[fname, lineno, func, msg]) + #13#10;
  end;
end;

function sys_test_ok(h: DWORD): PHiValue; stdcall;
var
  msg: string;
begin
  msg := getArgStr(h, 0, True);
  log_writeLn(True, msg);
  Result := nil;
end;

function sys_test_ng(h: DWORD): PHiValue; stdcall;
var
  msg: string;
begin
  msg := getArgStr(h, 0, True);
  log_writeLn(False, msg);
  Result := nil;
end;

function sys_test_exec(h: DWORD): PHiValue; stdcall;
var
  s1, s2: string;
  res: Boolean;
begin
  s1 := getArgStr(h, 0, True);
  s2 := getArgStr(h, 1);

  res := (s1 = s2);

  if res then
  begin
    log_writeLn(res, s1);
  end else
  begin
    log_writeLn(res, Format('�u%s�v���u%s�v',[s1,s2]));
  end;
  
  Result := hi_newBool(res);
end;

function sys_test_getResult(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(Format(
      'all=%d'#13#10+
      'ng=%d'#13#10+
      'ok=%d',[test_count, test_ng, (test_count - test_ng)]));
end;

function sys_test_getlog(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(test_log);
end;

function sys_finddll(h: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  s := getArgStr(h, 0);
  s := FindDLLFile(s);
  Result := hi_newBool(FileExists(s));
end;


//------------------------------------------------------------------------------
// �ȉ���΂ɕK�v�Ȋ֐�
//------------------------------------------------------------------------------
// �֐��ǉ��p
procedure ImportNakoFunction; stdcall;
begin
  // �Ȃł����V�X�e���Ɋ֐���ǉ�
  // <����>
  //+�e�X�g�x��(nako_testunit.dll)
  //-�e�X�g
  AddFunc('�e�X�g���Z�b�g', '',   -1, sys_test_reset,             '�e�X�g���ʂ����Z�b�g����',       '�Ă��Ƃ肹����');
  AddFunc('�e�X�g���s', '{=?}A��B��|B��', -1, sys_test_exec,      'A��B�����������e�X�g�����s����', '�Ă��Ƃ�������');
  AddFunc('�e�X�g����', '{=""}S��|S��', -1, sys_test_ok,            '�e�X�g���P�����������Ƃɂ���', '�Ă��Ƃ�������');
  AddFunc('�e�X�g���s', '{=""}S��|S��', -1, sys_test_ng,            '�e�X�g���P���s�������Ƃɂ���', '�Ă��Ƃ����ς�');
  AddFunc('�e�X�g���ʎ擾', '',   -1, sys_test_getResult,         '�e�X�g���ʂ��n�b�V���ŕԂ��B(ALL/NG/OK)�v�̌`���ŕԂ�',   '�Ă��Ƃ���������Ƃ�');
  AddFunc('�e�X�g���O�擾', '',   -1, sys_test_getlog,            '�e�X�g���ʂ̃��O�𓾂�',         '�Ă��Ƃ낮����Ƃ�');
  AddFunc('�v���O�C��DLL����', 'FILE��', -1, sys_finddll,         '�v���O�C���t�H���_�Ɏw��FILE��DLL�����邩�ǂ������ׂāA�͂����������ŕԂ�', '�Ղ炮����DLL���񂴂�');
  // </����>
end;

//------------------------------------------------------------------------------
// �v���O�C���̏��
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
const STR_INFO = '�e�X�g���j�b�g�v���O�C�� by �N�W����s��';
begin
  Result := Length(STR_INFO);
  if (str <> nil)and(len > 0) then
  begin
    StrLCopy(str, STR_INFO, len);
  end;
end;

//------------------------------------------------------------------------------
// �v���O�C���̃o�[�W����
function PluginVersion: DWORD; stdcall;
begin
  Result := 2; // �v���O�C�����̂̃o�[�W����
end;

//------------------------------------------------------------------------------
// �Ȃł����v���O�C���o�[�W����
function PluginRequire: DWORD; stdcall;
begin
  Result := 2; // �K��2��Ԃ�����
end;

procedure PluginInit(Handle: DWORD); stdcall;
begin
  dnako_import_initFunctions(Handle);
  mini_file_utils.DIR_PLUGINS := nako_getPluginsDir;
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
