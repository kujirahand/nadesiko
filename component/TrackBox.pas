unit TrackBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;


const
  H_Size = 5;
  H_Cent = 2;

type
  //�^�錾
  TTrackInf = record
  Left,Top,Width,Height: Integer;
  end;
  TTrNotifyEvent = procedure (Sender: Tobject; SZf: Boolean) of object;
  TTrackBox = class(TPaintBox)

  private
    { Private �錾 }
    //�v���p�e�B
    FTrColor: TColor;
    //FTrVisible: Boolean;
    FTrLine: Boolean;
    FTrSize: Boolean;
    FTrPos: TTrackInf;
    FTrAdjustRD: Boolean;
    FTrStyle: Integer;
    //�C�x���g
    FOnTrackChange: TTrNotifyEvent;
    //����
    H_Num: Integer;
    TPhase: Integer;
    X_off,Y_off: Integer;
    //�v���p�e�B���[�`��
    procedure SetTrColor(cl: TColor);
    procedure SetTrLine(f: Boolean);
    procedure SetTrSize(f: Boolean);
    //ReadOnly�͂����Łi�������ԈႦ�Ȃ��悤�ɁD�D�D�j
    function GetTrackPos: TTrackInf;

    procedure DrawTrack;

  protected
    { Protected �錾 }
    //�C�x���g
    procedure TrackChange(Sender: TObject; SZf: Boolean);

  public
    { Public �錾 }
    //�I�[�o�[���C�h
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton;
      Shift: TShiftState; X,Y: Integer); override;
    procedure MouseUp(Button: TMouseButton;
      Shift: TShiftState; X,Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X,Y: Integer); override;
    procedure SetTrackPos (Val: TTrackInf);

    //���s���v���p�e�B
    //property TrackPos : TTrackInf read GetTrackPos write SetTrackPos;
    property TrackPos : TTrackInf read GetTrackPos;

  published
    { Published �錾 }
    //�v���p�e�B
    property TrackColor : TColor read FTrColor write SetTrColor;
    //property TrackVisible : Boolean read FTrVisible write SetTrVisible;
    property TrackLineVisible : Boolean read FTrLine write SetTrLine;
    property TrackSizeEnable : Boolean read FTrSize write SetTrSize;
    property TrackAdjustRD : Boolean read FTrAdjustRD write FTrAdjustRD;
    property TrackStyle : Integer read FTrStyle write FTrStyle;

    //�C�x���g
    property OnTrackChange :TTrNotifyEvent read FOnTrackChange write FOnTrackChange;

  end;


procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TTrackBox]);
end;

//**********
//�v���p�e�B
//**********

//Color�v���p�e�B
procedure TTrackBox.SetTrColor(cl: TColor);
begin
  if FTrColor <> cl then
    begin
    FTrColor := cl;
    Color := cl;
    DrawTrack;
    end;
end;

//Visible�v���p�e�B
//procedure TTrackBox.SetTrVisible(f: Boolean);
//begin
//  if FTrVisible <> f then
//    begin
//    FTrVisible := f;
//    DrawTrack;
//    end;
//end;

//Line�v���p�e�B
procedure TTrackBox.SetTrLine(f: Boolean);
begin
  if FTrLine <> f then
    begin
    FTrLine := f;
    DrawTrack;
    end;
end;

//Size�v���p�e�B
procedure TTrackBox.SetTrSize(f: Boolean);
begin
  if FTrSize <> f then
    begin
    FTrSize := f;
    end;
end;

//Trackposition�v���p�e�B�iRead�j
function TTrackBox.GetTrackPos: TTrackInf;
begin
  if FTrStyle = 1 then
  begin
    Result.Left   := Left   ;
    Result.Top    := Top    ;
    Result.Width  := Width  ;
    Result.Height := Height ;
  end else begin
    Result.Left   := Left+2 ;
    Result.Top    := Top +2 ;
    Result.Width  := Width -4 ;
    Result.Height := Height-4 ;
  end;
end;

//Trackposition�v���p�e�B�iWrite�j
procedure TTrackBox.SetTrackPos(Val: TTrackInf);
begin
//  if FTrPos <> Val then
//    begin
    FTrPos.Left := Val.Left;
    FTrPos.Top  := Val.Top;
    FTrPos.Width := Val.Width;
    FTrPos.Height := Val.Height;
  if FTrStyle = 1 then
  begin
    Left := FTrpos.Left;
    Top  := FTrpos.Top;
    Width := FTrpos.Width;
    Height := FTrpos.Height;
  end else begin
    Left := FTrpos.Left -2;
    Top  := FTrpos.Top -2;
    Width := FTrpos.Width + 4;
    Height := FTrpos.Height +4;
  end;
//    end;
end;

