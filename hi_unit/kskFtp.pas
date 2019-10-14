unit kskFtp;
// ���@���FFTP,HTTP�֘A�N���X�̃��j�b�g
// ��@�ҁF�N�W����s��(http://kujirahand.com)
// ���J���F2001/10/21 ��{�쐬
//         2004/12/03 �X���b�h�ɑΉ�

// ���̃��C�u�����쐬�̂��߂ɁA
// http://user.ecc.u-tokyo.ac.jp/~t00664/delphi/
// ���Q�l�ɂ��܂����B���ӁB

interface

uses
  SysUtils, Classes, Wininet, Windows, messages, commctrl, mmsystem;

type

  TkskProgress = procedure (var readByte: Cardinal; var totalByte: Cardinal;
    var flagStop: Boolean) of Object;

  TkskFtpWriter = class(TThread)
  private
    hFTPSession : HINTERNET;
    FStream: TStream;
    FName: AnsiString;
    OnError: TNotifyEvent;
    OnProgress: TkskProgress;
    FMode: DWORD;
  protected
    procedure Execute; override;
  public
    status: AnsiString;
    constructor Create(AhFTPSession: HINTERNET; AName: AnsiString; AStream: TStream;
      AMode: DWORD ; AOnError, AOnComplate: TNotifyEvent; AOnProgress: TkskProgress);
  end;

  TkskFtpReader = class(TThread)
  private
    hFTPSession : HINTERNET;
    FStream: TStream;
    FRemoteFile: AnsiString;
    OnError: TNotifyEvent;
    OnProgress: TkskProgress;
    FMode: DWORD;
  protected
    procedure Execute; override;
  public
    status: AnsiString;
    constructor Create(AhFTPSession: HINTERNET; ARemoteFile: AnsiString;
      AStream: TStream; AMode: DWORD ;
      AOnError, AOnComplate: TNotifyEvent; AOnProgress: TkskProgress);
  end;

  TkskFTP = class
  private
    FCurrentDir : AnsiString;
    FPort : Integer;
    FHost : AnsiString;
    FUserID : AnsiString;
    FPassword : AnsiString;
    FConnected : boolean;
    hInternetSession : HINTERNET;
    hFTPSession : HINTERNET;
    FMode : Cardinal;
    // EVENT DIALOG
    hProgress: HWND;
    FCompleteFlag: Boolean;
    FCancel: Boolean;
    procedure OnProgress(var readByte: Cardinal; var totalByte: Cardinal;
      var flagStop: Boolean);
    procedure OnError(Sender: TObject);
    procedure OnComplate(Sender: TObject);
  public
    useDialog: Boolean;
    ErrorMsg: AnsiString;
    constructor Create;
    destructor Destroy; override;
    procedure Initialize;
    procedure Uninitialize;

    function Connect : boolean;
    function Disconnect : boolean;
    function Upload( ALocalFile, ARemoteFile : AnsiString ) : Boolean;
    function Download( ARemoteFile, ALocalFile : AnsiString ) : boolean;
    function CheckConfig : Integer;
    function CreateDir(DirName : AnsiString) : boolean;
    function ChangeDir(DirName : AnsiString) : boolean;
    function DeleteDir(DirName : AnsiString) : boolean;
    function DeleteFile(FileName : AnsiString) : boolean;
    function RanemeFile(OldName, NewName: AnsiString) : boolean;
    function Command(s: AnsiString; UseRes: Boolean; var res: AnsiString) : boolean;
    function Glob(path: AnsiString): AnsiString;        //�t�@�C����񋓂���Ƃ�
    function GlobDir(path: AnsiString): AnsiString;     //�t�H���_��񋓂���Ƃ�
    procedure ShowDialog(title, text, info: AnsiString); // �_�C�A���O

    property Connected : Boolean read FConnected;
    property CurrentDir : AnsiString read FCurrentDir;
    property Mode : Cardinal read FMode write FMode default FTP_TRANSFER_TYPE_BINARY;

  published
    property Port : Integer read FPort write FPort default INTERNET_DEFAULT_FTP_PORT;
    property UserID : AnsiString read FUserID write FUserID;
    property Host : AnsiString read FHost write FHost;
    property Password : AnsiString read FPassword write FPassword;
  end;

  //----------------------------------------------------------------------------
  TkskHttp = class
  public
    procProgress: TkskProgress;
    UserAgent: AnsiString;
    HTTP_VERSION: AnsiString;
    TimeOut: Integer;
    Header: String;
    constructor Create;
    function Get(const URL, FileName: AnsiString): Boolean;
    function GetAsText(const URL: AnsiString): AnsiString;
    function GetAsMem(const URL: AnsiString; mem: TMemoryStream): Boolean;
    function GetHeader(const URL: AnsiString): AnsiString;
    function Post(const URL, Data, boundary, USER, PW: AnsiString; port: Integer): AnsiString;
  end;

  THTTPSyncFileDownloader = class(TThread)
  private
    FUserAgent, FURL, FHeaders: AnsiString;
    FOnError: TNotifyEvent;
    FOnProgress: TkskProgress;
    Stream: TStream;
    FHttpVersion: AnsiString;
    FMethod: string;
    FPostBody: string;
  protected
    procedure Execute; override;
  public
    ErrorMsg: AnsiString;
    constructor Create(aUserAgent, aURL, aHeaders, aHttpVersion: AnsiString; aStream: TStream;
      AOnComplete, AOnError: TNotifyEvent; AOnProgress: TkskProgress); overload;
    constructor Create(aMethod, aPostBody, aUserAgent, aURL, aHeaders, aHttpVersion: AnsiString; aStream: TStream;
      AOnComplete, AOnError: TNotifyEvent; AOnProgress: TkskProgress); overload;
  end;

  TkskHttpDialog = class
  private
    hProgress: HWND;
    FCompleteFlag: Boolean;
    FCancel: Boolean;
    downloader: THTTPSyncFileDownloader;
    procedure OnComplete(Sender: TObject);
    procedure OnError(Sender: TObject);
    procedure OnProgress(var readByte: Cardinal; var totalByte: Cardinal;
      var flagStop: Boolean);
  public
    Stream: TMemoryStream;
    id: AnsiString;
    password: AnsiString;
    UseBasicAuth: Boolean;
    UseDialog: Boolean;
    UserAgent: AnsiString;
    httpVersion: AnsiString;
    Referer: AnsiString;
    Header: AnsiString;
    Method: AnsiString;
    PostBody: AnsiString;
    constructor Create;
    destructor Destroy; override;
    function DownloadDialog(const URL: AnsiString): Boolean;
  end;

