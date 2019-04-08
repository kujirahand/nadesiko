(*********************************************************************

  heFountain.pas

  start  2000/12/24
  update 2001/09/30

  Copyright (c) 2000,2001 �{�c���F <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  comments
  #LastTokenBracket ... �����񃊃X�g�ɕێ������f�[�^�ɂ���

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
    FBkColor: TColor;           // �w�i�F
    FColor: TColor;             // �O�i�F
    FStyle: TFontStyles;        // �t�H���g�X�^�C��
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
    FItemColor: TFountainColor; // �̈�̔w�i�F�A�O�i�F�A�t�H���g�X�^�C��
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
    FLeftBracket: String;       // ���͂ݕ��� ex {, (*
    FRightBracket: String;      // �E�͂ݕ��� ex }, *)
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
  FBkColor := Graphics.clNone; // D2 �ł� Graphics. �����̂��K�v
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

  TRowAttributeStringList �e�s�Ɋi�[��������؂蕪���鏈���ɕK�v��
  �f�[�^���擾���邽�߂̃��\�b�h

  ---------------------------------------------------------------------
  ������f�[�^�ɂ���
  BracketIndex: Integer;
    Fountain.Brackets �ւ̃C���f�b�N�X�B
  ElementIndex: Integer;
    �^�O�̒��Aproperty �߂̒��ȂǁA�\���v�f��\�����鐔�l�B
  WrappedByte: Integer;
    ��̃g�[�N�����܂�Ԃ��\�����ꂽ�ꍇ�̐܂�Ԃ��ʒu����g�[�N����
    �Ō�܂ł̒����B
  StartToken: Char;
    WrappedByte ����O�̎��̃g�[�N���̎�ʁB
  PrevToken: Char;
    ���O�̃g�[�N���̎�ʁB

  ---------------------------------------------------------------------
  �����̗���
  Strings �� Index �s�̕������ ������ Data: TRowAttribute �^�f�[�^��
  ����ăp�[�X���AIndex + 1 �s���p�[�X����ۂɕK�p�ȃf�[�^�� Data ��
  �i�[����B

  Index �s�� raWrapped �̏ꍇ�A���̂P�s���������������������p�[�X����B
  �p�[�X�����́AtoEof ���Ԃ邩�A�擾�����g�[�N���̏I���ʒu���AIndex �s��
  �����񒷈ȏ�ɂȂ������_�� Break ����B�i���}�̏ꍇ P > L1�j

   Index �s          L1 Index + 1 �s       L2
  +------------------+---------------------+
  |   ***************|**************       |
  +------------------+---------------------+
      S                            P

  ---------------------------------------------------------------------
  �g�[�N���̔z�u�p�^�[���� Data �̍X�V�����ɂ��āB

  �g�[�N���̔z�u�p�^�[��
               Index �s        L1 Index + 1 �s    L2
            +------------------+------------------+
  �p�^�[���P|  �S��          |  �S��          |
            +------------------+------------------+
  �p�^�[���Q|  �S��          |  ********        |
            +------------------+------------------+
  �p�^�[���R|  ********        |  ********        |
            +------------------+------------------+
  �p�^�[���S|    **************|  �S��          |
            +------------------+------------------+
  �p�^�[���T|    **************|**********        |
            +------------------+------------------+
  �p�^�[���U|    **************|******************|
            +------------------+------------------+

  �p�^�[���� Data �̍X�V�����Ƃ̊֌W��\�ɂ܂Ƃ߂�����

  �p�^�[�� BracketIndex  ElementIndex  WrappedByte  StartToken  PrevToken
      �P     -             -             0            toEof       -
      �Q     -             -             0            toEof       -
      �R     Normal        p             0            toEof       p
      �S     p             p             0            toEof       p
      �T     ���L�������ꂽ�g�[�N���̏����ɂ��
      �U     �V

  -: �����l�̂܂�
  p: �p�[�X�����ɂ���Ď擾���ꂽ�f�[�^�ɂ���čX�V����

  ��L�\���牺�L�̂悤�ȍX�V�������s���B
  �EWrappedByte, StartToken �͂O�������l�Ƃ���B
  �EIndex �s���󔒂����̏ꍇ�́A�X�V�������s��Ȃ��B�i�p�^�[���P�C�Q�j
  �E�p�^�[���R�̏ꍇ�́ABracketIndex �� NormalBracketIndex �Ƃ���B
  �E�p�^�[���S�̏ꍇ�́A�p�[�X�����Ŏ擾�����f�[�^�ōX�V����B
  �E�������ꂽ�g�[�N���ɂ��ẮA���L�������ꂽ�g�[�N���̏����ɂ��

  ---------------------------------------------------------------------
  WordWrap ���ɕ������ꂽ�g�[�N���̈����ɂ���

  �s���ɑO�̍s����܂������Đ܂�Ԃ��\�����ꂽ�g�[�N��������ꍇ�A
  ���̍s�� Tokens �v���p�e�B�ɂ͂��̃g�[�N���̎�ʂ��i�[����Ă���B
  WrappedBytes �v���p�e�B�ɂ́A���̒������i�[����Ă���B�i�O���i�[
  �����ꍇ�����邪�A��q����B�j

  �p�[�T�[�͏������J�n����� Tokens �v���p�e�B���Q�Ƃ��A���ꂪ
  �� toEof �̏ꍇ�́AWrappedBytes �v���p�e�B�l���Q�Ƃ��A��O�ł����
  ���̕��|�C���^��i�߂āATokens �v���p�e�B�Ŏw�肳�ꂽ�g�[�N���Ƃ���
  �Ԃ��d�l�ɂȂ��Ă���BWrappedBytes �v���p�e�B�l���O�̏ꍇ�́A
  FTokenMethodTable[Tokens �v���p�e�B�l] �̃��\�b�h�ɏ������ς˂���B
  ���������āA�V�����g�[�N�����`�����ꍇ�́A���̃g�[�N���ɑΉ�����
  FTokenMethodTable ��p�ӂ���K�v������B

  WrappedBytes �ɂO���i�[�����ꍇ�ɂ���

  �p�^�[���P�@�Q�s�ɂ܂�����g�[�N��
          +---------------------+
  1 �s��  |              *******|
          +---------------------+
  2 �s��  |*******              |
          +---------------------+

  �p�^�[���Q�@�R�s�ɂ܂�����g�[�N��
          +---------------------+
  1 �s��  |              *******|
          +---------------------+
  2 �s��  |*********************|
          +---------------------+
  3 �s��  |*******              |
          +---------------------+

  ��}�Q�s�ڂ��p�[�X����ꍇ�ɂ��čl����B

  �p�^�[���P�̏ꍇ�@WrappedBytes �͂V�ŗǂ����A�p�^�[���Q�̏ꍇ�Q�P��
  �i�[������ԂŁA�p�[�X����ƂQ�s�ڑS�̂���̃g�[�N���Ƃ��Ď擾����
  ��A�R�s�ڂ͐V���ȃg�[�N���Ƃ��Ĉ����邱�ƂɂȂ��Ă��܂��̂ŁA����
  �ꍇ�i P = L2 �łQ�s�ڂ� raWrapped (*1)�j�� WrappedBytes �ɂO���i�[����B

  WrappedBytes ���|�C���^��i�߂鏈���ł́A�����Ƀ^�u����������ƁA����
  �V�X�e���͔j�]����Ƃ����u�^�u�������v������B
  ����́ALastTokenBracket �ň����f�[�^�͐��̃^�u�������܂ޕ������
  ���邪�A�`�悷��Ƃ��Ƀp�[�X���镶����̓^�u���������p�󔒂ɓW�J����
  �Ă��邱�ƂɌ������Ă���B�Ⴆ�� TabSpaceCount ���W��

              abc <- �܂�Ԃ�
  TAB.....def

  �Ƃ����g�[�N��������ꍇ�AWrappedBytes �ɂ͂S���i�[����邪�A�`�悷��
  ���̕������
              abc <- �܂�Ԃ�
  ________def �i _ �͔��p�󔒁j

  �ƂȂ�̂ŁA�擪����S�o�C�g�܂ł��w��g�[�N���Ƃ��Ĉ����A�c��̂V
  �o�C�g���ʂ̃g�[�N���Ƃ��Ĉ����Ă��܂��B

  �����̃^�u�������܂މ\���̂���g�[�N�� toComment, toSingleQuotation,
  toDoubleQuotation (*2) �ɂ��Ă��O���i�[���AFTokenMethodTable �ɏ�����
  �ς˂�d�l�Ƃ���B

  �����̃^�u�������܂މ\���̂���g�[�N���̏W����Ԃ����\�b�h�Ƃ���
  IncludeTabToken ���p�ӂ���Ă���BLastTokenBracket ���\�b�h�ł͂���
  ���\�b�h�ɖ₢���킹�āA�܂�Ԃ��ꂽ�g�[�N�����Y������ꍇ��
  WrappedByte �ɂO���i�[���鏈�����s���Ă���B

  �܂��A�܂�Ԃ��ꂽ�\���ɂ��Ă��l������K�v������̂ŁA���݂�
  �g�[�N������ toBracket �ȃg�[�N���Ő܂�Ԃ���Ă���ꍇ�ɁA
  ���ꂪ�\��ꂩ�ǂ����� WrappedTokenIsReserveWord ���\�b�h�ɖ₢����
  ���Č��݂̃g�[�N�����X�V���Ă���B

  toBracket ���^�u�������܂ޏꍇ������B
  toBracket �́ABrackets �v���p�e�B�l�ɂ���� BracketProc �֕��򂳂��
  �̂łO���i�[����Ηǂ����ƂɂȂ邪�A�Y�� RightBracket �����񂪐܂��
  ����Ă���ꍇ (*3) BracketProc �� RightBracket �𔭌����邱�Ƃ�
  �o���Ȃ��̂ŁA���̏ꍇ���� WrappedBytes �̎d�g�݂𗘗p����B

  ---------------------------------------------------------------------
  �������ꂽ�g�[�N���ł��邱�Ƃ̔��� (S < L1) and (L1 < P)

   Index �s          L1 Index + 1 �s       L2
  +------------------+---------------------+
  |   ***************|**************       |
  +------------------+---------------------+
      S                            P

  ---------------------------------------------------------------------
  �u���[�N�������_�ł́A���ۂ̏���

  Data.BracketIndex
  �u���[�N�������_�ł̃g�[�N�����A
  �E�J���� toBracket �̏ꍇ�́A���̎��_�ł� FBracketIndex ���i�[�����B
  �E���� toBracket �̏ꍇ�́A�������ꂽ�g�[�N���̏ꍇ�͂��̎��_�ł�
    FDrawBracketIndex ���i�[�����
  �E����ȊO�ł� NormalBracketIndex ���i�[�����B

  Data.ElementIndex
  �u���[�N�������_�ł̃g�[�N������������Ă���ꍇ�́A���O�̃g�[�N����
  �擾�����ۂ� FElementIndex ���i�[�����B��������Ă��Ȃ��ꍇ�́A����
  �� FElementIndex ���i�[�����B

  Data.WrappedByte
  �u���[�N�������_�ł̃g�[�N������������Ă���ꍇ�ɁA��} P �̈ʒu��
  L1 �̍������i�[�����B
  P = L2 �� Index + 1 �� raWrapped �̏ꍇ�͂O���i�[�����B
  toBracket �̏ꍇ�́A�Y�� RightBracket ���܂�Ԃ��ꂽ�Ƃ��������������B
  �� toBracket �̏ꍇ�́A���ꂪ�^�u�������܂ރg�[�N���i [toComment,
  toSingleQuotation, toDoubleQuotation] �ȂǁAIncludeTabToken ���\�b�h
  �̕Ԓl�j�ȊO�̏ꍇ�������������B

  Data.StartToken
  �v���[�N�������_�ł̃g�[�N������������Ă���ꍇ�ɁA���̃g�[�N����
  �i�[�����B
  toBracket �́A�Y�� RightBracket ���܂�Ԃ��ꂽ�Ƃ��������������
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
    (*
      Index �s���S�󔒂̏ꍇ�A�g�[�N�����܂�Ԃ��ɂ���ĕ��f����Ă��邱�Ƃ͖����̂ŁA
      Data.StartToken, Data.WrappedByte �͏��߂���O������AExit ����O�ɏ���������
      �K�v�͂Ȃ��B
    *)
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
      if SourcePos + TokenLength > L1 then
        Break;
      Data.ElementIndex := FElementIndex;
      Data.PrevToken := FPrevToken;
    end;
    // �u���[�N�������_�ł̏���
    Data.WrappedByte := 0;
    Data.StartToken := toEof;
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
  LastTokenBracket ���\�b�h�̃w���p�[���\�b�h�B���݂̃g�[�N�����A
  �� toBracket �ȃg�[�N���ŁA��������Ă���ꍇ���s�����B
  ���݂̃g�[�N�����\��ꃊ�X�g�Ɋ܂܂�Ă���ꍇ�́AAToken ���X�V����B
  ��Q��R�̗\��ꃊ�X�g�𗘗p����ꍇ�́A����Ɋ܂܂�Ă���g�[�N����
  ���邱�Ƃ�\������l�� AToken ���X�V����B
*)
begin
  if IsReserveWord then
    AToken := toReserve;
end;

function TFountainParser.IncludeTabToken: TCharSet;
(*
  LastTokenBracket ���\�b�h�̃w���p�[���\�b�h�B���݂̃g�[�N�����A
  �� toBracket �ȃg�[�N���ŁA��������Ă���ꍇ���s�����B
  �^�u�������܂މ\���̂���g�[�N���𕶎��W���^�ŕԂ��B
  �^�u�������܂މ\���̂���V�����g�[�N�����`�����ꍇ��
  �����̕Ԓl�ɒǉ�����B
*)
begin
  Result := [toComment, toSingleQuotation, toDoubleQuotation];
end;

function TFountainParser.EolToken: TCharSet;
(*
  LastTokenBracket ���\�b�h�̃w���p�[���\�b�h�B
  toComment �̂悤�ɁA�s���܂ł���̃g�[�N���Ƃ��Ĉ����ׂ��g�[�N��
  �̏W����Ԃ��B
  toComment �̑��ɂ��A�Ⴆ�� '>' �ȍ~�̍s���܂ł��ЂƂ̃g�[�N���Ƃ���
  ���������ꍇ�Ȃǂɗ��p����B
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
      // ���� toBracket ���������ɂ͂���ė��Ȃ��d�l
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
    // MailChars ���A�����A@ �̌�� . ������ꍇ�^��Ԃ�
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
  #$81#$43 '�C', #$81#$44 '�D', #$81#$5B '�[', #$81#$7C '�|' �̈���

  �܂�Ԃ��\�����ꂽ�s������� toDBInt, toDBHira, toDBKana �g�[�N��
  �Ƃ��ăp�[�X���J�n����ہA������̐擪����L�����̂����ꂩ�̏ꍇ
  ��������Ă��܂��d�l�Ȃ̂ŁA�����̃g�[�N������ʈ�������ꍇ��
  �܂�Ԃ��ꂽ�s������̐擪�ɂ����̕��������Ȃ��悤�� Leading
  �v���p�e�B�� True �ɐݒ肷�邱�ƁB
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
                    ((FP^ in [#$81]) and ((FP + 1)^ in [#$43..#$44])) do // '�C', ' �D'
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
                    ((FP^ in [#$81]) and ((FP + 1)^ in [#$5B, #$7C])) do // '�[', '�|'
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
                    ((FP^ in [#$81]) and ((FP + 1)^ in [#$5B, #$7C])) do // '�[', '�|'
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
