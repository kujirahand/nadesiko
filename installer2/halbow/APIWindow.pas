unit APIWindow;

interface

uses
  Windows,
  Messages,
  UtilFunc,
  UtilClass,
  APIControl,
  GDIObject;

type
TCreateParamsEx = record
  dwExStyle: DWORD;
  lpClassName: PChar;
  lpWindowName: PChar;
  dwStyle: DWORD;
  X, Y, nWidth, nHeight: Integer;
  hWndParent: HWND;
  hMenu: HMENU;
  hInstance: HINST;
  lpParam: Pointer;
end;

//-------------- TAPIWindow -----------------------------------
TOnClassParams = procedure (var WC:TWndClass);
TOnWindowParams = procedure (var CP:TCreateParamsEx);

TAPIWindow = class(TObject)
private
  FHandle: HWND;
  FParent: HWND;
  FClassName: string;
  FColor: COLORREF;
  FOnClassParams: TOnClassParams;
  FOnWindowparams: TOnWindowParams;
  FOnCreate: TNotifyMessage;
  FOnDestroy: TNotifyMessage;
  FOnCommand: TNotifyMessage;
  procedure SetColor(value:COLORREF);
protected
  procedure APIClassParams(var WC:TWndClass); virtual;
  procedure APICreateParams(var CP:TCreateParamsEx); virtual;
public
  constructor Create(hParent:HWND;ClassName:string);virtual;
  destructor Destroy; override;
  procedure DefaultHandler(var Message);override;
  procedure DoCreate;virtual;
  property Handle: HWND read FHandle;
  property Parent: HWND read FParent;
  property Color: COLORREF read FColor write SetColor;
  property OnClassParams: TOnClassParams read FOnClassParams
                                         write FOnClassParams;
  property OnWindowParams: TOnWindowParams read FOnWindowParams
                                           write FOnWindowparams;
  property OnCreate: TNotifyMessage read FOnCreate write FOnCreate;
  property OnDestroy: TNotifyMessage read FOnDestroy write FOnDestroy;
  property OnCommand: TNotifyMessage read FOnCommand write FOnCommand;
end;

//-------------- TAPIWindow2 ----------------------------------
TAPIWindow2 = class(TAPIWindow)
private
  FTrapMessage: TIntegerList;
  FTrapHandler: TIntegerList;
  FNumHandler: integer;
public
  constructor Create(hParent:HWND;ClassName:string);override;
  destructor Destroy; override;
  procedure DefaultHandler(var Message); override;
  procedure Trap(Msg: UINT; Hndlr: TNotifyMessage);
  property NumHandler: integer read FNumHandler;
end;

//-------------- TAPIWindow3 ----------------------------------
TAPIWindow3 = class(TAPIWindow2)
private
  FOnShow: TNotifyMessage;
  FCursor: HCURSOR;
  function GetWidth: integer;
  procedure SetWidth(value: integer);
  function GetHeight: integer;
  procedure SetHeight(value: integer);
  function GetVisible: Boolean;
  procedure SetVisible(value: Boolean);
  function GetEnable: Boolean;
  procedure SetEnable(value:Boolean);
public
  procedure DefaultHandler(var Message);override;
  property Width: integer read GetWidth write SetWidth;
  property Height: integer read GetHeight write SetHeight;
  property Visible: Boolean  read GetVisible write SetVisible;
  property Enable: Boolean read GetEnable write SetEnable;
  property Cursor: HCURSOR read FCursor write FCursor;
  property OnShow: TNotifyMessage read FOnShow write FOnShow;
end;

//-------------- TSDIMainWindow ----------------------------------
TMaxMinRestore = (Max,Min,Restore);

TSDIMainWindow = class(TAPIWindow3)
private
  function GetXPos: integer;
  procedure SetXPos(value: integer);
  function GetYPos: integer;
  procedure SetYPos(value: integer);
  function GetTitle: string;
  procedure SetTitle(s: string);
  function GetIcon: HICON;
  procedure SetIcon(value: HICON);
  function GetClientWidth: integer;
  procedure SetClientWidth(value: integer);
  function GetClientHeight: integer;
  procedure SetClientHeight(value: integer);
  function GetState: TMaxMinRestore;
  procedure SetState(value: TMaxMinRestore);
public
  constructor Create(hParent:HWND;ClassName:string);override;
  procedure Center;
  procedure Close;
  property XPos: integer read GetXPos write SetXPos;
  property YPos: integer read GetYPos write SetYPos;
  property Title: string read GetTitle write SetTitle;
  property Icon: HICON read GetIcon write SetIcon;
  property ClientWidth: integer read GetClientWidth write SetClientWidth;
  property ClientHeight: integer read GetClientHeight write SetClientHeight;
  property State: TMaxMinRestore read GetState write SetState;
end;

//---------- TAPIPanel ----------------------------------------------
TEdgeStyle = (esNone,esRaised,esSunken);

TAPIPanel = class(TAPIWindow3)
private
  FOuterEdge: TEdgeStyle;
  FInnerEdge: TEdgeStyle;
  FEdgeWidth: integer;
  function GetDimension: TRect;
  procedure SetDimension(value: TRect);
  function GetXPos: integer;
  procedure SetXPos(value: integer);
  function GetYPos: integer;
  procedure SetYPos(value: integer);
  procedure SetOuterEdge(value: TEdgeStyle);
  procedure SetInnerEdge(value: TEdgeStyle);
  procedure SetEdgeWidth(value: integer);
