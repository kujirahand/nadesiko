unit hima_variable_ex;

interface

uses
  Windows, SysUtils, Classes, hima_types, hima_variable;


//------------------------------------------------------------------------------
// 配列
//------------------------------------------------------------------------------
type
  THiArrayPickupFunc = function (v: PHiValue; param: Integer): Boolean; // ピックアップする場合にTrueを返す

  TDoubleArray = array of Double;
  THiArray = class(THList)
  private
    FRefCount: Integer;
    FForStack: Boolean;
    function GetValue(Index: Integer): PHiValue;
    procedure SetValue(Index: Integer; const Value: PHiValue);
    procedure AddFromString(s: AnsiString); // 改行で区切って要素追加
    procedure AddFromStringEx(s: AnsiString; splitter: AnsiChar); // 改行で区切って要素追加 ... CSVパーサー
    function GetAsString: AnsiString;
    procedure SetAsTsv(const Value: AnsiString);
    function GetAsTsv: AnsiString;
    function GetCell(Row, Col: Integer): PHiValue;
    procedure SetCell(Row, Col: Integer; const Value: PHiValue);
  protected
    function CustomPickup(func: THiArrayPickupFunc; param: Integer): THiArray;
  public
    property Values[Index: Integer]: PHiValue read GetValue write SetValue;
    procedure Clear; override;
    procedure ClearNotFree;
    function FindKey(Key: DWORD): PHiValue;
    function Join(s: AnsiString): AnsiString;
    function JoinAsCSV(splitter: AnsiString): AnsiString;
    procedure Assign(a: THiArray);
    procedure Add(v: PHiValue);
    procedure Sort;
    procedure SortNum;
    procedure CustomSort(s: AnsiString);
    procedure SortCsv(Index: Integer);
    procedure SortCsvNum(Index: Integer);
    procedure InsertArray(Index: Integer; a: THiArray);
    procedure Delete(Index: Integer); override;
    function DeleteAndPop(Index: Integer): PHiValue;
    function ToFloatArray: TDoubleArray;
    function sum: HFloat;
    function mean: HFloat;
    function stddev: HFloat;
    function norm: HFloat;
    function max: HFloat;
    function min: HFloat;
    function PopnVariance: HFloat;
    function FindIndex(key: AnsiString; fromI: Integer): Integer;
    function CsvPickupHasKey(s: AnsiString; Index: Integer=-1): THiArray;
    function CsvPickupIsKey(s: AnsiString; Index: Integer=-1): THiArray;
    function CsvPickupWildcard(s: AnsiString; Index: Integer=-1): THiArray;
    function CsvPickupRegExp(s: AnsiString; Index: Integer=-1): THiArray;
    function CsvFind(Col: Integer; key: AnsiString; fromRow: Integer=0): Integer;
    function CsvVagueFind(Col: Integer; key: AnsiString; fromRow: Integer=0): Integer;
    function GetColCount: Integer;
    function CutRow(vFrom, Count: Integer): THiArray;
    procedure RowColReverse;
    procedure Rotate;
    procedure CsvUniqCol(Col: Integer);
    procedure TrimTop;    // 上から無効なセルを削除
    procedure TrimBottom; // 下から無効なセルを削除
    procedure Trim;
    function CsvGetCol(i: Integer): PHiValue;
    function CsvInsCol(i: Integer; a: THiArray): PHiValue;
    function CsvDelCol(i: Integer): PHiValue;
    function CsvSum(idx: Integer): HFloat;
    property AsString: AnsiString read GetAsString write AddFromString; // カンマ区切り
    property AsTSV: AnsiString read GetAsTsv write SetAsTsv;
    property Cells[Row, Col: Integer]: PHiValue read GetCell write SetCell;
    property RefCount: Integer read FRefCount write FRefCount;
    property ForStack: Boolean read FForStack write FForStack;
  end;

procedure hi_ary_create(var v: PHiValue);
function  hi_ary_get(v: PHiValue; index: Integer): PHiValue;
function  hi_ary_getCsv(v: PHiValue; Row, Col: Integer): PHiValue;
procedure hi_ary_set(v: PHiValue; index: Integer; value: PHiValue);
function  hi_ary_count(v: PHiValue): Integer;
procedure hi_ary_setStr(v: PHiValue; index: Integer; value: AnsiString);
function  hi_ary2str(v: PHiValue): AnsiString;
procedure hi_str2ary(v: PHiValue);
function  hi_ary(v: PHiValue): THiArray;

//------------------------------------------------------------------------------
// ハッシュ
//------------------------------------------------------------------------------
type
  THiHashItem = class(THHashItem)
  public
    value: PHiValue;
  end;

  THiHash = class(THHash)
  private
    obj_assignTo: THiHash;
    temp: TStringList;
    FRefCount: Integer;
    function FreeItem(item: THHashItem): Boolean;
    function subGetAsString(item: THHashItem): Boolean;
    function subEnumKey(item: THHashItem): Boolean;
    function subEnumValue(item: THHashItem): Boolean;
    function GetValue(key: AnsiString): PHiValue;
    procedure SetValue(key: AnsiString; const Value: PHiValue);
    function subAssignTo(item: THHashItem): Boolean;
    function GetAsString: AnsiString;
    procedure SetFromString(const Value: AnsiString);
  public
    procedure Clear; override;
    function EnumKeys: AnsiString;
    function EnumValues: AnsiString;
    property Values[key: AnsiString]: PHiValue read GetValue write SetValue;
    procedure Assign(src: THiHash);
    procedure AssignTo(Des: THiHash);
    property AsString: AnsiString read GetAsString write SetFromString;
    property RefCount: Integer read FRefCount write FRefCount;
    constructor Create;
    destructor Destroy;override;
  end;

procedure hi_hash_create(v: PHiValue);
function  hi_hash_get(v: PHiValue; key: AnsiString): PHiValue;
procedure hi_hash_set(v: PHiValue; key: AnsiString; value: PHiValue);
function  hi_hash(v: PHiValue): THiHash;

//------------------------------------------------------------------------------
// 構造体
//------------------------------------------------------------------------------
//DType = ([1]Char/Byte,[2]Short/Word,[4]Long/DWord/Pointer/Float/Char*,[n]?(n)/[8]Real/Int64/[10]Extended)
const
  REC_DTYPE_1CHAR       = 'C';
  REC_DTYPE_1BYTE       = 'B';
  REC_DTYPE_2SHORT      = 'S';
  REC_DTYPE_2WORD       = 'W';
  REC_DTYPE_4LONG       = 'L';
  REC_DTYPE_4DWORD      = 'D';
  REC_DTYPE_4POINTER    = 'P';
  REC_DTYPE_4FLOAT      = 'F';
  REC_DTYPE_8REAL       = 'R';
  REC_DTYPE_8INT64      = 'I';
  REC_DTYPE_8QWORD      = 'Q';
  //REC_DTYPE_10EXTENDED  = 'E';
  REC_DTYPE__EXT        = '?';

type
  PHimaRecVarType = ^THimaRecVarType;
  THimaRecVarType = record // 構造体の構成.変数構造体
    VName: AnsiString;  // 変数の名前
    DType: AnsiString;  // データタイプ
    DSize: Integer; // データサイズ
    Index: Integer; // この構造体が構造体の何バイト目にあるかの情報
  end;

  TCallBufferRecord = record
    ptr:Pointer;
    src:PHiValue;
    dtype:AnsiChar;
  end;

  THimaRecord = class
  private
    FTotalByte: Integer;
    FDataTypes: array of THimaRecVarType;
    FDataBuffer: array of TCallBufferRecord;
    FBufferCount: integer;
    function SetBuffer(ptr: Pointer;src:PHiValue;dtype:AnsiChar):Pointer;
    procedure BufferClear;
  public
    DataPtr: Pointer;
    constructor Create;
    destructor Destroy; override;
    procedure SetDataTypes(DataTypes: AnsiString;for_stack: boolean = false);// TYPE NAME, TYPE NAME ... とカンマで区切って指定
    procedure RecordCreate; // 構造体の実体を作る
    procedure RecordFree;   // 構造体の実体を破棄
    function FindVar(const name: AnsiString): PHimaRecVarType;
    function FindVarIndex(const name: AnsiString): Integer;

    procedure SetVarNumIndex(Index, value: Integer);
    procedure SetVarNum(const name: AnsiString; value: Integer);
    function GetVarNum(const name: AnsiString): Integer;
    function GetVarNumIndex(Index:Integer): Integer;

    procedure SetVarFloatIndex(Index:Integer; value: Extended);
    procedure SetVarFloat(const name: AnsiString; value: Extended);
    function GetVarFloat(const name: AnsiString): Extended;
    function GetVarFloatIndex(Index:Integer): Extended;

    procedure SetVarStrIndex(Index: Integer;const value: AnsiString);
    procedure SetVarStr(const name: AnsiString;const value: AnsiString);

    procedure SetPAnsiCharIndex(Index: Integer; pv: PAnsiChar);
    procedure SetPointerIndex(Index: Integer; ptr: Pointer);
    function GetPointerIndex(Index: Integer): Pointer;

    function GetVarStr(const name: AnsiString): AnsiString;
    function GetVarStrIndex(Index: Integer): AnsiString;

    procedure SetVarBin(const name: AnsiString; value: Pointer; size: Integer);
    procedure SetVarBinIndex(index: integer; value: Pointer;size: Integer);
    function GetVarBinIndex(Index: Integer): AnsiString;

    procedure SetValue(const name: AnsiString; value: PHiValue);
    procedure SetValueIndex(Index: Integer; value: PHiValue);
    function GetValue(const name: AnsiString): PHiValue;
    procedure GetValueIndex(Index: Integer; res: PHiValue);

    property TotalByte: Integer read FTotalByte;
    procedure DataTypeCopyTo(rec: THimaRecord);
    procedure CopyToAll(rec: THimaRecord);
    procedure CopyDataTo(p: Pointer); // 無保証に全てをコピーする
    procedure Assign(rec: THimaRecord);
    procedure RestoreBuffer;
    function DumpMemory: AnsiString;
    function Count: Integer;
  end;

//------------------------------------------------------------------------------
// クラス(グループ)
//------------------------------------------------------------------------------
type
  THiGroup = class(THList)
  private
    FRefCount: Integer;
    FInstanceVar: PHiValue;
  public
    HiClassNameID     : DWORD;
    HiClassInstanceID : DWORD;
    HiClassDebug      : AnsiString; // DEBUG用
    IsDestructorRunned : Boolean;
    DefaultValue: PHiValue; // default
    constructor Create(InstanceVar: PHiValue);
    function FindMember(id: DWORD): PHiValue;
    function FindMemberIndex(id: DWORD): Integer;
    function Add(v: PHiValue): Integer;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Assign(src: THiGroup);
    procedure AddMembers(src: THiGroup);
    function EnumKeys: AnsiString;
    function EnumKeyAndVlues: AnsiString;
    property RefCount: Integer read FRefCount write FRefCount;
    property InstanceVar: PHiValue read FInstanceVar; // 実体を司る変数
  end;

