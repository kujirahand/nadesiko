(*********************************************************************

  heFountain.pas

  start  2000/12/24
  update 2001/09/30

  Copyright (c) 2000,2001 本田勝彦 <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  comments
  #LastTokenBracket ... 文字列リストに保持されるデータについて

**********************************************************************)

unit heFountain;

{$I heverdef.inc}

interface

uses
  SysUtils, Classes, Controls, Graphics, TypInfo,
  HPropUtils, heUtils, heClasses, heRaStrings;

{ TFountainParser special tokens }

const
 {toEOF             = Char(0);
  toSymbol          = Char(1);
  toString          = Char(2);
  toInteger         = Char(3);
  toFloat           = Char(4);
  toWString         = Char(5);}
  toBracket         = Char(6);
  toComment         = Char(7);
  toReserve         = Char(8);
  toTab             = Char(9);
  toAnk             = Char(11);
  toDBSymbol        = Char(12);
  toDBInt           = Char(14);
  toDBAlph          = Char(15);
  toDBHira          = Char(16);
  toDBKana          = Char(17);
  toDBKanji         = Char(18);
  toKanaSymbol      = Char(19);
  toKana            = Char(20);
  toUrl             = Char(21);
  toMail            = Char(22);
  toHex             = Char(23);
  toSingleQuotation = Char(24);
  toDoubleQuotation = Char(25);

