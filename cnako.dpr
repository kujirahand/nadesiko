program cnako;

{$APPTYPE CONSOLE}

uses
  FastMM4 in 'FastMM4.pas',
  SysUtils,
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  cnako_function in 'hi_unit\cnako_function.pas',
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  dnako_loader in 'hi_unit\dnako_loader.pas',
  unit_pack_files in 'hi_unit\unit_pack_files.pas',
  hima_types in 'hi_unit\hima_types.pas',
  unit_string in 'hi_unit\unit_string.pas',
  mt19937 in 'hi_unit\mt19937.pas',
  hima_stream in 'hi_unit\hima_stream.pas',
  mini_file_utils in 'hi_unit\mini_file_utils.pas',
  EasyMasks in 'hi_unit\EasyMasks.pas',
  nadesiko_version in 'nadesiko_version.pas'

  {$IFDEF DELUX_VERSION}
  ,unit_pack_files_pro in 'pro_unit\unit_pack_files_pro.pas'
  {$ENDIF}
  ;

var
  _nako_loader: TDnakoLoader;
  debugmode: Boolean = False;

function ExtractFilePath(const s: AnsiString): AnsiString;
var
  ss: AnsiString;
  p, pEnd, pFrom: PAnsiChar;
begin
  if s = '' then
  begin
    Result := '';
    Exit;
  end;

  SetLength(ss, Length(s));
  Move(s[1], ss[1], Length(s));

  p := PAnsiChar(ss);
  pFrom := p;
  pEnd  := nil;
  while p^ <> #0 do
  begin
    if Ord(p^) < $80 then
    begin
      if p^ = '\' then pEnd := p;
      Inc(p);
    end else
    begin
      Inc(p, 2);
    end;
  end;
  if pEnd <> nil then
  begin
    pEnd^ := #0;
    Result := AnsiString( PAnsiChar(pFrom) );
    if Copy(Result, Length(Result), 1) <> '\' then Result := Result + '\';
  end else
  begin
    Result := '';
  end;
end;

procedure ErrLoad;
begin
  nako_eval_str2('�u===========================================================�v�ƕ\���B');
  nako_eval_str2('�w���{��v���O���~���O����u�Ȃł����v�x�ƕ\���B');
  nako_eval_str2('�u===========================================================�v�ƕ\���B');
  nako_eval_str2('�u�v���O���������s�t�@�C��(cnako.exe)�փh���b�v���Ă��������B�v�ƕ\���B');
  nako_eval_str2('�u�v�ƕ\���B');
  nako_eval_str2('�u> �i�f�V�R�o�[�W���� = {�i�f�V�R�o�[�W����}�v�ƕ\���B');
  nako_eval_str2('�u> �i�f�V�R�ŏI�X�V�� = {�i�f�V�R�ŏI�X�V��}�v�ƕ\���B');
end;

procedure main;
var
  src, err, s, path: AnsiString;
  res, len: Integer;
  i: Integer;
  FlagOneLiner: Boolean;

  procedure ExitW;
  var s: AnsiString;
  begin
    if getMode = CNAKO_MODE_EXE then ReadLn;
    if debugmode then
    begin
      s := AnsiString(ExtractFilePath(AnsiString(ParamStr(0)))) + 'report.txt';
      nako_makeReport(PAnsiChar(s));
    end;
    Exit;
  end;

  procedure __loadFromCommandLine;
  begin
    // --- �R�}���h���C������̋N��
    if ParamCount = 0 then begin ErrLoad; Exit; end;
    nako_addFileCommand;
    nako_LoadPlugins;

    // --- �I�v�V�����̉��
    src := '';
    i := 1;
    while i <= ParamCount do
    begin
      s := AnsiString(ParamStr(i));
      if (Copy(s, 1, 6) = '-debug') then
      begin
        debugmode := True;
        Inc(i);
      end else
      if (s = '/w')or(s = '-w') then
      begin
        Inc(i); setMode(CNAKO_MODE_EXE);
      end else
      if (s = '/e')or(s = '-e') then
      begin
        // �������C�i�[
        Inc(i);
        src := AnsiString(ParamStr(i));
        Inc(i);
        FlagOneLiner := True;
      end else
      begin
        // �\�[�X
        if src = '' then src := s;
        Inc(i);
      end;
    end;
    // ���s���ׂ��\�[�X���Ȃ��ꍇ
    if src = '' then
    begin
      ErrLoad; ExitW;
    end;
    // �\�[�X�����s
    path := ExtractFilePath(src);
    if path = '' then path := ExtractFilePath(AnsiString(ParamStr(0)));
    nako_eval_str2('!�ϐ��錾���s�v'#13#10'��̓p�X��"'+path+'"'#13#10);
    //
    if FlagOneLiner then
    begin
      nako_eval_str(src);
      ExitW;
    end else
    begin
      res := nako_load(PAnsiChar(src));
    end;
  end;

begin
  FlagOneLiner := False;
  res := nako_OK;
  // �p�b�N�t�@�C�����`�F�b�N
  try
    _nako_loader := TDnakoLoader.Create(0);
  except
    WriteLn('DNAKO.DLL �̃��[�h�Ɏ��s���܂����B');
    ReadLn;
    Halt;
  end;
  try
    // cnako ��p�̃R���\�[���n���߂�o�^
    console_addCommand;
    if _nako_loader.hasPackfile then
    begin
      // --- ���s�t�@�C������̋N��
      nako_addFileCommand;
      nako_LoadPlugins;
      path := ExtractFilePath(AnsiString(ParamStr(0)));
      nako_eval_str2('!�ϐ��錾���s�v'#13#10'��̓p�X��"'+path+'"'#13#10);
      res := nako_runPackfile;
    end else
    begin
      __loadFromCommandLine;
    end;
  finally
    //nako_loader.Free;
  end;

  // ���[�h����
  if res = nako_NG then
  begin
    // �v���O�����̎��s�Ɏ��s�����Ƃ�
    len := nako_getError(nil, 0);
    SetLength(err, len);
    nako_getError(PAnsiChar(err), len);
    cout(err);
    ExitW;
    Exit;
  end;

  // �v���O�����̎��s
  try
    if nako_run = nako_NG then
    begin
      // �v���O�����̎��s�Ɏ��s�����Ƃ�
      len := nako_getError(nil, 0);
      SetLength(err, len);
      nako_getError(PAnsiChar(err), len);
      cout(err);
      ExitW;
      Exit;
    end;
  except
    begin
      cout('�v���I�ȃG���[�łȂł����͏I�����܂��B');
      ExitW;
      Exit;
    end;
  end;
  ExitW;
  Exit;
end;

//------------------------------------------------------------------------------
// ���C���v���O����
begin
  //ReportMemoryLeaksOnShutdown := False;
  _nako_loader := nil;
  try
    try
      main;
      if _nako_loader <> nil then
      begin
        nako_free;
      end;
    except
    end;
  finally
    FreeAndNil(_nako_loader);
  end;
end.
