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
  unit_sqlite3;

var
  _excel : TKExcel = nil;
  _word  : TKWord  = nil;
  ado   : TKAdo   = nil;
  ppt   : TKPowerPoint = nil;

function excel : TKExcel;
begin
  if _excel = nil then
  begin
    raise Exception.Create('エクセルが起動していません。『エクセル起動』命令で起動させてください。');
  end;
  Result := _excel;
end;

function word : TKWord;
begin
  if _word = nil then
  begin
    raise Exception.Create('ワードが起動していません。『ワード起動』命令で起動させてください。');
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
begin
  Result := nil;
  excel.WorkBookAdd;
end;

function excel_worksheet_add(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  excel.WorkSheetAdd;
end;

function excel_file_open(h: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  Result := nil;
  s := nako_getFuncArg(h, 0);
  excel.FileOpen(hi_str(s));
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
  if v = '右' then i := xlRight;
  if v = '左' then i := xlLeft;
  if Copy(v,1,2) = '中' then i := xlCenter;
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
  if v = '上' then i := xlTop;
  if v = '下' then i := xlBottom;
  if Copy(v,1,2) = '中' then i := xlCenter;
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
  if word = nil then raise Exception.Create('ワードが起動していません。『ワード起動』命令で起動させてください。');
  word.DocClose;
  Result := nil;
end;

function word_save(h: DWORD): PHiValue; stdcall;
var
  v: PHiValue;
begin
  v := nako_getFuncArg(h, 0);
  if word = nil then raise Exception.Create('ワードが起動していません。『ワード起動』命令で起動させてください。');
  word.FileSave(hi_str(v));
  Result := nil;
end;

function word_load(h: DWORD): PHiValue; stdcall;
var
  v: PHiValue;
begin
  v := nako_getFuncArg(h, 0);
  if word = nil then raise Exception.Create('ワードが起動していません。『ワード起動』命令で起動させてください。');
  word.FileOpen(hi_str(v));
  Result := nil;
end;

function word_new(h: DWORD): PHiValue; stdcall;
begin
  if word = nil then raise Exception.Create('ワードが起動していません。『ワード起動』命令で起動させてください。');
  word.NewDoc;
  Result := nil;
end;

function word_bookmark(h: DWORD): PHiValue; stdcall;
var
  s, v: PHiValue;
begin
  s := nako_getFuncArg(h, 0);
  v := nako_getFuncArg(h, 1);
  if word = nil then raise Exception.Create('ワードが起動していません。『ワード起動』命令で起動させてください。');
  word.BookmarkInsertText(hi_str(s), hi_str(v));
  Result := nil;
end;

function word_bookmark_get(h: DWORD): PHiValue; stdcall;
var
  bookmark: string;
begin
  bookmark := getArgStr(h, 0, True);
  if word = nil then raise Exception.Create('ワードが起動していません。『ワード起動』命令で起動させてください。');
  Result := hi_newStr(word.BookmarkGetText(bookmark));
end;

function word_printPreview(h: DWORD): PHiValue; stdcall;
begin
  if word = nil then raise Exception.Create('ワードが起動していません。『ワード起動』命令で起動させてください。');
  word.PrintPreview;
  Result := nil;
end;

function word_print(h: DWORD): PHiValue; stdcall;
begin
  if word = nil then raise Exception.Create('ワードが起動していません。『ワード起動』命令で起動させてください。');
  word.Print;
  Result := nil;
end;

function word_macro(h: DWORD): PHiValue; stdcall;
var
  a, b: PHiValue;
begin
  a := nako_getFuncArg(h, 0);
  b := nako_getFuncArg(h, 1);
  if word = nil then raise Exception.Create('ワードが起動していません。『ワード起動』命令で起動させてください。');
  Result := hi_newStr(word.MacroExec(hi_str(a), hi_str(b)));
end;

function word_getText(h: DWORD): PHiValue; stdcall;
begin
  if word = nil then raise Exception.Create('ワードが起動していません。『ワード起動』命令で起動させてください。');
  Result := hi_newStr(word.getAsText);
end;

function word_addText(h: DWORD): PHiValue; stdcall;
var
  v: PHiValue;
begin
  v := nako_getFuncArg(h, 0);
  if v = nil then v := nako_getSore;
  if word = nil then raise Exception.Create('ワードが起動していません。『ワード起動』命令で起動させてください。');
  word.InsertText(hi_str(v));
  Result := nil;
end;

function word_setVisible(h: DWORD): PHiValue; stdcall;
var
  v: PHiValue;
begin
  v := nako_getFuncArg(h, 0);
  if v = nil then v := nako_getSore;
  if word = nil then raise Exception.Create('ワードが起動していません。『ワード起動』命令で起動させてください。');
  word.Visible := hi_bool(v);
  Result := nil;
end;

function word_replace(h: DWORD): PHiValue; stdcall;
var
  a, b: string;
begin
  a := getArgStr(h, 0, True);
  b := getArgStr(h, 1);
  if word = nil then raise Exception.Create('ワードが起動していません。『ワード起動』命令で起動させてください。');
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
  if ppt = nil then raise Exception.Create('先に「パワポ」起動命令でPowerPointを起動してください。');
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
    hi_str(nako_getVariable('DBユーザーID')),
    hi_str(nako_getVariable('DBパスワード')));

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
    hi_str(nako_getVariable('DBユーザーID')),
    hi_str(nako_getVariable('DBパスワード')));

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
    hi_str(nako_getVariable('DBユーザーID')),
    hi_str(nako_getVariable('DBパスワード')));

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
    hi_str(nako_getVariable('DBユーザーID')),
    hi_str(nako_getVariable('DBパスワード')));

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
    hi_str(nako_getVariable('DBユーザーID')),
    hi_str(nako_getVariable('DBパスワード')));

  Result := hi_newInt(Integer(ado));
end;

function ado_getHandleFromArg(h: DWORD): TKAdo;
var
  p: PHiValue;
