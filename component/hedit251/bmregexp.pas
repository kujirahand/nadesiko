unit bmRegExp;
{******************************************************************************
タイトル      ：正規表現を使った文字列探索/操作コンポーネント集ver0.17
ユニット名    ：bmRegExp.pas
バージョン    ：version 0.17
日付          ：2001/09/15
動作確認環境  ：  Windows 98 + Borland Delphi6 Japanese Personal edition
作者          ：  峯島 bmonkey 雄治  ggb01164@nifty.ne.jp
変更履歴      ：  0.17    バグ修正 2001/09/15
              ：    ・MP3の魔術師さんに教えて頂いたメモリリークの修正を適用。
              ：    ・おかぽんさんに教えて頂いたメモリリークの修正を適用。
              ：    詳細は同梱のchangelog.htmlを参照。
              ：  0.16    第二次 一般公開 1998/03/07
              ：    version 0.15 -> version 0.16
              ：    ・TGrepで英大文字/小文字が正しく検索できなかったバグを修正。
              ：    ・漢字のキャラクタクラス指定([亜-熙]など)のバグを修正。
              ：    ・Delphi3, C++Builder1に対応
              ：        ・ユニットファイル名をRegExp.pasからbmRegExp.pasに変更
              ：        ・コンパイラの厳しくなった型チェックに対応
              ：        ・MBUtils.pasを使わないように変更。
              ：  0.15B   バグ修正、Delphi3、C++Builder1対応
              ：  0.15    一般公開
主要クラス    ：  TGrep, TAWKStr
継承関係      ：  TObject

*******************************************************************************
使用方法      ：ヘルプファイルとサンプルプロジェクトを参照のこと
補足説明      ：

定義型        ：

******************************************************************************}

interface

uses
  SysUtils, Classes, Windows, Forms
{$IFDEF DEBUG}
  ,OutLine
{$ENDIF}
  ;

type
{ -========================== 例外クラス =====================================-}
{TREParser が出す例外。
 ErrorPos によって、正規表現文字列の何文字目で例外が発生したかを示す。}
  ERegExpParser = class(Exception)
  public
    ErrorPos: Integer;
    constructor Create(const Msg: string; ErrorPosition: Word);
  end;
{-=============================                          ====================-}
{ ２バイト文字型}
  WChar_t = Word;

{ ２バイト文字型へのポインタ型}
  PWChar_t = ^WChar_t;

{ WChar_t型 ２つぶんの型}
  DoubleWChar_t = Integer;

