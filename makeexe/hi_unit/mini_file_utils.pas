unit mini_file_utils;

interface

uses
  Windows, Messages, SysUtils, Commdlg, shlobj, activex,
  ShellAPI, ComObj;

const
  MAX_PATH = 1024;

// Open / Save Dialog
function ShowOpenDialog(hOwner:HWND; Filter, InitDir: string; InitFile: string=''): string;
function ShowSaveDialog(hOwner:HWND; Filter, InitDir: string; InitFile: string=''): string;
function OpenFolderDialog(var FolderPath: string): boolean;

function GetSpecialFolder(id: DWORD): string;

function WinDir:string;
function SysDir:string;
function TempDir:string;
function DesktopDir:string;
function SendToDir:string;
function StartUpDir:string;
function RecentDir:string;
function ProgramsDir:string;
function StartMenuDir:string;
function MyDocumentDir:string;
function FavoritesDir: string;
function MyMusicDir:string;
function MyPictureDir:string;
function FontsDir: string;
function ProgramFilesDir:string;
function QuickLaunchDir:string;

function RunAndWait(path: string; Hide: Boolean=False): Boolean;
function OpenApp(path: string; Hide: Boolean=False): Boolean;
function RunApp(path: string; Hide: Boolean=False): Boolean;

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


implementation

uses unit_string, hima_types;

{
const
  CSIDL_DESKTOP 		=$0000;//「デスクトップ」（ネームスペースのルートを表す仮想フォルダ）
  CSIDL_INTERNET 		=$0001;//「Internet Explorer」（仮想フォルダ）
  CSIDL_PROGRAMS 		=$0002;//「プログラム」（ファイルシステムディレクトリ）
  CSIDL_CONTROLS 		=$0003;//「コントロール パネル」（仮想フォルダ）
  CSIDL_PRINTERS 		=$0004;//「プリンタ」（仮想フォルダ）
  CSIDL_PERSONAL 		=$0005;//「マイ ドキュメント」（ファイルシステムディレクトリ）
  CSIDL_FAVORITES 		=$0006;//「お気に入り」（ファイルシステムディレクトリ）
  CSIDL_STARTUP 		=$0007;//「スタートアップ」（ファイルシステムディレクトリ）
  CSIDL_RECENT 		=$0008;//「最近使ったファイル」（ファイルシステムディレクトリ）
  CSIDL_SENDTO 		=$0009;//「SendTo」（ファイルシステムディレクトリ）
  CSIDL_BITBUCKET 		=$000a;//「ごみ箱」（仮想フォルダ）
  CSIDL_STARTMENU 		=$000b;//「スタートメニュー」（ファイルシステムディレクトリ）
  CSIDL_MYMUSIC 		=$000d;//「マイ ミュージック」（ファイルシステムディレクトリ）
  CSIDL_DESKTOPDIRECTORY 		=$0010;//「デスクトップ」上のファイルオブジェクトを格納するフォルダ（ファイルシステムディレクトリ）
  CSIDL_DRIVES 		=$0011;//「マイ コンピュータ」（仮想フォルダ）
  CSIDL_NETWORK 		=$0012;//「ネットワークコンピュータ」（仮想フォルダ）
  CSIDL_NETHOOD 		=$0013;//「NetHood」（ファイルシステムディレクトリ）
  CSIDL_FONTS 		=$0014;//「Fonts」（フォントを含む仮想フォルダ）
  CSIDL_TEMPLATES 		=$0015;//ドキュメントテンプレートが格納されるフォルダ（ファイルシステムディレクトリ）
  CSIDL_COMMON_STARTMENU 		=$0016;//AllUsers の「スタートメニュー」（ファイルシステムディレクトリ）
  CSIDL_COMMON_PROGRAMS 		=$0017;//AllUsers の「プログラム」（ファイルシステムディレクトリ）
  CSIDL_COMMON_STARTUP 		=$0018;//AllUsers の「スタートアップ」（ファイルシステムディレクトリ）
  CSIDL_COMMON_DESKTOPDIRECTORY 		=$0019;//AllUsers の「デスクトップ」（ファイルシステムディレクトリ）
  CSIDL_APPDATA 		=$001a;//Version 4.71 以降： 「Application Data」（ファイルシステムディレクトリ）
  CSIDL_PRINTHOOD 		=$001b;//「プリンタ」仮想フォルダにおかれるリンクオブジェクトを格納するフォルダ（ファイルシステムディレクトリ）
  CSIDL_LOCAL_APPDATA 		=$001c;//Version 5.0 以降： 「Application Data」（ファイルシステムディレクトリ）
  CSIDL_ALTSTARTUP 		=$001d;//非ローカル版の「スタートアップ」（ファイルシステムディレクトリ）
  CSIDL_COMMON_ALTSTARTUP 		=$001e;//非ローカル版の AllUsers の「スタートアップ」（ファイルシステムディレクトリ）
  CSIDL_COMMON_FAVORITES 		=$001f;//AllUsers の「お気に入り」（NT系のみ）（ファイルシステムディレクトリ）
  CSIDL_INTERNET_CACHE 		=$0020;//Version 4.72 以降： インターネット一時ファイルを格納するフォルダ（ファイルシステムディレクトリ）
  CSIDL_COOKIES 		=$0021;//「Cookies」（ファイルシステムディレクトリ）
  CSIDL_HISTORY 		=$0022;//「履歴」（ファイルシステムディレクトリ）
  CSIDL_COMMON_APPDATA 		=$0023;//Version 5.0 以降： AllUsers の「Application Data」（ファイルシステムディレクトリ）
  CSIDL_WINDOWS 		=$0024;//Version 5.0 以降： Windows ディレクトリ
  CSIDL_SYSTEM 		=$0025;//Version 5.0 以降： Windows System ディレクトリ
  CSIDL_PROGRAM_FILES 		=$0026;//Version 5.0 以降： Program Files フォルダ
  CSIDL_MYPICTURES 		=$0027;//Version 5.0 以降： My Pictures フォルダ（ファイルシステムディレクトリ）
  CSIDL_PROFILE 		=$0028;//Version 5.0 以降： profile フォルダ
  CSIDL_PROGRAM_FILES_COMMON 		=$002b;//Version 5.0 以降；Windows 2000/XP： Program Files\Common
  CSIDL_COMMON_TEMPLATES 		=$002d;//Windows NT/2000/XP： AllUsers のドキュメントテンプレートが格納されるディレクトリ
  CSIDL_COMMON_DOCUMENTS 		=$002e;//Shfolder.dll： AllUsers のドキュメントテンプレートが格納されるディレクトリ（Windows NT 系および Shfolder.dll がインストールされた Windows 9x）
  CSIDL_COMMON_ADMINTOOLS 		=$002f;//Version 5.0 以降： AllUsers の管理ツールディレクトリ
  CSIDL_ADMINTOOLS 		=$0030;//Version 5.0 以降： 管理ツールディレクトリ
}


