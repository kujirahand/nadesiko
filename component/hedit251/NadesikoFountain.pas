(*********************************************************************

  NadesikoFountain.pas

  �Ȃł����̕��@�ɉ����ăJ���[�����O����

**********************************************************************)

unit NadesikoFountain;

{$I heverdef.inc}

interface

uses
  SysUtils, Classes, heClasses, heFountain, heRaStrings, Graphics;

const
  toControlCode        = Char(50);
  toControlCodeHex     = Char(51);
  toAsm                = Char(52);

  toJosi               = Char(80);
  toDefLine            = Char(81);
  toMember             = Char(82);

  PropertyBlockElement = 1;
  AsmBlockElement      = 2;

type
  TNadesikoFountainParser = class(TFountainParser)
  protected
    procedure AnkProc; override;
    procedure InitMethodTable; override;
    procedure IntegerProc; override;
    procedure SymbolProc; override;
    function IsReserveWord: Boolean; override;
    procedure DBProc; override;
    procedure DBSymbolProc; override;
    procedure DBKanjiProc; override;
    procedure CharCodeProc; virtual;
    procedure ControlCodeHexProc; virtual;
    procedure ControlCodeProc; virtual;
    procedure HexPrefixProc; virtual;
    procedure PropertyCancelProc; virtual;
    procedure SlashProc; virtual;

  public
    function TokenToFountainColor: TFountainColor; override;
  end;

  TNadesikoFountain = class(TFountain)
  private
    FAnk: TFountainColor;                  // ���p����
    FAsmBlock: TFountainColor;             // �A�Z���u���u���b�N
    FComment: TFountainColor;              // �R�����g����
    FDBCS: TFountainColor;                 // �S�p�����Ɣ��p����
    FInt: TFountainColor;                  // ���l
    FStr: TFountainColor;                  // ������
    FSymbol: TFountainColor;               // �L��
    FJosi: TFountainColor;                 // ����
    FDefLine: TFountainColor;              // �錾�s
    FMember: TFountainColor;               // �����o
    procedure SetAnk(Value: TFountainColor);
    procedure SetAsmBlock(Value: TFountainColor);
    procedure SetComment(Value: TFountainColor);
    procedure SetDBCS(Value: TFountainColor);
    procedure SetInt(Value: TFountainColor);
    procedure SetStr(Value: TFountainColor);
    procedure SetSymbol(Value: TFountainColor);
    procedure SetJosi(const Value: TFountainColor);
    procedure SetDefLine(const Value: TFountainColor);
    procedure SetMember(const Value: TFountainColor);
  protected
    function GetParserClass: TFountainParserClass; override;
    procedure InitBracketItems; override;
    procedure InitFileExtList; override;
    procedure InitReserveWordList; override;
    procedure CreateFountainColors; override;
  public
    destructor Destroy; override;
  published
    property Ank: TFountainColor read FAnk write SetAnk;
    property AsmBlock: TFountainColor read FAsmBlock write SetAsmBlock;
    property Comment: TFountainColor read FComment write SetComment;
    property DBCS: TFountainColor read FDBCS write SetDBCS;
    property Int: TFountainColor read FInt write SetInt;
    property Str: TFountainColor read FStr write SetStr;
    property Symbol: TFountainColor read FSymbol write SetSymbol;
    property Josi: TFountainColor read FJosi write SetJosi;
    property DefLine: TFountainColor read FDefLine write SetDefLine;
    property Member: TFountainColor read FMember write SetMember;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TEditor', [TNadesikoFountain]);
end;


{ TNadesikoFountainParser }

procedure TNadesikoFountainParser.InitMethodTable;
begin
  inherited InitMethodTable;
  // FMethodTable
  FMethodTable['#'] := CommenterProc;
  FMethodTable['$'] := HexPrefixProc;
  FMethodTable[';'] := PropertyCancelProc;
  FMethodTable[#39] := CommenterProc;//SingleQuotationProc;
  FMethodTable['/'] := SlashProc;
  // FTokenMethodTable
  FTokenMethodTable[toControlCode] := ControlCodeProc;
  FTokenMethodTable[toControlCodeHex] := ControlCodeHexProc;
  FTokenMethodTable[toAsm] := AnkProc;
end;

procedure TNadesikoFountainParser.CharCodeProc;
// '#'
begin
  Inc(FP);
  if FP^ = '$' then
  begin
    Inc(FP);
    ControlCodeHexProc;
  end
  else
    ControlCodeProc;
end;

procedure TNadesikoFountainParser.ControlCodeHexProc;
// '#$'
begin
  FToken := toControlCodeHex;
  while FP^ in ['0'..'9', 'A'..'F', 'a'..'f'] do
    Inc(FP);
end;

procedure TNadesikoFountainParser.ControlCodeProc;
// '#'
begin
  FToken := toControlCode;
  while FP^ in ['0'..'9'] do
    Inc(FP);
end;

procedure TNadesikoFountainParser.HexPrefixProc;
// '$'
begin
  Inc(FP);
  HexProc;
end;

procedure TNadesikoFountainParser.SlashProc;
// '/'
begin
  if (FP + 1)^ = '/' then
    CommenterProc
  else
    SymbolProc;
end;

procedure TNadesikoFountainParser.PropertyCancelProc;
// ';'
begin
  if FElementIndex = PropertyBlockElement then
    FElementIndex := NormalElementIndex;
  SymbolProc;
end;

procedure TNadesikoFountainParser.AnkProc;
// 'A'..'Z', '_', 'a'..'z':
begin
  FToken := toAnk;
  {
  case FElementIndex of
    NormalElementIndex:
      case FP^ of
        'P', 'p':
          if IsKeyWord('property') then
            FElementIndex := PropertyBlockElement
          else
            inherited AnkProc;
        'A', 'a':
          if IsKeyWord('asm') then
            FElementIndex := AsmBlockElement
          else
            inherited AnkProc;
      else
        inherited AnkProc;
      end;
    PropertyBlockElement:
      case FP^ of
        'E', 'e':
          if IsKeyWord('end') then
            FElementIndex := NormalElementIndex
          else
            inherited AnkProc;
        'F', 'f':
          if IsKeyWord('function') then
            FElementIndex := NormalElementIndex
          else
            inherited AnkProc;
        'P', 'p':
          if IsKeyWord('private') or IsKeyWord('procedure') or
             IsKeyWord('protected') or IsKeyWord('public') or
             IsKeyWord('published') then
            FElementIndex := NormalElementIndex
          else
            inherited AnkProc;
        'I', 'i':
          if IsKeyWord('index') then
            FToken := toReserve
          else
            inherited AnkProc;
        'R', 'r':
          if IsKeyWord('read') then
            FToken := toReserve
          else
            inherited AnkProc;
        'W', 'w':
          if IsKeyWord('write') then
            FToken := toReserve
          else
            inherited AnkProc;
      else
        inherited AnkProc;
      end;
    AsmBlockElement:
      if (FP^ in ['E', 'e']) and IsKeyWord('end') then
        FElementIndex := NormalElementIndex
      else
      begin
        inherited AnkProc;
        FToken := toAsm;
      end;
  else
    inherited AnkProc;
  end;
  }
  inherited AnkProc;
end;

procedure TNadesikoFountainParser.IntegerProc;
begin
  inherited IntegerProc;
  if FElementIndex = AsmBlockElement then
    FToken := toAsm;
end;

procedure TNadesikoFountainParser.SymbolProc;
begin
  inherited SymbolProc;
  if FElementIndex = AsmBlockElement then
    FToken := toAsm;
end;

function TNadesikoFountainParser.IsReserveWord: Boolean;
begin
  Result :=  (FToken <> toAsm) and inherited IsReserveWord;
end;

function TNadesikoFountainParser.TokenToFountainColor: TFountainColor;
begin
  with TNadesikoFountain(FFountain) do
    if IsReserveWord then
      Result := Reserve
    else
      case FToken of
        toSymbol,toDBSymbol:
          Result := FSymbol;
        toInteger, toFloat, toDBInt:
          Result := FInt;
        toBracket:
          Result := Brackets[FDrawBracketIndex].ItemColor;
        toComment:
          Result := FComment;
        toReserve:
          Result := Reserve;
        toAnk:
          Result := FAnk;
        toDBAlph, toDBHira, toDBKana, toDBKanji, toKanaSymbol, toKana:
          Result := FDBCS;
        toHex:
          Result := FInt;
        toSingleQuotation, toControlCode, toControlCodeHex:
          Result := FStr;
        toAsm:
          Result := FAsmBlock;
        toJosi:
          Result := FJosi;
        toDefLine:
          Result := FDefLine;
        toMember:
          Result := FMember;
      else
        Result := nil;
      end;
end;



procedure TNadesikoFountainParser.DBSymbolProc;

  function IsKey(p: PChar) : Boolean;
  begin
    Result := (StrLComp(FP, p, StrLen(p)) = 0);
  end;

begin
  FToken := toDBSymbol;

  if ( (FP - 1)^ in [#13,#10,#0] )and( IsKey('��') or IsKey('��') or IsKey('��') ) then
  begin
    FToken := toDefLine;
    while not (FP^ in [#0, #10, #13]) do Inc(FP);
  end else

  if IsKey('�E') then
  begin
    FToken := toMember;
    while not (FP^ in [#0, #13, #10, ' ', '#']) do
    begin
      if StrLComp(FP, '�`', 2) = 0 then Break;
      if StrLComp(FP, '��', 2) = 0 then Break;
      if StrLComp(FP, '��', 2) = 0 then Break;
      if StrLComp(FP, '��', 2) = 0 then Break;
      if FP^ in LeadBytes then Inc(FP, 2) else Inc(FP);
    end;
  end else

  if IsKey('��')or IsKey('��')or IsKey('�f') then
  begin
    Inc(FP, 2);
    CommenterProc;
  end else
  // �Q�o�C�g��HEX
  if IsKey('��') then
  begin
    Inc(FP, 2);
    if FP^ in ['0'..'9'] then
    begin
      Inc(FP);
      FToken := toInteger;
    end else
    while (FP^ = #$82)and((FP+1)^ in [#$4F..#$58]) do
    begin
      Inc(FP, 2);
      FToken := toDBInt;
    end;
  end else

  begin
    inherited DBSymbolProc;
  end;
end;

procedure TNadesikoFountainParser.DBProc;
var
  FlagIncPtr: Boolean;

  function IsKeyword( p: PChar ): Boolean;
  var len: Integer;
  begin
    len := StrLen(p);
    Result := (StrLComp(p, FP, len) = 0);
    if FlagIncPtr and Result then Inc(FP, len);
  end;

  function IsJosi(FlagInc: Boolean): Boolean;
  begin
    FlagIncPtr := FlagInc;
    if
      IsKeyword('�łȂ����') or IsKeyword('�ɂ���') or IsKeyword('�Ȃ��') or
      IsKeyword('�Ƃ���') or IsKeyword('���炢') or IsKeyword('�Ȃ̂�') or IsKeyword('�܂ł�') or
      IsKeyword('�Ȃ�') or IsKeyword('���') or IsKeyword('����') or IsKeyword('�܂�') or
      IsKeyword('�ق�') or IsKeyword('����') or IsKeyword('����') or IsKeyword('�Ȃ�') or
      IsKeyword('�Ƃ�') or IsKeyword('����') or
      IsKeyword('��') or IsKeyword('��') or IsKeyword('��') or IsKeyword('��') or
      IsKeyword('��') or IsKeyword('��') or IsKeyword('��') or IsKeyword('��') or
      IsKeyword('��')
    then begin
      Result := True;
    end else begin
      Result := False;
    end;
  end;

begin
//------------------------------------------------------------------------------
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
              // �A���t�@�x�b�g�ɑ�������
              while (FP^ in [#$82]) and ((FP+1)^ in [#$4F..#$58]) do Inc(FP, 2);
              // ����
              while (FP^ in ['0'..'9']) do Inc(FP);
              FToken := toDBAlph;
            end;
          #$9F..#$F1: // �Ђ炪�Ȃ̏���
            begin
              Dec(FP);
              
              // ��O���
              FlagIncPtr := True;
              if IsKeyword('�͂�') or IsKeyword('�����܂�') then
              begin
                FToken := toReserve; Exit;
              end;

              // �������H
              if IsJosi(True) then
              begin
                FToken := toJosi;
              end else
              begin
                while ((FP^ in [#$82]) and ((FP + 1)^ in [#$9F..#$F1])) or
                      ((FP^ in [#$81]) and ((FP + 1)^ in [#$5B, #$7C])) do // '�[', '�|'
                begin
                  if IsJosi(False) then Break;
                  Inc(FP, 2);
                end;
                FToken := toDBHira;
              end;
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
          else begin
          end;
        end;
      end;
  end;

end;

procedure TNadesikoFountainParser.DBKanjiProc;
var
  FlagIncPtr: Boolean;

  function IsKeyword( p: PChar ): Boolean;
  var len: Integer;
  begin
    len := StrLen(p);
    Result := (StrLComp(p, FP, len) = 0);
    if FlagIncPtr and Result then Inc(FP, len);
  end;

  function IsSyntaxKeyword: Boolean;
  begin
    FlagIncPtr := True;
    Result :=
      IsKeyword('�Ⴆ��') or IsKeyword('�J��Ԃ�') or IsKeyword('�J��Ԃ�') or
      IsKeyword('�߂�') or IsKeyword('������') or IsKeyword('������') or
      IsKeyword('�I���') or IsKeyword('�I���');
  end;

begin
  FToken := toDBKanji;

  if IsSyntaxKeyword then
  begin
    FToken := toReserve; Exit;
  end;

  while FP^ in [#$88..#$9F, #$E0..#$FC] do
  begin
    Inc(FP);
    if FP^ in [#$40..#$FF] then
      Inc(FP);
  end;
end;

{ TNadesikoFountain }

destructor TNadesikoFountain.Destroy;
begin
  FAnk.Free;
  FAsmBlock.Free;
  FComment.Free;
  FDBCS.Free;
  FInt.Free;
  FStr.Free;
  FSymbol.Free;
  inherited Destroy;
end;

procedure TNadesikoFountain.CreateFountainColors;
begin
  inherited CreateFountainColors;

  // �F�����̐���
  FAnk        := CreateFountainColor;
  FAsmBlock   := CreateFountainColor;
  FComment    := CreateFountainColor;
  FDBCS       := CreateFountainColor;
  FInt        := CreateFountainColor;
  FStr        := CreateFountainColor;
  FSymbol     := CreateFountainColor;
  FJosi       := CreateFountainColor;
  FDefLine    := CreateFountainColor;
  FMember     := CreateFountainColor;

  // �f�t�H���g�z�F�̌���
  FInt.Color      := clNavy;
  FStr.Color      := clNavy;
  FComment.Color  := clGreen;
  FSymbol.Color   := clTeal;
  FJosi.Color     := clMaroon;

  FDefLine.Color  := clFuchsia;
  FDefLine.Style  := [fsBold];

  FMember.Color   := clBlue;
  //FMember.Style   := [fsBold];

  Reserve.Color   := clNavy;
  Reserve.Style   := [];

end;

procedure TNadesikoFountain.SetAnk(Value: TFountainColor);
begin
  FAnk.Assign(Value);
end;

procedure TNadesikoFountain.SetAsmBlock(Value: TFountainColor);
begin
  FAsmBlock.Assign(Value);
end;

procedure TNadesikoFountain.SetComment(Value: TFountainColor);
begin
  FComment.Assign(Value);
end;

procedure TNadesikoFountain.SetDBCS(Value: TFountainColor);
begin
  FDBCS.Assign(Value);
end;

procedure TNadesikoFountain.SetInt(Value: TFountainColor);
begin
  FInt.Assign(Value);
end;

procedure TNadesikoFountain.SetStr(Value: TFountainColor);
begin
  FStr.Assign(Value);
end;

procedure TNadesikoFountain.SetSymbol(Value: TFountainColor);
begin
  FSymbol.Assign(Value);
end;

function TNadesikoFountain.GetParserClass: TFountainParserClass;
begin
  Result := TNadesikoFountainParser;
end;

procedure TNadesikoFountain.InitBracketItems;
var
  Item: TFountainBracketItem;
begin
  Item := Brackets.Add;
  Item.LeftBracket := '{';
  Item.RightBracket := '}';
  Item.ItemColor.Color := clGreen;

  // STRING
  Item := Brackets.Add;
  Item.LeftBracket := '�u';
  Item.RightBracket := '�v';
  Item.ItemColor.Color := clNavy;

  Item := Brackets.Add;
  Item.LeftBracket := '�w';
  Item.RightBracket := '�x';
  Item.ItemColor.Color := clNavy;

  Item := Brackets.Add;
  Item.LeftBracket := '`';
  Item.RightBracket := '`';
  Item.ItemColor.Color := clNavy;

  Item := Brackets.Add;
  Item.LeftBracket := '"';
  Item.RightBracket := '"';
  Item.ItemColor.Color := clNavy;

  // COMMENT
  Item := Brackets.Add;
  Item.LeftBracket := '/*';
  Item.RightBracket := '*/';
  Item.ItemColor.Color := clGreen;

end;

procedure TNadesikoFountain.InitFileExtList;
begin
  with FileExtList do
  begin
    Add('.nako');
    Add('.txt');
  end;
end;

procedure TNadesikoFountain.InitReserveWordList;
begin
  with ReserveWordList do
  begin
    Add('�\��');
    Add('��');
    Add('���');

    Add('�͂�');
    Add('������');
    Add('�L�����Z��');
    Add('�I��');
    Add('�I�t');

    Add('����');
    Add('�i�f�V�R');

    Add('������');
    Add('���l');
    Add('����');
    Add('����');
    Add('�ϐ�');
    Add('�z��');
    Add('����');
    Add('�n�b�V��');
    Add('�O���[�v');

    Add('�ϐ��錾');
    Add('�K�v');
    Add('�s�v');

    Add('����');
    Add('�Ȃ�');
    Add('�Ȃ��');
    Add('��');
    Add('��');
    Add('����');
    Add('��');
    Add('�J');
    Add('�G���[');
    Add('�Ď�');
    Add('��������');
    Add('���[�v');
    Add('��');
    Add('��');
    Add('��');
    Add('�����');
    Add('�����');
    Add('�I');
  end;
end;

procedure TNadesikoFountain.SetJosi(const Value: TFountainColor);
begin
  FJosi.Assign(Value);
end;

procedure TNadesikoFountain.SetDefLine(const Value: TFountainColor);
begin
  FDefLine.Assign(Value);
end;

procedure TNadesikoFountain.SetMember(const Value: TFountainColor);
begin
  FMember.Assign( Value );
end;

end.

