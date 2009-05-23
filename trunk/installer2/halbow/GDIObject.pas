unit GDIObject;

interface

uses
  windows,
  messages,
  UtilFunc,
  UtilClass;

//------------------ TGDIObject ------------------------------
type
TGDIObject = class(TSubClass)
private
  FDimension: TRect;
  FRect: TRect;
  FVisible: Boolean;
  FEnable: Boolean;
  procedure SetDimension(value:TRect);
  procedure SetVisible(value: Boolean);
  procedure SetEnable(value: Boolean);
protected
public
  constructor Create(hParent:HWND);override;
  destructor Destroy; override;
  procedure Update;
  procedure UpdateAll;
  property Dimension: TRect read FDimension write SetDimension;
  property Visible: Boolean read FVisible write SetVisible;
  property Enable: Boolean read FEnable write SetEnable;
end;

//-------------------- TAPISpeedBtn -------------------------------------
TAPISpeedBtn = class(TGDIObject)
private
  FCaption: string;
  FDown: Boolean;
  FFont: TAPIGFont;              // この行を追加する
  FOnClick: TNotifyMessage;
  procedure SetCaption(value:string);
protected
  FEdge: UINT;
public
  constructor Create(hParent:HWND); override;
  destructor Destroy; override;  // この行を追加する
  procedure DefaultHandler(var Message);override;
  property Caption: string read FCaption write SetCaption;
  property Font: TAPIGFont read FFont;  // この行を追加する
  property OnClick: TNotifyMessage read FOnClick write FOnClick;
end;

//-------------  TAPIColorBtn ---------------------------------------------
TAPIColorBtn = class(TAPISpeedBtn)
private
  FColor: COLORREF;
  FTextColor: COLORREF;
  procedure SetColor(value:COLORREF);
  procedure SetTextColor(value:COLORREF);
public
  constructor Create(hParent:HWND); override;
  procedure DefaultHandler(var Message);override;
  property Color: COLORREF read FColor write SetColor;
  property TextColor: COLORREF read FTextColor write SetTextColor;
end;

//-------------  TAPILabel ---------------------------------------------
TAPILabel = class(TGDIObject)
private
  FColor: COLORREF;
  FText: string;
  FTextAlign: UINT;
  FFont: TAPIGFont;  // この行を追加する
  FTextColor: COLORREF;
  FMargin: integer;
  FBkMode: integer;
  FDrawFrame: Boolean;
  FFrameColor: COLORREF;
  procedure SetColor(value: COLORREF);
  procedure SetText(value:string);
  procedure SetTextAlign(value:UINT);
  procedure SetTextColor(value:COLORREF);
  procedure SetMargin(value:integer);
  procedure SetBkMode(value:integer);
  procedure SetDrawFrame(value:Boolean);
  procedure SetFrameColor(value:COLORREF);
public
  constructor Create(hParent:HWND); override;
  destructor Destroy; override;                  // この行を追加する
  procedure DefaultHandler(var Message);override;
  property Color: COLORREF read FColor write SetColor;
  property Text: string read FText write SetText;
  property TextAlign: UINT read FTextAlign write SetTextAlign;
  property Font: TAPIGFont read FFont;          // この行を追加する
  property TextColor: COLORREF read FTextColor write SetTextColor;
  property Margin: integer read FMargin write SetMargin;
  property BkMode: integer read FBkMode write SetBkMode;
  property DrawFrame: Boolean read FDrawFrame write SetDrawFrame;
  property FrameColor: COLORREF read FFrameColor write SetFrameCOlor;
end;

//-------------  TClrMindBtn ----------------------------------------------
TColorKind = (crkWhite,crkRed,crkGreen,crkBlue,crkYellow);

TClrMindBtn = class(TAPISpeedBtn)
private
  FColorKind : TColorKind;
  procedure SetColorKind(value:TColorKind);
public
  constructor Create(hParent:HWND); override;
  procedure DefaultHandler(var Message);override;
  property Edge: UINT read FEdge;
  property ColorKind: TColorKind read FColorKind write SetColorKind;
end;

