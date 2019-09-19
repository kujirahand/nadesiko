unit unit_zip;

// 郵便番号検索辞書の検索

interface
uses
  Windows, SysUtils, Classes, strunit;

type
  TProcProgress = procedure (per: Integer); stdcall;


  //ken---8----   shi---22---   cho---74---
  TZipKen = array [0..7] of Char;
  TZipShi = array [0..21] of Char;
  TZipCho = array [0..73] of Char;

  PZipAddr = ^TZipAddr;
  TZipAddr = packed record
    zip: DWORD;
    ken: TZipKen;
    Shi: TZipShi;
    Cho: TZipCho;
  end;

  PZipIndex = ^TZipIndex;
  TZipIndex = packed record
    index: Byte;
    recNo: DWORD;
  end;

  TFindRange = record
    rFrom, rTo: Integer;
  end;

  // -[ZipDB SYSTEM]-------------------
  // TZipHead
  // TZipAddr  *
  // TZipIndex *
  // ---------------------------------
  TZipHead = packed record
    DBID: array [0..3] of Char; //'mzip'
    DataCount:  DWORD;
    IndexCount: DWORD;
    space:      DWORD;
  end;

  TZipDB = class(TList)
  private
    lstIndex: TList;
    function FindIndex(szip: string): Integer;
    procedure ClearIndex;
    function zip2str(p: PZipAddr): string;
    function zip2index(p: PZipAddr): Byte;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; override;
    procedure LoadFromFile(Filename: string);
    procedure SaveToFile(Filename: string);
    //procedure SortDB;
    function LoadFromCsvFile(ken_all: string; progress: TProcProgress): Boolean;
    function FindZip(szip: string): Integer;
    function FindZipAddr(szip: string): string;
    function FindZipCode(ken, shi, cho: string): string;
    function getAllKen: string;
    function getAllShi(ken: string): string;
    function getAllCho(ken, shi: string): string;
    //
    function getKen(p: PZipAddr): string;
    function getShi(p: PZipAddr): string;
    function getCho(p: PZipAddr): string;
    //
    function KenRange(ken: string): TFindRange;
    function ShiRange(ken, shi: string): TFindRange;
  end;

function ZipDB: TZipDB;
procedure ZipDBFree;


implementation

uses Masks;

var FZipDB: TZipDB = nil;

function ZipDB: TZipDB;
begin
  if FZipDB = nil then FZipDB := TZipDB.Create;
  Result := FZipDB;
end;

procedure ZipDBFree;
begin
  FreeAndNil(FZipDB);
end;

{ TZipDB }

procedure TZipDB.Clear;
var
  i: Integer;
  pa: PZipAddr;
begin
  // index のクリア
  ClearIndex;

  // データのクリア
  for i := 0 to Count - 1 do
  begin
    pa := Items[i];
    Dispose(pa);
  end;
  inherited Clear;
end;

procedure TZipDB.ClearIndex;
var
  i: Integer;
  pi: PZipIndex;
begin
  // index のクリア
  for i := 0 to lstIndex.Count - 1 do
  begin
    pi := lstIndex.Items[i];
    Dispose(pi);
  end;
  lstIndex.Clear;
end;

constructor TZipDB.Create;
begin
  lstIndex := TList.Create;
end;

destructor TZipDB.Destroy;
begin
  Clear;
  inherited;
  FreeAndNil(lstIndex);
end;

function TZipDB.FindIndex(szip: string): Integer;
var
  i: Integer;
  pi: PZipIndex;
  fc: Byte; // <---
  s: string;
begin
  Result := -1;
  s := Copy(Trim(szip),1,1);
  fc := StrToIntDef(s,0);

  // Indexの検索
  for i := 0 to lstIndex.Count - 1 do
  begin
    pi := lstIndex.Items[i];
    if fc = pi.index then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TZipDB.FindZip(szip: string): Integer;
var
  ii, idx1, i: Integer;
  pa: PZipAddr;
  fzip: DWORD;
