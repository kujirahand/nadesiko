unit Lua;

(*
 * A complete Pascal wrapper for Lua 5.1 DLL module.
 *
 * Created by Geo Massar, 2006
 * Distributed as free/open source.
 * ---
 * modified kujirahand.com 2009
 *)

interface

type
  size_t   = type Cardinal;
  Psize_t  = ^size_t;
  PPointer = ^Pointer;

  lua_State = record end;
  Plua_State = ^lua_State;

const
  LuaDLL = 'lua.dll'; // 10/02/2006 Jean-Francois Goulet - Changed the dll name
                      // for backward compatibility with LuaEdit

(*****************************************************************************)
(*                               luaconfig.h                                 *)
(*****************************************************************************)

(*
** $Id: luaconf.h,v 1.81 2006/02/10 17:44:06 roberto Exp $
** Configuration file for Lua
** See Copyright Notice in lua.h
*)

(*
** {==================================================================
@@ LUA_NUMBER is the type of numbers in Lua.
** CHANGE the following definitions only if you want to build Lua
** with a number type different from double. You may also need to
** change lua_number2int & lua_number2integer.
** ===================================================================
*)
type
  LUA_NUMBER_  = type Double;            // ending underscore is needed in Pascal
  LUA_INTEGER_ = type Integer;

(*
@@ LUA_IDSIZE gives the maximum size for the description of the source
@* of a function in debug information.
** CHANGE it if you want a different size.
*)
const
  LUA_IDSIZE = 60;

(*
@@ LUAL_BUFFERSIZE is the buffer size used by the lauxlib buffer system.
*)
const
  LUAL_BUFFERSIZE = 1024;

(*
@@ LUA_PROMPT is the default prompt used by stand-alone Lua.
@@ LUA_PROMPT2 is the default continuation prompt used by stand-alone Lua.
** CHANGE them if you want different prompts. (You can also change the
** prompts dynamically, assigning to globals _PROMPT/_PROMPT2.)
*)
const
  LUA_PROMPT  = '> ';
  LUA_PROMPT2 = '>> ';

(*
@@  LUA_NUMBER_SCAN is the default scan number format in Lua
** Formats for Lua numbers
** Added by Jean-Francois Goulet - 10/02/2006
*)
{$IFNDEF LUA_NUMBER_SCAN}
const
  LUA_NUMBER_SCAN = '%lf';
{$ENDIF}

(*
@@  LUA_NUMBER_FMT is the default number format in Lua
** Formats for Lua numbers
** Added by Jean-Francois Goulet - 10/02/2006
*)
{$IFNDEF LUA_NUMBER_FMT}
const
  LUA_NUMBER_FMT = '%.14g';
{$ENDIF}

(*
@@ lua_readline defines how to show a prompt and then read a line from
@* the standard input.
@@ lua_saveline defines how to "save" a read line in a "history".
@@ lua_freeline defines how to free a line read by lua_readline.
** CHANGE them if you want to improve this functionality (e.g., by using
** GNU readline and history facilities).
*)
function  lua_readline(L : Plua_State; var b : PAnsiChar; p : PAnsiChar): Boolean;
procedure lua_saveline(L : Plua_State; idx : Integer);
procedure lua_freeline(L : Plua_State; b : PAnsiChar);

(*
@@ lua_stdin_is_tty detects whether the standard input is a 'tty' (that
@* is, whether we're running lua interactively).
** CHANGE it if you have a better definition for non-POSIX/non-Windows
** systems.
*/
#include <io.h>
#include <stdio.h>
#define lua_stdin_is_tty()	_isatty(_fileno(stdin))
*)
const
  lua_stdin_is_tty = TRUE;

(*****************************************************************************)
(*                                  lua.h                                    *)
(*****************************************************************************)

(*
** $Id: lua.h,v 1.216 2006/01/10 12:50:13 roberto Exp $
** Lua - An Extensible Extension Language
** Lua.org, PUC-Rio, Brazil (http://www.lua.org)
** See Copyright Notice at the end of this file
*)

const
  LUA_VERSION     = 'Lua 5.1';
  LUA_VERSION_NUM = 501;
  LUA_COPYRIGHT   = 'Copyright (C) 1994-2006 Tecgraf, PUC-Rio';
  LUA_AUTHORS     = 'R. Ierusalimschy, L. H. de Figueiredo & W. Celes';

  (* mark for precompiled code (`<esc>Lua') *)
  LUA_SIGNATURE = #27'Lua';

  (* option for multiple returns in `lua_pcall' and `lua_call' *)
  LUA_MULTRET = -1;

  (*
  ** pseudo-indices
  *)
  LUA_REGISTRYINDEX = -10000;
  LUA_ENVIRONINDEX  = -10001;
  LUA_GLOBALSINDEX  = -10002;

function lua_upvalueindex(idx : Integer) : Integer;   // a marco

const
  (* thread status; 0 is OK *)
  LUA_YIELD_    = 1;     // Note: the ending underscore is needed in Pascal
  LUA_ERRRUN    = 2;
  LUA_ERRSYNTAX = 3;
  LUA_ERRMEM    = 4;
  LUA_ERRERR    = 5;

type
  lua_CFunction = function(L : Plua_State) : Integer; cdecl;

  (*
  ** functions that read/write blocks when loading/dumping Lua chunks
  *)
  lua_Reader = function (L : Plua_State; ud : Pointer;
                         sz : Psize_t) : PAnsiChar; cdecl;
  lua_Writer = function (L : Plua_State; const p : Pointer; sz : size_t;
                         ud : Pointer) : Integer; cdecl;

  (*
  ** prototype for memory-allocation functions
  *)
  lua_Alloc = function (ud, ptr : Pointer;
                        osize, nsize : size_t) : Pointer; cdecl;

const
  (*
  ** basic types
  *)
  LUA_TNONE          = -1;

  LUA_TNIL           = 0;
  LUA_TBOOLEAN       = 1;
  LUA_TLIGHTUSERDATA = 2;
  LUA_TNUMBER        = 3;
  LUA_TSTRING        = 4;
  LUA_TTABLE         = 5;
  LUA_TFUNCTION      = 6;
  LUA_TUSERDATA	     = 7;
  LUA_TTHREAD        = 8;

  (* minimum Lua stack available to a C function *)
  LUA_MINSTACK = 20;

type
  (* type of numbers in Lua *)
  lua_Number = LUA_NUMBER_;

  (* type for integer functions *)
  lua_Integer = LUA_INTEGER_;



(*
** garbage-collection functions and options
*)
const
  LUA_GCSTOP       = 0;
  LUA_GCRESTART    = 1;
  LUA_GCCOLLECT    = 2;
  LUA_GCCOUNT      = 3;
  LUA_GCCOUNTB	   = 4;
  LUA_GCSTEP       = 5;
  LUA_GCSETPAUSE   = 6;
  LUA_GCSETSTEPMUL = 7;


(*
** ===============================================================
** some useful macros
** ===============================================================
*)
procedure lua_pop(L : Plua_State; n : Integer);

procedure lua_newtable(L : Plua_State);

procedure lua_register(L : Plua_State; n : PAnsiChar; f : lua_CFunction);

procedure lua_pushcfunction(L : Plua_State; f : lua_CFunction);

function  lua_strlen(L : Plua_State; idx : Integer) : Integer;

function lua_isfunction(L : Plua_State; n : Integer) : Boolean;
function lua_istable(L : Plua_State; n : Integer) : Boolean;
function lua_islightuserdata(L : Plua_State; n : Integer) : Boolean;
function lua_isnil(L : Plua_State; n : Integer) : Boolean;
function lua_isboolean(L : Plua_State; n : Integer) : Boolean;
function lua_isthread(L : Plua_State; n : Integer) : Boolean;
function lua_isnone(L : Plua_State; n : Integer) : Boolean;
function lua_isnoneornil(L : Plua_State; n : Integer) : Boolean;

procedure lua_pushliteral(L : Plua_State; s : PAnsiChar);

procedure lua_setglobal(L : Plua_State; s : PAnsiChar);
procedure lua_getglobal(L : Plua_State; s : PAnsiChar);

function lua_tostring(L : Plua_State; idx : Integer) : PAnsiChar;


(*
** compatibility macros and functions
*)
function lua_open : Plua_State;

procedure lua_getregistry(L : Plua_State);

function lua_getgccount(L : Plua_State) : Integer;

type
  lua_Chuckreader = type lua_Reader;
  lua_Chuckwriter = type lua_Writer;

(* ====================================================================== *)

(*
** {======================================================================
** Debug API
** =======================================================================
*)

(*
** Event codes
*)
const
  LUA_HOOKCALL    = 0;
  LUA_HOOKRET     = 1;
  LUA_HOOKLINE    = 2;
  LUA_HOOKCOUNT   = 3;
  LUA_HOOKTAILRET = 4;


(*
** Event masks
*)
  LUA_MASKCALL  = 1 shl LUA_HOOKCALL;
  LUA_MASKRET   = 1 shl LUA_HOOKRET;
  LUA_MASKLINE  = 1 shl LUA_HOOKLINE;
  LUA_MASKCOUNT = 1 shl LUA_HOOKCOUNT;

type
  lua_Debug = packed record
    event : Integer;
    name : PAnsiChar;          (* (n) *)
    namewhat : PAnsiChar;      (* (n) `global', `local', `field', `method' *)
    what : PAnsiChar;          (* (S) `Lua', `C', `main', `tail' *)
    source : PAnsiChar;        (* (S) *)
    currentline : Integer; (* (l) *)
    nups : Integer;        (* (u) number of upvalues *)
    linedefined : Integer; (* (S) *)
    lastlinedefined : Integer; (* (S) *) // 10/03/2006 Jean-Francois Goulet - Added new field for Lua 5.1 compatibility
    short_src : array [0..LUA_IDSIZE-1] of Char; (* (S) *)
    (* private part *)
    i_ci : Integer;        (* active function *)
  end;
  Plua_Debug = ^lua_Debug;

  (* Functions to be called by the debuger in specific events *)
  lua_Hook = procedure (L : Plua_State; AR : Plua_Debug); cdecl;


(*****************************************************************************)
(*                                  lualib.h                                 *)
(*****************************************************************************)

(*
** $Id: lualib.h,v 1.36 2005/12/27 17:12:00 roberto Exp $
** Lua standard libraries
** See Copyright Notice at the end of this file
*)

const
  (* Key to file-handle type *)
  LUA_FILEHANDLE  = 'FILE*';

  LUA_COLIBNAME   = 'coroutine';
  LUA_TABLIBNAME  = 'table';
  LUA_IOLIBNAME   = 'io';
  LUA_OSLIBNAME   = 'os';
  LUA_STRLIBNAME  = 'string';
  LUA_MATHLIBNAME = 'math';
  LUA_DBLIBNAME   = 'debug';
  LUA_LOADLIBNAME = 'package';

procedure lua_assert(x : Boolean);    // a macro


(*****************************************************************************)
(*                                  lauxlib.h                                *)
(*****************************************************************************)

(*
** $Id: lauxlib.h,v 1.87 2005/12/29 15:32:11 roberto Exp $
** Auxiliary functions for building Lua libraries
** See Copyright Notice at the end of this file.
*)

// not compatibility with the behavior of setn/getn in Lua 5.0
function  luaL_getn(L : Plua_State; idx : Integer) : Integer;
procedure luaL_setn(L : Plua_State; i, j : Integer);

const
  LUA_ERRFILE = LUA_ERRERR + 1;

type
  luaL_Reg = packed record
    name : PAnsiChar;
    func : lua_CFunction;
  end;
  PluaL_Reg = ^luaL_Reg;


(*
** ===============================================================
** some useful macros
** ===============================================================
*)

function luaL_argcheck(L : Plua_State; cond : Boolean; numarg : Integer;
                       extramsg : PAnsiChar): Integer;
function luaL_checkstring(L : Plua_State; n : Integer) : PAnsiChar;
function luaL_optstring(L : Plua_State; n : Integer; d : PAnsiChar) : PAnsiChar;
function luaL_checkint(L : Plua_State; n : Integer) : Integer;
function luaL_optint(L : Plua_State; n, d : Integer): Integer;
function luaL_checklong(L : Plua_State; n : LongInt) : LongInt;
function luaL_optlong(L : Plua_State; n : Integer; d : LongInt) : LongInt;

function luaL_typename(L : Plua_State; idx : Integer) : PAnsiChar;

function luaL_dofile(L : Plua_State; fn : PAnsiChar) : Integer;

function luaL_dostring(L : Plua_State; s : PAnsiChar) : Integer;

procedure luaL_getmetatable(L : Plua_State; n : PAnsiChar);

(* not implemented yet
#define luaL_opt(L,f,n,d) (lua_isnoneornil(L,(n)) ? (d) : f(L,(n)))
*)

(*
** {======================================================
** Generic Buffer manipulation
** =======================================================
*)

type
  luaL_Buffer = packed record
    p : PAnsiChar;       (* current position in buffer *)
    lvl : Integer;   (* number of strings in the stack (level) *)
    L : Plua_State;
    buffer : array [0..LUAL_BUFFERSIZE-1] of Char;
  end;
  PluaL_Buffer = ^luaL_Buffer;

procedure luaL_addchar(B : PluaL_Buffer; c : AnsiChar);

(* compatibility only *)
procedure luaL_putchar(B : PluaL_Buffer; c : AnsiChar);

procedure luaL_addsize(B : PluaL_Buffer; n : Integer);


(* ====================================================== *)


(* compatibility with ref system *)

(* pre-defined references *)
const
  LUA_NOREF  = -2;
  LUA_REFNIL = -1;

function lua_ref(L : Plua_State; lock : Boolean) : Integer;

procedure lua_unref(L : Plua_State; ref : Integer);

procedure lua_getref(L : Plua_State; ref : Integer);


(******************************************************************************)
(******************************************************************************)
(******************************************************************************)
type __lua_newstate = function(f : lua_Alloc; ud : Pointer):Plua_State;cdecl;
var  lua_newstate:__lua_newstate;
type __lua_close = procedure(L: Plua_State);cdecl;
var  lua_close:__lua_close;
type __lua_newthread = function(L : Plua_State):Plua_State;cdecl;
var  lua_newthread:__lua_newthread;
type __lua_atpanic = function(L : Plua_State; panicf : lua_CFunction):lua_CFunction;cdecl;
var  lua_atpanic:__lua_atpanic;
type __lua_gettop = function(L : Plua_State):Integer;cdecl;
var  lua_gettop:__lua_gettop;
type __lua_settop = procedure(L : Plua_State; idx : Integer);cdecl;
var  lua_settop:__lua_settop;
type __lua_pushvalue = procedure(L : Plua_State; idx : Integer);cdecl;
var  lua_pushvalue:__lua_pushvalue;
type __lua_remove = procedure(L : Plua_State; idx : Integer);cdecl;
var  lua_remove:__lua_remove;
type __lua_insert = procedure(L : Plua_State; idx : Integer);cdecl;
var  lua_insert:__lua_insert;
type __lua_replace = procedure(L : Plua_State; idx : Integer);cdecl;
var  lua_replace:__lua_replace;
type __lua_checkstack = function(L : Plua_State; sz : Integer):LongBool;cdecl;
var  lua_checkstack:__lua_checkstack;
type __lua_xmove = procedure(src, dest : Plua_State; n : Integer);cdecl;
var  lua_xmove:__lua_xmove;
type __lua_isnumber = function(L : Plua_State; idx : Integer):LongBool;cdecl;
var  lua_isnumber:__lua_isnumber;
type __lua_isstring = function(L : Plua_State; idx : Integer):LongBool;cdecl;
var  lua_isstring:__lua_isstring;
type __lua_iscfunction = function(L : Plua_State; idx : Integer):LongBool;cdecl;
var  lua_iscfunction:__lua_iscfunction;
type __lua_isuserdata = function(L : Plua_State; idx : Integer):LongBool;cdecl;
var  lua_isuserdata:__lua_isuserdata;
type __lua_type = function(L : Plua_State; idx : Integer):Integer;cdecl;
var  lua_type:__lua_type;
type __lua_typename = function(L : Plua_State; tp : Integer):PAnsiChar;cdecl;
var  lua_typename:__lua_typename;
type __lua_equal = function(L : Plua_State; idx1, idx2 : Integer):LongBool;cdecl;
var  lua_equal:__lua_equal;
type __lua_rawequal = function(L : Plua_State; idx1, idx2 : Integer):LongBool;cdecl;
var  lua_rawequal:__lua_rawequal;
type __lua_lessthan = function(L : Plua_State; idx1, idx2 : Integer):LongBool;cdecl;
var  lua_lessthan:__lua_lessthan;
type __lua_tonumber = function(L : Plua_State; idx : Integer):lua_Number;cdecl;
var  lua_tonumber:__lua_tonumber;
type __lua_tointeger = function(L : Plua_State; idx : Integer):lua_Integer;cdecl;
var  lua_tointeger:__lua_tointeger;
type __lua_toboolean = function(L : Plua_State; idx : Integer):LongBool;cdecl;
var  lua_toboolean:__lua_toboolean;
type __lua_tolstring = function(L : Plua_State; idx : Integer; len : Psize_t):PAnsiChar;cdecl;
var  lua_tolstring:__lua_tolstring;
type __lua_objlen = function(L : Plua_State; idx : Integer):size_t;cdecl;
var  lua_objlen:__lua_objlen;
type __lua_tocfunction = function(L : Plua_State; idx : Integer):lua_CFunction;cdecl;
var  lua_tocfunction:__lua_tocfunction;
type __lua_touserdata = function(L : Plua_State; idx : Integer):Pointer;cdecl;
var  lua_touserdata:__lua_touserdata;
type __lua_tothread = function(L : Plua_State; idx : Integer):Plua_State;cdecl;
var  lua_tothread:__lua_tothread;
type __lua_topointer = function(L : Plua_State; idx : Integer):Pointer;cdecl;
var  lua_topointer:__lua_topointer;
type __lua_pushnil = procedure(L : Plua_State);cdecl;
var  lua_pushnil:__lua_pushnil;
type __lua_pushnumber = procedure(L : Plua_State; n : lua_Number);cdecl;
var  lua_pushnumber:__lua_pushnumber;
type __lua_pushinteger = procedure(L : Plua_State; n : lua_Integer);cdecl;
var  lua_pushinteger:__lua_pushinteger;
type __lua_pushlstring = procedure(L : Plua_State; const s : PAnsiChar; ls : size_t);cdecl;
var  lua_pushlstring:__lua_pushlstring;
type __lua_pushstring = procedure(L : Plua_State; const s : PAnsiChar);cdecl;
var  lua_pushstring:__lua_pushstring;
type __lua_pushvfstring = function(L : Plua_State; const fmt : PAnsiChar; argp : Pointer):PAnsiChar;cdecl;
var  lua_pushvfstring:__lua_pushvfstring;
type __lua_pushfstring = function(L : Plua_State; const fmt : PAnsiChar):PAnsiChar;cdecl;
var  lua_pushfstring:__lua_pushfstring;
type __lua_pushcclosure = procedure(L : Plua_State; fn : lua_CFunction; n : Integer);cdecl;
var  lua_pushcclosure:__lua_pushcclosure;
type __lua_pushboolean = procedure(L : Plua_State; b : LongBool);cdecl;
var  lua_pushboolean:__lua_pushboolean;
type __lua_pushlightuserdata = procedure(L : Plua_State; p : Pointer);cdecl;
var  lua_pushlightuserdata:__lua_pushlightuserdata;
type __lua_pushthread = function(L : Plua_state):Cardinal;cdecl;
var  lua_pushthread:__lua_pushthread;
type __lua_gettable = procedure(L : Plua_State ; idx : Integer);cdecl;
var  lua_gettable:__lua_gettable;
type __lua_getfield = procedure(L : Plua_State; idx : Integer; k : PAnsiChar);cdecl;
var  lua_getfield:__lua_getfield;
type __lua_rawget = procedure(L : Plua_State; idx : Integer);cdecl;
var  lua_rawget:__lua_rawget;
type __lua_rawgeti = procedure(L : Plua_State; idx, n : Integer);cdecl;
var  lua_rawgeti:__lua_rawgeti;
type __lua_createtable = procedure(L : Plua_State; narr, nrec : Integer);cdecl;
var  lua_createtable:__lua_createtable;
type __lua_newuserdata = function(L : Plua_State; sz : size_t):Pointer;cdecl;
var  lua_newuserdata:__lua_newuserdata;
type __lua_getmetatable = function(L : Plua_State; objindex : Integer):LongBool;cdecl;
var  lua_getmetatable:__lua_getmetatable;
type __lua_getfenv = procedure(L : Plua_State; idx : Integer);cdecl;
var  lua_getfenv:__lua_getfenv;
type __lua_settable = procedure(L : Plua_State; idx : Integer);cdecl;
var  lua_settable:__lua_settable;
type __lua_setfield = procedure(L : Plua_State; idx : Integer; const k : PAnsiChar);cdecl;
var  lua_setfield:__lua_setfield;
type __lua_rawset = procedure(L : Plua_State; idx : Integer);cdecl;
var  lua_rawset:__lua_rawset;
type __lua_rawseti = procedure(L : Plua_State; idx , n: Integer);cdecl;
var  lua_rawseti:__lua_rawseti;
type __lua_setmetatable = function(L : Plua_State; objindex : Integer):LongBool;cdecl;
var  lua_setmetatable:__lua_setmetatable;
type __lua_setfenv = function(L : Plua_State; idx : Integer):LongBool;cdecl;
var  lua_setfenv:__lua_setfenv;
type __lua_call = procedure(L : Plua_State; nargs, nresults : Integer);cdecl;
var  lua_call:__lua_call;
type __lua_pcall = function(L : Plua_State; nargs, nresults, errfunc : Integer):Integer;cdecl;
var  lua_pcall:__lua_pcall;
type __lua_cpcall = function(L : Plua_State; func : lua_CFunction; ud : Pointer):Integer;cdecl;
var  lua_cpcall:__lua_cpcall;
type __lua_load = function(L : Plua_State; reader : lua_Reader; dt : Pointer; const chunkname : PAnsiChar):Integer;cdecl;
var  lua_load:__lua_load;
type __lua_dump = function(L : Plua_State; writer : lua_Writer; data: Pointer):Integer;cdecl;
var  lua_dump:__lua_dump;
type __lua_yield = function(L : Plua_State; nresults : Integer):Integer;cdecl;
var  lua_yield:__lua_yield;
type __lua_resume = function(L : Plua_State; narg : Integer):Integer;cdecl;
var  lua_resume:__lua_resume;
type __lua_status = function(L : Plua_State):Integer;cdecl;
var  lua_status:__lua_status;
type __lua_gc = function(L : Plua_State; what, data : Integer):Integer;cdecl;
var  lua_gc:__lua_gc;
type __lua_error = function(L : Plua_State):Integer;cdecl;
var  lua_error:__lua_error;
type __lua_next = function(L : Plua_State; idx : Integer):Integer;cdecl;
var  lua_next:__lua_next;
type __lua_concat = procedure(L : Plua_State; n : Integer);cdecl;
var  lua_concat:__lua_concat;
type __lua_getallocf = function(L : Plua_State; ud : PPointer):lua_Alloc;cdecl;
var  lua_getallocf:__lua_getallocf;
type __lua_setallocf = procedure(L : Plua_State; f : lua_Alloc; ud : Pointer);cdecl;
var  lua_setallocf:__lua_setallocf;
type __luaopen_base = function(L : Plua_State):Integer;cdecl;
var  luaopen_base:__luaopen_base;
type __luaopen_table = function(L : Plua_State):Integer;cdecl;
var  luaopen_table:__luaopen_table;
type __luaopen_io = function(L : Plua_State):Integer;cdecl;
var  luaopen_io:__luaopen_io;
type __luaopen_os = function(L : Plua_State):Integer;cdecl;
var  luaopen_os:__luaopen_os;
type __luaopen_string = function(L : Plua_State):Integer;cdecl;
var  luaopen_string:__luaopen_string;
type __luaopen_math = function(L : Plua_State):Integer;cdecl;
var  luaopen_math:__luaopen_math;
type __luaopen_debug = function(L : Plua_State):Integer;cdecl;
var  luaopen_debug:__luaopen_debug;
type __luaopen_package = function(L : Plua_State):Integer;cdecl;
var  luaopen_package:__luaopen_package;
type __luaL_openlibs = procedure(L : Plua_State);cdecl;
var  luaL_openlibs:__luaL_openlibs;
type __lua_getstack = function(L : Plua_State; Level : Integer; AR : Plua_Debug):Integer;cdecl;
var  lua_getstack:__lua_getstack;
type __lua_getinfo = function(L : Plua_State; const what : PAnsiChar; AR : Plua_Debug):Integer;cdecl;
var  lua_getinfo:__lua_getinfo;
type __lua_getlocal = function(L : Plua_State; const AR : Plua_Debug; n : Integer):PAnsiChar;cdecl;
var  lua_getlocal:__lua_getlocal;
type __lua_setlocal = function(L : Plua_State; const AR : Plua_Debug; n : Integer):PAnsiChar;cdecl;
var  lua_setlocal:__lua_setlocal;
type __lua_getupvalue = function(L : Plua_State; funcindex, n : Integer):PAnsiChar;cdecl;
var  lua_getupvalue:__lua_getupvalue;
type __lua_setupvalue = function(L : Plua_State; funcindex, n : Integer):PAnsiChar;cdecl;
var  lua_setupvalue:__lua_setupvalue;
type __lua_sethook = function(L : Plua_State; func : lua_Hook; mask, count: Integer):Integer;cdecl;
var  lua_sethook:__lua_sethook;
type __lua_gethook = function(L : Plua_State):lua_Hook;cdecl;
var  lua_gethook:__lua_gethook;
type __lua_gethookmask = function(L : Plua_State):Integer;cdecl;
var  lua_gethookmask:__lua_gethookmask;
type __lua_gethookcount = function(L : Plua_State):Integer;cdecl;
var  lua_gethookcount:__lua_gethookcount;
type __luaL_openlib = procedure(L : Plua_State; const libname : PAnsiChar; const lr : PluaL_Reg; nup : Integer);cdecl;
var  luaL_openlib:__luaL_openlib;
type __luaL_register = procedure(L : Plua_State; const libname : PAnsiChar; const lr : PluaL_Reg);cdecl;
var  luaL_register:__luaL_register;
type __luaL_getmetafield = function(L : Plua_State; obj : Integer; const e : PAnsiChar):Integer;cdecl;
var  luaL_getmetafield:__luaL_getmetafield;
type __luaL_callmeta = function(L : Plua_State; obj : Integer; const e : PAnsiChar):Integer;cdecl;
var  luaL_callmeta:__luaL_callmeta;
type __luaL_typerror = function(L : Plua_State; narg : Integer; const tname : PAnsiChar):Integer;cdecl;
var  luaL_typerror:__luaL_typerror;
type __luaL_argerror = function(L : Plua_State; numarg : Integer; const extramsg : PAnsiChar):Integer;cdecl;
var  luaL_argerror:__luaL_argerror;
type __luaL_checklstring = function(L : Plua_State; numArg : Integer; ls : Psize_t):PAnsiChar;cdecl;
var  luaL_checklstring:__luaL_checklstring;
type __luaL_optlstring = function(L : Plua_State; numArg : Integer; const def: PAnsiChar; ls: Psize_t):PAnsiChar;cdecl;
var  luaL_optlstring:__luaL_optlstring;
type __luaL_checknumber = function(L : Plua_State; numArg : Integer):lua_Number;cdecl;
var  luaL_checknumber:__luaL_checknumber;
type __luaL_optnumber = function(L : Plua_State; nArg : Integer; def : lua_Number):lua_Number;cdecl;
var  luaL_optnumber:__luaL_optnumber;
type __luaL_checkinteger = function(L : Plua_State; numArg : Integer):lua_Integer;cdecl;
var  luaL_checkinteger:__luaL_checkinteger;
type __luaL_optinteger = function(L : Plua_State; nArg : Integer; def : lua_Integer):lua_Integer;cdecl;
var  luaL_optinteger:__luaL_optinteger;
type __luaL_checkstack = procedure(L : Plua_State; sz : Integer; const msg : PAnsiChar);cdecl;
var  luaL_checkstack:__luaL_checkstack;
type __luaL_checktype = procedure(L : Plua_State; narg, t : Integer);cdecl;
var  luaL_checktype:__luaL_checktype;
type __luaL_checkany = procedure(L : Plua_State; narg : Integer);cdecl;
var  luaL_checkany:__luaL_checkany;
type __luaL_newmetatable = function(L : Plua_State; const tname : PAnsiChar):Integer;cdecl;
var  luaL_newmetatable:__luaL_newmetatable;
type __luaL_checkudata = function(L : Plua_State; ud : Integer; const tname : PAnsiChar):Pointer;cdecl;
var  luaL_checkudata:__luaL_checkudata;
type __luaL_where = procedure(L : Plua_State; lvl : Integer);cdecl;
var  luaL_where:__luaL_where;
type __luaL_error = function(L : Plua_State; const fmt : PAnsiChar):Integer;cdecl;
var  luaL_error:__luaL_error;
type __luaL_checkoption = function(L : Plua_State; narg : Integer; const def : PAnsiChar; const lst : array of PAnsiChar):Integer;cdecl;
var  luaL_checkoption:__luaL_checkoption;
type __luaL_ref = function(L : Plua_State; t : Integer):Integer;cdecl;
var  luaL_ref:__luaL_ref;
type __luaL_unref = procedure(L : Plua_State; t, ref : Integer);cdecl;
var  luaL_unref:__luaL_unref;
type __luaL_loadfile = function(L : Plua_State; const filename : PAnsiChar):Integer;cdecl;
var  luaL_loadfile:__luaL_loadfile;
type __luaL_loadbuffer = function(L : Plua_State; const buff : PAnsiChar; sz : size_t; const name: PAnsiChar):Integer;cdecl;
var  luaL_loadbuffer:__luaL_loadbuffer;
type __luaL_loadstring = function(L : Plua_State; const s : PAnsiChar):Integer;cdecl;
var  luaL_loadstring:__luaL_loadstring;
type __luaL_newstate = function():Plua_State;cdecl;
var  luaL_newstate:__luaL_newstate;
type __luaL_gsub = function(L : Plua_State; const s, p, r : PAnsiChar):PAnsiChar;cdecl;
var  luaL_gsub:__luaL_gsub;
type __luaL_findtable = function(L : Plua_State; idx : Integer; const fname : PAnsiChar; szhint : Integer):PAnsiChar;cdecl;
var  luaL_findtable:__luaL_findtable;
type __luaL_buffinit = procedure(L : Plua_State; B : PluaL_Buffer);cdecl;
var  luaL_buffinit:__luaL_buffinit;
type __luaL_prepbuffer = function(B : PluaL_Buffer):PAnsiChar;cdecl;
var  luaL_prepbuffer:__luaL_prepbuffer;
type __luaL_addlstring = procedure(B : PluaL_Buffer; const s : PAnsiChar; ls : size_t);cdecl;
var  luaL_addlstring:__luaL_addlstring;
type __luaL_addstring = procedure(B : PluaL_Buffer; const s : PAnsiChar);cdecl;
var  luaL_addstring:__luaL_addstring;
type __luaL_addvalue = procedure(B : PluaL_Buffer);cdecl;
var  luaL_addvalue:__luaL_addvalue;
type __luaL_pushresult = procedure(B : PluaL_Buffer);cdecl;
var  luaL_pushresult:__luaL_pushresult;

function Lua_LoadLibrary(dllname: string): Boolean;

implementation

uses
  SysUtils, Windows;

function Lua_LoadLibrary(dllname: string): Boolean;
var
  h: THandle;
begin
  Result := False;
  h := LoadLibrary(PChar(dllname));
  if h = 0 then Exit;
  // LOAD ADDRESS
  lua_newstate := GetProcAddress(h, 'lua_newstate');
  lua_close := GetProcAddress(h, 'lua_close');
  lua_newthread := GetProcAddress(h, 'lua_newthread');
  lua_atpanic := GetProcAddress(h, 'lua_atpanic');
  lua_gettop := GetProcAddress(h, 'lua_gettop');
  lua_settop := GetProcAddress(h, 'lua_settop');
  lua_pushvalue := GetProcAddress(h, 'lua_pushvalue');
  lua_remove := GetProcAddress(h, 'lua_remove');
  lua_insert := GetProcAddress(h, 'lua_insert');
  lua_replace := GetProcAddress(h, 'lua_replace');
  lua_checkstack := GetProcAddress(h, 'lua_checkstack');
  lua_xmove := GetProcAddress(h, 'lua_xmove');
  lua_isnumber := GetProcAddress(h, 'lua_isnumber');
  lua_isstring := GetProcAddress(h, 'lua_isstring');
  lua_iscfunction := GetProcAddress(h, 'lua_iscfunction');
  lua_isuserdata := GetProcAddress(h, 'lua_isuserdata');
  lua_type := GetProcAddress(h, 'lua_type');
  lua_typename := GetProcAddress(h, 'lua_typename');
  lua_equal := GetProcAddress(h, 'lua_equal');
  lua_rawequal := GetProcAddress(h, 'lua_rawequal');
  lua_lessthan := GetProcAddress(h, 'lua_lessthan');
  lua_tonumber := GetProcAddress(h, 'lua_tonumber');
  lua_tointeger := GetProcAddress(h, 'lua_tointeger');
  lua_toboolean := GetProcAddress(h, 'lua_toboolean');
  lua_tolstring := GetProcAddress(h, 'lua_tolstring');
  lua_objlen := GetProcAddress(h, 'lua_objlen');
  lua_tocfunction := GetProcAddress(h, 'lua_tocfunction');
  lua_touserdata := GetProcAddress(h, 'lua_touserdata');
  lua_tothread := GetProcAddress(h, 'lua_tothread');
  lua_topointer := GetProcAddress(h, 'lua_topointer');
  lua_pushnil := GetProcAddress(h, 'lua_pushnil');
  lua_pushnumber := GetProcAddress(h, 'lua_pushnumber');
  lua_pushinteger := GetProcAddress(h, 'lua_pushinteger');
  lua_pushlstring := GetProcAddress(h, 'lua_pushlstring');
  lua_pushstring := GetProcAddress(h, 'lua_pushstring');
  lua_pushvfstring := GetProcAddress(h, 'lua_pushvfstring');
  lua_pushfstring := GetProcAddress(h, 'lua_pushfstring');
  lua_pushcclosure := GetProcAddress(h, 'lua_pushcclosure');
  lua_pushboolean := GetProcAddress(h, 'lua_pushboolean');
  lua_pushlightuserdata := GetProcAddress(h, 'lua_pushlightuserdata');
  lua_pushthread := GetProcAddress(h, 'lua_pushthread');
  lua_gettable := GetProcAddress(h, 'lua_gettable');
  lua_getfield := GetProcAddress(h, 'lua_getfield');
  lua_rawget := GetProcAddress(h, 'lua_rawget');
  lua_rawgeti := GetProcAddress(h, 'lua_rawgeti');
  lua_createtable := GetProcAddress(h, 'lua_createtable');
  lua_newuserdata := GetProcAddress(h, 'lua_newuserdata');
  lua_getmetatable := GetProcAddress(h, 'lua_getmetatable');
  lua_getfenv := GetProcAddress(h, 'lua_getfenv');
  lua_settable := GetProcAddress(h, 'lua_settable');
  lua_setfield := GetProcAddress(h, 'lua_setfield');
  lua_rawset := GetProcAddress(h, 'lua_rawset');
  lua_rawseti := GetProcAddress(h, 'lua_rawseti');
  lua_setmetatable := GetProcAddress(h, 'lua_setmetatable');
  lua_setfenv := GetProcAddress(h, 'lua_setfenv');
  lua_call := GetProcAddress(h, 'lua_call');
  lua_pcall := GetProcAddress(h, 'lua_pcall');
  lua_cpcall := GetProcAddress(h, 'lua_cpcall');
  lua_load := GetProcAddress(h, 'lua_load');
  lua_dump := GetProcAddress(h, 'lua_dump');
  lua_yield := GetProcAddress(h, 'lua_yield');
  lua_resume := GetProcAddress(h, 'lua_resume');
  lua_status := GetProcAddress(h, 'lua_status');
  lua_gc := GetProcAddress(h, 'lua_gc');
  lua_error := GetProcAddress(h, 'lua_error');
  lua_next := GetProcAddress(h, 'lua_next');
  lua_concat := GetProcAddress(h, 'lua_concat');
  lua_getallocf := GetProcAddress(h, 'lua_getallocf');
  lua_setallocf := GetProcAddress(h, 'lua_setallocf');
  luaopen_base := GetProcAddress(h, 'luaopen_base');
  luaopen_table := GetProcAddress(h, 'luaopen_table');
  luaopen_io := GetProcAddress(h, 'luaopen_io');
  luaopen_os := GetProcAddress(h, 'luaopen_os');
  luaopen_string := GetProcAddress(h, 'luaopen_string');
  luaopen_math := GetProcAddress(h, 'luaopen_math');
  luaopen_debug := GetProcAddress(h, 'luaopen_debug');
  luaopen_package := GetProcAddress(h, 'luaopen_package');
  luaL_openlibs := GetProcAddress(h, 'luaL_openlibs');
  lua_getstack := GetProcAddress(h, 'lua_getstack');
  lua_getinfo := GetProcAddress(h, 'lua_getinfo');
  lua_getlocal := GetProcAddress(h, 'lua_getlocal');
  lua_setlocal := GetProcAddress(h, 'lua_setlocal');
  lua_getupvalue := GetProcAddress(h, 'lua_getupvalue');
  lua_setupvalue := GetProcAddress(h, 'lua_setupvalue');
  lua_sethook := GetProcAddress(h, 'lua_sethook');
  lua_gethook := GetProcAddress(h, 'lua_gethook');
  lua_gethookmask := GetProcAddress(h, 'lua_gethookmask');
  lua_gethookcount := GetProcAddress(h, 'lua_gethookcount');
  luaL_openlib := GetProcAddress(h, 'luaL_openlib');
  luaL_register := GetProcAddress(h, 'luaL_register');
  luaL_getmetafield := GetProcAddress(h, 'luaL_getmetafield');
  luaL_callmeta := GetProcAddress(h, 'luaL_callmeta');
  luaL_typerror := GetProcAddress(h, 'luaL_typerror');
  luaL_argerror := GetProcAddress(h, 'luaL_argerror');
  luaL_checklstring := GetProcAddress(h, 'luaL_checklstring');
  luaL_optlstring := GetProcAddress(h, 'luaL_optlstring');
  luaL_checknumber := GetProcAddress(h, 'luaL_checknumber');
  luaL_optnumber := GetProcAddress(h, 'luaL_optnumber');
  luaL_checkinteger := GetProcAddress(h, 'luaL_checkinteger');
  luaL_optinteger := GetProcAddress(h, 'luaL_optinteger');
  luaL_checkstack := GetProcAddress(h, 'luaL_checkstack');
  luaL_checktype := GetProcAddress(h, 'luaL_checktype');
  luaL_checkany := GetProcAddress(h, 'luaL_checkany');
  luaL_newmetatable := GetProcAddress(h, 'luaL_newmetatable');
  luaL_checkudata := GetProcAddress(h, 'luaL_checkudata');
  luaL_where := GetProcAddress(h, 'luaL_where');
  luaL_error := GetProcAddress(h, 'luaL_error');
  luaL_checkoption := GetProcAddress(h, 'luaL_checkoption');
  luaL_ref := GetProcAddress(h, 'luaL_ref');
  luaL_unref := GetProcAddress(h, 'luaL_unref');
  luaL_loadfile := GetProcAddress(h, 'luaL_loadfile');
  luaL_loadbuffer := GetProcAddress(h, 'luaL_loadbuffer');
  luaL_loadstring := GetProcAddress(h, 'luaL_loadstring');
  luaL_newstate := GetProcAddress(h, 'luaL_newstate');
  luaL_gsub := GetProcAddress(h, 'luaL_gsub');
  luaL_findtable := GetProcAddress(h, 'luaL_findtable');
  luaL_buffinit := GetProcAddress(h, 'luaL_buffinit');
  luaL_prepbuffer := GetProcAddress(h, 'luaL_prepbuffer');
  luaL_addlstring := GetProcAddress(h, 'luaL_addlstring');
  luaL_addstring := GetProcAddress(h, 'luaL_addstring');
  luaL_addvalue := GetProcAddress(h, 'luaL_addvalue');
  luaL_pushresult := GetProcAddress(h, 'luaL_pushresult');
  //
  Result := True;
end;

(*****************************************************************************)
(*                            luaconfig.h                                    *)
(*****************************************************************************)

function  lua_readline(L : Plua_State; var b : PAnsiChar; p : PAnsiChar): Boolean;
var
  s : AnsiString;
begin
  Write(p);                        // show prompt
  ReadLn(s);                       // get line
  b := PAnsiChar(s);                   //   and return it
  result := (b[0] <> #4);          // test for ctrl-D
end;

procedure lua_saveline(L : Plua_State; idx : Integer);
begin
end;

procedure lua_freeline(L : Plua_State; b : PAnsiChar);
begin
end;


(*****************************************************************************)
(*                                  lua.h                                    *)
(*****************************************************************************)

function lua_upvalueindex(idx : Integer) : Integer;
begin
  result := LUA_GLOBALSINDEX - idx;
end;

procedure lua_pop(L : Plua_State; n : Integer);
begin
  lua_settop(L, -n - 1);
end;

procedure lua_newtable(L : Plua_State);
begin
  lua_createtable(L, 0, 0);
end;

procedure lua_register(L : Plua_State; n : PAnsiChar; f : lua_CFunction);
begin
  lua_pushcfunction(L, f);
  lua_setglobal(L, n);
end;

procedure lua_pushcfunction(L : Plua_State; f : lua_CFunction);
begin
  lua_pushcclosure(L, f, 0);
end;

function  lua_strlen(L : Plua_State; idx : Integer) : Integer;
begin
  result := lua_objlen(L, idx);
end;

function lua_isfunction(L : Plua_State; n : Integer) : Boolean;
begin
  result := lua_type(L, n) = LUA_TFUNCTION;
end;

function lua_istable(L : Plua_State; n : Integer) : Boolean;
begin
  result := lua_type(L, n) = LUA_TTABLE;
end;

function lua_islightuserdata(L : Plua_State; n : Integer) : Boolean;
begin
  result := lua_type(L, n) = LUA_TLIGHTUSERDATA;
end;

function lua_isnil(L : Plua_State; n : Integer) : Boolean;
begin
  result := lua_type(L, n) = LUA_TNIL;
end;

function lua_isboolean(L : Plua_State; n : Integer) : Boolean;
begin
  result := lua_type(L, n) = LUA_TBOOLEAN;
end;

function lua_isthread(L : Plua_State; n : Integer) : Boolean;
begin
  result := lua_type(L, n) = LUA_TTHREAD;
end;

function lua_isnone(L : Plua_State; n : Integer) : Boolean;
begin
  result := lua_type(L, n) = LUA_TNONE;
end;

function lua_isnoneornil(L : Plua_State; n : Integer) : Boolean;
begin
  result := lua_type(L, n) <= 0;
end;

procedure lua_pushliteral(L : Plua_State; s : PAnsiChar);
begin
  lua_pushlstring(L, s, StrLen(s));
end;

procedure lua_setglobal(L : Plua_State; s : PAnsiChar);
begin
  lua_setfield(L, LUA_GLOBALSINDEX, s);
end;

procedure lua_getglobal(L: Plua_State; s: PAnsiChar);
begin
  lua_getfield(L, LUA_GLOBALSINDEX, s);
end;

function lua_tostring(L : Plua_State; idx : Integer) : PAnsiChar;
begin
  result := lua_tolstring(L, idx, nil);
end;

function lua_open : Plua_State;
begin
  result := luaL_newstate;
end;

procedure lua_getregistry(L : Plua_State);
begin
  lua_pushvalue(L, LUA_REGISTRYINDEX);
end;

function lua_getgccount(L : Plua_State) : Integer;
begin
  result := lua_gc(L, LUA_GCCOUNT, 0);
end;


(*****************************************************************************)
(*                                  lualib.h                                 *)
(*****************************************************************************)

procedure lua_assert(x : Boolean);
begin
end;


(*****************************************************************************)
(*                                  lauxlib.h    n                           *)
(*****************************************************************************)

function luaL_getn(L : Plua_State; idx : Integer) : Integer;
begin
  result := lua_objlen(L, idx);
end;

procedure luaL_setn(L : plua_State; i, j : Integer);
begin
  (* no op *)
end;

function luaL_argcheck(L : Plua_State; cond : Boolean; numarg : Integer;
                       extramsg : PAnsiChar): Integer;
begin
  if not cond then
    result := luaL_argerror(L, numarg, extramsg)
  else
    result := 0;
end;

function luaL_checkstring(L : Plua_State; n : Integer) : PAnsiChar;
begin
  result := luaL_checklstring(L, n, nil);
end;

function luaL_optstring(L : Plua_State; n : Integer; d : PAnsiChar) : PAnsiChar;
begin
  result := luaL_optlstring(L, n, d, nil);
end;

function luaL_checkint(L : Plua_State; n : Integer) : Integer;
begin
  result := luaL_checkinteger(L, n);
end;

function luaL_optint(L : Plua_State; n, d : Integer): Integer;
begin
  result := luaL_optinteger(L, n, d);
end;

function luaL_checklong(L : Plua_State; n : LongInt) : LongInt;
begin
  result := luaL_checkinteger(L, n);
end;

function luaL_optlong(L : Plua_State; n : Integer; d : LongInt) : LongInt;
begin
  result := luaL_optinteger(L, n, d);
end;

function luaL_typename(L : Plua_State; idx : Integer) : PAnsiChar;
begin
  result := lua_typename( L, lua_type(L, idx) );
end;

function luaL_dofile(L : Plua_State; fn : PAnsiChar) : Integer;
begin
  result := luaL_loadfile(L, fn);
  if result = 0 then
    result := lua_pcall(L, 0, 0, 0);
end;

function luaL_dostring(L : Plua_State; s : PAnsiChar) : Integer;
begin
  result := luaL_loadstring(L, s);
  if result = 0 then
    result := lua_pcall(L, 0, 0, 0);
end;

procedure luaL_getmetatable(L : Plua_State; n : PAnsiChar);
begin
  lua_getfield(L, LUA_REGISTRYINDEX, n);
end;

procedure luaL_addchar(B : PluaL_Buffer; c : AnsiChar);
begin
  if not(B^.p < B^.buffer + LUAL_BUFFERSIZE) then
    luaL_prepbuffer(B);
  B^.p^ := c;
  Inc(B^.p);
end;

procedure luaL_putchar(B : PluaL_Buffer; c : AnsiChar);
begin
  luaL_addchar(B, c);
end;

procedure luaL_addsize(B : PluaL_Buffer; n : Integer);
begin
  Inc(B^.p, n);
end;

function lua_ref(L : Plua_State; lock : Boolean) : Integer;
begin
  if lock then
    result := luaL_ref(L, LUA_REGISTRYINDEX)
  else begin
    lua_pushstring(L, 'unlocked references are obsolete');
    lua_error(L);
    result := 0;
  end;
end;

procedure lua_unref(L : Plua_State; ref : Integer);
begin
  luaL_unref(L, LUA_REGISTRYINDEX, ref);
end;

procedure lua_getref(L : Plua_State; ref : Integer);
begin
  lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
end;


(******************************************************************************
* Original copyright for the lua source and headers:
*  1994-2004 Tecgraf, PUC-Rio.
*  www.lua.org.
*
*
* Permission is hereby granted, free of charge, to any person obtaining
* a copy of this software and associated documentation files (the
* "Software"), to deal in the Software without restriction, including
* without limitation the rights to use, copy, modify, merge, publish,
* distribute, sublicense, and/or sell copies of the Software, and to
* permit persons to whom the Software is furnished to do so, subject to
* the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
******************************************************************************)

end.

