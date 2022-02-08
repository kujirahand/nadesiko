unit unit_string2;
//------------------------------------------------------------------------------
// �����񏈗��Ɋւ���ėp�I�ȃ��j�b�g(Classes ���p��)
// [�쐬] �N�W����s��
// [�A��] http://kujirahand.com/
// [���t] 2004/07/26
//
// �����R�[�h: SHIFT-JIS ��Ώ�
//
interface

uses
  Windows, SysUtils, Classes;

//------------------------------------------------------------------------------
// PChar �֘A
//------------------------------------------------------------------------------
// PChar ���� 1�������o��
function getOneChar(var p: PChar): string;
// PChar ���� 1�������o�������R�[�h�ŕԂ��|�C���^��i�߂�
function getOneCharCode(var p: PChar): Integer;
// PChar �ŋ󔒕������΂��|�C���^��i�߂�
procedure skipSpace(var p: PChar);
// PChar �œ���̕����܂ł����o���|�C���^��i�߂�(�Ԃ�������splitter���܂�)
// ����splitter������� HasSplitter=True ��Ԃ�
function getToSplitter(var p: PChar; splitter: string; var HasSplitter: Boolean): string;
function getToSplitterStr(var s: string; splitter: string): string;
function getToSplitterCh(var p: PChar; splitter: TSysCharSet; var HasSplitter: Boolean): string;
// ����̕�����̎�O�܂ł��擾����
function getToSplitterB(var p: PChar; splitter: string): string;
// ����̋�؂蕶���܂ł��擾����i��؂蕶���͍폜����j
function getTokenCh(var p: PChar; ch: TSysCharSet): string;
// ����̋�؂蕶���܂ł��擾����i��؂蕶���͎c���j
function getTokenChB(var p: PChar; ch: TSysCharSet): string;
// ����̋�؂蕶���܂ł��擾����i��؂蕶���͍폜����j
function getTokenStr(var p: PChar; splitter: string): string;
// �����Chars���擾����
function getChars(var p: PChar; ch: TSysCharSet): string;

//------------------------------------------------------------------------------
// ������֘A
//------------------------------------------------------------------------------
// ����̋�؂蕶���܂ł��擾����i��؂蕶���͍폜����j
function getToken_s(var s: string; splitter: string): string;
// �����Chars�̊Ԃ��擾����
function getChars_s(var s: string; ch: TSysCharSet): string;

//------------------------------------------------------------------------------
// �������o��
//------------------------------------------------------------------------------
// ����
function JPos(sub, s: string): Integer;
function JPosEx(sub, s: string; FromI: Integer): Integer;
function PosEx(sub, s: string; FromI: Integer): Integer;

// �R�s�[
function JCopy (s: string; i, count: Integer): string;
function JRight(s: string; count: Integer): string;
function Right (s: string; count: Integer): string;
// �������擾
function JLength(s: string): Integer;
// �����폜
procedure JDelete(var s: string; i, count: Integer);
// �u��
function JReplace(str, sFind, sNew: string): string;
function JReplace_(str, sFind, sNew: string): string;
function JReplaceOne(str, sFind, sNew: string): string;
// �J��Ԃ�
function RepeatStr(s: string; count: Integer): string;

//------------------------------------------------------------------------------
// S_JIS�Ή��R�s�[
//------------------------------------------------------------------------------
function sjis_copyByte(var p: PChar; count: Integer): string;
function Asc(const ch: string): Integer; //�����R�[�h�𓾂�

//------------------------------------------------------------------------------
// ������ޕϊ� �֘A
//------------------------------------------------------------------------------
// �S�p�ϊ�
function convToFull(const str: string): string;
// ���p�ϊ�
function convToHalf(const str: string): string;
// �Ђ炪�ȕϊ�
function convToHiragana(const str: string): string;
// �J�^�J�i�ϊ�
function convToKatakana(const str: string): string;
// �������ϊ�
function LowerCaseEx(const str: string): string;
// �啶���ϊ�
function UpperCaseEx(const str: string): string;


//------------------------------------------------------------------------------
// �e�폈��
//------------------------------------------------------------------------------
function ExpandTab(s: string; tabCnt: Integer): string;
function TrimCoupleFlag(s: string): string;

{$IF RTLVersion < 20}
type TChars = set of AnsiChar;
function CharInSet(c: Char; chars: TChars): Boolean;
{$IFEND}


implementation
uses
  unit_string;

{$IF RTLVersion < 20}
function CharInSet(c: Char; chars: TChars): Boolean;
begin
  if c in chars then Result := True else Result := False;
end;
{$IFEND}

//------------------------------------------------------------------------------
// PChar �֘A
//------------------------------------------------------------------------------
// PChar ���� 1�������o��
function getOneChar(var p: PChar): string;
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

// PChar ���� 1�������o�������R�[�h�ŕԂ�
function getOneCharCode(var p: PChar): Integer;
begin
  begin
    Result := Ord(p^);
    Inc(p);
  end;
end;

