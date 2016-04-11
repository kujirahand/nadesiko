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
  // Delphi2009 -> RTLVersion(20)
  {$IF RTLVersion < 20}
  ,XPMan, gldpng
  ,TntStdCtrls,TntExtCtrls, TntGrids
  {$ELSE}
  ,XPMan, pngimage
  {$IFEND}
  ;

const
  EVENT_CLICK       = '�N���b�N������';
  EVENT_DBLCLICK    = '�_�u���N���b�N������';
  EVENT_CHANGE      = '�ύX������';
  EVENT_SIZE_CHANGE = '�T�C�Y�ύX������';
  EVENT_SHOW        = '�\��������';
  EVENT_CLOSE       = '������';
  EVENT_MOUSEDOWN   = '�}�E�X��������';
  EVENT_MOUSEMOVE   = '�}�E�X�ړ�������';
  EVENT_MOUSEUP     = '�}�E�X��������';
  EVENT_KEYDOWN     = '�L�[��������';
  EVENT_KEYPRESS    = '�L�[�^�C�s���O��';
  EVENT_KEYUP       = '�L�[��������';
  EVENT_DRAGOVER    = '�h���b�v��������';
  EVENT_DRAGDROP    = '�h���b�v������';
  EVENT_MOUSEWHEEL  = '�}�E�X�z�C�[���񂵂���';
  EVENT_FILEDROP    = '�t�@�C���h���b�v������';
  EVENT_COPYDATA    = 'COPYDATA�󂯂���';
  EVENT_TIMER       = '����������';
  EVENT_ACTIVATE    = '�A�N�e�B�u��������';
  EVENT_COMPLETE    = '����������';
  EVENT_ACTIVATE2   = '�A�N�e�B�u��';
  EVENT_DEACTIVATE  = '��A�N�e�B�u��';
  EVENT_MINIMIZE    = '�ŏ���������';
  EVENT_RESTORE     = '���ʂ莞';
  EVENT_PAINT       = '�`�悷�鎞';
  EVENT_MOUSEENTER  = '�}�E�X��������';
  EVENT_MOUSELEAVE  = '�}�E�X�o����';
  EVENT_LISTOPEN    = '���X�g�J������';
  EVENT_LISTCLOSE   = '���X�g������';
  EVENT_LISTSELECT  = '���X�g�I��������';

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
    freetag: Integer; // ���R�Ɏg����^�O
  end;

var
  guiCount: Integer = 1; // ID = 0 : ���
  GuiInfos: array [0..2047] of TGuiInfo; // �ő� 2048 ������΂����ł��傤...
  EventObject: PHiValue = nil;
  parentObj: TComponent = nil;

// �Ȃł����ɕK�v�Ȋ֐���ǉ�����
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

procedure setDialogIME(h: THandle); //�_�C�A���OIME���
function setControlIME(v: AnsiString): TImeMode;
function getIMEStatusName(mode: TImeMode): AnsiString; //IME���
procedure GetDialogSetting(var title: string; var init: string; var cancel: string; var ime: string);
function getDialogS(ValueName: AnsiString; initValue: AnsiString): AnsiString; // �_�C�A���O�ڍׂ���l�����o��

function getGui(g: PHiValue): TObject; // �I�u�W�F�N�g���擾
function getGuiName(g: PHiValue): AnsiString; // �I�u�W�F�N�g�̖��O���擾
function getGuiObj(o: PHiValue): TObject; // �I�u�W�F�N�g���擾
function getCanvasFromObj(obj: TObject): TCanvas; // �I�u�W�F�N�g���擾
function getCanvas(o: PHiValue): TCanvas; // �I�u�W�F�N�g���擾
function getBmp(o: PHiValue): TBitmap; // �I�u�W�F�N�g���擾
function getImage(o: PHiValue): TImage; // �I�u�W�F�N�g���擾
function getGroupName(group: PHiValue): AnsiString; // �O���[�v�����擾����

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

{$IF RTLVersion < 20}
  TTntButton = class(TntStdCtrls.TTntButton)
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
 	  property OnMouseHover:TMouseEvent read FOnMouseHover write FOnMouseHover;
 	end;

 	TTntEdit = class(TntStdCtrls.TTntEdit)
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
 	  property OnMouseHover:TMouseEvent read FOnMouseHover write FOnMouseHover;
 	end;

 	TTntMemo = class(TntStdCtrls.TTntMemo)
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
 	  property OnMouseHover:TMouseEvent read FOnMouseHover write FOnMouseHover;
 	end;

 	TTntListBox = class(TntStdCtrls.TTntListBox)
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
 	  property OnMouseHover:TMouseEvent read FOnMouseHover write FOnMouseHover;
 	end;

 	TTntComboBox = class(TntStdCtrls.TTntComboBox)
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
 	  property OnMouseHover:TMouseEvent read FOnMouseHover write FOnMouseHover;
 	end;

 	TTntCheckBox = class(TntStdCtrls.TTntCheckBox)
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
 	  property OnMouseHover:TMouseEvent read FOnMouseHover write FOnMouseHover;
 	end;

 	TTntStringGrid = class(TntGrids.TTntStringGrid)
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
 	  property OnMouseHover:TMouseEvent read FOnMouseHover write FOnMouseHover;
 	end;

 	TTntLabel = class(TntStdCtrls.TTntLabel)
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
    property OnMouseHover:TMouseEvent read FOnMouseHover write FOnMouseHover;
  end;
{$IFEND}

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

// Vista/7/8��IntegralHeight���L���̎��AHegiht�̒l�𖳎�����
// �������g������Ă��܂��o�O�ւ̑΍�
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

{$IF RTLVersion < 20}
{TTntButton}
procedure TTntButton.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
  	FOnMouseEnter(self);
 	_TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TTntButton.CMMouseLeave(var Msg:TMessage);
begin
 	if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
   	FOnMouseLeave(Self);
end;

procedure TTntButton.WMMouseHover(var Msg:TMessage);
begin
	if Assigned(FOnMouseHover) then
 	begin
   	with TWMMouse(Msg) do
    	FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{TTntEdit}
procedure TTntEdit.CMMouseEnter(var Msg:TMessage);
begin
	if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
   	FOnMouseEnter(self);
	_TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TTntEdit.CMMouseLeave(var Msg:TMessage);
begin
 	if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
  	FOnMouseLeave(Self);
end;

procedure TTntEdit.WMMouseHover(var Msg:TMessage);
begin
	if Assigned(FOnMouseHover) then
 	begin
  	with TWMMouse(Msg) do
    	FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
 	end;
end;

{TTntMemo}
procedure TTntMemo.CMMouseEnter(var Msg:TMessage);
begin
 	if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
  	FOnMouseEnter(self);
 	_TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TTntMemo.CMMouseLeave(var Msg:TMessage);
begin
 	if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
  	FOnMouseLeave(Self);
end;

procedure TTntMemo.WMMouseHover(var Msg:TMessage);
begin
 	if Assigned(FOnMouseHover) then
 	begin
 	  with TWMMouse(Msg) do
   	  FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
 	end;
end;

{TTntListBox}
procedure TTntListBox.CMMouseEnter(var Msg:TMessage);
begin
 	if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
  	FOnMouseEnter(self);
 	_TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TTntListBox.CMMouseLeave(var Msg:TMessage);
begin
 	if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
   	FOnMouseLeave(Self);
end;

procedure TTntListBox.WMMouseHover(var Msg:TMessage);
begin
 	if Assigned(FOnMouseHover) then
 	begin
  	with TWMMouse(Msg) do
 	    FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
 	end;
end;

{TTntComboBox}
procedure TTntComboBox.CMMouseEnter(var Msg:TMessage);
begin
 	if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
   	FOnMouseEnter(self);
 	_TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TTntComboBox.CMMouseLeave(var Msg:TMessage);
begin
 	if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
   	FOnMouseLeave(Self);
end;

procedure TTntComboBox.WMMouseHover(var Msg:TMessage);
begin
 	if Assigned(FOnMouseHover) then
 	begin
  	with TWMMouse(Msg) do
 	    FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
 	end;
end;

{TTntCheckBox}
procedure TTntCheckBox.CMMouseEnter(var Msg:TMessage);
begin
 	if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
  	FOnMouseEnter(self);
 	_TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TTntCheckBox.CMMouseLeave(var Msg:TMessage);
begin
 	if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
  	FOnMouseLeave(Self);
end;

procedure TTntCheckBox.WMMouseHover(var Msg:TMessage);
begin
if Assigned(FOnMouseHover) then
 	begin
   	with TWMMouse(Msg) do
 	    FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
 	end;
end;

{TTntStringGrid}
procedure TTntStringGrid.CMMouseEnter(var Msg:TMessage);
begin
 	if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
  	FOnMouseEnter(self);
 	_TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TTntStringGrid.CMMouseLeave(var Msg:TMessage);
begin
 	if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
  	FOnMouseLeave(Self);
end;

procedure TTntStringGrid.WMMouseHover(var Msg:TMessage);
begin
 	if Assigned(FOnMouseHover) then
 	begin
  	with TWMMouse(Msg) do
    	FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
 	end;
end;

{TTntLabel}
procedure TTntLabel.CMMouseEnter(var Msg:TMessage);
begin
 	if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
 	  FOnMouseEnter(self);
 	//_TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TTntLabel.CMMouseLeave(var Msg:TMessage);
begin
 	if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
 	  FOnMouseLeave(Self);
end;

procedure TTntLabel.WMMouseHover(var Msg:TMessage);
begin
 	if Assigned(FOnMouseHover) then
 	begin
 	  with TWMMouse(Msg) do
  	  FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
	end;
end;
{$IFEND}

constructor TRingBufferString.Create(maxsize:integer);
begin
  FCapacity := maxsize;
  SetLength(FBuffer,FCapacity+1);//+1���Ȃ��ƁA�w�肳�ꂽ�e�ʕ��g���Ȃ�����
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
  begin // ���e���I�[���瓪�ɖ߂��Ă��Ă���
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
  p := nako_getVariable('�_�C�A���O���l�ϊ�');
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
  // pngimage �̃o�O���H�F����������������I�I
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
    if GraphicClass = nil then raise Exception.Create('���Ή��̉摜�t�H�[�}�b�g');
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

  // �N���b�v�{�[�h�H
  if fname = '�N���b�v�{�[�h' then
  begin
    if Clipboard.HasFormat(CF_BITMAP) then
    begin
      Result.Assign(Clipboard);
    end;
    Exit;
  end;

  // �C���[�W���i���ǂ����H
  ext := LowerCase(ExtractFileExt(fname));
  if ext = '' then
  begin
    p := nako_getVariable(PAnsiChar(AnsiString(fname)));
    if (p<>nil)and(p.VType = varGroup) then
    begin
      b := GetBMP(p);
      if b = nil then raise Exception.Create('GUI���i�́w'+fname+'�x����C���[�W�����o���܂���ł����B');
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
      raise Exception.CreateFmt('"%s"�͖��Ή��̉摜�^�C�v�ł��B',[ext]);
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
    v := nako_getVariable('JPEG���k��');
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
  // �N���b�v�{�[�h�ւ̕ۑ��H
  if fname = '�N���b�v�{�[�h' then
  begin
    Clipboard.Assign(bmp);
    Exit;
  end;

  ext := LowerCase( ExtractFileExt(fname) );

  // �t�@�C���ւ̕ۑ�
  // CREATE
  if ext = '.png'  then _png  else
  if ext = '.jpg'  then _jpeg else
  if ext = '.jpeg' then _jpeg else
  if ext = '.gif'  then _gif  else
  if ext = '.bmp'  then _bmp  else
  if ext = '.ico'  then begin _ico; Exit; end else
  if ext = '.mag'  then _mag  else
  raise Exception.CreateFmt('"%s"�͖��Ή��̉摜�^�C�v�ł��B',[ext]);
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
  if fsBold       in fs then Result := Result + '����';
  if fsItalic     in fs then Result := Result + '�Α�';
  if fsUnderline  in fs then Result := Result + '����';
  if fsStrikeOut  in fs then Result := Result + '�ŏ�';
end;

function StrTofontStyle(fs: string): TFontStyles;
begin
  Result := [];
  if Pos('����', fs) > 0 then Result := Result + [fsBold];
  if Pos('�Α�', fs) > 0 then Result := Result + [fsItalic];
  if Pos('����', fs) > 0 then Result := Result + [fsUnderline];
  if Pos('�ŏ�', fs) > 0 then Result := Result + [fsStrikeOut];
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
  if ps = '����' then Canvas.Pen.Style := psSolid else
  if ps = '�_��' then begin Canvas.Pen.Style := psDot; Canvas.Pen.Width := 1; end else
  if ps = '�j��' then begin Canvas.Pen.Style := psDash;Canvas.Pen.Width := 1; end else
  if (ps = '')or(ps = '�Ȃ�')or(ps = '����') then Canvas.Pen.Style := psClear else
  begin
    Canvas.Pen.Style := psSolid;
  end;

  // BRUSH
  Canvas.Brush.Color := RGB2Color( hi_int(brushColor) );
  // BRUSH.STYLE
  bs := hi_str(brushStyle);
  if (bs = '�ׂ�')or(bs = '�x�^') then Canvas.Brush.Style := bsSolid else
  if bs = '����' then Canvas.Brush.Style := bsClear else
  if bs = '�i�q' then Canvas.Brush.Style := bsCross else
  if bs = '����' then Canvas.Brush.Style := bsHorizontal else
  if bs = '�c��' then Canvas.Brush.Style := bsVertical else
  if bs = '���΂ߐ�' then Canvas.Brush.Style := bsFDiagonal else
  if bs = '�E�΂ߐ�' then Canvas.Brush.Style := bsBDiagonal else
  if bs = '�\����' then Canvas.Brush.Style := bsCross else
  if bs = '�΂ߏ\����' then Canvas.Brush.Style := bsDiagCross else
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
  begin // �����w�肠��
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

  Font.Size    := StrToIntDefA(getDialogS('�����T�C�Y','10'),10);
  Font.Charset := DEFAULT_CHARSET;
  // �F
  s := string(getDialogS('�����F','0'));
  sa := AnsiString(s);
  if not IsNumber(sa) then s := hi_strU(nako_eval_str(AnsiString(s))) else s := string(sa);
  Font.Color := Color2RGB(StrToIntDef(s, 0));
  // ����
  s := string(getDialogS('��������', AnsiString(bokan.BackCanvas.Font.Name)));
  if Pos('|', s) > 0 then
  begin // �����w�肠��
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

function getGui(g: PHiValue): TObject; // �I�u�W�F�N�g���擾
var
  p: PHiValue;
begin
  // group �� �I�u�W�F�N�g���ێ�����
  if g = nil then
  begin
    Result := bokan; Exit;
  end;
  p := nako_group_findMember(g, '�I�u�W�F�N�g');
  if p = nil then
  begin
    raise Exception.Create('�I�u�W�F�N�g������ł��܂���ł����B');
  end else
  begin
    Result := TObject(hi_int(p));
  end;
end;

function getGroupName(group: PHiValue): AnsiString; // �O���[�v�����擾����
var
  buf: AnsiString;
begin
  SetLength(buf, 1024);
  nako_id2tango(group.VarID, PAnsiChar(buf), 1023);
  Result := AnsiString(PAnsiChar(buf));
end;

function getGuiName(g: PHiValue): AnsiString; // �I�u�W�F�N�g�̖��O���擾
var
  p: PHiValue;
begin
  // group �� �I�u�W�F�N�g���ێ�����
  if g = nil then
  begin
    Result := '���'; Exit;
  end;
  p := nako_group_findMember(g, '���O');
  if p = nil then
  begin
    raise Exception.Create('�I�u�W�F�N�g������ł��܂���ł����B');
  end else
  begin
    Result := hi_str(p);
  end;
end;


function getGuiObj(o: PHiValue): TObject; // �I�u�W�F�N�g���擾
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

function getCanvasFromObj(obj: TObject): TCanvas; // �I�u�W�F�N�g���擾
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

function getCanvas(o: PHiValue): TCanvas; // �I�u�W�F�N�g���擾
var
  obj: TObject;
begin
  obj := getGui(o);
  Result := getCanvasFromObj(obj);
end;

function getBmp(o: PHiValue): TBitmap; // �I�u�W�F�N�g���擾
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

function getImage(o: PHiValue): TImage; // �I�u�W�F�N�g���擾
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

procedure setDialogIME(h: THandle); //�_�C�A���OIME���
var
  p: PHiValue;
  v: AnsiString;
begin
  p := nako_getVariable('�_�C�A���OIME');
  if p = nil then Exit;
  v := hi_str(p);
  SetImeMode(h, setControlIME(v));
end;

function setControlIME(v: AnsiString): TImeMode;
begin
  if Copy(v,1,6)='�h�l�d' then begin System.Delete(v,1,6); v := 'IME' + v; end;

  v := Copy(v,1,7);
  if v = 'IME�I��' then Result := imOpen  else
  if v = 'IME�I�t' then Result := imDisable else
  if (v = 'IME�Ђ�')or(v = 'IME����') then Result := imHira  else
  if (v = 'IME�J�i')or(v = 'IME�J�^') then Result := imKata  else
  if v = 'IME���p' then Result := imSKata else
  Result := imDontCare;
end;

function getIMEStatusName(mode: TImeMode): AnsiString; //IME���
begin
  //IME�I��|IME�I�t|IME�Ђ�|IME�J�i
  {
  TImeMode = (imDisable, imClose, imOpen, imDontCare,
              imSAlpha, imAlpha, imHira, imSKata, imKata,
              imChinese, imSHanguel, imHanguel);
  }
  if mode = imDisable   then Result := 'IME�I�t' else
  if mode = imClose     then Result := 'IME�I�t' else
  if mode = imOpen      then Result := 'IME�I��' else
  if mode = imDontCare  then Result := 'IME�I�t' else
  if mode = imSAlpha    then Result := 'IME�I�t' else
  if mode = imAlpha     then Result := 'IME�I�t' else
  if mode = imHira      then Result := 'IME����' else
  if mode = imSKata     then Result := 'IME���p' else
  if mode = imKata      then Result := 'IME�J�i' else
  Result := '';

end;


