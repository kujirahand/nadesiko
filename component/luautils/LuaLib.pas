(*
** $Id: lualib.pas,v 1.1 2005/04/24 19:31:20 jfgoulet Exp $
** Lua standard libraries
** See Copyright Notice in lua.h
**
**
** 10/02/2006 Jean-Francois Goulet - Removed the luaopen_loadlib declaration for
**                                   Lua 5.1 compatibility.
** 10/02/2006 Jean-Francois Goulet - Modified all lua_****libopen() functions to
**                                   support in-lua calls for Lua 5.1 compatibility.
*)
unit lualib;

{$IFNDEF lualib_h}
{$DEFINE lualib_h}
{$ENDIF}

interface

uses
  lua;

const
  LUA_PACKLIBNAME = 'package';
  LUA_COLIBNAME = 'coroutine';
  LUA_TABLIBNAME = 'table';
  LUA_IOLIBNAME = 'io';
  LUA_OSLIBNAME = 'os';
  LUA_STRLIBNAME = 'string';
  LUA_MATHLIBNAME = 'math';
  LUA_DBLIBNAME = 'debug';

function luaopen_base(L: Plua_State): Integer;
  cdecl external 'lua.dll';

function luaopen_package(L: Plua_State): Integer;
  cdecl external 'lua.dll';

function luaopen_table(L: Plua_State): Integer;
  cdecl external 'lua.dll';

function luaopen_io(L: Plua_State): Integer;
  cdecl external 'lua.dll';

function luaopen_string(L: Plua_State): Integer;
  cdecl external 'lua.dll';

function luaopen_math(L: Plua_State): Integer;
  cdecl external 'lua.dll';

function luaopen_debug(L: Plua_State): Integer;
  cdecl external 'lua.dll';


(* to help testing the libraries *)
{$IFNDEF lua_assert}
//#define lua_assert(c)   (* empty *)
{$ENDIF}


(* compatibility code *)
function lua_baselibopen(L: Plua_State): Integer;
function lua_packlibopen(L: Plua_State): Integer;
function lua_tablibopen(L: Plua_State): Integer;
function lua_iolibopen(L: Plua_State): Integer;
function lua_strlibopen(L: Plua_State): Integer;
function lua_mathlibopen(L: Plua_State): Integer;
function lua_dblibopen(L: Plua_State): Integer;

implementation

function lua_baselibopen(L: Plua_State): Integer;
begin
  lua_pushcfunction(L, luaopen_base);
  lua_pushstring(L, '');
  lua_call(L, 1, 0);
  Result := 1;
end;

function lua_packlibopen(L: Plua_State): Integer;
begin
  lua_pushcfunction(L, luaopen_package);
  lua_pushstring(L, 'package');
  lua_call(L, 1, 0);
  Result := 1;
end;

function lua_tablibopen(L: Plua_State): Integer;
begin
  lua_pushcfunction(L, luaopen_table);
  lua_pushstring(L, 'table');
  lua_call(L, 1, 0);
  Result := 1;
end;

function lua_iolibopen(L: Plua_State): Integer;
begin
  lua_pushcfunction(L, luaopen_io);
  lua_pushstring(L, 'io');
  lua_call(L, 1, 0);
  Result := 1;
end;

function lua_strlibopen(L: Plua_State): Integer;
begin
  lua_pushcfunction(L, luaopen_string);
  lua_pushstring(L, 'string');
  lua_call(L, 1, 0);
  Result := 1;
end;

function lua_mathlibopen(L: Plua_State): Integer;
begin
  lua_pushcfunction(L, luaopen_math);
  lua_pushstring(L, 'math');
  lua_call(L, 1, 0);
  Result := 1;
end;

function lua_dblibopen(L: Plua_State): Integer;
begin
  lua_pushcfunction(L, luaopen_debug);
  lua_pushstring(L, 'debug');
  lua_call(L, 1, 0);
  Result := 1;
end;

end.
