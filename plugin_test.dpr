library plugin_test;

uses
  FastMM4 in 'FastMM4.pas',
  Windows, SysUtils, Classes,
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',

  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  hima_types in 'hi_unit\hima_types.pas';

//------------------------------------------------------------------------------
// �o�^����e�X�g�֐�
//------------------------------------------------------------------------------
function testFunc(h: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  // (1) �����̎擾
  s := getArgStr(h, 0);

  // (2) ����
  MessageBox(0, 'test', PChar(s), MB_OK);

  // (3) �߂�l�̐ݒ� ... �������Ȃ��Ƃ��� Result := nil ��
  Result := hi_newStr(s);
end;

// �����Z���s���֐�
function tasizan(h: DWORD): PHiValue; stdcall;
var
  a, b, c: Integer;
begin
  // (1) �����̎擾
  a := getArgInt(h, 0); // 0�Ԗڂ̈����𓾂�
  b := getArgInt(h, 1); // 1�Ԗڂ̈����𓾂�

  // (2) ����
  c := a + b;

  // (3) �߂�l�̐ݒ�
  Result := hi_newInt( c ); // �����^�̖߂�l���w�肷��
end;



//------------------------------------------------------------------------------
// �v���O�C���Ƃ��ĕK�v�Ȋ֐��ꗗ
//------------------------------------------------------------------------------
// �ݒ肷��v���O�C���̏��
const S_PLUGIN_INFO = '�e�X�g�v���O�C�� by �N�W����s��';

function PluginVersion: DWORD; stdcall;
begin
  Result := 2; //�v���O�C�����g�̃o�[�W����
end;

procedure ImportNakoFunction; stdcall;
begin
  // �֐���ǉ������
  AddFunc('�e�X�g�\������','{=?}S��',-1,testFunc,'�e�X�g','�Ă��ƂЂ傤�������');
  AddFunc('�e�X�g�����Z','A��B��',-1,tasizan,'�����Z','�Ă��Ƃ�������');
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
  dnako_import_initFunctions(Handle);
end;
function PluginFin: DWORD; stdcall;
begin
  Result := 0;
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

begin
end.
