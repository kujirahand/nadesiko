(*********************************************************************

  HimawariFountain.pas

  なでしこの文法に沿ってカラーリングする

**********************************************************************)

unit HimawariFountain;

{$I heverdef.inc}

interface

uses
  SysUtils, Classes, heClasses, heFountain, heRaStrings, Graphics;

const
  toControlCode        = Char(50);
  toControlCodeHex     = Char(51);

  toDefLine            = Char(81);
  toMember             = Char(82);

type
  THimawariFountainParser = class(TFountainParser)
  protected
    procedure AnkProc; override;
    procedure InitMethodTable; override;
    procedure IntegerProc; override;
    procedure SymbolProc; override;
    function IsReserveWord: Boolean; override;
    procedure DBProc; override;
    procedure DBSymbolProc; override;
    procedure CharCodeProc; virtual;
    procedure ControlCodeHexProc; virtual;
    procedure ControlCodeProc; virtual;
    procedure HexPrefixProc; virtual;
    procedure PropertyCancelProc; virtual;
    procedure SlashProc; virtual;
  public
    function TokenToFountainColor: TFountainColor; override;
  end;

  THimawariFountain = class(TFountain)
  private
    FAnk: TFountainColor;                  // 半角文字
    FAsmBlock: TFountainColor;             // アセンブラブロック
    FComment: TFountainColor;              // コメント部分
    FDBCS: TFountainColor;                 // 全角文字と半角ｶﾀｶﾅ
    FInt: TFountainColor;                  // 数値
    FStr: TFountainColor;                  // 文字列
    FSymbol: TFountainColor;               // 記号
//    FJosi: TFountainColor;                 // 助詞
    FDefLine: TFountainColor;              // 宣言行
    FMember: TFountainColor;               // メンバ
    procedure SetAnk(Value: TFountainColor);
    procedure SetAsmBlock(Value: TFountainColor);
    procedure SetComment(Value: TFountainColor);
    procedure SetDBCS(Value: TFountainColor);
    procedure SetInt(Value: TFountainColor);
    procedure SetStr(Value: TFountainColor);
    procedure SetSymbol(Value: TFountainColor);
//    procedure SetJosi(const Value: TFountainColor);
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
    property DefLine: TFountainColor read FDefLine write SetDefLine;
    property Member: TFountainColor read FMember write SetMember;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TEditor', [THimawariFountain]);
end;


{ THimawariFountainParser }

