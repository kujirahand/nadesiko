unit dll_office_function;

interface

uses
  Windows, SysUtils, Classes, Registry, dll_plugin_helper, dnako_import,
  dnako_import_types, unit_office, ActiveX;

const
  NAKOFFICE_DLL_VERSION = '1.5041';

procedure RegistFunction;
procedure PluginFin;

implementation

uses unit_sqlite, OpenOffice, mini_file_utils, unit_string, StrUnit,
  unit_sqlite3, Variants;

var
  _excel : TKExcel = nil;
  _word  : TKWord  = nil;
  ado   : TKAdo   = nil;
  ppt   : TKPowerPoint = nil;

{$IFDEF VER150}
function VarIsNull(v: Variant): Boolean;
var
  w: Word;
begin
  w := VarType(v);
  Result := (w = varNull);
end;
{$ENDIF}

function excel : TKExcel;
begin
  if _excel = nil then
  begin
    raise Exception.Create('�G�N�Z�����N�����Ă��܂���B�w�G�N�Z���N���x���߂ŋN�������Ă��������B');
  end;
  Result := _excel;
end;

function word : TKWord;
begin
  if _word = nil then
  begin
    raise Exception.Create('���[�h���N�����Ă��܂���B�w���[�h�N���x���߂ŋN�������Ă��������B');
  end;
  Result := _word;
end;

