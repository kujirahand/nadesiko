unit unit_string2;
//------------------------------------------------------------------------------
// 文字列処理に関する汎用的なユニット(Classes 利用版)
// [作成] クジラ飛行机
// [連絡] http://kujirahand.com/
// [日付] 2004/07/26
//
// 文字コード: SHIFT-JIS を対象
//
interface

uses
  Windows, SysUtils, Classes;

type
  TChars = set of char;

//------------------------------------------------------------------------------
// PChar 関連
//------------------------------------------------------------------------------
// PChar から 1文字取り出す
function getOneChar(var p: PChar): string;
// PChar から 1文字取り出し文字コードで返しポインタを進める
function getOneCharCode(var p: PChar): Integer;
// PChar で空白文字を飛ばしポインタを進める
procedure skipSpace(var p: PChar);
// PChar で特定の文字までを取り出しポインタを進める(返す文字にsplitterを含む)
// もしsplitterがあれば HasSplitter=True を返す
function getToSplitter(var p: PChar; splitter: string; var HasSplitter: Boolean): string;
function getToSplitterStr(var s: string; splitter: string): string;
function getToSplitterCh(var p: PChar; splitter: TSysCharSet; var HasSplitter: Boolean): string;
// 特定の文字列の手前までを取得する
function getToSplitterB(var p: PChar; splitter: string): string;
// 特定の区切り文字までを取得する（区切り文字は削除する）
function getTokenCh(var p: PChar; ch: TSysCharSet): string;
// 特定の区切り文字までを取得する（区切り文字は削除する）
function getTokenStr(var p: PChar; splitter: string): string;
// 特定のCharsを取得する
function getChars(var p: PChar; ch: TSysCharSet): string;

//------------------------------------------------------------------------------
// 文字列関連
//------------------------------------------------------------------------------
// 特定の区切り文字までを取得する（区切り文字は削除する）
function getToken_s(var s: string; splitter: string): string;
// 特定のCharsの間を取得する
function getChars_s(var s: string; ch: TSysCharSet): string;

//------------------------------------------------------------------------------
// 検索取り出し
//------------------------------------------------------------------------------
// 検索
function JPos(sub, s: string): Integer;
function JPosEx(sub, s: string; FromI: Integer): Integer;
function PosEx(sub, s: string; FromI: Integer): Integer;

// コピー
function JCopy (s: string; i, count: Integer): string;
function JRight(s: string; count: Integer): string;
function Right (s: string; count: Integer): string;
// 文字数取得
function JLength(s: string): Integer;
// 文字削除
procedure JDelete(var s: string; i, count: Integer);
// 置換
function JReplace(str, sFind, sNew: string): string;
function JReplace_(str, sFind, sNew: string): string;
function JReplaceOne(str, sFind, sNew: string): string;
// 繰り返し
function RepeatStr(s: string; count: Integer): string;

//------------------------------------------------------------------------------
// S_JIS対応コピー
//------------------------------------------------------------------------------
function sjis_copyByte(var p: PChar; count: Integer): string;
function Asc(const ch: string): Integer; //文字コードを得る

//------------------------------------------------------------------------------
// 文字種類変換 関連
//------------------------------------------------------------------------------
// 全角変換
function convToFull(const str: string): string;
// 半角変換
function convToHalf(const str: string): string;
// ひらがな変換
function convToHiragana(const str: string): string;
// カタカナ変換
function convToKatakana(const str: string): string;
// 小文字変換
function LowerCaseEx(const str: string): string;
// 大文字変換
function UpperCaseEx(const str: string): string;


//------------------------------------------------------------------------------
// 各種処理
//------------------------------------------------------------------------------
function ExpandTab(s: string; tabCnt: Integer): string;
function TrimCoupleFlag(s: string): string;

{$IFDEF VER150}
function CharInSet(c: Char; chars: TChars): Boolean;
{$ENDIF}


implementation

{$IFDEF VER150}
function CharInSet(c: Char; chars: TChars): Boolean;
begin
  if c in chars then Result := True else Result := False;
end;
{$ENDIF}

//------------------------------------------------------------------------------
// PChar 関連
//------------------------------------------------------------------------------
// PChar から 1文字取り出す
function getOneChar(var p: PChar): string;
begin
  begin
    Result := p^;
    Inc(p);
  end;