procedure hi_group_create(var v: PHiValue);
procedure hi_group_free(v: PHiValue);
function hi_group(v:PHiValue): THiGroup; // for CAST

//------------------------------------------------------------------------------
// 計算 (a と b を計算して答えを返す)
//------------------------------------------------------------------------------
function hi_var_calc_plus  (a, b: PHiValue): PHiValue;
function hi_var_calc_minus (a, b: PHiValue): PHiValue;
function hi_var_calc_mul   (a, b: PHiValue): PHiValue;
function hi_var_calc_div   (a, b: PHiValue): PHiValue;
function hi_var_calc_mod   (a, b: PHiValue): PHiValue;

function hi_var_calc_plus_str(a, b: PHiValue): PHiValue;

function hi_var_calc_Eq    (a, b: PHiValue): PHiValue;
function hi_var_calc_NotEq (a, b: PHiValue): PHiValue;
function hi_var_calc_Gt    (a, b: PHiValue): PHiValue;
function hi_var_calc_GtEq  (a, b: PHiValue): PHiValue;
function hi_var_calc_Lt    (a, b: PHiValue): PHiValue;
function hi_var_calc_LtEq  (a, b: PHiValue): PHiValue;

function hi_var_calc_Or    (a, b: PHiValue): PHiValue;
function hi_var_calc_And   (a, b: PHiValue): PHiValue;

function hi_var_calc_ShiftL(a, b: PHiValue): PHiValue;
function hi_var_calc_ShiftR(a, b: PHiValue): PHiValue;
function hi_var_calc_Power (a, b: PHiValue): PHiValue;

function conv2float(p: PHiValue): HFloat;

implementation

uses
  Math, hima_string, unit_string, hima_system, hima_variable_lib,
  hima_function,wildcard2, BRegExp;

function conv2float(p: PHiValue): HFloat;
var
  s: AnsiString;
begin
  if p = nil then
  begin
    Result := 0; Exit;
  end;

  if p^.VType = varStr then
  begin
    s := hi_str(p); // 文字列ならできるだけ数値にする
    //s := HimaSourceConverter(0,s);
    s := convToHalf(s);
    Result := HimaStrToNum(s);
  end else
  begin
    Result := hi_float(p);
  end;
end;

procedure hi_ary_create(var v: PHiValue);
var s: AnsiString;
begin
  // 配列の生成
  if v = nil then
  begin
    v := hi_var_new;
  end else
  begin
    v := hi_getLink(v);
  end;

  if v.VType <> varArray then
  begin
    // 現在の値をなるだけ保持
    s := hi_str(v);

    // 初期化
    hi_var_clear(v);
    v.VType := varArray;
    v.Size  := SizeOf(THiArray);
    v.ptr   := THiArray.Create;

    // 配列に自動変換
    if s <> '' then
      THiArray(v.ptr).AsString := s;
  end;

  Assert( v.ptr <> nil, 'hi_ary_create()で配列の生成ができませんでした。' );
end;

function  hi_ary(v: PHiValue): THiArray;
begin
  if v.VType <> varArray then
  begin
    if v.VType = varLink then
    begin
      Result := hi_ary(hi_getLink(v)); Exit;
    end;
    raise Exception.Create('配列ではありません。');
  end;
  Result := v.ptr;
  
  Assert( Result <> nil, 'hi_ary(v)のキャストでnilが返されました。' );
end;

function  hi_ary_get(v: PHiValue; index: Integer): PHiValue;
begin
  hi_ary_Create(v);
  Result := THiArray(v.ptr).GetValue(index);
end;

function  hi_ary_getCsv(v: PHiValue; Row, Col: Integer): PHiValue;
var p: PHiValue;
begin
  hi_ary_Create(v);
  // Row を得る
  p := hi_ary(v).GetValue(Row);
  // Col を得る
  Result := hi_ary_get(p, Col);
end;

procedure hi_ary_set(v: PHiValue; index: Integer; value: PHiValue);
begin
  hi_ary_Create(v);
  THiArray(v.ptr).SetValue(index, value);
end;

procedure hi_ary_setStr(v: PHiValue; index: Integer; value: AnsiString);
var
  p: PHiValue;
begin
  hi_ary_Create(v);
  p := hi_var_new;
  hi_setStr(p, value);
  THiArray(v.ptr).SetValue(index, p);
end;

function  hi_ary2str(v: PHiValue): AnsiString;
begin
  hi_ary_Create(v);
  Result := THiArray(v.ptr).AsString;
end;

procedure  hi_str2ary(v: PHiValue);
var
  s: AnsiString;
begin
  if v.VType <> varArray then
  begin
    s := hi_str(v);
    hi_ary_create(v);
    hi_ary(v).AddFromString(s);
  end;
end;

function  hi_ary_count(v: PHiValue): Integer;
begin
  if v.VType <> varArray then
    if v.VType <> varNil then Result := 0 else Result := 1
  else
    Result := THiArray(v.ptr).Count;
end;


procedure hi_hash_create(v: PHiValue);
var
  str: AnsiString;
begin
  v := hi_getLink(v);
  if v.VType <> varHash then
  begin
    // 現在の値をできるだけ保持
    str := hi_str(v);

    // クリア
    hi_var_clear(v);
    v.VType := varHash;
    v.Size  := SizeOf(THiScope);
    v.ptr   := THiHash.Create;

    // 以前の値を設定
    THiHash(v.ptr).AsString := str;
  end;
end;

function  hi_hash_get(v: PHiValue; key: AnsiString): PHiValue;
begin
  v := hi_getLink(v);
  hi_hash_create(v);
  Result := THiHash(v^.ptr).GetValue(key);
end;

procedure hi_hash_set(v: PHiValue; key: AnsiString; value: PHiValue);
begin
  hi_hash_create(v);
  THiHash(V^.ptr).SetValue(key, value);
end;

function  hi_hash(v: PHiValue): THiHash;
begin
  if v.VType <> varHash then
  begin
    if v.VType = varLink then
    begin
      Result := hi_hash(hi_getLink(v)); Exit;
    end;
    raise Exception.Create('ハッシュではありません。');
  end;
  Result := v.ptr;
end;

procedure hi_group_create(var v: PHiValue);
var
  old_v: PHiValue;
begin
  if (v <> nil)and(v.VType = varLink) then
  begin
    old_v := v;
    v := hi_getLink(v);
    hi_var_free(old_v);
  end;

  if v.VType <> varGroup then
  begin
    hi_var_clear(v);
    v.VType := varGroup;
    v.Size  := SizeOf(THiGroup); // ポインタの大きさだけど
    v.ptr   := THiGroup.Create(v);
  end;
end;

procedure hi_group_free(v: PHiValue);
begin
  if v.VType = varGroup then
  begin
    FreeAndNil(THiGroup(v.ptr));
    hi_var_clear(v);
  end;
end;

function hi_group(v:PHiValue): THiGroup; // for CAST
begin
  v := hi_getLink(v);
  if (v = nil) then raise Exception.Create('(NIL)はグループではありません。');
  if (v.VType <> varGroup) then
  begin
    if hi_id2tango(v.VarID) <> '' then
    begin
      raise HException.Create(hi_id2tango(v.VarID)+'はグループではありません。');
    end else begin
      raise Exception.Create('グループへのキャストに失敗しました。');
    end;
  end;
  Result := v.ptr;
end;

//------------------------------------------------------------------------------
{$OVERFLOWCHECKS ON}
//------------------------------------------------------------------------------

function hi_var_calc_plus_str(a, b: PHiValue): PHiValue;
var
  sa, sb, res: AnsiString;
begin
  try
    sa := hi_str(a);
    sb := hi_str(b);
  except
    on e:Exception do begin
      raise Exception.Create('文字列の足し算(二つの文字列を取得)。' + e.Message);
    end;
  end;
  try
    // 希に以下でエラーが起きる(!) なぜ?!
    res := sa + sb;
  except
    on e:Exception do begin
      raise Exception.Create('文字列の足し算(加算処理)。' + e.Message);
    end;
  end;
  try
    Result := hi_newStr(res);
  except
    on e:Exception do begin
      raise Exception.Create('文字列の足し算(結果の設定)。' + e.Message);
    end;
  end;
end;

function hi_var_calc_Eq    (a, b: PHiValue): PHiValue;
begin
  Result := hi_var_new;

  //----------------------------------------------------------------------------
  // 比較方針
  //----------------------------------------------------------------------------
  // (*1) 文字列と数値を比較する場合、右辺の値を尊重するべし
  //----------------------------------------------------------------------------
  // (-) 特に整数計算を優先して実行速度を稼ぐ！

  // 整数計算か？
  if (a.VType = varInt) and (b.VType = varInt) then
  begin
      hi_setBool(Result, (a.int = b.int));
  end else
  // 数値計算か？
  if ((a.VType = varInt)or(a.VType = varFloat)) and
     ((b.VType = varInt)or(b.VType = varFloat)) then
  begin
    hi_setBool(Result, (hi_float(a) = hi_float(b)));
  end else
  // (混合) 右辺を尊重して比較
  begin
    case b.VType of
      varInt    : hi_setBool( Result, (hi_int(a)   = hi_int(b)) );
      varFloat  : hi_setBool( Result, (hi_float(a) = hi_float(b)) );
      else        hi_setBool( Result, (hi_str(a)   = hi_str(b)) );
    end;
  end;

end;

function hi_var_calc_NotEq (a, b: PHiValue): PHiValue;
begin
  Result := hi_var_new;

  // 整数計算か？
  if (a.VType = varInt) and (b.VType = varInt) then
  begin
      hi_setBool(Result, (a.int <> b.int));
  end else
  // 数値計算か？
  if ((a.VType = varInt)or(a.VType = varFloat)) and
     ((b.VType = varInt)or(b.VType = varFloat)) then
  begin
    hi_setBool(Result, (hi_float(a) <> hi_float(b)));
  end else
  // (混合) 右辺を尊重して比較
  begin
    case b.VType of
      varInt    : hi_setBool( Result, (hi_int(a)   <> hi_int(b)) );
      varFloat  : hi_setBool( Result, (hi_float(a) <> hi_float(b)) );
      else        hi_setBool( Result, (hi_str(a)   <> hi_str(b)) );
    end;
  end;
end;

function hi_var_calc_Gt    (a, b: PHiValue): PHiValue;
begin
  Result := hi_var_new;

  // 整数計算か？
  if (a.VType = varInt) and (b.VType = varInt) then
  begin
      hi_setBool(Result, (a.int > b.int));
  end else
  // 数値計算か？
  if ((a.VType = varInt)or(a.VType = varFloat)) and
     ((b.VType = varInt)or(b.VType = varFloat)) then
  begin
    hi_setBool(Result, (hi_float(a) > hi_float(b)));
  end else
  // (混合) 右辺を尊重して比較
  begin
    case b.VType of
      varInt    : hi_setBool( Result, (hi_int(a)   > hi_int(b)) );
      varFloat  : hi_setBool( Result, (hi_float(a) > hi_float(b)) );
      else        hi_setBool( Result, (hi_str(a)   > hi_str(b)) );
    end;
  end;
