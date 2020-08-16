unit frmPasswordU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmPassword = class(TForm)
    edtMain: TEdit;
    lblCaption: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    btnOk: TButton;
    btnClose: TButton;
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure edtMainKeyPress(Sender: TObject; var Key: Char);
    procedure FormResize(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
    Res: Boolean;
  end;

var
  frmPassword: TfrmPassword = nil;

function InputBoxPassword(Parent:TForm; Cap, Msg: string): string;

implementation

{$R *.dfm}

function InputBoxPassword(Parent:TForm; Cap, Msg: string): string;
var
  f: TfrmPassword;
begin
  Result := '';
  f := TfrmPassword.Create(Parent);
  try
    f.Caption := Cap;
    f.lblCaption.Caption := Msg;
    f.ShowModal;
    if f.Res then
    begin
      Result := f.edtMain.Text;
    end;
  finally
    f.Free;
  end;
end;

procedure TfrmPassword.btnOkClick(Sender: TObject);
begin
  Res := True;
  Close;
end;

procedure TfrmPassword.FormCreate(Sender: TObject);
begin
  Res := False;
end;

procedure TfrmPassword.FormShow(Sender: TObject);
begin
  Res := False;
end;

procedure TfrmPassword.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmPassword.edtMainKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    btnOkClick(nil);
  end;
end;

procedure TfrmPassword.FormResize(Sender: TObject);
begin
  panel2.Left := panel1.ClientWidth - panel2.Width + 4;
end;

end.
