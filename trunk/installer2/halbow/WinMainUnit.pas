unit WinMainUnit;

interface
uses
  Windows,
  Messages,
  UtilFunc,
  UtilClass,
  APIControl,
  GDIObject,
  APIWindow;

var
  MainWindow: TSDIMainWindow;

procedure HalbowWinMain(OnCreate: TNotifyMessage; OnSetParams:TOnWindowParams);

implementation

procedure WinMainDestroy(var m: TMessage);
begin
  PostQuitMessage(0);
end;

{
procedure OnSetParams(var CP:TCreateParamsEx);
begin
  CP.dwStyle:= WS_DLGFRAME or WS_SYSMENU;
  CP.nWidth := 390;
  CP.nHeight := 70;
end;
}

procedure HalbowWinMain(OnCreate: TNotifyMessage; OnSetParams:TOnWindowParams);
begin
  MainWindow := TSDIMainWindow.Create(0, GetExeName);
  MainWindow.OnCreate        := OnCreate;
  MainWindow.OnDestroy       := WinMainDestroy;
  MainWindow.OnWindowParams  := OnSetParams;
  // MainWindow.OnCommand := OnCommand; // メニューが必要なら
  MainWindow.DoCreate;
  Halt(MessageLoopNormal);
end;

end.