var MainWindowHandle: THandle = 0;

function IsGlobalOffline: boolean;
function IsInternetConnected: boolean;
procedure splitURL(url:AnsiString; var protocol:AnsiString; var domain:AnsiString; var path:AnsiString; var port:Integer);
procedure SetTimeOut(hSession:HINTERNET; Seconds: Integer); //TimeOut�̐ݒ�

implementation

uses nako_dialog_const, unit_windows_api, unit_string,
  nako_dialog_function, jconvert;

// �Q�l)
// http://www.ichibachi.com/delphi/wininet.html
function IsGlobalOffline: boolean;
var
  State, Size: DWORD;
begin
  Result := False;
  State := 0;
  Size := SizeOf(DWORD);
  if InternetQueryOption(nil, INTERNET_OPTION_CONNECTED_STATE, @State, Size) then
    if (State and INTERNET_STATE_DISCONNECTED_BY_USER) <> 0 then
      Result := True;
end;

function IsInternetConnected: boolean;
var
  ConnectType : DWORD;
begin
  ConnectType := INTERNET_CONNECTION_MODEM + INTERNET_CONNECTION_LAN + INTERNET_CONNECTION_PROXY;
  Result := InternetGetConnectedState(@ConnectType, 0);
end;


function getMainWindowHandle: THandle;
begin
  if MainWindowHandle = 0 then
  begin
    MainWindowHandle := GetForegroundWindow;
  end;
  Result := MainWindowHandle;
end;

function GetHttpStatus(hRequest:HINTERNET): Integer;
var
  Len, r: DWORD;
begin
  Len := SizeOf(Result);
  r := 0;
  HttpQueryInfo(hRequest, HTTP_QUERY_STATUS_CODE or HTTP_QUERY_FLAG_NUMBER,
    @Result, Len, r);
end;

procedure SetTimeOut(hSession:HINTERNET; Seconds: Integer); //TimeOut�̐ݒ�
var
  TimeOut: integer;
begin
  TimeOut := Seconds * 1000; //�P�ʂ�ms -> �b�ɕϊ�
  InternetSetOption(
    hSession,
    INTERNET_OPTION_RECEIVE_TIMEOUT,
    @TimeOut,
    SizeOf(TimeOut));
end;

procedure splitURL(url:AnsiString; var protocol:AnsiString; var domain:AnsiString; var path:AnsiString; var port:Integer);
var
  sport: AnsiString;
begin
  protocol := getToken_s(url, '://');
  domain   := getToken_s(url, '/');
  path     := '/' + url;
  // Check Port
  port := INTERNET_DEFAULT_HTTP_PORT;
  if protocol = 'https' then
  begin
    port := INTERNET_DEFAULT_HTTPS_PORT;
  end;
  if Pos(':', domain) > 0 then
  begin
    sport  := domain;
    domain := getToken_s(sport, ':');
    port   := StrToIntDef(sport, port);
  end;
end;

type
  FtpCommand_IE5 = function (
    hConnect: HINTERNET;
    fExpectResponse: BOOL;
    dwFlags: DWORD;
    lpszCommand: PAnsiChar;
    dwContext: DWORD;
    phFtpCommand: PHINTERNET): BOOL; stdcall;

var kskFlagStop: Boolean = False;

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
          kskFlagStop := True;
        end;
      end;
  end;
end;


constructor TkskFTP.Create;
begin
  useDialog     := False;
  FCompleteFlag := False;
  Mode          := FTP_TRANSFER_TYPE_BINARY;
  FCurrentDir   := '';
  Initialize;
end;

destructor TkskFTP.Destroy;
begin
  // �s�v: Disconnect;
  Uninitialize;
  inherited;
end;

procedure TkskFTP.Initialize;
begin
  hInternetSession := InternetOpen({PAnsiChar(Application.Exename)}'ftp.exe',
                              INTERNET_OPEN_TYPE_DIRECT,
                              nil, nil, 0 );
end;

procedure TkskFTP.Uninitialize;
begin
  InternetCloseHandle(hInternetSession);
end;


function TkskFTP.CheckConfig : Integer;
// �ݒ肪�Ȃ���Ă��邩�ǂ������ׂ܂��B
// hostname=$0001,port=$0002,username=$0004,password=$0008;
// ���ꂼ��t���O�������Ă�����ݒ肳��Ă��Ȃ��B
// ����= 0
begin
  result := 0;
  if( Host = '' ) then Result := Result or $0001;
  if( Port = 0 ) then Result := Result or $0002;
  if( UserID = '' ) then Result := Result or $0004;
  if( Password = '' ) then Result := Result or $0008;
end;