begin
  Result := -1;

  ii := FindIndex(szip);
  if ii < 0 then Exit;

  idx1 := PZipIndex(lstIndex.Items[ii])^.recNo;

  // 検索用の数値を取得
  fzip := StrToInt64Def(szip, 0);

  // 検索
  for i := idx1 to Count-1 do
  begin
    pa := Items[i];
    if pa^.zip = fzip then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TZipDB.FindZipAddr(szip: string): string;
var
  i: Integer;
  pa: PZipAddr;
  //ken, shi, cho: string;
begin
  szip := JReplace(szip,'-','',True);
  i := FindZip(szip);
  if i < 0 then Result := ''
  else begin
    pa := Items[i];
    Result := getKen(pa) + getShi(pa) + getCho(pa);
  end;
end;

function TZipDB.FindZipCode(ken, shi, cho: string): string;
var
  r: TFindRange;
  i: Integer;
  p: PZipAddr;
begin
  //------------------------------
  // 住所から郵便番号を検索する
  //------------------------------
  Result := '';
  r := ShiRange(ken, shi);
  for i := r.rFrom to r.rTo do
  begin
    p := Items[i];
    if cho = getCho(p) then begin
      Result := IntToStr(p.zip);
      Break;
    end;
  end;
end;

function TZipDB.getAllCho(ken, shi: string): string;
var
  i: integer;
  p: PZipAddr;
  sl: TStringList;
  o,s: string;
  r: TFindRange;
begin
  sl := TStringList.Create;
  try
    Result := '';
    o := '';
    r := ShiRange(ken, shi);
    if r.rFrom < 0 then Exit;
    for i := r.rFrom to r.rTo do
    begin
      p := Items[i];
      s := getCho(p);
      if (s <> o)and(s <> '') then
      begin
        if sl.IndexOf(s) < 0 then sl.Add(s);
        o := s;
      end;
    end;
    Result := sl.Text;
  finally
    sl.Free;
  end;
end;

function TZipDB.getAllKen: string;
var
  i: Integer;
  p: PZipAddr;
  s, o: string;
  sl: TStringList;
begin
  Result := '';
  o := '';
  sl := TStringList.Create;
  try
    for i := 0 to Count - 1 do
    begin
      p := Items[i];
      s := getKen(p);
      if s <> o then
      begin
        if sl.IndexOf(s) < 0 then sl.Add(s);
        o := s;
      end;
    end;
    sl.Sort;
    Result := sl.Text;
  finally
    sl.Free;
  end;
end;

function TZipDB.getAllShi(ken: string): string;
var
  i: integer;
  p: PZipAddr;
  sl: TStringList;
  o,s: string;
begin
  sl := TStringList.Create;
  try
    Result := '';
    o := '';
    for i := 0 to Count - 1 do
    begin
      p := Items[i];
      if ken = getKen(p) then begin
        s := getShi(p);
        if (o <> s)and(s<>'') then begin
          if sl.IndexOf(s) < 0 then sl.Add(s);
          o := s;
        end;
      end;
    end;
    Result := sl.Text;
  finally
    sl.Free;
  end;
end;

function TZipDB.getCho(p: PZipAddr): string;
begin
  SetLength(Result, SizeOf(p.Cho));
  System.Move(p.Cho[0], Result[1], SizeOf(p.Cho));
  Result := PChar(Result);
end;

function TZipDB.getKen(p: PZipAddr): string;
begin
  SetLength(Result, SizeOf(p.Ken));
  System.Move(p.Ken[0], Result[1], SizeOf(p.Ken));
  Result := PChar(Result);
end;

function TZipDB.getShi(p: PZipAddr): string;
begin
  SetLength(Result, SizeOf(p.Shi));
  System.Move(p.Shi[0], Result[1], SizeOf(p.Shi));
  Result := PChar(Result);
end;

function TZipDB.KenRange(ken: string): TFindRange;
var
  i: Integer;
  p: PZipAddr;
