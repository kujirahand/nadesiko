unit unit_nakopanel;

interface

uses
  Classes, Forms, StdCtrls, ExtCtrls, Graphics, Controls;

type
  TNakoPanel = class(TPanel)
  private
    FColor: TColor;
    FImage: TImage;
    procedure setColor(const Value: TColor);
    procedure doClick(Sender:TObject);
    procedure doDblClick(Sender:TObject);
    procedure doMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure doMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure doMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function getCanvas: TCanvas;
    function getText: string;
    procedure setText(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    procedure redrawBack;
  protected
    procedure Resize; override;
  published
    property Color: TColor read FColor write setColor;
    property Canvas: TCanvas read getCanvas;
    property Image: TImage read FImage;
    property Text: string read getText write setText;
  end;

implementation

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

end.
