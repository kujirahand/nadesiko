unit WinRestartUnit;
// Windows を再起動したり、電源を切る命令

interface
uses
  Windows;


function WindowsPowerOff: Boolean;
function WindowsRestart: Boolean;
function WindowsLogOff: Boolean;
function WindowsSuspend: Boolean;
function WindowsShowLogonScreen: Boolean;

implementation

uses SysUtils;

const
  SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';

function GetPriviledges: boolean;
const
 PriviledgesMsg = '特権の取得に失敗しました。';
var
 TokenPriv: TTokenPrivileges;
 TokenHandle: THandle;
 CurrentProc: THandle;
 ret: Cardinal;
begin
 Result := False;

 {特権変更を可能にする}
 CurrentProc := GetCurrentProcess;
 if OpenProcessToken(CurrentProc,TOKEN_ADJUST_PRIVILEGES or
    TOKEN_QUERY, TokenHandle) then
  begin
   {特権名を取得}
   if LookupPrivilegeValue(nil,
      SE_SHUTDOWN_NAME, TokenPriv.Privileges[0].LUID) then
    begin
     TokenPriv.PrivilegeCount := 1;
     TokenPriv.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
     {特権を再設定}
     Result := AdjustTokenPrivileges(
      TokenHandle, False, TokenPriv, 0, nil, ret);
    end;
  end;

 {失敗時は例外を生成}
 if not Result then
   raise Exception.Create(PriviledgesMsg);
end;

function ExitWindowsNT(const Flag: Cardinal): boolean;
begin
 Result := False;
 if GetPriviledges then                //特権取得
  Result := ExitWindowsEx(Flag, 0);
end;

function IsNT: boolean;
var
  OsVersionInfo: TOSVERSIONINFO;
begin
 OsVersionInfo.dwOSVersionInfoSize := SizeOf(OsVersionInfo);
 GetVersionEx(OsVersionInfo);
 Result := OsVersionInfo.dwPlatformId = VER_PLATFORM_WIN32_NT;
end;

function WindowsPowerOff: Boolean;
begin
  if IsNT then
  begin
   Result := ExitWindowsNT(EWX_SHUTDOWN or EWX_POWEROFF)
  end else
  begin
   Result := ExitWindowsEx(EWX_SHUTDOWN or EWX_POWEROFF, 0);
  end;
end;

function WindowsLogOff: Boolean;
begin
  Result := ExitWindowsEx(EWX_LOGOFF, 0);
end;

function WindowsRestart: Boolean;
begin
  if IsNT then
  begin
   Result := ExitWindowsNT(EWX_REBOOT)
  end else
  begin
   Result := ExitWindowsEx(EWX_REBOOT, 0);
  end;
end;

function WindowsSuspend: Boolean;
var
  hToken, len : Cardinal;
  NewToken, PreToken : TTokenPrivileges;
begin
  if IsNT then
  begin
    OpenProcessToken(GetCurrentProcess, (TOKEN_QUERY or TOKEN_ADJUST_PRIVILEGES), hToken);
    LookupPrivilegeValue(nil, SE_SHUTDOWN_NAME, NewToken.Privileges[0].Luid);
    NewToken.PrivilegeCount := 1;
    NewToken.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
    AdjustTokenPrivileges(hToken, False, NewToken, SizeOf(PreToken), PreToken, len);
  end;
  Result := SetSystemPowerState(True, True);
end;

function WindowsShowLogonScreen: Boolean;
var
  cmd: string;
begin
  cmd := 'RunDLL32.EXE user32.dll,LockWorkStation';
  Result := (WinExec(PChar(cmd), SW_NORMAL) > 30);
end;

end.
