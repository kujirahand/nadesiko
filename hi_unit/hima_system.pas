unit hima_system;
//------------------------------------------------------------------------------
// �\���؂����s����
//------------------------------------------------------------------------------

interface

uses
  Windows, SysUtils, Classes, hima_types, hima_parser, hima_token, hima_variable,
  hima_variable_ex, hima_function, hima_stream, mmsystem, unit_pack_files;

const
  MAX_STACK_COUNT = 4096; // �ċA�X�^�b�N�̍ő吔(���܂�傫�������Delphi���̂��I�[�o�[�t���[����)
const
  nako_OK= 1;
  nako_NG = 0;

type
  THiScope = class;

  THiNamespace = class(THList) // THiScope �����X�g�ɂԂ牺�����Ă���
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
    function GetVar(id: DWORD): PHiValue; // ���݂̃l�[���X�y�[�X����ϐ�������
    function GetVarNamespace(NamespaceID: Integer; WordID: DWORD): PHiValue; // �l�[���X�y�[�X���̕ϐ����擾����
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
    ScopeID: Integer; // DebugInfo.FileNo �Ɠ���
    procedure RegistVar(v: PHiValue);
    function GetVar(id: DWORD): PHiValue;
    procedure Clear; override;
    constructor Create;
    destructor Destroy; override;
    procedure ExecGroupDestructor;
    function EnumKeys: AnsiString;
    function EnumKeysAndValues(UserOnly: Boolean = False): AnsiString;
  end;

  THiGroupScope = class(THList) // �O���[�v�̓O���[�o���ϐ��Ƃ��Ă��o�^�����̂ł����ł͉�����Ȃ�
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

  THiVarScope = class(THObjectList) // ���[�J���X�R�[�v�̐����j�����s��
  public
    function FindVar(NameID: DWORD): PHiValue;
    procedure PushVarScope;
    procedure PopVarScope;
    function TopItem: THiScope;
    function HasLocal: Boolean;
  end;

  //----------------------------------------------------------------------------
  // �v���O�C���Ǘ��p
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
  THiPlugins = class(THObjectList) // �v���O�C���Ǘ��p���X�g
  public
    function UsedList: string; // ���p���ꂽ�v���O�C���݂̂�Ԃ�
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
  // �C���^�v���^�E�V�X�e����\���^
  THiSystem = class
  private
    FlagInit: Boolean;
    FNowLoadPluginId: Integer; // plugin�ǂݍ��ݎ��Ɉꎞ�I�ɗ��p����ϐ�
    // �V�X�e�����߂̒ǉ����Ǘ�����^�O(�w���v�t�@�C���ԍ��̏d����h�����߂̊ȈՓI�Ȃ���)
    FTime: DWORD;
    FRunFlagList: THList;
    FPluginsDir: string;
    // �V�X�e�����߂�ǉ�����
    procedure CheckInitSystem;
    procedure AddSystemCommand;
    // ���߂̒ǉ��Ɏg���葱��
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
    TangoList: THimaTangoList;  // �P�� <--> ID ��ێ�
    JosiList:  THimaJosiList;   // ���� <--> ID ��ێ�
    DefFuncList: THObjectList;  // �֐��錾�̃��X�g
    ConstList: THList;
    FlagStrict: Boolean;        // ���i�ɐ錾�Ȃǂ��K�v���H
    FlagVarInit: Boolean;       // �ϐ��̏��������K�v���H
    FlagSystem: Byte;           // �V�X�e����`���ǂ����H(0:USER 1:SYSTEM)
    //
    FFlagEnd: Boolean;          // �I������t���O
    BreakLevel: Integer;        // Break / Continue �𐧌䂷��
    BreakType: THiBreakType;    // Break or Continue
    FJumpPoint: DWORD;          // GOTO ���̎����̂���
    FFuncBreakLevel: Integer;   // �֐���Break�ʒu
    ReturnLevel: Integer;       // Return �𐧌䂷��
    FNestCheck  : Integer;
    //
    CurNode, ContinueNode: TSyntaxNode;       // ���s���̃m�[�h
    GroupScope: THiGroupScope;  // �O���[�v�X�R�[�v
    LocalScope: THiVarScope;    // ���[�J���X�R�[�v
    Namespace: THiNamespace;    // �O���[�o���ϐ�::�l�[���X�y�[�X�����p
    DllNameList: TStringList;  // �C���|�[�g����DLL�̃��X�g
    DllHInstList: THList;
    DebugEditorHandle: THandle; // �s�ԍ��̑��M���~�����̂���
    DebugLineNo: Boolean;
    Speed: Integer;             // ���s�E�F�C�g
    Sore: PHiValue;
    kaisu,errMsg, taisyou: PHiValue;
    MainFileNo: Integer;        // �f�o�b�O�̂��߂Ƀ��C���t�@�C���Ď��p
    FlagSystemFile: Boolean;
    plugins: THiPlugins;
    DebugNextStop: Boolean;
    LastFileNo: Integer; // �f�o�b�O�̂��߂�
    LastLineNo: Integer;
    FDummyGroup: PHiValue;
    FIncludeBasePath: string; // ��荞�ݒ���BasePath
    runtime_error: Boolean;
    //
    constructor Create;
    destructor Destroy; override;
    // --- �O�����瑀�삳��镔�� ---
    function LoadFromFile(Source: string): Integer;       // �\�[�X�ǂݍ��݁��\���؍쐬
    function LoadSourceText(Source, SourceName: AnsiString): Integer; // �\�[�X�ǂݍ��݁��\���؍쐬
    function Run: PHiValue;                       // �ǂݍ��񂾍\���؂����s
    procedure Run2;                               // �ǂݍ��񂾍\���؂����s(�l��Ԃ��Ȃ�)
    function Eval(Source: AnsiString): PHiValue;      // �\�[�X��������w�肷��Ƃ������s����
    procedure Eval2(Source: AnsiString);              // �\�[�X��������w�肷��Ƃ������s����(�l��Ԃ��Ȃ�)
    function GetVariable(VarID: DWORD): PHiValue; // �ϐ��̎擾
    function GetVariableRaw(VarID: DWORD): PHiValue; // �ϐ��̎擾
    function GetVariableNoGroupScope(VarID: DWORD): PHiValue; // �ϐ��̎擾
    function GetVariableS(vname: AnsiString): PHiValue; // �ϐ��̎擾
    function ExpandStr(s: string): string;       // ������̓W�J
    procedure AddSystemFileCommand;               // ������Ɗ댯�H�ȃt�@�C���֘A�̖��߂��V�X�e���ɒǉ�����
    procedure LoadPlugins;                         // �v���O�C���̃��[�h
    function ErrorContinue: PHiValue;             // �G���[�Ŏ~�܂����m�[�h�𑱂���
    procedure ErrorContinue2;
    // --- ���܂Ɏg������
    function ImportFile(FName: string; var node: TSyntaxNode): PHiValue; // ��荞��
    function RunNode(node: TSyntaxNode; IsNoGetter: Boolean = False): PHiValue; // �\���؂�n���Ď��s������
    procedure RunNode2(node: TSyntaxNode; IsNoGetter: Boolean = False);         // �\���؂�n���Ď��s������(�l��Ԃ��Ȃ�)
    function CreateHiValue(VarId: Integer = 0): PHiValue;
    function Local: THiScope;
    procedure PushScope; // ���[�J���X�R�[�v�̍쐬
    procedure PopScope;  // ���[�J���X�R�[�v�̔j��
    procedure SetSetterGetter(VarName, SetterName, GetterName: AnsiString; tag: Integer; Description, yomi: AnsiString); // �Z�b�^�[�Q�b�^�[�̐ݒ�
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
    procedure PushRunFlag; // Eval �ȂǂŎ��s���Ղ鎞�Ɏg��
    procedure PopRunFlag;
    function makeDllReport: AnsiString;
    property PluginsDir: string read FPluginsDir write SetPluginsDir;
  end;

  TImportNakoSystem = procedure; stdcall;
  TPluginRequire    = function : DWORD; stdcall;

  HException = class(Exception)
    constructor Create(msg: AnsiString);
  end;

// HiSystem �͗B��̂���(Singleton)
function HiSystem: THiSystem;
procedure HiSystemReset; // Reset...

// �Ȉ՗p�葱��
// �P��ID ���� �P�ꖼ�𓾂�
function hi_id2tango(id: DWORD): AnsiString;
function hi_tango2id(tango: AnsiString): DWORD;
function hi_id2fileno(id: DWORD): Integer;

procedure _initTag;
procedure _checkTag(tag:Integer; name: DWORD);
procedure nako_var_free(value: PHiValue); stdcall; // �ϐ� value �̒l���������
function nako_getFuncArg(handle: DWORD; index: Integer): PHiValue; stdcall; // nako_addFunction �œo�^�����R�[���o�b�N�֐�������������o���̂Ɏg��
function nako_getSore: PHiValue; stdcall; // �ϐ��w����x�ւ̃|�C���^���擾����

function getArg(h: DWORD; Index: Integer; UseHokan: Boolean = False): PHiValue;
function getArgInt(h: DWORD; Index: Integer; UseHokan: Boolean = False): Integer;
function getArgIntDef(h: DWORD; Index: Integer; Def:Integer): Integer;
function getArgStr(h: DWORD; Index: Integer; UseHokan: Boolean = False): AnsiString;
function getArgBool(h: DWORD; Index: Integer; UseHokan: Boolean = False): Boolean;
function getArgFloat(h: DWORD; Index: Integer; UseHokan: Boolean = False): HFloat;

function nako_var_new(name: PAnsiChar): PHiValue; stdcall; // �V�K PHiValue �̕ϐ����쐬����Bname��nil��n���ƕϐ��������Ȃ��Œl�����쐬���ϐ���������ƃO���[�o���ϐ��Ƃ��ēo�^����B
function nako_getVariable(vname: PAnsiChar): PHiValue; stdcall;// �Ȃł����ɓo�^����Ă���ϐ��̃|�C���^���擾����

procedure AddFunc(name, argStr: AnsiString; tag: Integer; func: THimaSysFunctionD;
  kaisetu, yomigana: AnsiString; IzonFiles: AnsiString = '');
function nako_addFunction2(name, args: PAnsiChar; func: THimaSysFunction; tag: Integer; IzonFiles: PAnsiChar): DWORD; stdcall; // �Ǝ��֐���ǉ�����
procedure nako_addStrVar(name: PAnsiChar; value: PAnsiChar; tag: Integer); stdcall; // ������^�̕ϐ����V�X�e���ɒǉ�����B

procedure AddStrVar(name, value: AnsiString; tag: Integer; kaisetu, yomigana: AnsiString);

const
  BREAK_OFF = MaxInt;



var FHiSystem: THiSystem = nil;// private �ɂ��ׂ�
var dnako_dll_handle: THandle = 0;

implementation

uses hima_error, hima_string, unit_string, unit_file_dnako, mini_file_utils,
  unit_windows_api, ConvUtils, nadesiko_version, unit_file;

// ������FHiSystem�̏��������s������
//   initialization �ŏ��������s���ƁA���j�b�g�̏z������ HiSystem ��
//   �������ꂽ��� initialization ���Ăяo����s����N����
//   �܂��ACreate �̒��� HiSystem ���Q�Ƃ���Ȃ��悤�ɂ��ׂ�
//   ���̂��߁AAddSystemVar �͈�x�ڂ� LoadFromFile�ŌĂ΂��

function HiSystem: THiSystem;
begin
  if FHiSystem = nil then
  begin
    FHiSystem := THiSystem.Create;
  end;
  Result := FHiSystem;
end;

// �P��ID ���� �P�ꖼ�𓾂�
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

var ctag: array [0..1000] of Byte; // 1 byte = 8 �̃`�F�b�N(1000 * 8) = 8000 �̖��߂��Ǘ��ł���

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
    // ����̃r�b�g�𒲂ׂ�
    idx := tag div 8;
    bit := tag mod 8;
    if idx > high(ctag) then Exit;

    // �r�b�g�𒲂ׂ�
    msk := 1 shl bit; // �}�X�N�r�b�g�̍쐬

    // �󂢂Ă�Ȃ� TRUE ��
    Result := ((ctag[idx] and msk) = 0);

    // �`�F�b�N�����邩�H
    if check then ctag[idx] := ctag[idx] or msk;
  end;

begin
  // 0 �Ȃ璲�ׂȂ�
  if (tag <= 0) then Exit;

  // ���|�[�g
  if not __blank(tag) then
  begin
    // ���ԂȂ炠���Ă���̂����ׂ�
    i := tag - 1;
    while not __blank(i) do Dec(i);
    // ���|�[�g�̕\��
    debugs(
      '[���߃^�O�d��] tag='+
      AnsiString(IntToStr(tag))+
      ' name='+hi_id2tango(name) +#13#10 +
       '����ȑO�̋󔒔ԍ�=' + AnsiString(IntToStr(i)));
    //raise Exception.Create('[���߃^�O�d��] tag='+IntToStr(tag));
  end;

  // �r�b�g���Z�b�g����
  __blank(tag, True);
end;

procedure nako_var_free(value: PHiValue); stdcall; // �ϐ� value �̒l���������
begin
  if value = nil then Exit;

  if value.Registered = 1 then
    hi_var_clear(value)  // ���[�U�[�폜�t��
  else
    hi_var_free(value);  // ���[�U�[�폜��
end;

function nako_getFuncArg(handle: DWORD; index: Integer): PHiValue; stdcall; // nako_addFunction �œo�^�����R�[���o�b�N�֐�������������o���̂Ɏg��
var
  a: THiArray;
begin
  a := THiArray(handle);    // handle = THiArray �ւ̃A�h���X

  Assert((a is THiArray), 'nako_getFuncArg�ɕs���ȃn���h�����n����܂����B');

  if a.Count > index then
  begin
    Result := a.Items[index]; // nil �� nil �Ƃ��ĕԂ�
  end else
  begin
    Result := nil;
  end;
  if (Result <> nil) then
  begin
    if Result.VType = varLink then Result := hi_getLink(Result);
  end;
end;

function nako_getSore: PHiValue; stdcall; // �ϐ��w����x�ւ̃|�C���^���擾����
begin
  Result := HiSystem.Sore;
end;

// �������ȒP�Ɏ擾����
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

function nako_var_new(name: PAnsiChar): PHiValue; stdcall; // �V�K PHiValue �̕ϐ����쐬����Bname��nil��n���ƕϐ��������Ȃ��Œl�����쐬���ϐ���������ƃO���[�o���ϐ��Ƃ��ēo�^����B
begin
  if name <> nil then
  begin
    Result := HiSystem.CreateHiValue(hi_tango2id(DeleteGobi(name)));
  end else
  begin
    Result := hi_var_new;
  end;
end;

function nako_getVariable(vname: PAnsiChar): PHiValue; stdcall;// �Ȃł����ɓo�^����Ă���ϐ��̃|�C���^���擾����
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
      //raise Exception.Create('�w'+name+'�x(tag='+IntToStr(tag)+')���d�����Ă��܂��B');
    end;
  end;
  nako_addFunction2(
    PAnsiChar(name),
    PAnsiChar(argStr),
    THimaSysFunction(func),
    tag,
    PAnsiChar(IzonFiles));
