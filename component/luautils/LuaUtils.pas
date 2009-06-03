//******************************************************************************
//***                     LUA SCRIPT DELPHI UTILITIES                        ***
//***                                                                        ***
//***        (c) 2005 Jean-Fran輟is Goulet,  Massimo Magnano, Kuma           ***
//***                                                                        ***
//***                                                                        ***
//******************************************************************************
//  File        : LuaUtils.pas
//
//  Description : Useful functions to work with Lua in Delphi. 
//
//******************************************************************************
//** See Copyright Notice in lua.h

//Revision 1.6
//     JF Adds :
//             LuaTableToVirtualTreeView
//
//Revision 1.1
//     MaxM Adds :
//             LuaPCallFunction
//
//Revision 1.0
//     MaxM Adds :
//             LuaPushVariant
//             LuaToVariant
//             LuaGetTableInteger, LuaGet\SetTableTMethod
//             LuaLoadBufferFromFile
//     Solved Bugs : Stack problem in LuaProcessTableName
//                   LuaToInteger why Round?, Trunc is better
unit LuaUtils;

interface

uses
  SysUtils, Classes, ComCtrls, lua, lauxlib, Variants;

const
     ERR_Script ='Script Error : ';  

type
  TOnLuaStdout = procedure (S: PAnsiChar; N: Integer);
  TOnLuaStdoutEx = procedure (F, S: PAnsiChar; L, N: Integer);
  ELuaException = class(Exception)
  public
    Title: AnsiString;
    Line: Integer;
    Msg: AnsiString;
    constructor Create(Title: AnsiString; Line: Integer; Msg: AnsiString);
  end;

  PBasicTreeData = ^TBasicTreeData;
  TBasicTreeData = record
    sName: AnsiString;
    sValue: AnsiString;
  end;

  TVariantArray =array of Variant;
  PVariantArray =^TVariantArray;

function Quote(const Str: AnsiString): AnsiString;
function Dequote(const QuotedStr: AnsiString): AnsiString;
function lua_print(L: Plua_State): Integer; cdecl;
function lua_printex(L: Plua_State): Integer; cdecl;
function lua_io_write(L: Plua_State): Integer; cdecl;
function lua_io_writeex(L: Plua_State): Integer; cdecl;

function LuaToBoolean(L: PLua_State; Index: Integer): Boolean;
procedure LuaPushBoolean(L: PLua_State; B: Boolean);
function LuaToInteger(L: PLua_State; Index: Integer): Integer;
procedure LuaPushInteger(L: PLua_State; N: Integer);
function LuaToVariant(L: Plua_State; Index: Integer): Variant;
procedure LuaPushVariant(L: Plua_State; N: Variant);
function LuaToAnsiString(L: PLua_State; Index: Integer): AnsiString;
function LuaToString(L: Plua_State; Index: Integer): string;
procedure LuaPushString(L: PLua_State; const S: AnsiString);
function LuaIncIndex(L: Plua_State; Index: Integer): Integer;
function LuaAbsIndex(L: Plua_State; Index: Integer): Integer;
procedure LuaGetTable(L: Plua_State; TableIndex: Integer; const Key: AnsiString);
function LuaGetTableBoolean(L: Plua_State; TableIndex: Integer; const Key: AnsiString): Boolean;
function LuaGetTableNumber(L: Plua_State; TableIndex: Integer; const Key: AnsiString): Double;
function LuaGetTableInteger(L: Plua_State; TableIndex: Integer; const Key: AnsiString): Integer;
function LuaGetTableString(L: Plua_State; TableIndex: Integer; const Key: AnsiString): AnsiString;
function LuaGetTableFunction(L: Plua_State; TableIndex: Integer; const Key: AnsiString): lua_CFunction;
function LuaGetTableLightUserData(L: Plua_State; TableIndex: Integer; const Key: AnsiString): Pointer;
function LuaGetTableTMethod(L: Plua_State; TableIndex: Integer; const Key: AnsiString): TMethod;
procedure LuaRawGetTable(L: Plua_State; TableIndex: Integer; const Key: AnsiString);
function LuaRawGetTableBoolean(L: Plua_State; TableIndex: Integer; const Key: AnsiString): Boolean;
function LuaRawGetTableNumber(L: Plua_State; TableIndex: Integer; const Key: AnsiString): Double;
function LuaRawGetTableString(L: Plua_State; TableIndex: Integer; const Key: AnsiString): AnsiString;
function LuaRawGetTableFunction(L: Plua_State; TableIndex: Integer; const Key: AnsiString): lua_CFunction;
function LuaRawGetTableLightUserData(L: Plua_State; TableIndex: Integer; const Key: AnsiString): Pointer;
procedure LuaSetTableValue(L: PLua_State; TableIndex: Integer; const Key: AnsiString; ValueIndex: Integer);
procedure LuaSetTableNil(L: Plua_State; TableIndex: Integer; const Key: AnsiString);
procedure LuaSetTableBoolean(L: Plua_State; TableIndex: Integer; const Key: AnsiString; B: Boolean);
procedure LuaSetTableNumber(L: Plua_State; TableIndex: Integer; const Key: AnsiString; N: Double);
procedure LuaSetTableString(L: Plua_State; TableIndex: Integer; const Key: AnsiString; S: AnsiString);
procedure LuaSetTableFunction(L: Plua_State; TableIndex: Integer; const Key: AnsiString; F: lua_CFunction);
procedure LuaSetTableLightUserData(L: Plua_State; TableIndex: Integer; const Key: AnsiString; P: Pointer);
procedure LuaSetTableTMethod(L: Plua_State; TableIndex: Integer; const Key: AnsiString; M: TMethod);
procedure LuaSetTableClear(L: Plua_State; TableIndex: Integer);
procedure LuaRawSetTableValue(L: PLua_State; TableIndex: Integer; const Key: AnsiString; ValueIndex: Integer);
procedure LuaRawSetTableNil(L: Plua_State; TableIndex: Integer; const Key: AnsiString);
procedure LuaRawSetTableBoolean(L: Plua_State; TableIndex: Integer; const Key: AnsiString; B: Boolean);
procedure LuaRawSetTableNumber(L: Plua_State; TableIndex: Integer; const Key: AnsiString; N: Double);
procedure LuaRawSetTableString(L: Plua_State; TableIndex: Integer; const Key: AnsiString; S: AnsiString);
procedure LuaRawSetTableFunction(L: Plua_State; TableIndex: Integer; const Key: AnsiString; F: lua_CFunction);
procedure LuaRawSetTableLightUserData(L: Plua_State; TableIndex: Integer; const Key: AnsiString; P: Pointer);
procedure LuaRawSetTableClear(L: Plua_State; TableIndex: Integer);
function LuaGetMetaFunction(L: Plua_State; Index: Integer; Key: AnsiString): lua_CFunction;
procedure LuaSetMetaFunction(L: Plua_State; Index: Integer; Key: AnsiString; F: lua_CFunction);

