unit jconvertex;

// �l���h�l�̍�������j�b�g�ł�
// http://member.nifty.ne.jp/m-and-i/tips/jconex.htm ���Q�ƁF���ӁI
// �ꕔ���� �N�W����s��(2005/01/28)

interface

uses
  Windows, SysUtils, jconvert, Classes;

const
  UNILE_IN   = 7; // Unicode Little Endian(Intel CPU)
  UNIBE_IN   = 8; // Unicode Big Endian
  UTF8_IN    = 9; // UTF8(TTF8N��BOM�t��)
  UTF8N_IN   = 10;// UTF8N

  UNILE_OUT  = 7;
  UNIBE_OUT  = 8;
  UTF8_OUT   = 9;
  UTF8N_OUT  = 10;

// �g�������R�[�h�`�F�b�N
function InCodeCheckEx(const s: AnsiString): integer;
// UNICODE(Little Endian)��SJIS�ɕϊ�����
function uniLETosjis(const s: PWideChar): string;
function uniLETosjis2(const s: string): string; // ������^�ŗ^����ꂽUNICODE��sjis�ɕϊ�
// UNICODE(Big Endian)��SJIS�ɕϊ�����
function uniBETosjis(const s: PWideChar): string;
function uniBETosjis2(const s: string): string;
// UTF8��SJIS�ɕϊ�����
function Utf8Tosjis(const s: String): string;
// UTF8N��SJIS�ɕϊ�����
function Utf8NTosjis(const s: String): string;

// SJIS��UNICODE(LE)�ɕϊ�����
procedure sjisToUniLE(var ms: TMemoryStream; const s: string);
function sjisToUniLE2(const s: string): string;
// SJIS��UNICODE(BE)�ɕϊ�����
procedure sjisToUniBE(var ms: TMemoryStream; const s: string);
function sjisToUniBE2(const s: string): string;
// SJIS��UNICODE(UTF8)�ɕϊ�����
function sjisToUtf8(const s: string): string;
// SJIS��UNICODE(UTF8N)�ɕϊ�����
function sjisToUtf8N(const s: string): string;


implementation

