(*********************************************************************

  EditorFountain.pas

  start  2001/03/07
  update 2001/10/12

  Copyright (c) 2001-2002 本田勝彦 <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  TEditor がデフォルトで所有する TFountain コンポーネント。
  TEditorParser をパートナーとして機能する。
  また TEditorViewInfo のデータコンテナとして利用される。
  Delphi-IDE へのインストールは行わない。

**********************************************************************)

unit EditorFountain;

{$I heverdef.inc}

interface

uses
  SysUtils, Classes, Graphics, TypInfo, heUtils, heClasses, heFountain,
  heRaStrings;

const
  toQuotation       = Char(26);
  toControlCode     = Char(27);
  toControlCodeHex  = Char(28);

type
  TEditorBracketItem = class(TFountainBracketItem);

  TEditorBracketCollection = class(TFountainBracketCollection)
  public
    procedure SameBkColor(B: TColor); virtual;
    procedure SameColor(C: TColor); virtual;
    procedure SameStyle(Style: TFontStyles); virtual;
  end;

  TEditorColor = class(TFountainColor);

  TEditorColors = class(TNotifyPersistent)
  private
    FAnk: TEditorColor;                  // 半角文字
    FComment: TEditorColor;              // コメント部分
    FDBCS: TEditorColor;                 // 全角文字と半角ｶﾀｶﾅ
    FHit: TEditorColor;                  // 検索一致文字列
    FInt: TEditorColor;                  // 数値
    FMail: TEditorColor;                 // mail アドレス
    FSelect: TEditorColor;               // 選択領域
    FStr: TEditorColor;                  // 文字列
    FSymbol: TEditorColor;               // 記号
    FUrl: TEditorColor;                  // url
    function GetReserve: TEditorColor;
    procedure SetAnk(Value: TEditorColor);
    procedure SetComment(Value: TEditorColor);
    procedure SetDBCS(Value: TEditorColor);
    procedure SetHit(Value: TEditorColor);
    procedure SetInt(Value: TEditorColor);
    procedure SetMail(Value: TEditorColor);
    procedure SetReserve(Value: TEditorColor);
    procedure SetSelect(Value: TEditorColor);
    procedure SetStr(Value: TEditorColor);
    procedure SetSymbol(Value: TEditorColor);
    procedure SetUrl(Value: TEditorColor);
  protected
    FFountain: TFountain; // Select, Reserve プロパティのデータ格納先
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Ank: TEditorColor read FAnk write SetAnk;
    property Comment: TEditorColor read FComment write SetComment;
    property DBCS: TEditorColor read FDBCS write SetDBCS;
    property Hit: TEditorColor read FHit write SetHit;
    property Int: TEditorColor read FInt write SetInt;
    property Mail: TEditorColor read FMail write SetMail;
    property Reserve: TEditorColor read GetReserve write SetReserve;
    property Select: TEditorColor read FSelect write SetSelect;
    property Str: TEditorColor read FStr write SetStr;
    property Symbol: TEditorColor read FSymbol write SetSymbol;
    property Url: TEditorColor read FUrl write SetUrl;
  end;

  TEditorParser = class(TFountainParser)
  protected
    procedure InitMethodTable; override;
    procedure NormalTokenProc; override;
    function IncludeTabToken: TCharSet; override;
    function IsQuotationProc: Boolean; virtual;
    procedure QuotationProc; virtual;
    function IsCommenterProc: Boolean; virtual;
    function IsHexPrefixProc: Boolean; virtual;
    function IsControlCodeHexProc: Boolean; virtual;
    procedure ControlCodeHexProc; virtual;
    function IsControlCodeProc: Boolean; virtual;
    procedure ControlCodeProc; virtual;
  public
    function TokenToFountainColor: TFountainColor; override;
  end;

  TEditorFountain = class(TFountain)
  private
    FColors: TEditorColors;  // 色々
    FCommenter: String;      // 行末までをコメントにする文字列
    FControlCode: Boolean;   // # を文字コードとして識別するしないフラグ
    FHexPrefix: String;      // １６進数の前に付く記号 ex $, 0x
    FMail: Boolean;          // mail アドレスを認識するしないフラグ
    FQuotation: String;      // 文字列を指定する引用符 ex ', "
    FUrl: Boolean;           // url を識別するしないフラグ
    procedure SetColors(Value: TEditorColors);
  protected
    function CreateBrackets: TFountainBracketCollection; override;
    function CreateColors: TEditorColors; virtual;
    function GetParserClass: TFountainParserClass; override;
    procedure FountainColorProc(Instance: TObject; pInfo: PPropInfo;
      tInfo: PTypeInfo); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SameBkColor(B: TColor); virtual;
    procedure SameColor(C: TColor); virtual;
    procedure SameStyle(Style: TFontStyles); virtual;
  published
    property Colors: TEditorColors read FColors write SetColors;
    property Commenter: String read FCommenter write FCommenter;
    property ControlCode: Boolean read FControlCode write FControlCode;
    property HexPrefix: String read FHexPrefix write FHexPrefix;
    property Mail: Boolean read FMail write FMail;
    property Quotation: String read FQuotation write FQuotation;
    property Url: Boolean read FUrl write FUrl;
  end;