function TkskFTP.Connect : boolean;
// ftp�ڑ�������B����I����true��Ԃ��B
var   buf : array[0..MAX_PATH-1] of AnsiChar;
      bufsize : DWORD;
begin
  // �ݒ肪�s���S���A���łɐڑ�����Ă����Exit
  if( (CheckConfig <> $0000) ) then begin Result := false; Exit end;
  if( Connected ) then begin Result := True; Exit end;
  // �����łȂ���ΐڑ������݂�B
  hFTPSession := InternetConnectA(hInternetSession,
                                 PAnsiChar(Host),
                                 Port,
                                 PAnsiChar(UserID),
                                 PAnsiChar(Password),
                                 INTERNET_SERVICE_FTP,
                                 INTERNET_FLAG_PASSIVE,
                                 0
                                 );
  if(hFTPSession<>nil) then begin
    FConnected := true;
    Result := true;
    FtpGetCurrentDirectoryA(hFTPSession,buf,bufsize);
    FCurrentDir := buf;
  end
  else Result := false
end;


function TkskFTP.Disconnect : Boolean;
// �ؒf����B����I����true��Ԃ��B
begin
  if not connected then begin Result := false; Exit end;
  Result := InternetCloseHandle(hFTPSession);
  FConnected := false;
end;


function TkskFTP.Upload(ALocalFile, ARemoteFile : AnsiString) : boolean;
var
  uploader: TkskFtpWriter;
  stream: TMemoryStream;
begin
  if useDialog then
  begin
    // loacal
    stream := TMemoryStream.Create;
    try
      stream.LoadFromFile(ALocalFile);
      Result := False;
      FCompleteFlag := False;

      uploader := TkskFtpWriter.Create(hFTPSession, ARemotefile, stream, Mode,
        OnError, OnComplate, OnProgress);

      // �_�E�����[�h���I������܂Ń_�C�A���O��\��
      showDialog(
        'FTP�A�b�v���[�h�o�ߕ\��',
        'FTP�A�b�v���[�h������',
        ExtractFileName(ALocalFile) + '��' + ARemoteFile);

      Result := (FCancel = False);
      ErrorMsg := uploader.status;
      uploader.Free;

    finally
      stream.Free;
    end;
  end else
  begin
    // not useDialog
    if(not FtpPutFileA(hFTPSession,
                    PAnsiChar(ALocalfile),
                    PAnsiChar(ARemotefile),
                    Mode or INTERNET_FLAG_RELOAD,
                    0 )
    ) then Result := false else Result := true;
  end;
end;

function TkskFTP.Download(ARemotefile,ALocalfile : AnsiString) : boolean;
var
  stream: TMemoryStream;
  downloader: TkskFtpReader;
begin

  if useDialog then
  begin
    // loacal
    stream := TMemoryStream.Create;
    try
      Result := False;
      FCompleteFlag := False;

      downloader := TkskFtpReader.Create(hFTPSession, ARemotefile, stream, Mode,
        OnError, OnComplate, OnProgress);

      // �_�E�����[�h���I������܂Ń_�C�A���O��\��
      showDialog(
        'FTP�_�E�����[�h�o�ߕ\��',
        'FTP�_�E�����[�h������',
        ARemoteFile + '��' + ExtractFileName(ALocalFile));

      Result := (FCancel = False);
      ErrorMsg := downloader.status;
      downloader.Free;
      if Result then stream.SaveToFile(ALocalfile);
    finally
      stream.Free;
    end;
  end else
  begin
    if( not FtpGetFileA(hFTPSession,
          PAnsiChar(ARemotefile),
          PAnsiChar(ALocalfile),
          false, // �㏑���G���[���o�����ǂ���
          FILE_ATTRIBUTE_NORMAL,
          Mode,
          0 ) ) then Result:=false else Result:=true;
  end;
end;

function TkskFTP.ChangeDir(DirName : AnsiString) : boolean;
var buf : array[0..MAX_PATH] of char;
    bufsize : DWORD;
begin
  Result := FtpSetCurrentDirectoryA(hFTPSession,PAnsiChar(DirName));
  if Result then
  begin
    bufsize := MAX_PATH;
    FtpGetCurrentDirectory(hFTPSession,buf,bufsize);
    FCurrentDir := buf;
  end;
end;


{ TkskHttp }

function TkskHttp.Get(const URL, FileName: AnsiString): Boolean;
var
  mem: TMemoryStream;
begin
  mem := TMemoryStream.Create;
  try
    Result := GetAsMem(URL, mem);
    mem.SaveToFile(FileName);
  finally
    mem.Free;
  end;
end;

function TkskFTP.DeleteDir(DirName: AnsiString): boolean;
begin
    Result := FtpRemoveDirectoryA(hFTPSession, PAnsiChar(DirName));
end;

function TkskFTP.DeleteFile(FileName: AnsiString): boolean;
begin
    Result := FtpDeleteFileA(hFTPSession, PAnsiChar(FileName));
end;

function TkskFTP.Glob(path: AnsiString): AnsiString;
var
    fd: TWin32FindDataA;
    //res: Cardinal ;
    hDir: HINTERNET;
begin
    Result := '';
    hDir := FtpFindFirstFileA(
        hFTPSession,
        PAnsiChar(path),
        fd,
        INTERNET_FLAG_RELOAD,
        0);
    if GetLastError = ERROR_NO_MORE_FILES then Exit;
    if fd.dwFileAttributes <> FILE_ATTRIBUTE_DIRECTORY then Result := fd.cFileName ;
    while True do
    begin
        if not InternetFindNextFile(hDir, @fd) then
        begin
            //res := GetLastError ;
            //if res = ERROR_NO_MORE_FILES then Break;
            //raise ;
            Break;
        end else
        begin
            if fd.dwFileAttributes <> FILE_ATTRIBUTE_DIRECTORY then Result := Result + #13#10 + fd.cFileName ;
        end;
    end;
