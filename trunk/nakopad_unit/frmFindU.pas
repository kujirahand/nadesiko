unit frmFindU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, clipbrd;

type
  TfrmFind = class(TForm)
    Label1: TLabel;
    cmbFind: TComboBox;
    btnFind: TButton;
    btnClose: TButton;
    popupFind: TPopupMenu;
    popCopy: TMenuItem;
    popPaste: TMenuItem;
    popCut: TMenuItem;
    procedure btnCloseClick(Sender: TObject);
    procedure btnFindClick(Sender: TObject);
    procedure cmbFindKeyPress(Sender: TObject; var Key: Char);
    procedure popCopyClick(Sender: TObject);
    procedure popCutClick(Sender: TObject);
    procedure popPasteClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  FfrmFind: TfrmFind = nil;

function frmFind: TfrmFind;

implementation

uses frmNakopadU;

{$R *.dfm}

function frmFind: TfrmFind;
begin
  if FfrmFind = nil then
  begin
    FfrmFind := TfrmFind.Create(frmNakopad);
  end;
  Result := FfrmFind;
end;


procedure TfrmFind.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmFind.btnFindClick(Sender: TObject);
var
  key: string;
begin
  key := cmbFind.Text;
  if cmbFind.Items.IndexOf(key) < 0 then
  begin
    cmbFind.Items.Add(key);
  end;
  frmNakopad.FFindKey := key;
  frmNakopad.mnuFindNextClick(nil);
end;

procedure TfrmFind.cmbFindKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    btnFindClick(nil);
  end;
end;

procedure TfrmFind.popCopyClick(Sender: TObject);
begin
  Clipboard.AsText := cmbFind.SelText;
end;

procedure TfrmFind.popCutClick(Sender: TObject);
begin
  Clipboard.AsText := cmbFind.SelText;
  cmbFind.SelText := '';
end;

procedure TfrmFind.popPasteClick(Sender: TObject);
begin
  cmbFind.SelText := Clipboard.AsText;
end;

procedure TfrmFind.FormShow(Sender: TObject);
begin
  cmbFind.SetFocus;
end;

end.
