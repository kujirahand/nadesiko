unit frmInstallU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, jpeg, IniFiles, Registry,
  shlobj, unit_install_page;

type
  TfrmNakoInstaller = class(TForm)
    Panel1: TPanel;
    pages: TPageControl;
    tabStart: TTabSheet;
    tabLicense: TTabSheet;
    tabOption: TTabSheet;
    tabProcess: TTabSheet;
    tabEnd: TTabSheet;
    btnPrev: TButton;
    btnNext: TButton;
    GroupBox1: TGroupBox;
    radioLicenseOK: TRadioButton;
    radioLicenseNG: TRadioButton;
    edtLicense: TRichEdit;
    groupPath: TGroupBox;
    edtDir: TEdit;
    btnDir: TButton;
    groupOption: TGroupBox;
    chkDesktop: TCheckBox;
    chkQuickLaunch: TCheckBox;
    chkExt: TCheckBox;
    chkSendTo: TCheckBox;
    ChkStartup: TCheckBox;
    lblPleaseSetOption: TLabel;
    GroupBox4: TGroupBox;
    Label2: TLabel;
    bar2: TProgressBar;
    btnStopInstall: TButton;
    edtLog: TRichEdit;
    GroupBox5: TGroupBox;
    lblCompleteMsg: TLabel;
    chkAllUsers: TCheckBox;
    bar1: TProgressBar;
    chkLaunchAfterInstall: TCheckBox;
    timerUninstall: TTimer;
    tabUninstall: TTabSheet;
    GroupBox6: TGroupBox;
    lblRemoveFiles: TLabel;
    ubar1: TProgressBar;
    ubar2: TProgressBar;
    edtLogU: TRichEdit;
    Panel2: TPanel;
    edtAbout: TRichEdit;
    lblWebSite: TLabel;
    lblAboutLink: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure radioLicenseOKClick(Sender: TObject);
    procedure radioLicenseNGClick(Sender: TObject);
    procedure lblAboutLinkClick(Sender: TObject);
    procedure btnDirClick(Sender: TObject);
    procedure btnStopInstallClick(Sender: TObject);
    procedure timerUninstallTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
  private
    FTable: array [0..5] of TInstallPage;
    procedure init;
    procedure definePage;
    procedure loadSetting;
    procedure setPage(cur: Integer);
    procedure PageMove(next: Integer);
    procedure checkLicense;
    procedure doInstall;
    procedure doInstall_copyFile;
    procedure doInstall_registry;
    procedure doInstall_shortcut;
    procedure doInstall_other;
    procedure doUninstall;
    procedure doUninstall_copyFile;
    procedure doUninstall_registry;
    procedure doUninstall_shortcut;
    procedure doUninstall_other;
    function enumCopyFile: TStringList;
    function enumShorcut: TStringList;
    function enumRegistry: TStringList;
    procedure checkExe;
    //
    procedure haltMessage;
    procedure installer_copy(fname: string);
    procedure installer_shortcut(fname: string);
    procedure installer_registry(s: string);
    procedure uninstaller_copy(fname: string);
    procedure uninstaller_shortcut(fname: string);
    procedure uninstaller_registry(key: string);
    procedure deleteSelf;
    procedure checkAllUsers;
    procedure uninstall_failed(msg: string);
    //
    procedure installComplete;
    procedure executeMainFile(Sender: TObject);
    procedure checkParam;
  public
    FHaltInstall: Boolean;
    FIniFile: string;
    FInstallPath: string;
    FInstallKey: string;
    FUninstallMode: Boolean;
    FCanClose: Boolean;
    HeadKey: string;
    FlagDebug: Boolean;
    lang: string;
    ini: TIniFile;
    function msgesc(msg: string): string;
    procedure log_section(msg, descript: string);
    procedure log(msg, descript: string);
    procedure ulog_section(msg, descript: string);
    procedure ulog(msg, descript: string);
    function swapPath(path: string): string;
    procedure writeLog(s: string);
  end;

var
  frmNakoInstaller: TfrmNakoInstaller;

implementation

uses gui_benri, StrUnit, ComObj, frmExeListU, unit_process32, unit_getmsg;

{$R *.dfm}

{ TfrmInstaller }