end;

function nako_addFunction2(name, args: PAnsiChar; func: THimaSysFunction; tag: Integer; IzonFiles: PAnsiChar): DWORD; stdcall; // �Ǝ��֐���ǉ�����
begin
  if HiSystem.AddFunction(name, args, func, tag, IzonFiles) then
    Result := NAKO_OK
  else
    Result := NAKO_NG;
end;

procedure nako_addStrVar(name: PAnsiChar; value: PAnsiChar; tag: Integer); stdcall; // ������^�̕ϐ����V�X�e���ɒǉ�����B
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
  // �O��/��������̃R�}���h�ǉ�
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
  item.VType := varStr; // �Ȃ�������Ă��܂����̂ōēx�ǉ�
  item.Designer := 1; // 1:SYSTEM
  hi_setStr(item, value);
end;

procedure THiSystem.AddSystemCommand;

  function _setCmdLine: AnsiString;
  var
    i: Integer;
    p, a: PHiValue;
  begin
    p := Global.GetVar(hi_tango2id('�R�}���h���C��'));
    if p = nil then p := CreateHiValue(hi_tango2id('�R�}���h���C��'));

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
    // ����
    v := GetVariable(hi_tango2id('_'));
    hi_setLink(v, Sore);
    v := GetVariable(hi_tango2id('����'));
    hi_setLink(v, Sore);

    // ���g
    {
    v := GetVariable(token_jisin);
    hi_var_copyGensi(FDummyGroup, v);
    if v.VType <> varGroup then raise Exception.Create('���g���O���[�v�ɂȂ�܂���B');
    }
  end;

