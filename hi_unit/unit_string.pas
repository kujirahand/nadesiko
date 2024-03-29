unit unit_string;
//------------------------------------------------------------------------------
// 文字列処理に関する汎用的なユニット
// [作成] クジラ飛行机
// [連絡] http://kujirahand.com
// [日付] 2004/07/26
//
// 文字コード: SHIFT-JIS を対象
//
interface

uses
  {$IFDEF Win32}
  Windows,
  {$ENDIF}
  SysUtils,
  Classes,
  //EasyMasks,
  hima_types;

// SJIS Support
type TChars = set of AnsiChar;
const SJISLeadBytes: TChars = [#$81..#$9F,#$E0..#$FC];

//------------------------------------------------------------------------------
// PAnsiChar 関連
//------------------------------------------------------------------------------
// PAnsiChar から 1文字取り出す
function getOneChar(var p: PAnsiChar): AnsiString;
// PAnsiChar から 1文字取り出し文字コードで返しポインタを進める
function getOneCharCode(var p: PAnsiChar): Integer;
// PAnsiChar で空白文字を飛ばしポインタを進める
procedure skipSpace(var p: PAnsiChar);
// PAnsiChar で特定の文字までを取り出しポインタを進める(返す文字にsplitterを含む)
// もしsplitterがあれば HasSplitter=True を返す
function getToSplitter(var p: PAnsiChar; splitter: AnsiString; var HasSplitter: Boolean): AnsiString;
function getToSplitterStr(var s: AnsiString; splitter: AnsiString): AnsiString;
// 特定の文字列の手前までを取得する
function getToSplitterB(var p: PAnsiChar; splitter: AnsiString): AnsiString;
// 特定の区切り文字までを取得する（区切り文字は削除する）
function getTokenCh(var p: PAnsiChar; ch: TChars): AnsiString;
// 特定の区切り文字までを取得する（区切り文字は削除する）
function getTokenStr(var p: PAnsiChar; splitter: AnsiString): AnsiString;
function getTokenStrU(var p: PChar; splitter: string): string;
// 特定の区切り文字までを取得する（区切り文字は削除する）
function getToken_s(var s: AnsiString; splitter: AnsiString): AnsiString;
function getToken_sU(var s: string; splitter: string): string;

// 特定の区切り文字までを取得する（区切り文字は削除する）
function getTokenChW(var p: PAnsiChar; ch: TChars): AnsiString;

// 特定の区切り文字までを取得する（区切り文字は削除する）対バイナリ用
function getTokenChB2(var p: PAnsiChar; var l: integer;ch: TChars): AnsiString;
function getTokenChB(var p: PChar; ch: TSysCharSet): string;

function getChars_s(var s: string; ch: TSysCharSet): string;
function getChars(var p: PChar; ch: TSysCharSet): string;

//------------------------------------------------------------------------------
// 検索取り出し
//------------------------------------------------------------------------------
// 検索
function PosA(sub, s: AnsiString): Integer;
function PosExA(sub, s: AnsiString; FromI: Integer): Integer;
function PosExA2(sub, s: AnsiString; FromI: Integer): Integer;
function JPos(sub, s: string): Integer;

// コピー
function CopyA (s: AnsiString; i, count: Integer): AnsiString;
function JRight(s: AnsiString; count: Integer): AnsiString;
function Right (s: AnsiString; count: Integer): AnsiString;
// 文字数取得
function JLength(s: AnsiString): Integer;
// 文字削除
procedure JDelete(var s: AnsiString; i, count: Integer);
// 置換
function JReplaceW(str, sFind, sNew: string): string;
function JReplaceA(str, sFind, sNew: AnsiString): AnsiString;
function JReplace(str, sFind, sNew: AnsiString): AnsiString;
function JReplaceU(str, sFind, sNew: string): string;
function JReplaceOne(str, sFind, sNew: AnsiString): AnsiString;
function JReplace_(str, sFind, sNew: string): string;
// 繰り返し
function RepeatStr(s: AnsiString; count: Integer): AnsiString;

function GetAbsolutePath(soutai, base: string; Delimiter: Char): string;
function SplitChar(delimiter: AnsiChar; str: AnsiString): TStringList;
function SplitCharU(delimiter: Char; str: string): TStringList;

//------------------------------------------------------------------------------
// S_JIS対応コピー
//------------------------------------------------------------------------------
function sjis_copyByte(p: PAnsiChar; count: Integer): AnsiString;
function sjis_copyB(p: PAnsiChar; index, count: Integer): AnsiString;
function Asc(const ch: String): Integer; //文字コードを得る

//------------------------------------------------------------------------------
// 文字種類変換 関連
//------------------------------------------------------------------------------
// 全角変換
function convToFull(const str: AnsiString): AnsiString;
// 半角変換
function convToHalf(const str: AnsiString): AnsiString;
// ひらがな変換
function convToHiragana(const str: AnsiString): AnsiString;
// カタカナ変換
function convToKatakana(const str: AnsiString): AnsiString;
// 大文字変換
function LowerCaseEx(const str: AnsiString): AnsiString;
// 小文字変換
function UpperCaseEx(const str: AnsiString): AnsiString;

// 全部アルファベット？（全角文字がない？）
function IsHalfStr(s: AnsiString): Boolean;
// 全部数値か？
function IsNumber(var s: AnsiString): Boolean;
function IsNumOne(const str: AnsiString): Boolean;
function IsHiragana(const str: AnsiString): Boolean;
function IsKatakana(const str: AnsiString): Boolean;
function IsAlphabet(const str: AnsiString): Boolean;

function URLEncode(s: AnsiString):AnsiString;
function URLDecode(s: AnsiString):AnsiString;

//------------------------------------------------------------------------------
// 各種処理
//------------------------------------------------------------------------------
function ExpandTab(const s: AnsiString; tabCnt: Integer): AnsiString;

// パスの終端に\をつける
function CheckPathYen(s: string): string;

function TrimA(const S: AnsiString): AnsiString;
function UpperCaseA(s: AnsiString): AnsiString;
function IntToStrA(i: Integer): AnsiString;
function FormatA(const Format: AnsiString; const Args: array of const): AnsiString;
function StrToIntDefA(const S: AnsiString; Default: Integer): Integer;
function FloatToStrA(Value: Extended): AnsiString;
function StrToFloatA(const S: AnsiString): Extended;
function IntToHexA(Value: Integer; Digits: Integer): AnsiString;

function CharInSet(c: Char; chars: TChars): Boolean;
function PosEx(sub, s: string; FromI: Integer): Integer;
function TrimCoupleFlag(s: string): string;

{$IFDEF FPC}
const NORM_IGNORECASE = $00000001;           
const NORM_IGNORENONSPACE = $00000002;       
const NORM_IGNORESYMBOLS = $00000004;        
const LCMAP_LOWERCASE = $00000100;           
const LCMAP_UPPERCASE = $00000200;           
const LCMAP_SORTKEY = $00000400;             
const LCMAP_BYTEREV = $00000800;             
const SORT_STRINGSORT = $00001000;           
const NORM_IGNOREKANATYPE = $00010000;       
const NORM_IGNOREWIDTH = $00020000;          
const LCMAP_HIRAGANA = $00100000;            
const LCMAP_KATAKANA = $00200000;            
const LCMAP_HALFWIDTH = $00400000;           
const LCMAP_FULLWIDTH = $00800000;           
const LCMAP_LINGUISTIC_CASING = $01000000;   
const LCMAP_SIMPLIFIED_CHINESE = $02000000;  
const LCMAP_TRADITIONAL_CHINESE = $04000000; 
{$ENDIF}

implementation

function TrimCoupleFlag(s: string): string;
var
  mae, usiro: WideString;
  flg: Boolean;
  ws: WideString;
begin
  s := Trim(s); // ***
  if s = '' then
  begin
    Result := s; Exit;
  end;
  ws := s;
  flg := False;
  begin
    mae   := Copy(ws,1,1);
    usiro := Copy(ws,Length(ws),1);
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
    ws := Copy(ws, Length(mae)+1, Length(ws) - Length(usiro)*2);
    Result := AnsiString(ws);
  end else
  begin
    Result := s;
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

function getChars_s(var s: string; ch: TSysCharSet): string;
var
  p: PChar;
begin
  p := PChar(s);
  Result := getChars(p, ch);
  s := string(p);
end;

// 置換
function JReplace_(str, sFind, sNew: string): string;
begin
  Result := JReplace(str, sFind, sNew);
end;

function PosEx(sub, s: string; FromI: Integer): Integer;
begin
  s := Copy(s, FromI, Length(s));
  Result := Pos(sub, s);
  if Result > 0 then Result := Result + (FromI-1);
end;

function CharInSet(c: Char; chars: TChars): Boolean;
begin
  if c in chars then Result := True else Result := False;
end;

function IntToHexA(Value: Integer; Digits: Integer): AnsiString;
begin
  Result := AnsiString(IntToHex(Value, Digits));
end;

function StrToFloatA(const S: AnsiString): Extended;
begin
  Result := StrToFloat(string(S));
end;

function FloatToStrA(Value: Extended): AnsiString;
var
  Buffer: array[0..63] of Char;
  r: string;
begin
  {$IFDEF Win32}
  SetString(r, Buffer, FloatToText(Buffer, Value, fvExtended,
    ffGeneral, 15, 0));
  {$ELSE}
  SetString(r, Buffer,
      FloatToText(
        Buffer,
        Value, 
        ffGeneral, 15, 0));
  {$ENDIF}
  Result := AnsiString(r);
end;

function StrToIntDefA(const S: AnsiString; Default: Integer): Integer;
var
  E: Integer;
  ss: string;
begin
  ss := string(S);
  Val(ss, Result, E);
  if E <> 0 then Result := Default;
end;

function FormatA(const Format: AnsiString; const Args: array of const): AnsiString;
var
  r: string;
begin
  r := '';
  FmtStr(r, string(Format), Args);
  Result := AnsiString(r);
end;

function IntToStrA(i: Integer): AnsiString;
begin
  Result := AnsiString(IntToStr(i));
end;

function UpperCaseA(s: AnsiString): AnsiString;
var
  i, len, ch: Integer;
const
  CH_A = Ord('a');
  CH_Z = Ord('z');
  TO_UPPER = Ord('A') - Ord('a');
begin
  len := Length(s);
  Result := '';
  SetLength(Result, len);
  i := 1;
  while (i <= len) do
  begin
    ch := Ord(s[i]);
    if ch >= $80 then // LeadBytes
    begin
      Result[i] := s[i]; Inc(i);
      if i <= len then
      begin
        Result[i] := s[i]; Inc(i);
      end;
      continue;
    end;
    if (CH_A <= ch)and(ch <= CH_Z) then
    begin
      Result[i] := AnsiChar(ch + TO_UPPER);
    end else
    begin
      Result[i] := AnsiChar(ch);
    end;
    Inc(i);
  end;
end;

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


function PosA(sub, s:AnsiString):Integer;
begin
  Result := AnsiPos(sub, s);
end;

function TrimA(const S: AnsiString): AnsiString;
{$IFDEF UNICODE}
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] <= ' ') do Inc(I);
  if I > L then Result := '' else
  begin
    while S[L] <= ' ' do Dec(L);
    Result := Copy(S, I, L - I + 1);
  end;
