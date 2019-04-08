
{********************************************************************}
{                                                                    }
{    TStrings Property Editor by TEditor                             }
{                                                                    }
{    start  1998/08/19                                               }
{                                                                    }
{    update 2001/10/19                                               }
{                                                                    }
{    Copyright (c) 1999 本田勝彦 <katsuhiko.honda@nifty.ne.jp>       }
{                                                                    }
{********************************************************************}

unit HStrProp;

{$I heverdef.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Menus, HEditor, ExtCtrls, ComCtrls,
  Clipbrd, HtSearch, HEdtProp, heClasses;

type
  TOpenMenuList = class;
  TFileList = class;

  TFormStringsEditor = class(TForm)
    PopupMenu1: TPopupMenu;
    mnuCut: TMenuItem;
    mnuCopy: TMenuItem;
    mnuPaste: TMenuItem;
    mnuDelete: TMenuItem;
    mnuSelectAll: TMenuItem;
    mnuReadFile: TMenuItem;
    mnuSaveAs: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    mnuLineDelete: TMenuItem;
    mnuUndo: TMenuItem;
    mnuRedo: TMenuItem;
    StatusBar1: TStatusBar;
    PageControl1: TPageControl;
    Panel1: TPanel;
    btnOk: TSpeedButton;
    btnCancel: TSpeedButton;
    btnOpenFile: TSpeedButton;
    btnSave: TSpeedButton;
    btnCopy: TSpeedButton;
    btnCut: TSpeedButton;
    btnPaste: TSpeedButton;
    btnUndo: TSpeedButton;
    btnRedo: TSpeedButton;
    btnFind: TSpeedButton;
    btnFindDown: TSpeedButton;
    btnFineUp: TSpeedButton;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    btnReplace: TSpeedButton;
    mnuOverWrite: TMenuItem;
    mnuSave: TMenuItem;
    mnuFind: TMenuItem;
    TabSheet1: TTabSheet;
    mnuFindF: TMenuItem;
    mnuFindB: TMenuItem;
    mnuReplace: TMenuItem;
    PopupMenu2: TPopupMenu;
    mnuRowCol: TMenuItem;
    btnFileList: TSpeedButton;
    mnuFile: TMenuItem;
    mnuEdit: TMenuItem;
    mnuSearch: TMenuItem;
    mnuRowColDisplay: TMenuItem;
    mnuLinesChar: TMenuItem;
    mnuClose: TMenuItem;
    N1: TMenuItem;
    N3: TMenuItem;
    Editor1: TEditor;
    btnProp: TSpeedButton;
    Bevel5: TBevel;
    EditorProp1: TEditorProp;
    EditorProp2: TEditorProp;
    mnuIndent: TMenuItem;
    mnuUnIndent: TMenuItem;
    mnuBoxPaste: TMenuItem;
    mnuBoxSelMode: TMenuItem;
    N2: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure EditorChange(Sender: TObject);
    procedure CaretMoved(Sender: TObject);
    procedure mnuCutClick(Sender: TObject);
    procedure mnuCopyClick(Sender: TObject);
    procedure mnuPasteClick(Sender: TObject);
    procedure mnuDeleteClick(Sender: TObject);
    procedure mnuSelectAllClick(Sender: TObject);
    procedure mnuReadFileClick(Sender: TObject);
    procedure mnuSaveAsClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure mnuLineDeleteClick(Sender: TObject);
    procedure mnuUndoClick(Sender: TObject);
    procedure mnuRedoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure mnuOverWriteClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure mnuSaveClick(Sender: TObject);
    procedure mnuRowColClick(Sender: TObject);
    procedure btnFileListClick(Sender: TObject);
    procedure mnuCloseClick(Sender: TObject);
    procedure mnuFindClick(Sender: TObject);
    procedure mnuFindFClick(Sender: TObject);
    procedure mnuFindBClick(Sender: TObject);
    procedure mnuReplaceClick(Sender: TObject);
    procedure btnPropClick(Sender: TObject);
    procedure mnuIndentClick(Sender: TObject);
    procedure mnuUnIndentClick(Sender: TObject);
    procedure mnuBoxSelModeClick(Sender: TObject);
    procedure mnuBoxPasteClick(Sender: TObject);
    procedure SelectionModeChange(Sender: TObject);
  private
    FOpenMenuList: TOpenMenuList;
    FSearchValue: String;
    FSearchOptions: TSearchOptions;
    FReplaceValue: String;
    procedure ReadReg;
    procedure WriteReg;
    procedure WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    procedure CreateNewSheet;
    function GetEditor: TEditor;
    procedure MenuListSelected(Sender: TObject);
    function Search: Boolean;
  public
    FFileList: TFileList;
  end;

  TOpenMenuList = class(TStringList)
  public
    FOnClickProc: TNotifyEvent;
    FPopupMenu: TPopupMenu;
    FForm: TFormStringsEditor;
    constructor Create(OnClickProc: TNotifyEvent; PopupMenu: TPopupMenu;
      Form: TFormStringsEditor);
    destructor Destroy; override;
    procedure BringToTop(const S: String);
    procedure RecreateMenu;
    procedure ReadReg;
    procedure WriteReg;
  end;

  TFileList = class(TStringList)
  protected
    FForm: TFormStringsEditor;
    procedure Put(Index: Integer; const S: string); override;
  public
    constructor Create(Form: TFormStringsEditor);
    function Add(const S: string): Integer; override;
    procedure Delete(Index: Integer); override;
  end;

implementation

{$R *.DFM}

uses
  Registry, HSchfm, HReplfm, HViewEdt, heStrConsts;

const
  RegRoot = '\Software\katsuhiko.honda\Delphi\TStrings Property Editor';

{  TOpenMenuList  }

constructor TOpenMenuList.Create(OnClickProc: TNotifyEvent;
  PopupMenu: TPopupMenu; Form: TFormStringsEditor);
begin
  FOnClickProc := OnClickProc;
  FPopupMenu := PopupMenu;
  FForm := Form;
  ReadReg;
  RecreateMenu;
end;

destructor TOpenMenuList.Destroy;
var
  I: Integer;
begin
  WriteReg;
  for I := FPopupMenu.Items.Count - 1 downto 0 do
    FPopupMenu.Items[I].Free;
  inherited Destroy;
end;

procedure TOpenMenuList.BringToTop(const S: String);
begin
  if IndexOf(S) <> -1 then
    Delete(IndexOf(S));
  Insert(0, S);
  if Count > 16 then
    Delete(Count - 1);
  RecreateMenu;
end;

procedure TOpenMenuList.RecreateMenu;
var
  I: Integer;
  Item: TMenuItem;
begin
  for I := FPopupMenu.Items.Count - 1 downto 0 do
    FPopupMenu.Items[I].Free;
  for I := 0 to Count - 1 do
  begin
    Item := TMenuItem.Create(FPopupMenu);
    Item.Caption := Strings[I];
    Item.OnClick := FOnClickProc;
    FPopupMenu.Items.Add(Item);
  end;
  FForm.btnFileList.Enabled :=
    FForm.PopupMenu2.Items.Count <> 0;
end;

procedure TOpenMenuList.ReadReg;
var
  Reg: TRegIniFile;
begin
  Reg := TRegIniFile.Create(RegRoot);
  try
    Text := Reg.ReadString('OpenFileList', 'Text', '');
  finally
    Reg.Free;
  end;
end;

procedure TOpenMenuList.WriteReg;
var
  Reg: TRegIniFile;
begin
  Reg := TRegIniFile.Create(RegRoot);
  try
    Reg.WriteString('OpenFileList', 'Text', Text);
  finally
    Reg.Free;
  end;
end;

{  TFileList  }

constructor TFileList.Create(Form: TFormStringsEditor);
begin
  FForm := Form;
end;

function TFileList.Add(const S: string): Integer;
begin
  Result := inherited Add(S);
  if Count > 1 then
  begin
    FForm.CreateNewSheet;
    with FForm.GetEditor do
    begin
      Lines.LoadFromFile(S);
      Modified := False;
      Row := 0;
      Col := 0;
    end;
  end;
  FForm.PageControl1.ActivePage.Caption := ExtractFileName(S);
  if FForm.Visible then
    FForm.PageControl1Change(FForm);
end;

procedure TFileList.Delete(Index: Integer);
begin
  if Index > 0 then
  begin
    inherited Delete(Index);
    with FForm, FForm.PageControl1 do
    begin
      GetEditor.Free;
      ActivePage.Free;
      if Count > 0 then
        ActivePage := Pages[Index - 1];
      PageControl1Change(Self);
    end;
  end;
end;

procedure TFileList.Put(Index: Integer; const S: string);
begin
  if Index > 0 then
  begin
    inherited Put(Index, S);
    FForm.PageControl1.ActivePage.Caption := ExtractFileName(S);
    FForm.PageControl1Change(FForm);
  end;
end;


{  TFormStringsEditor  }

procedure TFormStringsEditor.CreateNewSheet;
var
  Sheet: TTabSheet;
  NewEditor: TEditor;
begin
  Sheet := TTabSheet.Create(Self);
  Sheet.PageControl := PageControl1;
  NewEditor := TEditor.Create(Self);
  NewEditor.Parent := Sheet;
  NewEditor.Width := Sheet.Width;
  NewEditor.Height := Sheet.Height;
  NewEditor.Align := alClient;
  NewEditor.PopupMenu := PopupMenu1;
  NewEditor.OnChange := EditorChange;
  NewEditor.OnCaretMoved := CaretMoved;
  NewEditor.OnSelectionModeChange := SelectionModeChange;
  EditorProp2.AssignTo(NewEditor);
  with PageControl1 do ActivePage := Pages[PageCount - 1];
end;

function TFormStringsEditor.GetEditor: TEditor;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to PageControl1.ActivePage.ControlCount - 1 do
    if PageControl1.ActivePage.Controls[I] is TEditor then
    begin
      Result := PageControl1.ActivePage.Controls[I] as TEditor;
      Exit;
    end;
end;

procedure TFormStringsEditor.MenuListSelected(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    FFileList.Add(TMenuItem(Sender).Caption);
    FOpenMenuList.BringToTop(TMenuItem(Sender).Caption);
  end;
end;

procedure TFormStringsEditor.FormCreate(Sender: TObject);
begin
  FFileList := TFileList.Create(Self);
  FOpenMenuList := TOpenMenuList.Create(MenuListSelected, PopupMenu2, Self);
  ReadReg;
end;

procedure TFormStringsEditor.FormDestroy(Sender: TObject);
begin
  FFileList.Free;
  FOpenMenuList.Free;
  WriteReg;
end;

procedure TFormStringsEditor.FormShow(Sender: TObject);
begin
  EditorProp2.ReadReg(RegRoot, 'Property', 'EditorProp');
  Editor1.Modified := False;
  PageControl1Change(Self);
  Editor1.SelStart := Editor1.GetTextLen;
end;

procedure TFormStringsEditor.btnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TFormStringsEditor.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFormStringsEditor.WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);
var
  X, Y: Integer;
begin
  X := 514;
  Y := 300;
  Msg.MinMaxInfo^.ptMinTrackSize:= Point(X, Y);
end;

procedure TFormStringsEditor.PageControl1Change(Sender: TObject);
begin
  GetEditor.SetFocus;
  Caption := FFileList[PageControl1.ActivePage.PageIndex];
  CaretMoved(Self);
  StatusBar1.Panels[1].Text := IntToStr(GetEditor.Lines.Count) + StrProp_Line; // '  行';
  if GetEditor.Modified then
    StatusBar1.Panels[2].Text := StrProp_Modified // '変更'
  else
    StatusBar1.Panels[2].Text := '';
  if GetEditor.OverWrite then
    StatusBar1.Panels[3].Text := StrProp_Overwrite // '上書き'
  else
    StatusBar1.Panels[3].Text := StrProp_Insert; // '挿入';
  SelectionModeChange(GetEditor);
  btnSave.Enabled := (PageControl1.ActivePage <> TabSheet1) and
                     GetEditor.Modified;
  btnUndo.Enabled := GetEditor.CanUndo;
  btnRedo.Enabled := GetEditor.CanRedo;
  btnProp.Enabled := PageControl1.ActivePage <> TabSheet1;
end;

procedure TFormStringsEditor.CaretMoved(Sender: TObject);
begin
  with GetEditor do
    if mnuRowCol.Checked then
      StatusBar1.Panels[0].Text :=
        Format('[ %5d:%4d ]', [Row + 1, Col + 1])
    else
      StatusBar1.Panels[0].Text :=
        Format('[ %5d:%4d ]', [RowToLines(Row) + 1, ColToChar(Row, Col) + 1]);
end;

procedure TFormStringsEditor.EditorChange(Sender: TObject);
begin
  StatusBar1.Panels[1].Text := IntToStr(GetEditor.Lines.Count) + StrProp_Line; // '  行';
  StatusBar1.Panels[2].Text := StrProp_Modified; // '変更';
  btnSave.Enabled := (PageControl1.ActivePage <> TabSheet1) and
                     (GetEditor.Modified);
  btnUndo.Enabled := GetEditor.CanUndo;
  btnRedo.Enabled := GetEditor.CanRedo;
end;

procedure TFormStringsEditor.SelectionModeChange(Sender: TObject);
begin
  if Sender is TEditor then
    if (Sender as TEditor).SelectionMode = smBox then
      StatusBar1.Panels[4].Text := StrProp_Box // '矩形'
    else
      StatusBar1.Panels[4].Text := '';
end;

procedure TFormStringsEditor.PopupMenu1Popup(Sender: TObject);
var
  Sel: Boolean;
begin
  Sel := GetEditor.SelLength > 0;
  mnuCut.Enabled := Sel;
  mnuCopy.Enabled := Sel;
  mnuDelete.Enabled := Sel;
  mnuUndo.Enabled := GetEditor.CanUndo;
  mnuRedo.Enabled := GetEditor.CanRedo;
  mnuPaste.Enabled := Clipboard.HasFormat(CF_TEXT);
  mnuBoxPaste.Enabled := Clipboard.HasFormat(CF_TEXT);
  mnuOverWrite.Checked := GetEditor.OverWrite;
  mnuSave.Enabled := PageControl1.ActivePage <> TabSheet1;
  mnuClose.Enabled := PageControl1.ActivePage <> TabSheet1;
  mnuIndent.Enabled := Sel;
  mnuUnIndent.Enabled := Sel;
end;

procedure TFormStringsEditor.mnuCutClick(Sender: TObject);
begin
  GetEditor.CutToClipboard;
end;

procedure TFormStringsEditor.mnuCopyClick(Sender: TObject);
begin
  GetEditor.CopyToClipboard;
end;

procedure TFormStringsEditor.mnuPasteClick(Sender: TObject);
begin
  GetEditor.PasteFromClipboard;
end;

procedure TFormStringsEditor.mnuBoxPasteClick(Sender: TObject);
begin
  if Clipboard.HasFormat(CF_TEXT) then
    GetEditor.SetSelTextBox(PChar(Clipboard.AsText));
end;

procedure TFormStringsEditor.mnuDeleteClick(Sender: TObject);
begin
  GetEditor.SelText := '';
end;

procedure TFormStringsEditor.mnuSelectAllClick(Sender: TObject);
begin
  GetEditor.SelectAll;
end;

procedure TFormStringsEditor.mnuLineDeleteClick(Sender: TObject);
begin
  GetEditor.DeleteRow(GetEditor.Row);
end;

procedure TFormStringsEditor.mnuReadFileClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    FFileList.Add(OpenDialog1.FileName);
    FOpenMenuList.BringToTop(OpenDialog1.FileName);
  end;
end;

procedure TFormStringsEditor.mnuSaveClick(Sender: TObject);
begin
  if (PageControl1.ActivePage <> TabSheet1) and GetEditor.Modified then
  begin
    GetEditor.Lines.SaveToFile(
      FFileList[PageControl1.ActivePage.PageIndex]);
    GetEditor.Modified := False;
    PageControl1Change(Self);
  end;
end;

procedure TFormStringsEditor.mnuSaveAsClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    GetEditor.Lines.SaveToFile(SaveDialog1.FileName);
    if PageControl1.ActivePage <> TabSheet1 then
      FFileList[PageControl1.ActivePage.PageIndex] := SaveDialog1.FileName;
    FOpenMenuList.BringToTop(SaveDialog1.FileName);
  end;
end;

procedure TFormStringsEditor.mnuCloseClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := PageControl1.ActivePage.PageIndex;
  if Index = 0 then
    Exit;
  FFileList.Delete(Index);
end;

procedure TFormStringsEditor.mnuUndoClick(Sender: TObject);
begin
  GetEditor.Undo;
  btnUndo.Enabled := GetEditor.CanUndo;
  btnRedo.Enabled := GetEditor.CanRedo;
end;

procedure TFormStringsEditor.mnuRedoClick(Sender: TObject);
begin
  GetEditor.Redo;
  btnUndo.Enabled := GetEditor.CanUndo;
  btnRedo.Enabled := GetEditor.CanRedo;
end;

procedure TFormStringsEditor.mnuIndentClick(Sender: TObject);
begin
  GetEditor.SelIndent;
end;

procedure TFormStringsEditor.mnuUnIndentClick(Sender: TObject);
begin
  GetEditor.SelUnIndent;
end;

procedure TFormStringsEditor.mnuBoxSelModeClick(Sender: TObject);
begin
  mnuBoxSelMode.Checked := not mnuBoxSelMode.Checked;
  GetEditor.SelectionMode := TEditorSelectionMode(Byte(mnuBoxSelMode.Checked));
end;

procedure TFormStringsEditor.mnuOverWriteClick(Sender: TObject);
begin
  GetEditor.OverWrite := not GetEditor.OverWrite;
end;

procedure TFormStringsEditor.mnuRowColClick(Sender: TObject);
begin
  if Sender = mnuRowCol then
  begin
    mnuRowCol.Checked := True;
    mnuLinesChar.Checked := False;
  end
  else
  begin
    mnuRowCol.Checked := False;
    mnuLinesChar.Checked := True;
  end;
  CaretMoved(Self);
end;

procedure TFormStringsEditor.btnFileListClick(Sender: TObject);
var
  P: TPoint;
begin
  P := Point(btnOpenFile.Left, btnOpenFile.Top + btnOpenFile.Height);
  Windows.ClientToScreen(Handle, P);
  PopupMenu2.Popup(P.X - 1, P.Y);
end;

function TFormStringsEditor.Search: Boolean;
var
  Info: TSearchInfo;
begin
  Result := False;
  with GetEditor do
  begin
    Info.Start := SelStart;
    Info.Length := SelLength;
    // cf HTSearch.pas
    if SearchText(PChar(Lines.Text),
                  Info, FSearchValue, FSearchOptions) then
    begin
      SelStart := Info.Start;
      SelLength := Info.Length;
      if Row - TopRow > RowCount * 4 div 5 then
        TopRow := Row - RowCount div 3
      else
        if Row - TopRow < RowCount div 5 then
          TopRow := Row - RowCount div 3;
      Result := True;
    end
    else
      ShowMessage(StrProp_SearchString + FSearchValue + ' ''' + #13#10 +
                  StrProp_Isnotfound);
      // ShowMessage('検索文字列　'' ' + FSearchValue + ' ''' + #13#10 +
      //             'は見つかりませんでした。');
  end;
end;

procedure TFormStringsEditor.mnuFindClick(Sender: TObject);
begin
  if TFormSearch.Execute(FSearchValue, FSearchOptions) then
    Search;
end;

procedure TFormStringsEditor.mnuFindFClick(Sender: TObject);
begin
  if FSearchValue <> '' then
  begin
    Include(FSearchOptions, sfrDown);
    Search;
  end;
end;

procedure TFormStringsEditor.mnuFindBClick(Sender: TObject);
begin
  if FSearchValue <> '' then
  begin
    Exclude(FSearchOptions, sfrDown);
    Search;
  end;
end;

procedure TFormStringsEditor.mnuReplaceClick(Sender: TObject);
var
  Editor: TEditor;
  CaretPoint: TPoint;
  MsgForm: TForm;
  Choice: Word;

  procedure ReplaceEditor;
  begin
    Editor.SelText := FReplaceValue;
  end;

begin
  if TFormReplace.Execute(
       FSearchValue, FReplaceValue, FSearchOptions) then
  begin
    Editor := GetEditor;
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
            ''' ' + FSearchValue + ' ''' + StrProp_To + #13#10+
            ''' ' + FReplaceValue + ' ''' + StrProp_Doreplace,
            mtConfirmation, [mbYes, mbNo, mbCancel, mbAll]);

          // CreateMessageDialog(
          //   ''' ' + FSearchValue + ' ''' + '  を' + #13#10+
          //   ''' ' + FReplaceValue + ' ''' + '  に 置き換えますか？',
          //   mtConfirmation, [mbYes, mbNo, mbCancel, mbAll]);

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
  end;
