(*********************************************************************

  Property Editor & Component Editor for TFountain

  start  2001/03/12
  update 2001/07/25

  Copyright (c) 2001 本田勝彦 <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
**********************************************************************)

unit FountainEditor;

{$I heverdef.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, HEditor, StdCtrls, ColorGrd, ComCtrls, TypInfo, heUtils,
  heFountain, ExtCtrls, heColorManager;

type
  TFormFountainEditor = class(TForm)
    Button_Ok: TButton;
    Button_Cancel: TButton;
    Button_Help: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    ListBox_Colors: TListBox;
    Panel1: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    ColorGrid1: TColorGrid;
    Button_SameBkColor: TButton;
    Button_SameColor: TButton;
    Button_Samestyle: TButton;
    GroupBox_FontStyle: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Edit_LeftBracket: TEdit;
    Edit_RightBracket: TEdit;
    Button_BracketNew: TButton;
    Button_BracketUpdate: TButton;
    Button_BracketRemove: TButton;
    TabSheet2: TTabSheet;
    Editor_Reserve: TEditor;
    Button_ReserveLoad: TButton;
    Button_ReserveSave: TButton;
    Editor_FileExt: TEditor;
    Label5: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListBox_ColorsClick(Sender: TObject);
    procedure Edit_LeftBracketChange(Sender: TObject);
    procedure Button_BracketNewClick(Sender: TObject);
    procedure Button_BracketUpdateClick(Sender: TObject);
    procedure Button_BracketRemoveClick(Sender: TObject);
    procedure Button_OkClick(Sender: TObject);
    procedure Button_SameBkColorClick(Sender: TObject);
    procedure Button_SameColorClick(Sender: TObject);
    procedure Button_SamestyleClick(Sender: TObject);
    procedure Button_ReserveLoadClick(Sender: TObject);
    procedure Button_ReserveSaveClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button_HelpClick(Sender: TObject);
  private
    FFountain: TFountain;
    FColorManager: TEditorColorManager;
    procedure WMHelp(var Message: TMessage); message WM_HELP;
  public
    class function Execute(Fountain: TFountain): Boolean;
    function EditFountain(Fountain: TFountain): Boolean;
    procedure GetFountainItemProc(Instance: TObject; pInfo: PPropInfo;
      tInfo: PTypeInfo);
    function IsFountainColorItem(Index: Integer): Boolean;
    function IsBracket(Index: Integer): Boolean;
    function ActiveBracketItem: TFountainBracketItem;
    function ActiveFountainColor: TFountainColor;
    procedure NewFountainColor(FountainColor: TFountainColor);
    procedure UpdateBracketButtonEnabledChange;
    procedure UpdateBrackets;
    procedure UpdateFountainColors;
    procedure UpdateFountainColorsProc(Instance: TObject; pInfo: PPropInfo;
      tInfo: PTypeInfo);
  end;

function EditFountain(Fountain: TFountain): Boolean;

implementation

{$R *.DFM}

uses
  HPropUtils;

function EditFountain(Fountain: TFountain): Boolean;
begin
  Result := TFormFountainEditor.Execute(Fountain);
end;

class function TFormFountainEditor.Execute(Fountain: TFountain): Boolean;
var
  Form: TFormFountainEditor;
begin
  Result := False;
  if Fountain = nil then
    Exit;
  Form := TFormFountainEditor.Create(Application);
  try
    Result := Form.EditFountain(Fountain);
  finally
    Form.Free;
  end;
end;

function TFormFountainEditor.EditFountain(Fountain: TFountain): Boolean;
begin
  FFountain := Fountain;
  ListBox_Colors.Items.BeginUpdate;
  try
    ListBox_Colors.Items.Clear;
    EnumProperties(FFountain, tkProperties, GetFountainItemProc);
  finally
    ListBox_Colors.Items.EndUpdate;
  end;
  Editor_Reserve.Lines.Assign(Fountain.ReserveWordList);
  Editor_FileExt.Lines.Assign(Fountain.FileExtList);
  Result := ShowModal = mrOk;
end;

procedure TFormFountainEditor.GetFountainItemProc(Instance: TObject;
  pInfo: PPropInfo; tInfo: PTypeInfo);
var
  PropInstance: TObject;
  FountainColor: TFountainColor;
  BracketItem: TFountainBracketItem;
begin
  if tInfo.Kind = tkClass then
  begin
    // プロパティの実体を取得
    PropInstance := TObject(GetOrdProp(Instance, pInfo));
    if PropInstance is TFountainColor then
      // そいつが TFountainColor 型オブジェクトの場合だけ処理する
      if Instance is TFountainBracketItem then
      begin
        // プロパティの所有者が TFountainBracketItem の場合
        BracketItem := TFountainBracketItem.Create(nil);
        BracketItem.Assign(TFountainBracketItem(Instance));
        ListBox_Colors.Items.InsertObject(ListBox_Colors.Items.Count,
          BracketItem.LeftBracket + ' ' + BracketItem.RightBracket, BracketItem);
      end
      else
      begin
        FountainColor := TFountainColor.Create;
        FountainColor.Assign(TFountainColor(PropInstance));
        ListBox_Colors.Items.InsertObject(ListBox_Colors.Items.Count, pInfo.Name, FountainColor);
      end;
  end;
end;

function TFormFountainEditor.IsFountainColorItem(Index: Integer): Boolean;
begin
  Result := (Index >= 0) and (Index <= ListBox_Colors.Items.Count - 1) and
            (ListBox_Colors.Items.Objects[Index] is TFountainColorItem);
end;

function TFormFountainEditor.IsBracket(Index: Integer): Boolean;
begin
  Result := (Index >= 0) and (Index <= ListBox_Colors.Items.Count - 1) and
            (ListBox_Colors.Items.Objects[Index] is TFountainBracketItem);
end;

procedure TFormFountainEditor.FormCreate(Sender: TObject);
begin
  FColorManager := TEditorColorManager.Create(ColorGrid1, Panel1,
    Label4, Label3, CheckBox1, CheckBox2, CheckBox3);
end;

procedure TFormFountainEditor.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  FColorManager.Free;
  for I := 0 to ListBox_Colors.Items.Count - 1 do
    if IsBracket(I) then
      TFountainBracketItem(ListBox_Colors.Items.Objects[I]).Free
    else
      TFountainColor(ListBox_Colors.Items.Objects[I]).Free;
end;

procedure TFormFountainEditor.FormShow(Sender: TObject);
begin
  PageControl1.ActivePage := TabSheet1;
  ListBox_Colors.SetFocus;
  ListBox_Colors.ItemIndex := 0;
  NewFountainColor(ActiveFountainColor);
end;

procedure TFormFountainEditor.ListBox_ColorsClick(Sender: TObject);
begin
  NewFountainColor(ActiveFountainColor);
end;

function TFormFountainEditor.ActiveBracketItem: TFountainBracketItem;
var
  I: Integer;
begin
  I := ListBox_Colors.ItemIndex;
  if (I < 0) or not IsBracket(I) then
    Result := nil
  else
    Result := TFountainBracketItem(ListBox_Colors.Items.Objects[I]);
end;

function TFormFountainEditor.ActiveFountainColor: TFountainColor;
var
  I: Integer;
begin
  I := ListBox_Colors.ItemIndex;
  if I < 0 then
    Result := nil
  else
    if IsBracket(I) then
      Result := TFountainBracketItem(ListBox_Colors.Items.Objects[I]).ItemColor
    else
      Result := TFountainColor(ListBox_Colors.Items.Objects[I]);
end;

procedure TFormFountainEditor.NewFountainColor(FountainColor: TFountainColor);
var
  B: Boolean;
  LeftBracket, RightBracket: String;
begin
  FColorManager.FountainColor := FountainColor;
  // Button_BracketUpdate..6, Edit_LeftBracket..2
  B := IsBracket(ListBox_Colors.ItemIndex);
  Button_BracketRemove.Enabled := B;
  Edit_LeftBracket.Enabled := B;
  Edit_RightBracket.Enabled := B;
  if B then
  begin
    LeftBracket := ActiveBracketItem.LeftBracket;
    RightBracket := ActiveBracketItem.RightBracket;
  end
  else
  begin
    LeftBracket := '';
    RightBracket := '';
  end;
  Edit_LeftBracket.Text := LeftBracket;
  Edit_RightBracket.Text := RightBracket;
  UpdateBracketButtonEnabledChange; // Button_BracketUpdate
end;

procedure TFormFountainEditor.Edit_LeftBracketChange(Sender: TObject);
begin
  UpdateBracketButtonEnabledChange;
end;

procedure TFormFountainEditor.UpdateBracketButtonEnabledChange;
begin
  Button_BracketUpdate.Enabled := (Edit_LeftBracket.Text <> '') and (Edit_RightBracket.Text <> '');
end;

procedure TFormFountainEditor.Button_BracketNewClick(Sender: TObject);
var
  Item: TFountainBracketItem;
begin
  Item := TFountainBracketItem.Create(nil);
  ListBox_Colors.Items.InsertObject(ListBox_Colors.Items.Count, '', Item);
  ListBox_Colors.ItemIndex := ListBox_Colors.Items.Count - 1;
  NewFountainColor(ActiveFountainColor);
end;

procedure TFormFountainEditor.Button_BracketUpdateClick(Sender: TObject);
begin
  if IsBracket(ListBox_Colors.ItemIndex) then
    with ActiveBracketItem do
    begin
      LeftBracket := Edit_LeftBracket.Text;
      RightBracket := Edit_RightBracket.Text;
      ListBox_Colors.Items[ListBox_Colors.ItemIndex] := LeftBracket + ' ' + RightBracket;
      NewFountainColor(ItemColor);
    end;
end;

procedure TFormFountainEditor.Button_BracketRemoveClick(Sender: TObject);
var
  I: Integer;
begin
  I := ListBox_Colors.ItemIndex;
  if IsBracket(I) then
  begin
    ActiveBracketItem.Free;
    ListBox_Colors.Items.Delete(I);
    ListBox_Colors.ItemIndex := Min(I, ListBox_Colors.Items.Count - 1);
    NewFountainColor(ActiveFountainColor);
  end;
end;


// Samexxxx
procedure TFormFountainEditor.Button_SameBkColorClick(Sender: TObject);
var
  FountainColor: TFountainColor;
  B: TColor;
  I: Integer;
begin
  FountainColor := ActiveFountainColor;
  if FountainColor <> nil then
  begin
    B := FountainColor.BkColor;
    if MessageDlg('Change all BkColor to ' + ColorToString(B),
                  mtConfirmation, mbOkCancel, 0) = mrOk then
      for I := 0 to ListBox_Colors.Items.Count - 1 do
        if ListBox_Colors.Items[I] <> 'Select' then
          if IsFountainColorItem(I) then
            TFountainColorItem(ListBox_Colors.Items.Objects[I]).ItemColor.BkColor := B
          else
            TFountainColor(ListBox_Colors.Items.Objects[I]).BkColor := B;
  end;
end;

procedure TFormFountainEditor.Button_SameColorClick(Sender: TObject);
var
  FountainColor: TFountainColor;
  C: TColor;
  I: Integer;
begin
  FountainColor := ActiveFountainColor;
  if FountainColor <> nil then
  begin
    C := FountainColor.Color;
    if MessageDlg('Change all Color to ' + ColorToString(C),
                  mtConfirmation, mbOkCancel, 0) = mrOk then
      for I := 0 to ListBox_Colors.Items.Count - 1 do
        if ListBox_Colors.Items[I] <> 'Select' then
          if IsFountainColorItem(I) then
            TFountainColorItem(ListBox_Colors.Items.Objects[I]).ItemColor.Color := C
          else
            TFountainColor(ListBox_Colors.Items.Objects[I]).Color := C;
  end;
end;

procedure TFormFountainEditor.Button_SamestyleClick(Sender: TObject);
var
  FountainColor: TFountainColor;
  S: String;
  Style: TFontStyle;
  Styles: TFontStyles;
  I: Integer;
begin
  FountainColor := ActiveFountainColor;
  if FountainColor <> nil then
  begin
    Styles := FountainColor.Style;
    S := '';
    for Style := Low(TFontStyle) to High(TFontStyle) do
      if Style in Styles then
      begin
        if (S <> '') and (Style <> fsBold) then
          S := S + ', ';
        case Style of
          fsBold     : S := S + 'fsBold';
          fsItalic   : S := S + 'fsItalic';
          fsUnderline: S := S + 'fsUnderline';
          fsStrikeOut: S := S + 'fsStrikeOut';
        end;
      end;
    if MessageDlg('Change all Style to [ ' + S + ' ]',
                  mtConfirmation, mbOkCancel, 0) = mrOk then
      for I := 0 to ListBox_Colors.Items.Count - 1 do
        if ListBox_Colors.Items[I] <> 'Select' then
          if IsFountainColorItem(I) then
            TFountainColorItem(ListBox_Colors.Items.Objects[I]).ItemColor.Style := Styles
          else
            TFountainColor(ListBox_Colors.Items.Objects[I]).Style := Styles;
  end;
end;

// ReserveWordList
procedure TFormFountainEditor.Button_ReserveLoadClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    Editor_Reserve.Lines.LoadFromFile(OpenDialog1.FileName);
end;

procedure TFormFountainEditor.Button_ReserveSaveClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
    Editor_Reserve.Lines.SaveToFile(SaveDialog1.FileName);
end;


// Button OK
procedure TFormFountainEditor.Button_OkClick(Sender: TObject);
begin
  FFountain.NotifyEventList.Beginupdate;
  try
    UpdateBrackets;
    UpdateFountainColors;
    FFountain.ReserveWordList.Assign(Editor_Reserve.Lines);
    FFountain.FileExtList.Assign(Editor_FileExt.Lines);
  finally
    FFountain.NotifyEventList.EndUpdate;
  end;
end;

procedure TFormFountainEditor.UpdateBrackets;
var
  I: Integer;
begin
  FFountain.Brackets.Clear;
  for I := 0 to ListBox_Colors.Items.Count - 1 do
    if IsBracket(I) then
      FFountain.Brackets.Add.Assign(TFountainBracketItem(ListBox_Colors.Items.Objects[I]));
end;

procedure TFormFountainEditor.UpdateFountainColors;
begin
  EnumProperties(FFountain, tkProperties, UpdateFountainColorsProc);
end;

procedure TFormFountainEditor.UpdateFountainColorsProc(Instance: TObject;
  pInfo: PPropInfo; tInfo: PTypeInfo);
var
  PropInstance: TObject;
  I: Integer;
begin
  if (tInfo.Kind = tkClass) and not (Instance is TFountainColorItem) then
  begin
    PropInstance := TObject(GetOrdProp(Instance, pInfo));
    if PropInstance is TFountainColor then
    begin
      I := ListBox_Colors.Items.IndexOf(pInfo.Name);
      if I > -1 then
        TFountainColor(PropInstance).Assign(TFountainColor(ListBox_Colors.Items.Objects[I]));
    end;
  end;
end;

procedure TFormFountainEditor.Button_HelpClick(Sender: TObject);
begin
  WinHelp(Handle, PChar('HEdit.hlp'), HELP_FINDER, 0);
end;

procedure TFormFountainEditor.WMHelp(var Message: TMessage);
var
  Control: TWinControl;
  ContextID: Integer;
  Buf: array[0..1] of Longint;
begin
  if TWMHelp(Message).HelpInfo.iContextType = HELPINFO_WINDOW then
  with PHelpInfo(Message.LParam)^ do
  begin
    Control := FindControl(hItemHandle);
    if (Control <> nil) and (Control.HelpContext <> 0) then
    begin
      ContextID := Control.HelpContext;
      Buf[0] := hItemHandle;
      Buf[1] := ContextID;
      { HELP_CONTEXTMENU or HELP_WM_HELP needs cotrol handle }
      WinHelp(hItemHandle, PChar('HEdit.hlp'), HELP_WM_HELP, Integer(@Buf[0]));
    end;
  end;
end;

end.