protected
  procedure APIClassParams(var WC:TWndClass); override;
  procedure APICreateParams(var CP:TCreateParamsEx); override;
public
  procedure DefaultHandler(var Message); override;
  property Dimension : TRect read GetDimension write SetDimension;
  property XPos: integer read GetXPos write SetXPos;
  property YPos: integer read GetYPos write SetYPos;
  property OuterEdge: TEdgeStyle read FOuterEdge write SetOuterEdge;
  property InnerEdge: TEdgeStyle read FInnerEdge write SetInnerEdge;
  property EdgeWidth: integer read FEdgeWidth write SetEdgeWidth;
end;

//--------------- TAPIDialog -------------------------------
type
TAPIDialog = class(TObject)
private
  FHandle: HWND;
  FOwner: HWND;
  FStyle: DWORD;
  FTitle: string;
  FPosX: integer;
  FPosY: integer;
  FColor: COLORREF;
  FWidth:integer;
  FHeight:integer;
  FClientWidth:integer;
  FClientHeight:integer;
  FIcon: HICON;
  FOnInitDialog: TNotifyMessage;
  FOnCommand: TNotifyMessage;
  FOnDestroy: TNotifyMessage;
  procedure SetTitle(value: string);
  procedure SetPosX(value: integer);
  procedure SetPosY(value: integer);
  function GetWidth: integer;
  procedure SetWidth(value: integer);
  function GetHeight: integer;
  procedure SetHeight(value: integer);
  function GetClientWidth: integer;
  procedure SetClientWidth(value: integer);
  function GetClientHeight: integer;
  procedure SetClientHeight(value: integer);
  procedure SetColor(value: COLORREF);
  procedure SetIcon(value:HICON);
protected
  procedure InitWidthHeight;
public
  constructor Create(hOwner:HWND);virtual;
  destructor Destroy; override;
  property Owner: HWND read FOwner;
  property Handle: HWND read FHandle write FHandle;
  property Style: DWORD read FStyle write FStyle;
  property Title: string read FTitle write SetTitle;
  property PosX:integer read FPosX write SetPosX;
  property PosY:integer read FPosY write SetPosY;
  property Width: integer read GetWidth write SetWidth;
  property Height: integer read GetHeight write SetHeight;
  property ClientWidth: integer read GetClientWidth write SetClientWidth;
  property ClientHeight: integer read GetClientHeight write SetClientHeight;
  property Color: COLORREF read FColor write SetColor;
  property Icon: HICON read FIcon write SetIcon;
  property OnInitDialog: TNotifyMessage
                  read FOnInitDialog write FOnInitDialog;
  property OnCommand: TNotifyMessage
                  read FOnCommand write FOnCommand;
  property OnDestroy: TNotifyMessage
                  read FOnDestroy write FOnDestroy;
end;

//--------------- TModalDialog -------------------------------
TModalDialog = class(TAPIDialog)
private
protected
public
  constructor Create(hOwner:HWND);override;
  procedure DefaultHandler(var Message); override;
  function Show:integer;
  procedure Close(rslt: integer);
  procedure Center;
end;

//---------------- AInputBox ------------------------------
type
TInputBox = class(TModalDialog)
private
  FLabel:TAPILabel;
  FEdit: TAPIEdit;
  FOK: TAPIButton;
  FCancel: TAPIButton;
  FPrompt:string;
  FDefault:string;
public
  constructor Create(hOwner:HWND);override;
  procedure DefaultHandler(var Message); override;
  property Prompt:string read FPrompt write FPrompt;
  property DefString:string read FDefault write FDefault;
end;

//--------------- TModelessDialog -------------------------------
type
TModelessDialog = class(TAPIDialog)
private
  FClassName:string;
  FExStyle: DWORD;
  FPhDialog: PInteger;
  FOnCreate: TNotifyMessage;
protected
public
  constructor Create(hOwner:HWND;ClassName:string); virtual;
  destructor Destroy; override;
  procedure DefaultHandler(var Message); override;
  function Show:HWND;
  procedure Close;
  procedure Center;
  property ExStyle:DWORD read FExStyle write FExStyle;
  property PhDialog: PInteger read FPhDialog write FPhDialog;
  property OnCreate :TNotifyMessage read FOnCreate write FOnCreate;
end;

function CreateModelessDialog(hOwner:HWND;clsnm:string;x,y,cw,ch:integer;
                 ExStyle,Style:DWORD;sOnCreate:TNotifyMessage):TModelessDialog;


function AInputBox(hOwner:HWND;ATitle,APrompt,ADefault:string):string;


function CreateModalDialog(hOwner:HWND;x,y,cw,ch:integer;
                           Style:DWORD;sOnInit:TNotifyMessage):TModalDialog;


function CreatePanel(hParent:HWND;x,y,cx,cy:integer):TAPIPanel;


implementation

{---------------------------------------------------------------------
             Custom Window Procedure
----------------------------------------------------------------------}
function CustomWndProc(hWindow: HWND; Msg: UINT; WParam: WPARAM;
                            LParam: LPARAM): LRESULT; stdcall;
