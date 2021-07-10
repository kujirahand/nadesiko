library dnako;

{$DEFINE DNAKO}

uses
  FastMM4 in 'FastMM4.pas',
  Windows,
  SysUtils,
  nadesiko_version in 'nadesiko_version.pas',
  hima_system in 'hi_unit\hima_system.pas',
  hima_parser in 'hi_unit\hima_parser.pas',
  hima_function in 'hi_unit\hima_function.pas',
  unit_windows_api in 'hi_unit\unit_windows_api.pas',
  hima_error in 'hi_unit\hima_error.pas',
  hima_string in 'hi_unit\hima_string.pas',
  hima_token in 'hi_unit\hima_token.pas',
  hima_types in 'hi_unit\hima_types.pas',
  hima_variable in 'hi_unit\hima_variable.pas',
  hima_variable_ex in 'hi_unit\hima_variable_ex.pas',
  hima_variable_lib in 'hi_unit\hima_variable_lib.pas',
  unit_file_dnako in 'hi_unit\unit_file_dnako.pas',
  unit_string in 'hi_unit\unit_string.pas',
  BRegExp in 'hi_unit\BRegExp.pas',
  mini_func in 'hi_unit\mini_func.pas',
  mini_file_utils in 'hi_unit\mini_file_utils.pas',
  hima_stream in 'hi_unit\hima_stream.pas',
  unit_pack_files in 'hi_unit\unit_pack_files.pas',
  nako_dialog_const in 'hi_unit\nako_dialog_const.pas',
  nako_dialog_function2 in 'hi_unit\nako_dialog_function2.pas',
  common_function in 'hi_unit\common_function.pas',
  unit_text_file in 'hi_unit\unit_text_file.pas',
  mt19937 in 'hi_unit\mt19937.pas',
  wildcard2 in 'hi_unit\wildcard2.pas',
  unit_blowfish in 'hi_unit\unit_blowfish.pas',
  BlowFish in 'hi_unit\BlowFish.pas',
  CryptUtils in 'hi_unit\CryptUtils.pas',
  unit_file in 'hi_unit\unit_file.pas',
  EasyMasks in 'hi_unit\EasyMasks.pas',
  unit_pack_files_pro in 'pro_unit\unit_pack_files_pro.pas',
  unit_date in 'hi_unit\unit_date.pas';

const
  nako_OK = 1; // �֐��̐���
  nako_NG = 0; // �֐��̎��s

///<DNAKOAPI:BEGIN>
procedure nako_resetAll; stdcall; // �Ȃł����̃V�X�e�������Z�b�g����
begin
  HiSystemReset;
end;

procedure nako_free; stdcall; // �Ȃł����̃V�X�e�����������
begin
  FreeAndNil(FileMixReader);
  FreeAndNil(FHiSystem);
end;

function nako_load(sourceFile: PAnsiChar): DWORD; stdcall;// �w�Ȃł����x�̃\�[�X�t�@�C����ǂݍ���
begin
  try
    HiSystem.FIncludeBasePath := '';
    HiSystem.MainFileNo := HiSystem.LoadFromFile(string(SourceFile));
  except
    Result := nako_NG; Exit;
  end;
  Result := nako_OK;
end;

function nako_loadSource(sourceText: PAnsiChar): DWORD; stdcall;// �w�Ȃł����x�̃\�[�X�t�@�C����ǂݍ���
begin
  try
    HiSystem.FIncludeBasePath := '';
    HiSystem.MainFileNo := HiSystem.LoadSourceText(sourceText, 'system');
  except
    Result := nako_NG; Exit;
  end;
  Result := nako_OK;
end;

function nako_run: DWORD; stdcall;// nako_load() �œǂ񂾃\�[�X�t�@�C�������s����
begin
  try
    HiSystem.Run2;
  except
    Result := nako_NG; Exit;
  end;
  Result := nako_OK;
end;

function nako_run_ex: PHiValue; stdcall;// nako_load() �œǂ񂾃\�[�X�t�@�C�������s����
begin
  try
    Result := HiSystem.Run;
  except
    Result := nil;
  end;
end;

