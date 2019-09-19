library nako_zip;

uses
  Windows,
  SysUtils,
  Classes,
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  unit_zip in 'unit_zip.pas',
  StrUnit2 in 'strunit2.pas';

//------------------------------------------------------------------------------
// �ȉ��֐�
//------------------------------------------------------------------------------

function zip_open(h: DWORD): PHiValue; stdcall;
begin
  Result  := nil;
  ZipDB.LoadFromFile(getArgStr(h,0));
end;
function zip_close(h: DWORD): PHiValue; stdcall;
begin
  Result  := nil;
  ZipDBFree;
end;

function zip_code_find(h: DWORD): PHiValue; stdcall;
begin
  //ZIP�ԍ����� --> �Z���Ŕԍ�������
  Result  := hi_newStr(ZipDB.FindZipCode(getArgStr(h,0),getArgStr(h,1),getArgStr(h,2)));
end;
function zip_addr_find(h: DWORD): PHiValue; stdcall;
begin
  //ZIP�Z������ --> �ԍ��ŏZ��������
  Result  := hi_newStr(ZipDB.FindZipAddr(getArgStr(h,0)));
end;
function zip_conv(h: DWORD): PHiValue; stdcall;
begin
  Result  := nil;
  ZipDB.LoadFromCsvFile(getArgStr(h,0), nil);
  ZipDB.SaveToFile(getArgStr(h,1));
end;
function zip_open_csv(h: DWORD): PHiValue; stdcall;
begin
  Result  := nil;
  ZipDB.LoadFromCsvFile(getArgStr(h,0), nil);
end;

function zip_getAllKen(h: DWORD): PHiValue; stdcall;
begin
  Result  := hi_newStr(ZipDB.getAllKen);
end;
function zip_getAllShi(h: DWORD): PHiValue; stdcall;
begin
  Result  := hi_newStr(ZipDB.getAllShi(getArgStr(h,0)));
end;
function zip_getAllCho(h: DWORD): PHiValue; stdcall;
begin
  Result  := hi_newStr(ZipDB.getAllCho(getArgStr(h,0),getArgStr(h,1)));
end;

//------------------------------------------------------------------------------
// �ȉ���΂ɕK�v�Ȋ֐�
//------------------------------------------------------------------------------
// �֐��ǉ��p
procedure ImportNakoFunction; stdcall;
begin
  // �Ȃł����V�X�e���Ɋ֐���ǉ�
  AddFunc('ZIP�f�[�^�J��', 'F��|F��|F����', 0, zip_open, '�X�֔ԍ��f�[�^�t�@�C�����J���B', '');
  AddFunc('ZIP�f�[�^CSV�J��', 'F��|F��|F����', 0, zip_open_csv, '�X�֋ǂ̃y�[�W�Ŕz�z���Ă���CSV�f�[�^���f�[�^�t�@�C���Ƃ��ĊJ���B(�ǂݍ��݂ɒ����Ԃ�v����)', '');
  AddFunc('ZIP����', '', 0, zip_close, '', '');
  //
  AddFunc('ZIP�Z������', 'ZIP��|ZIP��|ZIP��', 0, zip_addr_find, '', 'ZIP���イ���傯�񂳂�');
  AddFunc('ZIP�ԍ�����', 'KEN,SHI,CHO��', 0, zip_code_find, '', 'ZIP�΂񂲂����񂳂�');
  AddFunc('ZIP�f�[�^�쐬', 'CSV����F��|CSV��F��', 0, zip_conv, '', '');
  //
  AddFunc('ZIP�s���{���擾', '', 0, zip_getAllKen, '', '');
  AddFunc('ZIP�s��擾', 'KEN��', 0, zip_getAllShi, '', '');
  AddFunc('ZIP�����擾', 'KEN,SHI��', 0, zip_getAllCho, '', '');
end;

//------------------------------------------------------------------------------
// �v���O�C���̏��
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
const STR_INFO = '�X�֔ԍ��v���O�C�� by �N�W����s��';
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
  Result := 1; // �v���O�C�����̂̃o�[�W�����E�E�E�K���łn�j
end;

//------------------------------------------------------------------------------
// �Ȃł����v���O�C���o�[�W����
function PluginRequire: DWORD; stdcall;
begin
  Result := 1; // �K���P��Ԃ�����
end;


exports
  ImportNakoFunction,
  PluginInfo,
  PluginVersion,
  PluginRequire;


begin
end.