// PChar �ŋ󔒕������΂�
procedure skipSpace(var p: PChar);
begin
  while CharInSet(p^, [' ',#9]) do Inc(p);
end;

// PChar �œ���̕����܂ł����o���|�C���^��i�߂�(�Ԃ�������splitter���܂�)
// ����splitter������� HasSplitter=True ��Ԃ�
function getToSplitter(var p: PChar; splitter: string; var HasSplitter: Boolean): string;
var sp: PChar; len: Integer;
begin
  sp := PChar(splitter); len := Length(splitter);
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

function getToSplitterStr(var s: string; splitter: string): string;
var
  p: PChar; flg: Boolean;
begin
  p := PChar(s);
  Result := getToSplitter(p, splitter, flg);
  s := p;
end;

// ����̕�����̎�O�܂ł��擾����
function getToSplitterB(var p: PChar; splitter: string): string;
var
  sp: PChar; len: Integer;
begin
  sp := PChar(splitter); len := Length(splitter);
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

function getToSplitterCh(var p: PChar; splitter: TSysCharSet; var HasSplitter: Boolean): string;
begin
  HasSplitter := False;
  Result := '';
  while p^ <> #0 do
  begin
    //if p^ in splitter then // ���v������
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

// ����̋�؂蕶���܂ł��擾����i��؂蕶���͍폜����j
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

// ����̋�؂蕶���܂ł��擾����i��؂蕶���͎c���j
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

// ����̋�؂蕶���܂ł��擾����i��؂蕶���͍폜����j
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

// �����Chars���擾����
function getChars(var p: PChar; ch: TSysCharSet): string;
begin
  Result := '';
  while CharInSet(p^ , ch) do
  begin
    Result := Result + p^;
    Inc(p);
  end;
end;

// ����̋�؂蕶���܂ł��擾����i��؂蕶���͍폜����j
function getToken_s(var s: string; splitter: string): string;
var
  p: PChar;
begin
  p := PChar(s);
  Result := getTokenStr(p, splitter);
  s := string(p);
end;

// �����Chars�̊Ԃ��擾����
function getChars_s(var s: string; ch: TSysCharSet): string;
var
  p: PChar;
begin
  p := PChar(s);
  Result := getChars(p, ch);
  s := string(p);
end;

//------------------------------------------------------------------------------
// �������o��
//------------------------------------------------------------------------------
// ����
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
    // ��v�������H
    if StrLComp(ps, psub, len) = 0 then
    begin
      Result := i + 1; Break;
    end;
    // ��v���Ȃ��Ȃ�Έꕶ�����炵�Č������s
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
  s := JCopy(s, FromI, Length(s)); // �؂�o��

  psub := PChar(sub);
  ps   := PChar(s);
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

// �R�s�[
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
    if idxTo < idx then Break; // �擾�͈͂𒴂����甲����

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

// �������擾
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

// �����폜
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
      // ���̊Ԃ��폜
    end else
    begin
      des := des + c;
    end;
  end;
  s := des;
end;

// �u��
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
    // ������ɍ��v���邩�H
    if (StrLComp(p, pFind, len) = 0) then
    begin
      Result := Result + sNew;
      Inc(p, len);
      Continue;
    end;
    // ���v���Ȃ���΂��̂܂܂�Ԃ�
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

  // �̈���m��
  len := Length(s);
  SetLength(Result, count * len);

  // �J��Ԃ�
  for i := 0 to count - 1 do
  begin
    Move(s[1], Result[i * len + 1], len);
  end;
end;


//------------------------------------------------------------------------------
// S_JIS�Ή��R�s�[
//------------------------------------------------------------------------------
function sjis_copyByte(var p: PChar; count: Integer): string;
var
  i: Integer;
begin
  Result := '';
  i := 0;
  while p^ <> #0 do
  begin
    if (i+1) > count then Break;

    if p^ in SJISLeadBytes then
    begin
      Result := Result + p^;
      Inc(i); Inc(p);
      if p^ <> #0 then
      begin
        Result := Result + p^;
        Inc(i); Inc(p);
      end;
    end else
    begin
      Result := Result + p^;
      Inc(i); Inc(p);
    end;
  end;
end;


function Asc(const ch: string): Integer; //�����R�[�h�𓾂�
begin
    if ch = '' then begin
        Result := 0;
        Exit;
    end;
    Result := Ord(ch[1]);
end;


//------------------------------------------------------------------------------
// ������ޕϊ� �֘A
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
{�Ђ炪�ȁE�J�^�J�i�̕ϊ�}
function convToHiragana(const str: string): string;
begin
  Result := LCMapStringEx( str, LCMAP_HIRAGANA );
end;
function convToKatakana(const str: string): string;
begin
  Result := LCMapStringEx( str, LCMAP_KATAKANA );
end;
{�}���`�o�C�g���l�������啶���A��������}
function LowerCaseEx(const str: string): string;
begin
  Result := LCMapStringExHalf( str, LCMAP_LOWERCASE );
end;
function UpperCaseEx(const str: string): string;
begin
  Result := LCMapStringExHalf( str, LCMAP_UPPERCASE );
end;

//------------------------------------------------------------------------------
// �e�폈��
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
      // �Ή�����L�����`�F�b�N
      if (mae='(')and(usiro=')') then flg := True else
      if (mae='[')and(usiro=']') then flg := True else
      if (mae='{')and(usiro='}') then flg := True else
      if (mae='`')and(usiro='''') then flg := True else
      if (mae='<')and(usiro='>') then flg := True else
      if (mae='�u')and(usiro='�v') then flg := True else
      if (mae='�w')and(usiro='�x') then flg := True else
      if (mae='�o')and(usiro='�p') then flg := True else
      if (mae='�y')and(usiro='�z') then flg := True else
      if (mae='�i')and(usiro='�j') then flg := True else
      if (mae='�k')and(usiro='�l') then flg := True else
      if (mae='�g')and(usiro='�h') then flg := True else
      if (mae='�e')and(usiro='�f') then flg := True else
      if (mae='��')and(usiro='��') then flg := True else
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


end.