procedure TfrmNakoInstaller.init;
begin
  // todo: init
  //
  lblWebSite.Caption := getMsg('WebSite');
  btnPrev.Caption := getMsg('Prev');
  btnNext.Caption := getMsg('Next');
  tabStart.Caption := getMsg('First');
  tabLicense.Caption := getMsg('License');
  tabOption.Caption := getMsg('Setting');
  tabProcess.Caption := getMsg('Process');
  tabEnd.Caption := getMsg('Complete');
  chkLaunchAfterInstall.Caption := getMsg('Execute');
  tabUninstall.Caption := getMsg('Uninstall');
  lblRemoveFiles.Caption := getMsg('Remove Files');
  radioLicenseOK.Caption := getMsg('Agree');
  radioLicenseNG.Caption := getMsg('Disagree');
  lblPleaseSetOption.Caption := getMsg('Setting Option');
  chkDesktop.Caption := getMsg('chkDesktop');
  chkQuickLaunch.Caption := getMsg('chkQuickLaunch');
  chkExt.Caption := getMsg('chkExt');
  chkSendTo.Caption := getMsg('chkSendTo');
  ChkStartup.Caption := getMsg('ChkStartup');
  chkAllUsers.Caption := getMsg('chkAllUsers');
  groupOption.Caption := getMsg('Option');
  groupPath.Caption := getMsg('Path');
  //
  FCanClose := False;
  // --- INI ファイルの調査
  ini := setting;
  loadSetting;

  // --- ページの定義
  definePage;

  // --- ページの表示
  setPage(0);
end;

procedure TfrmNakoInstaller.setPage(cur: Integer);
var
  i: Integer;
  s: TTabSheet;
  p: TInstallPage;
begin
  for i := 0 to pages.PageCount - 1 do
  begin
    s := pages.Pages[i];
    if i = cur then
    begin
      s.TabVisible := True;
    end else
    begin
      s.TabVisible := False;
    end;
  end;
  p := FTable[cur];
  btnPrev.Enabled := (p.prev >= 0);
  btnPrev.Tag := p.prev;
  btnNext.Enabled := (p.next >= 0);
  btnNext.Tag := p.next;
end;

procedure TfrmNakoInstaller.FormCreate(Sender: TObject);
begin
  // todo: FormCreate
  FlagDebug := False;
  FUninstallMode := False;
  init;
  checkParam;
end;

procedure TfrmNakoInstaller.btnNextClick(Sender: TObject);
begin
  PageMove(btnNext.Tag);
end;

procedure TfrmNakoInstaller.btnPrevClick(Sender: TObject);
begin
  PageMove(btnPrev.Tag);
end;

procedure TfrmNakoInstaller.PageMove(next: Integer);
var
  p: TInstallPage;
begin
  setPage(next);
  p := FTable[next];
  if Assigned(p.onActive) then
  begin
    p.onActive();
  end;
end;


procedure TfrmNakoInstaller.radioLicenseOKClick(Sender: TObject);
begin
  btnNext.Enabled := True;
end;

procedure TfrmNakoInstaller.radioLicenseNGClick(Sender: TObject);
begin
  btnNext.Enabled := False;
end;

procedure TfrmNakoInstaller.checkLicense;
begin
  if edtLicense.Text = '' then
  begin
    btnNextClick(nil);
    Exit;
  end;
  btnNext.Enabled :=  radioLicenseOK.Checked;
end;

procedure TfrmNakoInstaller.definePage;
begin
  //todo: define page
  FTable[0] := TInstallPage.Create(0, -1,  1, nil);
  FTable[1] := TInstallPage.Create(1,  0,  2, checkLicense);
  FTable[2] := TInstallPage.Create(2,  1,  3, nil);
  FTable[3] := TInstallPage.Create(3,  2,  4, doInstall);
  FTable[4] := TInstallPage.Create(4, -1, -1, installComplete);
  FTable[5] := TInstallPage.Create(5, -1, -1, nil); // uninstall
end;

procedure TfrmNakoInstaller.loadSetting;
var
  s: string;
