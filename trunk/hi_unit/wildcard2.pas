unit wildcard2;
{-------------------------------------------------------------------------------

●●●　VB上位互換のワイルドカード　●●●

================================================================================
【製作】http://nadesi.com
================================================================================
"*"      : 任意の0文字以上の文字列
"?"      : 任意の1文字
"#"      : 任意の数字1文字
"[str]"    : str に指定したいずれかの１字列
"[!str]"   : str に指定した以外のいずれかの１文字
"[*str]"   : str に指定したいずれかの文字の0文字以上の連続
"[+str]"   : str に指定したいずれかの文字の1文字以上の連続
"[=s1|s2]" : s1 か s2 のいずれかの文字列
"[*!str]"  : str に指定した以外の文字の0文字以上の連続
"[+!str]"  : str に指定した以外の文字の1文字以上の連続
"(str)"    : カッコ中にマッチしたパターンを抜き出す
"\"        : シーケンス記号(\nで改行/\tでタブ/\*で*/\?で?)
================================================================================
*** MATCH ***
================================================================================
Filename      pattern         IsMatch pickup        説明
------------- --------------- ------- ------------- ----------------------------
abc.txt       *.txt           True
abc.txt       abc.*           True
abc-def-ghi   ???-???-???     True                  任意の文字の組み合わせ
090-0123-4567 ###-####-####   True                  任意の数字の組み合わせ
abc.txt       (*).txt         True    abc           カッコ中にマッチした部分
123-4567      (*)-(*)         True    123\n4567     カッコ中にマッチした部分
abc           [a-z]bc         True                  aからzのいずれかの１文字部分
abc           [+a-z]          True                  aからzの１文字以上の連続
abc           [*a-z]          True                  aからzの０文字以上の連続
123abc        [*0-9][*a-z]    True
123           [*a-z]123       True
123           [+a-z]123       False
abc.txt       [=abc|cde].txt  True                  abcかcdeのどれか
abc.txt       [*!.].txt       True                  "."以外の連続
ひらがな.txt  [*あ-ん].txt    True                  "あ"から"ん"の0文字以上の連続
================================================================================

*** REPLACE ***
ワイルドカードを用いた置換
※FindStr にカッコを使うと、NewStr の $1,$2,$3... をカッコで置き換えができる
================================================================================
Source        FindStr         NewStr                結果
------------- --------------- --------------------- ----------------------------
abc.txt       *.              @                      @txt
abc.txt       .*              @                      abc@
a[1]b[2]      [(*)]           ($1)                   a(1)b(2)
a:aaa,b:bbb   (*):[*!,]       $1                     a,b
================================================================================

-------------------------------------------------------------------------------}

interface

uses
  Windows, SysUtils, Classes;