//*********
//�C�x���g
//*********
procedure TTrackBox.TrackChange(Sender: TObject; SZf: Boolean);
begin
  if FTrStyle = 1 then
  begin
    FTrPos.Left := Left;
    FTrPos.Top  := Top;
    FTrPos.Width := Width;
    FTrPos.Height := Height;
  end else begin
    FTrPos.Left := Left +2;
    FTrPos.Top  := Top +2;
    FTrPos.Width := Width -4;
    FTrPos.Height := Height -4;
  end;
  if Assigned(FOnTrackChange) then FOnTrackChange(Self,SZf);
end;
//TrackChange(self,true)�ŌĂяo��

//*********
//��ʏ���
//*********

//���Ƃ�
constructor TTrackBox.Create(AOwner: TComponent);
begin
  inherited Create (AOwner);
  TPhase := 0;
  H_num := 8;
  X_off :=0; Y_off :=0;
  FTrColor := Color;
  FTrColor := clBlack;
  //FTrVisible := True;
  FTrLine  := True;
  FTrSize  := True;
  FTrStyle := 0;
  FTrAdjustRD := True;
  FTrPos.Left := Left +2;
  FTrPos.Top  := Top +2;
  FTrPos.Width := Width -4;
  FTrPos.Height := Height -4;
end;

//Paint��
procedure TTrackBox.Paint;
begin
  inherited Paint;
  DrawTrack;
end;

//�}�E�X�_�E��
procedure TTrackBox.MouseDown(Button: TMouseButton;
      Shift: TShiftState; X,Y: Integer);
var
  w,h: integer;
begin
  inherited MouseDown(Button,Shift,X,Y);
  w := Width;
  h := Height;
  //H_num := 8;
  X_off := X; Y_off := Y;
      if ((FTrStyle = 0) or (FTrStyle = 1)) and (
       ((X >= 0) and (X <= H_Size) and (Y >= 0) and (Y <= H_size)) or
       ((X >= (w-H_Size)div 2) and (X <= (w-H_Size)div 2 +H_Size) and (Y >= 0) and (Y <= H_Size)) or
       ((X >= w-H_Size) and (X <= w) and (Y >= 0) and (Y <= H_size)) or
       ((X >= w-H_Size) and (X <= w) and (Y >= (h-H_Size)div 2) and (Y <= (h-H_Size)div 2+H_Size)) or
       ((X >= w-H_Size) and (X <= w) and (Y >= h-H_Size) and (Y <= h)) or
       ((X >= (w-H_Size)div 2) and (X <= (w-H_Size)div 2 +H_Size) and (Y >= h-H_Size) and (Y <= h)) or
       ((X >= 0) and (X <= H_Size) and (Y >= h-H_Size) and (Y <= h)) or
       ((X >= 0) and (X <= H_Size) and (Y >= (h-H_Size)div 2) and (Y <= (h-H_Size)div 2+H_Size))) then
    //if (H_num < 8) then
       TPhase := 1
    else
       TPhase := 2;
end;

//�}�E�X�A�b�v
procedure TTrackBox.MouseUp(Button: TMouseButton;
      Shift: TShiftState; X,Y: Integer);
begin
  inherited MouseUp(Button,Shift,X,Y);
  TPhase := 0;
  H_num := 8;
end;

//�}�E�X���[�u
procedure TTrackBox.MouseMove(Shift: TShiftState; X,Y: Integer);
var
  w,h: integer;
  i: integer;
