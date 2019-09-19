
unit frmNakoU;

interface

uses
  // Windows Unit
  Windows, Messages,
  // Delphi Unit
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus, ValEdit, Grids, ComCtrls, Spin,
  AppEvnts, ShellAPI, Math,
  // nadesiko unit
  dnako_loader, unit_pack_files, hima_types, dnako_import_types,
  unit_string, vnako_function, unit_tree_list,
  // Added Component
  TrackBox,Buttons,
  // XPManifest
{$IF RTLVersion >=15}
  XPMan, VistaAltFixUnit,
{$IFEND}
  vnako_message,
  // TEditor Support
  heClasses, HEdtProp, EditorExProp,
  EditorEx, heRaStrings
  ;

const
  WM_NotifyTasktray = WM_USER + 100;

type
  TNotifyIconDataVistaA = record
    cbSize:Integer;
    Wnd:HWND;
    uID:Integer;
    uFlags:Integer;
    uCallbackMessage:Integer;
    hIcon:HICON;
    szTip:array[0..127] of char;
    dwState:Integer;
    dwStateMask:Integer;
    szInfo:array[0..255] of char;
    uTimeout:Integer;
    szInfoTitle:array[0..63] of char;
    dwInfoFlags:Integer;
    guidItem:TGUID;
    hBalloonIcon:HICON;
  end;
  
  THiEditor = class(TEditorEx)
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
    edtPropNormal: TEditorExProp;
    XPManifest: TXPManifest;
    timerFormWakeUp: TTimer;
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
    procedure timerFormWakeUpTimer(Sender: TObject);
  private
    { Private �錾 }
    FFlagFree: Boolean;
    DebugEditorHandle: Integer;
    FDragPoint: TPoint;
    FHoverTime : Cardinal;
    SaveFPUMask: TFPUExceptionMask; // �s���ȕ��������_�����Z���߃G���[����̂���
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
    // �h���b�O���ăt�H�[�����ړ�����ꍇ
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    //procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;

  // �^�X�N�g���C�ւ̏풓�@�\�̂���
  private
    NotifyIcon: TNotifyIconDataVistaA;
    NotifyIconSize: Integer; // V1(NT)=88 V2(2K)=488 V3(XP)=504 V4(Vista)=508
    procedure wmNotifyTasktray(var Msg: TMessage); message WM_NotifyTasktray;
    procedure wmDevChange(var Msg: TMessage); message WM_DEVICECHANGE;
  public
    FTempX, FTempY: Integer; // �X�^�C���ύX�ɂ����č��W���������ݒ肳��Ȃ����(@761)
    IsLiveTasktray: boolean;
    dwBalloonOption: Integer;
    bBalloonRealtime: boolean;
    bBalloonHideTitle: boolean;
    procedure InitTasktray;
    procedure FinishTasktray;
    procedure ChangeTrayIcon;
    procedure MovetoTasktray(HideForm:Boolean = True); // �^�X�N�g���C�ֈړ�
    procedure LeaveTasktray(RestoreForm:Boolean = True);  // �^�X�N�g���C�𗣂��
    procedure ShowBalloon(message:string); // �o���[���\��
    procedure HideBalloon(); // �o���[���폜
  public
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  public
    { Public �錾 }
    freeObjList: TList; // VCL_FREE �Œǉ������
    IsBokan: Boolean;
    flagBokanSekkei: Boolean;
    flagRepaint: Boolean; // �ĕ`�悪�K�v���H

    flagNowClose: Boolean; // CloseQuery�̎��s�����ǂ���
    flagClose: Boolean;    // ����ׂ����ǂ���

    flagDragMove: Boolean;
    UseDebug:  Boolean;
    UseLineNo: Boolean;
    backBmp: TBitmap;
    FMainFile: AnsiString; // ���C���t�@�C����
    //
    function GetRect: TRect;
    procedure ClearScreen(col: Integer);
    property BackCanvas: TCanvas read GetBackCanvas;
    procedure Redraw;
    procedure setStyle(s: AnsiString);
    procedure RecoverXY;
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
  FlagBokan: Boolean = False; // --- ���߂Ă� Create �ŁATrue �ɂȂ�
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
  gui_benri, nadesiko_version;

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