function cmd_print(h: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  y: Integer;
  str: AnsiString;
  r: TRect;
begin
  // (1) �����̎擾
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;

  // �ȈՃ��O��ǉ�
  printLogBuf.Add((hi_str(p)));
  printLogBuf.Add(#13#10);
  hi_setStr(printLog, AnsiString(printLogBuf.Text));
  //---

  y := nako_var2int(baseY);

  r := RECT(0,0,bokan.ClientWidth, bokan.ClientHeight);
  r.Left := hi_int(baseX);
  r.Top  := y;

  // (2) ����

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
  
  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;


function cmd_print_continue(h: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  x, y: Integer;
  str, s: AnsiString;
  hasRet: Boolean;
begin
  // (1) �����̎擾
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;

  // �ȈՃ��O��ǉ�
  printLogBuf.Add((hi_str(p)));
  hi_setStr(printLog, AnsiString(printLogBuf.Text));

  //---
  getFont;

  x := nako_var2int(baseX);
  y := nako_var2int(baseY);

  // (2) ����
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

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_cls(h: DWORD): PHiValue; stdcall;
var
  o, p: PHiValue;
  c: Integer;
  gui: TObject;
begin
  // (1) �����̎擾
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
  // RRGGBB�ɕϊ�
  c := RGB2Color(c);

  // (2) ����
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

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_move(h: DWORD): PHiValue; stdcall;
var
  x, y: PHiValue;
begin
  // (1) �����̎擾
  x := nako_getFuncArg(h, 0);
  y := nako_getFuncArg(h, 1);

  // (2) ����
  nako_varCopyData(x, baseX);
  nako_varCopyData(y, baseY);

  Bokan.BackCanvas.MoveTo(nako_var2int(x), nako_var2int(y));

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;


function cmd_line(h: DWORD): PHiValue; stdcall;
var
  x1, y1, x2, y2: PHiValue;
  i1, i2, i3, i4: Integer;
  gui: TObject;
begin
  // (1) �����̎擾
  gui := getGui( nako_getFuncArg(h, 0) );
  x1  := nako_getFuncArg(h, 1);
  y1  := nako_getFuncArg(h, 2);
  x2  := nako_getFuncArg(h, 3);
  y2  := nako_getFuncArg(h, 4);

  // (2) ����
  if (x1=nil)and(y1=nil) then
  begin
    // ��{�_����̕`��
    i1 := nako_var2int(baseX);
    i2 := nako_var2int(baseY);
    i3 := nako_var2int(x2);
    i4 := nako_var2int(y2);
  end else
  begin
    // ��{�_����̕`��
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

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_ExtFloodFill(h: DWORD): PHiValue; stdcall;
var
  xx, yy, c, b: Integer;
  v: TCanvas;
begin
  // (1) �����̎擾
  v  := getCanvas(nako_getFuncArg(h, 0));
  xx := getArgInt(h, 1);
  yy := getArgInt(h, 2);
  c  := RGB2Color(getArgInt(h, 3));
  b  := getArgInt(h, 4);

  // (2) ����
  Bokan.flagRepaint := True;
  v.Brush.Color := c;
  if b <> Integer($FF000000) then
    ExtFloodFill(v.Handle, xx, yy, RGB2Color(b), FLOODFILLBORDER)
  else
    ExtFloodFill(v.Handle, xx, yy, v.Pixels[xx,yy], FLOODFILLSURFACE);
  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_pset(h: DWORD): PHiValue; stdcall;
var
  xx, yy, c: Integer;
  v: TCanvas;
begin
  // (1) �����̎擾
  v  := getCanvas(nako_getFuncArg(h, 0));
  xx := getArgInt(h, 1);
  yy := getArgInt(h, 2);
  c  := RGB2Color(getArgInt(h, 3));

  // (2) ����
  Bokan.flagRepaint := True;
  v.Pixels[xx, yy] := c;

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_pget(h: DWORD): PHiValue; stdcall;
var
  xx, yy, c: Integer;
  v: TCanvas;
begin
  // (1) �����̎擾
  v  := getCanvas( nako_getFuncArg(h, 0) );
  xx := getArgInt(h, 1);
  yy := getArgInt(h, 2);

  // (2) ����
  c := v.Pixels[xx, yy];
  c := RGB2Color(c);

  // (3) ���ʂ̑��
  Result := hi_newInt(c); // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_rectangle(h: DWORD): PHiValue; stdcall;
var
  x1, y1, x2, y2: PHiValue;
  i1, i2, i3, i4: Integer;
  c: TCanvas;
begin
  // (1) �����̎擾
  c  := getCanvas(nako_getFuncArg(h, 0));
  x1 := nako_getFuncArg(h, 1);
  y1 := nako_getFuncArg(h, 2);
  x2 := nako_getFuncArg(h, 3);
  y2 := nako_getFuncArg(h, 4);

  // (2) ����
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

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_circle(h: DWORD): PHiValue; stdcall;
var
  x1, y1, x2, y2: PHiValue;
  i1, i2, i3, i4: Integer;
  c: TCanvas;
begin
  // (1) �����̎擾
  c   := getCanvas( nako_getFuncArg(h, 0) );
  x1  := nako_getFuncArg(h, 1);
  y1  := nako_getFuncArg(h, 2);
  x2  := nako_getFuncArg(h, 3);
  y2  := nako_getFuncArg(h, 4);

  // (2) ����
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

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_roundrect(h: DWORD): PHiValue; stdcall;
var
  x1, y1, x2, y2, m1, m2: PHiValue;
  i1, i2, i3, i4, i5, i6: Integer;
  c: TCanvas;
begin
  // (1) �����̎擾
  c  := getCanvas(nako_getFuncArg(h, 0));
  x1 := nako_getFuncArg(h, 1);
  y1 := nako_getFuncArg(h, 2);
  x2 := nako_getFuncArg(h, 3);
  y2 := nako_getFuncArg(h, 4);
  m1 := nako_getFuncArg(h, 5);
  m2 := nako_getFuncArg(h, 6);

  // (2) ����
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

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
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
  // (1) �����̎擾
  c  := getCanvas(nako_getFuncArg(h,0));
  ps := nako_getFuncArg(h, 1);

  // (2) ����
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

  // �`��
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

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_loadPic(h: DWORD): PHiValue; stdcall;
var
  s, x, y : PHiValue;
  xx, yy  : Integer;
  ss      : AnsiString;
  bmp     : TBitmap;
  c       : TCanvas;
begin
  // (1) �����̎擾
  //c := TCanvas( getCanvas(nako_getFuncArg(h, 0)) );
  x := nako_getFuncArg(h, 0);
  y := nako_getFuncArg(h, 1);
  s := nako_getFuncArg(h, 2);
  c := bokan.BackCanvas;

  // (2) �ȗ����̕⊮
  if (x=nil)and(y=nil) then
  begin
    x := baseX;
    y := baseY;
  end;

  xx := hi_int(x);
  yy := hi_int(y);
  ss := hi_str(s); // �t�@�C����

  // (3) ����
  bmp := LoadPic(string(ss));
  try
    c.Draw(xx, yy, bmp);
    hi_setInt(baseY, hi_int(baseY) + bmp.Height + 4);
  finally
    bmp.Free;
  end;
  // (4) ���ʂ̑��
  Bokan.flagRepaint := True;
  if Bokan.UseLineNo then
  begin
    Bokan.Redraw;
  end;
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;
function cmd_loadPic2(h: DWORD): PHiValue; stdcall;
var
  s, x, y : PHiValue;
  xx, yy  : Integer;
  ss      : AnsiString;
  bmp     : TBitmap;
  c       : TCanvas;
begin
  // (1) �����̎擾
  c := TCanvas( getCanvas(nako_getFuncArg(h, 0)) );
  x := nako_getFuncArg(h, 1);
  y := nako_getFuncArg(h, 2);
  s := nako_getFuncArg(h, 3);

  // (2) �ȗ����̕⊮
  if (x=nil)and(y=nil) then
  begin
    x := baseX;
    y := baseY;
  end;

  xx := hi_int(x);
  yy := hi_int(y);
  ss := hi_str(s); // �t�@�C����

  // (3) ����
  bmp := LoadPic(string(ss));
  try
    c.Draw(xx, yy, bmp);
    hi_setInt(baseY, hi_int(baseY) + bmp.Height + 4);
  finally
    bmp.Free;
  end;
  // (4) ���ʂ̑��
  if c.Handle = Bokan.BackCanvas.Handle then
  begin
    Bokan.flagRepaint := True;
  end;
  if Bokan.UseLineNo then
  begin
    Bokan.Redraw;
  end;
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_stop(h: DWORD): PHiValue; stdcall;
begin
  // (1) �����̎擾
  // (2) ����
  nako_stop;
  InvalidateRect(Bokan.Handle, nil, True);

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_closeWindow(h: DWORD): PHiValue; stdcall;
begin
  // (1) �����̎擾
  // (2) ����

  nako_stop;
  Bokan.Close;
  if Bokan.flagBokanSekkei then
  begin
    Halt; //�Ƃɂ����I��
  end;

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_keyState(h: DWORD): PHiValue; stdcall;
var
  code : Integer;
  //ks   : TKeyboardState;
  b    : Boolean;
begin
  // (1) �����̎擾
  code := hi_int(nako_getFuncArg(h, 0));

  // (2) ����
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
  // (3) ���ʂ̑��
  Result := hi_var_new; // �����Ԃ��Ȃ��ꍇ�� nil
  hi_setBool(Result, b);
end;

function cmd_sleep(h: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  w, endTime: DWORD;
begin
  // (1) �����̎擾
  p := nako_getFuncArg(h, 0);

  // (2) ����
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
    sleep(10); // CPU�p���[�ߖ񏈗�
  end;

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

//  AddFunc('�t�H���g�I��',    '',                    1400,@,   '�t�H���g��I�����ăt�H���g����Ԃ��B', '�ӂ���Ƃ��񂽂�');
//  AddFunc('�F�I��',          '',                    1402,@,  '�F��I�����ĕԂ��B', '���낹�񂽂�');
//  AddFunc('�v�����^�ݒ�',    '',                    1403,@,  '�v�����^��ݒ肷��B', '�Ղ�񂽂����Ă�');
//  AddFunc('�����L��',        '{=?}S��|S��|S��|S��', 1404,@cmd_dlgMemo,   '�G�f�B�^��S��\�����ҏW���ʂ���Ԃ��B', '�߂����ɂイ');

function cmd_dlgFont(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  // (1) �����̎擾
  // (2) ����
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
  // (1) �����̎擾
  // (2) ����
  if bokan.dlgColor.Execute then
  begin
    Result := hi_var_new;
    hi_setInt(Result, RGB2Color(bokan.dlgColor.Color));
  end;
end;

function cmd_dlgPrint(h: DWORD): PHiValue; stdcall;
begin
  // (1) �����̎擾
  // (2) ����
  Result := hi_newBool(bokan.dlgPrinter.Execute);
end;

function cmd_dlgMemo(h: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  f: TfrmMemo;
  init,cancel,ime, title: string;
begin
  Result := hi_var_new;

  // (1) �����̎擾
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;
  // (2) ����
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
  title  := hi_strU(nako_getVariable('�_�C�A���O�^�C�g��'));
  init   := hi_strU(nako_getVariable('�_�C�A���O�����l'));
  cancel := hi_strU(nako_getVariable('�_�C�A���O�L�����Z���l'));
  ime    := hi_strU(nako_getVariable('�_�C�A���OIME'));
  //-----------------------------------
  {$IFDEF IS_LIBVNAKO}
  if title = '' then title := '�Ȃł���';
  {$ELSE}
  if title = '' then title := (Application.Title);
  {$ENDIF}
end;

function getDialogS(ValueName: AnsiString; initValue: AnsiString): AnsiString; // �_�C�A���O�ڍׂ���l�����o��
var
  p, pp: PHiValue;
begin
  p := nako_getVariable('�_�C�A���O�ڍ�');
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

  // (1) �����̎擾
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;

  // (2) ����
  f := TfrmInput.Create(bokan);
  try
    f.lblCaption.Caption := string(hi_str(p));

    GetDialogSetting(title, init, cancel, ime);
    setDialogIME(f.edtMain.Handle);
    f.edtMain.Text := string(init);
    f.Caption := string(title);
    limit := Trunc(1000 * hi_float(nako_getVariable('�_�C�A���O�\������')));
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

  // (1) �����̎擾
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;

  // (2) ����
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
  // (1) �����̎擾
  // �Ȃ�

  // (2) ����
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

  // (1) �����̎擾
  px := nako_getFuncArg(h, 0);
  py := nako_getFuncArg(h, 1);
  ps := nako_getFuncArg(h, 2);
  if ps = nil then ps := nako_getSore;

  // (2) ����
  f := TfrmHukidasi.Create(bokan);
  try
    f.Left := hi_int(px);
    f.Top  := hi_int(py);
    getFont(bokan.Canvas);
    f.SetText(bokan.Canvas.Font, hi_strU(ps));
    // �[�����[�_��
    f.Show;
    while f.Res = False do
    begin
      Application.ProcessMessages;
      sleep(20);
    end;
    //---
  finally
    //�������
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


// �r�b�g�}�b�v�p������[�`�� by �����̗� �����l(http://www.asahi-net.or.jp/~HA3T-NKMR/tips004.htm)
procedure StretchDrawBitmap(Canvas:TCanvas; r : TRect; Bitmap:TBitmap); // �r�b�g�}�b�v
var
  OldMode   : integer;     // StretchMode�̕ۑ��p
  Info      : PBitmapInfo; // DIB�w�b�_�{�J���[�e�[�u��
  InfoSize  : DWord;       // DIB�w�b�_�{�J���[�e�[�u���̃T�C�Y
  Image     : Pointer;     // DIB�̃s�N�Z���f�[�^
  ImageSize : DWord;       // DIB�̃s�N�Z���f�[�^�̃T�C�Y
  dc        : HDC;         // GetDIBits �p Device Context
  OldPal    : HPALETTE;    // �p���b�g�ۑ��p
begin
  GetDIBSizes(Bitmap.Handle, InfoSize, ImageSize);
  Info:=nil;
  Image:=nil;
  try
    // 24 Bit DIB �̗̈���m��
    InfoSize := SizeOf(TBitmapInfoHeader) + 4 * 259;
    Info :=AllocMem(InfoSize);
    ImageSize := ((Bitmap.Width * 24 + 31) div 32) * 4 * Bitmap.Height;
    Image:=AllocMem(ImageSize);

    // DIB ��BitmapInfoHeader ��������
    with Info^.bmiHeader do begin
      biSize := SizeOf(TBitmapInfoHeader);
      biWidth := Bitmap.Width;
      biHeight := Bitmap.Height;
      biPlanes := 1;
      biBitCount := 24;
      biCompression := BI_RGB;
    end;

    dc := GetDC(0); // �ϊ��p�� DC ���l��
    try
      // �r�b�g�}�b�v�̃p���b�g��I��
      OldPal := 0;
      if Bitmap.Palette <> 0 then
        OldPal := SelectPalette(dc, Bitmap.Palette, True);

      // 24 bit DIB �𓾂�B
      GetDIBits(dc, Bitmap.Handle, 0, Bitmap.Height,
                Image, Info^, DIB_RGB_COLORS);
      // �p���b�g�����ɖ߂��B
      if OldPal <> 0 then SelectPalette(dc, OldPal, True);

      // �g�僂�[�h�� �J���[�p�ɕύX
      OldMode:=SetStretchBltMode(Canvas.Handle,COLORONCOLOR);

      // �`��I�I
      StretchDIBits(Canvas.Handle,
                    r.Left,r.Top,r.Right-r.Left,r.Bottom-r.Top,
                    0,0,Info^.bmiHeader.biWidth,Info^.bmiHeader.biHeight,
                    Image,Info^,DIB_RGB_COLORS,SRCCOPY);
      // �g�僂�[�h�����ɖ߂�
      SetStretchBltMode(Canvas.Handle,OldMode);

    // ��n��
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

  // (1) �����̎擾
  p := nako_getFuncArg(h, 0);
  // (2) ����
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

  // (1) �����̎擾
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;
  // (2) ����
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

  // (1) �����̎擾
  ps := nako_getFuncArg(h, 0);
  pv := nako_getFuncArg(h, 1);
  if ps = nil then ps := nako_getSore;
  // (2) ����
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

  // (1) �����̎擾
  ps := nako_getFuncArg(h, 0);
  if ps = nil then ps := nako_getSore;

  // (2) ����
  f := TfrmSay.Create(bokan);
  try
    try
      f.Close;          
      GetDialogSetting(title, init, cancel, ime);
      limit := Trunc(1000*hi_float(nako_getVariable('�_�C�A���O�\������')));
      //
      f.Caption := string(title);
      //-----------------------
      // �傫���̎w��
      getFontDialog(f.FBmp.Canvas.Font);
      //-----------------------
      // �e�L�X�g�̃Z�b�g
      f.SetProperty(hi_strU(ps));
      f.SetLimitTime(limit);
      // �\��
      ShowModalCheck(f, bokan);
    except
      on e: Exception do
        raise Exception.Create('�y�����z�ŃG���[�B' + e.Message);
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

  // (1) �����̎擾
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;
  msg := hi_strU(p);

  // (2) ����
  f := TfrmSay.Create(bokan);
  try
  try
    f.Close;
    f.UseNitaku;
    GetDialogSetting(title, init, cancel, ime);
    f.Caption := string(title);
    limit := Trunc(1000*hi_float(nako_getVariable('�_�C�A���O�\������')));
    //-----------------------
    // �傫���̎w��
    getFontDialog(f.FBmp.Canvas.Font);
    f.SetProperty(string(msg));
    f.SetLimitTime(limit);
    ShowModalCheck(f, bokan);
    Result := hi_newBool(f.Res);
  except on e: Exception do
    raise Exception.Create('�y����z�ŃG���[�B' + e.Message);
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
  // (1) �����̎擾
  msg := string(getArgStr(h, 0, True));
  Result := nil;

  // (2) ����
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
    raise Exception.Create('�y���X�g�i���ݑI���z�ŃG���[�B' + e.Message);
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
  // (1) �����̎擾
  con := getGui(nako_getFuncArg(h, 0));
  if con <> nil then
  begin
    TControl(con).Invalidate;
  end;
  Application.ProcessMessages;
  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_redraw(h: DWORD): PHiValue; stdcall;
begin
  Bokan.Redraw;
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_debug(h: DWORD): PHiValue; stdcall;
begin
  // (1) �����̎擾
  // (2) ����

  ShowModalCheck(frmDebug(bokan), bokan);

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
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
    raise Exception.Create('�I�u�W�F�N�g�ł͂Ȃ��̂Œ����Ɉړ��ł��܂���B');
  end;

  //�߂�l
  Result := nil;
end;

function cmd_textout(h: DWORD): PHiValue; stdcall;
var
  c: TCanvas;
  x, y, hh, i: Integer;
  s: AnsiString;
  sl: TStringList;
begin
  // ����
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
    hh := Trunc(c.TextHeight('��') * 1.2);
    for i:=0 to sl.Count -1 do
    begin
      SuperTextOut(c, x, y+i*hh, c.Font, sl.Strings[i]);
    end;
  finally
    sl.Free;
  end;

  // �߂�
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
  // �o�O���� ---- Application.Processmessage �Ńt�H�[���̈ړ����s���ƃG���[
  getFont(c);
  //
  sl := TStringList.Create ;
  try
    sl.Text := string(ExpandTab(s, hi_int(tabCount)));
    hh := Trunc(c.TextHeight('��') * 1.2);
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
            sleep(100); // CPU�g�p����������
          end;
        except
        end;
      end;
    end;
  finally
    sl.Free;
  end;

  // �߂�
end;

var flag_define_str_function: Byte = 0;

procedure define_str_function;
var
  s: AnsiString;
begin
  if flag_define_str_function <> 0 then Exit;
  flag_define_str_function := 1;
  // ---
  s := '�����x���\���p��`���i�f�V�R����B';
  nako_eval_str(s);
  //
  // --- --- --- ---
  // ���܂�
  nako_eval_str('_���ӂ́`�uIPA�̊F�l�A(��)�т��˂��Ƃ̋{������'#13#10+
  '�Ƃ������ASWinX����AEZNavi����'#13#10+
  '�������Ă������鑽���̕��X�Ɋ��ӂ��܂��B�v�ƌ����B');
end;


function cmd_textoutDelay(h: DWORD): PHiValue; stdcall;
var
  //o: TObject;
  //c: TCanvas;
  x, y, m: Integer;
  s, name: AnsiString;
begin
  // ����
  // o := getGui(nako_getFuncArg(h, 0)); // object
  // c := getCanvasFromObj(o);           // canvas
  name := getGuiName(nako_getFuncArg(h, 0));
  x := hi_int(nako_getFuncArg(h, 1));
  y := hi_int(nako_getFuncArg(h, 2));
  s := hi_str(nako_getFuncArg(h, 3));
  m := hi_int(nako_getFuncArg(h, 4));
  // textout_delay(o, c, x, y, s, m, True); // �o�O����
  Result := nil;
  //
  define_str_function;
  s := JReplaceA(s, '`', '�e');
  nako_eval_str(
    AnsiString(format('0����%s��%d,%d��`%s`��%d��SYS_�����x���`�揈��',
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
  // ����
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
  s := JReplaceA(s, '`', '�e');
  nako_eval_str(
    FormatA('1����%s��%d,%d��`%s`��%d��SYS_�����x���`�揈��',
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
  // ����
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

  // �߂�
  Result := nil;
end;

function cmd_mosaic(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  i: Integer;
  r: TRect;
begin
  // ����
  b := getBmp(nako_getFuncArg(h, 0));
  i := hi_int(nako_getFuncArg(h, 1));
  // ����
  r.Left := 0;
  r.Top  := 0;
  r.Right := b.Width;
  r.Bottom := b.Height;
  //
  try
    Mozaic(b, i, i, r);
  except end;
  // �߂�
  Result := nil;
end;

// �Ȃł����̉摜�ɂڂ������ʂ������閽�߁u�摜�{�J�V�v�̎�������
function cmd_blur(h: DWORD): PHiValue; stdcall;
var // �ϐ��錾
  bmp : TBitmap; // �r�b�g�}�b�v�^
  i   : Integer; // �����^
begin
  // (1) �Ȃł����̃V�X�e������������擾����
  bmp := getBmp(nako_getFuncArg(h, 0)); // �t�B���^�[��������Ώ�
  i   := hi_int(nako_getFuncArg(h, 1)); // �ǂ̒��x�̋����ł�����̂�
  // (2) �{�J�V���ʂ̃t�B���^�[�������� ... �G���[���o�Ă���������
  try
    BiLe2(i, bmp);
  except
  end;
  // (3) �߂�l�͂Ȃ��̂Ŗ��߂̌��ʂƂ��� nil ��Ԃ�
  Result := nil;
end;

function cmd_sharp(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  i: Integer;
begin
  // ����
  b := getBmp(nako_getFuncArg(h, 0));
  i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    Laplacian(i, b);
  except end;
  // �߂�
  Result := nil;
end;

function cmd_negaposi(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
begin
  // ����
  b := getBmp(nako_getFuncArg(h, 0));
  //
  try
    Nega(b);
  except end;
  // �߂�
  Result := nil;
end;

function cmd_mono(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  i: Integer;
begin
  // ����
  b := getBmp(nako_getFuncArg(h, 0));
  i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    Mono(i, b);
  except end;
  // �߂�
  Result := nil;
end;

function cmd_solarization(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  //i: Integer;
begin
  // ����
  b := getBmp(nako_getFuncArg(h, 0));
  //i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    Solarization(b);
  except end;
  // �߂�
  Result := nil;
end;

function cmd_sepia(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  i: Integer;
begin
  // ����
  b := getBmp(nako_getFuncArg(h, 0));
  i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    SepiaSuper(b, GetRValue(i), GetGValue(i), GetBValue(i));
  except end;
  // �߂�
  Result := nil;
end;

function cmd_pic90r(h: DWORD): PHiValue; stdcall;
var
  bmp: TBitmap;
  obj: TObject;
  o: PHiValue;
begin
  // ����
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
  // �߂�
  Result := nil;
end;

function cmd_pic90l(h: DWORD): PHiValue; stdcall;
var
  bmp: TBitmap;
  obj: TObject;
  o: PHiValue;
begin
  // ����
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
  // �߂�
  Result := nil;
end;

function cmd_picRotate(handle: DWORD): PHiValue; stdcall;
var
  bmp: TBitmap;
  obj: TObject;
  o  : PHiValue;
  a  : Integer;
begin
  // ����
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
  // �߂�
  Result := nil;
end;

function cmd_picRotateFast(handle: DWORD): PHiValue; stdcall;
var
  bmp: TBitmap;
  obj: TObject;
  o  : PHiValue;
  a  : Integer;
begin
  // ����
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
  // �߂�
  Result := nil;
end;

function cmd_VertRev(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  //i: Integer;
begin
  // ����
  b := getBmp(nako_getFuncArg(h, 0));
  //i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    VertReverse(b);
  except end;
  // �߂�
  Result := nil;
end;
function cmd_HorzRev(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  //i: Integer;
begin
  // ����
  b := getBmp(nako_getFuncArg(h, 0));
  //i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    HorzReverse(b);
  except end;
  // �߂�
  Result := nil;
end;

function cmd_Resize(h: DWORD): PHiValue; stdcall;
var
  bmp: TBitmap;
  obj: TObject;
  o: PHiValue;
  a, b: Integer;
begin
  // ����
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
  // �߂�
  Result := nil;
end;

function cmd_ResizeAspect(h: DWORD): PHiValue; stdcall;
var
  bmp: TBitmap;
  obj: TObject;
  o: PHiValue;
  a, b: Integer;
begin
  // ����
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
  // �߂�
  Result := nil;
end;


function cmd_ResizeAspectEx(h: DWORD): PHiValue; stdcall;
var
  bmp: TBitmap;
  obj: TObject;
  o: PHiValue;
  a, b: Integer;
begin
  // ����
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
  // �߂�
  Result := nil;
end;

function cmd_img_bit(h: DWORD): PHiValue; stdcall;
var
    o: PHiValue;
  gra: TBitmap;
    a: Integer;
begin
  // ����
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
  // �߂�
  Result := nil;
end;

function cmd_ResizeSpeed(h: DWORD): PHiValue; stdcall;
var
  bmp: TBitmap;
  obj: TObject;
  o: PHiValue;
  a, b: Integer;
begin
  // ����
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
  // �߂�
  Result := nil;
end;

function cmd_img_save(h: DWORD): PHiValue; stdcall;
var
  gra: TBitmap;
    s: AnsiString;
begin
  // ����
  gra := getBmp(nako_getFuncArg(h, 0));
  s   := hi_str(nako_getFuncArg(h, 1));
  //
  try
    SavePic(gra, string(s));
  except on e: Exception do
    raise Exception.Create('"' + string(s) + '"�ւ̕ۑ��Ɏ��s�B' + e.Message);
  end;
  // �߂�
  Result := nil;
end;

function cmd_img_alphaCopy(h: DWORD): PHiValue; stdcall;
var
  obj1, obj2: TBitmap;
  px,py,pa: PHiValue;
  x, y, a: Integer;
  abmp: TABitmap;
begin
  // {�O���[�v}OBJ1��{�O���[�v}OBJ2��X,Y��A��
  // ����
  obj1 := getBmp(nako_getFuncArg(h, 0)); {src��}
  obj2 := getBmp(nako_getFuncArg(h, 1)); {des��}
  px   := nako_getFuncArg(h, 2);
  py   := nako_getFuncArg(h, 3);
  pa   := nako_getFuncArg(h, 4);

  x := hi_int(px);
  y := hi_int(py);
  a := hi_int(pa);

  // (��)amp ���� (�\�[�X)xxx ��
  abmp := TABitmap.Create;
  try
    abmp.Assign(obj1);
    abmp.ColorAlpha(x, y, obj1.Width, obj1.Height, obj2, Trunc(a/100*256));
  finally
    abmp.Free;
  end;
  // �߂�
  Result := nil;
end;

function cmd_img_mask(h: DWORD): PHiValue; stdcall;
var
  obj: TBitmap;
  pc: PHiValue;
  abmp: TABitmap;
begin
  // {�O���[�v}OBJ1��{�O���[�v}OBJ2��X,Y��A��
  // ����
  obj := getBmp(nako_getFuncArg(h, 0));
  pc  := nako_getFuncArg(h, 1);

  abmp := TABitmap.Create;
  abmp.Assign(obj);
  abmp.Mask(RGB2Color(hi_int(pc)));
  obj.Assign(abmp);

  // �߂�
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
  // ����
  p1 := nako_getFuncArg(h, 0);
  p2 := nako_getFuncArg(h, 1);
  x  := hi_int(nako_getFuncArg(h, 2));
  y  := hi_int(nako_getFuncArg(h, 3));
  // �ϊ�
  obj1 := getBmp(p1);
  obj2 := getCanvas(p2);
  // �R�s�[
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
  // �߂�
  Result := nil;
end;

function cmd_img_copyAnd(h: DWORD): PHiValue; stdcall;
var
  obj1: TBitmap; p1, p2: PHiValue;
  obj2: TCanvas;
  x, y: Integer;
begin
  // ����
  p1 := nako_getFuncArg(h, 0);
  p2 := nako_getFuncArg(h, 1);
  x  := hi_int(nako_getFuncArg(h, 2));
  y  := hi_int(nako_getFuncArg(h, 3));
  // �ϊ�
  obj1 := getBmp(p1);
  obj2 := getCanvas(p2);
  obj1.PixelFormat := pf24bit;
  // �R�s�[
  BitBlt(obj2.Handle, x, y, obj1.Width, obj1.Height,
    obj1.Canvas.Handle, 0, 0, SRCAND);

  // �߂�
  Result := nil;
end;

function cmd_img_copyOr(h: DWORD): PHiValue; stdcall;
var
  obj1: TBitmap; p1, p2: PHiValue;
  obj2: TCanvas;
  x, y: Integer;
begin
  // ����
  p1 := nako_getFuncArg(h, 0);
  p2 := nako_getFuncArg(h, 1);
  x  := hi_int(nako_getFuncArg(h, 2));
  y  := hi_int(nako_getFuncArg(h, 3));
  // �ϊ�
  obj1 := getBmp(p1);
  obj2 := getCanvas(p2);
  obj1.PixelFormat := pf24bit;
  // �R�s�[
  BitBlt(obj2.Handle, x, y, obj1.Width, obj1.Height,
    obj1.Canvas.Handle, 0, 0, SRCPAINT);

  // �߂�
  Result := nil;
end;

function cmd_img_copyXOR(h: DWORD): PHiValue; stdcall;
var
  obj1: TBitmap; p1, p2: PHiValue;
  obj2: TCanvas;
  x, y: Integer;
begin
  // ����
  p1 := nako_getFuncArg(h, 0);
  p2 := nako_getFuncArg(h, 1);
  x  := hi_int(nako_getFuncArg(h, 2));
  y  := hi_int(nako_getFuncArg(h, 3));
  // �ϊ�
  obj1 := getBmp(p1);
  obj2 := getCanvas(p2);
  // �R�s�[
  BitBlt(obj2.Handle, x, y, obj1.Width, obj1.Height,
    obj1.Canvas.Handle, 0, 0, SRCINVERT);

  // �߂�
  Result := nil;
end;

function cmd_img_getC(h: DWORD): PHiValue; stdcall;
var
  obj: TCanvas;
  x, y: Integer;
begin
  // ����
  obj := getCanvas(nako_getFuncArg(h,0));
  x   := hi_int(nako_getFuncArg(h,1));
  y   := hi_int(nako_getFuncArg(h,2));
  // �߂�
  Result := hi_newInt(Color2RGB( obj.Pixels[x, y] ));
end;

function cmd_img_change(h: DWORD): PHiValue; stdcall;
var
  obj: TBitmap;
  a, b: Integer;
begin
  // ����
  obj := getBmp(nako_getFuncArg(h,0));
  a   := hi_int(nako_getFuncArg(h,1)); a := RGB2Color(a);
  b   := hi_int(nako_getFuncArg(h,2)); b := RGB2Color(b);
  // ����
  BmpColorChange(obj, a, b);

  // �߂�
  Result := nil;
end;

function cmd_img_linePic(h: DWORD): PHiValue; stdcall;
var
  obj: TBitmap;
begin
  // ����
  obj := getBmp(nako_getFuncArg(h,0));
  // ����
  LinePic(obj);
  // �߂�
  Result := nil;
end;

function cmd_img_edge(h: DWORD): PHiValue; stdcall;
var
  obj: TBitmap;
begin
  // ����
  obj := getBmp(nako_getFuncArg(h,0));
  // ����
  edge(obj);
  // �߂�
  Result := nil;
end;

function cmd_img_gousei(h: DWORD): PHiValue; stdcall;
var
  obj1, obj2, mask: TBitmap;
  x, y: Integer;
begin
  // ����
  obj1 := getBmp(nako_getFuncArg(h,0));
  obj2 := getBmp(nako_getFuncArg(h,1));
  x    := hi_int(nako_getFuncArg(h,2));
  y    := hi_int(nako_getFuncArg(h,3));

  // ����
  mask := TBitmap.Create;
  try
    mask.Assign(obj1);
    mask.Mask(mask.Canvas.Pixels[0,0]);

    // MASK ����
    BitBlt(obj2.Canvas.Handle, x, y, mask.Width, mask.Height,
      mask.Canvas.Handle, 0, 0, SRCAND);

    // �摜����
    BitBlt(obj2.Canvas.Handle, x, y, mask.Width, mask.Height,
      obj1.Canvas.Handle, 0, 0, SRCPAINT);
  finally
    mask.Free;
  end;
  // �߂�
  Result := nil;
end;

function cmd_img_copyEx(h: DWORD): PHiValue; stdcall;
var
  p1, p2: PHiValue;
  obj1, obj2: TCanvas;
  x, y, ww, hh, dx, dy: Integer;
begin
  // ����
  p1 := nako_getFuncArg(h, 0);
  x  := hi_int(nako_getFuncArg(h, 1));
  y  := hi_int(nako_getFuncArg(h, 2));
  ww := hi_int(nako_getFuncArg(h, 3));
  hh := hi_int(nako_getFuncArg(h, 4));
  p2 := nako_getFuncArg(h, 5);
  dx := hi_int(nako_getFuncArg(h, 6));
  dy := hi_int(nako_getFuncArg(h, 7));
  // �ϊ�
  obj1 := getCanvas(p1);
  obj2 := getCanvas(p2);
  // �R�s�[
  BitBlt(obj2.Handle, dx, dy, ww, hh, obj1.Handle, x, y, SRCCOPY);

  // �߂�
  Result := nil;
end;

function cmd_grayscale(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  //i: Integer;
begin
  // ����
  b := getBmp(nako_getFuncArg(h, 0));
  //i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    Grayscale(b);
  except end;
  // �߂�
  Result := nil;
end;

function cmd_gamma(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  i: Double;
begin
  // ����
  b := getBmp  (nako_getFuncArg(h, 0));
  i := hi_float(nako_getFuncArg(h, 1));
  //
  try
    Gamma(b, i);
  except end;
  // �߂�
  Result := nil;
end;

function cmd_contrast(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  i: Integer;
begin
  // ����
  b := getBmp(nako_getFuncArg(h, 0));
  i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    Contrast(i, b);
  except end;
  // �߂�
  Result := nil;
end;

function cmd_bright(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  i: Integer;
begin
  // ����
  b := getBmp(nako_getFuncArg(h, 0));
  i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    Bright(b, i);
  except end;
  // �߂�
  Result := nil;
end;

function cmd_noise(h: DWORD): PHiValue; stdcall;
var
  b: TBitmap;
  i: Integer;
begin
  // ����
  b := getBmp(nako_getFuncArg(h, 0));
  i := hi_int(nako_getFuncArg(h, 1));
  //
  try
    Noise(b, i mod 256);
  except end;
  // �߂�
  Result := nil;
end;

function vcl_free(h: DWORD): PHiValue; stdcall;
var
  g, v: PHiValue;
  obj: TObject;
begin
  Result := nil;
  g := nako_getFuncArg(h, 0); // group
  v := nako_group_findMember(g, '�I�u�W�F�N�g');
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
        TControl(obj).Visible := False; // ��ł�������������
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
    // BUG (@303) �e���i�Ƀ^�u�y�[�W���w�肳�ꂽ���̑Ώ�
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
  // (1) �����̎擾
  // g := nako_getFuncArg(h, 0); // group
  n := nako_getFuncArg(h, 1); // name
  t := nako_getFuncArg(h, 2); // gui type

  oName := hi_str(n);
  oType := hi_int(t);

  getFont(bokan.Canvas);
  fontname := bokan.Canvas.Font.Name;
  fontsize := bokan.Canvas.Font.Size;

  if parentObj = nil then parentObj := Bokan;

  // (2) ����
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
          // ���[�U�[�̗v�]�ɂ��V���[�g�J�b�g�L�[�̋����ύX
          for i := 0 to PopupMenu.Items.Count - 1 do
          begin
            if PopupMenu.Items.Items[i].Caption = '��蒼��(&R)' then
            begin
              PopupMenu.Items.Items[i].ShortCut := TextToShortCut('Ctrl+Y');
            end else
            if PopupMenu.Items.Items[i].Caption = '���ׂđI��(&A)' then
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
          //
          FTempX := frmNako.Left + 100;
          FTempY := frmNako.Top + 100;
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
{$IF RTLVersion < 20}
        o := TTntButton.Create(parentObj);
        with TTntButton(o) do begin
{$ELSE}
        o := TButton.Create(parentObj);
        with TButton(o) do begin
{$IFEND}
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
{$IF RTLVersion < 20}
        o := TTntEdit.Create(parentObj);
        with TTntEdit(o) do begin
{$ELSE}
        o := TEdit.Create(parentObj);
        with TEdit(o) do begin
{$IFEND}
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
{$IF RTLVersion < 20}
        o := TTntMemo.Create(parentObj);
        with TTntMemo(o) do begin
{$ELSE}
        o := TMemo.Create(parentObj);
        with TMemo(o) do begin
{$IFEND}
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
{$IF RTLVersion < 20}
        o := TTntListBox.Create(parentObj);
        with TTntListBox(o) do begin
{$ELSE}
        o := TListBox.Create(parentObj);
        with TListBox(o) do begin
{$IFEND}
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
{$IF RTLVersion < 20}
        o := TTntComboBox.Create(parentObj);
        with TTntComboBox(o) do begin
{$ELSE}
        o := TComboBox.Create(parentObj);
        with TComboBox(o) do begin
{$IFEND}
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
{$IF RTLVersion < 20}
        o := TTntCheckBox.Create(parentObj);
        with TTntCheckBox(o) do begin
{$ELSE}
        o := TCheckBox.Create(parentObj);
        with TCheckBox(o) do begin
{$IFEND}
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
{$IF RTLVersion < 20}
        o := TTntRadioGroup.Create(parentObj);
        with TTntRadioGroup(o) do begin
{$ELSE}
        o := TRadioGroup.Create(parentObj);
        with TRadioGroup(o) do begin
{$IFEND}
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
{$IF RTLVersion < 20}
        o := TTntStringGrid.Create(parentObj);
        with TTntStringGrid(o) do begin
{$ELSE}
        o := TStringGrid.Create(parentObj);
        with TStringGrid(o) do begin
{$IFEND}
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
{$IF RTLVersion < 20}
        o := TTntLabel.Create(parentObj);
        with TTntLabel(o) do begin
{$ELSE}
        o := TLabel.Create(parentObj);
        with TLabel(o) do begin
{$IFEND}
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
      raise Exception.Create('VCL_CREATE�Ŗ���`��VCL�^�C�v');
  end;

  // �w���p�[�ɓo�^
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

  // (3) ���ʂ̑��
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
    var
{$IF RTLVersion < 20}
      g: TTntStringGrid;
{$ELSE}
      g: TStringGrid;
{$IFEND}
      i: Integer;
    begin
      Result := '';

{$IF RTLVersion < 20}
      g := TTntStringGrid(obj);
{$ELSE}
      g := TStringGrid(obj);
{$IFEND}
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
{$IF RTLVersion < 20}
      VCL_GUI_UBUTTON     : res := uni2ansi(TTntButton(obj).Caption);
      VCL_GUI_UEDIT :
 	      begin
         	res := uni2ansi(TTntEdit(obj).Text);
 	        // ShowMessage(StrToHexStr(res)); // ok
 	      end;
 	    VCL_GUI_UMEMO : res := uni2ansi(TTntMemo(obj).Text);
     	VCL_GUI_ULIST : if TTntListBox(obj).ItemIndex >= 0 then res := uni2ansi(TTntListBox(obj).Items.Strings[TTntListBox(obj).ItemIndex]);
 	    VCL_GUI_UCOMBO : res := uni2ansi(TTntComboBox(obj).Text);
 	    VCL_GUI_UCHECK : res := uni2ansi(TTntCheckBox(obj).Caption);
 	    VCL_GUI_URADIO : res := uni2ansi(TTntRadioGroup(obj).Caption);
 	    VCL_GUI_UGRID : res := uni2ansi(getGridTextUni);
     	VCL_GUI_ULABEL : res := uni2ansi(TTntLabel(obj).Caption);
{$ELSE}
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
{$IFEND}
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
{$IF RTLVersion < 20}
      VCL_GUI_ULIST : res := TTntListBox(obj).ItemIndex;
    	VCL_GUI_UCOMBO : res := TTntComboBox(obj).ItemIndex;
 	    VCL_GUI_UGRID : res := TTntStringGrid(obj).Row;
    	VCL_GUI_URADIO : res := TTntRadioGroup(obj).ItemIndex;
{$ELSE}
      VCL_GUI_ULIST        : res := TListBox(obj).ItemIndex;
      VCL_GUI_UCOMBO       : res := TComboBox(obj).ItemIndex;
      VCL_GUI_UGRID        : res := TStringGrid(obj).Row;
      VCL_GUI_URADIO       : res := TRadioGroup(obj).ItemIndex;
{$IFEND}
      else raise Exception.Create('��`����Ă��܂���B');
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
{$IF RTLVersion < 20}
      VCL_GUI_ULIST : res := uni2ansi(TTntListBox(obj).Items.Text);
 	    VCL_GUI_UCOMBO: res := uni2ansi(TTntComboBox(obj).Items.Text);
 	    VCL_GUI_URADIO: res := uni2ansi(TTntRadioGroup(obj).Items.Text);
 	    VCL_GUI_UGRID:
 	      begin
 	        csv := TCsvSheet.Create;
 	        try
 	          CsvGridGetDataUni(TTntStringGrid(obj), csv);
 	          res := csv.AsText;
 	        finally
 	          csv.Free;
 	        end;
 	      end;
{$ELSE}
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
{$IFEND}
      else raise Exception.Create('��`����Ă��܂���B');
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
{$IF RTLVersion < 20}
      VCL_GUI_UEDIT : res := uni2ansi(TTntEdit(obj).SelText);
 	    VCL_GUI_UMEMO : res := uni2ansi(TTntMemo(obj).SelText);
 	    VCL_GUI_UCOMBO : res := uni2ansi(TTntComboBox(obj).SelText);
{$ELSE}
      VCL_GUI_UEDIT    : res := (TEdit(obj).SelText);
      VCL_GUI_UMEMO    : res := (TMemo(obj).SelText);
      VCL_GUI_UCOMBO   : res := (TComboBox(obj).SelText);
{$IFEND}
      else raise Exception.Create('��`����Ă��܂���B');
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
{$IF RTLVersion < 20}
 	    VCL_GUI_UEDIT : res := TTntEdit(obj).SelStart;
    	VCL_GUI_UMEMO : res := TTntMemo(obj).SelStart;
     	VCL_GUI_UCOMBO : res := TTntComboBox(obj).SelStart;
{$ELSE}
      VCL_GUI_UEDIT    : res := TEdit(obj).SelStart;
      VCL_GUI_UMEMO    : res := TMemo(obj).SelStart;
      VCL_GUI_UCOMBO   : res := TComboBox(obj).SelStart;
{$IFEND}
      else raise Exception.Create('��`����Ă��܂���B');
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
{$IF RTLVersion < 20}
      VCL_GUI_UEDIT : res := TTntEdit(obj).SelLength;
     	VCL_GUI_UMEMO : res := TTntMemo(obj).SelLength;
    	VCL_GUI_UCOMBO : res := TTntComboBox(obj).SelLength;
{$ELSE}
      VCL_GUI_UEDIT    : res := TEdit(obj).SelLength;
      VCL_GUI_UMEMO    : res := TMemo(obj).SelLength;
      VCL_GUI_UCOMBO   : res := TComboBox(obj).SelLength;
{$IFEND}
      else raise Exception.Create('��`����Ă��܂���B');
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
        alTop:      res := '��';
        alBottom:   res := '��';
        alLeft:     res := '��';
        alRight:    res := '�E';
        alClient:   res := '�S��';
      end;
      hi_setStr(Result, res);
    end else
    begin
      raise Exception.Create('��`����Ă��܂���B');
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
  // (1) �����̎擾
  s := nako_getFuncArg(h, 0);
  a := nako_getFuncArg(h, 1);

  prop  := hi_int(a);
  obj   := TComponent(hi_int(s));
  if obj = nil then raise Exception.Create('�v���p�e�B�ԍ�('+IntToStr(prop)+')�̎擾�ŁA�I�u�W�F�N�g�����ł��܂���B');
  ginfo := GuiInfos[obj.Tag];


  Result := nako_var_new(nil);

  // (2) ����
  // (3) ���ʂ̑��
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
      string(ginfo.name) + '�̃v���p�e�B(' + IntToStr(prop) + ')�̎擾�ŃG���[�B');
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
    var
{$IF RTLVersion < 20}
      g: TTntStringGrid;
{$ELSE}
      g: TStringGrid;
{$IFEND}
      c: TCsvSheet;
      i: Integer;
    begin
{$IF RTLVersion < 20}
      g := TTntStringGrid(obj);
{$ELSE}
      g := TStringGrid(obj);
{$IFEND}
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
          g.Cells[g.Col, g.Row] := ansi2uni(v);
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
      try
        for i:=0 to sl.count-1 do
        begin
          if i >= bar.Panels.Count then
            panel := bar.Panels.Add
          else
            panel := bar.Panels.Items[i];
          panel.Text := sl.Strings[i];
        end;
        for i := sl.count to bar.Panels.Count - 1 do
          bar.Panels.Delete(bar.Panels.Count - 1);
      finally
        sl.Free;
      end;
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
{$IF RTLVersion < 20}
      VCL_GUI_UBUTTON     : TTntButton(obj).Caption := ansi2uni(s);
 	    VCL_GUI_UEDIT       :
 	      begin
 	        TTntEdit(obj).Text := ansi2uni(s);
 	      end;
 	    VCL_GUI_UMEMO       : TTntMemo(obj).Text := ansi2uni(s);
 	    VCL_GUI_ULIST       : begin if TTntListBox(obj).ItemIndex >= 0 then TListBox(obj).Items[TTntListBox(obj).ItemIndex] := ansi2uni(s); end;
 	    VCL_GUI_UCOMBO      : TTntComboBox(obj).Text := ansi2uni(s);
 	    VCL_GUI_UCHECK      : TTntCheckBox(obj).Caption := ansi2uni(s);
 	    VCL_GUI_URADIO      : TTntRadioGroup(obj).Caption:= ansi2uni(s);
 	    VCL_GUI_UGRID       : setGridTextUni(s);
     	VCL_GUI_ULABEL      : begin TTntLabel(obj).AutoSize := True; TTntLabel(obj).Caption := ansi2uni(s); TTntLabel(obj).AutoSize := False; end;
{$ELSE}
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
{$IFEND}
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
{$IF RTLVersion < 20}
      VCL_GUI_ULIST       : TTntListBox(obj).ItemIndex := i;
 	    VCL_GUI_UCOMBO      : TTntComboBox(obj).ItemIndex := i;
 	    VCL_GUI_UGRID       : TTntStringGrid(obj).Row := i;
 	    VCL_GUI_URADIO      : TTntRadioGroup(obj).ItemIndex := i;
    	VCL_GUI_UCHECK      : TTntCheckBox(obj).Checked := (i<>0);
{$ELSE}
      VCL_GUI_ULIST        : TListBox(obj).ItemIndex  := i;
      VCL_GUI_UCOMBO       : TComboBox(obj).ItemIndex := i;
      VCL_GUI_UGRID        : TStringGrid(obj).Row := i;
      VCL_GUI_URADIO       : TRadioGroup(obj).ItemIndex := i;
      VCL_GUI_UCHECK       : TCheckBox(obj).Checked := (i<>0);
{$IFEND}
      else raise Exception.Create('��`����Ă��܂���B');
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
{$IF RTLVersion < 20}
      VCL_GUI_ULIST       : TTntListBox(obj).Items.Text := ansi2uni(hi_str(v));
 	    VCL_GUI_UCOMBO      : TTntComboBox(obj).Items.Text := ansi2uni(hi_str(v));
 	    VCL_GUI_URADIO      : TTntRadioGroup(obj).Items.Text := ansi2uni(hi_str(v));
 	    VCL_GUI_UGRID       :
 	      begin
 	        csv := TCsvSheet.Create;
 	        try
 	          csv.setTextW(Trim(ansi2uni(hi_str(v))), ',');
 	          with TTntStringGrid(obj) do
 	          begin
 	            if csv.Count >= 2 then
 	              RowCount := csv.Count
 	            else
 	              RowCount := 2;
           	  CsvGridSetDataUni(TTntStringGrid(obj), csv);
 	            CsvGridAutoColWidthUni(TTntDrawGrid(obj), csv);
 	          end;
 	        finally
 	          csv.Free;
 	        end;
        end;
{$ELSE}
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
{$IFEND}
      else raise Exception.Create('��`����Ă��܂���B');
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
{$IF RTLVersion < 20}
      VCL_GUI_UEDIT    : TTntEdit(obj).SelText         := ansi2uni(res);
      VCL_GUI_UMEMO    : TTntMemo(obj).SelText         := ansi2uni(res);
      VCL_GUI_UCOMBO   : TTntComboBox(obj).SelText     := ansi2uni(res);
{$ELSE}
      VCL_GUI_UEDIT    : TEdit(obj).SelText       := (res);
      VCL_GUI_UMEMO    : TMemo(obj).SelText       := (res);
      VCL_GUI_UCOMBO   : TComboBox(obj).SelText   := (res);
{$IFEND}
      else raise Exception.Create('��`����Ă��܂���B');
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
{$IF RTLVersion < 20}
        VCL_GUI_UEDIT    : TTntEdit(obj).SelStart      := res;
        VCL_GUI_UMEMO    : TTntMemo(obj).SelStart      := res;
        VCL_GUI_UCOMBO   : TTntComboBox(obj).SelStart  := res;
{$ELSE}
        VCL_GUI_UEDIT    : TEdit(obj).SelStart      := res;
        VCL_GUI_UMEMO    : TMemo(obj).SelStart      := res;
        VCL_GUI_UCOMBO   : TComboBox(obj).SelStart  := res;
{$IFEND}
        else raise Exception.Create('��`����Ă��܂���B');
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
{$IF RTLVersion < 20}
      VCL_GUI_UEDIT    : TTntEdit(obj).SelLength      := res;
      VCL_GUI_UMEMO    : TTntMemo(obj).SelLength      := res;
      VCL_GUI_UCOMBO   : TTntComboBox(obj).SelLength  := res;
{$ELSE}
      VCL_GUI_UEDIT    : TEdit(obj).SelLength      := res;
      VCL_GUI_UMEMO    : TMemo(obj).SelLength      := res;
      VCL_GUI_UCOMBO   : TComboBox(obj).SelLength  := res;
{$IFEND}
      else raise Exception.Create('��`����Ă��܂���B');
    end;
  end;
  procedure _layout;
  var s: AnsiString; i: TAlign;
  begin
    s := hi_str(v);
    if obj is TControl then
    begin
      i := alNone;
      if s = '�S��' then i := alClient else
      if s = '��'   then i := alTop    else
      if s = '��'   then i := alBottom else
      if s = '��'   then i := alLeft   else
      if s = '�E'   then i := alRight  else
      ;
      //raise Exception.Create('"'+s+'"�͒�`����Ă��܂���B');
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
      if not(oya is TWinControl) and (oya <> nil) then raise Exception.Create('�e�ɐݒ肷�邱�Ƃ��ł��܂���B');

      if obj is TControl then
      begin
        TControl(obj).Parent := oya as TWinControl;
      end;
    except
      raise Exception.Create('�e�ɐݒ肷�邱�Ƃ��ł��܂���ł����B');
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
  // (1) �����̎擾
  s := nako_getFuncArg(h, 0); // obj
  a := nako_getFuncArg(h, 1); // prop
  v := nako_getFuncArg(h, 2); // value

  // (2) ����
  obj   := TComponent(hi_int(s));
  prop  := hi_int(a);
  if obj = nil then
  begin
    raise Exception.Create('VCL_SET�Ńv���p�e�B�ԍ�('+IntToStr(prop)+')�̐ݒ�ŁA�I�u�W�F�N�g�̒l��(nil)�ł��B�I�u�W�F�N�g����������Ă��Ȃ��\��������܂��B');
  end;
  try
    ginfo := GuiInfos[obj.Tag];
  except
    raise Exception.Create('VCL_SET�Ńv���p�e�B�ԍ�('+IntToStr(prop)+')�̐ݒ�ŁA�I�u�W�F�N�g�����ł��܂���B');
  end;
  try
    case prop of
      VCL_PROP_X      : if obj is TControl then begin TControl(obj).Left   := hi_int(v); if obj is TfrmNako then TfrmNako(obj).FTempX := hi_int(v); end;
      VCL_PROP_Y      : if obj is TControl then begin TControl(obj).Top    := hi_int(v); if obj is TfrmNako then TfrmNako(obj).FTempY := hi_int(v); end;
      VCL_PROP_W      : if obj is TControl then begin TControl(obj).Width  := hi_int(v); end;
      VCL_PROP_H      : if obj is TControl then begin TControl(obj).Height := hi_int(v); end;
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
      else raise Exception.Create(IntToStr(prop)+' �͓ǎ��p�̃v���p�e�B�ł��B');
    end;
  except
    raise Exception.Create(string(ginfo.name) + '�̃v���p�e�B(' + IntToStr(prop) + ')�̐ݒ�ŃG���[�B');
  end;

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
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
    if cmd = '�摜�ݒ�' then
    begin
      TToolButton(o).ImageIndex := hi_int(v);
    end else
    if cmd = '�摜�擾' then
    begin
      Result := hi_var_new;
      hi_setInt(Result, TToolButton(o).ImageIndex);
    end;
  end;
  procedure _VCL_GUI_TREEVIEW;
  var s: string; tn: TTreeNode; e: THiTreeView; xx, yy: Integer;
  begin
    e := THiTreeView(obj);
    if cmd = '�摜�ݒ�' then
    begin
      if hi_int(v) = 0 then raise Exception.Create('��̃C���[�W���X�g�͐ݒ�ł��܂���B');
      TTreeView(obj).Images := TImageList(hi_int(v));
    end else
    if cmd = '�폜' then
    begin
      try
        TTreeView(obj).Items[ hi_int(v) ].Delete;
      except
      end;
    end else;
    if cmd = '�X�^�C���ݒ�' then //��|���[�g|�{�^��
    begin
      s := hi_strU(v);
      TTreeView(obj).ShowLines := (Pos('��',    s) > 0);
      TTreeView(obj).ShowRoot  := (Pos('���[�g',s) > 0);
      TTreeView(obj).ShowButtons := (Pos('�{�^��',s) > 0);
    end else
    if cmd = '�C���f���g�擾' then
    begin
      Result := hi_var_new;
      hi_setInt(Result, TTreeView(obj).Indent);
    end else
    if cmd = '�C���f���g�ݒ�' then
    begin
      TTreeView(obj).Indent := hi_int(v);
    end else
    if cmd = 'GET�ǎ��p' then
    begin
      Result := hi_var_new;
      hi_setBool(Result, TTreeView(obj).ReadOnly);
    end else
    if cmd = 'SET�ǎ��p' then
    begin
      TTreeView(obj).ReadOnly := ( hi_int(v) <> 0 );
    end else
    if cmd = '�I���p�X�擾' then
    begin
      Result := hi_var_new;
      tn := TTreeView(obj).Selected;
      if tn = nil then Exit;
      hi_setStrU(Result, THiTreeNode(tn.Data).GetTreePathText);
    end else
    if cmd = '�h���b�v�p�X�擾' then
    begin
      Result := hi_newStr(AnsiString(e.dropPath));
    end else
    if cmd = '�m�[�h����' then
    begin
      s := hi_strU(v);
      xx := StrToIntDef(getToken_s(s, ','), -1);
      yy := StrToIntDef(s,-1);
      if(xx<0)or(yy<0)then Exit;
      tn := e.GetNodeAt(xx, yy);
      if tn <> nil then
        Result := hi_newStr(AnsiString( THiTreeNode(tn.Data).IDStr ));
    end
    else if cmd = '�I���p�X�ݒ�' then THiTreeView(obj).SetSelectPath(hi_strU(v))
    else if cmd = '�I��ID�擾' then Result := hi_newStr(AnsiString(THiTreeView(obj).SelectedID))
    else if cmd = '�I��ID�ݒ�' then THiTreeView(obj).SelectedID := hi_strU(v)
    else if cmd = '�A�C�e����' then Result := hi_newInt(THiTreeView(obj).list.Count)
    else if cmd = '�e�L�X�g�ύX' then THiTreeView(obj).ChangeText(hi_strU(v))
    else if cmd = '�摜�ԍ��ύX' then THiTreeView(obj).ChangePic(hi_strU(v))
    else if cmd = '�I���摜�ԍ��ύX' then THiTreeView(obj).ChangeSelectPic(hi_strU(v))
    else if cmd = '�m�[�h�폜' then THiTreeView(obj).DeleteID(hi_strU(v))
    else if cmd = '�m�[�h�J��'   then THiTreeView(obj).ExpandAllID(hi_strU(v))
    else if cmd = '�m�[�h����' then THiTreeView(obj).CollapseAllID(hi_strU(v))
    else if cmd = '�m�[�h��i�J��'   then THiTreeView(obj).ExpandID(hi_strU(v))
    else if cmd = '�m�[�h��i����' then THiTreeView(obj).CollapseID(hi_strU(v))
    else if cmd = '�m�[�h�ԍ��擾' then Result := hi_newInt(THiTreeView(obj).list.FindID(hi_strU(v)))
    else if cmd = '�m�[�h�J�擾' then
    begin
      if THiTreeView(obj).GetExpanded(hi_strU(v)) then
        Result := hi_newStrU('�J')
      else
        Result := hi_newStrU('��');
    end
    else if cmd = '�e�m�[�h�擾'   then Result := hi_newStrU(THiTreeView(obj).GetParentID(hi_strU(v)))
    else if cmd = '�q�m�[�h�擾'   then Result := hi_newStrU(THiTreeView(obj).GetChildrenID(hi_strU(v)))
    else
    if cmd = 'POPUP' then TTreeView(obj).PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '�����T�C�YSET' then e.Font.Size := hi_int(v) else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '�w�i�F�擾' then setRes(Color2RGB(e.Color))  else
    if cmd = '�w�i�F�ݒ�' then begin
      e.Color := RGB2Color(hi_int(v));
    end else
    ;
  end;
  procedure _VCL_GUI_LISTVIEW;
  var s: AnsiString; e: THiListView;
  begin
    e := THiListView(obj);
    if cmd = '�摜�ݒ�' then
    begin
      if hi_int(v) = 0 then raise Exception.Create('��̃C���[�W���X�g�͐ݒ�ł��܂���B');
      TListView(obj).LargeImages := TImageList(hi_int(v));
      TListView(obj).SmallImages := TImageList(hi_int(v));
    end else
    if cmd = '�폜' then
    begin
      try
        TListView(obj).Items[ hi_int(v) ].Delete;
      except
      end;
    end else
    if cmd = '�X�^�C���ݒ�' then
    begin
      s := hi_str(v);
      if s = '�A�C�R��'         then TListView(obj).ViewStyle := vsIcon      else
      if s = '�X���[���A�C�R��' then TListView(obj).ViewStyle := vsSmallIcon else
      if s = '���X�g'           then TListView(obj).ViewStyle := vsList      else
      if s = '���|�[�g'         then TListView(obj).ViewStyle := vsReport    else
      TListView(obj).ViewStyle := vsIcon;
    end else
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '�����T�C�YSET' then e.Font.Size := hi_int(v) else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '�w�i�F�擾' then setRes(Color2RGB(e.Color))  else
    if cmd = '�w�i�F�ݒ�' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = '�ҏW�ݒ�' then e.ReadOnly := not hi_bool(v) else
    if cmd = '�ҏW�擾' then Result := hi_newBool(not e.ReadOnly) else
    if cmd = '�����I���擾' then Result := hi_newBool(e.MultiSelect) else
    if cmd = '�����I��ݒ�' then e.MultiSelect := hi_bool(v) else
    if cmd = '�I���m�F' then
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
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then begin setFontName(e.Font, string(hi_str(v))); end else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size); end else
    if cmd = '�����T�C�YSET' then begin e.Font.Size := hi_int(v); end else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '�w�i�F�擾' then setRes(Color2RGB(e.Color))  else
    if cmd = '�w�i�F�ݒ�' then e.Color := RGB2Color(hi_int(v)) else
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
    if cmd = '�ҏW�ݒ�' then e.ReadOnly := not hi_bool(v) else
    if cmd = '�ҏW�擾' then Result := hi_newBool(not e.ReadOnly) else
    if cmd = 'IME�擾' then Result := hi_newStr(getIMEStatusName(e.ImeMode)) else
    if cmd = 'IME�ݒ�' then e.ImeMode := setControlIME(hi_str(v)) else
    if cmd = '�p�X���[�h���[�h�擾' then Result := hi_newBool(e.PasswordChar=#0) else
    if cmd = '�p�X���[�h���[�h�ݒ�' then if hi_bool(v) then e.PasswordChar := '*' else e.PasswordChar := #0 else
    ;
  end;

  procedure memoToLine(memo: TMemo; ToLine: Integer);
  var
    NowLine: Integer;
  begin
    if stdctrls.TMemo(memo) is TMemoXp then
    begin
      with TMemoXp(Memo) do
      begin
        NowLine:=Perform(EM_LINEFROMCHAR,SelStartU,0);
        Perform(EM_LINESCROLL,0,ToLine-NowLine);
        SelStartU:=Perform(EM_LINEINDEX,ToLine,0);
      end;
    end else begin
      with Memo do
      begin
        NowLine:=Perform(EM_LINEFROMCHAR,SelStart,0);
        Perform(EM_LINESCROLL,0,ToLine-NowLine);
        SelStart:=Perform(EM_LINEINDEX,ToLine,0);
      end;
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

    function _setDelphiColor: TFountain;
    var t: TDelphiFountain;
    begin
      t := TDelphiFountain.Create(Bokan);
      t.Comment.Color := clGrayText;
      t.Str.Color := clBlue;
      t.Int.Color := clGreen;
      Result := t;
    end;
    function _setJava: TFountain;
    var t: TJavaFountain;
    begin
      t := TJavaFountain.Create(Bokan);
      t.Comment.Color := clGrayText;
      t.Str.Color := clBlue;
      t.Int.Color := clGreen;
      Result := t;
    end;
    function _setCpp: TFountain;
    var t: TCppFountain;
    begin
      t := TCppFountain.Create(Bokan);
      t.Comment.Color := clGrayText;
      t.Str.Color := clBlue;
      t.Int.Color := clGreen;
      t.PreProcessor.Color := clPurple;
      Result := t;
    end;
    function _setPerl: TFountain;
    var t: TPerlFountain;
    begin
      t := TPerlFountain.Create(Bokan);
      t.Comment.Color := clGrayText;
      t.DoubleQuotation.Color := clBlue;
      t.Here.Color := clBlue;
      t.Int.Color := clGreen;
      t.PerlVar.Color := clMaroon;
      t.Pattern.Color := clGreen;
      Result := t;
    end;

    procedure setcoloring;
    var s: string;
    begin
      // TODO
      s := UpperCase(hi_strU(v));
      if s = 'HTML'     then e.Fountain := _setHTMLColor else
      if s = 'DELPHI'   then e.Fountain := _setDelphiColor else
      if s = 'CPP'      then e.Fountain := _setCpp else
      if s = 'JAVA'     then e.Fountain := _setJava else
      if s = 'PERL'     then e.Fountain := _setPerl else
      if s = '�Ȃł���' then e.Fountain := TNadesikoFountain.Create(Bokan) else
      if (s = '')or(s = 'TEXT') then e.Fountain := nil else
      raise Exception.Create(s + '�̓T�|�[�g���Ă��܂���BHTML/DELPHI/PERL/CPP/JAVA/TEXT/�Ȃł����̂�');
      // �⑫
      if (e.Fountain <> nil) then begin
        e.Fountain.Reserve.Color := clNavy;
        e.Fountain.Reserve.Style := [fsBold];
      end;
    end;

  begin
    e := THiEditor(obj);
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '�����T�C�YSET' then e.Font.Size := hi_int(v) else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '�w�i�F�擾' then setRes(Color2RGB(e.Color))  else
    if cmd = '�w�i�F�ݒ�' then e.Color := RGB2Color(hi_int(v)) else
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
    if cmd = '�P��I��' then e.SelectTokenFromCaret else
    if cmd = '�J���[�����O' then setcoloring else
    if cmd = 'GETCUR_X' then setRes(e.GetCaretXY.X) else
    if cmd = 'GETCUR_Y' then setRes(e.GetCaretXY.Y) else
    if cmd = 'SETCUR_X' then e.SetCaretXY(hi_int(v), e.GetCaretXY.X) else
    if cmd = 'SETCUR_Y' then e.SetCaretXY(e.GetCaretXY.Y, hi_int(v)) else
    if cmd = '���[���[' then e.Ruler.Visible := hi_bool(v) else
    if cmd = '���o�['   then e.Leftbar.Visible := hi_bool(v) else
    if cmd = '�\���L��' then e.ViewFlag(hi_str(v)) else
    if cmd = '�܂�Ԃ�' then begin e.WordWrap := (hi_int(v) >= 1); e.WrapOption.WrapByte := hi_int(v) end else
    if cmd = '�������ݒ�' then begin if e.Fountain = nil then e.ReserveWordList.Text := hi_strU(v) else e.Fountain.ReserveWordList.Text := hi_strU(v) end else
    if cmd = '�������擾' then begin if e.Fountain = nil then setResS(e.ReserveWordList.Text) else setResS(e.Fountain.ReserveWordList.Text) end else
    if cmd = '�I�[�g�C���f���g�ݒ�' then e.Caret.AutoIndent := hi_bool(v) else
    if cmd = '�I�[�g�C���f���g�擾' then setRes(ord(e.Caret.AutoIndent))  else
    if cmd = '�ݒ�p�l���\��' then
    begin
      if EditEditorProp(bokan.edtPropNormal,nil) then
      begin
        bokan.edtPropNormal.AssignTo(e);
      end;
    end else
    if cmd = '�J���[�����O�p�l���\��' then
    begin
      if EditEditorProp(bokan.edtPropNormal,nil) then
      begin
        bokan.edtPropNormal.AssignTo(e);
      end;
    end else
    if cmd = '�ݒ�ۑ�' then begin Bokan.edtPropNormal.Assign(e); Bokan.edtPropNormal.WriteIni(hi_strU(v),'TEditor','edit'); end else
    if cmd = '�ݒ�Ǎ�' then begin try Bokan.edtPropNormal.ReadIni(hi_strU(v),'TEditor','edit'); except end; Bokan.edtPropNormal.AssignTo(e); end else
    if cmd = '������ݒ�'     then begin e.PutMark(hi_int(v));  end else
    if cmd = '������W�����v' then begin e.GotoMark(hi_int(v)); end else
    if cmd = '�ҏW�ݒ�' then e.ReadOnly := not hi_bool(v) else
    if cmd = '�ҏW�擾' then Result := hi_newBool(not e.ReadOnly) else
    if cmd = 'IME�擾' then Result := hi_newStr(getIMEStatusName(e.ImeMode)) else
    if cmd = 'IME�ݒ�' then e.ImeMode := setControlIME(hi_str(v)) else
    if cmd = '�t�@�C���h���b�v���ݒ�' then
    begin
      if hi_bool(v) then
        e.OnDropFiles := Bokan.eventTEditorDropFile
      else
        e.OnDropFiles := nil
      ;
    end else
    if cmd = '�t�@�C���h���b�v���擾' then Result := hi_newBool(Assigned(e.OnDropFiles)) else
    ;
  end;
  procedure _VCL_GUI_GRID;
  var e: TStrSortGrid; csv: TCsvSheet;
  begin
    e := TStrSortGrid(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '�����T�C�YSET' then begin
      e.Font.Size := hi_int(v); e.Canvas.Font := e.Font;
      e.DefaultRowHeight := Trunc(e.Canvas.TextHeight('Z') * 1.2);
    end else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '�w�i�F�擾' then setRes(Color2RGB(e.Color))  else
    if cmd = '�w�i�F�ݒ�' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = '�ҏW�ݒ�' then
    begin
      if hi_bool(v) then begin
        e.Options := e.Options - [goRowSelect];
        e.Options := e.Options + [goEditing, goAlwaysShowEditor];
      end else begin
        e.Options := e.Options - [goEditing, goAlwaysShowEditor];
        e.Options := e.Options + [goRowSelect];
      end;
    end else
    if cmd = '�ҏW�擾' then
    begin
      Result := hi_newBool(goEditing in e.Options);
    end else
    if cmd = 'GETROW' then Result := hi_newInt(e.Row) else
    if cmd = 'GETCOL' then Result := hi_newInt(e.Col) else
    if cmd = 'SETROW' then e.Row := hi_int(v) else
    if cmd = 'SETCOL' then e.Col := hi_int(v) else
    if cmd = '�s�I���擾' then
    begin
      if goRowSelect in e.Options then Result := hi_newBool(True) else Result := hi_newBool(False)
    end else
    if cmd = '�s�I��ݒ�' then
    begin
      if hi_bool(v) then
        e.Options := e.Options + [goRowSelect]
      else
        e.Options := e.Options - [goRowSelect];
    end else
    if cmd = '�Z���T�C�Y��������' then
    begin
      csv := TCsvSheet.Create;
      try
        CsvGridGetData(e, csv);
        CsvGridAutoColWidth(e, csv);
      finally
        csv.Free;
      end;
    end else
    if cmd = '�����\�[�g�擾' then Result := hi_newBool(e.SortOps <> soNon) else
    if cmd = '�����\�[�g�ݒ�' then if hi_bool(v) then e.SortOps := soBoth else e.SortOps := soNon else
    ;
  end;

  procedure _VCL_GUI_IMAGE;
  var e: TImage; bmp: TBitmap; gif: TGIFImage; f, ext: string;
  begin
    e := TImage(obj);
    if cmd = '�摜�ݒ�' then
    begin
      f := hi_strU(v);
      ext := UpperCase(ExtractFileExt(f));
      if f = '' then
      begin
        e.Picture := nil;
      end else
      if ext = '.GIF' then // �A�j��GIF�ɑΉ����邽�ߌʂɍ��
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
      // ���̑��̉摜�`��
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
    if cmd = '�������ݒ�' then
    begin
      e.Transparent := hi_bool(v);
    end;
    ;
  end;
  procedure _VCL_GUI_TRACKBOX;
  var e: TTrackBox;s: AnsiString;
  begin
    e := TTrackBox(obj);
    if cmd = 'SETCOLOR' then e.TrackColor := RGB2Color( hi_int(v) ) else
    if cmd = 'GETCOLOR' then Result := hi_newInt(Color2RGB( e.TrackColor) ) else
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '�g���X�^�C���ݒ�' then //�O��/����
    begin
      s := hi_str(v);
      if Pos('��',s) > 0 then e.TrackStyle := 0;
      if Pos('�O',s) > 0 then e.TrackStyle := 1;
    end else
    if cmd = '�g���X�^�C���擾' then
    begin
      if e.TrackStyle = 0 then Result := hi_newStr('����') else
      if e.TrackStyle = 1 then Result := hi_newStr('�O��');
    end else
    if cmd = '�g���␳�ݒ�' then
    begin
      s := hi_str(v);
      if (s = '�͂�') or (s = '����') then e.TrackAdjustRD := True else e.TrackAdjustRD := False;
    end else
    if cmd = '�g���␳�擾' then
    begin
      if e.TrackAdjustRD then Result := hi_newStr('����') else Result := hi_newStr('�Ȃ�');
    end else
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
        if Pos('�摜',  s) = 0                  then begin dc := dc + [CS_Images]; end;
        if Pos('�r�f�I',s) = 0                  then dc := dc + [CS_Videos];
        if Pos('BGM',   s) = 0                  then dc := dc + [CS_BGSounds];
        if Pos('�X�N���v�g', s) > 0             then begin dc := dc + [CS_NoScripts]; e.IeDontSCRIPT := True; end;
        if Pos('JAVA', s) > 0                   then dc := dc + [CS_NoJava];
        if Pos('ActiveX', s) > 0                then dc := dc + [CS_NoActiveXRun];
        if Pos('ActiveX�_�E�����[�h', s) > 0    then dc := dc + [cs_NoActiveXDownLoad];
        if Pos('�_�C�A���O', s) > 0             then begin dc := dc + [CS_Silent]; e.Silent := True; end;
        if Pos('�I�t���C�����[�h', s) > 0       then dc := dc + [CS_OffLine];
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
      if cmd = '�߂�'   then e.GoBack else
      if cmd = '�i��'   then e.GoForward else
      if cmd = '�z�[��' then e.GoHome else
      if cmd = '�^�C�g���擾' then
      begin
        Doc := e.Document as IHTMLDocument2;
        Result := hi_newStrU(Doc.title);
      end else
      if cmd = '�֎~���ڐݒ�' then changeSetting(hi_strU(v)) else
      if cmd = '�^�O�ǉ�' then
      begin
        Doc := e.Document as IHTMLDocument2;
        Doc.body.insertAdjacentHTML('BeforeEnd', hi_strU(v));
      end else
      if cmd = '����' then
      begin
        //SetFocus(e.ParentWindow);
        e.SetFocus;
        e.DocFocus;
      end else
      if cmd = '���'           then e.ExecWB(OLECMDID_PRINT, OLECMDEXECOPT_DODEFAULT, tmp, tmp) else
      if cmd = '����v���r���[' then e.ExecWB(OLECMDID_PRINTPREVIEW, OLECMDEXECOPT_DODEFAULT, tmp, tmp) else
      if cmd = '�X�V'           then e.ExecWB(OLECMDID_REFRESH, OLECMDEXECOPT_DODEFAULT, tmp, tmp) else
      if cmd = '�ۑ�'           then e.ExecWB(OLECMDID_SAVEAS, OLECMDEXECOPT_DODEFAULT, tmp, tmp) else
      ;
    except end;
  end;
  procedure _VCL_GUI_SPINEDIT;
  var e: TSpinEdit;
  begin
    e := TSpinEdit(obj);
    if cmd = '�ő�l' then e.MaxValue := hi_int(v) else
    if cmd = '�ŏ��l' then e.MinValue := hi_int(v) else
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '�����T�C�YSET' then e.Font.Size := hi_int(v) else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '�w�i�F�擾' then setRes(Color2RGB(e.Color))  else
    if cmd = '�w�i�F�ݒ�' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = 'UNDO'  then e.Undo else
    if cmd = 'REDO'  then  else
    if cmd = 'COPY'  then e.CopyToClipboard    else
    if cmd = 'CUT'   then e.CutToClipboard     else
    if cmd = 'PASTE' then e.PasteFromClipboard else
    if cmd = 'SELECTALL' then e.SelectAll else
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '�ҏW�ݒ�' then e.ReadOnly := not hi_bool(v) else
    if cmd = '�ҏW�擾' then Result := hi_newBool(not e.ReadOnly) else
    ;
  end;

  procedure _VCL_GUI_BUTTON;
  var e: TButton;
  begin
    e := TButton(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then begin setFontName(e.Font, hi_strU(v)); end else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size); end else
    if cmd = '�����T�C�YSET' then begin e.Font.Size := hi_int(v); end else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
  end;
  procedure _VCL_GUI_MEMO;
  var e: TMemo; s: AnsiString;
  begin
    e := TMemo(obj);
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then begin setFontName(e.Font, hi_strU(v)); end else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size); end else
    if cmd = '�����T�C�YSET' then begin e.Font.Size := hi_int(v); end else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '�w�i�F�擾' then setRes(Color2RGB(e.Color))  else
    if cmd = '�w�i�F�ݒ�' then e.Color := RGB2Color(hi_int(v)) else
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
    if cmd = '�ҏW�ݒ�' then e.ReadOnly := not hi_bool(v) else
    if cmd = '�ҏW�擾' then Result := hi_newBool(not e.ReadOnly) else
    if cmd = 'IME�擾' then Result := hi_newStr(getIMEStatusName(e.ImeMode)) else
    if cmd = 'IME�ݒ�' then e.ImeMode := setControlIME(hi_str(v)) else
    if cmd = '�X�N���[���o�[�擾' then
    begin
      case e.ScrollBars of
        ssNone        : Result := hi_newStr('');
        ssHorizontal  : Result := hi_newStr('��');
        ssVertical    : Result := hi_newStr('�c');
        ssBoth        : Result := hi_newStr('�c��');
      end;
    end else
    if cmd = '�X�N���[���o�[�ݒ�' then
    begin
      s := hi_str(v);
      if (s = '')or(s = '�Ȃ�') then e.ScrollBars := ssNone else
      if (s = '�c'  ) then e.ScrollBars := ssVertical else
      if (s = '��'  ) then e.ScrollBars := ssHorizontal else
      if (s = '�c��')or(s = '���c')or(s = '����') then e.ScrollBars := ssBoth else
      e.ScrollBars := ssNone;
    end else
    ;
  end;
  procedure _VCL_GUI_LIST;
  var e: TListBox;
  begin
    e := TListBox(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '�����T�C�YSET' then begin
      e.Style := lbOwnerDrawFixed;
      e.Canvas.Font.Size := hi_int(v);
      e.Font.Size := hi_int(v);
      e.ItemHeight := e.Canvas.TextHeight('a');
    end else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '�w�i�F�擾' then setRes(Color2RGB(e.Color))  else
    if cmd = '�w�i�F�ݒ�' then e.Color := RGB2Color(hi_int(v)) else
    ;
  end;
  procedure _VCL_GUI_COMBO;
  var e: TComboBox;
  begin
    e := TComboBox( obj );
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '�����T�C�YSET' then e.Font.Size := hi_int(v) else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '�w�i�F�擾' then setRes(Color2RGB(e.Color))  else
    if cmd = '�w�i�F�ݒ�' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = '�ҏW�ݒ�' then if hi_bool(v) then e.Style := csDropDown else e.Style := csDropDownList else
    if cmd = '�ҏW�擾' then Result := hi_newBool(e.Style = csDropDown) else
    if cmd = 'IME�擾' then Result := hi_newStr(getIMEStatusName(e.ImeMode)) else
    if cmd = 'IME�ݒ�' then e.ImeMode := setControlIME(hi_str(v)) else
    if cmd = '���X�g�s���擾' then Result := hi_newInt(e.DropDownCount) else
    if cmd = '���X�g�s���ݒ�' then e.DropDownCount := hi_int(v) else
  end;
  procedure _VCL_GUI_BAR;
  var e: TScrollBar;
  begin
    e := TScrollBar(obj);
    if cmd = '�ő�l' then e.Max := hi_int(v) else
    if cmd = '�ŏ��l' then e.Min := hi_int(v) else
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '�����ݒ�' then if hi_str(v) = '�c' then e.Kind := sbVertical else e.Kind := sbHorizontal else
    if cmd = '�����擾' then if e.Kind = sbVertical then Result := hi_newStr('�c') else Result := hi_newStr('��') else
  end;
  procedure _VCL_GUI_PROGRESS;
  var e: TProgressBar;
  begin
    e := TProgressBar(obj);
    if cmd = '�ő�l' then e.Max := hi_int(v) else
    if cmd = '�ŏ��l' then e.Min := hi_int(v) else
    if cmd = '�l'     then begin e.Position := hi_int(v); end else
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
  end;
  procedure _VCL_GUI_PANEL;
  var e: TNakoPanel; s: AnsiString;
  begin
    e := TNakoPanel(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '�X�^�C���ݒ�' then
    begin // �g�Ȃ�|��|��
      s := hi_str(v);
      if s = '�g�Ȃ�' then e.BevelOuter := bvNone    else
      if s = '��'     then e.BevelOuter := bvLowered else
      if s = '��'     then e.BevelOuter := bvRaised  else
      ;
    end else
    if cmd = '�X�^�C���擾' then
    begin
      case e.BevelOuter of
        bvNone    : Result := hi_newStr('�g�Ȃ�');
        bvLowered : Result := hi_newStr('��');
        bvRaised  : Result := hi_newStr('��');
        else        Result := hi_newStr('');
      end;
    end else
    if cmd = '�w�i�F�擾' then setRes(Color2RGB(e.Color))  else
    if cmd = '�w�i�F�ݒ�' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '�����T�C�YSET' then e.Font.Size := hi_int(v) else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    ;
  end;
  procedure _VCL_GUI_GROUPBOX;
  var e: TGroupBox;
  begin
    e := TGroupBox(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '�w�i�F�擾' then setRes(Color2RGB(e.Color))  else
    if cmd = '�w�i�F�ݒ�' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '�����T�C�YSET' then e.Font.Size := hi_int(v) else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    ;
  end;
  procedure _VCL_GUI_SCROLL_PANEL;
  var e: TScrollBox;
  begin
    e := TScrollBox(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '�p�l�����擾' then Result := hi_newInt(e.ClientWidth) else
    if cmd = '�p�l�����擾' then Result := hi_newInt(e.ClientHeight) else
    if cmd = '�p�l�����ݒ�' then e.ClientWidth  := hi_int(v) else
    if cmd = '�p�l�����ݒ�' then e.ClientHeight := hi_int(v) else
    if cmd = '�w�i�F�擾' then setRes(Color2RGB(e.Color))  else
    if cmd = '�w�i�F�ݒ�' then e.Color := RGB2Color(hi_int(v)) else
    ;            
  end;
  procedure _VCL_GUI_CHECK;
  var e: TCheckBox;
  begin
    e := TCheckBox(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '�����T�C�YSET' then e.Font.Size := hi_int(v) else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '�w�i�F�擾' then setRes(Color2RGB(e.Color))  else
    if cmd = '�w�i�F�ݒ�' then e.Color := RGB2Color(hi_int(v)) else

  end;
  procedure _VCL_GUI_RADIO;
  var e: TRadioGroup;
  begin
    e := TRadioGroup(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '�����T�C�YSET' then e.Font.Size := hi_int(v) else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '�w�i�F�擾' then setRes(Color2RGB(e.Color))  else
    if cmd = '�w�i�F�ݒ�' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = 'GETCOL' then setRes(e.Columns)  else
    if cmd = 'SETCOL' then e.Columns := hi_int(v) else

  end;
  procedure _VCL_GUI_RADIOGROUP;
  var e: TRadioGroup;
  begin
    e := TRadioGroup(obj);
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '�����T�C�YSET' then e.Font.Size := hi_int(v) else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '�w�i�F�擾' then setRes(Color2RGB(e.Color))  else
    if cmd = '�w�i�F�ݒ�' then e.Color := RGB2Color(hi_int(v)) else
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
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '�����T�C�YSET' then e.Font.Size := hi_int(v) else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '�w�i�F�擾' then setRes(Color2RGB(e.Color))  else
    if cmd = '�w�i�F�ݒ�' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = '�����擾' then Result := hi_newBool(e.Transparent)  else
    if cmd = '�����ݒ�' then e.Transparent := hi_bool(v) else
    if cmd = '�����ʒu�擾' then
    begin
      case e.Alignment of
        taLeftJustify  : Result := hi_newStr('��');
        taRightJustify : Result := hi_newStr('�E');
        taCenter       : Result := hi_newStr('����');
      end;
    end else if cmd = '�����ʒu�ݒ�' then
    begin
      s := hi_str(v);
      if s = '��'   then e.Alignment := taLeftJustify else
      if s = '����' then e.Alignment := taCenter else
      if s = '�E'   then e.Alignment := taRightJustify else ;
    end else
    ;
  end;
  procedure _VCL_GUI_MENUITEM;
  var e, menu: TMenuItem;
  begin
    e := TMenuItem(obj);
    if cmd = '�ǉ�' then
    begin
      menu := TMenuItem(hi_int(v));
      TMenuItem(obj).Add(menu);
      menu.Visible := True;
    end else
    if cmd = '�`�F�b�N�擾' then begin Result := hi_newBool(e.Checked) end else
    if cmd = '�`�F�b�N�ݒ�' then begin e.Checked := (hi_int(v) <> 0); end else
    if cmd = '�V���[�g�J�b�g�擾' then begin Result := hi_newStrU(ShortCutToText(e.ShortCut)) end else
    if cmd = '�V���[�g�J�b�g�ݒ�' then begin e.ShortCut := TextToShortCut(hi_strU(v)); end else
    begin
      raise Exception.Create(string(cmd)+'�͖���`�ł��B');
    end;
  end;
  procedure _VCL_GUI_TABPAGE;
  var sheet: TTabSheet; e: TPageControl; i: Integer;
  begin
    e := obj as TPageControl;

    if cmd = '�^�u�ǉ�' then
    begin
      sheet := TTabSheet.Create(obj);
      sheet.Caption := hi_strU(v);
      sheet.PageControl := e;
      Result := nako_var_new(nil);
      hi_setInt(Result, Integer(sheet));
    end else
    if cmd = '�e�L�X�g�擾' then
    begin
      Result := hi_var_new;
      hi_setStrU(Result, e.ActivePage.Caption);
    end else
    if cmd = '�e�L�X�g�ݒ�' then
    begin
      e.ActivePage.Caption := hi_strU(v);
    end else
    if cmd = '�\���^�u�擾' then
    begin
      Result := hi_var_new;
      hi_setInt(Result, e.ActivePageIndex);
    end else
    if cmd = '�\���^�u�ݒ�' then
    begin
      e.ActivePageIndex := hi_int(v);
    end else
    if cmd = 'POPUP' then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '�^�u�폜' then
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
    if cmd = '�^�u���i���擾' then
    begin
      Result := hi_var_new;
      hi_setBool(Result, e.MultiLine);
    end else
    if cmd = '�^�u���i���ݒ�' then
    begin
      e.MultiLine := hi_bool(v);
    end else
    if cmd = 'CW�擾' then
    begin
      Result := hi_newInt(e.ClientWidth);
    end else
    if cmd = 'CW�ݒ�' then
    begin
      e.ClientWidth := hi_int(v);
    end else
    if cmd = 'CH�擾' then
    begin
      Result := hi_newInt(e.ClientHeight);
    end else
    if cmd = 'CH�ݒ�' then
    begin
      e.ClientHeight := hi_int(v);
    end
    else begin
      raise Exception.Create(string(cmd)+'�͖���`�ł��B');
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
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '�����T�C�YSET' then e.Font.Size := hi_int(v) else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '�����擾'  then begin
      Result := hi_var_new;
      hi_setBool(Result, not e.SimplePanel);
    end else
    if cmd = '�����ݒ�'  then e.SimplePanel := not hi_bool(v) else
    if cmd = '���ڕ��擾'  then begin
      Result := hi_var_new;
      if e.Panels.Count > 0 then
      begin
        nako_ary_create(Result);
        for i := 0 to e.Panels.Count-1 do
          nako_ary_add(result,hi_newInt(e.Panels.Items[i].Width))
      end;
    end else
    if cmd = '���ڕ��ݒ�'  then
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
    if cmd = '�摜�ݒ�' then
    begin
      if hi_int(v) = 0 then raise Exception.Create('��̃C���[�W���X�g�͐ݒ�ł��܂���B');
      TToolBar(obj).Images := TImageList(hi_int(v));
    end else
    if cmd = '�ǉ�' then
    begin
      b := TToolButton( hi_int(v) );
      if (b = nil)or(not(b is TToolButton)) then raise Exception.Create('�c�[���{�^���̃I�u�W�F�N�g����ł��B');
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
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '�����T�C�YSET' then begin
      e.Font.Size := hi_int(v); e.Canvas.Font := e.Font;
      e.DefaultRowHeight := Trunc( e.Canvas.TextHeight('Z') * 1.2 );
    end else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '�w�i�F�擾' then setRes(Color2RGB(e.Color))  else
    if cmd = '�w�i�F�ݒ�' then e.Color := RGB2Color(hi_int(v)) else
    if cmd = 'POPUP'        then e.PopupMenu := TPopupMenu( hi_int(v) ) else
  end;
  procedure _VCL_GUI_FORM;
  var e: TfrmNako; ico: TIcon; icoCreate: TjvIcon; s: string; bmp: TBitmap; opt:Integer;
  begin
    e := TfrmNako(obj);
    if cmd = '�w�i�n���h��' then begin Result := hi_var_new; hi_setInt(Result, Integer(e.BackCanvas.Handle)); end else
    if cmd = '�\��'         then begin e.Show; e.Invalidate; e.RecoverXY; end else
    if cmd = 'POPUP'        then e.PopupMenu := TPopupMenu( hi_int(v) ) else
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '�����T�C�YSET' then e.Font.Size := hi_int(v) else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
    if cmd = '�w�i�F�擾' then setRes(Color2RGB(e.Color))  else
    if cmd = '�w�i�F�ݒ�' then begin e.Color := RGB2Color(hi_int(v)); e.ClearScreen(e.Color); end else
    if cmd = '�X�^�C���ݒ�' then e.setStyle(hi_str(v)) else
    if cmd = 'CW�ݒ�' then e.ClientWidth  := hi_int(v) else
    if cmd = 'CH�ݒ�' then e.ClientHeight := hi_int(v) else
    if cmd = 'CW�擾' then Result := hi_newInt(e.ClientWidth)  else
    if cmd = 'CH�擾' then Result := hi_newInt(e.ClientHeight) else
    if cmd = '�A�C�R���ݒ�' then
    begin
      s := hi_strU(v);
      icoCreate := TjvIcon.Create(nil);
      bmp := LoadPic(s);
      ico := icoCreate.CreateIcon(bmp);
      bmp.Free;
      e.Icon.Assign(ico);
      ico.Free;
      icoCreate.Free;
      // �^�X�N�g���C�ɃA�C�R��������΍X�V
      if e.IsLiveTasktray then begin e.ChangeTrayIcon end;
    end else
    if cmd = '�摜�ݒ�' then
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
    if cmd = '���[�_���\��' then
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
    if cmd = '����' then e.Close else
    if cmd = '�^�X�N�g���C�����' then e.MovetoTasktray(True) else
    if cmd = '�^�X�N�g���C�o��' then e.LeaveTasktray(True)  else
    if cmd = '�^�X�N�g���C�\��' then e.MovetoTasktray(False) else
    if cmd = '�^�X�N�g���C��\��' then e.LeaveTasktray(False) else
    if cmd = '�^�X�N�g���C�o���[���\��' then e.showBalloon(hi_str(v)) else
    if cmd = '�^�X�N�g���C�o���[����\��' then e.hideBalloon() else
    if cmd = '�^�X�N�g���C�o���[���I�v�V����SET' then
    begin
      s := hi_str(v);
      opt := 0;
      if Pos('�A�C�R������',  s) > 0            then opt := $00000000 { NIIF_NONE=$00000000 } else
      if Pos('�G���[�A�C�R��',  s) > 0          then opt := $00000003 { NIIF_ERROR=$00000003 } else
      if Pos('�ʒm�A�C�R��',  s) > 0            then opt := $00000001 { NIIF_INFO=$00000001 } else
      if Pos('�x���A�C�R��',  s) > 0            then opt := $00000002 { NIIF_WARNING=$00000002 } else
      if Pos('�A�v���P�[�V�����A�C�R��',s) > 0  then opt := $00000004; { NIIF_USER=$00000004 }
      if (Pos('���[�W�A�C�R��',s) > 0) or (Pos('�傫�ȃA�C�R��',  s) > 0) then opt := opt + $00000020; { NIIF_LARGE_ICON=$00000020 }
      if (Pos('������',  s) > 0) or (Pos('����',  s) > 0)  then opt := opt + $00000010; { NIIF_NOSOUND=$00000010 }
      e.dwBalloonOption := opt;
      if Pos('���A���^�C��',s) > 0  then e.bBalloonRealtime := true
      else e.bBalloonRealtime := false;
      if (Pos('�^�C�g������',s) > 0) or (Pos('�^�C�g���Ȃ�',s) > 0)  then e.bBalloonHideTitle := true
      else e.bBalloonHideTitle := false;
    end else
    if cmd = '�^�X�N�g���C�o���[���I�v�V����GET' then
    begin
      opt := e.dwBalloonOption;
      s := '';
      if (opt and $00000010) <> 0 then begin s:='/����'; opt:=opt-$00000010; end;
      if (opt and $00000020) <> 0 then begin s:='/���[�W�A�C�R��'; opt:=opt-$00000020; end;
      if opt=$00000000 then s:='�A�C�R������'+s;
      if opt=$00000003 then s:='�G���[�A�C�R��'+s;
      if opt=$00000002 then s:='�x���A�C�R��'+s;
      if opt=$00000001 then s:='�ʒm�A�C�R��'+s;
      if opt=$00000004 then s:='�A�v���P�[�V�����A�C�R��'+s;
      e.dwBalloonOption := opt;
      if e.bBalloonRealtime then s:=s+'/���A���^�C��';
      if e.bBalloonHideTitle then s:=s+'/�^�C�g������';
      Result := hi_var_new; hi_setStr(Result, s);
    end else
    if cmd = '�摜�ʂ�ό`' then
    begin
      SetRgnFromBitmap(e, e.backBmp, True);
      e.flagDragMove := True;
    end else
    if cmd = '�h���b�O�ړ��擾' then Result := hi_newBool(e.flagDragMove) else
    if cmd = '�h���b�O�ړ��ݒ�' then e.flagDragMove := hi_bool(v) else
    if cmd = '�����o���ό`' then
    begin
      SetRgnHukidasi(e); e.flagDragMove := True;
    end else
    if cmd = '�ő剻' then
    begin
      //��͂̎��̂݌��ɖ߂��ƁA�q�t�H�[���ŏ�������͍ŏ������q�t�H�[�����ʂ聄��͌��ʂ�
      //�Ƃ���ƁA��͌��ʂ�ɂ����Ƃ��q�t�H�[�����������܂�
      //����􂪎v�����Ȃ��̂ŁA��͍ŏ������ɁA�t�H�[�����ő剻/���ʂ肵���Ƃ��́A��͌��ʂ�

      //if e.IsBokan then
      //  Application.Restore;
      if IsIconic(Application.Handle) then
        Application.Restore;
      e.WindowState := wsMaximized;
    end else
    if cmd = '�ŏ���' then
    begin
      if e.IsBokan then
        Application.Minimize
      else
        e.WindowState := wsMinimized;
    end else
    if cmd = '���ʂ�' then
    begin
      //if e.IsBokan then
      //  Application.Restore;
      if IsIconic(Application.Handle) then
        Application.Restore;
      e.WindowState := wsNormal;
    end else
    if cmd = '�E�B���h�E��Ԏ擾' then
    begin
      if e.IsBokan then
       if IsIconic(Application.Handle) then
       begin
         Result := hi_newStr('�ŏ���');
         Exit;
       end;
       case e.WindowState of
         wsMaximized: Result := hi_newStr('�ő剻');
         wsMinimized: Result := hi_newStr('�ŏ���');
         wsNormal   : Result := hi_newStr('���ʂ�');
       end;
    end else
    if cmd = '�E�B���h�E��Ԑݒ�' then
    begin
      if hi_str(v) = '�ő剻' then
      begin
        //if e.IsBokan then
        //  Application.Restore;
        if IsIconic(Application.Handle) then
          Application.Restore;
        e.WindowState := wsMaximized;
      end else
      if hi_str(v) = '�ŏ���' then
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
    if cmd = '�����x�擾' then
    begin
      if e.AlphaBlend then
        Result := hi_newInt(e.AlphaBlendValue)
      else
        Result := hi_newInt(255);
    end else
    if cmd = '�����x�ݒ�' then
    begin
      if hi_int(v) = 255 then begin
        e.AlphaBlend := False;
        e.AlphaBlendValue := hi_int(v);
      end else begin
        e.AlphaBlend := True;
        e.AlphaBlendValue := hi_int(v);
      end;
    end else
    if cmd = '�ő剻�{�^���L���ύX' then begin
      if hi_bool(v) then
        e.BorderIcons := e.BorderIcons + [biMaximize]
      else
        e.BorderIcons := e.BorderIcons - [biMaximize];
    end else
    if cmd = '�ŏ����{�^���L���ύX' then begin
      if hi_bool(v) then
        e.BorderIcons := e.BorderIcons + [biMinimize]
      else
        e.BorderIcons := e.BorderIcons - [biMinimize];
    end else
    if cmd = '�V�X�e�����j���[�{�^���L���ύX' then begin
      if hi_bool(v) then
        e.BorderIcons := e.BorderIcons + [biSystemMenu]
      else
        e.BorderIcons := e.BorderIcons - [biSystemMenu];
    end else
    ;
    // �n���h�����ς�邱�Ƃ�����̂ŕK�����f������
    nako_setMainWindowHandle(bokan.Handle);
  end;
  procedure _VCL_GUI_MAINMENU;
  var menu: TMenuItem;
  begin
    if cmd = '�ǉ�' then
    begin
      menu := TMenuItem(hi_int(v));
      TMainMenu(obj).Items.Add(menu);
      menu.Visible := True;
    end else
    begin
      raise Exception.Create(string(cmd)+'�͖���`�ł��B');
    end;
  end;
  procedure _VCL_GUI_POPUPMENU;
  var menu: TMenuItem;
  begin
    if cmd = '�ǉ�' then
    begin
      menu := TMenuItem(hi_int(v));
      TPopupMenu(obj).Items.Add(menu);
      menu.Visible := True;
    end else
    begin
      raise Exception.Create(string(cmd)+'�͖���`�ł��B');
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
    if cmd = '������' then begin e.Clear; end else
    if cmd = '�ǉ�' then
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
    if cmd = '�ꊇ�ǉ�' then
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
    if cmd = '�u��' then
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
    if cmd = '�摜W�ݒ�' then
    begin
      TImageList(obj).Width := hi_int(v);
    end else
    if cmd = '�摜W�擾' then
    begin
      Result := hi_var_new;
      hi_setInt(Result, TImageList(obj).Width);
    end else
    if cmd = '�摜H�ݒ�' then
    begin
      TImageList(obj).Height := hi_int(v);
    end else
    if cmd = '�摜H�擾' then
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
    if cmd = '�摜�ݒ�' then
    begin
      bmp := LoadPic(hi_strU(v));
      try
        e.Glyph := bmp;
      finally
        bmp.Free;
      end;
    end else
    if cmd = '�t���b�g�擾' then Result := hi_newBool(e.Flat) else
    if cmd = '�t���b�g�ݒ�' then e.Flat := hi_bool(v) else
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '�����T�C�YSET' then e.Font.Size := hi_int(v) else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
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
    if cmd = '�摜�ݒ�' then
    begin
      bmp := LoadPic(hi_strU(v));
      try
        e.Glyph := bmp;
      finally
        bmp.Free;
      end;
    end else
    if cmd = '��������GET' then begin Result := hi_var_new; hi_setStrU(Result, e.Font.Name); end else
    if cmd = '��������SET' then setFontName(e.Font, hi_strU(v)) else
    if cmd = '�����T�C�YGET' then begin Result := hi_var_new; hi_setInt(Result, e.Font.Size) end else
    if cmd = '�����T�C�YSET' then e.Font.Size := hi_int(v) else
    if cmd = '�����FGET' then setRes(Color2RGB(e.Font.Color))  else
    if cmd = '�����FSET' then e.Font.Color := RGB2Color( hi_int(v) ) else
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
    if cmd = '�摜�ݒ�' then
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
    if cmd = 'GIF�摜�ݒ�' then
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
          raise Exception.CreateFmt('GIF�摜�u%s�v���ǂ߂܂���B',[hi_str(v)]);
        end;
      finally
        gif.Free;
      end;
      e.Start;
    end else
    if cmd = '�\���Ԋu�ݒ�' then
    begin
      e.Interval := hi_int(v);
    end else
    if cmd = '�J�n' then
    begin
      e.Start;
    end else
    if cmd = '��~' then
    begin
      e.Stop;
    end else
    if cmd = '�Đ��񐔐ݒ�' then
    begin
      e.RepeatTime := hi_int(v);
    end else
    if cmd = '�Đ��񐔎擾' then
    begin
      Result := hi_newInt(e.RepeatTime);
    end else
    if cmd = '�{�^�����[�h�ݒ�' then
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
    raise Exception.Create('VCL_COMMAND�́w'+string(cmd)+'�x�ŃI�u�W�F�N�g����������Ă��܂���B');
  end;

  try
    ginfo := GuiInfos[TControl(hi_int(o)).Tag];
    obj   := ginfo.obj;
  except
    raise Exception.Create('VCL_COMMAND�́w'+string(cmd)+'�x�ŃI�u�W�F�N�g������ł��܂���ł����B');
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
    VCL_GUI_TEDITOR : _VCL_GUI_TEDITOR; // T�G�f�B�^
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
      raise Exception.Create(string(ginfo.name) + '�ɂ̓R�}���h�͖���`�ł��B');
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
    // �ȉ��̕��@���ƃn���h�����ς���Ă��܂�
    // TForm(obj).FormStyle := fsStayOnTop;
    // �ȉ��̕��@���ƃn���h�����ς��Ȃ�����?!
    SetWindowPos(obj.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);
    // �n���h�����ς�邱�Ƃ�����̂ŕK�����f������
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

    // ID���w�肷��
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
      oya   := TrimA(csv.Cells[0,i]); if oya   = '�Ȃ�' then oya  := '';
      vname := TrimA(csv.Cells[1,i]); if vname = '' then Continue;
      cap   := TrimA(csv.Cells[2,i]);
      scut  := TrimA(csv.Cells[3,i]); if scut  = '�Ȃ�' then scut  := '';
      opt   := TrimA(csv.Cells[4,i]); if opt   = '�Ȃ�' then opt   := '';
      event := TrimA(csv.Cells[5,i]); if event = '�Ȃ�' then event := '';
      if (Copy(oya,1,1) = '#')or(Copy(oya,1,2)='��') then Continue;
      if Copy(vname,1,1) = '-' then
      begin
        vname := '__auto_' + oldOya[0] + '_line' + IntToStrA(i);
        cap   := '-';
      end;
      // �L���v�V�������ȗ�
      if cap = '' then
      begin
        cap := vname;
        if Copy(cap, Length(cap) - 8 + 1, 8) = '���j���[' then // ab���j���[
        begin
          cap := Copy(cap, 1, Length(cap) - 8);
        end;
      end;
      // �ȗ��������g����
      if Copy(oya,1,1) = '-' then
      begin
        cnt := _count(oya);
        oya := oldOya[cnt-1];
        oldOya[cnt] := vname;
      end else
      begin
        oldOya[0] := vname;
      end;

      // ����
      pm := nako_getVariable(PAnsiChar(vname));
      //
      //nako_eval_str('!' + vname + '�Ƃ̓��j���[�B'#13#10+vname+'�����B');
      if pm = nil then pm := hi_var_new(vname);
      pmenu := nako_getVariable('���j���[');
      nako_varCopyData(pmenu, pm);
      nako_group_exec(pm, '��');

      pm_obj := nako_getGroupMember(PAnsiChar(vname), '�I�u�W�F�N�g');
      if pm_obj = nil then begin
        raise Exception.Create(
                '�V�X�e���G���[.���j���["' +
                string(vname)+
                '"�̃|�C���^���擾�ł��܂���B');
      end;
      if not (TComponent(hi_int(pm_obj)) is TMenuItem) then
        raise Exception.Create(
                '�V�X�e���G���[.���j���["'+
                string(vname)+
                '"�̃|�C���^���擾�ł��܂���B');

      mnu := TMenuItem(hi_int(pm_obj));
      mnu.Caption := string(cap);
      mnu.OnClick := Bokan.eventClick;
      with GuiInfos[mnu.Tag] do begin
        name     := vname;
        pgroup   := pm;
      end;

      if scut <> '' then mnu.ShortCut := TextToShortCut(string(scut));
      // option
      if opt = '�`�F�b�N' then TMenuItem(mnu).Checked := True;

      // �C�x���g�̒�`
      if event <> '' then
      begin
        try
          nako_eval_str(vname+'�̃N���b�N�������́`'+event);
        except on e: Exception do
          raise Exception.Create('"'+string(vname)+'"�̃C�x���g�̐ݒ�G���[�B' + e.Message);
        end;
      end;

      // �ǉ�
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
                  string(oya) + '�͖���`�ł��B'
          );

        po := nako_getGroupMember(PAnsiChar(oya), '�I�u�W�F�N�g');
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
  // (1) �����̎擾
  ps := nako_getFuncArg(h, 0);

  // (2) ����
  if Bokan.Menu = nil then Bokan.Menu := TMainMenu.Create(Bokan);
  sub_menus(ps, Bokan.Menu);

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function vcl_popupmenus(h: DWORD): PHiValue; stdcall;
var ps, po: PHiValue;
begin
  // (1) �����̎擾
  po := nako_getFuncArg(h, 0);
  ps := nako_getFuncArg(h, 1);

  // (2) ����
  sub_menus(ps, TPopupMenu(getGui(po)));

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
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
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function vcl_treenode_add(h: DWORD): PHiValue; stdcall;
var
  pobj, ps: PHiValue;
begin
  pobj := nako_getFuncArg(h, 0);
  ps   := nako_getFuncArg(h, 1);
  sub_treenode_add(pobj, ps, False);
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

procedure sub_listview_add(pobj, ps: PHiValue; FlagClear: Boolean);
var
  csv: TCsvSheet;
  i: Integer;

  //�e���i��,���i��,�e�L�X�g,�摜�ԍ�
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

      // �e�̌���
      if oya <> '' then n := THPtrHashItem( tv.nodes.Items[oya] ) else n := nil;
      if n <> nil then oya_tn := TListItem( n.ptr ) else oya_tn := nil;

      // �ǉ�
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

      // �J�X�^�}�C�Y
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
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;


function vcl_listview_add(h: DWORD): PHiValue; stdcall;
var
  pobj, ps: PHiValue;
begin
  pobj := nako_getFuncArg(h, 0);
  ps   := nako_getFuncArg(h, 1);
  sub_listview_add(pobj, ps, False);
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function vcl_toolbutton(h: DWORD): PHiValue; stdcall;
var
  p, pobj,ps, pm, btn_group, ptoolbtn: PHiValue;

  csv: TCsvSheet;
  i: Integer;

  //���i��,�摜�ԍ�,���,�C�x���g
  vname, ino, itype, hint, event: AnsiString;

  btn: TToolButton;
  toolbar: TToolBar;

begin
  // (1) �����̎擾
  pobj := nako_getFuncArg(h, 0);
  ps   := nako_getFuncArg(h, 1);

  p := nako_group_findMember(pobj, '�I�u�W�F�N�g');
  if p = nil then raise Exception.Create('�c�[���{�^�������ł��܂���B');
  toolbar := TToolBar(Integer(hi_int(p)));
  //toolbar.Visible := False;


  // (2) ����
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

      // ����
      // nako_eval_str('!' + vname + '�Ƃ̓c�[���{�^���B'#13#10+vname+'�����B');
      btn_group := nako_getVariable(PAnsiChar(vname));
      if btn_group = nil then btn_group := nako_var_new(PAnsiChar(vname));
      //
      ptoolbtn := nako_getVariable('�c�[���{�^��');
      nako_varCopyData(ptoolbtn, btn_group);
      nako_group_exec(btn_group, '��');
      pm := nako_group_findMember(btn_group, '�I�u�W�F�N�g');

      if pm = nil then raise Exception.Create('�V�X�e���G���[.�c�[���{�^��'+string(vname)+'�̃|�C���^���擾�ł��܂���B');

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

      if (itype = '')or(itype='�{�^��') then
      begin
        btn.Style := tbsButton;
      end else
      if itype = '��؂�' then
      begin
        btn.Style := tbsDivider;
        btn.Width := 8;
      end;

      // �C�x���g�̒�`
      if event <> '' then
        nako_eval_str(vname+'�̃N���b�N�������́`'+event);

      // �ǉ�
      try
        btn.Parent := toolbar;
        btn.Visible := True;
      except
        raise Exception.Create('�V�X�e���G���[�Ń{�^�����c�[���o�[�ɒǉ��ł��܂���B');
      end;
    end;
  finally
    csv.Free;
  end;
  //toolbar.Visible := True;

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
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

// ���s����� INVALID_HANDLE_VALUE ��Ԃ�
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
    sleep(256); // �K����sleep ���ĉ�ʂ��^�����ɂȂ�̂�h��
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
  if title = '�f�X�N�g�b�v' then
  begin
    target := GetDesktopWindow;
  end else
  begin
    target := MyFindWindow(Title);
    if target = INVALID_HANDLE_VALUE then target := GetDesktopWindow;
    if BringWindowToTop(target) then
    begin
      Application.ProcessMessages;
      sleep(256); // �K����sleep ���ĉ�ʂ��^�����ɂȂ�̂�h��
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
  if title = '�f�X�N�g�b�v' then
  begin
    target := GetDesktopWindow;
  end else
  begin
    target := MyFindWindow(Title);
    if target = INVALID_HANDLE_VALUE then target := GetForegroundWindow;
    if BringWindowToTop(target) then
    begin
      Application.ProcessMessages;
      sleep(256); // �K����sleep ���ĉ�ʂ��^�����ɂȂ�̂�h��
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
  // OBJ��F��NO��
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

// �Ȃł����ɕK�v�Ȋ֐���ǉ�����
procedure RegistCallbackFunction(bokanHandle: Integer);

  procedure _init_font;
  begin
    baseX         := nako_getVariable('��{X');
    baseY         := nako_getVariable('��{Y');
    baseFont      := nako_getVariable('��������');
    baseFontSize  := nako_getVariable('�����T�C�Y');
    baseFontColor := nako_getVariable('�����F');
    penColor      := nako_getVariable('���F');
    brushColor    := nako_getVariable('�h��F');
    penWidth      := nako_getVariable('������');
    penStyle      := nako_getVariable('���X�^�C��');
    brushStyle    := nako_getVariable('�h��X�^�C��');
    tabCount      := nako_getVariable('�^�u��');
    baseInterval  := nako_getVariable('���i�Ԋu');
    printLog      := nako_getVariable('�\�����O');
  end;

begin
  //todo 0: ���V�X�e�����ߒǉ�
  //<VNAKO����>
  //+�`��֘A(vnako)
  //-�`�摮��
  AddIntVar('��{X',        10, 2000, '�`��p��{���W��X','���ق�X');
  AddIntVar('��{Y',        10, 2001, '�`��p��{���W��Y','���ق�Y');
  AddStrVar('��������',     '�l�r �S�V�b�N', 2002,'�`��p��{�t�H���g','�������傽��');
  AddIntVar('�����T�C�Y',   10, 2003, '�`��p��{�t�H���g�T�C�Y','����������');
  AddIntVar('�����F',        0, 2009, '�`��p��{�t�H���g�F','��������');
  AddIntVar('������',        3, 2004, '�}�`�̉��̐��̑���','����ӂƂ�');
  AddIntVar('���F',          0, 2005, '�}�`�̉��̐��̐F','���񂢂�');
  AddIntVar('�h��F',        0, 2006, '�}�`�̓h��F','�ʂ肢��');
  AddStrVar('���X�^�C��',    '����', 2007, '�}�`�̉��̐��̃X�^�C���B������Ŏw��B�u����|�_��|�j��|�����v','���񂷂�����');
  AddStrVar('�h��X�^�C��',  '�ׂ�', 2008, '�}�`�̓h��X�^�C���B������Ŏw��B�u�ׂ�|����|�i�q(�\����)|�c��|����|�E�΂ߐ�|���΂ߐ�|�΂ߏ\�����v','�ʂ肷������');
  AddIntVar('�^�u��',        4, 2010, '�����\�����Ƀ^�u���������œW�J���邩�B','���Ԃ���');
  AddIntVar('���i�Ԋu',      8, 2011, '���i�̔z�u�Ԋu','�ԂЂ񂩂񂩂�');
  AddIntVar('�C�x���g���i',0, 2012, '�C�x���g�����������Ƃ��ɐݒ肳���B','���ׂ�ƂԂЂ�');
  AddIntVar('JPEG���k��',    80, 2013, 'JPEG�摜��ۑ����鎞�̈��k��','JPEG�������キ���');

  //-�`�施��
  AddFunc('�\��',       '{=?}S��|S��',                     2100,cmd_print,    '��ʂɕ�����S��\������', '�Ђ傤��');
  AddFunc('��ʃN���A', '{�O���[�v=?}OBJ��{����=$FFFFFF}RGB��',2101,cmd_cls,      '��ʂ��J���[�R�[�h($RRGGBB)�ŃN���A����BRGB���ȗ��͔��F�BOBJ�̏ȗ��͕�͂̃I�u�W�F�N�g�B','���߂񂭂肠');
  AddFunc('�ړ�',       'X,Y��',                           2102,cmd_move,     '�`��̊�{���W��X,Y�ɕύX����B','���ǂ�');
  AddFunc('MOVE',       'X,Y��',                           2103,cmd_move,     '�`��̊�{���W��X,Y�ɕύX����','MOVE');
  AddFunc('��',         '{�O���[�v=?}OBJ��X1,Y1����X2,Y2��',       2104,cmd_line,     '��ʂɐ��������BOBJ�̏ȗ��͕�́B','����');
  AddFunc('LINE',       '{�O���[�v=?}OBJ,X1,Y1,X2,Y2',             2105,cmd_line,     '��ʂɐ��������BOBJ�̏ȗ��͕�́B','LINE');
  AddFunc('�l�p',       '{�O���[�v=?}OBJ��X1,Y1����X2,Y2��',       2106,cmd_rectangle,'��ʂɒ����`��`���BOBJ�̏ȗ��͕�́B','������');
  AddFunc('BOX',        '{�O���[�v=?}OBJ,X1,Y1,X2,Y2',             2107,cmd_rectangle,'��ʂɒ����`��`���BOBJ�̏ȗ��͕�́B','BOX');
  AddFunc('�~',         '{�O���[�v=?}OBJ��X1,Y1����X2,Y2��',       2108,cmd_circle,   '��ʂɉ~��`���B','����');
  AddFunc('CIRCLE',     '{�O���[�v=?}OBJ,X1,Y1,X2,Y2',             2109,cmd_circle,   '��ʂɉ~��`���B','CIRCLE');
  AddFunc('�p�ێl�p',   '{�O���[�v=?}OBJ��X1,Y1����X2,Y2��X3,Y3��',2110,cmd_roundrect,'��ʂɊp�̊ۂ������`��`���BX3,Y3�ɂ͊ۂ̓x�������w��B','���ǂ܂邵����');
  AddFunc('ROUNDBOX',   '{�O���[�v=?}OBJ,X1,Y1,X2,Y2,X3,Y3',       2111,cmd_roundrect,'��ʂɊp�̊ۂ������`��`���BX3,Y3�ɂ͊ۂ̓x�������w��B','ROUNDBOX');
  AddFunc('���p�`',     '{�O���[�v=?}OBJ��S��|OBJ��S��',           2112,cmd_poly,     '��ʂɑ��p�`��`���BS�ɂ͍��W�̈ꗗ�𕶎���ŗ^����B��)�u10,10,10,20,20,20�v','����������');
  AddFunc('POLY',       '{�O���[�v=?}OBJ,S',                       2113,cmd_poly,     '��ʂɑ��p�`��`���BS�ɂ͍��W�̈ꗗ�𕶎���ŗ^����B��)�u10,10,10,20,20,20�v','POLY');
  AddFunc('�摜�\��',   '{=?}X,{=?}Y��S��',                2114,cmd_loadPic,  '�t�@�C��S�̉摜��\������B','�������Ђ傤��');
  AddFunc('�摜�`��',   '{�O���[�v=?}OBJ��X,Y��S��',               2115,cmd_loadPic2, '�I�u�W�F�N�gOBJ��X,Y�փt�@�C��S�̉摜��\������B','�������т傤��');
  AddFunc('�����`��',   '{�O���[�v=?}OBJ��X,Y��S��',               2116,cmd_textout,  '�I�u�W�F�N�gOBJ��X,Y�֕���S���A���`�G�C���A�X�`�悷��B','�����т傤��');
  AddFunc('�����\��',   '{�O���[�v=?}OBJ��X,Y��S��',               2117,cmd_textout2, '�I�u�W�F�N�gOBJ��X,Y�֕���S��`�悷��B�i�A���`�G�C���A�X���Ȃ��j','�����Ђ傤��');
  AddFunc('�����x���`��','{�O���[�v=?}OBJ��X,Y��S��{���l=200}A��', 2118,cmd_textoutDelay,  '�I�u�W�F�N�gOBJ��X,Y�֕���S��x��A�~���b�ŕ`�悷��B','����������т傤��');
  AddFunc('���L���v�`��','{�O���[�v=?}OBJ��S��', 2119, cmd_capture,  '�^�C�g����S�̃E�B���h�E���L���v�`�����ăI�u�W�F�N�gOBJ�֕`�悷��BS�Ɂu�f�X�N�g�b�v�v���w�肷�邱�Ƃ��\�B','�܂ǂ���Ղ���');
  AddFunc('�����x���\��','{�O���[�v=?}OBJ��X,Y��S��{���l=200}A��', 2124,cmd_textoutDelayNoneAlias,  '�I�u�W�F�N�gOBJ��X,Y�֕���S��x��A�~���b�ŕ`�悷��B(�A���`�G�C���A�X�Ȃ�)','����������Ђ傤��');
  AddFunc('���n���h���L���v�`��','{�O���[�v=?}OBJ��H��', 2129, cmd_captureHandle,  '�n���h����H�̃E�B���h�E���L���v�`�����ăI�u�W�F�N�gOBJ�֕`�悷��B','�܂ǂ͂�ǂ邫��Ղ���');
  AddStrVar('�\�����O','',2120,'��ʂɕ\������������̃��O��ێ�����', '�Ђ傤���낮');
  AddFunc('�������擾',  '{=?}S��', 2121,cmd_getCharW, '������S�̕��������擾���ĕԂ�', '�����͂΂���Ƃ�');
  AddFunc('���������擾','{=?}S��', 2122,cmd_getCharH, '������S�̕����������擾���ĕԂ�', '��������������Ƃ�');
  AddFunc('�������L���v�`��','{�O���[�v=?}OBJ��S��', 2123, cmd_captureClient,  '�^�C�g����S�̃E�B���h�E�̓������L���v�`�����ăI�u�W�F�N�gOBJ�֕`�悷��B','�܂ǂ������킫��Ղ���');
  AddFunc('�A�C�R�����o','{�O���[�v=?}OBJ��F��NO��', 2125, cmd_extractIcon, '�t�@�C��F��NO�Ԗ�(0�`)�̃A�C�R�������o����OBJ�֕`�悷��B','�������񂿂イ�����');
  AddFunc('�A�C�R�����擾','F��', 2126, cmd_extractIconCount, '�t�@�C��F�̎����Ă���A�C�R������Ԃ��B','�������񂷂�����Ƃ�');
  AddFunc('�_�`��',      '{�O���[�v=?}OBJ��X,Y��C��', 2127,cmd_pset, 'X,Y�֐F�R�[�hC��_��`�悷��','�Ă�т傤��');
  AddFunc('�_�擾',      '{�O���[�v=?}OBJ��X,Y��|Y��',2128,cmd_pget, 'X,Y�̐F�R�[�h���擾����','�Ă񂵂�Ƃ�');
  AddFunc('�p���\��',    '{=?}S��|S��',               2099,cmd_print_continue, '��ʂɕ�����S��\������(���s���Ȃ�)', '���������Ђ傤��');
  AddFunc('�h��',        '{�O���[�v=?}OBJ��X,Y��COLOR��{=$FF000000}BORDER�܂�', 2164,cmd_ExtFloodFill, 'X,Y����S�����ɋ��E���FBORDER�܂�COLOR�̐F�œh��ׂ��BBORDER���ȗ������Ƃ���X,Y�̍��W�̐F�Ɠ����F�͈̔͂�h��ׂ��B', '�ʂ�');

  //-�摜����
  AddFunc('�摜���U�C�N',   '{�O���[�v}OBJ��A��|OBJ��',              2130,cmd_mosaic,   '�C���[�WOBJ��A�s�N�Z���̃��U�C�N��������', '��������������');
  AddFunc('�摜�{�J�V',     '{�O���[�v}OBJ��A��|OBJ��',              2131,cmd_blur,     '�C���[�WOBJ�ɋ��xA(1�`20)�̃{�J�V��������', '�������ڂ���');
  AddFunc('�摜�V���[�v',   '{�O���[�v}OBJ��A��|OBJ��',              2132,cmd_sharp,    '�C���[�WOBJ�ɋ��xA(1�`20)�̃V���[�v��������', '����������[��');
  AddFunc('�摜�l�K�|�W',   '{�O���[�v}OBJ��',                       2133,cmd_negaposi, '�C���[�WOBJ�̃l�K�|�W�𔽓]������', '�������˂��ۂ�');
  AddFunc('�摜���m�N��',   '{�O���[�v}OBJ��A��',                    2134,cmd_mono,     '�C���[�WOBJ�����x��A(0-255)�Ń��m�N��������', '���������̂���');
  AddFunc('�摜�\�����[�[�V����', '{�O���[�v}OBJ��',                 2135,cmd_solarization,'�C���[�WOBJ���\�����[�[�V��������', '����������肺�[�����');
  AddFunc('�摜�O���C�X�P�[��',   '{�O���[�v}OBJ��',                 2136,cmd_grayscale,'�C���[�WOBJ���O���C�X�P�[��������', '���������ꂢ�����[��');
  AddFunc('�摜�K���}�␳',       '{�O���[�v}OBJ��A��',              2137,cmd_gamma,    '�C���[�WOBJ�����x��A(����)�ŃK���}�␳����', '����������܂ق���');
  AddFunc('�摜�R���g���X�g',     '{�O���[�v}OBJ��A��',              2138,cmd_contrast, '�C���[�WOBJ�����x��A�ŃR���g���X�g���C������', '����������Ƃ炷��');
  AddFunc('�摜���x�␳',         '{�O���[�v}OBJ��A��',              2139,cmd_bright,   '�C���[�WOBJ�����x��A�Ŗ��x�␳����', '�������߂��ǂق���');
  AddFunc('�摜�m�C�Y',           '{�O���[�v}OBJ��A��',              2140,cmd_noise,    '�C���[�WOBJ�����x��A�Ńm�C�Y��������', '�������̂���');
  AddFunc('�摜�Z�s�A',           '{�O���[�v}OBJ��A��',              2141,cmd_sepia,    '�C���[�WOBJ���J���[A�ŃZ�s�A������', '���������҂�');
  AddFunc('�摜�E��]',           '{�O���[�v}OBJ��',                 2142,cmd_pic90r,   '�C���[�WOBJ���E��]������', '�������݂������Ă�');
  AddFunc('�摜����]',           '{�O���[�v}OBJ��',                 2143,cmd_pic90l,   '�C���[�WOBJ������]������', '�������Ђ��肩���Ă�');
  AddFunc('�摜��]',             '{�O���[�v}OBJ��A��',              2161,cmd_picRotate,    '�C���[�WOBJ��A�x��]������B', '�����������Ă�');
  AddFunc('�摜������]',         '{�O���[�v}OBJ��A��',              2166,cmd_picRotateFast,'�C���[�WOBJ��A�x��]������B', '�������������������Ă�');
  AddFunc('�摜�������]',         '{�O���[�v}OBJ��',                 2144,cmd_VertRev,  '�C���[�WOBJ�𐂒����]������', '�������������傭�͂�Ă�');
  AddFunc('�摜�������]',         '{�O���[�v}OBJ��',                 2145,cmd_HorzRev,  '�C���[�WOBJ�𐅕����]������', '�����������ւ��͂�Ă�');
  AddFunc('�摜���T�C�Y',         '{�O���[�v}OBJ��W,H��|H��',        2146,cmd_Resize,   '�C���[�WOBJ��W,H�̃T�C�Y�֕ύX����', '�������肳����');
  AddFunc('�摜�R�s�[',           '{�O���[�v}OBJ1��{�O���[�v}OBJ2��X,Y��',     2147,cmd_img_copy, '�C���[�WOBJ1���C���[�WOBJ2��X,Y�փR�s�[����B', '���������ҁ[');
  AddFunc('�摜�����R�s�[',       '{�O���[�v}OBJ1��X,Y,W,H��{�O���[�v}OBJ2��X2,Y2��', 2148,cmd_img_copyEx, '�C���[�WOBJ1��X,Y,W,H���C���[�WOBJ2��X,Y�փR�s�[����B', '�������ԂԂ񂱂ҁ[');
  AddFunc('�摜�r�b�g���ύX',     '{�O���[�v}OBJ��A��', 2149, cmd_img_bit, '�C���[�WOBJ�̉摜�F�r�b�g����A(1/4/8/15/16/24/32)�r�b�g�ɕύX����B', '�������т��Ƃ����ւ񂱂�');
  AddFunc('�摜�ۑ�',             '{�O���[�v}OBJ��S��|S��', 2150, cmd_img_save, '�C���[�WOBJ�̉摜��S�֕ۑ�����', '�������ق���');
  AddFunc('�摜�������R�s�[',     '{�O���[�v}OBJ1��{�O���[�v}OBJ2��X,Y��A��', 2151, cmd_img_alphaCopy, '�C���[�WOBJ1��OBJ2��X,Y�։摜�𓧖��x�`���ŃR�s�[����', '�������͂�Ƃ��߂����ҁ[');
  AddFunc('�摜�}�X�N�쐬',       '{�O���[�v}OBJ��C��', 2152, cmd_img_mask, '�C���[�WOBJ�𓧖��FC�Ń}�X�N�����', '�������܂�����������');
  AddFunc('�摜AND�R�s�[',        '{�O���[�v}OBJ1��{�O���[�v}OBJ2��X,Y��',     2153,cmd_img_copyAnd, '�C���[�WOBJ1���C���[�WOBJ2��X,Y��AND�R�s�[����B�}�X�N�摜���d�˂�̂Ɏg���B', '������AND���ҁ[');
  AddFunc('�摜OR�R�s�[',         '{�O���[�v}OBJ1��{�O���[�v}OBJ2��X,Y��',     2154,cmd_img_copyOr, '�C���[�WOBJ1���C���[�WOBJ2��X,Y��OR�R�s�[����B', '������OR���ҁ[');
  AddFunc('�摜XOR�R�s�[',        '{�O���[�v}OBJ1��{�O���[�v}OBJ2��X,Y��',     2155,cmd_img_copyXOR, '�C���[�WOBJ1���C���[�WOBJ2��X,Y��XOR�R�s�[����B', '������XOR���ҁ[');
  AddFunc('�摜�F�擾',           '{�O���[�v=?}OBJ��X,Y��|Y����', 2156,cmd_img_getC, '�C���[�WOBJ��X,Y�ɂ���F�ԍ����擾����B', '���������낵��Ƃ�');
  AddFunc('�摜�F�u��',           '{�O���[�v=?}OBJ��A��B��|A����B��',2157,cmd_img_change, '�C���[�WOBJ�̐FA��FB�ɒu�����܂��B', '���������낿����');
  AddFunc('�摜����ϊ�',         '{�O���[�v=?}OBJ��|OBJ��',2158,cmd_img_linePic, '�C���[�WOBJ�̉摜�����ɕϊ�', '���������񂪂ւ񂩂�');
  AddFunc('�摜�G�b�W�ϊ�',       '{�O���[�v=?}OBJ��|OBJ��',2159,cmd_img_edge, '�C���[�WOBJ�̉摜���G�b�W�ɕϊ�', '�������������ւ񂩂�');
  AddFunc('�摜����',             '{�O���[�v=?}OBJ1��{�O���[�v}OBJ2��X,Y��|Y��',2160,cmd_img_gousei, '�C���[�WOBJ1��OBJ2��X,Y�֍������܂��BOBJ1�̍���̐F�𓧉ߐF�Ƃ��Ĉ����B', '��������������');
  AddFunc('�摜�䗦�ς������T�C�Y','{�O���[�v}OBJ��W,H��|H��',        2162,cmd_ResizeAspect,   '�C���[�WOBJ��W,H�̃T�C�Y�֏c���䗦��ێ����ĕύX����', '�������Ђ�������肳����');
  AddFunc('�摜�������T�C�Y',      '{�O���[�v}OBJ��W,H��|H��',        2163,cmd_ResizeSpeed,    '�C���[�WOBJ��W,H�̃T�C�Y�֍����ɕύX����B(�摜���T�C�Y���掿��������B)', '���������������肳����');
  AddFunc('�摜�䗦�ς����������T�C�Y','{�O���[�v}OBJ��W,H��|H��',    2165,cmd_ResizeAspectEx, '�C���[�WOBJ��W,H�̃T�C�Y�֏c���䗦��ێ����ĕύX��W,H�̒����֕`�悷��B�]���́u�h�F�v�̐F���K�p�����B', '�������Ђ���������イ�����肳����');

  //-�f�X�N�g�b�v
  AddIntVar('�f�X�N�g�b�vX', Screen.WorkAreaLeft, 2170, '�f�X�N�g�b�v�̃��[�N�G���A��X','�ł����Ƃ���X');
  AddIntVar('�f�X�N�g�b�vY', Screen.WorkAreaTop, 2171, '�f�X�N�g�b�v�̃��[�N�G���A��Y','�ł����Ƃ���Y');
  AddIntVar('�f�X�N�g�b�vW', Screen.DesktopWidth, 2172, '�f�X�N�g�b�v�̕�','�ł����Ƃ���W');
  AddIntVar('�f�X�N�g�b�vH', Screen.DesktopHeight, 2173, '�f�X�N�g�b�v�̍���','�ł����Ƃ���H');
  AddIntVar('�f�X�N�g�b�v���[�N�G���AW', Screen.WorkAreaWidth, 2174, '�f�X�N�g�b�v�̃��[�N�G���A�̕�','�ł����Ƃ��Ղ�[�����肠W');
  AddIntVar('�f�X�N�g�b�v���[�N�G���AH', Screen.WorkAreaHeight, 2175, '�f�X�N�g�b�v�̃��[�N�G���A�̍���','�ł����Ƃ��Ղ�[�����肠H');
  AddFunc('�t�H���g�ꗗ�擾','', 2176, cmd_getFonts, '�t�H���g�̈ꗗ���擾', '�ӂ���Ƃ�����񂵂�Ƃ�');

  //+GUI�֘A(vnako)
  //-GUI���i
  // AddIntVar('�{�^��',   0, 6000, '(GUI���i)','�ڂ���');
  // AddIntVar('�G�f�B�^', 0, 6001, '(GUI���i)','���ł���');
  // AddIntVar('����',     0, 6002, '(GUI���i)','�߂�');
  // AddIntVar('���X�g',   0, 6003, '(GUI���i)','�肷��');
  // AddIntVar('�R���{',   0, 6004, '(GUI���i)','�����');
  // AddIntVar('�o�[',     0, 6005, '(GUI���i)','�΁[');
  // AddIntVar('�p�l��',   0, 6006, '(GUI���i)','�ς˂�');
  // AddIntVar('�`�F�b�N', 0, 6007, '(GUI���i)','��������');
  // AddIntVar('���W�I',   0, 6008, '(GUI���i)','�炶��');
  // AddIntVar('�O���b�h', 0, 6009, '(GUI���i)','�������');
  // AddIntVar('�C���[�W', 0, 6010, '(GUI���i)','���߁[��');
  // AddIntVar('���x��',   0, 6011, '(GUI���i)','��ׂ�');
  // AddIntVar('���j���[', 0, 6012, '(GUI���i)','�߂ɂ�[');
  // AddIntVar('�^�u�y�[�W', 0, 6013, '(GUI���i)','���Ԃ؁[��');
  // AddIntVar('�J�����_�[', 0, 6014, '(GUI���i)','����񂾁[');
  // AddIntVar('�c���[', 0, 6015, '(GUI���i)','��[');
  // AddIntVar('���X�g�r���[', 0, 6016, '(GUI���i)','�肷�Ƃт�[');
  // AddIntVar('�X�e�[�^�X�o�[', 0, 6017, '(GUI���i)','���ā[�����΁[');
  // AddIntVar('�c�[���o�[', 0, 6018, '(GUI���i)','�[��΁[');
  // AddIntVar('�^�C�}�[', 0, 6019, '(GUI���i)','�����܁[');
  // AddIntVar('�u���E�U', 0, 6020, '(GUI���i)','�Ԃ炤��');
  // AddIntVar('�X�s���G�f�B�^', 0, 6021, '(GUI���i)','���҂񂦂ł���');
  // AddIntVar('�g���b�N', 0, 6022, '(GUI���i)','�Ƃ����');
  // AddIntVar('T�G�f�B�^', 0, 6023, '(GUI���i)','T���ł���');
  // AddIntVar('�v���p�e�B�G�f�B�^', 0, 6025, '(GUI���i)','�Ղ�ςĂ����ł���');
  // AddIntVar('�t�H�[��', 0, 6026, '(GUI���i)','�ӂ��[��');
  // AddIntVar('���C�����j���[', 0, 6027, '(GUI���i)','�߂���߂ɂ�[');
  // AddIntVar('�|�b�v�A�b�v���j���[', 0, 6028, '(GUI���i)','�ۂ��Ղ����Ղ߂ɂ�[');
  // AddIntVar('�X�v���b�^', 0, 6029, '(GUI���i)','���Ղ����');
  // AddIntVar('�C���[�W���X�g', 0, 6030, '(GUI���i)','���߁[���肷��');
  // AddIntVar('�c�[���{�^��', 0, 6031, '(GUI���i)','�[��ڂ���');
  // AddIntVar('�A�j��', 0, 6033, '(GUI���i)','���ɂ�');
  // AddIntVar('�摜�{�^��', 0, 6034, '(GUI���i)','�������ڂ���');
  // AddIntVar('�X�N���[���p�l��', 0, 6035, '(GUI���i)','������[��ς˂�');

  //-�C�x���g
  AddIntVar('�C���X�^���X�n���h��', HInstance,      2200, '�C���X�^���X�n���h��', '���񂷂��񂷂͂�ǂ�');
  AddIntVar('��̓n���h��',         bokanHandle,    2201, '��͂̃E�B���h�E�n���h��','�ڂ���͂�ǂ�');
  AddIntVar('��̓I�u�W�F�N�g',     Integer(Bokan), 2202, '��̓I�u�W�F�N�g','�ڂ��񂨂Ԃ�������');
  AddFunc  ('�ҋ@',         '', 2203, cmd_stop,          '�v���O�����̎��s���~�߃C�x���g��҂B','������');
  AddFunc  ('�I���',       '', 2204, cmd_closeWindow,   '��͂���ăv���O�����̎��s���I��������B','�����');//���\�b�h�̏㏑��
  AddFunc  ('�����',       '', 2205, cmd_closeWindow,   '��͂���ăv���O�����̎��s���I��������B','�����');//���\�b�h�̏㏑��
  AddFunc  ('�`�揈�����f', '{�O���[�v=?}OBJ��|OBJ��', 2206, cmd_reflesh, 'GUI���iOBJ�ւ���܂łɕ`�悵�����e�𔽉f������BOBJ�ȗ����͕�́B','�т傤�������͂񂦂�');
  AddFunc  ('��͍ĕ`��',   '', 2207, cmd_redraw,        '�`�揈�����f�������S�̏��Ȃ��ĕ`����s��','�ڂ��񂳂��т傤��');
  AddFunc  ('�b�҂�',       '{=?}A', 2209, cmd_sleep,    'A�b�Ԏ��s���~�߂�B','�т傤�܂�');
  AddFunc  ('�I��',         '',      2210, cmd_closeWindow, '��͂���ăv���O�����̎��s���I��������B','���イ��傤');//���\�b�h�̏㏑��
  AddFunc  ('�L�[���', 'A��|A��',   2211, cmd_keyState, '�L�[�R�[�hA�̏�Ԃ𒲂ׁA�I�����I�t��Ԃ��B','���[���傤����');
  AddIntVar('�A�v���P�[�V�����n���h��', Application.Handle, 2212, '�A�v���P�[�V�����̃E�B���h�E�n���h��','���Ղ肯�[�����͂�ǂ�');

  //-VCL�֘A
  AddFunc('�f�t�H���g�e���i�ݒ�', '{�O���[�v}OBJ��|OBJ��|OBJ��', 2318, vcl_setDefaultParentObj, '��ƂȂ�e���i���w�肷��', '�łӂ���Ƃ���ԂЂ񂹂��Ă�');
  AddFunc('VCL_CREATE', '{�O���[�v}A,NAME,TYPE', 2300, vcl_create, 'VCL GUI���i���쐬','VCL_CREATE');
  AddFunc('VCL_GET','OBJ,PROP',   2301, vcl_getprop, 'VCL GUI���i�̃v���p�e�B���擾(OBJ�ɂ�GUI�I�u�W�F�N�g�𒼐ڎw��)','VCL_GET');
  AddFunc('VCL_SET','OBJ,PROP,V', 2302, vcl_setprop, 'VCL GUI���i�̃v���p�e�B��ݒ�(OBJ�ɂ�GUI�I�u�W�F�N�g�𒼐ڎw��)','VCL_SET');
  AddFunc('VCL_COMMAND','OBJ,V1,V2', 2303, vcl_command, 'VCL GUI���i�̃R�}���hV1�Ƀf�[�^V2��ݒ肷��','VCL_COMMAND');
  AddFunc('VCL_FREE','{�O���[�v}A', 2311, vcl_free, 'VCL GUI���i��j������','VCL_FREE');
  AddFunc('���j���[�ꊇ�쐬','S��|S��', 2304, vcl_menus, '���j���[���ꊇ�쐬����BCSV�`���Łu�e���i��,���i��,�e�L�X�g,�V���[�g�J�b�g,�I�v�V����,�C�x���g�v�Ŏw�肷��B�C�x���g�ɂ͊֐�������s�v���O�������w��B','�߂ɂ�[��������������');
  AddFunc('�|�b�v�A�b�v���j���[�ꊇ�쐬','{�O���[�v}OBJ��S��', 2305, vcl_popupmenus, '�|�b�v�A�b�v���j���[OBJ(�I�u�W�F�N�g��^����)�Ń��j���[���ꊇ�쐬����BCSV�`���Łu�e���i��,���i��,�e�L�X�g,�V���[�g�J�b�g,�I�v�V����,�C�x���g�v�Ŏw�肷��B�C�x���g�ɂ͊֐�������s�v���O�������w��B','�ۂ��Ղ����Ղ߂ɂ�[��������������');
  AddFunc('�c�[���{�^���ꊇ�쐬','{�O���[�v}OBJ��S��', 2306, vcl_toolbutton, '�c�[���o�[OBJ(�c�[���o�[�̃I�u�W�F�N�g��^����)�Ƀc�[���{�^�����ꊇ�쐬����BS�ɂ�CSV�`���Łu���i��,�摜�ԍ�,���(�{�^��|��؂�),����,�C�x���g�v�Ŏw�肷��B','�[��ڂ��񂢂�����������');
  AddFunc('�c���[�m�[�h�ꊇ�쐬','{�O���[�v}OBJ��S��', 2307, vcl_treenode, '�c���[OBJ�Ƀm�[�hS���ꊇ�쐬����BS�́u�e���ʖ�,�m�[�h���ʖ�,�e�L�X�g,�摜�ԍ�,�I���摜�ԍ��v�Ŏw��B','��[�́[�ǂ�������������');
  AddFunc('�c���[�m�[�h�ꊇ�ǉ�','{�O���[�v}OBJ��S��', 2308, vcl_treenode_add, '�c���[OBJ�Ƀm�[�h���ꊇ�ǉ�����BS�́u�e���ʖ�,�m�[�h���ʖ�,�e�L�X�g,�摜�ԍ�,�I���摜�ԍ��v�Ŏw��B','��[�́[�ǂ���������');
  AddFunc('���X�g�A�C�e���ꊇ�쐬','{�O���[�v}OBJ��S��', 2309, vcl_listview, '�c���[OBJ�Ƀm�[�h���ꊇ�쐬����BS�́u�e���ʖ�,�m�[�h���ʖ�,�e�L�X�g,�摜�ԍ��v�Ŏw��B','�肷�Ƃ����Ăނ�������������');
  AddFunc('���X�g�A�C�e���ꊇ�ǉ�','{�O���[�v}OBJ��S��', 2310, vcl_listview_add, '�c���[OBJ�Ƀm�[�h���ꊇ�ǉ�����BS�́u�e���ʖ�,�m�[�h���ʖ�,�e�L�X�g,�摜�ԍ��v�Ŏw��B','�肷�Ƃ����Ăނ���������');
  AddFunc('�����ړ�', '{�O���[�v}OBJ��', 2320, cmd_moveWindow, '�E�B���h�E�╔�iOBJ�𒆉��ֈړ�����B','���イ�������ǂ�');
  AddFunc('��̓^�C�g���ݒ�', 'S��', 2321, vcl_set_apptitle, '�^�C�g���o�[�̃e�L�X�g��ύX����','�ڂ��񂽂��Ƃ邹���Ă�');
  AddFunc('��̓^�C�g���擾', '', 2322, vcl_get_apptitle, '�^�C�g���o�[�̃e�L�X�g���擾����','�ڂ��񂽂��Ƃ邵��Ƃ�');
  AddFunc('�őO��', '{�O���[�v}OBJ��|OBJ��', 2323, cmd_StayOnTop, '���iOBJ���őO�ʂɕ\������','��������߂�');
  AddFunc('�Ŕw��', '{�O���[�v}OBJ��|OBJ��', 2324, cmd_StayOnTopOff, '���iOBJ���Ŕw�ʂɕ\������','�����͂��߂�');
  AddFunc('�őO�ʔ���', '{�O���[�v}OBJ��|OBJ��', 2327, cmd_IsStayOnTop, '�E�B���h�EOBJ���őO�ʂ��ǂ������肵�āA�͂�(=1)��������(=0)��Ԃ�','��������߂�͂�Ă�');
  SetSetterGetter('��̓^�C�g��', '��̓^�C�g���ݒ�','��̓^�C�g���擾',2325, '��̓^�C�g���o�[�̐ݒ�擾���s��', '�ڂ��񂽂��Ƃ�');
  AddFunc  ('�����ǂݎ擾','{������=?}S��|S��',2326, sys_toHurigana,'����S�̂ӂ肪�Ȃ�IME���擾����(�R���\�[����ł͋@�\���Ȃ�)','���񂶂�݂���Ƃ�');
  AddFunc('SetFocus',   'H',         2319, _SetFocus, '','SetFocus');
  AddFunc('SendMessage','H,MSG,W,L', 2328, _SendMessage, '','SendMessage');
  AddFunc('PostMessage','H,MSG,W,L', 2329, _PostMessage, '','PostMessage');
  //-�u���E�U�x��
  AddFunc('�u���E�UINPUT�l�ݒ�','{�O���[�v}OBJ��ID��S��', 2399, browser_setFormValue, '�u���E�U���iOBJ�ŕ\�����̃y�[�W�ɂ���INPUT�^�O(ID�ɂ�id�������uname�������^�O��\�o���ԍ�(0�N�_)�v)��value�ɒl��ݒ肷��','�Ԃ炤��INPUT�����������Ă�');
  AddFunc('�u���E�UINPUT�l�擾','{�O���[�v}OBJ��ID��', 2398, browser_getFormValue, '�u���E�U���iOBJ�ŕ\�����̃y�[�W�ɂ���INPUT�^�O�̒l���擾����','�Ԃ炤��INPUT����������Ƃ�');
  AddFunc('�u���E�UFORM���M','{�O���[�v}OBJ��ID��', 2397, browser_submit, '�u���E�U���iOBJ�ŕ\�����̃y�[�W�ɂ���FORM�^�O�𑗐M����(ID�ɂ�id�������uname�������^�O��\�o���ԍ�(0�N�_)�v)�𑗐M����','�Ԃ炤��FORM��������');
  AddFunc('�u���E�UHTML����','{�O���[�v}OBJ��ID��S��|S��', 2396, browser_setHTML, '�u���E�U���iOBJ�ŕ\������ID��HTML������������(ID�ɂ�id�������uname�������^�O��\�o���ԍ�(0�N�_)�v)','�Ԃ炤��HTML��������');
  AddFunc('�u���E�UHTML�擾','{�O���[�v}OBJ��ID��', 2395, browser_getHTML, '�u���E�U���iOBJ�ŕ\������ID��HTML���擾����(ID�ɂ�id�������uname�������^�O��\�o���ԍ�(0�N�_)�v)','�Ԃ炤��HTML����Ƃ�');
  AddFunc('�u���E�U�Ǎ��ҋ@','{�O���[�v}OBJ��', 2394, browser_waitToComplete, '�u���E�U���iOBJ�ŕ\������ID��HTML���擾����','�Ԃ炤����݂��݂�����');
  AddFunc('�u���E�U�v�f�N���b�N','{�O���[�v}OBJ��ID��', 2393, browser_click, '�u���E�U���iOBJ�ŕ\������ID�v�f���N���b�N����','�Ԃ炤���悤���������');
  AddFunc('�u���E�U����v���r���[','{�O���[�v}OBJ��|OBJ��', 2392, browser_printpreview, '�u���E�U���iOBJ�ň���v���r���[���o��','�Ԃ炤�����񂳂Ղ�т�[');
  AddFunc('�u���E�UEXECWB','{�O���[�v}OBJ��CMD��OPT��', 2391, browser_execwb, '�u���E�U���iOBJ�ɃR�}���h�𑗂�','�Ԃ炤��EXECWB');

  //-�F�萔
  AddIntVar('���F', $FFFFFF, 2330, '���F','���낢��');
  AddIntVar('���F', $000000, 2331, '���F','���낢��');
  AddIntVar('�ԐF', $FF0000, 2333, '�ԐF','��������');
  AddIntVar('�F', $0000FF, 2334, '�F','��������');
  AddIntVar('���F', $FFFF00, 2332, '���F','������');
  AddIntVar('�ΐF', $00FF00, 2335, '�ΐF','�݂ǂ肢��');
  AddIntVar('���F', $FF00FF, 2336, '���F','�ނ炳������');
  AddIntVar('���F', $00FFFF, 2337, '���F','�݂�����');

  AddIntVar('�E�B���h�E�F',     Color2RGB(clWindow),      2338, '�V�X�e���J���[','������ǂ�����');
  AddIntVar('�E�B���h�E�w�i�F', Color2RGB(clBtnFace),     2339, '�V�X�e���J���[','������ǂ��͂��������傭');
  AddIntVar('�E�B���h�E�����F', Color2RGB(clWindowText),  2340, '�V�X�e���J���[','������ǂ��������傭');
  AddIntVar('�f�X�N�g�b�v�F',   Color2RGB(clBackground),  2341, '�V�X�e���J���[','�ł����Ƃ��Ղ��傭');
  AddIntVar('�A�N�e�B�u�F',     Color2RGB(clActiveCaption),   2342, '�V�X�e���J���[','�����Ă��Ԃ��傭');
  AddIntVar('��A�N�e�B�u�F',   Color2RGB(clInactiveCaption), 2343, '�V�X�e���J���[','�Ђ����Ă��Ԃ��傭');

  //-�f�o�b�O�p
  AddIntVar('�f�o�b�O�G�f�B�^�n���h��', 0, 2360, '�Ȃł����G�f�B�^������s���ꂽ���A�G�f�B�^�n���h�����ݒ肳���B','�ł΂������ł����͂�ǂ�');
  AddFunc('�f�o�b�O', '', 2361, @cmd_debug, '�f�o�b�O�_�C�A���O��\������B','�ł΂���');//���\�b�h�̏㏑��
  AddStrVar('�G���[�_�C�A���O�^�C�g��', '�Ȃł����̃G���[', 2362, '�G���[�_�C�A���O�̃^�C�g�����w�肷��','����[�������낮�����Ƃ�');
  AddIntVar('�G���[�_�C�A���O�\������', 1, 2363, '�G���[�_�C�A���O�̕\���������邩�ǂ������w�肷��(0�Ȃ狖���Ȃ�)','����[�������낮�Ђ傤�����傩');

  //+�_�C�A���O(vnako)
  //-�_�C�A���O
  AddFunc('�t�H���g�I��',    '',                    2401,cmd_dlgFont,   '�t�H���g��I�����ăt�H���g����Ԃ��B', '�ӂ���Ƃ��񂽂�');
  AddFunc('�F�I��',          '',                    2402,cmd_dlgColor,  '�F��I�����ĕԂ��B', '���낹�񂽂�');
  AddFunc('�v�����^�ݒ�',    '',                    2403,cmd_dlgPrint,  '�v�����^��ݒ肷��B�L�����Z���������ꂽ��A������(=0)��Ԃ��B', '�Ղ�񂽂����Ă�');
  AddFunc('�����L��',        '{=?}S��|S��|S��|S��', 2404,cmd_dlgMemo,   '�G�f�B�^��S��\�����ҏW���ʂ�Ԃ��B', '�߂����ɂイ');
  AddFunc('�q�˂�',          '{=?}S��|S��|S��',     2405,cmd_dlgInput,     '���[�U�[����̓��͂�Ԃ��B', '�����˂�');
  AddFunc('���ڋL��',        '{=?}S��|S��|S��|S��', 2406,cmd_dlgInputList, '���[�U�[���畡���̍���S(�n�b�V���`��)�̓��͂𓾂Č��ʂ��n�b�V���ŕԂ��B', '�����������ɂイ');
  AddFunc('�p�X���[�h����',  '{=?}S��|S��|S��|S��', 2407,cmd_dlgPassword,  '���b�Z�[�WS��\�����A�p�X���[�h�̓��͂𓾂�B', '�ς���[�ǂɂイ��傭');
  AddFunc('�{�^���I��',      '{=?}S��V��|S��V��',   2408,cmd_dlgButton,    '���b�Z�[�WS��\�����A�I����V���瓚���𓾂ĕԂ��B', '�ڂ��񂹂񂽂�');
  AddFunc('����',            '{=?}S��|S��|S��|S��', 2409,cmd_dlgSay,       '���b�Z�[�WS��\������B', '����');
  AddFunc('���l����',        '{=?}S��|S��|S��|S��', 2410,cmd_dlgInputNum,  '���b�Z�[�WS��\�����Đ��l����͂��Ă��炤�B', '�������ɂイ��傭');
  AddFunc('�����o���\��',    'X,Y��{=?}S��|S��|S��|S��',  2411,cmd_dlgHukidasi, 'X,Y�փ��b�Z�[�WS�𐁂��o���ɂ��ĕ\������B', '�ӂ������Ђ傤��');
  AddFunc('���',            'S��|S��|S��',               2412,cmd_nitaku,      '���b�Z�[�WS��\�����A�͂����������Őq�˂�_�C�A���O��\�����A���ʂ��͂�(=1)������(=0)�ŕԂ��B', '�ɂ���');
  AddFunc('���X�g�i���ݑI��','{=?}S��|S��|S��|S��|S����',     2421,cmd_dlgList,  '���b�Z�[�WS��\�����A�͂����������Őq�˂�_�C�A���O��\�����A���ʂ��͂�(=1)������(=0)�ŕԂ��B', '�肷�Ƃ��ڂ肱�݂��񂽂�');
  AddFunc('���t�I��',        '', 2416,cmd_dlgInputDate,  '�J�����_�[��\�����ē��t�I���_�C�A���O��\�������t��Ԃ��B', '�ЂÂ����񂽂�');
  //-Vista�_�C�A���O
  AddFunc('����_�C�A���O�\��','{=?}Q��S��|Q��S��',  2413,cmd_nitaku_vista, 'Vista�ȍ~�̕W������_�C�A���O�Ɏ���Q�Ɛ���S��\������B', '�ɂ����������낮�Ђ傤��');
  AddFunc('�x���_�C�A���O�\��','{=?}Q��S��|Q��S��',  2414,cmd_warning_vista, 'Vista�ȍ~�̕W������_�C�A���O�Ƀ^�C�g��Q�Ɛ���S��\������B', '���������������낮�Ђ傤��');
  AddFunc('���_�C�A���O�\��','{=?}Q��S��|Q��S��',  2415,cmd_okdialog_vista, 'Vista�ȍ~�̕W������_�C�A���O�Ƀ^�C�g��Q�Ɛ���S��\������B', '���傤�ق��������낮�Ђ傤��');

  //-�_�C�A���O�I�v�V����
  AddStrVar('�_�C�A���O�ڍ�','',2420,'�_�C�A���O�Ɋւ���I�v�V�������n�b�V���`���Ŏw�肷��B(��������/�����T�C�Y/�����F)','�������낮���傤����');
  //AddStrVar('�_�C�A���O�L�����Z���l','',460,'�_�C�A���O���L�����Z�������Ƃ��̒l���w��','�������낮����񂹂邿');
  //AddStrVar('�_�C�A���O�����l','',461,'�_�C�A���O�̏����l���w��','�������낮���傫��');
  //AddStrVar('�_�C�A���OIME','',462,'�_�C�A���O�̓��̓t�B�[���h��IME��Ԃ̎w��(IME�I��|IME�I�t|IME����|IME�J�i|IME���p)','�������낮IME');
  //AddStrVar('�_�C�A���O�^�C�g��','',463,'�_�C�A���O�̃^�C�g�����w�肷��','�������낮�����Ƃ�');
  //AddStrVar('�_�C�A���O���l�ϊ�','1',464,'�_�C�A���O�̌��ʂ𐔒l�ɕϊ����邩�ǂ����B�I��(=1)�I�t(=0)���w�肷��B','�������낮�������ւ񂩂�');

  //+���(vnako)
  //-�ȈՈ��
  AddFunc('�ȈՕ�������', '{=?}S��|S��|S��', 2450, cmd_printEasy,  '������S���������', '���񂢂�������񂳂�');
  AddFunc('��͈��', '', 2451, cmd_printBokan,  '��͂�p�������ς��Ɉ������', '�ڂ��񂢂񂳂�');
  AddFunc('�ȈՉ摜���', '{�O���[�v=?}G��', 2452, cmd_printEasyImage,  '�C���[�WG��p�������ς��Ɉ������', '���񂢂��������񂳂�');
  //-�ڍ׈��
  AddFunc('�v�����^�`��J�n', '', 2455, cmd_printBeginDoc,  '', '�Ղ�񂽂т傤��������');
  AddFunc('�v�����^�`��I��', '', 2456, cmd_printEndDoc,  '', '�Ղ�񂽂т傤�����イ��傤');
  AddFunc('�v�����^�p����',   '', 2457, cmd_printPaperWidth,  '', '�Ղ�񂽂悤���͂�');
  AddFunc('�v�����^�p������', '', 2458, cmd_printPaperHeight,  '', '�Ղ�񂽂悤��������');
  AddFunc('�v�����^���y�[�W', '', 2465, cmd_printPaperNewPage,  '', '�Ղ�񂽂����؁[��');

  AddFunc('�v�����^�����`��',     '{=?}S��X,Y��', 2459, cmd_printTextOut,  '', '�Ղ�񂽂����т傤��');
  AddFunc('�v�����^�������擾',   '{=?}S��', 2460, cmd_printGetCharWidth,  '', '�Ղ�񂽂����͂΂���Ƃ�');
  AddFunc('�v�����^���������擾', '{=?}S��', 2461, cmd_printGetCharHeight,  '', '�Ղ�񂽂�������������Ƃ�');

  AddFunc('�v�����^�摜�`��',     '{�O���[�v=?}G��X,Y��', 2462, cmd_printImage,  '', '�Ղ�񂽂������т傤��');
  AddFunc('�v�����^���`��',       'X1,Y1����X2,Y2��', 2463, cmd_printLine,  '', '�Ղ�񂽂���т傤��');
  AddFunc('�v�����^�g��摜�`��', '{�O���[�v=?}G��X1,Y1,X2,Y2��', 2464, cmd_printImageEx,  '', '�Ղ�񂽂��������������т傤��');

  //</VNAKO����>

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
