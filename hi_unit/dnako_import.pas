
unit dnako_import;
///
/// dnako.dll の API を定義したもの
/// generated by DLL宣言抜き出し.nako
///
interface

uses
  {$IFDEF Win32}
  Windows,
  ShlObj,
  {$ELSE}
  unit_fpc,
  {$ENDIF}
  SysUtils,
  dnako_import_types
  ;

/// DLLの取り込み
function dnako_import_init(dllfile: string): THandle;
procedure dnako_import_initFunctions(handle: THandle);

const
  nako_OK= 1;
  nako_NG = 0;

/// APIの定義
var // インポート関数の名前を宣言
  //●なでしこのシステムをリセットする
  nako_resetAll : procedure (); stdcall;
  //●なでしこのシステムを解放する
  nako_free : procedure (); stdcall;
  //●『なでしこ』のソースファイルを読み込む
  nako_load : function (sourceFile: PAnsiChar): DWORD; stdcall;
  //●『なでしこ』のソースファイルを読み込む
  nako_loadSource : function (sourceText: PAnsiChar): DWORD; stdcall;
  //●nako_load() で読んだソースファイルを実行する
  nako_run : function (): DWORD; stdcall;
  //●nako_load() で読んだソースファイルを実行する
  nako_run_ex : function (): PHiValue; stdcall;
  //●エラーで止まった実行を続ける
  nako_error_continue : function (): DWORD; stdcall;
  //●エラーメッセージを取得する。戻り値にはエラーメッセージの長さを返す。
  nako_getError : function (msg: PAnsiChar; maxLen: Integer): DWORD; stdcall;
  //●現在表示されているエラー情報を消す。
  nako_clearError : procedure (); stdcall;
  //●source に与えられた文字列をプログラムとして評価して結果を返す
  nako_eval : function (source: PAnsiChar): PHiValue; stdcall;
  //●source に与えられた文字列をプログラムとして評価して実行結果と成功したかどうかを返す
  nako_evalEx : function (source: PAnsiChar; var ret: PHiValue): BOOL; stdcall;
  //●ファイル関連の命令を使えるようにシステムに登録する。
  nako_addFileCommand : procedure (); stdcall;
  //●なでしこに登録されている変数のポインタを取得する
  nako_getVariable : function (vname: PAnsiChar): PHiValue; stdcall;
  //●ID番号からなでしこに登録されている変数のポインタを取得する
  nako_getVariableFromId : function (vname_id: DWORD): PHiValue; stdcall;
  //●なでしこに変数を登録する(グローバルとして)
  nako_setVariable : procedure (vname: PAnsiChar; value: PHiValue); stdcall;
  //●独自関数を追加する
  nako_addFunction : function (name, args: PAnsiChar; func: THimaSysFunction; tag: Integer): DWORD; stdcall;
  //●独自関数を追加する
  nako_addFunction2 : function (name, args: PAnsiChar; func: THimaSysFunction; tag: Integer; IzonFiles: PAnsiChar): DWORD; stdcall;
  //●nako_addFunction で登録したコールバック関数から引数を取り出すのに使う
  nako_getFuncArg : function (handle: DWORD; index: Integer): PHiValue; stdcall;
  //●変数『それ』へのポインタを取得する
  nako_getSore : function (): PHiValue; stdcall;
  //●整数型の変数をシステムに追加する。(tagには希望の単語IDを指定)
  nako_addIntVar : procedure (name: PAnsiChar; value: Integer; tag: Integer); stdcall;
  //●文字列型の変数をシステムに追加する。
  nako_addStrVar : procedure (name: PAnsiChar; value: PAnsiChar; tag: Integer); stdcall;
  //●システムの実行を中止する
  nako_stop : procedure (); stdcall;
  //●システムの実行を継続する
  nako_continue : procedure (); stdcall;
  //●単語管理用IDから単語名を取得する。戻り値は常に単語の長さを返す。
  nako_id2tango : function (id: DWORD; tango: PAnsiChar; maxLen: DWORD): DWORD; stdcall;
  //●単語名から単語管理用IDを取得する
  nako_tango2id : function (tango: PAnsiChar): DWORD; stdcall;
  //●PHiValueを文字列に変換してstrにコピーする。
  nako_var2str : function (value: PHiValue; str: PAnsiChar; maxLen: DWORD): DWORD; stdcall;
  //●PHiValueをヌル終端文字列に変換してstrにコピーする。内容が途中で途切れる可能性もある。
  nako_var2cstr : function (value: PHiValue; str: PAnsiChar; maxLen: DWORD): DWORD; stdcall;
  //●PHiValueをLongintに変換して得る
  nako_var2int : function (value: PHiValue): Integer; stdcall;
  //●PHiValueをDoubleに変換して得る
  nako_var2double : function (value: PHiValue): Double; stdcall;
  //●PHiValueをExtendedに変換して得る
  nako_var2extended : function (value: PHiValue): Extended; stdcall;
  //●ヌル文字列を PHiValue に変換してセット
  nako_str2var : procedure (str: PAnsiChar; value: PHiValue); stdcall;
  //●バイナリデータを文字列としてvalueにセット
  nako_bin2var : procedure (bin: PAnsiChar; len: DWORD; value: PHiValue); stdcall;
  //●ヌル文字列を PHiValue に変換してセット
  nako_int2var : procedure (num: Integer; value: PHiValue); stdcall;
  //●ヌル文字列を PHiValue に変換してセット
  nako_double2var : procedure (num: Double; value: PHiValue); stdcall;
  //●新規 PHiValue の変数を作成する。nameにnilを渡すと変数名をつけないで値だけ作成し変数名をつけるとグローバル変数として登録する。
  nako_var_new : function (name: PAnsiChar): PHiValue; stdcall;
  //●変数 value の値をクリアする
  nako_var_clear : procedure (value: PHiValue); stdcall;
  //●変数 value の値を解放する
  nako_var_free : procedure (value: PHiValue); stdcall;
  //●v を配列として v[index]の値を得る
  nako_ary_get : function (v: PHiValue; index: Integer): PHiValue; stdcall;
  //●v を二次元配列として v[Row][Col]の値を得る
  nako_ary_getCsv : function (v: PHiValue; Row, Col: Integer): PHiValue; stdcall;
  //●v の配列の要素数を得る
  nako_ary_count : function (v: PHiValue): Integer; stdcall;
  //●PHiValue型の変数の内容をまるまるコピーする
  nako_varCopyData : procedure (src, dest: PHiValue); stdcall;
  //●PHiValue型の変数の内容をコピーする(原始型のみ複製)
  nako_varCopyGensi : procedure (src, dest: PHiValue); stdcall;
  //●メインウィンドウハンドルを設定する（ダイアログ表示関連の命令で利用）
  nako_setMainWindowHandle : procedure (h: Integer); stdcall;
  //●メインウィンドウハンドルを取得する（ダイアログ表示関連の命令で利用）
  nako_getMainWindowHandle : function ():DWORD; stdcall;
  //●グループのメンバを取得する。メンバが存在しなければnilが返る。
  nako_getGroupMember : function (groupName, memberName: PAnsiChar): PHiValue; stdcall;
  //●グループのメンバを取得する。メンバが存在しなければnilが返る。
  nako_hasEvent : function (groupName, memberName: PAnsiChar): PHiValue; stdcall;
  //●変数名vnameにゲッターセッターを設定する
  nako_addSetterGetter : procedure (vname, setter, getter:PAnsiChar; tag: DWORD); stdcall;
  //●デバッグ中のエディタハンドルを設定する
  nako_setDebugEditorHandle : procedure (h: DWORD); stdcall;
  //●デバッグ中のエディタへ行番号を表示するか
  nako_setDebugLineNo : procedure (b: BOOL); stdcall;
  //●変数vをグループ型に変更する
  nako_group_create : procedure (v: PHiValue); stdcall;
  //●グループ変数groupにメンバmemberを追加する
  nako_group_addMember : procedure (group, member: PHiValue); stdcall;
  //●グループ変数groupのメンバmemberNameを検索する
  nako_group_findMember : function (group: PHiValue; memberName: PAnsiChar): PHiValue; stdcall;
  //●グループ変数groupのメンバmemberNameがイベントならば実行し結果を返す
  nako_group_exec : function (group: PHiValue; memberName: PAnsiChar): PHiValue; stdcall;
  //●nako_loadした構文木を再度ソースに変換する
  nako_debug_nadesiko : function (p: PAnsiChar; len: DWORD): DWORD; stdcall;
  //●p を配列として生成する
  nako_ary_create : procedure (p: PHiValue); stdcall;
  //●p を配列として生成する
  nako_ary_add : procedure (ary, val: PHiValue); stdcall;
  //●命令タグが重複してないかチェック
  nako_check_tag : procedure (tag:Integer; name: DWORD); stdcall;
  //●次の命令で終了する
  nako_DebugNextStop : procedure (); stdcall;
  //●プラグインを取り込む
  nako_LoadPlugins : procedure (); stdcall;
  //●実行ファイル fname のパックファイルを開く。失敗なら、0を返す。
  nako_openPackfile : function (fname: PAnsiChar): Integer; stdcall;
  //●nako_openPackfile で開いたファイルにある nadesiko.nako を開いて実行する。失敗は、nako_NGを返す。
  nako_runPackfile : function (): DWORD; stdcall;
  //●packname のパックファイルを開く。失敗なら、0を返す。
  nako_openPackfileBin : function (packname: PAnsiChar): Integer; stdcall;
  //●実行ファイルのパックファイルを閉じる（後片付け）。失敗なら、0を返す。
  nako_closePackfile : function (dummy: PAnsiChar): Integer; stdcall;
  //●実行ファイルにした時、パックファイルの操作に必要な、TMixFileReaderのハンドルを返す。
  nako_getPackFileHandle : function (): Integer; stdcall;
  //●実行ファイルにした時で、実行ファイル側でパックファイルを開いた場合この関数を呼ぶ
  nako_setPackFileHandle : procedure (handle: DWORD); stdcall;
  //●取り込んだファイル、プラグインのレポートを作成する
  nako_makeReport : procedure (fname: PAnsiChar); stdcall;
  //●DLLを利用したことを明示する..レポートに加える
  nako_reportDLL : procedure (fname: PAnsiChar); stdcall;
  //●指定したプラグインが使われているか？
  nako_hasPlugins : function (dllName: PAnsiChar): BOOL; stdcall;
  //●値vをハッシュ形式に変換する
  nako_hash_create : procedure (v: PHiValue); stdcall;
  //●hashのkeyの値を取得する
  nako_hash_get : function (hash: PHiValue; key: PAnsiChar): PHiValue; stdcall;
  //●hashのkeyにvalueを設定する
  nako_hash_set : procedure (hash: PHiValue; key: PAnsiChar; value: PHiValue); stdcall;
  //●hashのkey一覧を得る
  nako_hash_keys : function (hash: PHiValue; s: PAnsiChar; len: Integer): Integer; stdcall;
  //●現在の実行行を得る
  nako_getLineNo : procedure (fileNo, lineNo: PInteger); stdcall;
  //●現在の実行行を得る
  nako_getSourceText : function (fileNo: Integer; s: PAnsiChar; len: DWORD): DWORD; stdcall;
  //●fileno からファイル名を得る
  nako_getFilename : function (fileNo: Integer; outstr: PAnsiChar; len: DWORD): DWORD; stdcall;
  //●イベントの実行前に実行フラグを退避しておきたいときに使う
  nako_pushRunFlag : procedure (); stdcall;
  //●イベントの実行前に実行フラグを退避したものを戻すときに使う
  nako_popRunFlag : procedure (); stdcall;
  //●なでしこのシステム関数をIDを指定して呼ぶ
  nako_callSysFunction : function (func_id:DWORD; args: PHiValue):PHiValue; stdcall;
  //●dnako.dll をロードしたときに、そのハンドルをセットする
  nako_setDNAKO_DLL_handle : procedure (h: DWORD); stdcall;
  //●plug-ins フォルダを指定する
  nako_setPluginsDir : procedure (path: PAnsiChar); stdcall;
  //●plug-ins フォルダを取得する
  nako_getPluginsDir : function (): PAnsiChar; stdcall;
  //●テスト
  test : procedure (); stdcall;
  //●なでしこのバージョンを文字列で得る
  nako_getVersion : function (): PAnsiChar; stdcall;
  //●なでしこの更新日を文字列で得る
  nako_getUpdateDate : function (): PAnsiChar; stdcall;
  //●なでしこのGUIDを返す
  nako_getNADESIKO_GUID : function (): PAnsiChar; stdcall;
  //●実行ファイルに埋め込まれたリソースがあればファイルを返す
  nako_getEmbedFile : function (find_file: PAnsiChar; outfile: PAnsiChar; len: DWORD): BOOL; stdcall;
  //●最後に実行したユーザー関数を得る
  nako_getLastUserFuncID : function ():DWORD; stdcall;
  //●ライセンスされているか確認する
  nako_checkLicense : function (license_name:PAnsiChar; license_code:PAnsiChar): DWORD; stdcall;
  //●ライセンスコードを書き込む
  nako_registerLicense : function (license_name:PAnsiChar; license_code:PAnsiChar): DWORD; stdcall;