end;

function TkskFTP.GlobDir(path: AnsiString): AnsiString;
var
    fd: TWin32FindDataA;
    //res: Cardinal ;
    hDir: HINTERNET;
begin
    Result := '';
    hDir := FtpFindFirstFileA(
        hFTPSession,
        PAnsiChar(path),
        fd,
        INTERNET_FLAG_RELOAD,
        0);
    if GetLastError = ERROR_NO_MORE_FILES then Exit;
    if fd.dwFileAttributes = FILE_ATTRIBUTE_DIRECTORY then Result := fd.cFileName ;

    while True do
    begin
        if not InternetFindNextFile(hDir, @fd) then
        begin
            //res := GetLastError ;
            //if res = ERROR_NO_MORE_FILES then Break;
            //raise ;
            Break;
        end else
        begin
            if fd.dwFileAttributes = FILE_ATTRIBUTE_DIRECTORY then Result := Result + #13#10 + fd.cFileName ;
        end;
    end;
end;

function TkskFTP.CreateDir(DirName: AnsiString): boolean;
var buf : array[0..MAX_PATH] of char;
    bufsize : DWORD;
begin
  Result := FtpCreateDirectoryA(hFTPSession, PAnsiChar(DirName));
  if Result then
  begin
    bufsize := MAX_PATH;
    FtpGetCurrentDirectory(hFTPSession,buf,bufsize);
    FCurrentDir := buf;
  end;
end;

function TkskHttp.GetAsText(const URL: AnsiString): AnsiString;
var
  mem: TMemoryStream;
begin
  Result := '';
  mem := TMemoryStream.Create;
  try
    if GetAsMem(URL, mem) = False then raise Exception.Create(URL+'�̎擾�Ɏ��s���܂����B');
    if mem.Size > 0 then
    begin
      SetLength(Result,    mem.Size);
      mem.Position := 0;
      mem.Read (Result[1], mem.Size);
    end;
  finally
    mem.Free;
  end;
end;

function TkskHttp.GetAsMem(const URL: AnsiString; mem: TMemoryStream): Boolean;
var
  hHttpSession, hReqUrl: HInternet;
  Buffer: array[0..1023]of Char;
  nRead, nCount, nTotal: Cardinal;
  d: DWORD;
  res: BOOL;
  flagStop: Boolean;
  pHead: PChar;
