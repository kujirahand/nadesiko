unit frmErrorU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

const
  ERRMSG_HEADER = '��ϐ\���󂠂�܂���B' +
    '���L�̃G���[�����o����܂����B'#13#10+
    '���m�F�����肢���܂��B'#13#10+
    '-------------------------------'#13#10;

type
  TfrmError = class(TForm)
    panelBase: TPanel;
    panelBtn: TPanel;
    btnDebug: TButton;
    btnContinue: TButton;
    btnClose: TButton;
    btnOteage: TButton;
    edtMain: TMemo;
    procedure panelBaseResize(Sender: TObject);
    procedure btnDebugClick(Sender: TObject);
    procedure btnContinueClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnOteageClick(Sender: TObject);
  private
    { Private �錾 }
    procedure WMMousewheel(var Msg: TMessage); message WM_MOUSEWHEEL;
  public
    { Public �錾 }
    FlagEnd: Boolean;
  end;

var
  FfrmError: TfrmError = nil;

function frmError: TfrmError;

implementation

uses frmDebugU, dnako_import, frmNakoU, StrUnit, gui_benri, unit_string,
  dll_plugin_helper, dnako_import_types, nadesiko_version;

function frmError: TfrmError;
begin
  if FfrmError = nil then FfrmError := TfrmError.Create(frmNako);
  Result := FfrmError;
end;

{$R *.dfm}

procedure TfrmError.panelBaseResize(Sender: TObject);
begin
  panelBtn.Left := panelBase.Width - panelBtn.Width;
end;

procedure TfrmError.btnDebugClick(Sender: TObject);
begin
  frmDebug(Self).Show;
  Close;
end;

procedure TfrmError.btnContinueClick(Sender: TObject);
begin
  nako_continue;
  Close;  
end;

procedure TfrmError.btnCloseClick(Sender: TObject);
begin
  FlagEnd := True;
  //Close;
  Halt;
end;

procedure TfrmError.FormShow(Sender: TObject);
var
  v: PHiValue;
  allow: Boolean;
begin
  FlagEnd := False;
  v := nako_getVariable('�G���[�_�C�A���O�\������');
  allow := hi_bool(v);
  btnDebug.Visible := allow;
  btnOteage.Visible := allow;
  // �o�[�W��������\��
  edtMain.Text :=
    '[�Ȃł���(vnako)] ver.' + NADESIKO_VER + #13#10 +
    edtMain.Text + #13#10;
end;

procedure TfrmError.WMMousewheel(var Msg: TMessage);
begin
  if (Msg.WParam > 0) then
  begin
    { �z�C�[�������ɓ����������̏��� }
    Sendmessage(edtMain.Handle, WM_VSCROLL, SB_LINEUP, 0);
  end
  else
  begin
    { �z�C�[������O�ɓ����������̏��� }
    Sendmessage(edtMain.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
  end;
end;

// ����グ..�Ȃ̂ŁA�G���[���b�Z�[�W���O�O��
procedure TfrmError.btnOteageClick(Sender: TObject);
var
  url, key, s: string;
begin
  btnOteage.Enabled := False;
  try
    btnOteage.Caption := '�N����';
    s := edtMain.Lines.Text;
    GetToken('�w', s);
    key := Trim(GetToken('�x', s));
    if key = '' then key := edtMain.Lines.Text;
    key := key + ' �Ȃł���';
    key := UTF8Encode(key);
    key := URLEncode(key);
    url := 'http://www.google.co.jp/search?q='+key+'&lr=lang_ja&ie=utf-8&oe=utf-8';
    OpenApp(url);
  finally
    sleep(1000);
    btnOteage.Caption := '����グ';
    btnOteage.Enabled := True;
  end;
end;

end.