begin
  inherited MouseMove(Shift,X,Y);

  w := Width;
  h := Height;
  i := 1;
  //****************
  //�J�[�\���ω�����
  //****************
  if (FTrSize = True) then
    begin
    //����
    if (X >= 0) and (X <= H_Size) and (Y >= 0) and (Y <= H_size) then
      begin
      H_num := 0; i := 0;
      Cursor := crSizeNWSE;
      end;
    //��
    if (X >= (w-H_Size)div 2) and (X <= (w-H_Size)div 2 +H_Size) and (Y >= 0) and (Y <= H_Size) then
      begin
      H_num := 1; i := 0;
      Cursor := crSizeNS;
      end;
    //�E��
    if (X >= w-H_Size) and (X <= w) and (Y >= 0) and (Y <= H_size) then
      begin
      H_num := 2; i := 0;
      Cursor := crSizeNESW;
      end;
    //�E
    if (X >= w-H_Size) and (X <= w) and (Y >= (h-H_Size)div 2) and (Y <= (h-H_Size)div 2+H_Size) then
      begin
      H_num := 3; i := 0;
      Cursor := crSizeWE;
      end;
    //�E��
    if (X >= w-H_Size) and (X <= w) and (Y >= h-H_Size) and (Y <= h) then
      begin
      H_num := 4; i := 0;
      Cursor := crSizeNWSE;
      end;
    //��
    if (X >= (w-H_Size)div 2) and (X <= (w-H_Size)div 2 +H_Size) and (Y >= h-H_Size) and (Y <= h) then
      begin
      H_num := 5; i := 0;
      Cursor := crSizeNS;
      end;
    //����
    if (X >= 0) and (X <= H_Size) and (Y >= h-H_Size) and (Y <= h) then
      begin
      H_num := 6; i := 0;
      Cursor := crSizeNESW;
      end;
    //��
    if (X >= 0) and (X <= H_Size) and (Y >= (h-H_Size)div 2) and (Y <= (h-H_Size)div 2+H_Size) then
      begin
      H_num := 7; i := 0;
      Cursor := crSizeWE;
      end;
   end;
  //�J�[�\����߂�(H_num�ł͎��X���܂������Ȃ��j
  if i = 1 then
    Cursor := crDefault;

  //************
  //����������
  //************
    if (TPhase = 2) then
      begin
        Top := Top +y - Y_off;
        Left:= Left + x - X_off;
        TrackChange(self,false);
        Exit;
      end;
  if (FTrSize = True) then
    begin
    //����
    if (TPhase = 1) and (H_num = 0) then
      begin
      if (x < w) then
       if (y < h) then
         begin
         Left  := Left + x;
         Top   := Top + y;
         Width := w -x;
         Height := h -y;
         TrackChange(self,true);
         end;
      end;
    //��
    if (TPhase = 1) and (H_num = 1) then
      begin
       if (y < h) then
         begin
         Top   := Top + y;
         Height := h -y;
         TrackChange(self,true);
         end;
      end;
    //�E��
    if (TPhase = 1) and (H_num = 2) then
      begin
      if (x+ w >0) then
       if (y < h) then
         begin
         Top   := Top + y;
         Width :=  x;
         Height := h -y;
         TrackChange(self,true);
         end;
      end;
    //�E
    if (TPhase = 1) and (H_num = 3) then
      begin
       if (y < h) then
         begin
         Width :=  x;
         TrackChange(self,true);
         end;
      end;
    //�E��
    if (TPhase = 1) and (H_num = 4) then
      begin
      if (x+ w >0) then
       if (y+h >0) then
         begin
         Width :=  x;
         Height := y;
         TrackChange(self,true);
         end;
      end;
    //��
    if (TPhase = 1) and (H_num = 5) then
      begin
       if (y+h >0) then
         begin
         Height := y;
         TrackChange(self,true);
         end;
      end;
    //����
    if (TPhase = 1) and (H_num = 6) then
      begin
      if (x < w) then
       if (y+h >0) then
         begin
         Left  := Left + x;
         Width := w -x;
         Height := y;
         TrackChange(self,true);
         end;
      end;
    //��
    if (TPhase = 1) and (H_num = 7) then
      begin
      if (x < w ) then
         begin
         Left  := Left + x;
         Width := w -x;
         TrackChange(self,true);
         end;
      end;
  end;
end;


//�g���b�N�{�b�N�X��`��(Sub)
procedure TTrackBox.DrawTrack;
var
  w,h :integer;
begin
  w := Width;
  h := Height;
  with Canvas do
    begin
    Pen.Color := FTrColor;
    //if (FTrVisible = true) then
    //  Pen.Mode  := pmCopy
    //else
    //  Pen.Mode  := pmNop;
    Pen.Mode  := pmCopy;
    Pen.width := 1;
    Brush.Color := FTrColor;
    Brush.Style := bsSolid;
    Rectangle(0,0,H_Size,H_Size);
    Rectangle((w-H_Size)div 2,0,(w-H_Size)div 2 +H_Size,H_Size);
    Rectangle(w-H_Size,0,w,H_Size);
    Rectangle(w-H_Size,(h-H_Size)div 2,w,(h-H_Size)div 2+H_Size);
    Rectangle(w-H_Size,h-H_Size,w,h);
    Rectangle((w-H_Size)div 2,h-H_Size,(w-H_Size)div 2 +H_Size,h);
    Rectangle(0,h-H_Size,H_Size,h);
    Rectangle(0,(h-H_Size)div 2,H_Size,(h-H_Size)div 2+H_Size);
    if (FTrLine = True) then
    begin
      if FTrStyle = 1 then
      begin
        if FTrAdjustRD then
        begin
          MoveTo(0,0);
          LineTo(w-1,0);
          LineTo(w-1,h-1);
          LineTo(0,h-1);
          LineTo(0,0);
        end else begin
          MoveTo(0,0);
          LineTo(w,0);
          LineTo(w,h);
          LineTo(0,h);
          LineTo(0,0);
        end;
      end else begin
        if FTrAdjustRD then
        begin
          MoveTo(H_Cent,H_Cent);
          LineTo(w-H_Cent-1,H_Cent);
          LineTo(w-H_Cent-1,h-H_Cent-1);
          LineTo(H_Cent,h-H_Cent-1);
          LineTo(H_Cent,H_Cent);
        end else begin
          MoveTo(H_Cent,H_Cent);
          LineTo(w-H_Cent,H_Cent);
          LineTo(w-H_Cent,h-H_Cent);
          LineTo(H_Cent,h-H_Cent);
          LineTo(H_Cent,H_Cent);
        end;
      end;
    end;
  end;
  BringToFront;
end;

end.
