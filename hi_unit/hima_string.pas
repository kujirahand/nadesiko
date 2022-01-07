unit hima_string;

interface

uses
  SysUtils, unit_string, hima_variable;

type
  // �Ђ܂��̃\�[�X�𐮌`����R���o�[�^�[
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

// �N���X���g��Ȃ��Ő��`
function HimaSourceConverter(FileNo: Integer; var src: AnsiString): AnsiString;
// �����̌���ω����폜
function DeleteGobi(key: AnsiString): AnsiString;
// �����R�[�h�͈͓̔����ǂ������ׂ�
function CharInRange(p: PAnsiChar; fromCH, toCH: AnsiString): Boolean;
// ������𐔒l�ɕϊ�
function HimaStrToNum(s: AnsiString): HFloat;

implementation

uses
  hima_error, hima_token;

// �N���X���g��Ȃ��Ő��`
function HimaSourceConverter(FileNo: Integer; var src: AnsiString): AnsiString;
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

// �����̌���ω����폜
function DeleteGobi(key: AnsiString): AnsiString;
var p: PAnsiChar;
begin
  key := HimaSourceConverter(0, key);
  p := PAnsiChar(key);

  if CharInRange(p, '��','��') then // �Ђ炪�Ȃ���n�܂�Ό���������Ȃ�
  begin
    Result := key;
    Exit;
  end;

  //
  Result := '';
  while p^ <> #0 do
  begin
    if p^ in SJISLeadBytes then
    begin
      if not CharInRange(p, '��','��') then Result := Result + p^ + (p+1)^;
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

  // �Ђ炪�ȈȊO���Ō�Ɍ��ꂽ�ʒu(+1�����̏�)���L�^
  while p^ <> #0 do begin
    if p^ in SJISLeadBytes then
    begin
      if False = CharInRange(p, '��','��') then // �Ђ炪�ȈȊO
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

  // �����S���Ђ炪�Ȃ�������...
  if pp = pS then
  begin
    // ����̓������폜                     1234|5678|
    s := Copy(key, Length(key) - 4 + 1, 4); //�Ђ�|����|
    //if Pos(s, '���� ����') > 0 then
    if ((s='����')or(s='����'))and(key<>s) then
    begin
      Result := Copy(key,1,Length(key)-4);
    end else
      Result := key;
    Exit;
  end;

  // �Ō�ɂЂ炪�ȈȊO���o���ꏊ�܂œ���
  Result := Copy(key, 1, (pp - pS));
end;
}


// �����R�[�h�͈͓̔����ǂ������ׂ�
function CharInRange(p: PAnsiChar; fromCH, toCH: AnsiString): Boolean;
var
  code: Integer;
  fromCode, toCode: Integer;
begin
  // ���ʑΏۂ̃R�[�h�𓾂�
  if p^ in SJISLeadBytes then code := (Ord(p^) shl 8) + Ord((p+1)^) else code := Ord(p^);

  // �͈͏���
  if fromCH = '' then
  begin
    fromCode := 0;
  end else
  begin
    if fromCH[1] in SJISLeadBytes then
      fromCode := (Ord(fromCH[1]) shl 8) + Ord(fromCH[2])
    else
      fromCode := Ord(fromCH[1]);
  end;

  // �͈͏I���
  if toCH = '' then
  begin
    toCode := $FCFC;
  end else
  begin
    if toCH[1] in SJISLeadBytes then
      toCode := (Ord(toCH[1]) shl 8) + Ord(toCH[2])
    else
      toCode := Ord(toCH[1]);
  end;

  Result := (fromCode <= code)and(code <= toCode);
end;

// ������𐔒l�ɕϊ�
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
    // �ʏ�̌`��
    // 123.456
    // �w���`��
    // 7.89E+08 7.89e-2
    n := p^; Inc(p);
    // ��������
    while p^ in ['0'..'9'] do begin
      n := n + p^; Inc(p);
    end;
    // �����_
    if (p^ = '.') then
    begin
      n := n + p^; Inc(p);
      // �����_�ȉ�
      while p^ in ['0'..'9'] do begin
        n := n + p^; Inc(p);
      end;
      // �w���`��
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
    // ���ʂ𓾂�
    Result := Flag * StrToFloat(n);
  end;

