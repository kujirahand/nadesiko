unit unit_process32;

interface

uses
  Windows, SysUtils, Classes;

//PROCESSENTRY32構造体
type
  PPROCESSENTRY32 = ^TPROCESSENTRY32;
  TPROCESSENTRY32 = record
      dwSize               : integer; //構造体サイズ
      cntUsage             : integer; //参照カウント
      th32ProcessID        : integer; //プロセスID
      th32DefaultHeapID    : integer; //デフォルトのヒープID
      th32ModuleID         : integer; //モジュールID
      cntThreads           : integer; //スレッドカウント
      th32ParentProcessID  : integer; //親プロセスID
      pcPriClassBase       : integer; //基本優先レベル
      dwFlags              : integer; //フラグ（未使用）
      szExeFile            : array [0..MAX_PATH] of char; //ファイル名
  end;

//ﾌﾟﾛｾｽのｽﾅｯﾌﾟｼｮﾄを取得するAPI
function CreateToolhelp32Snapshot (dwFlag,th32ProcessID : integer) :integer;stdcall;external 'Kernel32.dll';

//最初のﾌﾟﾛｾｽを取得するAPI
function Process32First(hSnapshot :integer; lppe : PPROCESSENTRY32):integer ;stdcall;external 'Kernel32.dll';

//2番目以降のﾌﾟﾛｾｽを取得するAPI
function Process32Next(hSnapshot :integer ; lppe : PPROCESSENTRY32):integer ;stdcall;external 'Kernel32.dll';

const
  TH32CS_INHERIT      = $80000000 ;
  TH32CS_SNAPHEAPLIST = $1 ;
  TH32CS_SNAPPROCESS  = $2 ;
  TH32CS_SNAPTHREAD   = $4 ;
  TH32CS_SNAPMODULE   = $8 ;
  TH32CS_SNAPALL      = TH32CS_SNAPHEAPLIST Or TH32CS_SNAPPROCESS Or         TH32CS_SNAPTHREAD Or TH32CS_SNAPMODULE;

function GetProcesFileNameFromPID(PID: Integer):string;
function GetProcesFileNameFrom(Handle: hWnd):string;
function GetProcessList: TStringList;
function GetPidLive(PID: Integer): Boolean;

function DeleteProcess(PID: Integer): Boolean;
function GetPidFromName(name: string): Integer;

//
implementation

function DeleteProcess(PID: Integer): Boolean;
var
  process_handle: THandle;
begin
  process_handle := OpenProcess(PROCESS_TERMINATE, FALSE, PID);
  if ( process_handle > 0 ) then
  begin
    Result := TerminateProcess(process_handle, 0);
        CloseHandle(process_handle);
  end else begin
    Result := False;
  end;
end;

// ハンドルからファイル名を得る
function GetProcesFileNameFrom(Handle: hWnd):string;
var
  PID: DWORD;
  SnapShot: THandle;
  ProcessEntry32: TPROCESSENTRY32;
begin
  // ハンドルから作成スレッドを調べてプロセスＩＤを得る
  GetWindowThreadProcessId(Handle, @PID);
  // TProcessEntry32構造体の初期化
  ProcessEntry32.dwSize := SizeOf(TProcessEntry32);
  // システム中の情報のスナップショットをとる
  SnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    // 最初のプロセスの検索
    if Process32First(SnapShot, @ProcessEntry32) <> 0 then
    begin
      repeat
        // IDが一致したら
        if DWORD(ProcessEntry32.th32ProcessID) = PID then
        begin
          Result := string(ProcessEntry32.szExeFile);
          break;
        end;
      // 次のプロセスの検索
      until Process32Next(SnapShot, @ProcessEntry32) = 0;
    end;
  finally
    CloseHandle(SnapShot);
  end;
end;

// ハンドルからファイル名を得る
function GetProcesFileNameFromPID(PID: Integer):string;
var
  SnapShot: THandle;
  ProcessEntry32: TPROCESSENTRY32;
begin
  // TProcessEntry32構造体の初期化
  ProcessEntry32.dwSize := SizeOf(TProcessEntry32);
  // システム中の情報のスナップショットをとる
  SnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    // 最初のプロセスの検索
    if Process32First(SnapShot, @ProcessEntry32) <> 0 then
    begin
      repeat
        // IDが一致したら
        if ProcessEntry32.th32ProcessID = PID then
        begin
          Result := string(ProcessEntry32.szExeFile);
          break;
        end;
      // 次のプロセスの検索
      until Process32Next(SnapShot, @ProcessEntry32) = 0;
    end;
  finally
    CloseHandle(SnapShot);
  end;
end;

function GetPidFromName(name: string): Integer;
var
  SnapShot: THandle;
  ProcessEntry32: TPROCESSENTRY32;
begin
  Result := 0;
  // TProcessEntry32構造体の初期化
  ProcessEntry32.dwSize := SizeOf(TProcessEntry32);
  // システム中の情報のスナップショットをとる
  SnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    // 最初のプロセスの検索
    if Process32First(SnapShot, @ProcessEntry32) <> 0 then
    begin
      repeat
        // IDが一致したら
        if ExtractFileName(string(ProcessEntry32.szExeFile)) = name then
        begin
          Result := ProcessEntry32.th32ProcessID;
          break;
        end;
      // 次のプロセスの検索
      until Process32Next(SnapShot, @ProcessEntry32) = 0;
    end;
  finally
    CloseHandle(SnapShot);
  end;
end;

// ハンドルからファイル名を得る
function GetPidLive(PID: Integer): Boolean;
var
  SnapShot: THandle;
  ProcessEntry32: TPROCESSENTRY32;
begin
  Result := False;

  // TProcessEntry32構造体の初期化
  ProcessEntry32.dwSize := SizeOf(TProcessEntry32);

  // システム中の情報のスナップショットをとる
  SnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    // 最初のプロセスの検索
    if Process32First(SnapShot, @ProcessEntry32) <> 0 then
    begin
      repeat
        // IDが一致したら
        if ProcessEntry32.th32ProcessID = PID then
        begin
          Result := True;
          break;
        end;
      // 次のプロセスの検索
      until Process32Next(SnapShot, @ProcessEntry32) = 0;
    end;
  finally
    CloseHandle(SnapShot);
  end;
end;

{
function getProcessTimeMSEC(
  hProcess: DWORD;
  pUseTime: PDWORD;
  pKernelTime: PDWORD ): boolean;
var
  ftCreate, ftExit, ftKernel, ftUser: _FILETIME;
  ptr: PInt64;
begin
  Result := GetProcessTimes( hProcess, ftCreate, ftExit, ftKernel, ftUser );

  if ( Result ) then begin
    ptr := PInt64( @ftUser );
    pUseTime^ := DWORD( ptr^ div 10000 );

    ptr := PInt64( @ftKernel );
    pKernelTime^ := DWORD(ptr^ div 10000 );
  end else begin
    pUseTime^ := 0;
    pKernelTime^ := 0;
  end;
end;
}


function GetProcessList: TStringList;
var
    hProcesss : integer;
    P32 : TPROCESSENTRY32 ;
begin
    Result := TStringList.Create;

    hProcesss := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    P32.dwSize := Sizeof(TPROCESSENTRY32);

    if Process32First(hProcesss, @P32) <> 0 then
    begin
      repeat
        Result.Add(P32.szExeFile);
      until(Process32Next(hProcesss, @P32) = 0);
    end;

    CloseHandle(hProcesss) ;
end;

end.
