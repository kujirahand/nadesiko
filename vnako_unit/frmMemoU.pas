unit frmMemoU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus, ComCtrls, Clipbrd, HEditor,
  hOleddEditor, EditorEx;

type
  TfrmMemo = class(TForm)
    dlgSave: TSaveDialog;
    dlgOpen: TOpenDialog;
    Status: TStatusBar;
    MainMenu1: TMainMenu;
    mnuFile: TMenuItem;
    mnuOpen: TMenuItem;
    mnuSave: TMenuItem;
    E1: TMenuItem;
    mnuUndo: TMenuItem;
    N1: TMenuItem;
    mnuCut: TMenuItem;
    mnuCopy: TMenuItem;
    mnuPaste: TMenuItem;
    mnuSelAll: TMenuItem;
    panelBase: TPanel;
    F1: TMenuItem;
    mnuFont: TMenuItem;
    dlgFont: TFontDialog;
    panelBtn: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    N2: TMenuItem;
    mnuCountLen: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    mnuClose: TMenuItem;
    popEdit: TPopupMenu;
    popCut: TMenuItem;
    popCopy: TMenuItem;
    popPaste: TMenuItem;
    N6: TMenuItem;
    popSelAll: TMenuItem;
    mnuPasteQuote: TMenuItem;
    N7: TMenuItem;
    mnuFind: TMenuItem;
    dlgFind: TFindDialog;
    edtMain: TEditorEx;
    mnuOrikaesi: TMenuItem;
    N9: TMenuItem;
    mnuOpenApp: TMenuItem;
    Label1: TLabel;
    edtFind: TEdit;
    btnFindNext: TButton;
    btnFindPrev: TButton;
    mnuFindNext: TMenuItem;
    N8: TMenuItem;
    F2: TMenuItem;
    H1: TMenuItem;
    mnuFindGoole: TMenuItem;
    mnuAbout: TMenuItem;
    N10: TMenuItem;
    mnuAlwaysTop: TMenuItem;
    N3: TMenuItem;
    mnuReplace: TMenuItem;
    dlgReplace: TReplaceDialog;
    procedure mnuOpenClick(Sender: TObject);
    procedure mnuSaveClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure mnuUndoClick(Sender: TObject);
    procedure mnuCutClick(Sender: TObject);
    procedure mnuCopyClick(Sender: TObject);
    procedure mnuPasteClick(Sender: TObject);
    procedure mnuSelAllClick(Sender: TObject);
    procedure mnuFontClick(Sender: TObject);
    procedure panelBaseResize(Sender: TObject);
    procedure mnuCountLenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mnuCloseClick(Sender: TObject);
    procedure mnuPasteQuoteClick(Sender: TObject);
    procedure mnuFindClick(Sender: TObject);
    procedure dlgFindFind(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure mnuOrikaesiClick(Sender: TObject);
    procedure edtMainMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure edtMainDblClick(Sender: TObject);
    procedure mnuOpenAppClick(Sender: TObject);
    procedure btnFindNextClick(Sender: TObject);
    procedure btnFindPrevClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mnuFindNextClick(Sender: TObject);
    procedure mnuFindGooleClick(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure edtFindKeyPress(Sender: TObject; var Key: Char);
    procedure mnuAlwaysTopClick(Sender: TObject);
    procedure dlgReplaceReplace(Sender: TObject);
    procedure mnuReplaceClick(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
    Res: Boolean;
  end;

var
  frmMemo: TfrmMemo;

implementation

uses unit_string, gui_benri, unit_base64, frmPasswordU,
  dnako_import, dnako_import_types;

{$R *.dfm}

procedure TfrmMemo.mnuOpenClick(Sender: TObject);
begin
  if not dlgOpen.Execute then Exit;
  edtMain.Lines.LoadFromFile(dlgOpen.FileName);
end;

procedure TfrmMemo.mnuSaveClick(Sender: TObject);
begin
  if not dlgSave.Execute then Exit;
  edtMain.Lines.SaveToFile(dlgSave.FileName);
end;

procedure TfrmMemo.btnOKClick(Sender: TObject);
begin
  Res := True;
  Close;
end;

procedure TfrmMemo.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMemo.mnuUndoClick(Sender: TObject);
begin
  if Self.ActiveControl = edtFind then
  begin
    edtFind.Undo;
  end else
  begin
    edtMain.Undo;
  end;
end;

procedure TfrmMemo.mnuCutClick(Sender: TObject);
begin
  if Self.ActiveControl = edtFind then
  begin
    edtFind.CutToClipboard;
  end else
  begin
    edtMain.CutToClipboard;
  end;
end;

procedure TfrmMemo.mnuCopyClick(Sender: TObject);
begin
  if Self.ActiveControl = edtFind then
  begin
    edtFind.CopyToClipboard;
  end else
  begin
    edtMain.CopyToClipboard;
  end;
end;

procedure TfrmMemo.mnuPasteClick(Sender: TObject);
begin
  if Self.ActiveControl = edtFind then
  begin
    edtFind.PasteFromClipboard;
  end else
  begin
    edtMain.PasteFromClipboard;
  end;
end;

procedure TfrmMemo.mnuSelAllClick(Sender: TObject);
begin
  if Self.ActiveControl = edtFind then
  begin
    edtFind.SelectAll;
  end else
  begin
    edtMain.SelectAll;
  end;
end;

procedure TfrmMemo.mnuFontClick(Sender: TObject);
begin
  dlgFont.Font := edtMain.Font;
  if not dlgFont.Execute then Exit;
  edtMain.Font := dlgFont.Font;
end;

procedure TfrmMemo.panelBaseResize(Sender: TObject);
begin
  panelBtn.Left := panelBase.Width - panelBtn.Width;
end;

procedure TfrmMemo.mnuCountLenClick(Sender: TObject);
var
  lenB, lenM, slenB, slenM: Integer;
  s: string;
begin
  s := edtMain.Lines.Text;
  lenB := Length(s);
  lenM := JLength(s);
  //
  s := edtMain.SelText;
  slenB := Length(s);
  slenM := JLength(s);
  //
  Status.SimpleText := Format('■総文字数:%d文字(%dB) ■選択文字数:%d文字(%dB)',
    [lenM, lenB, slenM, slenB]);
end;

procedure TfrmMemo.FormCreate(Sender: TObject);
begin
  Res := False;
end;

procedure TfrmMemo.mnuCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMemo.mnuPasteQuoteClick(Sender: TObject);
var
  s: TStringList;
  i: Integer;
begin
  s := TStringList.Create;
  s.Text := Clipboard.AsText;
  for i := 0 to s.Count - 1 do
  begin
    s.Strings[i] := '> ' + s.Strings[i];
  end;
  edtMain.SelText := s.Text;
  s.Free;
end;

procedure TfrmMemo.mnuFindClick(Sender: TObject);
begin
  //if not dlgFind.Execute then Exit;
  edtFind.SetFocus;
end;

procedure TfrmMemo.dlgFindFind(Sender: TObject);
begin
  edtMain.SetFocus;

  if Sender is TReplaceDialog then
  begin
    edtMain.FindString := dlgReplace.FindText;
  end else
  begin
    edtMain.FindString := dlgFind.FindText;
  end;
  if not edtMain.FindNext then
  begin
    edtMain.SelStart := 0;
    if not edtMain.FindNext then
    begin
      ShowMessage('見つかりませんでした。');
    end;
  end;
end;

procedure TfrmMemo.N8Click(Sender: TObject);
begin
  dlgFindFind(nil);
end;

procedure TfrmMemo.mnuOrikaesiClick(Sender: TObject);
begin
  mnuOrikaesi.Checked := not mnuOrikaesi.Checked;
  edtMain.WordWrap := mnuOrikaesi.Checked;
  edtMain.WrapOption.WrapByte := 72;
end;

procedure TfrmMemo.edtMainMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if (WheelDelta > 0) then
  begin
    { ホイールを奥に動かした時の処理 }
    Sendmessage(edtMain.Handle, WM_VSCROLL, SB_LINEUP, 0);
  end
  else
  begin
    { ホイールを手前に動かした時の処理 }
    Sendmessage(edtMain.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
  end;
end;

procedure TfrmMemo.edtMainDblClick(Sender: TObject);
begin
  edtMain.SelectWordFromCaret;
end;

procedure TfrmMemo.mnuOpenAppClick(Sender: TObject);
var
  s: string;
begin
  if edtMain.SelText = '' then
  begin
    s := InputBox('関連付け','実行したいファイル名(URL)を入力してください。','');
    if s = '' then Exit;
    OpenApp(s);
  end else
  begin
    OpenApp(edtMain.SelText);
  end;
end;

procedure TfrmMemo.btnFindNextClick(Sender: TObject);
var
  bRes: Boolean;
begin
  edtMain.SetFocus;

  edtMain.FindString := edtFind.Text;
  bRes := edtMain.FindNext;
  if bRes = False then
  begin
    edtMain.SelStart := 0;
    bRes := edtMain.FindNext;
  end;

  if bRes then
  begin
    edtFind.Color := clWindow;
  end else
  begin
    edtFind.Color := RGB(255,200,200);
  end;

  edtFind.SetFocus;
end;

procedure TfrmMemo.btnFindPrevClick(Sender: TObject);
var
  bRes: Boolean;
begin
  edtMain.SetFocus;

  edtMain.FindString := edtFind.Text;
  bRes := edtMain.FindPrev;
  if not bRes then
  begin
    edtMain.SelStart := Length(edtMain.Lines.Text) - 1;
    bRes := edtMain.FindPrev;
  end;

  if bRes then
  begin
    edtFind.Color := clWindow;
  end else
  begin
    edtFind.Color := RGB(255,200,200);
  end;

  edtFind.SetFocus;
end;

procedure TfrmMemo.FormShow(Sender: TObject);
begin
  // 作業フォルダを得る
  dlgSave.InitialDir := GetCurrentDir;
  dlgOpen.InitialDir := GetCurrentDir;
  edtMain.SetFocus;
end;

procedure TfrmMemo.mnuFindNextClick(Sender: TObject);
begin
  btnFindNextClick(nil);
end;

procedure TfrmMemo.mnuFindGooleClick(Sender: TObject);
begin
  if edtMain.SelLength = 0 then
  begin
    edtMain.SelectWordFromCaret;
  end;
  OpenApp(
    'http://www.google.co.jp/search?start=0&hl=ja&lr=lang_ja&ie=shift_jis&q=' +
    edtMain.SelText
  );
end;

procedure TfrmMemo.mnuAboutClick(Sender: TObject);
begin
  ShowMessage(
    '[簡易メモ帳]'+#13#10+
    '好きな内容を書き込んで[決定]ボタンを押してください。');
end;

procedure TfrmMemo.edtFindKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    btnFindNextClick(nil);
  end;
end;

procedure TfrmMemo.mnuAlwaysTopClick(Sender: TObject);
begin
  mnuAlwaysTop.Checked := not mnuAlwaysTop.Checked;
  if mnuAlwaysTop.Checked then
  begin
    Self.FormStyle := fsStayOnTop;
  end else
  begin
    Self.FormStyle := fsNormal;
  end;
end;

procedure TfrmMemo.dlgReplaceReplace(Sender: TObject);
begin
  edtMain.SetFocus;
  edtMain.FindString := dlgReplace.FindText;
  
  if frReplaceAll in dlgReplace.Options then
  begin
    edtMain.ReplaceAll(dlgReplace.ReplaceText, True);
    Exit;
  end;

  if edtMain.SelText <> '' then
  begin
    edtMain.SelText := dlgReplace.ReplaceText;
  end;

  if not edtMain.FindNext then
  begin
    edtMain.SelStart := 0;
    if not edtMain.FindNext then
    begin
      ShowMessage('見つかりませんでした。');
    end;
  end;
end;

procedure TfrmMemo.mnuReplaceClick(Sender: TObject);
begin
  if not dlgReplace.Execute then Exit;
end;

end.
