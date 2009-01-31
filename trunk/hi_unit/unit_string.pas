unit unit_string;
//------------------------------------------------------------------------------
// �����񏈗��Ɋւ���ėp�I�ȃ��j�b�g
// [�쐬] �N�W����s��
// [�A��] http://kujirahand.com
// [���t] 2004/07/26
//
// �����R�[�h: SHIFT-JIS ��Ώ�
//
interface

uses
  Windows, SysUtils, hima_types;

type
  TChars = set of AnsiChar;

//------------------------------------------------------------------------------
// PAnsiChar �֘A
//------------------------------------------------------------------------------
// PAnsiChar ���� 1�������o��
function getOneChar(var p: PAnsiChar): AnsiString;
// PAnsiChar ���� 1�������o�������R�[�h�ŕԂ��|�C���^��i�߂�
function getOneCharCode(var p: PAnsiChar): Integer;
// PAnsiChar �ŋ󔒕������΂��|�C���^��i�߂�
procedure skipSpace(var p: PAnsiChar);
// PAnsiChar �œ���̕����܂ł����o���|�C���^��i�߂�(�Ԃ�������splitter���܂�)
// ����splitter������� HasSplitter=True ��Ԃ�
function getToSplitter(var p: PAnsiChar; splitter: AnsiString; var HasSplitter: Boolean): AnsiString;
function getToSplitterStr(var s: AnsiString; splitter: AnsiString): AnsiString;
// ����̕�����̎�O�܂ł��擾����
function getToSplitterB(var p: PAnsiChar; splitter: AnsiString): AnsiString;
// ����̋�؂蕶���܂ł��擾����i��؂蕶���͍폜����j
function getTokenCh(var p: PAnsiChar; ch: TChars): AnsiString;
// ����̋�؂蕶���܂ł��擾����i��؂蕶���͍폜����j
function getTokenStr(var p: PAnsiChar; splitter: AnsiString): AnsiString;
// ����̋�؂蕶���܂ł��擾����i��؂蕶���͍폜����j
function getToken_s(var s: AnsiString; splitter: AnsiString): AnsiString;

//------------------------------------------------------------------------------
// �������o��
//------------------------------------------------------------------------------
// ����
function JPos(sub, s: AnsiString): Integer;
function JPosEx(sub, s: AnsiString; FromI: Integer): Integer;
function PosEx(sub, s: AnsiString; FromI: Integer): Integer;

// �R�s�[
function JCopy (s: AnsiString; i, count: Integer): AnsiString;
function JRight(s: AnsiString; count: Integer): AnsiString;
function Right (s: AnsiString; count: Integer): AnsiString;
// �������擾
function JLength(s: AnsiString): Integer;
// �����폜
procedure JDelete(var s: AnsiString; i, count: Integer);
// �u��
function JReplace(str, sFind, sNew: AnsiString): AnsiString;
function JReplaceOne(str, sFind, sNew: AnsiString): AnsiString;
// �J��Ԃ�
function RepeatStr(s: AnsiString; count: Integer): AnsiString;

function GetAbsolutePath(soutai, base: AnsiString; Delimiter: AnsiChar): AnsiString;
function SplitChar(delimiter: AnsiChar; str: AnsiString): THStringList;

//------------------------------------------------------------------------------
// S_JIS�Ή��R�s�[
//------------------------------------------------------------------------------
function sjis_copyByte(p: PAnsiChar; count: Integer): AnsiString;
function sjis_copyB(p: PAnsiChar; index, count: Integer): AnsiString;
function Asc(const ch: AnsiString): Integer; //�����R�[�h�𓾂�

//------------------------------------------------------------------------------
// ������ޕϊ� �֘A
//------------------------------------------------------------------------------
// �S�p�ϊ�
function convToFull(const str: AnsiString): AnsiString;
// ���p�ϊ�
function convToHalf(const str: AnsiString): AnsiString;
// �Ђ炪�ȕϊ�
function convToHiragana(const str: AnsiString): AnsiString;
// �J�^�J�i�ϊ�
function convToKatakana(const str: AnsiString): AnsiString;
// �啶���ϊ�
function LowerCaseEx(const str: AnsiString): AnsiString;
// �������ϊ�
function UpperCaseEx(const str: AnsiString): AnsiString;

