(*********************************************************************

  DelphiFountain.pas

  start  2001/03/13
  update 2001/07/26

  Copyright (c) 2001 本田勝彦 <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  Object Pascal を表示するための TDelphiFountain コンポーネントと
  TDelphiFountainParser クラス

**********************************************************************)

unit DelphiFountain;

{$I heverdef.inc}

interface

uses
  SysUtils, Classes, heClasses, heFountain, heRaStrings;

const
  toControlCode        = Char(50);
  toControlCodeHex     = Char(51);
  toAsm                = Char(52);
  PropertyBlockElement = 1;
  AsmBlockElement      = 2;

type
  TDelphiFountainParser = class(TFountainParser)
  protected
    procedure AnkProc; override;
    procedure InitMethodTable; override;
    procedure IntegerProc; override;
    procedure SymbolProc; override;
    function IsReserveWord: Boolean; override;
    procedure CharCodeProc; virtual;
    procedure ControlCodeHexProc; virtual;
    procedure ControlCodeProc; virtual;
    procedure HexPrefixProc; virtual;
    procedure PropertyCancelProc; virtual;
    procedure SlashProc; virtual;
  public
    function TokenToFountainColor: TFountainColor; override;
  end;

  TDelphiFountain = class(TFountain)
  private
    FAnk: TFountainColor;                  // 半角文字
    FAsmBlock: TFountainColor;             // アセンブラブロック
    FComment: TFountainColor;              // コメント部分
    FDBCS: TFountainColor;                 // 全角文字と半角ｶﾀｶﾅ
    FInt: TFountainColor;                  // 数値
    FStr: TFountainColor;                  // 文字列
    FSymbol: TFountainColor;               // 記号
    procedure SetAnk(Value: TFountainColor);
    procedure SetAsmBlock(Value: TFountainColor);
    procedure SetComment(Value: TFountainColor);
    procedure SetDBCS(Value: TFountainColor);
    procedure SetInt(Value: TFountainColor);
    procedure SetStr(Value: TFountainColor);
    procedure SetSymbol(Value: TFountainColor);
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
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TEditor', [TDelphiFountain]);
end;


{ TDelphiFountainParser }