function nako_error_continue: DWORD; stdcall;// �G���[�Ŏ~�܂������s�𑱂���
begin
  try
    HiSystem.ErrorContinue2;
  except
    Result := nako_NG; Exit;
  end;
  Result := nako_OK;
end;

function nako_getError(msg: PAnsiChar; maxLen: Integer): DWORD; stdcall;// �G���[���b�Z�[�W���擾����B�߂�l�ɂ̓G���[���b�Z�[�W�̒�����Ԃ��B
begin
  Result := Length(HimaErrorMessage);
  if maxLen > 0 then
  begin
    StrLCopy(msg, PAnsiChar(HimaErrorMessage), maxLen);
  end;
end;

procedure nako_clearError(); stdcall; // ���ݕ\������Ă���G���[���������B
begin
  HimaErrorMessage := '';
end;

function nako_eval(source: PAnsiChar): PHiValue; stdcall;// source �ɗ^����ꂽ��������v���O�����Ƃ��ĕ]�����Č��ʂ�Ԃ�
begin
  try
    Result := HiSystem.Eval(source);
  except
    Result := nil;
  end;
end;

function nako_evalEx(source: PAnsiChar; var ret: PHiValue): BOOL; stdcall;// source �ɗ^����ꂽ��������v���O�����Ƃ��ĕ]�����Ď��s���ʂƐ����������ǂ�����Ԃ�
begin
  Result := True;
  try
    ret := HiSystem.Eval(source);
  except
    Result := False;
    ret    := nil;
  end;
end;

procedure nako_addFileCommand; stdcall; // �t�@�C���֘A�̖��߂��g����悤�ɃV�X�e���ɓo�^����B
begin
  HiSystem.AddSystemFileCommand;
end;

function nako_getVariable(vname: PAnsiChar): PHiValue; stdcall;// �Ȃł����ɓo�^����Ă���ϐ��̃|�C���^���擾����
var
  id: DWORD;
begin
  id := hi_tango2id(DeleteGobi(vname));
  Result := HiSystem.GetVariable(id);
end;

function nako_getVariableFromId(vname_id: DWORD): PHiValue; stdcall;// ID�ԍ�����Ȃł����ɓo�^����Ă���ϐ��̃|�C���^���擾����
begin
  Result := HiSystem.GetVariable(vname_id);
end;

procedure nako_setVariable(vname: PAnsiChar; value: PHiValue); stdcall; // �Ȃł����ɕϐ���o�^����(�O���[�o���Ƃ���)
begin
  value.VarID := hi_tango2id(DeleteGobi(vname));
  HiSystem.Global.RegistVar(value);
end;

function nako_addFunction(name, args: PAnsiChar; func: THimaSysFunction; tag: Integer): DWORD; stdcall; // �Ǝ��֐���ǉ�����
begin
  if HiSystem.AddFunction(name, args, func, tag, '') then
    Result := NAKO_OK
  else
    Result := NAKO_NG;
end;

function nako_addFunction2(name, args: PAnsiChar; func: THimaSysFunction; tag: Integer; IzonFiles: PAnsiChar): DWORD; stdcall; // �Ǝ��֐���ǉ�����
begin
  if HiSystem.AddFunction(name, args, func, tag, IzonFiles) then
    Result := NAKO_OK
  else
    Result := NAKO_NG;
end;

function nako_getFuncArg(handle: DWORD; index: Integer): PHiValue; stdcall; // nako_addFunction �œo�^�����R�[���o�b�N�֐�������������o���̂Ɏg��
begin
  Result := hima_system.nako_getFuncArg(handle, index);
end;

function nako_getSore: PHiValue; stdcall; // �ϐ��w����x�ւ̃|�C���^���擾����
begin
  Result := HiSystem.Sore;
end;

procedure nako_addIntVar(name: PAnsiChar; value: Integer; tag: Integer); stdcall; // �����^�̕ϐ����V�X�e���ɒǉ�����B(tag�ɂ͊�]�̒P��ID���w��)
var
  p: PHiValue;
  key: AnsiString;
  id: DWORD;
