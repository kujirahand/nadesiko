unit dll_file_function;

interface
uses
  windows, dnako_import, dnako_import_types, dll_plugin_helper,
  unit_pack_files, SysUtils, Classes, shellapi, registry, inifiles,
  shlobj, Variants, ActiveX, hima_types, messages, nadesiko_version;

const
  NAKOFILE_DLL_VERSION = NADESIKO_VER;

type
  THiSystemDummy = class
  public
    constructor Create;
    function mixReader: TFileMixReader;
    function Sore: PHiValue;
  end;


procedure RegistFunction;
function ExpandEnvironmentStrDelphi(s: string): string;
// MixFileをチェック
procedure CheckMixFile(var fname: string);

implementation

uses unit_file, unit_windows_api, unit_string, hima_stream, StrUnit,
  mini_file_utils, unit_archive, LanUtil, unit_text_file, ComObj,
  unit_kanrenduke,
  EasyMasks;

var
  HiSystem: THiSystemDummy;

procedure CheckMixFile(var fname: string);
var
  s: TMemoryStream;
  f: string;
begin
  // mix file を検索
  if HiSystem.mixReader <> nil then
  if HiSystem.mixReader.ReadFile(fname, s) then
  begin
    f := TempDir + ExtractFileName(fname);
    s.SaveToFile(f);
    fname := f;
    s.Free;
    Exit;
  end;

  CheckFileExists(fname);
end;


function ExpandEnvironmentStrDelphi(s: string): string;
var
  tmp: string;
begin
  SetLength(tmp, 4096);
  ExpandEnvironmentStrings(PChar(s), PChar(tmp), 4096);
  Result := PChar(tmp);
end;

function getNakoFileDllVersion(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(NAKOFILE_DLL_VERSION);
end;

function nakofile_saveAll(args: DWORD): PHiValue; stdcall;
var
  s, f: PHiValue;
  fname, str: string;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  f := nako_getFuncArg(args, 1);

  if s <> nil then str := hi_str(s) else str := hi_str(HiSystem.Sore);
  fname := hi_str(f);

  // (2) データの処理
  FileSaveAll(str, fname);

  // (3) 戻り値を設定
  Result := nil;
end;

function nakofile_saveAllAdd(args: DWORD): PHiValue; stdcall;
var
  s, f: PHiValue;
  fname, str, ss: string;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  f := nako_getFuncArg(args, 1);

  if s <> nil then str := hi_str(s) else str := hi_str(HiSystem.Sore);
  fname := hi_str(f);
  if CheckFileExists(fname) then
  begin
    ss := FileLoadAll(fname);
  end else
  begin
    ss := '';
  end;

  // (2) データの処理
  FileSaveAll(ss + str, fname);

  // (3) 戻り値を設定
  Result := nil;
end;

function nakofile_loadAll(args: DWORD): PHiValue; stdcall;
var
  v, f: PHiValue;
  fname, str: string;
begin

  // (1) 引数の取得
  v := nako_getFuncArg(args, 0);
  f := nako_getFuncArg(args, 1);

  fname := hi_str(f);

  // (2) データの処理
  try
    if (HiSystem.mixReader = nil)or
      (not HiSystem.mixReader.ReadFileAsString(fname, str)) then
    begin
      str := FileLoadAll(fname);
    end;
  except
    raise; // 例外の再生成
  end;
  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, str);
  if v <> nil then nako_varCopyData(Result, v);
end;

function nakofile_loadEveryLine(args: DWORD): PHiValue; stdcall;
var
  v, f: PHiValue;
  fname, s: string;
  // h: TKTextFileStream;
begin
  // (1) 引数の取得
  v := nako_getFuncArg(args, 0); // ハンドル
  f := nako_getFuncArg(args, 1); // ファイル名

  fname := hi_str(f);

  // (2) データの処理
  //CheckMixFile(fname);
  if not CheckFileExists(fname) then raise Exception.Create('ファイルが見つかりません。"'+fname+'"');

  // (3) 戻り値を設定 // Create したハンドルは 『反復』構文の中で自動的に閉じる
  // h := TKTextFileStream.Create(fname, fmOpenRead or fmShareDenyWrite);
  //s := 'TKTextFileStream::' + IntToStr(Integer(h));

  s := '@@@毎行読::' + fname;
  Result := hi_newStr(s);

  // v に格納
  if v <> nil then
  begin
    hi_setStr(v, s);
  end;
end;

function nakofile_CloseEveryLine(args: DWORD): PHiValue; stdcall;
var
  ph: PHiValue;
  h: TKTextFileStream;
begin
  // (1) 引数の取得
  ph := nako_getFuncArg(args, 0); // ハンドル

  h := TKTextFileStream(hi_int(ph));
  FreeAndNil(h);

  // (3) 戻り値を設定
  Result := nil;
end;