procedure LuaShowStack(L: Plua_State; Caption: AnsiString = '');
function LuaStackToStr(L: Plua_State; Index: Integer; MaxTable: Integer = -1; SubTableMax: Integer = 99; CheckCyclicReferencing: Boolean = True; TablePtrs: TList = nil): AnsiString;
procedure LuaRegisterCustom(L: PLua_State; TableIndex: Integer; const Name: PAnsiChar; F: lua_CFunction);
procedure LuaRegister(L: Plua_State; const Name: PAnsiChar; F: lua_CFunction);
procedure LuaRegisterMetatable(L: Plua_State; const Name: PAnsiChar; F: lua_CFunction);
procedure LuaRegisterProperty(L: PLua_State; const Name: PAnsiChar; ReadFunc, WriteFunc: lua_CFunction);
procedure LuaStackToStrings(L: Plua_State; Lines: TStrings; MaxTable: Integer = -1; SubTableMax: Integer = 99; CheckCyclicReferencing: Boolean = True);
procedure LuaLocalToStrings(L: Plua_State; Lines: TStrings; MaxTable: Integer = -1; Level: Integer = 0; SubTableMax: Integer = 99; CheckCyclicReferencing: Boolean = True);
//procedure LuaGlobalToStrings(L: PLua_State; Lines: TStrings; MaxTable: Integer = -1; SubTableMax: Integer = 99; CheckCyclicReferencing: Boolean = True);
//procedure LuaTableToVirtualTreeView(L: Plua_State; Index: Integer; VTV: TVirtualStringTree; MaxTable: Integer; SubTableMax: Integer; CheckCyclicReferencing: Boolean);
function LuaGetIdentValue(L: Plua_State; Ident: AnsiString; MaxTable: Integer = -1): AnsiString;
procedure LuaSetIdentValue(L: Plua_State; Ident, Value: AnsiString; MaxTable: Integer = -1);
procedure LuaLoadBuffer(L: Plua_State; const Code: AnsiString; const Name: AnsiString);
procedure LuaLoadBufferFromFile(L: Plua_State; const Filename: AnsiString; const Name: AnsiString);
procedure LuaPCall(L: Plua_State; NArgs, NResults, ErrFunc: Integer);
function LuaPCallFunction(L: Plua_State; FunctionName : AnsiString;
                          const Args: array of Variant;
                          Results : PVariantArray;
                          ErrFunc: Integer=0;
                          NResults :Integer=LUA_MULTRET):Integer;
procedure LuaError(L: Plua_State; const Msg: AnsiString);
procedure LuaErrorFmt(L: Plua_State; const Fmt: AnsiString; const Args: array of Const);
function LuaDataStrToStrings(const TableStr: AnsiString; Strings: TStrings): AnsiString;
function LuaDoFile(L: Plua_State): Integer; cdecl;

const
  LuaGlobalVariableStr = '[LUA_GLOBALSINDEX]';
var
  OnLuaStdoutEx: TOnLuaStdoutEx;
  OnLuaStdout: TOnLuaStdout;
  DefaultMaxTable: Integer;
  SubTableCount: Integer;
  SubTableCount2: Integer;


implementation

uses
  Dialogs;

const
  QuoteStr = '"';
  CR = #$0D;
  LF = #$0A;
  CRLF = CR + LF;

function Quote(const Str: AnsiString): AnsiString;
begin
  Result := AnsiString(AnsiQuotedStr(string(Str), QuoteStr));
end;

function Dequote(const QuotedStr: AnsiString): AnsiString;
begin
  Result := AnsiString(AnsiDequotedStr(string(QuotedStr), QuoteStr));
end;

function fwriteex(F, S: PAnsiChar; Un, Len: Integer; L, Dummy: Integer): Integer;
var
  Size: Integer;
begin
  Size := Un * Len;
  if (Assigned(OnLuaStdoutEx)) then
    OnLuaStdoutEx(F, S, L, Size);
  Result := Size;
end;

function fwrite(S: PAnsiChar; Un, Len: Integer; Dummy: Integer): Integer;
var
  Size: Integer;
begin
  Size := Un * Len;
  if (Assigned(OnLuaStdout)) then
    OnLuaStdout(S, Size);
  Result := Size;
end;

function fputsex(const F, S: AnsiString; L, Dummy: Integer): Integer;
begin
  Result := fwriteex(PAnsiChar(F), PAnsiChar(S), SizeOf(AnsiChar), L, Length(S), Dummy);
end;

function fputs(const S: AnsiString; Dummy: Integer): Integer;
begin
  Result := fwrite(PAnsiChar(S), SizeOf(AnsiChar), Length(S), Dummy);
end;

function lua_printex(L: Plua_State): Integer; cdecl;
const
  TAB = #$08;
  NL = #$0A;
  stdout = 0;
var
  N, I: Integer;
  S: PAnsiChar;
  Debug: lua_Debug;
  AR: Plua_Debug;
begin
  AR := @Debug;
  lua_getstack(L, 1, AR); {* stack informations *}
  lua_getinfo(L, 'Snlu', AR); {* debug informations *}

  N := lua_gettop(L);  (* number of arguments *)
  lua_getglobal(L, 'tostring');
  
  for I := 1 to N do
  begin
    lua_pushvalue(L, -1);  (* function to be called *)
    lua_pushvalue(L, i);   (* value to print *)
    lua_call(L, 1, 1);
    S := lua_tostring(L, -1);  (* get result *)
    if (S = nil) then
    begin
      Result := luaL_error(L, '`tostring'' must return a string to `print''');
      Exit;
    end;
    if (I > 1) then fputs(TAB, stdout);
    fputsex(AR.source, S, AR.currentline, stdout);
    lua_pop(L, 1);  (* pop result *)
  end;

  fputsex(AR.source, NL, AR.currentline, stdout);
  Result := 0;
end;

function lua_print(L: Plua_State): Integer; cdecl;
const
  TAB = #$08;
  NL = #$0A;
  stdout = 0;
var
  N, I: Integer;
  S: PAnsiChar;
begin
  N := lua_gettop(L);  (* number of arguments *)
  lua_getglobal(L, 'tostring');
  for I := 1 to N do
  begin
    lua_pushvalue(L, -1);  (* function to be called *)
    lua_pushvalue(L, i);   (* value to print *)
    lua_call(L, 1, 1);
    S := lua_tostring(L, -1);  (* get result *)
    if (S = nil) then
    begin
      Result := luaL_error(L, '`tostring'' must return a string to `print''');
      Exit;
    end;
    if (I > 1) then fputs(TAB, stdout);
    fputs(S, stdout);
    lua_pop(L, 1);  (* pop result *)
  end;
  fputs(NL, stdout);
  Result := 0;
end;

function lua_io_writeex(L: Plua_State): Integer; cdecl;
  function pushresult(L: Plua_State; I: Boolean; FileName: PAnsiChar): Integer;
  begin
    lua_pushboolean(L, True);
    Result := 1;
  end;
const
  F = 0;
var
  NArgs: Integer;
  Status: Boolean;
  Arg: Integer;
  Len: Integer;
  S: PAnsiChar;
  Debug: lua_Debug;
  AR: Plua_Debug;
begin
  AR := @Debug;
  lua_getstack(L, 1, AR); {* stack informations *}
  lua_getinfo(L, 'Snlu', AR); {* debug informations *}

  Arg := 1;
  NArgs := lua_gettop(L);
  Status := True;
  
  while (NArgs > 0) do
  begin
    Dec(NArgs);
    if (lua_type(L, Arg) = LUA_TNUMBER) then
    begin
      (* optimization: could be done exactly as for strings *)
      Status := Status and
          (fputsex(AR.source,
            AnsiString(Format(LUA_NUMBER_FMT, [lua_tonumber(L, Arg)])),
            AR.currentline, 0) > 0);
    end else
    begin
      S := luaL_checklstring(L, Arg, @Len);
      Status := Status and (fwriteex(AR.source, S, SizeOf(AnsiChar), Len, AR.currentline, F) = Len);
    end;
    Inc(Arg);
  end;
  
  Result := pushresult(L, Status, nil);