begin
  key := DeleteGobi(name);
  id  := HiSystem.TangoList.GetID(key, tag);
  p := HiSystem.CreateHiValue(id);
  p.Designer := 1;
  hi_setInt(p, value);
end;

procedure nako_addStrVar(name: PAnsiChar; value: PAnsiChar; tag: Integer); stdcall; // ������^�̕ϐ����V�X�e���ɒǉ�����B
var
  p: PHiValue;
  key: AnsiString;
  id: DWORD;
begin
  key := DeleteGobi(name);
  id  := HiSystem.TangoList.GetID(key, tag);
  p := HiSystem.CreateHiValue(id);
  p.Designer := 1;
  hi_setStr(p, value);
end;

procedure nako_stop; stdcall; // �V�X�e���̎��s�𒆎~����
begin
  HiSystem.FlagEnd := True;
end;

procedure nako_continue; stdcall; // �V�X�e���̎��s���p������
begin
  HiSystem.FlagEnd      := False;
  HiSystem.BreakLevel   := BREAK_OFF;
  HiSystem.BreakType    := btNone;
  HiSystem.ReturnLevel  := BREAK_OFF;
end;

function nako_id2tango(id: DWORD; tango: PAnsiChar; maxLen: DWORD): DWORD; stdcall; // �P��Ǘ��pID����P�ꖼ���擾����B�߂�l�͏�ɒP��̒�����Ԃ��B
var s: AnsiString;
begin
  s       := hi_id2tango(id);
  Result  := Length(s);
  if maxLen > 0 then StrLCopy(tango, PAnsiChar(s), maxLen);
end;

function nako_tango2id(tango: PAnsiChar): DWORD; stdcall; // �P�ꖼ����P��Ǘ��pID���擾����
begin
  Result := hi_tango2id(AnsiString(tango));
end;

function nako_var2str(value: PHiValue; str: PAnsiChar; maxLen: DWORD): DWORD; stdcall; // PHiValue�𕶎���ɕϊ�����str�ɃR�s�[����B
var
  s: AnsiString;
  copyLen: DWORD;
begin
  s := hi_str(value);

  Result := Length(s);
  if (str = nil)or(maxLen = 0) then Exit;

  copyLen := Result;
  if copyLen > maxLen then copyLen := maxLen;

  if Result = 0 then
  begin
    StrCopy(str, ''); Exit;
  end;

  if Result > 0 then
  begin
    Move(s[1], str^, copyLen);
  end;
end;

function nako_var2cstr(value: PHiValue; str: PAnsiChar; maxLen: DWORD): DWORD; stdcall; // PHiValue���k���I�[������ɕϊ�����str�ɃR�s�[����B���e���r���œr�؂��\��������B
var
  s: AnsiString;
  copyLen: DWORD;
begin
  s := hi_str(value);

  Result := Length(s);
  if (str = nil)or(maxLen = 0) then Exit;

  copyLen := Result;
  if copyLen >= maxLen then copyLen := maxLen - 1;

  if Result = 0 then
  begin
    StrCopy(str, ''); Exit;
  end;

  if Result > 0 then
  begin
    StrLCopy(str, PAnsiChar(s), copyLen);
  end;
end;


function nako_var2int(value: PHiValue): Integer; stdcall; // PHiValue��Longint�ɕϊ����ē���
begin
  Result := hi_int(value);
end;

function nako_var2double(value: PHiValue): Double; stdcall; // PHiValue��Double�ɕϊ����ē���
begin
  Result := hi_Float(value); // ���S�ɕϊ��͂ł��Ȃ������������̐��x�ϊ������͂�
end;

function nako_var2extended(value: PHiValue): Extended; stdcall; // PHiValue��Extended�ɕϊ����ē���
begin
  Result := hi_Float(value);
end;

procedure nako_str2var(str: PAnsiChar; value: PHiValue); stdcall; // �k��������� PHiValue �ɕϊ����ăZ�b�g
begin
  hi_setStr(value, AnsiString(str));
end;

procedure nako_bin2var(bin: PAnsiChar; len: DWORD; value: PHiValue); stdcall; // �o�C�i���f�[�^�𕶎���Ƃ���value�ɃZ�b�g
var
  s: AnsiString;
