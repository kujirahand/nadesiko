unit frmHukidasiU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, clipbrd, Menus;

type
  TfrmHukidasi = class(TForm)
    popMain: TPopupMenu;
    btnClose: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure timerCloseTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDeactivate(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private 宣言 }
    FDragPoint: TPoint;
    FBmp: TBitmap;
    FStr: string;
  protected
    // ドラッグしてフォームを移動する場合
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    { Public 宣言 }
    Res: Boolean;
    procedure SetText(font: TFont; s: string);
  end;

var
  frmHukidasi: TfrmHukidasi;

implementation

uses bmp_filter;

{$R *.dfm}

{ TfrmHukidasi }


{ TfrmHukidasi }

procedure TfrmHukidasi.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  FDragPoint := POINT(X, Y);
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TfrmHukidasi.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if GetKeyState(VK_LBUTTON) < 0 then
    SetBounds(Left + X - FDragPoint.x, Top + Y - FDragPoint.y, Width, Height);
end;

procedure TfrmHukidasi.SetText(font: TFont; s: string);
var
  slCount, ch, i, strx, stry, strw, strh, w: Integer;
  sl: TStringList;
begin
  FStr := s;
  FreeAndNil(FBmp);
  FBmp := TBitmap.Create;
  FBmp.Canvas.Font := font;
  // 幅と高さを求める
  strw := 0;
  sl := TStringList.Create;
  sl.Text := Trim(s) ;
  for i := 0 to sl.Count - 1 do
  begin
    w := FBmp.Canvas.TextWidth(sl.Strings[i]);
    if strw < w then strw := w;
  end;
  strw := strw + 8;
  ch := FBmp.Canvas.TextHeight('A');
  slCount := sl.Count;
  strh := ch * slCount + 8 + 9;

  FBmp.Width := Trunc(strw * 1.5);
  FBmp.Height := Trunc(strh * 1.5);
  FBmp.Canvas.Brush.Color := clInfoBk;
  FBmp.Canvas.Brush.Style := bsSolid;
  FBmp.Canvas.Pen.Color := clInfoBk;
  FBmp.Canvas.Pen.Style := psSolid;
  FBmp.Canvas.Pen.Width := 1;
  FBmp.Canvas.Rectangle(0,0,FBmp.Width,FBmp.Height);
  Self.Width := FBmp.Width;
  Self.Height := FBmp.Height;

  strx := (FBmp.Width - strw) div 2;
  stry := (FBmp.Height - strh) div 2;
  FBmp.Canvas.Brush.Style := bsClear;
  // 描画
  for i := 0 to sl.Count - 1 do
  begin
    FBmp.Canvas.TextOut(4+strx, 4+stry+i*ch, sl.Strings[i]);
  end;

  FBmp.Canvas.Font.Height := 9;
  FBmp.Canvas.Font.Color := clGray;
  FBmp.Canvas.Font.Style := [fsUnderline];
  FBmp.Canvas.TextOut((Self.Width - (4+strx)) div 2, 8+stry+sl.Count*ch, 'ok');
  
  sl.Free;
  SetRgnHukidasi(self);
  Self.Left := Self.Left - Self.Width;
  Self.Top := Self.Top - Self.Height;
end;

procedure TfrmHukidasi.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  inherited;
  BitBlt(Self.Canvas.Handle, 0, 0, ClientWidth, ClientHeight,
    FBmp.Canvas.Handle, 0, 0, SRCCOPY);
end;


procedure TfrmHukidasi.FormCreate(Sender: TObject);
begin
  FBmp := nil;
  Res := False;
end;

procedure TfrmHukidasi.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FBmp);
end;

procedure TfrmHukidasi.FormPaint(Sender: TObject);
begin
  BitBlt(Self.Canvas.Handle, 0, 0, ClientWidth, ClientHeight,
    FBmp.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TfrmHukidasi.FormDblClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmHukidasi.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmHukidasi.N2Click(Sender: TObject);
begin
  Clipboard.AsText := FStr;
  Beep;
end;

procedure TfrmHukidasi.timerCloseTimer(Sender: TObject);
begin
  Close;
end;

procedure TfrmHukidasi.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 13)or(Key = VK_ESCAPE) then Close;
end;

procedure TfrmHukidasi.FormDeactivate(Sender: TObject);
begin
  Close;
end;

procedure TfrmHukidasi.FormClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmHukidasi.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Res := True;
end;

end.
