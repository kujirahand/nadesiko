(*********************************************************************

  JSPFountain.pas

  start  2002/09/25
  update 2002/10/21

  Copyright (C) 2002 Km <CQE03114@nifty.ne.jp>
  http://homepage2.nifty.com/Km/

  --------------------------------------------------------------------
  JSP を表示するための TJSPFountain コンポーネントと
  TJSPFountainParser クラス

**********************************************************************)

unit JSPFountain;

{$I heverdef.inc}

interface

uses
  SysUtils, Classes, heClasses, heFountain, heRaStrings;

const
  toReserve2              = Char(30);
  toTagStart              = Char(50);
  toTagEnd                = Char(51);
  toTagElement            = Char(52);
  toTagAttribute          = Char(53);
  toTagAttributeDelimiter = Char(54);
  toTagAttributeValue     = Char(55);
  toAmpersand             = Char(56);
  toScript                = Char(57);

  ScriptElement           = 1;
  CommentElement          = 2;

type
  TJSPFountainParser = class(TFountainParser)
  private
    FInTag: Boolean;
  protected
    procedure InitMethodTable; override;
    procedure TagStartProc; virtual;
    procedure TagEndProc; virtual;
    procedure PercentProc; virtual;
    procedure SlashProc; virtual;
    procedure DoubleQuotationProc; override;
    procedure SingleQuotationProc; override;
    procedure AmpersandProc; virtual;
    procedure ReserveWord2Proc; virtual;
    procedure NormalTokenProc; override;
    procedure TagElementProc; virtual;
    procedure TagAttributeProc; virtual;
    procedure TagAttributeDelimiterProc; virtual;
    procedure TagAttributeValueProc; virtual;
    procedure AnkProc; override;
    procedure WrappedTokenIsReserveWord(var AToken: Char); override;
    procedure UpdateTagToken; virtual;
    function IsReserveWord: Boolean; override;
    function IsReserveWord2: Boolean; virtual;

  public
    function NextToken: Char; override;
    function TokenToFountainColor: TFountainColor; override;
  end;

  TJSPFountain = class(TFountain)
  private
    FAmpersand: TFountainColor;
    FMail: TFountainColor;
    FStr: TFountainColor;
    FTagAttribute: TFountainColor;
    FTagAttributeValue: TFountainColor;
    FTagColor: TFountainColor;
    FTagElement: TFountainColor;
    FUrl: TFountainColor;
    FScript: TFountainColor;
    FComment: TFountainColor;
    FReserveWordList2: TStringList;
    procedure SetAmpersand(Value: TFountainColor);
    procedure SetMail(Value: TFountainColor);
    procedure SetStr(Value: TFountainColor);
    procedure SetTagAttribute(Value: TFountainColor);
    procedure SetTagAttributeValue(Value: TFountainColor);
    procedure SetTagColor(Value: TFountainColor);
    procedure SetTagElement(Value: TFountainColor);
    procedure SetUrl(Value: TFountainColor);
    procedure SetScript(Value: TFountainColor);
    procedure SetComment(Value: TFountainColor);
    procedure SetReserveWordList2(Value: TStringList);
  protected
    procedure CreateFountainColors; override;
    function GetParserClass: TFountainParserClass; override;
    procedure InitBracketItems; override;
    procedure InitFileExtList; override;
    procedure InitReserveWordList; override;
    procedure InitReserveWordList2; virtual;
  public
    constructor Create(AOwner: TComponent); override;
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
    property Script: TFountainColor read FScript write SetScript;
    property Comment: TFountainColor read FComment write SetComment;
    property ReserveWordList2: TStringList read FReserveWordList2 write SetReserveWordList2;
  end;

procedure Register;

implementation

uses
  heUtils;

procedure Register;
begin
  RegisterComponents('TEditor', [TJSPFountain]);
end;

