unit vbfunc;

(***********************************************************************
    vbfunc.pas - VB Like Functions for Delphi 2.0J Ver.0.10

    VBの関数のうち比較的要望が高いと思われるものをDelphiで実現する事
    で、VBユーザのDelphiへの移行を促進することにつながればと思い、本
    ユニットを作成しました。現段階でサポートしているのは以下の関数群
    です。

    Shell         指定した実行可能プログラムを起動する
    AppActivate   指定されたアプリケーションをアクティブにする
    SendKeys      キーストローク列をアクティブ ウィンドウに渡す

                  Copyright(C) 1996 七☆星 (NIFTY-Serve SGM02275)
***********************************************************************)

interface

const
  vbHide             = 0;
  vbNormalFocus      = 1;
  vbMinimizedFocus   = 2;
  vbMaximizedFocus   = 3;
  vbNormalNoFocus    = 4;
  vbMinimizedNoFocus = 6;

function Shell(PathName: string; WindowStyle: Integer): Integer;
function AppFind(Title, Name: string; ProcessId: Integer): THandle;
function AppActivate(Title, Name: string; ProcessId: Integer): Boolean;
function SendKeys(KeyStr: string; Wait: Boolean): Boolean;
function SendKeysVBA(KeyStr: string; Wait: Boolean): Boolean;
function SendKeysVB6(KeyStr: string; Wait: Boolean): Boolean;
function SendChars(KeyStr: string; Wait: Boolean): Boolean;
function WaitHandleActive(h: THandle; timeout:Integer=1000*2): Boolean;

implementation

uses
  Windows, Messages, SysUtils, EasyMasks;

(***********************************************************************
  Shell         指定した実行可能プログラムを起動する

  function Shell(PathName: string; WindowStyle: Integer): Integer;

  引数          内容
  --------------------------------------------------------------------
  PathName      実行するプログラム名及び必要な引数名またはコマンドライ
                ンスイッチを指定します。
  WindowStyle   プログラムを実行するときのウィンドウの形式を指定します。
                既定値以外の値を指定すると、この値は無視されます。

  WindowStyleには以下の値が指定できます。

  定数              値 内容
  --------------------------------------------------------------------
  vbHide             0 フォーカスを持ち隠されたウィンドウ
  vbNormalFocus      1 フォーカスを持ち元のサイズと位置に表示されてい
                       るウィンドウ
  vbMinimizedFocus   2 フォーカスを持ち最小化されるウィンドウ
  vbMaximizedFocus   3 フォーカスを持ち最大化されるウィンドウ
  vbNormalNoFocus    4 最後にウィンドウを閉じたときのサイズと位置に復
                       元されるウィンドウ
                       (現在アクティブなウィンドウはアクティブのまま)
  vbMinimizedNoFocus 6 アイコンとして表示されているウィンドウ
                       (現在アクティブなウィンドウはアクティブのまま)

  解説
  指定したプログラムが実行されるとプログラムのプロセスIDが返されます。
  プロセスIDは実行中のプログラムを識別する重複しない番号です。指定され
  たプログラムが実行できない場合は0を返します。
  Shell関数は、生成されたプロセスがアイドル状態になるまで(最大10秒)待
  ちます。

  例
  AppID := Shell('c:\windows\notepad.exe', vbNormalFocus);
***********************************************************************)

{ Shell関数 }
function Shell(PathName: string; WindowStyle: Integer): Integer;
const
  ShowCommands: array [0..6] of Integer =
    (SW_HIDE, SW_SHOWNORMAL, SW_SHOWMINIMIZED, SW_SHOWMAXIMIZED,
    SW_SHOWNOACTIVATE, SW_SHOWDEFAULT, SW_SHOWMINNOACTIVE);
var
  Si: TStartupInfo;
  Pi: TProcessInformation;
