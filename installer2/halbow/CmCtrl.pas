unit CmCtrl;

interface

uses
  Windows,
  Messages,
  CommCtrl,
  UtilFunc,
  UTilClass;


type

TNotifyNotify = procedure (var Msg:TMessage;NMHdr:TNMHdr);

PNMMouse = ^TNMMouse;
TNMMouse = packed record
  hdr: TNMHdr;
  ItemSpec:DWORD;
  ItemData:DWORD;
  pt:TPoint;
  HtInfo:LPARAM;
end;

TEffRect = record
  Mark:integer;
  ID: integer;
end;

const
  SBN_SIMPLEMODECHANGE = -880;
  TBM_SETBUDDY = WM_USER+32;
  TBM_GETBUDDY = WM_USER+33;

  PBS_SMOOTH = 1;
  PBS_VERTICAL = 4;
  PBM_SETBARCOLOR = WM_USER+9;
  PBM_SETBKCOLOR = $2001;
  CLR_DEFAULT = $FF000000;

type
//------------------ TCmCtrl --------------------------------------
TCmCtrl = class(TSubClass)
private
  FHandle: HWND;
  FID: HMenu;
  FOnClick:TNotifyNotify;
  FOnDblClick:TNotifyNotify;
  FOnRClick:TNotifyNotify;
  FOnRDblClick:TNotifyNotify;
  function GetEnable: Boolean;
  procedure SetEnable(value:Boolean);
  function GetVisible: Boolean;
  procedure SetVisible(value: Boolean);
protected
  procedure CreateControl; virtual; abstract;
public
  constructor Create(hParent: HWND); override;
  destructor Destroy; override;
  property Handle: HWND read FHandle;
  property ID: HMenu read FID;
  property Enable: Boolean read GetEnable write SetEnable;
  property Visible: Boolean read GetVisible write SetVisible;
  property OnClick:TNotifyNotify read FOnClick write FOnClick;
  property OnDblClick:TNotifyNotify read FOnDblClick write FOnDblClick;
  property OnRClick:TNotifyNotify read FOnRClick write FOnRClick;
  property OnRDblClick:TNotifyNotify read FOnRDblClick write FOnRDblClick;
end;

//----------------- TAPIStatusBar -----------------------------------
TSBTextStyle = (SUNKEN, NOBORDER, RAISED);

TAPIStatusBar = class(TCmCtrl)
private
  FPartsWidth: array [0..9] of integer;
  FTextStyle: array [0..9] of TSBTextStyle;
  FTOP:Boolean;
  FSimple:Boolean;
  FMinHeight:integer;
  FOnSize: TNotifyMessage;
  FOnSimpleChange:TNotifyNotify;
  procedure SetTOP(value:Boolean);
  function GetNumParts:integer;
  procedure SetNumParts(val:integer);
  function GetPartsWidth(i:integer):integer;
  procedure SetPartsWidth(i,val:integer);
  function GetText(i:integer):string;
  procedure SetText(i:integer;s:string);
  function GetTextStyle(i:integer):TSBTextStyle;
  procedure SetTextStyle(i:integer;style:TSBTextStyle);
  procedure SetSimple(val:Boolean);
  function GetSimpleText:string;
  procedure SetSimpleText(value:string);
  function GetRect(value:integer):TRect;
  procedure SetMinHeight(value:integer);
protected
  procedure CreateControl;override;
public
  constructor Create(hParent:HWND); override;
  procedure DefaultHandler(var Message);override;
  procedure Invalidate;
  property TOP:Boolean read FTOP write SetTOP;
  property NumParts:integer read GetNumParts write SetNumParts;
  property PartsWidth[i:integer]:integer read GetPartsWidth
                                           write SetPartsWidth;
  property Text[i:integer]:string read GetText write SetText;
  property TextStyle[i:integer]:TSBTextStyle read GetTextStyle
                                               write SetTextStyle;
  property Simple:Boolean read FSimple write SetSimple;
  property SimpleText:string read GetSimpleText write SetSimpleText;
  property Rect[i:integer]: TRect read GetRect;
  property MinHeight:integer read FMinHeight write SetMinHeight;
  property OnSize:TNotifyMessage read FOnSize write FOnSize;
  property OnSimpleChange:TNotifyNotify read FOnSimpleChange
                                         write FOnSimpleChange;