function GetSpecialFolder(id: DWORD): string;
var
  PID: PItemIDList;
  Path: array [0..MAX_PATH-1] of Char;
begin
  SHGetSpecialFolderLocation(GetDesktopWindow, id, PID);
  SHGetPathFromIDList(PID, Path);
  Result := Path;
  if Copy(Result, Length(Result),1)<>'\' then Result := Result + '\';
end;



{Windowsフォルダを得る}
function WinDir:string;
var
 TempWin:array[0..MAX_PATH] of Char;
begin
 GetWindowsDirectory(TempWin,MAX_PATH);
 Result:=StrPas(TempWin);
 if Copy(Result,Length(Result),1)<>'\' then Result := Result + '\';
end;

{Systemフォルダを得る}
function SysDir:string;
var
 TempSys:array[0..MAX_PATH] of Char;
begin
 GetSystemDirectory(TempSys,MAX_PATH);
 Result:=StrPas(TempSys);
 if Copy(Result,Length(Result),1)<>'\' then Result := Result + '\';
end;

{Tempフォルダを得る}
function TempDir:string;
var
 TempTmp:array[0..MAX_PATH] of Char;
begin
 GetTemppath(MAX_PATH,TempTmp);
 Result:=StrPas(TempTmp);
 if Copy(Result,Length(Result),1)<>'\' then Result := Result + '\';
end;

function DesktopDir:string;
begin
   Result := GetSpecialFolder(CSIDL_DESKTOPDIRECTORY);
end;
function SendToDir:string;
begin
   Result := GetSpecialFolder(CSIDL_SENDTO);
end;
function StartUpDir:string;
begin
   Result := GetSpecialFolder(CSIDL_STARTUP);
end;
function RecentDir:string;
begin
   Result := GetSpecialFolder(CSIDL_RECENT);
end;
function ProgramsDir:string;
begin
   Result := GetSpecialFolder(CSIDL_PROGRAMS);
end;
function StartMenuDir:string;
begin
   Result := GetSpecialFolder(CSIDL_STARTMENU);
end;
function MyDocumentDir:string;
begin
   Result := GetSpecialFolder(CSIDL_PERSONAL);