begin
  Result.rFrom := -1;
  Result.rTo := -1;
  for i := 0 to Self.Count - 1 do
  begin
    p := Items[i];
    if getKen(p) = ken then
    begin
      Result.rFrom := i; Break;
    end;
  end;
  if Result.rFrom < 0 then Exit;
  for i := Result.rFrom to Self.Count - 1 do
  begin
    p := Items[i];
    if getKen(p) <> ken then
    begin
      Result.rTo := i - 1; Break;
    end;
  end;
end;

function TZipDB.LoadFromCsvFile(ken_all: string;
  progress: TProcProgress): Boolean;
const
  MAX_KEN_ALL = 121671;
var
  i: Integer;
  f: TextFile;
  line: string;
  p: PChar;
  code, oldzip, zip, kana1, kana2, kana3, ken, shi, cho, aza: string;
  pa: PZipAddr;

  function chk(s: string): string;
  begin
    if (Copy(s,1,1) = '"')and(Copy(s,length(s),1) = '"') then
    begin
      Result := Copy(s,2,Length(s)-2);
    end;
  end;

begin
  // clear
  Self.Clear;

  //23520 行
  i := 0;
  AssignFile(f, ken_all);
  Reset(f);
  try
    while not EOF(f) do
    begin
      // progress
      if Assigned(progress) then
      begin
        if (i mod 3000) = 0 then
        begin
          progress(Trunc(100 * i / MAX_KEN_ALL));
        end;
      end;
      // read line
      Readln(f, line);
      // 区別
      p := PChar(line);
      code   := Trim( GetTokenPtr(',', p) ); if code = '' then Continue;
      oldzip := GetTokenPtr(',', p);
      zip    := chk(GetTokenPtr(',', p));
      kana1 := GetTokenPtr(',', p);
      kana2 := GetTokenPtr(',', p);
      kana3 := GetTokenPtr(',', p);
      ken   := chk(GetTokenPtr(',', p));
      shi   := chk(GetTokenPtr(',', p));
      cho   := chk(GetTokenPtr(',', p));
      aza   := '';
      //
      if cho = '以下に掲載がない場合' then cho := '' else
      if Pos('（', cho) > 0 then begin
        aza := cho;
        cho := GetToken('（', aza);
        aza := GetToken('）', aza);
        if aza='その他' then aza := '';
        if Pos('､', aza) > 0 then // 字の選択がある
        begin
          aza := '|' + aza;
        end;
      end;
      cho := cho + aza; aza := '';

      // DBに登録
      New(pa);
      ZeroMemory(pa, SizeOf(TZipAddr));
      pa.zip := StrToInt64Def(zip, 0);
      System.Move(ken[1], pa.ken[0], Length(ken));
      StrCopy(@pa.shi[0], PChar(shi));
      StrCopy(@pa.cho[0], PChar(cho));
      Self.Add(pa);
  {
  0全国地方公共団体コード(JIS X0401、X0402)………　半角数字
  1(旧)郵便番号(5桁)………………………………………　半角数字
  2郵便番号(7桁)………………………………………　半角数字
  3都道府県名　…………　半角カタカナ(コード順に掲載)　(注1)
  4市区町村名　…………　半角カタカナ(コード順に掲載)　(注1)
  5町域名　………………　半角カタカナ(五十音順に掲載)　(注1)
  6都道府県名　…………　漢字(コード順に掲載)　(注1,2)
  7市区町村名　…………　漢字(コード順に掲載)　(注1,2)
  8町域名　………………　漢字(五十音順に掲載)　(注1,2)
  9一町域が二以上の郵便番号で表される場合の表示　(注3)　(「1」は該当、「0」は該当せず)
  10小字毎に番地が起番されている町域の表示　(注4)　(「1」は該当、「0」は該当せず)
  11丁目を有する町域の場合の表示　(「1」は該当、「0」は該当せず)
  12一つの郵便番号で二以上の町域を表す場合の表示　(注5)　(「1」は該当、「0」は該当せず)
  13更新の表示（注6）（「0」は変更なし、「1」は変更あり、「2」廃止（廃止データのみ使用））
  14変更理由　(「0」は変更なし、「1」市政・区政・町政・分区・政令指定都市施行、「2」住居表示の実施、「3」区画整理、「4」郵便区調整、集配局新設、「5」訂正、「6」廃止(廃止データのみ使用))
  }

      Inc(i);
    end;
    Result := True;
  finally
    CloseFile(f);
  end;
