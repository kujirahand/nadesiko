unit dll_ctrl_function;

interface

uses
  Windows, messages, vbfunc, WinRestartUnit, Classes, ActiveX, mmsystem;

const
  NAKOCTRL_DLL_VERSION = '1.5072';

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
  // 結果
  Result := nil;

  // 引数の取得
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
  // 結果
  Result := nil;

  // 引数の取得
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
  // 結果
  Result := nil;

  // 引数の取得
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
  // 結果
  Result := nil;

  // 引数の取得
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
  // 結果
  Result := nil;

  // 引数の取得
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
  // 結果
  Result := nil;

  // 引数の取得
  pa := nako_getFuncArg(h, 0);
  if pa = nil then pa := nako_getSore;

  AppActivate(hi_str(pa), hi_str(pa), hi_int(pa));
end;

function cmd_handleActive(h:DWORD): PHiValue; stdcall;
var
  handle: THandle;
begin
  // 結果
  Result := nil;

  // 引数の取得
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
  // トップウィンドウを得る
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
  // 結果
  Result := nil;

  // 引数の取得
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
  // 結果
  Result := nil;

  // 引数の取得
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
    nako_evalEx('0.3秒待つ', ret);
    if ret <> nil then nako_var_free(ret);
  end;
end;

function cmd_sendKeysHandle(h: DWORD): PHiValue; stdcall;
var
  s: string;
  handle: THandle;
begin
  // 結果
  Result := nil;

  // 引数の取得
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
  // 結果
  Result := nil;

  // 引数の取得
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
  // 結果
  Result := nil;

  // 引数の取得
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
  // 結果
  Result := nil;
  WindowsRestart;
end;

function cmd_poweroff(h: DWORD): PHiValue; stdcall;
begin
  // 結果
  Result := nil;
  WindowsPowerOff;
end;

function cmd_showLogon(h: DWORD): PHiValue; stdcall;
begin
  // 結果
  Result := nil;
  WindowsShowLogonScreen;
end;


function cmd_logoff(h: DWORD): PHiValue; stdcall;
begin
  // 結果
  Result := nil;
  WindowsLogOff;
end;

function cmd_suspend(h: DWORD): PHiValue; stdcall;
begin
  // 結果
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
  mouse_event($4,0,0,0,0);// 左ボタンをUP
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
  // 結果
  Result := nil;
  //
  px := nako_getFuncArg(h, 0);
  py := nako_getFuncArg(h, 1);
  SetCursorPos(hi_int(px), hi_int(py));
end;

function cmd_mouse_click(h: DWORD): PHiValue; stdcall;
begin
  // 結果
  Result := nil;

  mouse_event(MOUSEEVENTF_LEFTDOWN,
    MOUSEEVENTF_ABSOLUTE, MOUSEEVENTF_ABSOLUTE, 0, 0);
  mouse_event(MOUSEEVENTF_LEFTUP,
    MOUSEEVENTF_ABSOLUTE, MOUSEEVENTF_ABSOLUTE, 0, 0);

end;

function cmd_mouse_r_click(h: DWORD): PHiValue; stdcall;
begin
  // 結果
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
  // 結果
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
  // 結果
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

//バッテリ
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
    Result := hi_newInt(-1); // 不明
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
      1: Result := hi_newStr('高');
      2: Result := hi_newStr('低');
      4: Result := hi_newStr('致命的');
      8: Result := hi_newStr('充電中');
    128: Result := hi_newStr('なし');
    255: Result := hi_newStr('不明');
    else Result := hi_newStr('不明');
    end;
  end else
  begin
    Result := hi_newStr('不明');
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

var FCpuUsage: TCpuUsage = nil; // GLOBAL なので Singleton で使う

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
    // 適当に計測(NT系の場合) --->
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

