unit CsvUtils2Grid;

interface
uses
  CsvUtils2, Grids;

// グリッド列幅の自動調整
procedure CsvGridAutoColWidth(grid: TDrawGrid; csv: TCsvSheet);
// グリッドを空にする
procedure CsvGridClearGrid(grid: TStringGrid);
// グリッドからデータを得る
procedure CsvGridGetData(grid: TStringGrid; csv: TCsvSheet);
// グリッドにデータを注入
procedure CsvGridSetData(grid: TStringGrid; csv: TCsvSheet);

// グリッド列幅の自動調整
procedure CsvGridAutoColWidthUni(grid: TDrawGrid; csv: TCsvSheet);
// グリッドを空にする
procedure CsvGridClearGridUni(grid: TStringGrid);
// グリッドからデータを得る
procedure CsvGridGetDataUni(grid: TStringGrid; csv: TCsvSheet);
// グリッドにデータを注入
procedure CsvGridSetDataUni(grid: TStringGrid; csv: TCsvSheet);

implementation


// グリッドからデータを得る
procedure CsvGridGetData(grid: TStringGrid; csv: TCsvSheet);
var
  c, r: Integer;
begin
  csv.Clear;
  for r := 0 to grid.RowCount - 1 do
  begin
    for c := 0 to grid.ColCount - 1 do
    begin
      csv.Cells[c, r] := grid.Cells[c, r];
    end;
  end;
  csv.TrimBottom;
end;

// グリッドからデータを得る
procedure CsvGridGetDataUni(grid: TStringGrid; csv: TCsvSheet);
var
  c, r: Integer;
begin
  csv.Clear;
  for r := 0 to grid.RowCount - 1 do
  begin
    for c := 0 to grid.ColCount - 1 do
    begin
      csv.Cells[c, r] := uni2ansi(grid.Cells[c, r]);
    end;
  end;
  csv.TrimBottom;
end;

procedure CsvGridAutoColWidth(grid: TDrawGrid; csv: TCsvSheet);
var
  cols, rows: Integer;

  procedure SetWidth;
  var
    x, y, w, ww: Integer;
    v: string;
  begin
    // grid のサイズをあわせる
    if rows > 100 then rows := 100;
    for x := 0 to cols - 1 do
    begin
      w := 0;
      for y := 0 to rows - 1 do
      begin
        v := csv.Cells[x, y];
        ww := grid.Canvas.TextWidth(v);
        if w < ww then w := ww;
      end;
      w := Trunc(w * 1.2);
      if grid.Width < w then w := grid.Width div 3;
      if w < grid.DefaultColWidth then w := grid.DefaultColWidth;
      grid.ColWidths[x + grid.FixedCols] := w;
    end;
  end;

begin
  cols := csv.ColCount ;
  rows := csv.Count ;

  with grid do
  begin
    Canvas.Font := Font;
    if rows < 2 then
    begin
      rows := 2;
    end else
    begin
      RowCount := rows + 1;
    end;
    ColCount := cols + FixedCols ;
    DefaultRowHeight := Trunc(grid.Canvas.TextHeight('A')*1.2);
    SetWidth;
    Invalidate ;
  end;
end;

// グリッド列幅の自動調整
procedure CsvGridAutoColWidthUni(grid: TDrawGrid; csv: TCsvSheet);
var
  cols, rows: Integer;

  procedure SetWidth;
  var
    x, y, w, ww: Integer;
    v: string;
  begin
    // grid のサイズをあわせる
    if rows > 100 then rows := 100;
    for x := 0 to cols - 1 do
    begin
      w := 0;
      for y := 0 to rows - 1 do
      begin
        v := csv.Cells[x, y];
        ww := grid.Canvas.TextWidth(v);
        if w < ww then w := ww;
      end;
      w := Trunc(w * 1.2);
      if grid.Width < w then w := grid.Width div 3;
      if w < grid.DefaultColWidth then w := grid.DefaultColWidth;
      grid.ColWidths[x + grid.FixedCols] := w;
    end;
  end;

begin
  cols := csv.ColCount ;
  rows := csv.Count ;

  with grid do
  begin
    Canvas.Font := Font;
    if rows < 2 then
    begin
      rows := 2;
    end else
    begin
      RowCount := rows + 1;
    end;
    ColCount := cols + FixedCols ;
    DefaultRowHeight := Trunc(grid.Canvas.TextHeight('A')*1.2);
    SetWidth;
    Invalidate ;
  end;
end;

// グリッドを空にする
procedure CsvGridClearGrid(grid: TStringGrid);
var
  x, y: Integer;
begin
  // Clear
  for y := 0 to grid.RowCount - 1 do
  begin
    for x := 0 to grid.ColCount - 1 do
    begin
      grid.Cells[x, y] := '';
    end;
  end;
end;


// グリッドを空にする
procedure CsvGridClearGridUni(grid: TStringGrid);
var
  x, y: Integer;
begin
  // Clear
  for y := 0 to grid.RowCount - 1 do
  begin
    for x := 0 to grid.ColCount - 1 do
    begin
      grid.Cells[x, y] := '';
    end;
  end;
end;


// グリッドにデータを注入
procedure CsvGridSetData(grid: TStringGrid; csv: TCsvSheet);
var
  x, y, cols: Integer;
begin
  // set csv
  cols := csv.ColCount ;
  grid.ColCount := cols + grid.FixedCols;

  if (csv.Count < 2) then
  begin
    grid.RowCount := 2;
  end else
  begin
    grid.RowCount := csv.Count + 1;
  end;
  CsvGridClearGrid(grid);

  for y := 0 to csv.Count - 1 do
  begin
    for x := 0 to cols - 1 do
    begin
      grid.Cells[x + grid.FixedCols, y] := csv.Cells[x, y];
    end;
  end;
end;

// グリッドにデータを注入
procedure CsvGridSetDataUni(grid: TStringGrid; csv: TCsvSheet);
var
  x, y, cols: Integer;
begin
  // set csv
  cols := csv.ColCount ;
  grid.ColCount := cols + grid.FixedCols;

  if (csv.Count < 2) then
  begin
    grid.RowCount := 2;
  end else
  begin
    grid.RowCount := csv.Count + 1;
  end;
  CsvGridClearGrid(grid);

  for y := 0 to csv.Count - 1 do
  begin
    for x := 0 to cols - 1 do
    begin
      grid.Cells[x + grid.FixedCols, y] := ansi2uni(csv.Cells[x, y]);
    end;
  end;
end;


end.
