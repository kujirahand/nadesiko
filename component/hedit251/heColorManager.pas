(*********************************************************************

  heColorManager.pas

  start  2001/04/21
  update 2001/04/23

  Copyright (c) 2001 本田勝彦 <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  HViewEdt.pas, FountainEditor.pas で利用される。
  背景色・前景色・フォントスタイル、LeftBracket, RightBracket を
  TColorGrid, TLabel, TCheckBox, TEdit, TButton で表現・編集する
  ためのクラス
**********************************************************************)

unit heColorManager;

{$I heverdef.inc}

interface

uses
  Classes, Controls, StdCtrls, ExtCtrls, Graphics, ColorGrd,
  heFountain, HEditor;
type
  TColorEditState = (csFountainColor, csEditorMark);

  TCustomColorManager = class(TObject)
  private
    FState: TColorEditState;
    FFountainColor: TFountainColor;
    FEditorMark: TEditorMark;
    FColorList: TList;
  protected
    procedure UpdateColorList; virtual;
    procedure GetColorList(const S: String); virtual;
    procedure SetEditorMark(Value: TEditorMark); virtual;
    procedure SetFountainColor(Value: TFountainColor); virtual;
    procedure SetState(Value: TColorEditState); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    property EditorMark: TEditorMark read FEditorMark write SetEditorMark;
    property FountainColor: TFountainColor read FFountainColor write SetFountainColor;
    property State: TColorEditState read FState write SetState;
  end;

  TEditorColorManager = class(TCustomColorManager)
  private
    FColorGrid: TColorGrid;
    FclNonePanel: TPanel;
    FBGLabel: TLabel;
    FFGLabel: TLabel;
    FBoldCheckBox: TCheckBox;
    FUnderlineCheckBox: TCheckBox;
    FItalicCheckBox: TCheckBox;
  protected
    procedure SetEditorMark(Value: TEditorMark); override;
    procedure SetFountainColor(Value: TFountainColor); override;
    procedure SetState(Value: TColorEditState); override;
    procedure CheckBoxClick(Sender: TObject);
    procedure PanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ColorGridMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); virtual;
  public
    constructor Create(
      ColorGrid: TColorGrid;
      clNonePanel: TPanel;
      BGLabel, FGLabel: TLabel;
      BoldCheckBox, UnderlineCheckBox, ItalicCheckBox: TCheckBox);
  end;

implementation


{ TCustomColorManager }

constructor TCustomColorManager.Create;
begin
  FColorList := TList.Create;
  UpdateColorList;
end;

destructor TCustomColorManager.Destroy;
begin
  FColorList.Free;
  inherited Destroy;
end;

procedure TCustomColorManager.UpdateColorList;
begin
  GetColorValues(GetColorList);
  FColorList.Exchange(7, 8); // exchange clSilver, clGray
  FColorList.Add(Pointer(clNone));
end;

procedure TCustomColorManager.GetColorList(const S: String);
begin
  if FColorList.Count < 16 then
    FColorList.Add(Pointer(StringToColor(S)));
end;

procedure TCustomColorManager.SetEditorMark(Value: TEditorMark);
begin
  FEditorMark := Value; // not Assign
end;

procedure TCustomColorManager.SetFountainColor(Value: TFountainColor);
begin
  FFountainColor := Value; // not Assign
end;

procedure TCustomColorManager.SetState(Value: TColorEditState);
begin
  FState := Value;
end;


{ TEditorColorManager }

constructor TEditorColorManager.Create(ColorGrid: TColorGrid;
  clNonePanel: TPanel; BGLabel, FGLabel: TLabel;
  BoldCheckBox, UnderlineCheckBox, ItalicCheckBox: TCheckBox);
begin
  inherited Create;
  FColorGrid := ColorGrid;
  FColorGrid.OnMouseUp := ColorGridMouseUp;
  FclNonePanel := clNonePanel;
  FclNonePanel.OnMouseUp := PanelMouseUp;
  FBGLabel := BGLabel;
  FBGLabel.OnMouseUp := PanelMouseUp;
  FFGLabel := FGLabel;
  FFGLabel.OnMouseUp := PanelMouseUp;
  // ３個のチェックボックスは nil を許容する仕様
  if BoldCheckBox <> nil then
  begin
    FBoldCheckBox := BoldCheckBox;
    FBoldCheckBox.OnClick := CheckBoxClick;
  end;
  if UnderlineCheckBox <> nil then
  begin
    FUnderlineCheckBox := UnderlineCheckBox;
    FUnderlineCheckBox.OnClick := CheckBoxClick;
  end;
  if ItalicCheckBox <> nil then
  begin
    FItalicCheckBox := ItalicCheckBox;
    FItalicCheckBox.OnClick := CheckBoxClick;
  end;
end;

procedure TEditorColorManager.SetState(Value: TColorEditState);
begin
  inherited SetState(Value);
  case FState of
    csFountainColor:
      begin
        FColorGrid.ForegroundEnabled := True;
        FColorGrid.BackgroundEnabled := True;
        if FBoldCheckBox <> nil then
          FBoldCheckBox.Enabled := True;
        if FUnderlineCheckBox <> nil then
          FUnderlineCheckBox.Enabled := True;
        if FItalicCheckBox <> nil then
          FItalicCheckBox.Enabled := True;
      end;
    csEditorMark:
      begin
        FColorGrid.ForegroundEnabled := True;
        FColorGrid.BackgroundEnabled := False;
        FBGLabel.Visible := False;
        if FBoldCheckBox <> nil then
        begin
          FBoldCheckBox.Checked := False;
          FBoldCheckBox.Enabled := False;
        end;
        if FUnderlineCheckBox <> nil then
        begin
          FUnderlineCheckBox.Checked := False;
          FUnderlineCheckBox.Enabled := False;
        end;
        if FItalicCheckBox <> nil then
        begin
          FItalicCheckBox.Checked := False;
          FItalicCheckBox.Enabled := False;
        end;
      end;
  end;
