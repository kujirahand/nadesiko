unit hima_variable;

interface

uses
  Windows, SysUtils, hima_types;

//------------------------------------------------------------------------------
// 変数などで利用される型
//------------------------------------------------------------------------------
type
  HFloat  = Extended; // Cへの移植を考えるなら Double かな？
  PHFloat = ^HFloat;

  // 値の取りうる種類
  THiVType = (varNil = 0, varInt=1, varFloat=2, varStr=3, varPointer=4,
    varFunc=5, varArray=6, varHash=7, varGroup=8, varLink=9);

  // 型の宣言
  PHiValue = ^THiValue;
  THiValue = packed record
    VType       : THiVType; // 値の型
    Size        : Integer;  // 値の大きさ
    VarID       : DWORD;    // 変数名
    RefCount    : Integer;  // 参照カウント
    Setter      : PHiValue; // Setter
    Getter      : PHiValue; // Getter
    ReadOnly    : Byte;     // 定数なら 1 変数なら 0
    Registered  : Byte;     // 変数として登録した場合は1, 自動解放は0 // 配列やグループでも後々自動的に解放されるものは 1 に設定される
    Designer    : Byte;     // 誰が定義した変数か(0..User/1..System)
    Flag1       : Byte;     //
    case Byte of
    0:( int     : Longint ); // varInt
    1:( ptr     : Pointer ); // other...
    2:( ptr_s   : PAnsiChar   ); // varStr
    3:( link    : PHiValue); // varLink
  end;

// 変換→原始型
function hi_int   (v: PHiValue): Integer;
function hi_float (v: PHiValue): HFloat;
function hi_str   (v: PHiValue): AnsiString;
function hi_bool  (v: PHiValue): Boolean;
function hi_bin   (v: PHiValue): AnsiString;

// 変換←THiValue
procedure hi_setInt   (v: PHiValue; const i: Integer);
procedure hi_setFloat (v: PHiValue; const f: HFloat);
procedure hi_setStr   (v: PHiValue; const s: RawByteString);
procedure hi_setBool  (v: PHiValue; const b: Boolean);
procedure hi_setIntOrFloat(v: PHiValue; f: HFloat);

// 変数へのリンクというか参照
function hi_getLink(v: PHiValue): PHiValue;
procedure hi_setLink(v, Src: PHiValue);

// 変数の処理
function hi_var_new: PHiValue;                  // 新規値の生成(内部で利用)
procedure hi_var_clear(var v: PHiValue);        // 内容を初期化する
procedure hi_var_free(var v: PHiValue);         // 値を完全に削除する
procedure hi_var_copy     (Src, Des: PHiValue); // 変数をまるまるコピー。変数名も。（注意）
procedure hi_var_copyData (Src, Des: PHiValue); // 変数のデータ内容だけをコピー。
procedure hi_var_copyGensi(Src, Des: PHiValue); // 原始型の変数はデータ内容を、その他はポインタをコピー。
function hi_clone(v: PHiValue): PHiValue;       // 新規変数を作成しvの値をコピーして返す
procedure hi_var_copyGensiAndCheckType(Src, Des: PHiValue); // 原始型の変数はデータ内容を、その他はポインタをコピー。
procedure hi_var_ChangeType(var v: PHiValue; vType: THiVType); // 変数の型を変換する
//
function hi_newStr(s: AnsiString): PHiValue;        // 新規変数を生成して文字列をセットして返す
function hi_newInt(i: Integer): PHiValue;       // 新規変数を生成して数値をセットして返す
function hi_newBool(i: Boolean): PHiValue;       // 新規変数を生成して数値をセットして返す

// その他
function hi_vtype2str(p: PHiValue): AnsiString;

implementation

uses hima_string, hima_variable_ex, hima_function, hima_system, hima_token,
  unit_string;
var var_pool_list: THList = nil;

function hi_vtype2str(p: PHiValue): AnsiString;
begin
  if p = nil then
  begin
    Result := 'NIL'; Exit;
  end;
  case p.VType of
    varNil:     Result := 'NIL';
    varInt:     Result := '整数';
    varFloat:   Result := '実数';
    varStr:     Result := '文字列';
    varPointer: Result := 'ポインタ';
    varFunc:    Result := '関数';
    varArray:   Result := '配列';
    varHash:    Result := 'ハッシュ';
    varGroup:   Result := 'グループ';
    varLink:    Result := 'リンク';
  end;
