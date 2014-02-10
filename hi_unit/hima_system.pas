unit hima_system;
//------------------------------------------------------------------------------
// 構文木を実行する
//------------------------------------------------------------------------------

interface

uses
  Windows, SysUtils, Classes, hima_types, hima_parser, hima_token, hima_variable,
  hima_variable_ex, hima_function, hima_stream, mmsystem, unit_pack_files;

const
  MAX_STACK_COUNT = 4096; // 再帰スタックの最大数(あまり大きくするとDelphi自体がオーバーフローする)
const
  nako_OK= 1;
  nako_NG = 0;

type
  THiScope = class;

  THiNamespace = class(THList) // THiScope がリストにぶら下がっている
  private
    FCurSpace: THiScope;
    function GetCurSpace: THiScope;
    procedure SetCurSpaceE(const Value: THiScope);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; override;
    procedure ExecuteGroupDestructor;
    procedure CreateNewSpace(NamespaceID: Integer);
    procedure SetCurSpace(id: Integer);
    function FindSpace(id: Integer): THiScope;
    function GetVar(id: DWORD): PHiValue; // 現在のネームスペースから変数を検索
    function GetVarNamespace(NamespaceID: Integer; WordID: DWORD): PHiValue; // ネームスペース中の変数を取得する
    function EnumKeysAndValues(UserOnly: Boolean = False): AnsiString;
    function GetTopSpace: THiScope;
    property CurSpace: THiScope read GetCurSpace write SetCurSpaceE;
  end;

  THiScope = class(THIDHash) // HASH
  private
    function FreeItem(item: PHIDHashItem; ptr: Pointer): Boolean;
    function subEnumKeys(item: PHIDHashItem; ptr: Pointer): Boolean;
    function subEnumKeysAndValues(item: PHIDHashItem; ptr: Pointer): Boolean;
    function subEnumKeysAndValuesUserOnly(item: PHIDHashItem; ptr: Pointer): Boolean;
    function subExecGroupDestructor(item: PHIDHashItem; ptr: Pointer): Boolean;
  public
    Parent: THiScope;
    ScopeID: Integer; // DebugInfo.FileNo と同じ
    procedure RegistVar(v: PHiValue);
    function GetVar(id: DWORD): PHiValue;
    procedure Clear; override;
    constructor Create;
    destructor Destroy; override;
    procedure ExecGroupDestructor;
    function EnumKeys: AnsiString;
    function EnumKeysAndValues(UserOnly: Boolean = False): AnsiString;
  end;

  THiGroupScope = class(THList) // グループはグローバル変数としても登録されるのでここでは解放しない
  private
    jisin: PHiValue;
  public
    constructor Create;
    destructor Destroy; override;
    function FindMember(NameID: DWORD): PHiValue;
    procedure PushGroupScope(FScope: THiGroup);
    procedure PopGroupScope;
    function TopItem: THiGroup;
  end;

  THiVarScope = class(THObjectList) // ローカルスコープの生成破棄を行う
  public
    function FindVar(NameID: DWORD): PHiValue;
    procedure PushVarScope;
    procedure PopVarScope;
    function TopItem: THiScope;
    function HasLocal: Boolean;
  end;

  //----------------------------------------------------------------------------
  // プラグイン管理用
  THiPlugin = class
  public
    FullPath: string;
    Handle: THandle;
    ID: Integer;
    Used: Boolean;
    memo: string;
    NotUseAutoFree: Boolean;
    constructor Create;
    destructor Destroy; override;
  end;
  //
  THiPlugins = class(THObjectList) // プラグイン管理用リスト
  public
    function UsedList: string; // 利用されたプラグインのみを返す
    procedure ChangeUsed(id, PluginID: Integer; Value: Boolean; memo: string; IzonFiles: string);
    procedure addDll(fname: string);
    function find(fname: string): Integer;
  end;

  THiBreakType = (btNone, btContinue, btBreak);
  PHiRunFlag = ^THiRunFlag;
  THiRunFlag = record
    BreakLevel      : Integer;
    BreakType       : THiBreakType;
    ReturnLevel     : Integer;
    FFuncBreakLevel : Integer;
    FNestCheck      : Integer;
    CurNode         : TSyntaxNode;
  end;

  THiOutLangType = (langNako, langLua);
  //----------------------------------------------------------------------------
  // インタプリタ・システムを表す型
  THiSystem = class
  private
    FlagInit: Boolean;
    FNowLoadPluginId: Integer; // plugin読み込み時に一時的に利用する変数
    // システム命令の追加を管理するタグ(ヘルプファイル番号の重複を防ぐための簡易的なもの)
    FTime: DWORD;
    FRunFlagList: THList;
    FPluginsDir: string;
    // システム命令を追加する
    procedure CheckInitSystem;
    procedure AddSystemCommand;
    // 命令の追加に使う手続き
    procedure AddStrVar(const name, value: AnsiString; const tag: Integer; const kaisetu, yomigana: AnsiString);
    procedure AddIntVar(const name: AnsiString; const value, tag: Integer; const kaisetu, yomigana: AnsiString);
    procedure AddFunc(name, argStr: AnsiString; tag: Integer; func: THimaSysFunction; kaisetu, yomigana: AnsiString; FIzonFiles: AnsiString = '');
    procedure constListClear;
    function GetGlobalSpace: THiScope;
    function GetBokanPath: string;
    procedure SetFlagEnd(const Value: Boolean);
    function getRunFlag: THiRunFlag;
    procedure setRunFlag(RunFlag: THiRunFlag);
    procedure SetPluginsDir(const Value: string);
  public
    TokenFiles: THimaFiles;
    TopSyntaxNode: TSyntaxNode;
    TangoList: THimaTangoList;  // 単語 <--> ID を保持
    JosiList:  THimaJosiList;   // 助詞 <--> ID を保持
    DefFuncList: THObjectList;  // 関数宣言のリスト
    ConstList: THList;
    FlagStrict: Boolean;        // 厳格に宣言などが必要か？
    FlagVarInit: Boolean;       // 変数の初期化が必要か？
    FlagSystem: Byte;           // システム定義かどうか？(0:USER 1:SYSTEM)
    //
    FFlagEnd: Boolean;          // 終了判定フラグ
    BreakLevel: Integer;        // Break / Continue を制御する
    BreakType: THiBreakType;    // Break or Continue
    FJumpPoint: DWORD;          // GOTO 文の実装のため
    FFuncBreakLevel: Integer;   // 関数のBreak位置
    ReturnLevel: Integer;       // Return を制御する
    FNestCheck  : Integer;
    //
    CurNode, ContinueNode: TSyntaxNode;       // 実行中のノード
    GroupScope: THiGroupScope;  // グループスコープ
    LocalScope: THiVarScope;    // ローカルスコープ
    Namespace: THiNamespace;    // グローバル変数::ネームスペース実装用
    DllNameList: TStringList;  // インポートしたDLLのリスト
    DllHInstList: THList;
    DebugEditorHandle: THandle; // 行番号の送信や停止処理のため
    DebugLineNo: Boolean;
    Speed: Integer;             // 実行ウェイト
    Sore: PHiValue;
    kaisu,errMsg, taisyou: PHiValue;
    MainFileNo: Integer;        // デバッグのためにメインファイル監視用
    FlagSystemFile: Boolean;
    plugins: THiPlugins;
    DebugNextStop: Boolean;
    LastFileNo: Integer; // デバッグのために
    LastLineNo: Integer;
    FDummyGroup: PHiValue;
    FIncludeBasePath: string; // 取り込み中のBasePath
    runtime_error: Boolean;
    //
    constructor Create;
    destructor Destroy; override;
    // --- 外部から操作される部分 ---
    function LoadFromFile(Source: string): Integer;       // ソース読み込み→構文木作成
    function LoadSourceText(Source, SourceName: AnsiString): Integer; // ソース読み込み→構文木作成
    function Run: PHiValue;                       // 読み込んだ構文木を実行
    procedure Run2;                               // 読み込んだ構文木を実行(値を返さない)
    function Eval(Source: AnsiString): PHiValue;      // ソース文字列を指定するとすぐ実行する
    procedure Eval2(Source: AnsiString);              // ソース文字列を指定するとすぐ実行する(値を返さない)
    function GetVariable(VarID: DWORD): PHiValue; // 変数の取得
    function GetVariableRaw(VarID: DWORD): PHiValue; // 変数の取得
    function GetVariableNoGroupScope(VarID: DWORD): PHiValue; // 変数の取得
    function GetVariableS(vname: AnsiString): PHiValue; // 変数の取得
    function ExpandStr(s: string): string;       // 文字列の展開
    procedure AddSystemFileCommand;               // ちょっと危険？なファイル関連の命令をシステムに追加する
    procedure LoadPlugins;                         // プラグインのロード
    function ErrorContinue: PHiValue;             // エラーで止まったノードを続ける
    procedure ErrorContinue2;
    // --- たまに使う部分
    function ImportFile(FName: string; var node: TSyntaxNode): PHiValue; // 取り込み
    function RunNode(node: TSyntaxNode; IsNoGetter: Boolean = False): PHiValue; // 構文木を渡して実行させる
    procedure RunNode2(node: TSyntaxNode; IsNoGetter: Boolean = False);         // 構文木を渡して実行させる(値を返さない)
    function CreateHiValue(VarId: Integer = 0): PHiValue;
    function Local: THiScope;
    procedure PushScope; // ローカルスコープの作成
    procedure PopScope;  // ローカルスコープの破棄
    procedure SetSetterGetter(VarName, SetterName, GetterName: AnsiString; tag: Integer; Description, yomi: AnsiString); // セッターゲッターの設定
    function AddFunction(name, argStr: AnsiString; func: THimaSysFunction; tag: Integer; FIzonFiles: AnsiString): Boolean;
    function DebugProgram(n: TSyntaxNode; lang: THiOutLangType = langNako): AnsiString;
    function DebugProgramNadesiko: AnsiString;
    function RunGroupEvent(group: PHiValue; memberId: DWORD): PHiValue;
    function RunGroupMethod(group, method: PHiValue; args: THObjectList): PHiValue;
    property Global: THiScope read GetGlobalSpace;
    property BokanPath: string read GetBokanPath;
    property FlagEnd: Boolean read FFlagEnd write SetFlagEnd;
    function GetSourceText(FileNo: Integer): AnsiString;
    procedure Test;
    procedure PushRunFlag; // Eval などで実行を遮る時に使う
    procedure PopRunFlag;
    function makeDllReport: AnsiString;
    property PluginsDir: string read FPluginsDir write SetPluginsDir;
  end;

  TImportNakoSystem = procedure; stdcall;
  TPluginRequire    = function : DWORD; stdcall;

  HException = class(Exception)
    constructor Create(msg: AnsiString);
  end;

// HiSystem は唯一のもの(Singleton)
function HiSystem: THiSystem;
procedure HiSystemReset; // Reset...

// 簡易用手続き
// 単語ID から 単語名を得る
function hi_id2tango(id: DWORD): AnsiString;
function hi_tango2id(tango: AnsiString): DWORD;
function hi_id2fileno(id: DWORD): Integer;

procedure _initTag;
procedure _checkTag(tag:Integer; name: DWORD);
procedure nako_var_free(value: PHiValue); stdcall; // 変数 value の値を解放する
function nako_getFuncArg(handle: DWORD; index: Integer): PHiValue; stdcall; // nako_addFunction で登録したコールバック関数から引数を取り出すのに使う
function nako_getSore: PHiValue; stdcall; // 変数『それ』へのポインタを取得する

function getArg(h: DWORD; Index: Integer; UseHokan: Boolean = False): PHiValue;
function getArgInt(h: DWORD; Index: Integer; UseHokan: Boolean = False): Integer;
function getArgIntDef(h: DWORD; Index: Integer; Def:Integer): Integer;
function getArgStr(h: DWORD; Index: Integer; UseHokan: Boolean = False): AnsiString;
function getArgBool(h: DWORD; Index: Integer; UseHokan: Boolean = False): Boolean;
function getArgFloat(h: DWORD; Index: Integer; UseHokan: Boolean = False): HFloat;

function nako_var_new(name: PAnsiChar): PHiValue; stdcall; // 新規 PHiValue の変数を作成する。nameにnilを渡すと変数名をつけないで値だけ作成し変数名をつけるとグローバル変数として登録する。
function nako_getVariable(vname: PAnsiChar): PHiValue; stdcall;// なでしこに登録されている変数のポインタを取得する

procedure AddFunc(name, argStr: AnsiString; tag: Integer; func: THimaSysFunctionD;
  kaisetu, yomigana: AnsiString; IzonFiles: AnsiString = '');
function nako_addFunction2(name, args: PAnsiChar; func: THimaSysFunction; tag: Integer; IzonFiles: PAnsiChar): DWORD; stdcall; // 独自関数を追加する
procedure nako_addStrVar(name: PAnsiChar; value: PAnsiChar; tag: Integer); stdcall; // 文字列型の変数をシステムに追加する。

procedure AddStrVar(name, value: AnsiString; tag: Integer; kaisetu, yomigana: AnsiString);

const
  BREAK_OFF = MaxInt;



var FHiSystem: THiSystem = nil;// private にすべし
var dnako_dll_handle: THandle = 0;

implementation

uses hima_error, hima_string, unit_string, unit_file_dnako, mini_file_utils,
  unit_windows_api, ConvUtils, nadesiko_version, unit_file;

// ここでFHiSystemの初期化を行うこと
//   initialization で初期化を行うと、ユニットの循環が問題で HiSystem が
//   生成された後に initialization が呼び出され不具合が起こる
//   また、Create の中で HiSystem が参照されないようにすべき
//   そのため、AddSystemVar は一度目の LoadFromFileで呼ばれる

function HiSystem: THiSystem;
begin
  if FHiSystem = nil then
  begin
    FHiSystem := THiSystem.Create;
  end;
  Result := FHiSystem;
end;

// 単語ID から 単語名を得る
function hi_id2tango(id: DWORD): AnsiString;
begin
  Result := HiSystem.TangoList.FindKey(id);
end;

function hi_tango2id(tango: AnsiString): DWORD;
begin
  Result := HiSystem.TangoList.GetID(tango);
end;

function hi_id2fileno(id: DWORD): Integer;
var
  f: THimaFile;
begin
  Result := -1;
  f := HiSystem.TokenFiles.FindFile(string(hi_id2tango(id)));
  if f <> nil then Result := f.Fileno;
end;

var ctag: array [0..1000] of Byte; // 1 byte = 8 個のチェック(1000 * 8) = 8000 個の命令を管理できる

procedure _initTag;
//var i: Integer;
begin
  ZeroMemory(@ctag[0], Length(ctag));
  //for i := low(ctag) to high(ctag) do ctag[i] := 0;
end;

procedure _checkTag(tag:Integer; name: DWORD);
var
  i: Integer;

  function __blank(tag: Integer; check: Boolean = False): Boolean;
  var idx, bit: Integer; msk: Byte;
  begin
    Result := True;
    if tag = 0 then Exit;
    // 特定のビットを調べる
    idx := tag div 8;
    bit := tag mod 8;
    if idx > high(ctag) then Exit;

    // ビットを調べる
    msk := 1 shl bit; // マスクビットの作成

    // 空いてるなら TRUE に
    Result := ((ctag[idx] and msk) = 0);

    // チェックをつけるか？
    if check then ctag[idx] := ctag[idx] or msk;
  end;

begin
  // 0 なら調べない
  if (tag <= 0) then Exit;

  // レポート
  if not __blank(tag) then
  begin
    // 何番ならあいているのか調べる
    i := tag - 1;
    while not __blank(i) do Dec(i);
    // レポートの表示
    debugs(
      '[命令タグ重複] tag='+
      AnsiString(IntToStr(tag))+
      ' name='+hi_id2tango(name) +#13#10 +
       'それ以前の空白番号=' + AnsiString(IntToStr(i)));
    //raise Exception.Create('[命令タグ重複] tag='+IntToStr(tag));
  end;

  // ビットをセットする
  __blank(tag, True);
end;

procedure nako_var_free(value: PHiValue); stdcall; // 変数 value の値を解放する
begin
  if value = nil then Exit;

  if value.Registered = 1 then
    hi_var_clear(value)  // ユーザー削除付加
  else
    hi_var_free(value);  // ユーザー削除可
end;

function nako_getFuncArg(handle: DWORD; index: Integer): PHiValue; stdcall; // nako_addFunction で登録したコールバック関数から引数を取り出すのに使う
var
  a: THiArray;
begin
  a := THiArray(handle);    // handle = THiArray へのアドレス

  Assert((a is THiArray), 'nako_getFuncArgに不正なハンドルが渡されました。');

  if a.Count > index then
  begin
    Result := a.Items[index]; // nil は nil として返す
  end else
  begin
    Result := nil;
  end;
  if (Result <> nil) then
  begin
    if Result.VType = varLink then Result := hi_getLink(Result);
  end;
end;

function nako_getSore: PHiValue; stdcall; // 変数『それ』へのポインタを取得する
begin
  Result := HiSystem.Sore;
end;

// 引数を簡単に取得する
function getArg(h: DWORD; Index: Integer; UseHokan: Boolean = False): PHiValue;
begin
  Result := nako_getFuncArg(h, Index);
  if (Result = nil)and(UseHokan) then
  begin
    Result := nako_getSore;
  end;
end;
function getArgInt(h: DWORD; Index: Integer; UseHokan: Boolean = False): Integer;
begin
  Result := hi_int(getArg(h, Index,UseHokan));
end;
function getArgIntDef(h: DWORD; Index: Integer; Def:Integer): Integer;
var p:PHiValue;
begin
  p := nako_getFuncArg(h, Index);
  if p = nil then
  begin
    Result := Def;
  end else
  begin
    Result := hi_int(p);
  end;