begin
  if len = 0 then
  begin
    hi_setStr(value, ''); Exit;
  end;
  SetLength(s, len);
  Move(bin^, s[1], len);
  hi_setStr(value, s);
end;

procedure nako_int2var(num: Integer; value: PHiValue); stdcall; // �k��������� PHiValue �ɕϊ����ăZ�b�g
begin
  hi_setInt(value, num);
end;

procedure nako_double2var(num: Double; value: PHiValue); stdcall; // �k��������� PHiValue �ɕϊ����ăZ�b�g
begin
  hi_setFloat(value, num);
end;

function nako_var_new(name: PAnsiChar): PHiValue; stdcall; // �V�K PHiValue �̕ϐ����쐬����Bname��nil��n���ƕϐ��������Ȃ��Œl�����쐬���ϐ���������ƃO���[�o���ϐ��Ƃ��ēo�^����B
begin
  if name <> nil then
  begin
    Result := HiSystem.CreateHiValue(hi_tango2id(DeleteGobi(name)));
  end else
  begin
    Result := hi_var_new;
  end;
end;

procedure nako_var_clear(value: PHiValue); stdcall; // �ϐ� value �̒l���N���A����
begin
  hi_var_clear(value);
end;

procedure nako_var_free(value: PHiValue); stdcall; // �ϐ� value �̒l���������
begin
  hima_system.nako_var_free(value);
end;

function nako_ary_get(v: PHiValue; index: Integer): PHiValue; stdcall; // v ��z��Ƃ��� v[index]�̒l�𓾂�
begin
  Result := hi_ary_get(v, index);
end;

function nako_ary_getCsv(v: PHiValue; Row, Col: Integer): PHiValue; stdcall; // v ��񎟌��z��Ƃ��� v[Row][Col]�̒l�𓾂�
begin
  Result := hi_ary_getCsv(v, Row, Col);
end;

function nako_ary_count(v: PHiValue): Integer; stdcall; // v �̔z��̗v�f���𓾂�
begin
  Result := hi_ary_count(v);
end;

procedure nako_varCopyData(src, dest: PHiValue); stdcall; // PHiValue�^�̕ϐ��̓��e���܂�܂�R�s�[����
begin
  hi_var_copyData(src, dest);
end;

procedure nako_varCopyGensi(src, dest: PHiValue); stdcall; // PHiValue�^�̕ϐ��̓��e���R�s�[����(���n�^�̂ݕ���)
begin
  hi_var_copyGensi(src, dest);
end;

procedure nako_setMainWindowHandle(h: Integer); stdcall; // ���C���E�B���h�E�n���h����ݒ肷��i�_�C�A���O�\���֘A�̖��߂ŗ��p�j
begin
  hima_function.MainWindowHandle := h;
end;

function nako_getMainWindowHandle:DWORD; stdcall; // ���C���E�B���h�E�n���h�����擾����i�_�C�A���O�\���֘A�̖��߂ŗ��p�j
begin
  Result := hima_function.MainWindowHandle;
end;

function nako_getGroupMember(groupName, memberName: PAnsiChar): PHiValue; stdcall; // �O���[�v�̃����o���擾����B�����o�����݂��Ȃ����nil���Ԃ�B
var
  g: PHiValue;
  grp: THiGroup;
  m_id: DWORD;
begin
  Result := nil;
  // �O���[�v�𓾂�
  g := HiSystem.GetVariable(hi_tango2id(DeleteGobi(groupName)));
  if g=nil then Exit;
  if g.VType <> varGroup then Exit;
  grp := hi_group(g);
  m_id := hi_tango2id(DeleteGobi(memberName));
  // �O���[�v�̃����o��T��
  Result := grp.FindMember(m_id);
end;

function nako_hasEvent(groupName, memberName: PAnsiChar): PHiValue; stdcall; // �O���[�v�̃����o���擾����B�����o�����݂��Ȃ����nil���Ԃ�B
var
  g: PHiValue;
