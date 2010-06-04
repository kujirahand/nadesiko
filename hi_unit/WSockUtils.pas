unit WSockUtils;

interface
uses
  SysUtils, Classes, Windows, WinSock, messages, mmsystem;

type
  TKTcpProgressEvent = procedure (PerDone: Integer; msg: string;
      var Cancel: Boolean) of Object;
  TKTcpLog = procedure (msg: string) of Object;

  //----------------------------------------------------------------------------
  // TCPClient
  EKTcpClient = class(Exception);
  TKTcpClient = class(TComponent)
  private
    // 外部情報
    FConnected: Boolean;
    FPort: Integer;
    FHost: string;
    FErrCode: Integer;
    FErrMsg: string;
    // 内部で使う変数
    FSocket: TSocket;
    FOnError: TNotifyEvent;
    FOnProgress: TKTcpProgressEvent;
    FBufSize: Integer;
    FReadBuffer: string;
    FTimeout: Integer;
    FOnLog: TKTcpLog;
    function GetSelfIP: string;
    //function WSCheck(v: Integer; msg: string): Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Open; virtual;  // サーバーと接続
    procedure Close; virtual; // サーバーと切断
    // 原始的なメソッド
    procedure send(s: string);
    function recv: string;
    // バッファ管理するメソッド
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


// サーバー名からIPアドレスを取得する
function GetIpAddressStr(server: string): string;
// IPアドレスからサーバー名からIPアドレスを取得する
function GetHostNameByAddr(ip: string): string;
// サーバー名からホスト情報を取得する
function GetHostEnt(server: string): PHostEnt;
// コンピューター名を取得
function GetComputerName: string;
// WinSock のエラーを得る
function GetSockErrorMsg(err: Integer): string;

var
  WSAData: TWSAData;

implementation

const
  WM_WSOCK_UTILS_STR = 'com.nadesi.wsockutils';
var
  WM_WSOCK_UTILS: DWORD = 0;

// コンピューター名を取得
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
    WSAETIMEDOUT:        Result := '[10060] 接続タイムアウト。接続先からの応答が長時間届きません。(Connection timed out)';
    WSAECONNREFUSED:     Result := '[10061] 接続が拒絶されました。接続先PCのポートが開いてない可能性があります。(Connection refused)';
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
    else                 Result := '[' + IntToStr(err) + '] エラー';
  end;
end;


// サーバー名からIPアドレスを取得する
function GetIpAddressStr(server: string): string;
var
  phe: PHostEnt;
begin
  phe := GetHostEnt(server);
  if phe = nil then
  begin
    Result := ''; // 失敗
  end else
  begin
    // in_addr型から、xxx.xxx.xxx.xxx の文字列に変換する
    Result := inet_ntoa(PInAddr(phe.h_addr_list^)^);
  end;
end;

// IPアドレスからサーバー名からIPアドレスを取得する
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
    Result := ''; // 失敗
  end else
  begin
    // in_addr型から、xxx.xxx.xxx.xxx の文字列に変換する
    Result := phe.h_name;
  end;
end;


function GetHostEnt(server: string): PHostEnt;
var
  addr: u_long;
  phe: PHostEnt;
begin
  // サーバー名からIPアドレスを得る
  phe := gethostbyname(PAnsiChar(server));
  if phe = nil then
  begin
    // IPアドレスの指定があったか？
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
  if FSocket <> INVALID_SOCKET then
  begin
    shutdown(FSocket, SD_BOTH);
    closesocket(FSocket);
    FConnected := False;
  end;
end;


constructor TKTcpClient.Create(AOwner: TComponent);
begin
  inherited;
  FConnected := False;
  FHost := '';
  FPort := 80; // 適当に初期化
  FSocket := INVALID_SOCKET;
  FBufSize := 8 * 1024;
  FReadBuffer := '';
  FTimeout := 3000;
end;

