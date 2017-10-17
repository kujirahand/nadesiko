unit unit_sqlite;

interface

uses
  Windows, SysUtils, Forms, Dialogs;

type
  TSqliteHandle = pointer;
  PString = ^String;


procedure SqliteInit(dllfile: string = '');
function SqliteOpen(dbname: string; mode: Integer = 0): TSqliteHandle;
procedure SqliteClose(handle: TSqliteHandle);
procedure SqliteExecute(handle: TSqliteHandle; SQL: string; var Res: string);
function SqliteLastInsertRowId(handle: TSqliteHandle): Integer;
function sqlite_escape_string(s:string): string;

var sqlite_encode:string = '';

implementation

uses StrUnit, unit_string, nkf, dnako_import;

const
  DLL_SQLITE = 'sqlite.dll';

var
  sqlite_dll_handle:THandle = 0;
  sqlite_open : function(dbname: PChar; mode: Integer; var ErrMsg: PChar): Pointer; cdecl;
  sqlite_close : procedure (db: Pointer); cdecl;
  sqlite_exec :function(db: Pointer; SQLStatement: PChar; CallbackPtr: Pointer; Sender: TObject; var ErrMsg: PChar): integer; cdecl;
  sqlite_last_insert_rowid : function(db:Pointer):Integer; cdecl;

function NkfConvertStr(ins, option: string; IsUTF16:Boolean) : string;
begin
  // レポートの作成
  nako_reportDLL(PChar(nkf.path_nkf32_dll));
  Result := nkf.NkfConvertStr(ins, option, IsUTF16);
end;

function sqlite_escape_string(s:string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(s) do
  begin
    if s[i] = '''' then
    begin
      Result := Result + '''''';
    end else
    begin
      Result := Result + s[i];
    end;
  end;
end;

function ExecCallback(Sender: TObject; Columns: Integer; ColumnValues: Pointer; ColumnNames: Pointer): integer; cdecl;
var
  i : integer;
  Name : ^PChar;
  Value : ^PChar;
  res: PString;
  s: string;
begin
  Name := ColumnNames;
  Value := ColumnValues;
  res := PString(Sender);
  if res^ = '' then
  begin
    // フィールドの名前を得る
    for i := 0 to Columns - 1 do
    begin
      res^ := res^ + Name^ + ',';
      inc(Name);
    end;
    if Columns > 0 then
    begin
      System.Delete(res^, Length(res^), 1);
      res^ := res^ + #13#10;
    end;
  end;

  for i := 0 to Columns - 1 do
  begin
    s := Value^;
    if sqlite_encode <> '' then
    begin
      s := NkfConvertStr(s, '--oc=' + nkf_easy_code(sqlite_encode), False);
    end;
    if (Pos(' ', s) > 0)or(Pos(',', s) > 0)or(Pos('"', s) >0)or(Pos(#13, s) > 0)or(Pos(#10, s) > 0) then
    begin
      s := JReplace(s, '"', '""');
      s := '"' + s + '"';
    end;
    res^ := res^ + s +  ',';
    inc(Value);
  end;
  if Columns > 0 then
  begin
    System.Delete(res^, Length(res^), 1);
    res^ := res^ + #13#10;
  end;

  result := 0;
end;

function SqliteOpen(dbname: string; mode: Integer = 0): TSqliteHandle;
var
  msg: PChar;
begin
  SqliteInit;
  if @sqlite_open = nil then
  begin
    raise Exception.Create(DLL_SQLITE+'がありません');
  end;
  Result := sqlite_open(PChar(dbname), mode, msg);
end;

procedure SqliteClose(handle: TSqliteHandle);
begin
  sqlite_close(handle);
end;

procedure SqliteExecute(handle: TSqliteHandle; SQL: string; var Res: string);
var
  msg: PChar;
begin
  sqlite_exec(handle, PChar(SQL), @ExecCallback, @Res, msg);
  if msg <> nil then raise Exception.Create(msg);
end;

function SqliteLastInsertRowId(handle: TSqliteHandle): Integer;
begin
  Result := sqlite_last_insert_rowid(handle);
end;

procedure SqliteInit(dllfile: string = '');
var
  dll: string;
begin
  if sqlite_dll_handle = 0 then
  begin
    if dllfile = '' then
    begin
      dll := 'plug-ins\' + DLL_SQLITE;
      sqlite_dll_handle := LoadLibrary('plug-ins\' + DLL_SQLITE);
      if sqlite_dll_handle = 0 then
      begin
        sqlite_dll_handle := LoadLibrary(DLL_SQLITE);
      end;
    end else
    begin
      sqlite_dll_handle := LoadLibrary(PChar(dllfile));
    end;
    if sqlite_dll_handle = 0 then
    begin
      raise Exception.Create(DLL_SQLITE + 'が見当たりません。インストールしてください。');
    end;
    sqlite_open  := GetProcAddress(sqlite_dll_handle,'sqlite_open');
    sqlite_close := GetProcAddress(sqlite_dll_handle,'sqlite_close');
    sqlite_exec  := GetProcAddress(sqlite_dll_handle,'sqlite_exec');
    sqlite_last_insert_rowid := GetProcAddress(sqlite_dll_handle,'sqlite_last_insert_rowid');
  end;
end;

initialization

finalization
  FreeLibrary(sqlite_dll_handle);

end.

