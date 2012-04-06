unit frmInputListU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ValEdit, ExtCtrls, FileCtrl, Menus,
  Clipbrd;

type
  TfrmInputList = class(TForm)
    panelBase: TPanel;
    veList: TValueListEditor;
    panelBtn: TPanel;
    btnOk: TButton;
    btnClose: TButton;
    dlgOpen: TOpenDialog;
    dlgColor: TColorDialog;
    MainMenu1: TMainMenu;
    F1: TMenuItem;
    mnuOpen: TMenuItem;
    mnuSave: TMenuItem;
    N1: TMenuItem;
    dlgSave: TSaveDialog;
    N2: TMenuItem;
    C1: TMenuItem;
    mnuReset: TMenuItem;
    N3: TMenuItem;
    mnuCopyAsText: TMenuItem;
    procedure panelBaseResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure veListEditButtonClick(Sender: TObject);
    procedure veListDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure veListEnter(Sender: TObject);
    procedure veListExit(Sender: TObject);
    procedure veListKeyPress(Sender: TObject; var Key: Char);
    procedure veListKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure veListMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure veListSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure mnuOpenClick(Sender: TObject);
    procedure mnuSaveClick(Sender: TObject);
    procedure C1Click(Sender: TObject);
    procedure mnuResetClick(Sender: TObject);
    procedure mnuCopyAsTextClick(Sender: TObject);
  private
    { Private 宣言 }
    procedure ChangeIME(ARow: Integer);
  public
    { Public 宣言 }
    kisoku: TStringList;
    Res: Boolean;
    procedure setProperty(s: string);
    function getResult: string;
  end;

var
  frmInputList: TfrmInputList = nil;

implementation

uses StrUnit, vnako_function, mini_file_utils, gui_benri;

{$R *.dfm}

procedure TfrmInputList.ChangeIME(ARow: Integer);
var
  c,str: string;
begin
  if kisoku.Count <= ARow then Exit;

  str := kisoku.Strings[ARow];
  c   := Copy(str,1,1);

  if c = 's' then
  begin
    SetImeMode(veList.Handle, imOpen);
  end else
  if (c='e')or(c='f')or(c='c') then
  begin
    SetImeMode(veList.Handle, imClose);
  end;
end;


procedure TfrmInputList.panelBaseResize(Sender: TObject);
begin
  panelBtn.Left := panelBase.ClientWidth - panelBtn.ClientWidth;
end;

procedure TfrmInputList.FormShow(Sender: TObject);
begin
  // 作業フォルダを得る
  dlgSave.InitialDir := GetCurrentDir;
  dlgOpen.InitialDir := GetCurrentDir;
  // 表示
  Res := False;
  veList.SetFocus;
end;

procedure TfrmInputList.FormCreate(Sender: TObject);
begin
  Res := False;
  kisoku := TStringList.Create;
end;

procedure TfrmInputList.FormDestroy(Sender: TObject);
begin
  FreeAndNil(kisoku);
end;

procedure TfrmInputList.setProperty(s: string);
var
  sl, cmb: TStringList;
  n, v, ss: string;
  i,w,max_w: Integer;

  function __GetToken(var s: string): string;
  var
    p: PChar;
  begin
    Result := '';
    
    p := PChar(s);
    while p^ <> #0 do
    begin
      if p^ in LeadBytes then
      begin
        if StrLComp(p, '＝', 2) = 0 then
        begin
          Inc(p, 2);
          s := string( PChar(p) );
          Break;
        end;
        Result := Result + p^ + (p+1)^;
        Inc(p,2);
      end else
      begin
        if p^ = '=' then
        begin
          Inc(p);
          s := string( PChar(p) );
          Break;
        end;
        Result := Result + p^;
        Inc(p);
      end;
    end;
  end;

