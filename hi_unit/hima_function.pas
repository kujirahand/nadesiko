
{$IFDEF RTLVersion >= 15}
{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_LIBRARY ON}
{$WARN SYMBOL_PLATFORM ON}
{$WARN UNIT_LIBRARY ON}
{$WARN UNIT_PLATFORM ON}
{$WARN UNIT_DEPRECATED ON}
{$WARN HRESULT_COMPAT ON}
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
{$WARN MESSAGE_DIRECTIVE ON}
{$WARN IMPLICIT_VARIANTS ON}
{$WARN UNICODE_TO_LOCALE ON}
{$WARN LOCALE_TO_UNICODE ON}
{$WARN IMAGEBASE_MULTIPLE ON}
{$WARN SUSPICIOUS_TYPECAST ON}
{$WARN PRIVATE_PROPACCESSOR ON}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}
{$ENDIF}
{$I heverdef.inc}

unit hima_function;

// 組み込みの命令など

interface

uses
  Windows, SysUtils, Classes, hima_variable, hima_variable_ex, hima_types, shellapi,
  Variants, Math, DateUtils;


type
  //----------------------------------------------------------------------------
  // 関数の引数を表す型
  //----------------------------------------------------------------------------
  THimaArg = class
  public
    Name     : DWORD;
    VType    : THiVType; // 変数の型を定義
    Value    : PHiValue; // デフォルト値 ... 今のところ必ずしも変数の型と合致してないこともある...
    JosiList : THList;   // 助詞のリスト
    Needed   : Boolean;  // 省略が可能な引数かどうかを表す
    ByRef    : Boolean;  // 参照渡しをするかどうか
    constructor Create;
    destructor Destroy; override;
    procedure Assign(a: THimaArg);
  end;

  THimaArgs = class(THObjectList)
  public
    destructor Destroy; override;
    function  FindFromName(name: DWORD): THimaArg;
    function  Add_JosiCheck(arg: THimaArg): Integer;
    procedure DefineArgs(s: AnsiString);
    procedure Assign(a: THimaArgs);
  end;

  //----------------------------------------------------------------------------
  // 関数を表す型
  //----------------------------------------------------------------------------
  THimaSysFunction = function (args: THiArray): PHiValue; stdcall;
  THiFuncType = (funcSystem, funcDll, funcUser);
  THimaSysFunctionD = function (HandleArg: DWORD): PHiValue; stdcall;

  // 関数の型を表すクラス
  // [注意]（定義内容は含まない）関数内容は、HiSystem.DefFunctionリストにぶら下がっている
  THiFunction = class
  private
    FRefCount: Integer;
  public
    FuncType: THiFuncType;
    Args: THimaArgs;
    PFunc: Pointer; // TSyntaxNode
    DllRetType, DllArgType: AnsiString; // for DLL
    DllArg: THimaRecord;
    PluginID: Integer; // Plug-inを使った命令の場合0以上
    IzonFiles: AnsiString;
    constructor Create;
    destructor Destroy; override;
    procedure Assign(src: THiFunction);
    property RefCount: Integer read FRefCount write FRefCount;
  end;


//------------------------------------------------------------------------------
// THiVarlue に対するメソッド
//------------------------------------------------------------------------------
procedure hi_func_create(v: PHiValue);
procedure hi_func_free(v: PHiValue);
function hi_func(v: PHiValue): THiFunction;

//------------------------------------------------------------------------------
// SYSTEM FUNCTION
//------------------------------------------------------------------------------
function sys_nil(args: THiArray): PHiValue; stdcall;
function sys_echo(args: THiArray): PHiValue; stdcall;
function sys_runspeed(args: THiArray): PHiValue; stdcall;
function sys_copydata_send(args: THiArray): PHiValue; stdcall;
function sys_copydata_sendex(args: THiArray): PHiValue; stdcall;
function sys_ref_syntax(args: THiArray): PHiValue; stdcall;

function sys_say(args: THiArray): PHiValue; stdcall;
function sys_yesno(args: THiArray): PHiValue; stdcall;
function sys_input(args: THiArray): PHiValue; stdcall;
//function sys_print(args: THiArray): PHiValue; stdcall;//  AddFunc  ('表示','{文字列=?}Sを|Sと', 001, sys_print, 'メッセージSを表示する。','ひょうじ');
function sys_timeGettime(args: THiArray): PHiValue; stdcall;
function sys_EnumVar(args: THiArray): PHiValue; stdcall;
function sys_ExistsVar(args: THiArray): PHiValue; stdcall;
function sys_EnumMember(args: THiArray): PHiValue; stdcall;
function sys_EnumMemberEx(args: THiArray): PHiValue; stdcall;
function sys_binView(args: THiArray): PHiValue; stdcall;
function sys_selFile(args: THiArray): PHiValue; stdcall;
function sys_selFileAsSave(args: THiArray): PHiValue; stdcall;
function sys_selDir(args: THiArray): PHiValue; stdcall;
function sys_yesnocancel(args: THiArray): PHiValue; stdcall;
function sys_msg_memo(args: THiArray): PHiValue; stdcall;
function sys_msg_list(args: THiArray): PHiValue; stdcall;
function sys_version_dialog(args: THiArray): PHiValue; stdcall;
function sys_groupCreate(args: THiArray): PHiValue; stdcall;
function sys_getSore(args: THiArray): PHiValue; stdcall;
function sys_group_ornot(args: THiArray): PHiValue; stdcall;

{
function sys_compress(args: THiArray): PHiValue; stdcall;
function sys_extract(args: THiArray): PHiValue; stdcall;
function sys_makesfx(args: THiArray): PHiValue; stdcall;
}
function sys_beep(args: THiArray): PHiValue; stdcall;
function sys_wav(args: THiArray): PHiValue; stdcall;
function sys_mciOpen(args: THiArray): PHiValue; stdcall;
function sys_mciPlay(args: THiArray): PHiValue; stdcall;
function sys_mciStop(args: THiArray): PHiValue; stdcall;
function sys_mciClose(args: THiArray): PHiValue; stdcall;
function sys_mciCommand(args: THiArray): PHiValue; stdcall;
function sys_musPlay(args: THiArray): PHiValue; stdcall;
function sys_musStop(args: THiArray): PHiValue; stdcall;
function sys_musRec(args: THiArray): PHiValue; stdcall;

function sys_calc_add(args: THiArray): PHiValue; stdcall;
function sys_calc_sub(args: THiArray): PHiValue; stdcall;
function sys_calc_let(args: THiArray): PHiValue; stdcall;
function sys_calc_mul(args: THiArray): PHiValue; stdcall;
function sys_calc_div(args: THiArray): PHiValue; stdcall;
function sys_calc_mod(args: THiArray): PHiValue; stdcall;
function sys_calc_add2(args: THiArray): PHiValue; stdcall;
function sys_calc_pow(args: THiArray): PHiValue; stdcall;
function sys_calc_baisu(args: THiArray): PHiValue; stdcall;

function sys_calc_add_b(args: THiArray): PHiValue; stdcall;
function sys_calc_sub_b(args: THiArray): PHiValue; stdcall;
function sys_calc_mul_b(args: THiArray): PHiValue; stdcall;
function sys_calc_div_b(args: THiArray): PHiValue; stdcall;

function sys_comp_GtEq(args: THiArray): PHiValue; stdcall;
function sys_comp_Gt(args: THiArray): PHiValue; stdcall;
function sys_comp_LtEq(args: THiArray): PHiValue; stdcall;
function sys_comp_Lt(args: THiArray): PHiValue; stdcall;
function sys_comp_Eq(args: THiArray): PHiValue; stdcall;
function sys_comp_not(args: THiArray): PHiValue; stdcall;

function sys_int(args: THiArray): PHiValue; stdcall;
function sys_round(args: THiArray): PHiValue; stdcall;
function sys_sisyagonyu(args: THiArray): PHiValue; stdcall;
function sys_ceil(args: THiArray): PHiValue; stdcall;
function sys_floor(args: THiArray): PHiValue; stdcall;
function sys_sisyagonyu2(args: THiArray): PHiValue; stdcall;
function sys_ceil2(args: THiArray): PHiValue; stdcall;
function sys_floor2(args: THiArray): PHiValue; stdcall;
function sys_float(args: THiArray): PHiValue; stdcall;
function sys_logn(args: THiArray): PHiValue; stdcall;
function sys_log2(args: THiArray): PHiValue; stdcall;
function sys_log10(args: THiArray): PHiValue; stdcall;
function sys_sin(args: THiArray): PHiValue; stdcall;
function sys_cos(args: THiArray): PHiValue; stdcall;
function sys_tan(args: THiArray): PHiValue; stdcall;
function sys_arcsin(args: THiArray): PHiValue; stdcall;
function sys_arccos(args: THiArray): PHiValue; stdcall;
function sys_arctan(args: THiArray): PHiValue; stdcall;
function sys_csc(args: THiArray): PHiValue; stdcall;
function sys_sec(args: THiArray): PHiValue; stdcall;
function sys_cot(args: THiArray): PHiValue; stdcall;
function sys_arccsc(args: THiArray): PHiValue; stdcall;
function sys_arcsec(args: THiArray): PHiValue; stdcall;
function sys_arccot(args: THiArray): PHiValue; stdcall;
function sys_hypot(args: THiArray): PHiValue; stdcall;
function sys_sign(args: THiArray): PHiValue; stdcall;
function sys_abs(args: THiArray): PHiValue; stdcall;
function sys_chr(args: THiArray): PHiValue; stdcall;
function sys_asc(args: THiArray): PHiValue; stdcall;
function sys_exp(args: THiArray): PHiValue; stdcall;
function sys_ln(args: THiArray): PHiValue; stdcall;
function sys_frac(args: THiArray): PHiValue; stdcall;
function sys_rnd(args: THiArray): PHiValue; stdcall;
function sys_randomize(args: THiArray): PHiValue; stdcall;
function sys_sqrt(args: THiArray): PHiValue; stdcall;
function sys_hex(args: THiArray): PHiValue; stdcall;
function sys_not(args: THiArray): PHiValue; stdcall;
function sys_or(args: THiArray): PHiValue; stdcall;
function sys_and(args: THiArray): PHiValue; stdcall;
function sys_xor(args: THiArray): PHiValue; stdcall;
function sys_shift_l(args: THiArray): PHiValue; stdcall;
function sys_shift_r(args: THiArray): PHiValue; stdcall;

function sys_rgb(args: THiArray): PHiValue; stdcall;
function sys_wrgb(args: THiArray): PHiValue; stdcall;
//function sys_rgb2wrgb(args: THiArray): PHiValue; stdcall;
function sys_wrgb2rgb(args: THiArray): PHiValue; stdcall;
function sys_RAD2DEG(args: THiArray): PHiValue; stdcall;
function sys_DEG2RAD(args: THiArray): PHiValue; stdcall;

function sys_eval(args: THiArray): PHiValue; stdcall;
function sys_break(args: THiArray): PHiValue; stdcall;
function sys_continue(args: THiArray): PHiValue; stdcall;
function sys_except(args: THiArray): PHiValue; stdcall;
function sys_runtime_error_off(args: THiArray): PHiValue; stdcall;
function sys_end(args: THiArray): PHiValue; stdcall;
function sys_trim(args: THiArray): PHiValue; stdcall;
function sys_return(args: THiArray): PHiValue; stdcall;
function sys_debug(args: THiArray): PHiValue; stdcall;
function sys_assert(args: THiArray): PHiValue; stdcall;
function sys_guguru(args: THiArray): PHiValue; stdcall;
function sys_plugins_enum(args: THiArray): PHiValue; stdcall;
function sys_goto(args: THiArray): PHiValue; stdcall;

(*
  AddFunc  ('変数列挙','{=?}Sの',             172, sys_EnumVar,'Sに「グローバル」か「ローカル」かを指定して変数の一覧を返す。','へんすうれっきょ');
  AddFunc  ('グループ参照コピー','{グループ}Aを{グループ}Bに|AのBへ', 173, ,   'グループAのエイリアスをグループBに作る。','ぐるーぷさんしょうこぴー');
  AddFunc  ('グループコピー','{グループ}Aを{グループ}Bに|AのBへ', 174, ,   'グループAのメンバ全部をグループBにコピーする。Ｂのメンバは初期化されるので注意。','ぐるーぷこぴー');
  AddFunc  ('グループメンバ追加','{グループ}Aを{グループ}Bに|AのBへ', 175, ,   'グループAのメンバ全部をグループBに追加コピーする。','ぐるーぷめんばついか');
  AddFunc  ('変数エイリアス作成','{参照渡し}Aを{参照渡し}Bに|AのBへ', 176, ,   '変数Aのエイリアスを変数Bに設定する。','へんすうえいりあすさくせい');
*)
function sys_groupCopyRef(args: THiArray): PHiValue; stdcall;
function sys_groupCopyVal(args: THiArray): PHiValue; stdcall;
function sys_groupAddMember(args: THiArray): PHiValue; stdcall;
function sys_alias(args: THiArray): PHiValue; stdcall;
function sys_copyData(args: THiArray): PHiValue; stdcall;
function EasyExecPointer(args: THiArray): PHiValue; stdcall;

function sys_getToken(args: THiArray): PHiValue; stdcall;
function sys_getTokenRange(args: THiArray): PHiValue; stdcall;
function sys_getTokenInRange(args: THiArray): PHiValue; stdcall;
function sys_RangeReplace(args: THiArray): PHiValue; stdcall;
function sys_InRangeReplace(args: THiArray): PHiValue; stdcall;
function sys_split(args: THiArray): PHiValue; stdcall;
function sys_join(args: THiArray): PHiValue; stdcall;
function sys_strCountM(args: THiArray): PHiValue; stdcall;
function sys_strCountB(args: THiArray): PHiValue; stdcall;
function sys_LineCount(args: THiArray): PHiValue; stdcall;
function sys_replace(args: THiArray): PHiValue; stdcall;
function sys_replaceOne(args: THiArray): PHiValue; stdcall;
function sys_posM(args: THiArray): PHiValue; stdcall;
function sys_posB(args: THiArray): PHiValue; stdcall;
function sys_midM(args: THiArray): PHiValue; stdcall;
function sys_midB(args: THiArray): PHiValue; stdcall;
function sys_mid_sjis(args: THiArray): PHiValue; stdcall;
function sys_insertM(args: THiArray): PHiValue; stdcall;
function sys_insertB(args: THiArray): PHiValue; stdcall;
function sys_deleteM(args: THiArray): PHiValue; stdcall;
function sys_deleteB(args: THiArray): PHiValue; stdcall;
function sys_posExM(args: THiArray): PHiValue; stdcall;
function sys_posExB(args: THiArray): PHiValue; stdcall;
function sys_addStr(args: THiArray): PHiValue; stdcall;
function sys_addStrR(args: THiArray): PHiValue; stdcall;
function sys_str_splitArray(args: THiArray): PHiValue; stdcall;
function sys_refrain(args: THiArray): PHiValue; stdcall;
function sys_word_count(args: THiArray): PHiValue; stdcall;
function sys_deleteRightM(args: THiArray): PHiValue; stdcall;
function sys_deleteRightB(args: THiArray): PHiValue; stdcall;

function sys_setBinary(args: THiArray): PHiValue; stdcall;
function sys_getBinary(args: THiArray): PHiValue; stdcall;


function sys_ary_find(args: THiArray): PHiValue; stdcall;
function sys_ary_count(args: THiArray): PHiValue; stdcall;
function sys_ary_insert(args: THiArray): PHiValue; stdcall;
function sys_ary_insertEx(args: THiArray): PHiValue; stdcall;
function sys_ary_sort(args: THiArray): PHiValue; stdcall;
function sys_ary_sort_num(args: THiArray): PHiValue; stdcall;
function sys_ary_sort_custom(args: THiArray): PHiValue; stdcall;
function sys_ary_reverse(args: THiArray): PHiValue; stdcall;
function sys_ary_add(args: THiArray): PHiValue; stdcall;
function sys_ary_del(args: THiArray): PHiValue; stdcall;
function sys_ary_random(args: THiArray): PHiValue; stdcall;
function sys_ary_varSplit(args: THiArray): PHiValue; stdcall;
function sys_ary_trim(args: THiArray): PHiValue; stdcall;
function sys_ary_cut(args: THiArray): PHiValue; stdcall;
function sys_ary_exchange(args: THiArray): PHiValue; stdcall;
function sys_ary_slice(args: THiArray): PHiValue; stdcall;

function sys_ary_sum(args: THiArray): PHiValue; stdcall;
function sys_ary_mean(args: THiArray): PHiValue; stdcall;
function sys_ary_StdDev(args: THiArray): PHiValue; stdcall;
function sys_ary_norm(args: THiArray): PHiValue; stdcall;
function sys_ary_max(args: THiArray): PHiValue; stdcall;
function sys_ary_min(args: THiArray): PHiValue; stdcall;
function sys_ary_PopnVariance(args: THiArray): PHiValue; stdcall;


function sys_ary_csv(args: THiArray): PHiValue; stdcall;
function sys_ary_tsv(args: THiArray): PHiValue; stdcall;
function sys_csv_sort(args: THiArray): PHiValue; stdcall;
function sys_csv_sort_num(args: THiArray): PHiValue; stdcall;
function sys_csv_pickup(args: THiArray): PHiValue; stdcall;
function sys_csv_pickupComplete(args: THiArray): PHiValue; stdcall;
function sys_csv_pickupWildcard(args: THiArray): PHiValue; stdcall;
function sys_csv_pickupRegExp(args: THiArray): PHiValue; stdcall;
function sys_csv_find(args: THiArray): PHiValue; stdcall;
function sys_csv_vague_find(args: THiArray): PHiValue; stdcall;
function sys_csv_cols(args: THiArray): PHiValue; stdcall;
function sys_csv2ary(args: THiArray): PHiValue; stdcall;
function sys_tsv2ary(args: THiArray): PHiValue; stdcall;
function sys_csv_rowcol_rev(args: THiArray): PHiValue; stdcall;
function sys_csv_rotate(args: THiArray): PHiValue; stdcall;
function sys_csv_uniq(args: THiArray): PHiValue; stdcall;
function sys_csv_getcol(args: THiArray): PHiValue; stdcall;
function sys_csv_inscol(args: THiArray): PHiValue; stdcall;
function sys_csv_delcol(args: THiArray): PHiValue; stdcall;
function sys_csv_sum(args: THiArray): PHiValue; stdcall;

function sys_hash_enumkey(args: THiArray): PHiValue; stdcall;
function sys_hash_enumvalue(args: THiArray): PHiValue; stdcall;
function sys_hash_deletekey(args: THiArray): PHiValue; stdcall;
function sys_count(args: THiArray): PHiValue; stdcall;

function sys_addr(args: THiArray): PHiValue; stdcall;
function sys_pointer(args: THiArray): PHiValue; stdcall;
function sys_unpointer(args: THiArray): PHiValue; stdcall;
function sys_typeof(args: THiArray): PHiValue; stdcall;
function sys_pack(args: THiArray): PHiValue; stdcall;
function sys_unpack(args: THiArray): PHiValue; stdcall;
function sys_AllocMem(args: THiArray): PHiValue; stdcall;
function sys_toStr(args: THiArray): PHiValue; stdcall;
function sys_toInt(args: THiArray): PHiValue; stdcall;
function sys_toFloat(args: THiArray): PHiValue; stdcall;
function sys_toHash(args: THiArray): PHiValue; stdcall;
function sys_include(args: THiArray): PHiValue; stdcall;

// ※動的に定義すると単語の未定義エラーが出る
// AddFunc('DLL取り込む','{=?}DLLのCをNで',0, sys_def_dll, 'DLLの関数をなでしこにインポートする。Ｃ言語で書かれた宣言Cをなでしこの関数宣言Nで使えるようにする。','DLLとりこむ');
// function sys_def_dll(args: THiArray): PHiValue; stdcall;

function sys_leftM(args: THiArray): PHiValue; stdcall;
function sys_leftB(args: THiArray): PHiValue; stdcall;
function sys_rightM(args: THiArray): PHiValue; stdcall;
function sys_rightB(args: THiArray): PHiValue; stdcall;

function sys_setClipbrd(args: THiArray): PHiValue; stdcall;
function sys_getClipbrd(args: THiArray): PHiValue; stdcall;
function sys_enumwindows(args: THiArray): PHiValue; stdcall;

function sys_now(args: THiArray): PHiValue; stdcall;
function sys_today(args: THiArray): PHiValue; stdcall;
function sys_week(args: THiArray): PHiValue; stdcall;
function sys_weekno(args: THiArray): PHiValue; stdcall;
function sys_sleep(args: THiArray): PHiValue; stdcall;
function sys_thismonth(args: THiArray): PHiValue; stdcall;
function sys_thisyear(args: THiArray): PHiValue; stdcall;
function sys_nextyear(args: THiArray): PHiValue; stdcall;
function sys_lastyear(args: THiArray): PHiValue; stdcall;
function sys_nextmonth(args: THiArray): PHiValue; stdcall;
function sys_lastmonth(args: THiArray): PHiValue; stdcall;

function sys_reMatch(args: THiArray): PHiValue; stdcall;
function sys_reMatchBool(args: THiArray): PHiValue; stdcall;
function sys_reSplit(args: THiArray): PHiValue; stdcall;
function sys_reTR(args: THiArray): PHiValue; stdcall;
function sys_reSub(args: THiArray): PHiValue; stdcall;
function sys_reSubOne(args: THiArray): PHiValue; stdcall;
//function sys_wildMatch(args: THiArray): PHiValue; stdcall;
function sys_DeleteGobi(args: THiArray): PHiValue; stdcall;
function sys_tokenSplit(args: THiArray): PHiValue; stdcall;

