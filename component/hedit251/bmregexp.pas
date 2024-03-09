unit bmRegExp;
{******************************************************************************
�^�C�g��      �F���K�\�����g����������T��/����R���|�[�l���g�Wver0.17
���j�b�g��    �FbmRegExp.pas
�o�[�W����    �Fversion 0.17
���t          �F2001/09/15
����m�F��  �F  Windows 98 + Borland Delphi6 Japanese Personal edition
���          �F  ���� bmonkey �Y��  ggb01164@nifty.ne.jp
�ύX����      �F  0.17    �o�O�C�� 2001/09/15
              �F    �EMP3�̖��p�t����ɋ����Ē��������������[�N�̏C����K�p�B
              �F    �E�����ۂ񂳂�ɋ����Ē��������������[�N�̏C����K�p�B
              �F    �ڍׂ͓�����changelog.html���Q�ƁB
              �F  0.16    ��� ��ʌ��J 1998/03/07
              �F    version 0.15 -> version 0.16
              �F    �ETGrep�ŉp�啶��/�������������������ł��Ȃ������o�O���C���B
              �F    �E�����̃L�����N�^�N���X�w��([��-�]�Ȃ�)�̃o�O���C���B
              �F    �EDelphi3, C++Builder1�ɑΉ�
              �F        �E���j�b�g�t�@�C������RegExp.pas����bmRegExp.pas�ɕύX
              �F        �E�R���p�C���̌������Ȃ����^�`�F�b�N�ɑΉ�
              �F        �EMBUtils.pas���g��Ȃ��悤�ɕύX�B
              �F  0.15B   �o�O�C���ADelphi3�AC++Builder1�Ή�
              �F  0.15    ��ʌ��J
��v�N���X    �F  TGrep, TAWKStr
�p���֌W      �F  TObject

*******************************************************************************
�g�p���@      �F�w���v�t�@�C���ƃT���v���v���W�F�N�g���Q�Ƃ̂���
�⑫����      �F

��`�^        �F

******************************************************************************}

interface

uses
  SysUtils, Classes, Windows, Forms
{$IFDEF DEBUG}
  ,OutLine
{$ENDIF}
  ;

type
{ -========================== ��O�N���X =====================================-}
{TREParser ���o����O�B
 ErrorPos �ɂ���āA���K�\��������̉������ڂŗ�O�������������������B}
  ERegExpParser = class(Exception)
  public
    ErrorPos: Integer;
    constructor Create(const Msg: string; ErrorPosition: Word);
  end;
{-=============================                          ====================-}
{ �Q�o�C�g�����^}
  WChar_t = Word;

{ �Q�o�C�g�����^�ւ̃|�C���^�^}
  PWChar_t = ^WChar_t;

{ WChar_t�^ �Q�Ԃ�̌^}
  DoubleWChar_t = Integer;

{ -====================== �����񑀍�֐� =====================================-}
  {���� �F  �P�U�i����\���������󂯎��A�����ɂ��ĕԂ��B
   ���� �F  WCh: WChar_t;     16�i����\��1�o�C�g���� [0-9a-fA-F]

   �Ԃ�l�F ���펞�F  0 <= result <= 15
            �ُ펞�F  -1}
  function HexWCharToInt(WCh: WChar_t): Integer;

  {���� �F  �W�i����\���������󂯎��A�����ɂ��ĕԂ��B
   ���� �F  WCh: WChar_t;     8�i����\��1�o�C�g���� [0-7]

   �Ԃ�l�F ���펞�F  0 <= result <= 7
            �ُ펞�F  -1}
  function OctWCharToInt(WCh: WChar_t): Integer;

  {���� �F  16�i���\�L�̕������Word�^�̐��l�ɕϊ�����B
  ����  �F  Str: String     �ϊ����̕�����
            Index: Integer  ����Str��Index�Ԗڂ̃o�C�g�ʒu����ϊ����n�߂�B
  ����p�F  ���������o�C�g������Index���C���N�������g�����B
  �Ԃ�l�F  �����񂪕\��Word�^�̒l}
  function HexStrToInt(const Str: String; var Index: Integer): Word;

  {���� �F  �W�i���\�L�̕������Word�^�̐��l�ɕϊ�����B
  ����  �F  Str: String     �ϊ����̕�����
            Index: Integer  ����Str��Index�Ԗڂ̃o�C�g�ʒu����ϊ����n�߂�B
  ����p�F  ���������o�C�g������Index���C���N�������g�����B
  �Ԃ�l�F  �����񂪕\��Word�^�̒l}
  function OctStrToInt(const Str: String; var Index: Integer): Word;

  {���� �F ����Str����P�����ǂݏo���B
  ����  �F ����Str �̒��̈���Index�Ԗڂ̃o�C�g�ʒu����P�������āAIndex�𑝂₷�B
  ����  �F Str:    String;    �Q�o�C�g�����R�[�h���܂�String
           Index:  Integer;   ������ǂݏo���ʒu�̐擪����̃o�C�g��
  �Ԃ�l�F �ǂݏo���� WChar_t�^�̒l
  ����p�F
  ����  �F Index��������̒�����肷�łɒ����ꍇ�͏�� WChType.Null��Ԃ��AIndex�𑝂₳�Ȃ��B
          �܂�AIndex�͍ő�ł� Length(Str)+1 �ł���B}
  function GetWChar(const Str: String;var Index: Integer): WChar_t;

  {�@�\�F GetWChar���\�b�h�ɂ���Đi�� Index���P�������߂�(1�`�Q�o�C�g)
   ���ӁF �k���E�L�����N�^(GetWChar�̕Ԃ�l WChType.Null)��߂����Ƃ͂ł��Ȃ��B}
  procedure UnGetWChar(const Str: String; var Index: Integer);


  {�@�\�F GetWChar��PChar�^�o�[�W����}
  function PCharGetWChar(var pText: PChar): WChar_t;

  {�@�\�F WChar_t�^�̒l��String�^�֕ϊ�����B}
  function WCharToStr(WCh: WChar_t): String;

  {�@�\�F '\' �� ���p���ꂽ�L�����N�^�𓾂�B \n, \t \\ ...
   ���ӁF Index��'\'�̎��̕������w���Ă���Ƃ���B}
  function GetQuotedWChar(const Str: String; var Index: Integer): WChar_t;


  {���� �F  FS:WChar_t����؂蕶���Ƃ��āA�o�C�g�ʒuIndex����n�܂�g�[�N�����P�Ԃ��B
  ����  �F  Str: String
            Index: Integer  ����Str��Index�Ԗڂ̃o�C�g�ʒu����ϊ����n�߂�B
  �Ԃ�l�F  FS�ŋ�؂�ꂽ�A�o�C�g�ʒuIndex����n�܂�g�[�N��}
  function WCharGetToken(const Str: String; var Index: Integer; FS: WChar_t): String;


  {���� �F  ����Str���̃��^�L�����N�^��'\'������B
  ����  �F  Str: String
  �Ԃ�l�F  ���^�L�����N�^�̑O��'\'������Str}
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

  CONST_EMPTY    = $FFFF; {TNFA, TDFA��ԕ\�Łu�������Ȃ��v���Ƃ�\���R�[�h�Ƃ��Ďg��}
  CONST_LINEHEAD = $FFFD; {�������^�L�����N�^'^'��\�������R�[�h�Ƃ��Ďg���B}
  CONST_LINETAIL = $FFFE; {�������^�L�����N�^'$'��\�������R�[�h�Ƃ��Ďg���B}

  REFuzzyWChars: array [0..144] of String =
    ('�`,��,A,a',
     '�a,��,B,b',
     '�b,��,C,c',
     '�c,��,D,d',
     '�d,��,E,e',
     '�e,��,F,f',
     '�f,��,G,g',
     '�g,��,H,h',
     '�h,��,I,i',
     '�i,��,J,j',
     '�j,��,K,k',
     '�k,��,L,l',
     '�l,��,M,m',
     '�m,��,N,n',
     '�n,��,O,o',
     '�o,��,P,p',
     '�p,��,Q,q',
     '�q,��,R,r',
     '�r,��,S,s',
     '�s,��,T,t',
     '�t,��,U,u',
     '�u,��,V,v',
     '�v,��,W,w',
     '�w,��,X,x',
     '�x,��,Y,y',
     '�y,��,Z,z',
     '0,�O,��',
     '1,�P,��,�@,�T,��',
     '2,�Q,��,�A,�U,��',
     '3,�R,�O,�B,�V,�Q',
     '4,�S,�l,�C,�W',
     '5,�T,��,�D,�X,��',
     '6,�U,�Z,�E,�Y',
     '7,�V,��,�F,�Z',
     '8,�W,��,�G,�[',
     '9,�X,��,�H,�\',
     '"�@"," "',
     '!,�I',
     '"""",�h',
     '#,��',
     '$,��',
     '%,��',
     '&,��',
     ''',�f',
     '(,�i',
     '),�j',
     '*,��',
     '+,�{',
     '�[,�`,�,',   { �����L���́A''�k���Ƃ���v������}
     '-,�[,�|,�`,�',
     '�,�E',
     '/,�^',
     ':,�F',
     ';,�G',
     '<,��',
     '=,��',
     '>,��',
     '?,�H',
     '@,��',
     '[,�m,�k',
     '\,��',
     '],�n,�l',
     '^,�O',
     '_,�Q',
     '{,�o',
     '|,�b',
     '},�p',
     '~,�P',
     '",",�,�A,�C',
     '�,.,�B,�D',
     '�u,�w,�',
     '�v,�x,�',
     '��,��,�',
     '��,�K,��,���J,�J�J',
     '��,�M,��,���J,�L�J',
     '��,�O,��,���J,�N�J',
     '��,�Q,��,���J,�P�J',
     '��,�S,��,���J,�R�J',
     '��,�U,��,���J,�T�J',
     '��,�W,��,���J,�V�J,��,�a,��,���J,�`�J',
     '��,�Y,��,�X�J,�X�J,��,�d,��,�J,�c�J',
     '��,�[,��,���J,�Z�J',
     '��,�],��,���J,�\�J',
     '��,�_,��,���J,�^�J',
     '��,�f,��,�āJ,�e�J',
     '��,�h,��,�ƁJ,�g�J',
     '��,�o,��,�́J,�n�J,���@,���J��,�E�J�@,�ާ',
     '��,�r,��,�ЁJ,�q�J,���B,���J��,�E�J�B,�ި',
     '��,�u,��,�ӁJ,�t�J,��,�E�J,���J,��',
     '��,�x,��,�ցJ,�w�J,���F,���J��,�E�J�F,�ު',
     '��,�{,��,�فJ,�z�J,���H,���J��,�E�J�H,�ޫ',
     '��,�p,��,�́K,�n�K',
     '��,�s,��,�ЁK,�q�K',
     '��,�v,��,�ӁK,�t�K',
     '��,�y,��,�ցK,�w�K',
     '��,�|,��,�فK,�z�K',
     '��,�A,�,��,�@,�',
     '��,�C,�,��,�B,�',
     '��,�E,�,��,�D,�',
     '��,�G,�,��,�F,�',
     '��,�I,�,��,�H,�',
     '��,�J,�',
     '��,�L,�',
     '��,�N,�',
     '��,�P,�',
     '��,�R,�',
     '��,�T,�',
     '��,�V,�',
     '��,�X,�',
     '��,�Z,�',
     '��,�\,�',
     '��,�^,�',
     '��,�`,�',
     '��,�c,�,��,�b,�',
     '��,�e,�',
     '��,�g,�',
     '��,�i,�',
     '��,�j,�',
     '��,�k,�',
     '��,�l,�',
     '��,�m,�',
     '��,�n,�',
     '��,�q,�',
     '��,�t,�',
     '��,�w,�',
     '��,�z,�',
     '��,�},�',
     '��,�~,�',
     '��,��,�',
     '��,��,�',
     '��,��,�',
     '��,��,�,��,��,�',
     '��,��,�,��,��,�',
     '��,��,�,��,��,�',
     '��,��,�',
     '��,��,�',
     '��,��,�',
     '��,��,�',
     '��,��,�',
     '��,��,�,����,�E�@,��',
     '��,��,����,�E�B,��',
     '��,��,����,�E�F,��',
     '��,��,�,����,�E�H,��',
     '�,�J',
     '�,�K'); {���_�A�����_�͂��̈ʒu�ɂȂ��� �h���h���h�ށh�ɕϊ�����Ȃ��B}

type
{ -============================= TREScanner Class ==================================-}
  { �����͈̔͂�\���^�B}
  RECharClass_t = record
    case Char of
    #0: (StartChar: WChar_t; EndChar: WChar_t);
    #1: (Chars: DoubleWChar_t);
  end;

const
  CONST_EMPTYCharClass: RECharClass_t = ( StartChar: CONST_EMPTY;
                                          EndChar: CONST_EMPTY);

type

  { RECharClass_t�ւ̃|�C���^�^}
  REpCharClass_t = ^RECharClass_t;

  {�g�[�N���̎�ނ�\���^ }
  REToken_t = ( retk_Char,      {�ʏ�̕���  }
                retk_CharClass, {'[]'�ň͂܂ꂽ�L�����N�^�N���X���K�\���̒���
                                 '-'���g���Ĕ͈͎w�肳�ꂽ�� }
                retk_Union,     { '|'}
                retk_LPar,      { '('}
                retk_RPar,      { ')'}
                retk_Star,      { '*'}
                retk_Plus,      { '+'}
                retk_QMark,     { '?'}
                retk_LBra,      { '['}
                retk_LBraNeg,   { '[�O'}
                retk_RBra,      { ']'}
                retk_Dot,       { '.'}
                retk_LHead,     { '^'}
                retk_LTail,     { '$'}
                retk_End);      { ������̏I��� }

  { REToken_t�̏W���W���^}
  RETokenSet_t = set of REToken_t;

  RESymbol_t = record
    case REToken_t of
      retk_CharClass: (CharClass: RECharClass_t);
      retk_Char:      (WChar: WChar_t);
  end;

{�� �����񂩂�g�[�N����؂�o���N���X}
  TREScanner = class
  private
    FRegExpStr: String;
    FIndex: Integer;
    FToken: REToken_t;
    FSymbol: RESymbol_t;
    FInCharClass: Boolean;
  protected
    procedure SetRegExpStr(RegExpStr: String);

    {���̃g�[�N���𓾂�B}
    function GetTokenStd: REToken_t; virtual;
    {�L�����N�^�N���X���K�\�� "[ ]" �̒��̃g�[�N���𓾂�B}
    function GetTokenCC: REToken_t; virtual;
  public
    constructor Create(Str: String);

    function GetToken: REToken_t;

    {���݂̃g�[�N��}
    property Token: REToken_t read FToken;

    { Token�ɑΉ����镶��[��](Lexeme)
      Token <> retk_CharClass �̂Ƃ� ���݂̃g�[�N���̕����l WChar_t�^
      Token =  retk_CharClass �̂Ƃ���RECharClass_t���R�[�h�^
      ��FToken = retk_LBraNeg�̎��̓u���P�b�g'['�P�����������Ȃ��B}
    property Symbol: RESymbol_t read FSymbol;

    {�����Ώۂ̕�����}
    property RegExpStr: String read FRegExpStr write SetRegExpStr;

    {�C���f�b�N�X
     InputStr�����񒆂Ŏ���GetWChar���\�b�h�ŏ������镶���̃C���f�b�N�X
     �� Symbol�̎��̕������w���Ă��邱�Ƃɒ���}
    property Index: Integer read FIndex;
  end;

{-=============================                          ====================-}
  {�g�[�N���̏����ЂƂ܂Ƃ߂ɂ�������}
  RETokenInfo_t = record
    Token: REToken_t;
    Symbol: RESymbol_t;
    FromIndex: Integer;
    ToIndex: Integer;
  end;

  REpTokenInfo_t = ^RETokenInfo_t;

  {TREPreProcessor�N���X�����Ŏg�p}
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
��  �\���؂��Ǘ�����N���X TREParseTree

�����F  ���Ԑ�(Internal node)�Ɨt(Leaf)�����Ƃ��́A���ꂼ��MakeInternalNode
        ���\�b�h��MakeLeaf���\�b�h���g���B
        �܂��A�\���؂Ƃ͕ʂɁAFNodeList��FLeafList���璆�Ԑ߂Ɨt�փ����N����
        �������Ƃɂ��A�r���ŃG���[���������Ă��K�����������J������B
**************************************************************************}
  { TREParseTree�̐߂̎�ނ�\���^}
  REOperation_t = (reop_Char,     { �������̂��� }
          reop_LHead,   { ���� }
          reop_LTail,   { ���� }
          reop_Concat,  { XY }
          reop_Union,   { X|Y}
          reop_Closure, { X* }
          reop_Empty);  { �� }

  { RENode_t�ւ̃|�C���^�^}
  REpNode_t = ^RENode_t;

  { TREParseTree�̎q�߂ւ̃|�C���^�^}
  REChildren_t = record
    pLeft: REpNode_t;
    pRight: REpNode_t;
  end;

  { TREParseTree�̐�}
  RENode_t = record
    Op: REOperation_t;
    case Char of
    #0: (CharClass: RECharClass_t);
    #1: (Children: REChildren_t);
  end;

{�� �\���؂��Ǘ�����N���X}
  TREParseTree = class
  private
    FpHeadNode: REpNode_t;{�\���؂̒��_�ɂ����}
    FNodeList: TList;   {���Ԑ߂̃��X�g�B}
    FLeafList: TList;   {�t�̃��X�g�B}
  public
    constructor Create;
    destructor Destroy; override;

    {�\���؂̓����߂��쐬�B
      op �̓m�[�h���\�����Z�Aleft�͍��̎q�Aright�͉E�̎q }
    function MakeInternalNode(TheOp: REOperation_t; pLeft, pRight: REpNode_t): REpNode_t;

    {�\���؂̗t���쐬�B
      aStartChar, aEndChar �ŃL�����N�^�N���X��\��}
    function MakeLeaf(aStartChar, aEndChar: WChar_t): REpNode_t;

    {�C�ӂ̈ꕶ����\��'.'���^�L�����N�^�ɑΉ����镔���؂����B
     ��CR LF�������S�ẴL�����N�^��\���t��reop_Union�����\�����Ԑ߂Ō��񂾂���}
    function MakeAnyCharsNode: REpNode_t; virtual;

    {�������^�L�����N�^��\���t���쐬
     �� �t��Ԃ����AMakeInternalNode���g���B}
    function MakeLHeadNode(WChar: WChar_t): REpNode_t;

    {�������^�L�����N�^��\���t���쐬
     �� �t��Ԃ����AMakeInternalNode���g���B}
    function MakeLTailNode(WChar: WChar_t): REpNode_t;

    {������ aStartChar <= aEndChar �̊֌W�𖞂����Ă���Ƃ��ɁAMakeLeaf���Ă�
     ����ȊO�́Anil ��Ԃ��B}
    function Check_and_MakeLeaf(aStartChar, aEndChar: WChar_t):REpNode_t;

    {�t������߂ɕς���B}
    procedure ChangeLeaftoNode(pLeaf, pLeft, pRight: REpNode_t);

    {�S�Ă̗t�����L�����N�^�N���X�͈̔͂����ꂼ��d�����Ȃ��悤�ɕ�������B}
    procedure ForceCharClassUnique;

    {���ׂĂ̐߁i�����߁A�t�j���폜�B}
    procedure DisposeTree;

    {�\���؂̒��_�ɂ����}
    property pHeadNode: REpNode_t read FpHeadNode write FpHeadNode;

    {�����߂̃��X�g}
    property NodeList: TList read FNodeList;
    {�t�̃��X�g}
    property LeafList: TList read FLeafList;
  end;

{-=========================== TREParser Class ===============================-}
{�� ���K�\�����������͂��č\���؂ɂ���p�[�T�[ }
  TREParser = class
  private
    FParseTree: TREParseTree; {���j�b�gParseTre.pas �Œ�`����Ă���\���؃N���X}
    FScanner: TREScanner;         {�g�[�N���Ǘ��N���X}

  protected
    { <regexp>���p�[�X���āA����ꂽ�\���؂�Ԃ��B
      �I�� X|Y ����͂���}
    function Regexp: REpNode_t;

    { <term>���p�[�X���āA����ꂽ�\���؂�Ԃ��B
      �A���w�x����͂���}
    function term: REpNode_t;

    { <factor>���p�[�X���āA����ꂽ�\���؂�Ԃ��B
      �J��Ԃ�X*, X+����͂���}
    function factor: REpNode_t;

    { <primary>���p�[�X���āA����ꂽ�\���؂�Ԃ��B
      �������̂��̂ƁA���ʂŊ���ꂽ���K�\�� (X) ����͂���}
    function primary: REpNode_t;

    { <charclass> ���p�[�X���āA����ꂽ�\���؂�Ԃ��B
      [ abcd] �Ŋ���ꂽ���K�\������͂���}
    function CharacterClass(aParseTree: TREParseTree): REpNode_t;

    { <negative charclass>���p�[�X���āA����ꂽ�\���؂�Ԃ��B
      [^abcd] �Ŋ���ꂽ���K�\������͂���}
    function NegativeCharacterClass: REpNode_t;

  public
    constructor Create(RegExpStr: String);
    destructor Destroy; override;

    {���K�\�����p�[�X����B
      regexp, term, factor, primary, charclass �̊e���\�b�h���g���ċA���~�@
      �ɂ���ĉ�͂���B}
    procedure Run;

    {�\���؂��Ǘ�����I�u�W�F�N�g}
    property ParseTree: TREParseTree read FParseTree;

    {���͕����񂩂�g�[�N����؂�o���I�u�W�F�N�g}
    property Scanner: TREScanner read FScanner;

{$IFDEF DEBUG}
    {�A�E�g���C���E�R���g���[���ɍ\���؂̐}�������o�����\�b�h}
    procedure WriteParseTreeToOutLine(anOutLine: TOutLine);
{$ENDIF}
  end;

{$IFDEF DEBUG}
  function DebugWCharToStr(WChar: WChar_t): String;
{$ENDIF}

{ -============================== TRE_NFA Class ==================================-}
type
  RE_pNFANode_t = ^RE_NFANode_t;

  { NFA��ԕ\�̐�
    RE_NFANode_t �� 1�̂m�e�`��Ԃ��A�L�����N�^�N���X(CharClass)���̕����ɂ��
    �đJ�ڂ���m�e�`��Ԃ̏�Ԕԍ�(TransitTo)���i�[����B
    �P�̂m�e�`��Ԃ֓��͂����L�����N�^�N���X���Ƀ����N�E���X�g���`������}
  RE_NFANode_t = record
    CharClass: RECharClass_t;{ ���� : CharClass.StartChar �` CharClass.EndChar}
    TransitTo: integer;    { �J�ڐ�F FStateList�̃C���f�b�N�X}

    Next: RE_pNFANode_t;      { �����N���X�g�̎���}
  end;

{�� �\���؂���͂���NFA��ԕ\�����N���X}
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
    { �m�[�h�ɔԍ������蓖�Ă�}
    function NumberNode: Integer;

    { NFA��Ԑ� ���P�쐬}
    function MakeNFANode: RE_pNFANode_t;

    { FStateList�ɏ�ԑJ�ڂ�ǉ�����B
      ��� TransFrom �ɑ΂��āAChrClass�̂Ƃ��ɏ�� TransTo �ւ̑J�ڂ�ǉ�����B}
    procedure AddTransition(TransFrom, TransTo: Integer; aCharClass: RECharClass_t);

    { �\���� pTree �ɑ΂��� StateList�𐶐�����
      NFA�̓������entry, �o����way_out�Ƃ��� }
    procedure GenerateStateList(pTree: REpNode_t; entry, way_out: Integer);

    { NFA��ԕ\��j������}
    procedure DisposeStateList;

  public
    constructor Create(Parser: TREParser; LHeadWChar, LTailWChar: WChar_t);
    destructor Destroy;override;

    { �\���� Tree�ɑΉ�����NFA�𐶐�����}
    procedure Run;

    {NFA ��Ԃ̃��X�g}
    property StateList: TList read FStateList;

    {NFA�̏�����Ԃ�FStateList�̃C���f�b�N�X}
    property EntryState: Integer read FEntryState;
    {NFA�̏I����Ԃ�FStateList�̃C���f�b�N�X}
    property ExitState: Integer read FExitState;

    {���K�\�����A�������^�L�����N�^���܂ނ�}
    property RegExpHasLHead: Boolean read FRegExpHasLHead;
    {���K�\�����A�������^�L�����N�^���܂ނ�}
    property RegExpHasLTail: Boolean read FRegExpHasLTail;

    {������\�����^�L�����N�^ '^'�ɗ^���郆�j�[�N�ȃL�����N�^�R�[�h}
    property LHeadWChar: WChar_t read FLHeadWChar write FLHeadWChar;
    {������\�����^�L�����N�^ '$'�ɗ^���郆�j�[�N�ȃL�����N�^�R�[�h}
    property LTailWChar: WChar_t read FLTailWChar write FLTailWChar;

{$IFDEF DEBUG}
    {TStrings�I�u�W�F�N�g�ɁANFA �̓��e����������}
    procedure WriteNFAtoStrings(Strings: TStrings);
{$ENDIF}
  end;

{ -========================== TRE_NFAStateSet Class =============================-}
{�� NFA�̏�ԏW����\���I�u�W�F�N�g
    �����ł̓r�b�g�x�N�^�ŏ�ԏW�����������Ă���B}
  TRE_NFAStateSet = class
  private
    FpArray: PByteArray;
    FCapacity: Integer;
  public
    {�R���X�g���N�^�ɂ́A�ő��Ԑ����w�肷��B}
    constructor Create(StateMax: Integer);
    destructor Destroy; override;

    {�I�u�W�F�N�g�̏W�����AStateIndex���܂ނ��H}
    function Has(StateIndex: Integer): Boolean;
    {�I�u�W�F�N�g�̏W�����AAStateSet�Ɠ����W����Ԃ��H}
    function Equals(AStateSet: TRE_NFAStateSet): Boolean;
    {�I�u�W�F�N�g�̏W����StateIndex���܂߂�B}
    procedure Include(StateIndex: Integer);
    {�I�u�W�F�N�g�����o�C�g�z��ւ̃|�C���^}
    property pArray: PByteArray read FpArray;
    {�I�u�W�F�N�g�����o�C�g�z��̗v�f��}
    property Capacity: Integer read FCapacity;
  end;

{ -============================= TRE_DFA Class ==================================-}
{�� TRE_DFA           NFA��ԕ\����DFA��ԕ\�����N���X
  �R���X�g���N�^ Create �ɁA���K�\����\���m�e�`(�񌈒萫�L���I�[�g�}�g��
  Non-deterministic Finite Automaton)�̏�ԕ\������TRE_NFA���󂯎��A
  �Ή�����c�e�`(���萫�L���I�[�g�}�g��Deterministic Finite Automaton)
  �̏�ԃ��X�g�I�u�W�F�N�g���\�z����TRE_DFA�N���X�B}

  RE_pDFATransNode_t = ^RE_DFATransNode_t;

  {TRE_DFA�̃��\�b�hCompute_Reachable_N_state(DState: PD_state_t): RE_pDFATransNode_t;
  �����̌^�̒l��Ԃ��B
  �L�����N�^�N���X(CharClass)�őJ�ډ\�Ȃm�e�`��ԏW��(ToNFAStateSet)}
  RE_DFATransNode_t = record
    CharClass: RECharClass_t;{Char;}
    ToNFAStateSet: TRE_NFAStateSet;

    next: RE_pDFATransNode_t;{�����N���X�g���`��}
  end;

  RE_pDFAStateSub_t = ^RE_DFAStateSub_t;
  RE_pDFAState_t = ^RE_DFAState_t;

  { RE_DFAState_t�ɂ���Ďg�p�����
  �L�����N�^�N���X(CharClass)�ɂ����DFA���(TransitTo) �֑J�ڂ���B}
  RE_DFAStateSub_t = record
    CharClass: RECharClass_t;
    TransitTo: RE_pDFAState_t; {CharClass�͈͓��̕����� DFA ��� TransitTo��}

    next: RE_pDFAStateSub_t; {�����N���X�g�̎��̃f�[�^}
  end;

  { RE_DFAState_t�͂c�e�`��Ԃ�\���^}
  RE_DFAState_t = record
    StateSet: TRE_NFAStateSet; {����DFA��Ԃ�\��NFA��ԏW��}
    Visited: wordbool; { �����ς݂Ȃ�P}
    Accepted: wordbool;{ StateSet�t�B�[���h��NFA�̏I����Ԃ��܂ނȂ�P}
    Next: RE_pDFAStateSub_t;  { �L�����N�^�N���X���̑J�ڐ�̃����N���X�g}
  end;

{ �� NFA��ԕ\����DFA��ԕ\�����N���X}
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
    { NFA��ԏW�� StateSet �ɑ΂��� ��-closure��������s����B
    �ÑJ�ڂőJ�ډ\�ȑS�Ă̂m�e�`��Ԃ�ǉ�����}
    procedure Collect_Empty_Transition(StateSet: TRE_NFAStateSet);

    { NFA��ԏW�� aStateSet ���c�e�`�ɓo�^���āA�c�e�`��Ԃւ̃|�C���^��Ԃ��B
      aStateSet���I����Ԃ��܂�ł���΁Aaccepted�t���O���Z�b�g����B
      ���ł�aStateSet���c�e�`�ɓo�^����Ă����牽�����Ȃ�}
    function Register_DFA_State(var aStateSet: TRE_NFAStateSet): RE_pDFAState_t;

    { �����ς݂̈󂪂��Ă��Ȃ��c�e�`��Ԃ�T���B
      ������Ȃ����nil��Ԃ��B}
    function Fetch_Unvisited_D_state: RE_pDFAState_t;

    { DFA���pDFAState����J�ډ\��NFA��Ԃ�T���āA���X�g�ɂ��ĕԂ�}
    function Compute_Reachable_N_state(pDFAState: RE_pDFAState_t): RE_pDFATransNode_t;

    { Compute_Reachable_N_state���\�b�h����� RE_DFATransNode_t�^�̃����N���X�g��
    �p������}
    procedure Destroy_DFA_TransList(pDFA_TransNode: RE_pDFATransNode_t);

    { NFA�𓙉��Ȃc�e�`�ւƕϊ�����}
    procedure Convert_NFA_to_DFA;

    { StateList�̊e�����N���X�g���\�[�g����}
    procedure StateListSort;

    procedure CheckIfRegExpIsSimple;
    procedure DestroyStateList;
  public
    constructor Create(NFA: TRE_NFA);
    destructor Destroy; override;

    procedure Run;

    property StateList: TList read FStateList;

    property pInitialState: RE_pDFAState_t read FpInitialState;

    {���K�\�����P���ȕ����񂩁H}
    property RegExpIsSimple: Boolean read FRegExpIsSimple;
    {���K�\���Ɠ����ȒP���ȕ�����}
    property SimpleRegExpStr: String read FSimpleRegExpStr;

    {���K�\�����A�������^�L�����N�^���܂ނ�}
    property RegExpHasLHead: Boolean read FRegExpHasLHead;
    {���K�\�����A�������^�L�����N�^���܂ނ�}
    property RegExpHasLTail: Boolean read FRegExpHasLTail;
  {$IFDEF DEBUG}
    {TStrings�I�u�W�F�N�g�ɁADFA �̓��e����������}
    procedure WriteDFAtoStrings(Strings: TStrings);
{$ENDIF}
  end;

{ -=================== TRegularExpression Class ==============================-}
  {TStringList �Ɋi�[�ł��鍀�ڐ��͈̔͌^}
  RE_IndexRange_t = 1..Classes.MaxListSize;

{�� ���K�\�������񂩂�c�e�`��ԕ\�����N���X}
  TRegularExpression = class(TComponent)
  private
  protected
    FLineHeadWChar: WChar_t;
    FLineTailWChar: WChar_t;
    {�v���v���Z�b�T��ʂ�O�̐��K�\��}
    FRegExp: String;
    {���K�\���̕����񃊃X�g�BObjects�v���p�e�B��T�c�e�`�I�u�W�F�N�g������}
    FRegExpList: TStringList;
    {FRegExpList�Ɋi�[���鍀�ڐ��̍ő�l�B �f�t�H���g 30}
    FRegExpListMax: RE_IndexRange_t;
    {���ݎw�肳��Ă��鐳�K�\�� RegExp�̐��K�\�������񃊃X�gRegExpList���ł�
     �C���f�b�N�X
     �� FRegExpList[FCurrentIndex] = RegExp}
    FCurrentIndex: Integer;
    {���ӌꏈ���v���v���Z�b�T}
    FPreProcessor: TREPreProcessor;

  { �����g�p�̂��߂̎葱���E�֐�}
    {*****     ���K�\�������񁨍\���؍\����NFA��DFA �̕ϊ����s�� *****}
    procedure Translate(RegExpStr: String); virtual;

    {���K�\�����X�g(RegExpList: TStringList)��Objects�v���p�e�B�Ɍ��ѕt����ꂽ
     TRE_DFA�I�u�W�F�N�g��j��}
    procedure DisposeRegExpList;

  {�v���p�e�B�E�A�N�Z�X�E���\�b�h}
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
  {DFA�I�u�W�F�N�g�֘A���\�b�h}
    {���ݎw�肳��Ă��鐳�K�\���ɑΉ�����c�e�`��ԕ\�̏�����Ԃւ̃|�C���^��Ԃ�}
    function GetpInitialDFAState: RE_pDFAState_t;
    {���ݎw�肳��Ă��鐳�K�\���ɑΉ�����TRE_DFA�I�u�W�F�N�g��Ԃ�}
    function GetCurrentDFA: TRE_DFA;
    {��� DFAstate���當�����ɂ���đJ�ڂ��āA�J�ڌ�̏�Ԃ�Ԃ��B
     �������ɂ���đJ�ڏo���Ȃ����nil��Ԃ�}
    function NextDFAState(DFAState: RE_pDFAState_t; c: WChar_t): RE_pDFAState_t;
    {DFA��ԕ\�̒��ŕ������^�L�����N�^��\���L�����N�^�R�[�h}
    property LineHeadWChar: WChar_t read GetLineHeadWChar;
    {DFA��ԕ\�̒��ŕ������^�L�����N�^��\���L�����N�^�R�[�h}
    property LineTailWChar: WChar_t read GetLineTailWChar;

  {���K�\���֘A�v���p�e�B}
    {���ݎw�肳��Ă��鐳�K�\��}
    property RegExp: String read FRegExp write SetRegExp;

    {���ݎw�肳��Ă��鐳�K�\���ɓ��ӌꏈ�����{��������}
    property ProcessedRegExp: String read GetProcessedRegExp;

    {���K�\�����P���ȕ����񂩁H}
    property RegExpIsSimple: Boolean read GetRegExpIsSimple;
    {���K�\���Ɠ����ȒP���ȕ�����(��RegExpIsSimple=False�̎��̓k��������)}
    property SimpleRegExp: String read GetSimpleRegExp;

    {���K�\�����A�������^�L�����N�^���܂ނ�}
    property HasLHead: Boolean read GetHasLHead;
    {���K�\�����A�������^�L�����N�^���܂ނ�}
    property HasLTail: Boolean read GetHasLTail;

  {�����֘A�v���p�e�B}
    {�������ꎋ�������g���^�g��Ȃ��w��}
    property UseFuzzyCharDic: Boolean read GetUseFuzzyCharDic write SetUseFuzzyCharDic;
    {�����̓��ꎋ�����̃��X�g}
    property ListOfFuzzyCharDic: TList read GetListOfFuzzyCharDic;

    {���ӌꎫ�����g���^�g��Ȃ��w��}
    property UseSynonymDic: Boolean read GetUseSynonymDic write SetUseSynonymDic;
    {���ӌꎫ���̃��X�g}
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

    {���� �F    �}�b�`
                (���K�\�����s���^�s�����^�L�����N�^���܂܂Ȃ��Ƃ��p)
    ����  �F
    ����  �F    pText: PChar    �k���L�����N�^�ŏI��錟���Ώە�����ւ̃|�C���^
    ����p�F    pStart:PChar    �}�b�`���������̐擪�����ւ̃|�C���^
                pEnd  :PChar    �}�b�`���������̎��̕����ւ̃|�C���^
    ����  �F    �}�b�`���������̃o�C�g���́ApEnd - pStart�œ�����B}
    procedure MatchStd(pText: PChar; var pStart, pEnd: PChar);


    {���� �F    �}�b�`(���K�\�����s���^�s�����^�L�����N�^���܂ނƂ��p)
    ����  �F
    ����  �F    pText: PChar    �k���L�����N�^�ŏI��錟���Ώە�����ւ̃|�C���^
    ����p�F    pStart:PChar    �}�b�`���������̐擪�����ւ̃|�C���^
                pEnd  :PChar    �}�b�`���������̎��̕����ւ̃|�C���^
    ����  �F    �}�b�`���������̃o�C�g���́ApEnd - pStart�œ�����B}
    procedure MatchEX(pText: PChar; var pStart, pEnd: PChar);

    {���� �F    �}�b�`(���������p�B���K�\�����s���^�s�����^�L�����N�^���܂ނƂ��p)
    ����  �F    MatchEx_Head���\�b�h�Ƃ̈Ⴂ�́A����pText���s�̓r�����|�C���g����
                ������̂Ƃ��āA�s�����^�L�����N�^�Ƀ}�b�`���Ȃ����ƁB
    ����  �F    pText: PChar    �k���L�����N�^�ŏI��錟���Ώە�����ւ̃|�C���^
                                (�s�̒����w���Ă�����̂Ƃ��Ĉ����B)
    ����p�F    pStart:PChar    �}�b�`���������̐擪�����ւ̃|�C���^
                pEnd  :PChar    �}�b�`���������̎��̕����ւ̃|�C���^
    ����  �F    �}�b�`���������̃o�C�g���́ApEnd - pStart�œ�����B}
    procedure MatchEX_Inside(pText: PChar; var pStart, pEnd: PChar);

{----------------�}�b�` ������    -------------}
{MatchHead, MatchInside�́A���� pText���w��������擪�Ƃ��ă}�b�`���邩����������}

    {���� �F    pText�́A���镶����̍s�����|�C���g���Ă�����̂ƌ��Ȃ��B
                ���������āApText���w�������͍s�����^�L�����N�^�Ƀ}�b�`����B
                �s�����^�L�����N�^���l������B
    ����  �F    pText: PChar      �����Ώە�����(�s�̍ŏ��̕������w��)
                pDFAState         �����l�Ƃ��Ďg��DFA��ԕ\�̂P���
    �Ԃ�l�F    �}�b�`��������������̎��̕����B
                �}�b�`��������������̃o�C�g���́Aresult - pText
    ����  �F    }
    function MatchHead(pText: PChar; pDFAState: RE_pDFAState_t): PChar;

    {���� �F    pText�́A���镶����̒�(�s���ł͂Ȃ�)���|�C���g���Ă�����̂ƌ��Ȃ��B
                ���������āApText���w�������͍s�����^�L�����N�^�Ƀ}�b�`���Ȃ��B
                �s�����^�L�����N�^���l������B
    ����  �F    pText: PChar      �����Ώە�����(�s���̕������w��)
                pDFAState         �����l�Ƃ��Ďg��DFA��ԕ\�̂P���
    �Ԃ�l�F    �}�b�`��������������̎��̕����B
                �}�b�`��������������̃o�C�g���́Aresult - pText
    ����  �F    }
    function MatchInside(pText: PChar; pDFAState: RE_pDFAState_t): PChar;
  public
    constructor Create(AOwner: TComponent); override;
  end;

{ -========================== TAWKStr Class ==================================-}
  TAWKStrMatchProc = procedure(pText: PChar; var pStart, pEnd: PChar) of object;

{�� AWK����̕����񑀍�֐��Q��Delphi�Ŏ�������N���X TAWKStr}
  TAWKStr = class(TMatchCORE)
  private
    FMatchProc: TAWKStrMatchProc;
  protected
    procedure SetRegExp(Str: String); override;
    {Sub, GSub���\�b�h�Ŏg�p�B '&'���}�b�`����������ɒu������}
    function Substitute_MatchStr_For_ANDChar(Text: String; MatchStr: String): String;
  public
    constructor Create(AOwner: TComponent); override;
    function ProcessEscSeq(Text: String): String;

    {�����̓��ꎋ�����̃��X�g}
    property ListOfFuzzyCharDic;
    {���ӌꎫ���̃��X�g}
    property ListOfSynonymDic;

    {���K�\�����A�������^�L�����N�^���܂ނ�}
    property HasLHead;
    {���K�\�����A�������^�L�����N�^���܂ނ�}
    property HasLTail;

    property ProcessedRegExp;

    {DFA��ԕ\�̒��ŕ������^�L�����N�^��\���L�����N�^�R�[�h}
    property LineHeadWChar;
    {DFA��ԕ\�̒��ŕ������^�L�����N�^��\���L�����N�^�R�[�h}
    property LineTailWChar;

    function Match(Text: String; var RStart, RLength: Integer): Integer;

    function Sub(SubText: String; var Text: String): Boolean;

    function GSub(SubText: String; var Text: String): Integer;

    function Split(Text: String; StrList: TStrings): Integer;
  published
    property RegExp;
    {�s�̋�؂蕶���w��}
    property LineSeparator;

    {�����̓��ꎋ�������g����}
    property UseFuzzyCharDic;
    {���ӌꎫ�����g����}
    property UseSynonymDic;

  end;

{ -========================== ��O�N���X =====================================-}
  EEndOfFile = class(EInOutError);

  EFileNotFound = class(EInOutError);

  EGrepCancel = class(Exception);

{ -=========================== TTxtFile Class ================================-}
  {TTextFile�N���X��GetThisLine���Ԃ��t�@�C�����̂P�s�̏���\���^}
  RE_LineInfo_t = record
    Line: String;
    LineNo: Integer; {�s�ԍ�}
  end;

{�� TTxtFile �e�L�X�g�t�@�C���E�A�N�Z�X�E�N���X}
  TTxtFile = Class
  private
  protected
  public
    FBuffSize: Integer; {�o�b�t�@�̃T�C�Y}
    FTailMargin: Integer;
    FpBuff: PChar;      {�ǂݍ��݃o�b�t�@�ւ̃|�C���^}

    FFileName: String;  {�����Ώۃt�@�C���� �i�t���p�X�\�L�j}
    FF: File;           {FFileName �Ɋ֘A�t������^�Ȃ��t�@�C���ϐ�}
    FFileOpened: Boolean;

    {�o�b�t�@���̕����ʒu��\���d�v�ȃ|�C���^�R���}
    FpBase: PChar;      {�����Ō����ΏۂƂȂ镔��������̐擪���w��}
    FpLineBegin: PChar; {FpBase���w�����̐擪�����ւ̃|�C���^}
    FpForward: PChar;     {�������̕����ւ̃|�C���^}

    FLineNo: Integer;   {���݂̍s�ԍ�}
    FReadCount: Integer;{BlockRead �ŉ��o�C�g�ǂݍ��񂾂��B}
    FBrokenLine: String;{�o�b�t�@�̋��E�ŕ��f���ꂽ���̑O������}

    FpCancelRequest: ^Boolean;
    {IncPBase���\�b�h��FpBase���k���E�L�����N�^���w�����Ƃ��̏���}
    procedure IncPBaseNullChar(Ch: Char);
    {GetChar���\�b�h��FpForward���k���E�L�����N�^���w�����Ƃ��̏���}
    procedure GetCharNullChar(Ch: Char);

    constructor Create(aFileName: String; var CancelRequest: Boolean);
    destructor Destroy; override;
    procedure BuffRead(pBuff: PChar);
    function IncPBase: Char;  {FpBase�����̃o�C�g���w���悤�ɂ���}
    function AdvanceBase: WChar_t;
    function GetChar: Char;
    function GetWChar: WChar_t;
    function GetThisLine: RE_LineInfo_t;{FpBase���w���Ă��镶�����܂ޕ��𓾂�}
  end;

{ -=========================== TGrep Class ==================================-}

  TGrepOnMatch = procedure (Sender: TObject; LineInfo: RE_LineInfo_t) of Object;

  TGrepGrepProc = procedure (FileName: String) of Object;

{�� �t�@�C�����K�\�������N���X TGrep }
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

    {�@�\ �w�肳�ꂽ�e�L�X�g�E�t�@�C�����Ő��K�\��(RegExp�v���p�e�B)�Ƀ}�b�`
          ����s��T���A�����邽�т�OnMatch �C�x���g�n���h�����Ăяo���܂��B

          (RegExp�v���p�e�B�ɐݒ肳��Ă��鐳�K�\�����������āA���ʂ̕�����Ȃ��
           GrepByStr���\�b�h�A���^�L�����N�^���܂ނƂ���GrepByRegExp���\�b�h��
           �Ăяo���܂��B)
          �� OnMatch �C�x���g�n���h�����w�肳��Ă��Ȃ��Ƃ��́A�������܂���B

     ����   FileNmae        �����Ώۂ̃e�L�X�g�t�@�C����(�t���p�X�w��)
            CancelRequest   ������r���Ŏ~�߂����Ƃ���True�ɂ���B
            �� Grep���\�b�h�͓����ŁAApplication.ProcessMessages���Ăяo��
               �̂ŁA���̂Ƃ��ɁACancelRequest��True�ɐݒ肷�邱�Ƃ��ł��܂��B}

    {���K�\�����P���ȕ����񂩁H}
    property RegExpIsSimple;
    {���K�\���Ɠ����ȒP���ȕ�����(��RegExpIsSimple=False�̎��̓k��������)}
    property SimpleRegExp;

    {���K�\�����A�������^�L�����N�^���܂ނ�}
    property HasLHead;
    {���K�\�����A�������^�L�����N�^���܂ނ�}
    property HasLTail;

    {RegExp�v���p�e�B�̐��K�\���ɓ��ӌꏈ�����{��������}
    property ProcessedRegExp;
    {�����̓��ꎋ�����̃��X�g}
    property ListOfFuzzyCharDic;
    {���ӌꎫ���̃��X�g}
    property ListOfSynonymDic;

    property Grep: TGrepGrepProc read FGrepProc;
  published
    {���K�\��������}
    property RegExp;
    {�����̓��ꎋ�������g����}
    property UseFuzzyCharDic;
    {���ӌꎫ�����g����}
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
{ -====================== �����񑀍�֐� =====================================-}
{���� �F  �P�U�i����\���������󂯎��A�����ɂ��ĕԂ��B
 ���� �F  WCh: WChar_t;     16�i����\��1�o�C�g���� [0-9a-fA-F]

 �Ԃ�l�F ���펞�F  0 <= result <= 15
          �ُ펞�F  -1}
function HexWCharToInt(WCh: WChar_t): Integer;
begin
  case WCh of
    Ord('0')..Ord('9'):       result := WCh - Ord('0');
    Ord('A')..Ord('F'):       result := WCh - Ord('A')+10;
    Ord('a')..Ord('f'):       result := WCh - Ord('a')+10;
    else                      result := -1;
  end;
end;

{���� �F  �W�i����\���������󂯎��A�����ɂ��ĕԂ��B
 ���� �F  WCh: WChar_t;     8�i����\��1�o�C�g���� [0-7]

 �Ԃ�l�F ���펞�F  0 <= result <= 7
          �ُ펞�F  -1}
function OctWCharToInt(WCh: WChar_t): Integer;
begin
  case WCh of
    Ord('0')..Ord('7'):       result := WCh - Ord('0');
    else                      result := -1;
  end;
end;

{�@�\�F Str ���� �P���� ����
 ����F Str����Index���w���ʒu����1����(�Q�o�C�g�����܂�) ���Ă���AIndex��
        ���̕������w���悤�ɐi�߂�
 ���ӁF Index��������̒�����肷�łɒ����ꍇ�͏�� 0��Ԃ��AIndex�𑝂₳�Ȃ��B
        �܂�AIndex�͍ő�ł� Length(Str)+1 �ł���B}
function GetWChar(const Str: String; var Index: Integer): WChar_t;
begin
  if (Index >= 1) and (Index <= Length(Str)) then begin
    if IsDBCSLeadByte(Byte(Str[Index])) then begin
      {Str�̍Ō�̕������Q�o�C�g�����R�[�h�̂P�o�C�g�̂Ƃ��͗�O����}
      if Index = Length(Str) then
        raise ERegExpParser.Create('�s���ȂQ�o�C�g�����R�[�h�ł��B', Index);
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

//1997/09/25 FIX: MBUtils.pas���Ȃ��Ă����삷��悤�ɕύX
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

{�@�\�F WChar_t�^�̒l��String�^�֕ϊ�����B}
function WCharToStr(WCh: WChar_t): String;
begin
  if IsDBCSLeadByte(Hi(WCh)) then
    result := Chr(Hi(WCh))+Chr(Lo(WCh))
  else
    result := Chr(Lo(WCh));
end;

{�@�\�F '\' �� ���p���ꂽ�L�����N�^�𓾂�B \n, \t \\ ...
 ���ӁF Index��'\'�̎��̕������w���Ă���Ƃ���B}
function GetQuotedWChar(const Str: String; var Index: Integer): WChar_t;
var
  WCh: WChar_t;
begin
  WCh := GetWChar(Str, Index);
  if WCh = 0 then
    raise ERegExpParser.Create('"\"�̎��ɂ͕������K�v�ł��B', Index);

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
    UnGetWChar(Str, Index); {WCh��߂�}
    result := OctStrToInt(Str, Index);
  end else
    result := WCh;
end;

{���� �F  16�i���\�L�̕������Word�^�̐��l�ɕϊ�����B
����  �F  Str: String     �ϊ����̕�����
          Index: Integer  ����Str��Index�Ԗڂ̃o�C�g�ʒu����ϊ����n�߂�B
�Ԃ�l�F  �����񂪕\��Word�^�̒l}
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
    raise ERegExpParser.Create('�s���ȂP�U�i���R�[�h�\�L�ł��B', Index);
  if WCh <> CONST_NULL then
    UnGetWChar(Str, Index);
end;

{���� �F  �W�i���\�L�̕������Word�^�̐��l�ɕϊ�����B
����  �F  Str: String     �ϊ����̕�����
          Index: Integer  ����Str��Index�Ԗڂ̃o�C�g�ʒu����ϊ����n�߂�B
�Ԃ�l�F  �����񂪕\��Word�^�̒l}
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
      raise ERegExpParser.Create('�s���ȂW�i���R�[�h�\�L�ł��B', Index);
    result := result * 8 + Val;
    WCh := GetWChar(Str, Index);
    Val := OctWCharToInt(WCh);
    Inc(i);
  end;
  if i = 1 then
    raise ERegExpParser.Create('�s���ȂW�i���R�[�h�\�L�ł��B', Index);
  if WCh <> CONST_NULL then
    UnGetWChar(Str, Index);
end;

{���� �F  FS:WChar_t����؂蕶���Ƃ��āA�o�C�g�ʒuIndex����n�܂�g�[�N�����P�Ԃ��B
����  �F  Str: String
          Index: Integer  ����Str��Index�Ԗڂ̃o�C�g�ʒu����ϊ����n�߂�B
�Ԃ�l�F  FS�ŋ�؂�ꂽ�A�o�C�g�ʒuIndex����n�܂�g�[�N��}
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

{���� �F  ����Str���̃��^�L�����N�^��'\'������B
����  �F  Str: String
�Ԃ�l�F  ���^�L�����N�^�̑O��'\'������Str}
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

{�@�\�F �g�[�N���𓾂�
 ����F GetWChar�����UnGetWChar���\�b�h���g���ăg�[�N���𓾂�B
 ���ӁF �Ԃ�l�́A�񋓌^ REToken_t�̂���retk_CharClass�ȊO�̂ǂꂩ}
function TREScanner.GetTokenStd: REToken_t;
var
  WChar: WChar_t;
begin
  WChar := GetWChar(FRegExpStr, FIndex);
  FSymbol.WChar := WChar;

  { ����(��)���g�[�N���ɕϊ����� }
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
      raise ERegExpParser.Create('�E�u���P�b�g"]"���K�v�ł�', FIndex);
    if WChar = CONST_CARET then
      FToken := retk_LBraNeg {��L�����N�^�N���X}
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

{�@�\�F '[]'�ň͂܂ꂽ�L�����N�^�N���X���K�\���̒��̃g�[�N���𓾂�B
 ����F GetWChar�����UnGetWChar���\�b�h���g���ăg�[�N���𓾂�B
 ���ӁF �Ԃ�l�́A�񋓌^ REToken_t�̂���
        retk_Char, retk_CharClass, retk_RBra�̂ǂꂩ�B
        �k���E�L�����N�^���������Ƃ��͗�O�𐶐�����B}
function TREScanner.GetTokenCC: REToken_t;
var
  WChar, WChar2, WChar3: WChar_t;
begin
  WChar := GetWChar(FRegExpStr, FIndex);
  FSymbol.WChar := WChar;

  { ����(��)���g�[�N���ɕϊ����� }
  if WChar = CONST_NULL then
    raise ERegExpParser.Create('�E�u���P�b�g"]"���K�v�ł�', FIndex);
  if WChar = CONST_RBRA then
    FToken := retk_RBra
  else begin
    if WChar = CONST_YEN then
    {�G�X�P�[�v�V�[�P���X������}
      WChar := GetQuotedWChar(FRegExpStr, FIndex);

    {�L�����N�^�͈͂�\��'-'�Ɋւ��鏈��������}
    FToken := retk_Char;
    WChar2 := GetWChar(FRegExpStr, FIndex);
    if WChar2 = CONST_MINUS then begin
    {2�Ԗڂ̕�����'-'�������Ƃ�}
      WChar3 := GetWChar(FRegExpStr, FIndex);
      if WChar3 = CONST_NULL then
      {3�Ԗڂ̕������k���L�����N�^�̂Ƃ�}
        raise ERegExpParser.Create('�E�u���P�b�g"]"���K�v�ł�', FIndex);

      if WChar3 = CONST_RBRA then begin
      {3�Ԗڂ̕����� ']'�̂Ƃ�}
        UnGetWChar(FRegExpStr, FIndex); { WChar3��߂� }
        UnGetWChar(FRegExpStr, FIndex); { WChar2��߂� }
        FSymbol.WChar := WChar;
      end else begin
        if WChar3 = CONST_YEN then
          WChar3 := GetQuotedWChar(FRegExpStr, FIndex);
        FToken := retk_CharClass;
        if WChar > WChar3 then
          raise ERegExpParser.Create('�s���ȃL�����N�^�͈͂ł�', FIndex);
        FSymbol.CharClass.StartChar := WChar;
        FSymbol.CharClass.EndChar := WChar3;
      end
    end else begin
    {2�Ԗڂ̕�����'-'�ł͂Ȃ��Ƃ�}
      if WChar2 = CONST_NULL then
      {2�Ԗڂ̕������k���L�����N�^�̂Ƃ�}
        raise ERegExpParser.Create('�E�u���P�b�g"]"���K�v�ł�', FIndex);
      UnGetWChar(FRegExpStr, FIndex);{WChar2��߂�}
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

{���� �F    FTokenList: TList ���A�A�C�e���f�[�^ (RETokenInfo_t�^���R�[�h)�Ƌ��ɔp������B
����  �F    MakeTokenList�Ƒ΂Ŏg�p����B}
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

{���� �F    FTokenList: TList�� RETokenInfo_t�^�̃��R�[�h���\�z����B
����  �F    �Ō����RETokenInfo_t�^���R�[�h�́A���Token = retk_End�ł���B
����  �F    DestroyTokenList���\�b�h�Ƒ΂Ŏg�p����B}
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

  {�Ō�� retk_End}
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

{���� �F    ���K�\��������ɓ��ӌ��g�ݍ��ށB}
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

{���� �F    ���ӌꖄ�ߍ��ݏ��� Run���\�b�h�̉�����}
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
  {���ׂẴg�[�N������������}
  while TkIndex < FTokenList.Count do begin
    Info := REpTokenInfo_t(FTokenList[TkIndex])^;
    {�L�����N�^�N���X ('[]'�ł�����ꂽ����)�ɓ���}
    if Info.Token = retk_LBra then
      InCC := True;

    {�L�����N�^�N���X����o��}
    if Info.Token = retk_RBra then
      InCC := False;

    {�g�[�N�����L�����N�^�ȊO���A�L�����N�^�N���X '[ ]'�̒��̏ꍇ}
    if (Info.Token <> retk_Char) or InCC then begin
      FProcessedRegExpStr := FProcessedRegExpStr +
        Copy(FScanner.RegExpStr, Info.FromIndex, Info.ToIndex-Info.FromIndex);
      Inc(TkIndex); {����������FProcessedRegExpStr�֒ǉ�}
    {�g�[�N�����L�����N�^�̏ꍇ}
    end else begin
      j := TkIndex;
      {j���L�����N�^�ȊO���w���܂ŃC���N�������g}
      while REpTokenInfo_t(FTokenList[j])^.Token = retk_Char do
        Inc(j);

      {�L�����N�^�̘A�����P�Â���}
      while TkIndex < j do begin
        k := FindFunc(TkIndex, j);
        if k <> -1 then begin
          {�}�b�`����������ǉ�}
          FProcessedRegExpStr := FProcessedRegExpStr + FSynonymStr;
          TkIndex := k; {���̃g�[�N������}�b�`���镔�������������������B}
        end else begin
          {�}�b�`���Ȃ���΁A�ꕶ�����ǉ����āA�C���f�b�N�X��i�߂�}
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

{���� �F    ���ӌꎫ�� SynonymDic: TList���g���āA���ӌ��T���B
�Ԃ�l�F    �g�[�N�����X�g���̓��ӌ�̎��̃C���f�b�N�X
            ������Ȃ���� -1}
function TREPreProcessor.ReferToOneList(FromTokenIndex, ToTokenIndex: Integer; SynonymDic: TList): Integer;
var
  StrList: TStrings;
  i, j, k, m: Integer;

  {Str��FTokenList���r}
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
      {�}�b�`����}
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

{���� �F
�Ԃ�l�F    �g�[�N�����X�g���̓��ӌ�̎��̃C���f�b�N�X
            ������Ȃ���� -1
����  �F    Run���\�b�h�����\�b�h�|�C���^��Process���\�b�h�ɓn���A
            Process���\�b�h���Ăяo���B}
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

{���� �F
�Ԃ�l�F    �g�[�N�����X�g���̓��ӌ�̎��̃C���f�b�N�X
            ������Ȃ���� -1
����  �F    Run���\�b�h�����\�b�h�|�C���^��Process���\�b�h�ɓn���A
            Process���\�b�h���Ăяo���B}
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

{�\���؂̃m�[�h���쐬����B
  op �̓m�[�h���\�����Z�Aleft�͍��̎q�Aright�͉E�̎q }
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
    {TList�Ń������s���̎���,�V�����\���؂̐߂��J�����Ă��܂�}
    on EOutOfMemory do begin
      Dispose(result);
      raise;
    end;
  end;
end;

{�\���؂̗t�����
  TheC �͂��̗t���\������}
function TREParseTree.MakeLeaf(aStartChar, aEndChar: WChar_t): REpNode_t;  {char}
var
  i: Integer;
begin
  {���ɓ����L�����N�^�N���X�����t�����݂���΁A�����Ԃ��B}
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
    {TList�Ń������s���̎���,�V�����\���؂̐߂��J�����Ă��܂�}
    on EOutOfMemory do begin
      Dispose(result);
      raise;
    end;
  end;
end;

{�������^�L�����N�^��\���߁B ���q�������Ȃ����AMakeInternalNode���g��}
function TREParseTree.MakeLHeadNode(WChar: WChar_t): REpNode_t;
begin
  result := MakeInternalNode(reop_LHead, nil, nil);
  with result^ do begin
    CharClass.StartChar := WChar;
    CharClass.EndChar := WChar;
  end;
end;

{�������^�L�����N�^��\���߁B ���q�������Ȃ����AMakeInternalNode���g��}
function TREParseTree.MakeLTailNode(WChar: WChar_t): REpNode_t;
begin
  result := MakeInternalNode(reop_LTail, nil, nil);
  with result^ do begin
    CharClass.StartChar := WChar;
    CharClass.EndChar := WChar;
  end;
end;

{�C�ӂ̈ꕶ����\��'.'���^�L�����N�^�ɑΉ����镔���؂����B
 ��CR LF�������S�ẴL�����N�^��\���t��reop_Union�����\�����Ԑ߂Ō��񂾂���}
function TREParseTree.MakeAnyCharsNode: REpNode_t;
begin
    result := MakeInternalNode(reop_Union, MakeLeaf($1, $09), MakeLeaf($0B, $0C));
    result := MakeInternalNode(reop_Union, result, MakeLeaf($0E, $FCFC));
end;

{������ aStartChar <= aEndChar �̊֌W�𖞂����Ă���Ƃ��ɁAMakeLeaf���Ă�
 ����ȊO�́Anil ��Ԃ��B}
function TREParseTree.Check_and_MakeLeaf(aStartChar, aEndChar: WChar_t):REpNode_t;
begin
  if aStartChar <= aEndChar then begin
    result := MakeLeaf(aStartChar, aEndChar);
  end else
    result := nil;
end;

{�t������߂ɕς���B}
procedure TREParseTree.ChangeLeaftoNode(pLeaf, pLeft, pRight: REpNode_t);
begin
  if (pLeft = nil) or (pRight = nil) then
    raise Exception.Create('TREParseTree : �v���I�G���[');{ debug }
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

{�@�\�F �X�̗t�����L�����N�^�͈͂��P���d�����Ȃ��悤�ɂ���B
 ����F �t�́ACharClass�t�B�[���h�������ACharClass�t�B�[���h��StartChar��EndChar
        ���t�B�[���h�Ɏ����R�[�h�ł���B
        �X�̗t�����L�����N�^�͈̔͂��d�����Ȃ������ׂāA�d������ꍇ�ɂ́A
        ���̗t�𕪊����Areop_Union���������߂œ����ȕ����؂ɒ����B}
procedure TREParseTree.ForceCharClassUnique;
var
  i, j: Integer;
  Changed: Boolean;

  {�@�\�F �d������L�����N�^�͈͂����t�̕���
   ����F �Q�̗tpCCLeaf1��pCCLeaf2�̃L�����N�^�͈͂𒲂ׂāA�d������Ƃ���
          �������邵�ē����ȕ����؂ɕϊ�����B}
  function SplitCharClass(pCCLeaf1, pCCLeaf2: REpNode_t): Boolean;
  var
    pNode1, pNode2, pNode3: REpNode_t;
    S1, S2, SmallE, BigE: WChar_t;
  begin
    result := False;
    {�O�����F pCCLeaf1 ��StartChar <= pCCLeaf2 ��StartChar ��ۏ؂���}
    if pCCLeaf1^.CharClass.StartChar > pCCLeaf2^.CharClass.StartChar then begin
      pNode1 := pCCLeaf1;
      pCCLeaf1 := pCCLeaf2;
      pCCLeaf2 := pNode1;
    end;

    {�L�����N�^�N���X�͈̔͂��d�����Ȃ� ���� ����Ȃ�� Exit
     �� MakeLeaf���\�b�h�̍\�����炢���čŏ��͏d�����鎖�͂Ȃ����A�������J��Ԃ�
        �Əd������\��������B}
    if (pCCLeaf1^.CharClass.EndChar < pCCLeaf2^.CharClass.StartChar) or
    (pCCLeaf1^.CharClass.Chars = pCCLeaf2^.CharClass.Chars) then
      exit;

    {(pCCLeaf1 ��StartChar) S1 <= S2 (pCCLeaf2 ��StartChar)}
    S1 := pCCLeaf1^.CharClass.StartChar;
    S2 := pCCLeaf2^.CharClass.StartChar;

    {SmallE �́ApCCLeaf1, pCCLeaf2 �� EndChar �̏�������
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
      raise ERegExpParser.Create('�v���I�ȃG���[', 0); }
    if pNode1 = nil then begin {S1 = S2 �̂Ƃ�}
      if pCCLeaf1^.CharClass.EndChar = BigE then
        ChangeLeaftoNode(pCCLeaf1, pNode2, pNode3)
      else
        ChangeLeaftoNode(pCCLeaf2, pNode2, pNode3);
    end else if pNode3 = nil then begin {SmallE = BigE �̎�}
      ChangeLeaftoNode(pCCLeaf1, pNode1, pNode2);
    end else begin
      if pCCLeaf1^.CharClass.EndChar = BigE then begin{pCCLeaf1��pCCLeaf2���܂܂��}
        ChangeLeaftoNode(pCCLeaf1, MakeInternalNode(reop_Union, pNode1, pNode2),
          pNode3)
      end else begin {pCCLeaf1 �� pCCLeaf2 �̂P�������d�Ȃ��Ă���}
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
  {���������B Run���\�b�h���Ăׂ΍\����͂�����B}
end;

destructor TREParser.Destroy;
begin
  FScanner.Free;
  FParseTree.Free;
  inherited Destroy;
end;

{**************************************************************************
  ���K�\�����p�[�X���郁�\�b�h�Q
 **************************************************************************}
procedure TREParser.Run;
begin
  FParseTree.DisposeTree; {���łɂ���\���؂�p�����ď�����}

  FScanner.GetToken; {�ŏ��̃g�[�N����ǂݍ���}

  {���K�\�����p�[�X����}
  FParseTree.pHeadNode := regexp;

  {���̃g�[�N����retk_End �łȂ���΃G���[}
  if FScanner.Token <> retk_End then begin
    raise ERegExpParser.Create('���K�\���ɗ]���ȕ���������܂�',
      FScanner.Index);
  end;

  FParseTree.ForceCharClassUnique;{�L�����N�^�N���X�𕪊����ă��j�[�N�ɂ���}
end;

{ <regexp>���p�[�X���āA����ꂽ�\���؂�Ԃ��B
  �I�� X|Y ����͂��� }
function TREParser.regexp: REpNode_t;
begin
  result := term;
  while FScanner.Token = retk_Union do begin
    FScanner.GetToken;
    result := FParseTree.MakeInternalNode(reop_union, result, term);
  end;
end;

{ <term>���p�[�X���āA����ꂽ�\���؂�Ԃ�
  �A���w�x����͂���}
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

{ <factor>���p�[�X���āA����ꂽ�\���؂�Ԃ�
  �J��Ԃ�X*, X+, X?����͂���}
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

{ <primary>���p�[�X���āA����ꂽ�\���؂�Ԃ��B
  �������̂��́A(X)����͂���}
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
          raise ERegExpParser.Create('�E(��)���ʂ��K�v�ł�', FScanner.Index);
        FScanner.GetToken;
      end;
    retk_LBra, retk_LBraNeg: begin
        if FScanner.Token = retk_LBra then
          result := CharacterClass(FParseTree)
        else
          result := NegativeCharacterClass;
        if FScanner.Token <> retk_RBra then
          raise ERegExpParser.Create('�E�u���P�b�g"]"���K�v�ł�', FScanner.Index);
        FScanner.GetToken;
      end;
    else
      raise ERegExpParser.Create('���ʂ̕����A�܂��͍�����"("���K�v�ł�', FScanner.Index);
  end;
end;

{ <charclass> ���p�[�X���āA����ꂽ�\���؂�Ԃ��B
      [] �Ŋ���ꂽ���K�\������͂���}
function TREParser.CharacterClass(aParseTree: TREParseTree): REpNode_t;
  {Token�ɑΉ������t�����}
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
  FScanner.GetToken; {GetScannerCC�́Aretk_RBra, retk_Char, retk_CharClass�����Ԃ��Ȃ�}
  if FScanner.Token = retk_RBra then
    raise ERegExpParser.Create('�s���ȃL�����N�^�N���X�w��ł��B', FScanner.Index);

  result := WCharToLeaf;
  FScanner.GetToken;
  while FScanner.Token <> retk_RBra do begin
    result := aParseTree.MakeInternalNode(reop_Union, result, WCharToLeaf);
    FScanner.GetToken;
  end;

end;{function TREParser.CharacterClass}


{ <negative charclass>���p�[�X���āA����ꂽ�\���؂�Ԃ��B
  [^ ] �Ŋ���ꂽ���K�\������͂���}
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
{ [^abc] = . - [abc] �Ƃ������������B}

  aParseTree := TREParseTree.Create;
  try
  aNeg_ParseTree := TREParseTree.Create;
  try
    {aParseTree��'[]'�ň͂܂ꂽ�L�����N�^�N���X���K�\���̒��ɑΉ�����߂����B}
    aParseTree.pHeadNode := CharacterClass(aParseTree);
    {aParseTree�̗t�����L�����N�^�N���X�͈̔͂��d�����Ȃ��悤�ɐ��`}
    aParseTree.ForceCharClassUnique;

    {�C�ӂ̈ꕶ����\���؂�aNeg_ParseTree�ɍ쐬}
    aNeg_ParseTree.MakeAnyCharsNode;

    for i := 0 to aParseTree.LeafList.Count-1 do begin
      {aNeg_ParseTree�̗t����aParseTree�̗t�Ɠ��������폜}
      RemoveCC(aParseTree.LeafList[i]);
    end;

    {aNeg_ParseTree�̗t��FParseTree�ɃR�s�[}
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

{ �f�o�b�O�p���b�\�b�h�B�\���؂�VCL ��TOutLine�R���|�[�l���g�ɏ�������}
{ �\���؂��傫������ƁATOutLine�R���|�[�l���g���h���ʁh�̂Œ���}
procedure TREParser.WriteParseTreeToOutLine(anOutLine: TOutLine);
  procedure SetOutLineRecursive(pTree: REpNode_t; ParentIndex: Integer);
  var
    aStr: String;
    NextParentIndex: Integer;
  begin
    if pTree = nil then
      exit;

    case pTree^.op of
      reop_Char: begin{ �������̂��� }
          if pTree^.CharClass.StartChar <> pTree^.CharClass.EndChar then
            aStr := DebugWCharToStr(pTree^.CharClass.StartChar)
            + ' �` '+ DebugWCharToStr(pTree^.CharClass.EndChar)
          else
            aStr := DebugWCharToStr(pTree^.CharClass.StartChar);
        end;
      reop_LHead:
          aStr := '���� '+DebugWCharToStr(pTree^.CharClass.StartChar);
      reop_LTail:
          aStr := '���� '+DebugWCharToStr(pTree^.CharClass.StartChar);
      reop_Concat:{ XY }
          aStr := '�A�� ';
      reop_Union:{ X|Y}
          aStr := '�I�� "|"';
      reop_Closure:{ X* }
          aStr := '�� "*"';
      reop_Empty:{ �� }
          aStr := '��';
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

{ NFA��ԕ\��j������}
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

{ �\���� Tree�ɑΉ�����NFA�𐶐�����}
procedure TRE_NFA.Run;
begin
  { NFA �̏�����Ԃ̃m�[�h�����蓖�Ă�B}
  FEntryState := NumberNode;

  { NFA �̏I����Ԃ̃m�[�h�����蓖�Ă� }
  FExitState := NumberNode;

  { NFA �𐶐����� }
  GenerateStateList(FParser.ParseTree.pHeadNode, FEntryState, FExitState);
end;

{ �m�[�h�ɔԍ������蓖�Ă�}
function TRE_NFA.NumberNode: Integer;
begin
  with FStateList do begin
    result := Add(nil);
  end;
end;

{ NFA��Ԑ� ���P�쐬}
function TRE_NFA.MakeNFANode: RE_pNFANode_t;
begin
  New(result);
end;

{ FStateList�ɏ�ԑJ�ڂ�ǉ�����B
  ��� TransFrom �ɑ΂��� aCharClass���̕����ŏ�� TransTo �ւ̑J�ڂ�ǉ�����B}
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

{ �\���� pTree �ɑ΂��� StateList�𐶐�����
  NFA�̓������entry, �o����way_out�Ƃ��� }
procedure TRE_NFA.GenerateStateList(pTree: REpNode_t; entry, way_out: Integer);
var
  aState1, aState2: Integer;
  aCharClass: RECharClass_t;
begin
  case pTree^.op of
    reop_Char:
        AddTransition(entry, way_out, pTree^.CharClass);
    reop_LHead: begin {'^'}
        {�������^�L�����N�^'^' �� TransFrom = FEntryState�̂Ƃ��ȊO�́A
         �ʏ�̃L�����N�^�Ƃ��Ĉ����B}
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
        {�s�����^�L�����N�^ '$'�́ATransTo = FExitState�̂Ƃ��ȊO�́A
        �ʏ�̃L�����N�^�Ƃ��Ĉ����B}
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
        { ��� entry �� �ÑJ�� �� ��� aState1}
        AddTransition(entry, aState1, CONST_EMPTYCharClass);
        { ��� aState1 �� (pTree^.Children.pLeft)�ȉ��̑J�� �� ��� aState2}
        GenerateStateList(pTree^.Children.pLeft, aState1, aState2);
        { ��� aState2 �� �ÑJ�� �� ��� aState1}
        AddTransition(aState2, aState1, CONST_EMPTYCharClass);
        { ��� aState1 �� �ÑJ�� �� ��� way_out}
        AddTransition(aState1, way_out, CONST_EMPTYCharClass);
      end;
    reop_Concat: begin {'AB'}
        aState1 := NumberNode;
        { ��� entry �� (pTree^.Children.pLeft)�J�� �� ��� aState1}
        GenerateStateList(pTree^.Children.pLeft, entry, aState1);
        { ��� aState1 �� (pTree^.Children.pRight)�J�� �� ��� way_out}
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
{TStrings�I�u�W�F�N�g�ɁANFA �̓��e����������}
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
      Str := Format('�J�n %2d : ', [i])
    else if i = ExitState then
      Str := Format('�I�� %2d : ', [i])
    else
      Str := Format('��� %2d : ', [i]);
    while pNFANode <> nil do begin
      if pNFANode^.CharClass.StartChar = CONST_EMPTY then
        Str := Str + Format('�ÑJ�ڂ� ��� %2d �� :',[pNFANode^.TransitTo])
      else if pNFANode^.CharClass.StartChar <> pNFANode^.CharClass.EndChar then
        Str := Str + Format('����%s ����%s �� ��� %2d �� :',
          [DebugWCharToStr(pNFANode^.CharClass.StartChar),
          DebugWCharToStr(pNFANode^.CharClass.EndChar), pNFANode^.TransitTo])
      else if pNFANode^.CharClass.StartChar = FLHeadWChar then begin
        Str := Str + Format('�����R�[�h%s �� ��� %2d �� :',
          [DebugWCharToStr(pNFANode^.CharClass.StartChar), pNFANode^.TransitTo]);
      end else if pNFANode^.CharClass.StartChar = FLTailWChar then begin
        Str := Str + Format('�����R�[�h%s �� ��� %2d �� :',
          [DebugWCharToStr(pNFANode^.CharClass.StartChar), pNFANode^.TransitTo]);
      end else
        Str := Str + Format('����%s �� ��� %2d �� :',
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

{DFA��Ԃ̃��X�g��j��}
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
  Convert_NFA_to_DFA;   {NFA��ԕ\����DFA��ԕ\�����}
  StateListSort;        {DFA��ԕ\�̐߂���̓L�[���ɐ��񂷂�B�������̍������̂���}
  CheckIfRegExpIsSimple;{���K�\�����P���ȕ����񂩃`�F�b�N}
end;

{ NFA�𓙉��Ȃc�e�`�ւƕϊ�����}
procedure TRE_DFA.Convert_NFA_to_DFA;
var
  Initial_StateSet: TRE_NFAStateSet;
  t: RE_pDFAState_t;
  pDFA_TransNode, pTransNodeHead: RE_pDFATransNode_t;
  pDFA_StateSub: RE_pDFAStateSub_t;
begin
{DFA�̏�����Ԃ�o�^����}
  Initial_StateSet := TRE_NFAStateSet.Create(FNFA.StateList.Count);
  Initial_StateSet.Include(FNFA.EntryState);
  {�m�e�`������Ԃ̏W�������߂�i�ÑJ�ڂ��܂ށj}
  Collect_Empty_Transition(Initial_StateSet);
  FpInitialState := Register_DFA_State(Initial_StateSet);

  {�������̂c�e�`��Ԃ�����΁A��������o���ď�������
    ���ڂ��Ă���c�e�`��Ԃ����Ƃ���}
  t := Fetch_Unvisited_D_state;
  while t <> nil do begin

    {�����ς݂̈��t����}
    t^.visited := True;

    {��Ԃ�����J�ډ\��DFA��Ԃ����ׂ�DFA�ɓo�^����B}
    pTransNodeHead := Compute_Reachable_N_state(t);
    try
    pDFA_TransNode := pTransNodeHead;
    while pDFA_TransNode <> nil do begin
      { NFA��ԏW���̃�-closure�����߂�}
      Collect_Empty_Transition(pDFA_TransNode^.ToNFAStateSet);

      { �J�ڏ���DFA��Ԃɉ�����}
      New(pDFA_StateSub);
      with pDFA_StateSub^ do begin
        next := nil;
        CharClass := pDFA_TransNode^.CharClass;
        next := t^.next;
      end;
      t^.next := pDFA_StateSub;

      {���݂�DFA��Ԃ���̑J�ڐ�̐V����DFA��Ԃ�o�^}
      pDFA_StateSub^.TransitTo :=
        Register_DFA_State(pDFA_TransNode^.ToNFAStateSet);
      {Register_DFA_State���\�b�h�ɂ��ToNFAStateSet�I�u�W�F�N�g��DFA_State�ɏ��L�����}
      {pDFA_TransNode^.ToNFAStateSet := nil;}

      pDFA_TransNode := pDFA_TransNode^.next;
    end;
    t := Fetch_Unvisited_D_state;
    finally
      Destroy_DFA_TransList(pTransNodeHead);
    end;
  end;
end;

{ NFA��ԏW�� StateSet �ɑ΂��� ��-closure��������s����B
  �ÑJ�ڂőJ�ډ\�ȑS�Ă̂m�e�`��Ԃ�ǉ�����}
procedure TRE_DFA.Collect_Empty_Transition(StateSet: TRE_NFAStateSet);
var
  i: Integer;
  { NFA��ԏW�� StateSet�ɂm�e�`��� ����ǉ�����B
    �����ɂm�e�`��Ԃ�����ÑJ�ڂňړ��ł���m�e�`��Ԃ��ǉ�����}
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

{ NFA��ԏW�� aStateSet ���c�e�`�ɓo�^���āA�c�e�`��Ԃւ̃|�C���^��Ԃ��B
  aStateSet���I����Ԃ��܂�ł���΁Aaccepted�t���O���Z�b�g����B
  ���ł�aStateSet���c�e�`�ɓo�^����Ă����牽�����Ȃ�}
function TRE_DFA.Register_DFA_State(var aStateSet: TRE_NFAStateSet): RE_pDFAState_t;
var
  i: Integer;
begin
  { NFA��� aStateSet �����łɂc�e�`�ɓo�^����Ă�����A�������Ȃ��Ń��^�[������}
  for i := 0 to FStateList.Count-1 do begin
    if RE_pDFAState_t(FStateList[i])^.StateSet.Equals(aStateSet) then begin
      result := RE_pDFAState_t(FStateList[i]);
      exit;
    end;
  end;

  {DFA�ɕK�v�ȏ����Z�b�g����}
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

{ �����ς݂̈󂪂��Ă��Ȃ��c�e�`��Ԃ�T���B
  ������Ȃ����nil��Ԃ��B}
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

{Compute_Reachable_N_state ����� RE_DFATransNode_t�^�̃����N���X�g��j������}
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

{ DFA���pDFAState����J�ډ\��NFA��Ԃ�T���āA�����N���X�g�ɂ��ĕԂ�}
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
  {���ׂĂ̂m�e�`��Ԃ����ɒ��ׂ�}
  for i := 0 to FNFA.StateList.Count-1 do begin

    { NFA���i��DFA��� pDFAState�Ɋ܂܂�Ă���΁A�ȉ��̏������s��}
    if pDFAState^.StateSet.Has(i) then begin

      { NFA��� i ����J�ډ\�Ȃm�e�`��Ԃ����ׂĒ��ׂă��X�g�ɂ���}
      pNFANode := RE_pNFANode_t(FNFA.StateList[i]);
      while pNFANode <> nil do begin
        if pNFANode^.CharClass.StartChar <> CONST_EMPTY then begin {�ÑJ�ڂ͖���}
          a := result;
          while a <> nil do begin
            if a^.CharClass.Chars = pNFANode^.CharClass.Chars then begin
              a^.ToNFAStateSet.Include(pNFANode^.TransitTo);
              goto added;
            end;
            a := a^.next;
          end;
          {�L�����N�^ pNFANode^.CharClass.c�ɂ��J�ڂ��o�^����Ă��Ȃ���Βǉ�}
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
    Destroy_DFA_TransList(result); {�\�z���̃��X�g�p��}
    raise;
  end;
end;
end;

{��ԃ��X�g�̃����N���X�g�𐮗񂷂�(�}�[�W�E�\�[�g���g�p)}
procedure TRE_DFA.StateListSort;
var
  i: Integer;
  {�}�[�W�E�\�[�g�������ċA�I�ɍs��}
  function DoSort(pCell: RE_pDFAStateSub_t): RE_pDFAStateSub_t;
  var
    pMidCell, pACell: RE_pDFAStateSub_t;

    {2�̃��X�g���\�[�g���Ȃ��畹������}
    function MergeList(pCell1, pCell2: RE_pDFAStateSub_t): RE_pDFAStateSub_t;
    var
      Dummy: RE_DFAStateSub_t;
    begin
      Result := @Dummy;
      {�ǂ��炩�̃��X�g���A��ɂȂ�܂Ŕ���}
      while (pCell1 <> nil) and (pCell2 <> nil) do begin
        {pCell1 �� pCell2 ���r���ď���������Result�ɒǉ����Ă���}
        if pCell1^.CharClass.StartChar > pCell2^.CharClass.StartChar then begin
        {pCell2�̕���������}
          Result^.Next := pCell2;
          Result := pCell2;
          pCell2 := pCell2^.Next;
        end else begin
        {pCell1�̕���������}
          Result^.Next := pCell1;
          Result := pCell1;
          pCell1 := pCell1^.Next;
        end;
      end;
      {�]�������X�g�����̂܂�result �ɒǉ�}
      if pCell1 = nil then
        Result^.Next := pCell2
      else
        Result^.Next := pCell1;

      result := Dummy.Next;
    end;

  {DoSort�{��}
  begin
    if (pCell = nil) or (pCell^.Next = nil) then begin
      result := pCell;
      exit; {�v�f���P�A�܂��́A�����Ƃ��́A������ exit}
    end;

    {ACell ���R�Ԗڂ̃Z�����w���悤�ɂ���B������΁Anil ����������}
    {���X�g���Q�`�R�̃Z�������Ƃ��ɂ��A�������s���悤�ɂ���B}
    pACell := pCell^.Next^.Next;
    pMidCell := pCell;
    {MidCell ���A���X�g�̐^�񒆂�����̃Z�����w���悤�ɂ���B}
    while pACell <> nil do begin
      pMidCell := pMidCell^.Next;
      pACell := pACell^.Next;
      if pACell <> nil then
        pACell := pACell^.Next;
    end;

    {MidCell �̌��Ń��X�g���Q��������}
    pACell := pMidCell^.Next;
    pMidCell^.Next := nil;

    result := MergeList(DoSort(pCell), DoSort(pACell));
  end;
begin {Sort �{��}
  for i := 0 to FStateList.Count-1 do begin
    RE_pDFAState_t(FStateList[i])^.next :=
      DoSort(RE_pDFAState_t(FStateList[i])^.next);
  end;
end;

{�@�\�F ���݂̐��K�\�����A���ʂ̕����񂩁H
        ���ʂ̕����񂾂�����AFRegExpIsSimple = True; FSimpleRegExpStr�ɕ�����ɐݒ�
        ����ȊO�̏ꍇ�́A    FRegExpIsSimple = False;FSimpleRegExpStr = ''}
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
       {�����̃L�����N�^���󂯓����}
      (pSub^.CharClass.StartChar <> pSub^.CharClass.EndChar) or
       {�L�����N�^�͈͂�����}
      (pDFAState^.Accepted and (pSub^.TransitTo <> nil))
      {�󗝌���L�����N�^���󂯓����}then begin

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
{TStrings�I�u�W�F�N�g�ɁADFA �̓��e����������}
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
      Str := Format('�J�n %2d : ', [i])
    else if pDFA_State^.Accepted then
      Str := Format('�I�� %2d : ', [i])
    else
      Str := Format('��� %2d : ', [i]);
    pDFA_StateSub := pDFA_State^.next;
    while pDFA_StateSub <> nil do begin
      if pDFA_StateSub^.CharClass.StartChar <> pDFA_StateSub^.CharClass.EndChar then
         Str := Str + Format('���� %s ���� ����%s �� ��� %2d �� :',
          [DebugWCharToStr(pDFA_StateSub^.CharClass.StartChar),
           DebugWCharToStr(pDFA_StateSub^.CharClass.EndChar),
          FStateList.IndexOf(pDFA_StateSub^.TransitTo)])

      else if pDFA_StateSub^.CharClass.StartChar = FNFA.LHeadWChar then begin
        Str := Str + Format('�����R�[�h %s �� ��� %2d �� :',
          [DebugWCharToStr(pDFA_StateSub^.CharClass.StartChar),
          FStateList.IndexOf(pDFA_StateSub^.TransitTo)]);
      end else if pDFA_StateSub^.CharClass.StartChar = FNFA.LTailWChar then begin
        Str := Str + Format('�����R�[�h %s �� ��� %2d �� :',
          [DebugWCharToStr(pDFA_StateSub^.CharClass.StartChar),
          FStateList.IndexOf(pDFA_StateSub^.TransitTo)]);
      end else
        Str := Str + Format('���� %s �� ��� %2d �� :',
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
  FRegExpListMax := 30; {RegExpList�̍��ڐ��ݒ� 30}
  {FCurrentIndex = 0 �̓k���̐��K�\���ŏ�Ɏg����悤�ɂ���B}
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

{���K�\�����X�g(FRegExpList: TStringList)��Objects�v���p�e�B�Ɍ��ѕt����ꂽ
 TRE_DFA�I�u�W�F�N�g��j��}
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

{ ---------------------- �v���p�e�B �A�N�Z�X ���\�b�h -----------------}
{RegExp�v���p�e�B��write���\�b�h}
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
  OrigRegExp := Str;{�v���v���Z�b�T��ʂ�O�̐��K�\����ޔ�}
  with FPreProcessor do begin
    TargetRegExpStr := Str;
    Run;
    Str := ProcessedRegExpStr;
  end;

  try
    FCurrentIndex := FindRegExpInList(Str);
    {FRegExpList���ɃL���b�V������Ă��Ȃ��Ƃ��́A�R���p�C��}
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
    {��O�����������Ƃ��́A��Ƀk�����K�\����ݒ肷��B}
    on Exception do begin
      FCurrentIndex := 0;
      FRegExp := '';
      raise;
    end;
  end;
end;

{RegExp�v���p�e�B��read���\�b�h}
function TRegularExpression.GetProcessedRegExp: String;
begin
  result := FRegExpList[FCurrentIndex];
end;

{ListOfFuzzyCharDic�v���p�e�B read���\�b�h}
function TRegularExpression.GetListOfFuzzyCharDic: TList;
begin
  result := FPreProcessor.ListOfFuzzyCharDic;
end;

{GetListOfSynonymDic�v���p�e�B read���\�b�h}
function TRegularExpression.GetListOfSynonymDic: TList;
begin
  result := FPreProcessor.ListOfSynonymDic;
end;

{RegExpIsSimple�v���p�e�B read���\�b�h}
function TRegularExpression.GetRegExpIsSimple: Boolean;
begin
  result := GetCurrentDFA.RegExpIsSimple;
end;

{SimpleRegExp�v���p�e�B read���\�b�h}
function TRegularExpression.GetSimpleRegExp: String;
begin
  result := GetCurrentDFA.SimpleRegExpStr;
end;

{HasLHead�v���p�e�B read���\�b�h}
function TRegularExpression.GetHasLHead: Boolean;
begin
  result := GetCurrentDFA.RegExpHasLHead;
end;

{HasLTail�v���p�e�B write���\�b�h}
function TRegularExpression.GetHasLTail: Boolean;
begin
  result := GetCurrentDFA.RegExpHasLTail;
end;

{���݂̐��K�\���ɑΉ�����TRE_DFA�^�I�u�W�F�N�g�𓾂�}
function TRegularExpression.GetCurrentDFA: TRE_DFA;
begin
  result := TRE_DFA(FRegExpList.Objects[FCurrentIndex]);
end;

{DFA��ԕ\�̏�����Ԃ�\���m�[�h�ւ̃|�C���^�𓾂邱�Ƃ��ł���B}
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
  Self.RegExp := FRegExp; {�V�����ݒ�ōăR���p�C��}
end;

function  TRegularExpression.GetUseSynonymDic: Boolean;
begin
  result := FPreProcessor.UseSynonymDic;
end;

procedure TRegularExpression.SetUseSynonymDic(Val: Boolean);
begin
  FPreProcessor.UseSynonymDic := Val;
  Self.RegExp := FRegExp; {�V�����ݒ�ōăR���p�C��}
end;

function TRegularExpression.GetLineHeadWChar: WChar_t;
begin
  result := CONST_LINEHEAD;
end;

function TRegularExpression.GetLineTailWChar: WChar_t;
begin
  result := CONST_LINETAIL;
end;

{*****     ���K�\�������񁨍\���؍\����NFA��DFA �̕ϊ����s�� *****}
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

{��� DFAstate���當�����ɂ���đJ�ڂ��āA�J�ڌ�̏�Ԃ�Ԃ��B
 �������ɂ���đJ�ڏo���Ȃ����nil��Ԃ�}
function TRegularExpression.NextDFAState(DFAState: RE_pDFAState_t; c: WChar_t): RE_pDFAState_t;
var
  pSub: RE_pDFAStateSub_t;
begin
  {�P��DFAState������ pSub�̃����N�ł̓L�����N�^�N���X�������ɂȂ��ł��邱��
  ��O��Ƃ��Ă���B}
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

  {pText���k��������ŁA���K�\�����k��������Ɉ�v����Ƃ�}
  if (Byte(pText^) = CONST_NULL) and GetCurrentDFA.pInitialState.Accepted then begin
    pStart := pText;
    pEnd := pText;
    exit;
  end;

  {���ړ_���P�����Â��炵�Ȃ���}�b�`����ō�������������}
  while Byte(pText^) <> CONST_NULL do begin
    {DFA�̏�����Ԃ�ݒ�}
    pDFAState := Self.GetCurrentDFA.pInitialState;
    pp := pText;
    {DFA��ԕ\�ɕ�������͂��Ă����ă}�b�`����Œ�������������}
    repeat
      if pDFAState^.accepted then begin
      {�I����Ԃł���Ώꏊ���L�^���Ă����B
       ���ʂƂ��ă}�b�`�����ō��Œ��������L�^�����}
        pStart := pText;
        pEnd := pp;
      end;
      {���̏�ԂɑJ��}
      pDFAState := NextDFAState(pDFAState, PCharGetWChar(pp));
    until pDFAState = nil;

    {�}�b�`�����Ƃ���Exit}
    if pStart <> nil then
      exit;

    {���ڈʒu���P�������i�߂�B}
    if IsDBCSLeadByte(Byte(pText^)) then
      Inc(pText, 2)
    else
      Inc(pText);
  end;
  {�}�b�`���Ȃ��B}
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
    {���ڈʒu���P�������i�߂�B}
    if IsDBCSLeadByte(Byte(pText^)) then
      Inc(pText, 2)
    else
      Inc(pText);
  end;

  if DFA.RegExpHasLTail and (NextDFAState(pInitialDFAState, LineTailWChar) <> nil) then begin
  {���K�\�����������^�L�����N�^�݂̂̂Ƃ�(RegExp = '$')�̓��ꏈ��}
    pStart := pText;
    pEnd := pText;
  end;
 end;

function TMatchCORE.MatchHead(pText: PChar; pDFAState: RE_pDFAState_t): PChar;
var
  pEnd: PChar;
begin
{���K�\�����s�����^�L�����N�^���܂�ł���}
  if GetCurrentDFA.RegExpHasLHead then begin
    result := MatchInSide(pText, NextDFAState(pDFAState, LineHeadWChar));
    if result <> nil then begin
    {�}�b�`�����B���̎��_�ŁAresult <> nil �m��}
      pEnd := result;
      {����ɁARegExp = '(^Love|Love me tender)'�ŁAText = 'Love me tender. Love me sweet'
       �̏ꍇ�ɍō��Œ��Ń}�b�`����̂́A'Love me tender'�łȂ���΂Ȃ�Ȃ��̂ŁA���ׂ̈�
       �}�b�`�������s���B}
      result := MatchInside(pText, pDFAState);
      if (result = nil) or (pEnd > result) then
        result := pEnd;
    end;
  end else begin
{���K�\�����s�����^�L�����N�^���܂�ł��Ȃ�}
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
    {�I����Ԃł���Ώꏊ���L�^���Ă����B
     ���ʂƂ��ă}�b�`�����ō��Œ��������L�^�����}
        result :=  pEnd;
    end;
    pPrevDFAState := pDFAState;
    {DFA����ԑJ�ڂ�����}
    WChar := PCharGetWChar(pEnd);
    pDFAState := NextDFAState(pDFAState, WChar);
  until pDFAState = nil;

  if (IsLineEnd(WChar) or (WChar = CONST_NULL)) and
    (NextDFAState(pPrevDFAState, LineTailWChar) <> nil) then begin
    {�s�����^�L�����N�^����͂��āAnil�ȊO���A���Ă���Ƃ��͕K���A�}�b�`����}
      result := pEnd;
      if WChar <> CONST_NULL then
        Dec(result); {CR($0d)�̕� Decrement}
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
  
  ListOfFuzzyCharDic.Add(RE_FuzzyCharDic); {�L�����N�^���ꎋ������ǉ�}
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

{�����񒆂�'\' �� ���p���ꂽ�L�����N�^����������B \n, \t \\ ...}
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

{Sub, GSub���\�b�h�Ŏg�p�B '&'���}�b�`����������ɒu������}
function TAWKStr.Substitute_MatchStr_For_ANDChar(Text: String; MatchStr: String): String;
var
  i: Integer;
  aStr: String;
  WCh, WCh2: WChar_t;
begin
  i := 1;
  aStr := '';
{'\&'��'\\&'�ɂ��Ă���}
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

{�G�X�P�[�v�E�V�[�P���X������}
  Text := ProcessEscSeq(aStr);

{'&' �� MatchStr�Œu�����A'\&'��'&'�ɒu����}
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
    RStart := pStart - PChar(Text)+1; {RStart�͂P�x�[�X}
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
{�}�b�`����}
    MatchStr := Copy(Text, pStart-PChar(Text)+1, pEnd-pStart); {�}�b�`��������}
    Delete(Text, pStart-PChar(Text)+1, pEnd-pStart);
    {SubText�̂Ȃ���&�L�����N�^���}�b�`��������(MatchStr)�Œu������B}
    SubText := Substitute_MatchStr_For_ANDChar(SubText, MatchStr);
    Insert(SubText, Text, pStart-PChar(Text)+1);
    result := True;
  end else begin
{�}�b�`���Ȃ�}
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
  ResultText := ''; {���ʂ̕����������ϐ�}
  aText := Text;    {�����ΏۂƂ��Ďg��}
  result := 0;
  FMatchProc(PChar(aText), pStart, pEnd);
  if pStart = nil then
    exit  {�����}�b�`���Ȃ�}
  else if aText = '' then begin
    result := 1; {�}�b�`������ Text=''}
    Text := Substitute_MatchStr_For_ANDChar(SubText, '');
    exit;
  end;

  {�}�b�`���� Text <> ''}
  while True do begin
    ResultText := Concat(ResultText, Copy(aText, 1, pStart-PChar(aText)));{�O������}
    MatchStr := Copy(aText, pStart-PChar(aText)+1, pEnd-pStart);   {�}�b�`��������������}
    MatchStr := Substitute_MatchStr_For_ANDChar(SubText, MatchStr);
    ResultText := Concat(ResultText, MatchStr);{+ �u��������}

    if pStart = pEnd then begin {�󕶎���Ƀ}�b�`�����Ƃ��̓��ꏈ��}
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
    {Chr($0a)�𒲂ׂ�ׂ����Ȃ̂ŁA�Q�o�C�g�����̍l���s�v�B aText = ''�͂��肦�Ȃ�}
    aText := String(pEnd);
    {�}�b�`��������������̌�̕�����aText�ɐݒ�}
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
  StrList.Clear;{���ʕ����񃊃X�g�̓��e�N���A}
  Str := '';
  while Text <> '' do begin
    FMatchProc(PChar(Text), pStart, pEnd);
    if pStart = nil then begin
    {�}�b�`���Ȃ������Ƃ�}
      StrList.Add(Concat(Str, Text));
      Str := '';
      break;
    end else if (pStart = PChar(Text)) and (pStart = pEnd) then begin
    {�擪�̃k��������Ƀ}�b�`�����Ƃ��̓��ꏈ��}
      if IsDBCSLeadByte(Byte(Text[1])) then begin
        Str := Concat(Str, Copy(Text, 1, 2));
        Text := Copy(Text, 3, Length(Text));
      end else begin
        Str := Concat(Str, Text[1]);
        Text := Copy(Text, 2, Length(Text));
      end;
    end else begin;
    {�}�b�`����}
      StrList.Add(Concat(Str, Copy(Text, 1, pStart-PChar(Text))));
      Str := '';
      Text := String(pEnd);
      if Text = '' then begin
      {�Ō���Ƀ}�b�`�����Ƃ��̓��ꏈ��}
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
  FpCancelRequest := @CancelRequest; {CancelRequest��True�œr���I������}

  FBuffSize := 1024*100; {�o�b�t�@�̃T�C�Y}
  FTailMargin := 100;

  FFileName := aFileName;
  System.FileMode := 0; {�t�@�C���A�N�Z�X���[�h ��ǂݏo����p�ɐݒ�}
  AssignFile(FF, FFileName);
  try
    Reset(FF, 1);
  except
    on E: EInOutError do begin
      raise EFileNotFound.Create(E.Message);
    end;
  end;
  FFileOpened := True;  { �t�@�C���I�[�v���̃t���O�BDestroy�Ŏg�p����}
  FpBuff := AllocMem(FBuffSize+FTailMargin);
  FpBuff^ := Chr($0a);  { �t�@�C���擪�s�̍s���ɂk�e Chr($0a)��t��}
  BuffRead(FpBuff+1);
  Inc(FReadCount);      { �擪�̂k�e($0a)�̂Ԃ�����Z}
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

  {�ǂݍ��񂾃f�[�^�̍Ō�Ƀk���E�L�����N�^����������}
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
  {FBrokenLine(String�^) �̒���Chr(0)�ɒB�����Ƃ��B}
    FpBase := FpBuff;
  end else begin    
  {FpBuff(PChar) �o�b�t�@�̒���Chr(0)�ɒB�����Ƃ��B}    
    if FpBase < FpBuff+FReadCount then begin
    {�t�@�C�����̕s���ȃk���L�����N�^ Chr(0)�́ASpace($20)�ɕ␳}   
      FpBase^ := Chr($20);    
    end else begin    
    {�o�b�t�@�̏I���ɗ���}    
      if Eof(FF) then begin   
      {�t�@�C���̏I���ɗ���}    
        if Ch = Chr(0) then   
          Dec(FpBase);    
        raise EEndOfFile.Create('End Of File');   
      end else begin    
      {�t�@�C�����܂��ǂ߂�}    
        if (FpLineBegin >= PChar(FBrokenLine)) and    
        (FpLineBegin < (PChar(FBrokenLine)+Length(FBrokenLine))) then begin
        {FpLineBegin��FBrokenLine�̒����w���Ă���B}    
          Distance := FpLineBegin-PChar(FBrokenLine);   
          FBrokenLine := Concat(FBrokenLine, String(FpBuff));   
          FpLineBegin := PChar(FBrokenLine)+Distance;   
          BuffRead(FpBuff);   
          FpBase := FpBuff;   
        end else begin    
        {FpLineBegin���o�b�t�@�����w���Ă���̂ł�������FBrokenLine�����}    
          FBrokenLine := String(FpLineBegin);   
          BuffRead(FpBuff);   
          FpBase := FpBuff;   
          FpLineBegin := PChar(FBrokenLine);    
        end;
      end;    
    end;    
  end;    
end;

{�@�\�F FpBase���C���N�������g���āA���̂P�o�C�g���w���悤�ɂ���B}
function TTxtFile.IncPBase: Char;
var
  ApBase: PChar;
begin
  result := FpBase^;
  Inc(FpBase);
  if FpBase^ = Chr(0) then
  {�k���E�L�����N�^�̏���}
    IncPBaseNullChar(result);
  if result = Chr($0a) then begin
  {���s����}
    if (FpBase < PChar(FBrokenLine)) or (FpBase > (PChar(FBrokenLine) +
    Length(FBrokenLine))) then begin
    {FpBase���o�b�t�@���w���Ă���Ƃ�}
      FBrokenLine := '';
      FpLineBegin := FpBase;
      Inc(FLineNo);
    end else begin
    {FpBase��FBrokenLine�����w���Ă���Ƃ�}
      FpLineBegin := FpBase;
      Inc(FLineNo);
    end;
  end;
  if FpBase^ = Chr($0d) then begin
    ApBase := FpBase;
    Inc(FpBase);
    if FpBase^ = Chr(0) then
    {�k���E�L�����N�^�̏���}
      IncPBaseNullChar(result);
    if FpBase^ <> Chr($0a) then begin
    { CR($0d)�̎���LF($0a)�łȂ��Ƃ��́A$0d��$0a�ɒu������B}
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
  {���������̂���IncPBase���ߍ���}
    Ch := FpBase^;
    Inc(FpBase);
    if FpBase^ = Chr(0) then
    {�k���E�L�����N�^�̏���}
      IncPBaseNullChar(Ch);
    if Ch = Chr($0a) then begin
    {���s����}
      if (FpBase < PChar(FBrokenLine)) or (FpBase > (PChar(FBrokenLine) +
      Length(FBrokenLine))) then begin
      {FpBase���o�b�t�@���w���Ă���Ƃ�}
        FBrokenLine := '';
        FpLineBegin := FpBase;
        Inc(FLineNo);
      end else begin
      {FpBase��FBrokenLine�����w���Ă���Ƃ�}
        FpLineBegin := FpBase;
        Inc(FLineNo);
      end;
    end;
    if FpBase^ = Chr($0d) then begin
      ApBase := FpBase;
      Inc(FpBase);
      if FpBase^ = Chr(0) then
      {�k���E�L�����N�^�̏���}
        IncPBaseNullChar(ApBase^);
      if FpBase^ <> Chr($0a) then begin
      { CR($0d)�̎���LF($0a)�łȂ��Ƃ��́A$0d��$0a�ɒu������B}
        if FpBase = FpBuff then
          FpBase := PChar(FBrokenLine)+Length(FBrokenLine)-1
        else
          FpBase := ApBase;
        FpBase^ := Chr($0a);
      end
    end;
    {���������̂���IncPBase���ߍ���}
    result := Byte(Ch);
    case result of
      $81..$9F, $E0..$FC: begin
          {���������̂���IncPBase���ߍ���}
          Ch := FpBase^;
          Inc(FpBase);
          if FpBase^ = Chr(0) then
          {�k���E�L�����N�^�̏���}
            IncPBaseNullChar(Ch);
          if Ch = Chr($0a) then begin
          {���s����}
            if (FpBase < PChar(FBrokenLine)) or (FpBase > (PChar(FBrokenLine) +
            Length(FBrokenLine))) then begin
            {FpBase���o�b�t�@���w���Ă���Ƃ�}
              FBrokenLine := '';
              FpLineBegin := FpBase;
              Inc(FLineNo);
            end else begin
            {FpBase��FBrokenLine�����w���Ă���Ƃ�}
              FpLineBegin := FpBase;
              Inc(FLineNo);
            end;
          end;
          if FpBase^ = Chr($0d) then begin
            ApBase := FpBase;
            Inc(FpBase);
            if FpBase^ = Chr(0) then
            {�k���E�L�����N�^�̏���}
              IncPBaseNullChar(ApBase^);
            if FpBase^ <> Chr($0a) then begin
            { CR($0d)�̎���LF($0a)�łȂ��Ƃ��́A$0d��$0a�ɒu������B}
              if FpBase = FpBuff then
                FpBase := PChar(FBrokenLine)+Length(FBrokenLine)-1
              else
                FpBase := ApBase;
              FpBase^ := Chr($0a);
            end
          end;
          {���������̂���IncPBase���ߍ���}
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
  {FBrokenLine(String�^) �̒���Chr(0)�ɒB�����Ƃ��B}
    FpForward := FpBuff;
  end else begin
  {FpBuff �o�b�t�@�̒���Chr(0)�ɒB�����Ƃ��B}
    if FpForward < FpBuff+FReadCount then begin
    {�t�@�C�����̕s���ȃk���L�����N�^ Chr(0) �� Space($20)�ɂ���B}
      FpForward^ := Chr($20);
    end else begin
    {�o�b�t�@�̏I���ɗ���}
      if Eof(FF) then begin
      {���łɃt�@�C���̏I���ɒB���Ă���Ƃ�}
        if Ch = Chr(0) then
          Dec(FpForward);     {��n����resut = Chr(0)��Ԃ��悤�ɂ���}
        exit;
      end else begin
      {�܂��t�@�C����ǂ߂�Ƃ�}
        if (FpLineBegin >= PChar(FBrokenLine)) and
        (FpLineBegin < PChar(FBrokenLine)+Length(FBrokenLine)) then begin
        {FpLineBegin��FBrokenLine�����w���Ă���Ƃ�}
          Distance := FpLineBegin-PChar(FBrokenLine);
          if (FpBase >= PChar(FBrokenLine)) and
          (FpBase < PChar(FBrokenLine)+Length(FBrokenLine)) then
          {FpBase��FBrokenLine�����w���Ă���Ƃ�}
            Distance2 := FpBase-PChar(FBrokenLine)
          else
          {FpBase�̓o�b�t�@�����w���Ă���Ƃ�}
            Distance2 := Length(FBrokenLine)+FpBase-FpBuff;
          FBrokenLine := Concat(FBrokenLine, String(FpBuff));
          FpLineBegin := PChar(FBrokenLine)+Distance;
          FpBase := PChar(FBrokenLine)+Distance2;
          BuffRead(FpBuff);
          FpForward := FpBuff;
        end else begin
        {FpLineBegin���o�b�t�@�����w���Ă���Ƃ�}
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
  {�k���E�L�����N�^�̏���}
  if FpForward^ = Chr(0) then
    GetCharNullChar(result);

  if result = Chr($0d) then begin
    if FpForward^ <> Chr($0a) then begin
    {CR($0d)�̎���LF($0a)�łȂ��Ƃ��́A$0d��$0a�ɒu������B}
      if FpForward = FpBuff then
        FpForward := PChar(FBrokenLine)+Length(FBrokenLine)-1
      else
        FpForward := ApForward;
      FpForward^ := Chr($0a);
      result := Chr($0a);
    end else begin
      result := FpForward^;
      Inc(FpForward);
      {�k���E�L�����N�^�̏���}
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
  {�k���E�L�����N�^�̏���}
  if FpForward^ = Chr(0) then
    GetCharNullChar(Ch);

  if Ch = Chr($0d) then begin
    if FpForward^ <> Chr($0a) then begin
    {CR($0d)�̎���LF($0a)�łȂ��Ƃ��́A$0d��$0a�ɒu������B}
      if FpForward = FpBuff then
        FpForward := PChar(FBrokenLine)+Length(FBrokenLine)-1
      else
        FpForward := ApForward;
      FpForward^ := Chr($0a);
      Ch := Chr($0a);
    end else begin
      Ch := FpForward^;
      Inc(FpForward);
      {�k���E�L�����N�^�̏���}
      if FpForward^ = Chr(0) then
        GetCharNullChar(Ch);
    end;
  end;
  result := Byte(Ch);
  case result of
    $81..$9F, $E0..$FC: begin
        Ch := FpForward^;
        Inc(FpForward);
        {�k���E�L�����N�^�̏���}
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

    {�s����������B}
    while FpBase^ <> Chr($0a) do begin
      IncPBase;
    end;

  if (FpLineBegin >= PChar(FBrokenLine)) and
  (FpLineBegin < PChar(FBrokenLine)+Length(FBrokenLine)) then begin
  {FpLineBegin��FBrokenLine�����w���Ă���Ƃ�}
    if (FpBase >= PChar(FBrokenLine)) and
    (FpBase < PChar(FBrokenLine)+Length(FBrokenLine)) then begin
    {FpBase��FBrokenLine�����w���Ă���Ƃ�}
      result.Line := Copy(FBrokenLine, FpLineBegin-PChar(FBrokenLine)+1,
                        FpBase-FpLineBegin);
    end else begin
    {FpBase�̓o�b�t�@�����w���Ă���Ƃ�}
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

  ListOfFuzzyCharDic.Add(RE_FuzzyCharDic); {�L�����N�^���ꎋ������ǉ�}
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
  {OnMatch�C�x���g�n���h�����ݒ肳��Ă��Ȃ��Ƃ��́A�������Ȃ�}
  if not Assigned(FOnMatch) then
    exit;

  FCancel := False;
  DFA := GetCurrentDFA;
  pInitialDFAState := DFA.pInitialState;
  try
    TxtFile := TTxtFile.Create(FileName, Self.FCancel);
  except on EEndOfFile do exit; {�t�@�C���T�C�Y�O�̂Ƃ���exit} end;

  try
    try
      {����}
      while True do begin
        repeat
          WChar := TxtFile.AdvanceBase;
          {��NextDFAState���\�b�h���ߍ���}
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
          {��NextDFAState���\�b�h���ߍ���}
        until pDFAState <> nil;

        while True do begin
          if pDFAState^.accepted then begin
          {�}�b�`����}
            LineInfo := TxtFile.GetThisLine;
            FOnMatch(Self, LineInfo);
            break;
          end;

          {DFA����ԑJ�ڂ�����}
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
  {OnMatch�C�x���g�n���h�����ݒ肳��Ă��Ȃ��Ƃ��́A�������Ȃ�}
  if not Assigned(FOnMatch) then
    exit;

  try
    TxtFile := TTxtFile.Create(FileName, Self.FCancel);
  except on EEndOfFile do exit; {�t�@�C���T�C�Y�O�̂Ƃ���exit}  end;

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
