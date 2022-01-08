{**************************************************************************
 *
 * Unit Name: jconvert
 * Purpose  : �����R�[�h�ϊ����C�u�����Ƃ��܂�
 * Author   : EarthWave Soft(IKEDA Takahiro)
 *            E-Mail: ikeda@os.rim.or.jp
 *            WWW:    http://www.os.rim.or.jp/~ikeda/
 *            Copyright(C) 1998 EarthWave Soft(IKEDA Takahiro)
 * History  : Ver 1.0 98/08/25 ����
 *            Ver 1.1 98/09/17 Result �������Y��Ή� ��
 *                               (Thanks kazukun@mars.dti.ne.jp)
 *            Ver 1.2 98/10/11 ���p�u��v�̑S�p�ϊ��~�X�̏C��
 *                             Hankana2Zenkana? ��L�Ή��ƃA���S���Y���ύX
 *                             1�s�݂̂̃f�[�^���̉��s�R�[�h���f����~�X�C��
 *            Ver 1.3 98/11/23 EncodeBase64R, DecodeBase64, DecodeHeaderString
 *                             �V�݁B
 *            Ver 1.4 98/11/29 EncodeUU, DecodeUU, EncodeBinHex, DecodeBinHex
 *                             ��V�݁iuuencode,BinHex�j�B
 *
 *  ����: �����Ō����ujis�v �� ISO-2022-JP �Ɋ�Â����d�l�ɂ��
 *        JIS �ւ̕ϊ��ł͔��p�J�^�J�i�͑S�p�֋����I�ɕϊ�����
 *************************************************************************}

unit jconvert;

interface

uses
  Windows, Sysutils, Classes;

const
  ASCII      = 0;
  BINARY     = 1;
  JIS83_IN   = 2;
  JIS78_IN   = 3;
  EUC_IN     = 4;
  SJIS_IN    = 5;
  EUCorSJIS_IN = 6;
  
  JIS_OUT   = 2;
  EUC_OUT     = 4;
  SJIS_OUT    = 5;
  
  CRLF_R = 1;
  CR_R = 2;
  LF_R = 3;

  {�o�C�i���t�@�C���������Ƀ`�F�b�N���邽�߂̍Œ�`�F�b�N�T�C�Y}
  STRICT_CHECK_LEN: Integer = 4096; {�C�ӂɕύX���ĉ�����}

{�����R�[�h����B�߂�l�͒萔���Q��}
function InCodeCheck( const s: string ): Integer;

{2 �o�C�g������ JIS -> SJIS�ϊ�}
function ToSjis( c1,c2: Byte ): string;

{2 �o�C�g������ SJIS -> JIS�ϊ�}
function ToJis( c1, c2: Byte ): string;

{euc���p�J�^�J�i�� jis �S�p�J�^�J�i�ցi�����g�p�j}
{function Hankana2Zenkana( const s: string; var index: Integer ): string;}

{sjis���p�J�^�J�i�� jis �S�p�J�^�J�i�ցi�����g�p�j}
{function Hankana2Zenkana2( const s: string; var index: Integer ): string;}

{jis -> euc �R���o�[�g}
function jis2euc( const s: string ): string;

{euc -> �Vjis �R���o�[�g}
function euc2jis83( const s: string ): string;

{jis -> sjis �R���o�[�g}
function jis2sjis( const s: string ): string;

{euc -> sjis �R���o�[�g}
function euc2sjis( const s: string ): string;

{sjis -> �Vjis �R���o�[�g}
function sjis2jis83( const s: string ): string;

{sjis -> euc �R���o�[�g}
function sjis2euc( const s: string ): string;

{���s�R�[�h�`�F�b�N}
function ReturnCodeCheck( const s: string ): Integer;

{�S�����R�[�h�ϊ� ... �g��}
function ConvertJCode( s: string; outcode: Integer; incode: Integer = -1 ): string;

{�����ȃR�[�h�ϊ��B���Ɍ��R�[�h���������Ă���ꍇ���Ɏg�p}
{�Ӗ�����̂�����H}
function StrictConvertJCode( s: string; incode, outcode: Integer ): string;

{���s�R�[�h�ϊ�}
function ConvertReturnCode( s: string; rcode: Integer ): string;

{�����ȉ��s�R�[�h�ϊ��B���Ɍ��R�[�h���������Ă���ꍇ���Ɏg�p}
{�Ӗ�����̂�����H}
function StrictConvertReturnCode( s: string; rcode_in, rcode: Integer ): string;

{���܂�}

{Base64 �`���ɃG���R�[�h����}
function EncodeBase64( const input: string ): string;

function EncodeBase64R( const input: string; Rcode: string ): string;

{uuencode �`���ɃG���R�[�h����}
function EncodeUU( const input: string; Rcode: string ): string;

{BinHex 4.0 �`���ɃG���R�[�h����}
function EncodeBinHex( const input: string; Rcode: string ): string;

{Base64 �`�����f�R�[�h����}
function DecodeBase64( const input: string ): string;

{uuencode �`�����f�R�[�h����Buudecode}
function DecodeUU( const input: string ): string;

{BinHex 4.0 �`�����f�R�[�h����}
function DecodeBinHex( const input: string ): string;

{E-Mail �̃w�b�_�ȂǂɎg��������(ISO-2022-JP �� Base64����������)�𐶐�}
function CreateHeaderString( const s: string): string;
function CreateHeaderString2( const s: string): string;//���{��ŏI����Ă��镶����ɑΉ�
function CreateHeaderStringEx(const s: string): string;//�����s�T�|�[�g
function CreateHeaderStringMail(const s: string): string;//�����s�T�|�[�g�̃��[���p


{E-Mail �̃w�b�_�ȂǂɎg��������(ISO-2022-JP �� Base64����������)���f�R�[�h}
function DecodeHeaderString( const s: string): string;
// DecodeHeaderString�̃o�O�𒼂�������
function DecodeHeaderString2( const s: string): string;
function DecodeHeaderStringMultiLine( const s: string): string;

{quoted-printable ���f�R�[�h����}
function DecodeQuotedPrintable(s: string): string;

// �����̈Ӗ��s���������폜���� by Mine 2001.Aug
function TrimJCodeBug(const s: string): string;

//URL Encode 2004/11/12 by http://www.delphidabbler.com/codesnip.php?action=named&routines=URLDecode&searchlogic=and&showsrc=1
function URLEncode(const S: string; const InQueryString: Boolean): string;
function URLDecode(const S: string): string;
function HexEncode(s: string): string;
function HexDecode(s: string): string;

function EntityEncode(s: string): string;
function EntityDecode(s: string): string;


implementation

uses unit_string, jconvertex;

function EntityEncode(s: string): string; // in: sjis
var
  i: Integer;
  n: string;
begin
  Result := '';
  i := 1;
  while (i <= Length(s)) do
  begin
    if s[i] in LeadBytes then
    begin
      Result := Result + s[i] + s[i+1];
      Inc(i, 2);
      Continue;
    end;

    n := s[i];
    case n[1] of
      '&': n := '&amp;';
      ' ': n := '&nbsp;';
      '>': n := '&gt;';
      '<': n := '&lt;';
      '\': n := '&yen;';
      '"': n := '&quot;';
    end;
    Result := Result + n;
    Inc(i);
  end;
end;

function EntityDecode(s: string): string;
var
  i, j, k: Integer;
  n: string;
begin
  Result := '';
  i := 1;
  while (i <= Length(s)) do
  begin
    if s[i] in LeadBytes then
    begin
      Result := Result + s[i] + s[i+1];
      Inc(i, 2);
      Continue;
    end;

    n := s[i];
    case n[1] of
      '&':
        begin
          Inc(i);
          j := PosEx(';', s, i);
          if j = 0 then j := Length(s);
          n := Copy(s, i, (j - i));
          if (n = '') then n := ' ';

          // ���ꕶ��
          if n[1] = '#' then
          begin
            System.Delete(n,1,1);
            n := JReplace_(n, 'x', '$');
            k := StrToIntDef(n, 32);
            n := WideChar(k);
          end else
          begin
            n := LowerCase(n);
            if n = 'amp'  then n := '&' else
            if n = 'nbsp' then n := ' ' else
            if n = 'quot' then n := '"' else
            if n = 'gt'   then n := '>' else
            if n = 'lt'   then n := '<' else
            if n = 'yen'  then n := '\' else
            ;
          end;
          i := j;
        end;
    end;
    Result := Result + n;
    Inc(i);
  end;
end;


function HexEncode(s: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(s) do
  begin
    Result := Result + IntToHex(Ord(s[i]), 2);
  end;
end;

function HexDecode(s: string): string;
var
  i: Integer;
  h: string;
begin
  Result := '';
  for i := 0 to (Length(s) div 2 - 1) do
  begin
    h := Copy(s, (i*2)+1, 2);
    Result := Result + Chr(StrToIntDef('$' + h, 0));
  end;
end;


function URLEncode(const S: string; const InQueryString: Boolean): string;
var
  Idx: Integer; // loops thru characters in string
begin
  Result := '';
  for Idx := 1 to Length(S) do
  begin
    case S[Idx] of
      'A'..'Z', 'a'..'z', '0'..'9', '-', '_', '.':
        Result := Result + S[Idx];
      ' ':
        if InQueryString then
          Result := Result + '+'
        else
          Result := Result + '%20';
      else
        Result := Result + '%' + SysUtils.IntToHex(Ord(S[Idx]), 2);
    end;
  end;
end;

function URLDecode(const S: string): string;
var
  Idx: Integer;   // loops thru chars in string
  Hex: string;    // string of hex characters
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
          Code := SysUtils.StrToIntDef('$' + Hex, -1);
          Inc(Idx, 2);
        end
        else
          // insufficient digits - error
          Code := -1;
        // check for error and raise exception if found
        if Code = -1 then
          raise SysUtils.EConvertError.Create(
            'Invalid hex digit in URL'
          );
        // decoded OK - add character to result
        Result := Result + Chr(Code);
      end;
      '+':
        // + is decoded as a space
        Result := Result + ' '
      else
        // All other characters pass thru unchanged
        Result := Result + S[Idx];
    end;
    Inc(Idx);
  end;
end;



const
  CR = $0D;
  LF = $0A;

  ESC = $1B;
  SS2 = $8E;
  
  KI_G0 = #$1B + '$B';
  KO_G0 = #$1B + '(J';

  Code64: PChar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  CodeUU: PChar = '`!"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_';
  CodeBinHex: PChar = '!"#$%&''()*+,-012345689@ABCDEFGHIJKLMNPQRSTUVXYZ[`abcdefhijklmpqr';
  DecBinHex: array[0..81] of BYTE = (
    $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$FF,$FF,$0D,
    $0E,$0F,$10,$11,$12,$13,$FF,$14,$15,$FF,$FF,$FF,$FF,$FF,$FF,$16,
    $17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20,$21,$22,$23,$24,$FF,$25,
    $26,$27,$28,$29,$2A,$2B,$FF,$2C,$2D,$2E,$2F,$FF,$FF,$FF,$FF,$30,
    $31,$32,$33,$34,$35,$36,$FF,$37,$38,$39,$3A,$3B,$3C,$FF,$FF,$3D,
    $3E,$3F );
    
  { JIS X0201 1 �o�C�g���� ���� JIS X0208 �E����}
  HkanaToZkana_R: array[0..63] of Char = (
    #$00,#$23,#$56,#$57,#$22,#$26,#$72,#$21,#$23,#$25,#$27,#$29,#$63,#$65,#$67,#$43,
    #$3C,#$22,#$24,#$26,#$28,#$2A,#$2B,#$2D,#$2F,#$31,#$33,#$35,#$37,#$39,#$3B,#$3D,
    #$3F,#$41,#$44,#$46,#$48,#$4A,#$4B,#$4C,#$4D,#$4E,#$4F,#$52,#$55,#$58,#$5B,#$5E,
    #$5F,#$60,#$61,#$62,#$64,#$66,#$68,#$69,#$6A,#$6B,#$6C,#$6D,#$6F,#$73,#$2B,#$2C);

function InCodeCheck( const s: string ): Integer;
var
  index,c,jmode: Integer;
begin
  {�o�C�i���`�F�b�N}
  index := 1;
  while (index <= STRICT_CHECK_LEN) and (index < Length(s)) do begin
    c := Ord( s[index] );
    if (c in [0..7]) or (c = $FF) then begin
      Result := BINARY;
      Exit;
    end;
    Inc(index);
  end;

  index := 1;
  jmode := ASCII;
  while ((jmode = ASCII) or (jmode = EUCorSJIS_IN)) and (index < Length(s)) do begin
    {�Ō�̕����͒��ׂȂ��i���[�v���Œ��ׂ�Ƃ�������j}
    c := Ord( s[index] );
    if c = ESC  then begin
      Inc(index);
      c := Ord(s[index]);
      if c = Ord('$') then begin
        Inc(index);
        c := Ord(s[index]);
        if c = Ord( 'B' ) then
          jmode := JIS83_IN           {JIS X0208-1983}
        else if c = Ord( '@' ) then
          jmode := JIS78_IN;          {JIS X0208-1978 Old JIS}
      end;
    end
    else if (c in [0..7]) or (c = $FF) then begin
      jmode := BINARY;
    end
    else if c > $7f then begin
      if (c in [$81..$8D]) or (c in [$8F..$9F]) then
        jmode := SJIS_IN
      else if c = SS2 then begin      {SS2 �� EUC �� JIS X0201 ����(1Byte)}
        Inc(index);                   {�ւ̈ڍs������}
        c := Ord( s[index] );
        if (c in [$40..$7E]) or (c in [$80..$A0]) or (c in [$E0..$FC]) then
          jmode := SJIS_IN
        else if (c in [$A1..$DF]) then   {EUC JIS X0201 ���� �̉\��}
          jmode := EUCorSJIS_IN;
      end
      else if c in [$A1..$DF] then begin  {SJIS �ł͔��p���ȗ̈�}
        Inc(index);
        c := Ord( s[index] );
        if c in [$F0..$FE] then
          jmode := EUC_IN
        else if c in [$A1..$DF] then
          jmode := EUCorSJIS_IN
        else if c in [$E0..$EF] then begin
          jmode := EUCorSJIS_IN;
          while (c >= $40) and (index <= Length( s )) and (jmode = EUCorSJIS_IN) do begin
            if c >= $81 then begin
              if (c <= $8D) or ( c in [$8F..$9C]) then {EUC �� A1..FF �̂͂�}
                jmode := SJIS_IN
              else if c in [$FD..$FE] then  {SJIS �ł͔����Ă���̈�}
                jmode := EUC_IN;
            end;
            Inc(index);
            c := ord( s[index] );
          end;
        end
        else if c <= $9F then
          jmode := SJIS_IN;
      end
      else if c in [$F0..$FE] then
        jmode := EUC_IN
      else if c in [$E0..$EF] then begin
        Inc(index);
        c := Ord( s[index] );
        if (c in [$40..$7E]) or (c in [$80..$A0]) then
          jmode := SJIS_IN
        else if c in [$FD..$FE] then
          jmode := EUC_IN
        else if c in [$A1..$FC] then
          jmode := EUCorSJIS_IN;
      end;
    end;
    Inc(index);
  end;
  Result := jmode;
end;


function ToSjis( c1,c2: Byte ): string; register;
var
  c1off,c2off: Integer;
begin
  if c1 < $5F then
    c1off := $70
  else
    c1off := $B0;
  if (c1 mod 2) <> 0 then begin
    if c2 > $5F then
      c2off := $20
    else
      c2off := $1F;
  end
  else
    c2off := $7E;
  Inc(c1);
  c1 := c1 shr 1;
  c1 := c1 + c1off;
  c2 := c2 + c2off;
  Result := Char(c1) + Char(c2);
end;


function ToJis( c1, c2: Byte ): string; register;
var
  c1off,c2off: Integer;
begin
  if c1 < 160 then
    c1off := 112
  else
    c1off := 176;
  c1 := c1 - c1off;
  c1 := c1 shl 1;

  if c2 < 159 then begin
    if c2 > 127 then begin
      c2off := 32;
    end
    else
      c2off := 31;
    Dec(c1);
  end
  else
    c2off := 126;

  c2 := c2 - c2off;
  Result := Char(c1) + Char(c2);
end;


function Hankana2Zenkana( const s: string; var index: Integer ): string;
var
  i,c: Integer;
  c2: Char;
begin
  Inc(index);
  c := Ord( s[index] );
  c := c and $7F;
  c2 := HkanaToZkana_R[c - $20];
  i := index+1;
  Result := '';
  
  case c of
    $21..$25,$30,$5E..$5F: begin {�L���n}
      Result := #$21 + c2;
    end;
    $33:begin {�u���v�Ή�}
      if (i <= Length(s)) and ( s[i] = Char(SS2) ) then begin
        if s[i+1] = #$DE then begin
          index := i+1;
          c2 := #$74;
        end;
      end;
    end;
    $36..$44:begin {���_�����ɂ��\���̂��镶��}
      if (i <= Length(s)) and ( s[i] = Char(SS2) ) then begin
        if s[i+1] = #$DE then begin
          index := i+1;
          Inc(c2);
        end;
      end;
    end;
    $4A..$4E:begin {�͂Ђӂւ�}
      if (i <= Length(s)) and ( s[i] = Char(SS2) ) then begin
        if s[i+1] = #$DE then begin
          index := i+1;
          Inc(c2);
        end
        else if s[i+1] = #$DF then begin  {�����_}
          index := i+1;
          Inc(c2); Inc(c2);
        end;
      end;
    end;
  end;
  Inc(index);
  if Result = '' then Result := #$25 + c2;
end;


function Hankana2Zenkana2( const s: string; var index: Integer ): string;
var
  i,c: Integer;
  c2: Char;
begin
  c := Ord( s[index] );
  c := c and $7F;
  c2 := HkanaToZkana_R[c - $20];
  i := index+1;
  Result := '';

  case c of
    $21..$25,$30,$5E..$5F:begin {�L���n}
      Result := #$21 + c2;
    end;
    $33:begin {�u���v�Ή�}
      if (i <= Length(s)) and ( s[i] = #$DE ) then begin
        index := i;
        c2 := #$74;
      end;
    end;
    $36..$44:begin {���_�����ɂ��\���̂��镶��}
      if (i <= Length(s)) and ( s[i] = #$DE ) then begin
        index := i;
        Inc(c2);
      end;
    end;
    $4A..$4E:begin {�͂Ђӂւ�}
      if (i <= Length(s)) and ( (s[i] = #$DE) or (s[i] = #$DF) ) then begin
        if s[i] = #$DE then begin
          index := i;
          Inc(c2);
        end
        else if s[i] = #$DF then begin  {�����_}
          index := i;
          Inc(c2); Inc(c2);
        end;
      end;
    end;
  end;
  Inc(index);
  if Result = '' then Result := #$25 + c2;
end;


{ JIS 1 Byte �������Ή�}
function jis2euc( const s: string ): string;
var
  index,c: Integer;
  ki: Boolean;
begin
  index := 1;
  ki := False;
  Result := '';
  while index <= Length( s ) do begin
    c := Ord(s[index]);
    if c = ESC then begin
      Inc(index);
      c := Ord(s[index]);
      if (c = $24) then
        ki := True
      else if (c = $28) then
        ki := False;
      Inc(index);
      Inc(index);
      c := Ord(s[index]);
    end;

    if ki then begin
      if c in [$21..$7E] then
        Result := Result + Char( c or $80 )
      else
        Result := Result+Char(c and $ff);
    end
    else begin
      Result := Result+Char(c and $ff);
    end;
    Inc(index);
  end;
end;


function euc2jis83( const s: string): string;
var
  ki: Boolean;
  index,c: Integer;
  c1,c2: Char;
begin
  ki := False;
  index := 1;
  Result := '';
  while index <= Length(s) do begin
    c := Ord( s[index] );
    if (c = CR) or (c = LF) then begin
      if ki then begin
        Result := Result + KO_G0;
        ki := False;
      end;
      Result := Result + Char(c and $ff);
      Inc(index);
      Continue;
    end;
    if c > $7F then begin
      if not ki then begin
        Result := Result + KI_G0;
        ki := True;
      end;
      if c = SS2 then begin  {���p�J�^�J�i}
        Result := Result + Hankana2Zenkana( s, index );
      end
      else begin
        c1 := Char(c and $7F);
        Inc(index);
        c := Ord(s[index] );
        c2 := Char(c and $7F);
        Result := Result + c1 + c2;
        Inc(index);
      end;
    end
    else begin
      if ki then begin
        Result := Result + KO_G0;
        ki := False;
      end;
      Result := Result + s[index];
      Inc(index);
    end;
  end;
end;


// by Mineaki Yamamoto
(*
�E���̃G�X�P�[�v�E�V�[�P���X�ɏ]���A������ނ����肷��B
ESC ( B   ASCII���� (ISO 8859-1�̃��[�}��)
ESC ( J   JIS X0201�̃��[�}��
ESC ( I   JIS X0201�̃J�^�J�i
ESC $ B   JIS X0208
ESC $ D   JIS X0212
ESC $ @   ESC $ B �Ɠ���
-------------------------------
<ESC>$B�@<ESC>$@ �c�c�c�c�c�c�c �����֐ؑւ�
<ESC>(I�@�c�c�c�c�c�c�c�c�c�c�c ���p�J�i�֐ؑւ�
<ESC>(B�@<ESC>(J�@<ESC>(H �c�c ASCII�֐ؑւ�

*)
function jis2sjis( const s: string ): string;
var
  i, len: Integer;
  p: PChar;
  IsKanji: Boolean;
begin
  // ����
  Result := '';
  len := Length(s);
  i := 1;
  p := PChar(s);
  IsKanji := False;
  // �ϊ����[�v
  while i <= len do
  begin
    // ESC ��
    if Ord(p^) = ESC then
    begin
      Inc(p); Inc(i); // skip ESC
      if p^ = '(' then
      begin
        Inc(p); Inc(i); // skip '('
        case p^ of
          'B':  IsKanji := False;
          'J':  IsKanji := False;
          'H':  IsKanji := False;
          'I':  IsKanji := False; // ���p�J�i�Ȃ̂Ŕ���
          else  IsKanji := False;
        end;
        Inc(p); Inc(i); // skip CODE
        Continue;
      end else
      if p^ = '$' then
      begin
        Inc(p); Inc(i); // skip '$'
        case p^ of
          'B':  IsKanji := True;
          'D':  IsKanji := True;
          '@':  IsKanji := True;
          else  IsKanji := True;
        end;
        Inc(p); Inc(i); // skip CODE
        Continue;
      end else
      begin
        // ������ESC ������ނ̕ύX�ł͂Ȃ�
      end;
    end;
    // �������ۂ��ŏ����𕪂���
    if Iskanji then
    begin
      Result := Result + ToSjis(Ord(p^), Ord((p+1)^));
      Inc(p, 2); Inc(i, 2);
    end else
    begin
      Result := Result + p^;
      Inc(p); Inc(i);
    end;
  end;
end;


function euc2sjis( const s: string ): string;
var
  index,c: Integer;
  c1,c2: Byte;
begin
  index := 1;
  Result := '';
  while index <= Length(s) do begin
    c := Ord(s[index]);
    if (c > $80) and ( c < $FF ) then begin
      if c = SS2 then begin
        Inc(index);
        c := Ord(s[index]);
        Result := Result + Char(c and $FF);
      end
      else begin
        c1 := Ord(s[index]);
        c1 := c1 and $7F;
        Inc(index);
        c2 := Ord(s[index]);
        c2 := c2 and $7F;
        Result := Result + ToSjis(c1,c2);
      end;
    end
    else begin
      Result := Result+Char(c and $ff);
    end;
    Inc(index);
  end;
end;


function sjis2jis83( const s: string ): string;
var
  ki: Boolean;
  index,c: Integer;
  c1,c2: Byte;
begin
  ki := False;
  index := 1;
  Result := '';
  while index <= Length(s) do begin
    c := Ord( s[index] );
    if (c = CR) or (c = LF) then begin
      if ki then begin
        Result := Result + KO_G0;
        ki := False;
      end;
      Result := Result + Char(c and $ff);
      Inc(index);
      Continue;
    end;
    if c > $7F then begin
      if not ki then begin
        Result := Result + KI_G0;
        ki := True;
      end;
      if c in [$A1..$DF] then begin  {���p�J�^�J�i}
        Result := Result + Hankana2Zenkana2( s,index)
      end
      else begin
        c1 := c and $FF;
        Inc(index);
        c2 := Ord(s[index] );
        Result := Result + ToJis( c1, c2 );
        Inc(index);
      end;
    end
    else begin
      if ki then begin
        Result := Result + KO_G0;
        ki := False;
      end;
      Result := Result + s[index];
      Inc(index);
    end;
  end;
  //---�ǉ� by MORIGUCHI hirokazu 2000/07/14---
  if ki then
  begin
  	//�I�[�Ɂu����OUT�v�̃R�[�h��ǉ�
    Result := Result + KO_G0;
    //ki:=False;
  end;
  //---�����܂�---
end;


function sjis2euc( const s: string ): string;
var
  index,c: Integer;
  c1,c2: Byte;
  zen: string;
begin
  index := 1;
  Result := '';
  while index <= Length(s) do begin
    c := Ord( s[index] );
    if c > $7F then begin
      if c in [$A1..$DF] then begin  {���p�J�^�J�i}
        Result := Result + Char(SS2) + Char(c and $FF);
      end
      else begin
        c1 := c;
        Inc(index);
        c2 := Ord(s[index]);
        zen := ToJis( c1, c2 );
        c1 := Byte(zen[1]) or $80;
        c2 := Byte(zen[2]) or $80;
        Result := Result + Char(c1) + Char(c2);
      end;
    end
    else begin
      Result := Result + s[index];
    end;
    Inc(index);
  end;
end;

// customized by kujira
function ConvertJCode( s: string; outcode: Integer; incode: Integer = -1): string;
begin
  if incode < 0 then
  begin
    incode := InCodeCheckEx( s );
  end;
  if (incode <= BINARY ) or ( incode = outcode ) or (incode = EUCorSJIS_IN) then begin
    Result := s;
    Exit;
  end;
  Result := '';
  case outcode of
    JIS_OUT:begin
      case incode of
        JIS83_IN..JIS78_IN: Result := s;
        EUC_IN            : Result := euc2jis83( s );
        SJIS_IN           : Result := sjis2jis83( s );
        UTF8_IN           : Result := sjis2jis83(Utf8Tosjis(s));
        UTF8N_IN          : Result := sjis2jis83(Utf8NTosjis(s));
        UNILE_IN          : Result := sjis2jis83(uniLETosjis2(s));
        UNIBE_IN          : Result := sjis2jis83(uniBETosjis2(s));
        else Result := s;
      end;
    end;
    EUC_OUT:begin
      case incode of
        JIS83_IN..JIS78_IN  : Result := jis2euc( s );
        SJIS_IN             : Result := sjis2euc( s );
        UTF8_IN             : Result := sjis2euc(Utf8Tosjis(s));
        UTF8N_IN            : Result := sjis2euc(Utf8NTosjis(s));
        UNILE_IN            : Result := sjis2euc(uniLETosjis2(s));
        UNIBE_IN            : Result := sjis2euc(uniBETosjis2(s));
        else Result := s;
      end;
    end;
    SJIS_OUT:begin
      case incode of
        JIS83_IN..JIS78_IN: Result := jis2sjis( s );
        EUC_IN            : Result := euc2sjis( s );
        UTF8_IN           : Result := Utf8Tosjis(s);
        UTF8N_IN          : Result := Utf8NTosjis(s);
        UNILE_IN          : Result := uniLETosjis2(s);
        UNIBE_IN          : Result := uniBETosjis2(s);
        else Result := s;
      end;
    end;
    UTF8_OUT:begin
      case incode of
        JIS83_IN..JIS78_IN: Result := sjisToUtf8(jis2sjis( s ));
        EUC_IN            : Result := sjisToUtf8(euc2sjis( s ));
        SJIS_IN           : Result := sjisToUtf8(s);
        UTF8N_IN          : Result := #$EF#$BB#$BF + s; // BOM�����邾��
        UNILE_IN          : Result := sjisToUtf8( uniLETosjis2(s) );
        UNIBE_IN          : Result := sjisToUtf8( uniBETosjis2(s) );
        else Result := s;
      end;
    end;
    UTF8N_OUT:begin
      case incode of
        JIS83_IN..JIS78_IN: Result := sjisToUtf8N(jis2sjis( s ));
        EUC_IN            : Result := sjisToUtf8N(euc2sjis( s ));
        SJIS_IN           : Result := sjisToUtf8N(s);
        UTF8_IN           : begin Result := s; System.Delete(Result, 1, 3); end; // BOM���폜
        UNILE_IN          : Result := sjisToUtf8N( uniLETosjis2(s) );
        UNIBE_IN          : Result := sjisToUtf8N( uniBETosjis2(s) );
        else Result := s;
      end;
    end;
    // ��������������...
    UNILE_OUT:begin
      case incode of
        JIS83_IN..JIS78_IN: Result := sjisToUniLE2(jis2sjis(s));
        EUC_IN            : Result := sjisToUniLE2(euc2sjis(s));
        SJIS_IN           : Result := sjisToUniLE2(s);
        UTF8_IN           : Result := sjisToUniLE2(Utf8Tosjis(s));
        UTF8N_IN          : Result := sjisToUniLE2(Utf8Tosjis(s));
        UNIBE_IN          : Result := sjisTouniBE2(uniBETosjis2(s));
        else Result := s;
      end;
    end;
    UNIBE_OUT:begin
      case incode of
        JIS83_IN..JIS78_IN: Result := sjisToUniBE2(jis2sjis(s));
        EUC_IN            : Result := sjisToUniBE2(euc2sjis(s));
        SJIS_IN           : Result := sjisToUniBE2(s);
        UTF8_IN           : Result := sjisToUniBE2(Utf8Tosjis(s));
        UTF8N_IN          : Result := sjisToUniBE2(Utf8NTosjis(s));
        UNILE_IN          : Result := sjisToUniBE2(uniLETosjis2(s));
        else Result := s;
      end;
    end;
    else
      Result := s;
  end;
end;


function StrictConvertJCode( s: string; incode,outcode: Integer ): string;
begin
  if (incode <= BINARY ) or ( incode = outcode ) or (incode = EUCorSJIS_IN) then begin
    Result := s;
    Exit;
  end;
  Result := '';
  case outcode of
    JIS_OUT:begin
      case incode of
        JIS83_IN..JIS78_IN: Result := s;
        EUC_IN:   Result := euc2jis83( s );
        SJIS_IN:  Result := sjis2jis83( s );
      end;
    end;
    EUC_OUT:begin
      case incode of
        JIS83_IN..JIS78_IN: Result := jis2euc( s );
        SJIS_IN: Result := sjis2euc( s );
      end;
    end;
    SJIS_OUT:begin
      case incode of
        JIS83_IN..JIS78_IN: Result := jis2sjis( s );
        EUC_IN: Result := euc2sjis( s );
      end;
    end;
    else
      Result := s;
  end;
end;


function ReturnCodeCheck( const s: string ): Integer;
var
  index: Integer;
  c:     char;
begin
  index := 1;
  c := #0;
  Result := 0;
  while (c <> #13) and (c <> #10) and (index <= Length(s)) do
  begin
    c := s[index];
    Inc(index);
  end;

  if c = #10 then
    Result := LF_R
  else if c = #13 then
  begin
    if Length(s) = index-1 then
      Result := CR_R
    else if s[index] = #10 then
      Result := CRLF_R
    else
      Result := CR_R;
  end;
end;


function ConvertReturnCode( s: string; rcode: Integer ): string;
var
  index, rcode_in: Integer;
  RCodeStr, RCodeStr_in: string;
begin
  rcode_in := ReturnCodeCheck( s );
  if (rcode_in = 0) or (rcode_in = rcode) then begin {���s�����e�L�X�g or}
    Result := s;
    Exit;
  end
  else begin
    case rcode_in of
      CRLF_R: RCodeStr_in := #13#10;
      CR_R: RCodeStr_in := #13;
      LF_R: RCodeStr_in := #10;
    end;
    case rcode of
      CRLF_R: RCodeStr := #13#10;
      CR_R: RCodeStr := #13;
      LF_R: RCodeStr := #10;
    end;
  end;
  Result := '';
  index := 1;
  while index <= Length(s) do
  begin
    if s[index] = RCodeStr_in[1] then
    begin
      Delete(s, index, Length(RCodeStr_in));
      Insert(RCodeStr, s, index);
      index := index + Length(RCodeStr);
    end
    else
      Inc(index);
  end;
  Result := s;
end;


function StrictConvertReturnCode( s: string; rcode_in, rcode: Integer ): string;
var
  index: Integer;
  RCodeStr, RCodeStr_in: string;
begin
  if (rcode_in = 0) or (rcode_in = rcode) then begin {���s�����e�L�X�g or}
    Result := s;
    Exit;
  end
  else begin
    case rcode_in of
      CRLF_R: RCodeStr_in := #13#10;
      CR_R: RCodeStr_in := #13;
      LF_R: RCodeStr_in := #10;
    end;
    case rcode of
      CRLF_R: RCodeStr := #13#10;
      CR_R: RCodeStr := #13;
      LF_R: RCodeStr := #10;
    end;
  end;
  Result := '';
  index := 1;
  while index <= Length(s) do
  begin
    if s[index] = RCodeStr_in[1] then
    begin
      Delete(s, index, Length(RCodeStr_in));
      Insert(RCodeStr, s, index);
      index := index + Length(RCodeStr);
    end
    else
      Inc(index);
  end;
  Result := s;
end;

{��������͂��܂�}


{Base64 �G���R�[�h�B77�����ȏ�̉��s�K���ɖ��Ή� :98/08/21}
{98/11/25: �e�[�u���`���̕ύX�ɕ����ďC���Bstring -> PChar �ɂ�� Code64 }
{          �� Zero origin �ɁB}
function EncodeBase64( const input: string ): string;
var
  i,j,iLen: Integer;
  a,b,c: BYTE;
begin
  Result := '';

  //�G���R�[�h��̑傫�����v�Z
  iLen := Length(input);
  i := iLen mod 3;
  if i <> 0 then i := 4;
  SetLength( Result, ( iLen div 3 ) * 4 + i);

  i:=1; j:=1;
  while i <= iLen -2 do begin
    a := BYTE(input[i]); b:= BYTE(input[i+1]); c := BYTE(input[i+2]);
    Result[j] := Code64[ ((a and $FC) shr 2) ]; Inc(j);
    Result[j] := Code64[ ( ((a and $03) shl 4) or ((b and $F0) shr 4) ) ]; Inc(j);
    Result[j] := Code64[ ( ((b and $0F) shl 2) or ((c and $C0) shr 6) ) ]; Inc(j);
    Result[j] := Code64[ (c and $3F) ]; Inc(j);
    i := i + 3;
  end;
  if (iLen mod 3) = 1 then begin
    a := BYTE(input[iLen]); b:=0;
    Result[j] := Code64[ ((a and $FC) shr 2) ]; Inc(j);
    Result[j] := Code64[ ( ((a and $03) shl 4) or ((b and $F0) shr 4) ) ]; Inc(j);
    Result[j] := '='; Inc(j);
    Result[j] := '=';
  end
  else if (iLen mod 3) = 2 then begin
    a := BYTE(input[iLen -1]); b := BYTE(input[iLen]); c := 0;
    Result[j] := Code64[ ((a and $FC) shr 2) ]; Inc(j);
    Result[j] := Code64[ ( ((a and $03) shl 4) or ((b and $F0) shr 4) ) ]; Inc(j);
    Result[j] := Code64[ ( ((b and $0F) shl 2) or ((c and $C0) shr 6) ) ]; Inc(j);
    Result[j] := '=';
  end;
end;


{Base64 �G���R�[�h�B77�����ȏ�̉��s�K���ɑΉ� :98/11/23}
{Rcode �ɂ͔C�ӂ̉��s�R�[�h���Z�b�g�Bex #$0D#0A}
{98/11/25: �e�[�u���`���̕ύX�ɕ����ďC���Bstring -> PChar �ɂ�� Code64 }
{          �� Zero origin �ɁB}
function EncodeBase64R( const input: string; Rcode: string ): string;
var
  i,j,k,l,iLen: Integer;
  a,b,c: BYTE;
begin
  Result := '';

  //�G���R�[�h��̑傫�����v�Z
  iLen := Length(input);
  i := iLen mod 3;
  if i <> 0 then i := 4;
  i := i + ((( iLen div 3 ) * 4) div 76) * Length(Rcode);
  SetLength( Result, ( iLen div 3 ) * 4 + i);

  i:=1; j:=1; k:=0;
  while i <= iLen -2 do begin
    a := BYTE(input[i]); b:= BYTE(input[i+1]); c := BYTE(input[i+2]);
    Result[j] := Code64[ ((a and $FC) shr 2) ]; Inc(j);
    Result[j] := Code64[ ( ((a and $03) shl 4) or ((b and $F0) shr 4) ) ]; Inc(j);
    Result[j] := Code64[ ( ((b and $0F) shl 2) or ((c and $C0) shr 6) ) ]; Inc(j);
    Result[j] := Code64[ (c and $3F) ]; Inc(j);
    i := i + 3;
    k := k + 4;
    if k = 76 then begin
      for l:=1 to Length(Rcode) do begin
        Result[j] := Rcode[l]; Inc(j);
      end;
      k := 0;
    end;
  end;
  if (iLen mod 3) = 1 then begin
    a := BYTE(input[iLen]); b:=0;
    Result[j] := Code64[ ((a and $FC) shr 2) ]; Inc(j);
    Result[j] := Code64[ ( ((a and $03) shl 4) or ((b and $F0) shr 4) ) ]; Inc(j);
    Result[j] := '='; Inc(j);
    Result[j] := '=';
  end
  else if (iLen mod 3) = 2 then begin
    a := BYTE(input[iLen -1]); b := BYTE(input[iLen]); c := 0;
    Result[j] := Code64[ ((a and $FC) shr 2) ]; Inc(j);
    Result[j] := Code64[ ( ((a and $03) shl 4) or ((b and $F0) shr 4) ) ]; Inc(j);
    Result[j] := Code64[ ( ((b and $0F) shl 2) or ((c and $C0) shr 6) ) ]; Inc(j);
    Result[j] := '=';
  end;
end;


{uuencode: 98/11/25}
{Rcode �ɂ͔C�ӂ̉��s�R�[�h���Z�b�g�Bex #$0D#0A}
{�擪�� begin 644 hogehoge.xxx �Ɩ����� end �͌Ăяo������������ɂǂ��ɂ�����}
{���Ȃ݂� 644 �� UNIX �Ō����Ƃ���̃t�@�C���p�[�~�b�V���� }
function EncodeUU( const input: string; Rcode: string ): string;
var
  i,j,k,l,m,iLen: Integer;
  a,b,c: BYTE;
begin
  Result := '';

  //�G���R�[�h��̑傫�����v�Z
  iLen := (Length(input) div 3) * 4;
  m := iLen div 60;
  i := Length(input) mod 3;
  if i <> 0 then iLen := iLen + 4;
  i := m * ( Length(RCode) + 1) + Length(Rcode) * 2 +1 +1;
  SetLength( Result, iLen + i);

  iLen := Length(input);
  i:=1; j:=1; k:=0;
  while i <= iLen -2 do begin
    a := BYTE(input[i]); b:= BYTE(input[i+1]); c := BYTE(input[i+2]);
    if (k = 0) and (m <> 0) then begin
      Result[j] := 'M'; Inc(j);
    end
    else if k=0 then begin
      Result[j] := Char(iLen - i +1 + $20); Inc(j);
    end;
    Result[j] := CodeUU[ ((a and $FC) shr 2) ]; Inc(j);
    Result[j] := CodeUU[ ( ((a and $03) shl 4) or ((b and $F0) shr 4) ) ]; Inc(j);
    Result[j] := CodeUU[ ( ((b and $0F) shl 2) or ((c and $C0) shr 6) ) ]; Inc(j);
    Result[j] := CodeUU[ (c and $3F) ]; Inc(j);
    i := i + 3;
    k := k + 4;

    if (k = 60) and (m <> 0) then begin
      for l:=1 to Length(Rcode) do begin
        Result[j] := Rcode[l]; Inc(j);
      end;
      Dec(m);
      k := 0;
    end;
  end;

  if (iLen mod 3) = 1 then begin
    a := BYTE(input[iLen]); b:=0;
    Result[j] := CodeUU[ ((a and $FC) shr 2) ]; Inc(j);
    Result[j] := CodeUU[ ( ((a and $03) shl 4) or ((b and $F0) shr 4) ) ]; Inc(j);
    Result[j] := CodeUU[0]; Inc(j);
    Result[j] := CodeUU[0]; Inc(j);
  end
  else if (iLen mod 3) = 2 then begin
    a := BYTE(input[iLen -1]); b := BYTE(input[iLen]); c := 0;
    Result[j] := CodeUU[ ((a and $FC) shr 2) ]; Inc(j);
    Result[j] := CodeUU[ ( ((a and $03) shl 4) or ((b and $F0) shr 4) ) ]; Inc(j);
    Result[j] := CodeUU[ ( ((b and $0F) shl 2) or ((c and $C0) shr 6) ) ]; Inc(j);
    Result[j] := CodeUU[0]; Inc(j);
  end;

  k := 1;
  while k <= Length(Rcode) * 2 +1 do begin
    for l:=1 to Length(Rcode) do begin
      Result[j] := Rcode[l]; Inc(j);
    end;
    k := k + Length(Rcode);
    if k = Length(RCode) +1 then
      Result[j] := '`'; Inc(j); Inc(k);
  end;

end;


{BinHex 4.0(Hqx7?) �G���R�[�h :98/11/27}
{Rcode �ɂ͔C�ӂ̉��s�R�[�h���Z�b�g�Bex #$0D#0A}
{(This file must be converted with BinHex 4.0) �Ƃ����擪�̕������}
{�Ăяo�������ǂ��ɂ�����}
function EncodeBinHex( const input: string; Rcode: string ): string;
var
  i,j,k,l,iLen: Integer;
  a,b,c: BYTE;
begin
  Result := '';

  //�G���R�[�h��̑傫�����v�Z
  iLen := (Length(input) div 3) * 4;
  i := iLen mod 3;
  if i <> 0 then Inc(i);
  iLen := iLen + i +2;  // +2 �n�I�[�L��
  iLen := iLen + (iLen div 64) * Length(Rcode); // �n�I�[�L���Ɖ��s�R�[�h��
  SetLength( Result, iLen );
  
  iLen := Length(input);
  i:=1; j:=2; k:=1;
  Result[1] := ':';
  while i <= iLen -2 do begin
    a := BYTE(input[i]); b:= BYTE(input[i+1]); c := BYTE(input[i+2]);

    Result[j] := CodeBinHex[ ((a and $FC) shr 2) ]; Inc(j);
    Result[j] := CodeBinHex[ ( ((a and $03) shl 4) or ((b and $F0) shr 4) ) ]; Inc(j);
    Result[j] := CodeBinHex[ ( ((b and $0F) shl 2) or ((c and $C0) shr 6) ) ]; Inc(j);
    k := k + 3;
    if k = 64 then begin
      for l:=1 to Length(Rcode) do begin
        Result[j] := Rcode[l]; Inc(j);
      end;
      k := 0;
    end;
    Result[j] := CodeBinHex[ (c and $3F) ]; Inc(j); Inc(k);
    i := i + 3;
  end;

  if (iLen mod 3) <> 0 then begin
    if (iLen mod 3) = 1 then begin
      a := BYTE(input[iLen]); b:=0;
      Result[j] := CodeBinHex[ ((a and $FC) shr 2) ]; Inc(j);
      Result[j] := CodeBinHex[ ( ((a and $03) shl 4) or ((b and $F0) shr 4) ) ]; Inc(j);
    end
    else if (iLen mod 3) = 2 then begin
      a := BYTE(input[iLen -1]); b := BYTE(input[iLen]); c := 0;
      Result[j] := CodeBinHex[ ((a and $FC) shr 2) ]; Inc(j);
      Result[j] := CodeBinHex[ ( ((a and $03) shl 4) or ((b and $F0) shr 4) ) ]; Inc(j);
      Result[j] := CodeBinHex[ ( ((b and $0F) shl 2) or ((c and $C0) shr 6) ) ]; Inc(j);
      if k = 64 then begin
        for l:=1 to Length(Rcode) do begin
          Result[j] := Rcode[l]; Inc(j);
        end;
      end;
    end;
  end;
  Result[j] := ':';
end;


{Base64 �f�R�[�h: 98/11/23}
function DecodeBase64( const input: string ): string;
var
  i,j,k,iLen: Integer;
  dbuf: array[0..3] of BYTE;
begin

  iLen := Length( input );
  Result := '';

  //�f�R�[�h��̑傫�����v�Z
  j := 0;
  for i:=1 to iLen do begin
    if (input[i] = #$0D) or (input[i] = #$0A) or (input[i] = '=') then
      Inc(j);
  end;
  iLen := iLen -j;
  i :=  iLen mod 4;
  if i <> 0 then Dec(i);
  iLen := (iLen div 4) * 3 +i;
  SetLength( Result, iLen); //�������̂���

  iLen := Length(input);
  i := 1;
  k := 1;
  while i <= iLen do begin
    if (input[i] = #$0D) or (input[i] = #$0A) then begin
      Inc(i);
      Continue;
    end;
    for j:=0 to 3 do begin
      case (input[i]) of
        'A'..'Z': dbuf[j] := BYTE(input[i]) - $41;
        'a'..'z': dbuf[j] := BYTE(input[i]) - $47;
        '0'..'9': dbuf[j] := BYTE(input[i]) + 4;
        '+'     : dbuf[j] := 62;
        '/'     : dbuf[j] := 63;
        '='     : dbuf[j] := $FF;
      end;
      Inc(i);
    end;

    if dbuf[2] = $FF then begin
      Result[k] := Char( (dbuf[0] shl 2) or (dbuf[1] shr 4) );
    end
    else if dbuf[3] = $FF then begin
      Result[k] := Char( (dbuf[0] shl 2) or (dbuf[1] shr 4) ); Inc(k);
      Result[k] := Char( (dbuf[1] shl 4) or (dbuf[2] shr 2) );
    end
    else begin
      Result[k] := Char( (dbuf[0] shl 2) or (dbuf[1] shr 4) ); Inc(k);
      Result[k] := Char( (dbuf[1] shl 4) or (dbuf[2] shr 2) ); Inc(k);
      Result[k] := Char( (dbuf[2] shl 6) or dbuf[3] );
    end;
    Inc(k);
  end;
end;


{uudecode: 98/11/25}
{begin 644 hogehoge.xxx �Ɩ����� end�ŋ��܂ꂽ���� uuencode data ��n������}
{�Ō�͉��s�ŏI����Ă��Ă����Ȃ��Ă�����}
function DecodeUU( const input: string ): string;
var
  i,j,k,iLen: Integer;
  dLen: Integer;
  dbuf: array[0..3] of BYTE;
begin

  iLen := Length( input );
  Result := '';

  //�f�R�[�h��̑傫�����v�Z
  j := 0; i := 1;
  while i <=iLen do begin
    if (input[i] = #$0D) or (input[i] = #$0A) then begin
      Inc(i);
      Continue;
    end;
    dLen := Ord(input[i]);
    if dLen = $4D then begin
      j := j + 45;
      i := i + 61;
    end 
    else begin
      j := j + dLen - $20;
      Break;
    end;
  end;
  SetLength( Result, j); //�������̂���
  
  i := 1;
  k := 1;
  dLen := 0;
  while i <= iLen do begin
    if (input[i] = #$0D) or (input[i] = #$0A) then begin
      Inc(i);
      dLen := 0;
      Continue;
    end;
    if dLen = 0 then begin
      dLen := Ord(input[i]) -$20; Inc(i);
      Continue;; // �I�[ '`' �̉\���������
    end;

    for j:=0 to 3 do begin
      if input[i] = '`' then
        dbuf[j] := 0
      else
        dbuf[j] := BYTE(input[i]) - $20;
      Inc(i);
    end;
    
    if dLen <= 1 then begin
      Result[k] := Char( (dbuf[0] shl 2) or (dbuf[1] shr 4) );
    end
    else if dLen <=2  then begin
      Result[k] := Char( (dbuf[0] shl 2) or (dbuf[1] shr 4) ); Inc(k);
      Result[k] := Char( (dbuf[1] shl 4) or (dbuf[2] shr 2) );
    end
    else begin
      Result[k] := Char( (dbuf[0] shl 2) or (dbuf[1] shr 4) ); Inc(k);
      Result[k] := Char( (dbuf[1] shl 4) or (dbuf[2] shr 2) ); Inc(k);
      Result[k] := Char( (dbuf[2] shl 6) or dbuf[3] );
    end;
    Inc(k);
    dLen := dLen -3;
  end;

end;


{BinHex 4.0(Hqx7?) �f�R�[�h :98/11/27}
{':'��':'�ň͂܂ꂽ�f�[�^��n��}
function DecodeBinHex( const input: string ): string;
var
  i,j,k,iLen: Integer;
  dbuf: array[0..3] of BYTE;
begin
  iLen := Length( input );
  Result := '';

  //�f�R�[�h��̑傫�����v�Z
  j := 0;
  for i:=1 to iLen do begin
    if (input[i] = #$0D) or (input[i] = #$0A) then begin
      Inc(j);
    end;
  end;
  iLen := iLen -j -2;
  i := iLen mod 4;
  if i <> 0 then Dec(i);
  iLen := (iLen div 4) * 3 + i;
  SetLength( Result, iLen); //�������̂���
  
  iLen := Length( input );
  i := 2;
  k := 1;
  while i <= iLen do begin
    dbuf[0] := DecBinHex[ Ord(input[i]) -$21]; Inc(i);
    if dbuf[0] = $FF then Break;
    dbuf[1] := DecBinHex[ Ord(input[i]) -$21]; Inc(i);
    dbuf[2] := DecBinHex[ Ord(input[i]) -$21]; Inc(i);
    if (input[i] = #$0D) or (input[i] = #$0A) then begin // ���s�̉\��
      Inc(i);
      if input[i] = #$0A then Inc(i);
    end;

    dbuf[3] := DecBinHex[ Ord(input[i]) -$21]; Inc(i);
    
    if dbuf[2] = $FF then begin
      Result[k] := Char( (dbuf[0] shl 2) or (dbuf[1] shr 4) );
      Break;
    end
    else if dbuf[3] = $FF then begin
      Result[k] := Char( (dbuf[0] shl 2) or (dbuf[1] shr 4) ); Inc(k);
      Result[k] := Char( (dbuf[1] shl 4) or (dbuf[2] shr 2) );
      Break;
    end
    else begin
      Result[k] := Char( (dbuf[0] shl 2) or (dbuf[1] shr 4) ); Inc(k);
      Result[k] := Char( (dbuf[1] shl 4) or (dbuf[2] shr 2) ); Inc(k);
      Result[k] := Char( (dbuf[2] shl 6) or dbuf[3] );
    end;
    Inc(k);
  end;
end;


{���[���̃T�u�W�F�N�g�Ƃ��ɓ���镶����̍쐬�B=?ISO-2022-JP?B?���Ă��}
{77�����ȏ�̃}���`���C�����ɖ��Ή�}
{���͕������ SJIS ����BIsDBCSLeadByte���g���Ă邩��}
function CreateHeaderString( const s: string): string;
var
  HanBuf,ZenBuf: string;  // ���p�����o�b�t�@�A�S�p�����o�b�t�@
  cnt: Integer;
  ZenFlg: Boolean;        // �}���`�o�C�g�����i�S�p�j���������Ă������ǂ���
begin
  Result := '';
  cnt := 1;
  ZenFlg := False;
  while cnt <= Length(s) do begin
    if IsDBCSLeadByte( BYTE(s[cnt]) ) then begin
      if not ZenFlg then begin
        if HanBuf <> '' then begin
          Result := Result + HanBuf;
          HanBuf := '';
        end;
      end;
      ZenBuf := ZenBuf + s[cnt] + s[cnt+1];
      ZenFlg := True;
      Inc( cnt );
    end
    else begin
      if ZenFlg then begin
        if ZenBuf <> '' then begin
          Result := Result + '=?ISO-2022-JP?B?'
                    + EncodeBase64( sjis2jis83(ZenBuf) ) +'?=';
          ZenBuf := '';
        end;
      end;
      HanBuf := HanBuf + s[cnt];
      ZenFlg := False;
    end;
    Inc( cnt );
  end;
  if ZenFlg then begin
    Result := Result + '=?ISO-2022-JP?B?'
              + EncodeBase64( sjis2jis83(ZenBuf) ) +'?=';
    ZenBuf := '';
  end
  else if HanBuf <> '' then begin
    Result := Result + HanBuf;
  end;
end;

function CreateHeaderString2( const s: string): string;
begin
  Result := CreateHeaderString(s);
  if AnsiPos('=?ISO-2022-JP?B?', result) > 0 then
  begin
    if AnsiPos('?=',Result) = 0 then
      Result := Result + '?=';
  end;
end;

function CreateHeaderStringEx(const s: string): string;//�����s�T�|�[�g
var
  flgEncode: Boolean;
  i: Integer;
  bs, tmp: string;
  p: PChar;
begin
  // �G���R�[�h���K�v���`�F�b�N����
  flgEncode := False;

  for i := 1 to Length(s) do
  begin
    if s[i] >= #$7F then begin flgEncode := True; Break; end;
  end;

  // �G���R�[�h���s�v�H
  if not flgEncode then
  begin
    Result := s;
    Exit;
  end;

  // ���s���s�v�H
  if Length(s) <= 24 then
  begin
    Result := ' =?ISO-2022-JP?B?' + EncodeBase64(sjis2jis83(s)) + '?=';
    Exit;
  end;

  // SJIS��32�o�C�g�ȏ�Ȃ�s�ɋ�؂�
  Result := '';
  bs := s;
  while Length(bs) > 24 do
  begin
    p := PChar(bs);
    tmp := sjis_copyByte(p, 24);
    bs := string(p);
    Result := Result + ' =?ISO-2022-JP?B?' + EncodeBase64(sjis2jis83(tmp)) + '?='#13#10;
  end;
  if bs <> '' then
    Result := Result + ' =?ISO-2022-JP?B?' + EncodeBase64(sjis2jis83(bs)) + '?=';
  Result := Trim(Result);
end;

function CreateHeaderStringMail(const s: string): string;//�����s�T�|�[�g�̃��[���p
var
  p: PChar;
  ss, name, mail: string;

  procedure GetMailOne(s: string);
  begin
    name := ''; mail := '';
    // �����̃��[���A�h���X������
    while p^ <> #0 do
    begin
      if p^ in [#13, #10, ','] then
      begin
        Inc(p);
        Break;
      end;
      // name
      if p^ in LeadBytes then
      begin
        name := name + p^ + (p+1)^;
        Inc(p, 2);
        Continue;
      end else
      // "name"
      if p^ = '"' then
      begin
        Inc(p);
        name := name + '"' + getTokenStr(p, '"') + '"';
      end else
      // mail
      if p^ = '<' then
      begin
        Inc(p);
        mail := getTokenStr(p, '>');
      end else
      begin
        name := name + p^;
        Inc(p);
      end;
    end;
  end;


begin
  Result := '';
  ss := Trim(s);
  p := PChar(ss);

  while p^ <> #0 do
  begin
    GetMailOne(p);
    // ���[���A�h���X����������
    if mail = '' then
    begin
      mail := name;
      name := '';
    end;
    mail := Trim(mail);
    if mail = '' then Continue;
    if Result <> '' then Result := Result + ','#13#10' ';
    Result := Result + Trim(Trim(CreateHeaderStringEx(name)) + ' <' + mail + '>');
  end;
end;

{MIME Header =?ISO-2022-JP?B? �`���̃f�R�[�h�B:98/11/23}
{�}���`���C���ɖ��Ή��B��s���Ƃɓn���� OK ���낤}
{  �߂�l�F ISO-2022-JP �̂͂� }
function DecodeHeaderString( const s: string): string;
var
  i,j: Integer;
  buf,temp: string;
begin
  Result := s;
  buf := UpperCase( s );

  i := Pos('=?ISO-2022-JP?B?', buf);
  while i > 0 do begin
    System.Delete( buf, i, 16 );
    System.Delete( Result, i, 16 );
    j := Pos('?=', Result);
    if j > 0 then begin
      temp := Copy( Result, i, j-i);
      System.Delete( buf, i, j-i+2 );
      System.Delete( Result, i, j-i+2 );
      temp := DecodeBase64( temp );
      System.Insert( temp+KO_G0, Result, i );
      System.Insert( temp+KO_G0, buf, i );
    end;
    i := Pos('=?ISO-2022-JP?B?', buf);
  end;
end;

function DecodeHeaderString2(const s: string): string;
var
  p: PChar;
  cmd, bq, dat, tmp: string;
begin
  Result := '';
  p  := PChar(s);
  while p^ <> #0 do
  begin
    if StrLComp(p, '=?', 2) = 0 then //=?ISO-2022-JP?B?xxxxxxx?=
    begin
      Inc(p, 2); // skip =?
      cmd := UpperCase(getTokenStr(p, '?'));
      if cmd = 'ISO-2022-JP' then
      begin
        bq  := UpperCase(getTokenStr(p, '?'));
        dat := getTokenStr(p, '?=');
        if bq = 'B' then
        begin
          tmp := DecodeBase64(dat);
          Result := Result + tmp;
        end else
        begin
          Result := Result + DecodeQuotedPrintable(dat);
        end;
      end else
      //if cmd = 'GB2312' then
      begin
        bq  := UpperCase(getTokenStr(p, '?'));
        dat := getTokenStr(p, '?=');
        if bq = 'B' then
        begin
          tmp := DecodeBase64(dat);
          Result := Result + tmp;
        end else
        begin
          Result := Result + DecodeQuotedPrintable(dat);
        end;
      end
      {
      else begin
        Result := Result + (p-2)^ + (p-1)^;
      end;
      }
    end else
    begin
      //if not(p^ in [#0, #9, ' ']) then
      begin
        Result := Result + p^;
      end;
      Inc(p);
    end;
  end;
  // �����R�[�h�`�F�b�N
  Result := ConvertJCode(Result, SJIS_OUT); // SJIS_OUT ����
end;

function DecodeHeaderStringMultiLine( const s: string): string;
var
  ss: TStringList;
  i: Integer;
  line, c: string;
begin
  Result := '';
  ss := TStringList.Create;
  ss.Text := s;
  for i := 0 to ss.Count-1 do
  begin
    line := ss.Strings[i];
    c := Copy(line,1,1);
    if (c=#9)or(c=' ') then System.Delete(line,1,1);
    Result := Result + DecodeHeaderString2(line);
  end;
  ss.Free;
end;

// �����̈Ӗ��s���������폜���� by Mine 2001.Aug
function TrimJCodeBug(const s: string): string;
var
	i: Integer;
begin
  Result := s;
  i := 1;
  while Length(Result) >= i do
  begin
  	if Result[i] in SysUtils.LeadBytes then
    begin
    	Inc(i,2)
    end else
  	begin
        if Result[i] in [' '..'~', #10, #13, #9] then // Is Ascii
        	Inc(i)
        else begin
            Result[i] := #0;
            Result := string(PChar(Result));
            Break;
        end;
    end;
  end;
end;

{quoted-printable ���f�R�[�h����}
function DecodeQuotedPrintable(s: string): string;
var p: PChar; i: Integer;
begin
  Result := '';
  p := PChar(s);
  while p^ <> #0 do
  begin
    if p^ = '=' then
    begin
      Inc(p);
      // �s���� = �̓X�L�b�v
      if (p^=#13)and((p+1)^=#10) then
      begin
        Inc(p,2); Continue;
      end;

      // =XX �`��
      i := StrToIntDef('$' + p^ + (p+1)^ , -1); Inc(p, 2);
      if i>0 then
      begin
        Result := Result + Char(i);
      end;
    end else
    begin
      Result := Result + p^;
      Inc(p);
    end;
  end;
end;

end.