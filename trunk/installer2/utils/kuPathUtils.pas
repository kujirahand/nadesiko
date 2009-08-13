{**
 * 各種パスの取得メソッド一覧をまとめたもの
 * @author  kujirahand.com
 * @version 2009/04/11
 *}

 unit kuPathUtils;

interface

uses
  SysUtils, Classes, Windows, ShellApi, ShlObj, ActiveX, ComObj;

type
  TKPathUtils = class
  public
    // Get Path
    function ExeFile: string;
    function ExeDir: string;
    function MyDocument: string;
    function MuMusic: string;
    function MyPicture: string;
    function MyVideo: string;
    function DesktopDir: string;
    function AppData: string;
    function SendTo: string;
    function TempDir: string;
    function ProgramFiles: string;
    function StartUpDir: string;
    function SystemDir: string;
    // Utils
    function GetSpecialDir(CSIDL: DWord): string;
    function AddLastPathDelim(path: string): string;
    function GetTempFile(head: string = ''): string;
    // Remove
    procedure Delete(path: string; FlagRecycle: Boolean = True);
    procedure Copy(PathFrom, PathTo: string);
    // Dialog
    function OpenFolderDialog(var FolderPath: string; msg: string = ''): Boolean; // Select Directory
    function CreateShortCutEx(SavePath, TargetApp, Arg: string; WorkDir: string = '';
      IconPath: string = ''; IconNo: Integer = 0; Comment: string = ''; Hotkey: Word = 0;
      State: Integer = 0): Boolean;
  end;

var
  AppHandle: THandle = 0;

function AppPath: string;
function KPath: TKPathUtils;

implementation

uses kuBenri;

var
  _path: TKPathUtils = nil;

function KPath: TKPathUtils;
begin
  if _path = nil then
  begin
    _path := TKPathUtils.Create;
  end;
  Result := _path;
end;

function AppPath: string;
begin
  Result := ExtractFilePath(ParamStr(0));
end;

{ TPathUtils }

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


///フォルダの参照ダイアログ用コールバック関数
function BrowseCallback(hWnd: HWND; uMsg: UINT; lParam: LPARAM; lpData: LPARAM): integer; stdcall;
var
  PathName: array[0..MAX_PATH] of Char;
begin
  Result:=0;

  case uMsg of
  {最初に表示するフォルダ}
  BFFM_INITIALIZED:
   SendMessage(hwnd,BFFM_SETSELECTION,1,LongInt(lpData));
  {フォルダ参照時にパスを表示}
  BFFM_SELCHANGED:
   begin
    SHGetPathFromIDList(PItemIDList(lParam), PathName);
    SendMessage(hWnd, BFFM_SETSTATUSTEXT, 0, LongInt(@PathName));
   end;
  end;
end;

///フォルダの参照ダイアログを開
function TKPathUtils.OpenFolderDialog(var FolderPath: String; msg: string = ''): Boolean;
var
  Malloc: IMalloc;
  BrowseInfo: TBrowseInfo;
  DisplayPath: array[0..MAX_PATH] of Char;
  IDList: PItemIdList;
  Buffer,pFolderPath: PChar;
begin
  Result:=False;
  if msg = '' then msg := 'フォルダを選択してください。';

  if Succeeded(SHGetMalloc(Malloc)) then  //IMallocのポインタを取得できたら
  begin
   pFolderPath:=PChar(FolderPath);       //初期フォルダ指定用

   {BrowseInfo構造体を初期化}
   with BrowseInfo do
   begin
    hwndOwner      := GetActiveWindow();  //D4のSelectDirectoryでは、ここがApplication.Handleになっているので、表示位置がおかしくなる
    pidlRoot       := nil;
    pszDisplayName := DisplayPath;                             //表示名用バッファ
    lpszTitle      := PChar(msg);
    ulFlags        := BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE{ or BIF_STATUSTEXT};  //通常のフォルダのみ参照可能（特殊フォルダは選択できない）
    lpfn           := @BrowseCallback;                         //コールバック関数指定
    lParam         := LongInt(pFolderPath);                    //初期フォルダ指定
    iImage         := 0;
   end;

   IDlist := SHBrowseForFolder(BrowseInfo); //フォルダ参照ダイアログを表示
   if IDlist<>nil then                      //値が返ってきたら
    begin
     Buffer:=Malloc.Alloc(MAX_PATH);        //フォルダパス取得用バッファ
     try
      SHGetPathFromIDList(IDlist, Buffer);  //フォルダパスを取得
      FolderPath:=string(Buffer);
     finally
      Malloc.Free(Buffer);
     end;

     Malloc.Free(IDlist);
     Result:=True;
    end;
  end;
