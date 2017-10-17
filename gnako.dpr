program gnako;

uses
  FastMM4 in 'FastMM4.pas',
  Windows, SysUtils, Classes,
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',

  gnako_function in 'hi_unit\gnako_function.pas',
  gnako_window in 'hi_unit\gnako_window.pas',
  gnako_gdi in 'hi_unit\gnako_gdi.pas',
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  dnako_loader in 'hi_unit\dnako_loader.pas',
  EasyMasks in 'hi_unit\EasyMasks.pas',
  unit_pack_files in 'hi_unit\unit_pack_files.pas',
  hima_stream in 'hi_unit\hima_stream.pas',
  mini_file_utils in 'hi_unit\mini_file_utils.pas',
  nadesiko_version in 'nadesiko_version.pas'
  
  {$IFDEF DELUX_VERSION}
  ,unit_pack_files_pro in 'pro_unit\unit_pack_files_pro.pas'
  {$ENDIF}
  ;


{$R gnako.res}

procedure debug(s: AnsiString);
begin
  MessageBoxA(0, PAnsiChar(s), 'debug', MB_OK);
end;

var
  wc    : TWndClass; // TPersistentClass
  Msg   : TMsg;

begin
  wc.lpszClassName   := WinClassName;
  wc.lpfnWndProc     := @MainWndProc;
  wc.style           := CS_VREDRAW or CS_HREDRAW;
  wc.hInstance       := hInstance;
  wc.hIcon           := LoadIcon(hInstance, 'MAINICON');//LoadIcon(0,IDI_APPLICATION);
  wc.hCursor         := LoadCursor(0,IDC_ARROW);
  wc.hbrBackground   := (COLOR_WINDOW+1);
  wc.lpszMenuName    := nil;
  wc.cbClsExtra      := 0;
  wc.cbWndExtra      := 0;

  Windows.RegisterClass(wc);

  // ウィンドウの作成

  hMainWindow := CreateWindowEx(
                          WS_EX_CONTROLPARENT or WS_EX_WINDOWEDGE,
                          WinClassName,
                          'なでしこ',
                          WS_VISIBLE or WS_CLIPSIBLINGS or
                          WS_CLIPCHILDREN or WS_OVERLAPPEDWINDOW,
                          Integer(CW_USEDEFAULT), Integer(CW_USEDEFAULT),
                          DEFAULT_WIDTH, DEFAULT_HEIGHT,
                          0,
                          0,
                          hInstance,
                          nil);

  ShowWindow(hMainWindow, SW_SHOW);
  UpdateWindow(hMainWindow);

  // メッセージループ

  while GetMessage(Msg, 0, 0, 0) do
  begin
    // メッセージの処理
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;

  Halt(Msg.wParam);
end.


