unit gnako_window;

interface

uses
  Windows, Messages, SysUtils, hima_types, gnako_function, gnako_gdi,
  dnako_loader;

const
  WinClassName = 'Tgnako_window';

type
  TWinEvent = class
  public
    Msg: DWORD;
    NotifyCode: Integer;
    GuiID: Integer;
    EventName: AnsiString;
  end;

  TWinEventList = class(THObjectList)
  private
    lastPos:Integer;
    lastId:Integer;
    lastNC:Integer;
    lastWMsg:DWORD;
  public
    function FindEvent(WMsg: DWORD; NotifyCode, id: Integer): TWinEvent;
    function FindNextEvent: TWinEvent;
  end;

  TBokan = class
  private
    hWindow : HWND;
    FBackBmp: THBitmap;
    FCanvas : THCanvas;
    FRect   : TRect;
    function GetCaption: AnsiString;
    procedure SetCanvas(const Value: THCanvas);
  public
    constructor Create(Handle: HWND);
    destructor Destroy; override;
    function OnPaint(dc: HDC): LRESULT;
    procedure ClearScreen(col: Integer);
    function GetRect: TRect;
    property WindowHandle: HWND read hWindow;
    property Canvas: THCanvas read FCanvas write SetCanvas;
    property Caption: AnsiString read GetCaption;
  end;

var
  hMainWindow : HWND; // メインウィンドウ母艦へのハンドル
  FlagFirstAction : Boolean = False; // 初めての Show イベントか?
  Bokan: TBokan = nil;
  FlagRepaint : Boolean = False;

  eventList: TWinEventList; // GUI 部品を登録しておく
  DebugEditorHandle: THandle;


const
  DEFAULT_WIDTH  = 640;
  DEFAULT_HEIGHT = 400;

function MainWndProc(hWindow: HWND; Msg: UINT; WParam: WPARAM;
                     LParam: LPARAM): LRESULT; stdcall; export;


procedure Nadesiko_Load;
procedure Nadesiko_exec; // 実行

implementation

uses dnako_import, dnako_import_types, unit_string, mini_file_utils;

var
  FlagNoProgram: Boolean = True;
  _dnako_loader: TDnakoLoader;
  debugmode:Boolean = False;

procedure Nadesiko_Load;
var
  err: AnsiString;
  res, len: Integer;
  
  procedure errLoad;
  begin
      nako_eval('「+==========================================================」と表示。');
      nako_eval('「|」と表示');
      nako_eval('『|　　　　日本語プログラミング言語「なでしこ」』と表示。');
      nako_eval('「|」と表示');
      nako_eval('「+==========================================================」と表示。');
      nako_eval('「|」と表示。');
      nako_eval('「| プログラムを実行ファイル(gnako.exe)へドロップしてください。」と表示。');
      nako_eval('「|」と表示。');
      nako_eval('「|」と表示。');
      nako_eval('「|」と表示。');
      nako_eval('「| -> ナデシコバージョン = {ナデシコバージョン}」と表示。');
      nako_eval('「| -> ナデシコ最終更新日 = {ナデシコ最終更新日}」と表示。');
      nako_eval('「|」と表示。');
      nako_eval('「|」と表示。');
  end;

  function _checkArg: Integer;
  var
    fname  : AnsiString;
    i      : Integer;
    s      : AnsiString;
    params : AnsiString;
    p      : PHiValue;
  begin
    i := 1;
    fname := ''; params := '';
    while (ParamCount >= i) do
    begin
      s := ParamStr(i);
      params := params + s + #13#10;
      if Copy(LowerCase(s),1,6) = '-debug' then
      begin
        // DEBUG MODE
        getToken_s(s, '::');
        DebugEditorHandle := StrToIntDef(s,0);
        nako_setDebugEditorHandle(DebugEditorHandle);
        Inc(i);
        debugmode := True;
      end else
      begin
        if fname = '' then
        begin
          fname := ParamStr(i);
          Inc(i);
        end else begin
          Inc(i);
        end;
      end;
    end;
    //----------------------------------
    // command
    p := nako_getVariable('コマンドライン');
    nako_str2var(PAnsiChar(params), p);
    // bokan
    p := nako_getVariable('母艦パス');
    if p = nil then p := nako_var_new('母艦パス');
    s := ExtractFilePath(fname);
    if s = '' then s := AppPath;
    nako_str2var(PAnsiChar(s), p);
    // load
    Result := nako_load(PAnsiChar(fname));
  end;

