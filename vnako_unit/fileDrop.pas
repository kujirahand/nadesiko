unit fileDrop;

interface
uses
  Classes, SysUtils, controls, windows, Messages, Forms, ShellApi;

type
  TFileDropEvent = procedure (Sender: TObject; Num: Integer;
                   Files: TStrings; X, Y: Integer) of object;

  TFileDrop = class(TComponent)
  private
    FAccept: Boolean;
    FControl: TWinControl;
    FOnFileDrop: TFileDropEvent;
    FWindowHandle: HWND;
    FAlterInstance: Pointer;
    FDefWndProc: Pointer;
    procedure SetAccept(Value: Boolean);
    procedure SetControl(Value: TWinControl);
    procedure WndProc(var Msg: TMessage);
  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent;
              Operation: TOperation); override;
    procedure FileDrop(HDrop: THandle); virtual;
    procedure HookDrop; virtual;
    procedure UnHookDrop; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Reset;
  published
    property Accept: Boolean read FAccept write SetAccept default True;
    property Control: TWinControl read FControl write SetControl;
    property OnFileDrop: TFileDropEvent read FOnFileDrop write FOnFileDrop;
  end;

implementation

constructor TFileDrop.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAccept := True;
  FAlterInstance := MakeObjectInstance(WndProc);
end;

destructor TFileDrop.Destroy;
begin
  UnHookDrop;
  FreeObjectInstance(FAlterInstance);
  inherited Destroy;
end;

procedure TFileDrop.Loaded;
begin
  inherited;
  if FControl = nil then Reset;
end;

procedure TFileDrop.Notification(AComponent: TComponent;
                                 Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = FControl) and (Operation = opRemove) then
  begin
    FControl := nil;
    FAccept := False;
  end;
end;

procedure TFileDrop.HookDrop;
begin
  if not (csDesigning in ComponentState) then
  begin
    if FControl <> nil then
      FWindowHandle := FControl.Handle
    else if Owner is TCustomForm then
      FWindowHandle := (Owner as TCustomForm).Handle
    else
      raise Exception.Create('Invalidate Window Handle in FileDrop');

    FDefWndProc := Pointer(GetWindowLong(FWindowHandle, GWL_WNDPROC));
    SetWindowLong(FWindowHandle, GWL_WNDPROC, Longint(FAlterInstance));
    DragAcceptFiles(FWindowHandle, FAccept);
  end;
end;

procedure TFileDrop.UnHookDrop;
var
  Wnd: HWND;
begin
  if not (csDesigning in ComponentState) then
  begin
    if (FWindowHandle <> 0) then
    begin
      if FControl <> nil then
        Wnd := FControl.Handle
      else if Owner is TCustomForm then
        Wnd := (Owner as TCustomForm).Handle
      else
        Wnd := 0;
      if FWindowHandle = Wnd then
        SetWindowLong(Wnd, GWL_WNDPROC, Longint(FDefWndProc));
    end;
    FWindowHandle := 0;
  end;
end;

procedure TFileDrop.Reset;
begin
  Control := FControl;
end;

procedure TFileDrop.WndProc(var Msg: TMessage);
begin
  with Msg do
    case Msg of
    WM_DROPFILES:
      begin
        try
          FileDrop(WParam);
        except
          Application.HandleException(Self);
        end;
        DragFinish(WParam);
      end;
    else
      Result := CallWindowProc(FDefWndProc, FWindowHandle,
                               Msg, WParam, LParam);
    end;
end;

procedure TFileDrop.FileDrop(HDrop: THandle);
var
  I, Num: Integer;
  Files: TStrings;
  Pos: TPoint;
  Buf: array [0..255] of Char;
begin
  if Assigned(FOnFileDrop) then
  begin
    Files := TStringList.Create;
    DragQueryPoint(HDrop, Pos);
    Num := DragQueryFile(HDrop, $FFFFFFFF, nil, 0);
    for I := 0 to Num - 1 do
    begin
      DragQueryFile(HDrop, I, Buf, SizeOf(Buf)-1);
      Files.Add(Buf);
    end;
    FOnFileDrop(Self, Num, Files, Pos.X, Pos.Y);
    Files.Free;
  end;
end;

procedure TFileDrop.SetAccept(Value: Boolean);
begin
  if FAccept <> Value then
  begin
    FAccept := Value;
    if FWindowHandle <> 0 then
      DragAcceptFiles(FWindowHandle, FAccept);
  end;
end;

procedure TFileDrop.SetControl(Value: TWinControl);
begin
  UnHookDrop;
  FControl := Value;
  if Value <> nil then Value.FreeNotification(Self);
  HookDrop;
end;



end.
