unit javaSctipyHTMLParser;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls ;
{ TScParser special tokens }
  const UnitVersion = 1.1;
const

 {toEOF        = Char(0);
  toSymbol     = Char(1);
  toString     = Char(2);
  toInteger    = Char(3);
  toFloat      = Char(4);}
  toBracket    = Char(5);
  toComment    = Char(6);
  toAnk        = Char(8);
  toTab        = Char(9);
  toDBSymbol   = Char(11);
  toDBInt      = Char(12);
  toDBAlph     = Char(14);
  toDBHira     = Char(15);
  toDBKana     = Char(16);
  toDBKanji    = Char(17);
  toKanaSymbol = Char(18);
  toKana       = Char(19);
  toUrl        = Char(20);



type
TAdjucentTagPos = record
   beforeBegin , afterBegin
  ,beforeEnd   , afterEnd : cardinal;
end;

type
  Padj = ^Tadj;
  Tadj = record
    beforeBegin: Integer;
    afterBegin : integer;
    beforeEnd  : integer;
    afterEnd   : integer;
//    LName: string;
end;
type
 TScParser = class(TObject)
  private
    function getBeginToken: integer;
    function getEndToken: integer;
  protected
 //   FEditor: TEditor;
    FTerminateBracket : boolean;
    FBracketIndex: Integer;
    FDrawBracketIndex: Integer;
    FBuffer: PChar;
    FBufSize: Integer;
    FSourcePtr: PChar;
    FTokenPtr: PChar;
    FToken: Char;
    FURLKind : string;
    procedure SkipBlanks; virtual;
  public

    BracketString : string;   // tokenがtoBrackeの場合,判断されたleftBracketがはいる
    isCKBracket : boolean;   //ブラケットの判断をするか
    RightBracket : TStringList;
    LeftBracket  : TSTringList;
    FQuotation : TStringList; //コーティション野定義
    FComment : tstringlist;  //コメントの定義
//    FMultiComment  :TStringlist;
    FURL : boolean;          //urlの判定をするか
    FckQuot : boolean;
    FHexPrefix : string;     //十六進数の判定をするか


    property TerminateBracket : boolean read FTerminateBracket;  //ブラケットが閉じられているか
    constructor Create(const S: String);
//    constructor CreateWithEditor(const S: String; Editor: TEditor;
//      BracketIndex: Integer);
    destructor Destroy; override;
    function NextToken: Char; virtual;
    function SourcePos: Longint; virtual;
    function TokenString: string;
    property doc :pchar read FBuffer;
    property Doclength : integer read FBufSize;

    procedure Reset ;
    property ckURL : boolean read FURL Write FURL ; //urkのチェックをするのか
    property ckQuot :boolean read FckQuot Write FckQuot;
    property URLKind : string read FURLKind; //URLの種類?href ?src
    property beginToken :integer read getBeginToken;
    property endToken   : integer read getEndToken;
    property DrawBracketIndex: Integer read FDrawBracketIndex;
    property Token: Char read FToken;
  end;

type
 TScriptParser = class(TScparser)
 public
    constructor Create(const S: String);
    destructor Destroy; override;
//    function NextToken: Char; override;
 end;

type
 TTagParser = class(TScparser)
 private
  FTokenDUPPtr: PChar;
  fisContainer : bool;
  TagOverlapping : boolean;
 public
    PROPERTY OverLapping :boolean read TagOverLapping;
    constructor Create(const S: String ; isContainer : boolean = false);
    destructor Destroy; override;
    function NextToken: Char; override;
 end;
     //TtagParserでおもに使える・
    function GetInnerHTML(doc , tag : string; container : boolean = false) : string;
    function GetOuterHTML(doc , tag : string; container : boolean = false) : string;

    function Get_outerHTML(parser : TScParser ; tag: string ): string;
    function Get_innerHTML(parser: TScParser;  tag: string ): string;
    function AdjacentTag(parser: TScParser; Tag : string ;  var adjTagPos : TAdjucentTagPos) : boolean ;

    function RemoveCRLFs(const OldStr : string) : string;

 implementation
// 大文字変換
function UpCase(ch: char): char;
begin
    if (Ch >= 'a') and (Ch <= 'z') then Dec(Ch, 32);
    result :=ch;
end;

 { TScParser }


