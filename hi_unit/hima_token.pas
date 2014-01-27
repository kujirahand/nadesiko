unit hima_token;
//------------------------------------------------------------------------------
// トークン、ハッシュを管理する
//------------------------------------------------------------------------------
interface

uses
  Windows, SysUtils, hima_string, hima_types, hima_error, unit_string;

const
  IndentChars:    TChars   = [' ',#9];
  AlphabetChars1: TChars   = ['A'..'Z','a'..'z','_'];
  AlphabetChars2: TChars   = ['A'..'Z','a'..'z','_','0'..'9'];
  NumberChars1:   TChars   = ['-','0'..'9','$'];
  EnzansiChar1:   TChars   = ['+','-','*','/','%','^','>','<','=','!','&','|'];
  EnzansiChar2:   TChars   = ['=','>','<','&','|'];
  HimaMark:       TChars   = ['@','~','.',':','?',',','\'];

  // 文字数の多い順に並べること
  HimaJosuusi: Array [0..17] of AnsiString = (
    //<単位>
    'メートル','ドット','つ目','つめ','個目','個','円','つ','本','冊','人','px','pt','cm','mm','m','kg','g'
    //</単位>
  );


type
  THimaBlock = class;
  THimaFile  = class;
  THimaFiles = class;

  TTokenType = (
    tokenTango,
    tokenOperator,
    tokenNumber,
    tokenParenthesis,
    tokenString,
    tokenMark
  );

  THimaToken = class(TObject)
  public
    TokenID : DWORD;
    JosiID  : Integer;
    Token, Josi: AnsiString;
    NumberToken: Extended;
    Parent: THimaBlock;
    TokenType: TTokenType;
    NextToken: THimaToken; // 次のトークン
    constructor Create(Parent: THimaBlock);
    function CheckNextBlock: THimaToken;
    function GetConstStr: AnsiString;
    function GetConstPtr: Pointer;
    function UCToken: AnsiString; // 大文字変換してトークンを得る
    function LineNo: Integer; // 親を調べて求める
    function Indent: Integer;
    function FileNo: Integer;
    function DebugInfo: TDebugInfo;
    function GetAsText: AnsiString;
  end;

  THimaBlock = class(THObjectList)
  private
    function GetToken(Index: Integer): THimaToken;
    procedure SetToken(Index: Integer; const Value: THimaToken);
  public
    Parent: THimaFile;
    Indent: Integer; // インデントのレベル
    LineNo: Integer;
    NextBlock: THimaBlock;
    TopToken, CurToken: THimaToken;
    constructor Create(Parent: THimaFile);
    destructor Destroy; override;
    property Tokens[Index: Integer]: THimaToken read GetToken write SetToken;
    function GetAsText(kugiri: AnsiString): AnsiString;
    procedure Add(item: THimaToken);
  end;

  THimaFile = class(THObjectList)
  private
    procedure Analize(var src: AnsiString); //<--- トークンを区切る関数 ---------------- ***
  public
    Parent    : THimaFiles;
    Path, Filename : string;
    Fileno    : Integer;
    TopBlock,
    CurBlock  : THimaBlock;
    constructor Create(Parent: THimaFiles; Fileno: Integer);
    function GetAsText: AnsiString;
    function TopToken: THimaToken;
    procedure Add(item: THimaBlock);
    //
    procedure LoadFromFile(Filename: string);
    procedure SetSource(src: AnsiString);
  end;

  THimaFiles = class(THObjectList)
  public
    function FindFile(Filename: string): THimaFile;
    function LoadAndAdd(Filename: string): THimaFile;
    function LoadSourceAdd(SourceText: AnsiString; Filename: string): THimaFile;
    function FindFileNo(no: Integer): THimaFile;
  end;

  THimaTango = class(THHashItem)
  public
    ID: Integer;
  end;

  THimaTangoList = class(THHash)
  private
    FLastID: Integer;
    FFindID: Integer; //**検索用
    FFindKey: AnsiString; //**検索用
    function subEnumKeys(item: THHashItem): Boolean;
    function subFindKey(item: THHashItem): Boolean;
    function GetTango(key: AnsiString): THimaTango;
    procedure SetTango(key: AnsiString; const Value: THimaTango);
  public
    constructor Create;
    function GetID(key: AnsiString; DefaultID: Integer = -1): Integer;
    procedure SetID(key: AnsiString; Value: Integer);
    function FindKey(id: Integer): AnsiString;
    function EnumKeys: AnsiString;
    property Tangos[key: AnsiString]: THimaTango read GetTango write SetTango;
  end;

  THimaJosiList = class(THObjectList)
  private
    FLastID: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function GetID(key: AnsiString): Integer;
    procedure SetID(key: AnsiString; Value: Integer);
    function AddID(key: AnsiString): Integer;
    function Find(var p: PAnsiChar): AnsiString;
    function ID2Str(id: WORD): AnsiString;
    procedure SortByLen;
    function EnumKeys: AnsiString;
  end;

  THiKuraidori = class
  public
    kurai: AnsiString;
    bai: Extended;
    function Comp(var p: PAnsiChar): Boolean;
    constructor Create(akurai: AnsiString; abai: Extended);
  end;

  THiKuraidoriList = class(THObjectList)
  public
    function FindKurai(var p: PAnsiChar; var num: Extended): Boolean;
  end;



// トークンを切り出す
function HimaGetWord(var p: PAnsiChar; var tokenJosi: AnsiString): AnsiString;
// 数字の切り出し
function HimaGetNumber(var p: PAnsiChar; var tokenJosuusi: AnsiString): Extended;
// 文字列の切り出し
function HimaGetString(var p: PAnsiChar; var lineNo: Integer): AnsiString;
// 助詞に一致する語があれば抜き出す
function HimaGetJosi(var p: PAnsiChar): AnsiString;

// 初期登録単語の作成
procedure setTokenList(sys: TObject);
// 助詞一覧の作成
procedure setJosiList(sys: TObject);

// ファイルの検索
function HiFindFile(var fname: string): Boolean;

// 文字列を#0で埋めてから削除する
procedure HiResetString(var source:string);


const
//------------------------------------------------------------------------------
// 予約語の登録
//------------------------------------------------------------------------------
  // 記号は 99xxx
  token_kakko_begin      = 99100;
  token_kakko_end        = 99101;
  token_kaku_kakko_begin = 99102;
  token_kaku_kakko_end   = 99103;
  token_nami_kakko_begin = 99104;
  token_nami_kakko_end   = 99105;

  token_plus      = 99110;
  token_minus     = 99111;
  token_mul       = 99112; token_mark_function = 99112;
  token_div       = 99113;
  token_mod       = 99114;
  token_Eq        = 99115;
  token_NotEq     = 99116;
  token_Gt        = 99117;
  token_GtEq      = 99118;
  token_Lt        = 99119;
  token_LtEq      = 99120;
  token_ShiftL    = 99121;
  token_ShiftR    = 99122;
  token_tilde     = 99123;
  token_power     = 99124;
  token_plus_str  = 99125;
  token_or        = 99126;
  token_and       = 99127;
  token_katu      = 99128;
  token_matawa    = 99129;
  token_vLine     = 99130;
  token_Colon     = 99131;
  token_Semicolon = 99132;
  token_comma     = 99133;
  token_yen       = 99134;

  token_mark_option = 99150;
  token_mark_at     = 99151;
  token_mark_sikaku = 99152;
  token_mark_nakaten= 99153;
  token_mark_sankaku= 99154;

  // 単語は 99xxx
  token_mosi      = 99200;
  token_naraba    = 99201;
  token_tagaeba   = 99202;
  token_aida      = 99203;
  token_hanpuku   = 99204;
  token_kai       = 99205;
  token_kurikaesu = 99206;
  token_err_kansi = 99207;
  token_err       = 99208;
  token_loop      = 99209;
  token_joukenbunki = 99210;
  token_koko      = 99211;
  
  token_mojiretu = 99250;
  token_suuti    = 99251;
  token_seisu    = 99252;
  token_hensuu   = 99253;
  token_hairetu  = 99254;
  token_hash     = 99255;
  token_hensuu_sengen = 99256;
  token_hituyou       = 99257;
  token_huyou         = 99258;
  token_private  = 99259;
  token_event    = 99260;
  token_jissuu   = 99261;
  token_group    = 99262;
  token_ByVal    = 99263; // 値渡し
  token_ByRef    = 99264; // 参照渡し
  token_system   = 99265; // システム
  token_user     = 99266; // ユーザー
  token_hensuu_syokika = 99267; // 変数初期化

  token_tukuru  = 99271;
  token_name    = 99272;
  token_include = 99273;
  token_default = 99274;
  token_kaisu   = 99275;
  token_errMsg  = 99276;
  token_taisyou = 99277; // 対象
  token_namespace_henkou = 99278; // ネームスペース変更
  token_kowasu = 99279;

  token_sore  = 99300;
  token_s     = 99301;
  token_v     = 99302;
  token_cnt   = 99303;
  token_a     = 99304;
  token_b     = 99305;
  token_c     = 99306;
  token_f     = 99307;
  token_x     = 99308;
  token_y     = 99309;
  token_sono  = 99310;
  token_jisin = 99311;
  token_kore  = 99312;

  token_left  = 99350;
  token_right = 99351;

  token_dainyu = 99352;
  token_question = 99353;


//------------------------------------------------------------------------------
// 助詞の登録
//------------------------------------------------------------------------------
  josi_wa         = 50;
  josi_nituite    = 51;
  josi_naraba     = 52;
  josi_denakereba = 53;
  josi_wo         = 54;
  josi_ga         = 55;
  josi_no         = 56;
  josi_kara       = 57;
  josi_made       = 58;
  josi_madewo     = 59;
  josi_de         = 60;
  josi_towa       = 61;
  josi_ni         = 62;
  josi_he         = 63;
  josi_te         = 64;

implementation

uses unit_file_dnako, hima_system, unit_pack_files, mini_file_utils;

var
  KuraidoriList: THiKuraidoriList;

function HiFindFile(var fname: string): Boolean;
var
  rawpath, path: string;
  name: string;

  function check(testpath: string): Boolean;
  begin
    Result := False;
    if FileExists(string(testpath + name)) then
    begin
      Result := True;
      fname := testpath + name;
    end;
  end;

begin
  Result := True;

  rawpath := (ExtractFilePath(string(fname)));
  name := ExtractFileName(fname);

  // 絶対指定か？
  if (Pos(':\', rawpath) > 0)or(Pos('\\', rawpath) > 0) then
  begin
    Result := FileExists(fname); Exit;
  end;

  // 大体が相対指定のはず
  //-------------------------------------
  // includeの基本パス
  path := CheckPathYen(
    string(GetAbsolutePath(
      (rawpath),
      string(HiSystem.FIncludeBasePath), '\')) );
  if check(path) then Exit;
  // includeの基本パス\lib
  path := path + 'lib\';
  if check(path) then Exit;
  // runtimeパス
  path := CheckPathYen( string(GetAbsolutePath(string(rawpath), ExtractFilePath(ParamStr(0)), '\')) );
  if check(path) then Exit;
  // runtimeパス\lib
  path := path + 'lib\';
  if check(path) then Exit;
  // bokanパス
  path := CheckPathYen( GetAbsolutePath(rawpath, string(HiSystem.BokanPath), '\') );
  if check(path) then Exit;
  // bokan\lib
  path := path + 'lib\';
  if check(path) then Exit;
  // Plug-ins dir
  if check(HiSystem.PluginsDir) then Exit;

  // other
  path := FindDLLFile(fname);
  if FileExists(path) then
  begin
    Result := True;
    Exit;
  end;

  Result := False;
end;

// (セキュリティ対策)文字列を#0で埋めてから解放する
procedure HiResetString(var source:string);
var len: Integer;
begin
  len := Length(source);
  FillMemory(PChar(source), len, 0);
  source := '';
end;

// トークンを切り出す
function HimaGetWord(var p: PAnsiChar; var tokenJosi: AnsiString): AnsiString;

  procedure HimaGetToJosi; // 格助詞まで
  begin
    while p^ <> #0 do
    begin
      if p^ in LeadBytes then
      // ２バイト文字の処理
      begin
        if CharInRange(p, 'ぁ', 'ん') then
        begin // 助詞の可能性
          if Length(Result) >= 1 then // １文字目から助詞なんてことはありえない
          begin
            tokenJosi := HiSystem.JosiList.Find(p);
            if tokenJosi <> '' then Break;
          end;
          // 助詞ではなかった
          Result := Result + getOneChar(p);
          Continue;
        end;
        if CharInRange(p, 'ァ','') or (StrLComp(p,'ー',2)=0) then
        begin
          Result := Result + getOneChar(p);
          Continue;
        end else
          Break;
      end else
      // １バイト文字の処理
      begin
        if not(p^ in AlphabetChars2) then Exit;
        while p^ in AlphabetChars2 do
        begin
          Result := Result + p^;
          Inc(p);
        end;
      end;
    end;
  end;

  procedure HimaGetAlphabet;
  begin
    Result := p^; Inc(p);
    HimaGetToJosi;
  end;

var
  i, len: Integer;
const
  reigaiku:Array[0..7] of Ansistring = (
    'または','もし','違えば','違えばもし','かつ','また',
    'なでしこ','ひらがな'
  );
  matubiku:Array[0..2] of Ansistring = (
    '回','以上','以下'
  );
begin
  // アルファベット ('A'..'Z'|'a'..'z'|'_')+ ('A'..'Z'|'a'..'z'|'0'..'9'|'_')*
  // 漢字カタカナ   ('ァ'..|'ー')+ [$8340 .. $FCFC]
  // ひらがな       ('あ'..'ん','ー')+ [$82A0 .. $82F1]

  Result := ''; tokenJosi := '';

  //============================================================================
  // 特別な予約語句から始まっていればそこで必ず語句を区切る
  for i := 0 to High(reigaiku) do
  begin
    len := Length(reigaiku[i]);
    if StrLComp(p, PAnsiChar(reigaiku[i]), len) = 0 then
    begin
      Result := reigaiku[i]; Inc(p, len);
      tokenJosi := '';
      Exit;
    end;
  end;

  //============================================================================
  // アルファベットか？
  if (p^ in AlphabetChars1) then
  begin
    HimaGetAlphabet;
  end else
  // 漢字カタカナひらがなから始まる語は助詞まで切り取る
  if CharInRange(p, 'ぁ', '') then
  begin
    HimaGetToJosi;
  end else
  begin
  end;
  // 特別語句
  for i := 0 to High(matubiku) do
  begin
    len := Length(matubiku[i]);
    if
      (Length(Result) > len) and
      (Copy(Result, Length(Result) - len + 1, len) = matubiku[i]) then
    begin
      Dec(p, len);
      Dec(p, Length(tokenJosi));
      Result := Copy(Result, 1, Length(Result) - len);
      tokenJosi := '';
      Break;
    end;
  end;

  // これ以外は記号とみなす
  Exit;
end;

// 数字の切り出し
function HimaGetNumber(var p: PAnsiChar; var tokenJosuusi: AnsiString): Extended;
var
  res: AnsiString;

  procedure get16sin;
  begin
    res := res + p^; Inc(p);
    while p^ in ['0'..'9','A'..'F','a'..'f'] do
    begin
      res := res + p^;
      Inc(p);
    end;
    Result := StrToIntDefA(res,0);
  end;

  procedure get10sin;
  begin
    // 通常の形式
    // 123.456
    // 指数形式
    // 7.89E+08 7.89e-2

    // 整数部分
    while p^ in ['0'..'9'] do begin
      res := res + p^; Inc(p);
    end;
    // 小数点
    if (p^ <> '.') then
    begin
      if (p^ in ['e','E']) and ((p+1)^ in ['+','-']) and ((p+2)^ in ['0'..'9']) then
      begin
        res := res + p^ + (p+1)^ + (p+2)^;
        Inc(p,3);
        while p^ in ['0'..'9'] do
        begin
          res := res + p^;
          Inc(p);
        end;
        Result := StrToFloatA(res);
      end else
      begin
        Result := StrToFloatA(res);
      end;
      Exit;
    end;
    res := res + p^; Inc(p);
    // 小数点以下
    while p^ in ['0'..'9'] do begin
      res := res + p^; Inc(p);
    end;
    // 指数形式
    if (p^ in ['e','E']) and ((p+1)^ in ['+','-']) and ((p+2)^ in ['0'..'9']) then
    begin
      res := res + p^ + (p+1)^ + (p+2)^;
      Inc(p,3);
      while p^ in ['0'..'9'] do
      begin
        res := res + p^;
        Inc(p);
      end;
    end;

    Result := StrToFloatA(res);
  end;

  procedure getJosuusi;
  var
    i: Integer;
    s: AnsiString;
  begin
    //---------------------
    if (p^ in LeadBytes) or (p^ in ['A'..'Z','a'..'z']) then
    begin
      for i := Low(HimaJosuusi) to High(HimaJosuusi) do
      begin
        s := HimaJosuusi[i];
        if StrLComp(p, PAnsiChar(s), Length(s)) = 0 then
        begin
          tokenJosuusi := s;
          //Result := Result + s;
          Inc(p, Length(s));
          Break;
        end;
      end;
    end;
    //---------------------
  end;

begin
  res := ''; tokenJosuusi := ''; Result := 0;

  // マイナス表記？
  if (p^='-')and((p+1)^ in ['0'..'9','$']) then
  begin
    res := p^; Inc(p);
  end;

  // 16進法か？
  if p^ = '$' then get16sin else

  // 10進法か？
  if p^ in ['0'..'9'] then get10sin else Exit; // 数値以外

  // 単位（位取り）
  KuraidoriList.FindKurai(p, Result);

  // 助数詞
  getJosuusi;

end;

// 文字列の切り出し
function HimaGetString(var p: PAnsiChar; var lineNo: Integer): AnsiString;
var
  c: AnsiString;
begin
  Result := '';
  if p^ = '"' then
  begin
    Result := Result + p^;
    Inc(p); // skip '"'
    while not (p^ in [#0,'"']) do begin
      Result := Result + getOneChar(p);
    end;
    if p^ = '"' then begin Result := Result + p^; Inc(p); Exit; end;
  end else
  if p^ = '`' then
  begin
    Result := Result + p^;
    Inc(p); // skip '"'
    while not (p^ in [#0,'`']) do begin
      Result := Result + getOneChar(p);
    end;
    if p^ = '`' then begin Result := Result + p^; Inc(p); Exit; end;
  end else
  if (p^ + (p+1)^) = '「' then
  begin
    while p^ <> #0 do
    begin
      c := getOneChar(p);
      if (c = #13)or(c = #10) then
      begin
        if p^ = #10 then Inc(p);
        Result := Result + #13#10;
        Inc(lineNo);
        Continue;
      end else
      if c = '」' then
      begin
        Result := Result + c;
        Exit;
      end;
      Result := Result + c;
    end;
  end else
  if (p^ + (p+1)^) = '『' then
  begin
    while p^ <> #0 do
    begin
      c := getOneChar(p);
      if (c = #13)or(c = #10) then
      begin
        Result := Result + #13#10;
        if p^ = #10 then Inc(p);
        Inc(lineNo);
        Continue;
      end else
      if c = '』' then begin
        Result := Result + c;
        Exit;
      end;
      Result := Result + c;
    end;
  end;
end;


function HimaGetJosi(var p: PAnsiChar): AnsiString;
begin
  Result := '';
  if p^ = #0 then Exit;
  Result := HiSystem.JosiList.Find(p);
end;


{ THimaBlock }

procedure THimaBlock.Add(item: THimaToken);
begin
  inherited Add(item);

  if TopToken = nil then
  begin
    TopToken := item;
    CurToken := item;
  end else
  begin
    CurToken.NextToken := item;
    CurToken := item;
  end;
  CurToken.NextToken := nil;
end;

constructor THimaBlock.Create(Parent: THimaFile);
begin
  self.Parent := Parent;
  TopToken    := nil;
  NextBlock   := nil;
  CurToken    := nil;
end;


destructor THimaBlock.Destroy;
begin

  inherited;
end;

function THimaBlock.GetAsText(kugiri: AnsiString): AnsiString;
var
  i: Integer;
  token: THimaToken;
begin
  Result := '';
  for i := 0 to FCount - 1 do
  begin
    token := Tokens[i];
    Result := Result + token.GetAsText + token.Josi;
    if i <> (FCount-1) then Result := Result + kugiri;
  end;
end;


function THimaBlock.GetToken(Index: Integer): THimaToken;
begin
  Result := Items[Index];
end;


procedure THimaBlock.SetToken(Index: Integer; const Value: THimaToken);
begin
  Objects[Index] := Value;
end;

{ THimaFile }

procedure THimaFile.Add(item: THimaBlock);
begin
  inherited Add(item);
  
  if TopBlock = nil then
  begin
    TopBlock := item;
    CurBlock := item;
  end else
  begin
    CurBlock.NextBlock := item;
    CurBlock := item;
  end;
  CurBlock.NextBlock := nil;
end;

procedure THimaFile.Analize(var src: AnsiString);
var
  lineNo: Integer;
  indent: Integer;
  p, pNext: PAnsiChar;
  block: THimaBlock;
  token: THimaToken;
  s, tokenJosi: AnsiString;

  function countIndent: Integer;
  var tab: Integer;
  begin
    // インデントの数を検出
    Result := 0;
    // タブは4文字でカウント
    while p^ <> #0 do
    begin
      if p^ = ' ' then
      begin
        Inc(Result);
        Inc(p);
      end else
      if p^ = #9  then
      begin
        tab := 4-(Result mod 4);
        if tab = 0 then tab := 4;
        Inc(Result, tab);
        Inc(p);
        //|1...2...|
        //|___>    |
      end else
      begin
        Break;
      end;
    end;
  end;

  function newBlock(indent: Integer): THimaBlock;
  begin
    Result := THimaBlock.Create(self);
    Result.Indent := indent;
    Result.LineNo := lineNo;
    Self.Add(Result);
  end;

  function _chkContinueNextLine:Boolean;

    function chkWord(word: AnsiString): Boolean;
    var
      pp: PAnsiChar;
    begin
      Result := False;
      pp := p;
      Dec(pp, Length(word));
      if StrLComp(pp, PAnsiChar(word), Length(word)) = 0 then
      begin
        Result := True;
      end;
    end;

    function __checkCommaCRLF: Boolean;
    begin
      Result := False;
      if p^ <> ',' then Exit;
      pNext := p;
      Inc(pNext);
      while pNext^ in [#9, ' '] do Inc(pNext);
      if (StrLComp(pNext, #13#10, 2) = 0) then
      begin
        Inc(pNext, 2);
        Result := True;
      end;
    end;

  begin
    Result := False;
    //if StrLComp(p,','#13#10, 3) = 0 then
    if __checkCommaCRLF then
    begin
      // 例外をチェック
      Result := True;
      if
        chkWord('もし') or
        chkWord('ならば') or chkWord('なら') or
        chkWord('違えば') or chkWord('違') or
        chkWord('せやなかったら') or chkWord('ちごたら') or
        chkWord('でなければ') or
        chkWord('間') or
        chkWord('ループ')   or
        chkWord('回')  or
        chkWord('反復')  or
        chkWord('繰り返す')  or
        chkWord('繰返し')  or
        chkWord('繰り返し')  or
        chkWord('繰返')  or
        chkWord('エラー監視')  or
        chkWord('エラー')  or
        chkWord('条件分岐')  or
        chkWord('ここから')
      then
      begin
        Inc(p);
        Exit;
      end;
      p := pNext;
      Result := True;
    end;
  end;

begin
  //todo 4: ソースをトークンに切る
  p := PAnsiChar(src);
  lineNo := 1; // 1 からはじめる

  // 一番初めのブロックを作る
  indent := countIndent;
  block  := newBlock(indent);

  while p^ <> #0 do
  begin
    // (1) 改行か
    if StrLComp(p, #13#10, 2) = 0 then
    begin
      Inc(p, 2); Inc(lineNo); // skip #13#10
      indent := countIndent;
      if p^ = #13 then Continue; // 空行なら次のインデントを数える
      // もし現在のブロックが空なら、新規作成しない
      if block.Count <> 0 then block := newBlock(indent)
                          else block.Indent := indent;
      block.LineNo := lineNo;
      Continue;
    end;
    // (2) 次の行へ続くか
    // 新ルール：ならば、違えば、回、反復の後は無視する
    if _chkContinueNextLine then
    // old rule => if StrLComp(p,','#13#10, 3) = 0 then
    begin
      Continue;
    end;
    // 文の区切れ - ブロックを変える
    if p^ = ';' then
    begin
      {
      Inc(p);
      block := newBlock(indent);
      block.LineNo := lineNo;
      }
      // ブロックを変えずに、記号を登録する
      token := THimaToken.Create(block); block.Add(token);
      token.Token := p^; Inc(p);
      token.TokenType := tokenMark;
      token.TokenID := token_Semicolon;
      Continue;
    end;

    // カッコ(はじまり)か？
    if p^ in ['(','{','['] then
    begin
      token := THimaToken.Create(block); block.Add(token);
      token.TokenID := HiSystem.TangoList.GetID(p^);
      token.Token := p^; Inc(p);
      // ！！カッコはじめには助詞はつかないはず！！　... 関数(はい) で、「は」を助詞とみなさないこと！
      // token.Josi := HimaGetJosi(p);
      // token.JosiID := HiSYstem.JosiList.GetID(token.Josi);
      token.TokenType := tokenParenthesis;
      Continue;
    end else
    // カッコ(閉じ)か？
    if p^ in [')','}',']'] then
    begin
      token := THimaToken.Create(block); block.Add(token);
      token.TokenID := HiSystem.TangoList.GetID(p^);
      token.Token := p^; Inc(p);
      token.Josi := HimaGetJosi(p); // もしあれば
      token.JosiID := HiSYstem.JosiList.GetID(token.Josi);
      token.TokenType := tokenParenthesis;
      Continue;
    end;
    // 演算子か
    if p^ in EnzansiChar1 then
    begin
      s := p^; Inc(p);
      if p^ in EnzansiChar2 then
      begin
        s := s + p^; Inc(p);
      end;
      //for DEBUG
      // Writeln(HiSystem.TangoList.EnumKeys); Readln;

      token := THimaToken.Create(block); block.Add(token);
      token.Token := s;
      token.TokenType := tokenOperator;
      token.TokenID := HiSystem.TangoList.GetID(s);

      Continue;
    end;
    // マークか？
    if p^ in HimaMark then
    begin
      token := THimaToken.Create(block); block.Add(token);
      token.Token := p^;
      token.TokenID := HiSystem.TangoList.GetID(token.Token);
      token.TokenType := tokenMark;
      Inc(p);
      Continue;
    end;
    // 数値か？
    if (p^ in NumberChars1) then
    begin
      token := THimaToken.Create(block); block.Add(token);
      token.NumberToken := HimaGetNumber(p, s);
      //token.Josuusi := s;
      skipSpace(p); // (ex)"-1 ならば"と書くことがあるので助詞チェックの前にスペースを進める
      token.Josi  := HimaGetJosi(p); // もしあれば
      token.TokenType := tokenNumber;
      token.TokenID := 0;
      token.JosiID := HiSystem.JosiList.GetID(token.Josi);
      Continue;
    end else
    // 文字列「」『』"" `` か?
    if (p^ = '`')or(p^ = '"')or(StrLComp(p,'「',2) = 0)or(StrLComp(p,'『',2) = 0) then
    begin
      token := THimaToken.Create(block); block.Add(token);
      token.Token := HimaGetString(p,lineNo);
      token.Josi  := HimaGetJosi(p);
      token.TokenType := tokenString;
      token.TokenID := 0;
      token.JosiID  := HiSystem.JosiList.GetID(token.Josi);
      Continue;
    end;
    // 区切り記号かスペース
    if p^ in [' ', #9] then // ',' はマークにした
    begin
      while p^ in [' ',#9] do Inc(p);
      Continue;
    end;
    // 一般トークンを切り出す
    s := HimaGetWord(p, tokenJosi);
    if s <> '' then
    begin
      if (p <> nil) and (p^ = '.') then Inc(p); // "(単語)." なら skip
      token := THimaToken.Create(block); block.Add(token);
      token.Token := DeleteGobi(s); // 初めから単語の語尾を省略して登録
      token.TokenID := HiSystem.TangoList.GetID(token.Token);
      token.Josi  := tokenJosi;
      token.JosiID := HiSystem.JosiList.GetID(token.Josi);
      token.TokenType := tokenTango;
      // 文字列演算子チェック
      if token.TokenID = token_katu then
      begin
        token.Token     := '&&';
        token.TokenID   := token_and;
        token.TokenType := tokenOperator;
      end else
      if token.TokenID = token_matawa then
      begin
        token.Token     := '||';
        token.TokenID   := token_or;
        token.TokenType := tokenOperator;
      end else
      ;
      Continue;
    end;
    // 解析不明な記号
    s := getOneChar(p);
    if PosA(s, '■・←→▲') > 0 then
    begin
      token := THimaToken.Create(block); block.Add(token);
      token.Token := s;
      token.TokenID := HiSystem.TangoList.GetID(s);
      token.TokenType := tokenMark;
      Continue;
    end;
    raise EHimaSyntax.Create(
            FileNo,
            lineNo,
            ERR_S_SOURCE_DUST+'(文字コード='+IntToStrA(Ord(p^))+')', [s]);
  end;

  if block.Count = 0 then // 最後の余分なブロックを削除
  begin
    Self.Delete(Self.Count - 1);
    if Self.Count > 0 then
    begin
      block := Self.Items[ Self.Count - 1 ];
      if block <> nil then block.NextBlock := nil;
    end;
  end;
end;

constructor THimaFile.Create(Parent: THimaFiles; Fileno: Integer);
begin
  self.Parent := Parent;
  self.Fileno := Fileno;
  Path := '';
  TopBlock := nil;
  CurBlock := nil;
end;


function THimaFile.GetAsText: AnsiString;
var
  i,j: Integer;
  block: THimaBlock;
begin
  Result := '';
  for i := 0 to FCount - 1 do
  begin
    block := Items[i];
    // lineNo
    Result := Result + IntToStrA(block.LineNo) + ':';
    // indent
    for j := 1 to block.Indent do Result := Result + ' ';
    // text
    Result := Result + block.GetAsText(' ') + #13#10;
  end;
end;




procedure THimaFile.LoadFromFile(Filename: string);
var
  src, srcC: AnsiString;
  fname, path: string;

begin
  // パスとファイル名を分解
  path := ExtractFilePath(Filename);
  fname := ExtractFileName(Filename);

  // 名前とファイル番号を設定
  Self.Filename := fname;
  Self.Fileno   := setSourceFileName(fname);

  // ファイル名を検索
  if (unit_pack_files.FileMixReader = nil) or
     (not unit_pack_files.FileMixReader.ReadFileAsString(string(fname), src)) then
  begin
    //--------------------------------------------------------------------------
    // ローカルをチェック
    if HiFindFile(Filename) = False then
    begin
      raise Exception.Create('ファイルが読み込めません。『'+fname+'』');
    end;
    // ソースのロード
    src := FileLoadAll(Filename);
    Self.Path := ExtractFilePath(Filename);
    //--------------------------------------------------------------------------
  end;

  // 一時解析
  srcC := HimaSourceConverter(FileNo, src);
  try
    HiResetString(src);
    Analize(srcC);
    HiResetString(srcC);
  except on e: Exception do
    raise Exception.Create('トークンの解析中にエラー。'+e.Message);
  end;
end;

procedure THimaFile.SetSource(src: AnsiString);
var r: String;
begin
  r := HimaSourceConverter(-1, src);
  Self.Filename := '';
  Self.Fileno := -1;
  HiResetString(src);
  Analize(r);
  HiResetString(r);
end;

function THimaFile.TopToken: THimaToken;
begin
  Result := nil;
  // 一番初めのトークンを得る
  if Self.Count = 0 then Exit;
  Result := TopBlock.TopToken;
end;

{ THimaFiles }

function THimaFiles.FindFile(Filename: string): THimaFile;
var
  i: Integer;
  h: THimaFile;

  function fp(s: string): string;
  begin
    s := ExtractFileName(s);
    s := getToken_s(s, '.'); // 拡張子の前だけが有効
    s := UpperCase(s);
    Result := s;
  end;

begin
  Result := nil;
  for i := 0 to FCount - 1 do
  begin
    h := Items[i];
    if fp(h.Filename) = fp(Filename) then
    begin
      Result := h;
      Break;
    end;
  end;
end;

function THimaFiles.FindFileNo(no: Integer): THimaFile;
var
  i: Integer;
  h: THimaFile;
begin
  Result := nil;
  for i := 0 to FCount - 1 do
  begin
    h := Items[i];
    if no = h.Fileno then
    begin
      Result := h;
      Break;
    end;
  end;
end;

function THimaFiles.LoadAndAdd(Filename: string):THimaFile;
var
  himaFile: THimaFile;
begin
  Result := FindFile(Filename);

  if nil = Result then
  begin
    himaFile := THimaFile.Create(self, FCount);
    himaFile.LoadFromFile(Filename);
    Result := himaFile;
    self.Add(Result);
  end;
end;

function THimaFiles.LoadSourceAdd(SourceText: AnsiString; Filename: string): THimaFile;
var
  himaFile: THimaFile;
  src: AnsiString;
begin
  himaFile := THimaFile.Create(self, FCount);
  himaFile.Filename := Filename;
  himaFile.Fileno   := setSourceFileName(Filename);

  // 一時解析
  src := HimaSourceConverter(himaFile.FileNo, SourceText);
  himaFile.Analize(src);

  Result := himaFile;
  self.Add(Result);
end;

{ THimaToken }

function THimaToken.CheckNextBlock: THimaToken;
var
  b: THimaBlock;
begin
  Result := nil;
  b := Self.Parent;
  b := b.NextBlock; // 次のブロック
  if b = nil then Exit;
  Result := b.TopToken;
end;

constructor THimaToken.Create(Parent: THimaBlock);
begin
  self.Parent  := Parent;
  self.Token   := '';
  self.Josi    := '';
  self.JosiID  := -1;
  Self.TokenID := 0;
  NextToken    := nil;
end;


function THimaToken.DebugInfo: TDebugInfo;
begin
  Result.FileNo := FileNo;
  Result.LineNo := LineNo;
end;

function THimaToken.FileNo: Integer;
begin
  Result := Self.Parent.Parent.Fileno;
end;

{
function THimaToken.GetConstNum: Extended;
begin
  Result := HimaStrToNum(token);
end;
}

function THimaToken.GetAsText: AnsiString;
begin
  if Self.TokenType = tokenNumber then
  begin
    Result := FloatToStrA(Self.NumberToken);
  end else
  begin
    Result := Self.Token;
  end;
end;

function THimaToken.GetConstPtr: Pointer;
begin
  if token = 'NULL' then
    Result := nil
  else
    raise EHimaSyntax.Create(Self.FileNo, Self.LineNo, 'NULL', []);
end;

function THimaToken.GetConstStr: AnsiString;
begin
  if (Copy(token,1,1) = '"') and (Copy(token,Length(token),1) = '"') then
  begin
    // "12345"
    Result := Copy(token, 2, Length(token) - 2);
  end else
  if (Copy(token,1,2) = '「') and (Copy(token,Length(token)-1,2) = '」') then
  begin
    Result := Copy(token, 3, Length(token) - 4);
  end else
  if (Copy(token,1,2) = '『') and (Copy(token,Length(token)-1,2) = '』') then
  begin
    Result := Copy(token, 3, Length(token) - 4);
  end else
  if (Copy(token,1,1) = '｢') and (Copy(token,Length(token),1) = '｣') then
  begin
    Result := Copy(token, 2, Length(token) - 2);
  end else
  if (Copy(token,1,1) = '`') and (Copy(token,Length(token),1) = '`') then
  begin
    Result := Copy(token, 2, Length(token) - 2);
  end else
  begin
    Result := token;
  end;
end;

function THimaToken.Indent: Integer;
begin
  Result := Self.Parent.Indent;
end;

function THimaToken.LineNo: Integer;
begin
  Result := Self.Parent.LineNo;
end;

function THimaToken.UCToken: AnsiString;
begin
  Result := UpperCaseEx(token);
end;

{ THimaTangoList }

constructor THimaTangoList.Create;
begin
  FLastID := 100000 {99xxx}; // 適当な最小値
  inherited;
end;

function THimaTangoList.GetID(key: AnsiString; DefaultID: Integer): Integer;
var
  tango: THimaTango;
begin
  // 単語IDを調べる
  tango := GetTango(key);

  // もし登録されてない単語だったら...
  if tango = nil then
  begin
    tango := THimaTango.Create;
    tango.Key := key;

    if DefaultID <= 0 then
    begin
      tango.ID  := FLastID;
      Inc(FLastID);
    end else
    begin
      tango.ID := DefaultID;
    end;

    SetTango(key, tango);
  end;

  //
  Result := tango.ID;
end;

function THimaTangoList.FindKey(id: Integer): AnsiString;
begin
  FFindKey := '';
  FFindID  := id;
  Each(subFindKey);
  Result := FFindKey;
end;

function THimaTangoList.GetTango(key: AnsiString): THimaTango;
begin
  Result := THimaTango(Items[key]);
end;

procedure THimaTangoList.SetID(key: AnsiString; Value: Integer);
var
  g: THimaTango;
begin
  key := DeleteGobi(key);
  g := GetTango(key);
  if g = nil then
  begin
    g := THimaTango.Create;
    g.Key := key;
    g.ID := Value;
    Add(g);
  end else
  begin
    g.ID := Value; // 上書き
  end;
end;

procedure THimaTangoList.SetTango(key: AnsiString; const Value: THimaTango);
begin
  Items[key] := Value;
end;


function THimaTangoList.subFindKey(item: THHashItem): Boolean;
var
  p: THimaTango;
begin
  p := item as THimaTango;
  if (p.ID = FFindID) then
  begin
    Result := False; // break
    FFindKey := p.Key;
  end else
  begin
    Result := True; // continue
  end;
end;

function THimaTangoList.EnumKeys: AnsiString;
begin
  FFindKey := '';
  Each(subEnumKeys);
  Result := FFindKey;
end;

function THimaTangoList.subEnumKeys(item: THHashItem): Boolean;
var
  p: THimaTango;
begin
  p := THimaTango(item);
  FFindKey := FFindKey + IntToStrA(p.ID) + ':' + item.Key + #13#10;
  Result := True;
end;

{ THimaJosiList }

function THimaJosiList.AddID(key: AnsiString): Integer;
begin
  Result := GetID(key);
  if Result < 0 then
  begin
    Result := FLastID;
    SetID(key, FLastID);
    Inc(FLastID);
  end;
end;

constructor THimaJosiList.Create;
begin
  inherited;
  FLastID := 1000;
end;

destructor THimaJosiList.Destroy;
begin
  Clear;
  inherited;
end;

function THimaJosiList.EnumKeys: AnsiString;
var
  i: Integer;
  w: THimaTango;
begin
  Result := '';
  for i := 0 to Count - 1 do
  begin
    w := Items[i];
    Result := Result + w.Key + #13#10;
  end;
  Result := TrimA(Result);
end;

function THimaJosiList.Find(var p: PAnsiChar): AnsiString;
var
  i: Integer;
  w: THimaTango;
begin
  Result := '';
  for i := 0 to Count - 1 do
  begin
    w := Items[i];
    if StrLComp(p, PAnsiChar(w.Key), Length(w.Key)) = 0 then
    begin
      Result := w.Key;
      Inc(p, Length(w.Key));
      Break;  
    end;
  end;
end;

function THimaJosiList.GetID(key: AnsiString): Integer;
var
  i: Integer;
  p: THimaTango;
begin
  Result := -1; if key = '' then Exit;
  for i := 0 to Count - 1 do
  begin
    p := Items[i];
    if p.Key = key then
    begin
      Result := p.ID; Break;
    end;
  end;
end;

function THimaJosiList.ID2Str(id: WORD): AnsiString;
var
  i: Integer;
  p: THimaTango;
begin
  Result := '';
  for i := 0 to Count - 1 do
  begin
    p := Items[i];
    if p.ID = id then
    begin
      Result := p.Key;
      Break;
    end;
  end;
end;

procedure THimaJosiList.SetID(key: AnsiString; Value: Integer);
var
  i: Integer;
  p: THimaTango;
begin
  i := GetID(key);
  if i < 0 then
  begin
    p     := THimaTango.Create;
    p.ID  := Value;
    p.Key := key;
    Add(p);
  end else
  begin
    p    := Items[i];
    p.ID := Value;
  end;
end;

function comp_by_len(A, B: Pointer): Integer; // A>B なら0以上
var
  ta, tb: THimaTango;
begin
  ta := THimaTango(A);
  tb := THimaTango(B);
  Result := Length(tb.Key) - Length(ta.Key);
end;

procedure THimaJosiList.SortByLen;
begin
  MergeSort(comp_by_len);
end;

{ THiKuraidori }

constructor THiKuraidori.Create(akurai: AnsiString; abai: Extended);
begin
  kurai := akurai;
  bai   := abai;
end;

function THiKuraidori.Comp(var p: PAnsiChar): Boolean;
begin
  if StrLComp(p, PAnsiChar(kurai), Length(kurai)) = 0 then
  begin
    Result := True;
    Inc(p, Length(kurai));
  end else
  begin
    Result := False;
  end;
end;

{ THiKuraidoriList }

function THiKuraidoriList.FindKurai(var p: PAnsiChar;
  var num: Extended): Boolean;
var
  i: Integer;
  k: THiKuraidori;
begin
  Result := False;
  for i := 0 to Count - 1 do
  begin
    k := Items[i];
    if k.Comp(p) then
    begin
      Result := True;
      num := num * k.bai;
      Break;
    end;
  end;
  // 単位の組み合わせに対応する
  if Result then
  begin
    FindKurai(p, num);
  end;
end;

procedure setKuraidoriList;

  procedure _add(name: AnsiString; bai: Extended);
  begin
    KuraidoriList.Add(THiKuraidori.Create(name, bai));
  end;

begin
  //<SI単位系>
  _add('十',10);
  _add('_D',10);
  _add('百',100);
  _add('_h',100);
  _add('千',1000);
  _add('_k',1000);
  _add('万',10000);
  _add('_M' ,1000000);
  _add('億',100000000);
  _add('_B' ,1);
  _add('KB',1024);
  _add('MB',1024*1024); // = 1024KB
  _add('GB',1024*1024*1024); // = 1024MB = 1024^3

  _add('割',0.1);
  _add('_d',0.1);
  _add('分',0.01);
  _add('_c',0.01);
  _add('厘',0.001);
  _add('_m',0.001);
  _add('μ',0.000001);
  //</SI単位系>
end;

procedure setTokenList(sys: TObject);
begin

  //todo 1: 予約語の登録
  with THiSystem(sys).TangoList do
  begin
    SetID('(', token_kakko_begin);
    SetID(')', token_kakko_end);
    SetID('[', token_kaku_kakko_begin);
    SetID(']', token_kaku_kakko_end);
    SetID('{', token_nami_kakko_begin);
    SetID('}', token_nami_kakko_end);

    SetID('+', token_plus);
    SetID('-', token_minus);
    SetID('*', token_mul);
    SetID('/', token_div);
    SetID('%', token_mod);
    SetID('=', token_Eq);
    SetID('==', token_Eq);
    SetID('<>', token_NotEq);
    SetID('!=', token_NotEq);
    SetID('>',  token_Gt);
    SetID('>=', token_GtEq);
    SetID('<',  token_Lt);
    SetID('<=', token_LtEq);
    SetID('<<', token_ShiftL);
    SetID('>>', token_ShiftR);
    SetID('~', token_tilde);
    SetID('^', token_power);
    SetID('|', token_vLine);
    SetID(':', token_Colon);
    SetID(';', token_Semicolon);
    SetID('?', token_question);

    SetID('&',  token_plus_str);
    SetID('&&', token_and);
    SetID('||', token_or);
    SetID('かつ',   token_katu);
    SetID('または', token_matawa);
    SetID('また',   token_matawa);

    SetID('!', token_mark_option);
    SetID('@', token_mark_at);
    SetID('■', token_mark_sikaku);
    SetID('・', token_mark_nakaten);
    SetID(',',  token_comma);
    SetID('\',  token_yen);
    SetID('▲', token_mark_sankaku);

    SetID('もし', token_mosi);
    SetID('ならば', token_naraba);
    SetID('なら',   token_naraba);
    SetID('違', token_tagaeba);
    SetID('せやなかったら', token_tagaeba);
    SetID('ちごたら', token_tagaeba);
    SetID('でなければ', token_tagaeba);
    SetID('間',         token_aida);
    SetID('ループ',     token_loop);
    SetID('回',         token_kai);
    SetID('反復',       token_hanpuku);
    SetID('繰り返',     token_kurikaesu);
    SetID('繰返',       token_kurikaesu);
    SetID('エラー監視', token_err_kansi);
    SetID('エラー',     token_err);
    SetID('条件分岐',   token_joukenbunki);
    SetID('ここ',       token_koko);

    SetID('文字列',   token_mojiretu);
    SetID('数値',     token_suuti);
    SetID('整数',     token_seisu);
    SetID('変数',     token_hensuu);
    SetID('配列',     token_hairetu);
    SetID('実数',     token_jissuu);
    SetID('グループ', token_group);
    SetID('ハッシュ', token_hash);
    SetID('値渡'  ,   token_ByVal);
    SetID('参照渡',   token_ByRef);
    SetID('変数宣言', token_hensuu_sengen);
    SetID('変数初期化', token_hensuu_syokika);
    SetID('必要',     token_hituyou);
    SetID('不要',     token_huyou);
    SetID('作',       token_tukuru);
    SetID('壊',       token_kowasu);
    SetID('非公開',     token_private);
    SetID('イベント',   token_event);
    SetID('名前',       token_name);
    SetID('取込',     token_include);
    SetID('デフォルト', token_default);
    SetID('ネームスペース変更',token_namespace_henkou);
    SetID('回数', token_kaisu);
    SetID('エラーメッセージ', token_errMsg);
    SetID('対象', token_taisyou);
    SetID('システム',     token_system);
    SetID('ユーザー',     token_user);


    SetID('←', token_left);
    SetID('→', token_right);

    SetID('代入', token_dainyu);

    SetID('それ', token_sore);
    SetID('S',    token_s);
    SetID('V',    token_v);
    SetID('CNT',  token_cnt);
    SetID('A',    token_a);
    SetID('B',    token_b);
    SetID('C',    token_c);
    SetID('F',    token_f);
    SetID('X',    token_x);
    SetID('Y',    token_y);
    SetID('そ',   token_sono);
    SetID('自身', token_jisin);
    SetID('これ', token_kore); // そ = これ

    //Writeln(EnumKeys);
    //ReadLn;
  end;

end;

procedure setJosiList(sys: TObject);
begin
  //todo 1:助詞の登録
  with THiSystem(sys).JosiList do
  begin
    //<助詞の登録>
    //構文として意味のある助詞
    SetID('とは', josi_towa);
    SetID('は',         josi_wa);

    SetID('について',   josi_nituite);

    SetID('やったら',   josi_naraba);
    SetID('ならば',     josi_naraba);
    SetID('なら',       josi_naraba);
    SetID('でなければ', josi_denakereba);

    // 命令の引数として、推奨する助詞
    SetID('から', josi_kara);
    SetID('まで', josi_made);
    SetID('までを',josi_madewo);
    AddID('までの');
    SetID('で', josi_de);
    SetID('を', josi_wo);
    SetID('の', josi_no);
    SetID('が', josi_ga);
    SetID('に', josi_ni);
    SetID('へ', josi_he);
    AddID('と');

    // 日本語らしくみせるための補助助詞
    AddID('して');
    AddID('だけ');
    AddID('くらい');
    AddID('なのか');
    AddID('として');
    AddID('より');
    AddID('ほど');
    AddID('など');

    // 以下、2004/11/07 に追加したもの
    AddID('って');
    AddID('では');

    // 以下、2005/01/26 に追加したもの
    SetID('て', josi_te);
    //</助詞の登録>

    SortByLen; // 必要
  end;

end;


initialization
  // 位取り ... このリストは不変
  KuraidoriList := THiKuraidoriList.Create;
  setKuraidoriList;

finalization
  FreeAndNil(KuraidoriList);

end.
