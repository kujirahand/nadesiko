
{********************************************************************}
{                                                                    }
{    Property Editor & Component Editor for TEditor & TEditorProp    }
{                                                                    }
{    start  1999/06/20                                               }
{                                                                    }
{    update 2001/11/23                                               }
{                                                                    }
{    Copyright (c) 1999, 2001 本田勝彦 <katsuhiko.honda@nifty.ne.jp> }
{                                                                    }
{********************************************************************}

unit HViewEdt;

{$I heverdef.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ColorGrd, StdCtrls, ExtCtrls, ComCtrls, Buttons, Spin,
  Menus, Clipbrd, heClasses, heFountain, EditorFountain, HEditor,
  HEdtProp, heUtils, heColorManager;

type
  TFormViewEditor = class(TForm)
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    PopupMenu1: TPopupMenu;
    Undo1: TMenuItem;
    Redo1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    DeleteRow1: TMenuItem;
    EditorProp1: TEditorProp;
    Button_Ok: TButton;
    Button_Cancel: TButton;
    Button_Help: TButton;
    // PageControl1
    PageControl1: TPageControl;
    // TabSheet1
    TabSheet1: TTabSheet;
    Label11: TLabel;
    Label12: TLabel;
    CheckBox_TrueType: TCheckBox;
    ListBox_FontName: TListBox;
    Edit_FontSize: TEdit;
    ListBox_FontSize: TListBox;
    Editor_FontSample: TEditor;
    RadioGroup_ScrollBars: TRadioGroup;
    GroupBox_FileExt: TGroupBox;
    Editor_FileExt: TEditor;
    GroupBox_TEditorSpeed: TGroupBox;
    CheckBox_InitBracketsFull: TCheckBox;
    Label32: TLabel;
    SpinEdit_CaretVerticalAc: TSpinEdit;
    Label33: TLabel;
    SpinEdit_PageVerticalRange: TSpinEdit;
    Label34: TLabel;
    SpinEdit_PageVerticalRangeAc: TSpinEdit;
    // TabSheet2
    TabSheet2: TTabSheet;
    GroupBox_TEditorCaret: TGroupBox;
    CheckBox_FreeCaret: TCheckBox;
    CheckBox_AutoIndent: TCheckBox;
    CheckBox_BackSpaceUnIndent: TCheckBox;
    CheckBox_InTab: TCheckBox;
    CheckBox_KeepCaret: TCheckBox;
    CheckBox_LockScroll: TCheckBox;
    CheckBox_NextLine: TCheckBox;
    CheckBox_TabIndent: TCheckBox;
    CheckBox_PrevSpaceIndent: TCheckBox;
    CheckBox_SoftTab: TCheckBox;
    Label10: TLabel;
    SpinEdit_TabSpaceCount: TSpinEdit;
    RadioGroup_TEditorCaretStyle: TRadioGroup;
    CheckBox_RowSelect: TCheckBox;
    CheckBox_SelMove: TCheckBox;
    RadioGroup_SelDragMode: TRadioGroup;
    CheckBox_AutoCursor: TCheckBox;
    GroupBox_TEditorCursors: TGroupBox;
    Label_DefaultCursor: TLabel;
    Label_DragSelCursor: TLabel;
    Label_DragSelCopyCursor: TLabel;
    Label_InSelCursor: TLabel;
    Label_LeftMarginCursor: TLabel;
    Label_TopMarginCursor: TLabel;
    ComboBox_DefaultCursor: TComboBox;
    ComboBox_DragSelCursor: TComboBox;
    ComboBox_DragSelCopyCursor: TComboBox;
    ComboBox_InSelCursor: TComboBox;
    ComboBox_LeftMarginCursor: TComboBox;
    ComboBox_TopMarginCursor: TComboBox;
    Editor_SelMove: TEditor;
    // TabSheet3
    TabSheet3: TTabSheet;
    ListBox_Colors: TListBox;
    Panel1: TPanel;
    Label26: TLabel;
    Label27: TLabel;
    ColorGrid_Colors: TColorGrid;
    GroupBox_ColorsStyle: TGroupBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox15: TCheckBox;
    Button_ColorsSameBkColor: TButton;
    Button_ColorsSameColor: TButton;
    Button_ColorsSameStyle: TButton;
    GroupBox_TEditorMarks: TGroupBox;
    CheckBox_RetMark: TCheckBox;
    CheckBox_EofMark: TCheckBox;
    CheckBox_WrapMark: TCheckBox;
    CheckBox_UnderLine: TCheckBox;
    CheckBox_Mail: TCheckBox;
    CheckBox_Url: TCheckBox;
    CheckBox_ControlCode: TCheckBox;
    Label7: TLabel;
    Label6: TLabel;
    Label5: TLabel;
    Edit_HexPrefix: TEdit;
    Edit_Quotation: TEdit;
    Edit_Commenter: TEdit;
    RadioGroup_HitStyle: TRadioGroup;
    Editor_Colors: TEditor;
    // TabSheet4
    TabSheet4: TTabSheet;
    ListBox_Ruler: TListBox;
    Panel3: TPanel;
    Label30: TLabel;
    Label31: TLabel;
    ColorGrid_Ruler: TColorGrid;
    GroupBox_TEditorRuler: TGroupBox;
    CheckBox_RulerVisible: TCheckBox;
    CheckBox_RulerEdge: TCheckBox;
    RadioGroup_GaugeRange: TRadioGroup;
    GroupBox_TEditorMargin: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    SpinEdit_MarginTop: TSpinEdit;
    SpinEdit_MarginLeft: TSpinEdit;
    SpinEdit_MarginLine: TSpinEdit;
    SpinEdit_MarginCharacter: TSpinEdit;
    GroupBox_TEditorImagebar: TGroupBox;
    CheckBox_ImagebarVisible: TCheckBox;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    SpinEdit_ImagebarDigitWidth: TSpinEdit;
    SpinEdit_ImagebarMarkWidth: TSpinEdit;
    SpinEdit_ImagebarLeftmargin: TSpinEdit;
    SpinEdit_ImagebarRightMargin: TSpinEdit;
    GroupBox_TEditorLeftbar: TGroupBox;
    CheckBox_LeftbarVisible: TCheckBox;
    CheckBox_LeftbarEdge: TCheckBox;
    CheckBox_LeftbarShowNumber: TCheckBox;
    CheckBox_LeftbarZeroBase: TCheckBox;
    CheckBox_LeftbarZeroLead: TCheckBox;
    RadioGroup_LeftbarShowNumberMode: TRadioGroup;
    Label22: TLabel;
    SpinEdit_LeftbarColumn: TSpinEdit;
    Label23: TLabel;
    SpinEdit_LeftbarLeftMargin: TSpinEdit;
    Label24: TLabel;
    SpinEdit_LeftbarRightMargin: TSpinEdit;
    Editor_Ruler: TEditor;
    // TabSheet5
    TabSheet5: TTabSheet;
    ListBox_Brackets: TListBox;
    Panel2: TPanel;
    Label28: TLabel;
    Label29: TLabel;
    ColorGrid_Brackets: TColorGrid;
    GroupBox_BracketsStyle: TGroupBox;
    CheckBox17: TCheckBox;
    CheckBox19: TCheckBox;
    CheckBox18: TCheckBox;
    Button_BracketsSameBkColor: TButton;
    Button_BracketsSameColor: TButton;
    Button_BracketsSameStyle: TButton;
    Button_BracketsNew: TButton;
    Button_BracketsRemove: TButton;
    Label8: TLabel;
    Label9: TLabel;
    Edit_LeftBracket: TEdit;
    Edit_RightBracket: TEdit;
    Button_BracketsUpdate: TButton;
    Editor_Brackets: TEditor;
    // TabSheet6
    TabSheet6: TTabSheet;
    Editor_Reserve: TEditor;
    Button_ReserveLoad: TButton;
    Button_ReserveSave: TButton;
    // TabSheet7
    TabSheet7: TTabSheet;
    CheckBox_WordWrap: TCheckBox;
    GroupBox_TEditorWrapOption: TGroupBox;
    CheckBox_FollowPunctuation: TCheckBox;
    CheckBox_FollowRetMark: TCheckBox;
    CheckBox_Leading: TCheckBox;
    CheckBox_WordBreak: TCheckBox;
    Label16: TLabel;
    SpinEdit_WrapByte: TSpinEdit;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Edit_FollowStr: TEdit;
    Edit_LeadStr: TEdit;
    Edit_PunctuationStr: TEdit;
    SpeedButton_FollowStrDefault: TSpeedButton;
    SpeedButton_LeadStrDefault: TSpeedButton;
    SpeedButton_PunctuationStrDefault: TSpeedButton;
    CheckBox_HideMark: TCheckBox;
    Label21: TLabel;
    Label25: TLabel;
    CheckBox_FreeRow: TCheckBox;
    // end of control
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure CheckBox_TrueTypeClick(Sender: TObject);
    procedure ListBox_FontNameClick(Sender: TObject);
    procedure ListBox_FontSizeClick(Sender: TObject);
    procedure Edit_FontSizeChange(Sender: TObject);
    procedure CheckBox_FreeCaretClick(Sender: TObject);
    procedure CheckBox_AutoIndentClick(Sender: TObject);
    procedure CheckBox_InTabClick(Sender: TObject);
    procedure CheckBox_LockScrollClick(Sender: TObject);
    procedure CheckBox_NextLineClick(Sender: TObject);
    procedure CheckBox_TabIndentClick(Sender: TObject);
    procedure CheckBox_PrevSpaceIndentClick(Sender: TObject);
    procedure CheckBox_SoftTabClick(Sender: TObject);
    procedure SpinEdit_TabSpaceCountChange(Sender: TObject);
    procedure RadioGroup_TEditorCaretStyleClick(Sender: TObject);
    procedure ListBox_ColorsClick(Sender: TObject);
    procedure Edit_HexPrefixChange(Sender: TObject);
    procedure Edit_QuotationChange(Sender: TObject);
    procedure Edit_CommenterChange(Sender: TObject);
    procedure CheckBox_ControlCodeClick(Sender: TObject);
    procedure CheckBox_RetMarkClick(Sender: TObject);
    procedure CheckBox_EofMarkClick(Sender: TObject);
    procedure CheckBox_UnderLineClick(Sender: TObject);
    procedure SpinEdit_MarginTopChange(Sender: TObject);
    procedure SpinEdit_MarginLeftChange(Sender: TObject);
    procedure SpinEdit_MarginLineChange(Sender: TObject);
    procedure SpinEdit_MarginCharacterChange(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure ListBox_BracketsClick(Sender: TObject);
    procedure Button_BracketsNewClick(Sender: TObject);
    procedure Button_BracketsRemoveClick(Sender: TObject);
    procedure Button_OkClick(Sender: TObject);
    procedure Button_BracketsUpdateClick(Sender: TObject);
    procedure Button_ColorsSameBkColorClick(Sender: TObject);
    procedure Button_ColorsSameColorClick(Sender: TObject);
    procedure Button_ColorsSameStyleClick(Sender: TObject);
    procedure Button_ReserveLoadClick(Sender: TObject);
    procedure Button_ReserveSaveClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure Redo1Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure DeleteRow1Click(Sender: TObject);
    procedure SpeedButton_FollowStrDefaultClick(Sender: TObject);
    procedure SpeedButton_LeadStrDefaultClick(Sender: TObject);
    procedure SpeedButton_PunctuationStrDefaultClick(Sender: TObject);
    procedure CheckBox_FollowPunctuationClick(Sender: TObject);
    procedure CheckBox_FollowRetMarkClick(Sender: TObject);
    procedure CheckBox_LeadingClick(Sender: TObject);
    procedure CheckBox_WordBreakClick(Sender: TObject);
    procedure Edit_FollowStrChange(Sender: TObject);
    procedure Edit_LeadStrChange(Sender: TObject);
    procedure Edit_PunctuationStrChange(Sender: TObject);
    procedure SpinEdit_WrapByteChange(Sender: TObject);
    procedure CheckBox_UrlClick(Sender: TObject);
    procedure RadioGroup_ScrollBarsClick(Sender: TObject);
    procedure CheckBox_WordWrapClick(Sender: TObject);
    procedure Edit_LeftBracketChange(Sender: TObject);
    procedure Button_HelpClick(Sender: TObject);
    procedure CheckBox_KeepCaretClick(Sender: TObject);
    procedure CheckBox_MailClick(Sender: TObject);
    procedure Button_BracketsSameBkColorClick(Sender: TObject);
    procedure Button_BracketsSameColorClick(Sender: TObject);
    procedure Button_BracketsSameStyleClick(Sender: TObject);
    procedure CheckBox_SelMoveClick(Sender: TObject);
    procedure ComboBox_DefaultCursorChange(Sender: TObject);
    procedure CheckBox_RowSelectClick(Sender: TObject);
    procedure RadioGroup_SelDragModeClick(Sender: TObject);
    procedure CheckBox_AutoCursorClick(Sender: TObject);
    procedure CheckBox_LeftbarVisibleClick(Sender: TObject);
    procedure CheckBox_LeftbarEdgeClick(Sender: TObject);
    procedure CheckBox_LeftbarShowNumberClick(Sender: TObject);
    procedure CheckBox_LeftbarZeroBaseClick(Sender: TObject);
    procedure CheckBox_LeftbarZeroLeadClick(Sender: TObject);
    procedure RadioGroup_LeftbarShowNumberModeClick(Sender: TObject);
    procedure SpinEdit_LeftbarColumnChange(Sender: TObject);
    procedure SpinEdit_LeftbarLeftMarginChange(Sender: TObject);
    procedure SpinEdit_LeftbarRightMarginChange(Sender: TObject);
    procedure CheckBox_RulerVisibleClick(Sender: TObject);
    procedure CheckBox_RulerEdgeClick(Sender: TObject);
    procedure RadioGroup_GaugeRangeClick(Sender: TObject);
    procedure ListBox_RulerClick(Sender: TObject);
    procedure CheckBox_BackSpaceUnIndentClick(Sender: TObject);
    procedure CheckBox_WrapMarkClick(Sender: TObject);
    procedure CheckBox_HideMarkClick(Sender: TObject);
    procedure CheckBox_ImagebarVisibleClick(Sender: TObject);
    procedure SpinEdit_ImagebarLeftmarginChange(Sender: TObject);
    procedure SpinEdit_ImagebarRightMarginChange(Sender: TObject);
    procedure SpinEdit_ImagebarDigitWidthChange(Sender: TObject);
    procedure SpinEdit_ImagebarMarkWidthChange(Sender: TObject);
    procedure CheckBox_InitBracketsFullClick(Sender: TObject);
    procedure SpinEdit_CaretVerticalAcChange(Sender: TObject);
    procedure SpinEdit_PageVerticalRangeChange(Sender: TObject);
    procedure SpinEdit_PageVerticalRangeAcChange(Sender: TObject);
    procedure RadioGroup_HitStyleClick(Sender: TObject);
    procedure CheckBox_FreeRowClick(Sender: TObject);
  private
    FEditorProp: TEditorProp;
    FOption: TPersistent;
    FShowTrueType: Boolean;
    FViewColorManager: TEditorColorManager;
    FRulerColorManager: TEditorColorManager;
    FBracketColorManager: TEditorColorManager;
    FFontFountain: TFountainColor;
    FRulerFountain: TFountainColor;
    FRulerMark: TEditorMark;
    FLeftbarFountain: TFountainColor;
    procedure FontFountainChange(Sender: TObject);
    procedure RulerFountainChange(Sender: TObject);
    procedure RulerMarkChange(Sender: TObject);
    procedure LeftbarFountainChange(Sender: TObject);
    procedure BuildFontList;
    procedure GetCursors(const S: string);
    procedure UpdateFontColor(Sender: TObject);
    procedure UpdateHitStyle(Sender: TObject);
    procedure UpdateImagebar(Sender: TObject);
    procedure UpdateLeftbar(Sender: TObject);
    procedure UpdateMargin(Sender: TObject);
    procedure UpdateMarks(Sender: TObject);
    procedure UpdateRuler(Sender: TObject);
    procedure UpdateScrollBars(Sender: TObject);
    procedure UpdateView(Sender: TObject);
    procedure WMHelp(var Message: TMessage); message WM_HELP;
  public
    class function Execute(EditorProp: TEditorProp;
      Option: TPersistent; ViewFileExt: Boolean): Boolean;
    function EditEditorProp(EditorProp: TEditorProp;
      Option: TPersistent): Boolean;
  end;

function EditEditor(Editor: TEditor; Option: TPersistent): Boolean;
function EditEditorProp(EditorProp: TEditorProp; Option: TPersistent): Boolean;

implementation

{$R *.DFM}

uses
  heRaStrings, // rm0..10
  heStrConsts;

function EditEditor(Editor: TEditor; Option: TPersistent): Boolean;
var
  EditorProp: TEditorProp;
begin
  Result := False;
  EditorProp := TEditorProp.Create(nil);
  try
    EditorProp.Assign(Editor);
    if TFormViewEditor.Execute(EditorProp, Option, False) then
    begin
      EditorProp.AssignTo(Editor);
      Result := True;
    end;
  finally
    EditorProp.Free;
  end;
end;

function EditEditorProp(EditorProp: TEditorProp;
  Option: TPersistent): Boolean;
begin
  Result := TFormViewEditor.Execute(EditorProp, Option, True);
end;


{ TFormViewEditor }

class function TFormViewEditor.Execute(EditorProp: TEditorProp;
  Option: TPersistent; ViewFileExt: Boolean): Boolean;
var
  Form: TFormViewEditor;
begin
  Form := TFormViewEditor.Create(Application);
  try
    Form.GroupBox_FileExt.Visible := ViewFileExt;
    Result := Form.EditEditorProp(EditorProp, Option);
  finally
    Form.Free;
  end;
end;

function TFormViewEditor.EditEditorProp(EditorProp: TEditorProp;
  Option: TPersistent): Boolean;
begin
  Result := False;
  if EditorProp = nil then Exit;
  // EditorProp, Option への参照を保持する
  FEditorProp := EditorProp;
  FOption := Option;
  // EditorProp のプロパティを受け取る
  EditorProp1.Assign(EditorProp);
  // 各コントロールの初期化
  // color & font
  Editor_FontSample.Font.Name := EditorProp1.Font.Name;
  Editor_FontSample.Font.Size := EditorProp1.Font.Size;
  // FileExtList
  Editor_FileExt.Lines.Assign(EditorProp1.FileExtList);
  // ScrollBars
  Editor_FontSample.ScrollBars := EditorProp1.ScrollBars;
  RadioGroup_ScrollBars.ItemIndex := Ord(EditorProp1.ScrollBars);
  // TEditorSpeed
  CheckBox_InitBracketsFull.Checked := EditorProp1.Speed.InitBracketsFull;
  SpinEdit_CaretVerticalAc.Value := EditorProp1.Speed.CaretVerticalAc;
  SpinEdit_PageVerticalRange.Value := EditorProp1.Speed.PageVerticalRange;
  SpinEdit_PageVerticalRangeAc.Value := EditorProp1.Speed.PageVerticalRangeAc;
  // TEditorViewInfo
  Edit_HexPrefix.Text := EditorProp1.View.HexPrefix;
  Edit_Quotation.Text := EditorProp1.View.Quotation;
  Edit_Commenter.Text := EditorProp1.View.Commenter;
  CheckBox_ControlCode.Checked := EditorProp1.View.ControlCode;
  CheckBox_Mail.Checked := EditorProp1.View.Mail;
  CheckBox_Url.Checked := EditorProp1.View.Url;
  // HitStyle
  RadioGroup_HitStyle.ItemIndex := Ord(EditorProp1.HitStyle);
  // TEditorCaret
  CheckBox_FreeCaret.Checked := EditorProp1.Caret.FreeCaret;
  CheckBox_FreeRow.Checked := EditorProp1.Caret.FreeRow;
  CheckBox_AutoIndent.Checked := EditorProp1.Caret.AutoIndent;
  CheckBox_BackSpaceUnIndent.Checked := EditorProp1.Caret.BackSpaceUnIndent;
  CheckBox_InTab.Checked := EditorProp1.Caret.InTab;
  CheckBox_KeepCaret.Checked := EditorProp1.Caret.KeepCaret;
  CheckBox_LockScroll.Checked := EditorProp1.Caret.LockScroll;
  CheckBox_NextLine.Checked := EditorProp1.Caret.NextLine;
  CheckBox_TabIndent.Checked := EditorProp1.Caret.TabIndent;
  CheckBox_PrevSpaceIndent.Checked := EditorProp1.Caret.PrevSpaceIndent;
  CheckBox_SelMove.Checked := EditorProp1.Caret.SelMove;
  CheckBox_SoftTab.Checked := EditorProp1.Caret.SoftTab;
  CheckBox_RowSelect.Checked := EditorProp1.Caret.RowSelect;
  CheckBox_AutoCursor.Checked := EditorProp1.Caret.AutoCursor;
  SpinEdit_TabSpaceCount.Value := EditorProp1.Caret.TabSpaceCount;
  RadioGroup_TEditorCaretStyle.ItemIndex := Ord(EditorProp1.Caret.Style);
  RadioGroup_SelDragMode.ItemIndex := Ord(EditorProp1.Caret.SelDragMode);
  // TEditorMarks
  CheckBox_RetMark.Checked := EditorProp1.Marks.RetMark.Visible;
  CheckBox_EofMark.Checked := EditorProp1.Marks.EofMark.Visible;
  CheckBox_WrapMark.Checked := EditorProp1.Marks.WrapMark.Visible;
  CheckBox_HideMark.Checked := EditorProp1.Marks.HideMark.Visible;
  CheckBox_UnderLine.Checked := EditorProp1.Marks.Underline.Visible;
  // TEditorMargin
  SpinEdit_MarginTop.Value := EditorProp1.Margin.Top;
  SpinEdit_MarginLeft.Value := EditorProp1.Margin.Left;
  SpinEdit_MarginLine.Value := EditorProp1.Margin.Line;
  SpinEdit_MarginCharacter.Value := EditorProp1.Margin.Character;
  // TEditorImagebar
  CheckBox_ImagebarVisible.Checked := EditorProp1.Imagebar.Visible;
  SpinEdit_ImagebarLeftMargin.Value := EditorProp1.Imagebar.LeftMargin;
  SpinEdit_ImagebarRightMargin.Value := EditorProp1.Imagebar.RightMargin;
  SpinEdit_ImagebarDigitWidth.Value := EditorProp1.Imagebar.DigitWidth;
  SpinEdit_ImagebarMarkWidth.Value := EditorProp1.Imagebar.MarkWidth;
  // TEditorLeftbar
  CheckBox_LeftbarVisible.Checked := EditorProp1.Leftbar.Visible;
  CheckBox_LeftbarEdge.Checked := EditorProp1.Leftbar.Edge;
  CheckBox_LeftbarShowNumber.Checked := EditorProp1.Leftbar.ShowNumber;
  CheckBox_LeftbarZeroBase.Checked := EditorProp1.Leftbar.ZeroBase;
  CheckBox_LeftbarZeroLead.Checked := EditorProp1.Leftbar.ZeroLead;
  RadioGroup_LeftbarShowNumberMode.ItemIndex := Byte(EditorProp1.Leftbar.ShowNumberMode);
  SpinEdit_LeftbarColumn.Value := EditorProp1.Leftbar.Column;
  SpinEdit_LeftbarLeftMargin.Value := EditorProp1.Leftbar.LeftMargin;
  SpinEdit_LeftbarRightMargin.Value := EditorProp1.Leftbar.RightMargin;
  // TEditorRuler
  CheckBox_RulerVisible.Checked := EditorProp1.Ruler.Visible;
  CheckBox_RulerEdge.Checked := EditorProp1.Ruler.Edge;
  RadioGroup_GaugeRange.ItemIndex := Min(1, EditorProp1.Ruler.GaugeRange mod 10);
  // draw
  UpdateView(Self);
  UpdateMarks(Self);
  UpdateMargin(Self);
  UpdateFontColor(Self);
  UpdateImagebar(Self);
  UpdateLeftbar(Self);
  UpdateRuler(Self);
  // ReserveWordList
  Editor_Reserve.Lines.Assign(EditorProp1.ReserveWordList);
  Editor_Reserve.Row := 0;
  // WordWrap
  CheckBox_WordWrap.Checked := EditorProp1.WordWrap;
  CheckBox_FollowPunctuation.Checked := EditorProp1.WrapOption.FollowPunctuation;
  CheckBox_FollowRetMark.Checked := EditorProp1.WrapOption.FollowRetMark;
  CheckBox_Leading.Checked := EditorProp1.WrapOption.Leading;
  CheckBox_WordBreak.Checked := EditorProp1.WrapOption.WordBreak;
  Edit_FollowStr.Text := EditorProp1.WrapOption.FollowStr;
  Edit_LeadStr.Text := EditorProp1.WrapOption.LeadStr;
  Edit_PunctuationStr.Text := EditorProp1.WrapOption.PunctuationStr;
  SpinEdit_WrapByte.Value := EditorProp1.WrapOption.WrapByte;
  // イベントハンドラをアタッチする
  EditorProp1.OnColorChange := UpdateFontColor;
  EditorProp1.Font.OnChange := UpdateFontColor;
  EditorProp1.OnHitStyleChange := UpdateHitStyle;
  EditorProp1.Imagebar.OnChange := UpdateImagebar;
  EditorProp1.Leftbar.OnChange := UpdateLeftbar;
  EditorProp1.Margin.OnChange := UpdateMargin;
  EditorProp1.Marks.OnChange := UpdateMarks;
  EditorProp1.Ruler.OnChange := UpdateRuler;
  EditorProp1.OnScrollBarsChange := UpdateScrollBars;
  EditorProp1.View.OnChange := UpdateView;
  // RowMarks
  Editor_Ruler.PutRowMark(1, rm0);
  Editor_Ruler.PutRowMark(3, rm3);
  Editor_Ruler.PutRowMark(4, rm4);
  Editor_Ruler.PutRowMark(4, rm15);
  Editor_Ruler.PutRowMark(6, rm12);

  // show modal
  Result := ShowModal = mrOk;
end;

//   HGetCursorValues に渡すメソッド cf. Controls.pas
procedure TFormViewEditor.GetCursors(const S: string);
begin
  ComboBox_DefaultCursor.Items.Add(S);
  ComboBox_DragSelCursor.Items.Add(S);
  ComboBox_DragSelCopyCursor.Items.Add(S);
  ComboBox_InSelCursor.Items.Add(S);
  ComboBox_LeftMarginCursor.Items.Add(S);
  ComboBox_TopMarginCursor.Items.Add(S);
end;

procedure TFormViewEditor.FormShow(Sender: TObject);
var
  I: Integer;
begin
  // Editor.Lines
  Editor_FontSample.Lines.Text := ViewEdit_Editor_FontSample_Lines;
  Editor_SelMove.Lines.Text := ViewEdit_Editor_SelMove_Lines;
  Editor_Colors.Lines.Text := ViewEdit_Editor_Colors_Lines;
  Editor_Ruler.Lines.Text := ViewEdit_Editor_Colors_Lines;

  // EditorProp1.Color, Font.Color, Font.Style を TFountainColor として
  // 扱うためのフィールドデータ
  FFontFountain := TFountainColor.Create;
  FFontFountain.BkColor := EditorProp1.Color;
  FFontFountain.Color := EditorProp1.Font.Color;
  FFontFountain.Style := EditorProp1.Font.Style;
  FFontFountain.OnChange := FontFountainChange;
  // EditorProp1.Ruler.BkColor, Color を TFountainColor に
  FRulerFountain := TFountainColor.Create;
  FRulerFountain.BkColor := EditorProp1.Ruler.BkColor;
  FRulerFountain.Color := EditorProp1.Ruler.Color;
  FRulerFountain.OnChange := RulerFountainChange;
  // EditorProp1.Ruler.MarkColor を TEditorMrak に
  FRulerMark := TEditorMark.Create;
  FRulerMark.Color := EditorProp1.Ruler.MarkColor;
  FRulerMark.OnChange := RulerMarkChange;
  // EditorProp1.Leftbar.BkColor, Color を TFountainColor に
  FLeftbarFountain := TFountainColor.Create;
  FLeftbarFountain.BkColor := EditorProp1.Leftbar.BkColor;
  FLeftbarFountain.Color := EditorProp1.Leftbar.Color;
  FLeftbarFountain.OnChange := LeftbarFountainChange;
  // View Marks ページ
  FViewColorManager := TEditorColorManager.Create(ColorGrid_Colors,
    Panel1, Label27, Label26, CheckBox13, CheckBox14, CheckBox15);
  // Leftbar, Ruler, Margin ページ
  FRulerColorManager := TEditorColorManager.Create(ColorGrid_Ruler,
    Panel3, Label31, Label30, nil, nil, nil);
  // Brackets ページ
  FBracketColorManager := TEditorColorManager.Create(ColorGrid_Brackets,
    Panel2, Label29, Label28, CheckBox17, CheckBox18, CheckBox19);
  // Font
  BuildFontList;
  I := ListBox_FontName.Items.IndexOf(EditorProp1.Font.Name);
  if I >= 0 then
    ListBox_FontName.ItemIndex := I
  else
  begin
    ListBox_FontName.ItemIndex := 0;
    EditorProp1.Font.Name := ListBox_FontName.Items[0];
  end;
  for I := 8 to 50 do
    ListBox_FontSize.Items.Add(IntToStr(I));
  I := ListBox_FontSize.Items.IndexOf(IntToStr(EditorProp1.Font.Size));
  if I >= 0 then
    ListBox_FontSize.ItemIndex := I
  else
  begin
    ListBox_FontSize.ItemIndex := 0;
    EditorProp1.Font.Size := StrToIntDef(ListBox_FontSize.Items[0], 10);
  end;
  Edit_FontSize.Text := IntToStr(EditorProp1.Font.Size);
  ListBox_Colors.ItemIndex := 0;
  ListBox_ColorsClick(Self);
  ListBox_Brackets.ItemIndex := 0;
  ListBox_BracketsClick(Self);
  ListBox_Ruler.ItemIndex := 0;
  ListBox_RulerClick(Self);
  HGetCursorValues(GetCursors);
  ComboBox_DefaultCursor.ItemIndex := ComboBox_DefaultCursor.Items.IndexOf(HCursorToString(EditorProp1.Caret.Cursors.DefaultCursor));
  ComboBox_DragSelCursor.ItemIndex := ComboBox_DragSelCursor.Items.IndexOf(HCursorToString(EditorProp1.Caret.Cursors.DragSelCursor));
  ComboBox_DragSelCopyCursor.ItemIndex := ComboBox_DragSelCopyCursor.Items.IndexOf(HCursorToString(EditorProp1.Caret.Cursors.DragSelCopyCursor));
  ComboBox_InSelCursor.ItemIndex := ComboBox_InSelCursor.Items.IndexOf(HCursorToString(EditorProp1.Caret.Cursors.InSelCursor));
  ComboBox_LeftMarginCursor.ItemIndex := ComboBox_LeftMarginCursor.Items.IndexOf(HCursorToString(EditorProp1.Caret.Cursors.LeftMarginCursor));
  ComboBox_TopMarginCursor.ItemIndex := ComboBox_TopMarginCursor.Items.IndexOf(HCursorToString(EditorProp1.Caret.Cursors.TopMarginCursor));
  Editor_SelMove.Caret.Cursors.Assign(EditorProp1.Caret.Cursors);
  Editor_SelMove.SelStart := 12;
  Editor_SelMove.SelLength := 22;
  if FOption is TEditorCaret then
    PageControl1.ActivePage := TabSheet2
  else
    if (FOption is TEditorLeftbar) or
       (FOption is TEditorRuler) or
       (FOption is TEditorMargin) then
      PageControl1.ActivePage := TabSheet4
    else
      if FOption is TEditorBracketCollection then
        PageControl1.ActivePage := TabSheet5
      else
        if FOption is TEditorWrapOption then
          PageControl1.ActivePage := TabSheet7
        else
          if FOption is TFont then
            PageControl1.ActivePage := TabSheet1
          else
            PageControl1.ActivePage := TabSheet3;
end;

// フォントの取得
function EnumFontFamProc(var EnumLogFont: TEnumLogFont;
  var NewTextMetric: TNewTextMetric; FontType: Integer;
  Data: Pointer): Integer; stdcall;
var
  Items: TStrings;
begin
  Items := TFormViewEditor(Data).ListBox_FontName.Items;
  Result := 1;
  // @
  if EnumLogFont.elfLogFont.lfFaceName[0] = '@' then Exit;
  // TMPF_FIXED_PITCH = 1 is variable pitch font
  if not TFormViewEditor(Data).FShowTrueType and
    ((NewTextMetric.tmPitchAndFamily and 1) = 1) then Exit;
  Items.Add(EnumLogFont.elfLogFont.lfFaceName);
end;

procedure TFormViewEditor.BuildFontList;
var
  DC: HDC;
begin
  ListBox_FontName.Items.Clear;
  DC:= GetDC(0);
  EnumFontFamilies(DC, nil, @EnumFontFamProc, Longint(Pointer(Self)));
  ReleaseDC(0, DC);
end;

procedure TFormViewEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FFontFountain.Free;
  FRulerFountain.Free;
  FRulerMark.Free;
  FLeftbarFountain.Free;
  FViewColorManager.Free;
  FRulerColorManager.Free;
  FBracketColorManager.Free;
end;

procedure TFormViewEditor.FontFountainChange(Sender: TObject);
begin
  EditorProp1.Color := FFontFountain.BkColor;
  EditorProp1.Font.Color := FFontFountain.Color;
  EditorProp1.Font.Style := FFontFountain.Style;
end;

procedure TFormViewEditor.RulerFountainChange(Sender: TObject);
begin
  EditorProp1.Ruler.BkColor := FRulerFountain.BkColor;
  EditorProp1.Ruler.Color := FRulerFountain.Color;
end;

procedure TFormViewEditor.RulerMarkChange(Sender: TObject);
begin
  EditorProp1.Ruler.MarkColor := FRulerMark.Color;
end;

procedure TFormViewEditor.LeftbarFountainChange(Sender: TObject);
begin
  EditorProp1.Leftbar.BkColor := FLeftbarFountain.BkColor;
  EditorProp1.Leftbar.Color := FLeftbarFountain.Color;
end;

procedure TFormViewEditor.CheckBox_TrueTypeClick(Sender: TObject);
var
  I: Integer;
begin
  FShowTrueType := CheckBox_TrueType.Checked;
  BuildFontList;
  I := ListBox_FontName.Items.IndexOf(EditorProp1.Font.Name);
  if I >= 0 then
    ListBox_FontName.ItemIndex := I
  else
  begin
    ListBox_FontName.ItemIndex := 0;
    EditorProp1.Font.Name := ListBox_FontName.Items[0];
  end;
end;

procedure TFormViewEditor.ListBox_FontNameClick(Sender: TObject);
begin
  EditorProp1.Font.Name := ListBox_FontName.Items[ListBox_FontName.ItemIndex];
end;

procedure TFormViewEditor.ListBox_FontSizeClick(Sender: TObject);
begin
  Edit_FontSize.Text := ListBox_FontSize.Items[ListBox_FontSize.ItemIndex];
end;

procedure TFormViewEditor.Edit_FontSizeChange(Sender: TObject);
begin
  EditorProp1.Font.Size := StrToIntDef(Edit_FontSize.Text, 10);
end;

procedure TFormViewEditor.UpdateFontColor(Sender: TObject);
begin
  Editor_FontSample.Font.Name := EditorProp1.Font.Name;
  Editor_FontSample.Font.Size := EditorProp1.Font.Size;
  Editor_Colors.Color := EditorProp1.Color;
  Editor_Colors.Font.Color := EditorProp1.Font.Color;
  Editor_Colors.Font.Style := EditorProp1.Font.Style;
  Editor_Brackets.Color := EditorProp1.Color;
  Editor_Brackets.Font.Color := EditorProp1.Font.Color;
  Editor_Brackets.Font.Style := EditorProp1.Font.Style;
  Editor_Ruler.Color := EditorProp1.Color;
  Editor_Ruler.Font.Color := EditorProp1.Font.Color;
  Editor_Ruler.Font.Style := EditorProp1.Font.Style;
  FormPaint(Sender);
end;

procedure TFormViewEditor.UpdateHitStyle(Sender: TObject);
begin
  Editor_Colors.HitStyle := EditorProp1.HitStyle;
  Editor_Ruler.HitStyle := EditorProp1.HitStyle;
  FormPaint(Sender);
end;

procedure TFormViewEditor.UpdateImagebar(Sender: TObject);
begin
  Editor_Colors.Imagebar.Assign(EditorProp1.Imagebar);
  Editor_Brackets.Imagebar.Assign(EditorProp1.Imagebar);
  Editor_Ruler.Imagebar.Assign(EditorProp1.Imagebar);
  FormPaint(Sender);
end;

procedure TFormViewEditor.UpdateLeftbar(Sender: TObject);
begin
  Editor_Colors.Leftbar.Assign(EditorProp1.Leftbar);
  Editor_Brackets.Leftbar.Assign(EditorProp1.Leftbar);
  Editor_Ruler.Leftbar.Assign(EditorProp1.Leftbar);
  FormPaint(Sender);
end;

procedure TFormViewEditor.UpdateMargin(Sender: TObject);
begin
  Editor_Colors.Margin.Assign(EditorProp1.Margin);
  Editor_Brackets.Margin.Assign(EditorProp1.Margin);
  Editor_Ruler.Margin.Assign(EditorProp1.Margin);
  FormPaint(Sender);
end;

procedure TFormViewEditor.UpdateMarks(Sender: TObject);
begin
  Editor_Colors.Marks.Assign(EditorProp1.Marks);
  Editor_Brackets.Marks.Assign(EditorProp1.Marks);
  Editor_Ruler.Marks.Assign(EditorProp1.Marks);
  FormPaint(Sender);
end;

procedure TFormViewEditor.UpdateRuler(Sender: TObject);
begin
  Editor_Colors.Ruler.Assign(EditorProp1.Ruler);
  Editor_Brackets.Ruler.Assign(EditorProp1.Ruler);
  Editor_Ruler.Ruler.Assign(EditorProp1.Ruler);
  FormPaint(Sender);
end;

procedure TFormViewEditor.UpdateScrollBars(Sender: TObject);
begin
  Editor_FontSample.ScrollBars := EditorProp1.ScrollBars;
end;

procedure TFormViewEditor.UpdateView(Sender: TObject);
var
  I, J: Integer;
begin
  J := ListBox_Brackets.ItemIndex;
  // TEditorBracketCollection
  Editor_Brackets.Lines.BeginUpdate;
  ListBox_Brackets.Items.BeginUpdate;
  try
    Editor_Brackets.Lines.Clear;
    ListBox_Brackets.Items.Clear;
    for I := 0 to EditorProp1.View.Brackets.Count - 1 do
      with EditorProp1.View.Brackets[I] do
      begin
        ListBox_Brackets.Items.Add(LeftBracket + ' ' + RightBracket);
        Editor_Brackets.Lines.Add(LeftBracket + ' Closed String ' + RightBracket);
      end;
  finally
    Editor_Brackets.Lines.EndUpdate;
    ListBox_Brackets.Items.EndUpdate;
  end;
  if J >= 0 then
  begin
    ListBox_Brackets.ItemIndex := J;
    ListBox_BracketsClick(Self);
  end;
  Editor_Colors.View.Assign(EditorProp1.View);
  Editor_Brackets.View.Assign(EditorProp1.View);
  Editor_Ruler.View.Assign(EditorProp1.View);
  Button_BracketsSameBkColor.Enabled := ListBox_Brackets.Items.Count > 0;
  Button_BracketsSameColor.Enabled := ListBox_Brackets.Items.Count > 0;
  Button_BracketsSameStyle.Enabled := ListBox_Brackets.Items.Count > 0;
  FormPaint(Sender);
end;

procedure TFormViewEditor.PageControl1Change(Sender: TObject);
begin
  FormPaint(Sender);
end;

procedure TFormViewEditor.FormPaint(Sender: TObject);
var
  R: TRect;
  SB, SC, HB, HC: TColor;
begin
  // 選択領域描画色
  SB := EditorProp1.View.Colors.Select.BkColor;
  if SB = clNone then
    SB := EditorProp1.Font.Color;
  SC := EditorProp1.View.Colors.Select.Color;
  if SC = clNone then
    SC := EditorProp1.Color;
  // 検索一致文字列描画色
  case EditorProp1.HitStyle of
    hsSelect:
      begin
        HB := SB;
        HC := SC;
      end;
    hsDraw:
      begin
        HB := EditorProp1.View.Colors.Hit.BkColor;
        HC := EditorProp1.View.Colors.Hit.Color;
      end;
    hsCaret:
      begin
        HB := ColorToRGB(clWhite) - ColorToRGB(EditorProp1.Color);
        HC := ColorToRGB(clWhite) - ColorToRGB(EditorProp1.Font.Color);
      end;
    else
    begin
      HB := clNone;
      HC := clNone;
    end;
  end;
  if HB = clNone then
    HB := EditorProp1.Font.Color;
  if HC = clNone then
    HC := EditorProp1.Color;
  // draw
  if Editor_Colors.Visible then
  begin
    UpdateWindow(Editor_Colors.Handle);
    // Select
    R := Rect(
           Editor_Colors.LeftMargin,
           Editor_Colors.TopMargin,
           Editor_Colors.LeftMargin + Editor_Colors.ColWidth * 8,
           Editor_Colors.TopMargin + Editor_Colors.RowHeight
         );
    Editor_Colors.Canvas.Brush.Color := SB;
    Editor_Colors.Canvas.Font.Color := SC;
    Editor_Colors.Canvas.Font.Style := EditorProp1.View.Colors.DBCS.Style;
    Editor_Colors.DrawTextRect(R, R.Left, R.Top, ViewEdit_SelectedArea{'選択領域'}, 0);
    // Hit
    R := Rect(
           Editor_Colors.LeftMargin + Editor_Colors.ColWidth * 24,
           Editor_Colors.TopMargin + Editor_Colors.RowHeight * 5,
           Editor_Colors.LeftMargin + Editor_Colors.ColWidth * 36,
           Editor_Colors.TopMargin + Editor_Colors.RowHeight * 6
         );
    Editor_Colors.Canvas.Brush.Color := HB;
    Editor_Colors.Canvas.Font.Color := HC;
    Editor_Colors.Canvas.Font.Style := EditorProp1.View.Colors.DBCS.Style;
    Editor_Colors.DrawTextRect(R, R.Left, R.Top, ViewEdit_HitString{'検索一致文字'}, 0);
  end;
  if Editor_Ruler.Visible then
  begin
    UpdateWindow(Editor_Ruler.Handle);
    // Select
    R := Rect(
           Editor_Ruler.LeftMargin,
           Editor_Ruler.TopMargin,
           Editor_Ruler.LeftMargin + Editor_Ruler.ColWidth * 8,
           Editor_Ruler.TopMargin + Editor_Ruler.RowHeight
         );
    Editor_Ruler.Canvas.Brush.Color := SB;
    Editor_Ruler.Canvas.Font.Color := SC;
    Editor_Ruler.Canvas.Font.Style := EditorProp1.View.Colors.DBCS.Style;
    Editor_Ruler.DrawTextRect(R, R.Left, R.Top, ViewEdit_SelectedArea{'選択領域'}, 0);
    // Hit
    R := Rect(
           Editor_Ruler.LeftMargin + Editor_Ruler.ColWidth * 7,
           Editor_Ruler.TopMargin + Editor_Ruler.RowHeight * 9,
           Editor_Ruler.LeftMargin + Editor_Ruler.ColWidth * 19,
           Editor_Ruler.TopMargin + Editor_Ruler.RowHeight * 10
         );
    Editor_Ruler.Canvas.Brush.Color := HB;
    Editor_Ruler.Canvas.Font.Color := HC;
    Editor_Ruler.Canvas.Font.Style := EditorProp1.View.Colors.DBCS.Style;
    Editor_Ruler.DrawTextRect(R, R.Left, R.Top, ViewEdit_HitString{'検索一致文字'}, 0);
  end;
end;

procedure TFormViewEditor.CheckBox_FreeCaretClick(Sender: TObject);
begin
  EditorProp1.Caret.FreeCaret := CheckBox_FreeCaret.Checked;
  Editor_SelMove.Caret.Assign(EditorProp1.Caret);
end;

procedure TFormViewEditor.CheckBox_FreeRowClick(Sender: TObject);
begin
  EditorProp1.Caret.FreeRow := CheckBox_FreeRow.Checked;
  Editor_SelMove.Caret.Assign(EditorProp1.Caret);
end;

procedure TFormViewEditor.CheckBox_AutoIndentClick(Sender: TObject);
begin
  EditorProp1.Caret.AutoIndent := CheckBox_AutoIndent.Checked;
  Editor_SelMove.Caret.Assign(EditorProp1.Caret);
end;

procedure TFormViewEditor.CheckBox_BackSpaceUnIndentClick(Sender: TObject);
begin
  EditorProp1.Caret.BackSpaceUnIndent := CheckBox_BackSpaceUnIndent.Checked;
  Editor_SelMove.Caret.Assign(EditorProp1.Caret);
end;

procedure TFormViewEditor.CheckBox_InTabClick(Sender: TObject);
begin
  EditorProp1.Caret.InTab := CheckBox_InTab.Checked;
  Editor_SelMove.Caret.Assign(EditorProp1.Caret);
end;

procedure TFormViewEditor.CheckBox_KeepCaretClick(Sender: TObject);
begin
  EditorProp1.Caret.KeepCaret := CheckBox_KeepCaret.Checked;
  Editor_SelMove.Caret.Assign(EditorProp1.Caret);
end;

procedure TFormViewEditor.CheckBox_LockScrollClick(Sender: TObject);
begin
  EditorProp1.Caret.LockScroll := CheckBox_LockScroll.Checked;
  Editor_SelMove.Caret.Assign(EditorProp1.Caret);
end;

procedure TFormViewEditor.CheckBox_NextLineClick(Sender: TObject);
begin
  EditorProp1.Caret.NextLine := CheckBox_NextLine.Checked;
  Editor_SelMove.Caret.Assign(EditorProp1.Caret);
end;

procedure TFormViewEditor.CheckBox_TabIndentClick(Sender: TObject);
begin
  EditorProp1.Caret.TabIndent := CheckBox_TabIndent.Checked;
  Editor_SelMove.Caret.Assign(EditorProp1.Caret);
end;

procedure TFormViewEditor.CheckBox_PrevSpaceIndentClick(Sender: TObject);
begin
  EditorProp1.Caret.PrevSpaceIndent := CheckBox_PrevSpaceIndent.Checked;
  Editor_SelMove.Caret.Assign(EditorProp1.Caret);
end;

procedure TFormViewEditor.CheckBox_SoftTabClick(Sender: TObject);
begin
  EditorProp1.Caret.SoftTab := CheckBox_SoftTab.Checked;
  Editor_SelMove.Caret.Assign(EditorProp1.Caret);
end;

procedure TFormViewEditor.SpinEdit_TabSpaceCountChange(Sender: TObject);
begin
  EditorProp1.Caret.TabSpaceCount := SpinEdit_TabSpaceCount.Value;
  Editor_SelMove.Caret.Assign(EditorProp1.Caret);
end;

procedure TFormViewEditor.RadioGroup_TEditorCaretStyleClick(Sender: TObject);
begin
  EditorProp1.Caret.Style := TEditorCaretStyle(RadioGroup_TEditorCaretStyle.ItemIndex);
  Editor_SelMove.Caret.Assign(EditorProp1.Caret);
end;

procedure TFormViewEditor.RadioGroup_SelDragModeClick(Sender: TObject);
begin
  EditorProp1.Caret.SelDragMode := TDragMode(RadioGroup_SelDragMode.ItemIndex);
  Editor_SelMove.Caret.Assign(EditorProp1.Caret);
end;

procedure TFormViewEditor.CheckBox_SelMoveClick(Sender: TObject);
begin
  EditorProp1.Caret.SelMove := CheckBox_SelMove.Checked;
  Editor_SelMove.Caret.Assign(EditorProp1.Caret);
end;

procedure TFormViewEditor.CheckBox_RowSelectClick(Sender: TObject);
begin
  EditorProp1.Caret.RowSelect := CheckBox_RowSelect.Checked;
  Editor_SelMove.Caret.Assign(EditorProp1.Caret);
end;

procedure TFormViewEditor.CheckBox_AutoCursorClick(Sender: TObject);
begin
  EditorProp1.Caret.AutoCursor := CheckBox_AutoCursor.Checked;
  Editor_SelMove.Caret.Assign(EditorProp1.Caret);
end;

procedure TFormViewEditor.ComboBox_DefaultCursorChange(Sender: TObject);
begin
  if Sender is TComboBox then
  begin
    with EditorProp1.Caret.Cursors, TComboBox(Sender) do
      case Tag of
        1: DefaultCursor := HStringToCursor(Items[ItemIndex]);
        2: DragSelCursor := HStringToCursor(Items[ItemIndex]);
        3: DragSelCopyCursor := HStringToCursor(Items[ItemIndex]);
        4: InSelCursor := HStringToCursor(Items[ItemIndex]);
        5: LeftMarginCursor := HStringToCursor(Items[ItemIndex]);
        6: TopMarginCursor := HStringToCursor(Items[ItemIndex]);
      end;
    Editor_SelMove.Caret.Cursors.Assign(EditorProp1.Caret.Cursors);
  end;
end;

procedure TFormViewEditor.ListBox_ColorsClick(Sender: TObject);
begin
  case ListBox_Colors.ItemIndex of
    0: FViewColorManager.FountainColor := FFontFountain;
    1: FViewColorManager.FountainColor := EditorProp1.View.Colors.Ank;
    2: FViewColorManager.FountainColor := EditorProp1.View.Colors.Comment;
    3: FViewColorManager.FountainColor := EditorProp1.View.Colors.DBCS;
    4: FViewColorManager.FountainColor := EditorProp1.View.Colors.Int;
    5: FViewColorManager.FountainColor := EditorProp1.View.Colors.Str;
    6: FViewColorManager.FountainColor := EditorProp1.View.Colors.Symbol;
    7: FViewColorManager.FountainColor := EditorProp1.View.Colors.Reserve;
    8: FViewColorManager.FountainColor := EditorProp1.View.Colors.Url;
    9: FViewColorManager.FountainColor := EditorProp1.View.Colors.Mail;
   10: FViewColorManager.FountainColor := EditorProp1.View.Colors.Select;
   11: FViewColorManager.FountainColor := EditorProp1.View.Colors.Hit;
   12: FViewColorManager.EditorMark := EditorProp1.Marks.EofMark;
   13: FViewColorManager.EditorMark := EditorProp1.Marks.RetMark;
   14: FViewColorManager.EditorMark := EditorProp1.Marks.WrapMark;
   15: FViewColorManager.EditorMark := EditorProp1.Marks.HideMark;
   16: FViewColorManager.EditorMark := EditorProp1.Marks.Underline;
  end;
end;

procedure TFormViewEditor.Edit_HexPrefixChange(Sender: TObject);
begin
  Editor_Colors.Lines[1] := '0123456789  ' + Edit_HexPrefix.Text + 'AF';
  Editor_Ruler.Lines[1] := '0123456789  ' + Edit_HexPrefix.Text + 'AF';
  EditorProp1.View.HexPrefix := Edit_HexPrefix.Text;
end;

procedure TFormViewEditor.Edit_QuotationChange(Sender: TObject);
var
  S: String;
begin
  S := Edit_Quotation.Text;
  if Length(S) > 0 then
    Edit_Quotation.Text := S[1];
  Editor_Colors.Lines[0] := ViewEdit_SelectedArea{'選択領域'} + '  ' + Edit_Quotation.Text + 'String' + Edit_Quotation.Text + '  #13#10';
  Editor_Ruler.Lines[0] := ViewEdit_SelectedArea{'選択領域'} + '  ' + Edit_Quotation.Text + 'String' + Edit_Quotation.Text + '  #13#10';
  EditorProp1.View.Quotation := Edit_Quotation.Text;
end;

procedure TFormViewEditor.Edit_CommenterChange(Sender: TObject);
begin
  Editor_Colors.Lines[2] := 'Editor1.View.Brackets[0]  ' + Edit_Commenter.Text + ' Commentline';
  Editor_Ruler.Lines[2] := 'Editor1.View.Brackets[0]  ' + Edit_Commenter.Text + ' Commentline';
  EditorProp1.View.Commenter := Edit_Commenter.Text;
end;

procedure TFormViewEditor.CheckBox_ControlCodeClick(Sender: TObject);
begin
  EditorProp1.View.ControlCode := CheckBox_ControlCode.Checked;
end;

procedure TFormViewEditor.CheckBox_MailClick(Sender: TObject);
begin
  EditorProp1.View.Mail := CheckBox_Mail.Checked;
end;

procedure TFormViewEditor.CheckBox_UrlClick(Sender: TObject);
begin
  EditorProp1.View.Url := CheckBox_Url.Checked;
end;

procedure TFormViewEditor.CheckBox_RetMarkClick(Sender: TObject);
begin
  EditorProp1.Marks.RetMark.Visible := CheckBox_RetMark.Checked;
end;

procedure TFormViewEditor.CheckBox_EofMarkClick(Sender: TObject);
begin
  EditorProp1.Marks.EofMark.Visible := CheckBox_EofMark.Checked;
end;

procedure TFormViewEditor.CheckBox_WrapMarkClick(Sender: TObject);
begin
  EditorProp1.Marks.WrapMark.Visible := CheckBox_WrapMark.Checked;
end;

procedure TFormViewEditor.CheckBox_HideMarkClick(Sender: TObject);
begin
  EditorProp1.Marks.HideMark.Visible := CheckBox_HideMark.Checked;
end;

type
  TKokodakenoEditorMargin = class(TEditorMargin);

procedure TFormViewEditor.CheckBox_UnderLineClick(Sender: TObject);
begin
  EditorProp1.Marks.Underline.Visible := CheckBox_UnderLine.Checked;
  if EditorProp1.Marks.Underline.Visible then
    TKokodakenoEditorMargin(EditorProp1.Margin).Underline := 1
  else
    TKokodakenoEditorMargin(EditorProp1.Margin).Underline := 0;
end;

procedure TFormViewEditor.RadioGroup_HitStyleClick(Sender: TObject);
begin
  EditorProp1.HitStyle := TEditorHitStyle(RadioGroup_HitStyle.ItemIndex);
end;

procedure TFormViewEditor.SpinEdit_MarginTopChange(Sender: TObject);
begin
  EditorProp1.Margin.Top := SpinEdit_MarginTop.Value;
end;

procedure TFormViewEditor.SpinEdit_MarginLeftChange(Sender: TObject);
begin
  EditorProp1.Margin.Left := SpinEdit_MarginLeft.Value;
end;

procedure TFormViewEditor.SpinEdit_MarginLineChange(Sender: TObject);
begin
  EditorProp1.Margin.Line := SpinEdit_MarginLine.Value;
end;

procedure TFormViewEditor.SpinEdit_MarginCharacterChange(Sender: TObject);
begin
  EditorProp1.Margin.Character := SpinEdit_MarginCharacter.Value;
end;

procedure TFormViewEditor.ListBox_BracketsClick(Sender: TObject);
var
  I: Integer;
  Item: TFountainBracketItem;
begin
  I := ListBox_Brackets.ItemIndex;
  if I >= 0 then
  begin
    Edit_LeftBracket.Enabled := True;
    Edit_RightBracket.Enabled := True;
    Panel2.Enabled := True;
    Button_BracketsRemove.Enabled := True;
    Item := EditorProp1.View.Brackets[I];
    Edit_LeftBracket.Text := Item.LeftBracket;
    Edit_RightBracket.Text := Item.RightBracket;
    FBracketColorManager.FountainColor := Item.ItemColor;
  end;
end;

procedure TFormViewEditor.Button_BracketsNewClick(Sender: TObject);
begin
  EditorProp1.View.Brackets.Add;
  ListBox_Brackets.ItemIndex := ListBox_Brackets.Items.Count - 1;
  ListBox_BracketsClick(Self);
end;

procedure TFormViewEditor.Button_BracketsRemoveClick(Sender: TObject);
var
  I: Integer;
begin
  I := ListBox_Brackets.ItemIndex;
  if I >= 0 then
  begin
    EditorProp1.View.Brackets[I].Free;
    FBracketColorManager.FountainColor := nil;
    I := Min(I, EditorProp1.View.Brackets.Count - 1);
    if I >= 0 then
    begin
      ListBox_Brackets.ItemIndex := I;
      ListBox_BracketsClick(Self);
    end
    else
    begin
      Edit_LeftBracket.Text := '';
      Edit_RightBracket.Text := '';
      Edit_LeftBracket.Enabled := False;
      Edit_RightBracket.Enabled := False;
      Button_BracketsRemove.Enabled := False;
    end;
  end;
end;

procedure TFormViewEditor.Edit_LeftBracketChange(Sender: TObject);
begin
  Button_BracketsUpdate.Enabled :=
    (Edit_LeftBracket.Text <> Edit_RightBracket.Text) and
    (Edit_LeftBracket.Text <> '') and
    (Edit_RightBracket.Text <> '');
end;

procedure TFormViewEditor.Button_BracketsUpdateClick(Sender: TObject);
var
  I: Integer;
begin
  I := ListBox_Brackets.ItemIndex;
  if I >= 0 then
  begin
    if (Edit_LeftBracket.Text = Edit_RightBracket.Text) or (Edit_LeftBracket.Text = '') or (Edit_RightBracket.Text = '') then
      raise Exception.Create(ViewEdit_BracketError{'空白 ・ 同一の LeftBracket, RightBracket は指定出来ません。'});
    EditorProp1.View.BeginUpdate;
    try
      EditorProp1.View.Brackets[I].LeftBracket := Edit_LeftBracket.Text;
      EditorProp1.View.Brackets[I].RightBracket := Edit_RightBracket.Text;
    finally
      EditorProp1.View.EndUpdate;
    end;
  end;
end;


(*

EditorProp1.View.Brackets の BkColor, Color, Style を統一するための
メソッド群。現在選択されている項目のプロパティ値で統一する。

*)

procedure TFormViewEditor.Button_BracketsSameBkColorClick(Sender: TObject);
var
  I: Integer;
  B: TColor;
begin
  I := ListBox_Brackets.ItemIndex;
  if (I >= 0) and (EditorProp1.View.Brackets.Count > I) then
  begin
    B := EditorProp1.View.Brackets[I].ItemColor.BkColor;
    if MessageDlg('Change all BkColor to ' + ColorToString(B),
                  mtConfirmation, mbOkCancel, 0) = mrOk then
      EditorProp1.View.Brackets.SameBkColor(B);
  end;
end;

procedure TFormViewEditor.Button_BracketsSameColorClick(Sender: TObject);
var
  I: Integer;
  C: TColor;
begin
  I := ListBox_Brackets.ItemIndex;
  if (I >= 0) and (EditorProp1.View.Brackets.Count > I) then
  begin
    C := EditorProp1.View.Brackets[I].ItemColor.Color;
    if MessageDlg('Change all Color to ' + ColorToString(C),
                  mtConfirmation, mbOkCancel, 0) = mrOk then
      EditorProp1.View.Brackets.SameColor(C);
  end;
end;

procedure TFormViewEditor.Button_BracketsSameStyleClick(Sender: TObject);
var
  J: Integer;
  S: String;
  I: TFontStyle;
  Style: TFontStyles;
begin
  J := ListBox_Brackets.ItemIndex;
  if (J >= 0) and (EditorProp1.View.Brackets.Count > J) then
  begin
    Style := EditorProp1.View.Brackets[J].ItemColor.Style;
    S := '';
    for I := Low(TFontStyle) to High(TFontStyle) do
      if I in Style then
      begin
        if (S <> '') and (I <> fsBold) then
          S := S + ', ';
        case I of
          fsBold     : S := S + 'fsBold';
          fsItalic   : S := S + 'fsItalic';
          fsUnderline: S := S + 'fsUnderline';
          fsStrikeOut: S := S + 'fsStrikeOut';
        end;
      end;
    if MessageDlg('Change all Style to [ ' + S + ' ]',
                  mtConfirmation, mbOkCancel, 0) = mrOk then
      EditorProp1.View.Brackets.SameStyle(Style);
  end;
end;

(*

EditorProp1.Colors の各プロパティを統一するためのメソッド群

TEditorFountain には SameBkColor, SameColor, SameStyle が実装されて
いて、そこでは TFountain.SameFountainColor を利用している。
TEditorFountain は SameFountainColor 内で利用される FountainColorProc
を override することで Select, Hit を除外している。

更新されるのは EditorProp1.Colors の Select 以外のプロパティで
EditorProp1.Color, Font.Color, Font.Style が変わることはない。

TEditor ver 2.10b は、各要素色が clNone の場合、TEditor.Color,
TEditor.Font.Color に置き換えて動作する仕様なので、統一する場合は
clNone を指定するようにしている。

*)

procedure TFormViewEditor.Button_ColorsSameBkColorClick(Sender: TObject);
var
  C: TColor;
begin
  case ListBox_Colors.ItemIndex of
    0:
      begin
        // Color が選択されているときは、clNone で Select, Hit 以外を統一する
        if MessageDlg('Change all BkColor to clNone',
             mtConfirmation, mbOkCancel, 0) = mrOk then
          EditorProp1.View.EditorFountain.SameBkColor(clNone);
      end;
    1..9:
      begin
        // Ank..Mail が選択されている時は、その背景色で Select, Hit 以外を統一する
        with EditorProp1.View.Colors do
          case ListBox_Colors.ItemIndex of
            1: C := Ank.BkColor;
            2: C := Comment.BkColor;
            3: C := DBCS.BkColor;
            4: C := Int.BkColor;
            5: C := Str.BkColor;
            6: C := Symbol.BkColor;
            7: C := Reserve.BkColor;
            8: C := Url.BkColor;
            9: C := Mail.BkColor;
          else
            C := Ank.BkColor;
          end;
        if MessageDlg('Change all BkColor to ' + ColorToString(C),
             mtConfirmation, mbOkCancel, 0) = mrOk then
          EditorProp1.View.EditorFountain.SameBkColor(C);
      end;
  end;
end;

procedure TFormViewEditor.Button_ColorsSameColorClick(Sender: TObject);
var
  C: TColor;
begin
  case ListBox_Colors.ItemIndex of
    0:
      begin
        // Color が選択されているときは、clNone で Select, Hit 以外を統一する
        if MessageDlg('Change all Color to clNone',
             mtConfirmation, mbOkCancel, 0) = mrOk then
          EditorProp1.View.EditorFountain.SameColor(clNone);
      end;
    1..9:
      begin
        // Ank..Mail が選択されている時は、その前景色で Select, Hit 以外を統一する
        with EditorProp1.View.Colors do
          case ListBox_Colors.ItemIndex of
            1: C := Ank.Color;
            2: C := Comment.Color;
            3: C := DBCS.Color;
            4: C := Int.Color;
            5: C := Str.Color;
            6: C := Symbol.Color;
            7: C := Reserve.Color;
            8: C := Url.Color;
            9: C := Mail.Color;
          else
            C := Ank.Color;
          end;
        if MessageDlg('Change all Color to ' + ColorToString(C),
             mtConfirmation, mbOkCancel, 0) = mrOk then
          EditorProp1.View.EditorFountain.SameColor(C);
      end;
  end;
end;

procedure TFormViewEditor.Button_ColorsSameStyleClick(Sender: TObject);
var
  S: String;
  I: TFontStyle;
begin
  // 項目 Color のフォントスタイル（ EditorProp1.Font.Style ）で
  // Select 以外を統一する
  S := '';
  for I := Low(TFontStyle) to High(TFontStyle) do
    if I in EditorProp1.Font.Style then
    begin
      if (S <> '') and (I <> fsBold) then
        S := S + ', ';
      case I of
        fsBold     : S := S + 'fsBold';
        fsItalic   : S := S + 'fsItalic';
        fsUnderline: S := S + 'fsUnderline';
        fsStrikeOut: S := S + 'fsStrikeOut';
      end;
    end;
  if MessageDlg('Change all Style to [ ' + S + ' ]',
                mtConfirmation, mbOkCancel, 0) = mrOk then
    EditorProp1.View.EditorFountain.SameStyle(EditorProp1.Font.Style);
end;

procedure TFormViewEditor.Button_ReserveLoadClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    Editor_Reserve.Lines.LoadFromFile(OpenDialog1.FileName);
end;

procedure TFormViewEditor.Button_ReserveSaveClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
    Editor_Reserve.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure TFormViewEditor.PopupMenu1Popup(Sender: TObject);
begin
  Undo1.Enabled := Editor_Reserve.CanUndo;
  Redo1.Enabled := Editor_Reserve.CanRedo;
  Cut1.Enabled := Editor_Reserve.Selected;
  Copy1.Enabled := Editor_Reserve.Selected;
  Paste1.Enabled := Clipboard.HasFormat(CF_TEXT);
end;

procedure TFormViewEditor.Undo1Click(Sender: TObject);
begin
  Editor_Reserve.Undo;
end;

procedure TFormViewEditor.Redo1Click(Sender: TObject);
begin
  Editor_Reserve.Redo;
end;

procedure TFormViewEditor.Cut1Click(Sender: TObject);
begin
  Editor_Reserve.CutToClipboard;
end;

procedure TFormViewEditor.Copy1Click(Sender: TObject);
begin
  Editor_Reserve.CopyToClipboard;
end;

procedure TFormViewEditor.Paste1Click(Sender: TObject);
begin
  Editor_Reserve.PasteFromClipboard;
end;

procedure TFormViewEditor.DeleteRow1Click(Sender: TObject);
begin
  Editor_Reserve.DeleteRow(Editor_Reserve.Row);
end;

procedure TFormViewEditor.SpeedButton_FollowStrDefaultClick(Sender: TObject);
begin
  Edit_FollowStr.Text := WrapOption_Default_FollowStr; // '、。，．・？！゛゜ヽヾゝゞ々ー）］｝」』!),.:;?]}｡｣､･ｰﾞﾟ';
end;

procedure TFormViewEditor.SpeedButton_LeadStrDefaultClick(Sender: TObject);
begin
  Edit_LeadStr.Text := WrapOption_Default_LeadStr; // '（［｛「『([{｢';
end;

procedure TFormViewEditor.SpeedButton_PunctuationStrDefaultClick(Sender: TObject);
begin
  Edit_PunctuationStr.Text := WrapOption_Default_PunctuationStr; // '、。，．,.｡､';
end;

procedure TFormViewEditor.CheckBox_WordWrapClick(Sender: TObject);
begin
  EditorProp1.WordWrap := CheckBox_WordWrap.Checked;
end;

procedure TFormViewEditor.CheckBox_FollowPunctuationClick(Sender: TObject);
begin
  EditorProp1.WrapOption.FollowPunctuation := CheckBox_FollowPunctuation.Checked;
end;

procedure TFormViewEditor.CheckBox_FollowRetMarkClick(Sender: TObject);
begin
  EditorProp1.WrapOption.FollowRetMark := CheckBox_FollowRetMark.Checked;
end;

procedure TFormViewEditor.CheckBox_LeadingClick(Sender: TObject);
begin
  EditorProp1.WrapOption.Leading := CheckBox_Leading.Checked;
end;

procedure TFormViewEditor.CheckBox_WordBreakClick(Sender: TObject);
begin
  EditorProp1.WrapOption.WordBreak := CheckBox_WordBreak.Checked;
end;

procedure TFormViewEditor.Edit_FollowStrChange(Sender: TObject);
begin
  EditorProp1.WrapOption.FollowStr := Edit_FollowStr.Text;
end;

procedure TFormViewEditor.Edit_LeadStrChange(Sender: TObject);
begin
  EditorProp1.WrapOption.LeadStr := Edit_LeadStr.Text;
end;

procedure TFormViewEditor.Edit_PunctuationStrChange(Sender: TObject);
begin
  EditorProp1.WrapOption.PunctuationStr := Edit_PunctuationStr.Text;
end;

procedure TFormViewEditor.SpinEdit_WrapByteChange(Sender: TObject);
var
  I: Integer;
begin
  I := Max(SpinEdit_WrapByte.MinValue, Min(SpinEdit_WrapByte.MaxValue, StrToIntDef(SpinEdit_WrapByte.Text, 20)));
  EditorProp1.WrapOption.WrapByte := I;
end;

procedure TFormViewEditor.RadioGroup_ScrollBarsClick(Sender: TObject);
begin
  EditorProp1.ScrollBars := TScrollStyle(RadioGroup_ScrollBars.ItemIndex);
end;

procedure TFormViewEditor.Button_HelpClick(Sender: TObject);
begin
  WinHelp(Handle, PChar('HEdit.hlp'), HELP_FINDER, 0);
end;

procedure TFormViewEditor.Button_OkClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to EditorProp1.View.Brackets.Count - 1 do
    if (EditorProp1.View.Brackets[I].LeftBracket = '') or
       (EditorProp1.View.Brackets[I].RightBracket = '') or
       (EditorProp1.View.Brackets[I].LeftBracket = EditorProp1.View.Brackets[I].RightBracket) then
    begin
      ModalResult := mrNone;
      PageControl1.ActivePage := TabSheet3;
      ListBox_Brackets.ItemIndex := I;
      ListBox_BracketsClick(Self);
      Edit_LeftBracket.SetFocus;
      raise Exception.Create(ViewEdit_BracketError{'空白 ・ 同一の LeftBracket, RightBracket は指定出来ません。'});
    end;
  // assign ReserveWordList
  EditorProp1.ReserveWordList.Assign(Editor_Reserve.Lines);
  // assign FileExtList
  EditorProp1.FileExtList.Assign(Editor_FileExt.Lines);
  // update FEditorProp
  FEditorProp.Assign(EditorProp1);
end;

procedure TFormViewEditor.WMHelp(var Message: TMessage);
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

// TEditorImagebar

procedure TFormViewEditor.CheckBox_ImagebarVisibleClick(Sender: TObject);
begin
  EditorProp1.Imagebar.Visible := CheckBox_ImagebarVisible.Checked;
end;

procedure TFormViewEditor.SpinEdit_ImagebarLeftmarginChange(Sender: TObject);
begin
  EditorProp1.Imagebar.LeftMargin := SpinEdit_ImagebarLeftMargin.Value;
end;

procedure TFormViewEditor.SpinEdit_ImagebarRightMarginChange(Sender: TObject);
begin
  EditorProp1.Imagebar.RightMargin := SpinEdit_ImagebarRightMargin.Value;
end;

procedure TFormViewEditor.SpinEdit_ImagebarDigitWidthChange(Sender: TObject);
begin
  EditorProp1.Imagebar.DigitWidth := SpinEdit_ImagebarDigitWidth.Value;
end;

procedure TFormViewEditor.SpinEdit_ImagebarMarkWidthChange(Sender: TObject);
begin
  EditorProp1.Imagebar.MarkWidth := SpinEdit_ImagebarMarkWidth.Value;
end;

// TEditorLeftbar

procedure TFormViewEditor.CheckBox_LeftbarVisibleClick(Sender: TObject);
begin
  EditorProp1.Leftbar.Visible := CheckBox_LeftbarVisible.Checked;
end;

procedure TFormViewEditor.CheckBox_LeftbarEdgeClick(Sender: TObject);
begin
  EditorProp1.Leftbar.Edge := CheckBox_LeftbarEdge.Checked;
end;

procedure TFormViewEditor.CheckBox_LeftbarShowNumberClick(Sender: TObject);
begin
  EditorProp1.Leftbar.ShowNumber := CheckBox_LeftbarShowNumber.Checked;
end;

procedure TFormViewEditor.CheckBox_LeftbarZeroBaseClick(Sender: TObject);
begin
  EditorProp1.Leftbar.ZeroBase := CheckBox_LeftbarZeroBase.Checked;
end;

procedure TFormViewEditor.CheckBox_LeftbarZeroLeadClick(Sender: TObject);
begin
  EditorProp1.Leftbar.ZeroLead := CheckBox_LeftbarZeroLead.Checked;
end;

procedure TFormViewEditor.RadioGroup_LeftbarShowNumberModeClick(Sender: TObject);
begin
  EditorProp1.Leftbar.ShowNumberMode := TEditorShowNumberMode(RadioGroup_LeftbarShowNumberMode.ItemIndex);
end;

procedure TFormViewEditor.SpinEdit_LeftbarColumnChange(Sender: TObject);
begin
  EditorProp1.Leftbar.Column := SpinEdit_LeftbarColumn.Value;
end;

procedure TFormViewEditor.SpinEdit_LeftbarLeftMarginChange(Sender: TObject);
begin
  EditorProp1.Leftbar.LeftMargin := SpinEdit_LeftbarLeftMargin.Value;
end;

procedure TFormViewEditor.SpinEdit_LeftbarRightMarginChange(Sender: TObject);
begin
  EditorProp1.Leftbar.RightMargin := SpinEdit_LeftbarRightMargin.Value;
end;

// TEditorRuler

procedure TFormViewEditor.CheckBox_RulerVisibleClick(Sender: TObject);
begin
  EditorProp1.Ruler.Visible := CheckBox_RulerVisible.Checked;
end;

procedure TFormViewEditor.CheckBox_RulerEdgeClick(Sender: TObject);
begin
  EditorProp1.Ruler.Edge := CheckBox_RulerEdge.Checked;
end;

procedure TFormViewEditor.RadioGroup_GaugeRangeClick(Sender: TObject);
begin
  EditorProp1.Ruler.GaugeRange := 10 - RadioGroup_GaugeRange.ItemIndex * 2;
end;

procedure TFormViewEditor.ListBox_RulerClick(Sender: TObject);
begin
  case ListBox_Ruler.ItemIndex of
    0: FRulerColorManager.FountainColor := FRulerFountain;
    1: FRulerColorManager.EditorMark := FRulerMark;
    2: FRulerColorManager.FountainColor := FLeftbarFountain;
  end;
end;

// TEditorSpeed

procedure TFormViewEditor.CheckBox_InitBracketsFullClick(Sender: TObject);
begin
  EditorProp1.Speed.InitBracketsFull := CheckBox_InitBracketsFull.Checked;
end;

procedure TFormViewEditor.SpinEdit_CaretVerticalAcChange(Sender: TObject);
begin
  EditorProp1.Speed.CaretVerticalAc := SpinEdit_CaretVerticalAc.Value;
end;

procedure TFormViewEditor.SpinEdit_PageVerticalRangeChange(Sender: TObject);
begin
  EditorProp1.Speed.PageVerticalRange := SpinEdit_PageVerticalRange.Value;
end;

procedure TFormViewEditor.SpinEdit_PageVerticalRangeAcChange(Sender: TObject);
begin
  EditorProp1.Speed.PageVerticalRangeAc := SpinEdit_PageVerticalRangeAc.Value;
end;

end.