end;

function hi_var_calc_GtEq  (a, b: PHiValue): PHiValue;
begin
  Result := hi_var_new;

  // 整数計算か？
  if (a.VType = varInt) and (b.VType = varInt) then
  begin
      hi_setBool(Result, (a.int >= b.int));
  end else
  // 数値計算か？
  if ((a.VType = varInt)or(a.VType = varFloat)) and
     ((b.VType = varInt)or(b.VType = varFloat)) then
  begin
    hi_setBool(Result, (hi_float(a) >= hi_float(b)));
  end else
  // (混合) 右辺を尊重して比較
  begin
    case b.VType of
      varInt    : hi_setBool( Result, (hi_int(a)   >= hi_int(b)) );
      varFloat  : hi_setBool( Result, (hi_float(a) >= hi_float(b)) );
      else        hi_setBool( Result, (hi_str(a)   >= hi_str(b)) );
    end;
  end;
end;

function hi_var_calc_Lt    (a, b: PHiValue): PHiValue;
begin
  Result := hi_var_new;

  // 整数計算か？
  if (a.VType = varInt) and (b.VType = varInt) then
  begin
      hi_setBool(Result, (a.int < b.int));
  end else
  // 数値計算か？
  if ((a.VType = varInt)or(a.VType = varFloat)) and
     ((b.VType = varInt)or(b.VType = varFloat)) then
  begin
    hi_setBool(Result, (hi_float(a) < hi_float(b)));
  end else
  // (混合) 右辺を尊重して比較
  begin
    case b.VType of
      varInt    : hi_setBool( Result, (hi_int(a)   < hi_int(b)) );
      varFloat  : hi_setBool( Result, (hi_float(a) < hi_float(b)) );
      else        hi_setBool( Result, (hi_str(a)   < hi_str(b)) );
    end;
  end;
end;

function hi_var_calc_LtEq  (a, b: PHiValue): PHiValue;
begin
  Result := hi_var_new;

  // 整数計算か？
  if (a.VType = varInt) and (b.VType = varInt) then
  begin
      hi_setBool(Result, (a.int <= b.int));
  end else
  // 数値計算か？
  if ((a.VType = varInt)or(a.VType = varFloat)) and
     ((b.VType = varInt)or(b.VType = varFloat)) then
  begin
    hi_setBool(Result, (hi_float(a) <= hi_float(b)));
  end else
  // (混合) 右辺を尊重して比較
  begin
    case b.VType of
      varInt    : hi_setBool( Result, (hi_int(a)   <= hi_int(b)) );
      varFloat  : hi_setBool( Result, (hi_float(a) <= hi_float(b)) );
      else        hi_setBool( Result, (hi_str(a)   <= hi_str(b)) );
    end;
  end;
end;

function hi_var_calc_Or    (a, b: PHiValue): PHiValue;
begin
  Result := hi_var_new;
  hi_setInt(Result, hi_int(a) or hi_int(b));
end;

function hi_var_calc_And   (a, b: PHiValue): PHiValue;
begin
  Result := hi_var_new;
  hi_setInt(Result, hi_int(a) and hi_int(b));
end;

function hi_var_calc_ShiftL(a, b: PHiValue): PHiValue;
begin
  Result := hi_var_new;
  hi_setInt(Result, hi_int(a) shl hi_int(b));
end;

function hi_var_calc_ShiftR(a, b: PHiValue): PHiValue;
begin
  Result := hi_var_new;
  hi_setInt(Result, hi_int(a) shr hi_int(b));
end;

function hi_var_calc_Power (a, b: PHiValue): PHiValue;
var
  m: HFloat;
begin
  Result := hi_var_new;
  try
    m := Math.Power(hi_float(a), hi_float(b));
  except
    m := 0;
  end;
  hi_setFloat(Result, m);
end;

function hi_var_calc_mod   (a, b: PHiValue): PHiValue;
begin
  Result := hi_var_new;
  hi_setFloat(Result, hi_int(a) mod hi_int(b));
end;

function hi_var_calc_plus  (a, b: PHiValue): PHiValue;
begin
  Result := hi_var_new;

  if a.VType = b.VType then
  begin
    // 整数同士なら特別 int で計算
    if a.VType = varInt then
    begin
      try
        hi_setInt(Result, a.int + b.int);
      except // overfloaw
        hi_setFloat(Result, hi_float(a) + hi_float(b));
      end;
    end else
    begin
      hi_setFloat(Result, hi_float(a) + hi_float(b));
    end;
  end else
  begin
    hi_setFloat(Result, hi_float(a) + hi_float(b));
  end;
end;

function hi_var_calc_minus  (a, b: PHiValue): PHiValue;
begin
  Result := hi_var_new;

  if a.VType = b.VType then
  begin
    // 整数同士なら特別 int で計算
    if a.VType = varInt then
    begin
      try
        hi_setInt(Result, a.int - b.int);
      except // overfloaw
        hi_setFloat(Result, hi_float(a) - hi_float(b));
      end;
    end else
    begin
      hi_setFloat(Result, hi_float(a) - hi_float(b));
    end;
  end else
  begin
    hi_setFloat(Result, hi_float(a) - hi_float(b));
  end;
end;

function hi_var_calc_div  (a, b: PHiValue): PHiValue;
var
  va, vb, v1, v2: HFloat;
begin
  Result := hi_var_new;

  va := hi_float(a);
  vb := hi_float(b);

  if vb = 0 then hi_setInt(Result, 0)
  else begin
    v1 := va / vb;
    v2 := int(v1);
    if (v1 = v2)and((Low(Integer) <= v2)and(v2 <= High(Integer))) then
      hi_setInt(Result, Trunc(v1))
    else
      hi_setFloat(Result, v1);
  end;
end;

function hi_var_calc_mul  (a, b: PHiValue): PHiValue;
begin
  Result := hi_var_new;

  if a.VType = b.VType then
  begin
    // 整数同士なら特別 int で計算
    if a.VType = varInt then
    begin
      try
        hi_setInt(Result, a.int * b.int);
      except // overfloaw
        hi_setFloat(Result, hi_float(a) * hi_float(b));
      end;
    end else
    begin
      hi_setFloat(Result, hi_float(a) * hi_float(b));
    end;
  end else
  begin
    hi_setFloat(Result, hi_float(a) * hi_float(b));
  end;
end;

//------------------------------------------------------------------------------
{$OVERFLOWCHECKS OFF}
//------------------------------------------------------------------------------

{ THimaRecord }

procedure THimaRecord.Assign(rec: thimaRecord);
begin
  rec.CopyToAll(Self);
end;

procedure THimaRecord.CopyDataTo(p: Pointer);
begin
  Move(DataPtr^, p^, FTotalByte); 
end;

procedure THimaRecord.CopyToAll(rec: THimaRecord);
begin
  // 型定義
  DataTypeCopyTo(rec);
  // データ内容
  if DataPtr <> nil then
  begin
    rec.RecordCreate;
    Move(DataPtr^, rec.DataPtr^, FTotalByte);
  end;
end;

function THimaRecord.Count: Integer;
begin
  Result := Length(FDataTypes);
end;

constructor THimaRecord.Create;
begin
  inherited;
  DataPtr := nil;
  FTotalByte := 0;
  FBufferCount := 0
end;

procedure THimaRecord.DataTypeCopyTo(rec: THimaRecord);
var
  i: Integer;
begin
  // 定義の丸ごとコピー
  SetLength(rec.FDataTypes, Length(FDataTypes));
  for i := 0 to High(FDataTypes) do
  begin
    rec.FDataTypes[i] := FDataTypes[i];
  end;
  rec.FTotalByte := FTotalByte;
end;

destructor THimaRecord.Destroy;
begin
  RecordFree;
  inherited;
end;

function THimaRecord.DumpMemory: AnsiString;
var
  v: AnsiString;
  i: Integer;
begin
  SetLength(v, TotalByte);
  Move(DataPtr^, v[1], TotalByte);
  Result := '';
  for i := 1 to Length(v) do
  begin
    if ((i-1) mod 10) = 0 then Result := Result + #13#10;
    Result := Result + IntToHexA(Ord(v[i]),2) + ',';
  end;
  Result := TrimA(Result);
end;

function THimaRecord.SetBuffer(ptr: Pointer;src:PHiValue;dtype:AnsiChar):Pointer;
begin
  if Length(FDataBuffer) <= FBufferCount then
    SetLength(FDataBuffer,5);
  FDataBuffer[FBufferCount].ptr  :=ptr;
  FDataBuffer[FBufferCount].src  :=src;
  FDataBuffer[FBufferCount].dtype:=dtype;
  Result:=FDataBuffer[FBufferCount].ptr;
  inc(FBufferCount);
end;

procedure THimaRecord.BufferClear;
var i:integer;
begin
  if FBufferCount <> 0 then
  begin
    for i:=0 to FBufferCount - 1 do begin
      FreeMem(FDataBuffer[i].ptr);
    end;
    FBufferCount := 0;
  end;
end;

procedure THimaRecord.RestoreBuffer;
var
  i:integer;
  i64:Int64;
begin
  if FBufferCount <> 0 then
  begin
    for i:=0 to FBufferCount - 1 do
    begin
      with FDataBuffer[i] do
      begin
        case dtype of
          //REC_DTYPE_4POINTER:;
          REC_DTYPE_4FLOAT: hi_setFloat(src,Psingle(ptr)^);
          REC_DTYPE_8REAL:  hi_setFloat(src,PDouble(ptr)^);
          REC_DTYPE_8INT64: hi_setIntOrFloat(src,PInt64(ptr)^);
          REC_DTYPE_8QWORD:
          begin
            i64:=pint64(ptr)^;
            if i64 < 0 then
              hi_setIntOrFloat(src,i64 - IntPower(-2,63) + IntPower(2,63))
            else
              hi_setIntOrFloat(src,i64);
          end;
        end;
      end;
    end;
  end;
  BufferClear;
end;


function THimaRecord.FindVar(const name: AnsiString): PHimaRecVarType;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to High(FDataTypes) do
  begin
    if name = FDataTypes[i].VName then
    begin
      Result := @FDataTypes[i];
    end;
  end;
end;

function THimaRecord.FindVarIndex(const name: AnsiString): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to High(FDataTypes) do
  begin
    if name = FDataTypes[i].VName then
    begin
      Result := i;
    end;
  end;
end;

function THimaRecord.GetValue(const name: AnsiString): PHiValue;
var
  i: integer;
begin
  i := FindVarIndex(name);
  if i = -1 then
  begin
    Result := nil; Exit;
  end;

  New(Result);
  GetValueIndex(i,Result);
end;

