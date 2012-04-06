unit hima_string;

interface

uses
  SysUtils, unit_string, hima_variable;

type
  // ひまわりのソースを整形するコンバーター
  THimaSourceConverter = class
  private
    FSource: AnsiString;
    FileNo: Integer;
  private
    procedure getOneChar(var p: PAnsiChar; AddPointer: Boolean; var ch: AnsiString; var nch: AnsiString);
  public
    constructor Create(FileNo: Integer; source: AnsiString);
    procedure Convert;
    property Source: AnsiString read FSource;
  end;

// クラスを使わないで整形
function HimaSourceConverter(FileNo: Integer; src: AnsiString): AnsiString;
// 動詞の語尾変化を削除
function DeleteGobi(key: AnsiString): AnsiString;
// 文字コードの範囲内かどうか調べる
function CharInRange(p: PAnsiChar; fromCH, toCH: AnsiString): Boolean;
// 文字列を数値に変換
function HimaStrToNum(s: AnsiString): HFloat;

implementation

uses
  hima_error, hima_token;

// クラスを使わないで整形
function HimaSourceConverter(FileNo: Integer; src: AnsiString): AnsiString;
var
  h: THimaSourceConverter;
begin
  h := THimaSourceConverter.Create(FileNo, src);
  try
    h.Convert;
    Result := h.Source;
  finally
    h.Free;
  end;
end;

// 動詞の語尾変化を削除
function DeleteGobi(key: AnsiString): AnsiString;
var p: PAnsiChar;
begin
  key := HimaSourceConverter(0, key);
  p := PAnsiChar(key);

  if CharInRange(p, 'ぁ','ん') then // ひらがなから始まれば語尾を消さない
  begin
    Result := key;
    Exit;
  end;

  //
  Result := '';
  while p^ <> #0 do
  begin
    if p^ in LeadBytes then
    begin
      if not CharInRange(p, 'ぁ','ん') then Result := Result + p^ + (p+1)^;
      Inc(p, 2);
    end else
    begin
      Result := Result + p^;
      Inc(p);
    end;
  end;
end;
{ //old version
function DeleteGobi(key: AnsiString): AnsiString;
var
  p, pS: PAnsiChar;
  pp: PAnsiChar;
  s: AnsiString;
begin
  key := HimaSourceConverter(0, key);
  p := PAnsiChar(key); pS := p; pp := p;

  // ひらがな以外が最後に現れた位置(+1文字の所)を記録
  while p^ <> #0 do begin
    if p^ in LeadBytes then
    begin
      if False = CharInRange(p, 'ぁ','ん') then // ひらがな以外
      begin
        pp := p + 2;
      end;
      Inc(p,2);
    end else
    begin
      Inc(p);
      pp := p;
    end;
  end;

  // もし全部ひらがなだったら...
  if pp = pS then
  begin
    // 語尾の特定句を削除                     1234|5678|
    s := Copy(key, Length(key) - 4 + 1, 4); //ひま|する|
    //if Pos(s, 'する しろ') > 0 then
    if ((s='する')or(s='しろ'))and(key<>s) then
    begin
      Result := Copy(key,1,Length(key)-4);
    end else
      Result := key;
    Exit;
  end;

  // 最後にひらがな以外が出た場所まで得る
  Result := Copy(key, 1, (pp - pS));
end;
}


// 文字コードの範囲内かどうか調べる
function CharInRange(p: PAnsiChar; fromCH, toCH: AnsiString): Boolean;
var
  code: Integer;
  fromCode, toCode: Integer;
begin
  // 判別対象のコードを得る
  if p^ in LeadBytes then code := (Ord(p^) shl 8) + Ord((p+1)^) else code := Ord(p^);

  // 範囲初め
  if fromCH = '' then
  begin
    fromCode := 0;
  end else
  begin
    if fromCH[1] in LeadBytes then
      fromCode := (Ord(fromCH[1]) shl 8) + Ord(fromCH[2])
    else
      fromCode := Ord(fromCH[1]);
  end;

  // 範囲終わり
  if toCH = '' then
  begin
    toCode := $FCFC;
  end else
  begin
    if toCH[1] in LeadBytes then
      toCode := (Ord(toCH[1]) shl 8) + Ord(toCH[2])
    else
      toCode := Ord(toCH[1]);
  end;

  Result := (fromCode <= code)and(code <= toCode);
