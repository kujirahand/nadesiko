program setxx;

uses
  Windows,
  Forms,
  frmInstallU in 'frmInstallU.pas' {frmNakoInstaller},
  unit_install_page in 'unit_install_page.pas',
  gui_benri in 'gui_benri.pas',
  StrUnit in 'strunit.pas',
  frmExeListU in 'frmExeListU.pas' {frmExe},
  unit_process32 in 'unit_process32.pas',
  unit_getmsg in 'unit_getmsg.pas';

{$R *.res}

var
  hMutex: THandle;
  hApp: THandle;
  flagOK: Boolean;
  i: Integer;
begin

  if (ParamCount >= 1)and(ParamStr(1) = '/u2') then
  begin
    if false = MsgYesNo(getMsg('Uninstall?')) then
    begin
      Exit;
    end;
  end;

  for i := 1 to 5 do
  begin
    // ユニークな名前でMutexを作成する
    hMutex := CreateMutex(nil, true, 'com.nadesi.nadesiko.setup.exe');
    flagOK := False;
    // もし失敗したら、すでにほかのインスタンスが存在する
    if (hMutex <> 0) and (GetLastError() = ERROR_ALREADY_EXISTS) then
    begin
      // 探すWindowはMainFormで、引数にMainFromのクラスと、キャプションを指定
      hApp := FindWindow('TfrmNakoInstaller', nil);    // 探すWindowは、MainForm
      if (hApp <> 0) then SetForeGroundWindow(hApp);
    end else
    begin
      flagOK := True;
      Break;
    end;
    Sleep(1000);
  end;

  if flagOK then
  begin
  Application.Initialize;
  Application.CreateForm(TfrmNakoInstaller, frmNakoInstaller);
  Application.CreateForm(TfrmExe, frmExe);
  Application.Run;
  end;
  
  if (hMutex <> 0) then ReleaseMutex(hMutex);
  if (hMutex <> 0) then CloseHandle(hMutex);
end.
