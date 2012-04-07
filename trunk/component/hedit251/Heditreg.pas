(*********************************************************************

  HEditReg.pas

  start  1998/06/20
  update 2001/07/25

  Copyright (c) 1998, 2001 本田勝彦 <katsuhiko.honda@nifty.ne.jp>
  --------------------------------------------------------------------
  Register for TEditor, TEditorProp, TFountain

**********************************************************************)

unit HEditReg;

{$I heverdef.inc}

interface

uses
  Classes

  {$IFDEF COMP6_UP}
    ,DesignIntf
    ,DesignEditors;
  {$ELSE}
    ,Dsgnintf;
  {$ENDIF}

procedure Register;

implementation

uses
  Controls, HEditor, HEdtProp, HPropert, EditorFountain,
  heFountain, DelphiFountain, HTMLFountain;

procedure Register;
begin
  // components
  RegisterComponents('TEditor', [TEditor, TEditorProp]);

  // component editors
  RegisterComponentEditor(TEditor, TEditorComponentEditor);
  RegisterComponentEditor(TEditorProp, TEditorPropComponentEditor);
  RegisterComponentEditor(TFountain, TFountainComponentEditor);

  // property editors

  // TEditorBracketsPropertyEditor
  RegisterPropertyEditor(TypeInfo(TEditorBracketCollection),
    TEditorViewInfo, 'Brackets', TEditorBracketsPropertyEditor);
  // TEditorCaretPropertyEditor
  RegisterPropertyEditor(TypeInfo(TEditorCaret),
    nil, '', TEditorCaretPropertyEditor);
  // TEditorTabSpaceCountPropertyEditor
  RegisterPropertyEditor(TypeInfo(Integer),
    TEditorCaret, 'TabSpaceCount', TEditorTabSpaceCountPropertyEditor);
  // TEditorCursorPropertyEditor
  { 総ての Cursor プロパティに TEditorCursorPropertyEditor を有効に
    する場合
  RegisterPropertyEditor(TypeInfo(TCursor),
    nil, '', TEditorCursorsPropertyEditor);}
  { TEditor.Caret.Cursors にだけ crRightArrow を認識する
    TEditorCursorPropertyEditor を適用する場合}
  RegisterPropertyEditor(TypeInfo(TCursor),
    TEditorCursors, '', TEditorCursorsPropertyEditor);
  // TEditorColorsPropertyEditor
  RegisterPropertyEditor(TypeInfo(TEditorColors),
    TEditorViewInfo, 'Colors', TEditorColorsPropertyEditor);
  // TEditorMarginPropertyEditor
  RegisterPropertyEditor(TypeInfo(TEditorMargin),
    nil, '', TEditorMarginPropertyEditor);
  // TEditorMarksPropertyEditor
  RegisterPropertyEditor(TypeInfo(TEditorMarks),
    nil, '', TEditorMarksPropertyEditor);
  // TEditorViewPropertyEditor
  RegisterPropertyEditor(TypeInfo(TEditorViewInfo),
    nil, '', TEditorViewPropertyEditor);
  // TEditorWrapOptionPropertyEditor
  RegisterPropertyEditor(TypeInfo(TEditorWrapOption),
    nil, '', TEditorWrapOptionPropertyEditor);
  // TEditorLeftbarPropertyEditor
  RegisterPropertyEditor(TypeInfo(TEditorLeftbar),
    nil, '', TEditorLeftbarPropertyEditor);
  // TEditorRulerPropertyEditor
  RegisterPropertyEditor(TypeInfo(TEditorRuler),
    nil, '', TEditorRulerPropertyEditor);
  // TEditorRulerGaugeRangePropertyEditor
  RegisterPropertyEditor(TypeInfo(Integer),
    TEditorRuler, 'GaugeRange', TEditorRulerGaugeRangePropertyEditor);
  // TStringsPropertyEditor
  { 総ての TStrings に対して TStringsPropertyEditor を有効にする場合
  RegisterPropertyEditor(TypeInfo(TStrings),
    nil, '', TStringsPropertyEditor);}
  // TEditor にだけ TStringsPropertyEditor を適用する場合
  RegisterPropertyEditor(TypeInfo(TStrings),
    TEditor, '', TStringsPropertyEditor);
  RegisterPropertyEditor(TypeInfo(TStrings),
    TEditorProp, '', TStringsPropertyEditor);
  // TFountainColorPropertyEditor
  RegisterPropertyEditor(TypeInfo(TFountainColor),
    TFountain, '', TFountainColorPropertyEditor);
  // TFountainBracketPropertyEditor
  RegisterPropertyEditor(TypeInfo(TFountainBracketCollection),
    TFountain, '', TFountainBracketPropertyEditor);
  // TFountain.Strings
  RegisterPropertyEditor(TypeInfo(TStrings),
    TFountain, '', TStringsPropertyEditor);

  // TFountain components
  DelphiFountain.Register;
  HTMLFountain.Register;
end;

end.

