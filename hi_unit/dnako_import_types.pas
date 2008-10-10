unit dnako_import_types;

interface

uses
  Windows;

//------------------------------------------------------------------------------
// 変数などで利用される型
//------------------------------------------------------------------------------
type
  HFloat  = Extended;
  PHFloat = ^HFloat;

  // 値の取りうる種類
  THiVType = (varNil = 0, varInt=1, varFloat=2, varStr=3, varPointer=4,
    varFunc=5, varArray=6, varHash=7, varGroup=8, varLink=9);

  // 型の宣言
  PHiValue = ^THiValue;
  THiValue = packed record
    VType    : THiVType; // 値の型
    Size     : Integer;  // 値の大きさ
    VarID    : DWORD;    // 変数名
    RefCount : Integer;  // 参照カウント for GC
    Setter   : PHiValue; // Setter
    Getter   : PHiValue; // Getter
    ReadOnly : Byte;     // ReadOnly = 1
    Registered : Byte;   // 解放してよい値か？(これが1なら勝手に解放してはならない)
    Flag1    : Byte;
    Flag2    : Byte;
    case Byte of
    0:( int    : Longint ); // varInt
    1:( ptr    : Pointer ); // other...
    2:( ptr_s  : PChar   ); // varStr
  end;

  // コールバック関数
  THimaSysFunction = function (HandleArg: DWORD): PHiValue; stdcall;

//------------------------------------------------------------------------------
// 新規変数の生成
function hi_var_new(name: string = ''): PHiValue;
// 新規変数を生成する
function hi_clone(v: PHiValue): PHiValue; // 関数とまったく同じものを生成する
function hi_newInt(value: Integer): PHiValue; // 新規整数
function hi_newStr(value: string): PHiValue;  // 新規文字列
function hi_newFloat(value: HFloat): PHiValue;// 新規文字列
function hi_newBool(value: Bool): PHiValue;// 新規BOOL
// 整数をセットする
procedure hi_setInt  (v: PHiValue; num: Integer);
procedure hi_setFloat(v: PHiValue; num: HFloat);
// BOOL型をセットする
procedure hi_setBool (v: PHiValue; b: Boolean);
// 文字列をセットする
procedure hi_setStr  (v: PHiValue; s: string);
// キャストして使えるように
function hi_bool (value: PHiValue): Boolean;
function hi_int  (value: PHiValue): Integer;
function hi_float(value: PHiValue): HFloat;
function hi_str  (p: PHiValue): string;
function hi_hashKeys(p: PHiValue): string;

implementation

uses
  dnako_import, SysUtils;


function var2str(p: PHiValue): string;
begin
  Result := hi_str(p);
end;

function hi_str(p: PHiValue): string;
const MAX_STR = 255;
var
  len: DWORD;
begin
  if p = nil then
  begin
    Result := ''; Exit;
  end;

  // 適当に確保して文字列をコピー
  SetLength(Result, MAX_STR+1);
  len := nako_var2str(p, @Result[1], MAX_STR);

  if len > MAX_STR then
  begin
    SetLength(Result, len);
    nako_var2str(p, @Result[1], len);
  end else
  begin
    if len = 0 then
    begin
      Result := ''; Exit;
    end;
    SetLength(Result, len); // リサイズ
  end;
end;

function hi_hashKeys(p: PHiValue): string;
var
  s: string;
begin
  SetLength(s, 1024 * 16);
  nako_hash_keys(p, PChar(s), Length(s));
  Result := Trim(s);
end;

function hi_var_new(name: string = ''): PHiValue;
begin
  if name = '' then
    Result := nako_var_new(nil)
  else
    Result := nako_var_new(PChar(name));
end;

function hi_clone(v: PHiValue): PHiValue;
begin
  Result := hi_var_new;
  nako_varCopyGensi(v, Result);
end;

function hi_newInt(value: Integer): PHiValue;
begin
  Result := hi_var_new;
  hi_setInt(Result, value);
end;

function hi_newStr(value: string): PHiValue;
begin
  Result := hi_var_new;
  hi_setStr(Result, value);
end;

function hi_newFloat(value: HFloat): PHiValue;// 新規文字列
begin
  Result := hi_var_new;
  hi_setFloat(Result, value);
end;

function hi_newBool(value: Bool): PHiValue;// 新規BOOL
begin
  Result := hi_var_new;
  hi_setBool(Result, value);
end;

procedure hi_setInt(v: PHiValue; num: Integer);
begin
  nako_int2var(num, v);
end;

procedure hi_setFloat(v: PHiValue; num: HFloat);
begin
  nako_double2var(num, v);
end;

procedure hi_setBool(v: PHiValue; b: Boolean);
begin
  if b then
    nako_int2var(1, v)
  else
    nako_int2var(0, v);
end;

function hi_bool(value: PHiValue): Boolean;
begin
  Result := (nako_var2int(value) <> 0);
end;

function hi_int(value: PHiValue): Integer;
begin
  Result := nako_var2int(value);
end;

function hi_float(value: PHiValue): HFloat;
begin
  Result := nako_var2double(value);
end;

procedure hi_setStr(v: PHiValue; s: string);
begin
  if s = '' then
  begin
    nako_str2var(PChar(s), v);
  end else
  begin
    nako_bin2var(@s[1], Length(s), v);
  end;
end;


end.