end;

function lua_io_write(L: Plua_State): Integer; cdecl;
  function pushresult(L: Plua_State; I: Boolean; FileName: PAnsiChar): Integer;
  begin
    lua_pushboolean(L, True);
    Result := 1;
  end;
const
  F = 0;
var
  NArgs: Integer;
  Status: Boolean;
  Arg: Integer;
  Len: Integer;
  S: PAnsiChar;
begin
  Arg := 1;
  NArgs := lua_gettop(L);
  Status := True;
  while (NArgs > 0) do
  begin
    Dec(NArgs);
    if (lua_type(L, Arg) = LUA_TNUMBER) then
    begin
      (* optimization: could be done exactly as for strings *)
      Status := Status and
          (fputs(
            AnsiString(Format(LUA_NUMBER_FMT, [lua_tonumber(L, Arg)])), 0) > 0);
    end else
    begin
      S := luaL_checklstring(L, Arg, @Len);
      Status := Status and (fwrite(S, SizeOf(AnsiChar), Len, F) = Len);
    end;
    Inc(Arg);
  end;
  Result := pushresult(L, Status, nil);
end;

function LuaToBoolean(L: PLua_State; Index: Integer): Boolean;
begin
  Result := (lua_toboolean(L, Index) <> False);
end;

procedure LuaPushBoolean(L: PLua_State; B: Boolean);
begin
  lua_pushboolean(L, B);
end;

function LuaToInteger(L: PLua_State; Index: Integer): Integer;
begin
  Result := Trunc(lua_tonumber(L, Index));  //Round(lua_tonumber(L, Index));
end;

procedure LuaPushInteger(L: PLua_State; N: Integer);
begin
  lua_pushnumber(L, N);
end;


function LuaToVariant(L: Plua_State; Index: Integer): Variant;
Var
   dataType :Integer;
   dataNum  :Double;

begin
     dataType :=lua_type(L, Index);
     Case dataType of
     LUA_TSTRING          : Result := VarAsType(LuaToAnsiString(L, Index), varString);
     LUA_TUSERDATA,
     LUA_TLIGHTUSERDATA   : Result := VarAsType(Integer(lua_touserdata(L, Index)), varInteger);
     LUA_TNONE,
     LUA_TNIL             : Result := varNull;
     LUA_TBOOLEAN         : Result := VarAsType(LuaToBoolean(L, Index), varBoolean);
     LUA_TNUMBER          : begin
                                 dataNum :=lua_tonumber(L, Index);
                                 if (Abs(dataNum)>MAXINT)
                                 then Result :=VarAsType(dataNum, varDouble)
                                 else begin
                                           if (Frac(dataNum)<>0)
                                           then Result :=VarAsType(dataNum, varDouble)
                                           else Result :=VarAsType(dataNum, varInteger)
                                      end;
                            end;
     end;
end;

procedure LuaPushVariant(L: Plua_State; N: Variant);
begin
     case VarType(N) of
     varEmpty,
     varNull          :lua_pushnil(L);
     varBoolean         :LuaPushBoolean(L, N);
     varStrArg,
     varOleStr,
     varString        :LuaPushString(L, AnsiString(N));
     varDate          :LuaPushString(L, AnsiString(DateTimeToStr(VarToDateTime(N))));
     else lua_pushnumber(L, N);
     end;
end;

function LuaToAnsiString(L: PLua_State; Index: Integer): AnsiString;
var
  Size: Integer;
begin
  Size := lua_strlen(L, Index);
  SetLength(Result, Size);
  if (Size > 0) then
    Move(lua_tostring(L, Index)^, Result[1], Size);
end;

function LuaToString(L: Plua_State; Index: Integer): string;
var
  value_a: AnsiString;
begin
  value_a := LuaToAnsiString(L, Index);
  {$IF RTLVersion >= 20.00}
    Result := UTF8ToString(value_a);
  {$ELSE}
    Result := value_a;
  {$IFEND}
end;

procedure LuaPushString(L: PLua_State; const S: AnsiString);
begin
  lua_pushstring(L, PAnsiChar(S));
end;

function LuaIncIndex(L: Plua_State; Index: Integer): Integer;
// 相対インデックス -1 ～ -N へ変換
begin
  if ((Index = LUA_GLOBALSINDEX) or (Index = LUA_REGISTRYINDEX)) then
  begin
    Result := Index;
    Exit;
  end;

  Result := LuaAbsIndex(L, Index) - lua_gettop(L) - 1;
end;

function LuaAbsIndex(L: Plua_State; Index: Integer): Integer;
// 絶対インデックス 1 ～ N へ変換
begin
  if ((Index = LUA_GLOBALSINDEX) or (Index = LUA_REGISTRYINDEX)) then
  begin
    Result := Index;
    Exit;
  end;

  if (Index < 0) then
    Result := Index + lua_gettop(L) + 1
  else
    Result := Index;
end;

procedure LuaPushKeyString(L: PLua_State; var Index: Integer; const Key: AnsiString);
begin
  Index := LuaAbsIndex(L, Index);
  lua_pushstring(L, PAnsiChar(Key));
end;

procedure LuaGetTable(L: Plua_State; TableIndex: Integer; const Key: AnsiString);
begin
  LuaPushKeyString(L, TableIndex, Key);
  lua_gettable(L, TableIndex);
end;

function LuaGetTableBoolean(L: Plua_State; TableIndex: Integer; const Key: AnsiString): Boolean;
begin
  LuaGetTable(L, TableIndex, Key);
  Result := (lua_toboolean(L, -1) <> False);
  lua_pop(L, 1);
end;

function LuaGetTableNumber(L: Plua_State; TableIndex: Integer; const Key: AnsiString): Double;
begin
  LuaGetTable(L, TableIndex, Key);
  Result := lua_tonumber(L, -1);
  lua_pop(L, 1);
end;

function LuaGetTableInteger(L: Plua_State; TableIndex: Integer; const Key: AnsiString): Integer;
begin
  LuaGetTable(L, TableIndex, Key);
  Result := LuaToInteger(L, -1);
  lua_pop(L, 1);
end;

function LuaGetTableString(L: Plua_State; TableIndex: Integer; const Key: AnsiString): AnsiString;
begin
  LuaGetTable(L, TableIndex, Key);
  Result := lua_tostring(L, -1);
  lua_pop(L, 1);
end;

function LuaGetTableFunction(L: Plua_State; TableIndex: Integer; const Key: AnsiString): lua_CFunction;
begin
  LuaGetTable(L, TableIndex, Key);
  Result := lua_tocfunction(L, -1);
  lua_pop(L, 1);
end;

function LuaGetTableLightUserData(L: Plua_State; TableIndex: Integer; const Key: AnsiString): Pointer;
begin
  LuaGetTable(L, TableIndex, Key);
  Result := lua_touserdata(L, -1);
  lua_pop(L, 1);
end;

function LuaGetTableTMethod(L: Plua_State; TableIndex: Integer; const Key: AnsiString): TMethod;
begin
     Result.Code :=LuaGetTableLightUserData(L, TableIndex, Key+'_Code'); //Code is the Method Pointer
     Result.Data :=LuaGetTableLightUserData(L, TableIndex, Key+'_Data'); //Data is the object Pointer
