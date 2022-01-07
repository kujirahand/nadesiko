unit hima_variable;

interface

uses
  {$IFDEF Win32}
  Windows, 
  {$ELSE}
  {$ENDIF}
  SysUtils, hima_types;

//------------------------------------------------------------------------------
// �ϐ��Ȃǂŗ��p�����^
//------------------------------------------------------------------------------
type
  HFloat  = Extended; // C�ւ̈ڐA���l����Ȃ� Double ���ȁH
  PHFloat = ^HFloat;

  // �l�̎�肤����
  THiVType = (varNil = 0, varInt=1, varFloat=2, varStr=3, varPointer=4,
    varFunc=5, varArray=6, varHash=7, varGroup=8, varLink=9);

  // �^�̐錾
  PHiValue = ^THiValue;
  THiValue = packed record
    VType       : THiVType; // �l�̌^
    Size        : Integer;  // �l�̑傫��
    VarID       : DWORD;    // �ϐ���
    RefCount    : Integer;  // �Q�ƃJ�E���g
    Setter      : PHiValue; // Setter
    Getter      : PHiValue; // Getter
    ReadOnly    : Byte;     // �萔�Ȃ� 1 �ϐ��Ȃ� 0
    Registered  : Byte;     // �ϐ��Ƃ��ēo�^�����ꍇ��1, ���������0 // �z���O���[�v�ł���X�����I�ɉ���������̂� 1 �ɐݒ肳���
    Designer    : Byte;     // �N����`�����ϐ���(0..User/1..System)
    Flag1       : Byte;     //
    case Byte of
    0:( int     : Longint ); // varInt
    1:( ptr     : Pointer ); // other...
    2:( ptr_s   : PAnsiChar   ); // varStr
    3:( link    : PHiValue); // varLink
  end;

// �ϊ������n�^
function hi_int   (v: PHiValue): Integer;
function hi_float (v: PHiValue): HFloat;
function hi_str   (v: PHiValue): AnsiString;
function hi_bool  (v: PHiValue): Boolean;
function hi_bin   (v: PHiValue): AnsiString;

// �ϊ���THiValue
procedure hi_setInt   (v: PHiValue; const i: Integer);
procedure hi_setFloat (v: PHiValue; const f: HFloat);
procedure hi_setStr   (v: PHiValue; const s: string);
procedure hi_setBool  (v: PHiValue; const b: Boolean);
procedure hi_setIntOrFloat(v: PHiValue; f: HFloat);

// �ϐ��ւ̃����N�Ƃ������Q��
function hi_getLink(v: PHiValue): PHiValue;
procedure hi_setLink(v, Src: PHiValue);

// �ϐ��̏���
function hi_var_new: PHiValue;                  // �V�K�l�̐���(�����ŗ��p)
procedure hi_var_clear(var v: PHiValue);        // ���e������������
procedure hi_var_free(var v: PHiValue);         // �l�����S�ɍ폜����
procedure hi_var_copy     (Src, Des: PHiValue); // �ϐ����܂�܂�R�s�[�B�ϐ������B�i���Ӂj
procedure hi_var_copyData (Src, Des: PHiValue); // �ϐ��̃f�[�^���e�������R�s�[�B
procedure hi_var_copyGensi(Src, Des: PHiValue); // ���n�^�̕ϐ��̓f�[�^���e���A���̑��̓|�C���^���R�s�[�B
function hi_clone(v: PHiValue): PHiValue;       // �V�K�ϐ����쐬��v�̒l���R�s�[���ĕԂ�
procedure hi_var_copyGensiAndCheckType(Src, Des: PHiValue); // ���n�^�̕ϐ��̓f�[�^���e���A���̑��̓|�C���^���R�s�[�B
procedure hi_var_ChangeType(var v: PHiValue; vType: THiVType); // �ϐ��̌^��ϊ�����
//
function hi_newStr(s: AnsiString): PHiValue;        // �V�K�ϐ��𐶐����ĕ�������Z�b�g���ĕԂ�
function hi_newInt(i: Integer): PHiValue;       // �V�K�ϐ��𐶐����Đ��l���Z�b�g���ĕԂ�
function hi_newBool(i: Boolean): PHiValue;       // �V�K�ϐ��𐶐����Đ��l���Z�b�g���ĕԂ�

// ���̑�
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
    varInt:     Result := '����';
    varFloat:   Result := '����';
    varStr:     Result := '������';
    varPointer: Result := '�|�C���^';
    varFunc:    Result := '�֐�';
    varArray:   Result := '�z��';
    varHash:    Result := '�n�b�V��';
    varGroup:   Result := '�O���[�v';
    varLink:    Result := '�����N';
  end;
end;

function hi_var_new: PHiValue; 
begin
  New(Result);
  {$IFDEF Win32}
  ZeroMemory(Result, SizeOf(THiValue)); // ��C�� zero �ŏ�����
  {$ELSE}
  FillByte(Result^, 0, SizeOf(THiValue));
  {$IFEND}
  Result.VarID := 0;
end;