implementation


{ TEditorBracketCollection }

procedure TEditorBracketCollection.SameBkColor(B: TColor);
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := 0 to Count - 1 do
      BracketItems[I].ItemColor.BkColor := B;
  finally
    EndUpdate;
  end;
end;

procedure TEditorBracketCollection.SameColor(C: TColor);
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := 0 to Count - 1 do
      BracketItems[I].ItemColor.Color := C;
  finally
    EndUpdate;
  end;
end;

procedure TEditorBracketCollection.SameStyle(Style: TFontStyles);
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := 0 to Count - 1 do
      BracketItems[I].ItemColor.Style := Style;
  finally
    EndUpdate;
  end;
end;


{ TEditorColors }

constructor TEditorColors.Create;
begin
  FAnk := TEditorColor.Create;
  FAnk.OnChange := ChangedProc;
  FComment := TEditorColor.Create;
  FComment.OnChange := ChangedProc;
  FDBCS := TEditorColor.Create;
  FDBCS.OnChange := ChangedProc;
  FHit := TEditorColor.Create;
  FHit.OnChange := ChangedProc;
  FInt := TEditorColor.Create;
  FInt.OnChange := ChangedProc;
  FMail := TEditorColor.Create;
  FMail.OnChange := ChangedProc;
  FSelect := TEditorColor.Create;
  FSelect.BkColor := clNavy;
  FSelect.Color := clWhite;
  FSelect.OnChange := ChangedProc;
  FStr := TEditorColor.Create;
  FStr.OnChange := ChangedProc;
  FSymbol := TEditorColor.Create;
  FSymbol.OnChange := ChangedProc;
  FUrl := TEditorColor.Create;
  FUrl.OnChange := ChangedProc;
end;

destructor TEditorColors.Destroy;
begin
  FAnk.Free;
  FComment.Free;
  FDBCS.Free;
  FHit.Free;
  FInt.Free;
  FMail.Free;
  FSelect.Free;
  FStr.Free;
  FSymbol.Free;
  FUrl.Free;
  inherited Destroy;
end;

procedure TEditorColors.Assign(Source: TPersistent);
begin
  if Source is TEditorColors then
  begin
    BeginUpdate;
    try
      FAnk.Assign(TEditorColors(Source).FAnk);
      FComment.Assign(TEditorColors(Source).FComment);
      FDBCS.Assign(TEditorColors(Source).FDBCS);
      FHit.Assign(TEditorColors(Source).FHit);
      FInt.Assign(TEditorColors(Source).FInt);
      FMail.Assign(TEditorColors(Source).FMail);
      FStr.Assign(TEditorColors(Source).FStr);
      FSymbol.Assign(TEditorColors(Source).FSymbol);
      Reserve.Assign(TEditorColors(Source).Reserve);
      FUrl.Assign(TEditorColors(Source).FUrl);
      FSelect.Assign(TEditorColors(Source).FSelect);
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TEditorColors.SetAnk(Value: TEditorColor);
begin
  FAnk.Assign(Value);
end;

procedure TEditorColors.SetComment(Value: TEditorColor);
begin
  FComment.Assign(Value);
end;

procedure TEditorColors.SetDBCS(Value: TEditorColor);
begin
  FDBCS.Assign(Value);
end;

procedure TEditorColors.SetHit(Value: TEditorColor);
begin
  FHit.Assign(Value);