begin
  //--------------------------------
  // todo: メインプログラムのロード
  //--------------------------------
  FlagNoProgram := False;
  try
    _dnako_loader := TDnakoLoader.Create(bokan.WindowHandle);
  except
    MessageBox(0,
      'DNAKO.DLL のロードに失敗しました。',
      'ランタイムエラー',
      MB_ICONERROR or MB_OK);
    Halt;
  end;
  try
    RegistCallbackFunction(bokan.WindowHandle);
    if _dnako_loader.hasPackfile then
    begin
      // include
      nako_addFileCommand;
      nako_LoadPlugins;
      _dnako_loader.includeLib('gnako.nako');
      _dnako_loader.checkBokanPath;
      res := nako_runPackfile;
    end else
    begin
      if ParamCount = 0 then
      begin
        errLoad; Exit;
      end;
      nako_addFileCommand;
      nako_LoadPlugins;
      _dnako_loader.includeLib('gnako.nako');
      res := _checkArg;
    end;
  finally
    // FreeAndNil(_dnako_loader);
  end;

  // ロード結果
  if res = nako_NG then
  begin
    // プログラムの実行に失敗したとき
    len := nako_getError(nil, 0);
    SetLength(err, len);
    nako_getError(PAnsiChar(err), len);
    MessageBoxA(hMainWindow, PAnsiChar(err), '文法エラー', MB_OK or MB_ICONERROR);
    Exit;
  end;

end;


procedure Nadesiko_exec;
var
  str: AnsiString; len: Integer;
begin

  if nako_NG = nako_run then
  begin
    len := nako_getError(nil, 0); SetLength(str, len+1);
    nako_getError(PAnsiChar(str), len);
    MessageBoxA(hMainWindow, PAnsiChar(str), '文法エラー', MB_OK or MB_ICONERROR);
    Exit;
  end;

end;

//------------------------------------------------------------------------------
// イベント
//------------------------------------------------------------------------------

procedure MainDestroy(hWindow: HWND);
var
  s: AnsiString;
begin
  if debugmode then
  begin
    s := ExtractFilePath(ParamStr(0)) + 'report.txt';
    nako_makeReport(PAnsiChar(s));
  end;
  PostQuitMessage(0);
end;

//------------------------------------------------------------------------------
// ウィンドウイベント検出
//------------------------------------------------------------------------------

var cw, ch: Integer;
var EventLog: AnsiString = '';

