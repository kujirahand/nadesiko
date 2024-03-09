unit unit_sqlite3;

interface

uses
  Windows, SysUtils;

const
  SQLite3DLL = 'sqlite3.dll';

// Return values for sqlite3_exec() and sqlite3_step()

  SQLITE_OK = 0; // Successful result
  SQLITE_ERROR = 1; // SQL error or missing database
  SQLITE_INTERNAL = 2; // An internal logic error in SQLite
  SQLITE_PERM = 3; // Access permission denied
  SQLITE_ABORT = 4; // Callback routine requested an abort
  SQLITE_BUSY = 5; // The database file is locked
  SQLITE_LOCKED = 6; // A table in the database is locked
  SQLITE_NOMEM = 7; // A malloc() failed
  SQLITE_READONLY = 8; // Attempt to write a readonly database
  SQLITE_INTERRUPT = 9; // Operation terminated by sqlite3_interrupt()
  SQLITE_IOERR = 10; // Some kind of disk I/O error occurred
  SQLITE_CORRUPT = 11; // The database disk image is malformed
  SQLITE_NOTFOUND = 12; // (Internal Only) Table or record not found
  SQLITE_FULL = 13; // Insertion failed because database is full
  SQLITE_CANTOPEN = 14; // Unable to open the database file
  SQLITE_PROTOCOL = 15; // Database lock protocol error
  SQLITE_EMPTY = 16; // Database is empty
  SQLITE_SCHEMA = 17; // The database schema changed
  SQLITE_TOOBIG = 18; // Too much data for one row of a table
  SQLITE_CONSTRAINT = 19; // Abort due to contraint violation
  SQLITE_MISMATCH = 20; // Data type mismatch
  SQLITE_MISUSE = 21; // Library used incorrectly
  SQLITE_NOLFS = 22; // Uses OS features not supported on host
  SQLITE_AUTH = 23; // Authorization denied
  SQLITE_FORMAT = 24; // Auxiliary database format error
  SQLITE_RANGE = 25; // 2nd parameter to sqlite3_bind out of range
  SQLITE_NOTADB = 26; // File opened that is not a database file
  SQLITE_ROW = 100; // sqlite3_step() has another row ready
  SQLITE_DONE = 101; // sqlite3_step() has finished executing

  SQLITE_INTEGER = 1;
  SQLITE_FLOAT = 2;
  SQLITE_TEXT = 3;
  SQLITE_BLOB = 4;
  SQLITE_NULL = 5;

  SQLITE_UTF8     = 1;
  SQLITE_UTF16    = 2;
  SQLITE_UTF16BE  = 3;
  SQLITE_UTF16LE  = 4;
  SQLITE_ANY      = 5;

  SQLITE_TRANSIENT = pointer(-1);
  SQLITE_STATIC = pointer(0);

type
  TSQLite3DB = Pointer;
  TSQLiteResult = ^PChar;
  TSQLiteStmt = Pointer;

  //function prototype for define own collate
  TCollateXCompare = function(Userdta: pointer; Buf1Len: integer; Buf1: pointer;
    Buf2Len: integer; Buf2: pointer): integer; cdecl;