end;
function getArgStr(h: DWORD; Index: Integer; UseHokan: Boolean = False): AnsiString;
begin
  Result := hi_str(getArg(h, Index,UseHokan));
end;
function getArgBool(h: DWORD; Index: Integer; UseHokan: Boolean = False): Boolean;
begin
  Result := hi_bool(getArg(h, Index,UseHokan));
end;
function getArgFloat(h: DWORD; Index: Integer; UseHokan: Boolean = False): HFloat;
begin
  Result := hi_float(getArg(h, Index,UseHokan));
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

function nako_getVariable(vname: PAnsiChar): PHiValue; stdcall;// なでしこに登録されている変数のポインタを取得する
var
  id: DWORD;
begin
  id := hi_tango2id(DeleteGobi(vname));
  Result := HiSystem.GetVariable(id);
end;

procedure AddFunc(name, argStr: AnsiString; tag: Integer; func: THimaSysFunctionD;
  kaisetu, yomigana: AnsiString; IzonFiles: AnsiString = '');
begin
  try
    _checkTag(tag, 0);
  except
    on e:Exception do
    begin
      raise;
      //raise Exception.Create('『'+name+'』(tag='+IntToStr(tag)+')が重複しています。');
    end;
  end;
  nako_addFunction2(
    PAnsiChar(name),
    PAnsiChar(argStr),
    THimaSysFunction(func),
    tag,
    PAnsiChar(IzonFiles));
end;

function nako_addFunction2(name, args: PAnsiChar; func: THimaSysFunction; tag: Integer; IzonFiles: PAnsiChar): DWORD; stdcall; // 独自関数を追加する
begin
  if HiSystem.AddFunction(name, args, func, tag, IzonFiles) then
    Result := NAKO_OK
  else
    Result := NAKO_NG;
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

procedure AddStrVar(name, value: AnsiString; tag: Integer; kaisetu, yomigana: AnsiString);
begin
  _checkTag(tag, 0);
  nako_addStrVar(PAnsiChar(name), PAnsiChar(value), tag);
end;


{ THiSystem }

procedure THiSystem.AddFunc(name, argStr: AnsiString; tag: Integer;
  func: THimaSysFunction; kaisetu, yomigana: AnsiString;
  FIzonFiles: AnsiString = '');
var item: PHiValue; id: Integer;
begin
  name := DeleteGobi(name);
  id := TangoList.GetID(name, tag);
  _checkTag(tag, id);
  item := CreateHiValue(id);
  item.VarID := id;
  item.Designer := 1;

  hi_func_create(item);
  with THiFunction(item.ptr) do
  begin
    PFunc     := @func;
    FuncType  := funcSystem;
    Args.DefineArgs(argStr);
    IzonFiles := FIzonFiles;
  end;
end;

function THiSystem.AddFunction(name, argStr: AnsiString;
  func: THimaSysFunction; tag: Integer; FIzonFiles: AnsiString): Boolean;
var item: PHiValue; id: Integer;
begin
  // 外部/内部からのコマンド追加
  HiSystem.CheckInitSystem;

  Result := True;
  try
    name := DeleteGobi(name);
    id := TangoList.GetID(name, tag);

    item := CreateHiValue(id);
    item.VarID := id;
    item.Designer := 1; // SYSTEM

    hi_func_create(item);
    with THiFunction(item.ptr) do
    begin
      PluginID  := FNowLoadPluginId;
      PFunc     := @func;
      FuncType  := funcSystem;
      IzonFiles := FIzonFiles;
      Args.DefineArgs(argStr);
    end;

  except
    Result := False;
  end;
end;

procedure THiSystem.AddIntVar(const name: AnsiString; const value, tag: Integer;
  const kaisetu, yomigana: AnsiString);
var item: PHiValue; id: Integer;
begin
  id := TangoList.GetID(DeleteGobi(name), tag);
  _checkTag(tag, id);
  item := CreateHiValue(id);
  item.VType := varStr;
  item.VarID := id;
  item.Designer := 1;
  hi_setInt(item, value);
end;

procedure THiSystem.AddStrVar(const name, value: AnsiString; const tag: Integer;
  const kaisetu, yomigana: AnsiString);
var item: PHiValue; id: Integer;
begin
  id := TangoList.GetID(DeleteGobi(name), tag);
  _checkTag(tag, id);
  item := CreateHiValue(id);
  item.VarID := id;
  item.VType := varStr; // なぜか削られてしまったので再度追加
  item.Designer := 1; // 1:SYSTEM
  hi_setStr(item, value);
end;

procedure THiSystem.AddSystemCommand;

  function _setCmdLine: AnsiString;
  var
    i: Integer;
    p, a: PHiValue;
  begin
    p := Global.GetVar(hi_tango2id('コマンドライン'));
    if p = nil then p := CreateHiValue(hi_tango2id('コマンドライン'));

    hi_ary_create(p);
    for i := 0 to ParamCount do
    begin
      a := hi_newStr(AnsiString(ParamStr(i)));
      hi_ary(p).Add(a);
    end;
  end;

  procedure Reserved(name, argStr: AnsiString; tag: Integer; kaisetu, yomigana: AnsiString);
  var
    id: Integer;
    item: PHiValue;
  begin
    name := DeleteGobi(name);
    id := TangoList.GetID(name);
    _checkTag(tag, id);

    item := CreateHiValue(id);
    item.VarID := id;
    item.ReadOnly := 1;
    item.VType := varNil;
    item.Designer := 1;
  end;

  function getRuntime: AnsiString;
  begin
    Result := AnsiString(
      UpperCase(ExtractFileName(ParamStr(0)))
    );
  end;

  procedure hi_makeAlias;
  var
    v: PHiValue;
  begin
    // それ
    v := GetVariable(hi_tango2id('_'));
    hi_setLink(v, Sore);
    v := GetVariable(hi_tango2id('そう'));
    hi_setLink(v, Sore);

    // 自身
    {
    v := GetVariable(token_jisin);
    hi_var_copyGensi(FDummyGroup, v);
    if v.VType <> varGroup then raise Exception.Create('自身がグループになりません。');
    }
  end;

