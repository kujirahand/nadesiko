library nako_filemaker;

uses
  Windows,
  SysUtils,
  ComObj,
  ActiveX,
  Variants,
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas';

//------------------------------------------------------------------------------
// �o�^����֐�
//------------------------------------------------------------------------------

var FMApp:Variant;
var FMDocs:Variant;
var FMFile:Variant;

const ID_FMPRO_APP = 'FMPRO.Application';

procedure init_filemaker;
begin
  if VarIsNull(FMApp) then
  begin
    try
      FMApp := GetActiveOleObject(ID_FMPRO_APP);
    except
      on E: EOleSysError do
      begin
        FMApp := CreateOleObject(ID_FMPRO_APP);
      end;
    end;
    FMDocs := FMApp.Documents;
    FMApp.Visible := True;
  end;
end;

function fmOpen(h: DWORD): PHiValue; stdcall;
var
  fname, userid, pass: string;
begin
  fname   := getArgStr(h, 0, True);
  userid  := getArgStr(h, 1);
  pass    := getArgStr(h, 2);
  init_filemaker;
  FMFile := FMDocs.Open(WideString(fname),WideString(userid),WideString(pass));
  Result := nil;
end;
function fmOpen2(h: DWORD): PHiValue; stdcall;
begin
  init_filemaker;
  FMFile := FMDocs.Active;
  Result := nil;
end;

function fmDoScript(h: DWORD): PHiValue; stdcall;
var
  scr: string;
  v: Variant;
begin
  scr := getArgStr(h, 0, True);
  if VarIsNull(FMApp) then
  begin
    init_filemaker;
    FMFile := FMDocs.Active;
  end;

  v := FMFile.DoFMScript(scr);
  //
  Result := nil;
  if VarIsStr(v) then
  begin
    Result := hi_newStr(VarToStr(v));
  end;
  v := Unassigned;
end;

function fmQuit(h: DWORD): PHiValue; stdcall;
begin
  FMApp.Quit;
  FMFile := Unassigned;
  FMDocs := Unassigned;
  FMApp := Unassigned;
  Result := nil;
end;


function fmCloseDoc(h: DWORD): PHiValue; stdcall;
begin
  FMFile.Close;
  FMFile := Unassigned;
  Result := nil;
end;

//------------------------------------------------------------------------------
// �v���O�C���Ƃ��ĕK�v�Ȋ֐��ꗗ
//------------------------------------------------------------------------------
// �ݒ肷��v���O�C���̏��
const S_PLUGIN_INFO = 'FileMaker ���C�u���� by �N�W����s��';

function PluginVersion: DWORD; stdcall;
begin
  Result := 2; //�v���O�C�����g�̃o�[�W����
end;

procedure ImportNakoFunction; stdcall;
begin
  // �֐���ǉ������
  //<����>
  //+FileMaker����(nako_filemaker)
  //-FileMaker����
  AddFunc('FILEMAKER�J��','{=?}FILE��USER��PASSWORD��',7350,fmOpen,'FileMaker�̃t�@�C�����J��(���̂Ƃ�USER��PASSWORD���w�肷��)','FILEMAKER�Ђ炭');
  AddFunc('FILEMAKER�X�N���v�g���s','{=?}SCRIPT��',7351,fmDoScript,'FileMaker�̃X�N���v�g�����s����(�uFILEMAKER�J���v�ŊJ���Ă����K�v������܂�)','FILEMAKER������ՂƂ�������');
  AddFunc('FILEMAKER�I��','',7352,fmQuit,'FileMaker���I��������','FILEMAKER���イ��傤');
  AddFunc('FILEMAKER�t�@�C������','',7353,fmCloseDoc,'FileMaker�̃h�L�������g�����','FILEMAKER�ӂ�����Ƃ���');
  AddFunc('FILEMAKER���p','',7354,fmOpen2,'�N������FileMaker�𑀍�ł���悤�ɏ�������','FILEMAKER��悤');
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
  FMApp := Null;
  FMDocs := Null;
  FMFile := Null;
end;

function PluginFin: DWORD; stdcall;
begin
  Result := 0;
  if not VarIsNull(FMApp) then
  begin
    FMFile := Unassigned;
    FMDocs := Unassigned;
    FMApp := Unassigned;
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