begin
  Result := nil;
  g := HiSystem.GetVariable(hi_tango2id(groupName));
  if g=nil then Exit;
  if g.VType <> varGroup then Exit;
  Result := hi_group(g).FindMember(hi_tango2id(memberName));
end;

procedure nako_addSetterGetter(vname, setter, getter:PAnsiChar; tag: DWORD); stdcall; // �ϐ���vname�ɃQ�b�^�[�Z�b�^�[��ݒ肷��
begin
  HiSystem.SetSetterGetter(vname, setter, getter, tag, '', '');
end;

procedure nako_setDebugEditorHandle(h: DWORD); stdcall; // �f�o�b�O���̃G�f�B�^�n���h����ݒ肷��
begin
  HiSystem.DebugEditorHandle := h;
end;

procedure nako_setDebugLineNo(b: BOOL); stdcall; // �f�o�b�O���̃G�f�B�^�֍s�ԍ���\�����邩
begin
  HiSystem.DebugLineNo := b;
end;

procedure nako_group_create(v: PHiValue); stdcall; // �ϐ�v���O���[�v�^�ɕύX����
begin
  hi_group_create(v);
end;

procedure nako_group_addMember(group, member: PHiValue); stdcall; // �O���[�v�ϐ�group�Ƀ����omember��ǉ�����
begin
  hi_group(group).Add(member);
end;

function nako_group_findMember(group: PHiValue; memberName: PAnsiChar): PHiValue; stdcall; // �O���[�v�ϐ�group�̃����omemberName����������
var
  vid: DWORD;
  s: AnsiString;
begin
  s := memberName;
  s := DeleteGobi(s);
  vid := hi_tango2id(s);
  group := hi_getLink(group);
  Result := hi_group(group).FindMember(vid);
end;

function nako_group_exec(group: PHiValue; memberName: PAnsiChar): PHiValue; stdcall; // �O���[�v�ϐ�group�̃����omemberName���C�x���g�Ȃ�Ύ��s�����ʂ�Ԃ�
begin
  Result := HiSystem.RunGroupEvent(group, hi_tango2id(DeleteGobi(memberName)));
end;

function nako_debug_nadesiko(p: PAnsiChar; len: DWORD): DWORD; stdcall; // nako_load�����\���؂��ēx�\�[�X�ɕϊ�����
var s: AnsiString;
begin
  s := HiSystem.DebugProgramNadesiko;
  Result := Length(s);
  StrLCopy(PAnsiChar(s), p, len);
end;

procedure nako_ary_create(p: PHiValue); stdcall; // p ��z��Ƃ��Đ�������
begin
  hi_ary_create(p);
end;

procedure nako_ary_add(ary, val: PHiValue); stdcall; // p ��z��Ƃ��Đ�������
begin
  hi_ary(ary).Add(val);
end;

procedure nako_check_tag(tag:Integer; name: DWORD); stdcall; // ���߃^�O���d�����ĂȂ����`�F�b�N
begin
  _checkTag(tag, name);
end;

procedure nako_DebugNextStop; stdcall; // ���̖��߂ŏI������
begin
  HiSystem.DebugNextStop := True;
end;

procedure nako_LoadPlugins; stdcall; // �v���O�C������荞��
begin
  HiSystem.LoadPlugins;
end;

function nako_openPackfile(fname: PAnsiChar): Integer; stdcall; // ���s�t�@�C�� fname �̃p�b�N�t�@�C�����J���B���s�Ȃ�A0��Ԃ��B
begin
  errLog('nako_openPackfile:' + AnsiString(fname));
  if OpenPackFile(string(AnsiString(fname))) then
  begin
    FileMixReader.autoDelete := True;
    Result := Integer(FileMixReader);
  end else
  begin
    Result := 0;
  end;
end;

function nako_runPackfile: DWORD; stdcall; // nako_openPackfile �ŊJ�����t�@�C���ɂ��� nadesiko.nako ���J���Ď��s����B���s�́Anako_NG��Ԃ��B
var
  src: AnsiString;