var
  WPMsg: TMessage;
  Wnd: TAPIWindow;
  pCS: PCreateStruct;
begin

   Result := 0;

   if Msg = WM_NCCREATE then begin
     pCS := Pointer(LParam);
     SetProp(hWindow,'OBJECT',integer(pCS^.lpCreateParams));
     TAPIWindow(pCS^.lpCreateParams).FHandle := hWindow;
   end;

   WPMsg.Msg := Msg;
   WPMsg.WParam := WParam;
   WPMsg.LParam := LParam;
   WPMsg.Result := 0;

   Wnd := TAPIWindow(GetProp(hWindow,'OBJECT'));

   case Msg of

{------------------  WM_DESTROY  --------------------------------}

     WM_DESTROY: begin
       if Assigned(Wnd) then begin
         Wnd.Dispatch(WPMsg);
         Wnd.Free;
       end;
     end;

{---------  他のメッセージをオブジェクトに Dispatch する ----}
   else begin
       if Assigned(Wnd) then Wnd.Dispatch(WPMsg);
       if WPMsg.Result = 0 then
         Result := DefWindowProc( hWindow, Msg, wParam, lParam )
       else Result := WPMsg.Result;
     end;

   end; // case

end;

//-------------------- TAPIWindow ---------------------------
constructor TAPIWindow.Create(hParent:HWND;ClassName:string);
begin
  FParent := hParent;
  FClassName := ClassName;
  FColor := clrBtnFace;
end;

destructor TAPIWindow.Destroy;
begin
  RemoveProp(FHandle,'OBJECT');
  inherited Destroy;
end;

procedure TAPIWindow.APIClassParams(var WC:TWndClass);
begin
  WC.lpszClassName   := PChar(FClassName);
  WC.lpfnWndProc     := @CustomWndProc;
  WC.style           := CS_VREDRAW or CS_HREDRAW;
  WC.hInstance       := hInstance;
  WC.hIcon           := LoadIcon(0,IDI_APPLICATION);
  WC.hCursor         := LoadCursor(0,IDC_ARROW);
  WC.hbrBackground   := ( COLOR_WINDOW+1 );
  WC.lpszMenuName    := nil;
  WC.cbClsExtra      := 0;
  WC.cbWndExtra      := 0;
  If Assigned(FOnClassParams) then FOnClassParams(WC);
end;

procedure TAPIWindow.APICreateParams(var CP:TCreateParamsEx);
begin
  CP.dwExStyle           := 0;
  CP.lpClassName         := PChar(FClassName);
  CP.lpWindowName        := PChar(FClassName);
  CP.dwStyle             := WS_VISIBLE or WS_OVERLAPPEDWINDOW;
  CP.X                   := CW_USEDEFAULT;
  CP.Y                   := 0;
  CP.nWidth              := CW_USEDEFAULT;
  CP.nHeight             := 0;
  CP.hWndParent          := FParent;
  CP.hMenu               := 0;
  CP.hInstance           := hInstance;
  CP.lpParam             := self;
  If Assigned(FOnWindowParams) then FOnWindowParams(CP);
end;

procedure TAPIWindow.DefaultHandler(var Message);
var
  AMsg:TMessage;
begin

  AMsg := TMessage(Message);

  case AMsg.Msg of

    WM_CREATE: if Assigned(FOnCreate) then OnCreate(AMsg);

    WM_DESTROY: if Assigned(FOnDestroy) then OnDestroy(AMsg);

    WM_COMMAND: if Assigned(FOnCommand) then OnCommand(AMsg);

    WM_ERASEBKGND: AMsg.result := EraseBkGnd(FHandle,FColor,AMsg.WParam);

  end; // case

  TMessage(Message).result := AMsg.result;

end;         

procedure TAPIWindow.DoCreate;
var
  WC: TWndClass;
  CP: TCreateParamsEx;
begin

  APIClassParams(WC);
  RegisterClass(WC);

  APICreateParams(CP);

  CreateWindowEx(CP.dwExStyle,
                 CP.lpClassName,
                 CP.lpWindowName,
                 CP.dwStyle,
                 CP.X,
                 CP.Y,
                 CP.nWidth,
                 CP.nHeight,
                 CP.hWndParent,
                 CP.hMenu,
                 CP.hInstance,
                 CP.lpParam);

  ShowWindow( FHandle, SW_SHOW);
  UpDateWindow(FHandle);
end;

procedure TAPIWindow.SetColor(value: COLORREF);
begin
  if  FColor = value then Exit;
  FColor := value;
  InvalidateRect(FHandle,nil,true);
end;

//-------------- TAPIWindow2 ----------------------------------
constructor TAPIWindow2.Create(hParent:HWND;ClassName:string);
begin
  inherited Create(hParent,ClassName);
  FTrapMessage := TIntegerList.Create($10,$10);
  FTrapHandler := TIntegerList.Create($10,$10);
end;

destructor TAPIWindow2.Destroy;
begin
  FTrapMessage.Free;
  FTrapHandler.Free;
  inherited Destroy;
end;

procedure TAPIWindow2.DefaultHandler(var Message);
var
  AMsg:TMessage;
  i: integer;
