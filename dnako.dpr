library dnako;

{$DEFINE DNAKO}

uses
  Windows,
  SysUtils,
  nadesiko_version in 'nadesiko_version.pas',
  hima_system in 'hi_unit\hima_system.pas',
  hima_parser in 'hi_unit\hima_parser.pas',
  hima_function in 'hi_unit\hima_function.pas',
  unit_windows_api in 'hi_unit\unit_windows_api.pas',
  hima_error in 'hi_unit\hima_error.pas',
  hima_string in 'hi_unit\hima_string.pas',
  hima_token in 'hi_unit\hima_token.pas',
  hima_types in 'hi_unit\hima_types.pas',
  hima_variable in 'hi_unit\hima_variable.pas',
  hima_variable_ex in 'hi_unit\hima_variable_ex.pas',
  hima_variable_lib in 'hi_unit\hima_variable_lib.pas',
  unit_file_dnako in 'hi_unit\unit_file_dnako.pas',
  unit_string in 'hi_unit\unit_string.pas',
  BRegExp in 'hi_unit\BRegExp.pas',
  mini_func in 'hi_unit\mini_func.pas',
  mini_file_utils in 'hi_unit\mini_file_utils.pas',
  hima_stream in 'hi_unit\hima_stream.pas',
  unit_pack_files in 'hi_unit\unit_pack_files.pas',
  nako_dialog_const in 'hi_unit\nako_dialog_const.pas',
  nako_dialog_function2 in 'hi_unit\nako_dialog_function2.pas',
  common_function in 'hi_unit\common_function.pas',
  unit_text_file in 'hi_unit\unit_text_file.pas',
  mt19937 in 'hi_unit\mt19937.pas',
  wildcard2 in 'hi_unit\wildcard2.pas',
  unit_blowfish in 'hi_unit\unit_blowfish.pas',
  BlowFish in 'hi_unit\BlowFish.pas',
  CryptUtils in 'hi_unit\CryptUtils.pas',
  unit_file in 'hi_unit\unit_file.pas',
  EasyMasks in 'hi_unit\EasyMasks.pas',
  {$IFDEF DELUX_VERSION}
  unit_pack_files_pro in 'pro_unit\unit_pack_files_pro.pas',
  {$ENDIF}
  unit_date in 'hi_unit\unit_date.pas';

const
  nako_OK = 1; // 関数の成功
  nako_NG = 0; // 関数の失敗

///<DNAKOAPI:BEGIN>
procedure nako_resetAll; stdcall; // なでしこのシステムをリセットする
begin
  HiSystemReset;
end;

procedure nako_free; stdcall; // なでしこのシステムを解放する
begin
  FreeAndNil(FileMixReader);
  FreeAndNil(FHiSystem);
end;

function nako_load(sourceFile: PAnsiChar): DWORD; stdcall;// 『なでしこ』のソースファイルを読み込む
begin
  try
    HiSystem.FIncludeBasePath := '';
    HiSystem.MainFileNo := HiSystem.LoadFromFile(string(SourceFile));
  except
    Result := nako_NG; Exit;
  end;
  Result := nako_OK;
end;

function nako_loadSource(sourceText: PAnsiChar): DWORD; stdcall;// 『なでしこ』のソースファイルを読み込む
begin
  try
    HiSystem.FIncludeBasePath := '';
    HiSystem.MainFileNo := HiSystem.LoadSourceText(sourceText, 'system');
  except
    Result := nako_NG; Exit;
  end;
  Result := nako_OK;
end;

function nako_run: DWORD; stdcall;// nako_load() で読んだソースファイルを実行する
begin
  try
    HiSystem.Run2;
  except
    Result := nako_NG; Exit;
  end;
  Result := nako_OK;
end;

function nako_run_ex: PHiValue; stdcall;// nako_load() で読んだソースファイルを実行する
begin
  try
    Result := HiSystem.Run;
  except
    Result := nil;
  end;
end;

function nako_error_continue: DWORD; stdcall;// エラーで止まった実行を続ける
begin
  try
    HiSystem.ErrorContinue2;
  except
    Result := nako_NG; Exit;
  end;
  Result := nako_OK;
end;