function sys_packfile_make(args: THiArray): PHiValue; stdcall;
function sys_packfile_extract(args: THiArray): PHiValue; stdcall;
function sys_packfile_nako_run(args: THiArray): PHiValue; stdcall;
function sys_packfile_nako_load(args: THiArray): PHiValue; stdcall;
function sys_checkpackfile(args: THiArray): PHiValue; stdcall;
function sys_unpackfile(args: THiArray): PHiValue; stdcall;
function sys_packfile(args: THiArray): PHiValue; stdcall;
function sys_packfile_extract_str(args: THiArray): PHiValue; stdcall;
function sys_makeDllReport(args: THiArray): PHiValue; stdcall;
function sys_packfile_enum(args: THiArray): PHiValue; stdcall;



function sys_getEnv(args: THiArray): PHiValue; stdcall;

function sys_dateAdd(args: THiArray): PHiValue; stdcall;
function sys_timeAdd(args: THiArray): PHiValue; stdcall;
function sys_dateSub(args: THiArray): PHiValue; stdcall;
function sys_timeSub(args: THiArray): PHiValue; stdcall;
function sys_date_wa(args: THiArray): PHiValue; stdcall;
function sys_date_format(args: THiArray): PHiValue; stdcall;
function sys_MinutesSub(args: THiArray): PHiValue; stdcall;
function sys_HourSub(args: THiArray): PHiValue; stdcall;
function sys_fromUnixTime(args: THiArray): PHiValue; stdcall;
function sys_toUnixTime(args: THiArray): PHiValue; stdcall;

function sys_format(args: THiArray): PHiValue; stdcall;
function sys_formatzero(args: THiArray): PHiValue; stdcall;
function sys_formatmoney(args: THiArray): PHiValue; stdcall;
function sys_str_center(args: THiArray): PHiValue; stdcall;
function sys_str_right(args: THiArray): PHiValue; stdcall;
function sys_zen_kana(args: THiArray): PHiValue; stdcall;
function sys_hira_kana(args: THiArray): PHiValue; stdcall;
function sys_kata_kana(args: THiArray): PHiValue; stdcall;
function sys_suuji_kana(args: THiArray): PHiValue; stdcall;
function sys_suuretu_kana(args: THiArray): PHiValue; stdcall;
function sys_eiji_kana(args: THiArray): PHiValue; stdcall;
function sys_str_comp(args: THiArray): PHiValue; stdcall;
function sys_str_comp_jisyo(args: THiArray): PHiValue; stdcall;

function sys_extractFile(args: THiArray): PHiValue; stdcall;
function sys_extractFilePath(args: THiArray): PHiValue; stdcall;
function sys_extractExt(args: THiArray): PHiValue; stdcall;
function sys_changeExt(args: THiArray): PHiValue; stdcall;
function sys_makeoriginalfile(args: THiArray): PHiValue; stdcall;
function sys_expand_path(args: THiArray): PHiValue; stdcall;





// DLLの引数タイプ文字列をＳＤＫ宣言からシステムネイティブに置換する
procedure replace_dll_types(var arg: AnsiString);
function nako_getFuncArg(arg: THiArray; index: Integer): PHiValue;
function nako_getSore: PHiValue;
procedure GetDialogSetting(var init: AnsiString; var cancel: AnsiString;
  var ime: AnsiString; var title: AnsiString);
function IsDialogConvNum: Boolean;


function GetMainWindowCaption: AnsiString;


// 引数を簡単に取得する
function getArg(h: THiArray; Index: Integer; UseHokan: Boolean = False): PHiValue;
function getArgInt(h: THiArray; Index: Integer; UseHokan: Boolean = False): Integer;
function getArgStr(h: THiArray; Index: Integer; UseHokan: Boolean = False): AnsiString;
function getArgBool(h: THiArray; Index: Integer; UseHokan: Boolean = False): Boolean;
function getArgFloat(h: THiArray; Index: Integer; UseHokan: Boolean = False): HFloat;

var MainWindowHandle: Integer = 0;

implementation

uses
  mmsystem,hima_system, unit_string, hima_string, hima_token, unit_file_dnako,
  hima_variable_lib, unit_windows_api, hima_error, BRegExp,
  mini_func, mini_file_utils,
  hima_parser, unit_date, unit_pack_files, hima_stream,
  nako_dialog_function2, common_function, mt19937, unit_text_file;


// 引数を簡単に取得する
function getArg(h: THiArray; Index: Integer; UseHokan: Boolean = False): PHiValue;
begin
  Result := nako_getFuncArg(h, Index);
  if (Result = nil)and(UseHokan) then
  begin
    Result := nako_getSore;
  end;
end;
function getArgInt(h: THiArray; Index: Integer; UseHokan: Boolean = False): Integer;
begin
  Result := hi_int(getArg(h, Index,UseHokan));
end;
function getArgStr(h: THiArray; Index: Integer; UseHokan: Boolean = False): AnsiString;
begin
  Result := hi_str(getArg(h, Index,UseHokan));
end;
function getArgBool(h: THiArray; Index: Integer; UseHokan: Boolean = False): Boolean;
begin
  Result := hi_bool(getArg(h, Index,UseHokan));
end;
function getArgFloat(h: THiArray; Index: Integer; UseHokan: Boolean = False): HFloat;
begin
  Result := hi_float(getArg(h, Index,UseHokan));
end;


function IsDialogConvNum: Boolean;
var p: PHiValue;
begin
  p := HiSystem.GetVariableS('ダイアログ数値変換');
  Result := hi_bool(p);
end;

function GetMainWindowCaption: AnsiString;
var
  len: Integer;
  s: AnsiString;
begin
  Result := '';
  len := GetWindowTextLength(MainWindowHandle);
  if len > 0 then
  begin
    SetLength(s, len);
    GetWindowTextA(MainWindowHandle, PAnsiChar(s), len + 1);
  end else
  begin
    s := '';
  end;
  s := AnsiString(Trim(string(s)));
  if s = '' then Result := 'なでしこ' else Result := s;
end;

procedure replace_dll_types(var arg: AnsiString);
var p:PAnsiChar;i:integer;
begin
  if arg = '' then begin
    exit;
  end;
  p:=PAnsiChar(arg);
  i:=Pos('*',string(arg));
  if i <> 0 then
    Delete(arg,i,1);
  case p^ of
    'P': begin
      if (Length(arg)=5) and CompareMem(p+1,PAnsiChar('OINT'),4) then begin
          arg := '' //POINT
      end else begin
        Delete(arg,1,1);
        replace_dll_types(arg);
        if (arg = '')or(arg = 'VOID') then
          arg := 'POINTER'
        else
          i := 1;
      end;
    end;
    'H': begin
      if (Length(arg)=7) and CompareMem(p+1,PAnsiChar('IVALUE'),6) then begin
          arg := '' //HIVALUE
      end else if (Length(arg)=8) and CompareMem(p+1,PAnsiChar('ALF_PTR'),7) then begin
{$IFDEF WIN32}
              arg := 'SHORT'  //HALF_PTR
{$ELSE}
              arg := 'LONG'   //HALF_PTR
{$ENDIF}
      end else if (Length(arg)=7) and CompareMem(p+1,PAnsiChar('RESULT'),6) then begin
              arg := 'LONG'   //HRESULT
      end else if (Length(arg)=5) and CompareMem(p+1,PAnsiChar('FILE'),4) then begin
              arg := 'LONG'   //HFILE
      end else begin
        arg := 'DWORD';//HANDLE
      end;
    end;
    'L': begin
      case (p+1)^ of
        'P': begin
          if (Length(arg)=6) and CompareMem(p+2,PAnsiChar('ARAM'),4) then begin
{$IFDEF WIN32}
              arg := 'LONG'  //LPARAM
{$ELSE}
              arg := 'INT64' //LPARAM
{$ENDIF}
          end else begin
            Delete(arg,1,2);
            replace_dll_types(arg);
            if (arg = '')or(arg = 'VOID') then
              arg := 'POINTER'
            else
              i := 1;
          end;
        end;
        'A': begin
          if (Length(arg)=6) and CompareMem(p+2,PAnsiChar('NGID'),4) then begin
            arg := 'WORD';//LANGID
          end else
            Delete(arg,1,MaxInt);
        end;
        'C': begin
          if (Length(arg)=4) and CompareMem(p+2,PAnsiChar('ID'),2) then begin
            arg := 'DWORD';//LCID
          end else if (Length(arg)=6) and CompareMem(p+2,PAnsiChar('TYPE'),4) then begin
            arg := 'DWORD';//LCTYPE
          end else
            Delete(arg,1,MaxInt);
        end;
        'G': begin
          if (Length(arg)=6) and CompareMem(p+2,PAnsiChar('RPID'),4) then begin
            arg := 'DWORD';//LGRPID
          end else
            Delete(arg,1,MaxInt);
        end;
        'R': begin
          if (Length(arg)=7) and CompareMem(p+2,PAnsiChar('ESULT'),5) then begin
{$IFDEF WIN32}
              arg := 'LONG'  //LRESULT
{$ELSE}
              arg := 'INT64' //LRESULT
{$ENDIF}
          end else
            Delete(arg,1,MaxInt);
        end;
        else begin
          if (Length(arg)>=4) and CompareMem(p+1,PAnsiChar('ONG'),3) then begin
            if (Length(arg)=8) and CompareMem(p+4,PAnsiChar('LONG'),4) then
              arg := 'INT64' else//LONGLONG
            if (Length(arg)=6) and CompareMem(p+4,PAnsiChar('64'),2)   then
              arg := 'INT64' else//LONG64
            if (Length(arg)=6) and CompareMem(p+4,PAnsiChar('32'),2)   then
              arg := 'LONG'  else//LONG32
            if (Length(arg)=8) and CompareMem(p+4,PAnsiChar('_PTR'),4) then
{$IFDEF WIN32}
              arg := 'LONG'  else//LONG_PTR
{$ELSE}
              arg := 'INT64' else//LONG_PTR
{$ENDIF}
            if (Length(arg)=4) then
              {arg := 'LONG'}else//LONG

              Delete(arg,1,MaxInt);
          end else
            Delete(arg,1,MaxInt);
        end;
      end;
    end;
    'U': begin
      case (p+1)^ of
        'I': begin
          if (Length(arg)>=4) and CompareMem(p+2,PAnsiChar('NT'),2) then begin
            if (Length(arg)=6) and CompareMem(p+4,PAnsiChar('64'),2) then begin
              arg := 'QWORD';//UINT64
            end else if (Length(arg)=6) and CompareMem(p+4,PAnsiChar('32'),2) then begin
              arg := 'DWORD';//UINT32
            end else if (Length(arg)=8) and CompareMem(p+4,PAnsiChar('_PTR'),4) then begin
{$IFDEF WIN32}
              arg := 'DWORD' //UINT_PTR
{$ELSE}
              arg := 'QWORD' //UINT_PTR
{$ENDIF}    end else if (Length(arg)=4) then begin
              arg := 'DWORD';//UINT
            end else
              Delete(arg,1,MaxInt);
          end else
            Delete(arg,1,MaxInt);
        end;
        'L': begin
          if (Length(arg)>=5) and CompareMem(p+2,PAnsiChar('ONG'),3) then begin
            if (Length(arg)=7) and CompareMem(p+5,PAnsiChar('64'),2) then begin
              arg := 'QWORD';//ULONG64
            end else if (Length(arg)=7) and CompareMem(p+5,PAnsiChar('32'),2) then begin
              arg := 'DWORD';//ULONG32
            end else if (Length(arg)=9) and CompareMem(p+5,PAnsiChar('LONG'),4) then begin
              arg := 'QWORD';//ULONGLONG
            end else if (Length(arg)=9) and CompareMem(p+5,PAnsiChar('_PTR'),4) then begin
{$IFDEF WIN32}
              arg := 'DWORD' //ULONG_PTR
{$ELSE}
              arg := 'QWORD' //ULONG_PTR
{$ENDIF}
            end else if (Length(arg)=5) then begin
              arg := 'DWORD';//ULONG
            end else
              Delete(arg,1,MaxInt);
          end else
            Delete(arg,1,MaxInt);
        end;
        'C': begin
          if (Length(arg)=5) and CompareMem(p+2,PAnsiChar('HAR'),3) then begin
            arg := 'BYTE';//UCHAR
          end else
            Delete(arg,1,MaxInt);
        end;
        'S': begin
          case (p+2)^ of
            'H': begin
              if (Length(arg)=6) and CompareMem(p+2,PAnsiChar('ORT'),4) then begin
                arg := 'WORD';//USHORT
              end else
                Delete(arg,1,MaxInt);
            end;
            'N': begin
              if (Length(arg)=3)then begin
                arg := 'INT64';//USN
              end else
                Delete(arg,1,MaxInt);
            end;
            else
              Delete(arg,1,MaxInt);
          end;
        end;
        'H': begin
          if (Length(arg)=9) and CompareMem(p+2,PAnsiChar('ALF_PTR'),7) then begin
{$IFDEF WIN32}
            arg := 'WORD'    //UHALF_PTR
{$ELSE}
            arg := 'DWORD'   //UHALF_PTR
{$ENDIF}
          end else
            Delete(arg,1,MaxInt);
        end;
        else
          Delete(arg,1,MaxInt);
      end;
    end;
    'D': begin
      case (p+1)^ of
        'W': begin
          if (Length(arg)>=5) and CompareMem(p+2,PAnsiChar('ORD'),3) then begin
            if (Length(arg)=9) and CompareMem(p+5,PAnsiChar('LONG'),4) then begin
              arg := 'QWORD';//DWORDLONG
            end else if (Length(arg)=9) and CompareMem(p+5,PAnsiChar('_PTR'),4) then begin
{$IFDEF WIN32}
              arg := 'DWORD' //DWORD_PTR
{$ELSE}
              arg := 'QWORD' //DWORD_PTR
{$ENDIF}
            end else if (Length(arg)=7) and CompareMem(p+5,PAnsiChar('32'),2) then begin
              arg := 'DWORD' //DWORD32
            end else if (Length(arg)=7) and CompareMem(p+5,PAnsiChar('64'),2) then begin
              arg := 'QWORD' //DWORD64
            end else if (Length(arg)=5) then begin
              //arg := 'DWORD';//DWORD
            end else
              Delete(arg,1,MaxInt);
          end else
            Delete(arg,1,MaxInt);
        end;
        'O': begin
          if (Length(arg)=6) and CompareMem(p+2,PAnsiChar('UBLE'),4) then begin
            arg := 'REAL';//DOUBLE
          end else
            Delete(arg,1,MaxInt);
        end;
        else
          Delete(arg,1,MaxInt);
      end;
    end;
    'C': begin
      case (p+1)^ of
        'H': begin
          if (Length(arg)>=4) and CompareMem(p+2,PAnsiChar('AR'),2) then begin
            if (Length(arg)=5) and ((p+4)^='*') then begin
              arg := 'PCHAR';//CHAR*
            end else if (Length(arg)=4) then begin
              //arg:='CHAR';//CHAR
            end else
              Delete(arg,1,MaxInt);
          end else
            Delete(arg,1,MaxInt);
        end;
        'A': begin
          if (Length(arg)=8) and CompareMem(p+2,PAnsiChar('RDINAL'),6) then begin
            arg := 'DWORD';//DOUBLE
          end else
            Delete(arg,1,MaxInt);
        end;
        'O': begin
          if (Length(arg)=8) and CompareMem(p+2,PAnsiChar('LORREF'),6) then begin
            arg := 'DWORD';//COLORREF
          end else
            Delete(arg,1,MaxInt);
        end;
        else
          Delete(arg,1,MaxInt);
      end;
    end;
    'I': begin
      //INT*
      if (Length(arg)>=3) and CompareMem(p,PAnsiChar('INT'),3) then begin
        if (Length(arg)=7) and CompareMem(p+3,PAnsiChar('_PTR'),4) then begin
{$IFDEF WIN32}
          arg := 'LONG'   //INT_PTR
{$ELSE}
          arg := 'INT64'  //INT_PTR
{$ENDIF}
        end else if (Length(arg)=7) and CompareMem(p+3,PAnsiChar('EGER'),4) then begin
          arg := 'LONG';  //INTEGER
        end else if (Length(arg)=5) and CompareMem(p+3,PAnsiChar('64'),2) then begin
          //arg := 'INT64';  //INT64
        end else if (Length(arg)=5) and CompareMem(p+3,PAnsiChar('32'),2) then begin
          arg := 'LONG';  //INT32
        end else if (Length(arg)=3) then begin
          arg := 'LONG';  //INT
        end else
          Delete(arg,1,MaxInt);
      end else
        Delete(arg,1,MaxInt);
    end;
    'B': begin
      case (p+1)^ of
        'O': begin
          if (Length(arg)>=4) and CompareMem(p+2,PAnsiChar('OL'),2) then begin
            if (Length(arg)=7) and CompareMem(p+4,PAnsiChar('EAN'),3) then begin
              arg := 'LONG';  //BOOLEAN
            end else if (Length(arg)=4) then begin
              arg := 'LONG';  //BOOL
            end else
              Delete(arg,1,MaxInt);
          end else
            Delete(arg,1,MaxInt);
        end;
        'Y': begin
          if (Length(arg)>=4) and CompareMem(p+2,PAnsiChar('TE'),2) then begin
            //arg := 'BYTE';  //BYTE
          end else
            Delete(arg,1,MaxInt);
        end;
        else
          Delete(arg,1,MaxInt);
      end;
    end;
    'W':begin
      case (p+1)^ of
        'P': begin
          if (Length(arg)=6) and CompareMem(p+2,PAnsiChar('ARAM'),4) then begin
{$IFDEF WIN32}
              arg := 'DWORD' //WPARAM
{$ELSE}
              arg := 'QWORD' //WPARAM
{$ENDIF}
          end else begin
            Delete(arg,1,MaxInt);
          end;
        end;
        'O': begin
          if (Length(arg)=4) and CompareMem(p+2,PAnsiChar('RD'),2) then begin
            //arg := 'WORD' //WORD
          end else begin
            Delete(arg,1,MaxInt);
          end;
        end;
        else
          Delete(arg,1,MaxInt);
      end;
    end;
    'S': begin
      case (p+1)^ of
        'H': begin
          if (Length(arg)=5) and CompareMem(p+2,PAnsiChar('ORT'),3) then begin
            //arg := 'SHORT' //SHORT
          end else begin
            Delete(arg,1,MaxInt);
          end;
        end;
        'C': begin
          if (Length(arg)=9) and CompareMem(p+2,PAnsiChar('_HANDLE'),7) then begin
            arg := 'DWORD' //SC_HANDLE
          end else if (Length(arg)=7) and CompareMem(p+2,PAnsiChar('_LOCK'),5) then begin
            arg := 'POINTER' //SC_LOCK
          end else begin
            Delete(arg,1,MaxInt);
          end;
        end;
        'E': begin
          if (Length(arg)=21) and CompareMem(p+2,PAnsiChar('RVICE_STATUS_HANDLE'),19) then begin
            arg := 'DWORD' //SERVICE_STATUS_HANDLE
          end else begin
            Delete(arg,1,MaxInt);
          end;
        end;
        'I': begin
          if (Length(arg)=6) and CompareMem(p+2,PAnsiChar('ZE_T'),4) then begin
{$IFDEF WIN32}
            arg := 'DWORD' //SIZE_T
{$ELSE}
            arg := 'QWORD' //SIZE_T
{$ENDIF}
          end else begin
            Delete(arg,1,MaxInt);
          end;
        end;
        'S': begin
          if (Length(arg)=7) and CompareMem(p+2,PAnsiChar('IZE_T'),5) then begin
{$IFDEF WIN32}
            arg := 'LONG'  //SSIZE_T
{$ELSE}
            arg := 'INT64' //SSIZE_T
{$ENDIF}
          end else begin
            Delete(arg,1,MaxInt);
          end;
        end;
        else
          Delete(arg,1,MaxInt);
      end;
    end;
    'V': begin
      if (Length(arg)=4) and CompareMem(p+1,PAnsiChar('OID'),3) then begin
        //arg := 'VOID' //VOID
      end else begin
        Delete(arg,1,MaxInt);
      end;
    end;
    'F': begin
      if (Length(arg)=5) and CompareMem(p+1,PAnsiChar('LOAT'),4) then begin
        //arg := 'FLOAT' //FLOAT
      end else begin
        Delete(arg,1,MaxInt);
      end;
    end;
    'R': begin
      if (Length(arg)=4) and CompareMem(p+1,PAnsiChar('EAL'),3) then begin
        //arg := 'REAL' //REAL
      end else begin
        Delete(arg,1,MaxInt);
      end;
    end;
    'Q': begin
      if (Length(arg)=5) and CompareMem(p+1,PAnsiChar('WORD'),4) then begin
        //arg := 'QWORD' //QWORD
      end else begin
        Delete(arg,1,MaxInt);
      end;
    end;
    'T': begin
      case (p+1)^ of
        'B': begin
          if (Length(arg)=5) and CompareMem(p+2,PAnsiChar('YTE'),3) then begin
              arg := 'BYTE' //TBYTE
          end else begin
            Delete(arg,1,MaxInt);
          end;
        end;
        'C': begin
          if (Length(arg)=5) and CompareMem(p+2,PAnsiChar('HAR'),3) then begin
            arg := 'CHAR' //TCHAR
          end else begin
            Delete(arg,1,MaxInt);
          end;
        end;
        else
          Delete(arg,1,MaxInt);
      end;
    end;
    else begin
      Delete(arg,1,MaxInt);
    end;
  end;
  //Result := arg;
  if i<>0 then begin
    arg:='P'+arg;
    {i:=Length(arg);
    SetLength(arg,i+1);
    p:=PAnsiChar(arg);
    Move(p^,(p+1)^,i);
    p^:='*';}
  end;
end;

function nako_getFuncArg(arg: THiArray; index: Integer): PHiValue;
begin
  Result := arg.Items[index];
end;

function nako_getSore: PHiValue;
begin
  Result := HiSystem.Sore;
end;