//---------- TAPISVScroll -------------------------------------------
TAPISVScroll = class(TSubClass)
private
  FOnChange: TNotifyMessage;
  FVorH: integer;
  FLargeChange: integer;
  FSmallChange: integer;
  FEnable: Boolean;
  FVisible: Boolean;
  function GetMin: integer;
  procedure SetMin(AMin: integer);
  function GetMax: integer;
  procedure SetMax(AMax: integer);
  function GetPos: integer;
  procedure SetPos(APos: integer);
  function GetThumbSize: integer;
  procedure SetThumbSize(ASize: integer);
  procedure SetEnable(value: Boolean);
  procedure SetVisible(value: Boolean);
protected
  procedure Initialize; virtual;
public
  constructor Create(hParent: HWND); override;
  procedure DefaultHandler(var Message); override;
  property Min: integer read GetMin write SetMin;
  property Max: integer read GetMax write SetMax;
  property Pos: integer read GetPos write SetPos;
  property LargeChange: integer read FLargeChange write FLargeChange;
  property SmallChange: integer read FSmallChange write FSmallChange;
  property ThumbSize: integer read GetThumbSize write SetThumbSize;
  property Enable: Boolean read FEnable write SetEnable;
  property Visible: Boolean read FVisible write SetVisible;
  property OnChange: TNotifyMessage read FOnChange write FOnChange;
end;

//---------- TAPISHScroll -------------------------------------------
TAPISHScroll = class(TAPISVScroll)
protected
  procedure Initialize; override;
end;


//
//--------------- Create Functions -------------------------------
//
function CreateSpeedBtn(hParent:HWND;x,y,cx,cy: integer;
           sCaption: string; sOnClick: TNotifyMessage): TAPISpeedBtn;
function CreateColorBtn(hParent:HWND;x,y,cx,cy: integer;
            sCaption: string; sOnClick: TNotifyMessage): TAPIColorBtn;
function CreateLabel(hParent:HWND;x,y,cx,cy: integer;
                                        sText: string): TAPILabel;



implementation

//------------------ TGDIObject ------------------------------
constructor TGDIObject.Create(hParent:HWND);
begin
  inherited Create(hParent);

  FVisible := true;
  FEnable := true;
  Dimension := SetDim(0,0,0,0);
end;

destructor TGDIObject.Destroy;
begin
  UpdateAll;
  inherited Destroy;
end;

procedure TGDIObject.Update;
var
  AMsg: TMessage;
begin
  AMsg.Msg := WM_PAINT;
  Dispatch(AMsg);
end;

procedure TGDIObject.UpdateAll;
begin
  InvalidateRect(Parent,@FRect,true);
end;

procedure TGDIObject.SetDimension(value:TRect);
begin
  FDimension := value;
  UpdateAll;
  FRect := value;
  FRect.Right := FDimension.Left+FDimension.Right; // right from width
  FRect.Bottom := FDimension.Top+FDimension.Bottom; // Bottom from height
  Update;
end;

procedure TGDIObject.SetVisible(value: Boolean);
begin
  FVisible := value;
  if value then Update else UpdateAll;
end;

procedure TGDIObject.SetEnable(value: Boolean);
begin
  FEnable := value;
  Update;
end;

//-------------------- TAPISpeedBtn -------------------------------------
constructor TAPISpeedBtn.Create(hParent:HWND);
begin
  FFont := TAPIGFont.Create; // この行を追加する
  inherited Create(hParent);
  Dispatcher.TrapMessage(WM_PAINT,self);
  Dispatcher.TrapMessage(WM_LBUTTONDOWN,self);
  Dispatcher.TrapMessage(WM_LBUTTONUP,self);
  Dispatcher.TrapMessage(WM_MOUSEMOVE,self);

  FEdge := EDGE_RAISED;
  FCaption := '';
  FDown := false;
end;

destructor TAPISpeedBtn.Destroy;
begin
  FFont.Free;
  inherited Destroy;
end;

procedure TAPISpeedBtn.DefaultHandler(var Message);
var
  AMsg:TMessage;
  DC:HDC;
  hBr: hBrush;
  dr: TRect;
  pt: TPoint;
