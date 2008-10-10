unit csvDB;
{ Csvユーティリティユニット(CSVの入出力、ソート、検索)
　作成者：クジラ飛行机(http://kujirahand.com)
  作成日：2001/11/26
  更新日：2004/02/02
  ---------------------------------------------------------------------
  2004/02/02 1.00 エクセルの"ID"対策を簡素化。
}
(***********************************************************************

このユニットで実現していること：

・CSVファイルの入出力や、CSVファイルの読み書き
・CSVの、文字列・数値・日付によるソート、フィルタリング
・TStringGridへ出力


基本：

基本的には、以下のように使います。
//-----------------------------------------------
var csv:TCsvDb;//宣言
begin
  csv := TCsvDb.Create;//作成
  csv.Cells[Col, Row] := value; //セルへ代入
  ShowMessage( csv.Cells[Col, Row] ); //セルの参照
  ShowMessage( csv.Text ); // CSV形式の文字列として得る
  csv.LoadFromFile(Filename); //CSVファイルの読みこみ
  csv.MergeSort(Col); //ソート
  csv.Free;//解放
end;
//-----------------------------------------------

解説：
TCsvDb のスーパークラスである、TCsvDbBase は、TList で、
行である TCsvCells を管理している。

***********************************************************************)

// {$DEFINE VNAKO} // VNAKOから使うときは コメントをはずす


{$IFDEF VER140}
    {$WARN UNIT_PLATFORM OFF}//煩い警告をオフ
{$ENDIF}
{$IFDEF VER150}
    {$WARN UNIT_PLATFORM OFF}//煩い警告をオフ
{$ENDIF}

interface
uses
  SysUtils, Classes, Windows, unit_string, StrUnit, hima_types,
  filectrl
  {$IFDEF VNAKO},grids{$ENDIF}
  {$IFDEF VER140},Variants{$ENDIF}
  {$IFDEF VER150},Variants{$ENDIF}
  ;

type
  TStringArray = array of string;

  TCsvCells = class {csvDBの一行}
  private
    list: TList;
    procedure SetValue(Index: Integer; const Value: string);
    function  GetValue(Index: Integer): string;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure Clear;
    function  Add(const dat: string): Integer;
    procedure Insert(const Index: Integer; const Value: string);
    procedure Delete(const Index: Integer);
    function  Count: Integer;
    function  GetAsArray : TStringArray;
    function  GetAsCommaText : string;
    function  GetAsCommaTextEx(cnt: Integer): string;
    property  Items[Index: Integer]: string read GetValue write SetValue;
    procedure TrimLastCell;
    function CanTrimAll: Boolean;
    procedure Assign(c:TCsvCells);
    function  Find(key: string): Integer;
    procedure SetStringList(sl: TStringList);
    procedure Move(idx1, idx2: Integer);
  end;

  TCsvDbBase = class {csvDBの基本クラス/基本的な入出力のみ持つ}
  private
    procedure SetCell(Col, Row: Integer; const Value: string);
    function  GetCell(Col, Row: Integer): string;
  public
    UseHeader: Boolean;// CSVの一行目を、ヘッダフィーるとして使うかどうか
  protected
    RowList: TList;
    procedure ExchangeRow(A,B: Integer);
    function  GetAsText : string;
    procedure SetCsvText(Text: string);
  public
    constructor Create;
    destructor  Destroy; override;
    procedure Clear;
    procedure SetRow(Index: Integer; CsvCell: TCsvCells);
    function  GetRow(Index: Integer): TCsvCells;
    function  RowCount: Integer;//行数
    function  ColCount: Integer;//列数
    procedure DeleteRow(const Index: Integer);//行削除
    procedure InsertRow(Index: Integer; RowCellsList: TCsvCells);//行の挿入
    procedure InsertRowEx(Index: Integer; RowCellsList: TCsvCells);//行の挿入元データをコピーする版
    procedure DeleteCol(const Index: Integer);//列削除
    procedure InsertCol(Index: Integer; RowCellsList: TCsvCells);//列挿入
    property  Cells[Col,Row: Integer]: string read GetCell write SetCell;//参照代入
    procedure LoadFromFile(const Filename: string);//ファイルのロード
    procedure LoadFromFileSub(const Filename: string; ClearData:Boolean);//ClearDataをFalseにすれば、CSVファイルの追加読み込みをする
    procedure LoadFromTabCsvFile(const Filename: string);
    procedure SaveToTabCsvFile(const Filename: string);
    procedure SaveToFile(const Filename: string);//ファイルの保存
    property  Text: string read GetAsText write SetCsvText;//CSV形式の文字列を読んだり書いたり
    function  GetRowCommaText(Index: Integer):string;// "Pen, 300, white"などのような１行のカンマ区切りテキストを得る
    procedure SetRowCommaText(Index: Integer; txt:string);//一行のカンマ区切りテキストをセルにセットする
    procedure InsertRowCommaText(Index: Integer; txt: string);
    procedure ColMove(idx1, idx2: Integer); // 列の移動
    procedure RowMove(idx1, idx2: Integer); // 行の移動
    procedure RowReverse; //行の上下をひっくり返す
    procedure Assign(csv: TCsvDbBase);
    procedure SetTsvText(value: string);
    function GetTsvText: string;
  end;

  BoolArray = array of Boolean;
  FuncCompStr = function(const A, B: string): Boolean;
  FuncCompVal = function(const A, B: Extended): Boolean;
  FuncCompDate = function(const A, B: TDateTime): Boolean;

  TCsvDbCustomSort = function (Item1, Item2: string): Integer;

  TCsvDb = class(TCsvDbBase)
  private
    procedure SelectionSort(ColNo, Min, Max: Integer);
    procedure SelectionSortNo(ColNo, Min, Max: Integer);
    procedure SelectionSortDate(ColNo, Min, Max: Integer);
    procedure CustomSelectionSort(ColNo, Min, Max: Integer; custom: TCsvDbCustomSort);
    procedure MergeSortSub(ColNo, Min, Max: Integer; scratch: TCsvDb);
    procedure MergeSortNoSub(ColNo, Min, Max: Integer; scratch: TCsvDb);
    procedure MergeSortDateSub(ColNo, Min, Max: Integer; scratch: TCsvDb);
    procedure CustomMergeSortSub(ColNo, Min, Max: Integer; scratch: TCsvDb; custom: TCsvDbCustomSort);
    procedure OR_BoolArray(var A:BoolArray; const B:BoolArray);
    procedure AND_BoolArray(var A:BoolArray; const B:BoolArray);
  protected
    function  PickupArrayMatch(command: string): BoolArray;
    function  PickupArrayMatchEx(command: string): BoolArray;
  public
    procedure QuickSort(ColNo: Integer); //速いが順番が安定でない
    procedure MergeSort(ColNo: Integer); //順番が安定
    procedure MergeSortNo(ColNo: Integer); //数値でソート
    procedure MergeSortDate(ColNo: Integer);//日付でソート
    procedure CustomMergeSort(ColNo: Integer; custom: TCsvDbCustomSort);// カスタマイズ可能なマージソート
    procedure MergeSortDic(ColNo: Integer); //辞書順にソート
    procedure TrimRow;//上下の空行を削除
    procedure LinkMerge(SelfColNo: Integer; linkCsv: TCsvDb; linkColNo: Integer);//２つのCSVテーブルをセルの値でマージする
    function  Find(const key: string; ColNo, from: Integer): Integer;//検索
    function  FindAimai(const key: string; ColNo, from: Integer): Integer;//曖昧検索
    function  FindWildMatch(const key: string; ColNo, from: Integer): Integer;//ワイルドマッチ検索
    function  Pickup(Field, pattern: string): TCsvDb;
    function  PickupNo(FieldNo: Integer ;pattern: string): TCsvDb;
    function  PickupNoComplete(FieldNo: Integer; pattern: string): TCsvDb;
    //目玉機能: ex ... (町名="二川町" AND 面積>=500) OR (町名="大岩町" AND 値段 <= 300)
    //文字列比較は、"str" 日付日時比較は、#datetime
    function  PickupCommand(commandStr: string): TCsvDb;
    function  GetFieldNo(FieldName: string): Integer;//一行目のヘッダ名から列番号を得る
    procedure UniqCol(ColNo: Integer);//重複項目があれば削除する
    function  GetUniqID(Index: Integer; minValue: Integer): string;
    {$IFDEF VNAKO}
    procedure GetStringGrid(const grd: TStringGrid);
    procedure SetStringGrid(const grd:TStringGrid; AdjustGridWidth:Boolean);
    {$ENDIF}
    procedure RowColChange;//行と列を入換える
    function  GetValue(col, row: Integer): string; // 以前のバージョンとの互換性のため導入
    function  Count: Integer;
    function  MakeHtmlTableTag(option: string): string; //HTMLのTABLEタグで囲って返す
    function FindLine(line: string; fromRow: Integer): Integer;
  end;

function StrToCsv(var str: string): TCsvCells;
function PStrToCsv(var p: PChar): TCsvCells;
function GetTokenCsv(var p:PChar): string;

// 例外をトラップした変換
function VarToDateTimeZ(s: string): TDateTime;

implementation

uses
  wildcard, EasyMasks;

function VarToDateTimeZ(s: string): TDateTime;
begin
  Result := 0;
  if s='' then Exit;
  try
    Result := VarToDateTime(s);
  except
  end;
end;

function StrToCsv(var str: string): TCsvCells;
var p: PChar;
begin
    p := PChar(str);
    Result := PStrToCsv(p);
    str := string( p );
end;

function GetTokenCsv(var p:PChar): string;
var
    IsStr: Boolean;
    pp: PChar;
begin
    Result:=''; if p=nil then Exit; if p^=#0 then  Exit; //空白なら抜ける
    while p^=' ' do Inc(p);

    IsStr := False;
    while p^ = ' ' do Inc(p);

    if p^='"' then begin
        IsStr := True;
        Inc(p);
    end;

    while p^ <> #0 do
    begin
        if p^ in LeadBytes then
        begin
            Result := Result + p^ + (p+1)^;
            Inc(p, 2);
        end
        else
        case p^ of
        '"':
            begin
                if (p+1)^='"' then
                begin
                    Inc(p,2);
                    Result := Result + '"';
                    Continue;
                end;

                // ", と、セルの終端かチェック(次にカンマか改行が来るか)
                pp := (p+1);
                while pp^ = ' ' do Inc(pp);
                if pp^ in [',',#13,#10,#0] then
                begin // セルの終端
                    Inc(p);
                    Break;
                end else
                begin // セル非終端
                    Result := Result + '"'; //セル中に"があった場合
                    Inc(p);
                    Continue;
                end;
            end;
        #13,#10,',':
            begin
                if IsStr=False then
                begin
                    Break;
                end;
                Result := Result + p^;
                Inc(p);
            end;
        #$1A:
            begin
                Result := Result + p^;
                Inc(p);
            end;
        else
        begin
            Result := Result + p^;
            Inc(p);
        end;
        end;
    end;
    if p^=',' then Inc(p);
end;

function PStrToCsv(var p:PChar): TCsvCells;
var
    s: string;
begin
    if p=nil then begin Result := nil; Exit; end;

    Result := TCsvCells.Create ;
    while p^ <> #0 do
    begin
        s := Trim(GetTokenCsv(p));
        {
        if (Copy(s,1,1)='"')and(Copy(s,Length(s),1)='"')and(Length(s)<>1) then // 文字列ならトリム
        begin
            Delete(s,1,1);
            Delete(s,Length(s),1);
        end;
        }
        Result.Add(s);
        if p^ in [#13,#10] then Break;
    end;
end;

{ TCsvCells }

function TCsvCells.Add(const dat: string): Integer;
var
    p: PChar;
    len: Integer;
begin
    len := Length(dat);
    if len>0 then
    begin
        GetMem(p, len+1);
        StrCopy(p, PChar(dat));
    end else
        p := nil;
    Result := list.Add(p);
end;

procedure TCsvCells.Assign(c: TCsvCells);
var
    i: Integer;
begin
    Clear;
    for i:=0 to c.list.Count -1 do
    begin
        Self.Add(c.GetValue(i));
    end;
end;

function TCsvCells.CanTrimAll: Boolean;
var
  i: Integer;
  p: PChar;
begin
  Result := False;
  for i := 0 to list.Count - 1 do
  begin
    p := list.Items[i];
    if p <> nil then
    begin
      if string(p) <> '' then
      begin
        Exit;
      end;
    end;
  end;
  Result := True;
end;

procedure TCsvCells.Clear;
var
    i: Integer;
    p: PChar;
begin
    // 各セルのメモリのクリア
    for i:=0 to list.Count-1 do
    begin
        p := list.Items[i];
        if p<>nil then FreeMem(p);
    end;
    // リストをクリア
    list.Clear;
end;

function TCsvCells.Count: Integer;
begin
    Result := list.Count;
end;

constructor TCsvCells.Create;
begin
    list := TList.Create;
end;

procedure TCsvCells.Delete(const Index: Integer);
var
    p: PChar;
begin
    if (Index >= list.Count)or(Index < 0) then Exit;
    p := list.Items[Index];
    if p<>nil then
    begin
        FreeMem(p);list.Items[Index] := nil;
    end;
    list.Delete(Index);
end;

destructor TCsvCells.Destroy;
begin
    inherited;
    Clear;
    list.Free;
end;

function TCsvCells.Find(key: string): Integer;
var
    i: Integer;
    p: PChar;
begin
    Result := -1;
    for i:=0 to list.Count -1 do
    begin
        p := list.Items[i];
        if p=nil then Continue;
        if StrComp(PChar(key), p)=0 then
        begin
            Result := i; Break;
        end;
    end;
end;

function TCsvCells.GetAsArray: TStringArray;
var
    i: Integer;
begin
    SetLength(Result, list.Count);
    for i:=0 to list.Count-1 do
    begin
        Result[i] := string( PChar(list.Items[i]) );
    end;
end;


function TCsvCells.GetAsCommaText: string;
begin
    Result := GetAsCommaTextEx(list.Count);
end;

function TCsvCells.GetAsCommaTextEx(cnt: Integer): string;
var
    i: Integer;
    v: string;

    // もし、" があれば、""にする。改行や、","があれば、Trueを返す
    function chk(var s: string): Boolean;
    begin
      Result := False;
      if JPosEx('"',  s,  1) > 0 then begin s := JReplace(s, '"', '""', True); Result := True; end else
      if JPosEx(',',  s,  1) > 0 then Result := True else
      if JPosEx(#13,  s,  1) > 0 then Result := True else
      if JPosEx(#10,  s,  1) > 0 then Result := True else
      if (s = 'ID')and(i = 0) then Result := True else; // Excel対策 Excelで (0,0)に IDと書くとエラーが出る
    end;

begin
    Result := '';
    for i:=0 to cnt-1 do
    begin
      v := GetValue(i);
      if chk(v) then v:='"'+v+'"';
      Result := Result + v + ',';
    end;
    if (Result <> '') then System.Delete(Result, Length(Result), 1);
end;

function TCsvCells.GetValue(Index: Integer): string;
begin
    if (Index >= list.Count)or(Index < 0) then
    begin
        Result := '';
        Exit;
    end;
    Result := string( PChar( list.Items[ Index ] ) );
end;

procedure TCsvCells.Insert(const Index: Integer; const Value: string);
begin
    while list.Count < Index do list.Add(nil);
    list.Insert(Index, nil);
    SetValue(Index, Value);
end;

procedure TCsvCells.Move(idx1, idx2: Integer);
begin
	list.Move(idx1, idx2);
end;

procedure TCsvCells.SetStringList(sl: TStringList);
var
    i: Integer;
begin
    if sl=nil then Exit;
    for i:=0 to sl.Count -1 do
    begin
        Add(sl.Strings[i]);
    end;
end;

procedure TCsvCells.SetValue(Index: Integer; const Value: string);
var
    p: PChar;
    len: Integer;
begin
    if Index < 0 then Exit;
    while Index >= list.Count do begin
        list.Add(nil);
    end;
    p := list.Items[Index];
    if p<> nil then FreeMem(p);
    p:=nil;
    len := Length( Value );
    if len > 0 then
    begin
        GetMem(p, len+1);
        StrCopy(p, PChar(Value));
    end;
    list.Items[Index] := p;
end;


procedure TCsvCells.TrimLastCell;
var
    i: Integer;
begin
    i := list.Count -1;
    while i >= 0 do
    begin
        if Trim(Items[i]) = '' then
        begin
            Self.Delete(i);
            Dec(i);
        end else
            Break;
    end;
end;

{ TCsvDbBase }

procedure TCsvDbBase.Clear;
var
    i: Integer;
    p: TCsvCells;
begin
    for i:=0 to RowList.Count -1 do
    begin
        p := RowList.items[i];
        if p<> nil then p.Free;
    end;
    RowList.Clear;
end;

function TCsvDbBase.ColCount: Integer;
var
    i, cnt: Integer;
    cl: TCsvCells;
begin
    cnt := 0;
    for i:=0 to RowCount-1 do
    begin
        cl := RowList.Items[i];
        if cl <> nil then
            if cl.Count > cnt then cnt := cl.Count;
    end;
    Result := cnt;
end;

procedure TCsvDbBase.ColMove(idx1, idx2: Integer);
var
    i: Integer;
    c: TCsvCells;
begin
    for i:=0 to RowList.Count -1 do
    begin
        c := RowList.Items[i];
        if c=nil then Continue;
        c.Move(idx1, idx2);
    end;
end;

constructor TCsvDbBase.Create;
begin
    RowList := TList.Create;
    UseHeader := False;
end;

procedure TCsvDbBase.DeleteCol(const Index: Integer);
var
    i: Integer;
    c: TCsvCells;
begin
    for i:=0 to RowList.Count -1 do
    begin
        c := RowList.Items[i];
        if c=nil then Continue;
        c.Delete( Index );
    end;
end;

procedure TCsvDbBase.DeleteRow(const Index: Integer);
var
    p: TCsvCells;
begin
    if Index >= RowList.Count then Exit;
    if Index < 0 then Exit;
    p := RowList.Items[Index];
    if p<>nil then p.Free;
    RowList.Items[Index] := nil;
    RowList.Delete(Index);
end;

destructor TCsvDbBase.Destroy;
begin
    inherited;
    Clear;
    RowList.Free;
end;

procedure TCsvDbBase.ExchangeRow(A, B: Integer);
var
    p: Pointer;
    c: Integer;
begin
    if A>B then
        c := A
    else
        c := B;
    while c >= RowList.Count do RowList.Add(nil);
    //RowList.Exchange(A,B);
    p := RowList.Items[B];
    RowList.Items[B] := RowList.Items[A];
    RowList.Items[A] := p;
end;

procedure TCsvDbBase.RowReverse;
var i, iFrom: Integer; row2: TList;
begin
    row2 := TList.Create ;
    try
        if UseHeader then iFrom := 1 else iFrom := 0;

        for i:=iFrom to rowList.Count -1 do
        begin
            row2.Add(rowList.Items[rowList.Count-1-i+iFrom]);
        end;

        if UseHeader then row2.Insert(0, rowlist.Items[0]); 

    finally
        rowList.Free ;
        rowList := row2;
    end;
end;

function TCsvDbBase.GetAsText: string;
{ // 勝手に、","を挿入するタイプ
var
    c: TCsvCells;
    maxcol,i: Integer;
begin
    maxcol := ColCount ;
    Result := '';
    for i:=0 to RowList.Count -1 do
    begin
        c := RowList.Items[i];
        if c=nil then
        begin
            Result := Result + #13#10;
        end else
        begin
            Result := Result + c.GetAsCommaTextEx(maxcol) + #13#10;
        end;
    end;
end;
}
// ひまわりでは、","が勝手に挿入されると困る場面があるので改良
var
    c: TCsvCells;
    i: Integer;
begin
    Result := '';
    for i:=0 to RowList.Count -1 do
    begin
        c := RowList.Items[i];
        if c=nil then
        begin
            Result := Result + #13#10;
        end else
        begin
            Result := Result + c.GetAsCommaText + #13#10;
        end;
    end;
end;

function TCsvDbBase.GetCell(Col, Row: Integer): string;
var
    cl: TCsvCells;
begin
    if (Row < 0)or(Row >= RowList.Count) then Exit;
    cl := RowList.Items[ Row ];
    if cl<>nil then
        Result := cl.Items[ Col ]
    else
        Result := '';
end;

function TCsvDbBase.GetRow(Index: Integer): TCsvCells;
begin
    Result := nil;
    if Index < 0 then Exit;
    if Index >= RowList.Count then Exit;

    Result := RowList.Items[ Index ];
end;

function TCsvDbBase.GetRowCommaText(Index: Integer): string;
var c: TCsvCells;
begin
    Result := '';
    c := GetRow(Index);
    if c=nil then Exit;
    Result := c.GetAsCommaText;
end;

procedure TCsvDbBase.InsertCol(Index: Integer; RowCellsList: TCsvCells);
var
    i:Integer; p: TCsvCells;
begin
    for i:=0 to RowList.Count-1 do
    begin
        p := RowList.Items[i];
        if p <> nil then
        begin
            if RowCellsList <> nil then
                p.Insert(Index, RowCellsList.Items[i])
            else
                p.Insert(Index,'');
        end;
    end;
end;

procedure TCsvDbBase.InsertRow(Index: Integer; RowCellsList: TCsvCells);
begin
    RowList.Insert(Index, RowCellsList);
end;

procedure TCsvDbBase.LoadFromFile(const Filename: string);
begin
    LoadFromFileSub(Filename, True);
end;

procedure TCsvDbBase.LoadFromFileSub(const Filename: string;
  ClearData: Boolean);
var
    s: TStringList;
    txt: string;
    p: PChar;
begin
    s := TStringList.Create ;
    try
    try
        s.LoadFromFile(Filename);
        if ClearData then Self.Clear;
        txt := s.Text ;
        p := PChar(txt);
        while p^ <> #0 do
        begin
            RowList.Add( PStrToCsv( p ) );
            if p^ = ',' then Inc(p) else
            while p^ in [#13,#10] do Inc(p);
        end;
    except
      raise;
    end;
    finally
        s.Free;
    end;
end;

function TCsvDbBase.RowCount: Integer;
begin
    Result := RowList.Count ;
end;

procedure TCsvDbBase.RowMove(idx1, idx2: Integer);
begin
    RowList.Move(idx1, idx2);
end;

procedure TCsvDbBase.SaveToFile(const Filename: string);
var
    f: TextFile;
    c: TCsvCells;
    i,maxcols: Integer;
begin
    maxcols := ColCount ;
    AssignFile(f, Filename);
    try
        Rewrite(f);
        for i:=0 to RowList.Count -1 do
        begin
            c := RowList.Items[i];
            if c<>nil then
            begin
                Writeln(f, c.GetAsCommaTextEx(maxcols));
            end else
                Writeln(f,'');
        end;
    finally
        CloseFile(f);
    end;
end;

procedure TCsvDbBase.SetCell(Col, Row: Integer; const Value: string);
var
    cl: TCsvCells;
begin
    if (Row < 0) then Exit;
    while Row >= RowList.Count do RowList.Add(nil); // dummy を足す

    cl := RowList.Items[Row];
    if cl = nil then cl := TCsvCells.Create;
    cl.Items[Col] := Value;

    RowList.Items[Row] := cl;
end;

procedure TCsvDbBase.SetCsvText(Text: string);
var
    p: PChar;
begin
    p := PChar(Text);

    Self.Clear;
    while p^ <> #0 do
    begin
      RowList.Add( PStrToCsv( p ) );
      if p^ = ',' then Inc(p) else
      //行区切り文字だけ進める
      if p^ = #13 then Inc(p);
      if p^ = #10 then Inc(p);
    end;
end;

procedure TCsvDbBase.SetRow(Index: Integer; CsvCell: TCsvCells);
begin
    if (Index < 0) then Exit;
    while Index >= RowList.Count do RowList.Add(nil); // dummy を足す
    RowList.Items[Index] := CsvCell;
end;



procedure TCsvDbBase.SetRowCommaText(Index: Integer; txt: string);
var p: PChar;
begin
    p := PChar(txt);
    SetRow(Index, PStrToCsv(p));
end;

procedure TCsvDbBase.InsertRowEx(Index: Integer; RowCellsList: TCsvCells);
var
    c: TCsvCells;
begin
    c := TCsvCells.Create ;
    c.Assign(RowCellsList);
    RowList.Insert(Index, c);
end;

procedure TCsvDbBase.LoadFromTabCsvFile(const Filename: string);
var
  f: TextFile;
  row: Integer;
  s: string;
  sl: TStringList;
  i: Integer;
begin
  Self.Clear ;
  AssignFile(f, Filename);
  try
    row := 0;
    Reset(f);
    while not EOF(f) do
    begin
      Readln(f, s);
      sl := SplitChar(#9, s);
      try
        for i := 0 to sl.Count - 1 do
        begin
          Self.Cells[i, row] := sl.Strings[i];
        end;
      finally
        sl.Free ;
      end;
      Inc(row);
    end;
  finally
    CloseFile(f);
  end;
end;

procedure TCsvDbBase.SaveToTabCsvFile(const Filename: string);
var
  f: TextFile;
  row, col: Integer;
  s: string;
  c: TCsvCells;
begin
  AssignFile(f, Filename);
  try
    Rewrite(f);

    for row := 0 to RowCount - 1 do
    begin
      // 一行ごと書き込み
      c := GetRow(row);
      if c<>nil then
      begin
        c.TrimLastCell ;
        s := '';
        for col := 0 to c.Count - 1 do
        begin
          s := s + c.Items[col] + #9;
        end;
        if c.Count > 0 then
        begin
          System.Delete(s, Length(s), 1);
        end;
      end;
      Writeln(f, s);
    end;
  finally
    CloseFile(f);
  end;
end;

procedure TCsvDbBase.InsertRowCommaText(Index: Integer; txt: string);
var
  c: TCsvCells;
begin
  c := TCsvCells.Create ;
  Self.InsertRow(Index, c);
  Self.SetRowCommaText(Index, txt);    
end;

procedure TCsvDbBase.Assign(csv: TCsvDbBase);
var
  i: Integer;
  c: TCsvCells ;
begin
  Self.Clear ;
  if csv = nil then Exit;
  for i := 0 to csv.RowList.Count - 1 do
  begin
    c := TCsvCells.Create ;
    c.Assign(csv.GetRow(i));
    Self.RowList.Add(c); 
  end;
end;

procedure TCsvDbBase.SetTsvText(value: string);
var
  s, line: string;
  col,row: Integer;
begin
  Clear ;
  row := 0;
  while value <> '' do
  begin
    line := GetToken(#13#10, value);
    col := 0;
    while line <> '' do
    begin
      s := GetToken(#9, line);
      Cells[col, row] := s;
      Inc(col);
    end;
    Inc(row);
  end;
end;

function TCsvDbBase.GetTsvText: string;
var
  y, x: Integer;
begin
  Result := '';
  for y := 0 to Self.RowCount - 1 do
  begin
    for x := 0 to Self.ColCount - 1 do
    begin
      Result := Result + Cells[x,y] + #9
    end;
    if Self.ColCount > 0 then System.Delete(Result, Length(Result), 1);
    Result := Result + #13#10;
  end;
end;

{ TCsvDb }

var QSortColNo: Integer;

function CsvDbSortStr(Item1, Item2: Pointer): Integer;
var
    c1,c2: TCsvCells;
    s1,s2: string;
begin
    if (Item1=nil) and (Item2=nil) then begin Result :=0; Exit; end;
    if (Item1=nil) then begin Result := -1; Exit; end;
    if (Item2=nil) then begin Result := 1; Exit; end;

    c1 := Item1; c2 := Item2;
    s1 := c1.GetValue(QSortColNo);
    s2 := c2.GetValue(QSortColNo);
    if s1 = s2 then begin Result := 0; Exit; end;
    if s1 > s2 then
        Result := 1
    else
        Result := -1;
end;

procedure TCsvDb.AND_BoolArray(var A: BoolArray; const B: BoolArray);
var
    i: Integer;
begin
    for i:=0 to High(A) do
    begin
        A[i] := A[i] and B[i];
    end;
end;

function TCsvDb.Count: Integer;
begin
    Result := RowCount;
end;

function TCsvDb.Find(const key: string; ColNo, from: Integer): Integer;
var
    i,j: Integer;
    c: TCsvCells;
begin
    Result := -1;
    for i:=from to rowList.Count -1 do
    begin
        c := getRow(i);
        if c=nil then Continue;
        if ColNo=-1 then
        begin
          for j:=0 to c.Count -1 do
          begin
            if key = c.GetValue(j) then
            begin
              Result := i; Break;
            end;
          end;
        end else
        if key=c.GetValue(ColNo) then
        begin
            Result := i; Break;
        end;
    end;
end;

function TCsvDb.FindAimai(const key: string; ColNo,
  from: Integer): Integer;
var
    i: Integer;
    c: TCsvCells;
begin
    Result := -1;
    if ColNo<0 then
    begin
        for i:=from to rowList.Count -1 do
        begin
            c := getRow(i);
            if c=nil then Continue;
            if Pos(key,c.GetAsCommaText)>0 then
            begin
                Result := i; Break;
            end;
        end;
    end else
    begin
        for i:=from to rowList.Count -1 do
        begin
            c := getRow(i);
            if c=nil then Continue;
            if Pos(key,c.GetValue(ColNo))>0 then
            begin
                Result := i; Break;
            end;
        end;
    end;
end;

function TCsvDb.FindLine(line: string; fromRow: Integer): Integer;
var
  i: Integer;
  s: string;
begin
  Result := -1;
  for i := fromRow to Self.RowCount do
  begin
    s := GetRowCommaText(i);
    if s = line then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TCsvDb.FindWildMatch(const key: string; ColNo,
  from: Integer): Integer;
var
    i: Integer;
    c: TCsvCells;
begin
    Result := -1;
    if ColNo<0 then
    begin
        for i:=from to rowList.Count -1 do
        begin
            c := getRow(i);
            if c=nil then Continue;
            if WildMatchFilename(c.GetAsCommaText,key) then
            begin
                Result := i; Break;
            end;
        end;
    end else
    begin
        for i:=from to rowList.Count -1 do
        begin
            c := getRow(i);
            if c=nil then Continue;
            if WildMatchFilename(c.GetValue(ColNo),key) then
            begin
                Result := i; Break;
            end;
        end;
    end;
end;

function TCsvDb.GetFieldNo(FieldName: string): Integer;
var
    c: TCsvCells;
begin
    Result := -1;
    c := GetRow(0);
    if c=nil then Exit;
    Result := c.Find(FieldName);
end;

{$IFDEF VNAKO}
procedure TCsvDb.GetStringGrid(const grd: TStringGrid);
var
	x,y:Integer;
begin
    Self.Clear ;
    if grd = nil then Exit;

	  for y:=0 to grd.RowCount - 1 do
    	for x:=0 to grd.ColCount - 1 do
        begin
          if grd.Cells[x,y] <> '' then Cells[x,y] := grd.Cells[x,y];
        end;
end;
{$ENDIF}
function TCsvDb.GetUniqID(Index, minValue: Integer): string;
var
    i,v: Integer;
begin

    for i:=RowList.Count -1  downto 0 do
    begin
        v := Trunc(StrToValue(Cells[Index, i]));
        if minValue < v then minValue := v;
    end;
    Result := IntToStr(minValue+1);
end;

function TCsvDb.GetValue(col, row: Integer): string;
begin
    Result := Cells[col,row];
end;

procedure TCsvDb.LinkMerge(SelfColNo: Integer; linkCsv: TCsvDb;
  linkColNo: Integer);
var
    i,j,k,no, maxCol, from: Integer;
    d,d2: TCsvCells;
    s: string;
begin
    maxCol := Self.ColCount;
    if UseHeader then begin
        from := 1;
        if linkCsv.UseHeader then begin
            d  := Self.GetRow(0);
            d2 := linkCsv.GetRow(0);
            if (d<>nil)and(d2<>nil) then
            begin
                k := 0;
                for j:=0 to d2.Count -1 do
                begin
                    if j=linkColNo then Continue;
                    d.Items[MaxCol+k] := d2.Items[j];
                    Inc(k);
                end;
            end;
        end;
    end else
        from := 0;

    for i:=from to rowList.Count -1 do
    begin
        d := rowList.Items[i]; if d=nil then Continue;
        s := d.Items[SelfColNo];
        no := linkCsv.Find(s, linkColNo, 0); // find
        if no<=0 then Continue;
        d2 := linkCsv.GetRow(no); // add data
        k := 0;
        for j:=0 to d2.Count -1 do
        begin
            if j=linkColNo then Continue;
            d.Items[MaxCol+k] := d2.Items[j]; Inc(k);
        end;
    end;
end;

function TCsvDb.MakeHtmlTableTag(option: string): string;
var
    x, y: Integer;
    s: string;
begin
    Result := '<TABLE '+option+'>'#13#10;
    for y := 0 to RowCount -1 do
    begin
        Result := Result + '<TR>';
        for x :=0 to ColCount -1 do
        begin
            s := Cells[x, y];
            {s := JReplace(s, '&', '&amp;', True);
            s := JReplace(s, '"', '&quot;', True);
            s := JReplace(s, '<', '&lt;', True);
            s := JReplace(s, '>', '&gt;', True);} //これはお節介なので止め
            Result := Result + '<TD>' + s + '</TD>';
        end;
        Result := Result + '</TR>'#13#10;
    end;
    Result := Result + '</TABLE>';
end;


procedure TCsvDb.MergeSort(ColNo: Integer);
var
    scratch: TCsvDb;
    from: Integer;
begin
    scratch := TCsvDb.Create ;
    try
        scratch.RowList.Capacity := RowList.Count;
        TrimRow;
        if UseHeader then from := 1 else from := 0;
        MergeSortSub(ColNo, from, RowList.Count-1, scratch);
        scratch.RowList.Clear ;//誤ってデータを二重に削除するのを防ぐため
    finally
        scratch.Free;
    end;
end;

procedure TCsvDb.MergeSortDate(ColNo: Integer);
var
    scratch: TCsvDb;
    from: Integer;
begin
    scratch := TCsvDb.Create ;
    try
        scratch.RowList.Capacity := RowList.Count;
        TrimRow;
        if UseHeader then from := 1 else from := 0;
        MergeSortDateSub(ColNo, from, RowList.Count-1, scratch);
        scratch.RowList.Clear ;//誤ってデータを二重に削除するのを防ぐため
    finally
        scratch.Free;
    end;
end;

procedure TCsvDb.MergeSortDateSub(ColNo, Min, Max: Integer;
  scratch: TCsvDb);
var
    middle,i1,i2,i3: Integer;
    d1,d2: string;
const
    Cutoff = 20;
begin
    //リストの要素が少なくなったセレクションソートに切り替え
    if (max - min < Cutoff) then begin
        SelectionSortDate(ColNo, min, max);
        exit;
    end;
    //サブリストを、再帰的にソートする
    middle := min div 2 + max div 2;
    MergeSortDateSub(ColNo, min, middle, scratch);
    MergeSortDateSub(ColNo, middle+1, max, scratch);
    //ソートされたリストをマージする
    i1 := min;
    i2 := middle + 1;
    i3 := min; // マージリストのインデックス
    while ((i1 <= middle)and(i2 <= max)) do
    begin
        d1 := Cells[ColNo,i1];
        d2 := Cells[ColNo,i2];
        if (VarToDateTimeZ(d1) <= VarToDateTimeZ(d2)) then
        begin
            scratch.SetRow(i3, GetRow(i1));
            Inc(i1);
        end else
        begin
            scratch.SetRow(i3, GetRow(i2));
            Inc(i2);
        end;
        i3 := i3 + 1;
    end;
    //リストが空でなければ、空にする
    while (i1 <= middle) do
    begin
        scratch.SetRow(i3, GetRow(i1));
        Inc(i1);
        Inc(i3);
    end;
    while (i2 <= max) do
    begin
        scratch.SetRow(i3, GetRow(i2));
        Inc(i2);
        Inc(i3);
    end;
    //マージされたリストを、元に戻す
    for i3:=min to max do
    begin
        SetRow(i3, scratch.GetRow(i3));
    end;

end;

procedure TCsvDb.MergeSortNo(ColNo: Integer);
var
    scratch: TCsvDb;
    from: Integer;
begin
    scratch := TCsvDb.Create ;
    try
        scratch.RowList.Capacity := RowList.Count;
        TrimRow;
        if UseHeader then from := 1 else from := 0;
        MergeSortNoSub(ColNo, from, RowList.Count-1, scratch);
        scratch.RowList.Clear ;//誤ってデータを二重に削除するのを防ぐため
    finally
        scratch.Free;
    end;
end;

procedure TCsvDb.MergeSortNoSub(ColNo, Min, Max: Integer; scratch: TCsvDb);
var
    middle,i1,i2,i3: Integer;
const
    Cutoff = 20;
begin
    //リストの要素が少なくなったセレクションソートに切り替え
    if (max - min < Cutoff) then begin
        SelectionSortNo(ColNo, min, max);
        exit;
    end;
    //サブリストを、再帰的にソートする
    middle := min div 2 + max div 2;
    MergeSortNoSub(ColNo, min, middle, scratch);
    MergeSortNoSub(ColNo, middle+1, max, scratch);
    //ソートされたリストをマージする
    i1 := min;
    i2 := middle + 1;
    i3 := min; // マージリストのインデックス
    while ((i1 <= middle)and(i2 <= max)) do
    begin
        if (StrToValue(Cells[ColNo,i1]) <= StrToValue(Cells[ColNo,i2])) then
        begin
            scratch.SetRow(i3, GetRow(i1));
            Inc(i1);
        end else
        begin
            scratch.SetRow(i3, GetRow(i2));
            Inc(i2);
        end;
        i3 := i3 + 1;
    end;
    //リストが空でなければ、空にする
    while (i1 <= middle) do
    begin
        scratch.SetRow(i3, GetRow(i1));
        Inc(i1);
        Inc(i3);
    end;
    while (i2 <= max) do
    begin
        scratch.SetRow(i3, GetRow(i2));
        Inc(i2);
        Inc(i3);
    end;
    //マージされたリストを、元に戻す
    for i3:=min to max do
    begin
        SetRow(i3, scratch.GetRow(i3));
    end;

end;

procedure TCsvDb.MergeSortSub(ColNo, Min, Max: Integer;
  scratch: TCsvDb);
var
    middle,i1,i2,i3: Integer;
const
    Cutoff = 20;
begin
    //リストの要素が少なくなったセレクションソートに切り替え
    if (max - min < Cutoff) then begin
        SelectionSort(ColNo, min, max);
        exit;
    end;
    //サブリストを、再帰的にソートする
    middle := min div 2 + max div 2;
    MergeSortSub(ColNo, min, middle, scratch);
    MergeSortSub(ColNo, middle+1, max, scratch);
    //ソートされたリストをマージする
    i1 := min;
    i2 := middle + 1;
    i3 := min; // マージリストのインデックス
    while ((i1 <= middle)and(i2 <= max)) do
    begin
        if (Cells[ColNo,i1] <= Cells[ColNo,i2]) then
        begin
            scratch.SetRow(i3, GetRow(i1));
            Inc(i1);
        end else
        begin
            scratch.SetRow(i3, GetRow(i2));
            Inc(i2);
        end;
        i3 := i3 + 1;
    end;
    //リストが空でなければ、空にする
    while (i1 <= middle) do
    begin
        scratch.SetRow(i3, GetRow(i1));
        Inc(i1);
        Inc(i3);
    end;
    while (i2 <= max) do
    begin
        scratch.SetRow(i3, GetRow(i2));
        Inc(i2);
        Inc(i3);
    end;
    //マージされたリストを、元に戻す
    for i3:=min to max do
    begin
        SetRow(i3, scratch.GetRow(i3));
    end;

end;

procedure TCsvDb.OR_BoolArray(var A: BoolArray; const B: BoolArray);
var
    i: Integer;
begin
    for i:=0 to High(A) do
    begin
        A[i] := A[i] or B[i];
    end;
end;

function TCsvDb.Pickup(Field, pattern: string): TCsvDb;
begin
    //フィールド番号を得る
    Result := PickupNo(GetFieldNo( Field ), pattern);
end;

// 計算用関数テーブル
    function f_eq_s(const a,b: string): Boolean; begin Result := EasyMasks.MatchesMask(a,b);  end;
    function f_ne_s(const a,b: string): Boolean; begin Result := not(EasyMasks.MatchesMask(a,b)); end;
    function f_gt_s(const a,b: string): Boolean; begin Result := ( a>b );  end;
    function f_gt_eq_s(const a,b: string): Boolean; begin Result := ( a>=b );  end;
    function f_lt_s(const a,b: string): Boolean; begin Result := ( a<b );  end;
    function f_lt_eq_s(const a,b: string): Boolean; begin Result := ( a<=b );  end;

    function f_eq_v(const a,b: Extended): Boolean; begin Result := ( a=b );  end;
    function f_ne_v(const a,b: Extended): Boolean; begin Result := ( a<>b ); end;
    function f_gt_v(const a,b: Extended): Boolean; begin Result := ( a>b );  end;
    function f_gt_eq_v(const a,b: Extended): Boolean; begin Result := ( a>=b );  end;
    function f_lt_v(const a,b: Extended): Boolean; begin Result := ( a<b );  end;
    function f_lt_eq_v(const a,b: Extended): Boolean; begin Result := ( a<=b );  end;

    function f_eq_d(const a,b: TDateTime): Boolean; begin Result := ( a=b );  end;
    function f_ne_d(const a,b: TDateTime): Boolean; begin Result := ( a<>b ); end;
    function f_gt_d(const a,b: TDateTime): Boolean; begin Result := ( a>b );  end;
    function f_gt_eq_d(const a,b: TDateTime): Boolean; begin Result := ( a>=b );  end;
    function f_lt_d(const a,b: TDateTime): Boolean; begin Result := ( a<b );  end;
    function f_lt_eq_d(const a,b: TDateTime): Boolean; begin Result := ( a<=b );  end;


{|*** commandの条件に合致したものを、BoolArrayにチェックする ***
 |コマンド例）　FIELD_NAME = "大岩町"
 |              FIELD_NAME >= 30
}
function TCsvDb.PickupArrayMatch(command: string): BoolArray;
var
    field, flag, value: string;
    fno: Integer;
    evalue: Extended;
    value_date: TDateTime;
    i, flagNo: Integer;
    c: TCsvCells;

    funcStrArray: array [1..6] of FuncCompStr;
    funcValArray: array [1..6] of FuncCompVal;
    funcDateArray: array [1..6] of FuncCompDate;
const
    enzan: TCharSet = ['=','<','>'];
    E_EQ = 1;
    E_NE = 2;
    E_GT = 3;
    E_GT_EQ = 4;
    E_LT = 5;
    E_LT_EQ = 6;

    procedure Analize;
    var p: PChar;
    begin
        p := PChar(command);
        //get field_name
        field := Trim(GetTokenChars(enzan, p));
        Dec(p);//区切り文字として削除された分を戻す
        //get flag
        flag := '';
        while p^ in enzan do begin
            flag := flag + p^;
            Inc(p);
        end;
        flagNo := 0;
             if(flag='=')or(flag='==') then flagNo := E_EQ
        else if(flag='<>')or(flag='><')then flagNo := E_NE
        else if(flag='>' )             then flagNo := E_GT
        else if(flag='>=')or(flag='=>')then flagNo := E_GT_EQ
        else if(flag='<' )             then flagNo := E_LT
        else if(flag='<=')or(flag='=<')then flagNo := E_LT_EQ
        ;
        if flagNo = 0 then raise EParserError.Create('演算子の指定エラー。');
        //get value
        value := Trim(string( PChar(p) ));
    end;

    procedure SetFunc;
    begin
        funcStrArray[E_EQ] := f_eq_s;
        funcStrArray[E_NE] := f_ne_s;
        funcStrArray[E_GT] := f_gt_s;
        funcStrArray[E_GT_EQ] := f_gt_eq_s;
        funcStrArray[E_LT] := f_lt_s;
        funcStrArray[E_LT_EQ] := f_lt_eq_s;

        funcValArray[E_EQ] := f_eq_v;
        funcValArray[E_NE] := f_ne_v;
        funcValArray[E_GT] := f_gt_v;
        funcValArray[E_GT_EQ] := f_gt_eq_v;
        funcValArray[E_LT] := f_lt_v;
        funcValArray[E_LT_EQ] := f_lt_eq_v;

        funcDateArray[E_EQ] := f_eq_d;
        funcDateArray[E_NE] := f_ne_d;
        funcDateArray[E_GT] := f_gt_d;
        funcDateArray[E_GT_EQ] := f_gt_eq_d;
        funcDateArray[E_LT] := f_lt_d;
        funcDateArray[E_LT_EQ] := f_lt_eq_d;
    end;

begin
    if RowList.Count = 0 then begin Result := nil; Exit; end;
    if command='' then begin Result := nil; Exit; end;

    SetLength(Result, RowList.Count);
    SetFunc;
    Analize;

    fno := GetFieldNo(field);
    if fno=-1 then raise EParserError.Create('フィールド名"'+field+'"が見つかりません。');

    Result[0] := True;
    //文字列か、数値か判断する
    if (Copy(value,1,1)='"')or(Copy(value,1,1)='`') then
    begin //文字比較
        Delete(value,1,1);              //前後の""を削除
        Delete(value,Length(value),1);
        value := ConvToHalf(value);
        for i:=1 to rowList.Count -1 do
        begin
            c := rowList.Items[i];
            if (c<>nil) then begin
                Result[i] := funcStrArray[flagNo](ConvToHalf(c.Items[fno]), value);
            end else
                Result[i] := False;
        end;
    end else
    if (Copy(value,1,1)='#') then
    begin //日時の比較
        Delete(value,1,1);              //日付前の#を削除
        //Delete(value,Length(value),1);
        try

        value_date := VarToDateTime(value);
        for i:=1 to rowList.Count -1 do
        begin
            c := rowList.Items[i];
            try
            if (c<>nil) then begin
                Result[i] := funcDateArray[flagNo](VarToDateTime(c.Items[fno]), value_date);
            end else
                Result[i] := False;
            except //日付の変換エラーは気にしない
            end;
        end;

        except
        end;
    end else
    begin //数値比較
        evalue := StrToValue( value );
        for i:=1 to rowList.Count -1 do
        begin
            c := rowList.Items[i];
            if (c<>nil) then begin
                Result[i] := funcValArray[flagNo](StrToValue(c.Items[fno]), evalue);
            end else
                Result[i] := False;
        end;
    end;
end;

function TCsvDb.PickupArrayMatchEx(command: string): BoolArray;
var
    p: PChar;
    ba: BoolArray;
    i: Integer;
    field,flag,value: string;
const
    enzan: TCharSet = ['=','<','>'];

begin
    SetLength(Result, rowList.Count); ba := nil;
    for i:=0 to rowList.Count -1 do
    begin
        Result[i] := False;
    end;
    
    p := PChar( command );
    while p^<>#0 do
    begin
        while p^ in [' ',#9] do Inc(p);
        if p^='(' then
        begin
            ba := PickupArrayMatchEx(GetKakko(p));
            OR_BoolArray(Result, ba);
            Continue;
        end;
        if (StrLComp(p, 'AND ', 4)=0)or(StrLComp(p, 'and ', 5)=0) then
        begin
            Inc(p,4);
            ba := PickupArrayMatchEx(string( p ));
            AND_BoolArray(Result, ba);
            Break;
        end;
        if (StrLComp(p, 'OR ', 3)=0)or(StrLComp(p, 'or ', 3)=0) then
        begin
            Inc(p,3);
            ba := PickupArrayMatchEx(string( p ));
            OR_BoolArray(Result, ba);
            Break;
        end;
        //get fieldname
        field := Trim(GetTokenChars(enzan, p));
        Dec(p);//デリミタとして行き過ぎのポインタを戻す
        //get flags
        flag := '';
        while p^ in enzan do begin
            flag := flag + p^;
            Inc(p);
        end;
        //get value
        while p^ in [#9,' ',#13,#10] do Inc(p);
        value := Trim(GetTokenChars([' ',#9,#13,#10], p));
        ba := PickupArrayMatch(field+' '+flag+' '+value);
        OR_BoolArray(Result, ba);
    end;
end;

function TCsvDb.PickupCommand(commandStr: string): TCsvDb;
var
    a: BoolArray;
    i: Integer;

    procedure data_match;
    var c,cc: TCsvCells;
    begin
        c := GetRow (i);
        if c=nil then
            Result.RowList.Add(nil)
        else
        begin
            cc := TCsvCells.Create;
            cc.Assign(c);
            Result.RowList.Add(cc);
        end;
    end;

begin
    a := nil;
    Result := TCsvDb.Create;
    commandStr := Trim(commandStr);
    if commandStr='' then Exit;

    a := PickupArrayMatchEx(commandStr);
    if a=nil then Exit;

    for i:=0 to High(a) do
    begin
        if a[i] then data_match;
    end;
end;

function TCsvDb.PickupNo(FieldNo: Integer; pattern: string): TCsvDb;
var
    i,from: Integer;
    c: TCsvCells;

    procedure data_match;
    var cc: TCsvCells;
    begin
        if c=nil then
            Result.RowList.Add(nil)
        else
        begin
            cc := TCsvCells.Create;
            cc.Assign(c);
            Result.RowList.Add(cc);
        end;
    end;

begin
    Result := TCsvDb.Create;

    if UseHeader then
    begin
        from := 1;
        c := GetRow(0);
        data_match;
    end else from := 0;

    //フィールド番号を得る
    if FieldNo<0 then Exit;

    if (JPosEx('*', pattern,1)=0)and(JPosEx('?', pattern,1)=0)and(JPosEx('[', pattern,1)=0)then
    begin
        for i:=from to rowList.Count-1 do
        begin
            c := GetRow(i);
            if c=nil then Continue;
            if JPosEx(pattern, c.GetValue(FieldNo), 1)>0 then data_match;
        end;
    end else
    begin
        for i:=from to rowList.Count-1 do
        begin
            c := GetRow(i);
            if c=nil then Continue;
            if WildMatchFilename(c.GetValue(FieldNo), pattern) then data_match;
        end;
    end;
end;

procedure TCsvDb.QuickSort(ColNo: Integer);
var
    p: TCsvCells;
begin
    QSortColNo := ColNo;
    if UseHeader then
    begin
        p := RowList.Items[0];
        RowList.Delete(0);
        TrimRow;
        RowList.Sort( CsvDbSortStr );
        RowList.Insert(0, p);
    end else
        RowList.Sort( CsvDbSortStr );

end;

procedure TCsvDb.RowColChange;
var
    i,j,rc,cc: Integer;
    db: TCsvDb;
    c: TCsvCells;
begin
    db := TCsvDb.Create ;
    try

    rc := RowCount;
    cc := ColCount;

    for i:=0 to cc -1 do
    begin
        for j:=0 to rc -1 do
        begin
            db.Cells[j,i] := Self.Cells[i,j];
        end;
    end;

    Self.Clear ;


    for i:=0 to cc-1 do
    begin
        c := TCsvCells.Create ;
        try
            c.Assign(db.GetRow(i));
            self.RowList.Add(c);
        except
        end;
    end;
    TrimRow ;

    finally
        db.Free;
    end;
end;

procedure TCsvDb.SelectionSort(ColNo, Min, Max: Integer);
var
    i,j: Integer;
    best_j: Integer;
    best_value: string;
begin
    for i:=min to max-1 do
    begin
        // 残りの要素から一番小さいものを見つける
        best_value := Cells[ColNo, i];
        best_j := i;
        for j := i+1 to max do
            if (Cells[colNo,j] < best_value) then
            begin
                best_value := Cells[ColNo, j];
                best_j := j;
            end;
        //要素を交換する
        RowList.Exchange(i, best_j);
    end;
end;

procedure TCsvDb.SelectionSortDate(ColNo, Min, Max: Integer);
var
    i,j: Integer;
    best_j: Integer;
    best_value, d: TDateTime;
begin
    for i:=min to max-1 do
    begin
        // 残りの要素から一番小さいものを見つける
        best_value := VarToDateTimeZ(Cells[ColNo, i]);

        best_j := i;
        for j := i+1 to max do
        begin
            d := VarToDateTimeZ(Cells[colNo,j]);
            if (VarToDateTime(d) < best_value) then
            begin
                best_value := VarToDateTimeZ(Cells[ColNo, j]);
                best_j := j;
            end;
        end;
        //要素を交換する
        RowList.Exchange(i, best_j);
    end;
end;

procedure TCsvDb.SelectionSortNo(ColNo, Min, Max: Integer);
var
    i,j: Integer;
    best_j: Integer;
    best_value: Double;
begin
    for i:=min to max-1 do
    begin
        // 残りの要素から一番小さいものを見つける
        best_value := StrToValue(Cells[ColNo, i]);
        best_j := i;
        for j := i+1 to max do
            if (StrToValue(Cells[colNo,j]) < best_value) then
            begin
                best_value := StrToValue(Cells[ColNo, j]);
                best_j := j;
            end;
        //要素を交換する
        RowList.Exchange(i, best_j);
    end;
end;

{$IFDEF VNAKO}
procedure TCsvDb.SetStringGrid(const grd: TStringGrid;
  AdjustGridWidth: Boolean);
var
	x,y,w,h: Integer;
	ACol, ARow, MaxSize: Integer;
begin
	if grd=nil then Exit;

  // 現在のグリッドを全部クリア
  for y := 0 to grd.RowCount - 1 do
  begin
    for x := 0 to grd.ColCount - 1 do
    begin
      grd.Cells[x, y] := '';
    end;
  end;

  // 新しい値をセット
  if RowCount <> 0 then
    grd.RowCount  := RowCount + 1
  else
    grd.RowCount  := 2;
  grd.ColCount  := ColCount;
  grd.FixedRows := 1;
  grd.FixedCols := 0;

	for y:=0 to RowCount-1 do // -1 しないのは、Gridをクリアするため。
  begin
    for x:=0 to ColCount-1 do
    begin
      grd.Cells[x,y] := Cells[x,y];
    end;
  end;

  // セルの幅を自動調節
  if AdjustGridWidth then
  begin
		with grd do
    begin
      Canvas.Font := Font;

      h := Canvas.TextHeight('Z');

      for ACol := 0 to ColCount - 1 do
      begin
        MaxSize := 0;
        for ARow := 0 to RowCount - 1 do
        begin
          w := Canvas.TextWidth(Cells[ACol, ARow]);
          if MaxSize < w then MaxSize := w;
        end;
        if MaxSize = 0 then ColWidths[ACol] := DefaultColWidth
                       else ColWidths[ACol] := MaxSize + 5;
      end;
      DefaultRowHeight := h + 4;
    end;
  end;
end;
{$ENDIF}

procedure TCsvDb.TrimRow;
var
    i: Integer;
    c: TCsvCells ;
begin
    // 上側
    {
    i := 0;
    while i < rowList.Count do
    begin
        c := getRow(i);
        if c<>nil then
        begin
            if c.CanTrimAll then
            begin
                DeleteRow(i);
                Continue;
            end else
                Break;
        end else
        if c = nil then
        begin
            DeleteRow(i);
        end else Break;
    end;
    }
    // 下側
    i := rowList.Count-1;
    while i >= 0 do
    begin
        c := getRow(i);
        if c<>nil then begin
            if c.CanTrimAll then
            begin
                DeleteRow(i);
                c := nil;
            end;
        end;
        if c = nil then begin
            DeleteRow(i);
            Dec(i);
        end else Break;
    end;
end;


function TCsvDb.PickupNoComplete(FieldNo: Integer;
  pattern: string): TCsvDb;
var
    i,from: Integer;
    c: TCsvCells;

    procedure data_match;
    var cc: TCsvCells;
    begin
        if c=nil then
            Result.RowList.Add(nil)
        else
        begin
            cc := TCsvCells.Create;
            cc.Assign(c);
            Result.RowList.Add(cc);
        end;
    end;

begin
    Result := TCsvDb.Create;

    if UseHeader then
    begin
        from := 1;
        c := GetRow(0);
        data_match;
    end else from := 0;

    //フィールド番号を得る
    if FieldNo<0 then Exit;

    if (JPosEx('*', pattern,1)=0)and(JPosEx('?', pattern,1)=0)and(JPosEx('[', pattern,1)=0)then
    begin
        for i:=from to rowList.Count-1 do
        begin
            c := GetRow(i);
            if c=nil then Continue;
            if pattern = c.GetValue(FieldNo) then data_match;
        end;
    end else
    begin
        for i:=from to rowList.Count-1 do
        begin
            c := GetRow(i);
            if c=nil then Continue;
            if WildMatchFilename(c.GetValue(FieldNo), pattern) then data_match;
        end;
    end;
end;

procedure TCsvDb.UniqCol(ColNo: Integer);
var
  i, no: Integer; line: string;
begin
  i := 0;

  if UseHeader then i := 1;

  if ColNo < 0 then
  begin
    while i < RowList.Count do
    begin
      line := GetRowCommaText(i);
      while True do
      begin
        no := FindLine(line, i+1);
        if no < 0 then Break;
        RowList.Delete(no); 
      end;
      Inc(i);
    end;
  end else
  begin
    while i < RowList.Count do
    begin
      line := Cells[ColNo, i];
      while True do
      begin
        no := Find(line, ColNo, i+1);
        if no < 0 then Break;
        RowList.Delete(no);
      end;
      Inc(i);
    end;
  end;
end;

procedure TCsvDb.CustomMergeSort(ColNo: Integer; custom: TCsvDbCustomSort);
var
    scratch: TCsvDb;
    from: Integer;
begin
    scratch := TCsvDb.Create ;
    try
        scratch.RowList.Capacity := RowList.Count;
        TrimRow;
        if UseHeader then from := 1 else from := 0;
        CustomMergeSortSub(ColNo, from, RowList.Count-1, scratch, custom);
        scratch.RowList.Clear ;//誤ってデータを二重に削除するのを防ぐため
    finally
        scratch.Free;
    end;
end;

procedure TCsvDb.CustomMergeSortSub(ColNo, Min, Max: Integer;
  scratch: TCsvDb; custom: TCsvDbCustomSort);
var
    middle,i1,i2,i3: Integer;
const
    Cutoff = 20;
begin
    //リストの要素が少なくなったセレクションソートに切り替え
    if (max - min < Cutoff) then begin
        CustomSelectionSort(ColNo, min, max, custom);
        exit;
    end;
    //サブリストを、再帰的にソートする
    middle := min div 2 + max div 2;
    CustomMergeSortSub(ColNo, min, middle, scratch, custom);
    CustomMergeSortSub(ColNo, middle+1, max, scratch, custom);
    //ソートされたリストをマージする
    i1 := min;
    i2 := middle + 1;
    i3 := min; // マージリストのインデックス
    while ((i1 <= middle)and(i2 <= max)) do
    begin
        if custom(Cells[ColNo,i1],Cells[ColNo,i2]) > 0 then
        begin
            scratch.SetRow(i3, GetRow(i1));
            Inc(i1);
        end else
        begin
            scratch.SetRow(i3, GetRow(i2));
            Inc(i2);
        end;
        i3 := i3 + 1;
    end;
    //リストが空でなければ、空にする
    while (i1 <= middle) do
    begin
        scratch.SetRow(i3, GetRow(i1));
        Inc(i1);
        Inc(i3);
    end;
    while (i2 <= max) do
    begin
        scratch.SetRow(i3, GetRow(i2));
        Inc(i2);
        Inc(i3);
    end;
    //マージされたリストを、元に戻す
    for i3:=min to max do
    begin
        SetRow(i3, scratch.GetRow(i3));
    end;
end;

procedure TCsvDb.CustomSelectionSort(ColNo, Min, Max: Integer;
  custom: TCsvDbCustomSort);
var
    i,j: Integer;
    best_j: Integer;
    best_value: string;
begin
    for i:=min to max-1 do
    begin
        // 残りの要素から一番小さいものを見つける
        best_value := Cells[ColNo, i];
        best_j := i;
        for j := i+1 to max do
            if custom(Cells[colNo,j], best_value) >= 0 then
            begin
                best_value := Cells[ColNo, j];
                best_j := j;
            end;
        //要素を交換する
        RowList.Exchange(i, best_j);
    end;
end;


function DicSort(Item1, Item2: String): Integer;
var
  s1, s2: WideString;
begin
  s1 := Item1; s1 := LowerCase(s1);
  s2 := Item2; s2 := LowerCase(s2);
  if s1 = s2 then Result := 0 else
  if s1 < s2 then Result := 1 else Result := -1;
end;

procedure TCsvDb.MergeSortDic(ColNo: Integer);
begin
  CustomMergeSort(ColNo, DicSort);
end;

end.