begin
  Result := nako_NG;

  if FileMixReader = nil then Exit;
  try
    if not FileMixReader.ReadFileAsString('nadesiko.nako', src) then Exit;
  except
    on e:Exception do begin
      errLog('nako_runPackfile.load.error:' + AnsiString(e.Message));
      Exit;
    end;
  end;
  try
    HiSystem.MainFileNo := HiSystem.LoadSourceText(src, 'nadesiko.nako');
  except
    on e:Exception do begin
      errLog('nako_runPackfile.run.error:' + AnsiString(e.Message));
      Exit;
    end;
  end;
  Result := nako_OK;
end;

function nako_openPackfileBin(packname: PAnsiChar): Integer; stdcall; // packname �̃p�b�N�t�@�C�����J���B���s�Ȃ�A0��Ԃ��B
begin
  errLog('nako_openPackfileBin:' + AnsiString(packname));

  try
    unit_pack_files.FileMixReader := TFileMixReader.Create(string(AnsiString(packname)));
    unit_pack_files.FileMixReader.autoDelete := True;
    unit_pack_files.FileMixReaderSelfCreate := True;
    Result := Integer(unit_pack_files.FileMixReader);
  except
    Result := 0;
  end;
end;


function nako_closePackfile(dummy: PAnsiChar): Integer; stdcall; // ���s�t�@�C���̃p�b�N�t�@�C�������i��Еt���j�B���s�Ȃ�A0��Ԃ��B
begin
  if FileMixReader <> nil then
  begin
    errLog('nako_closePackfile:' + AnsiString(FileMixReader.TempFile));
    try
      FreeAndNil(FileMixReader);
    except
    end;
  end;
  Result := 0;
end;


function nako_getPackFileHandle: Integer; stdcall; // ���s�t�@�C���ɂ������A�p�b�N�t�@�C���̑���ɕK�v�ȁATMixFileReader�̃n���h����Ԃ��B
begin
  Result := Integer(FileMixReader);
end;

procedure nako_setPackFileHandle(handle: DWORD); stdcall; // ���s�t�@�C���ɂ������ŁA���s�t�@�C�����Ńp�b�N�t�@�C�����J�����ꍇ���̊֐����Ă�
begin
  unit_pack_files.FileMixReader := TFileMixReader(Integer(handle));
end;

procedure nako_makeReport(fname: PAnsiChar); stdcall; // ��荞�񂾃t�@�C���A�v���O�C���̃��|�[�g���쐬����
var
  s: AnsiString;
  path: string;
begin
  s := HiSystem.makeDllReport;
  path := ExtractFilePath(fname);
  ForceDirectories(path);
  FileSaveAll(s, fname);
end;

procedure nako_reportDLL(fname: PAnsiChar); stdcall; // DLL�𗘗p�������Ƃ𖾎�����..���|�[�g�ɉ�����
begin
  HiSystem.plugins.addDll(string(AnsiString(fname)));
end;

function nako_hasPlugins(dllName: PAnsiChar): BOOL; stdcall; // �w�肵���v���O�C�����g���Ă��邩�H
var
  i: Integer;
  f: AnsiString;
  s: string;
  dll: AnsiString;
begin
  Result := False;
  dll := AnsiString(dllName);
  dll := UpperCaseEx(dll);

  for i := 0 to HiSystem.plugins.Count - 1 do
  begin
    s := THiPlugin(HiSystem.plugins.Items[i]).FullPath;
    s := (ExtractFileName(s));
    f := UpperCaseEx(AnsiString(s));
    if f = dll then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure nako_hash_create(v: PHiValue); stdcall; // �lv���n�b�V���`���ɕϊ�����
begin
  hi_hash_create(v);
end;
function nako_hash_get(hash: PHiValue; key: PAnsiChar): PHiValue; stdcall; // hash��key�̒l���擾����
begin
  hi_hash_create(hash);
  Result := hi_hash_get(hash, key);
end;
procedure nako_hash_set(hash: PHiValue; key: PAnsiChar; value: PHiValue); stdcall; // hash��key��value��ݒ肷��
begin
  hi_hash_create(hash);
  hi_hash_set(hash, key, value);