end;

procedure LuaRawGetTable(L: Plua_State; TableIndex: Integer; const Key: AnsiString);
begin
  LuaPushKeyString(L, TableIndex, Key);
  lua_rawget(L, TableIndex);
end;

function LuaRawGetTableBoolean(L: Plua_State; TableIndex: Integer; const Key: AnsiString): Boolean;
begin
  LuaRawGetTable(L, TableIndex, Key);
  Result := (lua_toboolean(L, -1) <> False);
  lua_pop(L, 1);
end;

function LuaRawGetTableNumber(L: Plua_State; TableIndex: Integer; const Key: AnsiString): Double;
begin
  LuaRawGetTable(L, TableIndex, Key);
  Result := lua_tonumber(L, -1);
  lua_pop(L, 1);
end;

function LuaRawGetTableString(L: Plua_State; TableIndex: Integer; const Key: AnsiString): AnsiString;
begin
  LuaRawGetTable(L, TableIndex, Key);
  Result := lua_tostring(L, -1);
  lua_pop(L, 1);
end;

function LuaRawGetTableFunction(L: Plua_State; TableIndex: Integer; const Key: AnsiString): lua_CFunction;
begin
  LuaRawGetTable(L, TableIndex, Key);
  Result := lua_tocfunction(L, -1);
  lua_pop(L, 1);
end;

function LuaRawGetTableLightUserData(L: Plua_State; TableIndex: Integer; const Key: AnsiString): Pointer;
begin
  LuaRawGetTable(L, TableIndex, Key);
  Result := lua_touserdata(L, -1);
  lua_pop(L, 1);
end;

procedure LuaSetTableValue(L: PLua_State; TableIndex: Integer; const Key: AnsiString; ValueIndex: Integer);
begin
  TableIndex := LuaAbsIndex(L, TableIndex);
  ValueIndex := LuaAbsIndex(L, ValueIndex);
  lua_pushstring(L, PAnsiChar(Key));
  lua_pushvalue(L, ValueIndex);
  lua_settable(L, TableIndex);
end;

procedure LuaSetTableNil(L: Plua_State; TableIndex: Integer; const Key: AnsiString);
begin
  LuaPushKeyString(L, TableIndex, Key);
  lua_pushnil(L);
  lua_settable(L, TableIndex);
end;

procedure LuaSetTableBoolean(L: Plua_State; TableIndex: Integer; const Key: AnsiString; B: Boolean);
begin
  LuaPushKeyString(L, TableIndex, Key);
  lua_pushboolean(L, B);
  lua_settable(L, TableIndex);
end;

procedure LuaSetTableNumber(L: Plua_State; TableIndex: Integer; const Key: AnsiString; N: Double);
begin
  LuaPushKeyString(L, TableIndex, Key);
  lua_pushnumber(L, N);
  lua_settable(L, TableIndex);
end;

procedure LuaSetTableString(L: Plua_State; TableIndex: Integer; const Key: AnsiString; S: AnsiString);
begin
  LuaPushKeyString(L, TableIndex, Key);
  lua_pushstring(L, PAnsiChar(S));
  lua_settable(L, TableIndex);
end;

procedure LuaSetTableFunction(L: Plua_State; TableIndex: Integer; const Key: AnsiString; F: lua_CFunction);
begin
  LuaPushKeyString(L, TableIndex, Key);
  lua_pushcfunction(L, F);
  lua_settable(L, TableIndex);
end;

procedure LuaSetTableLightUserData(L: Plua_State; TableIndex: Integer; const Key: AnsiString; P: Pointer);
begin
  LuaPushKeyString(L, TableIndex, Key);
  lua_pushlightuserdata(L, P);
  lua_settable(L, TableIndex);
end;

procedure LuaSetTableTMethod(L: Plua_State; TableIndex: Integer; const Key: AnsiString; M: TMethod);
begin
     LuaSetTableLightUserData(L, TableIndex, Key+'_Code', M.Code);
     LuaSetTableLightUserData(L, TableIndex, Key+'_Data', M.Data);
end;

procedure LuaSetTableClear(L: Plua_State; TableIndex: Integer);
begin
  TableIndex := LuaAbsIndex(L, TableIndex);

  lua_pushnil(L);
  while (lua_next(L, TableIndex) <> 0) do
  begin
    lua_pushnil(L);
    lua_replace(L, -1 - 1);
    lua_settable(L, TableIndex);
    lua_pushnil(L);
  end;
end;

procedure LuaRawSetTableValue(L: PLua_State; TableIndex: Integer; const Key: AnsiString; ValueIndex: Integer);
begin
  TableIndex := LuaAbsIndex(L, TableIndex);
  ValueIndex := LuaAbsIndex(L, ValueIndex);
  lua_pushstring(L, PAnsiChar(Key));
  lua_pushvalue(L, ValueIndex);
  lua_rawset(L, TableIndex);
end;

procedure LuaRawSetTableNil(L: Plua_State; TableIndex: Integer; const Key: AnsiString);
begin
  LuaPushKeyString(L, TableIndex, Key);
  lua_pushnil(L);
  lua_rawset(L, TableIndex);
end;

procedure LuaRawSetTableBoolean(L: Plua_State; TableIndex: Integer; const Key: AnsiString; B: Boolean);
begin
  LuaPushKeyString(L, TableIndex, Key);
  lua_pushboolean(L, B);
  lua_rawset(L, TableIndex);
end;

procedure LuaRawSetTableNumber(L: Plua_State; TableIndex: Integer; const Key: AnsiString; N: Double);
begin
  LuaPushKeyString(L, TableIndex, Key);
  lua_pushnumber(L, N);
  lua_rawset(L, TableIndex);
end;

procedure LuaRawSetTableString(L: Plua_State; TableIndex: Integer; const Key: AnsiString; S: AnsiString);
begin
  LuaPushKeyString(L, TableIndex, Key);
  lua_pushstring(L, PAnsiChar(S));
  lua_rawset(L, TableIndex);
end;

procedure LuaRawSetTableFunction(L: Plua_State; TableIndex: Integer; const Key: AnsiString; F: lua_CFunction);
begin
  LuaPushKeyString(L, TableIndex, Key);
  lua_pushcfunction(L, F);
  lua_rawset(L, TableIndex);
end;

procedure LuaRawSetTableLightUserData(L: Plua_State; TableIndex: Integer; const Key: AnsiString; P: Pointer);
begin
  LuaPushKeyString(L, TableIndex, Key);
  lua_pushlightuserdata(L, P);
  lua_rawset(L, TableIndex);
end;

procedure LuaRawSetTableClear(L: Plua_State; TableIndex: Integer);
begin
  TableIndex := LuaAbsIndex(L, TableIndex);

  lua_pushnil(L);
  while (lua_next(L, TableIndex) <> 0) do
  begin
    lua_pushnil(L);
    lua_replace(L, -1 - 1);
    lua_rawset(L, TableIndex);
    lua_pushnil(L);
  end;
end;

function LuaGetMetaFunction(L: Plua_State; Index: Integer; Key: AnsiString): lua_CFunction;
// メタ関数の取得
begin
  Result := nil;
  Index := LuaAbsIndex(L, Index);
  if not lua_getmetatable(L, Index) then
    Exit;

  LuaGetTable(L, -1, Key);
  if lua_iscfunction(L, -1) then
    Result := lua_tocfunction(L, -1);
  lua_pop(L, 2);