begin
  veList.Canvas.Font := veList.Font;
  //veList.Canvas.Font.Size := 10;

  sl := TStringList.Create ;
  try
    // 左列の大きさを計測
    sl.Text := s;
    if Copy(sl.Strings[0],1,1) = ';' then
    begin// 固定行の変更
      v := sl.Strings[0]; sl.Delete(0);
      n := GetToken('=', v);
      System.Delete(n,1,1);
      veList.TitleCaptions.Text := n + #13#10 + v;
      max_w := veList.Canvas.TextWidth(n);
    end else
    begin
      max_w := veList.Canvas.TextWidth('項目');
    end;

    veList.Strings.Clear ;
    kisoku.Clear ;  kisoku.Add(''); //title
    for i := 0 to sl.Count - 1 do
    begin
      // n = v に分解
      v := sl.Strings[i];
      //n := GetToken('=', v);
      n := __GetToken(v); // 全角＝でも動くように修正
      v := Trim(v);
      // 選択肢などのシーケンスチェック
      if (Copy(v,1,2) = '?(') then
      begin
        // 選択肢
        System.Delete(v,1,2);
        ss := GetToken(')', v);
        cmb := SplitChar('|', ss);
        veList.InsertRow(n, v, True); kisoku.Add('');
        veList.ItemProps[i].PickList.AddStrings(cmb);
        veList.ItemProps[i].EditStyle := esPickList ;
        cmb.Free ;
      end else
      if Copy(v,1,2) = '?f' then
      begin
        // ファイル選択
        System.Delete(v,1,2);
        if Copy(v,1,1) = '(' then
        begin
          System.Delete(v,1,1);
          ss := GetToken(')', v);
        end else ss := '';
        veList.InsertRow(n, v, True); kisoku.Add('f' + ss);
        veList.ItemProps[i].EditStyle := esEllipsis;
      end else
      if Copy(v,1,2) = '?d' then
      begin
        // フォルダ選択
        System.Delete(v,1,2);
        if Copy(v,1,1) = '(' then
        begin
          System.Delete(v,1,1);
          ss := GetToken(')', v);
        end else ss := '';
        veList.InsertRow(n, v, True); kisoku.Add('d' + ss);
        veList.ItemProps[i].EditStyle := esEllipsis;
      end else
      if Copy(v,1,2) = '?c' then
      begin
        // 色選択
        System.Delete(v,1,2);
        veList.InsertRow(n, v, True); kisoku.Add('c');
        veList.ItemProps[i].EditStyle := esEllipsis;
      end else
      if Copy(v,1,2) = '?s' then
      begin
        System.Delete(v,1,2);
        veList.InsertRow(n, v, True); kisoku.Add('s');
        veList.ItemProps[i].EditStyle := esSimple ;
      end else
      if Copy(v,1,2) = '?e' then
      begin
        // 色選択
        System.Delete(v,1,2);
        veList.InsertRow(n, v, True); kisoku.Add('e');
        veList.ItemProps[i].EditStyle := esSimple ;
      end else
      begin
        veList.InsertRow(n, v, True); kisoku.Add('');
        veList.ItemProps[i].PickList.Clear ;
        veList.ItemProps[i].EditStyle := esSimple ;
      end;
      w := veList.Canvas.TextWidth(n);
      if max_w < w then max_w := w;
    end;
    veList.ColWidths[0] := Trunc(max_w * 1.1) + 8;
    veList.DefaultRowHeight := Trunc(veList.Canvas.TextHeight('A') * 1.5);
    if self.ClientWidth < veList.ColWidths[0] * 2 then
    begin
      Self.ClientWidth := Trunc(veList.ColWidths[0] * 2.5);
      Self.ClientHeight := veList.DefaultRowHeight * 5;
    end;
  finally
    sl.Free ;
  end;
end;

function TfrmInputList.getResult: string;
begin
  Result := veList.Strings.Text;
end;

procedure TfrmInputList.btnOkClick(Sender: TObject);
begin
  Res := True;
  Close;
end;

procedure TfrmInputList.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmInputList.veListEditButtonClick(Sender: TObject);
var
  s, v: string;
  i, c: Integer;
begin
  //
  i := veList.Row;
  s := kisoku.Strings[ i ];
  if s = '' then Exit;
  case s[1] of
    'f':
      begin
        System.Delete(s,1,1);
        if s <> '' then dlgOpen.Filter := s else dlgOpen.Filter := '全て(*.*)|*.*';
        if dlgOpen.Execute then
        begin
          s := veList.Keys[i];
          veList.Values[s] := dlgOpen.FileName;
        end;
      end;
    'd':
      begin
        System.Delete(s,1,1);
        if SelectDirectory('フォルダの選択', s, v) then
        begin
          s := veList.Keys[i];
          if Copy(v,length(v),1) <> '\' then v := v + '\';
          veList.Values[s] := v;
        end;
      end;
    'c':
      begin
        if dlgColor.Execute then
        begin
          c := dlgColor.Color;
          veList.Cells[1,i] := '$' + IntToHex(Color2RGB(c),6) ;
        end;
      end;

  end;
