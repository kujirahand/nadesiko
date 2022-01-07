unit dnako_import_types;

interface

uses
  {$IFDEF Win32}
  Windows,
  {$ELSE}
  {$ENDIF}
  SysUtils
  ;

//------------------------------------------------------------------------------
// �ϐ��Ȃǂŗ��p�����^
//------------------------------------------------------------------------------
{$IFDEF FPC}
type
  Bool = Boolean;
{$ELSE}
{$ENDIF}

type
  HFloat  = Extended;
  PHFloat = ^HFloat;

  // �l�̎�肤����
  THiVType = (varNil = 0, varInt=1, varFloat=2, varStr=3, varPointer=4,
    varFunc=5, varArray=6, varHash=7, varGroup=8, varLink=9);

  // �^�̐錾
  PHiValue = ^THiValue;
  THiValue = packed record
    VType    : THiVType; // �l�̌^
    Size     : Integer;  // �l�̑傫��
    VarID    : DWORD;    // �ϐ���
    RefCount : Integer;  // �Q�ƃJ�E���g for GC
    Setter   : PHiValue; // Setter
    Getter   : PHiValue; // Getter
    ReadOnly : Byte;     // ReadOnly = 1
    Registered : Byte;   // ������Ă悢�l���H(���ꂪ1�Ȃ珟��ɉ�����Ă͂Ȃ�Ȃ�)
    Flag1    : Byte;
    Flag2    : Byte;
    case Byte of
    0:( int    : Longint ); // varInt
    1:( ptr    : Pointer ); // other...
    2:( ptr_s  : PChar   ); // varStr
  end;

  // �R�[���o�b�N�֐�
  THimaSysFunction = function (HandleArg: DWORD): PHiValue; stdcall;

//------------------------------------------------------------------------------
// �V�K�ϐ��̐���
function hi_var_new(name: AnsiString = ''): PHiValue;
// �V�K�ϐ��𐶐�����
function hi_clone(v: PHiValue): PHiValue; // �֐��Ƃ܂������������̂𐶐�����
function hi_newInt(value: Integer): PHiValue; // �V�K����
function hi_newStr(value: AnsiString): PHiValue;  // �V�K������
function hi_newStrU(value: string): PHiValue;  // �V�K������
function hi_newFloat(value: HFloat): PHiValue;// �V�K������
function hi_newBool(value: Bool): PHiValue;// �V�KBOOL
// �������Z�b�g����
procedure hi_setInt  (v: PHiValue; num: Integer);
procedure hi_setFloat(v: PHiValue; num: HFloat);
// BOOL�^���Z�b�g����
procedure hi_setBool (v: PHiValue; b: Boolean);
// ��������Z�b�g����
procedure hi_setStr  (v: PHiValue; s: AnsiString);
procedure hi_setStrU (v: PHiValue; s: string);
// �L���X�g���Ďg����悤��
function hi_bool (value: PHiValue): Boolean;
function hi_int  (value: PHiValue): Integer;
function hi_float(value: PHiValue): HFloat;
function hi_str  (p: PHiValue): AnsiString;
function hi_strU (p: PHiValue): string;
function hi_hashKeys(p: PHiValue): AnsiString;

implementation

uses
  dnako_import, unit_string;


function var2str(p: PHiValue): AnsiString;
begin
  Result := hi_str(p);
end;

function hi_str(p: PHiValue): AnsiString;
const MAX_STR = 255;
var
  len: DWORD;
begin
  if p = nil then
  begin
    Result := ''; Exit;
  end;

  // �K���Ɋm�ۂ��ĕ�������R�s�[
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
    SetLength(Result, len); // ���T�C�Y
  end;
end;

function hi_strU(p: PHiValue): string;
begin
  Result := string(AnsiString(hi_str(p)));
end;

function hi_hashKeys(p: PHiValue): AnsiString;
var
  s: AnsiString;
begin
  SetLength(s, 1024 * 16);
  nako_hash_keys(p, PAnsiChar(s), Length(s));
  Result := AnsiString(TrimA(s));
end;

function hi_var_new(name: AnsiString = ''): PHiValue;
begin
  if name = '' then
    Result := nako_var_new(nil)
  else
    Result := nako_var_new(PAnsiChar(name));
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

function hi_newStr(value: AnsiString): PHiValue;
begin
  Result := hi_var_new;
  hi_setStr(Result, value);
end;

function hi_newStrU(value: string): PHiValue;  // �V�K������
begin
  Result := hi_newStr(AnsiString(value));
end;

function hi_newFloat(value: HFloat): PHiValue;// �V�K������
begin
  Result := hi_var_new;
  hi_setFloat(Result, value);
end;

function hi_newBool(value: Bool): PHiValue;// �V�KBOOL
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

procedure hi_setStr(v: PHiValue; s: AnsiString);
begin
  if s = '' then
  begin
    nako_str2var(PAnsiChar(s), v);
  end else
  begin
    nako_bin2var(@s[1], Length(s), v);
  end;
end;

procedure hi_setStrU (v: PHiValue; s: string);
begin
  hi_setStr(v, AnsiString(s));
end;

end.