end;
function nako_hash_keys(hash: PHiValue; s: PAnsiChar; len: Integer): Integer; stdcall; // hash��key�ꗗ�𓾂�
var
  list: AnsiString;
begin
  hi_hash_create(hash);
  list := hi_hash(hash).EnumKeys;
  StrLCopy(s, PAnsiChar(list), len);
  Result := Length(list);
end;

procedure nako_getLineNo(fileNo, lineNo: PInteger); stdcall; // ���݂̎��s�s�𓾂�
begin
  // ---
  fileNo^ := HiSystem.LastFileNo; // error
  lineNo^ := HiSystem.LastLineNo;
  //
end;

function nako_getSourceText(fileNo: Integer; s: PAnsiChar; len: DWORD): DWORD; stdcall; // ���݂̎��s�s�𓾂�
var
  txt: AnsiString;
begin
  txt := HiSystem.GetSourceText(fileNo);
  Result := Length(txt);
  if len > 0 then StrLCopy(s, PAnsiChar(txt), len);
end;

function nako_getFilename(fileNo: Integer; outstr: PAnsiChar; len: DWORD): DWORD; stdcall; // fileno ����t�@�C�����𓾂�
var
  f: THimaFile;
  s: AnsiString;
begin
  f := HiSystem.TokenFiles.FindFileNo(fileNo);
  s := AnsiString(f.Path + f.Filename);
  if len > 0 then StrLCopy(outstr, PAnsiChar(s), len);
  Result := nako_OK;
end;

procedure nako_pushRunFlag; // �C�x���g�̎��s�O�Ɏ��s�t���O��ޔ����Ă��������Ƃ��Ɏg��
begin
  HiSystem.PushRunFlag;
end;

procedure nako_popRunFlag; // �C�x���g�̎��s�O�Ɏ��s�t���O��ޔ��������̂�߂��Ƃ��Ɏg��
begin
  HiSystem.PopRunFlag;
end;

function nako_callSysFunction(func_id:DWORD; args: PHiValue):PHiValue; stdcall; // �Ȃł����̃V�X�e���֐���ID���w�肵�ČĂ�
var
  p: PHiValue;
  HiFunc: THiFunction;
  a: THiArray;
begin
  Result := nil;
  if (args = nil) then
  begin
    a := THiArray.Create;
  end else
  begin
    a := THiArray(args.ptr);
  end;
  p := HiSystem.Namespace.GetVar(func_id);
  if p = nil then Exit;
  if p.VType = varFunc then
  begin
    HiFunc := p.ptr;
    try
      Result := THimaSysFunction(HiFunc.PFunc)(a);
    finally
    end;
  end;
end;

procedure nako_setDNAKO_DLL_handle(h: DWORD); stdcall; // dnako.dll �����[�h�����Ƃ��ɁA���̃n���h�����Z�b�g����
begin
  dnako_dll_handle := h;
end;

procedure nako_setPluginsDir(path: PAnsiChar); stdcall; // plug-ins �t�H���_���w�肷��
begin
  HiSystem.PluginsDir := string(path);
end;

function nako_getPluginsDir(): PAnsiChar; stdcall; // plug-ins �t�H���_���擾����
begin
  Result := PAnsiChar(AnsiString(HiSystem.PluginsDir));
end;

procedure test; stdcall; // �e�X�g
begin
  HiSystem.Test;
end;

function nako_getVersion(): PAnsiChar; stdcall; // �Ȃł����̃o�[�W�����𕶎���œ���
begin
  Result := PAnsiChar(NADESIKO_VER);
end;

function nako_getUpdateDate(): PAnsiChar; stdcall; // �Ȃł����̍X�V���𕶎���œ���
begin
  Result := PAnsiChar(NADESIKO_DATE);
end;

function nako_getNADESIKO_GUID(): PAnsiChar; stdcall; // �Ȃł�����GUID��Ԃ�
begin
  Result := PAnsiChar(NADESIKO_GUID);
end;

function nako_getEmbedFile(find_file: PAnsiChar; outfile: PAnsiChar; len: DWORD): BOOL; stdcall; // ���s�t�@�C���ɖ��ߍ��܂ꂽ���\�[�X������΃t�@�C����Ԃ�
var
  f, org: AnsiString;