var
//
  SQLite3_Open: function (dbname: PChar; var db: TSQLite3DB) : integer; cdecl; 
  SQLite3_Close: function (db: TSQLite3DB) : integer; cdecl; 
  SQLite3_Exec: function (db: TSQLite3DB; SQLStatement: PChar; CallbackPtr: Pointer; Sender: TObject; var ErrMsg: PChar) : integer; cdecl;
  SQLite3_Version: function () : PChar; cdecl; 
  SQLite3_ErrMsg: function (db: TSQLite3DB) : PChar; cdecl; 
  SQLite3_ErrCode: function (db: TSQLite3DB) : integer; cdecl; 
  SQlite3_Free: procedure (P: PChar) ; cdecl; 
  SQLite3_GetTable: function (db: TSQLite3DB; SQLStatement: PChar; var ResultPtr: TSQLiteResult; var RowCount: Cardinal; var ColCount: Cardinal; var ErrMsg: PChar) : integer; cdecl; 
  SQLite3_FreeTable: procedure (Table: TSQLiteResult) ; cdecl; 
  SQLite3_Complete: function (P: PChar) : boolean; cdecl; 
  SQLite3_LastInsertRowID: function (db: TSQLite3DB) : int64; cdecl; 
  SQLite3_Interrupt: procedure (db: TSQLite3DB) ; cdecl; 
  SQLite3_BusyHandler: procedure (db: TSQLite3DB; CallbackPtr: Pointer; Sender: TObject) ; cdecl; 
  SQLite3_BusyTimeout: procedure (db: TSQLite3DB; TimeOut: integer) ; cdecl; 
  SQLite3_Changes: function (db: TSQLite3DB) : integer; cdecl; 
  SQLite3_TotalChanges: function (db: TSQLite3DB) : integer; cdecl; 
  SQLite3_Prepare: function (db: TSQLite3DB; SQLStatement: PChar; nBytes: integer; var hStmt: TSqliteStmt; var pzTail: PChar) : integer; cdecl; 
  SQLite3_Prepare_v2: function (db: TSQLite3DB; SQLStatement: PChar; nBytes: integer; var hStmt: TSqliteStmt; var pzTail: PChar) : integer; cdecl; 
  SQLite3_ColumnCount: function (hStmt: TSqliteStmt) : integer; cdecl; 
  Sqlite3_ColumnName: function (hStmt: TSqliteStmt; ColNum: integer) : pchar; cdecl; 
  Sqlite3_ColumnDeclType: function (hStmt: TSqliteStmt; ColNum: integer) : pchar; cdecl; 
  Sqlite3_Step: function (hStmt: TSqliteStmt) : integer; cdecl; 
  SQLite3_DataCount: function (hStmt: TSqliteStmt) : integer; cdecl; 
  Sqlite3_ColumnBlob: function (hStmt: TSqliteStmt; ColNum: integer) : pointer; cdecl; 
  Sqlite3_ColumnBytes: function (hStmt: TSqliteStmt; ColNum: integer) : integer; cdecl; 
  Sqlite3_ColumnDouble: function (hStmt: TSqliteStmt; ColNum: integer) : double; cdecl; 
  Sqlite3_ColumnInt: function (hStmt: TSqliteStmt; ColNum: integer) : integer; cdecl; 
  Sqlite3_ColumnText: function (hStmt: TSqliteStmt; ColNum: integer) : pchar; cdecl; 
  Sqlite3_ColumnType: function (hStmt: TSqliteStmt; ColNum: integer) : integer; cdecl; 
  Sqlite3_ColumnInt64: function (hStmt: TSqliteStmt; ColNum: integer) : Int64; cdecl; 
  SQLite3_Finalize: function (hStmt: TSqliteStmt) : integer; cdecl; 
  SQLite3_Reset: function (hStmt: TSqliteStmt) : integer; cdecl; 
  SQLite3_Bind_Blob: function (hStmt: TSqliteStmt; ParamNum: integer; ptrData: pointer; numBytes: integer; ptrDestructor: pointer) : integer; cdecl; 
  SQLite3_Bind_Double: function (hStmt: TSqliteStmt; ParamNum: integer; Data: Double) : integer; cdecl; 
  SQLite3_BindInt: function (hStmt: TSqLiteStmt; ParamNum: integer; intData: integer) : integer; cdecl; 
  SQLite3_Bind_int64: function (hStmt: TSqliteStmt; ParamNum: integer; Data: int64) : integer; cdecl; 
  SQLite3_Bind_null: function (hStmt: TSqliteStmt; ParamNum: integer) : integer; cdecl; 
  SQLite3_Bind_text: function (hStmt: TSqliteStmt; ParamNum: integer; Data: PChar; numBytes: integer; ptrDestructor: pointer) : integer; cdecl; 
  SQLite3_Bind_Parameter_Index: function (hStmt: TSqliteStmt; zName: PChar) : integer; cdecl; 
  sqlite3_enable_shared_cache: function (value: integer) : integer; cdecl; 
  sqlite3_create_collation: function (db: TSQLite3DB; Name: Pchar; eTextRep: integer; UserData: pointer; xCompare: TCollateXCompare) : integer; cdecl;

