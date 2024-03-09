unit WSockUtils;

interface
uses
  SysUtils, Classes, Windows, WinSock, messages, mmsystem, openssl;

type
  TKTcpProgressEvent = procedure (PerDone: Integer; msg: string;
      var Cancel: Boolean) of Object;
  TKTcpLog = procedure (msg: string) of Object;

  //----------------------------------------------------------------------------
  // TCPClient
  EKTcpClient = class(Exception);
  TKTcpClient = class(TComponent)
  private
    // �O�����
    FConnected: Boolean;
    FPort: Integer;
    FHost: string;
    FNegotiatedSSL: Boolean;
    FErrCode: Integer;
    FErrMsg: string;
    // �����Ŏg���ϐ�
    FSocket: TSocket;
    FOnError: TNotifyEvent;
    FOnProgress: TKTcpProgressEvent;
    FBufSize: Integer;
    FReadBuffer: string;
    FTimeout: Integer;
    FOnLog: TKTcpLog;
    Fssl: PSSL;
    Fctx: PSSL_CTX;
    function GetSelfIP: string;
    //function WSCheck(v: Integer; msg: string): Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Open; virtual;  // �T�[�o�[�Ɛڑ�
    procedure Close; virtual; // �T�[�o�[�Ɛؒf
    // SSL�Ή����\�b�h
    function ConnectSSL: boolean; virtual;  // SSL�̃Z�b�V�������J�n����
    function ShutdownSSL: boolean; virtual; // SSL�̃Z�b�V�������I������
    // ���n�I�ȃ��\�b�h
    procedure send(s: string);
    function recv: string;
    // �o�b�t�@�Ǘ����郁�\�b�h
    procedure SendLn(cmd: string; eol: string = #13#10);
    function RecvLn(eol: string = #13#10): string;
    function RecvLnToDot(eol: string = #13#10): string;
    function RecvData(count: Integer): string;
    function RecvDataToEnd: string;
    procedure ClearBuffer;
    //
    property Host: string read FHost write FHost;
    property Port: Integer read FPort write FPort;
    property ReadBuffer: string read FReadBuffer write FReadBuffer;
    property ErrorCode: Integer read FErrCode;
    property ErrorMsg: string read FErrMsg;
    property Buffer: string read FReadBuffer;
    property OnProgress: TKTcpProgressEvent read FOnProgress write FOnProgress;
    property SelfIP: string read GetSelfIP;
    //
    property OnError: TNotifyEvent read FOnError write FOnError;
    property Timeout: Integer read FTimeout write FTimeout;
    property OnLog: TKTcpLog read FOnLog write FOnLog;
  end;


// �T�[�o�[������IP�A�h���X���擾����
function GetIpAddressStr(server: string): string;
// IP�A�h���X����T�[�o�[������IP�A�h���X���擾����
function GetHostNameByAddr(ip: string): string;
// �T�[�o�[������z�X�g�����擾����
function GetHostEnt(server: string): PHostEnt;
// �R���s���[�^�[�����擾
function GetComputerName: string;
// WinSock �̃G���[�𓾂�
function GetSockErrorMsg(err: Integer): string;
// OpenSSL �̃G���[�𓾂�
function GetOpenSSLErrorMsg(err: Integer): string;

var
  WSAData: TWSAData;

implementation

const
  WM_WSOCK_UTILS_STR = 'com.nadesi.wsockutils';
var
  WM_WSOCK_UTILS: DWORD = 0;

// �R���s���[�^�[�����擾
function GetComputerName: string;
var
  buf: string;
  sz: DWORD;
begin
  sz := 1024;
  SetLength(buf, 1024);
  Windows.GetComputerName(PChar(buf), sz);
  Result := string(PChar(buf));
end;

function GetOpenSSLErrorMsg(err: Integer): string;
begin
  case err of
    SSL_ERROR_NONE:              Result := '[0] No Error';
    SSL_ERROR_SSL:               Result := '[1] SSL Error';
    SSL_ERROR_WANT_READ:         Result := '[2] WANT READ';
    SSL_ERROR_WANT_WRITE:        Result := '[3] WANT WRITE';
    SSL_ERROR_WANT_X509_LOOKUP:  Result := '[4] WANT X509 LOOKUP';
    SSL_ERROR_SYSCALL:           Result := '[5] SYSCALL';
    SSL_ERROR_ZERO_RETURN:       Result := '[6] ZERO RETURN';
    SSL_ERROR_WANT_CONNECT:      Result := '[7] WANT CONNECT';
    else                         Result := '[' + IntToStr(err) + '] �G���[';
  end;
end;

function GetSockErrorMsg(err: Integer): string;
begin
  case err of
    WSABASEERR:          Result := '[0] No Error';
    WSAEINTR:            Result := '[10004] Interrupted system call';
    WSAEBADF:            Result := '[10009] Bad file number';
    WSAEACCES:           Result := '[10013] Permission denied';
    WSAEFAULT:           Result := '[10014] Bad address';
    WSAEINVAL:           Result := '[10022] Invalid argument';
    WSAEMFILE:           Result := '[10024] Too many open files';
    WSAEWOULDBLOCK:      Result := '[10035] Operation would block';
    WSAEINPROGRESS:      Result := '[10036] Operation now in progress';
    WSAEALREADY:         Result := '[10037] Operation already in progress';
    WSAENOTSOCK:         Result := '[10038] Socket operation on non-socket';
    WSAEDESTADDRREQ:     Result := '[10039] Destination address required';
    WSAEMSGSIZE:         Result := '[10040] Message too long';
    WSAEPROTOTYPE:       Result := '[10041] Protocol wrong type for socket';
    WSAENOPROTOOPT:      Result := '[10042] Bad protocol option';
    WSAEPROTONOSUPPORT:  Result := '[10043] Protocol not supported';
    WSAESOCKTNOSUPPORT:  Result := '[10044] Socket type not supported';
    WSAEOPNOTSUPP:       Result := '[10045] Operation not supported on socket';
    WSAEPFNOSUPPORT:     Result := '[10046] Protocol family not supported';
    WSAEAFNOSUPPORT:     Result := '[10047] Address family not supported by protocol family';
    WSAEADDRINUSE:       Result := '[10048] Address already in use';
    WSAEADDRNOTAVAIL:    Result := '[10049] Can''t assign requested address';
    WSAENETDOWN:         Result := '[10050] Network is down';
    WSAENETUNREACH:      Result := '[10051] Network is unreachable';
    WSAENETRESET:        Result := '[10052] Net dropped connection or reset';
    WSAECONNABORTED:     Result := '[10053] Software caused connection abort';
    WSAECONNRESET:       Result := '[10054] Connection reset by peer';
    WSAENOBUFS:          Result := '[10055] No buffer space available';
    WSAEISCONN:          Result := '[10056] Socket is already connected';
    WSAENOTCONN:         Result := '[10057] Socket is not connected';
    WSAESHUTDOWN:        Result := '[10058] Can''t send after socket shutdown';
    WSAETOOMANYREFS:     Result := '[10059] Too many referencescan''t splice';
    WSAETIMEDOUT:        Result := '[10060] �ڑ��^�C���A�E�g�B�ڑ��悩��̉����������ԓ͂��܂���B(Connection timed out)';
    WSAECONNREFUSED:     Result := '[10061] �ڑ������₳��܂����B�ڑ���PC�̃|�[�g���J���ĂȂ��\��������܂��B(Connection refused)';
    WSAELOOP:            Result := '[10062] Too many levels of symbolic links';
    WSAENAMETOOLONG:     Result := '[10063] File name too long';
    WSAEHOSTDOWN:        Result := '[10064] Host is down';
    WSAEHOSTUNREACH:     Result := '[10065] No Route to Host';
    WSAENOTEMPTY:        Result := '[10066] Directory not empty';
    WSAEPROCLIM:         Result := '[10067] Too many processes';
    WSAEUSERS:           Result := '[10068] Too many users';
    WSAEDQUOT:           Result := '[10069] Disc Quota Exceeded';
    WSAESTALE:           Result := '[10070] Stale NFS file handle';
    WSAEREMOTE:          Result := '[10071] Too many levels of remote in path';
    WSASYSNOTREADY:      Result := '[10091] Network SubSystem is unavailable';
    WSAVERNOTSUPPORTED:  Result := '[10092] WINSOCK DLL Version out of range';
    WSANOTINITIALISED:   Result := '[10093] Successful WSASTARTUP not yet performed';
    WSAHOST_NOT_FOUND:   Result := '[11001] Host not found';
    WSATRY_AGAIN:        Result := '[11002] Non-Authoritative Host not found';
    WSANO_RECOVERY:      Result := '[11003] Non-Recoverable errors: FORMER RREFUSED NOTIMP';
    WSANO_DATA:          Result := '[11004] Valid name no data record of requested type';
    else                 Result := '[' + IntToStr(err) + '] �G���[';
  end;
end;


// �T�[�o�[������IP�A�h���X���擾����
function GetIpAddressStr(server: string): string;
var
  phe: PHostEnt;
begin
  phe := GetHostEnt(server);
  if phe = nil then
  begin
    Result := ''; // ���s
  end else
  begin
    // in_addr�^����Axxx.xxx.xxx.xxx �̕�����ɕϊ�����
    Result := inet_ntoa(PInAddr(phe.h_addr_list^)^);
  end;
end;

// IP�A�h���X����T�[�o�[������IP�A�h���X���擾����
function GetHostNameByAddr(ip: string): string;
var
  phe: PHostEnt;
  addr: u_long;
begin
  addr := inet_addr(PAnsiChar(ip));
  phe := gethostbyaddr(@addr, SizeOf(addr), AF_INET);
  if phe = nil then phe := GetHostEnt(ip);
  if phe = nil then
  begin
    Result := ''; // ���s
  end else
  begin
    // in_addr�^����Axxx.xxx.xxx.xxx �̕�����ɕϊ�����
    Result := phe.h_name;
  end;
end;


function GetHostEnt(server: string): PHostEnt;
var
  addr: u_long;
  phe: PHostEnt;
begin
  // �T�[�o�[������IP�A�h���X�𓾂�
  phe := gethostbyname(PAnsiChar(server));
  if phe = nil then
  begin
    // IP�A�h���X�̎w�肪���������H
    addr := inet_addr(PAnsiChar(server));
    phe  := gethostbyaddr(@addr, 4, AF_INET);
  end;
  Result := phe;
end;


{ TKTcpClient }

procedure TKTcpClient.ClearBuffer;
begin
  FReadBuffer := '';
end;

procedure TKTcpClient.Close;
begin
  if FNegotiatedSSL then
  begin
    try
      SSL_shutdown(Fssl);
    except
      ;
    end;
    FNegotiatedSSL := false;
  end;
  if FSocket <> INVALID_SOCKET then
  begin
    shutdown(FSocket, SD_BOTH);
    closesocket(FSocket);
    FConnected := False;
  end;
  if Assigned(Fssl) then
  begin
    SSL_free(Fssl);
    Fssl := nil;
  end;
end;


constructor TKTcpClient.Create(AOwner: TComponent);
begin
  inherited;
  FConnected := False;
  FHost := '';
  FPort := 80; // �K���ɏ�����
  FSocket := INVALID_SOCKET;
  FBufSize := 8 * 1024;
  FReadBuffer := '';
  FTimeout := 3000;
  FNegotiatedSSL := False;
  Fssl := nil;
  Fctx := nil;
end;

destructor TKTcpClient.Destroy;
begin
  Close;
  if Assigned(Fctx) then
  begin
    SSL_CTX_free(Fctx);
    Fctx := nil;
  end;
  inherited;
end;

function TKTcpClient.GetSelfIP: string;
var
  name: sockaddr_in;
  namelen: Integer;
begin
  namelen := SizeOf(name);
  ZeroMemory(@name, namelen);
  getsockname(FSocket, name, namelen);
  Result := inet_ntoa(name.sin_addr);
end;

procedure TKTcpClient.Open;
var
  phe: PHostEnt;
  sockadd: sockaddr_in;
begin
  if FConnected then Close;

  // �z�X�g���𓾂�
  phe := GetHostEnt(Host);
  if phe = nil then raise EKTcpClient.Create(Host + '�͑��݂��܂���B');

  // �\�P�b�g�����
  FSocket := socket(PF_INET, SOCK_STREAM, 0);
  if(FSocket = INVALID_SOCKET)then
    raise EKTcpClient.Create('�\�P�b�g���쐬�ł��܂���ł����B');

  // �ڑ���A�h���X��ݒ�
  ZeroMemory(@sockadd, Sizeof(sockadd));
  sockadd.sin_family := AF_INET;
  sockadd.sin_port   := htons(FPort);
  sockadd.sin_addr   := PInAddr(phe.h_addr_list^)^;

  // �ڑ�
  if WinSock.connect(FSocket, sockadd, sizeof(sockadd)) = SOCKET_ERROR then
  begin
    // �ڑ����s
    FErrCode := WSAGetLastError;
    FErrMsg  := GetSockErrorMsg(FErrCode);
    raise EKTcpClient.Create('�z�X�g�Ɛڑ��ł��܂���B' + FErrMsg);
    Exit;
  end;
  FConnected := True;
end;

function TKTcpClient.ConnectSSL: boolean;
var
	ret : integer;
	method : PSSL_METHOD;
begin
	result := false;
	if FNegotiatedSSL then exit;
	if not haveSSL then
	begin
		raise EKTcpClient.Create('SSL�̋@�\�͗��p�ł��܂���B');
	end;
	if not Assigned(Fctx) then
	begin
		method :=SSLv23_client_method();
		if method = nil then
			raise EKTcpClient.Create('SSL�̏�����(method)�Ɏ��s���܂����B');
		Fctx := SSL_CTX_new(method);
		if Fctx = nil then
			raise EKTcpClient.Create('SSL�̏�����(ctx)�Ɏ��s���܂����B');
	end;
	if  not Assigned(Fssl) then
	begin
		Fssl := SSL_new(Fctx);
		if Fssl = nil then
			raise EKTcpClient.Create('SSL�̏�����(ssl)�Ɏ��s���܂����B');
		if SSL_set_fd(Fssl, FSocket) = 0 then
			raise EKTcpClient.Create('SSL�̏�����(setfd)�Ɏ��s���܂����B');
	end;
	ret := SSL_connect(Fssl);
	if ret < 1 then
	begin
		FErrCode :=  SSL_get_error(Fssl,ret);
		FErrMsg := GetOpenSSLErrorMsg(FErrCode);
		if FErrCode = SSL_ERROR_SYSCALL then
		begin
			ret := WSAGetLastError;
			FErrMsg := FErrMsg + ':'+GetSockErrorMsg(ret);
		end;
		raise EKTcpClient.Create('SSL���J�n�ł��܂���:' + FErrMsg);
	end;
	FNegotiatedSSL := true;
	result := true;
end;

function TKTcpClient.ShutdownSSL: boolean;
var
	ret : Integer;
begin
	result := false;
	if not FNegotiatedSSL then exit;
	ret := SSL_shutdown(Fssl);
	FNegotiatedSSL := false;
	if ret < 0 then
	begin
		FErrCode :=  SSL_get_error(Fssl,ret);
		FErrMsg := GetOpenSSLErrorMsg(FErrCode);
		if FErrCode = SSL_ERROR_SYSCALL then
		begin
			ret := WSAGetLastError;
			FErrMsg := FErrMsg + ':'+GetSockErrorMsg(ret);
		end;
		raise EKTcpClient.Create('SSL�̏I�����ɃG���[:' + FErrMsg);
	end;
	result := true;
end;


function TKTcpClient.recv: string;
var
  buf: string;
  cnt: Integer;
begin
  Result := '';

  // ��M
  while True do
  begin
    // ��M�o�b�t�@���m��
    SetLength(buf, FBufSize);
    ZeroMemory(@buf[1], Length(buf));

    // ��M����
    if FNegotiatedSSL then
    begin
      cnt := SSL_read(Fssl,buf[1],Length(buf)-1);
      if cnt = 0 then
      begin
        ShutdownSSL;
      end else
      if cnt < 0 then
      begin
        FErrCode :=  SSL_get_error(Fssl,cnt);
        FErrMsg := GetOpenSSLErrorMsg(FErrCode);
        if FErrCode = SSL_ERROR_SYSCALL then
        begin
          cnt := WSAGetLastError;
          FErrMsg := FErrMsg + ':'+GetSockErrorMsg(cnt);
        end;
        raise EKTcpClient.Create('SSL��M�G���[:' + FErrMsg);
      end;
    end else begin
      cnt := WinSock.recv(FSocket, buf[1], Length(buf)-1, 0);

      // ��������M�ł������`�F�b�N
      if cnt = SOCKET_ERROR then
      begin
        cnt := WSAGetLastError;
        raise EKTcpClient.Create('��M�G���[:'+GetSockErrorMsg(cnt));
      end;
    end;
    if cnt = 0 then Break;

    // �o�b�t�@�𒲐�
    SetLength(buf, cnt);

    // ��M���ʂ𓾂�
    Result := Result + buf;

    // �S����M�����甲����
    if cnt < FBufSize then Break;

  end;
  if Assigned(FOnLog) then FOnLog('<Recv>' + Result);
end;

function TKTcpClient.RecvData(count: Integer): string;
var
  cnt: Integer;
begin
  Result := '';
  //
  while True do
  begin
    if FReadBuffer <> '' then
    begin
      cnt := Length(FReadBuffer);
      if cnt >= count then
      begin
        Result := Result + Copy(FReadBuffer,1,count);
        System.Delete(FReadBuffer,1,count);
        Break;
      end else
      begin
        Result := Result + FReadBuffer;
        FReadBuffer := '';
        Dec(count, cnt);
      end;
    end;
    FReadBuffer := Self.recv;
  end;
end;

function TKTcpClient.RecvDataToEnd: string;
var
  fds:TFDSet;
  time:TTimeVal;
  res : Integer;
begin
  Result := '';
  time.tv_sec := 1;
  time.tv_usec := 0;
  //
  while True do
  begin
    if FReadBuffer <> '' then
    begin
      Result := Result + FReadBuffer;
      FReadBuffer := '';
    end
    else
    begin
      if FNegotiatedSSL then
      begin
        if SSL_pending(Fssl) = 0 then
        begin
          FD_ZERO(fds);
          FD_SET(FSocket, fds);
          res := select(0,@fds,nil,nil,@time);
          if res <= 0 then
          begin
            break;
          end;
        end;
      end else begin
        FD_ZERO(fds);
        FD_SET(FSocket, fds);
        res := select(0,@fds,nil,nil,@time);
        if res <= 0 then
        begin
          break;
        end;
      end;
    end;
    FReadBuffer := Self.recv;
    // �󃊃^�[���̓R�l�N�V�����f�̂͂�
    if FReadBuffer = '' then
      break;
  end;
end;

function TKTcpClient.RecvLn(eol: string = #13#10): string;
var
  i: Integer;
  s: string;
  start_time: DWORD;
begin
  Result := '';

  start_time := timeGetTime;
  while True do
  begin
    // Timeout ���邩�H
    if FTimeout > 0 then
    begin
      if Integer(timeGetTime - start_time) > FTimeout then
      begin
        raise EKTcpClient.Create('�^�C���A�E�g���܂����B');
      end;
    end;
    // ����[#13,#10]���܂ޕ����񂪂���΂�������؂�o��
    i := Pos(eol, FReadBuffer);
    if i > 0 then
    begin
      // ���ʂ�؂���
      Result := Copy(FReadBuffer, 1, i - 1);
      System.Delete(FReadBuffer, 1, i - 1);

      // ���s�������폜���Ĕ�����
      s := Copy(FReadBuffer, 1, 2);
      if s = eol then
      begin
        System.Delete(FReadBuffer, 1, 2);
        Break;
      end;
    end;
    // ���������񂪂Ȃ���Βǉ��œǂ�
    FReadBuffer := FReadBuffer + recv;
  end;
end;

function TKTcpClient.RecvLnToDot(eol: string = #13#10): string;
var
  line: string;
begin
  Result := '';
  while True do
  begin
    line := RecvLn(eol);
    if line = '.' then Break;
    Result := Result + line + #13#10;
  end;
end;

procedure TKTcpClient.send(s: string);
const BUFFSIZE = 2048;
var
  err: Integer;
  tmp, buf: string;
  total, cnt: Integer;
  FlagCancel: Boolean;
  ret: integer;
begin
  if s = '' then Exit;
  tmp := s;
  total := Length(s);
  cnt   := 0;

  // ���M����
  if Assigned(FOnProgress) then FOnProgress(0, '���M�J�n', FlagCancel);
  while s <> '' do
  begin
    if Assigned(FOnProgress) then
    begin
      FOnProgress(Trunc(cnt/total*100), '���M��', FlagCancel);
      if FlagCancel then raise EKTcpClient.Create('���[�U�[�ɂ�蒆�f����܂����B');
    end;
    // buf��؂���
    buf := Copy(s, 1, BUFFSIZE);
    // �؂����������폜
    System.Delete(s, 1, BUFFSIZE);
    // ���M
    if FNegotiatedSSL then
    begin
      ret := SSL_write(Fssl, buf[1], Length(buf));
      if ret < 0 then
      begin
        FErrCode :=  SSL_get_error(Fssl,ret);
        FErrMsg := GetOpenSSLErrorMsg(FErrCode);
        if FErrCode = SSL_ERROR_SYSCALL then
        begin
          ret := WSAGetLastError;
          FErrMsg := FErrMsg + ':'+GetSockErrorMsg(ret);
        end;
        raise EKTcpClient.Create('SSL���M�G���[:' + FErrMsg);
      end;
    end else begin
      if WinSock.send(FSocket, buf[1], Length(buf), 0) = SOCKET_ERROR then
      begin
        err := WSAGetLastError;
        raise EKTcpClient.Create('���M�G���[:'+IntToStr(err));
      end;
    end;
    // ���M���������J�E���g����
    cnt := cnt + Length(buf);
  end;
  // ���M����
  if Assigned(FOnProgress) then FOnProgress(100, '���M����', FlagCancel);
  if Assigned(FOnLog) then FOnLog('<Send>' + tmp);
end;

procedure TKTcpClient.SendLn(cmd, eol: string);
begin
  Self.send(cmd + eol);
end;
{
function TKTcpClient.WSCheck(v: Integer; msg: string): Integer;
begin
  if v = SOCKET_ERROR then
  begin
    FErrCode := WSAGetLastError;
    FErrMsg  := msg + GetSockErrorMsg(FErrCode);
    if Assigned(FOnError) then FOnError(Self);
  end;
  Result := v;
end;
}


initialization
  // WinSock ������
  if (0 <> WSAStartup(MakeWord(2,0), WSAData)) then
  begin
    WSAStartup(MakeWord(1,1), WSAData);
  end;

finalization
  // WinSock �I������
  WSACleanup;

end.

