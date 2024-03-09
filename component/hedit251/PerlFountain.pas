(*********************************************************************

  PerlFountain.pas

  ver 1.03

  start  2001/09/11
  update 2004/02/03

  Copyright (c) 2001 �{�c���F <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  Perl �X�N���v�g��\�����邽�߂� TPerlFountain �R���|�[�l���g��
  TPerlFountainParser �N���X

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
    FAnk: TFountainColor;                  // ���p����
    FBackQuotation: TFountainColor;        // ``
    FComment: TFountainColor;              // �R�����g����
    FDBCS: TFountainColor;                 // �S�p�����Ɣ��p����
    FDoubleQuotation: TFountainColor;      // ""
    FHere: TFountainColor;                 // �q�A�h�L�������g
    FHereHtml: Boolean;                    // �q�A�h�L�������g���� HTML �^�O��F�����邵�Ȃ��t���O
    FInt: TFountainColor;                  // ���l
    FLiteralQuotation: TFountainColor;     // ���p q//, qq//, qx//, qw//
    FPattern: TFountainColor;              // �p�^�[���}�b�`�ƒu������ //, m//, qr//, s///, tr///
    FPerlVar: TFountainColor;              // �ϐ�
    FSingleQuotation: TFountainColor;      // ''
    FSymbol: TFountainColor;               // �L��
    FTagAttribute: TFountainColor;         // border
    FTagAttributeValue: TFountainColor;    // = �̒���̃g�[�N��
    FTagColor: TFountainColor;             // �^�O�S��
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

  �g�[�N���̎擾���@�ɂ���

  �� �ǉ����ꂽ�f�[�^�t�B�[���h

  ver 2.34 ���� TRowAttributeData ��

    RowAttribute: TRowAttribute;
    PrevRowAttribute: TRowAttribute;
    Remain: Integer;
    DataStr: String;

  �̃f�[�^�t�B�[���h���ǉ�����Ă���Bcf heStringList.pas, heRaStrings.pas

  Remain, DataStr �́A�s���ɍ��킹�ė��p����t�B�[���h�Ȃ̂ŁA
  ���N���X�� TFountainParser.LastTokenBracket ���\�b�h�ł́A�X�V������
  �s���Ă��Ȃ��B�����̃t�B�[���h�f�[�^�𗘗p���ď�Ԃ�\������Ƃ��́A
  LastTokenBracket ���\�b�h�� override ���Ď��̍s�֏�Ԃ��󂯌p��������
  �s��Ȃ���΂Ȃ�Ȃ��B


  �� '', ``, "" �ɂ����p

  '' toSingleQuotation
  TFountainParser.SingleQuotationProc �̏����ɂ�肽���Ƃ��낾���A
  '''' �ɑΉ����郋�[�`���ɂȂ��Ă���̂ŁASingleQuotationProc ��
  override ���Ă���BFTokenMethodTable �͊��N���X�Őݒ肳��Ă���B

  `` toBackQuotation
  SingleQuotationProc �Ɠ��l�̏����菇�ɂ�� BackQuotationProc ��
  �������AtoBackQuotation �g�[�N�����擾����B
  �R�s�ȏ�ɓn���Đ܂�Ԃ��\������Ă���ꍇ�i WrappedByte = 0 �j�̂��߂�
  FTokenMethodTable[toBackQuotation] �� BackQuotationProc ��ݒ肵�Ă���B

  "" toDoubleQuotation
  \" ����������̂ŁA�]���� DoubleQuotationProc �ł͑Ή��o���Ȃ��B
  �]���̕����ŁA\ �𔭌������Ƃ��A���� " ���X�L�b�v��������@�����邪�A
  �^�u�������܂ރg�[�N���Ɛ��蓾��̂ŁAWrappedByte �̎d�g�݂𗘗p�o��
  �Ȃ����Ƃ���A�܂�Ԃ��ɂ���� \" �����f����Ă���Ƃ��A���̍s�̐擪��
  ���� " �� \", " " �̂ǂ���̖������𔻕ʂ�����@����������ł���B

  �����ŁA" �𔭌��������_�� toDoubleQuotation ��Ԃ��AFElementIndex ��
  " �� Ord �l�ōX�V����B�Ȍ�̃p�[�X�����ł� SymbolProc �� " �𔭌�����
  �܂ŁAFElementIndex �� " �� Ord �l�ł����ԂŎ擾�����g�[�N���́A
  ���ׂ� toDoubleQuotation �ɕύX����Ƃ��������� override ���ꂽ
  DoubleQuotationProc, NextToken ���\�b�h�� UpdateToken ���\�b�h�ōs��
  ���Ƃɂ���B

  �g�[�N�����܂�Ԃ���Ă���ꍇ�A���N���X��
  FTokenMethodTable[toDoubleQuotation] �̎d�g�݂ɂ����
  DoubleQuotationProc �����s����邪�A���̎��� SymbolProc �̏����ɂ��
  �g�[�N���� toDoubleQuotation �ɍX�V�����B

  \" �� BackSlashProc ���\�b�h�� toBackSlash �g�[�N���Ƃ��Ĉ�����̂ŁA
  \" ���܂�Ԃ��ɂ���ĕ��f����Ă��Ă��AStartToken, WrappedByte �̎d�g��
  �őΉ��o����B

  �܂��AraCrlf �ȍs�ł́A" �ɂ����p��Ԃ��������Ȃ���΂Ȃ�Ȃ��̂ŁA
  override ���� LastTokenBracket ���\�b�h�ł��̏������s���B

  �����̏����ɂ���āAtoDoubleQuotation �́A�^�u�������܂ނ��Ƃ�
  �Ȃ��Ȃ�̂� IncludeTabToken �̕Ԓl���珜�O���Ă���B

  ���AHTML �^�O���Ŏ擾���� toDoubleQuotation �́AFElementIndex ��
  �d�g�݂𗘗p�o���Ȃ��̂ŁA�]���̎擾�������̗p���Ă���B
  �Ȃ̂ŁALastTokenBracket �� IncludeTabToken �𗘗p�����ʂł́A
  ���̂��ƂɑΉ����Ă���B��₱�����E�E�E

  �^�u�������܂ރg�[�N���� toDoubleQuotation �ɍX�V����邱�Ƃ�h������
  SingleQuotationProc, BackQuotationProc �ł́AFElementIndex �̒l��
  ���ʂ��Ă���B

  ���� FElementIndex �𔻕ʂ��鏈���́A���ׂẴg�[�N���擾���[�`����
  �s���Ă���B

  FElementIndex ���f���~�^�� Ord �l�ōX�V���ăf���~�^�𔭌�����܂�
  ���݂̃g�[�N�����Y���g�[�N���ɕϊ�����d�g�݂𗘗p����g�[�N���ł́A
  FTokenMethodTable �̍X�V��K�v�Ƃ��Ȃ��B�f�t�H���g�� SymbolProc
  �ł��邱�Ƃ��]�܂�������ł���B


  �� q//, qq//, qx//, qw// �ɂ����p

  q, qq, qx, qw �ɂ����p�ł́AtoDoubleQuotation �Ɠ��l�̎d�g�݂ɂ����
  �g�[�N�����擾�� toLiteralQuotation ��Ԃ��B

  q..qw �̌�ɑ����P������ QuoteChars �Ɋ܂܂�Ă��鎞�AtoLiteralQuotation
  �Ƃ��ď��������BPerl �ł� q..qw �Ǝ��̂P�����̊Ԃɋ󔒂̑��݂��������
  ���ATPerlFountainParser �ł͋����Ă��Ȃ��B

  q..qw �̎��̂P�����i <, (, [, { �̏ꍇ�� >, ), ], } �ɕϊ������j��
  Ord �l�� ElementIndex �Ƃ��ė��p����B

  �g�[�N���̏I���� override ���� SymbolProc �Ŏ擾����B

  �����s�ɓn����p��������̂ŁAraCrlf �ȍs�ŏ��������鏈���͍s��Ȃ��B

  �f���~�^�� BracketChars �̏ꍇ�A�l�X�g�ɂ��Ώ�����K�v�����邪�A
  �p�^�[���}�b�`���Q�ƁB


  �� �p�^�[���}�b�`

  //, m##, m[], qr//imosx
  toLiteralQuotation �̎d�g�݂𗘗p���AtoPatternMatch ��Ԃ����A�f���~�^
  �� BracketChars �ŁA���ꂪ�l�X�g����Ă���ꍇ�ɂ��Ă��Ή�����
  ����΂Ȃ�Ȃ��B

  �l�X�g�J�E���^�ɂ� FRemain �f�[�^�t�B�[���h�𗘗p���A�p�^�[���}�b�`��
  �g�[�N���𔭌��������_�ŁA�l�X�g�J�E���^���P�ɏ���������B

  SymbolProc �ł́A�Y���f���~�^�� BracketChars �̂Ƃ��A�΂ɂȂ�
  �f���~�^�𔭌�������A�l�X�g�J�E���^���C���N�������g���A�Y���f���~�^
  �𔭌�������A�l�X�g�J�E���^���f�N�������g���A�J�E���^���O�ɂȂ�����
  �^�̃f���~�^�ł���Ɣ��f���Ă���B

  // �̏ꍇ�A/ �̎��̂P�������󔒂łȂ��ꍇ���� toPatternMatch ��
  �擾���Ă���B


  �� �u������

  s///, s###, s[][]egimosx
  toPatternMatch �̏����ɂ�邪�A�g�[�N���� toSubstitute1, toSubstitute2,
  �̂Q�ɕ����ď������s���B

  s/, s#, s[ �܂ł��擾�������_�ŁAElementIndex �� �f���~�^�� Ord �l��
  �X�V���AtoSubstitue1 ��Ԃ��B

  ���̃f���~�^�𔭌��������_�ŁAtoSubstitute2 ���擾���AFRemain ���ēx
  �P�ŏ���������B���̎��A�f���~�^�� BracketChars �̏ꍇ�� FElementIndex
  �� SeekOpenBracketElement �ɍX�V���āAOpenBracketChars (, <, [, { ��
  ��������BOpenBracketChars �f���~�^�𔭌�������A�f���~�^�����o�[�X
  ���āA), >, ], } ���� Ord �l�� FElementIndex ���X�V����B

  ���̃f���~�^�𔭌��������_�ŁA�������I������B

  tr///, tr###, tr[][], y///, y###, y[][]cds
  toSubstitute1..2 �̏����ɂ�邪�AtoTranslitarate1, toTranslitarate2,
  ���擾����B


  �� �q�A�h�L�������g�ɂ���

  << �ɑ���������� FDataStr �ɕێ����AFElementIndex ��
  HereDocumentElement �ɐݒ肷��Boverride ���� LastTokenBracket ��
  �P�s������Ƃ��̕�����𔻕ʂ��A�q�A�h�L�������g��Ԃ��������Ă���B
  HereDocumentElement ��ԂŎ擾�����g�[�N���́A���L HTML �^�O��������
  �S�� toHereDocument �֍X�V�����B


  �� �q�A�h�L�������g���� HTML �^�O�ɂ���

  �q�A�h�L�������g�Ƃ��ĔF�������̈�ł́A

  FElementIndex = HereDocumentElement
  FRemain = 0

  �ł��邱�Ƃ��ۏ؂���Ă���Bcf AngleBracketProc

  ���̗̈���� <, > �̒��ɂ����Ԃ� FRemain = TagBlockElement �Ƃ���
  ���ƂŁA�^�O���̃g�[�N���ł��邱�Ƃ�\������B

  �^�O�̒��ł��邱�Ƃ́A
  (FElementIndex = HereDocumentElement) and (FRemain = TagBlockElement)
  �Ŏ擾�o���邪�A���̔��ʂ��s�� InTag ���\�b�h���p�ӂ���Ă���B

  �^�O���ł͈ȉ��̃g�[�N�����擾����B

  {toTagStart              = Char(50);} <
  {toTagEnd                = Char(51);} >
  {toTagElement            = Char(52);} table
  {toTagAttribute          = Char(53);} border
  {toTagAttributeDelimiter = Char(54);} =
  {toTagAttributeValue     = Char(55);} 0

  toTagStart, toTagEnd
  �q�A�h�L�������g���� < �𔭌��������_�� FFountain.HereHtml �v���p�e�B��
  True �ɐݒ肳��Ă���ꍇ�AtoTagStart ���擾���AFPrevToken �ɕێ�����B
  �܂� FRemain �� TagBlockElement �ɍX�V���A�^�O����Ԃł��邱�Ƃ�ێ�����B
  > �𔭌��������_�� toTagEnd ���擾���AFRemain �� NormalElementIndex ��
  �X�V����B

  toTagElement
  toTagStart �̒���̃g�[�N�������ׂ� UpdateToken ���\�b�h��
  toTagElement �ɍX�V����B
  / ���������� SlashProc �ł� toTagStart �̒��ォ�ǂ����𔻕ʂ���
  toTagElement ���擾���Ă���B
  �܂�Ԃ��\������Ă���ꍇ�ɂ��Ή����邽�߂ɁAFTokenMethodTable ��
  �X�V����B

  toTagAttribute
  UpdateToken ���\�b�h�ŁAFPrevToken �̒l�ɉ����Č��݂̃g�[�N�����X�V����
  ���Ƃɂ���Ď擾����B
  case FPrevToken of
    toTagStart:
      toAnk -> toTagElement
    toDoubleQuotation, toSingleQuotation, toTagElement, toTagAttributeValue:
      �S�� -> toTagAttribute; (*1)
    toTagAttribute:
      �� toTagAttributeDelimiter -> toTagAttribute; (*2)
  end;
  �܂�Ԃ��\������Ă���ꍇ�ɂ��Ή����邽�߂ɁAFTokenMethodTable ��
  �X�V����B

  toTagAttributeDelimiter
  = ���������� EqualProc �Ń^�O���ɂ���ꍇ�����擾�����B

  toTagAttributeValue
  FPrevToken �� TagAttributeDelimiter �̏ꍇ�͂��ׂ� toTagAttributeValue
  �ɍX�V���鏈���� override ���� NormalTokenProc �ōs���B
  �܂�Ԃ��\������Ă���ꍇ�ɂ��Ή����邽�߂ɁAFTokenMethodTable ��
  �X�V����B


  �� �q�A�h�L�������g���� &amp; �ɂ���

  toAmpersand
  & ���������� AmpersandProc �ł́A�q�A�h�L�������g�̒��ɂ����āA
  FFountain.HereHtml �v���p�e�B�� True �ɐݒ肳��Ă���ꍇ�A
  toAmpersand ���擾���Ă���B
  �܂�Ԃ��\������Ă���ꍇ�ɂ��Ή����邽�߂ɁAFTokenMethodTable ��
  �X�V����B


  �� pod �ɂ���

  = ���������� EqualProc �� NormalElementIndex ��Ԃ��A�s���� = ��
  ���鎞�Ahead1, head2, item, over, back, pod, for, begin, end �̌�傪
  �����Ă���ꍇ�� FElementIndex �� PodElement �ɍX�V���Ă���A
  CommenterProc �����s�� toComment ���擾����B
  PodElement ��Ԃ̏ꍇ�́A�s���� =cut �𔻕ʂ��ANormalElementIndex ���
  �ɖ߂��Ă��� CommenterProc �����s�� toComment ���擾����B
  UpdateToken ���\�b�h�ł� PodElement ��ԂŎ擾�����g�[�N�������ׂ�
  toComment �ɍX�V���Ă���B

debug
  �t�H�[�}�b�g
  �����֐�
  �t�@�C���e�X�g���Z�q
  ����ϐ�
    
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
      '0': // �W�i��
        begin
          Inc(FP);
          while FP^ in ['0'..'7'] do
            Inc(FP);
        end;
      'x': // �P�U�i��
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
    // StartToken �� toDoubleQuotation �̎��́ASymbolProc �ŏ��������B
    Inc(FP);
    FToken := toDoubleQuotation;
    FElementIndex := Ord('"');
    FRemain := 1;
  end
  else
    if InTag then
    begin
      // HTML �^�O�̒�
      // StartToken �� toDoubleQuotation �̏ꍇ�������ŏ��������B
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
  // StartPos �͂Q�ڂ� < �̎��̕������w���Ă���
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
    // �q�A�h�L�������g���ǂ����̔���

    // debug << ���Z�q�𖳎����Ă���B

    Ps := FP + 2; // �Q�ڂ� < �̎��̕������w���Ă���
    P := Ps;
    while not (P^ in [#0, #10, #13]) do
    begin
      Inc(P);
      if (P^ = ';') and ((P + 1)^ in [#0, #10, #13]) then
      begin
        // �g�[�N���̖����� ; �ł���
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
    // HTML �^�O���ǂ����̔��ʂ��s���B
    if (FElementIndex = HereDocumentElement) and // InTag �ł͂Ȃ�
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
// FStartToken = toTagElement, FWrappedByte = 0 �̎��Ɏ��s�����
begin
  AnkProc;
  FToken := toTagElement;
end;

procedure TPerlFountainParser.TagAttributeProc;
// FStartToken = toTagAttribute, FWrappedByte = 0 �̎��Ɏ��s�����
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
  ���O�̃g�[�N���� toTagAttributeDelimiter �̏ꍇ���s�����B
  border="0", border='0' �̂悤�� ", ' �Ŏn�܂��Ă���ꍇ�́A
  toDoubleQuotation, toSingleQuotation ���擾����B
  FStartToken = toTagAttributeValue, FWrappedByte = 0 �̎��ɂ����s�����B
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
// & FStartToken = toAmpersand, FWrappedByte = 0 �̎��ɂ����s�����B
begin
  if (FElementIndex = HereDocumentElement) and
     TPerlFountain(FFountain).HereHtml then // if InTag then �ł͂Ȃ�
  begin
    // �q�A�h�L�������g���ł̏���
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
      // �T�u���[�`���Ăяo��
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
  TPerlFountainParser �� toDoubleQuotation �̓^�u�������܂ޕ����񂪎擾
  ����邱�Ƃ͂Ȃ��̂ŁA���O����B
*)
begin
  Result := [toComment, toSingleQuotation, toBackQuotation];
end;

function TPerlFountainParser.ElementTokens: TCharSet;
(*
  �f���~�^�� Ord �l�� FElementIndex �֊i�[���ăg�[�N�����擾����d�g�݂�
  ���p����g�[�N���̏W����Ԃ��B
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
      // QuoteElements �𗘗p����g�[�N���̏��� cf SymbolProc
      FToken := FPrevToken
    else
      if InTag then
      begin
        // HTML �^�O�̒��ł̏���
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
          // �q�A�h�L�������g��
          FToken := toHereDocument
        else
          if FElementIndex = PodElement then
            // pod ��
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
    //    ^       ^  ��T���Ă�����
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
        // �l�X�g�J�E���^���C���N�������g����
        Inc(FRemain);
        inherited SymbolProc;
      end
      else
        if FP^ = Chr(FElementIndex) then
        begin
          // �Y���f���~�^�𔭌�����
          Dec(FRemain);
          if FRemain = 0 then
            case FPrevToken of
              toSubstitute1, toTranslitarate1:
                begin
                  // s/ / /, s[][], tr/ / /, tr[][]
                  //    ^      ^        ^       ^   �𔭌��������
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
                  //      ^      ^        ^       ^ �𔭌��������
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
          // StartToken �� toDoubleQuotation �̎��A�����ŏ��������̂�
          // �S�p�����ɑΉ�����
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
  // �q�A�h�L�������g��Ԃ̉���
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
    // ������
    S := Strings[Index];
    L1 := Length(S);
    // �S�󔒂̔��ʁi�p�^�[���P�C�Q�j
    SpaceOnly := True;
    for I := 1 to L1 do
      if S[I] <> #$20 then
      begin
        SpaceOnly := False;
        Break;
      end;
    if SpaceOnly then
      Exit;
    // �p�^�[���R�`�U�̏���
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
      //  Data.Remain �̍X�V
      //  FRemain �� BracketChars �̃l�X�g�ɑΉ����邽�߂ɗ��p�����
      //  ����B
      // m[[[[[]]]< // �܂�Ԃ�
      // ]]
      // ����������ꍇ�A�����ł� S �ɂ́Am[[[[[]]]]] ���i�[����Ă��邱��
      // ����A�p�[�X���I���������_�ł� FRemain ���O�ɂȂ��Ă��܂��̂ŁA
      // SourcePos < L1 �̎��_�ł� FRemain �� Data.Remain ���X�V����B
      if SourcePos < L1 then
        Data.Remain := FRemain;
      //////////////////////////////////////////////////

      if SourcePos + TokenLength > L1 then
        Break;
      Data.ElementIndex := FElementIndex;
      Data.PrevToken := FPrevToken;
    end;
    // �u���[�N�������_�ł̏���
    Data.WrappedByte := 0;
    Data.StartToken := toEof;

    //////////////////////////////////////////////////
    // Data.DataStr �̍X�V
    Data.DataStr := FDataStr;
    //////////////////////////////////////////////////

    if (Token <> toEof) and (SourcePos >= L1) then
      // �p�^�[���R�̔���
      Data.BracketIndex := NormalBracketIndex
    else
    begin
      P := SourcePos + TokenLength;
      if (SourcePos < L1) and (P > L1) then
      begin
        // �������ꂽ�g�[�N���̏����i�p�^�[���T�C�U�j
        Data.ElementIndex := E;
        L2 := Length(S);
        if (TempToken = toBracket) and
           (Data.BracketIndex = NormalBracketIndex) then
        begin
          // �������ꂽ���� toBracket
          Data.BracketIndex := B;
          if (P - L1 < Length(FFountain.Brackets[B].RightBracket)) then
          begin
            // ���� toBracket �̊Y�� RightBracket �̕����񒷂����Z��
            // �����񂪕������ꂽ�ꍇ
            Data.StartToken := toBracket;
            Data.WrappedByte := P - L1;
          end
        end
        else
          if TempToken <> toBracket then
          begin
            // �� toBracket �g�[�N�����������ꂽ�ꍇ
            // �\��ꂩ�ǂ����𔻕�
            WrappedTokenIsReserveWord(TempToken);
            Data.StartToken := TempToken;
            // �^�u�������܂܂Ȃ��g�[�N���ŁA�g�[�N���̖����� Index + 1
            // �̍Ō���O���AIndex + 1 ���܂�Ԃ���Ă��Ȃ��ꍇ��
            // WrappedByte ���X�V����

            //////////////////////////////////////////////////
            // InTag ���� toDoubleQuotation �����O���鏈����ǉ�
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
  // ���s�ɂ����p��Ԃ̉����B
  // �����s�ɓn���� " �ɂ����p���������̂ł���Εs�K�v�ȏ����B
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