end;

// PChar から 1文字取り出し文字コードで返す
function getOneCharCode(var p: PChar): Integer;
begin
  begin
    Result := Ord(p^);
    Inc(p);
  end;
end;

// PChar で空白文字を飛ばす
procedure skipSpace(var p: PChar);
begin
  while CharInSet(p^, [' ',#9]) do Inc(p);
end;

// PChar で特定の文字までを取り出しポインタを進める(返す文字にsplitterを含む)
// もしsplitterがあれば HasSplitter=True を返す
function getToSplitter(var p: PChar; splitter: string; var HasSplitter: Boolean): string;
var sp: PChar; len: Integer;
begin
  sp := PChar(splitter); len := Length(splitter);
  HasSplitter := False;
  Result := '';
  while p^ <> #0 do
  begin
    if StrLComp(p, sp, len) = 0 then // 合致したか
    begin
      Result := Result + splitter;
      Inc(p, len);
      HasSplitter := True;
      Break;
    end;
    Result := Result + getOneChar(p);
  end;
end;

function getToSplitterStr(var s: string; splitter: string): string;
var
  p: PChar; flg: Boolean;
begin
  p := PChar(s);
  Result := getToSplitter(p, splitter, flg);
  s := p;
end;

// 特定の文字列の手前までを取得する
function getToSplitterB(var p: PChar; splitter: string): string;
var
  sp: PChar; len: Integer;
begin
  sp := PChar(splitter); len := Length(splitter);
  Result := '';
  while p^ <> #0 do
  begin
    if StrLComp(p, sp, len) = 0 then // 合致したか
    begin
      Break;
    end;
    Result := Result + getOneChar(p);
  end;
end;

function getToSplitterCh(var p: PChar; splitter: TSysCharSet; var HasSplitter: Boolean): string;
begin
  HasSplitter := False;
  Result := '';
  while p^ <> #0 do
  begin
    //if p^ in splitter then // 合致したか
    if CharInSet(p^, splitter) then
    begin
      Result := Result + p^;
      Inc(p);
      HasSplitter := True;
      Break;
    end;
    Result := Result + getOneChar(p);
  end;
end;

// 特定の区切り文字までを取得する（区切り文字は削除する）
function getTokenCh(var p: PChar; ch: TSysCharSet): string;
begin
  Result := '';
  while p^ <> #0 do
  begin
    if CharInSet(p^, ch) then
    begin
      Inc(p);
      Break;
    end;

    Result := Result + p^; Inc(p);
  end;
end;

// 特定の区切り文字までを取得する（区切り文字は削除する）
function getTokenStr(var p: PChar; splitter: string): string;
var
  sp: PChar;
  len: Integer;
begin
  Result := '';

  sp  := PChar(splitter);
  len := Length(splitter);

  while p^ <> #0 do
  begin

    if StrLComp(p, sp, len) = 0 then
    begin
      Inc(p, len);
      Break;
    end;

    begin
      Result := Result + p^; Inc(p);
    end;
  end;
end;

// 特定のCharsを取得する
function getChars(var p: PChar; ch: TSysCharSet): string;
begin
  Result := '';
  while CharInSet(p^ , ch) do
  begin
    Result := Result + p^;
    Inc(p);
  end;
end;

// 特定の区切り文字までを取得する（区切り文字は削除する）
function getToken_s(var s: string; splitter: string): string;
var
  p: PChar;
begin
  p := PChar(s);
  Result := getTokenStr(p, splitter);
  s := string(p);
end;

// 特定のCharsの間を取得する
function getChars_s(var s: string; ch: TSysCharSet): string;
var
  p: PChar;
begin
  p := PChar(s);
  Result := getChars(p, ch);
  s := string(p);
end;

//------------------------------------------------------------------------------
// 検索取り出し
//------------------------------------------------------------------------------
// 検索
function JPos(sub, s: string): Integer;
var
  psub, ps: PChar;
  i, len: Integer;
begin
  psub := PChar(sub);
  ps   := PChar(s);
  len  := Length(sub);
  Result := 0; i := 0;
  while ps^ <> #0 do
  begin
    // 一致したか？
    if StrLComp(ps, psub, len) = 0 then
    begin
      Result := i + 1; Break;
    end;
    // 一致しないならば一文字ずらして検索続行
    Inc(i);
    begin
      Inc(ps);
    end;
  end;
end;

function JPosEx(sub, s: string; FromI: Integer): Integer;
var
  psub, ps: PChar;
  i, len: Integer;
begin
  s := JCopy(s, FromI, Length(s)); // 切り出し

  psub := PChar(sub);
  ps   := PChar(s);
  len  := Length(sub);
  Result := 0; i := 0;
  while ps^ <> #0 do
  begin
    // 一致したか？
    if StrLComp(ps, psub, len) = 0 then
    begin
      Result := (FromI-1) + i + 1; Break;
    end;
    // 一致しないならば一文字ずらして検索続行
    Inc(i);
    begin
      Inc(ps);
    end;
  end;
end;

function PosEx(sub, s: string; FromI: Integer): Integer;
begin
  s := Copy(s, FromI, Length(s));
  Result := Pos(sub, s);
  if Result > 0 then Result := Result + (FromI-1);
end;

// コピー
function JCopy(s: string; i, count: Integer): string;
var
  p: PChar;
  idx, idxFrom, idxTo: Integer;
  c: string;
begin
  p := PChar(s);
  idx := 1;
  idxFrom := i; if idxFrom < 1 then idxFrom := 1;
  idxTo   := idxFrom + count - 1;
  Result := '';
  while p^ <> #0 do
  begin
    // (ex) JCopy('12345',3,2)
    //      idxFrom = 3; idxTo = 4
    if idxTo < idx then Break; // 取得範囲を超えたら抜ける

    c := getOneChar(p);
    if (idxFrom <= idx)and(idx <= idxTo) then
    begin
      Result := Result + c;
    end;
    Inc(idx);
  end;
end;

function Right (s: string; count: Integer): string;
var
  len: Integer;
begin
  // 123456| right(s, 3) | 456
  len := Length(s);
  Result := Copy(s, len - count + 1, count);
end;

function JRight(s: string; count: Integer): string;
var
  len: Integer;
begin
  // RIGHT(abcde, 3) = cde
  //
  len := JLength(s);
  Result := JCopy(s, len - count + 1, count);
end;

// 文字数取得
function JLength(s: string): Integer;
var
  p: PChar;
begin
  p := PChar(s);
  Result := 0;
  while p^ <> #0 do
  begin
    getOneChar(p);
    Inc(Result);
  end;
end;

// 文字削除
procedure JDelete(var s: string; i, count: Integer);
var
  idx, idxFrom, idxTo: Integer;
  p: PChar;
  des, c: string;
begin
  idx := 0;
  idxFrom := i;
  idxTo   := idxFrom + count - 1;
  p := PChar(s);
  des := '';
  while p^ <> #0 do
  begin
    c := getOneChar(p);
    Inc(idx);
    if (idxFrom <= idx) and (idx <= idxTo) then
    begin
      // この間を削除
    end else
    begin
      des := des + c;
    end;
  end;
  s := des;
end;

// 置換
function JReplace_(str, sFind, sNew: string): string;
begin
  Result := JReplace(str, sFind, sNew);
end;
function JReplace(str, sFind, sNew: string): string;
var
  p, pFind: PChar;
  len: Integer;
  c: string;
begin
  p      := PChar(str);
  pFind  := PChar(sFind);
  len    := Length(sFind);
  Result := '';
  while p^ <> #0 do
  begin
    // 検索語に合致するか？
    if (StrLComp(p, pFind, len) = 0) then
    begin
      Result := Result + sNew;
      Inc(p, len);
      Continue;
    end;
    // 合致しなければそのままを返す
    c := getOneChar(p);
    Result := Result + c;
  end;
end;

function JReplaceOne(str, sFind, sNew: string): string;
var
  i, lenA, lenF: Integer;
begin
  i := Pos(sFind, str);
  if i = 0 then
  begin
    Result := str; Exit;
  end;
  // 1234567890
  //    **
  lenA := Length(str);
  lenF := Length(sFind);
  Result := Copy(str, 1, i-1) + sNew + Copy(str, i + lenF, lenA - (i + lenF) + 1);
end;

function RepeatStr(s: string; count: Integer): string;
var
  i, len: Integer;
begin
  if s = '' then begin Result := ''; Exit; end;

  // 領域を確保
  len := Length(s);
  SetLength(Result, count * len);

  // 繰り返し
  for i := 0 to count - 1 do
  begin
    Move(s[1], Result[i * len + 1], len);
  end;
end;


//------------------------------------------------------------------------------
// S_JIS対応コピー
//------------------------------------------------------------------------------
function sjis_copyByte(var p: PChar; count: Integer): string;
var
  i: Integer;
begin
  Result := '';
  i := 0;
  while p^ <> #0 do
  begin
    begin
      if (i+1) > count then Break;
      Result := Result + p^;
      Inc(i); Inc(p);
    end;
  end;
end;


function Asc(const ch: string): Integer; //文字コードを得る
begin
    if ch = '' then begin
        Result := 0;
        Exit;
    end;
    Result := Ord(ch[1]);
end;


//------------------------------------------------------------------------------
// 文字種類変換 関連
//------------------------------------------------------------------------------
function LCMapStringEx(const str: string; MapFlag: DWORD): string;
var
  pDes: PChar;
  len,len2: Integer;
begin
  if str='' then begin Result := ''; Exit; end;
  len  := Length(str);
  len2 := len*2+2;
  GetMem(pDes, len2);//half -> full
  try
    FillChar( pDes^, len2, 0 );
    LCMapString( LOCALE_SYSTEM_DEFAULT, MapFlag, PChar(str), len, pDes, len2-1);
    Result := string( pDes );
  finally
    FreeMem(pDes);
  end;
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
  try
    FillChar( pDes^, len2, 0 );
    LCMapString( LOCALE_SYSTEM_DEFAULT, MapFlag, PChar(str), len, pDes, len2-1);
    Result := string( pDes );
  finally
    FreeMem(pDes);
  end;
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

//------------------------------------------------------------------------------
// 各種処理
//------------------------------------------------------------------------------
function ExpandTab(s: string; tabCnt: Integer): string;
var
  p: PChar;
  c, i, cc: Integer;
begin
  Result := '';
  p := PChar(s);
  c := 0;
  while (p^ <> #0) do
  begin
    begin
      case p^ of
      #13:
        begin
          while CharInSet(p^, [#13,#10]) do begin
            Result := Result + p^; Inc(p);
          end;
          c := 0;
        end;
      #9:
        begin
          // 0123456
          // *---xxx ... 4
          // ..*-xxx ... 2
          cc := c mod tabCnt;
          if cc = 0 then cc := 4;
          for i := 1 to cc do
            Result := Result + ' ';
          Inc(p);
          c := 0;
        end;
      else
        begin
          Result := Result + p^;
          Inc(p); Inc(c);
        end;
      end;
    end;
  end;
end;

function TrimCoupleFlag(s: string): string;
var
  mae, usiro: string;
  flg: Boolean;
begin
  s := Trim(s); // ***
  if s = '' then
  begin
    Result := s; Exit;
  end;
  flg := False;
  begin
    mae   := Copy(s,1,1);
    usiro := Copy(s,Length(s),1);
    if mae = usiro then flg := True
    else begin
      // 対応する記号をチェック
      if (mae='(')and(usiro=')') then flg := True else
      if (mae='[')and(usiro=']') then flg := True else
      if (mae='{')and(usiro='}') then flg := True else
      if (mae='`')and(usiro='''') then flg := True else
      if (mae='<')and(usiro='>') then flg := True else
      if (mae='「')and(usiro='」') then flg := True else
      if (mae='『')and(usiro='』') then flg := True else
      if (mae='｛')and(usiro='｝') then flg := True else
      if (mae='【')and(usiro='】') then flg := True else
      if (mae='（')and(usiro='）') then flg := True else
      if (mae='〔')and(usiro='〕') then flg := True else
      if (mae='“')and(usiro='”') then flg := True else
      if (mae='‘')and(usiro='’') then flg := True else
      if (mae='＜')and(usiro='＞') then flg := True else
      ;
    end;
  end;
  //
  if flg then
  begin
    Result := Copy(s, Length(mae)+1, Length(s) - Length(mae)*2);
  end else
  begin
    Result := s;
  end;
end;


end.