end;

procedure TEditorColorManager.SetFountainColor(Value: TFountainColor);
var
  B, C: Integer;
begin
  inherited SetFountainColor(Value);
  State := csFountainColor;
  if FFountainColor = nil then
  begin
    FColorGrid.BackgroundIndex := 16;
    FColorGrid.ForegroundIndex := 16;
    FColorGrid.Enabled := False;
    FBGLabel.Visible := False;
    FFGLabel.Visible := False;
    FclNonePanel.Enabled := False;
    if FBoldCheckBox <> nil then
    begin
      FBoldCheckBox.Checked := False;
      FBoldCheckBox.Enabled := False;
    end;
    if FUnderlineCheckBox <> nil then
    begin
      FUnderlineCheckBox.Checked := False;
      FUnderlineCheckBox.Enabled := False;
    end;
    if FItalicCheckBox <> nil then
    begin
      FItalicCheckBox.Checked := False;
      FItalicCheckBox.Enabled := False;
    end;
  end
  else
  begin
    B := FColorList.IndexOf(Pointer(FFountainColor.BkColor));
    C := FColorList.IndexOf(Pointer(FFountainColor.Color));
    FColorGrid.Enabled := True;
    FColorGrid.BackgroundIndex := B; // -1..16
    FColorGrid.ForegroundIndex := C; // -1..16
    FclNonePanel.Enabled := True;
    FBGLabel.Visible := (B < 0) or (B > 15);
    FFGLabel.Visible := (C < 0) or (C > 15);
    if FBoldCheckBox <> nil then
    begin
      FBoldCheckBox.Enabled := True;
      FBoldCheckBox.Checked := fsBold in FFountainColor.Style;
    end;
    if FUnderlineCheckBox <> nil then
    begin
      FUnderlineCheckBox.Enabled := True;
      FUnderlineCheckBox.Checked := fsUnderline in FFountainColor.Style;
    end;
    if FItalicCheckBox <> nil then
    begin
      FItalicCheckBox.Enabled := True;
      FItalicCheckBox.Checked := fsItalic in FFountainColor.Style;
    end;
  end;
end;

procedure TEditorColorManager.SetEditorMark(Value: TEditorMark);
var
  C: Integer;
begin
  inherited SetEditorMark(Value);
  State := csEditorMark;
  if FEditorMark = nil then
  begin
    FColorGrid.ForegroundIndex := 16;
    FColorGrid.Enabled := False;
    FFGLabel.Visible := False;
    FclNonePanel.Enabled := False;
  end
  else
  begin
    C := FColorList.IndexOf(Pointer(FEditorMark.Color));
    FColorGrid.ForegroundIndex := C; // -1..16
    FFGLabel.Visible := (C < 0) or (C > 15);
  end;
end;

procedure TEditorColorManager.CheckBoxClick(Sender: TObject);
var
  F: TFontStyle;
begin
  if (FState = csFountainColor) and (FFountainColor <> nil) and
     (Sender is TCheckBox) then
  begin
    if Sender = FBoldCheckBox then
      F := fsBold
    else
      if Sender = FUnderlineCheckBox then
        F := fsUnderline
      else
        if Sender = FItalicCheckBox then
          F := fsItalic
        else
          F := fsStrikeOut; // B:(
    with FFountainColor do
    begin
      if TCheckBox(Sender).Checked then
        Style := Style + [F]
      else
        Style := Style - [F];
    end;
  end;
end;

procedure TEditorColorManager.PanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  case FState of
    csFountainColor:
      if FFountainColor <> nil then
      begin
        case Button of
          mbLeft:  // FG
            begin
              FFGLabel.Visible := True;
              FColorGrid.ForegroundIndex := 16;
              FFountainColor.Color := clNone;
            end;
          mbRight: // BG
            begin
              FBGLabel.Visible := True;
              FColorGrid.BackgroundIndex := 16;
              FFountainColor.BkColor := clNone;
            end;
        end;
      end;
    csEditorMark:
      if (FEditorMark <> nil) and (Button = mbLeft) then
      begin
        FFGLabel.Visible := True;
        FColorGrid.ForegroundIndex := 16;
        FEditorMark.Color := clNone;
      end;
  end;
end;

procedure TEditorColorManager.ColorGridMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  case FState of
    csFountainColor:
      if FFountainColor <> nil then
      begin
        case Button of
          mbLeft:  // FG
            begin
              FFGLabel.Visible := False;
              FFountainColor.Color :=
                TColor(FColorList.Items[FColorGrid.ForegroundIndex]);
            end;
          mbRight: // BG
            begin
              FBGLabel.Visible := False;
              FFountainColor.BkColor :=
                TColor(FColorList.Items[FColorGrid.BackgroundIndex]);
            end;
        end;
      end;
    csEditorMark:
      if (FEditorMark <> nil) and (Button = mbLeft) then
      begin
        FFGLabel.Visible := False;
        FEditorMark.Color :=
          TColor(FColorList.Items[FColorGrid.ForegroundIndex]);
      end;
  end;
end;

end.