begin
  //todo 1: ���V�X�e���ϐ��֐�(BASE)

  FNowLoadPluginId := -1; // �V�X�e�����߂�-1

  // --- �����̋K�� ---
  // {�^=�ȗ����̃f�t�H���g}�ϐ����{���� �ϐ����{���� ... | �ϐ����{����
  // =? �͊�{�I�ɕϐ��u����v����������(���̂Ƃ���Ăяo�����֐��̒��őΏ�)
  //<�V�X�e���ϐ��֐�>

  //+�V�X�e��
  //-�o�[�W�������
  AddStrVar('�i�f�V�R�o�[�W����',    {'(�o�[�W�������ɈႤ)'}NADESIKO_VER , 100, '���s���̂Ȃł����̃o�[�W����','�Ȃł����΁[�����');
  AddStrVar('�i�f�V�R�ŏI�X�V��',    {'(�o�[�W�������ɈႤ)'}NADESIKO_DATE, 101, '�o�[�W�����̍X�V��','�Ȃł����������イ���������');
  AddStrVar('�i�f�V�R�����^�C��',    {'(�N�����Ɍ���)'}getRuntime,    102, '�Ȃł����G���W�������[�h�������s�t�@�C���̖��O(�啶��)','�Ȃł�����񂽂���');
  AddStrVar('�i�f�V�R�����^�C���p�X',{'(�N�����Ɍ���)'}AnsiString(ParamStr(0)),   103, '�Ȃł����G���W�������[�h�������s�t�@�C���̃t���p�X','�Ȃł�����񂽂��ނς�');
  AddStrVar('OS',                    {'(�N�����Ɍ���)'}getWinVersion, 104, 'OS�̎�ނ�ێ�����BWindows 8/Windows 8.1/Windows 7/Windows Vista/Windows Server 2003/Windows XP/Windows 2000/Windows Me/Windows 98/Windows NT 4.0/Windows NT 3.51/Windows 95','OS');
  AddStrVar('OS�o�[�W����',          {'(�N�����Ɍ���)'}getWinVersionN,105, 'OS�̃o�[�W�����ԍ����uMajor.Minor(Build:PlatformId)�v�̌`���Ԃ��B(��)4.10=Windows98/5.1=XP/6.0=Vista/6.1=Windows7','OS�΁[�����');

  //-��{�ϐ�
  AddStrVar('����',   '', 110, '���߂̌��ʂ���������ϐ��B�ȗ���Ƃ��Ă��g����B','����');
  AddIntVar('�͂�',    1, 111, '�͂��E�������̑I���Ɏg����B','�͂�');
  AddIntVar('������',  0, 112, '�͂��E�������̑I���Ɏg����B','������');
  AddIntVar('�K�v',    1, 113, '�K�v�E�s�v�̑I���Ɏg����B','�Ђ悤');
  AddIntVar('�s�v',    0, 114, '�K�v�E�s�v�̑I���Ɏg����B','�ӂ悤');
  AddIntVar('�I��',    1, 115, '�I���E�I�t�̑I���Ɏg����B','����');
  AddIntVar('�I�t',    0, 116, '�I���E�I�t�̑I���Ɏg����B','����');
  AddIntVar('�^',    1, 134, '�^�E�U�̑I���Ɏg����B','����');
  AddIntVar('�U',    0, 135, '�^�E�U�̑I���Ɏg����B','��');
  //AddIntVar('��',    0, 117, '���O�ɑ��삵���O���[�v�̖��O���ȗ�����̂Ɏg���B���́~�~�́~�~�̌`�Ŏg���B','��');
  AddIntVar('�L�����Z��',  2, 118, '�͂��E�������E�L�����Z���̑I���Ɏg����B','����񂹂�');
  AddStrVar('��',   '', 119, '����ہB�u�v�̂���','����');
  AddStrVar('���s',{'#13#10'}#13#10, 120, '���s��\��','�������傤');
  AddStrVar('�^�u',    {'#9'}#9,     121, '�^�u��\��','����');
  AddIntVar('OK', 1,     122, 'OK�ENG�̑I���Ɏg����B','OK');
  AddIntVar('NG', 0,     123, 'OK�ENG�̑I���Ɏg����B','NG');
  AddIntVar('����', 1,     124, '�����E���s�̑I���Ɏg����B','��������');
  AddIntVar('���s', 0,     125, '�����E���s�̑I���Ɏg����B','�����ς�');
  AddStrVar('�J�b�R',       '�u',126, '','������');
  AddStrVar('�J�b�R��',   '�v',127, '','�������Ƃ�');
  AddStrVar('�g�J�b�R',     '{', 128, '','�Ȃ݂�����');
  AddStrVar('�g�J�b�R��', '}', 129, '','�Ȃ݂������Ƃ�');
  AddStrVar('��d�J�b�R',       '�w',130, '','�ɂ��イ������');
  AddStrVar('��d�J�b�R��',   '�x',131, '','�ɂ��イ�������Ƃ�');
  AddStrVar('_','',132,'�ϐ��w����x�̃G�C���A�X�B','_');
  AddStrVar('����','',5020,'�ϐ��w����x�̃G�C���A�X�B','����');
  //AddIntVar('����', 0, 5021, '���O�ɑ��삵���O���[�v�̖��O���ȗ�����̂Ɏg���B����́~�~�́~�~�̌`�Ŏg���B','����');

  //-��{����
  AddFunc  ('����','{������=?}S��|S��',       150, sys_say,        '���b�Z�[�WS���_�C�A���O�ɕ\������B','����');
  AddFunc  ('�i�f�V�R����','{������}S��|S��', 151, sys_eval,  '������S�̓��e���Ȃł����̃v���O�����Ƃ��Ď��s����B','�Ȃł�������');
  AddFunc  ('EVAL','{������}S',               152, sys_eval,  '������S�̓��e���Ȃł����̃v���O�����Ƃ��Ď��s����B','EVAL');
  AddFunc  ('����','{������=?}S��|S��',       153, sys_say,        '���b�Z�[�WS���_�C�A���O�ɕ\������B','����');
  //-�f�o�b�O�x��
  AddFunc  ('�V�X�e������','',                171, sys_timeGetTime,'OS���N�����Ă���̎��Ԃ��擾���ĕԂ��B','�����Ăނ�����');
  AddFunc  ('�o�C�i���_���v','{������=?}S��', 173, sys_binView,'������S���o�C�i���Ƃ���1�o�C�g����16�i���ŃJ���}��؂�ɂ��ĕԂ�','�΂��Ȃ肾���');
  AddFunc  ('���s���x�ݒ�','A��', 174, sys_runspeed,'���s���x��x���������ꍇ�AA��1�ȏ�̒l��ݒ肷��ƒx������B','�������������ǂ����Ă�');
  AddFunc  ('�\���؋t�Q��', '', 149, sys_ref_syntax, '�Ȃł����\���؂��Q�Ƃ���B','�����Ԃ񂫂��Ⴍ���񂵂傤');
  Reserved ('�G���[�Ď�','',     207,'�w�G���[�Ď�(��A)�G���[�Ȃ��(��B)�x�̑΂Ŏg���A��A�����s���ɃG���[�������������ɕ�B�����s����B','����[����');
  Reserved ('�G���[�Ȃ��','',   208,'�w�G���[�Ď�(��A)�G���[�Ȃ��(��B)�x�̑΂Ŏg���A��A�����s���ɃG���[�������������ɕ�B�����s����B','����[�Ȃ��');
  AddFunc  ('�G���[����','{������=?}S��|S��', 170, sys_except, '�̈ӂɃG���[�𔭐�������B','����[�͂�����');
  AddFunc  ('�G���[����','', 189, sys_runtime_error_off, '���s���G���[�𖳎������s��������B','����[�ނ�');
  AddStrVar('�G���[���b�Z�[�W', '', 212, '�G���[�Ď��\���ŃG���[�������������ɃG���[���b�Z�[�W���擾����','����[�߂����[��');
  AddFunc  ('�f�o�b�O', '', 213, sys_debug, '�f�o�b�O�_�C�A���O��\������B','�ł΂���');
  AddFunc  ('ASSERT', 'A��|A��|A��', 214, sys_assert, '������A��0(�U)�ɂȂ�Ɨ�O�𔭂���B','ASSERT');
  AddFunc  ('�O�O��', 'S��|S��', 487, sys_guguru, '�L�[���[�hS�ŃO�O��B','������');
  AddFunc  ('�i�f�V�R���p�\�v���O�C����', '', 486, sys_plugins_enum, '���p�\�ȃv���O�C����Ԃ�','�Ȃł�����悤���̂��Ղ炮����������');

  //-�R�}���h���C���E���ϐ�
  AddStrVar('�R�}���h���C��', '', 190, '�v���O�����N�����̃R�}���h���C��������z��`���œ���','���܂�ǂ炢��');
  AddFunc  ('���ϐ��擾','S��',179, sys_getEnv,'���ϐ�S�̒l���擾','���񂫂傤�ւ񂷂�����Ƃ�');

  //-�ϐ��Ǘ�
  AddFunc  ('�ϐ���','{=?}S��',             172, sys_EnumVar,'S�Ɂu�O���[�o��|���[�J��|�V�X�e��|���[�U�[�v(������)���w�肵�ĕϐ��̈ꗗ��Ԃ��B','�ւ񂷂��������');
  AddFunc  ('�ϐ��m�F','{������}S��',         168, sys_ExistsVar,'������ŗ^�����ϐ���S�̏ڍ׏���Ԃ��B���݂��Ȃ���΋��Ԃ��B','�ւ񂷂������ɂ�');
  AddFunc  ('�O���[�v�Q�ƃR�s�[','{�Q�Ɠn�� �O���[�v}A��{�Q�Ɠn�� �O���[�v}B��|A��B��', 175, sys_groupCopyRef,   '�O���[�vA�̃G�C���A�X���O���[�vB�ɍ��B','����[�Ղ��񂵂傤���ҁ[');
  AddFunc  ('�O���[�v�R�s�[',    '{�Q�Ɠn�� �O���[�v}A��{�Q�Ɠn�� �O���[�v}B��|A��B��', 176, sys_groupCopyVal,   '�O���[�vA�̃����o�S�����O���[�vB�ɃR�s�[����B�a�̃����o�͏����������̂Œ��ӁB','����[�Ղ��ҁ[');
  AddFunc  ('�O���[�v�����o�ǉ�','{�Q�Ɠn�� �O���[�v}A��{�Q�Ɠn�� �O���[�v}B��|A��B��', 177, sys_groupAddMember,   '�O���[�vA�̃����o�S�����O���[�vB�ɒǉ��R�s�[����B','����[�Ղ߂�΂���');
  AddFunc  ('�ϐ��G�C���A�X�쐬','{�Q�Ɠn��}A��{�Q�Ɠn��}B��|A��B��', 178, sys_alias,   '�ϐ�A�̃G�C���A�X��ϐ�B�ɐݒ肷��B','�ւ񂷂������肠����������');
  AddFunc  ('�f�[�^�R�s�[','{�Q�Ɠn��}A��{�Q�Ɠn��}B��|A����B��', 140, sys_copyData,   '�ϐ�A�̃f�[�^��ϐ�B�̃f�[�^�փR�s�[����B','�Ł[�����ҁ[');
  AddFunc  ('TYPEOF',     '{�Q�Ɠn��}A',  193, sys_typeof, '�ϐ�A�̌^�𓾂�','TYPEOF');
  AddFunc  ('�ϐ��^�m�F', '{�Q�Ɠn��}A��',163, sys_typeof, '�ϐ�A�̌^�𓾂�','�ւ񂷂����������ɂ�');
  //-�|�C���^
  AddFunc  ('ADDR',   '{�Q�Ɠn��}A',191, sys_addr,   '�ϐ�A�̃|�C���^(PHiValue�^)�𓾂�','ADDR');
  AddFunc  ('POINTER','{�Q�Ɠn��}A',192, sys_pointer,'�ϐ�A�̕ێ����Ă��鐶�f�[�^�ւ̃|�C���^�𓾂�','POINTER');
  AddFunc  ('UNPOINTER','A,B',249, sys_unpointer,'�|�C���^A�̂��w���f�[�^���^B�Ƃ��ēǂݍ��ށBB�ɂ̓f�[�^�̃T�C�Y�𐔒l�Ƃ��Ă��w��ł���B','POINTER');
  AddFunc  ('PACK',   '{�O���[�v}A,{�Q�Ɠn��}B,S',194, sys_pack,   '�O���[�vA���o�C�i���\���̂Ƃ���B�Ƀp�b�N����BS�Ƀp�b�N����^���wlong,long�x�Ǝw�肷��B','PACK');
  AddFunc  ('UNPACK', '{�Q�Ɠn��}A,{�Q�Ɠn�� �O���[�v}B,S',195, sys_unpack, '�o�C�i���\����A���O���[�vB�ɐU�蕪����BS�ɐU�蕪����^���w�肷��B','UNPACK');
  AddFunc  ('EXEC_PTR', '{������=�ustdcall�v}CALLTYPE,{�Q�Ɠn��}FUNC,{����}SIZE,{�Q�Ɠn��}RECT,RET', 162, EasyExecPointer, '�֐��|�C���^FUNC�����s����BSIZE�͈����X�^�b�N�̃T�C�Y�ARECT�͈����X�^�b�N�ɐςގ��f�[�^�ARET�͕Ԃ�l�̌^���𕶎���Ŏw�肷��BCALLTYPE��stdcall��cdecl���w�肷��(�f�t�H���g��stdcall)�B','EXEC_PTR');
  //�^�ϊ�
  AddFunc  ('������ϊ�','{=?}S��',196, sys_toStr,   '�ϐ�S�𕶎���ɕϊ����ĕԂ�','������ւ񂩂�');
  AddFunc  ('�����ϊ�',  '{=?}S��',197, sys_toInt,   '�ϐ�S�𐮐��ɕϊ����ĕԂ�','���������ւ񂩂�');
  AddFunc  ('TOSTR','{=?}S',198, sys_toStr,   '�ϐ�S�𕶎���ɕϊ����ĕԂ�','TOSTR');
  AddFunc  ('TOINT','{=?}S',199, sys_toInt,   '�ϐ�S�𐮐��ɕϊ����ĕԂ�','TOINT');
  AddFunc  ('�����ϊ�','{=?}S��',165, sys_toFloat, '�ϐ�S�������ɕϊ����ĕԂ�','���������ւ񂩂�');
  AddFunc  ('TOFLOAT', '{=?}S',  167, sys_toFloat, '�ϐ�S�������ɕϊ����ĕԂ�','TOFLOAT');
  AddFunc  ('�n�b�V���ϊ�','{=?}S��',166, sys_toHash, '�ϐ�S���n�b�V���ɕϊ����ĕԂ�','�͂�����ւ񂩂�');

  //-�錾
  Reserved('������','S�Ƃ�', 180,'�w(�ϐ���)�Ƃ͕�����x�ŕϐ���錾����B','�������');
  Reserved('���l',  'S�Ƃ�', 181,'�w(�ϐ���)�Ƃ͐��l�x�ŕϐ���錾����B','������');
  Reserved('����',  'S�Ƃ�', 182,'�w(�ϐ���)�Ƃ͐����x�ŕϐ���錾����B','��������');
  Reserved('�ϐ�',  'S�Ƃ�', 183,'�w(�ϐ���)�Ƃ͕ϐ��x�ŕϐ���錾����B','�ւ񂷂�');
  Reserved('�z��',  'S�Ƃ�', 184,'�w(�ϐ���)�Ƃ͔z��x�ŕϐ���錾����B','�͂����');
  Reserved('����',  'S�Ƃ�', 185,'�w(�ϐ���)�Ƃ͎����x�ŕϐ���錾����B','��������');
  Reserved('�n�b�V��','S�Ƃ�', 186,'�w(�ϐ���)�Ƃ̓n�b�V���x�ŕϐ���錾����B','�͂�����');
  Reserved('�ϐ��錾','', 187,'�w!�ϐ��錾���K�v�b�s�v�x�ŕϐ��錾�̕K�v�s�v��؂�ւ���','�ւ񂷂����񂰂�');
  Reserved('�O���[�v','', 188,'�w���O���[�v�i�O���[�v���j�x�ŃO���[�v��錾����','����[��');
  Reserved('��荞��','S��', 5059,'�w!�u�t�@�C�����v����荞�ށx�ŊO���t�@�C������荞�ށB','�Ƃ肱��');
  Reserved('�l�[���X�y�[�X�ύX','S��|S��', 244,'�w!�u���O��Ԗ��v�Ƀl�[���X�y�[�X�ύX�x�Ŗ��O��Ԃ�ύX����B','�ˁ[�ނ��؁[���ւ񂱂�');

  //+��{�\��
  //-�t���[����
  Reserved('����',  '',         200,'�w����...�Ȃ��...�Ⴆ��...�x�̑΂Ŏg����������\����\���B','����');
  Reserved('�Ȃ��','',         201,'�w����(������)�Ȃ��(�^�̏���)�Ⴆ��(�U�̏���)�x�Ŏg����������\����\��','�Ȃ��');
  Reserved('�Ⴆ��','',         202,'�w����(������)�Ȃ��(�^�̏���)�Ⴆ��(�U�̏���)�x�Ŏg����������\����\��','��������');
  Reserved('��',    'S��',      203,'�w(������)�̊�...�x�ŏ��������^�̎�...�̕����J��Ԃ����s����B','������');
  Reserved('����',  '{=?}S��|S��',  204,'�w(�f�[�^S)�𔽕�...�x�Ńf�[�^S�̗v�f���J��Ԃ��B�J��Ԃ��ɍۂ��ϐ��w����x�Ƀf�[�^�̗v�f����������B','�͂�Ղ�');
  AddStrVar('�Ώ�','',164, '�w�����x�\���ŌJ��Ԃ��Ώۂ��w��','�������傤');
  Reserved('��',    'CNT',      205,'�w(CNT)��...�x��CNT��...���J��Ԃ��B','����');
  AddIntVar('��',    0,       211, '�w��x�w�����x�w�J��Ԃ��x�w�ԁx�ŌJ��Ԃ�������ڂ����������','��������');
  Reserved('�J��Ԃ�','{=?}S��A����B�܂�|S��',206,'�w(�ϐ�)��A����B�܂ŌJ��Ԃ�...�x��A����B�܂�1���ϐ�S�̓��e�𑝂₵�Ȃ���...�̕����J��Ԃ��B�ϐ����ȗ�����ƕϐ��u����v�ɔԍ�����������B','���肩����');
  Reserved('���[�v','S��',      209,'�w(������)�̃��[�v...�x�ŏ��������^�̎�...�̕����J��Ԃ����s����B','��[��');
  Reserved('��������','S��',    210,'�w(������)�ŏ�������{���s}(����)�Ȃ��...(����)�Ȃ��...�Ⴆ��...�x�ŏ����ɂ�蕡���̑I�����Ɏ��s�𕪊򂷂�B','���傤����Ԃ�');
  Reserved('����','',169,'����\���̍Ō�Łw�����܂Łx�ƍ\���̏I���𖾎��ł���B','����');
  AddFunc  ('���','{=?}JUMPPOINT��|JUMPPOINT��',161, sys_goto, '�W�����v�|�C���g�֎��s���ڂ�(JUMPPOINT�͕�����Ŏw�肷��)','�Ƃ�');
  //-�R�����g
  Reserved('#','',157,'# ������s�܂ł͈̔͂��R�����g�Ƃ��Ĉ����B','#');
  Reserved('��','',155,'��������s�͈̔͂��R�����g�Ƃ��Ĉ����B','��');
  Reserved('//','',159,'//������s�͈̔͂��R�����g�Ƃ��Ĉ����B','//');
  Reserved('/*..*/','',160,'/* .. */ �͈̔͂��R�����g�Ƃ��Ĉ����B','/*..*/');
  Reserved('�A','',158,'�s���́u�A�v�͎��̍s�փ\�[�X�𑱂�����Ӗ�����B','�A');

  //-���f���s�I��
  AddFunc  ('������','',                 220, sys_break,      '�J��Ԃ����甲����B','�ʂ���');
  AddFunc  ('������','',                 221, sys_continue,   '�J��Ԃ��̓r���ŌJ��Ԃ��͈͂̐擪�ɖ߂��đ�����B','�Â���');
  AddFunc  ('�I���','',                 222, sys_end,        '�v���O�����̎��s�𒆒f����B','�����');
  AddFunc  ('�����','',                 223, sys_end,        '�v���O�����̎��s�𒆒f����B','�����');
  AddFunc  ('�߂�',  '{=?}A��|A��',      224, sys_return,     '�֐�������s��߂��BA�ɂ͊֐��̖߂�l���w�肷��B','���ǂ�');
  AddFunc  ('�I��','',                   225, sys_end,        '�v���O�����̎��s�𒆒f����B','���イ��傤');
  //-���{��炵��
  AddFunc  ('��',  'A��',                240, sys_echo,     '�`�ł�','��');
  AddFunc  ('��',  'A',                  241, sys_echo,     '�`��',  '��');
  AddFunc  ('����','{�Q�Ɠn��=?}A��B|A��B��|A��',      242, sys_calc_let,   '�ϐ�A��B��������B','����');
  AddFunc  ('����܂�','{�Q�Ɠn��=?}A��B|A��B��|A��',  243, sys_calc_let,   '�ϐ�A��B��������B','����܂�');
  AddFunc  ('����','{�Q�Ɠn��}B��{=?}A��|A��',     246, sys_calc_let,   '�lA��ϐ�B�ɑ������B','����');

  //+���Z
  //-���Z
  AddFunc  ('���','{=?}A��{�Q�Ɠn��}B��|B��', 250, sys_calc_let,   '�lA��B�ɑ������B','�����ɂイ');
  AddFunc  ('����','{=?}A��B��|A��|A��',   251, sys_calc_add,   'A�ɐ��lB�𑫂��ĕԂ��B','����');
  AddFunc  ('����','{=?}A����B��',         252, sys_calc_sub,   'A���琔�lB�������ĕԂ��B','�Ђ�');
  AddFunc  ('�|����','{=?}A��B��|A��|A��', 253, sys_calc_mul,   'A�ɐ��lB���|���ĕԂ��B','������');
  AddFunc  ('����','{=?}A��B��',           254, sys_calc_div,   'A�𐔒lB�Ŋ����ĕԂ��B','���');
  AddFunc  ('�]��','{=?}A��B��',           255, sys_calc_mod,   'A�Ɛ��lB�̗]���Ԃ��B','���܂�');
  AddFunc  ('�������]��','{=?}A��B��',     248, sys_calc_mod,   '���lA�𐔒lB�Ŋ������]���Ԃ��B','��������܂�');
  AddFunc  ('���v','{=?}A��B��|A��|A��B��', 258, sys_calc_add2,  'A��B�̍��v��Ԃ��B','��������');
  AddFunc  ('�{','{=?}A��B|A��',            259, sys_calc_mul,  'A��B�{��Ԃ��B','�΂�');
  AddFunc  ('��','{=?}A��B��',            260, sys_calc_sub,  'A��B�̍���Ԃ��B','��');
  AddFunc  ('��','{=?}A��B��',            261, sys_calc_div,  'A��B�̏���Ԃ��B','���傤');
  AddFunc  ('��','{=?}A��B��',            262, sys_calc_mul,  'A��B�̐ς�Ԃ��B','����');
  AddFunc  ('��','{=?}A��B',             5024, sys_calc_pow,  'A���Ƃ���B�̗ݏ��Ԃ��B','���傤');
  AddFunc  ('��]','{=?}A��B��',         5025, sys_calc_mod,  'A��B�̏�]��Ԃ��B','���傤��');
  AddFunc  ('�{��','{=?}A��B��',         5070, sys_calc_baisu,  'A��B�̔{�������肵�Ă����Ȃ�͂���Ԃ��B','�΂�����');
  //-���Z(����)
  AddFunc  ('���ڑ���','{�Q�Ɠn��}A��B��|A��|A��',   263, sys_calc_add_b, '�ϐ�A�ɐ��lB�𑫂��ĕԂ��B(A�̓��e��ύX����)','���傭������');
  AddFunc  ('���ڈ���','{�Q�Ɠn��}A����B��',         264, sys_calc_sub_b, '�ϐ�A���琔�lB�������ĕԂ��B(A�̓��e��ύX����)','���傭���Ђ�');
  AddFunc  ('���ڊ|����','{�Q�Ɠn��}A��B��|A��|A��', 265, sys_calc_mul_b,   '�ϐ�A�ɐ��lB���|���ĕԂ��B(A�̓��e��ύX����)','���傭��������');
  AddFunc  ('���ڊ���','{�Q�Ɠn��}A��B��',           266, sys_calc_div_b,   '�ϐ�A�𐔒lB�Ŋ����ĕԂ��B(A�̓��e��ύX����)','���傭�����');
  //-��r
  AddFunc  ('�ȏ�',  'A��B',  270, sys_comp_GtEq, 'A��B�ȏ�Ȃ�1���Ⴆ��0��Ԃ�','�����傤');
  AddFunc  ('�ȉ�',  'A��B',  271, sys_comp_LtEq, 'A��B�ȉ��Ȃ�1���Ⴆ��0��Ԃ�','����');
  AddFunc  ('��',    'A��B',  272, sys_comp_Gt,   'A��B���Ȃ�1���Ⴆ��0��Ԃ�','���傤');
  AddFunc  ('����',  'A��B',  273, sys_comp_Lt,   'A��B�����Ȃ�1���Ⴆ��0��Ԃ�','�݂܂�');
  AddFunc  ('������','A��B��',274, sys_comp_Eq,   'A��B�Ɠ������Ȃ�1���Ⴆ��0��Ԃ�','�ЂƂ���');
  AddFunc  ('�Ȃ�',  '{=?}A��B��|B�ł�',      295, sys_comp_not,   '�ϐ�A��B�Ɠ������Ȃ��Ȃ�1���Ⴆ��0��Ԃ�','�Ȃ�');
  //-�v�Z�֐�
  AddFunc  ('INT',   'A',     275, sys_int,       '����A�̐���������Ԃ��BA��������Ȃ琮���ɕϊ������B','INT');
  AddFunc  ('FLOAT', 'A',     276, sys_float,     'A�������ɕϊ����ĕԂ��BA��������Ȃ�����ɕϊ������B','FLOAT');
  AddFunc  ('SIN',   'A',     277, sys_sin,       '���W�A���P�ʂ̊p�̐�����Ԃ��B','SIN');
  AddFunc  ('COS',   'A',     278, sys_cos,       '���W�A���P�ʂ̊p�̗]����Ԃ��B','COS');
  AddFunc  ('TAN',   'A',    5026, sys_tan,       '���W�A���P�ʂ̊p�̐��ڂ�Ԃ��B','TAN');
  AddFunc  ('ARCSIN','A',    5027, sys_arcsin,    '���W�A���P�ʂ̊p�̋t������Ԃ��BA��-1�`1�̊ԂłȂ���΂Ȃ�Ȃ��B�Ԃ�l��-PI/2�`PI/2�͈̔͂ƂȂ�B','ARCSIN');
  AddFunc  ('ARCCOS','A',    5028, sys_arccos,    '���W�A���P�ʂ̊p�̋t�]����Ԃ��BA��-1�`1�̊ԂłȂ���΂Ȃ�Ȃ��B�Ԃ�l��0�`PI�͈̔͂ƂȂ�B','ARCCOS');
  AddFunc  ('ARCTAN','A',     279, sys_arctan,    '���W�A���P�ʂ̊p�̋t���ڂ�Ԃ��B','ARCTAN');
  AddFunc  ('CSC',   'A',    5029, sys_csc,       '���W�A���P�ʂ̊p�̗]����Ԃ��B','CSC');
  AddFunc  ('SEC',   'A',    5030, sys_sec,       '���W�A���P�ʂ̊p�̐�����Ԃ��B','SEC');
  AddFunc  ('COT',   'A',    5031, sys_cot,       '���W�A���P�ʂ̊p�̗]�ڂ�Ԃ��B','COT');
  //('ARCCSC',   'A',    5032, sys_arccsc, '���W�A���P�ʂ̊p�̋t�]����Ԃ��B','ARCCSC');
  //('ARCSEC',   'A',    5033, sys_arcsec, '���W�A���P�ʂ̊p�̋t������Ԃ��B','ARCSEC');
  //('ARCCOT',   'A',    5034, sys_arccot, '���W�A���P�ʂ̊p�̋t�]�ڂ�Ԃ��B','ARCCOT');
  AddFunc  ('����','{=?}A��',    5035, sys_sin,   '���W�A���P�ʂ̊p�̐�����Ԃ��B','��������');
  AddFunc  ('�]��','{=?}A��',    5036, sys_cos,   '���W�A���P�ʂ̊p�̗]����Ԃ��B','�悰��');
  AddFunc  ('����','{=?}A��',    5037, sys_tan,   '���W�A���P�ʂ̊p�̐��ڂ�Ԃ��B','��������');
  AddFunc  ('�t����','{=?}A��',  5038, sys_arcsin,'���W�A���P�ʂ̊p�̋t������Ԃ��BA��-1�`1�̊ԂłȂ���΂Ȃ�Ȃ��B�Ԃ�l��-PI/2�`PI/2�͈̔͂ƂȂ�B','���Ⴍ��������');
  AddFunc  ('�t�]��','{=?}A��',  5039, sys_arccos,'���W�A���P�ʂ̊p�̋t�]����Ԃ��BA��-1�`1�̊ԂłȂ���΂Ȃ�Ȃ��B�Ԃ�l��0�`PI�͈̔͂ƂȂ�B','���Ⴍ�悰��');
  AddFunc  ('�t����','{=?}A��',  5040, sys_arctan,'���W�A���P�ʂ̊p�̋t���ڂ�Ԃ��B','���Ⴍ��������');
  AddFunc  ('�]��','{=?}A��',    5041, sys_csc,   '���W�A���P�ʂ̊p�̗]����Ԃ��B','�悩��');
  AddFunc  ('����','{=?}A��',    5042, sys_sec,   '���W�A���P�ʂ̊p�̐�����Ԃ��B','��������');
  AddFunc  ('�]��','{=?}A��',    5043, sys_cot,   '���W�A���P�ʂ̊p�̗]�ڂ�Ԃ��B','�悹��');
  //('�t�]��','{=?}A��',  5044, sys_arccsc,'���W�A���P�ʂ̊p�̋t�]����Ԃ��B','���Ⴍ�悩��');
  //('�t����','{=?}A��',  5045, sys_arcsec,'���W�A���P�ʂ̊p�̋t������Ԃ��B','���Ⴍ��������');
  //('�t�]��','{=?}A��',  5046, sys_arccot,'���W�A���P�ʂ̊p�̋t�]�ڂ�Ԃ��B','���Ⴍ�悹��');
  AddFunc  ('SIGN',      'A',5057, sys_sign,    '���lA�����Ȃ��1�A���Ȃ��-1�A�[���Ȃ��0��Ԃ��B','SIGN');
  AddFunc  ('����','{=?}A��',5058, sys_sign,    '���lA�����Ȃ��1�A���Ȃ��-1�A�[���Ȃ��0��Ԃ��B','�ӂ���');
  AddFunc  ('HYPOT',   'A,B',5047, sys_hypot,   '���p�O�p�`�̓�ӂ̒���A,B����Εӂ����߂ĕԂ��B','HYPOT');
  AddFunc  ('�Ε�',  'A��B��',5048, sys_hypot,  '���p�O�p�`�̓�ӂ̒���A,B����Εӂ����߂ĕԂ��B','����ւ�');
  AddFunc  ('ABS',   'A',     280, sys_abs,       '���lA�̐�Βl��Ԃ��B','ABS');
  AddFunc  ('��������','{=?}A��',  281, sys_int,   '���lA�̐���������Ԃ��B','���������ԂԂ�');
  AddFunc  ('��Βl',  '{=?}A��',  282, sys_abs,   '���lA�̐�Βl��Ԃ��B','����������');
  AddFunc  ('EXP',   'A',     283, sys_exp,       'e�i���R�ΐ��̒�j�� A ��̒l��Ԃ�','EXP');
  AddFunc  ('LN',    'A',     284, sys_ln,        '������ A �̎��R�ΐ��iLn(A) = 1�j��Ԃ�','LN');
  AddFunc  ('���R�ΐ�','{=?}A��', 5049, sys_ln,   '������ A �̎��R�ΐ��iLn(A) = 1�j��Ԃ�','�����񂽂�����');
  AddFunc  ('FRAC',  'A',     285, sys_frac,      '����A�̏���������Ԃ�','FRAC');
  AddFunc  ('��������', '{=?}A��', 286, sys_frac,'����A�̏���������Ԃ�','���傤�����ԂԂ�');
  AddFunc  ('����', '{=?}A��',     287, sys_rnd,  '0����A-1�̗�����Ԃ�','��񂷂�');
  AddFunc  ('����������','{����=?}A��',288, sys_randomize,  '�����̎�A�ŗ���������������B�������ȗ�����ƓK���Ȓl�ŏ����������B','��񂷂����傫��');
  AddFunc  ('SQRT',   'A',     289, sys_sqrt,    'A�̕�������Ԃ�','SQRT');
  AddFunc  ('������','{=?}A��',   5050, sys_sqrt,    'A�̕�������Ԃ�','�ւ��ق�����');
  AddFunc  ('HEX',    'A',     290, sys_hex,     'A��16�i���ŕԂ�','HEX');
  AddFunc  ('RGB',    'R,G,B', 296, sys_rgb,     'R,G,B(0-255)���w�肵�ăJ���[�R�[�h(�Ȃł����p$RRGGBB)��Ԃ�','RGB');
  AddFunc  ('WRGB',   'R,G,B',5019, sys_wrgb,    'R,G,B(0-255)���w�肵�ăJ���[�R�[�h(Windows�p$BBGGRR)��Ԃ�','WRGB');
  AddFunc  ('WRGB2RGB',   'COLOR',5051, sys_wrgb2rgb,'�J���[�R�[�h��Windows�p($BBGGRR)����Ȃł����p($RRGGBB)�ɕϊ����ĕԂ�','WRGB2RGB');
  AddFunc  ('RGB2WRGB',   'COLOR',5052, sys_wrgb2rgb,'�J���[�R�[�h���Ȃł����p($RRGGBB)����Windows�p($BBGGRR)�ɕϊ����ĕԂ�','RGB2WRGB');
  AddFunc  ('ROUND',  'A',     297, sys_round,   '�����^�̒lA���ۂ߂Ă����Ƃ��߂������l��Ԃ��B','ROUND');
  AddFunc  ('�l�̌ܓ�','A��',  298, sys_sisyagonyu, '����A�̈ꌅ�ڂ��ۂ߂ĕԂ��B','�����Ⴒ�ɂイ');
  AddFunc  ('CEIL',    'A',    299, sys_ceil,    '���l�𐳂̖���������֐؂�グ�ĕԂ��B','CEIL');
  AddFunc  ('�؂�グ','A��',  300, sys_ceil,    '���l�𐳂̖���������֐؂�グ�ĕԂ��B','���肠��');
  AddFunc  ('FLOOR',   'A',    215, sys_floor,   '���l�𕉂̖���������֐؂艺���ĕԂ��B','FLOOR');
  AddFunc  ('�؂艺��','A��',  216, sys_floor,   '���l�𕉂̖���������֐؂艺���ĕԂ��B','���肳��');
  AddFunc  ('�؂�̂�','A��',  217, sys_floor,   '���l�𕉂̖���������֐؂�̂ĂĕԂ��B','���肷��');
  AddFunc  ('�����_�l�̌ܓ�','{=?}A��B��',  5010, sys_sisyagonyu2, '����A�������_��B���Ŏl�̌ܓ����ĕԂ�','���傤�����Ă񂵂��Ⴒ�ɂイ');
  AddFunc  ('�����_�؂�グ','{=?}A��B��',  5011, sys_ceil2, '����A�������_��B���Ő؂�グ���ĕԂ�','���傤�����Ă񂫂肠��');
  AddFunc  ('�����_�؂艺��','{=?}A��B��',  5012, sys_floor2, '����A�������_��B���Ő؂艺�����ĕԂ�','���傤�����Ă񂫂肳��');
  AddFunc  ('LOG10','A',       5013, sys_log10, 'A�̑ΐ��i�10�j���v�Z���ĕԂ�','LOG10');
  AddFunc  ('��p�ΐ�','{=?}A��',5053, sys_log10,'A�̑ΐ��i�10�j���v�Z���ĕԂ�','���傤�悤��������');
  AddFunc  ('LOG2', 'A',       5014, sys_log2,  'A�̑ΐ��i�2�j���v�Z���ĕԂ�','LOG2');
  AddFunc  ('LOGN', 'A��B��',  5015, sys_logn,  '�w�肳�ꂽ��A��B�̑ΐ����v�Z���ĕԂ�','LOGN');
  AddFunc  ('�ΐ�', 'A��B��',  5054, sys_logn,  '�w�肳�ꂽ��A��B�̑ΐ����v�Z���ĕԂ�','��������');
  AddStrVar('PI',   '3.1415926535897932385',  5016,  '�~����(3.1415926535897932385)','PI');
  AddFunc  ('RAD2DEG', '{=?}A��',  5017, sys_RAD2DEG,  '���W�A��A��x�ɕϊ����ĕԂ�','RAD2DEG');
  AddFunc  ('DEG2RAD', '{=?}A��',  5018, sys_DEG2RAD,  '�xA�����W�A�����ɕϊ����ĕԂ�','DEG2RAD');
  AddFunc  ('�x�ϊ�', '{=?}A��',  5055, sys_RAD2DEG,  '���W�A��A��x�ɕϊ����ĕԂ�','�ǂւ񂩂�');
  AddFunc  ('���W�A���ϊ�', '{=?}A��',  5056, sys_DEG2RAD,  '�xA�����W�A�����ɕϊ����ĕԂ�','�炶����ւ񂩂�');

  //-�_�����Z
  AddFunc  ('NOT',    '{����}A',     291, sys_not,     'A=0�̂Ƃ�1���Ⴆ��0��Ԃ�','NOT');
  AddFunc  ('OR',     'A,B',   292, sys_or,      'A��B�̘_���a��Ԃ��B���{��́uA�܂���B�v�ɑ�������','OR');
  AddFunc  ('AND',    'A,B',   293, sys_and,     'A��B�̘_���ς�Ԃ��B���{��́uA����B�v�ɑ�������','AND');
  AddFunc  ('XOR',    'A,B',   294, sys_xor,     'A��B�̔r���I�_���a��Ԃ��B','XOR');
  //-�r�b�g���Z
  AddFunc  ('SHIFT_L','{=?}V,A', 5060, sys_shift_l, 'V��A�r�b�g���փV�t�g���ĕԂ��B(<<�Ɠ���)','SHIFT_L');
  AddFunc  ('SHIFT_R','{=?}V,A', 5061, sys_shift_r, 'V��A�r�b�g�E�փV�t�g���ĕԂ��B(>>�Ɠ���)','SHIFT_R');

  //+�����񏈗�
  //-�������{����
  AddFunc  ('������',    '{������=?}S��',    301, sys_strCountM,'������S�̕�������Ԃ�','��������');
  AddFunc  ('�o�C�g��',  '{������=?}S��',    302, sys_strCountB,'������S�̃o�C�g����Ԃ�','�΂��Ƃ���');
  AddFunc  ('�s��',      '{������=?}S��',    303, sys_LineCount,'������S�̍s����Ԃ�','���傤����');
  AddFunc  ('��������',  '{������=?}S��A��|S��', 304, sys_posM,'������S��A���������ڂ���Ԃ��B������Ȃ����0�B','�Ȃ������');
  AddFunc  ('���o�C�g��','{������=?}S��A��|S��', 305, sys_posB,'������S��A�����o�C�g�ڂ���Ԃ��B������Ȃ����0�B','�Ȃ�΂��Ƃ�');
  AddFunc  ('CHR','A', 306, sys_chr,'�����R�[�hA�ɑ΂��镶����Ԃ��B','CHR');
  AddFunc  ('ASC','A', 307, sys_asc,'����A�̕����R�[�h��Ԃ��B','ASC');
  AddFunc  ('�����}��',  '{������=?}S��CNT��A��', 308, sys_insertM,'������S��CNT�����ڂɕ�����A��}�����ĕԂ��B','���������ɂイ');
  AddFunc  ('�o�C�g�}��','{������=?}S��CNT��A��', 309, sys_insertB,'������S��CNT�o�C�g�ڂɕ�����A��}�����ĕԂ��B','�΂��Ƃ����ɂイ');
  AddFunc  ('��������',  '{������=?}S��{=1}A����B��|S��', 322, sys_posExM,'������S��A�����ڂ���B����������B������Ȃ����0�B','�������񂳂�');
  AddFunc  ('�o�C�g����','{������=?}S��{=1}A����B��|S��', 323, sys_posExB,'������S��A�o�C�g�ڂ���B����������B������Ȃ����0�B','�΂��Ƃ��񂳂�');
  AddFunc  ('�ǉ�','{�Q�Ɠn��=?}A��B��|A��', 324, sys_addStr,'�ϐ�A��B�̓��e��ǉ�����','����');
  AddFunc  ('��s�ǉ�','{�Q�Ɠn��=?}A��B��|A��', 269, sys_addStrR,'�ϐ�A��B�̓��e�Ɖ��s��ǉ�����','�������傤����');
  AddFunc  ('�����񕪉�','{=?}S��|S��|S��', 483, sys_str_splitArray, '������S���P�������z��ϐ��ɕ�������','������Ԃ񂩂�');
  AddFunc  ('���t���C��','{=?}S��CNT����', 5023, sys_refrain, '������S��CNT�����J��Ԃ��Ă���ɕԂ�','��ӂꂢ��');
  AddFunc  ('�o����','{������=?}S��A��', 5062, sys_word_count,'������S��A�̏o�Ă���񐔂�Ԃ�','������񂩂�����');
  //-�����o��
  AddFunc  ('MID', 'S,A,CNT', 310, sys_midM,'������S��A����CNT�������𔲂��o���ĕԂ�','MID');
  AddFunc  ('MIDB','S,A,CNT', 311, sys_midB,'������S��A����CNT�o�C�g���𔲂��o���ĕԂ�','MIDB');
  AddFunc  ('���������o��',  '{=?}S��A����CNT|S��', 312, sys_midM,'������S��A����CNT�������𔲂��o���ĕԂ�','�����ʂ�����');
  AddFunc  ('�o�C�g�����o��','{=?}S��A����CNT|S��', 313, sys_midB,'������S��A����CNT�o�C�g���𔲂��o���ĕԂ�','�΂��Ƃʂ�����');
  AddFunc  ('LEFT',   'S,CNT', 314, sys_leftM,'������S�̍�����CNT�������𔲂��o���ĕԂ�','LEFT');
  AddFunc  ('LEFTB',  'S,CNT', 315, sys_leftB,'������S�̍�����CNT�o�C�g���𔲂��o���ĕԂ�','LEFTB');
  AddFunc  ('RIGHT',  'S,CNT', 316, sys_rightM,'������S�̉E����CNT�������𔲂��o���ĕԂ�','RIGHT');
  AddFunc  ('RIGHTB', 'S,CNT', 317, sys_rightB,'������S�̉E����CNT�o�C�g���𔲂��o���ĕԂ�','RIGHTB');
  AddFunc  ('����������',    '{=?}S����CNT|S��', 318, sys_leftM, '������S�̍�����CNT�������𔲂��o���ĕԂ�','�����Ђ���ԂԂ�');
  AddFunc  ('�o�C�g������',  '{=?}S����CNT|S��', 319, sys_leftB, '������S�̍�����CNT�o�C�g���𔲂��o���ĕԂ�','�΂��ƂЂ���ԂԂ�');
  AddFunc  ('�����E����',    '{=?}S����CNT|S��', 320, sys_rightM,'������S�̉E����CNT�������𔲂��o���ĕԂ�','�����݂��ԂԂ�');
  AddFunc  ('�o�C�g�E����',  '{=?}S����CNT|S��', 321, sys_rightB,'������S�̉E����CNT�o�C�g���𔲂��o���ĕԂ�','�΂��Ƃ݂��ԂԂ�');
  AddFunc  ('�o�C�g���͔����o��','{=?}S��A����CNT|S��', 268, sys_mid_sjis,'������S��A����CNT�o�C�g���𔲂��o���ĕԂ��B(�S�p���������Ȃ��悤�z��)','�΂��ƂԂ񂵂傤�ʂ�����');
  AddFunc  ('����','{=?}S����A��|S��', 327, sys_enumWord,'������S����A��','�����������');
  //-��؂�E�؂���E�폜
  AddFunc  ('�؂���','{�Q�Ɠn�� ������=?}S����A�܂�|S��A�܂ł�|S��A��',330, sys_getToken,'������S�����؂蕶��A�܂ł�؂����ĕԂ��BS�ɕϐ����w�肵���ꍇ��S�̓��e���؂�����B','����Ƃ�');
  AddFunc  ('��؂�','{������=?}S��A��',  331, sys_split,'������S����؂蕶��A�ŋ�؂��Ĕz��Ƃ��ĕԂ��B','������');
  AddFunc  ('�����폜',  '{�Q�Ɠn�� ������=?}S��A����B|S��', 332, sys_deleteM,'������S��A�����ڂ���B���������폜����BS�ɕϐ����w�肷���S�̓��e���ύX����B','������������');
  AddFunc  ('�o�C�g�폜','{�Q�Ɠn�� ������=?}S��A����B|S��', 333, sys_deleteB,'������S��A�����ڂ���B�o�C�g�����폜����BS�ɕϐ����w�肷���S�̓��e���ύX����B','�΂��Ƃ�������');
  AddFunc  ('�͈͐؂���','{�Q�Ɠn�� ������=?}S��A����B�܂�|S��A����B��|B�܂ł�',334, sys_getTokenRange,'������S�̋�؂蕶��A�����؂蕶��B�܂ł�؂����ĕԂ��BS�ɕϐ����w�肵���ꍇ��S�̓��e���؂�����BS��B�����݂��Ȃ��Ƃ��AS�̍Ō�܂Ő؂���BA�����݂��Ȃ��Ƃ��͐؂���Ȃ��B','�͂񂢂���Ƃ�');
  AddFunc  ('�͈͓��؂���','{�Q�Ɠn�� ������=?}S��A����B�܂�|S��A����B��|B�܂ł�',335, sys_getTokenInRange,'������S�̋�؂蕶��A�����؂蕶��B�܂ł�؂����ĕԂ��BS�ɕϐ����w�肵���ꍇ��S�̓��e���؂�����BS�ɋ�؂蕶�������݂��Ȃ��Ƃ��A�؂�����s��Ȃ��B','�͂񂢂Ȃ�����Ƃ�');
  AddFunc  ('�����E�[�폜','{�Q�Ɠn��=?}S����A|S��|S��|S��',387, sys_deleteRightM,'������S�̉E�[A�������폜����BS�ɕϐ����w�肷���S�̓��e���ύX����B','�����݂��͂���������');
  AddFunc  ('�o�C�g�E�[�폜','{�Q�Ɠn��=?}S����A|S��|S��|S��',388, sys_deleteRightB,'������S�̉E�[A�o�C�g���폜����BS�ɕϐ����w�肷���S�̓��e���ύX����B','�΂��Ƃ݂��͂���������');
  //-�u���E����
  AddFunc  ('�u��',    '{������=?}S��A��B��|S��A����B��',   340, sys_replace,  '������S�ɂ���A��S��B�ɒu�����ĕԂ��B','������');
  AddFunc  ('�P�u��',  '{������=?}S��A��B��|S��A����B��', 341, sys_replaceOne,'������S�ɂ���A���P����B�ɒu�����ĕԂ��B','���񂿂���');
  AddFunc  ('�g����',  '{������=?}S��', 342, sys_trim,'�w�󔒏����x�̗��p�𐄏��B������S�̑O��̔��p�󔒕������������ĕԂ��B','�Ƃ��');
  AddFunc  ('�󔒏���','{������=?}S��', 339, sys_trim,'������S�̑O��̔��p�󔒕������������ĕԂ��B','�����͂����傫��');
  AddFunc  ('�͈͒u��','{������=?}S��A����B�܂ł�C��|S��A����B��C��',489, sys_RangeReplace,'������S��A����B�܂ł�C�ɒu�����ĕԂ��B','�͂񂢂�����');
  AddFunc  ('�͈͓��u��','{������=?}S��A����B�܂ł�C��|S��A����B��C��',5022, sys_InRangeReplace,'������S��A����B�܂ł�C�ɒu�����ĕԂ��BS��A�܂���B�����݂��Ȃ��Ƃ��A�u�����s��Ȃ��B','�͂񂢂Ȃ�������');

  //-���̑�
  AddFunc  ('�m��','{�Q�Ɠn��}S��CNT��', 343, sys_AllocMem,'������S�ɏ������ݗ̈��CNT�o�C�g���m�ۂ���','������');
  AddFunc  ('�o�C�i���擾','{�Q�Ɠn��}S��I��F��',    430, sys_getBinary,'�o�C�i���f�[�^S��I�o�C�g�ڂ�F�̌`��(CHAR|CHAR*|INT|BYTE|WORD|DWORD)�Ŏ擾����B','�΂��Ȃ肵��Ƃ�');
  AddFunc  ('�o�C�i���ݒ�','V��{�Q�Ɠn��}S��I��F��', 431, sys_setBinary,'�lV���o�C�i���f�[�^S��I�o�C�g�ڂ�F�̌`��(CHAR|CHAR*|INT|BYTE|WORD|DWORD)�Őݒ肷��B','�΂��Ȃ肹���Ă�');
  //-���K�\��
  AddFunc  ('���K�\���}�b�`','{=?}A��B��|A��B��', 344, sys_reMatch,'Perl�݊��̐��K�\���B������A���p�^�[��B�Ń}�b�`���Č��ʂ�Ԃ��B$1��$2�Ȃǂ͔z��`���ŕԂ��BBREGEXP.DLL�𗘗p�B','�������Ђ傤����܂���','BREGEXP.DLL');
  AddFunc  ('���K�\���u��','{=?}S��A��B��|A����B��|B��',   345, sys_reSub,  'Perl�݊��̐��K�\���B������S�̃p�^�[��A��B�Œu�����Č��ʂ�Ԃ��BBREGEXP.DLL�𗘗p�B','�������Ђ傤���񂿂���','BREGEXP.DLL');
  AddFunc  ('���K�\����؂�','{=?}A��B��', 346, sys_reSplit,'Perl�݊��̐��K�\���B������A���p�^�[��B�ŋ�؂��Č��ʂ�Ԃ��BBREGEXP.DLL�𗘗p�B','�������Ђ傤���񂭂���','BREGEXP.DLL');
  AddFunc  ('���K�\������','{=?}S��A��B��|A����B��|B��',   347, sys_reTR,   'Perl�݊��̐��K�\���B������S�ɂ���p�^�[��A���p�^�[��B�Œu�������Č��ʂ�Ԃ��BBREGEXP.DLL�𗘗p�B','�������Ђ傤���񂢂ꂩ��','BREGEXP.DLL');
  AddFunc  ('���K�\���P�u��','{=?}S��A��B��|A����B��|B��',   338, sys_reSubOne,  'Perl�݊��̐��K�\���B������S�̃p�^�[��A��B�łP�x�����u�����Č��ʂ�Ԃ��BBREGEXP.DLL�𗘗p�B','�������Ђ傤���񂽂񂿂���','BREGEXP.DLL');
  AddFunc  ('RE','{=?}A,B', 348, sys_reMatch,'�w���K�\���}�b�`�x�𐄏��B�����I�ɔp�~�������BPerl�݊��̐��K�\���B������A���p�^�[��B�Ń}�b�`���O�����ʂ�Ԃ��B$1��$2�Ȃǂ͔z��`���ŕԂ��BBREGEXP.DLL�𗘗p�B','RE','BREGEXP.DLL');
  AddStrVar('���o������','',795,'�w���K�\���}�b�`�x��w���C���h�J�[�h��v�x�Œ��o���������񂪑�������B','���イ����������');
  AddFunc  ('���K�\����v','{=?}A��B��|A��B��', 349, sys_reMatchBool,'Perl�݊��̐��K�\���B������A���p�^�[��B�Ɉ�v���邩�ǂ����Ԃ��B$1��$2�Ȃǂ͔z��`���ŕԂ��BBREGEXP.DLL�𗘗p�B','�������Ђ傤���񂢂���','BREGEXP.DLL');
  AddStrVar('���K�\���C���q','gmk', 337, '���K�\���̏C���q���w��B','�������Ђ傤���񂵂イ���傭��');
  //-�Ȃł������
  AddFunc  ('���艼���ȗ�','{������=?}S����|S��',325, sys_DeleteGobi,'������S���犿���̑��艼�����ȗ����ĕԂ��B','�����肪�Ȃ��傤��Ⴍ');
  AddFunc  ('�g�[�N������','{������=?}S��',326, sys_tokenSplit,'������S���g�[�N���𕪊����Ĕz��`���ŕԂ�','�Ɓ[����Ԃ񂩂�');
  //-�w��`��
  AddFunc  ('FORMAT','{������=?}S��A��',469,    sys_format,       '�f�[�^S��A�̌`���ŏo�͂���','FORMAT');
  AddFunc  ('�`���w��','{������=?}S��A��',470,  sys_format,     '�f�[�^S��A�̌`���ŏo�͂���','�����������Ă�');
  AddFunc  ('�[������','{������=?}S��A��',471,  sys_formatzero, '�f�[�^S��A���̃[���Ŗ��߂ďo�͂���','���낤��');
  AddFunc  ('�ʉ݌`��','{������=?}S��',472,     sys_formatmoney,   '�f�[�^S���J���}�ŋ�؂��ďo�͂���','������������');
  AddFunc  ('������Z���^�����O','{������=?}S��A��',473, sys_str_center, '������S��A���̒����ɗ���悤�ɏo�͂���','��������񂽂��');
  AddFunc  ('������E��','{������=?}S��A��',474, sys_str_right, '������S��A���̉E�[�ɗ���悤�ɏo�͂���','������݂��悹');
  //-������ޔ���
  AddFunc  ('�S�p������','{=?}S��|S��|S��',475, sys_zen_kana, '������S�̈ꕶ���ڂ��S�p���ǂ������肵�ĕԂ��B','���񂩂����͂�Ă�');
  AddFunc  ('���Ȃ�����','{=?}S��|S��|S��',476, sys_hira_kana, '������S�̈ꕶ���ڂ��Ђ炪�Ȃ����肵�ĕԂ��B','���Ȃ��͂�Ă�');
  AddFunc  ('�J�^�J�i������','{=?}S��|S��|S��',477, sys_kata_kana, '������S�̈ꕶ���ڂ��J�^�J�i�����肵�ĕԂ��B','�������Ȃ��͂�Ă�');
  AddFunc  ('����������','{=?}S��|S��|S��',478, sys_suuji_kana, '������S�̈ꕶ���ڂ����������肵�ĕԂ��B','���������͂�Ă�');
  AddFunc  ('���񂩔���','{=?}S��|S��|S��',479, sys_suuretu_kana, '������S�S�������������肵�ĕԂ��B','��������͂�Ă�');
  AddFunc  ('�p��������','{=?}S��|S��|S��',480, sys_eiji_kana, '������S�̈ꕶ���ڂ��A���t�@�x�b�g�����肵�ĕԂ��B','���������͂�Ă�');
  //-�������r
  AddFunc  ('�������r','{=?}A��B��|B��',481, sys_str_comp, '������A��B���r���ē����Ȃ�0��A���傫�����1��B���傫�����-1��Ԃ��B','������Ђ���');
  AddFunc  ('�����񎫏�����r','{=?}A��B��|B��',482, sys_str_comp_jisyo, '������A��B���������Ŕ�r���ē����Ȃ�0��A���傫�����1��B���傫�����-1��Ԃ��B','����������傶���Ђ���');

  //+�z��E�n�b�V���E�O���[�v
  //-�z���{����
  AddFunc  ('�z�񌋍�','{=?}A��S��',  350, sys_join,'�z��A�𕶎���S�Ōq���ĕ�����Ƃ��ĕԂ��B','�͂��������');
  AddFunc  ('�z�񌟍�','{=?}A��{����=0}I����KEY��|A��',  351, sys_ary_find,'�z��A�̗v�fI�Ԃ���KEY���������Ă��̃C���f�b�N�X�ԍ���Ԃ��B������Ȃ����-1��Ԃ��B','�͂�����񂳂�');
  AddFunc  ('�z��v�f��','{=?}A��',  352, sys_ary_count,'�z��A�̗v�f����Ԃ��B','�͂���悤������');
  AddFunc  ('�z��}��','{�Q�Ɠn��=?}A��I��S��|I����',  353, sys_ary_insert,'�z��A��I�Ԗڂ�S��}������BA�̓��e������������B','�͂�������ɂイ');
  AddFunc  ('�z��ꊇ�}��','{�Q�Ɠn��=?}A��I��S��|I����',  354, sys_ary_insertEx,'�z��A��I�Ԗ�(0�N�_)�ɔz��S�̓��e���ꊇ�}������BA�̓��e������������B','�͂�������������ɂイ');
  AddFunc  ('�z��\�[�g','{�Q�Ɠn��=?}A��|A��',  355, sys_ary_sort,'�z��A�𕶎��񏇂Ƀ\�[�g����BA�̓��e������������B','�͂�����[��');
  AddFunc  ('�z�񐔒l�\�[�g','{�Q�Ɠn��=?}A��|A��',  356, sys_ary_sort_num,'�z��A�𐔒l���Ƀ\�[�g����BA�̓��e������������B','�͂�����������[��');
  AddFunc  ('�z��J�X�^���\�[�g','{�Q�Ɠn��=?}A��S��|A��',  357, sys_ary_sort_custom,'�z��A���v���O����S(������ŗ^����-��r�p�ϐ���A��B)�Ń\�[�g����BA�̓��e������������B','�͂���������ނ��[��');
  AddFunc  ('�z��t��','{�Q�Ɠn��=?}A��',  358, sys_ary_reverse,'�z��A�̕��т��t���ɂ���BA�̓��e������������B','�͂�����Ⴍ�����');
  AddFunc  ('�z��ǉ�','{�Q�Ɠn��=?}A��S��', 359, sys_ary_add,'�z��A�ɗv�fS��ǉ�����BA�̓��e������������B','�͂������');
  AddFunc  ('�z��폜','{�Q�Ɠn��=?}A��I��', 360, sys_ary_del,'�z��A��I�Ԗ�(0�N�_)�̗v�f���폜����BA�̓��e������������B','�͂����������');
  AddFunc  ('�z��V���b�t��','{�Q�Ɠn��=?}A��|A��', 361, sys_ary_random,'�z��A�̏��Ԃ������_���ɃV���b�t������BA�̓��e������������B','�͂��������ӂ�');
  AddFunc  ('�ϐ����z','{=?}A��S��|A����S��', 369, sys_ary_varSplit,'�z��A�̗v�f�̊e�l�𕶎���r�̕ϐ����X�g�u�ϐ�,�ϐ�,�ϐ�...�v�֕��z����B','�ւ񂷂��Ԃ�ς�');
  AddFunc  ('�z��㉺��s�폜','{�Q�Ɠn��=?}A��|A��', 336, sys_ary_trim,'�z��A�̏㉺�ɂ����s���폜����B','�͂�����傤���������傤��������');
  AddFunc  ('�z��؂���','{�Q�Ɠn��=?}A��I��', 488, sys_ary_cut,'�z��A��I�Ԗ�(0�N�_)�̗v�f��؂����ĕԂ��BA�̓��e������������B','�͂������Ƃ�');
  AddFunc  ('�z�����ւ�','{�Q�Ɠn��=?}A��I��J��', 5064, sys_ary_exchange,'�z��A��I�Ԗ�(0�N�_)�̗v�f��J�Ԗ�(0�N�_)�̗v�f�����ւ��ĕԂ��BA�̓��e������������B','�͂�����ꂩ��');
  AddFunc  ('�z����o��','{�Q�Ɠn��=?}A��I����CNT��', 5065, sys_ary_slice,'�z��A��I�Ԗ�(0�N�_)����CNT�̗v�f�����o���ĕԂ��BA�̓��e������������B','�͂���Ƃ肾��');
  //-�z��v�Z
  AddFunc  ('�z�񍇌v','{=?}A��', 362, sys_ary_sum,'�z��A�̒l�̍��v�𒲂ׂē�����Ԃ��B','�͂����������');
  AddFunc  ('�z�񕽋�','{=?}A��', 363, sys_ary_mean,'�z��A�̒l�̕��ς𒲂ׂē�����Ԃ��B','�͂���ւ�����');
  AddFunc  ('�z��W���΍�','{=?}A��', 364, sys_ary_StdDev,'�z��A�̒l�̕W���΍��𒲂ׂē�����Ԃ��B','�͂���Ђ傤�����ւ�');
  AddFunc  ('�z��NORM','{=?}A��', 365, sys_ary_norm,'�z��A�̒l�̃��[�N���b�h�́uL-2�v�m�����𒲂ׂē�����Ԃ��B','�͂����NORM');
  AddFunc  ('�z��ő�l','{=?}A��', 366, sys_ary_max,'�z��A�̒l�̍ő�l�𒲂ׂĕԂ��B','�͂������������');
  AddFunc  ('�z��ŏ��l','{=?}A��', 367, sys_ary_min,'�z��A�̒l�̍ŏ��l�𒲂ׂĕԂ��B','�͂���������傤��');
  AddFunc  ('�z�񕪎U','{=?}A��', 368, sys_ary_PopnVariance,'�z��A�̒l�̕��U�x�𒲂ׂĕԂ��B','�͂���Ԃ񂳂�');

  //-�񎟌��z��(�\)����
  AddFunc  ('�\CSV�ϊ�','{=?}A��', 370, sys_ary_csv,'�񎟌��z��A��CSV�`��(�J���}��؂�e�L�X�g)�Ŏ擾���ĕԂ��B','�Ђ傤CSV�ւ񂩂�');
  AddFunc  ('�\TSV�ϊ�','{=?}A��', 371, sys_ary_tsv,'�񎟌��z��A��TSV�`��(�^�u��؂�e�L�X�g)�Ŏ擾���ĕԂ��B','�Ђ傤TSV�ւ񂩂�');
  AddFunc  ('CSV�擾','{=?}S��|S��|S��', 379, sys_csv2ary,'CSV�`���̃f�[�^�������I�ɓ񎟌��z��ɕϊ����ĕԂ��B','CSV����Ƃ�');
  AddFunc  ('TSV�擾','{=?}S��|S��|S��', 380, sys_tsv2ary,'TSV�`���̃f�[�^�������I�ɓ񎟌��z��ɕϊ����ĕԂ��B','TSV����Ƃ�');
  AddFunc  ('�\�\�[�g','{�Q�Ɠn��=?}A��I��', 372, sys_csv_sort,'�񎟌��z��A��I���(0�N�_)���L�[�ɕ����񏇂Ƀ\�[�g����BA�̓��e������������B','�Ђ傤���[��');
  AddFunc  ('�\���l�\�[�g','{�Q�Ɠn��=?}A��I��', 373, sys_csv_sort_num,'�񎟌��z��A��I���(0�N�_)���L�[�ɐ��l���Ƀ\�[�g����BA�̓��e������������B','�Ђ傤���������[��');
  AddFunc  ('�\�s�b�N�A�b�v','{=?}A��{=-1}I����S��|A��', 374, sys_csv_pickup,'�񎟌��z��A��I���(0�N�_)����L�[S���܂ލs(S�Ƃ����������܂ރZ��)���s�b�N�A�b�v���ĕԂ��BI=-1�őS�t�B�[���h��Ώۂɂ���B','�Ђ傤�҂���������');
  AddFunc  ('�\���S��v�s�b�N�A�b�v','{=?}A��{=-1}I����S��|A��', 375, sys_csv_pickupComplete,'�񎟌��z��A��I���(0�N�_)����L�[S���܂ލs(S�Ɗ��S�Ɉ�v����Z��������)���s�b�N�A�b�v���ĕԂ��BI=-1�őS�t�B�[���h��Ώۂɂ���B','�Ђ傤���񂺂񂢂����҂���������');
  AddFunc  ('�\����','{=?}A��{=-1}COL��S��{=0}ROW����|COL��', 376, sys_csv_find, '�񎟌��z��A��COL���(0�N�_)����L�[S���܂ލs��ROW�s�ڂ��猟�����ĉ��s�ڂɂ��邩�Ԃ��B������Ȃ����-1��Ԃ��BCOL=-1�őS�t�B�[���h��Ώۂɂ���B','�Ђ傤���񂳂�');
  AddFunc  ('�\�B������','{=?}A��{=-1}COL��S��{=0}ROW����|COL��', 394, sys_csv_vague_find, '�񎟌��z��A��COL���(0�N�_)���烏�C���h�J�[�hS�Ƀ}�b�`����s��ROW�s�ڂ��猟�����ĉ��s�ڂɂ��邩�Ԃ��B������Ȃ����-1��Ԃ��BCOL=-1�őS�t�B�[���h��Ώۂɂ���B','�Ђ傤�����܂����񂳂�');
  AddFunc  ('�\��','{=?}A��', 377, sys_csv_cols,'�񎟌��z��A�̗񐔂��擾���ĕԂ��B','�Ђ傤�����');
  AddFunc  ('�\�s��','{=?}A��', 378, sys_ary_count,'�񎟌��z��A�̍s�����擾���ĕԂ��B(�z��v�f���Ɠ���)','�Ђ傤���傤����');
  AddFunc  ('�\�s�����','{=?}A��|A��', 381, sys_csv_rowcol_rev,'�񎟌��z��A�̍s��𔽓]���ĕԂ��B','�Ђ傤���傤��͂�Ă�');
  AddFunc  ('�\�E��]','{=?}A��|A��',   382, sys_csv_rotate,    '�񎟌��z��A���X�O�x��]���ĕԂ��B','�Ђ傤�݂������Ă�');
  AddFunc  ('�\�d���폜','{=?}A��I��|I��', 383, sys_csv_uniq, '�񎟌��z��A��I��ڂɂ���d�����ڂ��폜���ĕԂ��B','�Ђ傤���イ�ӂ���������');
  AddFunc  ('�\��擾','{=?}A��I��', 384, sys_csv_getcol, '�񎟌��z��A��(0���琔����)I��ڂ��������o���Ĕz��ϐ��Ƃ��ĕԂ��B','�Ђ傤�����Ƃ�');
  AddFunc  ('�\��}��','{=?}A��I��S��|I��', 385, sys_csv_inscol, '�񎟌��z��A��(0���琔����)I��ڂɔz��S��}�����ĕԂ��B','�Ђ傤������ɂイ');
  AddFunc  ('�\��폜','{=?}A��I��', 386, sys_csv_delcol, '�񎟌��z��A��(0���琔����)I��ڂ��폜���ĕԂ��B','�Ђ傤���������');
  AddFunc  ('�\�񍇌v','{=?}A��I��|I��', 389, sys_csv_sum, '�񎟌��z��A��(0���琔����)I��ڂ����v���ĕԂ��B','�Ђ傤���������');
  AddFunc  ('�\���C���h�J�[�h�s�b�N�A�b�v','{=?}A��{=-1}I����S��|A��', 5066, sys_csv_pickupWildcard,'�񎟌��z��A��I���(0�N�_)���烏�C���h�J�[�h�p�^�[��S�Ƀ}�b�`(��v)����s���s�b�N�A�b�v���ĕԂ��BI=-1�őS�t�B�[���h��Ώۂɂ���B','�Ђ傤�킢��ǂ��[�ǂ҂���������');
  AddFunc  ('�\���K�\���s�b�N�A�b�v','{=?}A��{=-1}I����S��|A��', 5067, sys_csv_pickupRegExp,'�񎟌��z��A��I���(0�N�_)���琳�K�\���p�^�[��S�Ƀ}�b�`����s���s�b�N�A�b�v���ĕԂ��BI=-1�őS�t�B�[���h��Ώۂɂ���B','�Ђ傤�������Ђ傤����҂���������');

  //-�n�b�V��
  AddFunc  ('�n�b�V���L�[��','{=?}A��', 390, sys_hash_enumkey,'�n�b�V��A�̃L�[�ꗗ��Ԃ�','�͂����カ�[�������');
  AddFunc  ('�v�f��','{�Q�Ɠn��=?}S��', 391, sys_count,'�n�b�V���E�z��̗v�f���A������̍s����Ԃ��B','�悤������');
  AddFunc  ('�n�b�V�����e��','{=?}A��', 392, sys_hash_enumvalue,'�n�b�V��A�̓��e�ꗗ��Ԃ�','�͂�����Ȃ��悤�������');
  AddFunc  ('�n�b�V���L�[�폜','{�Q�Ɠn��=?}A��B��', 393, sys_hash_deletekey,'�n�b�V��A�̃L�[B���폜����BA�̓��e������������B','�͂����カ�[��������');

  //-�O���[�v
  AddFunc  ('�����o��','{�O���[�v}S��',           395, sys_EnumMember,'�O���[�vS�̃����o�ꗗ��Ԃ��B','�߂�΂������');
  AddFunc  ('�����o�ڍח�','{�O���[�v}S��',       396, sys_EnumMemberEx,'�O���[�vS�̃����o�ꗗ�Ƃ��̌^�ƒl��Ԃ��B','�߂�΂��傤�����������');
  AddFunc  ('�쐬','{�Q�Ɠn��}A��{�O���[�v}B�Ƃ���|B��', 397, sys_groupCreate,'�ϐ�A���O���[�vB�Ƃ��ē��I�ɍ쐬����B','��������');
  AddIntVar('���g', 0, 398, '�O���[�v���Ŏ������g���w�肵�������ɗp����','������');
  AddFunc  ('�O���[�v����','{�O���[�v}A��|A��', 399, sys_group_ornot,'�ϐ�A���O���[�v���ǂ������肵�O���[�v�Ȃ�΃O���[�v�̖��O��Ԃ�','����[�Ղ͂�Ă�');

  //+�N���b�v�{�[�h
  //-�N���b�v�{�[�h
  AddFunc  ('�R�s�[','{=?}S��',  400, sys_setClipbrd,'�N���b�v�{�[�h�ɕ�����r���R�s�[����B','���ҁ[');
  AddFunc  ('�N���b�v�{�[�h�擾','',  401, sys_getClipbrd,'�N���b�v�{�[�h���當������擾����','������Ղځ[�ǂ���Ƃ�');
  SetSetterGetter('�N���b�v�{�[�h','�R�s�[','�N���b�v�{�[�h�擾',404, '�N���b�v�{�[�h�ɓǂݏ������s��', '������Ղځ[��');
  //-�A�v���ԃf�[�^�ʐM
  AddFunc  ('COPYDATA���M','A��S��|A��',  402, sys_copydata_send, '�E�B���h�E�n���h��A��S�Ƃ������b�Z�[�W��COPYDATA�𑗐M����','COPYDATA��������');
  AddFunc  ('COPYDATA�ڍב��M','A��S��ID��|A��',  403, sys_copydata_sendex, '�E�B���h�E�n���h��A��S�Ƃ������b�Z�[�W��ID��������COPYDATA�𑗐M����','COPYDATA���傤������������');

  //+���t���ԏ���
  //-����
  AddFunc  ('��','',    410, sys_now,  '���̎��Ԃ��uhh:nn:ss�v�̌`���ŕԂ��B','����');
  //AddFunc  ('�V�X�e������','',                171, sys_timeGetTime,'OS���N�����Ă���̎��Ԃ��擾���ĕԂ��B','�����Ăނ�����');
  AddFunc  ('�b�҂�','{=?}A', 413, sys_sleep, 'A�b�Ԏ��s���~�߂�B','�т傤�܂�');
  //-���t
  AddFunc  ('����','',  411, sys_today,'�����̓��t���uyyyy/mm/dd�v�̌`���ŕԂ��B','���傤');
  AddFunc  ('���N','',  419, sys_thisyear, '���N�����N����Ԃ��B','���Ƃ�');
  AddFunc  ('����','',  420, sys_thismonth,'��������������Ԃ��B','���񂰂�');
  AddFunc  ('���N','',  421, sys_nextyear,'���N�����N���𐼗�ŕԂ��B','�炢�˂�');
  AddFunc  ('���N','',  422, sys_lastyear,'���N�����N���𐼗�ŕԂ��B','����˂�');
  AddFunc  ('����','',  423, sys_nextmonth,'��������������Ԃ��B','�炢����');
  AddFunc  ('�挎','',  424, sys_lastmonth,'�挎����������Ԃ��B','���񂰂�');
  AddFunc  ('�j��','{=?}S��', 412, sys_week, 'S�Ɏw�肵�����t�̗j�����w���`���x�ŕԂ��B�s���ȓ��t�̏ꍇ�͍����̗j����Ԃ��B','�悤��');
  AddFunc  ('�j���ԍ��擾','{=?}S��', 5063, sys_weekno, 'S�Ɏw�肵�����t�̗j���ԍ����ŕԂ��B�s���ȓ��t�̏ꍇ�͍����̗j���ԍ���Ԃ��B(0=��/1=��/2=��/3=��/4=��/5=��/6=�y)','�悤�т΂񂲂�����Ƃ�');
  AddFunc  ('�a��ϊ�','{=?}S��',    418, sys_date_wa, 'S��a��ɕϊ�����BS�͖����ȍ~�̓��t���L���B','��ꂫ�ւ񂩂�');
  AddFunc  ('�����`���ϊ�','{=?}DATE��FORMAT��|DATE����|FORMAT��|FORMAT��',    409, sys_date_format, '����(DATE)���w��`��(FORMAT)�ɕϊ�����B�t�H�[�}�b�g�ɂ́uRSS�`���v��uyyyy/mm/dd hh:nn:ss�v���w�肷��','�ɂ������������ւ񂩂�');
  AddFunc  ('UNIXTIME�ϊ�','{=?}DATE��', 427, sys_toUnixTime, '������Unix Time�ɕϊ�����','UNIXTIME�ւ񂩂�');
  AddFunc  ('UNIXTIME_�����ϊ�','{=?}I��', 428, sys_fromUnixTime, 'Unix Time�ł���I���Ȃł��������`���ɕϊ�����','UNIXTIME_�ɂ����ւ񂩂�');
  //-���t���Ԍv�Z
  AddFunc  ('���ԉ��Z','{=?}S��A��', 415, sys_timeAdd, '����S��A�������ĕԂ��BA�ɂ́u(+|-)hh:nn:dd�v�Ŏw�肷��B','�����񂩂���');
  AddFunc  ('���t���Z','{=?}S��A��', 414, sys_dateAdd, '���tS��A�������ĕԂ��BA�ɂ́u(+|-)yyyy/mm/dd�v�Ŏw�肷��B','�ЂÂ�������');
  AddFunc  ('������',  '{=?}A��B��|A����B�܂ł�', 416, sys_dateSub, '���tA��B�̍�������ŋ��߂ĕԂ��B','�ɂ�������');
  AddFunc  ('�b��',    '{=?}A��B��|A����B�܂ł�', 417, sys_timeSub, '����A��B�̍���b���ŋ��߂ĕԂ��B','�т傤��');
  AddFunc  ('����','{=?}A��B��|A����B�܂ł�', 425, sys_MinutesSub, '����A��B�̕����̍������߂ĕԂ�','�ӂ�');
  AddFunc  ('���ԍ�','{=?}A��B��|A����B�܂ł�', 426, sys_HourSub, '����A��B�̎��Ԃ̍������߂ĕԂ�','������');

  //+�_�C�A���O�E�E�B���h�E
  //-�_�C�A���O
  //AddFunc  ('����','{������=?}S��|S��',       150, sys_say,        '���b�Z�[�WS���_�C�A���O�ɕ\������B','����');
  AddFunc('���',    '{������=?}S��|S��|S��', 450,sys_yesno,'�͂��E�������̂ǂ��炩����̃_�C�A���O���o���B','�ɂ���');
  AddFunc('�q�˂�',  '{������=?}S��|S��|S��', 451,sys_input,'�_�C�A���O�Ɏ���r��\�����ă��[�U�[����̓��͂𓾂�B','�����˂�');
  AddFunc('�O��',    '{������=?}S��|S��|S��', 455,sys_yesnocancel,'�͂��E�������E�L�����Z���̂����ꂩ�O���̃_�C�A���O���o���B','���񂽂�');
  AddFunc('�����L��','{������=?}S��|S��|S��|S��', 457,sys_msg_memo,'�����\���_�C�A���O���o���B','�߂����ɂイ');
  AddFunc('���X�g�I��','{������=?}S��|S��|S��|S��|S����', 458,sys_msg_list,'���X�g�I���_�C�A���O���o���B�����͔z��Ŏw�肷��B','�肷�Ƃ��񂽂�');
  AddFunc('�o�[�W�����_�C�A���O�\��','{=?}TITLE��MEMO��|MEMO��', 459,sys_version_dialog,'Windows�o�[�W�����_�C�A���O�Ƀ^�C�g��TITLE�ƕ�����MEMO��\������B','�΁[����񂾂����낮�Ђ傤��');
  //-�t�@�C���֘A�_�C�A���O
  AddFunc('�t�@�C���I��','{������=�u�v}S��{������=�u�v}A��',     452,sys_selFile,'�g���qS�̃t�@�C����I�����ĕԂ�(A�͏����t�@�C����)','�ӂ����邹�񂽂�');
  AddFunc('�ۑ��t�@�C���I��','{������=�u�v}S��{������=�u�v}A��', 453,sys_selFileAsSave,'�ۑ��p�Ɋg���qS�̃t�@�C����I�����ĕԂ�(A�͏����t�@�C����)','�ق���ӂ����邹�񂽂�');
  AddFunc('�t�H���_�I��','{������=�u�v}S��|S��',     454,sys_selDir,'�����t�H���_S�Ńt�H���_��I�����ĕԂ�','�ӂ��邾���񂽂�');
  //-�E�B���h�E
  AddFunc('�E�B���h�E��', '', 456,sys_enumwindows,'�E�B���h�E�̈ꗗ��񋓂���B(�n���h��,�N���X��,�e�L�X�g)�̌`���ŗ񋓂���','������ǂ��������');
  //-�_�C�A���O�I�v�V����
  AddStrVar('�_�C�A���O�L�����Z���l','',460,'�_�C�A���O���L�����Z�������Ƃ��̒l���w��','�������낮����񂹂邿');
  AddStrVar('�_�C�A���O�����l','',461,'�_�C�A���O�̏����l���w��','�������낮���傫��');
  AddStrVar('�_�C�A���OIME','',462,'�_�C�A���O�̓��̓t�B�[���h��IME��Ԃ̎w��(IME�I��|IME�I�t|IME����|IME�J�i|IME���p)','�������낮IME');
  AddStrVar('�_�C�A���O�^�C�g��','',463,'�_�C�A���O�̃^�C�g�����w�肷��','�������낮�����Ƃ�');
  AddIntVar('�_�C�A���O���l�ϊ�',1,464,'�_�C�A���O�̌��ʂ𐔒l�ɕϊ����邩�ǂ����B�I��(=1)�I�t(=0)���w�肷��B','�������낮�������ւ񂩂�');
  AddIntVar('�_�C�A���O�\������',0,467,'(�W��GUI���p���̂�)�u�����v�u����v�u�q�˂�v�_�C�A���O�Ń_�C�A���O�̍ő�\�����Ԃ�b�Ŏw�肷��B0�Ő������Ԃ�݂��Ȃ��B','�������낮�Ђ傤��������');

  //+�T�E���h
  //-�T�E���h
  AddFunc('BEEP','', 496,sys_beep,'BEEP����炷','BEEP');
  AddFunc('WAV�Đ�','FILE��|FILE��', 497,sys_wav,'WAV�t�@�C�����Đ�����','WAV��������');
  AddFunc('�Đ�', 'FILE��', 498, sys_musPlay,'���y�t�@�C��FILE���Đ�����B','��������');
  AddFunc('��~', '',    499, sys_musStop,'�u�Đ��v�������y���~����B','�Ă���');
  AddFunc('���t', 'FILE��', 495, sys_musPlay,'���y�t�@�C��FILE�����t����B�w�Đ��x�Ɠ����B','���񂻂�');
  AddFunc('�b�^��', 'FILE��SEC|FILE��', 485, sys_musRec,'�t�@�C��FILE(WAV�`��)��SEC�b�����^������B','�т傤�낭����');
  //-MCI
  AddFunc('MCI�J��','FILE��A��',  490,sys_mciOpen, '���y�t�@�C��FILE���G�C���A�XA�ŊJ���B(MIDI/WAV/MP3/WMA�Ȃǂ��Đ��\)','MCI�Ђ炭');
  AddFunc('MCI�Đ�','A��',        491,sys_mciPlay, '�uMCI�J���v�ŊJ�����G�C���A�XA���Đ�����B','MCI��������');
  AddFunc('MCI��~','A��',        492,sys_mciStop, '�uMCI�J���v�ŊJ�����G�C���A�XA���~����','MCI�Ă���');
  AddFunc('MCI����','A��',      493,sys_mciClose,'�uMCI�J���v�ŊJ�����G�C���A�XA�����B','MCI�Ƃ���');
  AddFunc('MCI���M', 'S��',       494,sys_mciCommand,'MCI�ɃR�}���hS�𑗐M�����ʂ�Ԃ��B','MCI��������');
  
  //</�V�X�e���ϐ��֐�>

  Sore    := Global.GetVar(token_sore);
  kaisu   := Global.GetVar(token_kaisu);
  errMsg  := Global.GetVar(token_errMsg);
  taisyou := Global.GetVar(token_taisyou);

  hi_makeAlias;

  // �R�}���h���C���̓o�^
  _setCmdLine;

  //-------------
  // +++ temp +++
  //AddFunc  ('��荞��','S��|S��', 189, sys_include, '�t�@�C��S����荞��Ŏ��s����','�Ƃ肱��');
  //-------------
  
end;


procedure THiSystem.AddSystemFileCommand;
begin
  FlagSystemFile := True;
  //todo 1:�t�@�C���ϐ��֐��ǉ�
  //<�t�@�C���ϐ��֐�>
  //+���s�t�@�C���쐬
  //-�p�b�N�t�@�C���쐬
  AddFunc('�p�b�N�t�@�C���쐬','A��B��',    10, sys_packfile_make,  '�u�t�@�C���p�X=�p�b�N��=�Í���(0or1)�v�̃��X�g���g���ăt�@�C��B�֕ۑ�����','�ς����ӂ����邳������');
  AddFunc('�p�b�N�t�@�C�����o','A��B��C��', 11, sys_packfile_extract,  '�p�b�N�t�@�C��A�̒��ɂ���t�@�C��B�𒊏o����C�֕ۑ�����B','�ς����ӂ����邿�イ�����');
  AddFunc('�p�b�N�t�@�C������','F��|F��',   12, sys_checkpackfile,'���s�t�@�C��F�Ƀp�b�N�t�@�C�������݂��邩�m�F����B','�ς����ӂ����邻�񂴂�');
  AddFunc('�p�b�N�t�@�C�������񒊏o','A��B��', 13, sys_packfile_extract_str,  '�p�b�N�t�@�C��A�̒��ɂ���t�@�C��B�𒊏o���ĕ�����Ƃ��ĕԂ��B','�ς����ӂ������������イ�����');
  AddFunc('�p�b�N�t�@�C�������񒊏o','A��B��', 26, sys_packfile_enum,  '�p�b�N�t�@�C��A�̒��ɂ���t�@�C��B�𒊏o���ĕ�����Ƃ��ĕԂ��B','�ς����ӂ������������イ�����');

  //-���s�t�@�C���쐬���o���s
  AddFunc('�p�b�N�t�@�C������','A��B��C��',       14, sys_packfile,  '���s�t�@�C��A�ƃp�b�N�t�@�C��B����������C�֕ۑ�����B','�ς����ӂ����邯����');
  AddFunc('�p�b�N�t�@�C������','A����B��|A��B��', 15, sys_unpackfile,'���s�t�@�C��A����p�b�N�t�@�C�������o���t�@�C��B�֕ۑ�����B','�ς����ӂ�����Ԃ��');
  AddFunc('�p�b�N�t�@�C���\�[�X���[�h','A��B��|A����', 16, sys_packfile_nako_load,  '�p�b�N�t�@�C��A�ɂ���Ȃł����̃\�[�XB�����C���v���O�����Ƃ��ă��[�h����B���������1��Ԃ��B','�ς����ӂ����邻�[����[��');
  AddFunc('�p�b�N�t�@�C���\�[�X���s',  '',        17, sys_packfile_nako_run,   '�p�b�N�t�@�C���\�[�X���[�h�Ń��[�h�����v���O���������s����B','�ς����ӂ����邻�[����������');
  AddFunc('�i�f�V�RDLL�ˑ��󋵎擾','',5046, sys_makeDllReport, '�Ȃł�����DLL�ˑ��֌W���|�[�g���擾���ĕԂ�','�Ȃł���DLL�����񂶂傤���傤����Ƃ�');

  //+�t�@�C�����E�p�X����
  //-�p�X����
  AddFunc  ('�t�@�C�������o', 'S����|S��',  20, sys_extractFile,'�p�XS����t�@�C���������𒊏o���ĕԂ��B','�ӂ�����߂����イ�����');
  AddFunc  ('�p�X���o',       'S����|S��',  21, sys_extractFilePath,'�t�@�C����S����p�X�����𒊏o���ĕԂ��B','�ς����イ�����');
  AddFunc  ('�g���q���o',     'S����|S��',  22, sys_extractExt,'�t�@�C����S����g���q�����𒊏o���ĕԂ��B','�������傤�����イ�����');
  AddFunc  ('�g���q�ύX',     'S��A��|S��', 23, sys_changeExt,'�t�@�C����S�̊g���q��A�ɕύX���ĕԂ��B','�������傤���ւ񂱂�');
  AddFunc  ('���j�[�N�t�@�C��������','A��B��|A��', 24, sys_makeoriginalfile,'�t�H���_A�Ŋ�{�t�@�C����B�������j�[�N�ȃt�@�C�����𐶐����ĕԂ��B','��Ɂ[���ӂ�����߂���������');
  AddFunc  ('���΃p�X�W�J',   'A��B��',     25, sys_expand_path,'���΃p�X�`����{�p�X�a�œW�J���ĕԂ��B','���������ς��Ă񂩂�');
  //</�t�@�C���ϐ��֐�>

end;

procedure THiSystem.CheckInitSystem;
begin
  // �V�X�e���̏��������I����Ă��邩�`�F�b�N
  if FlagInit = False then
  begin
    FlagInit := True;
    // �V�X�e�����߂̒ǉ�
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
  FNowLoadPluginId := -1; // �V�X�e�����߂� -1
  FDummyGroup     := hi_var_new;
  hi_group_create(FDummyGroup);

  DebugNextStop := False;
  FIncludeBasePath := '';
  PluginsDir := AppPath + 'plug-ins\';

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  // ���߃^�O�̏�����
  _initTag;
  FTime      := timeGetTime;

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  // �P��̈ꊇ�o�^
  setTokenList(Self);
  // �����ꗗ�̍쐬
  setJosiList(Self);
end;

function THiSystem.CreateHiValue(VarId: Integer): PHiValue;
begin
  // ���ɑ��݂��邩�H
  Result := Global.GetVar(VarId);
  if Result = nil then
  begin
    //����
    Result := hi_var_new;
    //������
    Result^.VarID := VarID;
  end;

  //�o�^
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
      raise EHimaSyntax.Create(n.DebugInfo,'�w%s�x�Ńp�[�X�G���[�B',[n.ClassName]);
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
  Result := Result + '# --- ���C��'#13#10;
  Result := Result + DebugProgram(TopSyntaxNode);

  if DefFuncList.Count > 0 then
  begin
    Result := Result + '# --- �֐�'#13#10;
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
  // �v���O�C���̊J�����������s
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

  // --- �ϐ�����
  // (1)�󂷑O�ɃO���[�v�́u�󂷁v���\�b�h�����s
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

  // --- ���s�p�̃t���O����
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
  FreeAndNil(DllNameList); // ������
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

  //<�t���O�̑ޔ�>
  PushRunFlag;
  //</�t���O�̑ޔ�>
  FlagEnd := False;

  tmpSore := hi_var_new;
  hi_var_copyGensi(HiSystem.Sore, tmpSore);

  f := THimaFile.Create(nil, -1);
  try
    try
      f.SetSource(Source);
      parser := THiParser.Create;
      try
        MyTopNode := parser.Parse(f.TopToken); // Eval�p�m�[�h���\�z
        FFuncBreakLevel := FNestCheck;
        res  := RunNode(MyTopNode); // ���s
        if res <> nil then
        begin
          Result := hi_var_new;
          hi_var_copyGensi(res, Result);
        end;
      finally
        parser.Free;
      end;
    except on e: Exception do
      raise Exception.Create('EVAL(�\�[�X���]��)�ŃG���[���������܂����B' + e.Message);
    end;
  finally
    hi_var_copyGensi(tmpSore, HiSystem.Sore);
    hi_var_free(tmpSore);
    FreeAndNil(MyTopNode);
    f.Free;
  end;
  //<�t���O�̉�>
  PopRunFlag;
  //</�t���O�̉�>
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

    // �V�[�P���X���H
    p := PAnsiChar(w); Result := '';
    while p^ <> #0 do
    begin
      case p^ of
        ' ',',',#9: Inc(p);
        '>': begin Result := Result + #9 ;    Inc(p); end;
        '~': begin Result := Result + #13#10; Inc(p); end;
        // '_' �� ����̃G�C���A�X ... '_': begin Result := Result + ' ';    Inc(p); end;
        '[': begin Result := Result + '�u';   Inc(p); end;
        ']': begin Result := Result + '�v';   Inc(p); end;
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
                  // ���ߍ��ݕ���
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
        raise Exception.Create('������u'+string(w)+'�v�̓W�J�Ɏ��s�B'+e.Message);
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
      if (c = '�p')or(c = '}') then Break;
      Result := Result + c;
    end;
    if (c <> '�p')and(c <> '}') then raise Exception.Create(ERR_NOPAIR_NAMI);
  end;

begin
  Result := ''; if s = '' then Exit;
  p := PAnsiChar(s);

  // �W�J�̕K�v���𒲂ׂ�
  c := getOneChar(p);
  if (c = '"')or(c = '�u') then
  begin
    if c = '"' then
    begin
      EOS := '"';
    end else begin
      EOS := '�v';
    end;

    while p^ <> #0 do
    begin
      c := getOneChar(p);
      if (c = '�o')or(c = '{') then
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
  if c = '�w' then
  begin
    // �W�J���s�v ... �w�x������
    // |1234567|
    // |�waaa�x|
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
  Result := string(hi_str(GetVariable(hi_tango2id('��̓p�X'))));
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
  // ���[�J�����`�F�b�N
  Result := Local.GetVar(VarID);
  if Result <> nil then Exit;

  // �O���[�v�X�R�[�v���`�F�b�N
  Result := GroupScope.FindMember(VarID);
  if Result <> nil then Exit;

  // �O���[�o�����`�F�b�N
  Result := Namespace.GetVar(VarID);
end;

function THiSystem.GetVariableNoGroupScope(VarID: DWORD): PHiValue;
begin
  // ���[�J�����`�F�b�N
  Result := Local.GetVar(VarID);
  if Result <> nil then Exit;

  // �O���[�o�����`�F�b�N
  Result := Namespace.GetVar(VarID);
end;

function THiSystem.GetVariableRaw(VarID: DWORD): PHiValue;
begin
  // ���[�J�����`�F�b�N
  Result := Local.GetVar(VarID);
  if Result <> nil then Exit;

  // �O���[�v�X�R�[�v���`�F�b�N
  Result := GroupScope.FindMember(VarID);
  if Result <> nil then Exit;

  // �O���[�o�����`�F�b�N
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
      raise Exception.Create(string(FName)+'�̎�荞�݂Ɏ��s�B');
    end;

    if f = nil then raise Exception.Create(string(FName)+'�̎�荞�݂Ɏ��s�B');
    Namespace.CreateNewSpace(f.Fileno);
    FIncludeBasePath := f.Path;

    //-----------------------------------
    // ��荞�ݏ���
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
    // ���g�͎�荞�ݕs�v
    if s = 'DNAKO.DLL' then Exit;
    // vnako ��d��荞�݃`�F�b�N
    if s = 'LIBVNAKO.DLL' then
    begin
      p := HiSystem.GetVariable(hi_tango2id('noload_libvnako'));
      if p <> nil then 
      begin
        if hi_bool(p) then Exit;
      end;
    end;
    // ���̑��A��d��荞�݃`�F�b�N
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
      // ���d�v�F���L�t�H���_�Ŏ��s����Ƃ��AfmShareDenyNone �łȂ��ƂȂ����G���[�ɂȂ�
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
  // todo: �v���O�C���̎�荞��
  dll := TStringList.Create;
  dllpath := TStringList.Create;

  // ��������Ȃ�p�b�N�t�@�C����DLL�𒲂ׂ�
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
    // plug-in�t�H���_ �̃v���O�C���𒲂ׂ�
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

  // plug-in�t�H���_ �̃v���O�C���𒲂ׂ�
  path := AppPath + 'plug-ins\';
  if SysUtils.FindFirst(path+'*.dll', FaAnyFile, F) = 0 then
  begin
    repeat
      chkDLL(path + F.Name);
    until FindNext(F) <> 0;
    FindClose(F);
  end;

  // ���s�t�@�C���̃v���O�C���𒲂ׂ�
  path := AppPath;
  if SysUtils.FindFirst(path+'*.dll', FaAnyFile, F) = 0 then
  begin
    repeat
      chkDLL(path + F.Name);
    until FindNext(F) <> 0;
    FindClose(F);
  end;

  // �v���O�C�����ǂ����̔���
  for i := 0 to dllpath.Count - 1 do
  begin
    s := (dllpath.Strings[i]);
    // �w�b�_������LoadLibrary�ł��邩�ǂ����`�F�b�N����
    if chk_header(s) = False then Continue;
    h := LoadLibraryEx(PChar(s), 0, 0);
    if h = 0 then
    begin
      errLog('err.load.plugin=' + AnsiString(s));
      Continue;
    end;
    try
      // �v���O�C�����ǂ�������
      require := GetProcAddress(h, 'PluginRequire'); // plugin������
      if (Assigned(require) = False)or(require <= 1) then // �o�[�W�����Ⴂ��荞�܂Ȃ�
      begin
        FreeLibrary(h);
        Continue;
      end;

      // �v���O�C���Ƃ��ĔF��(�v���O�C�����X�g�ɒǉ�)
      plugin := THiPlugin.Create;
      plugin.FullPath := s;
      plugin.ID := plugins.Count;
      plugin.Handle := h;
      plugins.Add(plugin);
      FNowLoadPluginId := plugin.ID;
      // �������֐����Ă�(ver >= 2)
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
      raise Exception.Create('�v���O�C���̃��[�h���ɃG���[:'+s);
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
  // ���s�̂��߂ɏ�����
  FlagEnd     := False;
  BreakLevel  := BREAK_OFF;
  BreakType   := btNone;
  ReturnLevel := BREAK_OFF;

  // �n���h���̏������Ȃ�
  unit_file.MainWindowHandle := hima_function.MainWindowHandle;

  // ���s�J�n
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

  // �C�x���g�����
  group := hi_getLink(group);
  pEvent := hi_group(group).FindMember(memberId);
  if pEvent = nil then Exit; // �����o���Ȃ�
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
    // ���s
    HiSystem.FlagEnd := False;
    pRes := node.getValue;
    // �߂�l���R�s�[
    hi_var_copyGensi(pRes, Result);
    if (pRes <> nil)and(pRes.Registered = 0) then hi_var_free(pRes);
  finally
    //sv.Free; �����I�ɉ��
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
    // --- group �� stack �� push
    GroupScope.PushGroupScope(hi_group(group));
    node := TSyntaxFunction.Create(nil);
    try
      node.FDebugFuncName := hi_id2tango(method.VarID);
      node.FuncID := method.VarID;
      node.HiFunc := hi_func(method);
      node.Link.LinkType  := sfLinkDirect;
      if node.Stack <> nil then node.Stack.Free; 
      node.Stack := args;
      // ���s
      HiSystem.FlagEnd := False;
      node.SyntaxLevel := 0;
      pRes := node.getValue;
      // �߂�l���R�s�[
      hi_var_copyGensi(pRes, Result);
      if (pRes <> nil)and(pRes.Registered = 0) then hi_var_free(pRes);
      // �������͎����ŉ�����Ȃ�
      node.Stack := nil; // �d�v
    finally
      node.Free;
      HiSystem.GroupScope.PopGroupScope;
    end;
  finally
    PopRunFlag;
  end;
end;

function THiSystem.RunNode(node: TSyntaxNode; IsNoGetter: Boolean): PHiValue;
// node ���� node �Ɍq����\�������s����
// ---
// +----[����]
// ||   �Ԃ�l�͒��ڕϐ��ւ̃|�C���^�����邱�Ƃ�����A�����ɉ��(hi_var_free)���Ă͂����Ȃ��B
// ||   �����A�Ԃ�l��������Ă��܂��ƁA�I�����Ɉُ�I������B
// -----
  procedure __PRINT_DEBUG_STR__;
  var
    s: AnsiString;
  begin
    s := AnsiString(
      Format('%d:%0.4d (%2d): ',[node.DebugInfo.FileNo, node.DebugInfo.LineNo,node.SyntaxLevel])
    );
    s := s + RepeatStr('�@�@', node.SyntaxLevel);
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
  //todo 1: ���s(RunNode)
  Result := nil;
  bError := False;
  // ���̃��C���Ŏ~�߂邩�H

  // �ċA�X�^�b�N�̃I�[�o�[�t���[�`�F�b�N
  Inc(FNestCheck);
  if FNestCheck > MAX_STACK_COUNT then begin HiSystem.FlagEnd := True; raise Exception.Create(ERR_STACK_OVERFLOW); end;
  //
  try
lblTop:
  try
    while node <> nil do
    begin
      // �I���t���O����
      if FFlagEnd then Break;
      // �u���C�N����
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

      // �f�o�b�O�p�G�f�B�^�֌��ݎ��s���̍s�ԍ���ʒm
      if DebugLineNo and (DebugEditorHandle <> 0) then begin
        if (node.DebugInfo.FileNo = MainFileNo)and(node.DebugInfo.LineNo > 0) then begin
          SendCOPYDATA(DebugEditorHandle, 'row ' + IntToStrA(node.DebugInfo.LineNo), 0, MainWindowHandle);
        end;
      end;

      // ���ݎ��s���̃m�[�h���L�^
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
            Eval2('�f�o�b�O');
          end;
        end;
      end;
      // --------------------------------
      // �m�[�h�����s
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
      node := node.Next; // ���̃m�[�h���擾

      // �l��nil�łȂ���Ό��ʂ�Ԃ�
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

  // --- �G���[
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
  // �P��ID���擾
  VarID    := TangoList.GetID(DeleteGobi(VarName), tag);
  SetterID := TangoList.GetID(DeleteGobi(SetterName));
  GetterID := TangoList.GetID(DeleteGobi(GetterName));
  _checkTag(tag, VarID);
  // �P��ID����֐����擾
  pSetter  := Namespace.GetVar(SetterID); if pSetter = nil then raise Exception.CreateFmt(ERR_S_UNDEFINED,[SetterName]);
  pGetter  := Namespace.GetVar(GetterID); if pGetter = nil then raise Exception.CreateFmt(ERR_S_UNDEFINED,[GetterName]);
  // �֐��H
  if pSetter.VType <> varFunc then raise HException.Create(SetterName + '�͊֐��ł͂���܂���B');
  if pGetter.VType <> varFunc then raise HException.Create(GetterName + '�͊֐��ł͂���܂���B');
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
  p := Eval('�u{�i�f�V�R�o�[�W����}�v��\���B�P�b�҂�');
  if p.Registered = 0 then hi_var_free(p);
end;

function THiSystem.makeDllReport: AnsiString;
var
  s: AnsiString;
begin
  s := s + '; --- �Ȃł�����̓��|�[�g ---'#13#10;
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

  // ���e���폜
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
    varInt    : s := '(����)    ' + hi_str(v);
    varFloat  : s := '(����)    ' + hi_str(v);
    varStr    : s := '(������)  ' + hi_str(v);
    varNil    : s := '(nil)';
    varFunc   : s := '(�֐�)';
    varArray  : s := '(�z��)    ' + hi_str(v);
    varHash   : s := '(�n�b�V��)' + hi_str(v);
    varGroup  : s := '(�O���[�v)[' + hi_id2tango(hi_group(v).HiClassNameID)+']';
    varLink   : s := '(�����N)  ' + hi_str(v);
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
      HiSystem.RunGroupEvent(v, token_kowasu); // �G���[����������H�H
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
  // �O���[�v�w���g�x���R�s�[����
  if jisin = nil then
  begin
    jisin := HiSystem.GetVariable(token_jisin);
  end;
  // �V�������g���R�s�[����
  hi_var_copyGensi(FScope.InstanceVar, jisin);
  //hi_setLink(jisin, FScope.InstanceVar);

  Self.Push(FScope);
end;

procedure THiGroupScope.PopGroupScope;
var
  g: THiGroup;
begin
  // �O��̎��g��pop����
  Self.Pop;

  // ���g�ɃR�s�[����
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
  // �ς܂ꂽ�t���ɉ󂵂Ă���
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
  // �ς܂ꂽ�t���ɉ󂵂Ă���
  for i := Count -1 downto 0 do // �A���V�X�e���͉󂳂Ȃ�
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

  // CurSpace ������
  if CurSpace = nil then
  begin
    CurSpace := Items[0];
  end;
  Result := CurSpace.GetVar(id);
  if Result <> nil then Exit;
  curid := CurSpace.ScopeID;

  // �S�̂�����
  for i := 0 to Count - 1 do
  begin
    s := Items[i];
    if curid = s.ScopeID then Continue; // �����ς݂Ȃ̂Ŕ�΂�
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
  // �d���`�F�b�N
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
  // �ˑ��֌W�̂���t�@�C��������
  if IzonFiles <> '' then
  begin
    sl := SplitChar(',', IzonFiles);
    for i := 0 to sl.Count - 1 do
    begin
      HiSystem.plugins.addDll(AppPath + 'plug-ins\' + sl.Strings[i]);
    end;
    FreeAndNil(sl);
  end;
  // �g���Ă���v���O�C�����`�F�b�N
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
  HiSystem.CheckInitSystem; // �N��

finalization
  try
    FreeAndNil(FHiSystem);
  except
  end;

end.
