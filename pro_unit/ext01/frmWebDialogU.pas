unit frmWebDialogU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, StdCtrls, ExtCtrls;

type
  TfrmWebDialog = class(TForm)
    browser: TWebBrowser;
    pnl: TPanel;
    btnOK: TButton;
    procedure pnlResize(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure browserDocumentComplete(ASender: TObject; const pDisp: IDispatch;
      var URL: OleVariant);
    procedure browserBeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
      var URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
      var Cancel: WordBool);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  frmWebDialog: TfrmWebDialog;

implementation

{$R *.dfm}

procedure TfrmWebDialog.browserBeforeNavigate2(ASender: TObject;
  const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
begin
  Caption := '* ì«Ç›çûÇ›íÜ - è≠ÅXÇ®ë“ÇøÇ≠ÇæÇ≥Ç¢ÅB';
  btnOK.Enabled := False;
end;

procedure TfrmWebDialog.browserDocumentComplete(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
begin
  Caption := browser.OleObject.Document.Title;
  btnOK.Enabled := True;
end;

procedure TfrmWebDialog.btnOKClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmWebDialog.pnlResize(Sender: TObject);
begin
  btnOK.Left := pnl.ClientWidth - btnOK.Width - 10;
end;

end.
