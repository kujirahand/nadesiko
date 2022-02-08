unit unit_file;
//------------------------------------------------------------------------------
// ファイル入出力に関する汎用的なユニット
// [作成] クジラ飛行机
// [連絡] http://kujirahand.com/
// [日付] 2004/07/28
//
interface

uses
  {$IFDEF Win32}
  Windows, 
  ShellApi, comobj, shlobj, activex,
  {$ELSE}
  Types, dynlibs,
  {$ENDIF}
  SysUtils, Classes, hima_types;

type
  TWindowState2 = (ws2Normal, ws2Minimized, ws2Maximized);



{$IFDEF Win32}
// 文字列にファイルの内容を全部開く
function FileLoadAll(Filename: AnsiString): AnsiString;

// 文字列にファイルの内容を全部書き込む
procedure FileSaveAll(s, Filename: AnsiString);
{$ENDIF}

//COPY
function SHFileCopy(const Source, Dest, Title: AnsiString): Boolean;
function SHFileDelete(const Source: AnsiString): Boolean;
function SHFileDeleteComplete(const Source: AnsiString): Boolean;
function SHFileMove(const Source, Dest: AnsiString): Boolean;
function SHFileRename(const Source, Dest: AnsiString): Boolean;

//EnumFile
function EnumFiles(path: string): TStringList;
function EnumAllFiles(path: string; out basePath: string): TStringList; overload;
function EnumAllFiles(path: string): TStringList; overload;
function EnumAllDirs(path: string): TStringList;
function EnumDirs(const path: string): TStringList;
{$IFDEF Win32}
function CreateShortCut(SavePath, TargetApp, Arg, WorkDir: AnsiString; State: TWindowState2): Boolean;
function CreateShortCutEx(SavePath, TargetApp, Arg, WorkDir, IconPath: AnsiString;
    IconNo:Integer;Comment: AnsiString;Hotkey:Word; State: TWindowState2): Boolean;
function GetShortCutLink(Path : AnsiString): AnsiString;
{$ENDIF}

//ファイルの作成・更新・最終書込日時を得る
function GetFileTimeEx(fname:string; var tCreation, tLastAccess, tLastWrite:TDateTime):Boolean;
function SetFileTimeEx(fname:string; tCreation, tLastAccess, tLastWrite: TDateTime): Boolean;
//TDateTimeからファイル日時を得る
function DateTimeToFileTimeEx(dt: TDateTime):TFileTime;
// ファイルタイムをローカルなTTimeDateに変換する
function FileTimeToDateTimeEx(const ft:TFileTime):TDateTime;

function getVolumeName(drive: string): string;
function getSerialNo(drive: AnsiString): DWORD;
function getFileSystemName(drive: string): string;

function ShortToLongFileName(ShortName: string):string;
function LongToShortFileName(LongName: string):string;
procedure RunAsAdmin(hWnd: THandle; aFile: AnsiString; aParameters: AnsiString);

var MainWindowHandle: THandle = 0;

const
  HOTKEYF_SHIFT = $01;
  HOTKEYF_CONTROL = $02;
  HOTKEYF_ALT = $04;
  HOTKEYF_EXT = $08;

const
  UnixStartDate : tdatetime = 25569.0;
  TENTHOFSEC=100;
  SECOND=1000;
  MINUTE=60000;
  HOUR=3600000;
  DAY=86400000;
  SECONDSPERDAY=86400;

{$IFNDEF FPC}
type
  TLibHandle = THandle;
{$ENDIF}

// function LoadLibrary(fname: String): TLibHandle;
{
function GetProcAddress(Lib: TLibHandle, ProcName: String): Pointer;
}

implementation

uses
  unit_windows_api, unit_string;

(*
function GetProcAddress(Lib: TLibHandle, ProcName: String): Pointer;
begin
    {$IFDEF FPC}
    Result := GetProcedureAddress(Lib, ProcName);
    {$ELSE}
    {$ENDIF}
end;

function LoadLibrary(fname: String): TLibHandle;
begin
    {$IFDEF FPC}
    Result := SafeLoadLibrary(fname);
    {$ELSE}
    Result := LoadLibraryEx(PChar(fname), 0, 0);
    {$ENDIF}
end;
*)

procedure RunAsAdmin(hWnd: THandle; aFile: AnsiString; aParameters: AnsiString);
{$IFDEF Win32}
var
  sei: TShellExecuteInfoW;
  afile2: WideString;
  aparam: WideString;