begin
  Result := 0;
  GetStartupInfo(Si);
  if (0 <= WindowStyle) and (WindowStyle <= 6) then
  begin
    { 起動時のウィンドウ形式を設定 }
    Si.dwFlags := Si.dwFlags or STARTF_USESHOWWINDOW;
    Si.wShowWindow := ShowCommands[WindowStyle];
  end;
  { 指定されたプログラムの起動 }
  if CreateProcess(nil, PChar(PathName), nil, nil, False,
      CREATE_DEFAULT_ERROR_MODE, nil, nil, Si, Pi) then
  begin
    { 生成したプロセスがアイドルになるまで(最大10秒)待つ }
    WaitForInputIdle(Pi.hProcess, 10000);
    { 成功した場合はプロセスIDを返す }
    Result := Pi.dwProcessId;
    { プロセスハンドルを閉じる }
    CloseHandle(Pi.hProcess);
  end;
end;

(***********************************************************************
  AppActivate   指定されたアプリケーションをアクティブにする

  function AppActivate(Title, Name: string; ProcessId: Integer): Boolean;

  引数          内容
  --------------------------------------------------------------------
  Title         アクティブにしたいアプリケーションウィンドウのタイトル
                バー文字列を指定します。完全に一致するウィンドウが見つ
                からなかった場合はTitleで始まるウィンドウを探します。
                Titleを指定しない場合、この引数は''の様に記述します。
  Name          アプリケーションをクラス名で探す場合、ここにアプリケー
                ションのメインウィンドウのクラス名を指定します。ウィン
                ドウのクラス名はDelphiに付属のWinSight等で調べる事がで
                きます。Nameを指定しない場合、この引数は''の様に記述し
                ます。
  ProcessId     アクティブにしたいアプリケーションのプロセスIDを指定し
                します。Title及びNameを指定した場合はこの値は無視され
                ます。Shell関数によってアプリケーションを起動した場合、
                ここにその戻り値を指定することができます。

  解説
  指定されたアプリケーションが見つかった場合、そのアプリケーションを
  アクティブにして真(True)を返します。見つからなかった場合は偽(False)
  を返します。

  例
  AppID := Shell('notepad.exe', vbNormalFocus);
  AppActivate('', '', AppID);
***********************************************************************)
type
  TApp = record         { ウィンドウ識別構造体 }
    Wnd: HWnd;          { ウィンドウハンドル   }
    ProcessId: Integer; { プロセスID           }
    Title: string;      { ウィンドウタイトル   }
  end;

{ 目的のウィンドウを探すコールバック関数 }
function EnumWindowsProc(Wnd: HWND; lParam: Longint): Bool; stdcall; export;
var
  Pid{, Tid}: Integer;
  Title: string;
  AppTitle: PChar;
  pApp: ^TApp;
begin
  Result := True;
  pApp := Pointer(lParam);  { ウィンドウ識別構造体を取得 }

  if pApp^.Title <> '' then { タイトルが指定されている場合 }
  begin
    if IsWindowVisible(Wnd) = False then Exit;
    { 指定されたタイトルで始まっているかを調べる }
    SetLength(Title, 512);
    GetWindowText(Wnd, PChar(Title), Length(Title));

    AppTitle := PChar(pApp^.Title);
    Title    := PChar(Title);

    if (AppTitle = Title) or
       (EasyMasks.MatchesMask(Title, AppTitle)) then
    begin
      pApp^.Wnd := Wnd;     { ウィンドウハンドルを保存 }
      Result := False;      { 検索を終了               }
    end;
    
  end
  else                      { タイトルが指定されていない場合 }
  begin
    { 指定されたプロセスIDと一致するかを調べる }
    {Tid := }GetWindowThreadProcessId(Wnd, @Pid);
    if Pid = pApp^.ProcessId then
    begin
      pApp^.Wnd := Wnd;     { ウィンドウハンドルを保存 }
      Result := False;      { 検索を終了               }
    end;
  end;
