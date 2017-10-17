unit unit_ctrl;

interface

uses
  Windows, Messages, SysUtils, Classes;


// handle to class name
function getClassNameStr(h:THandle): string;


// CapsLock
function GetCapsLock: Boolean;
procedure SetCapsLock(status: Boolean);
// NumLock
function GetNumLock: Boolean;
procedure SetNumLock(status: Boolean);

// Enum
function EnumChildWindowStr(handle: THandle): string;
function findChildWindow(parent: THandle; title: string): THandle;
function EnumWindowStr(handle: THandle): string;

// Window Text
function GetWindowTextStr(hWindow:HWND):string;
function getWindowValueInt(h:THandle): Integer;
procedure setWindowValueInt(h:THandle; v: Integer);
function getWindowItemCount(h:THandle): Integer;
function getWindowItems(handle:THandle): string;

implementation

uses Masks, CommonMemoryUnit;

const
  SB_GETTEXT        = WM_USER+2;
  SB_GETTEXTLENGTH  = WM_USER+3;
  SB_GETPARTS       = WM_USER+6;
  SB_ISSIMPLE       = WM_USER+14;

const
  {$EXTERNALSYM LVM_FIRST}
  LVM_FIRST               = $1000;      { ListView messages }
  LVM_GETITEMCOUNT        = LVM_FIRST + 4;
  LVM_GETITEMA            = LVM_FIRST + 5;
  LVM_SETITEMA            = LVM_FIRST + 6;
  LVM_GETITEMTEXTA         = LVM_FIRST + 45;

type
  tagLVITEMA = packed record
    mask: UINT;
    iItem: Integer;
    iSubItem: Integer;
    state: UINT;
    stateMask: UINT;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iImage: Integer;
    lParam: LPARAM;
    iIndent: Integer;
  end;
  TLVItem = tagLVITEMA;

function ListView_GetItemText(hwndLV: HWND; i, iSubItem: Integer;
  pszText: PChar; cchTextMax: Integer): Integer;
var
  Item: TLVItem;
begin
  Item.iSubItem := iSubItem;
  Item.cchTextMax := cchTextMax;
  Item.pszText := pszText;
  Result := SendMessage(hwndLV, LVM_GETITEMTEXTA, i, Longint(@Item));
end;

function getClassNameStr(h:THandle): string;
var
  cs: string;
begin
  SetLength(cs, 257);
  GetClassName(h, PChar(cs), 256);
  cs := PChar(cs);
  Result := cs;
end;

function getWindowValueInt(h:THandle): Integer;
var
  cs: string;
begin
  cs := getClassNameStr(h);
  if cs = 'ListBox' then
  begin
    Result := SendMessage(h, LB_GETCURSEL, 0, 0);
  end else
  if cs = 'ComboBox' then
  begin
    Result := SendMessage(h, CB_GETCURSEL, 0, 0);
  end else
  begin
    raise Exception.Create('Windowクラス"' + cs + '"には対応していません。');
  end;
end;

function getWindowItemCount(h:THandle): Integer;
var
  cs: string;
begin
  cs := getClassNameStr(h);
  if cs = 'ListBox' then
  begin
    Result := SendMessage(h, LB_GETCOUNT, 0, 0);
  end else
  if cs = 'ComboBox' then
  begin
    Result := SendMessage(h, CB_GETCOUNT, 0, 0);
  end else
  if cs = 'msctls_statusbar32' then
  begin
    Result := SendMessage(h, SB_GETPARTS,0 ,0);
  end else
  begin
    raise Exception.Create('Windowクラス"' + cs + '"には対応していません。');
  end;
end;

