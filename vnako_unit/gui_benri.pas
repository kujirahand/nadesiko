unit gui_benri;

(**
����:�ʓ|�Ȏ葱�������j�b�g�ɂ܂Ƃ߂�����
���:������͂��(http://kujirahand.com/)
���J:2001/07/07 - 2001/10/21
�X�V:2006/08/24
*)

interface
uses
  SysUtils, Forms, Classes, Windows, ShellApi, ComObj, ActiveX, ShlObj, Registry, Messages;

function AppPath: string;

function MsgYesNo(msg: string): Boolean; overload;
function MsgYesNo(msg,cap: string): Boolean; overload;
function MsgYesNoCancel(msg: string): Integer; overload;
function MsgYesNoCancel(msg,cap: string): Integer; overload;
procedure ShowWarn(msg: string; cap: string = '');//�x���_�C�A���O��\��
procedure ShowInfo(msg: string; cap: string = '');//���_�C�A���O��\��
procedure ShowError(msg: string; cap: string = '');//���_�C�A���O��\��


{Windows�t�H���_�𓾂�}
function WinDir:string;
{System�t�H���_�𓾂�}
function SysDir:string;
{Temp�t�H���_�𓾂�}
function TempDir:string;
{�f�X�N�g�b�v�t�H���_�𓾂�}
function DesktopDir:string;
{����t�H���_�𓾂�}
function GetSpecialFolder(const loc:Word): string;
function SendToDir:string;
function StartUpDir:string;
function StartMenuDir:string;
function MyDocumentDir:string;
function GomibakoDir:string;
function FavoritesDir:string;
function ProgramsDir:string;
function RecentDir:string;
function MyMusicDir:string;
function MyPictureDir:string;
function FontsDir: string;
function AppData:string;
function LocalAppData:string;
function CommonAppData:string;


{�I���W�i���ꎞ�t�@�C�����̎擾(dirname���ȗ��ŁATempDir���Q��)}
function getOriginalFileName(dirname, header: string): string;

{�V���[�g�J�b�g���쐬����}
function CreateShortCut(Name, Target, Arg, WorkDir: string; State: TWindowState): Boolean;

function StrToDateDef(const StrDate, DefDate: string): TDateTime;

{chkDay���AbaseDay�ȍ~�Ȃ�ATrue ��Ԃ�}
function DateAfter(const baseDay, chkDay: TDateTime): Boolean;

function makeShortcut(FilePath, Description, WorkDir: string): Boolean;
function makeShortcutDesktop(FilePath, Description, WorkDir: string): Boolean;

{�T�u�t�H���_�܂ň�C�ɃR�s�[����}
function SHFileCopy(const Sorce, Dest: string): Boolean;
function SHFileCopyEx(const Sorce, Dest, Title: string): Boolean;
function SHFileDelete(const Sorce: string): Boolean;
function SHFileMove(const Sorce, Dest: string): Boolean;
function SHFileRename(const Sorce, Dest: string): Boolean;


{Windows �� XCopy.exe ���g���āA��C�ɃR�s�[}
procedure XCopy(const Sorce, Dest: AnsiString);

{�t�@�C���ɔC�ӂ̕��������������}
function WriteTextFile(const fname, str:string):Boolean;
function ReadTextFile(const fname:string; var str:string):Boolean;

{�\�t�g���N������}
function RunApp(const fname: AnsiString; IsHide:Boolean = False): Boolean;
function OpenApp(const fname: string; IsHide:Boolean = False): Integer;
function RunAppAndWait(const fname: string; arg: string = ''): Boolean;

{�f�B���N�g���̑I���F�E���ɕ\������Ȃ��o�[�W�����FOwnerHandle���A�t�H�[���̂��̂ɂ���}
function SelectDirectoryEx(const Caption: string; const Root: WideString;
  out Directory: string; OwnerHandle: THandle): Boolean;

{�����t�@�C�����𓾂�}
function ShortToLongFileName(ShortName: String):String;

{Windows�̃o�[�W�����𕶎���ŗ�}
function getWinVersion: string;
function isVistaOr7: Boolean;
function isWindowsSeven: Boolean;
function isWindowsVista:Boolean;
function isWindows2000:Boolean;
function isWindowsXP:Boolean;

{WM_COPYDATA���ȒP�ɑ��M����}
procedure SendCOPYDATA(hwnd: THandle; str: string; msgid: DWORD; SelfHandle: THandle);


implementation

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




function OpenApp(const fname: string; IsHide:Boolean = False): Integer;
begin
  if IsHide then
  begin
    Result := ShellExecute(0, 'open', PChar(fname),'','',SW_HIDE);
  end else
  begin
    Result := ShellExecute(0, 'open', PChar(fname),'','',SW_SHOW);
  end;
end;

function RunAppAndWait(const fname: string; arg: string = ''): Boolean;
var
  SI :TStartupInfo;
  PI :TProcessInformation;
begin
    GetStartupInfo(SI);
    try
        if arg<>'' then
        begin
          if not CreateProcess(nil, PChar(arg), nil, nil,False, 0, nil, nil,
            SI, PI) then raise Exception.Create('Error!');
        end else
        begin
          if not CreateProcess(nil, PChar(fname), nil, nil,False, 0, nil, nil,
            SI, PI) then raise Exception.Create('Error!');
        end;
        //  �X���b�h�n���h���͎g��Ȃ��̂ő����ɊJ��
        CloseHandle(pi.hThread);

        while WaitForSingleObject(PI.hProcess, 0) = WAIT_TIMEOUT do
        begin
            Application.ProcessMessages;       // �v���Z�X�I���܂őҋ@����
            sleep(100);
        end;
        // �v���Z�X�n���h�����J��
        CloseHandle(pi.hProcess);

        Result := True;
    except
        Result := False;
    end;
end;

{WM_COPYDATA���ȒP�ɑ��M����}
procedure SendCOPYDATA(hwnd: THandle; str: string; msgid: DWORD; SelfHandle: THandle);
var
  cd  : TCopyDataStruct;
  len : integer;
  Msg : PChar;
begin
  if hwnd <> 0 then
  begin
    //���郁�b�Z�[�W
    len :=  Length(str) + 1;
    cd.dwData :=  msgid;
    cd.cbData :=  len;
    GetMem(Msg, len);
    try
      StrPCopy(Msg, str);
      cd.lpData := Msg;
      //���M��E�B���h�E���A�N�e�B�u�ɂ���
      // SetForegroundWindow(hwnd);
      //���M
      SendMessage(hwnd, WM_COPYDATA, SelfHandle, LParam(@cd));
    finally
      FreeMem(Msg, len);
    end;
  end;
end;


function getWinVersion: string;
var
    Major,Minor: LongInt;
    Info: TOSVersionInfo;
begin
    Info.dwOSVersionInfoSize := SizeOf(Info);
    GetVersionEx(Info);
    Major := Info.dwMajorVersion ;
    Minor := Info.dwMinorVersion ;
    case major of
        4://95/98/ME/NT
            begin
                if Info.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS then
                begin
                    case Minor of
                        0 :Result := 'Windows 95';
                        10:Result := 'Windows 98';
                        90:Result := 'Windows Me';
                    end;
                end else
                if Info.dwPlatformId = VER_PLATFORM_WIN32_NT then
                begin
                    Result := 'Windows NT 4.0';
                end;
            end;
        3://NT 3.51
            begin
                Result := 'Windows NT 3.51';
            end;
        5://2000/XP/.NET Server
            begin
                case Minor of
                    0: Result := 'Windows 2000';
                    1: Result := 'Windows XP';
                end;
            end;
        6:// Vista
            begin
                case Minor of
                    0: Result := 'Windows Vista';
                    1: Result := 'Windows Vista�ȍ~';
                end;
            end;
        else begin
            Result := '�s�� Version = '+ IntToStr(GetVersion);
        end;
    end;
end;

function isVistaOr7: Boolean;
var
  osInfo: OSVERSIONINFO;
begin
  Result := False;
  osInfo.dwOSVersionInfoSize := sizeof(OSVERSIONINFO);
  if not GetVersionEx(osInfo) then Exit;
  Result := (osInfo.dwMajorVersion = 6) or (osInfo.dwMajorVersion > 6);
end;

function isWindowsSeven: Boolean;
var
  osInfo: OSVERSIONINFO;
begin
  Result := False;
  osInfo.dwOSVersionInfoSize:=sizeof(OSVERSIONINFO);
  if not GetVersionEx(osInfo) then Exit;
  Result := (osInfo.dwMajorVersion = 6) and (osInfo.dwMinorVersion = 1);
end;

function isWindowsVista:Boolean;
var
    Major,Minor: LongInt;
    Info: TOSVersionInfo;
begin
    Info.dwOSVersionInfoSize := SizeOf(Info);
    GetVersionEx(Info);
    Major := Info.dwMajorVersion ;
    Minor := Info.dwMinorVersion ;
    Result := (Major = 6) and (Minor = 0);
end;

function isWindows2000:Boolean;
var
    Major,Minor: LongInt;
    Info: TOSVersionInfo;
begin
    Info.dwOSVersionInfoSize := SizeOf(Info);
    GetVersionEx(Info);
    Major := Info.dwMajorVersion ;
    Minor := Info.dwMinorVersion ;
    Result := (Major = 5) and (Minor = 0);
end;

function isWindowsXP:Boolean;
var
    Major,Minor: LongInt;
    Info: TOSVersionInfo;
begin
    Info.dwOSVersionInfoSize := SizeOf(Info);
    GetVersionEx(Info);
    Major := Info.dwMajorVersion ;
    Minor := Info.dwMinorVersion ;
    Result := (Major = 5) and (Minor = 1);
end;

function CommonAppData:string;
begin
  Result := GetSpecialFolder(CSIDL_COMMON_APPDATA);
end;




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

        Sysutils.FindClose(SearchRec);
      end
    else
      // �t�@�C����������Ȃ���΂��̂܂�
      result := '\' + ExtractFileName(ShortName) + result;
    ShortName := ExtractFilePath(ShortName);
    SetLength(ShortName, Length(ShortName)-1); // �Ō�� '\' ���폜
  end;
  result := ShortName + result;
end;




{�I���W�i���ꎞ�t�@�C�����̎擾}
function getOriginalFileName(dirname, header: string): string;
var
    i: Integer;
    fname,s,ext: string;
begin
    if dirname='' then dirname := TempDir;
    i   := 1;
    s   := header;
    ext := ExtractFileExt(header);
    s   := Copy(s,1, Length(s)-Length(ext));
    if Copy(dirname,Length(dirname),1)<>'\' then dirname := dirname + '\';
    while True do
    begin
        fname := dirname + s + IntToStr(i) + ext;
        if FileExists(fname) = False then
        begin
            Result := fname; Break;
        end;
        Inc(i);
    end;
end;


function SelectDirectoryEx(const Caption: string; const Root: WideString;
  out Directory: string; OwnerHandle: THandle): Boolean;
var
  WindowList: Pointer;
  BrowseInfo: TBrowseInfo;
  Buffer: PChar;
  RootItemIDList, ItemIDList: PItemIDList;
  ShellMalloc: IMalloc;
  IDesktopFolder: IShellFolder;
  Eaten, Flags: LongWord;
  s: string;
begin
  Result := False;
  Directory := '';
  FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
  if (ShGetMalloc(ShellMalloc) = S_OK) and (ShellMalloc <> nil) then
  begin
    Buffer := ShellMalloc.Alloc(MAX_PATH);
    s := GetCurrentDir ;
    StrCopy(Buffer, PChar(s));
    try
      RootItemIDList := nil;
      if Root <> '' then
      begin
        SHGetDesktopFolder(IDesktopFolder);
        IDesktopFolder.ParseDisplayName(Application.Handle, nil,
          POleStr(Root), Eaten, RootItemIDList, Flags);
      end;
      with BrowseInfo do
      begin
        hwndOwner := OwnerHandle;
        pidlRoot := RootItemIDList;
        pszDisplayName := Buffer;
        lpszTitle := PChar(Caption);
        ulFlags := BIF_RETURNONLYFSDIRS;
      end;
      WindowList := DisableTaskWindows(0);
      try
        ItemIDList := ShBrowseForFolder(BrowseInfo);
      finally
        EnableTaskWindows(WindowList);
      end;
      Result :=  ItemIDList <> nil;
      if Result then
      begin
        ShGetPathFromIDList(ItemIDList, Buffer);
        ShellMalloc.Free(ItemIDList);
        Directory := Buffer;
      end;
    finally
      ShellMalloc.Free(Buffer);
    end;
  end;
end;


{�\�t�g���N������}
function RunApp(const fname: AnsiString; IsHide:Boolean = False): Boolean;
var
    retCode: Integer;
begin
    if IsHide then
    begin
      retCode := WinExec(PAnsiChar(fname), SW_HIDE);
    end else
    begin
      retCode := WinExec(PAnsiChar(fname), SW_SHOW);
    end;

    if retCode > 31 then
    begin
        Result:= True;
    end else
    begin
        Result :=False;
    end;
end;


{chkDay���AbaseDay�ȍ~�i���̓����܂ށj�Ȃ�ATrue ��Ԃ�}
function DateAfter(const baseDay, chkDay: TDateTime): Boolean;
var
	y1,m1,d1,  y2,m2,d2: Word;
    v1, v2: DWORD;
begin
    Result := False;
	DecodeDate(baseDay, y1, m1, d1);
    DecodeDate(chkDay,  y2, m2, d2);
    v1 := y1*365 + m1*12 + d1;
    v2 := y2*365 + m2*12 + d2;
	if v1 <= v2 then Result := True;
end;

{Windows�t�H���_�𓾂�}
function WinDir:string;
var
 TempWin:array[0..MAX_PATH] of Char;
begin
 GetWindowsDirectory(TempWin,MAX_PATH);
 Result:=StrPas(TempWin);
 if Copy(Result,Length(Result),1)<>'\' then Result := Result + '\';
end;

{System�t�H���_�𓾂�}
function SysDir:string;
var
 TempSys:array[0..MAX_PATH] of Char;
begin
 GetSystemDirectory(TempSys,MAX_PATH);
 Result:=StrPas(TempSys);
 if Copy(Result,Length(Result),1)<>'\' then Result := Result + '\';
end;

{Temp�t�H���_�𓾂�}
function TempDir:string;
var
 TempTmp:array[0..MAX_PATH] of Char;
begin
 GetTemppath(MAX_PATH,TempTmp);
 Result:=StrPas(TempTmp);
 if Copy(Result,Length(Result),1)<>'\' then Result := Result + '\';
end;


function GetSpecialFolder(const loc:Word): string;
var
   PathID: PItemIDList;
   Path : array[0..MAX_PATH] of char;
begin
   SHGetSpecialFolderLocation(Application.Handle, loc, PathID);
   SHGetPathFromIDList(PathID, Path);
   Result := string(Path);
   if Copy(Result, Length(Result),1)<>'\' then
    Result := Result + '\';
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
function GomibakoDir:string;
begin
   Result := GetSpecialFolder(CSIDL_BITBUCKET);
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

function CreateShortCut(Name, Target, Arg, WorkDir: string; State: TWindowState): Boolean;
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
      if SetPath(PChar(Target)) <> NOERROR then Abort;
      if SetArguments(PChar(Arg)) <> NOERROR then Abort;
      if SetWorkingDirectory(PChar(WorkDir)) <> NOERROR then Abort;
      if SetShowCmd(ShowCmd[State]) <> NOERROR then Abort
    end;
    W := PWChar(WideString(Name));
    if (IU as IPersistFile).Save(W, False) <> S_OK then Abort;
    Result := True
  except
  end
end;

function AppData:string;
begin
   Result := GetSpecialFolder(CSIDL_APPDATA);
end;

function LocalAppData:string;
begin
   Result := GetSpecialFolder(CSIDL_LOCAL_APPDATA);
end;


function AppPath: string;
begin
	result := ExtractFilePath( ParamStr(0) );
end;

function MsgYesNo(msg: string): Boolean;
var
	i: Integer;
begin
	i := MessageBox(Application.Handle,PChar(msg), PChar(Application.Title), MB_YESNO + MB_ICONQUESTION);
	if i=IDYES then
    	Result := True
    else
    	Result := False;
end;

function MsgYesNo(msg,cap: string): Boolean; overload;
var
	i: Integer;
begin
	i := MessageBox(Application.Handle,PChar(msg),
        PChar(cap), MB_YESNO + MB_ICONQUESTION);
	if i=IDYES then
    	Result := True
    else
    	Result := False;
end;


function MsgYesNoCancel(msg: string): Integer;
begin
	Result := MessageBox(Application.Handle,PChar(msg), PChar(Application.Title), MB_YESNOCANCEL + MB_ICONQUESTION);
end;

function MsgYesNoCancel(msg,cap: string): Integer; overload;
begin
	Result := MessageBox(Application.Handle,PChar(msg), PChar(cap), MB_YESNOCANCEL + MB_ICONQUESTION);
end;

procedure ShowWarn(msg: string; cap: string = '');//�x���_�C�A���O��\��
begin
    if cap='' then cap := Application.Title ;
	MessageBox(
        Application.Handle,
        PChar(msg),
        PChar(cap),
        MB_ICONWARNING or MB_OK);
end;
procedure ShowInfo(msg: string; cap: string = '');//���_�C�A���O��\��
begin
	if cap='' then cap := Application.Title ;
	MessageBox(
        Application.Handle,
        PChar(msg),
        PChar(cap),
        MB_ICONINFORMATION or MB_OK);
end;

procedure ShowError(msg: string; cap: string = '');//���_�C�A���O��\��
begin
	if cap='' then cap := Application.Title ;
	MessageBox(
        Application.Handle,
        PChar(msg),
        PChar(cap),
        MB_ICONERROR or MB_OK);
end;


function StrToDateDef(const StrDate, DefDate: string): TDateTime;
begin
    if StrDate='' then
    begin
    	Result := StrToDate(DefDate);
        Exit;
    end;
	try
    	Result := StrToDate(StrDate);
    except
    	try
        	Result := StrToDate(DefDate);
        except
        	Result := Date;
        end;
    end;
end;

function makeShortcut(FilePath, Description, WorkDir: string): Boolean;
var
	AnObj: IUnknown;
    ShLink: IShellLink;
    PFile: IPersistFile;
    Reg: TRegIniFile;
    WFilename: WideString ;
begin
	try
	AnObj := CreateComObject(CLSID_ShellLink) as IShellLink;
    ShLink := AnObj as IShellLink;
	PFile := ShLink as IPersistFile;
    ShLink.SetPath (PChar(FilePath));
    ShLink.SetDescription(PChar(Description));
    ShLink.SetWorkingDirectory(PChar(WorkDir));
	//save Desktop
    Reg := TRegIniFile.Create(
    	'Software\MicroSoft\Windows\CurrentVersion\Explorer');
	WFilename := Reg.ReadString('Shell Folders','Desktop','')+
    	'\' + Description + '.lnk';
    Reg.Free ;
    PFile.Save(PWChar(WFilename), False);
    //save StartMenu
    Reg := TRegIniFile.Create(
    	'Software\MicroSoft\Windows\CurrentVersion\Explorer');
	WFilename := Reg.ReadString('Shell Folders','Start Menu','')+
    	'\' + Description + '.lnk';
    Reg.Free ;
    PFile.Save(PWChar(WFilename), False);
    except
    	Result := False; Exit;
    end;
    Result := True;
end;

function makeShortcutDesktop(FilePath, Description, WorkDir: string): Boolean;
var
	AnObj: IUnknown;
    ShLink: IShellLink;
    PFile: IPersistFile;
    Reg: TRegIniFile;
    WFilename: WideString ;
begin
	try
	AnObj := CreateComObject(CLSID_ShellLink) as IShellLink;
    ShLink := AnObj as IShellLink;
	PFile := ShLink as IPersistFile;
    ShLink.SetPath (PChar(FilePath));
    ShLink.SetDescription(PChar(Description));
    ShLink.SetWorkingDirectory(PChar(WorkDir));
	//save Desktop
    Reg := TRegIniFile.Create(
    	'Software\MicroSoft\Windows\CurrentVersion\Explorer');
	WFilename := Reg.ReadString('Shell Folders','Desktop','')+
    	'\' + Description + '.lnk';
    Reg.Free ;
    PFile.Save(PWChar(WFilename), False);
    except
    	Result := False; Exit;
    end;
    Result := True;
end;

function SHFileCopyEx(const Sorce, Dest, Title: string): Boolean;
var
	foStruct: TSHFileOpStruct;
  s_src, s_des: string;
begin
    Result := False;
    if (Sorce='')or(Dest='') then Exit;

    s_src := Sorce + #0#0;
    s_des := Dest  + #0#0;

    with foStruct do
    begin
        wnd:=Application.Handle;
        wFunc  := FO_COPY;            //�t���O�i�R�s�[�̏ꍇ��FO_COPY�j
        pFrom  := PChar(s_src);
        pTo    := PChar(s_des);
        fFlags := FOF_NOCONFIRMATION or FOF_MULTIDESTFILES or FOF_NOCONFIRMMKDIR;
        fAnyOperationsAborted := False;          // ���������f���ꂽ�ꍇ FALSE ���Ԃ�
        hNameMappings         := nil;            // �����O��̃t�@�C��
        lpszProgressTitle     := PChar(Title);   // �_�C�A���O�̃^�C�g��
    end;
    Result := (SHFileOperation(foStruct) = 0);
end;

function SHFileCopy(const Sorce, Dest: string): Boolean;
var
	foStruct: TSHFileOpStruct;
begin
    Result := False;
    if (Sorce='')or(Dest='') then Exit;
    with foStruct do
    begin
        wnd:=Application.Handle;
        wFunc:=FO_COPY;  //�t���O�i�R�s�[�̏ꍇ��FO_COPY�j
        pFrom:=PChar(Sorce+#0#0);  //����t�H���_
        pTo:=PChar(Dest+#0#0);
        fFlags:=FOF_SILENT or FOF_NOCONFIRMATION or FOF_MULTIDESTFILES ;  //�_�C�A���O��\��
        fAnyOperationsAborted:=False;
        hNameMappings:=nil;
        lpszProgressTitle:=nil;
    end;

    Result := (SHFileOperation(foStruct)=0);
end;

function SHFileDelete(const Sorce: string): Boolean;
var
	foStruct: TSHFileOpStruct;
begin
    with foStruct do
    begin
        wnd:=Application.Handle;
        wFunc:=FO_DELETE;  //�t���O�i�R�s�[�̏ꍇ��FO_COPY�j
        pFrom:=PChar(Sorce+#0#0);  //����t�H���_
        pTo:=Nil;
        fFlags:=FOF_SILENT or FOF_NOCONFIRMATION or FOF_ALLOWUNDO or FOF_MULTIDESTFILES;  //�_�C�A���O��\��
        {fAnyOperationsAborted:=False;
        hNameMappings:=nil;
        lpszProgressTitle:=nil;}
    end;

    Result := (SHFileOperation(foStruct)=0);
(*
  //FileOp�̏�����
  //�����t�@�C�������ݔ��֍폜
  with FileOp do
  begin
    Wnd := Handle;
    wFunc := FO_DELETE;
    pFrom := PChar( FNames);
    pTo := Nil;
    fFlags := FOF_ALLOWUNDO;
  end;

  SHFileOperation( FileOp);
*)
end;
function SHFileMove(const Sorce, Dest: string): Boolean;
var
	foStruct: TSHFileOpStruct;
begin
    with foStruct do
    begin
        wnd:=Application.Handle;
        wFunc:=FO_MOVE;  //�t���O�i�R�s�[�̏ꍇ��FO_COPY�j
        pFrom:=PChar(Sorce+#0#0);  //����t�H���_
        pTo:=PChar(Dest + #0#0);
        fFlags:=FOF_NOCONFIRMATION or FOF_ALLOWUNDO;  //�_�C�A���O��\��
        fAnyOperationsAborted:=False;
        hNameMappings:=nil;
        lpszProgressTitle:=nil;
    end;

    Result := (SHFileOperation(foStruct)=0);
end;

//�Ȃ񂾂��A�R�s�[����Ă��܂��悤�ł���E�E�E�v����
function SHFileRename(const Sorce, Dest: string): Boolean;
var
	foStruct: TSHFileOpStruct;
begin
    with foStruct do
    begin
        wnd:=Application.Handle;
        wFunc:=FO_RENAME;  //�t���O�i�R�s�[�̏ꍇ��FO_COPY�j
        pFrom:=PChar(Sorce+#0#0);  //����t�H���_
        pTo:=PChar(Dest + #0#0);
        fFlags:=FOF_SILENT or FOF_NOCONFIRMATION or FOF_MULTIDESTFILES or FOF_ALLOWUNDO;  //�_�C�A���O��\��
        fAnyOperationsAborted:=False;
        hNameMappings:=nil;
        lpszProgressTitle:=nil;
    end;

    Result := (SHFileOperation(foStruct)=0);
end;


{Windows �� XCopy.exe ���g���āA��C�ɃR�s�[}
procedure XCopy(const Sorce, Dest: AnsiString);
var s: AnsiString;
begin
	s := 'XCOPY.EXE "'+Sorce+'" "'+dest+'" /E';
    WinExec(PAnsiChar(s),SW_NORMAL);
end;

{�t�@�C���ɔC�ӂ̕��������������}
function WriteTextFile(const fname, str:string):Boolean;
var
  s: TMemoryStream;
begin
  Result := True;
  s := TMemoryStream.Create;
  try
    try
      s.Write(str[1], Length(str));
      s.SaveToFile(fname);
    except
      Result := False;
    end;
  finally
    s.Free;
  end;
end;
function ReadTextFile(const fname:string; var str:string):Boolean;
var
  s: TMemoryStream;
begin
  Result := True;
  s := TMemoryStream.Create;
  try
    try
      s.LoadFromFile(fname);
      SetLength(str, s.Size);
      s.Read(str[1], s.Size);
    except
      Result := False;
    end;
  finally
    s.Free;
  end;
end;




end.