end;

//----------------- TEffecRect -------------------------------------
type
TEffecRect = class(TSubClass)
private
  FOnSize: TNotifyMessage;
  FIDArray: array[0..5] of TEffRect;
  FEffectiveRect:TRect;
  function GetItemID(i:integer):integer;
  procedure SetItemID(i,value:integer);
  function GetEffectiveDim:TRect;
protected
public
  constructor Create(hParent:HWND); override;
  procedure DefaultHandler(var Message);override;
  procedure ReCalc;
  property OnSize:TNotifyMessage read FOnSize write FOnSize;
  property ItemID[i:integer]:integer read GetItemID write SetItemID;
  property EffectiveDim:TRect read GetEffectiveDim;
end;

//------------------ TMenuHelp -----------------------------------
TMenuHelp = class(TSubClass)
private
  FhStatusBar: HWND;
  FID: TIntegerList;
  FSA: TStringArray;
  function GetNumList:integer;
protected
  procedure InitArray;
public
  constructor Create(hParent: HWND); override;
  destructor Destroy; override;
  procedure DefaultHandler(var Message);override;
  procedure AddList(mID:integer;sStr:string);
  property hStatusBar:HWND read FhStatusBar write FhStatusBar;
  property NumList:integer read GetNumList;
end;

//------------ TAPITrackBar ------------------------------------------
TTickDisplay = (BottomOrRight,TopOrLeft,Both, None);
TBuddyLocation = (RightOrBelow,LeftOrAbove);

TAPITrackBar = class(TCmCtrl)
private
  FDim: TRect;
  FRect: TRect;
  FVertical: Boolean;
  FTickDisplay: TTickDisplay;
  FTickFreq:integer;
  FDrawFrame: Boolean;
  FOnChange: TNotifyMessage;
  procedure SetDimension(val: TRect);
  function GetPos:integer;
  procedure SetPos(val: integer);
  function GetRangeMin: integer;
  procedure SetRangeMin(val: integer);
  function GetRangeMax: integer;
  procedure SetRangeMax(val: integer);
  function GetLine: integer;
  procedure SetLine(val: integer);
  function GetPage: integer;
  procedure SetPage(val: integer);
  procedure SetTickDisplay(val: TTickDisplay);
  procedure SetTickFreq(value:integer);
  function GetChannelRect:TRect;
  procedure SetDrawFrame(val:Boolean);
protected
  procedure CreateControl;override;
public
  constructor Create(hParent:HWND); override;
  procedure DefaultHandler(var Message);override;
  procedure SetVertical(val: Boolean);
  procedure SetBuddy(hBuddy:HWND;Position:TBuddyLocation);
  function GetBuddy(Position:TBuddyLocation):HWND;
  property Dimension : TRect read FDim write SetDimension;
  property ThumbPos: integer read GetPos write SetPos;
  property RangeMin: integer read GetRangeMin write setRangeMin;
  property RangeMax: integer read GetRangeMax write setRangeMax;
  property LineChange: integer read GetLine write SetLine;
  property PageChange: integer read GetPage write SetPage;
  property TickDisplay: TTickDisplay read FTickDisplay write SetTickDisplay;
  property TickFreq: integer read FTickFreq write SetTickFreq;
  property ChannelRect: TRect read GetChannelRect;
  property DrawFrame:Boolean read FDrawFrame write SetDrawFrame;
  property OnChange: TNotifyMessage read FOnChange write FOnChange;
end;

function CreateTrackBar(hParent:HWND;Vertical:Boolean;
           x,y,cx,cy,cRangeMin,cRangeMax,cTickFreq:integer;
           sOnChange:TNotifyMessage):TAPITrackBar;

function CreateStatusBar(hParent:HWND;Top:Boolean):TAPIStatusbar;