function nako_getError(msg: PAnsiChar; maxLen: Integer): DWORD; stdcall;// エラーメッセージを取得する。戻り値にはエラーメッセージの長さを返す。
begin
  Result := Length(HimaErrorMessage);
  if maxLen > 0 then
  begin
    StrLCopy(msg, PAnsiChar(HimaErrorMessage), maxLen);
  end;
end;

procedure nako_clearError(); stdcall; // 現在表示されているエラー情報を消す。
begin
  HimaErrorMessage := '';
end;

function nako_eval(source: PAnsiChar): PHiValue; stdcall;// source に与えられた文字列をプログラムとして評価して結果を返す
begin
  try
    Result := HiSystem.Eval(source);
  except
    Result := nil;
  end;
end;

function nako_evalEx(source: PAnsiChar; var ret: PHiValue): BOOL; stdcall;// source に与えられた文字列をプログラムとして評価して実行結果と成功したかどうかを返す
begin
  Result := True;
  try
    ret := HiSystem.Eval(source);
  except
    Result := False;
    ret    := nil;
  end;
end;

procedure nako_addFileCommand; stdcall; // ファイル関連の命令を使えるようにシステムに登録する。
begin
  HiSystem.AddSystemFileCommand;
end;

function nako_getVariable(vname: PAnsiChar): PHiValue; stdcall;// なでしこに登録されている変数のポインタを取得する
var
  id: DWORD;
begin
  id := hi_tango2id(DeleteGobi(vname));
  Result := HiSystem.GetVariable(id);
end;

function nako_getVariableFromId(vname_id: DWORD): PHiValue; stdcall;// ID番号からなでしこに登録されている変数のポインタを取得する
begin
  Result := HiSystem.GetVariable(vname_id);
end;

procedure nako_setVariable(vname: PAnsiChar; value: PHiValue); stdcall; // なでしこに変数を登録する(グローバルとして)
begin
  value.VarID := hi_tango2id(DeleteGobi(vname));
  HiSystem.Global.RegistVar(value);
end;

function nako_addFunction(name, args: PAnsiChar; func: THimaSysFunction; tag: Integer): DWORD; stdcall; // 独自関数を追加する
begin
  if HiSystem.AddFunction(name, args, func, tag, '') then
    Result := NAKO_OK
  else
    Result := NAKO_NG;
end;

function nako_addFunction2(name, args: PAnsiChar; func: THimaSysFunction; tag: Integer; IzonFiles: PAnsiChar): DWORD; stdcall; // 独自関数を追加する
begin
  if HiSystem.AddFunction(name, args, func, tag, IzonFiles) then
    Result := NAKO_OK
  else
    Result := NAKO_NG;
end;

function nako_getFuncArg(handle: DWORD; index: Integer): PHiValue; stdcall; // nako_addFunction で登録したコールバック関数から引数を取り出すのに使う
begin
  Result := hima_system.nako_getFuncArg(handle, index);
end;

function nako_getSore: PHiValue; stdcall; // 変数『それ』へのポインタを取得する
begin
  Result := HiSystem.Sore;
end;

procedure nako_addIntVar(name: PAnsiChar; value: Integer; tag: Integer); stdcall; // 整数型の変数をシステムに追加する。(tagには希望の単語IDを指定)
var
  p: PHiValue;
  key: AnsiString;
  id: DWORD;
begin
  key := DeleteGobi(name);
  id  := HiSystem.TangoList.GetID(key, tag);
  p := HiSystem.CreateHiValue(id);
  p.Designer := 1;
  hi_setInt(p, value);
end;

procedure nako_addStrVar(name: PAnsiChar; value: PAnsiChar; tag: Integer); stdcall; // 文字列型の変数をシステムに追加する。
var
  p: PHiValue;
  key: AnsiString;
  id: DWORD;
begin
  key := DeleteGobi(name);
  id  := HiSystem.TangoList.GetID(key, tag);
  p := HiSystem.CreateHiValue(id);
  p.Designer := 1;
  hi_setStr(p, value);
end;

procedure nako_stop; stdcall; // システムの実行を中止する
begin
  HiSystem.FlagEnd := True;
end;

procedure nako_continue; stdcall; // システムの実行を継続する
begin
  HiSystem.FlagEnd      := False;
  HiSystem.BreakLevel   := BREAK_OFF;
  HiSystem.BreakType    := btNone;
  HiSystem.ReturnLevel  := BREAK_OFF;
end;

