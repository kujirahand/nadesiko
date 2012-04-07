unit Unit1;

{$I heverdef.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Menus, ExtCtrls, HEditor, HtSearch, unit2, heClasses,
  HEdtProp;

type
  TOpenMenuList = class(TStringList)
  public
    FOnClickProc: TNotifyEvent;
    FMenuItem: TMenuItem;
    constructor Create(OnClickProc: TNotifyEvent; MenuItem: TMenuItem);
    destructor Destroy; override;
    procedure BringToTop(const S: String);
    procedure ReadIni;
    procedure WriteIni;
    procedure RecreateMenu;
  end;

  TLineNumberMode = (lmRow, lmLine);

  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    PageControl1: TPageControl;
    Memo1: TMemo;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    Close1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    Exit1: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    Edit1: TMenuItem;
    Undo1: TMenuItem;
    Redo1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    Show1: TMenuItem;
    Find2: TMenuItem;
    Window1: TMenuItem;
    Property1: TMenuItem;
    FountainAttribute: TMenuItem;
    Find3: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    N20: TMenuItem;
    N21: TMenuItem;
    K1: TMenuItem;
    LinesChar1: TMenuItem;
    RowCol1: TMenuItem;
    N17: TMenuItem;
    mnuReOpen: TMenuItem;
    Split1: TMenuItem;
    NewWindow1: TMenuItem;
    Clear1: TMenuItem;
    BoxPaste1: TMenuItem;
    K2: TMenuItem;
    K3: TMenuItem;
    BoxSel1: TMenuItem;
    N10: TMenuItem;
    Indent1: TMenuItem;
    UnIndent1: TMenuItem;
    TabIndent1: TMenuItem;
    TabUnIndent1: TMenuItem;
    N13: TMenuItem;
    overwrite1: TMenuItem;
    ReadOnly1: TMenuItem;
    EditorPropAttribute: TMenuItem;
    EditorProp1: TEditorProp;
    K4: TMenuItem;
    rm101: TMenuItem;
    rm111: TMenuItem;
    rm121: TMenuItem;
    rm131: TMenuItem;
    rm141: TMenuItem;
    rm151: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CaretMoved(Sender: TObject);
    procedure EditorChange(Sender: TObject);
    procedure EditorEnter(Sender: TObject);
    procedure SelectionModeChange(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure mnuLoadFromFileClick(Sender: TObject);
    procedure mnuNewClick(Sender: TObject);
    procedure mnuSaveClick(Sender: TObject);
    procedure mnuSaveAsClick(Sender: TObject);
    procedure mnuClearClick(Sender: TObject);
    procedure mnuPageCloseClick(Sender: TObject);
    procedure mnuReplaceClick(Sender: TObject);
    procedure mnuCutClick(Sender: TObject);
    procedure mnuCopyClick(Sender: TObject);
    procedure mnuPasteClick(Sender: TObject);
    procedure mnuSelectAllClick(Sender: TObject);
    procedure mnuDeleteLineClick(Sender: TObject);
    procedure mnuUndoClick(Sender: TObject);
    procedure mnuRedoClick(Sender: TObject);
    procedure mnuFindClick(Sender: TObject);
    procedure mnuFindForwardClick(Sender: TObject);
    procedure mnuFindBackwardClick(Sender: TObject);
    procedure mnuOverWriteClick(Sender: TObject);
    procedure mnuReadOnlyClick(Sender: TObject);
    procedure RowColClick(Sender: TObject);
    procedure mnuEditorPropertyClick(Sender: TObject);
    procedure mnuIndentClick(Sender: TObject);
    procedure mnuUnIndentClick(Sender: TObject);
    procedure mnuBoxSelClick(Sender: TObject);
    procedure mnuBoxPasteClick(Sender: TObject);
    procedure mnuOtherWindowClick(Sender: TObject);
    procedure mnuSplitClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure TabIndent1Click(Sender: TObject);
    procedure TabUnIndent1Click(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure File1Click(Sender: TObject);
    procedure Window1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure K4Click(Sender: TObject);
    procedure rm101Click(Sender: TObject);
  private
    FFileList: TStringList;
    FLineNumberMode: TLineNumberMode;
    FOpenMenuList: TOpenMenuList;
    FReplaceValue: String;
    FSearchOptions: TSearchOptions;
    FSearchValue: String;
    procedure EditorExchanged(NewEditor: TEditor);
    function GetActiveFileName: String;
    procedure OpenMenuListSelected(Sender: TObject);
    function SecondEditor: TEditor;
    procedure SetActiveFileName(Value: String);
    procedure SetLineNumberMode(Value: TLineNumberMode);
    procedure UpdateCaption;
    procedure UpdateLineNumber(Editor: TEditor);
    procedure UpdateModified(Editor: TEditor);
    procedure UpdateOverWrite(Editor: TEditor);
    procedure UpdateSelectionMode(Editor: TEditor);
    {$IFDEF COMP3_UP}
    function ActiveSplitter: TSplitter;
    procedure SplitterMoved(Sender: TObject);
    {$ENDIF}
  public
    function ActiveEditor: TEditor;
    procedure AssignEvent(Editor: TEditor);
    procedure BeginSplit;
    procedure CreateMenuItem;
    procedure CreateNewSheet(FileName: String);
    procedure EditorPropAttributeProc(Sender: TObject);
    procedure EndSplit;
    procedure FountainAttributeProc(Sender: TObject);
    function IsSplit: Boolean;
    procedure MoveEditorsFromTForm2;
    function Search: Boolean;
    procedure SelectEditorProp(FileName: String; Editor: TEditor);
    property ActiveFileName: String read GetActiveFileName write SetActiveFileName;
    property LineNumberMode: TLineNumberMode read FLineNumberMode write SetLineNumberMode;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses
  Clipbrd, {Registry,} IniFiles,
  HSchfm,         // 検索データフォーム
  HReplfm,        // 置き換えデータフォーム
  HViewEdt,       // TEditorProp コンポーネントエディタ
  FountainEditor, // TFountain コンポーネントエディタ
  hPropUtils,     // AssignProperties
  TypInfo,        // tkAny 識別子
  heFountain,     // TFountain
  heUtils,        // use LeadBytes on D2
  heRaStrings,    // rm0..rm15
  unit3;          // データモジュール上の TEditorProp, TFountain

const
  NewFile = 'new file';


{  TOpenMenuList  }

constructor TOpenMenuList.Create(OnClickProc: TNotifyEvent;
    MenuItem: TMenuItem);
begin
  FOnClickProc := OnClickProc;
  FMenuItem := MenuItem;
  ReadIni;
  RecreateMenu;
end;

destructor TOpenMenuList.Destroy;
var
  I: Integer;
begin
  WriteIni;
  for I := FMenuItem.Count - 1 downto 0 do
    FMenuItem.Items[I].Free;
  inherited Destroy;
end;

procedure TOpenMenuList.BringToTop(const S: String);
begin
  if IndexOf(S) <> -1 then
    Delete(IndexOf(S));
  Insert(0, S);
  if Count > 8 then
    Delete(Count - 1);
  RecreateMenu;
end;

procedure TOpenMenuList.ReadIni;
var
  Ini: TIniFile;
  I, Cnt: Integer;
begin
  Ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    Cnt := Ini.ReadInteger('OpenMenuItems', 'Count', 0);
    for I := 0 to Cnt - 1 do
      Add(Ini.ReadString('OpenMenuItems', 'Item' + IntToStr(I), ''));
  finally
    Ini.Free;
  end;
end;

procedure TOpenMenuList.WriteIni;
var
  Ini: TIniFile;
  I: Integer;
begin
  Ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    Ini.WriteInteger('OpenMenuItems', 'Count', Count);
    for I := 0 to Count - 1 do
      Ini.WriteString('OpenMenuItems', 'Item' + IntToStr(I), Strings[I]);
  finally
    Ini.Free;
  end;
end;

procedure TOpenMenuList.RecreateMenu;
var
  I: Integer;
  Item: TMenuItem;
begin
  for I := FMenuItem.Count - 1 downto 0 do
    FMenuItem.Items[I].Free;
  for I := 0 to Count - 1 do
  begin
    Item := TMenuItem.Create(FMenuItem);
    Item.Caption := Strings[I];
    Item.OnClick := FOnClickProc;
    FMenuItem.Add(Item);
  end;
end;


{  TForm1  }

procedure TForm1.MoveEditorsFromTForm2;
var
  I: Integer;
  Form: TForm2;
begin
  (*
    TForm2 を生成し、TForm2.TabSheet1..TabSheet9 を
    TForm1.PageControl1 へ移動し Editor1..Editor9 のイベントハンドラの
    一部を AssignEvent メソッドで TForm1 のものに設定する。
  *)
  Form := TForm2.Create(Application);
  for I := 0 to Form.ComponentCount - 1 do
    if Form.Components[I] is TTabSheet then
      TTabSheet(Form.Components[I]).PageControl := PageControl1
    else
      if Form.Components[I] is TEditor then
        AssignEvent(TEditor(Form.Components[I]));
  for I := 0 to Form.FFileList.Count - 1 do
    FFileList.Add(Form.FFileList[I]);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Free; // 効能書きの消去
  FFileList := TStringList.Create;
  FOpenMenuList := TOpenMenuList.Create(OpenMenuListSelected, mnuReOpen);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FOpenMenuList.Free;
  FFileList.Free;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  CreateMenuItem;
  PageControl1Change(Self);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // 別窓編集したフォームが閉じた時メモリを解放するために caFree とする
  Action := caFree;
end;

// TOpenMenuList.Create コンストラクタに渡すためのイベントハンドラ
procedure TForm1.OpenMenuListSelected(Sender: TObject);
var
  S: String;
begin
  if Sender is TMenuItem then
  begin
    S := TMenuItem(Sender).Caption;
    if FileExists(S) then
    begin
      FOpenMenuList.BringToTop(S);
      CreateNewSheet(S);
      with PageControl1 do
        ActivePage := Pages[PageCount - 1];
      ActiveEditor.Lines.LoadFromFile(S);
      ActiveEditor.Modified := False;
      EditorExchanged(ActiveEditor);
    end;
  end;
end;

procedure TForm1.CreateMenuItem;
var
  I: Integer;
  S: String;
  Item, TargetItem: TMenuItem;
  Proc: TNotifyEvent;

  procedure AddMenuItem;
  begin
    Item := TMenuItem.Create(TargetItem);
    Item.Caption := S;
    Item.OnClick := Proc;
    TargetItem.Add(Item);
  end;

begin
  for I := 0 to Props.ComponentCount - 1 do
    if (Props.Components[I] is TEditorProp) then
    begin
      TargetItem := EditorPropAttribute;
      // Exclude 'EditorProp_'
      S := Copy(Props.Components[I].Name, 12, MaxInt);
      Proc := EditorPropAttributeProc;
      AddMenuItem;
    end
    else
      if Props.Components[I] is TFountain then
      begin
        TargetItem := FountainAttribute;
        // Exclude 'Fountain1'
        S := Props.Components[I].Name;
        S := Copy(S, 1, Length(S) - 9);
        Proc := FountainAttributeProc;
        AddMenuItem;
      end;
end;

function DeleteAmpersand(const S: String): String;
(*
  D6 フィールドテスト版では、実行時に追加するメニューアイテムの
  キャプションに '&' が自動的に挿入されたので、それを除去するための関数

  といいつつ、実はＤ５でアクセラレータキーが自動的に挿入される機能が
  追加されたことを知ったので、対応した
*)
var
  I, L: Integer;
begin
  Result := '';
  L := Length(S);
  I := 1;
  while I <= L do
  begin
    if S[I] in LeadBytes then
    begin
      Result := Result + S[I] + S[I + 1];
      Inc(I);
    end
    else
      if S[I] <> '&' then
        Result := Result + S[I];
    Inc(I);
  end;
end;

procedure TForm1.EditorPropAttributeProc(Sender: TObject);
var
  Prop: TEditorProp;
  S: String;
begin
  if Sender is TMenuItem then
  begin
    S := DeleteAmpersand(TMenuItem(Sender).Caption);
    Prop := TEditorProp(Props.FindComponent('EditorProp_' + S));
    if (Prop <> nil) and EditEditorProp(Prop, nil) then
    begin
      Prop.WriteIni(
        ChangeFileExt(Application.ExeName, '.ini'),
        Prop.Name, 'prop');
      if ((ActiveEditor <> nil) and
           Prop.HasExt(ExtractFileExt(ActiveFileName))) or
         ((Prop = Props.EditorProp_Default) and
          (ActiveFileName = NewFile)) then
        Prop.AssignTo(ActiveEditor);
    end;
  end;
end;

procedure TForm1.FountainAttributeProc(Sender: TObject);
var
  Fountain: TFountain;
  S: String;
begin
  if Sender is TMenuItem then
  begin
    S := DeleteAmpersand(TMenuItem(Sender).Caption);
    Fountain := TFountain(Props.FindComponent(S + 'Fountain1'));
    if (Fountain <> nil) and EditFountain(Fountain) then
    begin
      Fountain.WriteIni(
        ChangeFileExt(Application.ExeName, '.ini'),
        Fountain.Name, 'prop');
      if (ActiveEditor <> nil) and
          Fountain.HasExt(ExtractFileExt(ActiveFileName)) then
        ActiveEditor.Fountain := Fountain;
    end;
  end;
end;


// イベントハンドラ群 ///////////////////////////////////////////////

procedure TForm1.CaretMoved(Sender: TObject);
begin
  if Sender is TEditor then
    UpdateLineNumber(TEditor(Sender));
end;

procedure TForm1.EditorChange(Sender: TObject);
begin
  if Sender is TEditor then
    UpdateModified(TEditor(Sender));
end;

procedure TForm1.SelectionModeChange(Sender: TObject);
begin
  if Sender is TEditor then
    UpdateSelectionMode(TEditor(Sender));
end;

procedure TForm1.EditorEnter(Sender: TObject);
begin
  if Sender is TEditor then
    UpdateSelectionMode(TEditor(Sender));
end;

procedure TForm1.PageControl1Change(Sender: TObject);
begin
  ActiveEditor.SetFocus;
  EditorExchanged(ActiveEditor);
end;


// メソッド群 ///////////////////////////////////////////////////////

function TForm1.ActiveEditor: TEditor;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to PageControl1.ActivePage.ControlCount - 1 do
    if PageControl1.ActivePage.Controls[I] is TEditor then
    begin
      Result := TEditor(PageControl1.ActivePage.Controls[I]);
      if Result.Focused then
        Exit;
    end;
end;

function TForm1.GetActiveFileName: String;
begin
  Result := FFileList[PageControl1.ActivePage.PageIndex];
end;

procedure TForm1.SetActiveFileName(Value: String);
begin
  FFileList[PageControl1.ActivePage.PageIndex] := Value;
end;

procedure TForm1.UpdateCaption;
begin
  Caption := ActiveFileName;
end;

procedure TForm1.UpdateModified(Editor: TEditor);
begin
  if Editor.Modified then
    StatusBar1.Panels[1].Text := '変更'
  else
    StatusBar1.Panels[1].Text := '';
end;

procedure TForm1.UpdateOverWrite(Editor: TEditor);
begin
  if Editor.OverWrite then
    StatusBar1.Panels[2].Text := '上書'
  else
    StatusBar1.Panels[2].Text := '挿入';
end;

procedure TForm1.UpdateSelectionMode(Editor: TEditor);
begin
  if Editor.SelectionMode = smBox then
    StatusBar1.Panels[3].Text := '矩形選択'
  else
    StatusBar1.Panels[3].Text := ''
end;

procedure TForm1.UpdateLineNumber(Editor: TEditor);
begin
  with Editor do
    if FLineNumberMode = lmLine then
      StatusBar1.Panels[0].Text :=
        Format('%5d 行:%4d 桁', [RowToLines(Row) + 1, ColToChar(Row, Col) + 1])
    else
      StatusBar1.Panels[0].Text :=
        Format('%5d 行:%4d 桁', [Row + 1, Col + 1]);
end;

procedure TForm1.EditorExchanged(NewEditor: TEditor);
begin
  UpdateCaption;
  UpdateModified(NewEditor);
  UpdateOverWrite(NewEditor);
  UpdateSelectionMode(NewEditor);
  UpdateLineNumber(NewEditor);
end;

procedure TForm1.SetLineNumberMode(Value: TLineNumberMode);
begin
  if FLineNumberMode <> Value then
  begin
    FLineNumberMode := Value;
    RowCol1.Checked := Value = lmRow;
    LinesChar1.Checked := Value = lmLine;
    UpdateLineNumber(ActiveEditor);
  end;
end;

procedure TForm1.AssignEvent(Editor: TEditor);
begin
  Editor.OnCaretMoved := CaretMoved;
  Editor.OnChange := EditorChange;
  Editor.OnEnter := EditorEnter;
  Editor.OnSelectionModeChange := SelectionModeChange;
end;

procedure TForm1.CreateNewSheet(FileName: String);
var
  Sheet: TTabSheet;
  NewEditor: TEditor;
begin
  FFileList.Add(FileName);
  Sheet := TTabSheet.Create(Self);
  Sheet.Caption := ChangeFileExt(ExtractFileName(FileName), '');
  Sheet.PageControl := PageControl1;
  NewEditor := TEditor.Create(Self);
  NewEditor.Parent := Sheet;
  NewEditor.Width := Sheet.Width;
  NewEditor.Height := Sheet.Height;
  NewEditor.Align := alClient;
  AssignEvent(NewEditor);
  SelectEditorProp(FileName, NewEditor);
end;

procedure TForm1.SelectEditorProp(FileName: String; Editor: TEditor);
var
  S: String;
begin
  // ファイルの拡張子に応じてデータモジュール上の EditorProp, Fountain
  // をあてがう
  S := ExtractFileExt(FileName);
  Props.EditorProp(S).AssignTo(Editor);
  Editor.Fountain := Props.Fountain(S);
end;


// menu enabled change //////////////////////////////////////////////

procedure TForm1.File1Click(Sender: TObject);
begin
  Save1.Enabled := PageControl1.ActivePage.Caption <> 'new file';
end;

procedure TForm1.Edit1Click(Sender: TObject);
var
  Sel, CanPaste: Boolean;
begin
  with ActiveEditor do
  begin
    OverWrite1.Checked := OverWrite;
    ReadOnly1.Checked := ReadOnly;
    Sel := SelLength > 0;
    Copy1.Enabled := Sel;
    Cut1.Enabled := Sel;
    Indent1.Enabled := Sel;
    UnIndent1.Enabled := Sel;
    TabIndent1.Enabled := Sel;
    TabUnIndent1.Enabled := Sel;
    CanPaste := Clipboard.HasFormat(CF_TEXT);
    Paste1.Enabled := CanPaste;
    BoxPaste1.Enabled := CanPaste;
    Redo1.Enabled := CanRedo;
    Undo1.Enabled := CanUndo;
    BoxSel1.Checked := SelectionMode = smBox;
  end;
end;

procedure TForm1.Window1Click(Sender: TObject);
begin
  Split1.Checked := IsSplit;
end;


// menu ファイル ////////////////////////////////////////////////////

procedure TForm1.mnuNewClick(Sender: TObject);
begin
  CreateNewSheet(NewFile);
  with PageControl1 do
    ActivePage := Pages[PageCount - 1];
  EditorExchanged(ActiveEditor);
end;

procedure TForm1.mnuLoadFromFileClick(Sender: TObject);
begin
  if (OpenDialog1.Execute) and
     (FileExists(OpenDialog1.FileName)) then
  begin
    CreateNewSheet(OpenDialog1.FileName);
    with PageControl1 do
      ActivePage := Pages[PageCount - 1];
    ActiveEditor.Lines.LoadFromFile(OpenDialog1.FileName);
    ActiveEditor.Modified := False;
    FOpenMenuList.BringToTop(OpenDialog1.FileName);
    EditorExchanged(ActiveEditor);
  end;
end;

procedure TForm1.mnuClearClick(Sender: TObject);
begin
  ActiveEditor.Lines.Clear;
end;

procedure TForm1.mnuPageCloseClick(Sender: TObject);
var
  Index: Integer;
begin
  if PageControl1.PageCount = 1 then
  begin
    Close;
    Exit;
  end;
  Index := PageControl1.ActivePage.PageIndex;
  with PageControl1 do
  begin
    if IsSplit then
      EndSplit;
    FFileList.Delete(Index);
    ActiveEditor.Free;
    ActivePage.Free;
    if Index > 0 then
      ActivePage := Pages[Index - 1]
    else
      ActivePage := Pages[0];
  end;
  PageControl1Change(Self);
end;

procedure TForm1.mnuSaveClick(Sender: TObject);
begin
  ActiveEditor.Lines.SaveToFile(ActiveFileName);
  ActiveEditor.Modified := False;
  UpdateModified(ActiveEditor);
end;

procedure TForm1.mnuSaveAsClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    ActiveEditor.Lines.SaveToFile(SaveDialog1.FileName);
    ActiveFileName := SaveDialog1.FileName;
    PageControl1.ActivePage.Caption :=
      ChangeFileExt(ExtractFileName(SaveDialog1.FileName), '');
    ActiveEditor.Modified := False;
    EditorExchanged(ActiveEditor);
  end;
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  Close;
end;


// menu 編集 ////////////////////////////////////////////////////////

procedure TForm1.mnuUndoClick(Sender: TObject);
begin
  ActiveEditor.Undo;
end;

procedure TForm1.mnuRedoClick(Sender: TObject);
begin
  ActiveEditor.Redo;
end;

procedure TForm1.mnuCutClick(Sender: TObject);
begin
  ActiveEditor.CutToClipboard;
end;

procedure TForm1.mnuCopyClick(Sender: TObject);
begin
  ActiveEditor.CopyToClipboard;
end;

procedure TForm1.mnuPasteClick(Sender: TObject);
begin
  ActiveEditor.PasteFromClipboard;
end;

procedure TForm1.mnuBoxPasteClick(Sender: TObject);
begin
  if Clipboard.HasFormat(CF_TEXT) then
    ActiveEditor.SetSelTextBox(PChar(Clipboard.AsText));
end;

procedure TForm1.mnuSelectAllClick(Sender: TObject);
begin
  ActiveEditor.SelectAll;
end;

procedure TForm1.mnuDeleteLineClick(Sender: TObject);
begin
  ActiveEditor.DeleteRow(ActiveEditor.Row);
end;

procedure TForm1.mnuBoxSelClick(Sender: TObject);
begin
  if ActiveEditor.SelectionMode = smLine then
    ActiveEditor.SelectionMode := smBox
  else
    ActiveEditor.SelectionMode := smLine;
end;

procedure TForm1.mnuIndentClick(Sender: TObject);
begin
  if ActiveEditor.Selected then
    ActiveEditor.SelIndent;
end;

procedure TForm1.mnuUnIndentClick(Sender: TObject);
begin
  if ActiveEditor.Selected then
    ActiveEditor.SelUnIndent;
end;

procedure TForm1.TabIndent1Click(Sender: TObject);
begin
  if ActiveEditor.Selected then
    ActiveEditor.SelTabIndent;
end;

procedure TForm1.TabUnIndent1Click(Sender: TObject);
begin
  if ActiveEditor.Selected then
    ActiveEditor.SelTabUnIndent;
end;

procedure TForm1.mnuOverWriteClick(Sender: TObject);
begin
  ActiveEditor.OverWrite := not ActiveEditor.OverWrite;
  UpdateOverWrite(ActiveEditor);
end;

procedure TForm1.mnuReadOnlyClick(Sender: TObject);
begin
  ActiveEditor.ReadOnly := not ActiveEditor.ReadOnly;
end;


// menu 検索 ////////////////////////////////////////////////////////

function TForm1.Search: Boolean;
begin
  Result := False;
  if not ActiveEditor.Search(FSearchValue, FSearchOptions) then
    ShowMessage('検索文字列  '' ' + FSearchValue + ' ''' + #13#10 +
                'は見つかりませんでした。')
  else
    Result := True;
end;

{ 全テキスト一気検索バージョン

function TForm1.Search: Boolean;
var
  Info: TSearchInfo;
begin
  Result := False;
  with ActiveEditor do
  begin
    Info.Start := SelStart;
    Info.Length := SelLength;
    // cf HTSearch.pas
    if SearchText(PChar(Lines.Text),
                  Info, FSearchValue, FSearchOptions) then
    begin
      SelStart := Info.Start;
      SelLength := Info.Length;
      SendMessage(ActiveEditor.Handle, EM_SCROLLCARET, 0, 0);
      Result := True;
    end
    else
      ShowMessage('検索文字列  '' ' + FSearchValue + ' ''' + #13#10 +
                  'は見つかりませんでした。');
  end;
end;
}

procedure TForm1.mnuFindClick(Sender: TObject);
begin
  if TFormSearch.Execute(FSearchValue, FSearchOptions) then
    Search;
end;

procedure TForm1.mnuFindForwardClick(Sender: TObject);
begin
  if FSearchValue <> '' then
  begin
    Include(FSearchOptions, sfrDown);
    Search;
  end;
end;

procedure TForm1.mnuFindBackwardClick(Sender: TObject);
begin
  if FSearchValue <> '' then
  begin
    Exclude(FSearchOptions, sfrDown);
    Search;
  end;
end;

procedure TForm1.mnuReplaceClick(Sender: TObject);
var
  Editor: TEditor;
  CaretPoint: TPoint;
  MsgForm: TForm;
  Choice: Word;
  Style: TEditorHitStyle;

  procedure ReplaceEditor;
  begin
    // hsDraw の場合、ヒット文字列が描画されているだけで、選択状態ではないので
    // 選択状態にする。
    if Editor.HitStyle <> hsSelect then
      Editor.HitToSelected;
    // 置き換え
    Editor.SelText := FReplaceValue;
    // 後方検索で Delphi を Delphi is Great に置き換えた場合
    // 無限ループになるのを防ぐための処理
    if not (sfrDown in FSearchOptions) then
      Editor.SelStart := Editor.SelStart - Length(FReplaceValue);
  end;

begin
  if TFormReplace.Execute(
       FSearchValue, FReplaceValue, FSearchOptions) then
  begin
    Editor := ActiveEditor;
    // hsCaret による検索一致文字列表現は、置き換え確認ダイアログが出たとき
    // TEditor がフォーカスを失い、キャレットが消えるので、置き換えには
    // 使えないので HitStyle の保存・復帰処理を行う。
    Style := Editor.HitStyle;
    if Editor.HitStyle = hsCaret then
      Editor.HitStyle := hsDraw;
    try
      while Search do
      begin
        if sfrReplaceConfirm in FSearchOptions then
        begin
          // get screen position
          GetCaretPos(CaretPoint);
          CaretPoint := Editor.ClientToScreen(CaretPoint);
          // TMessageForm.Create fc Dialogs.pas
          MsgForm :=
            CreateMessageDialog(
              '' + ' ' + FSearchValue + ' ' + '' + '  を' + #13#10+
              '' + ' ' + FReplaceValue + ' ' + '' + '  に 置き換えますか？',
              mtConfirmation, [mbYes, mbNo, mbCancel, mbAll]);
          try
            // positioning
            MsgForm.Top := CaretPoint.Y - MsgForm.Height - Editor.RowHeight;
            if MsgForm.Top < 0 then
              MsgForm.Top := CaretPoint.Y + Editor.RowHeight;
            MsgForm.Left := CaretPoint.X + 2;
            if (MsgForm.Left + MsgForm.Width) > Screen.Width then
              MsgForm.Left := Screen.Width - MsgForm.Width - 4;
            // display
            Choice := MsgForm.ShowModal;
          finally
            MsgForm.Free;
          end;

          case Choice of
            mrYes: ReplaceEditor;
            mrNo: ;
            mrCancel: Exit;
            mrAll:
              begin
                ReplaceEditor;
                Include(FSearchOptions, sfrReplaceAll);
                Exclude(FSearchOptions, sfrReplaceConfirm);
              end;
          end;
        end
        else
          ReplaceEditor;
        if not(sfrReplaceAll in FSearchOptions) then
          Exit;
      end;
    finally
      Editor.HitStyle := Style;
    end;
  end;
end;


// menu 表示 ////////////////////////////////////////////////////////

procedure TForm1.mnuEditorPropertyClick(Sender: TObject);
begin
  EditEditor(ActiveEditor, nil);
end;

procedure TForm1.RowColClick(Sender: TObject);
begin
  if Sender = RowCol1 then
    LineNumberMode := lmRow
  else
    LineNumberMode := lmLine;
end;



// menu ウィンドウ //////////////////////////////////////////////////

// 分割 /////////////////////////////////////////////////////////////

function TForm1.IsSplit: Boolean;
var
  I, Count: Integer;
begin
  Result := False;
  Count := 0;
  for I := 0 to PageControl1.ActivePage.ControlCount - 1 do
    if PageControl1.ActivePage.Controls[I] is TEditor then
    begin
      Inc(Count);
      if Count > 1 then
      begin
        Result := True;
        Exit;
      end;
    end;
end;

function TForm1.SecondEditor: TEditor;
var
  I: Integer;
begin
  Result := nil;
  if IsSplit then
    for I := PageControl1.ActivePage.ControlCount - 1 downto 0 do
      if PageControl1.ActivePage.Controls[I] is TEditor then
        begin
          Result := TEditor(PageControl1.ActivePage.Controls[I]);
          Exit;
        end;
end;

{$IFDEF COMP3_UP}
function TForm1.ActiveSplitter: TSplitter;
var
  I: Integer;
begin
  Result := nil;
  if IsSplit then
    for I := 0 to PageControl1.ActivePage.ControlCount - 1 do
      if PageControl1.ActivePage.Controls[I] is TSplitter then
      begin
        Result := TSplitter(PageControl1.ActivePage.Controls[I]);
        Exit;
      end;
end;

procedure TForm1.SplitterMoved(Sender: TObject);
begin
  if IsSplit then
    SecondEditor.Height := TSplitter(Sender).Top;
end;
{$ENDIF}

procedure TForm1.BeginSplit;
var
  Editor: TEditor;
  {$IFDEF COMP3_UP}
  Splitter: TSplitter;
  {$ENDIF}
begin
  if not IsSplit then
  begin
    Editor := TEditor.Create(Self);
    // TEditorProp によるプロパティ設定
    EditorProp1.Assign(ActiveEditor);
    EditorProp1.AssignTo(Editor);
    // TForm2.Editor1..Editor8 が分割された時のためにイベントハンドラを
    // 受け継ぐ
    AssignProperties(ActiveEditor, Editor, tkMethods);
    // OnCaretMoved, OnChange, OnEnter, OnSelectionModeChange
    // は TForm1 のモノにする
    AssignEvent(Editor);
    // Parent 他
    Editor.Parent := PageControl1.ActivePage;
    Editor.Align := alTop;
    Editor.Top := 0;
    Editor.Height := PageControl1.ActivePage.Height div 2;
    // 文字列オブジェクトの共有
    Editor.ExchangeList(ActiveEditor);
    Editor.TopRow := ActiveEditor.TopRow;
    ActiveEditor.TopRow := Editor.TopRow + Editor.RowCount;
    {$IFDEF COMP3_UP}
    Splitter := TSplitter.Create(Self);
    Splitter.Parent := PageControl1.ActivePage;
    Splitter.Align := alTop;
    Splitter.Top := Editor.Top + Editor.Height;
    Splitter.Cursor := crVSplit;
    Splitter.OnMoved := SplitterMoved;
    {$ENDIF}
  end;
end;

procedure TForm1.EndSplit;
begin
  if IsSplit then
  begin
    {$IFDEF COMP3_UP}
    ActiveSplitter.Free;
    {$ENDIF}
    SecondEditor.Free;
    PageControl1Change(Self);
  end;
end;

procedure TForm1.mnuSplitClick(Sender: TObject);
begin
  if IsSplit then
    EndSplit
  else
    BeginSplit;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  {$IFDEF COMP2}
  // フォームが破棄される時も実行されるので、PageControl1 へ
  // 手を伸ばす IsSplit 呼び出しには注意が必要。
  if not (csDestroying in ComponentState) and IsSplit then
    SecondEditor.Height := PageControl1.ActivePage.Height div 2;
  {$ENDIF}
end;


// 別窓 /////////////////////////////////////////////////////////////

procedure TForm1.mnuOtherWindowClick(Sender: TObject);
var
  Form: TForm1;
begin
  Form := TForm1.Create(Application);
  Form.CreateNewSheet(ActiveFileName);
  Form.Show;
  // TEditorProp によるプロパティ設定
  EditorProp1.Assign(ActiveEditor);
  EditorProp1.AssignTo(Form.ActiveEditor);
  // TForm2.Editor1..Editor8 の別窓を開いた時のためにイベントハンドラを
  // 受け継ぎ、一部を Form のハンドラに設定する
  AssignProperties(ActiveEditor, Form.ActiveEditor, tkMethods);
  Form.AssignEvent(Form.ActiveEditor);
  // 文字列オブジェクトの共有
  Form.ActiveEditor.ExchangeList(ActiveEditor);
end;

procedure TForm1.K4Click(Sender: TObject);
begin
  if ActiveEditor <> nil then
    with ActiveEditor do
    begin
      rm101.Checked := rm10 in ListRowMarks[Row];
      rm111.Checked := rm11 in ListRowMarks[Row];
      rm121.Checked := rm12 in ListRowMarks[Row];
      rm131.Checked := rm13 in ListRowMarks[Row];
      rm141.Checked := rm14 in ListRowMarks[Row];
      rm151.Checked := rm15 in ListRowMarks[Row];
    end;
end;

procedure TForm1.rm101Click(Sender: TObject);
var
  Mark: TRowMark;
begin
  if (Sender is TMenuItem) and (ActiveEditor <> nil) then
  begin
    Mark := TRowMark(TMenuItem(Sender).Tag); // 10..15
    with ActiveEditor do
      if TRowMark(TMenuItem(Sender).Tag) in ListRowMarks[Row] then
        DeleteRowMark(Row, Mark)
      else
        PutRowMark(Row, Mark);
  end;
end;

end.

