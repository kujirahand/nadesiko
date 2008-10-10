{********************************************************************}
{                                                                    }
{    TEditorProp                                                     }
{                                                                    }
{    start  1999/07/10                                               }
{                                                                    }
{    update 2001/08/26                                               }
{                                                                    }
{    Copyright (c) 1999, 2001 ñ{ìcèüïF <katsuhiko.honda@nifty.ne.jp> }
{                                                                    }
{********************************************************************}

unit HEdtProp;

{$I heverdef.inc}

interface

uses
  Windows, Classes, Graphics, StdCtrls, Registry, heClasses, HEditor;

type
  TEditorProp = class(TFileExtComponent)
  private
    FColor: TColor;
    FCaret: TEditorCaret;
    FFont: TFont;
    FHitStyle: TEditorHitStyle;
    FImagebar: TEditorImagebar;
    FLeftbar: TEditorLeftbar;
    FMargin: TEditorMargin;
    FMarks: TEditorMarks;
    FReserveWordList: TStringList;
    FRuler: TEditorRuler;
    FScrollBars: TScrollStyle;
    FSpeed: TEditorSpeed;
    FView: TEditorViewInfo;
    FWordWrap: Boolean;
    FWrapOption: TEditorWrapOption;
    FOnColorChange: TNotifyEvent;
    FOnHitStyleChange: TNotifyEvent;
    FOnScrollBarsChange: TNotifyEvent;
    FOnWordWrapChange: TNotifyEvent;
    procedure SetCaret(Value: TEditorCaret);
    procedure SetColor(Value: TColor);
    procedure SetFont(Value: TFont);
    procedure SetHitStyle(Value: TEditorHitStyle);
    procedure SetImagebar(Value: TEditorImagebar);
    procedure SetLeftbar(Value: TEditorLeftbar);
    procedure SetMargin(Value: TEditorMargin);
    procedure SetMarks(Value: TEditorMarks);
    procedure SetScrollBars(Value: TScrollStyle);
    procedure SetSpeed(Value: TEditorSpeed);
    procedure SetReserveWordList(Value: TStringList);
    procedure SetRuler(Value: TEditorRuler);
    procedure SetWordWrap(Value: Boolean);
    procedure SetView(Value: TEditorViewInfo);
    procedure SetWrapOption(Value: TEditorWrapOption);
  protected
    function CreateEditorCaret: TEditorCaret; virtual;
    function CreateEditorImagebar: TEditorImagebar; virtual;
    function CreateEditorLeftbar: TEditorLeftbar; virtual;
    function CreateEditorMargin: TEditorMargin; virtual;
    function CreateEditorMarks: TEditorMarks; virtual;
    function CreateEditorRuler: TEditorRuler; virtual;
    function CreateEditorSpeed: TEditorSpeed; virtual;
    function CreateViewInfo: TEditorViewInfo; virtual;
    function CreateWrapOption: TEditorWrapOption; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AssignTo(Dest: TPersistent); override;
    property OnColorChange: TNotifyEvent read FOnColorChange write FOnColorChange;
    property OnHitStyleChange: TNotifyEvent read FOnHitStyleChange write FOnHitStyleChange;
    property OnScrollBarsChange: TNotifyEvent read FOnScrollBarsChange write FOnScrollBarsChange;
    property OnWordWrapChange: TNotifyEvent read FOnWordWrapChange write FOnWordWrapChange;
  published
    property Color: TColor read FColor write SetColor;
    property Caret: TEditorCaret read FCaret write SetCaret;
    property Font: TFont read FFont write SetFont;
    property HitStyle: TEditorHitStyle read FHitStyle write SetHitStyle;
    property Imagebar: TEditorImagebar read FImagebar write SetImagebar;
    property Leftbar: TEditorLeftbar read FLeftbar write SetLeftbar;
    property Margin: TEditorMargin read FMargin write SetMargin;
    property Marks: TEditorMarks read FMarks write SetMarks;
    property ReserveWordList: TStringList read FReserveWordList write SetReserveWordList;
    property Ruler: TEditorRuler read FRuler write SetRuler;
    property ScrollBars: TScrollStyle read FScrollBars write SetScrollBars;
    property Speed: TEditorSpeed read FSpeed write SetSpeed;
    property View: TEditorViewInfo read FView write SetView;
    property WordWrap: Boolean read FWordWrap write SetWordWrap;
    property WrapOption: TEditorWrapOption read FWrapOption write SetWrapOption;
  end;

implementation

// TEditorViewInfo.FComponent Ç…éËÇêLÇŒÇ∑ÇΩÇﬂÇÃå^êÈåæ
type
  TPropEditorViewInfo = class(TEditorViewInfo);


{ TEditorProp }

constructor TEditorProp.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCaret := CreateEditorCaret;
  FFont := TFont.Create;
  FImagebar := CreateEditorImagebar;
  FLeftbar := CreateEditorLeftbar;
  FMargin := CreateEditorMargin;
  FMarks := CreateEditorMarks;
  FReserveWordList := TStringList.Create;
  FReserveWordList.Sorted := True;
  FReserveWordList.Duplicates := dupIgnore;
  FRuler := CreateEditorRuler;
  FView := CreateViewInfo;
  FSpeed := CreateEditorSpeed;
  TPropEditorViewInfo(FView).FComponent := Self; // for PropertyEditor
  FWrapOption := CreateWrapOption;
  FColor := clWindow;
  Font.Color := clWindowText;
  Font.Name := 'FixedSys';
end;

destructor TEditorProp.Destroy;
begin
  FCaret.Free;
  FFont.Free;
  FImagebar.Free;
  FLeftbar.Free;
  FMargin.Free;
  FMarks.Free;
  FReserveWordList.Free;
  FRuler.Free;
  FView.Free;
  FSpeed.Free;
  FWrapOption.Free;
  inherited Destroy;
end;

function TEditorProp.CreateEditorCaret: TEditorCaret;
begin
  Result := TEditorCaret.Create;
end;

function TEditorProp.CreateEditorImagebar: TEditorImagebar;
begin
  Result := TEditorImagebar.Create;
end;

function TEditorProp.CreateEditorLeftbar: TEditorLeftbar;
begin
  Result := TEditorLeftbar.Create;
end;

function TEditorProp.CreateEditorMargin: TEditorMargin;
begin
  Result := TEditorMargin.Create;
end;

function TEditorProp.CreateEditorMarks: TEditorMarks;
begin
  Result := TEditorMarks.Create;
end;

function TEditorProp.CreateEditorRuler: TEditorRuler;
begin
  Result := TEditorRuler.Create;
end;

function TEditorProp.CreateEditorSpeed: TEditorSpeed;
begin
  Result := TEditorSpeed.Create;
end;

function TEditorProp.CreateViewInfo: TEditorViewInfo;
begin
  Result := TEditorViewInfo.Create;
end;

function TEditorProp.CreateWrapOption: TEditorWrapOption;
begin
  Result := TEditorWrapOption.Create;
end;

procedure TEditorProp.Assign(Source: TPersistent);
begin
  if Source is TEditor then
  begin
    try
      Color := TEditor(Source).Color;
      FCaret.Assign(TEditor(Source).Caret);
      FFont.Assign(TEditor(Source).Font);
      FHitStyle := TEditor(Source).HitStyle;
      FImagebar.Assign(TEditor(Source).Imagebar);
      FLeftbar.Assign(TEditor(Source).Leftbar);
      FMargin.Assign(TEditor(Source).Margin);
      FMarks.Assign(TEditor(Source).Marks);
      FReserveWordList.Assign(TEditor(Source).ReserveWordList);
      FRuler.Assign(TEditor(Source).Ruler);
      ScrollBars := TEditor(Source).ScrollBars;
      FSpeed.Assign(TEditor(Source).Speed);
      FView.Assign(TEditor(Source).View);
      WordWrap := TEditor(Source).WordWrap;
      FWrapOption.Assign(TEditor(Source).WrapOption);
    except
    end;
  end
  else
    if Source is TEditorProp then
    begin
      try
        Color := TEditorProp(Source).Color;
        FCaret.Assign(TEditorProp(Source).Caret);
        FFont.Assign(TEditorProp(Source).Font);
        FHitStyle := TEditorProp(Source).HitStyle;
        FImagebar.Assign(TEditorProp(Source).Imagebar);
        FLeftbar.Assign(TEditorProp(Source).Leftbar);
        FMargin.Assign(TEditorProp(Source).Margin);
        FMarks.Assign(TEditorProp(Source).Marks);
        FReserveWordList.Assign(TEditorProp(Source).ReserveWordList);
        FRuler.Assign(TEditorProp(Source).Ruler);
        ScrollBars := TEditorProp(Source).ScrollBars;
        FSpeed.Assign(TEditorProp(Source).Speed);
        FView.Assign(TEditorProp(Source).View);
        WordWrap := TEditorProp(Source).WordWrap;
        FWrapOption.Assign(TEditorProp(Source).WrapOption);
        FileExtList.Assign(TEditorProp(Source).FileExtList);
      except
      end;
    end
    else
      inherited Assign(Source);
end;

procedure TEditorProp.AssignTo(Dest: TPersistent);
begin
  if Dest is TEditor then
  begin
    try
      TEditor(Dest).Color := FColor;
      TEditor(Dest).Caret.Assign(FCaret);
      TEditor(Dest).Font.Assign(FFont);
      TEditor(Dest).HitStyle := HitStyle;
      TEditor(Dest).Imagebar.Assign(FImagebar);
      TEditor(Dest).Leftbar.Assign(FLeftbar);
      TEditor(Dest).Margin.Assign(FMargin);
      TEditor(Dest).Marks.Assign(FMarks);
      TEditor(Dest).ReserveWordList.Assign(FReserveWordList);
      TEditor(Dest).Ruler.Assign(FRuler);
      TEditor(Dest).ScrollBars := FScrollBars;
      TEditor(Dest).Speed.Assign(FSpeed);
      TEditor(Dest).View.Assign(FView);
      if FWordWrap then
      begin
        TEditor(Dest).WrapOption.Assign(FWrapOption);
        TEditor(Dest).WordWrap := FWordWrap;
      end
      else
      begin
        TEditor(Dest).WordWrap := FWordWrap;
        TEditor(Dest).WrapOption.Assign(FWrapOption);
      end;
    except
    end;
  end
  else
    if Dest is TEditorProp then
    begin
      try
        TEditorProp(Dest).Color := FColor;
        TEditorProp(Dest).Caret.Assign(FCaret);
        TEditorProp(Dest).Font.Assign(FFont);
        TEditorProp(Dest).HitStyle := HitStyle;
        TEditorProp(Dest).Imagebar.Assign(FImagebar);
        TEditorProp(Dest).Leftbar.Assign(FLeftbar);
        TEditorProp(Dest).Margin.Assign(FMargin);
        TEditorProp(Dest).Marks.Assign(FMarks);
        TEditorProp(Dest).ReserveWordList.Assign(FReserveWordList);
        TEditorProp(Dest).Ruler.Assign(FRuler);
        TEditorProp(Dest).ScrollBars := FScrollBars;
        TEditorProp(Dest).Speed.Assign(FSpeed);
        TEditorProp(Dest).View.Assign(FView);
        TEditorProp(Dest).WordWrap := FWordWrap;
        TEditorProp(Dest).WrapOption.Assign(FWrapOption);
        TEditorProp(Dest).FileExtList.Assign(FileExtList);
      except
      end;
    end
    else
      inherited AssignTo(Dest);
end;

procedure TEditorProp.SetCaret(Value: TEditorCaret);
begin
  FCaret.Assign(Value);
end;

procedure TEditorProp.SetColor(Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    if Assigned(FOnColorChange) then FOnColorChange(Self);
  end;
end;

procedure TEditorProp.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TEditorProp.SetHitStyle(Value: TEditorHitStyle);
begin
  if FHitStyle <> Value then
  begin
    FHitStyle := Value;
    if Assigned(FOnHitStyleChange) then FOnHitStyleChange(Self);
  end;
end;

procedure TEditorProp.SetImagebar(Value: TEditorImagebar);
begin
  FImagebar.Assign(Value);
end;

procedure TEditorProp.SetLeftbar(Value: TEditorLeftbar);
begin
  FLeftbar.Assign(Value);
end;

procedure TEditorProp.SetMargin(Value: TEditorMargin);
begin
  FMargin.Assign(Value);
end;

procedure TEditorProp.SetMarks(Value: TEditorMarks);
begin
  FMarks.Assign(Value);
end;

procedure TEditorProp.SetScrollBars(Value: TScrollStyle);
begin
  if FScrollBars <> Value then
  begin
    FScrollBars := Value;
    if Assigned(FOnScrollBarsChange) then FOnScrollBarsChange(Self);
  end;
end;

procedure TEditorProp.SetSpeed(Value: TEditorSpeed);
begin
  FSpeed.Assign(Value);
end;

procedure TEditorProp.SetReserveWordList(Value: TStringList);
begin
  FReserveWordList.Assign(Value);
end;

procedure TEditorProp.SetRuler(Value: TEditorRuler);
begin
  FRuler.Assign(Value);
end;

procedure TEditorProp.SetView(Value: TEditorViewInfo);
begin
  FView.Assign(Value);
end;

procedure TEditorProp.SetWordWrap(Value: Boolean);
begin
  if FWordWrap <> Value then
  begin
    FWordWrap := Value;
    if Assigned(FOnWordWrapChange) then FOnWordWrapChange(Self);
  end;
end;

procedure TEditorProp.SetWrapOption(Value: TEditorWrapOption);
begin
  FWrapOption.Assign(Value);
end;

end.

