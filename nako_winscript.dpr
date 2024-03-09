library nako_winscript;

uses
  FastMM4 in 'FastMM4.pas',
  Windows, SysUtils, Classes,
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',
  ComObj,
  ActiveX,
  Variants,
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas';


//------------------------------------------------------------------------------
// �o�^����֐�
//------------------------------------------------------------------------------

var scriptObj:Variant;

procedure init_my_script;
begin
  if VarIsNull(scriptObj) then
  begin
    scriptObj := CreateOleObject('MSScriptControl.ScriptControl');
  end;
end;

function procExecJScript(h: DWORD): PHiValue; stdcall;
var
  src, res: string;
  res_v: Variant;
begin
  // (1) �����̎擾
  src := getArgStr(h, 0, True);

  // (2) ����
  init_my_script;
  scriptObj.Language := 'JScript';
  res_v := scriptObj.Eval(src);
  res := VarToStr(res_v);
  res_v := Unassigned;

  // (3) �߂�l�̐ݒ�
  Result := hi_newStr(res); // �����^�̖߂�l���w�肷��
end;

function procExecVBScript(h: DWORD): PHiValue; stdcall;
var
  src, res: string;
  vres: Variant;
begin
  // (1) �����̎擾
  src := getArgStr(h, 0, True);

  // (2) ����
  init_my_script;
  scriptObj.Language := 'VBScript';
  vres := scriptObj.Eval(src);
  res := vres;
  vres := Unassigned;

  // (3) �߂�l�̐ݒ�
  Result := hi_newStr(res); // �����^�̖߂�l���w�肷��
end;

function procExecVBScriptAddCode(h: DWORD): PHiValue; stdcall;
var
  src: string;
begin
  // (1) �����̎擾
  src := getArgStr(h, 0, True);

  // (2) ����
  init_my_script;
  scriptObj.Language := 'VBScript';
  scriptObj.addCode(src);

  // (3) �߂�l�̐ݒ�
  Result := nil; // �����^�̖߂�l���w�肷��
end;



//------------------------------------------------------------------------------
// �v���O�C���Ƃ��ĕK�v�Ȋ֐��ꗗ
//------------------------------------------------------------------------------
// �ݒ肷��v���O�C���̏��
const S_PLUGIN_INFO = 'JScript/VBScript ���C�u���� by �N�W����s��';

function PluginVersion: DWORD; stdcall;
begin
  Result := 2; //�v���O�C�����g�̃o�[�W����
end;

procedure ImportNakoFunction; stdcall;
begin
  // �֐���ǉ������
  //<����>
  //+ScriptControl�g��(nako_winscript)
  //-VBSCRIPT/JSCRIPT����
  AddFunc('JSCRIPT����','{=?}S��',7300,procExecJScript,'JScript�̃v���O���������s����','JSCRIPT����');
  AddFunc('VBSCRIPT����','{=?}S��',7310,procExecVBScript,'VBScript�̃v���O����(��)�����s����','VBSCRIPT����');
  AddFunc('VBSCRIPT�R�[�h�ǉ�','{=?}S��',7311,procExecVBScriptAddCode,'VBScript�̃v���O�������`����','VBSCRIPT���[�ǂ���');
  //</����>
end;

//------------------------------------------------------------------------------
// ���܂肫�������
function PluginRequire: DWORD; stdcall; //�Ȃł����v���O�C���o�[�W����
begin
  Result := 2;
end;
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
begin
  Result := Length(S_PLUGIN_INFO);
  if (str <> nil)and(len > 0) then
  begin
    StrLCopy(str, S_PLUGIN_INFO, len);
  end;
end;
procedure PluginInit(Handle: DWORD); stdcall;
begin
  OleInitialize(nil);
  dnako_import_initFunctions(Handle);
  scriptObj := Null;
end;

function PluginFin: DWORD; stdcall;
begin
  Result := 0;
  if not VarIsNull(scriptObj) then
  begin
    scriptObj := Unassigned;
  end;
  OleUninitialize;
end;

//------------------------------------------------------------------------------
// �O���ɃG�N�X�|�[�g�Ƃ���֐��̈ꗗ(Delphi�ŕK�v)
exports
  ImportNakoFunction,
  PluginInfo,
  PluginVersion,
  PluginRequire,
  PluginInit,
  PluginFin;

{
initialization
  OleInitialize(nil);
finalization
  OleUninitialize;
}

begin
end.