begin

  AMsg := TMessage(Message);

  case AMsg.Msg of

    WM_CREATE:if Assigned(FOnCreate) then OnCreate(AMsg);

    WM_COMMAND:if Assigned(FOnCreate) then OnCommand(AMsg);

    WM_DESTROY:if Assigned(FOnDestroy) then OnDestroy(AMsg);

    WM_ERASEBKGND:AMsg.result := EraseBkGnd(FHandle,FColor,AMsg.WParam);

  else if FNumHandler > 0 then begin
    i := FTrapMessage.Search(integer(AMsg.Msg));
    if i <> -1 then TNotifyMessage(FTrapHandler[i])(AMsg);
    end;

  end; // case

  TMessage(Message).result := AMsg.result;

end;

procedure TAPIWindow2.Trap(Msg: UINT; Hndlr: TNotifyMessage);
begin
  Inc(FNumHandler);
  FTrapMessage[FNumHandler-1] := integer(Msg);
  FTrapHandler[FNumHandler-1] := integer(@Hndlr);
end;

//-------------- TAPIWindow3 ----------------------------------
procedure TAPIWindow3.DefaultHandler(var Message);
var
  AMsg:TMessage;
  i: integer;
begin

  AMsg := TMessage(Message);

  case AMsg.Msg of

    WM_CREATE: if Assigned(FOnCreate) then OnCreate(AMsg);

    WM_DESTROY: if Assigned(FOnDestroy) then OnDestroy(AMsg);

    WM_COMMAND: if Assigned(FOnCommand) then OnCommand(AMsg);

    WM_ERASEBKGND: AMsg.result := EraseBkGnd(FHandle,FColor,AMsg.WParam);

    WM_SETCURSOR : if AMsg.LParamLo = HTCLIENT then begin
        SetCursor(FCursor);
        AMsg.Result := 1;
      end;

    WM_SHOWWINDOW: if Assigned(FOnShow) then OnShow(AMsg);

  else if FNumHandler > 0 then begin
    i := FTrapMessage.Search(integer(AMsg.Msg));
    if i <> -1 then TNotifyMessage(FTrapHandler[i])(AMsg);
    end;

  end; // case

  TMessage(Message).result := AMsg.result;

end;
function TAPIWindow3.GetWidth: integer;
var
  r: TRect;
begin
  GetWindowRect(FHandle,r);
  result := r.Right-r.Left+1;
end;

procedure TAPIWindow3.SetWidth(value: integer);
var
  r: TRect;
begin
  GetWindowRect(FHandle,r);
  ChangeWindowSize(FHandle,value,(r.Bottom-r.Top+1));
end;

function TAPIWindow3.GetHeight: integer;
var
  r: TRect;
begin
  GetWindowRect(FHandle,r);
  result := r.Bottom-r.Top+1;
end;

procedure TAPIWindow3.SetHeight(value: integer);
var
  r: TRect;
begin
  GetWindowRect(FHandle,r);
  ChangeWindowSize(FHandle,(r.Right-r.Left+1),value);
end;

function TAPIWindow3.GetVisible: Boolean;
begin
  result := IsWindowVisible(FHandle);
end;

procedure TAPIWindow3.SetVisible(value: Boolean);
begin
  if value then
    ShowWindow(FHandle,SW_SHOW)
  else
    ShowWindow(FHandle,SW_HIDE);
end;

function TAPIWindow3.GetEnable: Boolean;
begin
  result := Boolean(IsWindowEnabled(FHandle));
end;

procedure TAPIWindow3.SetEnable(value: Boolean);
begin
  EnableWindow(FHandle,value);
end;

//-------------- TSDIMainWindow ----------------------------------
constructor TSDIMainWindow.Create(hParent:HWND;ClassName:string);
begin
  inherited Create(hParent,ClassName);
  FCursor := LoadCursor(0,IDC_ARROW);
end;

procedure TSDIMainWindow.Center;
begin
  CenterWindow(FHandle);
end;

procedure TSDIMainWindow.Close;
begin
  DestroyWindow(FHandle);
end;

function TSDIMainWindow.GetXPos: integer;
var
  r: TRect;
  p: TPoint;
begin
  GetWindowRect(FHandle,r);
  p.x := r.Left; p.y := r.Top;
  ScreenToClient(Parent,p);
  result := p.x;
end;

procedure TSDIMainWindow.SetXPos(value: integer);
begin
  ChangeWindowPos(FHandle,value,YPos);
end;

function TSDIMainWindow.GetYPos: integer;
var
  r: TRect;
  p: TPoint;
begin
  GetWindowRect(FHandle,r);
  p.x := r.Left; p.y := r.Top;
  ScreenToClient(Parent,p);
  result := p.y;
end;

procedure TSDIMainWindow.SetYPos(value: integer);
begin
  ChangeWindowPos(FHandle,XPos,value);
end;

function TSDIMainWindow.GetTitle: string;
var
  s: string;
  len: integer;
begin
  SetLength(s,100);
  len := GetWindowText(FHandle,PChar(s),100);
  SetLength(s,len);
  result := s;
end;

procedure TSDIMainWindow.SetTitle(s: string);
begin
  SetWindowText(FHandle, PChar(s));
end;

function TSDIMainWindow.GetIcon: HICON;
begin
  result := GetClassLong(FHandle,GCL_HICON);
end;

procedure TSDIMainWindow.SetIcon(value: HICON);
begin
  SetClassLong(FHandle,GCL_HICON,value);