begin
  if not FVisible then Exit;

  AMsg := TMessage(Message);

  case AMsg.Msg of

    WM_PAINT : begin
      DC := GetDC(Parent);
        hBr := CreateSolidBrush(clrBtnFace);
        FillRect(DC, FRect, hBr);
        DeleteObject(hBr);
        DrawEdge(DC, FRect, FEdge, BF_RECT);
        if Length(FCaption)>0 then begin
          if not Enable then SetTextColor(DC,clrGrayText);
          SetBkMode(DC,TRANSPARENT);
          dr := FRect;
          if FEdge = EDGE_RAISED then
            OffsetRect(dr,1,1)
          else
            OffsetRect(dr,-1,-1);
          FFont.SelectHandle(DC);     // この行を追加する
          DrawText(DC,PChar(FCaption),Length(FCaption),
                   dr,DT_CENTER or DT_SINGLELINE or DT_VCENTER);
          FFont.DeleteHandle(DC);     // この行を追加する
        end;
      ReleaseDC(Parent,DC);
    end;

    WM_LBUTTONDOWN: begin
      if not FEnable then Exit;
      pt.x := AMsg.LParamLo;
      pt.y := AMsg.LParamHi;
      if PtInRect(FRect,pt) then begin
        FEdge := EDGE_SUNKEN;
        FDown := true;
        UpDate;
      end;
    end;

    WM_LBUTTONUP: begin
      if not FEnable then Exit;
       if not FDown then Exit;
      pt.x := AMsg.LParamLo;
      pt.y := AMsg.LParamHi;
      if PtInRect(FRect,pt) then begin
        FEdge := EDGE_RAISED;
        FDown := false;
        UpDate;
        AMsg.Msg := UINT(self);  // sender
        if Assigned(FOnClick) then OnClick(AMsg);
      end;
    end;

    WM_MOUSEMOVE: begin
      if not FEnable then Exit;
      if not FDown then Exit;
      pt.x := AMsg.LParamLo;
      pt.y := AMsg.LParamHi;
      if not PtInRect(FRect,pt) then begin
        FEdge := EDGE_RAISED;
        FDown := false;
        UpDate;
      end;
    end;

  end; // case
end;

procedure TAPISpeedBtn.SetCaption(value:string);
begin
  FCaption := value;
  UpDate;
end;

//-------------  TAPIColorBtn ---------------------------------------------
constructor TAPIColorBtn.Create(hParent:HWND);
begin
  inherited Create(hParent);

  FColor := clrBtnFace;
  FTextColor := clrBlack;
end;

procedure TAPIColorBtn.DefaultHandler(var Message);
var
  DC:HDC;
  AMsg: TMessage;
  hBr: hBrush;
  dr: TRect;
  pt: TPoint;
begin
  if not FVisible then Exit;

  AMsg := TMessage(Message);

  case AMsg.Msg of

    WM_PAINT : begin
      DC := GetDC(Parent);
        if FEnable then
          hBr := CreateSolidBrush(FColor)
        else
          hBr := CreateSolidBrush(clrBtnFace);
        FillRect(DC, FRect, hBr);
        DeleteObject(hBr);
        DrawEdge(DC, FRect, FEdge, BF_RECT);
        if Length(FCaption)>0 then begin
          SetBkMode(DC,TRANSPARENT);
          if not Enable then
            Windows.SetTextColor(DC,clrGrayText)
          else
            Windows.SetTextColor(DC,FTextColor);
          dr := FRect;
          if FEdge = EDGE_RAISED then
            OffsetRect(dr,1,1)
          else
            OffsetRect(dr,-1,-1);
          DrawText(DC,PChar(FCaption),Length(FCaption),
                   dr,DT_CENTER or DT_SINGLELINE or DT_VCENTER);
        end;
      ReleaseDC(Parent,DC);
    end;

    WM_LBUTTONDOWN: begin
      if not FEnable then Exit;
      pt.x := AMsg.LParamLo;
      pt.y := AMsg.LParamHi;
      if PtInRect(FRect,pt) then begin
        FEdge := EDGE_SUNKEN;
        FDown := true;
        UpDate;
      end;
    end;

    WM_LBUTTONUP: begin
      if not FEnable then Exit;
       if not FDown then Exit;
      pt.x := AMsg.LParamLo;
      pt.y := AMsg.LParamHi;
      if PtInRect(FRect,pt) then begin
        FEdge := EDGE_RAISED;
        FDown := false;
        UpDate;
        AMsg.Msg := UINT(self);  // sender
        if Assigned(FOnClick) then OnClick(AMsg);
      end;
    end;

    WM_MOUSEMOVE: begin
      if not FEnable then Exit;
      if not FDown then Exit;
      pt.x := AMsg.LParamLo;
      pt.y := AMsg.LParamHi;
      if not PtInRect(FRect,pt) then begin
        FEdge := EDGE_RAISED;
        FDown := false;
        UpDate;
      end;
    end;

  end; // case