begin
  // todo: load setting
  HeadKey  := ini.ReadString('head','key','');
  if HeadKey = '' then
  begin
    MessageBox(Self.Handle, 'headセクションのkeyが設定されていません。','不正な設定ファイル', MB_ICONERROR or MB_OK);
    Halt;
  end;
  
  FInstallKey := ini.ReadString('install', 'key', '');
  if FInstallKey = '' then
  begin
    MessageBox(Self.Handle, 'installセクションのkeyが設定されていません。','不正な設定ファイル', MB_ICONERROR or MB_OK);
    Halt;
  end;
  //
  FInstallPath := GetRegStringValue('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' + FInstallKey,
    'InstallLocation', HKEY_LOCAL_MACHINE);

  // title
  s := ini.ReadString('setup','title','Installer');
  Self.Caption := s;
  Application.Title := s;

  // message
  edtAbout.Text := msgesc(getMsg('The installation is started.'));
  lblAboutLink.Caption := msgesc(ini.ReadString('setup','link','ありません。'));

  // license
  s := ini.ReadString('setup', 'license_txt', '');
  if FileExists(AppPath + s) then
  begin
    edtLicense.Lines.LoadFromFile(AppPath + s);
  end else
  begin
    edtLicense.Text := '';
  end;

  // default dir
  s := ini.ReadString('setup', 'dir', ProgramFilesDir + HeadKey + '\');
  edtDir.Text := s;

  // option
  chkDesktop.Visible := ini.ReadBool('shortcut', 'desktop.visible', True);
  chkDesktop.Checked := ini.ReadBool('shortcut', 'desktop.checked', False);
  chkQuickLaunch.Visible := ini.ReadBool('shortcut', 'quicklaunch.visible', True);
  chkQuickLaunch.Checked := ini.ReadBool('shortcut', 'quicklaunch.checked', False);
  chkExt.Visible := ini.ReadBool('shortcut', 'extension.visible', True);
  chkExt.Checked := ini.ReadBool('shortcut', 'extension.checked', False);
  chkStartup.Visible := ini.ReadBool('shortcut', 'startup.visible', True);
  chkStartup.Checked := ini.ReadBool('shortcut', 'startup.checked', False);
  chkSendTo.Visible := ini.ReadBool('shortcut', 'sendto.visible', True);
  chkSendTo.Checked := ini.ReadBool('shortcut', 'sendto.checked', False);
  chkAllUsers.Visible := ini.ReadBool('shortcut', 'allusers.visible', True);
  chkAllUsers.Checked := ini.ReadBool('shortcut', 'allusers.checked', False);
  //
  checkAllUsers;
end;

procedure TfrmNakoInstaller.lblAboutLinkClick(Sender: TObject);
var
  s: string;
begin
  s := lblAboutLink.Caption;
  if Copy(s,1,4) = 'http' then
  begin
    OpenApp(lblAboutLink.Caption);
  end;
end;

function TfrmNakoInstaller.msgesc(msg: string): string;
begin
  msg := JReplace(msg, '\\', '\', True);
  msg := JReplace(msg, '\n', #13#10, True);
  msg := JReplace(msg, '\t', #9, True);
  result := msg;
end;

procedure TfrmNakoInstaller.btnDirClick(Sender: TObject);
var
  dir: string;
begin
  SelectDirectoryEx('', '', dir, Self.Handle);
  if Copy(dir, Length(dir), 1) <> '\' then dir := dir + '\';
  if dir <> '' then edtDir.Text := dir;
end;

procedure TfrmNakoInstaller.doInstall;
begin
  btnNext.Enabled := False;
  btnPrev.Enabled := False;
  bar1.Max      := 4;
  // setting
  FInstallPath := edtDir.Text;
  if Copy(FInstallPath, Length(FInstallPath), 1) <> '\' then
  begin
    FInstallpath := FInstallPath + '\';
    edtDir.Text := FInstallPath;
  end;

  bar1.Position := 1;
  Application.ProcessMessages;
  doInstall_copyFile;
  if FHaltInstall then begin HaltMessage; Exit; end;

  bar1.Position := 2;
  Application.ProcessMessages;
  doInstall_registry;
  if FHaltInstall then begin HaltMessage; Exit; end;

  bar1.Position := 3;
  Application.ProcessMessages;
  doInstall_shortcut;
  if FHaltInstall then begin HaltMessage; Exit; end;

  bar1.Position := 4;
  Application.ProcessMessages;
  doInstall_other;
  if FHaltInstall then begin HaltMessage; Exit; end;

  // last
  btnNext.Tag := 4;
  btnNextClick(nil);
end;


procedure TfrmNakoInstaller.log(msg, descript: string);
begin
  if descript <> '' then msg := msg + ' :' + descript;
  edtLog.Lines.Insert(0, '| ' + msg);
  edtLog.Invalidate;
end;

procedure TfrmNakoInstaller.log_section(msg, descript: string);
begin
  msg := ini.ReadString('message', msg, msg);
  msg := msgesc(msg);
  if descript <> '' then msg := msg + '(' + descript + ')';
  edtLog.Lines.Insert(0, '* ' + msg);
  writeLog('* ' + msg);
end;

procedure TfrmNakoInstaller.doInstall_copyFile;
var
  i: Integer;
  s: string;
  ls: TStringList;
begin
  ls := enumCopyFile;
  try
    // ---
    bar2.Max := ls.Count;
    bar2.Position := 0;
    log_section('FileCopy', IntToStr(ls.Count));
    // コピーループ
    for i := 0 to ls.Count - 1 do
    begin
      bar2.Position := i + 1;
      if (i mod 20) = 0 then
      begin
        Application.ProcessMessages;
        if FHaltInstall then Break;
      end;
      s := ls.Strings[i];
      log('copy', s);
      installer_copy(s);
      //
    end;
  finally
    ls.Free;
  end;
end;

procedure TfrmNakoInstaller.doInstall_other;
begin

end;

procedure TfrmNakoInstaller.doInstall_registry;
var
  s: string;
  regs: TStringList;
  i: Integer;
begin
  regs := enumRegistry;
  try
    // --- write
    log_section('Registry', IntToStr(regs.Count));
    bar2.Max := regs.Count;
    for i := 0 to regs.Count - 1 do
    begin
      bar2.Position := i + 1;
      s := regs.Strings[i];
      log('write', s);
      installer_registry(s);
    end;
    //=== 関連付けの反映
    SHChangeNotify(SHCNE_ASSOCCHANGED,SHCNF_FLUSH,nil,nil);
  finally
    regs.Free;
  end;
end;

procedure TfrmNakoInstaller.doInstall_shortcut;
var
  link: TStringList;
  i: Integer;
begin
  link := enumShorcut;
  try
    bar2.Max := link.Count;
    // --------------------------------
    // ショートカット作成処理
    log_section('Shortcut', IntToStr(link.Count));
    for i := 0 to link.Count - 1 do
    begin
      bar2.Position := i + 1;
      if (i mod 30) = 0 then
      begin
        Application.ProcessMessages;
        if FHaltInstall then Break;
      end;
      log('link', link.Strings[i]);
      installer_shortcut(link.Strings[i]);
    end;
  finally
    link.Free;
  end;
end;

procedure TfrmNakoInstaller.btnStopInstallClick(Sender: TObject);
begin
  FHaltInstall := True;
end;

procedure TfrmNakoInstaller.haltMessage;
var
  s: string;
begin
  s := getMsg('halt');
  ShowWarn(s, Application.Title);
  FCanClose := True;
  Close;
end;

procedure TfrmNakoInstaller.installer_copy(fname: string);
var
  s, path, spath, newname: string;
  src, des: string;

  procedure cpy(src, des: string);
  var des_path, ext: string;
  begin
    // フォルダチェック
    des_path := ExtractFilePath(des);
    ForceDirectories(des_path);
    // コピー
    if CopyFile(PChar(src), PChar(des), False) then
    begin
      writeLog('cpy "' + src + '" "' + des + '"');
      ext := LowerCase(ExtractFileExt(src));
      if (ext = '.ini') then
      begin
        SetFileAttributes(PChar(src), FILE_ATTRIBUTE_NORMAL);
      end;
    end;
  end;

begin
  // %spath%path\filename;newname
  // path\filename;newname
  s       := Trim(fname);
  fname   := Trim(GetToken(';', s));
  newname := Trim(s);
  if Copy(fname, 1, 1) = '%' then
  begin
    Delete(fname, 1,1);
    spath := Trim(GetToken('%', fname));
    path  := ExtractFilePath(fname);
    fname := ExtractFileName(fname);
    spath := swapPath('%'+spath+'%');
  end else
  begin
    spath := FInstallPath;
    path  := ExtractFilePath(fname);
    fname := ExtractFileName(fname);
  end;
  if newname = '' then newname := fname;
  src := AppPath + path + fname;
  des := spath + path + newname;
  cpy(src, des);
end;

function TfrmNakoInstaller.swapPath(path: string): string;
begin
  if Pos('%', path) = 0 then
  begin
    Result := path;
    Exit;
  end;

  Result := path;

  // ---
  Result := JReplace(Result, '%INSTALL%', FInstallPath, True);

  // Windows
  Result := JReplace(Result, '%PROGRAMS%', ProgramsDir, True);
  Result := JReplace(Result, '%QUICKLAUNCH%', QuickLaunchDir, True);
  Result := JReplace(Result, '%SENDTO%', SendToDir, True);
  Result := JReplace(Result, '%PROGRAMFILES%', ProgramFilesDir, True);
  if chkAllUsers.Checked then
  begin
    Result := JReplace(Result, '%APPDATA%', CommonAppData, True);
    Result := JReplace(Result, '%STARTUP%', CommonStartUpDir, True);
    Result := JReplace(Result, '%DESKTOP%', CommonDesktopDir, True);
    Result := JReplace(Result, '%STARTMENU%', CommonStartMenuDir, True);
  end else
  begin
    Result := JReplace(Result, '%APPDATA%', AppData, True);
    Result := JReplace(Result, '%STARTUP%', StartUpDir, True);
    Result := JReplace(Result, '%DESKTOP%', DesktopDir, True);
    Result := JReplace(Result, '%STARTMENU%', StartMenuDir, True);
  end;
end;

procedure TfrmNakoInstaller.installComplete;
begin
  btnNext.Enabled := True;
  btnNext.OnClick := executeMainFile;
  btnNext.Caption := getMsg('Quit');
  if FUninstallMode then
  begin
    lblCompleteMsg.Caption := getMsg('Uninstall Completed');
    chkLaunchAfterInstall.Visible := False;
  end;
end;

procedure TfrmNakoInstaller.executeMainFile(Sender: TObject);
var
  path: string;
begin
  if FUninstallMode then
  begin
    FCanClose := True;
    Close;
  end;
  if chkLaunchAfterInstall.Checked then
  begin
    path := FInstallPath + ini.ReadString('setup', 'exefile', '');
    OpenApp(path);
  end;
  FCanClose := True;
  Close;
end;

procedure TfrmNakoInstaller.installer_shortcut(fname: string);
var
  s, spath, newname: string;
  src, des: string;

  procedure cpy(src, des: string);
  var des_path: string;
  begin
    // フォルダチェック
    des_path := ExtractFilePath(des);
    ForceDirectories(des_path);
    // コピー
    CreateShortCut(des, src, '', MyDocumentDir, wsNormal);
    writeLog('shortcut "' + src + '" "' + des + '"');
  end;

begin
  // %spath%; path\filename; newname
  s := fname;
  spath   := Trim(GetToken(';', s));
  fname   := Trim(GetToken(';', s));
  newname := Trim(s);
  spath   := swapPath(spath);

  src := FInstallPath + fname;
  des := spath + newname;
  cpy(src, des);
end;

procedure setRoot(reg: TRegistry; root: string);
begin
  // ROOT
  if root = 'HKEY_CLASSES_ROOT' then reg.RootKey := HKEY_CLASSES_ROOT else
  if root = 'HKEY_CURRENT_USER' then reg.RootKey := HKEY_CURRENT_USER else
  if root = 'HKEY_LOCAL_MACHINE' then reg.RootKey := HKEY_LOCAL_MACHINE else
  if root = 'HKEY_USERS' then reg.RootKey := HKEY_USERS else
  if root = 'HKEY_PERFORMANCE_DATA' then reg.RootKey := HKEY_PERFORMANCE_DATA else
  if root = 'HKEY_CURRENT_CONFIG' then reg.RootKey := HKEY_CURRENT_CONFIG else
  if root = 'HKEY_DYN_DATA' then reg.RootKey := HKEY_DYN_DATA else
  begin
    ShowWarn('レジストリルートの破損データ:' + root, 'インストール設定の破損');
    Exit;
  end;
end;

procedure TfrmNakoInstaller.installer_registry(s: string);
var
  root, key, name, value: string;
  reg: TRegistry;
begin
  if Copy(s,1,2) = '\\' then System.Delete(s,1,2);
  root  := GetToken('\', s);
  key   := GetToken(';', s);
  name  := Trim(GetToken('=', s));
  value := swapPath(Trim(s));
  reg := TRegistry.Create;
  try
    // ROOT
    setRoot(reg, root);
    // KEY
    if reg.OpenKey(key, True) then
    begin
      reg.WriteString(name, value);
      writeLog('registry :' + root + '\' + key + ';' + name + '=' + value);
    end;
  finally
    reg.Free;
  end;
end;

procedure TfrmNakoInstaller.checkParam;
const
  uninstaller = 'uninstall_nako.exe';
var
  path, src, des: string;
begin
  if ParamCount < 1 then Exit;

  //todo: CheckParam
  if ParamStr(1) = '/u' then
  begin
    path := TempDir + HeadKey + '\';
    ForceDirectories(path);
    //
    src := ParamStr(0);
    des := path + uninstaller;
    CopyFile(PChar(src), PChar(des), False);
    //
    src := ChangeFileExt(ParamStr(0), '.ini');
    des := path + 'uninstall_nako.ini';
    CopyFile(PChar(src), PChar(des), False);
    //
    RunApp('"' + path + uninstaller + '" "/u2"');
    FCanClose := True;
    Close;
    Exit;
  end;

  if (ParamStr(1) = '/u2')or(ExtractFileName(ParamStr(0)) = uninstaller) then
  begin
    setPage(5);
    FUninstallMode := True;
    timerUninstall.Enabled := True;
  end;

end;

procedure TfrmNakoInstaller.timerUninstallTimer(Sender: TObject);
begin
  //
  timerUninstall.Enabled := False;
  doUninstall;
end;

procedure TfrmNakoInstaller.doUninstall;
begin
  // setting
  if Copy(FInstallPath, Length(FInstallPath), 1) <> '\' then
  begin
    FInstallpath := FInstallPath + '\';
    edtDir.Text := FInstallPath;
  end;

  ubar2.Max      := 4;
  //
  ubar2.Position := 1;
  doUninstall_copyFile;
  if FHaltInstall then HaltMessage;

  ubar2.Position := 2;
  doUninstall_registry;
  if FHaltInstall then HaltMessage;

  ubar2.Position := 3;
  doUninstall_shortcut;
  if FHaltInstall then HaltMessage;

  ubar2.Position := 4;
  doUninstall_other;
  if FHaltInstall then HaltMessage;

  //
  deleteSelf;

  // last
  btnNext.Tag := 4;
  btnNextClick(nil);

end;

procedure TfrmNakoInstaller.doUninstall_copyFile;
var
  i: Integer;
  s: string;
  ls: TStringList;
begin
  ls := enumCopyFile;
  try
    // ---
    bar2.Max := ls.Count;
    bar2.Position := 0;
    ulog_section('delete', IntToStr(ls.Count));
    // コピーループ
    for i := 0 to ls.Count - 1 do
    begin
      bar2.Position := i + 1;
      if (i mod 20) = 0 then
      begin
        Application.ProcessMessages;
        if FHaltInstall then Break;
      end;
      s := ls.Strings[i];
      ulog('remove', s);
      uninstaller_copy(s);
      //
    end;
  finally
    ls.Free;
  end;
end;

procedure TfrmNakoInstaller.doUninstall_other;
var
  i: Integer;
  s, src: string;
begin
  ulog_section('Remove Dir','');
  for i := 1 to 65535 do
  begin
    s := ini.ReadString('dir.uninstall', IntToStr(i), '');
    if s = '' then Break;
    src := swapPath(s);
    if DirectoryExists(src) then
    begin
      if Copy(src,Length(src),1) = '\' then
      begin
        System.Delete(src, length(src), 1);
      end;
      SHFileDeleteComplete(src);
      WriteLog('rmdir:' + src);
    end;
  end;
end;

procedure TfrmNakoInstaller.doUninstall_registry;
var
  regs: TStringList;
  i: Integer;
  s: string;
begin
  regs := TStringList.Create;
  try
    // enum
    for i := 1 to 65535 do
    begin
      s := ini.ReadString('registry.uninstall', IntToStr(i), '');
      if s = '' then Break;
      regs.Add(s);
    end;
    regs.Add('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'+FInstallKey);
    // remove
    ulog_section('Registry', IntToStr(regs.Count));
    for i := 0 to regs.Count - 1 do
    begin
      s := regs.Strings[i];
      ulog('remove', s);
      uninstaller_registry(s);
    end;
    //=== 関連付けの反映
    SHChangeNotify(SHCNE_ASSOCCHANGED,SHCNF_FLUSH,nil,nil);
  finally
    regs.Free;
  end;
end;

procedure TfrmNakoInstaller.doUninstall_shortcut;
var
  link: TStringList;
  i: Integer;
begin
  link := enumShorcut;
  try
    ubar2.Max := link.Count;
    // --------------------------------
    // ショートカット作成処理
    ulog_section('Shortcut',IntToStr(link.Count));
    for i := 0 to link.Count - 1 do
    begin
      ubar2.Position := i + 1;
      if (i mod 30) = 0 then
      begin
        Application.ProcessMessages;
        if FHaltInstall then Break;
      end;
      ulog('remove', link.Strings[i]);
      uninstaller_shortcut(link.Strings[i]);
    end;
  finally
    link.Free;
  end;
end;

function TfrmNakoInstaller.enumCopyFile: TStringList;
var
  i: Integer;
  ls: TStringList;
  s: string;
begin
  ls := TStringList.Create;

  // -----------------------------------
  // ファイル数の確認
  for i := 1 to 65535 do
  begin
    s := ini.ReadString('files', IntToStr(i), '');
    if s = '' then Break;
    ls.Add(s);
  end;
  // -----------------------------------
  // 自身を追加
  s := ExtractFileName(ParamStr(0));
  if ls.IndexOf(s) < 0 then ls.Add(s);
  s := ExtractFileName(FIniFile);
  if ls.IndexOf(s) < 0 then ls.Add(s);
  // -----------------------------------
  Result := ls;
end;

function TfrmNakoInstaller.enumShorcut: TStringList;
var
  s: string;
  link: TStringList;
  i: Integer;
begin
  link := TStringList.Create;

  // --------------------------------
  // (1)スタートメニューに追加する
  for i := 1 to 65535 do
  begin
    s := ini.ReadString('group', IntToStr(i), '');
    if s = '' then Break;
    link.Add('%PROGRAMS%;' + s + '.lnk');
  end;
  // (2)デスクトップ
  s := ini.ReadString('shortcut', 'file', '');
  if ((s <> '') and (chkDesktop.Checked)) or (FUninstallMode) then
  begin
    link.Add('%DESKTOP%;' + s + '.lnk');
  end;
  // (3)sendto
  if ((s <> '') and (chkSendTo.Checked)) or (FUninstallMode) then
  begin
    link.Add('%SENDTO%;' + s + '.lnk');
  end;
  // (4)startup
  if ((s <> '') and (ChkStartup.Checked)) or (FUninstallMode) then
  begin
    link.Add('%STARTUP%;' + s + '.lnk');
  end;
  // (5)クイック起動
  if ((s <> '') and (chkQuickLaunch.Checked)) or (FUninstallMode) then
  begin
    link.Add('%QUICKLAUNCH%;' + s + '.lnk');
  end;

  Result := link;
end;

function TfrmNakoInstaller.enumRegistry: TStringList;
var
  s, path: string;
  regs: TStringList;
  i: Integer;
begin
  regs := TStringList.Create;

  // --------------------------------
  // (1) レジストリ
  for i := 1 to 65535 do
  begin
    s := ini.ReadString('registry', IntToStr(i), '');
    if s = '' then Break;
    regs.Add(s);
  end;
  
  // --------------------------------
  // (2) アンインストール情報
  path := 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' +
    ini.ReadString('install', 'key', HeadKey);
  // name
  s := ini.ReadString('install','DisplayName', HeadKey);
  regs.Add(path+';' + 'DisplayName=' + s);
  // icon
  s := ini.ReadString('install','DisplayIcon', '');
  if s <> '' then
    regs.Add(path+';' + 'DisplayIcon=' + s);
  // location
  regs.Add(path+';' + 'InstallLocation=' + FInstallPath);
  // uninstallstring
  regs.Add(path+';' + 'UninstallString="' + FInstallPath + ExtractFileName(ParamStr(0)) + '" /u');
  // allusers?
  if chkAllUsers.Checked then
    regs.Add(path+';AllUsers=1')
  else
    regs.Add(path+';AllUsers=0');
  // -------------------------
  Result := regs;
end;

procedure TfrmNakoInstaller.uninstaller_copy(fname: string);
var
  s, path, spath, newname: string;
  src, des: string;

  procedure rm(src, des: string);
  begin
    if FileExists(des) then
    begin
      if DeleteFile(des) then
      begin
        WriteLog('rm : ' + des);
      end else
      begin
        uninstall_failed(getMsg('削除失敗: ') + des);
      end;
    end;
  end;

begin
  // %spath%path\filename;newname
  // path\filename;newname
  s       := Trim(fname);
  fname   := Trim(GetToken(';', s));
  newname := Trim(s);
  if Copy(fname, 1, 1) = '%' then
  begin
    Delete(fname, 1,1);
    spath := Trim(GetToken('%', fname));
    path  := ExtractFilePath(fname);
    fname := ExtractFileName(fname);
    spath := swapPath('%'+spath+'%');
  end else
  begin
    spath := FInstallPath;
    path  := ExtractFilePath(fname);
    fname := ExtractFileName(fname);
  end;
  if newname = '' then newname := fname;
  src := AppPath + path + fname;
  des := spath + path + newname;
  rm(src, des);
end;

procedure TfrmNakoInstaller.uninstaller_registry(key: string);
var
  root, name, value, s: string;
  reg: TRegistry;
begin
  s := key;
  if Copy(s,1,2) = '\\' then System.Delete(s,1,2);
  root  := GetToken('\', s);
  key   := GetToken(';', s);
  name  := Trim(GetToken('=', s));
  value := swapPath(Trim(s));
  reg := TRegistry.Create;
  try
    // ROOT
    setRoot(reg, root);

    // CHECK BROKEN KEY
    if key = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' then
    begin
      ShowWarn('危険なキーの指定' + key, 'インストーラーの警告');
      Exit;
    end;

    // KEY
    if name = '' then
    begin
      if reg.KeyExists(key) then
      begin
        reg.DeleteKey(key);
      end;
    end else
    begin
      if reg.OpenKeyReadOnly(key) then
      begin
        if reg.ValueExists(name) then
        begin
          reg.DeleteValue(name);
        end;
      end;
    end;
    writeLog('rm : ' + root + '\' + key + ';' + name + '=' + value);

  finally
    reg.Free;
  end;
end;

procedure TfrmNakoInstaller.uninstaller_shortcut(fname: string);
var
  s, spath, newname: string;
  src, des: string;

  procedure rm(src, des: string);
  begin
    if DeleteFile(des) then
    begin
      writeLog('rm : ' + des);
    end;
  end;

begin
  // %spath%; path\filename; newname
  s := fname;
  spath   := Trim(GetToken(';', s));
  fname   := Trim(GetToken(';', s));
  newname := Trim(s);
  spath   := swapPath(spath);

  src := FInstallPath + fname;
  des := spath + newname;
  rm(src, des);
end;

procedure TfrmNakoInstaller.ulog(msg, descript: string);
begin
  if descript <> '' then msg := msg + ' :' + descript;
  edtLogU.Lines.Insert(0, '| ' + msg);
  edtLogU.Invalidate;
end;

procedure TfrmNakoInstaller.ulog_section(msg, descript: string);
begin
  msg := ini.ReadString('message', msg, msg);
  msg := msgesc(msg);
  if descript <> '' then msg := msg + '(' + descript + ')';
  edtLogU.Lines.Insert(0, '* ' + msg);
  //
  writeLog('* ' + msg);
end;

procedure TfrmNakoInstaller.writeLog(s: string);
var
  path: string;
  f: TFileStream;
begin
  if not FlagDebug then Exit;
  path := DesktopDir + 'log.txt';
  if FileExists(path) then
  begin
    f := TFileStream.Create(path, fmOpenReadWrite);
  end else
  begin
    f := TFileStream.Create(path, fmCreate);
  end;
  f.Seek(0, soFromEnd);
  s := s + #13#10;
  f.Write(PChar(s)^, Length(s));
  f.Free;
end;

procedure TfrmNakoInstaller.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if FCanClose = False then
  begin
    if not MsgYesNo(getMsg('Install Interruped?')) then
    begin
      CanClose := False;
    end else
    begin
      FHaltInstall := True;
    end;
  end;
end;

procedure TfrmNakoInstaller.FormShow(Sender: TObject);
begin
  if FCanClose then
  begin
    Close;
  end;
  // --- exe の起動チェック
  checkExe;
end;


// 自分自身を削除するための「WinInit.ini」を作成する
procedure CreateWinInit(fname: string);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(WinDir + 'WinInit.ini');
  try
    Ini.WriteString('rename', 'NUL', fname);
  finally
    Ini.Free;
  end;
end;

procedure TfrmNakoInstaller.deleteSelf;
var
  delfile: string;
begin

  //--- 自身を削除する処理 ---
  delfile := ParamStr(0);

  if Win32PlatForm=VER_PLATFORM_WIN32_NT then
  begin
    MoveFileEx(PChar(delfile), nil, MOVEFILE_DELAY_UNTIL_REBOOT);
    MoveFileEx(PChar(FIniFile), nil, MOVEFILE_DELAY_UNTIL_REBOOT);
  end
  else if Win32PlatForm=VER_PLATFORM_WIN32_WINDOWS then
  begin
    CreateWinInit(delfile);
    CreateWinInit(FIniFile);
  end;

end;

procedure TfrmNakoInstaller.checkAllUsers;
var
  reg: TRegistry;
  v, path: string;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    path := 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' + FInstallKey;
    if reg.KeyExists(path) then
    begin
      if reg.OpenKeyReadOnly(path) then
      begin
        v := reg.ReadString('AllUsers');
        chkAllUsers.Checked := (v = '1');
      end;
    end;
  finally
    reg.Free;
  end;
end;

procedure TfrmNakoInstaller.uninstall_failed(msg: string);
begin
  ShowWarn(
    getMsg('アンインストールに失敗しました。\n' +
      '再度実行してください。'),
    msg + #13#10 +
    getMsg('エラー'));
  FCanClose := False;
  Close;
end;

procedure TfrmNakoInstaller.checkExe;
begin
  if frmExe.checkExe = false then
  begin
    frmExe.ShowModal;
  end;
end;

end.