end;

function TSDIMainWindow.GetClientWidth: integer;
var
  r: TRect;
begin
  GetClientRect(FHandle,r);
  result := r.Right+1;
end;

procedure TSDIMainWindow.SetClientWidth(value: integer);
begin
  ChangeWindowSize(FHandle,(value+Width-ClientWidth-1),Height);
end;

function TSDIMainWindow.GetClientHeight: integer;
var
  r: TRect;
begin
  GetClientRect(FHandle,r);
  result := r.Bottom+1;
end;

procedure TSDIMainWindow.SetClientHeight(value: integer);
begin
  ChangeWindowSize(FHandle,Width,(value+Height-ClientHeight));
end;

procedure TSDIMainWindow.SetState(value: TMaxMinRestore);
begin
  case value of
    Max: ShowWindow(FHandle,SW_SHOWMAXIMIZED);
    Min: ShowWindow(FHandle,SW_SHOWMINIMIZED);
    Restore: ShowWindow(FHandle,SW_RESTORE);
  end;
end;

function TSDIMainWindow.GetState: TMaxMinRestore;
begin
  if IsZoomed(FHandle) then
    result := Max
  else
    if IsIconic(FHandle) then
      result := Min
    else
      result := Restore;
end;

//--------------- TAPIPanel ----------------------------------------------
function PanelWndProc(hWindow: HWND; Msg: UINT; WParam: WPARAM;
                            LParam: LPARAM): LRESULT; stdcall;
var
  WPMsg: TMessage;
  Wnd: TAPIPanel;
  pCS: PCreateStruct;
begin
   Result := 0;
   
   if Msg = WM_CREATE then begin
     pCS := Pointer(LParam);
     SetProp(hWindow,'OBJECT',integer(pCS^.lpCreateParams));
     TAPIPanel(pCS^.lpCreateParams).FHandle := hWindow;
   end;

   Wnd := TAPIPanel(GetProp(hWindow,'OBJECT'));

   case Msg of

{------------------  WM_PAINT,WMERASEBKGND  ---------------------}

     WM_PAINT,WM_ERASEBKGND,WM_CONTEXTMENU: begin
       WPMsg.Msg := Msg;
       WPMsg.WParam := WParam;
       WPMsg.LParam := LParam;
       WPMsg.Result := Result;
       if Assigned(Wnd) then begin
         Wnd.Dispatch(WPMsg);
         if WPMsg.result <> 0 then Result := WPMsg.result;
       end;
     end;

{------------------  WM_DESTROY  --------------------------------}

     WM_DESTROY: begin
       if Assigned(Wnd) then begin
         Wnd.Free;
       end;
     end;

   else Result := DefWindowProc( hWindow, Msg, wParam, lParam );

   end; //case

end;

procedure TAPIPanel.APIClassParams(var WC:TWndClass);
begin
  WC.lpszClassName   := 'APIPanel';
  WC.lpfnWndProc     := @PanelWndProc;
  WC.style           := CS_VREDRAW or CS_HREDRAW;
  WC.hInstance       := hInstance;
  WC.hIcon           := 0;
  WC.hCursor         := LoadCursor(0,IDC_ARROW);
  WC.hbrBackground   := ( COLOR_BTNFACE+1 );
  WC.lpszMenuName    := nil;
  WC.cbClsExtra      := 0;
  WC.cbWndExtra      := 0;

  FOuterEdge := esRaised;
  FInnerEdge := esNone;
  FEdgeWidth := 2;

  If Assigned(FOnClassParams) then FOnClassParams(WC);
end;

procedure TAPIPanel.APICreateParams(var CP:TCreateParamsEx);
begin
  CP.dwExStyle           := WS_EX_CONTROLPARENT;
  CP.lpClassName         := 'APIPanel';
  CP.lpWindowName        := 'APIPanel';
  CP.dwStyle             := WS_CHILD or WS_VISIBLE or WS_CLIPSIBLINGS;
  CP.X                   := 0;
  CP.Y                   := 0;
  CP.nWidth              := 0;
  CP.nHeight             := 0;
  CP.hWndParent          := FParent;
  CP.hMenu               := 0;
  CP.hInstance           := hInstance;
  CP.lpParam             := self;
  If Assigned(FOnWindowParams) then FOnWindowParams(CP);
end;

procedure TAPIPanel.DefaultHandler(var Message);
var
  AMsg:TMessage;
  r: TRect;
  DC: HDC;
  ps: TPaintStruct;
begin
  AMsg := TMessage(message);
  case AMsg.Msg of
    WM_PAINT:begin
      DC := BeginPaint(FHandle,ps);
        GetClientRect(FHandle,r);
        case FOuterEdge of
          esRaised:DrawEdge(DC,r,BDR_RAISEDOUTER or BDR_RAISEDINNER,
                 BF_RECT);
          esSunken:DrawEdge(DC,r,BDR_SUNKENOUTER or BDR_SUNKENINNER,
                 BF_RECT);
        end;
        InflateRect(r,-FEdgeWidth,-FEdgeWidth);
        case FInnerEdge of
          esRaised:DrawEdge(DC,r,BDR_RAISEDOUTER or BDR_RAISEDINNER,
                 BF_RECT);
          esSunken:DrawEdge(DC,r,BDR_SUNKENOUTER or BDR_SUNKENINNER,
                 BF_RECT);
        end;
      EndPaint(FHandle,ps);
    end;
    WM_ERASEBKGND:TMessage(message).Result := EraseBkgnd(FHandle,
                   FColor,AMsg.WParam);
  end; // case
