unit OpenOffice;

interface

uses ComObj, Variants, sysutils, CsvUtils2;

type
  TCalcField = record
    Col : integer;
    Row : integer;
  end;

  TOpenOfficeorg = class(TObject)
    private
      fOpenOffice : Variant;
      fDocument   : Variant;
      fSheet      : Variant;
      fDesktop    : Variant;
      fDisp       : Variant;
      fConnected  : boolean;
      fDocumentOpened : boolean;
      fHTMLSrc : boolean;

      procedure Set_ActiveSheet(const Value: string);
      function get_ActiveSheet: string;

      procedure set_CellText(CellName: string; const Value: string);
      function Get_CellText(CellName: string): string;

      procedure set_CellValue(CellName: string; const Value: real);
      function Get_CellValue(CellName: string): real;

      function MakePropertyValue(PropName:string; PropValue:variant):variant;
      function CreateUnoService(name:String): Variant;
      function StrToURL(FileName:string):string;
      function getDesktop:Variant;
      function getDisp:Variant;
    public
      constructor Create;
      destructor Destroy; override;
      function Connect : boolean;
      procedure Disconnect;
      function  OpenDocument(Filename:string; Hidden:Boolean = True):boolean;
      procedure NewDocumentCalc(Hidden:Boolean = True);
      procedure NewDocumentWriter(Hidden:Boolean = True);
      procedure NewDocument(DocType:String; Hidden:Boolean = True);
      procedure NewSheet(Name:String);
      procedure SetActiveSheetByName(name:String);
      procedure SetActiveSheetByIndex(Index:Integer);
      procedure SaveToPDF(FileName:string);
      procedure SaveToCsv(FileName:String);
      procedure SaveDocument(const FileName, Format:String);
      procedure CloseDocument;
      procedure Print(num:integer);
      procedure InsertTextWriter(text:String);
      procedure InsertBookmarkWriter(BookmarkName:String; Text:String);
      function CellNameToCR(CellName:string):TCalcField;
      procedure setCell(row, col:Integer; value:String);
      procedure setCellByName(CellName, value:String);
      function getCell(CellName: String): String;
      function getCellByIndex(row, col: Integer): String;
      procedure setCellEx(CellName:String; strCsv:String);
      function getCellEx(Cell1, Cell2:String): string;
      procedure selectRange(Cell:String);
      procedure copySelection;
      procedure paste;
      procedure CellColor(color:Integer);
      procedure sheetPrintPreview;
      procedure selectAll;
      function writer_getText: string;
    published
      property ActiveSheet:string read get_ActiveSheet write Set_ActiveSheet;
    public
      property CellValue[CellName:string]: real read Get_CellValue write set_CellValue;
      property CellText[CellName:string]: string read Get_CellText write set_CellText;
      property DocumentOpened:Boolean read fDocumentOpened;
  end;

const
  OO_FORMAT_HTML = 'scalc: Text - txt';
  OO_FORMAT_XML  = 'swriter: StarOffice XML (Writer)';
  OO_FORMAT_PDF  = 'calc_pdf_Export';
  OO_FORMAT_EXCEL  = 'MS Excel 97';
  OO_FORMAT_WORD   = 'MS Word 97';
  OO_FORMAT_CSV    = 'Text - txt - csv (StarCalc)';

  CSIDL_DESKTOPDIRECTORY 		=$0010;//「デスクトップ」上のファイルオブジェクトを格納するフォルダ（ファイルシステムディレクトリ）
  CSIDL_PERSONAL 		        =$0005;//「マイ ドキュメント」（ファイルシステムディレクトリ）

function DesktopDir:string;
function MyDocumentDir:string;
function GetSpecialFolder(const loc:Word): string;

implementation

uses
   ActiveX, ShlObj, Windows;

function GetSpecialFolder(const loc:Word): string;
var
   PathID: PItemIDList;
   Path : array[0..MAX_PATH] of char;
begin
   SHGetSpecialFolderLocation(GetActiveWindow, loc, PathID);
   SHGetPathFromIDList(PathID, Path);
   Result := string(Path);
   if Copy(Result, Length(Result),1)<>'\' then
    Result := Result + '\';
