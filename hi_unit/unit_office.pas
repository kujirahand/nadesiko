unit unit_office;

interface

uses
  Windows, SysUtils, Classes, activex, comobj, Variants;

type
  TKExcel = class
  private
    E_Excel        : Variant;
    E_Application  : Variant;
    E_WorkBook     : Variant;
    E_WorkSheet    : Variant;
    FActive : Boolean;
    FVisible: Boolean;
    FDisplayAlerts: Boolean;
    procedure SetDisplayAlerts(v:Boolean);
    procedure SetVisible(const Value: Boolean);
    function GetVersion: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetUnassigned;
    procedure Open(Visible: Boolean);
    procedure Close(AlertOff: Boolean = True);
    function GetActiveWorkBook: Variant;
    function GetActiveSheet: Variant;
    function WorkBookAdd: Variant;
    procedure WorkBookActiveClose;
    procedure WorkBookActive(Index: Integer);
    procedure WorkBookActiveS(bookname:string);
    function GetActiveWorkBookName: string;
    function GetActiveSheetName: string;
    function GetActiveCellName: string;
    procedure WorkBookClose(name:string);
    function WorkBookGet(name: string): Variant;
    procedure WorkBookCloseBook(E_WorkBook:Variant; useSave:Boolean; bSave: Boolean);
    procedure WorkBookCloseSave(name:string);
    procedure WorkBookCloseNoSave(name:string);
    procedure WorkBookMarge(fname: string);
    procedure WorkSheetAdd;
    procedure WorkSheetActive(Index: Integer);
    procedure WorkSheetActiveClose;
    procedure WorkSheetActiveS(s: string);
    procedure SheetCopy(sh1, sh2: string);
    procedure SheetRename(sh1, sh2: string);
    procedure WorkSheetMoveLast(sheet: string);
    procedure WorkSheetMoveTop(sheet: string);
    function FileOpen(fname: string): Variant;
    procedure FileSave(fname: string);
    procedure FileSaveAsCsv(fname: string);
    procedure FileSaveAsTsv(fname: string);
    procedure FileSaveAsPDF(fname: string);
    procedure SetCell(row, col: Integer; v: string);
    function  GetCell(row, col: Integer): string;
    procedure SetCellR(cell, v: string);
    function  GetCellR(cell: string): string;
    procedure SetCellEx(cell, s: string);
    function GetCellEx(c1, c2: string): string;
    procedure CellSelect(cell: string);
    procedure setRowHeight(v: Double);
    procedure setColWidth(v: Double);
    procedure SendKeys(s: string);
    function enumSheets:String;
    procedure CellCopy;
    procedure CellPaste;
    procedure SelectAll;
    procedure SelectionReplace(findStr, replaceStr: string);
    procedure CellColor(v: Integer);
    procedure SelectionMerge;
    procedure SelectionAlignment(alignValue: Integer);
    procedure SelectionVAlignment(alignValue: Integer);
    procedure SelectionShrinkToFilt(value: Boolean);
    procedure SelectionWrapText(value: Boolean);
    function MacroExec(s: string; arg:string): string;
    procedure Print;
    procedure PrintPreview;
    procedure WorkBookPrintPreview;
    procedure WorkBookPrint;
    function Phonetic(s:string):string;
    function PhoneticAll(s:string):string;
    function CellPhonic(cell:string): string;
    function SelectionRow:Integer;
    function SelectionCol:Integer;
    function DeleteSheet(sheetname: string):Boolean;
    procedure InsertRow(i:string);
    procedure InsertCol(col:string);
    property Active: Boolean read FActive;
    property Visible: Boolean read FVisible write SetVisible;
    property Version: Integer read GetVersion;
    function getLastRow(col:string):Integer;
    function getLastCol(row:string):Integer;
    procedure UniqueRow(col:string);
    procedure InsertPic(f: string);
    procedure SetShapeSize(w, h:Integer);
    procedure MoveShape(x, y: Integer);
    procedure SelectShape(name: string);
    procedure InsertChart(range:string; typeStr:string);
    procedure ProtectOn(sheet: string; password: string);
    procedure ProtectOff(sheet: string; password: string);
    property DisplayAlerts:Boolean read FDisplayAlerts write SetDisplayAlerts;
  end;

  TKWord = class
  private
    FWord    : Variant;
    FWordApp : Variant;
    FWordDoc : Variant;
    FActive  : Boolean;
    function GetVisible: Boolean;
    procedure SetVisible(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Open(Visible: Boolean);
    procedure Close(AlertOff: Boolean = True);
    procedure DocClose;
    procedure FileSave(fname: string);
    procedure FileOpen(fname: string);
    procedure NewDoc;
    procedure Print;
    procedure PrintPreview;
    procedure replace(a, b: string);
    procedure BookmarkInsertText(name, value: string);
    function BookmarkGetText(name: string): string;
    function getAsText: string;
    procedure InsertText(s: string);
    function MacroExec(s: string; arg:string): string;
    property Active: Boolean read FActive;
    property Visible: Boolean read GetVisible write SetVisible;
  end;

  TKPowerPoint = class
  private
    FPp       : Variant;
    FPpApp    : Variant;
    FActive   : Boolean;
    function GetVisible: Boolean;
    procedure SetVisible(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Open(Visible: Boolean);
    procedure Close(AlertOff: Boolean = True);
    procedure FileSave(fname: string);
    procedure FileOpen(fname: string);
    procedure AddSlide; // スライドの追加
    procedure GotoSlide(Index: Integer); // スライドの移動
    procedure SlideNext;
    procedure SlidePrev;
    procedure SlideExit;
    procedure SlideStart;
    procedure Print;
    procedure SaveToJpegDir(dir: string);
    procedure SaveToPdfDir(dir: string);
    procedure SaveToPngDir(dir: string);
    procedure SaveToPDFFile(f: string);
    function MacroExec(s: string; arg:string): string;
    property Active: Boolean read FActive;
    property Visible: Boolean read GetVisible write SetVisible;
  end;

  TKAdo = class
  private
    FAdoConnect,
    FAdoRecSet: Variant;
  public
    DbProvider,
    DbDataSource,
    DbUserId,
    DbPassword: string;
    constructor Create;
    destructor Destroy; override;
    procedure Open(provider, source: string); // 汎用的な OPEN
    procedure OpenAccess(dbname, user, password: string); // アクセス2000のDBを開く
    procedure OpenAccess2007(dbname, user, password: string); // アクセス2007のDBを開く
    procedure OpenOracle(dbname, user, password: string); // ORACLE
    procedure OpenSQLServer(dbname, user, password: string); // MS SQL Server
    procedure OpenSQLServer2005(server, dbname, user, password: string); // MS SQL Server 2005
    procedure OpenCustom(cinfo: string);
    procedure Close;
    procedure SQL(cmd: string);
    function GetSqlResultAsCsv: string;
    function GetSqlResultAsTsv: string;
    procedure MoveFirst;
    procedure MoveLast;
    procedure MoveNext;
    procedure MovePrev;
    function GetRecordCount: Integer;
    function GetCurRecAsCsv: string;
    function GetCurRecAsTsv: string;
    function GetFieldNames: string;
    function dbEOF: Boolean;
    function dbBOF: Boolean;
    procedure Find(table, field, key: string);
    function GetFieldValue(field:string): string;
    function GetTableAsCsv(table:string): string;
  end;

procedure MsgBox(s: string);
function RowColToCellName(row, col: Integer): string;

const
  xlBottom = -4107;
  xlCenter = -4108;
  xlJustify = -4130;
  xlLeft = -4131;
  xlRight = -4152;
  xlTop = -4160;
  xlToLeft = -4159;

implementation

uses CsvUtils2, StrUnit, Math;

const
  ppSaveAsJPG = 17;
  ppSaveAsPNG = 18;
  ppSaveAsPDF = 32;
const
  xlCsv = 6;
  xlCurrentPlatformText = -4158;
  xlExcel8 = 56;
  xlExcel9795 = 43;
  xlHtml = 44;
  xlTypePDF = $00000000;
  xlTypeXPS = $00000001;
  xlQualityStandard = $00000000;
  xlQualityMinimum = $00000001;
  xlUp = -4162;
  xlToRight = -4161;
  xlDown = -4121;
  xlFormatFromLeftOrAbove = 0;


const
  wdExportFormatPDF = 17;
  wdExportOptimizeForPrint = 0;
  wdFormatDocument = $00000000;
  wdFormatTemplate = $00000001;
  wdFormatText = $00000002;
  wdFormatTextLineBreaks = $00000003;
  wdFormatDOSText = $00000004;
  wdFormatDOSTextLineBreaks = $00000005;
  wdFormatRTF = $00000006;
  wdFormatUnicodeText = $00000007;
  wdFormatEncodedText = $00000007;
  wdFormatHTML = $00000008;


function RowColToCellName(row, col: Integer): string;
var
  v: Integer;
  s: string;
begin
  s := '';

  v := col mod 26;
  col := col div 26;
  s := s + Char(Ord('A') + v);

  while (col > 0) do
  begin
    v := (col-1) mod 26;
    col := (col-1) div 26;
    s := Char(Ord('A') + v) + s;
  end;
  Result := s + IntToStr(row);
end;

procedure MsgBox(s: string);
begin
  MessageBox(0, PChar(s), 'debug', MB_OK);
end;

(*--- WEBより引っ張ってきた使い方
//***** Excelの起動 *****//
procedure TForm1.Button1Click(Sender: TObject);
begin
   try
      Excel := CreateOleObject('Excel.Application');
   except
      on EOleSysError do begin
         //起動失敗
         ShowMessage('Excelが起動できません');
         Excel := Null;
         Exit;
      end;
   end;
   Excel.Visible:= True;
end;

//***** Excelの終了 *****//
procedure TForm1.Button3Click(Sender: TObject);
begin
   Excel.DisplayAlerts := False;//メッセージダイアログを表示しない
   Excel.Quit;
   Excel := unAssigned;
end;

//***** 新規作成 *****//
procedure TForm1.Button2Click(Sender: TObject);
begin
   WorkBook := Excel.WorkBooks.Add;
   WorkSheet := WorkBook.WorkSheets[1];
   WorkSheet.Activate;
end;

//***** その他の使用法 *****//

  //Sheetの選択
  WorkSheet := WorkBook.Sheets[1].Select;

  //セル色変更
  WorkSheet.Range['E3'].Interior.ColorIndex := 6;

  //セル選択
  WorkSheet.Range['E3:E5'].Select;

  //幅自動調整[A-J]
  WorkSheet.Columns['A:J'].AutoFit;

  //Version情報取得
  Label1.Caption := Excel.Version;
  Label2.Caption := Excel.OperatingSystem;

  //縦に分割
  Excel.ActiveWindow.SplitColumn := 3;

  //横に分割
  Excel.ActiveWindow.SplitRow := 3;

  //プリントプレビュー
  WorkSheet.PrintPreview;

  //特定のセル同士を足す
  Edit1.Text :=
           WorkSheet.Range['A3'].Value + WorkSheet.Range['A4'].Value;

  //ファイルのロード
  Excel.WorkBooks.Open(ファイル名);

*)

{ TKExcel }

procedure TKExcel.CellColor(v: Integer);
var
  r,g,b: Byte;
begin
  E_WorkBook  := E_Application.ActiveWorkBook;
  E_WorkSheet := E_WorkBook.ActiveSheet;

  b := v and $FF;
  g := (v shr 8) and $FF;
  r := (v shr 16) and $FF;

  E_Excel.Selection.Interior.Color := RGB(r,g,b);
end;

procedure TKExcel.CellCopy;
begin
  { シートのコピー:::
  E_WorkBook  := E_Application.ActiveWorkBook;
  E_WorkSheet := E_WorkBook.ActiveSheet;
  E_WorkSheet.Copy;
  }
  E_Application.Selection.Copy;
end;

procedure TKExcel.CellPaste;
begin
  E_WorkBook  := E_Application.ActiveWorkBook;
  E_WorkSheet := E_WorkBook.ActiveSheet;
  E_WorkSheet.Paste;
end;

procedure TKExcel.CellSelect(cell: string);
begin
  E_WorkBook  := E_Application.ActiveWorkBook;
  E_WorkSheet := E_WorkBook.ActiveSheet;
  E_WorkSheet.Range[cell].Select;
end;

procedure TKExcel.Close(AlertOff: Boolean);
begin
  if FActive = False then Exit;

  FActive := False;
  try
    E_Application.DisplayAlerts := (not AlertOff); //メッセージダイアログを表示しない
  except end;
  try
    E_Excel.Quit;
  except end;

  // Unassigned を代入 ... これ非常に重要。これを忘れるとうまく終了できない
  SetUnassigned
end;

constructor TKExcel.Create;
begin
  FActive  := False;
  FVisible := False;
end;

destructor TKExcel.Destroy;
begin
  Close(True);
  SetUnassigned;
  inherited;
end;

function TKExcel.FileOpen(fname: string):Variant;
var
  path, old: string;
begin
  old := GetCurrentDir;
  path := ExtractFilePath(fname);
  if path <> '' then ChDir(path);

  Result := E_Application.Workbooks.Open(fname);

  ChDir(old);
end;

procedure TKExcel.FileSave(fname: string);
var
  ext: String;
begin
  ext := LowerCase(ExtractFileExt(fname));
  if ext = '.csv' then
  begin
    FileSaveAsCsv(fname); Exit;
  end else
  if (ext = '.txt')or(ext = '.tsv') then
  begin
    FileSaveAsTsv(fname); Exit;
  end else
  if (ext = '.pdf') then
  begin
    FileSaveAsPDF(fname); Exit;
  end;

  try E_Application.DisplayAlerts := False; except end;
  E_WorkBook := E_Application.ActiveWorkBook;

  if (ext = '.htm')or(ext = '.html') then
  begin
    E_WorkBook.SaveAs(fname, xlHtml);
    Exit;
  end;

  // Excel2007(12)以降で保存ファイル形式がおかしくなる
  if Version < 12 then // 2007以前はこれまで通り
  begin
    E_WorkBook.SaveAs(fname);
    Exit;
  end;
  // それ以降で分岐
  if ext = '.xls' then
  begin
    E_WorkBook.SaveAs(fname, xlExcel8);
  end else
  begin
    E_WorkBook.SaveAs(fname);
  end;
  try E_Application.DisplayAlerts := FDisplayAlerts; except end;
end;


procedure TKExcel.FileSaveAsCsv(fname: string);
begin
  try E_Application.DisplayAlerts := False; except end;
  E_WorkBook := E_Application.ActiveWorkBook;
  E_WorkBook.SaveAs(fname, xlCSV);
  try E_Application.DisplayAlerts := FDisplayAlerts; except end;
end;

procedure TKExcel.FileSaveAsPDF(fname: string);
begin
  try E_Application.DisplayAlerts := False; except end;
  E_WorkBook := E_Application.ActiveWorkBook;
  try
    E_WorkBook.ExportAsFixedFormat(
      xlTypePDF,
      fname,
      xlQualityStandard);
  except on e:Exception do
    begin
      raise Exception.Create('保存できませんでした。' + e.Message);
    end;
  end;
  try E_Application.DisplayAlerts := FDisplayAlerts; except end;
end;

procedure TKExcel.FileSaveAsTsv(fname: string);
begin
  try E_Application.DisplayAlerts := False; except end;
  E_WorkBook := E_Application.ActiveWorkBook;
  E_WorkBook.SaveAs(fname, xlCurrentPlatformText);
  try E_Application.DisplayAlerts := FDisplayAlerts; except end;
end;

function TKExcel.GetCell(row, col: Integer): string;
begin
  E_WorkBook  := E_Application.ActiveWorkBook;
  E_WorkSheet := E_WorkBook.ActiveSheet;
  Result      := E_WorkSheet.Cells[row, col];
end;

function TKExcel.GetCellEx(c1, c2: string): string;
var
  col1, col2, row1, row2: Integer;
  x, y: Integer;
  csv: TCsvSheet;
begin
  E_WorkBook  := E_Application.ActiveWorkBook;
  E_WorkSheet := E_WorkBook.ActiveSheet;
  col1 := E_WorkSheet.Range[c1].Column;
  row1 := E_WorkSheet.Range[c1].Row;
  col2 := E_WorkSheet.Range[c2].Column;
  row2 := E_WorkSheet.Range[c2].Row;

  csv := TCsvSheet.Create;
  try
    for y := 0 to (row2-row1) do
    begin
      for x := 0 to (col2-col1) do
      begin
        csv.Cells[x,y] := E_WorkSheet.Cells[row1 + y, col1 + x];
      end;
    end;
    Result := csv.AsText;
  finally
    csv.Free;
  end;
end;

function TKExcel.GetCellR(cell: string): string;
begin
  E_WorkBook  := E_Application.ActiveWorkBook;
  E_WorkSheet := E_WorkBook.ActiveSheet;
  Result      := E_WorkSheet.Range[cell];
end;

function TKExcel.MacroExec(s: string; arg: string): string;
begin
  if arg = '' then
    Result := E_Excel.Run(s)
  else
    Result := E_Excel.Run(s, arg);
end;

procedure TKExcel.Open(Visible: Boolean);
begin
  if FActive then Close(True);

  E_Excel := CreateOleObject('Excel.Application');

  E_Application         := E_Excel.Application;
  E_Application.Visible := Visible;


  // Visible を保持
  FVisible := E_Application.Visible;
  FActive := True;
end;

procedure TKExcel.PrintPreview;
begin
  E_WorkBook  := E_Application.ActiveWorkBook;
  E_WorkSheet := E_WorkBook.ActiveSheet;
  E_WorkSheet.PrintPreview;
end;

procedure TKExcel.Print;
begin
  E_WorkBook  := E_Application.ActiveWorkBook;
  E_WorkSheet := E_WorkBook.ActiveSheet;
  E_WorkSheet.PrintOut;
end;

procedure TKExcel.SetCell(row, col: Integer; v: string);
begin
  E_WorkSheet := GetActiveSheet;
  E_WorkSheet.Cells[row, col] := v;
end;

procedure TKExcel.SetCellEx(cell, s: string);
var
  col, row: Integer;
  x, y: Integer;
  csv: TCsvSheet;
begin
  E_WorkSheet := GetActiveSheet;
  col := E_WorkSheet.Range[cell].Column;
  row := E_WorkSheet.Range[cell].Row;

  csv := TCsvSheet.Create;
  try
    csv.AsText := s;
    for y := 0 to csv.Count - 1 do
    begin
      for x := 0 to csv.ColCount - 1 do
      begin
        E_WorkSheet.Cells[y+row, x+col] := csv.Cells[x, y];
      end;
    end;
  finally
    csv.Free;
  end;

end;

procedure TKExcel.SetCellR(cell, v: string);
begin
  E_WorkSheet := GetActiveSheet;
  E_WorkSheet.Range[cell] := v;
end;

procedure TKExcel.WorkBookActive(Index: Integer);
begin
  try
    E_WorkBook := E_Application.WorkBooks[Index];
    E_WorkBook.Activate;
  except
    raise Exception.CreateFmt('%d番目のワークブックはありません。',[Index]);
  end;
end;

procedure TKExcel.WorkBookActiveS(bookname:string);
begin
  try
    E_WorkBook := E_Application.WorkBooks[bookname];
    E_WorkBook.Activate;
  except
    raise Exception.CreateFmt('ワークブック"%s"はありません。',[bookname]);
  end;
end;

function TKExcel.GetActiveWorkBookName: string;
begin
  E_WorkBook := E_Application.ActiveWorkBook;
  Result := E_WorkBook.Name;
end;

function TKExcel.GetActiveSheetName: string;
begin
  E_WorkSheet := E_Application.ActiveSheet;
  Result := E_WorkSheet.Name;
end;

function TKExcel.GetActiveCellName: string;
begin
  E_WorkSheet := E_Application.ActiveSheet;
  Result := E_WorkSheet.Name;
end;

function TKExcel.WorkBookAdd: Variant;
begin
  E_WorkBook := E_Application.WorkBooks.Add;
  Result := E_WorkBook;
end;

function TKExcel.GetActiveWorkBook: Variant;
begin
  if VarIsClear(E_WorkBook) then
  begin
    E_WorkBook := E_Application.ActiveWorkBook;
    if VarIsClear(E_WorkBook) then
    begin
      WorkBookAdd;
    end;
  end;
  Result := E_WorkBook;
end;

function TKExcel.GetActiveSheet: Variant;
begin
  if VarIsClear(E_WorkSheet) then
  begin
    E_WorkSheet := E_Application.ActiveSheet;
    if VarIsClear(E_WorkSheet) then
    begin
      WorkSheetAdd;
    end;
  end;
  Result := E_WorkSheet;
end;

procedure TKExcel.WorkSheetActive(Index: Integer);
begin
  try
    E_WorkSheet := E_Application.ActiveWorkBook.Sheets[Index];
    E_WorkSheet.Activate;
  except
    raise Exception.CreateFmt('%d番目のワークシートはありません。',[Index]);
  end;
end;

procedure TKExcel.WorkSheetActiveS(s: string);
begin
  try
    E_WorkSheet := E_Application.ActiveWorkBook.Sheets[s];
    E_WorkSheet.Activate;
  except
    raise Exception.CreateFmt('%sのワークシートはありません。',[s]);
  end;
end;

procedure TKExcel.WorkSheetAdd;
begin
  if E_Application.Workbooks.Count = 0 then
  begin
    E_WorkBook := E_Application.WorkBooks.Add;
    E_WorkSheet := E_WorkBook.Sheets[1];
  end else
  begin
    E_WorkBook  := E_Application.ActiveWorkbook;
    E_WorkSheet := E_WorkBook.Sheets.Add;
  end;
end;

procedure TKExcel.WorkBookPrint;
begin
  E_WorkBook  := E_Application.ActiveWorkbook;
  E_WorkBook.Sheets.PrintOut;
end;

procedure TKExcel.WorkBookPrintPreview;
begin
  E_WorkBook  := E_Application.ActiveWorkbook;
  E_WorkBook.Sheets.PrintPreview;
end;

procedure TKExcel.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
  E_Application.Visible := Visible;
end;

procedure TKExcel.SetDisplayAlerts(v:Boolean);
begin
  try
    E_Application.DisplayAlerts := v;
  except end;
  FDisplayAlerts := v;
end;

procedure TKExcel.WorkBookActiveClose;
begin
  try
    E_WorkBook  := E_Application.ActiveWorkBook;
    E_WorkBook.Close;
  except
  end;
end;

procedure TKExcel.WorkSheetActiveClose;
begin
  try
    E_Application.ActiveWorkBook.ActiveWorkSheet.Close;
  except
  end;
end;

procedure TKExcel.SelectAll;
begin
  E_Application.Cells.Select;
end;

procedure TKExcel.SelectionReplace(findStr, replaceStr: string);
begin
  E_Application.Selection.Replace(findStr, replaceStr, 2, 1, False);
end;

procedure TKExcel.WorkBookClose(name: string);
begin
  WorkBookCloseBook(WorkBookGet(name), False, False);
end;

procedure TKExcel.SetUnassigned;
begin
  E_WorkSheet   := Unassigned;
  E_WorkBook    := Unassigned;
  E_Application := Unassigned;
  E_Excel       := Unassigned;
end;

procedure TKExcel.setColWidth(v: Double);
begin
  E_Application.Selection.ColumnWidth := v;
end;

procedure TKExcel.setRowHeight(v: Double);
begin
  E_Application.Selection.RowHeight := v;
end;

procedure TKExcel.WorkBookCloseNoSave(name: string);
begin
  WorkBookCloseBook(WorkBookGet(name), True{useSave}, False{bSave});
end;

procedure TKExcel.WorkBookCloseSave(name: string);
begin
  WorkBookCloseBook(WorkBookGet(name), True, True);
end;

procedure TKExcel.WorkBookCloseBook(E_WorkBook: Variant; useSave,
  bSave: Boolean);
begin
  try
    try
      if useSave then
      begin
        E_WorkBook.Close(bSave);
      end else
      begin
        E_WorkBook.Close;
      end;
    except
    end;
  finally
    E_WorkSheet := Unassigned;
    E_WorkBook := Unassigned;
  end;
end;

function TKExcel.WorkBookGet(name: string): Variant;
var
  i: Integer;
begin

  if name = '' then begin
    Result := E_Application.ActiveWorkBook;
  end;

  for i := 0 to E_Application.Workbooks.Count - 1 do
  begin
    E_WorkBook  := E_Application.Workbooks[i+1];
    if LowerCase(name) = LowerCase(E_WorkBook.name) then
    begin
      Result := E_WorkBook;
      Break;
    end;
  end;
  
end;

procedure TKExcel.WorkBookMarge(fname: string);
begin
  E_Application.ActiveWorkBook.MergeWorkbook(fname);
end;

procedure TKExcel.SendKeys(s: string);
begin
  E_Excel.SendKeys(s);
end;

procedure TKExcel.SheetCopy(sh1, sh2: string);
begin
  E_WorkBook :=  E_Application.ActiveWorkBook;
  E_WorkBook.Sheets[sh1].Copy(E_WorkBook.Sheets[1]);
  E_WorkBook.Sheets[1].Name := sh2;
end;

function TKExcel.DeleteSheet(sheetname: string):Boolean;
begin
  try E_Application.DisplayAlerts := False; except end;
  E_WorkBook :=  E_Application.ActiveWorkBook;
  E_WorkSheet := E_WorkBook.Sheets[sheetname];
  Result := E_WorkSheet.Delete;
  try E_Application.DisplayAlerts := FDisplayAlerts; except end;
  E_WorkSheet := Unassigned;
end;

procedure TKExcel.InsertRow(i:string);
begin
  E_WorkSheet := GetActiveSheet;
  E_WorkSheet.Range[i+':'+i].Rows.Insert(xlDown, xlFormatFromLeftOrAbove);
end;

procedure TKExcel.InsertCol(col:string);
begin
  E_WorkSheet := GetActiveSheet;
  E_WorkSheet.Range[col+':'+col].Columns.Insert(xlToRight, xlFormatFromLeftOrAbove);
end;

procedure TKExcel.SheetRename(sh1, sh2: string);
begin
  E_WorkBook :=  E_Application.ActiveWorkBook;
  E_WorkBook.Sheets[sh1].Name := sh2;
end;

procedure TKExcel.WorkSheetMoveLast(sheet: string);
var
  ASheet: Variant;
begin
  E_WorkBook :=  E_Application.ActiveWorkBook;
  try
    E_WorkSheet := E_WorkBook.Sheets[sheet];
  except
    raise Exception.Create('シート"'+sheet+'"が見つかりません。');
  end;
  ASheet:=E_WorkBook.Sheets[E_WorkBook.Sheets.Count];
  try
    if ASheet.Name = E_WorkSheet.Name then Exit;
    E_WorkSheet.Move(EmptyParam, ASheet);
  finally
    ASheet := Unassigned;
  end;
end;

procedure TKExcel.WorkSheetMoveTop(sheet: string);
var
  ASheet: Variant;
begin
  E_WorkBook :=  E_Application.ActiveWorkBook;
  try
    E_WorkSheet := E_WorkBook.Sheets[sheet];
  except
    raise Exception.Create('シート"'+sheet+'"が見つかりません。');
  end;
  ASheet:=E_WorkBook.Sheets[1];
  try
    if ASheet.Name = E_WorkSheet.Name then Exit;
    E_WorkSheet.Move(ASheet, EmptyParam);
  finally
    ASheet := Unassigned;
  end;
end;

function TKExcel.enumSheets: String;
var
  i: Integer;
  s: string;
begin
  s := '';
  E_WorkBook :=  E_Application.ActiveWorkBook;
  for i := 1 to E_WorkBook.Sheets.Count do
  begin
    s := s + E_WorkBook.Sheets[i].Name + #13#10;
  end;
  Result := s;
end;

function TKExcel.getLastRow(col: string): Integer;
var
  v1, v2:Variant;
begin
  E_WorkSheet := E_Application.ActiveSheet;
  v1 := E_WorkSheet.Range[col + '65535'];
  v2 := v1.End[xlUp];
  Result := v2.Row;
  v1 := Unassigned;
  v2 := Unassigned;
end;

function TKExcel.getLastCol(row: string): Integer;
var
  v1, v2:Variant;
begin
  E_WorkSheet := E_Application.ActiveSheet;
  v1 := E_WorkSheet.Range['IV' + row];
  v2 := v1.End[xlToLeft];
  Result := v2.column;
  v1 := Unassigned;
  v2 := Unassigned;
end;

function TKExcel.GetVersion: Integer;
var
  str:string;
begin
  str := E_Application.Version;
  Delete(str,Pos('.',str),High(integer));
  Result := StrToIntDef(str,-1);
end;

function TKExcel.Phonetic(s:string):string;
begin
  Result := E_Application.GetPhonetic(s);
end;

function TKExcel.PhoneticAll(s:string):string;
var
  kanji: Variant;
  r: Variant;
begin
  kanji := s;
  Result := E_Application.GetPhonetic(kanji);
  r := Result;
  while r <> '' do
  begin
    r := E_Application.GetPhonetic;
    if r <> '' then
    begin
      Result := Result + #13#10 + r;
    end;
  end;
  r := Unassigned;
  kanji := Unassigned;
end;


function TKExcel.CellPhonic(cell:string):string;
begin
  E_WorkSheet := GetActiveSheet;
  Result := E_WorkSheet.Range[cell].Phonetics[1].Text;
end;


function TKExcel.SelectionRow:Integer;
begin
  try
    Result := E_Application.Selection.Row;
  except
    Result := 0;
  end;
end;

procedure TKExcel.SelectionShrinkToFilt(value: Boolean);
begin
  try
    E_Application.Selection.ShrinkToFit := value;
  except
  end;
end;

// Check xlCenter, xlTop, xlBottom
procedure TKExcel.SelectionVAlignment(alignValue: Integer);
begin
  try
    E_Application.Selection.VerticalAlignment := alignValue;
  except
  end;
end;

procedure TKExcel.SelectionWrapText(value: Boolean);
begin
  try
    E_Application.Selection.WrapText := value;
  except
  end;
end;

procedure TKExcel.SelectionMerge;
begin
  try
    E_Application.Selection.Merge;
  except
  end;
end;

// Check xlCenter,xlLeft, xlRight
procedure TKExcel.SelectionAlignment(alignValue: Integer);
begin
  try
    E_Application.Selection.HorizontalAlignment := alignValue;
  except
  end;
end;

function TKExcel.SelectionCol:Integer;
begin
  try
    Result := E_Application.Selection.Column;
  except
    Result := 0;
  end;
end;

procedure TKExcel.UniqueRow(col: string);
var
  r:Variant;
  sl:TStringList;
  i: Integer;
  key: string;
begin
  E_WorkSheet := E_Application.ActiveSheet;
  r := E_WorkSheet.Range[col+'1'];
  sl := TStringList.Create;
  try
    i := 0;
    while True do
    begin
      key := r.Offset[i,0];
      if key = '' then Break;
      if sl.Values[key] = '' then
      begin
        sl.Values[key] := '1';
        Inc(i);
        Continue;
      end;
      r.Offset[i, 0].EntireRow.Delete;
    end;
  finally
    sl.Free;
    r := Unassigned;
  end;
end;

procedure TKExcel.InsertPic(f: string);
var
  r:Variant;
begin
  E_WorkSheet := E_Application.ActiveSheet;
  r := E_WorkSheet.Pictures.Insert(f);
  r.Select();
  r := Unassigned;
end;
procedure TKExcel.SetShapeSize(w, h:Integer);
begin
  // E_WorkSheet := E_Application.ActiveSheet;
  try
    E_Application.Selection.ShapeRange.Height := h;
    E_Application.Selection.ShapeRange.Width := w;
  except
  end;
end;

procedure TKExcel.MoveShape(x, y: Integer);
begin
  try
    E_Application.Selection.ShapeRange.Left := x;
    E_Application.Selection.ShapeRange.Top := y;
  except
  end;
end;

procedure TKExcel.SelectShape(name: string);
begin
  try
    E_Application.Selection.Shapes(name).Select;
  except
  end;
end;

procedure TKExcel.InsertChart(range:string; typeStr:string);
var
  r1, r2: Variant;
  no: Integer;
begin
  raise Exception.Create('未実装のメソッドです');
  //
  // 2010と2003で実装方法を変えないといけないみたい
  //
  no := StrToIntDef(typeStr, 51);
  E_WorkSheet := E_Application.ActiveSheet;

  r1 := E_WorkSheet.Shapes.AddChart(no);
  r1.Select;

  r2 := E_Application.ActiveChart;
  r2.SetSourceData(E_WorkSheet.Range(range)); // ここでエラー

  r1 := Unassigned;
  r2 := Unassigned;
end;

procedure TKExcel.ProtectOn(sheet: string; password: string);
begin
  // Worksheet
  if sheet = '' then
  begin
    E_WorkSheet := E_Application.ActiveSheet;
  end else begin
    E_WorkSheet := E_Application.ActiveWorkBook.Sheets[sheet];
  end;
  // Protect
  E_WorkSheet.Protect(password, True, True, True);
end;
procedure TKExcel.ProtectOff(sheet: string; password: string);
begin
  // Worksheet
  if sheet = '' then
  begin
    E_WorkSheet := E_Application.ActiveSheet;
  end else begin
    E_WorkSheet := E_Application.ActiveWorkBook.Sheets[sheet];
  end;
  // Protect
  E_WorkSheet.Unprotect(password);
end;


{ TKWord }

function TKWord.BookmarkGetText(name: string): string;
begin
  FWordDoc := FWordApp.ActiveDocument;
  Result := FWordDoc.Bookmarks.Item(name).Range.Text;
end;

procedure TKWord.BookmarkInsertText(name, value: string);
begin
  FWordDoc := FWordApp.ActiveDocument;
  FWordDoc.Bookmarks.Item(name).Range.Text := value;
end;

procedure TKWord.Close(AlertOff: Boolean);
begin
  try
    FWordApp.DisplayAlerts := (not AlertOff);
  except end;
  try
    FWord.Quit(False);
  except end;
  //
  FWordDoc  := Unassigned;
  FWordApp  := Unassigned;
  FWord     := Unassigned;
end;

constructor TKWord.Create;
begin
  FActive := False;
end;

destructor TKWord.Destroy;
begin
  Close;
  inherited;
end;

procedure TKWord.DocClose;
begin
  FWordDoc := FWordApp.ActiveDocument;
  FWordApp.DisplayAlerts := False;
  try
    FWordDoc.Close(False);
  except
    FWordDoc.Close;
  end;
end;

procedure TKWord.FileOpen(fname: string);
var
  old,path: string;
begin
  old  := GetCurrentDir;
  path := ExtractFilePath(fname);
  if path <> '' then ChDir(path);

  FWordApp.DisplayAlerts := False;
  FWordApp.Documents.Open(fname);

  ChDir(old);
end;

procedure TKWord.FileSave(fname: string);
var
  ext: string;
begin
  FWordDoc := FWordApp.ActiveDocument;
  FWordApp.DisplayAlerts := False;
  ext := LowerCase(ExtractFileExt(fname));
  if ext = '.pdf' then
  begin
    FWordDoc.ExportAsFixedFormat(
      fname,
      wdExportFormatPDF,
      False,
      wdExportOptimizeForPrint
      );
  end else
  if ext = '.doc' then
  begin
    FWordDoc.SaveAs(
      fname, wdFormatDocument,
      EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam);
  end else
  if ext = '.html' then
  begin
    FWordDoc.SaveAs(
      fname, wdFormatHTML,
      EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam);
  end else
  begin
    FWordDoc.SaveAs(fname);
  end;
end;

function TKWord.getAsText: string;
begin
  FWordDoc := FWordApp.ActiveDocument;
  Result := FWordDoc.Range.Text;
end;

function TKWord.GetVisible: Boolean;
begin
  Result := FWordApp.Vsisible;
end;

procedure TKWord.InsertText(s: string);
begin
  FWordDoc := FWordApp.ActiveDocument;
  FWordDoc.Range.InsertAfter(s);
end;

function TKWord.MacroExec(s, arg: string): string;
begin
  if arg = '' then
    Result := FWordApp.Run(s)
  else
    Result := FWordApp.Run(s, arg);
end;

procedure TKWord.NewDoc;
begin
  FWordApp.Application.Documents.Add;
end;

procedure TKWord.Open(Visible: Boolean);
begin
  if FActive then Close;

  FWord := CreateOleObject('Word.Application');
  FWordApp := FWord.Application;
  FWordApp.Visible := Visible;
  FActive := True;
end;

procedure TKWord.Print;
begin
  FWordDoc := FWordApp.ActiveDocument;
  FWordDoc.PrintOut;
end;

procedure TKWord.PrintPreview;
begin
  FWordDoc := FWordApp.ActiveDocument;
  FWordDoc.PrintPreview;
end;

{
    Selection.Find.ClearFormatting
    Selection.Find.Replacement.ClearFormatting
    With Selection.Find
        .Text = a
        .Replacement.Text = b
        .Forward = True
        .Wrap = wdFindContinue
        .Format = False
        .MatchCase = False
        .MatchWholeWord = False
        .MatchByte = False
        .MatchAllWordForms = False
        .MatchSoundsLike = False
        .MatchWildcards = False
        .MatchFuzzy = True
    End With
    Selection.Find.Execute Replace:=wdReplaceAll
}
procedure TKWord.replace(a, b: string);
begin
  FWordApp.Selection.Find.ClearFormatting;
  FWordApp.Selection.Find.Replacement.ClearFormatting;
  // with
  FWordApp.Selection.Find.Forward := True;
  FWordApp.Selection.Find.MatchCase := False;
  FWordApp.Selection.Find.MatchWholeWord := False;
  FWordApp.Selection.Find.MatchByte := False;
  FWordApp.Selection.Find.MatchAllWordForms := False;
  FWordApp.Selection.Find.MatchSoundsLike := False;
  FWordApp.Selection.Find.MatchWildcards := False;
  FWordApp.Selection.Find.MatchFuzzy := True;
  // execute
  FWordApp.Selection.Find.Execute(a, False, False, False, False, False, True, 1, False, b, 2);
end;

procedure TKWord.SetVisible(const Value: Boolean);
begin
  FWordApp.Visible := Value;
end;

{ TKAdo }

procedure TKAdo.Close;
begin
  try
    FAdoRecSet.Close;
  except end;
  try
    FAdoConnect.Close;
  except end;
  FAdoRecSet  := Unassigned;
  FAdoConnect := Unassigned;
end;

constructor TKAdo.Create;
begin
  FAdoConnect := Unassigned;
  FAdoRecSet  := Unassigned;
end;

function TKAdo.dbBOF: Boolean;
begin
  try
    Result := (FAdoRecSet.Bof <> 0);
  except on e: Exception do
    raise Exception.Create('DBレコードを認識できません。'+e.Message);
  end;
end;

function TKAdo.dbEOF: Boolean;
begin
  try
    Result := (FAdoRecSet.Eof <> 0);
  except on e: Exception do
    raise Exception.Create('DBレコードを認識できません。'+e.Message);
  end;
end;

destructor TKAdo.Destroy;
begin
  Close;
  inherited;
end;

procedure TKAdo.Find(table, field, key: string);
begin
  sql('SELECT * FROM ' + table + ' WHERE ' + field + ' LIKE "%' + key + '%"');
end;

function TKAdo.GetCurRecAsCsv: string;
var
  i, fcnt: Integer;
  line, c: string;

  function chk(s: string): string;
  begin
    if (Pos('"',s) > 0)or(Pos(',', s)>0)or(Pos(#13,s)>0)or(Pos(#10,s)>0) then s := '"' + JReplace(s, '"', '""', True) + '"';
    Result := s;
  end;

begin
  try
    fcnt := FAdoRecSet.Fields.Count; // フィールド数
  except
    raise Exception.Create('DBレコードのフィールド数が取得できません。');
  end;

  // レコードを巡回して結果を取得
  // フィールドから取得
  for i := 0 to fcnt-1 do
  begin
    try
      c := FAdoRecSet.Fields.Item(i).value;
    except
      c := '';
    end;
    c := chk(c);
    if line <> '' then line := line + ',';
    line := line + c;
  end;

  Result := line;
end;

function TKAdo.GetCurRecAsTsv: string;
var
  i, fcnt: Integer;
  line, c: string;
begin
  try
    fcnt := FAdoRecSet.Fields.Count; // フィールド数
  except
    raise Exception.Create('DBレコードのフィールド数が取得できません。');
  end;

  // レコードを巡回して結果を取得
  // フィールドから取得
  for i := 0 to fcnt-1 do
  begin
    try
      c := FAdoRecSet.Fields.Item(i).value;
    except
      c := '';
    end;
    if Pos(#9,c) > 0 then c := JReplace(c, #9, '{\t}', True);
    if line <> '' then line := line + #9;
    line := line + c;
  end;

  Result := line;
end;

function TKAdo.GetFieldNames: string;
var
  i, fcnt: Integer;
  s: string;
begin
  s    := '';
  try
    fcnt := FAdoRecSet.Fields.Count; // フィールド数
  except on e: Exception do
    raise Exception.Create('フィールド数が取得できません。SQLが一度も発行されていない可能性があります。' + e.Message);
  end;

  // フィールド名を得る
  Result := '';
  for i := 0 to fcnt-1 do
  begin
    if Result <> '' then Result := Result + #13#10;
    Result := Result + FAdoRecSet.Fields.Item(i).name;
  end;
  
end;

function TKAdo.GetFieldValue(field: string): string;
begin
  try
    Result := FAdoRecSet.Fields.Item(field).value;
  except
    Result := '';
  end;
end;

function TKAdo.GetRecordCount: Integer;
begin
  try
    Result := FAdoRecSet.RecordCount;
  except
    raise Exception.Create('レコード数が取得できません。');
  end;
end;

function TKAdo.GetSqlResultAsCsv: string;
var
  i, fcnt: Integer;
  line, c, s: string;

  function chk(s: string): string;
  begin
    if (Pos('"',s) > 0)or(Pos(',', s)>0)or(Pos(#13,s)>0)or(Pos(#10,s)>0) then s := '"' + JReplace(s, '"', '""', True) + '"';
    Result := s;
  end;

begin
  s    := '';
  try
    fcnt := FAdoRecSet.Fields.Count; // フィールド数
  except on e: Exception do
    raise Exception.Create('フィールド数が取得できません。SQLが一度も発行されていない可能性があります。' + e.Message);
  end;

  // フィールド名を得る
  Result := '';
  for i := 0 to fcnt-1 do
  begin
    if Result <> '' then Result := Result + ',';
    Result := Result + chk(FAdoRecSet.Fields.Item(i).name);
  end;
  Result := Result + #13#10;

  try
    FAdoRecSet.MoveFirst; // Top に移動
  except
    Exit;
  end;

  // レコードを巡回して結果を取得
  while FAdoRecSet.Eof = 0 do
  begin
    line := '';
    // フィールドから取得
    for i := 0 to fcnt-1 do
    begin
      try
        c := FAdoRecSet.Fields.Item(i).value;
      except
        c := '';
      end;
      c := chk(c);
      if line <> '' then line := line + ',';
      line := line + c;
    end;
    if s <> '' then s := s + #13#10;
    s := s + line;
    FAdoRecSet.MoveNext;
  end;
  Result := Result + s;
end;

function TKAdo.GetSqlResultAsTsv: string;
var
  i, fcnt: Integer;
  line, c, s: string;

  function chk(s: string): string;
  begin
    if Pos(#9,s) > 0 then s := JReplace(s, #9, '{\t}', True);
    Result := s;
  end;

begin
  s := '';
  try
    fcnt := FAdoRecSet.Fields.Count; // フィールド数
  except on e: Exception do
    raise Exception.Create('フィールド数が取得できません。SQLが一度も発行されていない可能性があります。' + e.Message);
  end;

  // フィールド名を得る
  Result := '';
  for i := 0 to fcnt-1 do
  begin
    if Result <> '' then Result := Result + #9;
    Result := Result + chk(FAdoRecSet.Fields.Item(i).name);
  end;
  Result := Result + #13#10;

  try
    FAdoRecSet.MoveFirst; // Top に移動
  except
    Exit;
  end;

  // レコードを巡回して結果を取得
  while FAdoRecSet.Eof = 0 do
  begin
    line := '';
    // フィールドから取得
    for i := 0 to fcnt-1 do
    begin
      try
        c := FAdoRecSet.Fields.Item(i).value;
      except
        c := '';
      end;
      if Pos(#9, c) > 0 then c := JReplace(c, #9, '{\t}', True);
      if line <> '' then line := line + #9;
      line := line + c;
    end;
    if s <> '' then s := s + #13#10;
    s := s + line;
    FAdoRecSet.MoveNext;
  end;
  Result := Result + s;
end;

function TKAdo.GetTableAsCsv(table: string): string;
begin
  try
    sql('SELECT * FROM ' + table);
    Result := GetSqlResultAsCsv;
  except on e: Exception do
    raise Exception.Create(table + 'の取得に失敗。' + e.Message);
  end;
end;

procedure TKAdo.MoveFirst;
begin
  try
    FAdoRecSet.MoveFirst;
  except on e: Exception do
    raise Exception.Create('DBレコードの移動に失敗。' + e.Message);
  end;
end;

procedure TKAdo.MoveLast;
begin
  try
    FAdoRecSet.MoveLast;
  except on e: Exception do
    raise Exception.Create('DBレコードの移動に失敗。' + e.Message);
  end;
end;

procedure TKAdo.MoveNext;
begin
  try
    FAdoRecSet.MoveNext;
  except on e: Exception do
    raise Exception.Create('DBレコードの移動に失敗。' + e.Message);
  end;
end;

procedure TKAdo.MovePrev;
begin
  try
    FAdoRecSet.MovePrevious;
  except on e: Exception do
    raise Exception.Create('DBレコードの移動に失敗。' + e.Message);
  end;
end;

procedure TKAdo.Open(provider, source: string);
var
  s: string;
begin
  DbProvider   := provider;
  DbDataSource := source;

  // 接続情報文字列の生成
  s := '';
  s := s + 'Provider='     + DbProvider + ';';
  s := s + 'Data Source="' + DbDataSource + '";';

  // 微妙な部分
  {
  if DbUserId   <> '' then s := s + 'UID=' + DbUserId   + ';';
  if DbPassword <> '' then s := s + 'PWD=' + DbPassword + ';';
  }

  // 接続
  OpenCustom(s);
end;

procedure TKAdo.OpenAccess(dbname, user, password: string);
var
  s: string;
begin
  if user = '' then user := 'Admin';

  DbProvider   := 'Microsoft.Jet.OLEDB.4.0';
  DbDataSource := dbname;
  DbUserId     := user;
  DbPassword   := password;
  //
  s := Format('Provider=%s;Data Source=%s;'+
      'Persist Security Info=False;'+
      'User ID=%s;Jet OLEDB:Database Password=%s;',
      [DbProvider, DbDataSource, DbUserId, DbPassword]);
  //
  OpenCustom(s);
end;


procedure TKAdo.OpenAccess2007(dbname, user, password: string);
var
  s: string;
begin
  if user = '' then user := 'Admin';

  DbProvider   := 'Microsoft.ACE.OLEDB.12.0';
  DbDataSource := dbname;
  DbUserId     := user;
  DbPassword   := password;
  //
  s := Format('Provider=%s;Data Source=%s;'+
    'Persist Security Info=False;'+
    'User ID=%s;Jet OLEDB:Database Password=%s;',
    [DbProvider, DbDataSource, DbUserId, DbPassword]);
  //
  OpenCustom(s);
end;

procedure TKAdo.OpenCustom(cinfo: string);
begin
  try
    FAdoConnect := CreateOleObject('ADODB.Connection');
    FAdoConnect.Open(cinfo);

    FAdoRecSet  := CreateOleObject('ADODB.Recordset');
    FAdoRecSet.ActiveConnection := FAdoConnect;
    
  except on e: Exception do
    raise Exception.Create('DBとの接続に失敗。' + e.Message);
  end;
end;

procedure TKAdo.OpenOracle(dbname, user, password: string);
var
  fmt, s: string;
begin
  if user = '' then user := 'Admin';

  DbProvider   := 'MSDAORA.1';
  DbDataSource := dbname;
  DbUserId     := user;
  DbPassword   := password;

  // 接続文字列
  fmt := 'Provider=%s;User ID=%s;password=%s;' +
         'Data Source=%s;Persist Security Info=False';
  s := Format(fmt,
        [
            DbProvider, DbUserId, DbPassword,
            DbDataSource
        ]);

  // 接続
  OpenCustom(s);
end;

procedure TKAdo.OpenSQLServer(dbname, user, password: string);
var
  fmt, s: string;
begin
  if user = '' then user := 'Admin';
  
  DbProvider   := 'SQLOLEDB.1';
  DbDataSource := dbname;
  DbUserId     := user;
  DbPassword   := password;

  // 接続文字列
  fmt :=  'Provider=%s;Persist Security Info=False;Data Source=%s;User ID=%s;Password=%s';
  s := Format(fmt, [ DbProvider, DbDataSource, DbUserId, DbPassword]);
  // 接続
  OpenCustom(s);
end;

procedure TKAdo.OpenSQLServer2005(server, dbname, user, password: string);
var
  fmt, s: string;
begin
  if user = '' then user := 'sa';

  DbProvider   := '{SQL Server}';
  DbDataSource := dbname;
  DbUserId     := user;
  DbPassword   := password;

  // 接続文字列
  fmt := 'Driver=%s;server=%s;database=%s; uid=%s; pwd=%s;';
  s := Format(fmt, [DbProvider, DbDataSource, DbUserId, DbPassword]);
  // 接続
  OpenCustom(s);
end;

procedure TKAdo.SQL(cmd: string);
var
  state: Integer;
begin
{ obj.state
        0 adStateClosed     閉じている
        1 adStateOpen       オープン
        2 adStateConnecting 接続中
        4 adStateExecuting  実行中
        8 adStateFetching   行を取得
}

  try
    // 状態が開いているなら閉じる
    try
      state := FAdoRecSet.State;
      if state <> 0 then FAdoRecSet.Close;
    except
    end;
    // SQL 発行
    FAdoRecSet.Open(cmd, FAdoConnect);
  except on e: Exception do
    raise Exception.Create('SQL文の発行に失敗。' + e.Message);
  end;
end;

{ TKPowerPoint }

procedure TKPowerPoint.AddSlide;
begin
  // Slid の追加
  FPpApp.ActivePresentation.Slides.Add(
    FPpApp.ActivePresentation.Slides.Count,
    12);
end;

procedure TKPowerPoint.Close(AlertOff: Boolean);
begin
  try
    FPpApp.Quit;
  except end;
  //
  FPp       := Unassigned;
  FPpApp    := Unassigned;
  //
end;

constructor TKPowerPoint.Create;
begin
  FActive := False;
end;

destructor TKPowerPoint.Destroy;
begin
  Close;
  inherited;
end;

procedure TKPowerPoint.FileOpen(fname: string);
begin
  FPp.Presentations.Open(fname);
end;

procedure TKPowerPoint.FileSave(fname: string);
begin
  FPpApp.ActivePresentation.SaveAs(fname);
end;

function TKPowerPoint.GetVisible: Boolean;
begin
  Result := FPpApp.Visible;
end;

procedure TKPowerPoint.GotoSlide(Index: Integer);
begin
  FPpApp.ActiveWindow.View.GotoSlide(Index);
end;

function TKPowerPoint.MacroExec(s, arg: string): string;
begin
  if arg = '' then
    Result := FPpApp.Run(s)
  else
    Result := FPpApp.Run(s, arg);
end;

procedure TKPowerPoint.Open(Visible: Boolean);
begin
  if FActive then Close;
  try
    FPp := GetActiveOleObject('PowerPoint.Application');
  except
    FPp := CreateOleObject('PowerPoint.Application');
  end;

  FPpApp := FPp;
  try
    FPpApp.Visible := Visible;
  except
  end;
  FActive := True;
end;

procedure TKPowerPoint.Print;
begin
  FPpApp.ActivePresentation.PrintOut;
end;

function ppt_checkDir(dir:string): string;
var
  ws: WideString;
begin
  ws := dir;
  if Copy(ws, Length(ws), 1) = '\' then
  begin
    System.Delete(ws, Length(ws), 1);
  end;
  Result := ws;
end;

procedure TKPowerPoint.SaveToJpegDir(dir: string);
begin
  ForceDirectories(dir);
  FPpApp.ActivePresentation.SaveAs(ppt_checkDir(dir), ppSaveAsJPG);
end;

procedure TKPowerPoint.SaveToPdfDir(dir: string);
begin
  ForceDirectories(dir);
  FPpApp.ActivePresentation.SaveAs(ppt_checkDir(dir), ppSaveAsPDF);
end;

procedure TKPowerPoint.SaveToPDFFile(f: string);
begin
  FPpApp.ActivePresentation.SaveAs(f, ppSaveAsPDF);
end;

procedure TKPowerPoint.SaveToPngDir(dir: string);
begin
  ForceDirectories(dir);
  FPpApp.ActivePresentation.SaveAs(ppt_checkDir(dir), ppSaveAsPNG);
end;

procedure TKPowerPoint.SetVisible(const Value: Boolean);
begin
  FPpApp.Visible := Value;
end;

procedure TKPowerPoint.SlideExit;
begin
  FPpApp.ActivePresentation.SlideShowWindow.View.Exit;
end;

procedure TKPowerPoint.SlideNext;
begin
  FPpApp.ActivePresentation.SlideShowWindow.View.Next;
end;

procedure TKPowerPoint.SlidePrev;
begin
  FPpApp.ActivePresentation.SlideShowWindow.View.Previous;
end;

procedure TKPowerPoint.SlideStart;
begin
  FPp.ActivePresentation.SlideShowSettings.Run;
end;

initialization
begin
  CoInitialize(nil);
end;

finalization
begin
  CoUninitialize;
end;

end.