end;

procedure TAPIColorBtn.SetColor(value:COLORREF);
begin
  FColor := value;
  Update;
end;

procedure TAPIColorBtn.SetTextColor(value:COLORREF);
begin
  FTextColor := value;
  Update;
end;

//-------------  TAPILabel ---------------------------------------------
constructor TAPILabel.Create(hParent:HWND);
begin
  FFont := TAPIGFont.Create;  // この行を追加する
  inherited Create(hParent);
  Dispatcher.TrapMessage(WM_PAINT,self);

  FColor := clrWhite;
  FTextColor := clrBlack;
  FTextAlign := DT_LEFT;
  FText := ClassName;
  FMargin := 4;
  FBkMode := OPAQUE;
  FDrawFrame := false;
  FFrameColor := clrBlack;
  Update;
end;

destructor TAPILabel.Destroy;
begin
  FFont.Free;
  inherited Destroy;
end;

procedure TAPILabel.DefaultHandler(var Message);
var
  DC:HDC;
  AMsg: TMessage;
  hBr: hBrush;
  iR: TRect;
  uFlags: UINT;
begin
  if not FVisible then Exit;
  AMsg := TMessage(Message);
  if AMsg.Msg = WM_PAINT then begin
   DC := GetDC(Parent);
    if FBkMode = OPAQUE then begin
      hBr := CreateSolidBrush(FColor);
      FillRect(DC,FRect,hBr);
      DeleteObject(hBr);
    end;
    if FDrawFrame then begin
      hBr := CreateSolidBrush(FFrameColor);
      FrameRect(DC,FRect,hBr);
      DeleteObject(hBr);
    end;
    Windows.SetBkMode(DC,TRANSPARENT);
    FFont.SelectHandle(DC);           // この行を追加する
    iR := FRect;
    InflateRect(iR,-FMargin,-FMargin);
    uFlags := DT_WORDBREAK or DT_EXTERNALLEADING or
                DT_EXPANDTABS or FTextAlign;
    DrawText(DC,PChar(FText),Length(FText),iR,uFlags);
    FFont.DeleteHandle(DC);           // この行を追加する
   ReleaseDC(Parent,DC);
  end;
end;

procedure TAPILabel.SetColor(value: COLORREF);
begin
  FColor := value;
  Update;
end;

procedure TAPILabel.SetText(value:string);
begin
  FText := value;
  Update;
end;

procedure TAPILabel.SetTextAlign(value:UINT);
begin
  FTextAlign := value;
  Update;
end;

procedure TAPILabel.SetTextColor(value:COLORREF);
begin
  FTextColor := value;
  Update;
end;

procedure TAPILabel.SetMargin(value:integer);
begin
  FMargin := value;
  Update;
end;

procedure TAPILabel.SetBkMode(value:integer);
begin
  FBkMode := value;
  Update;
end;

procedure TAPILabel.SetDrawFrame(value:Boolean);
begin
  FDrawFrame := value;
  Update;
end;

procedure TAPILabel.SetFrameColor(value:COLORREF);
begin
  FFrameColor := value;
  Update;
end;

//-------------  TClrMindBtn ----------------------------------------------
constructor TClrMindBtn.Create(hParent:HWND);
begin
  inherited Create(hParent);

  ColorKind := crkRed;
end;

procedure TClrMindBtn.DefaultHandler(var Message);
var
  DC:HDC;
  hBr: hBrush;
  dr: TRect;
  AMsg:TMessage;
  clr: COLORREF;
  pt: TPoint;
