program SetupNako;

{$IF RTLVersion < 20}
//  Delphi 2009 Only
{$IFEND}

uses
  Windows,
  Messages,
  SysUtils,
  ShellApi,
  Registry,
  kuPathUtils in 'utils\kuPathUtils.pas',
  kuBenri in 'utils\kuBenri.pas',
  kuFilesUtils in 'utils\kuFilesUtils.pas',
  APIControl in 'halbow\APIControl.pas',
  APIWindow in 'halbow\APIWindow.pas',
  CmCtrl in 'halbow\CmCtrl.pas',
  GDIObject in 'halbow\GDIObject.pas',
  UtilClass in 'halbow\UtilClass.pas',
  UtilFunc in 'halbow\UtilFunc.pas',
  WinMainUnit in 'halbow\WinMainUnit.pas';

{$R SetupNako.res}

const
  // ---
  DIR_APP       = 'nadesiko_lang\';
  APP_TITLE     = '日本語プログラミング言語「なでしこ」';
  APP_GUID      = 'nadesiko_lang';
  APP_Publisher = 'kujirahand.com';
  FIRST_RUN1    = 'nakopad.exe';
  // STARTUP_LINK  = '';
  DESKTOP_LINK  = APP_TITLE + '.lnk';
  // ---
  // CLOSE APP
  CLOSE_APP_CLASS1 = 'TfrmNako';
  CLOSE_APP_CLASS2 = 'TfrmNakopad';
  // ---
  // 関連付け
  SHELL_EXT     = '.nako';
  SHELL_EXTFILE = 'nakoFile';
  SHELL_CAPTION = 'なでしこスクリプト';
  SHELL_RUN     = 'vnako.exe';
  SHELL_EDIT    = 'nakopad.exe';
  SHELL_ICON    = 'tools\nako.ico';

const
  // HKEY_LOCAL_MACHINE
  REG_UNINSTALL = '\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\';

var
  _target: string = ''; //

function getTargetDir: string;
begin
  if _target = '' then
  begin
    Result := KPath.ProgramFiles + DIR_APP;
  end else
  begin
    Result := _target;
  end;
end;

function getUninstallRegKey: string;
begin
  Result := REG_UNINSTALL + APP_GUID;
end;

procedure doInstall;
var
  Target, name: string;
  reg: TRegistry;

  procedure _write(key: string; vname: string; value: string);
  begin
    if reg.OpenKey(key, True) then
    begin
      reg.WriteString(vname, value);
      reg.CloseKey;
    end;
  end;

begin
  try
    // Copy
    Target := getTargetDir;
    ForceDirectories(Target);
    KPath.Copy(AppPath+'*', Target);
    // Create Shortcut
    // -- StartUp
    {
    KPath.CreateShortCutEx(
      KPath.StartUpDir + STARTUP_LINK,
      Target + FIRST_RUN1, '');
    }
    // -- Desktop
    KPath.CreateShortCutEx(
      KPath.DesktopDir + DESKTOP_LINK,
      Target + FIRST_RUN1, '');
    // Registry
    name := ExtractFileName(ParamStr(0));
    reg := TRegistry.Create;
    try
    try
      // Install Info
      reg.RootKey := HKEY_LOCAL_MACHINE;
      if reg.OpenKey(getUninstallRegKey, True) then
      begin
        reg.WriteString('DisplayName', APP_TITLE);
        reg.WriteString('UninstallString', '"' + Target + name + '" /u');
        reg.WriteString('DisplayIcon','"' + Target + name + '"');
        reg.WriteString('Publisher', APP_Publisher);
        reg.WriteString('InstallLocation', Target);
        reg.CloseKey;
      end;
      // 関連付け
      reg.RootKey := HKEY_CLASSES_ROOT;
      _write(SHELL_EXT, '', SHELL_EXTFILE);
      _write(SHELL_EXT, 'PersistentHandler', '{5e941d80-bf96-11cd-b579-08002b30bfeb}');
      _write(SHELL_EXTFILE, '', SHELL_CAPTION);
      _write(SHELL_EXTFILE+'\DefaultIcon', '', Target + SHELL_ICON);
      _write(SHELL_EXTFILE+'\shell\edit', '', '編集(&E)');
      _write(SHELL_EXTFILE+'\shell\edit\command', '', '"'+Target + SHELL_EDIT+'" "%1"');
      _write(SHELL_EXTFILE+'\shell\open\command', '', '"'+Target + SHELL_RUN+'" "%1"');
    except
    end;
    finally
      reg.Free;
    end;
    // ----------------------------
    MessageBox(0, 'インストールが完了しました。', APP_TITLE, MB_OK);
  except
    MessageBox(0, 'コピーに失敗しました。再度実行してください。',APP_TITLE + 'インストール', MB_OK);
  end;
  Halt;
end;

//------------------------------------------------------------------------------
// INSTALL DIALOG
//------------------------------------------------------------------------------
var lbl: TAPILabel;
var btn: TAPIButton;
var edt: TAPIEdit;
var btnInstall: TAPIButton;

procedure btnChangeDirClick(var m: TMessage);
var
  dir: string;
begin
  dir := '';
  if KPath.OpenFolderDialog(dir) then
  begin
    edt.Text := IncludeTrailingPathDelimiter(dir);
  end;
end;

procedure doInstallProc(var m: TMessage);
begin
  _target := edt.Text;
  MainWindow.Visible := False;
  doInstall;
