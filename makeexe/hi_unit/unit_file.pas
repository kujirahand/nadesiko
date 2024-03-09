unit unit_file;
//------------------------------------------------------------------------------
// �t�@�C�����o�͂Ɋւ���ėp�I�ȃ��j�b�g
// [�쐬] �N�W����s��
// [�A��] �N�W����s��(http://kujirahand.com)
// [���t] 2004/07/28
//
interface

uses
  Windows, SysUtils, hima_types, ShellApi, comobj, shlobj, activex;

type
  TWindowState = (wsNormal, wsMinimized, wsMaximized);

// ������Ƀt�@�C���̓��e��S���J��
function FileLoadAll(Filename: string): string;

// ������Ƀt�@�C���̓��e��S����������
procedure FileSaveAll(s, Filename: string);

//COPY
function SHFileCopy(const Source, Dest, Title: string): Boolean;
function SHFileDelete(const Source: string): Boolean;
function SHFileDeleteComplete(const Source: string): Boolean;
function SHFileMove(const Source, Dest: string): Boolean;
function SHFileRename(const Source, Dest: string): Boolean;

//EnumFile
function EnumFiles(path: string): THStringList;
function EnumAllFiles(path: string): THStringList;
function EnumDirs(const path: string): THStringList;
function CreateShortCut(SavePath, TargetApp, Arg, WorkDir: string; State: TWindowState): Boolean;
function CreateShortCutEx(SavePath, TargetApp, Arg, WorkDir, IconPath: string;
    IconNo:Integer;Comment:String;Hotkey:Word; State: TWindowState): Boolean;
function GetShortCutLink(Path :string): String;

//�t�@�C���̍쐬�E�X�V�E�ŏI���������𓾂�
function GetFileTimeEx(fname:string; var tCreation, tLastAccess, tLastWrite:TDateTime):Boolean;
function SetFileTimeEx(fname:string; tCreation, tLastAccess, tLastWrite: TDateTime): Boolean;
//TDateTime����t�@�C�������𓾂�
function DateTimeToFileTimeEx(dt: TDateTime):TFileTime;
// �t�@�C���^�C�������[�J����TTimeDate�ɕϊ�����
function FileTimeToDateTimeEx(const ft:TFileTime):TDateTime;

function getVolumeName(drive: string): string;
function getSerialNo(drive: string): DWORD;
function getFileSystemName(drive: string): string;

function ShortToLongFileName(ShortName: String):String;
function LongToShortFileName(LongName: String):String;

var MainWindowHandle: THandle = 0;

const
  HOTKEYF_SHIFT = $01;
  HOTKEYF_CONTROL = $02;
  HOTKEYF_ALT = $04;
  HOTKEYF_EXT = $08;

implementation

uses
  unit_windows_api, unit_string, unit_dummy;

function ShortToLongFileName(ShortName: String):String;
var
  SearchRec: TSearchRec;