end;

function hi_var_new: PHiValue; 
begin
  New(Result);
  ZeroMemory(Result, sizeOf(THiValue)); // 一気に zero で初期化
  Result.VarID := 0;
end;

procedure hi_setLink(v, Src: PHiValue);
begin
  // リンク作成対象をクリア
  hi_var_clear(v);
  Src := hi_getLink(Src);

  // リンク作成
  v^.VType := varLink;
  v^.ptr   := Src;
  v^.Size  := Sizeof(PHiValue);

  // Src の参照カウントを増やす
  if Src <> nil then
  begin
    Inc(Src^.RefCount);
  end;
end;

function hi_getLink(v: PHiValue): PHiValue;
begin
  Result := nil; if v = nil then Exit;

  if v.VType = varLink then
  begin
    Result := hi_getLink(v.ptr); // linik->link にも対応
  end else
  // リンク以外ならそのものを返す
  begin
    Result := v;
  end;
end;

procedure hi_var_copy(Src, Des: PHiValue);
begin
  // nil が渡されたときの処理
  if Src = nil then
  begin
    hi_var_clear(Des); Exit;
  end else
  if Des = nil then
  begin
    raise Exception.Create('変数のコピーでコピー対象にnilが渡されました。');
  end;

  // link なら link 先を得る
  if Src.VType = varLink then
  begin
    Src := hi_getLink(Src);
  end;

  // Des の内容をクリア
  if Des^.Size > 0 then hi_var_clear(Des);

  // 構造体をまるまるコピー
  // Move(Src^, Des^, SizeOf(THiValue));
  Des^.VarID    := Src^.VarID; //***
  Des^.VType    := Src^.VType;
  Des^.Size     := Src^.Size;
  Des^.Setter   := Src^.Setter;
  Des^.Getter   := Src^.Getter;
  Des^.ReadOnly := Src^.ReadOnly;
  Des^.ptr      := Src^.ptr;
  // [注意]
  // Des^.RefCount を変更してはならない
  // Des^.Registered を変更してはならない

  // 外部データがあればそれもコピー
  if Src^.Size > 0 then
  begin
    case Src^.VType of
      varFloat, varStr:
      begin
        Des^.Size  := Src^.Size;
        GetMem(Des^.ptr, Des^.Size);
        Des^.VType := Src^.VType;
        // 単純に内容をコピー
        Move(Src^.ptr^, Des^.ptr^, Src^.Size);
      end;
      varArray:
      begin
        Des^.ptr := THiArray.Create;
        THiArray(Des^.ptr).Assign(THiArray(Src^.ptr));
        THiArray(Des^.ptr).RefCount := 0;
      end;
      varHash:
      begin
        Des^.ptr := THiHash.Create;
        THiHash(Des^.ptr).Assign(THiHash(Src^.ptr));
        THiHash(Des^.ptr).RefCount := 0;
      end;
      varGroup:
      begin
        Des^.ptr := THiGroup.Create(Des);
        THiGroup(Des^.ptr).Assign(THiGroup(Src^.ptr));
        THiGroup(Des^.ptr).RefCount := 0;
      end;
      varFunc:
      begin
        // 関数は宣言部分だけをコピー。
        Des^.ptr := THiFunction.Create;
        THiFunction(Des^.ptr).Assign(THiFunction(Src^.ptr));
        THiFunction(Des^.ptr).RefCount := 0;
      end;
    end;//of case
  end;
end;

procedure hi_var_copyData(Src, Des: PHiValue);// 変数のデータ内容だけをコピー。
var
  id: DWORD;
begin
  id := Des.VarID;
  hi_var_copy(Src, Des);
  Des.VarID := id;
end;

