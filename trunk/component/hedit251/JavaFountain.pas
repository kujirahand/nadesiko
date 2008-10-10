(*********************************************************************

  JavaFountain.pas

  start  2002/02/12
  update 2002/02/22

  Copyright (c) 2002 Km <CQE03114@nifty.ne.jp>
  http://homepage2.nifty.com/Km/

  --------------------------------------------------------------------
  Java を表示するための TJavaFountain コンポーネントと
  TJavaFountainParser クラス

**********************************************************************)

unit JavaFountain;

interface

uses
  SysUtils, Classes, heClasses, heFountain, heRaStrings;

const
  toJavaHex            = Char(50);

type
  TJavaFountainParser = class(TFountainParser)
  protected
    procedure InitMethodTable; override;
    procedure ZeroProc; virtual;
    procedure JavaHexProc; virtual;
    procedure SlashProc; virtual;
  public
    function TokenToFountainColor: TFountainColor; override;
  end;

  TJavaFountain = class(TFountain)
    FAnk:     TFountainColor;           // 半角文字
    FComment: TFountainColor;           // コメント部分
    FDBCS:    TFountainColor;           // 全角文字と半角カタカナ
    FInt:     TFountainColor;           // 数値
    FStr:     TFountainColor;           // 文字列
    FSymbol:  TFountainColor;           // 記号
    procedure SetAnk(Value: TFountainColor);
    procedure SetComment(Value: TFountainColor);
    procedure SetDBCS(Value: TFountainColor);
    procedure SetInt(Value: TFountainColor);
    procedure SetStr(Value: TFountainColor);
    procedure SetSymbol(Value: TFountainColor);
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
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TEditor', [TJavaFountain]);
end;


{ TJavaFountainParser }

procedure TJavaFountainParser.InitMethodTable;
begin
  inherited InitMethodTable;
  // FMethodTable
  FMethodTable['0'] := ZeroProc;
  FMethodTable[#39] := SingleQuotationProc;
  FMethodTable['"'] := DoubleQuotationProc;
  FMethodTable['/'] := SlashProc;
  // FTokenMethodTable
  FTokenMethodTable[toJavaHex] := JavaHexProc;
end;

procedure TJavaFountainParser.ZeroProc;
// '0'
begin
  Inc(FP);
  if (FP^ = 'x') or (FP^ = 'X') then
  begin
    Inc(FP);
    JavaHexProc;
  end
  else
    IntegerProc;
end;

procedure TJavaFountainParser.JavaHexProc;
// '0xhhh'
begin
  FToken := toJavaHex;
  while FP^ in ['0'..'9', 'A'..'F', 'a'..'f'] do
    Inc(FP);
end;

procedure TJavaFountainParser.SlashProc;
// '/'
begin
  if (FP + 1)^ = '/' then
    CommenterProc
  else
    SymbolProc;
end;

function TJavaFountainParser.TokenToFountainColor: TFountainColor;
begin
  with TJavaFountain(FFountain) do
    if IsReserveWord then
      Result := Reserve
    else
      case FToken of
        toSymbol:
          Result := FSymbol;
        toInteger, toFloat, toJavaHex:
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
      else
        Result := nil;
      end;
end;


{ TJavaFountain }

destructor TJavaFountain.Destroy;
begin
  FAnk.Free;
  FComment.Free;
  FDBCS.Free;
  FInt.Free;
  FStr.Free;
  FSymbol.Free;
  inherited Destroy;
end;

procedure TJavaFountain.CreateFountainColors;
begin
  inherited CreateFountainColors;
  FAnk          := CreateFountainColor;
  FComment      := CreateFountainColor;
  FDBCS         := CreateFountainColor;
  FInt          := CreateFountainColor;
  FStr          := CreateFountainColor;
  FSymbol       := CreateFountainColor;
end;

procedure TJavaFountain.SetAnk(Value: TFountainColor);
begin
  FAnk.Assign(Value);
end;

procedure TJavaFountain.SetComment(Value: TFountainColor);
begin
  FComment.Assign(Value);
end;

procedure TJavaFountain.SetDBCS(Value: TFountainColor);
begin
  FDBCS.Assign(Value);
end;

procedure TJavaFountain.SetInt(Value: TFountainColor);
begin
  FInt.Assign(Value);
end;

procedure TJavaFountain.SetStr(Value: TFountainColor);
begin
  FStr.Assign(Value);
end;

procedure TJavaFountain.SetSymbol(Value: TFountainColor);
begin
  FSymbol.Assign(Value);
end;

function TJavaFountain.GetParserClass: TFountainParserClass;
begin
  Result := TJavaFountainParser;
end;

procedure TJavaFountain.InitBracketItems;
var
  Item: TFountainBracketItem;
begin
  Item := Brackets.Add;
  Item.LeftBracket := '/*';
  Item.RightBracket := '*/';
end;

procedure TJavaFountain.InitReserveWordList;
begin
  with ReserveWordList do
  begin
    Add('abstract');
    Add('boolean');
    Add('break');
    Add('byte');
    Add('case');
    Add('catch');
    Add('char');
    Add('class');
    Add('const');
    Add('continue');
    Add('default');
    Add('do');
    Add('double');
    Add('else');
    Add('extends');
    Add('final');
    Add('finally');
    Add('float');
    Add('for');
    Add('goto');
    Add('if');
    Add('implements');
    Add('import');
    Add('instanceof');
    Add('int');
    Add('interface');
    Add('long');
    Add('native');
    Add('new');
    Add('package');
    Add('private');
    Add('protected');
    Add('public');
    Add('return');
    Add('short');
    Add('static');
    Add('super');
    Add('switch');
    Add('synchronized');
    Add('this');
    Add('throw');
    Add('throws');
    Add('transient');
    Add('try');
    Add('void');
    Add('volatile');
    Add('while');
  end;
end;

procedure TJavaFountain.InitFileExtList;
begin
  with FileExtList do
  begin
    Add('.java');
    Add('.class');
  end;
end;

end.
