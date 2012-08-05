{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_LIBRARY ON}
{$WARN SYMBOL_PLATFORM ON}
{$IFDEF VER150}
{$ELSE}
{WARN SYMBOL_EXPERIMENTAL ON}
{$WARN UNIT_LIBRARY ON}
{$WARN UNIT_PLATFORM ON}
{$WARN UNIT_DEPRECATED ON}
{WARN UNIT_EXPERIMENTAL ON}
{$ENDIF}
(*{$WARN HRESULT_COMPAT ON}
{$WARN HIDING_MEMBER ON}
{$WARN HIDDEN_VIRTUAL ON}
{$WARN GARBAGE ON}
{$WARN BOUNDS_ERROR ON}
{$WARN ZERO_NIL_COMPAT ON}
{$WARN STRING_CONST_TRUNCED ON}
{$WARN FOR_LOOP_VAR_VARPAR ON}
{$WARN TYPED_CONST_VARPAR ON}
{$WARN ASG_TO_TYPED_CONST ON}
{$WARN CASE_LABEL_RANGE ON}
{$WARN FOR_VARIABLE ON}
{$WARN CONSTRUCTING_ABSTRACT ON}
{$WARN COMPARISON_FALSE ON}
{$WARN COMPARISON_TRUE ON}
{$WARN COMPARING_SIGNED_UNSIGNED ON}
{$WARN COMBINING_SIGNED_UNSIGNED ON}
{$WARN UNSUPPORTED_CONSTRUCT ON}
{$WARN FILE_OPEN ON}
{$WARN FILE_OPEN_UNITSRC ON}
{$WARN BAD_GLOBAL_SYMBOL ON}
{$WARN DUPLICATE_CTOR_DTOR ON}
{$WARN INVALID_DIRECTIVE ON}
{$WARN PACKAGE_NO_LINK ON}
{$WARN PACKAGED_THREADVAR ON}
{$WARN IMPLICIT_IMPORT ON}
{$WARN HPPEMIT_IGNORED ON}
{$WARN NO_RETVAL ON}
{$WARN USE_BEFORE_DEF ON}
{$WARN FOR_LOOP_VAR_UNDEF ON}
{$WARN UNIT_NAME_MISMATCH ON}
{$WARN NO_CFG_FILE_FOUND ON}
{$WARN IMPLICIT_VARIANTS ON}
{$WARN UNICODE_TO_LOCALE ON}
{$WARN LOCALE_TO_UNICODE ON}
{$WARN IMAGEBASE_MULTIPLE ON}
{$WARN SUSPICIOUS_TYPECAST ON}
{$WARN PRIVATE_PROPACCESSOR ON}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}
{$IFDEF VER150}
{$ELSE}
{$WARN OPTION_TRUNCATED ON}
{$WARN WIDECHAR_REDUCED ON}
{$WARN DUPLICATES_IGNORED ON}
{$WARN UNIT_INIT_SEQ ON}
{$WARN LOCAL_PINVOKE ON}
{$ENDIF}
{$WARN MESSAGE_DIRECTIVE ON}
*)



unit unit_file;
//------------------------------------------------------------------------------
// ファイル入出力に関する汎用的なユニット
// [作成] クジラ飛行机
// [連絡] http://kujirahand.com/
// [日付] 2004/07/28
//
interface

uses
  Windows, SysUtils, Classes, hima_types, ShellApi, comobj, shlobj, activex;

type
  TWindowState2 = (ws2Normal, ws2Minimized, ws2Maximized);




// 文字列にファイルの内容を全部開く
function FileLoadAll(Filename: AnsiString): AnsiString;

// 文字列にファイルの内容を全部書き込む
procedure FileSaveAll(s, Filename: AnsiString);

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
function CreateShortCut(SavePath, TargetApp, Arg, WorkDir: AnsiString; State: TWindowState2): Boolean;
function CreateShortCutEx(SavePath, TargetApp, Arg, WorkDir, IconPath: AnsiString;
    IconNo:Integer;Comment: AnsiString;Hotkey:Word; State: TWindowState2): Boolean;
function GetShortCutLink(Path : AnsiString): AnsiString;

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

implementation

uses
  unit_windows_api, unit_string;


procedure RunAsAdmin(hWnd: THandle; aFile: AnsiString; aParameters: AnsiString);
var
  sei: TShellExecuteInfoA;
begin
  ZeroMemory(@sei, SizeOf(sei));
  sei.cbSize := SizeOf(sei);
  sei.Wnd := hWnd;
  sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  sei.lpVerb := 'runas';
  sei.lpFile := PAnsiChar(aFile);
  sei.lpParameters := PAnsiChar(aParameters);
  sei.nShow := SW_SHOWNORMAL;
  if not ShellExecuteEx(@sei) then
    raise Exception.Create('起動に失敗しました。(' + string(aFile) + ')');
end;

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

function getVolumeName(drive: string): string;
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

function getFileSystemName(drive: string): string;
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

function getSerialNo(drive: AnsiString): DWORD;
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

function getMainWindowHandle: THandle;
begin
  if MainWindowHandle = 0 then
  begin
    MainWindowHandle := GetForegroundWindow;
  end;

  Result := MainWindowHandle;
end;


// ファイルタイムをローカルなTTimeDateに変換する
function FileTimeToDateTimeEx(const ft:TFileTime):TDateTime;
var lt:TFileTime; st:TSystemTime;
begin
  // 2ちゃんの「こんな関数作ったよ。 」スレより。27 ：デフォルトの名無しさん ：02/10/15 19:24 より
  FileTimeToLocalFileTime(ft,lt);
  FileTimeToSystemTime(lt,st);
  Result:=SystemTimeToDateTime(st);
end;

//TDateTimeからファイル日時を得る
function DateTimeToFileTimeEx(dt: TDateTime):TFileTime;
var ft:TFileTime; st:TSystemTime;
begin
  DateTimeToSystemTime(dt, st);
  SystemTimeToFileTime(st, ft);
  LocalFileTimeToFileTime(ft, Result);
end;


//ファイルの作成・更新・最終書込日時を得る
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

// 一括でファイル日時を変更する
function SetFileTimeEx(fname:string; tCreation, tLastAccess, tLastWrite: TDateTime): Boolean;
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
    raise EInOutError.Create(string('ファイル"' + Filename + '"が開けません。') + GetLastErrorStr);
  try
    // set pointer
    SetFilePointer(f, 0, nil, FILE_BEGIN); // 初めからゼロの位置に

    // write
    size := Length(s);
    if size > 0 then
    begin
      if not WriteFile(f, s[1], size, rsize, nil) then
      begin // 失敗
        raise EInOutError.Create(string('ファイル"' + Filename + '"の読み取りに失敗しました。') + GetLastErrorStr);
      end;
    end;
  finally
    // close
    CloseHandle(f);
  end;
end;


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
        if not ((rec.Attr and FaDirectory)>0) then
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

function EnumAllDirs(path: string): TStringList;
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


function EnumDirs(const path: string): TStringList;
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

function CreateShortCut(SavePath, TargetApp, Arg, WorkDir: AnsiString; State: TWindowState2): Boolean;
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

end.