end;

function TAPIPanel.GetDimension: TRect;
begin
  result := SetDim(XPos,YPos,Width,Height);
end;

procedure TAPIPanel.SetDimension(value: TRect);
begin
  MoveWindow(FHandle,value.left, value.top,
                   value.right, value.bottom, true);
end;

function TAPIPanel.GetXPos: integer;
var
  r: TRect;
  p: TPoint;
begin
  GetWindowRect(FHandle,r);
  p.x := r.Left; p.y := r.Top;
  ScreenToClient(FParent,p);
  result := p.x;
end;

procedure TAPIPanel.SetXPos(value: integer);
begin
  ChangeWindowPos(FHandle,value,YPos);
end;

function TAPIPanel.GetYPos: integer;
var
  r: TRect;
  p: TPoint;
begin
  GetWindowRect(FHandle,r);
  p.x := r.Left; p.y := r.Top;
  ScreenToClient(FParent,p);
  result := p.y;
end;

procedure TAPIPanel.SetYPos(value: integer);
begin
  ChangeWindowPos(FHandle,XPos,value);
end;
        
procedure TAPIPanel.SetOuterEdge(value: TEdgeStyle);
begin
  FOuterEdge := value;
  InvalidateRect(FHandle,nil,true);
end;

procedure TAPIPanel.SetInnerEdge(value: TEdgeStyle);
begin
  FInnerEdge := value;
  InvalidateRect(FHandle,nil,true);
end;

procedure TAPIPanel.SetEdgeWidth(value: integer);
begin
  FEdgeWidth := value;
  InvalidateRect(FHandle,nil,true);
end;

function CreatePanel(hParent:HWND;x,y,cx,cy:integer):TAPIPanel;
begin
  result := TAPIPanel.Create(hParent,'');
  result.DoCreate;
  result.Dimension := SetDim(x,y,cx,cy);
end;

//--------------- TAPIDialog -------------------------------
constructor TAPIDialog.Create(hOwner:HWND);
begin
  FHandle := 0;
  FOwner := hOwner;
  FColor := clrBtnFace;
end;

destructor TAPIDialog.Destroy;
begin
  inherited Destroy;
end;

procedure TAPIDialog.SetTitle(value: string);
begin
  FTitle := value;
  if FHandle <> 0 then
    SetWindowText(FHandle,PChar(value));
end;

procedure TAPIDialog.SetPosX(value: integer);
var
  pt: TPoint;
begin
  FPosX := value;
  if FHandle <> 0 then begin
    pt.x := value;
    pt.y := FPosY;
    ClientToScreen(FOwner,pt);
    ChangeWindowPos(FHandle,pt.x,pt.y);
  end;
end;

procedure TAPIDialog.SetPosY(value: integer);
var
  pt: TPoint;
begin
  FPosY := value;
  if FHandle <> 0 then begin
    pt.x := FPosX;
    pt.y := value;
    ClientToScreen(FOwner,pt);
    ChangeWindowPos(FHandle,pt.x,pt.y);
  end;
end;

function TAPIDialog.GetWidth: integer;
var
  r: TRect;
begin
  if FHandle  = 0 then
    result := FWidth
  else begin
    GetWindowRect(FHandle,r);
    result := r.Right-r.Left;
  end;
end;

procedure TAPIDialog.SetWidth(value: integer);
var
  r: TRect;
begin
  if FHandle = 0 then
    FWidth := value
  else begin
    GetWindowRect(FHandle,r);
    ChangeWindowSize(FHandle,value,(r.Bottom-r.Top));
  end;
end;

function TAPIDialog.GetHeight: integer;
var
  r: TRect;
begin
  if FHandle = 0 then
    result := FHeight
  else begin
    GetWindowRect(FHandle,r);
    result := r.Bottom-r.Top;
  end;
end;

procedure TAPIDialog.SetHeight(value: integer);
var
  r: TRect;
begin
  if FHandle = 0 then
    FHeight := value
  else begin
    GetWindowRect(FHandle,r);
    ChangeWindowSize(FHandle,(r.Right-r.Left),value);
  end;
end;

function TAPIDialog.GetClientWidth: integer;
var
  r: TRect;
begin
  if FHandle = 0  then
    result := FClientWidth
  else begin
    GetClientRect(FHandle,r);
    result := r.Right;
  end;
end;

procedure TAPIDialog.SetClientWidth(value: integer);
begin
  if FHandle = 0 then
    FClientWidth := value
  else
    ChangeWindowSize(FHandle,(value+Width-ClientWidth),Height);
end;

function TAPIDialog.GetClientHeight: integer;
var
  r: TRect;
begin
  if FHandle = 0 then
    result := FClientHeight
  else begin
    GetClientRect(FHandle,r);
    result := r.Bottom;
  end;
end;

procedure TAPIDialog.SetClientHeight(value: integer);
begin
  if FHandle = 0 then
    FClientHeight := value
  else
    ChangeWindowSize(FHandle,Width,(value+Height-ClientHeight));
