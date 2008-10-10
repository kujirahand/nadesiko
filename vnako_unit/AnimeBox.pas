unit AnimeBox;
(*
説　明：パラパラアニメボタンコンポ
作成者：クジラ飛行机(http://kujirahand.com)

2001/11/28 ver.1.10
繰り返し回数の指定と、マウスが上に来たときにアニメするオプション(UseButton2)追加。

*)
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, MMSystem;

type
  TAnimeBox = class(TGraphicControl)
  private
    { Private declarations }
    list: TList; // Bitmap保持用
    animeTimer: TTimer; // Animeイベント用
    AnimeNo: Integer; // anime no : -1 なら、アニメーションしない。
    FInterval: Integer;
    FClickFlush: Boolean;
    MustFlush: Boolean;
    MustBorder: Boolean;
    FStretch: Boolean;
    FAutoStart: Boolean;
    FTRansparent: Boolean;
    FColor: TColor;
    FVisible: Boolean;
    FMouseButton: Boolean;
    FRepeatTime: Integer;
    FRepeatTimeMem: Integer;
    FWaveFile: string;
    procedure OnAnimeTimer(Sender: TObject);
    procedure SetInterval(const Value: Integer);
    procedure SetAutoStart(const Value: Boolean);
    procedure SetTransparent(const Value: Boolean);
    procedure DoTransparent;
    procedure SetColor(const Value: TColor);
    procedure SetVisible(const Value: Boolean);
    procedure SetMouseButton(const Value: Boolean);
    procedure SetRepeatTime(const Value: Integer);
    procedure DrawAnime;
  protected
    { Protected declarations }
    procedure Paint; override;
    procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
	  procedure WMLButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
  public
    { Public declarations }
    BackGround: TBitmap;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AddBitmap(bmp: TBitmap): Integer;
    function AddFromFile(FName: string): Integer;
    function AddFromFiles(FNames: string): Integer;
    procedure ClearImage;
    procedure Start;
    procedure Stop;
  published
    { Published declarations }
    property Visible: Boolean read FVisible write SetVisible;
    property Canvas;
    property OnClick;
    property OnDblClick;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnDragOver;
    property OnDragDrop;
    property Interval: Integer read FInterval write SetInterval;
    property UseButton: Boolean read FClickFlush write FClickFlush; //イメージをボタンとして扱うかどうか
    property UseButton2: Boolean read FMouseButton write SetMouseButton;
    property Stretch: Boolean read FStretch write FStretch;
    property AutoStart: Boolean read FAutoStart write SetAutoStart;
    property Transparent: Boolean read FTRansparent write SetTransparent;
    property Color: TColor read FColor write SetColor;
    property RepeatTime: Integer read FRepeatTime write SetRepeatTime;
    property WaveFile: string read FWaveFile write FWaveFile;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Mine', [TAnimeBox]);
end;

{ TAnimeBox }

function TAnimeBox.AddBitmap(bmp: TBitmap): Integer;
var
	p: TBitmap;
begin
	p := TBitmap.Create;
  p.Assign(bmp);
  if Width  < bmp.Width  then Width  := bmp.Width;
  if Height < bmp.Height then Height := bmp.Height;
	Result := list.Add(p);
  DoTransparent;
end;

function TAnimeBox.AddFromFile(FName: string): Integer;
var
	bmp: TBitmap;
begin
  bmp := TBitmap.Create ;
  bmp.LoadFromFile(FName);
  Result := list.Add(bmp);
  DoTransparent;
end;


function TAnimeBox.AddFromFiles(FNames: string): Integer;
var
  s: TStringList;
  i: Integer;
begin
  Result := -1;
  s := TStringList.Create;
  try
    s.Text := FNames;
    for i := 0 to s.Count - 1 do
    begin
      Result := AddFromFile(s.Strings[i]);
    end;
  finally
    s.Free;
  end;
end;

procedure TAnimeBox.ClearImage;
var
	i:Integer;
    p:TBitmap;
begin
	for i:=0 to list.Count -1 do
    begin
    	p := list.Items[i];
        if p<>nil then p.Free;
    end;
    list.Clear;
end;

procedure TAnimeBox.CMMouseEnter(var Msg: TMessage);
begin
    if not FVisible then Exit; // 可視がオンのときのみ

    try
        if FWaveFile <> '' then //効果音
        begin
            sndPlaySound(nil,SND_ASYNC); //一度止めてから。
            sndPlaySound(PChar(FWaveFile),SND_ASYNC or SND_LOOP) ;
        end;
    except
    end;

    if FMouseButton then
    begin
        FRepeatTime := FRepeatTimeMem;
        Start;
    end else
    begin
        MustBorder := True;
        Paint;
    end;
end;

procedure TAnimeBox.CMMouseLeave(var Msg: TMessage);
begin
    if FWaveFile <> '' then //効果音
        sndPlaySound(nil,SND_ASYNC);
    if FMouseButton then
    begin
        Stop;
    end else
    begin
        MustBorder := False;
        Paint;
    end;
end;

constructor TAnimeBox.Create(AOwner: TComponent);
begin
	inherited Create(AOwner);
    FVisible := True;
    Width := 100; Height := 100;
	FColor := clWhite;
    AnimeNo := -1;
	list := TList.Create;
    animeTimer := TTimer.Create(nil);
    animeTImer.Enabled := False;
    animeTimer.OnTimer := OnAnimeTimer;
    Interval := 300;
    FClickFlush := False;
    FTransparent := False;
    Background := TBitmap.Create ;
    FRepeatTime := -1;
    FWaveFile := '';
    ParentColor := True;
end;

destructor TAnimeBox.Destroy;
begin
    if FWaveFile <> '' then //効果音
        sndPlaySound(nil,SND_ASYNC); //一度止めてから。
    if Background <> nil then Background.Free ;
    animeTimer.Free;
  	ClearImage;
    list.Free;
	inherited Destroy;
end;

procedure TAnimeBox.DoTransparent;
var
	i: Integer;
    bmp: TBitmap;
begin
	for i:=0 to list.Count -1 do
    begin
		bmp := list.Items[i];
        //bmp.Mask( bmp.Canvas.Pixels[0,0] );
        bmp.TransparentColor := bmp.Canvas.Pixels[0,0];
        bmp.Transparent := FTransparent;
    end;
end;

procedure TAnimeBox.DrawAnime;
var
    bmp: TBitmap;
begin
    if FVisible = False then Exit;
    //背景を得る
    if FTransparent = True then
    begin
        if Background.Empty then
        begin
            Canvas.Pen.Style := psClear;
            Canvas.Brush.Style := bsSolid;
            Canvas.Brush.Color := FColor ;
            Canvas.Rectangle(0,0,Width,Height);
        end else
        begin
        	Canvas.StretchDraw(RECT(0,0,Width,Height), Background);
        end;
    end;


    if list.Count > 0 then
    begin
    	if AnimeNo >= 0 then
    		bmp := list.Items[AnimeNo]
        else
        	bmp := list.Items[0];
		if bmp = nil then Exit;
        if FStretch then
            Canvas.StretchDraw(Rect(0,0,Width,Height), bmp)
        else
            Canvas.Draw(0,0, bmp);
    end;
    if MustBorder and FClickFlush then
    begin
        with Canvas do
        begin
        	Pen.Mode := pmCopy;
			Pen.Width := (Width div 24)+1;

        	Pen.Color := clBtnShadow;
            MoveTo(0,Height);
			LineTo(Width,Height);
            LineTo(Width,0);

            Pen.Color := cl3DLight  ;
			LineTo(0,0);
        	LineTo(0,Height);

        end;
    end;
    if (MustFlush)and(FClickFlush or FMouseButton) then
    begin
        Canvas.Brush.Style := bsSolid ;
    	Canvas.Pen.Width := 1;
        Canvas.Pen.Mode := pmXor ;
        Canvas.Pen.Color := clWhite;
    	Canvas.Brush.Color := clWhite ;
        Canvas.Rectangle(0,0, Width, Height);
    end;
end;

procedure TAnimeBox.OnAnimeTimer(Sender: TObject);
begin
    AnimeTimer.Enabled := False;
    if (UseButton=False) or (MustFlush=False) then
    begin
		  Inc(AnimeNo);
    	if list.Count <= AnimeNo then
      begin
        if FMouseButton then
        begin
          if list.Count >= 1 then
            AnimeNo := 1
          else
            AnimeNo := 0;
        end else
          AnimeNo := 0;
        if FRepeatTime > 0 then
        begin
          Dec(FRepeatTime);
          if FRepeatTime <= 0 then
          begin
            Stop;
            Exit;
          end;
        end;
      end;
    end;
    Paint;

    AnimeTimer.Enabled := True;
end;

procedure TAnimeBox.Paint;
begin
  inherited Paint;
  if FVisible = False then Exit;
  DrawAnime;
end;

procedure TAnimeBox.SetAutoStart(const Value: Boolean);
begin
	if Value then
    	Start
    else
    	Stop;
    FMouseButton := Value;
end;

procedure TAnimeBox.SetColor(const Value: TColor);
begin
	FColor := Value;
    Invalidate ;
end;

procedure TAnimeBox.SetInterval(const value: Integer);
begin
    FInterval := value;
    if AnimeNo >=0 then
		animeTimer.Interval := value;
end;


procedure TAnimeBox.SetMouseButton(const Value: Boolean);
begin
    if Value=True then Stop;
    FMouseButton := Value;
end;

procedure TAnimeBox.SetRepeatTime(const Value: Integer);
begin
    FRepeatTime := Value;
    FRepeatTimeMem := FRepeatTime;
end;

procedure TAnimeBox.SetTransparent(const Value: Boolean);
begin
	  FTransparent := Value;
    //inherited Transparent := Value;
    DoTransparent;
    Paint;
end;

procedure TAnimeBox.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    if Value then
    begin
        if FMouseButton = False then Start;
    end else begin
        Stop;
    end;
    VisibleChanging;
    FVisible  := Value;
    Enabled   := Value;
    Perform(CM_VISIBLECHANGED, Ord(Value), 0);
    RequestAlign;
  end;
end;

procedure TAnimeBox.Start;
begin
	if list.Count > 1 then
  begin
    	AnimeNo := 0;
      animeTimer.Interval := FInterval;
      animeTimer.Enabled := True;
    	FAutoStart := True;
  end else
  begin
    Self.Invalidate ;
  end;
end;

procedure TAnimeBox.Stop;
begin
    if FWaveFile <> '' then //効果音
        sndPlaySound(nil,SND_ASYNC);//効果音を演奏していれば、止める。
	  animeNo := -1;
    animeTimer.Enabled := False;
    FAutoStart := False;
    Paint;
end;

procedure TAnimeBox.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
begin
    //背景を描画しない。
end;

procedure TAnimeBox.WMLButtonDown(var Msg: TWMLButtonDown);
begin
    MouseCapture := True;
	MustFlush := True;
    Paint;
    if Assigned(OnMouseDown) then
    	OnMouseDown(Self, mbLeft, KeysToShiftState(Msg.Keys), Msg.XPos, Msg.YPos);
    if Assigned(OnClick) then
    	OnClick(Self);
end;

procedure TAnimeBox.WMLButtonUp(var Msg: TWMLButtonUp);
begin
	MustFlush := False;
    Paint;
    MouseCapture := False;
    if Assigned(OnMouseUp) then
    	OnMouseUp(Self, mbLeft, KeysToShiftState(Msg.Keys), Msg.XPos, Msg.YPos);
end;


end.