procedure hi_var_copyGensi(Src, Des: PHiValue);// 原始型の変数はデータ内容を、その他はポインタをコピー。
begin
  // Des の内容をクリア
  if Des = nil then Des := hi_var_new;
  if Des^.Size > 0 then hi_var_clear(Des);
  if Src = nil then Exit;
  if Src.VType = varLink then Src := hi_getLink(Src);

  // 構造体をまるまるコピー
  // Move(Src^, Des^, SizeOf(THiValue));
  Des^.VType    := Src^.VType;
  Des^.Size     := Src^.Size;
  Des^.Setter   := Src^.Setter;
  Des^.Getter   := Src^.Getter;
  Des^.ReadOnly := Src^.ReadOnly;
  Des^.ptr      := Src^.ptr;
  // [注意]
  // Des^.RefCount を変更してはならない
  // Des^.Registered を変更してはならない

  // 原始型の外部データがあればそれもコピー
  if Src^.Size > 0 then
  begin
    case Src^.VType of
      varFloat, varStr:
      begin
        Des^.Size  := Src^.Size;
        GetMem(Des^.ptr, Des^.Size);
        Des^.VType := Src^.VType;
        // 単純に内容をコピー
        Move(Src^.ptr^, Des^.ptr^, Src^.Size);
      end;
      else begin
        // オブジェクトの参照を足す
        case Src^.VType of
          varFunc  : THiFunction(Src^.ptr).RefCount := THiFunction(Src^.ptr).RefCount + 1;
          varArray : THiArray   (Src^.ptr).RefCount := THiArray   (Src^.ptr).RefCount + 1;
          varHash  : THiHash    (Src^.ptr).RefCount := THiHash    (Src^.ptr).RefCount + 1;
          varGroup : THiGroup   (Src^.ptr).RefCount := THiGroup   (Src^.ptr).RefCount + 1;
        end;
      end;
    end;//of case
  end;
end;

procedure hi_var_ChangeType(var v: PHiValue; vType: THiVType); // 変数の型を変換する
var
  tmp: PHiValue;
begin
  // 変換不可能ならエラー
  if v = nil then v := hi_var_new;

  // リンク先を得る
  tmp := hi_getLink(v);

  // 型チェック
  case vType of
    varNil      : ; // 何も変換しない
    varInt      : begin
      tmp^.int := hi_int(tmp);
      tmp^.VType := varInt;
    end;
    varFloat    : hi_setFloat(tmp, hi_float(tmp));
    varStr      : hi_setStr(tmp, hi_str(tmp));
    varPointer  : tmp^.ptr := Pointer(hi_int(tmp));
    varFunc     : if tmp^.VType <> varFunc then raise Exception.Create('関数型に変換できません。');
    varArray    : hi_ary_create(tmp);
    varHash     : hi_hash_create(tmp);
    varGroup    : hi_group_create(tmp);
    varLink     : ; //if v^.VType <> varLink then raise Exception.Create('リンク型に変換できません。');
  end;
end;

procedure hi_var_copyGensiAndCheckType(Src, Des: PHiValue); // 原始型の変数はデータ内容を、その他はポインタをコピー。
begin
  case Des^.VType of
    varNil, varLink:
      begin
        hi_var_copyGensi(Src, Des);
      end;
    varInt:
      begin
        Des^.int := hi_int(Src);
      end;
    varFloat:
      begin
        hi_setFloat(Des, hi_float(Src));
      end;
    varStr:
      begin
        hi_setStr(Des, hi_str(Src));
      end;
    varPointer, varFunc:
      begin
        Des^.ptr := Pointer(hi_int(Src));
      end;
    varArray:
      begin
        hi_ary_create(Des);
        if Src^.VType = varArray then hi_ary(Des).Assign(hi_ary(Src))
                                 else hi_ary(Des).AsString := hi_str(Src);
      end;
    varHash:
      begin
        hi_hash_create(Des);
        if Src^.VType = varHash then hi_hash(Des).Assign(hi_hash(Src))
                                else hi_hash(Des).AsString := hi_str(Src);
      end;
    varGroup:
      begin
        hi_group_create(Des);
        if Src^.VType = varGroup then hi_group(Des).Assign(hi_group(Src))
                                 else raise Exception.Create('変換不可能な型です。');
      end;
  end;
end;

function hi_clone(v: PHiValue): PHiValue; // 新規変数を作成しvの値をコピーして返す
begin
  Result := hi_var_new;
  hi_var_copyData(v, Result);
end;

function hi_newStr(s: AnsiString): PHiValue;  // 新規変数を生成して文字列をセットして返す
begin
  Result := hi_var_new;
  hi_setStr(Result, s);
end;

