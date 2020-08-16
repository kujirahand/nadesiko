unit dll_plugin_helper;

interface
uses
  windows, SysUtils, dnako_import, dnako_import_types;


// �֐����������o�^�ł��邩�`�F�b�N����
procedure _checkTag(tag, name: DWORD);
// �֐���o�^����
procedure AddFunc(name, argStr: AnsiString; tag: Integer; func: THimaSysFunction;
  kaisetu, yomigana: AnsiString; IzonFiles: AnsiString = '');
// �������o�^����
procedure AddStrVar(name, value: AnsiString; tag: Integer; kaisetu,
  yomigana: AnsiString);
// ������o�^����
procedure AddIntVar(name: AnsiString; value, tag: Integer; kaisetu,
  yomigana: AnsiString);
// �Z�b�^�[�E�Q�b�^�[���Z�b�g����
procedure SetSetterGetter(name, setter, getter: AnsiString; tag: DWORD; desc, yomi: AnsiString);

//-----------------------------------------------------
// �t�@�C���̗L�����`�F�b�N
function CheckFileExists(var fname: AnsiString): Boolean;
// �G���[��������擾
function nako_getErrorStr: AnsiString;
//-----------------------------------------------------
// �������ȒP�Ɏ擾����
function getArg(h: DWORD; Index: Integer; UseHokan: Boolean = False): PHiValue;
function getArgInt(h: DWORD; Index: Integer; UseHokan: Boolean = False): Integer;
function getArgIntDef(h: DWORD; Index: Integer; Def:Integer): Integer;
function getArgStr(h: DWORD; Index: Integer; UseHokan: Boolean = False): AnsiString;
function getArgStrU(h: DWORD; Index: Integer; UseHokan: Boolean = False): string;
function getArgBool(h: DWORD; Index: Integer; UseHokan: Boolean = False): Boolean;
function getArgFloat(h: DWORD; Index: Integer; UseHokan: Boolean = False): HFloat;
// �����̌���ω����폜
function DeleteGobi(key: AnsiString): AnsiString;
// ���s�t�@�C���ɖ��ߍ��܂ꂽ�t�@�C������肾��
function _getEmbedFile(var f: AnsiString): Boolean;


implementation

uses nadesiko_version;

function _getEmbedFile(var f: AnsiString): Boolean;
var
  path: AnsiString;
begin
  SetLength(path, 4096);
  if (nako_getEmbedFile(PAnsiChar(f), PAnsiChar(path), 4095)) then
  begin
    f := AnsiString(path);
    Result := True;
  end else
  begin
    Result := False;
  end;
end;

function nako_getErrorStr: AnsiString;
var
  len: Integer;
begin
  len := nako_getError(nil, 0);
  SetLength(Result, len + 1);
  nako_getError(PAnsiChar(Result), len);
  Result := PAnsiChar(Result);
end;

// �����R�[�h�͈͓̔����ǂ������ׂ�
function CharInRange(p: PAnsiChar; fromCH, toCH: AnsiString): Boolean;
var
  code: Integer;
  fromCode, toCode: Integer;
begin
  // ���ʑΏۂ̃R�[�h�𓾂�
  if p^ in LeadBytes then code := (Ord(p^) shl 8) + Ord((p+1)^) else code := Ord(p^);

  // �͈͏���
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

  // �͈͏I���
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