function nako_id2tango(id: DWORD; tango: PAnsiChar; maxLen: DWORD): DWORD; stdcall; // 単語管理用IDから単語名を取得する。戻り値は常に単語の長さを返す。
var s: AnsiString;
begin
  s       := hi_id2tango(id);
  Result  := Length(s);
  if maxLen > 0 then StrLCopy(tango, PAnsiChar(s), maxLen);
end;

function nako_tango2id(tango: PAnsiChar): DWORD; stdcall; // 単語名から単語管理用IDを取得する
begin
  Result := hi_tango2id(AnsiString(tango));
end;

function nako_var2str(value: PHiValue; str: PAnsiChar; maxLen: DWORD): DWORD; stdcall; // PHiValueを文字列に変換してstrにコピーする。
var
  s: AnsiString;
  copyLen: DWORD;
begin
  s := hi_str(value);

  Result := Length(s);
  if (str = nil)or(maxLen = 0) then Exit;

  copyLen := Result;
  if copyLen > maxLen then copyLen := maxLen;

  if Result = 0 then
  begin
    StrCopy(str, ''); Exit;
  end;

  if Result > 0 then
  begin
    Move(s[1], str^, copyLen);
  end;
end;

function nako_var2cstr(value: PHiValue; str: PAnsiChar; maxLen: DWORD): DWORD; stdcall; // PHiValueをヌル終端文字列に変換してstrにコピーする。内容が途中で途切れる可能性もある。
var
  s: AnsiString;
  copyLen: DWORD;
begin
  s := hi_str(value);

  Result := Length(s);
  if (str = nil)or(maxLen = 0) then Exit;

  copyLen := Result;
  if copyLen >= maxLen then copyLen := maxLen - 1;

  if Result = 0 then
  begin
    StrCopy(str, ''); Exit;
  end;

  if Result > 0 then
  begin
    StrLCopy(str, PAnsiChar(s), copyLen);
  end;
end;


function nako_var2int(value: PHiValue): Integer; stdcall; // PHiValueをLongintに変換して得る
begin
  Result := hi_int(value);
end;

function nako_var2double(value: PHiValue): Double; stdcall; // PHiValueをDoubleに変換して得る
begin
  Result := hi_Float(value); // 完全に変換はできないがだいたいの精度変換されるはず
end;

function nako_var2extended(value: PHiValue): Extended; stdcall; // PHiValueをExtendedに変換して得る
begin
  Result := hi_Float(value);
end;

procedure nako_str2var(str: PAnsiChar; value: PHiValue); stdcall; // ヌル文字列を PHiValue に変換してセット
begin
  hi_setStr(value, AnsiString(str));
end;

procedure nako_bin2var(bin: PAnsiChar; len: DWORD; value: PHiValue); stdcall; // バイナリデータを文字列としてvalueにセット
var
  s: AnsiString;
begin
  if len = 0 then
  begin
    hi_setStr(value, ''); Exit;
  end;
  SetLength(s, len);
  Move(bin^, s[1], len);
  hi_setStr(value, s);
end;

procedure nako_int2var(num: Integer; value: PHiValue); stdcall; // ヌル文字列を PHiValue に変換してセット
begin
  hi_setInt(value, num);
end;

procedure nako_double2var(num: Double; value: PHiValue); stdcall; // ヌル文字列を PHiValue に変換してセット
begin
  hi_setFloat(value, num);
end;

function nako_var_new(name: PAnsiChar): PHiValue; stdcall; // 新規 PHiValue の変数を作成する。nameにnilを渡すと変数名をつけないで値だけ作成し変数名をつけるとグローバル変数として登録する。
begin
  if name <> nil then
  begin
    Result := HiSystem.CreateHiValue(hi_tango2id(DeleteGobi(name)));
  end else
  begin
    Result := hi_var_new;
  end;
end;

procedure nako_var_clear(value: PHiValue); stdcall; // 変数 value の値をクリアする
begin
  hi_var_clear(value);
end;

procedure nako_var_free(value: PHiValue); stdcall; // 変数 value の値を解放する
begin
  hima_system.nako_var_free(value);
end;

function nako_ary_get(v: PHiValue; index: Integer): PHiValue; stdcall; // v を配列として v[index]の値を得る
begin
  Result := hi_ary_get(v, index);
end;