// �g�������R�[�h�`�F�b�N
// UNICODE��UTF8���`�F�b�N���A���̂ǂ��ł��Ȃ������ꍇ�ɂ�
// jconvert��InCodeCheck��߂�l�ɂ���
(*
function InCodeCheckEx(const s: string): integer;
var
  index, c, size: Integer;
  utfk: Boolean;
begin
  size := Length(s);
  { Size = 0 }
  if size = 0 then
  begin
    Result := BINARY;
    Exit;
  end;
  { Unicode���`�F�b�N���� }
  { �擪��BOM�����`�F�b�N���Ă��Ȃ��̂Ō�쓮�̉\������ }
  if (size >= 2 ) then
  begin
    { UNICODE(Little Endian)�`�F�b�N }
    if (s[1] = #$FF) and (s[2] = #$FE) then
    begin
      Result := UNILE_IN;
      Exit;
    end;
    { UNICODE(Big Endian)�`�F�b�N }
    if (s[1] = #$FE) and (s[2] = #$FF) then
    begin
      Result := UNIBE_IN;
      Exit;
    end;
  end;
  { UTF-8���`�F�b�N���� }
  if size > 3 then
  begin
    { UTF-8N(BOM����)�`�F�b�N }
    { �擪��BOM�����`�F�b�N���Ă��Ȃ��̂Ō�쓮�̉\������ }
    if (s[1] = #$EF) and (s[2] = #$BB) and (s[3] = #$BF) then
    begin
      Result := UTF8_IN;
      Exit;
    end;
  end;
  {UTF-8(BOM�Ȃ�)�`�F�b�N}
  index := 1;
  utfk := False;
  while (index <= STRICT_CHECK_LEN) and (index < size - 4) do
  begin
    c := Ord(s[index]);
    if (c in [$C0..$DF]) or (c > $EF) then
    begin
      utfk := False;
      Break;
    end;
    if c in [0..$7F] then
    begin
      ;
    end else if c = $E0 then
    begin
      Inc(index);
      c := Ord(s[index]);
      if c in [$A0..$BF] then
      begin
        Inc(index);
        c := Ord(s[index]);
        if c in [$80..$BF] then
          utfk := True
        else begin
          utfk := False;
          Break;
        end;
      end else begin
        utfk := False;
        Break;
      end;
    end else if c in [$E1..$EF] then
    begin
      Inc(index);
      c := Ord(s[index]);
      if c in [$80..$BF] then
      begin
        Inc(index);
        c := Ord(s[index]);
        if c in [$80..$BF] then
          utfk := True
        else begin
          utfk := False;
          Break;
        end;
      end else begin
        utfk := False;
        Break;
      end;
    end else begin
      utfk := False;
      Break;
    end;
    Inc(index);
  end;
  { ��������������UTF }
  if utfk then
    Result := UTF8N_IN
  { Unicde�ł�UTF8�ł��Ȃ����Jconvert�Ń`�F�b�N }
  else
    Result := InCodeCheck(s);
end;
*) // �{�Ƃ̃`�F�b�N

//�N�W�����`�F�b�N
//�ȉ��̂v�d�a���Q�l�ɂ���
//http://www.gprj.net/dev/tips/other/kanji.shtml

function InCodeCheckEx(const s: AnsiString): Integer;
var
  i, rMax, rMaxV, maxLen, sLen: Integer;
  FlagUTF8Bom: Boolean;
  FlagStrict: Boolean; // �����R�[�h���m�肵�����ǂ���
  rate: array [0..10] of Integer;

  procedure IncRate(code, v: Integer);
  begin
    rate[code] := rate[code] + v;
  end;

  procedure check_ISO2022JP;
  begin
    // ISO-2022-JP�̃`�F�b�N
    { 1    2    3
      0x1B 0x24 0x40       JIS X 0208-1978
      0x1B 0x24 0x42       JIS X 0208-1983
      0x1B 0x24 0x28 0x44  JIS X 0208-1990
      0x1B 0x24 0x28 0x4F  JIS X 0213:2000 1��
      0x1B 0x24 0x28 0x50  JIS X 0213:2000 2��
      0x1B 0x24 0x42       JIS X 0208-1990
      0x1B 0x26 0x40       JIS X 0208-1990
      0x1B 0x28 0x49       JIS X 0201-1976 �Љ���
      0x1B 0x28 0x42       ASCII
      0x1B 0x28 0x4A       JIS X 0201-1976 Roman Set
      0x1B 0x28 0x48       JIS X 0201-1976 Roman Set
    }

    if (i+3) <= slen then
    begin

      if s[i] = #$1B{ESC} then
      begin
        case s[i+1] of
          #$24:
            begin
              case s[i+2] of
                #$40: Result := JIS78_IN;
                #$42: Result := JIS83_IN;
                #$44: Result := JIS83_IN; // �{���� JIS90 ������
                else  Result := JIS83_IN;
              end;
            end;
          #$28:
            begin
              Result := JIS78_IN; // �{���� JIS76 ������
            end;
          #$26:
            begin
              Result := JIS83_IN; // �{���� JIS90 ������
            end;
          else
            begin
              FlagStrict := True;
              Exit;
            end;
        end;
        FlagStrict := True;
      end;

    end;
  end;

  procedure check_UTF8;
  var
    cb: Byte;
    temp: Integer;

    function chk(count: Integer): Boolean;
    var k: Integer; b: Byte;
    begin
      Result := False;
      if (i+count) > slen then Exit;
      // check
      for k := 1 to count do
      begin
        b := Ord(s[i + k]);
        if not ( ($80 <= b) and (b <= $BF) ) then
        begin
          rate[UTF8N_IN] := 0; // �\�����Ⴂ
          Exit; // False
        end;
      end;
      // ok
      Result := True;
      Exit;
    end;

  begin
    // UTF-8 �̃`�F�b�N
    if not( (#$C0 <= s[i])and(s[i] <= #$FD) ) then Exit; // �\�����Ȃ�

    temp := i;

    // BOM���H
    if Copy(s, i, 3) = #$EF+#$BB+#$BF then
    begin
      FlagUTF8Bom := True;
      Inc(i, 3);
      if i > sLen then Exit; // FALSE
    end;

    // UTF-8 �̂P�o�C�g��(��)
    // ��1�o�C�g������0xC0<->0xFD���ł����UTF-8�̋����\��
    // ��2�o�C�g�ȍ~���w�肳�ꂽ�T�C�Y��0x80<->0xBF�͈͓̔����ǂ����`�F�b�N
    // 2�o�C�g�ȍ~�́A0x80<->0xBF �ɂȂ�
    {
    AND 0xFC ... 5�o�C�g(RFC2279(�j��RFC))
    AND 0xF8 ... 4�o�C�g
    AND 0xF0 ... 3�o�C�g
    AND 0xE0 ... 2�o�C�g
    AND 0xC0 ... 1�o�C�g(�擪�o�C�g������������킷)
    }

    while i <= maxLen do // �J��Ԃ��\�����`�F�b�N
    begin
      IncRate(UTF8N_IN, 1); //

      // 1�o�C�g�ڂ��`�F�b�N
      cb := Ord(s[i]);
      if (cb and $FC) = $FC then
      begin
        if chk(5) = False then Exit; // False
        Result := UTF8N_IN;
        Inc(i); Inc(i, 5);
      end else
      if (cb and $F8) = $F8 then
      begin
        if chk(4) = False then Exit; // False
        Result := UTF8N_IN;
        Inc(i); Inc(i, 4);
      end else
      if (cb and $F0) = $F0 then
      begin
        if chk(3) = False then Exit; // False
        Result := UTF8N_IN;
        Inc(i); Inc(i, 3);
      end else
      if (cb and $E0) = $E0 then
      begin
        if chk(2) = False then Exit; // False
        Result := UTF8N_IN;
        Inc(i); Inc(i, 2);
      end else
      if (cb and $C0) = $C0 then
      begin
        //if chk(1) = False then Exit; // False
        Result := UTF8N_IN;
        Inc(i); Inc(i);
      end else
      // 1 �o�C�g
      begin
        if cb < $80 then
        begin
          Inc(i);
        end else
        begin
          i := temp;
          FlagStrict := False;
          Exit;
        end;
      end;
    end;
    //
  end;

  procedure check_EUC;
  begin
    { EUC
      ��1�o�C�g         0xA1<->0xFE
      ��2�o�C�g         0x8E(1�o�C�g��) + 0xA1<->0xDF
      ���p�J�i          0xA4(1�o�C�g��) + 0xA1<->0xF3
      �S�p����(���`��)  0xA5(1�o�C�g��) + 0xA1<->0xF6
      �S�p�J�i(�A�`��)  0x8F(1�o�C�g��) + 0xA1<->0xFE(2�E3�o�C�g��)
      �⏕���� 0xA1<->0xFE
      --------------------
    }
    {
      EUC ���p�J�i�̃`�F�b�N

    ��1�o�C�g��0x8E�ő�2�o�C�g��0xA1<->0xDF�ȏꍇ��EUC���p�J�i�̋����\��
    ���������ɑ��̕����R�[�h�̋����\������Ɣ��f����ĂȂ��ꍇ�Ɍ���
    ��2�o�C�g��EUC���p�J�i�͈͊O��0x80<->0xA0�ł���Ȃ��SJIS(�m��)
    �ȏ�ɓ��Ă͂܂�Ȃ��ꍇ�͕s���R�[�h

    }
    if ((i+2) > slen) then Exit;
    // ���p�J�i�̉\��
    if (s[i] = #$8E) then
    begin
      // SJIS �����H
      if s[i+1] in [#$80..#$A0] then
      begin
        // SJIS�m��
        Result := SJIS_IN;
        FlagStrict := True;
        Exit;
      end;
      if s[i+1] in [#$A1..#$DF] then // �����\��
      begin
        // EUC�J�i�̉\�� ... �m�肵�Ȃ�
        Result := EUC_IN;
        IncRate(EUC_IN, 2);
      end;
    end;
    {
    ��1�o�C�g��0x8F�ő�2�E3�o�C�g��0xA1<->0xFE�ȏꍇ��EUC�⏕�����̋����\��
    ���������ɑ��̕����R�[�h�̋����\������Ɣ��f����ĂȂ��ꍇ�Ɍ���
    ��2�E3�o�C�g�ǂ��炩��0xFD�E0xFE�ł���Ȃ��EUC�⏕����(�m��)
    ��2�E3�o�C�g��EUC�⏕�����͈͊O��0x80<->0xA0�ł���Ȃ��SJIS(�m��)
    �ȏ�ɓ��Ă͂܂�Ȃ��ꍇ�͕s���R�[�h
    }
    // �d�t�b�⏕�����̉\��
    if (s[i] = #$8F)and((i+3) <= slen) then
    begin
      if (s[i+1] in [#$A1..#$FE])and((s[i+2] in [#$A1..#$FE])) then
      begin
        Result := EUC_IN; // EUC�̉\��
        IncRate(EUC_IN,1);

        // �m�肷�邩�H
        if (s[i+1] in [#$FD,#$FE]) or (s[i+2] in [#$FD,#$FE]) then
        begin
          FlagStrict := True; Exit;
        end;
      end;
    end;
    //

  end;

  procedure check_SJIS;
  begin
    // SJIS
    // 0x80<->0xA0�ł���Ȃ��SJIS�Ŋm��
    if s[i] in [#$80..#$A0] then
    begin
      FlagStrict := True;
      Result := SJIS_IN;
      Exit;
    end;
    // 1byte��
    if s[i] in [#$81..#$9F,#$E0..#$EF] then
    begin
      IncRate(SJIS_IN, 1);
      // 2byte��
      if (i+1) <= slen then
      begin
        if s[i+1] in [#$40..#$7E, #$80..#$FC] then
        begin
          IncRate(SJIS_IN,1);
        end;
      end;
    end;
    {
    0xA1<->0xDF���o���ꍇ��SJIS���p�J�i�EEUC�S�p���ȁE�J�i�̋����\��
    ���������ɑ��̕����R�[�h�̋����\���Ɣ��f����ĂȂ��ꍇ�Ɍ���
    ��1�o�C�g��0xA4��0xA5�ő�2�o�C�g��[����]0xA1<->0xF3[�J�i]0xA1<->0xF6�ł���Ȃ��
    EUC�S�p�Ђ炪�ȁE�J�^�J�i�̎ア�\��
    ��2�o�C�g���`�F�b�N����0xE0<->0xFE�ł���Ȃ��EUC�̋����\����0xFD�E0xFE�̏ꍇ��EUC(�m��)
    ��2�o�C�g�����݂��Ȃ��ꍇ��SJIS�̋����\��
    �ȏ�ɓ��Ă͂܂�Ȃ��ꍇ��SJIS���p�J�i�̋����\��
    }
    if (i+1) > slen then
    begin
      // ��Q�o�C�g�����݂��Ȃ�
      if s[i] in [#$A1..#$DF] then
      begin
        Result := SJIS_IN; FlagStrict := True; // ���p�J�i�Ō���
      end;
      Exit;
    end;
    // SJIS ���p�J�i�̔���
    if s[i] in [#$A1..#$DF] then // SJIS���p�J�i or EUC�S�p���ȁE�J�i�̉\��
    begin
      IncRate(SJIS_IN, 1);
      if (s[i] in [#$A4,#$A5])and(s[i+1] in [#$A1..#$F6]) then // EUC�S�p�Ђ炪�ȁE�J�^�J�i�̎ア�\��
      begin
        IncRate(EUC_IN,1);
      end else
      if s[i+1] in [#$E0..#$FE] then //EUC�̋����\��
      begin
        IncRate(EUC_IN,1);
        Result := EUC_IN;
        if s[i+1] in [#$FD,#$FE] then
        begin
          FlagStrict := True; Exit;
        end;
      end else
      begin
        IncRate(SJIS_IN,1);
        Result := SJIS_IN; // �\��������
      end;
    end;
  end;

  procedure check_UNICODE;
  begin
    { Unicode���`�F�b�N���� }
    { �擪��BOM�����`�F�b�N���Ă��Ȃ��̂Ō�쓮�̉\������ }
    if (sLen >= 2 ) then
    begin
      { UNICODE(Little Endian)�`�F�b�N }
      if (s[1] = #$FF) and (s[2] = #$FE) then
      begin
        Result := UNILE_IN;
        FlagStrict := True;
      end;
      { UNICODE(Big Endian)�`�F�b�N }
      if (s[1] = #$FE) and (s[2] = #$FF) then
      begin
        Result := UNIBE_IN;
        FlagStrict := True;
      end;
    end;
  end;

begin
  Result := BINARY;
  if s = '' then Exit;

  // ���������ݒ�
  maxLen := Length(s);
  sLen   := maxLen;
  if maxLen > STRICT_CHECK_LEN then maxLen := STRICT_CHECK_LEN;
  FlagUTF8Bom := False;
  FlagStrict  := False; // �����R�[�h���m�肵�����ǂ���


  // UNICODE �̔���͎蔲��
  check_UNICODE;

  // �S��ASCII�����H
  FlagStrict := True;
  for i := 1 to maxLen do
  begin
    if not(Ord(s[i]) in [$21..$7E]) then
    begin
      FlagStrict := False;
      Break;
    end;
  end;
  if FlagStrict then
  begin
    Result := ASCII; Exit;
  end;


  // �{�i�����J�n
  FlagStrict := False;
  for i := 0 to High(rate) do
  begin
    rate[i] := 0;
  end;
  
  i := 1;
  while i <= maxLen do
  begin
    // JIS �͊m�肷��
    check_ISO2022JP;
    if FlagStrict then Exit;

    // UTF-8/UTF-8N
    check_UTF8;

    // UNICODE
    check_UNICODE;
    if FlagStrict then Exit;

    // EUC�J�i�E�⏕
    check_EUC;
    if FlagStrict then Exit;

    // SJIS
    check_SJIS;
    if FlagStrict then Exit;

    // EUC����
    {0xA1<->0xFE�̏ꍇ��EUC�̋����\����0xFD�E0xFE�̏ꍇ��EUC(�m��)}
    if s[i] in [#$A1..#$FE] then
    begin
      Result := EUC_IN;
      IncRate(EUC_IN,1);
      if s[i] in [#$FD,#$FE] then Exit; // EUC�m��
    end;

    Inc(i);
  end;

  // �����ŉ\���e�X�g
  // �\���������Ă����肵�Ȃ������ꍇ
  // ��Ԋm�����������̂��̗p
  rMax := ASCII; rMaxV := 0;
  for i := 0 to High(rate) do
  begin
    if rate[i] > rMaxV then
    begin
      rMax := i; rMaxV := rate[i];
    end;
  end;
  Result := rMax;

  if Result = UTF8N_IN then
  begin
    // BOM �Ń`�F�b�N
    if FlagUTF8Bom then
    begin
      Result := UTF8_IN;
    end else
    begin
      Result := UTF8N_IN;
    end;
  end;

end;


function UniLETosjis(const s: PWideChar): string;
begin
  Result := WideCharToString(s);
end;

function uniLETosjis2(const s: string): string; // ������^�ŗ^����ꂽUNICODE��sjis�ɕϊ�
begin
  if s <> '' then
  begin
    Result := WideCharToString(@s[1]);
  end else
  begin
    Result := '';
  end;
end;

function uniBETosjis2(const s: string): string;
begin
  if s <> '' then
  begin
    Result := UniBETosjis(@s[1]);
  end else
  begin
    Result := '';
  end;
end;


function UniBETosjis(const s: PWideChar): string;
var
  Pc: PChar;
  c: char;
  n: integer;
begin
  Pc := PChar(s);
  n := 0;
  while True do
  begin
    if (Pc[n] = #0) and (Pc[n+1] = #0) then
      Break;
    c := Pc[n];
    Pc[n] := Pc[n+1];
    Pc[n+1] := c;
    Inc(n, 2);
  end;
  Result := WideCharToString(PWideChar(Pc));
end;

procedure sjisToUniLE(var ms: TMemoryStream; const s: string);
var
  PWs: PWideChar;
  Len: integer;
begin
  if not Assigned(ms) then
    raise Exception.Create('������MemoryStream.');
  Len := Length(s) * 2;
  PWs := AllocMem(Len + 2);
  try
    StringToWideChar(s, PWs, Len);
    ms.Write(#$FF#$FE, 2);
    ms.Write(PWs^, Length(Pws) * 2);
  finally
    FreeMem(PWs);
  end;
end;

function sjisToUniLE2(const s: string): string;
var
  i, len, sLen: Integer;
begin
  sLen := Length(s);
  len := sLen * 2;
  SetLength(Result, len + 2);
  StringToWideChar(s, @Result[1], len);
  // �����𑪂�
  len := 2;
  for i := 0 to sLen-1 do
  begin
    if Result[i*2+1] = #0 then // 1 �o�C�g�ڂ�0�Ȃ�ΏI�[
    begin
      len := i*2; Break;
    end;
  end;
  Result := Copy(Result, 1, len);
  Result := #$FF#$FE + Result;
end;

function sjisToUniBE2(const s: string): string;
var
  m: TMemoryStream;
begin
  m := TMemoryStream.Create;
  try
    sjisToUniBe(m, s);
    SetLength(Result, m.Size);
    m.Position := 0;
    if m.Size > 0 then
    begin
      m.Write(Result[1], m.Size);
    end else
    begin
      Result := '';
    end;
  finally
    m.Free;
  end;
end;

procedure sjisToUniBE(var ms: TMemoryStream; const s: string);
var
  PWs: PWideChar;
  Pc: PChar;
  len, n: integer;
  Tc: Char;
begin
  if not Assigned(ms) then
    raise Exception.Create('������MemoryStream.');
  Len := Length(s) * 2;
  PWs := AllocMem(Len + 2);
  try
    StringToWideChar(s, PWs, Len);
    Pc := PChar(PWs);
    n := 0;
    while n < len do
    begin
      Tc := (Pc+n)^;
      (Pc+n)^ := (Pc+n+1)^;
      (Pc+n+1)^ := Tc;
      Inc(n, 2);
    end;
    ms.Write(#$FE#$FF, 2);
    ms.Write(PWs^, Length(Pws) * 2);
  finally
    FreeMem(PWs);
  end;
end;

function Utf8NTosjis(const s: string): string;
{
var
  Len: integer;
  OutStr: PWideChar;
  SIn, SOut: string;
}
begin
  Result := Utf8ToAnsi(s); // Delphi 8 �W���̊֐�
  {

  Result := '';
  // �S�~�h�~
  SIn := S + #0#0;
  Len := MultiByteToWideChar(CP_UTF8, 0, PChar(SIn), Length(SIn), nil, 0);
  if Len = 0 then
    raise Exception.Create('UTF8�̕�����ϊ��Ɏ��s���܂���.');
  // Len�ŗǂ��͂������A�Ȃ����G���[�ƂȂ邽�߂Q�{
  OutStr := AllocMem(Len * 2);
  try
    MultiByteToWideChar(CP_UTF8, 0, PChar(SIn), Length(SIn), OutStr, Len);
    WideCharToStrVar(OutStr, SOut);
    Result := SOut;
  finally
    FreeMem(OutStr);
  end;

  }
end;

function Utf8Tosjis(const s: string): string;
var
  s2: string;
begin
  s2 := s;
  // #$EF#$BB#$BF�����邩����
  if Copy(s2,1,3) = #$EF#$BB#$BF then
  begin
    Delete(s2, 1, 3);
  end;
  Result := Utf8NTosjis(s2);
end;

function SjisToUtf8N(const s: string): string;
{
var
  Len: integer;
  InStr: PWideChar;
  OutStr: PChar;
}
begin
  Result := AnsiToUtf8(s); // Delphi 8 �W���̊֐�
{
  Result := '';
  Len := Length(s) * 2 + 2;
  InStr := AllocMem(Len);
  try
    StringToWideChar(s, InStr, Len);
    OutStr := AllocMem(Len);
    try
      WideCharToMultiByte(CP_UTF8, 0, InStr, Length(InStr) * 2, OutStr, Len, nil, nil);
      Result := OutStr;
    finally
      FreeMem(OutStr);
    end;
  finally
    FreeMem(InStr);
  end;
}
end;

function SjisToUtf8(const s: string): string;
begin
  Result := #$EF#$BB#$BF + SjisToUtf8N(s);
end;

end.