//--------------- TAPIProgress --------------------------------------
type
TAPIProgress = class(TCmCtrl)
private
  FDim: TRect;
  FStep: integer;
  FSmooth: Boolean;
  FVertical: Boolean;
  FBarColor:COLORREF;
  FBkColor:COLORREF;
  FDrawFrame: Boolean;
  FOnChange: TNotifyMessage;
  procedure SetDimension(val: TRect);
  function GetPos: integer;
  procedure SetPos(val: integer);
  function GetRangeMin: integer;
  procedure SetRangeMin(val: integer);
  function GetRangeMax: integer;
  procedure SetRangeMax(val: integer);
  procedure SetStep(val: integer);
  procedure SetSmooth(value: Boolean);
  procedure SetVertical(value: Boolean);
  procedure SetBarColor(value:COLORREF);
  procedure SetBkColor(value:COLORREF);
  procedure SetDrawFrame(val:Boolean);
protected
  procedure CreateControl;override;
public
  constructor Create(hParent:HWND); override;
  procedure DefaultHandler(var Message);override;
  procedure StepIt;
  procedure DeltaPos(val: integer);
  property Dimension : TRect read FDim write SetDimension;
  property Pos: integer read GetPos write SetPos;
  property RangeMin: integer read GetRangeMin write SetRangeMin;
  property RangeMax: integer read GetRangeMax write SetRangeMax;
  property Step: integer read FSTep write SetStep;
  property BarColor: COLORREF read FBarColor write SetBarColor;
  property BkColor: COLORREF read FBkColor write SetBkColor;
  property Smooth: Boolean read FSmooth write SetSmooth;
  property Vertical: Boolean read FVertical write SetVertical;
  property DrawFrame:Boolean read FDrawFrame write SetDrawFrame;
  property OnChange: TNotifyMessage read FOnChange write FOnChange;
end;

function CreateProgressBar(hParent:HWND;x,y,cx,cy,cRangeMin,cRangeMax:integer;
            cVertical,cSmooth:Boolean;sOnChange:TNotifyMessage):TAPIProgress;


implementation

var
  ID_CmCtrl:integer = 1000;

//------------------ TCmCtrl --------------------------------------
constructor TCmCtrl.Create(hParent: HWND);
begin
  inherited Create(hParent);
  Dispatcher.TrapMessage(WM_NOTIFY,self);
  InitCommonControls;
end;

destructor TCmCtrl.Destroy;
begin
  DestroyWindow(FHandle);
  inherited Destroy;
end;

function TCmCtrl.GetEnable: Boolean;
begin
  result := Boolean(IsWindowEnabled(FHandle));
end;

procedure TCmCtrl.SetEnable(value: Boolean);
begin
  EnableWindow(FHandle,value);
end;

function TCmCtrl.GetVisible: Boolean;
begin
  result := Boolean(IsWindowVisible(FHandle));
end;

procedure TCmCtrl.SetVisible(value:Boolean);
begin
  if value then
    ShowWindow(FHandle,SW_SHOWNORMAL)
  else
    ShowWindow(FHandle,SW_HIDE);
end;

//------------ TAPIStatusBar   ------------------------------------------------
constructor TAPIStatusBar.Create(hParent:HWND);
var
  i: integer;
begin
  inherited Create(hParent);

  CreateControl;
  Dispatcher.TrapMessage(WM_SIZE,self);

  for i := 0 to 9 do FPartsWidth[i] := 80;
end;

procedure TAPIStatusBar.CreateControl;
begin
  FHandle := CreateStatusWindow(WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or
                 WS_CLIPSIBLINGS or CCS_TOP,'APIStatusBar',Parent,ID_CmCtrl);
  FID := ID_CmCtrl;
  inc(ID_CmCtrl);
end;

procedure TAPIStatusBar.DefaultHandler(var Message);
var
  AMsg:TMessage;
  phdr: PNMHdr;
begin
  AMsg := TMessage(Message);

  case AMsg.Msg of

    WM_SIZE: begin
      SendMessage(FHandle,AMsg.Msg,AMsg.WParam,AMsg.LParam);
      if (AMsg.WParam+AMsg.LParam) = 0 then exit;
      AMsg.Msg := UINT(self);
      if Assigned(FOnSize) then OnSize(AMsg);
    end;

    WM_NOTIFY:begin
      phdr := Pointer(AMsg.LParam);
      if FHandle <> phdr^.hwndFrom then exit;
      AMsg.Msg := UINT(self); // Sender
      case phdr^.code of
        NM_CLICK:if Assigned(FOnClick) then FOnClick(AMsg,phdr^);
        NM_DBLCLK:if Assigned(FOnDblClick) then FOnDblClick(AMsg,phdr^);
        NM_RCLICK:if Assigned(FOnRClick) then FOnRClick(AMsg,phdr^);
        NM_RDBLCLK:if Assigned(FOnRDblClick) then FOnRDBlClick(AMsg,phdr^);
        SBN_SIMPLEMODECHANGE:if Assigned(FOnSimpleChange) then
                                FOnSimpleChange(AMsg,phdr^);
      end;
    end;

  end;
