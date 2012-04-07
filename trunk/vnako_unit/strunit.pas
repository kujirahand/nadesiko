unit StrUnit;
(*------------------------------------------------------------------------------
汎用文字列処理を定義したユニット

全ての関数は、マルチバイト文字(S-JIS)に対応している

作成者：クジラ飛行机(http://kujirahand.com)
作成日：2001/11/24

履歴：
2002/04/09 途中に#0を含む文字列でも検索置換できるように修正
2004/11/12 ナデシコ用に改良

------------------------------------------------------------------------------*)
interface
uses
  Windows, Classes, SysUtils, DateUtils, hima_types, imm
  {$IFDEF VER140},Variants{$ENDIF}{$IFDEF VER150},Variants{$ENDIF};

type
  TCharSet = set of Char;

{------------------------------------------------------------------------------}
{文字種類の変換}

{ LCMapString を簡単に使うための関数 変換後の文字列は、str * 2 以内}
function LCMapStringEx(const str: string; MapFlag: DWORD): string;
{ LCMapString を簡単に使うための関数 変換後の文字列は、str 以内}
function LCMapStringExHalf(const str: string; MapFlag: DWORD): string;
{全角変換}
function convToFull(const str: string): string;
{半角変換}
function convToHalf(const str: string): string;
{数字とアルファベットと記号のみ半角に変換する/但し遅い}
function convToHalfAnk(const str: string): string;
{ひらがな・カタカナの変換}
function convToHiragana(const str: string): string;
function convToKatakana(const str: string): string;
{マルチバイトを考慮した大文字、小文字化}
function LowerCaseEx(const str: string): string;
function UpperCaseEx(const str: string): string;
{ローマ字表記を半角カナに変換}
function RomajiToKana(romaji: String): String;
function KanaToRomaji(kana: string): string;
{ｱ 愛知県 のような行頭の半角カナを削除して返す}
function TrimLeftKana(str: string): string;
// 漢字をふりがなに変換
function ConvToHurigana(const str: string; hwnd: HWND): string;

{------------------------------------------------------------------------------}
{文字種類の判別}
function IsHiragana(const str: string): Boolean;
function IsKatakana(const str: string): Boolean;
function Asc(const str: string): Integer; //文字コードを得る
function IsNumStr(const str: string): Boolean; //文字列が全て数値かどうか判断

{------------------------------------------------------------------------------}
{HTML処理}

{HTML から タグを取り除く}
function DeleteTag(const html: string): String;
{HTMLの指定タグで囲われた部分を抜き出す}
function GetTag(var html:string; tag: string): string;
function GetTags(html:string; tag: string): string;
function GetAbsolutePath(soutai, base: string; Delimiter: Char): string;
function GetTagAttribute(html:string; tag:string; attribute: string; FlagGetAll: Boolean = False): string;

{------------------------------------------------------------------------------}
{トークン処理}

{トークン切り出し／区切り文字分を進める}
function GetTokenChars(delimiter: TCharSet; var ptr:PChar): string;
function GetTokenPtr(delimiter: Char; var ptr:PChar): string;
function SplitChar(delimiter: Char; str: string): TStringList;
{ネストする（）の内容を抜き出す}
function GetKakko(var pp: PChar): string;


{------------------------------------------------------------------------------}
{その他}

{3桁区切りでカンマを挿入する}
function InsertYenComma(const yen: string): string;
{文字を出来る限り数値に変換する}
function StrToValue(const str: string): Extended;
{ワイルドカードマッチ}
//function WildMatch(Filename,Mask:string):Boolean;
{行揃えする}
function CutLine(line: string; cnt,tabCnt: Integer; kinsoku: string='dafault'): string;

{------------------------------------------------------------------------------}
function JReplace(const Str, oldStr, newStr:string; repAll:Boolean): string;
function JLength(const str: string): Integer;
function JPosM(const sub, str: string): Integer;

function GetToken(const delimiter: String; var str: string): String;
{------------------------------------------------------------------------------}
implementation

function JPosEx(const sub, str:string; idx:Integer): Integer;
var
  len_sub, len_str: Integer;
  p, pSub, pStart: PChar;
begin
  Result  := 0;
  if (sub = '')or(str = '') then Exit;

  len_sub := Length(sub);
  len_str := Length(str);
  if idx > len_str then Exit; // 文字列の長さよりインデックスが後ろにある場合は抜ける

  // １文字ずつ一致を探すためにポインタを取得
  p := PChar(str);
  pStart := p;
  pSub := PChar(sub);

  // idx 分 ポインタを進める
  Dec(idx);
  while idx > 0 do
  begin
    if p^ in LeadBytes then
    begin
      Inc(p, 2); Dec(idx, 2);
    end else
    begin
      Inc(p); Dec(idx);
    end;
  end;

  // 繰り返し検索
  try
    while p^ <> #0 do
    begin
      if StrLComp(p, pSub, len_sub) = 0 then
      begin
        Result := (p - pStart) + 1;
        Break;
      end;
      if p^ in LeadBytes then Inc(p, 2) else Inc(p);
    end;
  except
    raise Exception.Create('文字列の検索中にエラー。'); 
  end;
end;

function JReplace(const Str, oldStr, newStr:string; repAll:Boolean): string;
var
    i, idx:Integer;
begin
    Result := Str;
    // ****
    i := JPosEx(oldStr, Str, 1);
    if i=0 then Exit;
    Delete(result, i, Length(oldStr));
    Insert(newStr, result, i);
    idx := i + Length(newStr);
    if repAll = False then Exit;
    // *** Loop
    while True do
    begin
        i := JPosEx(oldStr, result, idx);
        if i=0 then Exit;
        Delete(result, i, Length(oldStr));
        Insert(newStr, result, i);
        idx := i + Length(newStr);
    end;
end;

//指定個目のoldStrを、newStrに置換する
function JReplaceCnt(const Str, oldStr, newStr:string; Index: Integer): string;
var
  i, idx:Integer;
  p, pp: PChar;
begin
  idx := 0;
  p := PChar(str);
  pp := p;
  while p^ <> #0 do
  begin
    if StrLComp(p, PChar(oldStr), Length(oldStr)) = 0 then
    begin
      Inc(idx);
      if idx = Index then
      begin
        i := (p - pp);
        Result := Copy(Str, 1, i); // 前半部分
        Result := Result + newStr; // 置換部分
        Result := Result + Copy(Str, 1 + i + Length(oldStr), Length(Str));
        Exit;
      end;
      Inc(p, Length(oldStr));
    end else
    begin
      if p^ in LeadBytes then
        Inc(p,2)
      else
        Inc(p);
    end;
  end;
  Result := Str;
end;

function JReplaceEx(const Str, oldStr, newStr:string; repAll:Boolean; useCase:Boolean): string;
var
    i, idx:Integer;
    oldStrFind: string;
    strFind: string;
begin
    Result := Str;
    oldStrFind := UpperCaseEx(oldStr);
    strFind := UpperCaseEx(Result);
    // ****
    i := JPosEx(oldStrFind, strFind, 1);
    if i=0 then Exit;
    Delete(result, i, Length(oldStr));
    Insert(newStr, result, i);
    idx := i + Length(newStr);
    if repAll = False then Exit;
    // *** Loop
    while True do
    begin
        oldStrFind := UpperCaseEx(oldStr);
        strFind := UpperCaseEx(Result);
        i := JPosEx(oldStrFind, strFind, idx);
        if i=0 then Exit;
        Delete(result, i, Length(oldStr));
        Insert(newStr, result, i);
        idx := i + Length(newStr);
    end;
end;


function GetToken(const delimiter: String; var str: string): String;
var
    i: Integer;
begin
    i := JPosEx(delimiter, str,1);
    if i=0 then
    begin
        Result := str;
        str := '';
        Exit;
    end;
    Result := Copy(str, 1, i-1);
    Delete(str,1,i + Length(delimiter) -1);
end;

{行揃えする}
function CutLine(line: string; cnt,tabCnt: Integer; kinsoku: string): string;
const
  GYOUTOU_KINSI = '、。，．・？！゛゜ヽヾゝゞ々ー）］｝」』!),.:;?]}｡｣､･ｰﾞﾟ';
var
    p, pr,pr_s: PChar;
    i,len: Integer;

    procedure CopyOne;
    begin
        pr^ := p^; Inc(pr); Inc(p);
    end;

    procedure InsCrLf;
    var next_c: string;
    begin
        //禁則処理(行頭禁則文字)
        if kinsoku <> '' then
        begin
            if p <> nil then
            if p^ in LeadBytes then
            begin
                next_c := p^ + (p+1)^;
            end else
            begin
                next_c := p^;
            end;

            if JPosM(next_c, kinsoku) > 0 then
            begin
                if p^ in LeadBytes then
                begin
                    if p <> nil then CopyOne;
                    if p <> nil then CopyOne;
                end else
                begin
                    if p <> nil then CopyOne;
                end;
            end;
        end;

        // 追加
        pr^ := #13; Inc(pr);
        pr^ := #10; Inc(pr);
        i := 0;
    end;

begin
    if cnt<=0 then
    begin
        Result := line;
        Exit;
    end;
    if line = '' then
    begin
        Result := line;
        Exit;
    end;
    if kinsoku = 'dafault' then kinsoku := GYOUTOU_KINSI;

    len := Length(line);
    SetLength(Result, len + (len div cnt) * 3);

    pr := PChar(Result); pr_s := pr;
    p  := PChar(line);
    i := 0;
    while p^ <> #0 do
    begin
        if p^ in LeadBytes then
        begin
            if (i+2) > cnt then InsCrLf;
            CopyOne;
            CopyOne;
            Inc(i,2);
        end else
        begin
            if i >= cnt then InsCrLf;
            if p^ in [#13,#10] then
            begin
                Inc(p);
                if p^ in[#13,#10] then Inc(p);
                InsCrLf;
            end else
            if p^ = #9 then
            begin
                CopyOne;
                Inc(i, tabCnt);
            end else
            begin
                CopyOne;
                Inc(i);
            end;
        end;
    end;

    pr^ := #0;
    Result := string( pr_s );
end;


{マルチバイト文字数を得る}
function JLength(const str: string): Integer;
var
    p: PChar;
begin
    p := PChar(str);
    Result := 0;
    while p^ <> #0 do
    begin
        if p^ in LeadBytes then
            Inc(p,2)
        else
            Inc(p);
        Inc(Result);
    end;
end;

{マルチバイト文字列を切り出す}
function JCopy(const str: string; Index, Count: Integer): string;
var
    i, iTo: Integer;
    p: PChar;
    ch: string;
begin
    i   := 1;
    iTo := Index + Count -1;
    p := PChar(str);
    Result := '';
    while (p^ <> #0) do
    begin
        if p^ in LeadBytes then
        begin
            ch := p^ + (p+1)^;
            Inc(p,2);
        end else
        begin
            ch :=p^;
            Inc(p);
        end;
        if (Index <= i) and (i <= iTo) then
        begin
            Result := Result + ch;
        end;
        Inc(i);
        if iTo < i then Break;
    end;
end;

{マルチバイト文字列を検索する}
function JPosM(const sub, str: string): Integer;
var
    i, len: Integer;
    p: PChar;
begin
    i := 1;
    Result := 0;
    p := PChar(str);
    len := Length(sub);
    while p^ <> #0 do
    begin
        if StrLComp(p, PChar(sub), len) = 0 then
        begin
            Result := i; Break;
        end;
        if p^ in LeadBytes then
        begin
            Inc(p,2);
        end else
        begin
            Inc(p);
        end;
        Inc(i);
    end;
end;

function Asc(const str: string): Integer; //文字コードを得る
begin
    if str='' then begin
        Result := 0;
        Exit;
    end;

    if str[1] in LeadBytes then
    begin
        Result := (Ord(str[1]) shl 8) + Ord(str[2]);
    end else
        Result := Ord(str[1]);
end;


procedure skipSpace(var p: PChar);
begin
    while p^ in [' ',#9] do Inc(p);
end;

{ネストする（）の内容を抜き出す}
function GetKakko(var pp: PChar): string;
const
    CH_STR1 = '"';
    CH_STR2 = '''';
var
    nest, len: Integer;
    tmp, buf: PChar;
    IsStr, IsStr2: Boolean;
begin
    Result := '';
    skipSpace(pp);
    nest := 0;
    IsStr := False;
    IsStr2 := False;
    if pp^ = '(' then
    begin
        Inc(nest);
        Inc(pp);
    end;
    tmp := pp;
    while pp^ <> #0 do
    begin
        if pp^ in LeadBytes then
        begin
            Inc(pp,2); continue;
        end else
        case pp^ of
            CH_STR1:
            begin
                if IsStr2 = False then
                    IsStr := not IsStr;
                Inc(pp);
            end;
            CH_STR2:
            begin
                if IsStr = False then
                    IsStr2 := not IsStr2;
                Inc(pp);
            end;
            '\':
            begin
                Inc(pp);
                if IsStr then if pp^ in LeadBytes then Inc(pp,2) else Inc(pp);
            end;
            '(':
            begin
                Inc(pp);
                if (IsStr=False)and(IsStr2=False) then
                begin
                    Inc(nest); continue;
                end;
            end;
            ')':
            begin
                Inc(pp);
                if (IsStr=False)and(IsStr2=False) then
                begin
                    Dec(nest);
                    if nest = 0 then Break;
                    continue;
                end;
            end;
            else
                Inc(pp);
        end;
    end;
    len := pp - tmp -1;
    if len<=0 then
    begin
        if nest <> 0 then
        begin
            pp := tmp;
            raise Exception.Create('")"が対応していません。');
        end;
        Exit;
    end;
    if nest > 0 then raise Exception.Create('")"が対応していません。');
    GetMem(buf, len + 1);
    try
        StrLCopy(buf, tmp, len);
        (buf+len)^ := #0;
        Result := string( PChar(buf) );
    finally
        FreeMem(buf);
    end;
end;

{ワイルドカードマッチ}
{
function WildMatch(Filename,Mask:string):Boolean;
begin
    Result := MatchesMask(Filename, Mask);
end;
}

{文字列を数値に変換する}
function StrToValue(const str: string): Extended;
var
    st,p,mem: PChar;
    len, sig: Integer;
    buf: string;

    function convToHalfMini(sSrc: string): string;
    var
      cSrc : array [0..255] of char;
      cDst : array [0..255] of char;
    begin
      StrLCopy( cSrc, PChar(sSrc), 254  );
      FillChar( cDst, sizeof(cDst), 0);
      LCMapString( LOCALE_SYSTEM_DEFAULT, LCMAP_HALFWIDTH, cSrc, strlen(cSrc),cDst, sizeof(cDst) );
      Result := cDst;
    end;

begin

    // はじめに、数字を半角にする
    if Trim(str)='' then begin Result := 0; Exit; end;

    buf := Trim(JReplace(ConvToHalfMini(str),',','',True));//カンマを削除

    p := PChar(buf);
    while p^ in [' ',#9] do Inc(p);
    if p^='$' then
    begin
        Result := StrToIntDef(buf,0);
        Exit;
    end;

    sig := 1;

    if p^ = '+' then Inc(p) else
    if p^ ='-' then
    begin
        Inc(p);
        sig := -1;
    end;

    st := p;
    // 整数
    while p^ in ['0'..'9'] do Inc(p);
    // 小数点
    if p^ = '.' then Inc(p);
    while p^ in ['0'..'9'] do Inc(p);
    // 指数形式
    if (p^ in ['e','E']) and ((p+1)^ in ['+','-']) and ((p+2)^ in ['0'..'9']) then
    begin
      Inc(p,3);
      while p^ in ['0'..'9'] do Inc(p);
    end;

    len := p - st;
    if len=0 then begin Result:=0; Exit; end;

    GetMem(mem, len+1);
    try
        StrLCopy(mem, st, len);
        (mem+len)^ := #0;
        Result := sig * StrToFloat(string(mem));
    finally
        FreeMem(mem);
    end;
end;


{HTML から タグを取り除く}
function DeleteTag(const html: string): String;
var
  i, j: Integer;
  txt: String;
  TagIn: Boolean;
const
  CDATA_IN  = '<![CDATA[';
  CDATA_OUT = ']]>';
begin
    txt := Trim(html);
    if txt = '' then Exit;

    i := 1;
    Result := '';

    TagIn := False;
    while i <= Length(txt) do
    begin

        if txt[i] in SysUtils.LeadBytes then
        begin
            if TagIn=False then
            begin
                Result := Result + Copy(txt,i,2);
            end;
            Inc(i,2);
            Continue;
        end;

        // Check "<![CDATA[ .. ]]>"
        if Copy(txt, i, Length(CDATA_IN)) = CDATA_IN then
        begin
          Inc(i, Length(CDATA_IN));
          j := JPosEx(CDATA_OUT, txt, i);
          if j = 0 then // MAYBE BROKEN?
          begin
            Result := Result + CDATA_IN + txt;
            Break;
          end;
          Result := Result + Copy(txt, i, (j-i));
          i := j;
          Inc(i, Length(CDATA_OUT));
          Continue;
        end;
        

        case txt[i] of
            '<': //TAG in
            begin
                TagIn := True;
                Inc(i);
            end;
            '>': //TAG out
            begin
                TagIn := False;
                Inc(i);
            end;
            else
            begin
                if TagIn then
                begin // to skip
                    Inc(i);
                end else
                begin
                    Result := Result + txt[i];
                    Inc(i);
                end;
            end;
        end;

    end;
end;

{HTMLの指定タグで囲われた部分を抜き出す}
function GetTag(var html:string; tag: string): string;
var
  p, pp, pFrom, pEnd: PChar;
  nest, len: Integer;
  s: string;

  function getTagName(var p: PChar): string;
  begin
    Result := '';
    //先頭の/を考慮
    if p^ = '/' then
    begin
      Result := Result + p^; Inc(p);
    end;
    while p^ <> #0 do
    begin
      if p^ in LeadBytes then
      begin
        Result := Result + p^ + (p+1)^;
        Inc(p,2);
      end else
      begin
        if p^ in ['A'..'Z','a'..'z','0'..'9','_',':','-','.'] then
        begin
          Result := Result + p^; Inc(p);
        end else
          Break;
      end;
    end;
  end;

  procedure skipToChar(ch: Char; var p: PChar);
  begin
    while p^ <> #0 do
    begin
      if p^ = ch then
      begin
        Inc(p);
        break;
      end;
      if p^ in LeadBytes then Inc(p,2) else Inc(p);
    end;
  end;

  procedure skipTagEnd(var p: PChar);
  begin
    while p^ <> #0 do
    begin
      if p^ = '>' then
      begin
        Inc(p);
        Break;
      end else
      if p^ = '"' then
      begin
        Inc(p); skipToChar('"', p);
      end else
      if p^ = '''' then
      begin
        Inc(p); skipToChar('''', p);
      end else
      if p^ in LeadBytes then Inc(p,2) else Inc(p);
    end;
  end;

  function skipSection(var p: PChar):Boolean;
  begin
    // <!-- --> <![CDATA[]]> などの<!で始まるものを読み飛ばす
    Result := False;
    if (p+1)^ <> '!' then Exit;

    Inc(p,2); // skip <!
    if AnsiStrLComp(p,'--', 2) = 0 then
    begin
      while p^ <> #0 do
      begin
        if p^ in LeadBytes then
        begin
          Inc(p,2); Continue;
        end;
        if AnsiStrLComp(p,'-->', 3) = 0 then begin Inc(p,3); Break; end;
        Inc(p);
      end;
      Result := True;
    end
    else if AnsiStrLComp(p,'[CDATA[', 7) = 0 then
    begin
      while p^ <> #0 do
      begin
        if p^ in LeadBytes then
        begin
          Inc(p,2); Continue;
        end;
        if AnsiStrLComp(p,']]>', 3) = 0 then begin Inc(p,3); Break; end;
        Inc(p);
      end;
      Result := True;
    end;
  end;

  function isBlankTag(p:Pchar):boolean;
  begin
    Result:=False;
    Dec(p);
    if p^ <> '>' then
    begin
      Exit;
    end;
    Dec(p);
    while p^ = ' ' do Dec(p);
    Result := p^ = '/' ;
  end;

begin
  // タグを大文字に切りそろえる。タグ記号は削除する
  tag := UpperCase(tag);
  tag := JReplace(tag, '<','', True);
  tag := JReplace(tag, '>','', True);

  // タグの始まりを探す
  p := PChar(html);
  nest := 0;
  pFrom := nil;
  while p^ <> #0 do
  begin
    if p^ in LeadBytes then
    begin
      Inc(p,2); Continue;
    end;
    if p^ <> '<' then begin Inc(p); Continue; end;
    if skipSection(p) then
    begin
      Continue;
    end;
    pp := p;
    Inc(pp);
    s := getTagName(pp);
    skipTagEnd(pp);
    if UpperCase(s) = tag then
    begin
      if isBlankTag(pp) then
      begin
        // 切り取り結果
        len := (pp - p);
        SetLength(Result, len);
        StrLCopy(PChar(Result), p, len);

        // html の残りをセット
        html := string( PChar( pp ) );
        Exit;
      end;
      pFrom := p; // タグの < の前
      nest := 1;
      Break;
    end;
    p := pp;
  end;
  if nest=0 then
  begin
    Result := '';
    html := '';
    Exit;
  end;

  // タグの終わりを探す
  p := pp;
  pEnd := nil;
  while p^ <> #0 do
  begin
    if p^ in LeadBytes then
    begin
      Inc(p,2); Continue;
    end;
    if p^ <> '<' then begin Inc(p); Continue; end;
    if skipSection(p) then Continue;

    Inc(p);
    s := getTagName(p);
    skipTagEnd(p);

    // タグのネストを検出
    if UpperCase(s) = tag then
    begin
      if not isBlankTag(p) then Inc(nest);
      Continue;
    end;

    // タグの終端を検出
    if (UpperCase(s) = '/'+tag) then
    begin
      Dec(nest);
      if nest <= 0 then
      begin
        pEnd := p;
        Break;
      end;
    end;
  end;
  if pEnd = nil then pEnd := p;

  // 切り取り結果
  len := (pEnd - pFrom);
  SetLength(Result, len);
  StrLCopy(PChar(Result), pFrom, len);

  // html の残りをセット
  html := string( PChar( pEnd ) );
end;

function GetTags(html:string; tag: string): string;
var
    s: string;
begin
    Result := '';
    while html <> '' do
    begin
        s := GetTag(html, tag);
        if s<>'' then
            Result := Result + s + #13#10;
    end;
end;

// tag の attribute を取得する tag が '' の時は tag の種類を問わない
function GetTagAttribute(html:string; tag:string; attribute: string; FlagGetAll: Boolean): string;
var
  p: PChar;

  function getTokenName(var p: PChar): string;
  begin
    Result := '';
    while p^ <> #0 do
    begin
      if p^ in LeadBytes then
      begin
        Result := Result + p^ + (p+1)^;
        Inc(p,2);
      end else
      begin
        if p^ in ['a'..'z','A'..'Z','_','0'..'9','-','!','.',':'] then
        begin
          Result := Result + p^;
          Inc(p);
        end else
          Break;
      end;
    end;
  end;
  function getStrValue(var p: PChar): string;
  begin
    Result := '';
    while p^ in [' ', #13, #10, #9] do Inc(p);
    if p^='"' then
    begin
      Inc(p);
      while p^ <> #0 do
      begin
        if (p^='"') then begin Inc(p); Break; end;
        if p^ in LeadBytes then
        begin
          Result := Result + p^ + (p+1)^; Inc(p,2);
        end else
        begin
          Result := Result + p^; Inc(p);
        end;
      end;
    end else
    if p^='''' then
    begin
      Inc(p);
      while p^ <> #0 do
      begin
        if (p^='''') then begin Inc(p); Break; end;
        if p^ in LeadBytes then
        begin
          Result := Result + p^ + (p+1)^; Inc(p,2);
        end else
        begin
          Result := Result + p^; Inc(p);
        end;
      end;
    end else
    begin
      while p^ <> #0 do
      begin
        if (p^=' ') then begin Inc(p); Break; end;
        if (p^='>') then begin Break; end;
        if p^ in LeadBytes then
        begin
          Result := Result + p^ + (p+1)^; Inc(p,2);
        end else
        begin
          Result := Result + p^; Inc(p);
        end;
      end;
    end;

  end;

  procedure readTag;
  var
    name, attname, attvalue:string;
    att: TStringList;
  begin
    // タグ <name att="value" att="value" ... >
    //      <!-- xxx "xxx" -->
    //      <!DOCTYPE ... >
    //------------
    // 名前を取得
    name := UpperCase(getTokenName(p));

    // 属性を取得
    att  := TStringList.Create ;
    while p^ <> #0 do
    begin
      // 終了判定
      while p^ in [' ',#9, #13, #10] do Inc(p);
      if p^ = '>' then begin Inc(p); Break; end;

      // 属性取得
      attname := UpperCase(getTokenName(p));
      while p^ in [' ',#9, #13, #10] do Inc(p);
      if (p^ = '=') then
      begin
        Inc(p);
        attvalue := getStrValue(p);
        if attname <> '' then att.Add(attname + '=' + attvalue);
      end else
      begin
        // 属性ではない場合(コメントなど)
        attvalue := getStrValue(p);
      end;
    end;

    // 結果に加えるか判定
    if FlagGetAll then
    begin
      if (tag='')or(tag=name) then
        Result := Result + Trim(att.Text) + #13#10;
    end else
    if (tag='')or(tag=name) then
    begin
      if att.IndexOfName(attribute) >= 0 then
        Result := Result + att.Values[attribute] + #13#10;
    end;
  end;

begin
  Result := '';
  tag := UpperCase(tag);
  attribute := UpperCase(attribute);
  p := PChar(html);
  while p^ <> #0 do
  begin
    if p^ in LeadBytes then
    begin
      Inc(p,2);
    end else
    begin
      if p^ = '<' then
      begin
        Inc(p);

        // <!-- --> <![CDATA[]]> などの<!で始まるものを読み飛ばす
        if (p)^ = '!' then
        begin
          Inc(p);
          if AnsiStrComp(p,'--') = 0 then
          begin
            while p^ <> #0 do
            begin
              if p^ in LeadBytes then
              begin
                Inc(p,2); Continue;
              end;
              if AnsiStrComp(p,'-->') = 0 then begin Inc(p,3); Break; end;
              Inc(p);
            end;
          end
          else if AnsiStrComp(p,'[CDATA[') = 0 then
          begin
            while p^ <> #0 do
            begin
              if p^ in LeadBytes then
              begin
                Inc(p,2); Continue;
              end;
              if AnsiStrComp(p,']]>') = 0 then begin Inc(p,3); Break; end;
              Inc(p);
            end;
          end;
          Continue;
        end;

        readTag;
      end else
      begin
        Inc(p);
      end;
    end;
  end;
end;

function GetAbsolutePath(soutai, base: string; Delimiter: Char): string;
var
  slSoutai, slBase: TStringList;
  rel, s: string;
  i: Integer;
begin
  // 不要の場合
  if Delimiter = '/' then
  begin
    i := Pos('/', soutai);
    if Copy(soutai,i,2) = '//' then
    begin
      Result := soutai; Exit;
    end;
  end else
  begin
    if Copy(soutai, 2,2) = ':\' then
    begin
      Result := soutai; Exit;
    end;
  end;

  slSoutai := SplitChar(Delimiter, soutai);
  slBase   := SplitChar(Delimiter, base);

  while (slSoutai.Count >= 1) or (slBase.Count >= 1) do
  begin
    rel := slSoutai.Strings[0];
    if rel = '.' then
    begin
      slSoutai.Delete(0);Continue;
    end else
    if rel = '..' then
    begin
      slSoutai.Delete(0);
      slBase.Delete(slBase.Count-1);
    end else
    begin
      Break;
    end;
  end;

  Result := '';
  for i := 0 to slBase.Count - 1 do
  begin
    s := slBase.Strings[i];
    Result := Result + s + Delimiter ;
  end;
  for i := 0 to slSoutai.Count - 1 do
  begin
    s := slSoutai.Strings[i];
    Result := Result + s + Delimiter;
  end;
  if Copy(Result, Length(Result), 1) = Delimiter then
  begin
    System.Delete(Result, Length(Result), 1);
  end;
end;

function InsertYenComma(const yen: string): string;
begin
    if Pos('.',yen)=0 then
    begin
        Result := FormatCurr('#,##0', StrToValue(yen));
    end else
    begin
        Result := FormatCurr('#,##0.00', StrToValue(yen));
    end;
end;

function KanaToRomaji(kana: string): string;
const
  hira: string     = 'あいうえおかきくけこがぎぐげごさしすせそざじずぜぞ'+
                      'たっちつてとだぢづでど'+
                      'なにぬねのはひふへほばびぶべぼぱぴぷぺぽ'+
                      'まみむめもやゆよらりるれろわをんーヴ';
  roma: string     = 'a,i,u,e,o,ka,ki,ku,ke,ko,ga,gi,gu,ge,go,sa,si,su,se,so,za,zi,zu,ze,zo,' +
                      'ta,ltu,ti,tu,te,to,da,di,du,de,do,'+
                      'na,ni,nu,ne,no,ha,hi,hu,he,ho,ba,bi,bu,be,bo,pa,pi,pu,pe,po,'+
                      'ma,mi,mu,me,mo,ya,yu,yo,ra,ri,ru,re,ro,wa,wo,n,-,vo';
var
  i: Integer;
  c, nc: string;
  romaList: TStringList;

  function getOne: string;
  begin
    Result := '';
    if i > Length(kana) then Exit;
    if kana[i] in SysUtils.LeadBytes then
    begin
      Result := Result + kana[i];
      Inc(i);
      if i <= Length(kana) then
      begin
        Result := Result + kana[i];
        Inc(i);
      end;
    end else
    begin
      Result := Result + kana[i];
      Inc(i);
    end;
  end;

  function kana2roma(c: string): string;
  var
    j: Integer;
  begin
    Result := '';
    j := JPosM(c, hira);
    if j > 0 then
    begin
      Result := romaList.Strings[j-1];
    end;
  end;

begin
  kana := convToHiragana(kana);
  romaList:= TStringList.Create;
  romaList.Text := JReplace(roma, ',',#13#10,True);
  i := 1;
  while (i <= Length(kana)) do
  begin
    c := getOne;
    if Result <> '' then
    begin
      if c = 'ゃ' then
      begin
        // きゃ : ki => kya
        Delete(Result, Length(Result), 1);
        Result := Result + 'ya';
      end else
      if c = 'ゅ' then
      begin
        Delete(Result, Length(Result), 1);
        Result := Result + 'yu';
      end else
      if c = 'ょ' then
      begin
        Delete(Result, Length(Result), 1);
        Result := Result + 'yo';
      end else
      if c = 'っ' then
      begin
        // かった : ka ta => ka-tta
        nc := kana2roma(getOne);
        Result := Result + Copy(nc,1,1) + nc;
      end else
      begin
        Result := Result + kana2roma(c);
      end;
    end else
    begin
      Result := Result + kana2roma(c);
    end;
  end;
  romaList.Free;
  // 整形
  Result := JReplace(Result, 'zyo', 'jo', True);
end;

function RomajiToKana(romaji: String): String;
const
    kana_list = 'k,ｶｷｸｹｺ,s,ｻｼｽｾｿ,t,ﾀﾁﾂﾃﾄ,n,ﾅﾆﾇﾈﾉ,h,ﾊﾋﾌﾍﾎ,m,ﾏﾐﾑﾒﾓ,y,2ﾔ ｲ ﾕ ｲｪﾖ ,r,ﾗﾘﾙﾚﾛ,w,2ﾜ ｳｨｳ ｳｪｦ ,'+
    'g,2ｶﾞｷﾞｸﾞｹﾞｺﾞ,z,2ｻﾞｼﾞｽﾞｾﾞｿﾞ,d,2ﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞ,b,2ﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞ,p,2ﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟ,'+
    'q,2ｸｧｸｨｸ ｸｪｸｫ,f,2ﾌｧﾌｨﾌ ﾌｪﾌｫ,j,3ｼﾞｬｼﾞ ｼﾞｭｼﾞｪｼﾞｮ,l,ｧｨｩｪｫ,x,ｧｨｩｪｫ,c,ｶｼｸｾｺ,'+
    'v,3ｳﾞｧｳﾞｨｳﾞ ｳﾞｪｳﾞｫ,f,ﾊﾋﾌﾍﾎ,'+
    'ky,2ｷｬｷｨｷｭｷｪｷｮ,sy,2ｼｬｼｨｼｭｼｪｼｮ,ty,2ﾁｬﾁｨﾁｭﾁｪﾁｮ,ny,2ﾆｬﾆｨﾆｭﾆｪﾆｮ,hy,2ﾋｬﾋｨﾋｭﾋｪﾋｮ,'+
    'my,2ﾐｬﾐｨﾐｭﾐｪﾐｮ,by,3ﾋﾞｬﾋﾞｨﾋﾞｭﾋﾞｪﾋﾞｮ,cy,2ﾁｬﾁｨﾁｭﾁｪﾁｮ,ch,2ﾁｬﾁ ﾁｭﾁｪﾁｮ,sh,2ｼｬｼ ｼｭｼｪｼｮ';
var
    p: PChar;
    siin: string;
    siin_s, siin_k: array [0..50] of string;

    function GetBoinNo(c: Char): Integer;
    begin
        case c of
        'a': Result := 0;
        'i': Result := 1;
        'u': Result := 2;
        'e': Result := 3;
        'o': Result := 4;
        else Result := 0;
        end;
    end;

    function GetSiinCh(s: string; c: Char): string;
    var i,len: Integer;
    begin
        Result := '';
        if s='' then Exit;
        i := GetBoinNo(c);
        if s[1] in ['1'..'9'] then
        begin
            len := StrToIntDef(s[1],1);
            Delete(s,1,1);
            Result := Trim(Copy(s, i*2+1, len));
        end else
        begin
            Result := s[i+1];
        end;
    end;

    procedure DecideChar(c: Char);
    var i:Integer;
    begin
        if siin = '' then begin
            Result := Result + Copy('ｱｲｳｴｵ',GetBoinNo(c)+1,1);
        end else
        begin
            for i:=0 to High(siin_k) do
            begin
                if siin = siin_s[i] then
                begin
                    Result := Result + GetSiinCh( siin_k[i], c);
                    Break;
                end;
            end;
        end;

    end;

    procedure getKanaList;
    var i: Integer; s,ss: string;
    begin
        ss := kana_list; i:=0;
        while ss<>'' do
        begin
            s := GetToken(',', ss);
            siin_s[i] := s;
            s := GetToken(',', ss);
            siin_k[i] := s;
            Inc(i);
        end;
    end;

begin
    Result := '';
    romaji := LowerCase(convToHalf(romaji));
    if romaji='' then Exit;

    getKanaList;

    siin := '';
    p := PChar(romaji);
    while p^ <> #0 do
    begin
        if p^='-' then
        begin
            Result := Result + 'ｰ';
            Inc(p); siin := '';
            Continue;
        end else
        if p^ in ['a','i','u','e','o'] then
        begin //母音なので決定
            DecideChar(p^);
            Inc(p);
            siin := '';
            Continue;
        end else
        if p^ in ['a'..'z'] then
        begin
            if (siin='n')and(p^<>'y') then
            begin
                Result := Result + 'ﾝ';
                siin := p^;
                Inc(p);
                Continue;
            end;
            if Copy(siin,Length(siin),1)=p^ then
            begin
                Inc(p);
                Result := Result + 'ｯ';
                Continue;
            end;
            siin := siin + p^;
            Inc(p);
        end else
        begin //記号数字など
            Result := Result + p^;
            Inc(p);
        end;
    end;
end;

{ｱ 愛知県 のような行頭の半角カナを削除して返す}
function TrimLeftKana(str: string): string;
begin
    Result := '';
    if str='' then Exit;

    if (str[1] in ['ｱ'..'ﾝ'])and(Copy(str,2,1)=' ') then
    begin
        Delete(str,1,1);
    end;
    Result := Trim(str);
end;




{LCMapString-------------------------------------------------------------------}
function LCMapStringEx(const str: string; MapFlag: DWORD): string;
var
    pDes: PChar;
    len,len2: Integer;
begin
    if str='' then begin Result := ''; Exit; end;
    len  := Length(str);
    len2 := len*2+2;
    GetMem(pDes, len2);//half -> full
    FillChar( pDes^, len2, 0 );
    LCMapString( LOCALE_SYSTEM_DEFAULT, MapFlag, PChar(str), len, pDes, len2-1);
    Result := string( pDes );
end;
function LCMapStringExHalf(const str: string; MapFlag: DWORD): string;
var
    pDes: PChar;
    len,len2: Integer;
begin
    if str='' then begin Result := ''; Exit; end;
    len  := Length(str);
    len2 := len+2;
    GetMem(pDes, len2);
    FillChar( pDes^, len2, 0 );
    LCMapString( LOCALE_SYSTEM_DEFAULT, MapFlag, PChar(str), len, pDes, len2-1);
    Result := string( pDes );
end;
function convToFull(const str: string): string;
begin
    Result := LCMapStringEx( str, LCMAP_FULLWIDTH );
end;

function convToHalf(const str: string): string;
begin
    Result := LCMapStringEx( str, LCMAP_HALFWIDTH );
end;
{ひらがな・カタカナの変換}
function convToHiragana(const str: string): string;
begin
    Result := LCMapStringEx( str, LCMAP_HIRAGANA );
end;
function convToKatakana(const str: string): string;
begin
    Result := LCMapStringEx( str, LCMAP_KATAKANA );
end;
{マルチバイトを考慮した大文字、小文字化}
function LowerCaseEx(const str: string): string;
begin
    Result := LCMapStringExHalf( str, LCMAP_LOWERCASE );
end;
function UpperCaseEx(const str: string): string;
begin
    Result := LCMapStringExHalf( str, LCMAP_UPPERCASE );
end;

function ConvToHurigana(const str: string; hwnd: HWND): string;
var
  src       : string;
  wstr      : WideString;
  hIMC_     : HIMC;
  hKL_      : HKL;
  lngOffset : DWORD;
  osvi      : TOSVersionInfo;
  pclist    : PCANDIDATELIST;
  p         : PChar;
  pw        : PWideString;
  lngSize   : DWORD;
begin
  Result := '';
  if str = '' then Exit;

  if hwnd = 0 then // 0のときうまく動かない（よって、コンソール版だとNG）
  begin
    hwnd := GetForegroundWindow;
  end;

  // OS判別
  osvi.dwOSVersionInfoSize := SizeOf(osvi);
  GetVersionEx(osvi);

  hIMC_ := ImmGetContext(hwnd);
  hKL_  := GetKeyboardLayout(0);
  try
    if osvi.dwPlatformId = VER_PLATFORM_WIN32_NT then
    begin
      // Windows NT : SHIFT_JIS にて
      src := str;
      // 変換結果を受け取るバッファサイズを取得
      lngSize := ImmGetConversionListA(hKL_, hIMC_, @src[1], nil, 0, GCL_REVERSECONVERSION);
      if lngSize > 0 then
      begin
        // バッファ分の配列を取得
        pclist := GetMemory(lngSize);
        try
          // 変換結果を取得
          ImmGetConversionListA(hKL_, hIMC_, @src[1], pclist, lngSize, GCL_REVERSECONVERSION);
          if pclist.dwCount > 0 then
          begin
            // 先頭候補のオフセット取得
            lngOffset := pclist.dwOffset[1];
            p := PChar(pclist);
            Inc(PChar(p), lngOffset);
            // ふりがな取得
            Result := string(PChar(p));
          end;
        finally
          FreeMemory(pclist);
        end;
      end;
    end else
    begin
      // Windows 9x : SHIFT_JIS
      src := str;
      // 変換結果を受け取るバッファサイズを取得
      lngSize := ImmGetConversionListW(hKL_, hIMC_, @src[1], nil, 0, GCL_REVERSECONVERSION);
      if lngSize > 0 then
      begin
        // バッファ分の配列を取得
        pclist := GetMemory(lngSize);
        try
          // 変換結果を取得
          ImmGetConversionListW(hKL_, hIMC_, @src[1], pclist, lngSize, GCL_REVERSECONVERSION);
          if pclist.dwCount > 0 then
          begin
            // 先頭候補のオフセット取得
            lngOffset := pclist.dwOffset[1];
            pw := PWideString(pclist);
            Inc(PWideString(pw), lngOffset);
            // ふりがな取得
            wstr := WideString(pw);
            Result := wstr;
          end;
        finally
          FreeMemory(pclist);
        end;
      end;
    end;
  finally
    ImmReleaseContext(hwnd, hIMC_);
  end;
end;

function convToHalfAnk(const str: string): string;
var
    p,pr: PChar;
    s: string;
    i: Integer;
const
    HALF_JOUKEN = '０１２３４５６７８９'+
        'ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ'+
        'ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ'+
        '！”＃＄％＆’（）＝－￥［］｛｝＿／＞＜，．＠‘　｜';

begin
    SetLength(Result, Length(str)*2+1);//とりあえず適当な大きさを確保
    p  := PChar(str);
    pr := PChar(Result);

    while p^ <> #0 do
    begin
        if p^ in LeadBytes then
        begin
            s := p^ + (p+1)^;
            i := Pos(s, HALF_JOUKEN);
            if (i>0)and(((i-1)mod 2)=0) then //文字が途中で分断されているのを防ぐため、mod 2=0 でチェック
            begin
                s := convToHalf(s);
                pr^ := s[1]; Inc(pr);
                Inc(p,2);
            end else
            begin
                pr^ := p^; Inc(pr); Inc(p);
                pr^ := p^; Inc(pr); Inc(p);
            end;
        end else
        begin // 既に ank
            //半角カタカナは全角へ(( 0xA0-0xDF ))
            if (#$A0 <= p^)and(p^ <= #$DF) then
            begin
              s := convToFull(p^);
              pr^ := s[1]; Inc(pr);
              pr^ := s[2]; Inc(pr);
              Inc(p);
            end else
            begin
              pr^ := p^ ; Inc(pr); Inc(p);
            end;
        end;
    end;
    pr^ := #0;
    Result := string(PChar(Result));
end;


{トークン処理}
{トークン切り出し／区切り文字分を進める}
function GetTokenChars(delimiter: TCharSet; var ptr:PChar): string;
begin
  Result := '';
  while ptr^ <> #0 do
  begin
    if ptr^ in LeadBytes then
    begin
      Result := Result + ptr^ + (ptr+1)^;
      Inc(ptr,2);
    end else
    begin
      if ptr^ in delimiter then
      begin
        Inc(ptr);
        Break;
      end;
      Result := Result + ptr^;
      Inc(ptr);
    end;
  end;
end;

function GetTokenPtr(delimiter: Char; var ptr:PChar): string;
begin
  Result := '';
  while ptr^ <> #0 do
  begin
    if ptr^ in LeadBytes then
    begin
      Result := Result + (ptr^) + (ptr+1)^;
      Inc(ptr,2);
    end else
    begin
      if ptr^ = delimiter then
      begin
        Inc(ptr);
        Break;
      end else
      begin
        Result := Result + ptr^;
        Inc(ptr);
      end;
    end;
  end;
end;

function SplitChar(delimiter: Char; str: string): TStringList;
var
  p: PChar; s: string;
begin
  Result := TStringList.Create ;
  p := PChar(str);
  while p^ <> #0 do
  begin
    s := GetTokenPtr(delimiter, p);
    Result.Add(s); 
  end;
end;

function IsHiragana(const str: string): Boolean;
var code: Integer;
begin
    Result := False;
    if Length(str)<2 then Exit;
    code := (Ord(str[1])shl 8) + Ord(str[2]);
    if ($82A0 <= code)and(code <= $833E) then Result := True;
end;

function IsKatakana(const str: string): Boolean;
var code: Integer;
begin
    Result := False;
    if Length(str)<2 then Exit;
    code := (Ord(str[1])shl 8) + Ord(str[2]);
    if ($8340 <= code)and(code <= $839D) then Result := True;
end;

function IsNumStr(const str: string): Boolean; //文字列が全て数値かどうか判断
var
    p: PChar;
begin
    Result := False;
    p := PChar(str);

    if not (p^ in ['0'..'9']) then Exit;
    Inc(p);

    while p^ <> #0 do
    begin
        if p^ in ['0'..'9','e','E','+','-','.'] then //浮動小数点に対応
            Inc(p)
        else
            Exit;
    end;
    Result := True;
end;

end.

