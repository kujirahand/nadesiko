unit mini_file_utils;
//------------------------------------------------------------------------------
// �t�@�C���Ɋւ���ȈՂȏ���
// Unicode �Ή��ς�
//------------------------------------------------------------------------------

interface

uses
  {$IFDEF Win32}
  Windows, Messages, SysUtils, Commdlg, shlobj, activex,
  ShellAPI, ComObj;
  {$ELSE}
  SysUtils,
  Process,
  dos;
  {$ENDIF}

const
  MAX_PATH = 1024;

type
  TPipe = record
    StdIn:THANDLE;
    StdOut:THANDLE;
    StdErr:THANDLE;
  end;

var
  DIR_PLUGINS: string = 'plug-ins\';

{$IFDEF Win32}
// Open / Save Dialog
function ShowOpenDialog(hOwner:HWND; Filter, InitDir: AnsiString; InitFile: AnsiString=''): AnsiString;
function ShowSaveDialog(hOwner:HWND; Filter, InitDir: AnsiString; InitFile: AnsiString=''): AnsiString;
function OpenFolderDialog(var FolderPath: AnsiString; msg: AnsiString = ''): boolean;
{$ENDIF}

function GetSpecialFolder(id: DWORD): string;

function WinDir: string;
function SysDir: string;
function TempDir: string;
function DesktopDir: string;
{$IFDEF Win32}
function SendToDir: string;
function StartUpDir: string;
function RecentDir: string;
function ProgramsDir: string;
function StartMenuDir: string;
function MyDocumentDir: string;
function FavoritesDir: string;
function MyMusicDir: string;
function MyPictureDir: string;
function FontsDir: string;
function ProgramFilesDir: string;
function QuickLaunchDir: string;
function AppDataDir: string;
{$ENDIF}

function RunAndWait(path: AnsiString; Hide: Boolean=False; sec:Integer = 0): Boolean;
function OpenApp(path: AnsiString; Hide: Boolean=False): Boolean;
function RunApp(path: AnsiString; Hide: Boolean=False): Boolean;
function RunAppWithPipe(path: AnsiString; Hide: Boolean;out ParentPipe,ChildPipe:TPipe): Cardinal;