end;

procedure TAPIStatusBar.Invalidate;
begin
  SendMessage(FHandle,WM_SIZE,0,0);
end;

procedure TAPIStatusBar.SetTOP(value:Boolean);
var
  st: integer;
begin
  FTOP := value;
  st := GetWindowLong(FHandle,GWL_STYLE);
  if value then
    st := st or CCS_TOP
  else
    st := st and (not CCS_TOP);
  SetWindowLong(FHandle,GWL_STYLE,st);
  Invalidate;
end;

function TAPIStatusBar.GetNumParts: integer;
begin
  result := SendMessage(FHandle,SB_GETPARTS,0,0);
end;

procedure TAPIStatusBar.SetNumParts(val: integer);
var
  PartsX: array [0..9] of integer;
  i: integer;
begin
  if val > 9 then exit;
  if val = 1 then begin
    PartsX[0] := -1;
    SendMessage(FHandle,SB_SETPARTS,1,integer(@PartsX[0]));
  end else begin
    PartsX[0] := FPartsWidth[0];
    for i := 1 to val-1 do PartsX[i] := PartsX[i-1]+FPartsWidth[i];
    PartsX[val-1] := -1;
    SendMessage(FHandle,SB_SETPARTS,val,integer(@PartsX[0]));
  end;
end;

function TAPIStatusBar.GetPartsWidth(i: integer): integer;
begin
  if i > 9 then begin
    result := 0;
    exit;
  end;
  result := FPartsWidth[i];
end;

procedure TAPIStatusBar.SetPartsWidth(i,val: integer);
begin
  if i > 9 then exit;
  FPartsWidth[i] := val;
  SetNumParts(NumParts);
end;

function TAPIStatusBar.GetText(i: integer): string;
var
  Len: integer;
begin
  if (i > 9) and not (i = 255) then exit;
  SetLength(result,200);
  Len := LOWORD(SendMessage(FHandle,SB_GETTEXT,i,integer(PChar(result))));
  SetLength(result,Len);
end;

procedure TAPIStatusBar.SetText(i: integer; s: string);
var
  ts: integer;
begin
  if i > 9 then
    if i = 255 then begin
      SendMessage(FHandle,SB_SETTEXT,i,integer(PChar(s)));
      exit;
    end
  else
    exit;
  case FTextStyle[i] of
    NOBORDER: ts := SBT_NOBORDERS;
    RAISED: ts := SBT_POPOUT;
  else
    ts := 0;
  end;
  SendMessage(FHandle,SB_SETTEXT,i or ts,integer(PChar(s)));
end;

function TAPIStatusBar.GetTextStyle(i: integer): TSBTextStyle;
begin
  result := FTextStyle[i];
end;

procedure TAPIStatusBar.SetTextStyle(i: integer; style: TSBTextStyle);
var
  s: string;
begin
  FTextStyle[i] := style;
  s := GetText(i);
  SetText(i,s);
  InvalidateRect(FHandle,nil,true);
end;

procedure TAPIStatusBar.SetSimple(val: Boolean);
begin
  if FSimple = val then exit;
  FSimple := val;
  SendMessage(FHandle,SB_SIMPLE,integer(val),0);
end;

function TAPIStatusBar.GetSimpleText:string;
begin
  result := GetText(255);
end;

procedure TAPIStatusBar.SetSimpleText(value:string);
begin
  SetText(255,value);
end;

function TAPIStatusBar.GetRect(value:integer):TRect;
begin
  if value = -2 then
    GetClientrect(FHandle,result)
  else
    SendMessage(FHandle,SB_GETRECT,value,integer(@result));
end;

procedure TAPIStatusBar.SetMinHeight(value:integer);
begin
  FMinHeight := value;
  SendMessage(FHandle,SB_SETMINHEIGHT,value,0);
  Invalidate;
