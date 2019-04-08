(*********************************************************************

  CppFountain.pas

  start  2001/04/27
  update 2004/01/04

  Copyright (c) 2001-2004 Km <CQE03114@nifty.ne.jp>
  http://homepage2.nifty.com/Km/

  --------------------------------------------------------------------
  C++ を表示するための TCppFountain コンポーネントと
  TCppFountainParser クラス

**********************************************************************)

unit CppFountain;

interface

uses
  SysUtils, Classes, heClasses, heFountain, heRaStrings;

const
  toCppHex             = Char(50);
  toPreProcessor       = Char(51);
  PropertyBlockElement = 1;

type
  TCppFountainParser = class(TFountainParser)
  protected
    procedure AnkProc; override;
    procedure InitMethodTable; override;
    procedure ZeroProc; virtual;
    procedure CppHexProc; virtual;
    procedure PropertyCancelProc; virtual;
    procedure SlashProc; virtual;
    procedure PreProcessorProc; virtual;
  public
    function TokenToFountainColor: TFountainColor; override;
  end;

  TCppFountain = class(TFountain)
    FAnk:     TFountainColor;           // 半角文字
    FComment: TFountainColor;           // コメント部分
    FDBCS:    TFountainColor;           // 全角文字と半角カタカナ
    FInt:     TFountainColor;           // 数値
    FStr:     TFountainColor;           // 文字列
    FSymbol:  TFountainColor;           // 記号
    FPreProcessor: TFountainColor;      // プリプロセッサー
    procedure SetAnk(Value: TFountainColor);
    procedure SetComment(Value: TFountainColor);
    procedure SetDBCS(Value: TFountainColor);
    procedure SetInt(Value: TFountainColor);
    procedure SetStr(Value: TFountainColor);
    procedure SetSymbol(Value: TFountainColor);
    procedure SetPreProcessor(Value: TFountainColor);
  protected
    function  GetParserClass: TFountainParserClass; override;
    procedure InitBracketItems; override;
    procedure InitReserveWordList; override;
    procedure InitFileExtList; override;
    procedure CreateFountainColors; override;
  public
    destructor Destroy; override;

  published
    property Ank:           TFountainColor read FAnk write SetAnk;
    property Comment:       TFountainColor read FComment write SetComment;
    property DBCS:          TFountainColor read FDBCS write SetDBCS;
    property Int:           TFountainColor read FInt write SetInt;
    property Str:           TFountainColor read FStr write SetStr;
    property Symbol:        TFountainColor read FSymbol write SetSymbol;
    property PreProcessor:  TFountainColor read FPreProcessor write SetPreProcessor;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TEditor', [TCppFountain]);
end;


{ TCppFountainParser }

