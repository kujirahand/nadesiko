unit vbfunc;

(***********************************************************************
    vbfunc.pas - VB Like Functions for Delphi 2.0J Ver.0.10

    VB�̊֐��̂�����r�I�v�]�������Ǝv������̂�Delphi�Ŏ������鎖
    �ŁAVB���[�U��Delphi�ւ̈ڍs�𑣐i���邱�ƂɂȂ���΂Ǝv���A�{
    ���j�b�g���쐬���܂����B���i�K�ŃT�|�[�g���Ă���͈̂ȉ��̊֐��Q
    �ł��B

    Shell         �w�肵�����s�\�v���O�������N������
    AppActivate   �w�肳�ꂽ�A�v���P�[�V�������A�N�e�B�u�ɂ���
    SendKeys      �L�[�X�g���[�N����A�N�e�B�u �E�B���h�E�ɓn��

                  Copyright(C) 1996 ������ (NIFTY-Serve SGM02275)
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
  Shell         �w�肵�����s�\�v���O�������N������

  function Shell(PathName: string; WindowStyle: Integer): Integer;

  ����          ���e
  --------------------------------------------------------------------
  PathName      ���s����v���O�������y�ѕK�v�Ȉ������܂��̓R�}���h���C
                ���X�C�b�`���w�肵�܂��B
  WindowStyle   �v���O���������s����Ƃ��̃E�B���h�E�̌`�����w�肵�܂��B
                ����l�ȊO�̒l���w�肷��ƁA���̒l�͖�������܂��B

  WindowStyle�ɂ͈ȉ��̒l���w��ł��܂��B

  �萔              �l ���e
  --------------------------------------------------------------------
  vbHide             0 �t�H�[�J�X�������B���ꂽ�E�B���h�E
  vbNormalFocus      1 �t�H�[�J�X���������̃T�C�Y�ƈʒu�ɕ\������Ă�
                       ��E�B���h�E
  vbMinimizedFocus   2 �t�H�[�J�X�������ŏ��������E�B���h�E
  vbMaximizedFocus   3 �t�H�[�J�X�������ő剻�����E�B���h�E
  vbNormalNoFocus    4 �Ō�ɃE�B���h�E������Ƃ��̃T�C�Y�ƈʒu�ɕ�
                       �������E�B���h�E
                       (���݃A�N�e�B�u�ȃE�B���h�E�̓A�N�e�B�u�̂܂�)
  vbMinimizedNoFocus 6 �A�C�R���Ƃ��ĕ\������Ă���E�B���h�E
                       (���݃A�N�e�B�u�ȃE�B���h�E�̓A�N�e�B�u�̂܂�)

  ���
  �w�肵���v���O���������s�����ƃv���O�����̃v���Z�XID���Ԃ���܂��B
  �v���Z�XID�͎��s���̃v���O���������ʂ���d�����Ȃ��ԍ��ł��B�w�肳��
  ���v���O���������s�ł��Ȃ��ꍇ��0��Ԃ��܂��B
  Shell�֐��́A�������ꂽ�v���Z�X���A�C�h����ԂɂȂ�܂�(�ő�10�b)��
  ���܂��B

  ��
  AppID := Shell('c:\windows\notepad.exe', vbNormalFocus);
***********************************************************************)

{ Shell�֐� }
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
    { �N�����̃E�B���h�E�`����ݒ� }
    Si.dwFlags := Si.dwFlags or STARTF_USESHOWWINDOW;
    Si.wShowWindow := ShowCommands[WindowStyle];
  end;
  { �w�肳�ꂽ�v���O�����̋N�� }
  if CreateProcess(nil, PChar(PathName), nil, nil, False,
      CREATE_DEFAULT_ERROR_MODE, nil, nil, Si, Pi) then
  begin
    { ���������v���Z�X���A�C�h���ɂȂ�܂�(�ő�10�b)�҂� }
    WaitForInputIdle(Pi.hProcess, 10000);
    { ���������ꍇ�̓v���Z�XID��Ԃ� }
    Result := Pi.dwProcessId;
    { �v���Z�X�n���h������� }
    CloseHandle(Pi.hProcess);
  end;
end;

(***********************************************************************
  AppActivate   �w�肳�ꂽ�A�v���P�[�V�������A�N�e�B�u�ɂ���

  function AppActivate(Title, Name: string; ProcessId: Integer): Boolean;

  ����          ���e
  --------------------------------------------------------------------
  Title         �A�N�e�B�u�ɂ������A�v���P�[�V�����E�B���h�E�̃^�C�g��
                �o�[��������w�肵�܂��B���S�Ɉ�v����E�B���h�E������
                ����Ȃ������ꍇ��Title�Ŏn�܂�E�B���h�E��T���܂��B
                Title���w�肵�Ȃ��ꍇ�A���̈�����''�̗l�ɋL�q���܂��B
  Name          �A�v���P�[�V�������N���X���ŒT���ꍇ�A�����ɃA�v���P�[
                �V�����̃��C���E�B���h�E�̃N���X�����w�肵�܂��B�E�B��
                �h�E�̃N���X����Delphi�ɕt����WinSight���Œ��ׂ鎖����
                ���܂��BName���w�肵�Ȃ��ꍇ�A���̈�����''�̗l�ɋL�q��
                �܂��B
  ProcessId     �A�N�e�B�u�ɂ������A�v���P�[�V�����̃v���Z�XID���w�肵
                ���܂��BTitle�y��Name���w�肵���ꍇ�͂��̒l�͖�������
                �܂��BShell�֐��ɂ���ăA�v���P�[�V�������N�������ꍇ�A
                �����ɂ��̖߂�l���w�肷�邱�Ƃ��ł��܂��B

  ���
  �w�肳�ꂽ�A�v���P�[�V���������������ꍇ�A���̃A�v���P�[�V������
  �A�N�e�B�u�ɂ��Đ^(True)��Ԃ��܂��B������Ȃ������ꍇ�͋U(False)
  ��Ԃ��܂��B

  ��
  AppID := Shell('notepad.exe', vbNormalFocus);
  AppActivate('', '', AppID);
***********************************************************************)
type
  TApp = record         { �E�B���h�E���ʍ\���� }
    Wnd: HWnd;          { �E�B���h�E�n���h��   }
    ProcessId: Integer; { �v���Z�XID           }
    Title: string;      { �E�B���h�E�^�C�g��   }
  end;

{ �ړI�̃E�B���h�E��T���R�[���o�b�N�֐� }
function EnumWindowsProc(Wnd: HWND; lParam: Longint): Bool; stdcall; export;
var
  Pid{, Tid}: Integer;
  Title: string;
  AppTitle: PChar;
  pApp: ^TApp;
begin
  Result := True;
  pApp := Pointer(lParam);  { �E�B���h�E���ʍ\���̂��擾 }

  if pApp^.Title <> '' then { �^�C�g�����w�肳��Ă���ꍇ }
  begin
    if IsWindowVisible(Wnd) = False then Exit;
    { �w�肳�ꂽ�^�C�g���Ŏn�܂��Ă��邩�𒲂ׂ� }
    SetLength(Title, 512);
    GetWindowText(Wnd, PChar(Title), Length(Title));

    AppTitle := PChar(pApp^.Title);
    Title    := PChar(Title);

    if (AppTitle = Title) or
       (EasyMasks.MatchesMask(Title, AppTitle)) then
    begin
      pApp^.Wnd := Wnd;     { �E�B���h�E�n���h����ۑ� }
      Result := False;      { �������I��               }
    end;
    
  end
  else                      { �^�C�g�����w�肳��Ă��Ȃ��ꍇ }
  begin
    { �w�肳�ꂽ�v���Z�XID�ƈ�v���邩�𒲂ׂ� }
    {Tid := }GetWindowThreadProcessId(Wnd, @Pid);
    if Pid = pApp^.ProcessId then
    begin
      pApp^.Wnd := Wnd;     { �E�B���h�E�n���h����ۑ� }
      Result := False;      { �������I��               }
    end;
  end;
end;

{ AppActivate�֐� }

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
  SendKeys      �L�[�X�g���[�N����A�N�e�B�u�E�B���h�E�ɓn��

  function SendKeys(KeyStr: string; Wait: Boolean): Boolean;

  ����          ���e
  --------------------------------------------------------------------
  KeyStr        �]������L�[�X�g���[�N���\�������񎮂��w�肵�܂��B
  Wait          �]���ɂ���čs���鏈�����I������܂Ŏ��s���ꎞ���f
                ���邩�ǂ������w�肵�܂��B���o�[�W�����ł͂��̈�����
                ��������܂��B

  ���
  KeyStr���w�肷��ꍇ�A�ʏ�̃L�[�͂��̂܂ܕ�����Ƃ��Ďw�肵�܂��B
  �Ⴆ��'ABC'�̗l�ɂ��܂��B
  '+'�A'^'�A'%'�A'~'�A'('�A')'�A'{'�A'}'�͂��ꂼ��SendKeys�֐��ł͓�
  �ʂȈӖ��������Ă��܂��B�����̕�����n���ɂ́A��������'{}'�ň͂�
  �Ŏw�肵�܂��B���Ƃ���'+'��'{+}'�̂悤�Ɏw�肵�܂��B

  �L�[���������Ƃ��ɕ\������Ȃ�����(Enter�L�[��Tab�L�[�Ȃ�)��A����
  �ł͂Ȃ������\������L�[���w�肷��ꍇ�́A���Ɏ����\�����g���܂��B
  {IME}�̓I�}�P�ł��B

  �L�[          �\��
  --------------------------------------------------------------------
  BackSpace     {BACKSPACE},{BS}�܂���{BKSP}
  Tab           {TAB}
  Ctrl+Break    {BREAK}
  Enter	        {ENTER} �܂��� ~
  Home,End      {HOME},{END}
  Esc,Help      {ESC},{HELP}
  Ins           {INSERT}
  Del           {DELETE}�܂���{DEL}
  ��,��,��,��   {UP},{DOWN},{LEFT},{RIGHT}
  PrintScreen	{PRTSC}
  PageDown	{PGDN}
  PageUp	{PGUP}
  CapsLock      {CAPSLOCK}
  NumLock	{NUMLOCK}
  ScrollLock	{SCROLLLOCK}
  F1�`F16	{F1}...{F16}
  ALT+�S�p/���p {IME}

  Shift�L�[�ACtrl�L�[�AAlt�L�[�Ƒ��̃L�[�Ƃ̑g�ݍ��킹���w�肷��ꍇ
  �́A�ʏ�̃L�[�\���̑O�Ɏ��̃L�[�\����P�ƁA�܂��͑g�ݍ��킹�ċL�q
  ���܂��B

  �L�[          �\��
  --------------------------------------------------------------------
  Shift         +
  Ctrl          ^
  Alt           %
  Win           &

  Shift�L�[�ACtrl�L�[�AAlt�L�[����������ԂŁA���̃L�[��A�����ĉ���
  ������w�肷��ɂ́A�A������L�[�����������()�ň݂͂܂��B�Ⴆ�΁A
  Alt�L�[�������Ȃ���'F'��'X'����������̏ꍇ��'%(AF)'�̗l�ɂ��܂��B

  �����L�[�X�g���[�N�̌J��Ԃ����w�肷��ɂ�'{Key Number}'�Ƃ����\��
  ���g���܂��B���Ƃ���'{RIGHT 10}'��'��'��10��A'{- 40}'��'-'��40��
  �������Ƃ��Ӗ����܂��B

  (��)
  SendKeys�֐���PrintScreen�L�[�𑗂����ꍇ�A�A�N�e�B�u�E�B���h�E��
  �X�i�b�v�V���b�g���N���b�v�{�[�h�ɃR�s�[����܂����A�A�v���P�[�V��
  ���͂��̃L�[���󂯎�邱�Ƃ͏o���܂���B

  ��
  if AppActivate('', 'Notepad', 0) then
    SendKeys('ABC���{��DEF{ENTER}', True);
***********************************************************************)
const
  MAXSPECIALKEY_VBA = 38;  { ����L�[�\���̔z��̗v�f�� }
  MAXSPECIALKEY_VB6 = 3;   { ����L�[�\���̔z��̗v�f�� }
  MAXSPECIALKEY_EXT = 31;  { ����L�[�\���̔z��̗v�f�� }
  VK_IME            = 25;  { IME�̃I���I�t��؂�ւ���  }

type
  TSpecialKey = record { ����L�[�\���� }
    VKey: Byte;        { ���z�L�[�R�[�h }
    Name: PChar;       { �\�����镶���� }
  end;

var
  { ����L�[�\���̔z�� }
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



  { ����L�[�\���̔z�� }
  SpecialKeysVB6: array [0..MAXSPECIALKEY_VB6] of TSpecialKey = (
    (VKey: VK_BACK;     Name: 'BKSP'),
    (VKey: VK_INSERT;   Name: 'INS'),
    (VKey: VK_SNAPSHOT; Name: 'PRTSC'),
    (VKey: VK_F16;      Name: 'F16')
  );

  { ����L�[�\���̔z�� }
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

{ ����L�[�̏��� }
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

{ �ЂƂ܂Ƃ܂�̃L�[�X�g���[�N�\���̏��� }
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
  if IsDBCSLeadByte(Byte(Chr)) or (Chr in [#$A1..#$DF]{���p�J�i}) then
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

{ SendKeys�֐� }
function SendKeysVBA(KeyStr: string; Wait: Boolean): Boolean;
var
  pStr: PChar;
begin
  pStr := PChar(KeyStr);       { �k��������ɕϊ�       }
  while Char(pStr^) <> #0 do   { ������I�[�܂ŌJ��Ԃ� }
  begin
    pStr := ProcessKeys(pStr,0); { �ЂƂ܂Ƃ܂�P�ʂŏ��� }
    sleep(10); // wait (2007/06/16)
  end;
  Result := True;
end;

{ SendKeys�֐� }
function SendKeysVB6(KeyStr: string; Wait: Boolean): Boolean;
var
  pStr: PChar;
begin
  pStr := PChar(KeyStr);       { �k��������ɕϊ�       }
  while Char(pStr^) <> #0 do   { ������I�[�܂ŌJ��Ԃ� }
  begin
    pStr := ProcessKeys(pStr,1); { �ЂƂ܂Ƃ܂�P�ʂŏ��� }
    sleep(10); // wait (2007/06/16)
  end;
  Result := True;
end;

{ SendKeys�֐� }
function SendKeys(KeyStr: string; Wait: Boolean): Boolean;
var
  pStr: PChar;
begin
  pStr := PChar(KeyStr);       { �k��������ɕϊ�       }
  while Char(pStr^) <> #0 do   { ������I�[�܂ŌJ��Ԃ� }
  begin
    pStr := ProcessKeys(pStr,2); { �ЂƂ܂Ƃ܂�P�ʂŏ��� }
    sleep(10); // wait (2007/06/16)
  end;
  Result := True;
end;

{ SendChars�֐� }
function SendChars(KeyStr: string; Wait: Boolean): Boolean;
var
  pStr: PChar;
  Wnd: HWnd;
  idAttach, idAttachTo: DWord;
  hProcess: THandle;
  pid: DWord;
begin
  pStr := PChar(KeyStr);       { �k��������ɕϊ� }
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