end;

{ AppActivate関数 }

function AppFind(Title, Name: string; ProcessId: Integer): THandle;
var
  App: TApp;
  pName, pTitle: PChar;
begin
  App.Wnd := 0;
  App.Title := Title;
  App.ProcessId := ProcessId;
  if Title = '' then pTitle := nil else pTitle := PChar(Title);
  if Name  = '' then pName  := nil else pName  := PChar(Name);

  if (Title <> '') or (Name <> '') then
    App.Wnd := FindWindow(pName, pTitle);

  if App.Wnd = 0 then
    EnumWindows(@EnumWindowsProc, Longint(@App));

  Result := App.Wnd;
end;

function WaitHandleActive(h: THandle; timeout:Integer): Boolean;
var
  cnt: Integer;
  ha: THandle;
begin
  Result := True;
  cnt := 0;

  SetForegroundWindow(h);
  ha := GetForegroundWindow;

  while ha <> h do
  begin
    sleep(10); Inc(cnt, 10);
    if cnt > timeout then
    begin
      Result := False; Exit;
    end;
    ha := GetForegroundWindow;
  end;
end;

function AppActivate(Title, Name: string; ProcessId: Integer): Boolean;
var
  h: THandle;
begin

  h := AppFind(Title, Name, ProcessID);
  if h <> 0 then Result := WaitHandleActive(h) else Result := False;
end;

(***********************************************************************
  SendKeys      キーストローク列をアクティブウィンドウに渡す

  function SendKeys(KeyStr: string; Wait: Boolean): Boolean;

  引数          内容
  --------------------------------------------------------------------
  KeyStr        転送するキーストローク列を表す文字列式を指定します。
  Wait          転送によって行われる処理が終了するまで実行を一時中断
                するかどうかを指定します。現バージョンではこの引数は
                無視されます。

  解説
  KeyStrを指定する場合、通常のキーはそのまま文字列として指定します。
  例えば'ABC'の様にします。
  '+'、'^'、'%'、'~'、'('、')'、'{'、'}'はそれぞれSendKeys関数では特
  別な意味を持っています。これらの文字を渡すには、中かっこ'{}'で囲ん
  で指定します。たとえば'+'は'{+}'のように指定します。

  キーを押したときに表示されない文字(EnterキーやTabキーなど)や、文字
  ではなく動作を表現するキーを指定する場合は、次に示す表現を使います。
  {IME}はオマケです。

  キー          表現
  --------------------------------------------------------------------
  BackSpace     {BACKSPACE},{BS}または{BKSP}
  Tab           {TAB}
  Ctrl+Break    {BREAK}
  Enter	        {ENTER} または ~
  Home,End      {HOME},{END}
  Esc,Help      {ESC},{HELP}
  Ins           {INSERT}
  Del           {DELETE}または{DEL}
  ↑,↓,←,↑   {UP},{DOWN},{LEFT},{RIGHT}
  PrintScreen	{PRTSC}
  PageDown	{PGDN}
  PageUp	{PGUP}
  CapsLock      {CAPSLOCK}
  NumLock	{NUMLOCK}
  ScrollLock	{SCROLLLOCK}
  F1～F16	{F1}...{F16}
  ALT+全角/半角 {IME}

  Shiftキー、Ctrlキー、Altキーと他のキーとの組み合わせを指定する場合
  は、通常のキー表現の前に次のキー表現を単独、または組み合わせて記述
  します。

  キー          表現
  --------------------------------------------------------------------
  Shift         +
  Ctrl          ^
  Alt           %
  Win           &

  Shiftキー、Ctrlキー、Altキーを押した状態で、他のキーを連続して押す
  操作を指定するには、連続するキー操作をかっこ()で囲みます。例えば、
  Altキーを押しながら'F'と'X'を押す操作の場合は'%(AF)'の様にします。

  同じキーストロークの繰り返しを指定するには'{Key Number}'という表現
  を使います。たとえば'{RIGHT 10}'は'→'を10回、'{- 40}'は'-'を40回
  押すことを意味します。

  (注)
  SendKeys関数でPrintScreenキーを送った場合、アクティブウィンドウの
  スナップショットがクリップボードにコピーされますが、アプリケーショ
  ンはそのキーを受け取ることは出来ません。

  例
  if AppActivate('', 'Notepad', 0) then
    SendKeys('ABC日本語DEF{ENTER}', True);
***********************************************************************)
const
  MAXSPECIALKEY_VBA = 38;  { 特殊キー構造体配列の要素数 }
  MAXSPECIALKEY_VB6 = 3;   { 特殊キー構造体配列の要素数 }
  MAXSPECIALKEY_EXT = 31;  { 特殊キー構造体配列の要素数 }
  VK_IME            = 25;  { IMEのオンオフを切り替える  }

