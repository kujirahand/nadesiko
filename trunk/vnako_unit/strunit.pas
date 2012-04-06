unit StrUnit;
(*------------------------------------------------------------------------------
汎用文字列処理を定義したユニット

全ての関数は、マルチバイト文字(S-JIS)に対応している

作成者：作成者：クジラ飛行机(http://kujirahand.com)
作成日：2001/11/24

履歴：
2002/04/09 途中に#0を含む文字列でも検索置換できるように修正

------------------------------------------------------------------------------*)
interface
uses
  Windows, SysUtils, Classes, EasyMasks {$IFDEF VER140},Variants{$ENDIF}
  {$IF RTLVersion>=15},Variants{$IFEND},imm, Forms;

type
  TCharSet = set of AnsiChar;

{------------------------------------------------------------------------------}
{マルチバイトに対応した検索置換関数}

{文字列検索 // ｎバイト目の文字の位置を返す}
function PosExW(const sub, str:string; idx:Integer): Integer;
{文字列置換}
function JReplaceU(const Str, oldStr, newStr:string; repAll:Boolean): string;
{文字列置換拡張版}
function JReplaceEx(const Str, oldStr, newStr:string; repAll:Boolean; useCase:Boolean): string;
{指定個目のoldStrを、newStrに置換する}
function JReplaceCnt(const Str, oldStr, newStr:string; Index: Integer): string;
{デリミタ文字列までの単語を切り出す。（切り出した単語にデリミタは含まない。）
切り出し後は、元の文字列strから、切り出した文字列＋デリミタ分を削除する。}
function GetToken(const delimiter: String; var str: string): String;
{マルチバイト文字数を得る}
function JLength(const str: string): Integer;
{マルチバイト文字列を切り出す}
function JCopy(const str: string; Index, Count: Integer): string;
{マルチバイト文字列を検索する}
function JPosM(const sub, str: string): Integer;

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
function ConvToHurigana(const str: string): string; // 振り仮名に変換
{マルチバイトを考慮した大文字、小文字化}
function LowerCaseEx(const str: string): string;
function UpperCaseEx(const str: string): string;
function UpperCaseOne(const str: string): string;//一文字目だけ大文字
{ローマ字表記を半角カナに変換}
function RomajiToKana(romaji: String): String;
{ｱ 愛知県 のような行頭の半角カナを削除して返す}
function TrimLeftKana(str: string): string;

{------------------------------------------------------------------------------}
{文字種類の判別}
function IsHiragana(const str: string): Boolean;
function IsKatakana(const str: string): Boolean;
function AscA(const str: AnsiString): Integer; //文字コードを得る
function AscW(const str: string): Integer; //文字コードを得る
function IsNumStr(const str: string): Boolean; //文字列が全て数値かどうか判断

{------------------------------------------------------------------------------}
{HTML処理}

{HTML から タグを取り除く}
function DeleteTag(const html: string): String;
{HTMLの指定タグで囲われた部分を抜き出す}
function GetTag(var html:string; tag: string): string;
function GetTags(html:string; tag: string): string;
function GetAbsolutePath(soutai, base: string; Delimiter: Char): string;
function HtmlColorToColorCode(s: string): Integer;
function ColorCodeToHtmlColor(c: Integer): string;

{------------------------------------------------------------------------------}
{トークン処理}

{トークン切り出し／区切り文字分を進める}
function GetTokenChars(delimiter: TCharSet; var ptr:PChar): string;
function GetTokenPtr(delimiter: Char; var ptr:PChar): string;
function SplitChar(delimiter: Char; str: string): TStringList;
{ネストする（）の内容を抜き出す}
function GetKakko(var pp: PChar): string;

{------------------------------------------------------------------------------}
{日時処理}

{日付の加算 ex)３ヵ月後 IncDate('2001/10/30','0/3/0') 三日前 IncDate('2001/1/1','-0/0/3')}
function IncDate(BaseDate: TDateTime; AddDate: string): TDateTime;
{時間の加算 ex)３時間後 IncTime('15:0:0','3:0:0') 三秒前 IncTime('12:45:0','-0:0:3')}
function IncTime(BaseTime: TDateTime; AddTime: string): TDateTime;
{西暦、和暦に対応した日付変換用関数}
function StrToDateStr(const str: string): string;
{西暦、和暦に対応した日付変換用関数}
function StrToDateEx(str: string): TDateTime;
{TDateTimeを、和暦に変換する}
function DateToWareki(d: TDateTime): string;

