unit vnako_function;

interface
                                                           
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus,ValEdit, Grids, ComCtrls, StrSortGrid,
  UIWebBrowser, Spin, TrackBox, jpeg, mag, GIFImage,
  dnako_import, dnako_import_types,
  fileDrop, mmsystem, printers, Buttons, EasyMasks, shellapi,
  imm, ActiveX, MSHTML_TLB,
  // TEditor
  EditorExProp, heFountain
  //
  // Delphi7    -> RTLVersion(15)
  // Delphi2005 -> RTLVersion(17)
  {$IF RTLVersion < 20}
  ,XPMan, gldpng
  {$ELSE}
  ,XPMan, pngimage
  {$IFEND}
  ;

const
  EVENT_CLICK       = 'クリックした時';
  EVENT_DBLCLICK    = 'ダブルクリックした時';
  EVENT_CHANGE      = '変更した時';
  EVENT_SIZE_CHANGE = 'サイズ変更した時';
  EVENT_SHOW        = '表示した時';
  EVENT_CLOSE       = '閉じた時';
  EVENT_MOUSEDOWN   = 'マウス押した時';
  EVENT_MOUSEMOVE   = 'マウス移動した時';
  EVENT_MOUSEUP     = 'マウス離した時';
  EVENT_KEYDOWN     = 'キー押した時';
  EVENT_KEYPRESS    = 'キータイピング時';
  EVENT_KEYUP       = 'キー離した時';
  EVENT_DRAGOVER    = 'ドロップ許可した時';
  EVENT_DRAGDROP    = 'ドロップした時';
  EVENT_MOUSEWHEEL  = 'マウスホイール回した時';
  EVENT_FILEDROP    = 'ファイルドロップした時';
  EVENT_COPYDATA    = 'COPYDATA受けた時';
  EVENT_TIMER       = '時満ちた時';
  EVENT_ACTIVATE    = 'アクティブ化した時';
  EVENT_COMPLETE    = '完了した時';
  EVENT_ACTIVATE2   = 'アクティブ時';
  EVENT_DEACTIVATE  = '非アクティブ時';
  EVENT_MINIMIZE    = '最小化した時';
  EVENT_RESTORE     = '元通り時';
  EVENT_PAINT       = '描画する時';
  EVENT_MOUSEENTER  = 'マウス入った時';
  EVENT_MOUSELEAVE  = 'マウス出た時';
  EVENT_LISTOPEN    = 'リスト開いた時';
  EVENT_LISTCLOSE   = 'リスト閉じた時';
  EVENT_LISTSELECT  = 'リスト選択した時';

const
VCL_GUI_BUTTON = 0;
VCL_GUI_EDIT   = 1;
VCL_GUI_MEMO   = 2;
VCL_GUI_LIST   = 3;
VCL_GUI_COMBO  = 4;
VCL_GUI_BAR    = 5;
VCL_GUI_PANEL  = 6;
VCL_GUI_CHECK  = 7;
VCL_GUI_RADIO  = 8;
VCL_GUI_GRID   = 9;
VCL_GUI_IMAGE  = 10;
VCL_GUI_LABEL      = 11;
VCL_GUI_MENUITEM   = 12;
VCL_GUI_TABPAGE    = 13;
VCL_GUI_CALENDER   = 14;
VCL_GUI_TREEVIEW   = 15;
VCL_GUI_LISTVIEW   = 16;
VCL_GUI_STATUSBAR  = 17;
VCL_GUI_TOOLBAR    = 18;
VCL_GUI_TIMER      = 19;
VCL_GUI_WEBBROWSER = 20;
VCL_GUI_SPINEDIT   = 21;
VCL_GUI_TRACKBOX   = 22;
VCL_GUI_TEDITOR    = 23;
VCL_GUI_KANA_EDIT  = 24;
VCL_GUI_PROPEDIT   = 25;
VCL_GUI_FORM       = 26;
VCL_GUI_MAINMENU   = 27;
VCL_GUI_POPUPMENU  = 28;
VCL_GUI_SPLITTER   = 29;
VCL_GUI_IMAGELIST  = 30;
VCL_GUI_TOOLBUTTON = 31;
VCL_GUI_TREENODE   = 32;
VCL_GUI_ANIME      = 33;
VCL_GUI_PIC_BUTTON = 34;
VCL_GUI_BIT_BUTTON   = 35;
VCL_GUI_SCROLL_PANEL = 36;
VCL_GUI_PROGRESS = 37;
VCL_GUI_GROUPBOX = 38;

VCL_GUI_UBUTTON = 39;
VCL_GUI_UEDIT   = 40;
VCL_GUI_UMEMO   = 41;
VCL_GUI_ULIST   = 42;
VCL_GUI_UCOMBO  = 43;
VCL_GUI_UCHECK  = 44;
VCL_GUI_URADIO  = 45;
VCL_GUI_UGRID   = 46;
VCL_GUI_ULABEL  = 47;

VCL_GUI_RADIOGROUP = 48;


//BASIC PROPERTY
VCL_PROP_NAME = 0;
VCL_PROP_ID = 1;
VCL_PROP_HANDLE = 2;
//SIZE
VCL_PROP_X = 10;
VCL_PROP_Y = 11;
VCL_PROP_W = 12;
VCL_PROP_H = 13;
//OPTION
VCL_PROP_TEXT  = 14;
VCL_PROP_VALUE = 15;
VCL_PROP_ITEM  = 16;
VCL_PROP_SEL_TEXT   = 17;
VCL_PROP_SEL_START  = 18;
VCL_PROP_SEL_LENGTH = 19;
VCL_PROP_LAYOUT = 20;
VCL_PROP_PARENT = 21;
VCL_PROP_VISIBLE = 22;
VCL_PROP_ENABLED = 23;
VCL_PROP_DRAGMODE = 24;
VCL_PROP_FILEDROP = 25;
VCL_PROP_HINT = 26;

type
  PGuiInfo = ^TGuiInfo;
  TGuiInfo = record
    pgroup  : PHiValue;
    obj     : TComponent;
    obj_type: Integer;
    name    : AnsiString;
    name_id : DWORD;
    fileDrop: TFileDrop;
    freetag: Integer; // 自由に使えるタグ
  end;

var
  guiCount: Integer = 1; // ID = 0 : 母艦
  GuiInfos: array [0..2047] of TGuiInfo; // 最大 2048 もあればいいでしょう...
  EventObject: PHiValue = nil;
  parentObj: TComponent = nil;

// なでしこに必要な関数を追加する
procedure RegistCallbackFunction(bokanHandle: Integer);

//
procedure getPenBrush(Canvas: TCanvas = nil);
procedure getFont(Canvas: TCanvas = nil);
procedure getFontDialog(Font: TFont = nil);
procedure setFontName(Font: TFont; name: string);
function nako_eval_str(src: AnsiString): PHiValue;
procedure nako_eval_str2(src: AnsiString);

function RGB2Color(c: Integer): Integer;
function Color2RGB(c: TColor): Integer;


//
function vcl_create(h: DWORD): PHiValue; stdcall;
function vcl_getprop(h: DWORD): PHiValue; stdcall;
function vcl_setprop(h: DWORD): PHiValue; stdcall;
function vcl_command(h: DWORD): PHiValue; stdcall;
function vcl_free(h: DWORD): PHiValue; stdcall;



function LoadPic(fname: string): TBitmap;
procedure SavePic(bmp: TBitmap; fname: string);
function fontStyleToStr(fs: TFontStyles): AnsiString;
function StrTofontStyle(fs: string): TFontStyles;

procedure setDialogIME(h: THandle); //ダイアログIME状態
function setControlIME(v: AnsiString): TImeMode;
function getIMEStatusName(mode: TImeMode): AnsiString; //IME状態
procedure GetDialogSetting(var title: string; var init: string; var cancel: string; var ime: string);
function getDialogS(ValueName: AnsiString; initValue: AnsiString): AnsiString; // ダイアログ詳細から値を取り出す

function getGui(g: PHiValue): TObject; // オブジェクトを取得
function getGuiName(g: PHiValue): AnsiString; // オブジェクトの名前を取得
function getGuiObj(o: PHiValue): TObject; // オブジェクトを取得
function getCanvasFromObj(obj: TObject): TCanvas; // オブジェクトを取得
function getCanvas(o: PHiValue): TCanvas; // オブジェクトを取得
function getBmp(o: PHiValue): TBitmap; // オブジェクトを取得
function getImage(o: PHiValue): TImage; // オブジェクトを取得
function getGroupName(group: PHiValue): AnsiString; // グループ名を取得する

function IsDialogConvNum: Boolean;

function ShowModalCheck(Form, Parent: TForm): Integer;

type
  TMemo = class(StdCtrls.TMemo)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TEdit = class(StdCtrls.TEdit)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TButton = class(StdCtrls.TButton)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TStringGrid = class(Grids.TStringGrid)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TBitBtn = class(Buttons.TBitBtn)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TSpeedButton = class(Buttons.TSpeedButton)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TListBox = class(StdCtrls.TListBox)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TComboBox = class(StdCtrls.TComboBox)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TScrollBar = class(StdCtrls.TScrollBar)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TProgressBar = class(ComCtrls.TProgressBar)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TGroupBox = class(StdCtrls.TGroupBox)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TScrollBox = class(Forms.TScrollBox)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TCheckBox = class(StdCtrls.TCheckBox)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TStrSortGrid = class(StrSortGrid.TStrSortGrid)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TLabel = class(StdCtrls.TLabel)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TPageControl = class(ComCtrls.TPageControl)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TMonthCalendar = class(ComCtrls.TMonthCalendar)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TStatusBar = class(ComCtrls.TStatusBar)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TToolBar = class(ComCtrls.TToolBar)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TTrackBox = class(TrackBox.TTrackBox)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TValueListEditor = class(ValEdit.TValueListEditor)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  TToolButton = class(ComCtrls.TToolButton)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

implementation

uses
  StrUnit, unit_string, frmNakoU, CsvUtils2, CsvUtils2Grid, hima_types,
{$IF RTLVersion>=15}
  SHDocVw,
{$ELSE}
  SHDocVw_TLB,
{$IFEND}
  TypInfo, frmDebugU, Math, AnimeBox, ABitmap,
  ABitmapFilters, bmp_filter, nstretchf, frmMemoU, frmInputU,
  unit_pack_files, hima_stream, frmInputListU, frmPasswordU,
  frmSelectButtonU, dll_plugin_helper, unit_tree_list, frmSayU,
  frmInputNumU, frmHukidasiU, jvIcon, clipbrd, memoXP, SPILib,
  MedianCut, unit_vista, frmListU, unit_nakopanel, GraphicEx,
  frmCalendarU, frmErrorU
  , HViewEdt, NadesikoFountain, DelphiFountain, HTMLFountain, PerlFountain,
  CppFountain, JavaFountain;

type
  TRingBufferString = class
    private
      FCapacity: integer;
      FFront: integer;
      FBack: integer;
      FBuffer: array of AnsiChar;
      procedure SetText(const str:AnsiString);
      function GetText:AnsiString;
    public
      procedure Add(const str:AnsiString);
      property Capacity:Integer read FCapacity;
      property Text:AnsiString read GetText write SetText;
      constructor Create(maxsize:integer);
  end;

const
  PRINT_LOG_SIZE = 32768;

var
  baseX,
  baseY,
  baseInterval: PHiValue;
  baseFont,
  baseFontSize,
  baseFontColor: PHiValue;
  penWidth,
  penColor,
  penStyle,
  brushColor,
  brushStyle,
  tabCount,
  printLog: PHiValue;
  printLogBuf: TRingBufferString;

procedure _TrackMouseEvent(handle:HWND;time:Cardinal);
var
  tme:TTrackMouseEvent;
begin
  tme.cbSize := sizeof(tme);
  tme.dwFlags := TME_HOVER;
  tme.hwndTrack := Handle;
  tme.dwHoverTime := Time;
  TrackMouseEvent(tme);
end;

{TButton}
procedure TButton.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TButton.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TButton.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{TBitBtn}
procedure TBitBtn.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TBitBtn.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TBitBtn.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{TSpeedButton}
procedure TSpeedButton.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  //_TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TSpeedButton.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TSpeedButton.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{TListBox}
procedure TListBox.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TListBox.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TListBox.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{TComboBox}
procedure TComboBox.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TComboBox.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TComboBox.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

// Vista/7/8のIntegralHeightが有効の時、Hegihtの値を無視して
// 高さが拡張されてしまうバグへの対策
procedure TComboBox.CreateParams(var Params: TCreateParams);
var
  Version: TOSVERSIONINFO;
begin
  inherited CreateParams(Params);
  Version.dwOSVersionInfoSize := SizeOf(Version);
  if GetVersionEx(Version) and (Version.dwMajorVersion > 5) then
    Params.Style := Params.Style or CBS_NOINTEGRALHEIGHT;
end;

{ TMemo }