destructor TKTcpClient.Destroy;
begin
  Close;
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

  // ホスト情報を得る
  phe := GetHostEnt(Host);
  if phe = nil then raise EKTcpClient.Create(Host + 'は存在しません。');

  // ソケットを作る
  FSocket := socket(PF_INET, SOCK_STREAM, 0);
  if(FSocket = INVALID_SOCKET)then
    raise EKTcpClient.Create('ソケットを作成できませんでした。');

  // 接続先アドレスを設定
  ZeroMemory(@sockadd, Sizeof(sockadd));
  sockadd.sin_family := AF_INET;
  sockadd.sin_port   := htons(FPort);
  sockadd.sin_addr   := PInAddr(phe.h_addr_list^)^;

  // 接続
  if WinSock.connect(FSocket, sockadd, sizeof(sockadd)) = SOCKET_ERROR then
  begin
    // 接続失敗
    FErrCode := WSAGetLastError;
    FErrMsg  := GetSockErrorMsg(FErrCode);
    raise EKTcpClient.Create('ホストと接続できません。' + FErrMsg);
    Exit;
  end;
  FConnected := True;
end;

function TKTcpClient.recv: string;
var
  buf: string;
  cnt: Integer;
begin
  Result := '';

  // 受信
  while True do
  begin
    // 受信バッファを確保
    SetLength(buf, FBufSize);
    ZeroMemory(@buf[1], Length(buf));

    // 受信処理
    cnt := WinSock.recv(FSocket, buf[1], Length(buf)-1, 0);

    // 正しく受信できたかチェック
    if cnt = SOCKET_ERROR then
    begin
      cnt := WSAGetLastError;
      raise EKTcpClient.Create('受信エラー:'+GetSockErrorMsg(cnt));
    end;
    if cnt = 0 then Break;

    // バッファを調節
    SetLength(buf, cnt);

    // 受信結果を得る
    Result := Result + buf;

    // 全部受信したら抜ける
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
      res := select(Self.FSocket,@fds,nil,nil,@time);
      if res <= 0 then
      begin
        break;
      end;
    end;
    FReadBuffer := Self.recv;
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
    // Timeout するか？
    if FTimeout > 0 then
    begin
      if Integer(timeGetTime - start_time) > FTimeout then
      begin
        raise EKTcpClient.Create('タイムアウトしました。');
      end;
    end;
    // 既に[#13,#10]を含む文字列があればそこから切り出す
    i := Pos(eol, FReadBuffer);
    if i > 0 then
    begin
      // 結果を切り取る
      Result := Copy(FReadBuffer, 1, i - 1);
      System.Delete(FReadBuffer, 1, i - 1);

      // 改行文字を削除して抜ける
      s := Copy(FReadBuffer, 1, 2);
      if s = eol then
      begin
        System.Delete(FReadBuffer, 1, 2);
        Break;
      end;
    end;
    // もし文字列がなければ追加で読む
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
begin
  if s = '' then Exit;
  tmp := s;
  total := Length(s);
  cnt   := 0;

  // 送信処理
  if Assigned(FOnProgress) then FOnProgress(0, '送信開始', FlagCancel);
  while s <> '' do
  begin
    if Assigned(FOnProgress) then
    begin
      FOnProgress(Trunc(cnt/total*100), '送信中', FlagCancel);
      if FlagCancel then raise EKTcpClient.Create('ユーザーにより中断されました。');
    end;
    // bufを切り取る
    buf := Copy(s, 1, BUFFSIZE);
    // 切り取った分を削除
    System.Delete(s, 1, BUFFSIZE);
    // 送信
    if WinSock.send(FSocket, buf[1], Length(buf), 0) = SOCKET_ERROR then
    begin
      err := WSAGetLastError;
      raise EKTcpClient.Create('送信エラー:'+IntToStr(err));
    end;
    // 送信した分をカウントする
    cnt := cnt + Length(buf);
  end;
  // 送信完了
  if Assigned(FOnProgress) then FOnProgress(100, '送信完了', FlagCancel);
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
  // WinSock 初期化
  if (0 <> WSAStartup(MakeWord(2,0), WSAData)) then
  begin
    WSAStartup(MakeWord(1,1), WSAData);
  end;

finalization
  // WinSock 終了処理
  WSACleanup;

end.