const
CSIDL_FLAG_CREATE = $8000;//Version 5.0. Combine this CSIDL with any of the following CSIDLs to force the creation of the associated folder.
CSIDL_ADMINTOOLS = $0030;//Version 5.0. The file system directory that is used to store administrative tools for an individual user. The Microsoft Management Console (MMC) will save customized consoles to this directory, and it will roam with the user.
CSIDL_ALTSTARTUP = $001d;//The file system directory that corresponds to the user's nonlocalized Startup program group.
CSIDL_APPDATA = $001a;//Version 4.71. The file system directory that serves as a common repository for application-specific data. A typical path is C:\Documents and Settings\username\Application Data. This CSIDL is supported by the redistributable Shfolder.dll for systems that do not have the Microsoft Internet Explorer 4.0 integrated Shell installed.
CSIDL_BITBUCKET = $000a;//The virtual folder containing the objects in the user's Recycle Bin.
CSIDL_CDBURN_AREA = $003b;//Version 6.0. The file system directory acting as a staging area for files waiting to be written to CD. A typical path is C:\Documents and Settings\username\Local Settings\Application Data\Microsoft\CD Burning.
CSIDL_COMMON_ADMINTOOLS = $002f;//Version 5.0. The file system directory containing administrative tools for all users of the computer.
CSIDL_COMMON_ALTSTARTUP = $001e;//The file system directory that corresponds to the nonlocalized Startup program group for all users. Valid only for Microsoft Windows NT systems.
CSIDL_COMMON_APPDATA = $0023;//Version 5.0. The file system directory containing application data for all users. A typical path is C:\Documents and Settings\All Users\Application Data.
CSIDL_COMMON_DESKTOPDIRECTORY = $0019;//The file system directory that contains files and folders that appear on the desktop for all users. A typical path is C:\Documents and Settings\All Users\Desktop. Valid only for Windows NT systems.
CSIDL_COMMON_DOCUMENTS = $002e;//The file system directory that contains documents that are common to all users. A typical paths is C:\Documents and Settings\All Users\Documents. Valid for Windows NT systems and Microsoft Windows 95 and Windows 98 systems with Shfolder.dll installed.
CSIDL_COMMON_FAVORITES = $001f;//The file system directory that serves as a common repository for favorite items common to all users. Valid only for Windows NT systems.
CSIDL_COMMON_MUSIC = $0035;//Version 6.0. The file system directory that serves as a repository for music files common to all users. A typical path is C:\Documents and Settings\All Users\Documents\My Music.
CSIDL_COMMON_PICTURES = $0036;//Version 6.0. The file system directory that serves as a repository for image files common to all users. A typical path is C:\Documents and Settings\All Users\Documents\My Pictures.
CSIDL_COMMON_PROGRAMS = $0017;//The file system directory that contains the directories for the common program groups that appear on the Start menu for all users. A typical path is C:\Documents and Settings\All Users\Start Menu\Programs. Valid only for Windows NT systems.
CSIDL_COMMON_STARTMENU = $0016;//The file system directory that contains the programs and folders that appear on the Start menu for all users. A typical path is C:\Documents and Settings\All Users\Start Menu. Valid only for Windows NT systems.
CSIDL_COMMON_STARTUP = $0018;//The file system directory that contains the programs that appear in the Startup folder for all users. A typical path is C:\Documents and Settings\All Users\Start Menu\Programs\Startup. Valid only for Windows NT systems.
CSIDL_COMMON_TEMPLATES = $002d;//The file system directory that contains the templates that are available to all users. A typical path is C:\Documents and Settings\All Users\Templates. Valid only for Windows NT systems.
CSIDL_COMMON_VIDEO = $0037;//Version 6.0. The file system directory that serves as a repository for video files common to all users. A typical path is C:\Documents and Settings\All Users\Documents\My Videos.
CSIDL_CONTROLS = $0003;//The virtual folder containing icons for the Control Panel applications.
CSIDL_COOKIES = $0021;//The file system directory that serves as a common repository for Internet cookies. A typical path is C:\Documents and Settings\username\Cookies.
CSIDL_DESKTOP = $0000;//The virtual folder representing the Windows desktop, the root of the namespace.
CSIDL_DESKTOPDIRECTORY = $0010;//The file system directory used to physically store file objects on the desktop (not to be confused with the desktop folder itself). A typical path is C:\Documents and Settings\username\Desktop.
CSIDL_DRIVES = $0011;//The virtual folder representing My Computer, containing everything on the local computer: storage devices, printers, and Control Panel. The folder may also contain mapped network drives.
CSIDL_FAVORITES = $0006;//The file system directory that serves as a common repository for the user's favorite items. A typical path is C:\Documents and Settings\username\Favorites.
CSIDL_FONTS = $0014;//A virtual folder containing fonts. A typical path is C:\Windows\Fonts.
CSIDL_HISTORY = $0022;//The file system directory that serves as a common repository for Internet history items.
CSIDL_INTERNET = $0001;//A virtual folder representing the Internet.
CSIDL_INTERNET_CACHE = $0020;//Version 4.72. The file system directory that serves as a common repository for temporary Internet files. A typical path is C:\Documents and Settings\username\Local Settings\Temporary Internet Files.
CSIDL_LOCAL_APPDATA = $001c;//Version 5.0. The file system directory that serves as a data repository for local (nonroaming) applications. A typical path is C:\Documents and Settings\username\Local Settings\Application Data.
CSIDL_MYDOCUMENTS = $000c;//Version 6.0. The virtual folder representing the My Documents desktop item.
CSIDL_MYMUSIC = $000d;//The file system directory that serves as a common repository for music files. A typical path is C:\Documents and Settings\User\My Documents\My Music.
CSIDL_MYPICTURES = $0027;//Version 5.0. The file system directory that serves as a common repository for image files. A typical path is C:\Documents and Settings\username\My Documents\My Pictures.
CSIDL_MYVIDEO = $000e;//Version 6.0. The file system directory that serves as a common repository for video files. A typical path is C:\Documents and Settings\username\My Documents\My Videos.
CSIDL_NETHOOD = $0013;//A file system directory containing the link objects that may exist in the My Network Places virtual folder. It is not the same as CSIDL_NETWORK, which represents the network namespace root. A typical path is C:\Documents and Settings\username\NetHood.
CSIDL_NETWORK = $0012;//A virtual folder representing Network Neighborhood, the root of the network namespace hierarchy.
CSIDL_PERSONAL = $0005;//Version 6.0. The virtual folder representing the My Documents desktop item. This is equivalent to CSIDL_MYDOCUMENTS.
CSIDL_PRINTHOOD = $001b;//The file system directory that contains the link objects that can exist in the Printers virtual folder. A typical path is C:\Documents and Settings\username\PrintHood.
CSIDL_PROFILE = $0028;//Version 5.0. The user's profile folder. A typical path is C:\Documents and Settings\username. Applications should not create files or folders at this level; they should put their data under the locations referred to by CSIDL_APPDATA or CSIDL_LOCAL_APPDATA.
CSIDL_PROFILES = $003e;//Version 6.0. The file system directory containing user profile folders. A typical path is C:\Documents and Settings.
CSIDL_PROGRAM_FILES = $0026;//Version 5.0. The Program Files folder. A typical path is C:\Program Files.
CSIDL_PROGRAM_FILES_COMMON = $002b;//Version 5.0. A folder for components that are shared across applications. A typical path is C:\Program Files\Common. Valid only for Windows NT, Windows 2000, and Windows XP systems. Not valid for Windows Millennium Edition (Windows Me).
CSIDL_PROGRAMS = $0002;//The file system directory that contains the user's program groups (which are themselves file system directories). A typical path is C:\Documents and Settings\username\Start Menu\Programs.
CSIDL_RECENT = $0008;//The file system directory that contains shortcuts to the user's most recently used documents. A typical path is C:\Documents and Settings\username\My Recent Documents. To create a shortcut in this folder, use SHAddToRecentDocs. In addition to creating the shortcut, this function updates the Shell's list of recent documents and adds the shortcut to the My Recent Documents submenu of the Start menu.
CSIDL_SENDTO = $0009;//The file system directory that contains Send To menu items. A typical path is C:\Documents and Settings\username\SendTo.
CSIDL_STARTMENU = $000b;//The file system directory containing Start menu items. A typical path is C:\Documents and Settings\username\Start Menu.
CSIDL_STARTUP = $0007;//The file system directory that corresponds to the user's Startup program group. The system starts these programs whenever any user logs onto Windows NT or starts Windows 95. A typical path is C:\Documents and Settings\username\Start Menu\Programs\Startup.
CSIDL_SYSTEM = $0025;//Version 5.0. The Windows System folder. A typical path is C:\Windows\System32.
CSIDL_TEMPLATES = $0015;//The file system directory that serves as a common repository for document templates. A typical path is C:\Documents and Settings\username\Templates.
CSIDL_WINDOWS = $0024;//Version 5.0. The Windows directory or SYSROOT. This corresponds to the %windir% or %SYSTEMROOT% environment variables. A typical path is C:\Windows.