function getWindowItems(handle:THandle): string;
var
  res, cs, tmp: string;
  len, i, count: Integer;
  p: PChar;
  
  procedure _get_statusbar;
  var Buffer : PChar;
      i , PanelCount ,BufferSize ,TextLen : integer;
      SimpleMode : Boolean;
      s : string;
  var
    TempCM : TCommonMemory;
  begin
    s := '';
    SimpleMode := (SendMessage(Handle,SB_ISSIMPLE,0,0)<>0);
    PanelCount := SendMessage(Handle,SB_GETPARTS,0,0);
    for i := 0 to PanelCount-1 do
      begin
        BufferSize := 1 + LOWORD(SendMessage(Handle,SB_GETTEXTLENGTH,i,0));
        TempCM := GetCommonMemory(Handle,BufferSize);
        try
          GetMem(Buffer,BufferSize+1);
          try
            if (BufferSize = 1) then
              Buffer[0] := Char(0)
            else
            if (BufferSize > 1) then
            begin
              TextLen := LOWORD(SendMessage(Handle,SB_GETTEXT,i,LPARAM(TempCM.MemPtr)));
              if (BufferSize > TextLen) then
               begin
                 TempCM.Read(0,Buffer,TextLen);
                 Buffer[TextLen] := Char(0)
               end
                else
               begin
                 raise Exception.Create(
                   Format(
                   'Handle[%d]' + #13+#10 +
                   ' Roop[%d/%d]' + #13+#10 +
                   'エラー:BufferSize[%d] < TextLen[%d] '
                  ,[ Handle
                     , i+1 ,PanelCount
                     ,BufferSize,TextLen
                       ]));
                  Buffer[0] := Char(0);
                end;
            end;
            s := s + Buffer + #13+#10;
            if (SimpleMode) then Break;
          finally
             FreeMem(Buffer);
          end;
        finally
          TempCM.Free;
        end;
      end; // for
      res := s;
  end;

begin
  cs := getClassNameStr(handle);
  res := '';

  if cs = 'ListBox' then
  begin
    count := SendMessage(handle, LB_GETCOUNT, 0, 0);
    for i := 0 to count - 1 do
    begin
      len := SendMessage(handle, LB_GETTEXTLEN, WPARAM(i), 0);
      GetMem(p, len + 1);
      SendMessage(handle, LB_GETTEXT, WPARAM(i), LPARAM(p));
      System.SetString(tmp, p, len);
      FreeMem(p);
      res := res + tmp;
      if (i <> (count-1)) then res := res + #13#10;
    end;
  end else if cs = 'ComboBox' then
  begin
    count := SendMessage(handle, CB_GETCOUNT, 0, 0);
    for i := 0 to count - 1 do
    begin
      len := SendMessage(handle, CB_GETLBTEXTLEN, WPARAM(i), 0);
      GetMem(p, len + 1);
      SendMessage(handle, CB_GETLBTEXT, WPARAM(i), LPARAM(p));
      System.SetString(tmp, p, len);
      FreeMem(p);
      res := res + tmp;
      if (i <> (count-1)) then res := res + #13#10;
    end;
  end else if cs = 'SysListView32' then
  begin
    count := SendMessage(handle, LVM_GETITEMCOUNT, 0, 0);
    for i := 0 to count - 1 do
    begin
      GetMem(p, 4096);
      ListView_GetItemText(handle, i, 0, p, 4095);
      System.SetString(tmp, p, len);
      FreeMem(p);
      res := res + tmp;
      if (i <> (count-1)) then res := res + #13#10;
    end;
  end else
  if cs = 'msctls_statusbar32' then
  begin
    _get_statusbar;
  end else
  begin
    raise Exception.Create('Windowクラス"' + cs + '"には対応していません。');
  end;
  Result := res;
end;

procedure setWindowValueInt(h:THandle; v: Integer);
var
  cs: string;
begin
  cs := getClassNameStr(h);
  if cs = 'ListBox' then
  begin
    SendMessage(h, LB_SETCURSEL, v, 0);
  end else
  if cs = 'ComboBox' then
  begin
    SendMessage(h, CB_SETCURSEL, v, 0);
  end else
  begin
    raise Exception.Create('Windowクラス"' + cs + '"には対応していません。');
  end;
end;


function GetWindowTextStr(hWindow:HWND):string;
var
  p:PChar;
  ret:integer;
begin
  ret := GetWindowTextLength(hWindow);
  GetMem(p,ret+1);
  ret := GetWindowText(hWindow,p,ret+1);
  SetString(result,p,ret);
  FreeMem(p);
end;

function sub_EnumChildWindoProc( h: HWND; lp: LPARAM): BOOL; stdcall;
var
  ps, ts, s: string;
  pstr: PString;
begin
  Result := True; //Continue
  pstr := PString(lp);
  // クラス名
  SetLength(ps, 256);
  GetClassName(h, PChar(ps), 256);
  // テキスト
  ts := GetWindowTextStr(h);
  // ID
  s := IntToStr(GetWindowLong(h, GWL_ID));
  //------------------------------------------------------------------------
  //               handle              class                     text                     id
  pstr^ := pstr^ + IntToStr(h) + ',' + string(PChar(ps)) + ',' + string(PChar(ts)) + ',' + s + #13#10;
end;