procedure THimawariFountainParser.InitMethodTable;
begin
  inherited InitMethodTable;
  // FMethodTable
  //FMethodTable['#'] := CommenterProc;
  FMethodTable['$'] := HexPrefixProc;
  //FMethodTable[';'] := PropertyCancelProc;
  FMethodTable[#39] := CommenterProc;//SingleQuotationProc;
  FMethodTable['/'] := SlashProc;
  // FTokenMethodTable
  FTokenMethodTable[toControlCode] := ControlCodeProc;
  FTokenMethodTable[toControlCodeHex] := ControlCodeHexProc;
end;

procedure THimawariFountainParser.CharCodeProc;
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

procedure THimawariFountainParser.ControlCodeHexProc;
// '#$'
begin
  FToken := toControlCodeHex;
  while FP^ in ['0'..'9', 'A'..'F', 'a'..'f'] do
    Inc(FP);
end;

procedure THimawariFountainParser.ControlCodeProc;
// '#'
begin
  FToken := toControlCode;
  while FP^ in ['0'..'9'] do
    Inc(FP);
end;

procedure THimawariFountainParser.HexPrefixProc;
// '$'
begin
  Inc(FP);
  HexProc;
end;

procedure THimawariFountainParser.SlashProc;
// '/'
begin
  if (FP + 1)^ = '/' then
    CommenterProc
  else
    SymbolProc;
end;

procedure THimawariFountainParser.PropertyCancelProc;
// ';'
begin
  SymbolProc;
end;

procedure THimawariFountainParser.AnkProc;
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

procedure THimawariFountainParser.IntegerProc;
begin
  inherited IntegerProc;
end;

procedure THimawariFountainParser.SymbolProc;
begin
  inherited SymbolProc;
end;

function THimawariFountainParser.IsReserveWord: Boolean;
begin
  Result :=  inherited IsReserveWord;
end;

function THimawariFountainParser.TokenToFountainColor: TFountainColor;
begin
  with THimawariFountain(FFountain) do
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
        toDefLine:
          Result := FDefLine;
        toMember:
          Result := FMember;
      else
        Result := nil;
      end;
end;



procedure THimawariFountainParser.DBSymbolProc;

  function IsKey(p: PChar) : Boolean;
  begin
    Result := (StrLComp(FP, p, StrLen(p)) = 0);
  end;

begin
  FToken := toDBSymbol;

  if ( (FP - 1)^ in [#13,#10,#0] )and( IsKey('＊') ) then
  begin
    FToken := toDefLine;
    while not (FP^ in [#0, #10, #13]) do Inc(FP);
  end else

  if IsKey('※')or IsKey('’') then
  begin
    Inc(FP, 2);
    CommenterProc;
  end else

  begin
    inherited DBSymbolProc;
  end;
end;

procedure THimawariFountainParser.DBProc;
var
  FlagIncPtr: Boolean;

  function IsKeyword( p: PChar ): Boolean;
  var len: Integer;
  begin
    len := StrLen(p);
    Result := (StrLComp(p, FP, len) = 0);
    if FlagIncPtr and Result then Inc(FP, len);
  end;

begin
  inherited;
{
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
          #$9F..#$F1: // ひらがなの処理
            begin
              Dec(FP);
              // 例外語句
              if StrLComp(FP,'はい',4) = 0 then
              begin
                Inc(FP,4); FToken := toDBHira; Exit;
              end;
              while ((FP^ in [#$82]) and ((FP + 1)^ in [#$9F..#$F1])) or
                    ((FP^ in [#$81]) and ((FP + 1)^ in [#$5B, #$7C])) do // 'ー', '－'
              begin
                //if IsJosi(False) then Break;
                Inc(FP, 2);
              end;
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
}
end;

{ THimawariFountain }

destructor THimawariFountain.Destroy;
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

procedure THimawariFountain.CreateFountainColors;
begin
  inherited CreateFountainColors;

  // 色分けの生成
  FAnk := CreateFountainColor;
  FAsmBlock := CreateFountainColor;
  FComment := CreateFountainColor;
  FDBCS := CreateFountainColor;
  FInt := CreateFountainColor;
  FStr := CreateFountainColor;
  FSymbol := CreateFountainColor;
  FDefLine := CreateFountainColor;
  FMember := CreateFountainColor;

  // デフォルト配色の決定
  FInt.Color      := clGreen;
  FComment.Color  := clMaroon;
  FStr.Color      := clNavy;
  FSymbol.Color   := clBlue;

  FDefLine.Color  := clRed;
  FDefLine.Style  := [fsBold];

  FMember.Color   := clBlue;

  Reserve.Style   := [fsBold];

end;

procedure THimawariFountain.SetAnk(Value: TFountainColor);
begin
  FAnk.Assign(Value);
end;

procedure THimawariFountain.SetAsmBlock(Value: TFountainColor);
begin
  FAsmBlock.Assign(Value);
end;

procedure THimawariFountain.SetComment(Value: TFountainColor);
begin
  FComment.Assign(Value);
end;

procedure THimawariFountain.SetDBCS(Value: TFountainColor);
begin
  FDBCS.Assign(Value);
end;

procedure THimawariFountain.SetInt(Value: TFountainColor);
begin
  FInt.Assign(Value);
end;

procedure THimawariFountain.SetStr(Value: TFountainColor);
begin
  FStr.Assign(Value);
end;

procedure THimawariFountain.SetSymbol(Value: TFountainColor);
begin
  FSymbol.Assign(Value);
end;

function THimawariFountain.GetParserClass: TFountainParserClass;
begin
  Result := THimawariFountainParser;
end;

procedure THimawariFountain.InitBracketItems;
var
  Item: TFountainBracketItem;
begin
  Item := Brackets.Add;
  Item.LeftBracket := '{';
  Item.RightBracket := '}';
  Item.ItemColor.Color := clMaroon;
  Item := Brackets.Add;
  Item.LeftBracket := '｛';
  Item.RightBracket := '｝';
  Item.ItemColor.Color := clMaroon;

  // STRING
  Item := Brackets.Add;
  Item.LeftBracket := '「';
  Item.RightBracket := '」';
  Item.ItemColor.Color := clNavy;

  Item := Brackets.Add;
  Item.LeftBracket := '『';
  Item.RightBracket := '』';
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
  Item.ItemColor.Color := clMaroon;

end;

procedure THimawariFountain.InitFileExtList;
begin
  with FileExtList do
  begin
    Add('.hmw');
    Add('.txt');
  end;
end;

procedure THimawariFountain.InitReserveWordList;
begin
  with ReserveWordList do
  begin
    Add('表示');
    Add('言');
    Add('代入');

    Add('はい');
    Add('いいえ');
    Add('キャンセル');
    Add('オン');
    Add('オフ');

    Add('それ');
    Add('ひまわりする');

    Add('もし');
    Add('なら');
    Add('ならば');
    Add('違');
    Add('反復');
    Add('回');
    Add('繰');
    Add('抜');
    Add('続');
    Add('戻');
    Add('おわり');
    Add('おわる');
    Add('終');
  end;
end;

procedure THimawariFountain.SetDefLine(const Value: TFountainColor);
begin
  FDefLine.Assign(Value);
end;

procedure THimawariFountain.SetMember(const Value: TFountainColor);
begin
  FMember.Assign( Value );
end;

end.