procedure THimaRecord.GetValueIndex(Index: Integer; res: PHiValue);
var
  r: PHimaRecVarType;
  ptr: Pointer;
  i:Integer;

  procedure forPointer;
  var
    str: AnsiString;
    size: Integer;
  begin
    case r.DType[i] of
      REC_DTYPE_1CHAR:    hi_setStr(Res,PAnsiChar(ptr));
      REC_DTYPE_1BYTE:    hi_setInt(Res,pbyte(ptr)^);
      REC_DTYPE_2SHORT:   hi_setInt(Res,psmallint(ptr)^);
      REC_DTYPE_2WORD:    hi_setInt(Res,pword(ptr)^);
      REC_DTYPE_4LONG:    hi_setInt(Res,plongint(ptr)^);
      REC_DTYPE_4DWORD:   hi_setInt(Res,plongword(ptr)^);
      REC_DTYPE_4FLOAT:   hi_setFloat(Res,psingle(ptr)^);
      REC_DTYPE_4POINTER: begin
        {Inc(i);
        if Length(r.DType) < i then
          hi_setInt(Res,Integer(ppointer(ptr)^))
        else begin
          ptr:=ppointer(ptr)^;
          forPointer;
        end;}
        hi_setInt(Res,Integer(ppointer(ptr)^))
      end;
      REC_DTYPE_8INT64:   hi_setIntOrFloat(Res,pint64(ptr)^);
      REC_DTYPE_8REAL:    hi_setFloat(Res,pdouble(ptr)^);
      REC_DTYPE_8QWORD:
      begin
        i:=pint64(ptr)^;
        if i < 0 then
          hi_setIntOrFloat(Res,i - IntPower(-2,63) + IntPower(2,63))
        else
          hi_setIntOrFloat(Res,i);
      end;
      REC_DTYPE__EXT:
      begin
        str:=r.DType;
        getToken_s(str,'(');
        size := StrToIntDefA(getToken_s(str,')'), 0);
        SetLength(str,size);
        Move(ptr^,PAnsiChar(str)^,size);
        hi_setStr(Res,str)
      end;
      else
        hi_setInt(Res,Integer(ppointer(ptr)^));
    end;
  end;

begin
  r := @FDataTypes[Index];

  case r.DType[1] of
    REC_DTYPE_4POINTER:begin
      ptr:=GetPointerIndex(index);
      i:=2;
      forPointer;
    end;
    REC_DTYPE_4FLOAT,
    REC_DTYPE_8REAL :
      hi_setFloat(res, GetVarFloatIndex(Index));
    REC_DTYPE_8INT64,
    REC_DTYPE_8QWORD:
      hi_setIntOrFloat(res, GetVarFloatIndex(Index));
    REC_DTYPE__EXT: begin
      hi_setstr(res,GetVarBinIndex(Index));
    end;
    else
      hi_setInt(res, GetVarNumIndex(Index));
  end;
end;

function THimaRecord.GetPointerIndex(Index: Integer): Pointer;
var
  r: PHimaRecVarType;
  pp: PAnsiChar;
begin
  r := @FDataTypes[Index];

  // 対象アドレスを得る
  pp := PAnsiChar(DataPtr);
  Inc(pp, r.Index);

  Move(pp^, result, SizeOf(Pointer));
end;

function THimaRecord.GetVarBinIndex(Index: Integer): AnsiString;
var
  r: PHimaRecVarType;
  pp: PAnsiChar;
begin
  r := @FDataTypes[Index];

  // 対象アドレスを得る
  pp := PAnsiChar(DataPtr);
  Inc(pp, r.Index);

  SetLength(result,r.dsize);
  Move(pp^, result, r.dsize);
end;

function THimaRecord.GetVarNum(const name: AnsiString): Integer;
var
  i: Integer;
begin
  i := FindVarIndex(name);
  if i < 0 then begin Result := 0; Exit; end;

  Result := GetVarNumIndex(i);
end;

function THimaRecord.GetVarNumIndex(Index: Integer): Integer;
var
  r: PHimaRecVarType;
  p: PByte;
  //--------------- for CAST
  FChar: Shortint;
  FByte: Byte;
  FInt: Smallint;
  FWord: Word;
  FLong: Longint;
  FDWord: DWORD;
begin
  r := @FDataTypes[Index];

  // 対象アドレスを得る
  p := PByte(DataPtr);
  Inc(p, r.Index);

  // バイト数の調整
  case r.DType[1] of
    REC_DTYPE_1CHAR   : begin Move(p^, FChar,   1);  Result := FChar; end;
    REC_DTYPE_1BYTE   : begin Move(p^, FByte,   1);  Result := FByte; end;
    REC_DTYPE_2SHORT  : begin Move(p^, FInt,    2);  Result := FInt;  end;
    REC_DTYPE_2WORD   : begin Move(p^, FWord,   2);  Result := FWord; end;
    REC_DTYPE_4LONG   : begin Move(p^, FLong,   4);  Result := FLong; end;
    REC_DTYPE_4DWORD,
    REC_DTYPE_4POINTER: begin Move(p^, FDWord,  4);  Result := FDWord;end;
    else Result := 0;
  end;
end;

function THimaRecord.GetVarStr(const name: AnsiString): AnsiString;
var
  i: Integer;
begin
  i := FindVarIndex(name);
  if i < 0 then begin Result := ''; Exit; end;
  Result:=GetVarStrIndex(i);
end;

function THimaRecord.GetVarStrIndex(Index: Integer): AnsiString;
var
  r: PHimaRecVarType;
  p: PAnsiChar;
begin
  r := @FDataTypes[Index];

  // 対象アドレスを得る
  p := PAnsiChar(DataPtr);
  Inc(p, r.Index);

  SetLength(Result, r.DSize);
  StrLCopy(PAnsiChar(Result), p, r.DSize);
end;

function THimaRecord.GetVarFloat(const name: AnsiString): Extended;
var
  i: Integer;
begin
  i := FindVarIndex(name);
  if i < 0 then begin Result := 0; Exit; end;

  Result := GetVarFloatIndex(i);
end;

function THimaRecord.GetVarFloatIndex(Index:Integer): Extended;
var
  r: PHimaRecVarType;
  p: PByte;
  //--------------- for CAST
  FFloat:Single;
  FReal:Real;
  FInt64:Int64;
begin
  r := @FDataTypes[Index];

  // 対象アドレスを得る
  p := PByte(DataPtr);
  Inc(p, r.Index);

  // バイト数の調整
  case r.DType[1] of
    REC_DTYPE_4FLOAT  : begin Move(p^, FFloat,  4);  Result := FFloat; end;
    REC_DTYPE_8REAL   : begin Move(p^, FReal,   8);  Result := FReal; end;
    REC_DTYPE_8INT64  : begin Move(p^, FInt64,  8);  Result := FInt64;  end;
    REC_DTYPE_8QWORD  : begin
      Move(p^, FInt64,  8);
      if FInt64 < 0 then
        Result := (FInt64 - IntPower(-2,63)) + IntPower(2,63)
      else
        Result := FInt64;
    end;
    else Result := 0;
  end;
end;

procedure THimaRecord.RecordCreate;
begin
  //構造体の作成
  if FTotalByte <= 0 then raise Exception.Create('構造体の型が未定義なのに作成しようとしました。');

  // 既に生成されていたら作成しない(0で初期化するけど)
  if DataPtr <> nil then
  begin
    ZeroMemory(DataPtr, FTotalByte);
    Exit;
  end;

  //
  DataPtr := AllocMem(FTotalByte);
end;

procedure THimaRecord.RecordFree;
begin
  //構造体の破棄
  FreeMem(DataPtr);
  BufferClear;
end;

procedure THimaRecord.SetDataTypes(DataTypes: AnsiString;for_stack: boolean = false);
var
  sl: THStringList;
  i,sz,total: Integer;
  stype, _stype, sname: AnsiString;

  function GetTypeSize(s: AnsiString): Integer;
  var a: AnsiString;
  begin
    Result := -1;
    case s[1] of
      REC_DTYPE_1CHAR,
      REC_DTYPE_1BYTE:begin
          if for_stack then
                Result := 4
          else
                Result := 1;
      end;
      REC_DTYPE_2SHORT,
      REC_DTYPE_2WORD:begin
          if for_stack then
                Result := 4
          else
                Result := 2;
      end;
      REC_DTYPE_4LONG,
      REC_DTYPE_4DWORD,
      REC_DTYPE_4FLOAT,
      REC_DTYPE_4POINTER: Result := 4;

      REC_DTYPE_8INT64,
      REC_DTYPE_8QWORD,
      REC_DTYPE_8REAL:    Result := 8;

      REC_DTYPE__EXT:
      begin
        getToken_s(s,'('); a := getToken_s(s,')');
        Result := StrToIntDefA(a, -1);
      end;
    end;
    if Result < 0 then raise HException.Create('構造体の定義エラー「' + s + '」は未定義');
  end;

begin
  // TYPE NAME, TYPE NAME ... カンマで区切って指定
  // (ex) WORD hHandle, DWORD D1, DWORD D2...
  sl := THStringList.Create;
  try
    sl.SplitText(DataTypes, ',');

    if (sl.Count > 0)and(sl.Strings[sl.Count - 1] = '') then sl.Delete(sl.Count-1);
    SetLength(FDataTypes, sl.Count);
    total := 0;
    for i := 0 to sl.Count - 1 do
    begin
      sname := TrimA(sl.Strings[i]);
      stype := TrimA(getToken_s(sname, ' '));
      if (sname<>'')and(stype='') then
      begin
        stype := sname; //sname := stype;
      end;
      stype := UpperCaseA(stype);
      _stype := stype;

      replace_dll_types(stype);
      if stype = '' then raise HException.Create('構造体の定義エラー「' + _stype + '」は未定義');

      FDataTypes[i].VName := sname;
      FDataTypes[i].DType := stype;
      sz := GetTypeSize(stype);
      FDataTypes[i].DSize := sz;
      FDataTypes[i].Index := total;
      Inc(total, sz);
    end;
    FTotalByte := total;
  finally
    sl.Free;
  end;
end;

procedure THimaRecord.SetPAnsiCharIndex(Index: Integer; pv: PAnsiChar);
var
  r: PHimaRecVarType;
  pp: PAnsiChar;
begin
  r := @FDataTypes[Index];

  // 対象アドレスを得る
  pp := PAnsiChar(DataPtr);
  Inc(pp, r.Index);

  // 文字列へのポインタ(直接)
  //pv := PAnsiChar(value);

  Move(pv, pp^, SizeOf(Pointer));
end;

procedure THimaRecord.SetPointerIndex(Index: Integer; ptr: Pointer);
var
  r: PHimaRecVarType;
  pp: PAnsiChar;
begin
  r := @FDataTypes[Index];

  // 対象アドレスを得る
  pp := PAnsiChar(DataPtr);
  Inc(pp, r.Index);

  Move(ptr, pp^, SizeOf(Pointer));
end;

procedure THimaRecord.SetValue(const name: AnsiString; value: PHiValue);
var
  i: integer;
begin
  i := FindVarIndex(name);
  if i < -1 then
  begin
    raise HException.Create('構造体への代入でメンバ「'+name+'」が見つかりません');
  end;
  SetValueIndex(i,value);
end;