{ -====================== 文字列操作関数 =====================================-}
  {説明 ：  １６進数を表す文字を受け取り、整数にして返す。
   引数 ：  WCh: WChar_t;     16進数を表す1バイト文字 [0-9a-fA-F]

   返り値： 正常時：  0 <= result <= 15
            異常時：  -1}
  function HexWCharToInt(WCh: WChar_t): Integer;

  {説明 ：  ８進数を表す文字を受け取り、整数にして返す。
   引数 ：  WCh: WChar_t;     8進数を表す1バイト文字 [0-7]

   返り値： 正常時：  0 <= result <= 7
            異常時：  -1}
  function OctWCharToInt(WCh: WChar_t): Integer;

  {説明 ：  16進数表記の文字列をWord型の数値に変換する。
  引数  ：  Str: String     変換元の文字列
            Index: Integer  引数StrのIndex番目のバイト位置から変換を始める。
  副作用：  処理したバイト数だけIndexがインクリメントされる。
  返り値：  文字列が表すWord型の値}
  function HexStrToInt(const Str: String; var Index: Integer): Word;

  {説明 ：  ８進数表記の文字列をWord型の数値に変換する。
  引数  ：  Str: String     変換元の文字列
            Index: Integer  引数StrのIndex番目のバイト位置から変換を始める。
  副作用：  処理したバイト数だけIndexがインクリメントされる。
  返り値：  文字列が表すWord型の値}
  function OctStrToInt(const Str: String; var Index: Integer): Word;

  {説明 ： 引数Strから１文字読み出す。
  動作  ： 引数Str の中の引数Index番目のバイト位置から１文字得て、Indexを増やす。
  引数  ： Str:    String;    ２バイト文字コードを含んだString
           Index:  Integer;   文字を読み出す位置の先頭からのバイト数
  返り値： 読み出した WChar_t型の値
  副作用：
  注意  ： Indexが文字列の長さよりすでに長い場合は常に WChType.Nullを返し、Indexを増やさない。
          つまり、Indexは最大でも Length(Str)+1 である。}
  function GetWChar(const Str: String;var Index: Integer): WChar_t;

  {機能： GetWCharメソッドによって進んだ Indexを１文字分戻す(1～２バイト)
   注意： ヌル・キャラクタ(GetWCharの返り値 WChType.Null)を戻すことはできない。}
  procedure UnGetWChar(const Str: String; var Index: Integer);


  {機能： GetWCharのPChar型バージョン}
  function PCharGetWChar(var pText: PChar): WChar_t;

  {機能： WChar_t型の値をString型へ変換する。}
  function WCharToStr(WCh: WChar_t): String;

  {機能： '\' で 引用されたキャラクタを得る。 \n, \t \\ ...
   注意： Indexは'\'の次の文字を指しているとする。}
  function GetQuotedWChar(const Str: String; var Index: Integer): WChar_t;


  {説明 ：  FS:WChar_tを区切り文字として、バイト位置Indexから始まるトークンを１つ返す。
  引数  ：  Str: String
            Index: Integer  引数StrのIndex番目のバイト位置から変換を始める。
  返り値：  FSで区切られた、バイト位置Indexから始まるトークン}
  function WCharGetToken(const Str: String; var Index: Integer; FS: WChar_t): String;


  {説明 ：  引数Str中のメタキャラクタに'\'をつける。
  引数  ：  Str: String
  返り値：  メタキャラクタの前に'\'がついたStr}
  function QuoteMetaWChar(Str: String): String;

const
  CONST_DOLLAR  = $24;    //  '$'
  CONST_LPAR    = $28;    //  '('
  CONST_RPAR    = $29;    //  ')'
  CONST_STAR    = $2A;    //  '*'
  CONST_PLUS    = $2B;    //  '+'
  CONST_DOT     = $2E;    //  '.'
  CONST_QMARK   = $3F;    //  '?'
  CONST_VL      = $7C;    //  '|'

  CONST_LBRA    = $5B;    //  '['
  CONST_RBRA    = $5D;    //  ']'
  CONST_CARET   = $5E;    //  '^'
  CONST_YEN     = $5C;    //  '\'
  CONST_MINUS   = $2D;    //  '-'

  CONST_b       = $62;      //  'b'
  CONST_r       = $72;      //  'r'
  CONST_n       = $6E;      //  'n'
  CONST_t       = $74;      //  't'
  CONST_x       = $78;      //  'x'

  CONST_BS      = $08;      //  BackSpace
  CONST_CR      = $0D;      //  Carriage Return
  CONST_LF      = $0A;      //  Line Feed
  CONST_TAB     = $09;      //  TAB

  CONST_ANP     = $26;      //  '&'

  CONST_NULL    = $0000;

  METACHARS: Array[0..11] of WChar_t = (CONST_CARET,
                                        CONST_LPAR,
                                        CONST_VL,
                                        CONST_RPAR,
                                        CONST_PLUS,
                                        CONST_STAR,
                                        CONST_QMARK,
                                        CONST_DOT,
                                        CONST_LBRA,
                                        CONST_RBRA,
                                        CONST_DOLLAR,
                                        CONST_YEN);

  CONST_EMPTY    = $FFFF; {TNFA, TDFA状態表で「文字がない」ことを表すコードとして使う}
  CONST_LINEHEAD = $FFFD; {文頭メタキャラクタ'^'を表す文字コードとして使う。}
  CONST_LINETAIL = $FFFE; {文尾メタキャラクタ'$'を表す文字コードとして使う。}

  REFuzzyWChars: array [0..144] of String =
    ('Ａ,ａ,A,a',
     'Ｂ,ｂ,B,b',
     'Ｃ,ｃ,C,c',
     'Ｄ,ｄ,D,d',
     'Ｅ,ｅ,E,e',
     'Ｆ,ｆ,F,f',
     'Ｇ,ｇ,G,g',
     'Ｈ,ｈ,H,h',
     'Ｉ,ｉ,I,i',
     'Ｊ,ｊ,J,j',
     'Ｋ,ｋ,K,k',
     'Ｌ,ｌ,L,l',
     'Ｍ,ｍ,M,m',
     'Ｎ,ｎ,N,n',
     'Ｏ,ｏ,O,o',
     'Ｐ,ｐ,P,p',
     'Ｑ,ｑ,Q,q',
     'Ｒ,ｒ,R,r',
     'Ｓ,ｓ,S,s',
     'Ｔ,ｔ,T,t',
     'Ｕ,ｕ,U,u',
     'Ｖ,ｖ,V,v',
     'Ｗ,ｗ,W,w',
     'Ｘ,ｘ,X,x',
     'Ｙ,ｙ,Y,y',
     'Ｚ,ｚ,Z,z',
     '0,０,零',
     '1,１,一,①,Ⅰ,壱',
     '2,２,二,②,Ⅱ,弐',
     '3,３,三,③,Ⅲ,参',
     '4,４,四,④,Ⅳ',
     '5,５,五,⑤,Ⅴ,伍',
     '6,６,六,⑥,Ⅵ',
     '7,７,七,⑦,Ⅶ',
     '8,８,八,⑧,Ⅷ',
     '9,９,九,⑨,Ⅸ',
     '"　"," "',
     '!,！',
     '"""",”',
     '#,＃',
     '$,＄',
     '%,％',
     '&,＆',
     ''',’',
     '(,（',
     '),）',
     '*,＊',
     '+,＋',
     'ー,～,ｰ,',   { 長音記号は、''ヌルとも一致させる}
     '-,ー,－,～,ｰ',
     '･,・',
     '/,／',
     ':,：',
     ';,；',
     '<,＜',
     '=,＝',
     '>,＞',
     '?,？',
     '@,＠',
     '[,［,〔',
     '\,￥',
     '],］,〕',
     '^,＾',
     '_,＿',
     '{,｛',
     '|,｜',
     '},｝',
     '~,￣',
     '",",､,、,，',
     '｡,.,。,．',
     '「,『,｢',
     '」,』,｣',
     'ん,ン,ﾝ',
     'が,ガ,ｶﾞ,か゛,カ゛',
     'ぎ,ギ,ｷﾞ,き゛,キ゛',
     'ぐ,グ,ｸﾞ,く゛,ク゛',
     'げ,ゲ,ｹﾞ,け゛,ケ゛',
     'ご,ゴ,ｺﾞ,こ゛,コ゛',
     'ざ,ザ,ｻﾞ,さ゛,サ゛',
     'じ,ジ,ｼﾞ,し゛,シ゛,ぢ,ヂ,ﾁﾞ,ち゛,チ゛',
     'ず,ズ,ｽﾞ,ス゛,ス゛,づ,ヅ,ﾂﾞ,つ゛,ツ゛',
     'ぜ,ゼ,ｾﾞ,せ゛,セ゛',
     'ぞ,ゾ,ｿﾞ,そ゛,ソ゛',
     'だ,ダ,ﾀﾞ,た゛,タ゛',
     'で,デ,ﾃﾞ,て゛,テ゛',
     'ど,ド,ﾄﾞ,と゛,ト゛',
     'ば,バ,ﾊﾞ,は゛,ハ゛,ヴァ,う゛ぁ,ウ゛ァ,ｳﾞｧ',
     'び,ビ,ﾋﾞ,ひ゛,ヒ゛,ヴィ,う゛ぃ,ウ゛ィ,ｳﾞｨ',
     'ぶ,ブ,ﾌﾞ,ふ゛,フ゛,ヴ,ウ゛,う゛,ｳﾞ',
     'べ,ベ,ﾍﾞ,へ゛,ヘ゛,ヴェ,う゛ぇ,ウ゛ェ,ｳﾞｪ',
     'ぼ,ボ,ﾎﾞ,ほ゛,ホ゛,ヴォ,う゛ぉ,ウ゛ォ,ｳﾞｫ',
     'ぱ,パ,ﾊﾟ,は゜,ハ゜',
     'ぴ,ピ,ﾋﾟ,ひ゜,ヒ゜',
     'ぷ,プ,ﾌﾟ,ふ゜,フ゜',
     'ぺ,ペ,ﾍﾟ,へ゜,ヘ゜',
     'ぽ,ポ,ﾎﾟ,ほ゜,ホ゜',
     'あ,ア,ｱ,ぁ,ァ,ｧ',
     'い,イ,ｲ,ぃ,ィ,ｨ',
     'う,ウ,ｳ,ぅ,ゥ,ｩ',
     'え,エ,ｴ,ぇ,ェ,ｪ',
     'お,オ,ｵ,ぉ,ォ,ｫ',
     'か,カ,ｶ',
     'き,キ,ｷ',
     'く,ク,ｸ',
     'け,ケ,ｹ',
     'こ,コ,ｺ',
     'さ,サ,ｻ',
     'し,シ,ｼ',
     'す,ス,ｽ',
     'せ,セ,ｾ',
     'そ,ソ,ｿ',
     'た,タ,ﾀ',
     'ち,チ,ﾁ',
     'つ,ツ,ﾂ,っ,ッ,ｯ',
     'て,テ,ﾃ',
     'と,ト,ﾄ',
     'な,ナ,ﾅ',
     'に,ニ,ﾆ',
     'ぬ,ヌ,ﾇ',
     'ね,ネ,ﾈ',
     'の,ノ,ﾉ',
     'は,ハ,ﾊ',
     'ひ,ヒ,ﾋ',
     'ふ,フ,ﾌ',
     'へ,ヘ,ﾍ',
     'ほ,ホ,ﾎ',
     'ま,マ,ﾏ',
     'み,ミ,ﾐ',
     'む,ム,ﾑ',
     'め,メ,ﾒ',
     'も,モ,ﾓ',
     'や,ヤ,ﾔ,ゃ,ャ,ｬ',
     'ゆ,ユ,ﾕ,ゅ,ュ,ｭ',
     'よ,ヨ,ﾖ,ょ,ョ,ｮ',
     'ら,ラ,ﾗ',
     'り,リ,ﾘ',
     'る,ル,ﾙ',
     'れ,レ,ﾚ',
     'ろ,ロ,ﾛ',
     'わ,ワ,ﾜ,うぁ,ウァ,ｳｧ',
     'ヰ,ゐ,うぃ,ウィ,ｳｨ',
     'ヱ,ゑ,うぇ,ウェ,ｳｪ',
     'を,ヲ,ｦ,うぉ,ウォ,ｳｫ',
     'ﾞ,゛',
     'ﾟ,゜'); {濁点、半濁点はこの位置にないと ”が”→”ｶﾞ”に変換されない。}

type
{ -============================= TREScanner Class ==================================-}
  { 文字の範囲を表す型。}
  RECharClass_t = record
    case Char of
    #0: (StartChar: WChar_t; EndChar: WChar_t);
    #1: (Chars: DoubleWChar_t);
  end;

const
  CONST_EMPTYCharClass: RECharClass_t = ( StartChar: CONST_EMPTY;
                                          EndChar: CONST_EMPTY);

type

  { RECharClass_tへのポインタ型}
  REpCharClass_t = ^RECharClass_t;

  {トークンの種類を表す型 }
  REToken_t = ( retk_Char,      {通常の文字  }
                retk_CharClass, {'[]'で囲まれたキャラクタクラス正規表現の中で
                                 '-'を使って範囲指定された物 }
                retk_Union,     { '|'}
                retk_LPar,      { '('}
                retk_RPar,      { ')'}
                retk_Star,      { '*'}
                retk_Plus,      { '+'}
                retk_QMark,     { '?'}
                retk_LBra,      { '['}
                retk_LBraNeg,   { '[＾'}
                retk_RBra,      { ']'}
                retk_Dot,       { '.'}
                retk_LHead,     { '^'}
                retk_LTail,     { '$'}
                retk_End);      { 文字列の終わり }

  { REToken_tの集合集合型}
  RETokenSet_t = set of REToken_t;

  RESymbol_t = record
    case REToken_t of
      retk_CharClass: (CharClass: RECharClass_t);
      retk_Char:      (WChar: WChar_t);
  end;

{● 文字列からトークンを切り出すクラス}
  TREScanner = class
  private
    FRegExpStr: String;
    FIndex: Integer;
    FToken: REToken_t;
    FSymbol: RESymbol_t;
    FInCharClass: Boolean;
  protected
    procedure SetRegExpStr(RegExpStr: String);

    {次のトークンを得る。}
    function GetTokenStd: REToken_t; virtual;
    {キャラクタクラス正規表現 "[ ]" の中のトークンを得る。}
    function GetTokenCC: REToken_t; virtual;
  public
    constructor Create(Str: String);

    function GetToken: REToken_t;

    {現在のトークン}
    property Token: REToken_t read FToken;

    { Tokenに対応する文字[列](Lexeme)
      Token <> retk_CharClass のとき 現在のトークンの文字値 WChar_t型
      Token =  retk_CharClass のときはRECharClass_tレコード型
      ※FToken = retk_LBraNegの時はブラケット'['１文字分しかない。}
    property Symbol: RESymbol_t read FSymbol;

    {処理対象の文字列}
    property RegExpStr: String read FRegExpStr write SetRegExpStr;

    {インデックス
     InputStr文字列中で次のGetWCharメソッドで処理する文字のインデックス
     ※ Symbolの次の文字を指していることに注意}
    property Index: Integer read FIndex;
  end;

{-=============================                          ====================-}
  {トークンの情報をひとまとめにしたもの}
  RETokenInfo_t = record
    Token: REToken_t;
    Symbol: RESymbol_t;
    FromIndex: Integer;
    ToIndex: Integer;
  end;

  REpTokenInfo_t = ^RETokenInfo_t;

  {TREPreProcessorクラス内部で使用}
  TREPreProcessorFindFunc = function(FromTokenIndex, ToTokenIndex: Integer): Integer of object;

  TREPreProcessor = class
  private
    FScanner: TREScanner;
    FProcessedRegExpStr: String;
    FListOfSynonymDic: TList;
    FListOfFuzzyCharDic: TList;
    FTokenList: TList;
    FSynonymStr: String;

    FUseFuzzyCharDic: Boolean;
    FUseSynonymDic: Boolean;
  protected
    procedure MakeTokenList;
    procedure DestroyTokenListItems;

    function ReferToOneList(FromTokenIndex, ToTokenIndex: Integer; SynonymDic: TList): Integer;
    function FindSynonym(FromTokenIndex, ToTokenIndex: Integer): Integer;
    function FindFuzzyWChar(FromTokenIndex, ToTokenIndex: Integer): Integer;

    procedure Process(FindFunc: TREPreProcessorFindFunc);

    function GetTargetRegExpStr: String;
    procedure SetTargetRegExpStr(Str: String);
  public
    constructor Create(Str: String);
    destructor  Destroy; override;
    procedure   Run;

    property    TargetRegExpStr: String read GetTargetRegExpStr write SetTargetRegExpStr;
    property    ProcessedRegExpStr: String read FProcessedRegExpStr;

    property    UseSynonymDic:      Boolean read FUseSynonymDic write FUseSynonymDic;
    property    ListOfSynonymDic:   TList   read FListOfSynonymDic;
    property    UseFuzzyCharDic:    Boolean read FUseFuzzyCharDic write FUseFuzzyCharDic;
    property    ListOfFuzzyCharDic: TList   read FListOfFuzzyCharDic;
  end;

{-=========================== TREParseTree Class ===============================-}
{**************************************************************************
●  構文木を管理するクラス TREParseTree

特徴：  中間節(Internal node)と葉(Leaf)を作るときは、それぞれMakeInternalNode
        メソッドとMakeLeafメソッドを使う。
        また、構文木とは別に、FNodeListとFLeafListから中間節と葉へリンクして
        おくことにより、途中でエラーが発生しても必ずメモリを開放する。
**************************************************************************}
  { TREParseTreeの節の種類を表す型}
  REOperation_t = (reop_Char,     { 文字そのもの }
          reop_LHead,   { 文頭 }
          reop_LTail,   { 文尾 }
          reop_Concat,  { XY }
          reop_Union,   { X|Y}
          reop_Closure, { X* }
          reop_Empty);  { 空 }

  { RENode_tへのポインタ型}
  REpNode_t = ^RENode_t;

  { TREParseTreeの子節へのポインタ型}
  REChildren_t = record
    pLeft: REpNode_t;
    pRight: REpNode_t;
  end;

  { TREParseTreeの節}
  RENode_t = record
    Op: REOperation_t;
    case Char of
    #0: (CharClass: RECharClass_t);
    #1: (Children: REChildren_t);
  end;

{● 構文木を管理するクラス}
  TREParseTree = class
  private
    FpHeadNode: REpNode_t;{構文木の頂点にある節}
    FNodeList: TList;   {中間節のリスト。}
    FLeafList: TList;   {葉のリスト。}
  public
    constructor Create;
    destructor Destroy; override;

    {構文木の内部節を作成。
      op はノードが表す演算、leftは左の子、rightは右の子 }
    function MakeInternalNode(TheOp: REOperation_t; pLeft, pRight: REpNode_t): REpNode_t;

    {構文木の葉を作成。
      aStartChar, aEndChar でキャラクタクラスを表す}
    function MakeLeaf(aStartChar, aEndChar: WChar_t): REpNode_t;

    {任意の一文字を表す'.'メタキャラクタに対応する部分木を作る。
     ※CR LFを除く全てのキャラクタを表す葉をreop_Union操作を表す中間節で結んだもの}
    function MakeAnyCharsNode: REpNode_t; virtual;

    {文頭メタキャラクタを表す葉を作成
     ※ 葉を返すが、MakeInternalNodeを使う。}
    function MakeLHeadNode(WChar: WChar_t): REpNode_t;

    {文尾メタキャラクタを表す葉を作成
     ※ 葉を返すが、MakeInternalNodeを使う。}
    function MakeLTailNode(WChar: WChar_t): REpNode_t;

    {引数が aStartChar <= aEndChar の関係を満たしているときに、MakeLeafを呼ぶ
     それ以外は、nil を返す。}
    function Check_and_MakeLeaf(aStartChar, aEndChar: WChar_t):REpNode_t;

    {葉を内部節に変える。}
    procedure ChangeLeaftoNode(pLeaf, pLeft, pRight: REpNode_t);

    {全ての葉が持つキャラクタクラスの範囲がそれぞれ重複しないように分割する。}
    procedure ForceCharClassUnique;

    {すべての節（内部節、葉）を削除。}
    procedure DisposeTree;

    {構文木の頂点にある節}
    property pHeadNode: REpNode_t read FpHeadNode write FpHeadNode;

    {内部節のリスト}
    property NodeList: TList read FNodeList;
    {葉のリスト}
    property LeafList: TList read FLeafList;
  end;

{-=========================== TREParser Class ===============================-}
{● 正規表現文字列を解析して構文木にするパーサー }
  TREParser = class
  private
    FParseTree: TREParseTree; {ユニットParseTre.pas で定義されている構文木クラス}
    FScanner: TREScanner;         {トークン管理クラス}

  protected
    { <regexp>をパースして、得られた構文木を返す。
      選択 X|Y を解析する}
    function Regexp: REpNode_t;

    { <term>をパースして、得られた構文木を返す。
      連結ＸＹを解析する}
    function term: REpNode_t;

    { <factor>をパースして、得られた構文木を返す。
      繰り返しX*, X+を解析する}
    function factor: REpNode_t;

    { <primary>をパースして、得られた構文木を返す。
      文字そのものと、括弧で括られた正規表現 (X) を解析する}
    function primary: REpNode_t;

    { <charclass> をパースして、得られた構文木を返す。
      [ abcd] で括られた正規表現を解析する}
    function CharacterClass(aParseTree: TREParseTree): REpNode_t;

    { <negative charclass>をパースして、得られた構文木を返す。
      [^abcd] で括られた正規表現を解析する}
    function NegativeCharacterClass: REpNode_t;

  public
    constructor Create(RegExpStr: String);
    destructor Destroy; override;

    {正規表現をパースする。
      regexp, term, factor, primary, charclass の各メソッドを使い再帰下降法
      によって解析する。}
    procedure Run;

    {構文木を管理するオブジェクト}
    property ParseTree: TREParseTree read FParseTree;

    {入力文字列からトークンを切り出すオブジェクト}
    property Scanner: TREScanner read FScanner;

{$IFDEF DEBUG}
    {アウトライン・コントロールに構文木の図を書き出すメソッド}
    procedure WriteParseTreeToOutLine(anOutLine: TOutLine);
{$ENDIF}
  end;

{$IFDEF DEBUG}
  function DebugWCharToStr(WChar: WChar_t): String;
{$ENDIF}

{ -============================== TRE_NFA Class ==================================-}
type
  RE_pNFANode_t = ^RE_NFANode_t;

  { NFA状態表の節
    RE_NFANode_t は 1つのＮＦＡ状態が、キャラクタクラス(CharClass)内の文字によっ
    て遷移するＮＦＡ状態の状態番号(TransitTo)を格納する。
    １つのＮＦＡ状態へ入力されるキャラクタクラス毎にリンク・リストを形成する}
  RE_NFANode_t = record
    CharClass: RECharClass_t;{ 入力 : CharClass.StartChar ～ CharClass.EndChar}
    TransitTo: integer;    { 遷移先： FStateListのインデックス}

    Next: RE_pNFANode_t;      { リンクリストの次節}
  end;

{● 構文木を解析してNFA状態表を作るクラス}
  TRE_NFA = class
  private
    FStateList: TList;
    FEntryState: Integer;
    FExitState: Integer;
    FParser: TREParser;
    FRegExpHasLHead: Boolean;
    FRegExpHasLTail: Boolean;
    FLHeadWChar: WChar_t;
    FLTailWChar: WChar_t;
  protected
    { ノードに番号を割り当てる}
    function NumberNode: Integer;

    { NFA状態節 を１つ作成}
    function MakeNFANode: RE_pNFANode_t;

    { FStateListに状態遷移を追加する。
      状態 TransFrom に対して、ChrClassのときに状態 TransTo への遷移を追加する。}
    procedure AddTransition(TransFrom, TransTo: Integer; aCharClass: RECharClass_t);

    { 構文木 pTree に対する StateListを生成する
      NFAの入り口をentry, 出口をway_outとする }
    procedure GenerateStateList(pTree: REpNode_t; entry, way_out: Integer);

    { NFA状態表を破棄する}
    procedure DisposeStateList;

  public
    constructor Create(Parser: TREParser; LHeadWChar, LTailWChar: WChar_t);
    destructor Destroy;override;

    { 構文木 Treeに対応するNFAを生成する}
    procedure Run;

    {NFA 状態のリスト}
    property StateList: TList read FStateList;

    {NFAの初期状態のFStateListのインデックス}
    property EntryState: Integer read FEntryState;
    {NFAの終了状態のFStateListのインデックス}
    property ExitState: Integer read FExitState;

    {正規表現が、文頭メタキャラクタを含むか}
    property RegExpHasLHead: Boolean read FRegExpHasLHead;
    {正規表現が、文尾メタキャラクタを含むか}
    property RegExpHasLTail: Boolean read FRegExpHasLTail;

    {文頭を表すメタキャラクタ '^'に与えるユニークなキャラクタコード}
    property LHeadWChar: WChar_t read FLHeadWChar write FLHeadWChar;
    {文尾を表すメタキャラクタ '$'に与えるユニークなキャラクタコード}
    property LTailWChar: WChar_t read FLTailWChar write FLTailWChar;

{$IFDEF DEBUG}
    {TStringsオブジェクトに、NFA の内容を書き込む}
    procedure WriteNFAtoStrings(Strings: TStrings);
{$ENDIF}
  end;

{ -========================== TRE_NFAStateSet Class =============================-}
{● NFAの状態集合を表すオブジェクト
    内部ではビットベクタで状態集合を実現している。}
  TRE_NFAStateSet = class
  private
    FpArray: PByteArray;
    FCapacity: Integer;
  public
    {コンストラクタには、最大状態数を指定する。}
    constructor Create(StateMax: Integer);
    destructor Destroy; override;

    {オブジェクトの集合が、StateIndexを含むか？}
    function Has(StateIndex: Integer): Boolean;
    {オブジェクトの集合が、AStateSetと同じ集合状態か？}
    function Equals(AStateSet: TRE_NFAStateSet): Boolean;
    {オブジェクトの集合にStateIndexを含める。}
    procedure Include(StateIndex: Integer);
    {オブジェクトが持つバイト配列へのポインタ}
    property pArray: PByteArray read FpArray;
    {オブジェクトが持つバイト配列の要素数}
    property Capacity: Integer read FCapacity;
  end;

{ -============================= TRE_DFA Class ==================================-}
{● TRE_DFA           NFA状態表からDFA状態表を作るクラス
  コンストラクタ Create に、正規表現を表すＮＦＡ(非決定性有限オートマトン
  Non-deterministic Finite Automaton)の状態表を持つTRE_NFAを受け取り、
  対応するＤＦＡ(決定性有限オートマトンDeterministic Finite Automaton)
  の状態リストオブジェクトを構築するTRE_DFAクラス。}

  RE_pDFATransNode_t = ^RE_DFATransNode_t;

  {TRE_DFAのメソッドCompute_Reachable_N_state(DState: PD_state_t): RE_pDFATransNode_t;
  がこの型の値を返す。
  キャラクタクラス(CharClass)で遷移可能なＮＦＡ状態集合(ToNFAStateSet)}
  RE_DFATransNode_t = record
    CharClass: RECharClass_t;{Char;}
    ToNFAStateSet: TRE_NFAStateSet;

    next: RE_pDFATransNode_t;{リンクリストを形成}
  end;

  RE_pDFAStateSub_t = ^RE_DFAStateSub_t;
  RE_pDFAState_t = ^RE_DFAState_t;

  { RE_DFAState_tによって使用される
  キャラクタクラス(CharClass)によってDFA状態(TransitTo) へ遷移する。}
  RE_DFAStateSub_t = record
    CharClass: RECharClass_t;
    TransitTo: RE_pDFAState_t; {CharClass範囲内の文字で DFA 状態 TransitToへ}

    next: RE_pDFAStateSub_t; {リンクリストの次のデータ}
  end;

  { RE_DFAState_tはＤＦＡ状態を表す型}
  RE_DFAState_t = record
    StateSet: TRE_NFAStateSet; {このDFA状態を表すNFA状態集合}
    Visited: wordbool; { 処理済みなら１}
    Accepted: wordbool;{ StateSetフィールドがNFAの終了状態を含むなら１}
    Next: RE_pDFAStateSub_t;  { キャラクタクラス毎の遷移先のリンクリスト}
  end;

{ ● NFA状態表からDFA状態表を作るクラス}
  TRE_DFA = class
  private
    FStateList: TList;
    FpInitialState: RE_pDFAState_t;
    FNFA: TRE_NFA;

    FRegExpIsSimple: Boolean;
    FSimpleRegExpStr: String;
    FRegExpHasLHead: Boolean;
    FRegExpHasLTail: Boolean;
  protected
    { NFA状態集合 StateSet に対して ε-closure操作を実行する。
    ε遷移で遷移可能な全てのＮＦＡ状態を追加する}
    procedure Collect_Empty_Transition(StateSet: TRE_NFAStateSet);

    { NFA状態集合 aStateSet をＤＦＡに登録して、ＤＦＡ状態へのポインタを返す。
      aStateSetが終了状態を含んでいれば、acceptedフラグをセットする。
      すでにaStateSetがＤＦＡに登録されていたら何もしない}
    function Register_DFA_State(var aStateSet: TRE_NFAStateSet): RE_pDFAState_t;

    { 処理済みの印がついていないＤＦＡ状態を探す。
      見つからなければnilを返す。}
    function Fetch_Unvisited_D_state: RE_pDFAState_t;

    { DFA状態pDFAStateから遷移可能なNFA状態を探して、リストにして返す}
    function Compute_Reachable_N_state(pDFAState: RE_pDFAState_t): RE_pDFATransNode_t;

    { Compute_Reachable_N_stateメソッドか作る RE_DFATransNode_t型のリンクリストを
    廃棄する}
    procedure Destroy_DFA_TransList(pDFA_TransNode: RE_pDFATransNode_t);

    { NFAを等価なＤＦＡへと変換する}
    procedure Convert_NFA_to_DFA;

    { StateListの各リンクリストをソートする}
    procedure StateListSort;

    procedure CheckIfRegExpIsSimple;
    procedure DestroyStateList;
  public
    constructor Create(NFA: TRE_NFA);
    destructor Destroy; override;

    procedure Run;

    property StateList: TList read FStateList;

    property pInitialState: RE_pDFAState_t read FpInitialState;

    {正規表現が単純な文字列か？}
    property RegExpIsSimple: Boolean read FRegExpIsSimple;
    {正規表現と等価な単純な文字列}
    property SimpleRegExpStr: String read FSimpleRegExpStr;

    {正規表現が、文頭メタキャラクタを含むか}
    property RegExpHasLHead: Boolean read FRegExpHasLHead;
    {正規表現が、文尾メタキャラクタを含むか}
    property RegExpHasLTail: Boolean read FRegExpHasLTail;
  {$IFDEF DEBUG}
    {TStringsオブジェクトに、DFA の内容を書き込む}
    procedure WriteDFAtoStrings(Strings: TStrings);
{$ENDIF}
  end;

{ -=================== TRegularExpression Class ==============================-}
  {TStringList に格納できる項目数の範囲型}
  RE_IndexRange_t = 1..Classes.MaxListSize;

{● 正規表現文字列からＤＦＡ状態表を作るクラス}
  TRegularExpression = class(TComponent)
  private
  protected
    FLineHeadWChar: WChar_t;
    FLineTailWChar: WChar_t;
    {プリプロセッサを通る前の正規表現}
    FRegExp: String;
    {正規表現の文字列リスト。ObjectsプロパティにTＤＦＡオブジェクトを持つ}
    FRegExpList: TStringList;
    {FRegExpListに格納する項目数の最大値。 デフォルト 30}
    FRegExpListMax: RE_IndexRange_t;
    {現在指定されている正規表現 RegExpの正規表現文字列リストRegExpList中での
     インデックス
     ※ FRegExpList[FCurrentIndex] = RegExp}
    FCurrentIndex: Integer;
    {同意語処理プリプロセッサ}
    FPreProcessor: TREPreProcessor;

  { 内部使用のための手続き・関数}
    {*****     正規表現文字列→構文木構造→NFA→DFA の変換を行う *****}
    procedure Translate(RegExpStr: String); virtual;

    {正規表現リスト(RegExpList: TStringList)とObjectsプロパティに結び付けられた
     TRE_DFAオブジェクトを破棄}
    procedure DisposeRegExpList;

  {プロパティ・アクセス・メソッド}
    procedure SetRegExp(Str: String); virtual;
    function  GetProcessedRegExp: String;
    function  GetListOfFuzzyCharDic: TList;
    function  GetListOfSynonymDic: TList;
    function  GetRegExpIsSimple: Boolean;
    function  GetSimpleRegExp: String;
    function  GetHasLHead: Boolean;
    function  GetHasLTail: Boolean;
    function  GetUseFuzzyCharDic: Boolean;
    procedure SetUseFuzzyCharDic(Val: Boolean);
    function  GetUseSynonymDic: Boolean;
    procedure SetUseSynonymDic(Val: Boolean);
    function  GetLineHeadWChar: WChar_t; virtual;
    function  GetLineTailWChar: WChar_t; virtual;
  {DFAオブジェクト関連メソッド}
    {現在指定されている正規表現に対応するＤＦＡ状態表の初期状態へのポインタを返す}
    function GetpInitialDFAState: RE_pDFAState_t;
    {現在指定されている正規表現に対応するTRE_DFAオブジェクトを返す}
    function GetCurrentDFA: TRE_DFA;
    {状態 DFAstateから文字ｃによって遷移して、遷移後の状態を返す。
     文字ｃによって遷移出来なければnilを返す}
    function NextDFAState(DFAState: RE_pDFAState_t; c: WChar_t): RE_pDFAState_t;
    {DFA状態表の中で文頭メタキャラクタを表すキャラクタコード}
    property LineHeadWChar: WChar_t read GetLineHeadWChar;
    {DFA状態表の中で文尾メタキャラクタを表すキャラクタコード}
    property LineTailWChar: WChar_t read GetLineTailWChar;

  {正規表現関連プロパティ}
    {現在指定されている正規表現}
    property RegExp: String read FRegExp write SetRegExp;

    {現在指定されている正規表現に同意語処理を施したもの}
    property ProcessedRegExp: String read GetProcessedRegExp;

    {正規表現が単純な文字列か？}
    property RegExpIsSimple: Boolean read GetRegExpIsSimple;
    {正規表現と等価な単純な文字列(※RegExpIsSimple=Falseの時はヌル文字列)}
    property SimpleRegExp: String read GetSimpleRegExp;

    {正規表現が、文頭メタキャラクタを含むか}
    property HasLHead: Boolean read GetHasLHead;
    {正規表現が、文尾メタキャラクタを含むか}
    property HasLTail: Boolean read GetHasLTail;

  {辞書関連プロパティ}
    {文字同一視辞書を使う／使わない指定}
    property UseFuzzyCharDic: Boolean read GetUseFuzzyCharDic write SetUseFuzzyCharDic;
    {文字の同一視辞書のリスト}
    property ListOfFuzzyCharDic: TList read GetListOfFuzzyCharDic;

    {同意語辞書を使う／使わない指定}
    property UseSynonymDic: Boolean read GetUseSynonymDic write SetUseSynonymDic;
    {同意語辞書のリスト}
    property ListOfSynonymDic: TList read GetListOfSynonymDic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

{ -========================== TAWKStr Class ==================================-}
  TMatchCORE_LineSeparator = (mcls_CRLF, mcls_LF);

  TMatchCORE = class(TRegularExpression)
  private
    FLineSeparator: TMatchCORE_LineSeparator;
  protected
    function IsLineEnd(WChar: WChar_t): Boolean;
    property LineSeparator: TMatchCORE_LineSeparator
      read FLineSeparator write FLineSeparator;
  protected

    {説明 ：    マッチ
                (正規表現が行頭／行末メタキャラクタを含まないとき用)
    動作  ：
    引数  ：    pText: PChar    ヌルキャラクタで終わる検索対象文字列へのポインタ
    副作用：    pStart:PChar    マッチした部分の先頭文字へのポインタ
                pEnd  :PChar    マッチした部分の次の文字へのポインタ
    注意  ：    マッチした部分のバイト数は、pEnd - pStartで得られる。}
    procedure MatchStd(pText: PChar; var pStart, pEnd: PChar);


    {説明 ：    マッチ(正規表現が行頭／行末メタキャラクタを含むとき用)
    動作  ：
    引数  ：    pText: PChar    ヌルキャラクタで終わる検索対象文字列へのポインタ
    副作用：    pStart:PChar    マッチした部分の先頭文字へのポインタ
                pEnd  :PChar    マッチした部分の次の文字へのポインタ
    注意  ：    マッチした部分のバイト数は、pEnd - pStartで得られる。}
    procedure MatchEX(pText: PChar; var pStart, pEnd: PChar);

    {説明 ：    マッチ(内部処理用。正規表現が行頭／行末メタキャラクタを含むとき用)
    動作  ：    MatchEx_Headメソッドとの違いは、引数pTextが行の途中をポイントして
                いるものとして、行頭メタキャラクタにマッチしないこと。
    引数  ：    pText: PChar    ヌルキャラクタで終わる検索対象文字列へのポインタ
                                (行の中を指しているものとして扱う。)
    副作用：    pStart:PChar    マッチした部分の先頭文字へのポインタ
                pEnd  :PChar    マッチした部分の次の文字へのポインタ
    注意  ：    マッチした部分のバイト数は、pEnd - pStartで得られる。}
    procedure MatchEX_Inside(pText: PChar; var pStart, pEnd: PChar);

{----------------マッチ 下請け    -------------}
{MatchHead, MatchInsideは、引数 pTextが指す文字を先頭としてマッチするかを検査する}

    {説明 ：    pTextは、ある文字列の行頭をポイントしているものと見なす。
                したがって、pTextが指す文字は行頭メタキャラクタにマッチする。
                行末メタキャラクタを考慮する。
    引数  ：    pText: PChar      検索対象文字列(行の最初の文字を指す)
                pDFAState         初期値として使うDFA状態表の１状態
    返り値：    マッチした部分文字列の次の文字。
                マッチした部分文字列のバイト長は、result - pText
    注意  ：    }
    function MatchHead(pText: PChar; pDFAState: RE_pDFAState_t): PChar;

    {説明 ：    pTextは、ある文字列の中(行頭ではない)をポイントしているものと見なす。
                したがって、pTextが指す文字は行頭メタキャラクタにマッチしない。
                行末メタキャラクタを考慮する。
    引数  ：    pText: PChar      検索対象文字列(行中の文字を指す)
                pDFAState         初期値として使うDFA状態表の１状態
    返り値：    マッチした部分文字列の次の文字。
                マッチした部分文字列のバイト長は、result - pText
    注意  ：    }
    function MatchInside(pText: PChar; pDFAState: RE_pDFAState_t): PChar;
  public
    constructor Create(AOwner: TComponent); override;
  end;

{ -========================== TAWKStr Class ==================================-}
  TAWKStrMatchProc = procedure(pText: PChar; var pStart, pEnd: PChar) of object;

{● AWK言語の文字列操作関数群をDelphiで実現するクラス TAWKStr}
  TAWKStr = class(TMatchCORE)
  private
    FMatchProc: TAWKStrMatchProc;
  protected
    procedure SetRegExp(Str: String); override;
    {Sub, GSubメソッドで使用。 '&'をマッチした文字列に置換える}
    function Substitute_MatchStr_For_ANDChar(Text: String; MatchStr: String): String;
  public
    constructor Create(AOwner: TComponent); override;
    function ProcessEscSeq(Text: String): String;

    {文字の同一視辞書のリスト}
    property ListOfFuzzyCharDic;
    {同意語辞書のリスト}
    property ListOfSynonymDic;

    {正規表現が、文頭メタキャラクタを含むか}
    property HasLHead;
    {正規表現が、文尾メタキャラクタを含むか}
    property HasLTail;

    property ProcessedRegExp;

    {DFA状態表の中で文頭メタキャラクタを表すキャラクタコード}
    property LineHeadWChar;
    {DFA状態表の中で文尾メタキャラクタを表すキャラクタコード}
    property LineTailWChar;

    function Match(Text: String; var RStart, RLength: Integer): Integer;

    function Sub(SubText: String; var Text: String): Boolean;

    function GSub(SubText: String; var Text: String): Integer;

    function Split(Text: String; StrList: TStrings): Integer;
  published
    property RegExp;
    {行の区切り文字指定}
    property LineSeparator;

    {文字の同一視辞書を使うか}
    property UseFuzzyCharDic;
    {同意語辞書を使うか}
    property UseSynonymDic;

  end;

{ -========================== 例外クラス =====================================-}
  EEndOfFile = class(EInOutError);

  EFileNotFound = class(EInOutError);

  EGrepCancel = class(Exception);

{ -=========================== TTxtFile Class ================================-}
  {TTextFileクラスのGetThisLineが返すファイル中の１行の情報を表す型}
  RE_LineInfo_t = record
    Line: String;
    LineNo: Integer; {行番号}
  end;

{● TTxtFile テキストファイル・アクセス・クラス}
  TTxtFile = Class
  private
  protected
  public
    FBuffSize: Integer; {バッファのサイズ}
    FTailMargin: Integer;
    FpBuff: PChar;      {読み込みバッファへのポインタ}

    FFileName: String;  {処理対象ファイル名 （フルパス表記）}
    FF: File;           {FFileName に関連付けられる型なしファイル変数}
    FFileOpened: Boolean;

    {バッファ中の文字位置を表す重要なポインタ３種類}
    FpBase: PChar;      {文中で検索対象となる部分文字列の先頭を指す}
    FpLineBegin: PChar; {FpBaseが指す文の先頭文字へのポインタ}
    FpForward: PChar;     {検索中の文字へのポインタ}

    FLineNo: Integer;   {現在の行番号}
    FReadCount: Integer;{BlockRead で何バイト読み込んだか。}
    FBrokenLine: String;{バッファの境界で分断された文の前半部分}

    FpCancelRequest: ^Boolean;
    {IncPBaseメソッドでFpBaseがヌル・キャラクタを指したときの処理}
    procedure IncPBaseNullChar(Ch: Char);
    {GetCharメソッドでFpForwardがヌル・キャラクタを指したときの処理}
    procedure GetCharNullChar(Ch: Char);

    constructor Create(aFileName: String; var CancelRequest: Boolean);
    destructor Destroy; override;
    procedure BuffRead(pBuff: PChar);
    function IncPBase: Char;  {FpBaseが次のバイトを指すようにする}
    function AdvanceBase: WChar_t;
    function GetChar: Char;
    function GetWChar: WChar_t;
    function GetThisLine: RE_LineInfo_t;{FpBaseが指している文字を含む文を得る}
  end;

{ -=========================== TGrep Class ==================================-}

  TGrepOnMatch = procedure (Sender: TObject; LineInfo: RE_LineInfo_t) of Object;

  TGrepGrepProc = procedure (FileName: String) of Object;

{● ファイル正規表現検索クラス TGrep }
  TGrep = class(TRegularExpression)
  private
    FOnMatch: TGrepOnMatch;
//    FDummyIgnoreCase: Boolean;
    FCancel:  Boolean;
    FGrepProc: TGrepGrepProc;
  protected
    procedure SetRegExp(Str: String); override;
    function  GetLineHeadWChar: WChar_t; override;
    function  GetLineTailWChar: WChar_t; override;
  public
    constructor Create(AOwner: TComponent); override;

    procedure GrepByRegExp(FileName: String);
    procedure GrepByStr(FileName: String);

    {機能 指定されたテキスト・ファイル中で正規表現(RegExpプロパティ)にマッチ
          する行を探し、見つけるたびにOnMatch イベントハンドラを呼び出します。

          (RegExpプロパティに設定されている正規表現を検査して、普通の文字列ならば
           GrepByStrメソッド、メタキャラクタを含むときはGrepByRegExpメソッドを
           呼び出します。)
          ※ OnMatch イベントハンドラが指定されていないときは、何もしません。

     引数   FileNmae        検索対象のテキストファイル名(フルパス指定)
            CancelRequest   検索を途中で止めたいときにTrueにする。
            ※ Grepメソッドは内部で、Application.ProcessMessagesを呼び出す
               ので、そのときに、CancelRequestをTrueに設定することができます。}

    {正規表現が単純な文字列か？}
    property RegExpIsSimple;
    {正規表現と等価な単純な文字列(※RegExpIsSimple=Falseの時はヌル文字列)}
    property SimpleRegExp;

    {正規表現が、文頭メタキャラクタを含むか}
    property HasLHead;
    {正規表現が、文尾メタキャラクタを含むか}
    property HasLTail;

    {RegExpプロパティの正規表現に同意語処理を施したもの}
    property ProcessedRegExp;
    {文字の同一視辞書のリスト}
    property ListOfFuzzyCharDic;
    {同意語辞書のリスト}
    property ListOfSynonymDic;

    property Grep: TGrepGrepProc read FGrepProc;
  published
    {正規表現文字列}
    property RegExp;
    {文字の同一視辞書を使うか}
    property UseFuzzyCharDic;
    {同意語辞書を使うか}
    property UseSynonymDic;

    property OnMatch: TGrepOnMatch read FOnMatch write FOnMatch;

    property Cancel: Boolean read FCancel write FCancel;
  end;



var
  RE_FuzzyCharDic: TList;

procedure Register;

implementation
{************************  Implementation ************************************}
constructor ERegExpParser.Create(const Msg: string; ErrorPosition: Word);
begin
  inherited Create(Msg);
  ErrorPos := ErrorPosition;
end;
{ -====================== 文字列操作関数 =====================================-}
{説明 ：  １６進数を表す文字を受け取り、整数にして返す。
 引数 ：  WCh: WChar_t;     16進数を表す1バイト文字 [0-9a-fA-F]

 返り値： 正常時：  0 <= result <= 15
          異常時：  -1}
function HexWCharToInt(WCh: WChar_t): Integer;
begin
  case WCh of
    Ord('0')..Ord('9'):       result := WCh - Ord('0');
    Ord('A')..Ord('F'):       result := WCh - Ord('A')+10;
    Ord('a')..Ord('f'):       result := WCh - Ord('a')+10;
    else                      result := -1;
  end;
end;

{説明 ：  ８進数を表す文字を受け取り、整数にして返す。
 引数 ：  WCh: WChar_t;     8進数を表す1バイト文字 [0-7]

 返り値： 正常時：  0 <= result <= 7
          異常時：  -1}
function OctWCharToInt(WCh: WChar_t): Integer;
begin
  case WCh of
    Ord('0')..Ord('7'):       result := WCh - Ord('0');
    else                      result := -1;
  end;
end;

{機能： Str から １文字 得る
 解説： Str中でIndexが指す位置から1文字(２バイト文字含む) 得てから、Indexが
        次の文字を指すように進める
 注意： Indexが文字列の長さよりすでに長い場合は常に 0を返し、Indexを増やさない。
        つまり、Indexは最大でも Length(Str)+1 である。}
function GetWChar(const Str: String; var Index: Integer): WChar_t;
begin
  if (Index >= 1) and (Index <= Length(Str)) then begin
    if IsDBCSLeadByte(Byte(Str[Index])) then begin
      {Strの最後の文字が２バイト文字コードの１バイトのときは例外生成}
      if Index = Length(Str) then
        raise ERegExpParser.Create('不正な２バイト文字コードです。', Index);
      WordRec(result).Hi := Byte(Str[Index]);
      WordRec(result).Lo := Byte(Str[Index+1]);
      Inc(Index, 2);
    end else begin
      result := Byte(Str[Index]);
      Inc(Index);
    end;
  end else begin
    result := CONST_NULL;
  end;
end;

//1997/09/25 FIX: MBUtils.pasがなくても動作するように変更
function IsTrailByteInStr(pText: PAnsiChar;
                          ptr:   PAnsiChar
                         ): Boolean;
var
  p: PAnsiChar;
begin
  Result := false;
  if pText = ptr then Exit;
  p := ptr - 1;
  while (p <> pText) do
  begin
    if not IsDBCSLeadByte(Ord(p^)) then Break;
    Dec(p);
  end;
  if ((ptr - p) mod 2) = 0 then Result := true;
end;

procedure UnGetWChar(const Str: String; var Index: Integer);
begin
  if Index <= 1 then
    Exit
  else if (Index > 2) and IsTrailByteInStr(PAnsiChar(Str), PAnsiChar(Str)+Index-2) then
    Dec(Index, 2)
  else
    Dec(Index);
end;

function PCharGetWChar(var pText: PChar): WChar_t;
begin
  if Byte(pText^) <> CONST_NULL then begin
    if IsDBCSLeadByte(Byte(pText^)) then begin
      WordRec(result).Hi := Byte(pText^);
      WordRec(result).Lo := Byte((pText+1)^);
      Inc(pText, 2);
    end else begin
      result := Byte(pText^);
      Inc(pText);
    end;
  end else begin
    result := CONST_NULL;
  end;
end;

{機能： WChar_t型の値をString型へ変換する。}
function WCharToStr(WCh: WChar_t): String;
begin
  if IsDBCSLeadByte(Hi(WCh)) then
    result := Chr(Hi(WCh))+Chr(Lo(WCh))
  else
    result := Chr(Lo(WCh));
end;

{機能： '\' で 引用されたキャラクタを得る。 \n, \t \\ ...
 注意： Indexは'\'の次の文字を指しているとする。}
function GetQuotedWChar(const Str: String; var Index: Integer): WChar_t;
var
  WCh: WChar_t;
begin
  WCh := GetWChar(Str, Index);
  if WCh = 0 then
    raise ERegExpParser.Create('"\"の次には文字が必要です。', Index);

  if WCh = CONST_b  then      {'b'}
    result := CONST_BS  {back space}
  else if WCh = CONST_r then {'r'}
    result := CONST_CR  {Carriage Return}
  else if WCh = CONST_n then {'n'}
    result := CONST_LF  {Line Feed}
  else if WCh = CONST_t then {'t'}
    result := CONST_TAB {tab}
  else if WCh = CONST_x then {'x'}
    result := HexStrToInt(Str, Index)
  else if OctWCharToInt(WCh) >= 0 then begin
    UnGetWChar(Str, Index); {WChを戻す}
    result := OctStrToInt(Str, Index);
  end else
    result := WCh;
end;

{説明 ：  16進数表記の文字列をWord型の数値に変換する。
引数  ：  Str: String     変換元の文字列
          Index: Integer  引数StrのIndex番目のバイト位置から変換を始める。
返り値：  文字列が表すWord型の値}
function HexStrToInt(const Str: String; var Index: Integer): Word;
var
 Val, i: Integer;
 WCh: WChar_t;
begin
  result := 0;
  i := 1;
  WCh := GetWChar(Str, Index);
  Val := HexWCharToInt(WCh);
  while (WCh <> CONST_NULL) and (Val >= 0) and (i < 5) do begin
    result := result * 16 + Val;
    WCh := GetWChar(Str, Index);
    Val := HexWCharToInt(WCh);
    Inc(i);
  end;
  if i = 1 then
    raise ERegExpParser.Create('不正な１６進数コード表記です。', Index);
  if WCh <> CONST_NULL then
    UnGetWChar(Str, Index);
end;

{説明 ：  ８進数表記の文字列をWord型の数値に変換する。
引数  ：  Str: String     変換元の文字列
          Index: Integer  引数StrのIndex番目のバイト位置から変換を始める。
返り値：  文字列が表すWord型の値}
function OctStrToInt(const Str: String; var Index: Integer): Word;
var
  Val, i: Integer;
  WCh: WChar_t;
begin
  result := 0;
  i := 1;
  WCh := GetWChar(Str, Index);
  Val := OctWCharToInt(WCh);
  while (WCh <> CONST_NULL) and (Val >= 0) and (i < 7) do begin
    if (result * 8 + Val) > $FFFF then
      raise ERegExpParser.Create('不正な８進数コード表記です。', Index);
    result := result * 8 + Val;
    WCh := GetWChar(Str, Index);
    Val := OctWCharToInt(WCh);
    Inc(i);
  end;
  if i = 1 then
    raise ERegExpParser.Create('不正な８進数コード表記です。', Index);
  if WCh <> CONST_NULL then
    UnGetWChar(Str, Index);
end;

{説明 ：  FS:WChar_tを区切り文字として、バイト位置Indexから始まるトークンを１つ返す。
引数  ：  Str: String
          Index: Integer  引数StrのIndex番目のバイト位置から変換を始める。
返り値：  FSで区切られた、バイト位置Indexから始まるトークン}
function WCharGetToken(const Str: String; var Index: Integer; FS: WChar_t): String;
var
  WCh: WChar_t;
begin
  result := '';
  WCh := GetWChar(Str, Index);
  while WCh <> 0 do begin
    if WCh = FS then
      break
    else begin
      result := result + WCharToStr(WCh);
      WCh := GetWChar(Str, Index);
    end;
  end;
end;

{説明 ：  引数Str中のメタキャラクタに'\'をつける。
引数  ：  Str: String
返り値：  メタキャラクタの前に'\'がついたStr}
function QuoteMetaWChar(Str: String): String;
var
  i, j: Integer;
  WChar: WChar_t;
begin
  result := '';
  i := 1;
  WChar := GetWChar(Str, i);
  while WChar <> 0 do begin
    j := 0;
    while j <= High(METACHARS) do begin
      if METACHARS[j] = WChar then
        break
      else
        Inc(j);
    end;
    if j <= High(METACHARS) then
      result := result + '\' + WCharToStr(WChar)
    else
      result := result + WCharToStr(WChar);
    WChar := GetWChar(Str, i);
  end;

end;

{ -============================ TREScanner Class =================================-}
constructor TREScanner.Create(Str: String);
begin
  inherited Create;
  Self.SetRegExpStr(Str);
end;

procedure TREScanner.SetRegExpStr(RegExpStr: String);
begin
  FRegExpStr := RegExpStr;
  FIndex := 1;
end;

{機能： トークンを得る
 解説： GetWCharおよびUnGetWCharメソッドを使ってトークンを得る。
 注意： 返り値は、列挙型 REToken_tのうちretk_CharClass以外のどれか}
function TREScanner.GetTokenStd: REToken_t;
var
  WChar: WChar_t;
begin
  WChar := GetWChar(FRegExpStr, FIndex);
  FSymbol.WChar := WChar;

  { 文字(列)をトークンに変換する }
  if WChar = CONST_NULL then
    FToken := retk_End
  else if WChar = CONST_DOLLAR then
    FToken := retk_LTail
  else if WChar = CONST_LPAR then
    FToken := retk_LPar
  else if WChar = CONST_RPAR then
    FToken := retk_RPar
  else if WChar = CONST_STAR then
    FToken := retk_Star
  else if WChar = CONST_PLUS then
    FToken := retk_Plus
  else if WChar = CONST_DOT then
    FToken := retk_Dot
  else if WChar = CONST_QMARK then
    FToken := retk_QMark
  else if WChar = CONST_VL then
    FToken := retk_Union
  else if WChar = CONST_RBRA then
    FToken := retk_RBra
  else if WChar = CONST_LBRA then begin
    WChar := GetWChar(FRegExpStr, FIndex);
    if WChar = CONST_NULL then
      raise ERegExpParser.Create('右ブラケット"]"が必要です', FIndex);
    if WChar = CONST_CARET then
      FToken := retk_LBraNeg {補キャラクタクラス}
    else begin
      UnGetWChar(FRegExpStr, FIndex);
      FToken := retk_LBra;
    end;
  end
  else if WChar = CONST_YEN then begin
    FToken := retk_Char;
    FSymbol.WChar := GetQuotedWChar(FRegExpStr, FIndex);
  end
  else if WChar = CONST_CARET then begin
    FToken := retk_LHead;
  end else
    FToken := retk_Char;

  result := FToken;
end;

{機能： '[]'で囲まれたキャラクタクラス正規表現の中のトークンを得る。
 解説： GetWCharおよびUnGetWCharメソッドを使ってトークンを得る。
 注意： 返り値は、列挙型 REToken_tのうち
        retk_Char, retk_CharClass, retk_RBraのどれか。
        ヌル・キャラクタを見つけたときは例外を生成する。}
function TREScanner.GetTokenCC: REToken_t;
var
  WChar, WChar2, WChar3: WChar_t;
begin
  WChar := GetWChar(FRegExpStr, FIndex);
  FSymbol.WChar := WChar;

  { 文字(列)をトークンに変換する }
  if WChar = CONST_NULL then
    raise ERegExpParser.Create('右ブラケット"]"が必要です', FIndex);
  if WChar = CONST_RBRA then
    FToken := retk_RBra
  else begin
    if WChar = CONST_YEN then
    {エスケープシーケンスを処理}
      WChar := GetQuotedWChar(FRegExpStr, FIndex);

    {キャラクタ範囲を表す'-'に関する処理をする}
    FToken := retk_Char;
    WChar2 := GetWChar(FRegExpStr, FIndex);
    if WChar2 = CONST_MINUS then begin
    {2番目の文字が'-'だったとき}
      WChar3 := GetWChar(FRegExpStr, FIndex);
      if WChar3 = CONST_NULL then
      {3番目の文字がヌルキャラクタのとき}
        raise ERegExpParser.Create('右ブラケット"]"が必要です', FIndex);

      if WChar3 = CONST_RBRA then begin
      {3番目の文字が ']'のとき}
        UnGetWChar(FRegExpStr, FIndex); { WChar3を戻す }
        UnGetWChar(FRegExpStr, FIndex); { WChar2を戻す }
        FSymbol.WChar := WChar;
      end else begin
        if WChar3 = CONST_YEN then
          WChar3 := GetQuotedWChar(FRegExpStr, FIndex);
        FToken := retk_CharClass;
        if WChar > WChar3 then
          raise ERegExpParser.Create('不正なキャラクタ範囲です', FIndex);
        FSymbol.CharClass.StartChar := WChar;
        FSymbol.CharClass.EndChar := WChar3;
      end
    end else begin
    {2番目の文字が'-'ではないとき}
      if WChar2 = CONST_NULL then
      {2番目の文字がヌルキャラクタのとき}
        raise ERegExpParser.Create('右ブラケット"]"が必要です', FIndex);
      UnGetWChar(FRegExpStr, FIndex);{WChar2を戻す}
      FSymbol.WChar := WChar;
    end;
  end;
  result := FToken;
end;

function TREScanner.GetToken: REToken_t;
begin
  if FInCharClass then begin
    try
      result := GetTokenCC;
    except
      FInCharClass := False;
      raise;
    end;
    if result = retk_RBra then
      FInCharClass := False;
  end else begin
    result := GetTokenStd;
    if (result = retk_LBra) or (result = retk_LBraNeg) then
      FInCharClass := True;
  end;
end;

constructor TREPreProcessor.Create(Str: String);
begin
  inherited Create;
  FScanner := TREScanner.Create(Str);
  FTokenList := TList.Create;
  FListOfSynonymDic := TList.Create;
  FListOfFuzzyCharDic := TList.Create;
end;

destructor TREPreProcessor.Destroy;
begin
  FScanner.Free;
  DestroyTokenListItems;
  FTokenList.Free;
  FListOfSynonymDic.Free;
  FListOfFuzzyCharDic.Free;
  inherited Destroy;
end;

{説明 ：    FTokenList: TList を、アイテムデータ (RETokenInfo_t型レコード)と共に廃棄する。
注意  ：    MakeTokenListと対で使用する。}
procedure TREPreProcessor.DestroyTokenListItems;
var
  i: Integer;
begin
  if FTokenList = nil then
    exit;

  i := 0;
  while i < FTokenList.Count do begin
    Dispose(REpTokenInfo_t(FTokenList.Items[i]));
    FTokenList.Items[i] := nil;
    Inc(i);
  end;
  FTokenList.Clear;
end;

{説明 ：    FTokenList: TListに RETokenInfo_t型のレコードを構築する。
動作  ：    最後尾のRETokenInfo_t型レコードは、常にToken = retk_Endである。
注意  ：    DestroyTokenListメソッドと対で使用する。}
procedure TREPreProcessor.MakeTokenList;
var
  pTokenInfo: REpTokenInfo_t;
  prevIndex: Integer;
begin
  prevIndex := FScanner.Index;
  DestroyTokenListItems;
  while FScanner.GetToken <> retk_End do begin
    New(pTokenInfo);
    try
      FTokenList.Add(pTokenInfo);
    except
      on Exception do begin
        Dispose(pTokenInfo);
        raise;
      end;
    end;
    with pTokenInfo^ do begin
      Token := FScanner.Token;
      Symbol := FScanner.Symbol;
      FromIndex := prevIndex;
      ToIndex := FScanner.Index;
    end;
    prevIndex := FScanner.Index;
  end;

  {最後尾 retk_End}
  New(pTokenInfo);
  try
    FTokenList.Add(pTokenInfo);
  except
    on Exception do begin
      Dispose(pTokenInfo);
      raise;
    end;
  end;
  with pTokenInfo^ do begin
    Token := retk_End;
    Symbol.WChar := CONST_NULL;
    FromIndex := 0;
    ToIndex := 0;
  end;
end;

function TREPreProcessor.GetTargetRegExpStr: String;
begin
  result := FScanner.RegExpStr;
end;

procedure TREPreProcessor.SetTargetRegExpStr(Str: String);
begin
  FScanner.RegExpStr := Str;
end;

{説明 ：    正規表現文字列に同意語を組み込む。}
procedure TREPreProcessor.Run;
begin
  FProcessedRegExpStr := FScanner.RegExpStr;
  if FUseSynonymDic then begin
    Self.Process(FindSynonym);
    FScanner.RegExpStr := FProcessedRegExpStr;
  end;

  if FUseFuzzyCharDic then
    Self.Process(FindFuzzyWChar);
end;

{説明 ：    同意語埋め込み処理 Runメソッドの下請け}
procedure TREPreProcessor.Process(FindFunc: TREPreProcessorFindFunc);
var
  j, k: Integer;
  TkIndex: Integer;
  Info: RETokenInfo_t;
  InCC: Boolean;
begin
  FProcessedRegExpStr := '';
  MakeTokenList;
  InCC := False;
  TkIndex := 0;
  {すべてのトークンを検査する}
  while TkIndex < FTokenList.Count do begin
    Info := REpTokenInfo_t(FTokenList[TkIndex])^;
    {キャラクタクラス ('[]'でくくられた部分)に入る}
    if Info.Token = retk_LBra then
      InCC := True;

    {キャラクタクラスから出た}
    if Info.Token = retk_RBra then
      InCC := False;

    {トークンがキャラクタ以外か、キャラクタクラス '[ ]'の中の場合}
    if (Info.Token <> retk_Char) or InCC then begin
      FProcessedRegExpStr := FProcessedRegExpStr +
        Copy(FScanner.RegExpStr, Info.FromIndex, Info.ToIndex-Info.FromIndex);
      Inc(TkIndex); {何もせずにFProcessedRegExpStrへ追加}
    {トークンがキャラクタの場合}
    end else begin
      j := TkIndex;
      {jがキャラクタ以外を指すまでインクリメント}
      while REpTokenInfo_t(FTokenList[j])^.Token = retk_Char do
        Inc(j);

      {キャラクタの連続を１つづつ検査}
      while TkIndex < j do begin
        k := FindFunc(TkIndex, j);
        if k <> -1 then begin
          {マッチした部分を追加}
          FProcessedRegExpStr := FProcessedRegExpStr + FSynonymStr;
          TkIndex := k; {次のトークンからマッチする部分を引き続きさがす。}
        end else begin
          {マッチしなければ、一文字分追加して、インデックスを進める}
          Info := REpTokenInfo_t(FTokenList[TkIndex])^;
          FProcessedRegExpStr := FProcessedRegExpStr +
            Copy(FScanner.RegExpStr, Info.FromIndex, Info.ToIndex-Info.FromIndex);;
          Inc(TkIndex);
        end;
      end;
      TkIndex := j;
    end;
  end;
end;

{説明 ：    同意語辞書 SynonymDic: TListを使って、同意語を探す。
返り値：    トークンリスト内の同意語の次のインデックス
            見つからなければ -1}
function TREPreProcessor.ReferToOneList(FromTokenIndex, ToTokenIndex: Integer; SynonymDic: TList): Integer;
var
  StrList: TStrings;
  i, j, k, m: Integer;

  {StrとFTokenListを比較}
  function Match(Str: String): Integer;
  var
    StrIndex, TkIndex: Integer;
    WChar: WChar_t;
  begin
    if Str = '' then begin
      result := -1;
      exit;
    end;

    TkIndex := FromTokenIndex;
    StrIndex := 1;
    WChar := GetWChar(Str, StrIndex);
    while (WChar <> CONST_NULL) and (TkIndex < ToTokenIndex) do begin
      if WChar <> REpTokenInfo_t(FTokenList[TkIndex])^.Symbol.WChar then begin
        result := -1;
        exit;
      end else begin
        Inc(TkIndex);
        WChar := GetWChar(Str, StrIndex);
      end;
    end;
    if WChar = CONST_NULL then
      result := TkIndex
    else
      result := -1;
  end;
begin
  result := -1;
  i := 0;
  while i < SynonymDic.Count do begin
    StrList := TStrings(SynonymDic[i]);
    j := 0;
    while j < StrList.Count do begin
      k := Match(StrList[j]);
      if k <> -1 then begin
      {マッチした}
        FSynonymStr := '(' + QuoteMetaWChar(StrList[0]);
        m := 1;
        while m < StrList.Count do begin
          FSynonymStr := FSynonymStr + '|' + QuoteMetaWChar(StrList[m]);
          Inc(m);
        end;
        FSynonymStr := FSynonymStr + ')';
        result := k;
        exit;
      end;
      Inc(j);
    end;
    Inc(i);
  end;
end;

{説明 ：
返り値：    トークンリスト内の同意語の次のインデックス
            見つからなければ -1
注意  ：    RunメソッドがメソッドポインタをProcessメソッドに渡し、
            Processメソッドが呼び出す。}
function TREPreProcessor.FindSynonym(FromTokenIndex, ToTokenIndex: Integer): Integer;
var
  i: Integer;
begin
  result := -1;
  i := 0;
  while i < FListOfSynonymDic.Count do begin
    result := ReferToOneList(FromTokenIndex, ToTokenIndex, FListOfSynonymDic[i]);
    if result <> -1 then
      exit;
    Inc(i);
  end;
end;

{説明 ：
返り値：    トークンリスト内の同意語の次のインデックス
            見つからなければ -1
注意  ：    RunメソッドがメソッドポインタをProcessメソッドに渡し、
            Processメソッドが呼び出す。}
function TREPreProcessor.FindFuzzyWChar(FromTokenIndex, ToTokenIndex: Integer): Integer;
var
  i: Integer;
begin
  result := -1;
  i := 0;
  while i < FListOfFuzzyCharDic.Count do begin
    result := ReferToOneList(FromTokenIndex, ToTokenIndex, FListOfFuzzyCharDic[i]);
    if result <> -1 then
      exit;
    Inc(i);
  end;
end;

constructor TREParseTree.Create;
begin
  inherited Create;
  FNodeList := TList.Create;
  FLeafList := TList.Create;
end;

destructor TREParseTree.Destroy;
begin
  DisposeTree;
  FNodeList.Free;
  FLeafList.Free;
  inherited Destroy;
end;

{構文木のノードを作成する。
  op はノードが表す演算、leftは左の子、rightは右の子 }
function TREParseTree.MakeInternalNode(TheOp: REOperation_t; pLeft,
  pRight: REpNode_t): REpNode_t;
begin
  New(result);
  with result^ do begin
    op := TheOp;
    Children.pLeft := pLeft;
    Children.pRight := pRight;
  end;
  try
    FNodeList.Add(result);
  except
    {TListでメモリ不足の時は,新しい構文木の節も開放してしまう}
    on EOutOfMemory do begin
      Dispose(result);
      raise;
    end;
  end;
end;

{構文木の葉を作る
  TheC はこの葉が表す文字}
function TREParseTree.MakeLeaf(aStartChar, aEndChar: WChar_t): REpNode_t;  {char}
var
  i: Integer;
begin
  {既に同じキャラクタクラスを持つ葉が存在すれば、それを返す。}
  for i := 0 to FLeafList.Count-1 do begin
    if (REpNode_t(FLeafList[i])^.CharClass.StartChar = aStartChar) and
    (REpNode_t(FLeafList[i])^.CharClass.EndChar = aEndChar) then begin
      result := FLeafList[i];
      exit;
    end;
  end;

  New(result);
  with result^ do begin
    op := reop_char;
    CharClass.StartChar := aStartChar;
    CharClass.EndChar := aEndChar;
  end;
  try
    FLeafList.Add(result);
  except
    {TListでメモリ不足の時は,新しい構文木の節も開放してしまう}
    on EOutOfMemory do begin
      Dispose(result);
      raise;
    end;
  end;
end;

{文頭メタキャラクタを表す節。 ※子を持たないが、MakeInternalNodeを使う}
function TREParseTree.MakeLHeadNode(WChar: WChar_t): REpNode_t;
begin
  result := MakeInternalNode(reop_LHead, nil, nil);
  with result^ do begin
    CharClass.StartChar := WChar;
    CharClass.EndChar := WChar;
  end;
end;

{文尾メタキャラクタを表す節。 ※子を持たないが、MakeInternalNodeを使う}
function TREParseTree.MakeLTailNode(WChar: WChar_t): REpNode_t;
begin
  result := MakeInternalNode(reop_LTail, nil, nil);
  with result^ do begin
    CharClass.StartChar := WChar;
    CharClass.EndChar := WChar;
  end;
end;

{任意の一文字を表す'.'メタキャラクタに対応する部分木を作る。
 ※CR LFを除く全てのキャラクタを表す葉をreop_Union操作を表す中間節で結んだもの}
function TREParseTree.MakeAnyCharsNode: REpNode_t;
begin
    result := MakeInternalNode(reop_Union, MakeLeaf($1, $09), MakeLeaf($0B, $0C));
    result := MakeInternalNode(reop_Union, result, MakeLeaf($0E, $FCFC));
end;

{引数が aStartChar <= aEndChar の関係を満たしているときに、MakeLeafを呼ぶ
 それ以外は、nil を返す。}
function TREParseTree.Check_and_MakeLeaf(aStartChar, aEndChar: WChar_t):REpNode_t;
begin
  if aStartChar <= aEndChar then begin
    result := MakeLeaf(aStartChar, aEndChar);
  end else
    result := nil;
end;

{葉を内部節に変える。}
procedure TREParseTree.ChangeLeaftoNode(pLeaf, pLeft, pRight: REpNode_t);
begin
  if (pLeft = nil) or (pRight = nil) then
    raise Exception.Create('TREParseTree : 致命的エラー');{ debug }
  with pLeaf^ do begin
    op := reop_Union;
    Children.pLeft := pLeft;
    Children.pRight := pRight;
  end;
  FLeafList.Remove(pLeaf);
  try
    FNodeList.Add(pLeaf);
  except
  on EOutOfMemory do begin
    FreeMem(pLeaf, SizeOf(RENode_t));
    raise;
    end;
  end;
end;

{機能： 個々の葉が持つキャラクタ範囲が１つも重複しないようにする。
 解説： 葉は、CharClassフィールドを持ち、CharClassフィールドはStartCharとEndChar
        をフィールドに持つレコードである。
        個々の葉が持つキャラクタの範囲が重複しないか調べて、重複する場合には、
        その葉を分割し、reop_Unionを持つ内部節で等価な部分木に直す。}
procedure TREParseTree.ForceCharClassUnique;
var
  i, j: Integer;
  Changed: Boolean;

  {機能： 重複するキャラクタ範囲をもつ葉の分割
   解説： ２つの葉pCCLeaf1とpCCLeaf2のキャラクタ範囲を調べて、重複するときは
          分割するして等価な部分木に変換する。}
  function SplitCharClass(pCCLeaf1, pCCLeaf2: REpNode_t): Boolean;
  var
    pNode1, pNode2, pNode3: REpNode_t;
    S1, S2, SmallE, BigE: WChar_t;
  begin
    result := False;
    {前処理： pCCLeaf1 のStartChar <= pCCLeaf2 のStartChar を保証する}
    if pCCLeaf1^.CharClass.StartChar > pCCLeaf2^.CharClass.StartChar then begin
      pNode1 := pCCLeaf1;
      pCCLeaf1 := pCCLeaf2;
      pCCLeaf2 := pNode1;
    end;

    {キャラクタクラスの範囲が重複しない 又は 同一ならば Exit
     ※ MakeLeafメソッドの構造からいって最初は重複する事はないが、分割を繰り返す
        と重複する可能性がある。}
    if (pCCLeaf1^.CharClass.EndChar < pCCLeaf2^.CharClass.StartChar) or
    (pCCLeaf1^.CharClass.Chars = pCCLeaf2^.CharClass.Chars) then
      exit;

    {(pCCLeaf1 のStartChar) S1 <= S2 (pCCLeaf2 のStartChar)}
    S1 := pCCLeaf1^.CharClass.StartChar;
    S2 := pCCLeaf2^.CharClass.StartChar;

    {SmallE は、pCCLeaf1, pCCLeaf2 の EndChar の小さい方
     SmallE <= E2}
    if pCCLeaf1^.CharClass.EndChar > pCCLeaf2^.CharClass.EndChar then begin
      SmallE := pCCLeaf2^.CharClass.EndChar;
      BigE := pCCLeaf1^.CharClass.EndChar;
    end else begin
      SmallE := pCCLeaf1^.CharClass.EndChar;
      BigE := pCCLeaf2^.CharClass.EndChar;
    end;

    pNode1 := Check_and_MakeLeaf(S1, S2-1);
    pNode2 := Check_and_MakeLeaf(S2, SmallE);
    pNode3 := Check_and_MakeLeaf(SmallE+1, BigE);
    {if (pNode1 = nil) and (pNode2 = nil) and (pNode3 = nil) then
      raise ERegExpParser.Create('致命的なエラー', 0); }
    if pNode1 = nil then begin {S1 = S2 のとき}
      if pCCLeaf1^.CharClass.EndChar = BigE then
        ChangeLeaftoNode(pCCLeaf1, pNode2, pNode3)
      else
        ChangeLeaftoNode(pCCLeaf2, pNode2, pNode3);
    end else if pNode3 = nil then begin {SmallE = BigE の時}
      ChangeLeaftoNode(pCCLeaf1, pNode1, pNode2);
    end else begin
      if pCCLeaf1^.CharClass.EndChar = BigE then begin{pCCLeaf1にpCCLeaf2が含まれる}
        ChangeLeaftoNode(pCCLeaf1, MakeInternalNode(reop_Union, pNode1, pNode2),
          pNode3)
      end else begin {pCCLeaf1 と pCCLeaf2 の１部分が重なっている}
        ChangeLeaftoNode(pCCLeaf1, pNode1, pNode2);
        ChangeLeaftoNode(pCCLeaf2, pNode2, pNode3);
      end;
    end;
    result := True;
  end;
begin {procedure TREParser.ForceCharClassUnique}
  i := 0;
  while i < LeafList.Count do begin
    j := i + 1;
    Changed := False;
    while j < LeafList.Count do begin
      Changed := SplitCharClass(LeafList[j], LeafList[i]);
      if not Changed then
        Inc(j)
      else
        break;
    end;
    if not Changed then
      Inc(i);
  end;
end; {procedure TREParser.ForceCharClassUnique}

procedure TREParseTree.DisposeTree;
var
  i: Integer;
begin
  if FNodeList <> nil then begin
    for i := 0 to FNodeList.Count - 1 do begin
      if FNodeList[i] <> nil then
        Dispose(REpNode_t(FNodeList.Items[i]));
    end;
    FNodeList.Clear;
  end;

  if FLeafList <> nil then begin
    for i := 0 to FLeafList.Count -1 do begin
      if FLeafList[i] <> nil then
        Dispose(REpNode_t(FLeafList[i]));
    end;
    FLeafList.Clear;
  end;
  FpHeadNode := nil;
end;

{-=========================== TREParser Class ===============================-}
constructor TREParser.Create(RegExpStr: String);
begin
  inherited Create;
  FScanner := TREScanner.Create(RegExpStr);
  FParseTree := TREParseTree.Create;
  {準備完了。 Runメソッドを呼べば構文解析をする。}
end;

destructor TREParser.Destroy;
begin
  FScanner.Free;
  FParseTree.Free;
  inherited Destroy;
end;

{**************************************************************************
  正規表現をパースするメソッド群
 **************************************************************************}
procedure TREParser.Run;
begin
  FParseTree.DisposeTree; {すでにある構文木を廃棄して初期化}

  FScanner.GetToken; {最初のトークンを読み込む}

  {正規表現をパースする}
  FParseTree.pHeadNode := regexp;

  {次のトークンがretk_End でなければエラー}
  if FScanner.Token <> retk_End then begin
    raise ERegExpParser.Create('正規表現に余分な文字があります',
      FScanner.Index);
  end;

  FParseTree.ForceCharClassUnique;{キャラクタクラスを分割してユニークにする}
end;

{ <regexp>をパースして、得られた構文木を返す。
  選択 X|Y を解析する }
function TREParser.regexp: REpNode_t;
begin
  result := term;
  while FScanner.Token = retk_Union do begin
    FScanner.GetToken;
    result := FParseTree.MakeInternalNode(reop_union, result, term);
  end;
end;

{ <term>をパースして、得られた構文木を返す
  連結ＸＹを解析する}
function TREParser.Term: REpNode_t;
begin
  if (FScanner.Token = retk_Union) or
     (FScanner.Token = retk_RPar) or
     (FScanner.Token = retk_End) then
    result := FParseTree.MakeInternalNode(reop_Empty, nil, nil)
  else begin
    result := factor;
    while (FScanner.Token <> retk_Union) and
          (FScanner.Token <> retk_RPar) and
          (FScanner.Token <> retk_End) do begin
      result := FParseTree.MakeInternalNode(reop_concat, result, factor);
    end;
  end;
end;

{ <factor>をパースして、得られた構文木を返す
  繰り返しX*, X+, X?を解析する}
function TREParser.Factor: REpNode_t;
begin
  result := primary;
  if FScanner.Token = retk_Star then begin
    result := FParseTree.MakeInternalNode(reop_closure, result, nil);
    FScanner.GetToken;
  end else if FScanner.Token = retk_Plus then begin
    result := FParseTree.MakeInternalNode(reop_concat, result,
      FParseTree.MakeInternalNode(reop_closure, result, nil));
    FScanner.GetToken;
  end else if FScanner.Token = retk_QMark then begin
    result := FParseTree.MakeInternalNode(reop_Union, result,
      FParseTree.MakeInternalNode(reop_Empty, nil, nil));
    FScanner.GetToken;
  end;
end;

{ <primary>をパースして、得られた構文木を返す。
  文字そのもの、(X)を解析する}
function TREParser.Primary: REpNode_t;
begin
  case FScanner.Token of
    retk_Char: begin
        result := FParseTree.MakeLeaf(FScanner.Symbol.WChar, FScanner.Symbol.WChar);
        FScanner.GetToken;
      end;
    retk_LHead: begin
        result := FParseTree.MakeLHeadNode(FScanner.Symbol.WChar);
        FScanner.GetToken;
      end;
    retk_LTail: begin
        result := FParseTree.MakeLTailNode(FScanner.Symbol.WChar);
        FScanner.GetToken;
      end;
    retk_Dot: begin
        result := FParseTree.MakeAnyCharsNode;
        FScanner.GetToken;
      end;
    retk_LPar: begin
        FScanner.GetToken;
        result := regexp;
        if FScanner.Token <> retk_RPar then
          raise ERegExpParser.Create('右(閉じ)括弧が必要です', FScanner.Index);
        FScanner.GetToken;
      end;
    retk_LBra, retk_LBraNeg: begin
        if FScanner.Token = retk_LBra then
          result := CharacterClass(FParseTree)
        else
          result := NegativeCharacterClass;
        if FScanner.Token <> retk_RBra then
          raise ERegExpParser.Create('右ブラケット"]"が必要です', FScanner.Index);
        FScanner.GetToken;
      end;
    else
      raise ERegExpParser.Create('普通の文字、または左括弧"("が必要です', FScanner.Index);
  end;
end;

{ <charclass> をパースして、得られた構文木を返す。
      [] で括られた正規表現を解析する}
function TREParser.CharacterClass(aParseTree: TREParseTree): REpNode_t;
  {Tokenに対応した葉を作る}
  function WCharToLeaf: REpNode_t;
  begin
    result := nil;
    case FScanner.Token of
      retk_Char:
        result := aParseTree.MakeLeaf(FScanner.Symbol.WChar, FScanner.Symbol.WChar);

      retk_CharClass:
        result := aParseTree.MakeLeaf(FScanner.Symbol.CharClass.StartChar,
                                      FScanner.Symbol.CharClass.EndChar);
    end;
  end;
begin {function TREParser.CharacterClass}
  FScanner.GetToken; {GetScannerCCは、retk_RBra, retk_Char, retk_CharClassしか返さない}
  if FScanner.Token = retk_RBra then
    raise ERegExpParser.Create('不正なキャラクタクラス指定です。', FScanner.Index);

  result := WCharToLeaf;
  FScanner.GetToken;
  while FScanner.Token <> retk_RBra do begin
    result := aParseTree.MakeInternalNode(reop_Union, result, WCharToLeaf);
    FScanner.GetToken;
  end;

end;{function TREParser.CharacterClass}


{ <negative charclass>をパースして、得られた構文木を返す。
  [^ ] で括られた正規表現を解析する}
function TREParser.NegativeCharacterClass: REpNode_t;
var
  aParseTree, aNeg_ParseTree: TREParseTree;
  i: Integer;
  aCharClass: RECharClass_t;
  procedure RemoveCC(pLeaf: REpNode_t);
  var
    i: Integer;
    pANode, pNode1, pNode2: REpNode_t;
  begin
    i := 0;
    while i < aNeg_ParseTree.LeafList.Count do begin
      pANode := aNeg_ParseTree.LeafList[i];
      if (pLeaf^.CharClass.EndChar < pANode^.CharClass.StartChar) or
      (pLeaf^.CharClass.StartChar > pANode^.CharClass.EndChar) then
        Inc(i)
      else begin
        pNode1 := aNeg_ParseTree.Check_and_MakeLeaf(pANode^.CharClass.StartChar,
          pLeaf^.CharClass.StartChar-1);
        pNode2 := aNeg_ParseTree.Check_and_MakeLeaf(pLeaf^.CharClass.EndChar+1,
          pANode^.CharClass.EndChar);
        if (pNode1 <> nil) or (pNode2 <> nil) then begin
          Dispose(REpNode_t(aNeg_ParseTree.LeafList[i]));
          aNeg_ParseTree.LeafList.Delete(i);
        end;
      end;
    end;
  end;
begin
{ [^abc] = . - [abc] という動作をする。}

  aParseTree := TREParseTree.Create;
  try
  aNeg_ParseTree := TREParseTree.Create;
  try
    {aParseTreeに'[]'で囲まれたキャラクタクラス正規表現の中に対応する節を作る。}
    aParseTree.pHeadNode := CharacterClass(aParseTree);
    {aParseTreeの葉が持つキャラクタクラスの範囲が重複しないように整形}
    aParseTree.ForceCharClassUnique;

    {任意の一文字を表す木をaNeg_ParseTreeに作成}
    aNeg_ParseTree.MakeAnyCharsNode;

    for i := 0 to aParseTree.LeafList.Count-1 do begin
      {aNeg_ParseTreeの葉からaParseTreeの葉と同じ物を削除}
      RemoveCC(aParseTree.LeafList[i]);
    end;

    {aNeg_ParseTreeの葉をFParseTreeにコピー}
    result := nil;
    if aNeg_ParseTree.LeafList.Count > 0 then begin
      aCharClass := REpNode_t(aNeg_ParseTree.LeafList[0])^.CharClass;
      result := FParseTree.MakeLeaf(aCharClass.StartChar, aCharClass.EndChar);
      for i := 1 to aNeg_ParseTree.LeafList.Count-1 do begin
        aCharClass := REpNode_t(aNeg_ParseTree.LeafList[i])^.CharClass;
        result := FParseTree.MakeInternalNode(reop_Union, result,
          FParseTree.MakeLeaf(aCharClass.StartChar, aCharClass.EndChar));
      end;
    end;
  finally
    aNeg_ParseTree.Free;
  end;
  finally
    aParseTree.Free;
  end;
end;

{$IFDEF DEBUG}
function DebugWCharToStr(WChar: WChar_t): String;
begin
  if WChar > $FF then
    result := ' ' + Chr(Hi(WChar))+Chr(Lo(WChar))+'($' + IntToHex(WChar, 4) + ')'
  else
    result := ' ' + Chr(Lo(WChar))+' ($00' + IntToHex(WChar, 2) + ')';

end;

{ デバッグ用メッソッド。構文木をVCL のTOutLineコンポーネントに書き込む}
{ 構文木が大きすぎると、TOutLineコンポーネントが”死ぬ”ので注意}
procedure TREParser.WriteParseTreeToOutLine(anOutLine: TOutLine);
  procedure SetOutLineRecursive(pTree: REpNode_t; ParentIndex: Integer);
  var
    aStr: String;
    NextParentIndex: Integer;
  begin
    if pTree = nil then
      exit;

    case pTree^.op of
      reop_Char: begin{ 文字そのもの }
          if pTree^.CharClass.StartChar <> pTree^.CharClass.EndChar then
            aStr := DebugWCharToStr(pTree^.CharClass.StartChar)
            + ' ～ '+ DebugWCharToStr(pTree^.CharClass.EndChar)
          else
            aStr := DebugWCharToStr(pTree^.CharClass.StartChar);
        end;
      reop_LHead:
          aStr := '文頭 '+DebugWCharToStr(pTree^.CharClass.StartChar);
      reop_LTail:
          aStr := '文尾 '+DebugWCharToStr(pTree^.CharClass.StartChar);
      reop_Concat:{ XY }
          aStr := '連結 ';
      reop_Union:{ X|Y}
          aStr := '選択 "|"';
      reop_Closure:{ X* }
          aStr := '閉包 "*"';
      reop_Empty:{ 空 }
          aStr := '空';
    end;

    NextParentIndex := anOutLine.AddChild(ParentIndex, aStr);

    if pTree^.op in [reop_Concat, reop_Union, reop_Closure] then begin
      SetOutLineRecursive(pTree^.Children.pLeft, NextParentIndex);
      SetOutLineRecursive(pTree^.Children.pRight, NextParentIndex);
    end;
  end;
begin
  anOutLine.Clear;
  SetOutLineRecursive(FParseTree.pHeadNode, 0);
end;

{$ENDIF}

{ -============================== TRE_NFA Class ==================================-}
constructor TRE_NFA.Create(Parser: TREParser; LHeadWChar, LTailWChar: WChar_t);
begin
  inherited Create;
  FStateList := TList.Create;
  FParser := Parser;
  FLHeadWChar := LHeadWChar;
  FLTailWChar := LTailWChar;
end;

destructor TRE_NFA.Destroy;
begin
  DisposeStateList;
  inherited Destroy;
end;

{ NFA状態表を破棄する}
procedure TRE_NFA.DisposeStateList;
var
  i: Integer;
  pNFANode, pNext: RE_pNFANode_t;
begin
  if FStateList <> nil then begin
    for i := 0 to FStateList.Count-1 do begin
      pNFANode := FStateList.Items[i];
      while pNFANode <> nil do begin
        pNext := pNFANode^.Next;
        Dispose(pNFANode);
        pNFANode := pNext;
      end;
    end;
    FStateList.Free;
    FStateList := nil;
  end;
end;

{ 構文木 Treeに対応するNFAを生成する}
procedure TRE_NFA.Run;
begin
  { NFA の初期状態のノードを割り当てる。}
  FEntryState := NumberNode;

  { NFA の終了状態のノードを割り当てる }
  FExitState := NumberNode;

  { NFA を生成する }
  GenerateStateList(FParser.ParseTree.pHeadNode, FEntryState, FExitState);
end;

{ ノードに番号を割り当てる}
function TRE_NFA.NumberNode: Integer;
begin
  with FStateList do begin
    result := Add(nil);
  end;
end;

{ NFA状態節 を１つ作成}
function TRE_NFA.MakeNFANode: RE_pNFANode_t;
begin
  New(result);
end;

{ FStateListに状態遷移を追加する。
  状態 TransFrom に対して aCharClass内の文字で状態 TransTo への遷移を追加する。}
procedure TRE_NFA.AddTransition(TransFrom, TransTo: Integer;
  aCharClass: RECharClass_t); {Char}
var
  pNFANode: RE_pNFANode_t;
begin
  pNFANode := MakeNFANode;

  with pNFANode^ do begin
    CharClass := aCharClass;
    TransitTo := TransTo;
    Next := RE_pNFANode_t(FStateList.Items[TransFrom]);
  end;
  FStateList.Items[TransFrom] := pNFANode;
end;

{ 構文木 pTree に対する StateListを生成する
  NFAの入り口をentry, 出口をway_outとする }
procedure TRE_NFA.GenerateStateList(pTree: REpNode_t; entry, way_out: Integer);
var
  aState1, aState2: Integer;
  aCharClass: RECharClass_t;
begin
  case pTree^.op of
    reop_Char:
        AddTransition(entry, way_out, pTree^.CharClass);
    reop_LHead: begin {'^'}
        {文頭メタキャラクタ'^' は TransFrom = FEntryStateのとき以外は、
         通常のキャラクタとして扱う。}
        if Entry <> FEntryState then begin
          AddTransition(entry, way_out, pTree^.CharClass);
        end else begin
          FRegExpHasLHead := True;
          with aCharClass do begin
            StartChar := FLHeadWChar;
            EndChar := FLHeadWChar;
          end;
          AddTransition(entry, way_out, aCharClass);
        end;
      end;
    reop_LTail: begin
        {行末メタキャラクタ '$'は、TransTo = FExitStateのとき以外は、
        通常のキャラクタとして扱う。}
        if way_out <> FExitState then begin
          AddTransition(entry, way_out, pTree^.CharClass);
        end else begin
          FRegExpHasLTail := True;
          with aCharClass do begin
            StartChar := FLTailWChar;
            EndChar := FLTailWChar;
          end;
          AddTransition(entry, way_out, aCharClass);
        end;
      end;
    reop_Union: begin  {'|'}
        GenerateStateList(pTree^.Children.pLeft, entry, way_out);
        GenerateStateList(pTree^.Children.pRight, entry, way_out);
      end;
    reop_Closure: begin {'*'}
        aState1 := NumberNode;
        aState2 := NumberNode;
        { 状態 entry → ε遷移 → 状態 aState1}
        AddTransition(entry, aState1, CONST_EMPTYCharClass);
        { 状態 aState1 → (pTree^.Children.pLeft)以下の遷移 → 状態 aState2}
        GenerateStateList(pTree^.Children.pLeft, aState1, aState2);
        { 状態 aState2 → ε遷移 → 状態 aState1}
        AddTransition(aState2, aState1, CONST_EMPTYCharClass);
        { 状態 aState1 → ε遷移 → 状態 way_out}
        AddTransition(aState1, way_out, CONST_EMPTYCharClass);
      end;
    reop_Concat: begin {'AB'}
        aState1 := NumberNode;
        { 状態 entry → (pTree^.Children.pLeft)遷移 → 状態 aState1}
        GenerateStateList(pTree^.Children.pLeft, entry, aState1);
        { 状態 aState1 → (pTree^.Children.pRight)遷移 → 状態 way_out}
        GenerateStateList(pTree^.Children.pRight, aState1, way_out);
      end;
    reop_Empty:
        AddTransition(entry, way_out, CONST_EMPTYCharClass);
    else begin
        raise Exception.Create('This cannot happen in TRE_NFA.GenerateStateList');
      end;
  end;
end;

{$IFDEF DEBUG}
{TStringsオブジェクトに、NFA の内容を書き込む}
procedure TRE_NFA.WriteNFAtoStrings(Strings: TStrings);
var
  i: Integer;
  pNFANode: RE_pNFANode_t;
  Str: String;
begin
  Strings.clear;
  Strings.BeginUpDate;
  for i := 0 to FStateList.Count-1 do begin
    pNFANode := FStateList.items[i];
    if i = EntryState then
      Str := Format('開始 %2d : ', [i])
    else if i = ExitState then
      Str := Format('終了 %2d : ', [i])
    else
      Str := Format('状態 %2d : ', [i]);
    while pNFANode <> nil do begin
      if pNFANode^.CharClass.StartChar = CONST_EMPTY then
        Str := Str + Format('ε遷移で 状態 %2d へ :',[pNFANode^.TransitTo])
      else if pNFANode^.CharClass.StartChar <> pNFANode^.CharClass.EndChar then
        Str := Str + Format('文字%s から%s で 状態 %2d へ :',
          [DebugWCharToStr(pNFANode^.CharClass.StartChar),
          DebugWCharToStr(pNFANode^.CharClass.EndChar), pNFANode^.TransitTo])
      else if pNFANode^.CharClass.StartChar = FLHeadWChar then begin
        Str := Str + Format('文頭コード%s で 状態 %2d へ :',
          [DebugWCharToStr(pNFANode^.CharClass.StartChar), pNFANode^.TransitTo]);
      end else if pNFANode^.CharClass.StartChar = FLTailWChar then begin
        Str := Str + Format('文尾コード%s で 状態 %2d へ :',
          [DebugWCharToStr(pNFANode^.CharClass.StartChar), pNFANode^.TransitTo]);
      end else
        Str := Str + Format('文字%s で 状態 %2d へ :',
          [DebugWCharToStr(pNFANode^.CharClass.StartChar), pNFANode^.TransitTo]);

      pNFANode := pNFANode^.Next;
    end;
    Strings.Add(Str);
  end;
  Strings.EndUpDate;
end;
{$ENDIF}

{ -========================== TRE_NFAStateSet Class =============================-}
constructor TRE_NFAStateSet.Create(StateMax: Integer);
var
  i: Integer;
begin
  inherited Create;
  FCapacity := StateMax div 8 + 1;
  GetMem(FpArray, FCapacity);
  for i := 0 to FCapacity-1 do
    FpArray^[i] := 0;
end;

destructor TRE_NFAStateSet.Destroy;
begin
  FreeMem(FpArray, FCapacity);
  inherited Destroy;
end;

function TRE_NFAStateSet.Has(StateIndex: Integer): Boolean;
begin
  result := (FpArray^[StateIndex div 8] and (1 shl (StateIndex mod 8))) <> 0;
end;

procedure TRE_NFAStateSet.Include(StateIndex: Integer);
begin
  FpArray^[StateIndex div 8] := FpArray^[StateIndex div 8] or
    (1 shl (StateIndex mod 8));
end;

function TRE_NFAStateSet.Equals(AStateSet: TRE_NFAStateSet): Boolean;
var
  i: Integer;
begin
  result := False;
  for i := 0 to FCapacity - 1 do begin
    if FpArray^[i] <> AStateSet.pArray^[i] then
      exit;
  end;
  result := True;
end;

{ -============================= TRE_DFA Class ==================================-}
constructor TRE_DFA.Create(NFA: TRE_NFA);
begin
  inherited Create;
  FNFA := NFA;
  FStateList := TList.Create;
end;

destructor TRE_DFA.Destroy;
begin
  DestroyStateList;

  inherited Destroy;
end;

{DFA状態のリストを破棄}
procedure TRE_DFA.DestroyStateList;
var
  i: Integer;
  pDFA_State: RE_pDFAState_t;
  pDFA_StateSub, pNextSub: RE_pDFAStateSub_t;
begin
  if FStateList <> nil then begin
    for i := 0 to FStateList.Count-1 do begin
      pDFA_State := FStateList.Items[i];
      if pDFA_State <> nil then begin
        pDFA_StateSub := pDFA_State^.next;
        while pDFA_StateSub <> nil do begin
          pNextSub := pDFA_StateSub^.next;
          Dispose(pDFA_StateSub);
          pDFA_StateSub := pNextSub;
        end;
        pDFA_State^.StateSet.Free;
        Dispose(pDFA_State);
      end;
    end;
    FStateList.Free;
    FStateList := nil;
  end;
end;

procedure TRE_DFA.Run;
begin
  FRegExpHasLHead := FNFA.RegExpHasLHead;
  FRegExpHasLTail := FNFA.RegExpHasLTail;
  Convert_NFA_to_DFA;   {NFA状態表からDFA状態表を作る}
  StateListSort;        {DFA状態表の節を入力キー順に整列する。※検索の高速化のため}
  CheckIfRegExpIsSimple;{正規表現が単純な文字列かチェック}
end;

{ NFAを等価なＤＦＡへと変換する}
procedure TRE_DFA.Convert_NFA_to_DFA;
var
  Initial_StateSet: TRE_NFAStateSet;
  t: RE_pDFAState_t;
  pDFA_TransNode, pTransNodeHead: RE_pDFATransNode_t;
  pDFA_StateSub: RE_pDFAStateSub_t;
begin
{DFAの初期状態を登録する}
  Initial_StateSet := TRE_NFAStateSet.Create(FNFA.StateList.Count);
  Initial_StateSet.Include(FNFA.EntryState);
  {ＮＦＡ初期状態の集合を求める（ε遷移も含む）}
  Collect_Empty_Transition(Initial_StateSet);
  FpInitialState := Register_DFA_State(Initial_StateSet);

  {未処理のＤＦＡ状態があれば、それを取り出して処理する
    注目しているＤＦＡ状態をｔとする}
  t := Fetch_Unvisited_D_state;
  while t <> nil do begin

    {処理済みの印を付ける}
    t^.visited := True;

    {状態ｔから遷移可能なDFA状態をすべてDFAに登録する。}
    pTransNodeHead := Compute_Reachable_N_state(t);
    try
    pDFA_TransNode := pTransNodeHead;
    while pDFA_TransNode <> nil do begin
      { NFA状態集合のε-closureを求める}
      Collect_Empty_Transition(pDFA_TransNode^.ToNFAStateSet);

      { 遷移情報をDFA状態に加える}
      New(pDFA_StateSub);
      with pDFA_StateSub^ do begin
        next := nil;
        CharClass := pDFA_TransNode^.CharClass;
        next := t^.next;
      end;
      t^.next := pDFA_StateSub;

      {現在のDFA状態からの遷移先の新しいDFA状態を登録}
      pDFA_StateSub^.TransitTo :=
        Register_DFA_State(pDFA_TransNode^.ToNFAStateSet);
      {Register_DFA_StateメソッドによりToNFAStateSetオブジェクトはDFA_Stateに所有される}
      {pDFA_TransNode^.ToNFAStateSet := nil;}

      pDFA_TransNode := pDFA_TransNode^.next;
    end;
    t := Fetch_Unvisited_D_state;
    finally
      Destroy_DFA_TransList(pTransNodeHead);
    end;
  end;
end;

{ NFA状態集合 StateSet に対して ε-closure操作を実行する。
  ε遷移で遷移可能な全てのＮＦＡ状態を追加する}
procedure TRE_DFA.Collect_Empty_Transition(StateSet: TRE_NFAStateSet);
var
  i: Integer;
  { NFA状態集合 StateSetにＮＦＡ状態 ｓを追加する。
    同時にＮＦＡ状態ｓからε遷移で移動できるＮＦＡ状態も追加する}
  procedure Mark_Empty_Transition(StateSet: TRE_NFAStateSet; s: Integer);
  var
    pNFANode: RE_pNFANode_t;
  begin
    StateSet.Include(s);
    pNFANode := FNFA.StateList[s];
    while pNFANode <> nil do begin
      if (pNFANode^.CharClass.StartChar = CONST_EMPTY) and
        (not StateSet.Has(pNFANode^.TransitTo)) then
        Mark_Empty_Transition(StateSet, pNFANode^.TransitTo);
      pNFANode := pNFANode^.next;
    end;
  end;
begin
  for i := 0 to FNFA.StateList.Count-1 do begin
    if StateSet.Has(i) then
      Mark_Empty_Transition(StateSet, i);
  end;
end;

{ NFA状態集合 aStateSet をＤＦＡに登録して、ＤＦＡ状態へのポインタを返す。
  aStateSetが終了状態を含んでいれば、acceptedフラグをセットする。
  すでにaStateSetがＤＦＡに登録されていたら何もしない}
function TRE_DFA.Register_DFA_State(var aStateSet: TRE_NFAStateSet): RE_pDFAState_t;
var
  i: Integer;
begin
  { NFA状態 aStateSet がすでにＤＦＡに登録されていたら、何もしないでリターンする}
  for i := 0 to FStateList.Count-1 do begin
    if RE_pDFAState_t(FStateList[i])^.StateSet.Equals(aStateSet) then begin
      result := RE_pDFAState_t(FStateList[i]);
      exit;
    end;
  end;

  {DFAに必要な情報をセットする}
  New(result);
  with result^ do begin
    StateSet := aStateSet;
    visited := False;
    if aStateSet.Has(FNFA.ExitState) then
      accepted := True
    else
      accepted := False;
    next := nil;
  end;
  aStateSet := nil;
  FStateList.add(result);
end;

{ 処理済みの印がついていないＤＦＡ状態を探す。
  見つからなければnilを返す。}
function TRE_DFA.Fetch_Unvisited_D_state: RE_pDFAState_t;
var
  i: Integer;
begin

  for i := 0 to FStateList.Count-1 do begin
    if not RE_pDFAState_t(FStateList[i])^.visited then begin
      result := FStateList[i];
      exit;
    end;
  end;
  result := nil;
end;

{Compute_Reachable_N_state が作る RE_DFATransNode_t型のリンクリストを破棄する}
procedure TRE_DFA.Destroy_DFA_TransList(pDFA_TransNode: RE_pDFATransNode_t);
var
  pNext: RE_pDFATransNode_t;
begin
  if pDFA_TransNode <> nil then begin
    while pDFA_TransNode <> nil do begin
      pNext := pDFA_TransNode^.next;
      if pDFA_TransNode^.ToNFAStateSet <> nil then
        pDFA_TransNode^.ToNFAStateSet.Free;
      Dispose(pDFA_TransNode);

      pDFA_TransNode := pNext;
    end;
  end;
end;

{ DFA状態pDFAStateから遷移可能なNFA状態を探して、リンクリストにして返す}
function TRE_DFA.Compute_Reachable_N_state(pDFAState: RE_pDFAState_t): RE_pDFATransNode_t;
var
  i: Integer;
  pNFANode: RE_pNFANode_t;
  a, b: RE_pDFATransNode_t;
label
  added;
begin
  result := nil;
try
  {すべてのＮＦＡ状態を順に調べる}
  for i := 0 to FNFA.StateList.Count-1 do begin

    { NFA状態iがDFA状態 pDFAStateに含まれていれば、以下の処理を行う}
    if pDFAState^.StateSet.Has(i) then begin

      { NFA状態 i から遷移可能なＮＦＡ状態をすべて調べてリストにする}
      pNFANode := RE_pNFANode_t(FNFA.StateList[i]);
      while pNFANode <> nil do begin
        if pNFANode^.CharClass.StartChar <> CONST_EMPTY then begin {ε遷移は無視}
          a := result;
          while a <> nil do begin
            if a^.CharClass.Chars = pNFANode^.CharClass.Chars then begin
              a^.ToNFAStateSet.Include(pNFANode^.TransitTo);
              goto added;
            end;
            a := a^.next;
          end;
          {キャラクタ pNFANode^.CharClass.cによる遷移が登録されていなければ追加}
          New(b);
          with b^ do begin
            CharClass := pNFANode^.CharClass;
            ToNFAStateSet := TRE_NFAStateSet.Create(FNFA.StateList.Count);
            ToNFAStateSet.Include(pNFANode^.TransitTo);
            next := result;
          end;
          result := b;
        added:
          ;
        end;
        pNFANode := pNFANode^.next;
      end;
    end;
  end;
except
  on EOutOfMemory do begin
    Destroy_DFA_TransList(result); {構築中のリスト廃棄}
    raise;
  end;
end;
end;

{状態リストのリンクリストを整列する(マージ・ソートを使用)}
procedure TRE_DFA.StateListSort;
var
  i: Integer;
  {マージ・ソート処理を再帰的に行う}
  function DoSort(pCell: RE_pDFAStateSub_t): RE_pDFAStateSub_t;
  var
    pMidCell, pACell: RE_pDFAStateSub_t;

    {2つのリストをソートしながら併合する}
    function MergeList(pCell1, pCell2: RE_pDFAStateSub_t): RE_pDFAStateSub_t;
    var
      Dummy: RE_DFAStateSub_t;
    begin
      Result := @Dummy;
      {どちらかのリストが、空になるまで反復}
      while (pCell1 <> nil) and (pCell2 <> nil) do begin
        {pCell1 と pCell2 を比較して小さい方をResultに追加していく}
        if pCell1^.CharClass.StartChar > pCell2^.CharClass.StartChar then begin
        {pCell2の方が小さい}
          Result^.Next := pCell2;
          Result := pCell2;
          pCell2 := pCell2^.Next;
        end else begin
        {pCell1の方が小さい}
          Result^.Next := pCell1;
          Result := pCell1;
          pCell1 := pCell1^.Next;
        end;
      end;
      {余ったリストをそのままresult に追加}
      if pCell1 = nil then
        Result^.Next := pCell2
      else
        Result^.Next := pCell1;

      result := Dummy.Next;
    end;

  {DoSort本体}
  begin
    if (pCell = nil) or (pCell^.Next = nil) then begin
      result := pCell;
      exit; {要素が１つ、または、無いときは、すぐに exit}
    end;

    {ACell が３番目のセルを指すようにする。無ければ、nil を持たせる}
    {リストが２～３個のセルを持つときにも、分割を行うようにする。}
    pACell := pCell^.Next^.Next;
    pMidCell := pCell;
    {MidCell が、リストの真ん中あたりのセルを指すようにする。}
    while pACell <> nil do begin
      pMidCell := pMidCell^.Next;
      pACell := pACell^.Next;
      if pACell <> nil then
        pACell := pACell^.Next;
    end;

    {MidCell の後ろでリストを２分割する}
    pACell := pMidCell^.Next;
    pMidCell^.Next := nil;

    result := MergeList(DoSort(pCell), DoSort(pACell));
  end;
begin {Sort 本体}
  for i := 0 to FStateList.Count-1 do begin
    RE_pDFAState_t(FStateList[i])^.next :=
      DoSort(RE_pDFAState_t(FStateList[i])^.next);
  end;
end;

{機能： 現在の正規表現が、普通の文字列か？
        普通の文字列だったら、FRegExpIsSimple = True; FSimpleRegExpStrに文字列に設定
        それ以外の場合は、    FRegExpIsSimple = False;FSimpleRegExpStr = ''}
procedure TRE_DFA.CheckIfRegExpIsSimple;
var
  pDFAState: RE_pDFAState_t;
  pSub: RE_pDFAStateSub_t;
  WChar: WChar_t;
begin
  FRegExpIsSimple := False;
  FSimpleRegExpStr := '';

  pDFAState := FpInitialState;

  while pDFAState <> nil do begin
    pSub := pDFAState^.next;
    if pSub = nil then
      break;
    if (pSub^.next <> nil) or
       {複数のキャラクタを受け入れる}
      (pSub^.CharClass.StartChar <> pSub^.CharClass.EndChar) or
       {キャラクタ範囲を持つ}
      (pDFAState^.Accepted and (pSub^.TransitTo <> nil))
      {受理後もキャラクタを受け入れる}then begin

      FSimpleRegExpStr := '';
      exit;
    end else begin
      WChar := pSub^.CharClass.StartChar;
      FSimpleRegExpStr := FSimpleRegExpStr + WCharToStr(WChar);
    end;
    pDFAState := pSub^.TransitTo;
  end;
  FRegExpIsSimple := True;
end;


{$IFDEF DEBUG}
{TStringsオブジェクトに、DFA の内容を書き込む}
procedure TRE_DFA.WriteDFAtoStrings(Strings: TStrings);
var
  i: Integer;
  pDFA_State: RE_pDFAState_t;
  pDFA_StateSub: RE_pDFAStateSub_t;
  Str: String;
begin
  Strings.clear;
  Strings.BeginUpDate;
  for i := 0 to FStateList.Count-1 do begin
    pDFA_State := FStateList.items[i];
    if pDFA_State = FpInitialState then
      Str := Format('開始 %2d : ', [i])
    else if pDFA_State^.Accepted then
      Str := Format('終了 %2d : ', [i])
    else
      Str := Format('状態 %2d : ', [i]);
    pDFA_StateSub := pDFA_State^.next;
    while pDFA_StateSub <> nil do begin
      if pDFA_StateSub^.CharClass.StartChar <> pDFA_StateSub^.CharClass.EndChar then
         Str := Str + Format('文字 %s から 文字%s で 状態 %2d へ :',
          [DebugWCharToStr(pDFA_StateSub^.CharClass.StartChar),
           DebugWCharToStr(pDFA_StateSub^.CharClass.EndChar),
          FStateList.IndexOf(pDFA_StateSub^.TransitTo)])

      else if pDFA_StateSub^.CharClass.StartChar = FNFA.LHeadWChar then begin
        Str := Str + Format('文頭コード %s で 状態 %2d へ :',
          [DebugWCharToStr(pDFA_StateSub^.CharClass.StartChar),
          FStateList.IndexOf(pDFA_StateSub^.TransitTo)]);
      end else if pDFA_StateSub^.CharClass.StartChar = FNFA.LTailWChar then begin
        Str := Str + Format('文尾コード %s で 状態 %2d へ :',
          [DebugWCharToStr(pDFA_StateSub^.CharClass.StartChar),
          FStateList.IndexOf(pDFA_StateSub^.TransitTo)]);
      end else
        Str := Str + Format('文字 %s で 状態 %2d へ :',
          [DebugWCharToStr(pDFA_StateSub^.CharClass.StartChar),
          FStateList.IndexOf(pDFA_StateSub^.TransitTo)]);

      pDFA_StateSub := pDFA_StateSub^.Next;
    end;
    Strings.Add(Str);
  end;
  Strings.EndUpDate;
end;
{$ENDIF}

{ -=================== TRegularExpression Class ==============================-}
constructor TRegularExpression.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRegExpList := TStringList.Create;
  FRegExpListMax := 30; {RegExpListの項目数設定 30}
  {FCurrentIndex = 0 はヌルの正規表現で常に使えるようにする。}
  FCurrentIndex := FRegExpList.Add('');
  FPreProcessor := TREPreProcessor.Create('');
  Translate(FRegExpList[FCurrentIndex]);
end;

destructor TRegularExpression.Destroy;
begin
  FPreProcessor.Free;
  DisposeRegExpList;
  inherited Destroy;
end;

{正規表現リスト(FRegExpList: TStringList)とObjectsプロパティに結び付けられた
 TRE_DFAオブジェクトを破棄}
procedure TRegularExpression.DisposeRegExpList;
var
  i: Integer;
begin
  if FRegExpList <> nil then begin
    with FRegExpList do begin
      for i := 0 to Count-1 do begin
        TRE_DFA(Objects[i]).Free;
      end;
    end;
    FRegExpList.Free;
    FRegExpList := nil;
  end;
end;

{ ---------------------- プロパティ アクセス メソッド -----------------}
{RegExpプロパティのwriteメソッド}
procedure TRegularExpression.SetRegExp(Str: String);
var
  OrigRegExp: String;
  function FindRegExpInList(RegExpStr: String): Integer;
  var
    i: Integer;
  begin
    result := -1;
    i := 0;
    while i < FRegExpList.Count do begin
      if RegExpStr = FRegExpList[i] then begin
        result := i;
        exit;
      end;
      Inc(i);
    end;
  end;
begin
  OrigRegExp := Str;{プリプロセッサを通る前の正規表現を退避}
  with FPreProcessor do begin
    TargetRegExpStr := Str;
    Run;
    Str := ProcessedRegExpStr;
  end;

  try
    FCurrentIndex := FindRegExpInList(Str);
    {FRegExpList内にキャッシュされていないときは、コンパイル}
    if FCurrentIndex = -1 then begin
      if FRegExpList.Count = FRegExpListMax then begin
        TRE_DFA(FRegExpList.Objects[FRegExpList.Count-1]).Free;
        FRegExpList.Delete(FRegExpList.Count-1);
      end;
      FRegExpList.Insert(1, Str);
      FCurrentIndex := 1;
      Translate(FRegExpList[1]);
    end;
    FRegExp := OrigRegExp;
  except
    {例外が発生したときは、常にヌル正規表現を設定する。}
    on Exception do begin
      FCurrentIndex := 0;
      FRegExp := '';
      raise;
    end;
  end;
end;

{RegExpプロパティのreadメソッド}
function TRegularExpression.GetProcessedRegExp: String;
begin
  result := FRegExpList[FCurrentIndex];
end;

{ListOfFuzzyCharDicプロパティ readメソッド}
function TRegularExpression.GetListOfFuzzyCharDic: TList;
begin
  result := FPreProcessor.ListOfFuzzyCharDic;
end;

{GetListOfSynonymDicプロパティ readメソッド}
function TRegularExpression.GetListOfSynonymDic: TList;
begin
  result := FPreProcessor.ListOfSynonymDic;
end;

{RegExpIsSimpleプロパティ readメソッド}
function TRegularExpression.GetRegExpIsSimple: Boolean;
begin
  result := GetCurrentDFA.RegExpIsSimple;
end;

{SimpleRegExpプロパティ readメソッド}
function TRegularExpression.GetSimpleRegExp: String;
begin
  result := GetCurrentDFA.SimpleRegExpStr;
end;

{HasLHeadプロパティ readメソッド}
function TRegularExpression.GetHasLHead: Boolean;
begin
  result := GetCurrentDFA.RegExpHasLHead;
end;

{HasLTailプロパティ writeメソッド}
function TRegularExpression.GetHasLTail: Boolean;
begin
  result := GetCurrentDFA.RegExpHasLTail;
end;

{現在の正規表現に対応するTRE_DFA型オブジェクトを得る}
function TRegularExpression.GetCurrentDFA: TRE_DFA;
begin
  result := TRE_DFA(FRegExpList.Objects[FCurrentIndex]);
end;

{DFA状態表の初期状態を表すノードへのポインタを得ることができる。}
function TRegularExpression.GetpInitialDFAState: RE_pDFAState_t;
begin
  result := TRE_DFA(FRegExpList.Objects[FCurrentIndex]).pInitialState;
end;

function  TRegularExpression.GetUseFuzzyCharDic: Boolean;
begin
  result := FPreProcessor.UseFuzzyCharDic;
end;

procedure TRegularExpression.SetUseFuzzyCharDic(Val: Boolean);
begin
  FPreProcessor.UseFuzzyCharDic := Val;
  Self.RegExp := FRegExp; {新しい設定で再コンパイル}
end;

function  TRegularExpression.GetUseSynonymDic: Boolean;
begin
  result := FPreProcessor.UseSynonymDic;
end;

procedure TRegularExpression.SetUseSynonymDic(Val: Boolean);
begin
  FPreProcessor.UseSynonymDic := Val;
  Self.RegExp := FRegExp; {新しい設定で再コンパイル}
end;

function TRegularExpression.GetLineHeadWChar: WChar_t;
begin
  result := CONST_LINEHEAD;
end;

function TRegularExpression.GetLineTailWChar: WChar_t;
begin
  result := CONST_LINETAIL;
end;

{*****     正規表現文字列→構文木構造→NFA→DFA の変換を行う *****}
procedure TRegularExpression.Translate(RegExpStr: String);
var
  DFA: TRE_DFA;
  Parser: TREParser;
  NFA: TRE_NFA;
begin
  DFA := nil;
  try
    Parser := TREParser.Create(RegExpStr);
    try
      Parser.Run;
      NFA := TRE_NFA.Create(Parser, GetLineHeadWChar, GetLineTailWChar);
      try
        Self.FLineHeadWChar := NFA.LHeadWChar;
        Self.FLineTailWChar := NFA.LTailWChar;
        NFA.Run;
        DFA := TRE_DFA.Create(NFA);
        FRegExpList.Objects[FCurrentIndex] := DFA;
        TRE_DFA(FRegExpList.Objects[FCurrentIndex]).Run;
      finally
        NFA.Free;
      end;
    finally
      Parser.Free;
    end;
  except
    On Exception do begin
      DFA.Free;
      FRegExpList.Delete(FCurrentIndex);
      FCurrentIndex := 0;
      raise;
    end;
  end;
end;

{状態 DFAstateから文字ｃによって遷移して、遷移後の状態を返す。
 文字ｃによって遷移出来なければnilを返す}
function TRegularExpression.NextDFAState(DFAState: RE_pDFAState_t; c: WChar_t): RE_pDFAState_t;
var
  pSub: RE_pDFAStateSub_t;
begin
  {１つのDFAStateが持つ pSubのリンクではキャラクタクラスが昇順にならんでいること
  を前提としている。}
  result := nil;
  pSub := DFAState^.next;
  while pSub <> nil do begin
    if c < pSub^.CharClass.StartChar then
      exit
    else if c <= pSub^.CharClass.EndChar then begin
      result := pSub^.TransitTo;
      exit;
    end;
    pSub := pSub^.next;
  end;
end;

constructor TMatchCORE.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLineSeparator := mcls_CRLF;
end;

procedure TMatchCORE.MatchStd(pText: PChar; var pStart, pEnd: PChar);
var
  pDFAState: RE_pDFAState_t;
  pp: PChar;
begin
  pStart := nil;
  pEnd := nil;

  {pTextがヌル文字列で、正規表現がヌル文字列に一致するとき}
  if (Byte(pText^) = CONST_NULL) and GetCurrentDFA.pInitialState.Accepted then begin
    pStart := pText;
    pEnd := pText;
    exit;
  end;

  {注目点を１文字づつずらしながらマッチする最左部分を見つける}
  while Byte(pText^) <> CONST_NULL do begin
    {DFAの初期状態を設定}
    pDFAState := Self.GetCurrentDFA.pInitialState;
    pp := pText;
    {DFA状態表に文字を入力していってマッチする最長部分を見つける}
    repeat
      if pDFAState^.accepted then begin
      {終了状態であれば場所を記録しておく。
       結果としてマッチした最左最長部分が記録される}
        pStart := pText;
        pEnd := pp;
      end;
      {次の状態に遷移}
      pDFAState := NextDFAState(pDFAState, PCharGetWChar(pp));
    until pDFAState = nil;

    {マッチしたときはExit}
    if pStart <> nil then
      exit;

    {注目位置を１文字分進める。}
    if IsDBCSLeadByte(Byte(pText^)) then
      Inc(pText, 2)
    else
      Inc(pText);
  end;
  {マッチしない。}
end;

procedure TMatchCORE.MatchEX(pText: PChar; var pStart, pEnd: PChar);
begin
  pStart := pText;
  pEnd := MatchHead(pText, GetCurrentDFA.pInitialState);
  if pEnd = nil then
    MatchEX_Inside(pText, pStart, pEnd);
end;

procedure TMatchCORE.MatchEX_Inside(pText: PChar; var pStart, pEnd: PChar);
var
  DFA: TRE_DFA;
  pInitialDFAState: RE_pDFAState_t;
begin
  pStart := nil;
  pEnd := nil;

  DFA := GetCurrentDFA;
  pInitialDFAState := DFA.pInitialState;
  while Byte(pText^) <> CONST_NULL do begin
    pEnd := MatchInSide(pText, pInitialDFAState);
    if pEnd <> nil then begin
      pStart := pText;
      exit;
    end else if (Byte(pText^) = CONST_LF) and
      DFA.RegExpHasLHead then begin
      pEnd := MatchHead(pText+1, pInitialDFAState);
      if pEnd <> nil then begin
        pStart := pText+1;
        exit;
      end;
    end;
    {注目位置を１文字分進める。}
    if IsDBCSLeadByte(Byte(pText^)) then
      Inc(pText, 2)
    else
      Inc(pText);
  end;

  if DFA.RegExpHasLTail and (NextDFAState(pInitialDFAState, LineTailWChar) <> nil) then begin
  {正規表現が文尾メタキャラクタのみのとき(RegExp = '$')の特殊処理}
    pStart := pText;
    pEnd := pText;
  end;
 end;

function TMatchCORE.MatchHead(pText: PChar; pDFAState: RE_pDFAState_t): PChar;
var
  pEnd: PChar;
begin
{正規表現が行頭メタキャラクタを含んでいる}
  if GetCurrentDFA.RegExpHasLHead then begin
    result := MatchInSide(pText, NextDFAState(pDFAState, LineHeadWChar));
    if result <> nil then begin
    {マッチした。この時点で、result <> nil 確定}
      pEnd := result;
      {さらに、RegExp = '(^Love|Love me tender)'で、Text = 'Love me tender. Love me sweet'
       の場合に最左最長でマッチするのは、'Love me tender'でなければならないので、その為の
       マッチ検査を行う。}
      result := MatchInside(pText, pDFAState);
      if (result = nil) or (pEnd > result) then
        result := pEnd;
    end;
  end else begin
{正規表現が行頭メタキャラクタを含んでいない}
    result := MatchInside(pText, pDFAState);
  end;
end;

function TMatchCORE.MatchInside(pText: PChar; pDFAState: RE_pDFAState_t): PChar;
var
  pEnd: PChar;
  WChar: WChar_t;
  pPrevDFAState: RE_pDFAState_t;
begin
  result := nil;
  pEnd := pText;

  if pDFAState = nil then
    exit;
  repeat
    if pDFAState^.accepted then begin
    {終了状態であれば場所を記録しておく。
     結果としてマッチした最左最長部分が記録される}
        result :=  pEnd;
    end;
    pPrevDFAState := pDFAState;
    {DFAを状態遷移させる}
    WChar := PCharGetWChar(pEnd);
    pDFAState := NextDFAState(pDFAState, WChar);
  until pDFAState = nil;

  if (IsLineEnd(WChar) or (WChar = CONST_NULL)) and
    (NextDFAState(pPrevDFAState, LineTailWChar) <> nil) then begin
    {行末メタキャラクタを入力して、nil以外が帰ってくるときは必ず、マッチする}
      result := pEnd;
      if WChar <> CONST_NULL then
        Dec(result); {CR($0d)の分 Decrement}
  end;
end;

function TMatchCORE.IsLineEnd(WChar: WChar_t): Boolean;
begin
  result := False;
  case FLineSeparator of
    mcls_CRLF:  result := (WChar = CONST_CR);
    mcls_LF:    result := (WChar = CONST_LF);
  end;
end;

{ -========================== TAWKStr Class ==================================- }
constructor TAWKStr.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  
  ListOfFuzzyCharDic.Add(RE_FuzzyCharDic); {キャラクタ同一視辞書を追加}
end;

procedure TAWKStr.SetRegExp(Str: String);
begin
  inherited SetRegExp(Str);
  if not (HasLHead or HasLTail) then begin
    FMatchProc := MatchStd;
  end else begin
    FMatchProc := MatchEx;
  end;
end;

{文字列中の'\' で 引用されたキャラクタを処理する。 \n, \t \\ ...}
function TAWKStr.ProcessEscSeq(Text: String): String;
var
  WChar: WChar_t;
  Index: Integer;
begin
  result := '';
  Index := 1;
  while Index <= Length(Text) do begin
    WChar := GetWChar(Text, Index);
    if WChar = Ord('\') then
      result := result + WCharToStr(GetQuotedWChar(Text, Index))
    else
      result := result + WCharToStr(WChar);
  end;
end;

{Sub, GSubメソッドで使用。 '&'をマッチした文字列に置換える}
function TAWKStr.Substitute_MatchStr_For_ANDChar(Text: String; MatchStr: String): String;
var
  i: Integer;
  aStr: String;
  WCh, WCh2: WChar_t;
begin
  i := 1;
  aStr := '';
{'\&'を'\\&'にしてから}
  while i <= Length(Text) do begin
    WCh := GetWChar(Text, i);
    if WCh = CONST_YEN then begin
      aStr := aStr + WCharToStr(WCh);

      WCh := GetWChar(Text, i);
      if WCh = CONST_ANP then begin
        aStr := Concat(aStr, WCharToStr(CONST_YEN));
      end;
    end;
    aStr := aStr + WCharToStr(WCh);
  end;

{エスケープ・シーケンスを処理}
  Text := ProcessEscSeq(aStr);

{'&' を MatchStrで置換え、'\&'を'&'に置換え}
  result := '';
  i := 1;
  while i <= Length(Text) do begin
    WCh := GetWChar(Text, i);
    if WCh = CONST_ANP then
      result := Concat(result, MatchStr)
    else if WCh = CONST_YEN then begin
      WCh2 := GetWChar(Text, i);
      if WCh2 = CONST_ANP then begin
        result := result + WCharToStr(WCh2);
      end else begin
        if WCh2 <> CONST_NULL then
          UnGetWChar(Text, i);
        result := result + WCharToStr(WCh);
      end;
    end else begin
      result := result + WCharToStr(WCh);
    end;
  end;
end;

function TAWKStr.Match(Text: String; var RStart, RLength: Integer): Integer;
var
  pStart, pEnd: PChar;
begin
  FMatchProc(PChar(Text), pStart, pEnd);
  if pStart = nil then begin
    RStart := 0;
    RLength := 0;
    result := 0;
  end else begin
    RStart := pStart - PChar(Text)+1; {RStartは１ベース}
    RLength := pEnd - pStart;
    result := RStart;
  end;
end;

{AWK Like function Sub_Raw}
function TAWKStr.Sub(SubText: String; var Text: String): Boolean;
var
  pStart, pEnd: PChar;
  MatchStr: String;
begin
  FMatchProc(PChar(Text), pStart, pEnd);
  if pStart <> nil then begin
{マッチした}
    MatchStr := Copy(Text, pStart-PChar(Text)+1, pEnd-pStart); {マッチした部分}
    Delete(Text, pStart-PChar(Text)+1, pEnd-pStart);
    {SubTextのなかの&キャラクタをマッチした部分(MatchStr)で置換える。}
    SubText := Substitute_MatchStr_For_ANDChar(SubText, MatchStr);
    Insert(SubText, Text, pStart-PChar(Text)+1);
    result := True;
  end else begin
{マッチしない}
    result := False;
  end;
end;

{AWK Like GSubRaw }
function TAWKStr.GSub(SubText: String; var Text: String): Integer;
var
  pStart, pEnd: PChar;
  ResultText, aText: String;
  MatchStr: String;
  WChar: WChar_t;
begin
  ResultText := ''; {結果の文字列を入れる変数}
  aText := Text;    {検索対象として使う}
  result := 0;
  FMatchProc(PChar(aText), pStart, pEnd);
  if pStart = nil then
    exit  {何もマッチしない}
  else if aText = '' then begin
    result := 1; {マッチしたが Text=''}
    Text := Substitute_MatchStr_For_ANDChar(SubText, '');
    exit;
  end;

  {マッチして Text <> ''}
  while True do begin
    ResultText := Concat(ResultText, Copy(aText, 1, pStart-PChar(aText)));{前半部分}
    MatchStr := Copy(aText, pStart-PChar(aText)+1, pEnd-pStart);   {マッチした部分文字列}
    MatchStr := Substitute_MatchStr_For_ANDChar(SubText, MatchStr);
    ResultText := Concat(ResultText, MatchStr);{+ 置換文字列}

    if pStart = pEnd then begin {空文字列にマッチしたときの特殊処理}
      if isDBCSLeadByte(Byte(pStart^)) or
         ((LineSeparator = mcls_CRLF) and (Byte(pStart^) = CONST_CR)) then begin
        ResultText := Concat(ResultText, Copy(aText, pStart-PChar(aText)+1, 2));
        Inc(pEnd, 2);
      end else begin
        ResultText := Concat(ResultText, Copy(aText, pStart-PChar(aText)+1, 1));
        if Byte(pEnd^) <> CONST_NULL then
          Inc(pEnd, 1);
      end;
    end;
    Inc(result);

    WChar := Byte((pEnd-1)^);
    {Chr($0a)を調べる為だけなので、２バイト文字の考慮不要。 aText = ''はありえない}
    aText := String(pEnd);
    {マッチした部分文字列の後の部分をaTextに設定}
    if aText = '' then
      break;
    if WChar = CONST_LF then begin
      FMatchProc(PChar(aText), pStart, pEnd);
      if pStart = nil then
        break;
    end else begin
      MatchEX_Inside(PChar(aText), pStart, pEnd);
      if pStart = nil then
        break;
    end;
  end;
  Text := Concat(ResultText, aText);
end;

function TAWKStr.Split(Text: String; StrList: TStrings): Integer;
var
  pStart, pEnd: PChar;
  Str: String;
begin
  StrList.Clear;{結果文字列リストの内容クリア}
  Str := '';
  while Text <> '' do begin
    FMatchProc(PChar(Text), pStart, pEnd);
    if pStart = nil then begin
    {マッチしなかったとき}
      StrList.Add(Concat(Str, Text));
      Str := '';
      break;
    end else if (pStart = PChar(Text)) and (pStart = pEnd) then begin
    {先頭のヌル文字列にマッチしたときの特殊処理}
      if IsDBCSLeadByte(Byte(Text[1])) then begin
        Str := Concat(Str, Copy(Text, 1, 2));
        Text := Copy(Text, 3, Length(Text));
      end else begin
        Str := Concat(Str, Text[1]);
        Text := Copy(Text, 2, Length(Text));
      end;
    end else begin;
    {マッチした}
      StrList.Add(Concat(Str, Copy(Text, 1, pStart-PChar(Text))));
      Str := '';
      Text := String(pEnd);
      if Text = '' then begin
      {最後尾にマッチしたときの特殊処理}
        StrList.Add('');
        break;
      end;
    end;
  end;
  if Str <> '' then
    StrList.Add(Str);
  result := StrList.Count;
end;

{ -=========================== TTxtFile Class ================================-}
constructor TTxtFile.Create(aFileName: String; var CancelRequest: Boolean);
begin
  inherited Create;
  FpCancelRequest := @CancelRequest; {CancelRequestがTrueで途中終了する}

  FBuffSize := 1024*100; {バッファのサイズ}
  FTailMargin := 100;

  FFileName := aFileName;
  System.FileMode := 0; {ファイルアクセスモード を読み出し専用に設定}
  AssignFile(FF, FFileName);
  try
    Reset(FF, 1);
  except
    on E: EInOutError do begin
      raise EFileNotFound.Create(E.Message);
    end;
  end;
  FFileOpened := True;  { ファイルオープンのフラグ。Destroyで使用する}
  FpBuff := AllocMem(FBuffSize+FTailMargin);
  FpBuff^ := Chr($0a);  { ファイル先頭行の行頭にＬＦ Chr($0a)を付加}
  BuffRead(FpBuff+1);
  Inc(FReadCount);      { 先頭のＬＦ($0a)のぶんを加算}
  FpBase := FpBuff;
  FpLineBegin := FpBuff;
  FpForward := FpBuff;
  FLineNo := 0;
end;

destructor TTxtFile.Destroy;
begin
  if FFileOpened then
    CloseFile(FF);

  if FpBuff <> nil then begin
    FreeMem(FpBuff, FBuffSize+FTailMargin);
  end;

  inherited Destroy;
end;

procedure TTxtFile.BuffRead(pBuff: PChar);
begin
  BlockRead(FF, pBuff^, FBuffSize, FReadCount);
  if FReadCount = 0 then begin
    {FpLineBegin := FpBase;}
    raise EEndOfFile.Create('End Of File');
  end;

  {読み込んだデータの最後にヌル・キャラクタを書き込む}
  if not Eof(FF) then begin
    (pBuff+FReadCount)^ := Chr(0);
  end else begin
    if (pBuff+FReadCount-1)^ <> Chr($0a) then begin
      (pBuff+FReadCount)^ := Chr($0a);
      (pBuff+FREadCount+1)^ := Chr(0);
      (pBuff+FReadCount+2)^ := Chr(0);
      Inc(FReadCount);
    end else begin
      (pBuff+FReadCount)^ := Chr(0);
      (pBuff+FreadCount+1)^ := Char(0);
    end;
  end;

  Application.ProcessMessages;
  if FpCancelRequest^ then
    raise EGrepCancel.Create('CancelRequest');
end;

procedure TTxtFile.IncPBaseNullChar(Ch: Char);
var
  Distance: Integer;
begin
  if FpBase = (PChar(FBrokenLine)+Length(FBrokenLine)) then begin
  {FBrokenLine(String型) の中でChr(0)に達したとき。}
    FpBase := FpBuff;
  end else begin    
  {FpBuff(PChar) バッファの中でChr(0)に達したとき。}    
    if FpBase < FpBuff+FReadCount then begin
    {ファイル中の不正なヌルキャラクタ Chr(0)は、Space($20)に補正}   
      FpBase^ := Chr($20);    
    end else begin    
    {バッファの終わりに来た}    
      if Eof(FF) then begin   
      {ファイルの終わりに来た}    
        if Ch = Chr(0) then   
          Dec(FpBase);    
        raise EEndOfFile.Create('End Of File');   
      end else begin    
      {ファイルをまだ読める}    
        if (FpLineBegin >= PChar(FBrokenLine)) and    
        (FpLineBegin < (PChar(FBrokenLine)+Length(FBrokenLine))) then begin
        {FpLineBeginがFBrokenLineの中を指している。}    
          Distance := FpLineBegin-PChar(FBrokenLine);   
          FBrokenLine := Concat(FBrokenLine, String(FpBuff));   
          FpLineBegin := PChar(FBrokenLine)+Distance;   
          BuffRead(FpBuff);   
          FpBase := FpBuff;   
        end else begin    
        {FpLineBeginがバッファ中を指しているのでそこからFBrokenLineを取る}    
          FBrokenLine := String(FpLineBegin);   
          BuffRead(FpBuff);   
          FpBase := FpBuff;   
          FpLineBegin := PChar(FBrokenLine);    
        end;
      end;    
    end;    
  end;    
end;

{機能： FpBaseをインクリメントして、次の１バイトを指すようにする。}
function TTxtFile.IncPBase: Char;
var
  ApBase: PChar;
begin
  result := FpBase^;
  Inc(FpBase);
  if FpBase^ = Chr(0) then
  {ヌル・キャラクタの処理}
    IncPBaseNullChar(result);
  if result = Chr($0a) then begin
  {改行処理}
    if (FpBase < PChar(FBrokenLine)) or (FpBase > (PChar(FBrokenLine) +
    Length(FBrokenLine))) then begin
    {FpBaseがバッファを指しているとき}
      FBrokenLine := '';
      FpLineBegin := FpBase;
      Inc(FLineNo);
    end else begin
    {FpBaseがFBrokenLine中を指しているとき}
      FpLineBegin := FpBase;
      Inc(FLineNo);
    end;
  end;
  if FpBase^ = Chr($0d) then begin
    ApBase := FpBase;
    Inc(FpBase);
    if FpBase^ = Chr(0) then
    {ヌル・キャラクタの処理}
      IncPBaseNullChar(result);
    if FpBase^ <> Chr($0a) then begin
    { CR($0d)の次がLF($0a)でないときは、$0dを$0aに置換する。}
      if FpBase = FpBuff then
        FpBase := PChar(FBrokenLine)+Length(FBrokenLine)-1
      else
        FpBase := ApBase;
      FpBase^ := Chr($0a);
    end
  end;
  FpForward := FpBase;
end;

function TTxtFile.AdvanceBase: WChar_t;
var
  ApBase: PChar;
  Ch: Char;
begin
  {↓高速化のためIncPBase埋め込み}
    Ch := FpBase^;
    Inc(FpBase);
    if FpBase^ = Chr(0) then
    {ヌル・キャラクタの処理}
      IncPBaseNullChar(Ch);
    if Ch = Chr($0a) then begin
    {改行処理}
      if (FpBase < PChar(FBrokenLine)) or (FpBase > (PChar(FBrokenLine) +
      Length(FBrokenLine))) then begin
      {FpBaseがバッファを指しているとき}
        FBrokenLine := '';
        FpLineBegin := FpBase;
        Inc(FLineNo);
      end else begin
      {FpBaseがFBrokenLine中を指しているとき}
        FpLineBegin := FpBase;
        Inc(FLineNo);
      end;
    end;
    if FpBase^ = Chr($0d) then begin
      ApBase := FpBase;
      Inc(FpBase);
      if FpBase^ = Chr(0) then
      {ヌル・キャラクタの処理}
        IncPBaseNullChar(ApBase^);
      if FpBase^ <> Chr($0a) then begin
      { CR($0d)の次がLF($0a)でないときは、$0dを$0aに置換する。}
        if FpBase = FpBuff then
          FpBase := PChar(FBrokenLine)+Length(FBrokenLine)-1
        else
          FpBase := ApBase;
        FpBase^ := Chr($0a);
      end
    end;
    {↑高速化のためIncPBase埋め込み}
    result := Byte(Ch);
    case result of
      $81..$9F, $E0..$FC: begin
          {↓高速化のためIncPBase埋め込み}
          Ch := FpBase^;
          Inc(FpBase);
          if FpBase^ = Chr(0) then
          {ヌル・キャラクタの処理}
            IncPBaseNullChar(Ch);
          if Ch = Chr($0a) then begin
          {改行処理}
            if (FpBase < PChar(FBrokenLine)) or (FpBase > (PChar(FBrokenLine) +
            Length(FBrokenLine))) then begin
            {FpBaseがバッファを指しているとき}
              FBrokenLine := '';
              FpLineBegin := FpBase;
              Inc(FLineNo);
            end else begin
            {FpBaseがFBrokenLine中を指しているとき}
              FpLineBegin := FpBase;
              Inc(FLineNo);
            end;
          end;
          if FpBase^ = Chr($0d) then begin
            ApBase := FpBase;
            Inc(FpBase);
            if FpBase^ = Chr(0) then
            {ヌル・キャラクタの処理}
              IncPBaseNullChar(ApBase^);
            if FpBase^ <> Chr($0a) then begin
            { CR($0d)の次がLF($0a)でないときは、$0dを$0aに置換する。}
              if FpBase = FpBuff then
                FpBase := PChar(FBrokenLine)+Length(FBrokenLine)-1
              else
                FpBase := ApBase;
              FpBase^ := Chr($0a);
            end
          end;
          {↑高速化のためIncPBase埋め込み}
          result := (result shl 8) or Byte(Ch);
        end;
    end;
    FpForward := FpBase;
end;

procedure TTxtFile.GetCharNullChar(Ch: Char);
var
  Distance, Distance2: Integer;
begin
  if FpForward = (PChar(FBrokenLine)+Length(FBrokenLine)) then begin
  {FBrokenLine(String型) の中でChr(0)に達したとき。}
    FpForward := FpBuff;
  end else begin
  {FpBuff バッファの中でChr(0)に達したとき。}
    if FpForward < FpBuff+FReadCount then begin
    {ファイル中の不正なヌルキャラクタ Chr(0) は Space($20)にする。}
      FpForward^ := Chr($20);
    end else begin
    {バッファの終わりに来た}
      if Eof(FF) then begin
      {すでにファイルの終わりに達しているとき}
        if Ch = Chr(0) then
          Dec(FpForward);     {ずnっとresut = Chr(0)を返すようにする}
        exit;
      end else begin
      {まだファイルを読めるとき}
        if (FpLineBegin >= PChar(FBrokenLine)) and
        (FpLineBegin < PChar(FBrokenLine)+Length(FBrokenLine)) then begin
        {FpLineBeginがFBrokenLine中を指しているとき}
          Distance := FpLineBegin-PChar(FBrokenLine);
          if (FpBase >= PChar(FBrokenLine)) and
          (FpBase < PChar(FBrokenLine)+Length(FBrokenLine)) then
          {FpBaseもFBrokenLine中を指しているとき}
            Distance2 := FpBase-PChar(FBrokenLine)
          else
          {FpBaseはバッファ中を指しているとき}
            Distance2 := Length(FBrokenLine)+FpBase-FpBuff;
          FBrokenLine := Concat(FBrokenLine, String(FpBuff));
          FpLineBegin := PChar(FBrokenLine)+Distance;
          FpBase := PChar(FBrokenLine)+Distance2;
          BuffRead(FpBuff);
          FpForward := FpBuff;
        end else begin
        {FpLineBeginがバッファ中を指しているとき}
          FBrokenLine := String(FpLineBegin);
          FpBase := PChar(FBrokenLine)+(FpBase-FpLineBegin);
          FpLineBegin := PChar(FBrokenLine);
          BuffRead(FpBuff);
          FpForward := FpBuff;
        end;
      end;
    end;
  end;
end;

function TTxtFile.GetChar: Char;
var
  ApForward: PChar;
begin
  ApForward := FpForward;
  result := FpForward^;
  Inc(FpForward);
  {ヌル・キャラクタの処理}
  if FpForward^ = Chr(0) then
    GetCharNullChar(result);

  if result = Chr($0d) then begin
    if FpForward^ <> Chr($0a) then begin
    {CR($0d)の次がLF($0a)でないときは、$0dを$0aに置換する。}
      if FpForward = FpBuff then
        FpForward := PChar(FBrokenLine)+Length(FBrokenLine)-1
      else
        FpForward := ApForward;
      FpForward^ := Chr($0a);
      result := Chr($0a);
    end else begin
      result := FpForward^;
      Inc(FpForward);
      {ヌル・キャラクタの処理}
      if FpForward^ = Chr(0) then
        GetCharNullChar(result);
    end;
  end;
end;

function TTxtFile.GetWChar: WChar_t;
var
  ApForward: PChar;
  Ch: Char;
begin
  ApForward := FpForward;
  Ch := FpForward^;
  Inc(FpForward);
  {ヌル・キャラクタの処理}
  if FpForward^ = Chr(0) then
    GetCharNullChar(Ch);

  if Ch = Chr($0d) then begin
    if FpForward^ <> Chr($0a) then begin
    {CR($0d)の次がLF($0a)でないときは、$0dを$0aに置換する。}
      if FpForward = FpBuff then
        FpForward := PChar(FBrokenLine)+Length(FBrokenLine)-1
      else
        FpForward := ApForward;
      FpForward^ := Chr($0a);
      Ch := Chr($0a);
    end else begin
      Ch := FpForward^;
      Inc(FpForward);
      {ヌル・キャラクタの処理}
      if FpForward^ = Chr(0) then
        GetCharNullChar(Ch);
    end;
  end;
  result := Byte(Ch);
  case result of
    $81..$9F, $E0..$FC: begin
        Ch := FpForward^;
        Inc(FpForward);
        {ヌル・キャラクタの処理}
        if FpForward^ = Chr(0) then
          GetCharNullChar(Ch);
        result := (result shl 8) or Byte(Ch);
      end;
  end;
end;

function TTxtFile.GetThisLine: RE_LineInfo_t;
var
  i: Integer;
begin
  Application.ProcessMessages;
  if FpCancelRequest^ then
    raise EGrepCancel.Create('CancelRequest');

    {行末を見つける。}
    while FpBase^ <> Chr($0a) do begin
      IncPBase;
    end;

  if (FpLineBegin >= PChar(FBrokenLine)) and
  (FpLineBegin < PChar(FBrokenLine)+Length(FBrokenLine)) then begin
  {FpLineBeginがFBrokenLine中を指しているとき}
    if (FpBase >= PChar(FBrokenLine)) and
    (FpBase < PChar(FBrokenLine)+Length(FBrokenLine)) then begin
    {FpBaseもFBrokenLine中を指しているとき}
      result.Line := Copy(FBrokenLine, FpLineBegin-PChar(FBrokenLine)+1,
                        FpBase-FpLineBegin);
    end else begin
    {FpBaseはバッファ中を指しているとき}
      SetString(result.Line, FpBuff, FpBase-FpBuff);
      result.Line := Concat(Copy(FBrokenLine, FpLineBegin-PChar(FBrokenLine)+1,
                            Length(FBrokenLine)), result.Line);
    end;
  end else begin
    SetString(result.Line, FpLineBegin, FpBase-FpLineBegin);
  end;

  {TrimRight}
  i := Length(result.Line);
  while (i > 0) and (result.Line[i] in [Chr($0d), Chr($0a)]) do Dec(I);
  result.Line := Copy(result.Line, 1, i);

  result.LineNo := FLineNo;
end;

function StringToWordArray(Str: String; pWCharArray: PWordArray): Integer;
var
  i, j: Integer;
  WChar: WChar_t;
begin
  i := 1;
  j := 0;
  WChar := GetWChar(Str, i);
  while WChar <> 0 do begin
    pWCharArray^[j] := WChar;
    Inc(j);
    WChar := GetWChar(Str, i);
  end;
  pWCharArray^[j] := 0;
  result := j;
end;

constructor TGrep.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ListOfFuzzyCharDic.Add(RE_FuzzyCharDic); {キャラクタ同一視辞書を追加}
end;

procedure TGrep.SetRegExp(Str: String);
begin
  inherited SetRegExp(Str);
  if Self.RegExpIsSimple then
    FGrepProc := GrepByStr
  else
    FGrepProc := GrepByRegExp;
end;

function TGrep.GetLineHeadWChar: WChar_t;
begin
  result := CONST_LF;
end;

function TGrep.GetLineTailWChar: WChar_t;
begin
  result := CONST_LF;
end;

procedure TGrep.GrepByRegExp(FileName: String);
var
  TxtFile: TTxtFile;
  pDFAState,pInitialDFAState: RE_pDFAState_t;
  LineInfo: RE_LineInfo_t;
  DFA: TRE_DFA;
  WChar: WChar_t;
  pSub: RE_pDFAStateSub_t;
begin
  {OnMatchイベントハンドラが設定されていないときは、何もしない}
  if not Assigned(FOnMatch) then
    exit;

  FCancel := False;
  DFA := GetCurrentDFA;
  pInitialDFAState := DFA.pInitialState;
  try
    TxtFile := TTxtFile.Create(FileName, Self.FCancel);
  except on EEndOfFile do exit; {ファイルサイズ０のときはexit} end;

  try
    try
      {検索}
      while True do begin
        repeat
          WChar := TxtFile.AdvanceBase;
          {↓NextDFAStateメソッド埋め込み}
          pDFAState := nil;
          pSub := pInitialDFAState^.next;
          while pSub <> nil do begin
            if WChar < pSub^.CharClass.StartChar then
              break
            else if WChar <= pSub^.CharClass.EndChar then begin
              pDFAState := pSub^.TransitTo;
              break;
            end;
            pSub := pSub^.next;
          end;
          {↑NextDFAStateメソッド埋め込み}
        until pDFAState <> nil;

        while True do begin
          if pDFAState^.accepted then begin
          {マッチした}
            LineInfo := TxtFile.GetThisLine;
            FOnMatch(Self, LineInfo);
            break;
          end;

          {DFAを状態遷移させる}
          pDFAState := NextDFAState(pDFAState, TxtFile.GetWChar);
          if pDFAState = nil then begin
            break;
          end;
        end;
      end;
    finally TxtFile.Free; end;
  except on EEndOfFile do ; end; {Catch EEndOfFile}
end;

procedure TGrep.GrepByStr(FileName: String);
var
  TxtFile: TTxtFile;
  Pattern: String;
  pPat: PWordArray;
  PatLen: Integer;
  i: Integer;
  LineInfo: RE_LineInfo_t;
begin
  FCancel := False;
  Pattern := Self.SimpleRegExp;
  {OnMatchイベントハンドラが設定されていないときは、何もしない}
  if not Assigned(FOnMatch) then
    exit;

  try
    TxtFile := TTxtFile.Create(FileName, Self.FCancel);
  except on EEndOfFile do exit; {ファイルサイズ０のときはexit}  end;

  try
    pPat := AllocMem(Length(Pattern)*2+2);
  try
    PatLen := StringToWordArray(Pattern, pPat);
    try
      while True do begin
        while (TxtFile.AdvanceBase <> Word(pPat^[0])) do
          ;
        i := 1;
        while True do begin
          if i = PatLen then begin
            LineInfo := TxtFile.GetThisLine;
            FOnMatch(Self, LineInfo);
            break;
          end;
          if TxtFile.GetWChar = Word(pPat^[i]) then
            Inc(i)
          else
            break;
        end;
      end;
    except on EEndOfFile do ;{Catch EEndOfFile} end;
  finally FreeMem(pPat, Length(Pattern)*2+2); end;
  finally TxtFile.Free; end;
end;

procedure MakeFuzzyCharDic;
var
  StrList: TStrings;
  i: Integer;
begin
  RE_FuzzyCharDic := nil;
  RE_FuzzyCharDic := TList.Create;

  i := 0;
  repeat
    StrList := TStringList.Create;
    try
      RE_FuzzyCharDic.Add(StrList);
    except
      on Exception do begin
        StrList.Free;
        raise;
      end;
    end;

    StrList.CommaText := REFuzzyWChars[i];
    Inc(i);
  until i > High(REFuzzyWChars);
end;

procedure DestroyFuzzyCharDic;
var
  i: Integer;
begin
  for i := 0 to RE_FuzzyCharDic.Count-1 do
    TStringList(RE_FuzzyCharDic[i]).Free;
  RE_FuzzyCharDic.Free;
end;

procedure Register;
begin
  RegisterComponents('RegExp', [TGrep, TAWKStr]);
end;

initialization
  MakeFuzzyCharDic;

finalization
  DestroyFuzzyCharDic;

end.
