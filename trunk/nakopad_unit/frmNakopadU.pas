unit frmNakopadU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, HEditor, hOleddEditor, EditorEx, heClasses, heFountain,
  ComCtrls, ExtCtrls, ToolWin, HEdtProp, EditorExProp,
  IniFiles, ImgList, heRaStrings, Clipbrd, CsvUtils2, StdCtrls, nakopad_types,
  XPMan, NadesikoFountain, PerlFountain, JavaFountain, CppFountain, HTMLFountain,
  DelphiFountain, HimawariFountain, HViewEdt, AppEvnts, TrackBox,
  unit_guiParts, Grids, ValEdit;

const
  NAKO_VNAKO = 0;
  NAKO_GNAKO = 1;
  NAKO_CNAKO = 2;
  GUI_TXT       = 'tools\gui.txt';
  COMMAND_TXT   = 'tools\command.txt';
  REPORT_TXT    = 'report.txt';
  DIR_TOOLS     = 'tools\';
  DIR_TEMPLATE  = 'tools\template\';
  MODE_HINT_STR = '※【なでしこ実行モード】';

type
  TColorMode = class
    menu: TMenuItem;
    fountain: TFountain;
    ext: string;
  end;

  TfrmNakopad = class(TForm)
    mnusMain: TMainMenu;
    F1: TMenuItem;
    E1: TMenuItem;
    F2: TMenuItem;
    V1: TMenuItem;
    R1: TMenuItem;
    mnuTools: TMenuItem;
    S1: TMenuItem;
    H1: TMenuItem;
    mnuNew: TMenuItem;
    N2: TMenuItem;
    mnuOpen: TMenuItem;
    N3: TMenuItem;
    mnuSave: TMenuItem;
    mnuSaveAs: TMenuItem;
    N4: TMenuItem;
    mnuMakeExe: TMenuItem;
    N5: TMenuItem;
    mnuClose: TMenuItem;
    mnuOpenRecent: TMenuItem;
    pageLeft: TPageControl;
    sheetAction: TTabSheet;
    sheetFind: TTabSheet;
    sheetGroup: TTabSheet;
    sheetCmd: TTabSheet;
    ToolBar1: TToolBar;
    splitPanel: TSplitter;
    Status: TStatusBar;
    NadesikoFountain: TNadesikoFountain;
    sheetVar: TTabSheet;
    edtProp: TEditorExProp;
    mnuSplitEdit: TMenuItem;
    N6: TMenuItem;
    mnuViewLeftPanel: TMenuItem;
    imgsMain: TImageList;
    ToolButton1: TToolButton;
    toolOpenRecent: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    toolRun: TToolButton;
    toolStop: TToolButton;
    toolPause: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    mnuUndo: TMenuItem;
    mnuRedo: TMenuItem;
    N1: TMenuItem;
    mnuCut: TMenuItem;
    mnuCopy: TMenuItem;
    mnuPaste: TMenuItem;
    N7: TMenuItem;
    mnuSelectAll: TMenuItem;
    N8: TMenuItem;
    mnuIndentRight: TMenuItem;
    mnuIndentLeft: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    mnuBM1: TMenuItem;
    mnuBM2: TMenuItem;
    mnuBM3: TMenuItem;
    mnuBM4: TMenuItem;
    mnuBM5: TMenuItem;
    mnuBJ1: TMenuItem;
    mnuBJ2: TMenuItem;
    mnuBJ3: TMenuItem;
    mnuBJ4: TMenuItem;
    mnuBJ5: TMenuItem;
    popUndo: TMenuItem;
    N13: TMenuItem;
    popCut: TMenuItem;
    popCopy: TMenuItem;
    popPaste: TMenuItem;
    N14: TMenuItem;
    popSelectAll: TMenuItem;
    N15: TMenuItem;
    popIndentRight: TMenuItem;
    popIndentLeft: TMenuItem;
    popupMain: TPopupMenu;
    mnuRun: TMenuItem;
    mnuStop: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    mnuNakoV: TMenuItem;
    mnuNakoG: TMenuItem;
    mnuNakoC: TMenuItem;
    mnuPause: TMenuItem;
    mnuFind: TMenuItem;
    mnuFindNext: TMenuItem;
    mnuMan: TMenuItem;
    N18: TMenuItem;
    mnuAbout: TMenuItem;
    popRecent: TPopupMenu;
    N19: TMenuItem;
    mnuDebugLineNo: TMenuItem;
    N20: TMenuItem;
    mnuKanrenduke: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    cmbFind: TComboBox;
    btnFind: TButton;
    chkFindTop: TCheckBox;
    btnFindSort: TButton;
    lstFind: TListBox;
    popFind: TPopupMenu;
    popFindCopy: TMenuItem;
    popFindPaste: TMenuItem;
    popFindCut: TMenuItem;
    chkFindZenHan: TCheckBox;
    N21: TMenuItem;
    mnuInsLine: TMenuItem;
    popListFind: TPopupMenu;
    popListFindGoto: TMenuItem;
    N23: TMenuItem;
    popListFindMem1: TMenuItem;
    popListFindMem2: TMenuItem;
    popListFindMem3: TMenuItem;
    popListFindMem4: TMenuItem;
    popListFindMem5: TMenuItem;
    N24: TMenuItem;
    Panel4: TPanel;
    Panel5: TPanel;
    btnGroupEnum: TButton;
    Panel6: TPanel;
    chkGroupInclude: TCheckBox;
    lstGroup: TListBox;
    Splitter1: TSplitter;
    lstMember: TListBox;
    cmbGroup: TComboBox;
    btnGroupSort: TButton;
    N22: TMenuItem;
    mnuGotoLine: TMenuItem;
    Panel7: TPanel;
    Panel8: TPanel;
    btnCmdEnum: TButton;
    chkCmdWildcard: TCheckBox;
    cmbCmd: TComboBox;
    chkCmdDescript: TCheckBox;
    lstCmd: TListBox;
    Panel9: TPanel;
    btnVarEnum: TButton;
    cmbVar: TComboBox;
    btnVarSort: TButton;
    lstVar: TListBox;
    chkVarLocal: TCheckBox;
    btnFuncEnum: TButton;
    popTabList: TPopupMenu;
    popTabListGoto: TMenuItem;
    popTabListIns: TMenuItem;
    N25: TMenuItem;
    lstAction: TListBox;
    Splitter2: TSplitter;
    edtAction: TRichEdit;
    XPManifest1: TXPManifest;
    mnuHokan: TMenuItem;
    popCmd: TPopupMenu;
    popInsCmd: TMenuItem;
    dlgFont: TFontDialog;
    N26: TMenuItem;
    mnuEditFont: TMenuItem;
    sheetTree: TTabSheet;
    treeCmd: TTreeView;
    Splitter3: TSplitter;
    viewCmd: TListView;
    imgsTab: TImageList;
    N27: TMenuItem;
    mnuViewSheetAction: TMenuItem;
    mnuViewSheetGroup: TMenuItem;
    mnuViewSheetTree: TMenuItem;
    N28: TMenuItem;
    S2: TMenuItem;
    mnuRunSpeed0: TMenuItem;
    mnuRunSpeed100: TMenuItem;
    mnuRunSpeed300: TMenuItem;
    mnuRunSpeed30: TMenuItem;
    N29: TMenuItem;
    mnuImeOn: TMenuItem;
    N30: TMenuItem;
    mnuColorMode: TMenuItem;
    mnuCol_nako: TMenuItem;
    mnuCol_hmw: TMenuItem;
    N33: TMenuItem;
    mnuCol_Text: TMenuItem;
    mnuCol_htm: TMenuItem;
    N34: TMenuItem;
    mnuCol_pl: TMenuItem;
    mnuCol_pas: TMenuItem;
    mnuCol_cpp: TMenuItem;
    DelphiFountain1: TDelphiFountain;
    HTMLFountain1: THTMLFountain;
    CppFountain1: TCppFountain;
    JavaFountain1: TJavaFountain;
    PerlFountain1: TPerlFountain;
    mnuCol_java: TMenuItem;
    HimawariFountain1: THimawariFountain;
    N31: TMenuItem;
    JIS1: TMenuItem;
    EUC1: TMenuItem;
    UTF8N1: TMenuItem;
    UTF81: TMenuItem;
    N32: TMenuItem;
    O1: TMenuItem;
    mnuOutSJIS: TMenuItem;
    mnuOutJIS: TMenuItem;
    mnuOutEUC: TMenuItem;
    mnuOutUTF8N: TMenuItem;
    N35: TMenuItem;
    N36: TMenuItem;
    mnuInCodeAuto: TMenuItem;
    N37: TMenuItem;
    N38: TMenuItem;
    mnuRetCRLF1: TMenuItem;
    mnuRetCR1: TMenuItem;
    mnuRetLF1: TMenuItem;
    N39: TMenuItem;
    mnuLookWeb: TMenuItem;
    mnuUseNewWindow: TMenuItem;
    N41: TMenuItem;
    N42: TMenuItem;
    popFindSelectWord: TMenuItem;
    N44: TMenuItem;
    N45: TMenuItem;
    N46: TMenuItem;
    popBookmark1: TMenuItem;
    popBookmark2: TMenuItem;
    popBookmark3: TMenuItem;
    popGoBookmark1: TMenuItem;
    popGoBookmark2: TMenuItem;
    popGoBookmark3: TMenuItem;
    mnuFindRuigigo: TMenuItem;
    N43: TMenuItem;
    popFindDefine: TMenuItem;
    mnuInsCmdNeedArg: TMenuItem;
    popupStatus: TPopupMenu;
    popStatus: TMenuItem;
    N47: TMenuItem;
    popStatusDescriptInBox: TMenuItem;
    btnVarClear: TButton;
    NadesikoFountainBlack: TNadesikoFountain;
    mnuColorBlack: TMenuItem;
    N48: TMenuItem;
    mnuStopAll: TMenuItem;
    N49: TMenuItem;
    N50: TMenuItem;
    mnuViewCmdTab: TMenuItem;
    mnuViewEdit: TMenuItem;
    mnuViewFindTab: TMenuItem;
    mnuCopyCmd: TMenuItem;
    mnuWordHelp: TMenuItem;
    mnuSayCmdDescript: TMenuItem;
    mnuViewMan: TMenuItem;
    mnuOpenSample: TMenuItem;
    AppEvent: TApplicationEvents;
    popupActDesc: TPopupMenu;
    popActDescCopy: TMenuItem;
    N51: TMenuItem;
    popActDescMore: TMenuItem;
    sheetGui: TTabSheet;
    panelGUI: TPanel;
    lstGuiType: TListBox;
    Splitter4: TSplitter;
    lstGuiProperty: TListBox;
    mnuShowBlank: TMenuItem;
    N52: TMenuItem;
    mnuReplace: TMenuItem;
    WEB2: TMenuItem;
    popLookWeb: TMenuItem;
    sheetDesignProp: TTabSheet;
    mnuDesign: TMenuItem;
    mnuInsButton: TMenuItem;
    Panel10: TPanel;
    Panel12: TPanel;
    cmbParts: TComboBox;
    propGui: TValueListEditor;
    mnuInsEdit: TMenuItem;
    mnuInsLabel: TMenuItem;
    mnuInsMemo: TMenuItem;
    mnuInsBar: TMenuItem;
    N53: TMenuItem;
    N54: TMenuItem;
    mnuInsTEdit: TMenuItem;
    mnuInsGrid: TMenuItem;
    mnuInsImage: TMenuItem;
    popupDesign: TPopupMenu;
    mnuDesignDelete: TMenuItem;
    N55: TMenuItem;
    mnuDesignDel: TMenuItem;
    N56: TMenuItem;
    N57: TMenuItem;
    mnuRegDelux: TMenuItem;
    panelGuiTop: TPanel;
    edtGuiFind: TEdit;
    mnuShowNadesikoHistory: TMenuItem;
    mnuIndentRightSpace: TMenuItem;
    mnuOpenSettingDir: TMenuItem;
    N58: TMenuItem;
    N61: TMenuItem;
    mnuInsAnime: TMenuItem;
    mnuInsPanel: TMenuItem;
    mnuInsCheck: TMenuItem;
    mnuInsList: TMenuItem;
    mnuRunAs: TMenuItem;
    mnuMakeInstaller: TMenuItem;
    mnuRunTest: TMenuItem;
    mnuTestMode: TMenuItem;
    mnuTestModeHelp: TMenuItem;
    N40: TMenuItem;
    mnuRunNakoTest: TMenuItem;
    N59: TMenuItem;
    mnuInsRunMode: TMenuItem;
    N60: TMenuItem;
    pnlGroupFilter: TPanel;
    Label1: TLabel;
    edtGroupFilter: TEdit;
    Splitter6: TSplitter;
    Panel13: TPanel;
    Panel14: TPanel;
    lblLinkToWebMan: TLabel;
    memCommand: TRichEdit;
    lblLinkToLocalMan: TLabel;
    mnuEnumUserFunction: TMenuItem;
    N62: TMenuItem;
    mnuEnumUserVar: TMenuItem;
    mnuInsertTemplate: TMenuItem;
    dlgOpenTemplate: TOpenDialog;
    N63: TMenuItem;
    mnuSaveAsTemplate: TMenuItem;
    dlgSaveTemplate: TSaveDialog;
    mnuMakeBatchFile: TMenuItem;
    dlgSaveBatchFile: TSaveDialog;
    tabsMain: TTabControl;
    pageMain: TPageControl;
    tabSource: TTabSheet;
    splitEdit: TSplitter;
    edtA: TEditorEx;
    edtB: TEditorEx;
    tabDesign: TTabSheet;
    Splitter5: TSplitter;
    panelDesign: TPanel;
    edtDesignDescript: TLabel;
    track: TTrackBox;
    panelTools: TPanel;
    Panel11: TPanel;
    lstInsertParts: TListBox;
    N64: TMenuItem;
    mnuDiffView: TMenuItem;
    splitLR: TSplitter;
    panelOtehon: TPanel;
    edtC: TEditorEx;
    panelOtehonBottom: TPanel;
    panelDiff: TPanel;
    edtDiff: TEditorEx;
    btnDiff: TButton;
    mnuInsDebug: TMenuItem;
    procedure mnuCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mnuViewLeftPanelClick(Sender: TObject);
    procedure mnuSplitEditClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtBChange(Sender: TObject);
    procedure edtBClick(Sender: TObject);
    procedure mnuNewClick(Sender: TObject);
    procedure mnuSaveClick(Sender: TObject);
    procedure mnuSaveAsClick(Sender: TObject);
    procedure mnuOpenClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure mnuBM1Click(Sender: TObject);
    procedure mnuBJ1Click(Sender: TObject);
    procedure mnuUndoClick(Sender: TObject);
    procedure mnuRedoClick(Sender: TObject);
    procedure mnuCutClick(Sender: TObject);
    procedure mnuCopyClick(Sender: TObject);
    procedure mnuPasteClick(Sender: TObject);
    procedure mnuSelectAllClick(Sender: TObject);
    procedure mnuIndentLeftClick(Sender: TObject);
    procedure mnuIndentRightClick(Sender: TObject);
    procedure mnuRunClick(Sender: TObject);
    procedure mnuNakoVClick(Sender: TObject);
    procedure mnuNakoGClick(Sender: TObject);
    procedure mnuNakoCClick(Sender: TObject);
    procedure mnuStopClick(Sender: TObject);
    procedure mnuPauseClick(Sender: TObject);
    procedure mnuFindClick(Sender: TObject);
    procedure mnuFindNextClick(Sender: TObject);
    procedure mnuManClick(Sender: TObject);
    procedure mnuDebugLineNoClick(Sender: TObject);
    procedure mnuKanrendukeClick(Sender: TObject);
    procedure popFindCutClick(Sender: TObject);
    procedure popFindCopyClick(Sender: TObject);
    procedure popFindPasteClick(Sender: TObject);
    procedure btnFindClick(Sender: TObject);
    procedure lstFindDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure btnFindSortClick(Sender: TObject);
    procedure cmbFindKeyPress(Sender: TObject; var Key: Char);
    procedure mnuInsLineClick(Sender: TObject);
    procedure lstFindDblClick(Sender: TObject);
    procedure popListFindGotoClick(Sender: TObject);
    procedure popListFindMem1Click(Sender: TObject);
    procedure btnGroupEnumClick(Sender: TObject);
    procedure lstGroupClick(Sender: TObject);
    procedure lstGroupDblClick(Sender: TObject);
    procedure lstMemberDblClick(Sender: TObject);
    procedure mnuGotoLineClick(Sender: TObject);
    procedure btnGroupSortClick(Sender: TObject);
    procedure btnCmdEnumClick(Sender: TObject);
    procedure cmbCmdKeyPress(Sender: TObject; var Key: Char);
    procedure lstCmdClick(Sender: TObject);
    procedure lstCmdDblClick(Sender: TObject);
    procedure cmbGroupKeyPress(Sender: TObject; var Key: Char);
    procedure btnVarEnumClick(Sender: TObject);
    procedure btnVarSortClick(Sender: TObject);
    procedure lstVarDblClick(Sender: TObject);
    procedure btnFuncEnumClick(Sender: TObject);
    procedure edtBDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure popTabListInsClick(Sender: TObject);
    procedure popTabListGotoClick(Sender: TObject);
    procedure edtBDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure edtBKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtBMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mnuMakeExeClick(Sender: TObject);
    procedure lstActionDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lstActionClick(Sender: TObject);
    procedure edtBKeyPress(Sender: TObject; var Key: Char);
    procedure edtBKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lstActionDblClick(Sender: TObject);
    procedure mnuHokanClick(Sender: TObject);
    procedure edtBDblClick(Sender: TObject);
    procedure lstCmdKeyPress(Sender: TObject; var Key: Char);
    procedure popInsCmdClick(Sender: TObject);
    procedure mnuEditFontClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure pageLeftChange(Sender: TObject);
    procedure treeCmdClick(Sender: TObject);
    procedure viewCmdClick(Sender: TObject);
    procedure viewCmdDblClick(Sender: TObject);
    procedure mnuViewSheetActionClick(Sender: TObject);
    procedure mnuViewSheetGroupClick(Sender: TObject);
    procedure mnuViewSheetTreeClick(Sender: TObject);
    procedure mnuRunSpeed0Click(Sender: TObject);
    procedure edtBDropFiles(Sender: TObject; Drop, KeyState: Integer;
      Point: TPoint);
    procedure cmbFindEnter(Sender: TObject);
    procedure cmbGroupEnter(Sender: TObject);
    procedure cmbVarEnter(Sender: TObject);
    procedure cmbCmdEnter(Sender: TObject);
    procedure mnuImeOnClick(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure mnuCol_javaClick(Sender: TObject);
    procedure JIS1Click(Sender: TObject);
    procedure EUC1Click(Sender: TObject);
    procedure UTF8N1Click(Sender: TObject);
    procedure UTF81Click(Sender: TObject);
    procedure mnuInCodeAutoClick(Sender: TObject);
    procedure mnuOutSJISClick(Sender: TObject);
    procedure mnuOutJISClick(Sender: TObject);
    procedure mnuOutEUCClick(Sender: TObject);
    procedure mnuOutUTF8NClick(Sender: TObject);
    procedure mnuRetCRLF1Click(Sender: TObject);
    procedure mnuRetCR1Click(Sender: TObject);
    procedure mnuRetLF1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure mnuLookWebClick(Sender: TObject);
    procedure mnuWebWriteLinkClick(Sender: TObject);
    procedure mnuUseNewWindowClick(Sender: TObject);
    procedure mnuEditCustomizeClick(Sender: TObject);
    procedure popFindSelectWordClick(Sender: TObject);
    procedure mnuFindRuigigoClick(Sender: TObject);
    procedure popTabListPopup(Sender: TObject);
    procedure popFindDefineClick(Sender: TObject);
    procedure mnuInsCmdNeedArgClick(Sender: TObject);
    procedure popStatusClick(Sender: TObject);
    procedure popStatusDescriptInBoxClick(Sender: TObject);
    procedure StatusClick(Sender: TObject);
    procedure StatusDblClick(Sender: TObject);
    procedure btnVarClearClick(Sender: TObject);
    procedure mnuColorBlackClick(Sender: TObject);
    procedure lstMemberKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure pageLeftChanging(Sender: TObject; var AllowChange: Boolean);
    procedure mnuStopAllClick(Sender: TObject);
    procedure mnuViewCmdTabClick(Sender: TObject);
    procedure mnuViewFindTabClick(Sender: TObject);
    procedure mnuViewEditClick(Sender: TObject);
    procedure treeCmdKeyPress(Sender: TObject; var Key: Char);
    procedure viewCmdKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mnuCopyCmdClick(Sender: TObject);
    procedure mnuWordHelpClick(Sender: TObject);
    procedure mnuSayCmdDescriptClick(Sender: TObject);
    procedure mnuViewManClick(Sender: TObject);
    procedure mnuOpenSampleClick(Sender: TObject);
    procedure AppEventIdle(Sender: TObject; var Done: Boolean);
    procedure popActDescCopyClick(Sender: TObject);
    procedure popActDescMoreClick(Sender: TObject);
    procedure lstGuiTypeClick(Sender: TObject);
    procedure lstGuiPropertyDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lstGuiPropertyClick(Sender: TObject);
    procedure lstGuiPropertyDblClick(Sender: TObject);
    procedure mnuShowBlankClick(Sender: TObject);
    procedure mnuReplaceClick(Sender: TObject);
    procedure WEB2Click(Sender: TObject);
    procedure popLookWebClick(Sender: TObject);
    procedure mnuInsButtonClick(Sender: TObject);
    procedure shapeBackMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cmbPartsChange(Sender: TObject);
    procedure trackMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure propGuiSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure propGuiKeyPress(Sender: TObject; var Key: Char);
    procedure propGuiGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    procedure mnuInsEditClick(Sender: TObject);
    procedure mnuInsLabelClick(Sender: TObject);
    procedure pageMainChange(Sender: TObject);
    procedure propGuiEditButtonClick(Sender: TObject);
    procedure mnuInsMemoClick(Sender: TObject);
    procedure mnuInsBarClick(Sender: TObject);
    procedure mnuInsTEditClick(Sender: TObject);
    procedure mnuInsGridClick(Sender: TObject);
    procedure mnuInsImageClick(Sender: TObject);
    procedure mnuDesignDeleteClick(Sender: TObject);
    procedure mnuDesignDelClick(Sender: TObject);
    procedure labelDesignLimitClick(Sender: TObject);
    procedure mnuRegDeluxClick(Sender: TObject);
    procedure panelGuiTopResize(Sender: TObject);
    procedure edtGuiFindChange(Sender: TObject);
    procedure mnuShowNadesikoHistoryClick(Sender: TObject);
    procedure mnuIndentRightSpaceClick(Sender: TObject);
    procedure mnuOpenSettingDirClick(Sender: TObject);
    procedure mnuInsAnimeClick(Sender: TObject);
    procedure mnuInsPanelClick(Sender: TObject);
    procedure mnuInsCheckClick(Sender: TObject);
    procedure panelDesignMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mnuInsListClick(Sender: TObject);
    procedure Panel12Resize(Sender: TObject);
    procedure mnuRunAsClick(Sender: TObject);
    procedure lstInsertPartsDblClick(Sender: TObject);
    procedure mnuMakeInstallerClick(Sender: TObject);
    procedure mnuTestModeClick(Sender: TObject);
    procedure mnuTestModeHelpClick(Sender: TObject);
    procedure lblActionGetMoreInfoClick(Sender: TObject);
    procedure mnuRunNakoTestClick(Sender: TObject);
    procedure mnuInsRunModeClick(Sender: TObject);
    procedure pnlGroupFilterResize(Sender: TObject);
    procedure edtGroupFilterChange(Sender: TObject);
    procedure edtGroupFilterKeyPress(Sender: TObject; var Key: Char);
    procedure lblLinkToWebManClick(Sender: TObject);
    procedure lblLinkToLocalManClick(Sender: TObject);
    procedure mnuEnumUserFunctionClick(Sender: TObject);
    procedure mnuEnumUserVarClick(Sender: TObject);
    procedure mnuInsertTemplateClick(Sender: TObject);
    procedure mnuSaveAsTemplateClick(Sender: TObject);
    procedure mnuMakeBatchFileClick(Sender: TObject);
    procedure tabsMainDrawTab(Control: TCustomTabControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure mnuDiffViewClick(Sender: TObject);
    procedure edtCDrawLine(Sender: TObject; LineStr: String; X, Y,
      Index: Integer; ARect: TRect; Selected: Boolean);
    procedure edtBCaretMoved(Sender: TObject);
    procedure btnDiffClick(Sender: TObject);
    procedure edtBMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mnuInsDebugClick(Sender: TObject);
  private
    { Private 宣言 }
    ini: TIniFile;
    FUserDir      : string;
    FIniName      : string;
    FModified     : Boolean;
    FFileName     : string;
    FTempFile     : string;
    RuntimeLineno : Integer;
    RecentFiles   : TStringList;
    tools         : TCsvSheet;
    groupList     : TKeyValueList;
    cmdList       : TStringList;
    csvCommand    : TCsvSheet;
    FPanel0,FPanel1,FPanel2: string;
    FSpeed        : Integer;
    cmbFindActive : TComboBox;
    FColorModes   : Array [0..7] of TColorMode;
    FOutCode      : Integer;
    FRetCode      : Integer;
    FLineTokens   : TStringList;
    FLineCurToken : Integer;
    FLastTab      : TTabSheet;
    FFirstTime    : Boolean;
    FCodeDown, FCodePress: Integer;
    // Gui design
    FGuiList      : TNGuiList;
    FTrackTarget  : TNGuiParts;
    FGuiCancelInvalidate: Boolean;
    FDownPoint: TPoint;
    tmpGroupFilter: TStringList;
    // setting
    procedure CreateVar;
    procedure FreeVar;
    procedure CheckOldVersion;
    procedure LoadIni;
    procedure SaveIni;
    procedure setEditImeMode;
    procedure edtActive_setFocus;
    // FILE
    procedure TitleChange;
    function CheckSave: Boolean; // キャンセルなら True を返す
    procedure OpenFile(fname: string);
    procedure AddRecentFile(fname: string);
    //
    procedure Indent(LeftIndent: Boolean);
    procedure WMMousewheel(var Msg: TMessage); message WM_MOUSEWHEEL;
    procedure CopyDataMessage(var WMCopyData: TWMCopyData); message WM_COPYDATA;
    procedure commandExecuteMacro(Sender: TObject; Msg: TStrings);
    procedure MoveCur(LineNo: Integer);
    // menu
    procedure MakeTools;
    procedure MakeRecentFiles;
    procedure ClearRecent(Sender: TObject);
    procedure RecentFileClick(Sender: TObject);
    procedure ToolClick(Sender: TObject);
    procedure setPanel0(const Value: string);
    procedure setPanel1(const Value: string);
    procedure setPanel2(const Value: string);
    procedure showRowCol;
    procedure makeCmdTree;
    procedure SelectWordFindCommand;
    procedure LoadCommandList;
    procedure ShowCommandToBar(line: string);
    procedure SetColorMode;
    procedure CheckColorMode;
    procedure ViewOutCode;
    procedure autoIndent;
    procedure makeGuiPage;
    procedure changeBlankMark(Value: Boolean);
    procedure appendFileToStrings(fname: string; list:TStrings);
    procedure appendFileToStringsAppAndUser(fname: string; list:TStrings);
    procedure appendFileToCsvSheet(fname: string; list:TCsvSheet);
    procedure appendFileToCsvSheetAppAndUser(fname: string; list:TCsvSheet);
    procedure selectFileLoadAppOrUser(fname: string; list:TStrings);
    // for GUI design
    procedure parts_insertFromMenu(parts: TNGuiParts; name: string = '');
    function parts_insertCommand(guiType: string; name: string = ''):TNGuiParts;
    procedure parts_mouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure parts_mouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure parts_mouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure parts_setCombo;
    procedure parts_select(parts: TNGuiParts);
    function parts_ComboGetObj: TNGuiParts;
    procedure parts_reflesh;
    procedure design2source;
    procedure source2design;
    procedure parts_prop2valueList(parts: TNGuiParts);
    procedure parts_changeDesign;
    procedure changeProLicense(b:Boolean);
    procedure track_fix;
    procedure getGUIPartsList;
    procedure DeleteNakopadTempFile;
    function GetReportFile: string;
  public
    { Public 宣言 }
    edtActive     : TEditorEx;
    FNakoIndex    : Integer;
    FFindKey      : string;
    isDelux       : Boolean;
    procedure TangoSelect;
    procedure RunProgram(FlagWait: Boolean);
    property StatusInfo: string read FPanel0 write setPanel0;
    property StatusMemo: string read FPanel1 write setPanel1;
    property StatusMsg : string read FPanel2 write setPanel2;
    property TempFile: string read FTempFile;
    property ReportFile: string read GetReportFile;
  end;

var
  frmNakopad: TfrmNakopad;

const
  key_license_sig = 'tCXPQXX4Ar8NjjLYx13RuawyV5NcdMzhsYBZhm';
  key_license_chk = 'MkUwODZCQkM1MjQ1OUI2NUREMThFRTM5MkNEMDVENDNFNTNGQjEzNA==';

// 動詞の語尾変化を削除
function DeleteGobi(key: string): string;
function DeleteJosi(key: string): string;

implementation

uses gui_benri, unit_string, unit_windows_api, StrUnit, Math,
  wildcard, frmMakeExeU, jconvert, jconvertex, MSCryptUnit, frmFindU,
  frmReplaceU, md5, unit_file, nkf, unit_blowfish, SHA1, vnako_message;

{$R *.dfm}

function chk_nakopad_key(key: string): Boolean;
var
  bf, hex, s: string;
begin
  bf     := BlowfishEnc(key, key_license_sig);
  hex    := SHA1StringHex(bf);
  s      := EncodeBase64(hex);
  Result := (s = key_license_chk);
end;


function CharInRange(p: PChar; fromCH, toCH: string): Boolean;
var
  code: Integer;
  fromCode, toCode: Integer;
begin
  // 判別対象のコードを得る
  if p^ in LeadBytes then code := (Ord(p^) shl 8) + Ord((p+1)^) else code := Ord(p^);

  // 範囲初め
  if fromCH = '' then
  begin
    fromCode := 0;
  end else
  begin
    if fromCH[1] in LeadBytes then
      fromCode := (Ord(fromCH[1]) shl 8) + Ord(fromCH[2])
    else
      fromCode := Ord(fromCH[1]);
  end;

  // 範囲終わり
  if toCH = '' then
  begin
    toCode := $FCFC;
  end else
  begin
    if toCH[1] in LeadBytes then
      toCode := (Ord(toCH[1]) shl 8) + Ord(toCH[2])
    else
      toCode := Ord(toCH[1]);
  end;

  Result := (fromCode <= code)and(code <= toCode);
end;

// 動詞の語尾変化を削除
// 動詞の語尾変化を削除
function DeleteGobi(key: string): string;
var p: PChar;
begin
  //key := HimaSourceConverter(0, key);
  p := PChar(key);

  if CharInRange(p, 'ぁ','ん') then // ひらがなから始まれば語尾を消さない
  begin
    Result := key;
    Exit;
  end;

  //
  Result := '';
  while p^ <> #0 do
  begin
    if p^ in LeadBytes then
    begin
      if not CharInRange(p, 'ぁ','ん') then Result := Result + p^ + (p+1)^;
      Inc(p, 2);
    end else
    begin
      Result := Result + p^;
      Inc(p);
    end;
  end;
end;

function DeleteJosi(key: string): string;
var
  len, slen: Integer;
  p: PString;

  function _chk(s: string): Boolean;
  begin
    Result := False;
    slen := Length(s);
    // それが(6) が(2)
    if (slen > len) then Exit;
    if Copy(key, len - slen + 1, slen) = s then
    begin
      Result := True;
      p^ := Copy(key, 1, len - slen);
    end;
  end;

begin
  Result := key;
  p := @Result;
  len  := Length(key);
	if _chk('でなければ') then Exit;
	if _chk('について') then Exit;
	if _chk('ならば') then Exit;
	if _chk('までを') then Exit;
	if _chk('までの') then Exit;
	if _chk('なのか') then Exit;
	if _chk('として') then Exit;
	if _chk('くらい') then Exit;
	if _chk('して') then Exit;
	if _chk('だけ') then Exit;
	if _chk('より') then Exit;
	if _chk('ほど') then Exit;
	if _chk('など') then Exit;
	if _chk('って') then Exit;
	if _chk('では') then Exit;
	if _chk('とは') then Exit;
	if _chk('なら') then Exit;
	if _chk('から') then Exit;
	if _chk('まで') then Exit;
	if _chk('は') then Exit;
	if _chk('で') then Exit;
	if _chk('を') then Exit;
	if _chk('の') then Exit;
	if _chk('が') then Exit;
	if _chk('に') then Exit;
	if _chk('へ') then Exit;
	if _chk('と') then Exit;
	if _chk('て') then Exit;
end;

procedure TfrmNakopad.mnuCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmNakopad.FormCreate(Sender: TObject);
begin
  //
  CreateVar;
  LoadIni;
end;

procedure TfrmNakopad.mnuViewLeftPanelClick(Sender: TObject);
begin
  if pageLeft.Width < 8 then
  begin
    pageLeft.Width := 220;
    mnuViewLeftPanel.Checked := True;
    splitPanel.Enabled := True;
  end else
  begin
    pageLeft.Width := 0;
    mnuViewLeftPanel.Checked := False;
    splitPanel.Left := pageLeft.Left + pageLeft.Width;
    splitPanel.Enabled := False;
  end;
end;

procedure TfrmNakopad.mnuSplitEditClick(Sender: TObject);
begin
  if edtA.Height < 8 then
  begin
    edtA.Height := self.ClientHeight div 3;
    mnuSplitEdit.Checked := True;
    splitEdit.Top := edtA.Top + edtA.Height;
    splitEdit.Enabled := True;
  end else
  begin
    splitEdit.Enabled := False;
    edtA.Height := 0;
    mnuSplitEdit.Checked := False;
  end;
end;

procedure TfrmNakopad.LoadIni;
var
  s: string;
  fx, fy, fw, fh: Integer;

  procedure _removeNonExistsFile(files: TStringList);
  var i: Integer; f: string;
  begin
    i := 0;
    while files.Count > i do
    begin
      f := files.Strings[i];
      if FileExists(f) then
      begin
        Inc(i);
        Continue;
      end;
      files.Delete(i);
    end;
  end;

begin
  //todo 1: LoadINI(2:Create)
  //----------------------------------------------------------------------------
  // エディタの設定
  try
    edtProp.ReadIni(ini.FileName, 'TEditor', 'edt');
  except
  end;
  splitEdit.Enabled := False;
  edtProp.AssignTo(edtA);
  edtProp.AssignTo(edtB);
  edtA.Fountain := NadesikoFountain;
  edtB.Fountain := NadesikoFountain;
  edtB.ExchangeList(edtA);
  edtA.Lines.Text := '';
  //----------------------------------------------------------------------------
  // ini
  // なでしこ実行方式
  FNakoIndex :=  ini.ReadInteger('nadesiko', 'exe', NAKO_VNAKO);
  case FNakoIndex of
    NAKO_VNAKO: mnuNakoVClick(nil);
    NAKO_GNAKO: mnuNakoVClick(nil);
    NAKO_CNAKO: mnuNakoVClick(nil);
    else        mnuNakoVClick(nil);
  end;

  // なでしこのサイズ
  fx := ini.ReadInteger('pad', 'x', -1); if fx >= 0 then Self.Left   := fx;
  fy := ini.ReadInteger('pad', 'y', -1); if fy >= 0 then Self.Top    := fy;
  fw := ini.ReadInteger('pad', 'w', -1); if fw >= 0 then Self.Width  := fw;
  fh := ini.ReadInteger('pad', 'h', -1); if fh >= 0 then Self.Height := fh;

  if (Screen.DesktopRect.Left <= fx) and ((fx+fw) <= (Screen.DesktopRect.Right)) and
     (Screen.DesktopRect.Top  <= fy) and ((fy+fh) <= (Screen.DesktopRect.Bottom)) then
  begin
    // ok
  end else
  begin
    // Reset
    Self.Top  := 0;
    Self.Left := 0;
  end;

  // タブの状態
  pageLeft.Width := ini.ReadInteger('tab', 'width', 220);
  if pageLeft.Width < 8 then
  begin
    splitPanel.Enabled := False;
    mnuViewLeftPanel.Checked := False;
  end;

  // ファイル履歴
  RecentFiles := SplitChar('?', ini.ReadString('files', 'history', ''));
  RecentFiles.Text := Trim(RecentFiles.Text);
  //存在しないファイルを削除する
  _removeNonExistsFile(RecentFiles);
  MakeRecentFiles;
  // tools
  appendFileToCsvSheetAppAndUser('tools\tools.txt', tools);
  MakeTools;
  // action
  selectFileLoadAppOrUser('tools\action.txt',
    lstAction.Items);
  // エディタ
  s := ini.ReadString ('Edit','Font.Name', '');
  if s <> '' then
  begin
    edtProp.Font.Name := s;
    edtProp.Font.Size := ini.ReadInteger('Edit','Font.Size', 10);
    edtProp.AssignTo(edtA);
    edtProp.AssignTo(edtB);
  end;
  mnuImeOn.Checked := ini.ReadBool('Edit', 'mnuImeOn.checked', True);
  if mnuImeOn.Checked then setEditImeMode;
  mnuUseNewWindow.Checked := ini.ReadBool('Edit', 'mnuUseNewWindow.checked', True);
  mnuInsCmdNeedArg.Checked := ini.ReadBool('Edit', 'mnuInsCmdNeedArg', True);
  mnuColorBlack.Checked := ini.ReadBool('Edit', 'mnuColorBlack', False);
  if mnuColorBlack.Checked then
  begin
    edtA.Color := clBlack;
    edtA.Font.Color := clWhite;
    edtA.Fountain := NadesikoFountainBlack;
    //
    edtB.Color := edtA.Color;
    edtB.Font.Color := edtA.Font.Color;
    edtB.Fountain := edtA.Fountain;
    //
    edtC.Color := edtA.Color;
    edtC.Font.Color := edtA.Font.Color;
    edtC.Fountain := edtA.Fountain;
  end;
  changeBlankMark(ini.ReadBool('Edit','ShowBlank', False));
  mnuInsDebug.Checked := ini.ReadBool('Edit','mnuInsDebug', False);

  // タブ
  sheetAction.TabVisible  := ini.ReadBool('tab', 'sheetAction.visible', sheetAction.TabVisible);
  sheetGroup.TabVisible   := ini.ReadBool('tab', 'sheetGroup.visible',  sheetGroup.TabVisible);
  sheetTree.TabVisible    := ini.ReadBool('tab', 'sheetTree.visible',   sheetTree.TabVisible);
  mnuViewSheetAction.Checked := sheetAction.TabVisible;
  mnuViewSheetGroup.Checked  := sheetGroup.TabVisible;
  mnuViewSheetTree.Checked   := sheetTree.TabVisible;

  // 文字コード
  FOutCode := SJIS_OUT;
  FRetCode := CRLF_R;
  ViewOutCode;

  //
  pageLeft.ActivePage := sheetAction;
end;

procedure TfrmNakopad.SaveIni;
var
  ws: TWindowState;
begin
  //todo 1: SaveINI
  // なでしこ実行方式
  ini.WriteInteger('nadesiko', 'exe', FNakoIndex);

  // エディタの状態
  ws := Self.WindowState;
  ini.WriteInteger('pad', 'WindowState', Ord(ws));
  if ws = wsNormal then
  begin
    ini.WriteInteger('pad', 'x', Self.Left);
    ini.WriteInteger('pad', 'y', Self.Top);
    ini.WriteInteger('pad', 'w', self.Width);
    ini.WriteInteger('pad', 'h', self.Height);
  end else
  begin
    ini.WriteInteger('pad', 'x', -1);
    ini.WriteInteger('pad', 'y', -1);
    ini.WriteInteger('pad', 'w', 700);
    ini.WriteInteger('pad', 'h', 500);
  end;
  ini.WriteBool('Edit', 'mnuImeOn.checked', mnuImeOn.Checked);
  ini.WriteBool('Edit', 'mnuUseNewWindow.checked', mnuUseNewWindow.Checked);
  ini.WriteBool('Edit', 'mnuInsCmdNeedArg', mnuInsCmdNeedArg.Checked);
  ini.WriteBool('Edit', 'mnuColorBlack', mnuColorBlack.Checked);


  // タブの状態
  ini.WriteInteger('tab', 'width', pageLeft.Width);
end;




procedure TfrmNakopad.CreateVar;
begin
  //todo 2: CreateVar(1:Create)

  FUserDir     := AppData + 'nadesiko_lang\';
  FIniName    := FUserDir + 'nakopad.ini';
  ForceDirectories(FUserDir);
  ForceDirectories(FUserDir + DIR_TOOLS);
  CheckOldVersion;

  ini         := TIniFile.Create(FIniName);
  RecentFiles := TStringList.Create;
  tools       := TCsvSheet.Create;
  groupList   := TKeyValueList.Create;
  cmdList     := TStringList.Create;
  csvCommand  := TCsvSheet.Create;
  //
  FModified := False;
  edtActive := edtB;
  FFileName := '';
  FTempFile := '';
  FNakoIndex := NAKO_VNAKO;
  FSpeed     := 0;
  TitleChange;
  cmbFindActive := cmbFind;
  FFirstTime := True;
  //
  FLineTokens := TStringList.Create;
  FLineCurToken := -1;
  FLastTab := nil;
  isDelux := False;
  tmpGroupFilter := nil;
  // GUI
  FGuiList := TNGuiList.Create;
  FTrackTarget := nil;
  FGuiCancelInvalidate := True;
  // Tab
  tabsMain.TabWidth := 130;
  tabsMain.Tabs.Text := '';
end;

procedure TfrmNakopad.FreeVar;
var
  i: Integer;
begin
  //todo 2: FreeVar
  FreeAndNil(ini);
  FreeAndNil(RecentFiles);
  FreeAndNil(tools);
  FreeAndNil(groupList);
  FreeAndNil(cmdList);
  FreeAndNil(csvCommand);
  FreeAndNil(FLineTokens);
  // free
  for i := 0 to High(FColorModes) do
  begin
    FreeAndNil(FColorModes[i]);
  end;
  //
  FreeAndNil(FGuiList);
end;

procedure TfrmNakopad.FormDestroy(Sender: TObject);
begin
  SaveIni;
  FreeVar;
  DeleteNakopadTempFile;
end;

procedure TfrmNakopad.edtBChange(Sender: TObject);
begin
  FModified := True; // 更新
  TitleChange;
end;


procedure TfrmNakopad.edtBClick(Sender: TObject);
begin
  // アクティブの切り替え
  edtActive := TEditorEx(Sender);
  showRowCol;
  if edtActive.SelLength = 0 then
  begin
    edtActive.ShowHint := False;
  end;
end;

procedure TfrmNakopad.TitleChange;
var
  s: string;
begin
  //
  s := '';
  if FFileName = '' then s := '無題' else s := ExtractFileName(FFileName);
  if FModified then s := s + '*';
  s := s + '-なでしこエディタ';
  Self.Caption := s;
  Application.Title := s;
end;

procedure TfrmNakopad.mnuNewClick(Sender: TObject);
begin
  if mnuUseNewWindow.Checked then
  begin
    RunApp(ParamStr(0));
    Exit;
  end;

  if CheckSave then Exit;
  edtActive.Lines.Clear;
  FModified := False;
  FFileName := '';
  FOutCode := SJIS_OUT;
  FRetCode := CRLF_R;
  ViewOutCode;
  TitleChange;
end;

function TfrmNakopad.CheckSave: Boolean;
var
  i: Integer;
begin
  Result := False;
  if FModified = False then Exit;
  i := MsgYesNoCancel('文書は変更されています。'#13#10'保存しますか？',
       Application.Title);
  case i of
    IDYES   :
      begin
        mnuSaveClick(nil);
        if FModified = True then
        begin
          Result := True; Exit;
        end;
      end;
    IDNO    : ;
    IDCANCEL: begin Result := True; end;
  end;
end;

procedure TfrmNakopad.mnuSaveClick(Sender: TObject);
var
  s: string;
begin
  if edtActive = edtC then
  begin
    edtActive := edtB;
  end;
  // 保存
  if pageMain.ActivePage = tabDesign then
  begin
    design2source;
    pageMain.ActivePage := tabSource;
  end;
  if FFileName = '' then
  begin
    mnuSaveAsClick(nil); Exit;
  end;
  // 保存
  s := edtActive.Lines.Text;
  // 改行コード
  s := ConvertReturnCode(s, FRetCode);
  // 出力文字コード
  case FOutCode of
    SJIS_OUT  :;
    JIS_OUT   :  s := sjis2jis83(s);
    EUC_OUT   :  s := sjis2euc(s);
    UTF8_OUT  :  s := sjisToUtf8(s);
    UTF8N_OUT :  s := sjisToUtf8N(s);
    UNILE_OUT :  s := sjisToUniLE2(s);
  end;
  //edtActive.Lines.SaveToFile(FFileName);
  WriteTextFile(FFileName, s);
  //
  FModified := False;
  TitleChange;
  //
  AddRecentFile(FFileName);
  MakeRecentFiles;

end;

procedure TfrmNakopad.mnuSaveAsClick(Sender: TObject);
var
  s, line, fname: string;
  i: Integer;
begin
  // 名前をつけて保存
  if edtActive = edtC then
  begin
    edtActive := edtB;
  end;
  if pageMain.ActivePage = tabDesign then
  begin
    design2source;
  end;
  if FFileName = '' then
  begin
    // 自動的に名前を考える処理
    s := Trim(Copy(edtActive.Lines.Text, 1, 320));
    //
    while True do
    begin
      // 先頭のコメントを削除
      line := Trim( convToHalfAnk( getToken_s(s, #13#10) ) );
      if Copy(line,1,1) = '#'  then System.Delete(line, 1,1);
      if Copy(line,1,1) = '''' then System.Delete(line, 1,1);
      if Copy(line,1,2) = '//' then System.Delete(line, 1,2);
      if Copy(line,1,2) = '/*' then System.Delete(line, 1,2);
      // 罫線なら行末までスキップ
      if (Copy(line,1,4) = '----')or(Copy(line,1,4) = '####')or
         (Copy(line,1,4) = '====')or(Copy(line,1,4) = '──')or
         (Copy(line,1,4) = '━━')or(Copy(line,1,4) = '////')then
      begin
        Continue;
      end;
      line := Trim(line);
      Break;
    end;
    //
    if line = '' then line := '無題';
    i := 1;
    fname := '';
    while (i <= Length(line)) do
    begin
      if line[i] in LeadBytes then
      begin
        fname := fname + line[i] + line[i+1];
        Inc(i,2);
      end else
      begin
        if ( line[i] in ['0'..'9','A'..'Z','a'..'z','_','-','~'] ) then
        begin
          fname := fname + line[i];
        end;
        Inc(i);
      end;
    end;

    dlgSave.FileName := fname;
  end else
  begin
    dlgSave.FileName := FFileName;
  end;

  if not dlgSave.Execute then Exit;
  // 保存処理
  FFileName := dlgSave.FileName;
  mnuSaveClick(nil);
end;

procedure TfrmNakopad.mnuOpenClick(Sender: TObject);
begin
  if CheckSave then Exit;
  if FFileName <> '' then
  begin
    dlgOpen.FileName := FFileName;
  end;
  if dlgOpen.Execute = False then Exit;
  // ファイルを開く
  OpenFile(dlgOpen.FileName);
end;

procedure TfrmNakopad.OpenFile(fname: string);
var
  path: string;

  procedure _checkNakoMode;
  var
    i, hintlen: Integer;
    s, m: string;
    hint: string;
  begin
    hint    := MODE_HINT_STR;
    hintlen := Length(hint);
    for i := 0 to edtActive.Lines.Count - 1 do
    begin
      s := edtActive.Lines.Strings[i];
      if Copy(s, 1, hintlen) = hint then
      begin
        m := Trim(s);
        System.Delete(m, 1, hintlen);
        m := LowerCase(m);
        if m = 'cnako' then
        begin
          mnuNakoCClick(nil);
        end else
        if m = 'gnako' then
        begin
          mnuNakoGClick(nil);
        end else
        if m = 'vnako' then
        begin
          mnuNakoVClick(nil);
        end else
        begin
          // unknown
        end;
      end;
    end;
  end;

begin
  // テンポラリファイルを作っていれば削除
  DeleteNakopadTempFile;

  FFileName := fname;

  edtActive.Lines.LoadFromFile(fname);
  path := ExtractFilePath(fname);
  if path <> '' then SetCurrentDir(path);

  // 文字コードの自動判別
  mnuInCodeAutoClick(nil);
  //

  // Add RecentFiles
  AddRecentFile(fname);
  MakeRecentFiles;

  // Check Color Mode
  CheckColorMode;

  // Active に
  if self.Active then
  begin
    if pageMain.ActivePage = tabSource then
    begin
      edtActive.SelStart := 0;
      edtActive_setFocus;
    end;
  end;

  // 変更をオフ
  FModified := False;
  TitleChange;

  // モード依存を確認する
  _checkNakoMode;
end;

procedure TfrmNakopad.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if CheckSave then
  begin
    CanClose := False; Exit;
  end;
end;

procedure TfrmNakopad.mnuBM1Click(Sender: TObject);
var
  tag: Integer;
begin
  tag := TMenuItem(Sender).Tag;
  case tag of
    1: edtActive.PutRowMark(edtActive.Row, rm1);
    2: edtActive.PutRowMark(edtActive.Row, rm2);
    3: edtActive.PutRowMark(edtActive.Row, rm3);
    4: edtActive.PutRowMark(edtActive.Row, rm4);
    5: edtActive.PutRowMark(edtActive.Row, rm5);
  end;
end;

procedure TfrmNakopad.mnuBJ1Click(Sender: TObject);
var
  tag: Integer;
begin
  tag := TMenuItem(Sender).Tag;
  case tag of
    1: edtActive.GotoRowMark(rm1);
    2: edtActive.GotoRowMark(rm2);
    3: edtActive.GotoRowMark(rm3);
    4: edtActive.GotoRowMark(rm4);
    5: edtActive.GotoRowMark(rm5);
  end;
end;

procedure TfrmNakopad.mnuUndoClick(Sender: TObject);
begin
  edtActive.Undo;
end;

procedure TfrmNakopad.mnuRedoClick(Sender: TObject);
begin
  edtActive.Redo;
end;

procedure TfrmNakopad.mnuCutClick(Sender: TObject);
begin
  if frmFind.Active then
  begin
    ClipbrdSetAsText(frmFind.cmbFind.SelText);
    frmFind.cmbFind.SelText := '';
  end else
  begin
    edtActive.CutToClipboard;
  end;
end;

procedure TfrmNakopad.mnuCopyClick(Sender: TObject);
begin
  if frmFind.Active then
  begin
    ClipbrdSetAsText(frmFind.cmbFind.SelText);
  end else
  begin
    edtActive.CopyToClipboard;
  end;
end;

procedure TfrmNakopad.mnuPasteClick(Sender: TObject);
begin
  if frmFind.Active then
  begin
    frmFind.cmbFind.SelText := ClipbrdGetAsText;
  end else
  begin
    edtActive.PasteFromClipboard;
  end;
end;

procedure TfrmNakopad.mnuSelectAllClick(Sender: TObject);
begin
  edtActive.SelectAll;
end;

procedure TfrmNakopad.mnuIndentLeftClick(Sender: TObject);
begin
  Indent(True);
end;

procedure TfrmNakopad.Indent(LeftIndent: Boolean);
var
  s: string;
  i: Integer;
  o: TStringList;
  iStart: Integer;

  procedure _iLeft(var s: string);
  begin
    if s = '' then Exit;
    if Copy(s,1,1) = #9 then
    begin
      System.Delete(s,1,1);
    end else
    if Copy(s,1,4) = '    ' then
    begin
      System.Delete(s,1,4);
    end else
    if Copy(s,1,4) = '　　' then
    begin
      System.Delete(s,1,4);
    end else
    if Copy(s,1,1) = ' ' then
    begin
      System.Delete(s,1,1);
    end
    ;
  end;

  procedure _iRight(var s: string);
  begin
    if Copy(s,1,1) = #9 then
    begin
      s := #9 + s;
    end else
    if Copy(s,1,4) = '    ' then
    begin
      s := '    ' + s;
    end else
    if Copy(s,1,4) = '　　' then
    begin
      s := '　　' + s;
    end else
    if Copy(s,1,1) = ' ' then
    begin
      s := '    ' + s;
    end else
    begin
      s := '    ' + s;
    end;
  end;

  procedure _indent(var s: string);
  begin
    if LeftIndent then
    begin
      _iLeft(s);
    end else
    begin
      _iRight(s);
    end;
  end;

begin
  if edtActive.SelLength > 0 then
  begin
    iStart := edtActive.SelStart;
    o := TStringList.Create;
    o.Text := edtActive.SelText;
    for i := 0 to o.Count - 1 do
    begin
      s := o.Strings[i];
      _indent(s);
      o.Strings[i] := s;
    end;
    edtActive.SelText   := o.Text;
    edtActive.SelStart := iStart;
    edtActive.SelLength := Length(o.Text);
    o.Free;
  end else
  begin
    // カーソル行
    iStart := edtActive.SelStart;
    s := edtActive.Lines.Strings[ edtActive.Row ];
    // インデントを左に
    if s = '' then Exit;
    _indent(s);
    edtActive.Lines.Strings[ edtActive.Row ] := s;
    edtActive.SelStart := iStart;
  end;
end;

procedure TfrmNakopad.mnuIndentRightClick(Sender: TObject);
begin
  Indent(False);
end;

procedure TfrmNakopad.mnuRunClick(Sender: TObject);
begin
  // Check Page
  if pageMain.ActivePage = tabDesign then
  begin
    design2source;
    pageMain.ActivePage := tabSource;
  end;
  // Run
  RunProgram(False);
end;

procedure mnuClearCheck(e: TfrmNakopad);
begin
  e.mnuNakoV.Checked := False;
  e.mnuNakoG.Checked := False;
  e.mnuNakoC.Checked := False;
end;

procedure TfrmNakopad.mnuNakoVClick(Sender: TObject);
begin
  mnuClearCheck(Self);
  mnuNakoV.Checked := True;
  FNakoIndex := NAKO_VNAKO;
end;

procedure TfrmNakopad.mnuNakoGClick(Sender: TObject);
begin
  mnuClearCheck(Self);
  mnuNakoG.Checked := True;
  FNakoIndex := NAKO_GNAKO;
end;

procedure TfrmNakopad.mnuNakoCClick(Sender: TObject);
begin
  mnuClearCheck(Self);
  mnuNakoC.Checked := True;
  FNakoIndex := NAKO_CNAKO;
end;

var send_cmd: string;
var send_msg: Integer;

function findNakoStop(h: HWND; lp: LPARAM): BOOL; stdcall;
var
  s  : string;
begin
  SetLength(s, 512);
  GetClassName(h, @s[1], 511); s := string( PChar(s) );
  if s = 'TfrmNako' then
  begin
    // SendCOPYDATA(h, send_cmd, 1001, lp);
    PostMessage(h, send_msg, 0, lp);
  end;
  Result := True;
end;

procedure TfrmNakopad.mnuStopClick(Sender: TObject);
begin
  send_cmd := 'break';
  send_msg := WM_VNAKO_BREAK;
  EnumWindows(@findNakoStop, Self.Handle);
end;

procedure TfrmNakopad.mnuPauseClick(Sender: TObject);
begin
  send_cmd := 'pause';
  send_msg := WM_VNAKO_STOP;
  EnumWindows(@findNakoStop, Self.Handle);
end;

procedure TfrmNakopad.mnuFindClick(Sender: TObject);
begin
  //FFindKey := InputBox('検索','検索語句を入力', '');
  frmFind.Show;
end;

procedure TfrmNakopad.mnuFindNextClick(Sender: TObject);
var
  i: Integer;
begin
  edtActive_setFocus;
  i := edtActive.SelStart;
  edtActive.FindString := FFindKey;
  if edtActive.FindNext = False then
  begin
    edtActive.SelStart := 0;
    if not edtActive.FindNext then
    begin
      StatusMemo := FFindKey + 'は見つかりませんでした。';
      Beep;
      edtActive.SelStart := i;
    end;
  end;
  {
  // カーソル位置から検索
  i := edtActive.SelStart + 1;
  s := Copy(edtActive.Lines.Text, i+1, Length(edtActive.Lines.Text));
  j := JPos(FFindKey, s);
  if j = 0 then
  begin
    // 見つからなかった
    // 再度はじめから検索
    j := JPos(FFindKey, edtActive.Lines.Text);
  end else
  begin
    j := j + i;
  end;
  if j = 0 then
  begin
    StatusMemo := FFindKey + 'は見つかりませんでした。';
    Beep;
    Exit;
  end;

  // 見つかった
  edtActive.SelStart  := j-1;
  edtActive.SelLength := Length(FFindKey);
  }
end;

procedure TfrmNakopad.mnuManClick(Sender: TObject);
begin
  OpenApp(AppPath+'doc\index.htm');
end;

procedure TfrmNakopad.CopyDataMessage(var WMCopyData: TWMCopyData);
var
  msg: string;
  sl: TStringList;
begin
  msg := PChar( WMCopyData.CopyDataStruct.lpData );
  if (WMCopyData.CopyDataStruct.dwData <> 0) then Exit; // ひまわりからのメッセージ以外は受け付けない
  // マクロの実行など
  sl := TStringList.Create;
  sl.Text := msg;
  commandExecuteMacro(nil, sl);
  sl.Free;
end;

procedure TfrmNakopad.WMMousewheel(var Msg: TMessage);
begin
  if edtActive.Focused then
  begin
    if (Msg.WParam > 0) then
    begin
      { ホイールを奥に動かした時の処理 }
      Sendmessage(edtActive.Handle, WM_VSCROLL, SB_LINEUP, 0);
    end
    else
    begin
      { ホイールを手前に動かした時の処理 }
      Sendmessage(edtActive.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
    end;
  end;
end;

procedure TfrmNakopad.commandExecuteMacro(Sender: TObject; Msg: TStrings);
var
    token: string;
    cmd, value: string;

    procedure sub_saveas;
    begin
        edtActive.Lines.SaveToFile( value );
    end;
    procedure sub_open;
    begin
        OpenFile(value);
    end;
    procedure sub_insert;
    begin
        edtActive.SelLength := 0;
        edtActive.SelText := value;
    end;
    {
    procedure sub_getlabel;
    var sl:TStringList;
    begin
        sl := nil;
        getLabel(sl);
        sl.SaveToFile(value);
        sl.Free;
    end;
    }
    procedure sub_col;
    var i: Integer;
    begin
        Self.Activate;
        i := StrToIntDef(value, -1);
        if i<0 then Exit;
        edtActive_setFocus ;
        edtActive.Col := i-1;
    end;
    procedure sub_row;
    var i: Integer;
    begin
        i := StrToIntDef(value, -1);
        if i<0 then Exit;
        if Self.Active then edtActive_setFocus ;
        MoveCur(i);
    end;
    procedure sub_seltext_save;
    var s: TStringList;
    begin
        s := TStringList.Create;
        try
            s.Text := edtActive.SelText ;
            s.SaveToFile(value);
        finally
            s.Free;
        end;
    end;
    procedure sub_seltext_load;
    var s: TStringList;
    begin
        s := TStringList.Create;
        try
            s.LoadFromFile(value);
            edtActive.SelText := s.Text;
        finally
            s.Free;
        end;
    end;
    procedure sub_seltext_copy;
    begin
      Clipboard.Clear ;
      Clipboard.AsText := edtActive.SelText;
      Application.ProcessMessages ;
    end;

    procedure sub_stop;
    begin
      if RuntimeLineno > 0 then MoveCur(RuntimeLineno);
    end;
begin
    token := Msg.Text ;
    StatusMsg := token;
    cmd := Trim(lowercase(convToHalf(GetToken_s(token, ' '))));
    value := Trim(token);

    if cmd='new'            then mnuNewClick(nil) else
    if cmd='save'           then mnuSaveClick(nil) else
    if cmd='saveas'         then sub_saveas else
    if cmd='open'           then sub_open else
    if cmd='insert'         then sub_insert else
    //if cmd='getlabel'       then sub_getlabel else
    if cmd='row'            then sub_row else
    if cmd='col'            then sub_col else
    if cmd='seltext_save'   then sub_seltext_save else
    if cmd='seltext_open'   then sub_seltext_load else
    if cmd='copy'           then sub_seltext_copy else
    if cmd='paste'          then begin edtActive.SelText := Clipboard.AsText; end else
    //if cmd='makeexe'        then mnuMakeExeFileClick(nil) else
    if cmd='stop'           then sub_stop else
    if cmd='selectall'      then edtActive.SelectAll else
    if cmd='selectnone'     then edtActive.SelLength := 0 else
    ;
    Application.ProcessMessages ;
end;

procedure TfrmNakopad.MoveCur(LineNo: Integer);
var
  NowLine,ToLine: Integer;
begin
  edtActive_setFocus ;
  if lineNo >= edtActive.Lines.Count then Exit;
  with edtActive do
  begin
    NowLine:=Perform(EM_LINEFROMCHAR,SelStart,0);
    ToLine:=lineNo;
    Perform(EM_LINESCROLL,0,ToLine-NowLine);
    SelStart:=Perform(EM_LINEINDEX,ToLine-1,0);
  end;
end;

procedure TfrmNakopad.MakeRecentFiles;
var
  m, p: TMenuItem;
  i: Integer;
begin
  mnuOpenRecent.Clear;
  popRecent.Items.Clear;
  if RecentFiles.Count = 0 then
  begin
    ini.WriteString('files', 'history', '');
    Exit;
  end;

  // 特別メニューを追加
  m := TMenuItem.Create(mnuOpenRecent);
  m.Caption := '(&0) 履歴をクリア';
  m.Tag     := -1;
  m.OnClick := ClearRecent;
  mnuOpenRecent.Add(m);
  m := TMenuItem.Create(mnuOpenRecent);
  m.Caption := '-';
  mnuOpenRecent.Add(m);

  // 最近のファイルを追加
  for i := 0 to RecentFiles.Count - 1 do
  begin
    m := TMenuItem.Create(mnuOpenRecent);
    m.Caption := '(&' + IntToStr(i+1) + ') ' +RecentFiles.Strings[i];
    m.Tag := i;
    m.OnClick := RecentFileClick;
    mnuOpenRecent.Add(m);
    //
    p := TMenuItem.Create(popRecent);
    p.Caption := '(&' + IntToStr(i+1) + ') ' +RecentFiles.Strings[i];
    p.Tag := i;
    p.OnClick := RecentFileClick;
    popRecent.Items.Add(p);
  end;
  mnuOpenRecent.Visible := (RecentFiles.Count > 0);

  // エディタ履歴を保存
  ini.WriteString('files', 'history', JReplace(RecentFiles.Text, #13#10, '?', True));
end;

procedure TfrmNakopad.RecentFileClick(Sender: TObject);
begin
  if CheckSave then Exit;
  OpenFile( RecentFiles.Strings[ TMenuItem(Sender).Tag ] );
end;

procedure TfrmNakopad.ClearRecent(Sender: TObject);
begin
  RecentFiles.Clear;
  MakeRecentFiles;
end;

procedure TfrmNakopad.mnuDebugLineNoClick(Sender: TObject);
begin
  mnuDebugLineNo.Checked := not mnuDebugLineNo.Checked;
end;

procedure TfrmNakopad.mnuKanrendukeClick(Sender: TObject);
var
  exe: string;
begin
  if isVistaOr7 then
  begin
    RunAsAdmin(Handle, AppPath + 'vnako.exe', AppPath + 'tools\install.nako');
  end else
  begin
    exe := AppPath + 'vnako.exe "' + AppPath + 'tools\install.nako"';
    RunApp(exe);
  end;
end;

procedure TfrmNakopad.MakeTools;
var
  m: TMenuItem;
  i, cnt: Integer;
  cap, shortcut, path, err: string;
begin
  // Tool の作成
  mnuTools.Clear;
  err := '';
  cnt := 0;

  // 一行目はヘッダ
  for i := 1 to tools.Count - 1 do
  begin
    //-----------------------------------------
    cap       := Trim(tools.Cells[0, i]);
    shortcut  := Trim(tools.Cells[1, i]);
    path      := Trim(tools.Cells[2, i]);
    if Pos(':\', path) = 0 then
    begin
      path := AppPath + 'tools\' + path;
      tools.Cells[2, i] := path;
      if not FileExists(path) then
      begin
        err := err + cap + #13#10;
        path := '';
      end;
    end;
    if (cap = '')or(path = '') then Continue;
    //-----------------------------------------
    m         := TMenuItem.Create(mnuTools);
    m.Caption := cap;
    if path <> '' then m.ShortCut := TextToShortCut(shortcut);
    m.Tag     := i;
    m.OnClick := ToolClick;
    mnuTools.Add(m);
    cnt := cnt + 1;
  end;

  if err <> '' then
  begin
    ShowMessage('tools\tools.txt の以下のパスが不正です。'#13#10+
                '-----------------------'#13#10+err);
  end;
  mnuTools.Visible := (cnt > 0);
end;

procedure TfrmNakopad.ToolClick(Sender: TObject);
var
  tag: Integer;
  ext, s: string;
begin
  tag := TMenuItem(Sender).Tag;
  if tag < 0 then Exit;

  s   := tools.Cells[2, tag];
  ext := UpperCase(ExtractFileExt(s));
  if ext = '.NAKO' then
  begin
    RunApp(AppPath + 'vnako.exe "'+s+'" -debug::' + IntToStr(Self.Handle));
  end else
  begin
    OpenApp(s);
  end;
end;

procedure TfrmNakopad.popFindCutClick(Sender: TObject);
begin
  Clipboard.AsText := cmbFindActive.SelText;
  cmbFindActive.SelText := '';
end;

procedure TfrmNakopad.popFindCopyClick(Sender: TObject);
begin
  Clipboard.AsText := cmbFindActive.SelText;
end;

procedure TfrmNakopad.popFindPasteClick(Sender: TObject);
begin
  cmbFindActive.SelText := Clipboard.AsText;
end;

procedure TfrmNakopad.btnFindClick(Sender: TObject);
var
  i: Integer;
  findType: Integer;
  s, key: string;
  ok: Boolean;

  function findNormal(var s: string): Boolean;
  var i: Integer;
  begin
    s := Trim(s);
    i := unit_string.PosA(key, s);
    Result := (i > 0);
    if Result then
    begin
      if Length(s) > 32 then
      begin
        s := unit_string.CopyA(s, max(i-4, 0), 32);
      end;
    end;
  end;

  function findLeft(var s: string): Boolean;
  var ss: string;
  begin
    s  := Trim(s);
    ss := Copy(s,1,Length(key));
    Result := (ss=key);
    if Result then
    begin
      if Length(s) > 64 then s := Copy(s,1,64);
    end;
  end;

begin
  findType := 0;
  key      := cmbFind.Text;
  if cmbFind.Items.IndexOf(key) < 0 then
  begin
    cmbFind.Items.Insert(0, key);
    if cmbFind.Items.Count > 10 then cmbFind.Items.Delete(10);
  end;

  if chkFindTop.Checked then findType := 1;
  if not chkFindZenHan.Checked then key := convToHalfAnk(key);

  lstFind.Clear;
  if key = '' then Exit;

  for i := 0 to edtActive.Lines.Count - 1 do
  begin
    s := edtActive.Lines.Strings[i];
    s := Trim(s);
    // コメント区切り線は検索しないように
    if Copy(s,1,8) = '#-------' then Continue;
    if Copy(s,1,8) = '//------' then Continue;
    if not chkFindZenHan.Checked then s := convToHalfAnk(s);
    case findType of
      0:   ok := findNormal(s);
      1:   ok := findLeft(s);
      else ok := False;
    end;
    if ok then lstFind.Items.Add(IntToStr(i)+#9+s);
  end;
end;

procedure TfrmNakopad.lstFindDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  s: string;
begin
  s := TListBox(Control).Items[Index];
  getToken_s(s, #9);
  if Copy(s,1,1) = '"' then s := Copy(s,2,Length(s)-2);

  with TListBox(Control).Canvas do
  begin
    if odFocused in State then
    begin
      Brush.Color := clBlue;
      Font.Color  := clWhite;
    end else
    begin
      if Copy(s,1,1)='+' then
      begin
        Brush.Color := RGB(255,200,200);
      end else
      if (Index mod 2) = 0 then
        Brush.Color := RGB(230,230,230)
      else
        Brush.Color := clWhite;
      Font.Color := clBlack;
    end;
    if Pos('非公開',s)>0 then
    begin
      Font.Color := clGray;
    end;
    Pen.Color := Brush.Color;
    Rectangle(Rect);
    TextOut(Rect.Left + 2, Rect.Top + 2, s);
  end;
end;

procedure TfrmNakopad.btnFindSortClick(Sender: TObject);
var
  c: TCsvSheet;
begin
  c := TCsvSheet.Create;
  try
    c.AsTabText := lstFind.Items.Text;
    c.SortStr(1);
    lstFind.Items.Text := c.AsTabText;
  finally
    c.Free;
  end;
end;

procedure TfrmNakopad.cmbFindKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    btnFindClick(nil);
  end;
end;

procedure TfrmNakopad.mnuInsLineClick(Sender: TObject);
begin
  if edtActive.Row >= 0 then
  begin
    edtActive.Lines.Insert(edtActive.Row, '#-----------------------------------------------------------------------');
  end;
end;

procedure TfrmNakopad.lstFindDblClick(Sender: TObject);
var
  s: string;
  n: Integer;
begin
  if lstFind.ItemIndex < 0 then Exit;
  s := lstFind.Items[lstFind.ItemIndex];
  s := getToken_s(s, #9);
  n := StrToIntDef(s, -1);
  if n < 0 then Exit;
  MoveCur(n+1);
end;

procedure TfrmNakopad.popListFindGotoClick(Sender: TObject);
begin
  lstFindDblClick(nil);
end;

procedure TfrmNakopad.popListFindMem1Click(Sender: TObject);
var
  n: Integer;
  s: string;
begin
  if lstFind.ItemIndex < 0 then Exit;
  s := lstFind.Items.Strings[ lstFind.ItemIndex ];
  n := StrToIntDef( getToken_s(s, #9), -1 );
  if n < 0 then Exit;
  case TMenuItem(Sender).Tag of
    1: edtActive.PutRowMark(n,rm1);
    2: edtActive.PutRowMark(n,rm2);
    3: edtActive.PutRowMark(n,rm3);
    4: edtActive.PutRowMark(n,rm4);
    5: edtActive.PutRowMark(n,rm5);
  end;
end;

procedure TfrmNakopad.btnGroupEnumClick(Sender: TObject);
var
  s: TStringList;
  a: string;
  targetGroup: string;
  target: TKeyValue;
  fs: TStringList;

  procedure _group(a: string);
  var
    kk: TKeyValue;
    b: string;
  begin
    System.Delete(a,1,2); // del ■
    a := JReplace(a, #9,  ' ', True);
    a := JReplace(a, '+', ' ', True);
    targetGroup := getToken_s(a, ' '); //get group.name

    target := TKeyValue.Create; groupList.Add(target);
    target.key := targetGroup;

    // mix groupを得る
    while a <> '' do
    begin
      a := Trim(a);
      b := getToken_s(a, ' ');
      b := Trim(b);
      kk := groupList.FindKey(b);
      if kk <> nil then
      begin
        target.value.AddStrings(kk.value);
      end;
    end;
  end;

  procedure _check(fname: string; s: TStringList);
  var i: Integer; ff, dir: string; p: TStringList; fn: string;
  begin
    fn := ExtractFileName(fname);
    fn := UpperCase(fn);
    if fs.IndexOf(fn) >= 0 then Exit;
    fs.Add(fn);
    
    for i := 0 to s.Count - 1 do
    begin
      a := Trim(convToHalfAnk(s.Strings[i]));
      if Copy(a, 1, 2) = '■' then
      begin
        // group 発見メンバ検索
        _group(a);
        if (cmbGroup.Text = '')or(cmbGroup.Text = targetGroup) then
        begin
          if fname <> '' then ff := '?' + fname + '?' else ff:='';
          lstGroup.Items.Add(ff + IntToStr(i)+#9+targetGroup);
        end;
      end else
      if Copy(a, 1, 2) = '・' then
      begin
        if Pos('非公開', a) > 0 then Continue;
        if target <> nil then
        begin
          // memo: 省略表示しない方が便利
          // if Pos('～',a) > 0 then a := getToken_s(a, '～') + '～';
          if fname <> '' then ff := '?' + fname + '?' else ff:='';
          target.value.Add(ff+IntToStr(i)+#9+a);
        end;
      end else
      if (Copy(a,1,1) = '!')and(Pos('取り込', a) > 0) then
      begin
        if chkGroupInclude.Checked = False then Continue;
        a := JReplace(a, '「','"', True);
        a := JReplace(a, '」','"', True);
        a := JReplace(a, '『','"', True);
        a := JReplace(a, '』','"', True);
        a := JReplace(a, '`','"', True);
        // 取り込み
        getToken_s(a,'"');
        ff := getToken_s(a,'"');
        dir := ExtractFilePath(FFileName);
        if not FileExists(ff) then
        begin
          if FileExists(AppPath+'lib\'+ff) then
          begin
            ff := AppPath + 'lib\' + ff;
          end else
          if FileExists(AppPath + ff) then
          begin
            ff := AppPath + ff;
          end else
          if FileExists(dir + ff) then
          begin
            ff := dir + ff;
          end else
            ff := '';
        end;
        if ff <> '' then begin
          p := TStringList.Create;
          p.LoadFromFile(ff);
          _check(ff, p);
          p.Free;
        end;
      end;
    end;
  end;

begin
  // Clear Filter
  edtGroupFilter.Text := '';
  FreeAndNil(tmpGroupFilter);
  //
  fs := TStringList.Create;
  cmbGroup.Text := convToHalfAnk(cmbGroup.Text);
  cmbGroup.Text := JReplace(cmbGroup.Text, '、','',True);
  cmbGroup.Text := JReplace(cmbGroup.Text, '。','',True);
  cmbGroup.Text := JReplace(cmbGroup.Text, ',','',True);
  cmbGroup.Text := JReplace(cmbGroup.Text, ';','',True);

  if cmbGroup.Text <> '' then
  begin
    cmbGroup.Items.Insert(0, cmbGroup.Text);
  end;

  lstGroup.Clear;
  targetGroup := '';
  target      := nil;
  s := TStringList.Create;
  try
    //--------------------
    // main
    s.Text := edtActive.Lines.Text;
    _check('', s);
    //--------------------
    // autoinclude
    if chkGroupInclude.Checked then
    begin
      case FNakoIndex of
        NAKO_VNAKO:
          begin
            if LowerCase(ExtractFileName(FFilename)) <> 'vnako.nako' then
            begin
              s.LoadFromFile(AppPath+'lib\vnako.nako');
              _check(AppPath + 'lib\vnako.nako',s);
            end;
          end;
        NAKO_GNAKO:
          begin
            if LowerCase(ExtractFileName(FFilename)) <> 'gnako.nako' then
            begin
              s.LoadFromFile(AppPath+'lib\gnako.nako');
              _check(AppPath+'lib\gnako.nako',s);
            end;
          end;
      end;
    end;
  finally
    s.Free;
  end;

  if lstGroup.Count > 0 then
  begin
    lstGroup.ItemIndex := 0;
    lstGroupClick(nil);
  end;

  fs.Free;
end;

procedure TfrmNakopad.lstGroupClick(Sender: TObject);
var
  s: string;
  v: TKeyValue;
begin
  if lstGroup.ItemIndex < 0 then Exit;
  s := lstGroup.Items.Strings[lstGroup.ItemIndex];
  getToken_s(s, #9); s := Trim(s);
  v := groupList.FindKey(s);
  if v <> nil then
  begin
    lstMember.Items.Text := v.value.Text;
  end;
end;

procedure TfrmNakopad.lstGroupDblClick(Sender: TObject);
var
  s,f: string;
  n: Integer;
begin
  if lstGroup.ItemIndex < 0 then Exit;
  s := lstGroup.Items.Strings[lstGroup.ItemIndex];
  f := Trim(getToken_s(s, #9));
  if Copy(f,1,1) = '?' then
  begin
    StatusMsg := f;
  end else
  begin
    n := StrToIntDef(f, -1);
    if n >= 0 then MoveCur(n+1);
  end;
end;

procedure TfrmNakopad.setPanel0(const Value: string);
begin
  FPanel0 := Value;
  Status.Panels[0].Text := Value;
end;

procedure TfrmNakopad.setPanel1(const Value: string);
begin
  FPanel1 := Value;
  Status.Panels[1].Text := Value;
end;

procedure TfrmNakopad.setPanel2(const Value: string);
begin
  FPanel2 := Value;
  Status.Panels[2].Text := Value;
end;

procedure TfrmNakopad.lstMemberDblClick(Sender: TObject);
begin
  popTabListGotoClick(lstMember); Exit;
end;

procedure TfrmNakopad.mnuGotoLineClick(Sender: TObject);
var
  s: string;
begin
  s := InputBox('指定行へ移動', '何行目へ移動しますか？', '');
  if s = '' then Exit;
  MoveCur(StrToIntDef(s, 1));
end;

procedure TfrmNakopad.btnGroupSortClick(Sender: TObject);
var
  c: TCsvSheet;
begin
  c := TCsvSheet.Create;
  try
    //1
    c.AsTabText := lstGroup.Items.Text;
    c.SortStr(1);
    lstGroup.Items.Text := c.AsTabText;
    //2
    c.AsTabText := lstMember.Items.Text;
    c.SortStr(1);
    lstMember.Items.Text := c.AsTabText;
  finally
    c.Free;
  end;
end;

procedure TfrmNakopad.btnCmdEnumClick(Sender: TObject);
var
  i: Integer;
  key, s, h1, h2, name, dispname: string;
  flg: Boolean;
begin
  lstCmd.Clear;
  
  key := cmbCmd.Text;
  key := convToHalfAnk(key);
  key := DeleteGobi(key);
  if key <> '' then
  if cmbCmd.Items.IndexOf(key) = 0 then
  begin
    cmbCmd.Items.Insert(0, key);
    if cmbCmd.Items.Count > 20 then cmbCmd.Items.Delete(20);
  end;

  LoadCommandList;
  lstCmd.Items.BeginUpdate;
  try
    for i := 0 to cmdList.Count - 1 do
    begin
      s := cmdList.Strings[i];
      if s = '' then Continue;
      if s[1] = '+' then begin h1 := s; Continue; end;
      if s[1] = '-' then begin h2 := s; Continue; end;
      //|ナデシコバージョン,"","",100,,変数,なでしこバージョン
      System.Delete(s,1,1); // del '|'
      name      := getToken_s(s, ',');
      dispname  := name;
      if key <> '' then
      begin
        name := DeleteGobi(name);
        flg := False;
        if chkCmdWildcard.Checked then
        begin
          // ワイルドカード検索
          if WildMatchFilename(name, key) then flg := True;
        end else
        begin
          // 部分一致検索
          if Pos(key, name) > 0 then flg := True;
        end;
        // 解説文も検索
        if (flg = False)and(chkCmdDescript.Checked) then
        begin
          if Pos(key, s) > 0 then flg := True;
        end;
      end else flg := True;
      if flg then
      begin
        if (h1 <> '')and(h2 <> '') then
        begin
          lstCmd.Items.Add(#9+h1+h2+''); h2 := '';
          lstCmd.Items.Add(IntToStr(i)+#9+dispname);
        end else
        begin
          lstCmd.Items.Add(IntToStr(i)+#9+dispname);
        end;
      end;
    end;
  finally
    lstCmd.Items.EndUpdate;
  end;
end;

procedure TfrmNakopad.cmbCmdKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    btnCmdEnumClick(nil);
  end;
end;

procedure TfrmNakopad.lstCmdClick(Sender: TObject);
var
  s, info: string;
begin
  if lstCmd.ItemIndex < 0 then Exit;
  s := lstCmd.Items[lstCmd.ItemIndex];

  if Pos(#9, s) = 0 then Exit;

  info := getToken_s(s, #9);
  ShowCommandToBar(cmdList[ StrToIntDef(info, 0)]);
end;

procedure TfrmNakopad.lstCmdDblClick(Sender: TObject);
var
  s, mae, cmd, arg, line: string;
  cur: Integer;

  function _chk(s:string): string;
  begin
    Result := '';
    if s = 'なし' then Exit;

    s := convToHalfAnk(s);
    while Pos('{',s) > 0 do
    begin
      mae := getToken_s(s, '{');
      getToken_s(s,'}');
      s := mae + s;
    end;
    Result := getToken_s(s, '|');
  end;

begin
  s := Trim(StatusMsg);
  if s = '' then Exit;
  if pos('【命令】', s) > 0 then
  begin
    // 余分なところを消す
    getToken_s(s, '】');
    cmd := Trim(getToken_s(s, '【'));
    getToken_s(s, '】');
    arg := _chk(Trim(getToken_s(s, '【')));
    // 挿入時引数をつけるか？
    if mnuInsCmdNeedArg.Checked then
    begin
      // 引数が全部アルファベットか？
      if arg = '' then
      begin
        line := cmd;
      end else
      if IsHalfStr(arg) then
      begin
        line := cmd + '(' + arg + ')';
      end else
      begin
        line := arg + cmd;
      end;
    end else
    begin
      line := cmd;
    end;
  end else
  begin
    // 余分なところを消す
    getToken_s(s, '】');
    cmd := Trim(getToken_s(s, '【'));
    line := cmd;
  end;
  cur := edtActive.SelStart;
  edtActive.SelText := line + #13#10;
  edtActive.SetFocus;
  edtActive.SelStart := cur;
end;

procedure TfrmNakopad.cmbGroupKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then btnGroupEnumClick(nil);
end;

procedure TfrmNakopad.btnVarEnumClick(Sender: TObject);
var
  s, key: string;
  files: TStringList;
  src: TStringList;

  procedure _check(fname: string; ss: TStrings);
  var
    i : Integer;
    w : string;
  begin
    s := UpperCase(ExtractFileName(fname));
    if files.IndexOf(s) >= 0 then Exit; // 重複取り込みはしない
    files.Add(s);

    if fname <> '' then fname := '?' + fname + '?';

    for i := 0 to ss.Count - 1 do
    begin
      s := convToHalfAnk(ss.Strings[i]);
      if s = '' then Continue;

      // 検索
      if (Pos('とは', s) > 0) then
      begin
        if (key <> '') then
        begin
          w := s;
          w := getToken_s(w, 'とは');
          if Copy(w,1,1) = '!' then System.Delete(w,1,1);
          if w <> key then Continue;
        end;
        // ローカルかチェック
        if s[1] in [' ',#9] then
        begin
          if chkVarLocal.Checked = False then Continue;
        end;
        //
        s := Trim(s);if s='' then Continue;
        lstVar.Items.Add(fname + IntToStr(i) + #9 + s);
      end else
      if Pos('!'+key, s) > 0 then
      begin
        if Pos('取り込',   s) > 0 then Continue;
        if Pos('変数宣言', s) > 0 then Continue;
        s := Trim(s);
        if s='' then Continue;
        lstVar.Items.Add(fname + IntToStr(i) + #9 + s);
      end;
    end;
  end;

begin
  key := Trim(convToHalfAnk( cmbVar.Text ));
  if cmbVar.Items.IndexOf(key) = 0 then
  begin
    cmbVar.Items.Insert(0, key);
    if cmbVar.Items.Count > 20 then cmbVar.Items.Delete(20);
  end;

  lstVar.Clear;

  // 検索
  key := convToHalfAnk(key);

  files := TStringList.Create;
  src   := TStringList.Create;

  try

    _check('', edtActive.Lines);
    case FNakoIndex of
      NAKO_VNAKO:
        begin
          src.LoadFromFile(AppPath + 'lib\vnako.nako');
          _check('lib\vnako.nako', src);
        end;
      NAKO_GNAKO:
        begin
          src.LoadFromFile(AppPath + 'lib\gnako.nako');
          _check('lib\gnako.nako', src);
        end;
    end;

  finally
    src.Free;
    files.Free;
  end;

end;

procedure TfrmNakopad.btnVarSortClick(Sender: TObject);
var
  c: TCsvSheet;
begin
  c := TCsvSheet.Create;
  try
    //1
    c.AsTabText := lstVar.Items.Text;
    c.SortStr(1);
    lstVar.Items.Text := c.AsTabText;
  finally
    c.Free;
  end;
end;

procedure TfrmNakopad.lstVarDblClick(Sender: TObject);
begin
  popTabListGotoClick(lstVar);
end;

procedure TfrmNakopad.btnFuncEnumClick(Sender: TObject);
var
  s, key: string;
  fs: TStringList;

  procedure FindList(list: TStrings; fname: string);
  var i : Integer; line: string; f, dir: string; p: TStringList;
  begin
    f := UpperCase(ExtractFileName(fname));
    if fs.IndexOf(f) >= 0 then Exit;
    fs.Add(f);
    
    for i := 0 to list.Count - 1 do
    begin
      line := list.Strings[i];
      s := convToHalfAnk(line);
      if s='' then Continue;

      // 取り込むの解析
      if (Copy(s,1,1) = '!')and(Pos('取り込',s) > 0) then
      begin
        s := JReplace(s, '「', '"', True);
        s := JReplace(s, '」', '"', True);
        s := JReplace(s, '『', '"', True);
        s := JReplace(s, '』', '"', True);
        GetToken('"', s);
        f := GetToken('"',s);
        dir := ExtractFilePath(FFileName);
        p := TStringList.Create;
        if FileExists(AppPath + 'lib\' + f) then
        begin
          f := AppPath + 'lib\' + f;
        end else
        if FileExists(dir + f) then
        begin
          f := dir + f;
        end else
          Continue;
        p.LoadFromFile(f);
        FindList(p, f);
      end;

      if (Copy(s,1,2)='●')or(Copy(s,1,1)='*') then
      begin
        if Copy(s,1,2) = '●' then
        begin
          System.Delete(s,1,2);
        end else
        begin
          System.Delete(s,1,1);
        end;
        s := DeleteGobi(s);
        s := DeleteJosi(s);
        if (key <> '')and(Pos(key, s)=0) then Continue;
        s := Trim(s);
        if fname = '' then
        begin
          lstVar.Items.Add(IntToStr(i) + #9 + line);
        end else
        begin
          lstVar.Items.Add('?'+fname+'?'+IntToStr(i) + #9 + line);
        end;
      end;
    end;
  end;

begin
  fs := TStringList.Create;
  //
  key := Trim(convToHalfAnk( cmbVar.Text ));
  key := DeleteGobi(key);
  key := DeleteJosi(key);

  if cmbVar.Items.IndexOf(key) = 0 then
  begin
    cmbVar.Items.Insert(0, key);
    if cmbVar.Items.Count > 20 then cmbVar.Items.Delete(20);
  end;

  // 検索
  lstVar.Clear;
  FindList(edtActive.Lines, '');
  //
  fs.Free;
end;

procedure TfrmNakopad.edtBDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  r,c: Integer;
begin
  if (Source is TListBox)or(Source is TListView) then
  begin
    edtActive.PosToRowCol(X,Y,r,c,True);
    edtActive.SetRowCol(r,c);
    edtActive_setFocus ;

    Accept := True;
  end;
end;

procedure TfrmNakopad.popTabListInsClick(Sender: TObject);
var
  line: string;
  tab: TTabSheet;
  name: string;
begin
  if Sender is TMenuItem then
  begin
    tab := pageLeft.ActivePage;
    if tab = sheetAction then Sender := lstAction else
    if tab = sheetFind   then Sender := lstFind   else
    if tab = sheetCmd    then Sender := lstCmd    else
    if tab = sheetVar    then Sender := lstVar    else
    if tab = sheetTree   then Sender := viewCmd   else
    if tab = sheetGui    then Sender := lstGuiProperty else
    if tab = sheetGroup  then
    begin
      Sender := frmNakopad.ActiveControl;
    end else Exit;
  end;

  if not((Sender is TListBox)or(Sender is TListView)) then Exit;
  
  if Sender = lstGuiProperty then
  begin
    lstGuiPropertyDblClick(nil); Exit;
  end;
  //
  if Sender is TListView then
  begin
    if TListView(Sender).Selected = nil then Exit;
    viewCmdDblClick(nil); Exit;
  end;
  //
  if Sender = lstCmd then
  begin
    popInsCmdClick(nil); Exit;
  end;

  //
  if TListBox(Sender).ItemIndex < 0 then Exit;
  line := TListBox(Sender).Items[ TListBox(Sender).ItemIndex ];
  getToken_s(line, #9);
  line := Trim(line);

  if Sender = lstVar then
  begin
    line := convToHalfAnk(line);
    if (Copy(line,1,2) = '●') then // 面倒なので * は未対応
    begin
      System.Delete(line,1,2);
      name := getToken_s(line, '(');
      line := getToken_s(line, ')');
      line := getToken_s(line, '|');
      if line <> '' then name := name + '(' + line + ')';
      line := name;
    end;
    if Pos('とは', line) > 0 then
    begin
      line := getToken_s(line, 'とは');
    end;
  end;
  if Sender = lstMember then
  begin
    line := convToHalfAnk(line);
    if (Copy(line,1,2) = '・') then
    begin
      System.Delete(line,1,2);
      line := getToken_s(line, '～');
      line := getToken_s(line, '#');
      line := getToken_s(line, '＃');
      line := getToken_s(line, '←');
      line := getToken_s(line, '→');
      // { ... } の切り取り
      while PosA('{', line) > 0 do begin
        name := GetToken_s(line, '{');
        GetToken_s(line,'}');
        line := name + line;
      end;
      if PosA('(',line) > 0 then
      begin
        // カッコを逆にするか？
        if not IsHalfStr(line) then
        begin
          name := getToken_s(line, '(');
          line := getToken_s(line,')');
          if line = '' then line := name else line := line + name;
        end;
      end;
    end;
  end;
  edtActive.SelText := line + #13#10;
end;

procedure TfrmNakopad.popTabListGotoClick(Sender: TObject);
var
  line, f: string;
  n: Integer;
begin
  if Sender is TMenuItem then
  begin
    Sender := Self.ActiveControl;
  end;

  if not(Sender is TListBox) then Exit;
  if TListBox(Sender).ItemIndex < 0 then Exit;
  line := TListBox(Sender).Items[ TListBox(Sender).ItemIndex ];

  // ファイル内？ファイル外？
  f := getToken_s(line, #9);
  if Copy(f,1,1) = '?' then
  begin
    System.Delete(f,1,1);
    line := f;
    f := getToken_s(line, '?');
    RunApp('"' + ParamStr(0) + '" "-open?' + f + '" -lineno?'+ IntToStr(StrToIntDef(line,0)+1));
  end else
  begin
    n := StrToIntDef(f, -1);
    if n < 0 then Exit;
    MoveCur(n+1);
  end;
end;

procedure TfrmNakopad.edtBDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  if (Source is TListBox)or(Source is TListView) then
  begin
    popTabListInsClick(Source);
  end;
end;

procedure TfrmNakopad.showRowCol;
begin
  StatusInfo := Format('行列 %3d,%3d',[ edtActive.Row, edtActive.Col]);
end;
{
KEY.MEMO
------------------
IMEなしENTER   Up:13(1):Press:13(1):Down:13(2)
IMEありENTER   Up:229(3):Press:130(3)...Up:13(3)
}
procedure TfrmNakopad.autoIndent;
var
  lines, indent, ch: string;
  i, arow, brow, tab: Integer;
begin
  //---
  indent := ''; tab := 0;
  arow   := edtActive.Row - 1;
  brow   := arow + 1;
  if arow <= 0 then
  begin
    arow := 0;
    brow := 1;
  end;
  while edtActive.Lines.Count <= brow do edtActive.Lines.Add('');
  
  lines  := edtActive.LineString(arow);
  i := 1;
  while i <= Length(lines) do
  begin
    if lines[i] in [' ',#9] then
    begin
      if lines[i] = #9 then tab := tab + 4 else tab := tab + 1;
      indent := indent + lines[i];
      Inc(i); Continue;
    end else
    if lines[i] in LeadBytes then
    begin
      ch := lines[i]+lines[i+1];
      if ch = '　' then
      begin
        indent := indent + ch; tab := tab + 2;
        Inc(i, 2); Continue;
      end else Break;
    end else Break;
  end;
  edtActive.Lines.Strings[brow] := indent + edtActive.Lines.Strings[brow];
  edtActive.SetRowCol(brow, tab);
end;
procedure TfrmNakopad.edtBKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  showRowCol;
  if (FCodeDown = 13)and(FCodePress = 13)and(Key = 13) then
  begin
    autoIndent;
    Exit;
  end;
  FCodeDown := 0; FCodePress := 0;
end;

procedure TfrmNakopad.edtBKeyPress(Sender: TObject; var Key: Char);
begin
  FCodePress := Ord(Key);
  showRowCol;
end;

procedure TfrmNakopad.edtBKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  FCodeDown := Key;
  showRowCol;
  // Check Tab Back
  if Key = VK_ESCAPE then
  begin
    if FLastTab <> nil then pageLeft.ActivePage := FLastTab;
    Exit;
  end else
  ;
end;

procedure TfrmNakopad.edtBMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  showRowCol;
end;

procedure TfrmNakopad.mnuMakeExeClick(Sender: TObject);
begin
  if FModified then
  begin
    ShowWarn('実行ファイルを作る前に念のため保存してください。');
    Exit;
  end;
  //
  if (not FileExists(ReportFile)) then
  begin
    if FileExists(ReportFile) then DeleteFile(ReportFile);
    // --- 自動実行する ---
    edtActive.Lines.Insert(0, '終わる');
    RunProgram(True);
    edtActive.Lines.Delete(0);
    edtActive.Modified := False;
  end;
  if frmMakeExe.dlgSave.FileName = '' then
  begin
    frmMakeExe.dlgSave.FileName := ChangeFileExt(FFileName, '.exe');
  end;
  frmMakeExe.ShowModal;
end;

procedure TfrmNakopad.lstActionDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  s: string;
  x: Integer;
begin
  x := 0;
  s := TListBox(Control).Items[Index];
  s := getToken_s(s, ',');

  with TListBox(Control).Canvas do
  begin
    if odFocused in State then
    begin
      Brush.Color := clBlue;
      Font.Color  := clWhite;
      if Copy(s,1,1) = '+' then
        x := 0
      else
        x := 16;
    end else
    begin
      if Copy(s,1,1)='+' then
      begin
        Brush.Color := RGB(255,200,200);
      end else
      begin
        if (Index mod 2) = 0 then
          Brush.Color := RGB(230,230,230)
        else
          Brush.Color := clWhite;
        x := 16;
      end;
      Font.Color := clBlack;
    end;
    Pen.Color := Brush.Color;
    Rectangle(Rect);
    TextOut(x + Rect.Left + 2, Rect.Top + 2, s);
  end;
end;

procedure TfrmNakopad.lstActionClick(Sender: TObject);
var
  s: string;
  cap, fname: string;

  function showDescript(path: string): Boolean;
  begin
    Result := False;
    fname := path + 'tools\action\' + fname;
    if not FileExists(fname) then Exit;
    StatusMsg := 'リストをダブルクリックするとウィザードを実行できます。';
    ReadTextFile(fname, s);
    getToken_s(s, '/*');
    s := getToken_s(s, '*/');
    edtAction.Lines.Text := Trim(s) + #13#10#13#10 + '→リストをダブルクリックすると実行できます。';
    Result := True;
  end;

begin
  if lstAction.ItemIndex < 0 then Exit;
  s := lstAction.Items.Strings[lstAction.ItemIndex];
  cap   := getToken_s(s, ',');
  fname := s;
  //
  if showDescript(AppPath)  then Exit;
  if showDescript(FUserDir) then Exit;
end;


procedure TfrmNakopad.lstActionDblClick(Sender: TObject);
var
  s: string;
  cap, fname: string;
begin
  if lstAction.ItemIndex < 0 then Exit;
  s := lstAction.Items.Strings[lstAction.ItemIndex];
  cap   := getToken_s(s, ',');
  fname := Trim(s);
  //
  fname := Trim(AppPath+'tools\action\'+fname);
  if not FileExists(fname) then Exit;
  RunApp(AppPath+'vnako.exe "'+fname+'" -debug::'+IntToStr(Self.Handle));
end;

procedure TfrmNakopad.mnuHokanClick(Sender: TObject);
var
  s, c: string;
  i: Integer;
begin
  TangoSelect;
  s := Trim(DeleteGobi(edtActive.SelText));
  s := Trim(DeleteJosi(s));
  if s = '' then Exit;

  //----------------------------------------------------------------------------
  // もしかして命令？
  cmbCmd.Text := s;
  chkCmdDescript.Checked := False;
  btnCmdEnumClick(nil);
  if lstCmd.Items.Count > 0 then
  begin
    pageLeft.ActivePage := sheetCmd;
    for i := 0 to lstCmd.Count - 1 do
    begin
      s := lstCmd.Items.Strings[i];
      c := getToken_s(s, #9);
      if Copy(s,1,1) <> '+' then
      begin
        lstCmd.ItemIndex := i;
        lstCmdClick(nil);
        Break;
      end;
    end;
    lstCmd.SetFocus;
  end;
  
  //----------------------------------------------------------------------------
  // もしかして変数？
  cmbVar.Text := s;
  chkVarLocal.Checked := True;
  btnVarEnumClick(nil);
  if lstVar.Count > 0 then
  begin
    // 特定ができている
    if lstVar.Count = 1 then
    begin
      s := lstVar.Items[0]; // (no)\t(xxxとはxxx)
      c := getToken_s(s, 'とは');
      s := convToHalfAnk(s);
      if (Pos('#', s) > 0) then
      begin
        s := GetToken('#', s);
      end else
      if (Pos('※', s) > 0) then
      begin
        s := GetToken('※', s);
      end else
      if (Pos('//', s) > 0) then
      begin
        s := GetToken('//', s);
      end;

      // s がグループ名？
      cmbGroup.Text := s;
      btnGroupEnumClick(nil);
      if lstGroup.Count > 0 then
      begin
        if pageLeft.ActivePage <> sheetGroup then FLastTab := pageLeft.ActivePage;
        pageLeft.ActivePage := sheetGroup;
        lstMember.SetFocus;
        if lstMember.Count > 0 then lstMember.ItemIndex := 0;
      end else
      begin
        if pageLeft.ActivePage <> sheetVar then FLastTab := pageLeft.ActivePage;
        pageLeft.ActivePage := sheetVar;
      end;
    end else
    begin
      if pageLeft.ActivePage <> sheetVar then FLastTab := pageLeft.ActivePage;
      pageLeft.ActivePage := sheetVar;
    end;
    Exit;
  end;
  btnFuncEnumClick(nil);
  if lstVar.Count > 0 then
  begin
    if pageLeft.ActivePage <> sheetVar then FLastTab := pageLeft.ActivePage;
    pageLeft.ActivePage := sheetVar;
    Exit;
  end;

  //----------------------------------------------------------------------------
  // もしかしてグループ？
  cmbGroup.Text := s;
  btnGroupEnumClick(nil);
  if lstGroup.Count > 0 then
  begin
    if pageLeft.ActivePage <> sheetGroup then FLastTab := pageLeft.ActivePage;
    pageLeft.ActivePage := sheetGroup;
    Exit;
  end;

end;

procedure TfrmNakopad.TangoSelect;
var
  line, token,s: string;
  p: PChar;
  len, i: Integer;

  function _comp(p: PChar; s:string): Boolean;
  begin
    Result := (StrLComp(PChar(s), p, Length(s)) = 0);
  end;

  procedure IsJosi(p: PChar; var len: Integer); // 1 以上なら助詞
    function comp(s:string): Integer;
    begin
      if StrLComp(PChar(s), p, Length(s)) = 0 then
      begin
        Result := Length(s);
      end else
      begin
        Result := 0;
      end;
      len := Result;
    end;
  begin
    len := 0;
    if comp('でなければ')>0 then Exit;
    if comp('について')>0 then Exit;
    if comp('くらい')>0 then Exit;
    if comp('なのか')>0 then Exit;
    if comp('として')>0 then Exit;
    if comp('ならば')>0 then Exit;
    if comp('までを')>0 then Exit;
    if comp('までの')>0 then Exit;
    if comp('まで')>0 then Exit;
    if comp('とは')>0 then Exit;
    if comp('なら')>0 then Exit;
    if comp('から')>0 then Exit;
    if comp('して')>0 then Exit;
    if comp('だけ')>0 then Exit;
    if comp('より')>0 then Exit;
    if comp('ほど')>0 then Exit;
    if comp('など')>0 then Exit;
    if comp('って')>0 then Exit;
    if comp('では')>0 then Exit;
    if comp('て')>0 then Exit;
    if comp('で')>0 then Exit;
    if comp('を')>0 then Exit;
    if comp('の')>0 then Exit;
    if comp('が')>0 then Exit;
    if comp('に')>0 then Exit;
    if comp('へ')>0 then Exit;
    if comp('と')>0 then Exit;
    if comp('は')>0 then Exit;
  end;

begin
  if edtActive.Row >= edtActive.Lines.Count then Exit;
  line := edtActive.Lines[ edtActive.Row ];
  if line = '' then Exit;
  FLineTokens.Clear;

  //-------------------------
  // 適当にトークンを区切る
  p := PChar(line);
  token := '';
  while p^ <> #0 do
  begin
    // line Break?
    // 助詞？
    IsJosi(p, len);
    if len > 0 then
    begin
      SetLength(s, len); StrLCopy(@s[1],p, len);
      token := token + PChar(s);
      FLineTokens.Add(token);
      token := '';
      Inc(p,len);
    end;
    // 区切り？
    if p^ in LeadBytes then
    begin
      if
        _comp(p, '「') or _comp(p,'」') or _comp(p,'『') or _comp(p,'』') or
        _comp(p, '、') or _comp(p,'，') or _comp(p,'（') or _comp(p,'）') or
        _comp(p, '！') or _comp(p,'”') or _comp(p,'＂') or _comp(p,'‘') or
        _comp(p, '＃') or _comp(p,'＆') or _comp(p,'％') or _comp(p,'＝') or
        _comp(p, '＋') or _comp(p,'－') or _comp(p,'＊') or _comp(p,'×') or
        _comp(p, '÷') or _comp(p,'；') or _comp(p,'　') or _comp(p,'＠') or
        _comp(p, '。') or _comp(p,'→') or _comp(p,'←') or _comp(p,'■') or
        _comp(p, '●') or _comp(p,'・') or _comp(p,'？') or _comp(p,'～')
      then begin
        FLineTokens.Add(token); token := '';
        FLineTokens.Add(p^ + (p+1)^); Inc(p, 2);
      end else
      begin
        token := token + p^ + (p+1)^; Inc(p,2);
      end;
    end else
    begin
      if p^ in ['A'..'Z','a'..'z','0'..'9','_'] then
      begin
        token := token + p^; Inc(p);
      end else
      begin
        // break
        FLineTokens.Add(token);
        token := '';
        FLineTokens.Add(p^);
        Inc(p);
      end;
    end;
  end;
  if token <> '' then FLineTokens.Add(token);
  // 選択範囲を得る
  len := 0;
  for i := 0 to FLineTokens.Count - 1 do
  begin
    s := FLineTokens.Strings[i];
    if edtActive.Col <= (len + Length(s)) then
    begin
      edtActive.Col := len;
      edtActive.SelLength := Length(s);
      FLineCurToken := i;
      Break;
    end;
    if i = (FLineTokens.Count-1) then
    begin
      edtActive.Col := len;
      edtActive.SelLength := Length(s);
      FLineCurToken := i;
      Break;
    end;
    Inc(len, Length(s));
  end;

end;

procedure TfrmNakopad.edtBDblClick(Sender: TObject);
begin
  TangoSelect;
  if (edtActive.Fountain = NadesikoFountain)or(edtActive.Fountain = NadesikoFountainBlack) then
  begin
    pageLeft.ActivePage := sheetCmd;
    SelectWordFindCommand;
  end;
end;

procedure TfrmNakopad.lstCmdKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    popInsCmdClick(Sender);
    edtActive_setFocus;
  end else
  if Key = #27 then
  begin
    edtActive_setFocus;
  end;
end;

procedure TfrmNakopad.popInsCmdClick(Sender: TObject);
begin
  lstCmdDblClick(nil);
end;

procedure TfrmNakopad.mnuEditFontClick(Sender: TObject);
begin
  dlgFont.Font := edtActive.Font;
  if dlgFont.Execute = False then Exit;

  edtProp.Font.Assign(dlgFont.Font);
  edtProp.AssignTo(edtA);
  edtProp.AssignTo(edtB);

  ini.WriteString ('Edit','Font.Name', edtA.Font.Name);
  ini.WriteInteger('Edit','Font.Size', edtA.Font.Size);

  CheckColorMode;
end;

procedure TfrmNakopad.FormShow(Sender: TObject);
var
  i: Integer;
  fname, cmd, sub: string;
  ws: TWindowState;
  ini_key: string;
begin
  SetColorMode;
  ws := TWindowState( ini.ReadInteger('pad', 'WindowState', Ord(wsNormal)) );
  if ws = wsMaximized then
  begin
    Application.ProcessMessages;
    Self.WindowState := wsMaximized;
  end;

  // パラメーターを読む
  i := 1; fname := '';
  while i <= ParamCount do
  begin
    sub := ParamStr(i);
    cmd := getToken_s(sub, '?');
    // コマンドラインごとの実行
    if cmd = '-lineno' then
    begin
      MoveCur(StrToIntDef(sub, 0));
    end else
    if cmd = '-open' then
    begin
      OpenFile(sub);
    end else
    begin
      OpenFile(cmd);
    end;
    Inc(i);
  end;

  // todo: 商用版のみの特典を反映
  ini_key := ini.ReadString('license', 'key', 'xxx');
  if chk_nakopad_key(ini_key) then
  begin
    changeProLicense(True);
  end;
end;

procedure TfrmNakopad.pageLeftChange(Sender: TObject);
begin
  if pageLeft.ActivePage = sheetTree then
  begin
    makeCmdTree;
  end else
  if pageLeft.ActivePage = sheetGui then
  begin
    makeGuiPage;
  end else
  // design mode ?
  if pageLeft.ActivePage = sheetDesignProp then
  begin
    pageMain.ActivePage := tabDesign;
    source2design;
    getGUIPartsList;
  end else
  begin
    pageMain.ActivePage := tabSource;
  end;
end;

procedure TfrmNakopad.makeCmdTree;
var
  t, tt: TTreeNode;
  i: Integer;
  c: Char;
  s, cmd: string;
begin
  // make
  if treeCmd.Items.Count > 0 then Exit;
  LoadCommandList;
  //
  t := nil; treeCmd.Items.Clear;
  for i := 0 to cmdList.Count - 1 do
  begin
    s := cmdList.Strings[i];
    if s = '' then Continue;
    cmd := Trim(getToken_s(s, ','));
    c   := cmd[1];
    System.Delete(cmd,1,1);
    case c of
      '+':
        begin
          t := treeCmd.Items.Add(nil, cmd);
          t.ImageIndex    := 2;
          t.SelectedIndex := 3;
        end;
      '-':
        begin
          if t = nil then treeCmd.Items.Add(nil, cmd);
          tt := treeCmd.Items.AddChild(t, cmd);
          tt.ImageIndex    := 0;
          tt.SelectedIndex := 1;
        end;
    end;
  end;
end;

procedure TfrmNakopad.treeCmdClick(Sender: TObject);
var
  h1, h2: string;
  i, j, k: Integer;
  s, cmd, c, ss: string;
  t: TListItem;
  v: TCsvSheet;
begin
  if treeCmd.Selected = nil then Exit;
  if treeCmd.Selected.Parent = nil then Exit;

  viewCmd.Clear; ss := '';
  csvCommand.Clear;
  h1 := '+'+treeCmd.Selected.Parent.Text;
  h2 := '-'+treeCmd.Selected.Text;
  for i := 0 to cmdList.Count - 1 do
  begin
    // command
    s := cmdList.Strings[i];
    if s='' then Exit;
    cmd := Trim(getToken_s(s, ','));
    if cmd = h1 then
    begin
      for j := i+1 to cmdList.Count - 1 do
      begin
        // sub command
        s := cmdList.Strings[j];
        cmd := Trim(getToken_s(s, ','));
        if cmd = h2 then
        begin
          for k := j+1 to cmdList.Count - 1 do
          begin
            s   := cmdList.Strings[k];
            if s = '' then Continue;
            c   := s[1];
            if c <> '|' then Break;
            // view に追加
            t := viewCmd.Items.Add;
            // コマンドの１文字を削除
            System.Delete(s, 1, 1);
            ss  := ss + s + #13#10;
            //--- 命令によってアイコンを変える
            v := TCsvSheet.Create;
            v.AsText := s;
            if v.Cells[5,0] = '命令' then t.ImageIndex := 5
                                     else t.ImageIndex := 4;
            v.Free;
            //--- 命令名をつける
            cmd := Trim(getToken_s(s, ','));
            t.Caption := cmd;
          end;
          // ステータスバーに表示するデータ
          csvCommand.AsText := ss; // set
          Exit;
        end;
      end;
    end;
  end;
end;

procedure TfrmNakopad.viewCmdClick(Sender: TObject);
var
  s: string;
  i: Integer;
begin
  //--------------------------------------
  if viewCmd.Selected = nil then Exit;
  s := viewCmd.Selected.Caption;
  i := csvCommand.FindStr(0, s);
  if i < 0 then Exit;
  ShowCommandToBar('|'+csvCommand.Rows[i].GetCommaText);
end;

procedure TfrmNakopad.viewCmdDblClick(Sender: TObject);
begin
  lstCmdDblClick(nil);
end;

procedure TfrmNakopad.mnuViewSheetActionClick(Sender: TObject);
begin
  mnuViewSheetAction.Checked := not mnuViewSheetAction.Checked;
  sheetAction.TabVisible := mnuViewSheetAction.Checked;
  ini.WriteBool('tab', 'sheetAction.visible', sheetAction.TabVisible);
end;

procedure TfrmNakopad.mnuViewSheetGroupClick(Sender: TObject);
begin
  mnuViewSheetGroup.Checked := not mnuViewSheetGroup.Checked;
  sheetGroup.TabVisible := mnuViewSheetGroup.Checked;
  ini.WriteBool('tab', 'sheetGroup.visible', sheetGroup.TabVisible);
end;

procedure TfrmNakopad.mnuViewSheetTreeClick(Sender: TObject);
begin
  mnuViewSheetTree.Checked := not mnuViewSheetTree.Checked;
  sheetTree.TabVisible := mnuViewSheetTree.Checked;
  ini.WriteBool('tab', 'sheetTree.visible', sheetTree.TabVisible);
end;

procedure TfrmNakopad.SelectWordFindCommand;
var
  s: string;
  c, key,cmd: string;
  i: Integer;
  flg: Boolean;
begin
  key := Trim(edtActive.SelText);
  key := DeleteGobi(key);
  key := DeleteJosi(key);

  LoadCommandList;

  //--- 命令か？
  flg := False;
  for i := 0 to cmdList.Count - 1 do
  begin
    s := cmdList.Strings[i];
    c := Copy(s,1,1)+'-';
    if c[1] in ['+','-'] then Continue;
    cmd := Trim(getToken_s(s, ','));
    System.Delete(cmd,1,1);
    cmd := DeleteGobi(cmd);
    if cmd = key then
    begin
      ShowCommandToBar(cmdList.Strings[i]);
      // hint
      s := StatusMsg;
      edtActive.Hint := s;
      edtActive.ShowHint := True;
      // customize hint
      Application.HintPause := 50;
      flg := True;
      Break;
    end;
  end;

  if flg = False then
  begin
    edtActive.ShowHint := False;
    mnuHokanClick(nil);
  end;

end;

procedure TfrmNakopad.LoadCommandList;
begin
  if cmdList.Count = 0 then
  begin
    // ユーザーフォルダの中も読み込むようにする
    appendFileToStringsAppAndUser(COMMAND_TXT, cmdList);
  end;
end;

procedure TfrmNakopad.ShowCommandToBar(line: string);
var
  cmd, arg, descript, id, dummy, ctype, yomi: string;
  c: TCsvSheet;
begin
  if line = '' then Exit;

  c := TCsvSheet.Create;
  c.AsText := line;
  //
  cmd      := Trim(c.Cells[0,0]); if cmd = '' then Exit; System.Delete(cmd,1,1);
  arg      := Trim(c.Cells[1,0]);
  descript := Trim(c.Cells[2,0]);
  id       := Trim(c.Cells[3,0]);
  dummy    := Trim(c.Cells[4,0]);
  ctype    := Trim(c.Cells[5,0]);
  yomi     := Trim(c.Cells[6,0]);
  //
  c.Free;
  //
  if arg = '' then arg := 'なし';
  if ctype = '命令' then
  begin
    //StatusMsg := '(ID:'+id+')【命令】'+cmd+' 【引数】'+arg+' 【解説】'+descript;
    StatusMsg := '【命令】'+cmd+'【引数】'+arg+' 【解説】'+descript;
  end else
  begin
    //StatusMsg := '(ID:'+id+')【変数】'+cmd+' 【定義】'+arg+' 【解説】'+descript;
    StatusMsg := '【変数】'+cmd+'【定義】'+arg+' 【解説】'+descript;
  end;
  lstCmd.ShowHint := True;
  lstCmd.Hint     := StatusMsg;
  //
  cmbCmd.Text := cmd;
  memCommand.Text := StatusMsg;
end;

procedure TfrmNakopad.mnuRunSpeed0Click(Sender: TObject);
begin
  FSpeed := TMenuItem(Sender).Tag;
end;

procedure TfrmNakopad.edtBDropFiles(Sender: TObject; Drop,
  KeyState: Integer; Point: TPoint);
var
  i: Integer;
begin
  // ---
  if edtActive.DropFileNames.Count <= 0 then Exit;

  if mnuUseNewWindow.Checked then
  begin
    for i := 0 to edtActive.DropFileNames.Count - 1 do
    begin
      RunApp('"'+ParamStr(0)+'" "'+edtActive.DropFileNames.Strings[i]);
    end;
    Exit;
  end;

  // ---
  if CheckSave then Exit;
  OpenFile( edtActive.DropFileNames.Strings[0] );
end;

procedure TfrmNakopad.cmbFindEnter(Sender: TObject);
begin
  cmbFindActive := cmbFind;
end;

procedure TfrmNakopad.cmbGroupEnter(Sender: TObject);
begin
  cmbFindActive := cmbGroup;
end;

procedure TfrmNakopad.cmbVarEnter(Sender: TObject);
begin
  cmbFindActive := cmbVar;
end;

procedure TfrmNakopad.cmbCmdEnter(Sender: TObject);
begin
  cmbFindActive := cmbCmd;
end;

procedure TfrmNakopad.mnuImeOnClick(Sender: TObject);
begin
  mnuImeOn.Checked := not mnuImeOn.Checked;
  setEditImeMode;
end;

procedure TfrmNakopad.mnuAboutClick(Sender: TObject);
begin
  //
  if isDelux then
    RunApp('"'+AppPath+'vnako.exe" "'+AppPath+'tools\about.nako" -delux')
  else
    RunApp('"'+AppPath+'vnako.exe" "'+AppPath+'tools\about.nako"');
end;

procedure TfrmNakopad.mnuCol_javaClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to High(FColorModes) do
  begin
    FColorModes[i].menu.Checked := False;
  end;

  i := TMenuItem(Sender).Tag;
  edtA.Fountain := FColorModes[i].fountain;
  edtB.Fountain := edtA.Fountain;
  FColorModes[i].menu.Checked := True;
end;

procedure TfrmNakopad.SetColorMode;
var i: Integer;
begin
  // カラーモード
  for i := 0 to High(FColorModes) do
  begin
    FColorModes[i] := TColorMode.Create;
  end;

  with FColorModes[0] do begin
    menu     := mnuCol_nako;
    if mnuColorBlack.Checked then begin
      fountain := NadesikoFountainBlack
    end else begin
      fountain := NadesikoFountain;
    end;
    ext      := '*.nako';
  end;
  with FColorModes[1] do begin
    menu     := mnuCol_hmw;
    fountain := HimawariFountain1;
    ext      := '*.hmw';
  end;
  with FColorModes[2] do begin
    menu     := mnuCol_Text;
    fountain := nil;
    ext      := '*.txt;*.eml';
  end;
  with FColorModes[3] do begin
    menu     := mnuCol_htm;
    fountain := HTMLFountain1;
    ext      := '*.htm;*.html';
  end;
  with FColorModes[4] do begin
    menu     := mnuCol_pl;
    fountain := PerlFountain1;
    ext      := '*.cgi;*.pl;*.pod;*.pm';
  end;
  with FColorModes[5] do begin
    menu     := mnuCol_pas;
    fountain := DelphiFountain1;
    ext      := '*.pas;*.dpr';
  end;
  with FColorModes[6] do begin
    menu     := mnuCol_java;
    fountain := JavaFountain1;
    ext      := '*.java';
  end;
  with FColorModes[7] do begin
    menu     := mnuCol_cpp;
    fountain := CppFountain1;
    ext      := '*.cpp;*.c;*.h';
  end;
end;

procedure TfrmNakopad.CheckColorMode;
var
  i, j: Integer;
  cm, f: TColorMode;
  s: TStringList;
begin
  if mnuColorBlack.Checked then
  begin
    FColorModes[0].fountain := NadesikoFountainBlack;
    edtA.Color := clBlack;
    edtA.Font.Color := clWhite;
    edtB.Color := edtA.Color;
    edtB.Font.Color := clWhite;
  end;

  cm := FColorModes[0];
  for i := 0 to High(FColorModes) do
  begin
    f := FColorModes[i];
    f.menu.Checked := False;
    s := SplitChar(';', f.ext);
    for j := 0 to s.Count - 1 do
    begin
      if WildMatchFilename(FFileName, s.Strings[j]) then
      begin
        cm := f; Break;
      end;
    end;
    s.Free;
  end;
  // VIEW FLAG
  changeBlankMark( mnuShowBlank.Checked );
  
  // CHANGE
  if edtA.Fountain <> cm.fountain then
  begin
    edtA.Fountain := cm.fountain;
    edtB.Fountain := edtA.Fountain;
    cm.menu.Checked := True;
  end;
end;

procedure TfrmNakopad.JIS1Click(Sender: TObject);
begin
  edtActive.Lines.Text := jis2sjis(edtActive.Lines.Text);
  FOutCode := JIS_OUT;
  ViewOutCode;
end;

procedure TfrmNakopad.EUC1Click(Sender: TObject);
begin
  edtActive.Lines.Text := euc2sjis(edtActive.Lines.Text);
  FOutCode := EUC_OUT;
  ViewOutCode;
end;

procedure TfrmNakopad.UTF8N1Click(Sender: TObject);
begin
  edtActive.Lines.Text := Utf8NTosjis(edtActive.Lines.Text);
  FOutCode := UTF8N_OUT;
  ViewOutCode;
end;

procedure TfrmNakopad.UTF81Click(Sender: TObject);
begin
  edtActive.Lines.Text := Utf8Tosjis(edtActive.Lines.Text);
  FOutCode := UTF8_OUT;
  ViewOutCode;
end;

function nkf2jconvertCode(nkfid: string): Integer;
begin
  nkfid := UpperCase(nkfid);
  if nkfid = 'SHIFT_JIS'   then Result := SJIS_IN   else
  if nkfid = 'EUC-JP'      then Result := EUC_IN    else
  if nkfid = 'ISO-2022-JP' then Result := JIS_OUT   else
  if nkfid = 'UTF-8'       then Result := UTF8_IN   else
  if nkfid = 'UTF-8N'      then Result := UTF8N_IN  else
  if nkfid = 'UTF-16'      then Result := UNILE_IN  else
  Result := 0
  ;
end;


procedure TfrmNakopad.mnuInCodeAutoClick(Sender: TObject);
var
  code,s: string;
begin
  // 出力文字コード
  s := edtActive.Lines.Text;
  code := NkfGuessCode(s);

  // JConvertEx の漢字判定が甘いので、NKFで行う
  // FOutCode := InCodeCheckEx(s);
  FOutCode := nkf2jconvertCode(code);
  
  if s <> '' then
  begin
    if JPosM(#13#10, s) > 0 then FRetCode := CRLF_R else
    if JPosM(#13,    s) > 0 then FRetCode := CR_R   else
    if JPosM(#10,    s) > 0 then FRetCode := LF_R   else
                                 FRetCode := CRLF_R;
  end;

  if FOutCode <> SJIS_IN then
  begin
    s := NkfConvertStr(s, '--sjis', False);
  end;
  //
  edtActive.Lines.Text := s;
  ViewOutCode;
end;

procedure TfrmNakopad.mnuOutSJISClick(Sender: TObject);
begin
  FOutCode := SJIS_OUT;
  ViewOutCode;
end;

procedure TfrmNakopad.mnuOutJISClick(Sender: TObject);
begin
  FOutCode := JIS_OUT;
  ViewOutCode;
end;

procedure TfrmNakopad.mnuOutEUCClick(Sender: TObject);
begin
  FOutCode := EUC_OUT;
  ViewOutCode;
end;

procedure TfrmNakopad.mnuOutUTF8NClick(Sender: TObject);
begin
  FOutCode := UTF8N_OUT;
  ViewOutCode;
end;

procedure TfrmNakopad.mnuRetCRLF1Click(Sender: TObject);
begin
  FRetCode := CRLF_R;
  ViewOutCode;
end;

procedure TfrmNakopad.mnuRetCR1Click(Sender: TObject);
begin
  FRetCode := CR_R;
  ViewOutCode;
end;

procedure TfrmNakopad.mnuRetLF1Click(Sender: TObject);
begin
  FRetCode := LF_R;
  ViewOutCode;
end;

procedure TfrmNakopad.ViewOutCode;

  function OutCode2str(c: Integer): string;
  begin
    case c of
      SJIS_OUT  : Result := 'SJIS';
      JIS_OUT   : Result := 'JIS';
      EUC_OUT   : Result := 'EUC';
      UTF8_OUT  : Result := 'UTF8';
      UTF8N_OUT : Result := 'UTF8N';
      UNILE_OUT : Result := 'UNI';
    end;
  end;

  function OutRet2str(c: Integer): string;
  begin
    case c of
      CRLF_R  : Result := 'CRLF';
      CR_R    : Result := 'CR';
      LF_R    : Result := 'LF';
    end;
  end;

begin
  StatusMemo := OutCode2str(FOutCode) + '+' + OutRet2str(FRetCode);
end;

procedure TfrmNakopad.FormActivate(Sender: TObject);
begin
  edtActive_setFocus;
end;

procedure TfrmNakopad.mnuLookWebClick(Sender: TObject);
var
  s: string;
begin
  s := StatusMsg;
  getToken_s(s, '】');
  s := getToken_s(s, '【');
  s := URLEncode(sjisToUtf8N(s),True);
  OpenApp('http://nadesi.com/man/page/'+s);
end;

procedure TfrmNakopad.mnuWebWriteLinkClick(Sender: TObject);
var
  s: string;
begin
  s := StatusMsg;
  getToken_s(s, '】');
  s := getToken_s(s, '【');
  s := URLEncode(sjisToUtf8N(s),True);
  Clipboard.AsText := s;
  StatusInfo := 'コピー完了'; Beep;
end;

procedure TfrmNakopad.mnuUseNewWindowClick(Sender: TObject);
begin
  mnuUseNewWindow.Checked := not mnuUseNewWindow.Checked;
end;

procedure TfrmNakopad.mnuEditCustomizeClick(Sender: TObject);
var
  e: TEditorExProp;
begin
  //TEditor の設定を表示
  EditEditor(edtA, nil);
  e := TEditorExProp.Create(nil);
  try
    e.Assign(edtA);
    e.WriteIni(AppPath+'nakopad.ini', 'TEditor','a');
  finally
    e.Free;
  end;
  edtB.Assign(edtA);
end;

procedure TfrmNakopad.popFindSelectWordClick(Sender: TObject);
begin
  SelectWordFindCommand;
  mnuLookWebClick(nil);
end;

procedure TfrmNakopad.mnuFindRuigigoClick(Sender: TObject);
begin
  mnuHokanClick(nil);
end;

procedure TfrmNakopad.popTabListPopup(Sender: TObject);
var
  i: Integer;
  s: string;
begin
  // ---------------------------------------------
  popFindDefine.Caption := '定義内容の検索';
  if Self.ActiveControl = lstVar then
  begin
    popFindDefine.Visible := True;

    i := lstVar.ItemIndex;
    if i < 0 then Exit;
    s := lstVar.Items[i];
    if Pos('とは',s) > 0 then
    begin
      s := convToHalfAnk(s);
      popFindDefine.Enabled := True;
      GetToken_s(s, 'とは');
      s := GetToken_s(s, ';');
      s := GetToken_s(s, '。');
      s := GetToken_s(s, '=');
      s := GetToken_s(s, '#');
      s := GetToken_s(s, '//');
      popFindDefine.Caption := '『' + s + '』の定義を検索';
    end else
    begin
      popFindDefine.Enabled := False;
    end;
  end else
  begin
    popFindDefine.Visible := False;
  end;
end;

procedure TfrmNakopad.popFindDefineClick(Sender: TObject);
var
  s: string;
begin
  s := popFindDefine.Caption;
  getToken_s(s, '『');
  s := getToken_s(s, '』');
  if s = '' then Exit;
       if s = '文字列'  then StatusMsg := '文字列です。'
  else if s = '整数'    then StatusMsg := '整数です。'
  else if s = '実数'    then StatusMsg := '整数です。'
  else if s = 'グループ' then StatusMsg := 'グループは変数をまとめるものです。'
  else if s = '配列' then StatusMsg := '配列は複数の変数を格納できる変数です。'
  else if s = 'ハッシュ' then StatusMsg := 'ハッシュは複数の変数を格納できる変数です。'
  else begin
    // 変数？
    cmbVar.Text := s;
    btnVarEnumClick(nil);
    if lstVar.Count > 1 then
    begin
      pageLeft.ActivePage := sheetVar;
      Exit;
    end;
    // グループ？
    cmbGroup.Text := s;
    btnGroupEnumClick(nil);
    if lstGroup.Count > 0 then
    begin
      pageLeft.ActivePage := sheetGroup;
    end else
    begin
      StatusMsg := s + 'は、見つかりませんでした。';
    end;
  end;
end;

procedure TfrmNakopad.mnuInsCmdNeedArgClick(Sender: TObject);
begin
  mnuInsCmdNeedArg.Checked := not mnuInsCmdNeedArg.Checked;
end;

procedure TfrmNakopad.popStatusClick(Sender: TObject);
begin
  mnuViewManClick(nil);
end;

procedure TfrmNakopad.popStatusDescriptInBoxClick(Sender: TObject);
begin
  pageLeft.ActivePage := sheetCmd;
end;

procedure TfrmNakopad.StatusClick(Sender: TObject);
begin
  popStatusDescriptInBoxClick(nil);
end;

procedure TfrmNakopad.StatusDblClick(Sender: TObject);
begin
  popStatusClick(nil);
end;

procedure TfrmNakopad.btnVarClearClick(Sender: TObject);
begin
  lstVar.Clear;
  cmbVar.Clear;
end;

procedure TfrmNakopad.mnuColorBlackClick(Sender: TObject);
begin
  mnuColorBlack.Checked := not mnuColorBlack.Checked;

  if mnuColorBlack.Checked then
  begin
    edtA.Color := clBlack;
    edtA.Font.Color := clWhite;
    edtA.Fountain := NadesikoFountainBlack;
  end else
  begin
    edtA.Color := clWhite;
    edtA.Font.Color := clBlack;
    edtA.Fountain := NadesikoFountain;
  end;
  edtB.Color      := edtA.Color;
  edtB.Font.Color := edtA.Font.Color;
  edtB.Fountain   := edtA.Fountain;
  FColorModes[0].fountain := edtA.Fountain;
  //
  edtC.Color      := edtA.Color;
  edtC.Font.Color := edtA.Font.Color;
  edtC.Fountain   := edtA.Fountain;
end;

procedure TfrmNakopad.lstMemberKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    edtActive_setFocus;
    Exit;
  end;
  if Key = 13 then
  begin
    Key := 0;
    edtActive.SelStart := edtActive.SelStart + edtActive.SelLength;
    edtActive.SelLength := 0;
    edtActive_setFocus;
    popTabListInsClick(lstMember);
  end;
end;

procedure TfrmNakopad.pageLeftChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  FLastTab := pageLeft.ActivePage;
end;

procedure TfrmNakopad.mnuStopAllClick(Sender: TObject);
begin
  send_cmd := 'break-all';
  send_msg := WM_VNAKO_BREAK_ALL;
  EnumWindows(@findNakoStop, Self.Handle);
end;

procedure TfrmNakopad.mnuViewCmdTabClick(Sender: TObject);
begin
  pageLeft.ActivePage := sheetTree;
  makeCmdTree;
  treeCmd.SetFocus;
end;

procedure TfrmNakopad.mnuViewFindTabClick(Sender: TObject);
begin
  pageLeft.ActivePage := sheetFind;
  cmbFind.SetFocus;
end;

procedure TfrmNakopad.mnuViewEditClick(Sender: TObject);
begin
  edtActive_setFocus;
end;

procedure TfrmNakopad.treeCmdKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    treeCmdClick(nil);
    viewCmd.SetFocus;
    Key := #0;
  end;
end;

procedure TfrmNakopad.viewCmdKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_BACK)or(Key = VK_ESCAPE) then
  begin
    treeCmd.SetFocus;
  end;
end;

procedure TfrmNakopad.mnuCopyCmdClick(Sender: TObject);
var
  s: string;
begin
  s := StatusMsg;
  GetToken('】',s);
  s := GetToken('【',s);
  Clipboard.AsText := Trim(s);
  Beep;
end;

procedure TfrmNakopad.mnuWordHelpClick(Sender: TObject);
begin
  SelectWordFindCommand;
end;

procedure TfrmNakopad.mnuSayCmdDescriptClick(Sender: TObject);
begin
  ShowMessage(StatusMsg);
end;

procedure TfrmNakopad.mnuViewManClick(Sender: TObject);
var
  s, line: string;
begin
  s := StatusMsg;
  getToken_s(s, '】');
  s := getToken_s(s, '【');

  line := '"' + AppPath + 'vnako.exe" "' + AppPath + 'tools\WikiRef.nako"' +
    ' "'+s+'"';
  RunApp(line);
end;

procedure TfrmNakopad.mnuOpenSampleClick(Sender: TObject);
begin
  OpenApp(AppPath + 'sample\');
end;

procedure TfrmNakopad.AppEventIdle(Sender: TObject; var Done: Boolean);
begin
  if FFirstTime then
  begin
    FFirstTime := False;
    // ここで何か処理を
    Exit;
  end;
end;

procedure TfrmNakopad.setEditImeMode;
begin
  if mnuImeOn.Checked then
  begin
    SetImeMode(edtA.Handle, imOpen);
    SetImeMode(edtB.Handle, imOpen);
  end else
  begin
    SetImeMode(edtA.Handle, imDontCare);
    SetImeMode(edtB.Handle, imDontCare);
  end;
end;


procedure TfrmNakopad.popActDescCopyClick(Sender: TObject);
begin
  edtAction.CopyToClipboard;
end;

procedure TfrmNakopad.popActDescMoreClick(Sender: TObject);
begin
  popStatusClick(nil);
end;

procedure TfrmNakopad.makeGuiPage;
var
  s: string;
begin
  if lstGuiType.Count > 0 then Exit;
  try
    ReadTextFile(AppPath + GUI_TXT, s);
    getToken_s(s, '<種類>');
    s := getToken_s(s, '</種類>');
    lstGuiType.Sorted := False;
    lstGuiType.Items.Text := Trim(s);
  except
    Exit;
  end;
end;

procedure TfrmNakopad.lstGuiTypeClick(Sender: TObject);
var
  s, tag: string;
  i: Integer;
  sl: TStringList;
begin
  i := lstGuiType.ItemIndex;
  if i < 0 then Exit;
  tag := lstGuiType.Items[i];
  if tag = '' then Exit;
  try
    ReadTextFile(AppPath + GUI_TXT, s);
    getToken_s(s, '<'+tag+'>');
    s := getToken_s(s, '</'+tag+'>');
    sl := TStringList.Create;
    try
      sl.Text := Trim(s);
      sl.Sort;
      lstGuiProperty.Items.Text := sl.Text;
    finally
      sl.Free;
    end;
  except
    Exit;
  end;
end;

procedure TfrmNakopad.lstGuiPropertyDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  cap, s, line: string;
begin
  line := TListBox(Control).Items[Index];
  s := line;
  cap := Trim(getToken_s(s, '#'));

  with TListBox(Control).Canvas do
  begin
    if odFocused in State then
    begin
      Brush.Color := clBlue;
      Font.Color  := clWhite;
    end else
    begin
      Font.Color := clBlack;
      if Pos('～',cap) > 0 then
      begin
        Font.Color := RGB(20,20,80);
      end else
      if Pos('イベント', cap) > 0 then
      begin
        Font.Color := RGB(80,20,20);
      end;
      
      if (Index mod 2) = 0 then
        Brush.Color := RGB(230,230,230)
      else
        Brush.Color := clWhite;
    end;
    Pen.Color := Brush.Color;
    Rectangle(Rect);
    TextOut(Rect.Left + 2, Rect.Top + 2, cap);
  end;
end;

procedure TfrmNakopad.lstGuiPropertyClick(Sender: TObject);
var
  i: Integer;
  s, cap: string;
begin
  i := lstGuiProperty.ItemIndex;
  if i < 0 then Exit;
  s := lstGuiProperty.Items[i];
  if s = '' then Exit;
  cap := GetToken('#', s);
  StatusMsg := '【項目】' + cap + ' 【解説】' + s;
end;

procedure TfrmNakopad.lstGuiPropertyDblClick(Sender: TObject);
var
  i: Integer;
  s, cap: string;
begin
  i := lstGuiProperty.ItemIndex;
  if i < 0 then Exit;
  s := lstGuiProperty.Items[i];
  if s = '' then Exit;
  cap := GetToken('#', s);
  cap := GetToken('～', cap);
  if Pos('{イベント}',cap) > 0 then
  begin
    cap := JReplace(cap, '{イベント}','', True);
    cap := 'その' + cap + 'は～';
  end;
  edtActive.SelText := cap;
end;

procedure TfrmNakopad.mnuShowBlankClick(Sender: TObject);
begin
  mnuShowBlank.Checked := not mnuShowBlank.Checked;
  ini.WriteBool('Edit','ShowBlank',mnuShowBlank.Checked);
  changeBlankMark(mnuShowBlank.Checked);
end;

procedure TfrmNakopad.changeBlankMark(Value: Boolean);
begin
  with edtA.ExMarks do
  begin
    DBSpaceMark.Visible := Value;
    TabMark.Visible     := Value;
    SpaceMark.Visible   := Value;
    //
    DBSpaceMark.Color   := clSilver;
    TabMark.Color       := clSilver;
    SpaceMark.Color     := clSilver;
  end;
  mnuShowBlank.Checked := Value;
  //
  edtB.ExMarks.Assign(edtA.ExMarks);
end;

procedure TfrmNakopad.mnuReplaceClick(Sender: TObject);
begin
  frmReplace.chkSelection.Checked := (edtActive.SelLength > 0);
  frmReplace.Show;
end;

procedure TfrmNakopad.WEB2Click(Sender: TObject);
begin
  mnuLookWebClick(nil);
end;

procedure TfrmNakopad.popLookWebClick(Sender: TObject);
begin
  mnuLookWebClick(nil);
end;

procedure TfrmNakopad.edtActive_setFocus;
begin
  if pageMain.ActivePage = tabSource then
  begin
    try
      edtActive.SetFocus;
    except
    end;
  end;
end;

procedure TfrmNakopad.mnuInsButtonClick(Sender: TObject);
begin
  parts_changeDesign;
  parts_insertFromMenu(TNGuiButton.Create(panelDesign));
end;

procedure TfrmNakopad.parts_insertFromMenu(parts: TNGuiParts; name: string);
var
  frm: TNGuiForm;
  i: Integer;
begin
  // 母艦が生成されているかチェック！
  edtDesignDescript.Visible := False;
  if (FGuiList.FList.Count = 0) then
  begin
    // 母艦を挿入
    frm := TNGuiForm.Create(panelDesign);
    frm.Parent := panelDesign;
    frm.Left := 0;
    frm.Top  := 0;
    //frm.Width   := shapeBack.Width;
    //frm.Height  := shapeBack.Height;
    frm.Visible := True;
    frm.OnMouseDown := parts_mouseDown;
    frm.OnMouseUp   := parts_mouseUp;
    frm.propList.Items['名前'].value := '母艦';
    frm.Obj2Prop;
    FGuiList.Add(frm);
  end;
  if parts = nil then Exit;

  // 追加
  FGuiList.Add(parts);
  if name = '' then
  begin
    // 名前の自動生成
    for i := 1 to 9999 do
    begin
      name := parts.Items['種類'].value + IntToStr(i);
      if FGuiList.Find(name) = nil then Break;
    end;
    parts.propList.Items['名前'].value := name;
  end else
  begin
    parts.propList.Items['名前'].value := name;
  end;

  i := parts.propList.IndexOf('テキスト');
  if i >= 0 then
  begin
    parts.propList.Items['テキスト'].value := parts.propList.Items['名前'].value;
  end;

  parts.Parent := panelDesign;
  parts.Left := 8;
  parts.Top  := 8;
  parts.Visible := True;
  parts.BringToFront;
  parts.OnMouseDown := parts_mouseDown;
  parts.OnMouseUp   := parts_mouseUp;
  parts.OnMouseMove := parts_mouseMove;
  parts.Obj2Prop;
  //
  parts_setCombo;
  //
  panelDesign.Repaint;
  panelDesign.Invalidate;
  //
end;

procedure TfrmNakopad.parts_mouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  p: TNGuiParts;
begin
  p := TNGuiParts(Sender);
  if p = nil then Exit;
  p.bMouse := True;
  FDownPoint := Point(X, Y);
end;

procedure TfrmNakopad.shapeBackMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FTrackTarget := nil;
  track.Visible := False;
end;

procedure TfrmNakopad.parts_setCombo;
var
  i: Integer;
  p: TNGuiParts;
begin
  cmbParts.Clear;
  for i := 0 to FGuiList.FList.Count - 1 do
  begin
    p := FGuiList.FList.Items[i];
    cmbParts.Items.Add(p.propList.Items['名前'].value + ':' + p.propList.Items['種類'].value);  
  end;
  cmbParts.ItemIndex := -1;
end;

procedure TfrmNakopad.cmbPartsChange(Sender: TObject);
var
  p: TNGuiParts;
begin
  p := parts_ComboGetObj;
  if p = nil then Exit;
  parts_prop2valueList(p);
  if p.Items['名前'].value <> '母艦' then
    parts_select(p);
end;

procedure TfrmNakopad.trackMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then Exit;
  track_fix;  
  if FTrackTarget <> nil then
  begin
    // 更新するように
    FTrackTarget.Obj2Prop;

    parts_prop2valueList(FTrackTarget);
  end;
  track.Visible := False;
  FTrackTarget := nil;
end;

function TfrmNakopad.parts_ComboGetObj: TNGuiParts;
var
  name: string;
  p: TNGuiParts;
begin
  name := cmbParts.Text;
  name := getToken_s(name, ':');
  p := FGuiList.Find(name);
  Result := p;
end;

procedure TfrmNakopad.propGuiSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  s: string;
  name, vtype: string;
begin
  s := propGui.Cells[0, ARow];
  name  := GetToken(':', s);
  vtype := GetToken('=', s);
  if vtype = '数値' then
  begin
    SetImeMode(Self.Handle, imClose);
  end else
  if vtype = '文字列' then
  begin
    SetImeMode(Self.Handle, imOpen);
  end;
end;

procedure TfrmNakopad.propGuiKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    parts_reflesh;
  end;
end;

procedure TfrmNakopad.parts_reflesh;
var
  p: TNGuiParts;
  name: string;
  i: Integer;
begin
  begin
    p := parts_ComboGetObj;
    if p <> nil then
    begin
      // フォームチェック
      name := p.Items['名前'].value;
      p.propList.Text := propGui.Strings.Text;
      p.Prop2Obj;
      if name <> p.propList.Items['名前'].value then
      begin
        i := cmbParts.ItemIndex;
        parts_setCombo;
        cmbParts.ItemIndex := i;
      end;
      p.Invalidate;
      if track.Visible then
      begin
        track.Left := p.Left;
        track.Top := p.Top;
        track.Width := p.Width;
        track.Height := p.Height;
      end;
    end;
  end;
end;

procedure TfrmNakopad.propGuiGetEditText(Sender: TObject; ACol,
  ARow: Integer; var Value: String);
begin
  parts_reflesh;
end;

procedure TfrmNakopad.mnuInsEditClick(Sender: TObject);
begin
  parts_changeDesign;
  parts_insertFromMenu(TNGuiEdit.Create(panelDesign));
end;

procedure TfrmNakopad.mnuInsLabelClick(Sender: TObject);
begin
  parts_changeDesign;
  parts_insertFromMenu(TNGuiLabel.Create(panelDesign));
end;

procedure TfrmNakopad.pageMainChange(Sender: TObject);
begin
  FGuiCancelInvalidate := False;
  if pageMain.ActivePage = tabSource then
  begin
    // design to source
    design2source;
    pageLeft.ActivePage := sheetAction;
  end else
  if pageMain.ActivePage = tabDesign then
  begin
    // source to design
    getGUIPartsList;
    source2design;
    pageLeft.ActivePage := sheetDesignProp;
    panelDesign.Invalidate;
  end;
end;

const
  TUMIKI_DESGINER_BEGIN = '※※※積み木デザイナ:ここから※';
  TUMIKI_DESGINER_END   = '※※※積み木デザイナ:ここまで※';

procedure TfrmNakopad.design2source;
var
  i, j: Integer;
  s, mae, usiro, txt, guiname: string;
  gui: TNGuiParts;
  p  : TNGuiProp;
  events: TStringList;
  event: string;
begin
  if FGuiList.FList.Count <= 0 then Exit;
  cmbParts.Clear;
  propGui.Strings.Clear;

  s      := '';
  mae    := '';
  usiro  := '';
  txt    := edtActive.Lines.Text;
  events := TStringList.Create;

  if Pos(TUMIKI_DESGINER_BEGIN, txt) > 0 then
  begin
    mae   := GetToken(TUMIKI_DESGINER_BEGIN, txt);
    s     := GetToken(TUMIKI_DESGINER_END,   txt);
    usiro := txt;
    s     := '';
  end else
  begin
    mae := txt;
  end;

  s := s + TUMIKI_DESGINER_BEGIN + #13#10;
  s := s + '※ 以下はデザインデータです。'#13#10+
           '※ コメントを削除しないようにしてください。'#13#10;
  for i := 0 to FGuiList.FList.Count - 1 do
  begin
    s := s + '※ ---'#13#10;
    gui := FGuiList.Get(i);
    gui.Obj2Prop;
    guiname := gui.Items['名前'].value;

    if guiname = '母艦' then
    begin
      s := s + '※母艦とはフォーム##生成'#13#10;
      s := s + '母艦は「メインフォーム」'#13#10;
    end else begin
      s := s + gui.propList.Items['名前'].value + 'とは' + gui.propList.Items['種類'].value + '##生成'#13#10;
    end;

    for j := 0 to gui.propList.Count - 1 do
    begin
      p := gui.propList.Get(j);
      if p.name  = '名前' then Continue;
      if p.name  = '種類' then Continue;
      if p.vtype = '数値' then
      begin
        if (guiname = '母艦') then
        begin
          if (p.name = 'X')or(p.name = 'Y') then Continue;
          if (p.name = 'W') then
          begin
            s := s + 'そのクライアントW=' + p.value + '#数値' + #13#10;
            Continue;
          end else
          if (p.name = 'H') then
          begin
            s := s + 'そのクライアントH=' + p.value + '#数値' + #13#10;
            Continue;
          end;
        end;
        s := s + 'その' + p.Name + '=' + p.value + '#数値' + #13#10;
      end else
      if p.vtype = '文字列' then
      begin
        s := s + 'その' + p.Name + '=' + '「' +p.value + '」#文字列' + #13#10;
      end else
      if p.vtype = 'イベント' then
      begin
        if p.value <> '' then
        begin
          s := s + 'その' + p.Name + 'は～' + p.value + '#イベント' + #13#10;
          events.Add(p.value);
        end;
      end;
    end;
  end;
  s := s + TUMIKI_DESGINER_END + #13#10;

  txt := Trim(mae) + #13#10#13#10 + Trim(s) + #13#10#13#10 + Trim(usiro) + #13#10;

  // イベントのチェック
  for i := 0 to events.Count - 1 do
  begin
    event := '●' + events.Strings[i];
    if Pos(event, txt) = 0 then
    begin
      txt := txt + #13#10 + event + #13#10 +
        '　　# ここにイベントを書きます。'#13#10 +
        '　　# 字下げした部分がイベント範囲です。'#13#10;
    end;
  end;

  // エディタにセット
  edtActive.Lines.Text := txt;
  FGuiList.Clear;

  events.Free;

end;

procedure TfrmNakopad.source2design;
var
  txt, line, name, value, vtype: string;
  sl: TStringList;
  i: Integer;
  gui: TNGuiParts;
begin
  FGuiList.Clear;
  track.Visible := False;
  FTrackTarget  := nil;

  sl := TStringList.Create;
  try
    txt := edtActive.Lines.Text;
    GetToken(TUMIKI_DESGINER_BEGIN, txt);
    sl.Text := GetToken(TUMIKI_DESGINER_END, txt);
    i   := 0;
    gui := nil;
    while i < sl.Count do
    begin
      line := sl.Strings[i];
      if Pos('##生成', line) > 0 then
      begin
        if gui <> nil then gui.Prop2Obj;
        name  := Trim(GetToken('とは', line));
        name  := Trim(JReplace(name, '※', '', True));
        value := Trim(GetToken('#',   line));
        gui   := parts_insertCommand(value, name);
        Inc(i);
        Continue;
      end;
      if (Pos('#イベント', line) > 0)and(Copy(Trim(line), 1, 4) = 'その') then
      begin
        line  := Trim(line);
        System.Delete(line,1,4);
        name  := Trim(GetToken('は～', line));
        value := Trim(GetToken('#', line));
        vtype := Trim(line);
        gui.propList.Items[name].value := value;
      end;
      if Copy(Trim(line), 1, 4) = 'その' then
      begin
        if gui = nil then begin Inc(i); Continue; end;
        line  := Trim(line);
        System.Delete(line,1,4);
        name  := Trim(GetToken('=', line));
        value := Trim(GetToken('#', line));
        vtype := Trim(line);
        if Pos('「', value) > 0 then
        begin
          value := JReplace(value, '「', '', False);
          value := JReplace(value, '」', '', False);
        end else
        begin
          if name = 'クライアントW' then name := 'W';
          if name = 'クライアントH' then name := 'H';
          value := convToHalf(value);
        end;
        gui.propList.Items[name].value := value;
        if vtype <> '' then
        begin
          gui.propList.Items[name].vtype := vtype;
        end;
        Inc(i);
        Continue;
      end;
      Inc(i);
    end;
    if gui <> nil then gui.Prop2Obj;
    FTrackTarget := nil;
    parts_setCombo;
    parts_select(gui);
  finally
    sl.Free;
  end;
end;

function TfrmNakopad.parts_insertCommand(guiType, name: string): TNGuiParts;
var
  gui: TNGuiParts;
begin
  //todo: デザイン
  if guiType = 'ボタン' then
  begin
    gui := TNGuiButton.Create(panelDesign);
  end else
  if guiType = 'エディタ' then
  begin
    gui := TNGuiEdit.Create(panelDesign);
  end else
  if guiType = 'ラベル' then
  begin
    gui := TNGuiLabel.Create(panelDesign);
  end else
  if guiType = 'メモ' then
  begin
    gui := TNGuiMemo.Create(panelDesign);
  end else
  if guiType = 'Tエディタ' then
  begin
    gui := TNGuiTEditor.Create(panelDesign);
  end else
  if guiType = 'バー' then
  begin
    gui := TNGuiBar.Create(panelDesign);
  end else
  if guiType = 'グリッド' then
  begin
    gui := TNGuiGrid.Create(panelDesign);
  end else
  if guiType = 'イメージ' then
  begin
    gui := TNGuiImage.Create(panelDesign);
  end else
  if guiType = 'アニメ' then
  begin
    gui := TNGuiAnime.Create(panelDesign);
  end else
  if guiType = 'チェック' then
  begin
    gui := TNGuiCheck.Create(panelDesign);
  end else
  if guiType = 'パネル' then
  begin
    gui := TNGuiPanel.Create(panelDesign);
  end else
  if guiType = 'リスト' then
  begin
    gui := TNGuiListParts.Create(panelDesign);
  end else
  if guiType = 'コンボ' then
  begin
    gui := TNGuiCombo.Create(panelDesign);
  end else
  if guiType = 'フォーム' then
  begin
    parts_insertFromMenu(nil, '');
    gui := FGuiList.Find('母艦');
    Result := gui;
    Exit;
  end else
  begin
    gui := TNGuiButton.Create(panelDesign);
  end;
  Result := gui;
  parts_insertFromMenu(gui, name);
end;

procedure TfrmNakopad.parts_select(parts: TNGuiParts);
var
  i: integer;
  s: string;
  b: Boolean;
begin
  if parts = nil then Exit;
  if parts = FTrackTarget then Exit;

  // track (check property)
  track.Left    := parts.getItemsAsInt('X',parts.Left);
  track.Top     := parts.getItemsAsInt('Y',parts.Top);
  track.Width   := parts.getItemsAsInt('W',parts.Width);
  track.Height  := parts.getItemsAsInt('H',parts.Height);
  track.Visible := True;

  // set
  if parts <> FTrackTarget then
  begin
    FTrackTarget := parts;
    s := parts.propList.Items['名前'].value + ':' + parts.propList.Items['種類'].value;
    i := cmbParts.Items.IndexOf(s);
    if i >= 0 then
    begin
      b := FGuiCancelInvalidate;
      FGuiCancelInvalidate := True;
      cmbParts.ItemIndex := i;
      cmbPartsChange(nil);
      FGuiCancelInvalidate := b;
    end;
  end;

  if not FGuiCancelInvalidate then panelDesign.Repaint;
  mnuDesignDelete.Enabled := True;
end;


procedure TfrmNakopad.parts_prop2valueList(parts: TNGuiParts);
var
  i: Integer;
  p: TNGuiProp;
begin
  // todo: デザイン時GUIプロパティーをリストに表示する
  // parts
  propGui.Strings.BeginUpdate;
  try
    propGui.Strings.Text := parts.propList.Text;

    // items
    for i := 0 to parts.propList.Count - 1 do
    begin
      p := parts.propList.Get(i);
      //propGui.ItemProps[i].KeyDesc    := p.name;
      propGui.ItemProps[i].ReadOnly   := False;
      propGui.ItemProps[i].EditStyle  := esSimple;
      propGui.ItemProps[i].PickList.Clear;
      // 選択肢
      if p.sel <> '' then
      begin
        propGui.ItemProps[i].EditStyle  := esPickList;
        propGui.ItemProps[i].PickList.Text := JReplace(p.sel, '|', #13#10, True);
      end;
      if p.name = '種類' then
      begin
        propGui.ItemProps[i].ReadOnly := True;
      end else
      if p.vtype = '数値' then
      begin
      end else
      if p.vtype = 'イベント' then
      begin
        propGui.ItemProps[i].EditStyle := esEllipsis;
      end;
    end;

  finally
    propGui.Strings.EndUpdate;
  end;
end;

procedure TfrmNakopad.propGuiEditButtonClick(Sender: TObject);
var
  p: TNGuiParts;
  s, name, value: string;
  i: Integer;
begin
  p := parts_ComboGetObj;
  if p = nil then Exit;

  name  := Trim(propGui.Cells[0, propGui.Row]);
  name  := Trim(GetToken(':', name));
  value := Trim(propGui.Cells[1, propGui.Row]);
  if value = '' then
  begin
    s := Trim(p.Items['名前'].value) + '__' + name;
    value := s;
    propGui.Cells[1, propGui.Row] := value;
  end;
  parts_reflesh;

  // ページを切り替える
  pageMain.ActivePage := tabSource;
  design2source;
  // 指定のイベントへ飛ぶ
  edtActive_setFocus;
  s := '●' + value;
  i := Pos(s, edtActive.Lines.Text);
  if i >= 0 then
  begin
    edtActive.SelStart  := i - 1;
    edtActive.SelLength := Length(s);
  end;
end;

procedure TfrmNakopad.parts_changeDesign;
begin
  if pageLeft.ActivePage <> sheetDesignProp then
  begin
    pageLeft.ActivePage := sheetDesignProp;
  end;

  if pageMain.ActivePage <> tabDesign then
  begin
    pageMain.ActivePage := tabDesign;
    source2design;
  end;
end;

procedure TfrmNakopad.mnuInsMemoClick(Sender: TObject);
begin
  parts_changeDesign;
  parts_insertFromMenu(TNGuiMemo.Create(panelDesign));
end;

procedure TfrmNakopad.mnuInsBarClick(Sender: TObject);
begin
  parts_changeDesign;
  parts_insertFromMenu(TNGuiBar.Create(panelDesign));
end;

procedure TfrmNakopad.mnuInsTEditClick(Sender: TObject);
begin
  parts_changeDesign;
  parts_insertFromMenu(TNGuiTEditor.Create(panelDesign));
end;

procedure TfrmNakopad.mnuInsGridClick(Sender: TObject);
begin
  parts_changeDesign;
  parts_insertFromMenu(TNGuiGrid.Create(panelDesign));
end;

procedure TfrmNakopad.mnuInsImageClick(Sender: TObject);
begin
  parts_changeDesign;
  parts_insertFromMenu(TNGuiImage.Create(panelDesign));
end;

procedure TfrmNakopad.mnuDesignDeleteClick(Sender: TObject);
var
  name: string;
begin
  if FTrackTarget = nil then Exit;
  name := FTrackTarget.Items['名前'].value;
  if name = '母艦' then
  begin
    ShowMessage('母艦は削除できません！');
    Exit;
  end;
  FGuiList.Delete(name);
  FTrackTarget := nil;
  track.Visible := False;
  parts_setCombo;
end;

procedure TfrmNakopad.mnuDesignDelClick(Sender: TObject);
begin
  mnuDesignDeleteClick(nil);
end;

procedure TfrmNakopad.labelDesignLimitClick(Sender: TObject);
begin
  OpenApp('http://nadesi.com/pro/');
end;

procedure TfrmNakopad.AddRecentFile(fname: string);
var
  i: Integer;
begin
  // Add RecentFiles
  i := RecentFiles.IndexOf(fname);
  if i >= 0 then
  begin
    RecentFiles.Move(i, 0);
  end else
  begin
    RecentFiles.Insert(0, fname);
    if RecentFiles.Count > 10 then
    begin
      RecentFiles.Delete(10);
    end;
  end;
end;


procedure TfrmNakopad.mnuRegDeluxClick(Sender: TObject);
var
  s: string;
  i: Integer;

  procedure _proc_ok;
  begin
    // OK
    ShowMessage('登録ありがとうございました。'#13#10+
      'なでしこエディタのすべての機能が使えるようになりました。');
    ini.WriteString('license', 'key', s);
    changeProLicense(True);
  end;

begin
  // デラックス版の情報を表示するか？
  if MsgYesNo('デラックス版に興味を持っていただきありがとうございます。'#13#10+
      'ラインセンスのご購入はお済ですか？') = False then
  begin
    ShowMessage('デラックス版に関するページを表示します。');
    OpenApp('http://nadesi.com/pro/');
    Exit;
  end;

  // デラックス版の登録
  for i := 1 to 5 do
  begin
    SetImeMode(Self.Handle, imClose);
    s := InputBox('ライセンスキーの入力', 'ライセンスキーを入力してください。', '');
    if (s = '') then Exit;
    s := UpperCase(Trim(s));
    if not chk_nakopad_key(s) then
    begin
      ShowWarn('ライセンスキーが違います。'#13+
        'クリップボード経由で貼り付けを使うと間違いが少なくなります。',
        'ライセンスキーの入力ミス');
      if MsgYesNo('ライセンスキーの入力を中止しますか？') then
      begin
        ShowMessage('正規ライセンスの購入をお願いします。');
        OpenApp('http://nadesi.com/pro/');
        Exit;
      end;
      Continue;
    end;
    // ok
    _proc_ok;
    Exit;
  end;
  OpenApp('http://nadesi.com/pro/');
  ShowWarn('正規ライセンスの購入をお願いします。', 'タイプミス3回以上');
  Close;
end;

procedure TfrmNakopad.changeProLicense(b: Boolean);
begin
  //todo: 商用版のみ
  if b then
  begin
    // PRO
    // ***
    mnuDesignDelete.Enabled  := True; // 削除できる
    mnuRegDelux.Visible := False;
    isDelux := True;
    frmMakeExe.chkAngou3.Enabled := True;
    frmMakeExe.chkIncludeDLL.Enabled := True;
    mnuMakeInstaller.Enabled := True;
  end else
  begin
    // FREE
    // Default では、以下の状態を保つようにする
    // 簡単なクラック対策～あまり意味ないと思うけど。
    mnuRegDelux.Visible := True;
    isDelux := False;
    frmMakeExe.chkAngou3.Enabled := False;
    frmMakeExe.chkIncludeDLL.Enabled := False;
    mnuMakeInstaller.Enabled := False;
  end;
end;

procedure TfrmNakopad.parts_mouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  p: TNGuiParts;
  cw, rx, ry, rh, rw: Integer;
  b: Boolean;
begin
  p := TNGuiParts(Sender);
  if p = nil then Exit;
  p.bMouse := False;

  //
  cw := 8;
  rx := Round((p.Left   / cw)) * cw;
  ry := Round((p.Top    / cw)) * cw;
  rw := Round((p.Width  / cw)) * cw;
  rh := Round((p.Height / cw)) * cw;
  //
  p.Left := rx;
  p.Top  := ry;
  p.Width  := rw;
  p.Height := rh;
  //

  b := FGuiCancelInvalidate;
  FGuiCancelInvalidate := True;

  p.Obj2Prop;
  parts_select(p);

  if not FGuiCancelInvalidate then
    panelDesign.Invalidate;
    
  FGuiCancelInvalidate := b;
end;

procedure TfrmNakopad.parts_mouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  p: TNGuiParts;
  pt: TPoint;
begin
  p := TNGuiParts(Sender);
  if p = nil then Exit;
  if not p.bMouse then Exit;
  if p.ClassType = TNGuiForm then Exit;
  //===
  pt := p.ClientToScreen(Point(X,Y));
  pt := panelDesign.ScreenToClient(pt);
  p.Left := pt.X - FDownPoint.X;
  p.Top  := pt.Y - FDownPoint.Y;

  p.Update;
  //if not FGuiCancelInvalidate then
  //  p.Invalidate;
end;

procedure TfrmNakopad.panelGuiTopResize(Sender: TObject);
begin
  edtGuiFind.Width := panelGuiTop.ClientWidth - edtGuiFind.Left * 2;
end;

procedure TfrmNakopad.edtGuiFindChange(Sender: TObject);
var
  i: Integer;
  s, f: string;
begin
  //
  f := edtGuiFind.Text;
  if f = '母艦' then
  begin
    f := 'フォーム';
  end;
  for i := 0 to lstGuiType.Items.Count - 1 do
  begin
    s := lstGuiType.Items.Strings[i];
    if Pos(f, s) = 1 then
    begin
      lstGuiType.ItemIndex := i;
      lstGuiTypeClick(nil);
      Break;
    end;
  end;
end;

procedure TfrmNakopad.mnuShowNadesikoHistoryClick(Sender: TObject);
begin
  OpenApp(AppPath + 'history.txt');
end;

procedure TfrmNakopad.CheckOldVersion;
var
  oldini: String;
begin
  // IniFile
  oldini := ChangeFileExt(ParamStr(0), '.ini');
  if FileExists(oldini) then
  begin
    CopyFile(PChar(oldini), PChar(FIniName), False);
    DeleteFile(PChar(oldini));
  end;
  //
end;

procedure TfrmNakopad.track_fix;
var
  rx, ry: Integer;
  rw, rh: Integer;
  cw: Integer;
begin
  if FTrackTarget = nil then Exit;

  cw := 8;
  rx := (track.Left   div cw) * cw;
  ry := (track.Top    div cw) * cw;
  rw := (track.Width  div cw) * cw;
  rh := (track.Height div cw) * cw;

  if FTrackTarget.ClassType <> TNGuiForm then
  begin
    FTrackTarget.Top    := ry;
    FTrackTarget.Left   := rx;
  end;
  FTrackTarget.Width  := rw;
  FTrackTarget.Height := rh;
end;

procedure TfrmNakopad.mnuIndentRightSpaceClick(Sender: TObject);
var
  s: string;
  i: Integer;
  o: TStringList;
  iStart: Integer;
begin
  if edtActive.SelLength > 0 then
  begin
    iStart := edtActive.SelStart;
    o := TStringList.Create;
    o.Text := edtActive.SelText;
    for i := 0 to o.Count - 1 do
    begin
      s := o.Strings[i];
      o.Strings[i] := ' ' + s;
    end;
    edtActive.SelText   := o.Text;
    edtActive.SelStart := iStart;
    edtActive.SelLength := Length(o.Text);
    o.Free;
  end else
  begin
    // カーソル行
    iStart := edtActive.SelStart;
    s := edtActive.Lines.Strings[ edtActive.Row ];
    // インデントを左に
    if s = '' then Exit;
    edtActive.Lines.Strings[ edtActive.Row ] := ' ' + s;
    edtActive.SelStart := iStart;
  end;
end;

procedure TfrmNakopad.mnuOpenSettingDirClick(Sender: TObject);
begin
  OpenApp(FUserDir);
end;

procedure TfrmNakopad.mnuInsAnimeClick(Sender: TObject);
begin
  parts_changeDesign;
  parts_insertFromMenu(TNGuiAnime.Create(panelDesign));
end;

procedure TfrmNakopad.mnuInsPanelClick(Sender: TObject);
begin
  parts_changeDesign;
  parts_insertFromMenu(TNGuiPanel.Create(panelDesign));
end;

procedure TfrmNakopad.mnuInsCheckClick(Sender: TObject);
begin
  parts_changeDesign;
  parts_insertFromMenu(TNGuiCheck.Create(panelDesign));
end;

procedure TfrmNakopad.panelDesignMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FTrackTarget := nil;
  track.Visible := False;
end;

procedure TfrmNakopad.mnuInsListClick(Sender: TObject);
begin
  parts_changeDesign;
  parts_insertFromMenu(TNGuiListParts.Create(panelDesign));
end;

procedure TfrmNakopad.Panel12Resize(Sender: TObject);
begin
  cmbParts.Width := Panel12.ClientWidth - cmbParts.Left * 2;
end;

procedure TfrmNakopad.mnuRunAsClick(Sender: TObject);
begin
  mnuRunAs.Checked := not mnuRunAs.Checked;
end;

procedure TfrmNakopad.getGUIPartsList;
var
  gui,s: string;
begin
  if lstInsertParts.Items.Count > 0 then Exit;
  s := FileLoadAll(AppPath + 'tools\tumiki\list.txt');
  gui := GetToken('====',s);
  gui := Trim(gui);
  lstInsertParts.Items.Text := gui;
end;

procedure TfrmNakopad.lstInsertPartsDblClick(Sender: TObject);
var
  txt: string;
begin
  if lstInsertParts.ItemIndex < 0 then Exit;
  txt := lstInsertParts.Items[lstInsertParts.ItemIndex];
  if txt = 'ボタン'   then mnuInsButtonClick(nil) else
  if txt = 'ラベル'   then mnuInsLabelClick(nil) else
  if txt = 'バー'     then mnuInsBarClick(nil) else
  if txt = 'チェック' then mnuInsCheckClick(nil) else
  if txt = 'エディタ' then mnuInsEditClick(nil) else
  if txt = 'メモ'     then mnuInsMemoClick(nil) else
  if txt = 'Tエディタ'then mnuInsTEditClick(nil) else
  if txt = 'リスト'   then mnuInsListClick(nil) else
  if txt = 'グリッド' then mnuInsGridClick(nil) else
  if txt = 'パネル'   then mnuInsPanelClick(nil) else
  if txt = 'イメージ' then mnuInsImageClick(nil) else
  if txt = 'アニメ'   then mnuInsAnimeClick(nil) else
  if txt = 'コンボ'   then begin
    parts_changeDesign;
    parts_insertFromMenu(TNGuiCombo.Create(panelDesign));
  end else
  ;
end;

procedure TfrmNakopad.mnuMakeInstallerClick(Sender: TObject);
begin
  RunApp(Format('"%s\vnako.exe" "%s\installer\make.nako"',[
    AppPath,
    AppPath
  ]));
end;

procedure TfrmNakopad.DeleteNakopadTempFile;
begin
  // テンポラリファイル
  if (FTempFile <> '') and (FileExists(FTempFile)) then
  begin
    DeleteFile(FTempFile);
    FTempFile := '';
  end;
  // report.txt
  if FileExists(ReportFile) then
  begin
    DeleteFile(ReportFile);
  end;
  // 依存関連チェックをオフに。
  if frmMakeExe.chkIncludeDLL <> nil then
  begin
    frmMakeExe.lstFiles.Clear;
    frmMakeExe.chkIncludeDLL.Checked := False;
  end;
end;

procedure TfrmNakopad.mnuTestModeClick(Sender: TObject);
begin
  mnuTestMode.Checked := not mnuTestMode.Checked;
end;

procedure TfrmNakopad.mnuTestModeHelpClick(Sender: TObject);
begin
  //
  OpenApp(AppPath + 'doc\reference\misc\testmode.txt');
end;

procedure TfrmNakopad.lblActionGetMoreInfoClick(Sender: TObject);
begin
  // get info
  
end;

procedure TfrmNakopad.mnuRunNakoTestClick(Sender: TObject);
begin
  RunApp(Format('"%s" "%s"',[
    AppPath + 'vnako.exe',
    AppPath + 'test\test-all.nako'
  ]));
end;

function TfrmNakopad.GetReportFile: string;
begin
  Result := AppPath + REPORT_TXT;
end;

procedure TfrmNakopad.mnuInsRunModeClick(Sender: TObject);
var
  s: string;
begin
  s := MODE_HINT_STR;

  case FNakoIndex of
    NAKO_VNAKO : s := s + 'vnako';
    NAKO_GNAKO : s := s + 'gnako';
    NAKO_CNAKO : s := s + 'cnako';
  end;

  edtActive.Lines.Insert(
    edtActive.Row, s
  );
end;

procedure TfrmNakopad.appendFileToStrings(fname: string;
  list: TStrings);
var
  tmp: TStringList;
begin
  if not FileExists(fname) then Exit;
  tmp := TStringList.Create;
  try
    tmp.LoadFromFile(fname);
    list.AddStrings(tmp);
  finally
    FreeAndNil(tmp);
  end;
end;

procedure TfrmNakopad.appendFileToStringsAppAndUser(fname: string;
  list: TStrings);
begin
  appendFileToStrings(AppPath + fname, list);
  appendFileToStrings(FUserDir + fname, list);
end;

procedure TfrmNakopad.appendFileToCsvSheet(fname: string; list: TCsvSheet);
var
  i, row: Integer;
  j: Integer;
  tmp: TCsvSheet;
begin
  if not FileExists(fname) then Exit;
  tmp := TCsvSheet.Create;
  try
    tmp.LoadFromFile(fname);
    for i := 0 to tmp.Count - 1 do
    begin
      row := list.Count;
      for j := 0 to tmp.ColCount - 1 do
      begin
        list.Cells[j, row] := tmp.Cells[j, i];
      end;
    end;
  finally
    FreeAndNil(tmp);
  end;
end;

procedure TfrmNakopad.appendFileToCsvSheetAppAndUser(fname: string;
  list: TCsvSheet);
begin
  appendFileToCsvSheet(AppPath + fname, list);
  appendFileToCsvSheet(FUserDir + fname, list);
end;

procedure TfrmNakopad.pnlGroupFilterResize(Sender: TObject);
begin
  edtGroupFilter.Width := pnlGroupFilter.ClientWidth - edtGroupFilter.Left - 8;
end;

procedure TfrmNakopad.edtGroupFilterChange(Sender: TObject);
var
  tmp: TStringList;
  i: Integer;
  key, s: string;
begin
  key := Trim(convToHalf(edtGroupFilter.Text));
  if tmpGroupFilter = nil then
  begin
    tmpGroupFilter := TStringList.Create;
    tmpGroupFilter.AddStrings(lstMember.Items);
  end;

  if key = '' then
  begin
    lstMember.Items.Assign(tmpGroupFilter);
    Exit;
  end;

  tmp := TStringList.Create;
  for i := 0 to tmpGroupFilter.Count - 1 do
  begin
    s := tmpGroupFilter.Strings[i];
    if Pos(key, convToHalf(s)) > 0 then
    begin
      tmp.Add(s);
    end;
  end;
  lstMember.Items.Assign(tmp);
  FreeAndNil(tmp);
end;

procedure TfrmNakopad.edtGroupFilterKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    lstMember.SetFocus;
  end;
end;

procedure TfrmNakopad.lblLinkToWebManClick(Sender: TObject);
begin
  //
  popLookWebClick(nil);
end;


procedure TfrmNakopad.selectFileLoadAppOrUser(fname: string;
  list: TStrings);
begin
  if FileExists(FUserDir + fname) then
  begin
    list.LoadFromFile(FUserDir + fname);
  end else
  if FileExists(AppPath + fname) then
  begin
    list.LoadFromFile(AppPath + fname);
  end;
end;

procedure TfrmNakopad.lblLinkToLocalManClick(Sender: TObject);
begin
  mnuViewManClick(nil);
end;

procedure TfrmNakopad.mnuEnumUserFunctionClick(Sender: TObject);
begin
  TangoSelect;
  cmbVar.Text := edtActive.SelText;
  pageLeft.ActivePage := sheetVar;
  btnFuncEnumClick(nil);
end;

procedure TfrmNakopad.mnuEnumUserVarClick(Sender: TObject);
begin
  TangoSelect;
  cmbVar.Text := edtActive.SelText;
  pageLeft.ActivePage := sheetVar;
  btnVarEnumClick(nil);
end;

procedure TfrmNakopad.mnuInsertTemplateClick(Sender: TObject);
var
  txt: string;
begin
  ForceDirectories(FUserDir + DIR_TEMPLATE);
  dlgOpenTemplate.InitialDir := FUserDir + DIR_TEMPLATE;
  if not dlgOpenTemplate.Execute then Exit;
  ReadTextFile(dlgOpenTemplate.FileName, txt);
  edtActive.SelText := txt + #13#10;
end;

procedure TfrmNakopad.mnuSaveAsTemplateClick(Sender: TObject);
var
  txt: string;
begin
  ForceDirectories(FUserDir + DIR_TEMPLATE);
  dlgSaveTemplate.InitialDir := FUserDir + DIR_TEMPLATE;
  if not dlgSaveTemplate.Execute then Exit;
  txt := edtActive.Lines.Text;
  WriteTextFile(dlgSaveTemplate.FileName, txt);
end;

procedure TfrmNakopad.mnuMakeBatchFileClick(Sender: TObject);
var
  txt: string;
begin
  //----------------------------------------------------------
  if not MsgYesNo(
    '現在編集中のなでしこプログラムを'#13#10+
    'バッチファイルに変換します。'#13#10+
    'なでしこがインストールされた環境で、'#13#10+
    'D&Dを受け付けるプログラムを作るのに便利です。'#13#10+
    '作成しますか？') then Exit;
  //----------------------------------------------------------
  if not dlgSaveBatchFile.Execute then Exit;
  ReadTextFile(AppPath + 'tools\template\batfile_head.txt', txt);
  txt := txt + #13#10 + edtActive.Lines.Text + #13#10;
  txt := JReplaceOne(txt, 'C:\Program Files\nadesiko_lang\vnako.exe', AppPath + 'vnako.exe');
  WriteTextFile(dlgSaveBatchFile.FileName, txt);
  ShowMessage('作成しました。ダブルクリックやファイルドロップで起動します。');
end;

procedure TfrmNakopad.tabsMainDrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  cap: string;
begin
  if TabIndex < 0 then Exit;
  cap := tabsMain.Tabs.Strings[TabIndex];
  with Control.Canvas do
  begin
    TextOut(Rect.Left + 2, Rect.Top + 2, cap);
  end;
end;

procedure TfrmNakopad.mnuDiffViewClick(Sender: TObject);
begin
  if panelOtehon.Width < 8 then
  begin
    if edtC.Lines.Text = '' then
    begin
      edtC.Lines.Text := 'お手本をこちらに貼り付けます。';
    end;
    panelOtehon.Width := panelOtehon.Parent.Width div 2;
    edtC.Font.Assign(edtB.Font);
    edtC.Font.Height := edtB.Font.Height;
    edtC.Margin.Assign(edtB.Margin);
  end else
  begin
    panelOtehon.Width := 0;
  end;
  mnuDiffView.Checked := (panelOtehon.Width >= 8);
end;

procedure TfrmNakopad.edtCDrawLine(Sender: TObject; LineStr: String; X, Y,
  Index: Integer; ARect: TRect; Selected: Boolean);
var
  flagDiff: Boolean;
  c: TColor;
begin
  //
  flagDiff := False;
  //
  // if edtActive = edtC then Exit;
  if edtActive.RowCount <= Index then
  begin
    flagDiff := True;
  end else
  begin
    if convToHalfAnk(edtActive.LineString(Index)) <>
      convToHalfAnk(edtC.LineString(Index)) then
    begin
      flagDiff := True;
    end;
  end;
  if not Selected then
  begin
    if flagDiff then
    begin
      c := RGB(255,200,200);
      if mnuColorBlack.Checked then c := c xor $FFFFFF;
      edtC.Canvas.Brush.Style := bsSolid;
      edtC.Canvas.Brush.Color := c;
      edtC.Canvas.Pen.Style   := psClear;
      edtC.Canvas.Rectangle(ARect);
      edtC.Canvas.TextRect(ARect, X, Y, LineStr);
    end;
  end;
  //
end;

procedure TfrmNakopad.edtBCaretMoved(Sender: TObject);
begin
  if edtC.Width > 4 then
  begin
    if edtC.RowCount > edtB.Row then
    begin
      edtC.Row := edtB.Row;
      edtC.Caret.Assign(edtB.Caret);
    end;
  end;
end;

procedure TfrmNakopad.btnDiffClick(Sender: TObject);
var
  res, bat, cmd, tmp1, tmp2: string;
  i: Integer;
begin
  tmp1 := TempDir + '左(見本)';
  tmp2 := TempDir + '右';
  bat  := TempDir + 'nako_diff.bat';
  edtC.Lines.SaveToFile(tmp1);
  edtB.Lines.SaveToFile(tmp2);
  cmd :=  'cd "'+TempDir+'"'#13#10+
          'fc /N 左(見本) 右>a.txt'#13#10;
  WriteTextFile(bat, cmd);
  RunApp(bat, False);
  Sleep(300);
  res := TempDir + 'a.txt';
  for i := 1 to 5 * 2 do
  begin
    if FileExists(res) then Break;
    Sleep(500);
  end;
  if FileExists(res) then
  begin
    ReadTextFile(res, cmd);
    edtDiff.Lines.Text := cmd;
  end;
end;

procedure TfrmNakopad.edtBMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  s: string;
  c, debugLen: Integer;
const
  debug = ';デバッグ;';
begin
  showRowCol;
  if not mnuInsDebug.Checked then Exit;

  // 左バーをクリック
  if X < edtB.LeftMargin then
  begin
    //
    c := edtB.Row;
    if c < 0 then Exit;
    debugLen := Length(debug);
    edtB.SelLength := 0;
    s := edtB.LineString(c);
    if Copy(s, Length(s)-debugLen+1, debugLen) = debug then
    begin
      s := Copy(s, 1, Length(s)-debugLen);
    end else
    begin
      s := s + debug;
    end;
    if c >= edtB.Lines.Count then
    begin
      edtB.Lines.Insert(0, s);
    end else
    begin
      edtB.Lines.Strings[c] := s;
    end;
    edtB.Row := c;
  end;
end;

procedure TfrmNakopad.mnuInsDebugClick(Sender: TObject);
begin
  mnuInsDebug.Checked := not mnuInsDebug.Checked;
  ini.WriteBool('Edit', 'mnuInsDebug', mnuInsDebug.Checked);
end;

procedure TfrmNakopad.RunProgram(FlagWait: Boolean);
var
  s, exe, txt, param: string;
begin
  // 実行
  RuntimeLineno := edtActive.Row;

  // 仮ファイルを作成
  if (FFileName = '') then
  begin
    if FTempFile = '' then
      FTempFile := getOriginalFileName(TempDir, 'com.nadesi.exe.nakopad.temp.nako.bak');
  end else
  begin
    FTempFile := ChangeFileExt(FFileName, '.nako.bak');
  end;

  // プログラムを得る
  txt := edtActive.Lines.Text;
  if FSpeed > 0 then
  begin
    txt := IntToStr(FSpeed)+'に実行速度設定'#13#10+txt;
  end;
  if mnuTestMode.Checked then
  begin
    txt :=  '!テスト対象ファイル＝『'+FTempFile+'』'#13#10+
            '!"'+AppPath+'lib\testlib.nako"を取り込む;'#13#10+
            'テストメイン処理。終わる。'#13#10+
            txt;
  end;
  if not WriteTextFile(FTempFile, txt) then
  begin
    MessageBox(Self.Handle,'一時ファイルの作成に失敗しました。'#13#10+
    '手動で削除してください。','エラー',MB_OK or MB_ICONSTOP);
    Exit;
  end;

  // 実行
  case FNakoIndex of
  NAKO_VNAKO:
    begin
      exe := '"' + AppPath + 'vnako.exe" "' + FTempFile + '" -debug::' + IntToStr(Self.Handle);
      if mnuDebugLineNo.Checked then exe := exe + ' -lineno';
    end;
  NAKO_GNAKO:
    begin
      exe := '"' + AppPath + 'gnako.exe" "' + FTempFile + '" -debug::' + IntToStr(Self.Handle);
      if mnuDebugLineNo.Checked then exe := exe + ' -lineno';
    end;
  NAKO_CNAKO:
    begin
      exe := '"' + AppPath + 'cnako.exe" /w "' + FTempFile + '" -debug::' + IntToStr(Self.Handle);
    end;
  end;

  if mnuRunAs.Checked then
  begin
    s := exe;
    System.Delete(s,1,1);
    exe := GetToken('"', s);
    param := Trim(s);
    RunAsAdmin(Self.Handle, exe, param);
  end else
  begin
    if not FlagWait then
    begin
      RunApp(exe);
    end else
    begin
      RunAppAndWait(exe);
    end;
  end;
end;

end.