(*

JSPを認識するパーサーを実現する。基本的にはHTML部分とJSP部分の
違いを視覚的に表現することが目的。
Scriptlet、Declaration、Expression、Directiveに関しては区別せず
スクリプトとして取り扱う。スクリプトに関してはJavaのキーワード、
コメント、Directiveのキーワード等は色分けを実現する。
スクリプト中の/**/と//はCommentとする。
<jsp:～/>、<jsp:～>...</jsp:～>等はforward, getProperty, include,
plugin, setProperty, useBeanを付けるだけ。ただし、キーワードとは
しない。また、属性(TagAttribute)部分のキーワードはHTMLとかぶる物
も多いし、分ける意味合いが低そうなのでキーワードとしない。

Script
  <% %>     Scriptlet
    <%! %>  Declaration
    <%= %>  Expression
    <%@ %>  Directive (Include/Page/Taglib)

<jsp:～>    jsp,
            forward, getProperty, include, plugin, setProperty, useBean,
            param
Bracket
  <!-- -->  HTML Comment
  <%-- --%> Hidden Comment

*)


{ TJSPFountainParser }

procedure TJSPFountainParser.InitMethodTable;
begin
  inherited InitMethodTable;
  // FMethodTable
  FMethodTable['<'] := TagStartProc;
  FMethodTable['>'] := TagEndProc;
  FMethodTable['%'] := PercentProc;
  FMethodTable['/'] := SlashProc;
  FMethodTable['"'] := DoubleQuotationProc;
  FMethodTable[#39] := SingleQuotationProc;
  FMethodTable['&'] := AmpersandProc;
  FMethodTable['='] := TagAttributeDelimiterProc;
  // FTokenMethodTable
  FTokenMethodTable[toAmpersand] := AmpersandProc;
  FTokenMethodTable[toReserve2] := ReserveWord2Proc;
  FTokenMethodTable[toTagElement] := TagElementProc;
  FTokenMethodTable[toTagAttribute] := TagAttributeProc;
  FTokenMethodTable[toTagAttributeValue] := TagAttributeValueProc;
end;

procedure TJSPFountainParser.TagStartProc;
begin
  if FElementIndex = ScriptElement then
    SymbolProc
  else
    if FElementIndex = CommentElement then
    begin
      FToken := toComment;
      Inc(FP);
    end
    else
    begin
      if (FP + 1)^ <> '%' then
        FInTag := True;
      FToken := toTagStart;
      Inc(FP);
    end;
end;

procedure TJSPFountainParser.TagEndProc;
begin
  if FElementIndex = ScriptElement then
    SymbolProc
  else
    if FElementIndex = CommentElement then
    begin
      FToken := toComment;
      Inc(FP);
    end
    else
    begin
      if (FP - 1)^ <> '%' then
        FInTag := False;
      FToken := toTagEnd;
      Inc(FP);
    end;
end;

procedure TJSPFountainParser.PercentProc;
begin
  if FElementIndex = ScriptElement then
  begin
    if (FP + 1)^ = '>' then
      FElementIndex := NormalElementIndex;
    FToken := toScript;
    Inc(FP);
  end
  else
    if FElementIndex = CommentElement then
    begin
      FToken := toComment;
      Inc(FP);
    end
    else
      if FPrevToken = toTagStart then
      begin
        FToken := toScript;
        Inc(FP);
        FElementIndex := ScriptElement;
      end
      else
        SymbolProc;
end;

procedure TJSPFountainParser.SlashProc;
begin
  case FElementIndex of
    ScriptElement:
      if (FP + 1)^ = '/' then
        CommenterProc
      else
        if (FP + 1)^ = '*' then
        begin
          FToken := toComment;
          Inc(FP, 2);
          FElementIndex := CommentElement;
        end
        else
          SymbolProc;

    CommentElement:
      if (FP - 1)^ = '*' then
      begin
        FToken := toComment;
        Inc(FP);
        FElementIndex := ScriptElement;
      end
      else
        SymbolProc;
  else
    if FInTag and (FPrevToken = toTagStart) then
    begin
      Inc(FP);
      if IsKeyword('jsp') then
      begin
        AnkProc;
        FToken := toReserve2;
      end
      else
        TagElementProc;
    end
    else
      SymbolProc;
  end;
end;

procedure TJSPFountainParser.DoubleQuotationProc;
var
  C: Char;
  InScript: Boolean;
begin
  if not FInTag and (FElementIndex <> ScriptElement) then
    SymbolProc
  else
  begin
    InScript := False;
    FToken := toDoubleQuotation;
    if not FIsStartToken then
      Inc(FP);
    C := '"';
    while not (FP^ in [#0, #10, #13]) do
    begin
      if (FP^ = '<') and ((FP + 1)^ = '%') then
        InScript := True;

      if InScript and (FP^ = '%') and ((FP + 1)^ = '>') then
        InScript := False;

      if not InScript then
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

procedure TJSPFountainParser.SingleQuotationProc;
var
  C: Char;
  InScript: Boolean;
begin
  if not FInTag and (FElementIndex <> ScriptElement) then
    SymbolProc
  else
  begin
    InScript := False;
    FToken := toSingleQuotation;
    if not FIsStartToken then
      Inc(FP);
    C := #39;
    while not (FP^ in [#0, #10, #13]) do
    begin
      if (FP^ = '<') and ((FP + 1)^ = '%') then
        InScript := True;

      if InScript and (FP^ = '%') and ((FP + 1)^ = '>') then
        InScript := False;

      if not InScript then
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

procedure TJSPFountainParser.AmpersandProc;
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

procedure TJSPFountainParser.ReserveWord2Proc;
begin
  FMethodTable[FP^];
  FToken := toReserve2;
end;

procedure TJSPFountainParser.NormalTokenProc;
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
        if FPrevToken = toTagAttributeDelimiter then
          TagAttributeValueProc
        else
          FMethodTable[FP^];
end;

procedure TJSPFountainParser.WrappedTokenIsReserveWord(var AToken: Char);
begin
  if IsReserveWord then
    AToken := toReserve
  else
    if IsReserveWord2 then
      AToken := toReserve2;
end;

procedure TJSPFountainParser.TagElementProc;
// FStartToken = toTagElement, FWrappedByte = 0 の時に実行される
begin
  AnkProc;
  FToken := toTagElement;
end;

procedure TJSPFountainParser.TagAttributeProc;
// FStartToken = toTagAttribute, FWrappedByte = 0 の時に実行される
begin
  AnkProc;
  FToken := toTagAttribute;
end;

procedure TJSPFountainParser.TagAttributeDelimiterProc;
begin
  if FInTag and
    (FElementIndex <> ScriptElement) and
    (FElementIndex <> CommentElement) then
  begin
    FToken := toTagAttributeDelimiter;
    Inc(FP);
  end
  else
    SymbolProc;
end;

procedure TJSPFountainParser.TagAttributeValueProc;
// FStartToken = toTagAttributeValue, FWrappedByte = 0 の時にも実行される
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

procedure TJSPFountainParser.AnkProc;
// 'A'..'Z', '_', 'a'..'z':
begin
  FToken := toAnk;
  while FP^ in ['0'..'9', 'A'..'Z', '_', 'a'..'z'] do
    Inc(FP);
end;

procedure TJSPFountainParser.UpdateTagToken;
begin
  if FToken <> toEof then
    if FElementIndex = ScriptElement then
    begin
      if not (FToken in [toBracket, toComment, toDoubleQuotation, toSingleQuotation]) then
        FToken := toScript;
    end
    else
      if FElementIndex = CommentElement then
        FToken := toComment
      else
        if FInTag then
          case FPrevToken of
            toTagStart:
              if FToken = toAnk then
                FToken := toTagElement;

            toDoubleQuotation, toSingleQuotation, toTagElement, toTagAttributeValue, toTagAttribute:
            if FToken <> toTagAttributeDelimiter then
              FToken := toTagAttribute;

          end;
end;

function TJSPFountainParser.IsReserveWord: Boolean;
begin
  Result := (FToken = toScript) and
            inherited IsReserveWord;
end;

function TJSPFountainParser.IsReserveWord2: Boolean;
var
  I: Integer;
begin
  Result := FInTag and
            not FIsStartToken and
            not (FToken in [toEof, toBracket, toComment, toScript]) and
            TJSPFountain(FFountain).ReserveWordList2.Find(TokenString, I);
end;

function TJSPFountainParser.NextToken: Char;
begin
  inherited NextToken;
  UpdateTagToken;
  if FToken <> toEof then
    FPrevToken := FToken;
  Result := FToken;
end;

function TJSPFountainParser.TokenToFountainColor: TFountainColor;
begin
  with TJSPFountain(FFountain) do
    if IsReserveWord or IsReserveWord2 then
      Result := Reserve
    else
      case FToken of
        toBracket:
          Result := Brackets[FDrawBracketIndex].ItemColor;
        toReserve, toReserve2:
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
        toScript:
          Result := FScript;
        toComment:
          Result := FComment;
      else
        Result := nil;
      end;
end;



{ TJSPFountain }

constructor TJSPFountain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FReserveWordList2 := CreateSortedList;
  InitReserveWordList2;
end;

destructor TJSPFountain.Destroy;
begin
  FAmpersand.Free;
  FMail.Free;
  FStr.Free;
  FTagAttribute.Free;
  FTagAttributeValue.Free;
  FTagColor.Free;
  FTagElement.Free;
  FUrl.Free;
  FScript.Free;
  FComment.Free;
  FReserveWordList2.Free;
  inherited Destroy;
end;

procedure TJSPFountain.CreateFountainColors;
begin
  inherited CreateFountainColors;
  FAmpersand          := CreateFountainColor;
  FMail               := CreateFountainColor;
  FStr                := CreateFountainColor;
  FTagAttribute       := CreateFountainColor;
  FTagAttributeValue  := CreateFountainColor;
  FTagColor           := CreateFountainColor;
  FTagElement         := CreateFountainColor;
  FUrl                := CreateFountainColor;
  FScript             := CreateFountainColor;
  FComment            := CreateFountainColor;
end;

procedure TJSPFountain.SetAmpersand(Value: TFountainColor);
begin
  FAmpersand.Assign(Value);
end;

procedure TJSPFountain.SetMail(Value: TFountainColor);
begin
  FMail.Assign(Value);
end;

procedure TJSPFountain.SetStr(Value: TFountainColor);
begin
  FStr.Assign(Value);
end;

procedure TJSPFountain.SetTagAttribute(Value: TFountainColor);
begin
  FTagAttribute.Assign(Value);
end;

procedure TJSPFountain.SetTagAttributeValue(Value: TFountainColor);
begin
  FTagAttributeValue.Assign(Value);
end;

procedure TJSPFountain.SetTagColor(Value: TFountainColor);
begin
  FTagColor.Assign(Value);
end;

procedure TJSPFountain.SetTagElement(Value: TFountainColor);
begin
  FTagElement.Assign(Value);
end;

procedure TJSPFountain.SetUrl(Value: TFountainColor);
begin
  FUrl.Assign(Value);
end;

procedure TJSPFountain.SetScript(Value: TFountainColor);
begin
  FScript.Assign(Value);
end;

procedure TJSPFountain.SetComment(Value: TFountainColor);
begin
  FComment.Assign(Value);
end;

procedure TJSPFountain.SetReserveWordList2(Value: TStringList);
begin
  FReserveWordList2.Assign(Value);
  NotifyEventList.ChangedProc(Self);
end;

function TJSPFountain.GetParserClass: TFountainParserClass;
begin
  Result := TJSPFountainParser;
end;

procedure TJSPFountain.InitBracketItems;
var
  Item: TFountainBracketItem;
begin
  // HTML Comment
  Item := Brackets.Add;
  Item.LeftBracket := '<!--';
  Item.RightBracket := '-->';
  // Hidden Comment
  Item := Brackets.Add;
  Item.LeftBracket := '<%--';
  Item.RightBracket := '--%>';
end;

procedure TJSPFountain.InitFileExtList;
begin
  with FileExtList do
  begin
    Add('.jsp');
  end;
end;

procedure TJSPFountain.InitReserveWordList;
begin
  with ReserveWordList do
  begin
// Scriptlet--Java Keyword
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
// Include Directive Keyword
    Add('include');
    Add('file');
// Page Directive Keyword
    Add('page');
    Add('language');
    //Add('extends');
    //Add('import');
    Add('session');
    Add('buffer');
    Add('autoFlush');
    Add('isThreadSafe');
    Add('info');
    Add('errorPage');
    Add('contentType');
    Add('charset');
    Add('isErrorPage');
// Taglib Directive Keyword
    Add('taglib');
    Add('uri');
    Add('prefix');
  end;
end;

procedure TJSPFountain.InitReserveWordList2;
begin
  with ReserveWordList2 do
  begin
    Add('jsp');
    Add('forward');
    Add('getProperty');
    Add('include');
    Add('plugin');
    Add('param');
    Add('setProperty');
    Add('useBean');
  end;
end;

end.