type
  TFountainColor = class(TNotifyPersistent)
  private
    FBkColor: TColor;           // 背景色
    FColor: TColor;             // 前景色
    FStyle: TFontStyles;        // フォントスタイル
    procedure SetBkColor(Value: TColor);
    procedure SetColor(Value: TColor);
    procedure SetStyle(Value: TFontStyles);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property BkColor: TColor read FBkColor write SetBkColor;
    property Color: TColor read FColor write SetColor;
    property Style: TFontStyles read FStyle write SetStyle;
  end;

  TFountainColorItem = class(TCollectionItem)
  private
    FItemColor: TFountainColor; // 領域の背景色、前景色、フォントスタイル
    procedure SetItemColor(Value: TFountainColor);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property ItemColor: TFountainColor read FItemColor write SetItemColor;
  end;

  TFountainBracketItem = class(TFountainColorItem)
  private
    FLeftBracket: String;       // 左囲み文字 ex {, (*
    FRightBracket: String;      // 右囲み文字 ex }, *)
  public
    procedure Assign(Source: TPersistent); override;
  published
    property LeftBracket: String read FLeftBracket write FLeftBracket;
    property RightBracket: String read FRightBracket write FRightBracket;
  end;

  TFountainBracketCollection = class(TNotifyCollection)
  protected
    function GetBracketItem(Index: Integer): TFountainBracketItem;
    procedure SetBracketItem(Index: Integer; Value: TFountainBracketItem);
  public
    constructor Create;
    function Add: TFountainBracketItem;
    procedure Assign(Source: TPersistent); override;
    property BracketItems[Index: Integer]: TFountainBracketItem read GetBracketItem write SetBracketItem; default;
  end;

  { TFountainParser abstract class }

  TFountain = class;

  TFountainParseProc = procedure of object;

  TFountainParser = class(TObject)
  protected
    FBuffer: PChar;
    FBracketIndex: Integer;
    FDataStr: String;
    FDrawBracketIndex: Integer;
    FElementIndex: Integer;
    FFountain: TFountain;
    FIsStartToken: Boolean;
    FMethodTable: array [#0..#255] of TFountainParseProc;
    FP: PChar;
    FPrevRowAttribute: TRowAttribute;
    FPrevToken: Char;
    FRemain: Integer;
    FRowAttribute: TRowAttribute;
    FSourcePtr: PChar;
    FStartToken: Char;
    FToken: Char;
    FTokenMethodTable: array [#0..#255] of TFountainParseProc;
    FTokenPtr: PChar;
    FWrappedByte: Integer;
    procedure InitMethodTable; virtual;
    procedure SkipBlanks; virtual;
    function IsKeyWord(const S: String): Boolean;
    function IsReserveWord: Boolean; virtual;
    function IsBracketProc: Boolean; virtual;
    procedure BracketProc; virtual;
    function IsMailProc: Boolean; virtual;
    procedure MailProc; virtual;
    function IsUrlProc: Boolean; virtual;
    procedure UrlProc; virtual;
    procedure ReserveWordProc; virtual;
    procedure EofProc; virtual;
    procedure TabProc; virtual;
    procedure LFProc; virtual;
    procedure CrProc; virtual;
    procedure CommenterProc; virtual;
    procedure HexProc; virtual;
    procedure IntegerProc; virtual;
    procedure AnkProc; virtual;
    procedure DBSymbolProc; virtual;
    procedure DBProc; virtual;
    procedure DBKanjiProc; virtual;
    procedure KanaSymbolProc; virtual;
    procedure KanaProc; virtual;
    procedure SymbolProc; virtual;
    procedure SingleQuotationProc; virtual;
    procedure DoubleQuotationProc; virtual;
    procedure StartTokenProc; virtual;
    procedure NormalTokenProc; virtual;
    procedure WrappedTokenIsReserveWord(var AToken: Char); virtual;
    function IncludeTabToken: TCharSet; virtual;
    function EolToken: TCharSet; virtual;
  public
    constructor Create(Fountain: TFountain); virtual;
    procedure NewData(const S: String; Data: TRowAttributeData); virtual;
    procedure LastTokenBracket(Index: Integer; Strings: TRowAttributeStringList;
      var Data: TRowAttributeData); virtual;
    function NextToken: Char; virtual;
    function SourcePos: Longint;
    function TokenLength: Longint;
    function TokenString: String;
    function TokenToFountainColor: TFountainColor; virtual; abstract;
    property DrawBracketIndex: Integer read FDrawBracketIndex;
    property Token: Char read FToken;
  end;

  TFountainParserClass = class of TFountainParser;

  { TFountain abstract class }

  TFountainColorOperation = (coBkColor, coColor, coStyle);
  TFountainColorOperations = set of TFountainColorOperation;

  TFountain = class(TFileExtComponent)
  private
    FBrackets: TFountainBracketCollection;
    FNotifyEventList: TNotifyEventList;
    FReserve: TFountainColor;
    FReserveWordList: TStringList;
    procedure SetBrackets(Value: TFountainBracketCollection);
    procedure SetReserve(Value: TFountainColor);
    procedure SetReserveWordList(Value: TStringList);
  protected
    FHasItalicFontStyle: Boolean;
    FFountainColor: TFountainColor;        // for SameFountainColor method
    FOperations: TFountainColorOperations; // for SameFountainColor method
    function CreateFountainColor: TFountainColor; virtual;
    procedure CreateFountainColors; virtual;
    function CreateNotifyEventList: TNotifyEventList;
    function CreateBrackets: TFountainBracketCollection; virtual;
    function GetParserClass: TFountainParserClass; virtual; abstract;
    procedure InitBracketItems; virtual;
    procedure InitReserveWordList; virtual;
    procedure ItalicFontStyleProc(Instance: TObject; pInfo: PPropInfo;
      tInfo: PTypeInfo); virtual;
    procedure FountainColorProc(Instance: TObject; pInfo: PPropInfo;
      tInfo: PTypeInfo); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CreateParser: TFountainParser; virtual;
    function HasItalicFontStyle(Instance: TPersistent): Boolean; virtual;
    procedure SameFountainColor(Instance: TPersistent; FountainColor: TFountainColor;
      Operations: TFountainColorOperations);
    property NotifyEventList: TNotifyEventList read FNotifyEventList;
    property ParserClass: TFountainParserClass read GetParserClass;
  published
    property Brackets: TFountainBracketCollection read FBrackets write SetBrackets;
    property Reserve: TFountainColor read FReserve write SetReserve;
    property ReserveWordList: TStringList read FReserveWordList write SetReserveWordList;
  end;

implementation


{ TFountainColor }

constructor TFountainColor.Create;
begin
  FBkColor := Graphics.clNone; // D2 では Graphics. が何故か必要
  FColor := Graphics.clNone;
end;

procedure TFountainColor.Assign(Source: TPersistent);
begin
  if Source is TFountainColor then
  begin
    FBkColor := TFountainColor(Source).FBkColor;
    FColor := TFountainColor(Source).FColor;
    FStyle := TFountainColor(Source).FStyle;
    Changed;
  end
  else
    inherited Assign(Source);
end;

procedure TFountainColor.SetBkColor(Value: TColor);
begin
  if FBkColor <> Value then
  begin
    FBkColor := Value;
    Changed;
  end;
end;

procedure TFountainColor.SetColor(Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Changed;
  end;
end;

procedure TFountainColor.SetStyle(Value: TFontStyles);
begin
  if FStyle <> Value then
  begin
    FStyle := Value;
    Changed;
  end;
end;


{ TFountainColorItem }

constructor TFountainColorItem.Create(Collection: TCollection);
begin
  FItemColor := TFountainColor.Create;
  if (Collection <> nil) and (Collection is TNotifyCollection) then
    FItemColor.OnChange := TNotifyCollection(Collection).ChangedProc;
  inherited Create(Collection);
end;

destructor TFountainColorItem.Destroy;
begin
  FItemColor.Free;
  inherited Destroy;
end;

procedure TFountainColorItem.SetItemColor(Value: TFountainColor);
begin
  FItemColor.Assign(Value);
end;

procedure TFountainColorItem.Assign(Source: TPersistent);
begin
  if Source is TFountainColorItem then
    FItemColor.Assign(TFountainColorItem(Source).FItemColor)
  else
    inherited Assign(Source);
end;


{ TFountainBracketItem }

procedure TFountainBracketItem.Assign(Source: TPersistent);
begin
  if Source is TFountainBracketItem then
  begin
    FLeftBracket := TFountainBracketItem(Source).FLeftBracket;
    FRightBracket := TFountainBracketItem(Source).FRightBracket;
    inherited Assign(Source);
  end
  else
    inherited Assign(Source);
end;


{ TFountainBracketCollection }

constructor TFountainBracketCollection.Create;
begin
  inherited Create(TFountainBracketItem);
end;

function TFountainBracketCollection.Add: TFountainBracketItem;
begin
  if Count = BracketItemLimit then
    raise Exception.Create('TFountainBracketCollection'#13#10'You can not add item over ' + IntToStr(BracketItemLimit));
  Result := TFountainBracketItem(inherited Add);
end;

procedure TFountainBracketCollection.Assign(Source: TPersistent);
var
  I: Integer;
begin
  if Source is TFountainBracketCollection then
  begin
    BeginUpdate;
    try
      Clear;
      for I := 0 to TFountainBracketCollection(Source).Count - 1 do
        Add.Assign(TFountainBracketCollection(Source).Items[I]);
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

function TFountainBracketCollection.GetBracketItem(Index: Integer): TFountainBracketItem;
begin
  Result := TFountainBracketItem(inherited GetItem(Index));
end;

procedure TFountainBracketCollection.SetBracketItem(Index: Integer; Value: TFountainBracketItem);
begin
  inherited SetItem(Index, Value);
end;


{ TFountainParser }

// for IsKeyWord method
const
  WordDelimiters: set of Char =
    [#$0..#$FF] - ['0'..'9', 'A'..'Z', '_', 'a'..'z'];
var
  CharMap: array[#$0..#$FF] of Char;

procedure InitCharMap;
var
  I: Char;
begin
  for I := #$0 to #$FF do
    if I in ['a'..'z'] then
      CharMap[I] := UpCase(I)
    else
      CharMap[I] := I;
end;

constructor TFountainParser.Create(Fountain: TFountain);
begin
  if Fountain = nil then
    raise Exception.Create('TFountainParser.Create need instance of TFountain');
  FFountain := Fountain;
  InitMethodTable;
end;

function TFountainParser.IsKeyWord(const S: String): Boolean;
var
  I, L: Integer;
  P: PChar;
begin
  Result := False;
  L := Length(S);
  if L < 1 then
    Exit;
  P := FP;
  I := 1;
  while CharMap[P^] = CharMap[S[I]] do
  begin
    if I = L then
    begin
      Inc(P);
      if P^ in WordDelimiters then
      begin
        Result := True;
        FP := P;
      end;
      Break;
    end;
    Inc(I);
    Inc(P);
  end;
end;

function TFountainParser.IsReserveWord: Boolean;
var
  I: Integer;
begin
  Result := not FIsStartToken and
            not (FToken in [toEof, toBracket, toComment]) and
            FFountain.ReserveWordList.Find(TokenString, I);
end;

procedure TFountainParser.InitMethodTable;
var
  C: Char;
begin
  // FMethodTable
  for C := #0 to #255 do
    case C of
      #0:   FMethodTable[C] := EofProc;
      #9:   FMethodTable[C] := TabProc;
      #10:  FMethodTable[C] := LFProc;
      #13:  FMethodTable[C] := CrProc;
      '0'..'9':
            FMethodTable[C] := IntegerProc;
      'A'..'Z', '_', 'a'..'z':
            FMethodTable[C] := AnkProc;
      #$81: FMethodTable[C] := DBSymbolProc;
      #$82, #$83:
            FMethodTable[C] := DBProc;
      #$84..#$87:
            FMethodTable[C] := DBSymbolProc;
      #$88..#$9F, #$E0..#$FC:
            FMethodTable[C] := DBKanjiProc;
      #$A1..#$A5:
            FMethodTable[C] := KanaSymbolProc;
      #$A6..#$DF:
            FMethodTable[C] := KanaProc;
    else
            FMethodTable[C] := SymbolProc;
    end;

  // FTokenMethodTable
  for C := #0 to #255 do
    case C of
      toSymbol:
            FTokenMethodTable[C] := SymbolProc;
      toInteger, toFloat:
            FTokenMethodTable[C] := IntegerProc;
      toBracket:
            FTokenMethodTable[C] := BracketProc;
      toReserve:
            FTokenMethodTable[C] := ReserveWordProc;
      toComment:
            FTokenMethodTable[C] := CommenterProc;
      toAnk:
            FTokenMethodTable[C] := AnkProc;
      toDBSymbol:
            FTokenMethodTable[C] := DBSymbolProc;
      toDBInt:
            FTokenMethodTable[C] := DBProc;
      toDBAlph, toDBHira, toDBKana:
            FTokenMethodTable[C] := DBProc;
      toDBKanji:
            FTokenMethodTable[C] := DBKanjiProc;
      toKanaSymbol:
            FTokenMethodTable[C] := KanaSymbolProc;
      toKana:
            FTokenMethodTable[C] := KanaProc;
      toUrl:
            FTokenMethodTable[C] := UrlProc;
      toMail:
            FTokenMethodTable[C] := MailProc;
      toHex:
            FTokenMethodTable[C] := HexProc;
      toSingleQuotation:
            FTokenMethodTable[C] := SingleQuotationProc;
      toDoubleQuotation:
            FTokenMethodTable[C] := DoubleQuotationProc;
    else
            FTokenMethodTable[C] := SymbolProc;
    end;
end;

(*
  #LastTokenBracket

  TRowAttributeStringList 各行に格納される語句を切り分ける処理に必要な
  データを取得するためのメソッド

  ---------------------------------------------------------------------
  扱われるデータについて
  BracketIndex: Integer;
    Fountain.Brackets へのインデックス。
  ElementIndex: Integer;
    タグの中、property 節の中など、構文要素を表現する数値。
  WrappedByte: Integer;
    一つのトークンが折り返し表示された場合の折り返し位置からトークンの
    最後までの長さ。
  StartToken: Char;
    WrappedByte が非０の時のトークンの種別。
  PrevToken: Char;
    直前のトークンの種別。

  ---------------------------------------------------------------------
  処理の流れ
  Strings の Index 行の文字列を 引数の Data: TRowAttribute 型データに
  よってパースし、Index + 1 行をパースする際に必用なデータを Data に
  格納する。

  Index 行が raWrapped の場合、次の１行文字列を加えた文字列をパースする。
  パース処理は、toEof が返るか、取得したトークンの終了位置が、Index 行の
  文字列長以上になった時点で Break する。（下図の場合 P > L1）

   Index 行          L1 Index + 1 行       L2
  +------------------+---------------------+
  |   ***************|**************       |
  +------------------+---------------------+
      S                            P

  ---------------------------------------------------------------------
  トークンの配置パターンと Data の更新処理について。

  トークンの配置パターン
               Index 行        L1 Index + 1 行    L2
            +------------------+------------------+
  パターン１|  全空白          |  全空白          |
            +------------------+------------------+
  パターン２|  全空白          |  ********        |
            +------------------+------------------+
  パターン３|  ********        |  ********        |
            +------------------+------------------+
  パターン４|    **************|  全空白          |
            +------------------+------------------+
  パターン５|    **************|**********        |
            +------------------+------------------+
  パターン６|    **************|******************|
            +------------------+------------------+

  パターンと Data の更新処理との関係を表にまとめたもの

  パターン BracketIndex  ElementIndex  WrappedByte  StartToken  PrevToken
      １     -             -             0            toEof       -
      ２     -             -             0            toEof       -
      ３     Normal        p             0            toEof       p
      ４     p             p             0            toEof       p
      ５     下記分割されたトークンの処理による
      ６     〃

  -: 初期値のまま
  p: パース処理によって取得されたデータによって更新する

  上記表から下記のような更新処理を行う。
  ・WrappedByte, StartToken は０を初期値とする。
  ・Index 行が空白だけの場合は、更新処理を行わない。（パターン１，２）
  ・パターン３の場合は、BracketIndex を NormalBracketIndex とする。
  ・パターン４の場合は、パース処理で取得されるデータで更新する。
  ・分割されたトークンについては、下記分割されたトークンの処理による

  ---------------------------------------------------------------------
  WordWrap 時に分割されたトークンの扱いについて

  行頭に前の行からまたがって折り返し表示されたトークンがある場合、
  その行の Tokens プロパティにはそのトークンの種別が格納されている。
  WrappedBytes プロパティには、その長さが格納されている。（０が格納
  される場合もあるが、後述する。）

  パーサーは処理を開始する際 Tokens プロパティを参照し、それが
  非 toEof の場合は、WrappedBytes プロパティ値を参照し、非０であれば
  その分ポインタを進めて、Tokens プロパティで指定されたトークンとして
  返す仕様になっている。WrappedBytes プロパティ値が０の場合は、
  FTokenMethodTable[Tokens プロパティ値] のメソッドに処理が委ねられる。
  したがって、新しいトークンを定義した場合は、そのトークンに対応する
  FTokenMethodTable を用意する必要がある。

  WrappedBytes に０が格納される場合について

  パターン１　２行にまたがるトークン
          +---------------------+
  1 行目  |              *******|
          +---------------------+
  2 行目  |*******              |
          +---------------------+

  パターン２　３行にまたがるトークン
          +---------------------+
  1 行目  |              *******|
          +---------------------+
  2 行目  |*********************|
          +---------------------+
  3 行目  |*******              |
          +---------------------+

  上図２行目をパースする場合について考える。

  パターン１の場合　WrappedBytes は７で良いが、パターン２の場合２１を
  格納した状態で、パースすると２行目全体を一つのトークンとして取得した
  後、３行目は新たなトークンとして扱われることになってしまうので、この
  場合（ P = L2 で２行目が raWrapped (*1)）は WrappedBytes に０を格納する。

  WrappedBytes 分ポインタを進める処理では、そこにタブ文字があると、この
  システムは破綻するという「タブ文字問題」がある。
  これは、LastTokenBracket で扱うデータは生のタブ文字を含む文字列で
  あるが、描画するときにパースする文字列はタブ文字が半角空白に展開され
  ていることに原因している。例えば TabSpaceCount が８で

              abc <- 折り返し
  TAB.....def

  というトークンがある場合、WrappedBytes には４が格納されるが、描画する
  時の文字列は
              abc <- 折り返し
  ________def （ _ は半角空白）

  となるので、先頭から４バイトまでを指定トークンとして扱い、残りの７
  バイトが別のトークンとして扱われてしまう。

  これらのタブ文字を含む可能性のあるトークン toComment, toSingleQuotation,
  toDoubleQuotation (*2) についても０を格納し、FTokenMethodTable に処理を
  委ねる仕様とする。

  これらのタブ文字を含む可能性のあるトークンの集合を返すメソッドとして
  IncludeTabToken が用意されている。LastTokenBracket メソッドではこの
  メソッドに問い合わせて、折り返されたトークンが該当する場合は
  WrappedByte に０を格納する処理を行っている。

  また、折り返された予約語についても考慮する必要があるので、現在の
  トークンが非 toBracket なトークンで折り返されている場合に、
  それが予約語かどうかを WrappedTokenIsReserveWord メソッドに問い合わ
  せて現在のトークンを更新している。

  toBracket もタブ文字を含む場合がある。
  toBracket は、Brackets プロパティ値によって BracketProc へ分岐される
  ので０を格納すれば良いことになるが、該当 RightBracket 文字列が折り返
  されている場合 (*3) BracketProc は RightBracket を発見することが
  出来ないので、この場合だけ WrappedBytes の仕組みを利用する。

  ---------------------------------------------------------------------
  分割されたトークンであることの判別 (S < L1) and (L1 < P)

   Index 行          L1 Index + 1 行       L2
  +------------------+---------------------+
  |   ***************|**************       |
  +------------------+---------------------+
      S                            P

  ---------------------------------------------------------------------
  ブレークした時点での、実際の処理

  Data.BracketIndex
  ブレークした時点でのトークンが、
  ・開いた toBracket の場合は、その時点での FBracketIndex が格納される。
  ・閉じた toBracket の場合は、分割されたトークンの場合はその時点での
    FDrawBracketIndex が格納される
  ・それ以外では NormalBracketIndex が格納される。

  Data.ElementIndex
  ブレークした時点でのトークンが分割されている場合は、直前のトークンを
  取得した際の FElementIndex が格納される。分割されていない場合は、現在
  の FElementIndex が格納される。

  Data.WrappedByte
  ブレークした時点でのトークンが分割されている場合に、上図 P の位置と
  L1 の差分が格納される。
  P = L2 で Index + 1 が raWrapped の場合は０が格納される。
  toBracket の場合は、該当 RightBracket が折り返されたときだけ処理される。
  非 toBracket の場合は、それがタブ文字を含むトークン（ [toComment,
  toSingleQuotation, toDoubleQuotation] など、IncludeTabToken メソッド
  の返値）以外の場合だけ処理される。

  Data.StartToken
  プレークした時点でのトークンが分割されている場合に、そのトークンが
  格納される。
  toBracket は、該当 RightBracket が折り返されたときだけ処理される
*)

procedure TFountainParser.LastTokenBracket(Index: Integer;
  Strings: TRowAttributeStringList; var Data: TRowAttributeData);
var
  S: String;
  L1, L2, P, B, E, I: Integer;
  TempToken: Char;
  SpaceOnly: Boolean;
begin
  if Data.StartToken in EolToken then
  begin
    if Data.RowAttribute <> raWrapped then
      Data.StartToken := toEof;
    Data.WrappedByte := 0;
  end
  else
  begin
    // 初期化
    S := Strings[Index];
    L1 := Length(S);
    // 全空白の判別（パターン１，２）
    SpaceOnly := True;
    for I := 1 to L1 do
      if S[I] <> #$20 then
      begin
        SpaceOnly := False;
        Break;
      end;
    if SpaceOnly then
      Exit;
    (*
      Index 行が全空白の場合、トークンが折り返しによって分断されていることは無いので、
      Data.StartToken, Data.WrappedByte は初めから０だから、Exit する前に初期化する
      必要はない。
    *)
    // パターン３～６の処理
    if (Data.RowAttribute = raWrapped) and
       (Index < Strings.Count - 1) then
      S := S + Strings[Index + 1];
    B := Data.BracketIndex;
    E := Data.ElementIndex;
    TempToken := toEof;
    NewData(S, Data);
    while NextToken <> toEof do
    begin
      TempToken := Token;
      Data.BracketIndex := FBracketIndex;
      if Token = toBracket then
        B := FDrawBracketIndex;
      E := FElementIndex;
      if SourcePos + TokenLength > L1 then
        Break;
      Data.ElementIndex := FElementIndex;
      Data.PrevToken := FPrevToken;
    end;
    // ブレークした時点での処理
    Data.WrappedByte := 0;
    Data.StartToken := toEof;
    if (Token <> toEof) and (SourcePos >= L1) then
      // パターン３の判別
      Data.BracketIndex := NormalBracketIndex
    else
    begin
      P := SourcePos + TokenLength;
      if (SourcePos < L1) and (P > L1) then
      begin
        // 分割されたトークンの処理（パターン５，６）
        Data.ElementIndex := E;
        L2 := Length(S);
        if (TempToken = toBracket) and
           (Data.BracketIndex = NormalBracketIndex) then
        begin
          // 分割された閉じた toBracket
          Data.BracketIndex := B;
          if (P - L1 < Length(FFountain.Brackets[B].RightBracket)) then
          begin
            // 閉じた toBracket の該当 RightBracket の文字列長よりも短い
            // 文字列が分割された場合
            Data.StartToken := toBracket;
            Data.WrappedByte := P - L1;
          end
        end
        else
          if TempToken <> toBracket then
          begin
            // 非 toBracket トークンが分割された場合
            // 予約語かどうかを判別
            WrappedTokenIsReserveWord(TempToken);
            Data.StartToken := TempToken;
            // タブ文字を含まないトークンで、トークンの末尾が Index + 1
            // の最後より前か、Index + 1 が折り返されていない場合に
            // WrappedByte を更新する
            if not(TempToken in IncludeTabToken) and
               ((P < L2) or (Strings.Rows[Index + 1] <> raWrapped)) then
              Data.WrappedByte := SourcePos + TokenLength - L1;
          end;
      end;
    end;
  end;
end;

procedure TFountainParser.WrappedTokenIsReserveWord(var AToken: Char);
(*
  LastTokenBracket メソッドのヘルパーメソッド。現在のトークンが、
  非 toBracket なトークンで、分割されている場合実行される。
  現在のトークンが予約語リストに含まれている場合は、AToken を更新する。
  第２第３の予約語リストを利用する場合は、それに含まれているトークンで
  あることを表現する値で AToken を更新する。
*)
begin
  if IsReserveWord then
    AToken := toReserve;
end;

function TFountainParser.IncludeTabToken: TCharSet;
(*
  LastTokenBracket メソッドのヘルパーメソッド。現在のトークンが、
  非 toBracket なトークンで、分割されている場合実行される。
  タブ文字を含む可能性のあるトークンを文字集合型で返す。
  タブ文字を含む可能性のある新しいトークンを定義した場合は
  ここの返値に追加する。
*)
begin
  Result := [toComment, toSingleQuotation, toDoubleQuotation];
end;

function TFountainParser.EolToken: TCharSet;
(*
  LastTokenBracket メソッドのヘルパーメソッド。
  toComment のように、行末までを一つのトークンとして扱うべきトークン
  の集合を返す。
  toComment の他にも、例えば '>' 以降の行末までをひとつのトークンとして
  扱いたい場合などに利用する。
*)
begin
  Result := [toComment];
end;

procedure TFountainParser.NewData(const S: String; Data: TRowAttributeData);
begin
  FBuffer := PChar(S);
  FSourcePtr := FBuffer;
  FTokenPtr := FBuffer;
  FDrawBracketIndex := InvalidBracketIndex;
  // from TRowAttributeData
  FRowAttribute := Data.RowAttribute;
  FPrevRowAttribute := Data.PrevRowAttribute;
  FBracketIndex := Data.BracketIndex;
  FElementIndex := Data.ElementIndex;
  FWrappedByte := Data.WrappedByte;
  FRemain := Data.Remain;
  FStartToken := Data.StartToken;
  FPrevToken := Data.PrevToken;
  FDataStr := Data.DataStr;
end;

procedure TFountainParser.SkipBlanks;
begin
  while True do
  begin
    case FSourcePtr^ of
      #0:
        Exit;
      #9:
        Exit;
      #33..#255:
        Exit;
    end;
    Inc(FSourcePtr);
  end;
end;

function TFountainParser.SourcePos: Longint;
begin
  Result := FTokenPtr - FBuffer;
end;

function TFountainParser.TokenLength: Longint;
begin
  Result := FSourcePtr - FTokenPtr;
end;

function TFountainParser.TokenString: String;
begin
  SetString(Result, FTokenPtr, FSourcePtr - FTokenPtr);
end;

procedure TFountainParser.StartTokenProc;
begin
  if FWrappedByte > 0 then
  begin
    FToken := FStartToken;
    Inc(FP, FWrappedByte);
    if FToken = toBracket then
    begin
      // 閉じた toBracket しかここにはやって来ない仕様
      FDrawBracketIndex := FBracketIndex;
      FBracketIndex := NormalBracketIndex;
    end;
  end
  else
    FTokenMethodTable[FStartToken];
  FStartToken := toEof;
  FWrappedByte := 0;
end;

procedure TFountainParser.NormalTokenProc;
begin
  if (FBracketIndex = NormalBracketIndex) and IsBracketProc then
    BracketProc
  else
    FMethodTable[FP^];
end;

function TFountainParser.NextToken: Char;
begin
  SkipBlanks;
  FP := FSourcePtr;
  FTokenPtr := FSourcePtr;
  FIsStartToken := FStartToken <> toEof;
  if FP^ in [#0, #10, #13] then
    FToken := toEof
  else
    if FStartToken <> toEof then
      StartTokenProc
    else
      if FBracketIndex > NormalBracketIndex then
        BracketProc
      else
        NormalTokenProc;
  FSourcePtr := FP;
  Result := FToken;
end;

function TFountainParser.IsBracketProc: Boolean;
var
  S: String;
  I, J, L: Integer;
begin
  Result := False;
  for I := 0 to FFountain.FBrackets.Count - 1 do
  begin
    S := FFountain.FBrackets[I].FLeftBracket;
    L := Length(S);
    for J := 1 to L do
      if (FP + J - 1)^ <> S[J] then
        Break
      else
        if J = L then
        begin
          Result := True;
          FBracketIndex := I;
          Inc(FP, L);
          Exit;
        end;
  end;
end;

procedure TFountainParser.BracketProc;
var
  S: String;
  I, L: Integer;
begin
  if (FBracketIndex < 0) or
     (FBracketIndex > FFountain.FBrackets.Count - 1) or
     (FFountain.FBrackets[FBracketIndex].FRightBracket = '') then
    FToken := toEof
  else
  begin
    FToken := toBracket;
    FDrawBracketIndex := FBracketIndex;
    S := FFountain.FBrackets[FBracketIndex].FRightBracket;
    L := Length(S);
    while not (FP^ in [#0, #10, #13]) do
    begin
      for I := 1 to L do
        if (FP + I - 1)^ <> S[I] then
          Break
        else
          if I = L then
          begin
            Inc(FP, L);
            FBracketIndex := NormalBracketIndex; // -1
            Exit;
          end;
      if FP^ in LeadBytes then
        Inc(FP);
      Inc(FP);
    end;
  end;
end;

function TFountainParser.IsMailProc: Boolean;
var
  P: PChar;
  Is64: Boolean; // @
begin
  Result := False;
  if (FP^ in [#0, #10, #13]) or not (FP^ in (MailChars - ['@'])) then
    Exit;
  Is64 := False;
  P := FP;
  Inc(P);
  while not (P^ in [#0, #10, #13]) and (P^ in MailChars) do
  begin
    // MailChars が連続し、@ の後に . がある場合真を返す
    if P^ = '@' then
      Is64 := True;
    if Is64 and (P^ = '.') then
    begin
      Result := True;
      Inc(P);
      FP := P;
      Exit;
    end;
    Inc(P);
  end;
end;

procedure TFountainParser.MailProc;
begin
  FToken := toMail;
  while not (FP^ in [#0, #10, #13]) and (FP^ in MailChars) do
    Inc(FP);
end;

function TFountainParser.IsUrlProc: Boolean;

  function Url(const S: String): Boolean;
  var
    I, L: Integer;
  begin
    Result := False;
    L := Length(S);
    for I := 1 to L do
      if (FP + I - 1)^ <> S[I] then
        Exit
      else
        if I = L then
        begin
          Inc(FP, L);
          Result := True;
        end;
  end;

begin
  case FP^ of
    'h': Result := Url('http:') or Url('https:');
    'f': Result := Url('ftp:');
    'w': Result := Url('www.');
  else
    Result := False;
  end;
end;

procedure TFountainParser.UrlProc;
begin
  FToken := toUrl;
  while not (FP^ in [#0, #10, #13]) and (FP^ in UrlChars) do
    Inc(FP);
end;

procedure TFountainParser.CommenterProc;
begin
  FToken := toComment;
  while not (FP^ in [#0, #10, #13]) do
    Inc(FP);
end;

procedure TFountainParser.SingleQuotationProc;
var
  C: Char;
begin
  FToken := toSingleQuotation;
  if not FIsStartToken then
    Inc(FP);
  C := '''';
  while not (FP^ in [#0, #10, #13]) do
  begin
    if FP^ = C then
    begin
      Inc(FP);
      if FP^ <> C then
        Break;
    end;
    if FP^ in LeadBytes then
      Inc(FP);
    Inc(FP);
  end;
end;

procedure TFountainParser.DoubleQuotationProc;
var
  C: Char;
begin
  FToken := toDoubleQuotation;
  if not FIsStartToken then
    Inc(FP);
  C := '"';
  while not (FP^ in [#0, #10, #13]) do
  begin
    if FP^ = C then
    begin
      Inc(FP);
      if FP^ <> C then
        Break;
    end;
    if FP^ in LeadBytes then
      Inc(FP);
    Inc(FP);
  end;
end;

procedure TFountainParser.HexProc;
begin
  FToken := toHex;
  while FP^ in ['0'..'9', 'A'..'F', 'a'..'f'] do
    Inc(FP);
end;

procedure TFountainParser.ReserveWordProc;
begin
  FMethodTable[FP^];
  FToken := toReserve;
end;

procedure TFountainParser.EofProc;
// #0
begin
  FToken := toEof;
end;

procedure TFountainParser.TabProc;
// #9
begin
  FToken := toTab;
  if FP^ = #9 then
    Inc(FP);
end;

procedure TFountainParser.LFProc;
// #10
begin
  FToken := toEof;
  if FP^ = #10 then
    Inc(FP);
end;

procedure TFountainParser.CrProc;
// #13
begin
  FToken := toEof;
  if FP^ = #13 then
  begin
    Inc(FP);
    if FP^ = #10 then
      Inc(FP);
  end;
end;

procedure TFountainParser.IntegerProc;
// '0'..'9'
begin
  FToken := toInteger;
  while FP^ in ['0'..'9'] do
    Inc(FP);
  case FP^ of
    'e', 'E':
      begin
        FToken := toFloat;
        Inc(FP);
        case FP^ of
          '+', '-':
            begin
              Inc(FP);
              while FP^ in ['0'..'9'] do
                Inc(FP);
            end;
          '0'..'9':
            begin
              Inc(FP);
              while FP^ in ['0'..'9'] do
                Inc(FP);
            end;
        end;
      end;
    '.':
      begin
        FToken := toFloat;
        Inc(FP);
        if not (FP^ in ['0'..'9', 'e', 'E']) then
          Dec(FP)
        else
        case FP^ of
          '0'..'9':
            begin
              Inc(FP);
              while FP^ in ['0'..'9'] do
                Inc(FP);
              if FP^ in ['e', 'E'] then
              begin
                Inc(FP);
                case FP^ of
                  '+', '-':
                    begin
                      Inc(FP);
                      while FP^ in ['0'..'9'] do
                        Inc(FP);
                    end;
                  '0'..'9':
                    begin
                      Inc(FP);
                      while FP^ in ['0'..'9'] do
                        Inc(FP);
                    end;
                end;
              end;
            end;
          'e', 'E':
            begin
              Inc(FP);
              case FP^ of
                '+', '-':
                  begin
                    Inc(FP);
                    while FP^ in ['0'..'9'] do
                      Inc(FP);
                  end;
                '0'..'9':
                  begin
                    Inc(FP);
                    while FP^ in ['0'..'9'] do
                      Inc(FP);
                  end;
              end;
            end;
        end;
      end;
  end;
end;

procedure TFountainParser.AnkProc;
// 'A'..'Z', '_', 'a'..'z':
begin
  FToken := toAnk;
  while FP^ in [ '0'..'9', 'A'..'Z', '_', 'a'..'z'] do
    Inc(FP);
end;

procedure TFountainParser.DBSymbolProc;
// #$81, #$84..#$87
// #$83 + #$97..#$F0
// #$82 + #$40..#$4E, #$59..#$5F, #$7A..#$80, #$9B..#$9E, #$F2..#$FF
begin
  FToken := toDBSymbol;
  if (FP^ in [#$81, #$84..#$87]) or
     ((FP^ = #$83) and ((FP + 1)^ in [#$97..#$F0])) or
     ((FP^ = #$82) and ((FP + 1)^ in [#$40..#$4E, #$59..#$5F, #$7A..#$80, #$9B..#$9E, #$F2..#$FF])) then
    Inc(FP, 2);
end;

procedure TFountainParser.DBProc;
// #$82, #$83:
(*
  #$81#$43 '，', #$81#$44 '．', #$81#$5B 'ー', #$81#$7C '－' の扱い

  折り返し表示された行文字列を toDBInt, toDBHira, toDBKana トークン
  としてパースを開始する際、文字列の先頭が上記文字のいずれかの場合
  無視されてしまう仕様なので、これらのトークンを特別扱いする場合は
  折り返された行文字列の先頭にこれらの文字が来ないように Leading
  プロパティを True に設定すること。
*)
begin
  case FP^ of
    #$82:
      begin
        Inc(FP);
        case FP^ of
          #$40..#$4E, #$59..#$5F, #$7A..#$80, #$9B..#$9E, #$F2..#$FF:
            begin
              Inc(FP);
              FToken := toDBSymbol;
            end;
          #$4F..#$58:
            begin
              Inc(FP);
              while ((FP^ in [#$82]) and ((FP + 1)^ in [#$4F..#$58])) or
                    ((FP^ in [#$81]) and ((FP + 1)^ in [#$43..#$44])) do // '，', ' ．'
                Inc(FP, 2);
              FToken := toDBInt;
            end;
          #$60..#$79, #$81..#$9A:
            begin
              Inc(FP);
              while (FP^ in [#$82]) and ((FP + 1)^ in [#$60..#$79, #$81..#$9A]) do
                Inc(FP, 2);
              FToken := toDBAlph;
            end;
          #$9F..#$F1:
            begin
              Inc(FP);
              while ((FP^ in [#$82]) and ((FP + 1)^ in [#$9F..#$F1])) or
                    ((FP^ in [#$81]) and ((FP + 1)^ in [#$5B, #$7C])) do // 'ー', '－'
                Inc(FP, 2);
              FToken := toDBHira;
            end;
        end;
      end;
    #$83:
      begin
        Inc(FP);
        case FP^ of
          #$40..#$96:
            begin
              Inc(FP);
              while ((FP^ in [#$83]) and ((FP + 1)^ in [#$40..#$96])) or
                    ((FP^ in [#$81]) and ((FP + 1)^ in [#$5B, #$7C])) do // 'ー', '－'
                Inc(FP, 2);
              FToken := toDBKana;
            end;
          #$97..#$F0:
            begin
              Inc(FP);
              FToken := toDBSymbol;
            end;
        end;
      end;
  end;
end;

procedure TFountainParser.DBKanjiProc;
// #$88..#$9F,#$E0..#$FC:
begin
  FToken := toDBKanji;
  while FP^ in [#$88..#$9F, #$E0..#$FC] do
  begin
    Inc(FP);
    if FP^ in [#$40..#$FF] then
      Inc(FP);
  end;
end;

procedure TFountainParser.KanaSymbolProc;
// #$A1..#$A5:
begin
  FToken := toKanaSymbol;
  if FP^ in [#$A1..#$A5] then
    Inc(FP);
end;

procedure TFountainParser.KanaProc;
// #$A6..#$DF:
begin
  FToken := toKana;
  while FP^ in [#$A6..#$DF] do
    Inc(FP);
end;

procedure TFountainParser.SymbolProc;
begin
  FToken := toSymbol;
  if not (FP^ in [#0, #10, #13]) then
    Inc(FP);
end;


{ TFountain abstract class }

constructor TFountain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNotifyEventList := CreateNotifyEventList;
  FBrackets := CreateBrackets;
  InitBracketItems;
  FReserveWordList := CreateSortedList;
  InitReserveWordList;
  CreateFountainColors;
end;

destructor TFountain.Destroy;
begin
  FNotifyEventList.Free;
  FBrackets.Free;
  FReserveWordList.Free;
  FReserve.Free;
  inherited Destroy;
end;

function TFountain.CreateParser: TFountainParser;
begin
  Result := ParserClass.Create(Self);
end;

function TFountain.CreateNotifyEventList;
begin
  Result := TNotifyEventList.Create(Self);
end;

function TFountain.CreateBrackets: TFountainBracketCollection;
begin
  Result := TFountainBracketCollection.Create;
  Result.FOwner := Self;
  Result.OnChange := FNotifyEventList.ChangedProc;
end;

function TFountain.CreateFountainColor: TFountainColor;
begin
  Result := TFountainColor.Create;
  Result.OnChange := FNotifyEventList.ChangedProc;
end;

procedure TFountain.CreateFountainColors;
begin
  FReserve := CreateFountainColor;
end;

procedure TFountain.InitBracketItems;
begin
end;

procedure TFountain.InitReserveWordList;
begin
end;

procedure TFountain.SetBrackets(Value: TFountainBracketCollection);
begin
  FBrackets.Assign(Value);
end;

procedure TFountain.SetReserve(Value: TFountainColor);
begin
  FReserve.Assign(Value);
end;

procedure TFountain.SetReserveWordList(Value: TStringList);
begin
  FReserveWordList.Assign(Value);
  FNotifyEventList.ChangedProc(Self);
end;

function TFountain.HasItalicFontStyle(Instance: TPersistent): Boolean;
begin
  FHasItalicFontStyle := False;
  EnumProperties(Instance, tkProperties, ItalicFontStyleProc);
  Result := FHasItalicFontStyle;
end;

procedure TFountain.ItalicFontStyleProc(Instance: TObject; pInfo: PPropInfo;
  tInfo: PTypeInfo);
var
  Info: PPropInfo;
  PropInstance: TObject;
begin
  if tInfo.Kind = tkClass then
  begin
    PropInstance := TObject(GetOrdProp(Instance, pInfo));
    if PropInstance is TFountainColor then
    begin
      Info := GetPropInfo(PropInstance.ClassInfo, 'Style');
      if fsItalic in TFontStyles(Byte(GetOrdProp(PropInstance, Info))) then
        FHasItalicFontStyle := True;
    end;
  end;
end;

procedure TFountain.SameFountainColor(Instance: TPersistent;
  FountainColor: TFountainColor; Operations: TFountainColorOperations);
begin
  FFountainColor := FountainColor;
  FOperations := Operations;
  EnumProperties(Instance, tkProperties, FountainColorProc);
end;

procedure TFountain.FountainColorProc(Instance: TObject; pInfo: PPropInfo;
  tInfo: PTypeInfo);
var
  Info: PPropInfo;
  PropInstance: TObject;
begin
  if tInfo.Kind = tkClass then
  begin
    PropInstance := TObject(GetOrdProp(Instance, pInfo));
    if (PropInstance is TFountainColor) then
    begin
      if coBkColor in FOperations then
      begin
        Info := GetPropInfo(PropInstance.ClassInfo, 'BkColor');
        SetOrdProp(PropInstance, Info, Longint(FFountainColor.BkColor));
      end;
      if coColor in FOperations then
      begin
        Info := GetPropInfo(PropInstance.ClassInfo, 'Color');
        SetOrdProp(PropInstance, Info, Longint(FFountainColor.Color));
      end;
      if coStyle in FOperations then
      begin
        Info := GetPropInfo(PropInstance.ClassInfo, 'Style');
        SetOrdProp(PropInstance, Info, Longint(Byte(FFountainColor.Style)));
      end;
    end;
  end;
end;

initialization
  InitCharMap;
end.
