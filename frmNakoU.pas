
unit frmNakoU;

interface

uses
  // Windows Unit
  Windows, Messages,
  // Delphi Unit
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus, ValEdit, Grids, ComCtrls, Spin,
  AppEvnts, ShellAPI,
  // nadesiko unit
  dnako_loader, unit_pack_files, hima_types, dnako_import_types,
  unit_string, vnako_function, unit_tree_list,
  // Added Component
  TrackBox,Buttons,
  // XPManifest
{$IF RTLVersion >=15}
  XPMan,
{$IFEND}
  IdBaseComponent, IdComponent, IdTCPServer,
  vnako_message,
  // TEditor Support
  HEditor, heRaStrings, heClasses, HEdtProp
  ;

const
  WM_NotifyTasktray = WM_USER + 100;

type
  THiEditor = class(TEditor)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    procedure WMMousewheel(var Msg: TMessage); message WM_MOUSEWHEEL;
    function GetCaretXY: TPoint;
    procedure SetCaretXY(x,y: Integer);
    procedure ShowCaret;
    procedure ViewFlag(s: AnsiString);
    procedure PutMark(tag: Integer);
    procedure GotoMark(tag: Integer);
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  THiListView = class(TListView)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  public
    nodes: THHash;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

  THiWinControl = class(TWinControl)
  public
    property DragMode;
    property DragKind;
    procedure hi_setDragMode(s: AnsiString);
    function hi_getDragMode: AnsiString;
  end;

  TfrmNako = class(TForm)
    timerRunScript: TTimer;
    AppEvent: TApplicationEvents;
    dlgFont: TFontDialog;
    dlgColor: TColorDialog;
    dlgPrinter: TPrinterSetupDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure timerRunScriptTimer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure AppEventIdle(Sender: TObject; var Done: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure AppEventActivate(Sender: TObject);
    procedure AppEventDeactivate(Sender: TObject);
    procedure AppEventMinimize(Sender: TObject);
    procedure AppEventRestore(Sender: TObject);
  private
    { Private 宣言 }
    FFlagFree: Boolean;
    DebugEditorHandle: Integer;
    FDragPoint: TPoint;
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    function GetBackCanvas: TCanvas;
    procedure onExitSizeMove(var Msg: TMessage); message WM_EXITSIZEMOVE;
    procedure CopyDataMessage(var WMCopyData: TWMCopyData); message WM_COPYDATA;
    procedure _WM_VNAKO_STOP(var Msg: TMessage); message WM_VNAKO_STOP;
    procedure _WM_VNAKO_BREAK(var Msg: TMessage); message WM_VNAKO_BREAK;
    procedure _WM_VNAKO_BREAK_ALL(var Msg: TMessage); message WM_VNAKO_BREAK_ALL;
    function Nadesiko_Load: Boolean;
    procedure ResizeBackBmp;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
  protected
    // ドラッグしてフォームを移動する場合
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    //procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;

  // タスクトレイへの常駐機能のため
  private
    NotifyIcon: TNotifyIconData;
    procedure wmNotifyTasktray(var Msg: TMessage); message WM_NotifyTasktray;
    procedure wmDevChange(var Msg: TMessage); message WM_DEVICECHANGE;
  public
    IsLiveTasktray: boolean;
    edtPropNormal: TEditorProp;
    procedure InitTasktray;
    procedure FinishTasktray;
    procedure ChangeTrayIcon;
    procedure MovetoTasktray(HideForm:Boolean = True); // タスクトレイへ移動
    procedure LeaveTasktray(RestoreForm:Boolean = True);  // タスクトレイを離れる
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  public
    { Public 宣言 }
    freeObjList: TList; // VCL_FREE で追加される
    IsBokan: Boolean;
    flagBokanSekkei: Boolean;
    flagRepaint: Boolean; // 再描画が必要か？

    flagNowClose: Boolean; // CloseQueryの実行中かどうか
    flagClose: Boolean;    // 閉じるべきかどうか

    flagDragMove: Boolean;
    UseDebug:  Boolean;
    UseLineNo: Boolean;
    backBmp: TBitmap;
    FMainFile: AnsiString; // メインファイル名
    //
    function GetRect: TRect;
    procedure ClearScreen(col: Integer);
    property BackCanvas: TCanvas read GetBackCanvas;
    procedure Redraw;
    procedure setStyle(s: AnsiString);
    // event
    procedure eventClick(Sender: TObject);
    procedure eventChange(Sender: TObject);
    procedure eventSizeChange(Sender: TObject);
    procedure eventDblClick(Sender: TObject);
    procedure eventChangeTrackBox(Sender: Tobject; SZf: Boolean);
    procedure eventShow(Sender: TObject);
    procedure eventClose(Sender: TObject; var CanClose: Boolean);
    procedure eventTreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure eventMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure eventMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure eventMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure eventBrowserNavigate(Sender: TObject; const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData, Headers: OleVariant; var Cancel: WordBool);
    procedure eventKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure eventKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure eventKeyPress(Sender: TObject; var Key: Char);
    procedure eventDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure eventDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure eventMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure eventFileDrop(Sender: TObject; Num: Integer; Files: TStrings; X, Y: Integer);
    procedure eventTEditorDropFile(Sender: TObject; Drop, KeyState: Longint; Point: TPoint);
    procedure eventTimer(Sender: TObject);
    procedure eventNavigateComplete(Sender: TObject; const pDisp: IDispatch; var URL: OleVariant);
    procedure eventBrowserNewWindow2(Sender: TObject; var ppDisp: IDispatch; var Cancel: WordBool);
    procedure eventBrowserDocumentComplete(Sender: TObject; const pDisp: IDispatch;var URL: OleVariant);
    procedure eventBrowserDownloadComplete(Sender: TObject);
    procedure eventPaint(Sender: TObject);
    procedure eventMouseEnter(Sender: TObject);
    procedure eventMouseLeave(Sender: TObject);
    procedure eventListOpen(Sender: TObject);
    procedure eventListClose(Sender: TObject);
    procedure eventListSelect(Sender: TObject);
    //
    procedure doEvent(group: PGuiInfo; eventName: AnsiString);
    //
    procedure SetBokanHensu;
  end;

var
  frmNako: TfrmNako;
  Bokan: TfrmNako;
  FlagBokan: Boolean = False; // --- 初めての Create で、True になる
  _flag_vnako_exe:Boolean = True;
  _dnako_loader: TDnakoLoader = nil;
  _dnako_success: Boolean = False;

  {$IFDEF FMPMODE}
  _flag_fmp_mode: Boolean = False;
  _flag_fmp_key_enabled:Boolean = False;
  _fmp_key1: AnsiString = '';
  _flag_fmp_remove_src: Boolean = False;
  {$ENDIF}

procedure UpdateAfterEvent(o: TObject);
procedure ExtractMixFile(var fname: string);

implementation

uses dnako_import,
  hima_stream, mini_file_utils, fileDrop, unit_windows_api, frmDebugU,
  frmErrorU, frmInputListU, UIWebBrowser, dll_plugin_helper, unit_dbt,
  gui_benri;

{$R *.dfm}

procedure _TrackMouseEvent(handle:HWND;time:Cardinal);
var
  tme:TTrackMouseEvent;
begin
  tme.cbSize := sizeof(tme);
  tme.dwFlags := TME_HOVER;
  tme.hwndTrack := Handle;
  tme.dwHoverTime := Time;
  TrackMouseEvent(tme);
end;

// mix file の取り出しとファイルの検索
procedure ExtractMixFile(var fname: string);
var
  s: TMemoryStream;
  f: string;

  function chk(f: string): Boolean;
  begin
    Result := FileExists(string(f));
    if Result then
    begin
      fname := f;
    end;
  end;

  function path(f: string): string;
  begin
    if Copy(f,Length(f),1) <> '\' then
    begin
      Result := f + '\';
    end;
  end;

begin

  // mix file を検索
  if FileMixReader <> nil then
  if FileMixReader.ReadFile(string(fname), s) then
  begin
    f := TempDir + ExtractFileName(string(fname));
    s.SaveToFile(f);
    fname := f;
    s.Free;
    Exit;
  end;

  // 絶対パス指定なら抜ける
  if Pos(':\', fname) > 0 then Exit;

  // curdir
  if chk(path(GetCurrentDir) + fname) then Exit;
  // bokan
  f := hi_strU(nako_getVariable('母艦パス'));
  if chk(f + fname) then Exit;
  // bokan + lib
  if chk(f + 'lib\' + fname) then Exit;
  // apppath
  if chk(ExtractFilePath(ParamStr(0)) + fname) then Exit;
  // apppath + lib
  if chk(ExtractFilePath(ParamStr(0)) + 'lib\' + fname) then Exit;
end;


{ THiEditor }

function THiEditor.GetCaretXY: TPoint;
var x, y: Integer;
begin
  SetCaretPosition(x, y);
  Result.X := x;
  Result.Y := y;
end;



procedure THiEditor.GotoMark(tag: Integer);
begin
  case tag of
  0: Self.GotoRowMark(rm0);
  1: Self.GotoRowMark(rm1);
  2: Self.GotoRowMark(rm2);
  3: Self.GotoRowMark(rm3);
  4: Self.GotoRowMark(rm4);
  5: Self.GotoRowMark(rm5);
  6: Self.GotoRowMark(rm6);
  7: Self.GotoRowMark(rm7);
  8: Self.GotoRowMark(rm8);
  9: Self.GotoRowMark(rm9);
  end;
end;

procedure THiEditor.PutMark(tag: Integer);
begin
  case tag of
  0: Self.PutRowMark(Self.Row, rm0);
  1: Self.PutRowMark(Self.Row, rm1);
  2: Self.PutRowMark(Self.Row, rm2);
  3: Self.PutRowMark(Self.Row, rm3);
  4: Self.PutRowMark(Self.Row, rm4);
  5: Self.PutRowMark(Self.Row, rm5);
  6: Self.PutRowMark(Self.Row, rm6);
  7: Self.PutRowMark(Self.Row, rm7);
  8: Self.PutRowMark(Self.Row, rm8);
  9: Self.PutRowMark(Self.Row, rm9);
  end;
end;

procedure THiEditor.SetCaretXY(x, y: Integer);
var
  r, c: Integer;
begin
  self.PosToRowCol(x, y, r, c, True);
  self.SetRowCol(r, c);
  self.SetFocus;
end;

procedure THiEditor.ShowCaret;
begin
  ScrollCaret;
end;

procedure THiEditor.ViewFlag(s: AnsiString);
//var i:Integer;
begin
  (*
  ExMarks.TabMark.Visible := (Pos('タブ',s) > 0);

  ExMarks.DBSpaceMark.Visible := (Pos('全角スペース',s) > 0);
  ExMarks.SpaceMark.Visible := (Pos('半角スペース',s) > 0);
  i := Pos('スペース',s);
  while i <> 0 do
  begin
    if i < 5 then
    begin
      ExMarks.SpaceMark.Visible := True;
      ExMarks.DBSpaceMark.Visible := True;
      break;
    end;
    if  (not CompareMem(PAnsiChar('全角'),PAnsiChar(s)+i-5,4))
      and (not CompareMem(PAnsiChar('半角'),PAnsiChar(s)+i-5,4)) then
    begin
      ExMarks.SpaceMark.Visible := True;
      ExMarks.DBSpaceMark.Visible := True;
      break;
    end;
    i := PosEx('スペース',s, i+1);
  end;

  Marks.EofMark.Visible := (Pos('EOF',s) > 0);
  Marks.RetMark.Visible := (Pos('改行',s) > 0);
  *)
end;

procedure THiEditor.WMMousewheel(var Msg: TMessage);
begin
  if (Msg.WParam > 0) then
  begin
    { ホイールを奥に動かした時の処理 }
    Sendmessage(Self.Handle, WM_VSCROLL, SB_LINEUP, 0);
  end
  else
  begin
    { ホイールを手前に動かした時の処理 }
    Sendmessage(Self.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
  end;
end;

procedure THiEditor.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure THiEditor.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure THiEditor.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{ TfrmNako }

procedure TfrmNako.ClearScreen(col: Integer);
begin
  with Self.backBmp.Canvas do
  begin
    Pen.Style   := psSolid;
    Pen.Color   := col;

    Brush.Style := bsSolid;
    Brush.Color := col;
  end;
  Self.backBmp.Canvas.Rectangle(0,0,Self.Width, Self.Height);
end;

procedure TfrmNako.FormCreate(Sender: TObject);
var
  p: PHiValue;
begin
  //----------------------------------------------------------------------------
  // Windows Vista ALT キーの問題
  // TVistaAltFix.Create(Self);
  //----------------------------------------------------------------------------
  // 初期化処理
  ClientWidth  := 640;
  ClientHeight := 400;
  FFlagFree := False;

  // 背景ビットマップ
  backBmp := TBitmap.Create;
  
  backBmp.Width := Self.ClientWidth;
  backBmp.Height := Self.ClientHeight;
  backBmp.Canvas.Brush.Color := clWhite;
  backBmp.Canvas.Pen.Color := clWhite;
  backBmp.Canvas.Rectangle(0,0,backBmp.Width, backBmp.Height);

  freeObjList := TList.Create;

  self.Color := clWhite;

  flagNowClose := False;
  flagRepaint  := True;
  flagClose    := False;
  flagDragMove := False;
  flagBokanSekkei := False;

  IsLiveTaskTray := False;
  edtPropNormal := nil;

  //----------------------------------------------------------------------------
  // 自身が母艦かどうか判断
  if FlagBokan = False then
  begin
    // 母艦
    {$IFDEF IS_LIBVNAKO}
    {$ELSE}
    Application.Title := 'なでしこ';
    {$ENDIF}
    IsBokan   := True;
    FlagBokan := True;
    Bokan     := Self;

    // 必ず 0 が母艦となる
    Self.Tag := 0;
    with GuiInfos[0] do
    begin
      obj      := Self;
      obj_type := VCL_GUI_FORM;
      name     := '母艦';
    end;
    with Bokan do begin
      OnKeyDown   := eventKeyDown;
      OnKeyUp     := eventKeyUp;
      OnKeyPress  := eventKeyPress;
      OnMouseDown := eventMouseDown;
      OnMouseMove := eventMouseMove;
      OnMouseUp   := eventMouseUp;
      OnMouseEnter:= eventMouseEnter;
      OnMouseLeave:= eventMouseLeave;
      OnMouseWheel:= eventMouseWheel;
      OnClick     := eventClick;
      OnDblClick  := eventDblClick;
      //OnPaint     := eventPaint;
      //OnResize    := eventSizeChange;
      //OnClick     := eventClick;
      //OnDblClick  := eventDblClick;
    end;
    //--------------------------------------------------------------------------
    // 初期化

    //
    DebugEditorHandle := 0;
    UseDebug := False;
    UseLineNo := False;
    //
    // なでしこのプログラムをロード
    if _flag_vnako_exe then
    begin
      if not Nadesiko_Load then Halt;
    end;
    
    // 例外的に母艦設計イベントの実行
    p := nako_getVariable('母艦設計');
    if p <> nil then
    begin
      flagBokanSekkei := True;
      if p^.VType = varStr then
      begin
        nako_eval_str2('EVAL(母艦設計)');
      end else
      begin
        nako_eval_str2('母艦設計');
      end;
      flagBokanSekkei := False;
    end;
    nako_eval('!変数宣言が不要');

    // メインの実行
    if _flag_vnako_exe then
    begin
      timerRunScript.Enabled := True;
    end;
  end else
  begin
    // 母艦ではない２つ目以降のフォーム
    IsBokan := False;
  end;

end;

function TfrmNako.Nadesiko_Load: Boolean;
var
  s, err   : AnsiString;
  res, len : Integer;
  flag_out_error : Boolean;

  procedure errLoad;
  var s: string;
  begin
    if flag_out_error then Exit;
    flag_out_error := True;
      s :=  '「===========================================================」と表示。'#13#10+
            '『日本語プログラミング言語「なでしこ」』と表示。'#13#10+
            '「===========================================================」と表示。'#13#10+
            '「プログラムを実行ファイル(vnako.exe)へドロップしてください。」と表示。'#13#10+
            '「　」と表示。'#13#10+
            '「> ナデシコバージョン = {ナデシコバージョン}」と表示。'#13#10+
            '「> ナデシコ最終更新日 = {ナデシコ最終更新日}」と表示。'#13#10;
      try
        nako_eval_str2(AnsiString(s));
      except
        ShowWarn(s);
      end;
  end;


  function _checkArg: Integer;
  var
    fname  : string;
    fnamea : AnsiString;
    i      : Integer;
    s, path: string;
    params : string;
    p      : PHiValue;
    sl     : TStringList;
  begin
    i := 1;
    fname := ''; params := ''; UseLineNo := False;
    while (ParamCount >= i) do
    begin
      s := (ParamStr(i));
      {$IFDEF FMPMODE}
      if s = '-setkey' then begin
        Inc(i);
        if ParamStr(i) = _fmp_key1 then
        begin
          _flag_fmp_key_enabled := true;
          inc(i);
          Continue;
        end;
      end;
      if s = '-killsrc' then begin
        Inc(i);
        _flag_fmp_remove_src := True;
        Continue;
      end;
      {$ENDIF}
      params := params + s + #13#10;
      if Copy(LowerCase(s),1,6) = '-debug' then
      begin
        // DEBUG MODE
        getToken_s(s, '::');
        DebugEditorHandle := StrToIntDef(s,0);
        nako_setDebugEditorHandle(DebugEditorHandle);
        UseDebug := True;
        Inc(i);
      end else
      if LowerCase(s) = '-lineno' then
      begin
        nako_setDebugLineNo(True);
        UseLineNo := True;
        Inc(i);
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
    {$IFDEF FMPMODE}
    if not _flag_fmp_key_enabled then Halt;
    {$ENDIF}
    //----------------------------------
    // command
    p := nako_getVariable('コマンドライン');
    if p = nil then p := hi_var_new('コマンドライン');
    nako_var_clear(p); // clear
    nako_ary_create(p);
    sl := TStringList.Create ;
    try
      sl.Text := Trim(params);
      for i := 0 to sl.Count - 1 do
      begin
        nako_ary_add(p, hi_newStrU(sl.Strings[i]));
      end;
    finally
      sl.Free;
    end;

    // bokan
    p := nako_getVariable('母艦パス');
    if p = nil then p := hi_var_new('母艦パス');
    path := ExtractFilePath(fname);
    if path = '' then path := ExtractFilePath(ParamStr(0));
    hi_setStrU(p, path);

    // debugEditorHandle
    p := nako_getVariable('デバッグエディタハンドル');
    hi_setInt(p, DebugEditorHandle);

    // load
    fname := Trim(fname);
    fnamea := AnsiString(fname);
    if fname <> '' then Result := nako_load(PAnsiChar(fnamea))
                   else Result := 0;
    FMainFile := fnamea;
  end;

  function _runDefaultFile(fname: AnsiString): DWORD;
  var p: PHiValue; path: AnsiString;
  begin
    // (ExeName).nako での起動
    p := nako_getVariable('母艦パス');
    if p = nil then p := hi_var_new('母艦パス');
    path := AnsiString(ExtractFilePath(string(fname)));
    if path = '' then path := AnsiString(ExtractFilePath(ParamStr(0)));
    hi_setStr(p, path);
    //
    Result := nako_load(PAnsiChar(fname));
    FMainFile := fname;
  end;

  procedure msg(s: AnsiString); // for DEBUG
  begin
  end;

  procedure __runFromPackfile;
  begin
    // --- 実行ファイルからの実行 ----------------------------------------------
    msg('read packfile');
    try
      msg('load vnako.nako');
      _dnako_loader.includeLib('vnako.nako');
      setBokanHensu;
      _dnako_loader.checkBokanPath;
    except
      on e: Exception do
        raise Exception.Create('梱包ファイル"vnako.nako"の展開に失敗しました。'#13#10+
          '製作者に連絡してください。'#13#10 + e.Message);
    end;
    try
      msg('run packfile');
      res := nako_runPackfile;
    except
      on e: Exception do begin
        errLoad;
        raise Exception.Create('メイン梱包ファイルの展開に失敗しました。'#13#10+
          '開発者または製造元へ連絡してください。'#13#10 + '--------------'#13#10 + e.Message);
      end;
    end;
    FMainFile := AnsiString(ParamStr(0));
  end;

  procedure __runFromCommandLine;
  begin
    // --- コマンドラインからの実行 --------------------------------------------
    if ParamCount = 0 then
    begin
      s := AnsiString(ExtractFilePath(ParamStr(0)) + 'default.nako');
      if FileExists(string(s)) then
      begin
        _dnako_loader.includeLib('vnako.nako');
        setBokanHensu;
        res := _runDefaultFile(s);
      end else
      begin
        errLoad; Exit;
      end;
    end else
    begin
      _dnako_loader.includeLib('vnako.nako');
      setBokanHensu;
      res := _checkArg;
    end;
  end;

begin
  //--------------------------------
  // todo: メインプログラムのロード
  //--------------------------------
  Result := True;
  res    := nako_OK;
  flag_out_error := False;
  try
    _dnako_loader := TDnakoLoader.Create(Self.Handle);
  except
    ShowError('なでしこエンジンのロードに失敗しました。','ランタイムエラー');
    Result := False;
    Exit;
  end;
  try
    // vnako の関数を登録
    RegistCallbackFunction(Self.Handle);
    nako_addFileCommand;
    {$IFDEF FMPMODE}
    nako_setVariable('noload_libvnako',hi_newBool(True));
    {$ENDIF}
    nako_LoadPlugins;
    _dnako_success := True;
  except on e:Exception do
    raise Exception.Create('モジュールのロードに失敗しました。' + #13#10 +
      e.Message);
  end;
  try
    try
      if _dnako_loader.hasPackfile then
      begin
        __runFromPackfile;
      end else
      begin
        __runFromCommandLine;
      end;
    finally
      // don't free _dnako_loader
    end;
  except
    on e:Exception do
    begin
      errLoad;
      Exit;
    end;
  end;

  // ロード結果
  if res = nako_NG then
  begin
    msg('error load ng');
    // プログラムの実行に失敗したとき
    len := nako_getError(nil, 0);
    if len > 0 then
    begin
      // エラーの取得
      SetLength(err, len);
      nako_getError(PAnsiChar(err), len);
      // MessageBox(Self.Handle, PAnsiChar(err), '文法エラー', MB_OK or MB_ICONERROR);
      with frmError do begin
        edtMain.Lines.Text  := ERRMSG_HEADER + PAnsiChar(err);
        btnDebug.Visible    := False;
        btnContinue.Visible := False;
        btnClose.Visible    := True;
      end;
      ShowModalCheck(frmError, Self);
      if frmError.FlagEnd then Self.Close;
    end else
    begin
      // たぶんファイル名がなかった...
      errLoad; Exit;
    end;
    Exit;
  end;

end;

procedure TfrmNako.FormShow(Sender: TObject);
begin
  //----------------------------------------------------------------------------
  if not _dnako_success then Exit;
  if IsBokan then
  begin
    with bokan do begin
      OnShow        := eventShow;
      OnCloseQuery  := eventClose;
    end;
  end;

  if Assigned(Self.OnShow) then
  begin
    eventShow(Self);
    Self.Invalidate;
  end;
end;

function TfrmNako.GetBackCanvas: TCanvas;
begin
  Result := backBmp.Canvas;
end;

function TfrmNako.GetRect: TRect;
begin
  windows.GetWindowRect(Bokan.Handle, Result);
end;

procedure TfrmNako.timerRunScriptTimer(Sender: TObject);
var
  len: Integer; s: AnsiString;

  procedure err;
  var b: DWORD;
  begin
    len := nako_getError(nil,0);
    SetLength(s, len + 1);
    nako_getError(PAnsiChar(s), len);

    with frmError do
    begin
      Caption := string(hi_str(nako_getVariable('エラーダイアログタイトル')));
      edtMain.Lines.Text  := string(PAnsiChar(s));
      btnDebug.Visible    := True;
      btnContinue.Visible := True;
      btnClose.Visible    := True;
      ShowModalCheck(frmError, Bokan);
      if frmError.FlagEnd then Close;

      nako_continue;
      b := nako_error_continue;
      if b = nako_NG then err;
      
    end;
  end;

begin
  timerRunScript.Enabled := False;
  nako_setMainWindowHandle(Self.Handle);

  if nako_run = NAKO_NG then
  begin
    err;
  end else
  begin
    // 初期実行終了後、初めてのイベント
    nako_group_exec(nako_getVariable('母艦'), '表示した時');
  end;

  self.Invalidate;
end;

procedure TfrmNako.FormPaint(Sender: TObject);
begin
  //
  BitBlt(
    Self.Canvas.Handle,    0, 0, Self.ClientWidth, Self.ClientHeight,
    BackBmp.Canvas.Handle, 0, 0, SRCCOPY);
  eventPaint(self);
end;

procedure TfrmNako.onExitSizeMove(var Msg: TMessage);
begin
  // 内側領域の作り直し
  ResizeBackBmp;
end;

procedure UpdateAfterEvent(o: TObject);
begin
  if o is TfrmNako then
  begin
    bokan.flagRepaint := True;
  end else
  if o is TWinControl then
  begin
    if TWinControl(o).Parent = nil then
    begin
      InvalidateRect(TWinControl(o).Handle, nil, False);
    end else
    begin
      InvalidateRect(TWinControl(o).Parent.Handle, nil, False);
    end;
  end;
end;

procedure TfrmNako.eventClick(Sender: TObject);
var
   ginfo: PGuiInfo;
begin
  ginfo := @GuiInfos[ TControl(Sender).Tag ];
  doEvent(ginfo, EVENT_CLICK);
end;

procedure TfrmNako.eventChange(Sender: TObject);
var
   ginfo: PGuiInfo;
begin
  ginfo := @GuiInfos[ TControl(Sender).Tag ];
  doEvent(ginfo, EVENT_CHANGE);
end;

procedure TfrmNako.eventDblClick(Sender: TObject);
var
   ginfo: PGuiInfo;
begin
  ginfo := @GuiInfos[ TControl(Sender).Tag ];
  doEvent(ginfo, EVENT_DBLCLICK);
end;

procedure TfrmNako.eventChangeTrackBox(Sender: Tobject; SZf: Boolean);
var
   ginfo: PGuiInfo;
begin
  ginfo := @GuiInfos[ TControl(Sender).Tag ];
  doEvent(ginfo, EVENT_SIZE_CHANGE);
end;

procedure TfrmNako.eventSizeChange(Sender: TObject);
var
   ginfo: PGuiInfo;
begin
  ginfo := @GuiInfos[ TControl(Sender).Tag ];
  doEvent(ginfo, EVENT_SIZE_CHANGE);
end;

procedure TfrmNako.eventShow(Sender: TObject);
var
   ginfo: PGuiInfo;
begin
  ginfo := @GuiInfos[ TControl(Sender).Tag ];
  doEvent(ginfo, EVENT_SHOW);
end;

procedure TfrmNako.eventClose(Sender: TObject; var CanClose: Boolean);
var
   ginfo: PGuiInfo;
  p: PHiValue;
begin
  flagClose := True;

  if flagNowClose then
  begin
    flagClose := False;
    CanClose  := False; Exit;
  end;

  if not _dnako_success then Exit;
  if FFlagFree then Exit;

  flagNowClose := True;
  try

    ginfo := @GuiInfos[ TControl(Sender).Tag ];

    nako_continue;
    doEvent(ginfo, EVENT_CLOSE);

    p := nako_getGroupMember(PAnsiChar(ginfo.name), '終了可能');
    if (p<>nil)and(hi_int(p) = 0) then
    begin
      nako_continue;
      flagClose := False;
      CanClose := False;
      Exit;
    end;
    if self = Bokan then nako_stop;

    if DebugEditorHandle > 0 then
    begin
      SendCOPYDATA( DebugEditorHandle, 'stop', 0, self.Handle);
    end;

    {$IFDEF FMPMODE}
    if _flag_fmp_remove_src then
    begin
      try
        DeleteFile(FMainFile);
      except
      end;
    end;
    {$ENDIF}

  finally
    flagNowClose := False;
  end;
end;

procedure TfrmNako.eventTreeViewChange(Sender: TObject; Node: TTreeNode);
var
   ginfo: PGuiInfo;
begin
  ginfo := @GuiInfos[ TControl(Sender).Tag ];
  doEvent(ginfo, EVENT_CHANGE);
end;

procedure TfrmNako.eventPaint(Sender: TObject);
var
   ginfo: PGuiInfo;
begin
  ginfo := @GuiInfos[ TControl(Sender).Tag ];
  doEvent(ginfo, EVENT_PAINT);
end;

procedure TfrmNako.Redraw;
begin
  FormPaint(nil);
end;

procedure setShift(pinfo: PGuiInfo; Shift: TShiftState);
var p: PHiValue; s: AnsiString;
begin
  p := nako_getGroupMember(PAnsiChar(pinfo^.name), 'シフトキー');
  if p <> nil then
  begin
    s := '';
    if ssShift in Shift then s := s + 'SHIFT,';
    if ssCtrl  in Shift then s := s + 'CTRL,';
    if ssAlt   in Shift then s := s + 'ALT,';
    if s <> '' then System.Delete(s, Length(s), 1);
    hi_setStr(p, s);
  end;
end;

procedure TfrmNako.eventMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ginfo: TGuiInfo;
  p: PHiValue;
begin
  if not _dnako_success then Exit;
  if FFlagFree then Exit;
  //
  ginfo := GuiInfos[ TControl(Sender).Tag ];
  p := nako_getGroupMember(PAnsiChar(ginfo.name), EVENT_MOUSEDOWN);
  if (p=nil)or(p.ptr=nil) then Exit; //

  p := nako_getGroupMember(PAnsiChar(ginfo.name), '押されたボタン');
  if p <> nil then begin
    if Button = mbLeft   then hi_setStr(p, '左') else
    if Button = mbRight  then hi_setStr(p, '右') else
    if Button = mbMiddle then hi_setStr(p, '中央');
  end;
  p := nako_getGroupMember(PAnsiChar(ginfo.name), 'マウスX');
  if p <> nil then hi_setInt(p, X);
  p := nako_getGroupMember(PAnsiChar(ginfo.name), 'マウスY');
  if p <> nil then hi_setInt(p, Y);
  setShift(@ginfo, Shift);

  doEvent(@ginfo, EVENT_MOUSEDOWN);
end;

procedure TfrmNako.eventMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  ginfo: TGuiInfo;
  pe, p: PHiValue;
begin
  if not _dnako_success then Exit;
  if FFlagFree then Exit;
  //
  ginfo := GuiInfos[ TControl(Sender).Tag ];

  pe := nako_getGroupMember(PAnsiChar(ginfo.name), EVENT_MOUSEMOVE);
  if (pe = nil)or(pe.ptr = nil) then Exit;

  p := nako_getGroupMember(PAnsiChar(ginfo.name), 'マウスX');
  if p <> nil then hi_setInt(p, X);
  p := nako_getGroupMember(PAnsiChar(ginfo.name), 'マウスY');
  if p <> nil then hi_setInt(p, Y);
  setShift(@ginfo, Shift);

  doEvent(@ginfo, EVENT_MOUSEMOVE);
end;

procedure TfrmNako.eventMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ginfo: TGuiInfo;
  p: PHiValue;
begin
  if not _dnako_success then Exit;
  if FFlagFree then Exit;
  //
  ginfo := GuiInfos[ TControl(Sender).Tag ];

  p := nako_getGroupMember(PAnsiChar(ginfo.name), EVENT_MOUSEUP);
  if (p=nil)or(p.ptr=nil) then Exit;

  p := nako_getGroupMember(PAnsiChar(ginfo.name), '押されたボタン');
  if p <> nil then begin
    if Button = mbLeft   then hi_setStr(p, '左') else
    if Button = mbRight  then hi_setStr(p, '右') else
    if Button = mbMiddle then hi_setStr(p, '中央');
  end;
  p := nako_getGroupMember(PAnsiChar(ginfo.name), 'マウスX');
  if p <> nil then hi_setInt(p, X);
  p := nako_getGroupMember(PAnsiChar(ginfo.name), 'マウスY');
  if p <> nil then hi_setInt(p, Y);

  setShift(@ginfo, Shift);

  doEvent(@ginfo, EVENT_MOUSEUP);
end;

procedure TfrmNako.eventMouseEnter(Sender: TObject);
var
  ginfo: TGuiInfo;
begin
  ginfo := GuiInfos[ TControl(Sender).Tag ];
  doEvent(@ginfo, EVENT_MOUSEENTER);
end;

procedure TfrmNako.eventMouseLeave(Sender: TObject);
var
  ginfo: TGuiInfo;
begin
  ginfo := GuiInfos[ TControl(Sender).Tag ];
  doEvent(@ginfo, EVENT_MOUSELEAVE);
end;

procedure TfrmNako.eventListOpen(Sender: TObject);
var
  ginfo: TGuiInfo;
begin
  ginfo := GuiInfos[ TControl(Sender).Tag ];
  doEvent(@ginfo, EVENT_LISTOPEN);
end;

procedure TfrmNako.eventListClose(Sender: TObject);
var
  ginfo: TGuiInfo;
begin
  ginfo := GuiInfos[ TControl(Sender).Tag ];
  doEvent(@ginfo, EVENT_LISTCLOSE);
end;

procedure TfrmNako.eventListSelect(Sender: TObject);
var
  ginfo: TGuiInfo;
begin
  ginfo := GuiInfos[ TControl(Sender).Tag ];
  doEvent(@ginfo, EVENT_LISTSELECT);
end;

procedure TfrmNako.doEvent(group: PGuiInfo; eventName: AnsiString);
var
  p, p2: PHiValue;
  n: AnsiString;
begin
  if FFlagFree then Exit;
  if not _dnako_success then Exit;
  if group.pgroup = nil then Exit; // 無効
  eventName := DeleteGobi(eventName);
  // グループにメンバが存在するか？
  try
    // Check Group
    p := nako_group_findMember(group.pgroup, PAnsiChar(eventName));
    if (p = nil)or(p.VType = varNil) then
    begin
      if group.name_id = 0 then
      begin
        group.name_id := nako_tango2id(PAnsiChar(group.name));
      end;
      group.pgroup := nako_getVariableFromId(group.name_id);
      p := nako_group_findMember(group.pgroup, PAnsiChar(eventName));
    end;
  except
    Exit;
  end;
  if p = nil then Exit;
  if (p.VType <> varFunc) then Exit;

  // イベント部品にコピー
  if EventObject = nil then EventObject := nako_getVariable('イベント部品');
  nako_varCopyGensi(group.pgroup, EventObject);
  try
    nako_continue;
    // イベントを eval する
    if (_flag_vnako_exe = False) then // libvnako.dll の場合：なぜか group 実行するとエラーがでる
    begin
      n := group.name + 'の' + eventName;
      nako_eval_str2(n);
    end else
    begin
      p2 := nako_group_exec(group.pgroup, PAnsiChar(eventName));
      nako_var_free(p2);
    end;
    UpdateAfterEvent(group.obj);
  except
    on e: Exception do
    begin
      // --- デバッグダイアログの起動
      frmError.Caption := hi_strU(nako_getVariable('エラーダイアログタイトル'));
      frmError.edtMain.Lines.Text := '' +
        '[' + string(group.name) + 'の' + string(eventName) + 'を実行中のエラー]'#13#10 +
        string(nako_getErrorStr);
        ;
      ShowModalCheck(frmError, Bokan);
    end;
  end;
end;

procedure TfrmNako.eventBrowserNavigate(Sender: TObject;
  const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
var
  ginfo: TGuiInfo;
  p: PHiValue;
begin
  ginfo := GuiInfos[ TControl(Sender).Tag ];

  p := nako_getGroupMember(PAnsiChar(ginfo.name), '移動先URL');
  if p <> nil then hi_setStrU(p, URL);

  doEvent(@ginfo, EVENT_CLICK);

  p := nako_getGroupMember(PAnsiChar(ginfo.name), '移動許可');
  if (p <> nil)and(hi_int(p) = 0) then begin
    Cancel := True;
  end;

end;

procedure TfrmNako.eventKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  ginfo: TGuiInfo;
  p: PHiValue;
begin
  if not _dnako_success then Exit;
  if FFlagFree then Exit;

  ginfo := GuiInfos[ TControl(Sender).Tag ];

  p := nako_getGroupMember(PAnsiChar(ginfo.name), EVENT_KEYDOWN);
  if (p=nil)or(p.ptr=nil) then Exit; // イベントはなし

  // 変数の設定
  //--------------
  // シフト
  setShift(@ginfo, Shift);
  // キー
  p := nako_getGroupMember(PAnsiChar(ginfo.name), '押された仮想キー');
  hi_setInt(p, Key);

  // イベント
  doEvent(@ginfo, EVENT_KEYDOWN);

  // キーの変更を反映
  Key := hi_int(p);
end;

procedure TfrmNako.eventKeyPress(Sender: TObject; var Key: Char);
var
  ginfo: TGuiInfo;
  p: PHiValue;
  s: AnsiString;
begin
  if not _dnako_success then Exit;
  if FFlagFree then Exit;
  //
  ginfo := GuiInfos[ TControl(Sender).Tag ];

  p := nako_getGroupMember(PAnsiChar(ginfo.name), EVENT_KEYPRESS);
  if (p=nil)or(p.ptr=nil) then Exit; // イベントはなし

  // 変数の設定
  // キー
  p := nako_getGroupMember(PAnsiChar(ginfo.name), '押されたキー');
  hi_setStrU(p, Key);

  // イベント
  doEvent(@ginfo, EVENT_KEYPRESS);

  // キーの変更を反映
  s := hi_str(p);
  if s = '' then Key := #0 else Key := Char(s[1]);
end;

procedure TfrmNako.eventKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  ginfo: TGuiInfo;
  p: PHiValue;
begin
  if not _dnako_success then Exit;
  if FFlagFree then Exit;
  //
  ginfo := GuiInfos[ TControl(Sender).Tag ];

  p := nako_getGroupMember(PAnsiChar(ginfo.name), EVENT_KEYUP);
  if (p=nil)or(p.ptr=nil) then Exit; // イベントはなし

  // 変数の設定
  // キー
  p := nako_getGroupMember(PAnsiChar(ginfo.name), '押された仮想キー');
  hi_setInt(p, Key);
  // シフト
  setShift(@ginfo, Shift);

  // イベント
  doEvent(@ginfo, EVENT_KEYUP);
end;

procedure TfrmNako.setStyle(s: AnsiString);
begin
  if s = '枠なし' then self.BorderStyle := bsNone else
  if s = '枠固定' then self.BorderStyle := bsSingle else
  if s = '枠可変' then self.BorderStyle := bsSizeable else
  if s = 'ダイアログスタイル' then self.BorderStyle := bsDialog else
  if s = 'ツールウィンドウ'   then self.BorderStyle := bsToolWindow else
  ;
  if Self = bokan then
  begin
    nako_setMainWindowHandle(Self.Handle);
  end;
end;

procedure TfrmNako.eventDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  ginfo: TGuiInfo;
  p: PHiValue;
begin
  ginfo := GuiInfos[ TControl(Sender).Tag ];

  p := nako_getGroupMember(PAnsiChar(ginfo.name), EVENT_DRAGOVER);
  if (p=nil)or(p.ptr=nil) then Exit; // イベントはなし

  // イベント
  doEvent(@ginfo, EVENT_DRAGOVER);

  // 変数の設定
  p := nako_getGroupMember(PAnsiChar(ginfo.name), 'ドロップ許可');
  if (p<>nil) then Accept := (hi_int(p) <> 0);
end;

procedure TfrmNako.eventDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  ginfo: TGuiInfo;
  p: PHiValue;
  node: TTreeNode;
begin
  ginfo := GuiInfos[ TControl(Sender).Tag ];

  p := nako_getGroupMember(PAnsiChar(ginfo.name), EVENT_DRAGDROP);
  if (p=nil)or(p.ptr=nil) then Exit; // イベントはなし

  // 変数の設定
  p := nako_getGroupMember(PAnsiChar(ginfo.name), 'マウスX');
  if (p<>nil) then hi_setInt(p, X);
  p := nako_getGroupMember(PAnsiChar(ginfo.name), 'マウスY');
  if (p<>nil) then hi_setInt(p, Y);
  if ginfo.obj is THiTreeView then
  begin
    node := THiTreeView(Sender).GetNodeAt(X, Y);
    if node <> nil then
      THiTreeView(Sender).dropPath := THiTreeNode(node.Data).GetTreePathText
    else
      THiTreeView(Sender).dropPath := '';
  end;

  // ドロップ部品の設定
  nako_eval_str(ginfo.name + 'のドロップ部品は、' + GuiInfos[TControl(Source).Tag].name);

  // イベント
  doEvent(@ginfo, EVENT_DRAGDROP);
end;

procedure TfrmNako.eventMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  ginfo: TGuiInfo;
  p: PHiValue;
begin
  ginfo := GuiInfos[ TControl(Sender).Tag ];

  p := nako_getGroupMember(PAnsiChar(ginfo.name), EVENT_MOUSEWHEEL);
  if (p=nil)or(p.ptr=nil) then Exit; // イベントはなし

  // 変数の設定
  p := nako_getGroupMember(PAnsiChar(ginfo.name), 'ホイール値');
  if (p<>nil) then hi_setInt(p, WheelDelta);

  // イベント
  doEvent(@ginfo, EVENT_MOUSEWHEEL);
end;

procedure TfrmNako.eventFileDrop(Sender: TObject; Num: Integer;
  Files: TStrings; X, Y: Integer);
var
  ginfo: TGuiInfo;
  p: PHiValue;
begin
  ginfo := GuiInfos[ TControl(TFileDrop(Sender).Control).Tag ];

  p := nako_getGroupMember(PAnsiChar(ginfo.name), EVENT_FILEDROP);
  if (p=nil)or(p.ptr=nil) then Exit; // イベントはなし

  // 変数の設定
  p := nako_getGroupMember(PAnsiChar(ginfo.name), 'ドロップファイル');
  if (p<>nil) then hi_setStrU(p, Trim(Files.Text));

  // イベント
  doEvent(@ginfo, EVENT_FILEDROP);
end;

procedure TfrmNako.CopyDataMessage(var WMCopyData: TWMCopyData);
var
  msg: AnsiString;
  ginfo: TGuiInfo;
  p: PHiValue;
  tm: TMessage;
begin
  ginfo := GuiInfos[ self.Tag ];

  msg := PAnsiChar( WMCopyData.CopyDataStruct.lpData );

  // マクロの実行など
  if (msg = 'break')and(WMCopyData.CopyDataStruct.dwData = 1001) then //エディタから強制ストップを受けた
  begin
    tm.WParam := WMCopyData.From;
    _WM_VNAKO_BREAK(tm);
  end else
  if (msg = 'break-all')and(WMCopyData.CopyDataStruct.dwData = 1001) then //エディタから強制ストップを受けた
  begin
    tm.WParam := WMCopyData.From;
    _WM_VNAKO_BREAK_ALL(tm);
  end else
  if (msg = 'pause')and(WMCopyData.CopyDataStruct.dwData = 1001) then //エディタから強制ストップを受けた
  begin
    tm.WParam := WMCopyData.From;
    _WM_VNAKO_STOP(tm);
  end else
  begin
    // ユーザーの定義イベント
    p := nako_getGroupMember(PAnsiChar(ginfo.name), 'CD文字列');
    if (p<>nil) then hi_setStr(p, msg);
    p := nako_getGroupMember(PAnsiChar(ginfo.name), 'CD_ID');
    if (p<>nil) then hi_setInt(p, WMCopyData.CopyDataStruct.dwData);
    //
    doEvent(@ginfo, EVENT_COPYDATA);
  end;
end;

procedure TfrmNako.eventTimer(Sender: TObject);
var
  ginfo: TGuiInfo;
begin
  ginfo := GuiInfos[ TControl(Sender).Tag ];
  doEvent(@ginfo, EVENT_TIMER);
end;

procedure TfrmNako.ResizeBackBmp;
var
  tmp: TBitmap;
begin
  // ビットマップの作り直し
  tmp := TBitmap.Create;
  tmp.Width := Self.ClientWidth;
  tmp.Height := Self.ClientHeight;

  // 背景
  with tmp.Canvas do begin
    Brush.Color := Self.Color;
    Brush.Style := bsSolid;
    Pen.Color   := Self.Color;
    Pen.Style   := psSolid;
    Rectangle(0,0,tmp.Width,tmp.Height);
  end;
  tmp.Canvas.Draw(0, 0, backBmp);

  //
  if backBmp = nil then
  begin
    backBmp := TBitmap.Create;
    with backBmp do begin
      Tag := Self.Tag;
      OnClick     := self.eventClick;
      OnDblClick  := self.eventDblClick;
      OnMouseDown := self.eventMouseDown;
      OnMouseMove := self.eventMouseMove;
      OnMouseUp   := self.eventMouseUp;
      OnMouseEnter:= self.eventMouseEnter;
      OnMouseLeave:= self.eventMouseLeave;
      OnMouseWheel:= self.eventMouseWheel;
    end;
    Self.DoubleBuffered := True;
  end;
  backBmp.Assign(tmp);
  FreeAndNil(tmp);
end;


procedure TfrmNako.FinishTasktray;
begin
  if IsLiveTasktray = False then exit;
  with NotifyIcon do
  begin
    cbSize := SizeOf(TNotifyIconData);
    Wnd := Handle;
    uID := 1;
  end;
  Shell_NotifyIcon(NIM_DELETE, @NotifyIcon);
  IsLiveTasktray := False;

end;

procedure TfrmNako.InitTasktray;
begin
  if IsLiveTasktray then exit;
  with NotifyIcon do
  begin
    cbSize := SizeOf(TNotifyIconData);
    Wnd := Handle;
    uID := 1;
    uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
    uCallbackMessage := WM_NotifyTasktray;
    if Self.Icon.Handle > 0 then
      hIcon := Self.Icon.Handle
    else
      hIcon := Application.Icon.Handle;
    StrLCopy(@szTip[0],PChar(Self.Caption), 63);
  end;
  Shell_NotifyIcon(NIM_ADD,@NotifyIcon);
  IsLiveTasktray := True;
end;

procedure TfrmNako.LeaveTasktray(RestoreForm:Boolean = True);
begin
  FinishTasktray;
  if RestoreForm then
  begin
    Application.Restore;
    Application.ShowMainForm := True;
    ShowWindow(Application.Handle,SW_NORMAL);
    Self.Visible := True; //**
  end;
end;

procedure TfrmNako.MovetoTasktray(HideForm:Boolean = True);
begin
  if flagBokanSekkei then
  begin
    if HideForm then
    begin
      Application.ShowMainForm := False;
    end;
  end;
  InitTasktray;
  if HideForm then
  begin
    Hide;
    ShowWindow(Application.Handle,SW_HIDE);
  end;
end;

procedure TfrmNako.wmNotifyTasktray(var Msg: TMessage);
begin
  case Msg.LParam of
    WM_LBUTTONDOWN: doEvent(@GuiInfos[0], 'タスクトレイクリックした時');
    WM_RBUTTONDOWN: doEvent(@GuiInfos[0], 'タスクトレイ右クリックした時');
    WM_MOUSEMOVE:   doEvent(@GuiInfos[0], 'タスクトレイ通過した時');
  end;
end;

procedure TfrmNako._WM_VNAKO_BREAK(var Msg: TMessage);
begin
  if (THandle(DebugEditorHandle) = THandle(Msg.LParam)) then
  begin
    nako_stop;
    FinishTasktray;
    Close;
  end;
end;

procedure TfrmNako._WM_VNAKO_BREAK_ALL(var Msg: TMessage);
begin
  if Self.Handle <> THandle(Msg.LParam) then // 自分自身以外を終了
  begin
    nako_stop;
    FinishTasktray;
    Close;
  end;
end;

procedure TfrmNako._WM_VNAKO_STOP(var Msg: TMessage);
begin
  Application.ProcessMessages;
  if (THandle(DebugEditorHandle) = THandle(Msg.LParam)) then
  begin
    ShowModalCheck(frmDebug(Self), Bokan);
  end;
end;

procedure TfrmNako.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if flagDragMove then
  begin
    FDragPoint := POINT(X, Y);
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TfrmNako.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if flagDragMove then
  begin
    if GetKeyState(VK_LBUTTON) < 0 then
      SetBounds(Left + X - FDragPoint.x, Top + Y - FDragPoint.y, Width, Height);
  end;
end;
{
procedure TfrmNako.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  inherited;
  BitBlt(
    Self.Canvas.Handle,    0, 0, Self.ClientWidth, Self.ClientHeight,
    BackBmp.Canvas.Handle, 0, 0, SRCCOPY);
end;
}

procedure TfrmNako.ChangeTrayIcon;
begin
  if not IsLiveTasktray then exit;

  with NotifyIcon do
  begin
    cbSize := SizeOf(TNotifyIconData);
    Wnd := Handle;
    uID := 1;
    uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
    uCallbackMessage := WM_NotifyTasktray;
    if Self.Icon.Handle > 0 then
      hIcon := Self.Icon.Handle
    else
      hIcon := Application.Icon.Handle;
    StrLCopy(@szTip[0],PChar(Self.Caption), 63);
  end;
  Shell_NotifyIcon(NIM_MODIFY, @NotifyIcon);
  IsLiveTasktray := True;
end;

procedure TfrmNako.eventNavigateComplete(Sender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
var
  ginfo: PGuiInfo;
begin
  ginfo := @(GuiInfos[ TControl(Sender).Tag ]);
  ginfo.freetag := 0;
  doEvent(ginfo, '完了した時');
end;

procedure TfrmNako.eventBrowserDocumentComplete(Sender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
var
  ginfo: PGuiInfo;
begin
  ginfo := @(GuiInfos[ TControl(Sender).Tag ]);
  ginfo.freetag := 0;
  doEvent(ginfo, '文書完了した時');
end;

procedure TfrmNako.eventBrowserDownloadComplete(Sender: TObject);
var
  ginfo: PGuiInfo;
begin
  ginfo := @GuiInfos[ TControl(Sender).Tag ];
  ginfo.freetag := 0;
  doEvent(ginfo, 'ダウンロード完了した時');
end;


procedure TfrmNako.eventBrowserNewWindow2(Sender: TObject;
  var ppDisp: IDispatch; var Cancel: WordBool);
var
  ginfo: PGuiInfo;
  p: PHiValue;
  w: TUIWebBrowser;
begin
  ginfo := @GuiInfos[ TControl(Sender).Tag ];
  doEvent(ginfo, '新窓開いた時');

  // 禁止？
  p := nako_group_findMember(ginfo.pgroup, '新窓禁止');
  if p=nil then raise Exception.Create('メンバ『新窓用ブラウザ名』がありません。');
  if hi_bool(p) then
  begin
    Cancel := True; Exit;
  end;

  // 新しく開くウインドウについて
  p := nako_group_findMember(ginfo.pgroup, 'F新窓用ブラウザ');
  if (p <> nil)and(p^.VType <> varNil) then
  begin
    try
      w := TUIWebBrowser(hi_int(p));
      w.RegisterAsBrowser := True;
      ppDisp := w.Application ;
    except
    end;
  end;
  
end;

procedure TfrmNako.eventTEditorDropFile(Sender: TObject; Drop,
  KeyState: Integer; Point: TPoint);
var
  ginfo: PGuiInfo;
  p: PHiValue;
  s: AnsiString;
begin
  ginfo := @GuiInfos[ TMemo(Sender).Tag ];

  p := nako_getGroupMember(PAnsiChar(ginfo.name), EVENT_FILEDROP);
  if (p=nil)or(p.ptr=nil) then Exit; // イベントはなし

  // TODO:変数の設定
  //s := THiEditor(ginfo.obj).DropFileNames.Text;
  s := 'NOT SIUPPORTED';
  p := nako_getGroupMember(PAnsiChar(ginfo.name), 'ドロップファイル');
  if (p<>nil) then hi_setStr(p, TrimA(s));

  // イベント
  doEvent(ginfo, EVENT_FILEDROP);
end;

function FirstDriveFromMask (unitmask: DWORD): Char;
var
  i: Integer;
begin
  Result := #0;
  for i := 0 to 25 do
  begin
    if (unitmask and $1) > 0 then
    begin
      Result := Char(i + Ord('A'));
      break;
    end;
    unitmask := unitmask shr 1;
  end;
end;

procedure TfrmNako.wmDevChange(var Msg: TMessage);
var
  //buf: AnsiString;
  dev: PDEV_BROADCAST_HDR;
  vol: PDEV_BROADCAST_VOLUME;
  drive: Char;
begin
  dev := Pointer(Msg.LParam);
  // デバイスイベント
  case Msg.WParam of
    DBT_DEVICEARRIVAL:
      begin
        if dev.dbch_devicetype = DBT_DEVTYP_VOLUME then
        begin
          vol := PDEV_BROADCAST_VOLUME(dev);
          //if (vol.dbcv_flags and DBTF_MEDIA) > 0 then
          begin
            drive := FirstDriveFromMask(vol.dbcv_unitmask);
            hi_setStrU(nako_getSore, string(drive));
            doEvent(@GuiInfos[0], 'デバイス挿入した時');
          end;
        end;
      end;
    DBT_DEVICEREMOVECOMPLETE:
      begin
        if dev.dbch_devicetype = DBT_DEVTYP_VOLUME then
        begin
          vol := PDEV_BROADCAST_VOLUME(dev);
          //if (vol.dbcv_flags and DBTF_MEDIA) > 0 then
          begin
            drive := FirstDriveFromMask(vol.dbcv_unitmask);
            hi_setStrU(nako_getSore, string(drive));
            doEvent(@GuiInfos[0], 'デバイス削除した時');
          end;
        end;
      end;
  end;
end;

procedure TfrmNako.SetBokanHensu;
var b, p, f: PHiValue;
begin
  f := nako_getVariable('フォーム');
  if f = nil then raise Exception.Create('vnako.nakoの取り込みに失敗');
  //
  b := nako_var_new('母艦');
  nako_varCopyData(f, b);
  p := nako_group_findMember(b, '名前');
  hi_setStr(p, '母艦');
  GuiInfos[0].pgroup := b;
  p := nako_group_findMember(GuiInfos[0].pgroup,'オブジェクト');
  //
  hi_setInt(p, Integer(bokan));
end;

procedure TfrmNako.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure TfrmNako.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TfrmNako.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{ THiListView }

constructor THiListView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  nodes := THHash.Create;
end;

destructor THiListView.Destroy;
begin
  nodes.Free;
  inherited;
end;

procedure THiListView.CMMouseEnter(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  _TrackMouseEvent(Self.Handle,FHoverTime);
end;

procedure THiListView.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure THiListView.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{ THiWinControl }

function THiWinControl.hi_getDragMode: AnsiString;
begin
  if Self.DragMode = dmManual then Result := '0' else Result := '1';
end;

procedure THiWinControl.hi_setDragMode(s: AnsiString);
begin
  if (s = 'オフ')or(s = '0') then Self.DragMode := dmManual else
                                  Self.DragMode := dmAutomatic;
end;

procedure InitGuiInfos;
var i: Integer;
begin
  for i := 0 to High(GuiInfos) do
  begin
    GuiInfos[i].pgroup := nil;
    GuiInfos[i].obj    := nil;
    GuiInfos[i].name   := '';
    GuiInfos[i].obj_type := 0;
    GuiInfos[i].fileDrop := nil;
  end;
end;

procedure FreeGuiInfos;
var i: Integer;
begin
  for i := 0 to guiCount-1 do
  begin
    FreeAndNil( GuiInfos[i].fileDrop );
  end;
end;

procedure TfrmNako.AppEventIdle(Sender: TObject; var Done: Boolean);
var
  i: Integer;
  p: TObject;
begin
  if flagRepaint then
  begin
    Self.Redraw;
    InvalidateRect(Self.Handle, nil, False);
    flagRepaint := False;
  end;
  //
  if freeObjList.Count > 0 then
  begin
    for i := 0 to freeObjList.Count - 1 do
    begin
      try
        p := freeObjList.Items[i];
        FreeAndNil(p);
      except
        // 壊れていくものなのでエラーを無視。
      end;
    end;
    freeObjList.Clear;
  end;
end;

procedure TfrmNako.FormResize(Sender: TObject);
begin
  // ビットマップの作り直し処理
  ResizeBackBmp;

  // ユーザーイベントを実行する
  eventSizeChange(self);
end;

procedure TfrmNako.FormDestroy(Sender: TObject);
begin
  FreeAndNil(freeObjList); // これをいちいち解放しなくても自動でGUIデータは解放される
  FFlagFree := True;
  FreeAndNil(_dnako_loader);
  if _dnako_success then
  begin
    // 終了時の例外を無視するように
    try
      nako_free;
    except
    end;
  end;
end;

procedure TfrmNako.FormClose(Sender: TObject; var Action: TCloseAction);
var
  s: AnsiString;
begin
  if not _dnako_success then Exit;
  if FFlagFree then Exit;

  FinishTasktray;
  // ---------------------------------------
  // 実行レポートを保存する
  // ---------------------------------------
  if UseDebug then
  begin
    s := AnsiString(ExtractFilePath(ParamStr(0)) + 'report.txt');
    try
      nako_makeReport(PAnsiChar(s));
    except
      MessageBox(Self.Handle,'report.txtの作成に失敗しました。','なでしこ',MB_OK or MB_ICONERROR);
    end;
  end;
end;

procedure TfrmNako.FormActivate(Sender: TObject);
var
  ginfo: TGuiInfo;
begin
  ginfo := GuiInfos[ TControl(Sender).Tag ];
  doEvent(@ginfo, EVENT_ACTIVATE);
end;

procedure TfrmNako.AppEventActivate(Sender: TObject);
var
  ginfo: TGuiInfo;
begin
  ginfo := GuiInfos[ 0 ];
  doEvent(@ginfo, EVENT_ACTIVATE2);
  Self.Invalidate; // Vistaで Form 上のボタンが消える問題の対処
end;

procedure TfrmNako.AppEventDeactivate(Sender: TObject);
var
  ginfo: TGuiInfo;
begin
  ginfo := GuiInfos[ 0 ];
  doEvent(@ginfo, EVENT_DEACTIVATE);
end;

procedure TfrmNako.AppEventMinimize(Sender: TObject);
var
  ginfo: TGuiInfo;
begin
  ginfo := GuiInfos[ 0 ];
  doEvent(@ginfo, EVENT_MINIMIZE);
end;

procedure TfrmNako.AppEventRestore(Sender: TObject);
var
  ginfo: TGuiInfo;
begin
  ginfo := GuiInfos[ 0 ];
  doEvent(@ginfo, EVENT_RESTORE);
  Self.Invalidate; // Vista で画面のコンポーネントが消える問題に対処
end;

initialization
  InitGuiInfos;

finalization
  FreeGuiInfos;

end.