end;

procedure TEditorColors.SetInt(Value: TEditorColor);
begin
  FInt.Assign(Value);
end;

procedure TEditorColors.SetMail(Value: TEditorColor);
begin
  FMail.Assign(Value);
end;

procedure TEditorColors.SetStr(Value: TEditorColor);
begin
  FStr.Assign(Value);
end;

procedure TEditorColors.SetSymbol(Value: TEditorColor);
begin
  FSymbol.Assign(Value);
end;

procedure TEditorColors.SetReserve(Value: TEditorColor);
begin
  FFountain.Reserve.Assign(Value);
end;

function TEditorColors.GetReserve: TEditorColor;
begin
  Result := TEditorColor(FFountain.Reserve);
end;

procedure TEditorColors.SetUrl(Value: TEditorColor);
begin
  FUrl.Assign(Value);
end;

procedure TEditorColors.SetSelect(Value: TEditorColor);
begin
  FSelect.Assign(Value);
end;


{ TEditorParser }

procedure TEditorParser.InitMethodTable;
begin
  inherited InitMethodTable;
  FTokenMethodTable[toQuotation] := QuotationProc;
  FTokenMethodTable[toControlCode] := ControlCodeProc;
  FTokenMethodTable[toControlCodeHex] := ControlCodeHexProc;
end;

function TEditorParser.IncludeTabToken: TCharSet;
begin
  Result := inherited IncludeTabToken + [toQuotation];
end;

procedure TEditorParser.NormalTokenProc;
begin
  if (FBracketIndex >= NormalBracketIndex) and IsBracketProc then
    BracketProc
  else
    if TEditorFountain(FFountain).Mail and IsMailProc then
      MailProc
    else
      if TEditorFountain(FFountain).Url and IsUrlProc then
        UrlProc
      else
        if IsCommenterProc then
          CommenterProc
        else
          if IsQuotationProc then
            QuotationProc
          else
            if IsControlCodeHexProc then
              ControlCodeHexProc
            else
              if IsControlCodeProc then
                ControlCodeProc
              else
                if IsHexPrefixProc then
                  HexProc
                else
                  FMethodTable[FP^];
end;

function TEditorParser.TokenToFountainColor: TFountainColor;
begin
  with FFountain, TEditorFountain(FFountain).FColors do
    if IsReserveWord then
      Result := Reserve
    else
      case FToken of
        toSymbol:
          Result := FSymbol;
        toInteger, toFloat:
          Result := FInt;
        toBracket:
          Result := TEditorColor(Brackets[FDrawBracketIndex].ItemColor);
        toComment:
          Result := FComment;
        toAnk:
          Result := FAnk;
        toDBSymbol, toDBInt, toDBAlph, toDBHira, toDBKana, toDBKanji, toKanaSymbol, toKana:
          Result := FDBCS;
        toUrl:
          Result := FUrl;
        toMail:
          Result := FMail;
        toHex:
          Result := FInt;
        toQuotation, toControlCode, toControlCodeHex:
          Result := FStr;
        toReserve:
          Result := Reserve;
      else
        Result := nil;
      end;
end;

function TEditorParser.IsCommenterProc: Boolean;
var
  S: String;
  I, L: Integer;
begin
  Result := False;
  if (FFountain = nil) or (TEditorFountain(FFountain).FCommenter = '') then
    Exit;
  S := TEditorFountain(FFountain).FCommenter;
  L := Length(S);
  for I := 1 to L do
    if (FP + I - 1)^ <> S[I] then
      Break
    else
      if I = L then
      begin
        Result := True;
        Inc(FP, L);
      end;
end;

function TEditorParser.IsQuotationProc: Boolean;
begin
  Result := (FFountain <> nil) and (TEditorFountain(FFountain).FQuotation <> '') and
            (FP^ = TEditorFountain(FFountain).FQuotation[1]);
  if Result then
    Inc(FP);
end;

procedure TEditorParser.QuotationProc;
var
  C: Char;
begin
  if (FFountain = nil) or (TEditorFountain(FFountain).FQuotation = '') then
    FToken := toEof
  else
  begin
    FToken := toQuotation;
    C := TEditorFountain(FFountain).FQuotation[1];
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
end;

