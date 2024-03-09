unit UdpUnit;

interface

uses
  Windows, WinSock, Messages, SysUtils, Classes;

type
  TIpMreq = packed record
    imr_multiaddr: TInAddr ; // IP multicast address of group
    imr_interface: TInAddr ; // local IP address of interface
  end;

  // �C�x���g�ʒm�p
  TKUdpSocketDataEvent = procedure(Sender: TObject; pData: PChar; len: Integer) of object;

  //
  EKUdpSocket = class(Exception);
  TKUdpSocket = class(TComponent)
  private
    WM_KUDP_SOCKET  : Integer;        // ��M�p�̃��b�Z�[�W�ԍ�(RegisterWindowMessage�Ŏ擾����)
    FRecvHandle     : THandle;        // �p�P�b�g��M�p�̃n���h��
    // �ڑ��Ǘ�
    FSocketHandle   : TSocket;
    FSockAddr       : TSockAddr ;     // Local Addr  ��M�p
    FRemoteAddr     : TSockAddr ;     // Remote Addr ���M�p
    // �O���Ƃ̑Θb�p�̐ڑ��Ǘ�
    FHost           : string;         // �ڑ���
    FPortNo         : Integer;
    FOwnHost        : string;         // ����Host
    FOwnPortNo      : Integer;
    // �C�x���g�p
    FOnRecieve      : TKUdpSocketDataEvent;
    FOnSendReady    : TNotifyEvent;
  protected
    procedure WndProc(var Message: TMessage);
    procedure CheckError(Result: Integer; ErrorMsg: string);
  public
    ErrCode: Integer;
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Open;         // UDP�|�[�g���J�� ��M�I�����[�̏ꍇ�́AHost ���w�肵�Ȃ��Ă� Port �����ŗǂ�
    procedure Close;        // UDP�|�[�g�����
    procedure AddMultiCast; // UDP�}���`�L���X�g�����o�[�ɎQ������
                            // �}���`�L���X�g����M�̂��߂ɂ͕K�{ ���̂Ƃ��AHOST �́A�Ⴆ�� '225.0.0.0';
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
  WSAData: TWSAData ; // WinSock �������p�ϐ�

const
  WM_KUDP_SOCKET_STR = 'com.nadesi.TKUdpSocket.Socket';


{ TKUdpSocket }

procedure TKUdpSocket.AddMultiCast;
var
  Mreq: TIpMreq;
begin
  // Open ����Ă��邩�`�F�b�N
  if FSocketHandle = INVALID_SOCKET then
  begin
    raise EKUdpSocket.Create('�\�P�b�g���I�[�v������Ă��܂���B');
  end;

  // �}���`�L���X�g�@�����o�[�ɒǉ�
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
  FRecvHandle := AllocateHWnd(WndProc); // �p�P�b�g��M�p�̃n���h���𐶐�
  WM_KUDP_SOCKET := RegisterWindowMessage(WM_KUDP_SOCKET_STR);// ��M���b�Z�[�W��ID���擾

  // �ϐ��̏�����
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
  // �\�P�b�g�̍쐬
  FSocketHandle := socket(AF_INET, SOCK_DGRAM, 0);
  if FSocketHandle = INVALID_SOCKET then
  begin
    ErrCode := WSAGetLastError ;
    raise EKUdpSocket.Create('�\�P�b�g�̍쐬�Ɏ��s #'+IntToStr(ErrCode));
  end;

  // �|�[�g�̐ݒ�
  FSockAddr.sin_port         := htons(FOwnPortNo);
  FSockAddr.sin_family       := AF_INET;
  if FOwnHost = '' then
  begin
    FSockAddr.sin_addr.S_addr  := INADDR_ANY;
  end else begin
    FsockAddr.sin_addr.S_addr  := inet_addr(PAnsiChar(FOwnHost));
  end;
  FillChar(FSockAddr.sin_zero, SizeOf(FSockAddr.sin_zero), 0); //���Ԃ𖄂߂�
  CheckError(
    bind(FSocketHandle, FSockAddr, SizeOf(FSockAddr)), 'bind');

  // �����A�h���X�̐ݒ�
  if FHost <> '' then
  begin
    FRemoteAddr.sin_port         := htons(FPortNo);
    FRemoteAddr.sin_family       := AF_INET;
    FRemoteAddr.sin_addr.S_addr  := inet_addr(PAnsiChar(FHost));
    FillChar(FRemoteAddr.sin_zero, SizeOf(FRemoteAddr.sin_zero), 0); //���Ԃ𖄂߂�
  end;
  
  // �\�P�b�g�C�x���g��ʒm������悤�ɐݒ�
  if (WSAAsyncSelect(FSocketHandle, FRecvHandle, WM_KUDP_SOCKET,
    //FD_CONNECT or FD_WRITE or FD_READ or FD_CLOSE or FD_ACCEPT ) = SOCKET_ERROR) then
    FD_WRITE or FD_READ) = SOCKET_ERROR) then
  begin
    CloseSocket(FSocketHandle);
    raise EKUdpSocket.Create('�\�P�b�g�C�x���g��ʒm������ݒ�Ɏ��s');
  end;

end;

function TKUdpSocket.Send(var Buf; Size: Integer): Integer;
begin
  Result := sendto(FSocketHandle, Buf, Size, 0, FRemoteAddr, SizeOf(FRemoteAddr));
end;

procedure TKUdpSocket.WndProc(var Message: TMessage);

  procedure RecvPacket; // �p�P�b�g�̎�M
  var
    cnt: Integer;
    svrAddr: TSockAddrIn;
    len: Integer;
    RecvBuf: string;
  begin
    // �T�[�o�[�̓��e������
    FillChar(svrAddr.sin_zero, sizeof(svrAddr.sin_zero), 0);
    len := SizeOf(svrAddr);

    // ��M�p�o�b�t�@�̊m��
    SetLength(RecvBuf, 32 * 1024{KB}); // �������ɔ����đ傫�߂ɂƂ�

    // ��M
    cnt := recvfrom(FSocketHandle, RecvBuf[1], Length(RecvBuf)-1, 0, svrAddr, len);

    // �I�[�i�[�ɒʒm
    if(cnt = SOCKET_ERROR)then
    begin
      ErrCode := WSAGetLastError ;
      Exit;
    end else
    begin
      // ��M�ɐ����I ... �C�x���g�Ɏ�M�f�[�^��n��
      if Assigned(FOnRecieve) then
      begin
        FOnRecieve(Self, @RecvBuf[1], cnt);
      end;
    end;
  end;

begin
  //
  if(WSAGETSELECTERROR(Message.LParam) <> 0)then //�G���[�̏ꍇ
  begin
    //raise EKUdpSocket.Create('�\�P�b�g�C�x���g�̒ʒm�ŃG���[');
    Exit;
  end;
  //
  case Message.LParamLo of
  FD_WRITE:
    begin
      // �p�ӂ�����
      if Assigned(FOnSendReady) then FOnSendReady(Self);
    end;
  FD_READ:
    begin
      // ��M
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
