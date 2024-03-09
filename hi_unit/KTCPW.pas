unit KTCPW;

interface

uses
  SysUtils, Classes, winsock, KTcp, UdpUnit, dnako_import, dnako_import_types,
  dll_plugin_helper;

type
  TNakoTcpClient = class(TKTcpClient)
  private
    procedure setEvent;
    procedure TcpDoConnect(Sender: TObject);
    procedure TcpDoDisconnect(Sender: TObject);
    procedure TcpDoRcvReady(Sender: TObject);
    procedure TcpDoError(Sender: TObject; E: TKError);
    procedure DoEvent(EventName: string);
  public
    InstanceName: string;
    tcpid: Integer;
    constructor Create(AOwner: TComponent); override;
  end;

  TNakoTcpServer = class(TKTcpServer)
  private
    procedure setEvent;
    procedure TcpDoConnect(Sender: TObject; Target:TKTcpChildSock);
    procedure TcpDoDisconnect(Sender: TObject; Target:TKTcpChildSock);
    procedure TcpDoRcvReady(Sender: TObject; Target:TKTcpChildSock);
    procedure TcpDoError(Sender: TObject; E: TKError);
    procedure DoEvent(EventName: string);
    procedure TcpSendEmpty(Sender: TObject; Target:TKTcpChildSock);
  public
    InstanceName: string;
    tcpid: Integer;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function  handle2ip(handle: THandle): string;
    procedure SendToData(targetip, data: string);
    function  getChildFromIP(ip: string): TKTcpChildSock;
    procedure CloseFromIp(ip: string);
    function  getClientList: string;
  end;

  TNakoUdp = class(TKUdpSocket)
  private
    procedure RecvData(Sender: TObject; pData: PChar; len: Integer);
    procedure SendReady(Sender: TObject);
  public
    InstanceName: string;
    udpid: Integer;
    procedure setEvent;
    constructor Create(AOwner: TComponent); override;
    procedure DoEvent(EventName: string);
  end;

implementation

uses WSockUtils;

{ TNakoTcpClient }

procedure TNakoTcpClient.TcpDoConnect(Sender: TObject);
begin
  DoEvent('接続した時');
end;

procedure TNakoTcpClient.TcpDoDisconnect(Sender: TObject);
begin
  DoEvent('切断した時');
end;

procedure TNakoTcpClient.TcpDoError(Sender: TObject; E: TKError);
var
  p: PHiValue;
begin
  p := nako_getGroupMember(PAnsiChar(InstanceName),PAnsiChar('エラーメッセージ'));
  if p <> nil then nako_str2var(PAnsiChar(E.Message),p);

  DoEvent('エラー時');
end;

procedure TNakoTcpClient.DoEvent(EventName: string);
var
  p: PHiValue;
  s: string;
begin
  // イベントの実行
  {
  p := nako_group_findMember(InstanceVar, PChar(EventName));
  if p = nil then Exit;
  if p.VType = varNil then Exit;
  nako_group_exec(InstanceVar, PChar(EventName));
  }

  s := Self.InstanceName + 'の' + EventName + ';';
  p := nako_eval(PAnsiChar(s));
  if p <> nil then nako_var_free(p);
end;

procedure TNakoTcpClient.TcpDoRcvReady(Sender: TObject);
begin
  //
  DoEvent('受信した時');
end;

procedure TNakoTcpClient.setEvent;
begin
  Self.OnConnect     := TcpDoConnect;
  Self.OnRcvReady    := TcpDoRcvReady;
  Self.OnError       := TcpDoError;
  Self.OnDisconnect  := TcpDoDisconnect;
end;

constructor TNakoTcpClient.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  setEvent;
end;

{ TNakoTcpServer }

procedure TNakoTcpServer.CloseFromIp(ip: string);
var
  p: TKTcpChildSock;
begin
  p := getChildFromIP(ip);
  if p <> nil then p.Close;
end;

constructor TNakoTcpServer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  setEvent;
end;

destructor TNakoTcpServer.Destroy;
begin
  inherited;
end;

procedure TNakoTcpServer.DoEvent(EventName: string);
var
  p: PHiValue;
  s: string;
begin
  // イベントの実行
  s := Self.InstanceName + 'の' + EventName + ';';
  nako_evalEx(PAnsiChar(s), p);
  if p <> nil then nako_var_free(p);
end;

function TNakoTcpServer.getChildFromIP(ip: string): TKTcpChildSock;
var
  i: Integer;
  v: TKTcpChildSock;
begin
  ip := Trim(ip);
  Result := nil;
  for i := 0 to Self.ChildCount - 1 do
  begin
    v := Self.ChildSock[i];
    if v = nil then Continue;
    if v.IpStr = ip then
    begin
      Result := v;
      Break;
    end;
  end;
end;

function TNakoTcpServer.getClientList: string;
var
  i: Integer;
  p: TKTcpChildSock;