begin
  Result := False;
  org := AnsiString(find_file);
  f := org;
  if getEmbedFile(f) then
  begin
    StrLCopy(outfile, PAnsiChar(f), len);
    Result := True;
  end;
end;

function nako_getLastUserFuncID():DWORD; stdcall;// �Ō�Ɏ��s�������[�U�[�֐��𓾂�
begin
  Result := LastUserFuncID;
end;

function nako_checkLicense(license_name:PAnsiChar; license_code:PAnsiChar): DWORD; stdcall;// ���C�Z���X����Ă��邩�m�F����
var
  path: AnsiString;
  code: AnsiString;
begin
  Result := nako_NG;
  path := AnsiString(AppDataDir) + 'com.nadesi.dll.dnako\license\';
  path := path + AnsiString(license_name);
  if not FileExists(string(path)) then Exit;
  code := FileLoadAll(path);
  if AnsiString(license_code) = code then
  begin
    Result := nako_OK;
  end;
end;

function nako_registerLicense(license_name:PAnsiChar; license_code:PAnsiChar): DWORD; stdcall;// ���C�Z���X�R�[�h����������
var
  path: AnsiString;
begin
  Result := nako_NG;
  try
    path := AnsiString(AppDataDir) + 'com.nadesi.dll.dnako\license\';
    ForceDirectories(string(path));
    path := path + AnsiString(license_name);
    FileSaveAll(AnsiString(license_code), path);
    Result := nako_OK;
  except
    Exit;
  end;
end;

///<DNAKOAPI:END>


exports
  nako_getVersion,
  nako_getUpdateDate,
  nako_resetAll,
  nako_free,
  nako_load,
  nako_loadSource,
  nako_run,
  nako_run_ex,
  nako_getError,
  nako_eval,
  nako_evalEx,
  nako_addFileCommand,
  nako_getVariable,
  nako_setVariable,
  nako_addFunction,
  nako_addFunction2,
  nako_getSore,
  nako_id2tango,
  nako_tango2id,
  nako_var2str,
  nako_var2int,
  nako_var2double,
  nako_var2extended,
  nako_str2var,
  nako_int2var,
  nako_double2var,
  nako_var_new,
  nako_getFuncArg,
  nako_addIntVar,
  nako_addStrVar,
  nako_varCopyData,
  nako_varCopyGensi,
  nako_getGroupMember,
  nako_stop,
  nako_continue,
  nako_setMainWindowHandle,
  nako_getMainWindowHandle,
  nako_addSetterGetter,
  nako_setDebugEditorHandle,
  nako_setDebugLineNo,
  nako_group_create,
  nako_group_addMember,
  nako_group_findMember,
  nako_group_exec,
  nako_debug_nadesiko,
  nako_ary_create,
  nako_ary_add,
  nako_check_tag,
  nako_DebugNextStop,
  nako_var_clear,
  nako_var2cstr,
  nako_LoadPlugins,
  nako_var_free,
  nako_bin2var,
  nako_openPackfile,
  nako_runPackfile,
  nako_closePackfile,
  nako_openPackfileBin,
  nako_getPackFileHandle,
  nako_makeReport,
  nako_hasPlugins,
  nako_hash_create,nako_hash_get,nako_hash_set,nako_hash_keys,
  nako_getLineNo,
  nako_getSourceText,
  nako_error_continue,
  nako_ary_get,
  nako_ary_getCsv,
  nako_ary_count,
  nako_hasEvent,
  nako_pushRunFlag,
  nako_popRunFlag,
  nako_callSysFunction,
  nako_reportDLL,
  nako_setPackFileHandle,
  nako_setDNAKO_DLL_handle,
  nako_getPluginsDir,
  nako_setPluginsDir,
  nako_clearError,
  nako_getNADESIKO_GUID,
  nako_getEmbedFile,
  nako_getFilename,
  nako_getLastUserFuncID,
  nako_checkLicense,
  nako_registerLicense,
  nako_getVariableFromId,
  test;
  
begin
end.
 