begin
  Result := False;

  // InternetOpen
  hHttpSession := InternetOpen('HTTP', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if hHttpSession = nil then Exit; // ERROR
  try
    // OpenURL
    pHead := nil;
    if Header <> '' then pHead := PChar(Header);
    hReqUrl := InternetOpenURLA(hHttpSession, PAnsiChar(URL), pHead, 0,0,0);
    if hReqUrl = nil then Exit;
    try
      // Query Head
      nRead := Length(Buffer);
      HttpQueryInfo(hReqUrl, HTTP_QUERY_CONTENT_LENGTH, @Buffer[0], nRead, d);
      nTotal := StrToIntDef(PAnsiChar(@Buffer[0]), 0); // ?w?b?_?(c)?c,???^(3)?????3/4
      nCount := 0;
      // get data
      repeat
        // progress
        if Assigned(procProgress) then
        begin
          procProgress(nCount, nTotal, flagStop);
          if flagStop then Exit;
        end;
        // read
        res := InternetReadFile(hReqUrl, @Buffer, sizeof(Buffer), nRead);
        if res then
        begin
          mem.Write(buffer, nRead); // ?o?b?t?@?O"?C,?A'
          Inc(nCount, nRead);
        end else
        begin
          Exit;
        end;
      until nRead = 0;
      Result := True;
    finally
      InternetCloseHandle(hReqUrl);
    end;
  finally
      InternetCloseHandle(hHttpSession);
  end;
end;

function TkskHttp.GetHeader(const URL: AnsiString): AnsiString;
var
  hHttpSession, hReqUrl: HInternet;
  Buffer: array[0..4095]of Char;
  nRead: Cardinal;
  d: DWORD;
begin
  Result := '';

  // InternetOpen
  hHttpSession := InternetOpen('HTTP', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if hHttpSession = nil then Exit; // ERROR
  try
    // OpenURL
    hReqUrl := InternetOpenURLA(hHttpSession, PAnsiChar(URL), nil, 0,0,0);
    if hReqUrl = nil then raise Exception.Create('URL���J���܂���B');
    try
      // Query Head
      nRead := Length(Buffer); d := 0;
      HttpQueryInfo(hReqUrl, HTTP_QUERY_RAW_HEADERS_CRLF, @Buffer[0], nRead, d);
      Result := AnsiString( PAnsiChar( @Buffer[0] ) );
    finally
      InternetCloseHandle(hReqUrl);
    end;
  finally
      InternetCloseHandle(hHttpSession);
  end;
end;

function TkskHttp.Post(const URL, Data, boundary, USER, PW: AnsiString; port: Integer): AnsiString;
const
  BUFFSIZE = 500;

var
  hSession, hConnect, hReq: HINTERNET;
  server, path: AnsiString;
  buf: AnsiString;
  dwBytesRead: DWORD;
  pcBuffer: Array [0..BUFFSIZE-1] of Char;

  function UseHttpSendReqEx: Boolean;
  var
    BufferIn: INTERNET_BUFFERS;
    dwBytesWritten: DWORD;
    bRet: Boolean;
  begin
    ZeroMemory(@BufferIn, SizeOf(BufferIn));
    BufferIn.dwStructSize   := SizeOf(INTERNET_BUFFERS);
    BufferIn.dwBufferTotal  := Length(Data);

    if not HttpSendRequestEx(hReq, @BufferIn, nil, 0, 0) then
    begin
      raise Exception.Create('Error on HttpSendRequestEx ' + IntToStr(GetLastError));
    end;

    bRet := InternetWriteFile(hReq, @Data[1], Length(Data), dwBytesWritten);
    if not bRet then raise Exception.Create('Error on InternetWriteFile ' + IntToStr(GetLastError));

    HttpEndRequest(hReq, nil, 0, 0);
    Result := True;
  end;

begin
  Result := '';

  path := URL;
  getToken_s(path, '//');
  server := getToken_s(path, '/');
  //boundary := '--------------------__com.nadesiko.2005.01__' + IntToHex(timeGetTime,4);

  // InternetOpen
  hSession := InternetOpen('HttpSendRequestEx', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if hSession = nil then raise Exception.Create('WinInet�𗘗p�ł��܂���B');
  try
    // session
    if (USER='')and(PW='') then
    begin
      hConnect := InternetConnectA(
        hSession, PAnsiChar(server), port, nil, nil, INTERNET_SERVICE_HTTP, 0, 0);
    end else
    begin
      hConnect := InternetConnectA(
        hSession, PAnsiChar(server), port, PAnsiChar(USER), PAnsiChar(PW),
        INTERNET_SERVICE_HTTP, 0, 0);
    end;
    if hConnect = nil then raise Exception.Create(URL+'���J���܂���B' + GetLastErrorStr);
    try

      hReq := HttpOpenRequestA(
        hConnect, 'POST', PAnsiChar(path), nil, nil, nil,
        INTERNET_FLAG_NO_CACHE_WRITE, 0);

      if UseHttpSendReqEx then
      begin
        repeat
          dwBytesRead := 0;
          if InternetReadFile(hReq, @pcBuffer[0], BUFFSIZE-1, dwBytesRead) then
          begin
            pcBuffer[dwBytesRead] := #0;
            SetLength(buf, dwBytesRead);
            Move(pcBuffer[0], buf[1], dwBytesRead);
            Result := Result + buf;
          end else
          begin
            Break;
          end;
        until (dwBytesRead > 0);
      end;
    finally
      InternetCloseHandle(hConnect);
    end;
  finally
    InternetCloseHandle(hSession);
  end;

end;

constructor TkskHttp.Create;
begin
  UserAgent := 'kskHttp';
  HTTP_VERSION := 'HTTP/1.1';
  TimeOut := 60;
  Header := '';
end;

{ THTTPSyncFileDownloader }

constructor THTTPSyncFileDownloader.Create(aUserAgent, aURL, aHeaders,
  aHttpVersion: AnsiString; aStream: TStream; AOnComplete, AOnError: TNotifyEvent;
  AOnProgress: TkskProgress);
begin
  inherited Create(False);

  FreeOnTerminate := False;

  FUserAgent := aUserAgent;
  FURL       := aURL;
  FHeaders   := aHeaders;
  FHttpVersion := aHttpVersion;
  Stream     := aStream;
  ErrorMsg   := '';
  FMethod    := 'GET';

  OnTerminate := AOnComplete;
  FOnError    := AOnError;
  FOnProgress := AOnProgress;
end;

constructor THTTPSyncFileDownloader.Create(aMethod, aPostBody, aUserAgent,
  aURL, aHeaders, aHttpVersion: AnsiString; aStream: TStream; AOnComplete,
  AOnError: TNotifyEvent; AOnProgress: TkskProgress);
begin
  inherited Create(False);

  FreeOnTerminate := False;

  FUserAgent := aUserAgent;
  FURL       := aURL;
  FHeaders   := aHeaders;
  FHttpVersion := aHttpVersion;
  Stream     := aStream;
  ErrorMsg   := '';
  FMethod    := aMethod;
  FPostBody  := aPostBody;

  OnTerminate := AOnComplete;
  FOnError    := AOnError;
  FOnProgress := AOnProgress;
end;

procedure THTTPSyncFileDownloader.Execute;
var
  hSession: HINTERNET;
  hRequest: HINTERNET;
  hcon: HINTERNET;
  lpBuffer: array[0..65535] of Byte;
  dwBytesRead: DWORD;
  szHeader: AnsiString;
  dwTotal, dwRead, Reserved: DWORD;
  flagStop: Boolean;
  dwFlags: DWORD;
  dwBuffLen: DWORD;
  protocol, domain, path: AnsiString;
  b: BOOL;

  procedure closeHandleAll;
  begin
    if Assigned(hcon) then InternetCloseHandle(hcon);
    if Assigned(hRequest) then InternetCloseHandle(hRequest);
    if Assigned(hSession) then InternetCloseHandle(hSession);
  end;

  procedure err(msg: AnsiString);
  begin
    //
    closeHandleAll;
    ErrorMsg := msg;
    if Assigned(FOnError) then FOnError(Self);
  end;

  function _httpsDownload: Boolean;
  var
    code, port: Integer;
    flag: Cardinal;
  begin
    Result := False;
    splitURL(FUrl, protocol, domain, path, port);

    // connect
    hcon := InternetConnectA(
      hSession,
      PAnsiChar(domain),
      port,
      '',// username
      '',// password
      INTERNET_SERVICE_HTTP, 0, 0);
    if not Assigned(hcon) then begin err('�ڑ��G���['); Exit; end;

    // request
    flag := INTERNET_SERVICE_HTTP;
    if protocol = 'https' then flag := INTERNET_FLAG_SECURE or INTERNET_FLAG_KEEP_CONNECTION;
    hRequest := HttpOpenRequestA(
      hcon,
      PAnsiChar(FMethod),
      PAnsiChar(path),
      PAnsiChar(FHttpVersion),
      nil,
      nil,
      flag,
      0);
    if not Assigned(hRequest) then
    begin
      err('���N�G�X�g���̃G���['); Exit;
    end;
    
    // request option
    if protocol = 'https' then
    begin
      dwFlags := 0;
      dwBuffLen := sizeof(dwFlags);
      InternetQueryOption(hRequest, INTERNET_OPTION_SECURITY_FLAGS,
        @dwFlags, dwBuffLen);
      dwFlags := dwFlags or SECURITY_FLAG_IGNORE_UNKNOWN_CA;
      dwFlags := dwFlags or SECURITY_FLAG_IGNORE_CERT_CN_INVALID;
      dwFlags := dwFlags or SECURITY_FLAG_IGNORE_CERT_DATE_INVALID;
      dwFlags := dwFlags or SECURITY_FLAG_IGNORE_REDIRECT_TO_HTTP;
      dwFlags := dwFlags or SECURITY_FLAG_IGNORE_REDIRECT_TO_HTTPS;
      if not InternetSetOption (hRequest, INTERNET_OPTION_SECURITY_FLAGS,
       @dwFlags, sizeof(dwFlags)) then
      begin
        err('�F�؂Ɋւ���G���['); Exit;
      end;
    end;
    
    if FHeaders <> '' then
    begin
      b := HttpAddRequestHeadersA(hRequest, PAnsiChar(FHeaders), Length(FHeaders),
        HTTP_ADDREQ_FLAG_REPLACE or HTTP_ADDREQ_FLAG_ADD);
      if not b then begin err('�w�b�_�̐ݒ�Ɏ��s���܂����B@' + FHeaders + '@'); exit; end;
    end;

    if not HttpSendRequest(hRequest, nil, 0, PChar(FPostBody), Length(FPostBody)) then
    begin
      err('���N�G�X�g���M���̃G���['); Exit;
    end;

    code := GetHttpStatus(hRequest);
    if code <> HTTP_STATUS_OK then
    begin
      err('�X�e�[�^�X�R�[�h�ُ̈�:' + IntToStr(code)); Exit;
    end;

    Result := True;
  end;

begin
  inherited;

  flagStop := False;
  try
    hSession := InternetOpenA(PAnsiChar(FUserAgent), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
    if not Assigned(hSession) then
    begin
      err('�Z�b�V�������J���܂���B'); Exit;
    end;

    if UpperCase(FMethod) = 'POST' then
    begin
      if not _httpsDownload then Exit;
    end else begin
      // InternetOpenUrl
      szheader := FHeaders;
      SetLength(szHeader, Length(szHeader));
      hRequest := InternetOpenUrlA(hSession, PAnsiChar(FUrl),
                    PAnsiChar(FHeaders), Length(szheader),
                    INTERNET_FLAG_RELOAD, 0);

      // CA(�F��)�G���[�̏ꍇ�A�����I�v�V�������Z�b�g����
      if not Assigned(hRequest) then
      begin
        if (GetLastError = ERROR_INTERNET_INVALID_CA) or
          (GetLastError = ERROR_INTERNET_CLIENT_AUTH_CERT_NEEDED) then
        begin
          if not _httpsDownload then Exit;
        end;
      end else begin
        if not Assigned(hRequest) then
        begin
          err('���N�G�X�g���̃G���['); Exit;
        end;
      end;
    end;
    // �w�b�_�̎擾
    dwBytesRead := Length(lpBuffer);
    ZeroMemory(@lpBuffer, dwBytesRead);
    HttpQueryInfo(hRequest, HTTP_QUERY_CONTENT_LENGTH,
        @lpBuffer, dwBytesRead, Reserved);
    dwTotal := StrToIntDef(AnsiString( @lpBuffer ), 0);
    dwRead  := 0;

    dwBytesRead := Length(lpBuffer);
    while dwBytesRead <> 0 do
    begin

      if Terminated or kskFlagStop then
      begin
        err('���[�U�[�ɂ�钆�f');
        Break;
      end;

      if Assigned(FOnProgress) then
      begin
        FOnProgress(dwRead, dwTotal, flagStop);
        if flagStop then
        begin
          err('���[�U�[�ɂ�钆�f');
          Break;
        end;
      end;

      if InternetReadFile(hRequest, @lpBuffer, Length(lpBuffer), dwBytesRead) then
      begin
        stream.WriteBuffer(lpBuffer, dwBytesRead);
        Inc(dwRead, dwBytesRead);
      end else
      begin
        err('�f�[�^���ǂݎ��܂���B');
        Break;
      end;

      Sleep(10);
    end;
    if Assigned(OnTerminate) then
    begin
      OnTerminate(Self);
    end;
  finally
    closeHandleAll;
  end;
end;


{ TkskHttpDialog }

constructor TkskHttpDialog.Create;
begin
  UserAgent := '';
  downloader := nil;
  Header := '';
  Method := 'GET';
  PostBody := '';
  FCancel := False;
  Stream := TMemoryStream.Create;
  UseDialog := True;
end;

destructor TkskHttpDialog.Destroy;
begin
  Stream.Free;
  inherited;
end;

function TkskHttpDialog.DownloadDialog(const URL: AnsiString): Boolean;
var
  hParent: HWND;
  msg: TMsg;
  head: AnsiString;
begin
  //Result := False;
  hParent := getMainWindowHandle;

  FCompleteFlag := False;
  FCancel := False;
  kskFlagStop := False;

  if UseDialog then
  begin
    // �_�C�A���O�̕\��
    hProgress  := CreateDialogA(
        hInstance, PAnsiChar(IDD_DIALOG_PROGRESS), hParent, @procProgress);

    // �_�C�A���O�ɏ���\��
    SetDlgWinText(hProgress, IDC_EDIT_TEXT, '�_�E�����[�h������');
    SetDlgWinText(hProgress, IDC_EDIT_INFO, URL);
    ShowWindow(hProgress, SW_SHOW);
  end;

  // �w�b�_������
  head := '';
  if Header <> '' then
  begin
    head := head + Header + #13#10;
  end;
  if UseBasicAuth then
  begin
    head := head + 'Authorization: Basic ' + EncodeBase64(id + ':' + password) + #13#10;
  end;
  if Referer <> '' then
  begin
    head := head + 'Referer:' + Referer + #13#10;
  end;
  head := Trim(head);

  // �_�E�����[�h�p�̃X���b�h�̍쐬
  downloader := THTTPSyncFileDownloader.Create(Method, PostBody, UserAgent, url, head, httpVersion,
    Stream, OnComplete, OnError, OnProgress);
  try
    // �_�E�����[�h���I������܂Ń_�C�A���O��\��
    if UseDialog then
    begin
      while FCompleteFlag = False do
      begin
        if PeekMessage(msg, hProgress, 0, 0, PM_REMOVE) then
        begin
          if not IsDialogMessage(hProgress, msg) then
          begin
            TranslateMessage(msg);
            DispatchMessage (msg);
          end;
        end else
        begin
          // �A�C�h��
          sleep(1);
        end;
      end;

      DestroyWindow(hProgress);
      hProgress := 0;
    end else
    begin
      while FCompleteFlag = False do
      begin
        sleep(200);
      end;
    end;

    if FCancel then
    begin
      Stream.Clear;
      raise Exception.Create('�_�E�����[�h�Ɏ��s���܂����B' + downloader.ErrorMsg);
    end;
  finally
    downloader.Free;
  end;
  Result := True;
end;

procedure TkskHttpDialog.OnComplete(Sender: TObject);
begin
  FCompleteFlag := True;
end;

procedure TkskHttpDialog.OnError(Sender: TObject);
begin
  FCompleteFlag := True;
  FCancel := True;
end;

procedure TkskHttpDialog.OnProgress(var readByte, totalByte: Cardinal;
  var flagStop: Boolean);
var
  s: AnsiString;
begin
  // download text
  s := '�_�E�����[�h�� (' + IntToStr(Trunc(readByte/1024)) + '/' + IntToStr(Trunc(totalByte/1024)) + 'KB)';
  SetDlgWinText(hProgress, IDC_EDIT_TEXT, s);

  // progress bar
  SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
    PBM_SETSTEP, 1, 0);
  // range
  SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
    PBM_SETRANGE, 0, MakeLong(0, 100));

  // pos
  if totalByte > 0 then
  begin
    SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
      PBM_SETPOS, Trunc(readByte/totalByte*100) , LParam(BOOL(True)));
  end;
end;

{ TkskFtpWriter }

constructor TkskFtpWriter.Create(AhFTPSession: HINTERNET; AName: AnsiString;
  AStream: TStream; AMode: DWORD;
  AOnError, AOnComplate: TNotifyEvent; AOnProgress: TkskProgress);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  hFTPSession := AhFTPSession;
  FStream     := AStream;
  FMode       := AMode;
  FName       := AName;
  OnError     := AOnError;
  OnTerminate := AOnComplate;
  OnProgress  := AOnProgress;
end;

procedure TkskFtpWriter.Execute;
var
  hFile : HINTERNET;
  buf   : Array [0..4096] of Char;
  len, total, writeByte : DWORD;
  flagStop : Boolean;
begin
  inherited;

  hFile := FtpOpenFileA(
    hFTPSession,
    PAnsiChar(FName),
    GENERIC_WRITE, FMode, 0);

  if hFile = nil then
  begin
    status := '�t�@�C�����J���܂���';
    OnError(Self); Exit;
  end;

  FStream.Position := 0; // top
  total     := FStream.Size;
  writeByte := 0;
  try
    // ��������
    while not Terminated do
    begin
      // event
      if Assigned(OnProgress) then
      begin
        OnProgress(writeByte, total, flagStop);
        if flagStop or kskFlagStop then
        begin
          status := '���[�U�[�ɂ�钆�f';
          OnError(Self); Exit;
        end;
      end;
      // read buf
      len := FStream.Read(buf[0], Length(buf));
      if len = 0 then Break; // �Ō�܂ŏ�������ł��܂����甲����

      // write buf
      if InternetWriteFile(hFile, @buf, len, len) then
      begin
        Inc(writeByte, len);
      end else
      begin
        status := '�������߂܂���B';
        if Assigned(OnError) then OnError(Self);
      end;
    end;
    if Assigned(OnTerminate) then
    begin
      OnTerminate(Self);
      Exit;
    end;
  finally
    InternetCloseHandle(hFile);
  end;
end;

procedure TkskFTP.OnComplate(Sender: TObject);
begin
  FCompleteFlag := True;
end;

procedure TkskFTP.OnError(Sender: TObject);
begin
  FCancel := True;
  FCompleteFlag := True;
end;

procedure TkskFTP.OnProgress(var readByte, totalByte: Cardinal;
  var flagStop: Boolean);
var
  s: AnsiString;
begin
  // download text
  s := '�]���� (' + IntToStr(Trunc(readByte/1024)) + '/' + IntToStr(Trunc(totalByte/1024)) + ')';
  SetDlgWinText(hProgress, IDC_EDIT_TEXT, s);

  // progress bar
  SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
    PBM_SETSTEP, 1, 0);
  // range
  SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
    PBM_SETRANGE, 0, MakeLong(0, 100));

  // pos
  if totalByte > 0 then
  begin
    SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
      PBM_SETPOS, Trunc(readByte/totalByte*100) , LParam(BOOL(True)));
  end;