procedure THimaRecord.SetValueIndex(Index: Integer; value: PHiValue);
const
  pow2_64:Extended = High(Int64)+1.0-Low(Int64);
var
  r: PHimaRecVarType;

  procedure forPointer;
  var
   //ptr:PPointer;
   fptr:psingle;
   dptr:PDouble;
   iptr:pint64;
   f   :Extended;
  begin
    case r.DType[2] of
      REC_DTYPE_1CHAR:    SetPAnsiCharIndex(Index, value^.ptr_s);
      REC_DTYPE_1BYTE,
      REC_DTYPE_2SHORT,
      REC_DTYPE_2WORD,
      REC_DTYPE_4LONG,
      REC_DTYPE_4DWORD:   SetPointerIndex(Index, Pointer(value^.int));
      REC_DTYPE_4POINTER: begin
        {GetMem(ptr,4);
        ptr^:= value^.ptr;
        SetBuffer(ptr,value,REC_DTYPE_4POINTER);
        SetPointerIndex(Index, ptr);}
        //SetPointerIndex(Index, @(value^.ptr));
        SetPointerIndex(Index, (value^.ptr));
      end;
      REC_DTYPE_4FLOAT:   begin
        if (Value^.VType = varNil) or (value^.Size = 0) then
        begin
          fptr := nil;
        end
        else if (value^.VType = varStr) and (value^.Size > 4) then
        begin
          fptr := Pointer(value^.ptr_s);
        end
        else
        begin
          GetMem(fptr,4);
          fptr^:= hi_float(value);
          SetBuffer(fptr,value,REC_DTYPE_4FLOAT);
        end;
        SetPointerIndex(Index, fptr);
      end;
      REC_DTYPE_8REAL:    begin
        if (Value^.VType = varNil) or (value^.Size = 0) then
        begin
          dptr := nil;
        end
        else if (value^.VType = varStr) and (value^.Size > 8) then
        begin
          dptr := Pointer(value^.ptr_s);
        end
        else
        begin
          GetMem(dptr,8);
          dptr^:= hi_float(value);
          SetBuffer(dptr,value,REC_DTYPE_8REAL);
        end;
        SetPointerIndex(Index, dptr);
      end;
      REC_DTYPE_8INT64,
      REC_DTYPE_8QWORD:
      begin
        if (Value^.VType = varNil) or (value^.Size = 0) then
        begin
          iptr := nil;
        end
        else if (value^.VType = varStr) and (value^.Size > 8) then
        begin
          iptr := Pointer(value^.ptr_s);
        end
        else
        begin
          f:=hi_float(value);
          while f >= pow2_64 do f := f - pow2_64;
          while f < -pow2_64 do f := f + pow2_64 + 1;
          if f > High(Int64) then f := Low(Int64)+f-High(Int64)-1;
          if f <  Low(Int64) then f := High(Int64)+f-Low(Int64)+1;
          GetMem(iptr,8);
          iptr^:= Round(f);
          SetBuffer(iptr,value,r.DType[2]);
        end;
        SetPointerIndex(Index, iptr);
      end;
      REC_DTYPE__EXT:     SetPAnsiCharIndex(Index, value^.ptr);
      else
        SetPAnsiCharIndex(Index, value^.ptr);
    end;
  end;

begin
  r := @FDataTypes[Index];
  case r.DType[1] of
    REC_DTYPE_4POINTER: forPointer;
    REC_DTYPE_4FLOAT,
    REC_DTYPE_8REAL,
    REC_DTYPE_8INT64,
    REC_DTYPE_8QWORD:   SetVarFloatIndex(Index, hi_float(value));
    REC_DTYPE__EXT:     begin
      SetVarBinIndex(index,value.ptr,value.Size);
    end;
    else SetVarNumIndex(Index, hi_int(value));
  end;
end;

procedure THimaRecord.SetVarBin(const name: AnsiString; value: Pointer;
  size: Integer);
var
  i: Integer;
begin
  i := FindVarIndex(name);
  if i < 0 then raise Exception.CreateFmt('構造体のメンバ「%s」は存在しません。',[name]);
  SetVarBinIndex(i,value,size);
end;

procedure THimaRecord.SetVarBinIndex(index: integer; value: Pointer;
  size: Integer);
var
  r: PHimaRecVarType;
  p: PAnsiChar;
begin
  r := @FDataTypes[Index];

  // 対象アドレスを得る
  p := PAnsiChar(DataPtr);
  Inc(p, r.Index);

  // オーバー分を補正
  if size > r.DSize then size := r.DSize;

  // コピー
  Move(PAnsiChar(value)^, p^, size);
end;

procedure THimaRecord.SetVarNum(const name: AnsiString; value: Integer);
var
  i: Integer;
begin
  i := FindVarIndex(name);
  if i < 0 then raise Exception.CreateFmt('構造体のメンバ「%s」は存在しません。',[name]);
  SetVarNumIndex(i, value);
end;

procedure THimaRecord.SetVarNumIndex(Index, value: Integer);
var
  r: PHimaRecVarType;
  p: PAnsiChar;
  //--------------- for CAST
  FChar: Shortint;
  FByte: Byte;
  FInt: Smallint;
  FWord: Word;
  FLong: Longint;
  FDWord: DWORD;
begin
  r := @FDataTypes[Index];

  // 対象アドレスを得る
  p := PAnsiChar(DataPtr);
  Inc(p, r.Index);

  // バイト数の調整
  case r.DType[1] of
    REC_DTYPE_1CHAR:    begin FChar := Shortint(value);Move(FChar, p^, 1); end;
    REC_DTYPE_1BYTE:    begin FByte := Byte(value);    Move(FByte, p^, 1); end;
    REC_DTYPE_2SHORT:   begin FInt  := Smallint(value);Move(FInt,  p^, 2); end;
    REC_DTYPE_2WORD:    begin FWord := WORD(value);    Move(FWord, p^, 2); end;
    REC_DTYPE_4LONG:    begin FLong := Longint(value); Move(FLong, p^, 4); end;
    REC_DTYPE_4DWORD,
    REC_DTYPE_4POINTER: begin FDWord:= DWORD(value);   Move(FDWord,p^, 4); end;
  end;
end;

procedure THimaRecord.SetVarFloat(const name: AnsiString; value: Extended);
var
  i: Integer;
begin
  i := FindVarIndex(name);
  if i < 0 then raise Exception.CreateFmt('構造体のメンバ「%s」は存在しません。',[name]);
  SetVarFloatIndex(i, value);
end;

procedure THimaRecord.SetVarFloatIndex(Index:Integer; value: Extended);
const
  pow2_64:Extended = High(Int64)+1.0-Low(Int64);
var
  r: PHimaRecVarType;
  p: PAnsiChar;
  //--------------- for CAST
  FSingle: Single;
  FDouble: Double;
  FInt64 : Int64;//なでしこの整数は32bitなので64bitは実数で処理
begin
  r := @FDataTypes[Index];

  // 対象アドレスを得る
  p := PAnsiChar(DataPtr);
  Inc(p, r.Index);

  // バイト数の調整
  case r.DType[1] of
    REC_DTYPE_4FLOAT:    begin FSingle := value;Move(Fsingle, p^, 4); end;
    REC_DTYPE_8REAL:     begin FDouble := value;Move(Fdouble, p^, 8); end;
    //以下効率、精度ともに悪し、要改善
    REC_DTYPE_8INT64,
    REC_DTYPE_8QWORD://UInt64が無いのでInt64と同じ処理
      begin
        while value >= pow2_64 do value := value - pow2_64;
        while value < -pow2_64 do value := value + pow2_64 + 1;
        if value > High(Int64) then value := Low(Int64)+value-High(Int64)-1;
        if value <  Low(Int64) then value := High(Int64)+value-Low(Int64)+1;
        Fint64  := Round(value);
        Move(Fint64, p^, 8);
      end;
    {REC_DTYPE_8QWORD:
      begin
        while value =>  Power(2,64) do value := value - Power(2,64);
        while value <   0           do value := value + Power(2,64) + 1;
        if value => Power(2,63) then value := Power(2,63) - value;

        Fint64  := Round(value);
        Move(Fint64, p^, 8);
      end;}
  end;
end;

procedure THimaRecord.SetVarStr(const name: AnsiString;const value: AnsiString);
var
  i: Integer;
begin
  i := FindVarIndex(name);
  if i < 0 then raise Exception.CreateFmt('構造体のメンバ「%s」は存在しません。',[name]);
  SetVarStrIndex(i, value);
end;

procedure THimaRecord.SetVarStrIndex(Index: Integer;const value: AnsiString);
var
  r: PHimaRecVarType;
  p: PAnsiChar;
begin
  r := @FDataTypes[Index];

  // 対象アドレスを得る
  p := PAnsiChar(DataPtr);
  Inc(p, r.Index);

  StrLCopy(p, PAnsiChar(value), r.DSize);
end;

{ THiArray }

procedure THiArray.AddFromString(s: AnsiString);
begin
  AddFromStringEx(s, ',');
end;

procedure THiArray.Assign(a: THiArray);
var
  i: Integer;
  pSrc, pDes: PHiValue;
begin
  Self.Clear;
  Self.Grow(a.Count);
  for i := 0 to a.Count - 1 do
  begin
    pDes := hi_var_new;
    pSrc := a.Items[i];
    if pSrc = nil then
    begin
      pDes := nil;
    end else
    begin
      hi_var_copyData(pSrc, pDes);
    end;
    if pDes <> nil then pDes.Registered := 1;
    Self.Items[i] := pDes;
  end;
end;

function THiArray.GetAsString: AnsiString;
var
  i: Integer;
  p: PHiValue;
begin
  // Result := join(#13#10);
  // 二次元配列を考慮する

  Result := '';

  // 基本的に行を取得
  for i := 0 to Count - 1 do
  begin
    p := Values[i];

    // 列要素があるか？
    if p = nil then
    begin
      //
    end else
    if p^.VType = varArray then
    begin
      Result := Result + hi_ary(p).JoinAsCSV(',');
    end else
    begin
      Result := Result + hi_str(p);
    end;

    // 最後に改行文字を足す
    if (i <> (Count-1)) then Result := Result + #13#10;
  end;
end;

procedure THiArray.Clear;
var
  i: Integer;
  p,p2: PHiValue;
begin
  for i := 0 to Count - 1 do
  begin
    p := Items[i];
    if p <> nil then
    begin
      //Assert( p^.Registered = 1, '未登録の配列が存在します。' );
      //
      if p^.Registered = 1 then
      begin
        if FForStack then
        begin
          if p^.VType = VarLink then
          begin
            p2 := p^.ptr;
            if p2 <> nil then
            begin
              Dec(p2.RefCount);
              if p2.RefCount < 0 then
              begin
                hi_var_free(p2);
              end;
            end;
            p^.ptr := nil;
            p^.VType  :=  varNil;
            p^.Setter :=  nil;
            p^.Getter :=  nil;
            p^.Size   :=    0;
            p^.ptr    :=  nil;
          end;
        end;
        hi_var_free(p);
      end;
    end;
  end;
  inherited Clear;