type
  TKWPattern = class;

  TKWSeq = class
  public
    function IsMatch(var p: PAnsiChar): Boolean; virtual; abstract;
    function IsTopMatch(var p: PAnsiChar): Boolean; virtual; abstract;
  end;

  TKWArray = array of TKWSeq;

  TKWChar = class(TKWSeq)
  public
    Data: AnsiString;
    constructor Create(ch: AnsiString);
    function IsMatch(var p: PAnsiChar): Boolean; override;
    function IsTopMatch(var p: PAnsiChar): Boolean; override;
  end;

  TKWAsterisk = class(TKWSeq)
  public
    Parent: TKWPattern;
    constructor Create(AParent: TKWPattern);
    function IsMatch(var p: PAnsiChar): Boolean; override;
    function IsTopMatch(var p: PAnsiChar): Boolean; override;
  end;

  TKWQuestion = class(TKWSeq)
  public
    function IsMatch(var p: PAnsiChar): Boolean; override;
    function IsTopMatch(var p: PAnsiChar): Boolean; override;
  end;

  TKWSharp = class(TKWSeq)
  public
    function IsMatch(var p: PAnsiChar): Boolean; override;
    function IsTopMatch(var p: PAnsiChar): Boolean; override;
  end;

  TKWSelectPattern = (patOne, patPlus, patAsterisk, patWord);

  TKWSelect = class(TKWSeq)
  public
    Parent: TKWPattern;
    Sets: TStringList;
    Pattern: TKWSelectPattern;
    IsNot: Boolean;
    constructor Create(AParent: TKWPattern; var p: PAnsiChar); overload;
    constructor Create(AParent: TKWPattern; s: AnsiString); overload;
    destructor Destroy; override;
    function IsMatch(var p: PAnsiChar): Boolean; override;
    function IsTopMatch(var p: PAnsiChar): Boolean; override;
  end;

  TKWKakkoFrom = class(TKWSeq)
  public
    Parent: TKWPattern;
    constructor Create(AParent: TKWPattern);
    function IsMatch(var p: PAnsiChar): Boolean; override;
    function IsTopMatch(var p: PAnsiChar): Boolean; override;
  end;

  TKWKakkoTo = class(TKWSeq)
  public
    Parent: TKWPattern;
    constructor Create(AParent: TKWPattern);
    function IsMatch(var p: PAnsiChar): Boolean; override;
    function IsTopMatch(var p: PAnsiChar): Boolean; override;
  end;

  TKWString = class
  private
    FData: TKWArray;
    function GetCount: Integer;
    function GetCharAt(Index: Integer): TKWSeq;
    procedure SetCharAt(Index: Integer; const Value: TKWSeq);
  public
    destructor Destroy; override;
    procedure Clear; virtual;
    property Count: Integer read GetCount;
    property CharAt[Index:Integer]: TKWSeq read GetCharAt write SetCharAt;
  end;

  TKWPattern = class(TKWString)
  protected
    function IsMatchPAnsiChar(var p: PAnsiChar): Boolean;    // 完全にマッチ
    function IsTopMatchPAnsiChar(var p: PAnsiChar): Boolean; // 先頭にマッチ
  public
    Index: Integer;
    Pickup: TStringList;
    PickupBegin: PAnsiChar;
    constructor Create(str: AnsiString);
    destructor Destroy; override;
    procedure SetPattern(str: AnsiString); // パターン文字列の再設定
    procedure MoveNext;
    function HasNext: Boolean;
    function Cur: TKWSeq;
    function IsMatch(s: AnsiString): Boolean;            // 完全にマッチ
    function IsTopMatch(var s: AnsiString): Boolean;     // 先頭マッチ
    function Replace(Src, NewStr: AnsiString; ReplaceAll: Boolean): AnsiString; // 検索パターンは Create の時にセットする
    function Split(Src: AnsiString): TStringList;
    function SubMatch(Src: AnsiString): AnsiString; // 部分的にマッチした部分を抽出
    function getToken(var Src: AnsiString): AnsiString; // マッチした部分までを切り取る
  end;

function getOneChar(var p: PAnsiChar): AnsiString;overload;
function getOneChar(var p: PAnsiChar;const p_last:PAnsiChar): AnsiString;overload;

function JReplace(str, sFind, sNew: AnsiString): AnsiString;
function MatchesMask(const Filename, Mask: AnsiString): Boolean;
function IsMatch(const str, pattern: AnsiString; var pickup: TStringList): Boolean; overload;
function IsMatch(const str, pattern: AnsiString): Boolean; overload;
function IsTopMatch(var str: AnsiString; pattern: AnsiString; var pickup: TStringList): Boolean;
function WildReplace(Src, FindStr, NewStr: AnsiString; ReplaceAll: Boolean): AnsiString;
function WildSplit(Src, FindStr: AnsiString): TStringList;
function WildSubMatch(const str, pattern: AnsiString; var pickup: TStringList): AnsiString;
function WildGetToken(var Src: AnsiString; splitter: AnsiString; var pickup: TStringList): AnsiString;

procedure TestAll;
procedure TestWildcard1;
procedure TestWildcard2;
procedure TestWildcard3;
procedure TestReplace;

implementation

uses
  unit_string;

procedure TestAll;
begin
  TestWildcard1;
  TestWildcard2;
  TestWildcard3;
  TestReplace;
end;

procedure TestReplace;
begin
  Assert(WildReplace('abc.txt', 'a*c', '-', True)='-.txt');
  Assert(WildReplace('abc.txt', '*.', '.', True)='.txt');
  Assert(WildReplace('abc.txt', '.*', '-', True)='abc-');
  Assert(WildReplace('a(1)b(2)', '\((*)\)', '[$1]', True)='a[1]b[2]');
  Assert(WildReplace('a:aaa,b:bbb', '(*):[*!,]', '$1', True)='a,b');
end;

