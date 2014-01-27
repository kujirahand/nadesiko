unit hima_parser;

//------------------------------------------------------------------------------
// 構文木に変換する
//------------------------------------------------------------------------------

interface               

uses
  Windows, SysUtils, hima_error, hima_types, hima_token,
  hima_variable, hima_variable_ex, hima_function, mmsystem;


type                                            
  // 前方宣言                            
  TSyntaxNode = class;

  // スタック                           
  THStack = class(THList)
  public
    SyntaxLevel: Integer;
    function Get(Index: Integer): TSyntaxNode;
    function Push(node: TSyntaxNode): Integer;
    function FindJosi(key: Integer): Integer;
    function Pop(JosiID: Integer = 0): TSyntaxNode;
    function GetAndDel(Index: Integer): TSyntaxNode;
    function GetLast: TSyntaxNode;
  end;

  //----------------------------------------------------------------------------
  // 構文木となる要素
  //----------------------------------------------------------------------------
  TSyntaxNode = class
  private
    FSyntaxLevel: Integer;          // 構造化レベル
    FParent     : TSyntaxNode;
    procedure SetParent(const Value: TSyntaxNode);      // 親のノード
  protected
    procedure SetSyntaxLevel(const Value: Integer); virtual;
  public
    DebugInfo   : TDebugInfo  ;     // 行番号など
    Next        : TSyntaxNode;      // 次のノード
    Children    : TSyntaxNode;      // 子のノード
    JosiId      : Integer;          // 助詞ID
    NodeResult  : PHiValue;         // ノードの実行結果
    Priority    : Integer;          // 項の優先順位
    CanBreak    : Boolean;          // Breakで抜けることができるか？
    ReadOnly    : Boolean;          // このノードには書き込みが可能か？
    FlagLive    : Boolean;          // このノードが他から利用されているかどうか
  public
    constructor Create(FParent: TSyntaxNode);
    destructor Destroy; override;
    function DebugStr: AnsiString; virtual;           // 簡易デバッグ用文字列の保持
    function getValue: PHiValue; virtual;         // ノードの内容を実行する
    function GetValueNoGetter(CanCreate:Boolean): PHiValue; virtual; // Getterなしの変数を得る
    function FindBreakLevel: Integer;             // 抜けるなどの処理に使う
    function outNadesikoProgram: AnsiString; virtual; // 構文木からなでしこのプログラムを生成する
    function outLuaProgram: AnsiString; virtual;
    property SyntaxLevel: Integer read FSyntaxLevel write SetSyntaxLevel;
    property Parent: TSyntaxNode read FParent write SetParent;
  end;

  TSyntaxJumpPoint = class(TSyntaxNode)
  public
    NameId: DWORD;
    function DebugStr: AnsiString; override;
    function outNadesikoProgram: AnsiString; override;
  end;

  // 構文の関係を示すためのノードタイプ
  TSyntaxNodeTop = class(TSyntaxNode)
  public
    function DebugStr: AnsiString; override;
    function getValue: PHiValue; override;
    function outNadesikoProgram: AnsiString; override;
    function outLuaProgram: AnsiString; override;
  end;

  TSyntaxNodeChild = class(TSyntaxNode)
  public
    function DebugStr: AnsiString; override;
    function getValue: PHiValue; override;
    function outNadesikoProgram: AnsiString; override;
    function outLuaProgram: AnsiString; override;
  end;

  TSyntaxNamespace = class(TSyntaxNode)
  public
    scopeID: Integer;
    function DebugStr: AnsiString; override;
    function getValue: PHiValue; override;
    function outNadesikoProgram: AnsiString; override;
    function outLuaProgram: AnsiString; override;
  end;

  TSyntaxEnzansi = class(TSyntaxNode)
  public
    ID: Integer;
    function DebugStr: AnsiString; override;
    function getValue: PHiValue; override;
    function outNadesikoProgram: AnsiString; override;
    function outLuaProgram: AnsiString; override;
  end;

  TSyntaxConst = class(TSyntaxNode)
  public
    constValue: PHiValue;
    constructor Create(FParent: TSyntaxNode);
    destructor Destroy; override;
    function DebugStr: AnsiString; override;
    function getValue: PHiValue; override;
    function outNadesikoProgram: AnsiString; override;
    function outLuaProgram: AnsiString; override;
  end;

  //----------------------------------------------------------------------------
  // 変数の値を取得するノード
  //----------------------------------------------------------------------------
  TSyntaxValueLinkType = (
    svLinkGlobal,
    svLinkLocal,
    svLinkArray,
    svLinkHash,
    svLinkGroup,             // GROUP->MEMBER の場合
    svLinkVirtualGroupMember // (GROUP不明でその時のグループ)->MEMBER の場合
  );

  TSyntaxValueElement = class
  public
    LinkType    : TSyntaxValueLinkType;
    NextElement : TSyntaxValueElement;
    // option
    Stack       : THObjectList; // グループの動的実行で関数の引数を保持する
    VarLink     : PHiValue;
    aryIndex    : TSyntaxNode;
    groupMember : DWORD;
    constructor Create;
    destructor Destroy; override;
  end;

  TSyntaxValue = class(TSyntaxNode)
  private
    FGroupScope: THiGroup;
    procedure CheckGetter(var p: PHiValue);
  public
    VarID: Integer;
    Element: TSyntaxValueElement;
    constructor Create(FParent: TSyntaxNode);
    destructor Destroy; override;
    function DebugStr: AnsiString; override;
    function GetValueNoGetter(CanCreate:Boolean): PHiValue; override;
    function getValue: PHiValue; override;
    property GroupScope: THiGroup read FGroupScope;
    function outNadesikoProgram: AnsiString; override;
    function outLuaProgram: AnsiString; override;
  end;

  // -1 や !true を表す
  TSyntaxTermMode = (termMinus, termNot);

  TSyntaxTerm = class(TSyntaxNode)
  public
    baseNode: TSyntaxNode;
    mode: TSyntaxTermMode;
    constructor Create(FParent: TSyntaxNode);
    destructor Destroy; override;
    function DebugStr: AnsiString; override;
    function getValue: PHiValue; override;
    function outNadesikoProgram: AnsiString; override;
    function outLuaProgram: AnsiString; override;
  end;

  TSyntaxSentence = class(TSyntaxNode)
  public
    DebugMemo: AnsiString;
    constructor Create(FParent: TSyntaxNode);
    destructor Destroy; override;
    function DebugStr: AnsiString; override;
    function GetValueNoGetter(CanCreate:Boolean): PHiValue; override;
    function getValue: PHiValue; override;
    function outNadesikoProgram: AnsiString; override;
    function outLuaProgram: AnsiString; override;
  end;

  TSyntaxCalc = class(TSyntaxNode)
  public
    constructor Create(FParent: TSyntaxNode);
    destructor Destroy; override;
    function DebugStr: AnsiString; override;
    function getValue: PHiValue; override;
    function outNadesikoProgram: AnsiString; override;
    function outLuaProgram: AnsiString; override;
  end;

  TSyntaxLet = class(TSyntaxSentence)
  protected
    procedure SetSyntaxLevel(const Value: Integer); override;
  public
    VarID: DWORD;
    VarNode: TSyntaxValue;    // 左辺保持のための変数・右辺はChildrenに
    IsEvent: Boolean;
    token: THimaToken;        // EVENT LINK FROM SOURCE TOKEN
    tokenMultiLine: Boolean;
    constructor Create(FParent: TSyntaxNode);
    destructor Destroy; override;
    function DebugStr: AnsiString; override;
    function getValue: PHiValue; override;
    function getValueRaw: PHiValue;
    function outNadesikoProgram: AnsiString; override;
    function outLuaProgram: AnsiString; override;
  end;

  TSyntaxCreateVar = class(TSyntaxNode)
  public
    Template: PHiValue;
    InitNode: TSyntaxNode; // 初期化のための式があるかどうか
    constructor Create(FParent: TSyntaxNode);
    destructor Destroy; override;
    function DebugStr: AnsiString; override;
    function getValue: PHiValue; override;
    function outNadesikoProgram: AnsiString; override;
    function outLuaProgram: AnsiString; override;
  end;

  TSyntaxWhile = class(TSyntaxSentence)
  protected
    procedure SetSyntaxLevel(const Value: Integer); override;
  public
    Jouken: TSyntaxNode;
    constructor Create(FParent: TSyntaxNode);
    destructor Destroy; override;
    function DebugStr: AnsiString; override;
    function getValue: PHiValue; override;
    function outNadesikoProgram: AnsiString; override;
    function outLuaProgram: AnsiString; override;
  end;

  TSyntaxLoop = class(TSyntaxSentence)
  protected
    procedure SetSyntaxLevel(const Value: Integer); override;
  public
    Kaisu: TSyntaxNode;
    constructor Create(FParent: TSyntaxNode);
    destructor Destroy; override;
    function DebugStr: AnsiString; override;
    function getValue: PHiValue; override;
    function outNadesikoProgram: AnsiString; override;
    function outLuaProgram: AnsiString; override;
  end;

  TSyntaxFor = class(TSyntaxSentence)
  public
    VarLoop: TSyntaxNode;
    VarFrom,VarTo: TSyntaxNode;
    constructor Create(FParent: TSyntaxNode);
    destructor Destroy; override;
    function DebugStr: AnsiString; override;
    function getValue: PHiValue; override;
    function outNadesikoProgram: AnsiString; override;
    function outLuaProgram: AnsiString; override;
  end;

  TSyntaxEach = class(TSyntaxSentence)
  protected
    procedure SetSyntaxLevel(const Value: Integer); override;
  public
    jouken: TSyntaxNode;
    iVar: TSyntaxValue; // イテレーター変数
    constructor Create(FParent: TSyntaxNode);
    destructor Destroy; override;
    function DebugStr: AnsiString; override;
    function getValue: PHiValue; override;
    function outNadesikoProgram: AnsiString; override;
    function outLuaProgram: AnsiString; override;
  end;

  TSyntaxIf = class(TSyntaxNode)
  protected
    procedure SetSyntaxLevel(const Value: Integer); override;
  public
    Jouken    : TSyntaxNode;
    TrueNode  : TSyntaxNode;
    FalseNode : TSyntaxNode;
    Reverse: Boolean;
    constructor Create(FParent: TSyntaxNode);
    destructor Destroy; override;
    function DebugStr: AnsiString; override;
    function getValue: PHiValue; override;
    function outNadesikoProgram: AnsiString; override;
    function outLuaProgram: AnsiString; override;
  end;

  //-----------------------------------------
  // 多分岐構文
  TSyntaxSwitchCase = class
  public
    Jouken: TSyntaxNode;
    Action: TSyntaxSentence;
    constructor Create;
    destructor Destroy; override;
  end;

  TSyntaxSwitch = class(TSyntaxNode)
  protected
    procedure SetSyntaxLevel(const Value: Integer); override;
  public
    Jouken    : TSyntaxNode;
    CaseNodes : THObjectList;
    ElseNode  : TSyntaxSentence;
    constructor Create(FParent: TSyntaxNode);
    destructor Destroy; override;
    function DebugStr: AnsiString; override;
    function getValue: PHiValue; override;
    function outNadesikoProgram: AnsiString; override;
    function outLuaProgram: AnsiString; override;
  end;

  TSyntaxTryExcept = class(TSyntaxNode)
  protected
    procedure SetSyntaxLevel(const Value: Integer); override;
  public
    NodeTry   : TSyntaxNode;
    NodeExcept: TSyntaxNode;
    constructor Create(FParent: TSyntaxNode);
    destructor Destroy; override;
    function DebugStr: AnsiString; override;
    function getValue: PHiValue; override;
  end;

  // 普通の関数の呼び出し
  TSyntaxFunctionLinkType = (
    sfLinkDirect,       // 直接HiFuncの内容を実行
    sfLinkGroupMember,  // グループ->メンバ関数
    sfLinkVirtuaLink    // (動的グループ)->メンバ関数
  );
  TSyntaxFunctionLink = record
    LinkType  : TSyntaxFunctionLinkType;
    LinkValue : TSyntaxValue;
  end;

  TSyntaxDefFunction = class(TSyntaxSentence)
  public
    GroupID         : DWORD;
    FuncID          : DWORD;
    HiFunc          : THiFunction;
    FlagGroupMember : Boolean;
    constructor Create(FParent: TSyntaxNode);
    destructor  Destroy; override;
    function DebugStr           : AnsiString;   override;
    function getValue           : PHiValue; override;
    function outNadesikoProgram : AnsiString;   override;
    function outLuaProgram: AnsiString; override;
  end;

  TSyntaxFunction = class(TSyntaxNode)
  private
    function makeArgVar(v: PHiValue; IsRef: Boolean): PHiValue; // 引数に乗せるために変数を複製する
    function getArgStackToArray: THiArray; // システム変数のために引数を乗せる処理
    procedure ArgStackToLocalVar;          // ローカル変数のために引数を乗せる処理
    function callSysFunc:  PHiValue;
    function callUserFunc: PHiValue;
    function callDllFunc:  PHiValue;
  public
    FDebugFuncName: AnsiString; // デバッグ用関数名
    FuncID  : DWORD;
    HiFunc  : THiFunction;
    DefFunc : TSyntaxDefFunction;
    Stack   : THObjectList;
    Link    : TSyntaxFunctionLink;
    constructor Create(FParent: TSyntaxNode);
    destructor Destroy; override;
    function DebugStr: AnsiString; override;
    function getValue: PHiValue; override;
    function outNadesikoProgram: AnsiString; override;
    function outLuaProgram: AnsiString; override;
  end;

  TSyntaxWith = class(TSyntaxSentence)
  public
    WithVar: TSyntaxNode;
    constructor Create(FParent: TSyntaxNode);
    destructor Destroy; override;
    function DebugStr: AnsiString; override;
    function getValue: PHiValue; override;
    function outNadesikoProgram: AnsiString; override;
  end;

  // 引数のない関数型を宣言（新しいＤＬＬインポート命令）
  //[0]
  TDllfuncVoid   = procedure;          stdcall;
  //[1]
  TDllfuncChar   = function: Shortint; stdcall;
  TDllfuncByte   = function: Byte;     stdcall;
  //[2]
  TDllfuncShort  = function: Smallint; stdcall;
  TDllfuncWord   = function: WORD;     stdcall;
  //[4]
  TDllfuncLong   = function: Longint;  stdcall;
  TDllfuncDWord  = function: DWORD;    stdcall;
  TDllfuncPtr    = function: PAnsiChar;    stdcall;
  TDllfuncFloat  = function: Single;    stdcall;
  //[8]
  TDllfuncInt64  = function: int64;    stdcall;
  TDllfuncDouble = function: Double;    stdcall;

  //
  THiReadFlag = record
    CanLet: Boolean;
  end;

  THiParser = class
  private
    FStackStack : THList;
    FStack      : THStack; // SyntaxNode を覚えておく
    FTopNode    : TSyntaxNode;
    FCurNode    : TSyntaxNode;
    FNextBlock  : THimaToken;
    FPrevToken  : THimaToken;
    FReadFlag   : THiReadFlag;
    procedure ReadSyntaxBlock(var token: THimaToken; var cnode: TSyntaxNode;
      defIndent: Integer);  // 意味続きのブロックを読む
    procedure ReadPreprocess(token: THimaToken; var node: TSyntaxNode); // パース以前に関数を登録する
    procedure ReadBlocks(var token: THimaToken; var cnode: TSyntaxNode);  // ブロックを１つ読む
    procedure ReadLine(var token: THimaToken; var cnode: TSyntaxNode; CanLet:Boolean = True);   // 行を１つの区切りまで読む - 行の途中で抜けることもある。
    //procedure ReadLineEx(var token: THimaToken; var cnode: TSyntaxNode; CanLet:Boolean = True); // 行の終端まで必ず読む
    function ReadOneItem(var token: THimaToken): Boolean; // トークンを１つ読む
    function ReadTango(var token: THimaToken): Boolean;

    function ReadSiki(var token: THimaToken): Boolean;
    function ReadKakko(var token: THimaToken): Boolean;

    function ReadToNaraba(var token: THimaToken): Boolean;
    function ReadIf(var token: THimaToken; defIndent: Integer): Boolean;
    //function ReadSentence(var token: THimaToken; var cnode: TSyntaxNode): Boolean;
    function ReadFor(var token: THimaToken; defIndent: Integer): Boolean;
    function ReadEach(var token: THimaToken; defIndent: Integer): Boolean;
    function ReadWhile(var token: THimaToken; defIndent: Integer): Boolean;
    function ReadKai(var token: THimaToken; defIndent: Integer): Boolean;
    function ReadFunction(var token: THimaToken; v: PHiValue; link: TSyntaxFunctionLink): Boolean;
    function ReadLet(var token: THimaToken; IsDainyu: Boolean = False): Boolean;
    function ReadTryExcept(var token: THimaToken; defIndent: Integer): Boolean;
    function ReadDefFunction(var token: THimaToken): Boolean;
    function ReadDefFunctionContents(var token: THimaToken): Boolean;
    function ReadDefJumpPoint(var token: THimaToken): Boolean;
    //function ReadDefFunctionContentsSkip(var token: THimaToken): Boolean;
    function ReadDefGroup(var token: THimaToken): Boolean;
    function ReadSwitch(var token: THimaToken): Boolean;
    function ReadWith(var token: THimaToken; defIndent: Integer): Boolean;

    procedure ReadArg(var token: THimaToken; var josi: Integer);
    function getEnzansi(var token: THimaToken): TSyntaxEnzansi;
    procedure setPriority(n: TSyntaxNode);
    procedure getArgType(var token: THimaToken; v: PHiValue; var argNeeded: Boolean; var argByRef: Boolean);
    procedure getDefArgs(var token: THimaToken; args: THimaArgs);
    procedure RegistVar(var token: THimaToken; IsPreprocess: Boolean=False; ReadOnly: Boolean=False);
    function ReadOption(var token: THimaToken; IsPreprocess: Boolean; node: TSyntaxNode): Boolean;
    function ReadInclude(var token: THimaToken; node: TSyntaxNode): Boolean;
    procedure ChangeNamespace(var token: THimaToken; node: TSyntaxNode);

    //function IsTokenEnzan(token: THimaToken): Boolean;
    //
    procedure NextBlock(var token: THimaToken);
    procedure StackToNode(var cnode: TSyntaxNode); // FStack -> cnode
    procedure StackToNodeChild(stack: THStack; node: TSyntaxNode); // stack -> node.Children
    //
    function SkipDefFunction(var token: THimaToken): Boolean;
    function SkipBlock(var token: THimaToken): Boolean;
    //function SkipLine(var token: THimaToken): Boolean;
    procedure TokenNextToken(var token: THimaToken); // tokenを次に進める
    procedure TokenSkipComma(var token: THimaToken);
    //
    procedure infix2rpolish(sikiStack: THStack); // 中間記法→逆ポーランド
    //
    procedure StackPush;
    procedure StackPop;
  public
    constructor Create;
    destructor Destroy; override;
    function Parse(token: THimaToken): TSyntaxNode;
    function Debug: AnsiString;
  end;

var
  SonoTokenID: DWORD = DWORD(-1);
  LastUserFuncID: DWORD = 0;

function SyntaxTab(Level: Integer): AnsiString;
function SyntaxClassToFuncName(name: string): AnsiString;


implementation

uses hima_string, hima_system, unit_string, Math, unit_text_file;

function SyntaxClassToFuncName(name: string): AnsiString;
begin
  if name = 'TSyntaxCalc' then Result := '演算' else
  if name = 'TSyntaxValue' then Result := '値' else
  if name = 'TSyntaxDefFunction' then Result := '関数定義' else
  if name = 'TSyntaxFunction' then Result := '関数' else
  if name = 'TSyntaxTryExcept' then Result := '例外処理' else
  if name = 'TSyntaxLet' then Result := '代入' else
  if name = 'TSyntaxWhile' then Result := '間' else
  if name = 'TSyntaxLoop' then Result := '回' else
  if name = 'TSyntaxFor' then Result := '繰り返す' else
  if name = 'TSyntaxEach' then Result := '反復' else
  if name = 'TSyntaxIf' then Result := 'もし' else
  if name = 'TSyntaxSwitch' then Result := '条件分岐' else
  if name = 'TSyntaxWith' then Result := 'について' else
  if name = 'TSyntaxSentence' then Result := '文' else
  Result := AnsiString(name);
  ;
end;

function SyntaxTab(Level: Integer): AnsiString;
var i: Integer;p:PAnsiChar;
begin
  {Result := '';
  for i := 0 to Level - 1 do
  begin
    Result := Result + '    ';
  end;}
  SetLength(Result,level*4);
  p := PAnsiChar(Result);
  for i:= 0 to Level*4 - 1 do
  begin
    p^ := ' ';
    inc(p);
  end;
end;

{ TSyntaxNode }

constructor TSyntaxNode.Create(FParent: TSyntaxNode);
begin
  // 初期化
  Parent    := FParent;
  Next      := nil;
  Children  := nil;
  Priority  := MaxInt; // 通常の優先順位は最高レベル
  CanBreak  := False;
  NodeResult   := hi_var_new; NodeResult.Registered := 1;
  FSyntaxLevel := 0;
  JosiID       := 0;
  ReadOnly     := False;
  FlagLive     := False;
  //
  DebugInfo.FileNo := 255;
  DebugInfo.LineNo := 0;
  DebugInfo.Flag   := 0;
end;

function TSyntaxNode.DebugStr: AnsiString;
begin
  Result := '(なし)' + hi_str(NodeResult);
end;

destructor TSyntaxNode.Destroy;
begin
  if NodeResult <> nil then
  begin
    hi_var_free(NodeResult);
  end;
  
  if Next <> nil then FreeAndNil(Next);
  inherited;
end;

function TSyntaxNode.FindBreakLevel: Integer;
begin
  // 親がなければ自身が答え(つまりできない)
  if Parent = nil then
  begin
    Result := SyntaxLevel;
  end else
  // 一つ上を見て Break できるか調べる
  begin
    if Parent.CanBreak then
    begin
      Result := Parent.SyntaxLevel;
    end else
    begin
      Result := Parent.FindBreakLevel;
    end;
  end;
end;

function TSyntaxNode.getValue: PHiValue;
begin
  Result := nil;
end;


function TSyntaxNode.GetValueNoGetter(CanCreate:Boolean): PHiValue;
begin
  Result := getValue;
end;

function TSyntaxNode.outLuaProgram: AnsiString;
begin
  Result := '';
end;

function TSyntaxNode.outNadesikoProgram: AnsiString;
begin
  Result := '';
end;

procedure TSyntaxNode.SetParent(const Value: TSyntaxNode);
begin
  FParent := Value;
end;

procedure TSyntaxNode.SetSyntaxLevel(const Value: Integer);
begin
  if FSyntaxLevel <> 0 then Exit;
  FSyntaxLevel := Value;

  // 次のノードがあれば自動設定する
  if Next <> nil then
  begin
    if Self.Parent <> nil then Next.Parent := Self.Parent;
    Next.SyntaxLevel := Value;
  end;

  // 子のレベルを自動設定する
  if Children <> nil then
  begin
    Children.Parent      := Self;
    Children.SyntaxLevel := Value + 1;
  end;
end;

{ THiParser }

constructor THiParser.Create;
begin
  // 生成
  FStack := THStack.Create;
  FStackStack := THList.Create;
  // 初期化
  FNextBlock := nil;
  FStack.SyntaxLevel := 0;
  //
  FReadFlag.CanLet := True;
end;

destructor THiParser.Destroy;
begin
  FreeAndNil(FStack);
  FreeAndNil(FStackStack);
  inherited;
end;

function THiParser.getEnzansi(var token: THimaToken): TSyntaxEnzansi;
begin
  Result := TSyntaxEnzansi.Create(nil);
  Result.DebugInfo := token.DebugInfo;
  Result.ID := token.TokenID;
  token := token.NextToken; // skip ENZANSI
  // 優先順位を調べる
  setPriority(Result);
end;

procedure THiParser.infix2rpolish(sikiStack: THStack);
var
  i: Integer;
  n: TSyntaxNode;
  tempStack: THStack;
  polish   : THStack;
begin
  //--------------------------------------------------------------------------
  // 式を並び替える 中間記法→逆ポーランド
  //--------------------------------------------------------------------------
  // 1) 以下を繰り返す
  //      2) 式から１つの因子を取り出す
  //      3) (取り出した因子の優先順位) <= (スタックトップの因子の優先順位) の間、polish に tempStackの最上位の因子を取り出して積む
  //      4) 2)で取り出した因子をtempStackに積む
  // 5) tempStack の残りを polish に積む

  tempStack := THStack.Create;
  polish    := THStack.Create;

  try
    // 番兵を tempStack に置いておく
    n := TSyntaxNode.Create(nil);
    n.Priority := -1; // 番兵
    tempStack.Push(n);

    // ここから
    for i := 0 to sikiStack.Count - 1 do // ... 1
    begin
      n := sikiStack.Get(i); //... 2
      while n.Priority <= tempStack.GetLast.Priority do // ... 3
      begin
        polish.Push(tempStack.Pop);
      end;
      tempStack.Push(n); // ... 4
    end;
    while tempStack.Count > 1{番兵以外} do polish.Push(tempStack.Pop); // ... 5
    // ここまで

    // sikiStack に結果を乗せかえる
    sikiStack.Assign(polish);

    // 番兵を削除
    for i := 0 to tempStack.Count - 1 do
    begin
      n := tempStack.Pop; FreeAndNil(n);
    end;

    // for DEBUG
    {
    for i := 0 to sikiStack.Count - 1 do
    begin
      n := sikiStack.Get(i);
      writeln(n.DebugStr, ' = ', n.Priority);
    end;
    }

  finally
    tempStack.Free;
    polish.Free ;
  end;

end;

procedure THiParser.NextBlock(var token: THimaToken);
begin
  if token = nil then
  begin
    token := FNextBlock;
    if token <> nil then FNextBlock := token.CheckNextBlock else FNextBlock := nil;
  end else
  begin
    token := token.CheckNextBlock;
    if token <> nil then FNextBlock := token.CheckNextBlock else FNextBlock := nil;
  end;
end;

function THiParser.Parse(token: THimaToken): TSyntaxNode;
var
  tmpSpace: THiScope;
begin
  inherited;
  //todo 1: Parse
  FTopNode := TSyntaxNodeTop.Create(nil);
  FCurNode := FTopNode;

  // Namespace のセット
  tmpSpace := HiSystem.Namespace.CurSpace;
  FCurNode.Next := TSyntaxNamespace.Create(nil);
  TSyntaxNamespace(FCurNode.Next).scopeID := token.FileNo;
  FCurNode := FCurNode.Next;

  // 関数の先読み(定義だけを読む)
  ReadPreprocess(token, FCurNode);

  // 読み込み
  ReadBlocks(token, FCurNode);
  Result := FTopNode;

  FTopNode.SyntaxLevel := 0; // これで全ての構文レベルが自動で設定される

  // Namespace を戻す
  FCurNode.Next := TSyntaxNamespace.Create(nil);
  TSyntaxNamespace(FCurNode.Next).scopeID := tmpSpace.ScopeID;
  FCurNode := FCurNode.Next;
end;

procedure THiParser.ReadArg(var token: THimaToken; var josi: Integer);
begin
  // 引数を取得する
  if token = nil then Exit;
  if token.TokenID <> token_kakko_begin then Exit;
  FPrevToken := token;
  token := token.NextToken; // SKIP '('
  if token = nil then NextBlock(token);

  while token <> nil do
  begin
    if token.TokenID = token_kakko_end then Break;
    ReadOneItem(token);
    if token = nil then NextBlock(token);
  end;
  if (token = nil) then raise HException.Create(ERR_NOPAIR_KAKKO);
  if (token.TokenID <> token_kakko_end) then raise HException.Create(ERR_NOPAIR_KAKKO);
  josi := token.JosiID;

  FPrevToken := token;
  token := token.NextToken; // SKIP ')'

end;

procedure THiParser.ReadBlocks(var token: THimaToken; var cnode: TSyntaxNode);
var
  TopIndent: Integer;
  pTemp: THimaToken;
begin
  //todo 2:＠ブロック以下を読む
  if token = nil then Exit;
  TopIndent := token.Indent;

  while token <> nil do
  begin
    // １ブロックの終端を判別
    if TopIndent <> token.Indent then
    begin
      //..TopIndent(2)
      //....token.Indent(4)
      //....token.Indent(4)
      //..NextToken(2) ← ここで抜ける
      if TopIndent{1} >= token.Indent{3} then Break;
    end;

    // 次のラインを調べておく
    pTemp := token;
    FNextBlock := token.CheckNextBlock;

    try

      //{$IFDEF ERROR_LOG}errLog(Format('%0.4d:解析-'+token.Token,[token.LineNo]));{$ENDIF}

      // 行の初めにある特別な単語
      case token.TokenID of
        token_mark_function:  begin ReadDefFunctionContents(token); Continue; end; // 関数の宣言
        token_mark_sikaku:    begin SkipDefFunction(token); Continue; end;         // グループの宣言
        token_mark_option:    begin ReadOption(token,False,cnode); Continue; end;  // インタプリタオプション
        token_kakko_end:      raise HException.Create(ERR_NOPAIR_KAKKO+'突然の『)』です。');
      end;

      // 一行の終わりまで読む
      ReadLine(token, cnode);

      if (token <> nil)and(pTemp = token) then // 同じところを何度もループしている
      begin
        raise HException.Create('パースエラー。「'+hi_id2tango(token.TokenID)+'」');
      end;

    except
      on e: Exception do
        raise EHimaSyntax.Create(pTemp.DebugInfo, AnsiString(e.Message),[]);
    end;

    if token = nil then NextBlock(token);
  end;

  StackToNode(cnode);
