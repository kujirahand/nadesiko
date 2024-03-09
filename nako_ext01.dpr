library nako_ext01;

uses
  FastMM4 in 'FastMM4.pas',
  Windows, SysUtils, Classes,
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',

  Graphics,
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  unit_string2 in 'hi_unit\unit_string2.pas',
  frmWebDialogU in 'pro_unit\ext01\frmWebDialogU.pas',
  frmImageDialogU in 'pro_unit\ext01\frmImageDialogU.pas' {frmImageDialog},
  GldPng in 'component\gldpng\gldpng.pas';

// path ��ǉ����邱��

//------------------------------------------------------------------------------
// �ȉ��֐�
//------------------------------------------------------------------------------

function nako_dlg_web(h: DWORD): PHiValue; stdcall;
var
  f: TfrmWebDialog;
  url: string;
begin
  Result := nil;
  url := getArgStr(h, 0, True);
  f := TfrmWebDialog.Create(nil);
  try
    try
      f.browser.Navigate(url);
    except
      try
        Sleep(500);
        f.browser.Navigate(url);
      except
        f.browser.Navigate('about:blank');
      end;
    end;
    f.ShowModal;
  finally
    FreeAndNil(f);
  end;
end;

function nako_dlg_img(h: DWORD): PHiValue; stdcall;
var
  fn: string;
  f: TfrmImageDialog;
begin
  Result := nil;
  fn := getArgStr(h, 0, True);
  f := TfrmImageDialog.Create(nil);
  try
    f.img.Picture.LoadFromFile(fn);
    f.img.Repaint;
    f.ShowModal;
  finally
    f.Free;
  end;
end;


//------------------------------------------------------------------------------
// �ȉ���΂ɕK�v�Ȋ֐�
//------------------------------------------------------------------------------
// �֐��ǉ��p
procedure ImportNakoFunction; stdcall;
begin
  // �Ȃł����V�X�e���Ɋ֐���ǉ�
  // nako_ext01.dll,6570-6599
  // <����>
  //+�����g���p�b�N[�����������p�b�N�̂�](nako_qrcode.dll)
  //-�_�C�A���O
  AddFunc('WEB�_�C�A���O�\��', 'URL��', 6590, nako_dlg_web, '�ȈՃu���E�U�̃_�C�A���O��\����URL��\������B', 'WEB�������낮�Ђ傤��');
  AddFunc('�摜�_�C�A���O�\��', 'FILE��', 6591, nako_dlg_img, '�摜��\������_�C�A���O��\�����A�摜�t�@�C��FILE��\������B', 'WEB�������낮�Ђ傤��');
  // </����>
end;

//------------------------------------------------------------------------------
// �v���O�C���̏��
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
const STR_INFO = 'ext01�R�[�h�v���O�C�� by �N�W����s��';
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
