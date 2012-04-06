unit CsvUtils2;

interface
uses
  SysUtils, Classes;

type
  PCsvProgressFunc = ^TCsvProgressFunc;
  TCsvProgressFunc = procedure (percent: Integer; var Cancel: Boolean) of Object;

  TCsvCells = class
  private
    list: TList;
    function GetCount: Integer;
    function GetValue(Index: Integer): AnsiString;
    procedure SetValue(Index: Integer; const Value: AnsiString);
    procedure SetCount(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; virtual;
    procedure Delete(Index: Integer);
    function GetCommaText: AnsiString;
    function GetCommaTextEx(Splitter: AnsiChar; ColCount: Integer = -1): AnsiString;
    function GetTabText: AnsiString;
    function Add(Value: AnsiString): Integer;
    property Count: Integer read GetCount write SetCount;
    procedure Insert(Index: Integer; Value: AnsiString);
    procedure Move(FromI, ToI: Integer);
    property Values[Index: Integer]: AnsiString read GetValue write SetValue;
    procedure Assign(Source: TCsvCells);
    procedure TrimLast;
    function AllBlank: Boolean;
  end;

  TCsvSheet = class
  private
    list: TList;
    FUseHeader: Boolean;
    function GetCount: Integer;
    function GetCell(ACol, ARow: Integer): AnsiString;
    procedure SetCell(ACol, ARow: Integer; const Value: AnsiString);
    procedure SetCount(const Value: Integer);
    function GetColCount: Integer;
    function GetAsText: AnsiString;
    procedure SetAsText(const Value: AnsiString);
    function GetAsTabText: AnsiString;
    procedure SetAsTabText(const Value: AnsiString);
    procedure SetAsTextCustom(const Delimiter: AnsiChar; const Value: AnsiString);
    procedure SetColCount(const Value: Integer);
    function GetRow(ARow: Integer): TCsvCells;
  public
    constructor Create;
    destructor Destroy; override;
    // 追加移動削除
    procedure Clear; virtual;
    procedure InsertRow(Index: Integer); // 空行を挿入
    procedure InsertCol(Index: Integer); // 空行を挿入
    procedure DeleteRow(Index: Integer);
    procedure DeleteCol(Index: Integer);
    procedure MoveRow(FromI, ToI: Integer);
    procedure MoveCol(FromI, ToI: Integer);
    procedure TrimBottom; // 末端行のトリム
    procedure TrimRight;  // 右端列のトリム
    // EDIT
    procedure Paste(ACol, ARow: Integer; dat: TCsvSheet); // 貼り付け
    function GetRectData(ALeft,ATop,ARight,ABottom: Integer): TCsvSheet;
    procedure UniqueKey(Index: Integer);
    // ファイル操作
    procedure LoadFromFile(FileName: AnsiString; ProgressFunc: TCsvProgressFunc = nil; Splitter: AnsiChar = ',');
    procedure SaveToFile(FileName: AnsiString; ProgressFunc: TCsvProgressFunc = nil; Splitter: AnsiChar = ',');
    // 機能
    procedure ReverseRow; // 逆さまにする
    procedure SortStr(Index: Integer);
    procedure SortNum(Index: Integer);
    procedure SortDate(Index: Integer);
    function FindStr(Index: Integer; key: AnsiString; FromIndex: Integer = 0): Integer; // 普通に完全一致検索
    function FindWildMatch(Index: Integer; key: AnsiString; FromIndex: Integer = 0): Integer;
    function KeisenText: AnsiString;
    function OutHtmlTable(attribute: AnsiString): AnsiString;
    // コピーその他
    procedure Assign(Source: TCsvSheet);
    function AddCsvRow(sheet: TCsvSheet; Row: Integer): Integer;
    //
    procedure setTextW(str:WideString; splitter:WideChar);
    // プロパティ
    property Count: Integer read GetCount write SetCount;
    property ColCount: Integer read GetColCount write SetColCount;
    property Cells[ACol, ARow: Integer]: AnsiString read GetCell write SetCell;
    property AsText : AnsiString read GetAsText write SetAsText;
    property AsTabText : AnsiString read GetAsTabText write SetAsTabText;
    property UseHeader: Boolean read FUseHeader write FUseHeader;
    property Rows[ARow: Integer]: TCsvCells read GetRow;
  end;

function uni2ansi(ws:WideString): RawByteString;
function ansi2uni(s:RawByteString):WideString;

implementation

uses StrUnit, wildcard, Variants, unit_string;

function uni2ansi(ws:WideString): RawByteString;
begin
  Result := UTF8Encode(ws);
end;

function ansi2uni(s:RawByteString):WideString;
var
  i: Integer;
  c: Byte;
  f: Boolean;
  tmp: RawByteString;

  function chk(n:Integer): Boolean;
  var j: Integer;
  begin
    Result := True;
    Inc(i);
    for j := 1 to n do
    begin
      if i > Length(s) then
      begin
        Result := False;
        Break;
      end;
      c := Ord(s[i]);
      if ($80 <= c)and(c <= $BF) then
      begin
        Inc(i);
        Continue;
      end;
      Result := False;
      Break;
    end;
  end;

begin
  tmp := s;
  // BOMがあれば削る
  if Copy(s,1,3) = #$EF#$BB#$BF then
  begin
    System.Delete(s,1,3);
  end;

  f := True;
  i := 1;
  while (i <= Length(s)) do
  begin
    c := Ord(s[i]);
    if c <= $7F then
    begin
      Inc(i);
      Continue;
    end;
    // 第一バイトからバイト数をチェック
    if (c and $C0) > 0 then
    begin
      if chk(2) then Continue;
      f := False;
      break;
    end;
    if (c and $E0) > 0 then
    begin
      if chk(3) then Continue;
      f := False;
      Break;
    end;
    if (c and $F0) > 0 then
    begin
      if chk(4) then Continue;
      f := False;
      Break;
    end;
    f := False;
    Break;
  end;
  
  if f then
  begin
    // UTF-8
    Result := UTF8ToWideString(UTF8String(s));
  end else
  begin
    // SJIS
    Result := WideString(tmp);
  end;
end;


{ TCsvSheet }

function TCsvSheet.AddCsvRow(sheet: TCsvSheet; Row: Integer): Integer;
var
  src, des: TCsvCells;
begin
  if sheet.list.Count <= Row then
  begin
    Result := -1;
    Exit;
  end;
  src := sheet.list.Items[Row];
  des := TCsvCells.Create ;
  if src <> nil then des.Assign(src);
  Result := list.Add(src);
end;

procedure TCsvSheet.Assign(Source: TCsvSheet);
var
  i: Integer;
  c, cDest: TCsvCells;
begin
  list.Count := Source.Count ;
  for i := 0 to list.Count - 1 do
  begin
    cDest := Source.list.Items[i];
    //
    c := TCsvCells.Create ;
    if cDest <> nil then c.Assign(cDest);
    list.Items[i] := c;
  end;
end;

procedure TCsvSheet.Clear;
var
  i: Integer; c: TCsvCells;
begin
  for i := 0 to list.Count - 1 do
  begin
    c := list.Items[i];
    FreeAndNil(c);
  end;
  list.Clear ;
end;

constructor TCsvSheet.Create;
begin
  list := TList.Create ;
end;

procedure TCsvSheet.DeleteCol(Index: Integer);
var
  i: Integer;
  c: TCsvCells;
begin
  for i := 0 to list.Count - 1 do
  begin
    c := list.Items[i];
    if c <> nil then
    begin
      if c.Count > Index then c.Delete(Index);
    end;
  end;
end;

procedure TCsvSheet.DeleteRow(Index: Integer);
var
  c: TCsvCells;
begin
  c := TCsvCells(list.Items[Index]);
  FreeAndNil(c);
  list.Delete(Index); 
end;

destructor TCsvSheet.Destroy;
begin
  list.Free ;
  inherited;
end;

function TCsvSheet.FindStr(Index: Integer; key: AnsiString; FromIndex: Integer): Integer;
var
  i: Integer;
  p: TCsvCells ;
begin
  Result := -1;
  for i := FromIndex to list.Count - 1 do
  begin
    p := list.Items[i];
    if p.GetValue(Index) = key then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TCsvSheet.FindWildMatch(Index: Integer; key: AnsiString;
  FromIndex: Integer): Integer;
var
  i: Integer;
  p: TCsvCells ;
  s: AnsiString;
begin
  Result := -1;
  for i := FromIndex to list.Count - 1 do
  begin
    p := list.Items[i];
    s := p.GetValue(Index);
    if WildMatchFilename(string(s), string(key)) then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TCsvSheet.GetAsTabText: AnsiString;
var
  c: TCsvCells;
  row: Integer;
begin
  Result := '';
  for row := 0 to list.Count - 1 do
  begin
    c := list.Items[row];
    Result := Result + c.GetTabText + #13#10;
  end;
end;

function TCsvSheet.GetAsText: AnsiString;
var
  c: TCsvCells;
  row: Integer;
begin
  Result := '';
  for row := 0 to list.Count - 1 do
  begin
    c := list.Items[row];
    Result := Result + c.GetCommaText + #13#10;
  end;
end;


function TCsvSheet.GetCell(ACol, ARow: Integer): AnsiString;
var
  c: TCsvCells ;
begin
  if (ARow < list.Count)and(ARow >= 0) then
  begin
    c := list.Items[ARow];
    if c <> nil then
      Result := c.GetValue(ACol)
    else
      Result := ''
    ;
  end else
  begin
    Result := '';
  end;
end;

function TCsvSheet.GetColCount: Integer;
var
  c: TCsvCells; i, max: Integer;
begin
  max := 0;
  for i := 0 to list.Count - 1 do
  begin
    c := list.Items[i];
    if c <> nil then
    begin
      if max < c.Count then max := c.Count ;
    end;
  end;
  Result := max;
end;

function TCsvSheet.GetCount: Integer;
begin
  Result := list.Count ;
end;

function TCsvSheet.GetRectData(ALeft, ATop, ARight,
  ABottom: Integer): TCsvSheet;
var
  x, y, cols, rows : Integer;
begin
  rows := ABottom - ATop + 1;
  cols := ARight - ALeft + 1;

  Result := TCsvSheet.Create ;
  Result.Count := rows;

  for y := 0 to rows - 1 do
  begin
    for x := 0 to cols - 1 do
    begin
      Result.Cells[x,y] := Self.Cells[ALeft+x, ATop+y];
    end;
  end;
end;

function TCsvSheet.GetRow(ARow: Integer): TCsvCells;
begin
  Result := list.Items[ARow];
end;

procedure TCsvSheet.InsertCol(Index: Integer);
var
  i: Integer;
  p: TCsvCells;
begin
  for i := 0 to Count - 1 do
  begin
    p := list.Items[i];
    if p <> nil then p.Insert(Index, '');
  end;
end;

procedure TCsvSheet.InsertRow(Index: Integer);
begin
  if Index >= list.Count then
    list.Add(TCsvCells.Create)
  else
    list.Insert(Index, TCsvCells.Create);
end;

function TCsvSheet.KeisenText: AnsiString;
const
  KEI_TOP: array[0..2]of AnsiString = ('┏','┳','┓');
  KEI_MID: array[0..2]of AnsiString = ('┣','╋','┫');
  KEI_BOM: array[0..2]of AnsiString = ('┗','┻','┛');
  KEIW = '━';
  KEIH = '┃';

var
  col, row, cols, w, maxw: Integer;
  colWidth: array of Integer;

  function StrRepeat(s: AnsiString; Count: Integer): AnsiString;
  var i: Integer;
  begin
    Result := '';
    for i := 0 to Count - 1 do
      Result := Result + s;
  end;

  procedure subKeisen(L,M,R: AnsiString);
  var col: Integer;
  begin
    Result := Result + L;
    for col := 0 to cols -1 do
    begin
      Result := Result + StrRepeat(KEIW, ColWidth[col] div 2);
      if col <> (cols-1) then
        Result := Result + M
      else
        Result := Result + R + #13#10;
    end;
  end;

begin
  Result := '';
  cols := ColCount;
  if cols = 0 then Exit;
  
  SetLength(colWidth, cols);
  // 文字数をカウントする
  for col := 0 to cols - 1 do
  begin
    maxw := 0;
    for row := 0 to Count - 1 do
    begin
      w := Length(Cells[col,row]);
      if (w mod 2) = 1 then w := w + 1; // 罫線が２バイトなので揃える
      if w > maxw then maxw := w;
    end;
    colWidth[col] := maxw;
  end;

  // まず最上部を作る
  subKeisen(KEI_TOP[0], KEI_TOP[1], KEI_TOP[2]);

  // セルのデータ部分
  for row := 0 to Count - 1 do
  begin
    // データ
    Result := Result + KEIH;
    for col := 0 to cols - 1 do
    begin
      w := Length(Cells[col,row]);
      Result := Result + Cells[col,row];
      Result := Result + StrRepeat(' ', (ColWidth[col]-w));
      Result := Result + KEIH;
    end;
    Result := Result + #13#10;
    // 下線
    if row <> (Count - 1) then subKeisen(KEI_MID[0], KEI_MID[1], KEI_MID[2]);
  end;
  // 最下端
  subKeisen(KEI_BOM[0], KEI_BOM[1], KEI_BOM[2]);
end;

procedure TCsvSheet.LoadFromFile(FileName: AnsiString;
  ProgressFunc: TCsvProgressFunc; Splitter: AnsiChar);
var
  i: Integer; c: TCsvCells; Cancel: Boolean;
  f: TextFile;
  TotalSize: Integer;
  ReadBytes: Integer;

  procedure ReadLine;
  var
    flagStr: Boolean; p: PAnsiChar; line, cell: AnsiString;
  label
    lblRead;
  begin
    flagStr := False;
    ReadLn(f, line);
    ReadBytes := ReadBytes + Length(line) + 2;
    p := PAnsiChar(line);
    cell := '';

    lblRead:
    while p^ <> #0 do
    begin
      if p^ in LeadBytes then
      begin
        cell := cell + p^ + (p+1)^;
        Inc(p, 2);
        Continue;
      end;
      if (p^ = '"')and((p+1)^ = '"')and(flagStr) then
      begin
        cell := cell + '"';
        Inc(p, 2);
        Continue;
      end;
      if p^ = '"' then
      begin
        Inc(p);
        flagStr := not flagStr;
        Continue;
      end;
      if (p^ = Splitter)and(flagStr = False) then
      begin
        Inc(p);
        c.Add(cell);
        cell := '';
        while (p^ = ' ') do Inc(p); // スペースは省略
      end else
      begin
        cell := cell + p^; Inc(p);
      end;
    end;
    //
    if flagStr then
    begin
      if not EOF(f) then
      begin
        ReadLn(f, line);
        ReadBytes := ReadBytes + Length(line) + 2;
        p := PAnsiChar(line);
        cell := cell + #13#10;
        goto lblRead;
      end;
    end;
    c.Add(cell);
  end;

begin
  Clear ;
  AssignFile(f, string(FileName));
  try
    Reset(f);
    TotalSize := FileSize(f) * 128+ 1;
    ReadBytes := 1;
    i := 0;
    while not Eof(f) do
    begin
      // Progress function
      if Assigned(ProgressFunc) then
      begin
        if (i mod 30) = 0 then
        begin
          Cancel := False;
          ProgressFunc(Trunc(ReadBytes / TotalSize * 100), Cancel);
          if Cancel then Break;
        end;
      end;

      //========================================================================
      // Read File
      c := TCsvCells.Create ;
      ReadLine;
      list.Add(c);
      i := i + 1;
    end;
    if Assigned(ProgressFunc) then ProgressFunc(100, Cancel);
  finally
    CloseFile(f);
  end;
end;

procedure TCsvSheet.MoveCol(FromI, ToI: Integer);
var
  i: Integer;
  c: TCsvCells;
begin
  for i := 0 to Count - 1 do
  begin
    c := list.Items[i];
    if c = nil then Continue;
    c.Move(FromI, ToI); 
  end;
end;

procedure TCsvSheet.MoveRow(FromI, ToI: Integer);
begin
  if list.Count <= FromI then
  begin
    list.Count := FromI + 1;
  end;
  list.Move(FromI, ToI);
end;

function TCsvSheet.OutHtmlTable(attribute: AnsiString): AnsiString;
var
  x, y: Integer;
  cols: Integer;
begin
  cols := ColCount ;
  if attribute <> '' then
  begin
    Result := '<TABLE ' + TrimA(attribute) + '>'#13#10;
  end else
  begin
    Result := '<TABLE>'#13#10;
  end;
  //
  for y := 0 to Count - 1 do
  begin
    Result := Result + '  <TR>'#13#10;
    for x := 0 to cols - 1 do
    begin
      Result := Result + '    <TD>'+GetCell(x,y)+'</TD>'#13#10;
    end;
    Result := Result + '  </TR>'#13#10;
  end;
  Result := Result + '</TABLE>'#13#10;
end;

procedure TCsvSheet.Paste(ACol, ARow: Integer; dat: TCsvSheet);
var
  x, y, cols, rows: Integer;
begin
  rows := dat.Count ;
  cols := dat.ColCount ;

  for y := 0 to rows - 1 do
  begin
    for x := 0 to cols - 1 do
    begin
      Cells[ACol + x, ARow + y] := dat.Cells[x, y];
    end;
  end;
end;

procedure TCsvSheet.ReverseRow;
var
  i, j: Integer;
  rows, r2: Integer;
  p: Pointer;
begin
  rows := list.Count;
  // 上下を逆さまにする処理
  if UseHeader then
  begin
    // 012345678 : 9
    // *i      j
    r2   := (rows-1) div 2 + 1;
    for i := 1 to r2 - 1 do
    begin
      j := rows - i;  // ひっくり返す対象
      p := list.Items[i];
      list.Items[i] := list.Items[j];
      list.Items[j] := p;
    end;
  end else
  begin
    r2   := rows div 2 + 1;
    for i := 0 to r2 - 1 do
    begin
      j := rows - 1 - i;
      p := list.Items[i];
      list.Items[i] := list.Items[j];
      list.Items[j] := p;
    end;
  end;
end;

procedure TCsvSheet.SaveToFile(FileName: AnsiString;
  ProgressFunc: TCsvProgressFunc; Splitter: AnsiChar);
var
  i: Integer; c: TCsvCells; Cancel: Boolean;
  f: TextFile;
  colCount: Integer;
begin
  AssignFile(f, FileName);
  Rewrite(f);
  try
    colCount := GetColCount ;
    for i := 0 to list.Count - 1 do
    begin
      c := list.Items[i];
      // Progress function
      if Assigned(ProgressFunc) then
      begin
        if (i mod 30) = 0 then
        begin
          Cancel := False;
          ProgressFunc(Trunc(i / list.Count * 100), Cancel);
          if Cancel then Break;
        end;
      end;
      if c = nil then
        WriteLn(f, '')
      else
        WriteLn(f, c.GetCommaTextEx(Splitter,colCount));
    end;
    if Assigned(ProgressFunc) then ProgressFunc(100, Cancel);
  finally
    CloseFile(f);
  end;
end;

procedure TCsvSheet.SetAsTabText(const Value: AnsiString);
begin
  SetAsTextCustom(#9, Value);
end;

procedure TCsvSheet.SetAsText(const Value: AnsiString);
begin
  SetAsTextCustom(',', Value);
end;

procedure TCsvSheet.SetAsTextCustom(const Delimiter: AnsiChar;
  const Value: AnsiString);
var
  p: PAnsiChar;
  flagStr: Boolean;
  cell: AnsiString;
  c: TCsvCells;
begin
  Clear;
  flagStr := False;
  c := TCsvCells.Create ;
  p := PAnsiChar(Value);
  while p^ <> #0 do
  begin
    if p^ in LeadBytes then
    begin
      cell := cell + p^ + (p+1)^;
      Inc(p,2);
      Continue;
    end;

    if (flagStr) and (p^ = '"') and ((p+1)^ = '"') then
    begin
      cell := cell + '"';
      Inc(p, 2);
      Continue;
    end;

    if p^ = '"' then
    begin
      flagStr := not flagStr;
      Inc(p);
      Continue;
    end;

    if p^ = Delimiter then
    begin
      if flagStr then
      begin
        cell := cell + p^;
        Inc(p);
      end else
      begin
        c.Add(cell);
        cell := '';
        Inc(p);
      end;
      Continue;
    end;

    if (p^ in [#13, #10])and(flagStr = False) then
    begin
      if cell <> '' then
      begin
        c.Add(cell); cell := '';
      end;
      if p^ = #13 then Inc(p);
      if p^ = #10 then Inc(p);
      list.Add(c);
      c := TCsvCells.Create ;
    end else
    begin
      cell := cell + p^;
      Inc(p);
    end;
  end;
  if cell <> '' then c.Add(cell);
  if c.Count > 0 then list.Add(c) else c.Free ;
end;

procedure TCsvSheet.SetCell(ACol, ARow: Integer; const Value: AnsiString);
begin
  if ARow >= list.Count then
  begin
    list.Count := ARow + 1;
    list.Items[ARow] := TCsvCells.Create;
  end;
  if list.Items[ARow] = nil then list.Items[ARow] := TCsvCells.Create ;
  TCsvCells(list.Items[ARow]).Values[ACol] := Value;
end;

procedure TCsvSheet.SetColCount(const Value: Integer);
var
  p: TCsvCells;
begin
  if list.Count = 0 then list.Count := 1;
  p := list.Items[0];
  if p = nil then p := TCsvCells.Create ;
  p.Count := Value;
  list.Items[0] := p;
end;

procedure TCsvSheet.SetCount(const Value: Integer);
begin
  list.Count := Value;
end;

var
  CustomSortIndex: Integer;

function CustomSortString(Item1, Item2: Pointer): Integer;
var
  c1, c2: TCsvCells;
begin
  c1 := TCsvCells(Item1);
  c2 := TCsvCells(Item2);
  Result := CompareText(
    c1.Values[CustomSortIndex],
    c2.Values[CustomSortIndex]);
end;

function CustomSortNumber(Item1, Item2: Pointer): Integer;
var
  c1, c2: TCsvCells;
  n1, n2: Extended;
begin
  c1 := TCsvCells(Item1);
  c2 := TCsvCells(Item2);
  n1 := StrToValue(c1.Values[CustomSortIndex]);
  n2 := StrToValue(c2.Values[CustomSortIndex]);
  Result := Trunc(n1 - n2);
end;

function CustomSortDate(Item1, Item2: Pointer): Integer;
var
  c1, c2: TCsvCells;
  d1, d2: TDateTime;
begin
  c1 := TCsvCells(Item1);
  c2 := TCsvCells(Item2);
  try
    d1 := VarToDateTime(c1.Values[CustomSortIndex]);
  except
    d1 := 0;
  end;
  try
    d2 := VarToDateTime(c2.Values[CustomSortIndex]);
  except
    d2 := 0;
  end;
  // 日付に変換できなければ、0 とする
  Result := Trunc(d1 - d2);
end;

procedure TCsvSheet.setTextW(str: WideString; splitter:WideChar);
var
  i   : Integer;
  c   : WideChar;
  res : WideString;
  cel : WideString;
  row : TCsvCells;

  procedure skipSpace;
  begin
    while i <= Length(str) do
    begin
      if (str[i] in [WideChar(' ')]) then
        Inc(i)
      else
        Break;
    end;
  end;

  function getCellStr: WideString;
  begin
    Result := '';
    Inc(i); // skip '"'
    while i <= Length(str) do
    begin
      c := str[i];
      if c = '"' then
      begin
        Inc(i); Break;
      end else
      begin
        Inc(i);
      end;
      Result := Result + c;
    end;
  end;
  
  function getCell: WideString;
  begin
    Result := '';
    while i <= Length(str) do
    begin
      c := str[i];
      if c in [splitter,WideChar(#13),WideChar(#10)] then
      begin
        Break;
      end;
      Result := Result + c;
      Inc(i);
    end;
  end;

begin
  Clear;
  // ---
  row := TCsvCells.Create;
  Self.list.Add(row);
  //
  i   := 1;
  res := '';
  while i <= Length(str) do
  begin
    // get cell
    skipSpace;
    c := str[i];
    if c = '"' then
    begin
      cel := getCellStr;
    end else
    begin
      cel := getCell;
    end;
    row.Add(uni2ansi(cel));
    // comma ?
    skipSpace;
    if i > Length(str) then Break;
    c := str[i];
    if c = splitter then
    begin
      Inc(i);
      Continue;
    end;
    // cr lf
    if c = WideChar(#13) then
    begin
      Inc(i);
      if i > Length(str) then Break;
      c := str[i];
      if c = WideChar(#10) then Inc(i);
    end else
    if c in [WideChar(#10)] then Inc(i);
    row := TCsvCells.Create;
    Self.list.Add(row);
  end;
end;

procedure TCsvSheet.SortDate(Index: Integer);
var
  p: Pointer;
begin
  CustomSortIndex := Index;
  if list.Count = 0 then Exit;

  if UseHeader then
  begin
    p := list.Items[0];
    list.Delete(0);
    list.Sort(@CustomSortDate);
    list.Insert(0, p);
  end else
  begin
    list.Sort(@CustomSortNumber);
  end;
end;

procedure TCsvSheet.SortNum(Index: Integer);
var
  p: Pointer;
begin
  CustomSortIndex := Index;
  if list.Count = 0 then Exit;

  if UseHeader then
  begin
    p := list.Items[0];
    list.Delete(0);
    list.Sort(@CustomSortNumber);
    list.Insert(0, p);
  end else
  begin
    list.Sort(@CustomSortNumber);
  end;
end;

procedure TCsvSheet.SortStr(Index: Integer);
var
  p: Pointer;
begin
  CustomSortIndex := Index;
  if list.Count = 0 then Exit;

  if UseHeader then
  begin
    p := list.Items[0];
    list.Delete(0);
    list.Sort(@CustomSortString);
    list.Insert(0, p); 
  end else
  begin
    list.Sort(@CustomSortString);
  end;
end;

procedure TCsvSheet.TrimBottom;
var
  c: TCsvCells;
begin
  while list.Count > 0 do
  begin
    c := list.Items[ list.Count - 1 ];

    if (c = nil) or (c.AllBlank) then
    begin
      list.Delete(list.Count - 1);
      FreeAndNil(c);
    end else
    begin
      Break;
    end;
  end;
end;

procedure TCsvSheet.TrimRight;
var
  i: Integer;
  c: TCsvCells ;
begin
  for i := 0 to list.Count - 1 do
  begin
    c := list.Items[i];
    if c=nil then Continue;
    c.TrimLast ;
  end;
end;

procedure TCsvSheet.UniqueKey(Index: Integer);
var
  i, j: Integer;
begin
  i := 0;
  while i < Count do
  begin
    j := i + 1;
    while j < Count do
    begin
      if GetCell(Index, i) = GetCell(Index, j) then
      begin
        DeleteRow(j);
      end else
      begin
        Inc(j);
      end;
    end;
    Inc(i);
  end;
end;

{ TCsvCells }

function TCsvCells.Add(Value: AnsiString): Integer;
var
  p: PAnsiChar;
begin
  GetMem(p, Length(Value) + 1);
  StrCopy(p, PAnsiChar(Value));
  Result := list.Add(p);
end;

function TCsvCells.AllBlank: Boolean;
var
  i: Integer;
  s: AnsiString;
begin
  Result := False;
  for i := 0 to list.Count - 1 do
  begin
    s := GetValue(i);
    if s <> '' then Exit; //***
  end;
  Result := True;
end;

procedure TCsvCells.Assign(Source: TCsvCells);
var i: Integer; pSrc, pDes: PAnsiChar;
begin
  list.Count := Source.Count ;
  for i := 0 to Source.Count - 1 do
  begin
    pSrc := Source.list.Items[i];
    if pSrc <> nil then
    begin
      GetMem(pDes, StrLen(pSrc)+1);
      StrCopy(pDes, pSrc);
    end else
      pDes := nil;
    //
    list.Items[i] := pDes;
  end;
end;

procedure TCsvCells.Clear;
var i: Integer; p: PAnsiChar;
begin
  for i := 0 to list.Count - 1 do
  begin
    p := list.Items[i];
    if p <> nil then Dispose(p);
  end;
  list.Clear ;
end;

constructor TCsvCells.Create;
begin
  list := TList.Create ;
end;

procedure TCsvCells.Delete(Index: Integer);
var
  p: PAnsiChar;
begin
  p := list.Items[Index];
  if p<>nil then Dispose(p);
  list.Delete(Index); 
end;

destructor TCsvCells.Destroy;
begin
  Clear;
  list.Free ;
  inherited;
end;

function TCsvCells.GetCommaText: AnsiString;
var
  i: Integer;

  function chkValue(s: AnsiString): AnsiString;
  begin
    Result := s;
    if (JPosM('"', Result) > 0)or(JPosM(#13, Result) > 0)or(JPosM(#10, Result) > 0)then
    begin
      Result := '"' + JReplaceA(Result, '"', '""') + '"';
    end else
    if (JPosM(',', Result) > 0)or(JPosM(' ', Result) > 0) then
    begin
      Result := '"' + Result + '"';
    end else
    if (Result = 'ID')or(Result = 'id') then
    begin
      Result := '"' + Result + '"';
    end;
  end;

begin
  Result := '';
  for i := 0 to list.Count - 1 do
  begin
    Result := Result + chkValue(GetValue(i)) + ',';
  end;
  if Result <> '' then System.Delete(Result, Length(Result), 1);
end;

function TCsvCells.GetCommaTextEx(Splitter: AnsiChar; ColCount: Integer): AnsiString;
var
  i: Integer;

  function chkValue(s: AnsiString): AnsiString;
  begin
    Result := s;
    if (JPosM('"', Result) > 0)or(JPosM(#13, Result) > 0)or(JPosM(#10, Result) > 0)then
    begin
      Result := '"' + JReplaceA(Result, '"', '""') + '"';
    end else
    if (JPosM(Splitter, Result) > 0)or(JPosM(' ', Result) > 0) then
    begin
      Result := '"' + Result + '"';
    end else
    if (Result = 'ID')or(Result = 'id') then
    begin
      Result := '"' + Result + '"';
    end;
  end;

begin
  Result := '';
  if ColCount < 0 then ColCount := list.Count ;
  for i := 0 to ColCount - 1 do
  begin
    Result := Result + chkValue(GetValue(i)) + Splitter;
  end;
  if Result <> '' then System.Delete(Result, Length(Result), 1);
end;

function TCsvCells.GetCount: Integer;
begin
  Result := list.Count ;
end;


function TCsvCells.GetTabText: AnsiString;
var
  i: Integer;

  function chk(s: AnsiString): AnsiString;
  begin
    if (JPosM('"', s) > 0)or(JPosM(#13, s) > 0)or(JPosM(#10, s) > 0) then
    begin
      Result := '"' + JReplaceU(s, '"', '""', True) + '"';
    end else
    if JPosM(#9, s) > 0 then
    begin
      Result := '"' + s + '"';
    end else
    begin
      Result := s;
    end;
  end;

begin
  Result := '';
  for i := 0 to list.Count - 1 do
  begin
    Result := Result + chk(PAnsiChar(list.Items[i])) + #9;
  end;
  System.Delete(Result,Length(Result),1);
end;

function TCsvCells.GetValue(Index: Integer): AnsiString;
begin
  if (Index < list.Count)and(Index >= 0) then
  begin
    Result := string(PAnsiChar( list.Items[Index] ));
  end else
  begin
    Result := '';
  end;
end;

procedure TCsvCells.Insert(Index: Integer; Value: AnsiString);
var
  p: PAnsiChar;
begin
  if Value <> '' then
  begin
    GetMem(p, Length(Value)+1);
    StrCopy(p, PAnsiChar(Value));
  end else
    p := nil;
  if Index >= Count then list.Count := Index;
  list.Insert(Index, p);
end;

procedure TCsvCells.Move(FromI, ToI: Integer);
begin
  if FromI >= list.Count then
  begin
    list.Count := FromI + 1;
  end;
  list.Move(FromI, ToI);
end;

procedure TCsvCells.SetCount(const Value: Integer);
begin
  list.Count := Value;
end;

procedure TCsvCells.SetValue(Index: Integer; const Value: AnsiString);
var p: PAnsiChar;
begin
  if Index >= list.Count then
  begin
    list.Count := Index + 1; // 伸びる
  end;
  GetMem(p, Length(Value) + 1);
  StrCopy(p, PAnsiChar(Value));
  list.Items[Index] := p;
end;

procedure TCsvCells.TrimLast;
var
  i: Integer;
begin
  i := list.Count - 1;
  while i >= 0 do
  begin
    if Trim(GetValue(i)) = '' then
    begin
      Delete(i);
      Dec(i);
    end else
    begin
      Break;
    end;
  end;
end;

end.
