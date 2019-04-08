(*********************************************************************

  HTMLFountain.pas

  start  2001/03/17
  update 2002/10/20

  Copyright (c) 2001-2002 �{�c���F <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  HTML �t�@�C����\�����邽�߂� THTMLFountain �R���|�[�l���g��
  THTMLFountainParser �N���X

**********************************************************************)

unit HTMLFountain;

{$I heverdef.inc}

interface

uses
  SysUtils, Classes, heClasses, heFountain, heRaStrings;

const
  toTagStart              = Char(50);
  toTagEnd                = Char(51);
  toTagElement            = Char(52);
  toTagAttribute          = Char(53);
  toTagAttributeDelimiter = Char(54);
  toTagAttributeValue     = Char(55);
  toAmpersand             = Char(56);
  TagBlockElement         = 1;

type
  THTMLFountainParser = class(TFountainParser)
  protected
    procedure InitMethodTable; override;
    procedure NormalTokenProc; override;
    procedure AnkProc; override;
    procedure DoubleQuotationProc; override;
    procedure SingleQuotationProc; override;
    procedure AmpersandProc; virtual;
    procedure SlashProc; virtual;
    procedure TagAttributeProc; virtual;
    procedure TagAttributeDelimiterProc; virtual;
    procedure TagAttributeValueProc; virtual;
    procedure TagElementProc; virtual;
    procedure TagEndProc; virtual;
    procedure TagStartProc; virtual;
    procedure UpdateTagToken; virtual;
  public
    function NextToken: Char; override;
    function TokenToFountainColor: TFountainColor; override;
  end;

  THTMLFountain = class(TFountain)
  private
    FAmpersand: TFountainColor;
    FMail: TFountainColor;
    FStr: TFountainColor;
    FTagAttribute: TFountainColor;
    FTagAttributeValue: TFountainColor;
    FTagColor: TFountainColor;
    FTagElement: TFountainColor;
    FUrl: TFountainColor;
    procedure SetAmpersand(Value: TFountainColor);
    procedure SetMail(Value: TFountainColor);
    procedure SetStr(Value: TFountainColor);
    procedure SetTagAttribute(Value: TFountainColor);
    procedure SetTagAttributeValue(Value: TFountainColor);
    procedure SetTagColor(Value: TFountainColor);
    procedure SetTagElement(Value: TFountainColor);
    procedure SetUrl(Value: TFountainColor);
  protected
    procedure CreateFountainColors; override;
    function GetParserClass: TFountainParserClass; override;
    procedure InitBracketItems; override;
    procedure InitFileExtList; override;
  public
    destructor Destroy; override;
  published
    property Ampersand: TFountainColor read FAmpersand write SetAmpersand;
    property Mail: TFountainColor read FMail write SetMail;
    property Str: TFountainColor read FStr write SetStr;
    property TagAttribute: TFountainColor read FTagAttribute write SetTagAttribute;
    property TagAttributeValue: TFountainColor read FTagAttributeValue write SetTagAttributeValue;
    property TagColor: TFountainColor read FTagColor write SetTagColor;
    property TagElement: TFountainColor read FTagElement write SetTagElement;
    property Url: TFountainColor read FUrl write SetUrl;
  end;

procedure Register;

implementation

uses
  heUtils;
  
procedure Register;
begin
  RegisterComponents('TEditor', [THTMLFountain]);
end;

(*

�^�O���̗v�f(element)�A����(attribute)�A�����l(attribute_value)��
�F������p�[�T�[����������B

�^�O�̕��@��

%%
tag      : <statement>
;
statement: element attribute
;
element  : TOKEN
         | /TOKEN
;
attribute: TOKEN = value
         |  /* �� */
;
value    : TOKEN
         | "TOKEN"
;
%%

�ƒ�`����B

�R���p�C�����邽�߂̍\����͂��s����ł͂Ȃ��A�^�O���̃g�[�N���̎��
���擾���邱�Ƃ��ړI�Ȃ̂ŁA�X�^�b�N��g�[�N�����ǂ݂���d�g�݂͗p
�ӂ��Ă��Ȃ��B

�^�O���ł��邱�Ƃ̔��ʂ́A�g�[�N�� '<', '>' ���擾�������_��
FElementIndex ���X�V���A������Q�Ƃ��邱�ƂŎ�������B
�^�O�̒��Ŏ擾�����g�[�N���̎�ނ̔��ʂ́A���O�̃g�[�N����ێ��������
�Q�Ƃ��邱�ƂŎ�������B�i�P�i�̃X�^�b�N�Ƃ�������j

���������d�g�݂ɂ���Ď擾�����g�[�N���ɑΉ�����F���t�B�[���h��
�p�ӂ��邱�ƂŁA�v�f�A�����A�����l�����o�I�ɕ\������B

�E'<', '>' ��F������p�[�T�[���쐬���AFElementIndex ���X�V����B
�Eoverride ���ꂽ NextToken ���\�b�h�ł́AUpdateTagToken ���\�b�h���Ă�
  �o���āA�^�O���̃g�[�N���ɕϊ����A�擾�����g�[�N���� FPrevToken �ɕێ�
  ���āA����̃p�[�X�����Œ��O�̃g�[�N���Ƃ��ė��p����B
�EUpdateTagToken ���\�b�h�ł́A�^�O�̒��ł���΁A���O�̃g�[�N�����Q�Ƃ���
  �^�O���̃g�[�N���ɕϊ����鏈�����s���B���̍ہAtoEof �𑼂̃g�[�N��
  �ɕϊ����Ă��܂��ƁAwhile NextToken <> toEof do �̃��[�v���������[�v��
  �Ȃ�̂Œ��ӁB

*)


{ THTMLFountainParser }

procedure THTMLFountainParser.InitMethodTable;
begin
  inherited InitMethodTable;
  // FMethodTable
  FMethodTable['"'] := DoubleQuotationProc;
  FMethodTable['&'] := AmpersandProc;
  FMethodTable[#39] := SingleQuotationProc;
  FMethodTable['/'] := SlashProc;
  FMethodTable['<'] := TagStartProc;
  FMethodTable['='] := TagAttributeDelimiterProc;
  FMethodTable['>'] := TagEndProc;
  // FTokenMethodTable
  FTokenMethodTable[toTagElement] := TagElementProc;
  FTokenMethodTable[toTagAttribute] := TagAttributeProc;
  FTokenMethodTable[toTagAttributeValue] := TagAttributeValueProc;
  FTokenMethodTable[toAmpersand] := AmpersandProc;
end;

procedure THTMLFountainParser.AmpersandProc;
begin
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
end;

procedure THTMLFountainParser.SlashProc;
begin
  if (FElementIndex = TagBlockElement) and
     (FPrevToken = toTagStart) then
  begin
    FToken := toTagElement;
    Inc(FP);
    while FP^ in [ '0'..'9', 'A'..'Z', 'a'..'z'] do // AnkProc - ['_']
      Inc(FP);
  end
  else
    SymbolProc;
end;

procedure THTMLFountainParser.TagElementProc;
// FStartToken = toTagElement, FWrappedByte = 0 �̎��Ɏ��s�����
begin
  AnkProc;
  FToken := toTagElement;
end;

procedure THTMLFountainParser.TagAttributeProc;
// FStartToken = toTagAttribute, FWrappedByte = 0 �̎��Ɏ��s�����
begin
  AnkProc;
  FToken := toTagAttribute;
end;

procedure THTMLFountainParser.TagAttributeDelimiterProc;
begin
  if (FElementIndex = TagBlockElement) and
     (FPrevToken = toTagAttribute) then
  begin
    FToken := toTagAttributeDelimiter;
    Inc(FP);
  end
  else
    SymbolProc;
end;

procedure THTMLFountainParser.TagAttributeValueProc;
// FStartToken = toTagAttributeValue, FWrappedByte = 0 �̎��ɂ����s�����
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

procedure THTMLFountainParser.TagEndProc;
begin
  FToken := toTagEnd;
  Inc(FP);
  FElementIndex := NormalElementIndex;
end;

procedure THTMLFountainParser.TagStartProc;
begin
  FToken := toTagStart;
  Inc(FP);
  FElementIndex := TagBlockElement;
end;

procedure THTMLFountainParser.AnkProc;
// 'A'..'Z', '_', 'a'..'z':
begin
  FToken := toAnk;
  while FP^ in ['0'..'9', 'A'..'Z', '_', 'a'..'z'] do
    Inc(FP);
end;

procedure THTMLFountainParser.DoubleQuotationProc;
// " �^�O�̒��ł��� toDoubleQuotation ���擾����B
var
  C: Char;
begin
  if FElementIndex <> TagBlockElement then
    SymbolProc
  else
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
        Break;
      end;
      if FP^ in LeadBytes then
        Inc(FP);
      Inc(FP);
    end;
  end;
end;

procedure THTMLFountainParser.SingleQuotationProc;
// ' �^�O�̒��ł��� toSingleQuotation ���擾����B
var
  C: Char;
begin
  if FElementIndex <> TagBlockElement then
    SymbolProc
  else
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
  end;
end;

procedure THTMLFountainParser.NormalTokenProc;
begin
  if (FBracketIndex = NormalBracketIndex) and IsBracketProc then
    BracketProc
  else
    if IsUrlProc then
      UrlProc
    else
      if IsMailProc then
        MailProc
      else
        if (FElementIndex = TagBlockElement) and
           (FPrevToken = toTagAttributeDelimiter) then
          TagAttributeValueProc
        else
          FMethodTable[FP^];
end;

function THTMLFountainParser.NextToken: Char;
begin
  inherited NextToken;
  UpdateTagToken;
  if FToken <> toEof then
    FPrevToken := FToken;
  Result := FToken;
end;

procedure THTMLFountainParser.UpdateTagToken;
begin
  if (FToken <> toEof) and (FElementIndex = TagBlockElement) then
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
end;

function THTMLFountainParser.TokenToFountainColor: TFountainColor;
begin
  with THTMLFountain(FFountain) do
    if IsReserveWord then
      Result := Reserve
    else
      case FToken of
        toBracket:
          Result := Brackets[FDrawBracketIndex].ItemColor;
        toReserve:
          Result := Reserve;
        toDoubleQuotation, toSingleQuotation:
          Result := FStr;
        toUrl:
          Result := FUrl;
        toMail:
          Result := FMail;
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
      else
          Result := nil;
      end;
end;


{ THTMLFountain }

destructor THTMLFountain.Destroy;
begin
  FAmpersand.Free;
  FMail.Free;
  FStr.Free;
  FTagAttribute.Free;
  FTagAttributeValue.Free;
  FTagColor.Free;
  FTagElement.Free;
  FUrl.Free;
  inherited Destroy;
end;

procedure THTMLFountain.CreateFountainColors;
begin
  inherited CreateFountainColors;
  FAmpersand := CreateFountainColor;
  FMail := CreateFountainColor;
  FStr := CreateFountainColor;
  FTagAttribute := CreateFountainColor;
  FTagAttributeValue := CreateFountainColor;
  FTagColor := CreateFountainColor;
  FTagElement := CreateFountainColor;
  FUrl := CreateFountainColor;
end;

procedure THTMLFountain.SetAmpersand(Value: TFountainColor);
begin
  FAmpersand.Assign(Value);
end;

procedure THTMLFountain.SetMail(Value: TFountainColor);
begin
  FMail.Assign(Value);
end;

procedure THTMLFountain.SetStr(Value: TFountainColor);
begin
  FStr.Assign(Value);
end;

procedure THTMLFountain.SetTagAttribute(Value: TFountainColor);
begin
  FTagAttribute.Assign(Value);
end;

procedure THTMLFountain.SetTagAttributeValue(Value: TFountainColor);
begin
  FTagAttributeValue.Assign(Value);
end;

procedure THTMLFountain.SetTagColor(Value: TFountainColor);
begin
  FTagColor.Assign(Value);
end;

procedure THTMLFountain.SetTagElement(Value: TFountainColor);
begin
  FTagElement.Assign(Value);
end;

procedure THTMLFountain.SetUrl(Value: TFountainColor);
begin
  FUrl.Assign(Value);
end;

function THTMLFountain.GetParserClass: TFountainParserClass;
begin
  Result := THTMLFountainParser;
end;

procedure THTMLFountain.InitBracketItems;
var
  Item: TFountainBracketItem;
begin
  Item := Brackets.Add;
  Item.LeftBracket := '<!--';
  Item.RightBracket := '-->';
end;

procedure THTMLFountain.InitFileExtList;
begin
  with FileExtList do
  begin
    Add('.htm');
    Add('.html');
  end;
end;


end.