begin
  result:= '';
  // �t���p�X��
  ShortName:= ExpandFileName(ShortName);
  // �������O�ɕϊ��i�f�B���N�g�����j
  while LastDelimiter('\', ShortName) >= 3 do begin
    if FindFirst(ShortName, faAnyFile, SearchRec) = 0 then
      try
        result := '\' + SearchRec.Name + result;
      finally
        // ���������Ƃ����� Close -> [Delphi-ML:17508] ���Q��
        FindClose(SearchRec);
      end
    else
      // �t�@�C����������Ȃ���΂��̂܂�
      result := '\' + ExtractFileName(ShortName) + result;
    ShortName := ExtractFilePath(ShortName);
    SetLength(ShortName, Length(ShortName)-1); // �Ō�� '\' ���폜
  end;
  result := ShortName + result;
end;

function LongToShortFileName(LongName: String):String;
var
  tmp: string;
begin
  SetLength(tmp, MAX_PATH + 1);
  GetShortPathName(PChar(LongName), PChar(tmp), MAX_PATH);
  Result := string(PChar(tmp));
end;

function getVolumeName(drive: string): string;
var
  fi: SHFILEINFO;
begin
  if Length(drive) = 1 then drive := drive + ':\';
  //
  SHGetFileInfo(PChar(drive), 0, fi, sizeof(SHFILEINFO), SHGFI_DISPLAYNAME);
  Result := string(fi.szDisplayName);
end;

function getFileSystemName(drive: string): string;
var
	SystemName: array [0..1000] of Char;
	SerialNumber: DWORD;
	FileNameLength: DWORD;
  Flags: DWORD;
begin
  if Length(drive) = 1 then drive := drive + ':\';
  //
	GetVolumeInformation(
		PChar(drive),
    nil,
		0,
		@SerialNumber,
		FileNameLength,
		Flags,
		@SystemName[0],
		1000);
  //
  Result := string(PChar(@SystemName[0]));
end;


function getSerialNo(drive: string): DWORD;
var
	SerialNumber: DWORD;
	FileNameLength: DWORD;
  Flags: DWORD;
begin
  if Length(drive) = 1 then drive := drive + ':\';
  //
	GetVolumeInformation(
		PChar(drive),
		nil,
		0,
		@SerialNumber,
		FileNameLength,
		Flags,
    nil,
		0);
  //
  Result := SerialNumber
end;

function getMainWindowHandle: THandle;
begin
  if MainWindowHandle = 0 then
  begin
    MainWindowHandle := GetForegroundWindow;
  end;

  Result := MainWindowHandle;
end;


// �t�@�C���^�C�������[�J����TTimeDate�ɕϊ�����
function FileTimeToDateTimeEx(const ft:TFileTime):TDateTime;
var lt:TFileTime; st:TSystemTime;
begin
  // 2�����́u����Ȋ֐��������B �v�X�����B27 �F�f�t�H���g�̖��������� �F02/10/15 19:24 ���
  FileTimeToLocalFileTime(ft,lt);
  FileTimeToSystemTime(lt,st);
  Result:=SystemTimeToDateTime(st);
end;

//TDateTime����t�@�C�������𓾂�
function DateTimeToFileTimeEx(dt: TDateTime):TFileTime;
var ft:TFileTime; st:TSystemTime;
begin
  DateTimeToSystemTime(dt, st);
  SystemTimeToFileTime(st, ft);
  LocalFileTimeToFileTime(ft, Result);
end;


//�t�@�C���̍쐬�E�X�V�E�ŏI���������𓾂�
function GetFileTimeEx(fname:string; var tCreation, tLastAccess, tLastWrite:TDateTime):boolean;
var
  F: TWin32FindData;
  h:THandle;
begin
  Result:=False;
  h := FindFirstFile(PChar(fname),F);
  if h <> INVALID_HANDLE_VALUE then
  begin
    tCreation   :=  FileTimeToDateTimeEx( F. ftCreationTime   );
    tLastAccess :=  FileTimeToDateTimeEx( F. ftLastAccessTime );
    tLastWrite  :=  FileTimeToDateTimeEx( F. ftLastWriteTime  );
    Windows.FindClose(h);
    Result := True;
  end;
end;

// �ꊇ�Ńt�@�C��������ύX����
function SetFileTimeEx(fname:string; tCreation, tLastAccess, tLastWrite: TDateTime): Boolean;
var
  fCreation, fLastAccess, fLastWrite: TFileTime;
  hFile: THandle;
begin
  // �����̕ϊ�
  fCreation   := DateTimeToFileTimeEx(tCreation   );
  fLastAccess := DateTimeToFileTimeEx(tLastAccess );
  fLastWrite  := DateTimeToFileTimeEx(tLastWrite  );

  // �����̕ύX
	hFile := CreateFile(PChar(fname), GENERIC_WRITE, 0, nil, OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL, 0);
  if hFile <> INVALID_HANDLE_VALUE then
  begin
	  SetFileTime(hFile, @fCreation, @fLastAccess, @fLastWrite);
	  CloseHandle(hFile);
    Result := True;
  end else
  begin
    Result := False;
  end;
end;


// ������Ƀt�@�C���̓��e��S���J��
function FileLoadAll(Filename: string): string;
var
  f: THandle;
  size, rsize: DWORD;
begin
  // open
  f := CreateFile(PChar(Filename), GENERIC_READ, FILE_SHARE_READ, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN,0);
  if f = INVALID_HANDLE_VALUE then
    raise EInOutError.Create('�t�@�C��"' + Filename + '"���J���܂���B' + GetLastErrorStr);
  try
    // set pointer
    SetFilePointer(f, 0, nil, FILE_BEGIN); // ���߂���[���̈ʒu��

    // read
    size := GetFileSize(f, nil); // 4G �ȉ�����
    SetLength(Result, size);
    if not ReadFile(f, Result[1], size, rsize, nil) then
    begin // ���s
      raise EInOutError.Create('�t�@�C��"' + Filename + '"�̓ǂݎ��Ɏ��s���܂����B' + GetLastErrorStr);
    end;
  finally
    // close
    CloseHandle(f);
  end;
end;

// ������Ƀt�@�C���̓��e��S����������
procedure FileSaveAll(s, Filename: string);
var
  f: THandle;
  size, rsize: DWORD;
begin
  // open
  f := CreateFile(PChar(Filename), GENERIC_WRITE, 0, nil,
    CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN,0);
  if f = INVALID_HANDLE_VALUE then
    raise EInOutError.Create('�t�@�C��"' + Filename + '"���J���܂���B' + GetLastErrorStr);
  try
    // set pointer
    SetFilePointer(f, 0, nil, FILE_BEGIN); // ���߂���[���̈ʒu��

    // write
    size := Length(s);
    if size > 0 then
    begin
      if not WriteFile(f, s[1], size, rsize, nil) then
      begin // ���s
        raise EInOutError.Create('�t�@�C��"' + Filename + '"�̓ǂݎ��Ɏ��s���܂����B' + GetLastErrorStr);
      end;
    end;
  finally
    // close
    CloseHandle(f);
  end;
end;


function SHFileCopy(const Source, Dest, Title: string): Boolean;
var
  foStruct: TSHFileOpStruct;
  s_src, s_des: string;
begin
  Result := False;
  if (Source='')or(Dest='') then Exit;

  s_src := Source + #0#0;
  s_des := Dest   + #0#0;

  with foStruct do
  begin
    wnd    := getMainWindowHandle;
    wFunc  := FO_COPY;            //�t���O�i�R�s�[�̏ꍇ��FO_COPY�j
    pFrom  := PChar(s_src);
    pTo    := PChar(s_des);
    fFlags := FOF_MULTIDESTFILES or FOF_NOCONFIRMATION or FOF_NOCONFIRMMKDIR{orFOF_NOERRORUI};
    fAnyOperationsAborted := False;          // ���������f���ꂽ�ꍇ FALSE ���Ԃ�
    hNameMappings         := nil;            // �����O��̃t�@�C��
    lpszProgressTitle     := PChar(Title);   // �_�C�A���O�̃^�C�g��
  end;
  Result := (SHFileOperation(foStruct) = 0);
end;

function SHFileDelete(const Source: string): Boolean;
var
  foStruct: TSHFileOpStruct;
begin
  ZeroMemory(@foStruct, sizeof(foStruct));
  with foStruct do
  begin
    wnd    := getMainWindowHandle;//Application.Handle;
    wFunc  := FO_DELETE;  //�t���O�i�R�s�[�̏ꍇ��FO_COPY�j
    pFrom  := PChar(Source + #0#0);  //����t�H���_
    fFlags := FOF_NOCONFIRMATION or FOF_ALLOWUNDO;  //�_�C�A���O��\��
  end;
  Result := (SHFileOperation(foStruct)=0);
end;

function SHFileDeleteComplete(const Source: string): Boolean;
var
  foStruct: TSHFileOpStruct;
begin
  with foStruct do
  begin
    wnd    := getMainWindowHandle;//Application.Handle;
    wFunc  := FO_DELETE;  //�t���O�i�R�s�[�̏ꍇ��FO_COPY�j
    pFrom  := PChar(Source + #0#0);  //����t�H���_
    pTo    := Nil; // �K�v
    fFlags := FOF_NOCONFIRMATION or FOF_MULTIDESTFILES or FOF_NOERRORUI;  //�_�C�A���O��\��
    fAnyOperationsAborted := False;
    hNameMappings         := nil;
    lpszProgressTitle     := nil;
  end;
  Result := (SHFileOperation(foStruct)=0);
end;

function SHFileMove(const Source, Dest: string): Boolean;
var
  foStruct: TSHFileOpStruct;
begin
  with foStruct do
  begin
    wnd       :=  getMainWindowHandle;//Application.Handle;
    wFunc     :=  FO_MOVE;  //�t���O�i�R�s�[�̏ꍇ��FO_COPY�j
    pFrom     :=  PChar(Source + #0#0);  //����t�H���_
    pTo       :=  PChar(Dest   + #0#0);
    fFlags    :=  FOF_NOCONFIRMATION or FOF_ALLOWUNDO or FOF_NOERRORUI;  //�_�C�A���O��\��
    fAnyOperationsAborted := False;
    hNameMappings         := nil;
    lpszProgressTitle     := nil;
  end;
  Result := (SHFileOperation(foStruct)=0);
end;

function SHFileRename(const Source, Dest: string): Boolean;
begin
  Result := SHFileMove(Source, Dest);
end;

function EnumFiles(path: string): THStringList;
var
  rec: TSearchRec;
  basePath: string;
  s: string;

  procedure _enum(path: string);
  begin
    // �t�@�C���̌���
    if FindFirst(path, FaAnyFile, rec) = 0 then
    begin
      repeat
        if not ((rec.Attr and FaDirectory)>0) then
        begin
          Result.Add(rec.Name);
        end;
      until FindNext(rec) <> 0;
      FindClose(rec);
    end;
  end;

begin
  Result := THStringList.Create;

  // path ���t�H���_���H
  if DirectoryExists(path) then
  begin
    path := CheckPathYen(path);
  end;

  // ��{�p�X�̔����o��
  basePath := ExtractFilePath(path);
  if basePath <> '' then
  begin
    System.Delete(path, 1, Length(basePath));
  end;

  // �g���q��;�ŋ�؂��Ă���̂�;�܂ł�؂�o���Ă��ꂼ���
  while True do
  begin
    s := getToken_s(path, ';');

    // �p�X���L�q����ĂȂ���� basePath �𑫂�
    if Pos(':\', s) = 0 then s := basePath + s;

    // �t�H���_�݂̂̎w��Ȃ�� ���C���h�J�[�h�𑫂�
    if Copy(s, Length(s), 1) = '\' then s := s + '*';

    _enum(s);

    if path = '' then Break;
  end;

end;

function EnumAllFiles(path: string): THStringList;
var
  basePath: string;
  s: string;
  hmain: THandle;
  smain: string;

  procedure _enum(path: string);
  var
    base, ext, s, title: string;
    dirs: THStringList;
    files: THStringList;
    i: Integer;
  begin
    // ��{�p�X���擾
    base := ExtractFilePath(path); base := CheckPathYen(base);
    ext  := ExtractFileName(path);

    if hmain > 0 then
    begin
      title := '������:' + base;
      SetWindowText(hmain, PChar(title));
    end;

    // �t�@�C�����
    files := EnumFiles(path);
    for i := 0 to files.Count - 1 do
    begin
      Result.Add(base + files.Strings[i]); // �p�X��ǉ����Č��ʂɑ���
    end;
    files.Free;

    // �t�H���_���
    dirs := EnumDirs(base+'*');
    for i := 0 to dirs.Count - 1 do
    begin
      s := base + dirs.Strings[i] + '\' + ext;
      _enum(s); // �ċA�I�Ɍ���
    end;
    dirs.Free;
  end;

begin
  Result := THStringList.Create;

  // path ���t�H���_���H
  if DirectoryExists(path) then
  begin
    path := CheckPathYen(path);
  end;

  // ��{�p�X�̔����o��
  basePath := ExtractFilePath(path);
  if basePath = '' then
  begin
    // path �ɂ̓t�B���^�̂݋L�q����Ă���̂�
    // basePath�ɃJ�����g�t�H���_���w��
    basePath := GetCurrentDir;
    basePath := CheckPathYen(basePath);
  end else
  begin
    // ���������� path �����{�ƂȂ�p�X����������
    if basePath <> '' then System.Delete(path, 1, Length(basePath));
  end;
  
  hmain := nako_getMainWindowHandle;
  if hmain > 0 then
  begin
    SetLength(smain, 1024);
    GetWindowText(hmain, PChar(smain), 1023);
  end;


  // �g���q��;�ŋ�؂��Ă���̂�;�܂ł�؂�o���Ă��ꂼ���
  while True do
  begin
    s := getToken_s(path, ';');

    // �p�X���L�q����ĂȂ���� basePath �𑫂�
    if Pos(':\', s) = 0 then s := basePath + s;

    // �t�H���_�݂̂̎w��Ȃ�� ���C���h�J�[�h�𑫂�
    if Copy(s, Length(s), 1) = '\' then s := s + '*';

    _enum(s);

    if path = '' then Break;
  end;

  if hmain > 0 then
  begin
    SetWindowText(hmain, PChar(smain));
  end;

end;

function EnumDirs(const path: string): THStringList;
var
  rec: TSearchRec;
  s: string;
begin
  Result := THStringList.Create;
  //
  s := path;
  if DirectoryExists(s) then
  begin
    s := CheckPathYen(s) + '*';
  end;
  //
  if FindFirst(s, FaAnyFile, rec) = 0 then
  begin
    repeat
      if ((rec.Attr and FaDirectory) > 0) then
      begin
        if (rec.Name = '.') or (rec.Name = '..') then Continue;
        Result.Add(rec.Name);
      end;
    until FindNext(rec) <> 0;
    FindClose(rec);
  end;
end;

function CreateShortCut(SavePath, TargetApp, Arg, WorkDir: string; State: TWindowState): Boolean;
var
  IU: IUnknown;
  W: PWideChar;
const
  ShowCmd: array[TWindowState] of Integer =
    (SW_SHOWNORMAL, SW_MINIMIZE, SW_MAXIMIZE);
begin
  Result := False;
  try
    IU := CreateComObject(CLSID_ShellLink);
    with IU as IShellLink do begin
      if SetPath(PChar(TargetApp)) <> NOERROR then Abort;
      if SetArguments(PChar(Arg)) <> NOERROR then Abort;
      if SetWorkingDirectory(PChar(WorkDir)) <> NOERROR then Abort;
      if SetShowCmd(ShowCmd[State]) <> NOERROR then Abort
    end;
    W := PWChar(WideString(SavePath));
    if (IU as IPersistFile).Save(W, False) <> S_OK then Abort;
    Result := True
  except
  end
end;

function CreateShortCutEx(SavePath, TargetApp, Arg, WorkDir, IconPath: string;
    IconNo:Integer;Comment:String;Hotkey:Word; State: TWindowState): Boolean;
var
  IU: IUnknown;
  W: PWideChar;
const
  ShowCmd: array[TWindowState] of Integer =
    (SW_SHOWNORMAL, SW_MINIMIZE, SW_MAXIMIZE);
begin
  Result := False;
  try
    IU := CreateComObject(CLSID_ShellLink);
    with IU as IShellLink do begin
      if SetPath(PChar(TargetApp)) <> NOERROR then Abort;
      if SetArguments(PChar(Arg)) <> NOERROR then Abort;
      if SetWorkingDirectory(PChar(WorkDir)) <> NOERROR then Abort;
      if (IconPath <> '') and (SetIconLocation(PChar(IconPath),IconNo) <> NOERROR) then Abort;
      if (HotKey <> 0) and (SetHotkey(Hotkey) <> NOERROR) then Abort;
      if SetDescription(PChar(Comment)) <> NOERROR then Abort;
      if SetShowCmd(ShowCmd[State]) <> NOERROR then Abort
    end;
    W := PWChar(WideString(SavePath));
    if (IU as IPersistFile).Save(W, False) <> S_OK then Abort;
    Result := True
  except
  end
end;

function GetShortCutLink(Path :string): String;
var
  IU: IUnknown;
  IP: IPersistFile;
  buf:string;
  fd:_WIN32_FIND_DATAA;
begin
  Result := '';
  SetLength(buf,260);
  try
    IU := CreateComObject(CLSID_ShellLink);
    with IU as IShellLink do begin
      if QueryInterface(IPersistFile,IP) <> NOERROR then Abort;
      if IP.Load(PWChar(WideString(Path)),STGM_READWRITE) <> NOERROR then Abort;
      if GetPath(PChar(buf),260,fd,0) <> NOERROR then Abort;
    end;
    Result := PChar(buf);
  except
  end
end;

end.