implementation

const CSIDL_COMMON_APPDATA = $0023;

{$IFDEF Win32}
function GetSpecialFolder(const loc:Word): string;
var
   PathID: PItemIDList;
   Path : array[0..MAX_PATH] of char;
begin
   SHGetSpecialFolderLocation(0, loc, PathID);
   SHGetPathFromIDList(PathID, Path);
   Result := string(Path);
   if Copy(Result, Length(Result),1)<>'\' then
    Result := Result + '\';
end;
{$ELSE}
function GetSpecialFolder(const loc:Word): string;
begin
    if loc = CSIDL_COMMON_APPDATA then
    begin
        Result := '~/';
    end else begin
        Result := '';
    end;
end;
{$ENDIF}

function CommonAppData:string;
begin
  Result := GetSpecialFolder(CSIDL_COMMON_APPDATA);
end;


// dnako.dll のメインハンドル
var
  dnako_import_handle: THandle = 0;

/// DLLの取り込み
function dnako_import_init(dllfile: string): THandle;
var
  path: string;
begin
  if dnako_import_handle <> 0 then
  begin
  	Result := dnako_import_handle; Exit;
  end;
  // load
  // --- DEFAULT : PACKFILE
  {$IFDEF Win32}
  dnako_import_handle := LoadLibrary(PChar(dllfile));
  {$ELSE}
  dnako_import_handle := LoadLibrary(dllfile);
  {$ENDIF}
  // --- in APPPATH or WINDOWS or SYSTEM32
  if dnako_import_handle = 0 then
  begin
    dnako_import_handle := LoadLibrary('dnako.dll');
    if dnako_import_handle = 0 then // ダメ元で読んでみる
    begin
      dnako_import_handle := LoadLibrary('plug-ins\dnako.dll');
      if dnako_import_handle = 0 then // ダメ元で読んでみる
      begin
        path := CommonAppData + 'com.nadesi\plug-ins\dnako.dll';
        dnako_import_handle := LoadLibrary(PChar(path));
      end;
    end;
  end;
  if dnako_import_handle = 0 then
  begin
  	Result := 0; Exit;
  end;
  Result := dnako_import_handle;
  // get address
  dnako_import_initFunctions(Result);