end;

function TKPathUtils.CreateShortCutEx(SavePath, TargetApp, Arg: string; WorkDir: string;
  IconPath: string; IconNo: Integer; Comment: string; Hotkey: Word;
  State: Integer): Boolean;
var
  IU: IUnknown;
  tmp: WideString;
begin
  Result := False;
  CoInitialize(nil);
  try
    IU := CreateComObject(CLSID_ShellLink);
    with IU as IShellLink do begin
      if SetPath(PChar(TargetApp)) <> NOERROR then Abort;
      if SetArguments(PChar(Arg)) <> NOERROR then Abort;
      if SetWorkingDirectory(PChar(WorkDir)) <> NOERROR then Abort;
      if (IconPath <> '') and (SetIconLocation(PChar(IconPath),IconNo) <> NOERROR) then Abort;
      if (HotKey <> 0) and (SetHotkey(Hotkey) <> NOERROR) then Abort;
      if Comment <> '' then
      begin
        if SetDescription(PChar(Comment)) <> NOERROR then Abort;
      end;
      if State >= 0 then
      begin
        if SetShowCmd(State) <> NOERROR then Abort;
      end;
    end;
    {$IF RTLVersion < 20}
    tmp := SavePath;
    if (IU as IPersistFile).Save(PWideChar(tmp), False) <> S_OK then Abort;
    {$ELSE}
    if (IU as IPersistFile).Save(PWideChar(SavePath), False) <> S_OK then Abort;
    {$IFEND}
    Result := True
  except
  end;
  CoUninitialize;
end;


function TKPathUtils.AddLastPathDelim(path: string): string;
begin
  Result := IncludeTrailingPathDelimiter(path);
  {
  if Copy(path, Length(path), 1) <> PathDelim then
  begin
    Result := path + PathDelim;
  end else
  begin
    Result := path;
  end;
  }
end;

function TKPathUtils.AppData: string;
begin
  Result := GetSpecialDir(CSIDL_APPDATA);
end;

procedure TKPathUtils.Copy(PathFrom, PathTo: string);
var
  sh: SHFILEOPSTRUCT;
  ret: Integer;
begin
  PathFrom  := PathFrom + #0;
  PathTo    := PathTo   + #0;
  ZeroMemory(@sh, SizeOf(SHFILEOPSTRUCT));
  sh.wFunc := FO_COPY;
  sh.fFlags := FOF_SIMPLEPROGRESS or FOF_NOCONFIRMATION;
  sh.fAnyOperationsAborted := True;
  sh.pFrom := PChar(PathFrom);
  sh.pTo   := PChar(PathTo);
  //
  ret := SHFileOperation(sh);
  if ret <> 0 then
  begin
    raise Exception.Create('Could not Copy Path:' + PathFrom);
  end;
end;

procedure TKPathUtils.Delete(path: string; FlagRecycle: Boolean = True);
var
  sh: SHFILEOPSTRUCT;
  ret: Integer;
  wpath: string;