end;
{$ELSE}
begin
  Result := Trim(S);
end;
{$ENDIF}

function URLDecode(s: AnsiString):AnsiString;
var
  Idx: Integer;   // loops thru chars in string
  Hex: AnsiString;    // string of hex characters
  Code: Integer;  // hex character code (-1 on error)
begin
  // Intialise result and string index
  Result := '';
  Idx := 1;
  // Loop thru string decoding each character
  while Idx <= Length(S) do
  begin
    case S[Idx] of
      '%':
      begin
        // % should be followed by two hex digits - exception otherwise
        if Idx <= Length(S) - 2 then
        begin
          // there are sufficient digits - try to decode hex digits
          Hex := S[Idx+1] + S[Idx+2];
          Code := SysUtils.StrToIntDef(string('$' + Hex), -1);
          Inc(Idx, 2);
        end
        else begin
          Code := -1;
        end;
        // check for error and raise exception if found
        if Code = -1 then
          raise SysUtils.EConvertError.Create('Invalid hex digit in URL');
        // decoded OK - add character to result
        Result := Result + AnsiString(Chr(Code));
      end;
      '+':
        // + is decoded as a space
        Result := Result + ' '
      else
        // All other characters pass thru unchanged
        Result := Result + AnsiString(S[Idx]);
    end;
    Inc(Idx);
  end;
