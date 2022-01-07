unit dnako_loader;

// DNAKO �̃C���|�[�g���s��

interface
uses
  {$IFDEF Win32}
  Windows, 
  {$ENDIF}
  Classes, unit_pack_files, dnako_import;

type
  TDnakoLoader = class
  private
    FhasPackfile: Boolean;
    reader: TFileMixReader;
    FPluginsDir: string;
    FDnakoHandle: THandle;
    FPackfile: string;
    FMainWinHandle: THandle;
    procedure extractDLLFile;
  public
    constructor Create(MainWinHandle: THandle);
    destructor Destroy; override;
    procedure includeLib(nakofile: AnsiString);
    procedure eval(src: AnsiString);
    procedure checkBokanPath;
  public
    function load_DNAKO_DLL: Boolean;
    property hasPackfile: Boolean read FhasPackfile;
    property PluginsDir: string read FPluginsDir;
    property Packfile: string read FPackfile;
  end;


implementation

uses mini_file_utils, SysUtils, dnako_import_types, nadesiko_version;

const
  DNAKO_DLL = 'dnako.dll';

{ TDnakoLoader }

constructor TDnakoLoader.Create(MainWinHandle: THandle);

  // ex) test.nako -debug -pack test.bin
  procedure checkArgs;
  var
    i: Integer;
  begin
    FPackfile := '';
    i := 1;
    while i <= ParamCount do
    begin
      if ParamStr(i) = '-pack' then
      begin
        Inc(i);
        FPackfile := mini_file_utils.FindDLLFile((ParamStr(i)));
        if not FileExists(FPackfile) then
        begin
          FPackfile := '';
        end;
        Inc(i);
        Continue;
      end;
      Inc(i);
    end;
  end;

var
  fpack: string;
begin
  // [�菇]
  // (1) �������g�� packfile ������Ε�������
  // (2) packfile ���� dnako.dll ���������o���ăe���|�����t�@�C���ɓW�J����
  // (3) dnako.dll �����[�h����
  // (4) dnako.dll �ŉ��߂ăp�b�N�t�@�C�����J��
  // (5) �v���O�C���̃��[�h�Ȃ�

  FMainWinHandle := MainWinHandle;
  checkArgs;

  // (1) packfile �̕���
  if (FPackfile <> '') then
  begin
    unit_pack_files.FileMixReader := TFileMixReader.Create(FPackfile);
    FhasPackfile := True;
    reader := unit_pack_files.FileMixReader;
  end else
  // (2) EXE�t�@�C���ƈꏏ�ɍ쐬����packfile�̏ꍇ
  begin
    fpack := ExtractFilePath(ParamStr(0)) + 'plug-ins\' +
      ChangeFileExt(ExtractFileName(ParamStr(0)), '.nakopack');
    if FileExists(fpack) then
    begin
      FPackfile := fpack;
      unit_pack_files.FileMixReader := TFileMixReader.Create(FPackfile);
      FhasPackfile := True;
      reader := unit_pack_files.FileMixReader;
    end;
    // ����EXE�t�@�C���Ɏd����ł���ꍇ(�Z�L�����e�B�̖��̂��ߗ��p���Ȃ�)
    // FhasPackfile := OpenPackFile(ParamStr(0));
    // reader := unit_pack_files.FileMixReader;
  end;
  // set default plug-ins dir
  FPluginsDir := AppPath + 'plug-ins\';
  if FhasPackfile then
  begin
    reader.autoDelete := False;
    extractDLLFile;
    if FileExists(AppPath + 'plug-ins\' + DNAKO_DLL) then
    begin
      FPluginsDir := AppPath + 'plug-ins\';
    end;
  end;
  if reader <> nil then
  begin
    FPackfile := reader.TempFile;
    FreeAndNil(reader);
  end;
  // load "dnako.dll"
  if not load_DNAKO_DLL then raise Exception.Create('DNAKO.DLL �̃��[�h�Ɏ��s');
end;

destructor TDnakoLoader.Destroy;
begin
  // dnako.dll �ŉ�������
  FileMixReader := nil;
  reader := nil;
  inherited;
end;

procedure TDnakoLoader.extractDLLFile;
var
  dir: string;
begin
  dir := TempDir + 'com.nadesi.runtime\' + NADESIKO_VER + '\plug-ins\';
  reader.ExtractPatternFiles(dir, '*.dll', True);
  if FileExists(dir + DNAKO_DLL) then
  begin
    FPluginsDir := dir;
  end;
end;

procedure TDnakoLoader.checkBokanPath;
var
  p: PHiValue;
  path: string;
begin
  if FhasPackfile then
  begin
    // ��̓p�X���擾����
    p := nako_getVariable('��̓p�X');
    if p = nil then p := hi_var_new('��̓p�X');
    path := AppPath;
    hi_setStr(p, AnsiString(path));
    chdir(path);
  end;
end;

procedure TDnakoLoader.includeLib(nakofile: AnsiString);
begin
  eval('!"'+nakofile+'"����荞�ށB'#13#10+
       '!�ϐ��錾���s�v'#13#10);
end;

procedure TDnakoLoader.eval(src: AnsiString);
var
  p: PHiValue;
begin
  p := nako_eval(PAnsiChar(src));
  nako_var_free(p);
end;

function TDnakoLoader.load_DNAKO_DLL: Boolean;
var
  ver: AnsiString;
  pack_a: AnsiString;
  dir_a: AnsiString;
begin
  Result := True;
  FDnakoHandle := dnako_import.dnako_import_init(FPluginsDir + DNAKO_DLL);
  if FDnakoHandle = 0 then
  begin
    Result := False;
    Exit;
  end;
  ver := nako_getVersion();
  (*
  if ver <> NADESIKO_VER then
  begin
    raise Exception.Create('ng �J����:�Ȃł����̃o�[�W��������v���܂���B');
  end;
  *)
  // set Handle
  if FhasPackfile then
  begin
    pack_a := AnsiString(FPackFile);
    unit_pack_files.FileMixReader := TFileMixReader(
      dnako_import.nako_openPackfileBin(
        PAnsiChar(pack_a)
      )
    );
    reader := unit_pack_files.FileMixReader;
    if FPackfile <> '' then reader.autoDelete := False;
  end;
  dir_a := AnsiString(FPluginsDir);
  dnako_import.nako_setMainWindowHandle(FMainWinHandle);
  dnako_import.nako_setDNAKO_DLL_handle(FDnakoHandle);
  dnako_import.nako_setPluginsDir(PAnsiChar(dir_a));
end;

end.