end;

procedure LuaSetMetaFunction(L: Plua_State; Index: Integer; Key: AnsiString; F: lua_CFunction);
// メタ関数の設定
// Key = __add, __sub, __mul, __div, __pow, __unm, __concat,
//       __eq, __lt, __le, __index, __newindex, __call
// [メモ]
// __newindex は 新規代入時しか呼ばれないので注意
// table をグローバル変数とするとこうなる。
//
// a=1  -- (a=nilなので)メタ関数呼び出される
// a=2  -- メタ関数は呼び出されない
// a=3  -- メタ関数は呼び出されない
// a=nil
// a=4  -- (a=nilなので)メタ関数呼び出される
//
// lua 付属の trace-globals では__newindex と __index をセットで上書きして
// グローバル変数へのアクセスをローカル変数へのアクセスに切り替えてグロー
// バル変数の実体は常に table[key] = nil を保たせて __newindex イベントを
// 発生させている。
begin
  Index := LuaAbsIndex(L, Index);
  if not lua_getmetatable(L, Index) then
    lua_newtable(L);

  LuaRawSetTableFunction(L, -1, Key, F);
  lua_setmetatable(L, Index);
end;

// Convert the last item at 'Index' from the stack to a string
// nil    : nil
// Number : FloatToStr
// Boolean: True/False
// stirng : "..."
// Table  : { Key1=Value Key2=Value }
function LuaStackToStr(L: Plua_State; Index: Integer; MaxTable: Integer; SubTableMax: Integer; CheckCyclicReferencing: Boolean; TablePtrs: TList): AnsiString;
var
  pGLobalsIndexPtr: Pointer;
  bToFree: Boolean;

  function TableToStr(Index: Integer): AnsiString;
  var
    Key, Value: AnsiString;
    Count: Integer;

  begin
    Result := '{ ';
    Count := 0;
    lua_pushnil(L);


    // Go through the current table
    while (lua_next(L, Index) <> 0) do
    begin
      Inc(Count);
      if (Count > MaxTable) then
      begin
        Result := Result + '... ';
        lua_pop(L, 2);
        Break;
      end;

      // Key to string
      if lua_type(L, -2) = LUA_TNUMBER then
        Key := '[' + Dequote(LuaStackToStr(L, -2, MaxTable, SubTableMax, CheckCyclicReferencing, TablePtrs)) + ']'
      else
        Key := Dequote(LuaStackToStr(L, -2, MaxTable, SubTableMax, CheckCyclicReferencing, TablePtrs));

      // Value to string...
      if ((Key = '_G') or (lua_topointer(L, -1) = pGLobalsIndexPtr)) then
        Value := LuaGlobalVariableStr
      else if lua_type(L, -1) = LUA_TTABLE then
      begin
        if Assigned(TablePtrs) and CheckCyclicReferencing and (TablePtrs.IndexOf(lua_topointer(L, -1)) <> -1) then
          Value := '[CYCLIC_REFERENCING_DETECTED]'
        else
          Value := LuaStackToStr(L, -1, MaxTable, SubTableMax, CheckCyclicReferencing, TablePtrs);
      end
      else
        Value := LuaStackToStr(L, -1, MaxTable, SubTableMax, CheckCyclicReferencing, TablePtrs);

      if (lua_type(L, -1) = LUA_TFUNCTION) then
        Result := Result + AnsiString(Format('%s()=%p ', [Key, lua_topointer(L, -1)]))
      else
        Result := Result + AnsiString(Format('%s=%s ', [Key, Value]));

      // Pop current value from stack leaving current key on top of the stack for lua_next
      lua_pop(L, 1);
    end;

    Result := Result + '}';
  end;
begin
  bToFree := False;

  if not Assigned(TablePtrs) then
  begin
    TablePtrs := TList.Create;
    bToFree := True;
  end;

  if (MaxTable < 0) then
    MaxTable := DefaultMaxTable;

  pGLobalsIndexPtr := lua_topointer(L, LUA_GLOBALSINDEX); // Retrieve globals index poiner for later conditions
  lua_checkstack(L, SubTableMax * 3); // Ensure there is enough space on stack to work with according to user's setting
  Index := LuaAbsIndex(L, Index);

  case (lua_type(L, Index)) of
  LUA_TNIL:
    Result := 'nil';
  LUA_TNUMBER:
    Result := AnsiString(Format('%g', [lua_tonumber(L, Index)]));
  LUA_TBOOLEAN:
    Result := AnsiString(BoolToStr(lua_toboolean(L, Index), True));
  LUA_TSTRING:
    Result := '"'+lua_tostring(L, Index)+'"';
  LUA_TTABLE:
  begin
    if SubTableCount < SubTableMax then
    begin
      if Assigned(TablePtrs) and CheckCyclicReferencing and (TablePtrs.IndexOf(lua_topointer(L, Index)) <> -1) then
      begin
        Result := '[CYCLIC_REFERENCING_DETECTED]'
      end
      else
      begin
        if Assigned(TablePtrs) then
          TablePtrs.Add(lua_topointer(L, Index));

        SubTableCount := SubTableCount + 1;
        Result := TableToStr(Index);
        SubTableCount := SubTableCount - 1;

        //if Assigned(TablePtrs) then
          //TablePtrs.Delete(TablePtrs.IndexOf(lua_topointer(L, Index)));
      end;
    end
    else
      Result := '[SUB_TABLE_MAX_LEVEL_HAS_BEEN_REACHED]';
  end;
  LUA_TFUNCTION:
    if lua_iscfunction(L, Index) then
      Result := AnsiString(Format('CFUNC:%p', [Pointer(lua_tocfunction(L, Index))]))
    else
      Result := AnsiString(Format('FUNC:%p', [lua_topointer(L, Index)]));
  LUA_TUSERDATA:
    Result := AnsiString(Format('USERDATA:%p', [lua_touserdata(L, Index)]));
  LUA_TTHREAD:
    Result := AnsiString(Format('THREAD:%p', [lua_tothread(L, Index)]));
  LUA_TLIGHTUSERDATA:
    Result := AnsiString(Format('LIGHTUSERDATA:%p', [lua_touserdata(L, Index)]));
  else
    Assert(False);
  end;

  if bToFree then
    TablePtrs.Free;
end;

procedure LuaShowStack(L: Plua_State; Caption: AnsiString);
var
  I, N: Integer;
  S: AnsiString;
begin
  N := lua_gettop(L);
  S := '[' + Caption + ']';
  
  for I := N downto 1 do
  begin
    S := S + CRLF + AnsiString(Format('%3d,%3d:%s', [LuaAbsIndex(L, I), LuaIncIndex(L, I), LuaStackToStr(L, I, -1)]));
  end;

  ShowMessage(string(S));
end;

procedure LuaProcessTableName(L: Plua_State; const Name: PAnsiChar;
  var LastName: AnsiString; var TableIndex, Count: Integer);
// Name のテーブル要素をスタックに積んで、
// スタックに積んだ数と Name の最終要素の名前とその親テーブルのインデックスを返す
// テーブルが無い場合は作成する
// LuaProcessTableName(L, 'print', S, TI, Count) → S = print, TI = LUA_GLOBALSINDEX, Count = 0
// LuaProcessTableName(L, 'io.write', S, TI, Count) → S = write, TI -> io, Count = 1
// LuaProcessTableName(L, 'a.b.c.func', S, TI, Count) → S = func, TI -> a.b.c, Count = 3