{------------------------------------------------------------------------------}
{その他}

{3桁区切りでカンマを挿入する}
function InsertYenComma(const yen: string): string;
{文字を出来る限り数値に変換する}
function StrToValue(const str: string): Extended;
{ワイルドカードマッチ}
function WildMatch(Filename,Mask:string):Boolean;
{行揃えする}
function CutLine(line: AnsiString; cnt,tabCnt: Integer; kinsoku: AnsiString): AnsiString;

{バイナリ表示する}
function StrToHexStr(s:string): string;

{------------------------------------------------------------------------------}
implementation

uses DateUtils, gui_benri;


function StrToHexStr(s:string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(s) do
  begin
    Result := Result + IntToHex(Ord(s[i]), 2) + ',';
    if (i-1) mod 16 = 15 then Result := Result + #13#10;
  end;
end;

{行揃えする}
function CutLine(line: AnsiString; cnt,tabCnt: Integer; kinsoku: AnsiString): AnsiString;
(*
const
  GYOUTOU_KINSI = '、。，．・？！゛゜ヽヾゝゞ々ー）］｝」』!),.:;?]}｡｣､･ｰﾞﾟ';
*)
var
  p: PAnsiChar;
  i: Integer;

  procedure CopyOne;
  begin
    Result := Result + p^;
    Inc(p);
  end;

  procedure InsCrLf;
  var next_c: AnsiString;
  begin
    //禁則処理(行頭禁則文字)
    if kinsoku<>'' then
    begin
      if p^ in LeadBytes then
      begin
        next_c := p^ + (p+1)^;
      end else
      begin
        next_c := p^;
      end;

      if PosExW(string(next_c), string(kinsoku), 1) > 0 then
      begin
        if p^ in LeadBytes then
        begin
          CopyOne; CopyOne;
        end else
        begin
          CopyOne;
        end;
      end;
    end;

    Result := Result + #13#10;
    i := 0;
  end;

begin
  if cnt<=0 then
  begin
    Result := line;
    Exit;
  end;

  p  := PAnsiChar(line);
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
end;

{TDateTimeを、和暦に変換する}
function DateToWareki(d: TDateTime): string;
var y, yy, mm, dd: Word; sy: string;

const
  MEIJI  = 1868; //* 修正 2003/09/28
  TAISYO = 1912;
  SYOWA  = 1926;
  HEISEI = 1989;
begin
    DecodeDate(d, yy, mm, dd);
    if (MEIJI<=yy)and(yy<TAISYO) then
    begin
        y := yy-MEIJI+1;
        if y=1 then sy := '元年' else sy := IntToStr(y)+'年';
        Result := Format('明治'+sy+'%d月%d日',[mm,dd]);
    end else
    if (TAISYO<=yy)and(yy<SYOWA) then
    begin
        y := yy-TAISYO+1;
        if y=1 then sy := '元年' else sy := IntToStr(y)+'年';
        Result := Format('大正'+sy+'%d月%d日',[mm,dd]);
    end else
    if (SYOWA<=yy)and(yy<HEISEI) then
    begin
        y := yy-SYOWA+1;
        if y=1 then sy := '元年' else sy := IntToStr(y)+'年';
        Result := Format('昭和'+sy+'%d月%d日',[mm,dd]);
    end else
    if (HEISEI<=yy) then
    begin
        y := yy-HEISEI+1;
        if y=1 then sy := '元年' else sy := IntToStr(y)+'年';
        Result := Format('平成'+sy+'%d月%d日',[mm,dd]);
    end;
end;

{マルチバイト文字数を得る}
function JLength(const str: string): Integer;
begin
  Result := Length(str);
end;

{マルチバイト文字列を切り出す}
function JCopy(const str: string; Index, Count: Integer): string;
begin
  Result := Copy(str, Index, Count);
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
        Inc(p);
        Inc(i);
    end;
end;

function AscA(const str: AnsiString): Integer; //文字コードを得る
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

function AscW(const str: string): Integer; //文字コードを得る
begin
  if str = '' then begin
    Result := 0;
    Exit;
  end;
  Result := Ord(str[1]);
end;


{西暦、和暦に対応した日付変換用関数}
function StrToDateStr(const str: string): string;
begin
    Result:='';
    if str='' then Exit;
    Result := FormatDateTime(
        'yyyy/mm/dd',
        StrToDateEx(str)
    );
end;

function StrToDateEx(str: string): TDateTime;
begin
    Result := Now;
    if str='' then Exit;
    if Pos('.',str)>0 then str := JReplaceU(str,'.','/',True);
    Result := VarToDateTime(str);
end;

{時間の加算 ex)３時間後 IncTime('15:0:0','3:0:0') 三秒前 IncTime('12:45:0','-0:0:3')}
function IncTime(BaseTime: TDateTime; AddTime: string): TDateTime;
var
    flg: string;
    hh,nn,ss: Word;