end;

// 文字列を数値に変換
{
function HimaStrToNum(s: AnsiString): Extended;
var
  p: PAnsiChar;
  Flag: Integer;

  procedure get16sin;
  var n: AnsiString;
  begin
    n := p^; Inc(p);
    while p^ in ['0'..'9','A'..'F','a'..'f'] do
    begin
      n := n + p^;
      Inc(p);
    end;
    Result := StrToInt(n) * Flag;
  end;

  procedure get10sin;
  var n: AnsiString;
  begin
    // 通常の形式
    // 123.456
    // 指数形式
    // 7.89E+08 7.89e-2
    n := p^; Inc(p);
    // 整数部分
    while p^ in ['0'..'9'] do begin
      n := n + p^; Inc(p);
    end;
    // 小数点
    if (p^ = '.') then
    begin
      n := n + p^; Inc(p);
      // 小数点以下
      while p^ in ['0'..'9'] do begin
        n := n + p^; Inc(p);
      end;
      // 指数形式
      if (p^ in ['e','E']) and ((p+1)^ in ['+','-']) and ((p+2)^ in ['0'..'9']) then
      begin
        n := n + p^ + (p+1)^ + (p+2)^;
        Inc(p,3);
        while p^ in ['0'..'9'] do
        begin
          n := n + p^;
          Inc(p);
        end;
      end;
    end;
    // 結果を得る
    Result := Flag * StrToFloat(n);
  end;

begin
  Result := 0; Flag := 1;

  p := PAnsiChar(s); skipSpace(p);

  // + or -
  if p^ = '+' then Inc(p);
  if p^ = '-' then begin Inc(p); Flag := -1; end;

  // 16進法か？
  if p^ = '$' then get16sin else

  // 10進法か？
  if p^ in ['0'..'9'] then get10sin else Exit; // 数値以外

end;
}
function HimaStrToNum(s: AnsiString): Extended;
var
  p: PAnsiChar; dummy: AnsiString;
begin
  p := PAnsiChar(s);
  Result := hima_token.HimaGetNumber(p, dummy);
end;

{ THimaSourceConverter }

procedure THimaSourceConverter.Convert;
var
  res: AnsiString;
  p: PAnsiChar;
  lineNo, InLineNo: Integer; memStr: AnsiString;
  ch, nch, ch2, nch2: AnsiString;
  isString, isComment, isString2, isCommentLine: Boolean;
  isString3, isString4: Boolean;

