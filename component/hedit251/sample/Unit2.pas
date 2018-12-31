unit Unit2;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, ComCtrls,
  HEditor, ImgList, StdCtrls;

type
  TForm2 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Editor1: TEditor;
    TabSheet2: TTabSheet;
    Editor2: TEditor;
    TabSheet3: TTabSheet;
    Editor3: TEditor;
    TabSheet4: TTabSheet;
    Editor4: TEditor;
    TabSheet5: TTabSheet;
    Editor5: TEditor;
    TabSheet6: TTabSheet;
    Editor6: TEditor;
    TabSheet7: TTabSheet;
    Editor7: TEditor;
    TabSheet8: TTabSheet;
    Editor8: TEditor;
    TabSheet9: TTabSheet;
    Editor9: TEditor;
    ImageList_Digits: TImageList;
    ImageList_Marks: TImageList;
    TabSheet10: TTabSheet;
    Editor10: TEditor;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Editor1DrawLine(Sender: TObject; LineStr: string; X, Y,
      Index: Integer; ARect: TRect; Selected: Boolean);
    procedure Editor2DrawLine(Sender: TObject; LineStr: String; X, Y,
      Index: Integer; ARect: TRect; Selected: Boolean);
    procedure Editor2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Editor2Click(Sender: TObject);
    procedure Editor3MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Editor3DblClick(Sender: TObject);
    procedure Editor4DrawLine(Sender: TObject; LineStr: string; X, Y,
      Index: Integer; ARect: TRect; Selected: Boolean);
    procedure Editor6MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Editor6DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure Editor6DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure Editor6EndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure Editor7Click(Sender: TObject);
    procedure Editor8Click(Sender: TObject);
    procedure Editor8DrawLine(Sender: TObject; LineStr: String; X, Y,
      Index: Integer; ARect: TRect; Selected: Boolean);
    procedure Editor9Click(Sender: TObject);
  private
    FEditor6Dragging: Boolean; // Reselection
                               // Dragging されたかどうかを保持するフラグ
                               // Editor6DragOver で設定 Editor6EndDrag で解除
    FHintWindow: THintWindow;
    procedure ShowHintWindow(S: String);
    procedure HideHintWindow;
    procedure DrawDBSpaceMark(Editor: TEditor; R: TRect;
      X, Y: Integer; Selected: Boolean);
    procedure DrawTabMark(Editor: TEditor; R: TRect;
      X, Y: Integer; Selected: Boolean);
  public
    FFileList: TStringList;
  end;

implementation

uses
  ShellApi,    // ShellExecute
  heUtils,     // Max 関数
  heFountain,  // TFountainParser
  heRaStrings, // rm0..rm15
  unit3;       // データモジュール上の TEditorProp, TFountain

{$R *.DFM}

procedure TForm2.FormCreate(Sender: TObject);
begin
  FFileList := TStringList.Create;
  FFileList.Add('TEditor Demo  Drawing');
  FFileList.Add('TEditor Demo  WordWrap');
  FFileList.Add('TEditor Demo  HTML');
  FFileList.Add('TEditor Demo  BoxSelection');
  FFileList.Add('TEditor Demo  Split');
  FFileList.Add('TEditor Demo  Selection Drag and Drop');
  FFileList.Add('TEditor Demo  Leftbar and Ruler');
  FFileList.Add('TEditor Demo  Fountain');
  FFileList.Add('TEditor Demo  Imagebar');
  FFileList.Add('TEditor Demo  Search');
  FHintWindow := THintWindow.Create(Self);
  // Imagebar
  with Editor9 do
  begin
    PutRowMark(50, rm0);
    PutRowMark(51, rm1);
    PutRowMark(52, rm2);
    PutRowMark(53, rm3);
    PutRowMark(54, rm4);
    PutRowMark(55, rm5);
    PutRowMark(56, rm6);
    PutRowMark(57, rm7);
    PutRowMark(69, rm8);
    PutRowMark(72, rm9);
    PutRowMark(51, rm10);
    PutRowMark(52, rm11);
    PutRowMark(53, rm12);
    PutRowMark(55, rm13);
    PutRowMark(56, rm14);
    PutRowMark(57, rm15);
  end;
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  FHintWindow.Free;
  FFileList.Free;
