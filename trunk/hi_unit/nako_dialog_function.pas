unit nako_dialog_function;

interface
uses
  windows, sysutils, messages, nako_dialog_const;

{$R dialogScript.RES}

type
  TNakoDialogInfoRec = record
    DType       : Integer;
    Title       : string;
    Caption     : string;
    Text        : string;
    InitValue   : string;
    CancelValue : string;
    ImeMode     : DWORD;
  end;

function showMemoDialog(hParent: THandle; var txt: string;
  init:string = ''; cancel:string = ''; title: string = ''; ime:DWORD = 0): Boolean;
function showListDialog(hParent: THandle; var txt: string;
  init:string = ''; cancel:string = ''; title: string = ''; ime:DWORD = 0): Boolean;

procedure ShowProgressDialog(title, text, info: string; FlagShowDialog: Boolean);
procedure SetWinText(h: HWND; s: string);
procedure SetDlgWinText(hDlg: HWND; id: DWORD; s: string);

var
  DialogHandle        : HWND    = 0;
  DialogFlagStop      : Boolean = False;
  DialogFlagComplete  : Boolean = False;
  DialogParent        : HWND    = 0;

implementation

uses unit_string, mini_func
{$IFDEF EXE_CNAKO}
  // do not use dnako_import
{$ELSE}
  ,dnako_import
{$ENDIF}
  ;


{$IFDEF EXE_CNAKO}
function nako_getMainWindowHandle:THandle;
begin
  Result := 0;
end;
{$ENDIF}

var
  dinfo: TNakoDialogInfoRec;

procedure SetWinText(h: HWND; s: string);
begin
  SendMessage(h, WM_SETTEXT, 0, LPARAM(PChar(s)));
end;

procedure SetDlgWinText(hDlg: HWND; id: DWORD; s: string);
begin
  SetWinText(GetDlgItem(hDlg, id), s);
end;

function procProgress(
    hDlg: HWND;    // handle to dialog box
    uMsg: UINT;    // message
    wp  : WPARAM;  // first message parameter
    lp  : LPARAM   // second message parameter
   ): BOOL; stdcall;
var id: WORD;
begin
  Result := False;
  case uMsg of
    WM_COMMAND:
      begin
        id := LOWORD(wp);
        if id = IDCANCEL then
        begin
          DialogFlagStop := True;
        end;
      end;
  end;
end;

procedure ShowProgressDialog(title, text, info: string; FlagShowDialog: Boolean);
var
  hParent: HWND;
  msg: TMsg;
begin
  DialogFlagComplete := False;
  DialogFlagStop     := False;

  hParent := nako_getMainWindowHandle;
  if hParent = 0 then hParent := GetForegroundWindow;
  //
  DialogHandle := CreateDialog(hInstance, PChar(IDD_DIALOG_PROGRESS),
                hParent, @procProgress);

  SetDlgWinText(DialogHandle, IDC_EDIT_TEXT, text);
  SetDlgWinText(DialogHandle, IDC_EDIT_INFO, info);
  SetWindowText(DialogHandle, PChar(title));

  if FlagShowDialog then
  begin
    ShowWindow(DialogHandle, SW_SHOW);
  end else
  begin
    ShowWindow(DialogHandle, SW_HIDE);
  end;

  while DialogFlagComplete = False do
  begin
    if PeekMessage(msg, DialogHandle, 0, 0, PM_REMOVE) then
    begin
      if not IsDialogMessage(DialogHandle, msg) then
      begin
        TranslateMessage(msg);
        DispatchMessage (msg);
      end;
    end else
    begin
      // アイドル
      sleep(1);
    end;
  end;

  DestroyWindow(DialogHandle);
  DialogHandle := 0;
end;


function getWinH(h: THandle): THandle;
begin
  if (h = 0)or(h = INVALID_HANDLE_VALUE) then
  begin
    Result := GetForegroundWindow;
  end else
  begin
    Result := h;
  end;
end;

procedure WindowMoveCenter(hWnd: HWND);
var
  r, wr: TRect;
  w,h: Integer;
begin
  GetWindowRect(hWnd, r);
  GetWindowRect(GetDesktopWindow, wr);
  w := r.Right - r.Left + 1;
  h := r.Bottom - r.Top + 1;
  r.Left := ((wr.Right - wr.Left) - w) div 2;
  r.Top  := ((wr.Bottom - wr.Top) - h) div 2;
  SetWindowPos(hWnd, 0, r.Left, r.Top, w, h, SWP_NOSIZE);
end;

function getWinText(h: HWND): string;
var
  len: Integer;
  mem: PChar;
begin
  len := SendMessage(h, WM_GETTEXTLENGTH, 0, 0);
  //
  mem := GetMemory(len+1);
  try
    SendMessage(h, WM_GETTEXT, len+1, LPARAM(mem));
    Result := mem;
  finally
    FreeMem(mem);
  end;
