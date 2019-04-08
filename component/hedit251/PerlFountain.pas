(*********************************************************************

  PerlFountain.pas

  ver 1.03

  start  2001/09/11
  update 2004/02/03

  Copyright (c) 2001 本田勝彦 <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  Perl スクリプトを表示するための TPerlFountain コンポーネントと
  TPerlFountainParser クラス

**********************************************************************)

unit PerlFountain;

{$I heverdef.inc}

interface

uses
  SysUtils, Classes, heClasses, heFountain, heRaStrings, HTMLFountain;

{ TPerlFountainParser special tokens }
const
  {toTagStart              = Char(50);}
  {toTagEnd                = Char(51);}
  {toTagElement            = Char(52);}
  {toTagAttribute          = Char(53);}
  {toTagAttributeDelimiter = Char(54);}
  {toTagAttributeValue     = Char(55);}
  {toAmpersand             = Char(56);}

  toScallarVar       = Char(60);
  toArrayVar         = Char(61);
  toHashVar          = Char(62);
  toBackQuotation    = Char(63);
  toBackSlash        = Char(64);
  toLiteralQuotation = Char(65);
  toPatternMatch     = Char(66);
  toSubstitute1      = Char(67);
  toSubstitute2      = Char(68);
  toTranslitarate1   = Char(69);
  toTranslitarate2   = Char(70);
  toHereDocument     = Char(71);


{ TPerlFountainParser special elements }
const
  {TagBlockElement        = 1;}
  SeekOpenBracketElement = 2;
  HereDocumentElement    = 3;
  PodElement             = 4;

