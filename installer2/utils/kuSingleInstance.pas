{**
 * 二重起動を禁止する
 *}
unit kuSingleInstance;

interface
uses
  Windows, Messages, SysUtils, mmsystem;

const
  UNIQUE_MUTEX_HEADER = 'com.kujirahand.kusingleton.';


procedure CheckMutex(MainFormClass: TClass);
procedure sendAllAppActiveMsg;


implementation

var
  hMutexOne     : Integer = 0;
  hWindow       : Integer = 0;
  res           : Boolean = False;
  FMainFormClass: TClass;


function KMutexNew(MutexName: string): Boolean;
var
  res     : Boolean;
  dwWait  : DWORD;
begin
  res    := False;
  dwWait := timeGetTime;
  // 終了待機
  while (timeGetTime - dwWait) < 500 do
  begin
    hMutexOne := CreateMutex(nil, False, PChar(MutexName));
    // もし失敗したら、すでにほかのインスタンスが存在する
    if (hMutexOne <> 0) and (GetLastError() = ERROR_ALREADY_EXISTS) then
    begin
      // 待機
      Sleep(100);
    end else
    begin
      // 成功
      res := True;
      Break;
    end;
  end;
  Result := res;
end;

procedure MutexOneFree;
begin
  try
    if (hMutexOne <> 0) then ReleaseMutex(hMutexOne);
    if (hMutexOne <> 0) then CloseHandle(hMutexOne);
    hMutexOne := 0;
  except
  end;
end;


function EnumWindowsAndSendMsgProc(Wnd: HWND; lParam: Longint): Bool; stdcall; export;
var
  s: string;
begin
  Result := True;
  SetLength(s,256);
  GetClassName(Wnd, @s[1], 255);
  s := PChar(s);
  // ---
  if LowerCase(s) = LowerCase(FMainFormClass.ClassName) then
  begin
    if IsIconic(hWindow) then ShowWindow(hWindow,SW_RESTORE);
    SetForeGroundWindow(Wnd);
  end;
end;

procedure sendAllAppActiveMsg;
begin
  EnumWindows(@EnumWindowsAndSendMsgProc, 0);
end;

procedure CheckMutex(MainFormClass: TClass);
begin
  FMainFormClass := MainFormClass;
  // ----- 起動待ち ----
  res := KMutexNew(UNIQUE_MUTEX_HEADER + FMainFormClass.ClassName);

  // 失敗したときは
  if res = False then
  begin
    // アクティブにする
    begin
      hWindow := Windows.FindWindow(PWideChar(FMainFormClass.ClassName), nil);
      if hWindow > 0 then
      begin
        if IsIconic(hWindow) then ShowWindow(hWindow,SW_RESTORE);
        SetForeGroundWindow(hWindow);
      end;
      Halt; // 強制終了
    end;
  end;
end;

initialization
begin
end;

finalization
begin
  MutexOneFree;
end;

end.