procedure TDelphiFountainParser.InitMethodTable;
begin
  inherited InitMethodTable;
  // FMethodTable
  FMethodTable['#'] := CharCodeProc;
  FMethodTable['$'] := HexPrefixProc;
  FMethodTable[';'] := PropertyCancelProc;
  FMethodTable[#39] := SingleQuotationProc;
  FMethodTable['/'] := SlashProc;
  // FTokenMethodTable
  FTokenMethodTable[toControlCode] := ControlCodeProc;
  FTokenMethodTable[toControlCodeHex] := ControlCodeHexProc;
  FTokenMethodTable[toAsm] := AnkProc;
end;

procedure TDelphiFountainParser.CharCodeProc;
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

procedure TDelphiFountainParser.ControlCodeHexProc;
// '#$'
begin
  FToken := toControlCodeHex;
  while FP^ in ['0'..'9', 'A'..'F', 'a'..'f'] do
    Inc(FP);
end;

procedure TDelphiFountainParser.ControlCodeProc;
// '#'
begin
  FToken := toControlCode;
  while FP^ in ['0'..'9'] do
    Inc(FP);
end;

procedure TDelphiFountainParser.HexPrefixProc;
// '$'
begin
  Inc(FP);
  HexProc;
end;

procedure TDelphiFountainParser.SlashProc;
// '/'
begin
  if (FP + 1)^ = '/' then
    CommenterProc
  else
    SymbolProc;
end;

procedure TDelphiFountainParser.PropertyCancelProc;
// ';'
begin
  if FElementIndex = PropertyBlockElement then
    FElementIndex := NormalElementIndex;
  SymbolProc;
end;

procedure TDelphiFountainParser.AnkProc;
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
end;

procedure TDelphiFountainParser.IntegerProc;
begin
  inherited IntegerProc;
  if FElementIndex = AsmBlockElement then
    FToken := toAsm;
end;

procedure TDelphiFountainParser.SymbolProc;
begin
  inherited SymbolProc;
  if FElementIndex = AsmBlockElement then
    FToken := toAsm;
end;

function TDelphiFountainParser.IsReserveWord: Boolean;
begin
  Result :=  (FToken <> toAsm) and inherited IsReserveWord;
end;

function TDelphiFountainParser.TokenToFountainColor: TFountainColor;
begin
  with TDelphiFountain(FFountain) do
    if IsReserveWord then
      Result := Reserve
    else
      case FToken of
        toSymbol:
          Result := FSymbol;
        toInteger, toFloat:
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
        toSingleQuotation, toControlCode, toControlCodeHex:
          Result := FStr;
        toAsm:
          Result := FAsmBlock;
      else
        Result := nil;
      end;
end;


{ TDelphiFountain }

destructor TDelphiFountain.Destroy;
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

procedure TDelphiFountain.CreateFountainColors;
begin
  inherited CreateFountainColors;
  FAnk := CreateFountainColor;
  FAsmBlock := CreateFountainColor;
  FComment := CreateFountainColor;
  FDBCS := CreateFountainColor;
  FInt := CreateFountainColor;
  FStr := CreateFountainColor;
  FSymbol := CreateFountainColor;
end;

procedure TDelphiFountain.SetAnk(Value: TFountainColor);
begin
  FAnk.Assign(Value);
end;

procedure TDelphiFountain.SetAsmBlock(Value: TFountainColor);
begin
  FAsmBlock.Assign(Value);
end;

procedure TDelphiFountain.SetComment(Value: TFountainColor);
begin
  FComment.Assign(Value);
end;

procedure TDelphiFountain.SetDBCS(Value: TFountainColor);
begin
  FDBCS.Assign(Value);
end;

procedure TDelphiFountain.SetInt(Value: TFountainColor);
begin
  FInt.Assign(Value);
end;

procedure TDelphiFountain.SetStr(Value: TFountainColor);
begin
  FStr.Assign(Value);
end;

procedure TDelphiFountain.SetSymbol(Value: TFountainColor);
begin
  FSymbol.Assign(Value);
end;

function TDelphiFountain.GetParserClass: TFountainParserClass;
begin
  Result := TDelphiFountainParser;
end;

procedure TDelphiFountain.InitBracketItems;
var
  Item: TFountainBracketItem;
begin
  Item := Brackets.Add;
  Item.LeftBracket := '{';
  Item.RightBracket := '}';
  Item := Brackets.Add;
  Item.LeftBracket := '(*';
  Item.RightBracket := '*)';
end;

procedure TDelphiFountain.InitFileExtList;
begin
  with FileExtList do
  begin
    Add('.pas');
    Add('.dpr');
    Add('.inc');
  end;
end;

procedure TDelphiFountain.InitReserveWordList;
begin
  with ReserveWordList do
  begin
    Add('absolute');
    Add('abstract');
    Add('and');
    Add('array');
    Add('as');
    Add('asm');
    Add('assembler');
    Add('automated');
    Add('begin');
    Add('case');
    Add('cdecl');
    Add('class');
    Add('const');
    Add('constructor');
    Add('default');
    Add('destructor');
    Add('dispid');
    Add('dispinterface');
    Add('div');
    Add('do');
    Add('downto');
    Add('dynamic');
    Add('else');
    Add('end');
    Add('except');
    Add('export');
    Add('exports');
    Add('external');
    Add('far');
    Add('file');
    Add('finalization');
    Add('finally');
    Add('for');
    Add('forward');
    Add('function');
    Add('goto');
    Add('if');
    Add('implementation');
    Add('in');
//    Add('index');
    Add('inherited');
    Add('initialization');
    Add('inline');
    Add('interface');
    Add('is');
    Add('label');
    Add('library');
    Add('message');
    Add('mod');
//    Add('name');
    Add('near');
    Add('nil');
    Add('nodefault');
    Add('not');
    Add('object');
    Add('of');
    Add('or');
    Add('out');
    Add('overload');
    Add('override');
    Add('packed');
    Add('pascal');
    Add('private');
    Add('procedure');
    Add('program');
    Add('property');
    Add('protected');
    Add('public');
    Add('published');
    Add('raise');
//    Add('read');
    Add('readonly');
    Add('record');
    Add('register');
    Add('repeat');
    Add('resident');
    Add('resourcestring');
    Add('safecall');
    Add('set');
    Add('shl');
    Add('shr');
    Add('stdcall');
    Add('stored');
    Add('string');
    Add('then');
    Add('threadvar');
    Add('to');
    Add('try');
    Add('type');
    Add('unit');
    Add('until');
    Add('uses');
    Add('var');
    Add('virtual');
    Add('while');
    Add('with');
//    Add('write');
    Add('writeonly');
    Add('xor');
  end;
end;

end.