end;

procedure TForm2.ShowHintWindow(S: String);
var
  CursorHeight: Integer;
  Rect: TRect;
  Pos: TPoint;
begin
  if not FHintWindow.HandleAllocated then
    FHintWindow.HandleNeeded;
  CursorHeight := GetSystemMetrics(SM_CYCAPTION);
  GetCursorPos(Pos);
  Rect := Bounds(0, 0, Screen.Width, 0);
  DrawText(FHintWindow.Canvas.Handle, PChar(S),
    -1, Rect, DT_CALCRECT or DT_LEFT or DT_WORDBREAK or DT_NOPREFIX);
  OffsetRect(Rect, Pos.X, Pos.Y + CursorHeight);
  Inc(Rect.Right, 6);
  Inc(Rect.Bottom, 2);
  FHintWindow.ActivateHint(Rect, S);
end;

procedure TForm2.HideHintWindow;
begin
  if FHintWindow.HandleAllocated then
    FHintWindow.ReleaseHandle;
end;

procedure TForm2.DrawTabMark(Editor: TEditor; R: TRect;
  X, Y: Integer; Selected: Boolean);
var
  W, Xm, Ym: Integer;
begin
  // レフトマージンより左には描画しない
  if X < R.Left then
    Exit;
  if Editor <> nil then
  begin
    X := X + 2;
    Y := Y + (Editor.RowHeight - Editor.Margin.Line) div 2;
    if Editor.ColWidth > 13 then
    begin
      W := 2;
      Ym := 5;
      Xm := 5;
    end
    else
    begin
      W := 1;
      Ym := 1;
      Xm := 3;
    end;
    with Editor.Canvas do
    begin
{
      if Selected then
        Pen.Color := Editor.View.Colors.Select.Color
      else
        Pen.Color := clGray;
}

      (*
        Selected は Boolean(Byte(sstNone, sstSelected, sstHitSelected のどれか))
        という値でやって来ているので、
        TEditorSelectionState(Byte(Selected)) とキャストすることで
        非選択状態、選択状態、検索一致文字列の描画状態を知ることが出来る。
      *)

      if not Selected then
        Pen.Color := clGray
      else
        if TEditorSelectionState(Byte(Selected)) = sstSelected then
          Pen.Color := Editor.View.Colors.Select.Color
        else
          Pen.Color := Editor.View.Colors.Hit.Color;

      Pen.Width := W;
      MoveTo(X, Y - Ym);
      LineTo(X + Xm, Y);
      MoveTo(X, Y + Ym);
      LineTo(X + Xm, Y);
    end;
  end;
end;

procedure TForm2.DrawDBSpaceMark(Editor: TEditor; R: TRect;
  X, Y: Integer; Selected: Boolean);
var
  C: Integer;
begin
  if Editor <> nil then
  begin
    X := X + 2;
    Y := Y + 2;
    C := Editor.ColWidth - Editor.Margin.Character;
    // レフトマージンより左には描画しない
    if X + C * 2 - 4 < R.Left then
      Exit;
    with Editor.Canvas do
    begin
{
      if Selected then
        Pen.Color := Editor.View.Colors.Select.Color
      else
        Pen.Color := clGray;
}

      if not Selected then
        Pen.Color := clGray
      else
        if TEditorSelectionState(Byte(Selected)) = sstSelected then
          Pen.Color := Editor.View.Colors.Select.Color
        else
          Pen.Color := Editor.View.Colors.Hit.Color;

      Pen.Width := 1;
      Pen.Style := psSolid;
      Brush.Style := bsClear;
//      Rectangle(X, Y, X + C * 2 - 4, Y + C * 2 - 4);
      MoveTo(Max(R.Left, X), Y + C * 2 - 4);
      LineTo(X + C * 2 - 4, Y + C * 2 - 4);
      LineTo(X + C * 2 - 4, Y);
      LineTo(Max(R.Left - 1, X), Y);
      if X >= R.Left then
        LineTo(X, Y + C * 2 - 4);
    end;
  end;