end;

procedure dnako_import_initFunctions(handle: THandle);
begin
  dnako_import_handle := handle;
  // get address
  nako_resetAll := GetProcAddress(dnako_import_handle,'nako_resetAll');
  nako_free := GetProcAddress(dnako_import_handle,'nako_free');
  nako_load := GetProcAddress(dnako_import_handle,'nako_load');
  nako_loadSource := GetProcAddress(dnako_import_handle,'nako_loadSource');
  nako_run := GetProcAddress(dnako_import_handle,'nako_run');
  nako_run_ex := GetProcAddress(dnako_import_handle,'nako_run_ex');
  nako_error_continue := GetProcAddress(dnako_import_handle,'nako_error_continue');
  nako_getError := GetProcAddress(dnako_import_handle,'nako_getError');
  nako_clearError := GetProcAddress(dnako_import_handle,'nako_clearError');
  nako_eval := GetProcAddress(dnako_import_handle,'nako_eval');
  nako_evalEx := GetProcAddress(dnako_import_handle,'nako_evalEx');
  nako_addFileCommand := GetProcAddress(dnako_import_handle,'nako_addFileCommand');
  nako_getVariable := GetProcAddress(dnako_import_handle,'nako_getVariable');
  nako_getVariableFromId := GetProcAddress(dnako_import_handle,'nako_getVariableFromId');
  nako_setVariable := GetProcAddress(dnako_import_handle,'nako_setVariable');
  nako_addFunction := GetProcAddress(dnako_import_handle,'nako_addFunction');
  nako_addFunction2 := GetProcAddress(dnako_import_handle,'nako_addFunction2');
  nako_getFuncArg := GetProcAddress(dnako_import_handle,'nako_getFuncArg');
  nako_getSore := GetProcAddress(dnako_import_handle,'nako_getSore');
  nako_addIntVar := GetProcAddress(dnako_import_handle,'nako_addIntVar');
  nako_addStrVar := GetProcAddress(dnako_import_handle,'nako_addStrVar');
  nako_stop := GetProcAddress(dnako_import_handle,'nako_stop');
  nako_continue := GetProcAddress(dnako_import_handle,'nako_continue');
  nako_id2tango := GetProcAddress(dnako_import_handle,'nako_id2tango');
  nako_tango2id := GetProcAddress(dnako_import_handle,'nako_tango2id');
  nako_var2str := GetProcAddress(dnako_import_handle,'nako_var2str');
  nako_var2cstr := GetProcAddress(dnako_import_handle,'nako_var2cstr');
  nako_var2int := GetProcAddress(dnako_import_handle,'nako_var2int');
  nako_var2double := GetProcAddress(dnako_import_handle,'nako_var2double');
  nako_var2extended := GetProcAddress(dnako_import_handle,'nako_var2extended');
  nako_str2var := GetProcAddress(dnako_import_handle,'nako_str2var');
  nako_bin2var := GetProcAddress(dnako_import_handle,'nako_bin2var');
  nako_int2var := GetProcAddress(dnako_import_handle,'nako_int2var');
  nako_double2var := GetProcAddress(dnako_import_handle,'nako_double2var');
  nako_var_new := GetProcAddress(dnako_import_handle,'nako_var_new');
  nako_var_clear := GetProcAddress(dnako_import_handle,'nako_var_clear');
  nako_var_free := GetProcAddress(dnako_import_handle,'nako_var_free');
  nako_ary_get := GetProcAddress(dnako_import_handle,'nako_ary_get');
  nako_ary_getCsv := GetProcAddress(dnako_import_handle,'nako_ary_getCsv');
  nako_ary_count := GetProcAddress(dnako_import_handle,'nako_ary_count');
  nako_varCopyData := GetProcAddress(dnako_import_handle,'nako_varCopyData');
  nako_varCopyGensi := GetProcAddress(dnako_import_handle,'nako_varCopyGensi');
  nako_setMainWindowHandle := GetProcAddress(dnako_import_handle,'nako_setMainWindowHandle');
  nako_getMainWindowHandle := GetProcAddress(dnako_import_handle,'nako_getMainWindowHandle');
  nako_getGroupMember := GetProcAddress(dnako_import_handle,'nako_getGroupMember');
  nako_hasEvent := GetProcAddress(dnako_import_handle,'nako_hasEvent');
  nako_addSetterGetter := GetProcAddress(dnako_import_handle,'nako_addSetterGetter');
  nako_setDebugEditorHandle := GetProcAddress(dnako_import_handle,'nako_setDebugEditorHandle');
  nako_setDebugLineNo := GetProcAddress(dnako_import_handle,'nako_setDebugLineNo');
  nako_group_create := GetProcAddress(dnako_import_handle,'nako_group_create');
  nako_group_addMember := GetProcAddress(dnako_import_handle,'nako_group_addMember');
  nako_group_findMember := GetProcAddress(dnako_import_handle,'nako_group_findMember');
  nako_group_exec := GetProcAddress(dnako_import_handle,'nako_group_exec');
  nako_debug_nadesiko := GetProcAddress(dnako_import_handle,'nako_debug_nadesiko');
  nako_ary_create := GetProcAddress(dnako_import_handle,'nako_ary_create');
  nako_ary_add := GetProcAddress(dnako_import_handle,'nako_ary_add');
  nako_check_tag := GetProcAddress(dnako_import_handle,'nako_check_tag');
  nako_DebugNextStop := GetProcAddress(dnako_import_handle,'nako_DebugNextStop');
  nako_LoadPlugins := GetProcAddress(dnako_import_handle,'nako_LoadPlugins');
  nako_openPackfile := GetProcAddress(dnako_import_handle,'nako_openPackfile');
  nako_runPackfile := GetProcAddress(dnako_import_handle,'nako_runPackfile');
  nako_openPackfileBin := GetProcAddress(dnako_import_handle,'nako_openPackfileBin');
  nako_closePackfile := GetProcAddress(dnako_import_handle,'nako_closePackfile');
  nako_getPackFileHandle := GetProcAddress(dnako_import_handle,'nako_getPackFileHandle');
  nako_setPackFileHandle := GetProcAddress(dnako_import_handle,'nako_setPackFileHandle');
  nako_makeReport := GetProcAddress(dnako_import_handle,'nako_makeReport');
  nako_reportDLL := GetProcAddress(dnako_import_handle,'nako_reportDLL');
  nako_hasPlugins := GetProcAddress(dnako_import_handle,'nako_hasPlugins');
  nako_hash_create := GetProcAddress(dnako_import_handle,'nako_hash_create');
  nako_hash_get := GetProcAddress(dnako_import_handle,'nako_hash_get');
  nako_hash_set := GetProcAddress(dnako_import_handle,'nako_hash_set');
  nako_hash_keys := GetProcAddress(dnako_import_handle,'nako_hash_keys');
  nako_getLineNo := GetProcAddress(dnako_import_handle,'nako_getLineNo');
  nako_getSourceText := GetProcAddress(dnako_import_handle,'nako_getSourceText');
  nako_getFilename := GetProcAddress(dnako_import_handle,'nako_getFilename');
  nako_pushRunFlag := GetProcAddress(dnako_import_handle,'nako_pushRunFlag');
  nako_popRunFlag := GetProcAddress(dnako_import_handle,'nako_popRunFlag');
  nako_callSysFunction := GetProcAddress(dnako_import_handle,'nako_callSysFunction');
  nako_setDNAKO_DLL_handle := GetProcAddress(dnako_import_handle,'nako_setDNAKO_DLL_handle');
  nako_setPluginsDir := GetProcAddress(dnako_import_handle,'nako_setPluginsDir');
  nako_getPluginsDir := GetProcAddress(dnako_import_handle,'nako_getPluginsDir');
  test := GetProcAddress(dnako_import_handle,'test');
  nako_getVersion := GetProcAddress(dnako_import_handle,'nako_getVersion');
  nako_getUpdateDate := GetProcAddress(dnako_import_handle,'nako_getUpdateDate');
  nako_getNADESIKO_GUID := GetProcAddress(dnako_import_handle,'nako_getNADESIKO_GUID');
  nako_getEmbedFile := GetProcAddress(dnako_import_handle,'nako_getEmbedFile');
  nako_getLastUserFuncID := GetProcAddress(dnako_import_handle,'nako_getLastUserFuncID');
  nako_checkLicense := GetProcAddress(dnako_import_handle,'nako_checkLicense');
  nako_registerLicense := GetProcAddress(dnako_import_handle,'nako_registerLicense');

end;

end.