function EnumChildWindowStr(handle: THandle): string;
begin
  Result := '';
  EnumChildWindows(handle, @sub_EnumChildWindoProc, Integer(@Result));
end;

var sub_findChildWindow_result: THandle = 0;

function sub_findChildWindow( h: HWND; lp: LPARAM): BOOL; stdcall;
var
  ps, ts: string;
  p_pattern: PString;
  pattern: string;
begin
  Result := True; //Continue
  p_pattern := PString(lp);
  pattern := p_pattern^;
  // クラス名
  SetLength(ps, 256);
  GetClassName(h, PChar(ps), 256);
  ps := PChar(ps);
  // テキスト
  ts := GetWindowTextStr(h);
  // 検索
  if
    (ps = pattern)or
    (ts = pattern)or
    MatchesMask(ps, pattern) or
    MatchesMask(ts, pattern)
  then
  begin
    sub_findChildWindow_result := h;
    Result := False;
  end;
end;

function findChildWindow(parent: THandle; title: string): THandle;
begin
  sub_findChildWindow_result := 0;
  EnumChildWindows(parent, @sub_findChildWindow, Integer(@title));
  Result := sub_findChildWindow_result;
end;

function sub_EnumWindowProc( h: HWND; lp: LPARAM): BOOL; stdcall;
var
  ps, ts, s: string;
  pstr: PString;
  txt: string;
begin
  Result := True; //Continue
  pstr := PString(lp);
  // クラス名
  SetLength(ps, 256);
  GetClassName(h, PChar(ps), 256);
  // テキスト
  ts := GetWindowTextStr(h);
  // ID
  s := IntToStr(GetWindowLong(h, GWL_ID));
  //------------------------------------------------------------------------
  //               handle              class                   text              id
  txt := string(PChar(ts));
  txt := StringReplace(txt, '"', '""', [rfReplaceAll]);
  pstr^ := pstr^ + IntToStr(h) + ',"' + string(PChar(ps)) + '","' + txt + '",' + s + #13#10;
end;


function EnumWindowStr(handle: THandle): string;
begin
  Result := '';
  EnumWindows(@sub_EnumWindowProc, Integer(@Result));
end;


function GetCapsLock: Boolean;
var
  keys: TKeyboardState;
begin
  // キーボードの状態を取得
  GetKeyboardState(keys);
  Result := (keys[VK_CAPITAL] > 0);
end;

procedure SetCapsLock(status: Boolean);
var
  o: TOSVersionInfo;
  keys: TKeyboardState;
begin
  // キーボードの状態を取得
  GetKeyboardState(keys);
  // 既にその状態なら抜ける
  if (keys[VK_CAPITAL] > 0) = status then Exit;

  // OSのバージョンを得る
  o.dwOSVersionInfoSize := sizeof(o);
  GetVersionEx(o);

  if o.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS then //=== Win95/98
  begin
    keys[VK_CAPITAL] := 1;
    SetKeyboardState(keys);
  end else if o.dwPlatformId = VER_PLATFORM_WIN32_NT then //=== WinNT
  begin
    //Simulate Key Press
    keybd_event(VK_CAPITAL, $45, KEYEVENTF_EXTENDEDKEY or 0, 0);
    //Simulate Key Release
    keybd_event(VK_CAPITAL, $45, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0);
  end;

end;

function GetNumLock: Boolean;
var
  keys: TKeyboardState;
begin
  // キーボードの状態を取得
  GetKeyboardState(keys);
  Result := (keys[VK_NUMLOCK] > 0);
end;

procedure SetNumLock(status: Boolean);
var
  o: TOSVersionInfo;
  keys: TKeyboardState;
begin
  // キーボードの状態を取得
  GetKeyboardState(keys);
  // 既にその状態なら抜ける
  if (keys[VK_NUMLOCK] > 0) = status then Exit;

  // OSのバージョンを得る
  o.dwOSVersionInfoSize := sizeof(o);
  GetVersionEx(o);

  if o.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS then //=== Win95/98
  begin
    keys[VK_NUMLOCK] := 1;
    SetKeyboardState(keys);
  end else if o.dwPlatformId = VER_PLATFORM_WIN32_NT then //=== WinNT
  begin
    //Simulate Key Press
    keybd_event(VK_NUMLOCK, $45, KEYEVENTF_EXTENDEDKEY or 0, 0);
    //Simulate Key Release
    keybd_event(VK_NUMLOCK, $45, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0);
  end;

end;

end.