procedure TCppFountainParser.InitMethodTable;
begin
  inherited InitMethodTable;
  // FMethodTable
  FMethodTable['0'] := ZeroProc;
  FMethodTable[';'] := PropertyCancelProc;
  FMethodTable[#39] := SingleQuotationProc;
  FMethodTable['"'] := DoubleQuotationProc;
  FMethodTable['/'] := SlashProc;
  FMethodTable['#'] := PreProcessorProc;
  // FTokenMethodTable
  FTokenMethodTable[toCppHex] := CppHexProc;
  FTokenMethodTable[toPreProcessor] := PreProcessorProc;
end;

procedure TCppFountainParser.ZeroProc;
// '0'
begin
  Inc(FP);
  if (FP^ = 'x') or (FP^ = 'X') then
  begin
    Inc(FP);
    CppHexProc;
  end
  else
    IntegerProc;
end;

procedure TCppFountainParser.CppHexProc;
// '0xhhh'
begin
  FToken := toCppHex;
  while FP^ in ['0'..'9', 'A'..'F', 'a'..'f'] do
    Inc(FP);
end;

procedure TCppFountainParser.SlashProc;
// '/'
begin
  if (FP + 1)^ = '/' then
    CommenterProc
  else
    SymbolProc;
end;

procedure TCppFountainParser.PreProcessorProc;
// '#'
begin
  FToken := toPreProcessor;
  while not (FP^ in [#0, #10, #13]) do
  begin
    if (FP^ = '/') and ((FP + 1)^ = '/') then Break;  
    Inc(FP);
  end;
end;

procedure TCppFountainParser.PropertyCancelProc;
// ';'
begin
  if FElementIndex = PropertyBlockElement then
    FElementIndex := NormalElementIndex;
  SymbolProc;
end;

procedure TCppFountainParser.AnkProc;
// 'A'..'Z', '_', 'a'..'z':
begin
  FToken := toAnk;
  case FElementIndex of
    NormalElementIndex:
      case FP^ of
        'P', 'p':
          if IsKeyWord('property') then
            FElementIndex := PropertyBlockElement
          else
            inherited AnkProc;
      else
        inherited AnkProc;
      end;
    PropertyBlockElement:
      case FP^ of
        'P', 'p':
          if IsKeyWord('private') or
             IsKeyWord('protected') or
             IsKeyWord('public') or
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
  else
    inherited AnkProc;
  end;
end;

function TCppFountainParser.TokenToFountainColor: TFountainColor;
begin
  with TCppFountain(FFountain) do
    if IsReserveWord then
      Result := Reserve
    else
      case FToken of
        toSymbol:
          Result := FSymbol;
        toInteger, toFloat, toCppHex:
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
        toHex:
          Result := FInt;
        toSingleQuotation, toDoubleQuotation:
          Result := FStr;
        toPreProcessor:
          Result := FPreProcessor;
      else
        Result := nil;
      end;
end;


{ TCppFountain }

destructor TCppFountain.Destroy;
begin
  FAnk.Free;
  FComment.Free;
  FDBCS.Free;
  FInt.Free;
  FStr.Free;
  FSymbol.Free;
  FPreProcessor.Free;
  inherited Destroy;
end;

procedure TCppFountain.CreateFountainColors;
begin
  inherited CreateFountainColors;
  FAnk          := CreateFountainColor;
  FComment      := CreateFountainColor;
  FDBCS         := CreateFountainColor;
  FInt          := CreateFountainColor;
  FStr          := CreateFountainColor;
  FSymbol       := CreateFountainColor;
  FPreProcessor := CreateFountainColor;
end;

procedure TCppFountain.SetAnk(Value: TFountainColor);
begin
  FAnk.Assign(Value);
end;

procedure TCppFountain.SetComment(Value: TFountainColor);
begin
  FComment.Assign(Value);
end;

procedure TCppFountain.SetDBCS(Value: TFountainColor);
begin
  FDBCS.Assign(Value);
end;

procedure TCppFountain.SetInt(Value: TFountainColor);
begin
  FInt.Assign(Value);
end;

procedure TCppFountain.SetStr(Value: TFountainColor);
begin
  FStr.Assign(Value);
end;

procedure TCppFountain.SetSymbol(Value: TFountainColor);
begin
  FSymbol.Assign(Value);
end;

procedure TCppFountain.SetPreProcessor(Value: TFountainColor);
begin
  FPreProcessor.Assign(Value);
end;

function TCppFountain.GetParserClass: TFountainParserClass;
begin
  Result := TCppFountainParser;
end;

procedure TCppFountain.InitBracketItems;
var
  Item: TFountainBracketItem;
begin
  Item := Brackets.Add;
  Item.LeftBracket := '/*';
  Item.RightBracket := '*/';
end;

procedure TCppFountain.InitReserveWordList;
begin
  with ReserveWordList do
  begin
    Add('asm');
    Add('auto');
    Add('break');
    Add('case');
    Add('catch');
    Add('char');
    Add('class');
    Add('const');
    Add('continue');
    Add('default');
    Add('delete');
    Add('do');
    Add('double');
    Add('else');
    Add('enum');
    Add('extern');
    Add('float');
    Add('for');
    Add('friend');
    Add('goto');
    Add('if');
    Add('inline');
    Add('int');
    Add('long');
    Add('new');
    Add('operator');
    Add('private');
    Add('protected');
    Add('public');
    Add('register');
    Add('return');
    Add('short');
    Add('signed');
    Add('sizeof');
    Add('static');
    Add('struct');
    Add('switch');
    Add('template');
    Add('this');
    Add('throw');
    Add('try');
    Add('typedef');
    Add('union');
    Add('unsigned');
    Add('virtual');
    Add('void');
    Add('volatile');
    Add('while');
  end;
end;

procedure TCppFountain.InitFileExtList;
begin
  with FileExtList do
  begin
    Add('.cpp');
    Add('.c');
    Add('.hpp');
    Add('.h');
  end;
end;

end.