end;

// 以下のイベントハンドラは、複数のインスタンスから参照されるので
// Sender as TEditor に対して処理を行う仕様になっている

procedure TForm2.Editor1DrawLine(Sender: TObject; LineStr: string; X, Y,
  Index: Integer; ARect: TRect; Selected: Boolean);
var
  S: String;
  Parser: TFountainParser;
  E, T, C, P, Xp: Integer;
  Editor: TEditor;
begin
  // Editor の取得
  if Sender is TEditor then
    Editor := Sender as TEditor
  else
    Exit;
  // LineStr は、タブがスペースに展開された文字列なので、
  // ListString[Index] を取得する
  S := Editor.ListString[Index];
  // その中に、タブか全角スペースがある場合だけ処理
  if (Pos(#9, S) > 0) or (Pos(#$81#$40{'　'}, S) > 0) then
  begin
    E := 0;
    T := Editor.Caret.TabSpaceCount;
    C := Editor.ColWidth;
    Parser := Editor.ActiveFountain.ParserClass.Create(Editor.ActiveFountain);
    try
      Parser.NewData(S, Editor.ListData[Index]);
      while Parser.NextToken <> toEof do
      begin
        case Parser.Token of
          toTab:
            begin
              P := Parser.SourcePos;
              // ワードラップしている場合、X は前の行文字列長分
              // デクリメントされているので使用しない。
              Xp := Editor.LeftMargin - Editor.LeftScrollWidth +
                    P * C + E;
              // ARect の中でだけ描画する
              if (ARect.Left <= Xp ) and (Xp <= ARect.Right - C) then
                DrawTabMark(Editor, ARect, Xp, Y, Selected);
              // タブを展開したピクセル値を保持する
              Inc(E, (T - ((P + E div C) mod T + 1)) * C);
            end;
          toDBSymbol:
            if Parser.TokenString = #$81#$40 then
            begin
              P := Parser.SourcePos;
              // ワードラップしている場合、X は前の行文字列長分
              // デクリメントされているので使用しない。
              Xp := Editor.LeftMargin - Editor.LeftScrollWidth +
                    P * C + E;
              // ARect の中でだけ描画する
              if (ARect.Left <= Xp ) and
                 (Xp <= ARect.Right - C * 2) then
                DrawDBSpaceMark(Editor, ARect, Xp, Y, Selected);
            end;
        end;
      end;
    finally
      Parser.Free;
    end;
  end;
end;

procedure TForm2.Editor2DrawLine(Sender: TObject; LineStr: String; X, Y,
  Index: Integer; ARect: TRect; Selected: Boolean);
var
  Xp: Integer;
  Parser: TFountainParser;
  Editor: TEditor;
begin
  // Editor の取得
  if Sender is TEditor then
    Editor := Sender as TEditor
  else
    Exit;
  Parser := Editor.ActiveFountain.ParserClass.Create(Editor.ActiveFountain);
  try
    Parser.NewData(LineStr, Editor.ListData[Index]);
    while Parser.NextToken <> toEof do
    begin
      if Parser.TokenString = '■' then
      begin
        Xp := X + Parser.SourcePos * Editor.ColWidth;
        // 影を描画
{
        if Selected then
          // 選択領域の背景色
          Editor.Canvas.Brush.Color := Editor.View.Colors.Select.BkColor
        else
          Editor.Canvas.Brush.Color := Editor.Color;
}

        // DrawDBSpaceMark メソッドのような判別文が機能しない場合は、
        // 以下のような case 文を使って下さい。

        case TEditorSelectionState(Byte(Selected)) of
          sstNone:
            Editor.Canvas.Brush.Color := Editor.Color;
          sstSelected:
            Editor.Canvas.Brush.Color := Editor.View.Colors.Select.BkColor;
          sstHitSelected:
            Editor.Canvas.Brush.Color := Editor.View.Colors.Hit.BkColor;
        end;
        Editor.Canvas.Font.Style := [fsBold];
        Editor.Canvas.Font.Color := clSilver;
        Editor.Canvas.Brush.Style := bsSolid;
        Editor.DrawTextRect(ARect, Xp + 1, Y + 1, Parser.TokenString, ETO_CLIPPED);
        // 実体を描画
{
        if Selected then
          // 選択領域の文字色
          Editor.Canvas.Font.Color := Editor.View.Colors.Select.Color
        else
          Editor.Canvas.Font.Color := clLime;
}
        case TEditorSelectionState(Byte(Selected)) of
          sstNone:
            Editor.Canvas.Font.Color := clLime;
          sstSelected:
            Editor.Canvas.Font.Color := Editor.View.Colors.Select.Color;
          sstHitSelected:
            Editor.Canvas.Font.Color := Editor.View.Colors.Hit.Color;
        end;
        Editor.Canvas.Brush.Style := bsClear;
        Editor.DrawTextRect(ARect, Xp, Y, Parser.TokenString, ETO_CLIPPED);
      end;
    end;
  finally
    Parser.Free;
  end;
end;

procedure TForm2.Editor2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  I: Integer;
  S: String;
begin
  // Editor2, 7, 8, 9 に設定されている
  if Sender is TEditor then
    with Sender as TEditor do
    begin
      S := WordFromPos(Point(X, Y));
      if ReserveWordList.Find(S, I) then
        Cursor := crDefault
      else
        case CursorState of
          mcClient: Cursor := Caret.Cursors.DefaultCursor;
          mcLeftMargin: Cursor := Caret.Cursors.LeftMarginCursor;
          mcInSel: Cursor := Caret.Cursors.InSelCursor;
          mcDragging: Windows.SetCursor(Screen.Cursors[Caret.Cursors.DragSelCursor]);
          mcDraggingCopy: Windows.SetCursor(Screen.Cursors[Caret.Cursors.DragSelCopyCursor]);
        end;
    end;
end;

procedure TForm2.Editor2Click(Sender: TObject);
var
  Editor: TEditor;
  APos: TPoint;
  S: String;
  I: Integer;
begin
  if Sender is TEditor then
  begin
    Editor := Sender as TEditor;
    with Editor do
    begin
      GetCursorPos(APos);
      S := WordFromPos(Editor.ScreenToClient(APos));
      if ReserveWordList.Find(S, I) then
        case I of
          0: WrapOption.FollowPunctuation := False;
          1: WrapOption.FollowPunctuation := True;
          2: WrapOption.FollowRetMark := False;
          3: WrapOption.FollowRetMark := True;
          4: WrapOption.Leading := False;
          5: WrapOption.Leading := True;
          6: WrapOption.WordBreak := False;
          7: WrapOption.WordBreak := True;
        end;
    end;
  end;
end;

procedure TForm2.Editor3MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Sender is TEditor then
    with Sender as TEditor do
      case TokenFromPos(Point(X, Y)) of
        toUrl:
          begin
            Cursor := crDefault;
            ShowHintWindow('ダブルクリックすると行きます。');
          end;
        toMail:
          begin
            Cursor := crDefault;
            ShowHintWindow('メールお待ちしております。');
          end;
      else
        HideHintWindow;
        case CursorState of
          mcClient: Cursor := Caret.Cursors.DefaultCursor;
          mcLeftMargin: Cursor := Caret.Cursors.LeftMarginCursor;
          mcInSel: Cursor := Caret.Cursors.InSelCursor;
          mcDragging: Windows.SetCursor(Screen.Cursors[Caret.Cursors.DragSelCursor]);
          mcDraggingCopy: Windows.SetCursor(Screen.Cursors[Caret.Cursors.DragSelCopyCursor]);
        end;
      end;
end;

procedure TForm2.Editor3DblClick(Sender: TObject);
var
  S: String;
  C: Char;
  Editor: TEditor;
begin
  if Sender is TEditor then
  begin
    Editor := Sender as TEditor;
    C := Editor.TokenFromCaret;
    if (C = toUrl) or (C = toMail) then
    begin
      HideHintWindow;
      if C = toUrl then
        S := Editor.TokenStringFromCaret
      else
        S := 'mailto:' + Editor.TokenStringFromCaret;
      ShellExecute(Handle, 'OPEN', PChar(S), '', '', SW_SHOW);
    end
    else
      Editor.SelectTokenFromCaret;
  end;
end;

procedure TForm2.Editor4DrawLine(Sender: TObject; LineStr: string; X, Y,
  Index: Integer; ARect: TRect; Selected: Boolean);
var
  Editor: TEditor;
begin
  // Editor の取得
  if Sender is TEditor then
    Editor := Sender as TEditor
  else
    Exit;
  if (LineStr = 'abc') or
     (LineStr = 'defg') or
     (LineStr = 'hijk') then
  with Editor.Canvas do
  begin
    Brush.Color := Editor.View.Colors.Select.BkColor;
    Font.Color := Editor.View.Colors.Select.Color;
    Editor.DrawTextRect(ARect, X, Y, LineStr, ETO_OPAQUE or ETO_CLIPPED);
  end;
end;

// Drag & Drop

procedure TForm2.Editor6MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  R, C: Integer;
begin
  if (Sender is TEditor) and (Button = mbLeft) then
    with TEditor(Sender) do
    begin
      // X, Y 位置の Row, Col 値を取得。引数に False を渡すのがミソ１
      PosToRowCol(X, Y, R, C, False);
      // ドラッグ可能状態でそこが選択領域内であればドラッグ開始
      if CanSelDrag and (LeftMargin <= X) and IsSelectedArea(R, C) then
        TEditor(Sender).BeginDrag(False);
    end;
end;

procedure TForm2.Editor6DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  R, C: Integer;
begin
  if (Sender is TEditor) and (Source is TEditor) then
    with TEditor(Sender) do
    begin
      FEditor6Dragging := True; // Reselection Dragging フラグ設定 Editor6EndDrag で解除
      // 上に行った時はスクロールする
      if Y <= TopMargin then
        Row := Row - 1;
      // ドラッグオブジェクトにキャレットを追随させる
      // ここでも、False を渡すミソ１
      PosToRowCol(X, Y, R, C, False);
      SetRowCol(R, C);
      Accept := True;
    end;
end;

// ミソ１については、IsSelectedArea, PosToRowCol のヘルプを参照して下さい。

procedure TForm2.Editor6DragDrop(Sender, Source: TObject; X, Y: Integer);
var
  Length: Integer;
  InSel: Boolean;
begin
  if (Sender is TEditor) and (Source is TEditor) then
    with TEditor(Sender) do
    begin
      InSel := IsSelectedArea(Row, Col); // Reselection
      if Source = Sender then
      begin
        Length := SelLength; // Reselection
        // 自身のデータを移動又はコピー
        if GetKeyState(VK_CONTROL) < 0 then
          // ssCtrl キーが押されている場合はコピー
          CopySelection(Row, Col)
        else
          // 移動
          MoveSelection(Row, Col);
      end
      else
      begin
        Length := TEditor(Source).SelLength; // Reselection
        // 他人のデータなので選択状態の場合は解除してから
        // キャレット位置へ他人の選択領域文字列を挿入する
        CleanSelection;
        SetSelTextBuf(PChar(TEditor(Source).SelText));
      end;
      // Reselection
      if FEditor6Dragging then
        if InSel then
          // 選択領域内にドロップされた場合
          CleanSelection
        else
        begin
          // 再選択処理
          SelStart := SelStart - Length;
          SelLength := Length;
        end;
    end;
end;

procedure TForm2.Editor6EndDrag(Sender, Target: TObject; X, Y: Integer);
begin
  // BeginDrag(False) した後、マウスを動かすことなくドロップ
  // した場合のための処理
  if (Sender is TEditor) and not FEditor6Dragging {Reselection} then
    TEditor(Sender).CleanSelection;
  FEditor6Dragging := False; // Reselection フラグ解除
end;

procedure TForm2.Editor7Click(Sender: TObject);
var
  Editor: TEditor;
  APos: TPoint;
  S: String;
  I: Integer;
begin
  if Sender is TEditor then
  begin
    Editor := Sender as TEditor;
    with Editor do
    begin
      GetCursorPos(APos);
      S := WordFromPos(Editor.ScreenToClient(APos));
      if ReserveWordList.Find(S, I) then
        case I of
          0:
            begin
              // Edge_False
              Leftbar.Edge := False;
              Leftbar.BkColor := clNavy;
              Leftbar.Color := clWhite;
              Ruler.Edge := False;
              Ruler.BkColor := clNavy;
              Ruler.Color := clWhite;
            end;
          1:
            begin
              // Edge_True
              Leftbar.Edge := True;
              Leftbar.BkColor := clBtnFace;
              Leftbar.Color := clWindowText;
              Ruler.Edge := True;
              Ruler.BkColor := clBtnFace;
              Ruler.Color := clWindowText;
            end;
          2: Ruler.GaugeRange := 10;
          3: Ruler.GaugeRange := 8;
          4: Leftbar.ShowNumberMode := nmLine;
          5: Leftbar.ShowNumberMode := nmRow;
          6: Leftbar.ZeroBase := not Leftbar.ZeroBase;
          7: Leftbar.ZeroLead := not Leftbar.ZeroLead;
        end;
    end;
  end;
end;

procedure TForm2.Editor8Click(Sender: TObject);
var
  Editor: TEditor;
  APos: TPoint;
  S: String;
  I: Integer;
begin
  if Sender is TEditor then
  begin
    Editor := Sender as TEditor;
    with Editor do
    begin
      GetCursorPos(APos);
      S := WordFromPos(Editor.ScreenToClient(APos));
      if ReserveWordList.Find(S, I) then
        case I of
          0: Fountain := Props.DelphiFountain1;
          1: Fountain := Props.HTMLFountain1;
          2: Fountain := nil;
        end;
    end;
  end;
end;

procedure TForm2.Editor8DrawLine(Sender: TObject; LineStr: String; X, Y,
  Index: Integer; ARect: TRect; Selected: Boolean);
var
  Editor: TEditor;
  Parser: TFountainParser;
  I: Integer;
begin
  // Editor の取得
  if Sender is TEditor then
    Editor := Sender as TEditor
  else
    Exit;
  Parser := Editor.ActiveFountain.ParserClass.Create(Editor.ActiveFountain);
  try
    Parser.NewData(LineStr, Editor.ListData[Index]);
    while Parser.NextToken <> toEof do
      if Editor.ReserveWordList.Find(Parser.TokenString, I) then
        with Editor.Canvas do
        begin
{
          if Selected then
          begin
            Brush.Color := Editor.View.Colors.Select.BkColor;
            Font.Color := Editor.View.Colors.Select.Color;
          end
          else
          begin
            Brush.Color := Editor.Color;
            Font.Color := Editor.View.Colors.Reserve.Color;
          end;
}
          if not Selected then
          begin
            Brush.Color := Editor.Color;
            Font.Color := Editor.View.Colors.Reserve.Color;
          end
          else
            if TEditorSelectionState(Selected) = sstSelected then
            begin
              Brush.Color := Editor.View.Colors.Select.BkColor;
              Font.Color := Editor.View.Colors.Select.Color;
            end
            else
            begin
              Brush.Color := Editor.View.Colors.Hit.BkColor;
              Font.Color := Editor.View.Colors.Hit.Color;
            end;
          Font.Style := [fsUnderline];
          Editor.DrawTextRect(ARect, X + Parser.SourcePos * Editor.ColWidth,
            Y, Parser.TokenString, ETO_CLIPPED);
        end;
  finally
    Parser.Free;
  end;
end;

procedure TForm2.Editor9Click(Sender: TObject);
var
  Editor: TEditor;
  APos: TPoint;
  S: String;
  I: Integer;
begin
  if Sender is TEditor then
  begin
    Editor := Sender as TEditor;
    with Editor do
    begin
      GetCursorPos(APos);
      S := WordFromPos(Editor.ScreenToClient(APos));
      if ReserveWordList.Find(S, I) then
        case I of
          0:
            begin
              ImageDigits := nil;
              ImageMarks := nil;
            end;
          1:
            begin
              ImageDigits := ImageList_Digits;
              ImageMarks := ImageList_Marks;
            end;
        end;
    end;
  end;
end;


end.
