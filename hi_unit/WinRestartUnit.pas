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
function WindowsPowerOffUpdate: Boolean;


function InitiateShutdownA(lpMachineName, lpMessage: PAnsiChar; dwGracePeriode, dwShutdownFlags, dwReason: DWORD): DWORD; stdcall;
{$EXTERNALSYM InitiateShutdownA}
function InitiateShutdownW(lpMachineName, lpMessage: PWideChar; dwGracePeriode, dwShutdownFlags, dwReason: DWORD): DWORD; stdcall;
{$EXTERNALSYM InitiateShutdownW}

function WindowsShutDownFunc(Computer: PChar; Msg: PChar; Time: Word; Force: Boolean; Reboot: Boolean): Boolean;

implementation

uses SysUtils;

function InitiateShutdownA; external 'advapi32.dll';
function InitiateShutdownW; external 'advapi32.dll';

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

function WindowsPowerOffUpdate: Boolean;
begin
  Result := WindowsShutDownFunc(nil, nil, 0, True, False);
end;


function WindowsShutDownFunc(Computer: PChar; Msg: PChar; Time: Word; Force: Boolean; Reboot: Boolean): Boolean;
const
  SHUTDOWN_FORCE_OTHERS = $00000001;
  SHUTDOWN_FORCE_SELF = $00000002;
  SHUTDOWN_GRACE_OVERRIDE = $00000020;
  SHUTDOWN_HYBRID = $00000200;
  SHUTDOWN_INSTALL_UPDATES = $00000040;
  SHUTDOWN_NOREBOOT = $00000010;
  SHUTDOWN_POWEROFF = $00000008;
  SHUTDOWN_RESTART = $00000004;
  SHUTDOWN_RESTARTAPPS = $00000080;
var
  rl: Cardinal;
  hToken: Cardinal;
  tkp: TOKEN_PRIVILEGES;
  flags: DWORD;
begin
  Result:=False;
  if not OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
    RaiseLastOSError
  else
  begin
    if LookupPrivilegeValue(nil, 'SeShutdownPrivilege', tkp.Privileges[0].Luid) then
    begin
      tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
      tkp.PrivilegeCount := 1;
      AdjustTokenPrivileges(hToken, False, tkp, 0, nil, rl);
      if GetLastError <> ERROR_SUCCESS then
        RaiseLastOSError
      else
      begin

        if Win32MajorVersion >= 6 then
        begin
          //Flags
          if Reboot then
            flags := SHUTDOWN_FORCE_SELF or SHUTDOWN_GRACE_OVERRIDE or SHUTDOWN_RESTART
          else
            flags := SHUTDOWN_FORCE_SELF or SHUTDOWN_GRACE_OVERRIDE or SHUTDOWN_INSTALL_UPDATES;

          //Befehl ausfuhren
          if InitiateShutdownA(Computer, Msg, Time, flags, 0) = ERROR_SUCCESS then
            result := True
          else
            RaiseLastOSError;
        end
        else
        begin
          if InitiateSystemShutdownA(Computer, Msg, Time, Force, Reboot) then
            result := True
          else
            RaiseLastOSError;
        end;{else}

      end;{else}
    end
    else
      RaiseLastOSError;
  end;{else}
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
