unit dll_ctrl_function;

interface

uses
  Windows, messages, vbfunc, WinRestartUnit, Classes, ActiveX, mmsystem;

const
  NAKOCTRL_DLL_VERSION = '1.5073';

procedure RegistFunction;

implementation

uses dll_plugin_helper, dnako_import, dnako_import_types, unit_ctrl,
  CpuUtils, unit_process32, HotKeyManager, hima_hotkey_manager, SysUtils,
  Types, unit_string;

function getNakoCtrlVersion(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(NAKOCTRL_DLL_VERSION);
end;


function cmd_sendKeys(h: DWORD): PHiValue; stdcall;
var
  pa, ps: PHiValue;
begin
  // ����
  Result := nil;

  // �����̎擾
  pa := nako_getFuncArg(h, 0);
  ps := nako_getFuncArg(h, 1);

  if pa <> nil then
  begin
    AppActivate(hi_str(pa), hi_str(pa), hi_int(pa));
  end;

  SendKeys(hi_str(ps), False);
end;

function cmd_sendChars(h: DWORD): PHiValue; stdcall;
var
  pa, ps: PHiValue;
begin
  // ����
  Result := nil;

  // �����̎擾
  pa := nako_getFuncArg(h, 0);
  ps := nako_getFuncArg(h, 1);

  if pa <> nil then
  begin
    AppActivate(hi_str(pa), hi_str(pa), hi_int(pa));
  end;

  SendChars(hi_str(ps), False);
end;

function cmd_sendVkeys(h: DWORD): PHiValue; stdcall;
var
  pa: PHiValue;
  key: Byte;
begin
  // ����
  Result := nil;

  // �����̎擾
  pa := nako_getFuncArg(h, 0);
  key := hi_int(nako_getFuncArg(h, 1));

  if pa <> nil then
  begin
    AppActivate(hi_str(pa), hi_str(pa), hi_int(pa));
  end;

  keybd_event(key, 0, 0, 0);
  keybd_event(Key, 0, KEYEVENTF_KEYUP, 0);
end;

function cmd_capslock(h: DWORD): PHiValue; stdcall;
var
  pa: PHiValue;
begin
  // ����
  Result := nil;

  // �����̎擾
  pa := nako_getFuncArg(h, 0);
  SetCapsLock(hi_bool(pa));
end;

function cmd_capslock_get(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newBool(GetCapsLock);
end;

function cmd_numlock(h: DWORD): PHiValue; stdcall;
var
  pa: PHiValue;
begin
  // ����
  Result := nil;

  // �����̎擾
  pa := nako_getFuncArg(h, 0);
  SetNumLock(hi_bool(pa));
end;

function cmd_numlock_get(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newBool(GetNumLock);
end;

function cmd_active(h: DWORD): PHiValue; stdcall;
var
  pa: PHiValue;
begin
  // ����
  Result := nil;

  // �����̎擾
  pa := nako_getFuncArg(h, 0);
  if pa = nil then pa := nako_getSore;

  AppActivate(hi_str(pa), hi_str(pa), hi_int(pa));
end;

function cmd_handleActive(h:DWORD): PHiValue; stdcall;
var
  handle: THandle;
begin
  // ����
  Result := nil;

  // �����̎擾
  handle := getArgInt(h, 0, True);
  WaitHandleActive(handle);
end;


function cmd_getActive(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newInt(GetForegroundWindow);
end;

function cmd_getActiveTitle(h: DWORD): PHiValue; stdcall;
var
  hh: THandle;
  s: string;
begin
  hh := GetForegroundWindow;
  SetLength(s, 4096);
  GetWindowText(hh, PChar(s), 4096);
  Result := hi_newStr(PChar(s));
end;

function cmd_topmost(h: DWORD): PHiValue; stdcall;
var
  mask: string;
  wh: THandle;
begin
  Result := nil;
  mask := getArgStr(h, 0, True);
  wh := AppFind(mask, mask, 0);
  if wh = 0 then Exit;
  SetWindowPos(wh, HWND_TOPMOST, 0, 0, 0, 0, SWP_SHOWWINDOW or SWP_NOMOVE or SWP_NOSIZE);
end;

function cmd_topmost_off(h: DWORD): PHiValue; stdcall;
var
  mask: string;
  wh: THandle;
begin
  Result := nil;
  mask := getArgStr(h, 0, True);
  wh := AppFind(mask, mask, 0);
  if wh = 0 then Exit;
  SetWindowPos(wh, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_SHOWWINDOW or SWP_NOMOVE or SWP_NOSIZE);

end;

function cmd_setWinText(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
  s: string;
begin
  handle := getArgInt(h, 0, True);
  s := getArgStr(h, 1);
  SetWindowText(handle, PChar(s));
  Result := nil;
end;

function cmd_getWinText(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
  s: string;
  len: Integer;
begin
  handle := getArgInt(h, 0, True);
  len := GetWindowTextLength(handle);
  SetLength(s, len + 1);
  GetWindowText(handle, PChar(s), len + 1);
  s := trim(s);
  Result := hi_newStr(s);
end;

function cmd_win_getSize(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
  r:TRect;
begin
  handle := getArgInt(h, 0, True);
  GetWindowRect(handle, r);
  Result := hi_newStr(Format('%d,%d,%d,%d',[r.Left, r.Top, r.Right, r.Bottom]));
end;

function cmd_getClientRect(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
  r:TRect;
begin
  handle := getArgInt(h, 0, True);
  GetClientRect(handle, r);
  Result := hi_newStr(Format('%d,%d,%d,%d',[r.Left, r.Top, r.Right, r.Bottom]));
end;

function cmd_win_setSize(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
  s, x1,y1,x2,y2: string;
  function i(s: string): Integer;
  begin
    Result := StrToIntDef(s, 0);
  end;
begin
  handle := getArgInt(h, 0, True);
  s := getArgStr(h, 1);
  x1 := getToken_s(s, ',');
  y1 := getToken_s(s, ',');
  x2 := getToken_s(s, ',');
  y2 := getToken_s(s, ',');
  SetWindowPos(handle, 0, i(x1),i(y1),(i(x2)-i(x1)),(i(y2)-i(y1)), SWP_NOZORDER);
  Result := nil;
end;

function cmd_win_click(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
begin
  handle := getArgInt(h, 0, True);
  SendMessage(handle, WM_LBUTTONDOWN, 1, 0);
  SendMessage(handle, WM_LBUTTONUP, 1, 0);
  Result := nil;
end;


function cmd_win_click_a(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
begin
  handle := getArgInt(h, 0, True);
  PostMessage(handle, WM_LBUTTONDOWN, 1, 0);
  PostMessage(handle, WM_LBUTTONUP, 1, 0);
  Result := nil;
end;

function cmd_win_click_r(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
begin
  handle := getArgInt(h, 0, True);
  SendMessage(handle, WM_RBUTTONDOWN, 1, 0);
  SendMessage(handle, WM_RBUTTONUP, 1, 0);
  Result := nil;
end;

function cmd_win_getParent(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
begin
  handle := getArgInt(h, 0, True);
  handle := GetParent(handle);
  Result := hi_newInt(handle);
end;


function cmd_win_getXY(h: DWORD): PHiValue; stdcall;
var
  x, y: Integer;
  handle: THandle;
begin
  x := getArgInt(h, 0, True);
  y := getArgInt(h, 1);
  handle := WindowFromPoint(Point(x,y));
  Result := hi_newInt(handle);
end;

function GetXYClientHandle(p: TPoint): HWND;
var cp:TPoint; h: LongInt; x,y: Integer; r: TRect;
begin
  // �g�b�v�E�B���h�E�𓾂�
  Result := 0;
  h := WindowFromPoint(p);
  cp := p;
  if h <> 0 then
  begin
    while h<>0 do
    begin
      GetWindowRect(h, r);
      x := cp.X - r.Left;
      y := cp.Y - r.Top;
      cp := POINT(x, y);
      h := ChildWindowFromPoint(h, cp);
      if h <> 0 then Result := h;
    end;
  end;
end;

function cmd_win_getXY_c(h: DWORD): PHiValue; stdcall;
var
  x, y: Integer;
  handle: THandle;
begin
  x := getArgInt(h, 0, True);
  y := getArgInt(h, 1);
  handle := GetXYClientHandle(Point(x,y));
  Result := hi_newInt(handle);
end;

function cmd_enumChildWindow(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
  ret: string;
begin
  handle := getArgInt(h, 0, True);
  ret := EnumChildWindowStr(handle);
  Result := hi_newStr(ret);
end;


function cmd_findChildWindow(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
  pat: string;
  ret: THandle;
begin
  handle := getArgInt(h, 0, True);
  pat := getArgStr(h, 1);
  ret := findChildWindow(handle, pat);
  Result := hi_newInt(ret);
end;

function cmd_enumWindow(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
  ret: string;
begin
  handle := getArgInt(h, 0, True);
  ret := '';
  ret := EnumWindowStr(handle);
  Result := hi_newStr(ret);
end;

function cmd_flashWindow(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
  p:FLASHWINFO;
begin
  handle := getArgInt(h, 0, True);
  //FlashWindow(handle, True);
  p.cbSize := sizeof(p);
  p.hwnd := handle;
  p.dwFlags := FLASHW_ALL;
  p.dwTimeout := 0;
  p.uCount := 10;
  FlashWindowEx(p);
  Result := nil;
end;

function cmd_findHandle(h: DWORD): PHiValue; stdcall;
var
  pa: PHiValue; s: string; hh: HWND;
begin
  // ����
  Result := nil;

  // �����̎擾
  pa := nako_getFuncArg(h, 0);
  if pa = nil then pa := nako_getSore;

  s := hi_str(pa);
  hh := FindWindow(PChar(s),nil);
  if hh = 0 then hh := FindWindow(nil,PChar(s));
  if hh = 0 then
  begin
    Result := hi_newInt(
      AppFind(hi_str(pa), hi_str(pa), hi_int(pa))
    );
  end else
  begin
    Result := hi_newInt(hh);
  end;
end;

function cmd_findHandleTime(h: DWORD): PHiValue; stdcall;
var
  pattern: string; hh: HWND;
  start_time, max_time: DWORD;
  ret: PHiValue;
begin
  // ����
  Result := nil;

  // �����̎擾
  pattern  := getArgStr(h, 0, True);
  max_time := getArgInt(h, 1) * 1000;

  start_time := timeGetTime;

  while (timeGetTime - start_time) <= max_time do
  begin
    hh := FindWindow(PChar(pattern),nil);
    if hh = 0 then hh := FindWindow(nil,PChar(pattern));
    if hh = 0 then
    begin
      hh := AppFind(pattern, pattern, StrToIntDef(pattern, 0));
    end;
    if hh <> 0 then
    begin
      Result := hi_newInt(hh);
      Break;
    end;
    nako_evalEx('0.3�b�҂�', ret);
    if ret <> nil then nako_var_free(ret);
  end;
end;

function cmd_sendKeysHandle(h: DWORD): PHiValue; stdcall;
var
  s: string;
  handle: THandle;
begin
  // ����
  Result := nil;

  // �����̎擾
  handle  := getArgInt(h, 0, True);
  s       := getArgStr(h, 1, False);

  if WaitHandleActive(handle, 2000) then
  begin
    SendKeys(s, True);
  end;
end;

function cmd_sendCharsHandle(h: DWORD): PHiValue; stdcall;
var
  s: string;
  pa: PHiValue;
begin
  // ����
  Result := nil;

  // �����̎擾
  pa := nako_getFuncArg(h, 0);
  s := getArgStr(h, 1, False);

  if pa <> nil then
  begin
    WaitHandleActive(hi_int(pa), 2000);
  end;

  SendChars(s, True);
end;

function cmd_sendVKeysHandle(h: DWORD): PHiValue; stdcall;
var
  key: Byte;
  pa: PHiValue;
begin
  // ����
  Result := nil;

  // �����̎擾
  pa := nako_getFuncArg(h, 0);
  key := hi_int(nako_getFuncArg(h, 1));

  if pa <> nil then
  begin
    WaitHandleActive(hi_int(pa), 2000);
  end;

  keybd_event(key, 0, 0, 0);
  keybd_event(Key, 0, KEYEVENTF_KEYUP, 0);
end;

function cmd_restart(h: DWORD): PHiValue; stdcall;
begin
  // ����
  Result := nil;
  WindowsRestart;
end;

function cmd_poweroff(h: DWORD): PHiValue; stdcall;
begin
  // ����
  Result := nil;
  WindowsPowerOff;
end;

function cmd_poweroff_update(h: DWORD): PHiValue; stdcall;
begin
  // ����
  Result := nil;
  WindowsPowerOffUpdate;
end;

function cmd_showLogon(h: DWORD): PHiValue; stdcall;
begin
  // ����
  Result := nil;
  WindowsShowLogonScreen;
end;


function cmd_logoff(h: DWORD): PHiValue; stdcall;
begin
  // ����
  Result := nil;
  WindowsLogOff;
end;

function cmd_suspend(h: DWORD): PHiValue; stdcall;
begin
  // ����
  Result := nil;
  WindowsSuspend;
end;



function cmd_getMouseX(h: DWORD): PHiValue; stdcall;
var
  xy: TPoint;
begin
  GetCursorPos(xy);
  Result := hi_newInt(xy.X);
end;

function cmd_getMouseY(h: DWORD): PHiValue; stdcall;
var
  xy: TPoint;
begin
  GetCursorPos(xy);
  Result := hi_newInt(xy.Y);
end;


function getWorkArea: TRect;
begin
  SystemParametersInfo(SPI_GETWORKAREA, 0, @Result, 0);
end;

function cmd_mouse_drag(h: DWORD): PHiValue; stdcall;
var
  x1,y1,x2,y2: Integer;
  MW,MH: Extended;
  r: TRect;
begin
  //
  Result := nil;
  //
  x1 := getArgInt(h, 0);
  y1 := getArgInt(h, 1);
  x2 := getArgInt(h, 2);
  y2 := getArgInt(h, 3);
  //
  r := getWorkArea;
  MW := 65535 / (r.Right  - r.Left);
  MH := 65535 / (r.Bottom - r.Top);
  //
  x1 := Trunc(x1 * MW);
  y1 := Trunc(y1 * MH);
  x2 := Trunc(x2 * MW);
  y2 := Trunc(y2 * MH);
  //
  mouse_event(2 or $8000 or $1, x1, y1, 0, 0);
  Sleep(10);
  mouse_event($8000 or $1, x2, y2, 0, 0);
  Sleep(10);
  mouse_event($4,0,0,0,0);// ���{�^����UP
end;

function cmd_mouse_drag_r(h: DWORD): PHiValue; stdcall;
var
  x1,y1,x2,y2: Integer;
  MW,MH: Extended;
  r: TRect;
begin
  //
  Result := nil;
  //
  x1 := getArgInt(h, 0);
  y1 := getArgInt(h, 1);
  x2 := getArgInt(h, 2);
  y2 := getArgInt(h, 3);
  //
  r := getWorkArea;
  MW := 65535 / (r.Right  - r.Left);
  MH := 65535 / (r.Bottom - r.Top);
  //
  x1 := Trunc(x1 * MW);
  y1 := Trunc(y1 * MH);
  x2 := Trunc(x2 * MW);
  y2 := Trunc(y2 * MH);
  //
  mouse_event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE, x1, y1, 0, 0);
  Sleep(10);
  mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
  Sleep(10);
  mouse_event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE, x2, y2, 0, 0);
  Sleep(10);
  mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
end;

function cmd_movexy(h: DWORD): PHiValue; stdcall;
var
  px, py: PHiValue;
begin
  // ����
  Result := nil;
  //
  px := nako_getFuncArg(h, 0);
  py := nako_getFuncArg(h, 1);
  SetCursorPos(hi_int(px), hi_int(py));
end;

function cmd_mouse_tilt_l(h: DWORD): PHiValue; stdcall;
begin
  // ����
  Result := nil;
  //
  mouse_event($01000 {MOUSEEVENTF_HWHEEL},
    MOUSEEVENTF_ABSOLUTE, MOUSEEVENTF_ABSOLUTE, $ffffffff, 0);
end;

function cmd_mouse_tilt_r(h: DWORD): PHiValue; stdcall;
begin
  // ����
  Result := nil;
  //
  mouse_event($01000 {MOUSEEVENTF_HWHEEL},
    MOUSEEVENTF_ABSOLUTE, MOUSEEVENTF_ABSOLUTE, 1, 0);
end;

function cmd_mouse_wheel(h: DWORD): PHiValue; stdcall;
var
  d, py: PHiValue;
  s: String;
  y: Integer;
begin
  // ����
  Result := nil;
  //
  d := nako_getFuncArg(h, 0);
  py := nako_getFuncArg(h, 1);

  s := hi_str(d);
  y := hi_int(py);

  if (s='��') or (s='��O') or (s='�t') then
    y := -y;

  mouse_event(MOUSEEVENTF_WHEEL,
    MOUSEEVENTF_ABSOLUTE, MOUSEEVENTF_ABSOLUTE, y, 0);
end;

function cmd_mouse_click(h: DWORD): PHiValue; stdcall;
begin
  // ����
  Result := nil;

  mouse_event(MOUSEEVENTF_LEFTDOWN,
    MOUSEEVENTF_ABSOLUTE, MOUSEEVENTF_ABSOLUTE, 0, 0);
  mouse_event(MOUSEEVENTF_LEFTUP,
    MOUSEEVENTF_ABSOLUTE, MOUSEEVENTF_ABSOLUTE, 0, 0);

end;

function cmd_mouse_r_click(h: DWORD): PHiValue; stdcall;
begin
  // ����
  Result := nil;

  mouse_event(MOUSEEVENTF_RIGHTDOWN,
    MOUSEEVENTF_ABSOLUTE, MOUSEEVENTF_ABSOLUTE, 0, 0);
  mouse_event(MOUSEEVENTF_RIGHTUP,
    MOUSEEVENTF_ABSOLUTE, MOUSEEVENTF_ABSOLUTE, 0, 0);

end;

function cmd_winmove(h: DWORD): PHiValue; stdcall;
var
  pa, px, py: PHiValue;
  handle: HWND;
begin
  // ����
  Result := nil;
  //
  pa := nako_getFuncArg(h, 0);
  px := nako_getFuncArg(h, 1);
  py := nako_getFuncArg(h, 2);

  if pa <> nil then
  begin
    AppActivate(hi_str(pa), hi_str(pa), hi_int(pa));
  end;

  handle := GetForegroundWindow;
  if handle <> 0 then
  begin
    SetWindowPos(handle, 0, hi_int(px), hi_int(py), 0, 0,
        SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
  end;
end;


function cmd_handle_winmove(h: DWORD): PHiValue; stdcall;
var
  handle: HWND;
  x, y: Integer;
begin
  // ����
  Result := nil;
  handle := getArgInt(h, 0, True);
  x := getArgInt(h, 1);
  y := getArgInt(h, 2);

  if handle <> 0 then
  begin
    SetWindowPos(handle, 0, x, y, 0, 0,
        SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
  end;
end;

//�o�b�e��
function cmd_ac_check(h: DWORD): PHiValue; stdcall;
var
  sps: TSystemPowerStatus;
  b: Byte;
begin
  if GetSystemPowerStatus(sps) then
  begin
    b := sps.ACLineStatus;
    case b of
        0: Result := hi_newInt(0);
        1: Result := hi_newInt(1);
      else Result := hi_newInt(-1);
    end;
  end else
  begin
    Result := hi_newInt(-1); // �s��
  end;
end;
function cmd_get_battery(h: DWORD): PHiValue; stdcall;
var
  sps: TSystemPowerStatus;
  b: Byte;
begin
{
Value	Meaning
1	High
2	Low
4	Critical
8	Charging
128	No system battery
255	Unknown status
}
  Result := nil;
  if GetSystemPowerStatus(sps) then
  begin
    b := sps.BatteryFlag;
    case b of
      1: Result := hi_newStr('��');
      2: Result := hi_newStr('��');
      4: Result := hi_newStr('�v���I');
      8: Result := hi_newStr('�[�d��');
    128: Result := hi_newStr('�Ȃ�');
    255: Result := hi_newStr('�s��');
    else Result := hi_newStr('�s��');
    end;
  end else
  begin
    Result := hi_newStr('�s��');
  end;
end;
function cmd_get_battery_per(h: DWORD): PHiValue; stdcall;
var
  sps: TSystemPowerStatus;
begin
  if GetSystemPowerStatus(sps) then
  begin
    if sps.BatteryLifePercent = 255 then
    begin
      Result := hi_newInt(-1);
    end else
    begin
      Result := hi_newInt(sps.BatteryLifePercent);
    end;
  end else
  begin
    Result := hi_newInt(sps.BatteryLifePercent);
  end;
end;

var FCpuUsage: TCpuUsage = nil; // GLOBAL �Ȃ̂� Singleton �Ŏg��

function cmd_cpu(h: DWORD): PHiValue; stdcall;
var
  i, v: Integer;
  f: Extended;
  bFirst: Boolean;
begin
  Result := nil;

  if FCpuUsage = nil then
  begin
    FCpuUsage := TCpuUsage.Create(nil);
    FCpuUsage.Reset;
    bFirst := True;
  end else
  begin
    bFirst := False;
  end;

  v := FCpuUsage.Value;
  if bFirst then
  begin
    // �K���Ɍv��(NT�n�̏ꍇ) --->
    f := 0;
    for i := 1 to 10 do
    begin
      sleep(50);
      f := f + FCpuUsage.Value;
    end;
    v := Trunc( f / 10 );
    // <---
  end;
  Result := hi_newInt(v);
end;


function cmd_memoryusage(h: DWORD): PHiValue; stdcall;
var
  g:TMemoryStatus;
begin
  GlobalMemoryStatus(g);
  Result := hi_newInt(g.dwMemoryLoad);
end;

//-------------------------------------------------------
// for "GlobalMemoryStatusEx()"
//-------------------------------------------------------
type
  SIZE_T = Cardinal; 
  {$EXTERNALSYM SIZE_T} 
  DWORDLONG = Int64;  // ULONGLONG 
  {$EXTERNALSYM DWORDLONG} 

type 
  PMemoryStatus = ^TMemoryStatus; 
  LPMEMORYSTATUS = PMemoryStatus; 
  {$EXTERNALSYM LPMEMORYSTATUS} 
  _MEMORYSTATUS = packed record 
    dwLength       : DWORD;
    dwMemoryLoad   : DWORD; 
    dwTotalPhys    : SIZE_T; 
    dwAvailPhys    : SIZE_T; 
    dwTotalPageFile: SIZE_T; 
    dwAvailPageFile: SIZE_T; 
    dwTotalVirtual : SIZE_T; 
    dwAvailVirtual : SIZE_T; 
  end; 
  {$EXTERNALSYM _MEMORYSTATUS}
  TMemoryStatus = _MEMORYSTATUS; 
  MEMORYSTATUS = _MEMORYSTATUS; 
  {$EXTERNALSYM MEMORYSTATUS} 

type 
  PMemoryStatusEx = ^TMemoryStatusEx; 
  LPMEMORYSTATUSEX = PMemoryStatusEx; 
  {$EXTERNALSYM LPMEMORYSTATUSEX} 
  _MEMORYSTATUSEX = packed record 
    dwLength        : DWORD; 
    dwMemoryLoad    : DWORD; 
    ullTotalPhys    : DWORDLONG; 
    ullAvailPhys    : DWORDLONG; 
    ullTotalPageFile: DWORDLONG; 
    ullAvailPageFile: DWORDLONG; 
    ullTotalVirtual : DWORDLONG; 
    ullAvailVirtual : DWORDLONG;
    ullAvailExtendedVirtual: DWORDLONG;
  end; 
  {$EXTERNALSYM _MEMORYSTATUSEX} 
  TMemoryStatusEx = _MEMORYSTATUSEX; 
  MEMORYSTATUSEX = _MEMORYSTATUSEX; 
  {$EXTERNALSYM MEMORYSTATUSEX} 

//-------------------------------------------------------
procedure GlobalMemoryStatus(var lpBuffer: TMemoryStatus); stdcall;
  external kernel32;
{$EXTERNALSYM GlobalMemoryStatus}

function GlobalMemoryStatusEx(var lpBuffer: TMemoryStatusEx): BOOL; stdcall;
type
  TFNGlobalMemoryStatusEx = function(var msx: TMemoryStatusEx): BOOL; stdcall;
var
  FNGlobalMemoryStatusEx: TFNGlobalMemoryStatusEx;
begin
  FNGlobalMemoryStatusEx := TFNGlobalMemoryStatusEx(
    GetProcAddress(GetModuleHandle(kernel32), 'GlobalMemoryStatusEx'));
  if not Assigned(FNGlobalMemoryStatusEx) then
  begin
    SetLastError(ERROR_CALL_NOT_IMPLEMENTED);
    Result := False;
  end
  else
    Result := FNGlobalMemoryStatusEx(lpBuffer);
end;
//-------------------------------------------------------


function cmd_memory_status(h: DWORD): PHiValue; stdcall;
var
  g:TMemoryStatus;
  os:_OSVERSIONINFOA;
  Status: TMemoryStatusEx;

  procedure _old;
  begin
    GlobalMemoryStatus(g);
    Result := hi_newInt(g.dwTotalPhys);
  end;

begin
  ZeroMemory(@os, SizeOf(os));
  os.dwOSVersionInfoSize := SizeOf(os);
  GetVersionEx(os);
  // --- Windows 2000 �ȍ~
  if (os.dwPlatformId = VER_PLATFORM_WIN32_NT)and
    (os.dwMajorVersion >= 5) then
  begin
    ZeroMemory(@Status, SizeOf(TMemoryStatusEx));
    Status.dwLength := SizeOf(TMemoryStatusEx);
    if not GlobalMemoryStatusEx(Status) then
    begin
      _old; Exit;
    end;
    Result := hi_newFloat(Status.ullTotalPhys);
  end else begin
    _old;
  end;
end;

{
AddFunc('�v���Z�X��','',4256, cmd_enumProcess, '�N�����Ă���v���Z�X��񋓂��ĕԂ�',  '�Ղ낹���������');
AddFunc('�v���Z�X�����I��','S��',4257, cmd_killProcess, '�N�����Ă���v���Z�X(EXE���Ŏw��)�������I��������',  '�Ղ낹�����傤�������イ��傤');
}
function cmd_enumProcess(h: DWORD): PHiValue; stdcall;
var
  s: TStringList;
begin
  s := GetProcessList;
  try
    Result := hi_newStr(s.Text);
  finally
    s.Free;
  end;
end;

function cmd_killProcess(h: DWORD): PHiValue; stdcall;
var
  name: string;
begin
  name := getArgStr(h, 0, False);
  DeleteProcess(GetPidFromName(name));
  Result := nil;
end;

var
  IsUserAnAdmin: function : BOOL = nil;

function cmd_IsUserAnAdmin(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
begin
  if @IsUserAnAdmin = nil then
  begin
    handle := LoadLibrary('shell32.dll');
    if handle <> 0 then
    begin
      IsUserAnAdmin := GetProcAddress(handle, 'IsUserAnAdmin');
    end;
  end;
  //
  if @IsUserAnAdmin <> nil then
  begin
    Result := hi_newBool(IsUserAnAdmin);
  end else
  begin
    Result := hi_newBool(True);
  end;
end;

var
  hotkeys: THiHotkey = nil;

function cmd_setHotkey(h: DWORD): PHiValue; stdcall;
var
  key, event: string;
begin
  // arg
  key   := getArgStr(h, 0, True);
  event := getArgStr(h, 1);
  if hotkeys = nil then
  begin
    hotkeys := THiHotkey.Create(nil);
  end;
  hotkeys.AddHotKeyEvent(key, event);
  Result := nil;
end;

function cmd_removeHotkey(h: DWORD): PHiValue; stdcall;
var
  key: string;
begin
  // arg
  key   := getArgStr(h, 0, True);
  if hotkeys <> nil then
  begin
    hotkeys.RemoveHotKeyEvent(key);
  end;
  Result := nil;
end;

function cmd_createGUID(h: DWORD): PHiValue; stdcall;
var
  g: TGUID;
  s: string;
begin
  if Failed(CoCreateGUID(g)) then
  begin
    raise Exception.Create('GUID�����Ɏ��s');
  end;
  s := GUIDToString(g);
  s := Copy(s, 2, Length(s) - 2);
  Result := hi_newStr(s);
end;

{
// ���炽�܂���̃v���O�C���̕����֗��Ȃ̂Ŕp�~
- uses DdeMan
- AddFunc('DDE���M','SERVER��TOPIC��S��',0, cmd_dde_send, 'DDE��SEVER��TOPIC�ɕ�����S�𑗐M�����ʂ𓾂�', 'DDE��������');
function cmd_dde_send(h: DWORD): PHiValue; stdcall;
var
  ret, server, topic, s: string;
  dde: TDdeClientConv;
begin
  server := getArgStr(h, 0, True);
  topic := getArgStr(h, 1);
  s := getArgStr(h, 2);
  ret := '';
  //
  dde := TDdeClientConv.Create(nil);
  try
    dde.ServiceApplication := ParamStr(0);
    if dde.SetLink(server, topic) then
    begin
      ret := dde.RequestData(s);
    end else
    begin
      raise Exception.Create('DDE�R�}���h�̑��M�Ɏ��s');
    end;
    dde.CloseLink;
  finally
    FreeAndNil(dde);
  end;
  Result := hi_newStr(ret);
end;
}

function cmd_getcursel(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
  v: Integer;
begin
  handle := getArgInt(h, 0, True);
  v := getWindowValueInt(handle);
  Result := hi_newInt(v);
end;
function cmd_setcursel(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
  v: Integer;
begin
  handle := getArgInt(h, 0, True);
  v := getArgInt(h, 1);
  setWindowValueInt(handle, v);
  Result := nil;
end;
function cmd_wingetitemcount(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
  v: Integer;
begin
  handle := getArgInt(h, 0, True);
  v := getWindowItemCount(handle);
  Result := hi_newInt(v);
end;
function cmd_wingetitems(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
begin
  handle := getArgInt(h, 0, True);
  Result := hi_newStr(getWindowItems(handle));
end;
function cmd_ClientToScreen(h: DWORD): PHiValue; stdcall;
var
  handle: THandle;
  x, y: Integer;
  pt: TPoint;
begin
  handle := getArgInt(h, 0, True);
  x := getArgInt(h, 1);
  y := getArgInt(h, 2);
  pt.X := x;
  pt.Y := y;
  ClientToScreen(handle, pt);
  Result := hi_newStr(IntToStr(pt.X) + ',' + IntToStr(pt.Y));
end;



procedure RegistFunction;
begin
  //:::::::4200
  //todo: ���߂̒�`
  //<����>

  //+�\�t�g����/OS/�v���Z�X(nakoctrl.dll)
  //-�L�[����
  AddFunc('�L�[���M',     '{=?}A��S��|A��', 4200, cmd_sendKeys, '�^�C�g��A�����E�B���h�E�ɕ���S���L�[���M����BA���ȗ�����ƃA�N�e�B�u�ȃE�B���h�E�֑��M�B(VB�݊�)','���[��������');
  AddFunc('�L�[�������M',     '{=?}A��S��|A��', 4219, cmd_sendChars, '�^�C�g��A�����E�B���h�E�ɕ���S�����̂܂ܑ��M����B����L�[�͑��M�ł��Ȃ��BA���ȗ�����ƃA�N�e�B�u�ȃE�B���h�E�֑��M�B','���[������������');
  AddFunc('���z�L�[���M',     '{=?}A��S��|A��', 4223, cmd_sendVKeys, '�^�C�g��A�����E�B���h�E�ɉ��z�L�[�R�[�h(����)�𑗐M����BA���ȗ�����ƃA�N�e�B�u�ȃE�B���h�E�֑��M�B','���������[��������');
  AddFunc('CAPSLOCK�ݒ�', '{=?}A��',        4206, cmd_capslock, 'CapsLock�̏�Ԃ�A(ON/OFF)�ɂ���B','CAPSLOCK�����Ă�');
  AddFunc('CAPSLOCK�擾', '',               4207, cmd_capslock_get, 'CapsLock�̏�Ԃ𓾂�','CAPSLOCK����Ƃ�');
  AddFunc('NUMLOCK�ݒ�', '{=?}A��',        4210, cmd_numlock, 'NumLock�̏�Ԃ�A(ON/OFF)�ɂ���B','NUMLOCK�����Ă�');
  AddFunc('NUMLOCK�擾', '',               4211, cmd_numlock_get, 'NumLock�̏�Ԃ𓾂�','NUMLOCK����Ƃ�');

  //-�}�E�X����
  AddFunc('�}�E�X�ړ�', 'X,Y��|Y��',        4201, cmd_movexy,       '�}�E�X��X,Y�ֈړ�����B','�܂������ǂ�');
  AddFunc('�}�E�X�N���b�N', '',             4202, cmd_mouse_click,  '�}�E�X���N���b�N������B','�܂����������');
  AddFunc('�}�E�X�E�N���b�N', '',           4203, cmd_mouse_r_click,'�}�E�X���E�N���b�N������B','�܂����݂��������');
  AddFunc('����}�E�XX', '',                4221, cmd_getMouseX,    '�f�X�N�g�b�v��ł̃}�E�XX���W��Ԃ�','�����傤�܂���X');
  AddFunc('����}�E�XY', '',                4222, cmd_getMouseY,    '�f�X�N�g�b�v��ł̃}�E�XY���W��Ԃ�','�����傤�܂���Y');
  AddFunc('�}�E�X�h���b�O', 'X1,Y1����X2,Y2��|Y2�܂�',    4230, cmd_mouse_drag,   '�}�E�X���h���b�O����','�܂����ǂ����');
  AddFunc('�}�E�X�E�h���b�O', 'X1,Y1����X2,Y2��|Y2�܂�',  4231, cmd_mouse_drag_r, '�}�E�X���E�h���b�O����','�܂����݂��ǂ����');
  AddFunc('�}�E�X�z�C�[����]', 'DIR��H|DIR��',      -1, cmd_mouse_wheel,       '�}�E�X�̃z�C�[��������DIR(�O,��)��Y�������B','�܂����ق��[�邩���Ă�');
  AddFunc('�}�E�X�E�`���g', '',             -1, cmd_mouse_tilt_r,  '�}�E�X�̃z�C�[�����E�Ƀ`���g����B','�܂����݂������');
  AddFunc('�}�E�X���`���g', '',             -1, cmd_mouse_tilt_l,  '�}�E�X�̃z�C�[�������Ƀ`���g����B','�܂����Ђ��肿���');

  //-�E�B���h�E����
  AddFunc('���A�N�e�B�u',  '{=?}A��|A��',         4204, cmd_active,   '�^�C�g��A�����E�B���h�E�̑����A�N�e�B�u�ɂ���B(���C���h�J�[�h�Ŏw��\)','�܂ǂ����Ă���');
  AddFunc('���ʒu�ړ�',    '{=?}A��X,Y��|Y��',    4205, cmd_winmove,  '�^�C�g��A�����E�B���h�E��X,Y�ֈړ�����BA���ȗ�����ƃA�N�e�B�u�ȃE�B���h�E��Ώۂɂ���B','�܂ǂ������ǂ�');
  AddFunc('���n���h������','{=?}A��|A��',         4208, cmd_findHandle,'�^�C�g��A�����E�B���h�E�̃n���h���𒲂ׂ�B(���C���h�J�[�h�Ŏw��\)','�܂ǂ͂�ǂ邯�񂳂�');
  AddFunc('���n���h�������ҋ@','{=?}A��SEC�܂�|A��',  4287, cmd_findHandleTime,'�^�C�g��A�����E�B���h�E�̃n���h�����ő�SEC�b�ԒT���āA������΃n���h����Ԃ��B(���C���h�J�[�h�Ŏw��\)','�܂ǂ͂�ǂ邯�񂳂�������');
  AddFunc('���n���h���L�[���M','{=?}HANDLE��S��|HANDLE��',  4209, cmd_sendKeysHandle, '�E�B���h�E�̃n���h��HANDLE�ɕ���S���L�[���M����B(�L�[���M�݊�)','�܂ǂ͂�ǂ邫�[��������');
  AddFunc('���n���h���L�[�������M','{=?}HANDLE��S��|HANDLE��',  4220, cmd_sendCharsHandle, '�E�B���h�E�̃n���h��HANDLE�ɕ���S�����̂܂ܑ��M����B(�L�[�������M�݊�)','�܂ǂ͂�ǂ邫�[������������');
  AddFunc('���n���h�����z�L�[���M','{=?}HANDLE��S��|HANDLE��',  4224, cmd_sendVKeysHandle, '�E�B���h�E�̃n���h��HANDLE�ɉ��z�L�[�R�[�h(����)�𑗐M����B(���z�L�[���M�݊�)','�܂ǂ͂�ǂ邩�������[��������');
  AddFunc('���A�N�e�B�u�n���h���擾',  '',        4213, cmd_getActive,   '���݃A�N�e�B�u�ȃE�B���h�E�̃n���h�����擾���ĕԂ��B','�܂ǂ����Ă��Ԃ͂�ǂ邵��Ƃ�');
  AddFunc('���A�N�e�B�u�^�C�g���擾',  '',        4214, cmd_getActiveTitle,   '���݃A�N�e�B�u�ȃE�B���h�E�̃^�C�g�����擾���ĕԂ��B','�܂ǂ����Ă��Ԃ����Ƃ邵��Ƃ�');
  AddFunc('���őO��',       '{=?}A��|A��',        4215, cmd_topmost,   '�^�C�g��A�����E�B���h�E�̑����őO�ʕ\���ɂ���B(���C���h�J�[�h�Ŏw��\)','�܂ǂ�������߂�');
  AddFunc('���őO�ʉ���',   '{=?}A��|A��',        4216, cmd_topmost_off,   '�^�C�g��A�����E�B���h�E�̑����őO�ʉ�������B(���C���h�J�[�h�Ŏw��\)','�܂ǂ�������߂񂩂�����');
  AddFunc('���n���h���e�L�X�g�ݒ�','{=?}HANDLE��S��|HANDLE��', 4217, cmd_setWinText,'HANDLE�̃E�B���h�E�Ƀe�L�X�gS��ݒ肷��','�܂ǂ͂�ǂ�Ă����Ƃ����Ă�');
  AddFunc('���n���h���e�L�X�g�擾','{=?}HANDLE��|HANDLE��|HANDLE����', 4218, cmd_getWinText,'HANDLE�̃E�B���h�E����e�L�X�g���擾����','�܂ǂ͂�ǂ�Ă����Ƃ���Ƃ�');
  AddFunc('���n���h���T�C�Y�擾','{=?}HANDLE��',      4263, cmd_win_getSize,'HANDLE�̃E�B���h�E�T�C�Y���擾���āuX1,Y1,X2,Y2�v�̌`���ŕԂ�','�܂ǂ͂�ǂ邳��������Ƃ�');
  AddFunc('���n���h���T�C�Y�ݒ�','{=?}HANDLE��SIZE��',4264, cmd_win_setSize,'HANDLE�̃E�B���h�E��SIZE�uX1,Y1,X2,Y2�v��ݒ肷��','�܂ǂ͂�ǂ邳���������Ă�');
  AddFunc('����','', 4275, cmd_enumWindow,'�E�B���h�E�n���h�����擾���ĕԂ�(handle,�N���X��,�e�L�X�g,id�̌`��)','�܂ǂ������');
  AddFunc('���n���h���e�擾','{=?}HANDLE��',4267, cmd_win_getParent,'HANDLE�̐e�E�B���h�E�𓾂�','�܂ǂ͂�ǂ邨�₵��Ƃ�');
  AddFunc('���n���h�����W����','{=?}X,Y��',4268, cmd_win_getXY,'X,Y�̃E�B���h�E�𓾂�','�܂ǂ͂�ǂ邴�Ђ傤���񂳂�');
  AddFunc('���n���h�������W����','{=?}X,Y��',4269, cmd_win_getXY_c,'X,Y�ɂ���q�E�B���h�E�𓾂�','�܂ǂ͂�ǂ�Ȃ����Ђ傤���񂳂�');
  AddFunc('���n���h������','{=?}HANDLE��|HANDLE��|HANDLE����', 4273, cmd_enumChildWindow,'HANDLE�̃E�B���h�E�ɂ���q�n���h�����擾���ĕԂ�(handle,�N���X��,�e�L�X�g,id�̌`��)','�܂ǂ͂�ǂ�Ȃ��������');
  AddFunc('���n���h��������','{=?}HANDLE����S��|HANDLE��', 4279, cmd_findChildWindow,'HANDLE�̃E�B���h�E�ɂ���^�C�g��S�̎q�n���h�����擾���ĕԂ�','�܂ǂ͂�ǂ�Ȃ����񂳂�');
  AddFunc('���n���h���ʒu�ړ�','{=?}HANDLE��X,Y��|Y��',    4274, cmd_handle_winmove,  'HANDLE�̃E�B���h�E��X,Y�ֈړ�����B','�܂ǂ͂�ǂ邢�����ǂ�');
  AddFunc('���n���h����','{=?}HANDLE��', 4276, cmd_flashWindow,'�E�B���h�E�n���h��HANDLE�����点��','�܂ǂ͂�ǂ�Ђ���');
  AddFunc('���n���h���A�N�e�B�u','{=?}HANDLE��|HANDLE��', 4277, cmd_handleActive,'�E�B���h�E�n���h��HANDLE���A�N�e�B�u�ɂ���','�܂ǂ͂�ǂ邠���Ă���');
  AddFunc('���n���h���N���b�N','{=?}HANDLE��|HANDLE��',4265, cmd_win_click,'HANDLE�̃E�B���h�E���N���b�N����(�N���b�N�I����ҋ@����)','�܂ǂ͂�ǂ邭�����');
  AddFunc('���n���h���E�N���b�N','{=?}HANDLE��|HANDLE��',4266, cmd_win_click_r,'HANDLE�̃E�B���h�E���E�N���b�N����','�܂ǂ͂�ǂ�݂��������');
  AddFunc('���n���h���񓯊��N���b�N','{=?}HANDLE��|HANDLE��',4278, cmd_win_click_a,'HANDLE�̃E�B���h�E���N���b�N����(�N���b�N�I����ҋ@���Ȃ��BPostMessage���g�p)','�܂ǂ͂�ǂ�Ђǂ����������');
  AddFunc('���n���h���l�擾','{=?}HANDLE��|HANDLE��',4281, cmd_getcursel,'HANDLE�̃E�B���h�E�̃J�[�\���C���f�b�N�X�𓾂�','�܂ǂ͂�ǂ邠��������Ƃ�');
  AddFunc('���n���h���l�ݒ�','{=?}HANDLE��V��|HANDLE��',4282, cmd_setcursel,'HANDLE�̃E�B���h�E�̃J�[�\���C���f�b�N�X�𓾂�','�܂ǂ͂�ǂ邠���������Ă�');
  AddFunc('���n���h���A�C�e�����擾','{=?}HANDLE��|HANDLE��',4283, cmd_wingetitemcount,'HANDLE�̃E�B���h�E�̃A�C�e�����𓾂�','�܂ǂ͂�ǂ邠���Ăނ�������Ƃ�');
  AddFunc('���n���h���A�C�e���擾','{=?}HANDLE��|HANDLE��',4284, cmd_wingetitems,'HANDLE�̃E�B���h�E�̃A�C�e���𓾂�','�܂ǂ͂�ǂ邠���Ăނ���Ƃ�');
  AddFunc('���n���h����ʍ��W�v�Z','{=?}HANDLE��X,Y��|Y��',4285, cmd_ClientToScreen,'HANDLE�̃E�B���h�E��X,Y���W���΍��W�ux,y�v�œ���','�܂ǂ͂�ǂ邪�߂񂴂Ђ傤��������');
  AddFunc('���n���h�����T�C�Y�擾','{=?}HANDLE��',4286, cmd_getClientRect,'HANDLE�̃E�B���h�E�̃N���C�A���g�T�C�Y���uX1,Y1,X2,Y2�v�̌`���ŕԂ�','�܂ǂ͂�ǂ�Ȃ�����������Ƃ�');

  //-WINDOWS�ċN���ƏI��
  AddFunc('WINDOWS�ċN��', '',         4250, cmd_restart,   'WINDOWS���ċN������','WINDOWS�������ǂ�');
  AddFunc('WINDOWS�I��',   '',         4251, cmd_poweroff,  'WINDOWS���I������',  'WINDOWS���イ��傤');
  AddFunc('WINDOWS���O�I�t',   '',     4270, cmd_logoff,    'WINDOWS�����O�I�t����',  'WINDOWS�낮����');
  AddFunc('WINDOWS�T�X�y���h', '',     4271, cmd_suspend,   'WINDOWS���T�X�y���h��Ԃɂ���',  'WINDOWS�����؂��');
  AddFunc('WINDOWS���O�I����ʕ\��', '',4272, cmd_showLogon,   'WINDOWS���O�I����ʂ�\������(�p�X���[�h�ɂ�郍�b�N���s��)',  'WINDOWS�낮���񂪂߂�Ђ傤��');
  AddFunc('WINDOWS�X�V�I��',   '',      4288, cmd_poweroff_update,  'WINDOWS�̍X�V���s������ŏI������',  'WINDOWS�������񂵂イ��傤');

  //-�o�b�e��
  AddFunc('AC�d�����','',4252, cmd_ac_check,  'AC�d���̏�Ԃ��擾����B�I��(=1)/�I�t(=0)��Ԃ��B�s���Ȃ�-1��Ԃ��B',  'AC�ł񂰂񂶂傤����');
  AddFunc('�o�b�e����Ԏ擾','',4253, cmd_get_battery,    '�o�b�e���̏�Ԃ��擾���āu��/��/�v���I/�[�d��/�Ȃ�/�s���v�̂����ꂩ��Ԃ��B',  '�΂��Ă肶�傤��������Ƃ�');
  AddFunc('�o�b�e���c�ʎ擾','',4254, cmd_get_battery_per,  '�o�b�e���c�ʂ��p�[�Z���g�ŕԂ��B�o�b�e�����Ȃ��ꍇ-1��Ԃ��B',  '�΂��Ă肴���傤����Ƃ�');

  //-CPU
  AddFunc('CPU�g�p���擾','',4255, cmd_cpu,  'CPU�̎g�p����K���Ɏ擾���ĕԂ�(����I�ɌĂяo���Ďg��)�B',  'CPU���悤�����Ƃ�');

  //-������
  AddFunc('�������g�p���擾','',4262, cmd_memoryusage,  '�������̎g�p�����擾���ĕԂ�',  '�߂��肵�悤�����Ƃ�');
  AddFunc('�������g�[�^���T�C�Y�擾','',4249, cmd_memory_status,  '���ݗ��p�\�ȕ����������Ɖ��z�������̗����Ɋւ�������擾���ĕԂ�',  '�߂���Ɓ[���邳��������Ƃ�');

  //-�v���Z�X�֘A
  AddFunc('�v���Z�X��','',4256, cmd_enumProcess, '�N�����Ă���v���Z�X��񋓂��ĕԂ�',  '�Ղ낹���������');
  AddFunc('�v���Z�X�����I��','S��',4257, cmd_killProcess, '�N�����Ă���v���Z�X(EXE���Ŏw��)�������I��������',  '�Ղ낹�����傤�������イ��傤');

  //-�Ǘ��Ҍ���
  AddFunc('�Ǘ��Ҍ����擾','',4258, cmd_IsUserAnAdmin, '�Ǘ��Ҍ������擾�ł������ǂ����Ԃ��B(XP�ȍ~�œ���)',  '����肵�Ⴏ�񂰂񂵂�Ƃ�');

  //-�z�b�g�L�[
  AddFunc('�z�b�g�L�[�o�^','KEY��EVENT��|KEY��EVENT��',4259, cmd_setHotkey, '�z�b�g�L�[��o�^����B���s�������֐�����v���O�����𕶎���EVENT���w�肷��B',  '�ق��Ƃ��[�Ƃ��낭');
  AddFunc('�z�b�g�L�[����','KEY��|KEY��',4260, cmd_removeHotkey, '�z�b�g�L�[KEY����������',  '�ق��Ƃ��[��������');

  //-GUID
  AddFunc('GUID����','',4261, cmd_createGUID, 'GUID�𐶐����ĕԂ�',  'GUID��������');

  //-nakoctrl.dll
  AddFunc('NAKOCTRL_DLL�o�[�W����','',4280, getNakoCtrlVersion, 'nakoctrl.dll�̃o�[�W������Ԃ�',  'NAKOCTRL_DLL�΁[�����');
  //</����>
end;

initialization

finalization
begin
  if FCpuUsage <> nil then FCpuUsage.Free;
  if hotkeys <> nil then hotkeys.Free;
end;


end.