end;

procedure THiArray.ClearNotFree;
begin
  inherited Clear;
end;

function THiArray.FindKey(Key: DWORD): PHiValue;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Result := GetValue(i);
    if (Result <> nil)and(Result.VarID = Key) then
    begin
      if Result.VType = varLink then
      begin
        Result := hi_getLink(Result);
      end;
      Exit;
    end;
  end;
  Result := nil;
end;

function THiArray.GetValue(Index: Integer): PHiValue;
begin
  Result := nil;
  if (Index < Count) then
  begin
    Result := Items[Index];
  end;
  if Result = nil then
  begin
    Result := hi_var_new;
    Result.Registered := 1;
    Items[Index] := Result;
  end;
end;

function THiArray.Join(s: AnsiString): AnsiString;
var
  i: Integer;
  p: PHiValue;
begin
  Result := '';
  for i := 0 to Count - 1 do
  begin
    p := Values[i];
    Result := Result + hi_str(p);
    if (i <> (Count-1)) then Result := Result + s;
  end;
end;

procedure THiArray.SetValue(Index: Integer; const Value: PHiValue);
var
  p: PHiValue;
begin
  if Count > Index then
  begin
    p := Items[Index];
    if p <> nil then
    begin
      try
        hi_var_free(p);
      except
      end;
    end;
  end;

  if Value <> nil then
  begin
    Value.Registered := 1;
  end;
  Items[Index] := Value;

end;

function THiArray.JoinAsCSV(splitter: AnsiString): AnsiString;
var
  i: Integer;
  p: PHiValue;
  str: AnsiString;
  seq: Boolean;