type
  TSpecialKey = record { 特殊キー構造体 }
    VKey: Byte;        { 仮想キーコード }
    Name: PChar;       { 表現する文字列 }
  end;

var
  { 特殊キー構造体配列 }
  SpecialKeysVBA: array [0..MAXSPECIALKEY_VBA] of TSpecialKey = (
    (VKey: VK_BACK;     Name: 'BACKSPACE'),
    (VKey: VK_BACK;     Name: 'BS'),
    (VKey: VK_CANCEL;   Name: 'BREAK'),
    (VKey: VK_CAPITAL;  Name: 'CAPSLOCK'),
    (VKey: VK_CLEAR;    Name: 'CLEAR'),
    (VKey: VK_DELETE;   Name: 'DELETE'),
    (VKey: VK_DELETE;   Name: 'DEL'),
    (VKey: VK_DOWN;     Name: 'DOWN'),
    (VKey: VK_END;      Name: 'END'),
    (VKey: VK_RETURN;   Name: 'ENTER'),
    (VKey: VK_ESCAPE;   Name: 'ESCAPE'),
    (VKey: VK_ESCAPE;   Name: 'ESC'),
    (VKey: VK_HELP;     Name: 'HELP'),
    (VKey: VK_HOME;     Name: 'HOME'),
    (VKey: VK_INSERT;   Name: 'INSERT'),
    (VKey: VK_LEFT;     Name: 'LEFT'),
    (VKey: VK_NUMLOCK;  Name: 'NUMLOCK'),
    (VKey: VK_NEXT;     Name: 'PGDN'),
    (VKey: VK_PRIOR;    Name: 'PGUP'),
    (VKey: VK_RETURN;   Name: 'RETURN'),
    (VKey: VK_RIGHT;    Name: 'RIGHT'),
    (VKey: VK_SCROLL;   Name: 'SCROLLOCK'),
    (VKey: VK_TAB;      Name: 'TAB'),
    (VKey: VK_UP;       Name: 'UP'),
    (VKey: VK_F1;       Name: 'F1'),
    (VKey: VK_F2;       Name: 'F2'),
    (VKey: VK_F3;       Name: 'F3'),
    (VKey: VK_F4;       Name: 'F4'),
    (VKey: VK_F5;       Name: 'F5'),
    (VKey: VK_F6;       Name: 'F6'),
    (VKey: VK_F7;       Name: 'F7'),
    (VKey: VK_F8;       Name: 'F8'),
    (VKey: VK_F9;       Name: 'F9'),
    (VKey: VK_F10;      Name: 'F10'),
    (VKey: VK_F11;      Name: 'F11'),
    (VKey: VK_F12;      Name: 'F12'),
    (VKey: VK_F13;      Name: 'F13'),
    (VKey: VK_F14;      Name: 'F14'),
    (VKey: VK_F15;      Name: 'F15')
  );



  { 特殊キー構造体配列 }
  SpecialKeysVB6: array [0..MAXSPECIALKEY_VB6] of TSpecialKey = (
    (VKey: VK_BACK;     Name: 'BKSP'),
    (VKey: VK_INSERT;   Name: 'INS'),
    (VKey: VK_SNAPSHOT; Name: 'PRTSC'),
    (VKey: VK_F16;      Name: 'F16')
  );

  { 特殊キー構造体配列 }
  SpecialKeysExt: array [0..MAXSPECIALKEY_EXT] of TSpecialKey = (
    (VKey: VK_SNAPSHOT; Name: 'PRINTSCREEN'),
    (VKey: VK_CONTROL;  Name: 'CTRL'),
    (VKey: VK_LCONTROL; Name: 'LCTRL'),
    (VKey: VK_RCONTROL; Name: 'RCTRL'),
    (VKey: VK_SHIFT;    Name: 'SHIFT'),
    (VKey: VK_LSHIFT;   Name: 'LSHIFT'),
    (VKey: VK_RSHIFT;   Name: 'RSHIFT'),
    (VKey: VK_MENU;     Name: 'ALT'),
    (VKey: VK_LMENU;    Name: 'LALT'),
    (VKey: VK_RMENU;    Name: 'RALT'),
    (VKey: VK_PAUSE;    Name: 'PAUSE'),
    (VKey: VK_ADD;      Name: 'ADD'),
    (VKey: VK_MULTIPLY; Name: 'MULTIPLY'),
    (VKey: VK_SUBTRACT; Name: 'SUBTRACT'),
    (VKey: VK_DIVIDE;   Name: 'DIVIDE'),
    (VKey: VK_SEPARATOR;Name: 'SEPARATOR'),
    (VKey: VK_DECIMAL;  Name: 'DECIMAL'),
    (VKey: VK_NUMPAD0;  Name: 'NUMPAD0'),
    (VKey: VK_NUMPAD1;  Name: 'NUMPAD1'),
    (VKey: VK_NUMPAD2;  Name: 'NUMPAD2'),
    (VKey: VK_NUMPAD3;  Name: 'NUMPAD3'),
    (VKey: VK_NUMPAD4;  Name: 'NUMPAD4'),
    (VKey: VK_NUMPAD5;  Name: 'NUMPAD5'),
    (VKey: VK_NUMPAD6;  Name: 'NUMPAD6'),
    (VKey: VK_NUMPAD7;  Name: 'NUMPAD7'),
    (VKey: VK_NUMPAD8;  Name: 'NUMPAD8'),
    (VKey: VK_NUMPAD9;  Name: 'NUMPAD9'),
    (VKey: VK_IME;      Name: 'IME'),
    (VKey: VK_LWIN;     Name: 'WIN'),
    (VKey: VK_CONVERT;     Name: 'CONVERT'),
    (VKey: VK_NONCONVERT;  Name: 'NONCONVERT'),
    (VKey: VK_APPS;  Name: 'APPS')
  );