end;

procedure TfrmInputList.veListDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  h, y, c: Integer;
  s: string;
begin
  if ACol <> 0 then Exit;
  if ARow  = 0 then Exit;

  veList.Canvas.Brush.Style := bsClear;
  veList.Canvas.Pen.Style := psClear;

  s := veList.Cells[1, ARow];
  c := clBtnFace;
  if ((Copy(s,1,1) = '$')or(Copy(s,1,1) = '#')) and (Length(s) = 7) then
  begin
    s := JReplaceU(s, '#', '$', True);
    c := StrToIntDef(s, -1);
    if c >= 0 then c := Color2RGB(c);
  end;

  if (ARow = veList.Row)and(self.ActiveControl = veList) then
  begin
    // カーソル行
    veList.Canvas.Brush.Color := clActiveCaption;
    veList.Canvas.Font.Color  := c;//clCaptionText ;
  end else
  begin
    // 非カーソル行
    veList.Canvas.Brush.Color := c;
    veList.Canvas.Font.Color  := c xor $FFFFFF;
  end;

  h := Rect.Bottom - Rect.Top ;
  y := (h - veList.Canvas.TextHeight('A')) div 2;
  veList.Canvas.Rectangle(Rect);
  veList.Canvas.TextOut(Rect.Left + 4, Rect.Top + y, veList.Cells[ACol, ARow]);

  veList.Canvas.Pen.Style := psSolid;
end;

procedure TfrmInputList.veListEnter(Sender: TObject);
begin
  veList.Row := 1;
  ChangeIME(1);
end;

procedure TfrmInputList.veListExit(Sender: TObject);
begin
  veList.Invalidate ;
end;

procedure TfrmInputList.veListKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key=#9)or(Key=#13) then
  begin
    Key := #0;
    if veList.Row < veList.RowCount-1 then
    begin
      veList.Row := veList.Row + 1;
      Invalidate;
    end else
    begin
      btnOK.SetFocus ;
    end;
  end;
end;

procedure TfrmInputList.veListKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_UP)or(Key = VK_DOWN)or(Key = VK_RETURN)or(Key = VK_TAB) then
  begin
    veList.Invalidate ;
  end;

end;

procedure TfrmInputList.veListMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  col, row: Integer;
begin
  veList.MouseToCell(X,Y,col,row);
  if (Row > 0)and(Row < veList.RowCount) then
  begin
    veList.Row := row;
    veList.Invalidate ;
  end;
end;

procedure TfrmInputList.veListSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  ChangeIME(ARow) ;
  veList.Invalidate ;
end;

procedure TfrmInputList.mnuCopyAsTextClick(Sender: TObject);
begin
  Clipboard.AsText := getResult;
  Beep;
end;

procedure TfrmInputList.mnuOpenClick(Sender: TObject);
var
  s: TStringList;
  i: Integer;
  k: string;
begin
  dlgOpen.Filter := '全て(*.*)|*.*';
  if dlgOpen.Execute then
  begin
    s := TStringList.Create;
    s.LoadFromFile(dlgOpen.FileName);
    for i := 0 to s.Count - 1 do
    begin
      k := s.Names[i];
      veList.Values[k] := s.Values[k];
    end;
    s.Free;
  end;
end;

procedure TfrmInputList.mnuSaveClick(Sender: TObject);
var
  s: TStringList;
begin
  dlgSave.Filter := '全て(*.*)|*.*';
  if dlgSave.Execute then
  begin
     s := TStringList.Create;
     s.Text := getResult;
     s.SaveToFile(dlgSave.FileName);
     s.Free;
  end;
end;

procedure TfrmInputList.C1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmInputList.mnuResetClick(Sender: TObject);
var
  i: Integer;
begin
  i := MessageBox(
        Self.Handle,
        'フォームの内容を初期化してよろしいですか？',
        'フォームの初期化', MB_YESNO);
  if i = IDYES then
  begin
    for i := 1 to  veList.RowCount - 1 do
    begin
      veList.Cells[1,i] := '';
    end;
  end;
end;

end.