end;

procedure TZipDB.LoadFromFile(Filename: string);
var
  i : Integer;
  pi: PZipIndex;
  pa: PZipAddr;
  fs: TFileStream;
  head: TZipHead;
begin
  // がりがりDBを読む
  fs := TFileStream.Create(Filename, fmOpenRead);
  try
    fs.Read(head, sizeof(head));
    for i := 0 to head.DataCount - 1 do
    begin
      New(pa);
      fs.Read(pa^, sizeof(TZipAddr));
      Self.Add(pa);
    end;
    for i := 0 to head.IndexCount - 1 do
    begin
      New(pi);
      fs.Read(pi^, sizeof(TZipIndex));
      lstIndex.Add(pi);
    end;
  finally
    fs.Free;
  end;
end;

procedure TZipDB.SaveToFile(Filename: string);
var
  i : Integer;
  flag: Array [0..9] of Byte;
  pi: PZipIndex;
  pa: PZipAddr;
  fc: Byte;
  fs: TFileStream;
  head: TZipHead;
begin
  ClearIndex;
  //SortDB;

  // インデックス
  for i := 0 to 9 do flag[i] := 0;


  fs := TFileStream.Create(Filename, fmCreate or fmOpenWrite);
  try
    // write head
    fs.Position := 0;
    head.DBID := 'mzip';
    fs.Write(head, sizeof(head)); // dummy write

    // write body
    for i := 0 to Count - 1 do
    begin
      pa := Items[i];

      // index を追加
      fc := zip2index(pa);
      if flag[fc] = 0 then
      begin
        flag[fc] := 1;
        New(pi);
        pi^.index := fc;
        pi^.recNo := i;
        lstIndex.Add(pi);
      end;

      // データを追加
      fs.Write(pa^, sizeof(TZipAddr));
    end;
    // write index
    for i := 0 to lstIndex.Count - 1 do
    begin
      pi := lstIndex.Items[i];
      fs.Write(pi^, sizeof(TZipIndex));
    end;
    // rewrite header
    head.IndexCount := lstIndex.Count;
    head.DataCount  := Self.Count;
    head.space := 0;
    fs.Position := 0;
    fs.Write(head, sizeof(head));
  finally
    fs.Free;
  end;
end;
{
function sub_sort_db(Item1, Item2: Pointer): Integer;
var
  i1, i2: PZipAddr;
begin
  i1 := PZipAddr(Item1);
  i2 := PZipAddr(Item2);
  Result := i2^.zip - i1^.zip;
end;

procedure TZipDB.SortDB;
begin
  //Self.Sort(sub_sort_db);
end;
}

function TZipDB.ShiRange(ken, shi: string): TFindRange;
var
  r: TFindRange;
  i: Integer;
  p: PZipAddr;
begin
  Result.rFrom := -1;
  Result.rTo   := -1;
  r := KenRange(ken);
  if r.rFrom < 0 then Exit;
  for i := r.rFrom to r.rTo do
  begin
    p := Items[i];
    if shi = getShi(p) then
    begin
      Result.rFrom := i;
      Break;
    end;
  end;
  if Result.rFrom < 0 then Exit;
  for i := Result.rFrom to r.rTo do
  begin
    p := Items[i];
    if shi <> getShi(p) then
    begin
      Result.rTo := i-1;
      Break;
    end;
  end;
end;

function TZipDB.zip2index(p: PZipAddr): Byte;
var
  s: string;
begin
  s := Copy(zip2str(p), 1, 1);
  Result := StrToIntDef(s, 0);
end;

function TZipDB.zip2str(p: PZipAddr): string;
begin
  Result := Format('%.7d', [p^.zip]);
end;


initialization

finalization
  ZipDBFree;

end.