var
  S: AnsiString;


  function GetToken: AnsiString;
  var
    Index: Integer;
  begin
    Index := Pos('.', String(S));
    if (Index = 0) then
    begin
      Result := S;
      S := '';
      Exit;
    end;
    Result := Copy(S, 1, Index - 1);
    S := Copy(S, Index + 1, Length(S));
  end;


begin
  S := Name;
  Count := 0;

  LastName := GetToken;
  while (S <> '') do
  begin
    Inc(Count);
    TableIndex := LuaAbsIndex(L, TableIndex);
    LuaGetTable(L, TableIndex, LastName);
    if (lua_type(L, -1) <> LUA_TTABLE) then
    begin
      lua_pop(L, 1);
      lua_pushstring(L, PAnsiChar(LastName));
      lua_newtable(L);
      lua_rawset(L, TableIndex);
      LuaGetTable(L, TableIndex, LastName);
    end;
    TableIndex := -1;
    LastName := GetToken;
  end;
end;

procedure LuaRegisterCustom(L: PLua_State; TableIndex: Integer; const Name: PAnsiChar; F: lua_CFunction);
var
  Count: Integer;
  S: AnsiString;
begin
  LuaProcessTableName(L, Name, S, TableIndex, Count);
  LuaRawSetTableFunction(L, TableIndex, S, F);
  lua_pop(L, Count);
end;

procedure LuaRegister(L: Plua_State; const Name: PAnsiChar; F: lua_CFunction);
// 関数の登録
// LuaRegister(L, 'print', lua_print);
// LuaRegister(L, 'io.write', lua_io_write);  // テーブル io が無い場合は作成
// LuaRegister(L, 'a.b.c.func', a_b_c_func);  // テーブル a.b.c が無い場合は作成
begin
  LuaRegisterCustom(L, LUA_GLOBALSINDEX, Name, F);
end;

procedure LuaRegisterMetatable(L: Plua_State; const Name: PAnsiChar; F: lua_CFunction);
begin
  LuaRegisterCustom(L, LUA_REGISTRYINDEX, Name, F);
end;

procedure LuaRegisterProperty(L: PLua_State; const Name: PAnsiChar; ReadFunc, WriteFunc: lua_CFunction);
var
  Count: Integer;
  TI: Integer;
  S: AnsiString;
begin
  TI := LUA_GLOBALSINDEX;
  LuaProcessTableName(L, Name, S, TI, Count);
  TI := LuaAbsIndex(L, TI);

  LuaGetTable(L, TI, S);
  if (lua_type(L, -1) <> LUA_TTABLE) then
  begin
    lua_pop(L, 1);
    lua_pushstring(L, PAnsiChar(S));
    lua_newtable(L);
    lua_settable(L, TI);
    LuaGetTable(L, TI, S);
  end;
  if (Assigned(ReadFunc)) then
    LuaSetMetaFunction(L, -1, '__index', ReadFunc);
  if (Assigned(WriteFunc)) then
    LuaSetMetaFunction(L, -1, '__newindex', WriteFunc);
  lua_pop(L, Count + 1);
end;

procedure LuaStackToStrings(L: Plua_State; Lines: TStrings; MaxTable: Integer; SubTableMax: Integer; CheckCyclicReferencing: Boolean);
var
  I: Integer;
begin
  Lines.Clear;
  
  for I := lua_gettop(L) downto 1 do
  begin
    Lines.Add(string(LuaStackToStr(L, I, MaxTable, SubTableMax, CheckCyclicReferencing)));
  end;
end;

procedure LuaLocalToStrings(L: Plua_State; Lines: TStrings; MaxTable: Integer; Level: Integer; SubTableMax: Integer; CheckCyclicReferencing: Boolean);
var
  Name: PAnsiChar;
  Index: Integer;
  Debug: lua_Debug;
  AR: Plua_Debug;
begin
  AR := @Debug;
  Lines.Clear;
  Index := 1;
  
  if (lua_getstack(L, Level, AR) = 0) then
    Exit;

  Name := lua_getlocal(L, AR, Index);
  
  while (Name <> nil) do
  begin
    Lines.Values[string(Name)] := string(LuaStackToStr(L, -1, MaxTable, SubTableMax, CheckCyclicReferencing));
    lua_pop(L, 1);
    Inc(Index);
    Name := lua_getlocal(L, AR, Index);
  end;
end;
{
procedure LuaGlobalToStrings(L: PLua_State; Lines: TStrings; MaxTable: Integer; SubTableMax: Integer; CheckCyclicReferencing: Boolean);
begin
  lua_pushvalue(L, LUA_GLOBALSINDEX);
  LuaTableToStrings(L, -1, Lines, MaxTable, SubTableMax);
  lua_pop(L, 1);
end;
}

procedure LuaTableToStrings(L: Plua_State; Index: Integer; Lines: TStrings; MaxTable: Integer; SubTableMax: Integer; CheckCyclicReferencing: Boolean);
var
  Key, Value: AnsiString;
begin
  Index := LuaAbsIndex(L, Index);
  Lines.Clear;
  lua_pushnil(L);
  
  while (lua_next(L, Index) <> 0) do
  begin
    Key := Dequote(LuaStackToStr(L, -2, MaxTable, SubTableMax, CheckCyclicReferencing));
    Value := LuaStackToStr(L, -1, MaxTable, SubTableMax, CheckCyclicReferencing);
    Lines.Values[string(Key)] := string(Value);
    lua_pop(L, 1);
  end;
end;

{
procedure LuaTableToVirtualTreeView(L: Plua_State; Index: Integer; VTV: TVirtualStringTree; MaxTable: Integer; SubTableMax: Integer; CheckCyclicReferencing: Boolean);
var
  pGLobalsIndexPtr: Pointer;
  PtrsList: TList;
  pTreeNodeData: PBasicTreeData;

  // Go through all child of current table and create nodes
  procedure ParseTreeNode(TreeNode: PVirtualNode; Index: Integer);
  var
    Key: AnsiString;
    pData: PBasicTreeData;
    pNode: PVirtualNode;
  begin
    // Retreive absolute index
    Index := LuaAbsIndex(L, Index);
    lua_pushnil(L);

    while (lua_next(L, Index) <> 0) do
    begin
      if Assigned(TreeNode) then
        pTreeNodeData := VTV.GetNodeData(TreeNode)
      else
        pTreeNodeData := nil;

      if (pTreeNodeData = nil) or (pTreeNodeData.sValue <> '[CYCLIC_REFERENCING_DETECTED]') then
      begin
        Key := Dequote(LuaStackToStr(L, -2, MaxTable, SubTableMax, CheckCyclicReferencing));

        if lua_type(L, -1) <> LUA_TTABLE then
        begin
          pData := VTV.GetNodeData(VTV.AddChild(TreeNode));
          pData.sName := Key;
          pData.sValue := LuaStackToStr(L, -1, MaxTable, SubTableMax, CheckCyclicReferencing);
        end
        else
        begin
          if ((Key = '_G') or (lua_topointer(L, -1) = pGLobalsIndexPtr)) then
          begin
            pData := VTV.GetNodeData(VTV.AddChild(TreeNode));
            pData.sName := Key;
            pData.sValue := '[LUA_GLOBALSINDEX]';
          end
          else
          begin
            pNode := VTV.AddChild(TreeNode);
            pData := VTV.GetNodeData(pNode);
            pData.sName := Key;

            if CheckCyclicReferencing and (PtrsList.IndexOf(lua_topointer(L, -1)) <> -1) then
              pData.sValue := '[CYCLIC_REFERENCING_DETECTED]'
            else
              pData.sValue := LuaStackToStr(L, -1, MaxTable, SubTableMax, CheckCyclicReferencing);

            if SubTableCount < SubTableMax then
            begin
              if CheckCyclicReferencing then
                PtrsList.Add(lua_topointer(L, -1));

              SubTableCount := SubTableCount + 1;
              ParseTreeNode(pNode, -1);
              SubTableCount := SubTableCount - 1;

              if not Assigned(TreeNode) then
                PtrsList.Clear;
            end;
          end;
        end;
      end;

      lua_pop(L, 1);
    end;
  end;
begin
  PtrsList := TList.Create;
  Assert(lua_type(L, Index) = LUA_TTABLE);
  lua_checkstack(L, SubTableMax * 3); // Ensure there is enough space on stack to work with according to user's setting
  pGLobalsIndexPtr := lua_topointer(L, LUA_GLOBALSINDEX); // Retrieve globals index pointer for later conditions
  VTV.BeginUpdate;
  VTV.Clear;
  try
    ParseTreeNode(nil, Index);
  finally
    VTV.EndUpdate;
    PtrsList.Free;
  end;
end;
}