// �����̌���ω����폜
function DeleteGobi(key: AnsiString): AnsiString;
var p: PAnsiChar;
begin
  //key := HimaSourceConverter(0, key);
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
    if p^ in LeadBytes then
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
{//old
function DeleteGobi(key: AnsiString): AnsiString;
var
  p, pS: PAnsiChar;
  pp: PAnsiChar;
  s: AnsiString;
begin
  p := PAnsiChar(key); pS := p; pp := p;

  // �Ђ炪�ȈȊO���Ō�Ɍ��ꂽ�ʒu(+1�����̏�)���L�^
  while p^ <> #0 do begin
    if p^ in LeadBytes then
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

// �������ȒP�Ɏ擾����
function getArg(h: DWORD; Index: Integer; UseHokan: Boolean = False): PHiValue;
begin
  Result := nako_getFuncArg(h, Index);
  if (Result = nil)and(UseHokan) then
  begin
    Result := nako_getSore;
  end;
end;
function getArgInt(h: DWORD; Index: Integer; UseHokan: Boolean = False): Integer;
begin
  Result := hi_int(getArg(h, Index,UseHokan));
end;
function getArgIntDef(h: DWORD; Index: Integer; Def:Integer): Integer;
var p:PHiValue;
begin
  p := nako_getFuncArg(h, Index);
  if p = nil then
  begin
    Result := Def;
  end else
  begin
    Result := hi_int(p);
  end;
end;
function getArgStr(h: DWORD; Index: Integer; UseHokan: Boolean = False): AnsiString;
begin
  Result := hi_str(getArg(h, Index,UseHokan));
end;

function getArgStrU(h: DWORD; Index: Integer; UseHokan: Boolean = False): string;
begin
  Result := hi_strU(getArg(h, Index,UseHokan));
end;


function getArgBool(h: DWORD; Index: Integer; UseHokan: Boolean = False): Boolean;
begin
  Result := hi_bool(getArg(h, Index,UseHokan));
end;
function getArgFloat(h: DWORD; Index: Integer; UseHokan: Boolean = False): HFloat;
begin
  Result := hi_float(getArg(h, Index,UseHokan));
end;


// �t�@�C���̗L�����`�F�b�N
function CheckFileExists(var fname: AnsiString): Boolean;
var
  f: AnsiString;

  function chk(f: AnsiString): Boolean;
  begin
    Result := FileExists(string(f));
    if Result then
    begin
      fname := AnsiString(f);
    end;
  end;

  function path(f: string): AnsiString;
  begin
    if Copy(f,Length(f),1) <> '\' then
    begin
      Result := AnsiString(f + '\');
    end;
  end;

begin
  Result := True;

  // ��΃p�X�w��Ȃ甲����
  if (Pos(':\', string(fname)) > 0)or(Pos('\\', string(fname)) > 0) then
  begin
    Result := FileExists(string(fname));
    Exit;
  end;

  // curdir
  if chk(path(GetCurrentDir) + fname) then Exit;
  // bokan
  f := hi_str(nako_getVariable('��̓p�X'));
  if chk(f + fname) then Exit;
  // bokan + lib
  if chk(f + 'lib\' + fname) then Exit;
  // apppath
  if chk(AnsiString(ExtractFilePath(ParamStr(0))) + fname) then Exit;
  // apppath + lib
  if chk(AnsiString(ExtractFilePath(ParamStr(0))) + 'lib\' + fname) then Exit;
  // plug-ins
  f := nako_getPluginsDir;
  if chk(f + fname) then Exit;
  
  // �Ō�܂Ō�����Ȃ�����
  Result := False;
end;

procedure AddFunc(name, argStr: AnsiString; tag: Integer; func: THimaSysFunction;
  kaisetu, yomigana: AnsiString; IzonFiles: AnsiString = '');
begin
  try
    _checkTag(tag, 0);
  except
    on e:Exception do
    begin
      raise;
      //raise Exception.Create('�w'+name+'�x(tag='+IntToStr(tag)+')���d�����Ă��܂��B');
    end;
  end;
  nako_addFunction2(PAnsiChar(name), PAnsiChar(argStr), func, tag, PAnsiChar(IzonFiles));
end;

procedure AddStrVar(name, value: AnsiString; tag: Integer; kaisetu,
  yomigana: AnsiString);
begin
  _checkTag(tag, 0);
  nako_addStrVar(PAnsiChar(name), PAnsiChar(value), tag);
end;

procedure AddIntVar(name: AnsiString; value, tag: Integer; kaisetu,
  yomigana: AnsiString);
begin
  _checkTag(tag, 0);
  nako_addIntVar(PAnsiChar(name), value, tag);
end;

// �Z�b�^�[�E�Q�b�^�[���Z�b�g����
procedure SetSetterGetter(name, setter, getter: AnsiString; tag: DWORD; desc, yomi: AnsiString);
begin
  nako_addSetterGetter(PAnsiChar(name), PAnsiChar(setter), PAnsiChar(getter), tag);
end;

// �֐����������o�^�ł��邩�`�F�b�N����
procedure _checkTag(tag, name: DWORD);
begin
  nako_check_tag(tag, name);
end;


end.

