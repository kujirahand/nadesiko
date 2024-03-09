unit UdpUnit;

interface

uses
  Windows, WinSock, Messages, SysUtils, Classes;

type
  TIpMreq = packed record
    imr_multiaddr: TInAddr ; // IP multicast address of group
    imr_interface: TInAddr ; // local IP address of interface
  end;

  // イベント通知用
  TKUdpSocketDataEvent = procedure(Sender: TObject; pData: PChar; len: Integer) of object;

  //
  EKUdpSocket = class(Exception);
  TKUdpSocket = class(TComponent)
  private
    WM_KUDP_SOCKET  : Integer;        // 受信用のメッセージ番号(RegisterWindowMessageで取得する)
    FRecvHandle     : THandle;        // パケット受信用のハンドル
    // 接続管理
    FSocketHandle   : TSocket;
    FSockAddr       : TSockAddr ;     // Local Addr  受信用
    FRemoteAddr     : TSockAddr ;     // Remote Addr 送信用
    // 外部との対話用の接続管理
    FHost           : string;         // 接続先
    FPortNo         : Integer;
    FOwnHost        : string;         // 自側Host
    FOwnPortNo      : Integer;
    // イベント用
    FOnRecieve      : TKUdpSocketDataEvent;
    FOnSendReady    : TNotifyEvent;
  protected
    procedure WndProc(var Message: TMessage);
    procedure CheckError(Result: Integer; ErrorMsg: string);
  public
    ErrCode: Integer;
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Open;         // UDPポートを開く 受信オンリーの場合は、Host を指定しなくても Port だけで良い
    procedure Close;        // UDPポートを閉じる
    procedure AddMultiCast; // UDPマルチキャストメンバーに参加する
                            // マルチキャスト送受信のためには必須 このとき、HOST は、例えば '225.0.0.0';
    function Send(var Buf; Size: Integer): Integer;
    property OnSendReady      : TNotifyEvent read FOnSendReady write FOnSendReady;
    property OnRecieve      : TKUdpSocketDataEvent read FOnRecieve write FOnRecieve;
    property Host: string read FHost write FHost;
    property PortNo: Integer read FPortNo write FPortNo;
    property OwnHost: string read FOwnHost write FOwnHost;
    property OwnPortNo: Integer read FOwnPortNo write FOwnPortNo;
  end;

implementation

var
  WSAData: TWSAData ; // WinSock 初期化用変数

const
  WM_KUDP_SOCKET_STR = 'com.nadesi.TKUdpSocket.Socket';


{ TKUdpSocket }

procedure TKUdpSocket.AddMultiCast;
var
  Mreq: TIpMreq;
begin
  // Open されているかチェック
  if FSocketHandle = INVALID_SOCKET then
  begin
    raise EKUdpSocket.Create('ソケットがオープンされていません。');
  end;

  // マルチキャスト　メンバーに追加
  Mreq.imr_multiaddr.S_addr := inet_addr(PAnsiChar(FHost)) ;
  Mreq.imr_interface.S_addr := INADDR_ANY ;
  CheckError(
    setsockopt(FSocketHandle, IPPROTO_IP, IP_ADD_MEMBERSHIP, @Mreq, sizeof(Mreq)),
    'setsockopt IP_ADD_MEMBERSHIP');
end;

procedure TKUdpSocket.CheckError(Result: Integer; ErrorMsg: string);
begin
  if Result = SOCKET_ERROR then
  begin
    ErrCode := WSAGetLastError ;
    raise EKUdpSocket.Create(ErrorMsg + ' #' + IntToStr(ErrCode));
  end;
end;

procedure TKUdpSocket.Close;
begin
  if FSocketHandle = INVALID_SOCKET then Exit;
  closesocket(FSocketHandle);
end;

constructor TKUdpSocket.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRecvHandle := AllocateHWnd(WndProc); // パケット受信用のハンドルを生成
  WM_KUDP_SOCKET := RegisterWindowMessage(WM_KUDP_SOCKET_STR);// 受信メッセージのIDを取得

  // 変数の初期化
  FSocketHandle := INVALID_SOCKET ;

  ErrCode := 0;
  FOnSendReady := nil;
  FOnRecieve := nil;