function nako_ary_getCsv(v: PHiValue; Row, Col: Integer): PHiValue; stdcall; // v を二次元配列として v[Row][Col]の値を得る
begin
  Result := hi_ary_getCsv(v, Row, Col);
end;

function nako_ary_count(v: PHiValue): Integer; stdcall; // v の配列の要素数を得る
begin
  Result := hi_ary_count(v);
end;

procedure nako_varCopyData(src, dest: PHiValue); stdcall; // PHiValue型の変数の内容をまるまるコピーする
begin
  hi_var_copyData(src, dest);
end;

procedure nako_varCopyGensi(src, dest: PHiValue); stdcall; // PHiValue型の変数の内容をコピーする(原始型のみ複製)
begin
  hi_var_copyGensi(src, dest);
end;

procedure nako_setMainWindowHandle(h: Integer); stdcall; // メインウィンドウハンドルを設定する（ダイアログ表示関連の命令で利用）
begin
  hima_function.MainWindowHandle := h;
end;

function nako_getMainWindowHandle:DWORD; stdcall; // メインウィンドウハンドルを取得する（ダイアログ表示関連の命令で利用）
begin
  Result := hima_function.MainWindowHandle;
end;

function nako_getGroupMember(groupName, memberName: PAnsiChar): PHiValue; stdcall; // グループのメンバを取得する。メンバが存在しなければnilが返る。
var
  g: PHiValue;
  grp: THiGroup;
  m_id: DWORD;
begin
  Result := nil;
  // グループを得る
  g := HiSystem.GetVariable(hi_tango2id(DeleteGobi(groupName)));
  if g=nil then Exit;
  if g.VType <> varGroup then Exit;
  grp := hi_group(g);
  m_id := hi_tango2id(DeleteGobi(memberName));
  // グループのメンバを探す
  Result := grp.FindMember(m_id);
end;

function nako_hasEvent(groupName, memberName: PAnsiChar): PHiValue; stdcall; // グループのメンバを取得する。メンバが存在しなければnilが返る。
var
  g: PHiValue;
begin
  Result := nil;
  g := HiSystem.GetVariable(hi_tango2id(groupName));
  if g=nil then Exit;
  if g.VType <> varGroup then Exit;
  Result := hi_group(g).FindMember(hi_tango2id(memberName));
end;

procedure nako_addSetterGetter(vname, setter, getter:PAnsiChar; tag: DWORD); stdcall; // 変数名vnameにゲッターセッターを設定する
begin
  HiSystem.SetSetterGetter(vname, setter, getter, tag, '', '');
end;

procedure nako_setDebugEditorHandle(h: DWORD); stdcall; // デバッグ中のエディタハンドルを設定する
begin
  HiSystem.DebugEditorHandle := h;
end;

procedure nako_setDebugLineNo(b: BOOL); stdcall; // デバッグ中のエディタへ行番号を表示するか
begin
  HiSystem.DebugLineNo := b;
end;

procedure nako_group_create(v: PHiValue); stdcall; // 変数vをグループ型に変更する
begin
  hi_group_create(v);
end;

procedure nako_group_addMember(group, member: PHiValue); stdcall; // グループ変数groupにメンバmemberを追加する
begin
  hi_group(group).Add(member);
end;

function nako_group_findMember(group: PHiValue; memberName: PAnsiChar): PHiValue; stdcall; // グループ変数groupのメンバmemberNameを検索する
var
  vid: DWORD;
  s: AnsiString;
begin
  s := memberName;
  s := DeleteGobi(s);
  vid := hi_tango2id(s);
  group := hi_getLink(group);
  Result := hi_group(group).FindMember(vid);
end;

function nako_group_exec(group: PHiValue; memberName: PAnsiChar): PHiValue; stdcall; // グループ変数groupのメンバmemberNameがイベントならば実行し結果を返す
begin
  Result := HiSystem.RunGroupEvent(group, hi_tango2id(DeleteGobi(memberName)));
end;

function nako_debug_nadesiko(p: PAnsiChar; len: DWORD): DWORD; stdcall; // nako_loadした構文木を再度ソースに変換する
var s: AnsiString;
begin
  s := HiSystem.DebugProgramNadesiko;
  Result := Length(s);
  StrLCopy(PAnsiChar(s), p, len);
end;

procedure nako_ary_create(p: PHiValue); stdcall; // p を配列として生成する
begin
  hi_ary_create(p);