end;

function URLEncode(s: AnsiString):AnsiString;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(s) do
  begin
    Result := Result + '%' + AnsiString(IntToHex(Ord(s[i]), 2));
  end;
end;

function IsHiragana(const str: AnsiString): Boolean;
var code: Integer;
begin
    Result := False;
    if Length(str)<2 then Exit;
    code := (Ord(str[1])shl 8) + Ord(str[2]);
    if ($82A0 <= code)and(code <= $833E) then Result := True;
end;

function IsKatakana(const str: AnsiString): Boolean;
var code: Integer;
begin
    Result := False;
    if Length(str)<2 then Exit;
    code := (Ord(str[1])shl 8) + Ord(str[2]);
    if ($8340 <= code)and(code <= $839D) then Result := True;
end;

function IsAlphabet(const str: AnsiString): Boolean;
var s: AnsiString;
begin
  Result := False;
  if str = '' then Exit;
  if str[1] in ['a'..'z','A'..'Z'] then
  begin
    Result := True;
  end else
  begin
    s := convToHalf(Copy(str,1,2)) + ' ';
    if s[1] in ['a'..'z','A'..'Z'] then
    begin
      Result := True;
    end;
  end;
end;

function IsNumOne(const str: AnsiString): Boolean;
var s: AnsiString;
begin
  Result := False;
  if str = '' then Exit;
  if str[1] in ['0'..'9'] then
  begin
    Result := True;
  end else
  begin
    s := convToHalf(Copy(str,1,2)) + ' ';
    if s[1] in ['0'..'9'] then
    begin
      Result := True;
    end;
  end;