end;


function THiParser.ReadDefGroup(var token: THimaToken): Boolean;
var
  group: PHiValue;
  tempToken: THimaToken;
  mName: PHiValue;
  memberIndent: Integer;

  procedure _read_member;
  var
    m: PHiValue;
    b, refVar: Boolean;
    i: Integer;
  begin
    // skip '・'
    i := token.Indent;
    token := token.NextToken;
    if token = nil then raise HException.CreateFmt(ERR_S_DEF_GROUP+'メンバの名前がありません。',[hi_id2tango(group.VarID)]);

    // メンバ変数の生成
    m := hi_var_new;

    // 修飾があるか(1/2)
    if token.TokenID = token_nami_kakko_begin then getArgType(token, m, b, refVar);

    // メンバ名
    m.VarID := token.TokenID;
    // グループに登録
    hi_group(group).Add(m);
    token := token.NextToken; // SKIP NAME
    if token = nil then Exit;

    // 修飾があるか(2/2)...修飾は分かりやすいように前でも後ろでもOK
    if token.TokenID = token_nami_kakko_begin then
    begin
      getArgType(token, m, b, refVar);
    end;
    if token = nil then Exit;

    // ゲッターとセッター(ここでは飛ばす)
    if token.TokenID = token_left then
    begin
      token := token.NextToken; // SKIP <-
      if token = nil then Exit;
      token := token.NextToken; // SKIP FUNC NAME
      if token = nil then Exit;
    end;
    if token.TokenID = token_right then
    begin
      token := token.NextToken; // SKIP ->
      if token = nil then Exit;
      token := token.NextToken; // SKIP FUNC NAME
      if token = nil then Exit;
    end;
    // デフォルト
    if token.TokenID = token_default then
    begin
      hi_group(group).DefaultValue := m;
      token := token.NextToken;
      if token = nil then Exit;
    end;

    // 関数宣言があるか？
    if token.TokenID = token_kakko_begin{'('} then
    begin // これ即ち関数
      hi_func_create(m);
      getDefArgs(token, hi_func(m).Args);
      if token = nil then raise HException.CreateFmt(ERR_S_DEF_GROUP+'関数宣言をしたら、～が必要です。',[hi_id2tango(group.VarID)]);
    end;
    // 明示的な関数の指定があるか？
    if token.TokenID = token_tilde then
    begin
      hi_func_create(m);
      token := token.NextToken; // SKIP '~'
    end else
      Exit;

    // 関数の内容定義はとりあえずスキップ。。。
    if token = nil then
    begin
      NextBlock(token);
      while token <> nil do
      begin
        //　・xxx (2)            ...i
        //    xxx,xxx,xxx... (4) ...token.Indent
        if token.TokenID = token_mark_nakaten then Break;
        if i < token.Indent then NextBlock(token) else Break;
      end;
    end else
    begin
      NextBlock(token);
    end;

  end;// of procedure

  procedure _read_group_func;
  var
    node: TSyntaxDefFunction;
    n: TSyntaxNode;
    vName: DWORD;
    v, localVar, fp: PHiValue;
    arg: THimaArg;
    i, defIndent: Integer;
  begin
    //・{型=初期値}関数名(引数...)～定義内容

    token := token.NextToken; // skip '・'
    if token = nil then Exit;

    // 波カッコがあれば終わりまで飛ばす(1/2)
    if token.TokenID = token_nami_kakko_begin then
    begin
      while token.TokenID <> token_nami_kakko_end do token := token.NextToken;
      token := token.NextToken; // skip nami_kakko_end
    end;

    // 変数名の取得
    vName := token.TokenID;
    token := token.NextToken; // skip NAME
    v := hi_group(group).FindMember(vName);
    if v = nil then raise HException.CreateFmt(ERR_S_DEF_GROUP+'メンバ『%s』の定義に誤りがあります。',[hi_id2tango(group.VarID),hi_id2tango(vName)]);

    // 波カッコがあれば終わりまで飛ばす(2/2)
    if token = nil then Exit;
    if token.TokenID = token_nami_kakko_begin then
    begin
      while token.TokenID <> token_nami_kakko_end do token := token.NextToken;
      token := token.NextToken; // skip nami_kakko_end
    end;
    if token = nil then Exit;
    
    // セッター
    if token.TokenID = token_left then
    begin
      token := token.NextToken; // SKIP <-
      if token = nil then Exit;
      fp := hi_group(group).FindMember(token.TokenID);
      if (fp = nil)or(fp.VType <> varFunc) then raise HException.CreateFmt(ERR_S_DEF_GROUP+'セッター『%s』の定義がないか関数ではありません。',[hi_id2tango(group.VarID),hi_id2tango(token.TokenID)]);
      v.Setter := fp;
      token := token.NextToken; // SKIP FUNC NAME
      if token = nil then Exit;
    end;
    // ゲッター
    if token.TokenID = token_right then
    begin
      token := token.NextToken; // SKIP ->
      if token = nil then Exit;
      fp := hi_group(group).FindMember(token.TokenID);
      if (fp = nil)or(fp.VType <> varFunc) then raise HException.CreateFmt(ERR_S_DEF_GROUP+'ゲッター『%s』の定義がないか関数ではありません。',[hi_id2tango(group.VarID),hi_id2tango(token.TokenID)]);
      v.Getter := fp;
      token := token.NextToken; // SKIP FUNC NAME
      if token = nil then Exit;
    end;
    // デフォルト
    if token.TokenID = token_default then
    begin
      token := token.NextToken;
      if token = nil then Exit;
    end;

    // ～まで飛ばす
    while token <> nil do
    begin
      if token.TokenID <> token_tilde then token := token.NextToken else Break;
    end;

    // 明確な関数内容の指示があるか？
    if (token = nil) or (token.TokenID <> token_tilde) then Exit;

    // ここから先は関数である場合のみ（やっと関数内容の読み取り処理の開始）

    // ↓は確認のため
    if v.VType <> varFunc then raise HException.Create('関数のはずなのに関数ではない。');

    // 関数内容の取得
    node := TSyntaxDefFunction.Create(nil);
    node.FlagGroupMember := True;
    node.DebugInfo := token.DebugInfo;
    node.HiFunc := hi_func(v);
    node.FuncID := v.VarID;
    node.GroupID := group.VarID;

    n    := node.Children;

    defIndent := token.Indent;
    // SKIP '～'
    if token.TokenID = token_tilde then
      token := token.NextToken // skip TILDE
    else
      raise HException.Create('グループのメソッドで～がありません。');

    // ローカルに引数を登録しておく
    HiSystem.GroupScope.PushGroupScope(hi_group(group));
    HiSystem.PushScope;
    try
      // ローカル変数の登録

      for i := 0 to hi_func(v).Args.Count - 1 do
      begin
        arg := hi_func(v).Args.Items[i];
        localVar := hi_var_new;
        hi_var_copy(arg.Value, localVar);
        localVar.VarID := arg.Name;
        HiSystem.Local.RegistVar(localVar);
      end;

      // Writeln(HiSystem.Local.EnumKeysAndValues);
      try
        ReadSyntaxBlock(token, n, defIndent);
      except on e: Exception do
        raise Exception.Create('グループメソッドでエラー。'+(e.Message));
      end;
      {
      if token = nil then
      begin
        NextBlock(token);
        if token.Indent > 0 then
        begin
          // 定義内容が空なら読まない
          if (token<>nil)and(token.TokenID=token_mark_nakaten) then
          begin
            ;// 空
          end else begin
            ReadBlocks(token, n);
          end;
        end;
      end else
      begin
        ReadLineEx(token, n);
      end;
      }
    finally
      HiSystem.PopScope;
      HiSystem.GroupScope.PopGroupScope;
    end;
    {
    // for DEBUG
    // 引数が解放されてしまった？
    for i := 0 to hi_func(v).Args.Count - 1 do
    begin
      arg := hi_func(v).Args.Items[i];
      if arg = nil then raise HException.Create('Argがnil');
    end;
    if hi_func(v).Args = nil then
    begin
      raise HException.Create(hi_id2tango(v.VarID)+'.Argsがnil');
    end;
    }
    //
    hi_func(v).FuncType := funcUser;
    hi_func(v).PFunc := node;
    node.SetSyntaxLevel(0);
    // 関数リストに追加
    HiSystem.DefFuncList.Add(node); // 最後に解放されるように
  end;

  procedure copyMember;
  var
    super: PHiValue;
  begin
    while token <> nil do
    begin
      if token.TokenID <> token_plus then
      begin
        raise HException.CreateFmt(ERR_S_DEF_GROUP+'『■グループ名　＋親グループ』と指定してください。',[hi_id2tango(group.VarID)]);
      end;
      token := token.NextToken; // SKIP '+'
      // 継承元グループの取得
      super := HiSystem.Namespace.GetVar(token.TokenID);
      super := hi_getLink(super);
      if (super = nil)or(super.VType <> varGroup) then raise HException.CreateFmt(ERR_S_UNDEF_GROUP,[hi_id2tango(token.TokenID)]);
      token := token.NextToken; // skip 'グループ名'
      hi_group(group).AddMembers(hi_group(super));
      // デフォルトの継承
      if hi_group(super).DefaultValue <> nil then
      begin
        hi_group(group).DefaultValue := hi_group(group).FindMember( hi_group(super).DefaultValue.VarID );
      end;
    end;
  end;

begin
  //todo 2:■グループの宣言

  // skip '■'
  token := token.NextToken; // skip '■'
  if (token<>nil)and(token.TokenID = token_group) then
  begin
    token := token.NextToken; // skip 'グループ'
  end;

  //----------------------------------------------------------------------------
  // グループの定義は[追記]される
  group := HiSystem.GetVariable(token.TokenID);
  if group = nil then
  begin
    // グループの新規作成
    group := hi_var_new;
    group.Designer := HiSystem.FlagSystem;
    group.VarID := token.TokenID; // set NAME
    hi_group_create(group);
    hi_group(group).HiClassDebug := token.Token; // デバッグ用に名前をセット
    hi_group(group).HiClassNameID := group.VarID; // グループ名をセット
    HiSystem.Global.RegistVar(group);
  end else
  begin
    // グループ名の違反をチェック
    if group.VType <> varGroup then
    begin
      raise HException.CreateFmt('グループの宣言で「%s」はグループ以外の変数として既に使われています。',[hi_id2tango(token.TokenID)]);
    end;
    // それ以外ではメンバは[追記]される
    hi_group(group).HiClassDebug := token.Token; // デバッグ用に名前をセット
    hi_group(group).HiClassNameID := group.VarID; // グループ名をセット
  end;
  token := token.NextToken; // skip NAME
  copyMember; // メンバーの継承

  // 参照
  SonoTokenID := group.VarID;

  if token = nil then NextBlock(token);

  // グループメンバーの登録
  mName := hi_var_new;
  mName.VarID := token_name;
  hi_setStr(mName, hi_id2tango(group.VarID));
  hi_group(group).Add(mName);
  tempToken := token;

  //メンバ定義の点の付け忘れをチェック
  if (token.Indent = 0)or(token.Indent <> 0)and(token.TokenID <> token_mark_nakaten) then
  begin
    raise HException.Create('グループの宣言で「・」がありません。・メンバ{～}・メンバ…を字下げして宣言してください。');
  end;
  memberIndent := token.Indent;

  // グループメンバの登録
  while token <> nil do
  begin
    if memberIndent = token.Indent then
    begin
      if token.TokenID <> token_mark_nakaten then
      begin
        raise HException.Create('グループの宣言で「・」がありません。・メンバ{～}・メンバ…の書式で宣言してください。');
      end;

      _read_member;

      if token = nil then NextBlock(token);
    end else begin
      Break;
    end;
  end;

  //Writeln(hi_group(group).EnumKeys,'-----');
  // グループ関数の登録
  token := tempToken;
  FNextBlock := token.CheckNextBlock;
  while token <> nil do
  begin
    if (memberIndent = token.Indent)and(token.TokenID = token_mark_nakaten) then
    begin

      _read_group_func;

      if token = nil then NextBlock(token);
    end else
      Break;
  end;
  //DEBUG :メンバの表示
  //Writeln(hi_group(group).EnumKeys,'-----');
  Result := True;
end;