function SHFileDeleteComplete(const Source: AnsiString): Boolean;
function FindDLLFile(fname: string): string;
function AppPath: string;
function getUniqFilename(const dir: string; basename: string): string;
function CheckPathYen(const path: string): string;
function ExtractFilePathA(const FileName: AnsiString): AnsiString;

implementation

uses unit_string, hima_types;

function ExtractFilePathA(const FileName: AnsiString): AnsiString;
begin
  Result := AnsiString(ExtractFilePath(string(FileName)));
end;


function CheckPathYen(const path: string): string;
begin
  Result := IncludeTrailingPathDelimiter(string(path));
end;

function AppPath: string;
begin
  Result := ExtractFilePath(ParamStr(0));
end;

function FindDLLFile(fname: string): string;

  procedure _ok(dll: string);
  begin
    Result := dll;
  end;

var
  f: string;
begin
  Result := '';
  // ��΃p�X�H
  if Pos(':\', fname) > 0 then
  begin
    _ok(fname); Exit;
  end;
  // �����t�H���_���`�F�b�N
  f := string(AppPath) + fname;
  if FileExists(f) then
  begin
    _ok(f); Exit;
  end;
  f := DIR_PLUGINS + fname;
  if FileExists(f) then
  begin
    _ok(f); Exit;
  end;
  f := AppPath + 'plug-ins\' + fname;
  if FileExists(f) then
  begin
    _ok(f); Exit;
  end;
  // Windows�t�H���_���`�F�b�N
  f := WinDir + fname;
  if FileExists(f) then
  begin
    _ok(f); Exit;
  end;
  // �V�X�e���t�H���_���`�F�b�N
  f := SysDir + fname;
  if FileExists(f) then
  begin
    _ok(f); Exit;
  end;
  _ok(fname);
end;

var uniq_value: Word = 0;

function getUniqFilename(const dir: string; basename: string): string;
var
  ext, fdir: string;
  name: string;
  i: Integer;
  guid: TGUID;
begin
  ext  := ExtractFileExt(string(basename));
  name := ChangeFileExt(ExtractFileName(basename), '');
  fdir := string(CheckPathYen(dir));
  Inc(uniq_value);

  // [�t�@�C����]~[����] �̐���
  Result := fdir + name + '~' + IntToHex(uniq_value, 4) + ext;
  if not FileExists(Result) then Exit;

  // ���ɐ����̖��O�̃t�@�C�����������񂠂�̂ŁA��胉���_���Ȓl�𐶐�����
  for i := 0 to 999 do
  begin
    CreateGUID(guid);
    Result := fdir + name + '~' + GUIDToString(guid) + ext;
    if FileExists(Result) then Continue; // �{��?
    Exit;
  end;

  // Windows �� API ���g�����@ .. ��ԑ����������_��
  SetLength(Result, MAX_PATH);
  {$IFDEF UNICODE}
  GetTempFileNameW(PWideChar(fdir), PWideChar(name), 0, PWideChar(Result));
  Result := string(PWideChar(Result));
  {$ELSE}
  GetTempFileName(PChar(fdir), PChar(name), 0, PChar(Result));
  Result := string(PChar(Result));
  {$ENDIF}
end;

(*
const
  CSIDL_DESKTOP 		=$0000;//�u�f�X�N�g�b�v�v�i�l�[���X�y�[�X�̃��[�g��\�����z�t�H���_�j
  CSIDL_INTERNET 		=$0001;//�uInternet Explorer�v�i���z�t�H���_�j
  CSIDL_PROGRAMS 		=$0002;//�u�v���O�����v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_CONTROLS 		=$0003;//�u�R���g���[�� �p�l���v�i���z�t�H���_�j
  CSIDL_PRINTERS 		=$0004;//�u�v�����^�v�i���z�t�H���_�j
  CSIDL_PERSONAL 		=$0005;//�u�}�C �h�L�������g�v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_FAVORITES 		=$0006;//�u���C�ɓ���v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_STARTUP 		=$0007;//�u�X�^�[�g�A�b�v�v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_RECENT 		=$0008;//�u�ŋߎg�����t�@�C���v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_SENDTO 		=$0009;//�uSendTo�v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_BITBUCKET 		=$000a;//�u���ݔ��v�i���z�t�H���_�j
  CSIDL_STARTMENU 		=$000b;//�u�X�^�[�g���j���[�v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_MYMUSIC 		=$000d;//�u�}�C �~���[�W�b�N�v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_DESKTOPDIRECTORY 		=$0010;//�u�f�X�N�g�b�v�v��̃t�@�C���I�u�W�F�N�g���i�[����t�H���_�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_DRIVES 		=$0011;//�u�}�C �R���s���[�^�v�i���z�t�H���_�j
  CSIDL_NETWORK 		=$0012;//�u�l�b�g���[�N�R���s���[�^�v�i���z�t�H���_�j
  CSIDL_NETHOOD 		=$0013;//�uNetHood�v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_FONTS 		=$0014;//�uFonts�v�i�t�H���g���܂މ��z�t�H���_�j
  CSIDL_TEMPLATES 		=$0015;//�h�L�������g�e���v���[�g���i�[�����t�H���_�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_COMMON_STARTMENU 		=$0016;//AllUsers �́u�X�^�[�g���j���[�v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_COMMON_PROGRAMS 		=$0017;//AllUsers �́u�v���O�����v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_COMMON_STARTUP 		=$0018;//AllUsers �́u�X�^�[�g�A�b�v�v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_COMMON_DESKTOPDIRECTORY 		=$0019;//AllUsers �́u�f�X�N�g�b�v�v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_APPDATA 		=$001a;//Version 4.71 �ȍ~�F �uApplication Data�v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_PRINTHOOD 		=$001b;//�u�v�����^�v���z�t�H���_�ɂ�����郊���N�I�u�W�F�N�g���i�[����t�H���_�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_LOCAL_APPDATA 		=$001c;//Version 5.0 �ȍ~�F �uApplication Data�v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_ALTSTARTUP 		=$001d;//�񃍁[�J���ł́u�X�^�[�g�A�b�v�v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_COMMON_ALTSTARTUP 		=$001e;//�񃍁[�J���ł� AllUsers �́u�X�^�[�g�A�b�v�v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_COMMON_FAVORITES 		=$001f;//AllUsers �́u���C�ɓ���v�iNT�n�̂݁j�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_INTERNET_CACHE 		=$0020;//Version 4.72 �ȍ~�F �C���^�[�l�b�g�ꎞ�t�@�C�����i�[����t�H���_�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_COOKIES 		=$0021;//�uCookies�v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_HISTORY 		=$0022;//�u�����v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_COMMON_APPDATA 		=$0023;//Version 5.0 �ȍ~�F AllUsers �́uApplication Data�v�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_WINDOWS 		=$0024;//Version 5.0 �ȍ~�F Windows �f�B���N�g��
  CSIDL_SYSTEM 		=$0025;//Version 5.0 �ȍ~�F Windows System �f�B���N�g��
  CSIDL_PROGRAM_FILES 		=$0026;//Version 5.0 �ȍ~�F Program Files �t�H���_
  CSIDL_MYPICTURES 		=$0027;//Version 5.0 �ȍ~�F My Pictures �t�H���_�i�t�@�C���V�X�e���f�B���N�g���j
  CSIDL_PROFILE 		=$0028;//Version 5.0 �ȍ~�F profile �t�H���_
  CSIDL_PROGRAM_FILES_COMMON 		=$002b;//Version 5.0 �ȍ~�GWindows 2000/XP�F Program Files\Common
  CSIDL_COMMON_TEMPLATES 		=$002d;//Windows NT/2000/XP�F AllUsers �̃h�L�������g�e���v���[�g���i�[�����f�B���N�g��
  CSIDL_COMMON_DOCUMENTS 		=$002e;//Shfolder.dll�F AllUsers �̃h�L�������g�e���v���[�g���i�[�����f�B���N�g���iWindows NT �n����� Shfolder.dll ���C���X�g�[�����ꂽ Windows 9x�j
  CSIDL_COMMON_ADMINTOOLS 		=$002f;//Version 5.0 �ȍ~�F AllUsers �̊Ǘ��c�[���f�B���N�g��
  CSIDL_ADMINTOOLS 		=$0030;//Version 5.0 �ȍ~�F �Ǘ��c�[���f�B���N�g��
*)

function SHFileDeleteComplete(const Source: AnsiString): Boolean;
{$IFDEF Win32}
var
  foStruct: _SHFILEOPSTRUCTA;
begin
  with foStruct do
  begin
    wnd    := 0;
    wFunc  := FO_DELETE;  //�t���O�i�R�s�[�̏ꍇ��FO_COPY�j
    pFrom  := PAnsiChar(Source + #0#0);  //����t�H���_
    pTo    := Nil; // �K�v
    fFlags := FOF_NOCONFIRMATION or FOF_MULTIDESTFILES or FOF_NOERRORUI;  //�_�C�A���O��\��
    fAnyOperationsAborted := False;
    hNameMappings         := nil;
    lpszProgressTitle     := nil;
  end;
  Result := (SHFileOperationA(foStruct)=0);
end;
{$ELSE}
begin
    DeleteFile(Source);
end;
{$ENDIF}

function GetSpecialFolder(id: DWORD): string;
{$IFDEF Win32}
var
  PID: PItemIDList;
  Path: array [0..MAX_PATH-1] of WideChar;
begin
  SHGetSpecialFolderLocation(GetDesktopWindow, id, PID);
  SHGetPathFromIDListW(PID, Path);
  Result := Path;
  if Copy(Result, Length(Result),1)<>'\' then Result := Result + '\';
end;
{$ELSE}
begin
  // TODO
  Result := '';
end;
{$ENDIF}


{Windows�t�H���_�𓾂�}
function WinDir: string;
{$IFDEF Win32}
var
 TempWin:array[0..MAX_PATH] of Char;
begin
 GetWindowsDirectory(TempWin,MAX_PATH);
 Result:=StrPas(TempWin);
 if Copy(Result,Length(Result),1)<>'\' then Result := Result + '\';
end;
{$ELSE}
begin
  Result := ''; // todo
end;
{$ENDIF}

{System�t�H���_�𓾂�}
function SysDir: string;
{$IFDEF Win32} 
var
 TempSys:array[0..MAX_PATH] of Char;
begin
 GetSystemDirectory(TempSys,MAX_PATH);
 Result:=StrPas(TempSys);
 if Copy(Result,Length(Result),1)<>'\' then Result := Result + '\';
end;
{$ELSE}
begin
  Result := ''; // todo
end;
{$ENDIF}
{Temp�t�H���_�𓾂�}
function TempDir: string;
{$IFDEF Win32}
var
 TempTmp:array[0..MAX_PATH] of Char;
begin
 GetTemppath(MAX_PATH,TempTmp);
 Result:=StrPas(TempTmp);
 if Copy(Result,Length(Result),1)<>'\' then Result := Result + '\';
end;
{$ELSE}
begin
  Result := GetEnv('HOME') + '/.temp';
end;
{$ENDIF}

function DesktopDir: string;
begin
   Result := GetSpecialFolder(CSIDL_DESKTOPDIRECTORY);
end;
function SendToDir: string;
begin
   Result := GetSpecialFolder(CSIDL_SENDTO);
end;
function StartUpDir: string;
begin
   Result := GetSpecialFolder(CSIDL_STARTUP);
end;
function RecentDir: string;
begin
   Result := GetSpecialFolder(CSIDL_RECENT);
end;
function ProgramsDir: string;
begin
   Result := GetSpecialFolder(CSIDL_PROGRAMS);
end;
function StartMenuDir: string;
begin
   Result := GetSpecialFolder(CSIDL_STARTMENU);
end;
function MyDocumentDir: string;
begin
   Result := GetSpecialFolder(CSIDL_PERSONAL);
end;
function FavoritesDir: string;
begin
   Result := GetSpecialFolder(CSIDL_FAVORITES);
end;
function MyMusicDir: string;
begin
   Result := GetSpecialFolder(CSIDL_MYMUSIC);
end;
function MyPictureDir: string;
begin
   Result := GetSpecialFolder(CSIDL_MYPICTURES);
end;
function FontsDir: string;
begin
   Result := GetSpecialFolder(CSIDL_FONTS);
end;
function ProgramFilesDir: string;
begin
   Result := GetSpecialFolder(CSIDL_PROGRAM_FILES);
end;

function QuickLaunchDir: string;
begin
   Result := GetSpecialFolder(CSIDL_APPDATA) + 'Microsoft\Internet Explorer\Quick Launch\';
end;

function AppDataDir: string;
begin
   Result := GetSpecialFolder(CSIDL_APPDATA);
end;

//-------------------------------------------------------------------------
function CheckFilter(Filter: string): string;
begin
  if Pos('|', Filter) = 0 then
  begin
    if Filter = '' then Filter := '�S�Ẵt�@�C��(*.*)|*.*'
    else begin
      if Pos('.', Filter) = 0 then Filter := '.' + Filter;
      if Pos('*', Filter) = 0 then Filter := '*' + Filter;
      Filter := '(' + Filter + ') �`��|' + Filter + '|�S�Ẵt�@�C��(*.*)|*.*';
    end;
  end;
  Result := Filter;
end;

function ReplaceChar(const s: AnsiString; fromCH, toCH: AnsiChar): AnsiString;
var
  i: Integer;
begin
  Result := s;
  i := 1;
  while i <= Length(s) do
  begin
    if Result[i] in SJISLeadBytes then
    begin
      Inc(i, 2);
    end else
    begin
      if Result[i] = fromCH then Result[i] := toCH;
      Inc(i);
    end;
  end;
end;

{$IFDEF Win32}
function ShowOpenDialog(hOwner:HWND; Filter, InitDir: AnsiString; InitFile: AnsiString=''): AnsiString;
var
  OFN: tagOFNA;
  PATH, s, res: AnsiString;
  p: PAnsiChar;
  b: Boolean;
begin
  PATH := InitFile+#0;
  SetLength(PATH,MAX_PATH+5);
  //----------------------------------------------------------------------------
  // FILTER
  Filter := AnsiString(CheckFilter(string(Filter)));
  Filter := ReplaceChar(Filter, '|', #0)+#0;

  // OpenFileName �\���̂ɃZ�b�g
  FillChar(OFN,SizeOf(OFN),0);
  with OFN do
  begin
    lStructSize := SizeOf(OFN); // 76:98/NT  88:2k-
    hWndOwner := hOwner;
    lpstrFilter := PAnsiChar(Filter);
    nFilterIndex := 1;
    lpstrFile := PAnsiChar(PATH);
    nMaxFile:= MAX_PATH+5;
    lpstrInitialDir := PAnsiChar(InitDir);
    Flags := OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_EXPLORER or OFN_ALLOWMULTISELECT;
  end;

  b := GetOpenFileNameA(OFN);
  if ( not b ) and (CommDlgExtendedError() = CDERR_STRUCTSIZE) and (OFN.lStructSize > 76) then
  begin
    OFN.lStructSize := 76;
    b := GetOpenFileNameA(OFN);
  end;
  if b then
  begin
    SetLength(res, OFN.nMaxFile);
    ZeroMemory(PAnsiChar(res), OFN.nMaxFile);
    StrMove(PAnsiChar(res), OFN.lpstrFile, OFN.nMaxFile);

    Result := ''; p := PAnsiChar(res);

    // �t�@�C�����̎��o��(�}���`�Ή��� NULL ��؂�z��)
    PATH := getTokenStr(p, #0);
    Inc(p); // skip #0
    if p^ = #0 then
    begin
      Result := AnsiString(Trim(string(PATH))); Exit;
    end;

    while p^ <> #0 do
    begin
      s := getTokenStr(p, #0);
      Result := Result + PATH + '\' + s + #13#10;
      Inc(p); // skip #0
    end;

    Result := AnsiString(Trim(string(Result)));
  end else
  begin
    Result := '';
  end;
end;


function ShowSaveDialog(hOwner:HWND; Filter, InitDir: AnsiString; InitFile: AnsiString=''): AnsiString;
var
  OFN: tagOFNA;
  PATH: AnsiString;
  ext, tmp: AnsiString;
  extList: THStringList;
  b: Boolean;
begin
  PATH := InitFile+#0;
  SetLength(PATH,MAX_PATH+5);
  //----------------------------------------------------------------------------
  // FILTER
  // Filter := CheckFilter(Filter);
  Filter := AnsiString(CheckFilter(string(Filter)));
  extList := THStringList.Create;
  extList.SplitText(Filter, '|');
  Filter := ReplaceChar(Filter, '|', #0)+#0;

  // OpenFileName �\���̂ɃZ�b�g
  FillChar(OFN,SizeOf(OFN),0);
  with OFN do
  begin
    lStructSize := SizeOf(OFN); // 76:98/NT  88:2k-
    hWndOwner := hOwner;
    lpstrFilter := PAnsiChar(Filter);
    nFilterIndex := 1;
    lpstrFile := PAnsiChar(PATH);

    nMaxFile:= MAX_PATH+5;
    lpstrInitialDir := PAnsiChar(InitDir);
    Flags := OFN_OVERWRITEPROMPT or OFN_HIDEREADONLY;
  end;

  b := GetSaveFileNameA(OFN);
  if ( not b ) and (CommDlgExtendedError() = CDERR_STRUCTSIZE) and (OFN.lStructSize > 76) then
  begin
    OFN.lStructSize := 76;
    b := GetSaveFileNameA(OFN);
  end;
  if b then
  begin
    SetLength(Result, OFN.nMaxFile);
    ZeroMemory(PAnsiChar(Result), OFN.nMaxFile);
    StrMove(PAnsiChar(Result), OFN.lpstrFile, OFN.nMaxFile);

    Result := AnsiString(Trim(string(AnsiString( PAnsiChar(Result) ))));
    if ExtractFileExt(string(Result)) = '' then
    begin
      ext := extList.Strings[ (OFN.nFilterIndex-1) * 2 + 1 ];
      tmp := getToken_s(ext, ';');
      ext := AnsiString(ExtractFileExt(string(tmp)));
      if (Pos(string('*'), string(ext)) > 0)or(Pos(string('?'), string(ext)) > 0) then ext := '';
      Result := AnsiString(ChangeFileExt(string(Result), string(ext)));
    end;

  end else
  begin
    Result := '';
  end;
  //
  extList.Free;
end;

{�t�H���_�̎Q�ƃ_�C�A���O�p�R�[���o�b�N�֐�}
function BrowseCallback(hWnd: HWND; uMsg: UINT; lParam: LPARAM; lpData: LPARAM): integer; stdcall;
var
  PathName: array[0..MAX_PATH] of Char;
begin
  Result:=0;

  case uMsg of
  {�ŏ��ɕ\������t�H���_}
  BFFM_INITIALIZED:
   SendMessage(hwnd,BFFM_SETSELECTION,1,LongInt(lpData));
  {�t�H���_�Q�Ǝ��Ƀp�X��\��}
  BFFM_SELCHANGED:
   begin
    SHGetPathFromIDList(PItemIDList(lParam), PathName);
    SendMessage(hWnd, BFFM_SETSTATUSTEXT, 0, LongInt(@PathName));
   end;
  end;
end;

{�t�H���_�̎Q�ƃ_�C�A���O���J��}
function OpenFolderDialog(var FolderPath: AnsiString; msg: AnsiString = ''): boolean;
var
  Malloc: IMalloc;
  BrowseInfo: TBrowseInfoA;
  DisplayPath: array[0..MAX_PATH] of AnsiChar;
  IDList: PItemIdList;
  Buffer,pFolderPath: PAnsiChar;
begin
  Result:=False;
  if msg = '' then msg := '�t�H���_��I�����Ă��������B';

  if Succeeded(SHGetMalloc(Malloc)) then  //IMalloc�̃|�C���^���擾�ł�����
  begin
   pFolderPath:=PAnsiChar(FolderPath);       //�����t�H���_�w��p

   {BrowseInfo�\���̂�������}
   with BrowseInfo do
   begin
    hwndOwner      := GetActiveWindow();  //D4��SelectDirectory�ł́A������Application.Handle�ɂȂ��Ă���̂ŁA�\���ʒu�����������Ȃ�
    pidlRoot       := nil;
    pszDisplayName := DisplayPath;                             //�\�����p�o�b�t�@
    lpszTitle      := PAnsiChar(msg);
    ulFlags        := BIF_RETURNONLYFSDIRS{ or BIF_STATUSTEXT};  //�ʏ�̃t�H���_�̂ݎQ�Ɖ\�i����t�H���_�͑I���ł��Ȃ��j
    lpfn           := @BrowseCallback;                         //�R�[���o�b�N�֐��w��
    lParam         := LongInt(pFolderPath);                    //�����t�H���_�w��
    iImage         := 0;
   end;

   IDlist := SHBrowseForFolderA(BrowseInfo); //�t�H���_�Q�ƃ_�C�A���O��\��
   if IDlist<>nil then                      //�l���Ԃ��Ă�����
    begin
     Buffer:=Malloc.Alloc(MAX_PATH);        //�t�H���_�p�X�擾�p�o�b�t�@
     try
      SHGetPathFromIDListA(IDlist, Buffer);  //�t�H���_�p�X���擾
      FolderPath:=AnsiString(Buffer);
     finally
      Malloc.Free(Buffer);
     end;

     Malloc.Free(IDlist);
     Result:=True;
    end;
  end;
end;
{$ENDIF}


function RunApp(path: AnsiString; Hide: Boolean=False): Boolean;
{$IFDEF Win32}
var
    retCode: Integer;
begin
    if Hide then
    begin
      retCode := WinExec(PAnsiChar(path), SW_HIDE);
    end else
    begin
      retCode := WinExec(PAnsiChar(path), SW_SHOW);
    end;

    if retCode > 31 then
    begin
        Result:= True;
    end else
    begin
        Result :=False;
    end;
end;
{$ELSE}
var
  s: string;
begin
  Result := RunCommand(path, [], s);
end;
{$ENDIF}

function OpenApp(path: AnsiString; Hide: Boolean=False): Boolean;
{$IFDEF Win32}
var
  i: DWORD;
  res: HINST;
begin
  if Hide then
  begin
    i := SW_HIDE;
  end else
  begin
    i := SW_SHOW;
  end;
  res := ShellExecuteA(
    0, 'open', PAnsiChar(path), nil, nil,
    i);
  Result := (res > 32);
end;
{$ELSE}
var
  s: string;
begin
  Result := RunCommand(path, [], s);
end;
{$ENDIF}

function RunAndWait(path: AnsiString; Hide: Boolean; sec:Integer): Boolean;
{$IFDEF Win32}
var
  ret: Boolean;
  ecode: Integer;
  StartupInfo: _STARTUPINFOA;
  ProcessInfo: TProcessInformation;
begin
  Result := False;

  // �\����Ԃ�ݒ�
  with StartupInfo do begin
    // ���̍\���̂̃T�C�Y���w��
    cb := SizeOf(TStartupInfo);

    // �E�B���h�E�̕\����Ԃ��w��
    if Hide then
      wShowWindow := SW_HIDE
    else
      wShowWindow := SW_SHOWNORMAL;

    // �L���Ȑݒ荀�ڂ��w��
    dwFlags := STARTF_USESHOWWINDOW;

    // ����ȊO�̍��ڂ�������
    lpReserved := nil;
    lpDesktop  := nil;
    lpTitle    := nil;
    cbReserved2 := 0;
    lpReserved2 := nil;
  end;
  // ���s
  ret := CreateProcessA(
    nil,                        // ���s�t�@�C����
    PAnsiChar(path),                // �R�}���h���C��
    nil,                        // �v���Z�X�̃Z�L�����e�B����
    nil,                        // �X���b�h�̃Z�L�����e�B����
    False,                      // �e�v���Z�X����n���h�����p�����邩
    CREATE_DEFAULT_ERROR_MODE,  // �D�揇�ʂƃv���Z�X�̐��쐧��
    nil,                        // ���ϐ��u���b�N�ւ̃|�C���^
    nil,                        // �J�����g�f�B���N�g��
    StartupInfo,                // �E�B���h�E�̑���
    ProcessInfo                 // �V�����v���Z�X�̏����󂯎��\����
  );

  // �G���[�`�F�b�N
  if not ret then
  begin
    raise Exception.Create(
      '�w'+string(path)+'�x�����s�ł��܂���B���R�́A' +
      IntToStr(GetLastError) + '�B');
  end;

  // �I���҂�(10�b�҂�)
  if sec <= 0 then
  begin
    ecode := WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
  end else
  begin
    ecode := WaitForSingleObject(ProcessInfo.hProcess, sec * 1000);
  end;
  // ���b�Z�[�W�\��
  case ecode of
    WAIT_OBJECT_0:  Result := True;
    WAIT_TIMEOUT :  Result := False;
  end;
  CloseHandle(ProcessInfo.hProcess);
  CloseHandle(ProcessInfo.hThread);
end;
{$ELSE}
var
  s: string;
begin
  Result := RunCommand(path, [], s);
end;
{$ENDIF}

function RunAppWithPipe(path: AnsiString; Hide: Boolean;out ParentPipe,ChildPipe:TPipe): Cardinal;
{$IFDEF Win32}
var
  ret: Boolean;
  StartupInfo: _STARTUPINFOA;
  ProcessInfo: TProcessInformation;
  hParent: THandle;
  WorkPipe: TPipe;
  Security:TSecurityAttributes;
begin
  hParent:= GetCurrentProcess;

  with Security do begin
    nLength := sizeof(Security);
    lpSecurityDescriptor := nil;
    bInheritHandle := True;
  end;

  with WorkPipe do begin
    //stdout
    CreatePipe(StdOut,StdIn,@Security,0);
    StartupInfo.hStdOutput := StdIn;
    ChildPipe.StdOut := StdIn;
    DuplicateHandle(hParent,StdOut,hParent,@ParentPipe.StdOut,0,FALSE,DUPLICATE_SAME_ACCESS);
    CloseHandle(StdOut);
    //stderr
    CreatePipe(StdOut,StdIn,@Security,0);
    StartupInfo.hStdError := StdIn;
    ChildPipe.StdErr := StdIn;
    DuplicateHandle(hParent,StdOut,hParent,@ParentPipe.StdErr,0,FALSE,DUPLICATE_SAME_ACCESS);
    CloseHandle(StdOut);
    //stdin
    CreatePipe(StdOut,StdIn,@Security,0);
    StartupInfo.hStdInput := StdOut;
    ChildPipe.StdIn := StdOut;
    DuplicateHandle(hParent,StdIn,hParent,@ParentPipe.StdIn,0,FALSE,DUPLICATE_SAME_ACCESS);
    CloseHandle(StdIn);
  end;

  // �\����Ԃ�ݒ�
  with StartupInfo do begin
    // ���̍\���̂̃T�C�Y���w��
    cb := SizeOf(TStartupInfo);

    // �E�B���h�E�̕\����Ԃ��w��
    if Hide then
      wShowWindow := SW_HIDE
    else
      wShowWindow := SW_SHOWNORMAL;

    // �L���Ȑݒ荀�ڂ��w��
    dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;

    // ����ȊO�̍��ڂ�������
    lpReserved := nil;
    lpDesktop  := nil;
    lpTitle    := nil;
    cbReserved2 := 0;
    lpReserved2 := nil;
  end;
  // ���s
  ret := CreateProcessA(
    nil,                        // ���s�t�@�C����
    PAnsiChar(path),                // �R�}���h���C��
    nil,                        // �v���Z�X�̃Z�L�����e�B����
    nil,                        // �X���b�h�̃Z�L�����e�B����
    True,                       // �e�v���Z�X����n���h�����p�����邩
    CREATE_DEFAULT_ERROR_MODE,  // �D�揇�ʂƃv���Z�X�̐��쐧��
    nil,                        // ���ϐ��u���b�N�ւ̃|�C���^
    nil,                        // �J�����g�f�B���N�g��
    StartupInfo,                // �E�B���h�E�̑���
    ProcessInfo                 // �V�����v���Z�X�̏����󂯎��\����
  );

  // �G���[�`�F�b�N
  if not ret then
  begin
    raise Exception.Create('�w'+
      string(path)+'�x�����s�ł��܂���B���R�́A' +
      IntToStr(GetLastError) + '�B');
  end;

  Result := ProcessInfo.hProcess;
  CloseHandle(ProcessInfo.hThread);
end;
{$ELSE}
var
  s: string;
begin
  RunCommand(path, [], s);
  Result := 0;
end;
{$ENDIF}

initialization
;

finalization
;

end.