{ 特殊キーの処理 }
function SpecialKey(pStr: PChar;iMode: Integer): PChar;
var
  Key: Word;
  Token, SpKey: PChar;
  i, n: Integer;
begin
  Key := 0;
  if Char(pStr^) = '}' then
  begin
    Key := VkKeyScan('}');
    pStr := pStr + 1;
  end;
  Token := pStr;
  while (Char(Token^) <> #0) and (Char(Token^) <> ' ')
      and (Char(Token^) <> '}') do
    Token := Token + 1;
  if Char(Token^) = #0 then
  begin
    Result := Token;
    Exit;
  end;
  if Key = 0 then
  begin
    SpKey := StrAlloc(Token - pStr + 1);
    StrLCopy(SpKey, pStr, Token - pStr);
    for i := 0 to MAXSPECIALKEY_VBA do
    begin
      if StrIComp(SpKey, SpecialKeysVBA[i].Name) = 0 then
      begin
        Key := SpecialKeysVBA[i].VKey;
        Break;
      end;
    end;
    if (key = 0) and (iMode >= 1) then
    begin
      for i := 0 to MAXSPECIALKEY_VB6 do
      begin
        if StrIComp(SpKey, SpecialKeysVB6[i].Name) = 0 then
        begin
          Key := SpecialKeysVB6[i].VKey;
          Break;
        end;
      end;
      if (key = 0) and (iMode >= 2) then
      begin
        for i := 0 to MAXSPECIALKEY_EXT do
        begin
          if StrIComp(SpKey, SpecialKeysEXT[i].Name) = 0 then
          begin
            Key := SpecialKeysEXT[i].VKey;
            Break;
          end;
        end;
      end;
    end;
    if Key = 0 then
    begin
      if StrLen(SpKey) = 1 then
      Key := VkKeyScan(Char(SpKey^));
    end;
    StrDispose(SpKey);
  end;
  pStr := Token;
  if Char(Token^) <> '}' then
  begin
    while (Char(Token^) <> #0) and (Char(Token^) <> '}') do
      Token := Token + 1;
    if Char(Token^) = #0 then
    begin
      Result := Token;
      Exit;
    end;
  end;
  if Key <> 0 then
  begin
    n := 1;
    if Char(pStr^) = '}' then n := 1;
    if Char(pStr^) = ' ' then
    begin
      pStr := pStr + 1;
      SpKey := StrAlloc(Token - pStr + 1);
      StrLCopy(SpKey, pStr, Token - pStr);
      n := StrToIntDef(StrPas(SpKey), 0);
      StrDispose(SpKey);
    end;
    if (HiByte(Key) and 1) <> 0 then
      keybd_event(VK_SHIFT, 0, 0, 0);
    for i := 0 to n - 1 do
    begin
      keybd_event(LoByte(Key), 0, 0, 0);
      keybd_event(LoByte(Key), 0, KEYEVENTF_KEYUP, 0);
    end;
    if (HiByte(Key) and 1) <> 0 then
      keybd_event(VK_SHIFT, 0, KEYEVENTF_KEYUP, 0);
  end;
  pStr := ToKen;
  if Char(pStr^) = '}' then pStr := pStr + 1;
  Result := pStr;
end;

{ ひとまとまりのキーストローク表現の処理 }
function ProcessKeys(pStr: PChar; iMode: Integer): PChar;
var
  Chr: Char;
  Key: Word;
  Wnd: HWnd;
  idAttach, idAttachTo: DWord;
  hProcess: THandle;
  pid: DWord;
begin
  Chr := Char(pStr^);
  pStr := pStr + 1;
  if IsDBCSLeadByte(Byte(Chr)) or (Chr in [#$A1..#$DF]{半角カナ}) then
  begin
    if Char(pStr^) <> #0 then
    begin
      Wnd := GetForegroundWindow;
      idAttach := GetCurrentThreadId;
      idAttachTo := GetWindowThreadProcessId(Wnd, @pid);
      if AttachThreadInput(idAttach, idAttachTo, True) then
      begin
        hProcess := OpenProcess($001F0FFF, False, pid);
        WaitForInputIdle(hProcess, 10000);
        CloseHandle(hProcess);
        Wnd := GetFocus;
        PostMessage(Wnd, WM_CHAR, Byte(Chr), $00010001);
        PostMessage(Wnd, WM_CHAR, Byte(pStr^), $00010001);
        AttachThreadInput(idAttach, idAttachTo, False);
      end;
      pStr := pStr + 1;
    end;
  end
  else
  begin
    case Chr of
      '{': pStr := SpecialKey(pStr,iMode);
      '(':
      begin
        while (Char(pStr^) <> #0) and (Char(pStr^) <> ')') do // by mine 2002/7/18
          pStr := ProcessKeys(pStr,iMode);
        if pStr^ = ')' then Inc(pStr); // by mine 2002/7/18
      end;
      '~':
      begin
        Key := VK_RETURN;
        keybd_event(Key, 0, 0, 0);
        keybd_event(Key, 0, KEYEVENTF_KEYUP, 0);
      end;
      '+', '^', '%', '&':
      begin
        case Chr of
          '+': Key := VK_SHIFT;
          '^': Key := VK_CONTROL;
          '%': Key := VK_MENU;
          '&': Key := VK_LWIN;
          else Key := 0;
        end;
        keybd_event(Key, 0, 0, 0);
        pStr := ProcessKeys(pStr,iMode);
        keybd_event(Key, 0, KEYEVENTF_KEYUP, 0);
      end;
      else
      begin
        Key := VkKeyScan(Chr);
        if (HiByte(Key) and 1) <> 0 then
        begin
          keybd_event(VK_SHIFT, 0, 0, 0); sleep(10);
            keybd_event(LoByte(Key), 0, 0, 0);
            keybd_event(LoByte(Key), 0, KEYEVENTF_KEYUP, 0);
          keybd_event(VK_SHIFT, 0, KEYEVENTF_KEYUP, 0);
        end else
        begin
          keybd_event(Key, 0, 0, 0);
          keybd_event(Key, 0, KEYEVENTF_KEYUP, 0);
        end;
      end;
    end;
  end;
  Result := pStr;
end;

{ SendKeys関数 }
function SendKeysVBA(KeyStr: string; Wait: Boolean): Boolean;
var
  pStr: PChar;
begin
  pStr := PChar(KeyStr);       { ヌル文字列に変換       }
  while Char(pStr^) <> #0 do   { 文字列終端まで繰り返す }
  begin
    pStr := ProcessKeys(pStr,0); { ひとまとまり単位で処理 }
    sleep(10); // wait (2007/06/16)
  end;
  Result := True;
end;

{ SendKeys関数 }
function SendKeysVB6(KeyStr: string; Wait: Boolean): Boolean;
var
  pStr: PChar;
begin
  pStr := PChar(KeyStr);       { ヌル文字列に変換       }
  while Char(pStr^) <> #0 do   { 文字列終端まで繰り返す }
  begin
    pStr := ProcessKeys(pStr,1); { ひとまとまり単位で処理 }
    sleep(10); // wait (2007/06/16)
  end;
  Result := True;
end;

{ SendKeys関数 }
function SendKeys(KeyStr: string; Wait: Boolean): Boolean;
var
  pStr: PChar;
begin
  pStr := PChar(KeyStr);       { ヌル文字列に変換       }
  while Char(pStr^) <> #0 do   { 文字列終端まで繰り返す }
  begin
    pStr := ProcessKeys(pStr,2); { ひとまとまり単位で処理 }
    sleep(10); // wait (2007/06/16)
  end;
  Result := True;
end;

{ SendChars関数 }
function SendChars(KeyStr: string; Wait: Boolean): Boolean;
var
  pStr: PChar;
  Wnd: HWnd;
  idAttach, idAttachTo: DWord;
  hProcess: THandle;
  pid: DWord;
begin
  pStr := PChar(KeyStr);       { ヌル文字列に変換 }
  Wnd := GetForegroundWindow;
  idAttach := GetCurrentThreadId;
  idAttachTo := GetWindowThreadProcessId(Wnd, @pid);
  if AttachThreadInput(idAttach, idAttachTo, True) then
  begin
    hProcess := OpenProcess($001F0FFF, False, pid);
    WaitForInputIdle(hProcess, 10000);
    CloseHandle(hProcess);
    Wnd := GetFocus;
    while pStr^ <> #0 do
    begin
      PostMessage(Wnd, WM_CHAR, Byte(pStr^), $00010001);
      Inc(pStr);
    end;
    AttachThreadInput(idAttach, idAttachTo, False);
  end;
  Result := True;
end;


end.
