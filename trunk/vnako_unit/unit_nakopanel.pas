unit unit_nakopanel;

interface

uses
  Classes, Forms, StdCtrls, ExtCtrls, Graphics, Controls, Messages;

type
  TNakoImage = class(ExtCtrls.TImage)
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

  TNakoPanel = class(TPanel)
  private
    FColor: TColor;
    FImage: TImage;
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
    procedure setColor(const Value: TColor);
    procedure doClick(Sender:TObject);
    procedure doDblClick(Sender:TObject);
    procedure doMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure doMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure doMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure doMouseEnter(Sender:TObject);
    procedure doMouseLeave(Sender:TObject);
    function getCanvas: TCanvas;
    function getText: string;
    procedure setText(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    procedure redrawBack;
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  protected
    procedure Resize; override;
  published
    property Color: TColor read FColor write setColor;
    property Canvas: TCanvas read getCanvas;
    property Image: TImage read FImage;
    property Text: string read getText write setText;
  end;

implementation

uses Windows;

 { TNakoImage }
procedure TNakoImage.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  //_TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TNakoImage.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TNakoImage.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{ TNakoPanel }

constructor TNakoPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  //
  FImage := TImage.Create(Self);
  FImage.Parent := Self;
  FColor := -1;
  FImage.Align := alNone;
  //
  FImage.Picture := nil;
  FImage.Width  := Self.Width;
  FImage.Height := Self.Height;
  FImage.OnClick := doClick;
  FImage.OnDblClick := doDblClick;
  FImage.OnMouseDown := doMouseDown;
  FImage.OnMouseMove := doMouseMove;
  FImage.OnMouseUp := doMouseUp;
  //FImage.OnMouseEnter:= doMouseEnter;
  //FImage.OnMouseLeave:= doMouseLeave;
end;

procedure TNakoPanel.doClick(Sender: TObject);
begin
  if Assigned(OnClick) then Self.OnClick(Self);
end;

procedure TNakoPanel.doDblClick(Sender: TObject);
begin
  if Assigned(OnDblClick) then OnDblClick(Self);
end;

procedure TNakoPanel.doMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(OnMouseDown) then OnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TNakoPanel.doMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Assigned(OnMouseMove) then OnMouseMove(Self, Shift, X, Y);
end;

procedure TNakoPanel.doMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(OnMouseUp) then OnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TNakoPanel.doMouseEnter(Sender: TObject);
begin
  if Assigned(OnMouseEnter) then OnMouseEnter(Self);
end;

procedure TNakoPanel.doMouseLeave(Sender: TObject);
begin
  if Assigned(OnMouseLeave) then OnMouseLeave(Self);
end;

function TNakoPanel.getCanvas: TCanvas;
begin
  Result := FImage.Canvas;
end;

function TNakoPanel.getText: string;
begin
  Result := Self.Caption;
end;

procedure TNakoPanel.redrawBack;
var
  s: string;
  w: Integer;
  h: Integer;
begin
  if FColor = -1 then Exit;
  with FImage do
  begin
    Canvas.Brush.Style  := bsSolid;
    Canvas.Brush.Color  := FColor;
    Canvas.Pen.Style    := psClear;
    Canvas.Rectangle(0,0,FImage.ClientWidth, FImage.ClientHeight);
    Canvas.Font := Self.Font;
    s := Self.Caption;
    w := Canvas.TextWidth(s);
    h := Canvas.TextHeight(s);
    // Text
    Canvas.TextOut(
      (Self.ClientWidth - w) div 2,
      (Self.ClientHeight - h) div 2,
      s
    );
    Paint;
  end;
end;

procedure TNakoPanel.Resize;
begin
  FImage.Picture := nil;
  FImage.Width  := Self.ClientWidth;
  FImage.Height := Self.ClientHeight;
  redrawBack;
  inherited;
end;

procedure TNakoPanel.setColor(const Value: TColor);
begin
  FColor := Value;
  redrawBack;
end;

procedure TNakoPanel.setText(const Value: string);
begin
  Self.Caption := Value;
  redrawBack;
end;

procedure TNakoPanel.CMMouseEnter(var Msg:TMessage);
var
  tme:TTrackMouseEvent;
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  tme.cbSize := sizeof(tme);
  tme.dwFlags := TME_HOVER;
  tme.hwndTrack := Handle;
  tme.dwHoverTime := FHoverTime;
  TrackMouseEvent(tme);
end;

procedure TNakoPanel.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TNakoPanel.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

end.