begin
  Result := 0; Flag := 1;

  p := PAnsiChar(s); skipSpace(p);

  // + or -
  if p^ = '+' then Inc(p);
  if p^ = '-' then begin Inc(p); Flag := -1; end;

  // 16�i�@���H
  if p^ = '$' then get16sin else

  // 10�i�@���H
  if p^ in ['0'..'9'] then get10sin else Exit; // ���l�ȊO

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
  lineNo :=  1; InLineNo := 0; // �s�ԍ�
  memStr := ''; // �G���[�\���̂��߂̎��ӕ�����
  p      := PAnsiChar(FSource);
  isString  := False; //�u�v
  isString2 := False; //�w�x
  isString3 := False; // ""
  isString4 := False; // ``
  isComment  := False; // /* ... */
  isCommentLine := False; // #...

  // �p���S�p�𔼊p��
  // ���p�J�^�J�i��S�p��
  // ����L���𓝈ꂷ��
  // �������A������̒��A�R�����g�̒��͕ϊ����Ȃ�

  while p^ <> #0 do
  begin
    // ���s�Ȃ�s���𑫂�
    if (p^ in [#13,#10]) then
    begin
      if (p^ + (p+1)^) = #13#10 then Inc(p, 2) else Inc(p);
      isCommentLine := False;
      Inc(lineNo);
      res := res + #13#10;
      Continue;
    end;

    // ����̑ΏۂP�����𓾂�
    getOneChar(p, true, ch, nch);

    //----------------------------------------------------
    // ��Ԃ������񂩃R�����g�Ȃ�A����炩�甲���邩�m�F
    if isString then
    begin
      // ������̉�����
      if nch = '�v' then
      begin
        isString := False;
        res := res + nch; // ���p���S�p���u�v�œ���
        Continue;
      end;
    end else
    if isString2 then
    begin
      // ������̉�����
      if nch = '�x' then
      begin
        isString2 := False;
        res := res + nch; // ���p���S�p���u�v�œ���
        Continue;
      end;
    end else
    if isString3 then
    begin
      // ������̉�����
      if nch = '"' then
      begin
        isString3 := False;
        res := res + nch; // ���p���S�p���u�v�œ���
        Continue;
      end;
    end else
    if isString4 then
    begin
      // ������̉�����
      if nch = '`' then
      begin
        isString4 := False;
        res := res + nch; // ���p���S�p���u�v�œ���
        Continue;
      end;
    end else
    if isComment then
    begin
      // �R�����g���甲���邩
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
      // �R�����g���甲���邩
      if nch = '}' then
      begin
        isComment2 := False;
      end;
      Continue;
    end else
    *)
    //---------------------------------------------------
    // ������ł��R�����g�łȂ��ꏊ
    begin
      //-----------------------------------
      // �������R�����g�ɓ��邩�`�F�b�N
      //-----------------------------------
      // ������ɓ��邩�H
      if (nch = '�u') then
      begin
        isString := True;
        res := res + nch; // ���p���S�p���u�v�œ���
        InLineNo := lineNo;
        memStr := ch + sjis_copyByte(p, 10);
        Continue;
      end else
      if (nch = '�w') then
      begin
        isString2 := True;
        res := res + nch; // ���p���S�p���u�v�œ���
        InLineNo := lineNo;
        memStr := ch + sjis_copyByte(p, 10);
        Continue;
      end else
      if (nch = '"') then
      begin
        isString3 := True;
        res := res + nch; // ���p���S�p���u�v�œ���
        InLineNo := lineNo;
        memStr := ch + sjis_copyByte(p, 10);
        Continue;
      end else
      if (nch = '`') then
      begin
        isString4 := True;
        res := res + nch; // ���p���S�p���u�v�œ���
        InLineNo := lineNo;
        memStr := ch + sjis_copyByte(p, 10);
        Continue;
      end else
      // �R�����g�ɓ��邩
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
          // �s���܂ŃR�����g
          Inc(p, Length(ch2)); // add Pointer
          isCommentLine := True;
          Continue;
        end;
      end else
      if (nch = '#')or(nch = '''') then
      begin
        // �s���܂ŃR�����g
        isCommentLine := True;
        Continue;
      end else
      begin
        // �ˑR�������R�����g�̏I�[�L�����o�Ă�����G���[���o��
        if nch = '�v' then raise EHimaSyntax.Create(FileNo, LineNo, ERR_NOPAIR_STRING, []);
        if nch = '�x' then raise EHimaSyntax.Create(FileNo, LineNo, ERR_NOPAIR_STRING2,[]);
        if nch = '"'  then raise EHimaSyntax.Create(FileNo, LineNo, ERR_NOPAIR_STRING3,[]);
        if nch = '`'  then raise EHimaSyntax.Create(FileNo, LineNo, ERR_NOPAIR_STRING4,[]);
        if nch = '*'  then
        begin
          getOneChar(p, False, ch2, nch2);
          if nch2 = '/' then raise EHimaSyntax.Create(FileNo, LineNo, ERR_NOPAIR_COMMENT,[]);
        end;
      end;

    end;


    // ������Ȃ狌��������B�R�����g�͏ȗ��B�Ⴆ�ΐV��������B
    if isString or isString2 or isString3 or isString4 then res := res + ch
    //�s�v::else if isComment or isCommentLine then {nothing}
    else res := res + nch;
  end;

  // �����񂪑Ή����ĂȂ�
  if isString   then raise EHimaSyntax.Create(FileNo, InLineNo, ERR_NOPAIR_STRING   + '�`'+memStr,[]);
  if isString2  then raise EHimaSyntax.Create(FileNo, InLineNo, ERR_NOPAIR_STRING2  + '�`'+memStr,[]);
  if isString3  then raise EHimaSyntax.Create(FileNo, InLineNo, ERR_NOPAIR_STRING3  + '�`'+memStr,[]);
  if isString4  then raise EHimaSyntax.Create(FileNo, InLineNo, ERR_NOPAIR_STRING4  + '�`'+memStr,[]);
  if isComment  then raise EHimaSyntax.Create(FileNo, InLineNo, ERR_NOPAIR_COMMENT  + '�`'+memStr,[]);

  FSource := res;
end;

constructor THimaSourceConverter.Create(FileNo: Integer; source: AnsiString);
begin
  FSource := source;
  Self.FileNo := FileNo;
end;

// �ꕶ���؂�o�� ... �؂�o�������ʂ� ch nch �ɓ���
procedure THimaSourceConverter.getOneChar(var p: PAnsiChar; AddPointer: Boolean; var ch, nch: AnsiString);
var
  code: Integer;
  pp: PAnsiChar;
begin
  if p^ = #0 then begin ch := ''; nch := ''; Exit; end; //

  if p^ in SJISLeadBytes then
  begin
    ch   := p^ + (p+1)^; nch := '';
    code := Ord( p^ ) shl 8 + Ord( (p+1)^ );

    // �p�������͔��p��
    case code of
      $8140{�S�p�X�y�[�X}: nch := '  '; // �S�p�X�y�[�X�́A���p�Q�������Ɛ�����
      $8141{�A},$8143{�C}: nch := ',';
      $8142{�B},$8147{�G}: nch := ';';
      $8144{�D}          : nch := '.';
      $8146{�F}          : nch := ':';
      $8148{�H}          : nch := '?';
      $8149{�I}          : nch := '!';
      $814F{�O}          : nch := '^';
      $8151{�Q}          : nch := '_';
      $815E{�^}          : nch := '/';
      $8160{�`}          : nch := '~';
      $8165{�e}          : nch := '`';
      $8166{�f}          : nch := '#';
      $8167{�g}          : nch := '"';
      $8168{�h}          : nch := '"';
      $8179{�y}          : nch := '[';
      $817A{�z}          : nch := ']';
      $817B{�{}          : nch := '+';
      $817C{�|}          : nch := '-';
      $817E{�~}          : nch := '*';
      $8180{��}          : nch := '/';
      $8181{��}          : nch := '=';
      $8182{��}          : nch := '<>';
      $8183{��}          : nch := '<';
      $8184{��}          : nch := '>';
      $8185{��}          : nch := '<=';
      $8186{��}          : nch := '>=';
      $818F{��}          : nch := '\';
      $8190{��}          : nch := '$';
      $8193{��}          : nch := '%';
      $8194{��},$81A6{��}: nch := '#';
      $8195{��}          : nch := '&';
      $8196{��}          : nch := '*';
      $8197{��}          : nch := '@';
      $8162{�b}          : nch := '|';
      $8169{�i}          : nch := '(';
      $816A{�j}          : nch := ')';
      $816D{�m}          : nch := '[';
      $816E{�n}          : nch := ']';
      $816F{�o}          : nch := '{';
      $8170{�p}          : nch := '}';
      $819C{��}          : nch := '*';
      $824F..$8258{0..9} : code := code - $824F{S_JIS:0} + $30{ASCII:0};
      $8260..$8279{A..Z} : code := code - $8260{S_JIS:A} + $41{ASCII:A};
      $8281..$829A{a..z} : code := code - $8281{S_JIS:a} + $61{ASCII:a};
    else
      nch := ch;
    end;

    // ����
    if nch = '' then nch := AnsiString(Chr(code));
  end else
  begin
    // ���p�J�i��S�p��
    if (#$A1 <= p^) and (p^ <= #$DF) then
    begin
      // ���_�Ȃ瑫��
      pp := p + 1;
      if (pp^ = #$DE)or(pp^ = #$DF) then ch := p^ + pp^ else ch := p^;
      nch := convToFull(ch); // �S�p�ϊ�(API�ɗ���)
    end else
    begin
      ch := p^;
      nch := ch;
    end;
  end;
  if AddPointer then Inc(p, Length(ch));
end;

end.