end;

function DesktopDir:string;
begin
   Result := GetSpecialFolder(CSIDL_DESKTOPDIRECTORY);
end;

function MyDocumentDir:string;
begin
   Result := GetSpecialFolder(CSIDL_PERSONAL);
end;


procedure TOpenOfficeOrg.CloseDocument;
begin
  if fDocumentOpened then
  begin
    fSheet := Unassigned;
    fDisp  := Unassigned;
    try
      fDocument.Close(false);
    except
    end;
    fDocumentOpened := false;
    fDocument := Unassigned;
  end;
end;

function TOpenOfficeOrg.Connect: boolean;
begin
  if  VarIsEmpty(fOpenOffice) then
  begin
    fOpenOffice := CreateOleObject('com.sun.star.ServiceManager');
  end;
  fConnected := not (VarIsEmpty(fOpenOffice) or VarIsNull(fOpenOffice));
  Result := fConnected;
end;

constructor TOpenOfficeOrg.Create;
begin
  inherited;
  CoInitialize(nil);
end;

destructor TOpenOfficeOrg.Destroy;
begin
  try
    Disconnect;
  except
  end;
  CoUninitialize;
  inherited;
end;

procedure TOpenOfficeOrg.Disconnect;
begin
    if fDocumentOpened then
       CloseDocument;

    try
      if not VarIsEmpty(fDesktop) then
        fDesktop.Terminate;
    except
    end;
    fDesktop := UnAssigned;

    fConnected := false;
    fOpenOffice := Unassigned;
end;

function TOpenOfficeorg.get_ActiveSheet: string;
begin
  result:=fSheet.getName;
end;

function TOpenOfficeOrg.OpenDocument(Filename: string; Hidden:Boolean = True): boolean;
var
  wProperties   : Variant;
  wViewSettings : Variant;
  wController   : Variant;
  ext: String;
begin
  ext := LowerCase(ExtractFileExt(Filename));
  if not fConnected then
      abort;
  if VarIsEmpty(fDesktop) then begin
    fDesktop := fOpenOffice.createInstance('com.sun.star.frame.Desktop');
  end;

  wProperties := VarArrayCreate([0, 0], varVariant);
  wProperties[0] := MakePropertyValue('Hidden', Hidden);
  fDocument := fDesktop.loadComponentFromURL( StrToUrl(Filename), '_blank', 0, wProperties);
  fDocumentOpened := not (VarIsEmpty(fDocument) or VarIsNull(fDocument));
  fHTMLSrc := pos('.htm', lowercase(extractfileext(Filename))) > 0;

  if fDocumentOpened and fHTMLSrc then
  begin
    wController := fDocument.Getcurrentcontroller;
    if not (VarIsEmpty(wController) or VarIsNull(wController)) then
    begin
      wViewSettings := wController.getviewsettings;
      if not (VarIsEmpty(wViewSettings) or VarIsNull(wViewSettings)) then
      wViewSettings.ShowOnlineLayout := false;
   end;
   wViewSettings := Unassigned;
   wController   := Unassigned;
  end;
  try
    if pos(ext,'.xls.csv.ods.ots.sxc.stc.dif.dbf.xlt.sdc.vor.slk.xml') > 0 then
    begin
      fSheet := fDocument.getsheets.getByIndex(0) ;
    end;
  except
  end;
  result := fDocumentOpened;
end;

procedure TOpenOfficeOrg.SaveToPDF(FileName: string);
var
   wProperties: variant;
begin
   if not (fConnected and fDocumentOpened) then
      abort;

   wProperties := VarArrayCreate([0, 4], varVariant);
   if fHTMLSrc then
      wProperties[0] := MakePropertyValue('FilterName', 'calc_web_pdf_Export')
   else
      wProperties[0] := MakePropertyValue('FilterName', 'calc_pdf_Export');

   wProperties[1] := MakePropertyValue('CompressionMode', '1');
   wProperties[2] := MakePropertyValue('PageRange', '1-2');
   wProperties[3] := MakePropertyValue('SelectionOnly', TRUE);
   wProperties[4] := MakePropertyValue('Overwrite', TRUE);

   fDocument.StoreToURL(StrToUrl(Filename), wProperties);