begin
  res    := '';
  lineNo :=  1; InLineNo := 0; // 行番号
  memStr := ''; // エラー表示のための周辺文字列
  p      := PAnsiChar(FSource);
  isString  := False; //「」
  isString2 := False; //『』
  isString3 := False; // ""
  isString4 := False; // ``
  isComment  := False; // /* ... */
  isCommentLine := False; // #...

  // 英数全角を半角に
  // 半角カタカナを全角に
  // 制御記号を統一する
  // ただし、文字列の中、コメントの中は変換しない

  while p^ <> #0 do
  begin
    // 改行なら行数を足す
    if (p^ in [#13,#10]) then
    begin
      if (p^ + (p+1)^) = #13#10 then Inc(p, 2) else Inc(p);
      isCommentLine := False;
      Inc(lineNo);
      res := res + #13#10;
      Continue;
    end;

    // 今回の対象１文字を得る
    getOneChar(p, true, ch, nch);

    //----------------------------------------------------
    // 状態が文字列かコメントなら、それらから抜けるか確認
    if isString then
    begin
      // 文字列の解除か
      if nch = '」' then
      begin
        isString := False;
        res := res + nch; // 半角も全角も「」で統一
        Continue;
      end;
    end else
    if isString2 then
    begin
      // 文字列の解除か
      if nch = '』' then
      begin
        isString2 := False;
        res := res + nch; // 半角も全角も「」で統一
        Continue;
      end;
    end else
    if isString3 then
    begin
      // 文字列の解除か
      if nch = '"' then
      begin
        isString3 := False;
        res := res + nch; // 半角も全角も「」で統一
        Continue;
      end;
    end else
    if isString4 then
    begin
      // 文字列の解除か
      if nch = '`' then
      begin
        isString4 := False;
        res := res + nch; // 半角も全角も「」で統一
        Continue;
      end;
    end else
    if isComment then
    begin
      // コメントから抜けるか
      if nch = '*' then
      begin
        getOneChar(p, False, ch2, nch2);
        if nch2 = '/' then
        begin
          isComment := False;
          Inc(p, Length(ch2)); // add Pointer
          //res := res + '*/';
          InLineNo := lineNo;
          Continue;
        end;
      end;
      Continue;
    end else if isCommentLine then
    begin
      Continue;
    end else
    (*
    if isComment2 then
    begin
      // コメントから抜けるか
      if nch = '}' then
      begin
        isComment2 := False;
      end;
      Continue;
    end else
    *)
    //---------------------------------------------------
    // 文字列でもコメントでない場所
    begin
      //-----------------------------------
      // 文字列やコメントに入るかチェック
      //-----------------------------------
      // 文字列に入るか？
      if (nch = '「') then
      begin
        isString := True;
        res := res + nch; // 半角も全角も「」で統一
        InLineNo := lineNo;
        memStr := ch + sjis_copyByte(p, 10);
        Continue;
      end else
      if (nch = '『') then
      begin
        isString2 := True;
        res := res + nch; // 半角も全角も「」で統一
        InLineNo := lineNo;
        memStr := ch + sjis_copyByte(p, 10);
        Continue;
      end else
      if (nch = '"') then
      begin
        isString3 := True;
        res := res + nch; // 半角も全角も「」で統一
        InLineNo := lineNo;
        memStr := ch + sjis_copyByte(p, 10);
        Continue;
      end else
      if (nch = '`') then
      begin
        isString4 := True;
        res := res + nch; // 半角も全角も「」で統一
        InLineNo := lineNo;
        memStr := ch + sjis_copyByte(p, 10);
        Continue;
      end else
      // コメントに入るか
      {
      if (nch = '{') then
      begin
        isComment2 := True;
        InLineNo := lineNo;
        memStr := ch + sjis_copyByte(p, 10);
        Continue;
      end else
      }
      if (nch = '/') then
      begin
        getOneChar(p, False, ch2, nch2);
        if nch2 = '*' then
        begin
          isComment := True;
          Inc(p, Length(ch2)); // add Pointer
          //res := res + '/*';
          InLineNo := lineNo;
          memStr := ch + ch2 + sjis_copyByte(p, 10);
          Continue;
        end else
        if nch2 = '/' then
        begin
          // 行末までコメント
          Inc(p, Length(ch2)); // add Pointer
          isCommentLine := True;
          Continue;
        end;
      end else
      if (nch = '#')or(nch = '''') then
      begin
        // 行末までコメント
        isCommentLine := True;
        Continue;
      end else
      begin
        // 突然文字列やコメントの終端記号が出てきたらエラーを出す
        if nch = '」' then raise EHimaSyntax.Create(FileNo, LineNo, ERR_NOPAIR_STRING, []);
        if nch = '』' then raise EHimaSyntax.Create(FileNo, LineNo, ERR_NOPAIR_STRING2,[]);
        if nch = '"'  then raise EHimaSyntax.Create(FileNo, LineNo, ERR_NOPAIR_STRING3,[]);
        if nch = '`'  then raise EHimaSyntax.Create(FileNo, LineNo, ERR_NOPAIR_STRING4,[]);
        if nch = '*'  then
        begin
          getOneChar(p, False, ch2, nch2);
          if nch2 = '/' then raise EHimaSyntax.Create(FileNo, LineNo, ERR_NOPAIR_COMMENT,[]);
        end;
      end;

    end;


    // 文字列なら旧文字列を。コメントは省略。違えば新文字列を。
    if isString or isString2 or isString3 or isString4 then res := res + ch
    //不要::else if isComment or isCommentLine then {nothing}
    else res := res + nch;
  end;

  // 文字列が対応してない
  if isString   then raise EHimaSyntax.Create(FileNo, InLineNo, ERR_NOPAIR_STRING   + '～'+memStr,[]);
  if isString2  then raise EHimaSyntax.Create(FileNo, InLineNo, ERR_NOPAIR_STRING2  + '～'+memStr,[]);
  if isString3  then raise EHimaSyntax.Create(FileNo, InLineNo, ERR_NOPAIR_STRING3  + '～'+memStr,[]);
  if isString4  then raise EHimaSyntax.Create(FileNo, InLineNo, ERR_NOPAIR_STRING4  + '～'+memStr,[]);
  if isComment  then raise EHimaSyntax.Create(FileNo, InLineNo, ERR_NOPAIR_COMMENT  + '～'+memStr,[]);

  FSource := res;
end;

constructor THimaSourceConverter.Create(FileNo: Integer; source: AnsiString);
begin
  FSource := source;
  Self.FileNo := FileNo;
end;

// 一文字切り出す ... 切り出した結果を ch nch に得る
procedure THimaSourceConverter.getOneChar(var p: PAnsiChar; AddPointer: Boolean; var ch, nch: AnsiString);
var
  code: Integer;
  pp: PAnsiChar;
begin
  if p^ = #0 then begin ch := ''; nch := ''; Exit; end; //

  if p^ in SysUtils.LeadBytes then
  begin
    ch   := p^ + (p+1)^; nch := '';
    code := Ord( p^ ) shl 8 + Ord( (p+1)^ );

    // 英数文字は半角へ
    case code of
      $8140{全角スペース}: nch := '  '; // 全角スペースは、半角２文字分と数える
      $8141{、},$8143{，}: nch := ',';
      $8142{。},$8147{；}: nch := ';';
      $8144{．}          : nch := '.';
      $8146{：}          : nch := ':';
      $8148{？}          : nch := '?';
      $8149{！}          : nch := '!';
      $814F{＾}          : nch := '^';
      $8151{＿}          : nch := '_';
      $815E{／}          : nch := '/';
      $8160{～}          : nch := '~';
      $8165{‘}          : nch := '`';
      $8166{’}          : nch := '#';
      $8167{“}          : nch := '"';
      $8168{”}          : nch := '"';
      $8179{【}          : nch := '[';
      $817A{】}          : nch := ']';
      $817B{＋}          : nch := '+';
      $817C{－}          : nch := '-';
      $817E{×}          : nch := '*';
      $8180{÷}          : nch := '/';
      $8181{＝}          : nch := '=';
      $8182{≠}          : nch := '<>';
      $8183{＜}          : nch := '<';
      $8184{＞}          : nch := '>';
      $8185{≦}          : nch := '<=';
      $8186{≧}          : nch := '>=';
      $818F{￥}          : nch := '\';
      $8190{＄}          : nch := '$';
      $8193{％}          : nch := '%';
      $8194{＃},$81A6{※}: nch := '#';
      $8195{＆}          : nch := '&';
      $8196{＊}          : nch := '*';
      $8197{＠}          : nch := '@';
      $8162{｜}          : nch := '|';
      $8169{（}          : nch := '(';
      $816A{）}          : nch := ')';
      $816D{［}          : nch := '[';
      $816E{］}          : nch := ']';
      $816F{｛}          : nch := '{';
      $8170{｝}          : nch := '}';
      $819C{●}          : nch := '*';
      $824F..$8258{0..9} : code := code - $824F{S_JIS:0} + $30{ASCII:0};
      $8260..$8279{A..Z} : code := code - $8260{S_JIS:A} + $41{ASCII:A};
      $8281..$829A{a..z} : code := code - $8281{S_JIS:a} + $61{ASCII:a};
    else
      nch := ch;
    end;

    // 結果
    if nch = '' then nch := AnsiString(Chr(code));
  end else
  begin
    // 半角カナを全角に
    if (#$A1 <= p^) and (p^ <= #$DF) then
    begin
      // 濁点なら足す
      pp := p + 1;
      if (pp^ = #$DE)or(pp^ = #$DF) then ch := p^ + pp^ else ch := p^;
      nch := convToFull(ch); // 全角変換(APIに頼る)
    end else
    begin
      ch := p^;
      nch := ch;
    end;
  end;
  if AddPointer then Inc(p, Length(ch));
end;

end.
