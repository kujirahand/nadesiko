
{*****************************************************************************}
{                                                                             }
{    Tnt Delphi Unicode Controls                                              }
{      http://www.tntware.com/delphicontrols/unicode/                         }
{        Version: 2.2.5                                                       }
{                                                                             }
{    Copyright (c) 2002-2006, Troy Wolbrink (troy.wolbrink@tntware.com)       }
{                                                                             }
{*****************************************************************************}

unit TntThemeMgr;

{$INCLUDE TntCompilers.inc}

//---------------------------------------------------------------------------------------------
// TTntThemeManager is a TThemeManager descendant that knows about Tnt Unicode controls.
//   Most of the code is a complete copy from the Mike Lischke's original with only a
//     few modifications to enabled Unicode support of Tnt controls.
//---------------------------------------------------------------------------------------------
// The initial developer of ThemeMgr.pas is:
//   Dipl. Ing. Mike Lischke (public@lischke-online.de, www.lischke-online.de).
//     http://www.delphi-gems.com/ThemeManager.php
//
// Portions created by Mike Lischke are
// (C) 2001-2002 Mike Lischke. All Rights Reserved.
//---------------------------------------------------------------------------------------------

interface

uses
  Windows, Sysutils, Messages, Classes, Controls, Graphics, Buttons, ComCtrls, ThemeMgr, ThemeSrv;

{TNT-WARN TThemeManager}
type
  TTntThemeManagerHelper = class(TComponent)
  private
    FTntThemeManager: TThemeManager{TNT-ALLOW TThemeManager};
    procedure GroupBox_WM_PAINT(Control: TControl; var Message : TMessage);
    procedure CheckListBox_CN_DRAWITEM(Control: TControl; var Message: TMessage);
    procedure Panel_NewPaint(Control: TControl; DC: HDC);
    procedure Panel_WM_PAINT(Control: TControl; var Message: TMessage);
    procedure Panel_WM_PRINTCLIENT(Control: TControl; var Message: TMessage);
    procedure ToolBar_WM_LBUTTONDOWN(Control: TControl; var Message: TMessage);
    procedure ToolBar_WM_LBUTTONUP(Control: TControl; var Message: TMessage);
    procedure ToolBar_WM_CANCELMODE(Control: TControl; var Message: TMessage);
    procedure BitBtn_CN_DRAWITEM(Control: TControl; var Message: TMessage);
    procedure SpeedButton_WM_PAINT(Control: TControl; var Message: TMessage);
  protected
    procedure DrawBitBtn(Control: TBitBtn{TNT-ALLOW TBitBtn}; var DrawItemStruct: TDrawItemStruct);
    procedure DrawButton(Control: TControl; Button: TThemedButton; DC: HDC; R: TRect; Focused: Boolean);
  public
    constructor Create(AOwner: TThemeManager{TNT-ALLOW TThemeManager}); reintroduce;
    function DoControlMessage(Control: TControl; var Message: TMessage): Boolean;
  end;

  TTntThemeManager = class(TThemeManager{TNT-ALLOW TThemeManager})
  private
    FThemeMgrHelper: TTntThemeManagerHelper;
  protected
    function DoControlMessage(Control: TControl; var Message: TMessage): Boolean; override;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

procedure Register;

implementation

uses
  TntClasses, TntControls, StdCtrls, TntStdCtrls, TntButtons, TntCheckLst, ExtCtrls,
  TntExtCtrls, TntGraphics, TntWindows;

procedure Register;
begin
  RegisterComponents('Tnt Additional', [TTntThemeManager]);
end;

var
  GlobalCheckWidth: Integer;
  GlobalCheckHeight: Integer;

procedure GetCheckSize;
begin
  with TBitmap.Create do
  try
    Handle := LoadBitmap(0, PAnsiChar(32759));
    GlobalCheckWidth := Width div 4;
    GlobalCheckHeight := Height div 3;
  finally
    Free;
  end;
end;

{ TTntThemeManagerHelper }

constructor TTntThemeManagerHelper.Create(AOwner: TThemeManager{TNT-ALLOW TThemeManager});
begin
  inherited Create(AOwner);
  FTntThemeManager := AOwner;
end;

function TTntThemeManagerHelper.DoControlMessage(Control: TControl; var Message: TMessage): Boolean;
begin
  Result := False;
  if ThemeServices.ThemesEnabled then begin
    case Message.Msg of
      WM_PAINT:
        if (Control is TTntCustomPanel) then begin
          Result := True;
          Panel_WM_PAINT(Control, Message);
        end else if (Control is TTntCustomGroupBox) then begin
          Result := True;
          GroupBox_WM_PAINT(Control, Message);
        end else if (Control is TTntSpeedButton) then begin
          Result := True;
          SpeedButton_WM_PAINT(Control, Message);
        end;
      CN_DRAWITEM:
        if (Control is TTntCheckListBox) then begin
          Result := True;
          CheckListBox_CN_DRAWITEM(Control, Message);
        end else if (Control is TTntBitBtn) then begin
          Result := True;
          BitBtn_CN_DRAWITEM(Control, Message);
        end;
      WM_PRINTCLIENT:
        if (Control is TTntCustomPanel) then begin
          Result := True;
          Panel_WM_PRINTCLIENT(Control, Message);
        end;
      WM_LBUTTONDOWN:
        if (Control is TToolBar{TNT-ALLOW TToolBar}) then
          ToolBar_WM_LBUTTONDOWN(Control, Message);
      WM_LBUTTONUP:
        if (Control is TToolBar{TNT-ALLOW TToolBar}) then
          ToolBar_WM_LBUTTONUP(Control, Message);
      WM_CANCELMODE:
        if (Control is TToolBar{TNT-ALLOW TToolBar}) then
          ToolBar_WM_CANCELMODE(Control, Message);
    end;
  end;
  if Result then
    Message.Msg := WM_NULL;
end;

// ------- Group Box --------

type
  // Used to access protected properties.
  TGroupBoxCast = class(TTntCustomGroupBox);

procedure TTntThemeManagerHelper.GroupBox_WM_PAINT(Control: TControl; var Message: TMessage);
var
  GroupBoxCast: TGroupBoxCast;

  procedure NewPaint(DC: HDC);
  var
    CaptionRect,
    OuterRect: TRect;
    Size: TSize;
    LastFont: HFONT;
    Box: TThemedButton;
    Details: TThemedElementDetails;
  begin
    with FTntThemeManager, GroupBoxCast  do
    begin
      LastFont := SelectObject(DC, Font.Handle);
      if Caption <> '' then
      begin
        SetTextColor(DC, Graphics.ColorToRGB(Font.Color));
        // Determine size and position of text rectangle.
        // This must be clipped out before painting the frame.
        GetTextExtentPoint32W(DC, PWideChar(Caption), Length(Caption), Size);
        CaptionRect := Rect(0, 0, Size.cx, Size.cy);
        if not UseRightToLeftAlignment then
          OffsetRect(CaptionRect, 8, 0)
        else
          OffsetRect(CaptionRect, Width - 8 - CaptionRect.Right, 0);
      end
      else
        CaptionRect := Rect(0, 0, 0, 0);

      OuterRect := ClientRect;
      OuterRect.Top := (CaptionRect.Bottom - CaptionRect.Top) div 2;
      with CaptionRect do
        ExcludeClipRect(DC, Left, Top, Right, Bottom);
      if Control.Enabled then
        Box := tbGroupBoxNormal
      else
        Box := tbGroupBoxDisabled;
      Details := ThemeServices.GetElementDetails(Box);
      ThemeServices.DrawElement(DC, Details, OuterRect);

      SelectClipRgn(DC, 0);
      if Caption <> '' then
        ThemeServices.DrawText{TNT-ALLOW DrawText}(DC, Details, Caption, CaptionRect, DT_LEFT, 0);
      SelectObject(DC, LastFont);
    end;
  end;

var
  PS: TPaintStruct;
begin
  GroupBoxCast := TGroupBoxCast(Control as TTntCustomGroupBox);
  BeginPaint(GroupBoxCast.Handle, PS);
  NewPaint(PS.hdc);
  GroupBoxCast.PaintControls(PS.hdc, nil);
  EndPaint(GroupBoxCast.Handle, PS);
  Message.Result := 0;
end;

// ------- Check List Box --------

type
  TCheckListBoxCast = class(TTntCheckListBox);

procedure TTntThemeManagerHelper.CheckListBox_CN_DRAWITEM(Control: TControl; var Message: TMessage);
var
  DrawState: TOwnerDrawState;
  ListBox: TCheckListBoxCast;

  procedure DrawCheck(R: TRect; AState: TCheckBoxState; Enabled: Boolean);
  var
    DrawRect: TRect;
    Button: TThemedButton;
    Details: TThemedElementDetails;
  begin
    DrawRect.Left := R.Left + (R.Right - R.Left - GlobalCheckWidth) div 2;
    DrawRect.Top := R.Top + (R.Bottom - R.Top - GlobalCheckWidth) div 2;
    DrawRect.Right := DrawRect.Left + GlobalCheckWidth;
    DrawRect.Bottom := DrawRect.Top + GlobalCheckHeight;
    case AState of
      cbChecked:
        if Enabled then
          Button := tbCheckBoxCheckedNormal
        else
          Button := tbCheckBoxCheckedDisabled;
      cbUnchecked:
        if Enabled then
          Button := tbCheckBoxUncheckedNormal
        else
          Button := tbCheckBoxUncheckedDisabled;
      else // cbGrayed
        if Enabled then
          Button := tbCheckBoxMixedNormal
        else
          Button := tbCheckBoxMixedDisabled;
    end;
    with FTntThemeManager do begin
      Details := ThemeServices.GetElementDetails(Button);
      ThemeServices.DrawElement(ListBox.Canvas.Handle, Details, DrawRect, @DrawRect);
    end;
  end;

  procedure NewDrawItem(Index: Integer; Rect: TRect; DrawState: TOwnerDrawState);
  var
    Flags: Integer;
    Data: WideString;
    R: TRect;
    ACheckWidth: Integer;
    Enable: Boolean;
  begin
    with ListBox do
    begin
      if Assigned(OnDrawItem) and (Style <> lbStandard)then
        OnDrawItem(ListBox, Index, Rect, DrawState)
      else
      begin
        ACheckWidth := GetCheckWidth;
        if Index < Items.Count then
        begin
          R := Rect;
          // Delphi 4 has neither an enabled state nor a header state for items.
          Enable := Enabled and ItemEnabled[Index];
          if not Header[Index] then
          begin
            if not UseRightToLeftAlignment then
            begin
              R.Right := Rect.Left;
              R.Left := R.Right - ACheckWidth;
            end
            else
            begin
              R.Left := Rect.Right;
              R.Right := R.Left + ACheckWidth;
            end;
            DrawCheck(R, State[Index], Enable);
          end
          else
          begin
            Canvas.Font.Color := HeaderColor;
            Canvas.Brush.Color := HeaderBackgroundColor;
          end;
          if not Enable then
            Canvas.Font.Color := clGrayText;
        end;
        Canvas.FillRect(Rect);
        if Index < Count then
        begin
          Flags := DrawTextBiDiModeFlags(DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
          if not UseRightToLeftAlignment then
            Inc(Rect.Left, 2)
          else
            Dec(Rect.Right, 2);
          Data := '';
          if (Style in [lbVirtual, lbVirtualOwnerDraw]) then
            Data := DoGetData(Index)
          else
            Data := Items[Index];

          Tnt_DrawTextW(Canvas.Handle, PWideChar(Data), Length(Data), Rect, Flags);
        end;
      end;
    end;
  end;

begin
  ListBox := TCheckListBoxCast(Control);
  if ListBox.Count > 0
  then begin
    with TWMDrawItem(Message).DrawItemStruct^, ListBox do
    begin
      if not Header[itemID] then
        if not UseRightToLeftAlignment then
          rcItem.Left := rcItem.Left + GetCheckWidth
        else
          rcItem.Right := rcItem.Right - GetCheckWidth;
      DrawState := TOwnerDrawState(LongRec(itemState).Lo);
      Canvas.Handle := hDC;
      Canvas.Font := Font;
      Canvas.Brush := Brush;
      if (Integer(itemID) >= 0) and (odSelected in DrawState) then
      begin
        Canvas.Brush.Color := clHighlight;
        Canvas.Font.Color := clHighlightText
      end;
      if Integer(itemID) >= 0 then
        NewDrawItem(itemID, rcItem, DrawState)
      else
        Canvas.FillRect(rcItem);
      if odFocused in DrawState then
        DrawFocusRect(hDC, rcItem);
      Canvas.Handle := 0;
    end;
  end;
end;

// ------- Panel --------

type
  // Used to access protected properties.
  TPanelCast = class(TTntCustomPanel);

procedure TTntThemeManagerHelper.Panel_NewPaint(Control: TControl; DC: HDC);
const
  Alignments: array[TAlignment] of Longint = (DT_LEFT, DT_RIGHT, DT_CENTER);
var
  TopColor, BottomColor: TColor;

  procedure AdjustColors(Bevel: TPanelBevel);
  begin
    TopColor := clBtnHighlight;
    if Bevel = bvLowered then
      TopColor := clBtnShadow;
    BottomColor := clBtnShadow;
    if Bevel = bvLowered then
      BottomColor := clBtnHighlight;
  end;

var
  Rect: TRect;
  FontHeight: Integer;
  Flags: Longint;
  Details: TThemedElementDetails;
  OldFont: HFONT;
begin
  with TPanelCast(Control as TTntCustomPanel) do
  begin
    Canvas.Handle := DC;
    try
      Canvas.Font := Font;
      Rect := GetClientRect;
      if BevelOuter <> bvNone then
      begin
        AdjustColors(BevelOuter);
        Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
      end;
      InflateRect(Rect, -BorderWidth, -BorderWidth);
      if BevelInner <> bvNone then
      begin
        AdjustColors(BevelInner);
        Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
      end;
      if ParentColor or ((Control.Parent <> nil) and (Control.Parent.Brush.Color = Color)) then
      begin
        if TWinControl(Control.Parent).DoubleBuffered then
          FTntThemeManager.PerformEraseBackground(Control, DC)
        else
        begin
          Details := ThemeServices.GetElementDetails(tbGroupBoxNormal);
          ThemeServices.DrawParentBackground(Handle, DC, @Details, False, @Rect);
        end
      end
      else
      begin
        Canvas.Brush.Style := bsSolid;
        Canvas.Brush.Color := Color;
        FillRect(DC, Rect, Canvas.Brush.Handle);
      end;
      FontHeight := WideCanvasTextHeight(Canvas, 'W');
      with Rect do
      begin
        Top := ((Bottom + Top) - FontHeight) div 2;
        Bottom := Top + FontHeight;
      end;
      Flags := DT_EXPANDTABS or DT_VCENTER or Alignments[Alignment];
      Flags := DrawTextBiDiModeFlags(Flags);
      OldFont := SelectObject(DC, Font.Handle);
      SetBKMode(DC, TRANSPARENT);
      SetTextColor(DC, ColorToRGB(Font.Color));
      Tnt_DrawTextW(DC, PWideChar(Caption), -1, Rect, Flags);
      SelectObject(DC, OldFont);
    finally
      Canvas.Handle := 0;
    end;
  end;
end;

procedure TTntThemeManagerHelper.Panel_WM_PAINT(Control: TControl; var Message: TMessage);
var
  DC: HDC;
  PS: TPaintStruct;
begin
  with TPanelCast(Control as TTntCustomPanel) do begin
    DC := BeginPaint(Handle, PS);
    Panel_NewPaint(Control, DC);
    PaintControls(DC, nil);
    EndPaint(Handle, PS);
    Message.Result := 0;
  end;
end;

procedure TTntThemeManagerHelper.Panel_WM_PRINTCLIENT(Control: TControl; var Message: TMessage);
var
  DC: HDC;
begin
  with TPanelCast(Control as TTntCustomPanel) do
  begin
    DC := TWMPrintClient(Message).DC;
    Panel_NewPaint(Control, DC);
    PaintControls(DC, nil);
    Message.Result := 0;
  end;
end;

//-----------------------------------------

function ClickedToolButton(ToolBar: TToolBar{TNT-ALLOW TToolBar}; var Message: TWMMouse): TToolButton{TNT-ALLOW TToolButton};
var
  Control: TControl;
begin
  Result := nil;
  Control := ToolBar.ControlAtPos(SmallPointToPoint(Message.Pos), False);
  if (Control <> nil) and (Control is TToolButton{TNT-ALLOW TToolButton}) and not Control.Dragging then
    Result := TToolButton{TNT-ALLOW TToolButton}(Control);
end;

var LastClickedButton: TToolButton{TNT-ALLOW TToolButton};

procedure TTntThemeManagerHelper.ToolBar_WM_LBUTTONDOWN(Control: TControl; var Message: TMessage);
begin
  LastClickedButton := ClickedToolButton(Control as TToolBar{TNT-ALLOW TToolBar}, TWMMouse(Message));
end;

procedure TTntThemeManagerHelper.ToolBar_WM_LBUTTONUP(Control: TControl; var Message: TMessage);
var
  ToolButton: TToolButton{TNT-ALLOW TToolButton};
begin
  ToolButton := ClickedToolButton(Control as TToolBar{TNT-ALLOW TToolBar}, TWMMouse(Message));
  if (ToolButton <> nil)
  and (ToolButton = LastClickedButton)
  and (not (csCaptureMouse in ToolButton.ControlStyle)) then begin
    SetCaptureControl(LastClickedButton); // TToolBar is depending on this
    PostMessage((Control as TToolBar{TNT-ALLOW TToolBar}).Handle, WM_CANCELMODE, 0, 0); // this is to clean it up
  end;
end;

procedure TTntThemeManagerHelper.ToolBar_WM_CANCELMODE(Control: TControl; var Message: TMessage);
begin
  if (GetCaptureControl = nil) 
  or (GetCaptureControl = LastClickedButton) then
    SetCaptureControl(nil);
  LastClickedButton := nil;
end;

//-----------------------------------------

procedure TTntThemeManagerHelper.DrawBitBtn(Control: TBitBtn{TNT-ALLOW TBitBtn}; var DrawItemStruct: TDrawItemStruct);
var
  Button: TThemedButton;
  R: TRect;
  Wnd: HWND;
  P: TPoint;
begin
  with DrawItemStruct do
  begin
    // For owner drawn buttons we will never get the ODS_HIGHLIGHT flag. This makes it necessary to
    // check ourselves if the button is "hot".
    GetCursorPos(P);
    Wnd := WindowFromPoint(P);
    if Wnd = TWinControl(Control).Handle then
      itemState := itemState or ODS_HOTLIGHT;
    R := rcItem;
    if not Control.Enabled then
      Button := tbPushButtonDisabled
    else
      if (itemState and ODS_SELECTED) <> 0 then
        Button := tbPushButtonPressed
      else
        if (itemState and ODS_HOTLIGHT) <> 0 then
          Button := tbPushButtonHot
        else
          // It seems ODS_DEFAULT is never set, so we have to check the control's properties.
          if Control.Default or ((itemState and ODS_FOCUS) <> 0) then
            Button := tbPushButtonDefaulted
          else
            Button := tbPushButtonNormal;

    DrawButton(Control, Button, hDC, R, itemState and ODS_FOCUS <> 0);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure CalcButtonLayout(Control: TControl; DC: HDC; const Client: TRect; const Offset: TPoint; var GlyphPos: TPoint;
  var TextBounds: TRect; BiDiFlags: Integer);
var
  Layout: TButtonLayout;
  Spacing: Integer;
  Margin: Integer;
  Caption: TWideCaption;
begin
  if Control is TTntBitBtn then
  begin
    Layout := TTntBitBtn(Control).Layout;
    Spacing := TTntBitBtn(Control).Spacing;
    Margin := TTntBitBtn(Control).Margin;
    Caption := TTntBitBtn(Control).Caption;
  end
  else if Control is TTntSpeedButton then
  begin
    Layout := TTntSpeedButton(Control).Layout;
    Spacing := TTntSpeedButton(Control).Spacing;
    Margin := TTntSpeedButton(Control).Margin;
    Caption := TTntSpeedButton(Control).Caption;
  end else
    raise Exception.Create('TNT Internal Error: Wrong button class in CalcButtonLayout.');

  TButtonGlyph_CalcButtonLayout(Control, DC, Client, Offset, Caption, Layout, Margin,
    Spacing, GlyphPos, TextBounds, BiDiFlags);
end;

type
  TSpeedButtonCast = class(TTntSpeedButton);
  TControlCast = class(TControl);

procedure TTntThemeManagerHelper.DrawButton(Control: TControl; Button: TThemedButton; DC: HDC; R: TRect; Focused: Boolean);
// Common paint routine for TTntBitBtn and TTntSpeedButton.
var
  TextBounds: TRect;
  LastFont: HFONT;
  Glyph: TBitmap;
  GlyphPos: TPoint;
  GlyphWidth: Integer;
  GlyphSourceX: Integer;
  GlyphMask: TBitmap;
  Offset: TPoint;
  ToolButton: TThemedToolBar;
  Details: TThemedElementDetails;
begin
  GlyphSourceX := 0;
  GlyphWidth := 0;
  ToolButton := ttbToolbarDontCare;
  if Control is TTntBitBtn then
  begin
    Glyph := TTntBitBtn(Control).Glyph;
    // Determine which image to use (if there is more than one in the glyph).
    with TTntBitBtn(Control), Glyph do
    begin
      if not Empty then
      begin
        GlyphWidth := Width div NumGlyphs;
        if not Enabled and (NumGlyphs > 1) then
          GlyphSourceX := GlyphWidth
        else
          if (Button = tbPushButtonPressed) and (NumGlyphs > 2) then
            GlyphSourceX := 2 * GlyphWidth;
      end;
    end;
  end
  else
  begin
    Assert(Control is TTntSpeedButton, 'TNT Internal Error: Wrong button type in TTntThemeManagerHelper.DrawButton');
    Glyph := TTntSpeedButton(Control).Glyph;
    with TSpeedButtonCast(Control) do
    begin
      // Determine which image to use (if there is more than one in the glyph).
      with Glyph do
        if not Empty then
        begin
          GlyphWidth := Width div NumGlyphs;
          if not Enabled and (NumGlyphs > 1) then
            GlyphSourceX := GlyphWidth
          else
            case FState of
              bsDown:
                if NumGlyphs > 2 then
                  GlyphSourceX := 2 * GlyphWidth;
              bsExclusive:
                if NumGlyphs > 3 then
                  GlyphSourceX := 3 * GlyphWidth;
            end;
        end;
      // If the speed button is flat then we use toolbutton images for drawing.
      if Flat then
      begin
        case Button of
          tbPushButtonDisabled:
            Toolbutton := ttbButtonDisabled;
          tbPushButtonPressed:
            Toolbutton := ttbButtonPressed;
          tbPushButtonHot:
            Toolbutton := ttbButtonHot;
          tbPushButtonNormal:
            Toolbutton := ttbButtonNormal;
        end;
      end;
    end;
  end;
  if ToolButton = ttbToolbarDontCare then
  begin
    Details := ThemeServices.GetElementDetails(Button);
    ThemeServices.DrawElement(DC, Details, R);
    R := ThemeServices.ContentRect(DC, Details, R);
  end
  else
  begin
    Details := ThemeServices.GetElementDetails(ToolButton);
    ThemeServices.DrawElement(DC, Details, R);
    R := ThemeServices.ContentRect(DC, Details, R);
  end;

  // The XP style does no longer indicate pressed buttons by moving the caption one pixel down and right.
  Offset := Point(0, 0);

  with TControlCast(Control) do
  begin
    LastFont := SelectObject(DC, Font.Handle);
    CalcButtonLayout(Control, DC, R, Offset, GlyphPos, TextBounds, DrawTextBidiModeFlags(0));
    // Note: Currently we cannot do text output via the themes services because the second flags parameter (which is
    // used for graying out strings) is ignored (bug in XP themes implementation?).
    // Hence we have to do it the "usual" way.
    if ToolButton = ttbButtonDisabled then
      SetTextColor(DC, ColorToRGB(clGrayText));
    SetBkMode(DC, TRANSPARENT);
    if Control is TTntBitBtn then begin
      with TTntBitBtn(Control) do
        Tnt_DrawTextW(DC, PWideChar(Caption), Length(Caption), TextBounds, DT_CENTER or DT_VCENTER)
    end else begin
      Assert(Control is TTntSpeedButton, 'TNT Internal Error: Wrong button type in TTntThemeManagerHelper.DrawButton');
      with TTntSpeedButton(Control) do
        Tnt_DrawTextW(DC, PWideChar(Caption), Length(Caption), TextBounds, DT_CENTER or DT_VCENTER)
    end;
    with Glyph do
      if not Empty then
      begin
        GlyphMask := TBitmap.Create;
        GlyphMask.Assign(Glyph);
        GlyphMask.Mask(Glyph.TransparentColor);
        TransparentStretchBlt(DC, GlyphPos.X, GlyphPos.Y, GlyphWidth, Height, Canvas.Handle, GlyphSourceX, 0,
          GlyphWidth, Height, GlyphMask.Canvas.Handle, GlyphSourceX, 0);
        GlyphMask.Free;
      end;
    SelectObject(DC, LastFont);
  end;

  if Focused then
  begin
    SetTextColor(DC, 0);
    DrawFocusRect(DC, R);
  end;
end;

procedure TTntThemeManagerHelper.BitBtn_CN_DRAWITEM(Control: TControl; var Message: TMessage);
var
  Details: TThemedElementDetails;
begin
  with FTntThemeManager, TWMDrawItem(Message) do
  begin
    // This message is sent for bit buttons (TTntBitBtn) when they must be drawn. Since a bit button is a normal
    // Windows button (but with custom draw enabled) it is handled here too.
    // TTntSpeedButton is a TGraphicControl descentant and handled separately.
    Details := ThemeServices.GetElementDetails(tbPushButtonNormal);
    ThemeServices.DrawParentBackground(TWinControl(Control).Handle, DrawItemStruct.hDC, @Details, True);
    DrawBitBtn(Control as TTntBitBtn, DrawItemStruct^);
  end;
end;

procedure TTntThemeManagerHelper.SpeedButton_WM_PAINT(Control: TControl; var Message: TMessage);
var
  Button: TThemedButton;
  P: TPoint;
begin
  with FTntThemeManager, TWMPaint(Message) do
  begin
    // We cannot use the theme parent paint for the background of general speed buttons (because they are not
    // window controls).
    PerformEraseBackground(Control, DC);

    // Speed buttons are not window controls and are painted by a call of their parent with a given DC.
    if not Control.Enabled then
      Button := tbPushButtonDisabled
    else
      if TSpeedButtonCast(Control).FState in [bsDown, bsExclusive] then
        Button := tbPushButtonPressed
      else
      with TSpeedButtonCast(Control) do
      begin
        // Check the hot style here. If the button has a flat style then this check is easy. Otherwise
        // some more work is necessary.
        Button := tbPushButtonNormal;
        if Flat then
        begin
          if MouseInControl then
            Button := tbPushButtonHot;
        end
        else
        begin
          GetCursorPos(P);
          if FindDragTarget(P, True) = Control then
            Button := tbPushButtonHot;
        end;
      end;
    DrawButton(Control, Button, DC, Control.ClientRect, False);
    Message.Result := 0;
  end;
end;

{ TTntThemeManager }

constructor TTntThemeManager.Create(AOwner: TComponent);
begin
  inherited;
  FThemeMgrHelper := TTntThemeManagerHelper.Create(Self);
end;

procedure TTntThemeManager.Loaded;
begin
  if  (not (csDesigning in ComponentState))
  and (not ThemeServices.ThemesAvailable) then begin
    Options := Options - [toResetMouseCapture];
    FixControls(nil);
  end;
  inherited;
end;

function TTntThemeManager.DoControlMessage(Control: TControl; var Message: TMessage): Boolean;
begin
  Result := FThemeMgrHelper.DoControlMessage(Control, Message);
end;

initialization
  GetCheckSize;

end.