begin
  Result := '';
  for i := 0 to Self.ChildCount - 1 do
  begin
    p := Self.ChildSock[i];
    Result := Result + p.IpStr + #13#10;
  end;
end;

function TNakoTcpServer.handle2ip(handle: THandle): string;
var
  name: TSockAddr;
  len: Integer;
begin
  len := SizeOf(name);
  getpeername(handle, name, len);
  Result := inet_ntoa(name.sin_addr);
end;

procedure TNakoTcpServer.SendToData(targetip, data: string);
var
  cs: TKTcpChildSock;
  i: Integer;
begin
  //
  for i := 0 to GetChildCount - 1 do
  begin
    cs := ChildSock[i];
    if (cs.IpStr = targetip)or(targetip = 'all') then
    begin
      cs.SendString(data);
    end;
  end;
end;

procedure TNakoTcpServer.setEvent;
begin
  Self.OnConnect     := TcpDoConnect;
  Self.OnRcvReady    := TcpDoRcvReady;
  Self.OnError       := TcpDoError;
  Self.OnDisconnect  := TcpDoDisconnect;
  Self.OnSendEmpty   := TcpSendEmpty;
end;

procedure TNakoTcpServer.TcpDoConnect(Sender: TObject;
  Target: TKTcpChildSock);
var
  p: PHiValue;
  ip: string;
begin
  // 接続してきた相手のIPをセット
  ip := handle2ip(Target.Handle);
  Target.IpStr := ip;

  p := nako_getGroupMember(PAnsiChar(InstanceName),PAnsiChar('相手IP'));
  if p <> nil then nako_str2var(PAnsiChar(ip),p);

  DoEvent('接続した時');
end;

procedure TNakoTcpServer.TcpDoDisconnect(Sender: TObject;
  Target: TKTcpChildSock);
var
  p: PHiValue;
  ip: string;
begin
  // 相手のIPをセット
  ip := handle2ip(Target.Handle);
  p := nako_getGroupMember(PAnsiChar(InstanceName),PAnsiChar('相手IP'));
  if p <> nil then nako_str2var(PAnsiChar(ip),p);

  DoEvent('切断した時');
end;

procedure TNakoTcpServer.TcpDoError(Sender: TObject; E: TKError);
var
  p: PHiValue;
begin
  p := nako_getGroupMember(PAnsiChar(InstanceName),PAnsiChar('エラーメッセージ'));
  if p <> nil then nako_str2var(PAnsiChar(E.Message),p);

  DoEvent('エラー時');
end;

procedure TNakoTcpServer.TcpDoRcvReady(Sender: TObject;
  Target: TKTcpChildSock);
var
  p: PHiValue;
  s, ip: string;
begin
  // 相手のIPをセット
  ip := handle2ip(Target.Handle);
  p := nako_getGroupMember(PAnsiChar(InstanceName),PAnsiChar('相手IP'));
  if p <> nil then nako_str2var(PAnsiChar(ip),p);
  // 受信データをセット
  s := Target.RecvString;
  p := nako_getGroupMember(PAnsiChar(InstanceName),PAnsiChar('受信データ'));
  if p <> nil then nako_bin2var(PAnsiChar(s),Length(s),p);
  //
  DoEvent('受信した時');
end;

procedure TNakoTcpServer.TcpSendEmpty(Sender: TObject; Target:TKTcpChildSock);
var
  ip: string;
  p: PHiValue;
begin
  // 相手のIPをセット
  ip := handle2ip(Target.Handle);
  p := nako_getGroupMember(PAnsiChar(InstanceName),PAnsiChar('相手IP'));
  if p <> nil then nako_str2var(PAnsiChar(ip),p);

  DoEvent('送信完了した時');
end;

{ TNakoUdp }

constructor TNakoUdp.Create(AOwner: TComponent);
begin
  inherited;
  setEvent;
end;

procedure TNakoUdp.DoEvent(EventName: string);
var
  p: PHiValue;
  s: string;
begin
  s := Self.InstanceName + 'の' + EventName + ';';
  nako_evalEx(PAnsiChar(s), p);
  if p <> nil then nako_var_free(p);
end;

procedure TNakoUdp.RecvData(Sender: TObject; pData: PChar; len: Integer);
var
  p: PHiValue;
  s: string;
begin
  if len <= 0 then Exit;
  SetLength(s, len);
  Move(pData^, s[1], len);

  p := nako_getGroupMember(PAnsiChar(InstanceName),PAnsiChar('受信データ'));
  if p <> nil then nako_bin2var(PAnsiChar(s),len,p);

  DoEvent('受信した時');
end;

procedure TNakoUdp.SendReady(Sender: TObject);
begin
  DoEvent('接続した時');
end;

procedure TNakoUdp.setEvent;
begin
  Self.OnRecieve := RecvData;
  Self.OnSendReady := SendReady;
end;

end.