{
AddFunc('プロセス列挙','',4256, cmd_enumProcess, '起動しているプロセスを列挙して返す',  'ぷろせすれっきょ');
AddFunc('プロセス強制終了','Sの',4257, cmd_killProcess, '起動しているプロセス(EXE名で指定)を強制終了させる',  'ぷろせすきょうせいしゅうりょう');
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
    raise Exception.Create('GUID生成に失敗');
  end;
  s := GUIDToString(g);
  s := Copy(s, 2, Length(s) - 2);
  Result := hi_newStr(s);
end;

{
// しらたまさんのプラグインの方が便利なので廃止
- uses DdeMan
- AddFunc('DDE送信','SERVERのTOPICにSを',0, cmd_dde_send, 'DDEでSEVERのTOPICに文字列Sを送信し結果を得る', 'DDEそうしん');
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
      raise Exception.Create('DDEコマンドの送信に失敗');
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
  //todo: 命令の定義
  //<命令>

  //+ソフト制御/OS/プロセス(nakoctrl.dll)
  //-キー操作
  AddFunc('キー送信',     '{=?}AにSを|Aへ', 4200, cmd_sendKeys, 'タイトルAを持つウィンドウに文字Sをキー送信する。Aを省略するとアクティブなウィンドウへ送信。(VB互換)','きーそうしん');
  AddFunc('キー文字送信',     '{=?}AにSを|Aへ', 4219, cmd_sendChars, 'タイトルAを持つウィンドウに文字Sをそのまま送信する。特殊キーは送信できない。Aを省略するとアクティブなウィンドウへ送信。','きーもじそうしん');
  AddFunc('仮想キー送信',     '{=?}AにSを|Aへ', 4223, cmd_sendVKeys, 'タイトルAを持つウィンドウに仮想キーコード(整数)を送信する。Aを省略するとアクティブなウィンドウへ送信。','かそうきーそうしん');
  AddFunc('CAPSLOCK設定', '{=?}Aに',        4206, cmd_capslock, 'CapsLockの状態をA(ON/OFF)にする。','CAPSLOCKせってい');
  AddFunc('CAPSLOCK取得', '',               4207, cmd_capslock_get, 'CapsLockの状態を得る','CAPSLOCKしゅとく');
  AddFunc('NUMLOCK設定', '{=?}Aに',        4210, cmd_numlock, 'NumLockの状態をA(ON/OFF)にする。','NUMLOCKせってい');
  AddFunc('NUMLOCK取得', '',               4211, cmd_numlock_get, 'NumLockの状態を得る','NUMLOCKしゅとく');

  //-マウス操作
  AddFunc('マウス移動', 'X,Yへ|Yに',        4201, cmd_movexy,       'マウスをX,Yへ移動する。','まうすいどう');
  AddFunc('マウスクリック', '',             4202, cmd_mouse_click,  'マウスをクリックさせる。','まうすくりっく');
  AddFunc('マウス右クリック', '',           4203, cmd_mouse_r_click,'マウスを右クリックさせる。','まうすみぎくりっく');
  AddFunc('机上マウスX', '',                4221, cmd_getMouseX,    'デスクトップ上でのマウスX座標を返す','きじょうまうすX');
  AddFunc('机上マウスY', '',                4222, cmd_getMouseY,    'デスクトップ上でのマウスY座標を返す','きじょうまうすY');
  AddFunc('マウスドラッグ', 'X1,Y1からX2,Y2へ|Y2まで',    4230, cmd_mouse_drag,   'マウスをドラッグする','まうすどらっぐ');
  AddFunc('マウス右ドラッグ', 'X1,Y1からX2,Y2へ|Y2まで',  4231, cmd_mouse_drag_r, 'マウスを右ドラッグする','まうすみぎどらっぐ');

  //-ウィンドウ操作
  AddFunc('窓アクティブ',  '{=?}Aを|Aの',         4204, cmd_active,   'タイトルAを持つウィンドウの窓をアクティブにする。(ワイルドカードで指定可能)','まどあくてぃぶ');
  AddFunc('窓位置移動',    '{=?}AをX,Yへ|Yに',    4205, cmd_winmove,  'タイトルAを持つウィンドウをX,Yへ移動する。Aを省略するとアクティブなウィンドウを対象にする。','まどいちいどう');
  AddFunc('窓ハンドル検索','{=?}Aを|Aの',         4208, cmd_findHandle,'タイトルAを持つウィンドウのハンドルを調べる。(ワイルドカードで指定可能)','まどはんどるけんさく');
  AddFunc('窓ハンドル検索待機','{=?}AをSECまで|Aの',  4287, cmd_findHandleTime,'タイトルAを持つウィンドウのハンドルを最大SEC秒間探して、見つかればハンドルを返す。(ワイルドカードで指定可能)','まどはんどるけんさくたいき');
  AddFunc('窓ハンドルキー送信','{=?}HANDLEにSを|HANDLEへ',  4209, cmd_sendKeysHandle, 'ウィンドウのハンドルHANDLEに文字Sをキー送信する。(キー送信互換)','まどはんどるきーそうしん');
  AddFunc('窓ハンドルキー文字送信','{=?}HANDLEにSを|HANDLEへ',  4220, cmd_sendCharsHandle, 'ウィンドウのハンドルHANDLEに文字Sをそのまま送信する。(キー文字送信互換)','まどはんどるきーもじそうしん');
  AddFunc('窓ハンドル仮想キー送信','{=?}HANDLEにSを|HANDLEへ',  4224, cmd_sendVKeysHandle, 'ウィンドウのハンドルHANDLEに仮想キーコード(整数)を送信する。(仮想キー送信互換)','まどはんどるかそうきーそうしん');
  AddFunc('窓アクティブハンドル取得',  '',        4213, cmd_getActive,   '現在アクティブなウィンドウのハンドルを取得して返す。','まどあくてぃぶはんどるしゅとく');
  AddFunc('窓アクティブタイトル取得',  '',        4214, cmd_getActiveTitle,   '現在アクティブなウィンドウのタイトルを取得して返す。','まどあくてぃぶたいとるしゅとく');
  AddFunc('窓最前面',       '{=?}Aを|Aの',        4215, cmd_topmost,   'タイトルAを持つウィンドウの窓を最前面表示にする。(ワイルドカードで指定可能)','まどさいぜんめん');
  AddFunc('窓最前面解除',   '{=?}Aを|Aの',        4216, cmd_topmost_off,   'タイトルAを持つウィンドウの窓を最前面解除する。(ワイルドカードで指定可能)','まどさいぜんめんかいじょ');
  AddFunc('窓ハンドルテキスト設定','{=?}HANDLEにSを|HANDLEへ', 4217, cmd_setWinText,'HANDLEのウィンドウにテキストSを設定する','まどはんどるてきすとせってい');
  AddFunc('窓ハンドルテキスト取得','{=?}HANDLEの|HANDLEを|HANDLEから', 4218, cmd_getWinText,'HANDLEのウィンドウからテキストを取得する','まどはんどるてきすとしゅとく');
  AddFunc('窓ハンドルサイズ取得','{=?}HANDLEの',      4263, cmd_win_getSize,'HANDLEのウィンドウサイズを取得して「X1,Y1,X2,Y2」の形式で返す','まどはんどるさいずしゅとく');
  AddFunc('窓ハンドルサイズ設定','{=?}HANDLEにSIZEを',4264, cmd_win_setSize,'HANDLEのウィンドウにSIZE「X1,Y1,X2,Y2」を設定する','まどはんどるさいずせってい');
  AddFunc('窓列挙','', 4275, cmd_enumWindow,'ウィンドウハンドルを取得して返す(handle,クラス名,テキスト,idの形式)','まどれっきょ');
  AddFunc('窓ハンドル親取得','{=?}HANDLEの',4267, cmd_win_getParent,'HANDLEの親ウィンドウを得る','まどはんどるおやしゅとく');
  AddFunc('窓ハンドル座標検索','{=?}X,Yの',4268, cmd_win_getXY,'X,Yのウィンドウを得る','まどはんどるざひょうけんさく');
  AddFunc('窓ハンドル内座標検索','{=?}X,Yの',4269, cmd_win_getXY_c,'X,Yにある子ウィンドウを得る','まどはんどるないざひょうけんさく');
  AddFunc('窓ハンドル内列挙','{=?}HANDLEの|HANDLEを|HANDLEから', 4273, cmd_enumChildWindow,'HANDLEのウィンドウにある子ハンドルを取得して返す(handle,クラス名,テキスト,idの形式)','まどはんどるないれっきょ');
  AddFunc('窓ハンドル内検索','{=?}HANDLEからSを|HANDLEの', 4279, cmd_findChildWindow,'HANDLEのウィンドウにあるタイトルSの子ハンドルを取得して返す','まどはんどるないけんさく');
  AddFunc('窓ハンドル位置移動','{=?}HANDLEをX,Yへ|Yに',    4274, cmd_handle_winmove,  'HANDLEのウィンドウをX,Yへ移動する。','まどはんどるいちいどう');
  AddFunc('窓ハンドル光','{=?}HANDLEの', 4276, cmd_flashWindow,'ウィンドウハンドルHANDLEを光らせる','まどはんどるひかる');
  AddFunc('窓ハンドルアクティブ','{=?}HANDLEを|HANDLEの', 4277, cmd_handleActive,'ウィンドウハンドルHANDLEをアクティブにする','まどはんどるあくてぃぶ');
  AddFunc('窓ハンドルクリック','{=?}HANDLEを|HANDLEの',4265, cmd_win_click,'HANDLEのウィンドウをクリックする(クリック終了を待機する)','まどはんどるくりっく');
  AddFunc('窓ハンドル右クリック','{=?}HANDLEを|HANDLEの',4266, cmd_win_click_r,'HANDLEのウィンドウを右クリックする','まどはんどるみぎくりっく');
  AddFunc('窓ハンドル非同期クリック','{=?}HANDLEを|HANDLEの',4278, cmd_win_click_a,'HANDLEのウィンドウをクリックする(クリック終了を待機しない。PostMessageを使用)','まどはんどるひどうきくりっく');
  AddFunc('窓ハンドル値取得','{=?}HANDLEを|HANDLEの',4281, cmd_getcursel,'HANDLEのウィンドウのカーソルインデックスを得る','まどはんどるあたいしゅとく');
  AddFunc('窓ハンドル値設定','{=?}HANDLEにVを|HANDLEへ',4282, cmd_setcursel,'HANDLEのウィンドウのカーソルインデックスを得る','まどはんどるあたいしゅとく');
  AddFunc('窓ハンドルアイテム数取得','{=?}HANDLEを|HANDLEの',4283, cmd_wingetitemcount,'HANDLEのウィンドウのアイテム数を得る','まどはんどるあいてむすうしゅとく');
  AddFunc('窓ハンドルアイテム取得','{=?}HANDLEを|HANDLEの',4284, cmd_wingetitems,'HANDLEのウィンドウのアイテムを得る','まどはんどるあいてむしゅとく');
  AddFunc('窓ハンドル画面座標計算','{=?}HANDLEのX,Yを|Yで',4285, cmd_ClientToScreen,'HANDLEのウィンドウのX,Y座標を絶対座標「x,y」で得る','まどはんどるがめんざひょうけいさん');
  AddFunc('窓ハンドル内サイズ取得','{=?}HANDLEの',4286, cmd_getClientRect,'HANDLEのウィンドウのクライアントサイズを「X1,Y1,X2,Y2」の形式で返す','まどはんどるないさいずしゅとく');

  //-WINDOWS再起動と終了
  AddFunc('WINDOWS再起動', '',         4250, cmd_restart,   'WINDOWSを再起動する','WINDOWSさいきどう');
  AddFunc('WINDOWS終了',   '',         4251, cmd_poweroff,  'WINDOWSを終了する',  'WINDOWSしゅうりょう');
  AddFunc('WINDOWSログオフ',   '',     4270, cmd_logoff,    'WINDOWSをログオフする',  'WINDOWSろぐおふ');
  AddFunc('WINDOWSサスペンド', '',     4271, cmd_suspend,   'WINDOWSをサスペンド状態にする',  'WINDOWSさすぺんど');
  AddFunc('WINDOWSログオン画面表示', '',4272, cmd_showLogon,   'WINDOWSログオン画面を表示する(パスワードによるロックを行う)',  'WINDOWSろぐおんがめんひょうじ');

  //-バッテリ
  AddFunc('AC電源状態','',4252, cmd_ac_check,  'AC電源の状態を取得する。オン(=1)/オフ(=0)を返す。不明なら-1を返す。',  'ACでんげんじょうたい');
  AddFunc('バッテリ状態取得','',4253, cmd_get_battery,    'バッテリの状態を取得して「高/低/致命的/充電中/なし/不明」のいずれかを返す。',  'ばってりじょうたいしゅとく');
  AddFunc('バッテリ残量取得','',4254, cmd_get_battery_per,  'バッテリ残量をパーセントで返す。バッテリがない場合-1を返す。',  'ばってりざんりょうしゅとく');

  //-CPU
  AddFunc('CPU使用率取得','',4255, cmd_cpu,  'CPUの使用率を適当に取得して返す(定期的に呼び出して使う)。',  'CPUしようりつしゅとく');

  //-メモリ
  AddFunc('メモリ使用率取得','',4262, cmd_memoryusage,  'メモリの使用率を取得して返す',  'めもりしようりつしゅとく');

  //-プロセス関連
  AddFunc('プロセス列挙','',4256, cmd_enumProcess, '起動しているプロセスを列挙して返す',  'ぷろせすれっきょ');
  AddFunc('プロセス強制終了','Sの',4257, cmd_killProcess, '起動しているプロセス(EXE名で指定)を強制終了させる',  'ぷろせすきょうせいしゅうりょう');

  //-管理者権限
  AddFunc('管理者権限取得','',4258, cmd_IsUserAnAdmin, '管理者権限が取得できたかどうか返す。(XP以降で動作)',  'かんりしゃけんげんしゅとく');

  //-ホットキー
  AddFunc('ホットキー登録','KEYにEVENTを|KEYでEVENTを',4259, cmd_setHotkey, 'ホットキーを登録する。実行したい関数名やプログラムを文字列EVENTを指定する。',  'ほっときーとうろく');
  AddFunc('ホットキー解除','KEYを|KEYの',4260, cmd_removeHotkey, 'ホットキーKEYを解除する',  'ほっときーかいじょ');

  //-GUID
  AddFunc('GUID生成','',4261, cmd_createGUID, 'GUIDを生成して返す',  'GUIDせいせい');

  //-nakoctrl.dll
  AddFunc('NAKOCTRL_DLLバージョン','',4280, getNakoCtrlVersion, 'nakoctrl.dllのバージョンを返す',  'NAKOCTRL_DLLばーじょん');
  //</命令>
end;

initialization

finalization
begin
  if FCpuUsage <> nil then FCpuUsage.Free;
  if hotkeys <> nil then hotkeys.Free;
end;


end.