end;

destructor TKUdpSocket.Destroy;
begin
  Close;
  DeallocateHWnd(FRecvHandle);
  inherited;
end;

procedure TKUdpSocket.Open;
begin
  // ソケットの作成
  FSocketHandle := socket(AF_INET, SOCK_DGRAM, 0);
  if FSocketHandle = INVALID_SOCKET then
  begin
    ErrCode := WSAGetLastError ;
    raise EKUdpSocket.Create('ソケットの作成に失敗 #'+IntToStr(ErrCode));
  end;

  // ポートの設定
  FSockAddr.sin_port         := htons(FOwnPortNo);
  FSockAddr.sin_family       := AF_INET;
  if FOwnHost = '' then
  begin
    FSockAddr.sin_addr.S_addr  := INADDR_ANY;
  end else begin
    FsockAddr.sin_addr.S_addr  := inet_addr(PAnsiChar(FOwnHost));
  end;
  FillChar(FSockAddr.sin_zero, SizeOf(FSockAddr.sin_zero), 0); //隙間を埋める
  CheckError(
    bind(FSocketHandle, FSockAddr, SizeOf(FSockAddr)), 'bind');

  // 相手先アドレスの設定
  if FHost <> '' then
  begin
    FRemoteAddr.sin_port         := htons(FPortNo);
    FRemoteAddr.sin_family       := AF_INET;
    FRemoteAddr.sin_addr.S_addr  := inet_addr(PAnsiChar(FHost));
    FillChar(FRemoteAddr.sin_zero, SizeOf(FRemoteAddr.sin_zero), 0); //隙間を埋める
  end;
  
  // ソケットイベントを通知させるように設定
  if (WSAAsyncSelect(FSocketHandle, FRecvHandle, WM_KUDP_SOCKET,
    //FD_CONNECT or FD_WRITE or FD_READ or FD_CLOSE or FD_ACCEPT ) = SOCKET_ERROR) then
    FD_WRITE or FD_READ) = SOCKET_ERROR) then
  begin
    CloseSocket(FSocketHandle);
    raise EKUdpSocket.Create('ソケットイベントを通知させる設定に失敗');
  end;

end;

function TKUdpSocket.Send(var Buf; Size: Integer): Integer;
begin
  Result := sendto(FSocketHandle, Buf, Size, 0, FRemoteAddr, SizeOf(FRemoteAddr));
end;

procedure TKUdpSocket.WndProc(var Message: TMessage);

  procedure RecvPacket; // パケットの受信
  var
    cnt: Integer;
    svrAddr: TSockAddrIn;
    len: Integer;
    RecvBuf: string;
  begin
    // サーバーの内容も得る
    FillChar(svrAddr.sin_zero, sizeof(svrAddr.sin_zero), 0);
    len := SizeOf(svrAddr);

    // 受信用バッファの確保
    SetLength(RecvBuf, 32 * 1024{KB}); // もしもに備えて大きめにとる

    // 受信
    cnt := recvfrom(FSocketHandle, RecvBuf[1], Length(RecvBuf)-1, 0, svrAddr, len);

    // オーナーに通知
    if(cnt = SOCKET_ERROR)then
    begin
      ErrCode := WSAGetLastError ;
      Exit;
    end else
    begin
      // 受信に成功！ ... イベントに受信データを渡す
      if Assigned(FOnRecieve) then
      begin
        FOnRecieve(Self, @RecvBuf[1], cnt);
      end;
    end;
  end;

begin
  //
  if(WSAGETSELECTERROR(Message.LParam) <> 0)then //エラーの場合
  begin
    //raise EKUdpSocket.Create('ソケットイベントの通知でエラー');
    Exit;
  end;
  //
  case Message.LParamLo of
  FD_WRITE:
    begin
      // 用意が完了
      if Assigned(FOnSendReady) then FOnSendReady(Self);
    end;
  FD_READ:
    begin
      // 受信
      RecvPacket ;
    end;
  else
    Message.Result:=DefWindowProc(FRecvHandle,Message.Msg,Message.wParam,Message.lParam);
  end;
end;

initialization
  WSAStartup(MAKEWORD(2,0), WSAData);

finalization
  WSACleanup;

end.