function THiParser.ReadDefFunction(var token: THimaToken): Boolean;
var
  defIndent: Integer;
  node: TSyntaxDefFunction;
  tango: PHiValue;
  funcNameToken: THimaToken;

  procedure AnalizeDllImport;
  //const
  //  acceptTypes = '/CHAR/BYTE/SHORT/WORD/LONG/DWORD/POINTER/CHAR*/VOID/PAnsiChar/FLOAT/REAL/INT64/QWORD/';
  var
    dllName: string;
    cDec: AnsiString;
    ret, funcName, sarg, argName, argType, res: AnsiString;

    h: HINST;
    proc: Pointer;
    i: Integer;

    function getWord(var p: PAnsiChar): AnsiString;
    var
      tmp_p:PAnsiChar;
    begin
      skipSpace(p);
      //Result := '';
      tmp_p:=p;
      while (p^ in ['a'..'z','A'..'Z','_']) do
      begin
        //Result := Result + p^;
        Inc(p);
      end;
      SetLength(Result,Integer(p-tmp_p));
      StrLCopy(PAnsiChar(Result),tmp_p,Integer(p-tmp_p));
    end;

    procedure analizeDelphiDoc;
    var
      cnt: Integer;
      p: PAnsiChar;
      sl: THStringList;
      i: Integer;
      str: AnsiString;//for debug
    begin
      sl := THStringList.Create;
      //--------------
      // MessageBoxA(hWnd: HWND; lpText, lpCaption: PAnsiChar; uType: UINT)
      //--------------
      // DLL関数名(Delphi風)を得る
      //funcName := getToken_s(cDec, '(');
      if PosA('(',cDec) = 0 then begin//()を含んでいなければ
        funcName := TrimA(getToken_s(cDec, ':'));
        cDec:=':'+cDec ;//戻り値読み取り用
        sarg := ''
      end else begin
        // DLL関数名(Delphi風)を得る
        funcName := TrimA(getToken_s(cDec, '('));
        // 引数を得る
        sarg := TrimA(getToken_s(cDec, ')'));
        //if UpperCase(sarg) = 'VOID' then sarg := '';
        if sarg = 'VOID' then sarg := '';
      end;

      //--------------
      // 引数の正当性をチェック
      cnt := 0;
      p   := PAnsiChar(sarg);
      res := '';
      while p^ <> #0 do
      begin
        // a, b: Integer;
        // SKIP SPACE
        while p^ in [' ',#9,#13,#10] do Inc(p);{skip SPACE}
        if p^ = '/' then getTokenStr(p, #13#10);
        while p^ in [' ',#9,#13,#10] do Inc(p);
        if p^ = #0  then break;
        // GET NAME
        argName := getWord(p);
        if argName = 'var' then
        begin
          argName := getWord(p);
          res := res {+ argType} + 'POINTER ' + argName + ',';
          getTokenStr(p, ';');
          Inc(cnt);
          Continue;
        end;

        skipSpace(p);
        if p^ = ',' then
        begin
          sl.Add(argName);
          Inc(p);
          Continue;
        end else
        if p^ = ':' then
        begin
          sl.Add(argName);
          Inc(p); // skip ':'
          // GET TYPE
          argType := getWord(p);
          skipSpace(p);
          argType := UpperCaseA(argType);
          str := argType;
          replace_dll_types(argType); // DLLインポート型の単純置換
          //if Pos('/'+argType+'/',accepttypes) = 0 then
          if argType = '' then
            raise HException.Create('DLLの関数宣言で、関数の引数型「'+str+'」は未定義です。');
          for i := 0 to sl.Count - 1 do
          begin
            // stdcall の順番に並べる
            res := res + argType + ' ' + TrimA(sl.Strings[i]) + ',';
            Inc(cnt);
          end;
          sl.Clear;
        end else
        begin
          Inc(p);
        end;
        skipSpace(p);
        if p^ = ';' then Inc(p);
      end;
      sl.Free;
      sarg := res;
      if node.HiFunc.Args.Count <> cnt then
        raise HException.CreateFmt('DLL「%s」の関数「%s」の宣言で定義している引数の数が一致しません。',[dllName, funcName]);

      // : Integer; stdcall;
      // 返値を得る
      getToken_s(cDec, ':');
      ret := UpperCaseA(TrimA(getToken_s(cDec,';')));
      //ret := Trim(UpperCase(ret));
      if ret = '' then
        ret := 'VOID'
      else begin
        str:=ret;
        replace_dll_types(ret);
      end;
      //if Pos('/'+ret+'/',acceptTypes) = 0 then
      if ret = '' then
        raise HException.Create('DLLの関数宣言で、関数の戻り型「'+str+'」は未定義です。');
    end;

    procedure analizeCDec;
    var
      cnt: Integer;
      p: PAnsiChar;
      str: AnsiString;//for debug
    begin
      // 返値を得る
      ret := UpperCaseA(TrimA(getToken_s(cDec,' ')));
      if (ret = 'FUNCTION')or(ret = 'PROCEDURE') then begin analizeDelphiDoc; Exit; end;
      if PosA('(', ret) > 0 then //カッコがあれば返値が省略されているということ
      begin
        cDec := ret + ' ' + cDec; // 元に戻す
        ret  := 'VOID'; // VOID
      end;
      //ret := Trim(UpperCase(ret));
      str:=ret;
      replace_dll_types(ret);
      //if Pos('/'+ret+'/',acceptTypes) = 0 then
      if ret = '' then
        raise HException.Create('DLLの関数宣言で、関数の戻り型「'+str+'」は未定義です。');

      // DLL関数名(C風)を得る
      funcName := TrimA(getToken_s(cDec, '('));
      if PAnsiChar(funcName)^ = '*' then
      begin
        ret := 'P' + ret;
        System.Delete(funcName, 1, 1);
      end;      

      // 引数を得る
      sarg := TrimA(getToken_s(cDec, ')'));
      if sarg = 'VOID' then sarg := '';

      // 引数の正当性をチェック
      cnt := 0;
      p   := PAnsiChar(sarg);
      res := '';
      while p^ <> #0 do
      begin
        while p^ in [' ',#9,#13,#10] do Inc(p);
        if p^ = '/' then getTokenStr(p, #13#10);
        while p^ in [' ',#9,#13,#10] do Inc(p);
        argName := TrimA(getTokenCh(p, [',',')','/']));
        argType := TrimA(getToken_s(argName, ' '));
        if argType = '' then begin argType := argName; argName := ''; end;
        if argType = '' then Continue;
        //if Copy(argName, 1, 1) = '*' then
        if PAnsiChar(argName)^ = '*' then
        begin
          argType := argType + '*';
          System.Delete(argName, 1, 1);
        end;
        argType := UpperCaseA(argType);
        str:=argType;
        replace_dll_types(argType); // DLLインポート型の単純置換
        //if Pos('/'+argType+'/',acceptTypes) = 0 then
        if argType = '' then
          raise HException.Create('DLLの関数宣言で、関数の引数型「'+str+'」は未定義です。');
        // stdcall の順番に並べる
        res := res + argType + ' ' + argName + ',';
        Inc(cnt);
      end;
      sarg := res;
      if node.HiFunc.Args.Count <> cnt then
        raise HException.CreateFmt('DLL「%s」の関数「%s」の宣言で定義している引数の数が一致しません。',[dllName, funcName]);
    end;

  begin
    //----------------
    // 引数の取得
    // 名前
    if (token = nil) then raise HException.Create('DLL宣言が不完全です。');
    dllName := string(Token.GetConstStr);
    TokenNextToken(token);
    if (token = nil)or(dllName='') then raise HException.Create('DLL宣言が不完全です。');
    // commma
    if (token <> nil) and (token.TokenID = token_comma) then
    begin
      token := token.NextToken;
    end;
    // 宣言文字列
    cDec    := token.GetConstStr;
    token := token.NextToken;
    //----------------
    // 宣言の解析
    analizeCDec; // stdcall 呼び出し規則に則れ！
    // DLLエントリポイントを取得
    i := HiSystem.DllNameList.IndexOf(dllName);
    if i < 0 then
    begin
      h := LoadLibrary(PChar(dllName));
      if h <= 0 then
      begin
        if Pos(':\', dllName) = 0 then
        begin
          dllName := ExtractFilePath(ParamStr(0)) + 'plug-ins\' + dllName;
          h := LoadLibrary(PChar(dllName));
        end;
        if h <= 0 then begin
          raise Exception.Create('DLL「'+dllName+'」が読み込めません。エラーコード:'+IntToStr(GetLastError));
        end;
      end;
      HiSystem.DllHInstList.AddNum(h);
      HiSystem.DllNameList.Add(dllName);
    end else
    begin
      h := Cardinal(HiSystem.DllHInstList.Items[i]);
    end;
    // DLL内の関数へのエントリポイントを取得
    proc := GetProcAddress( h, PAnsiChar(funcName) );
    if proc = nil then raise HException.CreateFmt('DLL「%s」に関数「%s」が見当たりません。',[dllName, funcName]);

    // 変数に設定
    node.HiFunc.PFunc       := proc;
    node.HiFunc.FuncType    := funcDll;
    node.HiFunc.DllRetType  := ret;
    node.HiFunc.DllArgType  := sarg;
  end;

  procedure DLLImport;
  const ErrDll = 'DLLのインポートエラー。';
  begin
    Token := Token.NextToken; // skip '='
    if Token = nil then raise HException.Create(ErrDll);
    if Token.UCToken <> 'DLL' then raise HException.Create(ErrDll);
    Token := Token.NextToken; // skip 'DLL'
    if (Token = nil) or (Token.Token <> '(') then raise HException.Create(ErrDll);
    Token := Token.NextToken;
    {DLLのインポート} AnalizeDllImport;
    if (Token = nil) or (Token.Token   <> ')') then raise HException.Create(ErrDll);
    Token := Token.NextToken;
  end;

  procedure _defineGroup;
  var oya, ko: PHiValue;
  begin
    // 関数名をグループに登録する
    node.FlagGroupMember := True;
    ko  := nil;
    oya := HiSystem.GetVariable(token.TokenID);
    if oya = nil then
    begin
      oya := HiSystem.CreateHiValue(token.TokenID);
      oya.Designer := HiSystem.FlagSystem;
    end;
    hi_group_create(oya);
    token := token.NextToken;
    try
      if token = nil then raise HException.Create('メンバ名がありません。');
      while token <> nil do
      begin
        // エラーチェック
        if token.JosiID = josi_wa then raise HException.Create('関数宣言で「xxはxx」の形で初期値を代入することはできません。');
        // →なら次を見る
        if token.TokenID = token_right then token := token.NextToken;
        // 子が定義されているか？
        funcNameToken := token;
        ko := hi_group(oya).FindMember(token.TokenID);
        if ko = nil then
        begin
          ko := hi_var_new;
          ko.VarID := token.TokenID;
          hi_group(oya).Add(ko);
        end;
        // 次に続くか？
        token := token.NextToken;
        if token = nil then Break;
        // 次に続くなら親にする
        if (token.JosiID <> -1) or (token.TokenID = token_right) then
        begin
          oya := ko;
          hi_group_create(oya);
        end;
        // ( や ~ なら引数の指定なので終わる
        if token.TokenID = token_kakko_begin then Break;
        if token.TokenID = token_tilde then Break;
        if token.TokenID = token_eq then raise HException.Create('関数に＝で初期値を代入することはできません。');
      end;
    except on e:Exception do
      raise HException.Create(
        'グループ付関数『'+
        hi_id2tango(funcNameToken.TokenID)+
        '』の定義に失敗。' +
        AnsiString(e.Message));
    end;
    tango := ko;
  end;

begin
  // todo 2: ●関数の宣言を読む
  Result := True;
  defIndent := token.Indent;
  node := TSyntaxDefFunction.Create(nil);
  node.DebugInfo := token.DebugInfo;

  // SKIP '*' MARK
  token := token.NextToken;
  if token = nil then raise HException.CreateFmt(ERR_S_SYNTAX,['*']);

  // READ NAME
  //-------------------------------
  funcNameToken := token;
  // グループメンバの動的作成か？
  if ((token.JosiID <> -1)and(token.JosiID <> josi_towa)) or
     ((token.NextToken <> nil) and (token.TokenID = token_right)) then
  begin
    _defineGroup;
    node.FuncID := funcNameToken.TokenID;
  end else
  // 一般の関数
  begin
    // 単語-関数-生成
    tango := hi_var_new;
    tango.VarID := token.TokenID;
    tango.Designer := HiSystem.FlagSystem;
    node.FuncID := token.TokenID;
    token := token.NextToken; // skip "NAME"
  end;
  // 関数として認識させる
  hi_func_create(tango);
  node.HiFunc := tango.ptr;
  node.HiFunc.FuncType := funcUser; // デフォルト ... 後で読んで宣言があればfuncDLLになる
  // if (token = nil) then raise HException.CreateFmt(ERR_S_DEF_FUNC,[hi_id2tango(fNameID)]);

  // READ ARG
  if token <> nil then
  begin
    if (token.TokenID = token_kakko_begin)       then getDefArgs(token, node.HiFunc.Args);
    if (token<>nil)and(token.TokenID = token_Eq) then DLLImport;

    // ";"を飛ばす
    while (token <> nil) and (token.TokenID = token_semicolon) do token := token.NextToken;
    // "~"を飛ばす
    if (token <> nil) and (token.TokenID = token_tilde) then
    begin // 行末までスキップ
      while token <> nil do token := token.NextToken;
    end;
    {
    if token <> nil then
      raise HException.CreateFmt(ERR_S_DEF_FUNC+'関数名に助詞を含んでいる可能性があります。',[hi_id2tango(node.FuncID)]);
    }
  end;

  if node.HiFunc.FuncType = funcDll then
  begin
    if not HiSystem.FlagSystemFile then
    begin
      raise HException.Create(ERR_SECURITY + '危険なファイルアクセスの他、DLLのインポートが許可されていません。');
    end;
    HiSystem.Global.RegistVar(tango);
    FreeAndNil(node);
    Exit; // DLLに定義はない
  end;

  // DEFINE
  // 二重定義の禁止
  if HiSystem.Namespace.CurSpace.GetVar(tango.VarID) <> nil then
  begin
    raise HException.CreateFmt('関数の宣言で「%s」は使われています。',[hi_id2tango( tango.VarID )]);
  end;
  if node.FlagGroupMember = False then
  begin
    //HiSystem.Global.RegistVar(tango);
    HiSystem.Namespace.CurSpace.RegistVar(tango);
  end;
  HiSystem.DefFuncList.Add(node);
  THiFunction(tango.ptr).PFunc := node; // ** LINK 定義内容へのリンク

  //------------------------------------
  // 関数の内容があるか？
  //------------------------------------
  // n := node.Children;
  if token = nil then NextBlock(token);
  if token = nil then Exit;

  // *aaaa (0) defIndet
  //   xxx (2) Token.Indent
  if defIndent < token.Indent then
  begin
    //if node <> nil then node.contents := token;
    SkipBlock(token); // 実体は後ほど読むのです(ReadDefFunctionContents)
  end;

end;

function THiParser.ReadEach(var token: THimaToken; defIndent: Integer): Boolean;
var
  node: TSyntaxEach;
  n: TSyntaxNode;
  i: Integer;
begin
  // 反復内容を取得
  node := TSyntaxEach.Create(nil);
  node.FlagLive := True;

  // 対象を下ろす(AをBで)
  i := FStack.FindJosi(josi_wo);
  if i < 0 then i := FStack.FindJosi(josi_de);
  if i < 0 then
  begin
    // 反復条件が省略された場合
    node.jouken := TSyntaxValue.Create(node);
    with TSyntaxValue(node.jouken) do begin
      VarID := token_sore;
      Element.LinkType := svLinkGlobal;
      Element.VarLink  := HiSystem.Sore;
    end;
  end else
  begin
    node.jouken := FStack.GetAndDel(i);
  end;
  // イテレーター変数を調べる
  i := FStack.FindJosi(josi_de);
  if i >= 0 then
  begin
    n := FStack.GetAndDel(i);
    if n is TSyntaxValue then
      node.iVar := n as TSyntaxValue
    else
      raise HException.Create('『(変数)で(反復内容)を反復』の書式で指定してください。');
  end;

  //-------------
  node.DebugInfo := node.jouken.DebugInfo;
  n := node.Children;

  // 反復するプログラムを取得
  token := token.NextToken; // skip 反復する
  if (token <> nil)and(token.TokenID = token_kakko_begin)and(token.NextToken = nil) then raise HException.Create('『反復』の直後に『(』は使えません。インデントで構造化を表現します。');

  StackPush;
  try
    ReadSyntaxBlock(token, n, defIndent);
  except on e: Exception do
    raise HException.Create('『反復』構文内でエラーです。' + AnsiString(e.Message));
  end;
  StackPop;
  {
  if token = nil then
  begin
    NextBlock(token);
    try
      if (token<>nil)and(token.Indent > defIndent) then
        ReadBlocks(token, n);
    except on e: Exception do
      raise HException.Create('反復構文でエラー。' + e.Message);
    end;
  end else
  begin
    ReadLineEx(token, n);
  end;
  }
  //
  FStack.Push(node);
  Result := True;
end;

function THiParser.ReadFor(var token: THimaToken; defIndent: Integer): Boolean;
var
  node: TSyntaxFor;
  n: TSyntaxNode;
begin
  node := TSyntaxFor.Create(nil);
  node.FlagLive := True;

  //------------------------------------
  // 引数の取得
  //------------------------------------

  // ～から～まで(を)
  node.VarTo   := FStack.Pop(josi_made);
  node.VarFrom := FStack.Pop(josi_kara);
  if (node.VarFrom = nil)or(node.VarTo = nil) then raise HException.Create(ERR_SYNTAX+'『(変数)で(開始値)から(終了値)まで繰り返す～』の書式で指定してください。');

  // ループカウンタの取得
  // ～で｜～を
  node.VarLoop := FStack.Pop(josi_de);
  if node.VarLoop = nil then node.VarLoop := FStack.Pop(josi_wo);

  // デバッグ情報をセット
  node.DebugInfo := node.VarTo.DebugInfo;

  //------------------------------------
  // 繰り返す内容を取得
  //------------------------------------
  token := token.NextToken; // SKIP "繰り返す"
  n := node.Children;

  StackPush;
  try
    ReadSyntaxBlock(token, n, defIndent);
    {
    if token = nil then
    begin
      NextBlock(token);
      if (token<>nil)and(defIndent<token.Indent) then
      begin
        ReadBlocks(token, n);
      end;
    end else
    begin
      if (token.TokenID = token_kakko_begin)and(token.NextToken = nil) then raise HException.Create('『繰り返す』の直後に『(』は使えません。インデントで構造化を表現します。');
      ReadLineEx(token, n);
    end;
    }
  except on e: Exception do
    raise Exception.Create('『繰り返す』構文でエラー。' + e.Message);
  end;
  StackPop;
  FStack.Add(node);
  Result := True;
end;

function THiParser.ReadFunction(var token: THimaToken; v: PHiValue;
  link: TSyntaxFunctionLink): Boolean;
var
  HiFunc: THiFunction;
  SyntaxFunc: TSyntaxFunction;

  procedure get_args;
  var
    i, j, si, josiID: Integer;
    arg: THimaArg;
    flag: Boolean;
    UseJosi: Boolean;
  begin
    // 後ろに ( があれば引数なので引数を取得
    if (token <> nil)and(token.TokenID = token_kakko_begin) then
    begin
      try
        ReadArg(token, josiID);
        UseJosi := False;
      except on e: Exception do
        raise HException.CreateFmt(ERR_S_CALL_FUNC + e.Message,[hi_id2tango(v.VarID)]);
      end;
      SyntaxFunc.JosiId := josiID;
    end else
    begin
      UseJosi := True;
    end;

    // FStack から引数を取得して SyntaxFunc のスタックに乗せる
    if HiFunc.Args = nil then
    begin
      raise HException.Create(hi_id2tango(SyntaxFunc.FuncID));
    end;
    for i := HiFunc.Args.Count - 1 downto 0 do
    begin
      // 引数はスタックのトップからPOPするのが基本だが、助詞の番号によって順序が入れ替わる
      arg := HiFunc.Args.Items[i];
      if UseJosi = True then // 助詞を判別して引数の順番を決める
      begin

        flag := False;
        for j := 0 to arg.JosiList.Count - 1 do
        begin
          si := FStack.FindJosi(arg.JosiList.GetAsNum(j));
          if si < 0 then Continue;
          SyntaxFunc.Stack.Items[i] := FStack.GetAndDel(si);
          flag := True;
          Break;
        end;

      end else // 助詞の順番を考慮しない
      begin

        flag := (FStack.Count > 0);
        if flag then
          SyntaxFunc.Stack.Items[i] := FStack.Pop
        else
          SyntaxFunc.Stack.Items[i] := nil;

      end;

      // 引数取得のチェック
      if (flag = False) then
      begin
        if (arg.Needed) then
        begin
          if arg.JosiList.Count > 0 then
            raise HException.CreateFmt(
              ERR_SS_FUNC_ARG,[hi_id2tango(v.VarID),hi_id2tango(arg.Name)+HiSystem.JosiList.ID2Str(arg.JosiList.GetAsNum(0))])
          else
            raise HException.CreateFmt(
              ERR_SS_FUNC_ARG,[hi_id2tango(v.VarID),hi_id2tango(arg.Name)]);
        end else
        begin
          SyntaxFunc.Stack.Items[i] := nil;
        end;
      end;
    end;
  end;

begin
  //todo 2:●関数の読み込み
  Result := False;
  if v.VType <> varFunc then Exit;
  HiFunc := v.ptr;

  // Node の作成
  SyntaxFunc := TSyntaxFunction.Create(nil);
  SyntaxFunc.FlagLive := True;
  case link.LinkType of
    sfLinkDirect, sfLinkVirtuaLink:
    begin
      SyntaxFunc.DebugInfo  := token.DebugInfo;
      SyntaxFunc.JosiId     := token.JosiID;
      SyntaxFunc.FuncID     := v.VarID;
      SyntaxFunc.HiFunc     := HiFunc;
      SyntaxFunc.Link       := link;
      token                 := token.NextToken; // SKIP FUNC_NAME
    end;
    sfLinkGroupMember:
    begin
      SyntaxFunc.DebugInfo  := link.LinkValue.DebugInfo;
      SyntaxFunc.JosiId     := link.LinkValue.JosiID;
      SyntaxFunc.FuncID     := v.VarID;
      SyntaxFunc.HiFunc     := HiFunc;
      SyntaxFunc.Link       := link;
    end;
  end;
  SyntaxFunc.FDebugFuncName := hi_id2tango(SyntaxFUnc.FuncID);

  // 関数名の後にある『？』を許す
  if token <> nil then
  if token.TokenID = token_question then token := token.NextToken;


  // 引数の取得
  get_args;

  // プラグインが利用されればIDをチェック
  if (SyntaxFunc.HiFunc.PluginID >= 0)or(SyntaxFunc.HiFunc.IzonFiles <> '') then
  begin
    HiSystem.plugins.ChangeUsed(
      SyntaxFunc.FuncID,
      SyntaxFunc.HiFunc.PluginID, True,
      '', //hi_id2tango(SyntaxFunc.FuncID) // 関数名をメモする
      string(SyntaxFunc.HiFunc.IzonFiles)
    );
  end;

  FStack.Add(SyntaxFunc);
  Result := True;
end;

function THiParser.ReadIf(var token: THimaToken; defIndent: Integer): Boolean;
var
  node: TSyntaxIf;
  n: TSyntaxNode;
begin
  //Result := False;
  // (POP) ならば or でなければ
  n := FStack.Pop;
  node := TSyntaxIf.Create(nil);
  node.FlagLive := True;
  node.DebugInfo := n.DebugInfo;
  node.Jouken := n;
  node.Reverse := (n.JosiId = josi_denakereba);
  // TRUE 文を得る
  StackPush;

  node.TrueNode := TSyntaxSentence.Create(nil);
  n := node.TrueNode.Children;
  try
    ReadSyntaxBlock(token, n, defIndent);
  except on e: Exception do
    raise Exception.Create('『もし～ならば』構文のならばブロックでエラー。' + e.Message);
  end;
  {
  if token = nil then
  begin
    NextBlock(token);
    if (token <> nil) and (token.Indent > defIndent) then
    begin
      if (token <> nil) and (token.Indent > defIndent) then
      begin
        try
          ReadBlocks(token, n);
        except on e: Exception do
          raise HException.Create('『もし～ならば』構文のならばブロックでエラー。' + e.Message);
        end;
      end;
    end;
  end else
  begin
    node.TrueNode := TSyntaxSentence.Create(nil);
    n := node.TrueNode.Children;
    //ReadSentence(token, n);
    ReadLine(token, n);
  end;
  }
  StackPop;
  // FALSE 文があるか
  if token = nil then NextBlock(token);
  if (token <> nil) and (defIndent <= token.Indent) then
  if (token <> nil) and (
        (token.TokenID = token_tagaeba) or (
          (token.TokenID <= 0)and(token.JosiID = josi_denakereba)
        )
      )
  then begin
    StackPush;
    // "違えば"文の読み取り
    TokenNextToken(token); // SKIP "違えば"
    node.FalseNode := TSyntaxSentence.Create(nil);
    n := node.FalseNode.Children;
    try
      ReadSyntaxBlock(token, n, defIndent);
    except on e: Exception do
      raise Exception.Create('『もし～ならば』構文の違えばブロックでエラー。' + e.Message);
    end;
    {
    if token = nil then
    begin
      NextBlock(token);
      if (token <> nil) and (token.Indent > defIndent) then
      begin
        try
          ReadBlocks(token, n);
        except on e: Exception do
          raise HException.Create('『もし～ならば』構文の違えばブロックでエラー。' + e.Message);
        end;
      end;
    end else
    begin
      //ReadSentence(token, n);
      ReadLine(token, n);
    end;
    }
    StackPop;
  end;
  //...
  FStack.Push(node);
  Result := True;
end;

function THiParser.ReadKakko(var token: THimaToken): Boolean;
var
  node: TSyntaxSentence;
  n: TSyntaxNode;
begin
  if token.TokenID <> token_kakko_begin then
  begin
    raise HException.Create('『（』がありません。');
  end;

  node := TSyntaxSentence.Create(nil);
  node.DebugInfo := token.DebugInfo;
  n := node.Children;

  FPrevToken := token;
  token := token.NextToken; // SKIP '('
  if token = nil then NextBlock(token);

  StackPush;
  try
    // '(' .. ')' を取得する
    while token <> nil do
    begin
      if token.TokenID = token_kakko_end then Break;
      ReadLine(token, n, False);
      if token = nil then NextBlock(token); // 改行を跨ぐ（）にも対応。
    end;
    if (token = nil)or(token.TokenID <> token_kakko_end) then
      raise HException.Create(ERR_NOPAIR_KAKKO);
    if (FStack.Count > 0) then;

    node.JosiId := token.JosiID;
    FPrevToken := token;
    token := token.NextToken; // SKIP ')'

  finally
    StackPop;
  end;
  FStack.Push(node);
  Result := True;
end;

function THiParser.ReadLet(var token: THimaToken; IsDainyu: Boolean): Boolean;
var
  node: TSyntaxLet;
  n, wo: TSyntaxNode;
  v: TSyntaxValue;
begin
  //todo 3:＝代入の読み込み

  if IsDainyu = True then
  begin
    // 代入命令を用いた代入

    // 何へ代入するのか
    n := FStack.Pop(josi_ni);
    if (n = nil) then n := FStack.Pop(josi_he);
    if (n = nil) then raise HException.Create(ERR_SYNTAX + '何に代入するのか指定されていません。');
    if n.ClassType <> TSyntaxValue then raise HException.Create(ERR_SYNTAX + '定数には代入できません。(変数名)に代入。の書式で記述してください。');
    v := n as TSyntaxValue;
    if v.ReadOnly then raise HException.CreateFmt(ERR_SYNTAX + '定数"%s"には代入できません。',[hi_id2tango(v.VarID)]);

    // "その"を更新
    if v.Element.NextElement <> nil then
    begin
      if (v.VarID <> token_sono) then SonoTokenID := v.VarID;
    end;

    // ノードを挿入
    node := TSyntaxLet.Create(nil);
    node.FlagLive := True;
    node.DebugInfo := v.DebugInfo;
    node.VarID := v.VarID;
    node.VarNode := v;

    // 何を代入するのか
    wo := FStack.Pop(josi_wo);
    if wo = nil then
    begin
      v := TSyntaxValue.Create(node);
      v.VarID := token_sore;
      v.Element.LinkType := svLinkGlobal;
      v.Element.VarLink  := HiSystem.Sore;
      //node.Children.Next := v;
      node.Children.Free;
      node.Children := v;
    end else
    begin
      node.Children.Free;  // Children.Next = wo にすると Children が TSyntaxValue にならないから
      node.Children := wo; //
    end;

    //----------------------
    FStack.Add(node);
    Result := True;
    Exit;
  end;

  //----------------------------------------------------------------------------
  // "=" "は" を用いた代入
  if {(token = nil)or}(FStack.Count = 0) then raise HException.Create(ERR_SYNTAX + '代入する値がありません。');

  // 代入すべき変数を取得
  n := FStack.Pop;
  if n.ClassType <> TSyntaxValue then
  begin
    raise HException.Create(ERR_SYNTAX + '"' + n.DebugStr + '"には代入できません。(変数名)は(値)。の書式で記述してください。');
  end;
  v := n as TSyntaxValue;
  if v.ReadOnly then raise HException.CreateFmt(ERR_SYNTAX + '定数"%s"には代入できません。',[hi_id2tango(v.VarID)]);

  // "その"を更新
  if (v.Element.NextElement <> nil) then
  begin
    if (v.VarID <> token_sono) then SonoTokenID := v.VarID;
  end else
  if (v.Element.VarLink <> nil)and(v.Element.VarLink.VType = varGroup) then
  begin
    SonoTokenID := v.Element.VarLink.VarID;
  end;
  
  node := TSyntaxLet.Create(nil);
  node.FlagLive := True;
  node.DebugInfo := n.DebugInfo;
  node.VarID := v.VarID;
  node.VarNode := v;
  FStack.Add(node);

  // イベントの代入か？
  if (token = nil) or (token.TokenID = token_tilde) then
  begin
    if token <> nil then token := token.NextToken; // SKIP "~"
    node.IsEvent := True;
    //------------------------------
    // イベントの処理について
    //------------------------------
    // イベントはこの後に宣言するオブジェクトも出てくるので
    // 未定義による変数リンクエラーが起きる
    // そこでイベントはイベントの実行時に読み直すことにする
    //-----------------------------
    // ソースへのリンクを作る
    if token = nil then begin
      NextBlock(token);
      if (token <> nil)and(token.Indent > 0) then
      begin
        node.token := token;
        SkipBlock(token);
      end else
      begin
        node.token := nil;
      end;
      node.tokenMultiLine := True;
    end else begin
      node.token := token;
      NextBlock(token);
      node.tokenMultiLine := False;
    end;
    Result := True; Exit;
  end;

  // 値を取得
  StackPush;
  n := node.Children;
  if token = nil then
  begin
    NextBlock(token);
    ReadBlocks(token, n);
  end else
  begin
    ReadLine(token, n, false);
  end;
  StackPop;
  Result := True;
end;

procedure THiParser.ReadLine(var token: THimaToken; var cnode: TSyntaxNode; CanLet:Boolean = True);
var
  curIndent, i, cnt: Integer;
  n, nn: TSyntaxNode;
  flagMosi: Boolean;
  tmp, CheckToken, lastToken: THimaToken;

  // 『ここまで』構文のチェック
  function _chk(res: Boolean; w: DWORD): Boolean;
  var
    tmp: THimaToken;
    tmpBlock: THimaToken;
  begin
    Result := res;

    tmp := token;
    tmpBlock := FNextBlock;

    if token = nil then NextBlock(token);
    if (token <> nil)and(token.TokenID = token_koko)and(token.JosiID = josi_made) then
    begin
      token := token.NextToken;
      while (token <> nil) do
      begin
        if (token.TokenID = token_Semicolon)or(token.TokenID = token_comma) then
          token := token.NextToken
        else
          Break;
      end;
      if (token <> nil)and(token.TokenID <> w) then
      begin
        raise HException.CreateFmt('『ここまで%s』で明示された構文は『ここまで%s』であるべきです。',
          [hi_id2tango(token.TokenID), hi_id2tango(w)]);
      end else
      begin
        if token <> nil then token := token.NextToken;
      end;
    end else
    begin
      token := tmp; // ここまでがなかったので元に戻す
      FNextBlock := tmpBlock;
    end;
  end;

begin
  if token = nil then Exit;

  CheckToken := token;
  lastToken  := nil;
  FReadFlag.CanLet := CanLet; // 代入が可能かどうか

  StackPush;
  flagMosi := False;
  try
  try

    //todo 2: ＠一行読む
    curIndent := token.Indent;
    while token <> nil do
    begin
      if curIndent <> token.Indent then Break; // 次の行に移った
      if token.TokenID = token_kakko_end then Break; // ')' なら行抜け
      if token.TokenID = token_tagaeba   then Break; // '違えば'なら抜け
      if token.TokenID = token_semicolon then begin token := token.NextToken; Break; end;

      // いつまでも同じ場所を読んでいる場合の対策
      if lastToken <> nil then
      begin
        if lastToken = token then
        begin
          raise HException.Create('パースエラー。単語「'+hi_id2tango(token.TokenID)+'」が読めません。');
        end;
      end;
      lastToken := token;

      // ',' はあらかじめスキップさせておく
      if token.TokenID = token_comma then
      begin
        FPrevToken := token;
        token := token.NextToken;
      end;

      // 変数の宣言(～とは）
      if token.JosiID = josi_towa then
      begin
        RegistVar(token);
        //StackToNode(cnode);// ノードの順番を変更しないようにここで追加。※
        //Continue;
        Break;
      end;

      // 特殊な単語があればその処理を
      case token.TokenID of
        // 繰り返しなど単純な場合...
        {間} token_aida:        begin _chk(ReadWhile(token, CheckToken.Indent),token_aida); Break; end;
        {間} token_loop:        begin _chk(ReadWhile(token, CheckToken.Indent),token_loop); Break; end;
        {回} token_kai:         begin _chk(ReadKai  (token, CheckToken.Indent),token_kai);  Break; end;
        {繰} token_kurikaesu:   begin _chk(ReadFor  (token, CheckToken.Indent),token_kurikaesu); Break; end;
        {反} token_hanpuku:     begin _chk(ReadEach (token, CheckToken.Indent),token_hanpuku); Break; end;
        {監} token_err_kansi:   begin _chk(ReadTryExcept(token, CheckToken.Indent),token_err_kansi); Break; end;
        {岐} token_joukenbunki: begin _chk(ReadSwitch(token),token_joukenbunki); Break; end;
        // 複雑な場合...
        {もし} token_mosi:
          begin
            TokenNextToken(token); // SKIP "もし"
            TokenSkipComma(token);
            flagMosi := True;
            tmp := token;
            if _chk(ReadToNaraba(token),token_mosi) then Break else token := tmp;
          end;
        {代入} token_dainyu:
          begin
            if FReadFlag.CanLet then
            begin
              token := token.NextToken; // SKIP "代入"
              ReadLet(token, True);
              Break;
            end;
          end;
      end;
      // 『ここまで』構文？
      if (token.TokenID = token_koko)and(token.JosiID = josi_made) then
      begin
        raise HException.Create('『ここまで』が制御構文と対になっていません。');
      end;
      // GOTO
      if token.TokenID = token_mark_sankaku then
      begin
        ReadDefJumpPoint(token);
        Break;
      end; // ジャンプポイントの宣言

      //--------------------------------------
      // １つ読む
      try
        if not ReadOneItem(token) then Continue;
      except
        on e: Exception do // 正確な行番号を返す
          raise EHimaSyntax.Create(
            CheckToken.DebugInfo,
            '単語の読取に失敗。' + AnsiString(e.Message),
            []);
      end;
      //--------------------------------------

      n := FStack.GetLast; // 見るだけ下ろさない
      if n = nil then Continue;

      // ならば？
      if (n.JosiId = josi_naraba)or(n.JosiId = josi_denakereba) then
      begin
        if _chk(ReadIf(token, CheckToken.Indent), 0) then Break;
      end else
      // ...について
      if n.JosiId = josi_nituite then
      begin
        if _chk(ReadWith(token, curIndent), 0) then Break; //プログラムの実行順序の整理
      end;

      // 代入か？
      if (n.JosiId = josi_wa) then // 助詞「は」による代入
      begin
        // 警告
        if (CanLet = False)or(flagMosi = True) then raise HException.Create('(...)の中や「もし」構文では「は」を使った代入はできません。比較する場合は「=」を使います。');
        ReadLet(token);
        Break;
      end else
      if ((token<>nil)and(token.TokenID = token_Eq)) then // トークン「=」による代入
      begin
        if (flagMosi = True)or(CanLet = False) then Continue;
        token := token.NextToken;// SKIP '='
        ReadLet(token);
        Break;
      end;

    end;//of while

    // 未解決のスタックがないか残りをチェック
    if FStack.Count > 0 then
    begin
      cnt := 0; nn := nil;
      for i := 0 to FStack.Count - 1 do
      begin
        n := FStack.Get(i);
        if n.FlagLive = False then
        begin
          Inc(cnt);
          if nn = nil then nn := n;
        end;
      end;
      if cnt >= 1 then
      begin
        // 最後の１つだけは許される...戻り値の可能性があるから
        if not((FStack.GetLast.FlagLive = False)and(cnt=1))then // 例外条件
        begin
          if nn <> nil then begin
            raise EHimaSyntax.Create(
              nn.DebugInfo, '記述ミスがあります。プログラムを見直してください。%d個の語句が無意味です。命令の未定義、プラグイン不足の可能性もあります。' +
              '(「%s」助詞「%s」)',[cnt, nn.DebugStr, HiSystem.JosiList.ID2Str(nn.JosiId)]);
          end;
        end;
      end;
    end;

  except
    raise;
  end;
  finally
    StackToNode(cnode);
    StackPop;
  end;
  // 読み残しが";"ならばスキップ
  if token <> nil then
  begin
    while token <> nil do
    begin
      if token.TokenID = token_Semicolon then
      begin
        token := token.NextToken;
      end else Break;
    end;
  end;
end;

function THiParser.ReadKai(var token: THimaToken; defIndent: Integer): Boolean;
var
  node: TSyntaxLoop;
  n, c: TSyntaxNode;
begin
  //Result := False;
  if FStack.Count = 0 then raise HException.Create(ERR_SYNTAX+'『(回数)回～』の書式で使います。');

  n := FStack.Pop; // 回数

  node := TSyntaxLoop.Create(nil);
  node.DebugInfo := n.DebugInfo;
  node.FlagLive := True;
  
  node.Kaisu := n;
  token := token.NextToken; // SKIP "回"

  c := node.Children;

  StackPush;
  try
    ReadSyntaxBlock(token, c, defIndent);
    {
    if token = nil then
    begin
      NextBlock(token);
      if (token <> nil)and(defIndent < token.Indent) then ReadBlocks(token, c);
    end else
    begin
      if (token.TokenID = token_kakko_begin)and(token.NextToken = nil) then raise HException.Create('『n回』の直後に『(』は使えません。インデントで構造化を表現します。');
      ReadLineEx(token, c);
    end;
    }
  except on e: Exception do
    raise Exception.Create('『(回数)回～』でエラー。'+e.Message);
  end;
  StackPop;

  FStack.Add(node);
  Result := True;
end;

function THiParser.ReadOneItem(var token: THimaToken): Boolean;
var
  node: TSyntaxNode;
  tmp: THimaToken;
begin
  Result := False;
  if token = nil then Exit;
  tmp := token;

  //todo 2: ＠トークンを1つ読む
  // そして、 FStack へ乗せる
  case token.TokenType of
  tokenTango:
    begin
      Result := ReadTango(token);
      FPrevToken := tmp;
    end;
  tokenOperator:
    begin
      Result := ReadSiki(token);
      FPrevToken := tmp;
    end;
  tokenNumber: // 数値定数の読み取り
    begin
      Result := True;
      node := TSyntaxConst.Create(nil);
      node.DebugInfo := token.DebugInfo;
      node.JosiId    := token.JosiID;
      hi_setIntOrFloat(TSyntaxConst(node).constValue, token.NumberToken);
      FStack.Push(node);
      token := token.NextToken; // skip NUM
      FPrevToken := tmp;
    end;
  tokenParenthesis:
    begin
      if token.TokenID = token_kakko_begin then
      begin
        Result := ReadKakko(token);
      end else
      begin
        raise HException.CreateFmt(ERR_S_UNDEFINED,[hi_id2tango(token.TokenID)]);
      end;
    end;
  tokenString:
    begin
      Result := True;
      node := TSyntaxConst.Create(nil);
      node.DebugInfo := token.DebugInfo;
      node.JosiId    := token.JosiID;
      hi_setStr(TSyntaxConst(node).constValue, token.Token);
      FStack.Push(node);
      token := token.NextToken; // skip STR
      FPrevToken := tmp;
    end;
  tokenMark:
    begin
      if token.TokenID = token_Semicolon then
      begin
        token := token.NextToken;
        FPrevToken := tmp;
        Exit;
      end else
      if token.TokenID = token_comma then
      begin
        // 次の単語を読む必要がある
        // [,]b,c
        token := token.NextToken;
        // ,[b],c
        FPrevToken := tmp{comma};
        Result := ReadOneItem(token);
        Exit;
      end else
      raise HException.CreateFmt(ERR_S_UNDEF_MARK,[hi_id2tango(token.TokenID)]);
    end;
  else
    begin
      raise HException.CreateFmt('不明な語句『%s』を見つけました。',[token.Token]);
    end;
  end;
end;


procedure THiParser.ReadPreprocess(token: THimaToken; var node: TSyntaxNode);
var
  temp, topToken: THimaToken;
  FStrict: Boolean;
begin
  //todo 1: Preprocess

  FStrict := HiSystem.FlagStrict;
  temp := token;
  try
    topToken := token;

    //--------------------------
    // 関数の宣言だけ読む
    token := topToken;
    while token <> nil do
    begin
      // 次の行をチェック
      temp := token;
      FNextBlock := token.CheckNextBlock;

      // 行頭に宣言があるか？
      if (token.TokenID = token_mark_function) then
      begin
        ReadDefFunction(token);
        if token = nil then NextBlock(token);
        Continue;
      end;
      token := FNextBlock;
    end;
    FNextBlock := nil;

    //--------------------------
    // クラスの宣言+定義を読む
    token := topToken;
    while token <> nil do
    begin
      // 次の行をチェック
      temp := token;
      FNextBlock := token.CheckNextBlock;
      if (token.TokenID = token_mark_option) then
      begin
        ReadOption(token, True, node);
        Continue;
      end else
      if (token.TokenID = token_mark_sikaku) then
      begin
        ReadDefGroup(token);
        Continue;
      end;
      // 行頭に宣言があるか？
      token := FNextBlock;
    end;
    FNextBlock := nil;

  except on e: Exception do
    raise EHimaSyntax.Create(temp.DebugInfo, AnsiString(e.Message), []);
  end;

  HiSystem.FlagStrict := FStrict;
end;
{
function THiParser.ReadSentence(var token: THimaToken; var cnode: TSyntaxNode): Boolean;
var
  n: TSyntaxNode;
  c: THimaToken;
begin
  if token = nil then begin Result := False; Exit; end;
  StackPush;
  c := token;
  while token <> nil do
  begin
    if token.TokenID = token_tagaeba    then Break;
    if token.TokenID = josi_denakereba  then Break;
    if token.TokenID = token_err        then Break;
    if token.TokenID = token_mosi then
    begin
    end;
    if ReadOneItem(token) = False then Continue;
    n := FStack.GetLast;
    if n.JosiId = josi_naraba then
    begin
      if ReadIf(token, c.Indent) then Break;
    end;
  end;
  StackToNode(cnode);
  StackPop;
  Result := True;
end;
}

function THiParser.ReadSiki(var token: THimaToken): Boolean;
var
  term: TSyntaxTerm;
  node: TSyntaxCalc;
  n: TSyntaxNode;
  sikiStack: THStack;
begin
  if (FStack.Count = 0)  or (FStack.GetLast.JosiId <> -1     )or
     (FPrevToken = nil)  or (FPrevToken.TokenID = token_comma)or
     (FPrevToken.TokenID = token_Semicolon)or
     (FPrevToken.TokenID = token_kakko_begin)
  then
  begin
    // 例えば -1 の時など
    if token.TokenID = token_minus then
    begin
      term := TSyntaxTerm.Create(nil);
      token := token.NextToken; // skip '-'
      if not ReadOneItem(token) then raise HException.Create('突然の"-"');
      term.baseNode := FStack.Pop;
      term.mode := termMinus;
      term.JosiId := term.baseNode.JosiId;
      FStack.Add(term);
      Result := True;
    end else
    begin
      raise HException.Create('突然の演算子"'+ hi_id2tango(token.tokenID)+'"');
    end;
    Exit;
  end;
  
  //============================================================================
  // 計算式のパース
  //============================================================================
  // :::順序:::
  //   (1) token から式を読み取り、sikiStackに積む
  //   (2) tempStack を使って sikiStack を逆ポーランドに並び替え
  //   (3) node.Children へ移す
  //----------------------------------------------------------------------------
  sikiStack := THStack.Create;
  try
    //--------------------------------------------------------------------------
    // (1) 式の読み取り
    //--------------------------------------------------------------------------
    // 1つ目の値は FStack から POP
    n := FStack.Pop;
    sikiStack.Push(n);

    node := TSyntaxCalc.Create(nil);
    node.DebugInfo := n.DebugInfo;
    node.JosiId := n.JosiId;
    FStack.Push(node);

    // 2つ目以降は token から
    while token <> nil do
    begin
      if token.TokenType <> tokenOperator then Break;
      // 演算子の読み取り
      sikiStack.Push(getEnzansi(token));
      if token = nil then NextBlock(token); // 行末の演算子は次の行まで読む

      // -N (演算子を読んでさらに演算子)のとき
      if token.TokenID = token_minus then
      begin
        token := token.NextToken; // skip "-"
        term := TSyntaxTerm.Create(node);
        if not ReadOneItem(token) then raise HException.Create(ERR_INVALID_SIKI);
        term.baseNode := FStack.Pop;
        term.mode := termMinus;
        term.JosiId := term.baseNode.JosiId;
        node.JosiId := term.JosiId;
        sikiStack.Push(term); Continue;
      end;

      // 普通に値の読み取り
      if not ReadOneItem(token) then raise HException.Create(ERR_INVALID_SIKI);
      n := FStack.Pop;
      node.JosiId := n.JosiId;
      sikiStack.Push(n);
    end;
    //--------------------------------------------------------------------------
    // (2) 式を並び替える
    //--------------------------------------------------------------------------
    infix2rpolish(sikiStack);

    //--------------------------------------------------------------------------
    // (3) 移し変え
    //--------------------------------------------------------------------------
    StackToNodeChild(sikiStack, node);
    //writeln('---');
  finally
    sikiStack.Free;
  end;
  Result := True;
end;

function THiParser.ReadTango(var token: THimaToken): Boolean;
var
  pv, mv: PHiValue;
  node: TSyntaxValue;
  pElement, pe, pTop: TSyntaxValueElement;
  linkType: TSyntaxValueLinkType;
  funcLink: TSyntaxFunctionLink;
  ns: DWORD;
  tmp: THimaToken;
  lastJosi: Integer;

  function NewPe: TSyntaxValueElement;
  begin
    Result := TSyntaxValueElement.Create;
  end;

  procedure NextElementLink(pe: TSyntaxValueElement);
  begin
    // 次の要素へのリンクを作る
    if (pElement=nil) then
    begin
      node.Element.NextElement := pe;
      pElement := pe;
    end else
    begin
      pElement.NextElement := pe;
      pElement := pe;
    end;
    pElement.NextElement := nil;
  end;

  procedure _CheckGroupAutoCreate(root: PHiValue);
  var
    p: THimaToken;
    flagLet: Boolean;
    oya, ko: PHiValue;
  begin
    //--------------------------------------------------------------------------
    if HiSystem.FlagStrict then Exit; // 正規化されているなら以下のチェックは不要

    // 普通の処理で変数が自動生成されるならば処理は不要
    if token.JosiID = josi_wa then Exit;
    if (token.NextToken <> nil)and(token.NextToken.TokenID = token_eq) then Exit;

    // まず、代入文かどうかが重要
    p := token; flagLet := False;
    while p <> nil do
    begin
      if p.JosiID = josi_wa then
      begin
        flagLet := True; Break;
      end;
      if (p.NextToken<>nil)and(p.NextToken.TokenID = token_eq) then
      begin
        flagLet := True; Break;
      end;
      // 続きがなければ終わり
      if (p.JosiID = josi_naraba)or(p.JosiID = josi_denakereba) then Break;
      if p.JosiID = -1 then Break;
      TokenNextToken(p);
      TokenSkipComma(p);
    end;
    // 代入文か？
    if flagLet = False then Exit;

    // 数珠繋ぎにグループを作っていく
    hi_group_create(root);
    oya := root;
    //
    p := token; // 一番初めに戻してはじめの要素
    TokenNextToken(p);
    while p <> nil do
    begin
      if p.TokenID = token_eq then Break;

      // 子の追加
      ko := hi_group(oya).FindMember(p.TokenID);
      if ko = nil then
      begin
        ko := hi_var_new;
        ko.VarID := p.TokenID;
        hi_group(oya).Add(ko);
      end;
      if p.JosiID = josi_wa then Break;
      if (p.NextToken <> nil)and(p.NextToken.TokenID = token_eq) then Break;

      // 子が親になる
      oya := ko;
      hi_group_create(oya);
      TokenNextToken(p);
      TokenSkipComma(p);
    end;
  end;

  // xxとはoo = vv の新規型を生成する
  function _newGroupVar: Boolean;
  var
    p: THimaToken;
    flagTowa: Boolean;
    oya, ko, def, con, vv: PHiValue;
    vType: THiVType;
    sf: TSyntaxFunction; sv: TSyntaxValue; n: TSyntaxNode;
  begin
    // --- 先読みする ----------------------------------------------------------
    // ...とは...があるか？
    Result   := False;
    flagTowa := False;
    vType    := varNil;
    p := token;
    while p <> nil do
    begin
      if p.JosiID = -1 then Break; // "xxxのxxx"のように助詞がない場合は抜ける
      if p.JosiID = josi_towa then begin flagTowa := True; Break; end;
      if p.TokenID = token_Semicolon then Break;
      TokenNextToken(p);
      TokenSkipComma(p);
    end;
    if not flagTowa then Exit;
    // ---
    // 親なしで変数宣言
    if token.JosiID = josi_towa then
    begin
      ko := HiSystem.CreateHiValue(token.TokenID);
      ko.Designer := HiSystem.FlagSystem;
      TokenNextToken(token);
      TokenSkipComma(p);
    end else
    // 親ありで変数宣言（グループ）
    begin
      ko  := nil;
      oya := HiSystem.GetVariable(token.TokenID);
      if oya = nil then // 親を作る
      begin
        oya := HiSystem.CreateHiValue(token.TokenID);
        oya.Designer := HiSystem.FlagSystem;
      end;
      token := token.NextToken;
      while token <> nil do
      begin
        hi_group_create(oya);
        ko := hi_group(oya).FindMember(token.TokenID);
        if ko = nil then // メンバを作る
        begin
          ko := hi_var_new;
          ko.VarID := token.TokenID;
          hi_group(oya).Add(ko);
        end;
        if token.JosiID = josi_towa then
        begin
          TokenNextToken(token);
          Break;
        end;
        oya := ko; // 続き
        TokenNextToken(token);
        TokenSkipComma(p);
      end;
    end;
    if ko = nil then raise HException.Create('変数宣言に失敗。');
    if token.TokenID = token_comma then token := token.NextToken;
    if token = nil then raise HException.CreateFmt('変数宣言に失敗。『%sとはxxx』のxxx部分（変数の型）がありません。',[hi_id2tango(ko.VarID)]);
    // xxxとはooo の ooo 部分
    def := nil;
    while token <> nil do
    begin
      if token.JosiID = -1 then Break;
      def := HiSystem.GetVariable(token.TokenID);
      if def = nil then raise HException.CreateFmt('変数『%s』の宣言で型が特定できません。',[hi_id2tango(ko.VarID)]);
      if def.VType <> varGroup then raise HException.CreateFmt('変数『%s』の宣言で型が特定できません。',[hi_id2tango(ko.VarID)]);
      TokenNextToken(token);
      TokenSkipComma(p);
      vType := varGroup;
    end;
    // 型の特定
    if def = nil then
    begin
      if token = nil then raise HException.CreateFmt('変数『%s』の宣言で型が特定できません。',[hi_id2tango(ko.VarID)]);
      case token.TokenID of
        token_hensuu: vType := varNil;
        token_seisu:  vType := varInt;
        token_suuti,
        token_jissuu: vType := varFloat;
        token_mojiretu: vType := varStr;
        token_hairetu: vType := varArray;
        token_group: vType := varGroup;
        token_hash:  vType := varHash;
        else
          begin
            vType := varGroup;
            def := HiSystem.GetVariable(token.TokenID);
            if (def = nil)or(def.VType <> varGroup) then raise HException.CreateFmt('変数『%s』の宣言で型が特定できません。',[hi_id2tango(ko.VarID)]);
          end;
      end;
      TokenNextToken(token);
      TokenSkipComma(p);
    end;
    // group の複製
    if def <> nil then
    begin
      hi_group_create(ko);
      hi_group(ko).Assign(hi_group(def)); // メンバの複製
      con := hi_group(ko).FindMember(token_tukuru); // コンストラクターがあるか？
      if (con <> nil)and(con.VType = varFunc) then
      begin
        sf := TSyntaxFunction.Create(nil);
        sf.FDebugFuncName := '作';
        sf.DebugInfo := token.DebugInfo;
        sf.FuncID := token_tukuru; // 作る
        sf.HiFunc := hi_func(con);
        sf.Link.LinkType  := sfLinkGroupMember;
        sv := TSyntaxValue.Create(nil);
        sv.VarID := ko.VarID;
        sv.Element.LinkType := svLinkGlobal;
        sv.Element.VarLink := ko;
        sv.Element.NextElement := TSyntaxValueElement.Create;
        sv.Element.NextElement.LinkType := svLinkGroup;
        sv.Element.NextElement.groupMember := token_tukuru;
        sf.Link.LinkValue := sv;
        FStack.Add(sf);
      end;
    end else
    begin
      // 初期値をセット
      if (token <> nil)and(token.TokenID = token_eq) then
      begin
        TokenNextToken(token); // skip '='
        // 初期値に計算を含んでいてもばっちり計算するように！
        StackPush;
        try
          if ReadOneItem(token) = False then raise HException.Create('変数宣言で初期値がありません。');
          while (token <> nil) do ReadOneItem(token);
          if FStack.Count > 1 then raise HException.Create('変数宣言で初期化式で値が２つ以上存在します。');
          n := FStack.Pop;
          vv := n.getValue; // 変数名を壊してしまうので必ず vv へ値を得てそのあとコピーしなおす
          hi_var_copyGensi(vv, ko);
          if vv.Registered = 0 then hi_var_free(vv);
          FreeAndNil(n);
          if vType <> varNil then hi_var_ChangeType(ko, vType);
        finally
          StackPop;
        end;
      end;
    end;
    Result := True;
  end;

  function _checkBeyondMethod(group: PHiValue): Boolean;
  var tmp: THimaToken; flg: Boolean; p: PHiValue;
  begin
    Result := False;
    if token = nil then Exit;
    tmp := token; // グループ ... 命令メソッドではなかったときのために

    // グループの直後がメンバではなかった場合
    flg := False;
    // グループの直後がメンバでなく、グループだった場合は直ちに失敗
    p := HiSystem.GetVariable(token.TokenID);
    if (p<>nil)and(p.VType = varGroup) then Exit;
    // GROUP 引数越えかどうか確認
    while token <> nil do
    begin
      // トークンをジャンプ
      token := token.NextToken;
      // 調べる
      if token = nil then Break;
      if token.TokenID = token_semiColon then Break;
      // : があれば次の単語は飛ばす
      if token.TokenID = token_colon then
      begin
        token := token.NextToken; // skip ":"
        Continue;
      end;
      if token.TokenType <> tokenTango then Continue;
      // = があれば区切りなのでそれ以後は読まない
      if token.JosiID = josi_wa then Break;
      if token.TokenID = token_Eq then Break;
      // 『GROUP1がGROUP2のMETHOD』の場合、GROUP2->METHODを優先するので
      // 途中にGROUPがあれば、このチェックは失敗する
      // METHODの引数を読んで判別するか？...判別しない
      p := HiSystem.GetVariable(token.TokenID);
      if (p <> nil)and(p.VType = varGroup) then Break;
      // グループメンバかどうか確認
      p := hi_group(group).FindMember(token.TokenID);
      if p = nil then Continue; // メンバが存在しない...続ける
      if p.VType <> varFunc then Continue; // メンバだが関数ではない...一応続ける
      flg := True; Break;
    end;
    if flg = False then
    begin
      token := tmp; // トークンを元の位置に戻して抜ける
      Exit;
    end;
    // 関数メンバだったらそのままスタックへ引数を積んでいく
    token := tmp; flg := False; p := nil;
    while token <> nil do
    begin
      // 読んでスタックに積む
      if ReadOneItem(token) = False then Continue;
      p := hi_group(group).FindMember(token.TokenID);
      // 終了判定
      if p = nil then Continue;            // メンバが存在しない...続ける
      if p.VType <> varFunc then Continue; // メンバだが関数ではない...一応続ける
      flg := True; Break;
    end;
    // 一応確認
    if flg = False then raise HException.CreateFmt('グループ『%s』の後にメンバが見つかったのですが、式が複雑すぎてスタックへ積めませんでした。もう少し単純な式にしてください。',[hi_id2tango(group.VarID)]);
    // あとは通常処理に戻る
    mv := p;
    Result := True;
  end;

begin
  //todo 2:＠単語の読み取り
  Result := True;
  linkType := svLinkGlobal;
  //-------------------------------
  // グループで新しい変数の宣言か？
  if FReadFlag.CanLet then
  begin
    if _newGroupVar then
    begin
      Result := False; Exit;
    end;
  end;
  //-------------------------------
  // 変数かどうか確認する
  //-------------------------------
  // 優先度の順位(ローカル変数→Groupメンバ→グローバル)

  // その？これ？
  if (token.TokenID = token_sono)or(token.TokenID = token_kore) then
  begin
    if SonoTokenID = DWORD(-1) then raise HException.Create('『その』『これ』の値が設定されていません。');
    token.TokenID := SonoTokenID;
  end;

  // ローカル変数か？
  pv := HiSystem.LocalScope.FindVar(token.TokenID);
  if pv <> nil then linkType := svLinkLocal;

  // Groupメンバか？
  if pv = nil then
  begin
    pv := HiSystem.GroupScope.FindMember(token.TokenID);
    if pv <> nil then linkType := svLinkVirtualGroupMember;
  end;

  // グローバル変数か？
  if pv = nil then
  begin
    // ネームスペースを考慮する
    if (token.NextToken <> nil) and (token.NextToken.TokenID = token_Colon) then
    begin
      ns := hi_id2fileno(token.TokenID);
      if token.Token <> 'グローバル' then
      begin
        token := token.NextToken; // skip NAME
        token := token.NextToken; // skip ':'
        pv := HiSystem.Namespace.GetVarNamespace(ns, token.TokenID);
      end else begin
        token := token.NextToken; // skip NAME
        token := token.NextToken; // skip ':'
        pv := HiSystem.Namespace.GetVarNamespace(ns, token.TokenID);
        if pv = nil then pv := HiSystem.Namespace.GetVar(token.TokenID);
      end;
    end else begin
      pv := HiSystem.Namespace.GetVar(token.TokenID);
      pv := hi_getLink(pv);
    end;
    if pv <> nil then linkType := svLinkGlobal;
  end;

  // もし未知なる単語ならば単語として登録する
  if pv = nil then
  begin
    // 『変数宣言が必要』 ならエラーに。
    if HiSystem.FlagStrict then raise HException.CreateFmt(ERR_S_STRICT_UNDEF,[hi_id2tango(token.TokenID)]);
    // 『変数初期化が必要』なら代入文でなければエラーに。
    if HiSystem.FlagVarInit then
    begin
      if (token.JosiID <> josi_wa)and((token.NextToken = nil)or(token.NextToken.TokenID <> token_Eq)) then raise HException.CreateFmt(ERR_S_VARINIT_UNDEF,[hi_id2tango(token.TokenID)]);
    end;
    // 変数の登録(Globalとして)
    pv := HiSystem.CreateHiValue(token.TokenID);
    // 変数の初期値は変数名とする。これにより、「」で囲わない文字列でも多少やりすごせる。
    hi_setStr(pv, token.Token);
    linkType := svLinkGlobal;
  end;

  // 文脈からグループの自動生成かどうかを調べる（この処理には時間がかかるが必要）
  if FReadFlag.CanLet then
  begin
    _CheckGroupAutoCreate(pv);
  end;
  
  //------------------------------------
  // pv は関数か？
  //------------------------------------
  if pv.VType = varFunc then
  begin
    if linkType = svLinkVirtualGroupMember then
    begin
      funcLink.LinkType  := sfLinkVirtuaLink;
      funcLink.LinkValue := nil;
      ReadFunction(token, pv, funcLink);
    end else
    begin
      funcLink.LinkType  := sfLinkDirect;
      funcLink.LinkValue := nil;
      ReadFunction(token, pv, funcLink);
    end;
    Exit;
  end;

  //------------------------------------
  // pv は変数だったということで話は進む
  //------------------------------------
  node := TSyntaxValue.Create(nil);
  node.VarID := pv.VarID;
  node.DebugInfo := token.DebugInfo;
  node.JosiId := token.JosiID;
  TokenNextToken(token); // skip VAR_NAME
  node.ReadOnly := (pv.ReadOnly <> 0); // 0 でなければ読み取り専用
  // Global or Local
  case linkType of
    svLinkGlobal:
    begin
      node.Element.LinkType := svLinkGlobal;
      node.Element.VarLink  := pv; // グローバル変数をそのまま登録
    end;
    svLinkLocal:
    begin
      node.Element.LinkType := svLinkLocal;
    end;
    svLinkVirtualGroupMember:
    begin
      node.Element.LinkType := svLinkVirtualGroupMember;
    end;
  end;//of CASE

  pElement := nil;
  pTop := node.Element;

  if node.JosiId <> josi_nituite then
  //---------------------------------------------------
  // その他の要素（配列・メンバ）があるかどうか調べる
  //---------------------------------------------------
  while token <> nil do
  begin
    tmp := token;
    // commaを超えるか
    if node.JosiId > 0 then
    begin
      TokenSkipComma(token);
    end;
    case token.TokenID of
      //------------------------------------------------------------------------
      // 配列へのリンク
      token_kaku_kakko_begin:
      begin
        TokenNextToken(token); // skip "["
        //要素を複数読む
        while token <> nil do
        begin
          // ']'ならば、抜ける
          if token.TokenID = token_kaku_kakko_end then Break;

          // 一要素得る
          while token <> nil do
          begin
            // ']'ならば、抜ける
            if token.TokenID = token_kaku_kakko_end then Break;
            // ','ならば、抜ける
            if token.TokenID = token_comma then
            begin
              token := token.NextToken;
              Break;
            end;
            // カッコの中を読む
            if not ReadOneItem(token) then raise HException.CreateFmt(ERR_S_VAR_ELEMENT,[hi_id2tango(pv.VarID)]);
            while (token<>nil)and(token.TokenType = tokenOperator) do
            begin
              ReadOneItem(token);
            end;
          end;
          // 取得した要素をnodeに追加する
          pe := NewPe; //New(pe);
          pe.LinkType := svLinkArray;
          // 読んだ値をスタックから下ろしインデックスとする
          pe.aryIndex := FStack.Pop;
          NextElementLink(pe);
        end;
        // 終端のカッコをチェック
        if (token = nil)or(token.TokenID <> token_kaku_kakko_end) then raise HException.Create(ERR_NOPAIR_KAKU);
        node.JosiId := token.JosiId;  // "]"xx
        token := token.NextToken;     // skip "]"
        Continue;
      end;
      //-----------------------------------------
      // 配列２へのリンク
      token_yen:
      begin
        TokenNextToken(token);// skip "\"
        pe := NewPe; //New(pe);
        pe.LinkType := svLinkArray;
        // 要素を読む
        if not ReadOneItem(token) then raise HException.CreateFmt(ERR_S_VAR_ELEMENT,[hi_id2tango(pv.VarID)]);
        // 読んだ値をスタックから下ろしインデックスとする
        pe.aryIndex := FStack.Pop;
        node.JosiId := pe.aryIndex.JosiId;
        lastJosi := node.JosiId;
        NextElementLink(pe);
        //--------------------------
        // 次の要素があるか
        if lastJosi <> josi_wa then
        while(token <> nil)do
        begin
          if token.TokenID <> token_comma then Break;
          TokenNextToken(token);// skip ","
          pe := NewPe; //New(pe);
          pe.LinkType := svLinkArray;
          // 要素を読む
          if not ReadOneItem(token) then raise HException.CreateFmt(ERR_S_VAR_ELEMENT,[hi_id2tango(pv.VarID)]);
          // 読んだ値をスタックから下ろしインデックスとする
          pe.aryIndex := FStack.Pop;
          node.JosiId := pe.aryIndex.JosiId;
          NextElementLink(pe);
        end;
        Continue;
      end;
      //------------------------------------------------------------------------
      // ハッシュへのリンク
      token_mark_at:
      begin
        token := token.NextToken; // skip @
        pe := NewPe; //New(pe);
        pe.LinkType := svLinkHash;
        // ハッシュのメンバ名を１つ読む
        if not ReadOneItem(token) then raise HException.CreateFmt(ERR_S_VAR_ELEMENT,[hi_id2tango(pv.VarID)]);
        // 読んだ値をスタックから下ろしメンバ名とする
        pe.aryIndex := FStack.Pop;
        node.JosiId := pe.aryIndex.JosiId;
        NextElementLink(pe);
        Continue;
      end;
      //------------------------------------------------------------------------
      // → 強制グループ
      token_right: 
      begin
        token := token.NextToken; // skip →
        if token = nil then raise HException.Create('グループへのアクセス子"→"があるがメンバ名がありません。');
        if pTop <> nil then
        begin
          pTop.LinkType := svLinkLocal;
          pTop.VarLink  := nil;
          pTop := nil;
        end;
        pe := NewPe; //New(pe);
        pe.LinkType := svLinkGroup;
        pe.groupMember := token.TokenID;
        node.JosiId := token.JosiId;
        NextElementLink(pe);
        token := token.NextToken; // skip "メンバ"
        //----------------------------------------------------------------------
        // 引数付の関数?だった場合
        if (token <> nil) and (node.JosiID <> josi_wa) and (token.TokenID = token_kakko_begin) then
        begin
          pe.Stack := THObjectList.Create;
          token := token.NextToken; // skip '('
          while token <> nil do
          begin
            if token.TokenID = token_kakko_end then Break;
            if not ReadOneItem(token) then raise HException.CreateFmt(ERR_S_VAR_ELEMENT,[hi_id2tango(pv.VarID)]);
            pe.Stack.Add(FStack.Pop);
            if (token <> nil) and (token.TokenID = token_comma) then Continue;
          end;
          if (token = nil)or(token.TokenID <> token_kakko_end) then raise HException.CreateFmt(ERR_NOPAIR_KAKKO,[]);
          token := token.NextToken; // skip ')'
        end;
        //----------------------------------------------------------------------
        Continue;
      end;
      //------------------------------------------------------------------------
      // 配列でもハッシュでもない時
      else
      begin
        //----------------------------------------------------------------------
        // グループなのか?
        if pv.VType = varGroup then
        begin
          // グループ要素の読み込み
          mv := hi_group(pv).FindMember(token.TokenID);
          if mv = nil then
          begin
            // 暗黙のグループメンバ定義をするかどうか？
            if (token.JosiID = josi_wa) or ((token.NextToken <> nil)and(token.NextToken.TokenID = token_eq)) then
            begin
              if HiSystem.FlagStrict then raise HException.CreateFmt(ERR_S_STRICT_UNDEF,[hi_id2tango(token.TokenID)]);
              mv := hi_var_new;
              mv.VarID := token.TokenID;
              hi_group(pv).Add(mv);
            end else
            begin
              //『(グループ名)で(引数)を(引数)に(メソッド名)する』かどうか？
              if _checkBeyondMethod(pv) = False then
              begin
                // node を積んで抜ける
                FStack.Push(node);
                Exit; // メンバの続きが無い時は、抜ける
              end;
            end;
          end;
          //グループメンバを見つけた場合
          node.JosiId := token.JosiID;
          TokenNextToken(token);// skip 'NAME'
          { // 代入時に参照を変更するようにした
          // "その"への参照変更
          SonoTokenID := pv.VarID;
          }
          //
          pe := NewPe; //New(pe);
          pe.LinkType    := svLinkGroup;
          pe.groupMember := mv.VarID; // グループにアクセスするときは必ず動的
          NextElementLink(pe);
          if mv.VType = varFunc then
          begin
            // グループ内関数
            funcLink.LinkType  := sfLinkGroupMember;
            funcLink.LinkValue := node;
            ReadFunction(token, mv, funcLink);
            Exit;
          end;
          pv := mv;
          if (node.JosiId = josi_nituite)or(node.JosiId = josi_wa) then Break;
          Continue;
        end else
        // グループではない場合
        begin
          token := tmp;
          Break;
        end;
      end;
    end;//of case token.TokenID
  end;

  // 最後に、FStack へ変数を登録する
  FStack.Push(node);
end;

function THiParser.ReadToNaraba(var token: THimaToken): Boolean;
var
  A, B: TSyntaxNode;
  n: TSyntaxNode;
  c: THimaToken;
begin
  Result := False;
  StackPush;
  c := token; if c = nil then Exit;
  FReadFlag.CanLet := False;
  while token <> nil do
  begin
    // 条件を１つ読む
    if not ReadOneItem(token) then raise HException.Create('『もし』の条件が読み取れませんでした。');
    if (token <> nil) and (token.TokenType = tokenOperator) then
    begin
      if not ReadOneItem(token) then raise HException.Create('『もし』の条件が読み取れませんでした。');
    end;

    A := FStack.GetLast;

    // ...ならばなら抜ける
    if (A.JosiId = josi_naraba)or(A.JosiId = josi_denakereba) then Break;

    // A が B ... のとき
    if (A.JosiId = josi_ga) then
    begin
      if not ReadOneItem(token) then Exit;
      B := FStack.GetLast;
      // ならば
      if (B.JosiId = josi_naraba)or(B.JosiId = josi_denakereba) then
      begin
        //『もし(Aが存在する)ならば』の時は抜ける
        if FStack.Count = 1 then Break;

        // = を作る
        n := TSyntaxEnzansi.Create(nil);
        n.DebugInfo := B.DebugInfo;
        TSyntaxEnzansi(n).ID := token_Eq;
        setPriority(n);
        B := FStack.Pop;
        FStack.Push(n); // =
        FStack.Push(B); // 要素
        Break;
      end else
      // 『A が B ||...』の時
      if ( (token.TokenID = token_or)or(token.TokenID = token_and) ) then
      begin
        // A & B
        n := TSyntaxEnzansi.Create(nil);
        n.DebugInfo := B.DebugInfo;
        TSyntaxEnzansi(n).ID := token_Eq;
        setPriority(n);
        B := FStack.Pop;
        A := FStack.Pop;
        FStack.Push(A); // 要素A
        FStack.Push(n); // =
        FStack.Push(B); // 要素B
        // || * &&
        n := TSyntaxEnzansi.Create(nil);
        n.DebugInfo := B.DebugInfo;
        TSyntaxEnzansi(n).ID := token.TokenID;
        setPriority(n);
        FStack.Push(n);
        TokenNextToken(token);
      end;
    end;
  end;
  // チェック
  A := FStack.GetLast;
  if (A.JosiId <> josi_naraba)and(A.JosiID <> josi_denakereba) then
  begin
    raise HException.Create(ERR_SYNTAX + '『もし...ならば』の書式に誤りがあるか式が複雑すぎます。');
  end;

  // スタックを中間記法から逆ポーランドに並び替え
  if FStack.Count > 0 then infix2rpolish(FStack);

  // スタックをTSyntaxCalcに乗せる
  B := TSyntaxCalc.Create(nil);
  B.DebugInfo := A.DebugInfo;
  StackToNodeChild(FStack, B);
  B.JosiId := A.JosiId;

  // スタックを戻す
  StackPop;

  // TSyntaxCalcをスタックに乗せる
  FStack.Add(B);
  FReadFlag.CanLet := True;

  // ...
  Result := ReadIf(token, c.Indent);
end;

function THiParser.ReadTryExcept(var token: THimaToken; defIndent: Integer): Boolean;
var
  node: TSyntaxTryExcept;
  n: TSyntaxNode;
begin
  node := TSyntaxTryExcept.Create(nil);
  node.FlagLive := True;

  node.DebugInfo := token.DebugInfo;
  TokenNextToken(token);// skip "エラー監視"

  //監視文を得る
  node.NodeTry := TSyntaxSentence.Create(node);
  node.DebugInfo := node.DebugInfo;
  n := node.NodeTry.Children;
  StackPush;
  try
    ReadSyntaxBlock(token, n, defIndent);
  except on e: Exception do
    raise Exception.Create('『エラー監視』構文の監視ブロックでエラー。' + e.Message);
  end;
  {
  if token = nil then
  begin
    NextBlock(token);
    if (token<>nil)and(defIndent < token.Indent) then
      ReadBlocks(token, n);
  end else
  begin
    //ReadSentence(token, n);
    ReadLine(token, n);
  end;
  }
  StackPop;

  if token = nil then NextBlock(token);
  if (token = nil)or(token.TokenID <> token_err)or(token.JosiID <> josi_naraba) then raise HException.Create(ERR_SYNTAX + '『エラー監視～エラーならば～』の書式で指定してください。');

  //エラートラップ部分を得る
  node.NodeExcept := TSyntaxSentence.Create(node);
  node.DebugInfo := token.DebugInfo;
  token := token.NextToken; // SKIP "エラーならば"
  n := node.NodeExcept.Children;
  StackPush;
  try
    ReadSyntaxBlock(token, n, defIndent);
  except on e: Exception do
    raise Exception.Create('『エラー監視』構文のエラーブロックでエラー。' + e.Message);
  end;
  {
  if token = nil then
  begin
    NextBlock(token);
    if (token<>nil)and(defIndent < token.Indent) then
      ReadBlocks(token, n);
  end else
  begin
    //ReadSentence(token, n);
    ReadLine(token, n);
  end;
  }
  StackPop;

  FStack.Push(node);
  Result := True;
end;

function THiParser.ReadWhile(var token: THimaToken; defIndent: Integer): Boolean;
var
  n: TSyntaxNode;
  node: TSyntaxWhile;
begin
  if FStack.Count = 0 then raise HException.Create(ERR_SYNTAX+'『(条件)の間～』の書式で指定してください。');

  node := TSyntaxWhile.Create(nil);
  node.Jouken := FStack.pop;
  node.DebugInfo := node.Jouken.DebugInfo;
  node.FlagLive := True;
  n := node.Children;
  FStack.Push(node);

  token := token.NextToken; // skip '間'

  StackPush;
  try
    // While ループする文を取得
    ReadSyntaxBlock(token, n, defIndent);
    {
    if token = nil then
    begin
      NextBlock(token);
      if (token <> nil) and (token.Indent > defIndent) then
      begin
        ReadBlocks(token, n);
      end;
    end else
    begin
      ReadLineEx(token, n);
    end;
    }
  except on e: Exception do
    raise Exception.Create('『(条件)の間』構文でエラー。' + e.Message);
  end;
  StackPop;
  Result := True;
end;

function THiParser.SkipDefFunction(var token: THimaToken): Boolean;
var
  defIndent: Integer;
begin
  defIndent := token.Indent;
  token     := token.CheckNextBlock;
  while token <> nil do
  begin
    //*abc    ... (0) defIndent
    //   ddd  ... (3) token.Indent
    if token.TokenID = token_mark_nakaten then
    begin
      token := token.CheckNextBlock; Continue;
    end;
    if defIndent >= token.Indent then Break;
    token := token.CheckNextBlock;
  end;
  Result := True;
end;

procedure THiParser.StackPop;
begin
  FreeAndNil(FStack);
  FStack := FStackStack.Pop;
end;

procedure THiParser.StackPush;
begin
  // FStack の値を退避する
  FStackStack.Push(FStack);
  FStack := THStack.Create;
  FPrevToken := nil;

  if FStackStack.Count > MAX_STACK_COUNT then raise HException.Create(ERR_STACK_OVERFLOW);
end;

procedure THiParser.StackToNode(var cnode: TSyntaxnode);
var
  i: Integer;
  n: TSyntaxNode;
begin
  for i := 0 to FStack.Count - 1 do
  begin
    n := FStack.Items[i];
    cnode.Next := n;
    cnode := n;
  end;
  cnode.Next := nil;
  FStack.Clear;
end;

procedure THiParser.StackToNodeChild(stack: THStack; node: TSyntaxNode);
var
  n, nn: TSyntaxNode;
  i: Integer;
begin
  // 構造化のためのレベルを取得

  // node.Children にSyntaxNodeを追加していく
  n := nil;
  for i := 0 to stack.Count - 1 do
  begin
    nn := stack.Get(i);
    if (n = nil) then begin
      node.Children := nn;
      n := nn;
    end else begin
      n.Next := nn;
      n := nn;
    end;
    n.Parent  := node;
    n.Next    := nil;
    // FOR DEBUG
    //writeln('| ',n.DebugStr);
  end;
  //writeln('---');
end;

procedure THiParser.getArgType(var token: THimaToken; v: PHiValue; var argNeeded: Boolean; var argByRef: Boolean);
var
  g: PHiValue;
  vType: THiVType;
  ByRef: -1..1;//-1で値渡し、1で参照渡し
begin
  if token.TokenID <> token_nami_kakko_begin then Exit;
  argNeeded := True;
  argByRef  := False;
  vType     := varNil;
  ByRef     := 0;

  // skip '{'
  token := token.NextToken;

  while token <> nil do
  begin
    if token.TokenID = token_nami_kakko_end then Break;
    if token.TokenID = token_Eq then
    begin
      // skip '='
      token := token.NextToken;
      argNeeded := False;
      // 初期値
      if token.TokenID  = token_question then
      begin
        // ？＝nil
      end else
      if token.TokenType = tokenNumber then
      begin
        hi_setIntOrFloat(v, token.NumberToken);
        if vType = varNil then vType := v.VType;
      end else
      // (ex) =-1
      if (token.NextToken <> nil) and
         (token.TokenType = tokenOperator) and
         (token.TokenID   = token_minus) and
         (token.NextToken.TokenType = tokenNumber)
      then
      begin
        token := token.NextToken;
        hi_setIntOrFloat(v, token.NumberToken * -1);
        if vType = varNil then vType := v.VType;
      end else
      begin
        hi_setStr(v, token.GetConstStr); // ***
        if vType = varNil then vType := v.VType;
      end;
      token := token.NextToken;
    end else
    begin
      case token.TokenID of
      token_mojiretu: vType := varStr;
      token_seisu:    vType := varInt;
      token_suuti,
      token_jissuu:   vType := varFloat;
      token_hairetu:  begin vType := varArray; argByRef := true;end;
      token_hash:     begin vType := varHash;  argByRef := true;end;
      token_group:    begin vType := varGroup; argByRef := true;end;
      token_ByRef:    ByRef := 1 ;
      token_ByVal:    ByRef := -1;
      token_event:;
      token_private:;
      else
        begin
          // グループか？
          g := HiSystem.Namespace.GetVar(token.TokenID);
          g := hi_getLink(g);
          if (g = nil) or (g.VType <> varGroup) then raise HException.CreateFmt(ERR_S_UNDEFINED,[hi_id2tango(token.TokenID)]);
          hi_group_create(v);
          hi_group(v).Assign(hi_group(g));
          argByRef := true;
        end;
      end;

      token := token.NextToken; // SKIP TYPE
    end;
  end;

  //参照渡しか、値渡しか？
  if ByRef = 1 then
    argByRef := true
  else if ByRef = -1 then
    argByRef := false;

  // 型を決定
  if vType <> varNil then
  begin
    hi_var_ChangeType(v, vType);
  end;

  if token.TokenID <> token_nami_kakko_end then raise HException.Create(ERR_NOPAIR_NAMI);
  token := token.NextToken; // SKIP '}'
end;

procedure THiParser.getDefArgs(var token: THimaToken; args: THimaArgs);

  procedure _read_arg;
  var
    arg: THimaArg;
  begin
    //-------------------------------------
    // *関数名({修飾}引数名＋助詞,引数名＋助詞...)
    //-------------------------------------
    arg := THimaArg.Create;
    arg.Needed  := True;

    // 変数の修飾があるか？
    if token.TokenID = token_nami_kakko_begin then // '{'
    begin
      // 装飾
      try
        getArgType(token, arg.Value, arg.Needed, arg.ByRef);
        arg.VType := arg.Value.VType;
      except
        on e:Exception do
        begin
          raise Exception.Create('関数の引数の装飾定義でエラー:'+e.Message);
        end;
      end;
    end;
    // 変数名
    arg.Name := token.TokenID;
    arg.JosiList.AddNum( token.JosiID );
    token := token.NextToken;
    Args.Add_JosiCheck(arg);
    // ','
    if (token <> nil) and (token.TokenID = token_comma) then token := token.NextToken;
  end;

  procedure _def_args;
  var
    tmp: AnsiString;
  begin
    FPrevToken := token;
    token := token.NextToken; // SKIP '('
    // トークンを１つずつ調べていく
    while token <> nil do
    begin
      if token.TokenID = token_vLine then // '|'
      begin
        token := token.NextToken;
      end else
      begin
        if token.TokenID = token_kakko_end then Break;
        tmp := token.Token;
        try
          _read_arg;
        except
          raise HException.CreateFmt('関数の引数「%s」にエラーがあります。', [tmp]);
        end;
      end;
    end;
    if token.TokenID <> token_kakko_end then raise HException.Create(ERR_NOPAIR_KAKKO);

    FPrevToken := token;
    token := token.NextToken; // SKIP ')'
  end;

begin
  if token.TokenID <> token_kakko_begin then Exit;
  try
    _def_args;
  except on e:Exception do
    begin
      raise Exception.Create('関数の引数定義にエラーがあります。' + e.Message);
    end;
  end;
end;

procedure THiParser.RegistVar(var token: THimaToken; IsPreprocess: Boolean; ReadOnly: Boolean);
var
  fp, v, g, con,vv: PHiValue;
  node: TSyntaxCreateVar;
  sf: TSyntaxFunction; sv: TSyntaxValue;
  n: TSyntaxNode;
  josiId: Integer;
  IsGlobal: Boolean;
begin
  //todo 2: ■とは＝変数の登録
  //-------------------------------
  // こことは別に ReadTango の中にも__とは__の構文があるので注意
  // 後で統一できるとベスト

  // 変数の生成
  // グローバルでの宣言
  if (not HiSystem.LocalScope.HasLocal)or(IsPreprocess) then
  begin
    IsGlobal := True;
    // カレントネームスペースを確認する
    // v := HiSystem.Namespace.GetVar(token.TokenID); // --- 既存の変数があるか？
    v := HiSystem.Namespace.CurSpace.GetVar(token.TokenID);
    if v = nil then
    begin
      // 変数の生成
      v := hi_var_new;
      v.Designer := HiSystem.FlagSystem;
      v.VarID := token.TokenID;
      if HiSystem.Global.GetVar(v.VarID) <> nil then
      begin
        if (v.ReadOnly = 1) then
        begin
          raise HException.CreateFmt('変数の宣言で「%s」は既に定数として宣言されているので使えません。',[hi_id2tango(v.VarID)]);
        end else
        begin
          hi_var_free(v);
          v := HiSystem.Global.GetVar(token.TokenID);
        end;
      end else
      begin
        HiSystem.Global.RegistVar(v);
      end;
    end;
    node := nil;
  end else
  // ローカルでの宣言
  begin
    IsGlobal := False;
    // 変数の生成
    v := hi_var_new;
    v.Designer := HiSystem.FlagSystem;
    v.VarID := token.TokenID;
    //
    HiSystem.Local.RegistVar(v);
    node := TSyntaxCreateVar.Create(nil);
    FStack.Add(node);
    node.DebugInfo := token.DebugInfo;
  end;

  // 名前を飛ばす
  josiId := token.JosiID;
  token  := token.NextToken;
  if (token = nil) then raise HException.CreateFmt(ERR_S_DEF_VAR,[hi_id2tango(v.VarID)]);
  if token.TokenID = token_comma then token := token.NextToken;

  // タイプの取得
  if josiId <> josi_wa then
  begin
    case token.TokenID of
      token_mojiretu:   hi_setStr   (v,'');
      token_suuti,
      token_jissuu:     hi_setFloat (v, 0);
      token_seisu:      hi_setInt   (v, 0);
      token_hensuu:;
      token_hash:       hi_hash_create(v);
      token_hairetu:    hi_ary_create(v);
      token_Eq:;
      token_group:      hi_group_create(v);
      else
      begin
        // グループか既存の変数か何か
        g := HiSystem.Namespace.GetVar(token.TokenID);
        g := hi_getLink(g);
        if g = nil then raise HException.CreateFmt(ERR_S_UNDEFINED,[ hi_id2tango(token.tokenID) ]);

        if g.VType = varGroup then
        begin
          if v.VType <> varGroup then
          begin
            hi_var_copyData(g, v); // 内容を丸ごとコピー
            hi_group_create(v);
          end else
          begin
            hi_group(v).AddMembers(hi_group(g));
          end;
          hi_group(v).HiClassInstanceID := v.VarID;
          hi_group(v).HiClassDebug      := hi_id2tango(v.VarID); // FOR DEBUG
          hi_setStr(hi_group(v).FindMember(token_name),hi_id2tango(v.VarID)); // インスタンス名をセット
          //参照
          SonoTokenID := v.VarID;
          // コンストラクターの起動
          if IsPreprocess = False then
          begin
            con := hi_group(v).FindMember(token_tukuru);
            if (con <> nil)and(con.VType = varFunc) then
            begin
              sf := TSyntaxFunction.Create(nil);
              sf.FDebugFuncName := '作';
              sf.DebugInfo := token.DebugInfo;
              sf.FuncID := token_tukuru; // 作る
              sf.HiFunc := hi_func(con);
              sf.Link.LinkType  := sfLinkGroupMember;
              sv := TSyntaxValue.Create(nil);
              sv.VarID := v.VarID;
              if node = nil then begin // is GLOBAL
                sv.Element.LinkType := svLinkGlobal;
                sv.Element.VarLink := v;
              end else begin
                sv.Element.LinkType := svLinkLocal;
              end;
              sv.Element.NextElement := TSyntaxValueElement.Create;
              sv.Element.NextElement.NextElement := nil;
              sv.Element.NextElement.LinkType := svLinkGroup;
              sv.Element.NextElement.groupMember := token_tukuru;
              sf.Link.LinkValue := sv;
              FStack.Add(sf);
            end;
          end;//of Preprocess = False
        end else
        begin
          hi_var_copyData(g, v); // 内容を丸ごとコピー
        end;//of Group
      end;// of else
    end;//of case
    //
    if (token.TokenID <> token_Eq) then token := token.NextToken; // SKIP VAR_TYPE
  end;//of if

  //!Aとは型 [= 初期値]
  //         ~~~~~~~~~~
  if (token <> nil)and((token.TokenID = token_Eq)or(josiId = josi_wa)) then
  begin
    if token.TokenID = token_eq then token := token.NextToken; // skip "="
    //if (token = nil)or(token.TokenType <> tokenTango) then raise HException.CreateFmt(ERR_S_DEF_VAR,[hi_id2tango(v.VarID)]);

    //--------------------------------------------------------------------------
    // 初期値の取得
    {
    if token.TokenType = tokenNumber then
    begin
      //hi_setIntOrFloat(v, HimaStrToNum(token.Token));
      hi_setIntOrFloat(v, token.TokenNumber);
    end else
    begin
      hi_setStr(v, token.GetConstStr);
    end;
    token := token.NextToken; // skip VALUE
    }

    // 初期値に計算を含んでいてもばっちり計算するように！
    StackPush;
    try
      if ReadOneItem(token) = False then raise HException.Create('変数宣言で初期値がありません。');
      while (token <> nil) do // どんどん読む
      begin
        if (token.TokenID = token_Semicolon) then Break; // セミコロンなら抜ける
        ReadOneItem(token);
      end;
      if FStack.Count > 1 then raise HException.Create('変数宣言で初期化式で値が２つ以上存在します。');
      n := FStack.Pop;
      // グローバルなら、評価してから。ローカルなら構文を乗せる
      if IsGlobal then
      begin
        vv := n.getValue; // 変数名を壊してしまうので必ず vv へ値を得てそのあとコピーしなおす
        if (v.VType <> varNil) and (v.VType <> vv.VType) then
        begin
          hi_var_copyGensiAndCheckType(vv, v);
        end else
        begin
          hi_var_copyGensi(vv, v);
        end;
        if vv.Registered = 0 then hi_var_free(vv);
        FreeAndNil(n);
      end else
      // ローカル変数なので構文を乗せる
      begin
        node.InitNode := n;
      end;
    finally
      StackPop;
    end;
    //--------------------------------------------------------------------------
  end;

  // セッター/ゲッターがあるか？
  // セッター
  if token <> nil then
  if token.TokenID = token_left then
  begin
    token := token.NextToken; // SKIP <-
    if token <> nil then
    begin
      fp := HiSystem.Global.GetVar(token.TokenID);
      if (fp = nil)or(fp.VType <> varFunc) then raise HException.CreateFmt(ERR_S_DEF_VAR+'セッター『%s』の定義がないか関数ではありません。',[hi_id2tango(v.VarID),hi_id2tango(token.TokenID)]);
      v.Setter := fp;
      token := token.NextToken; // SKIP FUNC NAME
    end;
  end;
  // ゲッター
  if token <> nil then
  if token.TokenID = token_right then
  begin
    token := token.NextToken; // SKIP ->
    if token <> nil then
    begin
      fp := HiSystem.Global.GetVar(token.TokenID);
      if (fp = nil)or(fp.VType <> varFunc) then raise HException.CreateFmt(ERR_S_DEF_VAR+'セッター『%s』の定義がないか関数ではありません。',[hi_id2tango(v.VarID),hi_id2tango(token.TokenID)]);
      v.Getter := fp;
      token := token.NextToken; // SKIP FUNC NAME
    end;
  end;

  // 読み取り属性の設定
  if ReadOnly then v.ReadOnly := 1 else v.ReadOnly := 0;

  // ノードのテンプレートとして登録
  if node <> nil then hi_var_copy(v, node.Template);
  if token = nil then NextBlock(token);
end;

function THiParser.ReadOption(var token: THimaToken; IsPreprocess: Boolean; node: TSyntaxNode): Boolean;
begin
  // todo 2:＠実行オプション
  Result := False;
  if token.TokenID <> token_mark_option then Exit;
  token := token.NextToken; // SKIP '!'

  // 変数宣言が必要かどうか
  if token.TokenID = token_hensuu_sengen then
  begin
    token := token.NextToken; // SKIP '変数宣言'
    HiSystem.FlagVarInit := False; // どちらかのオプションしか使えない
    if token = nil then raise HException.Create('『!変数宣言』オプションが不完全です。必要か不要を指定します。');
    case token.TokenID of
      token_hituyou : HiSystem.FlagStrict := True;
      token_huyou   : HiSystem.FlagStrict := False;
      token_system  : HiSystem.FlagSystem := 1;
      token_user    : HiSystem.FlagSystem := 0;
      else raise HException.CreateFmt('『!変数宣言』オプションで'+ERR_S_UNDEF_OPTION+'必要か不要を指定します。',[hi_id2tango(token.TokenID)]);
    end;
    token := token.NextToken; // SKIP '必要'
  end else
  // 変数初期化が必要
  if token.TokenID = token_hensuu_syokika then
  begin
    token := token.NextToken; // SKIP '変数初期化'
    HiSystem.FlagStrict := False; // どちらかのオプションしか使えない
    if token = nil then raise HException.Create('『!変数初期化』オプションが不完全です。必要か不要を指定します。');
    case token.TokenID of
      token_hituyou : HiSystem.FlagVarInit := True;
      token_huyou   : HiSystem.FlagVarInit := False;
      else raise HException.CreateFmt('『!変数初期化』オプションで'+ERR_S_UNDEF_OPTION+'必要か不要を指定します。',[hi_id2tango(token.TokenID)]);
    end;
    token := token.NextToken; // SKIP '必要'
  end else
  // ●●とは●●
  if (token.JosiID = josi_wa)or(token.JosiID = josi_towa)or((token.NextToken <> nil)and(token.NextToken.TokenID = token_Eq)) then
  begin
    if IsPreprocess then RegistVar(token, IsPreprocess, True)
                    else NextBlock(token);
  end else
  // ●●を取り込む
  if (token.NextToken <> nil)and(token.NextToken.TokenID = token_include) then
  begin
    if IsPreprocess then ReadInclude(token, node)
                    else NextBlock(token);
  end else
  // ●●にネームスペース変更
  if (token.NextToken <> nil)and(token.NextToken.TokenID = token_namespace_henkou) then
  begin
    if IsPreprocess then ChangeNamespace(token, node)
                    else ChangeNamespace(token, node);
  end else
  begin
    raise HException.CreateFmt(ERR_S_UNDEF_OPTION,[hi_id2tango(token.TokenID)]);
  end;
  if token = nil then NextBlock(token);

  Result := True;
end;

function THiParser.ReadSwitch(var token: THimaToken): Boolean;
var
  n: TSyntaxNode;
  node: TSyntaxSwitch;
  scase: TSyntaxSwitchCase;
  i, indent, sIndent: Integer;
begin
  Result := True;

  node := TSyntaxSwitch.Create(nil);
  node.DebugInfo := token.DebugInfo;
  node.FlagLive := True;

  indent := token.Indent;
  token := token.NextToken; // skip '条件分岐'

  // 分岐条件の取得
  i := FStack.FindJosi(josi_de);
  if i < 0 then
  begin // 省略された場合(それの値で判別)
    node.Jouken := nil;
  end else
  begin
    node.Jouken := FStack.GetAndDel(i);
  end;

  // 条件の取得
  if (token <> nil)and(token.TokenID = token_semiColon) then token := token.NextToken;
  if token <> nil then raise HException.Create('『条件分岐』構文は単文で記述できません。');
  NextBlock(token);

  // xで条件分岐     (0)
  //    yならば,xxxx (4)
  if (token=nil)or(indent >= token.Indent) then raise HException.Create('『条件分岐』構文ではインデント字下げが必要です。');

  // 選択肢
  sIndent := token.Indent;

  while True do
  begin
    // 条件があるか？
    if (token = nil) or (sIndent <> token.Indent) then Break;
    // その他の条件
    if (sIndent <= token.Indent)and(token.TokenID = token_tagaeba) then
    begin
      token := token.NextToken; // skip '違えば'
      node.ElseNode := TSyntaxSentence.Create(node);
      TSyntaxSentence(node.ElseNode).DebugMemo := '条件分岐の違えば';
      n := node.ElseNode.Children;

      try
        ReadSyntaxBlock(token, n, sIndent);
      except on e: Exception do
        raise Exception.Create('『条件分岐』構文でエラー。'+e.Message);
      end;
      {
      if token = nil then
      begin
        NextBlock(token);
        if sIndent <= token.Indent then ReadBlocks(token, n);
      end else
      begin
        ReadLineEx(token, n);
      end;
      }
    end else
    begin
      if not ReadOneItem(token) then raise HException.Create('『条件分岐』構文のインデントレベルにあるのに条件が読めませんでした。');
      scase := TSyntaxSwitchCase.Create;
      scase.Jouken := FStack.Pop;
      if (scase.Jouken.JosiId <> josi_naraba) then raise HException.Create('『(条件式)で条件分岐。(条件)ならば...』の書式で指定してください。');
      scase.Action.DebugInfo := scase.Jouken.DebugInfo;
      n := scase.Action.Children;
      {
      if token = nil then
      begin
        NextBlock(token);
        if token <> nil then
        begin
          if sIndent <= token.Indent then ReadBlocks(token, n);
        end;
      end else
      begin
        ReadLineEx(token, n);
      end;
      }
      try
        ReadSyntaxBlock(token, n, sIndent);
      except on e: Exception do
        raise Exception.Create('『条件分岐』構文の条件でエラー。'+e.Message);
      end;
      node.CaseNodes.Add(scase);
    end;
    if token = nil then NextBlock(token);
  end;
  FStack.Push(node);
end;

function THiParser.SkipBlock(var token: THimaToken): Boolean;
var
  indent: Integer;
begin
  if token = nil then
  begin
    Result := False;
    Exit;
  end;

  indent := token.Indent;
  while token <> nil do
  begin
    // インデントがブロック以下か？
    if indent <= token.Indent then
    begin
      token := token.NextToken;
      if token = nil then NextBlock(token);
    end else
    begin
      Break;
    end;
  end;
  Result := True;
end;
{
function THiParser.SkipLine(var token: THimaToken): Boolean;
begin
  if token = nil then begin Result := False; Exit; end;
  while token <> nil do token := token.NextToken;
  Result := True;
end;
}
function THiParser.ReadDefFunctionContents(var token: THimaToken): Boolean;
var
  indent: Integer;
  funcNameID: DWORD;
  fp, v, group, localVar: PHiValue;
  node: TSyntaxDefFunction;
  n: TSyntaxNode;
  i: Integer;
  arg: THimaArg;
begin
  Result := False;
  if token = nil then Exit;

  if token.TokenID <> token_mark_function then Exit;
  token := token.NextToken; // skip '*'
  if token = nil then raise HException.CreateFmt(ERR_S_UNDEFINED,['*']);

  //---
  // 関数名
  indent := token.Indent;

  // グループ関数か純粋な関数か判別?
  funcNameID := token.TokenID;
  fp := HiSystem.Namespace.GetVar(funcNameID);
  if (fp = nil) then raise HException.CreateFmt(ERR_S_DEF_FUNC,[hi_id2tango(funcNameID)]);

  //---------------------------
  // 普通の関数の場合
  if fp.VType = varFunc then
  begin
    // 関数名をスキップ
    token := token.NextToken; // skip FUNC_NAME
    // 関数宣言をスキップ
    if (token <> nil) and (token.TokenID = token_kakko_begin) then
    begin
      while token <> nil do
      begin
        if token.TokenID = token_kakko_end then Break;
        token := token.NextToken;
      end;
      if (token <> nil)and(token.TokenID = token_kakko_end) then
      begin
        FPrevToken := token;
        token := token.NextToken;
      end;
    end;
    // ～をスキップ
    if (token <> nil) and (token.TokenID = token_tilde) then token := token.NextToken;
    // ＝ならば次のブロックへ
    if (token <> nil) and (token.TokenID = token_eq) then
      NextBlock(token)
    else // 内容があるか確認
    if token = nil then
    begin
      if (FNextBlock <> nil)and(indent >= FNextBlock.Indent) then
      begin
        NextBlock(token); Exit; // 内容がない
      end;
    end;
    // DLLなら続きを読まない
    if hi_func(fp).FuncType = funcDll then Exit;

    //---
    // 関数内容を読む
    node := hi_func(fp).PFunc;

    HiSystem.PushScope; // ---
    try

      // 引数をローカル変数へ登録
      for i := 0 to node.HiFunc.Args.Count - 1 do
      begin
        arg := node.HiFunc.Args.Items[i];
        v := hi_var_new;
        hi_var_copy(arg.Value, v); // 名前も
        v.VarID := arg.Name;
        HiSystem.Local.RegistVar(v);
      end;

      n := node.Children;
      //
      ReadSyntaxBlock(token, n, indent);
      //ReadBlocks(token, n);
      // 構文木のレベルを設定
      node.SetSyntaxLevel(0);

    finally
      HiSystem.PopScope; // ---
    end;
  end else // 普通の関数の場合.おわり
  //---------------------------
  // グループの場合
  begin
    // 関数メンバを特定する
    group := nil;
    token := token.NextToken;
    while token <> nil do
    begin
      if fp.VType <> varGroup then raise HException.Create('グループ付関数の定義に失敗。');
      group := fp;
      fp := hi_group(fp).FindMember(token.TokenID);
      if (fp = nil) then raise HException.Create('グループ付関数の定義に失敗');
      if fp.VType = varFunc then Break;
      funcNameID := token.TokenID;
      //
      token := token.NextToken;
    end;
    if (group = nil)or(fp = nil)or(fp.VType <> varFunc) then raise HException.Create('グループ付関数の定義に失敗。');

    // 関数名をスキップ
    token := token.NextToken; // skip FUNC_NAME
    // 関数宣言をスキップ
    if (token <> nil) and (token.TokenID = token_kakko_begin) then
    begin
      while token <> nil do
      begin
        if token.TokenID = token_kakko_end then Break;
        token := token.NextToken;
      end;
      if (token <> nil)and(token.TokenID = token_kakko_end) then token := token.NextToken;
    end;
    // ～をスキップ
    if (token <> nil) and (token.TokenID = token_tilde) then token := token.NextToken;
    // ＝ならば次のブロックへ
    if (token <> nil) and (token.TokenID = token_eq) then
      NextBlock(token)
    else // 内容があるか確認
    if token = nil then
    begin
      if (FNextBlock <> nil)and(indent >= FNextBlock.Indent) then
      begin
        NextBlock(token); Exit; // 内容がない
      end;
    end;

    // グループメンバの内容を読む
    node := hi_func(fp).PFunc;
    node.GroupID := funcNameID;

    // ローカルに引数を登録しておく
    HiSystem.GroupScope.PushGroupScope(hi_group(group));
    HiSystem.PushScope;
    try
      // ローカル変数の登録
      for i := 0 to hi_func(fp).Args.Count - 1 do
      begin
        arg := hi_func(fp).Args.Items[i];
        localVar := hi_var_new;
        hi_var_copy(arg.Value, localVar);
        localVar.VarID := arg.Name;
        HiSystem.Local.RegistVar(localVar);
      end;

      n := node.Children;
      ReadSyntaxBlock(token, n, indent);
      //ReadBlocks(token, n);
      // 構文木のレベルを設定
      node.SetSyntaxLevel(0);

    finally
      HiSystem.PopScope;
      HiSystem.GroupScope.PopGroupScope;
    end;

  end;
  Result := True;
end;

procedure THiParser.setPriority(n: TSyntaxNode);
begin
  if n = nil then raise HException.Create('nil');
  if n.ClassType = TSyntaxEnzansi then
  begin
    with TSyntaxEnzansi(n) do begin
      case ID of
      //理論演算
      token_or:     Priority := 10;
      token_and:    Priority := 10;
      //比較
      token_Eq:     Priority := 20;
      token_NotEq:  Priority := 20;
      token_Gt:     Priority := 20;
      token_GtEq:   Priority := 20;
      token_Lt:     Priority := 20;
      token_LtEq:   Priority := 20;
      // SHIFT
      token_ShiftL: Priority := 30;
      token_ShiftR: Priority := 30;
      //足し算引き算
      token_plus:   Priority   := 40;
      token_minus:  Priority   := 40;
      token_plus_str: Priority := 40;
      //積算乗算
      token_mul:    Priority := 50;
      token_div:    Priority := 50;
      token_mod:    Priority := 50;
      //累乗
      token_power:  Priority := 60;
      else raise HException.CreateFmt(ERR_S_SOURCE_DUST,[hi_id2tango(ID)]);
      end;
    end;
  end else
  begin
    n.Priority := MaxInt;
  end;
end;

function THiParser.ReadWith(var token: THimaToken; defIndent: Integer): Boolean;
var
  node: TSyntaxWith;
  n, nc: TSyntaxNode;
  pv: PHiValue;
begin
  n := FStack.Pop;
  node := TSyntaxWith.Create(nil);
  node.FlagLive := True;
  node.DebugInfo := n.DebugInfo;
  node.WithVar   := n;
  nc := node.Children;

  //----------------------------------------------------------------------------
  // with VAR の Var がグループかどうか調べる
  pv := n.GetValueNoGetter(False);
  if pv = nil then raise HException.Create('「●●について」構文では静的なグループを指定する必要があります。');
  if (pv.VType = varLink) then pv := hi_getLink(pv);
  if (pv.VType <> varGroup) then
  begin
    raise HException.Create('『'+hi_id2tango(pv.VarID) + '』はグループではありません。「●●について」構文では静的なグループを指定する必要があります。');
  end;

  //----------------------------------------------------------------------------
  HiSystem.GroupScope.PushGroupScope(hi_group(pv));
  try
    ReadSyntaxBlock(token, nc, defIndent);
    {
    if token = nil then
    begin
      NextBlock(token);
      ReadBlocks(token, nc);
    end else
    begin
      ReadLineEx(token, nc);
    end;
    }
  finally
    HiSystem.GroupScope.PopGroupScope;
  end;
  FStack.Add(node);
  Result := True;
end;

function THiParser.ReadInclude(var token: THimaToken; node: TSyntaxNode): Boolean;
var
  fname: string;
  res: PHiValue;
begin
  fname := string(token.GetConstStr); // <-- FNAME
  token := token.NextToken;   //
  token := token.NextToken;   // <-- '取り込む'
  //
  res := HiSystem.ImportFile(fname, node);
  if (res <> nil) and (res.Registered = 0) then hi_var_free(res);
  Result := True;
end;

function THiParser.Debug: AnsiString;
var
  p: TSyntaxNode;

  function _debug(p: TSyntaxNode): AnsiString;
  var
    s: AnsiString; i: Integer;
  begin
    if p = nil then Exit;

    while p <> nil do
    begin
      // this ptr
      s := AnsiString(Format('%0.3d(%2d)',[p.DebugInfo.LineNo, p.FSyntaxLevel]));
      for i := 0 to p.FSyntaxLevel - 1 do s := s + '  ';
      s := s + p.DebugStr + #13#10;

      // this children
      if p.Children <> nil then
      begin
        s := s + _debug(p.Children);
      end;
      Result := Result + s;
      p := p.Next;
    end;
  end;


begin
  p := FTopNode;
  Result := _debug(p);;
end;
{
procedure THiParser.ReadLineEx(var token: THimaToken;
  var cnode: TSyntaxNode; CanLet: Boolean);
var
  t: THimaToken;
begin
  while token <> nil do
  begin
    t := token;
    ReadLine(token, cnode, CanLet);
    if t = token then Break;
  end;
end;
}
{
function THiParser.IsTokenEnzan(token: THimaToken): Boolean;
begin
  Result := False; if token = nil then Exit;

  if token.TokenType = tokenOperator then
  begin
    if token.TokenID = token_Eq then Exit; // 代入だから除外
    Result := True;
  end;
end;
}

procedure THiParser.TokenNextToken(var token: THimaToken);
begin
  if token <> nil then
  begin
    token := token.NextToken;
  end;
end;

procedure THiParser.TokenSkipComma(var token: THimaToken);
begin
  if (token <> nil) and (token.TokenID = token_comma) then
  begin
    token := token.NextToken;
  end;
end;

procedure THiParser.ReadSyntaxBlock(var token: THimaToken;
  var cnode: TSyntaxNode; defIndent: Integer);
var
  thisBlock: THimaBlock;
  tmpToken: THimaToken;
begin
  if token = nil then
  begin
    NextBlock(token);
    if (token <> nil) and (token.Indent > defIndent) then
    begin
      ReadBlocks(token, cnode);
    end;
  end else
  begin
    //1) もし条件ならば, xxxx
    //2)    xxx
    //3)    xxx
    //--------------------
    // (1)を読む
    thisBlock := token.Parent;
    while token <> nil do
    begin
      // ブロックが同じなら行末まで読む
      if token.Parent = thisBlock then
      begin
        tmpToken := token;
        if token.TokenID = token_tagaeba then Break; // '違えば'なら抜け
        //
        ReadLine(token, cnode);
        //
        if tmpToken = token then
        begin
          token := token.NextToken;
        end;
      end else
        Break;
    end;
    if token = nil then NextBlock(token);
    if token = nil then Exit;
    //--------------------
    if (token <> nil) and (token.Indent > defIndent) then
    begin
      ReadBlocks(token, cnode);
    end;
  end;
end;

{
function THiParser.ReadDefFunctionContentsSkip(
  var token: THimaToken): Boolean;
begin
  // ---
  // 名前をスキップ
  NextBlock(token);
  // ---
  // コンテンツがあるか
  if token <> nil then
  begin
    NextBlock(token);
  end;
  Result := True;
end;
}

procedure THiParser.ChangeNamespace(var token: THimaToken; node: TSyntaxNode);
var
  str: AnsiString; id: DWORD;
  scope: THiScope;
begin
  str   := token.GetConstStr; // <-- FNAME
  token := token.NextToken;   //
  token := token.NextToken;   // <-- 'ネームスペース変更'
  id    := hi_tango2id(str);
  //
  scope := HiSystem.Namespace.FindSpace(id);
  if scope = nil then
  begin
    scope := THiScope.Create;
    scope.ScopeID := id;
    HiSystem.Namespace.Add(scope);
  end;
  HiSystem.Namespace.CurSpace := scope;
end;

function THiParser.ReadDefJumpPoint(var token: THimaToken): Boolean;
var
  jump_name: DWORD;
  node: TSyntaxJumpPoint;
begin
  // skip ▲
  if token.TokenID = token_mark_sankaku then
  begin
    TokenNextToken(token);
    if token = nil then raise HException.CreateFmt(ERR_S_SYNTAX,['▲']);
  end;
  // get name
  jump_name := token.TokenID;
  if token.NextToken = nil then
  begin
    NextBlock(token);
  end else
  begin
    TokenNextToken(token);
  end;

  // regist token
  node := TSyntaxJumpPoint.Create(nil);
  node.NameId := jump_name;
  if FStack.GetLast <> nil then
  begin
    node.Parent := FStack.GetLast.Parent;
  end;
  // add jump point
  FStack.Add(node);
  Result := True;
end;

{ THStack }

function THStack.FindJosi(key: Integer): Integer;
var
  i: Integer;
  p: TSyntaxNode;
begin
  Result := -1;
  for i := Count - 1 downto 0 do
  begin
    p := Items[i];
    if p.JosiId = key then
    begin
      Result := i; Break;
    end;
  end;
end;

function THStack.Get(Index: Integer): TSyntaxNode;
begin
  Result := Items[Index];
end;

function THStack.GetAndDel(Index: Integer): TSyntaxNode;
begin
  Result := Get(Index);
  Self.Delete(Index);
end;

function THStack.GetLast: TSyntaxNode;
begin
  if Count > 0 then
    Result := Items[Count-1]
  else
    Result := nil;
end;

function THStack.Pop(JosiID: Integer): TSyntaxNode;
var
  i: Integer;
  p: TSyntaxNode;
begin
  Result := nil;
  if Count <= 0 then Exit;

  if JosiID = 0 then
  begin
    Result := inherited Pop;
    Exit;
  end;

  for i := Count - 1 downto 0 do
  begin
    p := Items[i];
    if p.JosiId = JosiID then
    begin
      Result := Items[i];
      Self.Delete(i);
      Break;
    end;
  end;

end;

function THStack.Push(node: TSyntaxNode): Integer;
begin
  Result := inherited Add(node);
end;

{ TSyntaxConst }

constructor TSyntaxConst.Create(FParent: TSyntaxNode);
begin
  inherited;
  constValue := hi_var_new;
  constValue.Registered := 1;
end;

function TSyntaxConst.DebugStr: AnsiString;
begin
  Result := '(定数)' + hi_str(constValue);
end;

destructor TSyntaxConst.Destroy;
begin
  hi_var_free(constValue);
  inherited;
end;

function TSyntaxConst.getValue: PHiValue;
begin
  hi_var_copy(constValue, NodeResult);

  // 文字列なら展開
  if NodeResult.VType = varStr then
  begin
    hi_setStr(
      NodeResult,
      HiSystem.ExpandStr(
        hi_str(NodeResult)
      )
    );
  end;

  Result := NodeResult;
end;

function TSyntaxConst.outLuaProgram: AnsiString;
begin
  raise HException.Create('TSyntaxConst.outLuaProgram');
end;

function TSyntaxConst.outNadesikoProgram: AnsiString;
begin
  case constValue.VType of
  varStr, varInt, varFloat:
    begin
      Result := hi_str(constValue);
    end;
  varArray, varHash:
    begin
      Result := '『' + hi_str(constValue) + '』';
    end;
  else
    raise HException.Create('グループ定数を定義できません。');
  end;
end;

{ TSyntaxValue }

procedure TSyntaxValue.CheckGetter(var p: PHiValue);
var
  f: THiFunction; fn: TSyntaxNode;
begin
  if p = nil then Exit;

  // グループのデフォルトを考慮(pがリンクの場合も考慮)
  if hi_getLink(p).VType = varGroup then
  begin
    FGroupScope := hi_group(p);
    if hi_group(p).DefaultValue <> nil then
    begin
      p := hi_group(p).DefaultValue;
    end;
  end;

  //----------------------------------------------------------------------------
  // 変数自体が varFunc イベント or Getter がイベントなら実行
  //----------------------------------------------------------------------------
  if p.VType = varFunc then
  begin
    f := hi_func(p);
  end else
  if p.Getter <> nil then
  begin
    f  := hi_func(p.Getter);
  end else
  begin
    Exit;
  end;

  //----------------------------------------------------------------------------
  //todo: getter
  fn := f.PFunc;
  if FGroupScope <> nil then
  begin
    HiSystem.GroupScope.PushGroupScope(FGroupScope);
    try
      HiSystem.PushScope;
      try
        HiSystem.RunNode2(fn);
        p := hi_var_new;
        hi_var_copyGensi(HiSystem.Sore, p);
      finally
        HiSystem.PopScope;
      end;
    finally
      HiSystem.GroupScope.PopGroupScope;
    end;
  end else
  //----------------------------------------------------------------------------
  begin
    case f.FuncType of
    funcSystem : p := THimaSysFunction(f.PFunc)(nil);
    funcUser   :
      begin
        HiSystem.PushScope;
        HiSystem.RunNode2(fn);
        p := hi_var_new;
        hi_var_copyGensi(HiSystem.Sore, p);
        HiSystem.PopScope;
      end;
    end;
  end;
  //----------------------------------------------------------------------------
end;

constructor TSyntaxValue.Create(FParent: TSyntaxNode);
begin
  inherited Create(FParent);
  Element := TSyntaxValueElement.Create;
  FGroupScope := nil;
end;

function TSyntaxValue.DebugStr: AnsiString;
begin
  Result := '(変数)' + hi_id2tango(VarID);
end;

destructor TSyntaxValue.Destroy;
begin
  // リンク先の開放
  FreeAndNil(Element);
  inherited;
end;

function TSyntaxValue.getValue: PHiValue;
begin
  Result := GetValueNoGetter(False);
  CheckGetter(Result);
end;

function TSyntaxValue.GetValueNoGetter(CanCreate:Boolean): PHiValue;
var
  pe: TSyntaxValueElement;
  s: AnsiString;
  i: Integer;
  group, res: PHiValue;
begin
  //todo 3: ＝変数リンクの取得
  //----------------------------------------------------------------------------
  // 一次取得
  case Element.LinkType of
    svLinkGlobal:             Result := Element.VarLink;
    svLinkLocal:
      begin
        Result := HiSystem.Local.GetVar(VarID);
        if Result = nil then
        begin
          Result := HiSystem.GetVariable(VarID);
        end;
      end;
    svLinkVirtualGroupMember:
      begin
        FGroupScope := HiSystem.GroupScope.TopItem;
        Result := HiSystem.GroupScope.FindMember(VarID);
        if Result = nil then Result := FGroupScope.FindMember(VarID);
      end;
    else raise HException.CreateFmt(ERR_S_RUN_VALUE,[hi_id2tango(VarID)]);
  end;

  pe := Element.NextElement;
  if pe = nil then Exit;

  //----------------------------------------------------------------------------
  // 要素・二次取得
  while pe <> nil do
  begin
    case pe.LinkType of
      svLinkArray:
        begin
          i   := hi_int(pe.aryIndex.getValue); // get index
          res := hi_ary_get(Result, i);        // get value
          if (res=nil)and(CanCreate) then
          begin
            res := hi_var_new;
            hi_ary_set(Result, i, res); //
          end;
          pe := pe.NextElement;
          Result := res;
        end;
      svLinkHash:
        begin
          Result := hi_getLink(Result);
          if Result = nil then Break;
          if Result.VType = varGroup then // グループの動的アクセス
          begin
            s := hi_str(pe.aryIndex.getValue);
            FGroupScope := hi_group(Result);
            if s <> '' then
            begin
              Result := hi_group(Result).FindMember(hi_tango2id(s));
            end;
            if Result = nil then Break;
          end else
          begin
            s   := hi_str(pe.aryIndex.getValue); // s = '' でも値を返す仕様
            res := hi_hash_get(Result, s);
            if (res = nil)and(CanCreate) then
            begin
              res := hi_var_new;
              hi_hash_set(Result, s, res);
            end;
            Result := res;
          end;
          pe := pe.NextElement;
        end;
      svLinkGroup:
        begin
          group := Result;
          //if group = nil then Break;//敢えてエラーを出した方がシンプル
          FGroupScope := hi_group(group);
          Result := hi_group(group).FindMember(pe.groupMember);
          //--- 関数の場合がある
          if pe.Stack <> nil then
          begin
            if Result.VType <> varFunc then raise HException.Create('『'+hi_id2tango(pe.groupMember)+'』は関数ではないのに引数があります。');
            Result := HiSystem.RunGroupMethod(group, Result, pe.Stack);
          end;
          //---
          pe := pe.NextElement;
        end;
      else
        raise HException.Create('リンク切れ');
    end;

    {
    //ゲッターを展開してよいかどうかを判定する
    if pe <> nil then
    begin
      //続きがあればセッターゲッターを展開して値を得る必要がある
      CheckGetter(Result);
    end;
    }
  end;
  //----------------------------------------------------------------------------
end;


function TSyntaxValue.outLuaProgram: AnsiString;
var
  pe: TSyntaxValueElement;
begin
  //todo 3: ＝変数リンクの取得
  //----------------------------------------------------------------------------
  // 一次取得
  Result := SyntaxTab(FSyntaxLevel);
  case Element.LinkType of
    svLinkGlobal:             Result := Result + 'g["' + hi_id2tango(Element.VarLink.VarID)+'"]';
    svLinkLocal:              Result := Result + 'l["' + hi_id2tango(VarID) + '"]';
    svLinkVirtualGroupMember:
      begin
        FGroupScope := HiSystem.GroupScope.TopItem;
        Result := Result + '["' + hi_id2tango(VarID) + '"]';
      end;
    else raise HException.CreateFmt(ERR_S_RUN_VALUE,[hi_id2tango(VarID)]);
  end;

  pe := Element.NextElement;
  if pe = nil then Exit;

  //----------------------------------------------------------------------------
  // 要素・二次取得
  while pe <> nil do
  begin
    case pe.LinkType of
      svLinkArray:
        begin
          Result := Result + '[' + TrimA(pe.aryIndex.outNadesikoProgram) + ']';
          pe := pe.NextElement;
        end;
      svLinkHash:
        begin
          Result := Result + '[' + TrimA(pe.aryIndex.outNadesikoProgram) + ']';
          pe := pe.NextElement;
        end;
      svLinkGroup:
        begin
          Result := Result + '[' + TrimA(hi_id2tango(pe.groupMember)) + ']';
          pe := pe.NextElement;
        end;
      else
        raise HException.Create('リンク切れ');
    end;
  end;
  //----------------------------------------------------------------------------
  Result := Result + #13#10;
end;

function TSyntaxValue.outNadesikoProgram: AnsiString;
var
  pe: TSyntaxValueElement;
begin
  //todo 3: ＝変数リンクの取得
  //----------------------------------------------------------------------------
  // 一次取得
  Result := SyntaxTab(FSyntaxLevel);
  case Element.LinkType of
    svLinkGlobal:             Result := Result + hi_id2tango(Element.VarLink.VarID);
    svLinkLocal:              Result := Result + hi_id2tango(VarID);
    svLinkVirtualGroupMember:
      begin
        FGroupScope := HiSystem.GroupScope.TopItem;
        Result := Result + hi_id2tango(VarID);
      end;
    else raise HException.CreateFmt(ERR_S_RUN_VALUE,[hi_id2tango(VarID)]);
  end;

  pe := Element.NextElement;
  if pe = nil then Exit;

  //----------------------------------------------------------------------------
  // 要素・二次取得
  while pe <> nil do
  begin
    case pe.LinkType of
      svLinkArray:
        begin
          Result := Result + '[' + TrimA(pe.aryIndex.outNadesikoProgram) + ']';
          pe := pe.NextElement;
        end;
      svLinkHash:
        begin
          Result := Result + '@' + TrimA(pe.aryIndex.outNadesikoProgram);
          pe := pe.NextElement;
        end;
      svLinkGroup:
        begin
          Result := Result + '→' + TrimA(hi_id2tango(pe.groupMember));
          pe := pe.NextElement;
        end;
      else
        raise HException.Create('リンク切れ');
    end;
  end;
  //----------------------------------------------------------------------------
  Result := Result + #13#10;
end;

{ TSyntaxCalc }

constructor TSyntaxCalc.Create(FParent: TSyntaxNode);
begin
  inherited;
end;

function TSyntaxCalc.DebugStr: AnsiString;
begin
  Result := '(計算式)';
end;

destructor TSyntaxCalc.Destroy;
begin
  FreeAndNil(Children);
  inherited;
end;

function TSyntaxCalc.getValue: PHiValue;
var
  node: TSyntaxNode;
  va, vb, vc, p: PHiValue;
  // stack用変数
  stack: array [0..255] of PHiValue;
  sp: Integer;
begin
  hi_var_clear(NodeResult);
  Result := nil;
  ZeroMemory(@stack[0], Length(stack));
  if Children = nil then Exit;

  // 3 5 6 * +
  sp := 0;
  node := Children;
  while node <> nil do
  begin
    if node.ClassType = TSyntaxEnzansi then
    begin
      if sp <= 1 then raise HException.Create(ERR_RUN_CALC);
      vb := stack[sp-1]; Dec(sp); if vb = nil then vb := hi_var_new;
      va := stack[sp-1]; Dec(sp); if va = nil then va := hi_var_new;
      //todo 4: 計算式
      try
        case TSyntaxEnzansi(node).ID of
          token_plus      : vc := hi_var_calc_plus      (va, vb);
          token_minus     : vc := hi_var_calc_minus     (va, vb);
          token_mul       : vc := hi_var_calc_mul       (va, vb);
          token_div       : vc := hi_var_calc_div       (va, vb);
          token_mod       : vc := hi_var_calc_mod       (va, vb);
          token_Eq        : vc := hi_var_calc_Eq        (va, vb);
          token_NotEq     : vc := hi_var_calc_NotEq     (va, vb);
          token_Gt        : vc := hi_var_calc_Gt        (va, vb);
          token_GtEq      : vc := hi_var_calc_GtEq      (va, vb);
          token_Lt        : vc := hi_var_calc_Lt        (va, vb);
          token_LtEq      : vc := hi_var_calc_LtEq      (va, vb);
          token_ShiftL    : vc := hi_var_calc_ShiftL    (va, vb);
          token_ShiftR    : vc := hi_var_calc_ShiftR    (va, vb);
          token_power     : vc := hi_var_calc_power     (va, vb);
          token_plus_str  : vc := hi_var_calc_plus_str  (va, vb);
          token_or        : vc := hi_var_calc_or        (va, vb);
          token_and       : vc := hi_var_calc_and       (va, vb);
          else              vc := hi_var_new;
        end;
      except
        on e:Exception do
        begin
          raise HException.CreateFmt('計算の失敗(%s)『%s』(%s):%s',
            [
              Copy(hi_str(va),1,10),
              hi_id2tango(TSyntaxEnzansi(node).ID),
              Copy(hi_str(vb),1,10),
              e.Message
            ]);
        end;
      end;
      stack[sp] := vc;
      // スタックの桁あふれをチェック
      Inc(sp);
      if Length(stack) <= sp then
      begin
        raise HException.Create('計算が複雑すぎます。式を分割してください。');
      end;
      if va.Registered = 0 then hi_var_free(va);
      if vb.Registered = 0 then hi_var_free(vb);
    end else
    begin
      // 評価してスタックへ積む
      p := node.getValue;
      // 稀に戻り値が同一ポインタになってしまうので値を複製する
      stack[sp] := hi_var_new;
      hi_var_copy(p, stack[sp]);
      if (p <> nil)and(p.Registered = 0) then hi_var_free(p);
      Inc(sp);
    end;
    node := node.Next;
  end;

  // スタックの余剰チェック
  if sp <> 1 then raise HException.Create(ERR_RUN_CALC);

  // 答えをメモリ
  hi_var_copy(stack[0], NodeResult);

  // 不要なメモリを解放?
  va := stack[0];
  if (va <> nil) and (va.Registered = 0) then hi_var_free(va);


  // 結果をセット
  Result := NodeResult;
end;

function TSyntaxCalc.outLuaProgram: AnsiString;
var
  node: TSyntaxNode;
  va, vb: AnsiString;
  // stack用変数
  stack: array [0..255] of AnsiString;
  sp: Integer;
begin
  Result := '';
  if Children = nil then Exit;

  sp := 0;
  node := Children;
  while node <> nil do
  begin
    if node.ClassType = TSyntaxEnzansi then
    begin
      if sp <= 1 then raise HException.Create(ERR_RUN_CALC);
      vb := stack[sp-1]; Dec(sp);
      va := stack[sp-1]; Dec(sp);
      case TSyntaxEnzansi(node).ID of
      token_plus  : Result := va + '+' + vb;
      token_minus : Result := va + '-' + vb;
      token_mul   : Result := va + '*' + vb;
      token_div   : Result := va + '/' + vb;
      token_mod   : Result := va + '%' + vb;
      token_Eq    : Result := va + '==' + vb;
      token_NotEq : Result := va + '!=' + vb;
      token_Gt    : Result := va + '>' + vb;
      token_GtEq  : Result := va + '>=' + vb;
      token_Lt    : Result := va + '<' + vb;
      token_LtEq  : Result := va + '<=' + vb;
      token_ShiftL: Result := va + '<<' + vb;
      token_ShiftR: Result := va + '>>' + vb;
      token_power :  Result := va + '^' + vb;
      token_plus_str:Result := va + '&' + vb;
      token_or    :  Result := va + '||' + vb;
      token_and   :  Result := va + '&&' + vb;
      end;
      stack[sp] := Result; Inc(sp);
    end else
    begin
      // 評価してスタックへ積む
      stack[sp] := node.outNadesikoProgram; Inc(sp);
    end;
    node := node.Next;
  end;

  // スタックの余剰チェック
  if sp <> 1 then raise HException.Create(ERR_RUN_CALC);
  Result := '(' + TrimA(stack[0]) + ')';
end;

function TSyntaxCalc.outNadesikoProgram: AnsiString;
var
  node: TSyntaxNode;
  va, vb: AnsiString;
  // stack用変数
  stack: array [0..255] of AnsiString;
  sp: Integer;
begin
  Result := '';
  if Children = nil then Exit;

  // 3 5 6 * +
  // 3 5 +
  sp := 0;
  node := Children;
  while node <> nil do
  begin
    if node.ClassType = TSyntaxEnzansi then
    begin
      if sp <= 1 then raise HException.Create(ERR_RUN_CALC);
      vb := stack[sp-1]; Dec(sp);
      va := stack[sp-1]; Dec(sp);
      case TSyntaxEnzansi(node).ID of
      token_plus  : Result := va + '+' + vb;
      token_minus : Result := va + '-' + vb;
      token_mul   : Result := va + '*' + vb;
      token_div   : Result := va + '/' + vb;
      token_mod   : Result := va + '%' + vb;
      token_Eq    : Result := va + '==' + vb;
      token_NotEq : Result := va + '!=' + vb;
      token_Gt    : Result := va + '>' + vb;
      token_GtEq  : Result := va + '>=' + vb;
      token_Lt    : Result := va + '<' + vb;
      token_LtEq  : Result := va + '<=' + vb;
      token_ShiftL: Result := va + '<<' + vb;
      token_ShiftR: Result := va + '>>' + vb;
      token_power :  Result := va + '^' + vb;
      token_plus_str:Result := va + '&' + vb;
      token_or    :  Result := va + '||' + vb;
      token_and   :  Result := va + '&&' + vb;
      end;
      stack[sp] := Result; Inc(sp);
    end else
    begin
      // 評価してスタックへ積む
      stack[sp] := node.outNadesikoProgram; Inc(sp);
    end;
    node := node.Next;
  end;

  // スタックの余剰チェック
  if sp <> 1 then raise HException.Create(ERR_RUN_CALC);
  Result := '(' + TrimA(stack[0]) + ')';
end;

{ TSyntaxSentence }

constructor TSyntaxSentence.Create(FParent: TSyntaxNode);
begin
  inherited Create(FParent);
  Children := TSyntaxNodeChild.Create(self);
  DebugMemo := '';
end;

function TSyntaxSentence.DebugStr: AnsiString;
begin
  Result := '(文)'+DebugMemo;
end;

destructor TSyntaxSentence.Destroy;
begin
  FreeAndNil(Children);
  inherited;
end;

function TSyntaxSentence.getValue: PHiValue;
var
  p: PHiValue;
begin
  p := HiSystem.RunNode(Children);
  if p <> nil then
  begin
    hi_var_copyGensi(p, NodeResult);
    if p.Registered = 0 then hi_var_free(p);
    Result := NodeResult;
  end else
  begin
    Result := nil;
  end;
end;


function TSyntaxSentence.GetValueNoGetter(CanCreate:Boolean): PHiValue;
var
  p: PHiValue;
begin
  p := HiSystem.RunNode(Children, True);
  if p <> nil then
  begin
    hi_var_copyGensi(p, NodeResult);
    if p.Registered = 0 then hi_var_free(p);
    Result := NodeResult;
  end else
  begin
    Result := nil;
  end;
end;

function TSyntaxSentence.outLuaProgram: AnsiString;
begin
  Result := 'do'#13#10 + HiSystem.DebugProgram(Children) + 'end'#13#10;
end;

function TSyntaxSentence.outNadesikoProgram: AnsiString;
begin
  Result := SyntaxTab(FSyntaxLevel) + HiSystem.DebugProgram(Children);
end;

{ TSyntaxEnzansi }

function TSyntaxEnzansi.DebugStr: AnsiString;
begin
  Result := '(演算子)' + hi_id2tango(ID);
end;

function TSyntaxEnzansi.getValue: PHiValue;
begin
  Result := nil;
end;

function TSyntaxEnzansi.outLuaProgram: AnsiString;
begin
  Result := '';
end;

function TSyntaxEnzansi.outNadesikoProgram: AnsiString;
begin
  Result := '';
end;

{ TSyntaxFunction }

procedure TSyntaxFunction.ArgStackToLocalVar;
var
  arg: THimaArg;
  i: Integer;
  n: TSyntaxNode;
  v, vTmp: PHiValue;
  tmp: THiScope;

  function _getValue: PHiValue;
  begin
    if arg.VType = varGroup then
    begin
      if n is TSyntaxValue then
      begin
        Result := TSyntaxValue(n).GetValueNoGetter(False);
      end else
      begin
        raise HException.Create('関数の引数の型が違います。');
      end;
    end else
    begin
      Result := n.getValue;
    end;
  end;

  procedure _getDefaultValue;
  begin
    // 値が省略されたのでデフォルト値を取得
    // デフォルト値が参照されては困るので完全コピー
    v := hi_var_new;
    hi_var_copyData(arg.Value, v);
    // 変数に名前をつけて登録
    v.VarID := arg.Name;
    hi_var_ChangeType(v, arg.VType);
    HiSystem.Local.RegistVar(v);
  end;

begin
  // 引数変数の生成
  // スタックの構文木を実行して値を得て、ローカル変数として登録する
  if Stack = nil then Exit;
  
  for i := 0 to Stack.Count - 1 do
  begin
    n := Stack.Items[i];
    arg := HiFunc.Args.Items[i];

    // 引数が省略されているときの処理
    if n = nil then
    begin
      _getDefaultValue;
      Continue;
    end;

    // 引数として積まれた SyntaxNode を実行して値を得る
    // この部分だけ１つ上のローカル変数を参照する
    if HiSystem.LocalScope.Count > 1{ローカルが存在する} then
    begin
      with HiSystem do begin
        tmp := LocalScope.Items[LocalScope.Count-1];
        LocalScope.Items[LocalScope.Count-1] := LocalScope.Items[LocalScope.Count-2];
        vTmp := _getValue;
        LocalScope.Items[LocalScope.Count-1] := tmp;
      end;
    end else
    begin
      vTmp := _getValue;
    end;

    // 引数に乗せるためのコピーを得る
    v := makeArgVar(vTmp, arg.ByRef);
    // 型をチェック
    hi_var_ChangeType(v, arg.VType);

    // 変数に名前をつけて登録
    if v <> nil then v.VarID := arg.Name;
    HiSystem.Local.RegistVar(v);

  end;
end;

function TSyntaxFunction.callDllFunc: PHiValue;
var
  i: Integer;
  //rec: THimaRecord;
  v: PHiValue;
  ary: THiArray;
  //
  size: Integer;
  StkP: PAnsiChar;
  func: Pointer;
  res: Integer;
  resF: Extended;
  res64:Int64;
  resStr: AnsiString; resPtr: Pointer;
begin
  //----------------------------------------------------------------------------
  // 引数を取得
  ary := getArgStackToArray;

  // 引数をスタックに乗せる処理
  // 構造体を利用してスタックに順に引数を乗せていく

  if HiFunc.DllArg = nil then begin
    HiFunc.DllArg := THimaRecord.Create;
    HiFunc.DllArg.SetDataTypes(HiFunc.DllArgType,true);
    if HiFunc.DllArg.Count > 0 then HiFunc.DllArg.RecordCreate;
  end else
    ;

  for i := HiFunc.Args.Count - 1 downto 0 do
  begin
    // 引数にはリンクが渡されるのでリンクから実際の値を得る
    v := ary.Items[i];
    v := hi_getLink(v);
    if v <> nil then
      HiFunc.DllArg.SetValueIndex(i, v);// 積む順番に注意
  end;

  //----------------------------------------------------------------------------
  //writeln(rec.DumpMemory);
  //----------------------------------------------------------------------------
  // stdcall の場合
  // FUNC(DWORD AA,DWORD BB,DWORD CC) なら...
  // 引数のメモリは、AA AA AA AA BB BB BB BB CC CC CC CC となるようだ。

  size := HiFunc.DllArg.TotalByte;
  //{
  try
    // スタックポインタの設定
    asm
      sub ESP, size  // まず、引数を積めるように、スタックポインタの位置を変更。
      mov StkP, ESP  // そのスタックポインタのアドレスを得る
    end;
    Move(HiFunc.DllArg.DataPtr^, StkP^, size);

    // 関数のコール
    func := HiFunc.PFunc;

    // 返り値によって呼ぶ関数を使い分ける
    if HiFunc.DllRetType ='' then HiFunc.DllRetType := 'V';
    res := 0; resStr := ''; resF := 0; res64 := 0;
    case HiFunc.DllRetType[1] of
      //0
      'V':        TDllfuncVoid (func);
      //1B
      'C': res := TDllfuncChar (func);
      'B': res := TDllfuncByte (func);
      //2B
      'S': res := TDllfuncShort(func);
      'W': res := TDllfuncWord (func);
      //4B
      'L': res := TDllfuncLong (func);
      'D': res := TDllfuncDWord(func);
      'F': resF := TDllfuncFloat(func);
      'R': resF := TDllfuncDouble(func);
      'Q',
      'I': res64 := TDllfuncInt64(func);
      'P': // ポインタ型
      begin
        if (HiFunc.DllRetType = 'PChar')or(HiFunc.DllRetType = 'PAnsiChar') then
        begin
          resStr := AnsiChar( TDllfuncPtr(func) );
        end else
        begin
          resPtr := TDllfuncPtr(func);
          res := Integer(resPtr);
        end;
      end;
      else raise HException.Create('DLL関数の戻り値が未定義なので呼び出しませんでした。');
    end;

    // 関数の結果を代入
    if not (HiFunc.DllRetType[1] = 'V') then begin
      Result := hi_var_new;
      if HiFunc.DllRetType = 'PChar' then hi_setStr(Result, resStr)
                                     else
      begin
        case HiFunc.DllRetType[1] of
          'F','R': hi_setFloat(Result,resF);
          'I':     hi_setIntOrFloat(Result,res64);//出来るだけ整数で
          'Q':
          begin
                   if res64 < 0 then hi_setIntOrFloat(Result,Power(2,64)+res64)
                   else hi_setIntOrFloat(Result,res64);
          end;
          else     hi_setInt(Result, res);
        end;
      end;
    end else
      Result := nil;//VOIDの時は値を返さない
    HiFunc.DllArg.RestoreBuffer;
  except on e: Exception do
    raise EHimaRuntime.Create(
      DebugInfo,
      ERR_S_DLL_FUNCTION_EXEC + AnsiString(e.Message),
      [(hi_id2tango(FuncID))]);
  end;
  //}

  //ary.ClearNotFree;//完全にクリアしてかまわないので。
  ary.Free;
  //rec.Free;
end;

function TSyntaxFunction.callSysFunc: PHiValue;
var
  a: THiArray;
begin
  a := getArgStackToArray;
  try
    Result := THimaSysFunction(HiFunc.PFunc)(a);
  finally
    //a.ClearNotFree;
    a.Free ;
  end;
end;

function TSyntaxFunction.callUserFunc: PHiValue;
var
  n: TSyntaxNode;
  tmp: Integer;
begin
  //------------------------------
  // 引数をローカルに登録する
  //------------------------------
  // ローカルスコープの生成
  HiSystem.PushRunFlag;
  HiSystem.PushScope;
  try
    // 登録
    ArgStackToLocalVar;

    // 関数の実行
    tmp := HiSystem.FFuncBreakLevel;
    HiSystem.FFuncBreakLevel := HiSystem.FNestCheck;

    // 実行
    n := HiFunc.PFunc;
    n.SyntaxLevel := HiSystem.CurNode.SyntaxLevel; // イベントでレベルが無視されるバグ対策
    LastUserFuncID := Self.FuncID;
    HiSystem.RunNode2(n);

    // 結果(変数『それ』)をコピー
    Result := hi_var_new;
    hi_var_copyGensi(HiSystem.Sore, Result);

    // 戻す
    HiSystem.FFuncBreakLevel := tmp;
  finally
    HiSystem.PopScope;
    HiSystem.PopRunFlag;
  end;
end;

constructor TSyntaxFunction.Create(FParent: TSyntaxNode);
begin
  inherited Create(FParent);
  Stack           := THObjectList.Create;
  CanBreak        := True;
  Link.LinkType   := sfLinkDirect;
  Link.LinkValue  := nil;
  FDebugFuncName  := '';
  DefFunc         := nil;
end;

function TSyntaxFunction.DebugStr: AnsiString;
begin
  Result := '(関数)' + hi_id2tango(FuncID);
end;

destructor TSyntaxFunction.Destroy;
begin
  // SyntaxDefFunction 宣言の方でで開放される
  // if HiFunc <> nil then FreeAndNil(HiFunc);

  if Link.LinkValue <> nil then FreeAndNil(Link.LinkValue);
  
  FreeAndNil(Stack);
  inherited;
end;

function TSyntaxFunction.getArgStackToArray: THiArray;
var
  res: THiArray;
  arg: THimaArg;
  i: Integer;
  n: TSyntaxNode;
  v, tmp: PHiValue;

  procedure _getDefaultValue;
  begin
    // 省略された場合：初期値があるか？
    if arg.Value.VType <> varNil then
    begin
      // 参照渡し/値渡しに関係なくデータ自体をコピーして渡す
      // 省略値が壊されないように注意
      v := hi_var_new;
      hi_var_copyData(arg.Value, v);
      // 引数に名前をつける
      v.VarID := arg.Name;
      // 型をチェック
      hi_var_ChangeType(v, arg.VType);
      res.Values[i] := v;
    end else
    begin
      // 省略されたが初期値はない
      // そのまま nil を返す
      res.Values[i] := nil;
    end;
  end;

  procedure _getGroupValue;
  begin
    if not (n is TSyntaxValue) then raise HException.Create('指定された引数の型と合わない型が指定されてます。');
    // グループを取得
    tmp := TSyntaxValue(n).GetValueNoGetter(False);
    v   := makeArgVar(tmp, True);
    // 引数に名前をつける
    v.VarID := arg.Name;
    // 型をチェック ... 不要
    // hi_var_ChangeType(v, arg.VType);
    res.Values[i] := v;
  end;

begin
  res := THiArray.Create;
  res.ForStack := True;

  if Stack = nil then begin Result := res; Exit; end;
  // stack の値を配列に取得
  for i := 0 to Stack.Count - 1 do
  begin
    arg := HiFunc.Args.Items[i];
    n   := Stack.Items[i];

    // スタックにある構文木 n を実行し結果を 引数 res.Value[i] にコピーする

    // (1) 引数が省略されているときの処理
    if n = nil then
    begin
      _getDefaultValue;
      Continue;
    end;

    // (2) 引数を実行

    // 例外...グループが引数に指定されているときは、デフォルト引数を参照しない
    if arg.VType = varGroup then
    begin
      _getGroupValue;
      Continue;
    end;

    // 通常の引数取得
    tmp := HiSystem.RunNode(n);
    // 引数に乗せるために変数を複製する(そのまま乗せると、引数開放のときにデータ自体が始末されてしまうため)
    v := makeArgVar(tmp, arg.ByRef);

    if (tmp <> nil)and(tmp.Registered = 0)and(arg.ByRef = False) then
    begin
      hi_var_free(tmp);
    end;
    
    // 名前をつける
    if v <> nil then v.VarID := arg.Name;
    // 型をチェック
    hi_var_ChangeType(v, arg.VType);
    // 引数配列に代入
    res.Values[i] := v;

  end;
  Result := res;
end;

function TSyntaxFunction.getValue: PHiValue;
var
  res: PHiValue;
  tempGlobal: THiScope;
begin
  //todo 3:●関数の実行

  // グローバル変数ネームスペース
  tempGlobal := HiSystem.Namespace.CurSpace;
  HiSystem.Namespace.SetCurSpace(DebugInfo.FileNo);
  res := nil;
  try
    case Link.LinkType of
    sfLinkDirect:
      begin
        case HiFunc.FuncType of
          funcSystem  : res := callSysFunc;
          funcUser    : res := callUserFunc;
          funcDll     : res := callDllFunc;
          else          res := nil;
        end;
      end;
    sfLinkGroupMember:
      begin
        Link.LinkValue.GetValueNoGetter(False);
        HiSystem.GroupScope.PushGroupScope(Link.LinkValue.GroupScope);
        try
          res := callUserFunc;
        finally
          HiSystem.GroupScope.PopGroupScope;
        end;
      end;
    sfLinkVirtuaLink:
      begin
        res := callUserFunc;
      end;
    end;
  except on e: Exception do
    raise HException.CreateFmt(ERR_S_FUNCTION_EXEC + e.Message ,[hi_id2tango(FuncID)]);
  end;
  //---------------------
  // 戻り値の処理
  if res <> nil then
  begin
    hi_var_copyGensi(res, HiSystem.Sore);
    hi_var_copyGensi(res, NodeResult);
    Result := NodeResult;
    if res.Registered = 0 then hi_var_free(res); // 登録されてなければ削除
  end else
  begin
    hi_var_clear(NodeResult);
    Result := nil;
  end;
  HiSystem.Namespace.CurSpace := tempGlobal;
end;

function TSyntaxFunction.makeArgVar(v: PHiValue; IsRef: Boolean): PHiValue;
begin
  // 引数の生成
  // IsRef = 参照渡しかどうか
  if v = nil then begin Result := nil; Exit; end;

  // 参照渡し
  if IsRef then
  begin
    // リンクを作る
    Result := hi_var_new;
    hi_setLink(Result, v);
    Exit;
  end;

  // 値渡し
  case v.VType of
    varNil, varInt, varFloat, varStr:
      begin
        Result := hi_var_new;
        hi_var_copyData(v, Result);
      end;
    else
      begin
        Result := hi_var_new;
        hi_var_copyGensi(v, Result);
        //hi_setLink(Result, v);
        //※値渡しの場合で、リンクを作ると
        //※リンク元が、すぐに解放されてしまうのでメモリ違反となる
        //※リンクではなくhi_var_copyGensi()を使う
      end;
  end;
end;

function TSyntaxFunction.outLuaProgram: AnsiString;
begin
  raise HException.Create('TSyntaxFunction.outLuaProgram');
end;

function TSyntaxFunction.outNadesikoProgram: AnsiString;
var
  i: Integer;
  o: TSyntaxNode;
  f: AnsiString;
begin

  // グローバル変数ネームスペース
  //tempGlobal := HiSystem.Namespace.CurSpace;
  //HiSystem.Namespace.SetCurSpace(DebugInfo.FileNo);

  f := '';
  Result := SyntaxTab(SyntaxLevel);
  try
    case Link.LinkType of
    sfLinkDirect:
      begin
        f := hi_id2tango(FuncID);
      end;
    sfLinkGroupMember:
      begin
        //p := Link.LinkValue.GetValueNoGetter;
        f := TrimA(HiSystem.DebugProgram(Link.LinkValue));
      end;
    sfLinkVirtuaLink:
      begin
        f := hi_id2tango(FuncID);
      end;
    end;
  except on e: Exception do
    raise HException.CreateFmt(ERR_S_FUNCTION_EXEC + '理由は,' + e.Message ,[hi_id2tango(FuncID)]);
  end;

  if Stack.Count > 0 then
  begin
    for i := 0 to Stack.Count - 1 do
    begin
      o := Stack.Items[i];
      if o <> nil then
      begin
        Result := Result + TrimA(Hisystem.DebugProgram( o ));
        Result := Result + HiSystem.JosiList.ID2Str(o.JosiId);
        Result := Result + ',';
      end;
    end;
  end;

  Result := Result + f + #13#10;
end;

{ TSyntaxLet }

constructor TSyntaxLet.Create(FParent: TSyntaxNode);
begin
  inherited Create(FParent);
  IsEvent := False;
  token   := nil;
  VarNode := nil;
end;

function TSyntaxLet.DebugStr: AnsiString;
begin
  Result := '(代入)' + hi_id2tango(VarID);
  if VarNode.Element.NextElement <> nil then
  begin
    Result := Result + 'の要素';
  end;
end;

destructor TSyntaxLet.Destroy;
begin
  FreeAndNil(VarNode);
  inherited;
end;

function TSyntaxLet.getValueRaw: PHiValue;
var
  pName, pValue, tmp: PHiValue;

  procedure _subSetter;
  var
    f: THiFunction; fn: TSyntaxNode;

    procedure __exec_user;
    var
      arg: THimaArg;
      a, res: PHiValue;
    begin
      // 引数を登録
      arg := f.Args.Items[0];

      // setter の引数を再評価
      if (arg.VType = varGroup) then
      begin
        pValue := HiSystem.RunNode(Children, True);
      end else
      begin
        pValue := HiSystem.RunNode(Children);
      end;

      HiSystem.PushScope;
      try
        // 引数をローカルに登録
        a := hi_var_new;
        hi_var_copyGensi(pValue, a); // a に値をコピー
        // ID
        a.VarID := arg.Name;
        // ローカルに登録
        HiSystem.Local.RegistVar(a);
        res := HiSystem.RunNode(fn);
        // 実行結果をプロパティに反映する
        if res <> nil then hi_var_copyGensi(res, NodeResult) else hi_var_clear(NodeResult);
      finally
        HiSystem.PopScope;
      end;
    end;

    procedure __exec_system;
    var
      ary: THiArray;
      arg: THimaArg;
      a, res: PHiValue;
    begin
      ary := THiArray.Create;
      try
        // 引数を登録
        arg := f.Args.Items[0];
        if (arg.VType = varGroup)and(Children is TSyntaxValue) then
        begin
          pValue := TSyntaxValue(Children).GetValueNoGetter(False);
        end else
        begin
          pValue := HiSystem.RunNode(Children);
        end;

        a := hi_var_new;
        hi_var_copyGensi(pValue, a);
        a.VarID := arg.Name;
        ary.Values[0] := a;
        // 実行
        res := THimaSysFunction(f.PFunc)(ary);
        // 実行結果をプロパティに反映する
        if res <> nil then hi_var_copyGensi(res, NodeResult) else hi_var_clear(NodeResult);
      finally
        ary.ClearNotFree;
        FreeAndNil(ary);
      end;
    end;

  begin
    //todo: setter
    f  := hi_func(pName.Setter); // 関数
    fn := f.PFunc;               // 実行先ノード

    // 引数のチェック
    if f.Args.Count <> 1 then raise HException.CreateFmt(ERR_S_DEF_VAR+'セッターの引数は１つにしてください。',[hi_id2tango(Self.VarID)]);

    // グループ内実行？
    if VarNode.GroupScope <> nil then
    begin
      HiSystem.GroupScope.PushGroupScope(VarNode.GroupScope);
      try
        __exec_user;
      finally
        HiSystem.GroupScope.PopGroupScope;
      end;
    end else
    begin
      case f.FuncType of
      funcSystem: __exec_system;
      funcUser:   __exec_user;
      end;
    end;
  end;

  function _parseSN: TSyntaxNode;
  var
    p: THiParser;
    n: TSyntaxNode;
    t: THimaToken;
  begin
    // 実行すべきソースを構文木に変換
    p := THiParser.Create;
    try
      n := TSyntaxNode.Create(nil);
      Result := n;
      t := token;
      HiSystem.PushScope;
      try
        if Self.tokenMultiLine then
        begin
          p.ReadBlocks(t, n);
        end else
        begin
          p.ReadLine(t, n);
        end;
      finally
        HiSystem.PopScope;
      end;
      HiSystem.DefFuncList.Add(Result);
    finally
      p.Free;
    end;

  end;

begin
  //TSyntaxLet.getValue
  Result := nil;

  if Self.IsEvent then
  begin
    if token = nil then Exit;

    // 何に代入するのか先に得る
    pName := VarNode.GetValueNoGetter(True);
    // 実行すべきソースを構文木に変換
    // イベントを変数に割り当てる
    hi_func_create(pName);
    hi_func(pName).FuncType := funcUser;
    hi_func(pName).PFunc := _parseSN; // *** EVENT NODE
    Exit;
  end;

  // 何に代入するか？
  pName   := VarNode.GetValueNoGetter(True);
  if pName = nil then raise HException.Create('代入文で左辺が取得できません。');
  if pName.VType = varLink then // リンクなら展開する
  begin
    pName := hi_getLink(pName);
  end;

  // グループへの代入か？
  if pName.VType = varGroup then
  begin
    if hi_group(pName).DefaultValue <> nil then
    begin
      VarNode.FGroupScope := hi_group(pName);
      pName := hi_group(pName).DefaultValue;
    end;
  end;

  // セッターか？
  if (pName <> nil)and(pName.Setter <> nil) then
  begin
    _subSetter;
    // 代入の戻り値
    Result := nil;
  end else
  // 違えば............通常の代入...........................
  begin
    // 代入すべき値を評価
    pValue := HiSystem.RunNode(Children);
    //
    if pValue = nil then pValue := hi_var_new; // なぜか nil が戻ってきたとき
    if pName  = nil then
    begin
      raise HException.Create('代入処理で左辺がnilです。');
    end;
    // 安全性を考慮
    // グループにグループ以外のモノを代入しようとした
    if(pName.VType = varGroup)and(pValue.VType <> varGroup)then
    begin
      raise HException.Create('グループにグループ以外の値を代入しようとしました。');
    end;

    //-----------------------------------
    // 実際の代入処理
    //-----------------------------------
    // 配列などが壊れるのを防ぐため、一度内容を退避する
    // | コピーの途中に、右辺を一度初期化してしまうので、
    // |   配列 = 配列[要素番号]
    // | のような処理を行うと配列が壊れてしまうのを防ぐため
    tmp := hi_var_new;
    try
      hi_var_copyData(pValue, tmp);
      //-----------------------------------
      hi_var_copyData(tmp, pName);
      pName.Registered := 1;
      if pValue.Registered = 0 then hi_var_free(pValue);
      Result := nil;
      //-----------------------------------
    finally
      hi_var_free(tmp);
    end;
  end;

end;

function TSyntaxLet.getValue: PHiValue;
begin
  Result := getValueRaw;
end;

function TSyntaxLet.outLuaProgram: AnsiString;

  procedure _parseSN;
  var
    p: THiParser;
    n: TSyntaxNode;
    t: THimaToken;
  begin
    // 実行すべきソースを構文木に変換

    p := THiParser.Create;
    n := Children;
    t := token;

    if t <> nil then
    begin
      HiSystem.PushScope;
      try
        if Self.tokenMultiLine then
        begin
          p.ReadBlocks(t, n);
        end else
        begin
          p.ReadLine(t, n);
        end;
      finally
        HiSystem.PopScope;
      end;
      if Children.Next = nil then Children.Children.SetSyntaxLevel(Self.FSyntaxLevel + 1)
      else Children.next.SetSyntaxLevel( Self.FSyntaxLevel + 1 );

      Result := Result + HiSystem.DebugProgram( Children, langLua );
    end;
    p.Free;
  end;

begin

  if Self.IsEvent then
  begin
    // 何に代入するのか先に得る
    Result := SyntaxTab(Self.SyntaxLevel) + TrimA(VarNode.outNadesikoProgram) + '= function()'#13#10;
    // 実行すべきソースを構文木に変換
    _parseSN;
    Result := Result + 'end'#13#10;
    Exit;
  end;

  // 何に代入するか？
  Result := SyntaxTab(SyntaxLevel) + TrimA(VarNode.outLuaProgram);
  Result := Result + ' = ' + TrimA(HiSystem.DebugProgram( Children, langLua)) + #13#10;
end;

function TSyntaxLet.outNadesikoProgram: AnsiString;

  procedure _parseSN;
  var
    p: THiParser;
    n: TSyntaxNode;
    t: THimaToken;
  begin
    // 実行すべきソースを構文木に変換

    p := THiParser.Create;
    n := Children;
    t := token;

    if t <> nil then
    begin
      HiSystem.PushScope;
      try
        if Self.tokenMultiLine then
        begin
          p.ReadBlocks(t, n);
        end else
        begin
          p.ReadLine(t, n);
        end;
      finally
        HiSystem.PopScope;
      end;
      if Children.Next = nil then Children.Children.SetSyntaxLevel(Self.FSyntaxLevel + 1)
      else Children.next.SetSyntaxLevel( Self.FSyntaxLevel + 1 );

      Result := Result + HiSystem.DebugProgram( Children );
    end;
    p.Free;
  end;

begin

  if Self.IsEvent then
  begin
    // 何に代入するのか先に得る
    Result := SyntaxTab(Self.SyntaxLevel) + TrimA(VarNode.outNadesikoProgram) + 'は～'#13#10;
    // 実行すべきソースを構文木に変換
    _parseSN;
    Exit;
  end;

  // 何に代入するか？
  Result := SyntaxTab(SyntaxLevel) + TrimA(VarNode.outNadesikoProgram);
  Result := Result + ' = ' + TrimA(HiSystem.DebugProgram( Children )) + #13#10;
end;

procedure TSyntaxLet.SetSyntaxLevel(const Value: Integer);
begin
  inherited;
  if VarNode <> nil then VarNode.SyntaxLevel := Value;
end;

{ TSyntaxWhile }

constructor TSyntaxWhile.Create(FParent: TSyntaxNode);
begin
  inherited Create(FParent);
  jouken := nil;
  CanBreak := True;
end;

function TSyntaxWhile.DebugStr: AnsiString;
begin
  Result := '(間)';
end;

destructor TSyntaxWhile.Destroy;
begin
  FreeAndNil(jouken);
  inherited;
end;

function TSyntaxWhile.getValue: PHiValue;
var
  p: PHiValue;
  c: Integer;
  tmpKaisuu: Integer;
begin
  c := 1;
  tmpKaisuu := hi_int(HiSystem.kaisu);

  while True do
  begin
    hi_setInt(HiSystem.kaisu, c); Inc(c);

    // 無限ループ対策...少なすぎるかな？
    if (c > MAX_STACK_COUNT) then
    begin
      HiSystem.Eval2('0.01秒待つ'); // 適度なWAITを入れて緩和
      c := 0;
    end;

    //<BREAK>
    if HiSystem.BreakType = btBreak then
    begin
      // この上でブレークされる
      if HiSystem.BreakLevel < SyntaxLevel then Break;
      if HiSystem.BreakLevel = SyntaxLevel then
      begin
        HiSystem.BreakLevel := BREAK_OFF;
        HiSystem.BreakType  := btNone;
        Break;
      end;
      if HiSystem.ReturnLevel < HiSystem.FNestCheck then Break;
    end;
    //</BREAK>

    //<ACTION>
    p := HiSystem.RunNode(jouken);
    if hi_bool(p) = False then Break;
    HiSystem.RunNode(Children);
    //</ACTION>

    //<CONTINUE>
    if HiSystem.BreakType = btContinue then
    begin
      if HiSystem.BreakLevel <= SyntaxLevel then
      begin
        HiSystem.BreakLevel := BREAK_OFF;
        HiSystem.BreakType  := btNone;
        Continue;
      end;
    end;
    //</CONTINUE>

  end;
  hi_setInt(HiSystem.kaisu, tmpKaisuu);
  Result := nil;
end;

function TSyntaxWhile.outLuaProgram: AnsiString;
begin
  Result := SyntaxTab(SyntaxLevel) +
    'while(' + TrimA(HiSystem.DebugProgram(jouken, langLua)) + ')do'#13#10 +
    HiSystem.DebugProgram(Children,langLua) + #13#10 +
    'end'#13#10;
end;

function TSyntaxWhile.outNadesikoProgram: AnsiString;
begin
  Result := SyntaxTab(SyntaxLevel) + TrimA(HiSystem.DebugProgram(jouken)) + 'の間'#13#10;
  Result := Result + HiSystem.DebugProgram(Children);
end;

procedure TSyntaxWhile.SetSyntaxLevel(const Value: Integer);
begin
  inherited;
  if jouken <> nil then jouken.SyntaxLevel := Value;
end;

{ TSyntaxIf }

constructor TSyntaxIf.Create(FParent: TSyntaxNode);
begin
  inherited Create(FParent);
  jouken    := nil;
  TrueNode  := nil;
  FalseNode := nil;
  Reverse   := False;
end;

function TSyntaxIf.DebugStr: AnsiString;
begin
  Result := '(ならば)';
end;

destructor TSyntaxIf.Destroy;
begin
  FreeAndNil(jouken);
  FreeAndNil(TrueNode);
  FreeAndNil(FalseNode);
  inherited;
end;

function TSyntaxIf.getValue: PHiValue;
var
  v: PHiValue;
  b: Boolean;
begin
  Result := nil;
  v := HiSystem.RunNode(jouken);
  b := hi_bool(v);
  if Reverse then b := not b;
  if b then
  begin
    if TrueNode <> nil then Result := HiSystem.RunNode(TrueNode);
  end else
  begin
    if FalseNode <> nil then Result := HiSystem.RunNode(FalseNode);
  end;
end;

function TSyntaxIf.outLuaProgram: AnsiString;
var
  cond_str: AnsiString;
begin
  cond_str := '';
  if Reverse then
  begin
    cond_str := '!';
  end;
  Result := SyntaxTab(SyntaxLevel) +
    'if '+cond_str+'(' + TrimA(HiSystem.DebugProgram( Jouken, langLua )) + ')then'#13#10;
  // --
  Result := Result + SyntaxTab(SyntaxLevel+1) + TrimA(HiSystem.DebugProgram(TrueNode,langLua)) + #13#10;
  if FalseNode <> nil then
  begin
    Result := Result + SyntaxTab(SyntaxLevel) + 'else'#13#10;
    Result := Result + SyntaxTab(SyntaxLevel+1) +TrimA(HiSystem.DebugProgram(FalseNode,langLua)) + #13#10;
  end;
  Result := Result + 'end'#13#10;
end;

function TSyntaxIf.outNadesikoProgram: AnsiString;
begin
  Result := SyntaxTab(SyntaxLevel);
  Result := Result + 'もし,' + TrimA(HiSystem.DebugProgram( Jouken ));
  if Reverse then Result := Result + 'でなければ' else Result := Result + 'ならば';
  Result := Result + #13#10;
  // --
  Result := Result + SyntaxTab(SyntaxLevel+1) + TrimA(HiSystem.DebugProgram(TrueNode)) + #13#10;
  if FalseNode <> nil then
  begin
    Result := Result + SyntaxTab(SyntaxLevel) + '違えば'#13#10;
    Result := Result + SyntaxTab(SyntaxLevel+1) +TrimA(HiSystem.DebugProgram(FalseNode)) + #13#10;
  end;
end;

procedure TSyntaxIf.SetSyntaxLevel(const Value: Integer);
begin
  inherited;
  if jouken <> nil then
  begin
    jouken.Parent := Self;
    jouken.SyntaxLevel := Value;
  end;
  if TrueNode <> nil then
  begin
    TrueNode.Parent := Self;
    TrueNode.SyntaxLevel := Value + 1;
    if TrueNode.ClassType = TSyntaxSentence then TSyntaxSentence(TrueNode).DebugMemo := '=真の時';
  end;
  if FalseNode <> nil then
  begin
    FalseNode.Parent := Self;
    FalseNode.SyntaxLevel := Value + 1;
    if FalseNode.ClassType = TSyntaxSentence then TSyntaxSentence(FalseNode).DebugMemo := '=偽の時';
  end;
end;

{ TSyntaxLoop }

constructor TSyntaxLoop.Create(FParent: TSyntaxNode);
begin
  inherited Create(FParent);
  kaisu := nil;
  CanBreak := True;
end;

function TSyntaxLoop.DebugStr: AnsiString;
begin
  Result := '(回)';
end;

destructor TSyntaxLoop.Destroy;
begin
  FreeAndNil(kaisu);
  inherited;
end;

function TSyntaxLoop.getValue: PHiValue;
var
  i: Integer;
  v: PHiValue;
  tmpKaisu: Integer;
begin
  Result := nil;

  // BREAK?
  if HiSystem.BreakType = btBreak then
  begin
    // この上でブレークされる
    if HiSystem.BreakLevel < SyntaxLevel then Exit;
    if HiSystem.BreakLevel = SyntaxLevel then
    begin
      HiSystem.BreakLevel := BREAK_OFF;
      HiSystem.BreakType  := btNone;
      Exit;
    end;
    if HiSystem.ReturnLevel < HiSystem.FNestCheck then Exit;
  end;

  tmpKaisu := hi_int(HiSystem.kaisu);
  // 何回ループするのか？
  v := kaisu.getValue;
  for i := 1 to hi_int(v) do
  begin
    hi_setInt(HiSystem.kaisu, i);
    try
      HiSystem.RunNode(Children);
    except
      on e:Exception do
      begin
        raise HException.CreateFmt('%d回目の実行中',[i]);
      end;  
    end;
    if HiSystem.BreakType = btContinue then
    begin
      if HiSystem.BreakLevel <= SyntaxLevel then
      begin
        HiSystem.BreakLevel := BREAK_OFF;
        HiSystem.BreakType  := btNone;
        Continue;
      end;
    end else
    // BREAK?
    if HiSystem.BreakType = btBreak then
    begin
      // この上でブレークされる
      if HiSystem.BreakLevel < SyntaxLevel then Break;
      if HiSystem.BreakLevel = SyntaxLevel then
      begin
        HiSystem.BreakLevel := BREAK_OFF;
        HiSystem.BreakType  := btNone;
        Break;
      end;
      if HiSystem.ReturnLevel < HiSystem.FNestCheck then Break;
    end;

  end;
  Result := nil;
  hi_setInt(HiSystem.kaisu, tmpKaisu);
end;

function TSyntaxLoop.outLuaProgram: AnsiString;
begin
  Result := SyntaxTab(SyntaxLevel) +
    'do'#13#10+
      'local _loop'#13#10+
      'for _loop=1,('+TrimA(HiSystem.DebugProgram(kaisu)) + ')do'#13#10+
      HiSystem.DebugProgram(Children, langLua) + #13#10 +
      'end'#13#10+
    'end'#13#10;
end;

function TSyntaxLoop.outNadesikoProgram: AnsiString;
begin
  Result := SyntaxTab(SyntaxLevel) + TrimA(HiSystem.DebugProgram(kaisu)) + '回'#13#10;
  Result := Result + HiSystem.DebugProgram(Children);
end;

procedure TSyntaxLoop.SetSyntaxLevel(const Value: Integer);
begin
  inherited;
  if kaisu <> nil then kaisu.SyntaxLevel := Value;
end;

{ TSyntaxNodeTop }

function TSyntaxNodeTop.DebugStr: AnsiString;
begin
  Result := '-(トップノード)-';
end;

function TSyntaxNodeTop.getValue: PHiValue;
begin
  Result := inherited getValue;
end;

function TSyntaxNodeTop.outLuaProgram: AnsiString;
begin
  Result := '-- top'#13#10;
end;

function TSyntaxNodeTop.outNadesikoProgram: AnsiString;
begin
  Result := '# トップ'#13#10;
end;

{ TSyntaxNodeChild }

function TSyntaxNodeChild.DebugStr: AnsiString;
begin
  Result := '-(子ノード)-';
end;

function TSyntaxNodeChild.getValue: PHiValue;
begin
  Result := inherited getValue;
end;

function TSyntaxNodeChild.outLuaProgram: AnsiString;
begin
  Result := HiSystem.DebugProgram(Self.Next, langLua) + '--Node'#13#10;
end;

function TSyntaxNodeChild.outNadesikoProgram: AnsiString;
begin
  //Result := '#子ノード'#13#10;
  //Result := inherited outNadesikoProgram;
  HiSystem.DebugProgram(Self.Next);
end;

{ TSyntaxFor }

constructor TSyntaxFor.Create(FParent: TSyntaxNode);
begin
  inherited Create(FParent);
  VarLoop := nil;
  VarFrom := nil;
  VarTo   := nil;
  CanBreak := True;
end;

function TSyntaxFor.DebugStr: AnsiString;
begin
  Result := '(繰り返し)';
end;

destructor TSyntaxFor.Destroy;
begin
  //todo 5: 既知のバグ:FreeAndNil(FOR)
  //以下の３つは、FreeAndNilすべきだが、コメントをはずすと、
  //関数内の繰り返し処理を行い、HiSystemメモリ解放時にランタイムエラーが出る

  FreeAndNil(VarLoop);
  FreeAndNil(VarFrom);
  FreeAndNil(VarTo  );

  inherited;
end;

function TSyntaxFor.getValue: PHiValue;
var
  HiLoop: PHiValue;
  HiFrom, HiTo: PHiValue;
  c, i, iFrom, iTo, BreakLevel: Integer;
  tmpKaisu: Integer;
begin
  tmpKaisu := hi_int(HiSystem.kaisu);
  Result   := nil;

  //<BREAK>
  if HiSystem.BreakType = btBreak then
  begin
    // この上でブレークした時
    BreakLevel := HiSystem.BreakLevel;
    if BreakLevel < SyntaxLevel then Exit;
    if BreakLevel = SyntaxLevel then
    begin
      HiSystem.BreakLevel := BREAK_OFF;
      HiSystem.BreakType  := btNone;
      Exit;
    end;
    if HiSystem.ReturnLevel < HiSystem.FNestCheck then Exit;
  end;
  //</BREAK>

  // ループカウンタ ... 省略されていれば「それ」をカウンターに使う
  if VarLoop <> nil then
  begin
    HiLoop := VarLoop.getValue;
  end else
  begin
    HiLoop := HiSystem.Sore;
  end;

  HiFrom := VarFrom.getValue; iFrom := hi_int(HiFrom);
  HiTo   := VarTo.getValue;   iTo   := hi_int(HiTo);

  //----------------------------------------------------------------------------
  if iFrom <= iTo then
  begin
    c := 1;
    for i := iFrom to iTo do
    begin
      hi_setInt(HiSystem.kaisu, c); Inc(c);

      // LOOP COUNTER
      hi_setInt(HiLoop, i);

      //<実行>
      HiSystem.RunNode(Children);
      //</実行>

      //<CONTINUE>
      if HiSystem.BreakType = btContinue then
      begin
        if HiSystem.BreakLevel <= SyntaxLevel then
        begin
          HiSystem.BreakLevel := BREAK_OFF;
          HiSystem.BreakType  := btNone;
          Continue;
        end;
      end else
      //</CONTINUE>
      //<BREAK>
      if HiSystem.BreakType = btBreak then
      begin
        // この上でブレークされる
        BreakLevel := HiSystem.BreakLevel;
        if BreakLevel < SyntaxLevel then Break;
        if BreakLevel = SyntaxLevel then
        begin
          HiSystem.BreakLevel := BREAK_OFF;
          HiSystem.BreakType  := btNone;
          Break;
        end;
        if HiSystem.ReturnLevel < HiSystem.FNestCheck then Break;
      end;
      //</BREAK>

    end;
  end else
  //----------------------------------------------------------------------------
  begin
    c := 1;
    for i := iFrom downto iTo do
    begin
      hi_setInt(HiSystem.kaisu, c); Inc(c);

      // LOOP COUNTER
      hi_setInt(HiLoop, i);

      //<実行>
      HiSystem.RunNode(Children);
      //</実行>

      //<CONTINUE>
      if HiSystem.BreakType = btContinue then
      begin
        if HiSystem.BreakLevel <= SyntaxLevel then
        begin
          HiSystem.BreakLevel := BREAK_OFF;
          HiSystem.BreakType  := btNone;
          Continue;
        end;
      end else
      //</CONTINUE>
      //<BREAK>
      if HiSystem.BreakType = btBreak then
      begin
        // この上でブレークされる
        if HiSystem.BreakLevel < SyntaxLevel then Break;
        if HiSystem.BreakLevel = SyntaxLevel then
        begin
          HiSystem.BreakLevel := BREAK_OFF;
          HiSystem.BreakType  := btNone;
          Break;
        end;
        if HiSystem.ReturnLevel < HiSystem.FNestCheck then Break;
      end;
      //</BREAK>

    end;
  end;
  hi_setInt(HiSystem.kaisu,tmpKaisu);
end;


function TSyntaxFor.outLuaProgram: AnsiString;
begin
  Result := SyntaxTab(SyntaxLevel) +
    'do'#13#10+
    'local i'#13#10+
    'for i=('+ TrimA(HiSystem.DebugProgram(VarFrom,langLua))+'),'+
    '('+TrimA(HiSystem.DebugProgram(VarTo))+')do'#13#10+
    'l["'+TrimA(HiSystem.DebugProgram(VarLoop))+'"]=l'#13#10+
    HiSystem.DebugProgram(Children,langLua)+#13#10+
    'end'#13#10;
end;

function TSyntaxFor.outNadesikoProgram: AnsiString;
begin
  Result := SyntaxTab(SyntaxLevel) + TrimA(HiSystem.DebugProgram(VarLoop)) + 'で' + TrimA(HiSystem.DebugProgram(VarFrom)) + 'から';
  Result := Result + TrimA(HiSystem.DebugProgram(VarTo)) + 'まで繰り返し'#13#10;
  Result := Result + HiSystem.DebugProgram(Children);
end;

{ TSyntaxTryExcept }

constructor TSyntaxTryExcept.Create(FParent: TSyntaxNode);
begin
  inherited Create(FParent);
  NodeTry := nil;
  NodeExcept := nil;
end;

function TSyntaxTryExcept.DebugStr: AnsiString;
begin
  Result := '(エラー監視)';
end;

destructor TSyntaxTryExcept.Destroy;
begin
  FreeAndNil(NodeTry);
  FreeAndNil(NodeExcept);
  inherited;
end;

function TSyntaxTryExcept.getValue: PHiValue;
begin
  // 例外のトラップは Delphi の例外機構に任せっきり
  try
    Result := HiSystem.RunNode(NodeTry);
  except
    on e: Exception do
    begin
      // ErrFmt(NodeTry.DebugInfo.FileNo, NodeTry.DebugInfo.LineNo, e.Message, []);
      // ... 一時的なメッセージではなく、全体を得る ... hi_setStr(HiSystem.Sore, e.Message);
      hi_setStr(HiSystem.ErrMsg, HimaErrorMessage);
      Result := HiSystem.RunNode(NodeExcept);
    end;
  end;
end;

procedure TSyntaxTryExcept.SetSyntaxLevel(const Value: Integer);
begin
  inherited;
  if NodeTry <> nil then
  begin
    NodeTry.Parent := Self;
    NodeTry.SyntaxLevel := Value + 1;
    if NodeTry.ClassType = TSyntaxSentence then TSyntaxSentence(NodeTry).DebugMemo := '=エラー監視';
  end;
  if NodeExcept <> nil then
  begin
    NodeExcept.Parent := Self;
    NodeExcept.SyntaxLevel := Value + 1;
    if NodeExcept.ClassType = TSyntaxSentence then TSyntaxSentence(NodeExcept).DebugMemo := '=エラーならば';
  end;

end;

{ TSyntaxDefFunction }

constructor TSyntaxDefFunction.Create(FParent: TSyntaxNode);
begin
  inherited Create(FParent);
  FuncID  := 0;
  GroupID := 0;
  FlagGroupMember := False;
  HiFunc   := nil; // コンパイルされているなら、(HiFunc <> nil)
  //contents := nil;
end;

function TSyntaxDefFunction.DebugStr: AnsiString;
begin
  Result := '(ユーザー関数)' + hi_id2tango(FuncID);
end;

destructor TSyntaxDefFunction.Destroy;
begin
  //HiSystem.HiFuncで解放される -> FreeAndNil(HiFunc);
  inherited;
end;

function TSyntaxDefFunction.getValue: PHiValue;
begin
  Result := HiSystem.RunNode(Children);
end;

function TSyntaxDefFunction.outLuaProgram: AnsiString;
var
  i: Integer;
  a: THimaArg;
begin
  // name
  if GroupID > 0 then
  begin
    Result := 'function ' + hi_id2tango(GroupID) + '.' + hi_id2tango(FuncID);
  end else
  begin
    Result := 'function ' + hi_id2tango(FuncID);
  end;

  // arg
  if HiFunc.Args.Count > 0 then
  begin
    Result := Result + '(';
    for i := 0 to HiFunc.Args.Count - 1 do
    begin
      a := HiFunc.Args.Items[i];
      Result := Result + hi_id2tango(a.Name);
      if a.JosiList.Count > 0 then
      begin
        Result := Result + HiSystem.JosiList.ID2Str(a.JosiList.GetAsNum(0));
      end;
    end;
    Result := Result + ')'#13#10;
  end else
  begin
    Result := Result + #13#10;
  end;
  // value
  Result := Result + HiSystem.DebugProgram(Children,langLua) +#13#10+
    'end'#13#10;
end;

function TSyntaxDefFunction.outNadesikoProgram: AnsiString;
var
  i: Integer;
  a: THimaArg;
begin
  // name
  if GroupID > 0 then
  begin
    Result := '●' + hi_id2tango(GroupID) + '→' + hi_id2tango(FuncID);
  end else
  begin
    Result := '●' + hi_id2tango(FuncID);
  end;

  // arg
  if HiFunc.Args.Count > 0 then
  begin
    Result := Result + '(';
    for i := 0 to HiFunc.Args.Count - 1 do
    begin
      a := HiFunc.Args.Items[i];
      Result := Result + hi_id2tango(a.Name);
      if a.JosiList.Count > 0 then
      begin
        Result := Result + HiSystem.JosiList.ID2Str(a.JosiList.GetAsNum(0));
      end;
    end;
    Result := Result + ')'#13#10;
  end else
  begin
    Result := Result + #13#10;
  end;
  // value
  Result := Result + HiSystem.DebugProgram(Children);
end;

{ TSyntaxEach }

constructor TSyntaxEach.Create(FParent: TSyntaxNode);
begin
  inherited Create(FParent);
  jouken := nil;
  CanBreak := True;
  iVar := nil;
end;

function TSyntaxEach.DebugStr: AnsiString;
begin
  Result := '(反復)';
end;

destructor TSyntaxEach.Destroy;
begin
  FreeAndNil(jouken);
  FreeAndNil(iVar);
  inherited;
end;

function TSyntaxEach.getValue: PHiValue;
var
  v, sore: PHiValue;
  i, cnt: Integer;
  p: PAnsiChar;
  str, s: AnsiString;
  mode: Integer;
  ary: THiArray;
  tkFile: TKTextFileE;
  tmpKaisu: Integer;
  ptmpTaisyou, ptaisyou: PHiValue;

  // 文字列を一行切り取る
  procedure _getLine;
  begin
    s := '';
    p := PAnsiChar(str);
    while p^ <> #0 do begin
      if p^ in LeadBytes then begin
        s := s + p^ + (p+1)^; Inc(p, 2);
      end else begin
        if p^ = #13 then
        begin
          Inc(p);
          if p^ = #10 then Inc(p);
          Break;
        end else
        if p^ = #10 then
        begin
          Inc(p);
          Break;
        end else
        begin
          s := s + p^; Inc(p);
        end;
      end;
    end;
  end;

  //--------------------------------------------------------------------------
  // 実際の反復処理
  //--------------------------------------------------------------------------
  procedure _repeat;
  begin
    i := 0;
    sore := HiSystem.Sore;

    while True do
    begin
      hi_setInt(HiSystem.kaisu, (i+1));

      //<イテレーターの設定>
      // 終了条件をチェック
      case mode of
        0:// string
        begin
          // 一行切り取る
          _getLine;
          str := p; // 残り
          if (s='')and(str='') then Break;
          hi_setStr(sore, s);
        end;
        1:// array
        begin
          cnt := ary.Count;
          if i >= cnt then Break;
          hi_var_clear(sore);
          hi_var_copyData(
            ary.Values[i],
            sore);
        end;
        2:// TKTextFileStream
        begin
          if tkFile.EOF then
          begin
            FreeAndNil(tkFile);
            Break;
          end;
          hi_setStr(sore, tkFile.ReadLn);
        end;
      end;

      //-----------------------------------------
      // "それ"の内容を"対象"にもコピー
      hi_var_copyData(sore, ptaisyou);
      //-----------------------------------------

      //<実行>
      HiSystem.RunNode(Children);
      Inc(i); // ループ回数
      //</実行>

      //<CONTINUE>
      if HiSystem.BreakType = btContinue then
      begin
        if HiSystem.BreakLevel <= SyntaxLevel then
        begin
          HiSystem.BreakLevel := BREAK_OFF;
          HiSystem.BreakType  := btNone;
          Continue;
        end;
      end else
      //</CONTINUE>
      //<BREAK>
      if HiSystem.BreakType = btBreak then
      begin
        // この上でブレークされる
        if HiSystem.BreakLevel < SyntaxLevel then Break;
        if HiSystem.BreakLevel = SyntaxLevel then
        begin
          HiSystem.BreakLevel := BREAK_OFF;
          HiSystem.BreakType  := btNone;
          Break;
        end;
        if HiSystem.ReturnLevel < HiSystem.FNestCheck then Break;
      end;
      //</BREAK>
    end;
  end;

begin
  Result := nil; ary := nil; str := ''; tkFile := nil;
  // 無条件ブレークを考慮
  //<BREAK>
  if HiSystem.BreakType = btBreak then
  begin
    // この上でブレークされる
    if HiSystem.BreakLevel < SyntaxLevel then Exit;
    if HiSystem.BreakLevel = SyntaxLevel then
    begin
      HiSystem.BreakLevel := BREAK_OFF;
      HiSystem.BreakType  := btNone;
      Exit;
    end;
    if HiSystem.ReturnLevel < HiSystem.FNestCheck then Exit;
  end;
  //</BREAK>

  //---------------------------------
  // 既存の「回数」「対象」を退避
  //---------------------------------
  // <注意>
  // なぜか tmpTaosyou:THiValue は、@tmpTaisyou とキャストできない
  // ptmpTaisyou 型を new しないとうまく動作しないようだ
  // </注意>

  tmpKaisu := hi_int(HiSystem.kaisu); // 回数

  if (Self.iVar <> nil) then
  begin
    ptmpTaisyou := nil;
    ptaisyou    := TSyntaxValue(iVar).GetValueNoGetter(True); // 対象の代わりに
  end else
  begin
    ptmpTaisyou := hi_var_new; // 対象
    hi_var_copyData( hi_getLink(HiSystem.taisyou), ptmpTaisyou);
    ptaisyou := HiSystem.taisyou;
  end;
  //---------------------------------
  // 反復条件を得る
  v := HiSystem.RunNode(jouken);
  v := hi_getLink(v); // リンク先が返されたならリンクを展開

  //<反復前置処理>
  case v.VType of

    varStr, varInt, varFloat: // 原始型
      begin
        str := hi_str(v);
        mode := 0;
        //if Copy(str,1,18) = 'TKTextFileStream::' then // 例外的なファイルストリーム
        if Copy(str,1,11) = '@@@毎行読::' then // 例外的なファイルストリーム
        begin
          getToken_s(str, '::');
          tkFile := TKTextFileE.Create(TrimA(str), fmOpenRead);
          if not(tkFile is TKTextFileE) then str := '';
          mode := 2;
        end;
      end;
    varArray:
      begin
        // それの値が壊れてもループできるように内容をコピー。
        ary := THiArray.Create;
        ary.Assign(THiArray(v^.ptr)); // 値を全てコピー。
        mode := 1;
      end;
    else
      begin
        str  := hi_str(v);
        mode := 0;
      end;

  end;
  //</反復前置処理>

  try
    // <繰り返し処理>
    _repeat;
    // </繰り返し処理>
  finally
    // <片付け処理>
    case mode of
      1: FreeAndNil(ary);    // 変数それでループした場合
      2:
        begin
          try
            FreeAndNil(tkFile); // TKTextFileStreamを解放
          except end;
        end;
    end;
    hi_setInt(HiSystem.kaisu, tmpKaisu);            // 回数を復元
    if Self.iVar = nil then
    begin
      try
        hi_var_copyData(ptmpTaisyou, ptaisyou); // 対象を復元
      except
      end;
      hi_var_free(ptmpTaisyou);                           // 対象を解放

    end;
    // </片付け処理>
  end;

end;

function TSyntaxEach.outLuaProgram: AnsiString;
begin
  Result := SyntaxTab(SyntaxLevel) +
    'do'#13#10+
      'for _key,_val in pair(' + TrimA(HiSystem.DebugProgram(jouken,langLua)) + ') do'#13#10+
        HiSystem.DebugProgram(Children,langLua)+#13#10+
      'end'#13#10+
    'end'#13#10;
end;

function TSyntaxEach.outNadesikoProgram: AnsiString;
begin
  Result := SyntaxTab(SyntaxLevel) + TrimA(HiSystem.DebugProgram(jouken)) + 'を反復'#13#10;
  Result := Result + HiSystem.DebugProgram(Children);
end;

procedure TSyntaxEach.SetSyntaxLevel(const Value: Integer);
begin
  inherited;
  if jouken <> nil then
  begin
    jouken.Parent := Self;
    jouken.SyntaxLevel := Value;
  end;
end;

{ TSyntaxCreateVar }


constructor TSyntaxCreateVar.Create(FParent: TSyntaxNode);
begin
  inherited Create(FParent);
  Template := hi_var_new;
  InitNode := nil;
end;

function TSyntaxCreateVar.DebugStr: AnsiString;
begin
  Result := '(変数生成)' + hi_id2tango(Template.VarID);
end;

destructor TSyntaxCreateVar.Destroy;
begin
  if Template <> nil then hi_var_free(Template);
  FreeAndNil(InitNode);
  inherited;
end;

function TSyntaxCreateVar.getValue: PHiValue;
var
  v, initValue: PHiValue;
begin
  Result := nil;
  v:=nil;
  // ローカルに template を登録する
  if template <> nil then
  begin
    v := hi_var_new;
    hi_var_copyData(template, v);
    v.VarID := template.VarID;
    HiSystem.Local.RegistVar(v);
  end;
  if (v <> nil)and(InitNode <> nil) then
  begin
    // 初期化式を評価して代入
    initValue := InitNode.getValue;
    hi_var_copyData(initValue, v);
  end;
end;


function TSyntaxCreateVar.outLuaProgram: AnsiString;
begin
  Result := '';
  if template = nil then Exit;
  Result := SyntaxTab(SyntaxLevel) + '-- ' +
    'l[' + hi_id2tango(template.VarID) + '] as ' + hi_vtype2str(template)+#13#10;
end;

function TSyntaxCreateVar.outNadesikoProgram: AnsiString;
begin
  Result := '';
  if template = nil then Exit;

  Result := SyntaxTab(SyntaxLevel) + hi_id2tango(template.VarID) + 'とは' + hi_vtype2str(template)+#13#10;
end;

{ TSyntaxSwitch }

constructor TSyntaxSwitch.Create(FParent: TSyntaxNode);
begin
  inherited Create(FParent);
  CaseNodes := THObjectList.Create;
  ElseNode := nil;
  Jouken   := nil;
end;

function TSyntaxSwitch.DebugStr: AnsiString;
begin
  Result := '(条件分岐)';
end;

destructor TSyntaxSwitch.Destroy;
begin
  FreeAndNil(Jouken);
  FreeAndNil(CaseNodes);
  FreeAndNil(ElseNode);
  inherited;
end;

function TSyntaxSwitch.getValue: PHiValue;
var
  vJouken, vCase, vKekka: PHiValue;
  i: Integer;
  iCase: TSyntaxSwitchCase;
  FlagAct: Boolean;
begin

  // 条件式の取得
  if Jouken = nil then
  begin
    vJouken := HiSystem.Sore
  end else
  begin
    vJouken := Jouken.getValue;
  end;

  // 合致する選択肢があるか調べる
  FlagAct := False;
  for i := 0 to CaseNodes.Count - 1 do
  begin
    iCase  := CaseNodes.Items[i];
    vCase  := iCase.Jouken.getValue;
    try
      vKekka := hi_var_calc_Eq(vJouken, vCase);
      try
        if hi_bool(vKekka) then
        begin
          FlagAct := True;
          HiSystem.RunNode2(iCase.Action);
          Break;
        end;
      finally
        if (vKekka <> nil) and (vKekka.Registered = 0) then hi_var_free(vKekka);
      end;
    finally
      if (vCase <> nil) and (vCase.Registered = 0) then hi_var_free(vCase);
    end;
  end;

  // 合致しなければ Else を実行
  if (FlagAct = False)and(ElseNode <> nil) then
  begin
    HiSystem.RunNode2(ElseNode);
  end;

  // Switch の結果があればコピー
  Result := nil;
end;

function TSyntaxSwitch.outLuaProgram: AnsiString;
var
  i: Integer;
  c: TSyntaxSwitchCase;
begin
  Result := '';
  Result := SyntaxTab(SyntaxLevel) + '-- switch'#13#10;
  Result := SyntaxTab(SyntaxLevel) + 'do'#13#10 +
    'local _case = ' + TrimA( HiSystem.DebugProgram(jouken,langLua) ) + #13#10 +
    'if false then'#13#10;
  for i := 0 to CaseNodes.Count - 1 do
  begin
    c := CaseNodes.Items[i];
    Result := Result + 'elsif(_case=='+TrimA( HiSystem.DebugProgram(c.Jouken) )+')then'#13#10+
      HiSystem.DebugProgram(c.Action) + #13#10;
  end;
  if ElseNode <> nil then
  begin
    Result := Result + 'else'#13#10;
    Result := Result + HiSystem.DebugProgram(ElseNode);
  end;
  Result := Result + #13#10+'end'+#13#10;
end;


function TSyntaxSwitch.outNadesikoProgram: AnsiString;
var
  i: Integer;
  c: TSyntaxSwitchCase;
begin
  Result := SyntaxTab(SyntaxLevel) + TrimA( HiSystem.DebugProgram(jouken) ) + 'で条件分岐'#13#10;
  for i := 0 to CaseNodes.Count - 1 do
  begin
    c := CaseNodes.Items[i];
    Result := Result + SyntaxTab(SyntaxLevel+1) +  TrimA( HiSystem.DebugProgram(c.Jouken) ) + 'ならば'#13#10;
    Result := Result + HiSystem.DebugProgram(c.Action);
  end;
  if ElseNode <> nil then
  begin
    Result := Result + SyntaxTab(SyntaxLevel+1) + '違えば'#13#10;
    Result := Result + HiSystem.DebugProgram(ElseNode);
  end;
end;

procedure TSyntaxSwitch.SetSyntaxLevel(const Value: Integer);
var
  i: Integer;
  c: TSyntaxSwitchCase;
begin
  inherited;
  if jouken <> nil then
  begin
    jouken.Parent := Self;
    jouken.SyntaxLevel := Value;
  end;
  if ElseNode <> nil then
  begin
    ElseNode.Parent := Self;
    ElseNode.SyntaxLevel := Value + 1;
  end;
  for i := 0 to CaseNodes.Count - 1 do
  begin
    c := CaseNodes.Items[i];
    c.Jouken.Parent := Self;
    c.Jouken.SyntaxLevel := Value + 1;
    c.Action.Parent := Self;
    c.Action.SyntaxLevel := Value + 1;
  end;
end;

{ TSyntaxSwitchCase }

constructor TSyntaxSwitchCase.Create;
begin
  jouken := nil;
  Action := TSyntaxSentence.Create(nil);
  Action.DebugMemo := '条件分岐の条件';
end;

destructor TSyntaxSwitchCase.Destroy;
begin
  FreeAndNil(Jouken);
  FreeAndNil(Action);
  inherited;
end;

{ TSyntaxWith }

constructor TSyntaxWith.Create(FParent: TSyntaxNode);
begin
  inherited Create(FParent);
end;

function TSyntaxWith.DebugStr: AnsiString;
begin
  Result := '(について)';
end;

destructor TSyntaxWith.Destroy;
begin
  FreeAndNil(WithVar);
  inherited;
end;

function TSyntaxWith.getValue: PHiValue;
var
  n: PHiValue;
begin
  // --- With Var の Var を取得
  n := WithVar.GetValueNoGetter(False);
  n := hi_getLink(n);
  if n.VType <> varGroup then raise HException.Create('『●について』構文にはグループ名を指定してください。');
  // ---
  HiSystem.GroupScope.PushGroupScope(hi_group(n));
  try
    Result := HiSystem.RunNode(Children);
  finally
    HiSystem.GroupScope.PopGroupScope;
  end;
end;

function TSyntaxWith.outNadesikoProgram: AnsiString;
begin
  Result := SyntaxTab(FSyntaxLevel) + TrimA(HiSystem.DebugProgram(WithVar)) + 'について'#13#10;
  Result := Result + HiSystem.DebugProgram(Children);
end;

{ TSyntaxNamespace }

function TSyntaxNamespace.DebugStr: AnsiString;
begin
  if scopeID >= 0 then
    Result := '(ネームスペース変更)' + AnsiString(HimaFileList.Strings[scopeID])
  else
    Result := '(ネームスペース変更)' + IntToStrA(scopeID);
end;

function TSyntaxNamespace.getValue: PHiValue;
begin
  HiSystem.Namespace.SetCurSpace(scopeID);
  Result := nil;
end;

function TSyntaxNamespace.outLuaProgram: AnsiString;
begin
  Result := '-- todo:namespace'#13#10;
end;

function TSyntaxNamespace.outNadesikoProgram: AnsiString;
begin
  if scopeID >= 0 then
    Result :=
      '『' +
      AnsiString(ChangeFileExt(
        string(HimaFileList.Strings[scopeID]),
        ''
      )) +
      '』にネームスペース変更。'#13#10
  else
    Result := '『システム』にネームスペース変更。'#13#10;
end;

{ TSyntaxTerm }

constructor TSyntaxTerm.Create(FParent: TSyntaxNode);
begin
  inherited;
  baseNode := nil;
end;

function TSyntaxTerm.DebugStr: AnsiString;
begin
  Result := '(項) - ' + baseNode.DebugStr;
end;

destructor TSyntaxTerm.Destroy;
begin
  FreeAndNil(baseNode);
  inherited;
end;

function TSyntaxTerm.getValue: PHiValue;
var
  res: PHiValue;
begin
  res := HiSystem.RunNode( baseNode );
  hi_var_copyData(res, NodeResult);

  if mode = termMinus then
  begin
    hi_setIntOrFloat(NodeResult, hi_float(NodeResult) * -1);
  end else
  begin
    hi_setBool(NodeResult, not hi_Bool(NodeResult));
  end;
  //---
  Result := NodeResult;

  if res.Registered = 0 then hi_var_free(res);
end;

function TSyntaxTerm.outLuaProgram: AnsiString;
begin
  Result := outNadesikoProgram;
end;

function TSyntaxTerm.outNadesikoProgram: AnsiString;
begin
  if mode = termMinus then
  begin
    Result := '-' + baseNode.outNadesikoProgram;
  end else
  begin
    Result := '!' + baseNode.outNadesikoProgram;
  end;
end;

{ TSyntaxValueElement }

constructor TSyntaxValueElement.Create;
begin
  VarLink     := nil; // 解放なし
  Stack       := nil; //* 解放が必要
  aryIndex    := nil; //* 解放が必要
  groupMember := 0;
end;

destructor TSyntaxValueElement.Destroy;
begin
  if NextElement <> nil then FreeAndNil(NextElement);
  FreeAndNil(Stack);
  FreeAndNil(aryIndex);
  inherited;
end;

{ TSyntaxJumpPoint }

function TSyntaxJumpPoint.DebugStr: AnsiString;
begin
  Result := '▲' + hi_id2tango(NameId) + ';';
end;

function TSyntaxJumpPoint.outNadesikoProgram: AnsiString;
begin
  Result := DebugStr;
end;

end.