// mix file �̎��o���ƃt�@�C���̌���
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

  // mix file ������
  if FileMixReader <> nil then
  if FileMixReader.ReadFile(string(fname), s) then
  begin
    f := TempDir + ExtractFileName(string(fname));
    s.SaveToFile(f);
    fname := f;
    s.Free;
    Exit;
  end;

  // ��΃p�X�w��Ȃ甲����
  if Pos(':\', fname) > 0 then Exit;

  // curdir
  if chk(path(GetCurrentDir) + fname) then Exit;
  // bokan
  f := hi_strU(nako_getVariable('��̓p�X'));
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
var i:Integer;
begin
  ExMarks.TabMark.Visible := (Pos('�^�u',s) > 0);

  ExMarks.DBSpaceMark.Visible := (Pos('�S�p�X�y�[�X',s) > 0);
  ExMarks.SpaceMark.Visible := (Pos('���p�X�y�[�X',s) > 0);
  i := Pos('�X�y�[�X',s);
  while i <> 0 do
  begin
    if i < 5 then
    begin
      ExMarks.SpaceMark.Visible := True;
      ExMarks.DBSpaceMark.Visible := True;
      break;
    end;
    if  (not CompareMem(PAnsiChar('�S�p'),PAnsiChar(s)+i-5,4))
      and (not CompareMem(PAnsiChar('���p'),PAnsiChar(s)+i-5,4)) then
    begin
      ExMarks.SpaceMark.Visible := True;
      ExMarks.DBSpaceMark.Visible := True;
      break;
    end;
    i := PosExA('�X�y�[�X',s, i+1);
  end;

  Marks.EofMark.Visible := (Pos('EOF',s) > 0);
  Marks.RetMark.Visible := (Pos('���s',s) > 0);
end;

procedure THiEditor.WMMousewheel(var Msg: TMessage);
begin
  if (Msg.WParam > 0) then
  begin
    { �z�C�[�������ɓ����������̏��� }
    Sendmessage(Self.Handle, WM_VSCROLL, SB_LINEUP, 0);
  end
  else
  begin
    { �z�C�[������O�ɓ����������̏��� }
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
  // �s���ȕ��������_�����Z���߃G���[���������
  SaveFPUMask := Math.GetExceptionMask;
  Math.SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]);
  //----------------------------------------------------------------------------
  // Windows Vista ALT �L�[�̖��
  {$IF RTLVersion < 20}
  TVistaAltFix.Create(Self);
  {$IFEND}
  //----------------------------------------------------------------------------
  // ����������
  FFlagFree := False;

  // �w�i�r�b�g�}�b�v
  backBmp := TBitmap.Create;

  ClientWidth  := 640;
  ClientHeight := 400;

  backBmp.Width := Self.ClientWidth;
  backBmp.Height := Self.ClientHeight;
  backBmp.Canvas.Brush.Color := clWhite;
  backBmp.Canvas.Pen.Color := clWhite;
  backBmp.Canvas.Rectangle(0,0,backBmp.Width, backBmp.Height);

  freeObjList := TList.Create;

  self.DoubleBuffered := True;
  self.Color := clWhite;

  flagNowClose := False;
  flagRepaint  := True;
  flagClose    := False;
  flagDragMove := False;
  flagBokanSekkei := False;

  IsLiveTaskTray := False;

  FTempX := MaxInt;
  FTempY := MaxInt;
  //----------------------------------------------------------------------------
  // ���g����͂��ǂ������f
  if FlagBokan = False then
  begin
    // ���
    {$IFDEF IS_LIBVNAKO}
    {$ELSE}
    Application.Title := '�Ȃł���';
    {$ENDIF}
    IsBokan   := True;
    FlagBokan := True;
    Bokan     := Self;

    // �K�� 0 ����͂ƂȂ�
    Self.Tag := 0;
    with GuiInfos[0] do
    begin
      obj      := Self;
      obj_type := VCL_GUI_FORM;
      name     := '���';
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
    // ������

    //
    DebugEditorHandle := 0;
    UseDebug := False;
    UseLineNo := False;
    //
    // �Ȃł����̃v���O���������[�h
    if _flag_vnako_exe then
    begin
      if not Nadesiko_Load then Halt;
    end;
    
    // ��O�I�ɕ�͐݌v�C�x���g�̎��s
    p := nako_getVariable('��͐݌v');
    if p <> nil then
    begin
      flagBokanSekkei := True;
      if p^.VType = varStr then
      begin
        nako_eval_str2('EVAL(��͐݌v)');
      end else
      begin
        nako_eval_str2('��͐݌v');
      end;
      flagBokanSekkei := False;
    end;
    nako_eval('!�ϐ��錾���s�v');

    // ���C���̎��s
    if _flag_vnako_exe then
    begin
      timerRunScript.Enabled := True;
    end;
  end else
  begin
    // ��͂ł͂Ȃ��Q�ڈȍ~�̃t�H�[��
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

    if s = '' then
    begin
      s :=  '�u===========================================================�v�ƕ\���B'#13#10+
            '�w���{��v���O���~���O����u�Ȃł����v�x�ƕ\���B'#13#10+
            '�u===========================================================�v�ƕ\���B'#13#10+
            '�u�v���O���������s�t�@�C��(vnako.exe)�փh���b�v���Ă��������B�v�ƕ\���B'#13#10+
            '�u�@�v�ƕ\���B'#13#10+
            '�u> �i�f�V�R�o�[�W���� = {�i�f�V�R�o�[�W����}�v�ƕ\���B'#13#10+
            '�u> �i�f�V�R�ŏI�X�V�� = {�i�f�V�R�ŏI�X�V��}�v�ƕ\���B'#13#10;
    end;
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
    p := nako_getVariable('�R�}���h���C��');
    if p = nil then p := hi_var_new('�R�}���h���C��');
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
    p := nako_getVariable('��̓p�X');
    if p = nil then p := hi_var_new('��̓p�X');
    path := ExtractFilePath(fname);
    if path = '' then path := ExtractFilePath(ParamStr(0));
    hi_setStrU(p, path);

    // debugEditorHandle
    p := nako_getVariable('�f�o�b�O�G�f�B�^�n���h��');
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
    // (ExeName).nako �ł̋N��
    p := nako_getVariable('��̓p�X');
    if p = nil then p := hi_var_new('��̓p�X');
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
    // --- ���s�t�@�C������̎��s ----------------------------------------------
    msg('read packfile');
    try
      msg('load vnako.nako');
      _dnako_loader.includeLib('vnako.nako');
      setBokanHensu;
      _dnako_loader.checkBokanPath;
    except
      on e: Exception do
        raise Exception.Create('����t�@�C��"vnako.nako"�̓W�J�Ɏ��s���܂����B'#13#10+
          '����҂ɘA�����Ă��������B'#13#10 + e.Message);
    end;
    try
      msg('run packfile');
      res := nako_runPackfile;
    except
      on e: Exception do begin
        errLoad;
        raise Exception.Create('���C������t�@�C���̓W�J�Ɏ��s���܂����B'#13#10+
          '�J���҂܂��͐������֘A�����Ă��������B'#13#10 + '--------------'#13#10 + e.Message);
      end;
    end;
    FMainFile := AnsiString(ParamStr(0));
  end;

  procedure __runFromCommandLine;
  begin
    // --- �R�}���h���C������̎��s --------------------------------------------
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
  // todo: ���C���v���O�����̃��[�h
  //--------------------------------
  Result := True;
  res    := nako_OK;
  flag_out_error := False;
  try
    _dnako_loader := TDnakoLoader.Create(Self.Handle);
  except
    ShowError('�Ȃł����G���W���̃��[�h�Ɏ��s���܂����B','�����^�C���G���[');
    Result := False;
    Exit;
  end;
  try
    // vnako �̊֐���o�^
    RegistCallbackFunction(Self.Handle);
    nako_addFileCommand;
    {$IFDEF FMPMODE}
    nako_setVariable('noload_libvnako',hi_newBool(True));
    {$ENDIF}
    nako_LoadPlugins;
    _dnako_success := True;
  except on e:Exception do
    raise Exception.Create('���W���[���̃��[�h�Ɏ��s���܂����B' + #13#10 +
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

  // ���[�h����
  if res = nako_NG then
  begin
    msg('error load ng');
    // �v���O�����̎��s�Ɏ��s�����Ƃ�
    len := nako_getError(nil, 0);
    if len > 0 then
    begin
      // �G���[�̎擾
      SetLength(err, len);
      nako_getError(PAnsiChar(err), len);
      // MessageBox(Self.Handle, PAnsiChar(err), '���@�G���[', MB_OK or MB_ICONERROR);
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
      // ���Ԃ�t�@�C�������Ȃ�����...
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
      Caption := string(hi_str(nako_getVariable('�G���[�_�C�A���O�^�C�g��')));
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
    // �������s�I����A���߂ẴC�x���g
    nako_group_exec(nako_getVariable('���'), '�\��������');
  end;

  if FTempX <> MaxInt then
  begin
    Self.RecoverXY;
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
  // �����̈�̍�蒼��
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

    p := nako_getGroupMember(PAnsiChar(ginfo.name), '�I���\');
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
  p := nako_getGroupMember(PAnsiChar(pinfo^.name), '�V�t�g�L�[');
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

  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�����ꂽ�{�^��');
  if p <> nil then begin
    if Button = mbLeft   then hi_setStr(p, '��') else
    if Button = mbRight  then hi_setStr(p, '�E') else
    if Button = mbMiddle then hi_setStr(p, '����');
  end;
  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�}�E�XX');
  if p <> nil then hi_setInt(p, X);
  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�}�E�XY');
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

  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�}�E�XX');
  if p <> nil then hi_setInt(p, X);
  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�}�E�XY');
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

  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�����ꂽ�{�^��');
  if p <> nil then begin
    if Button = mbLeft   then hi_setStr(p, '��') else
    if Button = mbRight  then hi_setStr(p, '�E') else
    if Button = mbMiddle then hi_setStr(p, '����');
  end;
  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�}�E�XX');
  if p <> nil then hi_setInt(p, X);
  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�}�E�XY');
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
  if group.pgroup = nil then Exit; // ����
  eventName := DeleteGobi(eventName);
  // �O���[�v�Ƀ����o�����݂��邩�H
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

  // �C�x���g���i�ɃR�s�[
  if EventObject = nil then EventObject := nako_getVariable('�C�x���g���i');
  nako_varCopyGensi(group.pgroup, EventObject);
  try
    nako_continue;
    // �C�x���g�� eval ����
    if (_flag_vnako_exe = False) then // libvnako.dll �̏ꍇ�F�Ȃ��� group ���s����ƃG���[���ł�
    begin
      n := group.name + '��' + eventName;
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
      // --- �f�o�b�O�_�C�A���O�̋N��
      frmError.Caption := hi_strU(nako_getVariable('�G���[�_�C�A���O�^�C�g��'));
      frmError.edtMain.Lines.Text := '' +
        '[' + string(group.name) + '��' + string(eventName) + '�����s���̃G���[]'#13#10 +
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

  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�ړ���URL');
  if p <> nil then hi_setStrU(p, URL);

  doEvent(@ginfo, EVENT_CLICK);

  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�ړ�����');
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
  if (p=nil)or(p.ptr=nil) then Exit; // �C�x���g�͂Ȃ�

  // �ϐ��̐ݒ�
  //--------------
  // �V�t�g
  setShift(@ginfo, Shift);
  // �L�[
  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�����ꂽ���z�L�[');
  hi_setInt(p, Key);

  // �C�x���g
  doEvent(@ginfo, EVENT_KEYDOWN);

  // �L�[�̕ύX�𔽉f
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
  if (p=nil)or(p.ptr=nil) then Exit; // �C�x���g�͂Ȃ�

  // �ϐ��̐ݒ�
  // �L�[
  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�����ꂽ�L�[');
  hi_setStrU(p, Key);

  // �C�x���g
  doEvent(@ginfo, EVENT_KEYPRESS);

  // �L�[�̕ύX�𔽉f
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
  if (p=nil)or(p.ptr=nil) then Exit; // �C�x���g�͂Ȃ�

  // �ϐ��̐ݒ�
  // �L�[
  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�����ꂽ���z�L�[');
  hi_setInt(p, Key);
  // �V�t�g
  setShift(@ginfo, Shift);

  // �C�x���g
  doEvent(@ginfo, EVENT_KEYUP);
end;

procedure TfrmNako.setStyle(s: AnsiString);
begin
  FTempX := Self.Left;
  FTempY  := Self.Top;
  if s = '�g�Ȃ�' then self.BorderStyle := bsNone else
  if s = '�g�Œ�' then self.BorderStyle := bsSingle else
  if s = '�g��' then self.BorderStyle := bsSizeable else
  if s = '�_�C�A���O�X�^�C��' then self.BorderStyle := bsDialog else
  if s = '�c�[���E�B���h�E'   then self.BorderStyle := bsToolWindow else
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
  if (p=nil)or(p.ptr=nil) then Exit; // �C�x���g�͂Ȃ�

  // �C�x���g
  doEvent(@ginfo, EVENT_DRAGOVER);

  // �ϐ��̐ݒ�
  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�h���b�v����');
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
  if (p=nil)or(p.ptr=nil) then Exit; // �C�x���g�͂Ȃ�

  // �ϐ��̐ݒ�
  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�}�E�XX');
  if (p<>nil) then hi_setInt(p, X);
  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�}�E�XY');
  if (p<>nil) then hi_setInt(p, Y);
  if ginfo.obj is THiTreeView then
  begin
    node := THiTreeView(Sender).GetNodeAt(X, Y);
    if node <> nil then
      THiTreeView(Sender).dropPath := THiTreeNode(node.Data).GetTreePathText
    else
      THiTreeView(Sender).dropPath := '';
  end;

  // �h���b�v���i�̐ݒ�
  nako_eval_str(ginfo.name + '�̃h���b�v���i�́A' + GuiInfos[TControl(Source).Tag].name);

  // �C�x���g
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
  if (p=nil)or(p.ptr=nil) then Exit; // �C�x���g�͂Ȃ�

  // �ϐ��̐ݒ�
  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�z�C�[���l');
  if (p<>nil) then hi_setInt(p, WheelDelta);

  // �C�x���g
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
  if (p=nil)or(p.ptr=nil) then Exit; // �C�x���g�͂Ȃ�

  // �ϐ��̐ݒ�
  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�h���b�v�t�@�C��');
  if (p<>nil) then hi_setStrU(p, Trim(Files.Text));

  // �C�x���g
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

  // �}�N���̎��s�Ȃ�
  if (msg = 'break')and(WMCopyData.CopyDataStruct.dwData = 1001) then //�G�f�B�^���狭���X�g�b�v���󂯂�
  begin
    tm.WParam := WMCopyData.From;
    _WM_VNAKO_BREAK(tm);
  end else
  if (msg = 'break-all')and(WMCopyData.CopyDataStruct.dwData = 1001) then //�G�f�B�^���狭���X�g�b�v���󂯂�
  begin
    tm.WParam := WMCopyData.From;
    _WM_VNAKO_BREAK_ALL(tm);
  end else
  if (msg = 'pause')and(WMCopyData.CopyDataStruct.dwData = 1001) then //�G�f�B�^���狭���X�g�b�v���󂯂�
  begin
    tm.WParam := WMCopyData.From;
    _WM_VNAKO_STOP(tm);
  end else
  begin
    // ���[�U�[�̒�`�C�x���g
    p := nako_getGroupMember(PAnsiChar(ginfo.name), 'CD������');
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
  // �r�b�g�}�b�v�̍�蒼��
  tmp := TBitmap.Create;
  tmp.Width := Self.ClientWidth;
  tmp.Height := Self.ClientHeight;

  // �w�i
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
    cbSize := SizeOf(TNotifyIconDataVistaA); // V4(Vista) 508B
    Wnd := Handle;
    uID := 1;
  end;
  Shell_NotifyIcon(NIM_DELETE, @NotifyIcon);
  IsLiveTasktray := False;

end;

procedure TfrmNako.InitTasktray;
begin
  if IsLiveTasktray then exit;
  NotifyIconSize := 508; // V4(Vista)�̃T�C�Y
  with NotifyIcon do
  begin
    cbSize := NotifyIconSize;
    Wnd := Handle;
    uID := 1;
    uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP or $00000080; // NIF_SHOWTIP=$00000080
    uCallbackMessage := WM_NotifyTasktray;
    if Self.Icon.Handle > 0 then
      hIcon := Self.Icon.Handle
    else
      hIcon := Application.Icon.Handle;
    StrLCopy(@szTip[0],PChar(Self.Caption), 127);
  end;
  if not Shell_NotifyIcon(NIM_ADD,@NotifyIcon) then
  begin
    NotifyIconSize := 504; // V3(XP)�̃T�C�Y
    NotifyIcon.uFlags := NotifyIcon.uFlags and $ffffff7f; // NIF_SHOWTIP=$00000080
    NotifyIcon.cbSize := NotifyIconSize;
    if not Shell_NotifyIcon(NIM_ADD,@NotifyIcon) then
    begin
      NotifyIconSize := 488; // V2(2K)�̃T�C�Y
      NotifyIcon.cbSize := NotifyIconSize;
      if not Shell_NotifyIcon(NIM_ADD,@NotifyIcon) then
      begin
        NotifyIconSize := 88; // V1(NT)�̃T�C�Y
        NotifyIcon.cbSize := NotifyIconSize;
        StrLCopy(@(NotifyIcon.szTip[0]),PChar(Self.Caption), 63);
        Shell_NotifyIcon(NIM_ADD,@NotifyIcon);
      end;
    end;
  end;
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
    WM_LBUTTONDOWN: doEvent(@GuiInfos[0], '�^�X�N�g���C�N���b�N������');
    WM_RBUTTONDOWN: doEvent(@GuiInfos[0], '�^�X�N�g���C�E�N���b�N������');
    WM_MOUSEMOVE:   doEvent(@GuiInfos[0], '�^�X�N�g���C�ʉ߂�����');
    1029:           doEvent(@GuiInfos[0], '�^�X�N�g���C�o���[���N���b�N������');
  end;
end;

procedure TfrmNako.ShowBalloon(message:String);
var
  trayIconInfo   : TIconInfo;
  tBM :tagBitmap;
begin
  if not IsLiveTasktray then exit;
  if NotifyIconSize = 88 then exit;

  with NotifyIcon do
  begin
    cbSize := NotifyIconSize;
    Wnd := Handle;
    uID := 1;
    uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP or $00000010; // NIF_INFO=$00000010
    if NotifyIconSize = 508 then
    begin
      uFlags := uFlags or $00000080; // NIF_SHOWTIP=$00000080
      if bBalloonRealtime then
        uFlags := uFlags or $00000040;  // NIF_REALTIME=$00000040
    end;
    uCallbackMessage := WM_NotifyTasktray;
    if Self.Icon.Handle > 0 then
      hIcon := Self.Icon.Handle
    else
      hIcon := Application.Icon.Handle;
    dwInfoFlags := dwBalloonOption;
    if NotifyIconSize = 508 then
      if (dwInfoFlags and $0000000f) = $00000004 then // NIIF_USER=$00000004
        if Self.Icon.Handle > 0 then
          hBalloonIcon := Self.Icon.Handle
        else
          hBalloonIcon := Application.Icon.Handle;
    if (dwInfoFlags and $0000000f) = $00000004 then // NIIF_USER=$00000004
    begin
      if NotifyIconSize = 508 then
        GetIconInfo(hBalloonIcon, trayIconInfo)
      else
        GetIconInfo(hIcon, trayIconInfo);
      GetObject(trayIconInfo.hbmColor, Sizeof(tBM), @tBM);
      if (GetSystemMetrics(SM_CXSMICON) = tBM.bmWidth) and
         (GetSystemMetrics(SM_CYSMICON) = tBM.bmHeight) then
        dwInfoFlags := dwInfoFlags and $ffffffdf  // NIIF_LARGE_ICON=$00000020
      else
      if (GetSystemMetrics(SM_CXICON) = tBM.bmWidth) and
         (GetSystemMetrics(SM_CYICON) = tBM.bmHeight) then
        dwInfoFlags := dwInfoFlags or  $00000020  // NIIF_LARGE_ICON=$00000020
      else
      begin
        dwInfoFlags := dwInfoFlags or  $fffffffb; // NIIF_USER=$00000004
        dwInfoFlags := dwInfoFlags and $ffffffdf; // NIIF_LARGE_ICON=$00000020
        if NotifyIconSize = 508 then
          hBalloonIcon := 0;
      end;
    end;
    StrLCopy(@szTip[0],PChar(Self.Caption), 127);
    if bBalloonHideTitle then
      StrLCopy(@szInfoTitle[0],PChar(''), 63)
    else
      StrLCopy(@szInfoTitle[0],PChar(Self.Caption), 63);
    StrLCopy(@szInfo[0],PChar(message), 255);
    if NotifyIconSize = 488 then
      dwInfoFlags := dwInfoFlags and $0000000f; // NIF_ICON_MASK=$0000000f
  end;
  Shell_NotifyIcon(NIM_MODIFY, @NotifyIcon);
  IsLiveTasktray := True;
end;

procedure TfrmNako.hideBalloon();
var
  trayIconInfo   : TIconInfo;
  tBM :tagBitmap;
begin
  if not IsLiveTasktray then exit;
  if NotifyIconSize = 88 then exit;

  with NotifyIcon do
  begin
    cbSize := NotifyIconSize;
    Wnd := Handle;
    uID := 1;
    uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP or $00000010; // NIF_INFO=$00000010
    if NotifyIconSize = 508 then
      uFlags := uFlags or $00000080; // NIF_SHOWTIP=$00000080
    uCallbackMessage := WM_NotifyTasktray;
    dwInfoFlags := dwBalloonOption;
    if Self.Icon.Handle > 0 then
      hIcon := Self.Icon.Handle
    else
      hIcon := Application.Icon.Handle;
    if (dwInfoFlags and $0000000f) = $00000004 then // NIIF_USER=$00000004
    begin
      if NotifyIconSize = 508 then
        GetIconInfo(hBalloonIcon, trayIconInfo)
      else
        GetIconInfo(hIcon, trayIconInfo);
      GetObject(trayIconInfo.hbmColor, Sizeof(tBM), @tBM);
      if (GetSystemMetrics(SM_CXSMICON) = tBM.bmWidth) and
         (GetSystemMetrics(SM_CYSMICON) = tBM.bmHeight) then
        dwInfoFlags := dwInfoFlags and $ffffffdf  // NIIF_LARGE_ICON=$00000020
      else
      if (GetSystemMetrics(SM_CXICON) = tBM.bmWidth) and
         (GetSystemMetrics(SM_CYICON) = tBM.bmHeight) then
        dwInfoFlags := dwInfoFlags or  $00000020  // NIIF_LARGE_ICON=$00000020
      else
      begin
        dwInfoFlags := dwInfoFlags or  $fffffffb; // NIIF_USER=$00000004
        dwInfoFlags := dwInfoFlags and $ffffffdf; // NIIF_LARGE_ICON=$00000020
        if NotifyIconSize = 508 then
          hBalloonIcon := 0;
      end;
    end;
    StrLCopy(@szTip[0],PChar(Self.Caption), 127);
    StrLCopy(@szInfoTitle[0],PChar(''), 63);
    StrLCopy(@szInfo[0],PChar(''), 255);
    if NotifyIconSize = 488 then
      dwInfoFlags := dwInfoFlags and $0000000f; // NIF_ICON_MASK=$0000000f
  end;
  Shell_NotifyIcon(NIM_MODIFY, @NotifyIcon);
  IsLiveTasktray := True;
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
  if Self.Handle <> THandle(Msg.LParam) then // �������g�ȊO���I��
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
    cbSize := NotifyIconSize;
    Wnd := Handle;
    uID := 1;
    uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
    if NotifyIconSize = 508 then
      uFlags := uFlags or $00000080; // NIF_SHOWTIP=$00000080
    uCallbackMessage := WM_NotifyTasktray;
    if Self.Icon.Handle > 0 then
      hIcon := Self.Icon.Handle
    else
      hIcon := Application.Icon.Handle;
    if NotifyIconSize = 88 then
      StrLCopy(@szTip[0],PChar(Self.Caption), 63)
    else
      StrLCopy(@szTip[0],PChar(Self.Caption), 127)
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
  doEvent(ginfo, '����������');
end;

procedure TfrmNako.eventBrowserDocumentComplete(Sender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
var
  ginfo: PGuiInfo;
begin
  ginfo := @(GuiInfos[ TControl(Sender).Tag ]);
  ginfo.freetag := 0;
  doEvent(ginfo, '��������������');
end;

procedure TfrmNako.eventBrowserDownloadComplete(Sender: TObject);
var
  ginfo: PGuiInfo;
begin
  ginfo := @GuiInfos[ TControl(Sender).Tag ];
  ginfo.freetag := 0;
  doEvent(ginfo, '�_�E�����[�h����������');
end;


procedure TfrmNako.eventBrowserNewWindow2(Sender: TObject;
  var ppDisp: IDispatch; var Cancel: WordBool);
var
  ginfo: PGuiInfo;
  p: PHiValue;
  w: TUIWebBrowser;
begin
  ginfo := @GuiInfos[ TControl(Sender).Tag ];
  doEvent(ginfo, '�V���J������');

  // �֎~�H
  p := nako_group_findMember(ginfo.pgroup, '�V���֎~');
  if p=nil then raise Exception.Create('�����o�w�V���p�u���E�U���x������܂���B');
  if hi_bool(p) then
  begin
    Cancel := True; Exit;
  end;

  // �V�����J���E�C���h�E�ɂ���
  p := nako_group_findMember(ginfo.pgroup, 'F�V���p�u���E�U');
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
  if (p=nil)or(p.ptr=nil) then Exit; // �C�x���g�͂Ȃ�

  // �ϐ��̐ݒ�
  s := TEditorEx(ginfo.obj).DropFileNames.Text;
  p := nako_getGroupMember(PAnsiChar(ginfo.name), '�h���b�v�t�@�C��');
  if (p<>nil) then hi_setStr(p, TrimA(s));

  // �C�x���g
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
  // �f�o�C�X�C�x���g
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
            doEvent(@GuiInfos[0], '�f�o�C�X�}��������');
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
            doEvent(@GuiInfos[0], '�f�o�C�X�폜������');
          end;
        end;
      end;
  end;
end;

procedure TfrmNako.SetBokanHensu;
var b, p, f: PHiValue;
begin
  f := nako_getVariable('�t�H�[��');
  if f = nil then raise Exception.Create('vnako.nako�̎�荞�݂Ɏ��s');
  //
  b := nako_var_new('���');
  nako_varCopyData(f, b);
  p := nako_group_findMember(b, '���O');
  hi_setStr(p, '���');
  GuiInfos[0].pgroup := b;
  p := nako_group_findMember(GuiInfos[0].pgroup,'�I�u�W�F�N�g');
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

procedure TfrmNako.RecoverXY;
begin
  if FTempX <> Self.Left then Self.Left := FTempX;
  if FTempY <> Self.Top  then Self.Top := FTempY;
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
  if (s = '�I�t')or(s = '0') then Self.DragMode := dmManual else
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
        // ���Ă������̂Ȃ̂ŃG���[�𖳎��B
      end;
    end;
    freeObjList.Clear;
  end;
end;

procedure TfrmNako.FormResize(Sender: TObject);
begin
  // �r�b�g�}�b�v�̍�蒼������
  ResizeBackBmp;

  // ���[�U�[�C�x���g�����s����
  eventSizeChange(self);
end;

procedure TfrmNako.FormDestroy(Sender: TObject);
begin
  Math.SetExceptionMask(SaveFPUMask);
  FreeAndNil(freeObjList); // �������������������Ȃ��Ă�������GUI�f�[�^�͉�������
  FFlagFree := True;
  FreeAndNil(_dnako_loader);
  FreeAndNil(backBmp);
  if _dnako_success then
  begin
    // �I�����̗�O�𖳎�����悤��
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
  // ���s���|�[�g��ۑ�����
  // ---------------------------------------
  if UseDebug then
  begin
    s := LocalAppData + NADESIKO_REPORT_TXT;
    try
      nako_makeReport(PAnsiChar(s));
    except
      MessageBox(Self.Handle,'report.txt�̍쐬�Ɏ��s���܂����B','�Ȃł���',MB_OK or MB_ICONERROR);
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
  Self.Invalidate; // Vista�� Form ��̃{�^������������̑Ώ�
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
  Self.Invalidate; // Vista �ŉ�ʂ̃R���|�[�l���g����������ɑΏ�
end;

procedure TfrmNako.timerFormWakeUpTimer(Sender: TObject);
begin
  timerFormWakeUp.Enabled := False;
  Self.RecoverXY;
  Self.Invalidate;
end;

initialization
  InitGuiInfos;

finalization
  FreeGuiInfos;

end.
