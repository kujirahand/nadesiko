unit frmReplaceU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, clipbrd;

type
  TfrmReplace = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    cmbFind: TComboBox;
    cmbReplace: TComboBox;
    btnFind: TButton;
    btnReplace: TButton;
    btnReplaceAll: TButton;
    chkSelection: TCheckBox;
    btnCancel: TButton;
    PopupMenu1: TPopupMenu;
    popCopy: TMenuItem;
    popPaste: TMenuItem;
    popCut: TMenuItem;
    procedure btnFindClick(Sender: TObject);
    procedure btnReplaceClick(Sender: TObject);
    procedure btnReplaceAllClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure popCopyClick(Sender: TObject);
    procedure popCutClick(Sender: TObject);
    procedure popPasteClick(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
    procedure MemoryField;
  end;

var
  FfrmReplace: TfrmReplace = nil;

function frmReplace: TfrmReplace;

implementation

uses frmNakopadU, unit_string2;

{$R *.dfm}

function frmReplace: TfrmReplace;
begin
  if FfrmReplace = nil then
  begin
    FfrmReplace := TfrmReplace.Create(frmNakopad);
  end;
  Result := FfrmReplace;
end;

procedure TfrmReplace.btnFindClick(Sender: TObject);
begin
  MemoryField;
  frmNakopad.FFindKey := cmbFind.Text;
  frmNakopad.mnuFindNextClick(nil);
end;

procedure TfrmReplace.btnReplaceClick(Sender: TObject);
var
  s: string;
begin
  MemoryField;
  s := cmbFind.Text;
  if frmNakopad.edtActive.SelText = s then
  begin
    frmNakopad.edtActive.SelText := cmbReplace.Text;
  end else
  begin
    btnFindClick(nil); // FIND
    if frmNakopad.edtActive.SelText = s then
    begin
      frmNakopad.edtActive.SelText := cmbReplace.Text;
    end;
  end;
end;

procedure TfrmReplace.btnReplaceAllClick(Sender: TObject);
var
  s: string;
begin
  MemoryField;
  if chkSelection.Checked then
  begin
    s := frmNakopad.edtActive.SelText;
    s := JReplace(s, cmbFind.Text, cmbReplace.Text);
    frmNakopad.edtActive.SelText := s;
  end else
  begin
    s := frmNakopad.edtActive.Lines.Text;
    s := JReplace(s, cmbFind.Text, cmbReplace.Text);
    frmNakopad.edtActive.Lines.Text := s;
  end;
end;

procedure TfrmReplace.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmReplace.popCopyClick(Sender: TObject);
var
  o: TObject;
begin
  o := frmReplace.ActiveControl;
  if o = nil then Exit;
  if o is TComboBox then
  begin
    Clipboard.AsText := TComboBox(o).SelText;
  end;
end;

procedure TfrmReplace.popCutClick(Sender: TObject);
var
  o: TObject;
begin
  o := frmReplace.ActiveControl;
  if o = nil then Exit;
  if o is TComboBox then
  begin
    Clipboard.AsText := TComboBox(o).SelText;
    TComboBox(o).SelText := '';
  end;
end;

procedure TfrmReplace.popPasteClick(Sender: TObject);
var
  o: TObject;
begin
  o := frmReplace.ActiveControl;
  if o = nil then Exit;
  if o is TComboBox then
  begin
    TComboBox(o).SelText := Clipboard.AsText;
  end;
end;

procedure TfrmReplace.MemoryField;
var
  s: string;
begin
  if cmbFind.Text <> '' then
  begin
    s := cmbFind.Text;
    if cmbFind.Items.IndexOf(s) < 0 then
    begin
      cmbFind.Items.Insert(0, s);
    end;
  end;
  if cmbReplace.Text <> '' then
  begin
    s := cmbReplace.Text;
    if cmbReplace.Items.IndexOf(s) < 0 then
    begin
      cmbReplace.Items.Insert(0, s);
    end;
  end;
end;

end.