begin
  if not FVisible then Exit;

  AMsg := TMessage(Message);

  case AMsg.Msg of

    WM_PAINT : begin
      DC := GetDC(Parent);
        if FEnable then
          hBr := CreateSolidBrush(GetSysColor(COLOR_BTNFACE))
        else
          hBr := CreateSolidBrush(clrDkGray);
        FillRect(DC, FRect, hBr);
        DeleteObject(hBr);
        DrawEdge(DC, FRect, FEdge, BF_RECT);
        dr := FRect;
        InflateRect(dr,-8,-8);
        clr:= clrWhite;
        if FEdge = EDGE_RAISED then begin
          OffsetRect(dr,-1,-1);
          case FColorKind of
            crkWhite: clr := clrDkGray;
            crkRed   : clr := clrMaroon;
            crkGreen : clr := clrGreen;
            crkBlue  : clr := clrBlue;
            crkYellow: clr := clrOlive;
          end;
        end else begin
          OffsetRect(dr,1,1);
          case FColorKind of
            crkWhite: clr := clrWhite;
            crkRed   : clr := RGB(255,50,50);
            crkGreen : clr := clrLime;
            crkBlue  : clr := clrAqua;
            crkYellow: clr := clrYellow;
          end;
        end;
        DrawEdge(DC,dr,EDGE_ETCHED,BF_RECT);
        InflateRect(dr,-4,-4);
        hBr := CreateSolidBrush(clr);
        FillRect(DC, dr, hBr);
        DeleteObject(hBr);
      ReleaseDC(Parent,DC);
    end;

    WM_LBUTTONDOWN: begin
      if not FEnable then Exit;
      pt.x := AMsg.LParamLo;
      pt.y := AMsg.LParamHi;
      if PtInRect(FRect,pt) then begin
        FEdge := EDGE_SUNKEN;
        MessageBeep($FFFFFFFF);
        FDown := true;
        UpDate;
      end;
    end;

    WM_LBUTTONUP: begin
      if not FEnable then Exit;
       if not FDown then Exit;
      pt.x := AMsg.LParamLo;
      pt.y := AMsg.LParamHi;
      if PtInRect(FRect,pt) then begin
        FEdge := EDGE_RAISED;
        FDown := false;
        UpDate;
        AMsg.Msg := UINT(self);  // sender
        if Assigned(FOnClick) then OnClick(AMsg);
      end;
    end;

    WM_MOUSEMOVE: begin
      if not FEnable then Exit;
      if not FDown then Exit;
      pt.x := AMsg.LParamLo;
      pt.y := AMsg.LParamHi;
      if not PtInRect(FRect,pt) then begin
        FEdge := EDGE_RAISED;
        FDown := false;
        UpDate;
      end;
    end;

    WM_USER: begin
      FEdge := EDGE_RAISED;
      Update;
    end;

    WM_USER+1: begin
      FEdge := EDGE_SUNKEN;
      Update;
    end;

  end; // case
end;

procedure TClrMindBtn.SetColorKind(value:TColorKind);
begin
  FColorKind := value;
  Update;
end;

//---------- TAPISVScroll -------------------------------------------
constructor TAPISVScroll.Create(hParent: HWND);
begin
  inherited Create(hParent);
  Initialize;
  if IsWindow(hParent) then
    if FVorH = SB_VERT then
      Dispatcher.TrapMessage(WM_VSCROLL,self)
    else
      Dispatcher.TrapMessage(WM_HSCROLL,self);
  FLargeChange := 10;
  FSmallChange := 1;
  FEnable := true;
  FVisible := true;
  ShowScrollBar(hParent,FVorH,true);
end;

procedure TAPISVScroll.Initialize;
begin
  FVorH := SB_VERT;
end;

procedure TAPISVScroll.DefaultHandler(var Message);
var
  AMsg: TMessage;
  Pos,FSC,FLC: integer;