begin
  afile2 := aFile;
  aparam := aParameters;
  ZeroMemory(@sei, SizeOf(sei));
  sei.cbSize := SizeOf(sei);
  sei.Wnd := hWnd;
  sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  sei.lpVerb := 'runas';
  sei.lpFile := PWideChar(afile2);
  sei.lpParameters := PWideChar(aParam);
  sei.nShow := SW_SHOWNORMAL;
  if not ShellExecuteExW(@sei) then
    raise Exception.Create('起動に失敗しました。(' + string(aFile) + ')');
end;
{$ELSE}
begin
    raise Exception.Create('Not Supported');
end;
{$ENDIF}

function ShortToLongFileName(ShortName: string):string;
var
  SearchRec: TSearchRec;
begin
  result:= '';
  // フルパス化
  ShortName:= ExpandFileName(ShortName);
  // 長い名前に変換（ディレクトリも）
  while LastDelimiter('\', ShortName) >= 3 do begin
    if FindFirst(ShortName, faAnyFile, SearchRec) = 0 then
      try
        result := '\' + SearchRec.Name + result;
      finally
        // 見つかったときだけ Close -> [Delphi-ML:17508] を参照
        FindClose(SearchRec);
      end
    else
      // ファイルが見つからなければそのまま
      result := '\' + ExtractFileName(ShortName) + result;
    ShortName := ExtractFilePath(ShortName);
    SetLength(ShortName, Length(ShortName)-1); // 最後の '\' を削除
  end;
  result := ShortName + result;
end;

function LongToShortFileName(LongName: string):string;
{$IFDEF Win32}
var
  tmp: string;
begin
  SetLength(tmp, MAX_PATH + 1);
  {$IFDEF UNICODE}
  GetShortPathNameW(PWideChar(LongName), PWideChar(tmp), MAX_PATH);
  Result := string(PWideChar(tmp));
  {$ELSE}
  GetShortPathName(PChar(LongName), PChar(tmp), MAX_PATH);
  Result := string(PChar(tmp));
  {$ENDIF}
end;
{$ELSE}
begin
    raise Exception.Create('Not Supported');
end;
{$ENDIF}

function getVolumeName(drive: string): string;
{$IFDEF Win32}
var
  {$IFDEF UNICODE}
  fi: SHFILEINFOW;
  {$ELSE}
  fi: SHFILEINFO;
  {$ENDIF}
begin
  if Length(drive) = 1 then drive := drive + ':\';
  //
  {$IFDEF UNICODE}
  SHGetFileInfoW(
    PWideChar(drive),
    0,
    fi,
    sizeof(SHFILEINFO),
    SHGFI_DISPLAYNAME);
  Result := string(fi.szDisplayName);
  {$ELSE}
  SHGetFileInfo(
    PAnsiChar(drive),
    0,
    fi,
    sizeof(SHFILEINFO),
    SHGFI_DISPLAYNAME);
  Result := string(fi.szDisplayName);
  {$ENDIF}
end;
{$ELSE}
begin
  raise Exception.Create('Not Supported');
end;
{$ENDIF}

function getFileSystemName(drive: string): string;
{$IFDEF Win32}
{$IFDEF UNICODE}
var
	SystemName: array [0..1000] of WideChar;
	SerialNumber: DWORD;
	FileNameLength: DWORD;
  Flags: DWORD;
begin
  if Length(drive) = 1 then drive := drive + ':\';
  //
	GetVolumeInformationW(
		PWideChar(drive),
    nil,
		0,
		@SerialNumber,
		FileNameLength,
		Flags,
		@SystemName[0],
		1000);
  //
  Result := string(PWideChar(@SystemName[0]));
end;
{$ELSE}
var
	SystemName: array [0..1000] of AnsiChar;
	SerialNumber: DWORD;
	FileNameLength: DWORD;
  Flags: DWORD;
begin
  if Length(drive) = 1 then drive := drive + ':\';
  //
	GetVolumeInformation(
		PAnsiChar(drive),
    nil,
		0,
		@SerialNumber,
		FileNameLength,
		Flags,
		@SystemName[0],
		1000);
  //
  Result := string(PAnsiChar(@SystemName[0]));
end;
{$ENDIF}
{$ELSE}
begin
  raise Exception.Create('Not Supported');
end;
{$ENDIF}

function getSerialNo(drive: AnsiString): DWORD;
{$IFDEF Win32}
var
	SerialNumber: DWORD;
	FileNameLength: DWORD;
  Flags: DWORD;
begin
  if Length(drive) = 1 then drive := drive + ':\';
  //
	GetVolumeInformationA(
		PAnsiChar(drive),
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
{$ELSE}
begin
  raise Exception.Create('Not Supported');
end;
{$ENDIF}

function getMainWindowHandle: THandle;
{$IFDEF Win32}
begin
  if MainWindowHandle = 0 then
  begin
    MainWindowHandle := GetForegroundWindow;
  end;

  Result := MainWindowHandle;
end;
{$ELSE}
begin
  // raise Exception.Create('Not Supported');
  Result := 0;
end;
{$ENDIF}


// ファイルタイムをローカルなTTimeDateに変換する
function FileTimeToDateTimeEx(const ft:TFileTime):TDateTime;
{$IFDEF Win32}
var lt:TFileTime; st:TSystemTime;
begin
  // 2ちゃんの「こんな関数作ったよ。 」スレより。27 ：デフォルトの名無しさん ：02/10/15 19:24 より
  FileTimeToLocalFileTime(ft,lt);
  FileTimeToSystemTime(lt,st);
  Result:=SystemTimeToDateTime(st);
end;
{$ELSE}
begin
  raise Exception.Create('Not Supported');
end;
{$ENDIF}

//TDateTimeからファイル日時を得る
function DateTimeToFileTimeEx(dt: TDateTime):TFileTime;
{$IFDEF Win32}
var ft:TFileTime; st:TSystemTime;
begin
  DateTimeToSystemTime(dt, st);
  SystemTimeToFileTime(st, ft);
  LocalFileTimeToFileTime(ft, Result);
end;
{$ELSE}
begin
  raise Exception.Create('Not Supported');
end;
{$ENDIF}

//ファイルの作成・更新・最終書込日時を得る
function GetFileTimeEx(fname:string; var tCreation, tLastAccess, tLastWrite:TDateTime):boolean;
{$IFDEF Win32}
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
{$ELSE}
begin
  raise Exception.Create('Not Supported');
end;
{$ENDIF}

// 一括でファイル日時を変更する
function SetFileTimeEx(fname:string; tCreation, tLastAccess, tLastWrite: TDateTime): Boolean;
{$IFDEF Win32}
var
  fCreation, fLastAccess, fLastWrite: TFileTime;
  hFile: THandle;
begin
  // 日時の変換
  fCreation   := DateTimeToFileTimeEx(tCreation   );
  fLastAccess := DateTimeToFileTimeEx(tLastAccess );
  fLastWrite  := DateTimeToFileTimeEx(tLastWrite  );

  // 日時の変更
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
{$ELSE}
begin
  raise Exception.Create('Not Supported');
end;
{$ENDIF}

{$IFDEF Win32}
// 文字列にファイルの内容を全部開く
function FileLoadAll(Filename: AnsiString): AnsiString;
var
  f: THandle;
  size, rsize: DWORD;
begin
  // open
  f := CreateFileA(PAnsiChar(Filename), GENERIC_READ, FILE_SHARE_READ, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN,0);
  if f = INVALID_HANDLE_VALUE then
    raise EInOutError.Create(
      string('ファイル"' + Filename + '"が開けません。') + GetLastErrorStr);
  try
    // set pointer
    SetFilePointer(f, 0, nil, FILE_BEGIN); // 初めからゼロの位置に

    // read
    size := GetFileSize(f, nil); // 4G 以下限定
    SetLength(Result, size);
    if not ReadFile(f, Result[1], size, rsize, nil) then
    begin // 失敗
      raise EInOutError.Create(
        string('ファイル"' + Filename + '"の読み取りに失敗しました。') + GetLastErrorStr);
    end;
  finally
    // close
    CloseHandle(f);
  end;
end;

// 文字列にファイルの内容を全部書き込む
procedure FileSaveAll(s, Filename: AnsiString);
var
  f: THandle;
  size, rsize: DWORD;
begin
  // open
  f := CreateFileA(PAnsiChar(Filename), GENERIC_WRITE, 0, nil,
    CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN,0);
  if f = INVALID_HANDLE_VALUE then
  begin
    CloseHandle(f);
    raise EInOutError.Create(string('ファイル"' + Filename + '"が開けません。') + GetLastErrorStr);
  end;
  try
    // set pointer
    SetFilePointer(f, 0, nil, FILE_BEGIN); // 初めからゼロの位置に

    // write
    size := Length(s);
    if size > 0 then
    begin
      if not WriteFile(f, s[1], size, rsize, nil) then
      begin // 失敗
        Closehandle(f); f := 0;
        raise EInOutError.Create(string('ファイル"' + Filename + '"の読み取りに失敗しました。') + GetLastErrorStr);
      end;
    end;
  finally
    // close
    CloseHandle(f);
  end;
end;
{$ENDIF}


{$IFDEF Win32}
function SHFileCopy(const Source, Dest, Title: AnsiString): Boolean;
var
  foStruct: TSHFileOpStructA;
  s_src, s_des: AnsiString;
begin
  Result := False;
  if (Source='')or(Dest='') then Exit;

  s_src := Source + #0#0;
  s_des := Dest   + #0#0;

  with foStruct do
  begin
    wnd    := getMainWindowHandle;
    wFunc  := FO_COPY;            //フラグ（コピーの場合はFO_COPY）
    pFrom  := PAnsiChar(s_src);
    pTo    := PAnsiChar(s_des);
    fFlags := FOF_MULTIDESTFILES or FOF_NOCONFIRMATION or FOF_NOCONFIRMMKDIR{orFOF_NOERRORUI};
    fAnyOperationsAborted := False;          // 処理が中断された場合 FALSE が返る
    hNameMappings         := nil;            // 処理前後のファイル
    lpszProgressTitle     := PAnsiChar(Title);   // ダイアログのタイトル
  end;
  Result := (SHFileOperationA(foStruct) = 0);
end;

function SHFileDelete(const Source: AnsiString): Boolean;
var
  foStruct: TSHFileOpStructA;
begin
  ZeroMemory(@foStruct, sizeof(foStruct));
  with foStruct do
  begin
    wnd    := getMainWindowHandle;//Application.Handle;
    wFunc  := FO_DELETE;  //フラグ（コピーの場合はFO_COPY）
    pFrom  := PAnsiChar(Source + #0#0);  //するフォルダ
    fFlags := FOF_NOCONFIRMATION or FOF_ALLOWUNDO;  //ダイアログ非表示
  end;
  Result := (SHFileOperationA(foStruct)=0);
end;

function SHFileDeleteComplete(const Source: AnsiString): Boolean;
var
  foStruct: TSHFileOpStructA;
begin
  with foStruct do
  begin
    wnd    := getMainWindowHandle;//Application.Handle;
    wFunc  := FO_DELETE;  //フラグ（コピーの場合はFO_COPY）
    pFrom  := PAnsiChar(Source + #0#0);  //するフォルダ
    pTo    := Nil; // 必要
    fFlags := FOF_NOCONFIRMATION or FOF_MULTIDESTFILES or FOF_NOERRORUI;  //ダイアログ非表示
    fAnyOperationsAborted := False;
    hNameMappings         := nil;
    lpszProgressTitle     := nil;
  end;
  Result := (SHFileOperationA(foStruct)=0);
end;

function SHFileMove(const Source, Dest: AnsiString): Boolean;
var
  foStruct: TSHFileOpStructA;
begin
  with foStruct do
  begin
    wnd       :=  getMainWindowHandle;//Application.Handle;
    wFunc     :=  FO_MOVE;  //フラグ（コピーの場合はFO_COPY）
    pFrom     :=  PAnsiChar(Source + #0#0);  //するフォルダ
    pTo       :=  PAnsiChar(Dest   + #0#0);
    fFlags    :=  FOF_NOCONFIRMATION or FOF_ALLOWUNDO or FOF_NOERRORUI;  //ダイアログ非表示
    fAnyOperationsAborted := False;
    hNameMappings         := nil;
    lpszProgressTitle     := nil;
  end;
  Result := (SHFileOperationA(foStruct)=0);
end;

function SHFileRename(const Source, Dest: AnsiString): Boolean;
begin
  Result := SHFileMove(Source, Dest);
end;

{$ELSE}
function SHFileCopy(const Source, Dest, Title: AnsiString): Boolean;
begin
  raise Exception.Create('Not Supported');
end;
function SHFileDelete(const Source: AnsiString): Boolean;
begin
  raise Exception.Create('Not Supported');
end;
function SHFileDeleteComplete(const Source: AnsiString): Boolean;
begin
  raise Exception.Create('Not Supported');
end;
function SHFileMove(const Source, Dest: AnsiString): Boolean;
begin
  raise Exception.Create('Not Supported');
end;
function SHFileRename(const Source, Dest: AnsiString): Boolean;
begin
  raise Exception.Create('Not Supported');
end;
{$ENDIF}


function EnumFiles(path: string): TStringList;
var
  rec: TSearchRec;
  basePath: string;
  s: string;

  procedure _enum(path: string);
  begin
    // ファイルの検索
    if FindFirst(string(path), FaAnyFile, rec) = 0 then
    begin
      repeat
        if not ((rec.Attr and FaDirectory) > 0) then
        begin
          Result.Add(rec.Name);
        end;
      until FindNext(rec) <> 0;
      FindClose(rec);
    end;
  end;

begin
  Result := TStringList.Create;

  // path がフォルダか？
  if DirectoryExists(string(path)) then
  begin
    path := CheckPathYen(path);
  end;

  // 基本パスの抜き出し
  basePath := (ExtractFilePath(string(path)));
  if basePath <> '' then
  begin
    System.Delete(path, 1, Length(basePath));
  end;

  // 拡張子が;で区切られているので;までを切り出してそれぞれ列挙
  while True do
  begin
    s := getToken_s(path, ';');

    // パスが記述されてなければ basePath を足す
    if Pos(':\', s) = 0 then s := basePath + s;

    // フォルダのみの指定ならば ワイルドカードを足す
    if Copy(s, Length(s), 1) = '\' then s := s + '*';

    _enum(s);

    if path = '' then Break;
  end;

end;

function EnumAllFiles(path: string): TStringList; overload;
var
  temp: string;
begin
  Result := EnumAllFiles(path, temp);
end;

/// 全ファイル列挙、引数 path には、基本となるパスを返す
function EnumAllFiles(path: string; out basePath: string): TStringList; overload;
{$IFDEF Win32}
var
  s: string;
  hmain: THandle;
  smain: string;

  procedure _enum(path: string);
  var
    base, ext, s, title: string;
    dirs: TStringList;
    files: TStringList;
    i: Integer;
  begin
    // 基本パスを取得
    base := ExtractFilePath(path); base := CheckPathYen(base);
    ext  := ExtractFileName(path);

    if hmain > 0 then
    begin
      title := 'パス検索中:' + base;
      SetWindowText(hmain, PChar(title));
    end;

    // ファイルを列挙
    files := EnumFiles(path);
    for i := 0 to files.Count - 1 do
    begin
      Result.Add(base + files.Strings[i]); // パスを追加して結果に足す
    end;
    files.Free;

    // フォルダを列挙
    dirs := EnumDirs(base+'*');
    for i := 0 to dirs.Count - 1 do
    begin
      s := base + dirs.Strings[i] + '\' + ext;
      _enum(s); // 再帰的に検索
    end;
    dirs.Free;
  end;

begin
  Result := TStringList.Create;

  // path がフォルダか？
  if DirectoryExists(path) then
  begin
    path := CheckPathYen(path);
  end;

  // 基本パスの抜き出し
  basePath := ExtractFilePath(path);
  if basePath = '' then
  begin
    // path にはフィルタのみ記述されているので
    // basePathにカレントフォルダを指定
    basePath := GetCurrentDir;
    basePath := CheckPathYen(basePath);
  end else
  begin
    // 検索文字列 path から基本となるパス部分を除く
    if basePath <> '' then System.Delete(path, 1, Length(basePath));
  end;

  hmain := MainWindowHandle;
  if hmain > 0 then
  begin
    SetLength(smain, 1024);
    GetWindowText(hmain, PChar(smain), 1023);
  end;

  // 拡張子が;で区切られているので;までを切り出してそれぞれ列挙
  while True do
  begin
    s := getToken_s(path, ';');

    // パスが記述されてなければ basePath を足す
    if Pos(':\', s) = 0 then s := basePath + s;

    // フォルダのみの指定ならば ワイルドカードを足す
    if Copy(s, Length(s), 1) = '\' then s := s + '*';

    _enum(s);

    if path = '' then Break;
  end;

  if hmain > 0 then
  begin
    SetWindowText(hmain, PChar(smain));
  end;

end;
{$ELSE}
begin
  raise Exception.Create('Not Supported');
end;
{$ENDIF}


function EnumAllDirs(path: string): TStringList;
{$IFDEF Win32}
var
  hmain: THandle;
  smain: string;

  procedure _enum(path: string);
  var
    title: string;
    dirs: TStringList;
    base, f, n: string;
    i: Integer;
  begin
    base := ExtractFilePath(path);
    f    := ExtractFileName(path);
    if hmain > 0 then
    begin
      title := '検索中:' + path;
      SetWindowText(hmain, PChar(title));
    end;

    // フォルダを列挙
    dirs := EnumDirs(path);
    for i := 0 to dirs.Count - 1 do
    begin
      n := base + dirs.Strings[i] + '\';
      Result.Add(n);
      _enum(n + '*');
    end;
    dirs.Free;
  end;

begin
  Result := TStringList.Create;

  // path がフォルダか？
  if DirectoryExists(path) then
  begin
    path := CheckPathYen(path);
    Result.Add(path);
  end else
  begin
    Exit;
  end;

  hmain := MainWindowHandle;
  if hmain > 0 then
  begin
    SetLength(smain, 1024);
    GetWindowText(hmain, PChar(smain), 1023);
  end;

  _enum(path+'*');

  if hmain > 0 then
  begin
    SetWindowText(hmain, PChar(smain));
  end;

end;
{$ELSE}
begin
  raise Exception.Create('Not Supported');
end;
{$ENDIF}


function EnumDirs(const path: string): TStringList;
{$IFDEF Win32}
var
  rec: TSearchRec;
  s: string;
begin
  Result := TStringList.Create;
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
{$ELSE}
begin
  raise Exception.Create('Not Supported');
end;
{$ENDIF}


function CreateShortCut(SavePath, TargetApp, Arg, WorkDir: AnsiString; State: TWindowState2): Boolean;
{$IFDEF Win32}
var
  IU: IUnknown;
  W: PWideChar;
const
  ShowCmd: array[TWindowState2] of Integer =
    (SW_SHOWNORMAL, SW_MINIMIZE, SW_MAXIMIZE);
begin
  Result := False;
  try
    IU := CreateComObject(CLSID_ShellLink);
    with IU as IShellLinkA do begin
      if SetPath(PAnsiChar(TargetApp)) <> NOERROR then Abort;
      if SetArguments(PAnsiChar(Arg)) <> NOERROR then Abort;
      if SetWorkingDirectory(PAnsiChar(WorkDir)) <> NOERROR then Abort;
      if SetShowCmd(ShowCmd[State]) <> NOERROR then Abort
    end;
    W := PWChar(WideString(SavePath));
    if (IU as IPersistFile).Save(W, False) <> S_OK then Abort;
    Result := True
  except
  end
end;
{$ELSE}
begin
  raise Exception.Create('Not Supported');
end;
{$ENDIF}

{$IFDEF Win32}
function CreateShortCutEx(SavePath, TargetApp, Arg, WorkDir, IconPath: AnsiString;
    IconNo:Integer;Comment: AnsiString;Hotkey:Word; State: TWindowState2): Boolean;
var
  IU: IUnknown;
  W: PWideChar;
const
  ShowCmd: array[TWindowState2] of Integer =
    (SW_SHOWNORMAL, SW_MINIMIZE, SW_MAXIMIZE);
begin
  Result := False;
  try
    IU := CreateComObject(CLSID_ShellLink);
    with IU as IShellLinkA do begin
      if SetPath(PAnsiChar(TargetApp)) <> NOERROR then Abort;
      if SetArguments(PAnsiChar(Arg)) <> NOERROR then Abort;
      if SetWorkingDirectory(PAnsiChar(WorkDir)) <> NOERROR then Abort;
      if (IconPath <> '') and (SetIconLocation(PAnsiChar(IconPath),IconNo) <> NOERROR) then Abort;
      if (HotKey <> 0) and (SetHotkey(Hotkey) <> NOERROR) then Abort;
      if SetDescription(PAnsiChar(Comment)) <> NOERROR then Abort;
      if SetShowCmd(ShowCmd[State]) <> NOERROR then Abort
    end;
    W := PWChar(WideString(SavePath));
    if (IU as IPersistFile).Save(W, False) <> S_OK then Abort;
    Result := True
  except
  end
end;

function GetShortCutLink(Path : AnsiString): AnsiString;
var
  IU: IUnknown;
  IP: IPersistFile;
  buf: AnsiString;
  fd:_WIN32_FIND_DATAA;
begin
  Result := '';
  SetLength(buf,260);
  try
    IU := CreateComObject(CLSID_ShellLink);
    with IU as IShellLinkA do begin
      if QueryInterface(IPersistFile,IP) <> NOERROR then Abort;
      if IP.Load(PWChar(WideString(Path)),STGM_READWRITE) <> NOERROR then Abort;
      if GetPath(PAnsiChar(buf),260,fd,0) <> NOERROR then Abort;
    end;
    Result := PAnsiChar(buf);
  except
  end
end;
{$ENDIF}

end.