function MainWndProc(hWindow: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT; stdcall; export;
var
  dc: HDC;
  ps: PAINTSTRUCT;
  w: TWinEvent;
  p: PHiValue;
begin
  Result := 0;

  w := eventList.FindEvent(Msg, HIWORD(WParam), LOWORD(WParam));
  if (w <> nil)and(_dnako_loader <> nil) then begin
    hi_setInt(pEventReturn, 0);
    while w <> nil do
    begin
      //nako_getGroupMember
      try
        //EventLog := EventLog + w.EventName + #13#10;
        nako_int2var(LParam, pLPARAM);
        nako_int2var(WParam, pWPARAM);
        p := nako_eval(PAnsiChar(w.EventName));
        if (p <> nil) and (p.Registered = 0) then nako_var_free(p);
      finally

      end;
      w := eventList.FindNextEvent;
    end;

    Result := hi_int(pEventReturn);
  end;
  // 再描画
  if FlagRepaint then
  begin
    FlagRepaint := True;
    InvalidateRect(hWindow, nil, False); // イベントを実行したら描画処理反映。
  end;

  //----------------------------------------------------------------------------
  // メインフォームの標準イベントを処理
  // イベントの実行
  case Msg of
  WM_DESTROY:
    begin
      FreeAndNil(_dnako_loader);
      //MessageBox(0, PAnsiChar(EventLog), 'LOG', MB_OK);
      {
      if bokan.hWindow = hWindow then // 母艦の破壊時になでしこのシステムを解放する
      begin
        nako_free;
      end;
      }
      MainDestroy(hWindow);
    end;
  WM_CREATE:
    begin
      bokan := TBokan.Create(hWindow);
      Nadesiko_load;
    end;
  WM_PAINT:
    begin
      dc := BeginPaint(hWindow , ps);

      bokan.OnPaint(dc);

      EndPaint(hWindow , ps);
      Exit;
    end;
  WM_EXITSIZEMOVE:
    begin
      if bokan <> nil then
      begin
        bokan.FBackBmp.Width  := cw;
        bokan.FBackBmp.Height := ch;
        bokan.Canvas := bokan.FBackBmp.Canvas;
      end;
    end;
  WM_SIZE:
    begin
      cw := LOWORD(lParam);
      ch := HIWORD(lParam);
      // --- RESIZE
      if bokan <> nil then
      begin
        bokan.FBackBmp.Width  := cw;
        bokan.FBackBmp.Height := ch;
        bokan.Canvas := bokan.FBackBmp.Canvas;
      end;
    end;
  WM_ACTIVATEAPP:
    begin
      if _dnako_loader = nil then Exit;
      if False = FlagFirstAction then
      begin
        FlagFirstAction := True;
        // 母艦のロードイベントがあれば実行
        p := nako_getVariable('母艦設計');
        if (p <> nil) then
        begin
          if p^.VType = varStr then
          begin
            nako_eval_str('!変数宣言が不要'#13#10'EVAL(母艦設計)');
          end else
          begin
            nako_eval_str('!変数宣言が不要'#13#10'母艦設計');
          end;
        end;
        Nadesiko_exec;
        InvalidateRect(hWindow, nil, True);
      end;
    end;
  end;

  if Result = 0 then
  begin
    Result := DefWindowProc(hWindow, Msg, wParam, lParam);
  end;
end;



{ TBokan }

procedure TBokan.ClearScreen(col: Integer);
begin
  GetRect;
  EZ_Rectangle(Canvas.Handle, 0,0,
    FRect.Right - FRect.Left, FRect.Bottom - FRect.Top,
    0, col, col);
end;

constructor TBokan.Create(Handle: HWND);
begin
  hWindow := Handle;

  FBackBmp := THBitmap.Create;
  FBackBmp.Width  := DEFAULT_WIDTH;
  FBackBmp.Height := DEFAULT_HEIGHT;

  // FBackBmp のキャンバスが母艦のキャンバスとなる
  FCanvas := FBackBmp.Canvas;
end;

destructor TBokan.Destroy;
begin
  FBackBmp.Free;
  inherited;
end;

function TBokan.GetCaption: AnsiString;
var
  len: Integer;
  s: AnsiString;
begin
  len := GetWindowTextLength(hWindow);
  SetLength(s, len);
  GetWindowTextA(hWIndow, PAnsiChar(s), len+1);
  Result := s;
end;

function TBokan.GetRect: TRect;
begin
  GetWindowRect(hWindow, FRect);
  Result := FRect;
end;

function TBokan.OnPaint(dc: HDC): LRESULT;
begin
  FBackBmp.Canvas.CBitBlt(dc, 0, 0, FBackBmp.Width, FBackBmp.Height);
  Result := 0;
end;

procedure TBokan.SetCanvas(const Value: THCanvas);
begin
  FCanvas := Value;
end;

{ TWinEventList }

function TWinEventList.FindEvent(WMsg: DWORD; NotifyCode, id: Integer): TWinEvent;
var
  i: Integer;
  w: TWinEvent;
begin
  Result := nil;
  lastId:=id;lastNC:=NotifyCode;lastWMsg:=WMsg;

  for i := Count - 1 downto 0 do
  begin
    w := Items[i];
    if w.Msg = WMsg then
    begin
      if (w.GuiID < 0)or(w.GuiID = id) then
      begin
        if (w.NotifyCode < 0)or(w.NotifyCode = NotifyCode) then
        begin
          lastPos:=i;
          Result := w;
          Exit;
        end;
      end;
    end;
  end;
end;

function TWinEventList.FindNextEvent: TWinEvent;
var
  i: Integer;
  w: TWinEvent;
begin
  Result := nil;

  for i := lastPos - 1 downto 0 do
  begin
    w := Items[i];
    if w.Msg = lastWMsg then
    begin
      if (w.GuiID < 0)or(w.GuiID = lastid) then
      begin
        if (w.NotifyCode < 0)or(w.NotifyCode = lastNC) then
        begin
          lastPos:=i;
          Result := w;
          Exit;
        end;
      end;
    end;
  end;
end;

initialization
  eventList := TWinEventList.Create;

finalization
  FreeAndNil(Bokan);
  FreeAndNil(eventList);

end.
