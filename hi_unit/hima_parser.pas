unit hima_parser;

//------------------------------------------------------------------------------
// �\���؂ɕϊ�����
//------------------------------------------------------------------------------

interface               

uses
  Windows, SysUtils, hima_error, hima_types, hima_token,
  hima_variable, hima_variable_ex, hima_function, mmsystem;


type                                            
  // �O���錾                            
  TSyntaxNode = class;

  // �X�^�b�N                           
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
  // �\���؂ƂȂ�v�f
  //----------------------------------------------------------------------------
  TSyntaxNode = class
  private
    FSyntaxLevel: Integer;          // �\�������x��
    FParent     : TSyntaxNode;
    procedure SetParent(const Value: TSyntaxNode);      // �e�̃m�[�h
  protected
    procedure SetSyntaxLevel(const Value: Integer); virtual;
  public
    DebugInfo   : TDebugInfo  ;     // �s�ԍ��Ȃ�
    Next        : TSyntaxNode;      // ���̃m�[�h
    Children    : TSyntaxNode;      // �q�̃m�[�h
    JosiId      : Integer;          // ����ID
    NodeResult  : PHiValue;         // �m�[�h�̎��s����
    Priority    : Integer;          // ���̗D�揇��
    CanBreak    : Boolean;          // Break�Ŕ����邱�Ƃ��ł��邩�H
    ReadOnly    : Boolean;          // ���̃m�[�h�ɂ͏������݂��\���H
    FlagLive    : Boolean;          // ���̃m�[�h�������痘�p����Ă��邩�ǂ���
  public
    constructor Create(FParent: TSyntaxNode);
    destructor Destroy; override;
    function DebugStr: AnsiString; virtual;           // �ȈՃf�o�b�O�p������̕ێ�
    function getValue: PHiValue; virtual;         // �m�[�h�̓��e�����s����
    function GetValueNoGetter(CanCreate:Boolean): PHiValue; virtual; // Getter�Ȃ��̕ϐ��𓾂�
    function FindBreakLevel: Integer;             // ������Ȃǂ̏����Ɏg��
    function outNadesikoProgram: AnsiString; virtual; // �\���؂���Ȃł����̃v���O�����𐶐�����
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

  // �\���̊֌W���������߂̃m�[�h�^�C�v
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
  // �ϐ��̒l���擾����m�[�h
  //----------------------------------------------------------------------------
  TSyntaxValueLinkType = (
    svLinkGlobal,
    svLinkLocal,
    svLinkArray,
    svLinkHash,
    svLinkGroup,             // GROUP->MEMBER �̏ꍇ
    svLinkVirtualGroupMember // (GROUP�s���ł��̎��̃O���[�v)->MEMBER �̏ꍇ
  );

  TSyntaxValueElement = class
  public
    LinkType    : TSyntaxValueLinkType;
    NextElement : TSyntaxValueElement;
    // option
    Stack       : THObjectList; // �O���[�v�̓��I���s�Ŋ֐��̈�����ێ�����
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

  // -1 �� !true ��\��
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
    VarNode: TSyntaxValue;    // ���ӕێ��̂��߂̕ϐ��E�E�ӂ�Children��
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
    InitNode: TSyntaxNode; // �������̂��߂̎������邩�ǂ���
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
    iVar: TSyntaxValue; // �C�e���[�^�[�ϐ�
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
  // ������\��
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

  // ���ʂ̊֐��̌Ăяo��
  TSyntaxFunctionLinkType = (
    sfLinkDirect,       // ����HiFunc�̓��e�����s
    sfLinkGroupMember,  // �O���[�v->�����o�֐�
    sfLinkVirtuaLink    // (���I�O���[�v)->�����o�֐�
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
    function makeArgVar(v: PHiValue; IsRef: Boolean): PHiValue; // �����ɏ悹�邽�߂ɕϐ��𕡐�����
    function getArgStackToArray: THiArray; // �V�X�e���ϐ��̂��߂Ɉ������悹�鏈��
    procedure ArgStackToLocalVar;          // ���[�J���ϐ��̂��߂Ɉ������悹�鏈��
    function callSysFunc:  PHiValue;
    function callUserFunc: PHiValue;
    function callDllFunc:  PHiValue;
  public
    FDebugFuncName: AnsiString; // �f�o�b�O�p�֐���
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

  // �����̂Ȃ��֐��^��錾�i�V�����c�k�k�C���|�[�g���߁j
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
    FStack      : THStack; // SyntaxNode ���o���Ă���
    FTopNode    : TSyntaxNode;
    FCurNode    : TSyntaxNode;
    FNextBlock  : THimaToken;
    FPrevToken  : THimaToken;
    FReadFlag   : THiReadFlag;
    procedure ReadSyntaxBlock(var token: THimaToken; var cnode: TSyntaxNode;
      defIndent: Integer);  // �Ӗ������̃u���b�N��ǂ�
    procedure ReadPreprocess(token: THimaToken; var node: TSyntaxNode); // �p�[�X�ȑO�Ɋ֐���o�^����
    procedure ReadBlocks(var token: THimaToken; var cnode: TSyntaxNode);  // �u���b�N���P�ǂ�
    procedure ReadLine(var token: THimaToken; var cnode: TSyntaxNode; CanLet:Boolean = True);   // �s���P�̋�؂�܂œǂ� - �s�̓r���Ŕ����邱�Ƃ�����B
    //procedure ReadLineEx(var token: THimaToken; var cnode: TSyntaxNode; CanLet:Boolean = True); // �s�̏I�[�܂ŕK���ǂ�
    function ReadOneItem(var token: THimaToken): Boolean; // �g�[�N�����P�ǂ�
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
    procedure TokenNextToken(var token: THimaToken); // token�����ɐi�߂�
    procedure TokenSkipComma(var token: THimaToken);
    //
    procedure infix2rpolish(sikiStack: THStack); // ���ԋL�@���t�|�[�����h
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
  if name = 'TSyntaxCalc' then Result := '���Z' else
  if name = 'TSyntaxValue' then Result := '�l' else
  if name = 'TSyntaxDefFunction' then Result := '�֐���`' else
  if name = 'TSyntaxFunction' then Result := '�֐�' else
  if name = 'TSyntaxTryExcept' then Result := '��O����' else
  if name = 'TSyntaxLet' then Result := '���' else
  if name = 'TSyntaxWhile' then Result := '��' else
  if name = 'TSyntaxLoop' then Result := '��' else
  if name = 'TSyntaxFor' then Result := '�J��Ԃ�' else
  if name = 'TSyntaxEach' then Result := '����' else
  if name = 'TSyntaxIf' then Result := '����' else
  if name = 'TSyntaxSwitch' then Result := '��������' else
  if name = 'TSyntaxWith' then Result := '�ɂ���' else
  if name = 'TSyntaxSentence' then Result := '��' else
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
  // ������
  Parent    := FParent;
  Next      := nil;
  Children  := nil;
  Priority  := MaxInt; // �ʏ�̗D�揇�ʂ͍ō����x��
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
  Result := '(�Ȃ�)' + hi_str(NodeResult);
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
  // �e���Ȃ���Ύ��g������(�܂�ł��Ȃ�)
  if Parent = nil then
  begin
    Result := SyntaxLevel;
  end else
  // �������� Break �ł��邩���ׂ�
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

  // ���̃m�[�h������Ύ����ݒ肷��
  if Next <> nil then
  begin
    if Self.Parent <> nil then Next.Parent := Self.Parent;
    Next.SyntaxLevel := Value;
  end;

  // �q�̃��x���������ݒ肷��
  if Children <> nil then
  begin
    Children.Parent      := Self;
    Children.SyntaxLevel := Value + 1;
  end;
end;

{ THiParser }

constructor THiParser.Create;
begin
  // ����
  FStack := THStack.Create;
  FStackStack := THList.Create;
  // ������
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
  // �D�揇�ʂ𒲂ׂ�
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
  // ������ёւ��� ���ԋL�@���t�|�[�����h
  //--------------------------------------------------------------------------
  // 1) �ȉ����J��Ԃ�
  //      2) ������P�̈��q�����o��
  //      3) (���o�������q�̗D�揇��) <= (�X�^�b�N�g�b�v�̈��q�̗D�揇��) �̊ԁApolish �� tempStack�̍ŏ�ʂ̈��q�����o���Đς�
  //      4) 2)�Ŏ��o�������q��tempStack�ɐς�
  // 5) tempStack �̎c��� polish �ɐς�

  tempStack := THStack.Create;
  polish    := THStack.Create;

  try
    // �ԕ��� tempStack �ɒu���Ă���
    n := TSyntaxNode.Create(nil);
    n.Priority := -1; // �ԕ�
    tempStack.Push(n);

    // ��������
    for i := 0 to sikiStack.Count - 1 do // ... 1
    begin
      n := sikiStack.Get(i); //... 2
      while n.Priority <= tempStack.GetLast.Priority do // ... 3
      begin
        polish.Push(tempStack.Pop);
      end;
      tempStack.Push(n); // ... 4
    end;
    while tempStack.Count > 1{�ԕ��ȊO} do polish.Push(tempStack.Pop); // ... 5
    // �����܂�

    // sikiStack �Ɍ��ʂ��悹������
    sikiStack.Assign(polish);

    // �ԕ����폜
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

  // Namespace �̃Z�b�g
  tmpSpace := HiSystem.Namespace.CurSpace;
  FCurNode.Next := TSyntaxNamespace.Create(nil);
  TSyntaxNamespace(FCurNode.Next).scopeID := token.FileNo;
  FCurNode := FCurNode.Next;

  // �֐��̐�ǂ�(��`������ǂ�)
  ReadPreprocess(token, FCurNode);

  // �ǂݍ���
  ReadBlocks(token, FCurNode);
  Result := FTopNode;

  FTopNode.SyntaxLevel := 0; // ����őS�Ă̍\�����x���������Őݒ肳���

  // Namespace ��߂�
  FCurNode.Next := TSyntaxNamespace.Create(nil);
  TSyntaxNamespace(FCurNode.Next).scopeID := tmpSpace.ScopeID;
  FCurNode := FCurNode.Next;
end;

procedure THiParser.ReadArg(var token: THimaToken; var josi: Integer);
begin
  // �������擾����
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
  //todo 2:���u���b�N�ȉ���ǂ�
  if token = nil then Exit;
  TopIndent := token.Indent;

  while token <> nil do
  begin
    // �P�u���b�N�̏I�[�𔻕�
    if TopIndent <> token.Indent then
    begin
      //..TopIndent(2)
      //....token.Indent(4)
      //....token.Indent(4)
      //..NextToken(2) �� �����Ŕ�����
      if TopIndent{1} >= token.Indent{3} then Break;
    end;

    // ���̃��C���𒲂ׂĂ���
    pTemp := token;
    FNextBlock := token.CheckNextBlock;

    try

      //{$IFDEF ERROR_LOG}errLog(Format('%0.4d:���-'+token.Token,[token.LineNo]));{$ENDIF}

      // �s�̏��߂ɂ�����ʂȒP��
      case token.TokenID of
        token_mark_function:  begin ReadDefFunctionContents(token); Continue; end; // �֐��̐錾
        token_mark_sikaku:    begin SkipDefFunction(token); Continue; end;         // �O���[�v�̐錾
        token_mark_option:    begin ReadOption(token,False,cnode); Continue; end;  // �C���^�v���^�I�v�V����
        token_kakko_end:      raise HException.Create(ERR_NOPAIR_KAKKO+'�ˑR�́w)�x�ł��B');
      end;

      // ��s�̏I���܂œǂ�
      ReadLine(token, cnode);

      if (token <> nil)and(pTemp = token) then // �����Ƃ�������x�����[�v���Ă���
      begin
        raise HException.Create('�p�[�X�G���[�B�u'+hi_id2tango(token.TokenID)+'�v');
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
    // skip '�E'
    i := token.Indent;
    token := token.NextToken;
    if token = nil then raise HException.CreateFmt(ERR_S_DEF_GROUP+'�����o�̖��O������܂���B',[hi_id2tango(group.VarID)]);

    // �����o�ϐ��̐���
    m := hi_var_new;

    // �C�������邩(1/2)
    if token.TokenID = token_nami_kakko_begin then getArgType(token, m, b, refVar);

    // �����o��
    m.VarID := token.TokenID;
    // �O���[�v�ɓo�^
    hi_group(group).Add(m);
    token := token.NextToken; // SKIP NAME
    if token = nil then Exit;

    // �C�������邩(2/2)...�C���͕�����₷���悤�ɑO�ł����ł�OK
    if token.TokenID = token_nami_kakko_begin then
    begin
      getArgType(token, m, b, refVar);
    end;
    if token = nil then Exit;

    // �Q�b�^�[�ƃZ�b�^�[(�����ł͔�΂�)
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
    // �f�t�H���g
    if token.TokenID = token_default then
    begin
      hi_group(group).DefaultValue := m;
      token := token.NextToken;
      if token = nil then Exit;
    end;

    // �֐��錾�����邩�H
    if token.TokenID = token_kakko_begin{'('} then
    begin // ���ꑦ���֐�
      hi_func_create(m);
      getDefArgs(token, hi_func(m).Args);
      if token = nil then raise HException.CreateFmt(ERR_S_DEF_GROUP+'�֐��錾��������A�`���K�v�ł��B',[hi_id2tango(group.VarID)]);
    end;
    // �����I�Ȋ֐��̎w�肪���邩�H
    if token.TokenID = token_tilde then
    begin
      hi_func_create(m);
      token := token.NextToken; // SKIP '~'
    end else
      Exit;

    // �֐��̓��e��`�͂Ƃ肠�����X�L�b�v�B�B�B
    if token = nil then
    begin
      NextBlock(token);
      while token <> nil do
      begin
        //�@�Exxx (2)            ...i
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
    //�E{�^=�����l}�֐���(����...)�`��`���e

    token := token.NextToken; // skip '�E'
    if token = nil then Exit;

    // �g�J�b�R������ΏI���܂Ŕ�΂�(1/2)
    if token.TokenID = token_nami_kakko_begin then
    begin
      while token.TokenID <> token_nami_kakko_end do token := token.NextToken;
      token := token.NextToken; // skip nami_kakko_end
    end;

    // �ϐ����̎擾
    vName := token.TokenID;
    token := token.NextToken; // skip NAME
    v := hi_group(group).FindMember(vName);
    if v = nil then raise HException.CreateFmt(ERR_S_DEF_GROUP+'�����o�w%s�x�̒�`�Ɍ�肪����܂��B',[hi_id2tango(group.VarID),hi_id2tango(vName)]);

    // �g�J�b�R������ΏI���܂Ŕ�΂�(2/2)
    if token = nil then Exit;
    if token.TokenID = token_nami_kakko_begin then
    begin
      while token.TokenID <> token_nami_kakko_end do token := token.NextToken;
      token := token.NextToken; // skip nami_kakko_end
    end;
    if token = nil then Exit;
    
    // �Z�b�^�[
    if token.TokenID = token_left then
    begin
      token := token.NextToken; // SKIP <-
      if token = nil then Exit;
      fp := hi_group(group).FindMember(token.TokenID);
      if (fp = nil)or(fp.VType <> varFunc) then raise HException.CreateFmt(ERR_S_DEF_GROUP+'�Z�b�^�[�w%s�x�̒�`���Ȃ����֐��ł͂���܂���B',[hi_id2tango(group.VarID),hi_id2tango(token.TokenID)]);
      v.Setter := fp;
      token := token.NextToken; // SKIP FUNC NAME
      if token = nil then Exit;
    end;
    // �Q�b�^�[
    if token.TokenID = token_right then
    begin
      token := token.NextToken; // SKIP ->
      if token = nil then Exit;
      fp := hi_group(group).FindMember(token.TokenID);
      if (fp = nil)or(fp.VType <> varFunc) then raise HException.CreateFmt(ERR_S_DEF_GROUP+'�Q�b�^�[�w%s�x�̒�`���Ȃ����֐��ł͂���܂���B',[hi_id2tango(group.VarID),hi_id2tango(token.TokenID)]);
      v.Getter := fp;
      token := token.NextToken; // SKIP FUNC NAME
      if token = nil then Exit;
    end;
    // �f�t�H���g
    if token.TokenID = token_default then
    begin
      token := token.NextToken;
      if token = nil then Exit;
    end;

    // �`�܂Ŕ�΂�
    while token <> nil do
    begin
      if token.TokenID <> token_tilde then token := token.NextToken else Break;
    end;

    // ���m�Ȋ֐����e�̎w�������邩�H
    if (token = nil) or (token.TokenID <> token_tilde) then Exit;

    // ���������͊֐��ł���ꍇ�̂݁i����Ɗ֐����e�̓ǂݎ�菈���̊J�n�j

    // ���͊m�F�̂���
    if v.VType <> varFunc then raise HException.Create('�֐��̂͂��Ȃ̂Ɋ֐��ł͂Ȃ��B');

    // �֐����e�̎擾
    node := TSyntaxDefFunction.Create(nil);
    node.FlagGroupMember := True;
    node.DebugInfo := token.DebugInfo;
    node.HiFunc := hi_func(v);
    node.FuncID := v.VarID;
    node.GroupID := group.VarID;

    n    := node.Children;

    defIndent := token.Indent;
    // SKIP '�`'
    if token.TokenID = token_tilde then
      token := token.NextToken // skip TILDE
    else
      raise HException.Create('�O���[�v�̃��\�b�h�Ł`������܂���B');

    // ���[�J���Ɉ�����o�^���Ă���
    HiSystem.GroupScope.PushGroupScope(hi_group(group));
    HiSystem.PushScope;
    try
      // ���[�J���ϐ��̓o�^

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
        raise Exception.Create('�O���[�v���\�b�h�ŃG���[�B'+(e.Message));
      end;
      {
      if token = nil then
      begin
        NextBlock(token);
        if token.Indent > 0 then
        begin
          // ��`���e����Ȃ�ǂ܂Ȃ�
          if (token<>nil)and(token.TokenID=token_mark_nakaten) then
          begin
            ;// ��
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
    // �������������Ă��܂����H
    for i := 0 to hi_func(v).Args.Count - 1 do
    begin
      arg := hi_func(v).Args.Items[i];
      if arg = nil then raise HException.Create('Arg��nil');
    end;
    if hi_func(v).Args = nil then
    begin
      raise HException.Create(hi_id2tango(v.VarID)+'.Args��nil');
    end;
    }
    //
    hi_func(v).FuncType := funcUser;
    hi_func(v).PFunc := node;
    node.SetSyntaxLevel(0);
    // �֐����X�g�ɒǉ�
    HiSystem.DefFuncList.Add(node); // �Ō�ɉ�������悤��
  end;

  procedure copyMember;
  var
    super: PHiValue;
  begin
    while token <> nil do
    begin
      if token.TokenID <> token_plus then
      begin
        raise HException.CreateFmt(ERR_S_DEF_GROUP+'�w���O���[�v���@�{�e�O���[�v�x�Ǝw�肵�Ă��������B',[hi_id2tango(group.VarID)]);
      end;
      token := token.NextToken; // SKIP '+'
      // �p�����O���[�v�̎擾
      super := HiSystem.Namespace.GetVar(token.TokenID);
      super := hi_getLink(super);
      if (super = nil)or(super.VType <> varGroup) then raise HException.CreateFmt(ERR_S_UNDEF_GROUP,[hi_id2tango(token.TokenID)]);
      token := token.NextToken; // skip '�O���[�v��'
      hi_group(group).AddMembers(hi_group(super));
      // �f�t�H���g�̌p��
      if hi_group(super).DefaultValue <> nil then
      begin
        hi_group(group).DefaultValue := hi_group(group).FindMember( hi_group(super).DefaultValue.VarID );
      end;
    end;
  end;

begin
  //todo 2:���O���[�v�̐錾

  // skip '��'
  token := token.NextToken; // skip '��'
  if (token<>nil)and(token.TokenID = token_group) then
  begin
    token := token.NextToken; // skip '�O���[�v'
  end;

  //----------------------------------------------------------------------------
  // �O���[�v�̒�`��[�ǋL]�����
  group := HiSystem.GetVariable(token.TokenID);
  if group = nil then
  begin
    // �O���[�v�̐V�K�쐬
    group := hi_var_new;
    group.Designer := HiSystem.FlagSystem;
    group.VarID := token.TokenID; // set NAME
    hi_group_create(group);
    hi_group(group).HiClassDebug := token.Token; // �f�o�b�O�p�ɖ��O���Z�b�g
    hi_group(group).HiClassNameID := group.VarID; // �O���[�v�����Z�b�g
    HiSystem.Global.RegistVar(group);
  end else
  begin
    // �O���[�v���̈ᔽ���`�F�b�N
    if group.VType <> varGroup then
    begin
      raise HException.CreateFmt('�O���[�v�̐錾�Łu%s�v�̓O���[�v�ȊO�̕ϐ��Ƃ��Ċ��Ɏg���Ă��܂��B',[hi_id2tango(token.TokenID)]);
    end;
    // ����ȊO�ł̓����o��[�ǋL]�����
    hi_group(group).HiClassDebug := token.Token; // �f�o�b�O�p�ɖ��O���Z�b�g
    hi_group(group).HiClassNameID := group.VarID; // �O���[�v�����Z�b�g
  end;
  token := token.NextToken; // skip NAME
  copyMember; // �����o�[�̌p��

  // �Q��
  SonoTokenID := group.VarID;

  if token = nil then NextBlock(token);

  // �O���[�v�����o�[�̓o�^
  mName := hi_var_new;
  mName.VarID := token_name;
  hi_setStr(mName, hi_id2tango(group.VarID));
  hi_group(group).Add(mName);
  tempToken := token;

  //�����o��`�̓_�̕t���Y����`�F�b�N
  if (token.Indent = 0)or(token.Indent <> 0)and(token.TokenID <> token_mark_nakaten) then
  begin
    raise HException.Create('�O���[�v�̐錾�Łu�E�v������܂���B�E�����o{�`}�E�����o�c�����������Đ錾���Ă��������B');
  end;
  memberIndent := token.Indent;

  // �O���[�v�����o�̓o�^
  while token <> nil do
  begin
    if memberIndent = token.Indent then
    begin
      if token.TokenID <> token_mark_nakaten then
      begin
        raise HException.Create('�O���[�v�̐錾�Łu�E�v������܂���B�E�����o{�`}�E�����o�c�̏����Ő錾���Ă��������B');
      end;

      _read_member;

      if token = nil then NextBlock(token);
    end else begin
      Break;
    end;
  end;

  //Writeln(hi_group(group).EnumKeys,'-----');
  // �O���[�v�֐��̓o�^
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
  //DEBUG :�����o�̕\��
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
      // DLL�֐���(Delphi��)�𓾂�
      //funcName := getToken_s(cDec, '(');
      if PosA('(',cDec) = 0 then begin//()���܂�ł��Ȃ����
        funcName := TrimA(getToken_s(cDec, ':'));
        cDec:=':'+cDec ;//�߂�l�ǂݎ��p
        sarg := ''
      end else begin
        // DLL�֐���(Delphi��)�𓾂�
        funcName := TrimA(getToken_s(cDec, '('));
        // �����𓾂�
        sarg := TrimA(getToken_s(cDec, ')'));
        //if UpperCase(sarg) = 'VOID' then sarg := '';
        if sarg = 'VOID' then sarg := '';
      end;

      //--------------
      // �����̐��������`�F�b�N
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
          replace_dll_types(argType); // DLL�C���|�[�g�^�̒P���u��
          //if Pos('/'+argType+'/',accepttypes) = 0 then
          if argType = '' then
            raise HException.Create('DLL�̊֐��錾�ŁA�֐��̈����^�u'+str+'�v�͖���`�ł��B');
          for i := 0 to sl.Count - 1 do
          begin
            // stdcall �̏��Ԃɕ��ׂ�
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
        raise HException.CreateFmt('DLL�u%s�v�̊֐��u%s�v�̐錾�Œ�`���Ă�������̐�����v���܂���B',[dllName, funcName]);

      // : Integer; stdcall;
      // �Ԓl�𓾂�
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
        raise HException.Create('DLL�̊֐��錾�ŁA�֐��̖߂�^�u'+str+'�v�͖���`�ł��B');
    end;

    procedure analizeCDec;
    var
      cnt: Integer;
      p: PAnsiChar;
      str: AnsiString;//for debug
    begin
      // �Ԓl�𓾂�
      ret := UpperCaseA(TrimA(getToken_s(cDec,' ')));
      if (ret = 'FUNCTION')or(ret = 'PROCEDURE') then begin analizeDelphiDoc; Exit; end;
      if PosA('(', ret) > 0 then //�J�b�R������ΕԒl���ȗ�����Ă���Ƃ�������
      begin
        cDec := ret + ' ' + cDec; // ���ɖ߂�
        ret  := 'VOID'; // VOID
      end;
      //ret := Trim(UpperCase(ret));
      str:=ret;
      replace_dll_types(ret);
      //if Pos('/'+ret+'/',acceptTypes) = 0 then
      if ret = '' then
        raise HException.Create('DLL�̊֐��錾�ŁA�֐��̖߂�^�u'+str+'�v�͖���`�ł��B');

      // DLL�֐���(C��)�𓾂�
      funcName := TrimA(getToken_s(cDec, '('));
      if PAnsiChar(funcName)^ = '*' then
      begin
        ret := 'P' + ret;
        System.Delete(funcName, 1, 1);
      end;      

      // �����𓾂�
      sarg := TrimA(getToken_s(cDec, ')'));
      if sarg = 'VOID' then sarg := '';

      // �����̐��������`�F�b�N
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
        replace_dll_types(argType); // DLL�C���|�[�g�^�̒P���u��
        //if Pos('/'+argType+'/',acceptTypes) = 0 then
        if argType = '' then
          raise HException.Create('DLL�̊֐��錾�ŁA�֐��̈����^�u'+str+'�v�͖���`�ł��B');
        // stdcall �̏��Ԃɕ��ׂ�
        res := res + argType + ' ' + argName + ',';
        Inc(cnt);
      end;
      sarg := res;
      if node.HiFunc.Args.Count <> cnt then
        raise HException.CreateFmt('DLL�u%s�v�̊֐��u%s�v�̐錾�Œ�`���Ă�������̐�����v���܂���B',[dllName, funcName]);
    end;

  begin
    //----------------
    // �����̎擾
    // ���O
    if (token = nil) then raise HException.Create('DLL�錾���s���S�ł��B');
    dllName := string(Token.GetConstStr);
    TokenNextToken(token);
    if (token = nil)or(dllName='') then raise HException.Create('DLL�錾���s���S�ł��B');
    // commma
    if (token <> nil) and (token.TokenID = token_comma) then
    begin
      token := token.NextToken;
    end;
    // �錾������
    cDec    := token.GetConstStr;
    token := token.NextToken;
    //----------------
    // �錾�̉��
    analizeCDec; // stdcall �Ăяo���K���ɑ���I
    // DLL�G���g���|�C���g���擾
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
          raise Exception.Create('DLL�u'+dllName+'�v���ǂݍ��߂܂���B�G���[�R�[�h:'+IntToStr(GetLastError));
        end;
      end;
      HiSystem.DllHInstList.AddNum(h);
      HiSystem.DllNameList.Add(dllName);
    end else
    begin
      h := Cardinal(HiSystem.DllHInstList.Items[i]);
    end;
    // DLL���̊֐��ւ̃G���g���|�C���g���擾
    proc := GetProcAddress( h, PAnsiChar(funcName) );
    if proc = nil then raise HException.CreateFmt('DLL�u%s�v�Ɋ֐��u%s�v����������܂���B',[dllName, funcName]);

    // �ϐ��ɐݒ�
    node.HiFunc.PFunc       := proc;
    node.HiFunc.FuncType    := funcDll;
    node.HiFunc.DllRetType  := ret;
    node.HiFunc.DllArgType  := sarg;
  end;

  procedure DLLImport;
  const ErrDll = 'DLL�̃C���|�[�g�G���[�B';
  begin
    Token := Token.NextToken; // skip '='
    if Token = nil then raise HException.Create(ErrDll);
    if Token.UCToken <> 'DLL' then raise HException.Create(ErrDll);
    Token := Token.NextToken; // skip 'DLL'
    if (Token = nil) or (Token.Token <> '(') then raise HException.Create(ErrDll);
    Token := Token.NextToken;
    {DLL�̃C���|�[�g} AnalizeDllImport;
    if (Token = nil) or (Token.Token   <> ')') then raise HException.Create(ErrDll);
    Token := Token.NextToken;
  end;

  procedure _defineGroup;
  var oya, ko: PHiValue;
  begin
    // �֐������O���[�v�ɓo�^����
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
      if token = nil then raise HException.Create('�����o��������܂���B');
      while token <> nil do
      begin
        // �G���[�`�F�b�N
        if token.JosiID = josi_wa then raise HException.Create('�֐��錾�Łuxx��xx�v�̌`�ŏ����l�������邱�Ƃ͂ł��܂���B');
        // ���Ȃ玟������
        if token.TokenID = token_right then token := token.NextToken;
        // �q����`����Ă��邩�H
        funcNameToken := token;
        ko := hi_group(oya).FindMember(token.TokenID);
        if ko = nil then
        begin
          ko := hi_var_new;
          ko.VarID := token.TokenID;
          hi_group(oya).Add(ko);
        end;
        // ���ɑ������H
        token := token.NextToken;
        if token = nil then Break;
        // ���ɑ����Ȃ�e�ɂ���
        if (token.JosiID <> -1) or (token.TokenID = token_right) then
        begin
          oya := ko;
          hi_group_create(oya);
        end;
        // ( �� ~ �Ȃ�����̎w��Ȃ̂ŏI���
        if token.TokenID = token_kakko_begin then Break;
        if token.TokenID = token_tilde then Break;
        if token.TokenID = token_eq then raise HException.Create('�֐��Ɂ��ŏ����l�������邱�Ƃ͂ł��܂���B');
      end;
    except on e:Exception do
      raise HException.Create(
        '�O���[�v�t�֐��w'+
        hi_id2tango(funcNameToken.TokenID)+
        '�x�̒�`�Ɏ��s�B' +
        AnsiString(e.Message));
    end;
    tango := ko;
  end;

begin
  // todo 2: ���֐��̐錾��ǂ�
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
  // �O���[�v�����o�̓��I�쐬���H
  if ((token.JosiID <> -1)and(token.JosiID <> josi_towa)) or
     ((token.NextToken <> nil) and (token.TokenID = token_right)) then
  begin
    _defineGroup;
    node.FuncID := funcNameToken.TokenID;
  end else
  // ��ʂ̊֐�
  begin
    // �P��-�֐�-����
    tango := hi_var_new;
    tango.VarID := token.TokenID;
    tango.Designer := HiSystem.FlagSystem;
    node.FuncID := token.TokenID;
    token := token.NextToken; // skip "NAME"
  end;
  // �֐��Ƃ��ĔF��������
  hi_func_create(tango);
  node.HiFunc := tango.ptr;
  node.HiFunc.FuncType := funcUser; // �f�t�H���g ... ��œǂ�Ő錾�������funcDLL�ɂȂ�
  // if (token = nil) then raise HException.CreateFmt(ERR_S_DEF_FUNC,[hi_id2tango(fNameID)]);

  // READ ARG
  if token <> nil then
  begin
    if (token.TokenID = token_kakko_begin)       then getDefArgs(token, node.HiFunc.Args);
    if (token<>nil)and(token.TokenID = token_Eq) then DLLImport;

    // ";"���΂�
    while (token <> nil) and (token.TokenID = token_semicolon) do token := token.NextToken;
    // "~"���΂�
    if (token <> nil) and (token.TokenID = token_tilde) then
    begin // �s���܂ŃX�L�b�v
      while token <> nil do token := token.NextToken;
    end;
    {
    if token <> nil then
      raise HException.CreateFmt(ERR_S_DEF_FUNC+'�֐����ɏ������܂�ł���\��������܂��B',[hi_id2tango(node.FuncID)]);
    }
  end;

  if node.HiFunc.FuncType = funcDll then
  begin
    if not HiSystem.FlagSystemFile then
    begin
      raise HException.Create(ERR_SECURITY + '�댯�ȃt�@�C���A�N�Z�X�̑��ADLL�̃C���|�[�g��������Ă��܂���B');
    end;
    HiSystem.Global.RegistVar(tango);
    FreeAndNil(node);
    Exit; // DLL�ɒ�`�͂Ȃ�
  end;

  // DEFINE
  // ��d��`�̋֎~
  if HiSystem.Namespace.CurSpace.GetVar(tango.VarID) <> nil then
  begin
    raise HException.CreateFmt('�֐��̐錾�Łu%s�v�͎g���Ă��܂��B',[hi_id2tango( tango.VarID )]);
  end;
  if node.FlagGroupMember = False then
  begin
    //HiSystem.Global.RegistVar(tango);
    HiSystem.Namespace.CurSpace.RegistVar(tango);
  end;
  HiSystem.DefFuncList.Add(node);
  THiFunction(tango.ptr).PFunc := node; // ** LINK ��`���e�ւ̃����N

  //------------------------------------
  // �֐��̓��e�����邩�H
  //------------------------------------
  // n := node.Children;
  if token = nil then NextBlock(token);
  if token = nil then Exit;

  // *aaaa (0) defIndet
  //   xxx (2) Token.Indent
  if defIndent < token.Indent then
  begin
    //if node <> nil then node.contents := token;
    SkipBlock(token); // ���̂͌�قǓǂނ̂ł�(ReadDefFunctionContents)
  end;

end;

function THiParser.ReadEach(var token: THimaToken; defIndent: Integer): Boolean;
var
  node: TSyntaxEach;
  n: TSyntaxNode;
  i: Integer;
begin
  // �������e���擾
  node := TSyntaxEach.Create(nil);
  node.FlagLive := True;

  // �Ώۂ����낷(A��B��)
  i := FStack.FindJosi(josi_wo);
  if i < 0 then i := FStack.FindJosi(josi_de);
  if i < 0 then
  begin
    // �����������ȗ����ꂽ�ꍇ
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
  // �C�e���[�^�[�ϐ��𒲂ׂ�
  i := FStack.FindJosi(josi_de);
  if i >= 0 then
  begin
    n := FStack.GetAndDel(i);
    if n is TSyntaxValue then
      node.iVar := n as TSyntaxValue
    else
      raise HException.Create('�w(�ϐ�)��(�������e)�𔽕��x�̏����Ŏw�肵�Ă��������B');
  end;

  //-------------
  node.DebugInfo := node.jouken.DebugInfo;
  n := node.Children;

  // ��������v���O�������擾
  token := token.NextToken; // skip ��������
  if (token <> nil)and(token.TokenID = token_kakko_begin)and(token.NextToken = nil) then raise HException.Create('�w�����x�̒���Ɂw(�x�͎g���܂���B�C���f���g�ō\������\�����܂��B');

  StackPush;
  try
    ReadSyntaxBlock(token, n, defIndent);
  except on e: Exception do
    raise HException.Create('�w�����x�\�����ŃG���[�ł��B' + AnsiString(e.Message));
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
      raise HException.Create('�����\���ŃG���[�B' + e.Message);
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
  // �����̎擾
  //------------------------------------

  // �`����`�܂�(��)
  node.VarTo   := FStack.Pop(josi_made);
  node.VarFrom := FStack.Pop(josi_kara);
  if (node.VarFrom = nil)or(node.VarTo = nil) then raise HException.Create(ERR_SYNTAX+'�w(�ϐ�)��(�J�n�l)����(�I���l)�܂ŌJ��Ԃ��`�x�̏����Ŏw�肵�Ă��������B');

  // ���[�v�J�E���^�̎擾
  // �`�Łb�`��
  node.VarLoop := FStack.Pop(josi_de);
  if node.VarLoop = nil then node.VarLoop := FStack.Pop(josi_wo);

  // �f�o�b�O�����Z�b�g
  node.DebugInfo := node.VarTo.DebugInfo;

  //------------------------------------
  // �J��Ԃ����e���擾
  //------------------------------------
  token := token.NextToken; // SKIP "�J��Ԃ�"
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
      if (token.TokenID = token_kakko_begin)and(token.NextToken = nil) then raise HException.Create('�w�J��Ԃ��x�̒���Ɂw(�x�͎g���܂���B�C���f���g�ō\������\�����܂��B');
      ReadLineEx(token, n);
    end;
    }
  except on e: Exception do
    raise Exception.Create('�w�J��Ԃ��x�\���ŃG���[�B' + e.Message);
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
    // ���� ( ������Έ����Ȃ̂ň������擾
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

    // FStack ����������擾���� SyntaxFunc �̃X�^�b�N�ɏ悹��
    if HiFunc.Args = nil then
    begin
      raise HException.Create(hi_id2tango(SyntaxFunc.FuncID));
    end;
    for i := HiFunc.Args.Count - 1 downto 0 do
    begin
      // �����̓X�^�b�N�̃g�b�v����POP����̂���{�����A�����̔ԍ��ɂ���ď���������ւ��
      arg := HiFunc.Args.Items[i];
      if UseJosi = True then // �����𔻕ʂ��Ĉ����̏��Ԃ����߂�
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

      end else // �����̏��Ԃ��l�����Ȃ�
      begin

        flag := (FStack.Count > 0);
        if flag then
          SyntaxFunc.Stack.Items[i] := FStack.Pop
        else
          SyntaxFunc.Stack.Items[i] := nil;

      end;

      // �����擾�̃`�F�b�N
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
  //todo 2:���֐��̓ǂݍ���
  Result := False;
  if v.VType <> varFunc then Exit;
  HiFunc := v.ptr;

  // Node �̍쐬
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

  // �֐����̌�ɂ���w�H�x������
  if token <> nil then
  if token.TokenID = token_question then token := token.NextToken;


  // �����̎擾
  get_args;

  // �v���O�C�������p������ID���`�F�b�N
  if (SyntaxFunc.HiFunc.PluginID >= 0)or(SyntaxFunc.HiFunc.IzonFiles <> '') then
  begin
    HiSystem.plugins.ChangeUsed(
      SyntaxFunc.FuncID,
      SyntaxFunc.HiFunc.PluginID, True,
      '', //hi_id2tango(SyntaxFunc.FuncID) // �֐�������������
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
  // (POP) �Ȃ�� or �łȂ����
  n := FStack.Pop;
  node := TSyntaxIf.Create(nil);
  node.FlagLive := True;
  node.DebugInfo := n.DebugInfo;
  node.Jouken := n;
  node.Reverse := (n.JosiId = josi_denakereba);
  // TRUE ���𓾂�
  StackPush;

  node.TrueNode := TSyntaxSentence.Create(nil);
  n := node.TrueNode.Children;
  try
    ReadSyntaxBlock(token, n, defIndent);
  except on e: Exception do
    raise Exception.Create('�w�����`�Ȃ�΁x�\���̂Ȃ�΃u���b�N�ŃG���[�B' + e.Message);
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
          raise HException.Create('�w�����`�Ȃ�΁x�\���̂Ȃ�΃u���b�N�ŃG���[�B' + e.Message);
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
  // FALSE �������邩
  if token = nil then NextBlock(token);
  if (token <> nil) and (defIndent <= token.Indent) then
  if (token <> nil) and (
        (token.TokenID = token_tagaeba) or (
          (token.TokenID <= 0)and(token.JosiID = josi_denakereba)
        )
      )
  then begin
    StackPush;
    // "�Ⴆ��"���̓ǂݎ��
    TokenNextToken(token); // SKIP "�Ⴆ��"
    node.FalseNode := TSyntaxSentence.Create(nil);
    n := node.FalseNode.Children;
    try
      ReadSyntaxBlock(token, n, defIndent);
    except on e: Exception do
      raise Exception.Create('�w�����`�Ȃ�΁x�\���̈Ⴆ�΃u���b�N�ŃG���[�B' + e.Message);
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
          raise HException.Create('�w�����`�Ȃ�΁x�\���̈Ⴆ�΃u���b�N�ŃG���[�B' + e.Message);
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
  t: THimaToken;
begin
  if token.TokenID <> token_kakko_begin then
  begin
    raise HException.Create('�w�i�x������܂���B');
  end;

  node := TSyntaxSentence.Create(nil);
  node.DebugInfo := token.DebugInfo;
  n := node.Children;

  FPrevToken := token;
  token := token.NextToken; // SKIP '('
  if token = nil then NextBlock(token);

  StackPush;
  try
    // '(' .. ')' ���擾����
    while token <> nil do
    begin
      t := token;
      if token.TokenID = token_kakko_end then Break;
      ReadLine(token, n, False);
      if token = nil then NextBlock(token); // ���s���ׂ��i�j�ɂ��Ή��B
      if t = token then
      begin
        raise EHimaSyntax.Create('�J�b�R���Ή����Ă��܂���B');
      end;
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
  //todo 3:������̓ǂݍ���

  if IsDainyu = True then
  begin
    // ������߂�p�������

    // ���֑������̂�
    n := FStack.Pop(josi_ni);
    if (n = nil) then n := FStack.Pop(josi_he);
    if (n = nil) then raise HException.Create(ERR_SYNTAX + '���ɑ������̂��w�肳��Ă��܂���B');
    if n.ClassType <> TSyntaxValue then raise HException.Create(ERR_SYNTAX + '�萔�ɂ͑���ł��܂���B(�ϐ���)�ɑ���B�̏����ŋL�q���Ă��������B');
    v := n as TSyntaxValue;
    if v.ReadOnly then raise HException.CreateFmt(ERR_SYNTAX + '�萔"%s"�ɂ͑���ł��܂���B',[hi_id2tango(v.VarID)]);

    // "����"���X�V
    if v.Element.NextElement <> nil then
    begin
      if (v.VarID <> token_sono) then SonoTokenID := v.VarID;
    end;

    // �m�[�h��}��
    node := TSyntaxLet.Create(nil);
    node.FlagLive := True;
    node.DebugInfo := v.DebugInfo;
    node.VarID := v.VarID;
    node.VarNode := v;

    // ����������̂�
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
      node.Children.Free;  // Children.Next = wo �ɂ���� Children �� TSyntaxValue �ɂȂ�Ȃ�����
      node.Children := wo; //
    end;

    //----------------------
    FStack.Add(node);
    Result := True;
    Exit;
  end;

  //----------------------------------------------------------------------------
  // "=" "��" ��p�������
  if {(token = nil)or}(FStack.Count = 0) then raise HException.Create(ERR_SYNTAX + '�������l������܂���B');

  // ������ׂ��ϐ����擾
  n := FStack.Pop;
  if n.ClassType <> TSyntaxValue then
  begin
    raise HException.Create(ERR_SYNTAX + '"' + n.DebugStr + '"�ɂ͑���ł��܂���B(�ϐ���)��(�l)�B�̏����ŋL�q���Ă��������B');
  end;
  v := n as TSyntaxValue;
  if v.ReadOnly then raise HException.CreateFmt(ERR_SYNTAX + '�萔"%s"�ɂ͑���ł��܂���B',[hi_id2tango(v.VarID)]);

  // "����"���X�V
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

  // �C�x���g�̑�����H
  if (token = nil) or (token.TokenID = token_tilde) then
  begin
    if token <> nil then token := token.NextToken; // SKIP "~"
    node.IsEvent := True;
    //------------------------------
    // �C�x���g�̏����ɂ���
    //------------------------------
    // �C�x���g�͂��̌�ɐ錾����I�u�W�F�N�g���o�Ă���̂�
    // ����`�ɂ��ϐ������N�G���[���N����
    // �����ŃC�x���g�̓C�x���g�̎��s���ɓǂݒ������Ƃɂ���
    //-----------------------------
    // �\�[�X�ւ̃����N�����
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

  // �l���擾
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

  // �w�����܂Łx�\���̃`�F�b�N
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
        raise HException.CreateFmt('�w�����܂�%s�x�Ŗ������ꂽ�\���́w�����܂�%s�x�ł���ׂ��ł��B',
          [hi_id2tango(token.TokenID), hi_id2tango(w)]);
      end else
      begin
        if token <> nil then token := token.NextToken;
      end;
    end else
    begin
      token := tmp; // �����܂ł��Ȃ������̂Ō��ɖ߂�
      FNextBlock := tmpBlock;
    end;
  end;

begin
  if token = nil then Exit;

  CheckToken := token;
  lastToken  := nil;
  FReadFlag.CanLet := CanLet; // ������\���ǂ���

  StackPush;
  flagMosi := False;
  try
  try

    //todo 2: ����s�ǂ�
    curIndent := token.Indent;
    while token <> nil do
    begin
      if curIndent <> token.Indent then Break; // ���̍s�Ɉڂ���
      if token.TokenID = token_kakko_end then Break; // ')' �Ȃ�s����
      if token.TokenID = token_tagaeba   then Break; // '�Ⴆ��'�Ȃ甲��
      if token.TokenID = token_semicolon then begin token := token.NextToken; Break; end;

      // ���܂ł������ꏊ��ǂ�ł���ꍇ�̑΍�
      if lastToken <> nil then
      begin
        if lastToken = token then
        begin
          raise HException.Create('�p�[�X�G���[�B�P��u'+hi_id2tango(token.TokenID)+'�v���ǂ߂܂���B');
        end;
      end;
      lastToken := token;

      // ',' �͂��炩���߃X�L�b�v�����Ă���
      if token.TokenID = token_comma then
      begin
        FPrevToken := token;
        token := token.NextToken;
      end;

      // �ϐ��̐錾(�`�Ƃ́j
      if token.JosiID = josi_towa then
      begin
        RegistVar(token);
        //StackToNode(cnode);// �m�[�h�̏��Ԃ�ύX���Ȃ��悤�ɂ����Œǉ��B��
        //Continue;
        Break;
      end;

      // ����ȒP�ꂪ����΂��̏�����
      case token.TokenID of
        // �J��Ԃ��ȂǒP���ȏꍇ...
        {��} token_aida:        begin _chk(ReadWhile(token, CheckToken.Indent),token_aida); Break; end;
        {��} token_loop:        begin _chk(ReadWhile(token, CheckToken.Indent),token_loop); Break; end;
        {��} token_kai:         begin _chk(ReadKai  (token, CheckToken.Indent),token_kai);  Break; end;
        {�J} token_kurikaesu:   begin _chk(ReadFor  (token, CheckToken.Indent),token_kurikaesu); Break; end;
        {��} token_hanpuku:     begin _chk(ReadEach (token, CheckToken.Indent),token_hanpuku); Break; end;
        {��} token_err_kansi:   begin _chk(ReadTryExcept(token, CheckToken.Indent),token_err_kansi); Break; end;
        {��} token_joukenbunki: begin _chk(ReadSwitch(token),token_joukenbunki); Break; end;
        // ���G�ȏꍇ...
        {����} token_mosi:
          begin
            TokenNextToken(token); // SKIP "����"
            TokenSkipComma(token);
            flagMosi := True;
            tmp := token;
            if _chk(ReadToNaraba(token),token_mosi) then Break else token := tmp;
          end;
        {���} token_dainyu:
          begin
            if FReadFlag.CanLet then
            begin
              token := token.NextToken; // SKIP "���"
              ReadLet(token, True);
              Break;
            end;
          end;
      end;
      // �w�����܂Łx�\���H
      if (token.TokenID = token_koko)and(token.JosiID = josi_made) then
      begin
        raise HException.Create('�w�����܂Łx������\���Ƒ΂ɂȂ��Ă��܂���B');
      end;
      // GOTO
      if token.TokenID = token_mark_sankaku then
      begin
        ReadDefJumpPoint(token);
        Break;
      end; // �W�����v�|�C���g�̐錾

      //--------------------------------------
      // �P�ǂ�
      try
        if not ReadOneItem(token) then Continue;
      except
        on e: Exception do // ���m�ȍs�ԍ���Ԃ�
          raise EHimaSyntax.Create(
            CheckToken.DebugInfo,
            '�P��̓ǎ�Ɏ��s�B' + AnsiString(e.Message),
            []);
      end;
      //--------------------------------------

      n := FStack.GetLast; // ���邾�����낳�Ȃ�
      if n = nil then Continue;

      // �Ȃ�΁H
      if (n.JosiId = josi_naraba)or(n.JosiId = josi_denakereba) then
      begin
        if _chk(ReadIf(token, CheckToken.Indent), 0) then Break;
      end else
      // ...�ɂ���
      if n.JosiId = josi_nituite then
      begin
        if _chk(ReadWith(token, curIndent), 0) then Break; //�v���O�����̎��s�����̐���
      end;

      // ������H
      if (n.JosiId = josi_wa) then // �����u�́v�ɂ����
      begin
        // �x��
        if (CanLet = False)or(flagMosi = True) then raise HException.Create('(...)�̒���u�����v�\���ł́u�́v���g��������͂ł��܂���B��r����ꍇ�́u=�v���g���܂��B');
        ReadLet(token);
        Break;
      end else
      if ((token<>nil)and(token.TokenID = token_Eq)) then // �g�[�N���u=�v�ɂ����
      begin
        if (flagMosi = True)or(CanLet = False) then Continue;
        token := token.NextToken;// SKIP '='
        ReadLet(token);
        Break;
      end;

    end;//of while

    // �������̃X�^�b�N���Ȃ����c����`�F�b�N
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
        // �Ō�̂P�����͋������...�߂�l�̉\�������邩��
        if not((FStack.GetLast.FlagLive = False)and(cnt=1))then // ��O����
        begin
          if nn <> nil then begin
            raise EHimaSyntax.Create(
              nn.DebugInfo, '�L�q�~�X������܂��B�v���O�������������Ă��������B%d�̌�傪���Ӗ��ł��B���߂̖���`�A�v���O�C���s���̉\��������܂��B' +
              '(�u%s�v�����u%s�v)',[cnt, nn.DebugStr, HiSystem.JosiList.ID2Str(nn.JosiId)]);
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
  // �ǂݎc����";"�Ȃ�΃X�L�b�v
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
  if FStack.Count = 0 then raise HException.Create(ERR_SYNTAX+'�w(��)��`�x�̏����Ŏg���܂��B');

  n := FStack.Pop; // ��

  node := TSyntaxLoop.Create(nil);
  node.DebugInfo := n.DebugInfo;
  node.FlagLive := True;
  
  node.Kaisu := n;
  token := token.NextToken; // SKIP "��"

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
      if (token.TokenID = token_kakko_begin)and(token.NextToken = nil) then raise HException.Create('�wn��x�̒���Ɂw(�x�͎g���܂���B�C���f���g�ō\������\�����܂��B');
      ReadLineEx(token, c);
    end;
    }
  except on e: Exception do
    raise Exception.Create('�w(��)��`�x�ŃG���[�B'+e.Message);
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

  //todo 2: ���g�[�N����1�ǂ�
  // �����āA FStack �֏悹��
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
  tokenNumber: // ���l�萔�̓ǂݎ��
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
        // ���̒P���ǂޕK�v������
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
      raise HException.CreateFmt('�s���Ȍ��w%s�x�������܂����B',[token.Token]);
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
    // �֐��̐錾�����ǂ�
    token := topToken;
    while token <> nil do
    begin
      // ���̍s���`�F�b�N
      temp := token;
      FNextBlock := token.CheckNextBlock;

      // �s���ɐ錾�����邩�H
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
    // �N���X�̐錾+��`��ǂ�
    token := topToken;
    while token <> nil do
    begin
      // ���̍s���`�F�b�N
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
      // �s���ɐ錾�����邩�H
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
    // �Ⴆ�� -1 �̎��Ȃ�
    if token.TokenID = token_minus then
    begin
      term := TSyntaxTerm.Create(nil);
      token := token.NextToken; // skip '-'
      if not ReadOneItem(token) then raise HException.Create('�ˑR��"-"');
      term.baseNode := FStack.Pop;
      term.mode := termMinus;
      term.JosiId := term.baseNode.JosiId;
      FStack.Add(term);
      Result := True;
    end else
    begin
      raise HException.Create('�ˑR�̉��Z�q"'+ hi_id2tango(token.tokenID)+'"');
    end;
    Exit;
  end;
  
  //============================================================================
  // �v�Z���̃p�[�X
  //============================================================================
  // :::����:::
  //   (1) token ���玮��ǂݎ��AsikiStack�ɐς�
  //   (2) tempStack ���g���� sikiStack ���t�|�[�����h�ɕ��ёւ�
  //   (3) node.Children �ֈڂ�
  //----------------------------------------------------------------------------
  sikiStack := THStack.Create;
  try
    //--------------------------------------------------------------------------
    // (1) ���̓ǂݎ��
    //--------------------------------------------------------------------------
    // 1�ڂ̒l�� FStack ���� POP
    n := FStack.Pop;
    sikiStack.Push(n);

    node := TSyntaxCalc.Create(nil);
    node.DebugInfo := n.DebugInfo;
    node.JosiId := n.JosiId;
    FStack.Push(node);

    // 2�ڈȍ~�� token ����
    while token <> nil do
    begin
      if token.TokenType <> tokenOperator then Break;
      // ���Z�q�̓ǂݎ��
      sikiStack.Push(getEnzansi(token));
      if token = nil then NextBlock(token); // �s���̉��Z�q�͎��̍s�܂œǂ�

      // -N (���Z�q��ǂ�ł���ɉ��Z�q)�̂Ƃ�
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

      // ���ʂɒl�̓ǂݎ��
      if not ReadOneItem(token) then raise HException.Create(ERR_INVALID_SIKI);
      n := FStack.Pop;
      node.JosiId := n.JosiId;
      sikiStack.Push(n);
    end;
    //--------------------------------------------------------------------------
    // (2) ������ёւ���
    //--------------------------------------------------------------------------
    infix2rpolish(sikiStack);

    //--------------------------------------------------------------------------
    // (3) �ڂ��ς�
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
    // ���̗v�f�ւ̃����N�����
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
    if HiSystem.FlagStrict then Exit; // ���K������Ă���Ȃ�ȉ��̃`�F�b�N�͕s�v

    // ���ʂ̏����ŕϐ����������������Ȃ�Ώ����͕s�v
    if token.JosiID = josi_wa then Exit;
    if (token.NextToken <> nil)and(token.NextToken.TokenID = token_eq) then Exit;

    // �܂��A��������ǂ������d�v
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
      // �������Ȃ���ΏI���
      if (p.JosiID = josi_naraba)or(p.JosiID = josi_denakereba) then Break;
      if p.JosiID = -1 then Break;
      TokenNextToken(p);
      TokenSkipComma(p);
    end;
    // ��������H
    if flagLet = False then Exit;

    // ����q���ɃO���[�v������Ă���
    hi_group_create(root);
    oya := root;
    //
    p := token; // ��ԏ��߂ɖ߂��Ă͂��߂̗v�f
    TokenNextToken(p);
    while p <> nil do
    begin
      if p.TokenID = token_eq then Break;

      // �q�̒ǉ�
      ko := hi_group(oya).FindMember(p.TokenID);
      if ko = nil then
      begin
        ko := hi_var_new;
        ko.VarID := p.TokenID;
        hi_group(oya).Add(ko);
      end;
      if p.JosiID = josi_wa then Break;
      if (p.NextToken <> nil)and(p.NextToken.TokenID = token_eq) then Break;

      // �q���e�ɂȂ�
      oya := ko;
      hi_group_create(oya);
      TokenNextToken(p);
      TokenSkipComma(p);
    end;
  end;

  // xx�Ƃ�oo = vv �̐V�K�^�𐶐�����
  function _newGroupVar: Boolean;
  var
    p: THimaToken;
    flagTowa: Boolean;
    oya, ko, def, con, vv: PHiValue;
    vType: THiVType;
    sf: TSyntaxFunction; sv: TSyntaxValue; n: TSyntaxNode;
  begin
    // --- ��ǂ݂��� ----------------------------------------------------------
    // ...�Ƃ�...�����邩�H
    Result   := False;
    flagTowa := False;
    vType    := varNil;
    p := token;
    while p <> nil do
    begin
      if p.JosiID = -1 then Break; // "xxx��xxx"�̂悤�ɏ������Ȃ��ꍇ�͔�����
      if p.JosiID = josi_towa then begin flagTowa := True; Break; end;
      if p.TokenID = token_Semicolon then Break;
      TokenNextToken(p);
      TokenSkipComma(p);
    end;
    if not flagTowa then Exit;
    // ---
    // �e�Ȃ��ŕϐ��錾
    if token.JosiID = josi_towa then
    begin
      ko := HiSystem.CreateHiValue(token.TokenID);
      ko.Designer := HiSystem.FlagSystem;
      TokenNextToken(token);
      TokenSkipComma(p);
    end else
    // �e����ŕϐ��錾�i�O���[�v�j
    begin
      ko  := nil;
      oya := HiSystem.GetVariable(token.TokenID);
      if oya = nil then // �e�����
      begin
        oya := HiSystem.CreateHiValue(token.TokenID);
        oya.Designer := HiSystem.FlagSystem;
      end;
      token := token.NextToken;
      while token <> nil do
      begin
        hi_group_create(oya);
        ko := hi_group(oya).FindMember(token.TokenID);
        if ko = nil then // �����o�����
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
        oya := ko; // ����
        TokenNextToken(token);
        TokenSkipComma(p);
      end;
    end;
    if ko = nil then raise HException.Create('�ϐ��錾�Ɏ��s�B');
    if token.TokenID = token_comma then token := token.NextToken;
    if token = nil then raise HException.CreateFmt('�ϐ��錾�Ɏ��s�B�w%s�Ƃ�xxx�x��xxx�����i�ϐ��̌^�j������܂���B',[hi_id2tango(ko.VarID)]);
    // xxx�Ƃ�ooo �� ooo ����
    def := nil;
    while token <> nil do
    begin
      if token.JosiID = -1 then Break;
      def := HiSystem.GetVariable(token.TokenID);
      if def = nil then raise HException.CreateFmt('�ϐ��w%s�x�̐錾�Ō^������ł��܂���B',[hi_id2tango(ko.VarID)]);
      if def.VType <> varGroup then raise HException.CreateFmt('�ϐ��w%s�x�̐錾�Ō^������ł��܂���B',[hi_id2tango(ko.VarID)]);
      TokenNextToken(token);
      TokenSkipComma(p);
      vType := varGroup;
    end;
    // �^�̓���
    if def = nil then
    begin
      if token = nil then raise HException.CreateFmt('�ϐ��w%s�x�̐錾�Ō^������ł��܂���B',[hi_id2tango(ko.VarID)]);
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
            if (def = nil)or(def.VType <> varGroup) then raise HException.CreateFmt('�ϐ��w%s�x�̐錾�Ō^������ł��܂���B',[hi_id2tango(ko.VarID)]);
          end;
      end;
      TokenNextToken(token);
      TokenSkipComma(p);
    end;
    // group �̕���
    if def <> nil then
    begin
      hi_group_create(ko);
      hi_group(ko).Assign(hi_group(def)); // �����o�̕���
      con := hi_group(ko).FindMember(token_tukuru); // �R���X�g���N�^�[�����邩�H
      if (con <> nil)and(con.VType = varFunc) then
      begin
        sf := TSyntaxFunction.Create(nil);
        sf.FDebugFuncName := '��';
        sf.DebugInfo := token.DebugInfo;
        sf.FuncID := token_tukuru; // ���
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
      // �����l���Z�b�g
      if (token <> nil)and(token.TokenID = token_eq) then
      begin
        TokenNextToken(token); // skip '='
        // �����l�Ɍv�Z���܂�ł��Ă��΂�����v�Z����悤�ɁI
        StackPush;
        try
          if ReadOneItem(token) = False then raise HException.Create('�ϐ��錾�ŏ����l������܂���B');
          while (token <> nil) do ReadOneItem(token);
          if FStack.Count > 1 then raise HException.Create('�ϐ��錾�ŏ��������Œl���Q�ȏ㑶�݂��܂��B');
          n := FStack.Pop;
          vv := n.getValue; // �ϐ������󂵂Ă��܂��̂ŕK�� vv �֒l�𓾂Ă��̂��ƃR�s�[���Ȃ���
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
    tmp := token; // �O���[�v ... ���߃��\�b�h�ł͂Ȃ������Ƃ��̂��߂�

    // �O���[�v�̒��オ�����o�ł͂Ȃ������ꍇ
    flg := False;
    // �O���[�v�̒��オ�����o�łȂ��A�O���[�v�������ꍇ�͒����Ɏ��s
    p := HiSystem.GetVariable(token.TokenID);
    if (p<>nil)and(p.VType = varGroup) then Exit;
    // GROUP �����z�����ǂ����m�F
    while token <> nil do
    begin
      // �g�[�N�����W�����v
      token := token.NextToken;
      // ���ׂ�
      if token = nil then Break;
      if token.TokenID = token_semiColon then Break;
      // : ������Ύ��̒P��͔�΂�
      if token.TokenID = token_colon then
      begin
        token := token.NextToken; // skip ":"
        Continue;
      end;
      if token.TokenType <> tokenTango then Continue;
      // = ������΋�؂�Ȃ̂ł���Ȍ�͓ǂ܂Ȃ�
      if token.JosiID = josi_wa then Break;
      if token.TokenID = token_Eq then Break;
      // �wGROUP1��GROUP2��METHOD�x�̏ꍇ�AGROUP2->METHOD��D�悷��̂�
      // �r����GROUP������΁A���̃`�F�b�N�͎��s����
      // METHOD�̈�����ǂ�Ŕ��ʂ��邩�H...���ʂ��Ȃ�
      p := HiSystem.GetVariable(token.TokenID);
      if (p <> nil)and(p.VType = varGroup) then Break;
      // �O���[�v�����o���ǂ����m�F
      p := hi_group(group).FindMember(token.TokenID);
      if p = nil then Continue; // �����o�����݂��Ȃ�...������
      if p.VType <> varFunc then Continue; // �����o�����֐��ł͂Ȃ�...�ꉞ������
      flg := True; Break;
    end;
    if flg = False then
    begin
      token := tmp; // �g�[�N�������̈ʒu�ɖ߂��Ĕ�����
      Exit;
    end;
    // �֐������o�������炻�̂܂܃X�^�b�N�ֈ�����ς�ł���
    token := tmp; flg := False; p := nil;
    while token <> nil do
    begin
      // �ǂ�ŃX�^�b�N�ɐς�
      if ReadOneItem(token) = False then Continue;
      p := hi_group(group).FindMember(token.TokenID);
      // �I������
      if p = nil then Continue;            // �����o�����݂��Ȃ�...������
      if p.VType <> varFunc then Continue; // �����o�����֐��ł͂Ȃ�...�ꉞ������
      flg := True; Break;
    end;
    // �ꉞ�m�F
    if flg = False then raise HException.CreateFmt('�O���[�v�w%s�x�̌�Ƀ����o�����������̂ł����A�������G�����ăX�^�b�N�֐ς߂܂���ł����B���������P���Ȏ��ɂ��Ă��������B',[hi_id2tango(group.VarID)]);
    // ���Ƃ͒ʏ폈���ɖ߂�
    mv := p;
    Result := True;
  end;

begin
  //todo 2:���P��̓ǂݎ��
  Result := True;
  linkType := svLinkGlobal;
  //-------------------------------
  // �O���[�v�ŐV�����ϐ��̐錾���H
  if FReadFlag.CanLet then
  begin
    if _newGroupVar then
    begin
      Result := False; Exit;
    end;
  end;
  //-------------------------------
  // �ϐ����ǂ����m�F����
  //-------------------------------
  // �D��x�̏���(���[�J���ϐ���Group�����o���O���[�o��)

  // ���́H����H
  if (token.TokenID = token_sono)or(token.TokenID = token_kore) then
  begin
    if SonoTokenID = DWORD(-1) then raise HException.Create('�w���́x�w����x�̒l���ݒ肳��Ă��܂���B');
    token.TokenID := SonoTokenID;
  end;

  // ���[�J���ϐ����H
  pv := HiSystem.LocalScope.FindVar(token.TokenID);
  if pv <> nil then linkType := svLinkLocal;

  // Group�����o���H
  if pv = nil then
  begin
    pv := HiSystem.GroupScope.FindMember(token.TokenID);
    if pv <> nil then linkType := svLinkVirtualGroupMember;
  end;

  // �O���[�o���ϐ����H
  if pv = nil then
  begin
    // �l�[���X�y�[�X���l������
    if (token.NextToken <> nil) and (token.NextToken.TokenID = token_Colon) then
    begin
      ns := hi_id2fileno(token.TokenID);
      if token.Token <> '�O���[�o��' then
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

  // �������m�Ȃ�P��Ȃ�ΒP��Ƃ��ēo�^����
  if pv = nil then
  begin
    // �w�ϐ��錾���K�v�x �Ȃ�G���[�ɁB
    if HiSystem.FlagStrict then raise HException.CreateFmt(ERR_S_STRICT_UNDEF,[hi_id2tango(token.TokenID)]);
    // �w�ϐ����������K�v�x�Ȃ������łȂ���΃G���[�ɁB
    if HiSystem.FlagVarInit then
    begin
      if (token.JosiID <> josi_wa)and((token.NextToken = nil)or(token.NextToken.TokenID <> token_Eq)) then raise HException.CreateFmt(ERR_S_VARINIT_UNDEF,[hi_id2tango(token.TokenID)]);
    end;
    // �ϐ��̓o�^(Global�Ƃ���)
    pv := HiSystem.CreateHiValue(token.TokenID);
    // �ϐ��̏����l�͕ϐ����Ƃ���B����ɂ��A�u�v�ň͂�Ȃ�������ł�������肷������B
    hi_setStr(pv, token.Token);
    linkType := svLinkGlobal;
  end;

  // ��������O���[�v�̎����������ǂ����𒲂ׂ�i���̏����ɂ͎��Ԃ������邪�K�v�j
  if FReadFlag.CanLet then
  begin
    _CheckGroupAutoCreate(pv);
  end;
  
  //------------------------------------
  // pv �͊֐����H
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
  // pv �͕ϐ��������Ƃ������ƂŘb�͐i��
  //------------------------------------
  node := TSyntaxValue.Create(nil);
  node.VarID := pv.VarID;
  node.DebugInfo := token.DebugInfo;
  node.JosiId := token.JosiID;
  TokenNextToken(token); // skip VAR_NAME
  node.ReadOnly := (pv.ReadOnly <> 0); // 0 �łȂ���Γǂݎ���p
  // Global or Local
  case linkType of
    svLinkGlobal:
    begin
      node.Element.LinkType := svLinkGlobal;
      node.Element.VarLink  := pv; // �O���[�o���ϐ������̂܂ܓo�^
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
  // ���̑��̗v�f�i�z��E�����o�j�����邩�ǂ������ׂ�
  //---------------------------------------------------
  while token <> nil do
  begin
    tmp := token;
    // comma�𒴂��邩
    if node.JosiId > 0 then
    begin
      TokenSkipComma(token);
    end;
    case token.TokenID of
      //------------------------------------------------------------------------
      // �z��ւ̃����N
      token_kaku_kakko_begin:
      begin
        TokenNextToken(token); // skip "["
        //�v�f�𕡐��ǂ�
        while token <> nil do
        begin
          // ']'�Ȃ�΁A������
          if token.TokenID = token_kaku_kakko_end then Break;

          // ��v�f����
          while token <> nil do
          begin
            // ']'�Ȃ�΁A������
            if token.TokenID = token_kaku_kakko_end then Break;
            // ','�Ȃ�΁A������
            if token.TokenID = token_comma then
            begin
              token := token.NextToken;
              Break;
            end;
            // �J�b�R�̒���ǂ�
            if not ReadOneItem(token) then raise HException.CreateFmt(ERR_S_VAR_ELEMENT,[hi_id2tango(pv.VarID)]);
            while (token<>nil)and(token.TokenType = tokenOperator) do
            begin
              ReadOneItem(token);
            end;
          end;
          // �擾�����v�f��node�ɒǉ�����
          pe := NewPe; //New(pe);
          pe.LinkType := svLinkArray;
          // �ǂ񂾒l���X�^�b�N���牺�낵�C���f�b�N�X�Ƃ���
          pe.aryIndex := FStack.Pop;
          NextElementLink(pe);
        end;
        // �I�[�̃J�b�R���`�F�b�N
        if (token = nil)or(token.TokenID <> token_kaku_kakko_end) then raise HException.Create(ERR_NOPAIR_KAKU);
        node.JosiId := token.JosiId;  // "]"xx
        token := token.NextToken;     // skip "]"
        Continue;
      end;
      //-----------------------------------------
      // �z��Q�ւ̃����N
      token_yen:
      begin
        TokenNextToken(token);// skip "\"
        pe := NewPe; //New(pe);
        pe.LinkType := svLinkArray;
        // �v�f��ǂ�
        if not ReadOneItem(token) then raise HException.CreateFmt(ERR_S_VAR_ELEMENT,[hi_id2tango(pv.VarID)]);
        // �ǂ񂾒l���X�^�b�N���牺�낵�C���f�b�N�X�Ƃ���
        pe.aryIndex := FStack.Pop;
        node.JosiId := pe.aryIndex.JosiId;
        lastJosi := node.JosiId;
        NextElementLink(pe);
        //--------------------------
        // ���̗v�f�����邩
        if lastJosi <> josi_wa then
        while(token <> nil)do
        begin
          if token.TokenID <> token_comma then Break;
          TokenNextToken(token);// skip ","
          pe := NewPe; //New(pe);
          pe.LinkType := svLinkArray;
          // �v�f��ǂ�
          if not ReadOneItem(token) then raise HException.CreateFmt(ERR_S_VAR_ELEMENT,[hi_id2tango(pv.VarID)]);
          // �ǂ񂾒l���X�^�b�N���牺�낵�C���f�b�N�X�Ƃ���
          pe.aryIndex := FStack.Pop;
          node.JosiId := pe.aryIndex.JosiId;
          NextElementLink(pe);
        end;
        Continue;
      end;
      //------------------------------------------------------------------------
      // �n�b�V���ւ̃����N
      token_mark_at:
      begin
        token := token.NextToken; // skip @
        pe := NewPe; //New(pe);
        pe.LinkType := svLinkHash;
        // �n�b�V���̃����o�����P�ǂ�
        if not ReadOneItem(token) then raise HException.CreateFmt(ERR_S_VAR_ELEMENT,[hi_id2tango(pv.VarID)]);
        // �ǂ񂾒l���X�^�b�N���牺�낵�����o���Ƃ���
        pe.aryIndex := FStack.Pop;
        node.JosiId := pe.aryIndex.JosiId;
        NextElementLink(pe);
        Continue;
      end;
      //------------------------------------------------------------------------
      // �� �����O���[�v
      token_right: 
      begin
        token := token.NextToken; // skip ��
        if token = nil then raise HException.Create('�O���[�v�ւ̃A�N�Z�X�q"��"�����邪�����o��������܂���B');
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
        token := token.NextToken; // skip "�����o"
        //----------------------------------------------------------------------
        // �����t�̊֐�?�������ꍇ
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
      // �z��ł��n�b�V���ł��Ȃ���
      else
      begin
        //----------------------------------------------------------------------
        // �O���[�v�Ȃ̂�?
        if pv.VType = varGroup then
        begin
          // �O���[�v�v�f�̓ǂݍ���
          mv := hi_group(pv).FindMember(token.TokenID);
          if mv = nil then
          begin
            // �Öق̃O���[�v�����o��`�����邩�ǂ����H
            if (token.JosiID = josi_wa) or ((token.NextToken <> nil)and(token.NextToken.TokenID = token_eq)) then
            begin
              if HiSystem.FlagStrict then raise HException.CreateFmt(ERR_S_STRICT_UNDEF,[hi_id2tango(token.TokenID)]);
              mv := hi_var_new;
              mv.VarID := token.TokenID;
              hi_group(pv).Add(mv);
            end else
            begin
              //�w(�O���[�v��)��(����)��(����)��(���\�b�h��)����x���ǂ����H
              if _checkBeyondMethod(pv) = False then
              begin
                // node ��ς�Ŕ�����
                FStack.Push(node);
                Exit; // �����o�̑������������́A������
              end;
            end;
          end;
          //�O���[�v�����o���������ꍇ
          node.JosiId := token.JosiID;
          TokenNextToken(token);// skip 'NAME'
          { // ������ɎQ�Ƃ�ύX����悤�ɂ���
          // "����"�ւ̎Q�ƕύX
          SonoTokenID := pv.VarID;
          }
          //
          pe := NewPe; //New(pe);
          pe.LinkType    := svLinkGroup;
          pe.groupMember := mv.VarID; // �O���[�v�ɃA�N�Z�X����Ƃ��͕K�����I
          NextElementLink(pe);
          if mv.VType = varFunc then
          begin
            // �O���[�v���֐�
            funcLink.LinkType  := sfLinkGroupMember;
            funcLink.LinkValue := node;
            ReadFunction(token, mv, funcLink);
            Exit;
          end;
          pv := mv;
          if (node.JosiId = josi_nituite)or(node.JosiId = josi_wa) then Break;
          Continue;
        end else
        // �O���[�v�ł͂Ȃ��ꍇ
        begin
          token := tmp;
          Break;
        end;
      end;
    end;//of case token.TokenID
  end;

  // �Ō�ɁAFStack �֕ϐ���o�^����
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
    // �������P�ǂ�
    if not ReadOneItem(token) then raise HException.Create('�w�����x�̏������ǂݎ��܂���ł����B');
    if (token <> nil) and (token.TokenType = tokenOperator) then
    begin
      if not ReadOneItem(token) then raise HException.Create('�w�����x�̏������ǂݎ��܂���ł����B');
    end;

    A := FStack.GetLast;

    // ...�Ȃ�΂Ȃ甲����
    if (A.JosiId = josi_naraba)or(A.JosiId = josi_denakereba) then Break;

    // A �� B ... �̂Ƃ�
    if (A.JosiId = josi_ga) then
    begin
      if not ReadOneItem(token) then Exit;
      B := FStack.GetLast;
      // �Ȃ��
      if (B.JosiId = josi_naraba)or(B.JosiId = josi_denakereba) then
      begin
        //�w����(A�����݂���)�Ȃ�΁x�̎��͔�����
        if FStack.Count = 1 then Break;

        // = �����
        n := TSyntaxEnzansi.Create(nil);
        n.DebugInfo := B.DebugInfo;
        TSyntaxEnzansi(n).ID := token_Eq;
        setPriority(n);
        B := FStack.Pop;
        FStack.Push(n); // =
        FStack.Push(B); // �v�f
        Break;
      end else
      // �wA �� B ||...�x�̎�
      if ( (token.TokenID = token_or)or(token.TokenID = token_and) ) then
      begin
        // A & B
        n := TSyntaxEnzansi.Create(nil);
        n.DebugInfo := B.DebugInfo;
        TSyntaxEnzansi(n).ID := token_Eq;
        setPriority(n);
        B := FStack.Pop;
        A := FStack.Pop;
        FStack.Push(A); // �v�fA
        FStack.Push(n); // =
        FStack.Push(B); // �v�fB
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
  // �`�F�b�N
  A := FStack.GetLast;
  if (A.JosiId <> josi_naraba)and(A.JosiID <> josi_denakereba) then
  begin
    raise HException.Create(ERR_SYNTAX + '�w����...�Ȃ�΁x�̏����Ɍ�肪���邩�������G�����܂��B');
  end;

  // �X�^�b�N�𒆊ԋL�@����t�|�[�����h�ɕ��ёւ�
  if FStack.Count > 0 then infix2rpolish(FStack);

  // �X�^�b�N��TSyntaxCalc�ɏ悹��
  B := TSyntaxCalc.Create(nil);
  B.DebugInfo := A.DebugInfo;
  StackToNodeChild(FStack, B);
  B.JosiId := A.JosiId;

  // �X�^�b�N��߂�
  StackPop;

  // TSyntaxCalc���X�^�b�N�ɏ悹��
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
  TokenNextToken(token);// skip "�G���[�Ď�"

  //�Ď����𓾂�
  node.NodeTry := TSyntaxSentence.Create(node);
  node.DebugInfo := node.DebugInfo;
  n := node.NodeTry.Children;
  StackPush;
  try
    ReadSyntaxBlock(token, n, defIndent);
  except on e: Exception do
    raise Exception.Create('�w�G���[�Ď��x�\���̊Ď��u���b�N�ŃG���[�B' + e.Message);
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
  if (token = nil)or(token.TokenID <> token_err)or(token.JosiID <> josi_naraba) then raise HException.Create(ERR_SYNTAX + '�w�G���[�Ď��`�G���[�Ȃ�΁`�x�̏����Ŏw�肵�Ă��������B');

  //�G���[�g���b�v�����𓾂�
  node.NodeExcept := TSyntaxSentence.Create(node);
  node.DebugInfo := token.DebugInfo;
  token := token.NextToken; // SKIP "�G���[�Ȃ��"
  n := node.NodeExcept.Children;
  StackPush;
  try
    ReadSyntaxBlock(token, n, defIndent);
  except on e: Exception do
    raise Exception.Create('�w�G���[�Ď��x�\���̃G���[�u���b�N�ŃG���[�B' + e.Message);
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
  if FStack.Count = 0 then raise HException.Create(ERR_SYNTAX+'�w(����)�̊ԁ`�x�̏����Ŏw�肵�Ă��������B');

  node := TSyntaxWhile.Create(nil);
  node.Jouken := FStack.pop;
  node.DebugInfo := node.Jouken.DebugInfo;
  node.FlagLive := True;
  n := node.Children;
  FStack.Push(node);

  token := token.NextToken; // skip '��'

  StackPush;
  try
    // While ���[�v���镶���擾
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
    raise Exception.Create('�w(����)�̊ԁx�\���ŃG���[�B' + e.Message);
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
  // FStack �̒l��ޔ�����
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
  // �\�����̂��߂̃��x�����擾

  // node.Children ��SyntaxNode��ǉ����Ă���
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
  ByRef: -1..1;//-1�Œl�n���A1�ŎQ�Ɠn��
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
      // �����l
      if token.TokenID  = token_question then
      begin
        // �H��nil
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
          // �O���[�v���H
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

  //�Q�Ɠn�����A�l�n�����H
  if ByRef = 1 then
    argByRef := true
  else if ByRef = -1 then
    argByRef := false;

  // �^������
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
    // *�֐���({�C��}�������{����,�������{����...)
    //-------------------------------------
    arg := THimaArg.Create;
    arg.Needed  := True;

    // �ϐ��̏C�������邩�H
    if token.TokenID = token_nami_kakko_begin then // '{'
    begin
      // ����
      try
        getArgType(token, arg.Value, arg.Needed, arg.ByRef);
        arg.VType := arg.Value.VType;
      except
        on e:Exception do
        begin
          raise Exception.Create('�֐��̈����̑�����`�ŃG���[:'+e.Message);
        end;
      end;
    end;
    // �ϐ���
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
    // �g�[�N�����P�����ׂĂ���
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
          raise HException.CreateFmt('�֐��̈����u%s�v�ɃG���[������܂��B', [tmp]);
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
      raise Exception.Create('�֐��̈�����`�ɃG���[������܂��B' + e.Message);
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
  //todo 2: ���Ƃ́��ϐ��̓o�^
  //-------------------------------
  // �����Ƃ͕ʂ� ReadTango �̒��ɂ�__�Ƃ�__�̍\��������̂Œ���
  // ��œ���ł���ƃx�X�g

  // �ϐ��̐���
  // �O���[�o���ł̐錾
  if (not HiSystem.LocalScope.HasLocal)or(IsPreprocess) then
  begin
    IsGlobal := True;
    // �J�����g�l�[���X�y�[�X���m�F����
    // v := HiSystem.Namespace.GetVar(token.TokenID); // --- �����̕ϐ������邩�H
    v := HiSystem.Namespace.CurSpace.GetVar(token.TokenID);
    if v = nil then
    begin
      // �ϐ��̐���
      v := hi_var_new;
      v.Designer := HiSystem.FlagSystem;
      v.VarID := token.TokenID;
      if HiSystem.Global.GetVar(v.VarID) <> nil then
      begin
        if (v.ReadOnly = 1) then
        begin
          raise HException.CreateFmt('�ϐ��̐錾�Łu%s�v�͊��ɒ萔�Ƃ��Đ錾����Ă���̂Ŏg���܂���B',[hi_id2tango(v.VarID)]);
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
  // ���[�J���ł̐錾
  begin
    IsGlobal := False;
    // �ϐ��̐���
    v := hi_var_new;
    v.Designer := HiSystem.FlagSystem;
    v.VarID := token.TokenID;
    //
    HiSystem.Local.RegistVar(v);
    node := TSyntaxCreateVar.Create(nil);
    FStack.Add(node);
    node.DebugInfo := token.DebugInfo;
  end;

  // ���O���΂�
  josiId := token.JosiID;
  token  := token.NextToken;
  if (token = nil) then raise HException.CreateFmt(ERR_S_DEF_VAR,[hi_id2tango(v.VarID)]);
  if token.TokenID = token_comma then token := token.NextToken;

  // �^�C�v�̎擾
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
        // �O���[�v�������̕ϐ�������
        g := HiSystem.Namespace.GetVar(token.TokenID);
        g := hi_getLink(g);
        if g = nil then raise HException.CreateFmt(ERR_S_UNDEFINED,[ hi_id2tango(token.tokenID) ]);

        if g.VType = varGroup then
        begin
          if v.VType <> varGroup then
          begin
            hi_var_copyData(g, v); // ���e���ۂ��ƃR�s�[
            hi_group_create(v);
          end else
          begin
            hi_group(v).AddMembers(hi_group(g));
          end;
          hi_group(v).HiClassInstanceID := v.VarID;
          hi_group(v).HiClassDebug      := hi_id2tango(v.VarID); // FOR DEBUG
          hi_setStr(hi_group(v).FindMember(token_name),hi_id2tango(v.VarID)); // �C���X�^���X�����Z�b�g
          //�Q��
          SonoTokenID := v.VarID;
          // �R���X�g���N�^�[�̋N��
          if IsPreprocess = False then
          begin
            con := hi_group(v).FindMember(token_tukuru);
            if (con <> nil)and(con.VType = varFunc) then
            begin
              sf := TSyntaxFunction.Create(nil);
              sf.FDebugFuncName := '��';
              sf.DebugInfo := token.DebugInfo;
              sf.FuncID := token_tukuru; // ���
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
          hi_var_copyData(g, v); // ���e���ۂ��ƃR�s�[
        end;//of Group
      end;// of else
    end;//of case
    //
    if (token.TokenID <> token_Eq) then token := token.NextToken; // SKIP VAR_TYPE
  end;//of if

  //!A�Ƃ͌^ [= �����l]
  //         ~~~~~~~~~~
  if (token <> nil)and((token.TokenID = token_Eq)or(josiId = josi_wa)) then
  begin
    if token.TokenID = token_eq then token := token.NextToken; // skip "="
    //if (token = nil)or(token.TokenType <> tokenTango) then raise HException.CreateFmt(ERR_S_DEF_VAR,[hi_id2tango(v.VarID)]);

    //--------------------------------------------------------------------------
    // �����l�̎擾
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

    // �����l�Ɍv�Z���܂�ł��Ă��΂�����v�Z����悤�ɁI
    StackPush;
    try
      if ReadOneItem(token) = False then raise HException.Create('�ϐ��錾�ŏ����l������܂���B');
      while (token <> nil) do // �ǂ�ǂ�ǂ�
      begin
        if (token.TokenID = token_Semicolon) then Break; // �Z�~�R�����Ȃ甲����
        ReadOneItem(token);
      end;
      if FStack.Count > 1 then raise HException.Create('�ϐ��錾�ŏ��������Œl���Q�ȏ㑶�݂��܂��B');
      n := FStack.Pop;
      // �O���[�o���Ȃ�A�]�����Ă���B���[�J���Ȃ�\�����悹��
      if IsGlobal then
      begin
        vv := n.getValue; // �ϐ������󂵂Ă��܂��̂ŕK�� vv �֒l�𓾂Ă��̂��ƃR�s�[���Ȃ���
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
      // ���[�J���ϐ��Ȃ̂ō\�����悹��
      begin
        node.InitNode := n;
      end;
    finally
      StackPop;
    end;
    //--------------------------------------------------------------------------
  end;

  // �Z�b�^�[/�Q�b�^�[�����邩�H
  // �Z�b�^�[
  if token <> nil then
  if token.TokenID = token_left then
  begin
    token := token.NextToken; // SKIP <-
    if token <> nil then
    begin
      fp := HiSystem.Global.GetVar(token.TokenID);
      if (fp = nil)or(fp.VType <> varFunc) then raise HException.CreateFmt(ERR_S_DEF_VAR+'�Z�b�^�[�w%s�x�̒�`���Ȃ����֐��ł͂���܂���B',[hi_id2tango(v.VarID),hi_id2tango(token.TokenID)]);
      v.Setter := fp;
      token := token.NextToken; // SKIP FUNC NAME
    end;
  end;
  // �Q�b�^�[
  if token <> nil then
  if token.TokenID = token_right then
  begin
    token := token.NextToken; // SKIP ->
    if token <> nil then
    begin
      fp := HiSystem.Global.GetVar(token.TokenID);
      if (fp = nil)or(fp.VType <> varFunc) then raise HException.CreateFmt(ERR_S_DEF_VAR+'�Z�b�^�[�w%s�x�̒�`���Ȃ����֐��ł͂���܂���B',[hi_id2tango(v.VarID),hi_id2tango(token.TokenID)]);
      v.Getter := fp;
      token := token.NextToken; // SKIP FUNC NAME
    end;
  end;

  // �ǂݎ�葮���̐ݒ�
  if ReadOnly then v.ReadOnly := 1 else v.ReadOnly := 0;

  // �m�[�h�̃e���v���[�g�Ƃ��ēo�^
  if node <> nil then hi_var_copy(v, node.Template);
  if token = nil then NextBlock(token);
end;

function THiParser.ReadOption(var token: THimaToken; IsPreprocess: Boolean; node: TSyntaxNode): Boolean;
begin
  // todo 2:�����s�I�v�V����
  Result := False;
  if token.TokenID <> token_mark_option then Exit;
  token := token.NextToken; // SKIP '!'

  // �ϐ��錾���K�v���ǂ���
  if token.TokenID = token_hensuu_sengen then
  begin
    token := token.NextToken; // SKIP '�ϐ��錾'
    HiSystem.FlagVarInit := False; // �ǂ��炩�̃I�v�V���������g���Ȃ�
    if token = nil then raise HException.Create('�w!�ϐ��錾�x�I�v�V�������s���S�ł��B�K�v���s�v���w�肵�܂��B');
    case token.TokenID of
      token_hituyou : HiSystem.FlagStrict := True;
      token_huyou   : HiSystem.FlagStrict := False;
      token_system  : HiSystem.FlagSystem := 1;
      token_user    : HiSystem.FlagSystem := 0;
      else raise HException.CreateFmt('�w!�ϐ��錾�x�I�v�V������'+ERR_S_UNDEF_OPTION+'�K�v���s�v���w�肵�܂��B',[hi_id2tango(token.TokenID)]);
    end;
    token := token.NextToken; // SKIP '�K�v'
  end else
  // �ϐ����������K�v
  if token.TokenID = token_hensuu_syokika then
  begin
    token := token.NextToken; // SKIP '�ϐ�������'
    HiSystem.FlagStrict := False; // �ǂ��炩�̃I�v�V���������g���Ȃ�
    if token = nil then raise HException.Create('�w!�ϐ��������x�I�v�V�������s���S�ł��B�K�v���s�v���w�肵�܂��B');
    case token.TokenID of
      token_hituyou : HiSystem.FlagVarInit := True;
      token_huyou   : HiSystem.FlagVarInit := False;
      else raise HException.CreateFmt('�w!�ϐ��������x�I�v�V������'+ERR_S_UNDEF_OPTION+'�K�v���s�v���w�肵�܂��B',[hi_id2tango(token.TokenID)]);
    end;
    token := token.NextToken; // SKIP '�K�v'
  end else
  // �����Ƃ́���
  if (token.JosiID = josi_wa)or(token.JosiID = josi_towa)or((token.NextToken <> nil)and(token.NextToken.TokenID = token_Eq)) then
  begin
    if IsPreprocess then RegistVar(token, IsPreprocess, True)
                    else NextBlock(token);
  end else
  // ��������荞��
  if (token.NextToken <> nil)and(token.NextToken.TokenID = token_include) then
  begin
    if IsPreprocess then ReadInclude(token, node)
                    else NextBlock(token);
  end else
  // �����Ƀl�[���X�y�[�X�ύX
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
  token := token.NextToken; // skip '��������'

  // ��������̎擾
  i := FStack.FindJosi(josi_de);
  if i < 0 then
  begin // �ȗ����ꂽ�ꍇ(����̒l�Ŕ���)
    node.Jouken := nil;
  end else
  begin
    node.Jouken := FStack.GetAndDel(i);
  end;

  // �����̎擾
  if (token <> nil)and(token.TokenID = token_semiColon) then token := token.NextToken;
  if token <> nil then raise HException.Create('�w��������x�\���͒P���ŋL�q�ł��܂���B');
  NextBlock(token);

  // x�ŏ�������     (0)
  //    y�Ȃ��,xxxx (4)
  if (token=nil)or(indent >= token.Indent) then raise HException.Create('�w��������x�\���ł̓C���f���g���������K�v�ł��B');

  // �I����
  sIndent := token.Indent;

  while True do
  begin
    // ���������邩�H
    if (token = nil) or (sIndent <> token.Indent) then Break;
    // ���̑��̏���
    if (sIndent <= token.Indent)and(token.TokenID = token_tagaeba) then
    begin
      token := token.NextToken; // skip '�Ⴆ��'
      node.ElseNode := TSyntaxSentence.Create(node);
      TSyntaxSentence(node.ElseNode).DebugMemo := '��������̈Ⴆ��';
      n := node.ElseNode.Children;

      try
        ReadSyntaxBlock(token, n, sIndent);
      except on e: Exception do
        raise Exception.Create('�w��������x�\���ŃG���[�B'+e.Message);
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
      if not ReadOneItem(token) then raise HException.Create('�w��������x�\���̃C���f���g���x���ɂ���̂ɏ������ǂ߂܂���ł����B');
      scase := TSyntaxSwitchCase.Create;
      scase.Jouken := FStack.Pop;
      if (scase.Jouken.JosiId <> josi_naraba) then raise HException.Create('�w(������)�ŏ�������B(����)�Ȃ��...�x�̏����Ŏw�肵�Ă��������B');
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
        raise Exception.Create('�w��������x�\���̏����ŃG���[�B'+e.Message);
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
    // �C���f���g���u���b�N�ȉ����H
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
  // �֐���
  indent := token.Indent;

  // �O���[�v�֐��������Ȋ֐�������?
  funcNameID := token.TokenID;
  fp := HiSystem.Namespace.GetVar(funcNameID);
  if (fp = nil) then raise HException.CreateFmt(ERR_S_DEF_FUNC,[hi_id2tango(funcNameID)]);

  //---------------------------
  // ���ʂ̊֐��̏ꍇ
  if fp.VType = varFunc then
  begin
    // �֐������X�L�b�v
    token := token.NextToken; // skip FUNC_NAME
    // �֐��錾���X�L�b�v
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
    // �`���X�L�b�v
    if (token <> nil) and (token.TokenID = token_tilde) then token := token.NextToken;
    // ���Ȃ�Ύ��̃u���b�N��
    if (token <> nil) and (token.TokenID = token_eq) then
      NextBlock(token)
    else // ���e�����邩�m�F
    if token = nil then
    begin
      if (FNextBlock <> nil)and(indent >= FNextBlock.Indent) then
      begin
        NextBlock(token); Exit; // ���e���Ȃ�
      end;
    end;
    // DLL�Ȃ瑱����ǂ܂Ȃ�
    if hi_func(fp).FuncType = funcDll then Exit;

    //---
    // �֐����e��ǂ�
    node := hi_func(fp).PFunc;

    HiSystem.PushScope; // ---
    try

      // ���������[�J���ϐ��֓o�^
      for i := 0 to node.HiFunc.Args.Count - 1 do
      begin
        arg := node.HiFunc.Args.Items[i];
        v := hi_var_new;
        hi_var_copy(arg.Value, v); // ���O��
        v.VarID := arg.Name;
        HiSystem.Local.RegistVar(v);
      end;

      n := node.Children;
      //
      ReadSyntaxBlock(token, n, indent);
      //ReadBlocks(token, n);
      // �\���؂̃��x����ݒ�
      node.SetSyntaxLevel(0);

    finally
      HiSystem.PopScope; // ---
    end;
  end else // ���ʂ̊֐��̏ꍇ.�����
  //---------------------------
  // �O���[�v�̏ꍇ
  begin
    // �֐������o����肷��
    group := nil;
    token := token.NextToken;
    while token <> nil do
    begin
      if fp.VType <> varGroup then raise HException.Create('�O���[�v�t�֐��̒�`�Ɏ��s�B');
      group := fp;
      fp := hi_group(fp).FindMember(token.TokenID);
      if (fp = nil) then raise HException.Create('�O���[�v�t�֐��̒�`�Ɏ��s');
      if fp.VType = varFunc then Break;
      funcNameID := token.TokenID;
      //
      token := token.NextToken;
    end;
    if (group = nil)or(fp = nil)or(fp.VType <> varFunc) then raise HException.Create('�O���[�v�t�֐��̒�`�Ɏ��s�B');

    // �֐������X�L�b�v
    token := token.NextToken; // skip FUNC_NAME
    // �֐��錾���X�L�b�v
    if (token <> nil) and (token.TokenID = token_kakko_begin) then
    begin
      while token <> nil do
      begin
        if token.TokenID = token_kakko_end then Break;
        token := token.NextToken;
      end;
      if (token <> nil)and(token.TokenID = token_kakko_end) then token := token.NextToken;
    end;
    // �`���X�L�b�v
    if (token <> nil) and (token.TokenID = token_tilde) then token := token.NextToken;
    // ���Ȃ�Ύ��̃u���b�N��
    if (token <> nil) and (token.TokenID = token_eq) then
      NextBlock(token)
    else // ���e�����邩�m�F
    if token = nil then
    begin
      if (FNextBlock <> nil)and(indent >= FNextBlock.Indent) then
      begin
        NextBlock(token); Exit; // ���e���Ȃ�
      end;
    end;

    // �O���[�v�����o�̓��e��ǂ�
    node := hi_func(fp).PFunc;
    node.GroupID := funcNameID;

    // ���[�J���Ɉ�����o�^���Ă���
    HiSystem.GroupScope.PushGroupScope(hi_group(group));
    HiSystem.PushScope;
    try
      // ���[�J���ϐ��̓o�^
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
      // �\���؂̃��x����ݒ�
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
      //���_���Z
      token_or:     Priority := 10;
      token_and:    Priority := 10;
      //��r
      token_Eq:     Priority := 20;
      token_NotEq:  Priority := 20;
      token_Gt:     Priority := 20;
      token_GtEq:   Priority := 20;
      token_Lt:     Priority := 20;
      token_LtEq:   Priority := 20;
      // SHIFT
      token_ShiftL: Priority := 30;
      token_ShiftR: Priority := 30;
      //�����Z�����Z
      token_plus:   Priority   := 40;
      token_minus:  Priority   := 40;
      token_plus_str: Priority := 40;
      //�ώZ��Z
      token_mul:    Priority := 50;
      token_div:    Priority := 50;
      token_mod:    Priority := 50;
      //�ݏ�
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
  // with VAR �� Var ���O���[�v���ǂ������ׂ�
  pv := n.GetValueNoGetter(False);
  if pv = nil then raise HException.Create('�u�����ɂ��āv�\���ł͐ÓI�ȃO���[�v���w�肷��K�v������܂��B');
  if (pv.VType = varLink) then pv := hi_getLink(pv);
  if (pv.VType <> varGroup) then
  begin
    raise HException.Create('�w'+hi_id2tango(pv.VarID) + '�x�̓O���[�v�ł͂���܂���B�u�����ɂ��āv�\���ł͐ÓI�ȃO���[�v���w�肷��K�v������܂��B');
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
  token := token.NextToken;   // <-- '��荞��'
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
    if token.TokenID = token_Eq then Exit; // ��������珜�O
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
    //1) ���������Ȃ��, xxxx
    //2)    xxx
    //3)    xxx
    //--------------------
    // (1)��ǂ�
    thisBlock := token.Parent;
    while token <> nil do
    begin
      // �u���b�N�������Ȃ�s���܂œǂ�
      if token.Parent = thisBlock then
      begin
        tmpToken := token;
        if token.TokenID = token_tagaeba then Break; // '�Ⴆ��'�Ȃ甲��
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
  // ���O���X�L�b�v
  NextBlock(token);
  // ---
  // �R���e���c�����邩
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
  token := token.NextToken;   // <-- '�l�[���X�y�[�X�ύX'
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
  // skip ��
  if token.TokenID = token_mark_sankaku then
  begin
    TokenNextToken(token);
    if token = nil then raise HException.CreateFmt(ERR_S_SYNTAX,['��']);
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
  Result := '(�萔)' + hi_str(constValue);
end;

destructor TSyntaxConst.Destroy;
begin
  hi_var_free(constValue);
  inherited;
end;

function TSyntaxConst.getValue: PHiValue;
begin
  hi_var_copy(constValue, NodeResult);

  // ������Ȃ�W�J
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
      Result := '�w' + hi_str(constValue) + '�x';
    end;
  else
    raise HException.Create('�O���[�v�萔���`�ł��܂���B');
  end;
end;

{ TSyntaxValue }

procedure TSyntaxValue.CheckGetter(var p: PHiValue);
var
  f: THiFunction; fn: TSyntaxNode;
begin
  if p = nil then Exit;

  // �O���[�v�̃f�t�H���g���l��(p�������N�̏ꍇ���l��)
  if hi_getLink(p).VType = varGroup then
  begin
    FGroupScope := hi_group(p);
    if hi_group(p).DefaultValue <> nil then
    begin
      p := hi_group(p).DefaultValue;
    end;
  end;

  //----------------------------------------------------------------------------
  // �ϐ����̂� varFunc �C�x���g or Getter ���C�x���g�Ȃ���s
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
  Result := '(�ϐ�)' + hi_id2tango(VarID);
end;

destructor TSyntaxValue.Destroy;
begin
  // �����N��̊J��
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
  //todo 3: ���ϐ������N�̎擾
  //----------------------------------------------------------------------------
  // �ꎟ�擾
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
  // �v�f�E�񎟎擾
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
          if Result.VType = varGroup then // �O���[�v�̓��I�A�N�Z�X
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
            s   := hi_str(pe.aryIndex.getValue); // s = '' �ł��l��Ԃ��d�l
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
          //if group = nil then Break;//�����ăG���[���o���������V���v��
          FGroupScope := hi_group(group);
          Result := hi_group(group).FindMember(pe.groupMember);
          //--- �֐��̏ꍇ������
          if pe.Stack <> nil then
          begin
            if Result.VType <> varFunc then raise HException.Create('�w'+hi_id2tango(pe.groupMember)+'�x�͊֐��ł͂Ȃ��̂Ɉ���������܂��B');
            Result := HiSystem.RunGroupMethod(group, Result, pe.Stack);
          end;
          //---
          pe := pe.NextElement;
        end;
      else
        raise HException.Create('�����N�؂�');
    end;

    {
    //�Q�b�^�[��W�J���Ă悢���ǂ����𔻒肷��
    if pe <> nil then
    begin
      //����������΃Z�b�^�[�Q�b�^�[��W�J���Ēl�𓾂�K�v������
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
  //todo 3: ���ϐ������N�̎擾
  //----------------------------------------------------------------------------
  // �ꎟ�擾
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
  // �v�f�E�񎟎擾
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
        raise HException.Create('�����N�؂�');
    end;
  end;
  //----------------------------------------------------------------------------
  Result := Result + #13#10;
end;

function TSyntaxValue.outNadesikoProgram: AnsiString;
var
  pe: TSyntaxValueElement;
begin
  //todo 3: ���ϐ������N�̎擾
  //----------------------------------------------------------------------------
  // �ꎟ�擾
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
  // �v�f�E�񎟎擾
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
          Result := Result + '��' + TrimA(hi_id2tango(pe.groupMember));
          pe := pe.NextElement;
        end;
      else
        raise HException.Create('�����N�؂�');
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
  Result := '(�v�Z��)';
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
  // stack�p�ϐ�
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
      //todo 4: �v�Z��
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
          raise HException.CreateFmt('�v�Z�̎��s(%s)�w%s�x(%s):%s',
            [
              Copy(hi_str(va),1,10),
              hi_id2tango(TSyntaxEnzansi(node).ID),
              Copy(hi_str(vb),1,10),
              e.Message
            ]);
        end;
      end;
      stack[sp] := vc;
      // �X�^�b�N�̌����ӂ���`�F�b�N
      Inc(sp);
      if Length(stack) <= sp then
      begin
        raise HException.Create('�v�Z�����G�����܂��B���𕪊����Ă��������B');
      end;
      if va.Registered = 0 then hi_var_free(va);
      if vb.Registered = 0 then hi_var_free(vb);
    end else
    begin
      // �]�����ăX�^�b�N�֐ς�
      p := node.getValue;
      // �H�ɖ߂�l������|�C���^�ɂȂ��Ă��܂��̂Œl�𕡐�����
      stack[sp] := hi_var_new;
      hi_var_copy(p, stack[sp]);
      if (p <> nil)and(p.Registered = 0) then hi_var_free(p);
      Inc(sp);
    end;
    node := node.Next;
  end;

  // �X�^�b�N�̗]��`�F�b�N
  if sp <> 1 then raise HException.Create(ERR_RUN_CALC);

  // ������������
  hi_var_copy(stack[0], NodeResult);

  // �s�v�ȃ����������?
  va := stack[0];
  if (va <> nil) and (va.Registered = 0) then hi_var_free(va);


  // ���ʂ��Z�b�g
  Result := NodeResult;
end;

function TSyntaxCalc.outLuaProgram: AnsiString;
var
  node: TSyntaxNode;
  va, vb: AnsiString;
  // stack�p�ϐ�
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
      // �]�����ăX�^�b�N�֐ς�
      stack[sp] := node.outNadesikoProgram; Inc(sp);
    end;
    node := node.Next;
  end;

  // �X�^�b�N�̗]��`�F�b�N
  if sp <> 1 then raise HException.Create(ERR_RUN_CALC);
  Result := '(' + TrimA(stack[0]) + ')';
end;

function TSyntaxCalc.outNadesikoProgram: AnsiString;
var
  node: TSyntaxNode;
  va, vb: AnsiString;
  // stack�p�ϐ�
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
      // �]�����ăX�^�b�N�֐ς�
      stack[sp] := node.outNadesikoProgram; Inc(sp);
    end;
    node := node.Next;
  end;

  // �X�^�b�N�̗]��`�F�b�N
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
  Result := '(��)'+DebugMemo;
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
  Result := '(���Z�q)' + hi_id2tango(ID);
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
        raise HException.Create('�֐��̈����̌^���Ⴂ�܂��B');
      end;
    end else
    begin
      Result := n.getValue;
    end;
  end;

  procedure _getDefaultValue;
  begin
    // �l���ȗ����ꂽ�̂Ńf�t�H���g�l���擾
    // �f�t�H���g�l���Q�Ƃ���Ă͍���̂Ŋ��S�R�s�[
    v := hi_var_new;
    hi_var_copyData(arg.Value, v);
    // �ϐ��ɖ��O�����ēo�^
    v.VarID := arg.Name;
    hi_var_ChangeType(v, arg.VType);
    HiSystem.Local.RegistVar(v);
  end;

begin
  // �����ϐ��̐���
  // �X�^�b�N�̍\���؂����s���Ēl�𓾂āA���[�J���ϐ��Ƃ��ēo�^����
  if Stack = nil then Exit;
  
  for i := 0 to Stack.Count - 1 do
  begin
    n := Stack.Items[i];
    arg := HiFunc.Args.Items[i];

    // �������ȗ�����Ă���Ƃ��̏���
    if n = nil then
    begin
      _getDefaultValue;
      Continue;
    end;

    // �����Ƃ��Đς܂ꂽ SyntaxNode �����s���Ēl�𓾂�
    // ���̕��������P��̃��[�J���ϐ����Q�Ƃ���
    if HiSystem.LocalScope.Count > 1{���[�J�������݂���} then
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

    // �����ɏ悹�邽�߂̃R�s�[�𓾂�
    v := makeArgVar(vTmp, arg.ByRef);
    // �^���`�F�b�N
    hi_var_ChangeType(v, arg.VType);

    // �ϐ��ɖ��O�����ēo�^
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
  // �������擾
  ary := getArgStackToArray;

  // �������X�^�b�N�ɏ悹�鏈��
  // �\���̂𗘗p���ăX�^�b�N�ɏ��Ɉ������悹�Ă���

  if HiFunc.DllArg = nil then begin
    HiFunc.DllArg := THimaRecord.Create;
    HiFunc.DllArg.SetDataTypes(HiFunc.DllArgType,true);
    if HiFunc.DllArg.Count > 0 then HiFunc.DllArg.RecordCreate;
  end else
    ;

  for i := HiFunc.Args.Count - 1 downto 0 do
  begin
    // �����ɂ̓����N���n�����̂Ń����N������ۂ̒l�𓾂�
    v := ary.Items[i];
    v := hi_getLink(v);
    if v <> nil then
      HiFunc.DllArg.SetValueIndex(i, v);// �ςޏ��Ԃɒ���
  end;

  //----------------------------------------------------------------------------
  //writeln(rec.DumpMemory);
  //----------------------------------------------------------------------------
  // stdcall �̏ꍇ
  // FUNC(DWORD AA,DWORD BB,DWORD CC) �Ȃ�...
  // �����̃������́AAA AA AA AA BB BB BB BB CC CC CC CC �ƂȂ�悤���B

  size := HiFunc.DllArg.TotalByte;
  //{
  try
    // �X�^�b�N�|�C���^�̐ݒ�
    asm
      sub ESP, size  // �܂��A������ς߂�悤�ɁA�X�^�b�N�|�C���^�̈ʒu��ύX�B
      mov StkP, ESP  // ���̃X�^�b�N�|�C���^�̃A�h���X�𓾂�
    end;
    Move(HiFunc.DllArg.DataPtr^, StkP^, size);

    // �֐��̃R�[��
    func := HiFunc.PFunc;

    // �Ԃ�l�ɂ���ČĂԊ֐����g��������
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
      'P': // �|�C���^�^
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
      else raise HException.Create('DLL�֐��̖߂�l������`�Ȃ̂ŌĂяo���܂���ł����B');
    end;

    // �֐��̌��ʂ���
    if not (HiFunc.DllRetType[1] = 'V') then begin
      Result := hi_var_new;
      if HiFunc.DllRetType = 'PChar' then hi_setStr(Result, resStr)
                                     else
      begin
        case HiFunc.DllRetType[1] of
          'F','R': hi_setFloat(Result,resF);
          'I':     hi_setIntOrFloat(Result,res64);//�o���邾��������
          'Q':
          begin
                   if res64 < 0 then hi_setIntOrFloat(Result,Power(2,64)+res64)
                   else hi_setIntOrFloat(Result,res64);
          end;
          else     hi_setInt(Result, res);
        end;
      end;
    end else
      Result := nil;//VOID�̎��͒l��Ԃ��Ȃ�
    HiFunc.DllArg.RestoreBuffer;
  except on e: Exception do
    raise EHimaRuntime.Create(
      DebugInfo,
      ERR_S_DLL_FUNCTION_EXEC + AnsiString(e.Message),
      [(hi_id2tango(FuncID))]);
  end;
  //}

  //ary.ClearNotFree;//���S�ɃN���A���Ă��܂�Ȃ��̂ŁB
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
  // ���������[�J���ɓo�^����
  //------------------------------
  // ���[�J���X�R�[�v�̐���
  HiSystem.PushRunFlag;
  HiSystem.PushScope;
  try
    // �o�^
    ArgStackToLocalVar;

    // �֐��̎��s
    tmp := HiSystem.FFuncBreakLevel;
    HiSystem.FFuncBreakLevel := HiSystem.FNestCheck;

    // ���s
    n := HiFunc.PFunc;
    n.SyntaxLevel := HiSystem.CurNode.SyntaxLevel; // �C�x���g�Ń��x�������������o�O�΍�
    LastUserFuncID := Self.FuncID;
    HiSystem.RunNode2(n);

    // ����(�ϐ��w����x)���R�s�[
    Result := hi_var_new;
    hi_var_copyGensi(HiSystem.Sore, Result);

    // �߂�
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
  Result := '(�֐�)' + hi_id2tango(FuncID);
end;

destructor TSyntaxFunction.Destroy;
begin
  // SyntaxDefFunction �錾�̕��łŊJ�������
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
    // �ȗ����ꂽ�ꍇ�F�����l�����邩�H
    if arg.Value.VType <> varNil then
    begin
      // �Q�Ɠn��/�l�n���Ɋ֌W�Ȃ��f�[�^���̂��R�s�[���ēn��
      // �ȗ��l���󂳂�Ȃ��悤�ɒ���
      v := hi_var_new;
      hi_var_copyData(arg.Value, v);
      // �����ɖ��O������
      v.VarID := arg.Name;
      // �^���`�F�b�N
      hi_var_ChangeType(v, arg.VType);
      res.Values[i] := v;
    end else
    begin
      // �ȗ����ꂽ�������l�͂Ȃ�
      // ���̂܂� nil ��Ԃ�
      res.Values[i] := nil;
    end;
  end;

  procedure _getGroupValue;
  begin
    if not (n is TSyntaxValue) then raise HException.Create('�w�肳�ꂽ�����̌^�ƍ���Ȃ��^���w�肳��Ă܂��B');
    // �O���[�v���擾
    tmp := TSyntaxValue(n).GetValueNoGetter(False);
    v   := makeArgVar(tmp, True);
    // �����ɖ��O������
    v.VarID := arg.Name;
    // �^���`�F�b�N ... �s�v
    // hi_var_ChangeType(v, arg.VType);
    res.Values[i] := v;
  end;

begin
  res := THiArray.Create;
  res.ForStack := True;

  if Stack = nil then begin Result := res; Exit; end;
  // stack �̒l��z��Ɏ擾
  for i := 0 to Stack.Count - 1 do
  begin
    arg := HiFunc.Args.Items[i];
    n   := Stack.Items[i];

    // �X�^�b�N�ɂ���\���� n �����s�����ʂ� ���� res.Value[i] �ɃR�s�[����

    // (1) �������ȗ�����Ă���Ƃ��̏���
    if n = nil then
    begin
      _getDefaultValue;
      Continue;
    end;

    // (2) ���������s

    // ��O...�O���[�v�������Ɏw�肳��Ă���Ƃ��́A�f�t�H���g�������Q�Ƃ��Ȃ�
    if arg.VType = varGroup then
    begin
      _getGroupValue;
      Continue;
    end;

    // �ʏ�̈����擾
    tmp := HiSystem.RunNode(n);
    // �����ɏ悹�邽�߂ɕϐ��𕡐�����(���̂܂܏悹��ƁA�����J���̂Ƃ��Ƀf�[�^���̂��n������Ă��܂�����)
    v := makeArgVar(tmp, arg.ByRef);

    if (tmp <> nil)and(tmp.Registered = 0)and(arg.ByRef = False) then
    begin
      hi_var_free(tmp);
    end;
    
    // ���O������
    if v <> nil then v.VarID := arg.Name;
    // �^���`�F�b�N
    hi_var_ChangeType(v, arg.VType);
    // �����z��ɑ��
    res.Values[i] := v;

  end;
  Result := res;
end;

function TSyntaxFunction.getValue: PHiValue;
var
  res: PHiValue;
  tempGlobal: THiScope;
begin
  //todo 3:���֐��̎��s

  // �O���[�o���ϐ��l�[���X�y�[�X
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
  // �߂�l�̏���
  if res <> nil then
  begin
    hi_var_copyGensi(res, HiSystem.Sore);
    hi_var_copyGensi(res, NodeResult);
    Result := NodeResult;
    if res.Registered = 0 then hi_var_free(res); // �o�^����ĂȂ���΍폜
  end else
  begin
    hi_var_clear(NodeResult);
    Result := nil;
  end;
  HiSystem.Namespace.CurSpace := tempGlobal;
end;

function TSyntaxFunction.makeArgVar(v: PHiValue; IsRef: Boolean): PHiValue;
begin
  // �����̐���
  // IsRef = �Q�Ɠn�����ǂ���
  if v = nil then begin Result := nil; Exit; end;

  // �Q�Ɠn��
  if IsRef then
  begin
    // �����N�����
    Result := hi_var_new;
    hi_setLink(Result, v);
    Exit;
  end;

  // �l�n��
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
        //���l�n���̏ꍇ�ŁA�����N������
        //�������N�����A�����ɉ������Ă��܂��̂Ń������ᔽ�ƂȂ�
        //�������N�ł͂Ȃ�hi_var_copyGensi()���g��
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

  // �O���[�o���ϐ��l�[���X�y�[�X
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
    raise HException.CreateFmt(ERR_S_FUNCTION_EXEC + '���R��,' + e.Message ,[hi_id2tango(FuncID)]);
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
  Result := '(���)' + hi_id2tango(VarID);
  if VarNode.Element.NextElement <> nil then
  begin
    Result := Result + '�̗v�f';
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
      // ������o�^
      arg := f.Args.Items[0];

      // setter �̈������ĕ]��
      if (arg.VType = varGroup) then
      begin
        pValue := HiSystem.RunNode(Children, True);
      end else
      begin
        pValue := HiSystem.RunNode(Children);
      end;

      HiSystem.PushScope;
      try
        // ���������[�J���ɓo�^
        a := hi_var_new;
        hi_var_copyGensi(pValue, a); // a �ɒl���R�s�[
        // ID
        a.VarID := arg.Name;
        // ���[�J���ɓo�^
        HiSystem.Local.RegistVar(a);
        res := HiSystem.RunNode(fn);
        // ���s���ʂ��v���p�e�B�ɔ��f����
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
        // ������o�^
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
        // ���s
        res := THimaSysFunction(f.PFunc)(ary);
        // ���s���ʂ��v���p�e�B�ɔ��f����
        if res <> nil then hi_var_copyGensi(res, NodeResult) else hi_var_clear(NodeResult);
      finally
        ary.ClearNotFree;
        FreeAndNil(ary);
      end;
    end;

  begin
    //todo: setter
    f  := hi_func(pName.Setter); // �֐�
    fn := f.PFunc;               // ���s��m�[�h

    // �����̃`�F�b�N
    if f.Args.Count <> 1 then raise HException.CreateFmt(ERR_S_DEF_VAR+'�Z�b�^�[�̈����͂P�ɂ��Ă��������B',[hi_id2tango(Self.VarID)]);

    // �O���[�v�����s�H
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
    // ���s���ׂ��\�[�X���\���؂ɕϊ�
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

    // ���ɑ������̂���ɓ���
    pName := VarNode.GetValueNoGetter(True);
    // ���s���ׂ��\�[�X���\���؂ɕϊ�
    // �C�x���g��ϐ��Ɋ��蓖�Ă�
    hi_func_create(pName);
    hi_func(pName).FuncType := funcUser;
    hi_func(pName).PFunc := _parseSN; // *** EVENT NODE
    Exit;
  end;

  // ���ɑ�����邩�H
  pName   := VarNode.GetValueNoGetter(True);
  if pName = nil then raise HException.Create('������ō��ӂ��擾�ł��܂���B');
  if pName.VType = varLink then // �����N�Ȃ�W�J����
  begin
    pName := hi_getLink(pName);
  end;

  // �O���[�v�ւ̑�����H
  if pName.VType = varGroup then
  begin
    if hi_group(pName).DefaultValue <> nil then
    begin
      VarNode.FGroupScope := hi_group(pName);
      pName := hi_group(pName).DefaultValue;
    end;
  end;

  // �Z�b�^�[���H
  if (pName <> nil)and(pName.Setter <> nil) then
  begin
    _subSetter;
    // ����̖߂�l
    Result := nil;
  end else
  // �Ⴆ��............�ʏ�̑��...........................
  begin
    // ������ׂ��l��]��
    pValue := HiSystem.RunNode(Children);
    //
    if pValue = nil then pValue := hi_var_new; // �Ȃ��� nil ���߂��Ă����Ƃ�
    if pName  = nil then
    begin
      raise HException.Create('��������ō��ӂ�nil�ł��B');
    end;
    // ���S�����l��
    // �O���[�v�ɃO���[�v�ȊO�̃��m�������悤�Ƃ���
    if(pName.VType = varGroup)and(pValue.VType <> varGroup)then
    begin
      raise HException.Create('�O���[�v�ɃO���[�v�ȊO�̒l�������悤�Ƃ��܂����B');
    end;

    //-----------------------------------
    // ���ۂ̑������
    //-----------------------------------
    // �z��Ȃǂ�����̂�h�����߁A��x���e��ޔ�����
    // | �R�s�[�̓r���ɁA�E�ӂ���x���������Ă��܂��̂ŁA
    // |   �z�� = �z��[�v�f�ԍ�]
    // | �̂悤�ȏ������s���Ɣz�񂪉��Ă��܂��̂�h������
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
    // ���s���ׂ��\�[�X���\���؂ɕϊ�

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
    // ���ɑ������̂���ɓ���
    Result := SyntaxTab(Self.SyntaxLevel) + TrimA(VarNode.outNadesikoProgram) + '= function()'#13#10;
    // ���s���ׂ��\�[�X���\���؂ɕϊ�
    _parseSN;
    Result := Result + 'end'#13#10;
    Exit;
  end;

  // ���ɑ�����邩�H
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
    // ���s���ׂ��\�[�X���\���؂ɕϊ�

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
    // ���ɑ������̂���ɓ���
    Result := SyntaxTab(Self.SyntaxLevel) + TrimA(VarNode.outNadesikoProgram) + '�́`'#13#10;
    // ���s���ׂ��\�[�X���\���؂ɕϊ�
    _parseSN;
    Exit;
  end;

  // ���ɑ�����邩�H
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
  Result := '(��)';
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

    // �������[�v�΍�...���Ȃ����邩�ȁH
    if (c > MAX_STACK_COUNT) then
    begin
      HiSystem.Eval2('0.01�b�҂�'); // �K�x��WAIT�����Ċɘa
      c := 0;
    end;

    //<BREAK>
    if HiSystem.BreakType = btBreak then
    begin
      // ���̏�Ńu���[�N�����
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
  Result := SyntaxTab(SyntaxLevel) + TrimA(HiSystem.DebugProgram(jouken)) + '�̊�'#13#10;
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
  Result := '(�Ȃ��)';
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
  Result := Result + '����,' + TrimA(HiSystem.DebugProgram( Jouken ));
  if Reverse then Result := Result + '�łȂ����' else Result := Result + '�Ȃ��';
  Result := Result + #13#10;
  // --
  Result := Result + SyntaxTab(SyntaxLevel+1) + TrimA(HiSystem.DebugProgram(TrueNode)) + #13#10;
  if FalseNode <> nil then
  begin
    Result := Result + SyntaxTab(SyntaxLevel) + '�Ⴆ��'#13#10;
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
    if TrueNode.ClassType = TSyntaxSentence then TSyntaxSentence(TrueNode).DebugMemo := '=�^�̎�';
  end;
  if FalseNode <> nil then
  begin
    FalseNode.Parent := Self;
    FalseNode.SyntaxLevel := Value + 1;
    if FalseNode.ClassType = TSyntaxSentence then TSyntaxSentence(FalseNode).DebugMemo := '=�U�̎�';
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
  Result := '(��)';
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
    // ���̏�Ńu���[�N�����
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
  // ���񃋁[�v����̂��H
  v := kaisu.getValue;
  for i := 1 to hi_int(v) do
  begin
    hi_setInt(HiSystem.kaisu, i);
    try
      HiSystem.RunNode(Children);
    except
      on e:Exception do
      begin
        raise HException.CreateFmt('%d��ڂ̎��s��',[i]);
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
      // ���̏�Ńu���[�N�����
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
  Result := SyntaxTab(SyntaxLevel) + TrimA(HiSystem.DebugProgram(kaisu)) + '��'#13#10;
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
  Result := '-(�g�b�v�m�[�h)-';
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
  Result := '# �g�b�v'#13#10;
end;

{ TSyntaxNodeChild }

function TSyntaxNodeChild.DebugStr: AnsiString;
begin
  Result := '-(�q�m�[�h)-';
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
  //Result := '#�q�m�[�h'#13#10;
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
  Result := '(�J��Ԃ�)';
end;

destructor TSyntaxFor.Destroy;
begin
  //todo 5: ���m�̃o�O:FreeAndNil(FOR)
  //�ȉ��̂R�́AFreeAndNil���ׂ������A�R�����g���͂����ƁA
  //�֐����̌J��Ԃ��������s���AHiSystem������������Ƀ����^�C���G���[���o��

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
    // ���̏�Ńu���[�N������
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

  // ���[�v�J�E���^ ... �ȗ�����Ă���΁u����v���J�E���^�[�Ɏg��
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

      //<���s>
      HiSystem.RunNode(Children);
      //</���s>

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
        // ���̏�Ńu���[�N�����
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

      //<���s>
      HiSystem.RunNode(Children);
      //</���s>

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
        // ���̏�Ńu���[�N�����
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
  Result := SyntaxTab(SyntaxLevel) + TrimA(HiSystem.DebugProgram(VarLoop)) + '��' + TrimA(HiSystem.DebugProgram(VarFrom)) + '����';
  Result := Result + TrimA(HiSystem.DebugProgram(VarTo)) + '�܂ŌJ��Ԃ�'#13#10;
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
  Result := '(�G���[�Ď�)';
end;

destructor TSyntaxTryExcept.Destroy;
begin
  FreeAndNil(NodeTry);
  FreeAndNil(NodeExcept);
  inherited;
end;

function TSyntaxTryExcept.getValue: PHiValue;
begin
  // ��O�̃g���b�v�� Delphi �̗�O�@�\�ɔC��������
  try
    Result := HiSystem.RunNode(NodeTry);
  except
    on e: Exception do
    begin
      // ErrFmt(NodeTry.DebugInfo.FileNo, NodeTry.DebugInfo.LineNo, e.Message, []);
      // ... �ꎞ�I�ȃ��b�Z�[�W�ł͂Ȃ��A�S�̂𓾂� ... hi_setStr(HiSystem.Sore, e.Message);
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
    if NodeTry.ClassType = TSyntaxSentence then TSyntaxSentence(NodeTry).DebugMemo := '=�G���[�Ď�';
  end;
  if NodeExcept <> nil then
  begin
    NodeExcept.Parent := Self;
    NodeExcept.SyntaxLevel := Value + 1;
    if NodeExcept.ClassType = TSyntaxSentence then TSyntaxSentence(NodeExcept).DebugMemo := '=�G���[�Ȃ��';
  end;

end;

{ TSyntaxDefFunction }

constructor TSyntaxDefFunction.Create(FParent: TSyntaxNode);
begin
  inherited Create(FParent);
  FuncID  := 0;
  GroupID := 0;
  FlagGroupMember := False;
  HiFunc   := nil; // �R���p�C������Ă���Ȃ�A(HiFunc <> nil)
  //contents := nil;
end;

function TSyntaxDefFunction.DebugStr: AnsiString;
begin
  Result := '(���[�U�[�֐�)' + hi_id2tango(FuncID);
end;

destructor TSyntaxDefFunction.Destroy;
begin
  //HiSystem.HiFunc�ŉ������� -> FreeAndNil(HiFunc);
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
    Result := '��' + hi_id2tango(GroupID) + '��' + hi_id2tango(FuncID);
  end else
  begin
    Result := '��' + hi_id2tango(FuncID);
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
  Result := '(����)';
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

  // ���������s�؂���
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
  // ���ۂ̔�������
  //--------------------------------------------------------------------------
  procedure _repeat;
  begin
    i := 0;
    sore := HiSystem.Sore;

    while True do
    begin
      hi_setInt(HiSystem.kaisu, (i+1));

      //<�C�e���[�^�[�̐ݒ�>
      // �I���������`�F�b�N
      case mode of
        0:// string
        begin
          // ��s�؂���
          _getLine;
          str := p; // �c��
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
      // "����"�̓��e��"�Ώ�"�ɂ��R�s�[
      hi_var_copyData(sore, ptaisyou);
      //-----------------------------------------

      //<���s>
      HiSystem.RunNode(Children);
      Inc(i); // ���[�v��
      //</���s>

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
        // ���̏�Ńu���[�N�����
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
  // �������u���[�N���l��
  //<BREAK>
  if HiSystem.BreakType = btBreak then
  begin
    // ���̏�Ńu���[�N�����
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
  // �����́u�񐔁v�u�Ώہv��ޔ�
  //---------------------------------
  // <����>
  // �Ȃ��� tmpTaosyou:THiValue �́A@tmpTaisyou �ƃL���X�g�ł��Ȃ�
  // ptmpTaisyou �^�� new ���Ȃ��Ƃ��܂����삵�Ȃ��悤��
  // </����>

  tmpKaisu := hi_int(HiSystem.kaisu); // ��

  if (Self.iVar <> nil) then
  begin
    ptmpTaisyou := nil;
    ptaisyou    := TSyntaxValue(iVar).GetValueNoGetter(True); // �Ώۂ̑����
  end else
  begin
    ptmpTaisyou := hi_var_new; // �Ώ�
    hi_var_copyData( hi_getLink(HiSystem.taisyou), ptmpTaisyou);
    ptaisyou := HiSystem.taisyou;
  end;
  //---------------------------------
  // ���������𓾂�
  v := HiSystem.RunNode(jouken);
  v := hi_getLink(v); // �����N�悪�Ԃ��ꂽ�Ȃ烊���N��W�J

  //<�����O�u����>
  case v.VType of

    varStr, varInt, varFloat: // ���n�^
      begin
        str := hi_str(v);
        mode := 0;
        //if Copy(str,1,18) = 'TKTextFileStream::' then // ��O�I�ȃt�@�C���X�g���[��
        if Copy(str,1,11) = '@@@���s��::' then // ��O�I�ȃt�@�C���X�g���[��
        begin
          getToken_s(str, '::');
          tkFile := TKTextFileE.Create(TrimA(str), fmOpenRead);
          if not(tkFile is TKTextFileE) then str := '';
          mode := 2;
        end;
      end;
    varArray:
      begin
        // ����̒l�����Ă����[�v�ł���悤�ɓ��e���R�s�[�B
        ary := THiArray.Create;
        ary.Assign(THiArray(v^.ptr)); // �l��S�ăR�s�[�B
        mode := 1;
      end;
    else
      begin
        str  := hi_str(v);
        mode := 0;
      end;

  end;
  //</�����O�u����>

  try
    // <�J��Ԃ�����>
    _repeat;
    // </�J��Ԃ�����>
  finally
    // <�Еt������>
    case mode of
      1: FreeAndNil(ary);    // �ϐ�����Ń��[�v�����ꍇ
      2:
        begin
          try
            FreeAndNil(tkFile); // TKTextFileStream�����
          except end;
        end;
    end;
    hi_setInt(HiSystem.kaisu, tmpKaisu);            // �񐔂𕜌�
    if Self.iVar = nil then
    begin
      try
        hi_var_copyData(ptmpTaisyou, ptaisyou); // �Ώۂ𕜌�
      except
      end;
      hi_var_free(ptmpTaisyou);                           // �Ώۂ����

    end;
    // </�Еt������>
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
  Result := SyntaxTab(SyntaxLevel) + TrimA(HiSystem.DebugProgram(jouken)) + '�𔽕�'#13#10;
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
  Result := '(�ϐ�����)' + hi_id2tango(Template.VarID);
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
  // ���[�J���� template ��o�^����
  if template <> nil then
  begin
    v := hi_var_new;
    hi_var_copyData(template, v);
    v.VarID := template.VarID;
    HiSystem.Local.RegistVar(v);
  end;
  if (v <> nil)and(InitNode <> nil) then
  begin
    // ����������]�����đ��
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

  Result := SyntaxTab(SyntaxLevel) + hi_id2tango(template.VarID) + '�Ƃ�' + hi_vtype2str(template)+#13#10;
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
  Result := '(��������)';
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

  // �������̎擾
  if Jouken = nil then
  begin
    vJouken := HiSystem.Sore
  end else
  begin
    vJouken := Jouken.getValue;
  end;

  // ���v����I���������邩���ׂ�
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

  // ���v���Ȃ���� Else �����s
  if (FlagAct = False)and(ElseNode <> nil) then
  begin
    HiSystem.RunNode2(ElseNode);
  end;

  // Switch �̌��ʂ�����΃R�s�[
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
  Result := SyntaxTab(SyntaxLevel) + TrimA( HiSystem.DebugProgram(jouken) ) + '�ŏ�������'#13#10;
  for i := 0 to CaseNodes.Count - 1 do
  begin
    c := CaseNodes.Items[i];
    Result := Result + SyntaxTab(SyntaxLevel+1) +  TrimA( HiSystem.DebugProgram(c.Jouken) ) + '�Ȃ��'#13#10;
    Result := Result + HiSystem.DebugProgram(c.Action);
  end;
  if ElseNode <> nil then
  begin
    Result := Result + SyntaxTab(SyntaxLevel+1) + '�Ⴆ��'#13#10;
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
  Action.DebugMemo := '��������̏���';
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
  Result := '(�ɂ���)';
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
  // --- With Var �� Var ���擾
  n := WithVar.GetValueNoGetter(False);
  n := hi_getLink(n);
  if n.VType <> varGroup then raise HException.Create('�w���ɂ��āx�\���ɂ̓O���[�v�����w�肵�Ă��������B');
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
  Result := SyntaxTab(FSyntaxLevel) + TrimA(HiSystem.DebugProgram(WithVar)) + '�ɂ���'#13#10;
  Result := Result + HiSystem.DebugProgram(Children);
end;

{ TSyntaxNamespace }

function TSyntaxNamespace.DebugStr: AnsiString;
begin
  if scopeID >= 0 then
    Result := '(�l�[���X�y�[�X�ύX)' + AnsiString(HimaFileList.Strings[scopeID])
  else
    Result := '(�l�[���X�y�[�X�ύX)' + IntToStrA(scopeID);
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
      '�w' +
      AnsiString(ChangeFileExt(
        string(HimaFileList.Strings[scopeID]),
        ''
      )) +
      '�x�Ƀl�[���X�y�[�X�ύX�B'#13#10
  else
    Result := '�w�V�X�e���x�Ƀl�[���X�y�[�X�ύX�B'#13#10;
end;

{ TSyntaxTerm }

constructor TSyntaxTerm.Create(FParent: TSyntaxNode);
begin
  inherited;
  baseNode := nil;
end;

function TSyntaxTerm.DebugStr: AnsiString;
begin
  Result := '(��) - ' + baseNode.DebugStr;
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
  VarLink     := nil; // ����Ȃ�
  Stack       := nil; //* ������K�v
  aryIndex    := nil; //* ������K�v
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
  Result := '��' + hi_id2tango(NameId) + ';';
end;

function TSyntaxJumpPoint.outNadesikoProgram: AnsiString;
begin
  Result := DebugStr;
end;

end.