end;

procedure TkskFTP.ShowDialog(title, text, info: AnsiString);
var
  hParent: HWND;
  msg: TMsg;
begin
  hParent   := getMainWindowHandle;
  hProgress := CreateDialogA(hInstance, PAnsiChar(IDD_DIALOG_PROGRESS),
                hParent, @procProgress);

  SetDlgWinText(hProgress, IDC_EDIT_TEXT, text);
  SetDlgWinText(hProgress, IDC_EDIT_INFO, info);
  SetWindowText(hProgress, PAnsiChar(title));

  ShowWindow(hProgress, SW_SHOW);

  while FCompleteFlag = False do
  begin
    if PeekMessage(msg, hProgress, 0, 0, PM_REMOVE) then
    begin
      if not IsDialogMessage(hProgress, msg) then
      begin
        TranslateMessage(msg);
        DispatchMessage (msg);
      end;
    end else
    begin
      // �A�C�h��
      sleep(1);
    end;
  end;

  DestroyWindow(hProgress);
  hProgress := 0;
end;

{ TkskFtpReader }

constructor TkskFtpReader.Create(AhFTPSession: HINTERNET;
  ARemoteFile: AnsiString; AStream: TStream; AMode: DWORD; AOnError,
  AOnComplate: TNotifyEvent; AOnProgress: TkskProgress);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  hFTPSession := AhFTPSession;
  FStream     := AStream;
  FMode       := AMode;
  FRemoteFile := ARemoteFile;
  OnError     := AOnError;
  OnTerminate := AOnComplate;
  OnProgress  := AOnProgress;