end;
function FavoritesDir: string;
begin
   Result := GetSpecialFolder(CSIDL_FAVORITES);
end;
function MyMusicDir:string;
begin
   Result := GetSpecialFolder(CSIDL_MYMUSIC);
end;
function MyPictureDir:string;
begin
   Result := GetSpecialFolder(CSIDL_MYPICTURES);
end;
function FontsDir: string;
begin
   Result := GetSpecialFolder(CSIDL_FONTS);
end;
function ProgramFilesDir:string;
begin
   Result := GetSpecialFolder(CSIDL_PROGRAM_FILES);
end;

function QuickLaunchDir:string;
begin
   Result := GetSpecialFolder(CSIDL_APPDATA) + 'Microsoft\Internet Explorer\Quick Launch\';
end;

//-------------------------------------------------------------------------
function CheckFilter(Filter: string): string;
begin
  if Pos('|', Filter) = 0 then
  begin
    if Filter = '' then Filter := '全てのファイル(*.*)|*.*'
    else begin
      if Pos('.', Filter) = 0 then Filter := '.' + Filter;
      if Pos('*', Filter) = 0 then Filter := '*' + Filter;
      Filter := '(' + Filter + ') 形式|' + Filter + '|全てのファイル(*.*)|*.*';
    end;
  end;
  Result := Filter;
end;

function ReplaceChar(const s: string; fromCH, toCH: Char): string;
var
  i: Integer;
begin
  Result := s;
  i := 1;
  while i <= Length(s) do
  begin
    if Result[i] in LeadBytes then
    begin
      Inc(i, 2);
    end else
    begin
      if Result[i] = fromCH then Result[i] := toCH;
      Inc(i);
    end;
  end;
end;

function ShowOpenDialog(hOwner:HWND; Filter, InitDir: string; InitFile: string=''): string;
var
  OFN: TOpenFileName;
  PATH, s, res: string;
  p: PChar;