constructor TScParser.Create(const S: String);
begin
    Furl := false;
    Fckquot := true;
    isckBracket := true;
    RightBracket := TStringList.create;
    LeftBracket  := TStringList.create;
    FQuotation := TStringList.create;
    FComment := TStringList.create;
//    FMultiComment  := TStringList.create;

  FBufSize := Length(S);
  GetMem(FBuffer, FBufSize + 1);
  if FBufSize > 0 then
    Move(S[1], FBuffer[0], FBufSize);
  FBuffer[FBufSize] := #0;
  FSourcePtr := FBuffer;
  FTokenPtr := FBuffer;
end;

destructor TScParser.Destroy;
begin
    RightBracket.Free;
    LeftBracket.Free;
    FQuotation.Free;
    FComment.Free;



  if FBuffer <> nil then
    FreeMem(FBuffer, FBufSize + 1);
end;

procedure TScParser.SkipBlanks;
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

function TScParser.SourcePos: Longint;
begin
  Result := FTokenPtr - FBuffer;
end;

function TScParser.TokenString: string;
begin
  SetString(Result, FTokenPtr, FSourcePtr - FTokenPtr);
end;

function TScParser.NextToken: Char;
var
  I, L, J: Integer;
  P, SavePtr: PChar;
  S: String;

  procedure InBracket;
  var
    L, I: Integer;
    S: String;
    SavePtr: PChar;
  begin
    S := RightBracket[FBracketIndex];
    L := Length(S);
    while not (P^ in [#0 ]) and (L > 0) do
    begin
      if upCase(P^) = upCase(S[1]) then
      begin
        SavePtr := P;
        I := 1;
        while I <= L do
          if upCase(P^) = UPCase(S[I]) then
            if I = L then
            begin
              Inc(P);
              Result := toBracket;
              BracketString :=LeftBracket[FBracketIndex];
              FTerminateBracket := true;
              FBracketIndex := -1;

              Exit;
            end
            else
            begin
              Inc(P);
              Inc(I);
            end
          else
          begin
            P := SavePtr;
            Break;
          end;
      end;
      if P^ in [#$81..#$9F, #$E0..#$FC] then
        Inc(P);
      Inc(P);
    end;
    BracketString :=LeftBracket[FBracketIndex];
    Result := toBracket;
    FTerminateBracket := false;
  end;

  function CheckUrl(const S: String): Boolean;
  var
    L, I: Integer;
    SavePtr: PChar;
  begin
    Result := False;
    SavePtr := P;
    L := Length(S);
    I := 1;
    while I <= L do
      if P^ = S[I] then
        if I = L then
        begin
          Result := True;
          while P^ in ['"','\','''','#', '%', '&', '+', '-', '.', '/', '0'..'9', ':', '=', '?', 'A'..'Z', '_', 'a'..'z'] do Inc(P);
          NextToken := toUrl;
          FSourcePtr := P;
          FToken := toUrl;
          Break;
        end
        else
        begin
          Inc(P);
          Inc(I);
        end
      else
      begin
        P := SavePtr;
        Break;
      end;
  end;

begin
  SkipBlanks;
  P := FSourcePtr;
  FTokenPtr := P;
  FurlKind :='';

  // check eof
  if P^ in [#0] then
  begin
    Result := toEof;
    FSourcePtr := P;
    FToken := Result;
    Exit;
  end;

  if isCKBracket  then
  begin
  //  begin
    // Brackets
       FBracketIndex := -1   ;
       begin
        SavePtr := P;
        for I := 0 to RightBracket.Count - 1 do
        begin
          S := LeftBracket[ i ];
          L := Length(S);
          J := 1;
          while J <= L do
            if upCase(P^) = upcase(S[J]) then
              if J = L then
              begin
                Inc(P);
                FBracketIndex := I;
                FDrawBracketIndex := FBracketIndex;
                InBracket;
                FSourcePtr := P;
                FToken := Result;
                Exit;
              end
              else
              begin
                Inc(P);
                Inc(J);
              end
            else
            begin
              P := SavePtr;
              Break;
            end;
        end;
      end;

    // Commenter
    i :=0;
    while  i < FComment.count do
    begin
      S := FComment[ i ] ;
      inc( i );
      L := Length(S);
      J := 1;
      SavePtr := P;
      while J <= L do
        if upcase(P^) = upcase(S[J]) then
          if J = L then
          begin
            Result := toComment;
            while not (P^ in [#0, #10, #13]) do
              Inc(P);
            FSourcePtr := P;
            FToken := Result;
            Exit;
          end  //if j=L
          else
          begin
            Inc(P);
            Inc(J);
          end  //if j=L else
        else
        begin
          P := SavePtr;
          Break;
        end; //if P^ = S[J]
     end;    // while  i < FComment.count-1

    // HexPrefix
    S := FHexPrefix;
    L := Length(S);
    J := 1;
    SavePtr := P;
    while J <= L do
      if P^ = S[J] then
        if J = L then
        begin
          Inc(P);
          while P^ in ['0'..'9', 'A'..'F', 'a'..'f'] do
            Inc(P);
          Result := toInteger;
          FSourcePtr := P;
          FToken := Result;
          Exit;
        end
        else
        begin
          Inc(P);
          Inc(J);
        end
      else
      begin
        P := SavePtr;
        Break;
      end;

  end;

      // url

    if FUrl then
      case P^ of
          'h': if checkurl('href=') then
          begin
            furlKind :='href=';
            exit;
          end;
          's': if checkUrl('src=') then
          begin
            furlKind :='src=';
            exit;
          end;
     //   'h': if CheckUrl('http:') or CheckUrl('https:')  then Exit;
     //   'f': if CheckUrl('ftp:') then Exit;
      end;


      // Quotation
  if fckquot then
  begin
    i:=0;
    while i < Fquotation.count do
    begin
    S := FQuotation[ i ] ;
    inc(i);
    if (Length(S) > 0) and (P^ = S[1]) then
    begin
      Inc(P);
      while True do
      begin
        if P^ in [#0 ] then
          Break
        else
          if P^ = S[1] then
          begin
            Inc(P);
            if P^ <> S[1] then
              Break;
          end;
        Inc(P);
      end;
      Result := toString;
      FSourcePtr := P;
      FToken := Result;
      Exit;
    end;
   end;
  end;



  // normal token
  case P^ of
    #9:
      begin
        Inc(P);
        Result := toTab;
      end;
    '0'..'9':
      begin
        Inc(P);
        while P^ in ['0'..'9'] do Inc(P);
        Result := toInteger;
        case P^ of
          'e', 'E':
            begin
              Result := toFloat;
              Inc(P);
              case P^ of
                '+', '-':
                  begin
                    Inc(P);
                    while P^ in ['0'..'9'] do Inc(P);
                  end;
                '0'..'9':
                  begin
                    Inc(P);
                    while P^ in ['0'..'9'] do Inc(P);
                  end;
              end;
            end;
          '.':
            begin
              Result := toFloat;
              Inc(P);
              if not (P^ in ['0'..'9', 'e', 'E']) then
                Dec(P)
              else
              case P^ of
                '0'..'9':
                  begin
                    Inc(P);
                    while P^ in ['0'..'9'] do Inc(P);
                    if P^ in ['e', 'E'] then
                    begin
                      Inc(P);
                      case P^ of
                        '+', '-':
                          begin
                            Inc(P);
                            while P^ in ['0'..'9'] do Inc(P);
                          end;
                        '0'..'9':
                          begin
                            Inc(P);
                            while P^ in ['0'..'9'] do Inc(P);
                          end;
                      end;
                    end;
                  end;
                'e', 'E':
                  begin
                    Inc(P);
                    case P^ of
                      '+', '-':
                        begin
                          Inc(P);
                          while P^ in ['0'..'9'] do Inc(P);
                        end;
                      '0'..'9':
                        begin
                          Inc(P);
                          while P^ in ['0'..'9'] do Inc(P);
                        end;
                    end;
                  end;
              end;
            end;
        end;
      end;
    'A'..'Z', '_', 'a'..'z':
      begin
        Inc(P);
        while P^ in [ '0'..'9', 'A'..'Z', '_', 'a'..'z'] do Inc(P);
        Result := toAnk;
      end;
    #$81:
      begin
        Inc(P, 2);
        Result := toDBSymbol;
      end;
    #$82:
      begin
        Inc(P);
        case P^ of
          #$4F..#$58:
            begin
              Inc(P);
              SavePtr := P + 1;
              while True do
                if ((P^ in [#$81]) and (SavePtr^ in [#$43..#$44])) or
                   ((P^ in [#$82]) and (SavePtr^ in [#$4F..#$58])) then
                begin
                  Inc(P, 2);
                  Inc(SavePtr, 2);
                end
                else
                  Break;
              Result := toDBInt;
            end;
          #$60..#$9A:
            begin
              Inc(P);
              SavePtr := P + 1;
              while True do
                if (P^ in [#$82]) and (SavePtr^ in [#$60..#$9A]) then
                begin
                  Inc(P, 2);
                  Inc(SavePtr, 2);
                end
                else
                  Break;
              Result := toDBAlph;
            end;
          #$9F..#$F1:
            begin
              Inc(P);
              SavePtr := P + 1;
              while True do
                if ((P^ in [#$82]) and (SavePtr^ in [#$9F..#$F1])) or
                   ((P^ in [#$81]) and (SavePtr^ in [#$5B, #$7C])) then
                begin
                  Inc(P, 2);
                  Inc(SavePtr, 2);
                end
                else
                  Break;
              Result := toDBHira;
            end;
        end;
      end;
    #$83:
      begin
        Inc(P);
        case P^ of
          #$40..#$96:
            begin
              Inc(P);
              SavePtr := P + 1;
              while True do
                if ((P^ in [#$83]) and (SavePtr^ in [#$40..#$96])) or
                   ((P^ in [#$81]) and (SavePtr^ in [#$5B, #$7C])) then
                begin
                  Inc(P, 2);
                  Inc(SavePtr, 2);
                end
                else
                  Break;
              Result := toDBKana;
            end;
          #$9F..#$F0:
            begin
              Inc(P);
              SavePtr := P + 1;
              while True do
                if (P^ in [#$83]) and (SavePtr^ in [#$9F..#$F0]) then
                begin
                  Inc(P, 2);
                  Inc(SavePtr, 2);
                end
                else
                  Break;
              Result := toDBSymbol;
            end;
        end;
      end;
    #$84..#$87:
      begin
        Inc(P, 2);
        while P^ in [#$84..#$87] do Inc(P, 2);
        Result := toDBSymbol;
      end;
    #$88..#$9F,#$E0..#$FC:
      begin
        Inc(P, 2);
        while P^ in [#$88..#$9F,#$E0..#$FC] do Inc(P, 2);
        Result := toDBKanji;
      end;
    #$A1..#$A5:
      begin
        Inc(P);
        Result := toKanaSymbol;
      end;
    #$A6..#$DF:
      begin
        Inc(P);
        while P^ in [#$A6..#$DF] do Inc(P);
        Result := toKana;
      end;
  else
    if P^ in [#0] then
      Result := toEof
    else
    begin
      Result := toSymbol;
      Inc(P);
    end;
  end;
  FSourcePtr := P;
  FToken := Result;
end;



procedure TScParser.Reset;
begin
   FSourcePtr := FBuffer;
   FTokenPtr := FBuffer;
  // FTokenDUPPtr :=FTokenPtr;

end;

function TScParser.getBeginToken: integer;
begin
  result := (FTokenPtr - FBuffer)+1;
end;

function TScParser.getEndToken: integer;
begin
  result := (FSourcePtr - FBuffer);
end;

{ TScriptParser }

constructor TScriptParser.Create(const S: String);
begin
  inherited create( s );
    FURL := false;
    FHexPrefix :='#';
    RightBracket.add('*/');
//    RightBracket.add('</SCRIPT');
//    RightBracket.add('</STYLE');
    LeftBracket.Add('/*');
//    LeftBracket.Add('<SCRIPT');
// LeftBracket.Add('<STYLE');
 FQuotation.Add('''');
 Fquotation.Add('"');
 FComment.Add('//');

  NextToken;

end;

destructor TScriptParser.Destroy;
begin
  inherited;

end;

{function TScriptParser.NextToken: Char;
begin

end;
}
{ TTagParser }


constructor TTagParser.Create(const S: String ; isContainer: boolean = false);
begin
  inherited create( s );
//FTokenDUPPtr :=FTokenPtr;
FisContainer := isContainer;
    ckQuot := false;
    FURL := false;
    FHexPrefix :='$';
//    RightBracket.add('-->');
    RightBracket.add('>');
    RightBracket.add('</XMP');
    RightBracket.add('</PRE');
    RightBracket.add('</SCRIPT');
    RightBracket.add('</STYLE');

 //   LeftBracket.Add('<!--');
    LeftBracket.Add('<!');
    LeftBracket.Add('<XMP');
    LeftBracket.Add('<PRE');
    LeftBracket.Add('<SCRIPT');
    LeftBracket.Add('<STYLE');
         FQuotation.Add('''');
         FQuotation.Add('"');
           NextToken;

end;

destructor TTagParser.Destroy;
begin
  inherited;

end;

function GetInnerHTML(doc , tag : string; container : boolean = false) : string;
 var
 parser : TSCParser;
begin
  parser := TTagParser.Create( doc , container );
   parser.Reset;
  result :=get_innerHTML( parser , tag);
  parser.Free;
end;

function GetOuterHTML(doc , tag : string; container : boolean = false) : string;
 var  parser : TSCParser;
begin
  parser := TTagParser.Create( doc , container );
  parser.Reset;
  result := get_outerHTML( parser ,tag);
  parser.Free;
end;

function Get_innerHTML(parser: TScParser;  tag: string): string;
var
 p : integer;
 adjTagPos : TAdjucentTagPos ;

begin
  result :='' ;
  if AdjacentTag( Parser , Tag  , adjTagPos) then
  begin

   if adjTagPos.beforeEnd > adjtagpos.afterBegin then
   begin
   p:= (adjTagPos.beforeEnd - adjtagpos.afterBegin)+1;
    setLength( result , p);
    StrLCopy(pchar( result ),( parser.FBuffer + adjtagpos.afterBegin-1 ),  p);
   end;

  end;
end;

function Get_outerHTML(parser: TScParser; tag: string): string;
var p:pchar;
begin
parser.LeftBracket.Add('<'+TAG);
parser.RightBracket.Add('</'+tag);
  parser.NextToken;


  result :='';
 while parser.Token <> toeof do
 begin
  if (parser.Token = toBracket) and
     (not boolean(strIComp( pchar(parser.BracketString) ,pchar('<'+Tag)))) then
  begin

  if parser.FTerminateBracket then
  begin
   while parser.FSourcePtr^<>'>' do
    inc(parser.FsourcePtr);

    inc(parser.FsourcePtr);
   end
   else
   begin
   p := parser.FTokenPtr  ;
   while p^<>'>' do
    inc(p);

    inc(p);
    parser.FSourcePtr := P;
   end;

   result := parser.TokenString;
   break;
  end;
  parser.NextToken;
 end;
parser.LeftBracket.Delete(parser.LeftBracket.Count-1);
parser.RightBracket.Delete(parser.LeftBracket.Count-1);

end;

function AdjacentTag(parser: TScParser; Tag : string ;  var adjTagPos : TAdjucentTagPos) : boolean ;
var s: string;
    p : pchar;
begin
 result :=false;
 s:=Get_outerHTML(Parser , Tag);


 if s<>'' then
 begin
  result := true;

   adjtagPos.afterEnd :=0;
  adjtagPos.beforeBegin:= (parser.FTokenPtr - parser.FBuffer)+1;
  if parser.FTerminateBracket then
    adjtagPos.afterEnd :=  (parser.FSourcePtr - parser.FBuffer);

  p := parser.FTokenPtr;
  while   not((p^='>') or (p^=#00))   do
  inc(P);

  adjtagPos.afterBegin := (p - parser.fbuffer) +2;

  adjTagPos.beforeEnd := 0 ;
  if parser.FTerminateBracket  then
  begin
    p := parser.FSourcePtr;

    while  not(((p-1)^='<') or (p=parser.Fbuffer)) do
      dec(p);
    adjTagPos.beforeEnd :=(p - parser.Fbuffer)-1;
  end;
 end;
end;

function TTagParser.NextToken: Char;
var
  I, L, J: Integer;
  P, SavePtr: PChar;
  S: String;

  procedure InBracket;
  var
    skip : integer;
    L ,LLL, I: Integer;
    S, LL,qs: String;
    SavePtr: PChar;
  begin
    skip :=0;
    S := RightBracket[FBracketIndex];
    L := Length(S);

    LL := LeftBracket[FBracketIndex];
    LLL := length( ll );
    while not (P^ in [#0 ]) and (L > 0) do
    begin

        // Quotation
      if fckquot then
      begin
       i:=0;
//quotqtion中の文字は無視
       while i < Fquotation.count do
       begin
         qS := FQuotation[ i ] ;
         inc(i);
         if (Length(qS) > 0) and (P^ = qS[1]) then
         begin
                Inc(P);
           while True do
           begin
            if P^ in [#0 ] then
             Break
            else
            if P^ = qS[1] then
            begin
             Inc(P);
             if P^ <> qS[1] then
              Break;
            end;
          Inc(P);
         end;
       end;
      end;
    end;




      if self.fisContainer then
      begin

       if upCase(P^) = upCase(LL[1]) then
       begin

          SavePtr := P;
        I := 1;
        while I <= LLL do
          if upCase(P^) = UPCase(LL[I]) then
            if I = LLL then
            begin
            //タグのネスト

              TagOverlapping :=true;
              inc(skip);
              Inc(P);
              break;
             end
            else
            begin
              Inc(P);
              Inc(I);
            end    //if i = L
          else
          begin
            P := SavePtr;
            Break;
          end;  //if upCase(P^) = UPCase(LL[I])
      end;
    end;
      //

      if (p^='<')and((ll='<' ) or ( ll='</') ) then
      begin
//              dec( p);
               Result := toBracket;
               BracketString :=LeftBracket[FBracketIndex];
               FTerminateBracket := false;
               FBracketIndex := -1;
               Exit;

            end  ;


      if upCase(P^) = upCase(S[1]) then
      begin
        //if skip < 1 then
        SavePtr := P;
        I := 1;
        while I <= L do
          if upCase(P^) = UPCase(S[I]) then
            if I = L then
            begin
              dec( skip );
              SavePtr := p;
               Inc(P);
              inc(i);
              if skip < 0  then
              begin
           //    Inc(P);
               Result := toBracket;
               BracketString :=LeftBracket[FBracketIndex];
               FTerminateBracket := true;
               FBracketIndex := -1;
               Exit;
              end


            end
            else
            begin
              Inc(P);
              Inc(I);
            end
          else
          begin
            P := SavePtr;
            Break;
          end;
      end;
      if P^ in [#$81..#$9F, #$E0..#$FC] then
        Inc(P);
      Inc(P);
    end;
    FTerminateBracket :=false;
    BracketString :=LeftBracket[FBracketIndex];
    p := FSourcePtr+1;
//    dec(p);
    Result := toComment;
  end;


begin
  TagOverlapping :=false;
  SkipBlanks;
  P := FSourcePtr;

 while true do
 begin

  // check eof
  if P^ in [#0] then
  begin
    Result := toEof;
    FSourcePtr := P;
    FToken := Result;
    Exit;
  end; //if P^

  if p^ = char('>') then // in [#29..#30] then
  begin
   result := toSymbol;
    inc( p);
    FSourcePtr := P;
    FToken := Result;
    exit;
  end; //if P^




    FTokenPtr := P;


     if isCKBracket  then
     begin
       FBracketIndex := -1   ;

        SavePtr := P;
        for I := 0 to RightBracket.Count - 1 do
        begin
          S := LeftBracket[ i ];
          L := Length(S);
          J := 1;
          while J <= L do
            if upcase(P^) = upcase(S[J]) then
              if (J = L)  then
              begin
              if  j>2 then
                 if not( ((p+1)^=' ') or ((p+1)^='>'))   then break;

                Inc(P);
                FBracketIndex := I;
                FDrawBracketIndex := FBracketIndex;
                InBracket;
                FSourcePtr := P;
                FToken := Result;
                Exit;
              end  //if J = L
              else
              begin
                Inc(P);
                Inc(J);
              end   //if J = L
            else
            begin
              P := SavePtr;
              Break;
            end;//    if uppercase(P^) = uppercase(S[J])
        end; //while J <= L
      end;  //for I := 0 to RightBracket.Count - 1
 inc( p);

    end;  //if isCKBracket

  end; //while true

function RemoveCRLFs(const OldStr : string) : string;

// Replace all CRLF pairs in string with ' '

var
  Index : integer;

begin
  Result := OldStr;

  for Index := Length(Result) - 1 downto 1 do
    If Result[Index] = #13 then
      If Copy(Result,Index + 1,1) = #10 then
        begin
          Delete(Result,Index,1);
          Result[Index] := ' ';
        end;

end;




end.