end;

procedure nako_ary_add(ary, val: PHiValue); stdcall; // p を配列として生成する
begin
  hi_ary(ary).Add(val);
end;

procedure nako_check_tag(tag:Integer; name: DWORD); stdcall; // 命令タグが重複してないかチェック
begin
  _checkTag(tag, name);
end;

procedure nako_DebugNextStop; stdcall; // 次の命令で終了する
begin
  HiSystem.DebugNextStop := True;
end;

procedure nako_LoadPlugins; stdcall; // プラグインを取り込む
begin
  HiSystem.LoadPlugins;
end;

function nako_openPackfile(fname: PAnsiChar): Integer; stdcall; // 実行ファイル fname のパックファイルを開く。失敗なら、0を返す。
begin
  errLog('nako_openPackfile:' + AnsiString(fname));
  if OpenPackFile(string(AnsiString(fname))) then
  begin
    FileMixReader.autoDelete := True;
    Result := Integer(FileMixReader);
  end else
  begin
    Result := 0;
  end;
end;

function nako_runPackfile: DWORD; stdcall; // nako_openPackfile で開いたファイルにある nadesiko.nako を開いて実行する。失敗は、nako_NGを返す。
var
  src: AnsiString;
begin
  Result := nako_NG;

  if FileMixReader = nil then Exit;
  try
    if not FileMixReader.ReadFileAsString('nadesiko.nako', src) then Exit;
  except
    on e:Exception do begin
      errLog('nako_runPackfile.load.error:' + AnsiString(e.Message));
      Exit;
    end;
  end;
  try
    HiSystem.MainFileNo := HiSystem.LoadSourceText(src, 'nadesiko.nako');
  except
    on e:Exception do begin
      errLog('nako_runPackfile.run.error:' + AnsiString(e.Message));
      Exit;
    end;
  end;
  Result := nako_OK;
end;

function nako_openPackfileBin(packname: PAnsiChar): Integer; stdcall; // packname のパックファイルを開く。失敗なら、0を返す。
begin
  errLog('nako_openPackfileBin:' + AnsiString(packname));

  try
    unit_pack_files.FileMixReader := TFileMixReader.Create(string(AnsiString(packname)));
    unit_pack_files.FileMixReader.autoDelete := True;
    unit_pack_files.FileMixReaderSelfCreate := True;
    Result := Integer(unit_pack_files.FileMixReader);
  except
    Result := 0;
  end;
end;


function nako_closePackfile(dummy: PAnsiChar): Integer; stdcall; // 実行ファイルのパックファイルを閉じる（後片付け）。失敗なら、0を返す。
begin
  if FileMixReader <> nil then
  begin
    errLog('nako_closePackfile:' + AnsiString(FileMixReader.TempFile));
    try
      FreeAndNil(FileMixReader);
    except
    end;
  end;
  Result := 0;
end;


function nako_getPackFileHandle: Integer; stdcall; // 実行ファイルにした時、パックファイルの操作に必要な、TMixFileReaderのハンドルを返す。
begin
  Result := Integer(FileMixReader);
end;

procedure nako_setPackFileHandle(handle: DWORD); stdcall; // 実行ファイルにした時で、実行ファイル側でパックファイルを開いた場合この関数を呼ぶ
begin
  unit_pack_files.FileMixReader := TFileMixReader(Integer(handle));
end;

procedure nako_makeReport(fname: PAnsiChar); stdcall; // 取り込んだファイル、プラグインのレポートを作成する
var
  s: AnsiString;
  path: string;
begin
  s := HiSystem.makeDllReport;
  path := ExtractFilePath(fname);
  ForceDirectories(path);
  FileSaveAll(s, fname);
end;

procedure nako_reportDLL(fname: PAnsiChar); stdcall; // DLLを利用したことを明示する..レポートに加える
begin
  HiSystem.plugins.addDll(string(AnsiString(fname)));
end;

function nako_hasPlugins(dllName: PAnsiChar): BOOL; stdcall; // 指定したプラグインが使われているか？
var
  i: Integer;
  f: AnsiString;
  s: string;
  dll: AnsiString;
