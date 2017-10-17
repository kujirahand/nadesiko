unit frmSayU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, clipbrd, Menus;

type
  TfrmSay = class(TForm)
    panelBottom: TPanel;
    btnOK: TButton;
    btnMore: TButton;
    popSay: TPopupMenu;
    mnuCopy: TMenuItem;
    popToMemo: TMenuItem;
    N1: TMenuItem;
    popCancel: TMenuItem;
    btnNg: TButton;
    timerLimit: TTimer;
    procedure btnNgClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure btnMoreClick(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure mnuCopyClick(Sender: TObject);
    procedure popToMemoClick(Sender: TObject);
    procedure popCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure timerLimitTimer(Sender: TObject);
  private
    FIsNitaku: Boolean;
    FRemainTime: Integer;
    FTitle: string;
    FMemo: string;
    procedure SetText(const Value: string);
    { Private 宣言 }
  public
    { Public 宣言 }
    Res: Boolean;
    FBmp: TBitmap;
    procedure UseNitaku;
    procedure SetProperty(s: string);
    procedure SetLimitTime(n: Integer);
  end;

implementation

uses vnako_function, frmMemoU, unit_string, frmNakoU, dnako_import,
  hima_types, dnako_import_types, StrUnit;

{$R *.dfm}

procedure TfrmSay.btnNgClick(Sender: TObject);
begin
  Res := False;
  Close;
end;

procedure TfrmSay.SetText(const Value: string);
var
  i, ww, hh, mw, w, h, x, y, len: Integer;
  str: AnsiString;
  ss: TStringList;
const
  MAXLEN = 80 * 12;
begin
  FMemo := Value;
  str   := AnsiString(FMemo);

  // 表示用に文字数オーバーなら切捨て
  len := Length(Value);
  btnMore.Visible := (len > MAXLEN);
  if btnMore.Visible then
  begin
    str := sjis_copyByte(PAnsiChar(str), MAXLEN);
  end;
  // タブを展開
  str := ExpandTab(str, hi_int(nako_getVariable('タブ数')));
  // いくらなんでも120桁で区切る
  str := CutLine(str, 120, 4, '');
  //
  ss := TStringList.Create;
  ss.Text := string(str);
  if ss.Count > 20 then
  begin
    btnMore.Visible := True;
  end;

  // 描画設定を得る
  // getFont(FBmp.Canvas);
  with FBmp.Canvas do
  begin
    // Font.Color := clBtnText;
    // Font.Size  := 10;

    mw := 0;
    for i := 0 to ss.Count - 1 do
    begin
      w := TextWidth(ss.Strings[i]);
      if w > mw then mw := w;
    end;
    w := mw;
    h := TextHeight('A') * ss.Count ;
    ww := w + 8 * 2;
    hh := h + 8 * 2;
    // サイズ補正
    if ww < 128 then ww := 128;
    if hh < 38  then hh := 38;
    if ww > Screen.Width  then ww := Trunc(Screen.Width  * 0.7);
    if hh > Screen.Height then hh := Trunc(Screen.Height * 0.7);
    // フォームサイズ変更
    self.ClientWidth  := ww ;
    self.ClientHeight := hh + panelBottom.Height ;
    // フォーム位置変更
    if ww > frmNako.Width then
    begin // メインフォームより大きい
      self.Left := (Screen.Width - ww) div 2;
    end else
    begin
      self.Left := frmNako.Left + (frmNako.Width - ww) div 2;
    end;
    if hh > frmNako.Height then
    begin
      self.Top := (Screen.Height - hh) div 2;
    end else
    begin
      self.Top := frmNako.Top + (frmNako.Height - hh) div 2;
    end;

    FBmp.Width   := ww;
    FBmp.Height  := hh;

    Pen.Color   := clBtnFace;
    Brush.Color := clBtnFace;
    Brush.Style := bsSolid;
    Rectangle(0,0,ClientWidth,ClientHeight);

    x := (ww-w) div 2;
    y := (hh-h) div 2; if y < 0 then y := 0;

    for i := 0 to ss.Count - 1 do
    begin
      TextOut(x, y + i * TextHeight('A'), ss.Strings[i]);
    end;
  end;
  ss.Free;

  // 二択用か？
  if FIsNitaku then
  begin
    ww := btnOk.Width + btnNg.Width + 4;
    if ww > panelBottom.ClientWidth then
    begin
      Self.Width := ww + 8;
    end;
    btnOk.Left := (panelBottom.ClientWidth - ww) div 2;
    btnNg.Visible := True;
    btnNg.Left := btnOk.Left + btnOk.Width + 4;
    btnOk.Caption := 'はい(&Y)';
    btnNG.Caption := 'いいえ(&N)';
  end else
  begin
    btnOk.Left := (panelBottom.ClientWidth - btnOk.Width) div 2;
    btnNg.Visible := False;
  end;
  //
  btnMore.Left := self.ClientWidth - btnMore.Width - 4;
  btnMore.Top := self.ClientHeight - btnMore.Height - 4 - panelBottom.Height;
end;

procedure TfrmSay.FormCreate(Sender: TObject);
begin
  {$IFDEF IS_LIBVNAKO}
  Self.Caption := 'なでしこ';
  {$ELSE}
  Self.Caption := Application.Title;
  {$ENDIF}
  FBmp := TBitmap.Create;
  FMemo := '';
  FIsNitaku := False;
  Res := False;
end;

procedure TfrmSay.FormDestroy(Sender: TObject);
begin
  FBmp.Free;
end;

procedure TfrmSay.SetProperty(s: string);
begin
  FMemo := s;
  SetText(FMemo);
end;

procedure TfrmSay.FormPaint(Sender: TObject);
begin
  if FMemo <> '' then Canvas.Draw(0,0,FBmp);
end;

procedure TfrmSay.btnMoreClick(Sender: TObject);
var
  f: TfrmMemo;
begin
  f := TfrmMemo.Create(self);
  f.edtMain.Lines.Text := FMemo;
  ShowModalCheck(f, self);
  f.Free;
end;

procedure TfrmSay.FormDblClick(Sender: TObject);
begin
  //
  btnMoreClick(nil);
end;

procedure TfrmSay.mnuCopyClick(Sender: TObject);
begin
  Clipboard.AsText := FMemo;
  Beep;
end;

procedure TfrmSay.popToMemoClick(Sender: TObject);
begin
  btnMoreClick(nil);
end;

procedure TfrmSay.popCancelClick(Sender: TObject);
begin
  ShowWindow(popSay.Handle, SW_HIDE);
end;

procedure TfrmSay.btnOKClick(Sender: TObject);
begin
  Res := True;
  Close;
end;

procedure TfrmSay.UseNitaku;
begin
  FIsNitaku := True;
end;

procedure TfrmSay.SetLimitTime(n: Integer);
begin
  if n <= 0 then
  begin
    timerLimit.Enabled := False;
  end else
  begin
    FRemainTime := n;
    timerLimit.Enabled := True;
    FTitle := Caption;
  end;
end;

procedure TfrmSay.timerLimitTimer(Sender: TObject);
begin
  timerLimit.Enabled := False;
  Dec(FRemainTime, 1000);
  if (FRemainTime <= 0) then
  begin
    Close;
  end else
  begin
    Caption := 'あと' + IntToStr(Trunc(FRemainTime/1000)) + '秒-' + FTitle;
    timerLimit.Enabled := True;
  end;
end;

end.
