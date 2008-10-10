(*********************************************************************

  HPropert.pas

  start  1999/10/14
  update 2003/04/23

  Copyright (c) 1999, 2003 本田勝彦 <katsuhiko.honda@nifty.ne.jp>
  --------------------------------------------------------------------
  TEditor, TEditorProp, TFountain のためのプロパティエディタと
  コンポーネントエディタが記述されている。

**********************************************************************)

unit HPropert;

{$I heverdef.inc}

interface

uses
  Classes,

  {$IFDEF MSWINDOWS}
    VCLEditors, // for TCursorProperty
  {$ENDIF}

  {$IFDEF LINUX}
    ClxEditors, // for TCursorProperty
  {$ENDIF}

  {$IFDEF COMP6_UP}
    DesignIntf, DesignEditors,
    {ICustomPropertyListDrawing}
    Windows, Graphics, Types;
  {$ELSE}
    Dsgnintf;
  {$ENDIF}

type
  TEditorClassPropertyEditor = class(TClassProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
  end;

  TEditorBracketsPropertyEditor = class(TEditorClassPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  TEditorCaretPropertyEditor = class(TEditorClassPropertyEditor)
  public
    procedure Edit; override;
  end;

  {$IFDEF COMP6_UP}

  TEditorCursorsPropertyEditor = class(TCursorProperty, ICustomPropertyListDrawing)
  public
    function GetValue: string; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;

    { ICustomPropertyListDrawing }
    procedure ListMeasureHeight(const Value: string; ACanvas: TCanvas;
      var AHeight: Integer);
    procedure ListMeasureWidth(const Value: string; ACanvas: TCanvas;
      var AWidth: Integer);
    procedure ListDrawValue(const Value: string; ACanvas: TCanvas;
      const ARect: TRect; ASelected: Boolean); 
  end;

  {$ELSE}

  TEditorCursorsPropertyEditor = class(TCursorProperty)
  public
    function GetValue: string; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;

  {$ENDIF}
  
  TEditorColorsPropertyEditor = class(TEditorClassPropertyEditor)
  public
    procedure Edit; override;
  end;

  TEditorMarginPropertyEditor = class(TEditorClassPropertyEditor)
  public
    procedure Edit; override;
  end;

  TEditorMarksPropertyEditor = class(TEditorClassPropertyEditor)
  public
    procedure Edit; override;
  end;

  TEditorViewPropertyEditor = class(TEditorClassPropertyEditor)
  public
    procedure Edit; override;
  end;

  TEditorWrapOptionPropertyEditor = class(TEditorClassPropertyEditor)
  public
    procedure Edit; override;
  end;

  TEditorLeftbarPropertyEditor = class(TEditorClassPropertyEditor)
  public
    procedure Edit; override;
  end;

  TEditorRulerPropertyEditor = class(TEditorClassPropertyEditor)
  public
    procedure Edit; override;
  end;

  TFountainColorPropertyEditor = class(TEditorClassPropertyEditor)
  public
    procedure Edit; override;
  end;

  TFountainBracketPropertyEditor = class(TFountainColorPropertyEditor)
  public
    function GetAttributes: TPropertyAttributes; override;
  end;

  TEditorComponentEditor = class(TComponentEditor)
  public
    procedure Edit; override;
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): String; override;
    function GetVerbCount: Integer; override;
  end;

  TEditorPropComponentEditor = class(TEditorComponentEditor)
  public
    procedure Edit; override;
  end;

  TFountainComponentEditor = class(TEditorComponentEditor)
  public
    procedure Edit; override;
  end;

  TStringsPropertyEditor = class(TClassProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  TEditorEnumIntegerPropertyEditor = class(TIntegerProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
  end;

  TEditorTabSpaceCountPropertyEditor = class(TEditorEnumIntegerPropertyEditor)
  public
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  TEditorRulerGaugeRangePropertyEditor = class(TEditorEnumIntegerPropertyEditor)
  public
    procedure GetValues(Proc: TGetStrProc); override;
  end;


implementation

uses
  SysUtils, Controls, Forms, HEditor, HEdtProp, HViewEdt, HStrProp,
  heUtils, heFountain, FountainEditor, heStrConsts;

{ PropertyEditors }

type
  TPropEditorViewInfo = class(TEditorViewInfo);

{ TEditorClassPropertyEditor }

function TEditorClassPropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paSubProperties, paReadOnly];
end;


{ TEditorBracketsPropertyEditor }

procedure TEditorBracketsPropertyEditor.Edit;
var
  Parent, Component: TPersistent;
begin
  Parent := GetComponent(0);
  if Parent is TEditorViewInfo then
  begin
    Component := TPropEditorViewInfo(Parent).GetOwner;
    if (Component is TEditorProp) and
       EditEditorProp(TEditorProp(Component),
                      TEditorViewInfo(Parent).Brackets) then
      Designer.Modified
    else
      if (Component is TEditor) and
         EditEditor(TEditor(Component),
                    TEditorViewInfo(Parent).Brackets) then
        Designer.Modified;
  end;
end;

function TEditorBracketsPropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;


{ TEditorCaretPropertyEditor }

procedure TEditorCaretPropertyEditor.Edit;
var
  Component: TPersistent;
begin
  Component := GetComponent(0);
  if (Component is TEditor) and
     EditEditor(TEditor(Component), TEditor(Component).Caret) then
    Designer.Modified
  else
    if (Component is TEditorProp) and
       EditEditorProp(TEditorProp(Component),
                      TEditorProp(Component).Caret) then
      Designer.Modified;
end;


{ TEditorCursorsProperty }

function TEditorCursorsPropertyEditor.GetValue: string;
begin
  Result := HCursorToString(TCursor(GetOrdValue));
end;

procedure TEditorCursorsPropertyEditor.GetValues(Proc: TGetStrProc);
begin
  HGetCursorValues(Proc);
end;

procedure TEditorCursorsPropertyEditor.SetValue(const Value: string);
begin
  if AnsiCompareText(RightArrowCursorIdent, Value) = 0 then
    SetOrdValue(crRightArrow)
  else
    if AnsiCompareText(DragSelCopyCursorIdent, Value) = 0 then
      SetOrdValue(crDragSelCopy)
    else
      inherited SetValue(Value);
end;

{$IFDEF COMP6_UP}

{ ICustomPropertyListDrawing }

procedure TEditorCursorsPropertyEditor.ListMeasureHeight(const Value: string; ACanvas: TCanvas;
  var AHeight: Integer);
begin
  AHeight := Max(ACanvas.TextHeight('Wg'), GetSystemMetrics(SM_CYCURSOR) + 4);
end;
  
procedure TEditorCursorsPropertyEditor.ListMeasureWidth(const Value: string; ACanvas: TCanvas;
  var AWidth: Integer);
begin
  AWidth := AWidth + GetSystemMetrics(SM_CXCURSOR) + 4;
end;

procedure TEditorCursorsPropertyEditor.ListDrawValue(const Value: string; ACanvas: TCanvas;
  const ARect: TRect; ASelected: Boolean); 
var
  Right: Integer;
  CursorIndex: Integer;
  CursorHandle: THandle;
begin
  Right := ARect.Left + GetSystemMetrics(SM_CXCURSOR) + 4;
  with ACanvas do
  begin
    CursorIndex := HStringToCursor(Value);
    ACanvas.FillRect(ARect);
    CursorHandle := Screen.Cursors[CursorIndex];
    if CursorHandle <> 0 then
      DrawIconEx(ACanvas.Handle, ARect.Left + 2, ARect.Top + 2, CursorHandle,
        0, 0, 0, 0, DI_NORMAL or DI_DEFAULTSIZE);
    DefaultPropertyListDrawValue(Value, ACanvas, Rect(Right, ARect.Top,
      ARect.Right, ARect.Bottom), ASelected);
  end;
end;

{$ENDIF}


{ TEditorColorsPropertyEditor }

procedure TEditorColorsPropertyEditor.Edit;
var
  Parent, Component: TPersistent;
begin
  Parent := GetComponent(0);
  if Parent is TEditorViewInfo then
  begin
    Component := TPropEditorViewInfo(Parent).GetOwner;
    if (Component is TEditorProp) and
       EditEditorProp(TEditorProp(Component),
                      TEditorViewInfo(Parent).Colors) then
      Designer.Modified
    else
      if (Component is TEditor) and
         EditEditor(TEditor(Component),
                    TEditorViewInfo(Parent).Colors) then
        Designer.Modified;
  end;
end;


{ TEditorMarginPropertyEditor }

procedure TEditorMarginPropertyEditor.Edit;
var
  Component: TPersistent;
begin
  Component := GetComponent(0);
  if (Component is TEditor) and
     EditEditor(TEditor(Component), TEditor(Component).Margin) then
    Designer.Modified
  else
    if (Component is TEditorProp) and
       EditEditorProp(TEditorProp(Component),
                      TEditorProp(Component).Margin) then
      Designer.Modified;
end;


{ TEditorMarksPropertyEditor }

procedure TEditorMarksPropertyEditor.Edit;
var
  Component: TPersistent;
begin
  Component := GetComponent(0);
  if (Component is TEditor) and
     EditEditor(TEditor(Component), TEditor(Component).Marks) then
    Designer.Modified
  else
    if (Component is TEditorProp) and
       EditEditorProp(TEditorProp(Component),
                      TEditorProp(Component).Marks) then
      Designer.Modified;
end;


{ TEditorViewPropertyEditor }

procedure TEditorViewPropertyEditor.Edit;
var
  Component: TPersistent;
begin
  Component := GetComponent(0);
  if (Component is TEditor) and
     EditEditor(TEditor(Component), TEditor(Component).View) then
    Designer.Modified
  else
    if (Component is TEditorProp) and
       EditEditorProp(TEditorProp(Component),
                      TEditorProp(Component).View) then
      Designer.Modified;
end;


{ TEditorWrapOptionPropertyEditor }

procedure TEditorWrapOptionPropertyEditor.Edit;
var
  Component: TPersistent;
begin
  Component := GetComponent(0);
  if (Component is TEditor) and
     EditEditor(TEditor(Component), TEditor(Component).WrapOption) then
    Designer.Modified
  else
    if (Component is TEditorProp) and
       EditEditorProp(TEditorProp(Component),
                      TEditorProp(Component).WrapOption) then
      Designer.Modified;
end;


{ TEditorLeftbarPropertyEditor }

procedure TEditorLeftbarPropertyEditor.Edit;
var
  Component: TPersistent;
begin
  Component := GetComponent(0);
  if (Component is TEditor) and
     EditEditor(TEditor(Component), TEditor(Component).Leftbar) then
    Designer.Modified
  else
    if (Component is TEditorProp) and
       EditEditorProp(TEditorProp(Component),
                      TEditorProp(Component).Leftbar) then
      Designer.Modified;
end;


{ TEditorRulerPropertyEditor }

procedure TEditorRulerPropertyEditor.Edit;
var
  Component: TPersistent;
begin
  Component := GetComponent(0);
  if (Component is TEditor) and
     EditEditor(TEditor(Component), TEditor(Component).Ruler) then
    Designer.Modified
  else
    if (Component is TEditorProp) and
       EditEditorProp(TEditorProp(Component),
                      TEditorProp(Component).Ruler) then
      Designer.Modified;
end;


{ TFountainColorPropertyEditor }

procedure TFountainColorPropertyEditor.Edit;
var
  Component: TPersistent;
begin
  Component := GetComponent(0);
  if (Component is TFountain) and
     EditFountain(TFountain(Component)) then
    Designer.Modified;
end;


{ TFountainBracketPropertyEditor }

function TFountainBracketPropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;


{ TEditorComponentEditor }

procedure TEditorComponentEditor.Edit;
begin
  if EditEditor(TEditor(Component), nil) then
    Designer.Modified;
end;

function TEditorComponentEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

function TEditorComponentEditor.GetVerb(Index: Integer): String;
begin
  Result := Component.Name + EditorComponentEditor_Verbstr; // ' の編集(&H)';
end;

procedure TEditorComponentEditor.ExecuteVerb(Index: Integer);
begin
  Edit;
end;


{ TEditorPropComponentEditor }

procedure TEditorPropComponentEditor.Edit;
begin
  if EditEditorProp(TEditorProp(Component), nil) then
    Designer.Modified;
end;


{ TFountainComponentEditor }

procedure TFountainComponentEditor.Edit;
begin
  if EditFountain(TFountain(Component)) then
    Designer.Modified;
end;


{ TStringsPropertyEditor }

procedure TStringsPropertyEditor.Edit;
var
  Form: TFormStringsEditor;
  Editor: TEditor;
begin
  Form:= TFormStringsEditor.Create(Application);
  try
    if GetComponent(0) is TComponent then
      Form.FFileList.Add(
        TComponent(GetComponent(0)).Owner.Name + '.' +
        TComponent(GetComponent(0)).Name + '.' +
        GetName);
    (*
       TEditor の場合は、Caret, Color, Font, Margin, Marks,
       ReserveWordList, ScrollBars, View, WrapOption, WordWrap
       プロパティを EditorProp1 経由で受け継ぎ、
       Fountain プロパティもコピーする。
    *)
    if GetComponent(0) is TEditor then
    begin
      Editor := GetComponent(0) as TEditor;
      Form.EditorProp1.Assign(Editor);
      Form.EditorProp1.AssignTo(Form.Editor1);
      Form.Editor1.Fountain := Editor.Fountain;
    end;
    // TStrings データを受け取る
    Form.Editor1.Lines.Assign(TStrings(GetOrdValue));
    if Form.ShowModal = mrOK then
    begin
      SetOrdValue(Longint(TStrings(Form.Editor1.Lines)));
      Modified;
    end;
  finally
    Form.Free;
  end;
end;

function TStringsPropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result:= [paDialog, paReadOnly];
end;


{ TEditorEnumIntegerPropertyEditor }

function TEditorEnumIntegerPropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList, paSortList, paRevertable];
end;


{ TEditorTabSpaceCountPropertyEditor }

procedure TEditorTabSpaceCountPropertyEditor.GetValues(Proc: TGetStrProc);
var
  I: Integer;
begin
  for I := 1 to 4 do
    Proc(IntToStr(I * 2));
end;


{ TEditorRulerGaugeRangePropertyEditor }

procedure TEditorRulerGaugeRangePropertyEditor.GetValues(Proc: TGetStrProc);
begin
  Proc('8');
  Proc('10');
end;


end.