begin
  //todo 1: ■システム変数関数(BASE)

  FNowLoadPluginId := -1; // システム命令は-1

  // --- 引数の規則 ---
  // {型=省略時のデフォルト}変数名＋助詞 変数名＋助詞 ... | 変数名＋助詞
  // =? は基本的に変数「それ」が代入される(今のところ呼び出される関数の中で対処)
  //<システム変数関数>

  //+システム
  //-バージョン情報
  AddStrVar('ナデシコバージョン',    {'(バージョン毎に違う)'}NADESIKO_VER , 100, '実行中のなでしこのバージョン','なでしこばーじょん');
  AddStrVar('ナデシコ最終更新日',    {'(バージョン毎に違う)'}NADESIKO_DATE, 101, 'バージョンの更新日','なでしこさいしゅうこうしんび');
  AddStrVar('ナデシコランタイム',    {'(起動時に決定)'}getRuntime,    102, 'なでしこエンジンをロードした実行ファイルの名前(大文字)','なでしこらんたいむ');
  AddStrVar('ナデシコランタイムパス',{'(起動時に決定)'}AnsiString(ParamStr(0)),   103, 'なでしこエンジンをロードした実行ファイルのフルパス','なでしこらんたいむぱす');
  AddStrVar('OS',                    {'(起動時に決定)'}getWinVersion, 104, 'OSの種類を保持する。Windows 7/Windows Vista/Windows Server 2003/Windows XP/Windows 2000/Windows Me/Windows 98/Windows NT 4.0/Windows NT 3.51/Windows 95','OS');
  AddStrVar('OSバージョン',          {'(起動時に決定)'}getWinVersionN,105, 'OSのバージョン番号を「Major.Minor(Build:PlatformId)」の形式返す。(4.10=Windows98/5.1=XP/6.0=Vista/6.1=Windows7','OSばーじょん');

  //-基本変数
  AddStrVar('それ',   '', 110, '命令の結果が代入される変数。省略語としても使われる。','それ');
  AddIntVar('はい',    1, 111, 'はい・いいえの選択に使われる。','はい');
  AddIntVar('いいえ',  0, 112, 'はい・いいえの選択に使われる。','いいえ');
  AddIntVar('必要',    1, 113, '必要・不要の選択に使われる。','ひつよう');
  AddIntVar('不要',    0, 114, '必要・不要の選択に使われる。','ふよう');
  AddIntVar('オン',    1, 115, 'オン・オフの選択に使われる。','おん');
  AddIntVar('オフ',    0, 116, 'オン・オフの選択に使われる。','おふ');
  AddIntVar('真',    1, 134, '真・偽の選択に使われる。','しん');
  AddIntVar('偽',    0, 135, '真・偽の選択に使われる。','ぎ');
  //AddIntVar('そ',    0, 117, '直前に操作したグループの名前を省略するのに使う。その××は××の形で使う。','そ');
  AddIntVar('キャンセル',  2, 118, 'はい・いいえ・キャンセルの選択に使われる。','きゃんせる');
  AddStrVar('空',   '', 119, '空っぽ。「」のこと','から');
  AddStrVar('改行',{'#13#10'}#13#10, 120, '改行を表す','かいぎょう');
  AddStrVar('タブ',    {'#9'}#9,     121, 'タブを表す','たぶ');
  AddIntVar('OK', 1,     122, 'OK・NGの選択に使われる。','OK');
  AddIntVar('NG', 0,     123, 'OK・NGの選択に使われる。','NG');
  AddIntVar('成功', 1,     124, '成功・失敗の選択に使われる。','せいこう');
  AddIntVar('失敗', 0,     125, '成功・失敗の選択に使われる。','しっぱい');
  AddStrVar('カッコ',       '「',126, '','かっこ');
  AddStrVar('カッコ閉じ',   '」',127, '','かっことじ');
  AddStrVar('波カッコ',     '{', 128, '','なみかっこ');
  AddStrVar('波カッコ閉じ', '}', 129, '','なみかっことじ');
  AddStrVar('二重カッコ',       '『',130, '','にじゅうかっこ');
  AddStrVar('二重カッコ閉じ',   '』',131, '','にじゅうかっことじ');
  AddStrVar('_','',132,'変数『それ』のエイリアス。','_');
  AddStrVar('そう','',5020,'変数『それ』のエイリアス。','そう');
  //AddIntVar('これ', 0, 5021, '直前に操作したグループの名前を省略するのに使う。これの××は××の形で使う。','これ');

  //-基本命令
  AddFunc  ('言う','{文字列=?}Sを|Sと',       150, sys_say,        'メッセージSをダイアログに表示する。','いう');
  AddFunc  ('ナデシコする','{文字列}Sで|Sを', 151, sys_eval,  '文字列Sの内容をなでしこのプログラムとして実行する。','なでしこする');
  AddFunc  ('EVAL','{文字列}S',               152, sys_eval,  '文字列Sの内容をなでしこのプログラムとして実行する。','EVAL');
  AddFunc  ('いう','{文字列=?}Sを|Sと',       153, sys_say,        'メッセージSをダイアログに表示する。','いう');
  //-デバッグ支援
  AddFunc  ('システム時間','',                171, sys_timeGetTime,'OSが起動してからの時間を取得して返す。','しすてむじかん');
  AddFunc  ('バイナリダンプ','{文字列=?}Sを', 173, sys_binView,'文字列Sをバイナリとして1バイトごと16進数でカンマ区切りにして返す','ばいなりだんぷ');
  AddFunc  ('実行速度設定','Aに', 174, sys_runspeed,'実行速度を遅くしたい場合、Aに1以上の値を設定すると遅くする。','じっこうそくどせってい');
  AddFunc  ('構文木逆参照', '', 149, sys_ref_syntax, 'なでしこ構文木を参照する。','こうぶんきぎゃくさんしょう');
  Reserved ('エラー監視','',     207,'『エラー監視(文A)エラーならば(文B)』の対で使い、文Aを実行中にエラーが発生した時に文Bを実行する。','えらーかんし');
  Reserved ('エラーならば','',   208,'『エラー監視(文A)エラーならば(文B)』の対で使い、文Aを実行中にエラーが発生した時に文Bを実行する。','えらーならば');
  AddFunc  ('エラー発生','{文字列=?}Sで|Sと', 170, sys_except, '故意にエラーを発生させる。','えらーはっせい');
  AddFunc  ('エラー無視','', 189, sys_runtime_error_off, '実行時エラーを無視し実行し続ける。','えらーむし');
  AddStrVar('エラーメッセージ', '', 212, 'エラー監視構文でエラーが発生した時にエラーメッセージを取得する','えらーめっせーじ');
  AddFunc  ('デバッグ', '', 213, sys_debug, 'デバッグダイアログを表示する。','でばっぐ');
  AddFunc  ('ASSERT', 'Aが|Aの|Aを', 214, sys_assert, '条件式Aが0(偽)になると例外を発する。','ASSERT');
  AddFunc  ('ググる', 'Sで|Sを', 487, sys_guguru, 'キーワードSでググる。','ぐぐる');
  AddFunc  ('ナデシコ利用可能プラグイン列挙', '', 486, sys_plugins_enum, '利用可能なプラグインを返す','なでしこりようかのうぷらぐいんれっきょ');

  //-コマンドライン・環境変数
  AddStrVar('コマンドライン', '', 190, 'プログラム起動時のコマンドライン引数を配列形式で得る','こまんどらいん');
  AddFunc  ('環境変数取得','Sの',179, sys_getEnv,'環境変数Sの値を取得','かんきょうへんすうしゅとく');

  //-変数管理
  AddFunc  ('変数列挙','{=?}Sの',             172, sys_EnumVar,'Sに「グローバル|ローカル|システム|ユーザー」(複数可)を指定して変数の一覧を返す。','へんすうれっきょ');
  AddFunc  ('変数確認','{文字列}Sの',         168, sys_ExistsVar,'文字列で与えた変数名Sの詳細情報を返す。存在しなければ空を返す。','へんすうかくにん');
  AddFunc  ('グループ参照コピー','{参照渡し グループ}Aを{参照渡し グループ}Bに|AのBへ', 175, sys_groupCopyRef,   'グループAのエイリアスをグループBに作る。','ぐるーぷさんしょうこぴー');
  AddFunc  ('グループコピー',    '{参照渡し グループ}Aを{参照渡し グループ}Bに|AのBへ', 176, sys_groupCopyVal,   'グループAのメンバ全部をグループBにコピーする。Ｂのメンバは初期化されるので注意。','ぐるーぷこぴー');
  AddFunc  ('グループメンバ追加','{参照渡し グループ}Aを{参照渡し グループ}Bに|AのBへ', 177, sys_groupAddMember,   'グループAのメンバ全部をグループBに追加コピーする。','ぐるーぷめんばついか');
  AddFunc  ('変数エイリアス作成','{参照渡し}Aを{参照渡し}Bに|AのBへ', 178, sys_alias,   '変数Aのエイリアスを変数Bに設定する。','へんすうえいりあすさくせい');
  AddFunc  ('データコピー','{参照渡し}Aを{参照渡し}Bに|AからBへ', 140, sys_copyData,   '変数Aのデータを変数Bのデータへコピーする。','でーたこぴー');
  AddFunc  ('TYPEOF',     '{参照渡し}A',  193, sys_typeof, '変数Aの型を得る','TYPEOF');
  AddFunc  ('変数型確認', '{参照渡し}Aの',163, sys_typeof, '変数Aの型を得る','へんすうかたかくにん');
  //-ポインタ
  AddFunc  ('ADDR',   '{参照渡し}A',191, sys_addr,   '変数Aのポインタ(PHiValue型)を得る','ADDR');
  AddFunc  ('POINTER','{参照渡し}A',192, sys_pointer,'変数Aの保持している生データへのポインタを得る','POINTER');
  AddFunc  ('UNPOINTER','A,B',249, sys_unpointer,'ポインタAのが指すデータを型Bとして読み込む。Bにはデータのサイズを数値としても指定できる。','POINTER');
  AddFunc  ('PACK',   '{グループ}A,{参照渡し}B,S',194, sys_pack,   'グループAをバイナリ構造体としてBにパックする。Sにパックする型を『long,long』と指定する。','PACK');
  AddFunc  ('UNPACK', '{参照渡し}A,{参照渡し グループ}B,S',195, sys_unpack, 'バイナリ構造体AをグループBに振り分ける。Sに振り分ける型を指定する。','UNPACK');
  AddFunc  ('EXEC_PTR', '{文字列=「stdcall」}CALLTYPE,{参照渡し}FUNC,{整数}SIZE,{参照渡し}RECT,RET', 162, EasyExecPointer, '関数ポインタFUNCを実行する。SIZEは引数スタックのサイズ、RECTは引数スタックに積む実データ、RETは返り値の型名を文字列で指定する。CALLTYPEはstdcallかcdeclを指定する(デフォルトはstdcall)。','EXEC_PTR');
  //型変換
  AddFunc  ('文字列変換','{=?}Sを',196, sys_toStr,   '変数Sを文字列に変換して返す','もじれつへんかん');
  AddFunc  ('整数変換',  '{=?}Sを',197, sys_toInt,   '変数Sを整数に変換して返す','せいすうへんかん');
  AddFunc  ('TOSTR','{=?}S',198, sys_toStr,   '変数Sを文字列に変換して返す','TOSTR');
  AddFunc  ('TOINT','{=?}S',199, sys_toInt,   '変数Sを整数に変換して返す','TOINT');
  AddFunc  ('実数変換','{=?}Sを',165, sys_toFloat, '変数Sを実数に変換して返す','じっすうへんかん');
  AddFunc  ('TOFLOAT', '{=?}S',  167, sys_toFloat, '変数Sを実数に変換して返す','TOFLOAT');
  AddFunc  ('ハッシュ変換','{=?}Sを',166, sys_toHash, '変数Sをハッシュに変換して返す','はっしゅへんかん');

  //-宣言
  Reserved('文字列','Sとは', 180,'『(変数名)とは文字列』で変数を宣言する。','もじれつ');
  Reserved('数値',  'Sとは', 181,'『(変数名)とは数値』で変数を宣言する。','すうち');
  Reserved('整数',  'Sとは', 182,'『(変数名)とは整数』で変数を宣言する。','せいすう');
  Reserved('変数',  'Sとは', 183,'『(変数名)とは変数』で変数を宣言する。','へんすう');
  Reserved('配列',  'Sとは', 184,'『(変数名)とは配列』で変数を宣言する。','はいれつ');
  Reserved('実数',  'Sとは', 185,'『(変数名)とは実数』で変数を宣言する。','じっすう');
  Reserved('ハッシュ','Sとは', 186,'『(変数名)とはハッシュ』で変数を宣言する。','はっしゅ');
  Reserved('変数宣言','', 187,'『!変数宣言が必要｜不要』で変数宣言の必要不要を切り替える','へんすうせんげん');
  Reserved('グループ','', 188,'『■グループ（グループ名）』でグループを宣言する','ぐるーぷ');
  Reserved('取り込む','Sを', 5059,'『!「ファイル名」を取り込む』で外部ファイルを取り込む。','とりこむ');
  Reserved('ネームスペース変更','Sに|Sへ', 244,'『!「名前空間名」にネームスペース変更』で名前空間を変更する。','ねーむすぺーすへんこう');

  //+基本構文
  //-フロー制御
  Reserved('もし',  '',         200,'『もし...ならば...違えば...』の対で使い条件分岐構文を表す。','もし');
  Reserved('ならば','',         201,'『もし(条件式)ならば(真の処理)違えば(偽の処理)』で使い条件分岐構文を表す','ならば');
  Reserved('違えば','',         202,'『もし(条件式)ならば(真の処理)違えば(偽の処理)』で使い条件分岐構文を表す','たがえば');
  Reserved('間',    'Sの',      203,'『(条件式)の間...』で条件式が真の時...の文を繰り返し実行する。','あいだ');
  Reserved('反復',  '{=?}Sを|Sで',  204,'『(データS)を反復...』でデータSの要素分繰り返す。繰り返しに際し変数『それ』にデータの要素が代入される。','はんぷく');
  AddStrVar('対象','',164, '『反復』構文で繰り返し対象を指す','たいしょう');
  Reserved('回',    'CNT',      205,'『(CNT)回...』でCNT回...を繰り返す。','かい');
  AddIntVar('回数',    0,       211, '『回』『反復』『繰り返す』『間』で繰り返しが何回目かを代入される','かいすう');
  Reserved('繰り返す','{=?}SでAからBまで|Sを',206,'『(変数)でAからBまで繰り返す...』でAからBまで1ずつ変数Sの内容を増やしながら...の文を繰り返す。変数を省略すると変数「それ」に番号が代入される。','くりかえす');
  Reserved('ループ','Sの',      209,'『(条件式)のループ...』で条件式が真の時...の文を繰り返し実行する。','るーぷ');
  Reserved('条件分岐','Sで',    210,'『(条件式)で条件分岐{改行}(条件)ならば...(条件)ならば...違えば...』で条件により複数の選択肢に実行を分岐する。','じょうけんぶんき');
  Reserved('ここ','',169,'制御構文の最後で『ここまで』と構文の終わりを明示できる。','ここ');
  AddFunc  ('飛ぶ','{=?}JUMPPOINTに|JUMPPOINTへ',161, sys_goto, 'ジャンプポイントへ実行を移す(JUMPPOINTは文字列で指定する)','とぶ');
  //-コメント
  Reserved('#','',157,'# から改行までの範囲をコメントとして扱う。','#');
  Reserved('※','',155,'※から改行の範囲をコメントとして扱う。','※');
  Reserved('//','',159,'//から改行の範囲をコメントとして扱う。','//');
  Reserved('/*..*/','',160,'/* .. */ の範囲をコメントとして扱う。','/*..*/');
  Reserved('、','',158,'行末の「、」は次の行へソースを続けるを意味する。','、');

  //-中断続行終了
  AddFunc  ('抜ける','',                 220, sys_break,      '繰り返しから抜ける。','ぬける');
  AddFunc  ('続ける','',                 221, sys_continue,   '繰り返しの途中で繰り返し範囲の先頭に戻って続ける。','つづける');
  AddFunc  ('終わる','',                 222, sys_end,        'プログラムの実行を中断する。','おわる');
  AddFunc  ('おわり','',                 223, sys_end,        'プログラムの実行を中断する。','おわり');
  AddFunc  ('戻る',  '{=?}Aで|Aを',      224, sys_return,     '関数から実行を戻す。Aには関数の戻り値を指定する。','もどる');
  AddFunc  ('終了','',                   225, sys_end,        'プログラムの実行を中断する。','しゅうりょう');
  //-日本語らしさ
  AddFunc  ('す',  'Aで',                240, sys_echo,     '～です','す');
  AddFunc  ('だ',  'A',                  241, sys_echo,     '～だ',  'だ');
  AddFunc  ('ある','{参照渡し=?}AがB|AがBで|Aに',      242, sys_calc_let,   '変数AにBを代入する。','ある');
  AddFunc  ('あります','{参照渡し=?}AがB|AがBで|Aに',  243, sys_calc_let,   '変数AにBを代入する。','あります');
  AddFunc  ('する','{参照渡し}Bを{=?}Aと|Aに',     246, sys_calc_let,   '値Aを変数Bに代入する。','する');

  //+演算
  //-演算
  AddFunc  ('代入','{=?}Aを{参照渡し}Bに|Bへ', 250, sys_calc_let,   '値AをBに代入する。','だいにゅう');
  AddFunc  ('足す','{=?}AにBを|Aへ|Aと',   251, sys_calc_add,   'Aに数値Bを足して返す。','たす');
  AddFunc  ('引く','{=?}AからBを',         252, sys_calc_sub,   'Aから数値Bを引いて返す。','ひく');
  AddFunc  ('掛ける','{=?}AにBを|Aへ|Aと', 253, sys_calc_mul,   'Aに数値Bを掛けて返す。','かける');
  AddFunc  ('割る','{=?}AをBで',           254, sys_calc_div,   'Aを数値Bで割って返す。','わる');
  AddFunc  ('余り','{=?}AとBの',           255, sys_calc_mod,   'Aと数値Bの余りを返す。','あまり');
  AddFunc  ('割った余り','{=?}AをBで',     248, sys_calc_mod,   '数値Aを数値Bで割った余りを返す。','わったあまり');
  AddFunc  ('合計','{=?}AにBを|Aへ|AとBの', 258, sys_calc_add2,  'AとBの合計を返す。','ごうけい');
  AddFunc  ('倍','{=?}AのB|Aを',            259, sys_calc_mul,  'AのB倍を返す。','ばい');
  AddFunc  ('差','{=?}AとBの',            260, sys_calc_sub,  'AとBの差を返す。','さ');
  AddFunc  ('商','{=?}AとBの',            261, sys_calc_div,  'AとBの商を返す。','しょう');
  AddFunc  ('積','{=?}AとBの',            262, sys_calc_mul,  'AとBの積を返す。','せき');
  AddFunc  ('乗','{=?}AのB',             5024, sys_calc_pow,  'Aを底としてBの累乗を返す。','じょう');
  AddFunc  ('剰余','{=?}AとBの',         5025, sys_calc_mod,  'AとBの剰余を返す。','じょうよ');
  AddFunc  ('倍数','{=?}AがBの',         5070, sys_calc_baisu,  'AがBの倍数か判定してそうならはいを返す。','ばいすう');
  //-演算(直接)
  AddFunc  ('直接足す','{参照渡し}AにBを|Aへ|Aと',   263, sys_calc_add_b, '変数Aに数値Bを足して返す。(Aの内容を変更する)','ちょくせつたす');
  AddFunc  ('直接引く','{参照渡し}AからBを',         264, sys_calc_sub_b, '変数Aから数値Bを引いて返す。(Aの内容を変更する)','ちょくせつひく');
  AddFunc  ('直接掛ける','{参照渡し}AにBを|Aへ|Aと', 265, sys_calc_mul_b,   '変数Aに数値Bを掛けて返す。(Aの内容を変更する)','ちょくせつかける');
  AddFunc  ('直接割る','{参照渡し}AをBで',           266, sys_calc_div_b,   '変数Aを数値Bで割って返す。(Aの内容を変更する)','ちょくせつわる');
  //-比較
  AddFunc  ('以上',  'AがB',  270, sys_comp_GtEq, 'AがB以上なら1を違えば0を返す','いじょう');
  AddFunc  ('以下',  'AがB',  271, sys_comp_LtEq, 'AがB以下なら1を違えば0を返す','いか');
  AddFunc  ('超',    'AがB',  272, sys_comp_Gt,   'AがB超なら1を違えば0を返す','ちょう');
  AddFunc  ('未満',  'AがB',  273, sys_comp_Lt,   'AがB未満なら1を違えば0を返す','みまん');
  AddFunc  ('等しい','AがBと',274, sys_comp_Eq,   'AがBと等しいなら1を違えば0を返す','ひとしい');
  AddFunc  ('ない',  '{=?}AがBで|Bでは',      295, sys_comp_not,   '変数AがBと等しくないなら1を違えば0を返す','ない');
  //-計算関数
  AddFunc  ('INT',   'A',     275, sys_int,       '実数Aの整数部分を返す。Aが文字列なら整数に変換される。','INT');
  AddFunc  ('FLOAT', 'A',     276, sys_float,     'Aを実数に変換して返す。Aが文字列なら実数に変換される。','FLOAT');
  AddFunc  ('SIN',   'A',     277, sys_sin,       'ラジアン単位の角の正弦を返す。','SIN');
  AddFunc  ('COS',   'A',     278, sys_cos,       'ラジアン単位の角の余弦を返す。','COS');
  AddFunc  ('TAN',   'A',    5026, sys_tan,       'ラジアン単位の角の正接を返す。','TAN');
  AddFunc  ('ARCSIN','A',    5027, sys_arcsin,    'ラジアン単位の角の逆正弦を返す。Aは-1～1の間でなければならない。返り値は-PI/2～PI/2の範囲となる。','ARCSIN');
  AddFunc  ('ARCCOS','A',    5028, sys_arccos,    'ラジアン単位の角の逆余弦を返す。Aは-1～1の間でなければならない。返り値は0～PIの範囲となる。','ARCCOS');
  AddFunc  ('ARCTAN','A',     279, sys_arctan,    'ラジアン単位の角の逆正接を返す。','ARCTAN');
  AddFunc  ('CSC',   'A',    5029, sys_csc,       'ラジアン単位の角の余割を返す。','CSC');
  AddFunc  ('SEC',   'A',    5030, sys_sec,       'ラジアン単位の角の正割を返す。','SEC');
  AddFunc  ('COT',   'A',    5031, sys_cot,       'ラジアン単位の角の余接を返す。','COT');
  //('ARCCSC',   'A',    5032, sys_arccsc, 'ラジアン単位の角の逆余割を返す。','ARCCSC');
  //('ARCSEC',   'A',    5033, sys_arcsec, 'ラジアン単位の角の逆正割を返す。','ARCSEC');
  //('ARCCOT',   'A',    5034, sys_arccot, 'ラジアン単位の角の逆余接を返す。','ARCCOT');
  AddFunc  ('正弦','{=?}Aの',    5035, sys_sin,   'ラジアン単位の角の正弦を返す。','せいげん');
  AddFunc  ('余弦','{=?}Aの',    5036, sys_cos,   'ラジアン単位の角の余弦を返す。','よげん');
  AddFunc  ('正接','{=?}Aの',    5037, sys_tan,   'ラジアン単位の角の正接を返す。','せいせつ');
  AddFunc  ('逆正弦','{=?}Aの',  5038, sys_arcsin,'ラジアン単位の角の逆正弦を返す。Aは-1～1の間でなければならない。返り値は-PI/2～PI/2の範囲となる。','ぎゃくせいげん');
  AddFunc  ('逆余弦','{=?}Aの',  5039, sys_arccos,'ラジアン単位の角の逆余弦を返す。Aは-1～1の間でなければならない。返り値は0～PIの範囲となる。','ぎゃくよげん');
  AddFunc  ('逆正接','{=?}Aの',  5040, sys_arctan,'ラジアン単位の角の逆正接を返す。','ぎゃくせいせつ');
  AddFunc  ('余割','{=?}Aの',    5041, sys_csc,   'ラジアン単位の角の余割を返す。','よかつ');
  AddFunc  ('正割','{=?}Aの',    5042, sys_sec,   'ラジアン単位の角の正割を返す。','せいかつ');
  AddFunc  ('余接','{=?}Aの',    5043, sys_cot,   'ラジアン単位の角の余接を返す。','よせつ');
  //('逆余割','{=?}Aの',  5044, sys_arccsc,'ラジアン単位の角の逆余割を返す。','ぎゃくよかつ');
  //('逆正割','{=?}Aの',  5045, sys_arcsec,'ラジアン単位の角の逆正割を返す。','ぎゃくせいかつ');
  //('逆余接','{=?}Aの',  5046, sys_arccot,'ラジアン単位の角の逆余接を返す。','ぎゃくよせつ');
  AddFunc  ('SIGN',      'A',5057, sys_sign,    '数値Aが正ならば1、負ならば-1、ゼロならば0を返す。','SIGN');
  AddFunc  ('符号','{=?}Aの',5058, sys_sign,    '数値Aが正ならば1、負ならば-1、ゼロならば0を返す。','ふごう');
  AddFunc  ('HYPOT',   'A,B',5047, sys_hypot,   '直角三角形の二辺の長さA,Bから斜辺を求めて返す。','HYPOT');
  AddFunc  ('斜辺',  'AとBの',5048, sys_hypot,  '直角三角形の二辺の長さA,Bから斜辺を求めて返す。','しゃへん');
  AddFunc  ('ABS',   'A',     280, sys_abs,       '数値Aの絶対値を返す。','ABS');
  AddFunc  ('整数部分','{=?}Aの',  281, sys_int,   '数値Aの整数部分を返す。','せいすうぶぶん');
  AddFunc  ('絶対値',  '{=?}Aの',  282, sys_abs,   '数値Aの絶対値を返す。','ぜったいち');
  AddFunc  ('EXP',   'A',     283, sys_exp,       'e（自然対数の底）の A 乗の値を返す','EXP');
  AddFunc  ('LN',    'A',     284, sys_ln,        '実数式 A の自然対数（Ln(A) = 1）を返す','LN');
  AddFunc  ('自然対数','{=?}Aの', 5049, sys_ln,   '実数式 A の自然対数（Ln(A) = 1）を返す','しぜんたいすう');
  AddFunc  ('FRAC',  'A',     285, sys_frac,      '実数Aの小数部分を返す','FRAC');
  AddFunc  ('小数部分', '{=?}Aの', 286, sys_frac,'実数Aの小数部分を返す','しょうすうぶぶん');
  AddFunc  ('乱数', '{=?}Aの',     287, sys_rnd,  '0からA-1の乱数を返す','らんすう');
  AddFunc  ('乱数初期化','{整数=?}Aで',288, sys_randomize,  '乱数の種Aで乱数を初期化する。引数を省略すると適当な値で初期化される。','らんすうしょきか');
  AddFunc  ('SQRT',   'A',     289, sys_sqrt,    'Aの平方根を返す','SQRT');
  AddFunc  ('平方根','{=?}Aの',   5050, sys_sqrt,    'Aの平方根を返す','へいほうこん');
  AddFunc  ('HEX',    'A',     290, sys_hex,     'Aを16進数で返す','HEX');
  AddFunc  ('RGB',    'R,G,B', 296, sys_rgb,     'R,G,B(0-255)を指定してカラーコード(なでしこ用$RRGGBB)を返す','RGB');
  AddFunc  ('WRGB',   'R,G,B',5019, sys_wrgb,    'R,G,B(0-255)を指定してカラーコード(Windows用$BBGGRR)を返す','WRGB');
  AddFunc  ('WRGB2RGB',   'COLOR',5051, sys_wrgb2rgb,'カラーコードをWindows用($BBGGRR)からなでしこ用($RRGGBB)に変換して返す','WRGB2RGB');
  AddFunc  ('RGB2WRGB',   'COLOR',5052, sys_wrgb2rgb,'カラーコードをなでしこ用($RRGGBB)からWindows用($BBGGRR)に変換して返す','RGB2WRGB');
  AddFunc  ('ROUND',  'A',     297, sys_round,   '実数型の値Aを丸めてもっとも近い整数値を返す。','ROUND');
  AddFunc  ('四捨五入','Aを',  298, sys_sisyagonyu, '整数Aの一桁目を丸めて返す。','ししゃごにゅう');
  AddFunc  ('CEIL',    'A',    299, sys_ceil,    '数値を正の無限大方向へ切り上げて返す。','CEIL');
  AddFunc  ('切り上げ','Aを',  300, sys_ceil,    '数値を正の無限大方向へ切り上げて返す。','きりあげ');
  AddFunc  ('FLOOR',   'A',    215, sys_floor,   '数値を負の無限大方向へ切り下げて返す。','FLOOR');
  AddFunc  ('切り下げ','Aを',  216, sys_floor,   '数値を負の無限大方向へ切り下げて返す。','きりさげ');
  AddFunc  ('小数点四捨五入','{=?}AをBで',  5010, sys_sisyagonyu2, '整数Aを少数点第B桁で四捨五入して返す','しょうすうてんししゃごにゅう');
  AddFunc  ('小数点切り上げ','{=?}AをBで',  5011, sys_ceil2, '整数Aを少数点第B桁で切り上げして返す','しょうすうてんきりあげ');
  AddFunc  ('小数点切り下げ','{=?}AをBで',  5012, sys_floor2, '整数Aを少数点第B桁で切り下げして返す','しょうすうてんきりさげ');
  AddFunc  ('LOG10','A',       5013, sys_log10, 'Aの対数（基数10）を計算して返す','LOG10');
  AddFunc  ('常用対数','{=?}Aの',5053, sys_log10,'Aの対数（基数10）を計算して返す','じょうようたいすう');
  AddFunc  ('LOG2', 'A',       5014, sys_log2,  'Aの対数（基数2）を計算して返す','LOG2');
  AddFunc  ('LOGN', 'AでBの',  5015, sys_logn,  '指定された底AでBの対数を計算して返す','LOGN');
  AddFunc  ('対数', 'AでBの',  5054, sys_logn,  '指定された底AでBの対数を計算して返す','たいすう');
  AddStrVar('PI',   '3.1415926535897932385',  5016,  '円周率(3.1415926535897932385)','PI');
  AddFunc  ('RAD2DEG', '{=?}Aを',  5017, sys_RAD2DEG,  'ラジアンAを度に変換して返す','RAD2DEG');
  AddFunc  ('DEG2RAD', '{=?}Aを',  5018, sys_DEG2RAD,  '度Aをラジアンをに変換して返す','DEG2RAD');
  AddFunc  ('度変換', '{=?}Aを',  5055, sys_RAD2DEG,  'ラジアンAを度に変換して返す','どへんかん');
  AddFunc  ('ラジアン変換', '{=?}Aを',  5056, sys_DEG2RAD,  '度Aをラジアンをに変換して返す','らじあんへんかん');

  //-論理演算
  AddFunc  ('NOT',    '{整数}A',     291, sys_not,     'A=0のとき1を違えば0を返す','NOT');
  AddFunc  ('OR',     'A,B',   292, sys_or,      'AとBの論理和を返す。日本語の「AまたはB」に相当する','OR');
  AddFunc  ('AND',    'A,B',   293, sys_and,     'AとBの論理積を返す。日本語の「AかつB」に相当する','AND');
  AddFunc  ('XOR',    'A,B',   294, sys_xor,     'AとBの排他的論理和を返す。','XOR');
  //-ビット演算
  AddFunc  ('SHIFT_L','{=?}V,A', 5060, sys_shift_l, 'VをAビット左へシフトして返す。(<<と同じ)','SHIFT_L');
  AddFunc  ('SHIFT_R','{=?}V,A', 5061, sys_shift_r, 'VをAビット右へシフトして返す。(>>と同じ)','SHIFT_R');

  //+文字列処理
  //-文字列基本操作
  AddFunc  ('文字数',    '{文字列=?}Sの',    301, sys_strCountM,'文字列Sの文字数を返す','もじすう');
  AddFunc  ('バイト数',  '{文字列=?}Sの',    302, sys_strCountB,'文字列Sのバイト数を返す','ばいとすう');
  AddFunc  ('行数',      '{文字列=?}Sの',    303, sys_LineCount,'文字列Sの行数を返す','ぎょうすう');
  AddFunc  ('何文字目',  '{文字列=?}SでAが|Sの', 304, sys_posM,'文字列SでAが何文字目かを返す。見つからなければ0。','なんもじめ');
  AddFunc  ('何バイト目','{文字列=?}SでAが|Sの', 305, sys_posB,'文字列SでAが何バイト目かを返す。見つからなければ0。','なんばいとめ');
  AddFunc  ('CHR','A', 306, sys_chr,'文字コードAに対する文字を返す。','CHR');
  AddFunc  ('ASC','A', 307, sys_asc,'文字Aの文字コードを返す。','ASC');
  AddFunc  ('文字挿入',  '{文字列=?}SのCNTにAを', 308, sys_insertM,'文字列SのCNT文字目に文字列Aを挿入して返す。','もじそうにゅう');
  AddFunc  ('バイト挿入','{文字列=?}SのCNTにAを', 309, sys_insertB,'文字列SのCNTバイト目に文字列Aを挿入して返す。','ばいとそうにゅう');
  AddFunc  ('文字検索',  '{文字列=?}Sで{=1}AからBを|Sの', 322, sys_posExM,'文字列SでA文字目からBを検索する。見つからなければ0。','もじけんさく');
  AddFunc  ('バイト検索','{文字列=?}Sで{=1}AからBを|Sの', 323, sys_posExB,'文字列SでAバイト目からBを検索する。見つからなければ0。','ばいとけんさく');
  AddFunc  ('追加','{参照渡し=?}AにBを|Aへ', 324, sys_addStr,'変数AにBの内容を追加する','ついか');
  AddFunc  ('一行追加','{参照渡し=?}AにBを|Aへ', 269, sys_addStrR,'変数AにBの内容と改行を追加する','いちぎょうついか');
  AddFunc  ('文字列分解','{=?}Sを|Sの|Sで', 483, sys_str_splitArray, '文字列Sを１文字ずつ配列変数に分解する','もじれつぶんかい');
  AddFunc  ('リフレイン','{=?}SをCNTだけ', 5023, sys_refrain, '文字列SをCNTだけ繰り返してそれに返す','りふれいん');
  AddFunc  ('出現回数','{文字列=?}SでAの', 5062, sys_word_count,'文字列SでAの出てくる回数を返す','しゅつげんかいすう');
  //-抜き出す
  AddFunc  ('MID', 'S,A,CNT', 310, sys_midM,'文字列SでAからCNT文字分を抜き出して返す','MID');
  AddFunc  ('MIDB','S,A,CNT', 311, sys_midB,'文字列SでAからCNTバイト分を抜き出して返す','MIDB');
  AddFunc  ('文字抜き出す',  '{=?}SのAからCNT|Sで', 312, sys_midM,'文字列SでAからCNT文字分を抜き出して返す','もじぬきだす');
  AddFunc  ('バイト抜き出す','{=?}SのAからCNT|Sで', 313, sys_midB,'文字列SでAからCNTバイト分を抜き出して返す','ばいとぬきだす');
  AddFunc  ('LEFT',   'S,CNT', 314, sys_leftM,'文字列Sの左からCNT文字分を抜き出して返す','LEFT');
  AddFunc  ('LEFTB',  'S,CNT', 315, sys_leftB,'文字列Sの左からCNTバイト分を抜き出して返す','LEFTB');
  AddFunc  ('RIGHT',  'S,CNT', 316, sys_rightM,'文字列Sの右からCNT文字分を抜き出して返す','RIGHT');
  AddFunc  ('RIGHTB', 'S,CNT', 317, sys_rightB,'文字列Sの右からCNTバイト分を抜き出して返す','RIGHTB');
  AddFunc  ('文字左部分',    '{=?}SからCNT|Sの', 318, sys_leftM, '文字列Sの左からCNT文字分を抜き出して返す','もじひだりぶぶん');
  AddFunc  ('バイト左部分',  '{=?}SからCNT|Sの', 319, sys_leftB, '文字列Sの左からCNTバイト分を抜き出して返す','ばいとひだりぶぶん');
  AddFunc  ('文字右部分',    '{=?}SからCNT|Sの', 320, sys_rightM,'文字列Sの右からCNT文字分を抜き出して返す','もじみぎぶぶん');
  AddFunc  ('バイト右部分',  '{=?}SからCNT|Sの', 321, sys_rightB,'文字列Sの右からCNTバイト分を抜き出して返す','ばいとみぎぶぶん');
  AddFunc  ('バイト文章抜き出す','{=?}SのAからCNT|Sで', 268, sys_mid_sjis,'文字列SでAからCNTバイト分を抜き出して返す。(全角文字が壊れないよう配慮)','ばいとぶんしょうぬきだす');
  AddFunc  ('語句列挙','{=?}SからAを|Sで', 327, sys_enumWord,'文字列SからAを','ごくれっきょ');
  //-区切る・切り取る・削除
  AddFunc  ('切り取る','{参照渡し 文字列=?}SからAまで|SのAまでを|SでAを',330, sys_getToken,'文字列Sから区切り文字Aまでを切り取って返す。Sに変数を指定した場合はSの内容が切り取られる。','きりとる');
  AddFunc  ('区切る','{文字列=?}SをAで',  331, sys_split,'文字列Sを区切り文字Aで区切って配列として返す。','くぎる');
  AddFunc  ('文字削除',  '{参照渡し 文字列=?}SのAからB|Sで', 332, sys_deleteM,'文字列SのA文字目からB文字だけ削除する。Sに変数を指定するとSの内容も変更する。','もじさくじょ');
  AddFunc  ('バイト削除','{参照渡し 文字列=?}SのAからB|Sで', 333, sys_deleteB,'文字列SのA文字目からBバイトだけ削除する。Sに変数を指定するとSの内容も変更する。','ばいとさくじょ');
  AddFunc  ('範囲切り取る','{参照渡し 文字列=?}SのAからBまで|SでAからBを|Bまでを',334, sys_getTokenRange,'文字列Sの区切り文字Aから区切り文字Bまでを切り取って返す。Sに変数を指定した場合はSの内容が切り取られる。SにBが存在しないとき、Sの最後まで切り取る。Aが存在しないときは切り取らない。','はんいきりとる');
  AddFunc  ('範囲内切り取る','{参照渡し 文字列=?}SのAからBまで|SでAからBを|Bまでを',335, sys_getTokenInRange,'文字列Sの区切り文字Aから区切り文字Bまでを切り取って返す。Sに変数を指定した場合はSの内容が切り取られる。Sに区切り文字が存在しないとき、切り取りを行わない。','はんいないきりとる');
  AddFunc  ('文字右端削除','{参照渡し=?}SからA|Sを|Sで|Sの',387, sys_deleteRightM,'文字列Sの右端A文字を削除する。Sに変数を指定するとSの内容も変更する。','もじみぎはしさくじょ');
  AddFunc  ('バイト右端削除','{参照渡し=?}SからA|Sを|Sで|Sの',388, sys_deleteRightB,'文字列Sの右端Aバイトを削除する。Sに変数を指定するとSの内容も変更する。','ばいとみぎはしさくじょ');
  //-置換・除去
  AddFunc  ('置換',    '{文字列=?}SのAをBに|SでAからBへ',   340, sys_replace,  '文字列SにあるAを全てBに置換して返す。','ちかん');
  AddFunc  ('単置換',  '{文字列=?}SのAをBに|SでAからBへ', 341, sys_replaceOne,'文字列SにあるAを１つだけBに置換して返す。','たんちかん');
  AddFunc  ('トリム',  '{文字列=?}Sを', 342, sys_trim,'『空白除去』の利用を推奨。文字列Sの前後の半角空白文字を除去して返す。','とりむ');
  AddFunc  ('空白除去','{文字列=?}Sを', 339, sys_trim,'文字列Sの前後の半角空白文字を除去して返す。','くうはくじょきょ');
  AddFunc  ('範囲置換','{文字列=?}SのAからBまでをCで|SでAからBをCに',489, sys_RangeReplace,'文字列SのAからBまでをCに置換して返す。','はんいちかん');
  AddFunc  ('範囲内置換','{文字列=?}SのAからBまでをCで|SでAからBをCに',5022, sys_InRangeReplace,'文字列SのAからBまでをCに置換して返す。SにAまたはBが存在しないとき、置換を行わない。','はんいないちかん');

  //-その他
  AddFunc  ('確保','{参照渡し}SにCNTを', 343, sys_AllocMem,'文字列Sに書き込み領域をCNTバイトを確保する','かくほ');
  AddFunc  ('バイナリ取得','{参照渡し}SのIをFで',    430, sys_getBinary,'バイナリデータSのIバイト目をFの形式(CHAR|CHAR*|INT|BYTE|WORD|DWORD)で取得する。','ばいなりしゅとく');
  AddFunc  ('バイナリ設定','Vを{参照渡し}SのIにFで', 431, sys_setBinary,'値VをバイナリデータSのIバイト目にFの形式(CHAR|CHAR*|INT|BYTE|WORD|DWORD)で設定する。','ばいなりせってい');
  //-正規表現
  AddFunc  ('正規表現マッチ','{=?}AをBで|AがBに', 344, sys_reMatch,'Perl互換の正規表現。文字列AをパターンBでマッチして結果を返す。$1や$2などは配列形式で返す。BREGEXP.DLLを利用。','せいきひょうげんまっち','BREGEXP.DLL');
  AddFunc  ('正規表現置換','{=?}SのAをBへ|AからBに|Bで',   345, sys_reSub,  'Perl互換の正規表現。文字列SのパターンAをBで置換して結果を返す。BREGEXP.DLLを利用。','せいきひょうげんちかん','BREGEXP.DLL');
  AddFunc  ('正規表現区切る','{=?}AをBで', 346, sys_reSplit,'Perl互換の正規表現。文字列AをパターンBで区切って結果を返す。BREGEXP.DLLを利用。','せいきひょうげんくぎる','BREGEXP.DLL');
  AddFunc  ('正規表現入換','{=?}SのAをBへ|AからBに|Bで',   347, sys_reTR,   'Perl互換の正規表現。文字列SにあるパターンAをパターンBで置き換えて結果を返す。BREGEXP.DLLを利用。','せいきひょうげんいれかえ','BREGEXP.DLL');
  AddFunc  ('正規表現単置換','{=?}SのAをBへ|AからBに|Bで',   338, sys_reSubOne,  'Perl互換の正規表現。文字列SのパターンAをBで１度だけ置換して結果を返す。BREGEXP.DLLを利用。','せいきひょうげんたんちかん','BREGEXP.DLL');
  AddFunc  ('RE','{=?}A,B', 348, sys_reMatch,'『正規表現マッチ』を推奨。将来的に廃止を検討。Perl互換の正規表現。文字列AをパターンBでマッチングし結果を返す。$1や$2などは配列形式で返す。BREGEXP.DLLを利用。','RE','BREGEXP.DLL');
  AddStrVar('抽出文字列','',795,'『正規表現マッチ』や『ワイルドカード一致』で抽出した文字列が代入される。','ちゅうしゅつもじれつ');
  AddFunc  ('正規表現一致','{=?}AがBに|AをBで', 349, sys_reMatchBool,'Perl互換の正規表現。文字列AをパターンBに一致するかどうか返す。$1や$2などは配列形式で返す。BREGEXP.DLLを利用。','せいきひょうげんいっち','BREGEXP.DLL');
  AddStrVar('正規表現修飾子','gmk', 337, '正規表現の修飾子を指定。','せいきひょうげんしゅうしょくし');
  //-なでしこ解析
  AddFunc  ('送り仮名省略','{文字列=?}Sから|Sの',325, sys_DeleteGobi,'文字列Sから漢字の送り仮名を省略して返す。','おくりがなしょうりゃく');
  AddFunc  ('トークン分割','{文字列=?}Sを',326, sys_tokenSplit,'文字列Sをトークンを分割して配列形式で返す','とーくんぶんかつ');
  //-指定形式
  AddFunc  ('FORMAT','{文字列=?}SをAで',469,    sys_format,       'データSをAの形式で出力する','FORMAT');
  AddFunc  ('形式指定','{文字列=?}SをAで',470,  sys_format,     'データSをAの形式で出力する','けいしきしてい');
  AddFunc  ('ゼロ埋め','{文字列=?}SをAで',471,  sys_formatzero, 'データSをA桁のゼロで埋めて出力する','ぜろうめ');
  AddFunc  ('通貨形式','{文字列=?}Sを',472,     sys_formatmoney,   'データSをカンマで区切って出力する','つうかけいしき');
  AddFunc  ('文字列センタリング','{文字列=?}SをAで',473, sys_str_center, '文字列SをA桁の中央に来るように出力する','もじれつせんたりんぐ');
  AddFunc  ('文字列右寄せ','{文字列=?}SをAで',474, sys_str_right, '文字列SをA桁の右端に来るように出力する','もじれつみぎよせ');
  //-文字種類判定
  AddFunc  ('全角か判定','{=?}Sが|Sの|Sを',475, sys_zen_kana, '文字列Sの一文字目が全角かどうか判定して返す。','ぜんかくかはんてい');
  AddFunc  ('かなか判定','{=?}Sが|Sの|Sを',476, sys_hira_kana, '文字列Sの一文字目がひらがなか判定して返す。','かなかはんてい');
  AddFunc  ('カタカナか判定','{=?}Sが|Sの|Sを',477, sys_kata_kana, '文字列Sの一文字目がカタカナか判定して返す。','かたかなかはんてい');
  AddFunc  ('数字か判定','{=?}Sが|Sの|Sを',478, sys_suuji_kana, '文字列Sの一文字目が数字か判定して返す。','すうじかはんてい');
  AddFunc  ('数列か判定','{=?}Sが|Sの|Sを',479, sys_suuretu_kana, '文字列S全部が数字か判定して返す。','すうれつかはんてい');
  AddFunc  ('英字か判定','{=?}Sが|Sの|Sを',480, sys_eiji_kana, '文字列Sの一文字目がアルファベットか判定して返す。','えいじかはんてい');
  //-文字列比較
  AddFunc  ('文字列比較','{=?}AとBで|Bを',481, sys_str_comp, '文字列AとBを比較して同じなら0をAが大きければ1をBが大きければ-1を返す。','もじれつひかく');
  AddFunc  ('文字列辞書順比較','{=?}AとBで|Bを',482, sys_str_comp_jisyo, '文字列AとBを辞書順で比較して同じなら0をAが大きければ1をBが大きければ-1を返す。','もじれつじしょじゅんひかく');

  //+配列・ハッシュ・グループ
  //-配列基本操作
  AddFunc  ('配列結合','{=?}AをSで',  350, sys_join,'配列Aを文字列Sで繋げて文字列として返す。','はいれつけつごう');
  AddFunc  ('配列検索','{=?}Aの{整数=0}IからKEYを|Aで',  351, sys_ary_find,'配列Aの要素I番からKEYを検索してそのインデックス番号を返す。見つからなければ-1を返す。','はいれつけんさく');
  AddFunc  ('配列要素数','{=?}Aの',  352, sys_ary_count,'配列Aの要素数を返す。','はいれつようそすう');
  AddFunc  ('配列挿入','{参照渡し=?}AのIにSを|Iから',  353, sys_ary_insert,'配列AのI番目にSを挿入する。Aの内容を書き換える。','はいれつそうにゅう');
  AddFunc  ('配列一括挿入','{参照渡し=?}AのIにSを|Iから',  354, sys_ary_insertEx,'配列AのI番目(0起点)に配列Sの内容を一括挿入する。Aの内容を書き換える。','はいれついっかつそうにゅう');
  AddFunc  ('配列ソート','{参照渡し=?}Aを|Aに',  355, sys_ary_sort,'配列Aを文字列順にソートする。Aの内容を書き換える。','はいれつそーと');
  AddFunc  ('配列数値ソート','{参照渡し=?}Aを|Aに',  356, sys_ary_sort_num,'配列Aを数値順にソートする。Aの内容を書き換える。','はいれつすうちそーと');
  AddFunc  ('配列カスタムソート','{参照渡し=?}AをSで|Aに',  357, sys_ary_sort_custom,'配列AをプログラムS(文字列で与える-比較用変数はAとB)でソートする。Aの内容を書き換える。','はいれつかすたむそーと');
  AddFunc  ('配列逆順','{参照渡し=?}Aを',  358, sys_ary_reverse,'配列Aの並びを逆順にする。Aの内容を書き換える。','はいれつぎゃくじゅん');
  AddFunc  ('配列追加','{参照渡し=?}AにSを', 359, sys_ary_add,'配列Aに要素Sを追加する。Aの内容を書き換える。','はいれつついか');
  AddFunc  ('配列削除','{参照渡し=?}AのIを', 360, sys_ary_del,'配列AのI番目(0起点)の要素を削除する。Aの内容を書き換える。','はいれつさくじょ');
  AddFunc  ('配列シャッフル','{参照渡し=?}Aを|Aの', 361, sys_ary_random,'配列Aの順番をランダムにシャッフルする。Aの内容を書き換える。','はいれつしゃっふる');
  AddFunc  ('変数分配','{=?}AをSへ|AからSに', 369, sys_ary_varSplit,'配列Aの要素の各値を文字列Ｓの変数リスト「変数,変数,変数...」へ分配する。','へんすうぶんぱい');
  AddFunc  ('配列上下空行削除','{参照渡し=?}Aの|Aの', 336, sys_ary_trim,'配列Aの上下にある空行を削除する。','はいれつじょうげくうぎょうさくじょ');
  AddFunc  ('配列切り取る','{参照渡し=?}AのIを', 488, sys_ary_cut,'配列AのI番目(0起点)の要素を切り取って返す。Aの内容を書き換える。','はいれつきりとる');
  AddFunc  ('配列入れ替え','{参照渡し=?}AのIとJを', 5064, sys_ary_exchange,'配列AのI番目(0起点)の要素とJ番目(0起点)の要素を入れ替えて返す。Aの内容を書き換える。','はいれついれかえ');
  AddFunc  ('配列取り出す','{参照渡し=?}AのIからCNTを', 5065, sys_ary_slice,'配列AのI番目(0起点)からCNT個の要素を取り出して返す。Aの内容を書き換える。','はいれつとりだす');
  //-配列計算
  AddFunc  ('配列合計','{=?}Aの', 362, sys_ary_sum,'配列Aの値の合計を調べて答えを返す。','はいれつごうけい');
  AddFunc  ('配列平均','{=?}Aの', 363, sys_ary_mean,'配列Aの値の平均を調べて答えを返す。','はいれつへいきん');
  AddFunc  ('配列標準偏差','{=?}Aの', 364, sys_ary_StdDev,'配列Aの値の標準偏差を調べて答えを返す。','はいれつひょうじゅんへんさ');
  AddFunc  ('配列NORM','{=?}Aの', 365, sys_ary_norm,'配列Aの値のユークリッドの「L-2」ノルムを調べて答えを返す。','はいれつNORM');
  AddFunc  ('配列最大値','{=?}Aの', 366, sys_ary_max,'配列Aの値の最大値を調べて返す。','はいれつさいだいち');
  AddFunc  ('配列最小値','{=?}Aの', 367, sys_ary_min,'配列Aの値の最小値を調べて返す。','はいれつさいしょうち');
  AddFunc  ('配列分散','{=?}Aの', 368, sys_ary_PopnVariance,'配列Aの値の分散度を調べて返す。','はいれつぶんさん');

  //-二次元配列(表)操作
  AddFunc  ('表CSV変換','{=?}Aを', 370, sys_ary_csv,'二次元配列AをCSV形式(カンマ区切りテキスト)で取得して返す。','ひょうCSVへんかん');
  AddFunc  ('表TSV変換','{=?}Aを', 371, sys_ary_tsv,'二次元配列AをTSV形式(タブ区切りテキスト)で取得して返す。','ひょうTSVへんかん');
  AddFunc  ('CSV取得','{=?}Sを|Sの|Sで', 379, sys_csv2ary,'CSV形式のデータを強制的に二次元配列に変換して返す。','CSVしゅとく');
  AddFunc  ('TSV取得','{=?}Sを|Sの|Sで', 380, sys_tsv2ary,'TSV形式のデータを強制的に二次元配列に変換して返す。','TSVしゅとく');
  AddFunc  ('表ソート','{参照渡し=?}AのIを', 372, sys_csv_sort,'二次元配列AでI列目(0起点)をキーに文字列順にソートする。Aの内容を書き換える。','ひょうそーと');
  AddFunc  ('表数値ソート','{参照渡し=?}AのIを', 373, sys_csv_sort_num,'二次元配列AでI列目(0起点)をキーに数値順にソートする。Aの内容を書き換える。','ひょうすうちそーと');
  AddFunc  ('表ピックアップ','{=?}Aの{=-1}IからSを|Aで', 374, sys_csv_pickup,'二次元配列AでI列目(0起点)からキーSを含む行(Sという文字を含むセル)をピックアップして返す。I=-1で全フィールドを対象にする。','ひょうぴっくあっぷ');
  AddFunc  ('表完全一致ピックアップ','{=?}Aの{=-1}IからSを|Aで', 375, sys_csv_pickupComplete,'二次元配列AでI列目(0起点)からキーSを含む行(Sと完全に一致するセルがある)をピックアップして返す。I=-1で全フィールドを対象にする。','ひょうかんぜんいっちぴっくあっぷ');
  AddFunc  ('表検索','{=?}Aの{=-1}COLでSを{=0}ROWから|COLに', 376, sys_csv_find, '二次元配列AでCOL列目(0起点)からキーSを含む行をROW行目から検索して何行目にあるか返す。見つからなければ-1を返す。COL=-1で全フィールドを対象にする。','ひょうけんさく');
  AddFunc  ('表曖昧検索','{=?}Aの{=-1}COLでSを{=0}ROWから|COLに', 394, sys_csv_vague_find, '二次元配列AでCOL列目(0起点)からワイルドカードSにマッチする行をROW行目から検索して何行目にあるか返す。見つからなければ-1を返す。COL=-1で全フィールドを対象にする。','ひょうあいまいけんさく');
  AddFunc  ('表列数','{=?}Aの', 377, sys_csv_cols,'二次元配列Aの列数を取得して返す。','ひょうれつすう');
  AddFunc  ('表行数','{=?}Aの', 378, sys_ary_count,'二次元配列Aの行数を取得して返す。(配列要素数と同じ)','ひょうぎょうすう');
  AddFunc  ('表行列交換','{=?}Aの|Aを', 381, sys_csv_rowcol_rev,'二次元配列Aの行列を反転して返す。','ひょうぎょうれつはんてん');
  AddFunc  ('表右回転','{=?}Aの|Aを',   382, sys_csv_rotate,    '二次元配列Aを９０度回転して返す。','ひょうみぎかいてん');
  AddFunc  ('表重複削除','{=?}AのIを|Iで', 383, sys_csv_uniq, '二次元配列AのI列目にある重複項目を削除して返す。','ひょうじゅうふくさくじょ');
  AddFunc  ('表列取得','{=?}AのIを', 384, sys_csv_getcol, '二次元配列Aの(0から数えて)I列目だけを取り出して配列変数として返す。','ひょうれつしゅとく');
  AddFunc  ('表列挿入','{=?}AのIにSを|Iへ', 385, sys_csv_inscol, '二次元配列Aの(0から数えて)I列目に配列Sを挿入して返す。','ひょうれつそうにゅう');
  AddFunc  ('表列削除','{=?}AのIを', 386, sys_csv_delcol, '二次元配列Aの(0から数えて)I列目を削除して返す。','ひょうれつさくじょ');
  AddFunc  ('表列合計','{=?}AのIを|Iで', 389, sys_csv_sum, '二次元配列Aの(0から数えて)I列目を合計して返す。','ひょうれつごうけい');
  AddFunc  ('表ワイルドカードピックアップ','{=?}Aの{=-1}IからSを|Aで', 5066, sys_csv_pickupWildcard,'二次元配列AでI列目(0起点)からワイルドカードパターンSにマッチする行をピックアップして返す。I=-1で全フィールドを対象にする。','ひょうわいるどかーどぴっくあっぷ');
  AddFunc  ('表正規表現ピックアップ','{=?}Aの{=-1}IからSを|Aで', 5067, sys_csv_pickupRegExp,'二次元配列AでI列目(0起点)から正規表現パターンSにマッチする行をピックアップして返す。I=-1で全フィールドを対象にする。','ひょうせいきひょうげんぴっくあっぷ');

  //-ハッシュ
  AddFunc  ('ハッシュキー列挙','{=?}Aの', 390, sys_hash_enumkey,'ハッシュAのキー一覧を返す','はっしゅきーれっきょ');
  AddFunc  ('要素数','{参照渡し=?}Sの', 391, sys_count,'ハッシュ・配列の要素数、文字列の行数を返す。','ようそすう');
  AddFunc  ('ハッシュ内容列挙','{=?}Aの', 392, sys_hash_enumvalue,'ハッシュAの内容一覧を返す','はっしゅないようれっきょ');
  AddFunc  ('ハッシュキー削除','{参照渡し=?}AのBを', 393, sys_hash_deletekey,'ハッシュAのキーBを削除する。Aの内容を書き換える。','はっしゅきーさくじょ');

  //-グループ
  AddFunc  ('メンバ列挙','{グループ}Sの',           395, sys_EnumMember,'グループSのメンバ一覧を返す。','めんばれっきょ');
  AddFunc  ('メンバ詳細列挙','{グループ}Sの',       396, sys_EnumMemberEx,'グループSのメンバ一覧とその型と値を返す。','めんばしょうさいれっきょ');
  AddFunc  ('作成','{参照渡し}Aを{グループ}Bとして|Bで', 397, sys_groupCreate,'変数AをグループBとして動的に作成する。','さくせい');
  AddIntVar('自身', 0, 398, 'グループ内で自分自身を指定したい時に用いる','じしん');
  AddFunc  ('グループ判定','{グループ}Aが|Aの', 399, sys_group_ornot,'変数Aがグループかどうか判定しグループならばグループの名前を返す','ぐるーぷはんてい');

  //+クリップボード
  //-クリップボード
  AddFunc  ('コピー','{=?}Sを',  400, sys_setClipbrd,'クリップボードに文字列Ｓをコピーする。','こぴー');
  AddFunc  ('クリップボード取得','',  401, sys_getClipbrd,'クリップボードから文字列を取得する','くりっぷぼーどしゅとく');
  SetSetterGetter('クリップボード','コピー','クリップボード取得',404, 'クリップボードに読み書きを行う', 'くりっぷぼーど');
  //-アプリ間データ通信
  AddFunc  ('COPYDATA送信','AにSを|Aへ',  402, sys_copydata_send, 'ウィンドウハンドルAにSというメッセージでCOPYDATAを送信する','COPYDATAそうしん');
  AddFunc  ('COPYDATA詳細送信','AにSをIDで|Aへ',  403, sys_copydata_sendex, 'ウィンドウハンドルAにSというメッセージにIDを加えてCOPYDATAを送信する','COPYDATAしょうさいそうしん');

  //+日付時間処理
  //-時間
  AddFunc  ('今','',    410, sys_now,  '今の時間を「hh:nn:ss」の形式で返す。','いま');
  //AddFunc  ('システム時間','',                171, sys_timeGetTime,'OSが起動してからの時間を取得して返す。','しすてむじかん');
  AddFunc  ('秒待つ','{=?}A', 413, sys_sleep, 'A秒間実行を止める。','びょうまつ');
  //-日付
  AddFunc  ('今日','',  411, sys_today,'今日の日付を「yyyy/mm/dd」の形式で返す。','きょう');
  AddFunc  ('今年','',  419, sys_thisyear, '今年が何年かを返す。','ことし');
  AddFunc  ('今月','',  420, sys_thismonth,'今月が何月かを返す。','こんげつ');
  AddFunc  ('来年','',  421, sys_nextyear,'来年が何年かを西暦で返す。','らいねん');
  AddFunc  ('去年','',  422, sys_lastyear,'去年が何年かを西暦で返す。','きょねん');
  AddFunc  ('来月','',  423, sys_nextmonth,'来月が何月かを返す。','らいげつ');
  AddFunc  ('先月','',  424, sys_lastmonth,'先月が何月かを返す。','せんげつ');
  AddFunc  ('曜日','{=?}Sの', 412, sys_week, 'Sに指定した日付の曜日を『月～日』で返す。不正な日付の場合は今日の曜日を返す。','ようび');
  AddFunc  ('曜日番号取得','{=?}Sの', 5063, sys_weekno, 'Sに指定した日付の曜日番号をで返す。不正な日付の場合は今日の曜日番号を返す。(0=日/1=月/2=火/3=水/4=木/5=金/6=土)','ようびばんごうしゅとく');
  AddFunc  ('和暦変換','{=?}Sを',    418, sys_date_wa, 'Sを和暦に変換する。Sは明治以降の日付が有効。','われきへんかん');
  AddFunc  ('日時形式変換','{=?}DATEをFORMATに|DATEから|FORMATで|FORMATへ',    409, sys_date_format, '日時(DATE)を指定形式(FORMAT)に変換する。フォーマットには「RSS形式」や「yyyy/mm/dd hh:nn:ss」を指定する','にちじけいしきへんかん');
  AddFunc  ('UNIXTIME変換','{=?}DATEを', 427, sys_toUnixTime, '日時をUnix Timeに変換する','UNIXTIMEへんかん');
  AddFunc  ('UNIXTIME_日時変換','{=?}Iを', 428, sys_fromUnixTime, 'Unix TimeであるIをなでしこ日時形式に変換する','UNIXTIME_にちじへんかん');
  //-日付時間計算
  AddFunc  ('時間加算','{=?}SにAを', 415, sys_timeAdd, '時間SにAを加えて返す。Aには「(+|-)hh:nn:dd」で指定する。','じかんかさん');
  AddFunc  ('日付加算','{=?}SにAを', 414, sys_dateAdd, '日付SにAを加えて返す。Aには「(+|-)yyyy/mm/dd」で指定する。','ひづけかさん');
  AddFunc  ('日数差',  '{=?}AとBの|AからBまでの', 416, sys_dateSub, '日付AとBの差を日数で求めて返す。','にっすうさ');
  AddFunc  ('秒差',    '{=?}AとBの|AからBまでの', 417, sys_timeSub, '時間AとBの差を秒差で求めて返す。','びょうさ');
  AddFunc  ('分差','{=?}AとBの|AからBまでの', 425, sys_MinutesSub, '時間AとBの分数の差を求めて返す','ふんさ');
  AddFunc  ('時間差','{=?}AとBの|AからBまでの', 426, sys_HourSub, '時間AとBの時間の差を求めて返す','じかんさ');

  //+ダイアログ・ウィンドウ
  //-ダイアログ
  //AddFunc  ('言う','{文字列=?}Sを|Sと',       150, sys_say,        'メッセージSをダイアログに表示する。','いう');
  AddFunc('二択',    '{文字列=?}Sで|Sと|Sを', 450,sys_yesno,'はい・いいえのどちらか二択のダイアログを出す。','にたく');
  AddFunc('尋ねる',  '{文字列=?}Sで|Sと|Sを', 451,sys_input,'ダイアログに質問Ｓを表示してユーザーからの入力を得る。','たずねる');
  AddFunc('三択',    '{文字列=?}Sで|Sと|Sを', 455,sys_yesnocancel,'はい・いいえ・キャンセルのいずれか三択のダイアログを出す。','さんたく');
  AddFunc('メモ記入','{文字列=?}Sで|Sと|Sを|Sの', 457,sys_msg_memo,'メモ表示ダイアログを出す。','めもきにゅう');
  AddFunc('リスト選択','{文字列=?}Sで|Sと|Sを|Sの|Sから', 458,sys_msg_list,'リスト選択ダイアログを出す。引数は配列で指定する。','りすとせんたく');
  AddFunc('バージョンダイアログ表示','{=?}TITLEとMEMOを|MEMOの', 459,sys_version_dialog,'WindowsバージョンダイアログにタイトルTITLEと文字列MEMOを表示する。','ばーじょんだいあろぐひょうじ');
  //-ファイル関連ダイアログ
  AddFunc('ファイル選択','{文字列=「」}Sの{文字列=「」}Aで',     452,sys_selFile,'拡張子Sのファイルを選択して返す(Aは初期ファイル名)','ふぁいるせんたく');
  AddFunc('保存ファイル選択','{文字列=「」}Sの{文字列=「」}Aで', 453,sys_selFileAsSave,'保存用に拡張子Sのファイルを選択して返す(Aは初期ファイル名)','ほぞんふぁいるせんたく');
  AddFunc('フォルダ選択','{文字列=「」}Sで|Sの',     454,sys_selDir,'初期フォルダSでフォルダを選択して返す','ふぉるだせんたく');
  //-ウィンドウ
  AddFunc('ウィンドウ列挙', '', 456,sys_enumwindows,'ウィンドウの一覧を列挙する。(ハンドル,クラス名,テキスト)の形式で列挙する','うぃんどうれっきょ');
  //-ダイアログオプション
  AddStrVar('ダイアログキャンセル値','',460,'ダイアログをキャンセルしたときの値を指定','だいあろぐきゃんせるち');
  AddStrVar('ダイアログ初期値','',461,'ダイアログの初期値を指定','だいあろぐしょきち');
  AddStrVar('ダイアログIME','',462,'ダイアログの入力フィールドのIME状態の指定(IMEオン|IMEオフ|IMEかな|IMEカナ|IME半角)','だいあろぐIME');
  AddStrVar('ダイアログタイトル','',463,'ダイアログのタイトルを指定する','だいあろぐたいとる');
  AddIntVar('ダイアログ数値変換',1,464,'ダイアログの結果を数値に変換するかどうか。オン(=1)オフ(=0)を指定する。','だいあろぐすうちへんかん');
  AddIntVar('ダイアログ表示時間',0,467,'(標準GUI利用時のみ)「言う」「二択」「尋ねる」ダイアログでダイアログの最大表示時間を秒で指定する。0で制限時間を設けない。','だいあろぐひょうじじかん');

  //+サウンド
  //-サウンド
  AddFunc('BEEP','', 496,sys_beep,'BEEP音を鳴らす','BEEP');
  AddFunc('WAV再生','FILEを|FILEで', 497,sys_wav,'WAVファイルを再生する','WAVさいせい');
  AddFunc('再生', 'FILEを', 498, sys_musPlay,'音楽ファイルFILEを再生する。','さいせい');
  AddFunc('停止', '',    499, sys_musStop,'「再生」した音楽を停止する。','ていし');
  AddFunc('演奏', 'FILEを', 495, sys_musPlay,'音楽ファイルFILEを演奏する。『再生』と同じ。','えんそう');
  AddFunc('秒録音', 'FILEへSEC|FILEに', 485, sys_musRec,'ファイルFILE(WAV形式)へSEC秒だけ録音する。','びょうろくおん');
  //-MCI
  AddFunc('MCI開く','FILEをAで',  490,sys_mciOpen, '音楽ファイルFILEをエイリアスAで開く。(MIDI/WAV/MP3/WMAなどが再生可能)','MCIひらく');
  AddFunc('MCI再生','Aを',        491,sys_mciPlay, '「MCI開く」で開いたエイリアスAを再生する。','MCIさいせい');
  AddFunc('MCI停止','Aを',        492,sys_mciStop, '「MCI開く」で開いたエイリアスAを停止する','MCIていし');
  AddFunc('MCI閉じる','Aを',      493,sys_mciClose,'「MCI開く」で開いたエイリアスAを閉じる。','MCIとじる');
  AddFunc('MCI送信', 'Sを',       494,sys_mciCommand,'MCIにコマンドSを送信し結果を返す。','MCIそうしん');
  
  //</システム変数関数>

  Sore    := Global.GetVar(token_sore);
  kaisu   := Global.GetVar(token_kaisu);
  errMsg  := Global.GetVar(token_errMsg);
  taisyou := Global.GetVar(token_taisyou);

  hi_makeAlias;

  // コマンドラインの登録
  _setCmdLine;

  //-------------
  // +++ temp +++
  //AddFunc  ('取り込む','Sを|Sで', 189, sys_include, 'ファイルSを取り込んで実行する','とりこむ');
  //-------------
  
end;


procedure THiSystem.AddSystemFileCommand;
begin
  FlagSystemFile := True;
  //todo 1:ファイル変数関数追加
  //<ファイル変数関数>
  //+実行ファイル作成
  //-パックファイル作成
  AddFunc('パックファイル作成','AをBに',    10, sys_packfile_make,  '「ファイルパス=パック名=暗号化(0or1)」のリストを使ってファイルBへ保存する','ぱっくふぁいるさくせい');
  AddFunc('パックファイル抽出','AのBをCへ', 11, sys_packfile_extract,  'パックファイルAの中にあるファイルBを抽出してCへ保存する。','ぱっくふぁいるちゅうしゅつ');
  AddFunc('パックファイル存在','Fの|Fに',   12, sys_checkpackfile,'実行ファイルFにパックファイルが存在するか確認する。','ぱっくふぁいるそんざい');
  AddFunc('パックファイル文字列抽出','AのBを', 13, sys_packfile_extract_str,  'パックファイルAの中にあるファイルBを抽出して文字列として返す。','ぱっくふぁいるもじれつちゅうしゅつ');
  AddFunc('パックファイル文字列抽出','AのBを', 26, sys_packfile_enum,  'パックファイルAの中にあるファイルBを抽出して文字列として返す。','ぱっくふぁいるもじれつちゅうしゅつ');

  //-実行ファイル作成抽出実行
  AddFunc('パックファイル結合','AとBをCに',       14, sys_packfile,  '実行ファイルAとパックファイルBを結合してCへ保存する。','ぱっくふぁいるけつごう');
  AddFunc('パックファイル分離','AからBへ|AをBに', 15, sys_unpackfile,'実行ファイルAからパックファイルを取り出しファイルBへ保存する。','ぱっくふぁいるぶんり');
  AddFunc('パックファイルソースロード','AのBを|Aから', 16, sys_packfile_nako_load,  'パックファイルAにあるなでしこのソースBをメインプログラムとしてロードする。成功するば1を返す。','ぱっくふぁいるそーすろーど');
  AddFunc('パックファイルソース実行',  '',        17, sys_packfile_nako_run,   'パックファイルソースロードでロードしたプログラムを実行する。','ぱっくふぁいるそーすじっこう');
  AddFunc('ナデシコDLL依存状況取得','',5046, sys_makeDllReport, 'なでしこのDLL依存関係レポートを取得して返す','なでしこDLLいぞんじょうきょうしゅとく');

  //+ファイル名・パス操作
  //-パス操作
  AddFunc  ('ファイル名抽出', 'Sから|Sの',  20, sys_extractFile,'パスSからファイル名部分を抽出して返す。','ふぁいるめいちゅうしゅつ');
  AddFunc  ('パス抽出',       'Sから|Sの',  21, sys_extractFilePath,'ファイル名Sからパス部分を抽出して返す。','ぱすちゅうしゅつ');
  AddFunc  ('拡張子抽出',     'Sから|Sの',  22, sys_extractExt,'ファイル名Sから拡張子部分を抽出して返す。','かくちょうしちゅうしゅつ');
  AddFunc  ('拡張子変更',     'SをAに|Sの', 23, sys_changeExt,'ファイル名Sの拡張子をAに変更して返す。','かくちょうしへんこう');
  AddFunc  ('ユニークファイル名生成','AでBの|Aに', 24, sys_makeoriginalfile,'フォルダAで基本ファイル名Bをもつユニークなファイル名を生成して返す。','ゆにーくふぁいるめいせいせい');
  AddFunc  ('相対パス展開',   'AをBで',     25, sys_expand_path,'相対パスＡを基本パスＢで展開して返す。','そうたいぱすてんかい');
  //</ファイル変数関数>

end;

procedure THiSystem.CheckInitSystem;
begin
  // システムの初期化が終わっているかチェック
  if FlagInit = False then
  begin
    FlagInit := True;
    // システム命令の追加
    AddSystemCommand;
  end;
end;

procedure THiSystem.constListClear;
var
  i: Integer;
  p: PHiValue;
begin
  for i := 0 to ConstList.Count - 1 do
  begin
    p := ConstList.Items[i];
    if p.Size > 0 then hi_var_clear(p);
  end;
end;

constructor THiSystem.Create;
begin
  //
  plugins := THiPlugins.Create;
  //
  TokenFiles := THimaFiles.Create;
  //
  TangoList := THimaTangoList.Create;
  JosiList  := THimaJosiList.Create;
  ConstList := THList.Create;
  DefFuncList := THObjectList.Create;
  //
  DllNameList := TStringList.Create;
  DllHInstList := THList.Create;
  // namespace
  Namespace := THiNamespace.Create;
  Namespace.CreateNewSpace(-1); // add system(=-1) space
  //
  LocalScope := THiVarScope.Create;
  GroupScope := THiGroupScope.Create;
  //
  TopSyntaxNode   := nil;
  FlagStrict      := False;
  FlagVarInit     := False;
  FlagSystem      := 0;
  FlagInit        := False;
  CurNode         := nil;
  ContinueNode    := nil;
  LastFileNo      := -1;
  LastLineNo      := -1;
  DebugEditorHandle := 0;
  DebugLineNo     := False;
  FlagSystemFile  := False;
  runtime_error   := True;

  FRunFlagList    := THList.Create;
  BreakLevel      := BREAK_OFF;
  BreakType       := btNone;
  ReturnLevel     := BREAK_OFF;
  FlagEnd         := False;
  FFuncBreakLevel := 0;
  MainFileNo      := 0;
  FNowLoadPluginId := -1; // システム命令は -1
  FDummyGroup     := hi_var_new;
  hi_group_create(FDummyGroup);

  DebugNextStop := False;
  FIncludeBasePath := '';
  PluginsDir := AppPath + 'plug-ins\';

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  // 命令タグの初期化
  _initTag;
  FTime      := timeGetTime;

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  // 単語の一括登録
  setTokenList(Self);
  // 助詞一覧の作成
  setJosiList(Self);
end;

function THiSystem.CreateHiValue(VarId: Integer): PHiValue;
begin
  // 既に存在するか？
  Result := Global.GetVar(VarId);
  if Result = nil then
  begin
    //生成
    Result := hi_var_new;
    //初期化
    Result^.VarID := VarID;
  end;

  //登録
  Global.RegistVar(Result);
end;

function THiSystem.DebugProgram(n: TSyntaxNode; lang: THiOutLangType): AnsiString;
begin
  Result := '';
  while n <> nil do
  begin
    try
      //Result := Result + '/*' + n.DebugStr + '*/';
      if lang = langNako then
      begin
        Result := Result + n.outNadesikoProgram;
      end else
      if lang = langLua then
      begin
        Result := Result + n.outLuaProgram;
      end;
    except
      raise EHimaSyntax.Create(n.DebugInfo,'『%s』でパースエラー。',[n.ClassName]);
    end;
    n := n.Next;
  end;
end;

function THiSystem.DebugProgramNadesiko: AnsiString;
var
  i: Integer;
  d: TSyntaxDefFunction;
begin
  Result := '';
  Result := Result + '# --- メイン'#13#10;
  Result := Result + DebugProgram(TopSyntaxNode);

  if DefFuncList.Count > 0 then
  begin
    Result := Result + '# --- 関数'#13#10;
    for i := 0 to DefFuncList.Count - 1 do
    begin
      d := DefFuncList.Items[i];
      Result := Result + d.outNadesikoProgram + #13#10;
    end;
  end;
end;

destructor THiSystem.Destroy;
var
  i: Integer; h: THandle; p: PHiRunFlag;
  g: THiPlugin;
  f: function ():DWORD; stdcall;
begin
  //todo: THiSystem.Destroy

  //-----------------------------------------
  // プラグインの開放処理を実行
  for i := 0 to plugins.Count - 1 do
  begin
    g := plugins.Items[i];
    f := GetProcAddress(g.Handle, 'PluginFin');
    if @f <> nil then
    begin
      //debugs('FIN:'+g.FullPath);
      f();
    end;
    //debugs('FREE:'+g.FullPath);
    FreeAndNil(g);
    plugins.Items[i] := nil;
  end;
  FreeAndNil(Plugins);
  //-----------------------------------------

  // --- 変数を壊す
  // (1)壊す前にグループの「壊す」メソッドを実行
  {
  try
    Namespace.ExecuteGroupDestructor;
  except
  end;
  }
  //
  try
    FreeAndNil(Namespace); // <- global.Free
  except
  end;


  //FileSaveAll( TangoList.EnumKeys, 'tangolist.txt');

  // --- 実行用のフラグを壊す
  for i := 0 to FRunFlagList.Count - 1 do
  begin
    p := FRunFlagList.Items[i];
    Dispose(p);
  end;
  FreeAndNil(FRunFlagList);
  //
  hi_var_free(FDummyGroup);
  FreeAndNil(TokenFiles);
  //
  ConstListClear;
  FreeAndNil(ConstList);
  FreeAndNil(DefFuncList);
  //
  FreeAndNil(GroupScope);
  FreeAndNil(LocalScope);
  //
  FreeAndNil(DllNameList); // 文字列
  for i := 0 to DllHInstList.Count - 1 do begin
    h := DllHInstList.GetAsNum(i);
    FreeLibrary(h);
  end;
  FreeAndNil(DllHInstList); // DLL
  //
  FreeAndNil(TopSyntaxNode);
  //
  //
  //
  FreeAndNil(TangoList);
  FreeAndNil(JosiList);
  inherited;
end;

function THiSystem.ErrorContinue: PHiValue;
begin
  Result := RunNode(ContinueNode);
end;

procedure THiSystem.ErrorContinue2;
var
  p: PHiValue;
begin
  p := ErrorContinue;
  if (p <> nil)and(p.Registered = 0) then hi_var_free(p);
end;

function THiSystem.Eval(Source: AnsiString): PHiValue;
var
  parser: THiParser;
  f:THimaFile;
  MyTopNode: TSyntaxNode;
  tmpSore, res: PHiValue;
begin
  Result := nil;
  CheckInitSystem;
  if (Source = '') then Exit;

  //<フラグの退避>
  PushRunFlag;
  //</フラグの退避>
  FlagEnd := False;

  tmpSore := hi_var_new;
  hi_var_copyGensi(HiSystem.Sore, tmpSore);

  f := THimaFile.Create(nil, -1);
  try
    try
      f.SetSource(Source);
      parser := THiParser.Create;
      try
        MyTopNode := parser.Parse(f.TopToken); // Eval用ノードを構築
        FFuncBreakLevel := FNestCheck;
        res  := RunNode(MyTopNode); // 実行
        if res <> nil then
        begin
          Result := hi_var_new;
          hi_var_copyGensi(res, Result);
        end;
      finally
        parser.Free;
      end;
    except on e: Exception do
      raise Exception.Create('EVAL(ソース内評価)でエラーが発生しました。' + e.Message);
    end;
  finally
    hi_var_copyGensi(tmpSore, HiSystem.Sore);
    hi_var_free(tmpSore);
    FreeAndNil(MyTopNode);
    f.Free;
  end;
  //<フラグの回復>
  PopRunFlag;
  //</フラグの回復>
end;

procedure THiSystem.Eval2(Source: AnsiString);
var
  p: PHiValue;
begin
  p := Eval(Source);
  if (p <> nil) and (p.Registered = 0) then hi_var_free(p);
end;

function THiSystem.ExpandStr(s: string): string;
var
  c, EOS, n: AnsiString;
  p: PAnsiChar;

  function subEval(w: String): String;
  var
    vid: Integer;
    n: Integer;
    v: PHiValue;
    p: PAnsiChar;
    dummy: AnsiString;
    c, s: String;
  begin
    w := HimaSourceConverter(-1, w);
    if w='' then begin Result := ''; Exit; end;

    // シーケンスか？
    p := PAnsiChar(w); Result := '';
    while p^ <> #0 do
    begin
      case p^ of
        ' ',',',#9: Inc(p);
        '>': begin Result := Result + #9 ;    Inc(p); end;
        '~': begin Result := Result + #13#10; Inc(p); end;
        // '_' は それのエイリアス ... '_': begin Result := Result + ' ';    Inc(p); end;
        '[': begin Result := Result + '「';   Inc(p); end;
        ']': begin Result := Result + '」';   Inc(p); end;
        '\':
          begin
            s := '';
            Inc(p); // slip \
            while p^ <> #0 do
            begin
              case p^ of
                '\',',',' ': Inc(p);
                'n': begin Inc(p); s := s + #13#10; Break; end;
                't': begin Inc(p); s := s + #9;     Break; end;
                's': begin Inc(p); s := s + ' ';    Break; end;
                '0'..'9','$':
                begin
                  n := Trunc(HimaGetNumber(p, dummy));
                  c := '';
                  while n > 255 do
                  begin
                    c := String(AnsiChar(n and $FF)) + c;
                    n := n shr 8;
                  end;
                  c := String(AnsiChar(n)) + c;
                  s := s + c;
                end;
                else begin
                  // 埋め込み文字
                  if p^ in SysUtils.LeadBytes then
                  begin
                    s := s + p^ + (p+1)^;
                    Inc(p, 2);
                  end else
                  begin
                    s := s + p^;
                    Inc(p);
                  end;
                  Break;
                end;
              end;
            end;
            Result := Result + s;
          end;
        else begin
          Break;
        end;
      end;
    end;
    w := AnsiString(PAnsiChar(p));
    if (w = '')or(w = #0) then Exit;

    vid := hi_tango2id(DeleteGobi(w));
    //v := GetVariableNoGroupScope(vid);
    v := GetVariable(vid);
    if (v = nil)or(v.VType = varFunc)or(v.Getter <> nil)or(v.VType = varGroup) then
    begin
      try
        v := Eval(w);
      except on e:Exception do
        raise Exception.Create('文字列「'+string(w)+'」の展開に失敗。'+e.Message);
      end;
    end;
    if v <> nil then
      Result := hi_str(v)
    else
      Result := '';
  end;

  function get_tenkai_end(var p: PAnsiChar): AnsiString;
  begin
    Result := '';
    while p^ <> #0 do
    begin
      c := getOneChar(p);
      if (c = '｝')or(c = '}') then Break;
      Result := Result + c;
    end;
    if (c <> '｝')and(c <> '}') then raise Exception.Create(ERR_NOPAIR_NAMI);
  end;

begin
  Result := ''; if s = '' then Exit;
  p := PAnsiChar(s);

  // 展開の必要性を調べる
  c := getOneChar(p);
  if (c = '"')or(c = '「') then
  begin
    if c = '"' then
    begin
      EOS := '"';
    end else begin
      EOS := '」';
    end;

    while p^ <> #0 do
    begin
      c := getOneChar(p);
      if (c = '｛')or(c = '{') then
      begin
        n := subEval(get_tenkai_end(p));
        Result := Result + n;
      end else
      if c = EOS then
      begin
        Break;
      end else
      begin
        Result := Result + c;
      end;
    end;
  end else
  if c = '『' then
  begin
    // 展開が不要 ... 『』を消す
    // |1234567|
    // |『aaa』|
    Result := Copy(s, 3, Length(s) - 4);
  end else
  if c = '`' then
  begin
    // |12345678|
    // |'123456'|
    Result := Copy(s, 2, Length(s) - 2);
  end else
  begin
    Result := s;
  end;
end;

function THiSystem.GetBokanPath: string;
begin
  Result := string(hi_str(GetVariable(hi_tango2id('母艦パス'))));
end;

function THiSystem.GetGlobalSpace: THiScope;
begin
  Result := Namespace.CurSpace;
  if Result = nil then
  begin
    Result := Namespace.Items[0];
  end;
end;

function THiSystem.getRunFlag: THiRunFlag;
begin
  Result.BreakLevel       :=  BreakLevel;
  Result.BreakType        :=  BreakType;
  Result.ReturnLevel      :=  ReturnLevel;
  Result.FFuncBreakLevel  :=  FFuncBreakLevel;
  Result.FNestCheck       :=  FNestCheck;
  Result.CurNode          :=  CurNode;
end;

function THiSystem.GetSourceText(FileNo: Integer): AnsiString;
var
  f: THimaFile;
begin
  Result := '';
  f := TokenFiles.FindFileNo(FileNo);
  if f = nil then Exit;
  Result := f.GetAsText;
end;


function THiSystem.GetVariable(VarID: DWORD): PHiValue;
begin
  // ローカルをチェック
  Result := Local.GetVar(VarID);
  if Result <> nil then Exit;

  // グループスコープをチェック
  Result := GroupScope.FindMember(VarID);
  if Result <> nil then Exit;

  // グローバルをチェック
  Result := Namespace.GetVar(VarID);
end;

function THiSystem.GetVariableNoGroupScope(VarID: DWORD): PHiValue;
begin
  // ローカルをチェック
  Result := Local.GetVar(VarID);
  if Result <> nil then Exit;

  // グローバルをチェック
  Result := Namespace.GetVar(VarID);
end;

function THiSystem.GetVariableRaw(VarID: DWORD): PHiValue;
begin
  // ローカルをチェック
  Result := Local.GetVar(VarID);
  if Result <> nil then Exit;

  // グループスコープをチェック
  Result := GroupScope.FindMember(VarID);
  if Result <> nil then Exit;

  // グローバルをチェック
  Result := Namespace.GetVar(VarID);
end;

function THiSystem.GetVariableS(vname: AnsiString): PHiValue;
begin
  Result := GetVariable(hi_tango2id(vname));
end;

function THiSystem.ImportFile(FName: string; var node: TSyntaxNode): PHiValue;
var
  f: THimaFile;
  parser: THiParser;
  oldNamespace: THiScope;
  n: TSyntaxNode;
  tmpPath: string;
begin
  CheckInitSystem;

  if FIncludeBasePath = '' then FIncludeBasePath := BokanPath;
  tmpPath := FIncludeBasePath;
  Result := nil;

  if TokenFiles.FindFile(FName) = nil then
  begin
    oldNamespace := Namespace.CurSpace;

    try
      f := TokenFiles.LoadAndAdd(FName);
    except on e: Exception do
      raise Exception.Create(string(FName)+'の取り込みに失敗。');
    end;

    if f = nil then raise Exception.Create(string(FName)+'の取り込みに失敗。');
    Namespace.CreateNewSpace(f.Fileno);
    FIncludeBasePath := f.Path;

    //-----------------------------------
    // 取り込み処理
    parser := THiParser.Create;
    try
      // def value
      FlagEnd    := False;
      FlagStrict := False;
      FlagSystem := 0;
      BreakLevel := BREAK_OFF; BreakType := btNone; ReturnLevel := BREAK_OFF;
      // parse
      n := parser.Parse(f.TopToken);
      //debugs(parser.Debug);
      // run
      Result := RunNode( n );
    finally
      parser.Free;
    end;

    Namespace.CurSpace := oldNamespace;
  end;
  FIncludeBasePath := tmpPath;
end;

function THiSystem.LoadFromFile(Source: string): Integer;
var
  f: THimaFile;
  parser: THiParser;
begin
  CheckInitSystem;
  Result := -1;

  f := TokenFiles.LoadAndAdd((Source));
  Namespace.CreateNewSpace(f.Fileno);

  if f.Count = 0 then Exit;
  Result := f.Fileno;
  parser := THiParser.Create;
  try
    TopSyntaxNode := parser.Parse(f.TopToken);
  finally
    parser.Free;
  end;
end;

procedure THiSystem.LoadPlugins;
var
  F:TSearchRec;
  dll, dllpath: TStringList;
  path: string;
  s: string;
  i: Integer;
  h: THandle;
  proc   : TImportNakoSystem;
  require: TPluginRequire;
  plugin : THiPlugin;
  PluginInit: procedure (h: DWORD); stdcall;

  procedure chkDLL(name: string);
  var s: string; p: PHiValue;
  begin
    s := UpperCase(ExtractFileName(name));
    // 自身は取り込み不要
    if s = 'DNAKO.DLL' then Exit;
    // vnako 二重取り込みチェック
    if s = 'LIBVNAKO.DLL' then
    begin
      p := HiSystem.GetVariable(hi_tango2id('noload_libvnako'));
      if p <> nil then 
      begin
        if hi_bool(p) then Exit;
      end;
    end;
    // その他、二重取り込みチェック
    if dll.IndexOf((s)) < 0 then
    begin
      dll.Add((s));
      dllpath.Add((name));
    end;
  end;

  function chk_header(s: string): Boolean;
  var
    m: TFileStream;
    b: AnsiString;
  begin
    Result := False;
    try
      SetLength(b, 2);
      // ↓重要：共有フォルダで実行するとき、fmShareDenyNone でないとなぜかエラーになる
      m := TFileStream.Create(s, fmOpenRead or SysUtils.fmShareDenyNone);
      try
        m.Read(b[1], 2);
        if b = 'MZ' then
        begin
          Result := True; Exit;
        end;
      finally
        FreeAndNil(m);
      end;
    except
      errLog('dll.load.cannot.check_header=' + AnsiString(s));
    end;
  end;

begin
  // todo: プラグインの取り込み
  dll := TStringList.Create;
  dllpath := TStringList.Create;

  // もしあるならパックファイルのDLLを調べる
  if FileMixReader <> nil then
  begin
    path := (HiSystem.PluginsDir);
    FileMixReader.ExtractPatternFiles((path), '*.dll', False);
    if SysUtils.FindFirst(string(path)+'*.dll', FaAnyFile, F) = 0 then
    begin
      repeat
        chkDLL(string(path) + F.Name);
      until FindNext(F) <> 0;
      FindClose(F);
    end;
  end else
  begin
    // plug-inフォルダ のプラグインを調べる
    path := (HiSystem.PluginsDir);
    if (Pos(':\', path) = 0) then
    begin
      path := AppPath + path;
    end;
    if SysUtils.FindFirst(path+'*.dll', FaAnyFile, F) = 0 then
    begin
      repeat
        chkDLL(path + F.Name);
      until FindNext(F) <> 0;
      FindClose(F);
    end;
  end;

  // plug-inフォルダ のプラグインを調べる
  path := AppPath + 'plug-ins\';
  if SysUtils.FindFirst(path+'*.dll', FaAnyFile, F) = 0 then
  begin
    repeat
      chkDLL(path + F.Name);
    until FindNext(F) <> 0;
    FindClose(F);
  end;

  // 実行ファイルのプラグインを調べる
  path := AppPath;
  if SysUtils.FindFirst(path+'*.dll', FaAnyFile, F) = 0 then
  begin
    repeat
      chkDLL(path + F.Name);
    until FindNext(F) <> 0;
    FindClose(F);
  end;

  // プラグインかどうかの判別
  for i := 0 to dllpath.Count - 1 do
  begin
    s := (dllpath.Strings[i]);
    // ヘッダを見てLoadLibraryできるかどうかチェックする
    if chk_header(s) = False then Continue;
    h := LoadLibraryEx(PChar(s), 0, 0);
    if h = 0 then
    begin
      errLog('err.load.plugin=' + AnsiString(s));
      Continue;
    end;
    try
      // プラグインかどうか判別
      require := GetProcAddress(h, 'PluginRequire'); // pluginか判別
      if (Assigned(require) = False)or(require <= 1) then // バージョン違い取り込まない
      begin
        FreeLibrary(h);
        Continue;
      end;

      // プラグインとして認識(プラグインリストに追加)
      plugin := THiPlugin.Create;
      plugin.FullPath := s;
      plugin.ID := plugins.Count;
      plugin.Handle := h;
      plugins.Add(plugin);
      FNowLoadPluginId := plugin.ID;
      // 初期化関数を呼ぶ(ver >= 2)
      if require >= 2 then
      begin
        PluginInit := GetProcAddress(h, 'PluginInit');
        if (dnako_dll_handle > 0)and(hInstance <> dnako_dll_handle) then
        begin
          PluginInit(dnako_dll_handle);
        end else
        begin
          PluginInit(HInstance);
        end;
      end;
      proc   := GetProcAddress(h, 'ImportNakoFunction');
      if Assigned(proc) then
      begin
        proc;
      end;
      errLog('add.plugin=' + AnsiString(s));
    except
      raise Exception.Create('プラグインのロード中にエラー:'+s);
    end;
  end;
  FNowLoadPluginId := -1;

  dllpath.Free;
  dll.Free;
end;

function THiSystem.LoadSourceText(Source, SourceName: AnsiString): Integer; // return FileNo
var
  f: THimaFile;
  parser: THiParser;
begin
  CheckInitSystem;
  Result := -1;

  f := TokenFiles.LoadSourceAdd(Source, string(SourceName));
  Namespace.CreateNewSpace(f.Fileno);

  if f.Count = 0 then Exit;
  Result := f.Fileno;
  parser := THiParser.Create;
  try
    TopSyntaxNode := parser.Parse(f.TopToken);
    HiResetString(Source);
  finally
    parser.Free;
  end;
end;

function THiSystem.Local: THiScope;
begin
  Result := LocalScope.TopItem;
  if Result = nil then Result := Global;
end;

procedure THiSystem.PopScope;
begin
  LocalScope.PopVarScope;
end;


procedure THiSystem.PushRunFlag;
var
  p: PHiRunFlag;
begin
  New(p);
  p^ := getRunFlag;
  FRunFlagList.Add(p);
end;

procedure THiSystem.PopRunFlag;
var
  p: PHiRunFlag;
begin
  p := FRunFlagList.Pop;
  if p = nil then Exit;
  setRunFlag(p^);
  Dispose(p);
end;

procedure THiSystem.PushScope;
begin
  LocalScope.PushVarScope;
end;

function THiSystem.Run: PHiValue;
begin
  // 実行のために初期化
  FlagEnd     := False;
  BreakLevel  := BREAK_OFF;
  BreakType   := btNone;
  ReturnLevel := BREAK_OFF;

  // ハンドルの初期化など
  unit_file.MainWindowHandle := hima_function.MainWindowHandle;

  // 実行開始
  Result := RunNode(TopSyntaxNode);
end;

procedure THiSystem.Run2;
var
  p: PHiValue;
begin
  p := Run;
  if (p <> nil)and(p.Registered = 0) then hi_var_free(p);
end;

{
function THiSystem.RunGroupEvent(group: PHiValue;
  memberId: DWORD): PHiValue;
var
  pEvent, pRes: PHiValue;
  node: TSyntaxFunction;
  sv: TSyntaxValue;
begin
  Result := nil;
  if group = nil then Exit;

  // イベントを特定
  group := hi_getLink(group);
  pEvent := hi_group(group).FindMember(memberId);
  if pEvent = nil then Exit; // メンバがない
  if pEvent.VType <> varFunc then Exit;

  //debugs( hi_group(group).HiClassDebug );

  Result := hi_var_new;

  node := TSyntaxFunction.Create(nil);
  sv   := TSyntaxValue.Create(nil);
  try
    sv.VarID := group.VarID;
    sv.Element.LinkType := svLinkGlobal;
    sv.Element.VarLink  := group;
    New(sv.Element.NextElement);
    sv.Element.NextElement.LinkType := svLinkGroup;
    sv.Element.NextElement.groupMember := memberId;
    sv.Element.NextElement.NextElement := nil;
    //
    node.FDebugFuncName := hi_id2tango(memberID);
    node.FuncID := memberId;
    node.HiFunc := hi_func(pEvent);
    node.Link.LinkType  := sfLinkGroupMember;
    node.Link.LinkValue := sv;
    // 実行
    HiSystem.FlagEnd := False;
    pRes := node.getValue;
    // 戻り値をコピー
    hi_var_copyGensi(pRes, Result);
    if (pRes <> nil)and(pRes.Registered = 0) then hi_var_free(pRes);
  finally
    //sv.Free; 自動的に解放
    node.Free;
  end;
end;
}
function THiSystem.RunGroupEvent(group: PHiValue;
  memberId: DWORD): PHiValue;
var
  method: PHiValue;
begin
  Result := nil;
  if group = nil then Exit;
  method := hi_group(group).FindMember(memberId);
  if method = nil then Exit;
  if method.VType = varNil then Exit;
  Result := RunGroupMethod(group, method, nil);
end;


function THiSystem.RunGroupMethod(group, method: PHiValue;
  args: THObjectList): PHiValue;
var
  node : TSyntaxFunction;
  pRes : PHiValue;
begin
  PushRunFlag;
  try
    Result := hi_var_new;
    // --- group を stack に push
    GroupScope.PushGroupScope(hi_group(group));
    node := TSyntaxFunction.Create(nil);
    try
      node.FDebugFuncName := hi_id2tango(method.VarID);
      node.FuncID := method.VarID;
      node.HiFunc := hi_func(method);
      node.Link.LinkType  := sfLinkDirect;
      if node.Stack <> nil then node.Stack.Free; 
      node.Stack := args;
      // 実行
      HiSystem.FlagEnd := False;
      node.SyntaxLevel := 0;
      pRes := node.getValue;
      // 戻り値をコピー
      hi_var_copyGensi(pRes, Result);
      if (pRes <> nil)and(pRes.Registered = 0) then hi_var_free(pRes);
      // ※引数は自動で解放しない
      node.Stack := nil; // 重要
    finally
      node.Free;
      HiSystem.GroupScope.PopGroupScope;
    end;
  finally
    PopRunFlag;
  end;
end;

function THiSystem.RunNode(node: TSyntaxNode; IsNoGetter: Boolean): PHiValue;
// node から node に繋がる構文を実行する
// ---
// +----[注意]
// ||   返り値は直接変数へのポインタが入ることもあり、うかつに解放(hi_var_free)してはいけない。
// ||   もし、返り値を解放してしまうと、終了時に異常終了する。
// -----
  procedure __PRINT_DEBUG_STR__;
  var
    s: AnsiString;
  begin
    s := AnsiString(
      Format('%d:%0.4d (%2d): ',[node.DebugInfo.FileNo, node.DebugInfo.LineNo,node.SyntaxLevel])
    );
    s := s + RepeatStr('　　', node.SyntaxLevel);
    s := s + node.DebugStr;
    // if node.Parent <> nil then s:=s+'*';
     Writeln(s);
    //debugs(s);
  end;

  function findJumpPoint(cnode: TSyntaxNode): Boolean;
  var
    pnode, top: TSyntaxNode;
    jpnode: TSyntaxJumpPoint;
    flag: Boolean;
  begin
    if cnode = nil then
    begin
      Result := False;
      Exit;
    end;
    flag := False;
    // find next from top
    pnode := cnode.Parent;
    if pnode = nil then
    begin
      pnode := TopSyntaxNode;
      top := pnode;
    end else
    begin
      top := pnode.Children;
    end;
    while (top <> nil) do
    begin
      if top is TSyntaxJumpPoint then
      begin
        jpnode := TSyntaxJumpPoint(top);
        if jpnode.NameId = FJumpPoint then
        begin
          node := jpnode;
          flag := True;
          Break;
        end;
      end;
      top := top.Next;
    end;
    if flag then
    begin
      Result := True;
      Exit;
    end;
    Result := findJumpPoint(cnode.Parent);
  end;

var
  res: PHiValue;
  bError: Boolean;
  err: AnsiString;
label
  lblTop, lblGoto;
begin
  //todo 1: 実行(RunNode)
  Result := nil;
  bError := False;
  // 次のラインで止めるか？

  // 再帰スタックのオーバーフローチェック
  Inc(FNestCheck);
  if FNestCheck > MAX_STACK_COUNT then begin HiSystem.FlagEnd := True; raise Exception.Create(ERR_STACK_OVERFLOW); end;
  //
  try
lblTop:
  try
    while node <> nil do
    begin
      // 終了フラグ判定
      if FFlagEnd then Break;
      // ブレイク判定
      if BreakLevel   < node.SyntaxLevel  then Break;
      if ReturnLevel  < FNestCheck        then Break;
      if ReturnLevel  = FNestCheck        then
      begin
        ReturnLevel := BREAK_OFF;
        BreakType := btNone;
      end;
      // GOTO
      if FJumpPoint <> 0 then
      begin
        if not findJumpPoint(node) then
        begin
          Break;
        end;
        FJumpPoint := 0;
        continue;
      end;
      // __PRINT_DEBUG_STR__;

      // デバッグ用エディタへ現在実行中の行番号を通知
      if DebugLineNo and (DebugEditorHandle <> 0) then begin
        if (node.DebugInfo.FileNo = MainFileNo)and(node.DebugInfo.LineNo > 0) then begin
          SendCOPYDATA(DebugEditorHandle, 'row ' + IntToStrA(node.DebugInfo.LineNo), 0, MainWindowHandle);
        end;
      end;

      // 現在実行中のノードを記録
      CurNode := node;
      if node.DebugInfo.FileNo <> 255 then
      begin
        if LastLineNo <> node.DebugInfo.LineNo then
        begin
          LastLineNo := node.DebugInfo.LineNo;
          LastFileNo := node.DebugInfo.FileNo;
          if DebugNextStop then
          begin
            DebugNextStop := False;
            Eval2('デバッグ');
          end;
        end;
      end;
      // --------------------------------
      // ノードを実行
      // --------------------------------
      try
        if IsNoGetter then
        begin
          if node.Next = nil then res := node.GetValueNoGetter(False)
                             else res := node.GetValue;
        end else begin
          res := node.getValue;
        end;
      except
        on e:Exception do begin
          err := JReplaceA(
            AnsiString(SyntaxClassToFuncName(node.ClassName)),
            'TSyntax',
            '');
          raise Exception.CreateFmt('%s(%s)',
                [e.Message, err]);
        end;
      end;
      // --------------------------------
      node := node.Next; // 次のノードを取得

      // 値がnilでなければ結果を返す
      if res <> nil then
      begin
        Result := res;
      end;
      if speed > 0 then begin sleep(speed); end;

    end;
  except
    on e: Exception do
    begin
      if not HiSystem.runtime_error then
      begin
        bError := True;
      end else
      if node <> nil then
      begin
        ContinueNode := node.Next;
        raise EHimaRuntime.Create(node.DebugInfo, AnsiString(e.Message), []);
      end else
      begin
        ContinueNode := nil;
        raise ;
      end;
    end;
  end;

  // --- エラー
  if (bError)and(HiSystem.runtime_error = False) then
  begin
    if node <> nil then
    begin
      node := node.Next;
      goto lblTop;
    end;
  end;
  finally
    Dec(FNestCheck);
  end;
end;

procedure THiSystem.RunNode2(node: TSyntaxNode; IsNoGetter: Boolean);
var
  p: PHiValue;
begin
  p := RunNode(node, IsNoGetter);
  if (p <> nil) and (p.Registered = 0) then hi_var_free(p);
end;

procedure THiSystem.SetFlagEnd(const Value: Boolean);
begin
  FFlagEnd := Value;
end;

procedure THiSystem.setRunFlag(RunFlag: THiRunFlag);
begin
   BreakLevel := RunFlag.BreakLevel;
   BreakType := RunFlag.BreakType;
   ReturnLevel := RunFlag.ReturnLevel;
   FFuncBreakLevel := RunFlag.FFuncBreakLevel;
   FNestCheck := RunFlag.FNestCheck;
   CurNode := RunFlag.CurNode;
end;

procedure THiSystem.SetSetterGetter(VarName, SetterName, GetterName: AnsiString;
  tag: Integer; Description, yomi: AnsiString);
var
  VarID, SetterID, GetterID: DWORD;
  pVar: PHiValue;
  pSetter, pGetter: PHiValue;
begin
  // 単語IDを取得
  VarID    := TangoList.GetID(DeleteGobi(VarName), tag);
  SetterID := TangoList.GetID(DeleteGobi(SetterName));
  GetterID := TangoList.GetID(DeleteGobi(GetterName));
  _checkTag(tag, VarID);
  // 単語IDから関数を取得
  pSetter  := Namespace.GetVar(SetterID); if pSetter = nil then raise Exception.CreateFmt(ERR_S_UNDEFINED,[SetterName]);
  pGetter  := Namespace.GetVar(GetterID); if pGetter = nil then raise Exception.CreateFmt(ERR_S_UNDEFINED,[GetterName]);
  // 関数？
  if pSetter.VType <> varFunc then raise HException.Create(SetterName + 'は関数ではありません。');
  if pGetter.VType <> varFunc then raise HException.Create(GetterName + 'は関数ではありません。');
  pVar := CreateHiValue(VarID);
  pVar.Designer := 1;
  pVar.Setter := pSetter;
  pVar.Getter := pGetter;
end;

procedure THiSystem.Test;
var p: PHiValue;
begin
  // ---
  //todo 9: test
  p := Eval('「{ナデシコバージョン}」を表示。１秒待つ');
  if p.Registered = 0 then hi_var_free(p);
end;

function THiSystem.makeDllReport: AnsiString;
var
  s: AnsiString;
begin
  s := s + '; --- なでしこ解析レポート ---'#13#10;
  s := s + '[import]'#13#10;
  s := s + AnsiString(HiSystem.DllNameList.Text) + #13#10;
  s := s + '[plug-ins]'#13#10;
  s := s + AnsiString(HiSystem.plugins.UsedList) + #13#10;
  s := s + '[files]'#13#10;
  s := s + AnsiString(HimaFileList.Text) + #13#10;
  Result := s;
end;

procedure THiSystem.SetPluginsDir(const Value: string);
begin
  FPluginsDir := Value;
  mini_file_utils.DIR_PLUGINS := Value;
end;

{ THiScope }

procedure THiScope.Clear;
begin
  Each(FreeItem, nil);
  inherited;
end;

constructor THiScope.Create;
begin
  inherited Create;
end;

destructor THiScope.Destroy;
begin
  inherited;
end;

function THiScope.EnumKeys: AnsiString;
begin
  Each(subEnumKeys, @Result);
end;

function THiScope.EnumKeysAndValues(UserOnly: Boolean = False): AnsiString;
begin
  if UserOnly then
    Each(subEnumKeysAndValuesUserOnly, @Result)
  else
    Each(subEnumKeysAndValues, @Result);
end;

procedure THiScope.ExecGroupDestructor;
begin
  Each(subExecGroupDestructor, nil);
end;

function THiScope.FreeItem(item: PHIDHashItem; ptr: Pointer): Boolean;
var
  p: PHiValue;
begin
  Result := True;
  p := item.Value;

  // 内容を削除
  hi_var_free(p);
end;

function THiScope.GetVar(id: DWORD): PHiValue;
var
  i: PHIDHashItem;
begin
  Result := nil;
  i := Items[id];
  if i <> nil then Result := i^.Value;
end;


procedure THiScope.RegistVar(v: PHiValue);
var
  i: PHIDHashItem;
begin
  New(i);
  i^.Key := v.VarID;
  i^.Value := v;
  Items[ v.VarID ] := i;
  v.Registered := 1;
end;


function THiScope.subEnumKeys(item: PHIDHashItem; ptr: Pointer): Boolean;
var
  p: PAnsiString;
begin
  Result := True;
  p := ptr;
  p^ := p^ + hi_id2tango(item.Key) + #13#10;
end;

function THiScope.subEnumKeysAndValues(item: PHIDHashItem;
  ptr: Pointer): Boolean;
var
  p: PAnsiString;
  v: PHiValue;
  s: AnsiString;
begin
  Result := True;
  p := ptr;

  v := item.Value;

  case v^.VType of
    varInt    : s := '(整数)    ' + hi_str(v);
    varFloat  : s := '(実数)    ' + hi_str(v);
    varStr    : s := '(文字列)  ' + hi_str(v);
    varNil    : s := '(nil)';
    varFunc   : s := '(関数)';
    varArray  : s := '(配列)    ' + hi_str(v);
    varHash   : s := '(ハッシュ)' + hi_str(v);
    varGroup  : s := '(グループ)[' + hi_id2tango(hi_group(v).HiClassNameID)+']';
    varLink   : s := '(リンク)  ' + hi_str(v);
  end;

  s := JReplaceA(s, #13#10, '{\n}');
  if Length(s) > 256 then s := sjis_copyByte(PAnsiChar(s), 256) + '...';


  if Length(p^) > 65535 then
  begin
    Result := False;
    Exit;
  end;
  
  p^ := p^ + hi_id2tango(item.Key) + '=' + s + #13#10;
end;

function THiScope.subEnumKeysAndValuesUserOnly(item: PHIDHashItem;
  ptr: Pointer): Boolean;
var
  v: PHiValue;
begin
  Result := True;
  v := item.Value;
  if v.Designer = 0 then
  begin
    Result := subEnumKeysAndValues(item, ptr);
  end;
end;

function THiScope.subExecGroupDestructor(item: PHIDHashItem;
  ptr: Pointer): Boolean;
var
  v: PHiValue;
begin
  Result := True;
  //
  v := item.Value;
  if (v <> nil)and(v.VType = varGroup)and(v.Designer = 0) then
  begin
    //---
    if not THiGroup(v.ptr).IsDestructorRunned then
    begin
      THiGroup(v.ptr).IsDestructorRunned := True;
      HiSystem.RunGroupEvent(v, token_kowasu); // エラーが発生する？？
    end;
  end;
end;

{ THiGroupScope }


constructor THiGroupScope.Create;
begin
  jisin := nil;
end;

destructor THiGroupScope.Destroy;
begin
  while Self.Count > 0 do
  begin
    Self.PopGroupScope;
  end;
  inherited;
end;

function THiGroupScope.FindMember(NameID: DWORD): PHiValue;
var
  c: THiGroup;
begin
  Result := nil;
  if Count = 0 then Exit;
  c := Items[Count-1]; // Top
  Result := c.FindMember(NameID);
end;


procedure THiGroupScope.PushGroupScope(FScope: THiGroup);
begin
  // グループ『自身』をコピーする
  if jisin = nil then
  begin
    jisin := HiSystem.GetVariable(token_jisin);
  end;
  // 新しい自身をコピーする
  hi_var_copyGensi(FScope.InstanceVar, jisin);
  //hi_setLink(jisin, FScope.InstanceVar);

  Self.Push(FScope);
end;

procedure THiGroupScope.PopGroupScope;
var
  g: THiGroup;
begin
  // 前回の自身をpopする
  Self.Pop;

  // 自身にコピーする
  g := Self.TopItem;

  if g <> nil then begin
    hi_var_copyGensi(g.InstanceVar, jisin);
    //hi_setLink(g.InstanceVar, jisin);
  end else begin
    hi_var_copyGensi(HiSystem.FDummyGroup, jisin);
    //hi_setLink(FHiSystem.FDummyGroup, jisin);
  end;
end;

function THiGroupScope.TopItem: THiGroup;
begin
  if Count = 0 then begin Result := nil; Exit; end;
  Result := Items[Count-1];
end;

{ THiVarScope }

function THiVarScope.FindVar(NameID: DWORD): PHiValue;
var
  scope: THiScope;
begin
  if Count = 0 then
  begin
    Result := nil;
    Exit;
  end;
  scope := Items[Count-1];
  Result := scope.GetVar(NameID);
end;

function THiVarScope.HasLocal: Boolean;
begin
  Result := (Count > 0);
end;

procedure THiVarScope.PopVarScope;
var
  scope: THiScope;
begin
  scope := Self.Pop;
  FreeAndNil(scope);
end;

procedure THiVarScope.PushVarScope;
var
  scope: THiScope;
begin
  scope := THiScope.Create;
  Self.Add(scope);
end;

function THiVarScope.TopItem: THiScope;
begin
  if Count = 0 then begin Result := nil; Exit; end;
  Result := Items[Count-1];
end;

{ THiNamespace }

procedure THiNamespace.Clear;
var
  i: Integer;
  s: THiScope;
begin
  // 積まれた逆順に壊していく
  for i := Count -1 downto 0 do
  begin
    s := Items[i];
    FreeAndNil(s);
  end;
  inherited Clear;
end;

constructor THiNamespace.Create;
begin
  inherited;  
end;

procedure THiNamespace.CreateNewSpace(NamespaceID: Integer);
begin
  CurSpace := THiScope.Create;
  CurSpace.ScopeID := NameSpaceID;
  Self.Add(CurSpace);
end;

destructor THiNamespace.Destroy;
begin
  Clear;
  inherited;
end;

function THiNamespace.EnumKeysAndValues(UserOnly: Boolean): AnsiString;
var
  i: Integer;
  s: THiScope;
begin
  Result := '';
  for i := 0 to Count - 1 do
  begin
    s := Items[i];
    Result := Result + TrimA(s.EnumKeysAndValues(UserOnly)) + #13#10;
  end;
end;

procedure THiNamespace.ExecuteGroupDestructor;
var
  i: Integer;
  s: THiScope;
begin
  // 積まれた逆順に壊していく
  for i := Count -1 downto 0 do // 但しシステムは壊さない
  begin
    s := Items[i];
    s.ExecGroupDestructor;
  end;
end;

function THiNamespace.FindSpace(id: Integer): THiScope;
var
  i: Integer;
  s: THiScope;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    s := Items[i];
    if s.ScopeID = id then
    begin
      Result := s; Break;
    end;
  end;
end;

function THiNamespace.GetCurSpace: THiScope;
begin
  if FCurSpace <> nil then
  begin
    Result := FCurSpace;
  end else
  begin
    Result := GetTopSpace;
  end;
end;

function THiNamespace.GetTopSpace: THiScope;
begin
  Result := Items[0];
end;

function THiNamespace.GetVar(id: DWORD): PHiValue;
var
  i: Integer;
  s: THiScope;
  curid: Integer;
begin
  //Result := nil;

  // CurSpace を検索
  if CurSpace = nil then
  begin
    CurSpace := Items[0];
  end;
  Result := CurSpace.GetVar(id);
  if Result <> nil then Exit;
  curid := CurSpace.ScopeID;

  // 全体を検索
  for i := 0 to Count - 1 do
  begin
    s := Items[i];
    if curid = s.ScopeID then Continue; // 検索済みなので飛ばす
    Result := s.GetVar(id);
    if Result <> nil then Break;
  end;

end;

function THiNamespace.GetVarNamespace(NamespaceID: Integer;
  WordID: DWORD): PHiValue;
var
  i: Integer;
  s,fs: THiScope;
begin
  fs := Items[0]; // SYSTEM

  if NamespaceID >= 0 then
  begin
    for i := 0 to Count - 1 do
    begin
      s := Items[i];
      if s.ScopeID = NamespaceID then
      begin
        fs := s; Break;
      end;
    end;
  end;

  Result := fs.GetVar(WordID);
end;

procedure THiNamespace.SetCurSpace(id: Integer);
var
  s: THiScope;
begin
  CurSpace := Items[0]; // SYSTEM
  if id < 0 then Exit;
  s := FindSpace(id);
  CurSpace := s;
end;

procedure THiNamespace.SetCurSpaceE(const Value: THiScope);
begin
  FCurSpace := Value;
end;

procedure HiSystemReset;
begin
  FreeAndNil(FHiSystem);
  HiSystem.CheckInitSystem;
end;

{ THiPlugin }

constructor THiPlugin.Create;
begin
  ID := -1;
  FullPath := '';
  Handle := 0;
  Used := False;
  memo := '';
  NotUseAutoFree := False;
end;

destructor THiPlugin.Destroy;
begin
  if Handle <> 0 then FreeLibrary(Handle);
  inherited;
end;

{ THiPlugins }

procedure THiPlugins.addDll(fname: string);
var
  p: THiPlugin;
begin
  // 重複チェック
  if find(fname) >= 0 then Exit;
  //
  p := THiPlugin.Create;
  p.FullPath := fname;
  p.ID := Self.Count;
  p.Used := True;
  p.NotUseAutoFree := True;
  Self.Add(p);
end;

procedure THiPlugins.ChangeUsed(id, PluginID: Integer; Value: Boolean; memo: string;
  IzonFiles: string);
var
  p: THiPlugin;
  sl: TStringList;
  i: Integer;
begin
  // 依存関係のあるファイルをメモ
  if IzonFiles <> '' then
  begin
    sl := SplitChar(',', IzonFiles);
    for i := 0 to sl.Count - 1 do
    begin
      HiSystem.plugins.addDll(AppPath + 'plug-ins\' + sl.Strings[i]);
    end;
    FreeAndNil(sl);
  end;
  // 使われているプラグインをチェック
  if PluginID > 0 then
  begin
    // debugs(hi_id2tango(id));
    p := Items[PluginID];
    p.Used := Value;
    //if pos(memo, p.memo) = 0 then p.memo := p.memo + memo + ',';
    p.memo := p.memo + memo;
  end;
end;

function THiPlugins.find(fname: string): Integer;
var
  i: Integer;
  p: THiPlugin;
  name: string;
begin
  Result := -1;
  name := UpperCase(ExtractFileName(fname));
  for i := 0 to Self.Count - 1 do
  begin
    p := Items[i];
    if p = nil then Continue;
    if UpperCase(ExtractFileName(p.FullPath)) = name then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function THiPlugins.UsedList: string;
var
  i: Integer;
  p: THiPlugin;
begin
  Result := '';
  for i := 0 to Count - 1 do
  begin
    p := Items[i];
    if p.Used then
    begin
      if p.memo = '' then
        Result := Result + p.FullPath + #13#10
      else
        Result := Result + p.FullPath + '(' + p.memo + ')' +#13#10;
    end;
  end;
end;

{ HException }

constructor HException.Create(msg: AnsiString);
begin
  Exception(Self).Create(string(msg));
end;

initialization
  HiSystem.CheckInitSystem; // 起動

finalization
  try
    FreeAndNil(FHiSystem);
  except
  end;

end.