end;

function procMemoDialog(hDlg: HWND; msg: UINT; wp: WPARAM; lp: LPARAM): BOOL; stdcall;
var
  ID, i, len: Integer;
  h: HWND;
  s, a: string;
begin
  Result := False;

  case Msg of
  WM_INITDIALOG:
    begin
      // Caption
      if dinfo.Caption <> '' then
      begin
        SetWindowText(hDlg, PChar(dinfo.Caption));
      end;
      // IME
      if dinfo.ImeMode > 0 then
      begin
        SetImeOnOff(GetDlgItem(hDlg, IDC_EDIT_TEXT), True);
        SetImeMode(GetDlgItem(hDlg, IDC_EDIT_TEXT), dinfo.ImeMode);
      end;
      // Text
      case dinfo.DType of
      IDD_DIALOG_MEMO:
        begin
          if dinfo.Text <> '' then
          begin
            SendMessage( GetDlgItem(hDlg, IDC_EDIT_TEXT), WM_SETTEXT, 0,
              LPARAM(PChar(dinfo.Text)));
          end;
          SetFocus(GetDlgItem(hDlg, IDC_EDIT_TEXT));
        end;
      IDD_DIALOG_LIST:
        begin
          // アイテムにセット
          if dinfo.Text <> '' then
          begin
            s := dinfo.Text;
            h := GetDlgItem(hDlg, IDC_LIST_MAIN);
            while s <> '' do
            begin
              a := getToken_s(s, #13#10);
              SendMessage(h, LB_ADDSTRING, 0, LPARAM(PChar(a)));
            end;
          end;
          // 初期値をセット  IDC_EDIT_TEXT
          if dinfo.InitValue <> '' then
          begin
            SendMessage( GetDlgItem(hDlg, IDC_EDIT_TEXT), WM_SETTEXT, 0,
              LPARAM(PChar(dinfo.InitValue)));
          end;
          GetDlgItem(hDlg, IDC_LIST_MAIN)
        end;
      end;
    end;
  WM_ACTIVATE:
    begin
      // Center
      WindowMoveCenter(hDlg);
      SetFocus(hDlg);
      //
      case dinfo.DType of
      IDD_DIALOG_MEMO: SetFocus(GetDlgItem(hDlg, IDC_EDIT_TEXT));
      IDD_DIALOG_LIST: SetFocus(GetDlgItem(hDlg, IDC_LIST_MAIN));
      end;
      //
      Result := True;
    end;
  WM_COMMAND:
    begin
      // ID
      id := LOWORD(wp);
      case id of
      IDOK:// IDOK
        begin
          // TEXT
          dinfo.Text := getWinText(GetDlgItem(hDlg,IDC_EDIT_TEXT));
          // CLOSE
          EndDialog(hDlg, IDOK);
        end;
      IDCANCEL:// IDCANCEL
        begin
          dinfo.Text := dinfo.CancelValue;
          EndDialog(hDlg, IDCancel);
        end;
      IDC_LIST_MAIN:
        begin
          // テキストへ
          h := GetDlgItem(hDlg, IDC_LIST_MAIN);
          i := SendMessage(h, LB_GETCURSEL, 0, 0);
          len := SendMessage(h, LB_GETTEXTLEN, i, 0);
          SetLength(a, len+1);
          SendMessage(h, LB_GETTEXT, i, LParam(@a[1]));
          SendMessage(GetDlgItem(hDlg, IDC_EDIT_TEXT), WM_SETTEXT, 0, LPARAM(PChar(a)));
        end;
      end;
      Result := True;
    end;
  end;
end;

function showMemoDialog(hParent: THandle; var txt: string;
  init, cancel, title: string; ime:DWORD): Boolean;
begin
  hParent     := getWinH(hParent);
  dinfo.Caption := title;
  dinfo.Text  := txt;
  dinfo.DType := IDD_DIALOG_MEMO;
  dinfo.InitValue   := init;
  dinfo.CancelValue := cancel;
  dinfo.ImeMode     := ime;
  Result      := (IDOK = DialogBox(hInstance, PChar(IDD_DIALOG_MEMO), hParent, @procMemoDialog));
  txt         := dinfo.Text;
end;

function showListDialog(hParent: THandle; var txt: string;
  init, cancel, title: string; ime:DWORD): Boolean;
begin
  hParent     := getWinH(hParent);
  dinfo.Caption := title;
  dinfo.Text  := txt;
  dinfo.DType := IDD_DIALOG_LIST;
  dinfo.InitValue   := init;
  dinfo.CancelValue := cancel;
  dinfo.ImeMode     := ime;
  Result      := (IDOK = DialogBox(hInstance, PChar(IDD_DIALOG_LIST), hParent, @procMemoDialog));
  txt         := dinfo.Text;
end;

end.