//------------------------------------------------------------------------------
{ システム関数 }



function sys_setClipbrd(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := args.FindKey(token_s);
  if s = nil then s := HiSystem.Sore;

  // (2) データの処理
  ClipbrdSetAsText(hi_str(s));

  // (3) 戻り値を設定
  Result := nil;
end;

function sys_getClipbrd(args: THiArray): PHiValue; stdcall;
begin
  // (1) 引数の取得
  // (2) データの処理

  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, ClipbrdGetAsText);
end;

function sys_now(args: THiArray): PHiValue; stdcall;
begin
  Result := hi_var_new;
  hi_setStr(Result, AnsiString(FormatDateTime('hh:nn:ss', Now)));
end;

function sys_today(args: THiArray): PHiValue; stdcall;
begin
  Result := hi_var_new;
  hi_setStr(Result, AnsiString(FormatDateTime('yyyy/mm/dd', Date)));
end;
function sys_thisyear(args: THiArray): PHiValue; stdcall;
begin
  Result := hi_var_new;
  hi_setStr(Result, AnsiString(FormatDateTime('yyyy', Date)));
end;
function sys_thismonth(args: THiArray): PHiValue; stdcall;
begin
  Result := hi_var_new;
  hi_setStr(Result, AnsiString(FormatDateTime('m', Date)));
end;

function sys_nextyear(args: THiArray): PHiValue; stdcall;
var
  yy,mm,dd:WORD;
begin
  DecodeDate(Date, yy, mm, dd); Inc(yy);
  Result := hi_newInt(yy);
end;
function sys_lastyear(args: THiArray): PHiValue; stdcall;
var
  yy,mm,dd:WORD;
begin
  DecodeDate(Date, yy, mm, dd); Dec(yy);
  Result := hi_newInt(yy);
end;
function sys_nextmonth(args: THiArray): PHiValue; stdcall;
var
  yy,mm,dd:WORD;
begin
  DecodeDate(Date, yy, mm, dd); Inc(mm); if mm > 12 then mm := 1;
  Result := hi_newInt(mm);
end;
function sys_lastmonth(args: THiArray): PHiValue; stdcall;
var
  yy,mm,dd:WORD;
begin
  DecodeDate(Date, yy, mm, dd); dec(mm); if mm < 1 then mm := 12;
  Result := hi_newInt(mm);
end;


function sys_week(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
  d: TDateTime;
const
  //日曜日が 1 で，土曜日が 7 に相当します。
  mn: array [1..7] of AnsiString = ('日','月','火','水','木','金','土');
begin
  Result := hi_var_new;

  s := args.Items[0]; if s = nil then s := HiSystem.Sore;
  try
    d := VarToDateTime(hi_str(s));
  except
    d := Date;
  end;

  hi_setStr( Result, mn[DayOfWeek(d)] );
end;

function sys_weekno(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
  d: TDateTime;
  i: Integer;
begin
  s := args.Items[0]; if s = nil then s := HiSystem.Sore;
  try
    d := VarToDateTime(hi_str(s));
  except
    d := Date;
  end;
  i := DayOfWeek(d) - 1;
  Result := hi_newInt(i);
end;

function sys_sleep(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
begin
  s := args.Items[0]; if s = nil then s := HiSystem.Sore;
  sleep(Trunc(1000 * hi_float(s)));
  Result := nil;
end;



function sys_getToken(args: THiArray): PHiValue;
var
  s, a: PHiValue;
  str,kugiri,token: AnsiString;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s := args.FindKey(token_s);
  a := args.FindKey(token_a);

  if s <> nil then str := hi_str(s) else str := hi_str(HiSystem.Sore);
  kugiri := hi_str(a);

  // (2) データの処理
  token := getToken_s(str, kugiri);

  // (3) 戻り値を設定
  hi_setStr(Result, token);
  if s <> nil then hi_setStr(s, str);
end;

function sys_getTokenRange(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
  str, sa, sb, res, rem: AnsiString;
begin
  // (1) 引数の取得
  s := args.Values[0];
  if s = nil then s := HiSystem.Sore;
  
  str := hi_str(s);
  sa := getArgStr(args, 1);
  sb := getArgStr(args, 2);

  // (2) データの処理
  // --A-- [sa] --B-- [sb] --C--
  res := ''; // B
  rem := ''; // A + C

  rem := rem + getToken_s(str, sa); // A
  res := res + getToken_s(str, sb); // B
  rem := rem + str; // C

  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, res);

  // 引数 s の内容を変更
  if s <> nil then hi_setStr(s, rem);
end;

function sys_getTokenInRange(args: THiArray): PHiValue; stdcall;
var
  s, a, b: PHiValue;
  str, sa, sb, res: AnsiString;
  idx1, idx2: Integer;
begin
  // (1) 引数の取得
  s := args.FindKey(token_s);
  a := args.FindKey(token_a);
  b := args.FindKey(token_b);

  if s <> nil then str := hi_str(s) else str := hi_str(HiSystem.Sore);
  sa := hi_str(a);
  sb := hi_str(b);

  // (2) データの処理
  // --A-- [sa] --B-- [sb] --C--
  res := ''; // B

  idx1 := PosA(sa, str);
  if idx1 <> 0 then
  begin
    idx2 := PosA((sb),Copy(str,idx1 + Length(sa),High(integer)));
    if idx2 <> 0 then
    begin
      idx2 := idx2 + idx1 + Length(sa) - 1;
      SetLength(res,idx2-idx1-Length(sa));
      Move(str[idx1+Length(sa)],res[1],idx2-idx1-Length(sa));
      Delete(str,idx1,idx2-idx1+Length(sb));
      if s <> nil then hi_setStr(s,str);
    end;
  end;

  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, res);
end;


function sys_RangeReplace(args: THiArray): PHiValue; stdcall;
var
  str, mae: AnsiString;
  s, a, b, c: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0); if s = nil then s := HiSystem.Sore;
  a := nako_getFuncArg(args, 1);
  b := nako_getFuncArg(args, 2);
  c := nako_getFuncArg(args, 3);

  // (2) データの処理
  // ---- a ***** b ====
  // ---- c =====
  str := hi_str(s);
  mae := getToken_s(str, hi_str(a));
  getToken_s(str, hi_str(b));
  str := mae + hi_str(c) + str;

  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, str);
end;

function sys_InRangeReplace(args: THiArray): PHiValue; stdcall;
var
  str, res, sa, sb, sc: string;
  s, a, b, c: PHiValue;
  idx1, idx2: Integer;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0); if s = nil then s := HiSystem.Sore;
  a := nako_getFuncArg(args, 1);
  b := nako_getFuncArg(args, 2);
  c := nako_getFuncArg(args, 3);

  // (2) データの処理
  // ---- a ***** b ====
  // ---- c =====
  str := string(hi_str(s));
  sa  := string(hi_str(a));
  sb  := string(hi_str(b));
  sc  := string(hi_str(c));

  idx1 := Pos(string(sa), string(str));
  if idx1 <> 0 then
  begin
    idx2 := Pos(string(sb),Copy(string(str),idx1 + Length(sa),High(integer)));
    if idx2 <> 0 then
    begin
      idx2 := idx2 + idx1 + Length(sa) - 1;
      begin
        //SetLength(res,Length(str)-(idx2-idx1+Length(sb))+Length(sc));
        //Move(str[1],res[1],idx1-1);
        //Move(sc[1],res[idx1],Length(sc));
        //Move(str[idx2+Length(sb)],res[idx1+Length(sc)],Length(str)-idx2-Length(sb)+1);
        //str:=res;
        // 前
        res := Copy(str, 1, idx1);
        // 置換後文字列
        res := res + sc;
        // 後ろ
        res := res + Copy(str, idx2, Length(str));
        str := res;
      end;
    end;
  end;

  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, AnsiString(str));
end;

function sys_split(args: THiArray): PHiValue;
var
  s, a: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  a := nako_getFuncArg(args, 1);
  if s = nil then s := nako_getSore;

  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_split(s, a);
end;

function sys_join(args: THiArray): PHiValue;
var
  s, a: PHiValue;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  a := args.FindKey(token_a);
  s := args.FindKey(token_s);
  if a = nil then a := HiSystem.Sore;

  // (2) データの処理
  // (3) 戻り値を設定
  if a.VType <> varArray then
  begin
    hi_setStr(Result, hi_str(a)); // 配列でなければ文字列に変換するだけ(^^;
  end else
  begin
    hi_setStr(Result, hi_ary(a).Join(hi_str(s)));
  end;
end;
function sys_strCountM(args: THiArray): PHiValue;
var
  s: PHiValue; str: AnsiString;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s := args.FindKey(token_s);

  // (2) データの処理
  if s = nil then str := hi_str(HiSystem.Sore) else str := hi_str(s);

  // (3) 戻り値を設定
  hi_setInt(Result, JLength(str));
end;

function sys_strCountB(args: THiArray): PHiValue;
var
  s: PHiValue; str: AnsiString;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s := args.FindKey(token_s);

  // (2) データの処理
  if s = nil then str := hi_str(HiSystem.Sore) else str := hi_str(s);

  // (3) 戻り値を設定
  hi_setInt(Result, Length(str));
end;

function sys_LineCount(args: THiArray): PHiValue;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := args.FindKey(token_s);
  // (2) データの処理
  Result := hi_newInt(CountStrLine(hi_str(s)));
end;

function sys_replace(args: THiArray): PHiValue;
var
  s, a, b: AnsiString;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s := getArgStr(args, 0, True);
  a := getArgStr(args, 1);
  b := getArgStr(args, 2);

  // (2) データの処理
  // (3) 戻り値を設定
  hi_setStr(Result, JReplace(s, a, b));
  // ↑バイナリの置換もできるように修正
  //hi_setStr(Result, StringReplace(hi_str(s), hi_str(a), hi_str(b), [rfReplaceAll]));
end;

function sys_replaceOne(args: THiArray): PHiValue;
var
  s, a, b: PHiValue;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s := args.FindKey(token_s); if s = nil then s := HiSystem.Sore;
  a := args.FindKey(token_a);
  b := args.FindKey(token_b);

  // (2) データの処理
  // (3) 戻り値を設定
  hi_setStr(Result, JReplaceOne(hi_str(s), hi_str(a), hi_str(b)));
end;

function sys_posM(args: THiArray): PHiValue;
var
  s, a: PHiValue;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s := args.FindKey(token_s); if s = nil then s := HiSystem.Sore;
  a := args.FindKey(token_a);

  // (2) データの処理
  // (3) 戻り値を設定
  hi_setInt(Result, PosA(hi_str(a), hi_str(s)));
end;

function sys_posB(args: THiArray): PHiValue;
var
  s, a: PHiValue;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s := args.FindKey(token_s); if s = nil then s := HiSystem.Sore;
  a := args.FindKey(token_a);

  // (2) データの処理
  // (3) 戻り値を設定
  hi_setInt(Result, Pos(hi_str(a), hi_str(s)));
end;

function sys_posExM(args: THiArray): PHiValue; stdcall;
var
  s, a, b: PHiValue;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s := args.FindKey(token_s); if s = nil then s := HiSystem.Sore;
  a := args.FindKey(token_a);
  b := args.FindKey(token_b);

  // (2) データの処理
  // (3) 戻り値を設定
  hi_setInt(Result, PosExA(hi_str(b), hi_str(s), hi_int(a)));
end;

function sys_posExB(args: THiArray): PHiValue; stdcall;
var
  s, a, b: PHiValue;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s := args.FindKey(token_s); if s = nil then s := HiSystem.Sore;
  a := args.FindKey(token_a);
  b := args.FindKey(token_b);

  // (2) データの処理
  // (3) 戻り値を設定
  hi_setInt(Result, PosExA2(hi_str(b), hi_str(s), hi_int(a)));
end;

function sys_addStr(args: THiArray): PHiValue; stdcall;
var
  a, b: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); if a = nil then a := HiSystem.Sore;
  b := args.FindKey(token_b);

  // (2) データの処理
  hi_setStr(a, hi_str(a) + hi_str(b));

  // (3) 戻り値を設定
  Result := nil;
end;