function hi_newInt(i: Integer): PHiValue;  // 新規変数を生成して数値をセットして返す
begin
  Result := hi_var_new;
  hi_setInt(Result, i);
end;

function hi_newBool(i: Boolean): PHiValue;  // 新規変数を生成して数値をセットして返す
begin
  Result := hi_var_new;
  hi_setBool(Result, i);
end;

function hi_int(v: PHiValue): Integer;
begin

  if v = nil then
  begin
    Result := 0;
    Exit;
  end;

  case v.VType of
    varInt    : Result := v^.int;
    varFloat  : Result := Trunc( PHFloat(v^.ptr)^ );
    varStr    : Result := Trunc( HimaStrToNum(hi_str(v)) );
    varLink   : Result := hi_int(hi_getLink(v));
    else begin
      // その他の場合、一度文字列に変換し、それを整数に戻す
      Result := Trunc( HimaStrToNum( hi_str(v) ) );
    end;
  end;
end;

function hi_float(v: PHiValue): HFloat;
begin

  if v = nil then
  begin
    Result := 0;
    Exit;
  end;

  case v.VType of
    varInt    : Result := v^.int;
    varFloat  : Result := PHFloat(v^.ptr)^;
    varStr    : Result := HimaStrToNum(hi_str(v));
    varLink   : Result := hi_float(hi_getLink(v));
    else begin
      // その他の場合、一度文字列に変換し、それを数値に戻す
      Result := HimaStrToNum( hi_str(v) );
    end;
  end;
end;

function hi_bool  (v: PHiValue): Boolean;
begin
  if v = nil then begin Result := False; Exit; end;
  case v^.VType of
    varNil:   Result := False;
    varInt:   Result := (v.int <> 0);
    varFloat: Result := (hi_float(v) <> 0);
    varStr:   Result := (hi_str(v) <> '');
    varLink:  Result := hi_bool(hi_getLink(v));
    else
      begin
        Result := (hi_str(v) <> '');
      end;
  end;
end;

function hi_str(v: PHiValue): AnsiString;
begin
  if v = nil then begin Result := ''; Exit; end;
  try
    // 変数の型によって変換を行う
    case v.VType of
      varInt    : Result := IntToStrA(hi_int(v));
      varFloat  : Result := FloatToStrA(hi_float(v));
      varLink   : Result := hi_str(hi_getLink(v));
      varArray  : Result := THiArray(v.ptr).AsString;
      varHash   : Result := THiHash(v.ptr).AsString;
      varStr    :
        begin
          // 文字列データとしてそのまま値を返す(#0も含めることができる)
          if v.Size > 0 then
          begin
            SetLength(Result, v.Size);        // 領域の確保
            Move(v.ptr^, Result[1], v.Size);   // 結果をコピー

            // 最後の一文字がヌルなら削る(null文字列対策)
            if Result[v.Size] = #0 then
            begin
              System.Delete(Result, v.Size, 1);
            end;

          end else
          begin
            Result := '';
          end;
        end;
      else
        begin
          Result := '';
        end;
    end;//of case
  except
    raise;
  end;
end;

function hi_bin   (v: PHiValue): AnsiString;
begin
  // 変数の型によって変換を行う
  case v^.VType of
    varStr:
      begin
        // 文字列データとしてそのまま値を返す(#0も含めることができる)
        // 忠実にデータの内容を得る(文字列は＃０を考慮する処理が入る)
        if v^.Size > 0 then
        begin
          SetLength(Result, v^.Size);        // 領域の確保
          Move(v^.ptr^, Result[1], v^.Size); // 結果をコピー
        end else
        begin
          Result := '';
        end;
      end;
    varLink: Result := hi_bin(hi_getLink(v));
    else
      begin
        Result := hi_str(v);
      end;
  end;//of case
end;