function LuaGetIdentValue(L: Plua_State; Ident: AnsiString; MaxTable: Integer): AnsiString;
const
  DebugValue = '___DEBUG_VALUE___';
var
  Local: TStrings;
  Code: AnsiString;
  Hook: lua_Hook;
  Mask: Integer;
  Count: Integer;
begin
  if (Ident = '') then
  begin
    Result := '';
    Exit;
  end;

  Local := TStringList.Create;
  try
    LuaLocalToStrings(L, Local, MaxTable);
    Result := AnsiString(Local.Values[string(Ident)]);
    if (Result <> '') then
      Exit;
  finally
    Local.Free;
  end;

  Code := DebugValue + '=' + Ident;
  luaL_loadbuffer(L, PAnsiChar(Code), Length(Code), 'debug');
  Hook := lua_gethook(L);
  Mask := lua_gethookmask(L);
  Count := lua_gethookcount(L);
  lua_sethook(L, Hook, 0, Count);

  if (lua_pcall(L, 0, 0, 0) = 0) then
    LuaRawGetTable(L, LUA_GLOBALSINDEX, DebugValue);

  Result := LuaStackToStr(L, -1, MaxTable, MaxTable, True);
  lua_remove(L, -1);
  luaL_dostring(L, DebugValue + '=nil');
  lua_sethook(L, Hook, Mask, Count);
end;

procedure LuaSetIdentValue(L: Plua_State; Ident, Value: AnsiString; MaxTable: Integer);
var
  Local: TStrings;
  Code: AnsiString;
  Index: Integer;
  Debug: lua_Debug;
  AR: Plua_Debug;
  buf: AnsiString;
begin
  Local := TStringList.Create;
  try
    AR := @Debug;
    LuaLocalToStrings(L, Local, MaxTable);
    Index := Local.IndexOf(string(Ident));
    if (Index >= 0) then
    begin
      try
        lua_pushnumber(L, StrToFloat(string(Value)));
      except
        buf := Dequote(Value);
        lua_pushstring(L, PAnsiChar(buf));
      end;
      lua_getstack(L, 0, AR);
      lua_getinfo(L, 'Snlu', AR);
      lua_setlocal(L, AR, Index + 1);
    end else
    begin
      Code := Ident + '=' + Value;
      luaL_loadbuffer(L, PAnsiChar(Code), Length(Code), 'debug');
      if (lua_pcall(L, 0, 0, 0) <> 0) then
        lua_remove(L, -1);
    end;
  finally
    Local.Free;
  end;
end;

procedure LuaProcessErrorMessage(const ErrMsg: AnsiString; var Title: AnsiString; var Line: Integer; var Msg: AnsiString);
const
  Term = #$00;
  function S(Index: Integer): AnsiChar;
  begin
    if (Index <= Length(ErrMsg)) then
      Result := ErrMsg[Index]
    else
      Result := Term;
  end;
  function IsDigit(C: AnsiChar): Boolean;
  begin
    Result := ('0' <= C) and (C <= '9');
  end;
  function PP(var Index: Integer): Integer;
  begin
    Inc(Index);
    Result := Index;
  end;
var
  I, Start, Stop: Integer;
  LS: AnsiString;
  Find: Boolean;
begin
  // ErrMsg = Title:Line:Message
  Title := '';
  Line := 0;
  Msg := ErrMsg;
  Find := False;
  I := 1 - 1;
  Stop := 0;
  // :数値: を探す
  repeat
    while (S(PP(I)) <> ':') do
      if (S(I) = Term) then
        Exit;
    Start := I;
    if (not IsDigit(S(PP(I)))) then
      Continue;
    while (IsDigit(S(PP(I)))) do
      if (S(I - 1) = Term) then
        Exit;
    Stop := I;
    if (S(I) = ':') then
      Find := True;
  until (Find);
  Title := Copy(ErrMsg, 1, Start - 1);
  LS := Copy(ErrMsg, Start + 1, Stop - Start - 1);
  Line := StrToIntDef(string(LS), 0);
  Msg := Copy(ErrMsg, Stop + 1, Length(ErrMsg));
end;

procedure LuaLoadBuffer(L: Plua_State; const Code: AnsiString; const Name: AnsiString);
var
  Title, Msg: AnsiString;
  Line: Integer;
begin
  if (luaL_loadbuffer(L, PAnsiChar(Code), Length(Code), PAnsiChar(Name)) = 0) then
    Exit;

  LuaProcessErrorMessage(LuaStackToStr(L, -1, -1, 99, True), Title, Line, Msg);
  raise ELuaException.Create(Title, Line, Msg);
end;

procedure LuaLoadBufferFromFile(L: Plua_State; const Filename: AnsiString; const Name: AnsiString);
Var
   xCode : AnsiString;
   xFile :TStringList;

begin
     xFile := TStringList.Create;
     xFile.LoadFromFile(string(FileName));
     xCode := AnsiString(xFile.Text);
     xFile.Free;
     LuaLoadBuffer(L, xCode, Name);
end;

procedure LuaPCall(L: Plua_State; NArgs, NResults, ErrFunc: Integer);
var
  Title, Msg: AnsiString;
  Line: Integer;
begin
  if (lua_pcall(L, NArgs, NResults, ErrFunc) = 0) then
    Exit;

  LuaProcessErrorMessage(Dequote(LuaStackToStr(L, -1, -1, 99, True)), Title, Line, Msg);
  raise ELuaException.Create(Title, Line, Msg);
end;

function LuaPCallFunction(L: Plua_State; FunctionName : AnsiString;
                          const Args: array of Variant;
                          Results : PVariantArray;
                          ErrFunc: Integer=0;
                          NResults :Integer=LUA_MULTRET):Integer;
var
   NArgs, i: Integer;