procedure hi_setLink(v, Src: PHiValue);
begin
  // �����N�쐬�Ώۂ��N���A
  hi_var_clear(v);
  Src := hi_getLink(Src);

  // �����N�쐬
  v^.VType := varLink;
  v^.ptr   := Src;
  v^.Size  := Sizeof(PHiValue);

  // Src �̎Q�ƃJ�E���g�𑝂₷
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
    Result := hi_getLink(v.ptr); // linik->link �ɂ��Ή�
  end else
  // �����N�ȊO�Ȃ炻�̂��̂�Ԃ�
  begin
    Result := v;
  end;
end;

procedure hi_var_copy(Src, Des: PHiValue);
begin
  // nil ���n���ꂽ�Ƃ��̏���
  if Src = nil then
  begin
    hi_var_clear(Des); Exit;
  end else
  if Des = nil then
  begin
    raise Exception.Create('�ϐ��̃R�s�[�ŃR�s�[�Ώۂ�nil���n����܂����B');
  end;

  // link �Ȃ� link ��𓾂�
  if Src.VType = varLink then
  begin
    Src := hi_getLink(Src);
  end;

  // Des �̓��e���N���A
  if Des^.Size > 0 then hi_var_clear(Des);

  // �\���̂��܂�܂�R�s�[
  // Move(Src^, Des^, SizeOf(THiValue));
  Des^.VarID    := Src^.VarID; //***
  Des^.VType    := Src^.VType;
  Des^.Size     := Src^.Size;
  Des^.Setter   := Src^.Setter;
  Des^.Getter   := Src^.Getter;
  Des^.ReadOnly := Src^.ReadOnly;
  Des^.ptr      := Src^.ptr;
  // [����]
  // Des^.RefCount ��ύX���Ă͂Ȃ�Ȃ�
  // Des^.Registered ��ύX���Ă͂Ȃ�Ȃ�

  // �O���f�[�^������΂�����R�s�[
  if Src^.Size > 0 then
  begin
    case Src^.VType of
      varFloat, varStr:
      begin
        Des^.Size  := Src^.Size;
        GetMem(Des^.ptr, Des^.Size);
        Des^.VType := Src^.VType;
        // �P���ɓ��e���R�s�[
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
        // �֐��͐錾�����������R�s�[�B
        Des^.ptr := THiFunction.Create;
        THiFunction(Des^.ptr).Assign(THiFunction(Src^.ptr));
        THiFunction(Des^.ptr).RefCount := 0;
      end;
    end;//of case
  end;
end;

procedure hi_var_copyData(Src, Des: PHiValue);// �ϐ��̃f�[�^���e�������R�s�[�B
var
  id: DWORD;
begin
  id := Des.VarID;
  hi_var_copy(Src, Des);
  Des.VarID := id;
end;

procedure hi_var_copyGensi(Src, Des: PHiValue);// ���n�^�̕ϐ��̓f�[�^���e���A���̑��̓|�C���^���R�s�[�B
begin
  // Des �̓��e���N���A
  if Des = nil then Des := hi_var_new;
  if Des^.Size > 0 then hi_var_clear(Des);
  if Src = nil then Exit;
  if Src.VType = varLink then Src := hi_getLink(Src);

  // �\���̂��܂�܂�R�s�[
  // Move(Src^, Des^, SizeOf(THiValue));
  Des^.VType    := Src^.VType;
  Des^.Size     := Src^.Size;
  Des^.Setter   := Src^.Setter;
  Des^.Getter   := Src^.Getter;
  Des^.ReadOnly := Src^.ReadOnly;
  Des^.ptr      := Src^.ptr;
  // [����]
  // Des^.RefCount ��ύX���Ă͂Ȃ�Ȃ�
  // Des^.Registered ��ύX���Ă͂Ȃ�Ȃ�

  // ���n�^�̊O���f�[�^������΂�����R�s�[
  if Src^.Size > 0 then
  begin
    case Src^.VType of
      varFloat, varStr:
      begin
        Des^.Size  := Src^.Size;
        GetMem(Des^.ptr, Des^.Size);
        Des^.VType := Src^.VType;
        // �P���ɓ��e���R�s�[
        Move(Src^.ptr^, Des^.ptr^, Src^.Size);
      end;
      else begin
        // �I�u�W�F�N�g�̎Q�Ƃ𑫂�
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

procedure hi_var_ChangeType(var v: PHiValue; vType: THiVType); // �ϐ��̌^��ϊ�����
var
  tmp: PHiValue;
begin
  // �ϊ��s�\�Ȃ�G���[
  if v = nil then v := hi_var_new;

  // �����N��𓾂�
  tmp := hi_getLink(v);

  // �^�`�F�b�N
  case vType of
    varNil      : ; // �����ϊ����Ȃ�
    varInt      : begin
      tmp^.int := hi_int(tmp);
      tmp^.VType := varInt;
    end;
    varFloat    : hi_setFloat(tmp, hi_float(tmp));
    varStr      : hi_setStr(tmp, hi_str(tmp));
    varPointer  : tmp^.ptr := Pointer(hi_int(tmp));
    varFunc     : if tmp^.VType <> varFunc then raise Exception.Create('�֐��^�ɕϊ��ł��܂���B');
    varArray    : hi_ary_create(tmp);
    varHash     : hi_hash_create(tmp);
    varGroup    : hi_group_create(tmp);
    varLink     : ; //if v^.VType <> varLink then raise Exception.Create('�����N�^�ɕϊ��ł��܂���B');
  end;