begin
  ZeroMemory(@sh, SizeOf(SHFILEOPSTRUCT));
  sh.wFunc := FO_DELETE;
  sh.fFlags :=
    FOF_SIMPLEPROGRESS or
    FOF_NOCONFIRMATION;
    //FOF_SILENT or FOF_NOCONFIRMATION or FOF_NOCONFIRMMKDIR or FOF_NOERRORUI;
  if FlagRecycle then
  begin
    sh.fFlags := sh.fFlags or FOF_ALLOWUNDO;
  end;
  sh.fAnyOperationsAborted := True;
  wpath := path + #0#0;
  sh.pFrom := PChar(wpath);
  sh.pTo   := nil;
  //
  ret := SHFileOperation(sh);
  if ret <> 0 then
  begin
    raise Exception.Create('Could not Remove Path:' + path + ':' +
      GetLastErrorStr(ret));
  end;
end;

function TKPathUtils.DesktopDir: string;
begin
  Result := GetSpecialDir(CSIDL_DESKTOP);
end;

function TKPathUtils.ExeDir: string;
begin
  Result := AppPath;
end;

function TKPathUtils.ExeFile: string;
begin
  Result := ParamStr(0);
end;

function GetSpecialFolder(id: DWORD): AnsiString;
var
  PID: PItemIDList;
  Path: array [0..MAX_PATH-1] of AnsiChar;
begin
  SHGetSpecialFolderLocation(GetDesktopWindow, id, PID);
  SHGetPathFromIDListA(PID, Path);
  Result := Path;
  if Copy(Result, Length(Result),1)<>'\' then Result := Result + '\';
end;

function TKPathUtils.GetSpecialDir(CSIDL: DWord): string;
{$IF RTLVersion < 20}
begin
    Result := GetSpecialFolder(CSIDL);
end;
{$ELSE}
var
    PIDL: PItemIDList;
    path: array[0..MAX_PATH-1] of WideChar;
begin
    SHGetSpecialFolderLocation(AppHandle, CSIDL, PIDL);
    SHGetPathFromIDList(PIDL, path);
    Result := AddLastPathDelim(path);
end;
{$IFEND}

function TKPathUtils.GetTempFile(head: string): string;
var
  dir: string;
  res: string;
begin
  dir := TempDir;
  SetLength(res, MAX_PATH);
  {$IF RTLVersion < 20}
  GetTempFileName(PChar(dir), PChar(head), 0{必ず0}, PChar(res));
  Result := PChar(res);
  {$ELSE}
  GetTempFileNameW(PWideChar(dir), PWideChar(head), 0{必ず0}, PWideChar(res));
  Result := PWideChar(res);
  {$IFEND}
end;

function TKPathUtils.MuMusic: string;
begin
  Result := GetSpecialDir(CSIDL_MYMUSIC);
end;

function TKPathUtils.MyDocument: string;
begin
  Result := GetSpecialDir(CSIDL_PERSONAL);
end;


function TKPathUtils.MyPicture: string;
begin
  Result := GetSpecialDir(CSIDL_MYPICTURES);
end;

function TKPathUtils.MyVideo: string;
begin
  Result := GetSpecialDir(CSIDL_MYVIDEO);
  if Result = '' then
  begin
    Result := MyDocument + 'Videos\';
  end;
end;

function TKPathUtils.ProgramFiles: string;
begin
  Result := GetSpecialDir(CSIDL_PROGRAM_FILES);
end;

function TKPathUtils.SendTo: string;
begin
  Result := GetSpecialDir(CSIDL_SENDTO);
end;

function TKPathUtils.StartUpDir: string;
begin
  Result := GetSpecialDir(CSIDL_STARTUP);
end;

function TKPathUtils.SystemDir: string;
begin
  Result := GetSpecialDir(CSIDL_SYSTEM);
end;

function TKPathUtils.TempDir: string;
var
  buf: WideString;
begin
  SetLength(buf, MAX_PATH);
  GetTempPathW(MAX_PATH-1, PWideChar(buf));
  Result := PWideChar(buf);
  Result := AddLastPathDelim(Result);
end;

initialization

finalization
  begin
    FreeAndNil(_path);
  end;

end.
