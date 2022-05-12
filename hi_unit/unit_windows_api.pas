unit unit_windows_api;

interface

uses
  {$IFDEF Win32}
  Windows, SysUtils, messages
  {$ELSE}
  SysUtils
  {$ENDIF};

// �G���[���b�Z�[�W���擾����
function GetLastErrorStr: string;
function GetLastErrorMessage(ErrorCode: Integer): string;

{$IFDEF Win32}
function ClipbrdGetAsText: AnsiString;
function ClipbrdSetAsText(s: AnsiString): AnsiString;
procedure ClipbrdSetAsBuffer(Format: Word; var Buffer; Size: Integer);

procedure SendCOPYDATA(hwnd: THandle; str: AnsiString; msgid: DWORD; SelfHandle: THandle);
{$ENDIF}

function getWinVersion: AnsiString;
function getWinVersionN: AnsiString;

implementation

uses
  Registry, unit_string;

function getWinVersionN: AnsiString;
{$IFDEF Win32}
var
  i: TOSVersionInfo;
begin
  i.dwOSVersionInfoSize := SizeOf(i);
  GetVersionEx(i);
  Result :=
    AnsiString(Format(
      '%d.%d(%d:%d)',
      [
        i.dwMajorVersion,
        i.dwMinorVersion,
        i.dwBuildNumber,
        i.dwPlatformId
      ]));
end;
{$ELSE}
begin
  Result := '0.0(0:0)';
end;
{$ENDIF}

function getWinVersion: AnsiString;
{$IFDEF Win32}
var
  //s: AnsiString;
  major,minor: LongInt;
  Info: TOSVersionInfo;

  function getFromRegistry(def:string): string;
  var
    reg: TRegistry;
    name, ver, currentBuild: string;
    build: Integer;
  begin
    Result := def;
    reg := TRegistry.Create;
    try
      reg.RootKey := HKEY_LOCAL_MACHINE;
      if reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows NT\CurrentVersion') then
      begin
        name := reg.ReadString('ProductName');
        CurrentBuild := reg.ReadString('CurrentBuild');
        build := StrToIntDef(currentBuild, 0);
        Result := name;
        if build >= 22000 then
        begin
          ver := reg.ReadString('DisplayVersion');
          Result := 'Windows 11 (' + ver + ')';
        end;
      end;
    finally
      reg.Free;
    end;
  end;

begin
  Info.dwOSVersionInfoSize := SizeOf(Info);
  GetVersionEx(Info);
  Major := Info.dwMajorVersion ;
  Minor := Info.dwMinorVersion ;
  Result := '�s��:' +
    AnsiString(
      Format('%d.%d',[Major, Minor]) + ')'
    );

  // �ȉ��̃y�[�W�ɏڍׂ�Windows�o�[�W�������L����Ă���
  // (�Q��) https://docs.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-osversioninfoexa
  // ����ł����݂͒��ڃ��W�X�g����ProductName���E���̂ōX�V�͕s�v
  case major of
      3://NT 3.51
          begin
            Result := 'Windows NT 3.51';
          end;
      4://95/98/ME/NT
          begin
              if Info.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS then
              begin
                  case Minor of
                      0 :Result := 'Windows 95';
                      10:Result := 'Windows 98';
                      90:Result := 'Windows Me';
                  end;
              end else
              if Info.dwPlatformId = VER_PLATFORM_WIN32_NT then
              begin
                  Result := 'Windows NT 4.0';
              end;
          end;
      5://2000/XP/.NET Server
          begin
              case Minor of
                  0: Result := 'Windows 2000';
                  1: Result := 'Windows XP';
                  2: Result := 'Windows Server 2003';
              end;
          end;
      6://Vista
          begin
              (*
              case Minor of
                0: Result := 'Windows Vista';
                1: Result := 'Windows 7';
                2: Result := 'Windows 8';
                3: Result := 'Windows 8.1';
              end;
              *)
              // ���W�X�g������l�𓾂�
              Result := getFromRegistry(Result);
          end;
      else begin
        Result := getFromRegistry(Result);
      end;
  end;//of case Major
end;
{$ELSE}
begin
  Result := 'Not Windows';
end;
{$ENDIF}


{$IFDEF Win32}
{WM_COPYDATA���ȒP�ɑ��M����}
procedure SendCOPYDATA(hwnd: THandle; str: AnsiString; msgid: DWORD; SelfHandle: THandle);
var
  cd  : TCopyDataStruct;
  len : integer;
  Msg : PAnsiChar;
begin
  if hwnd <> 0 then
  begin
    //���郁�b�Z�[�W
    len :=  Length(str) + 1;
    cd.dwData :=  msgid;
    cd.cbData :=  len;
    GetMem(Msg, len);
    try
      StrPCopy(Msg, str);
      cd.lpData := Msg;
      //���M��E�B���h�E���A�N�e�B�u�ɂ���
      // SetForegroundWindow(hwnd);
      //���M
      SendMessage(hwnd, WM_COPYDATA, SelfHandle, LParam(@cd));
    finally
      FreeMem(Msg, len);
    end;
  end;
end;

procedure ClipbrdOpen;
begin
  if not OpenClipboard(0) then raise Exception.Create('�N���b�v�{�[�h���J���܂���B');
end;

procedure ClipbrdClose;
begin
  CloseClipboard;
end;

function ClipbrdGetAsText: AnsiString;
var
  Data: THandle;
begin
  ClipbrdOpen;
  Data := GetClipboardData(CF_TEXT);
  try
    if Data <> 0 then
      Result := PAnsiChar(GlobalLock(Data))
    else
      Result := '';
  finally
    if Data <> 0 then GlobalUnlock(Data);
    ClipbrdClose;
  end;
end;

function ClipbrdSetAsText(s: AnsiString): AnsiString;
begin
  s := s + #0;
  ClipbrdSetAsBuffer(CF_TEXT, s[1], Length(s));
end;

procedure ClipbrdSetAsBuffer(Format: Word; var Buffer; Size: Integer);
var
  Data: THandle;
  DataPtr: Pointer;
begin
  ClipbrdOpen;    // �N���b�v�{�[�h���J��
  EmptyClipboard; // �N���b�v�{�[�h�ɕύX�̏��L����^����
  try
    Data := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, Size);
    try
      DataPtr := GlobalLock(Data);
      try
        Move(Buffer, DataPtr^, Size);
        //Adding;
        if SetClipboardData(Format, Data) = 0 then raise Exception.Create('�R�s�[���s');
      finally
        GlobalUnlock(Data);
      end;
    except
      GlobalFree(Data);
      raise;
    end;
  finally
    ClipbrdClose;
  end;
end;
{$ENDIF}

function GetLastErrorMessage(ErrorCode: Integer): string;
{$IFDEF Win32}
const
  MAX_MES = 512;
var
  Buf: PWideChar;
begin
  Buf := AllocMem(MAX_MES);
  try
    FormatMessageW(
      Format_Message_From_System,
      Nil,
      ErrorCode,
      (SubLang_Default shl 10) + Lang_Neutral,
      Buf,
      MAX_MES,
      Nil);
  finally
    Result := string(Buf);
    FreeMem(Buf);
  end;
end;
{$ELSE}
begin
  Result := 'ERROR-' + IntToStr(ErrorCode);
end;
{$ENDIF}

function GetLastErrorStr: string;
{$IFDEF Win32}
begin
  Result := GetLastErrorMessage(GetLastError);
end;
{$ELSE}
begin
  Result := 'LastError';
end;
{$ENDIF}

end.
