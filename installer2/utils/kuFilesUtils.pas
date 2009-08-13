{**
 * ファイルの列挙や属性の取得などを行うファイルに関する処理をまとめたもの
 * @author  kujirahand.com
 * @version 2009/04/11
 *}

unit kuFilesUtils;

interface

uses
  Windows, SysUtils, Classes, ShlObj, ShellApi, masks;

{$IF RTLVersion < 20}
type RawByteString = AnsiString;
type TEncoding = string;
{$IFEND}

type
  TFileGlobOption = (fgAll, fgDir, fgFile);
  TFildEnumOnProgress = procedure (Dir: string; Level: Integer; var FlagHalt:Boolean);
  TFileOnWalk = procedure (basepath: string; rec: TSearchRec);

  TKFiles = class
  public
    OnWalk: TFileOnWalk; // Glob, EnumAll
    OnProgress: TFildEnumOnProgress; // EnumAll
    function Glob(pattern: string; option: TFileGlobOption = fgAll): TStringList;
    function EnumAll(path: string; pattern: string; MaxLevel: Integer = -1;
      IncludeBasePath: Boolean = True): TStringList;
    function GetDirveList: TStringList;
    function GetDriveTypeStr(drive: string): string;
    function GetDriveTypeInt(drive: string): UINT;
    function GetLogicalDriversStr: string;
    function GetLogicalDrive(drive: string): Boolean;
  end;

  TKFile = class
  public
    function LoadAllAsBin(filename: string): RawByteString;
    function LoadAll(filename: string; Enc: TEncoding): string;
    procedure SaveAll(txt: string; filename: string; Enc: TEncoding);
    function FileAge(filename: string): TDateTime;
    function FileSize(filename: string): Cardinal;
    procedure OpenApp(fname, cmd: string; ShowWindow: Word = SW_SHOW);
    procedure RunAndWait(cmd: string; ShowWindow: Word = SW_SHOW);
    procedure RunAs(fname, cmd: string; IsWait: Boolean = False; Handle: HWND = 0);
  end;

function KFiles: TKFiles;
function KFile: TKFile;


// Check Filter "*.jpg;*.jpeg;*.jpe"
function MatchesMaskEx(filename: string; masks: string): Boolean;
function GetTokenStr(var str: string; splitter: string): string;

implementation

uses
  kuPathUtils, kuBenri;

var
  _files: TKFiles = nil;
  _file: TKFile = nil;

function GetTokenStr(var str: string; splitter: string): string;
var
  i: Integer;
begin
  i := Pos(splitter, str);
  if i = 0 then
  begin
    Result := str;
    str := '';
    Exit;
  end;
  Result := Copy(str, 1, i - 1);
  System.Delete(str, i, Length(splitter));
end;

function MatchesMaskEx(filename: string; masks: string): Boolean;
var
  s, pat: string;
begin
  Result := False;
  pat := masks;
  while pat <> '' do
  begin
    s := GetTokenStr(pat, ';');
    if not MatchesMask(filename, s) then Continue;
    Result := True;
    Break;
  end;
end;

{**
 * TKFile(ファイルユーティリティ)に関する機能を手軽に使える用にするためのもの
 *}
function KFile: TKFile;
begin
  if _file = nil then
  begin
    _file := TKFile.Create;
  end;
  Result := _File;
end;

{**
 * TKFilesに関する機能を手軽に使える用にするためのもの
 *}
function KFiles: TKFiles;
begin
  if _files = nil then
  begin
    _files := TKFiles.Create;
  end;
  Result := _files;
end;

{**
 * ファイルの一覧(サブフォルダを含む)を取得します
 * @param path      検索パス
 * @param pattern   検索パターン
 * @param MaxLevel  何レベル以下の階層まで調べるか
 * @return          ファイルの一覧
 * OnWork や OnProgress を設定すると、検索中に経過報告を実行できます
 *}
