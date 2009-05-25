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
    if (IU as IPersistFile).Save(PChar(SavePath), False) <> S_OK then Abort;
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
  sh.pFrom := PWideChar(PathFrom);
  sh.pTo   := PWideChar(PathTo);
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
  wpath: WideString;
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
  sh.pFrom := PWideChar(wpath);
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

function TKPathUtils.GetSpecialDir(CSIDL: DWord): string;
var
    PIDL: PItemIDList;
    path: array[0..MAX_PATH-1] of WideChar;
begin
    SHGetSpecialFolderLocation(AppHandle, CSIDL, PIDL);
    SHGetPathFromIDList(PIDL, path);
    Result := AddLastPathDelim(path);
end;

function TKPathUtils.GetTempFile(head: string): string;
var
  dir: string;
  res: string;
begin
  dir := TempDir;
  SetLength(res, MAX_PATH);
  GetTempFileNameW(PWideChar(dir), PWideChar(head), 0{必ず0}, PWideChar(res));
  Result := PWideChar(res);
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