procedure TestWildcard1;
begin
  // *
  Assert( MatchesMask('abc.txt', '*.txt') = True);
  Assert( MatchesMask('abc.txt', '*d.txt') = False);
  Assert( MatchesMask('abc.txt', 'a*c.txt') = True);
  Assert( MatchesMask('abc.txt', 'ab*.txt') = True);
  Assert( MatchesMask('abc.txt', 'b*.txt') = False);
  Assert( MatchesMask('abc.txt', 'abc.*') = True);
  Assert( MatchesMask('abc.txt', 'abc*txt') = True);
  Assert( MatchesMask('abc.txt', 'a*c.t*t') = True);
  Assert( MatchesMask('abc.txt', 'a*c.tx') = False);
  Assert( MatchesMask('a - b', 'a*b') = True);
  Assert( MatchesMask('a****t', 'a*t') = True);
  Assert( MatchesMask('abc.txt', '*.*') = True);
  Assert( MatchesMask('abc', '*.*') = False);
  Assert( MatchesMask('abc.txt', '*abc.txt*') = True);
  // ?
  Assert( MatchesMask('abc.txt', '???.txt') = True);
  Assert( MatchesMask('abc.txt', 'abc.???') = True);
  Assert( MatchesMask('abc.txt', '*.???') = True);
  Assert( MatchesMask('abc.txt', 'a??.*') = True);
  Assert( MatchesMask('abc.txt', '?abc.txt') = False);
  // #
  Assert( MatchesMask('012-345-6789', '###-###-####') = True);
  Assert( MatchesMask('012-345-6789', '###?###?####') = True);
  Assert( MatchesMask('01a-345-6789', '###-###-####') = False);
  Assert( MatchesMask('012-a45-6789', '###-###-####') = False);
end;

procedure TestWildcard2;
var
  pickup: TStringList;