begin
  Result := '';
  if Count = 0 then Exit;

  seq := False;

  // get value
  p := Values[0];
  str := hi_str(p);
  // check sequence
  if PosA('"', str) > 0 then begin
    str := JReplace(str, '"', '""');
    seq := True;
  end else
  if PosA(splitter, str) > 0 then begin
    seq := True;
  end else
  if PosA(#13#10, str) > 0 then begin
    seq := True
  end else
  if PosA(' ', str) > 0 then begin
    seq := True
  end;

  if (seq and (Count<>1)) then Result := Result + '"' + str + '"' else Result := Result + str;

  for i := 1 to Count - 1 do
  begin
    Result := Result + splitter;
    seq := False;

    // get value
    p := Values[i];
    str := hi_str(p);

    // check sequence
    if PosA('"', str) > 0 then begin
      str := JReplace(str, '"', '""');
      seq := True;
    end else
    if PosA(splitter, str) > 0 then begin
      seq := True;
    end else
    if PosA(#13#10, str) > 0 then begin
      seq := True
    end else
    if PosA(' ', str) > 0 then begin
      seq := True
    end;

    if seq then Result := Result + '"' + str + '"' else Result := Result + str;
  end;
end;

function THiArray.FindIndex(key: AnsiString; fromI: Integer): Integer;
var
  p: PHiValue;
  i: Integer;
begin
  Result := -1;
  for i := fromI to FCount - 1 do
  begin
    p := Items[i];
    if hi_str(p) = key then
    begin
      Result := i; Break;
    end;
  end;
end;

procedure THiArray.InsertArray(Index: Integer; a: THiArray);
var
  tmpArray: TPtrArray;
  idx, i, n1, n2: Integer;
  tmp: PHiValue;
begin
  // 一番大きなサイズを得る
  n1 := Count + a.Count;
  n2 := Index + a.Count;
  if n1 < n2 then n1 := n2;
  SetLength(tmpArray, n1);
  for i := 0 to High(tmpArray) do tmpArray[i] := nil;

  // 挿入していく
  for i := 0 to Count - 1 do
  begin
    if i < Index then
      tmpArray[i] := FArray[i]
    else
      tmpArray[i + a.Count] := FArray[i];
  end;
  for i := 0 to a.Count - 1 do
  begin
    tmp := hi_var_new;
    hi_var_copyData(a.Values[i], tmp);
    tmp.Registered:=1;
    tmpArray[i + Index] := tmp;
  end;

  idx:=Count+a.Count;
  SetLength(FArray, idx);
  for i := 0 to idx - 1 do
  begin
    FArray[i] := tmpArray[i];
  end;
  FCount := idx;

  tmpArray := nil;
end;

function ary_sort(A, B: Pointer): Integer; // A>B なら0以上
var
  pa,pb: PHiValue;
  sa,sb: AnsiString;
begin
  pa := A;
  pb := B;

  sa := hi_str(pa);
  sb := hi_str(pb);

  Result := StrComp(PAnsiChar(sa), PAnsiChar(sb));
end;

procedure THiArray.Sort;
begin
  QuickSort(ary_sort);
end;

function ary_sortNum(A, B: Pointer): Integer; // A>B なら0以上
var
  pa,pb: PHiValue;
  fa,fb: HFloat;
begin
  pa := A;
  pb := B;

  fa := hi_float(pa);
  fb := hi_float(pb);

  if fa = fb then Result := 0 else
  if fa > fb then Result := 1 else Result := -1;
end;

procedure THiArray.SortNum;
begin
  QuickSort(ary_sortNum);
end;

var
  sort_custom_str: AnsiString;

function ary_sort_custom(A, B: Pointer): Integer; // A>B なら0以上
var
  res, pa,pb: PHiValue;
begin
  pa := HiSystem.GetVariable(hi_tango2id('A'));
  pb := HiSystem.GetVariable(hi_tango2id('B'));

  hi_var_copyData(A, pa);
  hi_var_copyData(B, pb);

  res := HiSystem.Eval(sort_custom_str);
  Result := hi_int(res);
  hi_var_free(res);
end;


procedure THiArray.CustomSort(s: AnsiString);
var
  a,b, tmpa, tmpb: PHiValue;
begin
  // (EX) aを「A<B」で配列カスタムソートして表示。

  a := HiSystem.GetVariable(hi_tango2id('A')); tmpa := hi_var_new;
  b := HiSystem.GetVariable(hi_tango2id('B')); tmpb := hi_var_new;
  if a = nil then begin
    a := hi_var_new;
    a.VarID := hi_tango2id('A');
    HiSystem.Local.RegistVar(a);
  end;
  if b = nil then begin
    b := hi_var_new;
    b.VarID := hi_tango2id('B');
    HiSystem.Local.RegistVar(b);
  end;

  hi_var_copy(a,tmpa);
  hi_var_copy(b,tmpb);

  sort_custom_str := s;
  //QuickSort(ary_sort_custom);
  MergeSort(ary_sort_custom);

  hi_var_copy(tmpa,a);
  hi_var_copy(tmpb,b);
end;

function THiArray.CutRow(vFrom, Count: Integer): THiArray;
var
  i, c: Integer;
  p: PHiValue;
begin
  c := Count;
  i := vFrom;
  Result := THiArray.Create;
  while c > 0 do
  begin
    if Self.Count = 0 then Break;
    if i >= Self.Count then Break;
    p := Self.DeleteAndPop(i);
    Result.Add(p);
    Dec(c);
  end;
end;

function THiArray.GetAsTsv: AnsiString;
var
  i: Integer;
  p: PHiValue;
begin
  // Result := join(#13#10);
  // 二次元配列を考慮する

  Result := '';

  // 基本的に行を取得
  for i := 0 to Count - 1 do
  begin
    p := Values[i];

    // 列要素があるか？
    if p^.VType = varArray then
    begin
      Result := Result + hi_ary(p).JoinAsCSV(#9);
    end else
    begin
      Result := Result + hi_str(p);
    end;

    // 最後に改行文字を足す
    if (i <> (Count-1)) then Result := Result + #13#10;
  end;
end;

var csv_sort_index: Integer;

function csv_sort(A, B: Pointer): Integer; // A>B なら0以上
var
  pa, pb: PHiValue;
  sa, sb: AnsiString;
begin
  pa := A;
  pb := B;

  hi_ary_create(pa);
  hi_ary_create(pb);

  sa := hi_str( hi_ary(pa).GetValue(csv_sort_index) );
  sb := hi_str( hi_ary(pb).GetValue(csv_sort_index) );

  Result := StrComp(PAnsiChar(sa), PAnsiChar(sb));
end;

function csv_sort_num(A, B: Pointer): Integer; // A>B なら0以上
var
  pa, pb: PHiValue;
  fa, fb: HFloat;
begin
  pa := A;
  pb := B;

  hi_ary_create(pa);
  hi_ary_create(pb);

  fa := hi_float( hi_ary(pa).GetValue(csv_sort_index) );
  fb := hi_float( hi_ary(pb).GetValue(csv_sort_index) );

  if fa = fb then Result := 0 else
  if fa > fb then Result := 1 else Result := -1;
end;

procedure THiArray.SortCsv(Index: Integer);
begin
  csv_sort_index := Index;
  //QuickSort(csv_sort);
  MergeSort(csv_sort);
end;

procedure THiArray.SortCsvNum(Index: Integer);
begin
  csv_sort_index := Index;
  //QuickSort(csv_sort_num);
  MergeSort(csv_sort_num);
end;

function THiArray.CustomPickup(func: THiArrayPickupFunc; param: Integer): THiArray;
var
  i: Integer;
  p: PHiValue;
begin
  Result := THiArray.Create;
  for i := 0 to Count - 1 do
  begin
    p := GetValue(i);
    if func(p, param) then
    begin
      Result.Add(hi_clone(p));
    end;
  end;
end;

var
  _pickup_key: AnsiString;

function pickup_hasKey(v: PHiValue; param: Integer): Boolean; // ピックアップする場合は TRUE を返す
begin
  Result := False;
  if param < 0 then
  begin
    if PosA(_pickup_key, hi_str(v)) > 0 then
    begin
      Result := True;
    end;
  end else
  begin
    hi_ary_create(v);
    if PosA(_pickup_key, hi_str( hi_ary(v).GetValue(param) )) > 0 then
    begin
      Result := True;
    end;
  end;
end;

function pickup_isKey(v: PHiValue; param: Integer): Boolean; // ピックアップする場合は TRUE を返す
var
  i: Integer;
begin
  Result := False;
  if param < 0 then
  begin
    hi_ary_create(v);
    for i := 0 to hi_ary(v).Count - 1 do
    begin
      if hi_str(hi_ary(v).GetValue(i)) = _pickup_key then
      begin
        Result := True; Break;
      end;
    end;
  end else
  begin
    hi_ary_create(v);
    if (_pickup_key = hi_str( hi_ary(v).GetValue(param) )) then
    begin
      Result := True;
    end;
  end;
end;

function pickup_wildcard(v: PHiValue; param: Integer): Boolean; // ピックアップする場合は TRUE を返す
var
  i: Integer;
begin
  Result := False;
  if param < 0 then
  begin
    hi_ary_create(v);
    for i := 0 to hi_ary(v).Count - 1 do
    begin
      if wildcard2.IsMatch(hi_str(hi_ary(v).GetValue(i)), _pickup_key) then
      begin
        Result := True; Break;
      end;
    end;
  end else
  begin
    hi_ary_create(v);
    if wildcard2.IsMatch(hi_str( hi_ary(v).GetValue(param) ), _pickup_key) then
    begin
      Result := True;
    end;
  end;
end;

function pickup_regexp(v: PHiValue; param: Integer): Boolean; // ピックアップする場合は TRUE を返す
var
  i: Integer;
  opt: AnsiString;
begin
  Result := False;
  if param < 0 then
  begin
    hi_ary_create(v);
    opt := TrimA(hi_str(HiSystem.GetVariableS('正規表現修飾子')));
    for i := 0 to hi_ary(v).Count - 1 do
    begin
      if bregMatch(hi_str(hi_ary(v).GetValue(i)), _pickup_key, opt, nil) then
      begin
        Result := True; Break;
      end;
    end;
  end else
  begin
    hi_ary_create(v);
    if bregMatch(hi_str( hi_ary(v).GetValue(param) ), _pickup_key, opt) then
    begin
      Result := True;
    end;
  end;
end;

function THiArray.CsvPickupHasKey(s: AnsiString; Index: Integer): THiArray;
begin
  _pickup_key := s;
  Result := CustomPickup(pickup_hasKey, Index);
end;

function THiArray.CsvPickupIsKey(s: AnsiString; Index: Integer): THiArray;
begin
  _pickup_key := s;
  Result := CustomPickup(pickup_isKey, Index);
end;

function THiArray.CsvFind(Col: Integer; key: AnsiString;
  fromRow: Integer): Integer;
var
  row, i: Integer;
  p: PHiValue;
begin
  Result := -1;
  for row := fromRow to Count - 1 do
  begin
    p := GetValue(row);
    hi_ary_create(p);

    if Col < 0 then
    begin

      for i := 0 to hi_ary(p).Count - 1 do
      begin
        if hi_str( hi_ary(p).Items[i] ) = key then
        begin
          Result := row; Exit;
        end;
      end;

    end else
    begin

      if hi_str( hi_ary(p).GetValue(Col){Col >= Countと超えても大丈夫} ) = key then
      begin
        Result := row; Break;
      end;

    end;
  end;
end;

function THiArray.CsvVagueFind(Col: Integer; key: AnsiString;
  fromRow: Integer): Integer;
var
  row, i: Integer;
  p: PHiValue;
  //pat:TKWPattern;
  pickup:TStringList;
begin
  Result := -1;
  //pat:=TKWPattern.Create(key);
  pickup:= TStringList.Create;
  try
    for row := fromRow to Count - 1 do
    begin
      p := GetValue(row);
      hi_ary_create(p);

      if Col < 0 then
      begin

        for i := 0 to hi_ary(p).Count - 1 do
        begin
          if IsMatch(hi_str( hi_ary(p).Items[i] ),key,pickup) then
          begin
            Result := row; Exit;
          end;
        end;

      end else
      begin

        if IsMatch(hi_str( hi_ary(p).GetValue(Col){Col >= Countと超えても大丈夫} ),key,pickup) then
        begin
          Result := row; Break;
        end;

      end;
      pickup.Clear;
    end;
  finally
    //pat.Free;
    pickup.Free;
  end;
end;

function THiArray.GetColCount: Integer;
var
  i: Integer;
  p: PHiValue;
begin
  Result := 0; // 要素１つ
  for i := 0 to Count - 1 do
  begin
    p := Items[i];
    if p = nil then Continue;

    hi_ary_create(p);
    if hi_ary(p).Count > Result then Result := hi_ary(p).Count;
  end;
end;


procedure THiArray.AddFromStringEx(s: AnsiString; splitter: AnsiChar);
var
  p_last: PAnsiChar;
  function _getToSplitterQuote(var p: PAnsiChar): AnsiString;
  begin
    Result := '';
    Inc(p); // skip `"`
    while p < p_last do
    begin
      if StrLComp(p, '""', 2) = 0 then
      begin
        Result := Result + '"';
        Inc(p, 2); Continue;
      end else
      if p^ = '"' then
      begin
        Inc(p); // skip `"`
        Break;
      end else
      begin
        Result := Result + getOneChar(p);
      end;
    end;
    // skip SPACE
    while p^ in [' '] do Inc(p);
  end;

  function _getToSpliterNonQuote(var p: PAnsiChar): AnsiString;
  begin
    Result := '';
    while p < p_last do
    begin
      if p^ in [#13,#10,splitter] then Break;
      Result := Result + getOneChar(p,p_last);
    end;
  end;

  function _addNewRow: PHiValue;
  begin
    Result := hi_var_new;
    Result.Registered := 1;
    hi_ary_create(Result);
    Self.Add(Result);
  end;

  function _getOneCell(var p: PAnsiChar): AnsiString;
  begin
    if p = nil then
    begin
      Result := '';
      Exit;
    end;
    while (p^ = ' ') do Inc(p); // skip SPACE
    if p^ = '"' then
    begin
      Result := _getToSplitterQuote(p);
    end else
    begin
      Result := _getToSpliterNonQuote(p);
    end;
  end;

var
  p: PAnsiChar;
  cell: AnsiString;
  pRow, pCell: PHiValue;

begin
  // ガリガリCSVを読み込んで配列に追加していく
  if s = '' then Exit;
  p   := PAnsiChar(s);
  p_last := p + Length(s);
  pRow := _addNewRow;
  while p < p_last do
  begin
    // 値の取得
    cell := _getOneCell(p);
    // 行に追加
    pCell := hi_var_new;
    pCell.Registered := 1;
    hi_setStr(pCell, cell);
    hi_ary(pRow).Add(pCell);
    if p^ = splitter then
    begin
      Inc(p); // skip Splitter
      Continue;
    end;
    if p >= p_last then // last
    begin
      Break;
    end else // 改行...つまり次の行へ
    begin
      pRow := _addNewRow;
      if StrLComp(p, #13#10, 2) = 0 then // skip CRLF
      begin
        Inc(p, 2);
      end else
      if p^ in [#13,#10] then
      begin
        Inc(p) // skip CR or LF
      end
      else raise Exception.Create('CSVの記述に誤りがあります。');
    end;
  end;
  // 無意味な最終行はトリムしておく
  if hi_ary(pRow).Count = 0 then
  begin
    Delete(Count-1);
  end;
end;

procedure THiArray.SetAsTsv(const Value: AnsiString);
begin
  AddFromStringEx(Value, #9);
end;

procedure THiArray.RowColReverse;
var
  x, y: Integer;
  ary : THiArray;
begin
  ary := THiArray.Create;
  try
    for y := 0 to Self.Count - 1 do
    begin
      for x := 0 to Self.GetColCount - 1 do
      begin
        ary.Cells[x, y] := Self.Cells[y, x];
      end;
    end;
    Self.Assign(ary);
  finally
    FreeAndNil(ary);
  end;
end;

function THiArray.GetCell(Row, Col: Integer): PHiValue;
var
  p: PHiValue;
begin
  p := GetValue(Row);
  if p = nil then
  begin
    Result := nil;
    Exit;
  end;
  if Col = 0 then // 0 が指定されたときは、配列をできるだけ壊さないように配慮
  begin
    if p^.VType <> varArray then
    begin
      Result := p;
    end else
    begin
      Result := hi_ary(p).GetValue(Col{=0});
    end;
  end else
  begin
    hi_ary_create(p);
    Result := hi_ary(p).GetValue(Col);
  end;
end;

procedure THiArray.SetCell(Row, Col: Integer; const Value: PHiValue);
var
  p, v: PHiValue;
begin
  p := GetValue(Row);
  if p = nil then
  begin
    p := hi_var_new;
    Items[Row] := p;
  end;
  hi_ary_create(p);

  v := hi_var_new;
  hi_var_copy(Value, v);
  hi_ary(p).Items[Col] := v;
end;

procedure THiArray.Rotate;
var
  x, y: Integer;
  cx, cy, cw, ch: Integer;
  a: THiArray;
begin
  a := THiArray.Create;
  try
    cw := GetColCount;
    ch := Count;
    for y := 0 to ch - 1 do
    begin
      for x := 0 to cw - 1 do
      begin
        cx := ch - y - 1;
        cy := x;
        a.Cells[cy, cx] := Self.Cells[y, x];
      end;
    end;
    Self.Assign(a);
  finally
    a.Free;
  end;
end;


procedure THiArray.Add(v: PHiValue);
begin
  v.Registered := 1;
  inherited Add(v);
end;

procedure THiArray.CsvUniqCol(Col: Integer);
var
  Row, idx: Integer;
  key: AnsiString;
begin
  Row := 0;
  while Row < Count do
  begin
    key := hi_str( Cells[Row, Col] );
    while True do
    begin
      idx := CsvFind(Col, key, Row + 1);
      if idx < 0 then Break;
      Self.Delete(idx);
    end;
    Inc(Row);
  end;
end;

procedure THiArray.Delete(Index: Integer);
var
  p: PHiValue;
begin
  if Self.Count <= Index then Exit;
  p := Self.Items[Index];
  if (p <> nil) then
  begin
    try
      if p^.Registered = 1 then
      begin
        hi_var_free(p);
      end;
    except
    end;
  end;
  inherited Delete(Index);
end;



function THiArray.DeleteAndPop(Index: Integer): PHiValue;
begin
  Result := nil;
  if Self.Count <= Index then Exit;
  Result := Items[Index];
  inherited Delete(Index);
end;

function THiArray.sum: HFloat;
var
  i: Integer;
  p: PHiValue;
begin
  Result := 0;
  for i := 0 to Self.Count - 1 do
  begin
    p := Items[i];
    Result := Result + conv2float(p);
  end;
end;

function THiArray.mean: HFloat;
begin
  if Self.Count > 0 then
    Result := sum / Self.Count
  else
    Result := 0;
end;

function THiArray.stddev: HFloat;
var
  a: TDoubleArray;
begin
  // 配列に変換
  a := ToFloatArray;
  // 計算を頼む
  Result := Math.StdDev(a);
end;

function THiArray.norm: HFloat;
var
  a: TDoubleArray;
begin
  // 配列に変換
  a := ToFloatArray;
  // 計算を頼む
  Result := Math.Norm(a);
end;

function THiArray.ToFloatArray: TDoubleArray;
var
  i: Integer;
begin
  SetLength(Result, Self.Count);
  for i := 0 to Self.Count - 1 do
  begin
    Result[i] := hi_float(Items[i]);
  end;
end;

function THiArray.max: HFloat;
var
  a: TDoubleArray;
begin
  a := ToFloatArray;
  Result := Math.MaxValue(a);
end;

function THiArray.min: HFloat;
var
  a: TDoubleArray;
begin
  a := ToFloatArray;
  Result := Math.MinValue(a);
end;

function THiArray.CsvGetCol(i: Integer): PHiValue;
var
  j: Integer;
  p, pn: PHiValue;
begin
  Result := hi_var_new;
  hi_ary_create(Result);
  for j := 0 to Self.Count - 1 do
  begin
    p := GetCell(j, i);
    pn := hi_var_new;
    hi_var_copyData(p, pn);
    hi_ary(Result).Add(pn);
  end;
end;

function THiArray.PopnVariance: HFloat;
var
  a: TDoubleArray;
begin
  // 配列に変換
  a := ToFloatArray;
  // 計算を頼む
  Result := Math.PopnVariance(a);
end;

function THiArray.CsvInsCol(i: Integer; a: THiArray): PHiValue;
var
  j: Integer;
  pn, pa, pv: PHiValue;
begin
  Result := hi_var_new;
  hi_ary_create(Result);
  hi_ary(Result).Assign(Self);

  for j := 0 to a.Count - 1 do
  begin
    // 行を得る
    pn := hi_ary(Result).GetValue(j);
    // 行が配列でなければ配列にする
    hi_ary_create(pn);
    // 値を複製する
    pa := a.Items[j];
    pv := hi_var_new;
    hi_var_copyData(pa, pv);
    // 値を挿入する
    hi_ary(pn).Insert(i, pv);
  end;
end;

function THiArray.CsvDelCol(i: Integer): PHiValue;
var
  j: Integer;
  pn, pv: PHiValue;
begin
  Result := hi_var_new;
  hi_ary_create(Result);

  for j := 0 to Count - 1 do
  begin
    // 行を得る
    pn := GetValue(j);
    hi_ary_create(pn);
    // 複製する
    pv := hi_var_new;
    hi_var_copyData(pn, pv);
    hi_ary(pv).Delete(i);
    hi_ary(Result).Add(pv);
  end;
end;

procedure THiArray.TrimTop;
var
  i: Integer;
  p: PHiValue;
  s: AnsiString;
begin
  i := 0;
  while i < (Count-1) do
  begin
    p := Items[i];
    if p = nil then
    begin
      Delete(i); Continue;
    end;
    if p^.VType = varArray then
    begin
      hi_ary(p).TrimBottom;
      if hi_ary(p).Count = 0 then
      begin
        Delete(i); Continue;
      end else
      begin
        Break;
      end;
    end else
    if p^.VType = varStr then
    begin
      s := TrimA(hi_str(p));
      if s = '' then
      begin
        Delete(i); Continue;
      end else Break;
    end else
    begin
      Break;
    end;
  end;
end;

procedure THiArray.TrimBottom;
var
  i: Integer;
  p: PHiValue;
  s: AnsiString;
begin
  i := Count - 1;
  while i >= 0 do
  begin
    p := Items[i];
    if p = nil then
    begin
      Delete(i); Dec(i); Continue;
    end;
    if p^.VType = varArray then
    begin
      hi_ary(p).TrimBottom;
      if hi_ary(p).Count = 0 then
      begin
        Delete(i); Dec(i); Continue;
      end else
      begin
        Break;
      end;
    end else
    if p^.VType = varStr then
    begin
      s := TrimA(hi_str(p));
      if s = '' then
      begin
        Delete(i); Dec(i); Continue;
      end else
      begin
        Break;
      end;
    end else
    begin
      Break;
    end;
  end;
end;

procedure THiArray.Trim;
begin
  TrimBottom;
  if Count > 0 then TrimTop;
end;

function THiArray.CsvSum(idx: Integer): HFloat;
var
  p, pp: PHiValue;
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count - 1 do
  begin
    p := Items[i];
    if p = nil then Continue;
    if p^.VType = varArray then
    begin
      if hi_ary(p).Count > idx then
      begin
        pp := hi_ary(p).Values[idx];
        Result := Result + conv2float(pp);
      end;
    end;
  end;
end;

function THiArray.CsvPickupWildcard(s: AnsiString;
  Index: Integer): THiArray;
begin
  _pickup_key := s;
  Result := CustomPickup(pickup_wildcard, Index);
end;

function THiArray.CsvPickupRegExp(s: AnsiString; Index: Integer): THiArray;
begin
  _pickup_key := s;
  Result := CustomPickup(pickup_regexp, Index);
end;

{ THiHash }

constructor THiHash.Create;
begin
  inherited;
  temp := TStringList.Create;
end;

destructor THiHash.Destroy;
begin
  inherited;
  temp.Free;
end;

procedure THiHash.Assign(src: THiHash);
begin
  src.AssignTo(Self);
end;

procedure THiHash.AssignTo(Des: THiHash);
var
  tmp: THiHash;
begin
  if Des = nil then Exit;
  tmp := obj_assignTo;
  try
    Des.Clear;
    obj_assignTo := Des;
    Self.Each(subAssignTo);
  finally
    obj_assignTo := tmp;
  end;
end;

procedure THiHash.Clear;
begin
  Each(FreeItem);
  inherited;
end;

function THiHash.EnumKeys: AnsiString;
begin
  temp.Clear;
  Each(subEnumKey);
  Result := AnsiString(temp.Text);
end;

function THiHash.EnumValues: AnsiString;
begin
  temp.Clear;
  Each(subEnumValue);
  Result := AnsiString(temp.Text);
end;

function THiHash.FreeItem(item: THHashItem): Boolean;
begin
  Result := True;
  try
    if THiHashItem(item).value <> nil then
    begin
      if THiHashItem(item).value.Registered = 1 then
      begin
        hi_var_free(THiHashItem(item).value);
      end;
    end;
  except
  end;
end;

function THiHash.GetAsString: AnsiString;
begin
  temp.Clear;
  Each(subGetAsString);
  Result := AnsiString(temp.text); //trimは危険
end;

function THiHash.GetValue(key: AnsiString): PHiValue;
var
  i: THiHashItem;
begin
  //---------
  i := THiHashItem(Items[key]);
  {
  // ハッシュがなければ生成して返す？
  if i = nil then
  begin
    i := THiHashItem.Create;
    i.value := hi_var_new;
    i.value.Registered := 1;
    i.Key := key;
    Items[key] := i;
  end;
  Result := i.value;
  }
  if i <> nil then Result := i.value else Result := nil;
end;

procedure THiHash.SetFromString(const Value: AnsiString);
var
  p, p_last: PAnsiChar;
  n, v: AnsiString;
  hv: PHiValue;
begin
  p := PAnsiChar(Value);
  p_last := p + Length(Value);
  while p < p_last do
  begin
    v := getTokenCh(p, [#13,#10]);
    if p^ = #13 then Inc(p);
    if p^ = #10 then Inc(p);
    n := getToken_s(v, '=');
    if (TrimA(v) = '')and(TrimA(n) = '') then Continue; // 不要なキーは作らない
    // key = n , value = v
    hv := hi_var_new;
    hi_setStr(hv, v);
    self.SetValue(n, hv);
  end;
end;

procedure THiHash.SetValue(key: AnsiString; const Value: PHiValue);
var
  i: THiHashItem;
begin
  i := Items[key] as THiHashItem;

  if i = nil then
  begin
    i := THiHashItem.Create;
    i.value := Value;
    i.Key := key;
    Items[key] := i;
  end else
  begin
    hi_var_free(i.value);
    i.value := Value;
  end;

  i.value.Registered := 1;
end;


function THiHash.subAssignTo(item: THHashItem): Boolean;
var
  i, iTo: THiHashItem;
begin
  i := THiHashItem(item);

  // THiHashItem をコピー
  iTo := THiHashItem.Create;
  iTo.Key := i.Key;
  iTo.value := hi_clone(i.value);

  iTo.Value.Registered := 1; // ※忘れるべからず

  // 追加
  obj_assignTo.Add(iTo);

  Result := True;
end;

function THiHash.subEnumKey(item: THHashItem): Boolean;
begin
  Result := True;
  temp.add(string(item.Key));
end;

function THiHash.subEnumValue(item: THHashItem): Boolean;
begin
  Result := True;
  temp.add(string(hi_str(THiHashItem(item).value)));
end;

function THiHash.subGetAsString(item: THHashItem): Boolean;
begin
  Result := True;
  temp.add(string(item.Key + '=' + hi_str(THiHashItem(item).value)));
end;

{ THiGroup }

function THiGroup.Add(v: PHiValue): Integer;
begin
  Result := FindMemberIndex(v.VarID);
  if Result >= 0 then
  begin
    Delete(Result);
  end;
  // regist
  v.Registered := 1;
  Result := inherited Add(v);
end;

procedure THiGroup.AddMembers(src: THiGroup);
var
  i: Integer;
  v,n: PHiValue;
begin
  for i := 0 to src.Count - 1 do
  begin
    v := src.Items[i];
    n := hi_var_new;
    hi_var_copy(v, n);
    Self.Add(n);
  end;
  HiClassNameID := src.HiClassNameID;

  // DefaultValueの引継ぎ
  if src.DefaultValue <> nil then
  begin
    DefaultValue  := Self.FindMember(src.DefaultValue.VarID);
  end;

  // instanceName はコピー不要
end;

procedure THiGroup.Assign(src: THiGroup);
begin
  Self.Clear;
  HiClassNameID := src.HiClassNameID;
  AddMembers(src);
end;

procedure THiGroup.Clear;
var
  i: Integer;
  p: PHiValue;
begin
  for i := 0 to Count - 1 do
  begin
    p := Items[i];
    try
      hi_var_free(p);
    except
    end;
  end;
  inherited;
end;

constructor THiGroup.Create(InstanceVar: PHiValue);
begin
  HiClassNameID := 0;
  HiClassInstanceID := 0;
  DefaultValue := nil;
  FInstanceVar := InstanceVar;
  IsDestructorRunned := False;
end;

procedure THiGroup.Delete(Index: Integer);
var
  p: PHiValue;
begin
  p := Items[Index];
  hi_var_free(p);
  inherited;
end;

function THiGroup.EnumKeyAndVlues: AnsiString;
var
  i: Integer;
  p: PHiValue;
begin
  Result := '';
  for i := 0 to FCount - 1 do
  begin
    p := Items[i];

    Result := Result + hi_id2tango(p.VarID) + ' = ';

    // setter / getter
    if p.Setter <> nil then Result := Result + '(←)';
    if p.Getter <> nil then Result := Result + '(→)';

    // type
    Result := Result + '(' + hi_vtype2str(p) + ') ';

    // value
    Result := Result + hi_str(p) + #13#10;
  end;
end;

function THiGroup.EnumKeys: AnsiString;
var
  i: Integer;
  p: PHiValue;
begin
  Result := '';
  for i := 0 to FCount - 1 do
  begin
    p := Items[i];
    Result := Result + hi_id2tango(p.VarID) + {':' + IntToStr(p.RefCount) +} #13#10;
  end;
end;

function THiGroup.FindMember(id: DWORD): PHiValue;
var
  i: Integer;
begin
  Result := nil;
  i := FindMemberIndex(id);
  if i < 0 then Exit;
  Result := Items[i];
end;

function THiGroup.FindMemberIndex(id: DWORD): Integer;
var
  i: Integer;
  p: PHiValue;
begin
  Result := -1;
  for i := 0 to FCount - 1 do
  begin
    p := Items[i];
    if p.VarID = id then
    begin
      Result := i;
      Break;
    end;
  end;
end;

end.