end;

procedure hi_var_copyGensiAndCheckType(Src, Des: PHiValue); // ���n�^�̕ϐ��̓f�[�^���e���A���̑��̓|�C���^���R�s�[�B
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
                                 else raise Exception.Create('�ϊ��s�\�Ȍ^�ł��B');
      end;
  end;
end;

function hi_clone(v: PHiValue): PHiValue; // �V�K�ϐ����쐬��v�̒l���R�s�[���ĕԂ�
begin
  Result := hi_var_new;
  hi_var_copyData(v, Result);
end;

function hi_newStr(s: AnsiString): PHiValue;  // �V�K�ϐ��𐶐����ĕ�������Z�b�g���ĕԂ�
begin
  Result := hi_var_new;
  hi_setStr(Result, s);
end;

function hi_newInt(i: Integer): PHiValue;  // �V�K�ϐ��𐶐����Đ��l���Z�b�g���ĕԂ�
begin
  Result := hi_var_new;
  hi_setInt(Result, i);
end;

function hi_newBool(i: Boolean): PHiValue;  // �V�K�ϐ��𐶐����Đ��l���Z�b�g���ĕԂ�
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
      // ���̑��̏ꍇ�A��x������ɕϊ����A����𐮐��ɖ߂�
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
      // ���̑��̏ꍇ�A��x������ɕϊ����A����𐔒l�ɖ߂�
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
    // �ϐ��̌^�ɂ���ĕϊ����s��
    case v.VType of
      varInt    : Result := IntToStrA(hi_int(v));
      varFloat  : Result := FloatToStrA(hi_float(v));
      varLink   : Result := hi_str(hi_getLink(v));
      varArray  : Result := THiArray(v.ptr).AsString;
      varHash   : Result := THiHash(v.ptr).AsString;
      varStr    :
        begin
          // ������f�[�^�Ƃ��Ă��̂܂ܒl��Ԃ�(#0���܂߂邱�Ƃ��ł���)
          if v.Size > 0 then
          begin
            SetLength(Result, v.Size);        // �̈�̊m��
            Move(v.ptr^, Result[1], v.Size);   // ���ʂ��R�s�[

            // �Ō�̈ꕶ�����k���Ȃ���(null������΍�)
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
  // �ϐ��̌^�ɂ���ĕϊ����s��
  case v^.VType of
    varStr:
      begin
        // ������f�[�^�Ƃ��Ă��̂܂ܒl��Ԃ�(#0���܂߂邱�Ƃ��ł���)
        // �����Ƀf�[�^�̓��e�𓾂�(������́��O���l�����鏈��������)
        if v^.Size > 0 then
        begin
          SetLength(Result, v^.Size);        // �̈�̊m��
          Move(v^.ptr^, Result[1], v^.Size); // ���ʂ��R�s�[
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
            { // �G���[�����̂��߁AHiSystem.Free �ɂĎ���
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
    // �Q�Ɛ�� RefCount �����炷
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
    // �f�[�^�������̉��
    case v.VType of
      varFloat, varStr                      : FreeMem(v.ptr);
      varArray, varHash, varFunc, varGroup  : _ref_free;
      varLink                               : _freeLink;
    end; // of case
    v.ptr := nil;
    v.Size := 0;
  end else
  begin
    // �l�̏�����
    if v.VType = varLink then _freeLink;
    v.ptr := nil;
  end;

  v.VType  :=  varNil;
  v.Setter :=  nil;
  v.Getter :=  nil;
  v.Size   :=    0;
  v.ptr    :=  nil;
end;

procedure hi_var_free(var v: PHiValue);  // �l�����S�ɍ폜����
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
    //<�f�o�b�O�p>
    raise HException.Create('�ϐ��폜�G���[�B' + IntToStrA(id) + ':' + hi_id2tango(id));
    //</�f�o�b�O�p>
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

procedure hi_setStr(v: PHiValue; const s: string);
begin
  hi_var_clear(v);
  v.VType := varStr;

  if s = '' then
  begin
    v.ptr   := nil;
    v.Size  :=   0;
    Exit;
  end;

  v.Size := Length(s) + 1; // NULL������ɂ��Ή��ł���悤�ɁI

  // �̈���m��
  GetMem(v.ptr, v.Size);
  {$IFDEF Win32}
  ZeroMemory(v.ptr, v.Size); // �����܂őS��"0"
  {$ELSE}
  FillByte(v.ptr^, 0, v.Size);
  {$IFEND}

  // Chr(0) ���R�s�[�ł���悤�Ƀ����������̂܂܃R�s�[
  Move(s[1], v.ptr^, v.Size - 1);
end;

procedure hi_setBool (v: PHiValue; const b: Boolean);
begin
  if v^.Size > 0 then hi_var_clear(v);
  v^.VType := varInt;

  if b then v^.int := 1 else v^.int := 0;
end;

end.