begin
  Result := False;
  dll := AnsiString(dllName);
  dll := UpperCaseEx(dll);

  for i := 0 to HiSystem.plugins.Count - 1 do
  begin
    s := THiPlugin(HiSystem.plugins.Items[i]).FullPath;
    s := (ExtractFileName(s));
    f := UpperCaseEx(AnsiString(s));
    if f = dll then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure nako_hash_create(v: PHiValue); stdcall; // 値vをハッシュ形式に変換する
begin
  hi_hash_create(v);
end;
function nako_hash_get(hash: PHiValue; key: PAnsiChar): PHiValue; stdcall; // hashのkeyの値を取得する
begin
  hi_hash_create(hash);
  Result := hi_hash_get(hash, key);
end;
procedure nako_hash_set(hash: PHiValue; key: PAnsiChar; value: PHiValue); stdcall; // hashのkeyにvalueを設定する
begin
  hi_hash_create(hash);
  hi_hash_set(hash, key, value);
end;
function nako_hash_keys(hash: PHiValue; s: PAnsiChar; len: Integer): Integer; stdcall; // hashのkey一覧を得る
var
  list: AnsiString;
begin
  hi_hash_create(hash);
  list := hi_hash(hash).EnumKeys;
  StrLCopy(s, PAnsiChar(list), len);
  Result := Length(list);
end;

procedure nako_getLineNo(fileNo, lineNo: PInteger); stdcall; // 現在の実行行を得る
begin
  // ---
  fileNo^ := HiSystem.LastFileNo; // error
  lineNo^ := HiSystem.LastLineNo;
  //
end;

function nako_getSourceText(fileNo: Integer; s: PAnsiChar; len: DWORD): DWORD; stdcall; // 現在の実行行を得る
var
  txt: AnsiString;
begin
  txt := HiSystem.GetSourceText(fileNo);
  Result := Length(txt);
  if len > 0 then StrLCopy(s, PAnsiChar(txt), len);
end;

function nako_getFilename(fileNo: Integer; outstr: PAnsiChar; len: DWORD): DWORD; stdcall; // fileno からファイル名を得る
var
  f: THimaFile;
  s: AnsiString;
begin
  f := HiSystem.TokenFiles.FindFileNo(fileNo);
  s := AnsiString(f.Path + f.Filename);
  if len > 0 then StrLCopy(outstr, PAnsiChar(s), len);
  Result := nako_OK;
end;

procedure nako_pushRunFlag; // イベントの実行前に実行フラグを退避しておきたいときに使う
begin
  HiSystem.PushRunFlag;
end;

procedure nako_popRunFlag; // イベントの実行前に実行フラグを退避したものを戻すときに使う
begin
  HiSystem.PopRunFlag;
end;

function nako_callSysFunction(func_id:DWORD; args: PHiValue):PHiValue; stdcall; // なでしこのシステム関数をIDを指定して呼ぶ
var
  p: PHiValue;
  HiFunc: THiFunction;
  a: THiArray;
begin
  Result := nil;
  if (args = nil) then
  begin
    a := THiArray.Create;
  end else
  begin
    a := THiArray(args.ptr);
  end;
  p := HiSystem.Namespace.GetVar(func_id);
  if p = nil then Exit;
  if p.VType = varFunc then
  begin
    HiFunc := p.ptr;
    try
      Result := THimaSysFunction(HiFunc.PFunc)(a);
    finally
    end;
  end;
end;

procedure nako_setDNAKO_DLL_handle(h: DWORD); stdcall; // dnako.dll をロードしたときに、そのハンドルをセットする
begin
  dnako_dll_handle := h;
end;

procedure nako_setPluginsDir(path: PAnsiChar); stdcall; // plug-ins フォルダを指定する
begin
  HiSystem.PluginsDir := string(path);
end;

function nako_getPluginsDir(): PAnsiChar; stdcall; // plug-ins フォルダを取得する
begin
  Result := PAnsiChar(AnsiString(HiSystem.PluginsDir));
end;

procedure test; stdcall; // テスト
begin
  HiSystem.Test;
end;

function nako_getVersion(): PAnsiChar; stdcall; // なでしこのバージョンを文字列で得る
begin
  Result := PAnsiChar(NADESIKO_VER);
end;

function nako_getUpdateDate(): PAnsiChar; stdcall; // なでしこの更新日を文字列で得る
begin
  Result := PAnsiChar(NADESIKO_DATE);
end;