{ TPerlFountainParser special consts }
const
  PerlVarChars     = ['0'..'9', 'A'..'Z', '_', 'a'..'z'];
  ScallarVarChars  = ['!', '"', '#', '$', '%', '&', '''', '(',
                      ')', '*', '+', ',', '-', '.', '/', ':',
                      ';', '<', '=', '>', '?', '@', '[', '\',
                      ']', '^', '_', '`', '|', '~'];
  QuoteChars       = ['!'..'/', ':'..'@', '['..'^', '`', '{'..'~'];
  QuoteElements    = [ 33..47,   58..64,   91..94,  96,  123..126];
  OpenBracketChars = ['(', '<', '[', '{'];
  // BracketChars  = ['(', ')', '<', '>', '[', ']', '{', '}'];
  BracketElements  = [40,  41,  60,  62,  91,  93, 123, 125];
  PatternMatchOptions  = ['i', 'm', 'o', 's', 'x'];
  SubstituteOptions    = ['e', 'g', 'i', 'm', 'o', 's', 'x'];
  TranslitarateOptions = ['c', 'd', 's'];

type
  TPerlFountainParser = class(TFountainParser)
  protected
    // override
    procedure InitMethodTable; override;
    function IncludeTabToken: TCharSet; override;
    function IsReserveWord: Boolean; override;
    procedure NormalTokenProc; override;
    procedure CommenterProc; override;
    procedure DoubleQuotationProc; override;
    procedure IntegerProc; override;
    procedure SingleQuotationProc; override;
    procedure SymbolProc; override;
    // helper method
    function ElementTokens: TCharSet; virtual;
    function HereEndStr(StartPos: PChar): String; virtual;
    function InTag: Boolean; virtual;
    function ReverseDelimiter(C: Char): Char; virtual;
    procedure UpdateToken; virtual;
    // token procedure
    procedure AmpersandProc; virtual;
    procedure AngleBracketProc; virtual;
    procedure AtmarkProc; virtual;
    procedure BackQuotationProc; virtual;
    procedure BackSlashProc; virtual;
    procedure DollerProc; virtual;
    procedure LiteralQuotationProc; virtual;
    procedure PatternMatchProc; virtual;
    procedure PercentProc; virtual;
    procedure SlashProc; virtual;
    procedure SubstituteProc; virtual;
    procedure EqualProc; virtual;
    procedure TagAttributeProc; virtual;
    procedure TagAttributeValueProc; virtual;
    procedure TagElementProc; virtual;
    procedure TagEndProc; virtual;
    procedure TranslitarateProc; virtual;
    procedure TranslitarateYProc; virtual;
  public
    procedure LastTokenBracket(Index: Integer; Strings: TRowAttributeStringList;
      var Data: TRowAttributeData); override;
    function NextToken: Char; override;
    function TokenToFountainColor: TFountainColor; override;
  end;

  TPerlFountain = class(TFountain)
  private
    FAmpersand: TFountainColor;            // &amp
    FAnk: TFountainColor;                  // 半角文字
    FBackQuotation: TFountainColor;        // ``
    FComment: TFountainColor;              // コメント部分
    FDBCS: TFountainColor;                 // 全角文字と半角ｶﾀｶﾅ
    FDoubleQuotation: TFountainColor;      // ""
    FHere: TFountainColor;                 // ヒアドキュメント
    FHereHtml: Boolean;                    // ヒアドキュメント内で HTML タグを認識するしないフラグ
    FInt: TFountainColor;                  // 数値
    FLiteralQuotation: TFountainColor;     // 引用 q//, qq//, qx//, qw//
    FPattern: TFountainColor;              // パターンマッチと置き換え //, m//, qr//, s///, tr///
    FPerlVar: TFountainColor;              // 変数
    FSingleQuotation: TFountainColor;      // ''
    FSymbol: TFountainColor;               // 記号
    FTagAttribute: TFountainColor;         // border
    FTagAttributeValue: TFountainColor;    // = の直後のトークン
    FTagColor: TFountainColor;             // タグ全体
    FTagElement: TFountainColor;           // table /table
    procedure SetAmpersand(Value: TFountainColor);
    procedure SetAnk(Value: TFountainColor);
    procedure SetBackQuotation(Value: TFountainColor);
    procedure SetComment(Value: TFountainColor);
    procedure SetDBCS(Value: TFountainColor);
    procedure SetDoubleQuotation(Value: TFountainColor);
    procedure SetHere(Value: TFountainColor);
    procedure SetHereHtml(Value: Boolean);
    procedure SetInt(Value: TFountainColor);
    procedure SetLiteralQuotation(Value: TFountainColor);
    procedure SetPattern(Value: TFountainColor);
    procedure SetPerlVar(Value: TFountainColor);
    procedure SetSingleQuotation(Value: TFountainColor);
    procedure SetSymbol(Value: TFountainColor);
    procedure SetTagAttribute(Value: TFountainColor);
    procedure SetTagAttributeValue(Value: TFountainColor);
    procedure SetTagColor(Value: TFountainColor);
    procedure SetTagElement(Value: TFountainColor);
  protected
    procedure CreateFountainColors; override;
    function GetParserClass: TFountainParserClass; override;
    procedure InitFileExtList; override;
    procedure InitReserveWordList; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Ampersand: TFountainColor read FAmpersand write SetAmpersand;
    property Ank: TFountainColor read FAnk write SetAnk;
    property BackQuotation: TFountainColor read FBackQuotation write SetBackQuotation;
    property Comment: TFountainColor read FComment write SetComment;
    property DBCS: TFountainColor read FDBCS write SetDBCS;
    property DoubleQuotation: TFountainColor read FDoubleQuotation write SetDoubleQuotation;
    property Here: TFountainColor read FHere write SetHere;
    property HereHtml: Boolean read FHereHtml write SetHereHtml;
    property Int: TFountainColor read FInt write SetInt;
    property LiteralQuotation: TFountainColor read FLiteralQuotation write SetLiteralQuotation;
    property Pattern: TFountainColor read FPattern write SetPattern;
    property PerlVar: TFountainColor read FPerlVar write SetPerlVar;
    property SingleQuotation: TFountainColor read FSingleQuotation write SetSingleQuotation;
    property Symbol: TFountainColor read FSymbol write SetSymbol;
    property TagAttribute: TFountainColor read FTagAttribute write SetTagAttribute;
    property TagAttributeValue: TFountainColor read FTagAttributeValue write SetTagAttributeValue;
    property TagColor: TFountainColor read FTagColor write SetTagColor;
    property TagElement: TFountainColor read FTagElement write SetTagElement;
  end;

procedure Register;

implementation

uses
  heUtils;

procedure Register;
begin
  RegisterComponents('TEditor', [TPerlFountain]);
end;

(*********************************************************************

  トークンの取得方法について

  ■ 追加されたデータフィールド

  ver 2.34 から TRowAttributeData に

    RowAttribute: TRowAttribute;
    PrevRowAttribute: TRowAttribute;
    Remain: Integer;
    DataStr: String;

  のデータフィールドが追加されている。cf heStringList.pas, heRaStrings.pas

  Remain, DataStr は、都合に合わせて利用するフィールドなので、
  基底クラスの TFountainParser.LastTokenBracket メソッドでは、更新処理を
  行っていない。これらのフィールドデータを利用して状態を表現するときは、
  LastTokenBracket メソッドを override して次の行へ状態を受け継ぐ処理を
  行わなければならない。


  ■ '', ``, "" による引用

  '' toSingleQuotation
  TFountainParser.SingleQuotationProc の処理によりたいところだが、
  '''' に対応するルーチンになっているので、SingleQuotationProc を
  override している。FTokenMethodTable は基底クラスで設定されている。

  `` toBackQuotation
  SingleQuotationProc と同様の処理手順による BackQuotationProc を
  実装し、toBackQuotation トークンを取得する。
  ３行以上に渡って折り返し表示されている場合（ WrappedByte = 0 ）のために
  FTokenMethodTable[toBackQuotation] に BackQuotationProc を設定している。

  "" toDoubleQuotation
  \" を処理するので、従来の DoubleQuotationProc では対応出来ない。
  従来の方式で、\ を発見したとき、次の " をスキップさせる方法もあるが、
  タブ文字を含むトークンと成り得るので、WrappedByte の仕組みを利用出来
  ないことから、折り返しによって \" が分断されているとき、次の行の先頭に
  ある " を \", " " のどちらの末尾かを判別する方法が無いからである。

  そこで、" を発見した時点で toDoubleQuotation を返し、FElementIndex を
  " の Ord 値で更新する。以後のパース処理では SymbolProc が " を発見する
  まで、FElementIndex が " の Ord 値である状態で取得したトークンは、
  すべて toDoubleQuotation に変更するという処理を override された
  DoubleQuotationProc, NextToken メソッドと UpdateToken メソッドで行う
  ことにする。

  トークンが折り返されている場合、基底クラスの
  FTokenMethodTable[toDoubleQuotation] の仕組みによって
  DoubleQuotationProc が実行されるが、この時は SymbolProc の処理による
  トークンが toDoubleQuotation に更新される。

  \" は BackSlashProc メソッドで toBackSlash トークンとして扱われるので、
  \" が折り返しによって分断されていても、StartToken, WrappedByte の仕組み
  で対応出来る。

  また、raCrlf な行では、" による引用状態を解除しなければならないので、
  override した LastTokenBracket メソッドでこの処理を行う。

  これらの処理によって、toDoubleQuotation は、タブ文字を含むことが
  なくなるので IncludeTabToken の返値から除外している。

  が、HTML タグ中で取得する toDoubleQuotation は、FElementIndex の
  仕組みを利用出来ないので、従来の取得方式を採用している。
  なので、LastTokenBracket が IncludeTabToken を利用する場面では、
  このことに対応している。ややこしぃ・・・

  タブ文字を含むトークンが toDoubleQuotation に更新されることを防ぐため
  SingleQuotationProc, BackQuotationProc では、FElementIndex の値を
  判別している。

  この FElementIndex を判別する処理は、すべてのトークン取得ルーチンで
  行われている。

  FElementIndex をデリミタの Ord 値で更新してデリミタを発見するまで
  現在のトークンを該当トークンに変換する仕組みを利用するトークンでは、
  FTokenMethodTable の更新を必要としない。デフォルトの SymbolProc
  であることが望ましいからである。


  ■ q//, qq//, qx//, qw// による引用

  q, qq, qx, qw による引用では、toDoubleQuotation と同様の仕組みによって
  トークンを取得し toLiteralQuotation を返す。

  q..qw の後に続く１文字が QuoteChars に含まれている時、toLiteralQuotation
  として処理される。Perl では q..qw と次の１文字の間に空白の存在が許される
  が、TPerlFountainParser では許可していない。

  q..qw の次の１文字（ <, (, [, { の場合は >, ), ], } に変換される）の
  Ord 値を ElementIndex として利用する。

  トークンの終わりは override した SymbolProc で取得する。

  複数行に渡る引用を許可するので、raCrlf な行で初期化する処理は行わない。

  デリミタが BracketChars の場合、ネストにも対処する必要があるが、
  パターンマッチを参照。


  ■ パターンマッチ

  //, m##, m[], qr//imosx
  toLiteralQuotation の仕組みを利用し、toPatternMatch を返すが、デリミタ
  が BracketChars で、それがネストされている場合についても対応しな
  ければならない。

  ネストカウンタには FRemain データフィールドを利用し、パターンマッチの
  トークンを発見した時点で、ネストカウンタを１に初期化する。

  SymbolProc では、該当デリミタが BracketChars のとき、対になる
  デリミタを発見したら、ネストカウンタをインクリメントし、該当デリミタ
  を発見したら、ネストカウンタをデクリメントし、カウンタが０になった時
  真のデリミタであると判断している。

  // の場合、/ の次の１文字が空白でない場合だけ toPatternMatch を
  取得している。


  ■ 置き換え

  s///, s###, s[][]egimosx
  toPatternMatch の処理によるが、トークンを toSubstitute1, toSubstitute2,
  の２つに分けて処理を行う。

  s/, s#, s[ までを取得した時点で、ElementIndex を デリミタの Ord 値で
  更新し、toSubstitue1 を返す。

  次のデリミタを発見した時点で、toSubstitute2 を取得し、FRemain を再度
  １で初期化する。この時、デリミタが BracketChars の場合は FElementIndex
  を SeekOpenBracketElement に更新して、OpenBracketChars (, <, [, { を
  検索する。OpenBracketChars デリミタを発見したら、デリミタをリバース
  して、), >, ], } その Ord 値で FElementIndex を更新する。

  次のデリミタを発見した時点で、処理を終了する。

  tr///, tr###, tr[][], y///, y###, y[][]cds
  toSubstitute1..2 の処理によるが、toTranslitarate1, toTranslitarate2,
  を取得する。


  ■ ヒアドキュメントについて

  << に続く文字列を FDataStr に保持し、FElementIndex を
  HereDocumentElement に設定する。override した LastTokenBracket で
  １行文字列とこの文字列を判別し、ヒアドキュメント状態を解除している。
  HereDocumentElement 状態で取得されるトークンは、下記 HTML タグを除いて
  全部 toHereDocument へ更新される。


  ■ ヒアドキュメント中の HTML タグについて

  ヒアドキュメントとして認識される領域では、

  FElementIndex = HereDocumentElement
  FRemain = 0

  であることが保証されている。cf AngleBracketProc

  この領域内で <, > の中にある状態を FRemain = TagBlockElement とする
  ことで、タグ中のトークンであることを表現する。

  タグの中であることは、
  (FElementIndex = HereDocumentElement) and (FRemain = TagBlockElement)
  で取得出来るが、この判別を行う InTag メソッドが用意されている。

  タグ内では以下のトークンを取得する。

  {toTagStart              = Char(50);} <
  {toTagEnd                = Char(51);} >
  {toTagElement            = Char(52);} table
  {toTagAttribute          = Char(53);} border
  {toTagAttributeDelimiter = Char(54);} =
  {toTagAttributeValue     = Char(55);} 0

  toTagStart, toTagEnd
  ヒアドキュメント内で < を発見した時点で FFountain.HereHtml プロパティが
  True に設定されている場合、toTagStart を取得し、FPrevToken に保持する。
  また FRemain を TagBlockElement に更新し、タグ中状態であることを保持する。
  > を発見した時点で toTagEnd を取得し、FRemain を NormalElementIndex に
  更新する。

  toTagElement
  toTagStart の直後のトークンをすべて UpdateToken メソッドで
  toTagElement に更新する。
  / を処理する SlashProc でも toTagStart の直後かどうかを判別して
  toTagElement を取得している。
  折り返し表示されている場合にも対応するために、FTokenMethodTable を
  更新する。

  toTagAttribute
  UpdateToken メソッドで、FPrevToken の値に応じて現在のトークンを更新する
  ことによって取得する。
  case FPrevToken of
    toTagStart:
      toAnk -> toTagElement
    toDoubleQuotation, toSingleQuotation, toTagElement, toTagAttributeValue:
      全部 -> toTagAttribute; (*1)
    toTagAttribute:
      非 toTagAttributeDelimiter -> toTagAttribute; (*2)
  end;
  折り返し表示されている場合にも対応するために、FTokenMethodTable を
  更新する。

  toTagAttributeDelimiter
  = を処理する EqualProc でタグ中にある場合だけ取得される。

  toTagAttributeValue
  FPrevToken が TagAttributeDelimiter の場合はすべて toTagAttributeValue
  に更新する処理を override した NormalTokenProc で行う。
  折り返し表示されている場合にも対応するために、FTokenMethodTable を
  更新する。


  ■ ヒアドキュメント中の &amp; について

  toAmpersand
  & を処理する AmpersandProc では、ヒアドキュメントの中にあって、
  FFountain.HereHtml プロパティが True に設定されている場合、
  toAmpersand を取得している。
  折り返し表示されている場合にも対応するために、FTokenMethodTable を
  更新する。


  ■ pod について

  = を処理する EqualProc で NormalElementIndex 状態かつ、行頭に = が
  ある時、head1, head2, item, over, back, pod, for, begin, end の語句が
  続いている場合に FElementIndex を PodElement に更新してから、
  CommenterProc を実行し toComment を取得する。
  PodElement 状態の場合は、行頭の =cut を判別し、NormalElementIndex 状態
  に戻してから CommenterProc を実行し toComment を取得する。
  UpdateToken メソッドでは PodElement 状態で取得したトークンをすべて
  toComment に更新している。

debug
  フォーマット
  内部関数
  ファイルテスト演算子
  特殊変数
    
**********************************************************************)