procedure hi_var_clear(var v: PHiValue);

  procedure _ref_free;
  var
    p: Pointer;
  begin
    p := v.ptr;
    if p = nil then Exit;

    case v.VType of
      varFunc:
        begin
          THiFunction(p).RefCount := THiFunction(p).RefCount - 1;
          if THiFunction(p).RefCount < 0 then FreeAndNil( THiFunction(p) );
        end;
      varArray:
        begin
          THiArray(p).RefCount := THiArray(p).RefCount - 1;
          if THiArray(p).RefCount < 0 then FreeAndNil( THiArray(p) );
        end;
      varHash:
        begin
          THiHash(p).RefCount := THiHash(p).RefCount - 1;
          if THiHash(p).RefCount < 0 then FreeAndNil( THiHash(p) );
        end;
      varGroup:
        begin
          THiGroup(p).RefCount := THiGroup(p).RefCount - 1;
          if THiGroup(p).RefCount < 0 then
          begin
            { // エラー続発のため、HiSystem.Free にて実装
            if not THiGroup(p).IsDestructorRunned then
            begin
              THiGroup(p).IsDestructorRunned := True;
              HiSystem.RunGroupEvent(v, token_kowasu);
            end;
            }
            FreeAndNil( THiGroup(p) );
          end;
        end;
    end;
  end;

  procedure _freeLink; // for varLink
  var v2: PHiValue;
  begin
    // 参照先の RefCount を減らす
    v2 := hi_getLink(v);
    if v2 <> nil then
    begin
      Dec(v2.RefCount);

      if v2.RefCount < 0 then
      begin
        hi_var_free(v2);
      end;

    end;
  end;

begin
  if v = nil then begin v := hi_var_new; Exit; end;
  if v.Size > 0 then
  begin
    // データメモリの解放
    case v.VType of
      varFloat, varStr                      : FreeMem(v.ptr);
      varArray, varHash, varFunc, varGroup  : _ref_free;
      varLink                               : _freeLink;
    end; // of case
    v.ptr := nil;
    v.Size := 0;
  end else
  begin
    // 値の初期化
    if v.VType = varLink then _freeLink;
    v.ptr := nil;
  end;

  v.VType  :=  varNil;
  v.Setter :=  nil;
  v.Getter :=  nil;
  v.Size   :=    0;
  v.ptr    :=  nil;
end;

procedure hi_var_free(var v: PHiValue);  // 値を完全に削除する
var
  id: DWORD;
begin
  if v = nil then Exit;

  id := v.VarID;

  try
    hi_var_clear(v);
    if v.RefCount <= 0 then
    begin
      Dispose(v);
    end;
  except
    v := nil; if id = 0 then Exit;
    //<デバッグ用>
    raise HException.Create('変数削除エラー。' + IntToStrA(id) + ':' + hi_id2tango(id));
    //</デバッグ用>
  end;

  v := nil;
end;

procedure hi_setInt  (v: PHiValue; const i: Integer);
begin
  if v.VType <> varInt then
  begin
    hi_var_clear(v);
    v.VType := varInt;
  end;
  v.int   := i;
end;

procedure hi_setIntOrFloat(v: PHiValue; f: HFloat);
var
  i: Integer;
begin
  if (Low(Integer) <= f) and (f <= High(Integer)) then
  begin
    i := Trunc(f);
    if i = f then
    begin
      hi_setInt(v, i);
    end else
    begin
      hi_setFloat(v, f);
    end;
  end else
  begin
    hi_setFloat(v, f);
  end;
end;

procedure hi_setFloat(v: PHiValue; const f: HFloat);
begin
  if v.VType <> varFloat then
  begin
    hi_var_clear(v);
    v.VType := varFloat;
    v.Size := SizeOf(HFloat);
    GetMem(v.ptr, v.Size);
  end;
  PHFloat(v.ptr)^ := f;
end;

procedure hi_setStr(v: PHiValue; const s: RawByteString);
begin
  hi_var_clear(v);
  v.VType := varStr;

  if s = '' then
  begin
    v.ptr   := nil;
    v.Size  :=   0;
    Exit;
  end;

  v.Size := Length(s) + 1; // NULL文字列にも対応できるように！

  // 領域を確保
  GetMem(v.ptr, v.Size);
  ZeroMemory(v.ptr, v.Size); // 末尾まで全部"0"

  // Chr(0) もコピーできるようにメモリをそのままコピー
  Move(s[1], v.ptr^, v.Size - 1);
end;

procedure hi_setBool (v: PHiValue; const b: Boolean);
begin
  if v^.Size > 0 then hi_var_clear(v);
  v^.VType := varInt;

  if b then v^.int := 1 else v^.int := 0;
end;

end.