end;

function CreateStatusBar(hParent:HWND;Top:Boolean):TAPIStatusbar;
begin
  result := TAPIStatusbar.Create(hParent);
  result.TOP := Top;
end;

//----------------- TEffecRect -------------------------------------
constructor TEffecRect.Create(hParent:HWND);
begin
  inherited Create(hParent);
  Dispatcher.TrapMessage(WM_SIZE,self);
  FIDArray[0].Mark := 1; FIDArray[0].ID := 1;
end;

procedure TEffecRect.DefaultHandler(var Message);
var
  AMsg:TMessage;
begin
  AMsg := TMessage(Message);
  case AMsg.Msg of
    WM_SIZE: begin
      GetEffectiveClientRect(Parent,@FEffectiveRect,@FIDArray[0]);
      AMsg.Msg := UINT(self);
      if Assigned(FOnSize) then FOnSize(AMsg);
    end;
  end;
end;

procedure TEffecRect.ReCalc;
var
  Msg:TMessage;
begin
  Msg.Msg := WM_SIZE; 
  Dispatch(Msg);
end;

function TEffecRect.GetItemID(i:integer):integer;
begin
  result := 0;
  if (i<1) or (i>4) then exit;
  result := FIDArray[i].ID;
end;

procedure TEffecRect.SetItemID(i,value:integer);
begin
  if (i<1) or (i>4) then exit;
  FIDArray[i].Mark := 1; FIDArray[i].ID := value;
end;

function TEffecRect.GetEffectiveDim:TRect;
var
  r:TRect;
begin
  r := FEffectiveRect;
  result := SetDim(r.Left,r.Top,r.Right-r.Left,r.Bottom-r.Top);
end;

//------------------ TMenuHelp -----------------------------------
constructor TMenuHelp.Create(hParent: HWND);
begin
  inherited Create(hParent);
  FID := TIntegerList.Create(0,0);
  FSA := TStringArray.Create;
  InitArray;
  Dispatcher.TrapMessage(WM_ENTERMENULOOP,self);
  Dispatcher.TrapMessage(WM_MENUSELECT,self);
  Dispatcher.TrapMessage(WM_EXITMENULOOP,self);
end;

destructor TMenuHelp.Destroy;
begin
  FID.Free;
  FSA.Free;
  inherited Destroy;
end;

procedure TMenuHelp.DefaultHandler(var Message);
var
  AMsg:TMessage;
  i,ID:integer;
begin
  AMsg := TMessage(Message);
  case AMsg.Msg of
    WM_ENTERMENULOOP:SendMessage(FhStatusBar,SB_SIMPLE,1,0);
    WM_EXITMENULOOP:SendMessage(FhStatusBar,SB_SIMPLE,0,0);
    WM_MENUSELECT:begin
      if (AMsg.WParamHi and MF_POPUP) <> 0 then
        ID := MenuItemID(AMsg.LParam,AMsg.WParamLo)
      else
        ID := AMsg.WParamLo;

      if ID = 0 then exit;

      i := FID.Search(ID);
      if i <> -1 then
        SendMessage(FhStatusBar,SB_SETTEXT,255,integer(PChar(FSA[i])));
    end;
  end;
end;

procedure TMenuHelp.InitArray;
begin
  FID.Add(SC_RESTORE); FSA.Add('ウィンドウのサイズを元に戻します');
  FID.Add(SC_MOVE); FSA.Add('ウィンドウを移動します');
  FID.Add(SC_SIZE); FSA.Add('ウィンドウのサイズを変更します');
  FID.Add(SC_MINIMIZE); FSA.Add('ウィンドウを最小化します');
  FID.Add(SC_MAXIMIZE); FSA.Add('ウィンドウを最大化します');
  FID.Add(SC_CLOSE); FSA.Add('このウィンドウが閉じます');
end;

procedure TMenuHelp.AddList(mID:integer;sStr:string);
begin
  FID.Add(mID); FSA.Add(sStr);
end;

function TMenuHelp.GetNumList:integer;
begin
  result := FID.Count;
end;