begin
  AMsg := TMessage(message);
  if AMsg.LParam <> 0 then exit;
  FSC := FSmallChange;
  FLC := FLargeChange;
  case AMsg.Msg of
    WM_VSCROLL,WM_HSCROLL: begin
      Pos := GetScrollPos(Parent,FVorH);        ;
      case AMsg.WParamLo of
        SB_LINEDOWN: SetScrollPos(Parent,FVorH,Pos+FSC,true);
        SB_LINEUP: SetScrollPos(Parent,FVorH,Pos-FSC,true);
        SB_PAGEDOWN: SetScrollPos(Parent,FVorH,Pos+FLC,true);
        SB_PAGEUP: SetScrollPos(Parent,FVorH,Pos-FLC,true);
        SB_THUMBPOSITION,SB_THUMBTRACK:
              SetScrollPos(Parent,FVorH,AMsg.WParamHi,true);
      end;
      if Assigned(FOnChange) then begin
        AMsg.Msg := UINT(self); // Sender
        OnChange(AMsg);
      end;
    end;
  end;
end;
function TAPISVScroll.GetMin: integer;
var
  AMax: integer;
begin
  GetScrollRange(Parent,FVorH,result,AMax);
end;

procedure TAPISVScroll.SetMin(AMin: integer);
begin
  SetScrollRange(Parent,FVorH,AMin,Max,true);
end;

function TAPISVScroll.GetMax: integer;
var
  AMin: integer;
begin
  GetScrollRange(Parent,FVorH,AMin,result);
end;

procedure TAPISVScroll.SetMax(AMax: integer);
begin
  SetScrollRange(Parent,FVorH,Min,AMax,true);
end;

function TAPISVScroll.GetPos: integer;
begin
  result := GetScrollPos(Parent,FVorH);
end;

procedure TAPISVScroll.SetPos(APos: integer);
var
  AMsg: TMessage;
begin
  SetScrollPos(Parent,FVorH,APos,true);
  AMsg.Msg := WM_VSCROLL;
  AMsg.LParam := 0;
  AMsg.WParamLo := SB_ENDSCROLL;
  Dispatch(AMsg);
end;

function TAPISVScroll.GetThumbSize: integer;
var
  si: TScrollInfo;
begin
  si.cbSize := SizeOf(si);
  si.fMask:= SIF_PAGE;
  GetScrollInfo(Parent,FVorH,si);
  result := si.nPage;
end;

procedure TAPISVScroll.SetThumbSize(ASize: integer);
var
  si: TScrollInfo;
  AMsg: TMessage;
begin
  si.cbSize := SizeOf(si);
  si.fMask:= SIF_PAGE;
  si.nPage := ASize;
  SetScrollInfo(Parent,FVorH,si,true);
  AMsg.Msg := WM_VSCROLL;
  AMsg.LParam := 0;
  AMsg.WParamLo := SB_ENDSCROLL;
  Dispatch(AMsg);
end;

procedure TAPISVScroll.SetEnable(value: Boolean);
begin
  if value then
    EnableScrollBar(Parent,FVorH,ESB_ENABLE_BOTH)
  else
    EnableScrollBar(Parent,FVorH,ESB_DISABLE_BOTH);
  FEnable := value;
end;

procedure TAPISVScroll.SetVisible(value: Boolean);
begin
  if (FVisible <> value) then begin
    ShowScrollBar(Parent,FVorH,value);
    FVisible := value;
  end;
end;

//---------- TAPISHScroll -------------------------------------------
procedure TAPISHScroll.Initialize;
begin
  FVorH := SB_HORZ;
end;


//
//--------------- Create Functions -------------------------------
//
function CreateSpeedBtn(hParent:HWND;x,y,cx,cy: integer;
           sCaption: string; sOnClick: TNotifyMessage): TAPISpeedBtn;
begin
  result := TAPISpeedBtn.Create(hParent);
  with result do begin
    Dimension := SetDim(x,y,cx,cy);
    Caption := sCaption;
    OnClick := sOnClick;
  end;
end;

function CreateColorBtn(hParent:HWND;x,y,cx,cy: integer;
            sCaption: string; sOnClick: TNotifyMessage): TAPIColorBtn;
begin
  result := TAPIColorBtn.Create(hParent);
  with result do begin
    Dimension := SetDim(x,y,cx,cy);
    Caption := sCaption;
    OnClick := sOnClick;
  end;
end;

function CreateLabel(hParent:HWND;x,y,cx,cy: integer;
                                        sText: string): TAPILabel;
begin
  result := TAPILabel.Create(hParent);
  with result do begin
    Dimension := SetDim(x,y,cx,cy);
    Text := sText;
  end;
end;

end.
