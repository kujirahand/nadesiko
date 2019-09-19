unit frmImageDialogU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, jpeg, gldpng;

type
  TfrmImageDialog = class(TForm)
    img: TImage;
    pnl: TPanel;
    btnOK: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure pnlResize(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  frmImageDialog: TfrmImageDialog;

implementation

{$R *.dfm}

procedure TfrmImageDialog.btnOKClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmImageDialog.pnlResize(Sender: TObject);
begin
  btnOK.Left := pnl.ClientWidth - btnOK.Width - 10;
end;

end.