//------------ TAPITrackBar ------------------------------------------
constructor TAPITrackBar.Create(hParent:HWND);
begin
  inherited Create(hParent);

  CreateControl;
  FVertical := false;
  FTickDisplay := BottomOrRight;
  FTickFreq := 1;
  FDrawFrame := false;
  Dispatcher.TrapMessage(WM_HSCROLL,self);
  Dispatcher.TrapMessage(WM_VSCROLL,self);
end;

procedure TAPITrackBar.CreateControl;
begin

  FHandle := CreateWindow(TRACKBAR_CLASS,
                          'APITrackbar',
                          WS_CHILD or WS_VISIBLE or WS_TABSTOP or
                          TBS_AUTOTICKS,
                          20,20,200,40,
                          Parent,
                          ID_CmCtrl,
                          hInstance,
                          nil);

  FID := ID_CmCtrl;
  inc(ID_CmCtrl);

  Dimension := SetDim(20,20,200,40);
end;

procedure TAPITrackBar.DefaultHandler(var Message);
var
  AMsg:TMessage;
begin
  AMsg := TMessage(Message);

  if THandle(AMsg.LParam) <> FHandle then exit; //自分を確認する

  case AMsg.Msg of

    WM_HSCROLL, WM_VSCROLL: begin
      AMsg.Msg := UINT(self);  // sender
      if Assigned(FOnChange) then OnCHange(AMsg);
    end;

  end;
end;

procedure TAPITrackBar.SetVertical(val: Boolean);
var
  st: integer;
begin
  FVertical := val;
  st := GetWindowLong(FHandle,GWL_STYLE);
  if val then
    st := st or TBS_VERT
  else
    st := st and (not TBS_VERT);
  SetWindowLong(FHandle,GWL_STYLE,st);
end;

procedure TAPITrackBar.SetDimension(val: TRect);
begin
  FDim := val;// xPos,yPos,width,height
  FRect := val;
  FRect.Right := FDim.Left+FDim.Right; // right from width
  FRect.Bottom := FDim.Top+FDim.Bottom; // Bottom from height
  MoveWindow(FHandle,val.left, val.top,val.right, val.bottom, true);
end;


function TAPITrackBar.GetPos:integer;
begin
  result := SendMessage(FHandle,TBM_GETPOS,0,0);
end;

procedure TAPITrackBar.SetPos(val: integer);
var
  Msg: TMessage;
begin
  SendMessage(FHandle,TBM_SETPOS,1,val);
  Msg.Msg := WM_HSCROLL;
  Msg.LParam := FHandle;
  Dispatch(Msg);
end;

function TAPITrackBar.GetRangeMin: integer;
begin
  result := SendMessage(FHandle,TBM_GETRANGEMIN,0,0);
end;

procedure TAPITrackBar.SetRangeMin(val: integer);
begin
  SendMessage(FHandle,TBM_SETRANGEMIN,1,val);
end;

function TAPITrackBar.GetRangeMax: integer;
begin
  result := SendMessage(FHandle,TBM_GETRANGEMAX,0,0);
end;

procedure TAPITrackBar.SetRangeMax(val: integer);
begin
  SendMessage(FHandle,TBM_SETRANGEMAX,1,val);
end;

function TAPITrackBar.GetLine: integer;
begin
  result := SendMessage(FHandle,TBM_GETLINESIZE,0,0);
end;

procedure TAPITrackBar.SetLine(val: integer);
begin
  SendMessage(FHandle,TBM_SETLINESIZE,0,val);
end;

function TAPITrackBar.GetPage: integer;
begin
  result := SendMessage(FHandle,TBM_GETPAGESIZE,0,0);
end;

procedure TAPITrackBar.SetPage(val: integer);
begin
  SendMessage(FHandle,TBM_SETPAGESIZE,0,val);
end;

procedure TAPITrackBar.SetTickDisplay(val: TTickDisplay);
var
  td,st,flag: integer;
begin
  case val of
    TopOrLeft: td := TBS_TOP;
    Both:      td := TBS_BOTH;
    None:      td := TBS_NOTICKS;
  else
    td := TBS_BOTTOM;
  end;
  flag := $1C;
  st := GetWindowLong(FHandle,GWL_STYLE);
  st := st and (not flag) or td;
  SetWindowLong(FHandle,GWL_STYLE,st);
  FTickDisplay := val;
end;

function TAPITrackBar.GetChannelRect:TRect;
var
  r:TRect;