function sys_addStrR(args: THiArray): PHiValue; stdcall;
var
  a, b: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); if a = nil then a := HiSystem.Sore;
  b := args.FindKey(token_b);

  // (2) データの処理
  hi_setStr(a, hi_str(a) + hi_str(b) + #13#10);

  // (3) 戻り値を設定
  Result := nil;
end;

function sys_str_splitArray(args: THiArray): PHiValue; stdcall;
var
  s: AnsiString;
  p,p_last: PAnsiChar;
  c: AnsiString;
begin
  s := getArgStr(args, 0, True);
  p := PAnsiChar(s);
  p_last := p + Length(s);
  // 新規文字列を作成
  Result := hi_var_new;
  hi_ary_create(Result);
  while p < p_last do
  begin
    c := getOneChar(p);
    // 改行のときだけ1文字として扱う
    if (c = #13)and(p^ = #10) then
    begin
      c := #13#10;
      Inc(p);
    end;
    hi_ary(Result).Add(hi_newStr(c));
  end;
end;

function sys_refrain(args: THiArray): PHiValue;
var
  s: PHiValue;
  res, str: AnsiString;
  cnt, i, len: Integer;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s   := args.FindKey(token_s); if s = nil then s := HiSystem.Sore;

  str := hi_str(s);
  cnt := hi_int(args.FindKey(token_cnt));
  res := '';

  // (2) データの処理
  len := Length(str);
  if len > 0 then
  begin
    SetLength(res,cnt*len);
    for i:=0 to cnt - 1 do
    begin
      Move(str[1],res[i*len+1],len);
    end;
  end;

  // (3) 戻り値を設定
  hi_setStr(Result, res);
end;

function sys_word_count(args: THiArray): PHiValue;
var
  ss, sa: string;
  res, i, len: integer;
begin
  // (1) 引数の取得
  ss := string(getArgStr(args, 0, True));
  sa := string(getArgStr(args, 1));

  // (2) データの処理
  res := 0;
  len := Length(sa);
  repeat
    i := Pos(sa, ss);
    if i <> 0 then
    begin
      Inc(res);
      Delete(ss, 1, i+len-1);
    end
    else
      Break;
  until false;

  // (3) 戻り値を設定
  Result := hi_newInt(res);
end;

function sys_midM(args: THiArray): PHiValue;
var
  s, a, cnt: PHiValue;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s   := args.FindKey(token_s); if s = nil then s := HiSystem.Sore;
  a   := args.FindKey(token_a);
  cnt := args.FindKey(token_cnt);

  // (2) データの処理
  // (3) 戻り値を設定
  hi_setStr(Result, CopyA(hi_str(s), hi_int(a), hi_int(cnt)));
end;

function sys_midB(args: THiArray): PHiValue;
var
  s, a, cnt: PHiValue;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s   := args.FindKey(token_s); if s = nil then s := HiSystem.Sore;
  a   := args.FindKey(token_a);
  cnt := args.FindKey(token_cnt);

  // (2) データの処理
  // (3) 戻り値を設定
  hi_setStr(Result, Copy(hi_str(s), hi_int(a), hi_int(cnt)));
end;

function sys_mid_sjis(args: THiArray): PHiValue; stdcall;
var
  s, tmp: AnsiString;
  a, cnt: Integer;
begin
  // (1) 引数の取得
  s   := getArgStr(args, 0, True);
  a   := getArgInt(args, 1);
  cnt := getArgInt(args, 2);

  // (2) データの処理
  tmp := sjis_copyB(PAnsiChar(s), a, cnt);

  // (3) 戻り値を設定
  Result := hi_newStr(tmp);
end;

function sys_insertM(args: THiArray): PHiValue;
var
  s, cnt, a: PHiValue; str: WideString;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s   := args.FindKey(token_s);
  cnt := args.FindKey(token_cnt);
  a   := args.FindKey(token_a);

  if s = nil then s := nako_getSore;
  str := WideString(hi_str(s));

  // (2) データの処理
  Insert(WideString(hi_str(a)), str, hi_int(cnt));

  // (3) 戻り値を設定
  hi_setStr(Result, AnsiString(str));
  if s <> nil then hi_setStr(s, AnsiString(str));
end;

function sys_insertB(args: THiArray): PHiValue;
var
  s, cnt, a: PHiValue; str: AnsiString;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s   := args.FindKey(token_s); if s <> nil then str := hi_str(s) else str := hi_str(HiSystem.Sore);
  cnt := args.FindKey(token_cnt);
  a   := args.FindKey(token_a);

  // (2) データの処理
  str := hi_str(s);
  Insert(hi_str(a), str, hi_int(cnt));
  // 変更しないように変更
  //hi_setStr(s, AnsiString(str));

  // (3) 戻り値を設定
  hi_setStr(Result, str);
  if s <> nil then hi_setStr(s, str);
end;

function sys_deleteRightM(args: THiArray): PHiValue; stdcall;
var
  s, a: PHiValue; str: WideString;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s  := args.Items[0];
  a  := args.Items[1];
  s  := hi_getLink(s);
  if s = nil then s := nako_getSore;
  str := WideString(hi_str(s));

  // (2) データの処理
  if Length(str) < hi_int(a) then
  begin
    str := '';
  end else
  begin
    System.Delete(str, Length(str) - hi_int(a) + 1, hi_int(a));
  end;

  // (3) 戻り値を設定
  hi_setStr(Result, AnsiString(str));
  if s <> nil then hi_setStr(s, AnsiString(str));
end;

function sys_deleteRightB(args: THiArray): PHiValue; stdcall;
var
  s, a: PHiValue; str: AnsiString;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s   := args.Items[0]; if s <> nil then str := hi_str(s) else str := hi_str(HiSystem.Sore);
  a   := args.Items[1];
  s  := hi_getLink(s);

  // (2) データの処理
  // abcde,2 = abc3
  if Length(str) < hi_int(a) then
  begin
    str := '';
  end else
  begin
    System.Delete(str, Length(str) - hi_int(a) + 1, hi_int(a));
  end;

  // (3) 戻り値を設定
  hi_setStr(Result, str);
  if s <> nil then hi_setStr(s, str);
end;

function sys_deleteM(args: THiArray): PHiValue;
var
  s, a, b: PHiValue; str: WideString;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s   := args.FindKey(token_s);
  a   := args.FindKey(token_a);
  b   := args.FindKey(token_b);
  if s = nil then s := nako_getSore;
  str := WideString(hi_str(s));

  // (2) データの処理
  System.Delete(str, hi_int(a), hi_int(b));

  // (3) 戻り値を設定
  hi_setStr(Result, AnsiString(str));
  if s <> nil then hi_setStr(s, AnsiString(str));
end;

function sys_deleteB(args: THiArray): PHiValue;
var
  s, a, b: PHiValue; str: AnsiString;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s   := args.FindKey(token_s); if s <> nil then str := hi_str(s) else str := hi_str(HiSystem.Sore);
  a   := args.FindKey(token_a);
  b   := args.FindKey(token_b);

  // (2) データの処理
  System.Delete(str, hi_int(a), hi_int(b));

  // (3) 戻り値を設定
  hi_setStr(Result, str);
  if s <> nil then hi_setStr(s, str);
end;

function sys_ary_find(args: THiArray): PHiValue; stdcall;
var
  a,i,s: PHiValue;
  res: Integer;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  a   := args.Items[0]; if a = nil then a := HiSystem.Sore;
  i   := args.Items[1];
  s   := args.Items[2];

  // (2) データの処理
  hi_ary_create(a);
  res := hi_ary(a).FindIndex(hi_str(s), hi_int(i));

  // (3) 戻り値を設定
  hi_setInt(Result, res);
end;

function sys_ary_count(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
  cnt: Integer;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;

  a := hi_getLink(a);
  if a.VType = varArray then
  begin
    cnt := hi_ary(a).Count;
  end else
  begin
    hi_ary_create(a);
    cnt := hi_ary(a).Count;
  end;
  Result := hi_newInt(cnt);
end;

function sys_count(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
  cnt: Integer;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;
  a := hi_getLink(a);

  case a.VType of
    varArray  :   cnt := hi_ary(a).Count;
    varHash   :   cnt := hi_hash(a).Count;
    varStr    :   cnt := CountStrLine(hi_str(a));
    varGroup  :   cnt := hi_group(a).Count; // default があると正しくグループが得られないので気休め
    else begin
      cnt := CountStrLine(hi_str(a));
    end;
  end;

  Result := hi_newInt(cnt);
end;

function sys_csv_rowcol_rev(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;

  Result := hi_var_new;

  hi_var_copy(a, Result);
  hi_ary_create(Result);

  hi_ary(Result).RowColReverse;
end;

function sys_csv_rotate(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;

  Result := hi_var_new;

  hi_var_copy(a, Result);
  hi_ary_create(Result);

  hi_ary(Result).Rotate;
end;

function sys_csv_uniq(args: THiArray): PHiValue; stdcall;
var
  a, i: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;
  i := args.Items[1];

  a := hi_getLink(a);
  i := hi_getLink(i);

  Result := hi_var_new;
  hi_var_copy(a, Result);
  hi_ary_create(Result);
  hi_ary(Result).CsvUniqCol(hi_int(i));
end;

function sys_csv_getcol(args: THiArray): PHiValue; stdcall;
var
  a, i: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;
  i := args.Items[1];

  a := hi_getLink(a);
  i := hi_getLink(i);

  hi_ary_create(a);
  Result := hi_ary(a).CsvGetCol(hi_int(i));
end;

function sys_csv_inscol(args: THiArray): PHiValue; stdcall;
var
  a, i, s: PHiValue;
begin
  // get arg
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;
  i := args.Items[1];
  s := args.Items[2];
  // link
  a := hi_getLink(a);
  s := hi_getLink(s);
  //
  hi_ary_create(a);
  hi_ary_create(s);
  Result := hi_ary(a).CsvInsCol(hi_int(i), hi_ary(s));
end;

function sys_csv_delcol(args: THiArray): PHiValue; stdcall;
var
  a, i: PHiValue;
begin
  // get arg
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;
  i := args.Items[1];
  // link
  a := hi_getLink(a);
  //
  hi_ary_create(a);
  Result := hi_ary(a).CsvDelCol(hi_int(i));
end;

function sys_csv_sum(args: THiArray): PHiValue; stdcall;
var
  a, i: PHiValue;
begin
  // get arg
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;
  i := args.Items[1];
  // link
  a := hi_getLink(a);
  //
  hi_ary_create(a);
  //
  Result := hi_var_new;
  hi_setIntOrFloat(Result, hi_ary(a).CsvSum(hi_int(i)));
end;

function sys_ary_insert(args: THiArray): PHiValue; stdcall;
var
  a,s,tmp: PHiValue;
  i:integer;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore; // ary
  i := hi_int(args.Items[1]);                           // index
  s := args.Items[2];                                   // ary

  tmp := hi_var_new;
  hi_var_copyData(s, tmp);

  hi_ary_create(a);
  try
    hi_ary(a).Insert(i, tmp);
    hi_ary(a).Values[i].Registered:=1;
  except
    raise Exception.Create('配列の挿入でエラー');
  end;
  Result := nil;
end;
function sys_ary_insertEx(args: THiArray): PHiValue; stdcall;
var
  a, i, s: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;
  i := args.Items[1];
  s := args.Items[2];

  hi_ary_create(a);
  hi_ary_create(s);
  //--------
  hi_ary(a).InsertArray(hi_int(i), hi_ary(s));
  //----------
  Result := hi_var_new;
  hi_var_copyData(a, Result);
end;
function sys_ary_sort(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;

  hi_ary_create(a);
  hi_ary(a).Sort;

  Result := hi_var_new;
  hi_var_copyGensi(a, Result);
end;
function sys_ary_sort_num(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;

  hi_ary_create(a);
  hi_ary(a).SortNum;

  Result := hi_var_new;
  hi_var_copyGensi(a, Result);
end;
function sys_ary_sort_custom(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
  s: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;
  s := args.Items[1];

  hi_ary_create(a);
  hi_ary(a).CustomSort(hi_str(s));

  Result := hi_var_new;
  hi_var_copyGensi(a, Result);
end;
function sys_ary_reverse(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;

  hi_ary_create(a);
  hi_ary(a).Reverse;

  Result := hi_var_new;
  hi_var_copyGensi(a, Result);
end;

function sys_ary_add(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
  s: PHiValue;
  tmp: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;
  s := args.Items[1];

  hi_ary_create(a);
  tmp := hi_var_new;
  hi_var_copyData(s, tmp);

  hi_ary(a).Add(tmp);

  Result := nil;
end;

function sys_ary_del(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
  i: Integer;
begin
  a  := args.Items[0]; if a=nil then a := HiSystem.Sore;
  i  := hi_int( args.Items[1] );

  hi_ary_create(a);
  hi_ary(a).Delete(i);
  Result := nil;
end;

function sys_ary_random(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;

  hi_ary_create(a);
  hi_ary(a).Random;

  Result := hi_var_new;
  hi_var_copyGensi(a, Result);
end;

function sys_ary_varSplit(args: THiArray): PHiValue; stdcall;
var
  ary, v: PHiValue;
  sl  : TStringList;
  i   : Integer;
  s, vname : AnsiString;
begin
  Result := nil;
  ary := args.Items[0]; if (ary = nil) then ary := HiSystem.Sore;
  s   := hi_str(args.Items[1]);
  s   := HimaSourceConverter(-1, s);
  sl  := SplitChar(',', s);
  //
  hi_ary_create(ary);
  for i := 0 to sl.Count - 1 do
  begin
    vname := AnsiString(Trim(string(sl.Strings[i])));
    v := HiSystem.GetVariableS(vname);
    if v = nil then v := HiSystem.CreateHiValue(hi_tango2id(vname));
    hi_var_copyData(hi_ary(ary).Values[i], v);
  end;
end;

function sys_ary_trim(args: THiArray): PHiValue; stdcall;
var
  ary : PHiValue;
begin
  ary := args.Items[0]; if (ary = nil) then ary := HiSystem.Sore;
  hi_ary_create(ary);
  hi_ary(ary).Trim;
  Result := hi_var_new;
  hi_var_copyData(ary, Result);
end;

function sys_ary_cut(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
  i: Integer;
begin
  a  := args.Items[0]; if a=nil then a := HiSystem.Sore;
  i  := hi_int( args.Items[1] );

  Result := hi_var_new;
  hi_ary_create(a);
  hi_var_copy(hi_ary(a).Values[i],Result);
  hi_ary(a).Delete(i);
end;

function sys_ary_exchange(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
  i,j: Integer;
  ary: THiArray;
begin
  a  := args.Items[0]; if a=nil then a := HiSystem.Sore;
  i  := hi_int( args.Items[1] );
  j  := hi_int( args.Items[2] );

  hi_ary_create(a);
  ary := hi_ary(a);
  ary.Exchange(i,j);

  Result := hi_var_new;
  hi_var_copyData(a, Result);
end;

function sys_ary_slice(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
  v1,v2: Integer;
  a_src, a_des: THiArray;
begin
  a  := args.Items[0]; if a=nil then a := HiSystem.Sore;
  v1  := hi_int( args.Items[1] );
  v2  := hi_int( args.Items[2] );

  hi_ary_create(a);
  a_src := hi_ary(a);
  a_des := a_src.CutRow(v1, v2);

  Result := hi_var_new;
  Result.VType := varArray;
  Result.Size  := sizeof(a_des);
  Result.ptr   := a_des;
end;

function sys_ary_sum(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;

  hi_ary_create(a);
  Result := hi_var_new;
  hi_setIntOrFloat(Result, hi_ary(a).sum);
end;

function sys_ary_mean(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;

  hi_ary_create(a);
  Result := hi_var_new;
  hi_setIntOrFloat(Result, hi_ary(a).mean);
end;

function sys_ary_StdDev(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;

  hi_ary_create(a);
  Result := hi_var_new;
  hi_setIntOrFloat(Result, hi_ary(a).stddev);
end;

function sys_ary_norm(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;

  hi_ary_create(a);
  Result := hi_var_new;
  hi_setIntOrFloat(Result, hi_ary(a).norm);
end;

function sys_ary_PopnVariance(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;

  hi_ary_create(a);
  Result := hi_var_new;
  hi_setIntOrFloat(Result, hi_ary(a).norm);
end;

function sys_ary_max(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;

  hi_ary_create(a);
  Result := hi_var_new;
  hi_setIntOrFloat(Result, hi_ary(a).max);
end;

function sys_ary_min(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;

  hi_ary_create(a);
  Result := hi_var_new;
  hi_setIntOrFloat(Result, hi_ary(a).min);
end;

function sys_ary_csv(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;

  Result := hi_var_new;
  hi_ary_create(a);

  hi_setStr(Result, hi_ary(a).AsString);
end;
function sys_csv2ary(args: THiArray): PHiValue; stdcall;
var
  ps: PHiValue;
  s: AnsiString;
begin
  ps := args.Items[0]; if ps=nil then ps := HiSystem.Sore;
  s  := hi_str(ps);

  Result := hi_var_new;
  hi_ary_create(Result);
  hi_ary(Result).AsString := s;
end;
function sys_tsv2ary(args: THiArray): PHiValue; stdcall;
var
  ps: PHiValue;
  s: AnsiString;
begin
  ps := args.Items[0]; if ps=nil then ps := HiSystem.Sore;
  s  := hi_str(ps);

  Result := hi_var_new;
  hi_ary_create(Result);
  hi_ary(Result).AsTSV := s;
end;
function sys_ary_tsv(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;

  Result := hi_var_new;
  hi_ary_create(a);

  hi_setStr(Result, hi_ary(a).AsTsv);
end;
function sys_csv_sort(args: THiArray): PHiValue; stdcall;
var
  a,i: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;
  i := args.Items[1];

  hi_ary_create(a);
  hi_ary(a).SortCsv(hi_int(i));

  Result := hi_var_new;
  hi_var_copyGensi(a, Result);
end;
function sys_csv_sort_num(args: THiArray): PHiValue; stdcall;
var
  a,i: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;
  i := args.Items[1];

  hi_ary_create(a);
  hi_ary(a).SortCsvNum(hi_int(i));

  Result := hi_var_new;
  hi_var_copyGensi(a, Result);
end;

function sys_csv_pickup(args: THiArray): PHiValue; stdcall;
var
  a,i,s: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;
  i := args.Items[1];
  s := args.Items[2];

  hi_ary_create(a);

  Result := hi_var_new;
  Result.VType := varArray;
  Result.Size := sizeof(THiArray);
  Result.ptr := hi_ary(a).CsvPickupHasKey(hi_str(s), hi_int(i));
end;

function sys_csv_pickupWildcard(args: THiArray): PHiValue; stdcall;
var
  a,i,s: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;
  i := args.Items[1];
  s := args.Items[2];

  hi_ary_create(a);

  Result := hi_var_new;
  Result.VType := varArray;
  Result.Size := sizeof(THiArray);
  Result.ptr := hi_ary(a).CsvPickupWildcard(hi_str(s), hi_int(i));
end;

function sys_csv_pickupRegExp(args: THiArray): PHiValue; stdcall;
var
  a,i,s: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;
  i := args.Items[1];
  s := args.Items[2];

  hi_ary_create(a);

  Result := hi_var_new;
  Result.VType := varArray;
  Result.Size := sizeof(THiArray);
  Result.ptr := hi_ary(a).CsvPickupRegExp(hi_str(s), hi_int(i));
end;

function sys_csv_pickupComplete(args: THiArray): PHiValue; stdcall;
var
  a,i,s: PHiValue;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;
  i := args.Items[1];
  s := args.Items[2];

  hi_ary_create(a);

  Result := hi_var_new;
  Result.VType := varArray;
  Result.Size := sizeof(THiArray);
  Result.ptr := hi_ary(a).CsvPickupIsKey(hi_str(s), hi_int(i));
end;

function sys_csv_find(args: THiArray): PHiValue; stdcall;
var
  a,col,s,row: PHiValue;
  res: Integer;
begin
  // {=?}Aの{=-1}COLでSを{=0}ROWから
  a   := args.Items[0]; if a=nil then a := HiSystem.Sore;
  col := args.Items[1];
  s   := args.Items[2];
  row := args.Items[3];

  hi_ary_create(a);
  res := hi_ary(a).CsvFind(hi_int(col), hi_str(s), hi_int(row));

  Result := hi_var_new;
  hi_setInt(Result, res);
end;

function sys_csv_vague_find(args: THiArray): PHiValue; stdcall;
var
  a,col,s,row: PHiValue;
  res: Integer;
begin
  // {=?}Aの{=-1}COLでSを{=0}ROWから
  a   := args.Items[0]; if a=nil then a := HiSystem.Sore;
  col := args.Items[1];
  s   := args.Items[2];
  row := args.Items[3];

  hi_ary_create(a);
  res := hi_ary(a).CsvVagueFind(hi_int(col), hi_str(s), hi_int(row));

  Result := hi_var_new;
  hi_setInt(Result, res);
end;

function sys_csv_cols(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
  c: Integer;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;
  a := hi_getLink(a);

  if a.VType = varArray then
  begin
    //debugs('array');
    c := hi_ary(a).GetColCount;
  end else
  begin
    //debugs('not array');
    hi_ary_create(a);
    c := hi_ary(a).GetColCount;
  end;
  
  Result := hi_newInt(c);
end;



function sys_hash_enumkey(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
  i: Integer;
  res: AnsiString;
  sl: THStringList;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;

  Result := hi_var_new;
  // ハッシュとして取得する
  hi_hash_create(a);
  // キーを列挙する
  res := hi_hash(a).EnumKeys;
  // スペースが消えないように、あらかじめ、配列に変換する
  hi_ary_create(Result);
  sl := THStringList.Create;
  try
    sl.Text := res;
    hi_ary(Result).Grow(sl.Count);
    for i := 0 to sl.Count - 1 do
    begin
      hi_ary_setStr(Result, i, sl.Strings[i]);
    end;
  finally
    FreeAndNil(sl);
  end;
end;

function sys_hash_deletekey(args: THiArray): PHiValue; stdcall;
var
  a,b: PHiValue;
begin
  Result := nil;

  a := args.Items[0]; if a=nil then a := HiSystem.Sore;
  b := args.Items[1];

  hi_hash_create(a);
  hi_hash(a).DeleteKey(hi_str(b));
end;

function sys_hash_enumvalue(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
  res: AnsiString;
  i: Integer;
  sl: THStringList;
begin
  a := args.Items[0]; if a=nil then a := HiSystem.Sore;

  Result := hi_var_new;
  hi_hash_create(a);
  // ハッシュの値を列挙
  res := hi_hash(a).EnumValues;
  // ハッシュの空白が削除されないように配列として返す
  hi_ary_create(Result);
  sl := THStringList.Create;
  try
    sl.Text := res;
    hi_ary(Result).Grow(sl.Count);
    for i := 0 to sl.Count - 1 do
    begin
      hi_ary_setStr(Result, i, sl.Strings[i]);
    end;
  finally
    FreeAndNil(sl);
  end;
end;


//---


function sys_addr(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  a   := args.FindKey(token_a);

  // (2) データの処理
  // (3) 戻り値を設定
  hi_setInt(Result, Integer(a));
end;

function sys_toInt(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s   := args.FindKey(token_s);
  if s = nil then s := HiSystem.Sore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_newInt(hi_int(s));
end;

function sys_toFloat(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s   := args.FindKey(token_s);
  if s = nil then s := HiSystem.Sore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setFloat(Result, hi_Float(s));
end;

function sys_toHash(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s   := args.FindKey(token_s);
  if s = nil then s := HiSystem.Sore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_var_copyData(s, Result);
  hi_hash_create(Result);
end;

function sys_include(args: THiArray): PHiValue; stdcall;
var
  fname: AnsiString;
  n: TSyntaxNode;
begin
  // (1) 引数の取得
  fname := getArgStr(args, 0, True);
  // (2) データの処理
  // (3) 戻り値を設定
  HiSystem.PushRunFlag;
  try
    n := nil;
    Result := HiSystem.ImportFile(string(fname), n);
  finally
    HiSystem.PopRunFlag;
  end;
end;

function sys_def_dll(args: THiArray): PHiValue; stdcall;
var
  dll, cdef, ndef, s: AnsiString;
begin
  // (1) 引数の取得
  // DLLのCをNで
  dll  := getArgStr(args, 0, True);
  cdef := getArgStr(args, 1);
  ndef := getArgStr(args, 2);

  // (2) データの処理
  s := '*' + ndef + '=DLL("' + dll + '","' + cdef + '");';
  try
    HiSystem.Eval2(s);
  except
    on e: Exception do raise Exception.Create('DLL取り込みでエラー。' + e.Message);
  end;
  // (3) 戻り値を設定
  Result := nil;
end;

function sys_toStr(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s   := args.FindKey(token_s);
  if s = nil then s := HiSystem.Sore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_newStr(hi_str(s));
end;

function sys_pointer(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  a   := args.FindKey(token_a);

  // (2) データの処理
  // (3) 戻り値を設定
  if a.VType <> varInt then
    hi_setInt(Result, Integer(a.ptr))
  else
    hi_setInt(Result, Integer(@a.int));
end;

function sys_unpointer(args: THiArray): PHiValue; stdcall;
var
  a,b: PHiValue;
  vtype: AnsiString;
  ptr:Pointer;
  i:int64;
  size:integer;
  str: AnsiString;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  a   := args.FindKey(token_a);
  b   := args.FindKey(token_b);

  // (2) データの処理
  ptr  := Pointer(hi_int(a));
  // (3) 戻り値を設定
  if b.VType = varInt then begin
    size:=hi_int(b);
    SetLength(str,size);
    Move(ptr^,PAnsiChar(str)^,size);
    hi_setStr(Result,str)
  end else begin
    vtype:= UpperCaseA(hi_str(b));
    replace_dll_types(vtype);
    if vtype = '' then
      raise HException.Create(hi_str(b)+'は定義されていない型です。');

    case vtype[1] of
      REC_DTYPE_1CHAR:    hi_setInt(Result,pshortint(ptr)^);
      REC_DTYPE_1BYTE:    hi_setInt(Result,pbyte(ptr)^);
      REC_DTYPE_2SHORT:   hi_setInt(Result,psmallint(ptr)^);
      REC_DTYPE_2WORD:    hi_setInt(Result,pword(ptr)^);
      REC_DTYPE_4LONG:    hi_setInt(Result,plongint(ptr)^);
      REC_DTYPE_4DWORD:   hi_setInt(Result,plongword(ptr)^);
      REC_DTYPE_4FLOAT:   hi_setFloat(Result,psingle(ptr)^);
      REC_DTYPE_4POINTER: hi_setInt(Result,Integer(ppointer(ptr)^));
      REC_DTYPE_8INT64:   hi_setIntOrFloat(Result,pint64(ptr)^);
      REC_DTYPE_8REAL:    hi_setFloat(Result,pdouble(ptr)^);
      REC_DTYPE_8QWORD:
      begin
        i:=pint64(ptr)^;
        if i < 0 then
          hi_setIntOrFloat(Result,i - IntPower(-2,63) + IntPower(2,63))
        else
          hi_setIntOrFloat(Result,i);
      end;
      REC_DTYPE__EXT:
      begin
        getToken_s(vtype,'(');
        size := StrToIntDef(string(getToken_s(vtype,')')), 0);
        SetLength(str,size);
        Move(ptr^,PAnsiChar(str)^,size);
        hi_setStr(Result,str)
      end;
      else
        raise HException.Create(hi_str(b)+'は定義されていない型です。');
    end;
  end;

end;

function sys_typeof(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
  s: AnsiString;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  a   := args.FindKey(token_a);

  // (2) データの処理
  s := hi_vtype2str(a);

  // (3) 戻り値を設定
  hi_setStr(Result, s);
end;

function sys_pack(args: THiArray): PHiValue; stdcall;
var
  a, b, s: PHiValue;
  rec: THimaRecord;
  g: THiGroup;
  i: Integer;
  p: PAnsiChar;
begin
  // (1) 引数の取得
  a   := args.FindKey(token_a); // group ->
  b   := args.FindKey(token_b); // str
  s   := args.FindKey(token_s); // types

  if a.VType <> varGroup then raise Exception.Create('引数にはグループを指定してください。');

  // (2) データの処理

  //構造体を生成
  rec := THimaRecord.Create;
  try
    rec.SetDataTypes(hi_str(s)); // タイプのセット
  except on e: Exception do
    raise Exception.Create('PACK規則の設定に失敗。'+e.Message);
  end;
  rec.RecordCreate; // フィールドの生成

  //構造体のメンバにデータをセット
  g := hi_group(a); // a はグループ
  try
    // グループの要素0は名前なので1から
    for i := 0 to rec.Count - 1 do
    begin
      rec.SetValueIndex(i, g.Items[i+1]);
    end;
  except on e: Exception do
    raise Exception.Create('PACKの変数代入に失敗。'+e.Message);
  end;

  //変数bにパック
  hi_var_clear(b);
  b.VType := varStr;
  b.Size  := rec.TotalByte + 1;
  GetMem(b.ptr_s, b.Size);
  rec.CopyDataTo(b.ptr);
  // 最後に詰めの#0を足す
  // 0123456
  // xxxxxx@
  p := b.ptr_s;
  Inc(p, b.Size - 1);
  p^ := #0;
  FreeAndNil(rec);

  // (3) 戻り値を設定
  Result := nil;
end;

function sys_unpack(args: THiArray): PHiValue; stdcall;
var
  a, b, s, v: PHiValue;
  rec: THimaRecord;
  g: THiGroup;
  i, bytes: Integer;
begin
  // (1) 引数の取得
  a   := args.FindKey(token_a); // str ->
  b   := args.FindKey(token_b); // group
  s   := args.FindKey(token_s); // types

  if b.VType <> varGroup then raise Exception.Create('引数にはグループを指定してください。');

  // (2) データの処理
  rec := THimaRecord.Create;
  try
    rec.SetDataTypes(hi_str(s));
  except on e: Exception do
    raise Exception.Create('PACK規則の設定に失敗。'+e.Message);
  end;
  rec.RecordCreate;

  if a.VType <> varStr then hi_setStr(a, hi_str(a)); // 型がでたらめでもエラー防止

  // 構造体のサイズを取得して a にコピー
  bytes := rec.TotalByte; if bytes > a.Size then bytes := a.Size;
  Move(a.ptr^, rec.DataPtr^, bytes);

  g := hi_group(b);
  try
    // グループの要素0は名前なので1から
    for i := 0 to rec.Count - 1 do
    begin
      v := g.Items[i+1]; // グループのメンバを取得
      rec.GetValueIndex(i, v);
    end;
    //msg := g.EnumKeyAndVlues;
    //debugs(msg);

  except on e: Exception do
    raise Exception.Create('PACKの変数代入に失敗。'+e.Message);
  end;
  FreeAndNil(rec);

  // (3) 戻り値を設定
  Result := nil;
end;

function getRegExpOpt: AnsiString;
var
  v: PHiValue;
begin
  v := HiSystem.GetVariableS('正規表現修飾子');
  Result := TrimA(hi_str(v));
end;

function __reMatch(s, pat: AnsiString; var res: AnsiString): Boolean;
var
  v: PHiValue;
  m: TStringList;
  i: Integer;
begin
  res := '';
  v := HiSystem.GetVariableS('抽出文字列');
  hi_setStr(v, '');
  m := TStringList.Create;
  try
    Result := bregMatch(s, pat, getRegExpOpt, m);
    if not Result then
    begin
      Exit; // マッチしなかったら抜ける
    end;
    if m.Count = 0 then Exit;
    res := AnsiString(m.Strings[0]);
    if m.Count > 1 then
    begin
      hi_ary_create(v);
      for i := 1 to  m.Count - 1 do
      begin
        hi_ary_set(v, i - 1, hi_newStr(AnsiString(m.Strings[i])));
      end;
    end;
  finally
    FreeAndNil(m);
  end;
end;


function sys_reMatchBool(args: THiArray): PHiValue; stdcall;
var
  pat, s, res: AnsiString;
  b:Boolean;
begin
  s   := getArgStr(args, 0, True );
  pat := getArgStr(args, 1, False);

  b:=__reMatch(s, pat, res);
  if s = '' then //空文字マッチ対策
    Result := hi_newBool(b)
  else
    Result := hi_newBool(s = res);
end;

function sys_reMatch(args: THiArray): PHiValue; stdcall;
var
  pat, s, res: AnsiString;
begin
  s   := getArgStr(args, 0, True );
  pat := getArgStr(args, 1, False);

  __reMatch(s, pat, res);
  if s = '' then //空文字マッチ対策
    Result := hi_newStr('')
  else
    Result := hi_newStr(res);
end;

function sys_reSplit(args: THiArray): PHiValue; stdcall;
var
  a, b: PHiValue;
  re: TBRegExp;
  pat, s, ret: AnsiString;
  i: Integer;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  a   := args.FindKey(token_a  );
  b   := args.FindKey(token_b  );
  if a = nil then a := HiSystem.Sore;


  // (2) データの処理
  re := TBRegExp.Create;

  // load check
  if re.hDll = 0 then raise Exception.Create('Bregexp.dllがありません。WEBより入手してください。');

  // match
  try
    try
      s   := hi_str(a);
      pat := hi_str(b);

      if Copy(pat,1,1)<>'m' then
      begin
        pat := JReplaceA(pat, '#', '\#');
        pat := 'm#' + pat + '#' + getRegExpOpt;
      end;

      re.Split(pat, s, 100);
      
      // (3) 結果を設定
      if re.Count = 0 then Exit;
      if re.Count = 1 then
      begin
        hi_setStr(Result, ret);
        //Result := hi_newStr(re.Text);
      end else
      if re.Count > 1 then
      begin
        hi_ary_create(Result);
        for i := 0 to re.Count - 1 do
        begin
          hi_ary_set(Result, i, hi_newStr(re.Strings[i]));
        end;
      end;

    except on e:Exception do
      raise Exception.Create(e.Message);
    end;
  finally
    re.Free;
  end;

end;

function sys_reTR(args: THiArray): PHiValue; stdcall;
var
  re: TBRegExp;
  s, a, b, pat: AnsiString;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s := getArgStr(args, 0, True);
  a := getArgStr(args, 1, False);
  b := getArgStr(args, 2, False);

  // (2) データの処理
  re := TBRegExp.Create;
  // レポートに追加
  HiSystem.plugins.addDll(BRegExp.PATH_BREGEXP_DLL);

  // load check
  if re.hDll = 0 then raise Exception.Create('Bregexp.dllがありません。WEBより入手してください。');

  // match
  try
    try
      a := JReplaceA(a, '#', '\#');
      pat := 'tr#' + a + '#' + b + '#' + getRegExpOpt;
      re.Trans(pat, s);

      // (3) 結果を設定
      hi_setStr(Result, s);

    except on e:Exception do
      raise Exception.Create(e.Message);
    end;
  finally
    re.Free;
  end;

end;

function __reSub(s, a, b: AnsiString; IsGlobal: Boolean): AnsiString;
var
  re: TBRegExp;
  pat, ss: AnsiString;
begin
  re := TBRegExp.Create;
  // レポートに追加
  HiSystem.plugins.addDll(BRegExp.PATH_BREGEXP_DLL);

  // load check
  if re.hDll = 0 then raise Exception.Create('Bregexp.dllがありません。WEBより入手してください。');

  try
    //---
    try
      // シーケンスを置換
      // 既にエスケープされていれば確保
      a := JReplaceA(a, '#',   '\#');

      // オプション
      ss := getRegExpOpt;
      ss := JReplaceA(ss, 'g', '');
      if IsGlobal then
      begin
        pat := 's#' + a + '#' + b + '#g' + ss;
      end else
      begin
        pat := 's#' + a + '#' + b + '#' + ss;
      end;

      // 正規表現実行
      re.Subst(pat, s);

      // (3) 結果を設定
      Result := s;

    except
      on e:Exception do
        raise Exception.Create(e.Message);
    end;
    //---
  finally
    re.Free;
  end;

end;

function sys_reSubOne(args: THiArray): PHiValue; stdcall;
var
  s, a, b: AnsiString;
begin
  // (1) 引数の取得
  s := getArgStr(args, 0, True);
  a := getArgStr(args, 1, False);
  b := getArgStr(args, 2, False);

  // (2) 置換
  Result := hi_newStr(__reSub(s, a, b, False));
end;

function sys_reSub(args: THiArray): PHiValue; stdcall;
var
  s, a, b: AnsiString;
begin
  // (1) 引数の取得
  s := getArgStr(args, 0, True);
  a := getArgStr(args, 1, False);
  b := getArgStr(args, 2, False);

  // (2) 置換
  Result := hi_newStr(__reSub(s, a, b, True));
end;


function sys_DeleteGobi(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
  str: AnsiString;
begin

  // (1) 引数の取得
  s := args.Items[0];
  if s = nil then s := HiSystem.Sore;

  // (2) データの処理
  str := hi_str(s);
  str := DeleteGobi(str);

  // (3) 結果
  Result := hi_var_new;
  hi_setStr(Result, str);

end;

function sys_tokenSplit(args: THiArray): PHiValue; stdcall;
var
  s, p: PHiValue;
  str: AnsiString;
  hf: THimaFile; token: THimaToken;
begin

  // (1) 引数の取得
  s := args.Items[0];
  if s = nil then s := HiSystem.Sore;

  // (2) データの処理
  str := hi_str(s);

  Result := hi_var_new;
  hi_ary_create(Result);

  hf := THimaFile.Create(nil, -1);
  try
    hf.SetSource(str);
    token := hf.TopToken;
    while token <> nil do
    begin
      // add
      p := hi_var_new;
      //hi_setStr(p, token.Token + token.Josi);
      if token.TokenType = tokenNumber then
        hi_setStr(p, FloatToStrA(token.NumberToken) + token.Josi)
      else
        hi_setStr(p, token.Token + token.Josi);

      hi_ary(Result).Add(p);
      // next
      if token.NextToken = nil  then token := token.CheckNextBlock
                                else token := token.NextToken;
    end;
  finally
    hf.Free;
  end;

end;



function sys_AllocMem(args: THiArray): PHiValue; stdcall;
var
  s, cnt: PHiValue;
begin

  // (1) 引数の取得
  s   := args.FindKey(token_s  );
  cnt := args.FindKey(token_cnt);
  if s = nil then s := HiSystem.Sore;

  // (2) データの処理
  hi_var_clear(s);

  s.VType := varStr;
  s.Size  := hi_int(cnt) + 1;

  if s.Size > 0 then
  begin
    GetMem(s.ptr, s.Size);
    ZeroMemory(s.ptr, s.Size); // all zero
  end;

  // (3) 戻り値を設定
  Result := nil;
end;

function sys_getBinary(args: THiArray): PHiValue; stdcall;
var
  ps, pi, pf: PHiValue;
  p: PAnsiChar;
  fmt, buf: AnsiString;
  w: WORD; dw: DWORD; i, len: Integer;
  s: Smallint; f: Single; d: Double;
  e: Extended; i64: Int64;
begin
  // (1) 引数の取得 ... SのIをFで
  ps  := hi_getLink( args.Items[0] );
  pi  := hi_getLink( args.Items[1] );
  pf  := hi_getLink( args.Items[2] );

  // (2) データの処理
  if ps.VType <> varStr then hi_setStr(ps, hi_str(ps));

  fmt := UpperCaseA(hi_str(pf));
  replace_dll_types(fmt);

  p   := PAnsiChar(ps.ptr_s);
  if hi_int(pi) >= 1 then Inc(p, hi_int(pi) - 1);

  if fmt = '' then
  begin
      Result := nil;
  end else
  if fmt = 'PCHAR' then
  begin
      // それ以後のバイナリを全部得る
      // 01:23456 --- 2
      len := Length(hi_str(ps)) - hi_int(pi) + 1;
      SetLength(buf, len);
      Move(p^, buf[1], len);
      Result := hi_newStr(buf);
  end else
  begin
    case fmt[1] of
      REC_DTYPE_1CHAR:
        Result := hi_newStr(AnsiChar(p^));
      REC_DTYPE_1BYTE:
        Result := hi_newInt(Ord(p^));
      REC_DTYPE_2WORD:
        begin
          Move(p^, w, sizeof(w));
          Result := hi_newInt(w);
        end;
      REC_DTYPE_2SHORT:
        begin
          Move(p^, s, sizeof(s));
          Result := hi_newInt(s);
        end;
      REC_DTYPE_4POINTER,
      REC_DTYPE_4LONG:
        begin
          Move(p^, i, sizeof(i));
          Result := hi_newInt(i);
        end;
      REC_DTYPE_4DWORD:
        begin
          Move(p^, dw, sizeof(dw));
          Result := hi_var_new;
          hi_setIntOrFloat(Result,dw);
        end;
      REC_DTYPE_4FLOAT:
        begin
          Move(p^, f, sizeof(f));
          Result := hi_var_new;
          hi_setFloat(Result,f);
        end;
      REC_DTYPE_8REAL:
        begin
          Move(p^, d, sizeof(d));
          Result := hi_var_new;
          hi_setFloat(Result,d);
        end;
      REC_DTYPE_8INT64:
        begin
          Move(p^, i64, sizeof(i64));
          Result := hi_var_new;
          hi_setIntOrFloat(Result,i64);
        end;
      REC_DTYPE_8QWORD:
        begin
          Move(p^, i64, sizeof(i64));
          Result := hi_var_new;
          if i64 < 0 then
          begin
            e := i64 and $7FFFFFFFFFFFFFFF;
            hi_setIntOrFloat(Result,e + High(Int64)+1.0)
          end
          else
            hi_setIntOrFloat(Result,i64);
        end;
      else
        Result := nil;
    end;
  end;
end;

function sys_setBinary(args: THiArray): PHiValue; stdcall;
const
  pow2_64:Extended = High(Int64)+1.0-Low(Int64);
var
  pv, ps, pi, pf: PHiValue;
  p, pp: PAnsiChar;
  fmt: AnsiString;
  w: WORD; dw: DWORD; i, len: Integer;
  s: Smallint; f: Single; d: Double;
  e: Extended; i64: Int64;

  function getInt(p: PHiValue): Integer;
  var s: AnsiString;
  begin
    case p.VType of
      varInt:
        begin
          Result := p.int;
        end;
      varFloat:
        begin
          Result := hi_int(p);
        end;
      else
        begin
          s := hi_str(p) + #0;
          Result := Ord(s[1]);
        end;
    end;
  end;

  function getWord(p: PHiValue): WORD;
  var s: AnsiString;
  begin
    case p.VType of
      varInt:
        begin
          Result := p.int;
        end;
      varFloat:
        begin
          Result := hi_int(p);
        end;
      else
        begin
          s := hi_str(p) + #0#0;
          Result := (Ord(s[1]) shl 8)or(Ord(s[2]));
        end;
    end;
  end;

  function getDWord(p: PHiValue): DWORD;
  var s: AnsiString;
  begin
    case p.VType of
      varInt:
        begin
          Result := DWORD(p.int);
        end;
      varFloat:
        begin
          Result := DWORD(hi_int(p));
        end;
      else
        begin
          s := hi_str(p) + #0#0#0#0;
          Result := (Ord(s[1]) shl 24)or(Ord(s[2]) shl 16)or(Ord(s[3]) shl 8)or(Ord(s[4]));
        end;
    end;
  end;

begin
  // (1) 引数の取得 ... SのIをFで
  pv  := hi_getLink( args.Items[0] );
  ps  := hi_getLink( args.Items[1] );
  pi  := hi_getLink( args.Items[2] );
  pf  := hi_getLink( args.Items[3] );

  // (2) データの処理
  if ps.VType <> varStr then hi_setStr(ps, hi_str(ps));
  Result := nil;

  p := PAnsiChar(ps.ptr_s);
  if hi_int(pi) > 1 then Inc(p, hi_int(pi)-1);

  fmt := UpperCaseA(hi_str(pf));
  replace_dll_types(fmt);
  if fmt = '' then
    // 理解できない型の場合は何もしない
  else
  if fmt='PCHAR' then
  begin
    if pv.VType <> varStr then hi_setStr(pv, hi_str(pv));
    len := Length(hi_str(pv));
    pp := pv.ptr_s;
    Move(pp^, p^, len);
  end else
  begin
    case fmt[1]  of
      REC_DTYPE_1CHAR,
      REC_DTYPE_1BYTE:
        p^ := AnsiChar(getInt(pv) and $FF);
      REC_DTYPE_2SHORT:
        begin
          s:=Short(hi_int(pv));
          Move(s, p^, sizeof(s));
        end;
      REC_DTYPE_2WORD:
        begin
          w := getWord(pv) and $FFFF;
          Move(w, p^, sizeof(w));
        end;
      REC_DTYPE_4POINTER,
      REC_DTYPE_4LONG:
        begin
          i := getInt(pv);
          Move(i, p^, 4);
        end;
      REC_DTYPE_4DWORD:
        begin
          dw := getDWord(pv);
          Move(dw, p^, 4);
        end;
      REC_DTYPE_4FLOAT:
        begin
          f:=hi_float(pv);
          Move(f, p^, sizeof(f));
        end;
      REC_DTYPE_8REAL:
        begin
          d:=hi_float(pv);
          Move(d, p^, sizeof(d));
        end;
      REC_DTYPE_8INT64,
      REC_DTYPE_8QWORD:
      begin
        //hima_variable_ex.THimaRecord.SetValueIndexと同じ処理
        e:=hi_float(pv);
        while e >= pow2_64 do e := e - pow2_64;
        while e < -pow2_64 do e := e + pow2_64 + 1;
        if e > High(Int64) then e := Low(Int64)+e-High(Int64)-1;
        if e <  Low(Int64) then e := High(Int64)+e-Low(Int64)+1;
        i64:= Round(e);
        Move(i64, p^, sizeof(i64));
      end;
    end;
  end;

end;



function sys_leftM(args: THiArray): PHiValue;
var
  s, cnt: PHiValue;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s   := args.FindKey(token_s  ); if s = nil then s := HiSystem.Sore;
  cnt := args.FindKey(token_cnt);

  // (2) データの処理
  // (3) 戻り値を設定
  hi_setStr(Result, CopyA(hi_str(s), 1, hi_int(cnt)));
end;

function sys_leftB(args: THiArray): PHiValue;
var
  s, cnt: PHiValue;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s   := args.FindKey(token_s  ); if s = nil then s := HiSystem.Sore;
  cnt := args.FindKey(token_cnt);

  // (2) データの処理
  // (3) 戻り値を設定
  hi_setStr(Result, Copy(hi_str(s), 1, hi_int(cnt)));
end;


function EnumWindowsProc( hwnd:HWND; lParam:LPARAM ):BOOL; stdcall;
var
  p: PHiValue;
  c: AnsiString; len: Integer;
begin
  p := hi_var_new;
  hi_ary_create(p);
  // handle
  hi_ary(p).Add(hi_newInt( hwnd ));

  // class name
  SetLength(c, 512);
  GetClassNameA(hwnd, PAnsiChar(c), 512);
  hi_ary(p).Add(hi_newStr(PAnsiChar(c)));

  // window text
  len := GetWindowTextLength(hwnd);
  SetLength(c, len+1);
  GetWindowTextA(hwnd, PAnsiChar(c), len+1);
  hi_ary(p).Add(hi_newStr(PAnsiChar(c)));

  // 引数として与えられた返り値にセット
  hi_ary(PHiValue(lParam)).Add(p);

  // 次の窓も探す
  Result := True;
end;

function sys_enumwindows(args: THiArray): PHiValue;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  // (2) データの処理
  // (3) 戻り値を設定
  hi_ary_create(Result);
  EnumWindows(@EnumWindowsProc, Integer(Result));

end;

function sys_rightM(args: THiArray): PHiValue;
var
  s, cnt: PHiValue;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s   := args.FindKey(token_s  ); if s = nil then s := HiSystem.Sore;
  cnt := args.FindKey(token_cnt);

  // (2) データの処理
  // (3) 戻り値を設定
  hi_setStr(Result, JRight(hi_str(s), hi_int(cnt)));
end;
function sys_rightB(args: THiArray): PHiValue;
var
  s, cnt: PHiValue;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  s   := args.FindKey(token_s  ); if s = nil then s := HiSystem.Sore;
  cnt := args.FindKey(token_cnt);

  // (2) データの処理
  // (3) 戻り値を設定
  hi_setStr(Result, Right(hi_str(s), hi_int(cnt)));
end;

function sys_eval(args: THiArray): PHiValue;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := args.FindKey(token_s);

  // (2) データの処理
  // (3) 戻り値を設定
  Result := HiSystem.Eval(hi_str(s));
end;

function sys_trim(args: THiArray): PHiValue;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := args.FindKey(token_s);
  if s = nil then s := HiSystem.Sore;

  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, TrimA(hi_str(s)));
end;

function sys_break(args: THiArray): PHiValue;
begin
  //todo 5: BREAK
  Result := nil;
  HiSystem.BreakLevel := HiSystem.CurNode.FindBreakLevel;
  HiSystem.BreakType  := btBreak;
end;

function sys_return(args: THiArray): PHiValue; stdcall;
var
  p: PHiValue;
begin
  //todo 5: RETURN
  p := args.Items[0];
  if p = nil then p := HiSystem.Sore;
  Result := hi_clone(p);
  HiSystem.ReturnLevel := HiSystem.FFuncBreakLevel;
  HiSystem.BreakType  := btBreak;
end;

function sys_goto(args: THiArray): PHiValue; stdcall;
var
  s: AnsiString;
  jumppoint_id:DWORD;
begin
  Result := nil;
  s := getArgStr(args, 0);
  s := DeleteGobi(s);
  jumppoint_id := hi_tango2id(s);
  HiSystem.FJumpPoint := jumppoint_id;
  HiSystem.ReturnLevel := HiSystem.CurNode.FindBreakLevel + 1;
  HiSystem.BreakType := btBreak;
end;

function sys_nil(args: THiArray): PHiValue; stdcall;
begin
  Result := nil;
end;

function sys_echo(args: THiArray): PHiValue; stdcall;
var a: PHiValue;
begin
  a := args.Items[0];
  Result := hi_clone(a);
end;


function sys_continue(args: THiArray): PHiValue;
begin
  Result := nil;
  HiSystem.BreakLevel := HiSystem.CurNode.FindBreakLevel;
  HiSystem.BreakType  := btContinue;
end;

function sys_except(args: THiArray): PHiValue;
var
  s: PHiValue;
  msg: AnsiString;
begin
  // (1) 引数の取得
  s := args.FindKey(token_s);
  if s <> nil then msg := hi_str(s) else msg := 'ユーザーエラー';

  raise HException.Create(msg);
end;

function sys_runtime_error_off(args: THiArray): PHiValue; stdcall;
begin
  Result := nil;
  HiSystem.runtime_error := False;
end;

function sys_end(args: THiArray): PHiValue;
begin
  Result := nil;
  HiSystem.FlagEnd := True;
end;



function sys_debug(args: THiArray): PHiValue; stdcall;
var
  p: PHiValue;
  i: Integer;
  s: AnsiString;
begin
  Result := nil;
  p := HiSystem.Eval('変数列挙');
  s := AnsiString(AppPath) + 'debug.txt';
  FileSaveAll((hi_str(p)), string(s));
  //ShellExecute(mainWindowHandle, 'open', PAnsiChar(s), '', '', SW_SHOW);

  i := MessageBox(MainWindowHandle, 'debug.txtへ変数の一覧を保存しました。'#13#10+
        '実行を継続しますか？', 'デバッグ', MB_ICONQUESTION or MB_YESNO);
  if i = IDNO then
  begin
    Halt;
  end;
end;

function sys_assert(args: THiArray): PHiValue; stdcall;
var
  res: Boolean;
begin
  Result := nil;
  res := hi_bool( PHiValue( args.Items[0] ) );
  if not res then raise Exception.Create('ASSERTによる例外。');
end;

function sys_guguru(args: THiArray): PHiValue; stdcall;
var
  url, key: AnsiString;
begin
  key := getArgStr(args, 0, True);
  key := UTF8Encode(key);
  key := URLEncode(key);
  url := 'http://www.google.co.jp/search?q='+key+'&lr=lang_ja&ie=utf-8&oe=utf-8';
  OpenApp(url);
  Result := nil;
end;

function sys_plugins_enum(args: THiArray): PHiValue; stdcall;
var
  i: Integer;
  s: AnsiString;
  p: THiPlugin;
begin
  s := '';
  for i := 0 to HiSystem.plugins.Count - 1 do
  begin
    p := HiSystem.plugins.Items[i];
    s := s + AnsiString(ExtractFileName(p.FullPath)) + ',';
    if p.Used then s := s + '使用中' else s := s + '';
    s := s + #13#10;
  end;
  Result := hi_newStr(s);
end;

function sys_timeGettime(args: THiArray): PHiValue;
begin
  Result := hi_var_new;
  hi_setInt(Result, timeGetTime);
end;

function sys_EnumVar(args: THiArray): PHiValue;
var
  s: PHiValue;
  str,res: AnsiString;
begin
  Result := hi_var_new;

  s := args.FindKey(token_s);
  if s <> nil then str := hi_str(s)
              else str := 'グローバルローカルユーザー';

  res := '';

  if PosA('グローバル',str) > 0 then
  begin
    if PosA('ユーザー', str) > 0 then begin
      res := res + HiSystem.Namespace.EnumKeysAndValues(True)
    end else begin
      res := res + HiSystem.Namespace.EnumKeysAndValues(False);
    end;
  end;
  if posA('ローカル',str) > 0 then
  begin
    if HiSystem.LocalScope.Count > 0 then
      res := res + HiSystem.Local.EnumKeysAndValues;
  end;

  hi_setStr(Result, res);
end;


function sys_ExistsVar(args: THiArray): PHiValue; stdcall;
var
  s   : PHiValue;
  id  : DWORD;
  v   : PHiValue;
begin
  s  := args.Items[0];
  id := hi_tango2id(DeleteGobi(HimaSourceConverter(-1, hi_str(s))));
  v  :=HiSystem.GetVariable(id);
  if v = nil then
  begin
    Result := hi_newStr(''); // 空
    Exit;
  end;
  Result := hi_newStr(hi_vtype2str(v));
end;

function sys_groupCopyRef(args: THiArray): PHiValue; stdcall;
var
  a, b: PHiValue;
begin
  a := args.FindKey(token_a);
  b := args.FindKey(token_b);

  if a.VType <> varGroup then raise Exception.Create('引数がグループではありません。');
  hi_var_copyGensi(a, b);
  Result := nil;
end;
function sys_copyData(args: THiArray): PHiValue; stdcall;
var
  a, b: PHiValue;
begin
  a := args.Items[0];
  b := args.Items[1];
  //---
  a := hi_getLink(a);
  b := hi_getLink(b);
  hi_var_copyData(a, b);

  Result := nil;
end;

function EasyExecPointer(args: THiArray): PHiValue; stdcall; // by しらたまさん
type
  // 引数のない関数型を宣言（新しいＤＬＬインポート命令）
  //[0]
  TDllfuncVoid = procedure; stdcall;
  //[1]
  TDllfuncChar = function: Shortint; stdcall;
  TDllfuncByte = function: Byte; stdcall;
  //[2]
  TDllfuncShort = function: Smallint; stdcall;
  TDllfuncWord = function: WORD; stdcall;
  //[4]
  TDllfuncLong = function: Longint; stdcall;
  TDllfuncDWord = function: DWORD; stdcall;
  TDllfuncPtr = function: PAnsiChar; stdcall;
  TDllfuncFloat  = function: Single; stdcall;
  //[8]
  TDllfuncInt64  = function: int64; stdcall;
  TDllfuncDouble = function: Double; stdcall;

  TCallKind = (ckStdcall,ckCdecl);
var
  StkP:Pointer;//スタックポインタ
  rect:Pointer;//引数構造体
  ret: AnsiString;//返り値型
  res,size:integer;//返り値整数｜引数構造体のサイズ
  resStr: AnsiString;//返り値文字列
  resPtr:Pointer;//返り値ポインタ
  resF: Extended;
  res64:Int64;
  func:pointer;//関数ポインタ
  ck:TCallKind;
begin
  if StrIComp(PAnsiChar(hi_str(args.Items[0])),'cdecl') = 0 then
    ck := ckCdecl
  else
    ck := ckStdcall;
  func := Pointer(hi_int(args.Items[1]));
  size := hi_int(args.Items[2]);
  rect := PAnsiChar(hi_str(args.Items[3]));
  ret := UpperCaseA(hi_str(args.Items[4]));
  //Result:=nil;
  //MessageBox(0,rect,rect,0);

  // スタックポインタの設定
  try

  asm
    sub ESP, size // まず、引数を積めるように、スタックポインタの位置を変更。
    mov StkP, ESP // そのスタックポインタのアドレスを得る
  end;
  Move(rect^, StkP^, size);

  // 関数のコール

  // 返り値によって呼ぶ関数を使い分ける
  if ret ='' then ret := 'V';
  res := 0; resStr := ''; resF := 0; res64 := 0;
  case ret[1] of
    //0
    'V': TDllfuncVoid (func);
    //1B
    'C': res := TDllfuncChar (func);
    'B': res := TDllfuncByte (func);
    //2B
    'S': res := TDllfuncShort(func);
    'W': res := TDllfuncWord (func);
    //4B
    'L': res := TDllfuncLong (func);
    'D','H': res := TDllfuncDWord(func);
    'P': // ポインタ型
      begin
        if ret = 'PCHAR' then
        begin
          resStr := AnsiString( TDllfuncPtr(func) );
        end else
        begin
          resPtr := TDllfuncPtr(func);
          res := Integer(resPtr);
        end;
      end;
    else
      raise Exception.Create('DLL関数の戻り値が未定義なので呼び出しませんでした。');
  end;
  if ck = ckCdecl then
  begin
    asm
      add ESP,size //cdeclの時は、スタックポインタを元に戻す
    end;
  end;

  // 関数の結果を代入
  if not (ret[1] = 'V') then begin
    Result := hi_var_new;
    if ret = 'PCHAR' then hi_setStr(Result, resStr)
                                   else
    begin
      case ret[1] of
        'F','R': hi_setFloat(Result,resF);
        'I':     hi_setIntOrFloat(Result,res64);//出来るだけ整数で
        'Q':
        begin
                 if res64 < 0 then hi_setIntOrFloat(Result,Power(2,64)+res64)
                 else hi_setIntOrFloat(Result,res64);
        end;
        else     hi_setInt(Result, res);
      end;
    end;
  end else
    Result := nil;//VOIDの時は値を返さない


  except on e: Exception do
   raise Exception.Create(e.Message);
  end;
end;

function sys_groupCopyVal(args: THiArray): PHiValue; stdcall;
var
  a, b: PHiValue;
begin
//  AddFunc  ('グループコピー','{グループ}Aを{グループ}Bに|AのBへ', 174, ,   'グループAのメンバ全部をグループBにコピーする。Ｂのメンバは初期化されるので注意。','ぐるーぷこぴー');
  a := args.FindKey(token_a);
  b := args.FindKey(token_b);

  if a.VType <> varGroup then raise Exception.Create('引数がグループではありません。');

  hi_var_clear(b);
  hi_group_create(b);
  hi_group(b).Assign(hi_group(a));

  Result := nil;
end;
function sys_groupAddMember(args: THiArray): PHiValue; stdcall;
var
  a, b: PHiValue;
begin
  a := args.FindKey(token_a);
  b := args.FindKey(token_b);

  if a.VType <> varGroup then raise Exception.Create('引数がグループではありません。');

  hi_group_create(b);
  hi_group(b).AddMembers(hi_group(a));

  Result := nil;
end;
function sys_alias(args: THiArray): PHiValue; stdcall;
var
  a, b: PHiValue;
begin
  a := args.FindKey(token_a);
  b := args.FindKey(token_b);

  hi_setLink(b, a);

  Result := nil;
end;


function sys_group_ornot(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := args.FindKey(token_a);
  if a.VType = varGroup then
  begin
    Result := hi_newStr(hi_id2tango(hi_group(a).InstanceVar.VarID));
  end else
  begin
    Result := hi_var_new;
  end;
end;


function sys_groupCreate(args: THiArray): PHiValue; stdcall;
var
  pa, pb, pName, pp: PHiValue;
  idName: DWORD;
begin
  Result := nil;
  pa := args.Items[0]; pa := hi_getLink(pa);
  pb := args.Items[1]; pb := hi_getLink(pb);

  if pb.VType <> varGroup then
  begin
    // グループでなければただのコピー。
    hi_var_copyData(pb, pa);
    Exit;
  end;

  // pa が文字列で指定された場合（未登録の文字列の場合だけ）
  if (pa.VarID = 0) then
  begin
    if (pa.VType = varStr)and(pa.Registered = 0) then
    begin
      idName := hi_tango2id(DeleteGobi(hi_str(pa)));
      pp := HiSystem.Global.GetVar(idName);
      if pp <> nil then raise HException.Create(hi_id2tango(idName)+'は既に存在するので生成できません。');
      pa := HiSystem.CreateHiValue(idName);
    end else
    begin
      // 適当な識別名をつける
      idName := hi_tango2id('_AUTO' + IntToStrA(HiSystem.TangoList.Count));
      pp := hi_var_new;
      //IDを設定
      pp.VarID := idName;
      //対象の変数にリンクを作成
      hi_setLink(pa,pp);
      //変数を登録(ローカル変数ならローカル、グローバルならグローバルに登録)
      if HiSystem.Local.GetVar(pa.VarID) = nil then
        HiSystem.Global.RegistVar(pp)
      else
        HiSystem.Local.RegistVar(pp);
      Inc(pp.RefCount);//スコープから参照されているので
      //後ろのコードで操作しやすいようにポインタを再設定
      pa:=pp;
    end;
  end else
  begin
    // paがID持ちだけど登録の無しの可能性(例：グループメンバ)
    if HiSystem.Local.GetVar(pa.VarID) = nil then //MessageBox(0,'local','',0);
      if HiSystem.Global.GetVar(pa.VarID) = nil then //MessageBox(0,'global','',0);
        HiSystem.Global.RegistVar(pa);
    Inc(pa.RefCount);//スコープから参照されているので
  end;

  // グループを生成
  hi_group_create(pa);
  hi_group(pa).Assign(hi_group(pb));
  hi_group(pa).HiClassDebug := hi_id2tango(pa.VarID);
  // グループ名をセット（重要）
  pName := hi_group(pa).FindMember(hi_tango2id('名前'));
  hi_setStr(pName, hi_id2tango(pa.VarID));

  pp := HiSystem.RunGroupEvent(pa, hi_tango2id('作'));
  if (pp <> nil)and(pp.Registered = 0) then hi_var_free(pp);
end;

function sys_EnumMember(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
  res: AnsiString;
begin
  Result := hi_var_new;

  s := args.FindKey(token_s);
  if s.VType = varGroup then
  begin
    res := hi_group(s).EnumKeys;
  end else
  begin
    res := '';
  end;

  hi_setStr(Result, res);
end;

function sys_EnumMemberEx(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
  res: AnsiString;
begin
  Result := hi_var_new;

  s := args.FindKey(token_s);
  if s.VType = varGroup then
  begin
    res := hi_group(s).EnumKeyAndVlues;
  end else
  begin
    res := '(グループではない)';
  end;

  hi_setStr(Result, res);
end;

function sys_runspeed(args: THiArray): PHiValue; stdcall;
var s: PHiValue;
begin
  s := args.Items[0];
  HiSystem.Speed := hi_int(s);
  Result := nil;
end;

function sys_ref_syntax(args: THiArray): PHiValue; stdcall;
begin
  Result := hi_newStr(HiSystem.DebugProgramNadesiko);
end;

function sys_copydata_send(args: THiArray): PHiValue; stdcall;
var a,s: PHiValue;
begin
  a := args.Items[0];
  s := args.Items[1];
  SendCOPYDATA(hi_int(a), hi_str(s), 0, MainWindowHandle);
  Result := nil;
end;

function sys_copydata_sendex(args: THiArray): PHiValue; stdcall;
var a,s,id: PHiValue;
begin
  a := args.Items[0];
  s := args.Items[1];
  id := args.Items[2];
  SendCOPYDATA(hi_int(a), hi_str(s), hi_int(id), MainWindowHandle);
  Result := nil;
end;


function sys_binView(args: THiArray): PHiValue;
var
  s: PHiValue;
  str, res: AnsiString;
  i: Integer;
  p: PAnsiChar;
begin
  Result := hi_var_new;

  s := args.FindKey(token_s);
  if s = nil then s := HiSystem.Sore;

  res := '';

  if s.VType = varStr then
  begin
    p := s.ptr_s;
    for i := 0 to s.Size-2{最後の00は非表示にする} do
    begin
      if ( (i mod 16) = 0 ) then res := res + #13#10 else res := res + ',';
      res := res + AnsiString(IntToHex(Ord(p^), 2));
      Inc(p);
    end;
  end else
  begin
    str := hi_str(s);
    for i := 1 to Length(str) do
    begin
      if ( ((i-1) mod 16) = 0 ) then res := res + #13#10 else res := res + ',';
      res := res + AnsiString(IntToHex(Ord(str[i]), 2));
    end;
  end;

  hi_setStr(Result, TrimA(res));
end;

function sys_getSore(args: THiArray): PHiValue; stdcall;
begin
  Result := hi_var_new;
  hi_setLink(Result, HiSystem.Sore);
end;


function sys_say(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
  str, cap: AnsiString;
  h: THandle;
begin
  Result := nil;
  s := args.Items[0];
  if s=nil then s := HiSystem.Sore;
  str := hi_str(s); if Length(str) > 2024 then str := Copy(str, 1, 1024)+'...';
  h := MainWindowHandle;
  if h = 0 then
  begin
    h := GetForegroundWindow;
  end;
  cap := GetMainWindowCaption;
  MessageBoxA(h, PAnsiChar(str), PAnsiChar(cap), MB_OK);
end;

function sys_yesno(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
  cap, str: AnsiString;
  ret: Integer;
begin
  // (1) 引数の取得
  s := args.FindKey(token_s);
  if s = nil then s := HiSystem.Sore;

  // (2) 処理
  str := hi_str(s);
  cap := GetMainWindowCaption;
  ret := MessageBoxA(MainWindowHandle, PAnsiChar(str), PAnsiChar(cap), MB_YESNO);

  // (3) 結果の代入
  Result := hi_var_new;
  hi_setBool(Result, (ret = IDYES));
end;

function sys_yesnocancel(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
  cap, str: AnsiString;
  ret, res: Integer;
begin
  // (1) 引数の取得
  s := args.FindKey(token_s);
  if s = nil then s := HiSystem.Sore;

  // (2) 処理
  str := hi_str(s);
  cap := GetMainWindowCaption;
  ret := MessageBoxA(MainWindowHandle, PAnsiChar(str), PAnsiChar(cap), MB_YESNOCANCEL or MB_ICONQUESTION);
  case ret of
  IDYES:    res := 1;
  IDNO:     res := 0;
  IDCANCEL: res := 2;
  else      res := 2;
  end;

  // (3) 結果の代入
  Result := hi_var_new;
  hi_setInt(Result, res);
end;

function sys_msg_list(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
  t: AnsiString;
  init, cancel, ime, title: AnsiString;
begin
  // (1) 引数の取得
  s := args.FindKey(token_s);
  if s = nil then t := '' else t := hi_str(s);

  // (2) 処理
  GetDialogSetting(init, cancel, ime, title);
  showListDialog(MainWindowHandle, t, init, cancel, title, ImeStr2ImeMode(ime));

  // (3) 結果の代入
  Result := hi_var_new;
  if IsDialogConvNum then
  begin
    if IsNumber(t) then
      hi_setIntOrFloat(Result, StrToFloatA(t))
    else
      hi_setStr(Result, t);
  end else
  begin
    hi_setStr(Result, t);
  end;
end;

function sys_version_dialog(args: THiArray): PHiValue; stdcall;
var
  title, memo: AnsiString;
  h: THandle;
begin
  title := getArgStr(args, 0, True);
  memo  := getArgStr(args, 1);
  h := MainWindowHandle;
  ShellAboutA(h, PAnsiChar(title), PAnsiChar(memo), 0);
  Result := nil;
end;

function sys_msg_memo(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
  t: AnsiString;
  init, cancel, ime, title: AnsiString;
begin
  // (1) 引数の取得
  s := args.FindKey(token_s);
  if s = nil then s := nako_getSore;
  t := hi_str(s);

  // (2) 処理
  GetDialogSetting(init, cancel, ime, title);
  showMemoDialog(MainWindowHandle, t, init, cancel, title, ImeStr2ImeMode(ime));

  // (3) 結果の代入
  Result := hi_var_new;
  hi_setStr(Result, t);
end;

procedure GetDialogSetting(var init: AnsiString; var cancel: AnsiString; var ime: AnsiString;
  var title: AnsiString);
begin
  init    := hi_str(HiSystem.GetVariableS('ダイアログ初期値'));
  cancel  := hi_str(HiSystem.GetVariableS('ダイアログキャンセル値'));
  ime     := hi_str(HiSystem.GetVariableS('ダイアログIME'));
  title   := hi_str(HiSystem.GetVariableS('ダイアログタイトル'));
  if title = '' then GetMainWindowCaption;
end;

function sys_input(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
  str, init, cancel, title, ime: AnsiString;
  ret: AnsiString;
begin
  // (1) 引数の取得
  s := args.FindKey(token_s);

  // (2) 処理
  str := hi_str(s);
  DialogParentHandle := MainWindowHandle;
  if DialogParentHandle = 0 then
  begin
    DialogParentHandle := GetForegroundWindow;
  end;

  GetDialogSetting(init, cancel, ime, title);
  //
  ret := MsgInput(str, title,
    init, cancel, ImeStr2ImeMode(ime));

  // (3) 結果の代入
  Result := hi_var_new;
  if IsDialogConvNum then
  begin
    if IsNumber(ret) then
    begin
      hi_setIntOrFloat(Result, HimaStrToNum(ret));
    end else
    begin
      hi_setStr(Result, ret);
    end;
  end else
  begin
    hi_setStr(Result, ret);
  end;
end;

function sys_wav(args: THiArray): PHiValue; stdcall;
var
  fname: AnsiString;
begin
  // (1) 引数の取得
  fname := getArgStr(args, 0, True);

  // (2) 処理
  getEmbedFile(fname);
  sndPlaySoundA(PAnsiChar(fname), SND_ASYNC);

  // (3) 結果の代入
  Result := nil;
end;


function nako_mciSend(cmd: AnsiString): AnsiString;
begin
  SetLength(Result, 4096);
  if mciSendStringA(PAnsiChar(cmd), PAnsiChar(Result), Length(Result), 0) <> 0 then
  begin
    raise HException.Create(
      'MCIコマンドエラー。' +
      AnsiString(PAnsiChar(Result)) +
      '(' + cmd + ')');
  end else
  begin
    Result := AnsiString(PAnsiChar(Result));
  end;
end;

function sys_musRec(args: THiArray): PHiValue; stdcall;
var
  cmd, ret: AnsiString;
  fname: AnsiString;
  sec: Integer;
begin
  // (1) 引数の取得
  fname := getArgStr(args, 0, True);
  sec   := getArgInt(args, 1);

  // (2) 処理
  // まずはとりあえず閉じる
  try
    nako_mciSend('close nakoRec');
  except end;

  // 開く
  cmd := 'open new alias nakoRec type waveaudio';
  ret := nako_mciSend(cmd);

  // 録音
  nako_mciSend('record nakoRec');
  Sleep(sec * 1000);
  nako_mciSend('stop nakoRec');

  cmd := 'save nakoRec "'+fname+'"';
  ret := nako_mciSend(cmd);

  // 閉じる
  nako_mciSend('close nakoRec');

  // (3) 結果の代入
  Result := nil;
end;

function sys_musPlay(args: THiArray): PHiValue; stdcall;
var
  cmd, ret: AnsiString;
  fname: AnsiString;
begin
  // (1) 引数の取得
  fname := getArgStr(args, 0, True);

  // (2) 処理

  // まずはとりあえず閉じる
  try
    nako_mciSend('close nakoPlay');
  except end;

  // 開く
  getEmbedFile(fname);

  cmd := 'open "' + fname + '" alias nakoPlay';
  ret := nako_mciSend(cmd);

  // 再生
  cmd := 'play nakoPlay';
  ret := nako_mciSend(cmd);

  // (3) 結果の代入
  Result := nil;
end;

function sys_musStop(args: THiArray): PHiValue; stdcall;
begin
  // (1) 引数の取得

  // (2) 処理

  // まずはとりあえず閉じる
  try
    nako_mciSend('stop nakoPlay');
  except end;
  try
    nako_mciSend('close nakoPlay');
  except end;

  // (3) 結果の代入
  Result := nil;
end;

function sys_mciCommand(args: THiArray): PHiValue; stdcall;
var
  pa: PHiValue;
  cmd, ret: AnsiString;
begin
  // (1) 引数の取得
  pa := args.Items[0];

  // (2) 処理
  cmd := hi_str(pa);
  ret := nako_mciSend(cmd);

  // (3) 結果の代入
  Result := hi_newStr(ret);
end;

function sys_mciOpen(args: THiArray): PHiValue; stdcall;
var
  pfile, pa: PHiValue;
  fname, cmd, ret: AnsiString;
begin
  // (1) 引数の取得
  pfile := args.Items[0];
  pa    := args.Items[1];

  // (2) 処理
  fname := hi_str(pfile);
  getEmbedFile(fname);
  cmd := 'open "' + fname + '" alias ' + hi_str(pa);
  ret := nako_mciSend(cmd);

  // (3) 結果の代入
  Result := hi_newStr(ret);
end;

function sys_mciPlay(args: THiArray): PHiValue; stdcall;
var
  pa: PHiValue;
  cmd, ret: AnsiString;
begin
  // (1) 引数の取得
  pa    := args.Items[0];

  // (2) 処理
  cmd := 'play ' + hi_str(pa);
  ret := nako_mciSend(cmd);

  // (3) 結果の代入
  Result := hi_newStr(ret);
end;

function sys_mciStop(args: THiArray): PHiValue; stdcall;
var
  pa: PHiValue;
  cmd, ret: AnsiString;
begin
  // (1) 引数の取得
  pa    := args.Items[0];

  // (2) 処理
  cmd := 'stop ' + hi_str(pa);
  ret := nako_mciSend(cmd);

  // (3) 結果の代入
  Result := hi_newStr(ret);
end;

function sys_mciClose(args: THiArray): PHiValue; stdcall;
var
  pa: PHiValue;
  cmd, ret: AnsiString;
begin
  // (1) 引数の取得
  pa    := args.Items[0];

  // (2) 処理
  cmd := 'close ' + hi_str(pa);
  ret := nako_mciSend(cmd);

  // (3) 結果の代入
  Result := hi_newStr(ret);
end;

function sys_beep(args: THiArray): PHiValue; stdcall;
begin
  Beep;
  Result := nil;
end;

function sys_selDir(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
  str: AnsiString;
  ret: AnsiString;
  init, cancel, ime, title: AnsiString;
begin
  // (1) 引数の取得
  s := args.FindKey(token_s);
  if s = nil then s := HiSystem.Sore;

  // (2) 処理
  str := hi_str(s);
  //ret := ShowD(MainWindowHandle, str);
  GetDialogSetting(init, cancel, ime, title);
  if OpenFolderDialog(str, title) then
  begin
    ret := AnsiString(IncludeTrailingPathDelimiter(string(str)));
  end else
  begin
    ret := '';
  end;

  // (3) 結果の代入
  Result := hi_newStr(ret);
end;

function sys_selFile(args: THiArray): PHiValue; stdcall;
var
  s,a: PHiValue;
  str: AnsiString;
  ret: AnsiString;
  h: THandle;
begin
  // (1) 引数の取得
  s := args.Items[0];
  if s = nil then s := HiSystem.Sore;
  a := args.Items[1];

  // (2) 処理
  str := hi_str(s);
  //h   := hima_function.MainWindowHandle;
  //if h = 0 then h := GetForegroundWindow;
  h := GetForegroundWindow; // FMプラグインで実行されないので

  if a = nil then
    ret := ShowOpenDialog(h, str,
      AnsiString(CheckPathYen(GetCurrentDir)))
  else
    ret := ShowOpenDialog(h, str,
      AnsiString(CheckPathYen(GetCurrentDir)),
      hi_str(a));

  // (3) 結果の代入
  Result := hi_var_new;
  hi_setStr(Result, ret);
end;

function sys_selFileAsSave(args: THiArray): PHiValue; stdcall;
var
  s,a: PHiValue;
  str: AnsiString;
  ret: AnsiString;
  h: THandle;
begin
  // (1) 引数の取得
  s := args.Items[0];
  if s = nil then s := HiSystem.Sore;
  a := args.Items[1];

  // (2) 処理
  str := hi_str(s);

  //h   := hima_function.MainWindowHandle;
  //if h = 0 then h := GetForegroundWindow;
  h := GetForegroundWindow; // FMプラグインで実行されないので

  if a = nil then
    ret := ShowSaveDialog(h, str, AnsiString(CheckPathYen(GetCurrentDir)))
  else
    ret := ShowSaveDialog(h, str, AnsiString(CheckPathYen(GetCurrentDir)),hi_str(a));

  // (3) 結果の代入
  Result := hi_var_new;
  hi_setStr(Result, ret);
end;

{ // コンソールプログラムで追加すべき命令
function sys_print(args: THiArray): PHiValue;
var
  s: PHiValue;
  str: AnsiString;
begin
  Result := nil;
  s := args.FindKey(token_s);
  if s=nil then s := HiSystem.Sore;
  str := hi_str(s);
  writeln(str);
end;
}

function sys_calc_add(args: THiArray): PHiValue;
var
  a, b, c: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a);
  b := args.FindKey(token_b);
  if a=nil then a := HiSystem.Sore;

  // (2) データの処理
  if b.VType = varStr then c := hi_var_calc_plus_str(a, b)
                      else c := hi_var_calc_plus(a, b);

  //hi_var_copyData(c, a);

  // (3) 戻り値を設定
  Result := c;
end;

function sys_calc_add_b(args: THiArray): PHiValue; stdcall;
var
  a, b, c: PHiValue;
begin
  // (1) 引数の取得
  a := args.Items[0];
  b := args.Items[1];

  // (2) データの処理
  a := hi_getLink(a);
  if b.VType = varStr then c := hi_var_calc_plus_str(a, b)
                      else c := hi_var_calc_plus(a, b);

  hi_var_copyData(c, a);

  // (3) 戻り値を設定
  Result := c;
end;

function sys_calc_sub_b(args: THiArray): PHiValue; stdcall;
var
  a, b, c: PHiValue;
begin
  // (1) 引数の取得
  a := args.Items[0];
  b := args.Items[1];

  // (2) データの処理
  a := hi_getLink(a);
  c := hi_var_calc_minus(a, b);

  hi_var_copyData(c, a);

  // (3) 戻り値を設定
  Result := c;
end;

function sys_calc_mul_b(args: THiArray): PHiValue; stdcall;
var
  a, b, c: PHiValue;
begin
  // (1) 引数の取得
  a := args.Items[0];
  b := args.Items[1];

  // (2) データの処理
  a := hi_getLink(a);
  c := hi_var_calc_mul(a, b);

  hi_var_copyData(c, a);

  // (3) 戻り値を設定
  Result := c;
end;

function sys_calc_div_b(args: THiArray): PHiValue; stdcall;
var
  a, b, c: PHiValue;
begin
  // (1) 引数の取得
  a := args.Items[0];
  b := args.Items[1];

  // (2) データの処理
  a := hi_getLink(a);
  c := hi_var_calc_div(a, b);

  hi_var_copyData(c, a);

  // (3) 戻り値を設定
  Result := c;
end;

function sys_calc_add2(args: THiArray): PHiValue; stdcall;
var
  a, b, c: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a);
  b := args.FindKey(token_b);
  if a=nil then a := HiSystem.Sore;

  // (2) データの処理
  // (3) 戻り値を設定
  c := hi_var_calc_plus(a, b);

  Result := hi_var_new;
  hi_var_copyGensi(c, Result);
end;

function sys_calc_sub(args: THiArray): PHiValue;
var
  a, b, c: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a);
  b := args.FindKey(token_b);
  if a=nil then a := HiSystem.Sore;

  // (2) データの処理
  c := hi_var_calc_minus(a, b);

  //hi_var_copyData(c, a);

  // (3) 戻り値を設定
  Result := c;
end;
function sys_calc_mul(args: THiArray): PHiValue;
var
  a, b, c: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a);
  b := args.FindKey(token_b);
  if a=nil then a := HiSystem.Sore;

  // (2) データの処理
  c := hi_var_calc_mul(a, b);

  //hi_var_copyData(c, a);

  // (3) 戻り値を設定
  Result := c;
end;
function sys_calc_div(args: THiArray): PHiValue;
var
  a, b, c: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a);
  b := args.FindKey(token_b);
  if a=nil then a := HiSystem.Sore;

  // (2) データの処理
  c := hi_var_calc_div(a, b);

  //hi_var_copyData(c, a);

  // (3) 戻り値を設定
  Result := c;
end;
function sys_calc_mod(args: THiArray): PHiValue;
var
  a, b, c: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a);
  b := args.FindKey(token_b);
  if a=nil then a := HiSystem.Sore;

  // (2) データの処理
  c := hi_var_calc_mod(a, b);

  //hi_var_copyData(c, a);

  // (3) 戻り値を設定
  Result := c;
end;

function sys_calc_baisu(args: THiArray): PHiValue;
var
  a, b: Integer;
begin
  a := getArgInt(args, 0, True);
  b := getArgInt(args, 1);
  Result := hi_newBool((a Mod b) = 0);
end;

function sys_calc_pow(args: THiArray): PHiValue;
var
  a, b, c: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a);
  b := args.FindKey(token_b);
  if a=nil then a := HiSystem.Sore;

  // (2) データの処理
  c := hi_var_calc_Power(a, b);

  //hi_var_copyData(c, a);

  // (3) 戻り値を設定
  Result := c;
end;

function sys_calc_let(args: THiArray): PHiValue;
var
  a, b: PHiValue;
begin
  Result := hi_var_new;

  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  b := args.FindKey(token_b); // 変数

  if a = nil then a := HiSystem.Sore;
  if b = nil then b := HiSystem.Sore;

  // (2) 値の設定
  // A(値)を B(変数)へ 代入する
  hi_var_copyData(a, b);      // Src=値(a) Des=変数(b)
  hi_var_copyData(b, Result); // 変数を返す

  // 以下はセッターを考慮した場合だが、ここまでセッター変数がくることはまずありえない
  {begin
    // セッターを実行
    if a.Setter.VType <> varFunc then raise Exception.Create('代入する変数が不正なセッターで実行できません。');
    n := TSyntaxLet.Create(nil);
    // 値
    n.Children.Next := TSyntaxConst.Create(n);
    hi_var_copyGensi( a, TSyntaxConst(n.Children.Next).NodeResult );
    // 変数
    n.VarNode := TSyntaxValue.Create(n);
    n.VarNode.Element.LinkType := svLinkGlobal;
    n.VarNode.Element.VarLink  := b;
    // 結果
    hi_var_copyData(n.getValue, Result);
    n.Free;
  end;}

end;


function sys_comp_GtEq(args: THiArray): PHiValue;
var
  a, b: PHiValue; i: Integer;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  b := args.FindKey(token_b); // 値
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  if hi_float(a) >= hi_float(b) then i := 1 else i := 0;
  hi_setInt(Result, i);
end;

function sys_comp_Gt(args: THiArray): PHiValue;
var
  a, b: PHiValue; i: Integer;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  b := args.FindKey(token_b); // 値
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  if hi_float(a) > hi_float(b) then i := 1 else i := 0;
  hi_setInt(Result, i);
end;

function sys_comp_LtEq(args: THiArray): PHiValue;
var
  a, b: PHiValue; i: Integer;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  b := args.FindKey(token_b); // 値
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  if hi_float(a) <= hi_float(b) then i := 1 else i := 0;
  hi_setInt(Result, i);
end;

function sys_comp_Lt(args: THiArray): PHiValue;
var
  a, b: PHiValue; i: Integer;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  b := args.FindKey(token_b); // 値
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  if hi_float(a) < hi_float(b) then i := 1 else i := 0;
  hi_setInt(Result, i);
end;

function sys_comp_Eq(args: THiArray): PHiValue;
var
  a, b: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  b := args.FindKey(token_b); // 値
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_calc_Eq(a, b);
end;

function sys_comp_not(args: THiArray): PHiValue; stdcall;
var
  a, b: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  b := args.FindKey(token_b); // 値
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_calc_NotEq(a, b);
end;

function sys_int(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setIntOrFloat(Result, Int(hi_float(a)));
end;

function sys_round(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setIntOrFloat(Result, Round(hi_float(a)));
end;

function sys_sisyagonyu(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setIntOrFloat(Result, Trunc(0.5 + hi_float(a)));
end;

function sys_ceil(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setIntOrFloat(Result, Math.Ceil(hi_float(a)));
end;

function sys_floor(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setIntOrFloat(Result, Math.Floor(hi_float(a)));
end;

function ROUNDX(SUTI: Extended; KETA: Integer): Extended;
begin
  if SUTI < 0 then
  begin
    Result := -Int(-SUTI * Power(10, KETA) + 0.5) / Power(10, KETA);
  end else
  begin
    Result := Int(SUTI * Power(10,KETA) + 0.5) / Power(10, KETA);
  end;
end;

function FLOORX(SUTI: Extended; KETA: Integer): Extended;
begin
  if SUTI < 0 then
  begin
    Result := -Int(-SUTI * Power(10, KETA)) / Power(10, KETA);
  end else
  begin
    Result := Int(SUTI * Power(10,KETA)) / Power(10, KETA);
  end;
end;

function CEILX(SUTI: Extended; KETA: Integer): Extended;
begin
  if SUTI < 0 then
  begin
    Result := -Int(-SUTI * Power(10, KETA) + 0.9) / Power(10, KETA);
  end else
  begin
    Result := Int(SUTI * Power(10,KETA) + 0.9) / Power(10, KETA);
  end;
end;

function sys_sisyagonyu2(args: THiArray): PHiValue; stdcall;
var
  a,b: PHiValue;
begin
  // (1) 引数の取得
  a := args.Items[0];
  b := args.Items[1];
  if a = nil then a := HiSystem.Sore;

  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setIntOrFloat(Result, ROUNDX(hi_float(a), hi_int(b)));
end;

function sys_ceil2(args: THiArray): PHiValue; stdcall;
var
  a,b: PHiValue;
begin
  // (1) 引数の取得
  a := args.Items[0];
  b := args.Items[1];
  if a = nil then a := HiSystem.Sore;

  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setIntOrFloat(Result, CEILX(hi_float(a), hi_int(b)));
end;

function sys_floor2(args: THiArray): PHiValue; stdcall;
var
  a,b: PHiValue;
begin
  // (1) 引数の取得
  a := args.Items[0];
  b := args.Items[1];
  if a = nil then a := HiSystem.Sore;

  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setIntOrFloat(Result, FLOORX(hi_float(a), hi_int(b)));
end;

function sys_logn(args: THiArray): PHiValue; stdcall;
var
  a,b: PHiValue;
  fa,fb: Extended;
begin
  // (1) 引数の取得
  a := args.Items[0];
  b := args.Items[1];
  if a = nil then a := HiSystem.Sore;

  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  fa := hi_float(a);
  if (fa <= 0.0) or (fa = 1.0) then
    raise Exception.Create('対数の底は1でない正の数でなければなりません。');
  fb := hi_float(b);
  if fb <= 0.0 then
    raise Exception.Create('対数の真数が正の数ではありません。')
  else
    hi_setIntOrFloat(Result, Math.LogN(fa, fb));
end;

function sys_log2(args: THiArray): PHiValue;
var
  a: PHiValue;
  f: Extended;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  f := hi_float(a);
  if f <= 0.0 then
    raise Exception.Create('対数の真数が正の数ではありません。')
  else
    hi_setIntOrFloat(Result, Math.Log2(hi_float(a)));
end;

function sys_RAD2DEG(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setIntOrFloat(Result, Math.RadToDeg(hi_float(a)));
end;
function sys_DEG2RAD(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setIntOrFloat(Result, Math.DegToRad(hi_float(a)));
end;

function sys_log10(args: THiArray): PHiValue;
var
  a: PHiValue;
  f: Extended;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  f := hi_float(a);
  if f <= 0.0 then
    raise Exception.Create('常用対数の真数が正の数ではありません。')
  else
    hi_setIntOrFloat(Result, Math.Log10(hi_float(a)));
end;

function sys_abs(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setIntOrFloat(Result, abs(hi_float(a)));
end;

function sys_sign(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setInt(Result, Sign(hi_float(a)));
end;

function sys_hypot(args: THiArray): PHiValue;
var
  a, b: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  b := args.FindKey(token_b); // 値
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setIntOrFloat(Result, Hypot(hi_float(a),hi_float(b)));
end;

function sys_chr(args: THiArray): PHiValue;
var
  a: PHiValue;
  s: AnsiString;
  i: Integer;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;

  // (2) データの処理 / (3) 戻り値を設定
  s := '';
  i := hi_int(a);
  while (i > $FF) do
  begin
    s := ANsiString(Chr($FF and i)) + s;
    i := i shr 8;
  end;
  s := AnsiString(Chr($FF and i)) + s;
  //
  Result := hi_newStr(s);
end;

function sys_asc(args: THiArray): PHiValue;
var
  a: PHiValue;
  str: AnsiString;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  str := hi_str(a) + #0;
  if (str[1] in LeadBytes) and (Length(str) > 2) then
  begin
    hi_setInt(Result, ord(str[1]) shl 8 + ord(str[2]));
  end else
  begin
    hi_setInt(Result, ord(str[1]));
  end;
end;

function sys_exp(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  //if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setFloat(Result, exp(hi_float(a)));
end;
function sys_ln(args: THiArray): PHiValue;
var
  a: PHiValue;
  f: Extended;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  f := hi_float(a);
  if f <= 0.0 then
    raise Exception.Create('自然対数の真数が正の数ではありません。')
  else
    hi_setFloat(Result, ln(f));
end;

function sys_sqrt(args: THiArray): PHiValue;
var
  a: PHiValue;
  f: Extended;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  f := hi_float(a);
  if f < 0.0 then
    raise Exception.Create('平方根に負の数は与えられません。')
  else
    hi_setFloat(Result, sqrt(f));
end;

function sys_hex(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, AnsiString(IntToHex(hi_int(a), 2)));
end;

function sys_rgb(args: THiArray): PHiValue; stdcall;
var
  r ,g, b: PHiValue;
  cr,cg,cb,c: Integer;
begin
  r := args.Items[0];
  g := args.Items[1];
  b := args.Items[2];

  cr := hi_int(r) and $FF;
  cg := hi_int(g) and $FF;
  cb := hi_int(b) and $FF;

  c := cb + (cg shl 8) + (cr shl 16);

  Result := hi_newInt(c);
end;
function sys_wrgb2rgb(args: THiArray): PHiValue; stdcall;
var
  rgb: PHiValue;
  cr,cg,cb,c: Integer;
begin
  rgb := args.Items[0];
  c  := hi_int(rgb);

  cb := (c shr 16)and $FF;
  cg := (c shr  8)and $FF;
  cr := c         and $FF;

  c := cb + (cg shl 8) + (cr shl 16);

  Result := hi_newInt(c);
end;
function sys_wrgb(args: THiArray): PHiValue; stdcall;
var
  r ,g, b: PHiValue;
  cr,cg,cb,c: Integer;
begin
  r := args.Items[0];
  g := args.Items[1];
  b := args.Items[2];

  cr := hi_int(r) and $FF;
  cg := hi_int(g) and $FF;
  cb := hi_int(b) and $FF;

  c := cr + (cg shl 8) + (cb shl 16);

  Result := hi_newInt(c);
end;
{function sys_rgb2wrgb(args: THiArray): PHiValue; stdcall;
var
  rgb: PHiValue;
  cr,cg,cb,c: Integer;
begin
  rgb := args.Items[0];
  c  := hi_int(rgb);

  cr := (c shr 16)and $FF;
  cg := (c shr  8)and $FF;
  cb := c         and $FF;

  c := cr + (cg shl 8) + (cb shl 16);

  Result := hi_newInt(c);
end;
}
function sys_not(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setBool(Result, not hi_bool(a));
end;

function sys_or(args: THiArray): PHiValue; stdcall;
var
  a, b: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  b := args.FindKey(token_b); // 値

  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setInt(Result, hi_int(a) or hi_int(b));
end;

function sys_and(args: THiArray): PHiValue; stdcall;
var
  a, b: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  b := args.FindKey(token_b); // 値

  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setInt(Result, hi_int(a) and hi_int(b));
end;

function sys_xor(args: THiArray): PHiValue; stdcall;
var
  a, b: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  b := args.FindKey(token_b); // 値

  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setInt(Result, hi_int(a) xor hi_int(b));
end;

function sys_shift_l(args: THiArray): PHiValue; stdcall;
var
  v, a: Integer;
begin
  v := getArgInt(args, 0, True);
  a := getArgInt(args, 1);
  Result := hi_newInt(v shl a);
end;
function sys_shift_r(args: THiArray): PHiValue; stdcall;
var
  v, a: Integer;
begin
  v := getArgInt(args, 0, True);
  a := getArgInt(args, 1);
  Result := hi_newInt(v shr a);
end;

function sys_frac(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setFloat(Result, frac(hi_float(a)));
end;

function sys_rnd(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setInt(Result, RandomMT.Random(hi_int(a)));
  //hi_setInt(Result, Random(hi_int(a)));
end;

function sys_randomize(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  // (2) データの処理
  if a = nil then
  begin
    RandomMT.Randomize;
  end else
  begin
    RandomMT.Randomize(hi_int(a));
  end;
  // (3) 戻り値を設定
  Result := nil;
end;


function sys_float(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setFloat(Result, hi_float(a));
end;

function sys_sin(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setFloat(Result, sin(hi_float(a)));
end;
function sys_cos(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setFloat(Result, cos(hi_float(a)));
end;
function sys_tan(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setFloat(Result, tan(hi_float(a)));
end;
function sys_arcsin(args: THiArray): PHiValue;
var
  a: PHiValue;
  f: Extended;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  f := hi_float(a);
  if (f < -1) or (1 < f) then
    raise Exception.Create('ARCSINへの入力が-1～1の間にありません。');
  hi_setFloat(Result, arcsin(f));
end;
function sys_arccos(args: THiArray): PHiValue;
var
  a: PHiValue;
  f: Extended;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  f := hi_float(a);
  if (f < -1) or (1 < f) then
    raise Exception.Create('ARCCOSへの入力が-1～1の間にありません。');
  hi_setFloat(Result, arccos(f));
end;
function sys_arctan(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setFloat(Result, arctan(hi_float(a)));
end;
function sys_csc(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setFloat(Result, csc(hi_float(a)));
end;
function sys_sec(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setFloat(Result, sec(hi_float(a)));
end;
function sys_cot(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setFloat(Result, cot(hi_float(a)));
end;
function sys_arccsc(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setFloat(Result, arccsc(hi_float(a)));
end;
function sys_arcsec(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setFloat(Result, arcsec(hi_float(a)));
end;
function sys_arccot(args: THiArray): PHiValue;
var
  a: PHiValue;
begin
  // (1) 引数の取得
  a := args.FindKey(token_a); // 値
  if a = nil then a := HiSystem.Sore;
  // (2) データの処理 / (3) 戻り値を設定
  Result := hi_var_new;
  hi_setFloat(Result, arccot(hi_float(a)));
end;


// SysUtils を改良したもの(WINDOWS用)
function GetEnvVar(const Name: AnsiString): AnsiString;
var // 環境変数の取得
  Len: Integer;
begin
  Result := '';
  try
    Len := GetEnvironmentVariableA(PAnsiChar(Name), nil, 0);
    if Len > 0 then
    begin
      SetLength(Result, Len); // 修正 Len -1 だとアクセスエラーが出る環境があった
      ZeroMemory(@Result[1], Length(Result));
      GetEnvironmentVariableA(PAnsiChar(Name), PAnsiChar(Result), Len);
      // 最後の#0を抜く
      if Copy(Result, Length(Result), 1) = #0 then
        System.Delete(Result, Length(Result), 1);
    end;
  except
    Result := ''; // エラーが出たら空
  end;
end;

function sys_getEnv(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
begin
  s := args.Items[0];
  //Result := hi_newStr(GetEnvironmentVariable(hi_str(s)));
  // 独自の取得関数に書き換え
  Result := hi_newStr(GetEnvVar(hi_str(s)));
end;


function sys_dateAdd(args: THiArray): PHiValue; stdcall;
var
  s, a: PHiValue;
  ss: AnsiString;
begin
  s := args.Items[0];
  a := args.Items[1];
  if s=nil then s := HiSystem.Sore;

  ss := AnsiString(FormatDateTime(
    'yyyy/mm/dd',
    IncDate(StrToDateEx(hi_str(s)),
    ConvToHalf(hi_str(a)))));
  Result := hi_newStr(ss);
end;

function sys_timeAdd(args: THiArray): PHiValue; stdcall;
var
  s, a: PHiValue;
  ss: AnsiString;
begin
  s := args.Items[0];
  a := args.Items[1];
  if s=nil then s := HiSystem.Sore;

  ss := AnsiString(FormatDateTime( 'hh:nn:ss',
    IncTime(
      StrToDateEx(hi_str(s)),
      ConvToHalf(hi_str(a))
    )));
  Result := hi_newStr(ss);
end;

function sys_dateSub(args: THiArray): PHiValue; stdcall;
var
  a, b: PHiValue;
  da,db: TDateTime;
begin
  a := args.Items[0];
  b := args.Items[1];

  da := StrToDateEx(hi_str(a));
  db := StrToDateEx(hi_str(b));

  Result := hi_newInt(Trunc(db-da));
end;

function sys_timeSub(args: THiArray): PHiValue; stdcall;
var
  a, b: PHiValue;
  da,db: TDateTime;
begin
  a := args.Items[0];
  b := args.Items[1];

  da := StrToDateEx(hi_str(a));
  db := StrToDateEx(hi_str(b));

  Result := hi_newInt(Round((db-da)*60*60*24));
end;

function sys_MinutesSub(args: THiArray): PHiValue; stdcall;
var
  a, b: PHiValue;
  da,db: TDateTime;
begin
  a := args.Items[0];
  b := args.Items[1];

  da := StrToDateEx(hi_str(a));
  db := StrToDateEx(hi_str(b));

  Result := hi_newInt(Round((db-da)*MinsPerDay));
end;

function sys_HourSub(args: THiArray): PHiValue; stdcall;
var
  a, b: PHiValue;
  da,db: TDateTime;
begin
  a := args.Items[0];
  b := args.Items[1];

  da := StrToDateEx(hi_str(a));
  db := StrToDateEx(hi_str(b));

  Result := hi_newInt(Round((db-da)*HoursPerDay));
end;

function sys_fromUnixTime(args: THiArray): PHiValue; stdcall;
var
  i: Integer;
  d: TDateTime;
begin
  i := getArgInt(args, 0, True);
  d := UNIXTimeToDelphiDateTime(i);
  Result := hi_newStr(
    AnsiString(
      FormatDateTime('yyyy/mm/dd hh:nn:ss', d)
    )
  );
end;

function sys_toUnixTime(args: THiArray): PHiValue; stdcall;
var
  d: TDateTime;
begin
  try
    d := StrToDateEx(getArgStr(args, 0, True));
  except
    Result := hi_newInt(0);
    Exit;
  end;
  Result := hi_newInt(DelphiDateTimeToUNIXTime(d));
end;

function sys_date_wa(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
begin
  s := args.Items[0];
  Result := hi_newStr(DateToWarekiS(hi_str(s)));
end;

{$IFDEF DELPHI6}
function sys_date_format(args: THiArray): PHiValue; stdcall;
begin
  Result := nil;// ごめんなさい
end;
{$ELSE}
function sys_date_format(args: THiArray): PHiValue; stdcall;
var
  date_s: AnsiString;
  fmt: AnsiString;
  dt: TDateTime;
  fs: TFormatSettings;
  i: Integer;
const
  w_str: array[1..7] of string = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
  m_str: array[1..12] of string = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
begin
  date_s := getArgStr(args, 0, True);
  fmt    := getArgStr(args, 1);
  dt := StrToDateEx(date_s);
  //
  GetLocaleFormatSettings(GetUserDefaultLCID, fs);
  if (fmt = 'RSS形式') then // check RFC2822
  begin
    // Wed, 20 Aug 2008 00:40:56 +0900
    // ローカライズ防止
    for i := 1 to 7 do
    begin
      fs.ShortDayNames[i] := w_str[i];
    end;
    for i := 1 to 12 do
    begin
      fs.ShortMonthNames[i] := m_str[i];
    end;
    fmt := 'ddd, dd mmm yyyy hh:nn:ss +0900';
  end else
  if (fmt = 'ISO8601') then
  begin
    fmt := 'yyyy-mm-dd hh:nn:ss';
  end;
  Result := hi_newStr(AnsiString(FormatDateTime(string(fmt), dt, fs)));
end;
{$ENDIF}

function sys_format(args: THiArray): PHiValue; stdcall;
var
  s, a: PHiValue;
  sa, ss: AnsiString;
begin
  s := args.Items[0]; if s = nil then s := HiSystem.Sore;
  a := args.Items[1];

  sa := hi_str(a);

  try
    if (PosA('f', sa) > 0)or(PosA('m', sa) > 0) then begin
        ss := FormatA(sa,[hi_float(s)]);
    end else if (PosA('d', sa) > 0)or(PosA('x', sa) > 0)or(PosA('X', sa) > 0) then begin
        ss := FormatA(sa,[hi_int(s)]);
    end else begin
        ss := FormatA(sa,[hi_str(s)]);
    end;
    Result := hi_newStr(ss);
  except
    on e: Exception do
      raise Exception.Create('形式指定|FORMATで形式が変換できませんでした。'+e.Message);
  end;

end;
function sys_formatzero(args: THiArray): PHiValue; stdcall;
var
  s, a: PHiValue;
begin
  s := args.Items[0]; if s = nil then s := HiSystem.Sore;
  a := args.Items[1];

  try
    Result := hi_newStr(
      FormatA('%.' + IntToStrA(hi_int(a)) + 'd', [ hi_int(s) ] )
    );
  except
    Result := hi_clone(s);
  end;
end;
function sys_formatmoney(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;

  function InsertYenComma(const yen: AnsiString): AnsiString;
  begin
    if PosA('.',yen)=0 then
    begin
        Result := AnsiString(FormatCurr('#,##0', HimaStrToNum(yen)));
    end else
    begin
        Result := AnsiString(FormatCurr('#,##0.00', HimaStrToNum(yen)));
    end;
  end;

begin
  s := args.Items[0];
  if s = nil then s := HiSystem.Sore;
  try
    Result := hi_newStr(
      InsertYenComma(hi_str(s))
    );
  except
    Result := hi_clone(s);
  end;
end;
function sys_str_center(args: THiArray): PHiValue; stdcall;
var
  s, a: PHiValue;
  ss, res: AnsiString;
  ia: Integer;
  i, spc: Integer;
begin
  s := args.Items[0]; if s = nil then s := HiSystem.Sore;
  a := args.Items[1];

  ss := hi_str(s);
  ia := hi_int(a);

  spc := (ia - Length(ss)) div 2;
  res := '';
  for i := 1 to spc do
  begin
    res := res + ' ';
  end;

  Result := hi_newStr(res + ss);
end;

function sys_zen_kana(args: THiArray): PHiValue; stdcall;
var s: AnsiString;
begin
  s := CopyA(getArgStr(args,0,True),1,1) + ' ';
  Result := hi_newBool(s[1] in SysUtils.LeadBytes);
end;
function sys_hira_kana(args: THiArray): PHiValue; stdcall;
begin
  Result := hi_newBool(IsHiragana(getArgStr(args,0,True)));
end;
function sys_kata_kana(args: THiArray): PHiValue; stdcall;
begin
  Result := hi_newBool(IsKatakana(getArgStr(args,0,True)));
end;
function sys_suuji_kana(args: THiArray): PHiValue; stdcall;
begin
  Result := hi_newBool(IsNumOne(getArgStr(args,0,True)));
end;
function sys_suuretu_kana(args: THiArray): PHiValue; stdcall;
var s: AnsiString;
begin
  s := getArgStr(args,0,True);
  Result := hi_newBool(IsNumber(s));
end;
function sys_eiji_kana(args: THiArray): PHiValue; stdcall;
begin
  Result := hi_newBool(IsAlphabet(getArgStr(args,0,True)));
end;

function sys_str_comp(args: THiArray): PHiValue; stdcall;
var
  a, b: AnsiString;
  r: Integer;
begin
  a := getArgStr(args, 0,True);
  b := getArgStr(args, 1);
  if a = b then r := 0 else
  if a > b then r := 1 else r := -1;
  Result := hi_newInt(r);
end;

function sys_str_comp_jisyo(args: THiArray): PHiValue; stdcall;
var
  a, b: AnsiString;
  r: Integer;
begin
  a := getArgStr(args, 0,True);
  b := getArgStr(args, 1);
  //
  a := UpperCaseEx( convToFull(a) );
  b := UpperCaseEx( convToFull(b) );
  //
  if a = b then r := 0 else
  if a > b then r := 1 else r := -1;
  Result := hi_newInt(r);
end;

function sys_str_right(args: THiArray): PHiValue; stdcall;
var
  s, a: PHiValue;
  ss, res: AnsiString;
  ia: Integer;
  i, spc: Integer;
begin
  s := args.Items[0];if s = nil then s := HiSystem.Sore;
  a := args.Items[1];

  ss := hi_str(s);
  ia := hi_int(a);

  spc := (ia - Length(ss));
  res := '';
  for i := 1 to spc do
  begin
    res := res + ' ';
  end;

  Result := hi_newStr(res + ss);
end;


function sys_packfile(args: THiArray): PHiValue; stdcall;
var
  a,b,c: PHiValue;
begin
  a := nako_getFuncArg(args, 0);; // exe
  b := nako_getFuncArg(args, 1);; // pack
  c := nako_getFuncArg(args, 2);; // save
  //
  WritePackExeFile(string(hi_str(c)), string(hi_str(a)), string(hi_str(b)));
  Result := nil;
end;

function sys_unpackfile(args: THiArray): PHiValue; stdcall;
var
  a,b: PHiValue;
  m: TMemoryStream;
begin
  a := nako_getFuncArg(args, 0);; // exe
  b := nako_getFuncArg(args, 1);; // pack
  //
  m := TMemoryStream.Create;
  try
    ReadPackExeFile(string(hi_str(a)), m);
    m.SaveToFile(string(hi_str(b)));
  finally
    m.Free;
  end;

  Result := nil;
end;

function sys_checkpackfile(args: THiArray): PHiValue; stdcall;
var
  f: PHiValue;
begin
  f := nako_getFuncArg(args, 0);

  Result := hi_var_new;
  hi_setBool(Result, ReadPackExeFile(string(hi_str(f)), nil, False));
end;

function sys_packfile_nako_load(args: THiArray): PHiValue; stdcall;
var
  pPack: PHiValue;
  pFile: PHiValue;

  s: AnsiString;
begin
  Result := hi_var_new;

  pPack := nako_getFuncArg(args, 0);
  pFile := nako_getFuncArg(args, 1);

  if FileMixReader <> nil then FileMixReader.Free;

  FileMixReader := TFileMixReader.Create(string(hi_str(pPack)));
  try
    try
      FileMixReader.ReadFileAsString(string(hi_str(pFile)), s);
      HiSystem.LoadSourceText(s, hi_str(pFile));
    except
      hi_setBool(Result, False); Exit;
    end;
    hi_setBool(Result, True);
  finally
  end;
end;
function sys_packfile_nako_run(args: THiArray): PHiValue; stdcall;
begin
  Result := HiSystem.Run;
end;
function sys_makeDllReport(args: THiArray): PHiValue; stdcall;
begin
  Result := hi_newStr(HiSystem.makeDllReport);
end;

function sys_packfile_extract(args: THiArray): PHiValue; stdcall;
var
  a,b,c: PHiValue;
  e: TFileMixReader;
begin
  a := nako_getFuncArg(args, 0);; // pack
  b := nako_getFuncArg(args, 1);; // file
  c := nako_getFuncArg(args, 2);; // save
  //
  e := TFileMixReader.Create(string(hi_str(a)));
  try
    e.autoDelete := False;
    if False = e.ReadAndSaveToFile(string(hi_str(b)), string(hi_str(c)), True) then
    begin
      raise Exception.Create('パックファイルからの抽出ができません。');
    end;
  finally
    e.Free;
  end;
  Result := nil;
end;

function sys_packfile_extract_str(args: THiArray): PHiValue; stdcall;
var
  a,b: PHiValue;
  e: TFileMixReader;
  s: AnsiString;
begin
  a := nako_getFuncArg(args, 0);; // pack
  b := nako_getFuncArg(args, 1);; // file

  e := TFileMixReader.Create(string(hi_str(a)));
  try
    e.autoDelete := False;
    if False = e.ReadFileAsString(string(hi_str(b)), s, True) then
    begin
      Exception.Create('パックファイルからの抽出ができません。');
    end;
  finally
    e.Free;
  end;
  Result := hi_newStr(s);
end;

function sys_packfile_enum(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
  e: TFileMixReader;
  s: THStringList;
begin
  a := nako_getFuncArg(args, 0);; // pack
  e := TFileMixReader.Create(string(hi_str(a)));
  try
    e.autoDelete := False;
    s := e.EnumFiles;
    Result := hi_newStr(s.Text);
    FreeAndNil(s);
  finally
    e.Free;
  end;
end;

function sys_packfile_make(args: THiArray): PHiValue; stdcall;
var
  a,b: PHiValue;
  w: TFileMixWriter;
begin
  a := nako_getFuncArg(args, 0); // list
  b := nako_getFuncArg(args, 1); // pack
  //
  w := TFileMixWriter.Create;
  try
    w.FileList.Text := string(hi_str(a));
    w.SaveToFile(string(hi_str(b)));
  finally
    w.Free;
  end;
  Result := nil;
end;

function sys_extractFile(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s = nil then s := nako_getSore;

  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, AnsiString(ExtractFileName(string(hi_str(s)))));
end;

function sys_extractFilePath(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s = nil then s := nako_getSore;

  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, ExtractFilePathA(hi_str(s)));
end;

function sys_extractExt(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
begin

  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  if s = nil then s := HiSystem.Sore;

  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result, AnsiString(ExtractFileExt(string(hi_str(s)))));
end;

function sys_changeExt(args: THiArray): PHiValue; stdcall;
var
  s, a: PHiValue;
begin

  // (1) 引数の取得
  s   := nako_getFuncArg(args, 0);
  a   := nako_getFuncArg(args, 1);
  if s = nil then s := HiSystem.Sore;

  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_var_new;
  hi_setStr(Result,
    AnsiString(ChangeFileExt(
      string(hi_str(s)), string(hi_str(a)))
    )
  );
end;

function sys_makeoriginalfile(args: THiArray): PHiValue; stdcall;
var
  pDir, pHeader: PHiValue;
  s: AnsiString;
begin
  pDir    := nako_getFuncArg(args, 0);
  pHeader := nako_getFuncArg(args, 1);

  // OSのコマンドを使う場合
  // s := getOriginalFileName(hi_str(pDir), hi_str(pHeader));
  // 分かりやすい名前を使う場合
  s := AnsiString(
    mini_file_utils.getUniqFilename(
      string(hi_str(pDir)),
      string(hi_str(pHeader)))
  );

  Result := hi_newStr(s);
end;

function sys_expand_path(args: THiArray): PHiValue; stdcall;
var
  s, a: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(args, 0);
  a := nako_getFuncArg(args, 1);
  if s=nil then s := nako_getSore;
  // (2) データの処理
  // (3) 戻り値を設定
  Result := hi_newStr(AnsiString(getAbsolutePath(string(hi_str(s)), string(hi_str(a)), '\')));
end;

//------------------------------------------------------------------------------

procedure hi_func_create(v: PHiValue);
begin
  if v.VType <> varFunc then
  begin
    hi_var_clear(v);
    v.VType := varFunc;
    v.Size  := SizeOf(THiFunction);
    v.ptr   := THiFunction.Create;
  end;
end;

procedure hi_func_free(v: PHiValue); // 関数の解放処理
var f: THiFunction;
begin
  if v.VType = varFunc then
  begin
    f := v.ptr;
    FreeAndNil(f);
    v.Size  := 0;
    hi_var_clear(v);
  end;
end;

function hi_func(v: PHiValue): THiFunction;
begin
  if v.VType <> varFunc then raise Exception.Create('関数ではありません。');
  Result := v.ptr;
end;

{ THimaArg }

procedure THimaArg.Assign(a: THimaArg);
begin
  // (1)
  Name := a.Name;
  // (2)
  hi_var_copy(a.Value, Value);
  // (3)
  Self.VType := a.VType;
  // (4)
  JosiList.Assign(a.JosiList);
  // (5)
  Needed := a.Needed;
  // (6)
  ByRef  := a.ByRef;
end;

constructor THimaArg.Create;
begin
  Needed := True;
  ByRef  := False;
  JosiList := THList.Create;
  Value  := hi_var_new;
  VType  := varNil; // <--- 型なし
end;

destructor THimaArg.Destroy;
begin
  hi_var_free(Value);
  JosiList.Free;
  inherited;
end;

{ THimaArgs }

function THimaArgs.Add_JosiCheck(arg: THimaArg): Integer;
var
  p: THimaArg;
begin
  p := FindFromName(arg.Name);
  if p = nil then
  begin
    Result := Self.Add(arg);
  end else
  begin
    Result := p.JosiList.AddNum(arg.JosiList.GetAsNum(0));
    FreeAndNil(arg);
  end;
end;

procedure THimaArgs.Assign(a: THimaArgs);
var
  v1,v2: THimaArg;
  i: Integer;
begin
  Self.Clear;
  for i := 0 to a.Count - 1 do
  begin
    v1 := a.Items[i];
    v2 := THimaArg.Create;
    v2.Assign(v1);
    Self.Add(v2);
  end;
end;

procedure THimaArgs.DefineArgs(s: AnsiString);
var
  p: PAnsiChar;
  m, kata, value, name, josi, ss: AnsiString;
  arg: THimaArg;
begin
  // {文字列=""}Aから{文字列}Bへ|AをBへ
  p := PAnsiChar(s);
  while p^ <> #0 do
  begin
    // 修飾
    if p^ = '{' then
    begin
      Inc(p);
      m := getTokenStr(p,'}');
      arg := THimaArg.Create;
      if PosA('=', m) > 0 then
      begin
        kata  := getToken_s(m, '=');
        value := m;
        arg.Needed := False;
      end else
      begin
        kata  := m;
        value := '';
        arg.Needed := True;
      end;
      // 型を設定する
      while kata <> '' do
      begin
        ss := getToken_s(kata, ' ');
             if ss = '文字列'   then arg.VType  := varStr
        else if ss = '整数'     then arg.VType  := varInt
        else if ss = '数値'     then arg.VType  := varFloat
        else if ss = '配列'     then arg.VType  := varArray
        else if ss = 'ハッシュ' then arg.VType  := varHash
        else if ss = 'グループ' then arg.VType  := varGroup
        else if ss = '値渡し'   then arg.ByRef  := False
        else if ss = '参照渡し' then arg.ByRef  := True
        ;
      end;
      // 初期値の設定
      if (value = '')or(value = '?')or(value = '''' + '''') then
      begin
        hi_var_clear(arg.Value); // 初期値なし
      end else
      begin
        if (value[1] in ['"','''']) then
        begin
          hi_setStr(arg.Value, Copy(value,2,Length(value)-2));
        end else
        if value[1] in SysUtils.LeadBytes then
        begin
          if (Copy(value, 1, 2) = '「')or(Copy(value, 1, 2) = '『') then
          begin
            System.Delete(value,1,2);                // 123456
            System.Delete(value, Length(value)-1, 2);// 「**」
            hi_setStr(arg.Value, value);
          end else
          begin
            hi_setStr(arg.Value, value);
          end;
        end else
        begin
          if value[1] in ['$','0'..'9'] then
            hi_setIntOrFloat(arg.Value, HimaStrToNum(value))
          else
            hi_setStr(arg.Value, Copy(value,2,Length(value)-2));
        end;

      end;
      //
      name := HimaGetWord(p, josi);
      arg.Name := HiSystem.TangoList.GetID(name);
      arg.JosiList.AddNum(DWORD(HiSystem.JosiList.GetID(josi)));
      Self.Add_JosiCheck(arg);
    end else
    begin
      name := HimaGetWord(p, josi);
      arg := THimaArg.Create;
      arg.Name := HiSystem.TangoList.GetID(name);
      arg.JosiList.AddNum(DWORD(HiSystem.JosiList.GetID(josi)));
      Self.Add_JosiCheck(arg);
    end;
    if p^ = '|' then Inc(p);
    if p^ = ',' then Inc(p);
  end;
end;

destructor THimaArgs.Destroy;
begin
  inherited;
end;

function THimaArgs.FindFromName(name: DWORD): THimaArg;
var
  i: Integer;
  p: THimaArg;
begin
  Result := nil;
  for i := 0 to Self.Count - 1 do
  begin
    p := Self.Items[i];
    if p.Name = name then
    begin
      Result := p;
      Break;
    end;
  end;
end;


{ THiFunction }

procedure THiFunction.Assign(src: THiFunction);
begin
  FuncType := src.FuncType;
  Args.Assign(src.Args);
  PFunc := src.PFunc;
  DllRetType := src.DllRetType;
  DllArgType := src.DllArgType;
end;

constructor THiFunction.Create;
begin
  Args  := THimaArgs.Create;
  PFunc := nil;
  DllArg:= nil;
  PluginID := -1;
end;

destructor THiFunction.Destroy;
begin
  FreeAndNil(Args);
  FreeAndNil(DllArg);
  inherited;
end;

end.
