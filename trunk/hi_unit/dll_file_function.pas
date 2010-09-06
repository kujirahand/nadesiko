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
  s: THMemoryStream;
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

function sys_saveAll(args: DWORD): PHiValue; stdcall;
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

function sys_saveAllAdd(args: DWORD): PHiValue; stdcall;
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

function sys_loadAll(args: DWORD): PHiValue; stdcall;
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

function sys_loadEveryLine(args: DWORD): PHiValue; stdcall;
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

function sys_CloseEveryLine(args: DWORD): PHiValue; stdcall;
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

function sys_pathFlagAdd(args: DWORD): PHiValue; stdcall;
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

function sys_pathFlagDel(args: DWORD): PHiValue; stdcall;
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

function sys_StrtoFileName(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue; str, ret: string;
  i: Integer;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s = nil then s := nako_getSore;
(*
$　　#　　%　　@　　!　　^
-(マイナス記号)　　_(アンダ－スコア)
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


function sys_StrtoFileNameUnix(args: DWORD): PHiValue; stdcall;
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

function sys_exec(args: DWORD): PHiValue; stdcall;
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


function sys_exec_wait(args: DWORD): PHiValue; stdcall;
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

function sys_exec_wait_sec(args: DWORD): PHiValue; stdcall;
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


function sys_exec_open_hide(args: DWORD): PHiValue; stdcall;
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


function sys_exec_wait_hide(args: DWORD): PHiValue; stdcall;
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

function sys_exec_command(args: DWORD): PHiValue; stdcall;
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

function sys_exec_admin(args: DWORD): PHiValue; stdcall;
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

function sys_exec_exp(args: DWORD): PHiValue; stdcall;
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

function sys_setCurDir(args: DWORD): PHiValue; stdcall;
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

function sys_getCurDir(args: DWORD): PHiValue; stdcall;
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

function sys_makeDir(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  a: string;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  // (2) データの処理
  try
    a := hi_str(s);
    if Pos('\', a) > 0  then ForceDirectories(a)
                        else MkDir(a);
  except on e: Exception do
    raise Exception.Create('フォルダ『' + hi_str(s) + '』が作成できません。理由は,' + e.Message);
  end;
  // (3) 戻り値を設定
  Result := nil;
end;

function sys_removeDir(args: DWORD): PHiValue; stdcall;
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


function sys_enumFiles(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  path, f: string;
  g: THStringList;
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

function sys_enumAllFiles(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  path: string;
  g: THStringList;
  i: Integer;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then path := CheckPathYen( GetCurrentDir )
           else path := hi_str(s);

  // (2) データの処理
  unit_file.MainWindowHandle := nako_getMainWindowHandle;
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

function sys_enumAllFilesRelative(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  tmp, path, basepath: AnsiString;
  g: THStringList;
  i,len: Integer;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then path := CheckPathYen( GetCurrentDir )
           else path := hi_str(s);

  // (2) データの処理
  unit_file.MainWindowHandle := nako_getMainWindowHandle;
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

function sys_enumAllDir(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  path: string;
  g: THStringList;
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


function sys_enumDirs (args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  path, n: string;
  g: THStringList;
  i: Integer;
begin
  Result := hi_var_new;
  nako_ary_create(Result);

  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s=nil then path := CheckPathYen( GetCurrentDir )
           else path := hi_str(s);

  if Copy(path, Length(path), 1) = '\' then path := path + '*';

  // (2) データの処理
  g := EnumDirs(path);
  for i := 0 to g.Count - 1 do
  begin
    n := g.Strings[i];
    // (3) 戻り値を設定
    nako_ary_add(Result, hi_newStr(n));
  end;

end;

function sys_FileExists (args: DWORD): PHiValue; stdcall;
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

function sys_ExistsDir (args: DWORD): PHiValue; stdcall;
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

function sys_getLongFileName(args: DWORD): PHiValue; stdcall;
var
  fname: string;
begin
  fname := getArgStr(args, 0, True);
  Result := hi_newStr(ShortToLongFileName(fname));
end;
function sys_getShortFileName(args: DWORD): PHiValue; stdcall;
var
  fname: string;
begin
  fname := getArgStr(args, 0, True);
  Result := hi_newStr(LongToShortFileName(fname));
end;


function sys_fileCopy(args: DWORD): PHiValue; stdcall;
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

function sys_fileCopyEx(args: DWORD): PHiValue; stdcall;
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

function sys_dirCopy(args: DWORD): PHiValue; stdcall;
var
  a, b: PHiValue;
  sa,sb: string;
begin

  // (1) 引数の取得
  a := nako_getFuncArg(args, 0);
  b := nako_getFuncArg(args, 1);
  sa := hi_str(a);
  sb := hi_str(b);
  if Copy(sa,Length(sa),1) = '\' then System.Delete(sa,Length(sa),1);
  if Copy(sb,Length(sb),1) = '\' then System.Delete(sb,Length(sb),1);

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

function sys_fileRename(args: DWORD): PHiValue; stdcall;
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

function sys_fileDelete(args: DWORD): PHiValue; stdcall;
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

function sys_fileDeleteAll(args: DWORD): PHiValue; stdcall;
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


procedure RegSetRoot(r: TRegistry; hiv: string);
begin
  if hiv = 'HKEY_CLASSES_ROOT'  then r.RootKey := HKEY_CLASSES_ROOT else
  if hiv = 'HKEY_CURRENT_USER'  then r.RootKey := HKEY_CURRENT_USER else
  if hiv = 'HKEY_LOCAL_MACHINE' then r.RootKey := HKEY_LOCAL_MACHINE else
  if hiv = 'HKEY_USERS'         then r.RootKey := HKEY_USERS else
  if hiv = 'HKEY_PERFORMANCE_DATA'  then r.RootKey := HKEY_PERFORMANCE_DATA else
  if hiv = 'HKEY_CURRENT_CONFIG'    then r.RootKey := HKEY_CURRENT_CONFIG else
  if hiv = 'HKEY_DYN_DATA'    then r.RootKey := HKEY_DYN_DATA       else
  raise Exception.Create('レジストリパス"'+hiv+'"は開けません。');
end;

function sys_registry_open(args: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
  r: TRegistry;
  path: string;
  hiv: string;
begin
  a := nako_getFuncArg(args, 0);

  path := hi_str(a);
  hiv  := getToken_s(path, '\'); path := '\'+ path;

  r := TRegistry.Create;

  RegSetRoot(r, hiv);
  r.OpenKey(path, True);

  Result := hi_var_new;
  hi_setInt(Result, Integer(r));
end;

function sys_registry_write(args: DWORD): PHiValue; stdcall;
var
  h,s,a: PHiValue;
  r: TRegistry;
begin
  //HでSのAを
  h := nako_getFuncArg(args, 0);
  s := nako_getFuncArg(args, 1);
  a := nako_getFuncArg(args, 2);

  r := TRegistry(hi_int(h));
  r.WriteString(hi_str(s), hi_str(a));

  Result := nil;
end;

function sys_reg_easy_write(args: DWORD): PHiValue; stdcall;
var
  key, hiv, value, s: string;
  r: TRegistry;
begin
  // KEYのVにSを
  key   := getArgStr(args, 0, True);
  value := getArgStr(args, 1);
  s     := getArgStr(args, 2);
  //
  r := TRegistry.Create;
  try
    hiv := GetToken('\', key); key := '\' + key;
    RegSetRoot(r, hiv);
    if r.OpenKey(key, True) then
    begin
      r.WriteString(value, s);
    end;
  finally
    r.Free;
  end;
  Result := nil;
end;

function sys_reg_easy_read(args: DWORD): PHiValue; stdcall;
var
  key, hiv, value, s: string;
  r: TRegistry;
begin
  // KEYのVから
  key   := getArgStr(args, 0, True);
  value := getArgStr(args, 1);
  s     := getArgStr(args, 2);
  //
  Result := nil;
  r := TRegistry.Create;
  try
    hiv := GetToken('\', key); key := '\' + key;
    RegSetRoot(r, hiv);
    if r.OpenKey(key, False) then
    begin
      Result := hi_newStr(r.ReadString(value));
    end;
  finally
    r.Free;
  end;
end;

function sys_registry_writeInt(args: DWORD): PHiValue; stdcall;
var
  h,s,a: PHiValue;
  r: TRegistry;
begin
  //HでSのAを
  h := nako_getFuncArg(args, 0);
  s := nako_getFuncArg(args, 1);
  a := nako_getFuncArg(args, 2);

  r := TRegistry(hi_int(h));
  r.WriteInteger(hi_str(s), hi_int(a));

  Result := nil;
end;

function sys_registry_deleteKey(args: DWORD): PHiValue; stdcall;
var
  h,s: PHiValue;
  r: TRegistry;
begin
  //HでSの
  h := nako_getFuncArg(args, 0);
  s := nako_getFuncArg(args, 1);

  r := TRegistry(hi_int(h));
  r.DeleteKey(hi_str(s));

  Result := nil;
end;

function sys_registry_deleteVal(args: DWORD): PHiValue; stdcall;
var
  h,s: PHiValue;
  r: TRegistry;
begin
  //HでSの
  h := nako_getFuncArg(args, 0);
  s := nako_getFuncArg(args, 1);

  r := TRegistry(hi_int(h));
  r.DeleteValue(hi_str(s));

  Result := nil;
end;

function sys_registry_EnumKeys(args: DWORD): PHiValue; stdcall;
var
  h: PHiValue;
  r: TRegistry;
  sl: TStringList;
begin
  //HでSの
  h := nako_getFuncArg(args, 0);

  r := TRegistry(hi_int(h));
  sl := TStringList.Create;
  r.GetKeyNames(sl);

  Result := hi_newStr(sl.Text);
  sl.Free;
end;

function sys_registry_EnumValues(args: DWORD): PHiValue; stdcall;
var
  h: PHiValue;
  r: TRegistry;
  sl: TStringList;
begin
  //HでSの
  h := nako_getFuncArg(args, 0);

  r := TRegistry(hi_int(h));
  sl := TStringList.Create;
  r.GetValueNames(sl);

  Result := hi_newStr(sl.Text);
  sl.Free;
end;

function sys_registry_KeyExists(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  r: TRegistry;
  path, hiv: string;
begin
  s := nako_getFuncArg(args, 0);

  path := hi_str(s);
  hiv  := getToken_s(path, '\'); path := '\'+ path;

  r := TRegistry.Create;
  try
    RegSetRoot(r, hiv);
    Result := hi_var_new;
    hi_setBool(Result, r.KeyExists(path));
  finally
    r.Free;
  end;
end;

function sys_SHChangeNotify(args: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  SHChangeNotify(
    SHCNE_ASSOCCHANGED,
    SHCNF_FLUSHNOWAIT,
    nil,
    nil);
end;


const
  KEY_TILE_WALLPAPER  = 'TileWallpaper';
  KEY_STYLE_WALLPAPER = 'WallpaperStyle';

function sys_ChangeWallpaper(args: DWORD): PHiValue; stdcall;
var
  fname: string;
begin
  Result := nil;
  // ---
  fname := getArgStr(args, 0, True);
  if fname = '' then fname := #0;
  // wallpaper
  SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, PChar(fname),
    SPIF_UPDATEINIFILE or SPIF_SENDWININICHANGE);
end;

function sys_ChangeWallpaperStyle(args: DWORD): PHiValue; stdcall;
var
  pat, fname: string;
  reg: TRegistry;
begin
  Result := nil;
  // ---
  pat := getArgStr(args, 0, True);
  // ---
  //***HKEY_CURRENT_USER\Control Panel\Desktop
  // style
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey('Control Panel\Desktop',False);
    if pat = '中央' then
    begin
      reg.WriteString(KEY_TILE_WALLPAPER,  '0');
      reg.WriteString(KEY_STYLE_WALLPAPER, '0');
    end else
    if pat = 'タイル' then
    begin
      reg.WriteString(KEY_TILE_WALLPAPER,  '1');
      reg.WriteString(KEY_STYLE_WALLPAPER, '0');
    end else
    if pat = '拡大' then
    begin
      reg.WriteString(KEY_TILE_WALLPAPER,  '0');
      reg.WriteString(KEY_STYLE_WALLPAPER, '2');
    end else
    begin
      // 中央
      reg.WriteString(KEY_TILE_WALLPAPER,  '0');
      reg.WriteString(KEY_STYLE_WALLPAPER, '0');
    end;
    fname := reg.ReadString('Wallpaper');
    if fname = '' then fname := #0;
    // wallpaper
    SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, PChar(fname),
      SPIF_UPDATEINIFILE or SPIF_SENDWININICHANGE);

  finally
    reg.Free;
  end;
end;


function sys_getWallpaper(args: DWORD): PHiValue; stdcall;
var
  fname: string;
  reg: TRegistry;
begin

  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey('Control Panel\Desktop',False);
    fname := reg.ReadString('Wallpaper');
    Result := hi_newStr(fname);

  finally
    reg.Free;
  end;
end;


function sys_getWallpaperStyle(args: DWORD): PHiValue; stdcall;
var
  s, pat, tile, style: string;
  reg: TRegistry;
begin

  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey('Control Panel\Desktop',False);

    tile  := reg.ReadString(KEY_TILE_WALLPAPER);
    style := reg.ReadString(KEY_STYLE_WALLPAPER);

    s := tile + style;
    if s = '00' then pat := '中央'    else
    if s = '10' then pat := 'タイル'  else
    if s = '02' then pat := '拡大'    else pat := '中央';

    Result := hi_newStr(pat);

  finally
    reg.Free;
  end;
end;

function sys_registry_read(args: DWORD): PHiValue; stdcall;
var
  h, s: PHiValue;
  r: TRegistry;
begin
  //HでSの
  h := nako_getFuncArg(args, 0);
  s := nako_getFuncArg(args, 1);

  r := TRegistry(hi_int(h));

  Result := hi_var_new;
  hi_setStr(Result, r.ReadString(hi_str(s)));
end;

function sys_registry_readInt(args: DWORD): PHiValue; stdcall;
var
  h, s: PHiValue;
  r: TRegistry;
begin
  //HでSの
  h := nako_getFuncArg(args, 0);
  s := nako_getFuncArg(args, 1);

  r := TRegistry(hi_int(h));
  Result := hi_var_new;
  hi_setInt(Result, r.ReadInteger(hi_str(s)));
end;


function sys_registry_read_bin(args: DWORD): PHiValue; stdcall;
var
  h: Integer;
  s, buf: string;
  cnt: Integer;
  r: TRegistry;
begin
  //H, S, CNT
  h   := getArgInt(args, 0, True);
  s   := getArgStr(args, 1, False);
  cnt := getArgInt(args, 2, False);
  //
  SetLength(buf, cnt);
  //
  r := TRegistry(Pointer(h));
  r.ReadBinaryData(s, buf[1], cnt);
  //
  Result := hi_newStr(buf);
end;
function sys_registry_write_bin(args: DWORD): PHiValue; stdcall;
var
  h   : Integer;
  s   : string;
  v   : string;
  cnt : Integer;
  r   : TRegistry;
begin
  // HでSにVをCNTで
  h   := getArgInt(args, 0, True);
  s   := getArgStr(args, 1, False);
  v   := getArgStr(args, 2, False);
  cnt := getArgInt(args, 3, False);
  //
  if (Length(v) < cnt) then
  begin
    cnt := Length(v);
  end;
  //
  Result := nil;
  r := TRegistry(Pointer(h));
  r.WriteBinaryData(s, v[1], cnt);
end;


function sys_registry_close(args: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
  r: TRegistry;
begin
  a := nako_getFuncArg(args, 0);

  r := TRegistry(hi_int(a));
  r.CloseKey;
  r.Free;

  Result := nil;
end;

function sys_shortcut(args: DWORD): PHiValue; stdcall;
var
  a, b: PHiValue;
begin
  a := nako_getFuncArg(args, 0);
  b := nako_getFuncArg(args, 1);
  CreateShortCut(hi_str(b), hi_str(a), '', '', ws2Normal);
  Result := nil;
end;

function sys_shortcut_ex(args: DWORD): PHiValue; stdcall;
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

function sys_get_shortcut(args: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := nako_getFuncArg(args, 0);
  Result := hi_newStr(GetShortCutLink(hi_str(a)));
end;


function sys_ini_open(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue; ss: string;
  i: TIniFile;
begin
  // 1)引数
  s := nako_getFuncArg(args, 0);

  // パスが省略されたら、母艦パスにする
  ss := hi_str(s);
  dll_plugin_helper._getEmbedFile(ss); // もし可能なら実行ファイルから取り出す

  if ExtractFileDrive(ss) = '' then
  begin
    if not FileExists(ExpandFileName(WinDir + ss)) then
      ss :=ExpandFileName(hi_str(nako_getVariable('母艦パス')) + ss);
  end;

  // 2)INI
  i := TIniFile.Create(ss);
  // 3)結果
  Result := hi_newInt(Integer(i));
end;
function sys_ini_close(args: DWORD): PHiValue; stdcall;
var
  h: PHiValue;
begin
  // 1)引数
  h := nako_getFuncArg(args, 0);
  // 2)INI
  TIniFile(hi_int(h)).Free;
  // 3)結果
  Result := nil;
end;
function sys_ini_read(args: DWORD): PHiValue; stdcall;
var
  h,a,b: PHiValue;
  s: string;
begin
  // 1)引数
  h := nako_getFuncArg(args, 0);
  a := nako_getFuncArg(args, 1);
  b := nako_getFuncArg(args, 2);
  // 2)INI
  s := TIniFile(hi_int(h)).ReadString(hi_str(a),hi_str(b), '');
  // 3)結果
  Result := hi_newStr(s);
end;
function sys_ini_write(args: DWORD): PHiValue; stdcall;
var
  h,a,b,s: PHiValue;
begin
  // 1)引数
  h := nako_getFuncArg(args, 0);
  a := nako_getFuncArg(args, 1);
  b := nako_getFuncArg(args, 2);
  s := nako_getFuncArg(args, 3);
  // 2)INI
  TIniFile(hi_int(h)).WriteString(hi_str(a),hi_str(b),hi_str(s));
  // 3)結果
  Result := nil;
end;

function sys_sp_path(args: DWORD): PHiValue; stdcall;
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



function sys_getOE5(args: DWORD): PHiValue; stdcall;
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



function sys_getBecky2(args: DWORD): PHiValue; stdcall;
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

function sys_expandEnv(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr( ExpandEnvironmentStrDelphi( getArgStr(args,0,True) ) );
end;

function sys_getFileSize(args: DWORD): PHiValue; stdcall;
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

function sys_getFileDate(args: DWORD): PHiValue; stdcall;
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


function sys_getCreateFileDate(args: DWORD): PHiValue; stdcall;
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

function sys_getLastAccessFileDate(args: DWORD): PHiValue; stdcall;
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

function sys_getWriteFileDate(args: DWORD): PHiValue; stdcall;
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

function sys_setFileDateCreate(args: DWORD): PHiValue; stdcall;
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

function sys_setFileDateWrite(args: DWORD): PHiValue; stdcall;
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

function sys_setFileDateLastAccess(args: DWORD): PHiValue; stdcall;
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

function sys_getFileAttr(args: DWORD): PHiValue; stdcall;
var f: PHiValue; fname: string;
begin
  f := nako_getFuncArg(args, 0);
  if f = nil then f := nako_getSore;
  fname := hi_str(f);
  Result := hi_newInt(GetFileAttributes(PChar(fname)));
end;

function sys_setFileAttr(args: DWORD): PHiValue; stdcall;
var f, s: PHiValue; fname: string;
begin
  f := nako_getFuncArg(args, 0);
  s := nako_getFuncArg(args, 1);
  if f = nil then f := nako_getSore;
  fname := hi_str(f);
  SetFileAttributes(PChar(fname), hi_int(s));
  Result := nil;
end;


function sys_getLogicalDrives(args: DWORD): PHiValue; stdcall;
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

function sys_getDriveType(args: DWORD): PHiValue; stdcall;
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

function sys_getDiskSize(args: DWORD): PHiValue; stdcall;
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
function sys_getDiskFreeSize(args: DWORD): PHiValue; stdcall;
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
function sys_getVolumeName(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue; sp: string;
begin
  p := nako_getFuncArg(args, 0);
  if p = nil then p := nako_getSore;
  sp := hi_str(p);
  Result := hi_newStr(getVolumeName(sp));
end;
function sys_getSerialNo(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue; sp: string;
begin
  p := nako_getFuncArg(args, 0);
  if p = nil then p := nako_getSore;
  sp := hi_str(p);
  Result := hi_newInt(getSerialNo(sp));
end;

function sys_showHotplugDlg(args: DWORD): PHiValue; stdcall;
begin
  RunApp('rundll32 shell32.dll,Control_RunDLL hotplug.dll');
  Result := nil;
end;

function sys_shell_association(args: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_FLUSH, nil, nil);
end;

function sys_shell_updatedir(args: DWORD): PHiValue; stdcall;
var
  dir: string;
begin
  Result := nil;
  dir := getArgStr(args, 0, True);
  SHChangeNotify(SHCNE_UPDATEDIR, SHCNF_PATH, PChar(dir), nil);
end;

function sys_file_h_open(args: DWORD): PHiValue; stdcall;
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

function sys_file_h_read(args: DWORD): PHiValue; stdcall;
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

function sys_file_h_write(args: DWORD): PHiValue; stdcall;
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

function sys_file_h_close(args: DWORD): PHiValue; stdcall;
var
  ph: PHiValue;
  h : TFileStream;
begin
  ph := nako_getFuncArg(args, 0);
  h  := TFileStream( hi_int(ph) );

  FreeAndNil(h);

  Result := nil;
end;

function sys_file_h_getpos(args: DWORD): PHiValue; stdcall;
var
  ph: PHiValue;
  h : TFileStream;
begin
  ph := nako_getFuncArg(args, 0);
  h  := TFileStream( hi_int(ph) );

  Result := hi_newInt( h.Position );
end;

function sys_file_h_setpos(args: DWORD): PHiValue; stdcall;
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

function sys_file_h_size(args: DWORD): PHiValue; stdcall;
var
  ph: PHiValue;
  h : TFileStream;
begin
  ph := nako_getFuncArg(args, 0);
  h  := TFileStream( hi_int(ph) );

  Result := hi_newInt(h.Size);
end;

function sys_file_h_writeLine(args: DWORD): PHiValue; stdcall;
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

function sys_file_h_readLine(args: DWORD): PHiValue; stdcall;
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

function sys_compress(args: DWORD): PHiValue; stdcall;
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
  raise Exception.Create('"'+ext+'"は未対応の圧縮形式です。');
  nako_reportDLL(PChar(unit_archive.used_dll));

  // (3) 結果の代入
  Result := nil;
end;

function sys_extract(args: DWORD): PHiValue; stdcall;
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
  raise Exception.Create('"'+ext+'"は未対応の圧縮形式です。');
  nako_reportDLL(PChar(unit_archive.used_dll));

  // (3) 結果の代入
  Result := nil;
end;

function sys_compress_pass(args: DWORD): PHiValue; stdcall;
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
  if ext = '.yz1' then yz1_compress(src, des) else
  raise Exception.Create('"'+ext+'"は未対応の圧縮形式です。');
  nako_reportDLL(PChar(unit_archive.used_dll));

  // (3) 結果の代入
  Result := nil;
end;

function sys_extract_pass(args: DWORD): PHiValue; stdcall;
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
  if ext = '.yz1' then yz1_extract (src, des)  else
  raise Exception.Create('"'+ext+'"は未対応の圧縮形式です。');
  nako_reportDLL(PChar(unit_archive.used_dll));

  // (3) 結果の代入
  Result := nil;
end;


function sys_archive_command(args: DWORD): PHiValue; stdcall;
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
  if ext = '.cab' then CabCommand(cmd)  else
  if ext = '.yz1' then Yz1Command(cmd)  else
  raise Exception.Create('"'+ext+'"は未対応の圧縮形式です。');

  // (3) 結果の代入
  Result := nil;
end;


function sys_makesfx(args: DWORD): PHiValue; stdcall;
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

function sys_getUserName(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(GetUserName);
end;

function sys_GetComputerName(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(GetComputerName);
end;

function sys_LanEnumDomain(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(LanEnumDomain);
end;

function sys_LanEnumComputer(args: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := nako_getFuncArg(args, 0);
  if a = nil then
  begin
    Result := hi_newStr(LanEnumComputer('',True));
  end else
  begin
    Result := hi_newStr(LanEnumComputer(hi_str(a),True));
  end;
end;

function sys_LanEnumCommonDir(args: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := nako_getFuncArg(args, 0);
  Result := hi_newStr(LanGetCommonResource(hi_str(a)));
end;

function sys_WNetAddConnection2(args: DWORD): PHiValue; stdcall;
var
  drv, dir, pass, user: string;
begin
  Result := nil;
  drv := getArgStr(args, 0, True);
  dir := getArgStr(args, 1);
  user:= getArgStr(args, 2);
  pass:= getArgStr(args, 3);
  //
  drv := Trim(drv);
  drv := UpperCase(Copy(drv,1,1)) + ':';
  dir := ExcludeTrailingPathDelimiter(dir);
  //

  try
    if user = '' then
      AddNetworkDrive(PChar(drv), PChar(dir), nil)
    else
      AddNetworkDrive(PChar(drv), PChar(dir), nil,PChar(pass),Pchar(user));
  except
    on e: Exception do
      raise Exception.Create(Format('"%s"へ"%s"を割り当てできませんでした。' + e.Message,[drv,dir]));
  end;
end;

function sys_WNetCancelConnection2(args: DWORD): PHiValue; stdcall;
var
  drv:String;
begin
  Result := nil;
  drv := getArgStr(args, 0, True);
  drv := UpperCase(Copy(drv,1,1)) + ':';
  if WNetCancelConnection2(Pchar(drv),0,False) <> NO_ERROR then
    raise Exception.Create(Format('"%s"の割り当てを解除できませんでした。' + GetLastErrorStr,[drv]));
end;

function sys_kanrenduke(args: DWORD): PHiValue; stdcall;
var
  ext, app: string;
begin
  Result := nil;
  ext := getArgStr(args, 0, True);
  app := getArgStr(args, 1, False);
  Kanrenduke(ext, app);
end;
function sys_kanrendukekaijo(args: DWORD): PHiValue; stdcall;
var
  ext: string;
begin
  Result := nil;
  ext := getArgStr(args, 0, True);
  KanrendukeKaijo(ext);
end;
// 出力のために
var outfile: TFileStream = nil;
var outfile_name: string = '';
function sys_set_outfile(args: DWORD): PHiValue; stdcall;
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
function sys_get_outfile(args: DWORD): PHiValue; stdcall;
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
function sys_outfile_write(args: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  Result := nil;
  s := getArgStr(args, 0, True);
  check_outfile;
  if s <> '' then outfile.Write(s[1], Length(s));
end;
function sys_outfile_writeln(args: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  Result := nil;
  s := getArgStr(args, 0, True) + #13#10;
  check_outfile;
  if s <> '' then outfile.Write(s[1], Length(s));
end;
function sys_outfile_clear(args: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  outfile.Position := 0;
  outfile.Size := 0;
end;

//--- GET DIRECTORY FUNCTION
function sys_WinDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(WinDir);
end;
function sys_SysDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(SysDir);
end;
function sys_TempDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(TempDir);
end;
function sys_DesktopDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(DesktopDir);
end;
function sys_SendToDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(SendToDir);
end;
function sys_StartUpDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(StartUpDir);
end;
function sys_RecentDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(RecentDir);
end;
function sys_ProgramsDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(ProgramsDir);
end;
function sys_MyDocumentDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(MyDocumentDir);
end;
function sys_FavoritesDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(FavoritesDir);
end;
function sys_MyMusicDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(MyMusicDir);
end;
function sys_MyPictureDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(MyPictureDir);
end;
function sys_FontsDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(FontsDir);
end;
function sys_ProgramFilesDir(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(ProgramFilesDir);
end;

const
  KEY_USER_DESKTOP = '\Control Panel\Desktop';

function sys_getScr(args: DWORD): PHiValue; stdcall;
var
  reg: TRegistry;
  scr: string;
begin
  Result := nil;
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey(KEY_USER_DESKTOP, False) then
    begin
      scr := reg.ReadString('SCRNSAVE.EXE');
      reg.CloseKey;
      Result := hi_newStr(scr);
    end;
  finally
    FreeAndNil(reg);
  end;
end;


function sys_runScr(args: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  PostMessage(HWND_BROADCAST, WM_SYSCOMMAND, SC_SCREENSAVE, 0);
end;

function sys_setScr(args: DWORD): PHiValue; stdcall;
var
  reg: TRegistry;
  scr: string;
begin
  Result := nil;
  scr := getArgStr(args, 0, True);
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey(KEY_USER_DESKTOP, True) then
    begin
      if scr = '' then
      begin
        reg.WriteString('SCRNSAVE.EXE', '');
        reg.WriteInteger('ScreenSaveActive', 0);
      end else
      begin
        reg.WriteString('SCRNSAVE.EXE', scr);
        reg.WriteInteger('ScreenSaveActive', 1);
      end;
      reg.CloseKey;
    end else
    begin
      raise Exception.Create('スクリーンセイバーを設定できません。');
    end;
  finally
    FreeAndNil(reg);
  end;
end;

function sys_getScrTime(args: DWORD): PHiValue; stdcall;
var
  reg: TRegistry;
  timer: Integer;
begin
  Result := nil;
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey(KEY_USER_DESKTOP, False) then
    begin
      timer := StrToIntDef(reg.ReadString('ScreenSaveTimeOut'), 0);
      reg.CloseKey;
      Result := hi_newInt(timer);
    end;
  finally
    FreeAndNil(reg);
  end;
end;

function sys_setScrTime(args: DWORD): PHiValue; stdcall;
var
  reg: TRegistry;
  timer: String;
begin
  Result := nil;
  timer := IntToStr(getArgInt(args, 0, True));
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey(KEY_USER_DESKTOP, True) then
    begin
      reg.WriteString('ScreenSaveTimeOut', timer);
      reg.CloseKey;
    end else
    begin
      raise Exception.Create('スクリーンセイバー待ち時間を設定できません。');
    end;
  finally
    FreeAndNil(reg);
  end;
end;


//--- COM ----------------------------------------------------------------------
// 作りかけ
(*
  //+COM(nakofile.dll)
  AddFunc  ('OLE_CREATE','{=?}Sの', 638, sys_com_create,'COMのクラスSを生成して返す。','OLE_CREATE');
  AddFunc  ('OLE_SET_PROP','{=?}HのNへVを', 637, sys_com_setProperty,'COMのNへVを代入する。','OLE_SET_PROP');
  AddFunc  ('OLE_GET_PROP','{=?}HのNを', 636, sys_com_getProperty,'COMのNを取得して返す。','OLE_GET_PROP');

function sys_com_create(args: DWORD): PHiValue; stdcall;
begin
  Result := nako_var_new(nil);
  Result.int := Integer(CreateOleObject(getArgStr(args,0,True)));
  Result.VType := varInt;
end;

function sys_com_setProperty(args: DWORD): PHiValue; stdcall;
var
  i: IDispatch;
  n: string;
  p, v: PHiValue;
begin
  // args
  p := nako_getFuncArg(args, 0); if p = nil then p := nako_getSore;
  //todo: IDispatchの受け渡しに失敗する
  n := getArgStr(args,1);
  v := nako_getFuncArg(args, 2);
  if i = nil then raise Exception.Create('OLEオブジェクトが作成されていません。');
  //
  case v.VType of
    varNil    : SetDispatchPropValue(i, n, Unassigned);
    varInt    : SetDispatchPropValue(i, n, hi_int(v));
    varFloat  : SetDispatchPropValue(i, n, hi_float(v));
    varStr    : SetDispatchPropValue(i, n, hi_str(v));
    else begin
      SetDispatchPropValue(i, n, hi_str(v));
    end;
  end;
  Result := nil;
end;

function sys_com_getProperty(args: DWORD): PHiValue; stdcall;
var
  i: IDispatch;
  n: string;
  v: OleVariant;
begin
  // args
  i := IDispatch(getArgInt(args,0,True));
  n := getArgStr(args,1);
  v := GetDispatchPropValue(i, n);
  Result := hi_newStr(v);
end;
*)

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
  //AddFunc  ('ファイル名抽出', 'Sから|Sの',  20, sys_extractFile,'パスSからファイル名部分を抽出して返す。','ふぁいるめいちゅうしゅつ');
  //AddFunc  ('パス抽出',       'Sから|Sの',  21, sys_extractFilePath,'ファイル名Sからパス部分を抽出して返す。','ぱすちゅうしゅつ');
  //AddFunc  ('拡張子抽出',     'Sから|Sの',  22, sys_extractExt,'ファイル名Sから拡張子部分を抽出して返す。','かくちょうしちゅうしゅつ');
  //AddFunc  ('拡張子変更',     'SをAに|Sの', 23, sys_changeExt,'ファイル名Sの拡張子をAに変更して返す。','かくちょうしへんこう');
  //AddFunc  ('ユニークファイル名生成','AでBの|Aに', 24, sys_makeoriginalfile,'フォルダAでヘッダBをもつユニークなファイル名を生成して返す。','ゆにーくふぁいるめいせいせい');
  //AddFunc  ('相対パス展開',   'AをBで',     25, sys_expand_path,'相対パスＡを基本パスＢで展開して返す。','そうたいぱすてんかい');
  AddFunc  ('終端パス追加','{=?}Sの|Sで|Sに|Sから',525, sys_pathFlagAdd,  'フォルダ名の終端に「\」記号がなければつけて返す','しゅうたんぱすついか');
  AddFunc  ('終端パス削除','{=?}Sの|Sで|Sに|Sから',526, sys_pathFlagDel,  'フォルダ名の終端に「\」記号があれば削除して返す','しゅうたんぱすさくじょ');
  AddFunc  ('文字列ファイル名変換','{=?}Sの|Sを|Sで|Sから',527, sys_StrtoFileName,  '文字列をファイル名として使えるように変換して返す。','もじれつふぁいるめいへんかん');
  AddFunc  ('文字列UNIXファイル名変換','{=?}Sの|Sを|Sで|Sから',528, sys_StrtoFileNameUnix,  '文字列をファイル名として使えるように変換して返す。','もじれつふぁいるめいへんかん');
  //-開く保存
  AddFunc  ('保存','{文字列=?}SをFに|Fへ',             500, sys_saveAll,  '文字列Sの内容をファイル名Fへ保存する。','ほぞん');
  AddFunc  ('開く','{参照渡し 変数=?}VにFを|VへFから', 501, sys_loadAll,  '変数V(省略した場合は『それ』)にファイル名Fの内容を読み込む。','ひらく');
  AddFunc  ('読む','{参照渡し 変数=?}VにFを|VへFから', 502, sys_loadAll,  '変数V(省略した場合は『それ』)にファイル名Fの内容を読み込む。','よむ');
  AddFunc  ('追加保存','{文字列=?}SをFに|Fへ',         504, sys_saveAllAdd,'文字列Sの内容をファイル名Fへ追加保存する。','ついかほぞん');
  //-一行ずつ読み書き
  AddFunc  ('毎行読む','{参照渡し 変数=?}VにFを|VへFから', 503, sys_loadEveryLine,  '一行ずつ読むためにファイル名Fを開いてハンドルを返す。反復と組み合わせて使う。','まいぎょうよむ');
  AddFunc  ('出力先設定','Fに|Fへ', 505, sys_set_outfile,  '『出力』命令の出力先ファイルSを指定する。','しゅつりょくさきせってい');
  AddFunc  ('出力先取得','', 506, sys_get_outfile,  '『出力』命令の出力先ファイル名を取得する。','しゅつりょくさきしゅとく');
  SetSetterGetter('出力先ファイル','出力先設定','出力先取得',507,'『出力』命令の出力先ファイルを指定する。','しゅつりょくさきふぁいる');
  AddFunc  ('出力','Sを|Sと', 509, sys_outfile_write, '『出力先』で指定したファイルへ文字列S+改行を追記する(指定なしは「なでしこ出力.txt」へ出力)','しゅつりょく');
  AddFunc  ('一行出力','Sを|Sと', 508, sys_outfile_writeln, '『出力先』で指定したファイルへ文字列S+改行を追記する','いちぎょうしゅつりょく');
  AddFunc  ('出力先初期化','', 510, sys_outfile_clear, '『出力先』で指定したファイルを初期化する','しゅつりょくさきしょきか');

  //-起動
  AddFunc  ('起動','{文字列=?}PATHを',                      520, sys_exec, 'ファイルPATHを起動する。','きどう');
  AddFunc  ('起動待機','{文字列=?}PATHを',                  521, sys_exec_wait, 'ファイルPATHを起動して終了するまで待機する。','きどうたいき');
  AddFunc  ('秒間起動待機','{文字列=?}PATHをSEC',           677, sys_exec_wait_sec, 'ファイルPATHを起動してSEC秒間待機する。正常に終了すればはい(=1)を返す。時間内に終了しなければ、いいえ(=0)を返し処理を継続する。(起動したアプリの強制終了は行わない。)','びょうかんきどうたいき');
  AddFunc  ('エクスプローラー起動','{文字列=?}DIRで|DIRの|DIRを', 522, sys_exec_exp, 'フォルダDIRをエクスプローラーで起動する。','えくすぷろーらーきどう');
  AddFunc  ('隠し起動','{文字列=?}Sを', 523, sys_exec_open_hide, 'ファイルSを可視オフで起動する。','かくしきどう');
  AddFunc  ('隠し起動待機','{文字列=?}Sを', 524, sys_exec_wait_hide, 'ファイルSを可視オフで起動して終了まで待機する。','かくしきどうたいき');
  AddFunc  ('コマンド実行','{文字列=?}Sを', 675, sys_exec_command, 'ファイルSを可視オフで起動して終了まで待機する。起動したプログラムの標準出力の内容を返す。','こまんどじっこう');
  AddFunc  ('管理者権限実行','{文字列=?}Sを', 676, sys_exec_admin, 'ファイルSを管理者権限で起動する。','かんりしゃけんげんじっこう');
  //-フォルダ操作
  AddFunc  ('作業フォルダ変更','{文字列}Sに|Sへ',      530, sys_setCurDir, 'カレントディレクトリをSに変更する。','さぎょうふぉるだへんこう');
  AddFunc  ('作業フォルダ取得','',                     531, sys_getCurDir, 'カレントディレクトリを取得して返す。','さぎょうふぉるだしゅとく');
  SetSetterGetter('作業フォルダ', '作業フォルダ変更', '作業フォルダ取得', 537, 'カレントディレクトリの変更を行う。','さぎょうおふぉるだ');
  AddFunc  ('フォルダ作成','Sに|Sへ|Sの',              532, sys_makeDir,   'パスSにフォルダを作成する。','ふぉるださくせい');
  AddFunc  ('フォルダ削除','Sの|Sを|Sから',            559, sys_removeDir, 'パスSのフォルダを削除する。(フォルダは空でなくても良い)','ふぉるださくじょ');
  //-列挙・存在
  AddFunc  ('ファイル列挙','{文字列=?}Sの|Sを|Sで',   533, sys_enumFiles,'パスSにあるファイルを配列形式で返す。「;」で区切って複数の拡張子を指定可能。引数を省略するとカレントディレクトリのファイル一覧を返す。','ふぁいるれっきょ');
  AddFunc  ('フォルダ列挙','{文字列=?}Sの|Sを|Sで',   534, sys_enumDirs, 'パスSにあるフォルダを配列形式で返す。引数を省略するとカレントディレクトリのフォルダ一覧を返す。','ふぉるだれっきょ');
  AddFunc  ('存在','Sが|Sの',       535, sys_FileExists, 'パスSにファイルかフォルダが存在するか確認してはい(=1)かいいえ(=0)で返す','そんざい');
  AddFunc  ('全ファイル列挙','{文字列=?}Sの|Sを|Sで', 536, sys_enumAllFiles,'パスSにあるファイルをサブフォルダも含め配列形式で返す。「;」で区切って複数の拡張子を指定可能。','ぜんふぁいるれっきょ');
  AddFunc  ('全フォルダ列挙','{文字列=?}Sの|Sを|Sで', 680, sys_enumAllDir,'パスSにあるフォルダも再帰的に検索して配列形式で返す。','ぜんふぉるだれっきょ');
  AddFunc  ('全ファイル相対パス列挙','{文字列=?}Sの|Sを|Sで', 679, sys_enumAllFilesRelative,'パスSにあるファイルをサブフォルダを含めて（パスSからの相対指定で）配列形式で返す。','ぜんふぁいるそうたいぱすれっきょ');
  //-コピー移動削除
  AddFunc  ('ファイルコピー','AからBへ|AをBに',540,sys_fileCopy,  'ファイルAからBへコピーする。','ふぁいるこぴー');
  AddFunc  ('ファイル移動',  'AからBへ|AをBに',541,sys_fileRename,  'ファイルAからBへ移動する。','ふぁいるいどう');
  AddFunc  ('ファイル削除',  'Aを|Aの',        542,sys_fileDelete,'ファイルAを削除する(ゴミ箱へ移動)。','ふぁいるさくじょ');
  AddFunc  ('ファイル名変更','AからBへ|AをBに',543,sys_fileRename,'ファイル名AからBへ変更する。','ふぁいるめいへんこう');
  AddFunc  ('フォルダコピー','AからBへ|AをBに',544,sys_dirCopy,   'フォルダAからBへコピーする。','ふぉるだこぴー');
  AddFunc  ('ファイル完全削除', 'Aを|Aの',     545,sys_fileDeleteAll,'ファイルAを完全に削除する。(ゴミ箱へ移動しない)','ふぁいるかんぜんさくじょ');
  AddFunc  ('ファイル抽出コピー', 'AからBへ|AをBに',546,sys_fileCopyEx,'フォルダA(パス+ワイルドカードリスト「;」で区切る)からフォルダBへ任意のファイルのみをコピーする','ふぁいるちゅうしゅつこぴー');
  AddStrVar('ファイル抽出コピー除外パターン','Thumbs.db',547,'ファイル抽出コピーで除外するパターンを一行ごとワイルドカードで指定する。','ふぁいるちゅうしゅつこぴーじょがいぱたーん');
  //-ショートカット
  AddFunc  ('ショートカット作成','AをBへ|AのBに', 555, sys_shortcut,'アプリケーションAのショートカットをBに作る','しょーとかっとさくせい');
  AddFunc  ('ショートカット詳細作成','AをBへCで|AのBに', 553, sys_shortcut_ex,'アプリケーションAのショートカットをBにハッシュCの設定で作る','しょーとかっとしょうさいさくせい');
  AddFunc  ('ショートカットリンク先取得','Aの', 554, sys_get_shortcut,'ショートカットAのリンク先を取得する。','しょーとかっとりんくさきしゅとく');
  //-ファイル情報
  AddFunc  ('ファイルサイズ','Fの',           556, sys_getFileSize,'ファイルFのサイズを返す','ふぁいるさいず');
  AddFunc  ('ファイル日付','Fの',             557, sys_getFileDate,'ファイルFの日付を返す','ふぁいるひづけ');
  AddFunc  ('ファイル作成日時','Fの',         621, sys_getCreateFileDate,'ファイルFの作成日時を返す','ふぁいるさくせいにちじ');
  AddFunc  ('ファイル更新日時','Fの',         622, sys_getWriteFileDate,'ファイルFの更新日時を返す','ふぁいるこうしんにちじ');
  AddFunc  ('ファイル最終アクセス日時','Fの', 623, sys_getLastAccessFileDate,'ファイルFの最終アクセス日時を返す','ふぁいるさいしゅうあくせすにちじ');
  AddFunc  ('ファイル作成日時変更','{=?}FをSに|Sへ',  624, sys_setFileDateCreate,'ファイルFの作成日時をSに設定する','ふぁいるさくせいにちじへんこう');
  AddFunc  ('ファイル更新日時変更','{=?}FをSに|Sへ',  625, sys_setFileDateWrite,'ファイルFの更新日時をSに設定する','ふぁいるこうしんにちじへんこう');
  AddFunc  ('ファイル最終アクセス日時変更','{=?}FをSに|Sへ',  626, sys_setFileDateLastAccess,'ファイルFの最終アクセス日時をSに設定する','ふぁいるさいしゅうあくせすにちじへんこう');
  AddFunc  ('ファイル属性取得','{=?}Fの',         627, sys_getFileAttr,'ファイルFの属性を取得する','ふぁいるぞくせいしゅとく');
  AddFunc  ('ファイル属性設定','{=?}FをSに|Sへ',  628, sys_setFileAttr,'ファイルFの属性を設定する','ふぁいるぞくせいせってい');
  AddIntVar('アーカイブ属性',   $20,  640, 'ファイル属性','あーかいぶぞくせい');
  AddIntVar('ディレクトリ属性', $10,  641, 'ファイル属性','でぃれくとりぞくせい');
  AddIntVar('隠しファイル属性', $2,   642, 'ファイル属性','かくしふぁいるぞくせい');
  AddIntVar('読み込み専用属性', $1,   643, 'ファイル属性','よみこみせんようぞくせい');
  AddIntVar('システムファイル属性',$4,644, 'ファイル属性','しすてむふぁいるぞくせい');
  AddIntVar('ノーマル属性',     $80,  645, 'ファイル属性','のーまるぞくせい');
  AddFunc  ('フォルダ存在','{=?}Fの',  639, sys_ExistsDir,'フォルダFが存在するのか調べて、はい(=1)かいいえ(=0)で返す。','ふぉるだそんざい');
  AddFunc  ('長いファイル名取得','{=?}Fの',  673, sys_getLongFileName,'長いファイル名(ロングファイル)を返す。','ながいふぁいるめいしゅとく');
  AddFunc  ('短いファイル名取得','{=?}Fの',  674, sys_getShortFileName,'短いファイル名(ショートファイル)を返す。','みじかいふぁいるめいしゅとく');

  //-ドライブ情報
  AddFunc  ('使用可能ドライブ取得','',646, sys_getLogicalDrives,'使用可能ドライブの一覧を得る','しようかのうどらいぶしゅとく');
  AddFunc  ('ドライブ種類','{=?}Aの',647, sys_getDriveType,'ルートドライブＡの種類(不明|存在しない|取り外し可能|固定|ネットワーク|CD-ROM|RAM)を返す。','どらいぶしゅるい');
  AddFunc  ('ディスクサイズ','{=?}Aの',648, sys_getDiskSize,'ディスクＡの全体のバイト数を返す。','でぃすくさいず');
  AddFunc  ('ディスク空きサイズ','{=?}Aの',649, sys_getDiskFreeSize,'ディスクＡの利用可能空きバイト数を返す。','でぃすくあきさいず');
  AddFunc  ('ボリューム名取得','{=?}Aの',665, sys_getVolumeName,'ディスクＡのボリューム名を返す。','ぼりゅーむめいしゅとく');
  AddFunc  ('ディスクシリアル番号取得','{=?}Aの',666, sys_getSerialNo,'ディスクＡのシリアル番号を返す。','でぃすくしりあるばんごうしゅとく');
  AddFunc  ('ハードウェア取り外し起動','',672, sys_showHotplugDlg,'ハードウェア取り外しダイアログを表示する','はーどうぇあとりはずしきどう');

  //-コンソール
  //AddFunc  ('標準入力取得','CNTの', 558, nil,'CNTバイトの標準入力を取得する(コンソールのみ)','ひょうじゅんにゅうりょくしゅとく');
  //-ストリーム操作
  AddFunc  ('ファイルストリーム開く',  'AをBで',   561, sys_file_h_open,  'ファイル名AをモードB(作|読|書|排他)でストリームを開きハンドルを返す。','ふぁいるすとりーむひらく');
  AddFunc  ('ファイルストリーム読む',  'HでCNTを', 562, sys_file_h_read,  'ファイルストリームハンドルHでCNTバイト読んで返す。','ふぁいるすとりーむよむ');
  AddFunc  ('ファイルストリーム書く',  'HでSを',   563, sys_file_h_write, 'ファイルストリームハンドルHに(Sのバイト数分)文字列Sを書く。何も返さない。','ふぁいるすとりーむかく');
  AddFunc  ('ファイルストリーム閉じる','Hを',      564, sys_file_h_close, 'ファイルストリームハンドルHを閉じる。','ふぁいるすとりーむとじる');
  AddFunc  ('ファイルストリーム位置取得','Hの',    565, sys_file_h_getpos,'ファイルストリームハンドルHの位置を取得する','ふぁいるすとりーむいちしゅとく');
  AddFunc  ('ファイルストリーム位置設定','HでIに', 566, sys_file_h_setpos,'ファイルストリームハンドルHの位置をIに設定する','ふぁいるすとりーむいちせってい');
  AddFunc  ('ファイルストリームサイズ','Hの',  567, sys_file_h_size,  'ファイルストリームハンドルHで開いたファイルのサイズを返す','ふぁいるすとりーむさいず');
  AddFunc  ('ファイルストリーム一行読む',  'Hで|Hの', 568, sys_file_h_readLine,  'ファイルストリームハンドルHで一行読んで返す。','ふぁいるすとりーむいちぎょうよむ');
  AddFunc  ('ファイルストリーム一行書く',  '{=?}SをHに|Hで|Hへ', 569, sys_file_h_writeLine,  'ファイルストリームハンドルHへSを一行書く','ふぁいるすとりーむいちぎょうかく');
  //-更新
  AddFunc  ('関連付け反映','',575, sys_shell_association, '関連付けを変更した時、変更をシェルに伝える。','かんれんづけはんえい');
  AddFunc  ('フォルダ内容反映','{=?}DIRの',576, sys_shell_updatedir, 'フォルダDIRの内容が変更を反映させる。','ふぉるだないようはんえい');


  //+圧縮解凍(nakofile.dll)
  //-圧縮解凍
  AddFunc('圧縮','AをBへ|AからBに', 570, sys_compress, 'パスAをファイルBへ圧縮する。','あっしゅく','7-zip32.dll,UNLHA32.DLL');
  AddFunc('解凍','AをBへ|AからBに', 571, sys_extract, 'ファイルAをパスBへ解凍する。','かいとう','7-zip32.dll,UNLHA32.DLL');
  AddFunc('自己解凍書庫作成','AをBへ|Aから', 572, sys_makesfx, 'パスAをファイルBへ自己解凍書庫を作成する','じこかいとうしょこさくせい','7-zip32.dll,UNLHA32.DLL');
  AddFunc('圧縮解凍実行','TYPEのCMDを|CMDで', 573, sys_archive_command, 'TYPE(拡張子)でアーカイバDLLへコマンドCMDを直接実行する','あっしゅくかいとうじっこう','7-zip32.dll,UNLHA32.DLL');
  AddFunc('パスワード付圧縮','PASSでAをBへ|AからBに', 574, sys_compress_pass, 'パスワードPASSを利用してパスAをファイルBへ圧縮する。(ZIP/YZ1ファイルのみ対応)','ぱすわーどつきあっしゅく','');
  AddFunc('パスワード付解凍','PASSでAをBへ|AからBに', 577, sys_extract_pass, 'パスワードPASSを利用してファイルAをパスBへ解凍する。(ZIP/YZ1ファイルのみ対応)','ぱすわーどつきかいとう','');
  //+レジストリ/INIファイル(nakofile.dll)
  //-レジストリ
  AddFunc  ('レジストリ開く','Sの', 580, sys_registry_open,'レジストリパスSを開いてハンドルを返す','れじすとりひらく');
  AddFunc  ('レジストリ閉じる','Hの|Hを', 581, sys_registry_close,'レジストリのハンドルHを閉じる','れじすとりとじる');
  AddFunc  ('レジストリ書く','HでSにAを', 582, sys_registry_write,'レジストリのハンドルHを使ってキーSに文字列Aを書く','れじすとりかく');
  AddFunc  ('レジストリ整数書く','HでSにAを', 583, sys_registry_writeInt,'レジストリのハンドルHを使ってキーSに整数Aを書く','れじすとりせいすうかく');
  AddFunc  ('レジストリキー削除','HでSを', 584, sys_registry_deleteKey,'レジストリのハンドルHを使ってキーSを削除する','れじすとりきーさくじょ');
  AddFunc  ('レジストリ値削除','HでSを', 585, sys_registry_deleteVal,'レジストリのハンドルHを使って値Sを削除する','れじすとりあたいさくじょ');
  AddFunc  ('レジストリキー列挙','Hで', 586, sys_registry_enumKeys,'レジストリのハンドルHのキー名を列挙する','れじすとりきーれっきょ');
  AddFunc  ('レジストリ値列挙','Hで', 587, sys_registry_enumValues,'レジストリのハンドルHを使って値を列挙する','れじすとりあたいれっきょ');
  AddFunc  ('レジストリ読む','HでSを', 588, sys_registry_read,'レジストリのハンドルHを使ってSを読んで返す','れじすとりよむ');
  AddFunc  ('レジストリ整数読む','HでSを', 589, sys_registry_readInt,'レジストリのハンドルHを使って整数Sを読んで返す','れじすとりせいすうよむ');
  AddFunc  ('レジストリキー存在','Sが|Sに', 590, sys_registry_KeyExists,'レジストリのキーSが存在するか調べる。','れじすとりきーそんざい');
  AddFunc  ('レジストリ値設定','KEYのVにSを|VへSの', 657, sys_reg_easy_write,'レジストリキーKEYの値Vに文字列Sを書き込む。ハンドル操作不要版。','れじすとりあたいせってい');
  AddFunc  ('レジストリ値取得','KEYのVから|Vを', 658, sys_reg_easy_read,'レジストリキーKEYの値Vの値を読む。ハンドル操作不要版。','れじすとりあたいしゅとく');
  AddFunc  ('レジストリバイナリ読む','{=?}HのSをCNTで', 670, sys_registry_read_bin,'レジストリのハンドルHをつかって値SをCNTバイト読む。','れじすとりばいなりよむ');
  AddFunc  ('レジストリバイナリ書く','{=?}HのSにVをCNTで', 671, sys_registry_write_bin,'レジストリのハンドルHをつかって値SにデータVをCNTバイト読む。','れじすとりばいなりかく');
  //-INIファイル
  AddFunc  ('INI開く','Fの', 591, sys_ini_open,'INIファイルFを開いてハンドルを返す','INIひらく');
  AddFunc  ('INI閉じる','Hの|Hを', 592, sys_ini_close,'INIファイルのハンドルHを閉じる','INIとじる');
  AddFunc  ('INI読む','HでAのBを', 593, sys_ini_read,'INIファイルのハンドルHでセクションＡのキーＢを読む。','INIよむ');
  AddFunc  ('INI書く','HでAのBにSを|', 594, sys_ini_write,'INIファイルのハンドルHでセクションＡのキーＢに値Ｓを書く。','INIかく');
  //-シェル
  AddFunc  ('関連付けシステム通知','', 650, sys_SHChangeNotify,'関連付けの更新をシステムに通知する。','かんれんづけしすてむつうち');
  AddFunc  ('関連付け','SをAに|Aへ', 655, sys_kanrenduke,'拡張子SをアプリケーションAと関連付けする','かんれんづけ');
  AddFunc  ('関連付け解除','Sを|Sの', 656, sys_kanrendukekaijo,'拡張子Sの関連付けを解除する','かんれんづけかいじょ');
  //-壁紙
  AddFunc  ('壁紙設定','{=?}Fに|Fへ', 651, sys_ChangeWallpaper,'画像ファイルFに壁紙を変更する。','かべがみせってい');
  AddFunc  ('壁紙取得','', 652, sys_getWallpaper,'壁紙のファイル名を取得する。','かべがみしゅとく');
  AddFunc  ('壁紙スタイル設定','{=?}Aに|Aへ', 653, sys_ChangeWallpaperStyle,'壁紙のスタイルA(中央|拡大|タイル)に変更する','かべがみすたいるせってい');
  AddFunc  ('壁紙スタイル取得','', 654, sys_getWallpaperStyle,'壁紙のスタイルを取得する。','かべがみすたいるしゅとく');
  //-スクリーンセーバー
  AddFunc  ('スクリーンセイバー取得','', 681, sys_getScr,'スクリーンセイバーのファイル名を取得する。','すくりーんせいばーしゅとく');
  AddFunc  ('スクリーンセイバー設定','{=?}FILEを|FILEに', 682, sys_setScr,'スクリーンセイバーとしてファイル名FILEを設定する。','すくりーんせいばーせってい');
  AddFunc  ('スクリーンセイバー待ち時間取得','', 683, sys_getScrTime,'スクリーンセイバーの待ち時間を秒で取得する。','すくりーんせいばーまちじかんしゅとく');
  AddFunc  ('スクリーンセイバー待ち時間設定','{=?}Vを|Vに', 684, sys_setScrTime,'スクリーンセイバーの待ち時間をV秒に設定する。','すくりーんせいばーまちじかんせってい');
  AddFunc  ('スクリーンセイバー起動','', 685, sys_runScr,'設定されているスクリーンセイバーを起動する','すくりーんせいばーきどう');


  //+特殊フォルダ(nakofile.dll)
  //-パス
  AddFunc  ('WINDOWSパス',  '',                 600, sys_WinDir,'Windowsのインストールパスを返す','WINDOWSぱす');
  AddFunc  ('SYSTEMパス',   '',                 601, sys_SysDir,'Systemフォルダのパスを返す','SYSTEMぱす');
  AddFunc  ('テンポラリフォルダ', '',           602, sys_TempDir,'作業用のテンポラリフォルダのパスを得て返す','てんぽらりふぉるだ');
  AddFunc  ('デスクトップ',       '',           603, sys_DesktopDir,'デスクトップのフォルダのパスを返す','ですくとっぷ');
  AddFunc  ('SENDTOパス',         '',           604, sys_SendToDir,'「送る」メニューのフォルダのパスを返す','SENDTOぱす');
  AddFunc  ('スタートアップ',     '',           605, sys_StartUpDir,'Windowsを起動した時に自動的に実行する「スタートアップ」のフォルダパスを返す','すたーとあっぷ');
  AddFunc  ('RECENTパス',        '',            606, sys_RecentDir,'','RECENTぱす');
  AddFunc  ('スタートメニュー',  '',            607, sys_ProgramsDir,'スタートメニュー\プログラムのフォルダのパス返す','すたーとめにゅー');//スタートメニュー\プログラム\
  AddFunc  ('マイドキュメント',  '',            608, sys_MyDocumentDir, 'マイドキュメントのフォルダのパスを返す','まいどきゅめんと');
  AddFunc  ('FAVORITESパス',     '',            609, sys_FavoritesDir,'','FAVORITESぱす');
  AddFunc  ('お気入りフォルダ',  '',            610, sys_FavoritesDir,'','おきにいりふぉるだ');
  AddFunc  ('マイミュージック',  '',            612, sys_MyMusicDir,'','まいみゅーじっく');
  AddFunc  ('マイピクチャー',    '',            613, sys_MyPictureDir,'','まいぴくちゃー');
  AddFunc  ('マイピクチャ',      '',            669, sys_MyPictureDir,'','まいぴくちゃ');
  AddFunc  ('フォントパス',      '',            614, sys_FontsDir,'','ふぉんとぱす');
  AddFunc  ('PROGRAMFILESパス',  '',            615, sys_ProgramFilesDir,'','PROGRAMFILESぱす');
  AddFunc  ('OE5メールフォルダ',  '',           618, sys_getOE5,'Outlook Express5/6のメールが保存されているフォルダを取得して返す','OE5めーるふぉるだ');
  AddFunc  ('BECKY2メールフォルダ','',          619, sys_getBecky2,'Becky!Ver.2のメールが保存されているフォルダを取得して返す','Becky2めーるふぉるだ');
  AddFunc  ('環境変数展開','{=?}Sの|Sを|Sで',   620, sys_expandEnv,'「%UserProfiel%aaa\bbb」のような環境変数を含むパスを展開して返す','かんきょうへんすうてんかい');
  AddFunc  ('特殊パス取得','{=?}Aの|Aを',       660, sys_sp_path,'特殊パス(CSIDL_xxx)Aを指定して特殊パスを調べて返す','とくしゅぱすしゅとく');
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


  //+LAN(nakofile.dll)
  //-コンピューター情報
  AddFunc  ('ユーザー名取得','', 630, sys_getUserName,'ログオンユーザー名を返す。','ゆーざーめいしゅとく');
  AddFunc  ('コンピューター名取得','', 631, sys_getComputerName,'コンピューターの共有名を返す','こんぴゅーたーめいしゅとく');
  //-LAN共有コンピューター情報
  AddFunc  ('ドメイン列挙','', 632, sys_LanEnumDomain,'LAN上のドメインを列挙して返す。','どめいんれっきょ');
  AddFunc  ('コンピューター列挙','{=?}DOMAINの', 633, sys_LanEnumComputer,'LAN上のDOMAINに属するコンピューターを列挙して返す。','こんぴゅーたーれっきょ');
  AddFunc  ('共有フォルダ列挙','{=?}COMの', 634, sys_LanEnumCommonDir,'LAN上のCOMの共有フォルダを列挙して返す。','きょうゆうふぉるだれっきょ');
  AddFunc  ('ネットワークドライブ接続','AにBの{=「」}USERと{=「」}PASSで|AへBを', 635, sys_WNetAddConnection2,'ドライブAにネットワークフォルダBを割り当てる。接続ユーザ名USERとパスワードPASSは省略可能。','ねっとわーくどらいぶせつぞく');
  AddFunc  ('ネットワークドライブ切断','Aの|Aを', 636, sys_WNetCancelConnection2,'ドライブAに割り当てられたネットワークフォルダを切断する。','ねっとわーくどらいぶせつだん');
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