end;

function TOpenOfficeorg.Get_CellText(CellName: string): string;
begin
 result:=fSheet.getCellByPosition(CellNameToCR(Cellname).col,CellNameToCR(Cellname).row).String;;
end;

function TOpenOfficeorg.Get_CellValue(CellName: string): real;
begin
 result:=fSheet.getCellByPosition(CellNameToCR(Cellname).col,CellNameToCR(Cellname).row).getValue;
end;

procedure TOpenOfficeorg.Set_ActiveSheet(const Value: string);
begin
 fSheet := fDocument.getsheets.getByName(Value);
end;

procedure TOpenOfficeorg.set_CellText(CellName: string;
  const Value: string);
begin
  fSheet.getCellByPosition(CellNameToCR(Cellname).col,CellNameToCR(Cellname).row).setFormula(value);
end;

procedure TOpenOfficeorg.set_CellValue(CellName: string;
  const Value: real);
begin
  fSheet.getCellByPosition(CellNameToCR(Cellname).col,CellNameToCR(Cellname).row).setValue(value);
end;

function TOpenOfficeOrg.StrToURL(FileName:string):string;
begin
  if Pos(':\', FileName) = 0 then
  begin
    FileName := MyDocumentDir + FileName;
  end;
  result:='file:///'+ StringReplace(FileName, '\', '/', [rfIgnoreCase, rfReplaceAll]);
end;

function TOpenOfficeOrg.MakePropertyValue(PropName: string;
    PropValue: variant): variant;
var
   Struct: variant;
begin
    Struct := fOpenOffice.Bridge_GetStruct('com.sun.star.beans.PropertyValue');
    Struct.Name := PropName;
    Struct.Value := PropValue;
    Result := Struct;
end;

function TOpenOfficeorg.CellNameToCR(CellName: string): TCalcField;
var
  Temp:TcalcField;
  C : integer;
  R : integer;
  i : integer;
begin
  i:=1;
  C:=0;
  //R:=0;
  CellName:=lowerCase(CellName);
  while (i<length(CellName)) and (ord(CellName[i])>64) do i:=i+1;

  if i=2 then C:=ord(cellName[i-1])-97;
  if i=3 then C:=(ord(cellName[1])-96)*26+(ord(cellName[2])-97);
  if i>3 then ;//showmessage('invalid column');
  R:= strtoint(copy(CellName,i,length(CellName)))-1;
  temp.Col :=C;
  temp.Row :=R;
  result:=temp;
end;

procedure TOpenOfficeorg.SaveDocument(const FileName, Format:String);
var
   wProperties: variant;
   fname:String;
begin
   if not (fConnected and fDocumentOpened) then
      abort;

   wProperties := VarArrayCreate([0, 4], varVariant);
   wProperties[0] := MakePropertyValue('FilterName', Format);
   wProperties[1] := MakePropertyValue('CompressionMode', '1');
   wProperties[2] := MakePropertyValue('Overwrite', TRUE);
   wProperties[3] := MakePropertyValue('PageRange', '1-2');
   wProperties[4] := MakePropertyValue('SelectionOnly', TRUE);

   fname := StrToUrl(Filename);
   fDocument.StoreToURL(fname, wProperties);
end;



procedure TOpenOfficeorg.Print(num: integer);
const Bounds:array[1..2] of integer = (0,0);
var
    VariantArray: Variant;
begin
 if ( num < 1 ) or ( num > 512 ) then
     num := 1;
 VariantArray := VarArrayCreate(Bounds, varVariant);
 VariantArray[0]:= MakePropertyValue('CopyCount',num);
 fDocument.print(VariantArray);
end;


procedure TOpenOfficeorg.SaveToCsv(FileName: String);
var
   wProperties: variant;
begin
   if not (fConnected and fDocumentOpened) then
      abort;

   wProperties := VarArrayCreate([0, 1], varVariant);
   wProperties[0] := MakePropertyValue('FilterName', OO_FORMAT_CSV);
   wProperties[1] := MakePropertyValue('FilterOptions', '44,34,76');

   fDocument.StoreToURL(StrToUrl(Filename), wProperties);
end;

procedure TOpenOfficeorg.InsertTextWriter(text: String);
var
   TextPointer: Variant;
   CursorPointer: Variant;
begin
   TextPointer := fDocument.GetText;
   CursorPointer := TextPointer.CreateTextCursor;
   CursorPointer.gotoEnd(False);

   TextPointer.InsertString(CursorPointer, text, false);
   TextPointer.InsertControlCharacter(CursorPointer, 0, false);
end;

procedure TOpenOfficeorg.InsertBookmarkWriter(BookmarkName, Text: String);
var
  TextPointer: Variant;
  CursorPointer: Variant;
  BookmarksSupplier: Variant;
  Bookmark: Variant;
  Flag: boolean;
begin
  Flag := True;
  TextPointer := fDocument.GetText;
  CursorPointer := TextPointer.CreateTextCursor;
  BookmarksSupplier := fDocument.getBookmarks;
  try
    Bookmark := BookmarksSupplier.getByName(BookmarkName).getAnchor;
  except
    Flag := False;
  end;
  if (Flag) then Bookmark.setString(Text);
end;

procedure TOpenOfficeorg.NewDocumentCalc(Hidden: Boolean);
begin
  NewDocument('private:factory/scalc', Hidden);
end;

procedure TOpenOfficeorg.NewDocument(DocType: String; Hidden: Boolean);
var
  wProperties   : Variant;
begin
  if not fConnected then
      abort;
  if VarIsEmpty(fDesktop) then begin
    fDesktop := fOpenOffice.createInstance('com.sun.star.frame.Desktop');
  end;

  wProperties := VarArrayCreate([0, 0], varVariant);
  wProperties[0] := MakePropertyValue('Hidden', Hidden);

  fDocument := fDesktop.loadComponentFromURL( DocType, '_blank', 0, wProperties);
  fDocumentOpened := not (VarIsEmpty(fDocument) or VarIsNull(fDocument));
end;

procedure TOpenOfficeorg.NewDocumentWriter(Hidden: Boolean);
begin
  NewDocument('private:factory/swriter', Hidden);
end;

procedure TOpenOfficeorg.NewSheet(Name:String);
var
  count :Integer;
begin
  if not fConnected then abort;
  if Name = '' then
  begin
    count := fDocument.getSheets.count + 1;
    Name := '表' + IntToStr(count);
  end;
  fDocument.getSheets.insertNewByName(Name, 0);
  SetActiveSheetByName(Name);
end;

procedure TOpenOfficeorg.SetActiveSheetByName(name: String);
var
  myView: Variant;
begin
  if not fConnected then abort;

  myView := fDocument.CurrentController;
  fSheet := fDocument.Sheets.getByName(name);
  myView.setActiveSheet(fSheet);
end;

procedure TOpenOfficeorg.SetActiveSheetByIndex(Index: Integer);
var
  myView: Variant;
begin
  if not fConnected then abort;

  myView := fDocument.CurrentController;
  fSheet := fDocument.Sheets.getByIndex(Index);
  myView.setActiveSheet(fSheet);
end;

function TOpenOfficeorg.getDesktop: Variant;
begin
  if VarIsEmpty(fDesktop) then
  begin
    fDesktop := CreateUnoService('com.sun.star.frame.Desktop');
  end;
  Result := fDesktop;
end;

function TOpenOfficeorg.getDisp: Variant;
begin
  if VarIsEmpty(fDisp) then
  begin
    fDisp := CreateUnoService('com.sun.star.frame.DispatchHelper');
  end;
  Result := fDisp;
end;

function TOpenOfficeorg.CreateUnoService(name: String): Variant;
begin
  Result := fOpenOffice.createInstance(name);
end;

procedure TOpenOfficeorg.setCell(row, col:Integer; value: String);
var
  Cell: Variant;
begin
  Cell := fSheet.getCellByPosition(col, row);
  Cell.setString(value);
end;

procedure TOpenOfficeorg.setCellByName(CellName, value: String);
var
  Cell: Variant;
begin
  Cell:= fSheet.getCellRangeByName(CellName);
  Cell.setString(value);
end;

function TOpenOfficeorg.getCell(CellName: String): String;
var
  Cell: Variant;
  c: TCalcField;
begin
  //Cell:= fSheet.getCellRangeByName(CellName);
  c := CellNameToCR(CellName);
  Cell:= fSheet.getCellByPosition(c.col, c.row);
  Result := Cell.String;
  // Cell.Formula だと、式を取得してしまう
end;

procedure TOpenOfficeorg.setCellEx(CellName, strCsv: String);
var
  col, row: Integer;
  x, y: Integer;
  csv: TCsvSheet;
  cc: TCalcField;
  scell: string;
begin
  cc := CellNameToCR(CellName);
  col := cc.Col;
  row := cc.Row;

  if VarIsEmpty(fSheet) then
  begin
    SetActiveSheetByIndex(0);
  end;

  csv := TCsvSheet.Create;
  try
    csv.AsText := strCsv;
    for y := 0 to csv.Count - 1 do
    begin
      for x := 0 to csv.ColCount - 1 do
      begin
        scell := csv.Cells[x, y];
        setCell(y+row, x+col, scell);
      end;
    end;
  finally
    csv.Free;
  end;

end;

function TOpenOfficeorg.getCellEx(Cell1, Cell2: String): string;
var
  col, row: Integer;
  x, y: Integer;
  csv: TCsvSheet;
  c1, c2: TCalcField;
begin
  c1 := CellNameToCR(Cell1);
  c2 := CellNameToCR(Cell2);

  csv := TCsvSheet.Create;
  try
    for y := c1.Row to c2.Row do
    begin
      for x := c1.Col to c2.Col do
      begin
        col := x - c1.Col;
        row := y - c1.Row;
        csv.Cells[col, row] := getCellByIndex(y, x);
      end;
    end;
    Result := csv.AsText;
  finally
    csv.Free;
  end;

end;

function TOpenOfficeorg.getCellByIndex(row, col:Integer): String;
var
  Cell: Variant;
begin
  Cell:= fSheet.getCellByPosition(col, row);
  Result := Cell.String;
end;

procedure TOpenOfficeorg.selectRange(Cell: String);
var
  args:Variant;
begin
  getDesktop;
  getDisp;
  args    := VarArrayCreate([0,0], varVariant);
  args[0] := MakePropertyValue('ToPoint', Cell);
  fDisp.executeDispatch(fDesktop.CurrentFrame, '.uno:GoToCell', '', 0, args);
end;

procedure TOpenOfficeorg.copySelection;
var
  args:Variant;
begin
  getDesktop;
  getDisp;
  args    := VarArrayCreate([0, -1], varVariant);
  fDisp.executeDispatch(fDesktop.CurrentFrame, '.uno:Copy', '', 0, args);
end;

procedure TOpenOfficeorg.paste;
var
  args:Variant;
begin
  getDesktop;
  getDisp;
  args    := VarArrayCreate([0, -1], varVariant);
  fDisp.executeDispatch(fDesktop.CurrentFrame, '.uno:Paste', '', 0, args);
end;

procedure TOpenOfficeorg.CellColor(color: Integer);
var
  args:Variant;
begin
  getDesktop;
  getDisp;
  args    := VarArrayCreate([0, 0], varVariant);
  args[0] := MakePropertyValue('BackgroundColor', color);
  fDisp.executeDispatch(fDesktop.CurrentFrame, '.uno:BackgroundColor', '', 0, args);
end;

procedure TOpenOfficeorg.sheetPrintPreview;
var
  args:Variant;
begin
  getDesktop;
  getDisp;
  args    := VarArrayCreate([0, -1], varVariant);
  fDisp.executeDispatch(fDesktop.CurrentFrame, '.uno:PrintPreview', '', 0, args);
end;


procedure TOpenOfficeorg.selectAll;
var
  args:Variant;
begin
  getDesktop;
  getDisp;
  args    := VarArrayCreate([0, -1], varVariant);
  fDisp.executeDispatch(fDesktop.CurrentFrame, '.uno:SelectAll', '', 0, args);
end;

function TOpenOfficeorg.writer_getText: string;
begin
  Result := fDocument.Text.GetString;
end;

end.
