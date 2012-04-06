unit mini_func;

interface

uses
  Windows,
  Messages,
  SysUtils,
  imm;

//{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}


//==============================================================================
// 簡単に質問するダイアログ
function MsgInput(msg: AnsiString; caption: AnsiString = ''; InitValue: AnsiString = '';
  Cancel: AnsiString = ''; ImeMode: DWORD = 0): AnsiString;

//==============================================================================
// パス操作
function AppPath: string;

//==============================================================================
// その他
procedure WindowMoveCenter(hWnd: HWND);
// IME on/off
procedure SetImeOnOff(h: HWND; b: Boolean);
procedure SetImeMode(h: HWND; mode: Cardinal);

var
  DialogTitle: AnsiString;
  DialogParentHandle: HWND;

{$R mini_func.res}

implementation

type
  TMsgInputOpt = record
    Caption,
    Text,
    InitValue,
    Result,
    CancelValue: AnsiString;
    ImeMode: Integer;
  end;

var
  MsgInputOpt: TMsgInputOpt;

procedure SetImeOnOff(h: HWND; b: Boolean);
var
  hi: HIMC;
begin
  hi := ImmGetContext(h);
  ImmSetOpenStatus(hi, b);
  ImmReleaseContext(h, hi);
end;
procedure SetImeMode(h: HWND; mode: Cardinal);
var
  hi: HIMC;
  sentence, nmode: Cardinal;
begin
  hi := ImmGetContext(h);
  ImmGetConversionStatus(hi, nmode, sentence);
  ImmSetConversionStatus(hi, mode,  sentence);
  ImmReleaseContext(h, hi);
end;


//==============================================================================
// Window操作用
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

function MsgInputDialogFunc(hDlg: HWND; Msg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL; stdcall;
var
  ID: Integer;
  p: PAnsiChar;
begin
  Result := False;
  case Msg of
  WM_INITDIALOG:
    begin
      // Caption
      if MsgInputOpt.Caption <> '' then
        SetWindowTextA(hDlg, PAnsiChar(MsgInputOpt.Caption));
      // Text
      SendMessage(GetDlgItem(hDlg,4), WM_SETTEXT, 4, Integer(PAnsiChar(MsgInputOpt.Text)));
      // InitValue
      SendMessage(GetDlgItem(hDlg,3), WM_SETTEXT, 4, Integer(PAnsiChar(MsgInputOpt.InitValue)));
      // IME MODE
      if MsgInputOpt.ImeMode > 0 then
      begin
        SetImeOnOff(GetDlgItem(hDlg,3), True);
        SetImeMode(GetDlgItem(hDlg,3), MsgInputOpt.ImeMode);
      end;
    end;
  WM_ACTIVATE:
    begin
      // Center
      WindowMoveCenter(hDlg);
      SetFocus(hDlg);
    end;
  WM_COMMAND:
    begin
      // ID
      id := LOWORD(wParam);
      case id of
      1:// IDOK
        begin
          // LENGTH
          GetMem(p, 1024);
          try
            SendMessage(GetDlgItem(hDlg,3), WM_GETTEXT, 1024, Integer(p));
            MsgInputOpt.Result := AnsiString( p );
          finally
            FreeMem(p);
          end;
          // CLOSE
          EndDialog(hDlg, IDOK);
        end;
      2:// IDCANCEL
        begin
          MsgInputOpt.Result := MsgInputOpt.CancelValue;
          EndDialog(hDlg, IDCancel);
        end;
      end;
      Result := True;
    end;
  end;
end;

function MsgInput(msg: AnsiString; caption: AnsiString = ''; InitValue: AnsiString = '';
  Cancel: AnsiString = ''; ImeMode: DWORD = 0): AnsiString;
begin
  MsgInputOpt.Caption   := caption;
  MsgInputOpt.Text      := msg;
  MsgInputOpt.Result    := '';
  MsgInputOpt.InitValue := InitValue;
  MsgInputOpt.CancelValue := Cancel;
  MsgInputOpt.ImeMode   := ImeMode; 
  DialogBox(hInstance, 'INPUTBOX', DialogParentHandle, @MsgInputDialogFunc);
  Result := MsgInputOpt.Result ;
end;


//==============================================================================
// パスなど
function AppPath: string;
begin
  Result := ExtractFilePath(ParamStr(0));
end;


initialization
  DialogTitle := 'Test';
  DialogParentHandle := 0;


end.