begin
    // デルファイの標準関数を使うように変更 2003/2/19
    // 足すか引くか判断
    flg := Copy(AddTime,1,1);
    if (flg='-')or(flg='+') then Delete(AddTime, 1,1);

    hh := StrToIntDef(getToken(':', AddTime),0);
    nn := StrToIntDef(getToken(':', AddTime),0);
    ss := StrToIntDef(AddTime, 0);
    if flg <> '-' then
    begin
      Result := IncHour(BaseTime, hh);
      Result := IncMinute(Result, nn);
      Result := IncSecond(Result, ss);
    end else
    begin
      Result := IncHour(BaseTime, hh*-1);
      Result := IncMinute(Result, nn*-1);
      Result := IncSecond(Result, ss*-1);
      if(Result<0)then Result := IncHour(Result, 24);
    end;
end;

{日付の加算 ex)３ヵ月後 IncDate('2001/10/30','0/3/0') 三日前 IncDate('2001/1/1','-0/0/3')}
function IncDate(BaseDate: TDateTime; AddDate: string): TDateTime;
var
    flg: string;
    yy,mm,dd: Word;
begin
    // デルファイの標準関数を使うように変更 2003/2/19
    // 足すか引くかの判断
    flg := Copy(AddDate,1,1);
    if (flg='-')or(flg='+') then Delete(AddDate, 1,1);

    // 足す日付を分解する
    yy := StrToIntDef(getToken('/', AddDate),0);
    mm := StrToIntDef(getToken('/', AddDate),0);
    dd := StrToIntDef(AddDate, 0);
    if flg <> '-' then
    begin
      // 足す
      Result := IncYear(BaseDate, yy);
      Result := IncMonth(Result, mm);
      Result := IncDay(Result, dd);
    end else
    begin
      // 引く
      Result := IncYear(BaseDate, yy*-1);
      Result := IncMonth(Result, mm*-1);
      Result := IncDay(Result, dd*-1);
    end;
end;