//
function sqlite3_loaded: Boolean;
function sqlite3_init(dllpath: string): THandle;

function SQLiteFieldType(SQLiteFieldTypeCode: Integer): AnsiString;
function SQLiteErrorStr(SQLiteErrorCode: Integer): AnsiString;
function SQLite3ExecCSV(h:TSQLite3DB; sql: string): string;

var
  sqlite_encode: string = '';

implementation

uses nkf, unit_string2;

var
  _sqlite3_dll: THandle = 0;

function sqlite3_loaded: Boolean;
begin
  Result := (_sqlite3_dll <> 0);
end;

function sqlite3_init(dllpath: string): THandle;

  function _addr(name: string):Pointer;
  begin
    Result := GetProcAddress(_sqlite3_dll, PChar(name));
  end;

begin
  // check loaded ?
  Result := 0;
  if _sqlite3_dll <> 0 then begin
    Result := _sqlite3_dll; Exit;
  end;
  // load dll
  _sqlite3_dll := LoadLibrary(PChar(dllpath));
  if _sqlite3_dll = 0 then Exit;

  // set address
  SQLite3_Open := _addr('sqlite3_open');
  SQLite3_Close := _addr('sqlite3_close');
  SQLite3_Exec := _addr('sqlite3_exec');
  SQLite3_Version := _addr('sqlite3_libversion');
  SQLite3_ErrMsg := _addr('sqlite3_errmsg');
  SQLite3_ErrCode := _addr('sqlite3_errcode');
  SQlite3_Free := _addr('sqlite3_free');
  SQLite3_GetTable := _addr('sqlite3_get_table');
  SQLite3_FreeTable := _addr('sqlite3_free_table');
  SQLite3_Complete := _addr('sqlite3_complete');
  SQLite3_LastInsertRowID := _addr('sqlite3_last_insert_rowid');
  SQLite3_Interrupt := _addr('sqlite3_interrupt');
  SQLite3_BusyHandler := _addr('sqlite3_busy_handler');
  SQLite3_BusyTimeout := _addr('sqlite3_busy_timeout');
  SQLite3_Changes := _addr('sqlite3_changes');
  SQLite3_TotalChanges := _addr('sqlite3_total_changes');
  SQLite3_Prepare := _addr('sqlite3_prepare');
  SQLite3_Prepare_v2 := _addr('sqlite3_prepare_v2');
  SQLite3_ColumnCount := _addr('sqlite3_column_count');
  Sqlite3_ColumnName := _addr('sqlite3_column_name');
  Sqlite3_ColumnDeclType := _addr('sqlite3_column_decltype');
  Sqlite3_Step := _addr('sqlite3_step');
  SQLite3_DataCount := _addr('sqlite3_data_count');
  Sqlite3_ColumnBlob := _addr('sqlite3_column_blob');
  Sqlite3_ColumnBytes := _addr('sqlite3_column_bytes');
  Sqlite3_ColumnDouble := _addr('sqlite3_column_double');
  Sqlite3_ColumnInt := _addr('sqlite3_column_int');
  Sqlite3_ColumnText := _addr('sqlite3_column_text');
  Sqlite3_ColumnType := _addr('sqlite3_column_type');
  Sqlite3_ColumnInt64 := _addr('sqlite3_column_int64');
  SQLite3_Finalize := _addr('sqlite3_finalize');
  SQLite3_Reset := _addr('sqlite3_reset');
  SQLite3_Bind_Blob := _addr('sqlite3_bind_blob');
  SQLite3_Bind_Double := _addr('sqlite3_bind_double');
  SQLite3_BindInt := _addr('sqlite3.dll');
  SQLite3_Bind_int64 := _addr('sqlite3_bind_int64');
  SQLite3_Bind_null := _addr('sqlite3_bind_null');
  SQLite3_Bind_text := _addr('sqlite3_bind_text');
  SQLite3_Bind_Parameter_Index := _addr('sqlite3_bind_parameter_index');
  sqlite3_enable_shared_cache := _addr('sqlite3_enable_shared_cache');
  sqlite3_create_collation := _addr('sqlite3_create_collation');