function getNakoOfficeVersion(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(NAKOFFICE_DLL_VERSION);
end;

function excel_open(h: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
begin
  Result := nil;
  //
  a := nako_getFuncArg(h, 0);
  //
  FreeAndNil(_excel);
  _excel := TKExcel.Create;
  _excel.Open({Visible}hi_bool(a));
end;

function excel_close(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  FreeAndNil(_excel);
end;

function excel_workbooks_add(h: DWORD): PHiValue; stdcall;
var
  b: Variant;
begin
  Result := nil;
  b := excel.WorkBookAdd;
  if not VarIsNull(b) then
    Result := hi_newStr(b.Name);
end;

function excel_worksheet_add(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  excel.WorkSheetAdd;
end;

function excel_file_open(h: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  b: Variant;
begin
  Result := nil;
  s := nako_getFuncArg(h, 0);
  b := excel.FileOpen(hi_str(s));
  if not VarIsNull(b) then
    Result := hi_newStr(b.Name);
end;

function excel_file_save(h: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  Result := nil;
  s := nako_getFuncArg(h, 0);
  excel.FileSave(hi_str(s));
end;

function excel_worksheet_active(h: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  Result := nil;
  s := nako_getFuncArg(h, 0);
  if s.VType = varInt then
    excel.WorkSheetActive(hi_int(s))
  else
    excel.WorkSheetActiveS(hi_str(s));
end;

function excel_workbook_active(h: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  Result := nil;
  s := nako_getFuncArg(h, 0);
  if s.VType = varInt then
  begin
    excel.WorkBookActive(hi_int(s));
  end else
  begin
    excel.WorkBookActiveS(hi_str(s));
  end;
end;

function excel_file_saveCsv(h: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  Result := nil;
  s := nako_getFuncArg(h, 0);
  excel.FileSaveAsCsv(hi_str(s));
end;

function excel_file_saveTsv(h: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  Result := nil;
  s := nako_getFuncArg(h, 0);
  excel.FileSaveAsTsv(hi_str(s));
end;

function excel_file_savePDF(h: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  Result := nil;
  s := nako_getFuncArg(h, 0);
  excel.FileSaveAsPDF(hi_str(s));
end;

function excel_setCell(h: DWORD): PHiValue; stdcall;
var
  cell, v: PHiValue;
begin
  Result := nil;
  cell := nako_getFuncArg(h, 0);
  v    := nako_getFuncArg(h, 1);
  excel.SetCellR(hi_str(cell), hi_str(v));
end;

function excel_getCell(h: DWORD): PHiValue; stdcall;
var
  cell: PHiValue;
  res: string;
begin
  cell := nako_getFuncArg(h, 0);
  res := excel.GetCellR(hi_str(cell));
  Result := hi_newStr(res);
end;

function excel_setCellEx(h: DWORD): PHiValue; stdcall;
var
  cell, v: PHiValue;
begin
  Result := nil;
  cell := nako_getFuncArg(h, 0);
  v    := nako_getFuncArg(h, 1);
  excel.SetCellEx(hi_str(cell), hi_str(v));
end;

function excel_getCellEx(h: DWORD): PHiValue; stdcall;
var
  c1, c2: PHiValue;
begin
  c1 := nako_getFuncArg(h, 0);
  c2 := nako_getFuncArg(h, 1);
  Result := hi_newStr(excel.GetCellEx(hi_str(c1), hi_str(c2)));
end;

function excel_select(h: DWORD): PHiValue; stdcall;
var
  cell: PHiValue;
begin
  cell := nako_getFuncArg(h, 0);
  excel.CellSelect(hi_str(cell));
  Result := nil;
end;

function excel_selectall(h: DWORD): PHiValue; stdcall;
begin
  excel.SelectAll;
  Result := nil;
end;

function excel_selectReplace(h: DWORD): PHiValue; stdcall;
var
  a, b: string;
begin
  a := getArgStr(h, 0, True);
  b := getArgStr(h,1);
  excel.SelectionReplace(a, b);
  Result := nil;
end;

function excel_setCellHeight(h: DWORD): PHiValue; stdcall;
var
  v: Double;
begin
  v := getArgFloat(h, 0, True);
  excel.setRowHeight(v);
  Result := nil;
end;

function excel_setCellWidth(h: DWORD): PHiValue; stdcall;
var
  v: Double;
begin
  v := getArgFloat(h, 0, True);
  excel.setColWidth(v);
  Result := nil;
end;


function excel_enumSheets(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(excel.enumSheets);
end;

function excel_copy(h: DWORD): PHiValue; stdcall;
begin
  excel.CellCopy;
  Result := nil;
end;

function excel_workbook_marge(h: DWORD): PHiValue; stdcall;
var
  fname: string;
begin
  fname := getArgStr(h, 0);
  excel.WorkBookMarge(fname);
  Result := nil;
end;


function excel_sendKeys(h: DWORD): PHiValue; stdcall;
var
  keys: string;
begin
  keys := getArgStr(h, 0, True);
  excel.SendKeys(keys);
  Result := nil;
end;


function excel_sheetcopy(h: DWORD): PHiValue; stdcall;
var
  sh1, sh2: string;
begin
  sh1 := getArgStr(h, 0, True);
  sh2 := getArgStr(h, 1);
  excel.SheetCopy(sh1, sh2);
  Result := nil;
end;

function excel_sheetrename(h: DWORD): PHiValue; stdcall;
var
  sh1, sh2: string;
begin
  sh1 := getArgStr(h, 0, True);
  sh2 := getArgStr(h, 1);
  excel.SheetRename(sh1, sh2);
  Result := nil;
end;


function excel_getLastRow(h: DWORD): PHiValue; stdcall;
var
  col: string;
  v: PHiValue;
begin
  v := nako_getFuncArg(h, 0);
  if v = nil then
  begin
    col := 'A';
  end else
  begin
    col := hi_str(v);
  end;
  Result := hi_newInt(excel.getLastRow(col));
end;

function excel_getLastCol(h: DWORD): PHiValue; stdcall;
var
  row: string;
  v: PHiValue;
begin
  v := nako_getFuncArg(h, 0);
  if v = nil then
  begin
    row := '1';
  end else
  begin
    row := hi_str(v);
  end;
  Result := hi_newInt(excel.getLastCol(row));
end;

function excel_insertPic(h: DWORD): PHiValue; stdcall;
var
  f: string;
begin
  f := getArgStr(h, 0);
  excel.addPicture(f, false);
  Result := nil;
end;

function excel_insertPicLink(h: DWORD): PHiValue; stdcall;
var
  f: string;
begin
  f := getArgStr(h, 0);
  excel.addPicture(f, true);
  Result := nil;
end;

function excel_shapeResize(h: DWORD): PHiValue; stdcall;
var
  ww, hh: Integer;
begin
  ww := getArgInt(h, 0);
  hh := getArgInt(h, 1);
  excel.SetShapeSize(ww, hh);
  Result := nil;
end;


function excel_getVersion(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newInt(excel.Version);
end;

function excel_yomi(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(excel.Phonetic(getArgStr(h,0,True)));
end;

function excel_yomiAll(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(excel.PhoneticAll(getArgStr(h,0,True)));
end;

function excel_cell_yomi(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(excel.CellPhonic(getArgStr(h,0,True)));
end;

function excel_getSelectionRow(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newInt(excel.SelectionRow);
end;
function excel_getSelectionCol(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newInt(excel.SelectionCol);
end;

function excel_deleteSheet(h: DWORD): PHiValue; stdcall;
var
  sname: string;
begin
  sname := getArgStr(h, 0, True);
  Result := hi_newBool(excel.DeleteSheet(sname));
end;

function excel_insertRow(h: DWORD): PHiValue; stdcall;
var
  sname: string;
begin
  sname := getArgStr(h, 0, True);
  excel.InsertRow(sname);
  Result := nil;
end;
function excel_insertCol(h: DWORD): PHiValue; stdcall;
var
  sname: string;
begin
  sname := getArgStr(h, 0, True);
  excel.InsertCol(sname);
  Result := nil;
end;

function excel_deleteRow(h: DWORD): PHiValue; stdcall;
var
  no: string;
begin
  no := getArgStr(h, 0, True);
  excel.DeleteRow(no);
  Result := nil;
end;
function excel_deleteCol(h: DWORD): PHiValue; stdcall;
var
  sname: string;
begin
  sname := getArgStr(h, 0, True);
  excel.DeleteCol(sname);
  Result := nil;
end;


function excel_displayAlertsOff(h: DWORD): PHiValue; stdcall;
begin
  excel.DisplayAlerts := False;
  Result := nil;
end;

function excel_displayAlertsOn(h: DWORD): PHiValue; stdcall;
begin
  excel.DisplayAlerts := True;
  Result := nil;
end;

function excel_moveSheetLast(h: DWORD): PHiValue; stdcall;
var
  sheet: string;
begin
  sheet := getArgStr(h, 0, True);
  excel.WorkSheetMoveLast(sheet);
  Result := nil;
end;

function excel_moveSheetTop(h: DWORD): PHiValue; stdcall;
var
  sheet: string;
begin
  sheet := getArgStr(h, 0, True);
  excel.WorkSheetMoveTop(sheet);
  Result := nil;
end;


function excel_protect_on(h: DWORD): PHiValue; stdcall;
var
  sheet, pw: string;
begin
  sheet := getArgStr(h, 0, True);
  pw    := getArgStr(h, 1);
  excel.ProtectOn(sheet, pw);
  Result := nil;
end;

function excel_protect_off(h: DWORD): PHiValue; stdcall;
var
  sheet, pw: string;
begin
  sheet := getArgStr(h, 0, True);
  pw    := getArgStr(h, 1);
  excel.ProtectOff(sheet, pw);
  Result := nil;
end;


function excel_checkInstall(h: DWORD): PHiValue; stdcall;
var
  reg: TRegistry;
  b: Boolean;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CLASSES_ROOT;
    b := reg.KeyExists('Excel.Application');
  finally
    FreeAndNil(reg);
  end;
  Result := hi_newBool(b);
end;

function excel_getActiveBookName(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(excel.GetActiveWorkBookName);
end;


function excel_getActiveSheetName(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(excel.GetActiveSheetName);
end;

function excel_shapeMove(h: DWORD): PHiValue; stdcall;
begin
  excel.MoveShape(
    getArgInt(h, 0),
    getArgInt(h,1));
  Result := nil;
end;

// �������̃��\�b�h
// AddFunc  ('�G�N�Z���O���t�}��','{=?}RANGE����TYPE��', 4736, excel_insertChart,'Excel�Łu����:�E���v������TYPE�̃O���t���쐬���đ}������B','�������邮��ӂ����ɂイ');
function excel_insertChart(h: DWORD): PHiValue; stdcall;
var
  range, typeStr: string;
begin
  range := getArgStr(h, 0, True);
  typeStr := getArgStr(h, 1);
  excel.InsertChart(range, typeStr);
  Result := nil;
end;

function excel_selectShape(h: DWORD): PHiValue; stdcall;
begin
  excel.SelectShape(getArgStr(h, 0, True));
  Result := nil;
end;

function word_checkInstall(h: DWORD): PHiValue; stdcall;
var
  reg: TRegistry;
  b: Boolean;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CLASSES_ROOT;
    b := reg.KeyExists('Word.Application');
  finally
    FreeAndNil(reg);
  end;
  Result := hi_newBool(b);
end;

function ppt_checkInstall(h: DWORD): PHiValue; stdcall;
var
  reg: TRegistry;
  b: Boolean;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CLASSES_ROOT;
    b := reg.KeyExists('PowerPoint.Application');
  finally
    FreeAndNil(reg);
  end;
  Result := hi_newBool(b);
end;

function excel_uniqueRow(h:DWORD): PHiValue; stdcall;
var
  col: string;
  v: PHiValue;
begin
  v := nako_getFuncArg(h, 0);
  if v = nil then
  begin
    col := 'A';
  end else
  begin
    col := hi_str(v);
  end;
  excel.UniqueRow(col);
  Result := nil;
end;

function excel_cellname(h: DWORD): PHiValue; stdcall;
var
  row, col: Integer;
  s: string;
begin
  row := getArgInt(h, 0, True);
  col := getArgInt(h, 1) - 1;
  s := RowColToCellName(row, col);
  Result := hi_newStr(s);
end;

function excel_paste(h: DWORD): PHiValue; stdcall;
begin
  excel.CellPaste;
  Result := nil;
end;

function excel_color(h: DWORD): PHiValue; stdcall;
var
  v: PHiValue;
begin
  v := nako_getFuncArg(h, 0);
  excel.CellColor(hi_int(v));
  Result := nil;
end;

function excel_selection_merge(h: DWORD): PHiValue; stdcall;
begin
  excel.SelectionMerge;
  Result := nil;
end;

function excel_selection_align(h: DWORD): PHiValue; stdcall;
var
  v: string;
  i: Integer;
begin
  v := getArgStr(h, 0, False);
  i := 0;
  if v = '�E' then i := xlRight;
  if v = '��' then i := xlLeft;
  if Copy(v,1,2) = '��' then i := xlCenter;
  if i <> 0 then
  begin
    excel.SelectionAlignment(i);
  end;
  Result := nil;
end;

function excel_selection_valign(h: DWORD): PHiValue; stdcall;
var
  v: string;
  i: Integer;
begin
  v := getArgStr(h, 0, False);
  i := 0;
  if v = '��' then i := xlTop;
  if v = '��' then i := xlBottom;
  if Copy(v,1,2) = '��' then i := xlCenter;
  if i <> 0 then
  begin
    excel.SelectionAlignment(i);
  end;
  Result := nil;
end;


function excel_macro(h: DWORD): PHiValue; stdcall;
var
  a, b: PHiValue;
  ret: string;
begin
  a := nako_getFuncArg(h, 0);
  b := nako_getFuncArg(h, 1);
  ret := excel.MacroExec(hi_str(a), hi_str(b));
  Result := hi_newStr(ret);
end;

function excel_sheet_printPreview(h: DWORD): PHiValue; stdcall;
begin
  excel.PrintPreview;
  Result := nil;
end;

function excel_sheet_printOut(h: DWORD): PHiValue; stdcall;
begin
  excel.Print;
  Result := nil;
end;

function excel_book_printPreview(h: DWORD): PHiValue; stdcall;
begin
  excel.WorkBookPrintPreview;
  Result := nil;
end;

function excel_book_printOut(h: DWORD): PHiValue; stdcall;
begin
  excel.WorkBookPrint;
  Result := nil;
end;

function excel_setVisible(h: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := nako_getFuncArg(h, 0);
  Result := nil;
  excel.Visible := hi_bool(a);
end;

function excel_workbook_close(h: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := nako_getFuncArg(h, 0);
  excel.WorkBookClose(hi_str(a));
  Result := nil;
end;

function excel_workbook_close_save(h: DWORD): PHiValue; stdcall;
var
  name: string;
begin
  name := getArgStr(h, 0, True);
  excel.WorkBookCloseSave(name);
  Result := nil;
end;

function excel_workbook_close_nosave(h: DWORD): PHiValue; stdcall;
var
  name: string;
begin
  name := getArgStr(h, 0, True);
  excel.WorkBookCloseNoSave(name); // Do not save!
  Result := nil;
end;


function word_open(h: DWORD): PHiValue; stdcall;
var
  v: PHiValue;
begin
  v := nako_getFuncArg(h, 0);
  FreeAndNil(_word);
  //
  _word := TKWord.Create;
  word.Open(hi_bool(v));
  Result := nil;
end;

function word_close(h: DWORD): PHiValue; stdcall;
begin
  FreeAndNil(_word);
  Result := nil;
end;

function word_docClose(h: DWORD): PHiValue; stdcall;
begin
  if word = nil then raise Exception.Create('���[�h���N�����Ă��܂���B�w���[�h�N���x���߂ŋN�������Ă��������B');
  word.DocClose;
  Result := nil;
end;

function word_save(h: DWORD): PHiValue; stdcall;
var
  v: PHiValue;
begin
  v := nako_getFuncArg(h, 0);
  if word = nil then raise Exception.Create('���[�h���N�����Ă��܂���B�w���[�h�N���x���߂ŋN�������Ă��������B');
  word.FileSave(hi_str(v));
  Result := nil;
end;

function word_load(h: DWORD): PHiValue; stdcall;
var
  v: PHiValue;
begin
  v := nako_getFuncArg(h, 0);
  if word = nil then raise Exception.Create('���[�h���N�����Ă��܂���B�w���[�h�N���x���߂ŋN�������Ă��������B');
  word.FileOpen(hi_str(v));
  Result := nil;
end;

function word_new(h: DWORD): PHiValue; stdcall;
begin
  if word = nil then raise Exception.Create('���[�h���N�����Ă��܂���B�w���[�h�N���x���߂ŋN�������Ă��������B');
  word.NewDoc;
  Result := nil;
end;

function word_bookmark(h: DWORD): PHiValue; stdcall;
var
  s, v: PHiValue;
begin
  s := nako_getFuncArg(h, 0);
  v := nako_getFuncArg(h, 1);
  if word = nil then raise Exception.Create('���[�h���N�����Ă��܂���B�w���[�h�N���x���߂ŋN�������Ă��������B');
  word.BookmarkInsertText(hi_str(s), hi_str(v));
  Result := nil;
end;

function word_bookmark_get(h: DWORD): PHiValue; stdcall;
var
  bookmark: string;
begin
  bookmark := getArgStr(h, 0, True);
  if word = nil then raise Exception.Create('���[�h���N�����Ă��܂���B�w���[�h�N���x���߂ŋN�������Ă��������B');
  Result := hi_newStr(word.BookmarkGetText(bookmark));
end;

function word_printPreview(h: DWORD): PHiValue; stdcall;
begin
  if word = nil then raise Exception.Create('���[�h���N�����Ă��܂���B�w���[�h�N���x���߂ŋN�������Ă��������B');
  word.PrintPreview;
  Result := nil;
end;

function word_print(h: DWORD): PHiValue; stdcall;
begin
  if word = nil then raise Exception.Create('���[�h���N�����Ă��܂���B�w���[�h�N���x���߂ŋN�������Ă��������B');
  word.Print;
  Result := nil;
end;

function word_macro(h: DWORD): PHiValue; stdcall;
var
  a, b: PHiValue;
begin
  a := nako_getFuncArg(h, 0);
  b := nako_getFuncArg(h, 1);
  if word = nil then raise Exception.Create('���[�h���N�����Ă��܂���B�w���[�h�N���x���߂ŋN�������Ă��������B');
  Result := hi_newStr(word.MacroExec(hi_str(a), hi_str(b)));
end;

function word_getText(h: DWORD): PHiValue; stdcall;
begin
  if word = nil then raise Exception.Create('���[�h���N�����Ă��܂���B�w���[�h�N���x���߂ŋN�������Ă��������B');
  Result := hi_newStr(word.getAsText);
end;

function word_addText(h: DWORD): PHiValue; stdcall;
var
  v: PHiValue;
begin
  v := nako_getFuncArg(h, 0);
  if v = nil then v := nako_getSore;
  if word = nil then raise Exception.Create('���[�h���N�����Ă��܂���B�w���[�h�N���x���߂ŋN�������Ă��������B');
  word.InsertText(hi_str(v));
  Result := nil;
end;

function word_setVisible(h: DWORD): PHiValue; stdcall;
var
  v: PHiValue;
begin
  v := nako_getFuncArg(h, 0);
  if v = nil then v := nako_getSore;
  if word = nil then raise Exception.Create('���[�h���N�����Ă��܂���B�w���[�h�N���x���߂ŋN�������Ă��������B');
  word.Visible := hi_bool(v);
  Result := nil;
end;

function word_replace(h: DWORD): PHiValue; stdcall;
var
  a, b: string;
begin
  a := getArgStr(h, 0, True);
  b := getArgStr(h, 1);
  if word = nil then raise Exception.Create('���[�h���N�����Ă��܂���B�w���[�h�N���x���߂ŋN�������Ă��������B');
  word.replace(a, b);
  Result := nil;
end;

//------------------------------------------------------------------------------
// PowerPoint
function ppt_open(h: DWORD): PHiValue; stdcall;
var
  v: PHiValue;
begin
  v := nako_getFuncArg(h, 0);
  FreeAndNil(ppt);
  //
  ppt := TKPowerPoint.Create;
  ppt.Open(hi_bool(v));
  Result := nil;
end;

function ppt_open_file(h: DWORD): PHiValue; stdcall;
var
  s: String;
begin
  s := getArgStr(h, 0, True);
  ppt.FileOpen(s);
  Result := nil;
end;

function ppt_close(h: DWORD): PHiValue; stdcall;
begin
  FreeAndNil(ppt);
  Result := nil;
end;

procedure ppt_check;
begin
  if ppt = nil then raise Exception.Create('��Ɂu�p���|�v�N�����߂�PowerPoint���N�����Ă��������B');
end;

function ppt_slide_start(h: DWORD): PHiValue; stdcall;
begin
  ppt_check;
  ppt.SlideStart;
  Result := nil;
end;

function ppt_slide_prev(h: DWORD): PHiValue; stdcall;
begin
  ppt_check;
  ppt.SlidePrev;
  Result := nil;
end;

function ppt_slide_next(h: DWORD): PHiValue; stdcall;
begin
  ppt_check;
  ppt.SlideNext;
  Result := nil;
end;

function ppt_slide_end(h: DWORD): PHiValue; stdcall;
begin
  ppt_check;
  ppt.SlideExit;
  Result := nil;
end;

function ppt_slideshow_run(h: DWORD): PHiValue; stdcall;
begin
  ppt_check;
  ppt.SlideStart;
  Result := nil;
end;

function ppt_slide_replace(h: DWORD): PHiValue; stdcall;
begin
  ppt_check;
  ppt.SlideStart;
  Result := nil;
end;


function ppt_macro(h: DWORD): PHiValue; stdcall;
var
  s, a, r: string;
begin
  s := getArgStr(h, 0, True);
  a := getArgStr(h, 1);
  ppt_check;
  r := ppt.MacroExec(s, a);
  Result := hi_newStr(r);
end;

function ppt_save_jpegfile(h: DWORD): PHiValue; stdcall;
var
  dir: string;
begin
  Result := nil;
  dir := getArgStr(h, 0, True);
  ppt_check;
  ppt.SaveToJpegDir(dir);
end;

function ppt_save_pngfile(h: DWORD): PHiValue; stdcall;
var
  dir: string;
begin
  Result := nil;
  dir := getArgStr(h, 0, True);
  ppt_check;
  ppt.SaveToPngDir(dir);
end;

function ppt_save_pdffile(h: DWORD): PHiValue; stdcall;
var
  f: string;
begin
  Result := nil;
  f := getArgStr(h, 0, True);
  ppt_check;
  ppt.SaveToPDFFile(f);
end;

//------------------------------------------------------------------------------
// ADO

function ado_open_access(h: DWORD): PHiValue; stdcall;
var
  f: PHiValue;
begin
  f := nako_getFuncArg(h, 0);
  if f = nil then f := nako_getSore;

  FreeAndNil(ado);
  ado := TKAdo.Create;
  ado.OpenAccess(
    hi_str(f),
    hi_str(nako_getVariable('DB���[�U�[ID')),
    hi_str(nako_getVariable('DB�p�X���[�h')));

  Result := hi_newInt(Integer(ado));
end;

function ado_open_access2007(h: DWORD): PHiValue; stdcall;
var
  f: PHiValue;
begin
  f := nako_getFuncArg(h, 0);
  if f = nil then f := nako_getSore;

  FreeAndNil(ado);
  ado := TKAdo.Create;
  ado.OpenAccess2007(
    hi_str(f),
    hi_str(nako_getVariable('DB���[�U�[ID')),
    hi_str(nako_getVariable('DB�p�X���[�h')));

  Result := hi_newInt(Integer(ado));
end;

function ado_open_oracle(h: DWORD): PHiValue; stdcall;
var
  f: PHiValue;
begin
  f := nako_getFuncArg(h, 0);
  if f = nil then f := nako_getSore;

  FreeAndNil(ado);
  ado := TKAdo.Create;
  ado.OpenOracle(
    hi_str(f),
    hi_str(nako_getVariable('DB���[�U�[ID')),
    hi_str(nako_getVariable('DB�p�X���[�h')));

  Result := hi_newInt(Integer(ado));
end;

function ado_open_custom(h: DWORD): PHiValue; stdcall;
var
  f: PHiValue;
begin
  f := nako_getFuncArg(h, 0);
  if f = nil then f := nako_getSore;

  FreeAndNil(ado);
  ado := TKAdo.Create;
  ado.OpenCustom(hi_str(f));
  Result := hi_newInt(Integer(ado));
end;

function ado_open_mssql(h: DWORD): PHiValue; stdcall;
var
  f: PHiValue;
begin
  f := nako_getFuncArg(h, 0);
  if f = nil then f := nako_getSore;

  FreeAndNil(ado);
  ado := TKAdo.Create;
  ado.OpenSQLServer(
    hi_str(f),
    hi_str(nako_getVariable('DB���[�U�[ID')),
    hi_str(nako_getVariable('DB�p�X���[�h')));

  Result := hi_newInt(Integer(ado));
end;

function ado_open_sqlserver2005(h: DWORD): PHiValue; stdcall;
var
  f: PHiValue;
begin
  f := nako_getFuncArg(h, 0);
  if f = nil then f := nako_getSore;

  FreeAndNil(ado);
  ado := TKAdo.Create;
  ado.OpenSQLServer(
    hi_str(f),
    hi_str(nako_getVariable('DB���[�U�[ID')),
    hi_str(nako_getVariable('DB�p�X���[�h')));

  Result := hi_newInt(Integer(ado));
end;

function ado_getHandleFromArg(h: DWORD): TKAdo;
var
  p: PHiValue;
begin
  // �ȗ����ꂽ��Ō�ɊJ�����c�a��Ԃ�
  p := nako_getFuncArg(h, 0);
  if p = nil then
  begin
    Result := ado;
  end else
  begin
    Result := TKAdo(Pointer(Integer(hi_int(p))));
  end;
end;

function ado_close(h: DWORD): PHiValue; stdcall;
var
  ado2: TKAdo;
begin
  ado2 := ado_getHandleFromArg(h);
  if ado = ado2 then
  begin
    FreeAndNil(ado);
  end else
  begin
    FreeAndNil(ado2);
  end;
  Result := nil;
end;

function ado_sql(h: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  s := nako_getFuncArg(h, 1);
  if ado = nil then raise Exception.Create('DB�𑀍삷��O��DB���J���K�v������܂��B');
  ado.SQL(hi_str(s));
  Result := nil;
end;

function ado_moveFirst(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DB�𑀍삷��O��DB���J���K�v������܂��B');
  ado.MoveFirst;
  Result := nil;
end;

function ado_moveLast(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DB�𑀍삷��O��DB���J���K�v������܂��B');
  ado.MoveLast;
  Result := nil;
end;

function ado_moveNext(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DB�𑀍삷��O��DB���J���K�v������܂��B');
  ado.MoveNext;
  Result := nil;
end;

function ado_movePrev(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DB�𑀍삷��O��DB���J���K�v������܂��B');
  ado.MovePrev;
  Result := nil;
end;

function ado_bof(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DB�𑀍삷��O��DB���J���K�v������܂��B');
  Result := hi_newBool(ado.dbBOF);
end;

function ado_eof(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DB�𑀍삷��O��DB���J���K�v������܂��B');
  Result := hi_newBool(ado.dbEOF);
end;

function ado_getAllCsv(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DB�𑀍삷��O��DB���J���K�v������܂��B');
  Result := hi_newStr(ado.GetSqlResultAsCsv);
end;

function ado_getAllTsv(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DB�𑀍삷��O��DB���J���K�v������܂��B');
  Result := hi_newStr(ado.GetSqlResultAsTsv);
end;

function ado_find(h: DWORD): PHiValue; stdcall;
var
  table, field, key: string;
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  table := hi_str(nako_getFuncArg(h, 1));
  field := hi_str(nako_getFuncArg(h, 2));
  key   := hi_str(nako_getFuncArg(h, 3));
  if ado = nil then raise Exception.Create('DB�𑀍삷��O��DB���J���K�v������܂��B');
  ado.Find(table, field, key);
  Result := nil;
end;

function ado_getField(h: DWORD): PHiValue; stdcall;
var
  f: string;
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  f := hi_str(nako_getFuncArg(h, 1));
  if ado = nil then raise Exception.Create('DB�𑀍삷��O��DB���J���K�v������܂��B');

  Result := hi_newStr(ado.GetFieldValue(f));
end;

function ado_recordCount(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DB�𑀍삷��O��DB���J���K�v������܂��B');
  Result := hi_newInt(ado.GetRecordCount);
end;

function ado_getFiledNames(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DB�𑀍삷��O��DB���J���K�v������܂��B');
  Result := hi_newStr(ado.GetFieldNames);
end;

function ado_getRec(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DB�𑀍삷��O��DB���J���K�v������܂��B');
  Result := hi_newStr(ado.GetCurRecAsCsv);
end;

function ado_getTableAsCsv(h: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  p := nako_getFuncArg(h, 1);
  if ado = nil then raise Exception.Create('DB�𑀍삷��O��DB���J���K�v������܂��B');
  Result := hi_newStr(ado.GetTableAsCsv(hi_str(p)));
end;

//------------------------------------------------------------------------------
var sqlite_handle_def:Integer = 0;

function sqlite_handle(h: Integer): TSqliteHandle;
begin
  if h = 0 then
  begin
    Result := Pointer(sqlite_handle_def);
  end else
  begin
    Result := Pointer(h);
  end;
  if Result = nil then
  begin
    raise Exception.Create('�n���h���������ł��B�wSQLITE�J���x���߂Ńf�[�^�x�[�X���J���Ă��������B');
  end;
end;

function sqlite3_handle(h: Integer): TSQLite3DB;
begin
  if h = 0 then
  begin
    Result := Pointer(sqlite_handle_def);
  end else
  begin
    Result := Pointer(h);
  end;
  if Result = nil then
  begin
    raise Exception.Create('�n���h���������ł��B�wSQLITE3�J���x���߂Ńf�[�^�x�[�X���J���Ă��������B');
  end;
end;


function sys_SQLiteOpen(args: DWORD): PHiValue; stdcall;
var
  f: string;
  h: TSqliteHandle;
begin
  // raise Exception.Create('SQLite2�n�̃T�|�[�g�͏I�����܂����BSQLite3�n�̖��߁wSQLITE3�J���x�Ȃǂ𗘗p���Ă��������B');
  // SQLite �̏�����
  SqliteInit(FindDLLFile('sqlite.dll'));
  //
  Result := nil;
  f := getArgStr(args, 0, True);
  try
    h := SqliteOpen(f);
    sqlite_handle_def := Integer(h);
    Result := hi_newInt(Integer(h));
  except
    raise;
  end;
end;

function sys_SQLiteClose(args: DWORD): PHiValue; stdcall;
var
  h: Integer;
begin
  Result := nil;
  h := getArgIntDef(args, 0, 0);
  if h = 0 then h := sqlite_handle_def;
  if h = 0 then Exit;
  SqliteClose(Pointer(h));
end;

function sys_SQLiteExecute(args: DWORD): PHiValue; stdcall;
var
  res, sql: string;
  h: TSqliteHandle;
begin
  Result := nil;
  h   := sqlite_handle(getArgIntDef(args, 0, sqlite_handle_def));
  sql := getArgStr(args, 1, True);
  if h = nil then Exit;
  res := '';
  try
    SqliteExecute(h, sql, res);
    Result := hi_newStr(res);
  except
    raise;
  end;
end;

function sys_SQLiteSearch(args: DWORD): PHiValue; stdcall;
var
  res, sql, table, key, field: string;
  h: TSqliteHandle;
begin
  Result := nil;
  h   := sqlite_handle(getArgIntDef(args, 0, sqlite_handle_def));
  table := getArgStr(args, 1, False);
  field := getArgStr(args, 2, False);
  key   := getArgStr(args, 3, False);
  if h = nil then Exit;

  sql   := 'SELECT * FROM ' + table + ' WHERE ' + field + ' LIKE "%' + key + '%"';

  res := '';
  SqliteExecute(h, sql, res);
  Result := hi_newStr(res);
end;

function sys_SQLiteSearch2(args: DWORD): PHiValue; stdcall;
var
  res, sql, table, key, field: string;
  h: TSqliteHandle;
begin
  Result := nil;
  h   := sqlite_handle(getArgIntDef(args, 0, sqlite_handle_def));
  table := getArgStr(args, 1, False);
  field := getArgStr(args, 2, False);
  key   := getArgStr(args, 3, False);
  if h = nil then Exit;

  sql   := 'SELECT * FROM ' + table + ' WHERE ' + field + ' = "' + key + '"';

  res := '';
  SqliteExecute(h, sql, res);
  Result := hi_newStr(res);
end;

function sys_SQLiteCreateTable(args: DWORD): PHiValue; stdcall;
var
  res, sql, table, field: string;
  h: TSqliteHandle;
  sl:TStringList;
begin
  Result := nil;
  h   := sqlite_handle(getArgIntDef(args, 0, sqlite_handle_def));
  table := getArgStr(args, 1, False);
  field := getArgStr(args, 2, False);
  if h = nil then Exit;
  sl := TStringList.Create;
  try
    sl.Text := JReplace(field, ',', #13#10,True);
    if (sl.Count > 0) then
    begin
      if pos('PRIMARY KEY', sl.Strings[0]) = 0 then
      begin
        sl.Strings[0] := sl.Strings[0] + ' INTEGER PRIMARY KEY';
      end;
    end;
    sql := JReplace(Trim(sl.Text), #13#10, ',', True);
  finally
    sl.Free;
  end;
  res := '';
  try
   sql := 'CREATE TABLE ' + table + '(' + sql + ')';
    SqliteExecute(h, sql, res); // �G���[�͖�������
  except
    on e:Exception do
    begin
      if Pos('already exists', e.Message) = 0 then
      begin
        raise;
      end;
    end;
  end;
  Result := nil;
end;

function sys_SQLiteDropTable(args: DWORD): PHiValue; stdcall;
var
  res, sql, table: string;
  h: TSqliteHandle;
begin
  Result := nil;
  h   := sqlite_handle(getArgIntDef(args, 0, sqlite_handle_def));
  table := getArgStr(args, 1, False);
  if h = nil then Exit;
  sql := 'DROP TABLE IF EXISTS ' + table;
  SqliteExecute(h, sql, res);
  Result := nil;
end;

procedure hash_split_keys_values(p:PHiValue; var fields:string; var values:string);
var
  sl: TStringList;
  i: Integer;
  key, value: string;
begin
  sl := TStringList.Create;
  sl.Text := hi_hashKeys(p);
  fields := '';
  values := '';
  for i := 0 to sl.Count - 1 do
  begin
    key := sl.Strings[i];
    value := hi_str(nako_hash_get(p, PChar(key)));
    fields := fields + key + ',';
    values := values + '''' + sqlite_escape_string(value) + ''',';
  end;
  if sl.Count > 0 then
  begin
    fields := Copy(fields, 1, Length(fields) - 1);
    values := Copy(values, 1, Length(values) - 1);
  end;
  sl.Free;
end;

function hash_split_keys_values2(p:PHiValue): string;
var
  sl: TStringList;
  i: Integer;
  r, key, value: string;
begin
  sl := TStringList.Create;
  sl.Text := hi_hashKeys(p);
  r := '';
  for i := 0 to sl.Count - 1 do
  begin
    key := sl.Strings[i];
    value := hi_str(nako_hash_get(p, PChar(key)));
    r := key + '=''' + sqlite_escape_string(value) + ''',';
  end;
  if sl.Count> 0 then
  begin
    r := Copy(r, 1, Length(r) - 1);
  end;
  Result := r;
  sl.Free;
end;

function sys_SQLiteInsert(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  res, sql, table: string;
  h: TSqliteHandle;
  fields, values: string;
begin
  Result := nil;
  h   := sqlite_handle(getArgIntDef(args, 0, sqlite_handle_def));
  table:= getArgStr(args, 1);
  p    := getArg(args, 2);
  //
  hash_split_keys_values(p, fields, values);
  sql := 'INSERT INTO ' + table + '(' + fields + ')VALUES(' +
    values + ')';
  SqliteExecute(h, sql, res);
  Result := nil;
end;
function sys_SQLiteUpdate(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  res, sql, table, where: string;
  h: TSqliteHandle;
  ss: string;
begin
  Result := nil;
  h   := sqlite_handle(getArgIntDef(args, 0, sqlite_handle_def));
  table:= getArgStr(args, 1);
  where:= getArgStr(args, 2);
  p    := getArg(args, 3);
  //
  ss := hash_split_keys_values2(p);
  sql := 'UPDATE ' + table + ' SET ' + ss + ' WHERE ' + where;
  SqliteExecute(h, sql, res);
  Result := nil;
end;
function sys_SQLiteDelete(args: DWORD): PHiValue; stdcall;
var
  res, sql, table, where: string;
  h: TSqliteHandle;
begin
  Result := nil;
  h   := sqlite_handle(getArgIntDef(args, 0, sqlite_handle_def));
  table := getArgStr(args, 1);
  where := getArgStr(args, 2);
  sql := 'DELETE FROM ' + table + ' WHERE ' + where;
  SqliteExecute(h, sql, res);
  Result := nil;
end;
function sys_SQLiteSelectAll(args: DWORD): PHiValue; stdcall;
var
  res, sql, table, where: string;
  h: TSqliteHandle;
begin
  Result := nil;
  h   := sqlite_handle(getArgIntDef(args, 0, sqlite_handle_def));
  table := getArgStr(args, 1);
  where := getArgStr(args, 2);
  if where = '' then
  begin
    sql := 'SELECT * FROM ' + table;
  end else
  begin
    sql := 'SELECT * FROM ' + table + ' WHERE ' + where;
  end;
  SqliteExecute(h, sql, res);
  Result := hi_newStr(res);
end;

function sys_SQLiteSetEncode(args: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  unit_sqlite.sqlite_encode := getArgStr(args, 0, True);
end;

function sys_SQLiteGetLastId(args: DWORD): PHiValue; stdcall;
var h: TSqliteHandle;
begin
  h   := sqlite_handle(getArgIntDef(args, 0, sqlite_handle_def));
  Result := hi_newInt(SqliteLastInsertRowId(h));
end;

// sqlite3
function sys_SQLite3Open(args: DWORD): PHiValue; stdcall;
var
  f: string;
  h: TSQLite3DB;
  msg: string;
  sql_res: integer;
  Info: TOSVersionInfo;
begin
  Result := nil;
  f := getArgStr(args, 0, True);
  try
    // sqlite3 �̏�����
    if not sqlite3_loaded then
    begin
      unit_sqlite3.sqlite3_init(FindDLLFile(SQLite3DLL));
    end;
    // �f�[�^�x�[�X���J��
    GetVersionEx(Info);
    if (info.dwMajorVersion = 4) and (info.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS) then
      sql_res := SQLite3_Open(PChar(f), h)
    else
      sql_res := SQLite3_Open(PChar(AnsiToUtf8(f)), h);

    if sql_res = SQLITE_OK then
    begin
      Result := hi_newInt(Integer(h));
      sqlite_handle_def := Integer(h); // set default databese
    end else
    begin
      msg := Sqlite3_ErrMsg(h);
      raise Exception.CreateFmt('�wSQLITE3�J���x�Ńf�[�^�x�[�X�u%s�v���J���܂���ł����B%s',
          [f, msg]);
    end;
  except
    raise;
  end;
end;
function sys_SQLite3Close(args: DWORD): PHiValue; stdcall;
var
  h: Integer;
begin
  Result := nil;
  h := getArgIntDef(args, 0, 0);
  if h = 0 then h := sqlite_handle_def;
  if h = 0 then Exit;
  SQLite3_Close(Pointer(h));
end;

function sqlite3_autoconv: Boolean;
begin
  Result := hi_bool(nako_getVariable('SQLITE3�����ϊ�'));
end;

function sys_SQLite3Execute(args: DWORD): PHiValue; stdcall;
var
  res, sql: string;
  h: TSqliteHandle;
begin
  Result := nil;
  h   := sqlite_handle(getArgIntDef(args, 0, sqlite_handle_def));
  sql := getArgStr(args, 1, True);
  if h = nil then Exit;
  res := '';
  try
    if sqlite3_autoconv then
    begin
      sql := UTF8Encode(sql);
      res := SQLite3ExecCSV(h, sql);
      res := UTF8Decode(res);
    end else
    begin
      res := SQLite3ExecCSV(h, sql);
    end;
    Result := hi_newStr(res);
  except
    raise;
  end;
end;

function sys_SQLite3GetLastId(args: DWORD): PHiValue; stdcall;
var h: TSqliteHandle;
begin
  h   := sqlite3_handle(getArgIntDef(args, 0, sqlite_handle_def));
  Result := hi_newInt(SQLite3_LastInsertRowID(h));
end;

function sys_SQLite3SetEncode(args: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  unit_sqlite3.sqlite_encode := getArgStr(args, 0, True);
end;

function sys_SQLite3TotalChanges(args: DWORD): PHiValue; stdcall;
var h: TSqliteHandle;
begin
  h   := sqlite3_handle(getArgIntDef(args, 0, sqlite_handle_def));
  Result := hi_newInt(SQLite3_TotalChanges(h));
end;

function sys_sqlite3_checkInstall(args: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  s := FindDLLFile(SQLite3DLL);
  Result := hi_newBool(FileExists(s));  
end;

//------------------------------------------------------------------------------
// OpenOffice.org Calc
var ooo:TOpenOfficeorg = nil;
var ooo_visible:Boolean = true;

function calc_open(h: DWORD): PHiValue; stdcall;
begin
  FreeAndNil(ooo);
  //
  ooo_visible := getArgBool(h, 0);
  ooo := TOpenOfficeorg.Create;
  if not ooo.Connect then raise Exception.Create('OpenOffice.org ���N���ł��܂���ł����B');
  Result := nil;
end;

function calc_close(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  FreeAndNil(ooo);
end;

function calc_workbooks_add(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');
  ooo.NewDocumentCalc(not ooo_visible);
  ooo.SetActiveSheetByIndex(0);
end;

function calc_worksheet_add(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');
  if not ooo.DocumentOpened then
  begin
    ooo.NewDocumentCalc(not ooo_visible);
  end else
  begin
    ooo.NewSheet('');
  end;
end;

function calc_file_open(h: DWORD): PHiValue; stdcall;
var
  name:String;
begin
  name := getArgStr(h, 0);
  Result := nil;
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');
  ooo.OpenDocument(name, not ooo_visible);
end;

function calc_file_save(h: DWORD): PHiValue; stdcall;
var
  name:String;
begin
  name := getArgStr(h, 0);
  Result := nil;
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');
  ooo.SaveDocument(name, OO_FORMAT_EXCEL);
end;

function calc_worksheet_active(h: DWORD): PHiValue; stdcall;
var
  name:String;
  index: Integer;
begin
  name  := getArgStr(h, 0);
  index := StrToIntDef(name, -1);

  Result := nil;
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');

  if index >= 0 then
  begin
    ooo.SetActiveSheetByIndex(index);
  end else
  begin
    ooo.SetActiveSheetByName(name);
  end;
end;

function calc_file_saveCsv(h: DWORD): PHiValue; stdcall;
var
  name:String;
begin
  name := getArgStr(h, 0);
  Result := nil;
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');
  ooo.SaveToCsv(name);
end;

function calc_setCell(h: DWORD): PHiValue; stdcall;
var
  cell: string;
  v: string;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');
  cell := getArgStr(h, 0, True);
  v    := getArgStr(h, 1);
  ooo.setCellByName(cell, v);
end;

function calc_getCell(h: DWORD): PHiValue; stdcall;
var
  cell: string;
  v: string;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');
  cell := getArgStr(h, 0, True);
  v := ooo.getCell(cell);
  Result := hi_newStr(v);
end;

function calc_setCellEx(h: DWORD): PHiValue; stdcall;
var
  cell: string;
  v: string;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');
  cell := getArgStr(h, 0, True);
  v    := getArgStr(h, 1);
  ooo.setCellEx(cell, v);
end;


function calc_getCellEx(h: DWORD): PHiValue; stdcall;
var
  cell1, cell2: string;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');
  cell1 := getArgStr(h, 0, True);
  cell2 := getArgStr(h, 1);
  Result:= hi_newStr(ooo.getCellEx(cell1, cell2));
end;

function calc_select(h: DWORD): PHiValue; stdcall;
var
  cell: string;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');
  cell := getArgStr(h, 0, True);
  ooo.selectRange(cell);
end;


function calc_copy(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');
  ooo.copySelection;
end;

function calc_paste(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');
  ooo.paste;
end;

function calc_color(h: DWORD): PHiValue; stdcall;
var
  v: PHiValue;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');
  v := nako_getFuncArg(h, 0);
  ooo.CellColor(hi_int(v));
end;


function calc_sheet_printPreview(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');
  ooo.sheetPrintPreview;
end;
function calc_printOut(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');
  ooo.print(1);
end;
function calc_workbook_close(h: DWORD): PHiValue; stdcall;
//var
//  book: string;
begin
  Result := nil;
  //book := getArgStr(h, 0, True);
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');
  ooo.CloseDocument;
end;
function calc_selectall(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');
  ooo.selectAll;
end;
function calc_file_saveToPDF(h: DWORD): PHiValue; stdcall;
var
  f: string;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('���߂ɁuCALC�N���v���߂ŋN������K�v������܂��B');
  f := getArgStr(h, 0, True);
  ooo.SaveToPDF(f);
end;

function ooo_checkInstall(h: DWORD): PHiValue; stdcall;
var
  reg: TRegistry;
  b: Boolean;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CLASSES_ROOT;
    b := reg.OpenKeyReadOnly('\com.sun.star.ServiceManager');
    if b then reg.CloseKey;
  finally
    FreeAndNil(reg);
  end;
  Result := hi_newBool(b);
end;

var oow:TOpenOfficeorg = nil;
var oow_visible:Boolean = true;

function writer_open(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  FreeAndNil(oow);
  oow := TOpenOfficeorg.Create;
  oow_visible := getArgBool(h, 0);
  if not oow.Connect then raise Exception.Create('OpenOffice.org���N���ł��܂���ł����B');
  Result := nil;
end;
function writer_close(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('���߂ɁuWRITER�N���v���߂ŋN������K�v������܂��B');
  FreeAndNil(oow);
end;
function writer_save(h: DWORD): PHiValue; stdcall;
var
  f: string;
  ext: string;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('���߂ɁuWRITER�N���v���߂ŋN������K�v������܂��B');
  f := getArgStr(h, 0);
  ext := LowerCase(ExtractFileExt(f));
  if ext = '.pdf' then
  begin
    oow.SaveToPDF(f);
  end else
  begin
    oow.SaveDocument(f, OO_FORMAT_WORD);
  end;
end;
function writer_saveToPDF(h: DWORD): PHiValue; stdcall;
var
  f: string;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('���߂ɁuWRITER�N���v���߂ŋN������K�v������܂��B');
  f := getArgStr(h, 0);
  oow.SaveToPDF(f);
end;
function writer_load(h: DWORD): PHiValue; stdcall;
var
  f: string;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('���߂ɁuWRITER�N���v���߂ŋN������K�v������܂��B');
  f := getArgStr(h, 0);
  oow.OpenDocument(f, not oow_visible);
end;
function writer_new(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('���߂ɁuWRITER�N���v���߂ŋN������K�v������܂��B');
  oow.NewDocumentWriter(not oow_visible);
end;
function writer_bookmark(h: DWORD): PHiValue; stdcall;
var
  s, v: string;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('���߂ɁuWRITER�N���v���߂ŋN������K�v������܂��B');
  s := getArgStr(h, 0);
  v := getArgStr(h, 1);
  oow.InsertBookmarkWriter(s, v);
end;
function writer_printPreview(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('���߂ɁuWRITER�N���v���߂ŋN������K�v������܂��B');
  oow.sheetPrintPreview;
end;
function writer_print(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('���߂ɁuWRITER�N���v���߂ŋN������K�v������܂��B');
  oow.print(1);
end;
function writer_getText(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('���߂ɁuWRITER�N���v���߂ŋN������K�v������܂��B');
  Result := hi_newStr(oow.writer_getText);
end;

//  AddFunc  ('WRITER���͒ǉ�','{=?}S��', 4840, writer_addText,'����S��ǉ�����B','WRITER�Ԃ񂵂傤����');
function writer_addText(h: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('���߂ɁuWRITER�N���v���߂ŋN������K�v������܂��B');
  s := getArgStr(h, 0, True);
  oow.InsertTextWriter(s);
end;
function writer_docClose(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('���߂ɁuWRITER�N���v���߂ŋN������K�v������܂��B');
  oow.CloseDocument;
end;

//------------------------------------------------------------------------------
procedure RegistFunction;
begin
  //todo: ���߂̒ǉ�
  //<����>
  //+MS Office�A�g(nakooffice.dll)
  //-�G�N�Z��(Excel)
  AddFunc  ('�G�N�Z���N��','{=1}A��', 4300, excel_open, '��A(�I�����I�t)�ŃG�N�Z�����N������','�������邫�ǂ�');
  AddFunc  ('�G�N�Z���I��','', 4301, excel_close,'�N�������G�N�Z�����I������','�������邵�イ��傤');
  AddFunc  ('�G�N�Z���V�K�u�b�N','', 4302, excel_workbooks_add,'�V�K�u�b�N�����','�������邵�񂫂Ԃ���');
  AddFunc  ('�G�N�Z���V�K�V�[�g','', 4303, excel_worksheet_add,'�V�K�V�[�g��ǉ�����','�������邵�񂫂��[��');
  AddFunc  ('�G�N�Z���J��','S��|S����|S��', 4304, excel_file_open,'�t�@�C��S����t�@�C�����J���B','��������Ђ炭');
  AddFunc  ('�G�N�Z���ۑ�','S��|S��', 4305, excel_file_save,'�t�@�C���r�փt�@�C����ۑ�����','��������ق���');
  AddFunc  ('�G�N�Z���V�[�g����','A��|A��|A��', 4306, excel_worksheet_active,'A�Ԗ�(1�`n)�܂��͖��OA�̃V�[�g���A�N�e�B�u�ɂ���','�������邵�[�Ƃ��イ����');
  AddFunc  ('�G�N�Z���u�b�N����','A��|A��|A��', 4307, excel_workbook_active,'A�Ԗ�(1�`n)�̃u�b�N���A�N�e�B�u�ɂ���','��������Ԃ������イ����');
  AddFunc  ('�G�N�Z��CSV�ۑ�','S��|S��', 4308, excel_file_saveCsv,'�t�@�C���r�փt�@�C����CSV�`���ŕۑ�����','��������CSV�ق���');
  AddFunc  ('�G�N�Z��TSV�ۑ�','S��|S��', 4309, excel_file_saveTsv,'�t�@�C���r�փt�@�C����TSV�`���ŕۑ�����','��������TSV�ق���');
  AddFunc  ('�G�N�Z��PDF�ۑ�','S��|S��', 4731, excel_file_savePDF,'�t�@�C���r�փt�@�C����PDF�`���ŕۑ�����','��������PDF�ق���');
  AddFunc  ('�G�N�Z���Z���ݒ�','CELL��V��|CELL��', 4310, excel_setCell,'�Z��A(A1~)��V��ݒ肷��','�������邹�邹���Ă�');
  AddFunc  ('�G�N�Z���Z���擾','CELL��|CELL��', 4311, excel_getCell,'�Z��A(A1~)���擾���ĕԂ�','�������邹�邵��Ƃ�');
  AddFunc  ('�G�N�Z���ꊇ�ݒ�','CELL��V��|CELL��', 4312, excel_setCellEx,'�Z��(A1~)�֓񎟌��z��V���ꊇ�ݒ肷��','�������邹�邢���������Ă�');
  AddFunc  ('�G�N�Z���ꊇ�擾','C1����C2�܂�|C2�܂ł�|C2��', 4313, excel_getCellEx,'�Z��C1(A1~)����C2�܂ł̃Z�����ꊇ�擾���ĕԂ��B','�������邹�邢��������Ƃ�');
  AddFunc  ('�G�N�Z���I��','CELL��|CELL��|CELL��', 4314, excel_select,'�Z��(A1~)��I������BA1:C4�̂悤�ɔ͈͎w����\�B','�������邹�񂽂�');
  AddFunc  ('�G�N�Z���R�s�[','', 4315, excel_copy,'�I������Ă���Z�����R�s�[����B','�������邱�ҁ[');
  AddFunc  ('�G�N�Z���\��t��','', 4316, excel_paste,'�I������Ă���Z���փN���b�v�{�[�h����\��t������B','��������͂��');
  AddFunc  ('�G�N�Z�����F','V��|V��|V��|V��', 4317, excel_color,'�I������Ă���Z����FV�Œ��F����B','�������邿�Ⴍ���傭');
  AddFunc  ('�G�N�Z���}�N�����s','A��{=?}B��', 4318, excel_macro,'�}�N��A������B�Ŏ��s�B�֐��Ȃ猋�ʂ�Ԃ��B','��������܂��낶������');
  AddFunc  ('�G�N�Z���V�[�g����v���r���[','', 4319, excel_sheet_printPreview,'�A�N�e�B�u�ȃV�[�g������v���r���[����','�������邵�[�Ƃ��񂳂Ղ�т�[');
  AddFunc  ('�G�N�Z���V�[�g���','', 4320, excel_sheet_printOut,'�A�N�e�B�u�ȃV�[�g���������','�������邵�[�Ƃ��񂳂�');
  AddFunc  ('�G�N�Z���u�b�N����v���r���[','', 4321, excel_book_printPreview,'�A�N�e�B�u�ȃ��[�N�u�b�N������v���r���[����','��������Ԃ������񂳂Ղ�т�[');
  AddFunc  ('�G�N�Z���u�b�N���','', 4322, excel_book_printOut,'�A�N�e�B�u�ȃ��[�N�u�b�N���������','��������Ԃ������񂳂�');
  AddFunc  ('�G�N�Z�����ύX','A��', 4323, excel_setVisible,'�G�N�Z���̉����I��(=1)���I�t(=0)�ɕύX����B','�������邩���ւ񂱂�');
  AddFunc  ('�G�N�Z���u�b�N����','{=?}BOOK��', 4324, excel_workbook_close,'���[�N�u�b�NBOOK�����BBOOk���ȗ�����ƃA�N�e�B�u�ȃu�b�N�����B(�ۑ����邩�ǂ������[�U�[�ɐq�˂�)','��������Ԃ����Ƃ���');
  AddFunc  ('�G�N�Z���u�b�N���擾','', 4714, excel_getActiveBookName, '�A�N�e�B�u�ȃu�b�N���m�F���ĕ������Ԃ�','��������Ԃ����߂�����Ƃ�');
  AddFunc  ('�G�N�Z���V�[�g���擾','', 4715, excel_getActiveSheetName, '�A�N�e�B�u�ȃV�[�g���m�F���ĕ������Ԃ�','�������邵�[�Ƃ߂�����Ƃ�');
  AddFunc  ('�G�N�Z���S�I��','', 4325, excel_selectall,'�Z���S�Ă�I������B','�������邺�񂹂񂽂�');
  AddFunc  ('�G�N�Z���I��͈͒u��','A����B��|A��B��', 4326, excel_selectReplace,'�I��͈͂̃Z���ɂ���A��B�ɒu������B','�������邹�񂽂��͂񂢂�����');
  AddFunc  ('�G�N�Z���I���s�����ݒ�','V��|V��', 4327, excel_setCellHeight,'�I��͈͂̃Z���̍�����ݒ肷��B','�������邹�񂽂����傤�����������Ă�');
  AddFunc  ('�G�N�Z���I��񕝐ݒ�','V��|V��', 4328, excel_setCellWidth,'�I��͈͂̃Z���̕���ݒ肷��B','�������邹�񂽂���͂΂����Ă�');
  AddFunc  ('�G�N�Z���u�b�N�ۑ������','{=""}BOOK��', 4700, excel_workbook_close_save,  '���[�N�u�b�NBOOK���㏑���ۑ����ĕ���B','��������Ԃ����ق��񂲂Ƃ���');
  AddFunc  ('�G�N�Z���u�b�N��ۑ�����','{=""}BOOK��', 4701, excel_workbook_close_nosave,'���[�N�u�b�NBOOK���㏑���ۑ����Ȃ��ŕ���B','��������Ԃ����Ђق���Ƃ���');
  AddFunc  ('�G�N�Z���V�[�g��','', 4702, excel_enumSheets,'�V�[�g�̈ꗗ���擾���ĕԂ�','�������邵�[�Ƃ������');
  AddFunc  ('�G�N�Z���L�[���M','KEYS��|KEYS��', 4703, excel_sendKeys,'���݊J���Ă���Excel�E�B���h�E�ɃL�[�𑗐M����B','�������邫�[��������');
  AddFunc  ('�G�N�Z���V�[�g�R�s�[','SHEET��NEWSHEET��', 4704, excel_sheetcopy,'Excel�̃V�[�gSHEET�𕡐�����NEWSHEET�Ƃ���','�������邵�[�Ƃ��ҁ[');
  AddFunc  ('�G�N�Z���V�[�g���O�ύX','NAME��NEWNAME��|NAME����NEWNAME��', 4705, excel_sheetrename,'Excel�̃V�[�gNAME�̖��O��NEWNAME�֕ύX����','�������邵�[�ƂȂ܂��ւ񂱂�');
  AddFunc  ('�G�N�Z���Z�����擾','ROW,COL��|ROW,COL��', 4706, excel_cellname,'Excel�̃Z�������sROW,��COL����uA1�v��uC5�v�̂悤�ȃZ�������v�Z���܂��BCELL(ROW,COL)�ł������BROW,COL��1�N�_�Ő����邱�ƁB','�������邹��߂�����Ƃ�');
  AddFunc  ('CELL','ROW,COL', 4707, excel_cellname,'Excel�̃Z�������sROW,��COL����uA1�v��uC5�v�̂悤�ȃZ�������v�Z���܂��B�G�N�Z���Z�����擾�������BROW,COL��1�N�_�Ő����邱�ƁB','CELL');
  AddFunc  ('�G�N�Z���o�[�W����','', 4709, excel_getVersion,'Excel�̃o�[�W��������Ԃ��B(9:Excel2000,10:2002,11:2003,12:2007)','��������΁[�����');
  AddFunc  ('�G�N�Z���d���폜','{=A}COL��|COL��', 4710, excel_uniqueRow,'Excel�̗�COL(ABC..)���L�[�ɂ��ďd�����Ă���s���폜����','�������邶�イ�ӂ���������');
  AddFunc  ('�G�N�Z�������ǂݎ擾','{=?}S��|S��', 4711, excel_yomi,'Excel�𗘗p���Ċ����̂�݂��Ȃ��擾����','�������邩�񂶂�݂���Ƃ�');
  AddFunc  ('�G�N�Z�������ǂ݌��擾','{=?}S��|S��', 4712, excel_yomiAll,'Excel�𗘗p���Ċ����̂�݂��Ȃ̌���S�Ď擾����','�������邩�񂶂�݂����ق���Ƃ�');
  AddFunc  ('�G�N�Z���Z���ǂݎ擾','{=?}CELL��', 4716, excel_cell_yomi,'Excel�̎w��CELL�ɂ��銿���̃��~�K�i���擾����','�������邹���݂���Ƃ�');
  AddFunc  ('�G�N�Z���I���s�擾','', 4717, excel_getSelectionRow,'Excel�őI�����Ă���s�𓾂ĕԂ�','�������邹�񂽂����傤����Ƃ�');
  AddFunc  ('�G�N�Z���I���擾','', 4718, excel_getSelectionCol,'Excel�őI�����Ă����𓾂ĕԂ�','�������邹�񂽂������Ƃ�');
  AddFunc  ('�G�N�Z���V�[�g�폜','{=?}SHEET��|SHEET��', 4719, excel_deleteSheet,'Excel�ŃV�[�g��SHEET���폜���āA�����������ǂ�����^�U�l�ŕԂ�','�������邵�[�Ƃ�������');
  AddFunc  ('�G�N�Z���s�}��','{=?}ROW��|ROW��', 4720, excel_insertRow,'Excel��ROW(�Ⴆ��3)�Ԗڂ̍s�ɋ�s��}������','�������邬�傤�����ɂイ');
  AddFunc  ('�G�N�Z����}��','{=?}COLNAME��|COLNAME��', 4721, excel_insertCol,'Excel��COLNAME(�Ⴆ��F)�ɋ���}������','�������������ɂイ');
  AddFunc  ('�G�N�Z���C���X�g�[���`�F�b�N','', 4713, excel_checkInstall, 'Microsoft Excel���C���X�g�[������Ă��邩�m�F���Ă͂�(=1)��������(=0)��Ԃ�','�������邢�񂷂Ɓ[�邿������');
  AddFunc  ('�G�N�Z���x������','', 4722, excel_displayAlertsOff, 'Excel�̌x���_�C�A���O�̕\��(DisplayAlerts)��}������','�������邯�������ނ�');
  AddFunc  ('�G�N�Z���x���L��','', 4727, excel_displayAlertsOn,  'Excel�̌x���_�C�A���O�̕\��(DisplayAlerts)��L���ɂ���','�������邯�������䂤����');
  AddFunc  ('�G�N�Z���V�[�g�����ړ�','SHEET��', 4723, excel_moveSheetLast, 'Excel��SHEET���u�b�N�̖����Ɉړ�����','�������邵�[�Ƃ܂т��ǂ�');
  AddFunc  ('�G�N�Z���V�[�g�擪�ړ�','SHEET��', 4724, excel_moveSheetTop, 'Excel��SHEET���u�b�N�̐擪�Ɉړ�����','�������邵�[�Ƃ���Ƃ����ǂ�');
  AddFunc  ('�G�N�Z���V�[�g�ی�','SHEET��PASSWORD��', 4725, excel_protect_on, 'Excel��SHEET�̕ی�@�\��PASSWORD�t���ŃI���ɂ���','�������邵�[�Ƃق�');
  AddFunc  ('�G�N�Z���V�[�g�ی����','SHEET��PASSWORD��', 4726, excel_protect_off, 'Excel��SHEET�̕ی��PASSWORD�ŉ�������','�������邵�[�Ƃق���������');
  AddFunc  ('�G�N�Z���I��͈̓}�[�W','', 4728, excel_selection_merge,'�I������Ă���Z�����}�[�W����B','�������邹�񂽂��͂񂢂܁[��');
  AddFunc  ('�G�N�Z���I��͈͍��E�z�u�ݒ�','V��|V��', 4729, excel_selection_align,'�I������Ă���Z�����A���E�E�E�����Ɋ񂹂�','�������邹�񂽂��͂񂢂��䂤�͂��������Ă�');
  AddFunc  ('�G�N�Z���I��͈͏㉺�z�u�ݒ�','V��|V��', 4730, excel_selection_valign,'�I������Ă���Z�����A��E���E�����Ɋ񂹂�','�������邹�񂽂��͂񂢂��傤���͂��������Ă�');
  AddFunc  ('�G�N�Z���ŉ��s�擾','{=A}COL��|COL��', 4708, excel_getLastRow,'Excel�̗�COL(ABC..�Ŏw��)�̍ŉ��s�𒲂ׂĕԂ��B','�������邳�������傤����Ƃ�');
  AddFunc  ('�G�N�Z���ŉE��擾','{=1}ROW��|ROW��', 4732, excel_getLastCol,'Excel�̍s�ԍ�ROW(123..�Ŏw��)�̍ŉE��𒲂ׂĕԂ��B','�������邳���������Ƃ�');
  AddFunc  ('�G�N�Z���摜�}��','F��', 4733, excel_insertPic,'Excel�̑I�𒆃Z���̏ꏊ�ɉ摜F��}������B','�������邪���������ɂイ');
  AddFunc  ('�G�N�Z���I���V�F�C�v�T�C�Y�ݒ�','W,H��|H��', 4734, excel_shapeResize,'Excel�̑I�𒆃V�F�C�v�̃T�C�Y��W,H�ɕύX����B','�������邹�񂽂��������Ղ��������������Ă�');
  AddFunc  ('�G�N�Z���I���V�F�C�v�ړ�','X,Y��|Y��', 4735, excel_shapeMove,'Excel�̑I�𒆃V�F�C�v�̈ʒu��X,Y�ɕύX����B','�������邹�񂽂��������Ղ��ǂ�');
  AddFunc  ('�G�N�Z���V�F�C�v�I��','{=?}S��', 4737, excel_selectShape,'Excel�Ŗ��OS�̃V�F�C�v��I������B','�������邵�����Ղ��񂽂�');
  AddFunc  ('�G�N�Z���摜�����N�}��','F��', -1, excel_insertPicLink,'Excel�̑I�𒆃Z���̏ꏊ�ɉ摜F�������N�ő}������B','�������邪������񂭂����ɂイ');
  AddFunc  ('�G�N�Z���s�폜','{=?}ROW��|ROW����', 4738, excel_deleteRow,'Excel��ROW(�Ⴆ��3)�Ԗڂ̍s���폜����B','�������邬�傤��������');
  AddFunc  ('�G�N�Z����폜','{=?}COLNAME��|COLNAME����', 4739, excel_deleteCol,'Excel��COLNAME(�Ⴆ��F)���폜����B','����������������');

  //-���[�h(Word)
  AddFunc  ('���[�h�N��','{=1}A��', 4330, word_open,'��A(�I�����I�t)�Ń��[�h���N������','��[�ǂ��ǂ�');
  AddFunc  ('���[�h�I��','', 4331, word_close,'���[�h���I������','��[�ǂ��イ��傤');
  AddFunc  ('���[�h�ۑ�','F��|F��', 4332, word_save,'���[�h����F��ۑ�����','��[�ǂق���');
  AddFunc  ('���[�h�J��','F��|F��|F��', 4333, word_load,'���[�h����F���Ђ炭','��[�ǂЂ炭');
  AddFunc  ('���[�h�V�K����','', 4334, word_new,'�V�K���[�h���������','��[�ǂ��񂫂Ԃ񂵂�');
  AddFunc  ('���[�h�u�b�N�}�[�N�}��','S��V��|S��', 4335, word_bookmark,'�u�b�N�}�[�NS�ɒlV��}������','��[�ǂԂ����܁[�������ɂイ');
  AddFunc  ('���[�h�u�b�N�}�[�N�擾','S��|S����', 4345, word_bookmark_get,'�u�b�N�}�[�NS����l���擾����','��[�ǂԂ����܁[������Ƃ�');
  AddFunc  ('���[�h����v���r���[','', 4336, word_printPreview,'����v���r���[��\������','��[�ǂ��񂳂Ղ�т�[');
  AddFunc  ('���[�h���','', 4337, word_print,'���[�h�ň������','��[�ǂ��񂳂�');
  AddFunc  ('���[�h�}�N�����s','A��{=?}B��', 4338, word_macro,'���[�h�̃}�N��A������B�Ŏ��s���֐��Ȃ�l��Ԃ��B','��[�ǂ܂��낶������');
  AddFunc  ('���[�h�{���擾','', 4339, word_getText,'���[�h�̖{�����e�L�X�g�œ��ĕԂ�','��[�ǂق�Ԃ񂵂�Ƃ�');
  AddFunc  ('���[�h���͒ǉ�','{=?}S��', 4340, word_addText,'���[�h�ɕ���S��ǉ�����B','��[�ǂԂ񂵂傤����');
  AddFunc  ('���[�h��������','', 4341, word_docClose,'�A�N�e�B�u�ȃ��[�h���������','��[�ǂԂ񂵂�Ƃ���');
  AddFunc  ('���[�h���ύX','A��', 4342, word_setVisible,'���[�h�̉����I��(=1)���I�t(=0)�ɕύX����B','��[�ǂ����ւ񂱂�');
  AddFunc  ('���[�h�u��','A��B��|A����B��', 4343, word_replace,'���[�h�̕��͒��̕�����A��B�ɒu������B','��[�ǂ�����');
  AddFunc  ('���[�h�C���X�g�[���`�F�b�N','', 4344, word_checkInstall, 'Microsoft Wordl���C���X�g�[������Ă��邩�m�F���Ă͂�(=1)��������(=0)��Ԃ�','��[�ǂ��񂷂Ɓ[�邿������');

  //-�p���|(PowerPoint)
  AddFunc  ('�p���|�N��','{=1}A��', 4750, ppt_open,'��A(�I�����I�t)��PowerPoint���N������','�ς�ۂ��ǂ�');
  AddFunc  ('�p���|�I��','', 4751, ppt_close,'PowerPoint���I������','�ς�ۂ��イ��傤');
  AddFunc  ('�p���|�X���C�h�V���[�J�n','', 4752, ppt_slide_start,'PowerPoint�̃X���C�h���n�߂�','�ς�ۂ��炢�ǂ���[������');
  AddFunc  ('�p���|�y�[�W����','', 4753, ppt_slide_next,'PowerPoint�̃X���C�h�����Ɉړ�','�ς�ۂ؁[������');
  AddFunc  ('�p���|�y�[�W�O��','', 4754, ppt_slide_prev,'PowerPoint�̃X���C�h��O�Ɉړ�','�ς�ۂ؁[���܂���');
  AddFunc  ('�p���|�X���C�h�V���[�I��','', 4755, ppt_slide_end,'PowerPoint�̃X���C�h���I���','�ς�ۂ��炢�ǂ���[���イ��傤');
  AddFunc  ('�p���|�J��','FILE��|FILE��', 4756, ppt_open_file,'PowerPoint�̃t�@�C�����J��','�ς�ۂЂ炭');
  AddFunc  ('�p���|�}�N�����s','M��ARG��|M��', 4757, ppt_macro,'PowerPoint�̃}�N��M������ARG�Ŏ��s����','�ς�ۂ܂��낶������');
  AddFunc  ('�p���|�C���X�g�[���`�F�b�N','', 4758, ppt_checkInstall, 'Microsoft PowerPoint���C���X�g�[������Ă��邩�m�F���Ă͂�(=1)��������(=0)��Ԃ�','�ς�ۂ��񂷂Ɓ[�邿������');
  AddFunc  ('�p���|JPEG�o��','DIR��', 4759, ppt_save_jpegfile,'PowerPoint�̃X���C�h��JPEG�`���ŏo�͂���','�ς��JPEG�����傭');
  AddFunc  ('�p���|PNG�o��','DIR��', 4760, ppt_save_pngfile,'PowerPoint�̃X���C�h��PNG�`���ŏo�͂���','�ς��PNG�����傭');
  AddFunc  ('�p���|PDF�o��','FILE��|FILE��', 4761, ppt_save_pdffile,'PowerPoint�̃X���C�h��PDF�`���ŏo�͂���','�ς��PDF�����傭');

  //+�f�[�^�x�[�X�A�g(nakooffice.dll)
  //-ADO.�f�[�^�x�[�X
  AddFunc  ('ACCESS�J��','{=?}F��|F��', 4650, ado_open_access,'ACCESS(2000/2003)�̃f�[�^�x�[�XF���J��','ACCESS�Ђ炭');
  AddFunc  ('ACCESS2007�J��','{=?}F��|F��', 4797, ado_open_access2007,'ACCESS2007�̃f�[�^�x�[�XF���J��','ACCESS2007�Ђ炭');
  AddFunc  ('ORACLE�J��','{=?}F��|F��', 4651, ado_open_oracle,'ORACLE�̃f�[�^�x�[�XF���J��','ORACLE�Ђ炭');
  AddFunc  ('MSSQL�J��', '{=?}F��|F��', 4652, ado_open_mssql,'MS SQL SERVER 2000�̃f�[�^�x�[�XF���J��','MSSQL�Ђ炭');
  AddFunc  ('SQLSERVER2005�J��','{=?}SERVER��DATABASE��|DATABASE��|DATABASE��', 4685, ado_open_sqlserver2005,'MS SQL SERVER 2005�̃f�[�^�x�[�X�Ɛڑ�����(�ϐ��uDB���[�U�[ID�v�ƁuDB�p�X���[�h�v���w��)','SQLSERVER�Ђ炭');
  AddFunc  ('ADO�J��','S��',            4671, ado_open_custom,'ADO�ڑ�������S���g���ăf�[�^�x�[�X���J���ăn���h����Ԃ�','ADO�Ђ炭');
  AddFunc  ('DB����','{=?}HANDLE��',          4653, ado_close,'HANDLE(�ȗ��\)���g���ăf�[�^�x�[�X�����B�n���h�������B','DB�Ƃ���');
  AddStrVar('DB���[�U�[ID', 'Admin',4654, '','DB��[���[ID');
  AddStrVar('DB�p�X���[�h', '',     4655, '','DB�ς���[��');
  AddFunc  ('SQL���s',  '{=?}HANDLE��S��|HANDLE��S��|S��',  4656, ado_sql,'HANDLE(�ȗ��\)���g����SQL��S�����s����B���ʂ́wDB���ʑS���擾�x�Ȃǂœ���B','SQL��������');
  AddFunc  ('DB����','{=?}HANDLE��|HANDLE��A��F����S��',4666, ado_find,'HANDLE(�ȗ��\)���g���ăe�[�u��A�̃t�B�[���hF����L�[���[�hS����������B���ʂ́wDB���ʑS���擾�x�Ȃǂœ���B','DB���񂳂�');
  AddFunc  ('DB�擪�ړ�','{=?}HANDLE��|HANDLE��|HANDLE��',        4657, ado_moveFirst,'HANDLE(�ȗ��\)���g���ă��R�[�h�̐擪�Ɉړ�','DB����Ƃ����ǂ�');
  AddFunc  ('DB�Ō�ړ�','{=?}HANDLE��|HANDLE��|HANDLE��',        4658, ado_moveLast, 'HANDLE(�ȗ��\)���g���ă��R�[�h�̍Ō�Ɉړ�(�T�|�[�g���ĂȂ����Ƃ�����)','DB���������ǂ�');
  AddFunc  ('DB���ړ�','{=?}HANDLE��|HANDLE��|HANDLE��',          4659, ado_moveNext, 'HANDLE(�ȗ��\)���g���ă��R�[�h�����Ɉړ�','DB�����ǂ�');
  AddFunc  ('DB�O�ړ�','{=?}HANDLE��|HANDLE��|HANDLE��',          4660, ado_movePrev, 'HANDLE(�ȗ��\)���g���ă��R�[�h��O�Ɉړ�','DB�܂����ǂ�');
  AddFunc  ('DB�擪����','{=?}HANDLE��|HANDLE��|HANDLE��',        4661, ado_bof,      'HANDLE(�ȗ��\)���g���ă��R�[�h���擪������','DB����Ƃ��͂�Ă�');
  AddFunc  ('DB�Ō㔻��','{=?}HANDLE��|HANDLE��|HANDLE��',        4662, ado_eof,      'HANDLE(�ȗ��\)���g���ă��R�[�h���Ōォ����','DB�������͂�Ă�');
  AddFunc  ('DB�t�B�[���h�擾','{=?}HANDLE��|HANDLE��S��',4663, ado_getField,'HANDLE(�ȗ��\)���g���Č��݂̃��R�[�h�̃t�B�[���hS�̒l���擾���ĕԂ��B','DB�ӂ��[��ǂ���Ƃ�');
  AddFunc  ('DB���ʑS���擾','{=?}HANDLE��|HANDLE��|HANDLE��',4664, ado_getAllCsv,'HANDLE(�ȗ��\)���g���đS���R�[�h��CSV�`���Ŏ擾����B','DB����������Ԃ���Ƃ�');
  AddFunc  ('DB����TSV�擾','{=?}HANDLE��|HANDLE��|HANDLE��',4665, ado_getAllTsv,'HANDLE(�ȗ��\)���g���đS���R�[�h��TSV�`���Ŏ擾����B','DB������TSV����Ƃ�');
  AddFunc  ('DB���R�[�h��','{=?}HANDLE��|HANDLE��|HANDLE��',4667, ado_recordCount,'HANDLE(�ȗ��\)���g���ă��R�[�h�����擾���ĕԂ��B(DB�v���o�C�_���T�|�[�g���Ă��Ȃ��Ƃ���-1��Ԃ�)','DB�ꂱ�[�ǂ���');
  AddFunc  ('DB�t�B�[���h���擾','{=?}HANDLE��|HANDLE��|HANDLE��',4668, ado_getFiledNames,'HANDLE(�ȗ��\)���g���ă��R�[�h�̃t�B�[���h���̈ꗗ����Ԃ��B','DB�ӂ��[��ǂ߂�����Ƃ�');
  AddFunc  ('DB���R�[�h�擾','{=?}HANDLE��|HANDLE��|HANDLE��',4669, ado_getRec,'HANDLE(�ȗ��\)���g���ăJ�����g���R�[�h��CSV�`���œ���B','DB�ꂱ�[�ǂ���Ƃ�');
  AddFunc  ('DB�e�[�u��CSV�擾','{=?}HANDLE��|HANDLE��S��|S����|S��',4670, ado_getTableAsCsv,'HANDLE(�ȗ��\)���g���ăe�[�u��S�̓��e��CSV�Ŏ擾���ĕԂ��B','DB�ā[�Ԃ�CSV����Ƃ�');
  //-SQLite�f�[�^�x�[�X
  AddFunc  ('SQLITE�J��','F��|F��|F��', 4680, sys_SQLiteOpen,'SQLite�f�[�^�x�[�X�t�@�C��F���J���ăn���h����Ԃ�','SQLITE�Ђ炭', 'sqlite.dll');
  AddFunc  ('SQLITE����','{=0}H��', 4681, sys_SQLiteClose,'�n���h��H(�ȗ��\)�ŊJ���Ă���SQLite�f�[�^�x�[�X�����','SQLITE�Ƃ���', 'sqlite.dll');
  AddFunc  ('SQLITE���s','{=0}H��SQL��|H��', 4682, sys_SQLiteExecute,'�n���h��H(�ȗ��\)�ŊJ���Ă���SQLite�f�[�^�x�[�X��SQL�������s���Č��ʂ�CSV�`���ŕԂ�','SQLITE��������', 'sqlite.dll');
  AddFunc  ('SQLITE�B������','{=0}H��TABLE��FIELD����S��', 4683, sys_SQLiteSearch,'�f�[�^�x�[�X�̃e�[�u��TABLE�Ńt�B�[���h��FIELD���當����S���܂ލs�����������ʂ�CSV�`���ŕԂ�','SQLITE�����܂����񂳂�', 'sqlite.dll');
  AddFunc  ('SQLITE����','{=0}H��TABLE��FIELD����S��', 4684, sys_SQLiteSearch2,'�f�[�^�x�[�X�̃e�[�u��TABLE�Ńt�B�[���h��FIELD��������S�ł���s�����������ʂ�CSV�`���ŕԂ�','SQLITE���񂳂�', 'sqlite.dll');
  AddFunc  ('SQLITE�e�[�u���쐬','{=0}H��TABLE��DEF��', 4790, sys_SQLiteCreateTable,'�f�[�^�x�[�X�̃e�[�u��TABLE���t�B�[���h��`DEF(��:ID,name,value)���쐬����B(�擪�̃t�B�[���h��PRIMARY KEY�ɂ���)','SQLITE�ā[�Ԃ邳������', 'sqlite.dll');
  AddFunc  ('SQLITE�e�[�u���폜','{=0}H��TABLE��', 4791, sys_SQLiteDropTable,'�f�[�^�x�[�X�̃e�[�u��TABLE���폜����B','SQLITE�ā[�Ԃ邳������', 'sqlite.dll');
  AddFunc  ('SQLITE�f�[�^�}��','{=0}H��TABLE��DATA��|TABLE��', 4792, sys_SQLiteInsert,'�f�[�^�x�[�X�̃e�[�u��TABLE�փf�[�^DATA(�n�b�V���`���Ŏw��)��}������','SQLITE�Ł[�������ɂイ', 'sqlite.dll');
  AddFunc  ('SQLITE�f�[�^�X�V','{=0}H��TABLE��WHERE��DATA��|DATA��', 4793, sys_SQLiteUpdate,'�f�[�^�x�[�X�̃e�[�u��TABLE�ɂ������WHERE�̃f�[�^(�n�b�V���`���Ŏw��)���X�V����','SQLITE�Ł[����������', 'sqlite.dll');
  AddFunc  ('SQLITE�f�[�^�폜','{=0}H��TABLE��WHERE��', 4794, sys_SQLiteDelete,'�f�[�^�x�[�X�̃e�[�u��TABLE�ɂ������WHERE�̃f�[�^���폜����','SQLITE�Ł[����������', 'sqlite.dll');
  AddFunc  ('SQLITE���}������ID','{=0}H��', 4795, sys_SQLiteGetLastId,'SQLite�ōŌ�ɑ}������ID���擾����','SQLITE���܂����ɂイ����ID', 'sqlite.dll');
  AddFunc  ('SQLITE�f�[�^�擾','{=0}H��TABLE����{=""}WHERE��|TABLE��', 4796, sys_SQLiteSelectAll,'�f�[�^�x�[�X�̃e�[�u��TABLE�ɂ���f�[�^��CSV�`���Ŏ擾���ĕԂ�','SQLITE�Ł[������Ƃ�', 'sqlite.dll');
  AddFunc  ('SQLITE�o�̓R�[�h�ݒ�','{=""}S��|S��|S��', 4798, sys_SQLiteSetEncode,'�f�[�^�x�[�X����f�[�^���擾���鎞�̕����R�[�h��ݒ肷��','SQLITE�����傭���[�ǂ����Ă�', 'sqlite.dll');
  //-SQLite3
  AddFunc  ('SQLITE3�J��',  'F��|F��|F��',      4851, sys_SQLite3Open,'SQLite3�f�[�^�x�[�X�t�@�C��F���J���ăn���h����Ԃ�','SQLITE3�Ђ炭', 'sqlite3.dll');
  AddFunc  ('SQLITE3����','{=0}H��',          4852, sys_SQLite3Close,'�n���h��H(�ȗ��\)�ŊJ���Ă���SQLite3�f�[�^�x�[�X�����','SQLITE3�Ƃ���', 'sqlite3.dll');
  AddFunc  ('SQLITE3���s',  '{=0}H��SQL��|H��', 4853, sys_SQLite3Execute,'�n���h��H(�ȗ��\)�ŊJ���Ă���SQLite3�f�[�^�x�[�X��SQL�������s���Č��ʂ�CSV�`���ŕԂ�(�uSQLITE3�����ϊ�=�I���v�𖾎����Ďg�����Ƃ𐄏�)','SQLITE3��������', 'sqlite3.dll');
  AddFunc  ('SQLITE3���}������ID','{=0}H��',    4854, sys_SQLite3GetLastId,'SQLite�ōŌ�ɑ}������ID���擾����','SQLITE���܂����ɂイ����ID', 'sqlite3.dll');
  AddFunc  ('SQLITE3�o�̓R�[�h�ݒ�','{=""}S��|S��|S��', 4855, sys_SQLite3SetEncode,'�f�[�^�x�[�X����f�[�^���擾���鎞�̕����R�[�h��ݒ肷��','SQLITE�����傭���[�ǂ����Ă�', 'sqlite3.dll');
  AddFunc  ('SQLITE3�ύX���擾','{=0}H��',      4856, sys_SQLite3TotalChanges,'SQLite�ōŌ�ɕύX�������R�[�h�����擾����','SQLITE3�ւ񂱂���������Ƃ�', 'sqlite3.dll');
  AddFunc  ('SQLITE3�C���X�g�[���`�F�b�N','', 4857, sys_sqlite3_checkInstall,'SQLite3���g���邩�ǂ����`�F�b�N����','SQLITE3���񂷂Ɓ[�邿������');
  AddIntVar('SQLITE3�����ϊ�', 0, 4858, 'SQLITE3���s��SQL���������I��UTF-8�ɕϊ����A���ʂ�SHIFT_JIS�ɕϊ�����','SQLITE3���ǂ��ւ񂩂�');

  //+OpenOffice.org�A�g(nakooffice.dll)
  //-CALC(OpenOffice.org)
  AddFunc  ('CALC�N��','{=1}A��', 4800, calc_open, '��A(�I�����I�t)��CALC���N������','CALC���ǂ�');
  AddFunc  ('CALC�I��','',        4801, calc_close,'�N������CALC���I������','CALC���イ��傤');
  AddFunc  ('CALC�V�K�u�b�N','',  4802, calc_workbooks_add,'�V�K�u�b�N�����','CALC���񂫂Ԃ���');
  AddFunc  ('CALC�V�K�V�[�g','',  4803, calc_worksheet_add,'�V�K�V�[�g��ǉ�����','CALC���񂫂��[��');
  AddFunc  ('CALC�J��','S��|S����|S��', 4804, calc_file_open,'�t�@�C��S����t�@�C�����J���B','CALC�Ђ炭');
  AddFunc  ('CALC�ۑ�','S��|S��', 4805, calc_file_save,'�t�@�C���r�փt�@�C����ۑ�����','CALC�ق���');
  AddFunc  ('CALC�V�[�g����','A��|A��|A��', 4806, calc_worksheet_active,'A�Ԗ�(0�`n)�܂��͖��OA�̃V�[�g���A�N�e�B�u�ɂ���','CALC���[�Ƃ��イ����');
  AddFunc  ('CALC_CSV�ۑ�','S��|S��', 4808, calc_file_saveCsv,'�t�@�C���r�փt�@�C����CSV�`���ŕۑ�����','CALC_CSV�ق���');
  AddFunc  ('CALC�Z���ݒ�','CELL��V��|CELL��', 4810, calc_setCell,'�Z��A(A1~)��V��ݒ肷��','CALC�����Ă�');
  AddFunc  ('CALC�Z���擾','CELL��|CELL��',    4811, calc_getCell,'�Z��A(A1~)���擾���ĕԂ�','CALC���邵��Ƃ�');
  AddFunc  ('CALC�ꊇ�ݒ�','CELL��V��|CELL��', 4812, calc_setCellEx,'�Z��(A1~)�֓񎟌��z��V���ꊇ�ݒ肷��','CALC�����������Ă�');
  AddFunc  ('CALC�ꊇ�擾','C1����C2�܂�|C2�܂ł�|C2��', 4813, calc_getCellEx,'�Z��C1(A1~)����C2�܂ł̃Z�����ꊇ�擾���ĕԂ��B','CALC����������Ƃ�');
  AddFunc  ('CALC�I��','CELL��|CELL��|CELL��', 4814, calc_select,'�Z��(A1~)��I������BA1:C4�̂悤�ɔ͈͎w����\�B','CALC���񂽂�');
  AddFunc  ('CALC�R�s�[','', 4815, calc_copy,'�I������Ă���Z�����R�s�[����B','CALC���ҁ[');
  AddFunc  ('CALC�\��t��','', 4816, calc_paste,'�I������Ă���Z���փN���b�v�{�[�h����\��t������B','CALC�͂��');
  AddFunc  ('CALC���F','V��|V��|V��|V��', 4817, calc_color,'�I������Ă���Z���Z����FV�Œ��F����B','CALC���Ⴍ���傭');
  AddFunc  ('CALC�V�[�g����v���r���[','', 4819, calc_sheet_printPreview,'�A�N�e�B�u�ȃV�[�g������v���r���[����','CALC���[�Ƃ��񂳂Ղ�т�[');
  AddFunc  ('CALC���','', 4820, calc_printOut,'�������','CALC���񂳂�');
  AddFunc  ('CALC�u�b�N����','{=?}BOOK��', 4824, calc_workbook_close,'���[�N�u�b�NBOOK�����BBOOk���ȗ�����ƃA�N�e�B�u�ȃu�b�N�����B(�ۑ����邩�ǂ������[�U�[�ɐq�˂�)','CALC�Ԃ����Ƃ���');
  AddFunc  ('CALC�S�I��','', 4825, calc_selectall,'�Z���S�Ă�I������B','CALC���񂹂񂽂�');
  AddFunc  ('CALC_PDF�ۑ�','S��|S��', 4826, calc_file_saveToPDF,'�t�@�C���r��PDF�`���ŕۑ�����','CALC_PDF�ق���');
  AddFunc  ('OPENOFFICE_ORG�C���X�g�[���`�F�b�N','', 4827, ooo_checkInstall,'OpenOffice.org���C���X�g�[������Ă��邩�m�F���Ă͂����������ŕԂ��B','OPENOFFICE_ORG���񂷂Ɓ[�邿������');
  //-WRITER(OpenOffice.org)
  AddFunc  ('WRITER�N��','{=1}A��', 4830, writer_open,'��A(�I�����I�t)��Writer���N������','WRITER���ǂ�');
  AddFunc  ('WRITER�I��','', 4831, writer_close,'Writer���I������','WRITER���イ���傤');
  AddFunc  ('WRITER�ۑ�','F��|F��', 4832, writer_save,'����F��ۑ�����','WRITER�ق���');
  AddFunc  ('WRITER�J��','F��|F��|F��', 4833, writer_load,'����F���Ђ炭','WRITER�Ђ炭');
  AddFunc  ('WRITER�V�K����','', 4834, writer_new,'�V�K���������','WRITER���񂫂Ԃ񂵂�');
  AddFunc  ('WRITER�u�b�N�}�[�N�}��','S��V��|S��', 4835, writer_bookmark,'�u�b�N�}�[�NS�ɒlV��}������','WRITER�Ԃ����܁[�������ɂイ');
  AddFunc  ('WRITER����v���r���[','', 4836, writer_printPreview,'����v���r���[��\������','WRITER���񂳂Ղ�т�[');
  AddFunc  ('WRITER���','', 4837, writer_print,'�������','WRITER���񂳂�');
  AddFunc  ('WRITER�{���擾','', 4839, writer_getText,'�{�����e�L�X�g�œ��ĕԂ�','WRITER�ق�Ԃ񂵂�Ƃ�');
  AddFunc  ('WRITER���͒ǉ�','{=?}S��', 4840, writer_addText,'����S��ǉ�����B','WRITER�Ԃ񂵂傤����');
  AddFunc  ('WRITER��������','', 4841, writer_docClose,'�A�N�e�B�u�ȕ��������','WRITER�Ԃ񂵂�Ƃ���');
  AddFunc  ('WRITER_PDF�ۑ�','F��|F��', 4842, writer_saveToPDF,'�t�@�C��F��PDF��ۑ�����','WRITER_PDF�ق���');
  //-nakooffice.dll
  AddFunc  ('NAKOOFFICE_DLL�o�[�W����','', 4850, getNakoOfficeVersion,'nakooffice.dll�̃o�[�W�����𓾂�','NAKOOFFICE_DLL�΁[�����');
  //</����>
end;

procedure PluginFin;
begin
  if _excel <> nil then FreeAndNil(_excel);
  if _word  <> nil then FreeAndNil(_word);
  if ado    <> nil then FreeAndNil(ado);
  if ooo    <> nil then FreeAndNil(ooo);
  if oow    <> nil then FreeAndNil(oow);
end;

initialization

finalization
  PluginFin;

end.