begin
  // 省略されたら最後に開いたＤＢを返す
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
  if ado = nil then raise Exception.Create('DBを操作する前にDBを開く必要があります。');
  ado.SQL(hi_str(s));
  Result := nil;
end;

function ado_moveFirst(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DBを操作する前にDBを開く必要があります。');
  ado.MoveFirst;
  Result := nil;
end;

function ado_moveLast(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DBを操作する前にDBを開く必要があります。');
  ado.MoveLast;
  Result := nil;
end;

function ado_moveNext(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DBを操作する前にDBを開く必要があります。');
  ado.MoveNext;
  Result := nil;
end;

function ado_movePrev(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DBを操作する前にDBを開く必要があります。');
  ado.MovePrev;
  Result := nil;
end;

function ado_bof(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DBを操作する前にDBを開く必要があります。');
  Result := hi_newBool(ado.dbBOF);
end;

function ado_eof(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DBを操作する前にDBを開く必要があります。');
  Result := hi_newBool(ado.dbEOF);
end;

function ado_getAllCsv(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DBを操作する前にDBを開く必要があります。');
  Result := hi_newStr(ado.GetSqlResultAsCsv);
end;

function ado_getAllTsv(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DBを操作する前にDBを開く必要があります。');
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
  if ado = nil then raise Exception.Create('DBを操作する前にDBを開く必要があります。');
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
  if ado = nil then raise Exception.Create('DBを操作する前にDBを開く必要があります。');

  Result := hi_newStr(ado.GetFieldValue(f));
end;

function ado_recordCount(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DBを操作する前にDBを開く必要があります。');
  Result := hi_newInt(ado.GetRecordCount);
end;

function ado_getFiledNames(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DBを操作する前にDBを開く必要があります。');
  Result := hi_newStr(ado.GetFieldNames);
end;

function ado_getRec(h: DWORD): PHiValue; stdcall;
var
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  if ado = nil then raise Exception.Create('DBを操作する前にDBを開く必要があります。');
  Result := hi_newStr(ado.GetCurRecAsCsv);
end;

function ado_getTableAsCsv(h: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  ado: TKAdo;
begin
  ado := ado_getHandleFromArg(h);
  p := nako_getFuncArg(h, 1);
  if ado = nil then raise Exception.Create('DBを操作する前にDBを開く必要があります。');
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
    raise Exception.Create('ハンドルが無効です。『SQLITE開く』命令でデータベースを開いてください。');
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
    raise Exception.Create('ハンドルが無効です。『SQLITE3開く』命令でデータベースを開いてください。');
  end;
end;


function sys_SQLiteOpen(args: DWORD): PHiValue; stdcall;
var
  f: string;
  h: TSqliteHandle;
begin
  // SQLite の初期化
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
    SqliteExecute(h, sql, res); // エラーは無視する
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
    // sqlite3 の初期化
    if not sqlite3_loaded then
    begin
      unit_sqlite3.sqlite3_init(FindDLLFile(SQLite3DLL));
    end;
    // データベースを開く
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
      raise Exception.CreateFmt('『SQLITE3開く』でデータベース「%s」が開けませんでした。%s',
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
  Result := hi_bool(nako_getVariable('SQLITE3自動変換'));
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
  if not ooo.Connect then raise Exception.Create('OpenOffice.org が起動できませんでした。');
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
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');
  ooo.NewDocumentCalc(not ooo_visible);
  ooo.SetActiveSheetByIndex(0);
end;

function calc_worksheet_add(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');
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
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');
  ooo.OpenDocument(name, not ooo_visible);
end;

function calc_file_save(h: DWORD): PHiValue; stdcall;
var
  name:String;
begin
  name := getArgStr(h, 0);
  Result := nil;
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');
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
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');

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
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');
  ooo.SaveToCsv(name);
end;

function calc_setCell(h: DWORD): PHiValue; stdcall;
var
  cell: string;
  v: string;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');
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
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');
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
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');
  cell := getArgStr(h, 0, True);
  v    := getArgStr(h, 1);
  ooo.setCellEx(cell, v);
end;


function calc_getCellEx(h: DWORD): PHiValue; stdcall;
var
  cell1, cell2: string;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');
  cell1 := getArgStr(h, 0, True);
  cell2 := getArgStr(h, 1);
  Result:= hi_newStr(ooo.getCellEx(cell1, cell2));
end;

function calc_select(h: DWORD): PHiValue; stdcall;
var
  cell: string;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');
  cell := getArgStr(h, 0, True);
  ooo.selectRange(cell);
end;


function calc_copy(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');
  ooo.copySelection;
end;

function calc_paste(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');
  ooo.paste;
end;

function calc_color(h: DWORD): PHiValue; stdcall;
var
  v: PHiValue;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');
  v := nako_getFuncArg(h, 0);
  ooo.CellColor(hi_int(v));
end;


function calc_sheet_printPreview(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');
  ooo.sheetPrintPreview;
end;
function calc_printOut(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');
  ooo.print(1);
end;
function calc_workbook_close(h: DWORD): PHiValue; stdcall;
//var
//  book: string;
begin
  Result := nil;
  //book := getArgStr(h, 0, True);
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');
  ooo.CloseDocument;
end;
function calc_selectall(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');
  ooo.selectAll;
end;
function calc_file_saveToPDF(h: DWORD): PHiValue; stdcall;
var
  f: string;
begin
  Result := nil;
  if ooo = nil then raise Exception.Create('初めに「CALC起動」命令で起動する必要があります。');
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
  if not oow.Connect then raise Exception.Create('OpenOffice.orgが起動できませんでした。');
  Result := nil;
end;
function writer_close(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('初めに「WRITER起動」命令で起動する必要があります。');
  FreeAndNil(oow);
end;
function writer_save(h: DWORD): PHiValue; stdcall;
var
  f: string;
  ext: string;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('初めに「WRITER起動」命令で起動する必要があります。');
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
  if oow = nil then raise Exception.Create('初めに「WRITER起動」命令で起動する必要があります。');
  f := getArgStr(h, 0);
  oow.SaveToPDF(f);
end;
function writer_load(h: DWORD): PHiValue; stdcall;
var
  f: string;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('初めに「WRITER起動」命令で起動する必要があります。');
  f := getArgStr(h, 0);
  oow.OpenDocument(f, not oow_visible);
end;
function writer_new(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('初めに「WRITER起動」命令で起動する必要があります。');
  oow.NewDocumentWriter(not oow_visible);
end;
function writer_bookmark(h: DWORD): PHiValue; stdcall;
var
  s, v: string;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('初めに「WRITER起動」命令で起動する必要があります。');
  s := getArgStr(h, 0);
  v := getArgStr(h, 1);
  oow.InsertBookmarkWriter(s, v);
end;
function writer_printPreview(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('初めに「WRITER起動」命令で起動する必要があります。');
  oow.sheetPrintPreview;
end;
function writer_print(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('初めに「WRITER起動」命令で起動する必要があります。');
  oow.print(1);
end;
function writer_getText(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('初めに「WRITER起動」命令で起動する必要があります。');
  Result := hi_newStr(oow.writer_getText);
end;

//  AddFunc  ('WRITER文章追加','{=?}Sを', 4840, writer_addText,'文章Sを追加する。','WRITERぶんしょうついか');
function writer_addText(h: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('初めに「WRITER起動」命令で起動する必要があります。');
  s := getArgStr(h, 0, True);
  oow.InsertTextWriter(s);
end;
function writer_docClose(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if oow = nil then raise Exception.Create('初めに「WRITER起動」命令で起動する必要があります。');
  oow.CloseDocument;
end;

//------------------------------------------------------------------------------
procedure RegistFunction;
begin
  //todo: 命令の追加
  //<命令>
  //+MS Office連携(nakooffice.dll)
  //-エクセル(Excel)
  AddFunc  ('エクセル起動','{=1}Aで', 4300, excel_open, '可視A(オンかオフ)でエクセルを起動する','えくせるきどう');
  AddFunc  ('エクセル終了','', 4301, excel_close,'起動したエクセルを終了する','えくせるしゅうりょう');
  AddFunc  ('エクセル新規ブック','', 4302, excel_workbooks_add,'新規ブックを作る','えくせるしんきぶっく');
  AddFunc  ('エクセル新規シート','', 4303, excel_worksheet_add,'新規シートを追加する','えくせるしんきしーと');
  AddFunc  ('エクセル開く','Sを|Sから|Sの', 4304, excel_file_open,'ファイルSからファイルを開く。','えくせるひらく');
  AddFunc  ('エクセル保存','Sへ|Sに', 4305, excel_file_save,'ファイルＳへファイルを保存する','えくせるほぞん');
  AddFunc  ('エクセルシート注目','Aの|Aに|Aを', 4306, excel_worksheet_active,'A番目(1～n)または名前Aのシートをアクティブにする','えくせるしーとちゅうもく');
  AddFunc  ('エクセルブック注目','Aの|Aに|Aを', 4307, excel_workbook_active,'A番目(1～n)のブックをアクティブにする','えくせるぶっくちゅうもく');
  AddFunc  ('エクセルCSV保存','Sへ|Sに', 4308, excel_file_saveCsv,'ファイルＳへファイルをCSV形式で保存する','えくせるCSVほぞん');
  AddFunc  ('エクセルTSV保存','Sへ|Sに', 4309, excel_file_saveTsv,'ファイルＳへファイルをTSV形式で保存する','えくせるTSVほぞん');
  AddFunc  ('エクセルPDF保存','Sへ|Sに', 4731, excel_file_savePDF,'ファイルＳへファイルをPDF形式で保存する','えくせるPDFほぞん');
  AddFunc  ('エクセルセル設定','CELLへVを|CELLに', 4310, excel_setCell,'セルA(A1~)へVを設定する','えくせるせるせってい');
  AddFunc  ('エクセルセル取得','CELLの|CELLを', 4311, excel_getCell,'セルA(A1~)を取得して返す','えくせるせるしゅとく');
  AddFunc  ('エクセル一括設定','CELLへVを|CELLに', 4312, excel_setCellEx,'セル(A1~)へ二次元配列Vを一括設定する','えくせるせるいっかつせってい');
  AddFunc  ('エクセル一括取得','C1からC2まで|C2までの|C2の', 4313, excel_getCellEx,'セルC1(A1~)からC2までのセルを一括取得して返す。','えくせるせるいっかつしゅとく');
  AddFunc  ('エクセル選択','CELLを|CELLに|CELLへ', 4314, excel_select,'セル(A1~)を選択する。A1:C4のように範囲指定も可能。','えくせるせんたく');
  AddFunc  ('エクセルコピー','', 4315, excel_copy,'選択されているセルをコピーする。','えくせるこぴー');
  AddFunc  ('エクセル貼り付け','', 4316, excel_paste,'選択されているセルへクリップボードから貼り付けする。','えくせるはりつけ');
  AddFunc  ('エクセル着色','Vを|Vで|Vの|Vに', 4317, excel_color,'選択されているセルを色Vで着色する。','えくせるちゃくしょく');
  AddFunc  ('エクセルマクロ実行','Aを{=?}Bで', 4318, excel_macro,'マクロAを引数Bで実行。関数なら結果を返す。','えくせるまくろじっこう');
  AddFunc  ('エクセルシート印刷プレビュー','', 4319, excel_sheet_printPreview,'アクティブなシートを印刷プレビューする','えくせるしーといんさつぷれびゅー');
  AddFunc  ('エクセルシート印刷','', 4320, excel_sheet_printOut,'アクティブなシートを印刷する','えくせるしーといんさつ');
  AddFunc  ('エクセルブック印刷プレビュー','', 4321, excel_book_printPreview,'アクティブなワークブックを印刷プレビューする','えくせるぶっくいんさつぷれびゅー');
  AddFunc  ('エクセルブック印刷','', 4322, excel_book_printOut,'アクティブなワークブックを印刷する','えくせるぶっくいんさつ');
  AddFunc  ('エクセル可視変更','Aに', 4323, excel_setVisible,'エクセルの可視をオン(=1)かオフ(=0)に変更する。','えくせるかしへんこう');
  AddFunc  ('エクセルブック閉じる','{=?}BOOKの', 4324, excel_workbook_close,'ワークブックBOOKを閉じる。BOOkを省略するとアクティブなブックを閉じる。(保存するかどうかユーザーに尋ねる)','えくせるぶっくとじる');
  AddFunc  ('エクセルブック名取得','', 4714, excel_getActiveBookName, 'アクティブなブック名確認して文字列を返す','えくせるぶっくめいしゅとく');
  AddFunc  ('エクセルシート名取得','', 4715, excel_getActiveSheetName, 'アクティブなシート名確認して文字列を返す','えくせるしーとめいしゅとく');
  AddFunc  ('エクセル全選択','', 4325, excel_selectall,'セル全てを選択する。','えくせるぜんせんたく');
  AddFunc  ('エクセル選択範囲置換','AからBへ|AをBに', 4326, excel_selectReplace,'選択範囲のセルにあるAをBに置換する。','えくせるせんたくはんいちかん');
  AddFunc  ('エクセル選択行高さ設定','Vに|Vへ', 4327, excel_setCellHeight,'選択範囲のセルの高さを設定する。','えくせるせんたくぎょうたかさせってい');
  AddFunc  ('エクセル選択列幅設定','Vに|Vへ', 4328, excel_setCellWidth,'選択範囲のセルの幅を設定する。','えくせるせんたくれつはばせってい');
  AddFunc  ('エクセルブック保存後閉じる','{=""}BOOKの', 4700, excel_workbook_close_save,  'ワークブックBOOKを上書き保存して閉じる。','えくせるぶっくほぞんごとじる');
  AddFunc  ('エクセルブック非保存閉じる','{=""}BOOKの', 4701, excel_workbook_close_nosave,'ワークブックBOOKを上書き保存しないで閉じる。','えくせるぶっくひほぞんとじる');
  AddFunc  ('エクセルシート列挙','', 4702, excel_enumSheets,'シートの一覧を取得して返す','えくせるしーとれっきょ');
  AddFunc  ('エクセルキー送信','KEYSの|KEYSを', 4703, excel_sendKeys,'現在開いているExcelウィンドウにキーを送信する。','えくせるきーそうしん');
  AddFunc  ('エクセルシートコピー','SHEETをNEWSHEETに', 4704, excel_sheetcopy,'ExcelのシートSHEETを複製してNEWSHEETとする','えくせるしーとこぴー');
  AddFunc  ('エクセルシート名前変更','NAMEをNEWNAMEに|NAMEからNEWNAMEへ', 4705, excel_sheetrename,'ExcelのシートNAMEの名前をNEWNAMEへ変更する','えくせるしーとなまえへんこう');
  AddFunc  ('エクセルセル名取得','ROW,COLの|ROW,COLで', 4706, excel_cellname,'Excelのセル名を行ROW,列COLから「A1」や「C5」のようなセル名を計算します。CELL(ROW,COL)でも同じ。ROW,COLは1起点で数えること。','えくせるせるめいしゅとく');
  AddFunc  ('CELL','ROW,COL', 4707, excel_cellname,'Excelのセル名を行ROW,列COLから「A1」や「C5」のようなセル名を計算します。エクセルセル名取得も同じ。ROW,COLは1起点で数えること。','CELL');
  AddFunc  ('エクセルバージョン','', 4709, excel_getVersion,'Excelのバージョン情報を返す。(9:Excel2000,10:2002,11:2003,12:2007)','えくせるばーじょん');
  AddFunc  ('エクセル重複削除','{=A}COLの|COLで', 4710, excel_uniqueRow,'Excelの列COL(ABC..)をキーにして重複している行を削除する','えくせるじゅうふくさくじょ');
  AddFunc  ('エクセル漢字読み取得','{=?}Sを|Sの', 4711, excel_yomi,'Excelを利用して漢字のよみがなを取得する','えくせるかんじよみしゅとく');
  AddFunc  ('エクセル漢字読み候補取得','{=?}Sを|Sの', 4712, excel_yomiAll,'Excelを利用して漢字のよみがなの候補を全て取得する','えくせるかんじよみこうほしゅとく');
  AddFunc  ('エクセルセル読み取得','{=?}CELLの', 4716, excel_cell_yomi,'Excelの指定CELLにある漢字のヨミガナを取得する','えくせるせるよみしゅとく');
  AddFunc  ('エクセル選択行取得','', 4717, excel_getSelectionRow,'Excelで選択している行を得て返す','えくせるせんたくぎょうしゅとく');
  AddFunc  ('エクセル選択列取得','', 4718, excel_getSelectionCol,'Excelで選択している列を得て返す','えくせるせんたくれつしゅとく');
  AddFunc  ('エクセルシート削除','{=?}SHEETを|SHEETの', 4719, excel_deleteSheet,'Excelでシート名SHEETを削除して、成功したかどうかを真偽値で返す','えくせるしーとさくじょ');
  AddFunc  ('エクセル行挿入','{=?}ROWに|ROWへ', 4720, excel_insertRow,'ExcelでROW(例えば3)番目の行に空行を挿入する','えくせるぎょうそうにゅう');
  AddFunc  ('エクセル列挿入','{=?}COLNAMEに|COLNAMEへ', 4721, excel_insertCol,'ExcelでCOLNAME(例えばF)に空列を挿入する','えくせるれつそうにゅう');
  AddFunc  ('エクセルインストールチェック','', 4713, excel_checkInstall, 'Microsoft Excelがインストールされているか確認してはい(=1)かいいえ(=0)を返す','えくせるいんすとーるちぇっく');
  AddFunc  ('エクセル警告無視','', 4722, excel_displayAlertsOff, 'Excelの警告ダイアログの表示(DisplayAlerts)を抑制する','えくせるけいこくむし');
  AddFunc  ('エクセル警告有効','', 4727, excel_displayAlertsOn,  'Excelの警告ダイアログの表示(DisplayAlerts)を有効にする','えくせるけいこくゆうこう');
  AddFunc  ('エクセルシート末尾移動','SHEETを', 4723, excel_moveSheetLast, 'ExcelのSHEETをブックの末尾に移動する','えくせるしーとまつびいどう');
  AddFunc  ('エクセルシート先頭移動','SHEETを', 4724, excel_moveSheetTop, 'ExcelのSHEETをブックの先頭に移動する','えくせるしーとせんとういどう');
  AddFunc  ('エクセルシート保護','SHEETをPASSWORDで', 4725, excel_protect_on, 'ExcelのSHEETの保護機能をPASSWORD付きでオンにする','えくせるしーとほご');
  AddFunc  ('エクセルシート保護解除','SHEETをPASSWORDで', 4726, excel_protect_off, 'ExcelのSHEETの保護をPASSWORDで解除する','えくせるしーとほごかいじょ');
  AddFunc  ('エクセル選択範囲マージ','', 4728, excel_selection_merge,'選択されているセルをマージする。','えくせるせんたくはんいまーじ');
  AddFunc  ('エクセル選択範囲左右配置設定','Vに|Vへ', 4729, excel_selection_align,'選択されているセルを、左・右・中央に寄せる','えくせるせんたくはんいさゆうはいちせってい');
  AddFunc  ('エクセル選択範囲上下配置設定','Vに|Vへ', 4730, excel_selection_valign,'選択されているセルを、上・下・中央に寄せる','えくせるせんたくはんいじょうげはいちせってい');
  AddFunc  ('エクセル最下行取得','{=A}COLの|COLで', 4708, excel_getLastRow,'Excelの列名COL(ABC..で指定)の最下行を調べて返す。','えくせるさいかぎょうしゅとく');
  AddFunc  ('エクセル最右列取得','{=1}ROWの|ROWで', 4732, excel_getLastCol,'Excelの行番号ROW(123..で指定)の最右列を調べて返す。','えくせるさいうれつしゅとく');

  //-ワード(Word)
  AddFunc  ('ワード起動','{=1}Aで', 4330, word_open,'可視A(オンかオフ)でワードを起動する','わーどきどう');
  AddFunc  ('ワード終了','', 4331, word_close,'ワードを終了する','わーどしゅうりょう');
  AddFunc  ('ワード保存','Fへ|Fに', 4332, word_save,'ワード文書Fを保存する','わーどほぞん');
  AddFunc  ('ワード開く','Fを|Fで|Fの', 4333, word_load,'ワード文書Fをひらく','わーどひらく');
  AddFunc  ('ワード新規文書','', 4334, word_new,'新規ワード文書を作る','わーどしんきぶんしょ');
  AddFunc  ('ワードブックマーク挿入','SにVを|Sへ', 4335, word_bookmark,'ブックマークSに値Vを挿入する','わーどぶっくまーくそうにゅう');
  AddFunc  ('ワードブックマーク取得','Sの|Sから', 4345, word_bookmark_get,'ブックマークSから値を取得する','わーどぶっくまーくしゅとく');
  AddFunc  ('ワード印刷プレビュー','', 4336, word_printPreview,'印刷プレビューを表示する','わーどいんさつぷれびゅー');
  AddFunc  ('ワード印刷','', 4337, word_print,'ワードで印刷する','わーどいんさつ');
  AddFunc  ('ワードマクロ実行','Aを{=?}Bで', 4338, word_macro,'ワードのマクロAを引数Bで実行し関数なら値を返す。','わーどまくろじっこう');
  AddFunc  ('ワード本文取得','', 4339, word_getText,'ワードの本文をテキストで得て返す','わーどほんぶんしゅとく');
  AddFunc  ('ワード文章追加','{=?}Sを', 4340, word_addText,'ワードに文章Sを追加する。','わーどぶんしょうついか');
  AddFunc  ('ワード文書閉じる','', 4341, word_docClose,'アクティブなワード文書を閉じる','わーどぶんしょとじる');
  AddFunc  ('ワード可視変更','Aに', 4342, word_setVisible,'ワードの可視をオン(=1)かオフ(=0)に変更する。','わーどかしへんこう');
  AddFunc  ('ワード置換','AをBに|AからBへ', 4343, word_replace,'ワードの文章中の文字列AをBに置換する。','わーどちかん');
  AddFunc  ('ワードインストールチェック','', 4344, word_checkInstall, 'Microsoft Wordlがインストールされているか確認してはい(=1)かいいえ(=0)を返す','わーどいんすとーるちぇっく');

  //-パワポ(PowerPoint)
  AddFunc  ('パワポ起動','{=1}Aで', 4750, ppt_open,'可視A(オンかオフ)でPowerPointを起動する','ぱわぽきどう');
  AddFunc  ('パワポ終了','', 4751, ppt_close,'PowerPointを終了する','ぱわぽしゅうりょう');
  AddFunc  ('パワポスライドショー開始','', 4752, ppt_slide_start,'PowerPointのスライドを始める','ぱわぽすらいどしょーかいし');
  AddFunc  ('パワポページ次へ','', 4753, ppt_slide_next,'PowerPointのスライドを次に移動','ぱわぽぺーじつぎへ');
  AddFunc  ('パワポページ前へ','', 4754, ppt_slide_prev,'PowerPointのスライドを前に移動','ぱわぽぺーじまえへ');
  AddFunc  ('パワポスライドショー終了','', 4755, ppt_slide_end,'PowerPointのスライドを終わる','ぱわぽすらいどしょーしゅうりょう');
  AddFunc  ('パワポ開く','FILEを|FILEの', 4756, ppt_open_file,'PowerPointのファイルを開く','ぱわぽひらく');
  AddFunc  ('パワポマクロ実行','MをARGで|Mの', 4757, ppt_macro,'PowerPointのマクロMを引数ARGで実行する','ぱわぽまくろじっこう');
  AddFunc  ('パワポインストールチェック','', 4758, ppt_checkInstall, 'Microsoft PowerPointがインストールされているか確認してはい(=1)かいいえ(=0)を返す','ぱわぽいんすとーるちぇっく');
  AddFunc  ('パワポJPEG出力','DIRへ', 4759, ppt_save_jpegfile,'PowerPointのスライドをJPEG形式で出力する','ぱわぽJPEGしゅつりょく');
  AddFunc  ('パワポPNG出力','DIRへ', 4760, ppt_save_pngfile,'PowerPointのスライドをPNG形式で出力する','ぱわぽPNGしゅつりょく');
  AddFunc  ('パワポPDF出力','FILEへ|FILEに', 4761, ppt_save_pdffile,'PowerPointのスライドをPDF形式で出力する','ぱわぽPDFしゅつりょく');

  //+データベース連携(nakooffice.dll)
  //-ADO.データベース
  AddFunc  ('ACCESS開く','{=?}Fを|Fで', 4650, ado_open_access,'ACCESS(2000/2003)のデータベースFを開く','ACCESSひらく');
  AddFunc  ('ACCESS2007開く','{=?}Fを|Fで', 4797, ado_open_access2007,'ACCESS2007のデータベースFを開く','ACCESS2007ひらく');
  AddFunc  ('ORACLE開く','{=?}Fを|Fで', 4651, ado_open_oracle,'ORACLEのデータベースFを開く','ORACLEひらく');
  AddFunc  ('MSSQL開く', '{=?}Fを|Fで', 4652, ado_open_mssql,'MS SQL SERVER 2000のデータベースFを開く','MSSQLひらく');
  AddFunc  ('SQLSERVER2005開く','{=?}SERVERのDATABASEで|DATABASEへ|DATABASEに', 4685, ado_open_sqlserver2005,'MS SQL SERVER 2005のデータベースと接続する(変数「DBユーザーID」と「DBパスワード」を指定)','SQLSERVERひらく');
  AddFunc  ('ADO開く','Sで',            4671, ado_open_custom,'ADO接続文字列Sを使ってデータベースを開いてハンドルを返す','ADOひらく');
  AddFunc  ('DB閉じる','{=?}HANDLEを',          4653, ado_close,'HANDLE(省略可能)を使ってデータベースを閉じる。ハンドルを閉じる。','DBとじる');
  AddStrVar('DBユーザーID', 'Admin',4654, '','DBゆーざーID');
  AddStrVar('DBパスワード', '',     4655, '','DBぱすわーど');
  AddFunc  ('SQL実行',  '{=?}HANDLEにSを|HANDLEへSの|Sで',  4656, ado_sql,'HANDLE(省略可能)を使ってSQL文Sを実行する。結果は『DB結果全部取得』などで得る。','SQLじっこう');
  AddFunc  ('DB検索','{=?}HANDLEに|HANDLEへAのFからSを',4666, ado_find,'HANDLE(省略可能)を使ってテーブルAのフィールドFからキーワードSを検索する。結果は『DB結果全部取得』などで得る。','DBけんさく');
  AddFunc  ('DB先頭移動','{=?}HANDLEの|HANDLEに|HANDLEへ',        4657, ado_moveFirst,'HANDLE(省略可能)を使ってレコードの先頭に移動','DBせんとういどう');
  AddFunc  ('DB最後移動','{=?}HANDLEの|HANDLEに|HANDLEへ',        4658, ado_moveLast, 'HANDLE(省略可能)を使ってレコードの最後に移動(サポートしてないこともある)','DBさいごいどう');
  AddFunc  ('DB次移動','{=?}HANDLEの|HANDLEに|HANDLEへ',          4659, ado_moveNext, 'HANDLE(省略可能)を使ってレコードを次に移動','DBつぎいどう');
  AddFunc  ('DB前移動','{=?}HANDLEの|HANDLEに|HANDLEへ',          4660, ado_movePrev, 'HANDLE(省略可能)を使ってレコードを前に移動','DBまえいどう');
  AddFunc  ('DB先頭判定','{=?}HANDLEの|HANDLEに|HANDLEへ',        4661, ado_bof,      'HANDLE(省略可能)を使ってレコードが先頭か判定','DBせんとうはんてい');
  AddFunc  ('DB最後判定','{=?}HANDLEの|HANDLEに|HANDLEへ',        4662, ado_eof,      'HANDLE(省略可能)を使ってレコードが最後か判定','DBさいごはんてい');
  AddFunc  ('DBフィールド取得','{=?}HANDLEに|HANDLEへSの',4663, ado_getField,'HANDLE(省略可能)を使って現在のレコードのフィールドSの値を取得して返す。','DBふぃーるどしゅとく');
  AddFunc  ('DB結果全部取得','{=?}HANDLEの|HANDLEに|HANDLEへ',4664, ado_getAllCsv,'HANDLE(省略可能)を使って全レコードをCSV形式で取得する。','DBけっかぜんぶしゅとく');
  AddFunc  ('DB結果TSV取得','{=?}HANDLEの|HANDLEに|HANDLEへ',4665, ado_getAllTsv,'HANDLE(省略可能)を使って全レコードをTSV形式で取得する。','DBけっかTSVしゅとく');
  AddFunc  ('DBレコード数','{=?}HANDLEの|HANDLEに|HANDLEへ',4667, ado_recordCount,'HANDLE(省略可能)を使ってレコード数を取得して返す。(DBプロバイダがサポートしていないときは-1を返す)','DBれこーどすう');
  AddFunc  ('DBフィールド名取得','{=?}HANDLEの|HANDLEに|HANDLEへ',4668, ado_getFiledNames,'HANDLE(省略可能)を使ってレコードのフィールド名の一覧をを返す。','DBふぃーるどめいしゅとく');
  AddFunc  ('DBレコード取得','{=?}HANDLEの|HANDLEに|HANDLEへ',4669, ado_getRec,'HANDLE(省略可能)を使ってカレントレコードをCSV形式で得る。','DBれこーどしゅとく');
  AddFunc  ('DBテーブルCSV取得','{=?}HANDLEに|HANDLEへSを|Sから|Sの',4670, ado_getTableAsCsv,'HANDLE(省略可能)を使ってテーブルSの内容をCSVで取得して返す。','DBてーぶるCSVしゅとく');
  //-SQLiteデータベース
  AddFunc  ('SQLITE開く','Fを|Fの|Fで', 4680, sys_SQLiteOpen,'SQLiteデータベースファイルFを開いてハンドルを返す','SQLITEひらく', 'sqlite.dll');
  AddFunc  ('SQLITE閉じる','{=0}Hの', 4681, sys_SQLiteClose,'ハンドルH(省略可能)で開いているSQLiteデータベースを閉じる','SQLITEとじる', 'sqlite.dll');
  AddFunc  ('SQLITE実行','{=0}HでSQLを|Hの', 4682, sys_SQLiteExecute,'ハンドルH(省略可能)で開いているSQLiteデータベースでSQL文を実行して結果をCSV形式で返す','SQLITEじっこう', 'sqlite.dll');
  AddFunc  ('SQLITE曖昧検索','{=0}HのTABLEでFIELDからSを', 4683, sys_SQLiteSearch,'データベースのテーブルTABLEでフィールド名FIELDから文字列Sを含む行を検索し結果をCSV形式で返す','SQLITEあいまいけんさく', 'sqlite.dll');
  AddFunc  ('SQLITE検索','{=0}HのTABLEでFIELDからSを', 4684, sys_SQLiteSearch2,'データベースのテーブルTABLEでフィールド名FIELDが文字列Sである行を検索し結果をCSV形式で返す','SQLITEけんさく', 'sqlite.dll');
  AddFunc  ('SQLITEテーブル作成','{=0}HのTABLEをDEFで', 4790, sys_SQLiteCreateTable,'データベースのテーブルTABLEをフィールド定義DEF(例:ID,name,value)を作成する。(先頭のフィールドをPRIMARY KEYにする)','SQLITEてーぶるさくせい', 'sqlite.dll');
  AddFunc  ('SQLITEテーブル削除','{=0}HのTABLEを', 4791, sys_SQLiteDropTable,'データベースのテーブルTABLEを削除する。','SQLITEてーぶるさくじょ', 'sqlite.dll');
  AddFunc  ('SQLITEデータ挿入','{=0}HのTABLEにDATAを|TABLEへ', 4792, sys_SQLiteInsert,'データベースのテーブルTABLEへデータDATA(ハッシュ形式で指定)を挿入する','SQLITEでーたそうにゅう', 'sqlite.dll');
  AddFunc  ('SQLITEデータ更新','{=0}HのTABLEでWHEREをDATAに|DATAへ', 4793, sys_SQLiteUpdate,'データベースのテーブルTABLEにある条件WHEREのデータ(ハッシュ形式で指定)を更新する','SQLITEでーたこうしん', 'sqlite.dll');
  AddFunc  ('SQLITEデータ削除','{=0}HのTABLEでWHEREを', 4794, sys_SQLiteDelete,'データベースのテーブルTABLEにある条件WHEREのデータを削除する','SQLITEでーたさくじょ', 'sqlite.dll');
  AddFunc  ('SQLITE今挿入したID','{=0}Hの', 4795, sys_SQLiteGetLastId,'SQLiteで最後に挿入したIDを取得する','SQLITEいまそうにゅうしたID', 'sqlite.dll');
  AddFunc  ('SQLITEデータ取得','{=0}HのTABLEから{=""}WHEREで|TABLEを', 4796, sys_SQLiteSelectAll,'データベースのテーブルTABLEにあるデータをCSV形式で取得して返す','SQLITEでーたしゅとく', 'sqlite.dll');
  AddFunc  ('SQLITE出力コード設定','{=""}Sに|Sへ|Sで', 4798, sys_SQLiteSetEncode,'データベースからデータを取得する時の文字コードを設定する','SQLITEしゅつりょくこーどせってい', 'sqlite.dll');
  //-SQLite3
  AddFunc  ('SQLITE3開く',  'Fを|Fの|Fで',      4851, sys_SQLite3Open,'SQLite3データベースファイルFを開いてハンドルを返す','SQLITE3ひらく', 'sqlite3.dll');
  AddFunc  ('SQLITE3閉じる','{=0}Hの',          4852, sys_SQLite3Close,'ハンドルH(省略可能)で開いているSQLite3データベースを閉じる','SQLITE3とじる', 'sqlite3.dll');
  AddFunc  ('SQLITE3実行',  '{=0}HでSQLを|Hの', 4853, sys_SQLite3Execute,'ハンドルH(省略可能)で開いているSQLite3データベースでSQL文を実行して結果をCSV形式で返す(「SQLITE3自動変換=オン」を明示して使うことを推奨)','SQLITE3じっこう', 'sqlite3.dll');
  AddFunc  ('SQLITE3今挿入したID','{=0}Hの',    4854, sys_SQLite3GetLastId,'SQLiteで最後に挿入したIDを取得する','SQLITEいまそうにゅうしたID', 'sqlite3.dll');
  AddFunc  ('SQLITE3出力コード設定','{=""}Sに|Sへ|Sで', 4855, sys_SQLite3SetEncode,'データベースからデータを取得する時の文字コードを設定する','SQLITEしゅつりょくこーどせってい', 'sqlite3.dll');
  AddFunc  ('SQLITE3変更数取得','{=0}Hの',      4856, sys_SQLite3TotalChanges,'SQLiteで最後に変更したレコード数を取得する','SQLITE3へんこうすうしゅとく', 'sqlite3.dll');
  AddFunc  ('SQLITE3インストールチェック','', 4857, sys_sqlite3_checkInstall,'SQLite3が使えるかどうかチェックする','SQLITE3いんすとーるちぇっく');
  AddIntVar('SQLITE3自動変換', 0, 4858, 'SQLITE3実行でSQL文を自動的にUTF-8に変換し、結果をSHIFT_JISに変換する','SQLITE3じどうへんかん');

  //+OpenOffice.org連携(nakooffice.dll)
  //-CALC(OpenOffice.org)
  AddFunc  ('CALC起動','{=1}Aで', 4800, calc_open, '可視A(オンかオフ)でCALCを起動する','CALCきどう');
  AddFunc  ('CALC終了','',        4801, calc_close,'起動したCALCを終了する','CALCしゅうりょう');
  AddFunc  ('CALC新規ブック','',  4802, calc_workbooks_add,'新規ブックを作る','CALCしんきぶっく');
  AddFunc  ('CALC新規シート','',  4803, calc_worksheet_add,'新規シートを追加する','CALCしんきしーと');
  AddFunc  ('CALC開く','Sを|Sから|Sの', 4804, calc_file_open,'ファイルSからファイルを開く。','CALCひらく');
  AddFunc  ('CALC保存','Sへ|Sに', 4805, calc_file_save,'ファイルＳへファイルを保存する','CALCほぞん');
  AddFunc  ('CALCシート注目','Aの|Aに|Aを', 4806, calc_worksheet_active,'A番目(0～n)または名前Aのシートをアクティブにする','CALCしーとちゅうもく');
  AddFunc  ('CALC_CSV保存','Sへ|Sに', 4808, calc_file_saveCsv,'ファイルＳへファイルをCSV形式で保存する','CALC_CSVほぞん');
  AddFunc  ('CALCセル設定','CELLへVを|CELLに', 4810, calc_setCell,'セルA(A1~)へVを設定する','CALCせってい');
  AddFunc  ('CALCセル取得','CELLの|CELLを',    4811, calc_getCell,'セルA(A1~)を取得して返す','CALCせるしゅとく');
  AddFunc  ('CALC一括設定','CELLへVを|CELLに', 4812, calc_setCellEx,'セル(A1~)へ二次元配列Vを一括設定する','CALCいっかつせってい');
  AddFunc  ('CALC一括取得','C1からC2まで|C2までの|C2の', 4813, calc_getCellEx,'セルC1(A1~)からC2までのセルを一括取得して返す。','CALCいっかつしゅとく');
  AddFunc  ('CALC選択','CELLを|CELLに|CELLへ', 4814, calc_select,'セル(A1~)を選択する。A1:C4のように範囲指定も可能。','CALCせんたく');
  AddFunc  ('CALCコピー','', 4815, calc_copy,'選択されているセルをコピーする。','CALCこぴー');
  AddFunc  ('CALC貼り付け','', 4816, calc_paste,'選択されているセルへクリップボードから貼り付けする。','CALCはりつけ');
  AddFunc  ('CALC着色','Vを|Vで|Vの|Vに', 4817, calc_color,'選択されているセルセルを色Vで着色する。','CALCちゃくしょく');
  AddFunc  ('CALCシート印刷プレビュー','', 4819, calc_sheet_printPreview,'アクティブなシートを印刷プレビューする','CALCしーといんさつぷれびゅー');
  AddFunc  ('CALC印刷','', 4820, calc_printOut,'印刷する','CALCいんさつ');
  AddFunc  ('CALCブック閉じる','{=?}BOOKの', 4824, calc_workbook_close,'ワークブックBOOKを閉じる。BOOkを省略するとアクティブなブックを閉じる。(保存するかどうかユーザーに尋ねる)','CALCぶっくとじる');
  AddFunc  ('CALC全選択','', 4825, calc_selectall,'セル全てを選択する。','CALCぜんせんたく');
  AddFunc  ('CALC_PDF保存','Sへ|Sに', 4826, calc_file_saveToPDF,'ファイルＳへPDF形式で保存する','CALC_PDFほぞん');
  AddFunc  ('OPENOFFICE_ORGインストールチェック','', 4827, ooo_checkInstall,'OpenOffice.orgがインストールされているか確認してはいかいいえで返す。','OPENOFFICE_ORGいんすとーるちぇっく');
  //-WRITER(OpenOffice.org)
  AddFunc  ('WRITER起動','{=1}Aで', 4830, writer_open,'可視A(オンかオフ)でWriterを起動する','WRITERきどう');
  AddFunc  ('WRITER終了','', 4831, writer_close,'Writerを終了する','WRITERしゅうしょう');
  AddFunc  ('WRITER保存','Fへ|Fに', 4832, writer_save,'文書Fを保存する','WRITERほぞん');
  AddFunc  ('WRITER開く','Fを|Fで|Fの', 4833, writer_load,'文書Fをひらく','WRITERひらく');
  AddFunc  ('WRITER新規文書','', 4834, writer_new,'新規文書を作る','WRITERしんきぶんしょ');
  AddFunc  ('WRITERブックマーク挿入','SにVを|Sへ', 4835, writer_bookmark,'ブックマークSに値Vを挿入する','WRITERぶっくまーくそうにゅう');
  AddFunc  ('WRITER印刷プレビュー','', 4836, writer_printPreview,'印刷プレビューを表示する','WRITERいんさつぷれびゅー');
  AddFunc  ('WRITER印刷','', 4837, writer_print,'印刷する','WRITERいんさつ');
  AddFunc  ('WRITER本文取得','', 4839, writer_getText,'本文をテキストで得て返す','WRITERほんぶんしゅとく');
  AddFunc  ('WRITER文章追加','{=?}Sを', 4840, writer_addText,'文章Sを追加する。','WRITERぶんしょうついか');
  AddFunc  ('WRITER文書閉じる','', 4841, writer_docClose,'アクティブな文書を閉じる','WRITERぶんしょとじる');
  AddFunc  ('WRITER_PDF保存','Fへ|Fに', 4842, writer_saveToPDF,'ファイルFへPDFを保存する','WRITER_PDFほぞん');
  //-nakooffice.dll
  AddFunc  ('NAKOOFFICE_DLLバージョン','', 4850, getNakoOfficeVersion,'nakooffice.dllのバージョンを得る','NAKOOFFICE_DLLばーじょん');
  //</命令>
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