function nakofile_pathFlagAdd(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue; str: string;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s = nil then s := nako_getSore;

  // (2) データの処理
  str := hi_str(s);
  str := CheckPathYen(str);

  // (3) 戻り値を設定
  Result := hi_newStr(str);
end;

function nakofile_pathFlagDel(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue; str: string;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s = nil then s := nako_getSore;

  // (2) データの処理
  str := hi_str(s);
  str := CheckPathYen(str);
  System.Delete(str, Length(str), 1);

  // (3) 戻り値を設定
  Result := hi_newStr(str);
end;

function nakofile_StrtoFileName(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue; str, ret: string;
  i: Integer;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s = nil then s := nako_getSore;
(*
$　　#　　%　　@　　!　　^
-(マイナス記号)　　_(アンダ−スコア)
(　　)　　{　　}　　'(引用符)
*)
  // (2) データの処理
  str := hi_str(s); ret := '';
  i := 1;
  while i <= Length(str) do
  begin
    if str[i] in LeadBytes then
    begin
      ret := ret + str[i] + str[i+1];
      Inc(i, 2);
    end else
    begin
      case str[i] of
        // 数字アルファベット
        '0'..'9','a'..'z','A'..'Z':
          begin
            ret := ret + str[i];
          end;
        // 記号だけどファイル名として使えるもの
        '$','#','%','@','!','^','~','(',')','{','}','-','_',' ','.':
          begin
            ret := ret + str[i];
          end;
        // 使えない
          else
          begin
            ret := ret + convToFull(str[i]);
          end;
      end;
      Inc(i);
    end;
  end;

  // (3) 戻り値を設定
  Result := hi_newStr(ret);
end;


function nakofile_StrtoFileNameUnix(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue; str, ret, ch: string;
  i: Integer;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s = nil then s := nako_getSore;

  // (2) データの処理
  str := hi_str(s); ret := '';
  i := 1;
  while i <= Length(str) do
  begin
    // UNIXでは全角は不可なのでとりあえず半角に変換してみる
    if str[i] in LeadBytes then
    begin
      ch := convToHalf(str[i] + str[i+1]);
      if Length(ch) >= 2 then
      begin
        // 漢字だった・・・半角に変換できない
        // 文字コードに直す
        ret := ret + IntToHex(Ord(str[i]),2) + IntToHex(Ord(str[i+1]),2);
        Inc(i,2); Continue;
      end;
      Inc(i, 2);
    end else
    begin
      ch := str[i];
      Inc(i);
    end;
    if ch = '' then Continue;

    if ch[1] in ['0'..'9','a'..'z','A'..'Z','-','_','.'] then
    begin
      ret := ret + ch[1];
    end else
    begin
      ret := ret + '_';
    end;
  end;

  // (3) 戻り値を設定
  Result := hi_newStr(ret);
end;

function nakofile_exec(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue; str: string;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s = nil then s := nako_getSore;

  // (2) データの処理
  str := hi_str(s);
  _getEmbedFile(str); // もし可能なら実行ファイルから取り出す
  if 31 >= WinExec(PChar(str), SW_SHOW) then
  begin
    // 失敗なら
    ShellExecute(0, 'open', PChar(str), '','', SW_SHOWNORMAL);
  end;
  // (3) 戻り値を設定
  Result := nil;
end;


function nakofile_exec_wait(args: DWORD): PHiValue; stdcall;
var
  fname: string;
begin
  // (1) 引数の取得
  fname := getArgStr(args, 0, True);

  // (2) データの処理
  _getEmbedFile(fname); // もし可能なら実行ファイルから取り出す
  RunAndWait(fname);

  // (3) 戻り値を設定
  Result := nil;
end;

function nakofile_exec_wait_sec(args: DWORD): PHiValue; stdcall;
var
  fname: string;
  sec: Integer;
begin
  // (1) 引数の取得
  fname := getArgStr(args, 0, True);
  sec   := getArgInt(args, 1);

  // (2) データの処理
  _getEmbedFile(fname); // もし可能なら実行ファイルから取り出す

  // (3) 戻り値を設定
  try
    Result := hi_newBool(RunAndWait(fname, False, sec));
  except
    Result := hi_newBool(False);
  end;
end;


function nakofile_exec_open_hide(args: DWORD): PHiValue; stdcall;
var
  fname: string;
begin
  // (1) 引数の取得
  fname := getArgStr(args, 0, True);

  // (2) データの処理
  _getEmbedFile(fname); // もし可能なら実行ファイルから取り出す
  if 31 >= WinExec(PChar(fname), SW_HIDE) then
  begin
    // 失敗なら
    ShellExecute(0, 'open', PChar(fname), '','', SW_HIDE);
  end;

  // (3) 戻り値を設定
  Result := nil;
end;


function nakofile_exec_wait_hide(args: DWORD): PHiValue; stdcall;
var
  fname: string;
begin
  // (1) 引数の取得
  fname := getArgStr(args, 0, True);

  _getEmbedFile(fname); // もし可能なら実行ファイルから取り出す
  RunAndWait(fname, True);

  // (3) 戻り値を設定
  Result := nil;
end;

function nakofile_exec_command(args: DWORD): PHiValue; stdcall;
const
  BUF_LEN = 8192;
var
  ParentPipe,ChildPipe: TPipe;
  res: string;
  buf: array[1..BUF_LEN] of Char;
  len,cnt: Cardinal;
  hProcess: Cardinal;
  fname: string;
label
  endloop;
begin
  fname := getArgStr(args, 0, True);
  hProcess := RunAppWithPipe(fname, True,ParentPipe,ChildPipe);

  res := '';
  cnt := 0;

  while WaitForSingleObject(hProcess,10) <> WAIT_OBJECT_0 do
  begin
    FlushFileBuffers(ParentPipe.StdOut);
    PeekNamedPipe(ParentPipe.StdOut, nil, 0, nil, @len, nil);
    if len > 0 then
    begin
      cnt := 0;
      ReadFile(ParentPipe.StdOut,buf,BUF_LEN,len,nil);
      if len = BUF_LEN then
        res := res + buf
      else
        res := res + Copy(buf,1,len);
    end else
    begin
      Inc(cnt);
      if cnt > 3000 then
        goto endloop;
    end;
  end;
  repeat
    PeekNamedPipe(ParentPipe.StdOut, nil, 0, nil, @len, nil);
    if len > 0 then
    begin
      ReadFile(ParentPipe.StdOut,buf,BUF_LEN,len,nil);
      if len = BUF_LEN then
        res := res + buf
      else
        res := res + Copy(buf,1,len);
    end;
  until len = 0;
  //MessageBox(0,PChar(IntTOStr(GetLastError)),'',0);

  endloop:

  CloseHandle(ParentPipe.StdIn);
  CloseHandle(ParentPipe.StdOut);
  CloseHandle(ParentPipe.StdErr);
  CloseHandle(ChildPipe.StdIn);
  CloseHandle(ChildPipe.StdOut);
  CloseHandle(ChildPipe.StdErr);
  CloseHandle(hProcess);
  // (3) 戻り値を設定
  Result := hi_newStr(res);
end;

function nakofile_exec_admin(args: DWORD): PHiValue; stdcall;
var
  s: string;
  f, arg: string;
begin
  s := Trim(getArgStr(args, 0, True));
  if Copy(s,1,1) = '"' then
  begin
    System.Delete(s,1,1);
    f := StrUnit.GetToken('"', s);
    arg := s;
  end else
  begin
    f := StrUnit.GetToken(' ', s);
    arg := s;
  end;
  _getEmbedFile(f); // もし可能なら実行ファイルから取り出す
  RunAsAdmin(nako_getMainWindowHandle, f, arg);
  Result := nil;
end;

function nakofile_exec_exp(args: DWORD): PHiValue; stdcall;
var
  s: string;
  h: HWND;
begin
  // (1) 引数の取得
  s := getArgStr(args, 0, True);
  h := nako_getMainWindowHandle;

  // (2) データの処理
  ShellExecute(
    h,
    'explore',
    PChar(s), '', '', SW_SHOWNORMAL);

  // (3) 戻り値を設定
  Result := nil;
end;

function nakofile_setCurDir(args: DWORD): PHiValue; stdcall;
var s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s = nil then s := nako_getSore;
  // (2) データの処理
  SetCurrentDir(hi_str(s));
  // (3) 戻り値を設定
  Result := nil;
end;

function nakofile_getCurDir(args: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  // (1) 引数の取得
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_var_new;
  s := CheckPathYen( GetCurrentDir );
  hi_setStr(Result, s);
end;

function nakofile_makeDir(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  a: string;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  // (2) データの処理
  try
    a := hi_str(s);
    if PosA('\', a) > 0  then ForceDirectories(a)
                        else MkDir(a);
  except on e: Exception do
    raise Exception.Create('フォルダ『' + hi_str(s) + '』が作成できません。理由は,' + e.Message);
  end;
  // (3) 戻り値を設定
  Result := nil;
end;

function nakofile_removeDir(args: DWORD): PHiValue; stdcall;
var ps: PHiValue; s: string;
begin
  // (1) 引数の取得
  ps := nako_getFuncArg(args, 0);
  s  := hi_str(ps);

  // (2) データの処理
  s := CheckPathYen(s);

  // 最後の\を取る
  System.Delete(s, Length(s), 1);
  SHFileDelete(s); // == RemoveDir(hi_str(s));(RemoveDirでは制限がある)

  // (3) 戻り値を設定
  Result := nil;
end;


function nakofile_enumFiles(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  path, f: string;
  g: TStringList;
  i: Integer;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then path := GetCurrentDir
           else path := hi_str(s);

  // (2) データの処理
  g := EnumFiles(path);

  // (3) 結果の代入
  Result := hi_var_new;
  nako_ary_create(Result);
  for i := 0 to g.Count - 1 do
  begin
    f := g.Strings[i];
    if f = '' then Continue;
    s := hi_newStr(f);
    nako_ary_add(Result, s);
  end;
  //FileSaveAll(g.Text, 'test.txt');
  //FileSaveAll(hi_str(Result), 'test.txt');
  g.Free;
end;

function nakofile_enumAllFiles(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  path: string;
  g: TStringList;
  i: Integer;
  option: string;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then path := CheckPathYen( GetCurrentDir )
           else path := hi_str(s);

  // (2) データの処理
  option := hi_strU(nako_getVariable('ファイル列挙オプション'));
  if Pos('タイトル経過表示',option) > 0 then
    unit_file.MainWindowHandle := nako_getMainWindowHandle
  else
    unit_file.MainWindowHandle := 0;
  g := EnumAllFiles(path);

  // (3) 結果の代入
  Result := hi_var_new;
  nako_ary_create(Result);
  for i := 0 to g.Count - 1 do
  begin
    nako_ary_add(
      Result,
      hi_newStr(g.Strings[i])
    );
  end;
  FreeAndNil(g);
end;

function nakofile_enumAllFilesRelative(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  tmp, path, basepath: AnsiString;
  g: TStringList;
  i,len: Integer;
  option: string;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then path := CheckPathYen( GetCurrentDir )
           else path := hi_str(s);

  // (2) データの処理
  option := hi_strU(nako_getVariable('ファイル列挙オプション'));
  if Pos('タイトル経過表示',option) > 0 then
    unit_file.MainWindowHandle := nako_getMainWindowHandle
  else
    unit_file.MainWindowHandle := 0;
  g := EnumAllFiles(path, basepath);
  len := Length(basepath);

  // (3) 結果の代入
  Result := hi_var_new;
  nako_ary_create(Result);
  for i := 0 to g.Count - 1 do
  begin
    tmp := g.Strings[i];
    System.Delete(tmp, 1, len);
    nako_ary_add(
      Result,
      hi_newStr(tmp)
    );
  end;
  FreeAndNil(g);
end;

function nakofile_enumAllDir(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  path: string;
  g: TStringList;
  i: Integer;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then path := CheckPathYen( GetCurrentDir )
           else path := hi_str(s);

  // (2) データの処理
  g := EnumAllDirs(path);

  // (3) 結果の代入
  Result := hi_var_new;
  nako_ary_create(Result);
  for i := 0 to g.Count - 1 do
  begin
    nako_ary_add(
      Result,
      hi_newStr(g.Strings[i])
    );
  end;

  g.Free;
end;


function nakofile_enumDirs (args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  path, n: string;
  g: TStringList;
  i: Integer;
begin
  Result := hi_var_new;
  nako_ary_create(Result);

  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then path := CheckPathYen( GetCurrentDir )
           else path := hi_str(s);

  if CopyA(path, JLength(path), 1) = '\' then path := path + '*';

  // (2) データの処理
  g := EnumDirs(path);
  for i := 0 to g.Count - 1 do
  begin
    n := g.Strings[i];
    // (3) 戻り値を設定
    nako_ary_add(Result, hi_newStr(n));
  end;

end;

function nakofile_FileExists (args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  fname: string;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  fname := hi_str(s);

  // (2) データの処理
  // (3) 戻り値を設定

  SetErrorMode(SEM_FAILCRITICALERRORS);

  // フォルダ？
  if DirectoryExists(fname) then
  begin
    hi_setBool(Result, True); Exit;
  end;

  // ファイル
  if FileExists(fname) then
  begin
    hi_setBool(Result, True);
  end else
  begin
    hi_setBool(Result, False);
  end;
  
  SetErrorMode(0);
end;

function nakofile_ExistsDir (args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  fname: string;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  fname := hi_str(s);

  // フォルダ？
  Result := hi_newBool(DirectoryExists(fname));
end;

function nakofile_getLongFileName(args: DWORD): PHiValue; stdcall;
var
  fname: string;
begin
  fname := getArgStr(args, 0, True);
  Result := hi_newStr(ShortToLongFileName(fname));
end;
function nakofile_getShortFileName(args: DWORD): PHiValue; stdcall;
var
  fname: string;
begin
  fname := getArgStr(args, 0, True);
  Result := hi_newStr(LongToShortFileName(fname));
end;


function nakofile_fileCopy(args: DWORD): PHiValue; stdcall;
var
  pa, pb: PHiValue;
  sa, sb: string;
begin

  // (1) 引数の取得
  pa := nako_getFuncArg(args, 0);
  pb := nako_getFuncArg(args, 1);

  sa  := hi_str(pa);
  sb  := hi_str(pb);

  dll_plugin_helper._getEmbedFile(sa); // もし可能なら実行ファイルから取り出す

  // パスがないと誤作動を起こすのでパスを補完してやる
  CheckMixFile(sa);
  if (Pos(':\', sa) = 0)and(Pos('\\', sa) = 0) then // フルパス指定ではない
  begin
    sa := CheckPathYen(GetCurrentDir) + sa;
  end;
  if (Pos(':\', sb) = 0)and(Pos('\\', sb) = 0) then // フルパス指定ではない
  begin
    sb := CheckPathYen(GetCurrentDir) + sb;
  end;

  // sa/sb がフォルダか？ ... フォルダなら最後の'\'は削除
  if DirectoryExists(sa) then
  begin
    sa := CheckPathYen(sa);
    System.Delete(sa, Length(sa), 1);
  end;
  if DirectoryExists(sb) then
  begin
    sb := CheckPathYen(sb);
    System.Delete(sb, Length(sb), 1);
  end;

  // (2) データの処理
  unit_file.MainWindowHandle := nako_getMainWindowHandle;
  if not SHFileCopy(sa, sb, 'ファイルコピー') then
  begin
    raise Exception.Create('「'+sa+'」から「'+sb+'」へファイルコピーに失敗。');
  end;

  // (3) 戻り値を設定
  Result := nil;
end;

function nakofile_fileCopyEx(args: DWORD): PHiValue; stdcall;
var
  extList: TStringList;
  blackList: TStringList;


  function _checkBlackList(path: string): Boolean;
  var
    i: Integer;
    mask: string;
  begin
    Result := False;
    for i := 0 to blackList.Count - 1 do
    begin
      mask := blackList.Strings[i];
      if MatchesMask(path, mask) then
      begin
        Result := True;
        Break;
      end;
    end;
  end;

  function _match(path: string): Boolean;
  var
    i: Integer;
    mask: string;
  begin
    Result := False;
    for i := 0 to extList.Count - 1 do
    begin
      mask := extList.Strings[i];
      if MatchesMask(path, mask) then
      begin
        if _checkBlackList(path) then
        begin
          Continue;
        end;
        Result := True;
        Exit;
      end;
    end;
  end;

  procedure _copy(fromDir, toDir: string);
  var
    rec: TSearchRec;
    fromFile, toFile: string;
  begin
    // ディレクトリがない
    if not DirectoryExists(fromDir) then Exit;
    //
    SetWindowText(unit_file.MainWindowHandle, PChar(fromDir));
    //
    if 0 = FindFirst(fromDir+'*', faAnyFile, rec) then
    begin
      while (True) do
      begin
        if (rec.Name = '.') or (rec.Name = '..') then
        begin
          // do nothing
        end else
        if (rec.Attr and faDirectory > 0) then
        begin
          // copy recursive
          _copy(fromDir + rec.Name + '\', toDir + rec.Name + '\');
        end else
        begin
          // check filter
          fromFile := fromDir + rec.Name;
          toFile   := toDir   + rec.Name;
          if _match(toFile) then
          begin
            if not DirectoryExists(toDir) then ForceDirectories(toDir);
            if CopyFile(PChar(fromFile), PChar(toFile), False) = False then
            begin
              raise Exception.Create('"' + toFile + '"のコピーに失敗');
            end;
          end;
        end;
        // next
        if FindNext(rec) <> 0 then Break;
      end;
    end;
    FindClose(rec);
  end;

var
  fromDir, toDir, paramFrom, paramTo: string;
  extListStr: string;
  cap: string;
begin

  // (1) 引数の取得
  fromDir := getArgStr(args, 0, True);
  toDir   := getArgStr(args, 1);

  paramFrom := fromDir;
  paramTo   := toDir;

  // ---------------------------------------------------
  // パスがないと誤作動を起こすのでパスを補完してやる
  CheckMixFile(fromDir);
  if (Pos(':\', fromDir) = 0)and(Pos('\\', fromDir) = 0) then // フルパス指定ではない
  begin
    fromDir := CheckPathYen(GetCurrentDir) + fromDir;
  end;
  if (Pos(':\', toDir) = 0)and(Pos('\\', toDir) = 0) then // フルパス指定ではない
  begin
    toDir := CheckPathYen(GetCurrentDir) + toDir;
  end;

  // fromDir, toDir がパスか？
  // パスなら、\ をつける
  if DirectoryExists(fromDir) then
  begin
    fromDir := CheckPathYen(fromDir);
  end;
  // toDir は必ずディレクトリ
  toDir := CheckPathYen(toDir);

  // fromDir にフィルタの指定があるか？
  // フィルタがあれば、フィルタとパスを切り離す
  extList := nil;
  if not DirectoryExists(fromDir) then
  begin
    extListStr := ExtractFileName(fromDir);
    fromDir    := ExtractFilePath(fromDir);
    extList := SplitChar(';', extListStr);
  end;

  if extList = nil then
  begin
    extList := TStringList.Create;
  end;
  if extList.Count = 0 then
  begin
    extList.Add('*.*');
  end;

  blackList := TStringList.Create;
  blackList.Text := hi_str(nako_getVariable('ファイル抽出コピー除外パターン'));

  // ---------------------------------------------------
  // (2) データの処理
  unit_file.MainWindowHandle := nako_getMainWindowHandle;
  SetLength(cap, 4096);
  GetWindowText(unit_file.MainWindowHandle, PChar(cap), 4095);
  // copy
  try
    _copy(fromDir, toDir);
  except
    on e:Exception do
    begin
      raise Exception.CreateFmt('「%s」から「%s」への途中に発生：%s',
        [paramFrom, paramTo, e.Message]);
    end;
  end;
  //
  FreeAndNil(extList);
  FreeAndNil(blackList);
  SetWindowText(unit_file.MainWindowHandle, PChar(cap));
  // (3) 戻り値を設定
  Result := nil;
end;

function nakofile_dirCopy(args: DWORD): PHiValue; stdcall;
var
  a, b: PHiValue;
  sa,sb: string;
begin

  // (1) 引数の取得
  a := nako_getFuncArg(args, 0);
  b := nako_getFuncArg(args, 1);
  sa := hi_str(a);
  sb := hi_str(b);
  if CopyA(sa,JLength(sa),1) = '\' then System.Delete(sa,Length(sa),1);
  if CopyA(sb,JLength(sb),1) = '\' then System.Delete(sb,Length(sb),1);

  if DirectoryExists(sb) = False then
  begin
    ForceDirectories(sb);
  end;

  // (2) データの処理
  unit_file.MainWindowHandle := nako_getMainWindowHandle;
  if not SHFileCopy(sa, sb, 'フォルダコピー') then
  begin
    raise Exception.Create('フォルダコピーに失敗。' + GetLastErrorStr);
  end;

  // (3) 戻り値を設定
  Result := nil;
end;

function nakofile_fileRename(args: DWORD): PHiValue; stdcall;
var
  a, b: PHiValue;
  sa, sb, dir: string;
begin
  // (1) 引数の取得
  a := nako_getFuncArg(args, 0);
  b := nako_getFuncArg(args, 1);

  // パスがないと誤作動を起こすのでパスを補完してやる
  sa := hi_str(a);
  sb := hi_str(b);

  if (Pos(':\', sa) = 0)and(Pos('\\', sa) = 0) then // フルパス指定ではない
  begin
    sa := CheckPathYen(GetCurrentDir) + sa;
  end;
  if (Pos(':\', sb) = 0)and(Pos('\\', sb) = 0) then // フルパス指定ではない
  begin
    //sb := ExtractFilePath(sa) + sb;
    sb := CheckPathYen(GetCurrentDir) + sb;
  end;

  // もし移動先のフォルダが存在しないならば、ディレクトリを作成する
  // ---
  // 移動先がディレクトリ
  if (Copy(sb, Length(sb), 1) = '\') then
  begin
    if not DirectoryExists(sb) then
    begin
      ForceDirectories(sb);
    end;
  end else
  begin
    dir := ExtractFilePath(sb);
    ForceDirectories(dir);
  end;

  // (2) データの処理
  unit_file.MainWindowHandle := nako_getMainWindowHandle;
  if not SHFileRename(sa, sb) then
  begin
    raise Exception.CreateFmt('「%s」から「%s」へファイル名変更に失敗。',[sa,sb]);
  end;

  // (3) 戻り値を設定
  Result := nil;
end;

function nakofile_fileDelete(args: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := nako_getFuncArg(args, 0);

  // (2) データの処理
  unit_file.MainWindowHandle := nako_getMainWindowHandle;
  if not SHFileDelete(hi_str(a)) then
  begin
    raise Exception.Create('ファイル削除に失敗。' + GetLastErrorStr);
  end;

  // (3) 戻り値を設定
  Result := nil;
end;

function nakofile_fileDeleteAll(args: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := nako_getFuncArg(args, 0);

  // (2) データの処理
  unit_file.MainWindowHandle := nako_getMainWindowHandle;
  if not SHFileDeleteComplete(hi_str(a)) then
  begin
    raise Exception.Create('ファイル削除に失敗。' + GetLastErrorStr);
  end;

  // (3) 戻り値を設定
  Result := nil;
end;



function nakofile_shortcut(args: DWORD): PHiValue; stdcall;
var
  a, b: PHiValue;
begin
  a := nako_getFuncArg(args, 0);
  b := nako_getFuncArg(args, 1);
  CreateShortCut(hi_str(b), hi_str(a), '', '', ws2Normal);
  Result := nil;
end;

function nakofile_shortcut_ex(args: DWORD): PHiValue; stdcall;
var
  a, b, c, p: PHiValue;
  Arg,Comment,Key,Icon,WorkingDir,Win:String;
  HotKeyHi,HotKeyLo:BYTE;
  IconNo:Integer;
  WinState: TWindowState2;
  pc:PChar;
begin
  a := nako_getFuncArg(args, 0);
  b := nako_getFuncArg(args, 1);
  c := nako_getFuncArg(args, 2);

  Arg:='';
  Comment:='';
  Key:='';
  Icon:='';
  IconNo:=0;
  WorkingDir:='';
  Win:='';
  HotKeyHi:=0;
  HotKeyLo:=0;
  WinState:= ws2Normal;

  p := nako_hash_get(c,'引数');
  if p <> nil then Arg := hi_str(p);
  p := nako_hash_get(c,'コメント');
  if p <> nil then Comment := hi_str(p);
  p := nako_hash_get(c,'ショートカットキー');
  if p <> nil then
  begin
    Key := hi_str(p);
    pc:=PChar(AnsiUpperCase(Key));
    while pc^ <> #0 do
    begin
      case pc^ of
        '^':HotKeyHi:= HotKeyHi or HOTKEYF_CONTROL;
        '%':HotKeyHi:= HotKeyHi or HOTKEYF_ALT;
        '+':HotKeyHi:= HotKeyHi or HOTKEYF_SHIFT;
        else
          HotKeyLo:= BYTE(pc^);
      end;
      Inc(pc);
    end;
  end;
  p := nako_hash_get(c,'アイコン');
  if p <> nil then Icon := hi_str(p);
  p := nako_hash_get(c,'アイコン番号');
  if p <> nil then IconNo := hi_int(p);
  p := nako_hash_get(c,'作業フォルダ');
  if p <> nil then WorkingDir := hi_str(p);
  p := nako_hash_get(c,'ウィンドウ状態');//最大/最小/通常
  if p <> nil then
  begin
    Win := hi_str(p);
    if Win = '最大' then
      WinState := ws2Maximized
    else if Win = '最小' then
      WinState := ws2Minimized;
  end;

  CreateShortCutEx(hi_str(b), hi_str(a), Arg, WorkingDir, Icon,IconNo, Comment,
    MakeWord(HotKeyLo,HotKeyHi), WinState);
  Result := nil;
end;

function nakofile_get_shortcut(args: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := nako_getFuncArg(args, 0);
  Result := hi_newStr(GetShortCutLink(hi_str(a)));
end;



function nakofile_sp_path(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(GetSpecialFolder(getArgInt(args,0,True)));
end;
function get_CSIDL_COMMON_STARTUP(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(GetSpecialFolder(CSIDL_COMMON_STARTUP));
end;
function get_CSIDL_COMMON_DESKTOPDIRECTORY(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(GetSpecialFolder(CSIDL_COMMON_DESKTOPDIRECTORY));
end;
function get_CSIDL_COMMON_DOCUMENTS(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(GetSpecialFolder(CSIDL_COMMON_DOCUMENTS));
end;
function get_CSIDL_COMMON_APPDATA(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(GetSpecialFolder(CSIDL_COMMON_APPDATA));
end;
function get_CSIDL_COMMON_FAVORITES(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(GetSpecialFolder(CSIDL_COMMON_FAVORITES));
end;
function get_CSIDL_LOCAL_APPDATA(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(GetSpecialFolder(CSIDL_LOCAL_APPDATA));
end;
function get_USER_PROFILE(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(GetSpecialFolder(CSIDL_PROFILE));
end;
function get_APPDATA(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(GetSpecialFolder(CSIDL_APPDATA));
end;
function get_SENDTO(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(GetSpecialFolder(CSIDL_SENDTO));
end;
function get_QUICKLAUNCH(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(QuickLaunchDir);
end;
function get_COMSPEC(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(ExpandEnvironmentStrDelphi('%COMSPEC%'));
end;
function get_SYSTEMDRIVE(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(ExpandEnvironmentStrDelphi('%SystemDrive%'));
end;



function nakofile_getOE5(args: DWORD): PHiValue; stdcall;
var
  r: TRegistry;
  s: TStringList;
  id, path: string;
begin
  Result := hi_var_new;
  r := TRegistry.Create;
  s := TStringList.Create;
  try
    //HKEY_CURRENT_USER\Identities\<{ID}>\Software\Microsoft\Outlook Express\5.0\Rules\Mail
    r.RootKey := HKEY_CURRENT_USER;
    if r.OpenKeyReadOnly('Identities') then
    begin
      r.GetKeyNames(s);
      r.CloseKey;
      if s.Count = 0 then Exit;
      id := s.Strings[0];//writeln(id);
    end else Exit;
    if r.OpenKeyReadOnly('Identities\' + id + '\Software\Microsoft\Outlook Express\5.0') then
    begin
      path := r.ReadString('Store Root');
      r.CloseKey;

      // 環境変数を展開
      path := CheckPathYen(ExpandEnvironmentStrDelphi(path));

      // 結果をセット
      hi_setStr(Result, path);
    end;
  finally
    s.Free;
    r.Free;
  end;
end;



function nakofile_getBecky2(args: DWORD): PHiValue; stdcall;
var
  r: TRegistry;
  s: TStringList;
  path: string;
begin
  Result := hi_var_new;
  r := TRegistry.Create;
  s := TStringList.Create;
  try
    r.RootKey := HKEY_CURRENT_USER;
    if r.OpenKeyReadOnly('Software\RimArts\B2\Settings') then
    begin
      path := CheckPathYen(r.ReadString('DataDir'));
      hi_setStr(Result, path);
    end;
  finally
    s.Free;
    r.Free;
  end;
end;

function nakofile_expandEnv(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr( ExpandEnvironmentStrDelphi( getArgStr(args,0,True) ) );
end;

function nakofile_getFileSize(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  F: TSearchRec;
  i: Int64;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := HiSystem.Sore;

  // (2) データの処理
  if FindFirst(hi_str(s), FaAnyFile, F) = 0 then
  begin
    i := F.FindData.nFileSizeLow + Int64(F.FindData.nFileSizeHigh) shl 32;
    FindClose(F);
  end else i := 0;

  // (3) 戻り値を設定
  Result := hi_var_new;
  if i >= MaxInt then
  begin
    hi_setFloat(Result, i);
  end else
  begin
    hi_setInt(Result, Integer(i));
  end;
end;

function nakofile_getFileDate(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  F: TSearchRec;
  d: TDateTime;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := HiSystem.Sore;
  // (2) データの処理
  if FindFirst(hi_str(s), FaAnyFile, F) = 0 then
  begin
    d := FileDateToDateTime(F.Time);
    FindClose(F);
  end else
  begin
    Result := hi_newStr(''); Exit;
  end;

  // (3) 戻り値を設定
  Result := hi_newStr(FormatDateTime('yyyy/mm/dd hh:nn:ss',d));
end;


function nakofile_getCreateFileDate(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  tCreation, tLastAccess, tLastWrite:TDateTime;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := HiSystem.Sore;

  // (2) データの処理
  if GetFileTimeEx(hi_str(s), tCreation, tLastAccess, tLastWrite) then
  begin
    Result := hi_newStr(FormatDateTime('yyyy/mm/dd hh:nn:ss', tCreation));
  end else
  begin
    Result := nil;
  end;
end;

function nakofile_getLastAccessFileDate(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  tCreation, tLastAccess, tLastWrite:TDateTime;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := HiSystem.Sore;

  // (2) データの処理
  if GetFileTimeEx(hi_str(s), tCreation, tLastAccess, tLastWrite) then
  begin
    Result := hi_newStr(FormatDateTime('yyyy/mm/dd hh:nn:ss', tLastAccess));
  end else
  begin
    Result := nil;
  end;
end;

function nakofile_getWriteFileDate(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  tCreation, tLastAccess, tLastWrite:TDateTime;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then s := HiSystem.Sore;

  // (2) データの処理
  if GetFileTimeEx(hi_str(s), tCreation, tLastAccess, tLastWrite) then
  begin
    Result := hi_newStr(FormatDateTime('yyyy/mm/dd hh:nn:ss', tLastWrite));
  end else
  begin
    Result := nil;
  end;
end;

function nakofile_setFileDateCreate(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  fname, fdate: string;
  tCreation, tLastAccess, tLastWrite:TDateTime;
begin
  Result := nil;

  // 引数の取得
  p := nako_getFuncArg(args, 0); if p=nil then p := HiSystem.Sore;
  fname := hi_str(p);
  fdate := hi_str(nako_getFuncArg(args, 1));

  // 現在の日時を得る
  if not GetFileTimeEx(fname, tCreation, tLastAccess, tLastWrite) then
  begin
    raise Exception.Create('『'+fname+'』が特定できません。');
  end;

  tCreation := StrToDateTimeDef(fdate, 0);
  if tCreation = 0 then raise Exception.Create('日付('+fdate+')の形式は認識できません。');

  // 日付を設定する
  if not SetFileTimeEx(fname, tCreation, tLastAccess, tLastWrite) then
  begin
    raise Exception.Create('日付の変更に失敗しました。');
  end;
end;

function nakofile_setFileDateWrite(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  fname, fdate: string;
  tCreation, tLastAccess, tLastWrite:TDateTime;
begin
  Result := nil;

  // 引数の取得
  p := nako_getFuncArg(args, 0); if p=nil then p := HiSystem.Sore;
  fname := hi_str(p);
  fdate := hi_str(nako_getFuncArg(args, 1));

  // 現在の日時を得る
  if not GetFileTimeEx(fname, tCreation, tLastAccess, tLastWrite) then
  begin
    raise Exception.Create('『'+fname+'』が特定できません。');
  end;

  tLastWrite := StrToDateTimeDef(fdate, 0);
  if tLastWrite = 0 then raise Exception.Create('日付('+fdate+')の形式は認識できません。');

  // 日付を設定する
  if not SetFileTimeEx(fname, tCreation, tLastAccess, tLastWrite) then
  begin
    raise Exception.Create('日付の変更に失敗しました。');
  end;
end;

function nakofile_setFileDateLastAccess(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  fname, fdate: string;
  tCreation, tLastAccess, tLastWrite:TDateTime;
begin
  Result := nil;

  // 引数の取得
  p := nako_getFuncArg(args, 0); if p=nil then p := HiSystem.Sore;
  fname := hi_str(p);
  fdate := hi_str(nako_getFuncArg(args, 1));

  // 現在の日時を得る
  if not GetFileTimeEx(fname, tCreation, tLastAccess, tLastWrite) then
  begin
    raise Exception.Create('『'+fname+'』が特定できません。');
  end;

  tLastAccess := StrToDateTimeDef(fdate, 0);
  if tLastAccess = 0 then raise Exception.Create('日付('+fdate+')の形式は認識できません。');

  // 日付を設定する
  if not SetFileTimeEx(fname, tCreation, tLastAccess, tLastWrite) then
  begin
    raise Exception.Create('日付の変更に失敗しました。');
  end;
end;

function nakofile_getFileAttr(args: DWORD): PHiValue; stdcall;
var f: PHiValue; fname: string;
begin
  f := nako_getFuncArg(args, 0);
  if f = nil then f := nako_getSore;
  fname := hi_str(f);
  Result := hi_newInt(GetFileAttributes(PChar(fname)));
end;

function nakofile_setFileAttr(args: DWORD): PHiValue; stdcall;
var f, s: PHiValue; fname: string;
begin
  f := nako_getFuncArg(args, 0);
  s := nako_getFuncArg(args, 1);
  if f = nil then f := nako_getSore;
  fname := hi_str(f);
  SetFileAttributes(PChar(fname), hi_int(s));
  Result := nil;
end;


function nakofile_getLogicalDrives(args: DWORD): PHiValue; stdcall;
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
  buf := Trim(JReplace(buf, #13, #13#10, True));
  //
  Result := hi_newStr(buf);
end;

function nakofile_getDriveType(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue; sp, r: string;
  u: UINT;
begin
  p := nako_getFuncArg(args, 0);
  if p = nil then p := nako_getSore;
  sp := hi_str(p);

  // 不明|存在しない|取り外し可能|固定|ネットワーク|CD-ROM|RAM
  u := GetDriveType(PChar(sp));
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

  Result := hi_newStr(r);
end;

function nakofile_getDiskSize(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue; sp: string;
  iFree, iTotal: TLargeInteger;
begin
  p := nako_getFuncArg(args, 0);
  if p = nil then p := nako_getSore;
  sp := hi_str(p);

  SetErrorMode(SEM_FAILCRITICALERRORS);

  if DirectoryExists(sp) then
  begin
    GetDiskFreeSpaceEx(PChar(sp), iFree, iTotal, nil);
  end else
  begin
    iTotal := -1;
  end;
  Result := hi_newFloat(iTotal);

  SetErrorMode(0);

end;
function nakofile_getDiskFreeSize(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue; sp: string;
  iFree, iTotal: Int64;
begin
  p := nako_getFuncArg(args, 0);
  if p = nil then p := nako_getSore;
  sp := hi_str(p);

  SetErrorMode(SEM_FAILCRITICALERRORS);
  if DirectoryExists(sp) then
  begin
    GetDiskFreeSpaceEx(PChar(sp), iFree, iTotal, nil);
  end else
  begin
    iFree := -1;
  end;
  Result := hi_newFloat(iFree);
end;
function nakofile_getVolumeName(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue; sp: string;
begin
  p := nako_getFuncArg(args, 0);
  if p = nil then p := nako_getSore;
  sp := hi_str(p);
  Result := hi_newStr(getVolumeName(sp));
end;
function nakofile_getSerialNo(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue; sp: string;
begin
  p := nako_getFuncArg(args, 0);
  if p = nil then p := nako_getSore;
  sp := hi_str(p);
  Result := hi_newInt(getSerialNo(sp));
end;

function nakofile_showHotplugDlg(args: DWORD): PHiValue; stdcall;
begin
  RunApp('rundll32 shell32.dll,Control_RunDLL hotplug.dll');
  Result := nil;
end;

function nakofile_shell_association(args: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_FLUSH, nil, nil);
end;

function nakofile_shell_updatedir(args: DWORD): PHiValue; stdcall;
var
  dir: string;
begin
  Result := nil;
  dir := getArgStr(args, 0, True);
  SHChangeNotify(SHCNE_UPDATEDIR, SHCNF_PATH, PChar(dir), nil);
end;

function nakofile_file_h_open(args: DWORD): PHiValue; stdcall;
var
  a, b: PHiValue;
  f: TFileStream;
  fname, fmode: string;
  flg: Integer;
begin
  a := nako_getFuncArg(args, 0); fname := hi_str(a);
  b := nako_getFuncArg(args, 1); fmode := hi_str(b);

  flg := 0;
  dll_plugin_helper._getEmbedFile(fname); // もし可能なら実行ファイルから取り出す

  // 生成?
  if (FileExists(fname)=False)or(Pos('作',fmode) > 0) then
  begin
    flg := flg or fmCreate;
  end;

  // モード
  if (Pos('読',fmode) > 0)and(Pos('書',fmode) > 0) then
  begin
    flg := flg or fmOpenReadWrite;
  end else
  if Pos('読', fmode) > 0 then
  begin
    flg := flg or fmOpenRead;
  end else
  if Pos('書', fmode) > 0 then
  begin
    flg := flg or fmOpenWrite;
  end;

  // 排他
  if Pos('排他', fmode) > 0 then
  begin
    flg := flg or fmShareExclusive;
  end else
  begin
    flg := flg or fmShareDenyNone;
  end;

  f := TFileStream.Create(fname, flg);
  Result := hi_newInt(Integer(f));
end;

function nakofile_file_h_read(args: DWORD): PHiValue; stdcall;
var
  ph, pcnt: PHiValue;
  s: string;
  h: TFileStream;
  read_sz, required_sz: Integer;
begin
  ph   := nako_getFuncArg(args, 0);
  pcnt := nako_getFuncArg(args, 1);
  required_sz := hi_int(pcnt);

  h := TFileStream( hi_int(ph) );
  SetLength(s, required_sz);

  read_sz := h.Read(s[1], required_sz);
  if read_sz < required_sz then SetLength(s, read_sz);

  Result := hi_newStr(s);
end;

function nakofile_file_h_write(args: DWORD): PHiValue; stdcall;
var
  ph, ps: PHiValue;
  s: string;
  h: TFileStream;
begin
  ph   := nako_getFuncArg(args, 0);
  ps   := nako_getFuncArg(args, 1);

  h := TFileStream( hi_int(ph) );
  s := hi_str(ps);

  if Length(s) > 0 then
  begin
    h.Write(s[1], Length(s));
  end;

  Result := nil;
end;

function nakofile_file_h_close(args: DWORD): PHiValue; stdcall;
var
  ph: PHiValue;
  h : TFileStream;
begin
  ph := nako_getFuncArg(args, 0);
  h  := TFileStream( hi_int(ph) );

  FreeAndNil(h);

  Result := nil;
end;

function nakofile_file_h_getpos(args: DWORD): PHiValue; stdcall;
var
  ph: PHiValue;
  h : TFileStream;
begin
  ph := nako_getFuncArg(args, 0);
  h  := TFileStream( hi_int(ph) );

  Result := hi_newInt( h.Position );
end;

function nakofile_file_h_setpos(args: DWORD): PHiValue; stdcall;
var
  ph, pi: PHiValue;
  h : TFileStream;
  i : Integer;
begin
  ph := nako_getFuncArg(args, 0);
  pi := nako_getFuncArg(args, 1);

  h  := TFileStream( hi_int(ph) );
  i  := hi_int(pi);

  h.Position := i;

  Result := nil;
end;

function nakofile_file_h_size(args: DWORD): PHiValue; stdcall;
var
  ph: PHiValue;
  h : TFileStream;
begin
  ph := nako_getFuncArg(args, 0);
  h  := TFileStream( hi_int(ph) );

  Result := hi_newInt(h.Size);
end;

function nakofile_file_h_writeLine(args: DWORD): PHiValue; stdcall;
var
  ph: PHiValue;
  h: TFileStream;
  s: string;
begin
  s  := getArgStr(args, 0, True) + #13#10;
  ph := nako_getFuncArg(args, 1);
  //
  h  := TFileStream( hi_int(ph) );
  h.Write(s[1], Length(s));
  Result := nil;
end;

function nakofile_file_h_readLine(args: DWORD): PHiValue; stdcall;
const
  bufCount = 4096;
var
  ph: PHiValue;
  h : TFileStream;
  si, se: Int64;
  buf, res: string;
  i, j, sz: Integer;
  flagEnd: Boolean;
begin
  ph := nako_getFuncArg(args, 0);
  h  := TFileStream( hi_int(ph) );

  // buf
  SetLength(buf, bufCount);

  // defalt pos
  si := h.Position;
  res := ''; flagEnd := False; se :=si;

  // 適当に読む
  while True do
  begin
    sz := h.Read(buf[1], bufCount);
    if sz < bufCount then
    begin
      // ストリームの最後まで読んでしまった場合
      flagEnd := True;
      SetLength(buf,sz);
    end;
    j := 0;
    for i := 1 to sz do
    begin
      if buf[i] in [#13,#10] then
      begin
        j := i;
        if (i+1) <= bufCount then
        begin
          if buf[i+1] in [#10] then
          begin
            j := i+1;
          end;
        end;
        Break;
      end;
    end;
    // 改行がバッファ内にあった場合
    if j > 0 then
    begin
      // 123456** 8
      res := res + Copy(buf, 1, j);
      se := si + Length(res);
      // 改行をそぎ落とす
      if Copy(res, Length(res), 1) = #10 then System.Delete(res, Length(res), 1);
      if Copy(res, Length(res), 1) = #13 then System.Delete(res, Length(res), 1);
      Break;
    end else
    begin
      // 全てのバッファを足す
      res := res + buf;
      se := si + Length(res);
      if flagEnd then Break; // これ以上読めないなら、もちろん終わり
    end;
  end;

  // インデックスを後ろにずらす
  h.Position := se;

  // 結果
  Result := hi_newStr(res);
end;

function nakofile_compress(args: DWORD): PHiValue; stdcall;
var
  a, b: PHiValue;
  src, des, ext: string;
begin
  // (1) 引数の取得
  a := nako_getFuncArg(args, 0);
  b := nako_getFuncArg(args, 1);

  src := hi_str(a);
  des := hi_str(b);
  ext := LowerCase( ExtractFileExt(des) );

  // (2) 処理
  if ext = '.lzh' then lha_compress(src, des) else
  if ext = '.zip' then zip_compress(src, des) else
  if ext = '.cab' then cab_compress(src, des) else
  if ext = '.exe' then lha_makeSFX(src, des) else
  if ext = '.yz1' then yz1_compress(src, des) else
  if ext = '.7z'  then zip_compress(src, des) else
  raise Exception.Create('"'+ext+'"は未対応の圧縮形式です。');
  nako_reportDLL(PChar(unit_archive.used_dll));

  // (3) 結果の代入
  Result := nil;
end;

function nakofile_extract(args: DWORD): PHiValue; stdcall;
var
  a, b: PHiValue;
  src, des, ext: string;
begin
  // (1) 引数の取得
  a := nako_getFuncArg(args, 0);
  b := nako_getFuncArg(args, 1);
  // (2) 処理
  src := hi_str(a);
  des := hi_str(b);
  ext := LowerCase( ExtractFileExt(src) );

  if ExtractFileExt(des) = '' then
  begin
    des := CheckPathYen(des);
    ForceDirectories(des);
  end;

  dll_plugin_helper._getEmbedFile(src); // もし可能なら実行ファイルから取り出す

  // (2) 処理
  if ext = '.lzh' then lha_extract (src, des)  else
  if ext = '.zip' then zip_extract (src, des)  else
  if ext = '.cab' then cab_extract (src, des)  else
  if ext = '.yz1' then yz1_extract (src, des)  else
  if ext = '.7z'  then zip_extract (src, des)  else
  raise Exception.Create('"'+ext+'"は未対応の圧縮形式です。');
  nako_reportDLL(PChar(unit_archive.used_dll));

  // (3) 結果の代入
  Result := nil;
end;

function nakofile_compress_pass(args: DWORD): PHiValue; stdcall;
var
  a, b: PHiValue;
  src, des, ext, pass: string;
begin
  // (1) 引数の取得
  pass := getArgStr(args, 0);
  a := nako_getFuncArg(args, 1);
  b := nako_getFuncArg(args, 2);

  src := hi_str(a);
  des := hi_str(b);
  ext := LowerCase( ExtractFileExt(des) );

  // (2) 処理
  unit_archive.ArchivePassword := pass;
  if ext = '.zip' then zip_compress(src, des) else
  if ext = '.7z' then zip_compress(src, des) else
  if ext = '.yz1' then yz1_compress(src, des) else
  raise Exception.Create('"'+ext+'"は未対応の圧縮形式です。');
  nako_reportDLL(PChar(unit_archive.used_dll));

  // (3) 結果の代入
  Result := nil;
end;

function nakofile_extract_pass(args: DWORD): PHiValue; stdcall;
var
  a, b: PHiValue;
  src, des, ext, pass: string;
begin
  // (1) 引数の取得
  pass := getArgStr(args, 0);
  a := nako_getFuncArg(args, 1);
  b := nako_getFuncArg(args, 2);
  // (2) 処理
  src := hi_str(a);
  des := hi_str(b);
  ext := LowerCase( ExtractFileExt(src) );

  if ExtractFileExt(des) = '' then
  begin
    des := CheckPathYen(des);
    ForceDirectories(des);
  end;

  dll_plugin_helper._getEmbedFile(src); // もし可能なら実行ファイルから取り出す

  // (2) 処理
  unit_archive.ArchivePassword := pass;
  if ext = '.zip' then zip_extract (src, des)  else
  if ext = '.7z' then zip_extract (src, des)  else
  if ext = '.yz1' then yz1_extract (src, des)  else
  raise Exception.Create('"'+ext+'"は未対応の圧縮形式です。');
  nako_reportDLL(PChar(unit_archive.used_dll));

  // (3) 結果の代入
  Result := nil;
end;


function nakofile_archive_command(args: DWORD): PHiValue; stdcall;
var
  ext, cmd: string;
begin
  // (1) 引数の取得
  ext := getArgStr(args, 0);
  cmd := getArgStr(args, 1);
  ext := LowerCaseEx(ext);
  if Copy(ext,1,1) <> '.' then ext := '.' + ext;
  // (2) 処理
  if ext = '.lzh' then UnlhaCommand(cmd)  else
  if ext = '.zip' then SevenZipCommand(cmd)  else
  if ext = '.7z' then SevenZipCommand(cmd)  else
  if ext = '.cab' then CabCommand(cmd)  else
  if ext = '.yz1' then Yz1Command(cmd)  else
  raise Exception.Create('"'+ext+'"は未対応の圧縮形式です。');

  // (3) 結果の代入
  Result := nil;
end;


function nakofile_makesfx(args: DWORD): PHiValue; stdcall;
var
  a, b: PHiValue;
begin
  // (1) 引数の取得
  a := nako_getFuncArg(args, 0);
  b := nako_getFuncArg(args, 1);

  // (2) 処理
  lha_makeSFX(hi_str(a), hi_str(b));

  // (3) 結果の代入
  Result := nil;
end;


// 出力のために
var outfile: TFileStream = nil;
var outfile_name: string = '';
function nakofile_set_outfile(args: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  Result := nil;
  FreeAndNil(outfile);
  s := getArgStr(args, 0, True);
  if s = '' then
  begin
    outfile_name := '';
    Exit;
  end;

  if not FileExists(s) then
  begin
    outfile := TFileStream.Create(s, fmCreate);
    outfile.Seek(0, soFromBeginning); // 最初に
  end else
  begin
    outfile := TFileStream.Create(s, fmOpenReadWrite);
    outfile.Seek(0, soFromEnd); // 最後に
  end;
  outfile_name := s;
end;
function nakofile_get_outfile(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(outfile_name);
end;
procedure check_outfile;
begin
  if outfile = nil then begin // 適当なファイルを作って出力とする
    outfile_name := DesktopDir + 'なでしこ出力.txt';
    outfile := TFileStream.Create(outfile_name, fmCreate);
  end;
end;
function nakofile_outfile_write(args: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  Result := nil;
  s := getArgStr(args, 0, True);
  check_outfile;
  if s <> '' then outfile.Write(s[1], Length(s));
end;
function nakofile_outfile_writeln(args: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  Result := nil;
  s := getArgStr(args, 0, True) + #13#10;
  check_outfile;
  if s <> '' then outfile.Write(s[1], Length(s));
end;
function nakofile_outfile_clear(args: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  outfile.Position := 0;
  outfile.Size := 0;
end;

//--- GET DIRECTORY FUNCTION
function nakofile_WinDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(WinDir);
end;
function nakofile_SysDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(SysDir);
end;
function nakofile_TempDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(TempDir);
end;
function nakofile_DesktopDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(DesktopDir);
end;
function nakofile_SendToDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(SendToDir);
end;
function nakofile_StartUpDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(StartUpDir);
end;
function nakofile_RecentDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(RecentDir);
end;
function nakofile_ProgramsDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(ProgramsDir);
end;
function nakofile_MyDocumentDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(MyDocumentDir);
end;
function nakofile_FavoritesDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(FavoritesDir);
end;
function nakofile_MyMusicDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(MyMusicDir);
end;
function nakofile_MyPictureDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(MyPictureDir);
end;
function nakofile_FontsDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(FontsDir);
end;
function nakofile_ProgramFilesDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(ProgramFilesDir);
end;

procedure RegistFunction;

  function RuntimeDir: string;
  begin
    Result := ExtractFilePath(ParamStr(0));
  end;

begin
  //todo 1: ■システム変数関数(FILE)
  //<ファイル変数関数>

  //+ファイル(nakofile.dll)
  //-ファイル名パス操作
  //AddFunc  ('ファイル名抽出', 'Sから|Sの',  20, nakofile_extractFile,'パスSからファイル名部分を抽出して返す。','ふぁいるめいちゅうしゅつ');
  //AddFunc  ('パス抽出',       'Sから|Sの',  21, nakofile_extractFilePath,'ファイル名Sからパス部分を抽出して返す。','ぱすちゅうしゅつ');
  //AddFunc  ('拡張子抽出',     'Sから|Sの',  22, nakofile_extractExt,'ファイル名Sから拡張子部分を抽出して返す。','かくちょうしちゅうしゅつ');
  //AddFunc  ('拡張子変更',     'SをAに|Sの', 23, nakofile_changeExt,'ファイル名Sの拡張子をAに変更して返す。','かくちょうしへんこう');
  //AddFunc  ('ユニークファイル名生成','AでBの|Aに', 24, nakofile_makeoriginalfile,'フォルダAでヘッダBをもつユニークなファイル名を生成して返す。','ゆにーくふぁいるめいせいせい');
  //AddFunc  ('相対パス展開',   'AをBで',     25, nakofile_expand_path,'相対パスＡを基本パスＢで展開して返す。','そうたいぱすてんかい');
  AddFunc  ('終端パス追加','{=?}Sの|Sで|Sに|Sから',525, nakofile_pathFlagAdd,  'フォルダ名の終端に「\」記号がなければつけて返す','しゅうたんぱすついか');
  AddFunc  ('終端パス削除','{=?}Sの|Sで|Sに|Sから',526, nakofile_pathFlagDel,  'フォルダ名の終端に「\」記号があれば削除して返す','しゅうたんぱすさくじょ');
  AddFunc  ('文字列ファイル名変換','{=?}Sの|Sを|Sで|Sから',527, nakofile_StrtoFileName,  '文字列をファイル名として使えるように変換して返す。','もじれつふぁいるめいへんかん');
  AddFunc  ('文字列UNIXファイル名変換','{=?}Sの|Sを|Sで|Sから',528, nakofile_StrtoFileNameUnix,  '文字列をファイル名として使えるように変換して返す。','もじれつふぁいるめいへんかん');
  //-開く保存
  AddFunc  ('保存','{文字列=?}SをFに|Fへ',             500, nakofile_saveAll,  '文字列Sの内容をファイル名Fへ保存する。','ほぞん');
  AddFunc  ('開く','{参照渡し 変数=?}VにFを|VへFから', 501, nakofile_loadAll,  '変数V(省略した場合は『それ』)にファイル名Fの内容を読み込む。','ひらく');
  AddFunc  ('読む','{参照渡し 変数=?}VにFを|VへFから', 502, nakofile_loadAll,  '変数V(省略した場合は『それ』)にファイル名Fの内容を読み込む。','よむ');
  AddFunc  ('追加保存','{文字列=?}SをFに|Fへ',         504, nakofile_saveAllAdd,'文字列Sの内容をファイル名Fへ追加保存する。','ついかほぞん');
  //-一行ずつ読み書き
  AddFunc  ('毎行読む','{参照渡し 変数=?}VにFを|VへFから', 503, nakofile_loadEveryLine,  '一行ずつ読むためにファイル名Fを開いてハンドルを返す。反復と組み合わせて使う。','まいぎょうよむ');
  AddFunc  ('出力先設定','Fに|Fへ', 505, nakofile_set_outfile,  '『出力』命令の出力先ファイルSを指定する。','しゅつりょくさきせってい');
  AddFunc  ('出力先取得','', 506, nakofile_get_outfile,  '『出力』命令の出力先ファイル名を取得する。','しゅつりょくさきしゅとく');
  SetSetterGetter('出力先ファイル','出力先設定','出力先取得',507,'『出力』命令の出力先ファイルを指定する。','しゅつりょくさきふぁいる');
  AddFunc  ('出力','Sを|Sと', 509, nakofile_outfile_write, '『出力先』で指定したファイルへ文字列S+改行を追記する(指定なしは「なでしこ出力.txt」へ出力)','しゅつりょく');
  AddFunc  ('一行出力','Sを|Sと', 508, nakofile_outfile_writeln, '『出力先』で指定したファイルへ文字列S+改行を追記する','いちぎょうしゅつりょく');
  AddFunc  ('出力先初期化','', 510, nakofile_outfile_clear, '『出力先』で指定したファイルを初期化する','しゅつりょくさきしょきか');

  //-起動
  AddFunc  ('起動','{文字列=?}PATHを',                      520, nakofile_exec, 'ファイルPATHを起動する。','きどう');
  AddFunc  ('起動待機','{文字列=?}PATHを',                  521, nakofile_exec_wait, 'ファイルPATHを起動して終了するまで待機する。','きどうたいき');
  AddFunc  ('秒間起動待機','{文字列=?}PATHをSEC',           677, nakofile_exec_wait_sec, 'ファイルPATHを起動してSEC秒間待機する。正常に終了すればはい(=1)を返す。時間内に終了しなければ、いいえ(=0)を返し処理を継続する。(起動したアプリの強制終了は行わない。)','びょうかんきどうたいき');
  AddFunc  ('エクスプローラー起動','{文字列=?}DIRで|DIRの|DIRを', 522, nakofile_exec_exp, 'フォルダDIRをエクスプローラーで起動する。','えくすぷろーらーきどう');
  AddFunc  ('隠し起動','{文字列=?}Sを', 523, nakofile_exec_open_hide, 'ファイルSを可視オフで起動する。','かくしきどう');
  AddFunc  ('隠し起動待機','{文字列=?}Sを', 524, nakofile_exec_wait_hide, 'ファイルSを可視オフで起動して終了まで待機する。','かくしきどうたいき');
  AddFunc  ('コマンド実行','{文字列=?}Sを', 675, nakofile_exec_command, 'ファイルSを可視オフで起動して終了まで待機する。起動したプログラムの標準出力の内容を返す。','こまんどじっこう');
  AddFunc  ('管理者権限実行','{文字列=?}Sを', 676, nakofile_exec_admin, 'ファイルSを管理者権限で起動する。','かんりしゃけんげんじっこう');
  //-フォルダ操作
  AddFunc  ('作業フォルダ変更','{文字列}Sに|Sへ',      530, nakofile_setCurDir, 'カレントディレクトリをSに変更する。','さぎょうふぉるだへんこう');
  AddFunc  ('作業フォルダ取得','',                     531, nakofile_getCurDir, 'カレントディレクトリを取得して返す。','さぎょうふぉるだしゅとく');
  SetSetterGetter('作業フォルダ', '作業フォルダ変更', '作業フォルダ取得', 537, 'カレントディレクトリの変更を行う。','さぎょうおふぉるだ');
  AddFunc  ('フォルダ作成','Sに|Sへ|Sの',              532, nakofile_makeDir,   'パスSにフォルダを作成する。','ふぉるださくせい');
  AddFunc  ('フォルダ削除','Sの|Sを|Sから',            559, nakofile_removeDir, 'パスSのフォルダを削除する。(フォルダは空でなくても良い)','ふぉるださくじょ');
  //-列挙・存在
  AddFunc  ('ファイル列挙','{文字列=?}Sの|Sを|Sで',   533, nakofile_enumFiles,'パスSにあるファイルを配列形式で返す。「;」で区切って複数の拡張子を指定可能。引数を省略するとカレントディレクトリのファイル一覧を返す。','ふぁいるれっきょ');
  AddFunc  ('フォルダ列挙','{文字列=?}Sの|Sを|Sで',   534, nakofile_enumDirs, 'パスSにあるフォルダを配列形式で返す。引数を省略するとカレントディレクトリのフォルダ一覧を返す。','ふぉるだれっきょ');
  AddFunc  ('存在','Sが|Sの',       535, nakofile_FileExists, 'パスSにファイルかフォルダが存在するか確認してはい(=1)かいいえ(=0)で返す','そんざい');
  AddFunc  ('全ファイル列挙','{文字列=?}Sの|Sを|Sで', 536, nakofile_enumAllFiles,'パスSにあるファイルをサブフォルダも含め配列形式で返す。「;」で区切って複数の拡張子を指定可能。','ぜんふぁいるれっきょ');
  AddFunc  ('全フォルダ列挙','{文字列=?}Sの|Sを|Sで', 680, nakofile_enumAllDir,'パスSにあるフォルダも再帰的に検索して配列形式で返す。','ぜんふぉるだれっきょ');
  AddFunc  ('全ファイル相対パス列挙','{文字列=?}Sの|Sを|Sで', 679, nakofile_enumAllFilesRelative,'パスSにあるファイルをサブフォルダを含めて（パスSからの相対指定で）配列形式で返す。','ぜんふぁいるそうたいぱすれっきょ');
  AddStrVar('ファイル列挙オプション','タイトル経過表示', 691, '全が付くファイル列挙のオプション(タイトル経過表示|経過表示なし)','ふぁいるれっきょおぷしょん');


  //-コピー移動削除
  AddFunc  ('ファイルコピー','AからBへ|AをBに',540,nakofile_fileCopy,  'ファイルAからBへコピーする。','ふぁいるこぴー');
  AddFunc  ('ファイル移動',  'AからBへ|AをBに',541,nakofile_fileRename,  'ファイルAからBへ移動する。','ふぁいるいどう');
  AddFunc  ('ファイル削除',  'Aを|Aの',        542,nakofile_fileDelete,'ファイルAを削除する(ゴミ箱へ移動)。','ふぁいるさくじょ');
  AddFunc  ('ファイル名変更','AからBへ|AをBに',543,nakofile_fileRename,'ファイル名AからBへ変更する。','ふぁいるめいへんこう');
  AddFunc  ('フォルダコピー','AからBへ|AをBに',544,nakofile_dirCopy,   'フォルダAからBへコピーする。','ふぉるだこぴー');
  AddFunc  ('ファイル完全削除', 'Aを|Aの',     545,nakofile_fileDeleteAll,'ファイルAを完全に削除する。(ゴミ箱へ移動しない)','ふぁいるかんぜんさくじょ');
  AddFunc  ('ファイル抽出コピー', 'AからBへ|AをBに',546,nakofile_fileCopyEx,'フォルダA(パス+ワイルドカードリスト「;」で区切る)からフォルダBへ任意のファイルのみをコピーする','ふぁいるちゅうしゅつこぴー');
  AddStrVar('ファイル抽出コピー除外パターン','Thumbs.db',547,'ファイル抽出コピーで除外するパターンを一行ごとワイルドカードで指定する。','ふぁいるちゅうしゅつこぴーじょがいぱたーん');
  //-ショートカット
  AddFunc  ('ショートカット作成','AをBへ|AのBに', 555, nakofile_shortcut,'アプリケーションAのショートカットをBに作る','しょーとかっとさくせい');
  AddFunc  ('ショートカット詳細作成','AをBへCで|AのBに', 553, nakofile_shortcut_ex,'アプリケーションAのショートカットをBにハッシュCの設定で作る','しょーとかっとしょうさいさくせい');
  AddFunc  ('ショートカットリンク先取得','Aの', 554, nakofile_get_shortcut,'ショートカットAのリンク先を取得する。','しょーとかっとりんくさきしゅとく');
  //-ファイル情報
  AddFunc  ('ファイルサイズ','Fの',           556, nakofile_getFileSize,'ファイルFのサイズを返す','ふぁいるさいず');
  AddFunc  ('ファイル日付','Fの',             557, nakofile_getFileDate,'ファイルFの日付を返す','ふぁいるひづけ');
  AddFunc  ('ファイル作成日時','Fの',         621, nakofile_getCreateFileDate,'ファイルFの作成日時を返す','ふぁいるさくせいにちじ');
  AddFunc  ('ファイル更新日時','Fの',         622, nakofile_getWriteFileDate,'ファイルFの更新日時を返す','ふぁいるこうしんにちじ');
  AddFunc  ('ファイル最終アクセス日時','Fの', 623, nakofile_getLastAccessFileDate,'ファイルFの最終アクセス日時を返す','ふぁいるさいしゅうあくせすにちじ');
  AddFunc  ('ファイル作成日時変更','{=?}FをSに|Sへ',  624, nakofile_setFileDateCreate,'ファイルFの作成日時をSに設定する','ふぁいるさくせいにちじへんこう');
  AddFunc  ('ファイル更新日時変更','{=?}FをSに|Sへ',  625, nakofile_setFileDateWrite,'ファイルFの更新日時をSに設定する','ふぁいるこうしんにちじへんこう');
  AddFunc  ('ファイル最終アクセス日時変更','{=?}FをSに|Sへ',  626, nakofile_setFileDateLastAccess,'ファイルFの最終アクセス日時をSに設定する','ふぁいるさいしゅうあくせすにちじへんこう');
  AddFunc  ('ファイル属性取得','{=?}Fの',         627, nakofile_getFileAttr,'ファイルFの属性を取得する','ふぁいるぞくせいしゅとく');
  AddFunc  ('ファイル属性設定','{=?}FをSに|Sへ',  628, nakofile_setFileAttr,'ファイルFの属性を設定する','ふぁいるぞくせいせってい');
  AddIntVar('アーカイブ属性',   $20,  640, 'ファイル属性','あーかいぶぞくせい');
  AddIntVar('ディレクトリ属性', $10,  641, 'ファイル属性','でぃれくとりぞくせい');
  AddIntVar('隠しファイル属性', $2,   642, 'ファイル属性','かくしふぁいるぞくせい');
  AddIntVar('読み込み専用属性', $1,   643, 'ファイル属性','よみこみせんようぞくせい');
  AddIntVar('システムファイル属性',$4,644, 'ファイル属性','しすてむふぁいるぞくせい');
  AddIntVar('ノーマル属性',     $80,  645, 'ファイル属性','のーまるぞくせい');
  AddFunc  ('フォルダ存在','{=?}Fの',  639, nakofile_ExistsDir,'フォルダFが存在するのか調べて、はい(=1)かいいえ(=0)で返す。','ふぉるだそんざい');
  AddFunc  ('長いファイル名取得','{=?}Fの',  673, nakofile_getLongFileName,'長いファイル名(ロングファイル)を返す。','ながいふぁいるめいしゅとく');
  AddFunc  ('短いファイル名取得','{=?}Fの',  674, nakofile_getShortFileName,'短いファイル名(ショートファイル)を返す。','みじかいふぁいるめいしゅとく');

  //-ドライブ情報
  AddFunc  ('使用可能ドライブ取得','',646, nakofile_getLogicalDrives,'使用可能ドライブの一覧を得る','しようかのうどらいぶしゅとく');
  AddFunc  ('ドライブ種類','{=?}Aの',647, nakofile_getDriveType,'ルートドライブＡの種類(不明|存在しない|取り外し可能|固定|ネットワーク|CD-ROM|RAM)を返す。','どらいぶしゅるい');
  AddFunc  ('ディスクサイズ','{=?}Aの',648, nakofile_getDiskSize,'ディスクＡの全体のバイト数を返す。','でぃすくさいず');
  AddFunc  ('ディスク空きサイズ','{=?}Aの',649, nakofile_getDiskFreeSize,'ディスクＡの利用可能空きバイト数を返す。','でぃすくあきさいず');
  AddFunc  ('ボリューム名取得','{=?}Aの',665, nakofile_getVolumeName,'ディスクＡのボリューム名を返す。','ぼりゅーむめいしゅとく');
  AddFunc  ('ディスクシリアル番号取得','{=?}Aの',666, nakofile_getSerialNo,'ディスクＡのシリアル番号を返す。','でぃすくしりあるばんごうしゅとく');
  AddFunc  ('ハードウェア取り外し起動','',672, nakofile_showHotplugDlg,'ハードウェア取り外しダイアログを表示する','はーどうぇあとりはずしきどう');

  //-コンソール
  //AddFunc  ('標準入力取得','CNTの', 558, nil,'CNTバイトの標準入力を取得する(コンソールのみ)','ひょうじゅんにゅうりょくしゅとく');
  //-ストリーム操作
  AddFunc  ('ファイルストリーム開く',  'AをBで',   561, nakofile_file_h_open,  'ファイル名AをモードB(作|読|書|排他)でストリームを開きハンドルを返す。','ふぁいるすとりーむひらく');
  AddFunc  ('ファイルストリーム読む',  'HでCNTを', 562, nakofile_file_h_read,  'ファイルストリームハンドルHでCNTバイト読んで返す。','ふぁいるすとりーむよむ');
  AddFunc  ('ファイルストリーム書く',  'HでSを',   563, nakofile_file_h_write, 'ファイルストリームハンドルHに(Sのバイト数分)文字列Sを書く。何も返さない。','ふぁいるすとりーむかく');
  AddFunc  ('ファイルストリーム閉じる','Hを',      564, nakofile_file_h_close, 'ファイルストリームハンドルHを閉じる。','ふぁいるすとりーむとじる');
  AddFunc  ('ファイルストリーム位置取得','Hの',    565, nakofile_file_h_getpos,'ファイルストリームハンドルHの位置を取得する','ふぁいるすとりーむいちしゅとく');
  AddFunc  ('ファイルストリーム位置設定','HでIに', 566, nakofile_file_h_setpos,'ファイルストリームハンドルHの位置をIに設定する','ふぁいるすとりーむいちせってい');
  AddFunc  ('ファイルストリームサイズ','Hの',  567, nakofile_file_h_size,  'ファイルストリームハンドルHで開いたファイルのサイズを返す','ふぁいるすとりーむさいず');
  AddFunc  ('ファイルストリーム一行読む',  'Hで|Hの', 568, nakofile_file_h_readLine,  'ファイルストリームハンドルHで一行読んで返す。','ふぁいるすとりーむいちぎょうよむ');
  AddFunc  ('ファイルストリーム一行書く',  '{=?}SをHに|Hで|Hへ', 569, nakofile_file_h_writeLine,  'ファイルストリームハンドルHへSを一行書く','ふぁいるすとりーむいちぎょうかく');
  //-更新
  AddFunc  ('関連付け反映','',575, nakofile_shell_association, '関連付けを変更した時、変更をシェルに伝える。','かんれんづけはんえい');
  AddFunc  ('フォルダ内容反映','{=?}DIRの',576, nakofile_shell_updatedir, 'フォルダDIRの内容が変更を反映させる。','ふぉるだないようはんえい');


  //+圧縮解凍(nakofile.dll)
  //-圧縮解凍
  AddFunc('圧縮','AをBへ|AからBに', 570, nakofile_compress, 'パスAをファイルBへ圧縮する。','あっしゅく','7-zip32.dll,UNLHA32.DLL');
  AddFunc('解凍','AをBへ|AからBに', 571, nakofile_extract, 'ファイルAをパスBへ解凍する。','かいとう','7-zip32.dll,UNLHA32.DLL');
  AddFunc('自己解凍書庫作成','AをBへ|Aから', 572, nakofile_makesfx, 'パスAをファイルBへ自己解凍書庫を作成する','じこかいとうしょこさくせい','7-zip32.dll,UNLHA32.DLL');
  AddFunc('圧縮解凍実行','TYPEのCMDを|CMDで', 573, nakofile_archive_command, 'TYPE(拡張子)でアーカイバDLLへコマンドCMDを直接実行する','あっしゅくかいとうじっこう','7-zip32.dll,UNLHA32.DLL');
  AddFunc('パスワード付圧縮','PASSでAをBへ|AからBに', 574, nakofile_compress_pass, 'パスワードPASSを利用してパスAをファイルBへ圧縮する。(ZIP/YZ1ファイルのみ対応)','ぱすわーどつきあっしゅく','');
  AddFunc('パスワード付解凍','PASSでAをBへ|AからBに', 577, nakofile_extract_pass, 'パスワードPASSを利用してファイルAをパスBへ解凍する。(ZIP/YZ1ファイルのみ対応)','ぱすわーどつきかいとう','');

  //+特殊フォルダ(nakofile.dll)
  //-パス
  AddFunc  ('WINDOWSパス',  '',                 600, nakofile_WinDir,'Windowsのインストールパスを返す','WINDOWSぱす');
  AddFunc  ('SYSTEMパス',   '',                 601, nakofile_SysDir,'Systemフォルダのパスを返す','SYSTEMぱす');
  AddFunc  ('テンポラリフォルダ', '',           602, nakofile_TempDir,'作業用のテンポラリフォルダのパスを得て返す','てんぽらりふぉるだ');
  AddFunc  ('デスクトップ',       '',           603, nakofile_DesktopDir,'デスクトップのフォルダのパスを返す','ですくとっぷ');
  AddFunc  ('SENDTOパス',         '',           604, nakofile_SendToDir,'「送る」メニューのフォルダのパスを返す','SENDTOぱす');
  AddFunc  ('スタートアップ',     '',           605, nakofile_StartUpDir,'Windowsを起動した時に自動的に実行する「スタートアップ」のフォルダパスを返す','すたーとあっぷ');
  AddFunc  ('RECENTパス',        '',            606, nakofile_RecentDir,'','RECENTぱす');
  AddFunc  ('スタートメニュー',  '',            607, nakofile_ProgramsDir,'スタートメニュー\プログラムのフォルダのパス返す','すたーとめにゅー');//スタートメニュー\プログラム\
  AddFunc  ('マイドキュメント',  '',            608, nakofile_MyDocumentDir, 'マイドキュメントのフォルダのパスを返す','まいどきゅめんと');
  AddFunc  ('FAVORITESパス',     '',            609, nakofile_FavoritesDir,'','FAVORITESぱす');
  AddFunc  ('お気入りフォルダ',  '',            610, nakofile_FavoritesDir,'','おきにいりふぉるだ');
  AddFunc  ('マイミュージック',  '',            612, nakofile_MyMusicDir,'','まいみゅーじっく');
  AddFunc  ('マイピクチャー',    '',            613, nakofile_MyPictureDir,'','まいぴくちゃー');
  AddFunc  ('マイピクチャ',      '',            669, nakofile_MyPictureDir,'','まいぴくちゃ');
  AddFunc  ('フォントパス',      '',            614, nakofile_FontsDir,'','ふぉんとぱす');
  AddFunc  ('PROGRAMFILESパス',  '',            615, nakofile_ProgramFilesDir,'','PROGRAMFILESぱす');
  AddFunc  ('OE5メールフォルダ',  '',           618, nakofile_getOE5,'Outlook Express5/6のメールが保存されているフォルダを取得して返す','OE5めーるふぉるだ');
  AddFunc  ('BECKY2メールフォルダ','',          619, nakofile_getBecky2,'Becky!Ver.2のメールが保存されているフォルダを取得して返す','Becky2めーるふぉるだ');
  AddFunc  ('環境変数展開','{=?}Sの|Sを|Sで',   620, nakofile_expandEnv,'「%UserProfiel%aaa\bbb」のような環境変数を含むパスを展開して返す','かんきょうへんすうてんかい');
  AddFunc  ('特殊パス取得','{=?}Aの|Aを',       660, nakofile_sp_path,'特殊パス(CSIDL_xxx)Aを指定して特殊パスを調べて返す','とくしゅぱすしゅとく');
  AddFunc  ('共通スタートアップ','',            661, get_CSIDL_COMMON_STARTUP,'','きょうつうすたーとあっぷ');
  AddFunc  ('共通デスクトップ','',              662, get_CSIDL_COMMON_DESKTOPDIRECTORY,'','きょうつうですくとっぷ');
  AddFunc  ('共通マイドキュメント','',          663, get_CSIDL_COMMON_DOCUMENTS,'','きょうつうまいどきゅめんと');
  AddFunc  ('共通設定フォルダ','',              611, get_CSIDL_COMMON_APPDATA,'共通のAPPDATAフォルダ','きょうつうせっていふぉるだ');
  AddFunc  ('個人設定フォルダ','',              664, get_CSIDL_LOCAL_APPDATA,'ユーザーごとのAPPDATAフォルダ','こじんせっていふぉるだ');
  AddFunc  ('ユーザーホームフォルダ','',        659, get_USER_PROFILE,'%USERPROFILE%','ゆーざーほーむふぉるだ');
  AddFunc  ('アプリ設定フォルダ','',            638, get_APPDATA,'%APPDATA%','あぷりせっていふぉるだ');
  AddFunc  ('送るメニューフォルダ','',          637, get_SENDTO,'送るメニューのパス','おくるめにゅーふぉるだ');
  AddFunc  ('クイック起動フォルダ','',          629, get_QUICKLAUNCH,'送るメニューのパス','くいっくきどうふぉるだ');
  AddFunc  ('COMSPEC','',                       667, get_COMSPEC,'シェル(CMD.EXE)の種類','COMSPEC');
  AddFunc  ('システムドライブ','',              668, get_SYSTEMDRIVE,'Windowsがインストールされているドライブを返す','しすてむどらいぶ');
  //-なでしこパス
  AddStrVar('ランタイムパス',{''}RuntimeDir, 616, 'なでしこの実行ファイルのパス','らんたいむぱす');
  AddStrVar('母艦パス',{''}'', 617, '実行したプログラムのパス','ぼかんぱす');

  //-nakofile.dll
  AddFunc  ('NAKOFILE_DLLバージョン','', 690, getNakoFileDllVersion,'nakofile.dllのバージョンを得る','NAKOFILE_DLLばーじょん');
  //</ファイル変数関数>

end;



{ THiSystemDummy }

constructor THiSystemDummy.Create;
begin
end;

function THiSystemDummy.mixReader: TFileMixReader;
begin
  FileMixReader := TFileMixReader(nako_getPackFileHandle);
  Result := FileMixReader;
end;

function THiSystemDummy.Sore: PHiValue;
begin
  Result := nako_getSore;
end;



initialization
  begin
    OleInitialize(nil);
    outfile := nil;
    HiSystem := THiSystemDummy.Create;
  end;

finalization
  begin
    OleUninitialize;
    FreeAndNil(outfile);
    FreeAndNil(HiSystem);
  end;


  
end.
