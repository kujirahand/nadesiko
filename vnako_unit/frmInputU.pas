unit frmInputU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmInput = class(TForm)
    lblCaption: TLabel;
    edtMain: TEdit;
    Panel1: TPanel;
    Panel2: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    timerLimit: TTimer;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtMainKeyPress(Sender: TObject; var Key: Char);
    procedure FormResize(Sender: TObject);
    procedure timerLimitTimer(Sender: TObject);
  private
    { Private êÈåæ }
    FTitle: string;
    FLimit: Integer;
  public
    { Public êÈåæ }
    res: Boolean;
    procedure setLimitTimer(n:Integer);
  end;

var
  frmInput: TfrmInput;

implementation

{$R *.dfm}

procedure TfrmInput.btnOKClick(Sender: TObject);
begin
  res := True;
  Close;
end;

procedure TfrmInput.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmInput.FormCreate(Sender: TObject);
begin
  res := False;
end;

procedure TfrmInput.edtMainKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    btnOKClick(nil);
  end else
  if Key = #27 then
  begin
    btnCancelClick(nil);
  end;
end;

procedure TfrmInput.FormResize(Sender: TObject);
begin
  panel2.Left := panel1.ClientWidth - panel2.Width + 4;
end;

procedure TfrmInput.timerLimitTimer(Sender: TObject);
begin
  timerLimit.Enabled := False;
  Dec(FLimit, 1000);
  if FLimit <= 0 then
  begin
    Close;
    Exit;
  end;
  Caption := 'Ç†Ç∆' + IntToStr(Trunc(FLimit/1000)) + 'ïb-' + FTitle;
  timerLimit.Enabled := True;
end;

procedure TfrmInput.setLimitTimer(n: Integer);
begin
  FTitle := Caption;
  timerLimit.Enabled := (n > 0);
  FLimit := n;
end;

end.