function TEditorParser.IsControlCodeHexProc: Boolean;
begin
  Result := (FFountain <> nil) and TEditorFountain(FFountain).FControlCode and
            (FP^ = '#') and ((FP + 1)^ = '$');
  if Result then
    Inc(FP, 2);
end;

procedure TEditorParser.ControlCodeHexProc;
(*
  下の判別は、行末の折り返しで # と $ が分割されている場合、
  行頭の $ が toControlCodeHex として認識されない仕様になっている
  WrapOption.FollowStr に $ を追加し、Leading プロパティを
  True に設定することでこの問題を回避することが出来る。
*)
begin
  FToken := toControlCodeHex;
  while FP^ in ['0'..'9', 'A'..'F', 'a'..'f'] do // imperfection
    Inc(FP);
end;

function TEditorParser.IsControlCodeProc: Boolean;
begin
  Result := (FFountain <> nil) and TEditorFountain(FFountain).FControlCode and (FP^ = '#');
  if Result then
    Inc(FP);
end;

procedure TEditorParser.ControlCodeProc;
begin
  FToken := toControlCode;
  while FP^ in ['0'..'9'] do
    Inc(FP);
end;

function TEditorParser.IsHexPrefixProc: Boolean;
var
  S: String;
  I, L: Integer;
begin
  Result := False;
  if (FFountain = nil) or (TEditorFountain(FFountain).FHexPrefix = '') then
    Exit;
  S := UpperCase(TEditorFountain(FFountain).FHexPrefix);
  L := Length(S);
  for I := 1 to L do
    if UpCase((FP + I - 1)^) <> S[I] then
      Break
    else
      if I = L then
      begin
        Result := True;
        Inc(FP, L);
      end;
end;


{ TEditorFountain }

constructor TEditorFountain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColors := CreateColors;
end;

destructor TEditorFountain.Destroy;
begin
  FColors.Free;
  inherited Destroy;
end;

function TEditorFountain.CreateBrackets: TFountainBracketCollection;
begin
  Result := TEditorBracketCollection.Create;
  TEditorBracketCollection(Result).FOwner := Self;
  Result.OnChange := NotifyEventList.ChangedProc;
end;

function TEditorFountain.CreateColors: TEditorColors;
begin
  Result := TEditorColors.Create;
  Result.FFountain := Self;
  Result.OnChange := NotifyEventList.ChangedProc;
end;

function TEditorFountain.GetParserClass: TFountainParserClass;
begin
  Result := TEditorParser;
end;

procedure TEditorFountain.SetColors(Value: TEditorColors);
begin
  FColors.Assign(Value);
end;

procedure TEditorFountain.SameBkColor(B: TColor);
var
  FountainColor: TFountainColor;
begin
  FountainColor := TFountainColor.Create;
  try
    FountainColor.BkColor := B;
    NotifyEventList.BeginUpdate;
    try
      SameFountainColor(Self.Colors, FountainColor, [coBkColor]);
    finally
      NotifyEventList.EndUpdate;
    end;
  finally
    FountainColor.Free;
  end;
end;

procedure TEditorFountain.SameColor(C: TColor);
var
  FountainColor: TFountainColor;
begin
  FountainColor := TFountainColor.Create;
  try
    FountainColor.Color := C;
    NotifyEventList.BeginUpdate;
    try
      SameFountainColor(Self.Colors, FountainColor, [coColor]);
    finally
      NotifyEventList.EndUpdate;
    end;
  finally
    FountainColor.Free;
  end;
end;

procedure TEditorFountain.SameStyle(Style: TFontStyles);
var
  FountainColor: TFountainColor;
begin
  FountainColor := TFountainColor.Create;
  try
    FountainColor.Style := Style;
    NotifyEventList.BeginUpdate;
    try
      SameFountainColor(Self.Colors, FountainColor, [coStyle]);
    finally
      NotifyEventList.EndUpdate;
    end;
  finally
    FountainColor.Free;
  end;
end;

procedure TEditorFountain.FountainColorProc(Instance: TObject; pInfo: PPropInfo;
  tInfo: PTypeInfo);
begin
  if (AnsiCompareText(pInfo.Name, 'Select') <> 0) or
     (AnsiCompareText(pInfo.Name, 'Hit') <> 0) then
    inherited FountainColorProc(Instance, pInfo, tInfo);
end;

end.