end;

procedure TAPIDialog.InitWidthHeight;
begin
  ChangeWindowSize(FHandle,100,100);
  if FClientWidth <> 0 then
    SetClientWidth(FClientWidth)
  else
    if FWidth <> 0 then SetWidth(FWidth);

  if FClientHeight <> 0 then
    SetClientHeight(FClientHeight)
  else
    if FHeight <> 0 then SetHeight(FHeight);
end;

procedure TAPIDialog.SetColor(value: COLORREF);
begin
  if  FColor = value then Exit;
  FColor := value;
  if FHandle <> 0 then InvalidateRect(FHandle,nil,true);
end;

procedure TAPIDialog.SetIcon(value:HICON);
begin
  FIcon := value;
  if FHandle <> 0 then SetClassLong(FHandle,GCL_HICON,value);
end;

//--------------- TModalDialog -------------------------------
function ModalDlgProc(hDlg: HWND; Msg: UINT;
                     wparam, lparam: integer):BOOL; stdcall;
var
  AMsg: TMessage;
  Obj: integer;
begin
  result := true;
  AMsg.Msg := Msg;
  AMsg.WParam := wparam;
  AMsg.LParam := lparam;
  AMsg.Result := 0;
  case Msg of
    WM_INITDIALOG: begin
      SetProp(hDlg,'PASCAL',lparam);
      AMsg.Result := 1;
      TAPIDialog(lparam).Handle := hDlg;
      TAPIDialog(lparam).Dispatch(AMsg);
      result := Bool(AMsg.Result)
    end;

    WM_COMMAND: begin
      Obj := GetProp(hDlg,'PASCAL');
      if Obj <> 0 then TAPIDialog(Obj).Dispatch(AMsg);
    end;

    WM_DESTROY: begin
      Obj := GetProp(hDlg,'PASCAL');
      if Obj <> 0 then begin
        TAPIDialog(Obj).Dispatch(AMsg);
        TAPIDialog(Obj).Free;
      end;
      RemoveProp(hDlg,'PASCAL');
    end;

  else begin
    Obj := GetProp(hDlg,'PASCAL');
      if Obj = 0 then
        result := false
      else begin
        TAPIDialog(Obj).Dispatch(AMsg);
        result := BOOL(AMsg.Result);
      end;
    end;
  end;
end;

constructor TModalDialog.Create(hOwner:HWND);
begin
  inherited Create(hOwner);
  FStyle := DS_MODALFRAME or WS_POPUP or WS_VISIBLE;
  FTitle := 'APIModalDialog';
end;

procedure TModalDialog.DefaultHandler(var Message);
var
  AMsg:TMessage;
begin

  AMsg := TMessage(Message);

  case AMsg.Msg of

    WM_INITDIALOG: begin
      SetIcon(FIcon);
      InitWidthHeight;
      SetPosX(FPosX);
      SetPosY(FPosY);
      SetWindowText(FHandle,PChar(FTitle));
      if Assigned(FOnInitDialog) then OnInitDialog(AMsg);
      TMessage(Message).Result := AMsg.Result;
    end;

    WM_ERASEBKGND:
      TMessage(Message).result :=
                 EraseBkGnd(FHandle,FColor,AMsg.WParam);

    WM_DESTROY: begin
      if Assigned(FOnDestroy) then OnDestroy(AMsg);
    end;

    WM_COMMAND: if Assigned(FOnCommand) then
                  OnCommand(AMsg)
                else if AMsg.WParamLo = ID_CANCEL then
                        Close(ID_CANCEL);

  end;
end;

function TModalDialog.Show:integer;
var
  pMyTmp: PDlgTemplate;
begin
  GetMem(pMyTmp,SizeOf(TDlgTemplate)+10);
  ZeroMemory(pMyTmp,SizeOf(TDlgTemplate)+10);
  pMyTmp^.style := FStyle;
  result := DialogBoxIndirectParam(hInstance,pMyTmp^,
                                   FOwner,@ModalDlgProc,integer(self));
  FreeMem(pMyTmp);
end;

procedure TModalDialog.Close(rslt: integer);
begin
  EndDialog(FHandle,rslt);
end;

procedure TModalDialog.Center;
begin
  CenterWindow(FHandle);
end;

//--------------------------------------------------------------

function CreateModalDialog(hOwner:HWND;x,y,cw,ch:integer;
                           Style:DWORD;sOnInit:TNotifyMessage):TModalDialog;
begin
  result := TModalDialog.Create(hOwner);
  if Style <> 0 then result.Style := Style;
  result.PosX := x;
  result.PosY := y;
  result.ClientWidth := cw;
  result.ClientHeight := ch;
  result.OnInitDialog := sOnInit;
end;

//---------------- AInputBox ------------------------------
var
  resultString:string;

constructor TInputBox.Create(hOwner:HWND);
begin
  inherited Create(hOwner);
  Style := Style or WS_CAPTION or WS_SYSMENU;
  FPosX := 50;
  FPosY := 50;
  FClientWidth := 300;
  FClientHeight := 120;
end;

procedure OKClick(var Msg: TMessage);
var
  Obj: TInputBox;
begin
  Obj := TInputBox(GetProp(TAPIButton(Msg.Msg).Parent,'PASCAL'));
  Obj.Close(IDOK);