begin
  SendMessage(FHandle,TBM_GETCHANNELRECT,0,LPARAM(@r));
  if not FVertical then
    result := r
  else begin
    result.Left := FDim.Right-r.Bottom;
    result.Top := r.Left;
    result.Right := FDim.Right-r.Top;
    result.Bottom := r.Right;
  end;
end;

procedure TAPITrackBar.SetTickFreq(value:integer);
begin
  FTickFreq := value;
  SendMessage(FHandle,TBM_SETTICFREQ,value,0);
end;

procedure TAPITrackBar.SetBuddy(hBuddy:HWND;Position:TBuddyLocation);
begin
  case Position of
    RightOrBelow: SendMessage(FHandle,TBM_SETBUDDY,0,hBuddy);
    LeftOrAbove: SendMessage(FHandle,TBM_SETBUDDY,1,hBuddy);
  end;
end;

function TAPITrackBar.GetBuddy(Position:TBuddyLocation):HWND;
begin
  result := 0;
  case Position of
    RightOrBelow: result := SendMessage(FHandle,TBM_SETBUDDY,0,0);
    LeftOrAbove: result := SendMessage(FHandle,TBM_SETBUDDY,1,0);
  end;
end;

procedure TAPITrackBar.SetDrawFrame(val:Boolean);
var
  Style:DWORD;
  r:TRect;
begin
  Style := GetWindowLong(FHandle,GWL_STYLE);
  if val then
    Style := Style or WS_BORDER
  else
    Style := Style and (not WS_BORDER);
  SetWindowLong(FHandle,GWL_STYLE,Style);
  GetWindowRect(FHandle,r);
  ChangeWindowSize(FHandle,0,0);
  ChangeWindowSize(FHandle,r.Right-r.Left,r.Bottom-r.Top);
  FDrawFrame := val;
end;

function CreateTrackBar(hParent:HWND;Vertical:Boolean;
           x,y,cx,cy,cRangeMin,cRangeMax,cTickFreq:integer;
           sOnChange:TNotifyMessage):TAPITrackBar;
begin
  result := TAPITrackBar.Create(hParent);
  with result do begin
    if Vertical then SetVertical(true);
    Dimension := SetDim(x,y,cx,cy);
    RangeMin := cRangeMin;
    RangeMax := cRangeMax;
    TickFreq := cTickFreq;
    OnChange := sOnChange;
  end;
end;


//--------------- TAPIProgress --------------------------------------
const
  PBM_EVENT = WM_USER+100;

constructor TAPIProgress.Create(hParent:HWND);
begin
  inherited Create(hParent);

  CreateControl;
  FStep := 10;
  FBarColor := CLR_DEFAULT;
  FBkColor := CLR_DEFAULT;
end;

procedure TAPIProgress.CreateControl;
var
  Style:DWORD;
begin
  Style := WS_CHILD or WS_VISIBLE;
  if FSmooth then Style := Style or PBS_SMOOTH;
  if FVertical then Style := Style or PBS_VERTICAL;
  FHandle := CreateWindowEx(WS_EX_STATICEDGE,
                            PROGRESS_CLASS,
                           'ProgressBar',
                           Style,
                           20,20,300,20,
                           Parent,
                           ID_CmCtrl,
                           hInstance,
                           nil);
  FID := ID_CmCtrl;
  inc(ID_CmCtrl);

  Dimension := SetDim(20,20,300,20);
end;

procedure TAPIProgress.DefaultHandler(var Message);
var
  AMsg:TMessage;
begin
  AMsg := TMessage(Message);

  if THandle(AMsg.LParam) <> FHandle then exit; //自分を確認する

  case AMsg.Msg of

    PBM_EVENT: begin
      AMsg.Msg := UINT(self);  // sender
      if Assigned(FOnChange) then FOnCHange(AMsg);
    end;

  end;
end;

procedure TAPIProgress.StepIt;
var
  Msg: TMessage;
begin
  SendMessage(FHandle,PBM_STEPIT,0,0);
  Msg.Msg := PBM_EVENT;
  Msg.LParam := FHandle;
  Dispatch(Msg);
end;

procedure TAPIProgress.DeltaPos(val: integer);
var
  Msg: TMessage;