end;

function SQLiteFieldType(SQLiteFieldTypeCode: Integer): AnsiString;
begin
  case SQLiteFieldTypeCode of
    SQLITE_INTEGER: Result := 'Integer';
    SQLITE_FLOAT: Result := 'Float';
    SQLITE_TEXT: Result := 'Text';
    SQLITE_BLOB: Result := 'Blob';
    SQLITE_NULL: Result := 'Null';
  else
    Result := 'Unknown SQLite Field Type Code "' + IntToStr(SQLiteFieldTypeCode) + '"';
  end;
end;

function SQLiteErrorStr(SQLiteErrorCode: Integer): AnsiString;
begin
  case SQLiteErrorCode of
    SQLITE_OK: Result := 'Successful result';
    SQLITE_ERROR: Result := 'SQL error or missing database';
    SQLITE_INTERNAL: Result := 'An internal logic error in SQLite';
    SQLITE_PERM: Result := 'Access permission denied';
    SQLITE_ABORT: Result := 'Callback routine requested an abort';
    SQLITE_BUSY: Result := 'The database file is locked';
    SQLITE_LOCKED: Result := 'A table in the database is locked';
    SQLITE_NOMEM: Result := 'A malloc() failed';
    SQLITE_READONLY: Result := 'Attempt to write a readonly database';
    SQLITE_INTERRUPT: Result := 'Operation terminated by sqlite3_interrupt()';
    SQLITE_IOERR: Result := 'Some kind of disk I/O error occurred';
    SQLITE_CORRUPT: Result := 'The database disk image is malformed';
    SQLITE_NOTFOUND: Result := '(Internal Only) Table or record not found';
    SQLITE_FULL: Result := 'Insertion failed because database is full';
    SQLITE_CANTOPEN: Result := 'Unable to open the database file';
    SQLITE_PROTOCOL: Result := 'Database lock protocol error';
    SQLITE_EMPTY: Result := 'Database is empty';
    SQLITE_SCHEMA: Result := 'The database schema changed';
    SQLITE_TOOBIG: Result := 'Too much data for one row of a table';
    SQLITE_CONSTRAINT: Result := 'Abort due to contraint violation';
    SQLITE_MISMATCH: Result := 'Data type mismatch';
    SQLITE_MISUSE: Result := 'Library used incorrectly';
    SQLITE_NOLFS: Result := 'Uses OS features not supported on host';
    SQLITE_AUTH: Result := 'Authorization denied';
    SQLITE_FORMAT: Result := 'Auxiliary database format error';
    SQLITE_RANGE: Result := '2nd parameter to sqlite3_bind out of range';
    SQLITE_NOTADB: Result := 'File opened that is not a database file';
    SQLITE_ROW: Result := 'sqlite3_step() has another row ready';
    SQLITE_DONE: Result := 'sqlite3_step() has finished executing';
  else
    Result := 'Unknown SQLite Error Code "' + IntToStr(SQLiteErrorCode) + '"';
  end;
end;

function ColValueToStr(Value: PChar): AnsiString;
begin
  if (Value = nil) then
    Result := 'NULL'
  else
    Result := Value;
end;

function ExecCallbackCsv(Sender: TObject; Columns: Integer; ColumnValues: Pointer; ColumnNames: Pointer): integer; cdecl;
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


function SQLite3ExecCSV(h:TSQLite3DB; sql: string): string;
var
  ret: Integer;
  res: string;
  pmsg: PChar;
begin
  res := '';
  ret := SQLite3_Exec(h, PChar(sql), @ExecCallbackCsv, @res, pmsg);
  if ret <> SQLITE_OK then
  begin
    raise Exception.Create(pmsg);
  end;
  Result := res;
end;

initialization

finalization
begin
  if _sqlite3_dll <> 0 then
  begin
    FreeLibrary(_sqlite3_dll);
  end;
end;

end.