end;

procedure TkskFtpReader.Execute;
var
  hFile : HINTERNET;
  buf   : Array [0..4096] of Char;
  len, total, readByte : DWORD;
  flagStop : Boolean;
  // fd: WIN32_FIND_DATA;
begin
  inherited;
{ // FtpGetFileSize �ŉ���
  // �t�@�C���̃g�[�^���T�C�Y�����߂�
  hFile := FtpFindFirstFile(
    hFTPSession, PAnsiChar(FRemoteFile),
    fd, 0, 0);
  if hFile = nil then
  begin
    status := '�t�@�C�����J���܂���';
    OnError(Self); Exit;
  end;
  total := fd.nFileSizeLow;
  InternetCloseHandle(hFile);
}

  // �ǂݎ��t�@�C�����J��
  hFile := FtpOpenFileA(
    hFTPSession,
    PAnsiChar(FRemoteFile),
    GENERIC_READ, FMode or INTERNET_FLAG_RELOAD, 0);

  if hFile = nil then
  begin
    status := '�t�@�C�����J���܂���';
    OnError(Self); Exit;
  end;

  FtpGetFileSize(hFile, @total);

  FStream.Position := 0; // top
  readByte := 0;
  try
    // ��������
    while not Terminated do
    begin
      // event
      if Assigned(OnProgress) then
      begin
        OnProgress(readByte, total, flagStop);
        if flagStop or kskFlagStop then
        begin
          status := '���[�U�[�ɂ�钆�f';
          OnError(Self); Exit;
        end;
      end;

      // read file
      if InternetReadFile(hFile, @buf, Length(buf), len) then
      begin
        FStream.Write(buf, len);
        Inc(readByte, len);
      end else
      begin
        status := '�ǂݎ��܂���B';
        if Assigned(OnError) then OnError(Self);
      end;

      if DWORD(Length(buf)) > len then Break;
    end;
    if Assigned(OnTerminate) then
    begin
      OnTerminate(Self);
      Exit;
    end;
  finally
    InternetCloseHandle(hFile);
  end;