end;

procedure TFormStringsEditor.ReadReg;
var
  Reg: TRegIniFile;
begin
  Reg := TRegIniFile.Create(RegRoot);
  try
    Top := Reg.ReadInteger('Position', 'Top', 0);
    Left := Reg.ReadInteger('Position', 'Left', 0);
    Height := Reg.ReadInteger('Position', 'Height', 300);
    Width := Reg.ReadInteger('Position', 'Width', 514);
  finally
    Reg.Free;
  end;
end;

procedure TFormStringsEditor.WriteReg;
var
  Reg: TRegIniFile;
begin
  Reg := TRegIniFile.Create(RegRoot);
  try
    Reg.WriteInteger('Position', 'Top', Top);
    Reg.WriteInteger('Position', 'Left', Left);
    Reg.WriteInteger('Position', 'Height', Height);
    Reg.WriteInteger('Position', 'Width', Width);
  finally
    Reg.Free;
  end;
end;

procedure TFormStringsEditor.btnPropClick(Sender: TObject);
begin
  if EditEditor(GetEditor, nil) then
  begin
    EditorProp2.Assign(GetEditor);
    EditorProp2.WriteReg(RegRoot, 'Property', 'EditorProp');
    btnUndo.Enabled := GetEditor.CanUndo;
    btnRedo.Enabled := GetEditor.CanRedo;
  end;
end;

end.