procedure skipSpace(var p: PChar);
begin
    while CharInSet(p^, [' ',#9]) do Inc(p);
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
                if IsStr then begin
                  Inc(pp);
                end;
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
function WildMatch(Filename,Mask:string):Boolean;
begin
    Result := MatchesMask(Filename, Mask);
end;

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

    buf := Trim(JReplaceU(ConvToHalfMini(str),',','',True));//カンマを削除
    if Copy(buf,1,1) = '\' then System.Delete(buf,1,1);

    p := PChar(buf);
    while CharInSet(p^, [' ',#9]) do Inc(p);
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
    while CharInSet(p^, ['0'..'9']) do Inc(p);
    // 小数点
    if p^ = '.' then Inc(p);
    while CharInSet(p^, ['0'..'9']) do Inc(p);
    // 指数形式
    if CharInSet(p^, ['e','E']) and CharInSet((p+1)^, ['+','-']) and CharInSet((p+2)^,['0'..'9']) then
    begin
      Inc(p,3);
      while CharInSet(p^ ,['0'..'9']) do Inc(p);
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


function GetToken(const delimiter: String; var str: string): String;
var
    i: Integer;
begin
    i := PosExW(delimiter, str,1);
    if i=0 then
    begin
        Result := str;
        str := '';
        Exit;
    end;
    Result := Copy(str, 1, i-1);
    Delete(str,1,i + Length(delimiter) -1);
end;

{HTML から タグを取り除く}
function DeleteTag(const html: string): String;
var
  i: Integer;
  txt: String;
  TagIn: Boolean;
begin
    txt := Trim(html);
    if txt = '' then Exit;

    i := 1;
    Result := '';

    TagIn := False;
    while i <= Length(txt) do
    begin
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
    while p^ <> #0 do
    begin
      if CharInSet(p^ , ['/', 'A'..'Z','a'..'z','0'..'9','_','-']) then
      begin
        Result := Result + p^; Inc(p);
      end else
        Break;
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
      Inc(p);
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
      Inc(p);
    end;
  end;

begin
  // タグを大文字に切りそろえる。タグ記号は削除する
  tag := UpperCase(tag);
  tag := JReplaceU(tag, '<','', True);
  tag := JReplaceU(tag, '>','', True);

  // タグの始まりを探す
  p := PChar(html);
  nest := 0;
  pFrom := nil;
  while p^ <> #0 do
  begin
    if p^ <> '<' then begin Inc(p); Continue; end;
    pp := p;
    Inc(pp);
    s := getTagName(pp);
    skipTagEnd(pp);
    if UpperCase(s) = tag then
    begin
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
    if p^ <> '<' then begin Inc(p); Continue; end;
    Inc(p);
    s := getTagName(p);
    skipTagEnd(p);

    // タグのネストを検出
    if UpperCase(s) = tag then
    begin
      Inc(nest);
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

function HtmlColorToColorCode(s: string): Integer;
var
  r,g,b: string;
begin
  Result := -1;
  s := Trim(UpperCase(s));
  if s='' then Exit;
  if s[1] <> '#' then
  begin
    Result := StrToIntDef(s,-1); Exit;
  end;
  // 1234567
  // #RRGGBB
  r := Copy(s, 2, 2);
  g := Copy(s, 4, 2);
  b := Copy(s, 6, 2);
  try
    Result := RGB(StrToInt('$'+r), StrToInt('$'+g), StrToInt('$'+b));
  except
    Result := -1;
  end;
end;

function ColorCodeToHtmlColor(c: Integer): string;
var
  r,g,b: Byte;
begin
  // COL -> HTML
  // B G R
  r := c and $FF;
  g := BYTE( (c and $FF00) shr 8 );
  b := BYTE( (c and $FF0000) shr 16);
  Result := '#'+IntToHex(r,2)+IntToHex(g,2)+IntToHex(b,2); 
end;

function RomajiToKana(romaji: String): String;
const
    kana_list = 'k,ｶｷｸｹｺ,s,ｻｼｽｾｿ,t,ﾀﾁﾂﾃﾄ,n,ﾅﾆﾇﾈﾉ,h,ﾊﾋﾌﾍﾎ,m,ﾏﾐﾑﾒﾓ,y,2ﾔ ｲ ﾕ ｲｪﾖ ,r,ﾗﾘﾙﾚﾛ,w,2ﾜ ｳｨｳ ｳｪｦ ,'+
    'g,2ｶﾞｷﾞｸﾞｹﾞｺﾞ,z,2ｻﾞｼﾞｽﾞｾﾞｿﾞ,d,2ﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞ,b,2ﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞ,p,2ﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟ,'+
    'q,2ｸｧｸｨｸ ｸｪｸｫ,f,2ﾌｧﾌｨﾌ ﾌｪﾌｫ,j,3ｼﾞｬｼﾞ ｼﾞｭｼﾞｪｼﾞｮ,l,ｧｨｩｪｫ,x,ｧｨｩｪｫ,c,ｶｼｸｾｺ,'+
    'v,3ｳﾞｧｳﾞｨｳﾞ ｳﾞｪｳﾞｫ,f,ﾊﾋﾌﾍﾎ'+
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
        if CharInSet(s[1] , ['1'..'9']) then
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
        if CharInSet(p^, ['a','i','u','e','o']) then
        begin //母音なので決定
            DecideChar(p^);
            Inc(p);
            siin := '';
            Continue;
        end else
        if CharInSet(p^ , ['a'..'z']) then
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

    if CharInSet(str[1] , ['ｱ'..'ﾝ'])and(Copy(str,2,1)=' ') then
    begin
        Delete(str,1,1);
    end;
    Result := Trim(str);
end;

function PosExW(const sub, str:string; idx:Integer): Integer;
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
      Inc(p);
    end;
  except
    raise Exception.Create('文字列の検索中にエラー。'); 
  end;
end;

function JReplaceU(const Str, oldStr, newStr:string; repAll:Boolean): string;
var
    i, idx:Integer;
begin
    Result := Str;
    // ****
    i := PosExW(oldStr, Str, 1);
    if i=0 then Exit;
    Delete(result, i, Length(oldStr));
    Insert(newStr, result, i);
    idx := i + Length(newStr);
    if repAll = False then Exit;
    // *** Loop
    while True do
    begin
        i := PosExW(oldStr, result, idx);
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
    i := PosExW(oldStrFind, strFind, 1);
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
        i := PosExW(oldStrFind, strFind, idx);
        if i=0 then Exit;
        Delete(result, i, Length(oldStr));
        Insert(newStr, result, i);
        idx := i + Length(newStr);
    end;
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
function ConvToHurigana(const str: string): string;
var
  hIMC: THandle;    // 入力コンテキストハンドル
  hKL: THandle;    // キーボードレイアウトハンドル
  lngSize: Integer; // 変換後バッファサイズ
  lngOffset: Integer;// 変換文字列候補オフセットアドレス
  byCandiateArray: array of Byte; // 変換結果バッファ
  CandiateList: TCANDIDATELIST;
  osvi: TOSVERSIONINFO;
  w: WideString;
begin
  Result := '';
  if str = '' then Exit; //空文字列の場合は処理しない

  // OS判別
  osvi.dwOSVersionInfoSize := sizeof(osvi);
  GetVersionEx(osvi);

  // IME コンテキスト取得
  hIMC := ImmGetContext(Application.Handle);
  hKL := GetKeyboardLayout(0);

  if osvi.dwPlatformId = VER_PLATFORM_WIN32_NT then
  begin
    //WindowsNT系:SJIFT-JISのまま
    lngSize := ImmGetConversionListW(
      hKL,
      hIMC,
      PChar(str),
      nil,
      0,
      GCL_REVERSECONVERSION);
    if lngSize > 0 Then
    begin
      SetLength(byCandiateArray, lngSize);
      // 変換結果を取得
      ImmGetConversionListW(
        hKL, hIMC,
        PChar(str),
        @byCandiateArray[0],
        lngSize,
        GCL_REVERSECONVERSION);
      // バッファ内容を参照するため構造体にコピ-
      Move(byCandiateArray[0], CandiateList, sizeof(CandiateList));
      if CandiateList.dwCount > 0 then
      begin
        // 先頭候補のオフセット取得
        lngOffset := CandiateList.dwOffset[1];
        // '"ふりがな"取得
        Result := PChar( @byCandiateArray[lngOffset] );
      end;
    end;
  end else
  begin
    //Windows95系:シフトJISに変換
    //Windows98では ImmGetConversionListA API が Shift-JIS⇒Unicode の変換に使えることが判明しました。＼＾〇＾／
    //（"愛"はたまたま、他の文字はダメですから本当は使えません。なお、変換には MultiByteToWideChar API が用意されています。）
    //Windows 2000 がマトモなのに比べ Windows98 は本来使わないと思われる ImmGetConversionListW でなければ変換できません。
    //さらに渡すのは Shift-JIS で戻ってくるのは Unicode。マイクロソフトの言う一部サポートとはこういうことなんでしょうか？
    lngSize := ImmGetConversionListW(
                hKL, hIMC,
                PChar(str),
                nil,
                0,
                GCL_REVERSECONVERSION);
    if lngSize > 0 Then
    begin
      SetLength(byCandiateArray, lngSize);
      // 変換結果を取得 in: SJIS out: UNICODE
      ImmGetConversionList(hKL, hIMC, PChar(str), @byCandiateArray[0],
                    lngSize, GCL_REVERSECONVERSION);
      // バッファ内容を参照するため構造体にコピ-
      Move(byCandiateArray[0], CandiateList, sizeof(CandiateList));
      if CandiateList.dwCount > 0 then
      begin
        // 先頭候補のオフセット取得
        lngOffset := CandiateList.dwOffset[1];
        // '"ふりがな"取得 --- 戻りは UNICODE だそうだ wideString にキャスト
        w := PWideChar( @byCandiateArray[lngOffset] );
        Result := w; // Delphi ちゃんは楽チン自動変換の巻
      end;
    end;
  end;
  //開放
  ImmReleaseContext(Application.Handle, hIMC);
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
function UpperCaseOne(const str: string): string;//一文字目だけ大文字
var
  s: WideString; c: WideString;
begin
  if Length(str) > 0 then
  begin
    s := LowerCaseEx(str);
    c := s[1];
    c := UpperCase(c);
    s[1] := c[1];
    Result := s;
  end else
  begin
    Result := '';
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
        '！”＃＄％＆’（）＝－￥［］｛｝＿／＞＜，．＠‘　';

begin
    SetLength(Result, Length(str)*2+1);//とりあえず適当な大きさを確保
    p  := PChar(str);
    pr := PChar(Result);

    while p^ <> #0 do
    begin
        if Ord(p^) > $7F then
        begin
            s := p^;
            i := Pos(s, HALF_JOUKEN);
            if (i>0) then //文字が途中で分断されているのを防ぐため、mod 2=0 でチェック
            begin
                s := convToHalf(s);
                pr^ := s[1];
                Inc(pr);
                Inc(p);
            end else
            begin
                pr^ := p^;
                Inc(pr); Inc(p);
            end;
        end else
        begin // 既に ank
            //半角カタカナは全角へ((SJIS:0xA0-0xDF) UNI:FF61-FF9F)
            if CharInSet(p^,[#$FF61..#$FF9F]) then
            begin
              s := convToFull(p^);
              pr^ := s[1]; Inc(pr);
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
    begin
      if CharInSet(ptr^, delimiter) then
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

    if not CharInSet(p^ , ['0'..'9']) then Exit;
    Inc(p);

    while p^ <> #0 do
    begin
        if CharInSet(p^, ['0'..'9','e','E','+','-','.']) then //浮動小数点に対応
            Inc(p)
        else
            Exit;
    end;
    Result := True;
end;

end.