end;

function TkskFTP.RanemeFile(OldName, NewName: AnsiString): boolean;
begin
  Result := FtpRenameFileA(hFTPSession, PAnsiChar(OldName), PAnsiChar(NewName));
end;

function TkskFTP.Command(s: AnsiString; UseRes: Boolean; var res: AnsiString): boolean;
var
  hRes: HINTERNET;
  hLib: THandle;
  proc: FtpCommand_IE5;
  buf : Array [0..4096] of Char;
  len : DWORD;
  stream: TMemoryStream;
begin
  hLib := LoadLibrary('wininet.dll'); // IE5�ȍ~
  proc := GetProcAddress(hLib, 'FtpCommandA');
  if not Assigned(proc) then raise Exception.Create('���̖��߂�IE5�ȍ~�ŃT�|�[�g����܂��B');

  res := ''; hRes := nil;

  Result := proc( hFTPSession, UseRes,
    FTP_TRANSFER_TYPE_ASCII, PAnsiChar(s), 0, @hRes);
  if not Result then Exit;
  if UseRes = False then Exit;

  // res �̎擾
  stream := TMemoryStream.Create;
  try
    while hRes <> nil do
    begin
      if not InternetReadFile(hRes, @buf, Length(buf), len) then
      begin
        Exit;
        //raise Exception.Create('FtpCommand�̖߂�l�������܂���B');
      end;
      if len <= 0 then Break;
      stream.Write(buf[0], len);
    end;
    stream.Position := 0;
    SetLength(res, stream.Size);
    stream.Read(res[1], Length(res));
  finally
    stream.Free;
  end;

end;

end.