function nako_getNADESIKO_GUID(): PAnsiChar; stdcall; // なでしこのGUIDを返す
begin
  Result := PAnsiChar(NADESIKO_GUID);
end;

function nako_getEmbedFile(find_file: PAnsiChar; outfile: PAnsiChar; len: DWORD): BOOL; stdcall; // 実行ファイルに埋め込まれたリソースがあればファイルを返す
var
  f, org: AnsiString;
begin
  Result := False;
  org := AnsiString(find_file);
  f := org;
  if getEmbedFile(f) then
  begin
    StrLCopy(outfile, PAnsiChar(f), len);
    Result := True;
  end;
end;

function nako_getLastUserFuncID():DWORD; stdcall;// 最後に実行したユーザー関数を得る
begin
  Result := LastUserFuncID;
end;

function nako_checkLicense(license_name:PAnsiChar; license_code:PAnsiChar): DWORD; stdcall;// ライセンスされているか確認する
var
  path: AnsiString;
  code: AnsiString;
begin
  Result := nako_NG;
  path := AnsiString(AppDataDir) + 'com.nadesi.dll.dnako\license\';
  path := path + AnsiString(license_name);
  if not FileExists(string(path)) then Exit;
  code := FileLoadAll(path);
  if AnsiString(license_code) = code then
  begin
    Result := nako_OK;
  end;
end;

function nako_registerLicense(license_name:PAnsiChar; license_code:PAnsiChar): DWORD; stdcall;// ライセンスコードを書き込む
var
  path: AnsiString;
begin
  Result := nako_NG;
  try
    path := AnsiString(AppDataDir) + 'com.nadesi.dll.dnako\license\';
    ForceDirectories(string(path));
    path := path + AnsiString(license_name);
    FileSaveAll(AnsiString(license_code), path);
    Result := nako_OK;
  except
    Exit;
  end;
end;

///<DNAKOAPI:END>


exports
  nako_getVersion,
  nako_getUpdateDate,
  nako_resetAll,
  nako_free,
  nako_load,
  nako_loadSource,
  nako_run,
  nako_run_ex,
  nako_getError,
  nako_eval,
  nako_evalEx,
  nako_addFileCommand,
  nako_getVariable,
  nako_setVariable,
  nako_addFunction,
  nako_addFunction2,
  nako_getSore,
  nako_id2tango,
  nako_tango2id,
  nako_var2str,
  nako_var2int,
  nako_var2double,
  nako_var2extended,
  nako_str2var,
  nako_int2var,
  nako_double2var,
  nako_var_new,
  nako_getFuncArg,
  nako_addIntVar,
  nako_addStrVar,
  nako_varCopyData,
  nako_varCopyGensi,
  nako_getGroupMember,
  nako_stop,
  nako_continue,
  nako_setMainWindowHandle,
  nako_getMainWindowHandle,
  nako_addSetterGetter,
  nako_setDebugEditorHandle,
  nako_setDebugLineNo,
  nako_group_create,
  nako_group_addMember,
  nako_group_findMember,
  nako_group_exec,
  nako_debug_nadesiko,
  nako_ary_create,
  nako_ary_add,
  nako_check_tag,
  nako_DebugNextStop,
  nako_var_clear,
  nako_var2cstr,
  nako_LoadPlugins,
  nako_var_free,
  nako_bin2var,
  nako_openPackfile,
  nako_runPackfile,
  nako_closePackfile,
  nako_openPackfileBin,
  nako_getPackFileHandle,
  nako_makeReport,
  nako_hasPlugins,
  nako_hash_create,nako_hash_get,nako_hash_set,nako_hash_keys,
  nako_getLineNo,
  nako_getSourceText,
  nako_error_continue,
  nako_ary_get,
  nako_ary_getCsv,
  nako_ary_count,
  nako_hasEvent,
  nako_pushRunFlag,
  nako_popRunFlag,
  nako_callSysFunction,
  nako_reportDLL,
  nako_setPackFileHandle,
  nako_setDNAKO_DLL_handle,
  nako_getPluginsDir,
  nako_setPluginsDir,
  nako_clearError,
  nako_getNADESIKO_GUID,
  nako_getEmbedFile,
  nako_getFilename,
  nako_getLastUserFuncID,
  nako_checkLicense,
  nako_registerLicense,
  nako_getVariableFromId,
  test;
  
begin
end.
 