// �S���A���t�@�x�b�g�H�i�S�p�������Ȃ��H�j
function IsHalfStr(s: AnsiString): Boolean;
// �S�����l���H
function IsNumber(var s: AnsiString): Boolean;
function IsNumOne(const str: AnsiString): Boolean;
function IsHiragana(const str: AnsiString): Boolean;
function IsKatakana(const str: AnsiString): Boolean;
function IsAlphabet(const str: AnsiString): Boolean;

function URLEncode(s: AnsiString):string;
function URLDecode(s: AnsiString):string;

//------------------------------------------------------------------------------
// �e�폈��
//------------------------------------------------------------------------------
function ExpandTab(const s: AnsiString; tabCnt: Integer): AnsiString;

// �p�X�̏I�[��\������
function CheckPathYen(s: AnsiString): string;

implementation

function URLDecode(s: AnsiString):string;
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
        Result := Result + Chr(Code);
      end;
      '+':
        // + is decoded as a space
        Result := Result + ' '
      else
        // All other characters pass thru unchanged
        Result := Result + string(S[Idx]);
    end;
    Inc(Idx);
  end;
end;

function URLEncode(s: AnsiString):string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(s) do
  begin
    Result := Result + '%' + IntToHex(Ord(s[i]), 2);
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


// �p�X�̏I�[��\������
function CheckPathYen(s: AnsiString): string;
begin
  Result := IncludeTrailingPathDelimiter(string(s));
end;


//------------------------------------------------------------------------------
// PAnsiChar �֘A
//------------------------------------------------------------------------------
// PAnsiChar ���� 1�������o��
function getOneChar(var p: PAnsiChar): AnsiString;
begin
  if p^ in SysUtils.LeadBytes then
  begin
    Result := p^ + (p+1)^;
    Inc(p, 2);
  end else
  begin
    Result := p^;
    Inc(p);
  end;
end;

// PAnsiChar ���� 1�������o�������R�[�h�ŕԂ�
function getOneCharCode(var p: PAnsiChar): Integer;
begin
  if p^ in SysUtils.LeadBytes then
  begin
    Result := Ord(p^) shl 8 + Ord((p+1)^);
    Inc(p, 2);
  end else
  begin
    Result := Ord(p^);
    Inc(p);
  end;
end;