end;

procedure CancelClick(var Msg: TMessage);
var
  Obj: TInputBox;
begin
  Obj := TInputBox(GetProp(TAPIButton(Msg.Msg).Parent,'PASCAL'));
  Obj.Close(IDCANCEL);
end;

procedure EditChange(var Msg: TMessage);
begin
  resultString := TAPIEdit(Msg.Msg).Text;
end;

procedure TInputBox.DefaultHandler(var Message);
var
  AMsg:TMessage;
begin

  AMsg := TMessage(Message);

  case AMsg.Msg of

    WM_INITDIALOG: begin
      InitWidthHeight;
      PosX := FPosX;
      PosY := FPosY;
      Title := FTitle;
      FLabel := CreateLabel(FHandle,10,10,280,30,FPrompt);
      FLabel.BkMode := TRANSPARENT;
      FEdit := CreateEdit(FHandle,10,45,280,30,FDefault,EditChange);
      FOK := CreateButton(FHandle,40,80,100,30,'&O K',OKClick);
      FCancel := CreateButton(FHandle,160,80,100,30,'&Cancel',CancelClick);
      if Assigned(OnInitDialog) then OnInitDialog(AMsg);
    end;

    WM_COMMAND: if AMsg.WParamLo = ID_CANCEL then Close(ID_CANCEL);

  end;
end;

function AInputBox(hOwner:HWND;ATitle,APrompt,ADefault:string):string;
var
  AInputBox: TInputBox;
  ret:integer;
begin
  AInputBox := TInputBox.Create(hOwner);
  with AInputBox do begin
    Title := ATitle;
    Prompt := APrompt;
    DefString := ADefault;
  end;
  ret := AInputBox.Show;
  if ret = IDOK then result := resultString else result := ADefault;
end;

//--------------- TModelessDialog -------------------------------
constructor TModelessDialog.Create(hOwner:HWND;ClassName:string);
begin
  FHandle := 0;
  FOwner := hOwner;
  FColor := clrBtnFace;
  FStyle := WS_POPUP or WS_VISIBLE or WS_CAPTION or
            WS_SYSMENU or WS_DLGFRAME;
  FExStyle := WS_EX_TOOLWINDOW;
  FClassName := ClassName;
  FTitle := 'APIModolessDialog';
end;

destructor TModelessDialog.Destroy;
begin
  RemoveProp(FHandle,'OBJECT');
  inherited Destroy;
end;

procedure TModelessDialog.DefaultHandler(var Message);
var
  AMsg:TMessage;
begin

  AMsg := TMessage(Message);

  case AMsg.Msg of

    WM_CREATE: begin
      SetIcon(FIcon);
      InitWidthHeight;
      SetPosX(FPosX);
      SetPosY(FPosY);
      SetWindowText(FHandle,PChar(FTitle));
      if Assigned(FOnCreate) then FOnCreate(AMsg);
    end;

    WM_ERASEBKGND:
      TMessage(Message).result :=
                 EraseBkGnd(FHandle,FColor,AMsg.WParam);

    WM_DESTROY: begin
      if Assigned(FOnDestroy) then OnDestroy(AMsg);
    end;

    WM_COMMAND: begin
      if Assigned(FOnCommand) then OnCommand(AMsg);
      if AMsg.WParamLo = ID_CANCEL then Close;
    end;

    WM_ACTIVATE: begin
      if (AMsg.WParamLo<>WA_INACTIVE) and (FPhDialog<>nil) then
        FPhDialog^ := FHandle;
    end;
  end;
end;

function TModelessDialog.Show:HWND;
var
  WC:TWndClass;
begin
  WC.lpszClassName   := PChar(FClassName);
  WC.lpfnWndProc     := @CustomWndProc;
  WC.style           := CS_VREDRAW or CS_HREDRAW;
  WC.hInstance       := hInstance;
  WC.hIcon           := 0;
  WC.hCursor         := LoadCursor(0,IDC_ARROW);
  WC.hbrBackground   := ( COLOR_BTNFACE+1 );
  WC.lpszMenuName    := nil;
  WC.cbClsExtra      := 0;
  WC.cbWndExtra      := 0;

  RegisterClass(WC);

  FHandle := CreateWindowEx(FExStyle,
                            PChar(FClassName),
                            PChar(FTitle),
                            FStyle,
                            0,
                            0,
                            100,
                            100,
                            FOwner,
                            0,
                            hInstance,
                            self);

  ShowWindow( FHandle, SW_SHOW);
  UpDateWindow(FHandle);
  result := FHandle;
end;

procedure TModelessDialog.Close;
begin
  DestroyWindow(FHandle);
end;

procedure TModelessDialog.Center;
begin
  CenterWindow(FHandle);
end;

function CreateModelessDialog(hOwner:HWND;clsnm:string;x,y,cw,ch:integer;
                 ExStyle,Style:DWORD;sOnCreate:TNotifyMessage):TModelessDialog;
begin
  result := TModelessDialog.Create(hOwner,clsnm);
  if ExStyle <> 0 then result.ExStyle := ExStyle;
  if Style <> 0 then result.Style := Style;
  result.PosX := x;
  result.PosY := y;
  result.ClientWidth := cw;
  result.ClientHeight := ch;
  result.OnCreate := sOnCreate;
end;

end.