function TKFiles.EnumAll(path: string; pattern: string; MaxLevel: Integer; IncludeBasePath: Boolean): TStringList;
var
  base: string;
  FlagHalt: Boolean;

  procedure _enum(dir: string; level: Integer);
  var
    files, dirs: TStringList;
    full, s: string;
    i: Integer;
  begin
    // Check Max Level
    if (MaxLevel >= 0) and (MaxLevel < level) then Exit;
    if FlagHalt then Exit;

    full := base + dir;

    if Assigned(OnProgress) then
    begin
      OnProgress(full, level, FlagHalt);
      if FlagHalt then Exit;
    end;

    // add files
    files := Glob(full + pattern, fgFile);
    try
      for i := 0 to files.Count - 1 do
      begin
        if IncludeBasePath then
        begin
          Result.Add(full + files.Strings[i]);
        end else
        begin
          Result.Add(dir + files.Strings[i]);
        end;
      end;
    finally
      FreeAndNil(files);
    end;
    // add sub directory
    dirs := Glob(full + '*', fgDir);
    try
      for i := 0 to dirs.Count - 1 do
      begin
        s := dirs.Strings[i];
        _enum(dir + s + '\', level + 1);
      end;
    finally
      FreeAndNil(dirs);
    end;
  end;

begin
  Result := TStringList.Create;
  FlagHalt := False;
  base := IncludeTrailingPathDelimiter(path);
  _enum('', 0);
end;

{**
 * ファイルの一覧(サブフォルダを含まない)を検索して返す
 * @params  pattern   ファイルのパターン
 * @return            ファイルの一覧
 *}
function TKFiles.GetDirveList: TStringList;
var
  bufsize: DWORD;
  buf: string;
  i: Integer;
begin
  bufsize := GetLogicalDriveStrings(0, nil);
  SetLength(buf, bufsize);
  GetLogicalDriveStrings(bufsize, @buf[1]);
  for i := 1 to Length(buf) do
    if buf[i] = #0 then buf[i] := #13;
  buf := Trim(StringReplace(buf, #13, #13#10, [rfReplaceAll]));
  //
  Result := TStringList.Create;
  Result.Text := buf;
end;

{** Check Drive Type
 *@param  drive   'C:\' のようなドライブ文字列
 *}
function TKFiles.GetDriveTypeInt(drive: string): UINT;
begin
  Result := Windows.GetDriveType(PChar(drive));
  // DRIVE_UNKNOWN | DRIVE_REMOVABLE | DRIVE_CDROM | ..
end;

function TKFiles.GetDriveTypeStr(drive: string): string;
var
  u: UINT;
  r: string;
begin
  // 不明|存在しない|取り外し可能|固定|ネットワーク|CD-ROM|RAM
  u := Windows.GetDriveType(PChar(drive));
  case u of
    DRIVE_UNKNOWN     : r := '不明';
    DRIVE_NO_ROOT_DIR : r := '存在しない';
    DRIVE_REMOVABLE   : r := '取り外し可能';
    DRIVE_FIXED       : r := '固定';
    DRIVE_REMOTE      : r := 'ネットワーク';
    DRIVE_CDROM       : r := 'CD-ROM';
    DRIVE_RAMDISK     : r := 'RAM';
    else                r := '';
  end;

  Result := r;
end;

function TKFiles.GetLogicalDrive(drive: string): Boolean;
begin
  Result := False;
  if drive = '' then Exit;
  drive := UpperCase(drive);
  drive := drive[1];
  Result := (0 < Pos(drive, GetLogicalDriversStr));
end;

function TKFiles.GetLogicalDriversStr: string;
var
  i: Integer;
  bits: DWORD;
begin
  Result := '';
  bits := GetLogicalDrives;
  for i := 0 to 25 do
  begin
    if (bits and (1 shl i)) <> 0 then
    begin
      Result := Result + Chr(Ord('A') + i);
    end;
  end;
end;

function TKFiles.Glob(pattern: string; option: TFileGlobOption): TStringList;
var
  rec: TSearchRec;
  base: string;
  res: Integer;
begin
  if DirectoryExists(pattern) then
  begin
    pattern := IncludeTrailingPathDelimiter(pattern) + '*';
  end;
  base := ExtractFilePath(pattern);
  Result := TStringList.Create;

  res := FindFirst(pattern, faAnyFile, rec);
  try
    if 0 <> res then
    begin
      Exit; // FILE NOT FOUND
    end;
    // -------------------------------------------
    if option = fgAll then
    begin
      repeat
        if (rec.Name = '.')or(rec.Name = '..') then Continue;
        if Assigned(OnWalk) then OnWalk(base, rec);
        Result.Add(rec.Name);
      until (0 <> FindNext(rec));
    end else
    // -------------------------------------------
    if option = fgFile then
    begin
      repeat
        if (rec.Name = '.')or(rec.Name = '..') then Continue;
        if rec.Attr <> faDirectory  then
        begin
          if Assigned(OnWalk) then OnWalk(base, rec);
          Result.Add(rec.Name);
        end;
      until (0 <> FindNext(rec));
    end else
    // -------------------------------------------
    if option = fgDir then
    begin
      repeat
        if (rec.Name = '.')or(rec.Name = '..') then Continue;
        if rec.Attr = faDirectory  then
        begin
          Result.Add(rec.Name);
        end;
      until (0 <> FindNext(rec));
    end;
  finally
    FindClose(rec);
  end;
end;

{ TKFile }

{**
 * ファイルの日付を取得する
 * @param fileanem  ファイル名
 * @return ファイルの日付
 *}
function TKFile.FileAge(filename: string): TDateTime;
var
  rec: TSearchRec;
begin
  Result := 0;
  if FindFirst(filename, faAnyFile, rec) = 0 then
  begin
    Result := FileDateToDateTime(rec.Time);
  end;
  FindClose(rec);
end;

function TKFile.FileSize(filename: string): Cardinal;
var
  f: TFileStream;
begin
  f := TFileStream.Create(filename, fmOpenRead);
  try
      Result := f.Size;
  finally
    FreeAndNil(f);
  end;
end;

function TKFile.LoadAll(filename: string; Enc: TEncoding): string;
var
  s: TStringList;
begin
  s := TStringList.Create;
  try
    {$IF RTLVersion < 20}
    s.LoadFromFile(filename);
    {$ELSE}
    s.LoadFromFile(filename, Enc);
    {$IFEND}
    Result := s.Text;
  finally
    s.Free;
  end;
end;

function TKFile.LoadAllAsBin(filename: string): RawByteString;
var
  m: TMemoryStream;
begin
  m := TMemoryStream.Create;
  try
    m.LoadFromFile(filename);
    SetLength(Result, m.Size);
    m.Position := 0;
    m.Read(Result[1], m.Size);
  finally
    m.Free;
  end;
end;

procedure TKFile.OpenApp(fname, cmd: string; ShowWindow: Word);
begin
  {$IF RTLVersion < 20}
  ShellExecute(0, 'open', PChar(fname), PChar(cmd), nil, ShowWindow);
  {$ELSE}
  ShellExecute(0, 'open', PWideChar(fname), PWideChar(cmd), nil, ShowWindow);
  {$IFEND}
end;

procedure TKFile.RunAndWait(cmd: string; ShowWindow: Word);
var
  pi: TProcessInformation;
  si: TStartupInfo;
  ret: Boolean;
begin
  ZeroMemory(@si, SizeOf(si));
  si.cb := SizeOf(si);
  si.wShowWindow := ShowWindow;
  si.dwFlags := STARTF_USESHOWWINDOW;
  UniqueString(cmd);
  {$IF RTLVersion < 20}
  ret := CreateProcess(nil, PChar(cmd), nil, nil, False,
    CREATE_DEFAULT_ERROR_MODE, nil, nil, si, pi);
  {$ELSE}
  ret := CreateProcess(nil, PWideChar(cmd), nil, nil, False,
    CREATE_DEFAULT_ERROR_MODE, nil, nil, si, pi);
  {$IFEND}
  if not ret then begin
    raise Exception.Create('Could not run: ' + cmd + ':' + GetLastErrorStr(GetLastError));
  end;
  // 実行終了まで待機
  try
    WaitForSingleObject(pi.hProcess, INFINITE);
  finally
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
  end;
end;


procedure TKFile.RunAs(fname, cmd: string; IsWait: Boolean; Handle: HWND);
var
  isVista: Boolean;
  sei: TShellExecuteInfo;
  VerInfo: TOSVersionInfo;
begin
  // Vistaか調べる
  VerInfo.dwOSVersionInfoSize := SizeOf(VerInfo);
  GetVersionEx(VerInfo);
  isVista := (VerInfo.dwMajorVersion >= 6);
  ZeroMemory(@sei, SizeOf(sei));
  sei.cbSize := SizeOf(sei);
  sei.Wnd := Handle;
  sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  if isVista then
    sei.lpVerb := 'runas'
  else
    sei.lpVerb := 'open';
  //
  if fname = '' then  sei.lpFile := nil
                {$IF RTLVersion < 20}
                else  sei.lpFile := PChar(fname);
                {$ELSE}
                else  sei.lpFile := PWideChar(fname);
                {$IFEND}
  if cmd = ''   then sei.lpParameters := nil
                {$IF RTLVersion < 20}
                else sei.lpParameters := PChar(cmd);
                {$ELSE}
                else sei.lpParameters := PWideChar(cmd);
                {$IFEND}
  sei.nShow := SW_SHOWNORMAL;
  if IsWait then
  begin
    sei.fMask := sei.fMask or SEE_MASK_NOCLOSEPROCESS;
    ShellExecuteEx(@sei);
    while WaitForSingleObject(sei.hProcess, 0)  = WAIT_TIMEOUT do
    begin
      Sleep(200);
    end;
  end else
  begin
    ShellExecuteEx(@sei);
  end;
end;

procedure TKFile.SaveAll(txt, filename: string; Enc: TEncoding);
var
  s: TStringList;
begin
  s := TStringList.Create;
  try
    s.Text := txt;
    {$IF RTLVersion < 20}
    s.SaveToFile(filename);
    {$ELSE}
    s.SaveToFile(filename, Enc);
    {$IFEND}
  finally
    s.Free;
  end;
end;

initialization

finalization
  begin
    FreeAndNil(_files);
  end;

end.