// PAnsiChar �ŋ󔒕������΂�
procedure skipSpace(var p: PAnsiChar);
begin
  while p^ in [' ',#9] do Inc(p);
end;

// PAnsiChar �œ���̕����܂ł����o���|�C���^��i�߂�(�Ԃ�������splitter���܂�)
// ����splitter������� HasSplitter=True ��Ԃ�
function getToSplitter(var p: PAnsiChar; splitter: AnsiString; var HasSplitter: Boolean): AnsiString;
var sp: PAnsiChar; len: Integer;
begin
  sp := PAnsiChar(splitter); len := Length(splitter);
  HasSplitter := False;
  Result := '';
  while p^ <> #0 do
  begin
    if StrLComp(p, sp, len) = 0 then // ���v������
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
  Result := getToSplitter(p, splitter, flg);
  s := p;
end;

// ����̕�����̎�O�܂ł��擾����
function getToSplitterB(var p: PAnsiChar; splitter: AnsiString): AnsiString;
var
  sp: PAnsiChar; len: Integer;
begin
  sp := PAnsiChar(splitter); len := Length(splitter);
  Result := '';
  while p^ <> #0 do
  begin
    if StrLComp(p, sp, len) = 0 then // ���v������
    begin
      Break;
    end;
    Result := Result + getOneChar(p);
  end;
end;

// ����̋�؂蕶���܂ł��擾����i��؂蕶���͍폜����j
function getTokenCh(var p: PAnsiChar; ch: TChars): AnsiString;
begin
  Result := '';
  while p^ <> #0 do
  begin
    if p^ in SysUtils.LeadBytes then
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

// ����̋�؂蕶���܂ł��擾����i��؂蕶���͍폜����j
// ��؂蕶�����󕶎���̎���1���������Ԃ�
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
      if p^ in SysUtils.LeadBytes then
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

    if p^ in SysUtils.LeadBytes then
    begin
      Result := Result + p^ + (p+1)^;
      Inc(p, 2);
    end else
    begin
      Result := Result + p^; Inc(p);
    end;
  end;
end;

// ����̋�؂蕶���܂ł��擾����i��؂蕶���͍폜����j
function getToken_s(var s: AnsiString; splitter: AnsiString): AnsiString;
var
  ps, pSplitter: PAnsiChar;
  lenS, len, lenSplitter: Integer;
  flg: Boolean;
begin
  // ������̒����ő咷�܂Ŋm�F���� #0 �ł��r�؂�Ȃ��悤��
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
    // ��v�H
    if CompareMem(ps, pSplitter, lenSplitter) then
    begin
      // s=abcd splitter=b
      // lenS=4 lenSplitter=1 len=1
      flg := True;
      Break;
    end;

    if ps^ in LeadBytes then
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

//------------------------------------------------------------------------------
// �������o��
//------------------------------------------------------------------------------
// ����
function JPos(sub, s: AnsiString): Integer;
var
  psub, ps: PAnsiChar;
  i, len: Integer;
begin
  // Pos('','ABC') = 0 �ɏK��
  if sub = '' then
  begin
    Result := 0; Exit;
  end;
  psub := PAnsiChar(sub);
  ps   := PAnsiChar(s);
  len  := Length(sub);
  Result := 0; i := 0;
  while ps^ <> #0 do
  begin
    // ��v�������H
    if StrLComp(ps, psub, len) = 0 then
    begin
      Result := i + 1; Break;
    end;
    // ��v���Ȃ��Ȃ�Έꕶ�����炵�Č������s
    Inc(i);
    if ps^ in LeadBytes then
    begin
      Inc(ps, 2);
    end else
    begin
      Inc(ps);
    end;
  end;
end;

function JPosEx(sub, s: AnsiString; FromI: Integer): Integer;
var
  psub, ps: PAnsiChar;
  i, len: Integer;
begin
  // Pos('','ABC') = 0 �ɏK��
  if sub = '' then
  begin
    Result := 0; Exit;
  end;
  
  if FromI <= 0 then FromI := 1;
  s := JCopy(s, FromI, Length(s)); // �؂�o��

  psub := PAnsiChar(sub);
  ps   := PAnsiChar(s);
  len  := Length(sub);
  Result := 0; i := 0;
  while ps^ <> #0 do
  begin
    // ��v�������H
    if StrLComp(ps, psub, len) = 0 then
    begin
      Result := (FromI-1) + i + 1; Break;
    end;
    // ��v���Ȃ��Ȃ�Έꕶ�����炵�Č������s
    Inc(i);
    if ps^ in LeadBytes then
    begin
      Inc(ps, 2);
    end else
    begin
      Inc(ps);
    end;
  end;
end;

function PosEx(sub, s: AnsiString; FromI: Integer): Integer;
begin
  s := Copy(s, FromI, Length(s));
  Result := Pos(sub, s);
  if Result > 0 then Result := Result + (FromI-1);
end;

// �R�s�[
function JCopy(s: AnsiString; i, count: Integer): AnsiString;
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
    if idxTo < idx then Break; // �擾�͈͂𒴂����甲����

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
  Result := JCopy(s, len - count + 1, count);
end;

// �������擾
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

// �����폜
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
      // ���̊Ԃ��폜
    end else
    begin
      des := des + c;
    end;
  end;
  s := des;
end;

// �u��
function JReplace(str, sFind, sNew: AnsiString): AnsiString;
var
  p, pFind: PAnsiChar;
  i, len,slen: Integer;
  c: AnsiString;
begin
  Result := '';

  if str = '' then
    Exit;// �u���Ώۂ��Ȃ�
  if sFind = '' then
  begin
    Result := str;
    Exit;// �����Ώۂ��Ȃ�
  end;

  p      := PAnsiChar(str);
  pFind  := PAnsiChar(sFind);
  len    := Length(sFind);
  slen   := Length(str);

  i := 0;
  while (i + len) <= slen do//�Ō��len���Z������������ɂ͑��݂����Ȃ��̂�
  begin
    // ������ɍ��v���邩�H
    if (StrLComp(p, pFind, len) = 0) then
    begin
      Result := Result + sNew;
      Inc(p, len);
      Inc(i, len);
      Continue;
    end;
    // ���v���Ȃ���΂��̂܂܂�Ԃ�
    c := getOneChar(p);
    Result := Result + c;
    Inc(i, Length(c));
  end;
  //�c����Ȃ���
  Result := Result + Copy(p,1,slen-i);
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

  // �̈���m��
  len := Length(s);
  SetLength(Result, count * len);

  // �J��Ԃ�
  for i := 0 to count - 1 do
  begin
    Move(s[1], Result[i * len + 1], len);
  end;
end;

function SplitChar(delimiter: AnsiChar; str: AnsiString): THStringList;
var
  p: PAnsiChar; s: AnsiString;
begin
  Result := THStringList.Create ;
  p := PAnsiChar(str);
  while p^ <> #0 do
  begin
    s := getTokenStr(p, delimiter);
    Result.Add(s); 
  end;
end;

function GetAbsolutePath(soutai, base: AnsiString; Delimiter: AnsiChar): AnsiString;
var
  slSoutai, slBase: THStringList;
  rel, s, protocol, domain, root: AnsiString;
  i: Integer;
begin
  // �s�v�̏ꍇ
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

  // ��{�p�X�ɂ͕K�� / ������
  if Copy(base,Length(base),1) <> Delimiter then
  begin
    base := base + Delimiter;
  end;
  // ���΃p�X�� 1�����ڂ� / ������΃��[�g����̎w��ɂȂ�
  if Copy(soutai, 1,1) = Delimiter then
  begin
    // ROOT �𓾂�
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
      root := getToken_s(base, Delimiter);
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
// S_JIS�Ή��R�s�[
//------------------------------------------------------------------------------
function sjis_copyByte(p: PAnsiChar; count: Integer): AnsiString;
var
  i: Integer;
begin
  Result := '';
  i := 0;
  while p^ <> #0 do
  begin
    if p^ in SysUtils.LeadBytes then
    begin
      if (i+2) > count then Break; // �o�C�g�����яo���Ȃ甲����
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
      // �͈͂̓r���Ō����Ȃ����`�F�b�N
      if (i+Length(c)) <= rTo then
        Result := Result + c;
    end else
    if i > rTo then Break;
    Inc(i, Length(c));
  end;
end;

function Asc(const ch: AnsiString): Integer; //�����R�[�h�𓾂�
begin
    if ch = '' then begin
        Result := 0;
        Exit;
    end;

    if ch[1] in LeadBytes then
    begin
        Result := (Ord(ch[1]) shl 8) + Ord(ch[2]);
    end else
        Result := Ord(ch[1]);
end;


//------------------------------------------------------------------------------
// ������ޕϊ� �֘A
//------------------------------------------------------------------------------
function LCMapStringEx(const str: AnsiString; MapFlag: DWORD): AnsiString;
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

function LCMapStringExHalf(const str: AnsiString; MapFlag: DWORD): AnsiString;
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
function convToFull(const str: AnsiString): AnsiString;
begin
  Result := LCMapStringEx( str, LCMAP_FULLWIDTH );
end;
function convToHalf(const str: AnsiString): AnsiString;
begin
  Result := LCMapStringEx( str, LCMAP_HALFWIDTH );
end;
{�Ђ炪�ȁE�J�^�J�i�̕ϊ�}
function convToHiragana(const str: AnsiString): AnsiString;
begin
  Result := LCMapStringEx( str, LCMAP_HIRAGANA );
end;
function convToKatakana(const str: AnsiString): AnsiString;
begin
  Result := LCMapStringEx( str, LCMAP_KATAKANA );
end;
{�}���`�o�C�g���l�������啶���A��������}
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
    if s[i] in SysUtils.LeadBytes then
    begin
      Result := False; Exit;
    end;
  end;
end;

// �S�����l���H
function IsNumber(var s: AnsiString): Boolean;
var
  i: Integer;
  tmp: AnsiString;
begin
  if s = '' then begin Result := False; Exit; end;
  if Length(s) > 12 then begin Result := False; Exit; end;

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

  // ����
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
  // ����
  if (i <= Length(tmp))and(tmp[i] = '.') then
  begin
    Inc(i);
    // "."�̌��ɐ������Ȃ���NG
    if i > Length(tmp) then
    begin
      Result := False; Exit;
    end;
    // ������
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
    // �w���\�L���H
    if (i <= Length(tmp))and(tmp[i] in ['e','E']) then
    begin
      Inc(i);
      if (i <= Length(tmp))and(tmp[i] in ['+','-']) then
      begin
        Inc(i);
        // "+|-"�̌��ɐ������Ȃ���NG
        if i > Length(tmp) then
        begin
          Result := False; Exit;
        end;
        // �w����
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
  // ���ʂ����l�Ȃ甼�p�ɒ��������̂�Ԃ�
  if Result then s := tmp;
end;

//------------------------------------------------------------------------------
// �e�폈��
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
    if p^ in SysUtils.LeadBytes then
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