procedure TMemo.CMMouseEnter(var Msg: TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TMemo.CMMouseLeave(var Msg: TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TMemo.WMMouseHover(var Msg: TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{ TStringGrid }
procedure TStringGrid.CMMouseEnter(var Msg: TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TStringGrid.CMMouseLeave(var Msg: TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TStringGrid.WMMouseHover(var Msg: TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;


{ TEdit }
procedure TEdit.CMMouseEnter(var Msg: TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TEdit.CMMouseLeave(var Msg: TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TEdit.WMMouseHover(var Msg: TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;


{ TTrackBox }

procedure TTrackBox.CMMouseEnter(var Msg: TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Canvas.Handle, FHoverTime);
end;

procedure TTrackBox.CMMouseLeave(var Msg: TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TTrackBox.WMMouseHover(var Msg: TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{ TValueListEditor }

procedure TValueListEditor.CMMouseEnter(var Msg: TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TValueListEditor.CMMouseLeave(var Msg: TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TValueListEditor.WMMouseHover(var Msg: TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{ TToolButton }

procedure TToolButton.CMMouseEnter(var Msg: TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Canvas.Handle,FHoverTime);
end;

procedure TToolButton.CMMouseLeave(var Msg: TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TToolButton.WMMouseHover(var Msg: TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;


{TScrollBar}
procedure TScrollBar.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TScrollBar.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TScrollBar.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{TProgressBar}
procedure TProgressBar.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TProgressBar.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TProgressBar.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{TGroupBox}
procedure TGroupBox.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TGroupBox.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TGroupBox.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{TScrollBox}
procedure TScrollBox.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TScrollBox.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TScrollBox.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{TCheckBox}
procedure TCheckBox.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TCheckBox.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TCheckBox.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{TStrSortGrid}
procedure TStrSortGrid.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TStrSortGrid.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TStrSortGrid.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{TLabel}
procedure TLabel.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  //_TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TLabel.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TLabel.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{TPageControl}
procedure TPageControl.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TPageControl.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TPageControl.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{TMonthCalendar}
procedure TMonthCalendar.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TMonthCalendar.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TMonthCalendar.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{TStatusBar}
procedure TStatusBar.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TStatusBar.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TStatusBar.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{TToolBar}
procedure TToolBar.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TToolBar.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TToolBar.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

constructor TRingBufferString.Create(maxsize:integer);
begin
  FCapacity := maxsize;
  SetLength(FBuffer,FCapacity+1);//+1しないと、指定された容量分使えないため
  FFront := 0;
  FBack := 0;
end;

function TRingBufferString.GetText:AnsiString;
begin
  if FFront = FBack then
    Result := ''
  else if FFront < FBack then
  begin
    SetLength(Result,FBack-FFront);
    Move(FBuffer[FFront],Result[1],FBack-FFront);
  end else
  begin // 内容が終端から頭に戻ってきている
    SetLength(Result,FCapacity-FFront+1+FBack);
    Move(FBuffer[FFront],Result[1],FCapacity-FFront+1);
    Move(FBuffer[0],Result[FCapacity-FFront+1+1],FBack);
  end;
end;

procedure TRingBufferString.SetText(const str:AnsiString);
begin
  FFront := 0;
  if Length(str) < FCapacity then
  begin
    Move(str[1],FBuffer[0],Length(str));
    FBack := Length(str) + 1;
  end
  else
  begin
    Move(str[Length(str)-FCapacity-1],FBuffer[0],FCapacity);
    FBack := FCapacity + 1;
  end;
end;

procedure TRingBufferString.Add(const str:AnsiString);
var
  len,front:Integer;
begin
  len := Length(str);
  if len > FCapacity then
  begin
    front := Length(str)-FCapacity+1;
    len := FCapacity;
  end
  else
    front := 1;

  if FFront <= FBack then // --F---B--
  begin
    if FCapacity - FBack + 1 >= len then // --F---B*-
    begin
      Move(str[front],FBuffer[Fback],len);
      Inc(FBack,len);
    end
    else // *-F---B**
    begin
      Move(str[front],FBuffer[Fback],FCapacity-FBack+1);
      Move(str[front+FCapacity-FBack+1],FBuffer[0],len-(FCapacity-FBack+1));
      FBack := len-(FCapacity-FBack+1);
      if FBack > FFront then FFront := (FBack + 1)mod(FCapacity+1);
    end;
  end else // --B---F--
  begin
    if FCapacity - FBack + 1 >= len then // --B**-F--
    begin
      Move(str[front],FBuffer[Fback],len);
      Inc(FBack,len);
      if FBack > FFront then FFront := (FBack + 1)mod(FCapacity+1);
    end
    else // *-B***F**
    begin
      Move(str[front],FBuffer[Fback],FCapacity-FBack+1);
      Move(str[front+FCapacity-FBack+1],FBuffer[0],len-(FCapacity-FBack+1));
      FBack := len-(FCapacity-FBack+1);
      FFront := (FBack + 1)mod(FCapacity+1);
    end;
  end;
end;

function nako_eval_str(src: AnsiString): PHiValue;
var
  s: AnsiString;
begin
  Result := nil;

  if nako_evalEx(PAnsiChar(src), Result) = False then
  begin
    s := nako_getErrorStr;
    nako_continue;
    raise Exception.Create(string(s));
  end;

end;

procedure nako_eval_str2(src: AnsiString);
var
  p: PHiValue;
begin
  p := nako_eval_str(src);
  nako_var_free(p);
end;

function RGB2Color(c: Integer): Integer;
var
  r,g,b:Byte;
begin
  // RR GG BB
  // BB GG RR
  r := (c shr 16) and $FF;
  g := (c shr 8 ) and $FF;
  b := (c       ) and $FF;
  Result := RGB(r, g, b);
end;

function Color2RGB(c: TColor): Integer;
var
  r,g,b:Byte;
begin
  c := ColorToRGB(c);
  //
  r := (c shr 16) and $FF;
  g := (c shr 8 ) and $FF;
  b := (c       ) and $FF;
  //
  Result := (b shl 16) or (g shl 8) or r;
end;

function IsDialogConvNum: Boolean;
var p: PHiValue;
begin
  p := nako_getVariable('ダイアログ数値変換');
  Result := hi_bool(p);
end;

function IsTopMost(h: THandle):Boolean;
var
  ws: DWORD;
begin
  ws := GetWindowLong(h, GWL_EXSTYLE);
  if (ws and WS_EX_TOPMOST) > 0 then
  begin
    Result := True;
  end else
  begin
    Result := False;
  end;
end;

function ShowModalCheck(Form, Parent: TForm): Integer;
var
  b: Boolean;
  cap: AnsiString;
begin
  if (Parent is TForm) then
  begin
    if Form is TfrmError then
    begin
      cap := hi_str(nako_getVariable(''));
      if True then
      
    end;

    Application.ProcessMessages;
    b := IsTopMost(Parent.Handle);
    if b then
    begin
      SetWindowPos(Form.Handle, HWND_NOTOPMOST, 0,0,0,0,SWP_NOSIZE or SWP_NOMOVE);
    end;
    Result := Form.ShowModal;
    if b then
    begin
      SetWindowPos(Parent.Handle, HWND_TOPMOST, 0,0,0,0,SWP_NOSIZE or SWP_NOMOVE);
    end;
  end else
  begin
    Result := Form.ShowModal;
  end;
end;

//------------------------------------------------------------------------------

function LoadPic(fname: string): TBitmap;

  procedure _bmp;
  begin
    Result.LoadFromFile(fname);
  end;


{$IF RTLVersion >=15}
  procedure _png;
  var png: TPNGGraphic;
  begin
    png := TPNGGraphic.Create;
    try
      png.LoadFromFile(fname);
      Result.Assign(png);
    finally
      png.Free;
    end;
  end;
{$ELSE}
  // pngimage のバグか？色化けが激しすぎる！！
  procedure _png;
  var png: TPNGObject;
  begin
    png := TPNGObject.Create;
    try
      png.LoadFromFile(fname);
      Result.Assign(png);
    finally
      png.Free;
    end;
  end;
{$IFEND}
  procedure _jpeg;
  var jpg: TJPEGImage;
  begin
    jpg := TJPEGImage.Create;
    try
      jpg.LoadFromFile(fname);
      Result.Assign(jpg);
    finally
      jpg.Free;
    end;
  end;

  procedure _gif;
  var gif: TGIFImage;
  begin
    gif := TGIFImage.Create;
    try
      gif.LoadFromFile(fname);
      Result.Assign(gif);
    finally
      gif.Free;
    end;
  end;

  procedure _mag;
  var mag: TMAGImage;
  begin
    mag := TMAGImage.Create;
    try
      mag.LoadFromFile(fname);
      Result.Assign(mag);
    finally
      mag.Free;
    end;
  end;

  procedure _ico;
  var ico: TIcon;
  begin
    ico := TIcon.Create;
    try
      ico.LoadFromFile(fname);
      Result.Width  := ico.Width;
      Result.Height := ico.Height;
      DrawIcon(
        Result.Canvas.Handle,
        0, 0, ico.Handle);
    finally
      ico.Free;
    end;
  end;

  procedure _susie;
  var spi: TSpiLib32;
  begin
    spi := TSpiLib32.Create(nil);
    try
      spi.LoadPlugIn(AnsiString(ExtractFilePath(ParamStr(0))));
      spi.LoadFromFile(AnsiString(fname), Result);
    finally
      spi.Free;
    end;
  end;

  procedure _graphicex;
  var
    GraphicClass: TGraphicExGraphicClass;
    Graphic: TGraphic;
  begin
    GraphicClass := FileFormatList.GraphicFromContent(fname);
    if GraphicClass = nil then raise Exception.Create('未対応の画像フォーマット');
    begin
      Graphic := GraphicClass.Create;
      try
        try
          Graphic.LoadFromFile(fname);
          Result.Width := Graphic.Width;
          Result.Height := Graphic.Height;
          Result.PixelFormat := pf24bit;
          Result.Canvas.Draw(0,0,Graphic);
        except
          _susie;
        end;
      finally
        FreeAndNil(Graphic);
      end;
    end;
  end;


var
  ext: string;
  p: PHiValue;
  b: TBitmap;
begin
  Result := TBitmap.Create;
  Result.PixelFormat := pf24bit;

  // クリップボード？
  if fname = 'クリップボード' then
  begin
    if Clipboard.HasFormat(CF_BITMAP) then
    begin
      Result.Assign(Clipboard);
    end;
    Exit;
  end;

  // イメージ部品かどうか？
  ext := LowerCase(ExtractFileExt(fname));
  if ext = '' then
  begin
    p := nako_getVariable(PAnsiChar(AnsiString(fname)));
    if (p<>nil)and(p.VType = varGroup) then
    begin
      b := GetBMP(p);
      if b = nil then raise Exception.Create('GUI部品の『'+fname+'』からイメージを取り出せませんでした。');
      Result.Assign(b);
      Exit;
    end;
  end;

  ExtractMixFile(fname);
  ext := LowerCase(ExtractFileExt(fname));

  // nadesiko default support
  if ext = '.png'  then _png  else
  if ext = '.jpg'  then _jpeg else
  if ext = '.jpeg' then _jpeg else
  if ext = '.gif'  then _gif  else
  if ext = '.bmp'  then _bmp  else
  if ext = '.ico'  then _ico  else
  if ext = '.mag'  then _mag  else
  // use graphicex image library
  if Pos(ext+'/',
  '.bw/.rgb/.rgba/.sgi/.cel/.pic/.tif/.tiff/.tga/.vst/.icb/.vda/.win/.pcx/.pcc/.scr/.pcd/.ppm/.pgm/.pbm/.cut/.rla/.rpf/.psd/.pdd/.psp/.eps'
  ) > 0 then
  begin
    _graphicex;
  end else
  begin
    try
      _susie;
    except
      raise Exception.CreateFmt('"%s"は未対応の画像タイプです。',[ext]);
    end;
  end;
  ;

end;

procedure SavePic(bmp: TBitmap; fname: string);
var
  ext: string;
    g: TGraphic;

  procedure _png ;
  begin
    bmp.PixelFormat := pf24bit;
{$IF RTLVersion >=20}
    g := TPNGGraphic.Create;
{$ELSEIF RTLVersion >=15}
    g := TGldPng.Create;
{$ELSE}
    g := TPNGObject.Create;
{$IFEND}
  end;
  procedure _jpeg;
  var
    v: PHiValue;
    per: Integer;
  begin
    v := nako_getVariable('JPEG圧縮率');
    if v <> nil then
    begin
      per := hi_int(v);
    end else
    begin
      per := 80;
    end;
    if per < 30 then per := 30;
    g := TJpegImage.Create;
    TJpegImage(g).CompressionQuality := per;
  end;
  procedure _gif;
  begin
    bmp.PixelFormat := pf24bit;
    bmp := ReduceColorsByMedianCutED(bmp, 8);
    g := TGIFImage.Create;
  end;
  procedure _mag;
  begin
    bmp.PixelFormat := pf24bit;
    g := TMAGImage.Create;
  end;
  procedure _bmp;  begin g := TBitmap.Create;    end;

  procedure _ico;
  var icon: TjvIcon;
  begin
    if bmp.PixelFormat = pf4bit then
    begin
      g := TIcon.Create;
      g.SaveToFile(fname);
      g.Free;
    end else
    begin
      icon := TjvIcon.Create(nil);
      icon.SaveAsIcon256(bmp, fname);
      icon.Free;
    end;
  end;

begin
  // クリップボードへの保存？
  if fname = 'クリップボード' then
  begin
    Clipboard.Assign(bmp);
    Exit;
  end;

  ext := LowerCase( ExtractFileExt(fname) );

  // ファイルへの保存
  // CREATE
  if ext = '.png'  then _png  else
  if ext = '.jpg'  then _jpeg else
  if ext = '.jpeg' then _jpeg else
  if ext = '.gif'  then _gif  else
  if ext = '.bmp'  then _bmp  else
  if ext = '.ico'  then begin _ico; Exit; end else
  if ext = '.mag'  then _mag  else
  raise Exception.CreateFmt('"%s"は未対応の画像タイプです。',[ext]);
  ;
  // ASSIGN
  g.Assign(bmp);
  // SAVE
  g.SaveToFile(fname);
  // FREE
  g.Free;
end;

function fontStyleToStr(fs: TFontStyles): AnsiString;
begin
  //fsBold, fsItalic, fsUnderline, fsStrikeOut)
  Result := '';
  if fsBold       in fs then Result := Result + '太字';
  if fsItalic     in fs then Result := Result + '斜体';
  if fsUnderline  in fs then Result := Result + '下線';
  if fsStrikeOut  in fs then Result := Result + '打消';
end;

function StrTofontStyle(fs: string): TFontStyles;
begin
  Result := [];
  if Pos('太字', fs) > 0 then Result := Result + [fsBold];
  if Pos('斜体', fs) > 0 then Result := Result + [fsItalic];
  if Pos('下線', fs) > 0 then Result := Result + [fsUnderline];
  if Pos('打消', fs) > 0 then Result := Result + [fsStrikeOut];
end;

procedure getPenBrush(Canvas: TCanvas = nil);
var
  ps, bs: AnsiString;
begin
  if Canvas = nil then Canvas := Bokan.BackCanvas;

  // PEN
  Canvas.Pen.Width := hi_int(penWidth);
  Canvas.Pen.Color := RGB2Color( hi_int(penColor) );
  // PEN.STYLE
  ps := hi_str(penStyle);
  if ps = '実線' then Canvas.Pen.Style := psSolid else
  if ps = '点線' then begin Canvas.Pen.Style := psDot; Canvas.Pen.Width := 1; end else
  if ps = '破線' then begin Canvas.Pen.Style := psDash;Canvas.Pen.Width := 1; end else
  if (ps = '')or(ps = 'なし')or(ps = '透明') then Canvas.Pen.Style := psClear else
  begin
    Canvas.Pen.Style := psSolid;
  end;

  // BRUSH
  Canvas.Brush.Color := RGB2Color( hi_int(brushColor) );
  // BRUSH.STYLE
  bs := hi_str(brushStyle);
  if (bs = 'べた')or(bs = 'ベタ') then Canvas.Brush.Style := bsSolid else
  if bs = '透明' then Canvas.Brush.Style := bsClear else
  if bs = '格子' then Canvas.Brush.Style := bsCross else
  if bs = '横線' then Canvas.Brush.Style := bsHorizontal else
  if bs = '縦線' then Canvas.Brush.Style := bsVertical else
  if bs = '左斜め線' then Canvas.Brush.Style := bsFDiagonal else
  if bs = '右斜め線' then Canvas.Brush.Style := bsBDiagonal else
  if bs = '十字線' then Canvas.Brush.Style := bsCross else
  if bs = '斜め十字線' then Canvas.Brush.Style := bsDiagCross else
  Canvas.Brush.Style := bsSolid;

end;

procedure getFont(Canvas: TCanvas = nil);
var
  s: string;
begin
  //Bokan.Canvas.CSelectFont(hi_str(baseFont), nako_var2int(baseFontSize));
  if Canvas = nil then Canvas := Bokan.BackCanvas;
  s := hi_strU(baseFont);

  Canvas.Font.Size    := hi_int(baseFontSize);
  Canvas.Font.Charset := DEFAULT_CHARSET;
  Canvas.Font.Color   := RGB2Color( hi_int(baseFontColor) );
  Canvas.Brush.Style  := bsClear;

  if Pos('|', s) > 0 then
  begin // 複数指定あり
    Canvas.Font.Name   := string(getToken_s(s, '|'));
    if s <> '' then Canvas.Font.Size  := StrToIntDef(getToken_s(s,'|'),10);
    if s <> '' then Canvas.Font.Style := StrTofontStyle(getToken_s(s,'|'));
  end else
  begin
    Canvas.Font.Name   := string(s);
  end;

end;

procedure getFontDialog(Font: TFont);
var
  s: string;
  sa: AnsiString;
begin
  getFont(bokan.BackCanvas);
  if Font = nil then Font := Bokan.BackCanvas.Font;

  Font.Size    := StrToIntDefA(getDialogS('文字サイズ','10'),10);
  Font.Charset := DEFAULT_CHARSET;
  // 色
  s := string(getDialogS('文字色','0'));
  sa := AnsiString(s);
  if not IsNumber(sa) then s := hi_strU(nako_eval_str(AnsiString(s))) else s := string(sa);
  Font.Color := Color2RGB(StrToIntDef(s, 0));
  // 書体
  s := string(getDialogS('文字書体', AnsiString(bokan.BackCanvas.Font.Name)));
  if Pos('|', s) > 0 then
  begin // 複数指定あり
    Font.Name   := string(getToken_s(s, '|'));
    if s <> '' then Font.Size  := StrToIntDef(getToken_s(s,'|'),10);
    if s <> '' then Font.Style := StrTofontStyle(getToken_s(s,'|'));
  end else
  begin
    Font.Name   := string(s);
  end;
end;

procedure setFontName(Font: TFont; name: string);
begin
  if Pos('|', name) > 0 then
  begin
    Font.Name   := string(getToken_s(name, '|'));
    if name <> '' then Font.Size  := StrToIntDef(getToken_s(name,'|'),10);
    if name <> '' then Font.Style := StrTofontStyle(getToken_s(name,'|'));
  end else
  begin
    Font.Name := string(name);
  end;
end;

function getGui(g: PHiValue): TObject; // オブジェクトを取得
var
  p: PHiValue;
begin
  // group の オブジェクトが保持する
  if g = nil then
  begin
    Result := bokan; Exit;
  end;
  p := nako_group_findMember(g, 'オブジェクト');
  if p = nil then
  begin
    raise Exception.Create('オブジェクトが特定できませんでした。');
  end else
  begin
    Result := TObject(hi_int(p));
  end;
end;

function getGroupName(group: PHiValue): AnsiString; // グループ名を取得する
var
  buf: AnsiString;
begin
  SetLength(buf, 1024);
  nako_id2tango(group.VarID, PAnsiChar(buf), 1023);
  Result := AnsiString(PAnsiChar(buf));
end;

function getGuiName(g: PHiValue): AnsiString; // オブジェクトの名前を取得
var
  p: PHiValue;
begin
  // group の オブジェクトが保持する
  if g = nil then
  begin
    Result := '母艦'; Exit;
  end;
  p := nako_group_findMember(g, '名前');
  if p = nil then
  begin
    raise Exception.Create('オブジェクトが特定できませんでした。');
  end else
  begin
    Result := hi_str(p);
  end;
end;


function getGuiObj(o: PHiValue): TObject; // オブジェクトを取得
begin
  if o = nil then
  begin
    Result := bokan;
  end else
  begin
    try
      Result := TObject(hi_int(o));
    except
      Result := bokan;
    end;
  end;
end;

function getCanvasFromObj(obj: TObject): TCanvas; // オブジェクトを取得
var bmp: TBitmap;
begin
  if obj is TfrmNako then
  begin
    Result := TfrmNako(obj).BackCanvas;
  end else
  if obj is TImage then
  begin
    Result := TImage(obj).Canvas;
  end else
  if obj is TBitmap then
  begin
    Result := TBitmap(obj).Canvas;
  end else
  if obj is TAnimeBox then
  begin
    Result := TAnimeBox(obj).Canvas;
  end else
  if obj is TSpeedButton then
  begin
    if not TSpeedButton(obj).Glyph.HandleAllocated then
    begin
      bmp := TBitmap.Create;
      bmp.Width := TSpeedButton(obj).Width;
      bmp.Height := TSpeedButton(obj).Height;
      TSpeedButton(obj).Glyph.Assign(bmp);
      bmp.Free;
    end;
    Result := TSpeedButton(obj).Glyph.Canvas;
  end else
  begin
    Result := bokan.BackCanvas;
  end;
end;

function getCanvas(o: PHiValue): TCanvas; // オブジェクトを取得
var
  obj: TObject;
begin
  obj := getGui(o);
  Result := getCanvasFromObj(obj);
end;

function getBmp(o: PHiValue): TBitmap; // オブジェクトを取得
var
  obj: TObject;
begin
  obj := getGui(o);

  if obj is TfrmNako then
  begin
    Result := TfrmNako(obj).backBmp;
  end else
  if obj is TImage then
  begin
    if not(TImage(obj).Picture.Graphic is TBitmap) then
    begin
      Result := TBitmap.Create;
      try
        Result.Width  := TImage(obj).Width;
        Result.Height := TImage(obj).Height;
        {
        if TImage(obj).Picture.Graphic is TGIFImage then
        begin
          gif := TImage(obj).Picture.Graphic as TGIFImage;
          Result.Canvas.Draw(0, 0, gif);
        end
        else begin
          Result.Canvas.Draw(0, 0, TImage(obj).Picture.Graphic);
        end;
        }
        Result.Canvas.Draw(0, 0, TImage(obj).Picture.Graphic);
        {
        BitBlt(Result.Canvas.Handle, 0, 0, Result.Width, Result.Height,
          TImage(obj).Canvas.Handle, 0, 0, SRCCOPY);
        }
      finally
      end;
    end else
    begin
      Result := TImage(obj).Picture.Bitmap;
    end;
  end else
  if obj is TSpeedButton then
  begin
    Result := TSpeedButton(obj).Glyph;
  end else
  if obj is TAnimeBox then
  begin
    Result := TAnimeBox(obj).BackGround;
  end else
  begin
    Result := TfrmNako(obj).backBmp;
  end;
end;

function getImage(o: PHiValue): TImage; // オブジェクトを取得
var
  obj: TObject;
begin
  obj := getGui(o);

  Result := nil;
  if obj is TImage then
  begin
    Result := obj as TImage;
  end;
end;

procedure setDialogIME(h: THandle); //ダイアログIME状態
var
  p: PHiValue;
  v: AnsiString;
begin
  p := nako_getVariable('ダイアログIME');
  if p = nil then Exit;
  v := hi_str(p);
  SetImeMode(h, setControlIME(v));
end;

function setControlIME(v: AnsiString): TImeMode;
begin
  if Copy(v,1,6)='ＩＭＥ' then begin System.Delete(v,1,6); v := 'IME' + v; end;

  v := Copy(v,1,7);
  if v = 'IMEオン' then Result := imOpen  else
  if v = 'IMEオフ' then Result := imClose else
  if (v = 'IMEひら')or(v = 'IMEかな') then Result := imHira  else
  if (v = 'IMEカナ')or(v = 'IMEカタ') then Result := imKata  else
  if v = 'IME半角' then Result := imSKata else
  Result := imDontCare;
end;

function getIMEStatusName(mode: TImeMode): AnsiString; //IME状態
begin
  //IMEオン|IMEオフ|IMEひら|IMEカナ
  {
  TImeMode = (imDisable, imClose, imOpen, imDontCare,
              imSAlpha, imAlpha, imHira, imSKata, imKata,
              imChinese, imSHanguel, imHanguel);
  }
  if mode = imDisable   then Result := 'IMEオフ' else
  if mode = imClose     then Result := 'IMEオフ' else
  if mode = imOpen      then Result := 'IMEオン' else
  if mode = imDontCare  then Result := 'IMEオフ' else
  if mode = imSAlpha    then Result := 'IMEオフ' else
  if mode = imAlpha     then Result := 'IMEオフ' else
  if mode = imHira      then Result := 'IMEかな' else
  if mode = imSKata     then Result := 'IME半角' else
  if mode = imKata      then Result := 'IMEカナ' else
  Result := '';

end;


function cmd_print(h: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  y: Integer;
  str: AnsiString;
  r: TRect;
begin
  // (1) 引数の取得
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;

  // 簡易ログを追加
  printLogBuf.Add((hi_str(p)));
  printLogBuf.Add(#13#10);
  hi_setStr(printLog, AnsiString(printLogBuf.Text));
  //---

  y := nako_var2int(baseY);

  r := RECT(0,0,bokan.ClientWidth, bokan.ClientHeight);
  r.Left := hi_int(baseX);
  r.Top  := y;

  // (2) 処理

  getFont;
  str := hi_str(p);
  if str <> '' then
  begin
    str := ExpandTab(str, hi_int(tabCount));
    y := y + DrawTextA(
      Bokan.BackCanvas.Handle,
      PAnsiChar(str),
      Length(str),
      r,
      DT_LEFT or DT_NOPREFIX or DT_WORDBREAK
    );
  end else
  begin
    y := y + bokan.BackCanvas.TextHeight('a');
  end;
  nako_int2var(y + hi_int(baseInterval), baseY);

  Bokan.flagRepaint := True;

  if Bokan.UseLineNo then
  begin
    Bokan.Redraw;
  end;
  
  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;


function cmd_print_continue(h: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  x, y: Integer;
  str, s: AnsiString;
  hasRet: Boolean;
begin
  // (1) 引数の取得
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;

  // 簡易ログを追加
  printLogBuf.Add((hi_str(p)));
  hi_setStr(printLog, AnsiString(printLogBuf.Text));

  //---
  getFont;

  x := nako_var2int(baseX);
  y := nako_var2int(baseY);

  // (2) 処理
  str := hi_str(p);
  str := ExpandTab(str, hi_int(tabCount));
  hasRet := False;

  while True do
  begin
    hasRet := (PosA(#13#10, str) > 0);
    if hasRet then begin
      s := getToken_s(str, #13#10)
    end else begin
      s := str;
      str := '';
    end;
    bokan.BackCanvas.TextOut(x, y, string(s));
    if hasRet then
    begin
      y := y + bokan.BackCanvas.TextHeight('a') + hi_int(baseInterval);
      x := 10;
    end;
    if str = '' then Break;
  end;
  if hasRet = False then
  begin
    x := x + bokan.BackCanvas.TextWidth(string(s));
    if x > bokan.ClientWidth then x := 10;
  end;
  hi_setInt(baseX, x);
  hi_setInt(baseY, y);

  Bokan.flagRepaint := True;
  if Bokan.UseLineNo then
  begin
    Bokan.Redraw;
  end;

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_cls(h: DWORD): PHiValue; stdcall;
var
  o, p: PHiValue;
  c: Integer;
  gui: TObject;
begin
  // (1) 引数の取得
  o := nako_getFuncArg(h, 0);
  if o = nil then
  begin
    gui := Bokan;
  end else
  begin
    gui := getGui(o);
  end;

  p := nako_getFuncArg(h, 1);
  if p = nil then p := nako_getSore;

  c := nako_var2int(p);
  // RRGGBBに変換
  c := RGB2Color(c);

  // (2) 処理
  if gui is TfrmNako then
  begin
    TfrmNako(gui).ClearScreen(c);
    TfrmNako(gui).flagRepaint := True;
    TfrmNako(gui).Color := c;
  end else
  if gui is TImage then
  begin
    with TImage(gui) do begin
      Picture := nil;
      Canvas.Pen.Color := c;
      Canvas.Brush.Color := c;
      Canvas.Brush.Style := bsSolid;
      Canvas.Pen.Style := psSolid;
      Canvas.Rectangle(0,0, Width, Height);
    end;
  end;

  if Bokan.UseLineNo then
  begin
    Bokan.Redraw;
  end;

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_move(h: DWORD): PHiValue; stdcall;
var
  x, y: PHiValue;
begin
  // (1) 引数の取得
  x := nako_getFuncArg(h, 0);
  y := nako_getFuncArg(h, 1);

  // (2) 処理
  nako_varCopyData(x, baseX);
  nako_varCopyData(y, baseY);

  Bokan.BackCanvas.MoveTo(nako_var2int(x), nako_var2int(y));

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;


function cmd_line(h: DWORD): PHiValue; stdcall;
var
  x1, y1, x2, y2: PHiValue;
  i1, i2, i3, i4: Integer;
  gui: TObject;
begin
  // (1) 引数の取得
  gui := getGui( nako_getFuncArg(h, 0) );
  x1  := nako_getFuncArg(h, 1);
  y1  := nako_getFuncArg(h, 2);
  x2  := nako_getFuncArg(h, 3);
  y2  := nako_getFuncArg(h, 4);

  // (2) 処理
  if (x1=nil)and(y1=nil) then
  begin
    // 基本点からの描画
    i1 := nako_var2int(baseX);
    i2 := nako_var2int(baseY);
    i3 := nako_var2int(x2);
    i4 := nako_var2int(y2);
  end else
  begin
    // 基本点からの描画
    i1 := nako_var2int(x1);
    i2 := nako_var2int(y1);
    i3 := nako_var2int(x2);
    i4 := nako_var2int(y2);
  end;

  if gui is TfrmNako then
  begin
    getPenBrush(TfrmNako(gui).BackCanvas);
    with TfrmNako(gui).BackCanvas do begin
      MoveTo(i1, i2);
      LineTo(i3, i4);
    end;
    Bokan.flagRepaint := True;
  end else
  if gui is TImage then
  begin
    getPenBrush(TImage(gui).Canvas);
    with TImage(gui).Canvas do begin
      MoveTo(i1, i2);
      LineTo(i3, i4);
    end;
  end;


  if Bokan.UseLineNo then
  begin
    Bokan.Redraw;
  end;

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_ExtFloodFill(h: DWORD): PHiValue; stdcall;
var
  xx, yy, c, b: Integer;
  v: TCanvas;
begin
  // (1) 引数の取得
  v  := getCanvas(nako_getFuncArg(h, 0));
  xx := getArgInt(h, 1);
  yy := getArgInt(h, 2);
  c  := RGB2Color(getArgInt(h, 3));
  b  := getArgInt(h, 4);

  // (2) 処理
  Bokan.flagRepaint := True;
  v.Brush.Color := c;
  if b <> Integer($FF000000) then
    ExtFloodFill(v.Handle, xx, yy, RGB2Color(b), FLOODFILLBORDER)
  else
    ExtFloodFill(v.Handle, xx, yy, v.Pixels[xx,yy], FLOODFILLSURFACE);
  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_pset(h: DWORD): PHiValue; stdcall;
var
  xx, yy, c: Integer;
  v: TCanvas;
begin
  // (1) 引数の取得
  v  := getCanvas(nako_getFuncArg(h, 0));
  xx := getArgInt(h, 1);
  yy := getArgInt(h, 2);
  c  := RGB2Color(getArgInt(h, 3));

  // (2) 処理
  Bokan.flagRepaint := True;
  v.Pixels[xx, yy] := c;

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_pget(h: DWORD): PHiValue; stdcall;
var
  xx, yy, c: Integer;
  v: TCanvas;
begin
  // (1) 引数の取得
  v  := getCanvas( nako_getFuncArg(h, 0) );
  xx := getArgInt(h, 1);
  yy := getArgInt(h, 2);

  // (2) 処理
  c := v.Pixels[xx, yy];
  c := RGB2Color(c);

  // (3) 結果の代入
  Result := hi_newInt(c); // 何も返さない場合は nil
end;

function cmd_rectangle(h: DWORD): PHiValue; stdcall;
var
  x1, y1, x2, y2: PHiValue;
  i1, i2, i3, i4: Integer;
  c: TCanvas;
begin
  // (1) 引数の取得
  c  := getCanvas(nako_getFuncArg(h, 0));
  x1 := nako_getFuncArg(h, 1);
  y1 := nako_getFuncArg(h, 2);
  x2 := nako_getFuncArg(h, 3);
  y2 := nako_getFuncArg(h, 4);

  // (2) 処理
  i1 := nako_var2int(x1);
  i2 := nako_var2int(y1);
  i3 := nako_var2int(x2);
  i4 := nako_var2int(y2);

  getPenBrush(c);
  c.Rectangle(i1, i2, i3, i4);

  if c.Handle = Bokan.BackCanvas.Handle then
  begin
    Bokan.flagRepaint := True;
  end;

  if Bokan.UseLineNo then
  begin
    Bokan.Redraw;
  end;

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_circle(h: DWORD): PHiValue; stdcall;
var
  x1, y1, x2, y2: PHiValue;
  i1, i2, i3, i4: Integer;
  c: TCanvas;
begin
  // (1) 引数の取得
  c   := getCanvas( nako_getFuncArg(h, 0) );
  x1  := nako_getFuncArg(h, 1);
  y1  := nako_getFuncArg(h, 2);
  x2  := nako_getFuncArg(h, 3);
  y2  := nako_getFuncArg(h, 4);

  // (2) 処理
  i1 := nako_var2int(x1);
  i2 := nako_var2int(y1);
  i3 := nako_var2int(x2);
  i4 := nako_var2int(y2);

  getPenBrush(c);
  c.Ellipse(i1, i2, i3, i4);
  if c.Handle = Bokan.BackCanvas.Handle then
  begin
    Bokan.flagRepaint := True;
  end;
  if Bokan.UseLineNo then
  begin
    Bokan.Redraw;
  end;

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_roundrect(h: DWORD): PHiValue; stdcall;
var
  x1, y1, x2, y2, m1, m2: PHiValue;
  i1, i2, i3, i4, i5, i6: Integer;
  c: TCanvas;
begin
  // (1) 引数の取得
  c  := getCanvas(nako_getFuncArg(h, 0));
  x1 := nako_getFuncArg(h, 1);
  y1 := nako_getFuncArg(h, 2);
  x2 := nako_getFuncArg(h, 3);
  y2 := nako_getFuncArg(h, 4);
  m1 := nako_getFuncArg(h, 5);
  m2 := nako_getFuncArg(h, 6);

  // (2) 処理
  i1 := nako_var2int(x1);
  i2 := nako_var2int(y1);
  i3 := nako_var2int(x2);
  i4 := nako_var2int(y2);
  i5 := nako_var2int(m1);
  i6 := nako_var2int(m2);

  getPenBrush(c);
  c.RoundRect(i1, i2, i3, i4, i5, i6);
  if c.Handle = Bokan.BackCanvas.Handle then
  begin
    Bokan.flagRepaint := True;
  end;
  if Bokan.UseLineNo then
  begin
    Bokan.Redraw;
  end;

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_poly(h: DWORD): PHiValue; stdcall;
var
  ps       : PHiValue;
  s        : AnsiString;
  x, y, cnt: Integer;
  pts      : Array of TPoint;
  c        : TCanvas;
  p        : PAnsiChar;
  sx, sy   : AnsiString;
  q        : PAnsiChar;
  i        : Integer;
begin
  // (1) 引数の取得
  c  := getCanvas(nako_getFuncArg(h,0));
  ps := nako_getFuncArg(h, 1);

  // (2) 処理
  SetLength(pts, 128);
  cnt := 0;
  s := hi_str(ps);
  p := PAnsiChar(s);
  while p^ <> #0 do
  begin
    sx := getTokenCh(p, [',',#13]); if p^ = #10 then Inc(p);
    sy := getTokenCh(p, [',',#13]); if p^ = #10 then Inc(p);
    x := Trunc(StrToFloatDef(string(sx), 0));
    y := Trunc(StrToFloatDef(string(sy), 0));

    if cnt = 128 then
    begin
      i:=cnt+1;
      q:=p;
      while q^ <> #0 do
      begin
        getTokenCh(q,[',',#13]); if q^ = #10 then Inc(q);
        getTokenCh(q,[',',#13]); if q^ = #10 then Inc(q);
        inc(i);
      end;
      SetLength(pts,i);
    end;

    pts[cnt].X := x;
    pts[cnt].Y := y;
    Inc(cnt);
  end;

  // 描画
  getPenBrush(c);
  SetLength(pts, cnt);
  c.Polygon(pts);

  if c.Handle = Bokan.BackCanvas.Handle then
  begin
    Bokan.flagRepaint := True;
  end;
  if Bokan.UseLineNo then
  begin
    Bokan.Redraw;
  end;

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_loadPic(h: DWORD): PHiValue; stdcall;
var
  s, x, y : PHiValue;
  xx, yy  : Integer;
  ss      : AnsiString;
  bmp     : TBitmap;
  c       : TCanvas;
begin
  // (1) 引数の取得
  //c := TCanvas( getCanvas(nako_getFuncArg(h, 0)) );
  x := nako_getFuncArg(h, 0);
  y := nako_getFuncArg(h, 1);
  s := nako_getFuncArg(h, 2);
  c := bokan.BackCanvas;

  // (2) 省略時の補完
  if (x=nil)and(y=nil) then
  begin
    x := baseX;
    y := baseY;
  end;

  xx := hi_int(x);
  yy := hi_int(y);
  ss := hi_str(s); // ファイル名

  // (3) 処理
  bmp := LoadPic(string(ss));
  try
    c.Draw(xx, yy, bmp);
    hi_setInt(baseY, hi_int(baseY) + bmp.Height + 4);
  finally
    bmp.Free;
  end;
  // (4) 結果の代入
  Bokan.flagRepaint := True;
  if Bokan.UseLineNo then
  begin
    Bokan.Redraw;
  end;
  Result := nil; // 何も返さない場合は nil
end;
function cmd_loadPic2(h: DWORD): PHiValue; stdcall;
var
  s, x, y : PHiValue;
  xx, yy  : Integer;
  ss      : AnsiString;
  bmp     : TBitmap;
  c       : TCanvas;
begin
  // (1) 引数の取得
  c := TCanvas( getCanvas(nako_getFuncArg(h, 0)) );
  x := nako_getFuncArg(h, 1);
  y := nako_getFuncArg(h, 2);
  s := nako_getFuncArg(h, 3);

  // (2) 省略時の補完
  if (x=nil)and(y=nil) then
  begin
    x := baseX;
    y := baseY;
  end;

  xx := hi_int(x);
  yy := hi_int(y);
  ss := hi_str(s); // ファイル名

  // (3) 処理
  bmp := LoadPic(string(ss));
  try
    c.Draw(xx, yy, bmp);
    hi_setInt(baseY, hi_int(baseY) + bmp.Height + 4);
  finally
    bmp.Free;
  end;
  // (4) 結果の代入
  if c.Handle = Bokan.BackCanvas.Handle then
  begin
    Bokan.flagRepaint := True;
  end;
  if Bokan.UseLineNo then
  begin
    Bokan.Redraw;
  end;
  Result := nil; // 何も返さない場合は nil
end;

function cmd_stop(h: DWORD): PHiValue; stdcall;
begin
  // (1) 引数の取得
  // (2) 処理
  nako_stop;
  InvalidateRect(Bokan.Handle, nil, True);

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_closeWindow(h: DWORD): PHiValue; stdcall;
begin
  // (1) 引数の取得
  // (2) 処理

  nako_stop;
  Bokan.Close;
  if Bokan.flagBokanSekkei then
  begin
    Halt; //とにかく終了
  end;

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_keyState(h: DWORD): PHiValue; stdcall;
var
  code : Integer;
  //ks   : TKeyboardState;
  b    : Boolean;
begin
  // (1) 引数の取得
  code := hi_int(nako_getFuncArg(h, 0));

  // (2) 処理
  b := (GetAsyncKeyState(code) <> 0);
  {
  GetKeyboardState(ks);
  if (code = CAPSLOCK_ON)or(code = NUMLOCK_ON)or(code = VK_SPACE) then
  begin
    b := (ks[code and $FF] > 0);
  end else
  begin
    b := ((ks[code and $FF] and $80) > 0);
  end;
  b := (ks[code and $FF] <> 0);
  }
  // (3) 結果の代入
  Result := hi_var_new; // 何も返さない場合は nil
  hi_setBool(Result, b);
end;

function cmd_sleep(h: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  w, endTime: DWORD;
begin
  // (1) 引数の取得
  p := nako_getFuncArg(h, 0);

  // (2) 処理
  endTime := timeGetTime + Trunc(1000 * hi_float(p));

  // repaint
  Application.ProcessMessages;
  if Bokan.flagRepaint then
  begin
    Bokan.flagRepaint := False;
    InvalidateRect(Bokan.Handle, nil, False);
    Bokan.Invalidate;
  end;
  // wait
  while True do
  begin
    if Bokan.flagClose then Break;
    Application.ProcessMessages;
    w := timeGetTime;
    if w > endTime then Break;
    sleep(10); // CPUパワー節約処理
  end;

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

//  AddFunc('フォント選択',    '',                    1400,@,   'フォントを選択してフォント名を返す。', 'ふぉんとせんたく');
//  AddFunc('色選択',          '',                    1402,@,  '色を選択して返す。', 'いろせんたく');
//  AddFunc('プリンタ設定',    '',                    1403,@,  'プリンタを設定する。', 'ぷりんたせってい');
//  AddFunc('メモ記入',        '{=?}Sの|Sと|Sを|Sで', 1404,@cmd_dlgMemo,   'エディタにSを表示し編集結果をを返す。', 'めもきにゅう');

function cmd_dlgFont(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  // (1) 引数の取得
  // (2) 処理
  if bokan.dlgFont.Execute then
  begin
    Result := hi_var_new;
    hi_setStr(Result,
      AnsiString(
        bokan.dlgFont.Font.Name + '|' +
        IntToStr(bokan.dlgFont.Font.Size) + '|' +
        string(fontStyleToStr(bokan.dlgFont.Font.Style))
      )
    );
  end;
end;

function cmd_dlgColor(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  // (1) 引数の取得
  // (2) 処理
  if bokan.dlgColor.Execute then
  begin
    Result := hi_var_new;
    hi_setInt(Result, RGB2Color(bokan.dlgColor.Color));
  end;
end;

function cmd_dlgPrint(h: DWORD): PHiValue; stdcall;
begin
  // (1) 引数の取得
  // (2) 処理
  Result := hi_newBool(bokan.dlgPrinter.Execute);
end;

function cmd_dlgMemo(h: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  f: TfrmMemo;
  init,cancel,ime, title: string;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;
  // (2) 処理
  f := TfrmMemo.Create(bokan);
  try
    f.edtMain.Lines.Text := string(hi_str(p));
    setDialogIME(f.edtMain.Handle);
    GetDialogSetting(title, init, cancel, ime);
    f.Caption := string(title);
    getFontDialog(f.edtMain.Font);
    ShowModalCheck(f, bokan);
    if f.Res then
      hi_setStrU(Result, (f.edtMain.Lines.Text))
    else
      hi_setStrU(Result, cancel);
  finally
    f.Free;
  end;
end;

procedure GetDialogSetting(var title: string; var init: string; var cancel: string; var ime: string);
begin
  title  := hi_strU(nako_getVariable('ダイアログタイトル'));
  init   := hi_strU(nako_getVariable('ダイアログ初期値'));
  cancel := hi_strU(nako_getVariable('ダイアログキャンセル値'));
  ime    := hi_strU(nako_getVariable('ダイアログIME'));
  //-----------------------------------
  {$IFDEF IS_LIBVNAKO}
  if title = '' then title := 'なでしこ';
  {$ELSE}
  if title = '' then title := (Application.Title);
  {$ENDIF}
end;

function getDialogS(ValueName: AnsiString; initValue: AnsiString): AnsiString; // ダイアログ詳細から値を取り出す
var
  p, pp: PHiValue;
begin
  p := nako_getVariable('ダイアログ詳細');
  if p = nil then Exit;
  pp := nako_hash_get(p, PAnsiChar(ValueName));
  if (pp = nil)or(pp.VType = varNil) then
  begin
    Result := initValue;
  end else
  begin
    Result := hi_str(pp);
  end;
end;

function cmd_dlgInput(h: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  f: TfrmInput;
  title, init, cancel, ime: string;
  res: AnsiString;
  limit: Integer;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;

  // (2) 処理
  f := TfrmInput.Create(bokan);
  try
    f.lblCaption.Caption := string(hi_str(p));

    GetDialogSetting(title, init, cancel, ime);
    setDialogIME(f.edtMain.Handle);
    f.edtMain.Text := string(init);
    f.Caption := string(title);
    limit := Trunc(1000 * hi_float(nako_getVariable('ダイアログ表示時間')));
    //
    getFontDialog(f.lblCaption.Font);
    getFontDialog(f.edtMain.Font);
    f.setLimitTimer(limit);
    f.edtMain.Top := f.lblCaption.Top + f.lblCaption.Height + 8;
    f.ClientHeight := f.edtMain.Top + f.edtMain.Height + 8 + f.Panel1.Height;

    if f.lblCaption.Width > f.Width then
    begin
      f.ClientWidth := f.lblCaption.Width + f.lblCaption.Left * 2;
      f.edtMain.Width := f.lblCaption.Width;
    end;

    ShowModalCheck(f, bokan);
    
    if f.Res then res := AnsiString(f.edtMain.Text)
             else res := AnsiString(cancel);

    if IsDialogConvNum then
    begin
      if IsNumber(AnsiString(res)) then begin
        hi_setFloat(Result, StrToFloatA(res));
      end else begin
        hi_setStr(Result, res);
      end;
    end else
    begin
      hi_setStr(Result, res);
    end;
  finally
    f.Free;
  end;
end;

function cmd_dlgInputNum(h: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  f: TfrmInputNum;
  title, init, cancel, ime: string;
  res: AnsiString;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;

  // (2) 処理
  f := TfrmInputNum.Create(bokan);
  try
    f.lblInfo.Caption := string(hi_str(p));

    GetDialogSetting(title, init, cancel, ime);
    //setDialogIME(f.edtMain.Handle);
    if init = '' then init := '0';
    f.edtMain.Text := string(init);
    f.Caption := string(title);
    ShowModalCheck(f, bokan);

    if f.Res then res := AnsiString(f.edtMain.Text)
             else res := AnsiString(cancel);

    if IsNumber(res) then hi_setFloat(Result, StrToFloatA(res))
                     else hi_setStr(Result, res);

  finally
    f.Free;
  end;
end;

function cmd_dlgInputDate(h: DWORD): PHiValue; stdcall;
var
  f: TfrmCalendar;
  title, init, cancel, ime, res: string;
begin
  // (1) 引数の取得
  // なし

  // (2) 処理
  f := TfrmCalendar.Create(bokan);
  try

    GetDialogSetting(title, init, cancel, ime);
    //setDialogIME(f.edtMain.Handle);
    if init <> '' then
    begin
      f.setInitValue(string(init));
    end;
    f.Caption := string(title);
    ShowModalCheck(f, bokan);

    if f.Res then res := (f.ResultStr)
             else res := cancel;

    Result := hi_newStr(AnsiString(res));
  finally
    f.Free;
  end;
end;


function cmd_dlgHukidasi(h: DWORD): PHiValue; stdcall;
var
  px,py,ps: PHiValue;
  f: TfrmHukidasi;

begin
  Result := hi_var_new;

  // (1) 引数の取得
  px := nako_getFuncArg(h, 0);
  py := nako_getFuncArg(h, 1);
  ps := nako_getFuncArg(h, 2);
  if ps = nil then ps := nako_getSore;

  // (2) 処理
  f := TfrmHukidasi.Create(bokan);
  try
    f.Left := hi_int(px);
    f.Top  := hi_int(py);
    getFont(bokan.Canvas);
    f.SetText(bokan.Canvas.Font, hi_strU(ps));
    // 擬似モーダル
    f.Show;
    while f.Res = False do
    begin
      Application.ProcessMessages;
      sleep(20);
    end;
    //---
  finally
    //自動解放
  end;
end;


function cmd_printEasy(h: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
  prn: System.Text;
  sl:TStringList;
  i: Integer;
begin
  Result := nil;
  ps := nako_getFuncArg(h, 0);
  if ps = nil then ps := nako_getSore;

  //
  sl := TStringList.Create ;
  try
    sl.Text := hi_strU(ps);
    if not bokan.dlgPrinter.Execute then Exit;
    AssignPrn(prn);
    try
      Rewrite(prn);
      for i:=0 to sl.Count-1 do
        Writeln(prn, sl.Strings[i]);
    finally
      closeFile(prn);
    end;
  finally
      sl.Free;
  end;
end;


// ビットマップ用印刷ルーチン by 中村の里 中村様(http://www.asahi-net.or.jp/~HA3T-NKMR/tips004.htm)
procedure StretchDrawBitmap(Canvas:TCanvas; r : TRect; Bitmap:TBitmap); // ビットマップ
var
  OldMode   : integer;     // StretchModeの保存用
  Info      : PBitmapInfo; // DIBヘッダ＋カラーテーブル
  InfoSize  : DWord;       // DIBヘッダ＋カラーテーブルのサイズ
  Image     : Pointer;     // DIBのピクセルデータ
  ImageSize : DWord;       // DIBのピクセルデータのサイズ
  dc        : HDC;         // GetDIBits 用 Device Context
  OldPal    : HPALETTE;    // パレット保存用
begin
  GetDIBSizes(Bitmap.Handle, InfoSize, ImageSize);
  Info:=nil;
  Image:=nil;
  try
    // 24 Bit DIB の領域を確保
    InfoSize := SizeOf(TBitmapInfoHeader) + 4 * 259;
    Info :=AllocMem(InfoSize);
    ImageSize := ((Bitmap.Width * 24 + 31) div 32) * 4 * Bitmap.Height;
    Image:=AllocMem(ImageSize);

    // DIB のBitmapInfoHeader を初期化
    with Info^.bmiHeader do begin
      biSize := SizeOf(TBitmapInfoHeader);
      biWidth := Bitmap.Width;
      biHeight := Bitmap.Height;
      biPlanes := 1;
      biBitCount := 24;
      biCompression := BI_RGB;
    end;

    dc := GetDC(0); // 変換用の DC を獲得
    try
      // ビットマップのパレットを選択
      OldPal := 0;
      if Bitmap.Palette <> 0 then
        OldPal := SelectPalette(dc, Bitmap.Palette, True);

      // 24 bit DIB を得る。
      GetDIBits(dc, Bitmap.Handle, 0, Bitmap.Height,
                Image, Info^, DIB_RGB_COLORS);
      // パレットを元に戻す。
      if OldPal <> 0 then SelectPalette(dc, OldPal, True);

      // 拡大モードを カラー用に変更
      OldMode:=SetStretchBltMode(Canvas.Handle,COLORONCOLOR);

      // 描画！！
      StretchDIBits(Canvas.Handle,
                    r.Left,r.Top,r.Right-r.Left,r.Bottom-r.Top,
                    0,0,Info^.bmiHeader.biWidth,Info^.bmiHeader.biHeight,
                    Image,Info^,DIB_RGB_COLORS,SRCCOPY);
      // 拡大モードを元に戻す
      SetStretchBltMode(Canvas.Handle,OldMode);

    // 後始末
    finally
      ReleaseDC(0, dc);
    end;
  finally
    if Info<>nil then FreeMem(Info);
    if Image<>nil then FreeMem(Image);
  end;
end;


function cmd_printEasyImage(h: DWORD): PHiValue; stdcall;
var
  bmp: TBitmap;
  rate: Extended;
  x,y: Integer;
  rect: TRect;
begin
  Result := nil;
  bmp := getBmp(nako_getFuncArg(h, 0));
  if not bokan.dlgPrinter.Execute then Exit;

  with Printer do
  begin
    x := bmp.Width ;
    y := bmp.Height ;

    if x > y then
    begin
        rate := bmp.Width / PageWidth;
    end else
    begin
        rate := bmp.Height / PageHeight;
    end;
    x := Trunc(bmp.Width / rate);
    y := Trunc(bmp.Height / rate);
    rect.Top := 0;
    rect.Left := 0;
    rect.Right := x-1;
    rect.Bottom := y-1;
    Printer.Title := bokan.Caption;
    Printer.BeginDoc  ;
    StretchDrawBitmap(Printer.Canvas, Rect, bmp);
    Printer.EndDoc;
  end;
end;

function cmd_printBokan(h: DWORD): PHiValue; stdcall;
var
  rate: Extended;
  x,y: Integer;
  dc : HDC;
  bmp: TBitmap;
  rect: TRect;
begin
  Result := nil;
  if not bokan.dlgPrinter.Execute then Exit;

  bmp := TBitmap.Create ;
  try
      bokan.BringToFront ;
      Application.ProcessMessages ;

      dc := GetWindowDC(bokan.Handle);
      bmp.Width := bokan.Width ;
      bmp.Height := bokan.Height ;
      with bokan do begin
        bitblt(bmp.Canvas.Handle, 0, 0, Width, Height, dc, 0,0, SRCCOPY);
      end;
      ReleaseDC(bokan.Handle, dc);
      with Printer do
      begin
          x := bokan.Width ;
          y := bokan.Height ;

          if x > y then
          begin
              rate := bokan.Width / PageWidth;
          end else
          begin
              rate := bokan.Height / PageHeight;
          end;
          x := Trunc(bokan.Width / rate);
          y := Trunc(bokan.Height / rate);
          rect.Top := 0;
          rect.Left := 0;
          rect.Right := x-1;
          rect.Bottom := y-1;
          Printer.Title := bokan.Caption;
          Printer.BeginDoc  ;
          StretchDrawBitmap(Printer.Canvas, Rect, bmp);
          Printer.EndDoc;
      end;
  finally
      bmp.Free;
  end;
end;

function cmd_printBeginDoc(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  Printer.Title := bokan.Caption;
  Printer.BeginDoc;
end;
function cmd_printEndDoc(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  Printer.EndDoc;
end;
function cmd_printPaperNewPage(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  Printer.NewPage;
end;


function cmd_printPaperWidth(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newInt(Printer.PageWidth);
end;
function cmd_printPaperHeight(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newInt(Printer.PageHeight);
end;
function cmd_printTextOut(h: DWORD): PHiValue; stdcall;
var ps,px,py: PHiValue;
begin
  ps := nako_getFuncArg(h,0); if ps = nil then ps := nako_getSore;
  px := nako_getFuncArg(h,1);
  py := nako_getFuncArg(h,2);
  getFont(Printer.Canvas);
  Printer.Canvas.TextOut(hi_int(px), hi_int(py), hi_strU(ps));
  Result := nil;
end;
function cmd_printGetCharWidth(h: DWORD): PHiValue; stdcall;
var ps: PHiValue;
begin
  ps := nako_getFuncArg(h,0); if ps = nil then ps := nako_getSore;
  getFont(Printer.Canvas);
  Result := hi_newInt(Printer.Canvas.TextWidth(hi_strU(ps)));
end;
function cmd_printGetCharHeight(h: DWORD): PHiValue; stdcall;
var ps: PHiValue;
begin
  ps := nako_getFuncArg(h,0); if ps = nil then ps := nako_getSore;
  getFont(Printer.Canvas);
  Result := hi_newInt(Printer.Canvas.TextHeight(hi_strU(ps)));
end;

function cmd_printImage(h: DWORD): PHiValue; stdcall;
var px,py: PHiValue; bmp: TBitmap;
begin
  bmp := getBmp(nako_getFuncArg(h,0));
  px := nako_getFuncArg(h,1);
  py := nako_getFuncArg(h,2);
  Result := nil;
  Printer.Canvas.Draw(hi_int(px), hi_int(py), bmp);
end;

function cmd_printImageEx(h: DWORD): PHiValue; stdcall;
var
  bmp: TBitmap;
  r: TRect;
begin
  bmp := getBmp(nako_getFuncArg(h,0));
  r.Left   := getArgInt(h, 1, False);
  r.Top    := getArgInt(h, 2, False);
  r.Right  := getArgInt(h, 3, False);
  r.Bottom := getArgInt(h, 4, False);

  Result := nil;
  StretchDrawBitmap(Printer.Canvas, r, bmp);
end;

function cmd_printLine(h: DWORD): PHiValue; stdcall;
var x1,y1,x2,y2: Integer;
begin
  x1 := hi_int(nako_getFuncArg(h,0));
  y1 := hi_int(nako_getFuncArg(h,1));
  x2 := hi_int(nako_getFuncArg(h,2));
  y2 := hi_int(nako_getFuncArg(h,3));
  Result := nil;
  getPenBrush(Printer.Canvas);
  Printer.Canvas.MoveTo(x1,y1);
  Printer.Canvas.LineTo(x2,y2);
end;



function cmd_dlgInputList(h: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  f: TfrmInputList;
  title, init, cancel, ime: string;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  p := nako_getFuncArg(h, 0);
  // (2) 処理
  f := TfrmInputList.Create(bokan);
  try
    getFontDialog(f.veList.Font);
    f.setProperty(hi_strU(p));
    GetDialogSetting(title, init, cancel, ime);
    f.Caption := string(title);
    ShowModalCheck(f, bokan);
    if f.Res then hi_setStr(Result, AnsiString(f.getResult));
  finally
    f.Free;
  end;
end;

function cmd_dlgPassword(h: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  f: TfrmPassword;
  title, init, cancel, ime: string;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;
  // (2) 処理
  f := TfrmPassword.Create(bokan);
  try
    f.lblCaption.Caption := hi_strU(p);
    GetDialogSetting(title, init, cancel, ime);
    f.Caption := string(title);
    ShowModalCheck(f, bokan);
    if f.Res then hi_setStrU(Result, (f.edtMain.Text))
             else hi_setStrU(Result, cancel);
  finally
    f.Free;
  end;
end;

function cmd_dlgButton(h: DWORD): PHiValue; stdcall;
var
  ps, pv: PHiValue;
  f: TfrmSelectButton;
  title, init, cancel, ime: string;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  ps := nako_getFuncArg(h, 0);
  pv := nako_getFuncArg(h, 1);
  if ps = nil then ps := nako_getSore;
  // (2) 処理
  f := TfrmSelectButton.Create(bokan);
  try
    GetDialogSetting(title, init, cancel, ime);
    f.MakeButton(hi_strU(ps), hi_strU(pv));
    f.Caption := string(title);
    ShowModalCheck(f, bokan);
    if not f.IsCancel then hi_setStrU(Result, (f.Result))
                      else hi_setStrU(Result, cancel);
  finally
    f.Free;
  end;
end;


function cmd_dlgSay(h: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
  f: TfrmSay;
  title, init, cancel, ime: string;
  limit: Integer;
begin
  Result := nil;

  // (1) 引数の取得
  ps := nako_getFuncArg(h, 0);
  if ps = nil then ps := nako_getSore;

  // (2) 処理
  f := TfrmSay.Create(bokan);
  try
    try
      f.Close;          
      GetDialogSetting(title, init, cancel, ime);
      limit := Trunc(1000*hi_float(nako_getVariable('ダイアログ表示時間')));
      //
      f.Caption := string(title);
      //-----------------------
      // 大きさの指定
      getFontDialog(f.FBmp.Canvas.Font);
      //-----------------------
      // テキストのセット
      f.SetProperty(hi_strU(ps));
      f.SetLimitTime(limit);
      // 表示
      ShowModalCheck(f, bokan);
    except
      on e: Exception do
        raise Exception.Create('【言う】でエラー。' + e.Message);
    end;
  finally
    f.Free;
  end;
end;

function cmd_nitaku(h: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  f: TfrmSay;
  msg, title, init, cancel, ime: string;
  limit: Integer;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;
  msg := hi_strU(p);

  // (2) 処理
  f := TfrmSay.Create(bokan);
  try
  try
    f.Close;
    f.UseNitaku;
    GetDialogSetting(title, init, cancel, ime);
    f.Caption := string(title);
    limit := Trunc(1000*hi_float(nako_getVariable('ダイアログ表示時間')));
    //-----------------------
    // 大きさの指定
    getFontDialog(f.FBmp.Canvas.Font);
    f.SetProperty(string(msg));
    f.SetLimitTime(limit);
    ShowModalCheck(f, bokan);
    Result := hi_newBool(f.Res);
  except on e: Exception do
    raise Exception.Create('【二択】でエラー。' + e.Message);
  end;
  finally
    f.Free;
  end;
end;


function cmd_dlgList(h: DWORD): PHiValue; stdcall;
var
  f: TfrmList;
  msg, title, init, cancel, ime: string;
begin
  // (1) 引数の取得
  msg := string(getArgStr(h, 0, True));
  Result := nil;

  // (2) 処理
  f := TfrmList.Create(bokan);
  try
  try
    GetDialogSetting(title, init, cancel, ime);
    f.Caption := string(title);
    getFontDialog(f.edtMain.Font);
    getFontDialog(f.lstItem.Font);
    f.lstItem.Items.Text := string(msg);
    f.DefList.Text := msg;
    ShowModalCheck(f, bokan);
    Result := hi_newStr(AnsiString(f.Res));
  except on e: Exception do
    raise Exception.Create('【リスト絞込み選択】でエラー。' + e.Message);
  end;
  finally
    f.Free;
  end;
end;


function cmd_nitaku_vista(h: DWORD): PHiValue; stdcall;
var
  q,s: AnsiString;
  res: Integer;
begin
  q := getArgStr(h, 0, True);
  s := getArgStr(h, 1);
  res := TaskDialog(frmNako, frmNako.Caption, string(q), string(s),
    TD_YES or TD_NO, TD_ICON_QUESTION);
  Result := hi_newBool(res = DLGRES_YES);
end;

function cmd_warning_vista(h: DWORD): PHiValue; stdcall;
var
  q,s: AnsiString;
begin
  q := getArgStr(h, 0, True);
  s := getArgStr(h, 1);
  TaskDialog(frmNako, frmNako.Caption, string(q), string(s), TD_OK, TD_ICON_WARNING);
  Result := nil;
end;

function cmd_okdialog_vista(h: DWORD): PHiValue; stdcall;
var
  q,s: AnsiString;
begin
  q := getArgStr(h, 0, True);
  s := getArgStr(h, 1);
  TaskDialog(frmNako, frmNako.Caption, string(q), string(s), TD_OK, TD_ICON_INFORMATION);
  Result := nil;
end;

function cmd_reflesh(h: DWORD): PHiValue; stdcall;
var
  con: TObject;
begin
  // (1) 引数の取得
  con := getGui(nako_getFuncArg(h, 0));
  if con <> nil then
  begin
    TControl(con).Invalidate;
  end;
  Application.ProcessMessages;
  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_redraw(h: DWORD): PHiValue; stdcall;
begin
  Bokan.Redraw;
  Result := nil; // 何も返さない場合は nil
end;

function cmd_debug(h: DWORD): PHiValue; stdcall;
begin
  // (1) 引数の取得
  // (2) 処理

  ShowModalCheck(frmDebug(bokan), bokan);

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_moveWindow(h: DWORD): PHiValue; stdcall;
var
  o: TObject;
  c: TControl;
  f: TfrmNako;
begin
  o := getGui(nako_getFuncArg(h, 0));
  if o is TfrmNako then
  begin
    f := TfrmNako(o);
    f.Left := (Screen.WorkAreaWidth  - f.Width ) div 2 + Screen.WorkAreaLeft ;
    f.Top  := (Screen.WorkAreaHeight - f.Height) div 2 + Screen.WorkAreaTop  ;
  end else
  if o is TControl then
  begin
    c := TControl(o);
    c.Left := (c.Parent.Width  - c.Width ) div 2;
    c.Top  := (c.Parent.Height - c.Height) div 2;
  end else
  begin
    raise Exception.Create('オブジェクトではないので中央に移動できません。');
  end;

  //戻り値
  Result := nil;
end;

function cmd_textout(h: DWORD): PHiValue; stdcall;
var
  c: TCanvas;
  x, y, hh, i: Integer;
  s: AnsiString;
  sl: TStringList;
begin
  // 引数
  c := getCanvas(nako_getFuncArg(h, 0));
  x := hi_int(nako_getFuncArg(h, 1));
  y := hi_int(nako_getFuncArg(h, 2));
  s := hi_str(nako_getFuncArg(h, 3));

  //
  getFont(c);

  //
  sl := TStringList.Create ;
  try
    sl.Text := string(ExpandTab(s, hi_int(tabCount)));
    hh := Trunc(c.TextHeight('あ') * 1.2);
    for i:=0 to sl.Count -1 do
    begin
      SuperTextOut(c, x, y+i*hh, c.Font, sl.Strings[i]);
    end;
  finally
    sl.Free;
  end;

  // 戻り
  Result := nil;
end;


procedure textout_delay(o: TObject; c: TCanvas; x, y: Integer; s: AnsiString;
  m: DWORD; FlagBlur: Boolean);
var
  hh, i, j, len, ax: Integer;
  ss, a, b: AnsiString;
  sl: TStringList;
  dEnd: DWORD;
begin
  // バグあり ---- Application.Processmessage でフォームの移動を行うとエラー
  getFont(c);
  //
  sl := TStringList.Create ;
  try
    sl.Text := string(ExpandTab(s, hi_int(tabCount)));
    hh := Trunc(c.TextHeight('あ') * 1.2);
    for i:=0 to sl.Count -1 do
    begin
      ss  := AnsiString(sl.Strings[i]);
      len := JLength(ss);
      for j := 1 to len do
      begin
        if Bokan.flagClose then Exit;
        try

          try
          a  := CopyA(ss, 1, j-1);
          b  := CopyA(ss, j, 1);
          ax := c.TextWidth(string(a));

          if not FlagBlur then
            c.TextOut(x + ax, y+i*hh, string(b))
          else
            SuperTextOut(c, x + ax, y+i*hh, c.Font, string(b));
          finally
          end;

          // redraw
          if o is TImage then
          begin
            TImage(o).Repaint;
          end else
          if o is TfrmNako then
          begin
            TfrmNako(o).Redraw;
          end;

          // wait
          dEnd := timeGetTime + DWORD(m);
          while timeGetTime < dEnd do
          begin
            //Application.ProcessMessages;
            sleep(100); // CPU使用率を下げる
          end;
        except
        end;
      end;
    end;
  finally
    sl.Free;
  end;

  // 戻り
end;

var flag_define_str_function: Byte = 0;

procedure define_str_function;
var
  s: AnsiString;
begin
  if flag_define_str_function <> 0 then Exit;
  flag_define_str_function := 1;
  // ---
  s := '文字遅延表示用定義をナデシコする。';
  nako_eval_str(s);
  //
  // --- --- --- ---
  // おまけ
  nako_eval_str('_感謝は～「IPAの皆様、(株)びぎねっとの宮原さん'#13#10+
  'とこちゃん、SWinXさん、EZNaviさん'#13#10+
  '応援してくださる多くの方々に感謝します。」と言う。');
end;


function cmd_textoutDelay(h: DWORD): PHiValue; stdcall;
var
  //o: TObject;
  //c: TCanvas;
  x, y, m: Integer;
  s, name: AnsiString;
begin
  // 引数
  // o := getGui(nako_getFuncArg(h, 0)); // object
  // c := getCanvasFromObj(o);           // canvas
  name := getGuiName(nako_getFuncArg(h, 0));
  x := hi_int(nako_getFuncArg(h, 1));
  y := hi_int(nako_getFuncArg(h, 2));
  s := hi_str(nako_getFuncArg(h, 3));
  m := hi_int(nako_getFuncArg(h, 4));
  // textout_delay(o, c, x, y, s, m, True); // バグあり
  Result := nil;
  //
  define_str_function;
  s := JReplaceA(s, '`', '‘');
  nako_eval_str(
    AnsiString(format('0して%sの%d,%dへ`%s`を%dでSYS_文字遅延描画処理',
      [name, x, y, s, m]))
  );
end;

function cmd_textoutDelayNoneAlias(h: DWORD): PHiValue; stdcall;
var
//  o: TObject;
//  c: TCanvas;
  x, y, m: Integer;
  s, name: AnsiString;
begin
  // 引数
  //o := getGui(nako_getFuncArg(h, 0)); // object
  //c := getCanvasFromObj(o);           // canvas
  name := getGuiName(nako_getFuncArg(h, 0));
  x := hi_int(nako_getFuncArg(h, 1));
  y := hi_int(nako_getFuncArg(h, 2));
  s := hi_str(nako_getFuncArg(h, 3));
  m := hi_int(nako_getFuncArg(h, 4));
  //
  Result := nil;
  // textout_delay(o, c, x, y, s, m, False);
  //
  define_str_function;
  s := JReplaceA(s, '`', '‘');
  nako_eval_str(
    FormatA('1して%sの%d,%dへ`%s`を%dでSYS_文字遅延描画処理',
      [name, x, y, s, m])
  );
end;


function cmd_textout2(h: DWORD): PHiValue; stdcall;
var
  c: TCanvas;
  x, y: Integer;
  s: AnsiString;
  r: TRect;
begin
  // 引数
  c := getCanvas(nako_getFuncArg(h, 0));
  x := hi_int(nako_getFuncArg(h, 1));
  y := hi_int(nako_getFuncArg(h, 2));
  s := hi_str(nako_getFuncArg(h, 3));

  //
  getFont(c);
  r := c.ClipRect;
  r.Left := x;
  r.Top := y;
  //c.TextOut(x,y,s);

  DrawTextExA(c.Handle, PAnsiChar(s), -1, r, DT_HIDEPREFIX or DT_NOCLIP, nil);

  // 戻り
  Result := nil;
end;

function cmd_mosaic(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  i: Integer;
  r: TRect;
begin
  // 引数
  b := getBmp(nako_getFuncArg(h, 0));
  i := hi_int(nako_getFuncArg(h, 1));
  // 処理
  r.Left := 0;
  r.Top  := 0;
  r.Right := b.Width;
  r.Bottom := b.Height;
  //
  try
    Mozaic(b, i, i, r);
  except end;
  // 戻り
  Result := nil;
end;

// なでしこの画像にぼかし効果をかける命令「画像ボカシ」の実装部分
function cmd_blur(h: DWORD): PHiValue; stdcall;
var // 変数宣言
  bmp : TBitmap; // ビットマップ型
  i   : Integer; // 整数型
begin
  // (1) なでしこのシステムから引数を取得する
  bmp := getBmp(nako_getFuncArg(h, 0)); // フィルターをかける対象
  i   := hi_int(nako_getFuncArg(h, 1)); // どの程度の強さでかけるのか
  // (2) ボカシ効果のフィルターをかける ... エラーが出ても無視する
  try
    BiLe2(i, bmp);
  except
  end;
  // (3) 戻り値はないので命令の結果として nil を返す
  Result := nil;
end;

function cmd_sharp(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  i: Integer;
begin
  // 引数
  b := getBmp(nako_getFuncArg(h, 0));
  i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    Laplacian(i, b);
  except end;
  // 戻り
  Result := nil;
end;

function cmd_negaposi(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
begin
  // 引数
  b := getBmp(nako_getFuncArg(h, 0));
  //
  try
    Nega(b);
  except end;
  // 戻り
  Result := nil;
end;

function cmd_mono(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  i: Integer;
begin
  // 引数
  b := getBmp(nako_getFuncArg(h, 0));
  i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    Mono(i, b);
  except end;
  // 戻り
  Result := nil;
end;

function cmd_solarization(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  //i: Integer;
begin
  // 引数
  b := getBmp(nako_getFuncArg(h, 0));
  //i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    Solarization(b);
  except end;
  // 戻り
  Result := nil;
end;

function cmd_sepia(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  i: Integer;
begin
  // 引数
  b := getBmp(nako_getFuncArg(h, 0));
  i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    SepiaSuper(b, GetRValue(i), GetGValue(i), GetBValue(i));
  except end;
  // 戻り
  Result := nil;
end;

function cmd_pic90r(h: DWORD): PHiValue; stdcall;
var
  bmp: TBitmap;
  obj: TObject;
  o: PHiValue;
begin
  // 引数
  o := nako_getFuncArg(h, 0);
  bmp := getBmp(o);
  obj := getGui(o);
  //
  try
    Rotate90(bmp,True);
  except end;
  //
  if obj is TImage then
  begin
    TImage(obj).Width  := bmp.Width;
    TImage(obj).Height := bmp.Height;
  end;
  // 戻り
  Result := nil;
end;

function cmd_pic90l(h: DWORD): PHiValue; stdcall;
var
  bmp: TBitmap;
  obj: TObject;
  o: PHiValue;
begin
  // 引数
  o := nako_getFuncArg(h, 0);
  bmp := getBmp(o);
  obj := getGui(o);
  //
  try
    Rotate90(bmp,False);
  except end;
  //
  if obj is TImage then
  begin
    TImage(obj).Width  := bmp.Width;
    TImage(obj).Height := bmp.Height;
  end;
  // 戻り
  Result := nil;
end;

function cmd_picRotate(handle: DWORD): PHiValue; stdcall;
var
  bmp: TBitmap;
  obj: TObject;
  o  : PHiValue;
  a  : Integer;
begin
  // 引数
  o   := nako_getFuncArg(handle, 0);
  bmp := getBmp(o);
  obj := getGui(o);
  a   := getArgInt(handle, 1);
  //
  if obj is TImage then
  begin
    try
      Rotate(bmp, a);
    except
    end;
  end;
  //
  TImage(obj).Width  := bmp.Width;
  TImage(obj).Height := bmp.Height;
  // 戻り
  Result := nil;
end;

function cmd_picRotateFast(handle: DWORD): PHiValue; stdcall;
var
  bmp: TBitmap;
  obj: TObject;
  o  : PHiValue;
  a  : Integer;
begin
  // 引数
  o   := nako_getFuncArg(handle, 0);
  bmp := getBmp(o);
  obj := getGui(o);
  a   := getArgInt(handle, 1);
  //
  if obj is TImage then
  begin
    try
      RotateFast(bmp, a);
    except
    end;
  end;
  //
  TImage(obj).Width  := bmp.Width;
  TImage(obj).Height := bmp.Height;
  // 戻り
  Result := nil;
end;

function cmd_VertRev(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  //i: Integer;
begin
  // 引数
  b := getBmp(nako_getFuncArg(h, 0));
  //i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    VertReverse(b);
  except end;
  // 戻り
  Result := nil;
end;
function cmd_HorzRev(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  //i: Integer;
begin
  // 引数
  b := getBmp(nako_getFuncArg(h, 0));
  //i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    HorzReverse(b);
  except end;
  // 戻り
  Result := nil;
end;

function cmd_Resize(h: DWORD): PHiValue; stdcall;
var
  bmp: TBitmap;
  obj: TObject;
  o: PHiValue;
  a, b: Integer;
begin
  // 引数
  o := nako_getFuncArg(h, 0);
  a := hi_int(nako_getFuncArg(h, 1));
  b := hi_int(nako_getFuncArg(h, 2));
  //
  bmp := getBmp(o);
  obj := getGui(o);
  //
  try
    nstretchf.Stretch(bmp, a, b, nil);
  except end;
  //
  if obj is TImage then
  begin
    TImage(obj).Width  := bmp.Width;
    TImage(obj).Height := bmp.Height;
    TImage(obj).Picture.Assign(bmp);
  end;
  // 戻り
  Result := nil;
end;

function cmd_ResizeAspect(h: DWORD): PHiValue; stdcall;
var
  bmp: TBitmap;
  obj: TObject;
  o: PHiValue;
  a, b: Integer;
begin
  // 引数
  o := nako_getFuncArg(h, 0);
  a := hi_int(nako_getFuncArg(h, 1));
  b := hi_int(nako_getFuncArg(h, 2));
  //
  bmp := getBmp(o);
  obj := getGui(o);
  //
  try
    nstretchf.StretchAspect2(bmp, a, b, nil);
  except end;
  //
  if obj is TImage then
  begin
    TImage(obj).Width  := bmp.Width;
    TImage(obj).Height := bmp.Height;
    TImage(obj).Picture.Assign(bmp);
  end;
  // 戻り
  Result := nil;
end;


function cmd_ResizeAspectEx(h: DWORD): PHiValue; stdcall;
var
  bmp: TBitmap;
  obj: TObject;
  o: PHiValue;
  a, b: Integer;
begin
  // 引数
  o := nako_getFuncArg(h, 0);
  a := hi_int(nako_getFuncArg(h, 1));
  b := hi_int(nako_getFuncArg(h, 2));
  //
  bmp := getBmp(o);
  obj := getGui(o);
  //
  try
    nstretchf.StretchAspect3(bmp, a, b, nil, RGB2Color(hi_int(brushColor)));
  except end;
  //
  if obj is TImage then
  begin
    TImage(obj).Width  := bmp.Width;
    TImage(obj).Height := bmp.Height;
    TImage(obj).Picture.Assign(bmp);
  end;
  // 戻り
  Result := nil;
end;

function cmd_img_bit(h: DWORD): PHiValue; stdcall;
var
    o: PHiValue;
  gra: TBitmap;
    a: Integer;
begin
  // 引数
  o := nako_getFuncArg(h, 0);
  a := hi_int(nako_getFuncArg(h, 1));
  //
  gra := getBmp(o);
  case a of //1/4/8/15/1624/32
    32: gra.PixelFormat := pf32bit;
    24: gra.PixelFormat := pf24bit;
    16: gra.PixelFormat := pf16bit;
    15: gra.PixelFormat := pf15bit;
     8: gra.PixelFormat := pf8bit;
     4: gra.PixelFormat := pf4bit;
     1: gra.PixelFormat := pf1bit;
  end;
  // 戻り
  Result := nil;
end;

function cmd_ResizeSpeed(h: DWORD): PHiValue; stdcall;
var
  bmp: TBitmap;
  obj: TObject;
  o: PHiValue;
  a, b: Integer;
begin
  // 引数
  o := nako_getFuncArg(h, 0);
  a := hi_int(nako_getFuncArg(h, 1));
  b := hi_int(nako_getFuncArg(h, 2));
  //
  bmp := getBmp(o);
  obj := getGui(o);
  //
  try
    nstretchf.StretchAspectSpeed(bmp, a, b, nil);
  except end;
  //
  if obj is TImage then
  begin
    TImage(obj).Width  := bmp.Width;
    TImage(obj).Height := bmp.Height;
    TImage(obj).Picture.Assign(bmp);
  end;
  // 戻り
  Result := nil;
end;

function cmd_img_save(h: DWORD): PHiValue; stdcall;
var
  gra: TBitmap;
    s: AnsiString;
begin
  // 引数
  gra := getBmp(nako_getFuncArg(h, 0));
  s   := hi_str(nako_getFuncArg(h, 1));
  //
  try
    SavePic(gra, string(s));
  except on e: Exception do
    raise Exception.Create('"' + string(s) + '"への保存に失敗。' + e.Message);
  end;
  // 戻り
  Result := nil;
end;

function cmd_img_alphaCopy(h: DWORD): PHiValue; stdcall;
var
  obj1, obj2: TBitmap;
  px,py,pa: PHiValue;
  x, y, a: Integer;
  abmp: TABitmap;
begin
  // {グループ}OBJ1を{グループ}OBJ2のX,YへAで
  // 引数
  obj1 := getBmp(nako_getFuncArg(h, 0)); {srcを}
  obj2 := getBmp(nako_getFuncArg(h, 1)); {desに}
  px   := nako_getFuncArg(h, 2);
  py   := nako_getFuncArg(h, 3);
  pa   := nako_getFuncArg(h, 4);

  x := hi_int(px);
  y := hi_int(py);
  a := hi_int(pa);

  // (元)amp から (ソース)xxx へ
  abmp := TABitmap.Create;
  try
    abmp.Assign(obj1);
    abmp.ColorAlpha(x, y, obj1.Width, obj1.Height, obj2, Trunc(a/100*256));
  finally
    abmp.Free;
  end;
  // 戻り
  Result := nil;
end;

function cmd_img_mask(h: DWORD): PHiValue; stdcall;
var
  obj: TBitmap;
  pc: PHiValue;
  abmp: TABitmap;
begin
  // {グループ}OBJ1を{グループ}OBJ2のX,YへAで
  // 引数
  obj := getBmp(nako_getFuncArg(h, 0));
  pc  := nako_getFuncArg(h, 1);

  abmp := TABitmap.Create;
  abmp.Assign(obj);
  abmp.Mask(RGB2Color(hi_int(pc)));
  obj.Assign(abmp);

  // 戻り
  Result := nil;
end;

function cmd_getFonts(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr( AnsiString(Screen.Fonts.Text) );
end;

function cmd_img_copy(h: DWORD): PHiValue; stdcall;
var
  obj1: TBitmap; p1, p2: PHiValue;
  obj2: TCanvas;
  x, y: Integer;
begin
  // 引数
  p1 := nako_getFuncArg(h, 0);
  p2 := nako_getFuncArg(h, 1);
  x  := hi_int(nako_getFuncArg(h, 2));
  y  := hi_int(nako_getFuncArg(h, 3));
  // 変換
  obj1 := getBmp(p1);
  obj2 := getCanvas(p2);
  // コピー
  obj2.Draw(x, y, obj1);
  //
  //Bokan.flagRepaint := True;
  //Bokan.flagRepaint := True;
  {
  BitBlt(obj2.Handle, x, y, obj1.Width, obj1.Height,
    obj1.Canvas.Handle, 0, 0, SRCCOPY);
  //
  obj2.Refresh;
  InvalidateRect(obj2.Handle, nil, True);
  }
  // 戻り
  Result := nil;
end;

function cmd_img_copyAnd(h: DWORD): PHiValue; stdcall;
var
  obj1: TBitmap; p1, p2: PHiValue;
  obj2: TCanvas;
  x, y: Integer;
begin
  // 引数
  p1 := nako_getFuncArg(h, 0);
  p2 := nako_getFuncArg(h, 1);
  x  := hi_int(nako_getFuncArg(h, 2));
  y  := hi_int(nako_getFuncArg(h, 3));
  // 変換
  obj1 := getBmp(p1);
  obj2 := getCanvas(p2);
  obj1.PixelFormat := pf24bit;
  // コピー
  BitBlt(obj2.Handle, x, y, obj1.Width, obj1.Height,
    obj1.Canvas.Handle, 0, 0, SRCAND);

  // 戻り
  Result := nil;
end;

function cmd_img_copyOr(h: DWORD): PHiValue; stdcall;
var
  obj1: TBitmap; p1, p2: PHiValue;
  obj2: TCanvas;
  x, y: Integer;
begin
  // 引数
  p1 := nako_getFuncArg(h, 0);
  p2 := nako_getFuncArg(h, 1);
  x  := hi_int(nako_getFuncArg(h, 2));
  y  := hi_int(nako_getFuncArg(h, 3));
  // 変換
  obj1 := getBmp(p1);
  obj2 := getCanvas(p2);
  obj1.PixelFormat := pf24bit;
  // コピー
  BitBlt(obj2.Handle, x, y, obj1.Width, obj1.Height,
    obj1.Canvas.Handle, 0, 0, SRCPAINT);

  // 戻り
  Result := nil;
end;

function cmd_img_copyXOR(h: DWORD): PHiValue; stdcall;
var
  obj1: TBitmap; p1, p2: PHiValue;
  obj2: TCanvas;
  x, y: Integer;
begin
  // 引数
  p1 := nako_getFuncArg(h, 0);
  p2 := nako_getFuncArg(h, 1);
  x  := hi_int(nako_getFuncArg(h, 2));
  y  := hi_int(nako_getFuncArg(h, 3));
  // 変換
  obj1 := getBmp(p1);
  obj2 := getCanvas(p2);
  // コピー
  BitBlt(obj2.Handle, x, y, obj1.Width, obj1.Height,
    obj1.Canvas.Handle, 0, 0, SRCINVERT);

  // 戻り
  Result := nil;
end;

function cmd_img_getC(h: DWORD): PHiValue; stdcall;
var
  obj: TCanvas;
  x, y: Integer;
begin
  // 引数
  obj := getCanvas(nako_getFuncArg(h,0));
  x   := hi_int(nako_getFuncArg(h,1));
  y   := hi_int(nako_getFuncArg(h,2));
  // 戻り
  Result := hi_newInt(Color2RGB( obj.Pixels[x, y] ));
end;

function cmd_img_change(h: DWORD): PHiValue; stdcall;
var
  obj: TBitmap;
  a, b: Integer;
begin
  // 引数
  obj := getBmp(nako_getFuncArg(h,0));
  a   := hi_int(nako_getFuncArg(h,1)); a := RGB2Color(a);
  b   := hi_int(nako_getFuncArg(h,2)); b := RGB2Color(b);
  // 処理
  BmpColorChange(obj, a, b);

  // 戻り
  Result := nil;
end;

function cmd_img_linePic(h: DWORD): PHiValue; stdcall;
var
  obj: TBitmap;
begin
  // 引数
  obj := getBmp(nako_getFuncArg(h,0));
  // 処理
  LinePic(obj);
  // 戻り
  Result := nil;
end;

function cmd_img_edge(h: DWORD): PHiValue; stdcall;
var
  obj: TBitmap;
begin
  // 引数
  obj := getBmp(nako_getFuncArg(h,0));
  // 処理
  edge(obj);
  // 戻り
  Result := nil;
end;

function cmd_img_gousei(h: DWORD): PHiValue; stdcall;
var
  obj1, obj2, mask: TBitmap;
  x, y: Integer;
begin
  // 引数
  obj1 := getBmp(nako_getFuncArg(h,0));
  obj2 := getBmp(nako_getFuncArg(h,1));
  x    := hi_int(nako_getFuncArg(h,2));
  y    := hi_int(nako_getFuncArg(h,3));

  // 処理
  mask := TBitmap.Create;
  try
    mask.Assign(obj1);
    mask.Mask(mask.Canvas.Pixels[0,0]);

    // MASK 合成
    BitBlt(obj2.Canvas.Handle, x, y, mask.Width, mask.Height,
      mask.Canvas.Handle, 0, 0, SRCAND);

    // 画像合成
    BitBlt(obj2.Canvas.Handle, x, y, mask.Width, mask.Height,
      obj1.Canvas.Handle, 0, 0, SRCPAINT);
  finally
    mask.Free;
  end;
  // 戻り
  Result := nil;
end;

function cmd_img_copyEx(h: DWORD): PHiValue; stdcall;
var
  p1, p2: PHiValue;
  obj1, obj2: TCanvas;
  x, y, ww, hh, dx, dy: Integer;
begin
  // 引数
  p1 := nako_getFuncArg(h, 0);
  x  := hi_int(nako_getFuncArg(h, 1));
  y  := hi_int(nako_getFuncArg(h, 2));
  ww := hi_int(nako_getFuncArg(h, 3));
  hh := hi_int(nako_getFuncArg(h, 4));
  p2 := nako_getFuncArg(h, 5);
  dx := hi_int(nako_getFuncArg(h, 6));
  dy := hi_int(nako_getFuncArg(h, 7));
  // 変換
  obj1 := getCanvas(p1);
  obj2 := getCanvas(p2);
  // コピー
  BitBlt(obj2.Handle, dx, dy, ww, hh, obj1.Handle, x, y, SRCCOPY);

  // 戻り
  Result := nil;
end;

function cmd_grayscale(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  //i: Integer;
begin
  // 引数
  b := getBmp(nako_getFuncArg(h, 0));
  //i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    Grayscale(b);
  except end;
  // 戻り
  Result := nil;
end;

function cmd_gamma(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  i: Double;
begin
  // 引数
  b := getBmp  (nako_getFuncArg(h, 0));
  i := hi_float(nako_getFuncArg(h, 1));
  //
  try
    Gamma(b, i);
  except end;
  // 戻り
  Result := nil;
end;

function cmd_contrast(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  i: Integer;
begin
  // 引数
  b := getBmp(nako_getFuncArg(h, 0));
  i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    Contrast(i, b);
  except end;
  // 戻り
  Result := nil;
end;

function cmd_bright(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  i: Integer;
begin
  // 引数
  b := getBmp(nako_getFuncArg(h, 0));
  i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    Bright(b, i);
  except end;
  // 戻り
  Result := nil;
end;

function cmd_noise(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  i: Integer;
begin
  // 引数
  b := getBmp(nako_getFuncArg(h, 0));
  i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    Noise(b, i mod 256);
  except end;
  // 戻り
  Result := nil;
end;

function vcl_free(h: DWORD): PHiValue; stdcall;
var
  g, v: PHiValue;
  obj: TObject;
begin
  Result := nil;
  g := nako_getFuncArg(h, 0); // group
  v := nako_group_findMember(g, 'オブジェクト');
  obj := TObject(Integer(hi_int(v)));
  if obj = nil then Exit;
  try
    nako_var_free(g);
    if obj is TTimer then
    begin
      TTimer(obj).Enabled := False;
    end else
    if obj is TControl then
    begin
      try
        TControl(obj).Visible := False; // 後でこっそり解放する
      except
        obj := nil;
      end;
    end;
  except
    raise;
  end;
  if obj <> nil then bokan.freeObjList.Add(obj);
end;

function vcl_setDefaultParentObj(h: DWORD): PHiValue; stdcall;
var
  defp: PHiValue;
begin
  defp := nako_getFuncArg(h, 0);
  if defp.VType <> varGroup then
  begin
    parentObj := Bokan;
  end else
  begin
    parentObj := getGui(defp) as TComponent;
    // BUG (@303) 親部品にタブページが指定された時の対処
    if parentObj.ClassNameIs('TPageControl') then
    begin
      if TPageControl(parentObj).PageCount > 0 then
      begin
        parentObj := TPageControl(parentObj).ActivePage;
      end;
    end;
  end;
  Result := nil;
end;

function vcl_create(h: DWORD): PHiValue; stdcall;
var
  n,t: PHiValue;
  o: TComponent;
  oType: Integer;
  oName: AnsiString;
  fontsize: Integer;
  fontname: string;
  i: Integer;
  defp: PHiValue;
begin
  // (1) 引数の取得
  // g := nako_getFuncArg(h, 0); // group
  n := nako_getFuncArg(h, 1); // name
  t := nako_getFuncArg(h, 2); // gui type

  oName := hi_str(n);
  oType := hi_int(t);

  getFont(bokan.Canvas);
  fontname := bokan.Canvas.Font.Name;
  fontsize := bokan.Canvas.Font.Size;

  if parentObj = nil then parentObj := Bokan;

  // (2) 処理
  //todo: VCL_CREATE
  case oType of
    VCL_GUI_BUTTON:
      begin
        o := TButton.Create(parentObj);
        with TButton(o) do begin
          OnClick := Bokan.eventClick;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_BIT_BUTTON:
      begin
        o := TBitBtn.Create(parentObj);
        with TBitBtn(o) do begin
          OnClick := Bokan.eventClick;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_PIC_BUTTON:
      begin
        o := TSpeedButton.Create(parentObj);
        with TSpeedButton(o) do begin
          OnClick := Bokan.eventClick;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_EDIT        :
      begin
        o := TEditXP.Create(parentObj);
        with TEditXP(o) do begin
          OnClick     := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnChange    := Bokan.eventChange;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_MEMO        :
      begin
        o := TMemoXP.Create(parentObj);
        with TMemoXP(o) do begin
          ScrollBars := ssBoth;
          OnClick     := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnChange    := Bokan.eventChange;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_LIST        :
      begin
        o := TListBox.Create(parentObj);
        with TListBox(o) do begin
          OnClick     := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Style := lbOwnerDrawFixed;
          ItemHeight  := 14;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_COMBO       :
      begin
        o := TComboBox.Create(parentObj);
        with TComboBox(o) do begin
          AutoComplete := False;
          OnClick     := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnChange    := Bokan.eventChange;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          OnDropDown  := Bokan.eventListOpen;
          OnCloseUp   := Bokan.eventListClose;
          OnSelect    := Bokan.eventListSelect;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_BAR         :
      begin
        o := TScrollBar.Create(parentObj);
        with TScrollBar(o) do begin
          OnChange    := Bokan.eventChange;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
        end;
      end;
    VCL_GUI_PROGRESS    :
      begin
        o := TProgressBar.Create(parentObj);
        with TProgressBar(o) do begin
          OnMouseDown   := Bokan.eventMouseDown;
          OnMouseMove   := Bokan.eventMouseMove;
          OnMouseUp     := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
        end;
      end;
    VCL_GUI_PANEL       :
      begin
        o := TNakoPanel.Create(parentObj);
        with TNakoPanel(o) do begin
          OnClick     := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnResize    := Bokan.eventSizeChange;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
        end;
      end;
    VCL_GUI_GROUPBOX    :
      begin
        o := TGroupBox.Create(parentObj);
        with TGroupBox(o) do begin
          OnClick     := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
        end;
      end;
    VCL_GUI_SCROLL_PANEL :
      begin
        o := TScrollBox.Create(parentObj);
        with TScrollBox(o) do begin
          OnClick   := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnResize  := Bokan.eventSizeChange;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnMouseWheel:= Bokan.eventMouseWheel;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
        end;
      end;
    VCL_GUI_CHECK       :
      begin
        o := TCheckBox.Create(parentObj);
        with TCheckBox(o) do begin
          OnClick     := Bokan.eventClick;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_RADIO       :
      begin
        o := TRadioGroup.Create(parentObj);
        with TRadioGroup(o) do begin
          OnClick   := Bokan.eventClick;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_RADIOGROUP:
      begin
        o := TRadioGroup.Create(parentObj);
        with TRadioGroup(o) do begin
          OnClick   := Bokan.eventClick;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_GRID        :
      begin
        o := TStrSortGrid.Create(parentObj);
        with TStrSortGrid(o) do begin
          FixedCols := 0;
          DefaultColWidth := 32;
          DefaultRowHeight := Trunc(Bokan.Canvas.TextHeight('Z') * 1.5);
          Options := [goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,goColSizing,goRowSelect];
          OnClick := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
          SortOps := soNon;
        end;
      end;
    VCL_GUI_IMAGE       :
      begin
        o := TNakoImage.Create(parentObj);
        with TNakoImage(o) do begin
          OnClick     := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
        end;
      end;
    VCL_GUI_ANIME:
      begin
        o := TAnimeBox.Create(parentObj);
        with TAnimeBox(o) do begin
          OnClick     := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
        end;
      end;
    VCL_GUI_LABEL       :
      begin
        o := TLabel.Create(parentObj);
        with TLabel(o) do begin
          AutoSize := False;
          Transparent := True;
          OnClick := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_TABPAGE     :
      begin
        o := TPageControl.Create(parentObj);
        with TPageControl(o) do begin
          OnChange    := Bokan.eventChange;
          OnResize    := Bokan.eventSizeChange;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
        end;
      end;
    VCL_GUI_CALENDER    :
      begin
        o := TMonthCalendar.Create(parentObj);
        with TMonthCalendar(o) do begin
          OnClick     := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
        end;
      end;
    VCL_GUI_TREEVIEW    :
      begin
        o := THiTreeView.Create(parentObj);
        with THiTreeView(o) do begin
          ReadOnly := True;
          OnClick     := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnChange    := Bokan.eventTreeViewChange;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          Canvas.Font.Name := fontname;
          Canvas.Font.Size := fontsize;
        end;
      end;
    VCL_GUI_LISTVIEW    :
      begin
        o := THiListView.Create(parentObj);
        with THiListView(o) do begin
          MultiSelect := False;
          ReadOnly := True;
          OnClick := Bokan.eventClick;
          OnDblClick := Bokan.eventDblClick;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_STATUSBAR   :
      begin
        o := TStatusBar.Create(parentObj);
        with TStatusBar(o) do begin
          SimplePanel := True;
          OnClick := Bokan.eventClick;
          OnDblClick := Bokan.eventDblClick;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_TOOLBAR     :
      begin
        o := TToolBar.Create(parentObj);
        with TToolBar(o) do begin
          Flat := True;
          Transparent := False;
          Color := clBtnFace;
          OnClick := Bokan.eventClick;
          OnDblClick := Bokan.eventDblClick;
          OnResize    := Bokan.eventSizeChange;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_WEBBROWSER  :
      begin
        o := TUIWebBrowser.Create(parentObj);
        with TUIWebBrowser(o) do begin
          OnBeforeNavigate2 := Bokan.eventBrowserNavigate;
          OnNavigateComplete2 := Bokan.eventNavigateComplete;
          OnDocumentComplete := Bokan.eventBrowserDocumentComplete;
          OnNewWindow2 := Bokan.eventBrowserNewWindow2;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
        end;
      end;
    VCL_GUI_SPINEDIT    :
      begin
        o := TSpinEdit.Create(parentObj);
        with TSpinEdit(o) do begin
          OnClick     := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnChange    := Bokan.eventChange;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_TRACKBOX    :
      begin
        o := TTrackBox.Create(parentObj);
        with TTrackBox(o) do begin
          OnClick     := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnTrackChange := Bokan.eventChangeTrackBox;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
        end;
      end;
    VCL_GUI_TEDITOR     :
      begin
        o := THiEditor.Create(parentObj);
        if Bokan.edtPropNormal = nil then
        begin
          Bokan.edtPropNormal := TEditorExProp.Create(Bokan);
          Bokan.edtPropNormal.ScrollBars := ssBoth;
        end;
        Bokan.edtPropNormal.Assign(o);
        THiEditor(o).Fountain := TNadesikoFountain.Create(Bokan);
        with THiEditor(o) do begin
          ExMarks.TabMark.Visible := True;
          ExMarks.TabMark.Color   := clGray;
          Leftbar.Visible := True;
          Leftbar.Column := 3;
          Caret.FreeCaret := False;
          Ruler.Visible := True;
          Ruler.GaugeRange := 10;
          ScrollBars := ssBoth;
          //------------------------------------------------
          // ユーザーの要望によりショートカットキーの強制変更
          for i := 0 to PopupMenu.Items.Count - 1 do
          begin
            if PopupMenu.Items.Items[i].Caption = 'やり直し(&R)' then
            begin
              PopupMenu.Items.Items[i].ShortCut := TextToShortCut('Ctrl+Y');
            end else
            if PopupMenu.Items.Items[i].Caption = 'すべて選択(&A)' then
            begin
              PopupMenu.Items.Items[i].ShortCut := TextToShortCut('Ctrl+A');
            end;
          end;
          //------------------------------------------------

          OnClick     := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnChange    := Bokan.eventChange;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          OnMouseWheel := Bokan.eventMouseWheel;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_PROPEDIT    :
      begin
        o := TValueListEditor.Create(parentObj);
        with TValueListEditor(o) do begin
          OnClick    := Bokan.eventClick;
          OnDblClick := Bokan.eventDblClick;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_FORM        :
      begin
        o := TfrmNako.Create(nil);
        with TfrmNako(o) do begin
          OnClick       := eventClick;
          OnDblClick    := eventDblClick;
          //OnResize    := Bokan.eventSizeChange;
          OnShow        := Bokan.eventShow;
          OnCloseQuery  := eventClose;
          OnKeyDown     := eventKeyDown;
          OnKeyPress    := eventKeyPress;
          OnKeyUp       := eventKeyUp;
          OnDragOver    := eventDragOver;
          OnDragDrop    := eventDragDrop;
          OnMouseWheel  := eventMouseWheel;
          OnMouseDown   := eventMouseDown;
          OnMouseMove   := eventMouseMove;
          OnMouseUp     := eventMouseUp;
          OnMouseEnter  := eventMouseEnter;
          OnMouseLeave  := eventMouseLeave;
          OnActivate    := FormActivate;
          //OnPaint       := eventPaint;
          Font.Name     := fontname;
          Font.Size     := fontsize;
          Font.Charset  := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_MAINMENU:
      begin
        o := TMainMenu.Create(parentObj);
        TMainMenu(o).AutoHotkeys := maManual;
        TMainMenu(o).AutoLineReduction := maManual;
        if Bokan.Menu = nil then Bokan.Menu := TMainMenu(o);
      end;
    VCL_GUI_POPUPMENU:
      begin
        o := TPopupMenu.Create(parentObj);
        TPopupMenu(o).AutoHotkeys := maManual;
        TPopupMenu(o).AutoLineReduction := maManual;
        //with TPopupMenu(o) do begin end;
      end;
    VCL_GUI_MENUITEM:
      begin
        o := TMenuItem.Create(parentObj);
        TMenuItem(o).AutoHotkeys := maParent;
        TMenuItem(o).AutoLineReduction := maParent;

        with TMenuItem(o) do begin
          OnClick := Bokan.eventClick;
        end;
      end;
    VCL_GUI_SPLITTER:
      begin
        o := TSplitter.Create(parentObj);
        with TSplitter(o) do begin
          OnMoved := Bokan.eventChange;
        end;
      end;
    VCL_GUI_IMAGELIST:
      begin
        o := TImageList.Create(Bokan);
      end;
    VCL_GUI_TOOLBUTTON:
      begin
        o := TToolButton.Create(parentObj);
        with TToolButton(o) do begin
          OnClick    := Bokan.eventClick;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
        end;
      end;
    VCL_GUI_TIMER:
      begin
        o := TTimer.Create(parentObj);
        with TTImer(o) do
        begin
          Enabled := False;
          OnTimer := Bokan.eventTimer;
        end;
      end;
    // UNICODE COMPONENT
    VCL_GUI_UBUTTON:
      begin
        o := TButton.Create(parentObj);
        with TButton(o) do begin
          OnClick := Bokan.eventClick;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_UEDIT        :
      begin
        o := TEdit.Create(parentObj);
        with TEdit(o) do begin
          OnClick     := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnChange    := Bokan.eventChange;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_UMEMO        :
      begin
        o := TMemo.Create(parentObj);
        with TMemo(o) do begin
          ScrollBars := ssBoth;
          OnClick     := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnChange    := Bokan.eventChange;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_ULIST        :
      begin
        o := TListBox.Create(parentObj);
        with TListBox(o) do begin
          OnClick     := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Style := lbOwnerDrawFixed;
          ItemHeight  := 14;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_UCOMBO       :
      begin
        o := TComboBox.Create(parentObj);
        with TComboBox(o) do begin
          AutoComplete := False;
          OnClick     := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnChange    := Bokan.eventChange;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          OnDropDown  := Bokan.eventListOpen;
          OnCloseUp   := Bokan.eventListClose;
          OnSelect    := Bokan.eventListSelect;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_UCHECK       :
      begin
        o := TCheckBox.Create(parentObj);
        with TCheckBox(o) do begin
          OnClick     := Bokan.eventClick;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_URADIO       :
      begin
        o := TRadioGroup.Create(parentObj);
        with TRadioGroup(o) do begin
          OnClick   := Bokan.eventClick;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_UGRID        :
      begin
        o := TStringGrid.Create(parentObj);
        with TStringGrid(o) do begin
          FixedCols := 0;
          DefaultColWidth := 32;
          DefaultRowHeight := Trunc(Bokan.Canvas.TextHeight('Z') * 1.5);
          Options := [goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,goColSizing,goRowSelect];
          OnClick := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnKeyDown   := Bokan.eventKeyDown;
          OnKeyPress  := Bokan.eventKeyPress;
          OnKeyUp     := Bokan.eventKeyUp;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    VCL_GUI_ULABEL       :
      begin
        o := TLabel.Create(parentObj);
        with TLabel(o) do begin
          AutoSize := False;
          Transparent := True;
          OnClick := Bokan.eventClick;
          OnDblClick  := Bokan.eventDblClick;
          OnMouseDown := Bokan.eventMouseDown;
          OnMouseMove := Bokan.eventMouseMove;
          OnMouseUp   := Bokan.eventMouseUp;
          OnMouseEnter:= Bokan.eventMouseEnter;
          OnMouseLeave:= Bokan.eventMouseLeave;
          OnDragOver  := Bokan.eventDragOver;
          OnDragDrop  := Bokan.eventDragDrop;
          Font.Name := fontname;
          Font.Size := fontsize;
          Font.Charset := DEFAULT_CHARSET;
        end;
      end;
    else
      raise Exception.Create('VCL_CREATEで未定義のVCLタイプ');
  end;

  // ヘルパーに登録
  o.Tag  := guiCount; Inc(guiCount);
  with GuiInfos[o.Tag] do begin
    obj      := o;
    obj_type := oType;
    name     := oName;
    name_id  := nako_tango2id(PAnsiChar(name));
    fileDrop := nil;
    // pgroup   := g;
    pgroup   := nako_getVariableFromId(name_id);
  end;

  if (o is TControl)and(not(o is TfrmNako)) then
  begin
    with TControl(o) do begin
      Parent := TWinControl(parentObj);
      Left := hi_int(baseX);
      if (hi_int(baseY) + Height) < bokan.ClientHeight then
      begin
        Top  := hi_int(baseY);
      end else
      begin
        Top  := 10;
      end;
      if not (o is TStatusBar) then
        nako_int2var(Top + Height + hi_int(baseInterval), baseY);
    end;
  end;

  // (3) 結果の代入
  Result := hi_newInt(Integer(o));
end;


function vcl_getprop(h: DWORD): PHiValue; stdcall;
var
  s, a: PHiValue;
  obj: TComponent;
  prop: Integer;
  ginfo: TGuiInfo;

  procedure _getText;
  var
    res: string;
    res_a: AnsiString;

    function getGridText: string;
    var g: TStringGrid; i: Integer;
    begin
      Result := '';

      g := TStringGrid(obj);
      if goRowSelect in g.Options then
      begin
        if g.Row < 0 then Exit;
        for i := 0 to g.ColCount - 1 do
        begin
          Result := Result + '"' + string(g.Cells[i, g.Row]) + '"';
          if (g.ColCount-1) <> i then Result := Result + ',';
        end;
      end else
      begin
        if (g.Col >= 0)and(g.Row >= 0) then
          Result := '"' + string(g.Cells[g.Col, g.Row]) + '"';
      end;
    end;

    function getGridTextUni: WideString;
    var g: TStringGrid; i: Integer;
    begin
      Result := '';

      g := TStringGrid(obj);
      if goRowSelect in g.Options then
      begin
        if g.Row < 0 then Exit;
        for i := 0 to g.ColCount - 1 do
        begin
          Result := Result + '"' + g.Cells[i, g.Row] + '"';
          if (g.ColCount-1) <> i then Result := Result + ',';
        end;
      end else
      begin
        if (g.Col >= 0)and(g.Row >= 0) then
          Result := '"' + g.Cells[g.Col, g.Row] + '"';
      end;
    end;

    function getStatusbarText: string;
    var bar:TStatusBar; i:integer;
    begin
      Result := '';
      bar := TStatusBar(obj);
      if bar.Panels.Count > 0 then
      begin
        result := bar.Panels.Items[0].Text;
        for i:=1 to bar.Panels.Count-1 do
        begin
          result := result +#13#10+ bar.Panels.Items[i].Text;
        end;
      end;
    end;

  begin
    res := '';
    case ginfo.obj_type of
      VCL_GUI_BUTTON      : res := TButton(obj).Caption;
      VCL_GUI_EDIT        : res := TEdit(obj).Text;
      VCL_GUI_MEMO        : res := TMemo(obj).Text;
      VCL_GUI_LIST        : if TListBox(obj).ItemIndex >= 0 then res := TListBox(obj).Items.Strings[ TListBox(obj).ItemIndex ];
      VCL_GUI_COMBO       : res := TComboBox(obj).Text;
      VCL_GUI_PANEL       : res := TNakoPanel(obj).Text;
      VCL_GUI_CHECK       : res := TCheckBox(obj).Caption;
      VCL_GUI_RADIO       : res := TRadioGroup(obj).Caption;
      VCL_GUI_RADIOGROUP  : if TRadioGroup(obj).ItemIndex >= 0 then res := TRadioGroup(obj).Items[TRadioGroup(obj).ItemIndex];
      VCL_GUI_GRID        : res := getGridText;
      VCL_GUI_LABEL       : res := TLabel(obj).Caption;
      VCL_GUI_MENUITEM    : res := TMenuItem(obj).Caption;
      VCL_GUI_TABPAGE     : res := TPageControl(obj).ActivePage.Caption;
      VCL_GUI_STATUSBAR   : if TStatusBar(obj).SimplePanel then res := TStatusBar(obj).SimpleText else res := getStatusbarText;
      VCL_GUI_SPINEDIT    : res := TSpinEdit(obj).Text;
      VCL_GUI_TEDITOR     : res := THiEditor(obj).Lines.Text;
      VCL_GUI_FORM        : res := TfrmNako(obj).Caption;
      VCL_GUI_TREEVIEW    : begin if TTreeView(obj).Selected <> nil then res := TTreeView(obj).Selected.Text; end;
      VCL_GUI_LISTVIEW    : begin if TListView(obj).Selected <> nil then res := TListView(obj).Selected.Caption; end;
      VCL_GUI_CALENDER    : res := FormatDateTime('yyyy/mm/dd',TMonthCalendar(obj).Date);
      VCL_GUI_WEBBROWSER  : res := TUIWebBrowser(obj).DocumentSource;
      VCL_GUI_PROPEDIT    : res := TValueListEditor(obj).Strings.Text;
      VCL_GUI_PIC_BUTTON  : res := TSpeedButton(obj).Caption;
      VCL_GUI_BIT_BUTTON  : res := TBitBtn(obj).Caption;
      VCL_GUI_GROUPBOX    : res := TGroupBox(obj).Caption;
      // uni parts
      VCL_GUI_UBUTTON     : res := (TButton(obj).Caption);
      VCL_GUI_UEDIT       :
        begin
          res := (TEdit(obj).Text);
          // ShowMessage(StrToHexStr(res)); // ok
        end;
      VCL_GUI_UMEMO       : res := (TMemo(obj).Text);
      VCL_GUI_ULIST       : if TListBox(obj).ItemIndex >= 0 then res := (TListBox(obj).Items.Strings[TListBox(obj).ItemIndex]);
      VCL_GUI_UCOMBO      : res := (TComboBox(obj).Text);
      VCL_GUI_UCHECK      : res := (TCheckBox(obj).Caption);
      VCL_GUI_URADIO      : res := (TRadioGroup(obj).Caption);
      VCL_GUI_UGRID       : res := (getGridTextUni);
      VCL_GUI_ULABEL      : res := (TLabel(obj).Caption);

    end;
    if IsDialogConvNum then
    begin
      res_a := AnsiString(res);
      if IsNumber(res_a) then
      begin
        res := string(res_a);
        try
          hi_setFloat(Result, StrToFloatA(convToHalf(AnsiString(res))))
        except
          hi_setStrU(Result, res);
        end;
      end else hi_setStrU(Result, res);
    end else
    begin
      hi_setStrU(Result, res);
    end;
  end;

  procedure _getValue;
  var res: Integer;
  begin
    res := -1;
    case ginfo.obj_type of
      VCL_GUI_LIST        : res := TListBox(obj).ItemIndex;
      VCL_GUI_COMBO       : res := TComboBox(obj).ItemIndex;
      VCL_GUI_GRID        : res := TStringGrid(obj).Row;
      VCL_GUI_RADIO       : res := TRadioGroup(obj).ItemIndex;
      VCL_GUI_RADIOGROUP  : res := TRadioGroup(obj).ItemIndex;
      VCL_GUI_LISTVIEW    : if TListView(obj).Selected <> nil then res := TListView(obj).Selected.Index;
      VCL_GUI_CHECK       : res := Ord(TCheckBox(obj).Checked);
      VCL_GUI_BAR         : res := TScrollBar(obj).Position;
      VCL_GUI_TIMER       : res := TTimer(obj).Interval;
      VCL_GUI_TREEVIEW    : res := THiTreeView(obj).ItemIndex;
      VCL_GUI_PROGRESS    : res := TProgressBar(obj).Position;
      // uni
      VCL_GUI_ULIST        : res := TListBox(obj).ItemIndex;
      VCL_GUI_UCOMBO       : res := TComboBox(obj).ItemIndex;
      VCL_GUI_UGRID        : res := TStringGrid(obj).Row;
      VCL_GUI_URADIO       : res := TRadioGroup(obj).ItemIndex;
      else raise Exception.Create('定義されていません。');
    end;
    hi_setInt(Result, res);
  end;

  procedure _getItem;
  var res: string; csv: TCsvSheet;
  begin
    res := '';
    case ginfo.obj_type of
      VCL_GUI_LIST  : res := TListBox(obj).Items.Text;
      VCL_GUI_COMBO : res := TComboBox(obj).Items.Text;
      VCL_GUI_RADIO : res := TRadioGroup(obj).Items.Text;
      VCL_GUI_RADIOGROUP : res := TRadioGroup(obj).Items.Text;
      VCL_GUI_GRID  :
        begin
          csv := TCsvSheet.Create;
          try
            CsvGridGetData(TStringGrid(obj), csv);
            res := string(csv.AsText);
          finally
            csv.Free;
          end;
        end;
      VCL_GUI_TREEVIEW:
        begin
          res := TreeToCsv(obj as THiTreeView);
        end;
      VCL_GUI_ULIST : res := (TListBox(obj).Items.Text);
      VCL_GUI_UCOMBO: res := (TComboBox(obj).Items.Text);
      VCL_GUI_URADIO: res := (TRadioGroup(obj).Items.Text);
      VCL_GUI_UGRID:
        begin
          csv := TCsvSheet.Create;
          try
            CsvGridGetDataUni(TStringGrid(obj), csv);
            res := string(csv.AsText);
          finally
            csv.Free;
          end;
        end;
      else raise Exception.Create('定義されていません。');
    end;
    hi_setStrU(Result,res);
  end;
  procedure _getHandle;
  begin
    case ginfo.obj_type of
      VCL_GUI_IMAGE:  hi_setInt(Result, TImage(obj).Canvas.Handle);
      else            hi_setInt(Result, TWinControl(obj).Handle);
    end;
  end;
  procedure _getSelText;
  var res: string;
  begin
    res := '';
    case ginfo.obj_type of
      VCL_GUI_EDIT    : res := TEditXP(obj).SelText;
      VCL_GUI_MEMO    : res := TMemoXP(obj).SelText;
      VCL_GUI_COMBO   : res := TComboBox(obj).SelText;
      VCL_GUI_SPINEDIT: res := TSpinEdit(obj).SelText;
      VCL_GUI_TEDITOR : res := THiEditor(obj).SelText;
      // uni
      VCL_GUI_UEDIT    : res := (TEdit(obj).SelText);
      VCL_GUI_UMEMO    : res := (TMemo(obj).SelText);
      VCL_GUI_UCOMBO   : res := (TComboBox(obj).SelText);
      else raise Exception.Create('定義されていません。');
    end;
    hi_setStrU(Result, res);
  end;
  procedure _getSelStart;
  var res: Integer;
  begin
    case ginfo.obj_type of
      VCL_GUI_EDIT    : res := TEditXP(obj).SelStart;
      VCL_GUI_MEMO    : res := TMemoXP(obj).SelStart;
      VCL_GUI_COMBO   : res := TComboBox(obj).SelStart;
      VCL_GUI_SPINEDIT: res := TSpinEdit(obj).SelStart;
      VCL_GUI_TEDITOR : res := THiEditor(obj).SelStart;
      // uni
      VCL_GUI_UEDIT    : res := TEdit(obj).SelStart;
      VCL_GUI_UMEMO    : res := TMemo(obj).SelStart;
      VCL_GUI_UCOMBO   : res := TComboBox(obj).SelStart;
      else raise Exception.Create('定義されていません。');
    end;
    hi_setInt(Result, res);
  end;
  procedure _getSelLength;
  var res: Integer;
  begin
    case ginfo.obj_type of
      VCL_GUI_EDIT    : res := TEditXP(obj).SelLength;
      VCL_GUI_MEMO    : res := TMemoXP(obj).SelLength;
      VCL_GUI_COMBO   : res := TComboBox(obj).SelLength;
      VCL_GUI_SPINEDIT: res := TSpinEdit(obj).SelLength;
      VCL_GUI_TEDITOR : res := THiEditor(obj).SelLength;
      VCL_GUI_UEDIT    : res := TEdit(obj).SelLength;
      VCL_GUI_UMEMO    : res := TMemo(obj).SelLength;
      VCL_GUI_UCOMBO   : res := TComboBox(obj).SelLength;
      else raise Exception.Create('定義されていません。');
    end;
    hi_setInt(Result, res);
  end;
  procedure _layout;
  var
    i: TAlign; res: AnsiString;
  begin
    res := '';
    if (obj is TWinControl) then
    begin
      i := TWinControl(obj).Align;
      case i of
        alNone:     res := '';
        alTop:      res := '上';
        alBottom:   res := '下';
        alLeft:     res := '左';
        alRight:    res := '右';
        alClient:   res := '全体';
      end;
      hi_setStr(Result, res);
    end else
    begin
      raise Exception.Create('定義されていません。');
    end;
  end;
  procedure _parent;
  var o: TWinControl;
  begin
    if obj is TControl then
    begin
      o := TControl(obj).Parent;
      if o = nil then
        hi_setStr(Result,'')
      else
        nako_varCopyData(nako_getVariable(PAnsiChar(GuiInfos[o.Tag].name)), Result);
    end;
  end;
  procedure _visible;
  begin
    if obj is TControl  then hi_setBool(Result, TControl(obj).Visible) else
    if obj is TMenuItem then hi_setBool(Result, TMenuItem(obj).Visible);
  end;
  procedure _enabled;
  begin
    if obj is TControl  then hi_setBool(Result, TControl(obj).Enabled) else
    if obj is TMenuItem then hi_setBool(Result, TMenuItem(obj).Enabled) else
    if obj is TTimer    then hi_setBool(Result, TTimer(obj).Enabled) else
    ;
  end;

begin
  // (1) 引数の取得
  s := nako_getFuncArg(h, 0);
  a := nako_getFuncArg(h, 1);

  prop  := hi_int(a);
  obj   := TComponent(hi_int(s));
  if obj = nil then raise Exception.Create('プロパティ番号('+IntToStr(prop)+')の取得で、オブジェクトを特定できません。');
  ginfo := GuiInfos[obj.Tag];


  Result := nako_var_new(nil);

  // (2) 処理
  // (3) 結果の代入
  try
    case prop of
      VCL_PROP_HANDLE : _getHandle;
      VCL_PROP_ID     : hi_setInt(Result, obj.Tag);
      VCL_PROP_X      : if obj is TControl then hi_setInt(Result, TControl(obj).Left);
      VCL_PROP_Y      : if obj is TControl then hi_setInt(Result, TControl(obj).Top);
      VCL_PROP_W      : if obj is TControl then hi_setInt(Result, TControl(obj).Width);
      VCL_PROP_H      : if obj is TControl then hi_setInt(Result, TControl(obj).Height);
      VCL_PROP_TEXT   : _getText;
      VCL_PROP_VALUE  : _getValue;
      VCL_PROP_ITEM   : _getItem;
      VCL_PROP_SEL_TEXT   : _getSelText;
      VCL_PROP_SEL_START  : _getSelStart;
      VCL_PROP_SEL_LENGTH : _getSelLength;
      VCL_PROP_LAYOUT     : _layout;
      VCL_PROP_PARENT     : _parent;
      VCL_PROP_VISIBLE    : _visible;
      VCL_PROP_ENABLED    : _enabled;
      VCL_PROP_DRAGMODE   : if obj is TWinControl then hi_setStr(Result, THiWinControl(obj).hi_getDragMode);
    end;
  except
    raise Exception.Create(
      string(ginfo.name) + 'のプロパティ(' + IntToStr(prop) + ')の取得でエラー。');
  end;
end;

function vcl_setprop(h: DWORD): PHiValue; stdcall;
var
  s, a, v: PHiValue;
  obj: TComponent;
  prop: Integer;
  ginfo: TGuiInfo;

  procedure _setText;
  var s: string;

    procedure setGridText(v: string);
    var g: TStringGrid; c: TCsvSheet; i: Integer;
    begin
      g := TStringGrid(obj);
      if goRowSelect in g.Options then
      begin
        if g.Row < 0 then Exit;
        c := TCsvSheet.Create;
        try
          c.AsText := AnsiString(v);
          if c.ColCount > g.ColCount then g.ColCount := c.ColCount;
          for i := 0 to c.ColCount - 1 do begin
            g.Cells[i, g.Row] := string(c.Cells[i, 0]);
          end;
        finally
          c.Free;
        end;
      end else
      begin
        if (g.Col >= 0) and (g.Row >= 0) then
          g.Cells[g.Col, g.Row] := string(v);
      end;
    end;
    procedure setGridTextUni(v: string);
    var g: TStringGrid; c: TCsvSheet; i: Integer;
    begin
      g := TStringGrid(obj);
      if goRowSelect in g.Options then
      begin
        if g.Row < 0 then Exit;
        c := TCsvSheet.Create;
        try
          c.AsText := AnsiString(v);
          if c.ColCount > g.ColCount then g.ColCount := c.ColCount;
          for i := 0 to c.ColCount - 1 do begin
            g.Cells[i, g.Row] := ansi2uni(c.Cells[i, 0]);
          end;
        finally
          c.Free;
        end;
      end else
      begin
        if (g.Col >= 0) and (g.Row >= 0) then
          g.Cells[g.Col, g.Row] := (v);
      end;
    end;

    procedure setStatusbarText(v: string);
    var
      bar: TStatusbar;
      i: Integer;
      sl:TStringList;
      panel:TStatusPanel;
    begin
      bar := TStatusbar(obj);
      sl := TStringList.Create;
      sl.Text := s;
      for i:=0 to sl.count-1 do
      begin
        if i >= bar.Panels.Count then
          panel := bar.Panels.Add
        else
          panel := bar.Panels.Items[i];
        panel.Text := sl.Strings[i];
      end;
      for i := sl.count to bar.Panels.Count-1 do
        bar.Panels.Delete(bar.Panels.Count - 1);
    end;

  begin
    s := hi_strU(v);
    case ginfo.obj_type of
      VCL_GUI_BUTTON      : TButton(obj).Caption    := s;
      VCL_GUI_EDIT        : TEdit(obj).Text         := s;
      VCL_GUI_MEMO        : TMemo(obj).Text         := s;
      VCL_GUI_LIST        : begin if TListBox(obj).ItemIndex >= 0 then TListBox(obj).Items[TListBox(obj).ItemIndex] := s; end;
      VCL_GUI_COMBO       : TComboBox(obj).Text     := s;
      VCL_GUI_PANEL       : TNakoPanel(obj).Text    := s;
      VCL_GUI_CHECK       : TCheckBox(obj).Caption  := s;
      VCL_GUI_RADIO       : TRadioGroup(obj).Caption:= s;
      VCL_GUI_RADIOGROUP  : begin if TRadioGroup(obj).ItemIndex >= 0 then TRadioGroup(obj).Items[TRadioGroup(obj).ItemIndex] := s; end;
      VCL_GUI_GRID        : setGridText(s);
      VCL_GUI_LABEL       : begin TLabel(obj).AutoSize := True; TLabel(obj).Caption := s; TLabel(obj).AutoSize := False; end;
      VCL_GUI_MENUITEM    : TMenuItem(obj).Caption  := s;
      VCL_GUI_STATUSBAR   : if TStatusBar(obj).SimplePanel then TStatusBar(obj).SimpleText  := s else setStatusbarText(s);
      VCL_GUI_SPINEDIT    : TSpinEdit(obj).Text     := s;
      VCL_GUI_TEDITOR     : THiEditor(obj).Lines.Text := s;
      VCL_GUI_FORM        : begin TfrmNako(obj).Caption := s; if obj = bokan then Application.Title := s; end;
      VCL_GUI_TABPAGE     : TPageControl(obj).ActivePage.Caption := s;
      VCL_GUI_TREEVIEW    : begin if TTreeView(obj).Selected <> nil then TTreeView(obj).Selected.Text := s; end;
      VCL_GUI_LISTVIEW    : begin if TListView(obj).Selected <> nil then TListView(obj).Selected.Caption := s; end;
      VCL_GUI_CALENDER    : try TMonthCalendar(obj).Date := VarToDateTime(s); except TMonthCalendar(obj).Date := Date; end;
      VCL_GUI_WEBBROWSER  : if TUIWebBrowser(obj).Document <> nil then TUIWebBrowser(obj).DocumentSource := s;
      VCL_GUI_PROPEDIT    : TValueListEditor(obj).Strings.Text := s;
      VCL_GUI_PIC_BUTTON  : TSpeedButton(obj).Caption    := s;
      VCL_GUI_BIT_BUTTON  : TBitBtn(obj).Caption    := s;
      VCL_GUI_GROUPBOX    : TGroupBox(obj).Caption    := s;
      // uni
      VCL_GUI_UBUTTON     : TButton(obj).Caption := (s);
      VCL_GUI_UEDIT       :
        begin
          TEdit(obj).Text         := (s);
        end;
      VCL_GUI_UMEMO       : TMemo(obj).Text         := (s);
      VCL_GUI_ULIST       : begin if TListBox(obj).ItemIndex >= 0 then TListBox(obj).Items[TListBox(obj).ItemIndex] := (s); end;
      VCL_GUI_UCOMBO      : TComboBox(obj).Text     := (s);
      VCL_GUI_UCHECK      : TCheckBox(obj).Caption  := (s);
      VCL_GUI_URADIO      : TRadioGroup(obj).Caption:= (s);
      VCL_GUI_UGRID       : setGridTextUni(s);
      VCL_GUI_ULABEL      : begin TLabel(obj).AutoSize := True; TLabel(obj).Caption := (s); TLabel(obj).AutoSize := False; end;
    end;
  end;

  procedure _setValue;
  var i: Integer;
  begin
    i := hi_int(v);
    case ginfo.obj_type of
      VCL_GUI_LIST        : TListBox(obj).ItemIndex  := i;
      VCL_GUI_COMBO       : TComboBox(obj).ItemIndex := i;
      VCL_GUI_GRID        : TStringGrid(obj).Row := i;
      VCL_GUI_RADIO       : TRadioGroup(obj).ItemIndex := i;
      VCL_GUI_RADIOGROUP  : TRadioGroup(obj).ItemIndex := i;
      VCL_GUI_TREEVIEW    : THiTreeView(obj).ItemIndex := i;
      VCL_GUI_LISTVIEW    : TListView(obj).Items[ i ].Selected := True;
      VCL_GUI_CHECK       : TCheckBox(obj).Checked := (i<>0);
      VCL_GUI_BAR         : TScrollBar(obj).Position := i;
      VCL_GUI_TIMER       : TTimer(obj).Interval := i;
      VCL_GUI_PROGRESS    : TProgressBar(obj).Position := i;
      //
      VCL_GUI_ULIST        : TListBox(obj).ItemIndex  := i;
      VCL_GUI_UCOMBO       : TComboBox(obj).ItemIndex := i;
      VCL_GUI_UGRID        : TStringGrid(obj).Row := i;
      VCL_GUI_URADIO       : TRadioGroup(obj).ItemIndex := i;
      VCL_GUI_UCHECK       : TCheckBox(obj).Checked := (i<>0);
      else raise Exception.Create('定義されていません。');
    end;
  end;

  procedure _setItem;
  var csv: TCsvSheet;
  begin
    case ginfo.obj_type of
      VCL_GUI_LIST        : TListBox(obj).Items.Text  := hi_strU(v);
      VCL_GUI_COMBO       : TComboBox(obj).Items.Text := hi_strU(v);
      VCL_GUI_RADIO       : TRadioGroup(obj).Items.Text := hi_strU(v);
      VCL_GUI_RADIOGROUP  : TRadioGroup(obj).Items.Text := hi_strU(v);
      VCL_GUI_GRID        :
        begin
          csv := TCsvSheet.Create;
          try
            csv.AsText := TrimA(hi_str(v));
            with TStringGrid(obj) do
            begin
              if csv.Count >= 2 then
                RowCount := csv.Count
              else
                RowCount := 2;
              CsvGridSetData(TStringGrid(obj), csv);
              CsvGridAutoColWidth(TStringGrid(obj), csv);
            end;
          finally
            csv.Free;
          end;
        end;
      VCL_GUI_TREEVIEW    : CsvToTree( THiTreeView(obj), hi_strU(v), True);
      // uni
      VCL_GUI_ULIST       : TListBox(obj).Items.Text  := ansi2uni(hi_str(v));
      VCL_GUI_UCOMBO      : TComboBox(obj).Items.Text := ansi2uni(hi_str(v));
      VCL_GUI_URADIO      : TRadioGroup(obj).Items.Text := ansi2uni(hi_str(v));
      VCL_GUI_UGRID       :
        begin
          csv := TCsvSheet.Create;
          try
            csv.setTextW(Trim(ansi2uni(hi_str(v))), ',');
            with TStringGrid(obj) do
            begin
              if csv.Count >= 2 then
                RowCount := csv.Count
              else
                RowCount := 2;
              CsvGridSetDataUni(TStringGrid(obj), csv);
              CsvGridAutoColWidthUni(TDrawGrid(obj), csv);
            end;
          finally
            csv.Free;
          end;
        end;
      else raise Exception.Create('定義されていません。');
    end;
  end;

  procedure _setSelText;
  var res: string;
  begin
    res := hi_strU(v);
    case ginfo.obj_type of
      VCL_GUI_EDIT    : TEdit(obj).SelText       := res;
      VCL_GUI_MEMO    : TMemo(obj).SelText       := res;
      VCL_GUI_COMBO   : TComboBox(obj).SelText   := res;
      VCL_GUI_SPINEDIT: TSpinEdit(obj).SelText      := res;
      VCL_GUI_TEDITOR : THiEditor(obj).SelText        := res;
      // uni
      VCL_GUI_UEDIT    : TEdit(obj).SelText       := (res);
      VCL_GUI_UMEMO    : TMemo(obj).SelText       := (res);
      VCL_GUI_UCOMBO   : TComboBox(obj).SelText   := (res);
      else raise Exception.Create('定義されていません。');
    end;
  end;
  procedure _setSelStart;
  var res: Integer;
  begin
    res := hi_int(v);
    if res < 0 then res := -1;
    try
      case ginfo.obj_type of
        VCL_GUI_EDIT    : TEdit(obj).SelStart      := res;
        VCL_GUI_MEMO    : TMemo(obj).SelStart      := res;
        VCL_GUI_COMBO   : TComboBox(obj).SelStart  := res;
        VCL_GUI_SPINEDIT: TSpinEdit(obj).SelStart  := res;
        VCL_GUI_TEDITOR : THiEditor(obj).SelStart    := res;
        // uni
        VCL_GUI_UEDIT    : TEdit(obj).SelStart      := res;
        VCL_GUI_UMEMO    : TMemo(obj).SelStart      := res;
        VCL_GUI_UCOMBO   : TComboBox(obj).SelStart  := res;
        else raise Exception.Create('定義されていません。');
      end;
    finally
    end;
  end;
  procedure _setSelLength;
  var res: Integer;
  begin
    res := hi_int(v);
    case ginfo.obj_type of
      VCL_GUI_EDIT    : TEditXP(obj).SelLength      := res;
      VCL_GUI_MEMO    : TMemo(obj).SelLength      := res;
      VCL_GUI_COMBO   : TComboBox(obj).SelLength  := res;
      VCL_GUI_SPINEDIT: TSpinEdit(obj).SelLength  := res;
      VCL_GUI_TEDITOR : THiEditor(obj).SelLength    := res;
      // uni
      VCL_GUI_UEDIT    : TEdit(obj).SelLength      := res;
      VCL_GUI_UMEMO    : TMemo(obj).SelLength      := res;
      VCL_GUI_UCOMBO   : TComboBox(obj).SelLength  := res;
      else raise Exception.Create('定義されていません。');
    end;
  end;
  procedure _layout;
  var s: AnsiString; i: TAlign;
  begin
    s := hi_str(v);
    if obj is TControl then
    begin
      i := alNone;
      if s = '全体' then i := alClient else
      if s = '上'   then i := alTop    else
      if s = '下'   then i := alBottom else
      if s = '左'   then i := alLeft   else
      if s = '右'   then i := alRight  else
      ;
      //raise Exception.Create('"'+s+'"は定義されていません。');
      TControl(obj).Align := i;
    end;
  end;
  procedure _parent;
  var oya: TComponent;
  begin
    try
      oya := TComponent(hi_int(v));
      if oya is TPageControl then begin
        oya := TPageControl(oya).ActivePage;
      end;
      if not(oya is TWinControl) and (oya <> nil) then raise Exception.Create('親に設定することができません。');

      if obj is TControl then
      begin
        TControl(obj).Parent := oya as TWinControl;
      end;
    except
      raise Exception.Create('親に設定することができませんでした。');
    end;
  end;

  procedure _visible(b: Boolean);
  begin
    if (obj is TfrmNako)and(obj = bokan) then
    begin
      bokan.Visible := b;
      if bokan.flagBokanSekkei then
      begin
        Application.ShowMainForm := b;
      end;
    end else
    if obj is TControl  then TControl(obj).Visible  := b else
    if obj is TMenuItem then TMenuItem(obj).Visible := b;
  end;
  procedure _enabled(b: Boolean);
  begin
    if obj is TControl  then TControl(obj).Enabled  := b else
    if obj is TMenuItem then TMenuItem(obj).Enabled := b else
    if obj is TTimer    then TTimer(obj).Enabled    := b else
    ;
  end;

  procedure _filedrop;
  begin
    if not(obj is TWinControl) then Exit;
    if ginfo.fileDrop = nil then begin
      ginfo.fileDrop := TFileDrop.Create(nil);
      ginfo.fileDrop.Control := TWinControl(obj);
      ginfo.fileDrop.OnFileDrop := bokan.eventFileDrop;
    end;
    ginfo.fileDrop.Accept := (hi_bool(v));
  end;

  procedure _hint;
  var str: string; b: Boolean;
  begin
    str := hi_strU(v);
    b   := (str <> '');
    if obj is TControl then
    begin
      TControl(obj).Hint := str;
      TControl(obj).ShowHint := b;
    end;
  end;

begin
  // (1) 引数の取得
  s := nako_getFuncArg(h, 0); // obj
  a := nako_getFuncArg(h, 1); // prop
  v := nako_getFuncArg(h, 2); // value

  // (2) 処理
  obj   := TComponent(hi_int(s));
  prop  := hi_int(a);
  if obj = nil then
  begin
    raise Exception.Create('VCL_SETでプロパティ番号('+IntToStr(prop)+')の設定で、オブジェクトの値が(nil)です。オブジェクトが生成されていない可能性があります。');
  end;
  try
    ginfo := GuiInfos[obj.Tag];
  except
    raise Exception.Create('VCL_SETでプロパティ番号('+IntToStr(prop)+')の設定で、オブジェクトを特定できません。');
  end;
  try
    case prop of
      VCL_PROP_X      : if obj is TControl then TControl(obj).Left   := hi_int(v);
      VCL_PROP_Y      : if obj is TControl then TControl(obj).Top    := hi_int(v);
      VCL_PROP_W      : if obj is TControl then TControl(obj).Width  := hi_int(v);
      VCL_PROP_H      : if obj is TControl then TControl(obj).Height := hi_int(v);
      VCL_PROP_TEXT   : _setText;
      VCL_PROP_VALUE  : _setValue;
      VCL_PROP_ITEM   : _setItem;
      VCL_PROP_SEL_TEXT   : _setSelText;
      VCL_PROP_SEL_START  : _setSelStart;
      VCL_PROP_SEL_LENGTH : _setSelLength;
      VCL_PROP_LAYOUT     : _layout;
      VCL_PROP_PARENT     : _parent;
      VCL_PROP_VISIBLE    : _visible(0 <> hi_int(v));
      VCL_PROP_ENABLED    : _enabled(0 <> hi_int(v));
      VCL_PROP_DRAGMODE   : if obj is TWinControl then THiWinControl(obj).hi_setDragMode(hi_str(v));
      VCL_PROP_FILEDROP   : _filedrop;
      VCL_PROP_HINT       : _hint;
      else raise Exception.Create(IntToStr(prop)+' は読取専用のプロパティです。');
    end;
  except
    raise Exception.Create(string(ginfo.name) + 'のプロパティ(' + IntToStr(prop) + ')の設定でエラー。');
  end;

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function vcl_command(h: DWORD): PHiValue; stdcall;
var
  o, c, v: PHiValue;
  cmd: string;
  ginfo: TGuiInfo;
  obj: TComponent;

  procedure setRes(i: Integer);
  begin
    Result := hi_var_new;
    hi_setInt(Result, i);
  end;
  procedure setResS(s: string);
  begin
    Result := hi_var_new;
    hi_setStrU(Result, s);
  end;

  procedure _VCL_GUI_TOOLBUTTON;
  begin
    if cmd = '画像設定' then
    begin
      TToolButton(o).ImageIndex := hi_int(v);
    end else
    if cmd = '画像取得' then
    begin
      Result := hi_var_new;
      hi_setInt(Result, TToolButton(o).ImageIndex);
    end;
  end;
  procedure _VCL_GUI_TREEVIEW;
  var s: string; tn: TTreeNode; e: THiTreeView; xx, yy: Integer;
  begin
    e := THiTreeView(obj);
    if cmd = '画像設定' then
    begin
      if hi_int(v) = 0 then raise Exception.Create('空のイメージリストは設定できません。');
      TTreeView(obj).Images := TImageList(hi_int(v));
    end else
    if cmd = '削除' then
    begin
      try
        TTreeView(obj).Items[ hi_int(v) ].Delete;
      except
      end;
    end else;
    if cmd = 'スタイル設定' then //線|ルート|ボタン
    begin
      s := hi_strU(v);
      TTreeView(obj).ShowLines := (Pos('線',    s) > 0);
      TTreeView(obj).ShowRoot  := (Pos('ルート',s) > 0);
      TTreeView(obj).ShowButtons := (Pos('ボタン',s) > 0);
    end else
    if cmd = 'インデント取得' then
    begin
      Result := hi_var_new;
      hi_setInt(Result, TTreeView(obj).Indent);
    end else
    if cmd = 'インデント設定' then
    begin
      TTreeView(obj).Indent := hi_int(v);
    end else
    if cmd = 'GET読取専用' then
    begin
      Result := hi_var_new;
      hi_setBool(Result, TTreeView(obj).ReadOnly);
    end else
    if cmd = 'SET読取専用' then
    begin
      TTreeView(obj).ReadOnly := ( hi_int(v) <> 0 );
    end else
    if cmd = '選択パス取得' then
    begin
      Result := hi_var_new;
      tn := TTreeView(obj).Selected;
      if tn = nil then Exit;
      hi_setStrU(Result, THiTreeNode(tn.Data).GetTreePathText);
    end else
    if cmd = 'ドロップパス取得' then
    begin
      Result := hi_newStr(AnsiString(e.dropPath));
    end else
    if cmd = 'ノード調査' then
    begin
      s := hi_strU(v);
      xx := StrToIntDef(getToken_s(s, ','), -1);
      yy := StrToIntDef(s,-1);
      if(xx<0)or(yy<0)then Exit;
      tn := e.GetNodeAt(xx, yy);
      if tn <> nil then
        Result := hi_newStr(AnsiString( THiTreeNode(tn.Data).IDStr ));
    end
    else if cmd = '選択パス設定' then THiTreeView(obj).SetSelectPath(hi_strU(v))
    else if cmd = '選択ID取得' then Result := hi_newStr(AnsiString(THiTreeView(obj).SelectedID))
    else if cmd = '選択ID設定' then THiTreeView(obj).SelectedID := hi_strU(v)
    else if cmd = 'アイテム数' then Result := hi_newInt(THiTreeView(obj).list.Count)
    else if cmd = 'テキスト変更' then THiTreeView(obj).ChangeText(hi_strU(v))
    else if cmd = '画像番号変更' then THiTreeView(obj).ChangePic(hi_strU(v))
    else if cmd = '選択画像番号変更' then THiTreeView(obj).ChangeSelectPic(hi_strU(v))
    else if cmd = 'ノード削除' then THiTreeView(obj).DeleteID(hi_strU(v))
    else if cmd = 'ノード開く'   then THiTreeView(obj).ExpandID(hi_strU(v))
    else if cmd = 'ノード閉じる' then THiTreeView(obj).CollapseID(hi_strU(v))
    else if cmd = 'ノード番号取得' then Result := hi_newInt(THiTreeView(obj).list.FindID(hi_strU(v)))
    else if cmd = '親ノード取得'   then Result := hi_newStrU(THiTreeView(obj).GetParentID(hi_strU(v)))
    else if cmd = '子ノード取得'   then Result := hi_newStrU(THiTreeView(obj).GetChildrenID(hi_strU(v)))
    else
    if cmd = 'POPUP' then TTreeView(obj).PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '文字サイズSET' then e.Font.Size := hi_int(v) else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '背景色取得' then setRes(Color2RGB(e.Color))  else
    if cmd = '背景色設定' then begin
      e.Color := RGB2Color(hi_int(v));
    end else
    ;
  end;
  procedure _VCL_GUI_LISTVIEW;
  var s: AnsiString; e: THiListView;
  begin
    e := THiListView(obj);
    if cmd = '画像設定' then
    begin
      if hi_int(v) = 0 then raise Exception.Create('空のイメージリストは設定できません。');
      TListView(obj).LargeImages := TImageList(hi_int(v));
      TListView(obj).SmallImages := TImageList(hi_int(v));
    end else
    if cmd = '削除' then
    begin
      try
        TListView(obj).Items[ hi_int(v) ].Delete;
      except
      end;
    end else
    if cmd = 'スタイル設定' then
    begin
      s := hi_str(v);
      if s = 'アイコン'         then TListView(obj).ViewStyle := vsIcon      else
      if s = 'スモールアイコン' then TListView(obj).ViewStyle := vsSmallIcon else
      if s = 'リスト'           then TListView(obj).ViewStyle := vsList      else
      if s = 'レポート'         then TListView(obj).ViewStyle := vsReport    else
      TListView(obj).ViewStyle := vsIcon;
    end else
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '文字サイズSET' then e.Font.Size := hi_int(v) else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '背景色取得' then setRes(Color2RGB(e.Color))  else
    if cmd = '背景色設定' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = '編集設定' then e.ReadOnly := not hi_bool(v) else
    if cmd = '編集取得' then Result := hi_newBool(not e.ReadOnly) else
    if cmd = '複数選択取得' then Result := hi_newBool(e.MultiSelect) else
    if cmd = '複数選択設定' then e.MultiSelect := hi_bool(v) else
    if cmd = '選択確認' then
    begin
      try
        Result := hi_newBool(e.Items.Item[hi_int(v)].Selected);
      except
        Result := hi_newBool(False);
      end;
    end;

    ;
  end;
  procedure _VCL_GUI_EDIT;
  var e: TEdit;
  begin
    e := TEdit(obj);
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then begin setFontName(e.Font, string(hi_str(v))); end else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size); end else
    if cmd = '文字サイズSET' then begin e.Font.Size := hi_int(v); end else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '背景色取得' then setRes(Color2RGB(e.Color))  else
    if cmd = '背景色設定' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = 'UNDO'  then e.Undo else
    if cmd = 'REDO'  then  else
    if cmd = 'COPY'  then e.CopyToClipboard    else
    if cmd = 'CUT'   then e.CutToClipboard     else
    if cmd = 'PASTE' then e.PasteFromClipboard else
    if cmd = 'SELECTALL' then e.SelectAll else
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = 'GETROW' then setRes(0) else
    if cmd = 'GETCOL' then setRes(e.SelStart) else
    if cmd = 'SETROW' then  else
    if cmd = '編集設定' then e.ReadOnly := not hi_bool(v) else
    if cmd = '編集取得' then Result := hi_newBool(not e.ReadOnly) else
    if cmd = 'IME取得' then Result := hi_newStr(getIMEStatusName(e.ImeMode)) else
    if cmd = 'IME設定' then e.ImeMode := setControlIME(hi_str(v)) else
    if cmd = 'パスワードモード取得' then Result := hi_newBool(e.PasswordChar=#0) else
    if cmd = 'パスワードモード設定' then if hi_bool(v) then e.PasswordChar := '*' else e.PasswordChar := #0 else
    ;
  end;

  procedure memoToLine(memo: TMemo; ToLine: Integer);
  var
    NowLine: Integer;
  begin
    with Memo do
    begin
      NowLine:=Perform(EM_LINEFROMCHAR,SelStart,0);
      Perform(EM_LINESCROLL,0,ToLine-NowLine);
      SelStart:=Perform(EM_LINEINDEX,ToLine-1,0);
    end;
  end;

  procedure _VCL_GUI_TEDITOR;
  var e: THiEditor;

    function _setHTMLColor: TFountain;
    var t: THTMLFountain;
    begin
      t := THTMLFountain.Create(Bokan);
      t.Mail.Color := clBlue;
      t.Mail.Style := [fsUnderline];
      t.Url.Color := clBlue;
      t.Url.Style := [fsUnderline];
      t.Ampersand.Color := clMaroon;
      t.Str.Color := clNavy;
      t.TagAttribute.Color := clRed;
      t.TagAttributeValue.Color := clOlive;
      t.TagColor.Color := clMaroon;
      t.TagElement.Color := clMaroon;
      t.Brackets.BracketItems[0].ItemColor.Color := clGreen;
      Result := t;
    end;

    procedure setcoloring;
    var s: string;
    begin
      // TODO
      s := UpperCase(hi_strU(v));
      if s = 'HTML'     then e.Fountain := _setHTMLColor else
      if s = 'DELPHI'   then e.Fountain := TDelphiFountain.Create(Bokan) else
      if s = 'PERL'     then e.Fountain := TPerlFountain.Create(Bokan) else
      if s = 'CPP'      then e.Fountain := TCppFountain.Create(Bokan) else
      if s = 'JAVA'     then e.Fountain := TJavaFountain.Create(Bokan) else
      if s = 'なでしこ' then e.Fountain := TNadesikoFountain.Create(Bokan) else
      if (s = '')or(s = 'TEXT') then e.Fountain := nil else
      raise Exception.Create(s + 'はサポートしていません。HTML/DELPHI/PERL/CPP/JAVA/TEXT/なでしこのみ');
    end;

  begin
    e := THiEditor(obj);
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '文字サイズSET' then e.Font.Size := hi_int(v) else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '背景色取得' then setRes(Color2RGB(e.Color))  else
    if cmd = '背景色設定' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = 'UNDO'  then e.Undo else
    if cmd = 'REDO'  then e.Redo else
    if cmd = 'COPY'  then e.CopyToClipboard    else
    if cmd = 'CUT'   then e.CutToClipboard     else
    if cmd = 'PASTE' then e.PasteFromClipboard else
    if cmd = 'SELECTALL' then e.SelectAll else
    if cmd = 'POPUP'  then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = 'GETROW' then setRes(e.Row) else
    if cmd = 'GETCOL' then setRes(e.Col) else
    if cmd = 'SETROW' then begin e.Row := hi_int(v); e.ShowCaret; end else
    if cmd = 'SETCOL' then e.Col := hi_int(v) else
    if cmd = '単語選択' then e.SelectTokenFromCaret else
    if cmd = 'カラーリング' then setcoloring else
    if cmd = 'GETCUR_X' then setRes(e.GetCaretXY.X) else
    if cmd = 'GETCUR_Y' then setRes(e.GetCaretXY.Y) else
    if cmd = 'SETCUR_X' then e.SetCaretXY(hi_int(v), e.GetCaretXY.X) else
    if cmd = 'SETCUR_Y' then e.SetCaretXY(e.GetCaretXY.Y, hi_int(v)) else
    if cmd = 'ルーラー' then e.Ruler.Visible := hi_bool(v) else
    if cmd = '左バー'   then e.Leftbar.Visible := hi_bool(v) else
    if cmd = '表示記号' then e.ViewFlag(hi_str(v)) else
    if cmd = '折り返し' then begin e.WordWrap := (hi_int(v) >= 1); e.WrapOption.WrapByte := hi_int(v) end else
    if cmd = '強調語句設定' then begin if e.Fountain = nil then e.ReserveWordList.Text := hi_strU(v) else e.Fountain.ReserveWordList.Text := hi_strU(v) end else
    if cmd = '強調語句取得' then begin if e.Fountain = nil then setResS(e.ReserveWordList.Text) else setResS(e.Fountain.ReserveWordList.Text) end else
    if cmd = 'オートインデント設定' then e.Caret.AutoIndent := hi_bool(v) else
    if cmd = 'オートインデント取得' then setRes(ord(e.Caret.AutoIndent))  else
    if cmd = '設定パネル表示' then
    begin
      if EditEditorProp(bokan.edtPropNormal,nil) then
      begin
        bokan.edtPropNormal.AssignTo(e);
      end;
    end else
    if cmd = 'カラーリングパネル表示' then
    begin
      if EditEditorProp(bokan.edtPropNormal,nil) then
      begin
        bokan.edtPropNormal.AssignTo(e);
      end;
    end else
    if cmd = '設定保存' then begin Bokan.edtPropNormal.Assign(e); Bokan.edtPropNormal.WriteIni(hi_strU(v),'TEditor','edit'); end else
    if cmd = '設定読込' then begin try Bokan.edtPropNormal.ReadIni(hi_strU(v),'TEditor','edit'); except end; Bokan.edtPropNormal.AssignTo(e); end else
    if cmd = 'しおり設定'     then begin e.PutMark(hi_int(v));  end else
    if cmd = 'しおりジャンプ' then begin e.GotoMark(hi_int(v)); end else
    if cmd = '編集設定' then e.ReadOnly := not hi_bool(v) else
    if cmd = '編集取得' then Result := hi_newBool(not e.ReadOnly) else
    if cmd = 'IME取得' then Result := hi_newStr(getIMEStatusName(e.ImeMode)) else
    if cmd = 'IME設定' then e.ImeMode := setControlIME(hi_str(v)) else
    if cmd = 'ファイルドロップ許可設定' then
    begin
      if hi_bool(v) then
        e.OnDropFiles := Bokan.eventTEditorDropFile
      else
        e.OnDropFiles := nil
      ;
    end else
    if cmd = 'ファイルドロップ許可取得' then Result := hi_newBool(Assigned(e.OnDropFiles)) else
    ;
  end;
  procedure _VCL_GUI_GRID;
  var e: TStrSortGrid; csv: TCsvSheet;
  begin
    e := TStrSortGrid(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '文字サイズSET' then begin
      e.Font.Size := hi_int(v); e.Canvas.Font := e.Font;
      e.DefaultRowHeight := Trunc(e.Canvas.TextHeight('Z') * 1.2);
    end else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '背景色取得' then setRes(Color2RGB(e.Color))  else
    if cmd = '背景色設定' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = '編集設定' then
    begin
      if hi_bool(v) then begin
        e.Options := e.Options - [goRowSelect];
        e.Options := e.Options + [goEditing, goAlwaysShowEditor];
      end else begin
        e.Options := e.Options - [goEditing, goAlwaysShowEditor];
        e.Options := e.Options + [goRowSelect];
      end;
    end else
    if cmd = '編集取得' then
    begin
      Result := hi_newBool(goEditing in e.Options);
    end else
    if cmd = 'GETROW' then Result := hi_newInt(e.Row) else
    if cmd = 'GETCOL' then Result := hi_newInt(e.Col) else
    if cmd = 'SETROW' then e.Row := hi_int(v) else
    if cmd = 'SETCOL' then e.Col := hi_int(v) else
    if cmd = '行選択取得' then
    begin
      if goRowSelect in e.Options then Result := hi_newBool(True) else Result := hi_newBool(False)
    end else
    if cmd = '行選択設定' then
    begin
      if hi_bool(v) then
        e.Options := e.Options + [goRowSelect]
      else
        e.Options := e.Options - [goRowSelect];
    end else
    if cmd = 'セルサイズ自動調節' then
    begin
      csv := TCsvSheet.Create;
      try
        CsvGridGetData(e, csv);
        CsvGridAutoColWidth(e, csv);
      finally
        csv.Free;
      end;
    end else
    if cmd = '自動ソート取得' then Result := hi_newBool(e.SortOps <> soNon) else
    if cmd = '自動ソート設定' then if hi_bool(v) then e.SortOps := soBoth else e.SortOps := soNon else
    ;
  end;

  procedure _VCL_GUI_IMAGE;
  var e: TImage; bmp: TBitmap; gif: TGIFImage; f, ext: string;
  begin
    e := TImage(obj);
    if cmd = '画像設定' then
    begin
      f := hi_strU(v);
      ext := UpperCase(ExtractFileExt(f));
      if f = '' then
      begin
        e.Picture := nil;
      end else
      if ext = '.GIF' then // アニメGIFに対応するため個別に作る
      begin
        e.Picture := nil;
        ExtractMixFile(f);
        gif := TGIFImage.Create;
        try
          try
            gif.LoadFromFile(f);
            e.Picture.Assign(gif.Bitmap);
            e.Width  := gif.Width;
            e.Height := gif.Height;
          except
            raise ;
          end;
        finally
          gif.Free;
        end;
      end else
      // その他の画像形式
      begin
        bmp := LoadPic(hi_strU(v));
        e.Picture.Assign(bmp);
        e.Width  := bmp.Width;
        e.Height := bmp.Height;
        bmp.Free;
      end;
    end else
    if cmd = 'STRETCH' then
    begin
      e.Stretch := hi_bool(v);
    end else
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '透明化設定' then
    begin
      e.Transparent := hi_bool(v);
    end;
    ;
  end;
  procedure _VCL_GUI_TRACKBOX;
  var e: TTrackBox;
  begin
    e := TTrackBox(obj);
    if cmd = 'SETCOLOR' then e.TrackColor := RGB2Color( hi_int(v) ) else
    if cmd = 'GETCOLOR' then Result := hi_newInt(Color2RGB( e.TrackColor) ) else
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    ;
  end;
  
  procedure _VCL_GUI_WEBBROWSER;
  var e: TUIWebBrowser; Doc : IHTMLDocument2; tmp:OleVariant;

    procedure changeSetting(s: string);
    var
      dc: TDownLoadControl_;
      pOleControl: IOleControl;
    const
      IID_IOleControl:TGUID = '{B196B288-BAB4-101A-B69C-00AA00341D07}';
    begin
      try
        {
          TDownLoadControl_  =set of ( CS_Images , CS_Videos , CS_BGSounds ,CS_NoScripts
          ,CS_NoJava , CS_NoActiveXRun , cs_NoActiveXDownLoad
          ,CS_DownLoadOnly , CS_ReSynchronize , CS_NoCash
          ,CS_NoFrame, CS_ForceOffLine , CS_NoClientPull , CS_Silent , CS_OffLine);
        }
        dc := [];
        if Pos('画像',  s) = 0                  then begin dc := dc + [CS_Images]; end;
        if Pos('ビデオ',s) = 0                  then dc := dc + [CS_Videos];
        if Pos('BGM',   s) = 0                  then dc := dc + [CS_BGSounds];
        if Pos('スクリプト', s) > 0             then begin dc := dc + [CS_NoScripts]; e.IeDontSCRIPT := True; end;
        if Pos('JAVA', s) > 0                   then dc := dc + [CS_NoJava];
        if Pos('ActiveX', s) > 0                then dc := dc + [CS_NoActiveXRun];
        if Pos('ActiveXダウンロード', s) > 0    then dc := dc + [cs_NoActiveXDownLoad];
        if Pos('ダイアログ', s) > 0             then begin dc := dc + [CS_Silent]; e.Silent := True; end;
        if Pos('オフラインモード', s) > 0       then dc := dc + [CS_OffLine];
        //
        e.DownLoadControl := dc;
        e.Application.QueryInterface(IID_IOleControl, pOleControl);
        pOleControl.OnAmbientPropertyChange(DISPID_AMBIENT_DLCONTROL);
        if (pOleControl <> nil) then pOleControl._Release ;
      except
      end;
    end;

  begin
    e := TUIWebBrowser(obj);
    try
      if cmd = 'SETURL'    then
      begin
        e.Navigate(hi_strU(v));
        GuiInfos[ e.Tag ].freetag := 1;
      end else
      if cmd = 'GETURL'    then Result := hi_newStrU( e.LocationURL ) else
      if cmd = '戻る'   then e.GoBack else
      if cmd = '進む'   then e.GoForward else
      if cmd = 'ホーム' then e.GoHome else
      if cmd = 'タイトル取得' then
      begin
        Doc := e.Document as IHTMLDocument2;
        Result := hi_newStrU(Doc.title);
      end else
      if cmd = '禁止項目設定' then changeSetting(hi_strU(v)) else
      if cmd = 'タグ追加' then
      begin
        Doc := e.Document as IHTMLDocument2;
        Doc.body.insertAdjacentHTML('BeforeEnd', hi_strU(v));
      end else
      if cmd = '注目' then
      begin
        //SetFocus(e.ParentWindow);
        e.SetFocus;
        e.DocFocus;
      end else
      if cmd = '印刷'           then e.ExecWB(OLECMDID_PRINT, OLECMDEXECOPT_DODEFAULT, tmp, tmp) else
      if cmd = '印刷プレビュー' then e.ExecWB(OLECMDID_PRINTPREVIEW, OLECMDEXECOPT_DODEFAULT, tmp, tmp) else
      if cmd = '更新'           then e.ExecWB(OLECMDID_REFRESH, OLECMDEXECOPT_DODEFAULT, tmp, tmp) else
      if cmd = '保存'           then e.ExecWB(OLECMDID_SAVEAS, OLECMDEXECOPT_DODEFAULT, tmp, tmp) else
      ;
    except end;
  end;
  procedure _VCL_GUI_SPINEDIT;
  var e: TSpinEdit;
  begin
    e := TSpinEdit(obj);
    if cmd = '最大値' then e.MaxValue := hi_int(v) else
    if cmd = '最小値' then e.MinValue := hi_int(v) else
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '文字サイズSET' then e.Font.Size := hi_int(v) else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '背景色取得' then setRes(Color2RGB(e.Color))  else
    if cmd = '背景色設定' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = 'UNDO'  then e.Undo else
    if cmd = 'REDO'  then  else
    if cmd = 'COPY'  then e.CopyToClipboard    else
    if cmd = 'CUT'   then e.CutToClipboard     else
    if cmd = 'PASTE' then e.PasteFromClipboard else
    if cmd = 'SELECTALL' then e.SelectAll else
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '編集設定' then e.ReadOnly := not hi_bool(v) else
    if cmd = '編集取得' then Result := hi_newBool(not e.ReadOnly) else
    ;
  end;

  procedure _VCL_GUI_BUTTON;
  var e: TButton;
  begin
    e := TButton(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then begin setFontName(e.Font, hi_strU(v)); end else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size); end else
    if cmd = '文字サイズSET' then begin e.Font.Size := hi_int(v); end else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
  end;
  procedure _VCL_GUI_MEMO;
  var e: TMemo; s: AnsiString;
  begin
    e := TMemo(obj);
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then begin setFontName(e.Font, hi_strU(v)); end else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size); end else
    if cmd = '文字サイズSET' then begin e.Font.Size := hi_int(v); end else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '背景色取得' then setRes(Color2RGB(e.Color))  else
    if cmd = '背景色設定' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = 'UNDO'  then e.Undo else
    if cmd = 'REDO'  then  else
    if cmd = 'COPY'  then e.CopyToClipboard    else
    if cmd = 'CUT'   then e.CutToClipboard     else
    if cmd = 'PASTE' then e.PasteFromClipboard else
    if cmd = 'SELECTALL' then e.SelectAll else
    if cmd = 'POPUP'  then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = 'GETROW' then setRes(e.CaretPos.Y) else
    if cmd = 'GETCOL' then setRes(e.CaretPos.X) else
    if cmd = 'SETROW' then memoToLine(e, hi_int(v)) else
    if cmd = 'SETCOL' then begin memoToLine(e, e.CaretPos.Y); e.SelStart := e.SelStart+ hi_int(v) end else
    if cmd = '編集設定' then e.ReadOnly := not hi_bool(v) else
    if cmd = '編集取得' then Result := hi_newBool(not e.ReadOnly) else
    if cmd = 'IME取得' then Result := hi_newStr(getIMEStatusName(e.ImeMode)) else
    if cmd = 'IME設定' then e.ImeMode := setControlIME(hi_str(v)) else
    if cmd = 'スクロールバー取得' then
    begin
      case e.ScrollBars of
        ssNone        : Result := hi_newStr('');
        ssHorizontal  : Result := hi_newStr('横');
        ssVertical    : Result := hi_newStr('縦');
        ssBoth        : Result := hi_newStr('縦横');
      end;
    end else
    if cmd = 'スクロールバー設定' then
    begin
      s := hi_str(v);
      if (s = '')or(s = 'なし') then e.ScrollBars := ssNone else
      if (s = '縦'  ) then e.ScrollBars := ssVertical else
      if (s = '横'  ) then e.ScrollBars := ssHorizontal else
      if (s = '縦横')or(s = '横縦')or(s = '両方') then e.ScrollBars := ssBoth else
      e.ScrollBars := ssNone;
    end else
    ;
  end;
  procedure _VCL_GUI_LIST;
  var e: TListBox;
  begin
    e := TListBox(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '文字サイズSET' then begin
      e.Style := lbOwnerDrawFixed;
      e.Canvas.Font.Size := hi_int(v);
      e.Font.Size := hi_int(v);
      e.ItemHeight := e.Canvas.TextHeight('a');
    end else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '背景色取得' then setRes(Color2RGB(e.Color))  else
    if cmd = '背景色設定' then e.Color := RGB2Color(hi_int(v)) else
    ;
  end;
  procedure _VCL_GUI_COMBO;
  var e: TComboBox;
  begin
    e := TComboBox( obj );
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '文字サイズSET' then e.Font.Size := hi_int(v) else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '背景色取得' then setRes(Color2RGB(e.Color))  else
    if cmd = '背景色設定' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = '編集設定' then if hi_bool(v) then e.Style := csDropDown else e.Style := csDropDownList else
    if cmd = '編集取得' then Result := hi_newBool(e.Style = csDropDown) else
    if cmd = 'IME取得' then Result := hi_newStr(getIMEStatusName(e.ImeMode)) else
    if cmd = 'IME設定' then e.ImeMode := setControlIME(hi_str(v)) else
    if cmd = 'リスト行数取得' then Result := hi_newInt(e.DropDownCount) else
    if cmd = 'リスト行数設定' then e.DropDownCount := hi_int(v) else
  end;
  procedure _VCL_GUI_BAR;
  var e: TScrollBar;
  begin
    e := TScrollBar(obj);
    if cmd = '最大値' then e.Max := hi_int(v) else
    if cmd = '最小値' then e.Min := hi_int(v) else
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '向き設定' then if hi_str(v) = '縦' then e.Kind := sbVertical else e.Kind := sbHorizontal else
    if cmd = '向き取得' then if e.Kind = sbVertical then Result := hi_newStr('縦') else Result := hi_newStr('横') else
  end;
  procedure _VCL_GUI_PROGRESS;
  var e: TProgressBar;
  begin
    e := TProgressBar(obj);
    if cmd = '最大値' then e.Max := hi_int(v) else
    if cmd = '最小値' then e.Min := hi_int(v) else
    if cmd = '値'     then begin e.Position := hi_int(v); end else
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
  end;
  procedure _VCL_GUI_PANEL;
  var e: TNakoPanel; s: AnsiString;
  begin
    e := TNakoPanel(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = 'スタイル設定' then
    begin // 枠なし|凹|凸
      s := hi_str(v);
      if s = '枠なし' then e.BevelOuter := bvNone    else
      if s = '凹'     then e.BevelOuter := bvLowered else
      if s = '凸'     then e.BevelOuter := bvRaised  else
      ;
    end else
    if cmd = 'スタイル取得' then
    begin
      case e.BevelOuter of
        bvNone    : Result := hi_newStr('枠なし');
        bvLowered : Result := hi_newStr('凹');
        bvRaised  : Result := hi_newStr('凸');
        else        Result := hi_newStr('');
      end;
    end else
    if cmd = '背景色取得' then setRes(Color2RGB(e.Color))  else
    if cmd = '背景色設定' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '文字サイズSET' then e.Font.Size := hi_int(v) else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    ;
  end;
  procedure _VCL_GUI_GROUPBOX;
  var e: TGroupBox;
  begin
    e := TGroupBox(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '背景色取得' then setRes(Color2RGB(e.Color))  else
    if cmd = '背景色設定' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '文字サイズSET' then e.Font.Size := hi_int(v) else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    ;
  end;
  procedure _VCL_GUI_SCROLL_PANEL;
  var e: TScrollBox;
  begin
    e := TScrollBox(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = 'パネル幅取得' then Result := hi_newInt(e.ClientWidth) else
    if cmd = 'パネル高取得' then Result := hi_newInt(e.ClientHeight) else
    if cmd = 'パネル幅設定' then e.ClientWidth  := hi_int(v) else
    if cmd = 'パネル高設定' then e.ClientHeight := hi_int(v) else
    if cmd = '背景色取得' then setRes(Color2RGB(e.Color))  else
    if cmd = '背景色設定' then e.Color := RGB2Color(hi_int(v)) else
    ;            
  end;
  procedure _VCL_GUI_CHECK;
  var e: TCheckBox;
  begin
    e := TCheckBox(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '文字サイズSET' then e.Font.Size := hi_int(v) else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '背景色取得' then setRes(Color2RGB(e.Color))  else
    if cmd = '背景色設定' then e.Color := RGB2Color(hi_int(v)) else

  end;
  procedure _VCL_GUI_RADIO;
  var e: TRadioGroup;
  begin
    e := TRadioGroup(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '文字サイズSET' then e.Font.Size := hi_int(v) else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '背景色取得' then setRes(Color2RGB(e.Color))  else
    if cmd = '背景色設定' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = 'GETCOL' then setRes(e.Columns)  else
    if cmd = 'SETCOL' then e.Columns := hi_int(v) else

  end;
  procedure _VCL_GUI_RADIOGROUP;
  var e: TRadioGroup;
  begin
    e := TRadioGroup(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '文字サイズSET' then e.Font.Size := hi_int(v) else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '背景色取得' then setRes(Color2RGB(e.Color))  else
    if cmd = '背景色設定' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = 'GETCOL' then setRes(e.Columns)  else
    if cmd = 'SETCOL' then e.Columns := hi_int(v) else
    if cmd = 'GETTITLE' then setResS(e.Caption) else
    if cmd = 'SETTITLE' then e.Caption := hi_strU(v) else

  end;
  procedure _VCL_GUI_LABEL;
  var e: TLabel; s: AnsiString;
  begin
    e := TLabel(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '文字サイズSET' then e.Font.Size := hi_int(v) else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '背景色取得' then setRes(Color2RGB(e.Color))  else
    if cmd = '背景色設定' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = '透明取得' then Result := hi_newBool(e.Transparent)  else
    if cmd = '透明設定' then e.Transparent := hi_bool(v) else
    if cmd = '文字位置取得' then
    begin
      case e.Alignment of
        taLeftJustify  : Result := hi_newStr('左');
        taRightJustify : Result := hi_newStr('右');
        taCenter       : Result := hi_newStr('中央');
      end;
    end else if cmd = '文字位置設定' then
    begin
      s := hi_str(v);
      if s = '左'   then e.Alignment := taLeftJustify else
      if s = '中央' then e.Alignment := taCenter else
      if s = '右'   then e.Alignment := taRightJustify else ;
    end else
    ;
  end;
  procedure _VCL_GUI_MENUITEM;
  var e, menu: TMenuItem;
  begin
    e := TMenuItem(obj);
    if cmd = '追加' then
    begin
      menu := TMenuItem(hi_int(v));
      TMenuItem(obj).Add(menu);
      menu.Visible := True;
    end else
    if cmd = 'チェック取得' then begin Result := hi_newBool(e.Checked) end else
    if cmd = 'チェック設定' then begin e.Checked := (hi_int(v) <> 0); end else
    if cmd = 'ショートカット取得' then begin Result := hi_newStrU(ShortCutToText(e.ShortCut)) end else
    if cmd = 'ショートカット設定' then begin e.ShortCut := TextToShortCut(hi_strU(v)); end else
    begin
      raise Exception.Create(string(cmd)+'は未定義です。');
    end;
  end;
  procedure _VCL_GUI_TABPAGE;
  var sheet: TTabSheet; e: TPageControl; i: Integer;
  begin
    e := obj as TPageControl;

    if cmd = 'タブ追加' then
    begin
      sheet := TTabSheet.Create(obj);
      sheet.Caption := hi_strU(v);
      sheet.PageControl := e;
      Result := nako_var_new(nil);
      hi_setInt(Result, Integer(sheet));
    end else
    if cmd = 'テキスト取得' then
    begin
      Result := hi_var_new;
      hi_setStrU(Result, e.ActivePage.Caption);
    end else
    if cmd = 'テキスト設定' then
    begin
      e.ActivePage.Caption := hi_strU(v);
    end else
    if cmd = '表示タブ取得' then
    begin
      Result := hi_var_new;
      hi_setInt(Result, e.ActivePageIndex);
    end else
    if cmd = '表示タブ設定' then
    begin
      e.ActivePageIndex := hi_int(v);
    end else
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = 'タブ削除' then
    begin
      i := hi_int(v);
      if e.PageCount <= i then Exit;
      try
        sheet := e.Pages[i];
        sheet.PageControl := nil;
        sheet.Free;
      except
      end;
    end else
    if cmd = 'タブ多段化取得' then
    begin
      Result := hi_var_new;
      hi_setBool(Result, e.MultiLine);
    end else
    if cmd = 'タブ多段化設定' then
    begin
      e.MultiLine := hi_bool(v);
    end else
    if cmd = 'CW取得' then
    begin
      Result := hi_newInt(e.ClientWidth);
    end else
    if cmd = 'CW設定' then
    begin
      e.ClientWidth := hi_int(v);
    end else
    if cmd = 'CH取得' then
    begin
      Result := hi_newInt(e.ClientHeight);
    end else
    if cmd = 'CH設定' then
    begin
      e.ClientHeight := hi_int(v);
    end
    else begin
      raise Exception.Create(string(cmd)+'は未定義です。');
    end;
  end;
  procedure _VCL_GUI_CALENDER;
  var e: TMonthCalendar;
  begin
    e := TMonthCalendar(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
  end;
  procedure _VCL_GUI_STATUSBAR;
  var e: TStatusBar; i:integer;
  begin
    e := TStatusBar(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '文字サイズSET' then e.Font.Size := hi_int(v) else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '分割取得'  then begin
      Result := hi_var_new;
      hi_setBool(Result, not e.SimplePanel);
    end else
    if cmd = '分割設定'  then e.SimplePanel := not hi_bool(v) else
    if cmd = '項目幅取得'  then begin
      Result := hi_var_new;
      if e.Panels.Count > 0 then
      begin
        nako_ary_create(Result);
        for i := 0 to e.Panels.Count-1 do
          nako_ary_add(result,hi_newInt(e.Panels.Items[i].Width))
      end;
    end else
    if cmd = '項目幅設定'  then
    begin
      if e.Panels.Count > 0 then
      begin
        for i := 0 to e.Panels.Count-1 do
          e.Panels.Items[i].Width := hi_int(nako_ary_get(v,i));
      end;
    end else
  end;
  procedure _VCL_GUI_TOOLBAR;
  var b: TToolButton;
  begin
    if cmd = 'POPUP' then TToolBar(obj).PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '画像設定' then
    begin
      if hi_int(v) = 0 then raise Exception.Create('空のイメージリストは設定できません。');
      TToolBar(obj).Images := TImageList(hi_int(v));
    end else
    if cmd = '追加' then
    begin
      b := TToolButton( hi_int(v) );
      if (b = nil)or(not(b is TToolButton)) then raise Exception.Create('ツールボタンのオブジェクトが空です。');
      b.Parent := TToolBar(obj);
      b.Visible := True;
    end;
  end;
  procedure _VCL_GUI_TIMER;
  begin
    
  end;
  procedure _VCL_GUI_KANA_EDIT;
  begin
  end;
  procedure _VCL_GUI_PROPEDIT;
  var e: TValueListEditor;
  begin
    e := TValueListEditor(obj);
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '文字サイズSET' then begin
      e.Font.Size := hi_int(v); e.Canvas.Font := e.Font;
      e.DefaultRowHeight := Trunc( e.Canvas.TextHeight('Z') * 1.2 );
    end else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '背景色取得' then setRes(Color2RGB(e.Color))  else
    if cmd = '背景色設定' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = 'POPUP'        then e.PopupMenu := TPopupMenu( hi_int(v) ) else
  end;
  procedure _VCL_GUI_FORM;
  var e: TfrmNako; ico: TIcon; icoCreate: TjvIcon; s: string; bmp: TBitmap; opt:Integer;
  begin
    e := TfrmNako(obj);
    if cmd = '背景ハンドル' then begin Result := hi_var_new; hi_setInt(Result, Integer(e.BackCanvas.Handle)); end else
    if cmd = '表示'         then begin e.Show; e.Invalidate; end else
    if cmd = 'POPUP'        then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '文字サイズSET' then e.Font.Size := hi_int(v) else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '背景色取得' then setRes(Color2RGB(e.Color))  else
    if cmd = '背景色設定' then begin e.Color := RGB2Color(hi_int(v)); e.ClearScreen(e.Color); end else
    if cmd = 'スタイル設定' then e.setStyle(hi_str(v)) else
    if cmd = 'CW設定' then e.ClientWidth  := hi_int(v) else
    if cmd = 'CH設定' then e.ClientHeight := hi_int(v) else
    if cmd = 'CW取得' then Result := hi_newInt(e.ClientWidth)  else
    if cmd = 'CH取得' then Result := hi_newInt(e.ClientHeight) else
    if cmd = 'アイコン設定' then
    begin
      s := hi_strU(v);
      icoCreate := TjvIcon.Create(nil);
      bmp := LoadPic(s);
      ico := icoCreate.CreateIcon(bmp);
      bmp.Free;
      e.Icon.Assign(ico);
      ico.Free;
      icoCreate.Free;
      // タスクトレイにアイコンがあれば更新
      if e.IsLiveTasktray then begin e.ChangeTrayIcon end;
    end else
    if cmd = '画像設定' then
    begin
      if hi_str(v) = '' then
      begin
        e.ClearScreen(e.Color);
      end else
      begin
        bmp := LoadPic(hi_strU(v));
        try
          e.BackCanvas.Draw(0,0,bmp);
          e.ClientWidth := bmp.Width;
          e.ClientHeight := bmp.Height;
        finally
          bmp.Free;
        end;
      end;
    end else
    if cmd = 'モーダル表示' then
    begin
      nako_pushRunFlag;
      try
        ShowModalCheck(e, bokan);
        Result := hi_clone(nako_getSore);
      finally
        nako_popRunFlag;
      end;
      if e <> Bokan then nako_continue;
    end else
    if cmd = '閉じる' then e.Close else
    if cmd = 'タスクトレイ入れる' then e.MovetoTasktray(True) else
    if cmd = 'タスクトレイ出す' then e.LeaveTasktray(True)  else
    if cmd = 'タスクトレイ表示' then e.MovetoTasktray(False) else
    if cmd = 'タスクトレイ非表示' then e.LeaveTasktray(False) else
    if cmd = 'タスクトレイバルーン表示' then e.showBalloon(hi_str(v)) else
    if cmd = 'タスクトレイバルーン非表示' then e.hideBalloon() else
    if cmd = 'タスクトレイバルーンオプションSET' then
    begin
      s := hi_str(v);
      opt := 0;
      if Pos('アイコン無し',  s) > 0            then opt := $00000000 { NIIF_NONE=$00000000 } else
      if Pos('エラーアイコン',  s) > 0          then opt := $00000003 { NIIF_ERROR=$00000003 } else
      if Pos('通知アイコン',  s) > 0            then opt := $00000001 { NIIF_INFO=$00000001 } else
      if Pos('警告アイコン',  s) > 0            then opt := $00000002 { NIIF_WARNING=$00000002 } else
      if Pos('アプリケーションアイコン',s) > 0  then opt := $00000004; { NIIF_USER=$00000004 }
      if (Pos('ラージアイコン',s) > 0) or (Pos('大きなアイコン',  s) > 0) then opt := opt + $00000020; { NIIF_LARGE_ICON=$00000020 }
      if (Pos('音無し',  s) > 0) or (Pos('無音',  s) > 0)  then opt := opt + $00000010; { NIIF_NOSOUND=$00000010 }
      e.dwBalloonOption := opt;
      if Pos('リアルタイム',s) > 0  then e.bBalloonRealtime := true
      else e.bBalloonRealtime := false;
      if (Pos('タイトル無し',s) > 0) or (Pos('タイトルなし',s) > 0)  then e.bBalloonHideTitle := true
      else e.bBalloonHideTitle := false;
    end else
    if cmd = 'タスクトレイバルーンオプションGET' then
    begin
      opt := e.dwBalloonOption;
      s := '';
      if (opt and $00000010) <> 0 then begin s:='/無音'; opt:=opt-$00000010; end;
      if (opt and $00000020) <> 0 then begin s:='/ラージアイコン'; opt:=opt-$00000020; end;
      if opt=$00000000 then s:='アイコン無し'+s;
      if opt=$00000003 then s:='エラーアイコン'+s;
      if opt=$00000002 then s:='警告アイコン'+s;
      if opt=$00000001 then s:='通知アイコン'+s;
      if opt=$00000004 then s:='アプリケーションアイコン'+s;
      e.dwBalloonOption := opt;
      if e.bBalloonRealtime then s:=s+'/リアルタイム';
      if e.bBalloonHideTitle then s:=s+'/タイトル無し';
      Result := hi_var_new; hi_setStr(Result, s);
    end else
    if cmd = '画像通り変形' then
    begin
      SetRgnFromBitmap(e, e.backBmp, True);
      e.flagDragMove := True;
    end else
    if cmd = 'ドラッグ移動取得' then Result := hi_newBool(e.flagDragMove) else
    if cmd = 'ドラッグ移動設定' then e.flagDragMove := hi_bool(v) else
    if cmd = '吹き出し変形' then
    begin
      SetRgnHukidasi(e); e.flagDragMove := True;
    end else
    if cmd = '最大化' then
    begin
      //母艦の時のみ元に戻すと、子フォーム最小化＞母艦最小化＞子フォーム元通り＞母艦元通り
      //とすると、母艦元通りにしたとき子フォームが小さいまま
      //回避策が思いつかないので、母艦最小化時に、フォームを最大化/元通りしたときは、母艦元通り

      //if e.IsBokan then
      //  Application.Restore;
      if IsIconic(Application.Handle) then
        Application.Restore;
      e.WindowState := wsMaximized;
    end else
    if cmd = '最小化' then
    begin
      if e.IsBokan then
        Application.Minimize
      else
        e.WindowState := wsMinimized;
    end else
    if cmd = '元通り' then
    begin
      //if e.IsBokan then
      //  Application.Restore;
      if IsIconic(Application.Handle) then
        Application.Restore;
      e.WindowState := wsNormal;
    end else
    if cmd = 'ウィンドウ状態取得' then
    begin
      if e.IsBokan then
       if IsIconic(Application.Handle) then
       begin
         Result := hi_newStr('最小化');
         Exit;
       end;
       case e.WindowState of
         wsMaximized: Result := hi_newStr('最大化');
         wsMinimized: Result := hi_newStr('最小化');
         wsNormal   : Result := hi_newStr('元通り');
       end;
    end else
    if cmd = 'ウィンドウ状態設定' then
    begin
      if hi_str(v) = '最大化' then
      begin
        //if e.IsBokan then
        //  Application.Restore;
        if IsIconic(Application.Handle) then
          Application.Restore;
        e.WindowState := wsMaximized;
      end else
      if hi_str(v) = '最小化' then
      begin
        if e.IsBokan then
          Application.Minimize
        else
          e.WindowState := wsMinimized;
      end else
      begin
        //if e.IsBokan then
        //  Application.Restore;
        if IsIconic(Application.Handle) then
          Application.Restore;
        e.WindowState := wsNormal;
      end
    end else
    if cmd = '透明度取得' then
    begin
      if e.AlphaBlend then
        Result := hi_newInt(e.AlphaBlendValue)
      else
        Result := hi_newInt(255);
    end else
    if cmd = '透明度設定' then
    begin
      if hi_int(v) = 255 then begin
        e.AlphaBlend := False;
        e.AlphaBlendValue := hi_int(v);
      end else begin
        e.AlphaBlend := True;
        e.AlphaBlendValue := hi_int(v);
      end;
    end else
    if cmd = '最大化ボタン有効変更' then begin
      if hi_bool(v) then
        e.BorderIcons := e.BorderIcons + [biMaximize]
      else
        e.BorderIcons := e.BorderIcons - [biMaximize];
    end else
    if cmd = '最小化ボタン有効変更' then begin
      if hi_bool(v) then
        e.BorderIcons := e.BorderIcons + [biMinimize]
      else
        e.BorderIcons := e.BorderIcons - [biMinimize];
    end else
    if cmd = 'システムメニューボタン有効変更' then begin
      if hi_bool(v) then
        e.BorderIcons := e.BorderIcons + [biSystemMenu]
      else
        e.BorderIcons := e.BorderIcons - [biSystemMenu];
    end else
    ;
    // ハンドルが変わることがあるので必ず反映させる
    nako_setMainWindowHandle(bokan.Handle);
  end;
  procedure _VCL_GUI_MAINMENU;
  var menu: TMenuItem;
  begin
    if cmd = '追加' then
    begin
      menu := TMenuItem(hi_int(v));
      TMainMenu(obj).Items.Add(menu);
      menu.Visible := True;
    end else
    begin
      raise Exception.Create(string(cmd)+'は未定義です。');
    end;
  end;
  procedure _VCL_GUI_POPUPMENU;
  var menu: TMenuItem;
  begin
    if cmd = '追加' then
    begin
      menu := TMenuItem(hi_int(v));
      TPopupMenu(obj).Items.Add(menu);
      menu.Visible := True;
    end else
    begin
      raise Exception.Create(string(cmd)+'は未定義です。');
    end;
  end;
  procedure _VCL_GUI_SPLITTER;
  begin
  end;
  procedure _VCL_GUI_IMAGELIST;
  var
    e, imgs: TImageList; bmp, mask, bm: TBitmap; ico: TIcon; fname: string;
    i, w, cnt,no: Integer;
  begin
    e := TImageList(obj);
    if cmd = '初期化' then begin e.Clear; end else
    if cmd = '追加' then
    begin
      imgs  := TImageList(obj);
      fname := hi_strU(v);
      if LowerCase(ExtractFileExt(fname)) = '.ico' then
      begin
        ico := TIcon.Create;
        ExtractMixFile(fname);
        ico.LoadFromFile(fname);
        imgs.AddIcon(ico);
        ico.Free;
      end else
      begin
        bmp := LoadPic(fname);
        mask := TBitmap.Create;
        mask.Assign(bmp);
        mask.Mask(mask.Canvas.Pixels[mask.Width-1,mask.Height-1]);
        imgs.Add(bmp, mask);
        mask.Free;
        bmp.Free;
      end;
    end else
    if cmd = '一括追加' then
    begin
      imgs  := TImageList(obj);
      fname := hi_strU(v);
      bmp := LoadPic(fname);
      try
        w := imgs.Width;
        cnt := bmp.Width div w;
        if (bmp.Width mod w) > 1 then Inc(cnt);
        for i := 0 to cnt - 1 do
        begin
          bm := TBitmap.Create;
          try
            bm.Width  := w;
            bm.Height := imgs.Height;
            BitBlt(bm.Canvas.Handle, 0, 0, w, imgs.Height,
              bmp.Canvas.Handle, w * i, 0, SRCCOPY);
            mask := TBitmap.Create;
            mask.Assign(bm);
            mask.Mask(mask.Canvas.Pixels[mask.Width-1, mask.Height-1]);
            imgs.Add(bm, mask);
            mask.Free;
          finally
            bm.Free;
          end;
        end;
      finally
        bmp.Free;
      end;
    end else
    if cmd = '置換' then
    begin
      imgs  := TImageList(obj);
      fname := hi_strU(v);
      no := StrToIntDef(getToken_s(fname, '@'), 0);
      if LowerCase(ExtractFileExt(fname)) = '.ico' then
      begin
        ico := TIcon.Create;
        ExtractMixFile(fname);
        ico.LoadFromFile(fname);
        imgs.ReplaceIcon(no, ico);
        ico.Free;
      end else
      begin
        bmp := LoadPic(fname);
        mask := TBitmap.Create;
        mask.Assign(bmp);
        mask.Mask(mask.Canvas.Pixels[mask.Width-1,mask.Height-1]);
        imgs.Replace(no, bmp, mask);
        mask.Free;
        bmp.Free;
      end;
    end else
    if cmd = '画像W設定' then
    begin
      TImageList(obj).Width := hi_int(v);
    end else
    if cmd = '画像W取得' then
    begin
      Result := hi_var_new;
      hi_setInt(Result, TImageList(obj).Width);
    end else
    if cmd = '画像H設定' then
    begin
      TImageList(obj).Height := hi_int(v);
    end else
    if cmd = '画像H取得' then
    begin
      Result := hi_var_new;
      hi_setInt(Result, TImageList(obj).Height);
    end else
  end;
  procedure _VCL_GUI_TREENODE;
  begin
  end;
  procedure _VCL_GUI_PIC_BUTTON;
  var
    e: TSpeedButton;
    bmp: TBitmap;
  begin
    e := TSpeedButton(obj);
    Result := nil;
    if cmd = '画像設定' then
    begin
      bmp := LoadPic(hi_strU(v));
      try
        e.Glyph := bmp;
      finally
        bmp.Free;
      end;
    end else
    if cmd = 'フラット取得' then Result := hi_newBool(e.Flat) else
    if cmd = 'フラット設定' then e.Flat := hi_bool(v) else
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '文字サイズSET' then e.Font.Size := hi_int(v) else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = 'POPUP'        then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    ;
  end;
  procedure _VCL_GUI_BIT_BUTTON;
  var
    e: TBitBtn;
    bmp: TBitmap;
  begin
    e := TBitBtn(obj);
    Result := nil;
    if cmd = '画像設定' then
    begin
      bmp := LoadPic(hi_strU(v));
      try
        e.Glyph := bmp;
      finally
        bmp.Free;
      end;
    end else
    if cmd = '文字書体GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '文字書体SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '文字サイズGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '文字サイズSET' then e.Font.Size := hi_int(v) else
    if cmd = '文字色GET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '文字色SET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = 'POPUP'        then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    ;
  end;
  procedure _VCL_GUI_ANIME;
  var
    e: TAnimeBox;
    s: TStringList; bmp: TBitmap; i: Integer; gif: TGIFImage;
  begin
    e := TAnimeBox(obj);
    Result := nil;
    if cmd = '画像設定' then
    begin
      e.ClearImage;
      s := TStringList.Create;
      try
        s.Text := hi_strU(v);
        for i := 0 to s.Count - 1 do
        begin
          bmp := LoadPic(s.Strings[i]);
          e.AddBitmap(bmp);
        end;
        e.Start;
      finally
        s.Free;
      end;
    end else
    if cmd = 'GIF画像設定' then
    begin
      e.ClearImage;
      gif := TGIFImage.Create;
      try
        try
          gif.LoadFromFile(hi_strU(v));
          for i := 0 to gif.Images.Count - 1 do
          begin
            e.AddBitmap(gif.Images.SubImages[i].Bitmap);
          end;
        except
          raise Exception.CreateFmt('GIF画像「%s」が読めません。',[hi_str(v)]);
        end;
      finally
        gif.Free;
      end;
      e.Start;
    end else
    if cmd = '表示間隔設定' then
    begin
      e.Interval := hi_int(v);
    end else
    if cmd = '開始' then
    begin
      e.Start;
    end else
    if cmd = '停止' then
    begin
      e.Stop;
    end else
    if cmd = '再生回数設定' then
    begin
      e.RepeatTime := hi_int(v);
    end else
    if cmd = '再生回数取得' then
    begin
      Result := hi_newInt(e.RepeatTime);
    end else
    if cmd = 'ボタンモード設定' then
    begin
      case hi_int(v) of
      0: begin e.UseButton := False; e.UseButton2 := False; end;
      1: begin e.UseButton := True;  e.UseButton2 := False; end;
      2: begin e.UseButton := False; e.UseButton2 := True;  end;
      end;
    end;
  end;

begin
  //todo: VCL_COMMAND
  Result := nil;

  o := nako_getFuncArg(h, 0); // obj
  c := nako_getFuncArg(h, 1); // cmd
  v := nako_getFuncArg(h, 2); // value

  cmd   := hi_strU(c);

  if(o=nil)then
  begin
    raise Exception.Create('VCL_COMMANDの『'+string(cmd)+'』でオブジェクトが生成されていません。');
  end;

  try
    ginfo := GuiInfos[TControl(hi_int(o)).Tag];
    obj   := ginfo.obj;
  except
    raise Exception.Create('VCL_COMMANDの『'+string(cmd)+'』でオブジェクトが特定できませんでした。');
  end;

  case ginfo.obj_type of
    VCL_GUI_BUTTON : _VCL_GUI_BUTTON;
    VCL_GUI_EDIT : _VCL_GUI_EDIT;
    VCL_GUI_MEMO : _VCL_GUI_MEMO;
    VCL_GUI_LIST : _VCL_GUI_LIST;
    VCL_GUI_COMBO : _VCL_GUI_COMBO;
    VCL_GUI_BAR : _VCL_GUI_BAR;
    VCL_GUI_PROGRESS : _VCL_GUI_PROGRESS;
    VCL_GUI_PANEL : _VCL_GUI_PANEL;
    VCL_GUI_SCROLL_PANEL: _VCL_GUI_SCROLL_PANEL;
    VCL_GUI_CHECK : _VCL_GUI_CHECK;
    VCL_GUI_RADIO : _VCL_GUI_RADIO;
    VCL_GUI_RADIOGROUP : _VCL_GUI_RADIOGROUP;
    VCL_GUI_GRID : _VCL_GUI_GRID;
    VCL_GUI_IMAGE : _VCL_GUI_IMAGE;
    VCL_GUI_LABEL : _VCL_GUI_LABEL;
    VCL_GUI_MENUITEM : _VCL_GUI_MENUITEM;
    VCL_GUI_TABPAGE : _VCL_GUI_TABPAGE;
    VCL_GUI_CALENDER : _VCL_GUI_CALENDER;
    VCL_GUI_TREEVIEW : _VCL_GUI_TREEVIEW;
    VCL_GUI_LISTVIEW : _VCL_GUI_LISTVIEW;
    VCL_GUI_STATUSBAR : _VCL_GUI_STATUSBAR;
    VCL_GUI_TOOLBAR : _VCL_GUI_TOOLBAR;
    VCL_GUI_TIMER : _VCL_GUI_TIMER;
    VCL_GUI_WEBBROWSER : _VCL_GUI_WEBBROWSER;
    VCL_GUI_SPINEDIT : _VCL_GUI_SPINEDIT;
    VCL_GUI_TRACKBOX : _VCL_GUI_TRACKBOX;
    VCL_GUI_TEDITOR : _VCL_GUI_TEDITOR; // Tエディタ
    VCL_GUI_KANA_EDIT : _VCL_GUI_KANA_EDIT;
    VCL_GUI_PROPEDIT : _VCL_GUI_PROPEDIT;
    VCL_GUI_FORM        : _VCL_GUI_FORM;
    VCL_GUI_MAINMENU    : _VCL_GUI_MAINMENU;
    VCL_GUI_POPUPMENU   : _VCL_GUI_POPUPMENU;
    VCL_GUI_SPLITTER    : _VCL_GUI_SPLITTER;
    VCL_GUI_IMAGELIST   : _VCL_GUI_IMAGELIST;
    VCL_GUI_TOOLBUTTON  : _VCL_GUI_TOOLBUTTON;
    VCL_GUI_TREENODE    : _VCL_GUI_TREENODE;
    VCL_GUI_ANIME       : _VCL_GUI_ANIME;
    VCL_GUI_PIC_BUTTON  : _VCL_GUI_PIC_BUTTON;
    VCL_GUI_BIT_BUTTON  : _VCL_GUI_BIT_BUTTON;
    VCL_GUI_GROUPBOX    : _VCL_GUI_GROUPBOX;
    // UNICODE
    VCL_GUI_UBUTTON     : _VCL_GUI_BUTTON;
    VCL_GUI_UEDIT       : _VCL_GUI_EDIT;
    VCL_GUI_UMEMO       : _VCL_GUI_MEMO;
    VCL_GUI_ULIST       : _VCL_GUI_LIST;
    VCL_GUI_UCOMBO      : _VCL_GUI_COMBO;
    VCL_GUI_UCHECK      : _VCL_GUI_CHECK;
    VCL_GUI_URADIO      : _VCL_GUI_RADIO;
    VCL_GUI_UGRID       : _VCL_GUI_GRID;
    VCL_GUI_ULABEL      : _VCL_GUI_LABEL;
    else
      raise Exception.Create(string(ginfo.name) + 'にはコマンドは未定義です。');
  end;
end;


function vcl_set_apptitle(h: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
begin
  ps := nako_getFuncArg(h, 0);
  Application.Title := hi_strU(ps);
  Result := nil;
end;

function vcl_get_apptitle(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_var_new;
  hi_setStrU(Result, Application.Title);
end;

function cmd_StayOnTop(h: DWORD): PHiValue; stdcall;
var
  obj: TWinControl;
begin
  Result := nil;
  obj := TWinControl(getGui(nako_getFuncArg(h, 0)));
  if obj = nil then Exit;

  if obj is TfrmNako then
  begin
    // 以下の方法だとハンドルが変わってしまう
    // TForm(obj).FormStyle := fsStayOnTop;
    // 以下の方法だとハンドルが変わらないかも?!
    SetWindowPos(obj.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);
    // ハンドルが変わることがあるので必ず反映させる
    nako_setMainWindowHandle(bokan.Handle);
  end else
  begin
    obj.BringToFront;
  end;
end;

function cmd_IsStayOnTop(h: DWORD): PHiValue; stdcall;
var
  obj: TWinControl;
begin
  Result := nil;
  obj := TWinControl(getGui(nako_getFuncArg(h, 0)));
  if obj = nil then Exit;

  Result := hi_newBool(IsTopMost(obj.Handle));
end;

function cmd_StayOnTopOff(h: DWORD): PHiValue; stdcall;
var
  obj: TWinControl;
begin
  Result := nil;
  obj := TWinControl(getGui(nako_getFuncArg(h, 0)));
  if obj = nil then Exit;

  if obj is TfrmNako then
  begin
    SetWindowPos(obj.Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);
  end else
  begin
    obj.SendToBack;
  end;
end;

function _SetFocus(h: DWORD): PHiValue; stdcall;
var wnd: THandle;
begin
  Result := nil;
  wnd := getArgInt(h, 0);
  SetFocus(wnd);
end;
function _SendMessage(h: DWORD): PHiValue; stdcall;
var fh, fmsg, fw, fl: THandle;
begin
  Result := nil;
  fh   := getArgInt(h, 0);
  fmsg := getArgInt(h, 1);
  fw   := getArgInt(h, 2);
  fl   := getArgInt(h, 3);
  SendMessage(fh, fmsg, fw, fl);
end;
function _PostMessage(h: DWORD): PHiValue; stdcall;
var fh, fmsg, fw, fl: THandle;
begin
  Result := nil;
  fh   := getArgInt(h, 0);
  fmsg := getArgInt(h, 1);
  fw   := getArgInt(h, 2);
  fl   := getArgInt(h, 3);
  PostMessage(fh, fmsg, fw, fl);
end;

function browser_getId(web:TUIWebBrowser; idname: AnsiString): Variant;
var
  doc, items, inp: Variant;
  names: AnsiString;
  no: Integer;
begin
  try
    doc := web.Document;
    if VarIsClear(doc) then Exit;

    // IDを指定する
    if PosA('\', idname) = 0 then
    begin
      inp := doc.getElementById(idname);
    end else begin
      names := getToken_s(idname, '\');
      no    := StrToIntDefA(TrimA(idname), 1);
      items  := doc.getElementsByName(names);
      if VarIsClear(items) or (items.Length = 0) then
      begin
        items := Unassigned;
        items := doc.getElementsByTagName(names);
      end;
      if VarIsClear(items)  or (items.Length = 0) then
      begin
        Exit;
      end;
      if items.Length >= no then
      begin
        inp := items.item(no);
      end else
      begin
        Exit;
      end;
    end;
    if (VarIsClear(inp) or VarIsEmpty(inp)) then
    begin
      Exit;
    end;
    Result := inp;
  finally
    items := Unassigned;
    inp := Unassigned;
    doc := Unassigned;
  end;

end;

function browser_getFormValue(h: DWORD): PHiValue; stdcall;
var
  obj: TObject;
  idname: AnsiString;
  inp: Variant;
begin
  Result := nil;
  obj     := getGui(getArg(h, 0));
  idname  := getArgStr(h, 1);
  //
  try
    inp := browser_getId(obj as TUIWebBrowser, idname);
    if (VarIsEmpty(inp) or VarIsNull(inp)) then
    begin
      Exit;
    end;
    Result := hi_newStrU(inp.value);
  finally
    inp := Unassigned;
  end;
end;

function browser_setFormValue(h: DWORD): PHiValue; stdcall;
var
  obj: TObject;
  idname, value: AnsiString;
  inp: Variant;
begin
  Result := nil;
  obj     := getGui(getArg(h, 0));
  idname  := getArgStr(h, 1);
  value   := getArgStr(h, 2);
  //
  try
    inp := browser_getId(obj as TUIWebBrowser, idname);
    if (VarIsEmpty(inp) or VarIsNull(inp)) then
    begin
      Exit;
    end;
    inp.value := value;
  finally
    inp := Unassigned;
  end;
end;

function browser_submit(h: DWORD): PHiValue; stdcall;
var
  obj: TObject;
  idname: AnsiString;
  inp: Variant;
begin
  Result := nil;
  obj     := getGui(getArg(h, 0));
  idname  := getArgStr(h, 1);
  //
  try
    inp := browser_getId(obj as TUIWebBrowser, idname);
    if (VarIsEmpty(inp) or VarIsNull(inp)) then
    begin
      Exit;
    end;
    GuiInfos[TUIWebBrowser(obj).Tag].freetag := 1;
    inp.submit;
  finally
    inp := Unassigned;
  end;
end;

function browser_click(h: DWORD): PHiValue; stdcall;
var
  obj: TObject;
  idname: AnsiString;
  inp: Variant;
begin
  Result := nil;
  obj     := getGui(getArg(h, 0));
  idname  := getArgStr(h, 1);
  //
  try
    inp := browser_getId(obj as TUIWebBrowser, idname);
    if (VarIsEmpty(inp) or VarIsNull(inp)) then
    begin
      Exit;
    end;
    GuiInfos[TUIWebBrowser(obj).Tag].freetag := 1;
    try
      inp.click;
    except
    end;
  finally
    inp := Unassigned;
  end;
end;

function browser_printpreview(h: DWORD): PHiValue; stdcall;
var
  obj: TObject;
  d1, d2:OleVariant;
begin
  Result := nil;
  obj     := getGui(getArg(h, 0));
  //
  try
    TUIWebBrowser(obj).ExecWB(7, 0, d1, d2);
  except
  end;
  d1 := Unassigned;
  d2 := Unassigned;
end;

function browser_execwb(h: DWORD): PHiValue; stdcall;
var
  obj: TObject;
  cmd,opt:Integer;
  d1, d2:OleVariant;
begin
  Result := nil;
  obj     := getGui(getArg(h, 0));
  cmd := getArgInt(h, 1);
  opt := getArgInt(h, 2);
  //
  try
    TUIWebBrowser(obj).ExecWB(cmd, opt, d1, d2);
  except
  end;
  d1 := Unassigned;
  d2 := Unassigned;
end;


function browser_setHTML(h: DWORD): PHiValue; stdcall;
var
  obj: TObject;
  idname, html: AnsiString;
  inp: Variant;
begin
  Result := nil;
  obj     := getGui(getArg(h, 0));
  idname  := getArgStr(h, 1);
  html    := getArgStr(h, 2);
  //
  try
    inp := browser_getId(obj as TUIWebBrowser, idname);
    if (VarIsEmpty(inp) or VarIsNull(inp)) then
    begin
      Exit;
    end;
    inp.innerHTML := html;
  finally
    inp := Unassigned;
  end;
end;

function browser_getHTML(h: DWORD): PHiValue; stdcall;
var
  obj: TObject;
  idname: AnsiString;
  inp: Variant;
begin
  Result := nil;
  obj     := getGui(getArg(h, 0));
  idname  := getArgStr(h, 1);
  //
  try
    inp := browser_getId(obj as TUIWebBrowser, idname);
    if (VarIsEmpty(inp) or VarIsNull(inp)) then
    begin
      Exit;
    end;
    Result := hi_newStrU(inp.innerHTML);
  finally
    inp := Unassigned;
  end;
end;

function browser_waitToComplete(h: DWORD): PHiValue; stdcall;
var
  Sender: TObject;
begin
  Result := nil;
  Sender := getGui(getArg(h, 0));
  try
    while (GuiInfos[ TControl(Sender).Tag ].freetag = 1) do
    begin
      Application.ProcessMessages;
      Sleep(100);
    end;
  finally
  end;
end;


function sys_toHurigana(h: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  s := string(getArgStr(h,0,True));
  Result := hi_newStrU(
    StrUnit.ConvToHurigana(s, frmNako.Handle)
  );
end;


procedure sub_menus(ps: PHiValue; menu: TMenu);
var
  pm, pm_obj, po, pmenu: PHiValue;
  opo: TComponent;
  csv: TCsvSheet;
  i,cnt: Integer;

  oya, vname, cap, scut, opt, event: AnsiString;
  oldOya: array [0..30] of AnsiString;
  mnu: TMenuItem;

  function _count(s: AnsiString): Integer;
  var i : Integer;
  begin
    Result := 0;
    for i := 1 to Length(s) do
    begin
      if s[i] = '-' then Inc(Result);
    end;
  end;

begin
  for i:=0 to High(oldOya) do oldOya[i] := '';
  csv := TCsvSheet.Create;
  try
    csv.AsText := hi_str(ps);
    for i := 0 to csv.Count - 1 do
    begin
      oya   := TrimA(csv.Cells[0,i]); if oya   = 'なし' then oya  := '';
      vname := TrimA(csv.Cells[1,i]); if vname = '' then Continue;
      cap   := TrimA(csv.Cells[2,i]);
      scut  := TrimA(csv.Cells[3,i]); if scut  = 'なし' then scut  := '';
      opt   := TrimA(csv.Cells[4,i]); if opt   = 'なし' then opt   := '';
      event := TrimA(csv.Cells[5,i]); if event = 'なし' then event := '';
      if (Copy(oya,1,1) = '#')or(Copy(oya,1,2)='＃') then Continue;
      if Copy(vname,1,1) = '-' then
      begin
        vname := '__auto_' + oldOya[0] + '_line' + IntToStrA(i);
        cap   := '-';
      end;
      // キャプションを省略
      if cap = '' then
      begin
        cap := vname;
        if Copy(cap, Length(cap) - 8 + 1, 8) = 'メニュー' then // abメニュー
        begin
          cap := Copy(cap, 1, Length(cap) - 8);
        end;
      end;
      // 省略文字を使った
      if Copy(oya,1,1) = '-' then
      begin
        cnt := _count(oya);
        oya := oldOya[cnt-1];
        oldOya[cnt] := vname;
      end else
      begin
        oldOya[0] := vname;
      end;

      // 生成
      pm := nako_getVariable(PAnsiChar(vname));
      //
      //nako_eval_str('!' + vname + 'とはメニュー。'#13#10+vname+'を作る。');
      if pm = nil then pm := hi_var_new(vname);
      pmenu := nako_getVariable('メニュー');
      nako_varCopyData(pmenu, pm);
      nako_group_exec(pm, '作');

      pm_obj := nako_getGroupMember(PAnsiChar(vname), 'オブジェクト');
      if pm_obj = nil then begin
        raise Exception.Create(
                'システムエラー.メニュー"' +
                string(vname)+
                '"のポインタが取得できません。');
      end;
      if not (TComponent(hi_int(pm_obj)) is TMenuItem) then
        raise Exception.Create(
                'システムエラー.メニュー"'+
                string(vname)+
                '"のポインタが取得できません。');

      mnu := TMenuItem(hi_int(pm_obj));
      mnu.Caption := string(cap);
      mnu.OnClick := Bokan.eventClick;
      with GuiInfos[mnu.Tag] do begin
        name     := vname;
        pgroup   := pm;
      end;

      if scut <> '' then mnu.ShortCut := TextToShortCut(string(scut));
      // option
      if opt = 'チェック' then TMenuItem(mnu).Checked := True;

      // イベントの定義
      if event <> '' then
      begin
        try
          nako_eval_str(vname+'のクリックした時は～'+event);
        except on e: Exception do
          raise Exception.Create('"'+string(vname)+'"のイベントの設定エラー。' + e.Message);
        end;
      end;

      // 追加
      if oya = '' then
      begin
        if Menu is TMainMenu then
        begin
          if Bokan.Menu = nil then Bokan.Menu := TMainMenu.Create(Bokan);
        end;
        menu.Items.Add(mnu);
      end else
      begin
        po := nako_getVariable(PAnsiChar(oya));
        if po = nil then
          raise Exception.Create(
                  string(oya) + 'は未定義です。'
          );

        po := nako_getGroupMember(PAnsiChar(oya), 'オブジェクト');
        opo := TComponent(hi_int(po));
        if opo is TMainMenu then
          TMainMenu(opo).Items.Add(mnu)
        else
          TMenuItem(opo).Add(mnu);
      end;

    end;
  finally
    csv.Free;
  end;

end;


function vcl_menus(h: DWORD): PHiValue; stdcall;
var ps: PHiValue;
begin
  // (1) 引数の取得
  ps := nako_getFuncArg(h, 0);

  // (2) 処理
  if Bokan.Menu = nil then Bokan.Menu := TMainMenu.Create(Bokan);
  sub_menus(ps, Bokan.Menu);

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function vcl_popupmenus(h: DWORD): PHiValue; stdcall;
var ps, po: PHiValue;
begin
  // (1) 引数の取得
  po := nako_getFuncArg(h, 0);
  ps := nako_getFuncArg(h, 1);

  // (2) 処理
  sub_menus(ps, TPopupMenu(getGui(po)));

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

procedure sub_treenode_add(pobj, ps: PHiValue; FlagClear: Boolean);
var
  o: TObject;
begin
  o := getGui(pobj);
  CsvToTree(o as THiTreeView, hi_strU(ps), FlagClear);
end;

function vcl_treenode(h: DWORD): PHiValue; stdcall;
var
  pobj, ps: PHiValue;
begin
  pobj := nako_getFuncArg(h, 0);
  ps   := nako_getFuncArg(h, 1);
  sub_treenode_add(pobj, ps, True);
  Result := nil; // 何も返さない場合は nil
end;

function vcl_treenode_add(h: DWORD): PHiValue; stdcall;
var
  pobj, ps: PHiValue;
begin
  pobj := nako_getFuncArg(h, 0);
  ps   := nako_getFuncArg(h, 1);
  sub_treenode_add(pobj, ps, False);
  Result := nil; // 何も返さない場合は nil
end;

procedure sub_listview_add(pobj, ps: PHiValue; FlagClear: Boolean);
var
  csv: TCsvSheet;
  i: Integer;

  //親部品名,部品名,テキスト,画像番号
  oya, vname, text, pic: AnsiString;

  tn, oya_tn: TListItem;
  tv: THiListView;

  n: THPtrHashItem;
begin
  tv := THiListView(getGui(pobj));

  if FlagClear then
  begin
    tv.Items.Clear;
    tv.nodes.Clear;
  end;

  csv := TCsvSheet.Create;
  try
    csv.AsText := hi_str(ps);
    for i := 0 to csv.Count - 1 do
    begin
      oya   := csv.Cells[0,i];
      vname := csv.Cells[1,i]; if vname = '' then Continue;
      text  := csv.Cells[2,i];
      pic   := csv.Cells[3,i];

      // 親の検索
      if oya <> '' then n := THPtrHashItem( tv.nodes.Items[oya] ) else n := nil;
      if n <> nil then oya_tn := TListItem( n.ptr ) else oya_tn := nil;

      // 追加
      if oya_tn = nil then
      begin
        tn := tv.Items.Add;
        tn.Caption := string(text);
      end else
      begin
        oya_tn.SubItems.Add(string(text));
        tn := oya_tn;
      end;

      n := THPtrHashItem.Create;
      n.Key := vname;
      n.Ptr := tn;

      // カスタマイズ
      tn.ImageIndex    := StrToIntDefA(pic,-1);
    end;
  finally
    csv.Free;
  end;
end;

function vcl_listview(h: DWORD): PHiValue; stdcall;
var
  pobj, ps: PHiValue;
begin
  pobj := nako_getFuncArg(h, 0);
  ps   := nako_getFuncArg(h, 1);
  sub_listview_add(pobj, ps, True);
  Result := nil; // 何も返さない場合は nil
end;


function vcl_listview_add(h: DWORD): PHiValue; stdcall;
var
  pobj, ps: PHiValue;
begin
  pobj := nako_getFuncArg(h, 0);
  ps   := nako_getFuncArg(h, 1);
  sub_listview_add(pobj, ps, False);
  Result := nil; // 何も返さない場合は nil
end;

function vcl_toolbutton(h: DWORD): PHiValue; stdcall;
var
  p, pobj,ps, pm, btn_group, ptoolbtn: PHiValue;

  csv: TCsvSheet;
  i: Integer;

  //部品名,画像番号,種類,イベント
  vname, ino, itype, hint, event: AnsiString;

  btn: TToolButton;
  toolbar: TToolBar;

begin
  // (1) 引数の取得
  pobj := nako_getFuncArg(h, 0);
  ps   := nako_getFuncArg(h, 1);

  p := nako_group_findMember(pobj, 'オブジェクト');
  if p = nil then raise Exception.Create('ツールボタンを特定できません。');
  toolbar := TToolBar(Integer(hi_int(p)));
  //toolbar.Visible := False;


  // (2) 処理
  csv := TCsvSheet.Create;
  try
    csv.AsText := hi_str(ps);
    for i := 0 to csv.Count - 1 do
    begin
      vname := csv.Cells[0,i]; if vname = '' then Continue;
      ino   := csv.Cells[1,i];
      itype := csv.Cells[2,i];
      hint  := csv.Cells[3,i];
      event := csv.Cells[4,i];

      // 生成
      // nako_eval_str('!' + vname + 'とはツールボタン。'#13#10+vname+'を作る。');
      btn_group := nako_getVariable(PAnsiChar(vname));
      if btn_group = nil then btn_group := nako_var_new(PAnsiChar(vname));
      //
      ptoolbtn := nako_getVariable('ツールボタン');
      nako_varCopyData(ptoolbtn, btn_group);
      nako_group_exec(btn_group, '作');
      pm := nako_group_findMember(btn_group, 'オブジェクト');

      if pm = nil then raise Exception.Create('システムエラー.ツールボタン'+string(vname)+'のポインタが取得できません。');

      btn := TToolButton(hi_int(pm));
      btn.ImageIndex := StrToIntDefA(ino, -1);
      if hint <> '' then begin
        btn.Hint := string(hint);
        btn.ShowHint := True;
      end;
      btn.Left := i * toolbar.ButtonWidth;
      btn.OnClick := bokan.eventClick;
      with GuiInfos[btn.Tag] do begin
        name := vname;
        pgroup := btn_group;
        name_id := nako_tango2id(PAnsiChar(vname));
      end;

      if (itype = '')or(itype='ボタン') then
      begin
        btn.Style := tbsButton;
      end else
      if itype = '区切り' then
      begin
        btn.Style := tbsDivider;
        btn.Width := 8;
      end;

      // イベントの定義
      if event <> '' then
        nako_eval_str(vname+'のクリックした時は～'+event);

      // 追加
      try
        btn.Parent := toolbar;
        btn.Visible := True;
      except
        raise Exception.Create('システムエラーでボタンをツールバーに追加できません。');
      end;
    end;
  finally
    csv.Free;
  end;
  //toolbar.Visible := True;

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;


type
  PEnumRec = ^TEnumRec;
  TEnumRec = record
    Pattern: AnsiString;
    result: HWND;
  end;

function EnumWindowsProc(h: HWND; lp: LPARAM): BOOL; stdcall;
var
  p: PEnumRec;
  s: AnsiString;
  len: Integer;
begin
  Result := True;
  p   := PEnumRec(lp);
  len := GetWindowTextLength(h);
  if len = 0 then Exit;

  // set text
  SetLength(s, len+1);
  GetWindowText(h, @s[1], len+1);
  s := PAnsiChar(s);

  // match ?
  if MatchesMask(string(s), string(p^.Pattern)) then
  begin
    Result := False;
    p^.result := h;
  end else
  if (Copy(s, 1, Length(p^.Pattern)) = p^.Pattern) then
  begin
    Result := False;
    p^.result := h;
  end;
end;

// 失敗すれば INVALID_HANDLE_VALUE を返す
function MyFindWindow(title: AnsiString): HWND;
var
  EnumRec: TEnumRec;
begin
  // setting
  EnumRec.Pattern := title;
  EnumRec.result  := INVALID_HANDLE_VALUE;
  // find
  EnumWindows(@EnumWindowsProc, Integer(@EnumRec));
  // return result
  Result := EnumRec.result;
end;

function cmd_captureHandle(h: DWORD): PHiValue; stdcall;
var
  pobj, ps: PHiValue;
  obj: TObject;
  title: AnsiString;
  target: THandle;
  dc: HDC;
  c: TCanvas;
  r: TRect;
  ww, hh: Integer;
begin
  // ---
  pobj := nako_getFuncArg(h, 0);
  ps   := nako_getFuncArg(h, 1);
  // ---
  obj    := getGui(pobj);
  title  := hi_str(ps);
  //
  target := StrToIntDefA(hi_str(ps), 0);
  if target = 0 then target := GetDesktopWindow;
  if IsWindow(target) then
  if BringWindowToTop(target) then
  begin
    Application.ProcessMessages;
    sleep(256); // 適当にsleep して画面が真っ白になるのを防ぐ
  end;
  //
  GetWindowRect(target, r);
  ww := r.Right - r.Left;
  hh := r.Bottom - r.Top;
  //
  if obj is TImage then
  begin
    TImage(obj).Width  := ww;
    TImage(obj).Height := hh;
    c := TImage(obj).Canvas;
  end else
  begin
    c := getCanvasFromObj(obj);
  end;
  //
  dc := GetWindowDC(Target);
  BitBlt(c.Handle, 0, 0, ww, hh, dc, 0, 0, SRCCOPY);
  ReleaseDC(Target, dc);
  Result := nil;
end;

function cmd_capture(h: DWORD): PHiValue; stdcall;
var
  pobj, ps: PHiValue;
  obj: TObject;
  title: AnsiString;
  target: THandle;
  dc: HDC;
  c: TCanvas;
  r: TRect;
  ww, hh: Integer;
begin
  // ---
  pobj := nako_getFuncArg(h, 0);
  ps   := nako_getFuncArg(h, 1);
  // ---
  obj    := getGui(pobj);
  title  := hi_str(ps);
  //
  if title = 'デスクトップ' then
  begin
    target := GetDesktopWindow;
  end else
  begin
    target := MyFindWindow(Title);
    if target = INVALID_HANDLE_VALUE then target := GetDesktopWindow;
    if BringWindowToTop(target) then
    begin
      Application.ProcessMessages;
      sleep(256); // 適当にsleep して画面が真っ白になるのを防ぐ
    end;
  end;
  //
  GetWindowRect(target, r);
  ww := r.Right - r.Left;
  hh := r.Bottom - r.Top;
  //
  if obj is TImage then
  begin
    TImage(obj).Width  := ww;
    TImage(obj).Height := hh;
    c := TImage(obj).Canvas;
  end else
  begin
    c := getCanvasFromObj(obj);
  end;
  //
  dc := GetWindowDC(Target);
  BitBlt(c.Handle, 0, 0, ww, hh, dc, 0, 0, SRCCOPY);
  ReleaseDC(Target, dc);
  Result := nil;
end;


function cmd_captureClient(h: DWORD): PHiValue; stdcall;
var
  pobj, ps: PHiValue;
  obj: TObject;
  title: AnsiString;
  target: THandle;
  dc: HDC;
  c: TCanvas;
  r: TRect;
  ww, hh: Integer;
begin
  // ---
  pobj := nako_getFuncArg(h, 0);
  ps   := nako_getFuncArg(h, 1);
  // ---
  obj    := getGui(pobj);
  title  := hi_str(ps);
  //
  if title = 'デスクトップ' then
  begin
    target := GetDesktopWindow;
  end else
  begin
    target := MyFindWindow(Title);
    if target = INVALID_HANDLE_VALUE then target := GetForegroundWindow;
    if BringWindowToTop(target) then
    begin
      Application.ProcessMessages;
      sleep(256); // 適当にsleep して画面が真っ白になるのを防ぐ
      Application.ProcessMessages;
    end;
  end;
  //
  if target <> 0 then
    GetClientRect(target, r)
  else
    GetWindowRect(target, r);
  //
  ww := r.Right - r.Left;
  hh := r.Bottom - r.Top;
  //
  if obj is TImage then
  begin
    TImage(obj).Width  := ww;
    TImage(obj).Height := hh;
    c := TImage(obj).Canvas;
  end else
  begin
    c := getCanvasFromObj(obj);
  end;
  //
  dc := GetDC(Target);
  BitBlt(c.Handle, 0, 0, ww, hh, dc, 0, 0, SRCCOPY);
  ReleaseDC(Target, dc);
  Result := nil;
end;


function cmd_extractIcon(h: DWORD): PHiValue; stdcall;
var
  icon: TIcon;
  fname: AnsiString;
  obj: TCanvas;
  no: Integer;
begin
  // OBJへFのNOを
  obj   := getCanvas(nako_getFuncArg(h, 0));
  fname := getArgStr(h, 1);
  no    := getArgInt(h, 2);
  //
  icon := TIcon.Create;
  try
    icon.Handle := ExtractIconA(hInstance, PAnsiChar(fname), no);
    DrawIconEx(
        obj.Handle,
        0, 0, icon.Handle, icon.Width, icon.Height,
        0, 0, DI_NORMAL);
  finally
    icon.Free;
  end;
  //
  Result := nil;
end;

function cmd_extractIconCount(h: DWORD): PHiValue; stdcall;
var
  fname: AnsiString;
begin
  fname := getArgStr(h, 0);
  Result := hi_newInt(Integer(ExtractIconA(hInstance, PAnsiChar(fname), UINT(-1))));
end;


function cmd_getCharW(h: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
begin
  ps := nako_getFuncArg(h, 0);
  getFont(Bokan.BackCanvas);
  Result := hi_newInt(Bokan.BackCanvas.TextWidth(hi_strU(ps)));
end;

function cmd_getCharH(h: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
begin
  ps := nako_getFuncArg(h, 0);
  getFont(Bokan.BackCanvas);
  Result := hi_newInt(Bokan.BackCanvas.TextHeight(hi_strU(ps)));
end;

//------------------------------------------------------------------------------

// なでしこに必要な関数を追加する
procedure RegistCallbackFunction(bokanHandle: Integer);

  procedure _init_font;
  begin
    baseX         := nako_getVariable('基本X');
    baseY         := nako_getVariable('基本Y');
    baseFont      := nako_getVariable('文字書体');
    baseFontSize  := nako_getVariable('文字サイズ');
    baseFontColor := nako_getVariable('文字色');
    penColor      := nako_getVariable('線色');
    brushColor    := nako_getVariable('塗り色');
    penWidth      := nako_getVariable('線太さ');
    penStyle      := nako_getVariable('線スタイル');
    brushStyle    := nako_getVariable('塗りスタイル');
    tabCount      := nako_getVariable('タブ数');
    baseInterval  := nako_getVariable('部品間隔');
    printLog      := nako_getVariable('表示ログ');
  end;

begin
  //todo 0: ●システム命令追加
  //<VNAKO命令>
  //+描画関連(vnako)
  //-描画属性
  AddIntVar('基本X',        10, 2000, '描画用基本座標のX','きほんX');
  AddIntVar('基本Y',        10, 2001, '描画用基本座標のY','きほんY');
  AddStrVar('文字書体',     'ＭＳ ゴシック', 2002,'描画用基本フォント','もじしょたい');
  AddIntVar('文字サイズ',   10, 2003, '描画用基本フォントサイズ','もじさいず');
  AddIntVar('文字色',        0, 2009, '描画用基本フォント色','もじいろ');
  AddIntVar('線太さ',        3, 2004, '図形の縁の線の太さ','せんふとさ');
  AddIntVar('線色',          0, 2005, '図形の縁の線の色','せんいろ');
  AddIntVar('塗り色',        0, 2006, '図形の塗り色','ぬりいろ');
  AddStrVar('線スタイル',    '実線', 2007, '図形の縁の線のスタイル。文字列で指定。「実線|点線|破線|透明」','せんすたいる');
  AddStrVar('塗りスタイル',  'べた', 2008, '図形の塗りスタイル。文字列で指定。「べた|透明|格子(十字線)|縦線|横線|右斜め線|左斜め線|斜め十字線」','ぬりすたいる');
  AddIntVar('タブ数',        4, 2010, '文字表示時にタブを何文字で展開するか。','たぶすう');
  AddIntVar('部品間隔',      8, 2011, '部品の配置間隔','ぶひんかんかく');
  AddIntVar('イベント部品',0, 2012, 'イベントが発生したときに設定される。','いべんとぶひん');
  AddIntVar('JPEG圧縮率',    80, 2013, 'JPEG画像を保存する時の圧縮率','JPEGあっしゅくりつ');

  //-描画命令
  AddFunc('表示',       '{=?}Sを|Sと',                     2100,cmd_print,    '画面に文字列Sを表示する', 'ひょうじ');
  AddFunc('画面クリア', '{グループ=?}OBJを{整数=$FFFFFF}RGBで',2101,cmd_cls,      '画面をカラーコード($RRGGBB)でクリアする。RGBを省略は白色。OBJの省略は母艦のオブジェクト。','がめんくりあ');
  AddFunc('移動',       'X,Yへ',                           2102,cmd_move,     '描画の基本座標をX,Yに変更する。','いどう');
  AddFunc('MOVE',       'X,Yへ',                           2103,cmd_move,     '描画の基本座標をX,Yに変更する','MOVE');
  AddFunc('線',         '{グループ=?}OBJのX1,Y1からX2,Y2へ',       2104,cmd_line,     '画面に線を引く。OBJの省略は母艦。','せん');
  AddFunc('LINE',       '{グループ=?}OBJ,X1,Y1,X2,Y2',             2105,cmd_line,     '画面に線を引く。OBJの省略は母艦。','LINE');
  AddFunc('四角',       '{グループ=?}OBJのX1,Y1からX2,Y2へ',       2106,cmd_rectangle,'画面に長方形を描く。OBJの省略は母艦。','しかく');
  AddFunc('BOX',        '{グループ=?}OBJ,X1,Y1,X2,Y2',             2107,cmd_rectangle,'画面に長方形を描く。OBJの省略は母艦。','BOX');
  AddFunc('円',         '{グループ=?}OBJのX1,Y1からX2,Y2へ',       2108,cmd_circle,   '画面に円を描く。','えん');
  AddFunc('CIRCLE',     '{グループ=?}OBJ,X1,Y1,X2,Y2',             2109,cmd_circle,   '画面に円を描く。','CIRCLE');
  AddFunc('角丸四角',   '{グループ=?}OBJのX1,Y1からX2,Y2へX3,Y3で',2110,cmd_roundrect,'画面に角の丸い長方形を描く。X3,Y3には丸の度合いを指定。','かどまるしかく');
  AddFunc('ROUNDBOX',   '{グループ=?}OBJ,X1,Y1,X2,Y2,X3,Y3',       2111,cmd_roundrect,'画面に角の丸い長方形を描く。X3,Y3には丸の度合いを指定。','ROUNDBOX');
  AddFunc('多角形',     '{グループ=?}OBJのSへ|OBJにSで',           2112,cmd_poly,     '画面に多角形を描く。Sには座標の一覧を文字列で与える。例)「10,10,10,20,20,20」','たかっけい');
  AddFunc('POLY',       '{グループ=?}OBJ,S',                       2113,cmd_poly,     '画面に多角形を描く。Sには座標の一覧を文字列で与える。例)「10,10,10,20,20,20」','POLY');
  AddFunc('画像表示',   '{=?}X,{=?}YへSを',                2114,cmd_loadPic,  'ファイルSの画像を表示する。','がぞうひょうじ');
  AddFunc('画像描画',   '{グループ=?}OBJのX,YへSを',               2115,cmd_loadPic2, 'オブジェクトOBJのX,YへファイルSの画像を表示する。','がぞうびょうが');
  AddFunc('文字描画',   '{グループ=?}OBJのX,YへSを',               2116,cmd_textout,  'オブジェクトOBJのX,Yへ文字Sをアンチエイリアス描画する。','もじびょうが');
  AddFunc('文字表示',   '{グループ=?}OBJのX,YへSを',               2117,cmd_textout2, 'オブジェクトOBJのX,Yへ文字Sを描画する。（アンチエイリアスしない）','もじひょうじ');
  AddFunc('文字遅延描画','{グループ=?}OBJのX,YへSを{数値=200}Aで', 2118,cmd_textoutDelay,  'オブジェクトOBJのX,Yへ文字Sを遅延Aミリ秒で描画する。','もじちえんびょうが');
  AddFunc('窓キャプチャ','{グループ=?}OBJへSを', 2119, cmd_capture,  'タイトルがSのウィンドウをキャプチャしてオブジェクトOBJへ描画する。Sに「デスクトップ」を指定することも可能。','まどきゃぷちゃ');
  AddFunc('文字遅延表示','{グループ=?}OBJのX,YへSを{数値=200}Aで', 2124,cmd_textoutDelayNoneAlias,  'オブジェクトOBJのX,Yへ文字Sを遅延Aミリ秒で描画する。(アンチエイリアスなし)','もじちえんひょうじ');
  AddFunc('窓ハンドルキャプチャ','{グループ=?}OBJへHを', 2129, cmd_captureHandle,  'ハンドルがHのウィンドウをキャプチャしてオブジェクトOBJへ描画する。','まどはんどるきゃぷちゃ');
  AddStrVar('表示ログ','',2120,'画面に表示した文字列のログを保持する', 'ひょうじろぐ');
  AddFunc('文字幅取得',  '{=?}Sの', 2121,cmd_getCharW, '文字列Sの文字幅を取得して返す', 'もじはばしゅとく');
  AddFunc('文字高さ取得','{=?}Sの', 2122,cmd_getCharH, '文字列Sの文字高さを取得して返す', 'もじたかさしゅとく');
  AddFunc('窓内側キャプチャ','{グループ=?}OBJへSを', 2123, cmd_captureClient,  'タイトルがSのウィンドウの内側をキャプチャしてオブジェクトOBJへ描画する。','まどうちがわきゃぷちゃ');
  AddFunc('アイコン抽出','{グループ=?}OBJへFのNOを', 2125, cmd_extractIcon, 'ファイルFのNO番目(0～)のアイコンを取り出してOBJへ描画する。','あいこんちゅうしゅつ');
  AddFunc('アイコン数取得','Fの', 2126, cmd_extractIconCount, 'ファイルFの持っているアイコン数を返す。','あいこんすうしゅとく');
  AddFunc('点描画',      '{グループ=?}OBJのX,YへCを', 2127,cmd_pset, 'X,Yへ色コードCを点を描画する','てんびょうが');
  AddFunc('点取得',      '{グループ=?}OBJのX,Yを|Yの',2128,cmd_pget, 'X,Yの色コードを取得する','てんしゅとく');
  AddFunc('継続表示',    '{=?}Sを|Sと',               2099,cmd_print_continue, '画面に文字列Sを表示する(改行しない)', 'けいぞくひょうじ');
  AddFunc('塗る',        '{グループ=?}OBJのX,YをCOLORで{=$FF000000}BORDERまで', 2164,cmd_ExtFloodFill, 'X,Yから全方向に境界線色BORDERまでCOLORの色で塗り潰す。BORDERを省略したときはX,Yの座標の色と同じ色の範囲を塗り潰す。', 'ぬる');

  //-画像処理
  AddFunc('画像モザイク',   '{グループ}OBJにAの|OBJへ',              2130,cmd_mosaic,   'イメージOBJにAピクセルのモザイクをかける', 'がぞうもざいく');
  AddFunc('画像ボカシ',     '{グループ}OBJにAの|OBJへ',              2131,cmd_blur,     'イメージOBJに強度A(1～20)のボカシをかける', 'がぞうぼかし');
  AddFunc('画像シャープ',   '{グループ}OBJにAの|OBJへ',              2132,cmd_sharp,    'イメージOBJに強度A(1～20)のシャープをかける', 'がぞうしゃーぷ');
  AddFunc('画像ネガポジ',   '{グループ}OBJを',                       2133,cmd_negaposi, 'イメージOBJのネガポジを反転させる', 'がぞうねがぽじ');
  AddFunc('画像モノクロ',   '{グループ}OBJをAで',                    2134,cmd_mono,     'イメージOBJをレベルA(0-255)でモノクロ化する', 'がぞうものくろ');
  AddFunc('画像ソラリゼーション', '{グループ}OBJを',                 2135,cmd_solarization,'イメージOBJをソラリゼーションする', 'がぞうそらりぜーしょん');
  AddFunc('画像グレイスケール',   '{グループ}OBJを',                 2136,cmd_grayscale,'イメージOBJをグレイスケール化する', 'がぞうぐれいすけーる');
  AddFunc('画像ガンマ補正',       '{グループ}OBJをAで',              2137,cmd_gamma,    'イメージOBJをレベルA(実数)でガンマ補正する', 'がぞうがんまほせい');
  AddFunc('画像コントラスト',     '{グループ}OBJをAで',              2138,cmd_contrast, 'イメージOBJをレベルAでコントラストを修正する', 'がぞうこんとらすと');
  AddFunc('画像明度補正',         '{グループ}OBJをAで',              2139,cmd_bright,   'イメージOBJをレベルAで明度補正する', 'がぞうめいどほせい');
  AddFunc('画像ノイズ',           '{グループ}OBJをAで',              2140,cmd_noise,    'イメージOBJをレベルAでノイズを混ぜる', 'がぞうのいず');
  AddFunc('画像セピア',           '{グループ}OBJをAで',              2141,cmd_sepia,    'イメージOBJをカラーAでセピア化する', 'がぞうせぴあ');
  AddFunc('画像右回転',           '{グループ}OBJを',                 2142,cmd_pic90r,   'イメージOBJを右回転させる', 'がぞうみぎかいてん');
  AddFunc('画像左回転',           '{グループ}OBJを',                 2143,cmd_pic90l,   'イメージOBJを左回転させる', 'がぞうひだりかいてん');
  AddFunc('画像回転',             '{グループ}OBJをAで',              2161,cmd_picRotate,    'イメージOBJをA度回転させる。', 'がぞうかいてん');
  AddFunc('画像高速回転',         '{グループ}OBJをAで',              2166,cmd_picRotateFast,'イメージOBJをA度回転させる。', 'がぞうこうそくかいてん');
  AddFunc('画像垂直反転',         '{グループ}OBJを',                 2144,cmd_VertRev,  'イメージOBJを垂直反転させる', 'がぞうすいちょくはんてん');
  AddFunc('画像水平反転',         '{グループ}OBJを',                 2145,cmd_HorzRev,  'イメージOBJを水平反転させる', 'がぞうすいへいはんてん');
  AddFunc('画像リサイズ',         '{グループ}OBJをW,Hで|Hへ',        2146,cmd_Resize,   'イメージOBJをW,Hのサイズへ変更する', 'がぞうりさいず');
  AddFunc('画像コピー',           '{グループ}OBJ1を{グループ}OBJ2のX,Yへ',     2147,cmd_img_copy, 'イメージOBJ1をイメージOBJ2のX,Yへコピーする。', 'がぞうこぴー');
  AddFunc('画像部分コピー',       '{グループ}OBJ1のX,Y,W,Hを{グループ}OBJ2のX2,Y2へ', 2148,cmd_img_copyEx, 'イメージOBJ1のX,Y,W,HをイメージOBJ2のX,Yへコピーする。', 'がぞうぶぶんこぴー');
  AddFunc('画像ビット数変更',     '{グループ}OBJをAに', 2149, cmd_img_bit, 'イメージOBJの画像色ビット数をA(1/4/8/15/16/24/32)ビットに変更する。', 'がぞうびっとすうへんこう');
  AddFunc('画像保存',             '{グループ}OBJをSに|Sへ', 2150, cmd_img_save, 'イメージOBJの画像をSへ保存する', 'がぞうほぞん');
  AddFunc('画像半透明コピー',     '{グループ}OBJ1を{グループ}OBJ2のX,YへAで', 2151, cmd_img_alphaCopy, 'イメージOBJ1をOBJ2のX,Yへ画像を透明度Ａ％でコピーする', 'がぞうはんとうめいこぴー');
  AddFunc('画像マスク作成',       '{グループ}OBJをCで', 2152, cmd_img_mask, 'イメージOBJを透明色Cでマスクを作る', 'がぞうますくさくせい');
  AddFunc('画像ANDコピー',        '{グループ}OBJ1を{グループ}OBJ2のX,Yへ',     2153,cmd_img_copyAnd, 'イメージOBJ1をイメージOBJ2のX,YへANDコピーする。マスク画像を重ねるのに使う。', 'がぞうANDこぴー');
  AddFunc('画像ORコピー',         '{グループ}OBJ1を{グループ}OBJ2のX,Yへ',     2154,cmd_img_copyOr, 'イメージOBJ1をイメージOBJ2のX,YへORコピーする。', 'がぞうORこぴー');
  AddFunc('画像XORコピー',        '{グループ}OBJ1を{グループ}OBJ2のX,Yへ',     2155,cmd_img_copyXOR, 'イメージOBJ1をイメージOBJ2のX,YへXORコピーする。', 'がぞうXORこぴー');
  AddFunc('画像色取得',           '{グループ=?}OBJのX,Yを|Yから', 2156,cmd_img_getC, 'イメージOBJのX,Yにある色番号を取得する。', 'がぞういろしゅとく');
  AddFunc('画像色置換',           '{グループ=?}OBJのAをBに|AからBへ',2157,cmd_img_change, 'イメージOBJの色Aを色Bに置換します。', 'がぞういろちかん');
  AddFunc('画像線画変換',         '{グループ=?}OBJを|OBJへ',2158,cmd_img_linePic, 'イメージOBJの画像を線画に変換', 'がぞうせんがへんかん');
  AddFunc('画像エッジ変換',       '{グループ=?}OBJを|OBJへ',2159,cmd_img_edge, 'イメージOBJの画像をエッジに変換', 'がぞうえっじへんかん');
  AddFunc('画像合成',             '{グループ=?}OBJ1を{グループ}OBJ2のX,Yへ|Yに',2160,cmd_img_gousei, 'イメージOBJ1をOBJ2のX,Yへ合成します。OBJ1の左上の色を透過色として扱う。', 'がぞうごうせい');
  AddFunc('画像比率変えずリサイズ','{グループ}OBJをW,Hで|Hへ',        2162,cmd_ResizeAspect,   'イメージOBJをW,Hのサイズへ縦横比率を保持して変更する', 'がぞうひりつかえずりさいず');
  AddFunc('画像高速リサイズ',      '{グループ}OBJをW,Hで|Hへ',        2163,cmd_ResizeSpeed,    'イメージOBJをW,Hのサイズへ高速に変更する。(画像リサイズより画質が落ちる。)', 'がぞうこうそくりさいず');
  AddFunc('画像比率変えず中央リサイズ','{グループ}OBJをW,Hで|Hへ',    2165,cmd_ResizeAspectEx, 'イメージOBJをW,Hのサイズへ縦横比率を保持して変更しW,Hの中央へ描画する。余白は「塗色」の色が適用される。', 'がぞうひりつかえずちゅうおうりさいず');

  //-デスクトップ
  AddIntVar('デスクトップX', Screen.WorkAreaLeft, 2170, 'デスクトップのワークエリアのX','ですくとっぷX');
  AddIntVar('デスクトップY', Screen.WorkAreaTop, 2171, 'デスクトップのワークエリアのY','ですくとっぷY');
  AddIntVar('デスクトップW', Screen.DesktopWidth, 2172, 'デスクトップの幅','ですくとっぷW');
  AddIntVar('デスクトップH', Screen.DesktopHeight, 2173, 'デスクトップの高さ','ですくとっぷH');
  AddIntVar('デスクトップワークエリアW', Screen.WorkAreaWidth, 2174, 'デスクトップのワークエリアの幅','ですくとっぷわーくえりあW');
  AddIntVar('デスクトップワークエリアH', Screen.WorkAreaHeight, 2175, 'デスクトップのワークエリアの高さ','ですくとっぷわーくえりあH');
  AddFunc('フォント一覧取得','', 2176, cmd_getFonts, 'フォントの一覧を取得', 'ふぉんといちらんしゅとく');

  //+GUI関連(vnako)
  //-GUI部品
  // AddIntVar('ボタン',   0, 6000, '(GUI部品)','ぼたん');
  // AddIntVar('エディタ', 0, 6001, '(GUI部品)','えでぃた');
  // AddIntVar('メモ',     0, 6002, '(GUI部品)','めも');
  // AddIntVar('リスト',   0, 6003, '(GUI部品)','りすと');
  // AddIntVar('コンボ',   0, 6004, '(GUI部品)','こんぼ');
  // AddIntVar('バー',     0, 6005, '(GUI部品)','ばー');
  // AddIntVar('パネル',   0, 6006, '(GUI部品)','ぱねる');
  // AddIntVar('チェック', 0, 6007, '(GUI部品)','ちぇっく');
  // AddIntVar('ラジオ',   0, 6008, '(GUI部品)','らじお');
  // AddIntVar('グリッド', 0, 6009, '(GUI部品)','ぐりっど');
  // AddIntVar('イメージ', 0, 6010, '(GUI部品)','いめーじ');
  // AddIntVar('ラベル',   0, 6011, '(GUI部品)','らべる');
  // AddIntVar('メニュー', 0, 6012, '(GUI部品)','めにゅー');
  // AddIntVar('タブページ', 0, 6013, '(GUI部品)','たぶぺーじ');
  // AddIntVar('カレンダー', 0, 6014, '(GUI部品)','かれんだー');
  // AddIntVar('ツリー', 0, 6015, '(GUI部品)','つりー');
  // AddIntVar('リストビュー', 0, 6016, '(GUI部品)','りすとびゅー');
  // AddIntVar('ステータスバー', 0, 6017, '(GUI部品)','すてーたすばー');
  // AddIntVar('ツールバー', 0, 6018, '(GUI部品)','つーるばー');
  // AddIntVar('タイマー', 0, 6019, '(GUI部品)','たいまー');
  // AddIntVar('ブラウザ', 0, 6020, '(GUI部品)','ぶらうざ');
  // AddIntVar('スピンエディタ', 0, 6021, '(GUI部品)','すぴんえでぃた');
  // AddIntVar('トラック', 0, 6022, '(GUI部品)','とらっく');
  // AddIntVar('Tエディタ', 0, 6023, '(GUI部品)','Tえでぃた');
  // AddIntVar('プロパティエディタ', 0, 6025, '(GUI部品)','ぷろぱてぃえでぃた');
  // AddIntVar('フォーム', 0, 6026, '(GUI部品)','ふぉーむ');
  // AddIntVar('メインメニュー', 0, 6027, '(GUI部品)','めいんめにゅー');
  // AddIntVar('ポップアップメニュー', 0, 6028, '(GUI部品)','ぽっぷあっぷめにゅー');
  // AddIntVar('スプリッタ', 0, 6029, '(GUI部品)','すぷりった');
  // AddIntVar('イメージリスト', 0, 6030, '(GUI部品)','いめーじりすと');
  // AddIntVar('ツールボタン', 0, 6031, '(GUI部品)','つーるぼたん');
  // AddIntVar('アニメ', 0, 6033, '(GUI部品)','あにめ');
  // AddIntVar('画像ボタン', 0, 6034, '(GUI部品)','がぞうぼたん');
  // AddIntVar('スクロールパネル', 0, 6035, '(GUI部品)','すくろーるぱねる');

  //-イベント
  AddIntVar('インスタンスハンドル', HInstance,      2200, 'インスタンスハンドル', 'いんすたんすはんどる');
  AddIntVar('母艦ハンドル',         bokanHandle,    2201, '母艦のウィンドウハンドル','ぼかんはんどる');
  AddIntVar('母艦オブジェクト',     Integer(Bokan), 2202, '母艦オブジェクト','ぼかんおぶじぇくと');
  AddFunc  ('待機',         '', 2203, cmd_stop,          'プログラムの実行を止めイベントを待つ。','たいき');
  AddFunc  ('終わる',       '', 2204, cmd_closeWindow,   '母艦を閉じてプログラムの実行を終了させる。','おわる');//メソッドの上書き
  AddFunc  ('おわり',       '', 2205, cmd_closeWindow,   '母艦を閉じてプログラムの実行を終了させる。','おわり');//メソッドの上書き
  AddFunc  ('描画処理反映', '{グループ=?}OBJを|OBJの', 2206, cmd_reflesh, 'GUI部品OBJへそれまでに描画した内容を反映させる。OBJ省略時は母艦。','びょうがしょりはんえい');
  AddFunc  ('母艦再描画',   '', 2207, cmd_redraw,        '描画処理反映よりも負担の少ない再描画を行う','ぼかんさいびょうが');
  AddFunc  ('秒待つ',       '{=?}A', 2209, cmd_sleep,    'A秒間実行を止める。','びょうまつ');
  AddFunc  ('終了',         '',      2210, cmd_closeWindow, '母艦を閉じてプログラムの実行を終了させる。','しゅうりょう');//メソッドの上書き
  AddFunc  ('キー状態', 'Aで|Aの',   2211, cmd_keyState, 'キーコードAの状態を調べ、オンかオフを返す。','きーじょうたい');
  AddIntVar('アプリケーションハンドル', Application.Handle, 2212, 'アプリケーションのウィンドウハンドル','あぷりけーしょんはんどる');

  //-VCL関連
  AddFunc('デフォルト親部品設定', '{グループ}OBJに|OBJへ|OBJを', 2318, vcl_setDefaultParentObj, '基準となる親部品を指定する', 'でふぉるとおやぶひんせってい');
  AddFunc('VCL_CREATE', '{グループ}A,NAME,TYPE', 2300, vcl_create, 'VCL GUI部品を作成','VCL_CREATE');
  AddFunc('VCL_GET','OBJ,PROP',   2301, vcl_getprop, 'VCL GUI部品のプロパティを取得(OBJにはGUIオブジェクトを直接指定)','VCL_GET');
  AddFunc('VCL_SET','OBJ,PROP,V', 2302, vcl_setprop, 'VCL GUI部品のプロパティを設定(OBJにはGUIオブジェクトを直接指定)','VCL_SET');
  AddFunc('VCL_COMMAND','OBJ,V1,V2', 2303, vcl_command, 'VCL GUI部品のコマンドV1にデータV2を設定する','VCL_COMMAND');
  AddFunc('VCL_FREE','{グループ}A', 2311, vcl_free, 'VCL GUI部品を破棄する','VCL_FREE');
  AddFunc('メニュー一括作成','Sを|Sの', 2304, vcl_menus, 'メニューを一括作成する。CSV形式で「親部品名,部品名,テキスト,ショートカット,オプション,イベント」で指定する。イベントには関数名か一行プログラムを指定。','めにゅーいっかつさくせい');
  AddFunc('ポップアップメニュー一括作成','{グループ}OBJにSを', 2305, vcl_popupmenus, 'ポップアップメニューOBJ(オブジェクトを与える)でメニューを一括作成する。CSV形式で「親部品名,部品名,テキスト,ショートカット,オプション,イベント」で指定する。イベントには関数名か一行プログラムを指定。','ぽっぷあっぷめにゅーいっかつさくせい');
  AddFunc('ツールボタン一括作成','{グループ}OBJにSを', 2306, vcl_toolbutton, 'ツールバーOBJ(ツールバーのオブジェクトを与える)にツールボタンを一括作成する。SにはCSV形式で「部品名,画像番号,種類(ボタン|区切り),説明,イベント」で指定する。','つーるぼたんいっかつさくせい');
  AddFunc('ツリーノード一括作成','{グループ}OBJにSを', 2307, vcl_treenode, 'ツリーOBJにノードSを一括作成する。Sは「親識別名,ノード識別名,テキスト,画像番号,選択画像番号」で指定。','つりーのーどいっかつさくせい');
  AddFunc('ツリーノード一括追加','{グループ}OBJにSを', 2308, vcl_treenode_add, 'ツリーOBJにノードを一括追加する。Sは「親識別名,ノード識別名,テキスト,画像番号,選択画像番号」で指定。','つりーのーどいっかつついか');
  AddFunc('リストアイテム一括作成','{グループ}OBJにSを', 2309, vcl_listview, 'ツリーOBJにノードを一括作成する。Sは「親識別名,ノード識別名,テキスト,画像番号」で指定。','りすとあいてむいっかつさくせい');
  AddFunc('リストアイテム一括追加','{グループ}OBJにSを', 2310, vcl_listview_add, 'ツリーOBJにノードを一括追加する。Sは「親識別名,ノード識別名,テキスト,画像番号」で指定。','りすとあいてむいっかつついか');
  AddFunc('中央移動', '{グループ}OBJを', 2320, cmd_moveWindow, 'ウィンドウや部品OBJを中央へ移動する。','ちゅうおういどう');
  AddFunc('母艦タイトル設定', 'Sに', 2321, vcl_set_apptitle, 'タイトルバーのテキストを変更する','ぼかんたいとるせってい');
  AddFunc('母艦タイトル取得', '', 2322, vcl_get_apptitle, 'タイトルバーのテキストを取得する','ぼかんたいとるしゅとく');
  AddFunc('最前面', '{グループ}OBJを|OBJの', 2323, cmd_StayOnTop, '部品OBJを最前面に表示する','さいぜんめん');
  AddFunc('最背面', '{グループ}OBJを|OBJの', 2324, cmd_StayOnTopOff, '部品OBJを最背面に表示する','さいはいめん');
  AddFunc('最前面判定', '{グループ}OBJを|OBJの', 2327, cmd_IsStayOnTop, 'ウィンドウOBJが最前面かどうか判定して、はい(=1)かいいえ(=0)を返す','さいぜんめんはんてい');
  SetSetterGetter('母艦タイトル', '母艦タイトル設定','母艦タイトル取得',2325, '母艦タイトルバーの設定取得を行う', 'ぼかんたいとる');
  AddFunc  ('漢字読み取得','{文字列=?}Sを|Sの',2326, sys_toHurigana,'文章SのふりがなをIMEより取得する(コンソール上では機能しない)','かんじよみしゅとく');
  AddFunc('SetFocus',   'H',         2319, _SetFocus, '','SetFocus');
  AddFunc('SendMessage','H,MSG,W,L', 2328, _SendMessage, '','SendMessage');
  AddFunc('PostMessage','H,MSG,W,L', 2329, _PostMessage, '','PostMessage');
  //-ブラウザ支援
  AddFunc('ブラウザINPUT値設定','{グループ}OBJのIDにSを', 2399, browser_setFormValue, 'ブラウザ部品OBJで表示中のページにあるINPUTタグ(IDにはid属性か「name属性かタグ名\出現番号(0起点)」)のvalueに値を設定する','ぶらうざINPUTあたいせってい');
  AddFunc('ブラウザINPUT値取得','{グループ}OBJのIDを', 2398, browser_getFormValue, 'ブラウザ部品OBJで表示中のページにあるINPUTタグの値を取得する','ぶらうざINPUTあたいしゅとく');
  AddFunc('ブラウザFORM送信','{グループ}OBJのIDを', 2397, browser_submit, 'ブラウザ部品OBJで表示中のページにあるFORMタグを送信する(IDにはid属性か「name属性かタグ名\出現番号(0起点)」)を送信する','ぶらうざFORMそうしん');
  AddFunc('ブラウザHTML書換','{グループ}OBJのIDをSに|Sへ', 2396, browser_setHTML, 'ブラウザ部品OBJで表示中のIDのHTMLを書き換える(IDにはid属性か「name属性かタグ名\出現番号(0起点)」)','ぶらうざHTMLかきかえ');
  AddFunc('ブラウザHTML取得','{グループ}OBJのIDを', 2395, browser_getHTML, 'ブラウザ部品OBJで表示中のIDのHTMLを取得する(IDにはid属性か「name属性かタグ名\出現番号(0起点)」)','ぶらうざHTMLしゅとく');
  AddFunc('ブラウザ読込待機','{グループ}OBJの', 2394, browser_waitToComplete, 'ブラウザ部品OBJで表示中のIDのHTMLを取得する','ぶらうざよみこみたいき');
  AddFunc('ブラウザ要素クリック','{グループ}OBJのIDを', 2393, browser_click, 'ブラウザ部品OBJで表示中のID要素をクリックする','ぶらうざようそくりっく');
  AddFunc('ブラウザ印刷プレビュー','{グループ}OBJで|OBJを', 2392, browser_printpreview, 'ブラウザ部品OBJで印刷プレビューを出す','ぶらうざいんさつぷれびゅー');
  AddFunc('ブラウザEXECWB','{グループ}OBJのCMDをOPTで', 2391, browser_execwb, 'ブラウザ部品OBJにコマンドを送る','ぶらうざEXECWB');

  //-色定数
  AddIntVar('白色', $FFFFFF, 2330, '白色','しろいろ');
  AddIntVar('黒色', $000000, 2331, '黒色','くろいろ');
  AddIntVar('赤色', $FF0000, 2333, '赤色','あかいろ');
  AddIntVar('青色', $0000FF, 2334, '青色','あおいろ');
  AddIntVar('黄色', $FFFF00, 2332, '黄色','きいろ');
  AddIntVar('緑色', $00FF00, 2335, '緑色','みどりいろ');
  AddIntVar('紫色', $FF00FF, 2336, '紫色','むらさきいろ');
  AddIntVar('水色', $00FFFF, 2337, '水色','みずいろ');

  AddIntVar('ウィンドウ色',     Color2RGB(clWindow),      2338, 'システムカラー','うぃんどういろ');
  AddIntVar('ウィンドウ背景色', Color2RGB(clBtnFace),     2339, 'システムカラー','うぃんどうはいけいしょく');
  AddIntVar('ウィンドウ文字色', Color2RGB(clWindowText),  2340, 'システムカラー','うぃんどうもじしょく');
  AddIntVar('デスクトップ色',   Color2RGB(clBackground),  2341, 'システムカラー','ですくとっぷしょく');
  AddIntVar('アクティブ色',     Color2RGB(clActiveCaption),   2342, 'システムカラー','あくてぃぶしょく');
  AddIntVar('非アクティブ色',   Color2RGB(clInactiveCaption), 2343, 'システムカラー','ひあくてぃぶしょく');

  //-デバッグ用
  AddIntVar('デバッグエディタハンドル', 0, 2360, 'なでしこエディタから実行された時、エディタハンドルが設定される。','でばっぐえでぃたはんどる');
  AddFunc('デバッグ', '', 2361, @cmd_debug, 'デバッグダイアログを表示する。','でばっぐ');//メソッドの上書き
  AddStrVar('エラーダイアログタイトル', 'なでしこのエラー', 2362, 'エラーダイアログのタイトルを指定する','えらーだいあろぐたいとる');
  AddIntVar('エラーダイアログ表示許可', 1, 2363, 'エラーダイアログの表示を許可するかどうかを指定する(0なら許可しない)','えらーだいあろぐひょうじきょか');

  //+ダイアログ(vnako)
  //-ダイアログ
  AddFunc('フォント選択',    '',                    2401,cmd_dlgFont,   'フォントを選択してフォント名を返す。', 'ふぉんとせんたく');
  AddFunc('色選択',          '',                    2402,cmd_dlgColor,  '色を選択して返す。', 'いろせんたく');
  AddFunc('プリンタ設定',    '',                    2403,cmd_dlgPrint,  'プリンタを設定する。キャンセルが押されたら、いいえ(=0)を返す。', 'ぷりんたせってい');
  AddFunc('メモ記入',        '{=?}Sの|Sと|Sを|Sで', 2404,cmd_dlgMemo,   'エディタにSを表示し編集結果を返す。', 'めもきにゅう');
  AddFunc('尋ねる',          '{=?}Sと|Sを|Sで',     2405,cmd_dlgInput,     'ユーザーからの入力を返す。', 'たずねる');
  AddFunc('項目記入',        '{=?}Sと|Sを|Sで|Sの', 2406,cmd_dlgInputList, 'ユーザーから複数の項目S(ハッシュ形式)の入力を得て結果をハッシュで返す。', 'こうもくきにゅう');
  AddFunc('パスワード入力',  '{=?}Sと|Sを|Sで|Sの', 2407,cmd_dlgPassword,  'メッセージSを表示し、パスワードの入力を得る。', 'ぱすわーどにゅうりょく');
  AddFunc('ボタン選択',      '{=?}SをVで|SにVの',   2408,cmd_dlgButton,    'メッセージSを表示し、選択肢Vから答えを得て返す。', 'ぼたんせんたく');
  AddFunc('言う',            '{=?}Sと|Sを|Sの|Sで', 2409,cmd_dlgSay,       'メッセージSを表示する。', 'いう');
  AddFunc('数値入力',        '{=?}Sと|Sを|Sの|Sで', 2410,cmd_dlgInputNum,  'メッセージSを表示して数値を入力してもらう。', 'すうちにゅうりょく');
  AddFunc('吹き出し表示',    'X,Yへ{=?}Sと|Sを|Sの|Sで',  2411,cmd_dlgHukidasi, 'X,YへメッセージSを吹き出しにして表示する。', 'ふきだしひょうじ');
  AddFunc('二択',            'Sで|Sを|Sの',               2412,cmd_nitaku,      'メッセージSを表示し、はいかいいえで尋ねるダイアログを表示し、結果をはい(=1)いいえ(=0)で返す。', 'にたく');
  AddFunc('リスト絞込み選択','{=?}Sで|Sと|Sを|Sの|Sから',     2421,cmd_dlgList,  'メッセージSを表示し、はいかいいえで尋ねるダイアログを表示し、結果をはい(=1)いいえ(=0)で返す。', 'りすとしぼりこみせんたく');
  AddFunc('日付選択',        '', 2416,cmd_dlgInputDate,  'カレンダーを表示して日付選択ダイアログを表示し日付を返す。', 'ひづけせんたく');
  //-Vistaダイアログ
  AddFunc('二択ダイアログ表示','{=?}QでSの|QとSを',  2413,cmd_nitaku_vista, 'Vista以降の標準二択ダイアログに質問Qと説明Sを表示する。', 'にたくだいあろぐひょうじ');
  AddFunc('警告ダイアログ表示','{=?}QでSの|QとSを',  2414,cmd_warning_vista, 'Vista以降の標準二択ダイアログにタイトルQと説明Sを表示する。', 'けいこくだいあろぐひょうじ');
  AddFunc('情報ダイアログ表示','{=?}QでSの|QとSを',  2415,cmd_okdialog_vista, 'Vista以降の標準二択ダイアログにタイトルQと説明Sを表示する。', 'じょうほうだいあろぐひょうじ');

  //-ダイアログオプション
  AddStrVar('ダイアログ詳細','',2420,'ダイアログに関するオプションをハッシュ形式で指定する。(文字書体/文字サイズ/文字色)','だいあろぐしょうさい');
  //AddStrVar('ダイアログキャンセル値','',460,'ダイアログをキャンセルしたときの値を指定','だいあろぐきゃんせるち');
  //AddStrVar('ダイアログ初期値','',461,'ダイアログの初期値を指定','だいあろぐしょきち');
  //AddStrVar('ダイアログIME','',462,'ダイアログの入力フィールドのIME状態の指定(IMEオン|IMEオフ|IMEかな|IMEカナ|IME半角)','だいあろぐIME');
  //AddStrVar('ダイアログタイトル','',463,'ダイアログのタイトルを指定する','だいあろぐたいとる');
  //AddStrVar('ダイアログ数値変換','1',464,'ダイアログの結果を数値に変換するかどうか。オン(=1)オフ(=0)を指定する。','だいあろぐすうちへんかん');

  //+印刷(vnako)
  //-簡易印刷
  AddFunc('簡易文字列印刷', '{=?}Sで|Sを|Sの', 2450, cmd_printEasy,  '文字列Sを印刷する', 'かんいもじれついんさつ');
  AddFunc('母艦印刷', '', 2451, cmd_printBokan,  '母艦を用紙いっぱいに印刷する', 'ぼかんいんさつ');
  AddFunc('簡易画像印刷', '{グループ=?}Gを', 2452, cmd_printEasyImage,  'イメージGを用紙いっぱいに印刷する', 'かんいがぞういんさつ');
  //-詳細印刷
  AddFunc('プリンタ描画開始', '', 2455, cmd_printBeginDoc,  '', 'ぷりんたびょうがかいし');
  AddFunc('プリンタ描画終了', '', 2456, cmd_printEndDoc,  '', 'ぷりんたびょうがしゅうりょう');
  AddFunc('プリンタ用紙幅',   '', 2457, cmd_printPaperWidth,  '', 'ぷりんたようしはば');
  AddFunc('プリンタ用紙高さ', '', 2458, cmd_printPaperHeight,  '', 'ぷりんたようしたかさ');
  AddFunc('プリンタ改ページ', '', 2465, cmd_printPaperNewPage,  '', 'ぷりんたかいぺーじ');

  AddFunc('プリンタ文字描画',     '{=?}SをX,Yへ', 2459, cmd_printTextOut,  '', 'ぷりんたもじびょうが');
  AddFunc('プリンタ文字幅取得',   '{=?}Sを', 2460, cmd_printGetCharWidth,  '', 'ぷりんたもじはばしゅとく');
  AddFunc('プリンタ文字高さ取得', '{=?}Sを', 2461, cmd_printGetCharHeight,  '', 'ぷりんたもじたかさしゅとく');

  AddFunc('プリンタ画像描画',     '{グループ=?}GをX,Yへ', 2462, cmd_printImage,  '', 'ぷりんたがぞうびょうが');
  AddFunc('プリンタ線描画',       'X1,Y1からX2,Y2へ', 2463, cmd_printLine,  '', 'ぷりんたせんびょうが');
  AddFunc('プリンタ拡大画像描画', '{グループ=?}GをX1,Y1,X2,Y2へ', 2464, cmd_printImageEx,  '', 'ぷりんたかくだいがぞうびょうが');

  //</VNAKO命令>

  nako_setMainWindowHandle(bokanHandle);
  _init_font;
end;




initialization
begin
  printLogBuf := TRingBufferString.Create(PRINT_LOG_SIZE);
end;

finalization
  printLogBuf.Free;
end.