end;


// パスの終端に\をつける
function CheckPathYen(s: string): string;
begin
  Result := (IncludeTrailingPathDelimiter(string(s)));
end;


//------------------------------------------------------------------------------
// PAnsiChar 関連
//------------------------------------------------------------------------------
// PAnsiChar から 1文字取り出す
function getOneChar(var p: PAnsiChar): AnsiString;
begin
  if p^ in SJISLeadBytes then
  begin
    Result := p^ + (p+1)^;
    Inc(p, 2);
  end else
  begin
    Result := p^;
    Inc(p);
  end;
end;

// PAnsiChar から 1文字取り出し文字コードで返す
function getOneCharCode(var p: PAnsiChar): Integer;
begin
  if p^ in SJISLeadBytes then
  begin
    Result := Ord(p^) shl 8 + Ord((p+1)^);
    Inc(p, 2);
  end else
  begin
    Result := Ord(p^);
    Inc(p);
  end;
end;

// PAnsiChar で空白文字を飛ばす
procedure skipSpace(var p: PAnsiChar);
begin
  while p^ in [' ',#9] do Inc(p);
end;

// PAnsiChar で特定の文字までを取り出しポインタを進める(返す文字にsplitterを含む)
// もしsplitterがあれば HasSplitter=True を返す
function getToSplitter(var p: PAnsiChar; splitter: AnsiString; var HasSplitter: Boolean): AnsiString;
var sp: PAnsiChar; len: Integer;
begin
  sp := PAnsiChar(splitter); len := Length(splitter);
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

function getToSplitterStr(var s: AnsiString; splitter: AnsiString): AnsiString;
var
  p: PAnsiChar; flg: Boolean;
begin
  p := PAnsiChar(s);
  flg := False;
  Result := getToSplitter(p, splitter, flg);
  s := p;
end;

// 特定の文字列の手前までを取得する
function getToSplitterB(var p: PAnsiChar; splitter: AnsiString): AnsiString;
var
  sp: PAnsiChar; len: Integer;
begin
  sp := PAnsiChar(splitter); len := Length(splitter);
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

// 特定の区切り文字までを取得する（区切り文字は削除する）
function getTokenCh(var p: PAnsiChar; ch: TChars): AnsiString;
begin
  Result := '';
  while p^ <> #0 do
  begin
    if p^ in SJISLeadBytes then
    begin
      Result := Result + p^ + (p+1)^;
      Inc(p, 2); Continue;
    end;

    if p^ in ch then
    begin
      Inc(p);
      Break;
    end;

    Result := Result + p^; Inc(p);
  end;
end;

// 特定の区切り文字までを取得する（区切り文字は削除する）
function getTokenChB2(var p: PAnsiChar; var l: Integer;ch: TChars): AnsiString;
begin
  Result := '';
  while l > 0 do
  begin
    if p^ in ch then
    begin
      Inc(p);
      Dec(l);
      Break;
    end;

    Result := Result + p^; Inc(p);
    Dec(l);
  end;
end;

function getTokenChW(var p: PAnsiChar; ch: TChars): AnsiString;
begin
  Result := '';
  while p^ <> #0 do
  begin
    if p^ in ch then
    begin
      Inc(p);
      Break;
    end;

    Result := Result + p^; Inc(p);
  end;
end;

// 特定の区切り文字までを取得する（区切り文字は削除する）
// 区切り文字が空文字列の時は1文字だけ返す
function getTokenStrU(var p: PChar; splitter: string): string;
var
  sp: PChar;
  len: Integer;
begin
  Result := '';

  sp  := PChar(splitter);
  len := Length(splitter);

  if len = 0 then
  begin
    if p^ <> #0 then
    begin
      begin
        Result := p^; Inc(p);
      end;
    end;
    Exit;
  end;

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

function getTokenStr(var p: PAnsiChar; splitter: AnsiString): AnsiString;
var
  sp: PAnsiChar;
  len: Integer;
begin
  Result := '';

  sp  := PAnsiChar(splitter);
  len := Length(splitter);

  if len = 0 then
  begin
    if p^ <> #0 then
    begin
      if p^ in SJISLeadBytes then
      begin
        Result := p^ + (p+1)^;
        Inc(p, 2);
      end else
      begin
        Result := p^; Inc(p);
      end;
    end;
    Exit;
  end;

  while p^ <> #0 do
  begin

    if StrLComp(p, sp, len) = 0 then
    begin
      Inc(p, len);
      Break;
    end;

    if p^ in SJISLeadBytes then
    begin
      Result := Result + p^ + (p+1)^;
      Inc(p, 2);
    end else
    begin
      Result := Result + p^; Inc(p);
    end;
  end;
end;

// 特定の区切り文字までを取得する（区切り文字は削除する）
function getToken_s(var s: AnsiString; splitter: AnsiString): AnsiString;
var
  ps, pSplitter: PAnsiChar;
  lenS, len, lenSplitter: Integer;
  flg: Boolean;
begin
  // 文字列の長さ最大長まで確認する #0 でも途切れないように
  if splitter = '' then
  begin
    Result := '';
    Exit;
  end;

  lenS        := Length(s);
  lenSplitter := Length(splitter);
  ps        := @s[1];
  pSplitter := @splitter[1];

  flg := False;
  len := 0;
  while len < lenS do
  begin
    // 一致？
    if CompareMem(ps, pSplitter, lenSplitter) then
    begin
      // s=abcd splitter=b
      // lenS=4 lenSplitter=1 len=1
      flg := True;
      Break;
    end;

    if ps^ in SJISLeadBytes then
    begin
      Inc(ps, 2); Inc(len, 2);
    end else
    begin
      Inc(ps); Inc(len);
    end;
  end;

  Result := Copy(s, 1, len);
  if flg then
  begin
    s := Copy(s, len + lenSplitter + 1, lenS - lenSplitter - len);
  end else
  begin
    s := '';
  end;
end;

function getToken_sU(var s: string; splitter: string): string;
var
  ps, pSplitter: PChar;
  lenS, len, lenSplitter: Integer;
  flg: Boolean;
begin
  // 文字列の長さ最大長まで確認する #0 でも途切れないように
  if splitter = '' then
  begin
    Result := '';
    Exit;
  end;

  lenS        := Length(s);
  lenSplitter := Length(splitter);
  ps        := @s[1];
  pSplitter := @splitter[1];

  flg := False;
  len := 0;
  while len < lenS do
  begin
    // 一致？
    if CompareMem(ps, pSplitter, lenSplitter) then
    begin
      // s=abcd splitter=b
      // lenS=4 lenSplitter=1 len=1
      flg := True;
      Break;
    end;

    Inc(ps); Inc(len);
  end;

  Result := Copy(s, 1, len);
  if flg then
  begin
    s := Copy(s, len + lenSplitter + 1, lenS - lenSplitter - len);
  end else
  begin
    s := '';
  end;
end;

// 特定の区切り文字までを取得する（区切り文字は残す）
function getTokenChB(var p: PChar; ch: TSysCharSet): string;
begin
  Result := '';
  while p^ <> #0 do
  begin
    if CharInSet(p^, ch) then
    begin
      Break;
    end;

    Result := Result + p^; Inc(p);
  end;
end;


//------------------------------------------------------------------------------
// 検索取り出し
//------------------------------------------------------------------------------
// 検索
function PosExA(sub, s: AnsiString; FromI: Integer): Integer;
var
  psub, ps: PAnsiChar;
  i, len: Integer;
begin
  // Pos('','ABC') = 0 に習う
  if sub = '' then
  begin
    Result := 0; Exit;
  end;
  
  if FromI <= 0 then FromI := 1;
  s := CopyA(s, FromI, Length(s)); // 切り出し

  psub := PAnsiChar(sub);
  ps   := PAnsiChar(s);
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
    if ps^ in SJISLeadBytes then
    begin
      Inc(ps, 2);
    end else
    begin
      Inc(ps);
    end;
  end;
end;

function PosExA2(sub, s: AnsiString; FromI: Integer): Integer;
begin
  s := Copy(s, FromI, Length(s));
  Result := Pos(sub, s);
  if Result > 0 then Result := Result + (FromI-1);
end;

// コピー
function CopyA(s: AnsiString; i, count: Integer): AnsiString;
var
  p: PAnsiChar;
  idx, idxFrom, idxTo: Integer;
  c: AnsiString;
begin
  p := PAnsiChar(s);
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

function Right (s: AnsiString; count: Integer): AnsiString;
var
  len: Integer;
begin
  // 123456| right(s, 3) | 456
  len := Length(s);
  Result := Copy(s, len - count + 1, count);
end;

function JRight(s: AnsiString; count: Integer): AnsiString;
var
  len: Integer;
begin
  // RIGHT(abcde, 3) = cde
  //
  len := JLength(s);
  Result := CopyA(s, len - count + 1, count);
end;

// 文字数取得
function JLength(s: AnsiString): Integer;
var
  p: PAnsiChar;
begin
  p := PAnsiChar(s);
  Result := 0;
  while p^ <> #0 do
  begin
    getOneChar(p);
    Inc(Result);
  end;
end;

// 文字削除
procedure JDelete(var s: AnsiString; i, count: Integer);
var
  idx, idxFrom, idxTo: Integer;
  p: PAnsiChar;
  des, c: AnsiString;
begin
  idx := 0;
  idxFrom := i;
  idxTo   := idxFrom + count - 1;
  p := PAnsiChar(s);
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
function JReplaceW(str, sFind, sNew: string): string;
var
  p, pFind: PChar;
  i, len,slen: Integer;
  c: string;
begin
  Result := '';

  if str = '' then
    Exit;// 置換対象がない
  if sFind = '' then
  begin
    Result := str;
    Exit;// 検索対象がない
  end;

  p      := PChar(str);
  pFind  := PChar(sFind);
  len    := Length(sFind);
  slen   := Length(str);

  i := 0;
  while (i + len) <= slen do//最後のlenより短い部分文字列には存在し得ないので
  begin
    // 検索語に合致するか？
    if (StrLComp(p, pFind, len) = 0) then
    begin
      Result := Result + sNew;
      Inc(p, len);
      Inc(i, len);
      Continue;
    end;
    // 合致しなければそのままを返す
    c := p^; Inc(p);
    Result := Result + c;
    Inc(i, Length(c));
  end;
  //残りをつなげる
  Result := Result + Copy(p,1,slen-i);
end;

function JReplaceA(str, sFind, sNew: AnsiString): AnsiString;
var
  p, pFind: PAnsiChar;
  i, len,slen: Integer;
  c: AnsiString;
begin
  Result := '';

  if str = '' then
    Exit;// 置換対象がない
  if sFind = '' then
  begin
    Result := str;
    Exit;// 検索対象がない
  end;

  p      := PAnsiChar(str);
  pFind  := PAnsiChar(sFind);
  len    := Length(sFind);
  slen   := Length(str);

  i := 0;
  while (i + len) <= slen do//最後のlenより短い部分文字列には存在し得ないので
  begin
    // 検索語に合致するか？
    if (StrLComp(p, pFind, len) = 0) then
    begin
      Result := Result + sNew;
      Inc(p, len);
      Inc(i, len);
      Continue;
    end;
    // 合致しなければそのままを返す
    c := getOneChar(p);
    Result := Result + c;
    Inc(i, Length(c));
  end;
  //残りをつなげる
  Result := Result + Copy(p,1,slen-i);
end;

function JReplace(str, sFind, sNew: AnsiString): AnsiString;
begin
  Result := JReplaceA(str, sFind, sNew);
end;

function JReplaceU(str, sFind, sNew: string): string;
begin
  Result := JReplaceW(str, sFind, sNew);
end;


function JReplaceOne(str, sFind, sNew: AnsiString): AnsiString;
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

function RepeatStr(s: AnsiString; count: Integer): AnsiString;
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

function SplitChar(delimiter: AnsiChar; str: AnsiString): TStringList;
var
  p: PAnsiChar; s: AnsiString;
begin
  Result := TStringList.Create ;
  p := PAnsiChar(str);
  while p^ <> #0 do
  begin
    s := getTokenStr(p, delimiter);
    Result.Add(s);
  end;
end;

function SplitCharU(delimiter: Char; str: string): TStringList;
var
  p: PChar; s: string;
begin
  Result := TStringList.Create ;
  p := PChar(str);
  while p^ <> #0 do
  begin
    s := getTokenStrU(p, delimiter);
    Result.Add(s);
  end;
end;


function GetAbsolutePath(soutai, base: string; Delimiter: Char): string;
var
  slSoutai, slBase: TStringList;
  rel, s, protocol, domain, root: string;
  i: Integer;
begin
  // 不要の場合
  if Delimiter = '/' then
  begin
    i := Pos('/', string(soutai));
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

  // 基本パスには必ず / をつける
  if Copy(base,Length(base),1) <> Delimiter then
  begin
    base := base + Delimiter;
  end;
  // 相対パスの 1文字目に / があればルートからの指定になる
  if Copy(soutai, 1,1) = Delimiter then
  begin
    // ROOT を得る
    if Delimiter = '/' then
    begin
      // http://www.xxx.com/aa/bb
      protocol := getToken_s(base, '//');
      domain   := getToken_s(base, '/');
      Result := protocol + '//' + domain + soutai;
      Exit;
    end else
    begin
      // c:\a\b\c
      root := getToken_sU(base, Delimiter);
      Result := root + soutai;
      Exit;
    end;
  end;

  slSoutai := SplitChar(Delimiter, soutai);
  slBase   := SplitChar(Delimiter, base);
  try
    while (slSoutai.Count >= 1) and (slBase.Count >= 1) do
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
    //
    for i := 0 to slSoutai.Count - 1 do
    begin
      s := slSoutai.Strings[i];
      Result := Result + s + Delimiter;
    end;
    //
    if Copy(Result, Length(Result), 1) = Delimiter then
    begin
      System.Delete(Result, Length(Result), 1);
    end;
  finally
    slBase.Free;
    slSoutai.Free;
  end;
end;

//------------------------------------------------------------------------------
// S_JIS対応コピー
//------------------------------------------------------------------------------
function sjis_copyByte(p: PAnsiChar; count: Integer): AnsiString;
var
  i: Integer;
begin
  Result := '';
  i := 0;
  while p^ <> #0 do
  begin
    if p^ in SJISLeadBytes then
    begin
      if (i+2) > count then Break; // バイト数を飛び出すなら抜ける
      Result := Result + p^ + (p+1)^;
      Inc(p, 2);
    end else
    begin
      Result := Result + p^;
      Inc(i); Inc(p);
    end;
    if i >= count then Break;
  end;
end;

function sjis_copyB(p: PAnsiChar; index, count: Integer): AnsiString;
var
  i: Integer;
  c: AnsiString;
  rFrom, rTo: Integer;
begin
  Result := '';
  rFrom := index - 1;
  rTo   := rFrom + count;
  i := 0;
  while p^ <> #0 do
  begin
    c := getOneChar(p);
    if (rFrom <= i)and(i <= rTo) then
    begin
      // 範囲の途中で欠けないかチェック
      if (i+Length(c)) <= rTo then
        Result := Result + c;
    end else
    if i > rTo then Break;
    Inc(i, Length(c));
  end;
end;

function Asc(const ch: String): Integer; //文字コードを得る
begin
    if ch = '' then begin
        Result := 0;
        Exit;
    end;

    if ch[1] in SJISLeadBytes then
    begin
        Result := (Ord(ch[1]) shl 8) + Ord(ch[2]);
    end else
        Result := Ord(ch[1]);
end;


//------------------------------------------------------------------------------
// 文字種類変換 関連
//------------------------------------------------------------------------------
function LCMapStringEx(const str: AnsiString; MapFlag: DWORD): AnsiString;
{$IFDEF Win32}
var
  pDes: PAnsiChar;
  len,len2: Integer;
begin
  if str='' then begin Result := ''; Exit; end;
  len  := Length(str);
  len2 := len*2+2;
  GetMem(pDes, len2);//half -> full
  try
    FillChar( pDes^, len2, 0 );
    LCMapStringA( LOCALE_SYSTEM_DEFAULT, MapFlag, PAnsiChar(str), len, pDes, len2-1);
    Result := AnsiString( pDes );
  finally
    FreeMem(pDes);
  end;
end;
{$ELSE}
begin
  //todo: 文字種類変換
  Result := str;
end;
{$ENDIF}

function LCMapStringExHalf(const str: AnsiString; MapFlag: DWORD): AnsiString;
{$IFDEF Win32}
var
  pDes: PAnsiChar;
  len,len2: Integer;
begin
  if str='' then begin Result := ''; Exit; end;
  len  := Length(str);
  len2 := len+2;
  GetMem(pDes, len2);
  try
    FillChar( pDes^, len2, 0 );
    LCMapStringA( LOCALE_SYSTEM_DEFAULT, MapFlag, PAnsiChar(str), len, pDes, len2-1);
    Result := AnsiString( pDes );
  finally
    FreeMem(pDes);
  end;
end;
{$ELSE}
begin
  // todo: 変換
  Result := str;
end;
{$ENDIF}

function convToFull(const str: AnsiString): AnsiString;
begin
  Result := LCMapStringEx( str, LCMAP_FULLWIDTH );
end;
function convToHalf(const str: AnsiString): AnsiString;
begin
  Result := LCMapStringEx( str, LCMAP_HALFWIDTH );
end;
{ひらがな・カタカナの変換}
function convToHiragana(const str: AnsiString): AnsiString;
begin
  Result := LCMapStringEx( str, LCMAP_HIRAGANA );
end;
function convToKatakana(const str: AnsiString): AnsiString;
begin
  Result := LCMapStringEx( str, LCMAP_KATAKANA );
end;
// {マルチバイトを考慮した大文字、小文字化}
function LowerCaseEx(const str: AnsiString): AnsiString;
begin
  Result := LCMapStringExHalf( str, LCMAP_LOWERCASE );
end;
function UpperCaseEx(const str: AnsiString): AnsiString;
begin
  Result := LCMapStringExHalf( str, LCMAP_UPPERCASE );
end;

function IsHalfStr(s: AnsiString): Boolean;
var i: Integer;
begin
  Result := True;
  for i := 1 to Length(s) do
  begin
    if s[i] in SJISLeadBytes then
    begin
      Result := False; Exit;
    end;
  end;
end;

// 全部数値か？
function IsNumber(var s: AnsiString): Boolean;
var
  i: Integer;
  tmp: AnsiString;
begin
  if s = '' then begin Result := False; Exit; end;
  
  Result := True;
  tmp := convToHalf(s);

  i := 1;
  // -2.25e+6
  // +|-
  if tmp[i] in ['+','-'] then
  begin
    Inc(i);
  end else
  if tmp[i] = '$' then
  begin
    Inc(i);
  end;

  if i > Length(tmp) then
  begin
    Result := False; Exit;
  end;

  // 実数
  while i <= Length(tmp) do
  begin
    if tmp[i] in ['0'..'9'] then
    begin
      Inc(i);
    end else
    if tmp[i] = '.' then
    begin
      Break;
    end else
    begin
      Result := False; Exit; // NG
    end;
  end;
  // 実数
  if (i <= Length(tmp))and(tmp[i] = '.') then
  begin
    Inc(i);
    // "."の後ろに数字がないとNG
    if i > Length(tmp) then
    begin
      Result := False; Exit;
    end;
    // 実数部
    while i <= Length(tmp) do
    begin
      if tmp[i] in ['0'..'9'] then
      begin
        Inc(i);
      end else
      if tmp[i] in ['e','E'] then
      begin
        Break;
      end else
      begin
        Result := False; Exit;
      end;
    end;
    // 指数表記か？
    if (i <= Length(tmp))and(tmp[i] in ['e','E']) then
    begin
      Inc(i);
      if (i <= Length(tmp))and(tmp[i] in ['+','-']) then
      begin
        Inc(i);
        // "+|-"の後ろに数字がないとNG
        if i > Length(tmp) then
        begin
          Result := False; Exit;
        end;
        // 指数部
        while i <= Length(tmp) do
        begin
          if tmp[i] in ['0'..'9'] then
          begin
            Inc(i);
          end else
          begin
            Result := False; Exit;
          end;
        end;
      end else
      begin
        Result := False; Exit;
      end;
    end;
  end;
  // 結果が数値なら半角に直したものを返す
  if Result then s := tmp;
end;

//------------------------------------------------------------------------------
// 各種処理
//------------------------------------------------------------------------------
function ExpandTab(const s: AnsiString; tabCnt: Integer): AnsiString;
var
  p: PAnsiChar;
  cnt, spc: Integer;
  i: Integer;
begin
  Result := '';
  p := PAnsiChar(s);
  cnt := 0;
  while (p^ <> #0) do
  begin
    if p^ in SJISLeadBytes then
    begin
      Result := Result + p^ + (p+1)^;
      Inc(cnt, 2);
      Inc(p, 2);
      Continue;
    end;
    case p^ of
      #13,#10:
        begin
          Result := Result + p^;
          cnt := 0;
          Inc(p);
          Continue;
        end;
      #9:
        begin
          spc := cnt mod tabCnt;
          spc := tabCnt - spc;
          for i := 1 to spc do
          begin
            Result := Result + ' ';
            Inc(cnt);
          end;
          Inc(p);
        end;
      else
        begin
          Result := Result + p^;
          Inc(p);
          Inc(cnt);
        end;
    end;
  end;
end;

end.