begin
  pickup := nil;
  Assert(IsMatch('abc.txt-notepad','(abc).(*)-(*)',pickup));
  Assert(Trim(pickup.Text) = 'abc'#13#10'txt'#13#10'notepad');

  FreeAndNil(pickup);
  Assert(IsMatch('123-456-789','(*)-(*)-(*)',pickup));
  Assert(Trim(pickup.Text) = '123'#13#10'456'#13#10'789');

  FreeAndNil(pickup);
  Assert(IsMatch('11:22:33','(*)[:.](*)[:.](*)',pickup));
  Assert(Trim(pickup.Text) = '11'#13#10'22'#13#10'33');

  FreeAndNil(pickup);
  Assert(IsMatch('11時22分33秒','(*)[:時](*)[:分](*)[秒.]',pickup));
  Assert(Trim(pickup.Text) = '11'#13#10'22'#13#10'33');

  FreeAndNil(pickup);
  Assert(IsMatch('11時22分33分','(*)[:時](*)[:分](*)[秒.]',pickup)=False);

  FreeAndNil(pickup);
end;

procedure TestWildcard3;
var
  pickup: TStringList;
  str: AnsiString;
begin
  pickup := nil;
  assert(MatchesMask('ウタダヒカル','*[!ア-ン]')=False);
  assert(MatchesMask('abc','[a-z][!a][a-z]'));
  assert(MatchesMask('abc','[*a-c]'));
  assert(MatchesMask('abc','[+a-c]'));
  assert(MatchesMask('abcefg','[*!e]efg'));
  assert(MatchesMask('abcddd','[=abc|efg]ddd'));
  Assert( IsMatch('ひらがな.txt', '[*あ-ん].txt', pickup) = True);
  Assert( IsMatch('漢字.txt', '[*あ-ん].txt', pickup) = False);
  Assert( IsMatch('漢字.txt', '[*!あ-ん].txt', pickup) = False);
  Assert( IsMatch('ひらがな.txt', '[*!.].txt', pickup) = True);
  //
  str := '123-456';
  Assert(IsTopMatch(str, '[*0-9]', pickup));
  Assert(str='-456');
  //---
  str := 'abc-def';
  Assert(IsTopMatch(str, '[*a-z]', pickup));
  Assert(str='-def');
  //---
  str := 'abc-def';
  Assert(IsTopMatch(str, '*-', pickup));
  Assert(str='def');
  str := 'abc-def';
  Assert(IsTopMatch(str, '*-e', pickup)=False);
end;


function LCMapStringExHalf(const str: AnsiString; MapFlag: DWORD): AnsiString;
var
  pDes: PAnsiChar;
  len,len2: Integer;
begin
  if str='' then begin Result := ''; Exit; end;
  len  := Length(str);
  len2 := len+2;
  GetMem(pDes, len2);
  try
    FillChar( pDes^, len2, 0 );
    LCMapStringA( LOCALE_SYSTEM_DEFAULT, MapFlag, PAnsiChar(str), len, pDes, len2-1);
    Result := AnsiString( pDes );
  finally
    FreeMem(pDes);
  end;
end;

function UpperCaseEx(const str: AnsiString): AnsiString;
begin
  Result := LCMapStringExHalf( str, LCMAP_UPPERCASE );
end;

function MatchesMask(const Filename, Mask: AnsiString): Boolean;
var
  pat: TKWPattern;
begin
  pat := TKWPattern.Create(UpperCaseEx(Mask));
  try
    Result := pat.IsMatch(UpperCaseEx(Filename));
  finally
    pat.Free;
  end;
end;


function IsMatch(const str, pattern: AnsiString; var pickup: TStringList): Boolean;
var
  pat: TKWPattern;
begin
  if pickup = nil then pickup := TStringList.Create;
  pat := TKWPattern.Create(pattern);
  try
    Result := pat.IsMatch(str);
    pickup.Assign(pat.Pickup);
  finally
    pat.Free;
  end;
end;

function IsMatch(const str, pattern: AnsiString): Boolean; overload;
var
  pick: TStringList;
begin
  pick := TStringList.Create;
  try
    Result := IsMatch(str, pattern, pick);
  finally
    FreeAndNil(pick);
  end;
end;

function IsTopMatch(var str: AnsiString; pattern: AnsiString; var pickup: TStringList): Boolean;
var
  pat: TKWPattern;
begin
  if pickup = nil then pickup := TStringList.Create;
  pat := TKWPattern.Create(pattern);
  try
    Result := pat.IsTopMatch(str);
    pickup.Assign(pat.Pickup);
  finally
    pat.Free;
  end;
end;

function WildReplace(Src, FindStr, NewStr: AnsiString; ReplaceAll: Boolean): AnsiString;
var
  pat: TKWPattern;
begin
  if FindStr = '' then
  begin
    Result:=Src;
    Exit;
  end;
  pat := TKWPattern.Create(FindStr);
  try
    Result := pat.Replace(Src, NewStr, ReplaceAll);
  finally
    pat.Free;
  end;
end;

function WildSplit(Src, FindStr: AnsiString): TStringList;
var
  pat: TKWPattern;
  p: PAnsiChar;
  s: AnsiString;
begin
  if FindStr = '' then
  begin
    //ワイルドカードが空の時は1文字ずつ区切る
    Result := TStringList.Create;
    p := PAnsiChar(Src);
    while p^ <> #0 do
    begin
      if p^ in LeadBytes then
      begin
        s := p^ + (p+1)^;
        Result.Add(string(s));
        Inc(p,2);
      end else
      begin
        Result.Add(string(p^));
        Inc(p);
      end
    end;
    Exit;
  end;
  pat := TKWPattern.Create(FindStr);
  try
    Result := pat.Split(Src);
  finally
    pat.Free;
  end;
end;

function WildSubMatch(const str, pattern: AnsiString; var pickup: TStringList): AnsiString;
var
  pat: TKWPattern;
begin
  if pickup = nil then pickup := TStringList.Create;
  pat := TKWPattern.Create(pattern);
  try
    Result := pat.SubMatch(str);
    pickup.Assign(pat.Pickup);
  finally
    pat.Free;
  end;
end;

function WildGetToken(var Src: AnsiString; splitter: AnsiString; var pickup: TStringList): AnsiString;
var
  pat: TKWPattern;
begin
  if pickup = nil then pickup := TStringList.Create;
  pat := TKWPattern.Create(splitter);
  try
    Result := pat.getToken(Src);
    pickup.Assign(pat.Pickup);
  finally
    pat.Free;
  end;
end;

function getOneChar(var p: PAnsiChar): AnsiString;
begin
  if (p = nil)or(p^ = #0) then begin Result := ''; Exit; end;
  if p^ in LeadBytes then
  begin
    Result := p^ + (p+1)^;
    Inc(p, 2);
  end else
  begin
    Result := p^;
    Inc(p);
  end;
end;

function getOneChar(var p: PAnsiChar;const p_last:PAnsiChar): AnsiString;
begin
  if (p = nil)or(p >= p_last) then begin Result := ''; Exit; end;
  if p^ in LeadBytes then
  begin
    Result := p^ + (p+1)^;
    Inc(p, 2);
  end else
  begin
    Result := p^;
    Inc(p);
  end;
end;

function JReplace(str, sFind, sNew: AnsiString): AnsiString;
var
  p, pFind: PAnsiChar;
  len: Integer;
  c: AnsiString;
begin
  p      := PAnsiChar(str);
  pFind  := PAnsiChar(sFind);
  len    := Length(sFind);
  Result := '';
  while p^ <> #0 do
  begin
    // 検索語に合致するか？
    if (StrLComp(p, pFind, len) = 0) then
    begin
      Result := Result + sNew;
      Inc(p, len);
      Continue;
    end;
    // 合致しなければそのままを返す
    c := getOneChar(p);
    Result := Result + c;
  end;
end;

{ TKWString }

procedure TKWString.Clear;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    FreeAndNil(TKWSeq(FData[i]));
  end;
end;

destructor TKWString.Destroy;
begin
  Clear;
  inherited;
end;


function TKWString.GetCharAt(Index: Integer): TKWSeq;
begin
  Result := FData[Index];
end;

function TKWString.GetCount: Integer;
begin
  Result := Length(FData);
end;

procedure TKWString.SetCharAt(Index: Integer; const Value: TKWSeq);
begin
  FData[Index] := Value;
end;


{ TKWChar }

constructor TKWChar.Create(ch: AnsiString);
begin
  Data := ch;
end;

function TKWChar.IsMatch(var p: PAnsiChar): Boolean;
var
  c: AnsiString;
begin
  if Data = #13#10 then // 改行だけ特別扱いする
  begin
    Result := (((p^) + (p+1)^) = Data);
    Inc(p, 2);
  end else
  begin
    c := getOneChar(p);
    Result := (c = Data);
  end;
end;

function TKWChar.IsTopMatch(var p: PAnsiChar): Boolean;
begin
  Result := IsMatch(p);
end;

{ TKWQuestion }

function TKWQuestion.IsMatch(var p: PAnsiChar): Boolean;
var
  c: AnsiString;
begin
  c := getOneChar(p);
  Result := True;
end;

function TKWQuestion.IsTopMatch(var p: PAnsiChar): Boolean;
begin
  Result := IsMatch(p);
end;

{ TKWAsterisk }

constructor TKWAsterisk.Create(AParent: TKWPattern);
begin
  Parent := AParent;
end;

function TKWAsterisk.IsMatch(var p: PAnsiChar): Boolean;
var
  tmp: PAnsiChar;
  idx: Integer;
  pickupCount: Integer;
begin
  tmp := p;
  if Parent.HasNext = False then
  begin
    // 最後のワイルドカードなら必ずTrueを返す
    while p^ <> #0 do Inc(p);
    Result := True;
    Exit;
  end;
  //
  Parent.MoveNext; // "*" を飛ばす
  //
  idx := Parent.Index;
  pickupCount := Parent.Pickup.Count;

  while p^ <> #0 do
  begin
    if Parent.IsMatchPAnsiChar(p) then
    begin
      Result := True;
      Exit;
    end else
    begin
      Parent.Index := idx; // 戻す
      getOneChar(tmp);
      p := tmp;
      // pickup
      while (pickupCount < Parent.Pickup.Count) do
      begin
        Parent.Pickup.Delete(Parent.Pickup.Count-1);
      end;
    end;
  end;
  // ワイルドカードが文の最後なら必ず True を返す
  Result := Parent.IsMatchPAnsiChar(p);
  Parent.Index := idx;
end;

function TKWAsterisk.IsTopMatch(var p: PAnsiChar): Boolean;
var
  tmp: PAnsiChar;
  idx: Integer;
  pickupCount: Integer;
begin
  tmp := p;
  if Parent.HasNext = False then
  begin
    // 最後のワイルドカードなら必ずTrueを返す
    while p^ <> #0 do Inc(p);
    Result := True;
    Exit;
  end;
  //
  Parent.MoveNext; // "*" を飛ばす
  //
  idx := Parent.Index;
  pickupCount := Parent.Pickup.Count;

  while p^ <> #0 do
  begin
    if Parent.IsTopMatchPAnsiChar(p) then
    begin
      Result := True;
      Exit;
    end else
    begin
      Parent.Index := idx; // 戻す
      getOneChar(tmp);
      p := tmp;
      // pickup
      while (pickupCount < Parent.Pickup.Count) do
      begin
        Parent.Pickup.Delete(Parent.Pickup.Count-1);
      end;
    end;
  end;
  // ワイルドカードが文の最後なら必ず True を返す
  Result := Parent.IsTopMatchPAnsiChar(p);
  Parent.Index := idx;
end;

{ TKWPattern }

constructor TKWPattern.Create(str: AnsiString);
begin
  Pickup := TStringList.Create;
  PickupBegin := nil;
  Index := 0;
  SetPattern(str);
end;

function TKWPattern.Cur: TKWSeq;
begin
  Result := CharAt[Index];
end;

destructor TKWPattern.Destroy;
begin
  FreeAndNil(Pickup);
  inherited;
end;

function TKWPattern.HasNext: Boolean;
begin
  Result := (Index < Count - 1);
end;

function TKWPattern.IsMatch(s: AnsiString): Boolean;
var
  p: PAnsiChar;
begin
  pickup.Clear;
  p := PAnsiChar(s);
  Result := IsMatchPAnsiChar(p);
end;

procedure TKWPattern.MoveNext;
begin
  Inc(Index);
end;

procedure TKWPattern.SetPattern(str: AnsiString);
var
  p: PAnsiChar;
  c: AnsiString;
  i: Integer;
  q: TKWSeq;
begin
  SetLength(FData, Length(str));
  i := 0;
  p := PAnsiChar(str);
  while p^ <> #0 do
  begin
    c := getOneChar(p);
    if c = '' then Continue;
    case c[1] of
      '*':
        begin
          q := TKWAsterisk.Create(Self);
        end;
      '?':
        begin
          q := TKWQuestion.Create;
        end;
      '#':
        begin
          q := TKWSharp.Create;
        end;
      '(':
        begin
          q := TKWKakkoFrom.Create(Self);
        end;
      ')':
        begin
          q := TKWKakkoTo.Create(Self);
        end;
      '[':
        begin
          q := TKWSelect.Create(Self, p);
        end;
      else
        begin
          if c = '\' then
          begin
            c := getOneChar(p);
            if c = 't' then q := TKWChar.Create(#9)     else
            if c = 'n' then q := TKWChar.Create(#13#10) else
            if c = 's' then q := TKWSelect.Create(Self, ' '#9)  else
            if c = 'S' then q := TKWSelect.Create(Self, '! '#9) else
            if c = 'd' then q := TKWSelect.Create(Self, '0-9')  else
            if c = 'D' then q := TKWSelect.Create(Self, '!0-9') else
            begin
              q := TKWChar.Create(c);
            end;
          end else
          begin
            q := TKWChar.Create(c);
          end;
        end;
    end;
    FData[i] := q;
    Inc(i);
  end;
  SetLength(FData, i);
end;

function TKWPattern.IsMatchPAnsiChar(var p: PAnsiChar): Boolean;
var
  c: TKWSeq;
begin
  Result := True;

  while (Index < Count) do
  begin
    c := Cur;
    if not c.IsMatch(p) then
    begin
      Result := False; Break;
    end;
    MoveNext;
  end;

  if (p = nil) or (p^ <> #0) then Result := False;
end;

function TKWPattern.IsTopMatch(var s: AnsiString): Boolean;
var
  p: PAnsiChar;
begin
  pickup.Clear;
  p := PAnsiChar(s);
  Result := IsTopMatchPAnsiChar(p);
  s := p;
end;

function TKWPattern.IsTopMatchPAnsiChar(var p: PAnsiChar): Boolean;
var
  c: TKWSeq;
begin
  Result := True;

  while (Index < Count) do
  begin
    c := Cur;
    if not c.IsTopMatch(p) then
    begin
      Result := False; Break;
    end;
    MoveNext;
  end;
end;

function TKWPattern.Replace(Src, NewStr: AnsiString;
  ReplaceAll: Boolean): AnsiString;
var
  p, pTemp: PAnsiChar;
  c, s: AnsiString;
  i: Integer;
begin
  Result := '';
  p := PAnsiChar(Src);
  pTemp := p;
  while p^ <> #0 do
  begin
    Self.Index := 0;
    if IsTopMatchPAnsiChar(p) then
    begin
      s := NewStr;
      //-----------------------------
      // ピックアップの置換
      if pickup.Count > 0 then
      begin
        for i := 0 to pickup.Count - 1 do
        begin
          s := JReplaceA(s, '$' + IntToStrA(i+1), AnsiString(pickup.Strings[i]));
        end;
      end;
      //-----------------------------
      Result := Result + s;
      if ReplaceAll then
      begin
        pickup.Clear;
        pTemp := p;
        Continue;
      end else
      begin
        Result := Result + AnsiString(p); Break;
      end;
    end else
    begin
      c := getOneChar(pTemp);
      Result := Result + c;
      p := pTemp;
    end;
  end;
end;

function TKWPattern.Split(Src: AnsiString): TStringList;
var
  p, pTemp: PAnsiChar;
  s, c: AnsiString;
begin
  Result := TStringList.Create;
  p := PAnsiChar(Src);
  pTemp := p;
  s := '';
  while p^ <> #0 do
  begin
    Self.Index := 0;
    if IsTopMatchPAnsiChar(p) then
    begin
      Result.Add(string(s));
      s := '';
      pickup.Clear;
      pTemp := p;
    end else
    begin
      c := getOneChar(pTemp);
      s := s + c;
      p := pTemp;
    end;
  end;
  if s <> '' then Result.Add(string(s));
end;

function TKWPattern.SubMatch(Src: AnsiString): AnsiString;
var
  p, pTemp: PAnsiChar;
  c: AnsiString;
  len: Integer;
begin
  Result := '';
  p := PAnsiChar(Src);
  pTemp := p;
  while p^ <> #0 do
  begin
    Self.Index := 0;
    if IsTopMatchPAnsiChar(p) then
    begin
      len := (p - pTemp) ;
      if len <> 0 then
      begin
        SetLength(Result, len);
        StrLCopy(PAnsiChar(Result), pTemp, len);
      end;
      Break;
    end else
    begin
      // 1文字次を調べる
      c := getOneChar(pTemp);
      p := pTemp;
    end;
  end;
end;

function TKWPattern.getToken(var Src: AnsiString): AnsiString;
var
  p, pTemp: PAnsiChar;
  c: AnsiString;
begin
  Result := '';
  p := PAnsiChar(Src);
  pTemp := p;
  while p^ <> #0 do
  begin
    Self.Index := 0;
    if IsTopMatchPAnsiChar(p) then
    begin
      Src := AnsiString(p);
      Exit;
    end else
    begin
      // 1文字次を調べる
      c := getOneChar(pTemp);
      p := pTemp;
      Result := Result + c;
    end;
  end;
  Src := '';
end;

{ TKWSharp }

function TKWSharp.IsMatch(var p: PAnsiChar): Boolean;
var
  c: AnsiString;
begin
  Result := False;
  c := getOneChar(p);
  if c = '' then Exit;
  if c[1] in ['0'..'9'] then Result := True;
end;

function TKWSharp.IsTopMatch(var p: PAnsiChar): Boolean;
begin
  Result := IsMatch(p);
end;

{ TKWKakkoFrom }

constructor TKWKakkoFrom.Create(AParent: TKWPattern);
begin
  Parent := AParent;
end;

function TKWKakkoFrom.IsMatch(var p: PAnsiChar): Boolean;
begin
  Parent.PickupBegin := p;
  Result := True;
end;

function TKWKakkoFrom.IsTopMatch(var p: PAnsiChar): Boolean;
begin
  Result := IsMatch(p);
end;

{ TKWKakkoTo }

constructor TKWKakkoTo.Create(AParent: TKWPattern);
begin
  Parent := AParent;
end;

function TKWKakkoTo.IsMatch(var p: PAnsiChar): Boolean;
var
  s: AnsiString;
  pp: PAnsiChar;
begin
  Result := True;
  pp := Parent.PickupBegin;
  s := '';
  while (pp <> p) do
  begin
    if pp^ = #0 then Break;
    s := s + pp^;
    Inc(pp);
  end;
  Parent.Pickup.Add(string(s));
end;

function TKWKakkoTo.IsTopMatch(var p: PAnsiChar): Boolean;
begin
  Result := IsMatch(p);
end;

{ TKWSelect }

constructor TKWSelect.Create(AParent: TKWPattern; var p: PAnsiChar);
var
  c, c2: AnsiString;

  function getCharCode(s: AnsiString): Integer;
  begin
    if s = '' then begin Result := 0; Exit; end;
    if s[1] in LeadBytes then
    begin
      Result := Ord(s[1]) shl 8 + Ord(s[2]);
    end else
    begin
      Result := Ord(s[1]);
    end;
  end;

  function CharCode2Str(code: Integer): AnsiString;
  begin
    Result := AnsiChar(Chr( (code shr 8) and $FF )) + AnsiChar(Chr( code and $FF ));
  end;

  procedure getSets;
  var i: Integer;
  begin
    if p^ = '!' then
    begin
      Inc(p);
      IsNot := True;
    end;
    while p^ <> #0 do
    begin
      c := getOneChar(p);
      if c = '' then Break;
      if p^ = '\' then
      begin
        Inc(p);
        Sets.Add(string(c));
        Continue;
      end;
      if p^ = '-' then
      begin
        Inc(p);
        c2 := getOneChar(p);
        for i := getCharCode(c) to getCharCode(c2) do
        begin
          Sets.Add(string(CharCode2Str(i)));
        end;
      end;

      if c = ']' then
      begin
        Break;
      end;
      Sets.Add(string(c));
    end;
  end;
  procedure getWords;
  var s: AnsiString;
  begin
    if p^ = '!' then
    begin
      Inc(p);
      IsNot := True;
    end;
    while p^ <> #0 do
    begin
      s := '';
      while p^ <> #0 do begin
        if p^ = '|' then
        begin
          Inc(p); Break;
        end else
        if p^ = ']' then
        begin
          Break;
        end;
        if p^ in LeadBytes then
        begin
          s := s + p^;
          Inc(p);
        end;
        s := s + p^;
        Inc(p);
      end;
      if s <> '' then Sets.Add(string(s));
      if p^ = ']' then
      begin
        Inc(p);
        Break;
      end;
    end;
  end;

begin
  Parent := AParent;
  //
  Sets := TStringList.Create;
  IsNot := False;
  if p^ = '!' then
  begin
    Inc(p);
    IsNot := True;
  end;
  //
  case p^ of
    '+':
      begin
        Pattern := patPlus;
        Inc(p);
        getSets;
      end;
    '*':
      begin
        Pattern := patAsterisk;
        Inc(p);
        getSets;
      end;
    '=':
      begin
        Pattern := patWord;
        Inc(p);
        getWords;
      end;
    else
      begin
        Pattern := patOne;
        getSets;
      end;
  end;
end;

constructor TKWSelect.Create(AParent: TKWPattern; s: AnsiString);
var
  p: PAnsiChar;
begin
  p := PAnsiChar(s);
  Self.Create(AParent, p);
end;

destructor TKWSelect.Destroy;
begin
  Sets.Free;
  inherited;
end;

function TKWSelect.IsMatch(var p: PAnsiChar): Boolean;
var
  c: AnsiString;
  i: Integer;

  function getChar: AnsiString;
  begin
    if (p = nil)or(p^ = #0) then begin Result := ''; Exit; end;
    if p^ in LeadBytes then
      Result := p^ + (p+1)^
    else
      Result := p^;
  end;

  procedure match_one;
  begin
    c := getOneChar(p);
    if c = '' then begin Result := False; Exit; end;
    Result := (Sets.IndexOf(string(c)) >= 0);
    if IsNot then Result := not Result;
  end;

  procedure match_any;
  begin
    while True do
    begin
      if IsNot then
      begin
        c := getChar;
        Result := (Sets.IndexOf(string(c)) < 0);
      end else
      begin
        c := getChar;
        Result := (Sets.IndexOf(string(c)) >= 0);
      end;
      if c = '' then Break;
      if not Result then Break;
      Inc(p, Length(c));
    end;
  end;

begin
  case Pattern of
    patOne:
      begin
        // 1文字マッチ
        match_one;
      end;
    patPlus:
      begin
        // 1文字以上のマッチ
        match_one;
        if Result then begin match_any; Result := True; end;
      end;
    patAsterisk:
      begin
        // 0文字以上のマッチ
        match_any;
        Result := True; // 必ずTrueになる
      end;
    patWord:
      begin
        Result := False;
        for i := 0 to Sets.Count - 1 do
        begin
          c := AnsiString(Sets.Strings[i]);
          if StrLComp(PAnsiChar(c), p, Length(c)) = 0 then
          begin
            Result := True;
            Inc(p, Length(c));
            Break;
          end;
        end;
      end;
  end;
end;

function TKWSelect.IsTopMatch(var p: PAnsiChar): Boolean;
begin
  Result := IsMatch(p);
end;

end.