begin
  SendMessage(FHandle,PBM_DELTAPOS,val,0);
  Msg.Msg := PBM_EVENT;
  Msg.LParam := FHandle;
  Dispatch(Msg);
end;

function TAPIProgress.GetPos: integer;
begin
  result := SendMessage(FHandle,PBM_GETPOS,0, 0);
end;

procedure TAPIProgress.SetPos(val: integer);
var
  Msg: TMessage;
begin
  SendMessage(FHandle,PBM_SETPOS,val,0);
  Msg.Msg := PBM_EVENT;
  Msg.LParam := FHandle;
  Dispatch(Msg);
end;

procedure TAPIProgress.SetDimension(val: TRect);
begin
  FDim := val;// xPos,yPos,width,height
  MoveWindow(FHandle,val.left, val.top,val.right, val.bottom, true);
end;

function TAPIProgress.GetRangeMin: integer;
begin
  result := SendMessage(FHandle,PBM_GETRANGE,1,0);
end;

procedure TAPIProgress.SetRangeMin(val: integer);
begin
  SendMessage(FHandle,PBM_SETRANGE,0,MakeLong(val,RangeMax));
end;

function TAPIProgress.GetRangeMax: integer;
begin
  result := SendMessage(FHandle,PBM_GETRANGE,0,0);
end;

procedure TAPIProgress.SetRangeMax(val: integer);
begin
  SendMessage(FHandle,PBM_SETRANGE,0,MakeLong(RangeMin,val));
end;

procedure TAPIProgress.SetStep(val :integer);
begin
  FStep := val;
  SendMessage(FHandle,PBM_SETSTEP,val,0);
end;

procedure TAPIProgress.SetBarColor(value:COLORREF);
begin
  FBarColor := value;
  SendMessage(FHandle,PBM_SETBARCOLOR,0,value);
end;

procedure TAPIProgress.SetBkColor(value:COLORREF);
begin
  FBkColor := value;
  SendMessage(FHandle,PBM_SETBKCOLOR,0,value);
end;

procedure TAPIProgress.SetSmooth(value: Boolean);
var
  iMin,iMax,iPos:integer;
  Dim: TRect;
begin
  if FSmooth = value then exit;
  FSmooth := value;
  Dim := FDim;
  iMin := RangeMin;
  iMax := RangeMax;
  iPos := Pos;
  DestroyWindow(FHandle);
  CreateControl;
  Dimension := Dim;
  RangeMin := iMin;
  RangeMax := iMax;
  Pos := iPos;
  Step := FStep;
  BarColor := FBarColor;
  BkColor := FBkColor;
end;

procedure TAPIProgress.SetVertical(value: Boolean);
var
  iMin,iMax,iPos:integer;
  Dim: TRect;
begin
  if FVertical = value then exit;
  FVertical := value;
  Dim := FDim;
  iMin := RangeMin;
  iMax := RangeMax;
  iPos := Pos;
  DestroyWindow(FHandle);
  CreateControl;
  Dimension := Dim;
  RangeMin := iMin;
  RangeMax := iMax;
  Pos := iPos;
  Step := FStep;
  BarColor := FBarColor;
  BkColor := FBkColor;
end;

procedure TAPIProgress.SetDrawFrame(val:Boolean);
var
  Style:DWORD;
  r:TRect;
begin
  Style := GetWindowLong(FHandle,GWL_STYLE);
  if val then
    Style := Style or WS_BORDER
  else
    Style := Style and (not WS_BORDER);
  SetWindowLong(FHandle,GWL_STYLE,Style);
  GetWindowRect(FHandle,r);
  ChangeWindowSize(FHandle,0,0);
  ChangeWindowSize(FHandle,r.Right-r.Left,r.Bottom-r.Top);
  FDrawFrame := val;
end;

function CreateProgressBar(hParent:HWND;x,y,cx,cy,cRangeMin,cRangeMax:integer;
            cVertical,cSmooth:Boolean;sOnChange:TNotifyMessage):TAPIProgress;
begin
  result := TAPIProgress.Create(hParent);
  with Result do begin
    Dimension := SetDim(x,y,cx,cy);
    RangeMin := cRangeMin;
    RangeMax := cRangeMax;
    Vertical := cVertical;
    Smooth := cSmooth;
    OnChange := sOnChange;
  end;
end;


end.