begin
  PATH := InitFile+#0;
  SetLength(PATH,MAX_PATH+5);
  //----------------------------------------------------------------------------
  // FILTER
  Filter := CheckFilter(Filter);
  Filter := ReplaceChar(Filter, '|', #0)+#0;

  // OpenFileName 構造体にセット
  FillChar(OFN,SizeOf(OFN),0);
  with OFN do
  begin
    lStructSize := 76; // for Delphi6
    hWndOwner := hOwner;
    lpstrFilter := PChar(Filter);
    nFilterIndex := 1;
    lpstrFile := PChar(PATH);
    nMaxFile:= MAX_PATH+5;
    lpstrInitialDir := PChar(InitDir);
    Flags := OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_EXPLORER or OFN_ALLOWMULTISELECT;
  end;

  if GetOpenFileName(OFN) then
  begin
    SetLength(res, OFN.nMaxFile);
    ZeroMemory(PChar(res), OFN.nMaxFile);
    StrMove(PChar(res), OFN.lpstrFile, OFN.nMaxFile);

    Result := ''; p := PChar(res);

    // ファイル名の取り出し(マルチ対応版 NULL 区切り配列)
    PATH := getTokenStr(p, #0);
    Inc(p); // skip #0
    if p^ = #0 then
    begin
      Result := Trim(PATH); Exit;
    end;

    while p^ <> #0 do
    begin
      s := getTokenStr(p, #0);
      Result := Result + PATH + '\' + s + #13#10;
      Inc(p); // skip #0
    end;

    Result := Trim(Result);
  end else
  begin
    Result := '';
  end;
end;


function ShowSaveDialog(hOwner:HWND; Filter, InitDir: string; InitFile: string=''): string;
var
  OFN: TOpenFileName;
  PATH: string;
  ext: string;
  extList: THStringList;
begin
  PATH := InitFile+#0;
  SetLength(PATH,MAX_PATH+5);
  //----------------------------------------------------------------------------
  // FILTER
  Filter := CheckFilter(Filter);
  extList := THStringList.Create;
  extList.SplitText(Filter, '|');
  Filter := ReplaceChar(Filter, '|', #0)+#0;

  // OpenFileName 構造体にセット
  FillChar(OFN,SizeOf(OFN),0);
  with OFN do
  begin
    lStructSize := 76; // for Delphi6
    hWndOwner := hOwner;
    lpstrFilter := PChar(Filter);
    nFilterIndex := 1;
    lpstrFile := PChar(PATH);

    nMaxFile:= MAX_PATH+5;
    lpstrInitialDir := PChar(InitDir);
    Flags := OFN_OVERWRITEPROMPT or OFN_HIDEREADONLY;
  end;

  if GetSaveFileName(OFN) then
  begin
    SetLength(Result, OFN.nMaxFile);
    ZeroMemory(PChar(Result), OFN.nMaxFile);
    StrMove(PChar(Result), OFN.lpstrFile, OFN.nMaxFile);

    Result := Trim(string( PChar(Result) ));
    if ExtractFileExt(Result) = '' then
    begin
      ext := extList.Strings[ (OFN.nFilterIndex-1) * 2 + 1 ];
      ext := ExtractFileExt(getToken_s(ext, ';'));
      if (Pos('*', ext) > 0)or(Pos('?', ext) > 0) then ext := '';
      Result := ChangeFileExt(Result, ext);
    end;

  end else
  begin
    Result := '';
  end;
  //
  extList.Free;
end;

{フォルダの参照ダイアログ用コールバック関数}
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

{フォルダの参照ダイアログを開く}
function OpenFolderDialog(var FolderPath: string): boolean;
var
  Malloc: IMalloc;
  BrowseInfo: TBrowseInfo;
  DisplayPath: array[0..MAX_PATH] of Char;
  IDList: PItemIdList;
  Buffer,pFolderPath: PChar;
begin
  Result:=False;

  if Succeeded(SHGetMalloc(Malloc)) then  //IMallocのポインタを取得できたら
  begin
   pFolderPath:=PChar(FolderPath);       //初期フォルダ指定用

   {BrowseInfo構造体を初期化}
   with BrowseInfo do
   begin
    hwndOwner      := GetActiveWindow();  //D4のSelectDirectoryでは、ここがApplication.Handleになっているので、表示位置がおかしくなる
    pidlRoot       := nil;
    pszDisplayName := DisplayPath;                             //表示名用バッファ
    lpszTitle      := 'フォルダを選択してください。';
    ulFlags        := BIF_RETURNONLYFSDIRS{ or BIF_STATUSTEXT};  //通常のフォルダのみ参照可能（特殊フォルダは選択できない）
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

function RunApp(path: string; Hide: Boolean=False): Boolean;
var
    retCode: Integer;
begin
    if Hide then
    begin
      retCode := WinExec(PChar(path), SW_HIDE);
    end else
    begin
      retCode := WinExec(PChar(path), SW_SHOW);
    end;

    if retCode > 31 then
    begin
        Result:= True;
    end else
    begin
        Result :=False;
    end;
end;

function OpenApp(path: string; Hide: Boolean=False): Boolean;
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
  res := ShellExecute(
    0, 'open', PChar(path), nil, nil,
    i);
  Result := (res > 32);
end;

function RunAndWait(path: string; Hide: Boolean): Boolean;
var
  ret: Boolean;
  ecode: Integer;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  Result := False;

  // 表示状態を設定
  with StartupInfo do begin
    // この構造体のサイズを指定
    cb := SizeOf(TStartupInfo);

    // ウィンドウの表示状態を指定
    if Hide then
      wShowWindow := SW_HIDE
    else
      wShowWindow := SW_SHOWNORMAL;

    // 有効な設定項目を指定
    dwFlags := STARTF_USESHOWWINDOW;

    // それ以外の項目を初期化
    lpReserved := nil;
    lpDesktop  := nil;
    lpTitle    := nil;
    cbReserved2 := 0;
    lpReserved2 := nil;
  end;
  // 実行
  ret := CreateProcess(
    nil,                        // 実行ファイル名
    PChar(path),                // コマンドライン
    nil,                        // プロセスのセキュリティ属性
    nil,                        // スレッドのセキュリティ属性
    False,                      // 親プロセスからハンドルを継承するか
    CREATE_DEFAULT_ERROR_MODE,  // 優先順位とプロセスの制作制御
    nil,                        // 環境変数ブロックへのポインタ
    nil,                        // カレントディレクトリ
    StartupInfo,                // ウィンドウの属性
    ProcessInfo                 // 新しいプロセスの情報を受け取る構造体
  );

  // エラーチェック
  if not ret then
  begin
    raise Exception.Create('『'+path+'』を実行できません。理由は、' + IntToStr(GetLastError) + '。');
  end;

  // 終了待ち(10秒待つ)
  ecode := WaitForSingleObject(ProcessInfo.hProcess, INFINITE);

  // メッセージ表示
  case ecode of
    WAIT_OBJECT_0:  Result := True;
    WAIT_TIMEOUT :  Result := False;
  end;
end;

initialization
;

finalization
;

end.