end;

procedure CreateFormParts(var m: TMessage);
var
  h: THandle;
begin
  MainWindow.Width := 400;
  MainWindow.Height := 160;
  MainWindow.Title := APP_TITLE;

  h         := MainWindow.Handle;
  lbl       := CreateLabel (h, 10,   6, 300, 30, 'インストール先:');
  edt       := CreateEdit  (h, 10,  30, 350, 28, getTargetDir, nil);
  btn       := CreateButton(h, 360, 30,  24, 27, '...', btnChangeDirClick);
  btnInstall:= CreateButton(h, 240, 90, 140, 28, '実行', doInstallProc);
  //
  lbl.Font.Size := 9;
  lbl.Color := clrBtnFace;
  lbl.UpdateAll;
  edt.ReadOnly := True;
  CenterWindow(MainWIndow.Handle);
end;

procedure OnSetParams(var CP:TCreateParamsEx);
begin
  CP.dwStyle:= WS_DLGFRAME or WS_SYSMENU;
  CP.nWidth := 390;
  CP.nHeight := 70;
end;

//------------------------------------------------------------------------------
// Uninstall
//------------------------------------------------------------------------------
procedure doUninstallPrepare;
var
  src, des: string;
begin
  if not YesNoDialog(
    'アンインストールしても宜しいですか?',
    APP_TITLE) then Exit;
  src := ParamStr(0);
  des := KPath.TempDir + APP_TITLE + ' Uninstaller {' + FormatDateTime('hhnnss', Now) + '}.exe';
  KPath.Copy(src, des);
  KFile.RunAs(des, '/u2', False, 0);
end;

procedure doUinstallExec;
var
  reg: TRegistry;
  path: string;
  {$IF RTLVersion < 20}
  w: AnsiString;
  {$ELSE}
  w: WideString;
  {$IFEND}
begin
  // delete Directory
  _target := '';
  reg := TRegistry.Create;
  try
    try
      // Install Information
      reg.RootKey := HKEY_LOCAL_MACHINE;
      if reg.OpenKey(getUninstallRegKey, False) then
      begin
        _target := reg.ReadString('InstallLocation');
      end;
      if reg.KeyExists(getUninstallRegKey) then
      begin
        reg.DeleteKey(getUninstallRegKey);
      end;
      // 関連付け
      reg.RootKey := HKEY_CLASSES_ROOT;
      if reg.KeyExists(SHELL_EXT) then
      begin
        reg.DeleteKey(SHELL_EXT);
      end;
      if reg.KeyExists(SHELL_EXTFILE) then
      begin
        reg.DeleteKey(SHELL_EXTFILE);
      end;
    except
    end;
  finally
    reg.Free;
  end;
  // 削除すべきパスがあるかどうか?
  try
    path := getTargetDir;
    if (_target <> '') and DirectoryExists(path) then
    begin
      KPath.Delete(ExcludeTrailingPathDelimiter(path), False);
    end;

    path := KPath.DesktopDir + DESKTOP_LINK;
    if FileExists(path) then
    begin
      DeleteFile(path);
    end;
    {
    path := KPath.StartUpDir + STARTUP_LINK;
    if FileExists(path) then
    begin
      DeleteFile(path);
    end;
    }

    MessageBox(0, 'アンインストールが完了しました。', APP_TITLE, MB_OK);
  except
    on e: Exception do
    begin
      w := 'ファイルの削除に失敗しました。'#13#10+
        'アプリケーションを終了させてから再度実行してください。'#13#10+
        e.Message;
      {$IF RTLVersion < 20}
      MessageBox(0, PChar(w), APP_TITLE, MB_OK);
      {$ELSE}
      MessageBox(0, PWideChar(w), APP_TITLE, MB_OK);
      {$IFEND}
    end;
  end;
  Halt;
end;

procedure HaltApp;

  procedure _haltapp(cname: string);
  var
    h: HWND;
    r: Integer;
  begin
    while True do
    begin
      h := FindWindow(PChar(cname), nil);
      if h = 0 then Break;

      r := MessageBox(h,
        'アプリケーションに変更を加えるため、'#13#10+
        '対象となるアプリケーションを終了させてください。'#13#10+
        'アプリケーションを強制終了させますか？',
        APP_TITLE,
        MB_YESNO);

      if r = IDYES then
      begin
        SetForegroundWindow(h);
        SendMessage(h, WM_CLOSE, 0, 0);
        Sleep(300);
        Continue;
      end
      else if r = IDNO then
      begin
        Sleep(1000);
        Continue;
      end
      else if r = IDCANCEL then
      begin
        Halt;
      end;
    end;
  end;

begin
  _haltapp(CLOSE_APP_CLASS1);
  _haltapp(CLOSE_APP_CLASS2);
end;

begin
  HaltApp;
  if ParamCount = 0 then
  begin
    KFile.RunAs(ParamStr(0), '/install');
    Exit;
  end
  else if ParamStr(1) = '/install' then
  begin
    // call doInstall;
    HalbowWinMain(CreateFormParts, OnSetParams);
  end
  else if ParamStr(1) = '/u' then
  begin
    doUninstallPrepare; Exit;
  end
  else if ParamStr(1) = '/u2' then
  begin
    doUinstallExec; Exit;
  end
  else if ParamStr(1) = '/install_test' then
  begin
    doInstall;
  end;
end.




