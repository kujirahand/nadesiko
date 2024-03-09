unit kuLuaUtils;

interface
uses
  SysUtils, Classes, Lua;

type
  TKuLua = class
  protected
    FHandle: PLua_state;
  public
    ErrorString: string;
    //
    constructor Create;
    destructor Destroy; override;
    procedure Open;
    procedure Close;
    procedure OpenLibs;
    procedure DoFile(path: string);
    procedure DoString(source: string);
    procedure DoStringFmt(Source: string; const Args:array of const);
    procedure SetVarStr(const varname, value: string);
    function GetVarStr(const varname: string): string;
    function GetErrorInfo: string;
    property Handle: PLua_state read FHandle;
    function GetString(Index: Integer): string;
    function QuoteStr(str: string): string;
  end;

// Wrap Function
function KLuaGetErrorFromCode(ErrorCode: Integer): string;
function KLuaLoadFile(L: Plua_State; Filename: string): Integer;
function KLuaGetPCallError(L: Plua_State): AnsiString;

function KLua: TKuLua;

implementation

var _kulua: TKuLua = nil;


function LuaToAnsiString(L: PLua_State; Index: Integer): AnsiString;
var
  Size: Integer;
begin
  Size := lua_strlen(L, Index);
  SetLength(Result, Size);
  if (Size > 0) then
    Move(lua_tostring(L, Index)^, Result[1], Size);
end;

procedure KLuaOnLuaStdoutEx(F, S: PAnsiChar; L, N: Integer);
begin
  if L > 0 then
  begin
    KLua.ErrorString := KLua.ErrorString + string(AnsiString(F)) + #13#10;
  end;
  if N > 0 then
  begin
    KLua.ErrorString := KLua.ErrorString + string(AnsiString(S)) + #13#10;
  end;
end;

function KLua: TKuLua;
begin
  if _kulua = nil then
  begin
    _kulua := TKuLua.Create;
    //LuaUtils.OnLuaStdoutEx := KLuaOnLuaStdoutEx;
  end;
  Result := _kulua;
end;

function KLuaGetPCallError(L: Plua_State): AnsiString;
var
  p: PAnsiChar;
begin
  p := lua_tostring(L, -1);
  Result := AnsiString(p);
  //lua_printex(L);
  Result := Result + KLua.ErrorString;
  KLua.ErrorString := '';
end;

function KLuaLoadFile(L: Plua_State; Filename: string): Integer;
var
  path: AnsiString;
begin
  // íçà”: ÉtÉ@ÉCÉãñºÇ»ÇÃÇ≈ UTF8Encode ÇµÇƒÇÕÇ»ÇÁÇ»Ç¢
  path := AnsiString(Filename);
  Result := luaL_loadfile(L, PAnsiChar(path));
end;

function KLuaGetErrorFromCode(ErrorCode: Integer): string;
begin
  case ErrorCode of
    LUA_ERRRUN:     Result := 'Run Error';
    LUA_ERRSYNTAX:  Result := 'Syntax Error';
    LUA_ERRMEM:     Result := 'Memory Error';
    LUA_ERRFILE:    Result := 'File IO Error';
    LUA_ERRERR:     Result := 'Error';
  else
    Result := 'Error';
  end;
end;

{ TKuLua }

procedure TKuLua.Close;
begin
  if FHandle <> nil then
  begin
    lua_close(FHandle);
    FHandle := nil;
  end;
end;

constructor TKuLua.Create;
begin
  FHandle := nil;
  Open;
end;

destructor TKuLua.Destroy;
begin
  Close;
  inherited;
end;

procedure TKuLua.DoFile(path: string);
var
  patha: AnsiString;
  res: Integer;
begin
  patha := AnsiString(path);
  res := luaL_dofile(Handle, PAnsiChar(patha));
  if res <> 0 then
  begin
    raise Exception.Create(GetErrorInfo);
  end;
end;

procedure TKuLua.DoString(source: string);
var
  source_a: UTF8String;
  res: Integer;
begin
  {$IF RTLVersion > 20.0}
  source_a := UTF8Encode(source);
  {$ELSE}
  source_a := source;
  {$IFEND}
  res := luaL_dostring(Handle, PAnsiChar(source_a));
  if res <> 0 then
  begin
    raise Exception.Create(GetErrorInfo);
  end;
end;

procedure TKuLua.DoStringFmt(Source: string; const Args: array of const);
begin
  DoString(Format(Source, Args));
end;

function TKuLua.GetErrorInfo: string;
begin
  {$IF RTLVersion > 20.0}
  Result := UTF8ToString(KLuaGetPCallError(Handle));
  {$ELSE}
  Result := KLuaGetPCallError(Handle);
  {$IFEND}
end;

function TKuLua.GetString(Index: Integer): string;
var
  v: AnsiString;
begin
  v := LuaToAnsiString(Handle, Index);
  {$IF RTLVersion > 20}
  Result := UTF8ToString(v);
  {$ELSE}
  Result := v;
  {$IFEND}
end;

function TKuLua.GetVarStr(const varname: string): string;
var
  var_u: UTF8String;
begin
  var_u := UTF8Encode(varname);
  lua_getglobal(Handle, PAnsiChar(var_u));
  Result := GetString(-1);
  lua_pop(Handle, 1);
end;

procedure TKuLua.Open;
begin
  if FHandle = nil then
  begin
    FHandle := luaL_newstate;
  end;
end;

procedure TKuLua.OpenLibs;
begin
  luaL_openlibs(FHandle);
end;

function TKuLua.QuoteStr(str: string): string;
begin
  str := StringReplace(str, '\', '\\', [rfReplaceAll]);
  Result := '"' + str + '"';
end;

procedure TKuLua.SetVarStr(const varname, value: string);
var
  var_u: UTF8String;
  val_u: UTF8String;
begin
  var_u := UTF8Encode(varname);
  val_u := UTF8Encode(value);
  lua_pushstring(Handle, PAnsiChar(val_u));
  lua_setglobal(Handle, PAnsiChar(var_u));

end;

initialization

finalization
  begin
    FreeAndNil(_kulua);
  end;

end.
