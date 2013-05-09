unit frmListU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmList = class(TForm)
    TopPanel: TPanel;
    edtMain: TEdit;
    lstItem: TListBox;
    btnOk: TButton;
    timerFocus: TTimer;
    procedure btnOkClick(Sender: TObject);
    procedure lstItemDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lstItemKeyPress(Sender: TObject; var Key: Char);
    procedure edtMainKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure lstItemKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtMainChange(Sender: TObject);
    procedure TopPanelResize(Sender: TObject);
    procedure timerFocusTimer(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
    Res:String;
    DefList:TStringList;
  end;

var
  frmList: TfrmList;

implementation

{$R *.dfm}

procedure TfrmList.btnOkClick(Sender: TObject);
begin
  Res := edtMain.Text;
  Self.Close;
end;

procedure TfrmList.lstItemDblClick(Sender: TObject);
begin
  if lstItem.ItemIndex < 0 then Exit;
  edtMain.Text := lstItem.Items.Strings[lstItem.ItemIndex];
  btnOkClick(nil);
end;

procedure TfrmList.FormCreate(Sender: TObject);
begin
  DefList := TStringList.Create;
end;

procedure TfrmList.FormDestroy(Sender: TObject);
begin
  FreeAndNil(DefList);
end;

procedure TfrmList.lstItemKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    if lstItem.ItemIndex >= 0 then
    begin
      edtMain.Text := lstItem.Items.Strings[lstItem.ItemIndex];
      btnOk.Click;
    end else
      edtMain.SetFocus;
  end;
  if Key = #8 then // bs
  begin
    edtMain.SetFocus;
  end;
end;

procedure TfrmList.edtMainKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 40)or(Key = 13) then // down
  begin
    lstItem.SetFocus;
    if lstItem.ItemIndex < 0 then
    begin
      lstitem.ItemIndex := 0;
    end;
    if lstItem.Items.Count = 1 then
    begin
      edtMain.Text := lstItem.Items.Strings[0];
    end;
  end
  else if
    (Ord('a') <= Key)and(Key <= Ord('z')) or
    (Ord('A') <= Key)and(Key <= Ord('Z')) or
    (Key = 8)
  then
  begin
  end
  else if Key = 27 then
  begin
    Self.Close;
  end;
end;

procedure TfrmList.FormShow(Sender: TObject);
begin
  timerFocus.Enabled := True;
end;

procedure TfrmList.lstItemKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 38)and(lstItem.ItemIndex <= 0) then
  begin
    edtMain.SetFocus;
  end;
  if (Ord('A') <= Key)and(Key <= Ord('Z')) then
  begin
    edtMain.SetFocus;
  end;
end;

procedure TfrmList.edtMainChange(Sender: TObject);
var
  i, j: Integer;
  s: string;
begin
  // ÉäÉXÉgÇçiÇËçûÇﬁ
  if edtMain.Text = '' then
  begin
    lstItem.Items.Text := DefList.Text;
    Exit;
  end;
  lstItem.Clear;
  for i := 0 to DefList.Count - 1 do
  begin
    s := DefList.Strings[i];
    j := Pos(Trim(edtMain.Text), s);
    if j > 0 then
      lstItem.Items.Add(s);
  end;
  if lstItem.Items.Count > 0 then
  begin
    lstItem.ItemIndex := 0;
  end;

end;

procedure TfrmList.TopPanelResize(Sender: TObject);
begin
  edtMain.Width := TopPanel.ClientWidth - btnOk.Width - 4 * 3;
  btnOk.Left := edtMain.Width + 4 * 2;
end;

procedure TfrmList.timerFocusTimer(Sender: TObject);
begin
  timerFocus.Enabled := False;
  edtMain.SetFocus;
end;

end.