begin
     //Put Function To Call on the Stack
     luaPushString(L, FunctionName);
     lua_gettable(L, LUA_GLOBALSINDEX);

     //Put Parameters on the Stack
     NArgs := High(Args)+1;
     for i:=0 to (NArgs-1) do
       LuaPushVariant(L, Args[i]);

     //Call the Function
     LuaPcall(L, NArgs, NResults, ErrFunc);
     Result :=lua_gettop(L);   //Get Number of Results

     if (Results<>Nil)
     then begin 
               //Get Results in the right order
               SetLength(Results^, Result);
               for i:=0 to Result-1 do
               begin
                    Results^[Result-(i+1)] :=LuaToVariant(L, -(i+1));
               end;
          end;
end;

procedure LuaError(L: Plua_State; const Msg: AnsiString);
begin
  luaL_error(L, PAnsiChar(Msg));
end;

procedure LuaErrorFmt(L: Plua_State; const Fmt: AnsiString; const Args: array of Const);
begin
  LuaError(L, AnsiString(Format(string(Fmt), Args)));
end;

{ ELuaException }

constructor ELuaException.Create(Title: AnsiString; Line: Integer;
  Msg: AnsiString);
var
  LS: AnsiString;
begin
  if (Line > 0) then
    LS := AnsiString(Format('(%d)', [Line]))
  else
    LS := '';
  inherited Create(string(Title + LS + Msg));
  Self.Title := Title;
  Self.Line := Line;
  Self.Msg := Msg;
end;

function LuaDataStrToStrings(const TableStr: AnsiString; Strings: TStrings): AnsiString;
(*
  LuaStackToStr 形式から Strings.Values[Name] 構造へ変換
  TableStr
  { Name = "Lua" Version = 5.0 }
  ↓
  Strings
  Name="Lua"
  Version=5.0

  DataList  : Data DataList
            |

  Data      : Table
            | {グローバル変数}
            | Ident ( )
            | Ident = Value
            | Ident
            |

  Table     : { DataList }
            |

  Value     : "..."
            | Data

*)
const
  EOF = #$00;
var
  Index: Integer;
  Text: AnsiString;
  Token: AnsiChar;
  function S(Index: Integer): AnsiChar;
  begin
    if (Index <= Length(TableStr)) then
      Result := TableStr[Index]
    else
      Result := EOF;
  end;
  function GetString: AnsiString;
  var
    SI: Integer;
  begin
    Dec(Index);
    Result := '';
    repeat
      Assert(S(Index) = '"');
      SI := Index;
      Inc(Index);
      while (S(Index) <> '"') do
        Inc(Index);
      Result := Result + Copy(TableStr, SI, Index - SI + 1);
      Inc(Index);
    until (S(Index) <> '"');
  end;
  function GetValue: AnsiString;
    function IsIdent(C: AnsiChar): Boolean;
    const
      S = ' =(){}' + CR + LF;
    begin
      Result := (Pos(string(C), string(S)) = 0);
    end;
  var
    SI: Integer;
  begin
    Dec(Index);
    SI := Index;
    while (IsIdent(S(Index))) do
      Inc(Index);
    Result := Copy(TableStr, SI, Index - SI);
  end;
  function GetToken: AnsiChar;
    function SkipSpace(var Index: Integer): Integer;
    const
      TAB = #$09;
      CR = #$0D;
      LF = #$0A;
    begin
      while (S(Index) in [' ', TAB, CR, LF]) do
        Inc(Index);
      Result := Index;
    end;
  begin
    SkipSpace(Index);
    Token := S(Index);
    Inc(Index);
    Text := Token;
    case (Token) of
    EOF: ;
    '"': Text := GetString;
    '{':
      if (Copy(TableStr, Index - 1, Length(LuaGlobalVariableStr)) = LuaGlobalVariableStr) then
      begin
        Token := 'G';
        Text := LuaGlobalVariableStr;
        Inc(Index, Length(LuaGlobalVariableStr) - 1);
      end;
    '}': ;
    '(': ;
    ')': ;
    '=': ;
    else Text := GetValue
    end;
    Result := Token;
  end;
  procedure Check(S: AnsiString);
  begin
    if (Pos(Token, S) = -1) then
      raise Exception.CreateFmt('Error %s is required :%s', [Copy(TableStr, Index - 1, Length(TableStr))]);
  end;
  function CheckGetToken(S: AnsiString): AnsiChar;
  begin
    Result := GetToken;
    Check(S);
  end;
  function ParseData: AnsiString; forward;
  function ParseTable: AnsiString; forward;
  function ParseValue: AnsiString; forward;
  function ParseDataList: AnsiString;
  begin
    with (TStringList.Create) do
    try
      while not (Token in [EOF, '}']) do
        Add(string(ParseData));
      Result := AnsiString(Text);
    finally
      Free;
    end;
  end;
  function ParseData: AnsiString;
  begin
    if (Token = EOF) then
    begin
      Result := '';
      Exit;
    end;

    case (Token) of
    '{': Result := ParseTable;
    'G':
      begin
        Result := Text;
        GetToken;
      end;
    else
      begin
        Result := Text;
        case (GetToken) of
        '(':
          begin
            CheckGetToken(')');
            Result := AnsiString(Format('%s=()', [string(Result)]));
            GetToken;
          end;
        '=':
          begin
            GetToken;
            Result := AnsiString(Format('%s=%s', [string(Result), string(ParseValue)]));
          end;
        end;
      end;
    end;
  end;
  function ParseTable: AnsiString;
  begin
    if (Token in [EOF]) then
    begin
      Result := '';
      Exit;
    end;
    Check('{');
    GetToken;
    with (TStringList.Create) do
    try
      Text := string(ParseDataList);
      Result := AnsiString(CommaText);
    finally
      Free;
    end;
    Check('}');
    GetToken;
  end;
  function ParseValue: AnsiString;
  begin
    if (Token = EOF) then
    begin
      Result := '';
      Exit;
    end;

    case (Token) of
    '"':
      begin
        Result := Text;
        GetToken;
      end;
    else
      Result := ParseData;
    end;
  end;
begin
  Index := 1;
  GetToken;
  Strings.Text := string(ParseDataList);
end;           

function LuaDoFile(L: Plua_State): Integer; cdecl;
// dofile 引数(arg)戻り値付き
// Lua: DoFile(FileName, Args...)
const
  ArgIdent = 'arg';
var
  FileName: PAnsiChar;
  I, N, R: Integer;
  ArgTable, ArgBackup: Integer;
begin
  N := lua_gettop(L);

  // arg, result の保存
  lua_getglobal(L, ArgIdent);
  ArgBackup := lua_gettop(L);

  FileName := luaL_checkstring(L, 1);
  lua_newtable(L);
  ArgTable := lua_gettop(L);
  for I := 2 to N do
  begin
    lua_pushvalue(L, I);
    lua_rawseti(L, ArgTable, I - 1);
  end;
  lua_setglobal(L, ArgIdent);

  Result := lua_gettop(L);
  luaL_loadfile(L, PAnsiChar(FileName));
  R := lua_pcall(L, 0, LUA_MULTRET, 0);
  Result := lua_gettop(L) - Result;

  LuaRawSetTableValue(L, LUA_GLOBALSINDEX, ArgIdent, ArgBackup);
  lua_remove(L, ArgBackup);

  if (R <> 0) then
    lua_error(L);
end;

initialization
  DefaultMaxTable := 256;

end.