{ TPerlFountainParser }

procedure TPerlFountainParser.InitMethodTable;
begin
  inherited InitMethodTable;
  // FMethodTable
  FMethodTable['"'] := DoubleQuotationProc;
  FMethodTable['#'] := CommenterProc;
  FMethodTable['$'] := DollerProc;
  FMethodTable['%'] := PercentProc;
  FMethodTable['&'] := AmpersandProc;
  FMethodTable[#39] := SingleQuotationProc;
  FMethodTable['/'] := SlashProc;
  FMethodTable['<'] := AngleBracketProc;
  FMethodTable['='] := EqualProc;
  FMethodTable['>'] := TagEndProc;
  FMethodTable['@'] := AtmarkProc;
  FMethodTable['\'] := BackSlashProc;
  FMethodTable['`'] := BackQuotationProc;
  FMethodTable['m'] := PatternMatchProc;
  FMethodTable['q'] := LiteralQuotationProc;
  FMethodTable['s'] := SubstituteProc;
  FMethodTable['t'] := TranslitarateProc;
  FMethodTable['y'] := TranslitarateYProc;
  // FTokenMethodTable
  FTokenMethodTable[toTagElement] := TagElementProc;
  FTokenMethodTable[toTagAttribute] := TagAttributeProc;
  FTokenMethodTable[toTagAttributeValue] := TagAttributeValueProc;
  FTokenMethodTable[toAmpersand] := AmpersandProc;
  FTokenMethodTable[toBackQuotation] := BackQuotationProc;
end;

procedure TPerlFountainParser.DollerProc;
// $
begin
  if FElementIndex = NormalElementIndex then
  begin
    if (FP + 1)^ in PerlVarChars then
    begin
      FToken := toScallarVar;
      Inc(FP);
      if FP^ in ['0'..'9'] then
      begin
        Inc(FP);
        while FP^ in ['0'..'9'] do
          Inc(FP);
      end
      else
      begin
        Inc(FP);
        while FP^ in PerlVarChars do
          Inc(FP);
      end;
    end
    else
      if (FP + 1)^ in ScallarVarChars then
      begin
        FToken := toScallarVar;
        Inc(FP, 2);
      end
      else
        SymbolProc;
  end
  else
    SymbolProc;
end;

procedure TPerlFountainParser.PercentProc;
// %
begin
  if FElementIndex = NormalElementIndex then
  begin
    if (FP + 1)^ in PerlVarChars then
    begin
      FToken := toHashVar;
      Inc(FP);
      if FP^ in ['0'..'9'] then
      begin
        Inc(FP);
        while FP^ in ['0'..'9'] do
          Inc(FP);
      end
      else
      begin
        Inc(FP);
        while FP^ in PerlVarChars do
          Inc(FP);
      end;
    end
    else
      SymbolProc;
  end
  else
    SymbolProc;
end;

procedure TPerlFountainParser.AtmarkProc;
// @
begin
  if FElementIndex = NormalElementIndex then
  begin
    if (FP + 1)^ in PerlVarChars then
    begin
      FToken := toArrayVar;
      Inc(FP);
      if FP^ in ['0'..'9'] then
      begin
        Inc(FP);
        while FP^ in ['0'..'9'] do
          Inc(FP);
      end
      else
      begin
        Inc(FP);
        while FP^ in PerlVarChars do
          Inc(FP);
      end;
    end
    else
      SymbolProc;
  end
  else
    SymbolProc;
end;

procedure TPerlFountainParser.CommenterProc;
// #
begin
  if FElementIndex = NormalElementIndex then
  begin
    FToken := toComment;
    while not (FP^ in [#0, #10, #13]) do
      Inc(FP);
  end
  else
    SymbolProc;
end;

procedure TPerlFountainParser.BackSlashProc;
// \
begin
  if (FP + 1)^ in ['!'..'~'] then
  begin
    FToken := toBackSlash;
    Inc(FP);
    case FP^ of
      '0': // ８進数
        begin
          Inc(FP);
          while FP^ in ['0'..'7'] do
            Inc(FP);
        end;
      'x': // １６進数
        begin
          Inc(FP);
          while FP^ in ['A'..'F', '0'..'9', 'a'..'f'] do
            Inc(FP);
        end;
      // 'c': control code debug
    else
      Inc(FP);
    end;
  end
  else
    SymbolProc;
end;

procedure TPerlFountainParser.DoubleQuotationProc;
// "
var
  C: Char;
begin
  if FElementIndex = NormalElementIndex then
  begin
    // StartToken が toDoubleQuotation の時は、SymbolProc で処理される。
    Inc(FP);
    FToken := toDoubleQuotation;
    FElementIndex := Ord('"');
    FRemain := 1;
  end
  else
    if InTag then
    begin
      // HTML タグの中
      // StartToken が toDoubleQuotation の場合もここで処理される。
      FToken := toDoubleQuotation;
      if not FIsStartToken then
        Inc(FP);
      C := '"';
      while not (FP^ in [#0, #10, #13]) do
      begin
        if FP^ = C then
        begin
          Inc(FP);
          Break;
        end;
        if FP^ in LeadBytes then
          Inc(FP);
        Inc(FP);
      end;
    end
    else
      SymbolProc;
end;

procedure TPerlFountainParser.IntegerProc;
// 0..9
begin
  if (FP^ = '0') and ((FP + 1)^ = 'x') then
  begin
    Inc(FP, 2);
    HexProc;
  end
  else
    inherited IntegerProc;
end;

procedure TPerlFountainParser.SingleQuotationProc;
// '
var
  C: Char;
begin
  if (FElementIndex = NormalElementIndex) or InTag then
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
        Break;
      end;
      if FP^ in LeadBytes then
        Inc(FP);
      Inc(FP);
    end;
  end
  else
    SymbolProc;
end;

procedure TPerlFountainParser.BackQuotationProc;
// `
var
  C: Char;
begin
  if FElementIndex = NormalElementIndex then
  begin
    FToken := toBackQuotation;
    if not FIsStartToken then
      Inc(FP);
    C := '`';
    while not (FP^ in [#0, #10, #13]) do
    begin
      if FP^ = C then
      begin
        Inc(FP);
        Break;
      end;
      if FP^ in LeadBytes then
        Inc(FP);
      Inc(FP);
    end;
  end
  else
    SymbolProc;
end;

function TPerlFountainParser.HereEndStr(StartPos: PChar): String;
var
  Ps, P: PChar;
begin
  // StartPos は２つ目の < の次の文字を指している
  Result := '';
  if (StartPos^ < ' ') then
    Exit;
  Ps := StartPos;
  while Ps^ in ['"', '''', '`'] do
    Inc(Ps);
  P := Ps;
  while P^ in PerlVarChars do
    Inc(P);
  SetString(Result, Ps, P - Ps);
end;

procedure TPerlFountainParser.AngleBracketProc;
// <
var
  Ps, P: PChar;
begin
  if (FElementIndex = NormalElementIndex) and
     ((FP + 1)^ = '<') and
     not ((FP + 2)^ in [#0, #10, #13, '<']) then
  begin
    // ヒアドキュメントかどうかの判別

    // debug << 演算子を無視している。

    Ps := FP + 2; // ２つ目の < の次の文字を指している
    P := Ps;
    while not (P^ in [#0, #10, #13]) do
    begin
      Inc(P);
      if (P^ = ';') and ((P + 1)^ in [#0, #10, #13]) then
      begin
        // トークンの末尾が ; である
        FDataStr := HereEndStr(Ps);
        FP := P + 1;
        FToken := toHereDocument;
        FElementIndex := HereDocumentElement;
        FRemain := NormalElementIndex;
        Exit;
      end;
    end;
    SymbolProc;
  end
  else
    // HTML タグかどうかの判別を行う。
    if (FElementIndex = HereDocumentElement) and // InTag ではない
       TPerlFountain(FFountain).HereHtml then
    begin
      FToken := toTagStart;
      Inc(FP);
      FRemain := TagBlockElement;
    end
    else
      SymbolProc;
end;

function TPerlFountainParser.InTag: Boolean;
begin
  Result := (FElementIndex = HereDocumentElement) and
            (FRemain = TagBlockElement);
end;

procedure TPerlFountainParser.TagEndProc;
// >
begin
  if InTag then
  begin
    FToken := toTagEnd;
    Inc(FP);
    FRemain := NormalElementIndex;
  end
  else
    SymbolProc;
end;

procedure TPerlFountainParser.TagElementProc;
// FStartToken = toTagElement, FWrappedByte = 0 の時に実行される
begin
  AnkProc;
  FToken := toTagElement;
end;

procedure TPerlFountainParser.TagAttributeProc;
// FStartToken = toTagAttribute, FWrappedByte = 0 の時に実行される
begin
  AnkProc;
  FToken := toTagAttribute;
end;

procedure TPerlFountainParser.EqualProc;
// =
begin
  if InTag and (FPrevToken = toTagAttribute) then
  begin
    FToken := toTagAttributeDelimiter;
    Inc(FP);
  end
  else
    if (SourcePos = 0) and
       (FPrevRowAttribute <> raWrapped) then
    begin
      Inc(FP);
      if (FElementIndex = NormalElementIndex) and
         (FP^ in ['b', 'e', 'f', 'h', 'i', 'o', 'p']) then
      begin
        if IsKeyWord('head1') or
           IsKeyWord('head2') or
           IsKeyWord('over') or
           IsKeyWord('item') or
           IsKeyWord('back') or
           IsKeyWord('for') or
           IsKeyWord('begin') or
           IsKeyWord('end') or
           IsKeyWord('pod') then
        begin
          FElementIndex := PodElement;
          CommenterProc;
        end
        else
          FToken := toSymbol;
      end
      else
        if (FElementIndex = PodElement) and
           IsKeyWord('cut') then
        begin
          FElementIndex := NormalElementIndex;
          CommenterProc;
        end
        else
          FToken := toSymbol;
    end
    else
      SymbolProc;
end;

procedure TPerlFountainParser.TagAttributeValueProc;
(*
  直前のトークンが toTagAttributeDelimiter の場合実行される。
  border="0", border='0' のように ", ' で始まっている場合は、
  toDoubleQuotation, toSingleQuotation を取得する。
  FStartToken = toTagAttributeValue, FWrappedByte = 0 の時にも実行される。
*)
begin
  case FP^ of
    '"':
      DoubleQuotationProc;
    '''':
      SingleQuotationProc;
  else
    FToken := toTagAttributeValue;
    while not (FP^ in [#0, #9, #10, #13, #32, '>']) do
      Inc(FP);
  end;
end;

procedure TPerlFountainParser.AmpersandProc;
// & FStartToken = toAmpersand, FWrappedByte = 0 の時にも実行される。
begin
  if (FElementIndex = HereDocumentElement) and
     TPerlFountain(FFountain).HereHtml then // if InTag then ではない
  begin
    // ヒアドキュメント内での処理
    FToken := toAmpersand;
    if not FIsStartToken then
      Inc(FP);
    while FP^ in ['#', '0'..'9', 'A'..'Z', 'a'..'z'] do
    begin
      Inc(FP);
      if FP^ = ';' then
      begin
        Inc(FP);
        Break;
      end;
    end;
  end
  else
    if (FP + 1)^ in PerlVarChars then
    begin
      // サブルーチン呼び出し
      Inc(FP);
      while FP^ in PerlVarChars do
        Inc(FP);
      if FP^ = #39 then // Perl 4 style
        Inc(FP);
      FToken := toAnk;
    end
    else
      SymbolProc;
end;

procedure TPerlFountainParser.LiteralQuotationProc;
// q
begin
  if (FElementIndex = NormalElementIndex) and
     (((FP + 1)^ in QuoteChars) or
      (((FP + 1)^ in ['q', 'r', 'x', 'w']) and ((FP + 2)^ in QuoteChars))) then
  begin
    if (FP + 1)^ = 'r' then
      FToken := toPatternMatch
    else
      FToken := toLiteralQuotation;
    while not (FP^ in QuoteChars) do // skip [q, r, x, w]
      Inc(FP);
    FElementIndex := Ord(ReverseDelimiter(FP^));
    FRemain := 1;
    Inc(FP);
  end
  else
    AnkProc;
end;

procedure TPerlFountainParser.SlashProc;
// /
begin
  if (FElementIndex = NormalElementIndex) and
     ((FP + 1)^ <> ' ') then
  begin
    Inc(FP);
    FToken := toPatternMatch;
    FElementIndex := Ord('/');
    FRemain := 1;
  end
  else
    if InTag and (FPrevToken = toTagStart) then
    begin
      FToken := toTagElement;
      Inc(FP);
      while FP^ in [ '0'..'9', 'A'..'Z', 'a'..'z'] do // AnkProc - ['_']
        Inc(FP);
    end
    else
      SymbolProc;
end;

procedure TPerlFountainParser.PatternMatchProc;
// m
var
  C: Char;
begin
  if (FElementIndex = NormalElementIndex) and
     ((FP + 1)^ in QuoteChars) then
  begin
    C := (FP + 1)^;
    FElementIndex := Ord(ReverseDelimiter(C));
    FRemain := 1;
    FToken := toPatternMatch;
    Inc(FP, 2);
  end
  else
    AnkProc;
end;

procedure TPerlFountainParser.SubstituteProc;
// s
var
  C: Char;
begin
  if (FElementIndex = NormalElementIndex) and
     ((FP + 1)^ in QuoteChars) then
  begin
    C := (FP + 1)^;
    FElementIndex := Ord(ReverseDelimiter(C));
    FRemain := 1;
    FToken := toSubstitute1;
    Inc(FP, 2);
  end
  else
    AnkProc;
end;

procedure TPerlFountainParser.TranslitarateProc;
// t
var
  C: Char;
begin
  if (FElementIndex = NormalElementIndex) and
     ((FP + 1)^ = 'r') and
     ((FP + 2)^ in QuoteChars) then
  begin
    C := (FP + 2)^;
    FElementIndex := Ord(ReverseDelimiter(C));
    FRemain := 1;
    FToken := toTranslitarate1;
    Inc(FP, 3);
  end
  else
    AnkProc;
end;

procedure TPerlFountainParser.TranslitarateYProc;
// y
var
  C: Char;
begin
  if (FElementIndex = NormalElementIndex) and
     ((FP + 1)^ in QuoteChars) then
  begin
    C := (FP + 1)^;
    FElementIndex := Ord(ReverseDelimiter(C));
    FRemain := 1;
    FToken := toTransLitarate1;
    Inc(FP, 2);
  end
  else
    AnkProc;
end;

function TPerlFountainParser.ReverseDelimiter(C: Char): Char;
begin
  case C of
    '<': Result := '>';
    '(': Result := ')';
    '[': Result := ']';
    '{': Result := '}';
    '>': Result := '<';
    ')': Result := '(';
    ']': Result := '[';
    '}': Result := '{';
  else
    Result := C;
  end;
end;

function TPerlFountainParser.IncludeTabToken: TCharSet;
(*
  TPerlFountainParser の toDoubleQuotation はタブ文字を含む文字列が取得
  されることはないので、除外する。
*)
begin
  Result := [toComment, toSingleQuotation, toBackQuotation];
end;

function TPerlFountainParser.ElementTokens: TCharSet;
(*
  デリミタの Ord 値を FElementIndex へ格納してトークンを取得する仕組みを
  利用するトークンの集合を返す。
*)
begin
  Result := [toDoubleQuotation, toLiteralQuotation, toPatternMatch,
             toSubstitute1, toSubstitute2,
             toTranslitarate1, toTranslitarate2];
end;

function TPerlFountainParser.NextToken: Char;
begin
  inherited NextToken;
  UpdateToken;
  if FToken <> toEof then
    FPrevToken := FToken;
  Result := FToken;
end;

procedure TPerlFountainParser.UpdateToken;
begin
  if FToken <> toEof then
  begin
    if (FElementIndex in QuoteElements + [SeekOpenBracketElement]) and
       not (FToken in ElementTokens) and
       (FPrevToken in ElementTokens) then
      // QuoteElements を利用するトークンの処理 cf SymbolProc
      FToken := FPrevToken
    else
      if InTag then
      begin
        // HTML タグの中での処理
        case FPrevToken of
          toTagStart:
            if FToken = toAnk then
              FToken := toTagElement;
          toDoubleQuotation, toSingleQuotation, toTagElement, toTagAttributeValue:
            FToken := toTagAttribute;
          toTagAttribute:
            if FToken <> toTagAttributeDelimiter then
              FToken := toTagAttribute;
        end;
      end
      else
        if (FElementIndex = HereDocumentElement) and
           not (FToken in [toTagEnd, toAmpersand]) then
          // ヒアドキュメント内
          FToken := toHereDocument
        else
          if FElementIndex = PodElement then
            // pod 内
            FToken := toComment;
  end;
end;

procedure TPerlFountainParser.NormalTokenProc;
begin
  if (FBracketIndex = NormalBracketIndex) and IsBracketProc then
    BracketProc
  else
    if InTag and (FPrevToken = toTagAttributeDelimiter) then
      TagAttributeValueProc
    else
      FMethodTable[FP^];
end;

procedure TPerlFountainParser.SymbolProc;
var
  IsBracketDelimiter: Boolean;
begin
  if FElementIndex = SeekOpenBracketElement then
  begin
    // s[][], tr[][]
    //    ^       ^  を探している状態
    if FP^ in OpenBracketChars then
    begin
      FElementIndex := Ord(ReverseDelimiter(FP^));
      FRemain := 1;
      Inc(FP);
      FToken := FPrevToken;
    end
    else
      inherited SymbolProc;
  end
  else
    if FElementIndex in QuoteElements then
    begin
      IsBracketDelimiter := FElementIndex in BracketElements;
      if IsBracketDelimiter and
         (FP^ = ReverseDelimiter(Chr(FElementIndex))) then
      begin
        // ネストカウンタをインクリメントする
        Inc(FRemain);
        inherited SymbolProc;
      end
      else
        if FP^ = Chr(FElementIndex) then
        begin
          // 該当デリミタを発見した
          Dec(FRemain);
          if FRemain = 0 then
            case FPrevToken of
              toSubstitute1, toTranslitarate1:
                begin
                  // s/ / /, s[][], tr/ / /, tr[][]
                  //    ^      ^        ^       ^   を発見した状態
                  if IsBracketDelimiter then
                    FElementIndex := SeekOpenBracketElement;
                  FRemain := 1;
                  Inc(FP);
                  case FPrevToken of
                    toSubstitute1:
                      FToken := toSubstitute2;
                    toTranslitarate1:
                      FToken := toTransLitarate2;
                  end;
                end;
              toSubstitute2, toTranslitarate2:
                begin
                  // s/ / /, s[][], tr/ / /, tr[][]
                  //      ^      ^        ^       ^ を発見した状態
                  FElementIndex := NormalElementIndex;
                  Inc(FP);
                  FToken := FPrevToken;
                  case FToken of
                    toSubstitute2:
                      while FP^ in SubstituteOptions do
                        Inc(FP);
                    toTranslitarate2:
                      while FP^ in TranslitarateOptions do
                        Inc(FP);
                  end;
                end;
            else
              FElementIndex := NormalElementIndex;
              Inc(FP);
              FToken := FPrevToken;
              if FToken = toPatternMatch then
                while FP^ in PatternMatchOptions do
                  Inc(FP);
            end
          else
            inherited SymbolProc;
        end
        else
        begin
          // StartToken が toDoubleQuotation の時、ここで処理されるので
          // 全角文字に対応する
          FToken := toSymbol;
          if FP^ in LeadBytes then
            Inc(FP);
          if not (FP^ in [#0, #10, #13]) then
            Inc(FP);
        end;
    end
    else
      inherited SymbolProc;
end;

function TPerlFountainParser.IsReserveWord: Boolean;
begin
  Result := (FElementIndex = NormalElementIndex) and
            inherited IsReserveWord;
end;

procedure TPerlFountainParser.LastTokenBracket(Index: Integer;
  Strings: TRowAttributeStringList; var Data: TRowAttributeData);
var
  S: String;
  L1, L2, P, B, E, I: Integer;
  TempToken: Char;
  SpaceOnly: Boolean;
begin

  //////////////////////////////////////////////////
  // ヒアドキュメント状態の解除
  if (Data.ElementIndex = HereDocumentElement) and
     (Data.PrevRowAttribute = raCrlf) and
     (Data.RowAttribute = raCrlf) and
     (Strings[Index] = Data.DataStr) then
  begin
    Data.ElementIndex := NormalElementIndex;
    Data.DataStr := '';
    Exit;
  end;
  //////////////////////////////////////////////////

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

      //////////////////////////////////////////////////
      //  Data.Remain の更新
      //  FRemain は BracketChars のネストに対応するために利用されて
      //  いる。
      // m[[[[[]]]< // 折り返し
      // ]]
      // を処理する場合、ここでの S には、m[[[[[]]]]] が格納されていること
      // から、パースが終了した時点での FRemain が０になってしまうので、
      // SourcePos < L1 の時点での FRemain で Data.Remain を更新する。
      if SourcePos < L1 then
        Data.Remain := FRemain;
      //////////////////////////////////////////////////

      if SourcePos + TokenLength > L1 then
        Break;
      Data.ElementIndex := FElementIndex;
      Data.PrevToken := FPrevToken;
    end;
    // ブレークした時点での処理
    Data.WrappedByte := 0;
    Data.StartToken := toEof;

    //////////////////////////////////////////////////
    // Data.DataStr の更新
    Data.DataStr := FDataStr;
    //////////////////////////////////////////////////

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

            //////////////////////////////////////////////////
            // InTag 中の toDoubleQuotation を除外する処理を追加
            if not (TempToken in IncludeTabToken) and
               not ((TempToken = toDoubleQuotation) and InTag) and // *
               ((P < L2) or (Strings.Rows[Index + 1] <> raWrapped)) then
              Data.WrappedByte := SourcePos + TokenLength - L1;
            //////////////////////////////////////////////////
          end;
      end;
    end;
  end;

  //////////////////////////////////////////////////
  // 改行による引用状態の解除。
  // 複数行に渡って " による引用が許されるのであれば不必要な処理。
  if (TempToken = toDoubleQuotation) and
     (Data.ElementIndex = Ord('"')) and
     (Strings.Rows[Index] = raCrlf) then
  begin
    Data.ElementIndex := NormalElementIndex;
    Data.Remain := 0;
  end;
  //////////////////////////////////////////////////

end;

function TPerlFountainParser.TokenToFountainColor: TFountainColor;
begin
  with TPerlFountain(FFountain) do
    if IsReserveWord then
      Result := Reserve
    else
      case FToken of
        toSymbol:
          Result := FSymbol;
        toInteger, toFloat, toHex:
          Result := FInt;
        toBracket:
          Result := Brackets[FDrawBracketIndex].ItemColor;
        toComment:
          Result := FComment;
        toReserve:
          Result := Reserve;
        toAnk:
          Result := FAnk;
        toDBSymbol, toDBInt, toDBAlph, toDBHira, toDBKana, toDBKanji, toKanaSymbol, toKana:
          Result := FDBCS;
        toSingleQuotation:
          Result := FSingleQuotation;
        toDoubleQuotation:
          Result := FDoubleQuotation;
        toTagStart, toTagEnd, toTagAttributeDelimiter:
          Result := FTagColor;
        toTagElement:
          Result := FTagElement;
        toTagAttribute:
          Result := FTagAttribute;
        toTagAttributeValue:
          Result := FTagAttributeValue;
        toAmpersand:
          Result := FAmpersand;
        toScallarVar, toArrayVar, toHashVar:
          Result := FPerlVar;
        toBackQuotation:
          Result := FBackQuotation;
        toLiteralQuotation:
          Result := FLiteralQuotation;
        toPatternMatch, toSubstitute1, toSubstitute2, toTranslitarate1, toTranslitarate2:
          Result := FPattern;
        toHereDocument:
          Result := FHere;
      else
        Result := nil;
      end;
end;


{ TPerlFountain }

constructor TPerlFountain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHereHtml := True;
end;

destructor TPerlFountain.Destroy;
begin
  FAnk.Free;
  FBackQuotation.Free;
  FComment.Free;
  FDBCS.Free;
  FDoubleQuotation.Free;
  FHere.Free;
  FInt.Free;
  FPattern.Free;
  FPerlVar.Free;
  FLiteralQuotation.Free;
  FSingleQuotation.Free;
  FSymbol.Free;
  FAmpersand.Free;
  FTagAttribute.Free;
  FTagAttributeValue.Free;
  FTagColor.Free;
  FTagElement.Free;
  inherited Destroy;
end;

procedure TPerlFountain.CreateFountainColors;
begin
  inherited CreateFountainColors;
  FAnk := CreateFountainColor;
  FBackQuotation := CreateFountainColor;
  FComment := CreateFountainColor;
  FDBCS := CreateFountainColor;
  FDoubleQuotation := CreateFountainColor;
  FHere := CreateFountainColor;
  FInt := CreateFountainColor;
  FPattern := CreateFountainColor;
  FPerlVar := CreateFountainColor;
  FLiteralQuotation := CreateFountainColor;
  FSingleQuotation := CreateFountainColor;
  FSymbol := CreateFountainColor;
  FAmpersand := CreateFountainColor;
  FTagAttribute := CreateFountainColor;
  FTagAttributeValue := CreateFountainColor;
  FTagColor := CreateFountainColor;
  FTagElement := CreateFountainColor;
end;

procedure TPerlFountain.SetAnk(Value: TFountainColor);
begin
  FAnk.Assign(Value);
end;

procedure TPerlFountain.SetBackQuotation(Value: TFountainColor);
begin
  FBackQuotation.Assign(Value);
end;

procedure TPerlFountain.SetComment(Value: TFountainColor);
begin
  FComment.Assign(Value);
end;

procedure TPerlFountain.SetDBCS(Value: TFountainColor);
begin
  FDBCS.Assign(Value);
end;

procedure TPerlFountain.SetDoubleQuotation(Value: TFountainColor);
begin
  FDoubleQuotation.Assign(Value);
end;

procedure TPerlFountain.SetHereHtml(Value: Boolean);
begin
  if FHereHtml <> Value then
  begin
    FHereHtml := Value;
    if not (csLoading in ComponentState) and
       not (csDestroying in ComponentState) then
      NotifyEventList.ChangedProc(Self);
  end;
end;

procedure TPerlFountain.SetHere(Value: TFountainColor);
begin
  FHere.Assign(Value);
end;

procedure TPerlFountain.SetInt(Value: TFountainColor);
begin
  FInt.Assign(Value);
end;

procedure TPerlFountain.SetPattern(Value: TFountainColor);
begin
  FPattern.Assign(Value);
end;

procedure TPerlFountain.SetPerlVar(Value: TFountainColor);
begin
  FPerlVar.Assign(Value);
end;

procedure TPerlFountain.SetLiteralQuotation(Value: TFountainColor);
begin
  FLiteralQuotation.Assign(Value);
end;

procedure TPerlFountain.SetSingleQuotation(Value: TFountainColor);
begin
  FSingleQuotation.Assign(Value);
end;

procedure TPerlFountain.SetSymbol(Value: TFountainColor);
begin
  FSymbol.Assign(Value);
end;

procedure TPerlFountain.SetAmpersand(Value: TFountainColor);
begin
  FAmpersand.Assign(Value);
end;

procedure TPerlFountain.SetTagAttribute(Value: TFountainColor);
begin
  FTagAttribute.Assign(Value);
end;

procedure TPerlFountain.SetTagAttributeValue(Value: TFountainColor);
begin
  FTagAttributeValue.Assign(Value);
end;

procedure TPerlFountain.SetTagColor(Value: TFountainColor);
begin
  FTagColor.Assign(Value);
end;

procedure TPerlFountain.SetTagElement(Value: TFountainColor);
begin
  FTagElement.Assign(Value);
end;

function TPerlFountain.GetParserClass: TFountainParserClass;
begin
  Result := TPerlFountainParser;
end;

procedure TPerlFountain.InitFileExtList;
begin
  with FileExtList do
  begin
    Add('.cgi');
    Add('.pl');
    Add('.pm');
    Add('.pod');
  end;
end;

procedure TPerlFountain.InitReserveWordList;
begin
  with ReserveWordList do
  begin
    Add('cmp');
    Add('do');
    Add('else');
    Add('elsif');
    Add('eq');
    Add('for');
    Add('foreach');
    Add('ge');
    Add('gt');
    Add('if');
    Add('le');
    Add('lt');
    Add('ne');
    Add('package');
    Add('require');
    Add('return');
    Add('sub');
    Add('unless');
    Add('until');
    Add('use');
    Add('while');
  end;
end;

end.

