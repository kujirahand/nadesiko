// http://www.asahi-net.or.jp/~nk2w-ishr/ktcp.lzh
// よりダウンロード
{****************************************************************}
{* Winsockを扱うためのコンポーネント				*}
{* TCP非同期のみサポート					*}
{* Delphi2/Delphi3共通版					*}
{*--------------------------------------------------------------*}
{* 97/10/26(日) Kok						*}
{*	Ver 1.00 公開						*}
{* 97/11/02(日) Kok						*}
{*	Ver 1.01 ReserveCloseメソッド追加			*}
{*		 ForceCloseメソッド追加				*}
{* 		 OnRcvEventを設定していない場合はFD_READを	*}
{* 		 設定しないよう修正				*}
{* 99/03/06(土) Kok						*}
{*	Ver 1.02 TKTcpClientにて、サーバを指定した直後に	*}
{* 		Connectするとおかしくなる件を修正		*}
{* 		Delphi4に対応					*}
{* 99/03/29(月) Kok						*}
{*	Ver 1.03 Text受信モード(#13#10)を追加			*}
{* 		Text受信モードでは、#13#10を一区切りとして	*}
{* 		受信する					*}
{* 		受信データ内には#13#10が含まれる		*}
{* 		Text受信モードでは#13#10は常に１回に受信するので*}
{* 		Recvで1Byteだけだと受信できない可能性がある	*}
{* 99/10/06(水) Kok						*}
{*	Ver 1.04 送信バッファの解放漏れがあったので修正		*}
{****************************************************************}
unit	KTcp;
interface
uses	Windows,Winsock,Classes,Messages,mmsystem;

{****************************************************************}
{* 使用するユーザメッセージ					*}
{****************************************************************}
const
	WM_KOK_BASE =		WM_USER+$100;	{ このくらいのところはDelphiが使っていないようだ }
	WM_KOK_ASYNCCMD	=	WM_KOK_BASE+ 1;	{ Asyncレスポンスメッセージ }
	WM_KOK_CHILDFREE=	WM_KOK_BASE+ 2;	{ サーバーに子供を消してもらう為のメッセージ }

{****************************************************************}
{* Winsock情報を開示するコンポーネント				*}
{* このコンポーネントは、published propertyにWinsock初期化時情報*}
{* を表示する機能しかない					*}
{* 必要にはほとんどならないだろうが、表示してみると面白い？	*}
{****************************************************************}
type
TKWinsockInfo=class(TComponent)
private
	function	GetCanUsesWinsock: Boolean;
	function	GetVersion: WORD;
	function	GetHighVersion: WORD;
	function	GetDescription: string;
	function	GetSystemStatus: string;
	function	GetMaxSockes: WORD;
	function	GetMaxUdpDg: WORD;
	function	GetVendorInfo: Pointer;
	function	GetLocalHostName: string;
	procedure	SetBoolean(Newval:Boolean);
	procedure	SetWord(Newval:Word);
	procedure	SetString(Newval:string);
public
	property VendorInfo: Pointer read GetVendorInfo;
published
	property CanUsesWinsock: Boolean read GetCanUsesWinsock write SetBoolean;
	property LocalHostName: string read GetLocalHostName write SetString;
	property Version: WORD read GetVersion write SetWord;
	property HighVersion: WORD read GetHighVersion write SetWord;
	property Description: string read GetDescription write SetString;
	property SystemStatus: string read GetSystemStatus write SetString;
	property MaxSockes: WORD read GetMaxSockes write SetWord;
	property MaxUdpDg: WORD read GetMaxUdpDg write SetWord;
end;

{****************************************************************}
{* エラーを表すオブジェクト					*}
{****************************************************************}
type
TKError=class(TObject)
private
	FCode:	Integer;
	FMsg:	string;
public
	constructor Create(Code_: Integer;Msg: string);
published
	property Message: string read FMsg;
	property Code: Integer read FCode;
end;

type
TKWinSockError=class(TKError)
public
	constructor Create(Code_: Integer);
end;

{****************************************************************}
{* 非同期のデータベース検索コンポーネントの親			*}
{****************************************************************}
type
TKAsyncHostEnt=Record
	Case Integer of
	0:	(buf:		array [0..MAXGETHOSTSTRUCT-1] of BYTE);
	1:	(hostEnt:	THostEnt;);
	2:	(servEnt:	TServEnt;);
end;
TKErrorEvent= procedure (Sender: TObject; E: TKError) of Object;
TKAsyncFinder=class(TComponent)
private
	FOnError:	TKErrorEvent;
protected
	FBuffer:	TKASyncHostEnt;
	FSearching:	Boolean;
	FWnd:		HWnd;
	FTaskHandle:	THandle;

	procedure	WndProc(var Msg:TMessage); virtual;
	procedure	ThrowError(code:Integer); virtual;
	procedure	Find; virtual; abstract;
public
	constructor	Create(AOwner:TComponent); override;
	destructor	Destroy; override;

	procedure	Cancel; virtual;

	property Searching: Boolean read FSearching;
published
	property OnError: TKErrorEvent read FOnError write FOnError;
end;

{****************************************************************}
{* ホスト名からIPアドレスを検索するオブジェクト			*}
{****************************************************************}
type
TKIpFindEvent=procedure (Sender: TObject; ip: TInAddr) of Object;
TKIpFinder=class(TKAsyncFinder)
private
	FOnFind:	TKIpFindEvent;
protected
	FIpAddress:	TInAddr;
	procedure	Find; override;
public
	constructor	Create(AOwner:TComponent); override;

	procedure	Search(hostName:string);
	property IpAddress: TInAddr read FIpAddress;
published
	property OnFind: TKIpFindEvent read FOnFind write FOnFind;
end;

{****************************************************************}
{* ストリーム非同期型のソケット					*}
{****************************************************************}
type
TKStreamSock=class(TComponent)
private
	FHandle:	TSocket;
	FOnError:	TKErrorEvent;
protected
	FWnd:		HWnd;
	procedure	WndProc(var Msg:TMessage); virtual;
	procedure	ThrowError(code:Integer); virtual;
	function	GetHandle: TSocket; virtual;
	procedure	SetHandle(Newval: TSocket); virtual;
public
	constructor	Create(AOwner:TComponent); override;
	destructor	Destroy; override;

	procedure	Close; virtual;
published
	property OnError: TKErrorEvent read FOnError write FOnError;
end;

{****************************************************************}
{* 実際に通信を行うソケット					*}
{****************************************************************}
type
TKTcpRecvMode=(ktrmBinary,ktrmText);
type
TKStreamTranciverSocket=class(TKStreamSock)
private
	FSendBuff:	TList;		{ 送信バッファ }
	FRecvMode:	TKTcpRecvMode;	{ 受信モード }

	FOnSendEmpty:	TNotifyEvent;	{ 送信バッファが空 }
	FOnRcvReady:	TNotifyEvent;	{ 受信データあり }
	FOnDisconnect:	TNotifyEvent;	{ 相手が接続を断った }
  FSendCount: Integer;
protected
	FCloseReserved:	Boolean;	{ クローズ予約が入った }
	FRecvBuf:	string;		{ 受信バッファ }
	procedure	WndProc(var Msg:TMessage); override;
	procedure	WriteReadyEvent(var Msg:TMessage); virtual;
	procedure	ReadReadyEvent(var Msg:TMessage); virtual;
	procedure	DisconnectEvent(var Msg:TMessage); virtual;
	procedure	SetRecvMode(Newval:TKTcpRecvMode);
	function	RecvReal(var data; len: Integer):Integer;
	function	RecvStringReal: string;
public
	constructor	Create(AOwner:TComponent); override;
	destructor	Destroy; override;

	procedure	Send(const data; len: Integer);
	procedure	SendString(str: string);
	function	Recv(var data; len: Integer):Integer;
	function	RecvString: string;
  function  RecvStrByte(len: Integer): string;

	procedure	Close; override;
	procedure	ReserveClose; virtual;
	procedure	ForceClose; virtual;
	property Handle: TSocket read GetHandle;
published
	property RecvMode: TKTcpRecvMode read FRecvMode write SetRecvMode;
	property OnSendEmpty: TNotifyEvent read FOnSendEmpty write FOnSendEmpty;
	property OnRcvReady: TNotifyEvent read FOnRcvReady write FOnRcvReady;
	property OnDisconnect: TNotifyEvent read FOnDisconnect write FOnDisconnect;
end;

{****************************************************************}
{* クライアントソケット						*}
{* 接続を行う方のソケット					*}
{****************************************************************}
type
TKTcpClient=class(TKStreamTRanciverSocket)
private
	FServerName:	string;
	FActive:	Boolean;
	FOnConnect:	TNotifyEvent;
protected
	FServerAddr:	TInAddr;
	FPort:		WORD;
	FIpFinder:	TKIpFinder;
	FConnected:	Boolean;
	procedure	WndProc(var Msg:TMessage); override;
	procedure	ConnectEvent(var Msg:TMessage); virtual;
	procedure	WriteReadyEvent(var Msg:TMessage); override;
	procedure	DisconnectEvent(var Msg:TMessage); override;
	procedure	SetServerName(Newval: string);
	procedure	SetPort(Newval: WORD);
	procedure	SetActive(Newval: Boolean);
	procedure	SetServerAddr(Newval: TInAddr);
	procedure	DoConnect;
	procedure	FindServerAddr(Sender: TObject; addr: TInAddr);
	procedure	DoError(Sender: TObject; E:TKError);
	procedure	Loaded; override;
public
	constructor	Create(AOwner:TComponent); override;
	destructor	Destroy; override;

	procedure	Close; override;
	procedure	Connect;

	property ServerAddr: TInAddr read FServerAddr write SetServerAddr;
published
	property Active: Boolean read FActive write SetActive;
	property ServerName: string read FServerName write SetServerName;
	property Port: WORD read FPort write SetPort;

	property OnConnect: TNotifyEvent read FOnConnect write FOnConnect;
end;

{****************************************************************}
{* サーバーの中でクライアントの相手をするソケット		*}
{****************************************************************}
type
TKTcpChildSock=class(TKStreamTranciverSocket)
private
	FOnDestroy:	TNotifyEvent;
protected
	function	GetIndex:Integer;
	procedure	DisconnectEvent(var Msg:TMessage); override;
public
  IpStr: string; // IPアドレスを保持
	constructor	Create(AOwner:TComponent); override;
	destructor	Destroy; override;
  procedure _SetHandle(h: TSocket); 
	procedure	SetUp;
	procedure	Close; override;
	property Index: Integer read GetIndex;
published
	property OnDestroy: TNotifyEvent read FOnDestroy write FOnDestroy;
end;

{****************************************************************}
{* サーバーソケット						*}
{****************************************************************}
type
TKServerNotifyEvent=procedure (Sender: TObject; Target:TKTcpChildSock) of object;
TKChildErrorEvent=procedure (Sender: TObject; Target:TKTcpChildSock; E:TKError) of object;
TKTcpServer=class(TKStreamSock)
private
	FActive:	Boolean;
	FPort:		WORD;
	FRecvMode:	TKTcpRecvMode;
	FOnConnect:	TKServerNotifyEvent;
	FOnRcvReady:	TKServerNotifyEvent;
	FOnSendEmpty:	TKServerNotifyEvent;
	FOnDisconnect:	TKServerNotifyEvent;
	FOnChildDestroy:	TKServerNotifyEvent;
	FOnChildError:	TKChildErrorEvent;
protected
	function	GetChildSock(idx:Integer): TKTcpChildSock;
	function	GetChildCount: Integer;
	procedure	WndProc(var Msg:TMessage); override;
	procedure	Loaded; override;
	procedure	DoRcvReady(Sender:TObject);
	procedure	DoSendEmpty(Sender:TObject);
	procedure	DoDisconnect(Sender:TObject);
	procedure	DoError(Sender:TObject; E:TKError);
	procedure	DoDestroy(Sender:TObject);
	procedure	SetActive(Newval:Boolean);
	procedure	SetOnRcvReady(Newval:TKServerNotifyEvent);
public
	procedure	Open;
	procedure	Close; override;

	property ChildCount:Integer read GetChildCount;
	property ChildSock[idx:Integer]: TKTcpChildSock read GetChildSock;
	property Wnd: HWnd read FWnd;	{ Child->Server通信用 }
	property Handle:TSocket read GetHandle;
published
	property Active: Boolean read FActive write SetActive;
	property Port: WORD read FPort write FPort;
	property RecvMode: TKTcpRecvMode read FRecvMode write FRecvMode;

	property OnConnect: TKServerNotifyEvent read FOnConnect write FOnConnect;
	property OnRcvReady: TKServerNotifyEvent read FOnRcvReady write SetOnRcvReady;
	property OnSendEmpty: TKServerNotifyEvent read FOnSendEmpty write FOnSendEmpty;
	property OnDisconnect: TKServerNotifyEvent read FOnDisconnect write FOnDisconnect;
	property OnChildDestroy: TKServerNotifyEvent read FOnChildDestroy write FOnChildDestroy;
	property OnChildError: TKChildErrorEvent read FOnChildError write FOnChildError;
end;

procedure Register;

function CanUseWinsock:Boolean;				{ Winsockが使えるか調べる }
function LocalHostName: string;				{ ローカルホスト名を調べる }
function SockErrorString(code: Integer): string;	{ Winsockのエラーコードを文字列で表現する }

implementation

uses	SysUtils;

{****************************************************************}
{* コンポーネント登録						*}
{****************************************************************}
procedure Register;
begin
	RegisterComponents('KokComp', [TKWinsockInfo,TKIpFinder,TKTcpClient,TKTcpServer]);
end;

var
	WSAData:	TWSAData;	{ 初期化状態情報 }
	WSAError:	Boolean;	{ エラー情報 }

{****************************************************************}
{* Winsock情報を開示するコンポーネント				*}
{* 単に初期化したときのデータを表示するだけ			*}
{****************************************************************}
function TKWinsockInfo.GetCanUsesWinsock: Boolean;
begin
	result:=not WSAError;
end;

function TKWinsockInfo.GetLocalHostName: string;
begin
	result:=KTcp.LocalHostName;
	if result='' then result:='(エラー)';
end;

function TKWinsockInfo.GetVersion: WORD;
begin
	result:=WSAData.wVersion;
end;

function TKWinsockInfo.GetHighVersion: WORD;
begin
	result:=WSAData.wHighVersion;
end;

function TKWinsockInfo.GetDescription: string;
begin
	result:=WSAData.szDescription;
end;

function TKWinsockInfo.GetSystemStatus: string;
begin
	result:=WSAData.szSystemStatus;
end;

function TKWinsockInfo.GetMaxSockes: WORD;
begin
	result:=WSAData.iMaxSockets;
end;

function TKWinsockInfo.GetMaxUdpDg: WORD;
begin
	result:=WSAData.iMaxUdpDg;
end;

function TKWinsockInfo.GetVendorInfo: Pointer;
begin
	result:=WSAData.lpVendorInfo;
end;

procedure TKWinsockInfo.SetBoolean(Newval:Boolean);
begin
{	Raise Exception.Create('このコンポーネントのプロパティに代入は出来ません。(^^;;');}
end;

procedure TKWinsockInfo.SetWord(Newval:WORD);
begin
{	Raise Exception.Create('このコンポーネントのプロパティに代入は出来ません。(^^;;');}
end;

procedure TKWinsockInfo.SetString(Newval:string);
begin
{	Raise Exception.Create('このコンポーネントのプロパティに代入は出来ません。(^^;;');}
end;

{****************************************************************}
{* エラーを表すオブジェクト					*}
{****************************************************************}
constructor TKError.Create(Code_:Integer; Msg:string);
begin
	inherited	Create;
	FCode:=Code_;
	FMsg:=Msg;
end;

constructor TKWinSockError.Create(Code_: Integer);
begin
	inherited	Create(Code_,SockErrorString(Code_));
end;

{****************************************************************}
{* 非同期データベース検索コンポーネントの親			*}
{****************************************************************}
constructor TKAsyncFinder.Create(AOwner:TComponent);
begin
	inherited;
	FWnd:=Classes.allocateHWnd(WndProc);
end;

destructor TKASyncFinder.Destroy;
begin
	Cancel;
	Classes.DeallocateHWnd(FWnd);
	inherited;
end;

procedure TKAsyncFinder.ThrowError(Code:Integer);
var
	E:	TKError;
begin
	if assigned(FOnError) then begin
		E:=TKWinsockError.Create(Code);
		Try
			FOnError(Self,E);
		Finally
			E.Free;
		end;
	end;
end;

procedure TKAsyncFinder.Cancel;
var
	th:	THandle;
begin
	if not FSearching then Exit;
	th:=FTaskhandle;
	FTaskHandle:=0;
	FSearching:=FALSE;
	if WSACancelAsyncRequest(th)<>0 then begin
		ThrowError(WSAGetLastError);
	end;
end;

procedure TKASyncFinder.WndProc(var Msg:TMessage);
begin
	if Msg.Msg<>WM_KOK_ASYNCCMD then begin
		Msg.Result:=DefWindowProc(FWnd,Msg.Msg,Msg.wParam,Msg.lParam);
		Exit;
	end;
	if THandle(Msg.wParam)<>FTaskHandle then Exit;	{ キャンセルした後に届いたメッセージなど }
	FSearching:=FALSE;
	if WSAGetASyncError(Msg.lParam)<>0 then begin
		ThrowError(WSAGetASyncError(Msg.lParam));
		Exit;
	end;
	Find;
end;

{****************************************************************}
{* ホスト名からIPアドレスを探すコンポーネント			*}
{****************************************************************}
constructor TKIpFinder.Create(AOwner:TComponent);
begin
	inherited;
	FIpAddress.S_addr:=LongInt(INADDR_NONE);
end;

procedure TKIpFinder.Search(hostName:string);
begin
	Cancel;			{ すでにサーチ中なら止める }
	FSearching:=True;
	FIpAddress.S_addr:=inet_addr(PChar(hostName));
	if FIpAddress.S_addr<>Integer(INADDR_NONE) then begin
		FSearching:=False;
		if assigned(FOnFind) then FOnFind(Self,IpAddress);
	end
	else begin
		FTaskHandle:=WSAAsyncGetHostByName(FWnd,WM_KOK_ASYNCCMD,PChar(hostName),@FBuffer,sizeof(FBuffer));
		if FTaskHandle=0 then begin
			FSearching:=False;
			ThrowError(WSAGetLastError);
		end;
	end;
end;

procedure TKIpFinder.Find;
begin
	FIpAddress:=PInAddr(FBuffer.hostEnt.h_addr_list^)^;
	if assigned(FOnFind) then FOnFind(Self,FIpAddress);
end;

{****************************************************************}
{* ストリーム型のソケット基本コンポーネント			*}
{****************************************************************}
constructor TKStreamSock.Create(AOwner:TComponent);
begin
	inherited;
	FWnd:=Classes.AllocateHWnd(WndProc);
	FHandle:=INVALID_SOCKET;
end;

destructor TKStreamSock.Destroy;
begin
	Close;
	Classes.DeallocateHWnd(FWnd);
	inherited;
end;

function TKStreamSock.GetHandle:TSocket;
begin
	if FHandle=INVALID_SOCKET then begin
		FHandle:=socket(AF_INET,SOCK_STREAM,0);
		if FHandle=INVALID_SOCKET then begin
			ThrowError(WSAGetLastError);
		end;
	end;
	Result:=FHandle;
end;

procedure TKStreamSock.SetHandle(Newval:TSocket);
begin
	if FHandle=Newval then Exit;
	Close;
	FHandle:=Newval;
end;

procedure TKStreamSock.ThrowError(Code:Integer);
var
	E:	TKError;
begin
	if assigned(FOnError) then begin
		E:=TKWinsockError.Create(Code);
		Try
			FOnError(Self,E);
		Finally
			E.Free;
		end;
	end;
end;

procedure TKStreamSock.Close;
begin
	if FHandle=INVALID_SOCKET then Exit;
	if closesocket(FHandle)<>0 then begin
		ThrowError(WSAGetLastError);
	end;
	FHandle:=INVALID_SOCKET;
end;

procedure TKStreamSock.WndProc(var Msg:TMessage);
begin
	Msg.Result:=DefWindowProc(FWnd,Msg.Msg,Msg.wParam,Msg.lParam);
end;

{****************************************************************}
{* 通信を行うソケットコンポーネント				*}
{****************************************************************}
type
PSockSendBuff=^TSockSendBuff;
TSockSendBuff=Record
	Size      :	Integer;
	Sendpoint :	PChar;
	Buff      :	PChar;
end;

constructor TKStreamTranciverSocket.Create(AOwner:TComponent);
begin
	inherited;
	FSendBuff:=TList.Create;
	FRecvMode:=ktrmBinary;
	FRecvBuf:='';
  FSendCount := 0;
end;

destructor TKStreamTranciverSocket.Destroy;
begin
	Close;
	FSendBuff.Free;
	inherited;
end;

procedure TKStreamTranciverSocket.Close;
begin
	if FHandle=INVALID_SOCKET then Exit;
  {
	while FCloseReserved and (FSendBuff.Count>0) do
  begin
		//Application.ProcessMessages;
	end;
  }
	inherited;
	while FSendBuff.Count>0 do begin
		FreeMem(FSendBuff.Items[FSendBuff.Count-1]);
		FsendBuff.Delete(FSendBuff.Count-1);
	end;
end;

procedure TKStreamTranciverSocket.ForceClose;
var
	lg:	TLinger;
begin
	FCloseReserved:=False;
	lg.l_onoff:=1;
	lg.l_linger:=0;
	if setsockopt(Handle,SOL_SOCKET,SO_LINGER,PChar(@lg),sizeof(lg))<>0 then begin
		ThrowError(WSAGetLastError);
	end;
	inherited;
	while FSendBuff.Count>0 do begin
		FreeMem(FSendBuff.Items[FSendBuff.Count-1]);
		FsendBuff.Delete(FSendBuff.Count-1);
	end;
end;

procedure TKStreamTranciverSocket.ReserveClose;
var
	lg:	TLinger;
begin
	if FHandle=INVALID_SOCKET then Exit;
	FCloseReserved:=True;
	lg.l_onoff:=0;
	lg.l_linger:=0;
	if setsockopt(Handle,SOL_SOCKET,SO_LINGER,PChar(@lg),sizeof(lg))<>0 then begin
		ThrowError(WSAGetLastError);
	end;
	if FSendBuff.Count=0 then Close;
end;

procedure TKStreamTranciverSocket.WndProc(var Msg:TMessage);
begin
	if Msg.Msg = WM_KOK_ASYNCCMD then
  begin
		if FHandle <> Msg.wParam then Exit;	{ すでにクローズしたソケットのメッセージ }
		case WSAGetSelectEvent(Msg.lParam) of
		  FD_Close  :	DisconnectEvent(Msg);
		  FD_Write  :	WriteReadyEvent(Msg);
		  FD_Read   :	ReadReadyEvent(Msg);
		  else
        Msg.Result:=0;	{ 何もしない }
		end;
	end
	else begin
		inherited;
	end;
end;

procedure TKStreamTranciverSocket.WriteReadyEvent(var Msg:Tmessage);
var
	i: Integer;
  p: PSockSendBuff;
begin
	if WSAGetSelectError(Msg.lParam)<>0 then
  begin
		ThrowError(WSAGetSelectError(Msg.lParam));
		Exit;
	end;

	while FSendBuff.Count > 0 do
  begin
    p := FSendBuff.Items[0];
    while p.Size > 0 do
    begin
      i := Winsock.send(Handle, p.Sendpoint^, p.Size, 0);
      if i = SOCKET_ERROR then
      begin
        if WSAGetLastError<>WSAEWOULDBLOCK then begin
          ThrowError(WSAGetLastError);
        end;
        Exit;
      end;
      Dec(p.Size, i);
      Inc(p.Sendpoint,i);
    end;
		FreeMem(p.Buff);
    Dispose(p); { 先頭のバッファが要らなくなったので削除 }
		FSendBuff.Delete(0);
	end;
	if FCloseReserved then
  begin
		Close;
		Exit;
	end;
	if (FSendCount > 0) and (assigned(FOnSendEmpty)) then FOnSendEmpty(Self);
end;

procedure TKStreamTranciverSocket.ReadReadyEvent(var Msg:TMessage);
var
	i:	integer;
begin
	if WSAGetSelectError(Msg.lParam)<>0 then begin
		ThrowError(WSAGetSelectError(Msg.lParam));
		Exit;
	end;
	FRecvBuf:=FRecvBuf+RecvStringReal;
	if Length(FRecvBuf)=0 then Exit;
	Case RecvMode of
	ktrmBinary:
		begin
			if assigned(FOnRcvReady) then FOnRcvReady(Self);
		end;
	ktrmText:
		begin
			i:=Pos(#13#10,FRecvBuf);
			if i<1 then Exit;
			if assigned(FOnRcvReady) then FOnRcvReady(Self);
		end;
	end;
end;

procedure TKStreamTranciverSocket.DisconnectEvent(var Msg:TMessage);
begin
	if WSAGetSelectError(Msg.lParam)<>0 then
  begin
		ThrowError(WSAGetSelectError(Msg.lParam));
		Exit;
	end;
	if assigned(FOnDisconnect) then FOnDisconnect(Self);
end;

procedure TKStreamTranciverSocket.Send(const data; len: integer);
var
	p:	PSockSendBuff;
begin
	if len < 1 then	Exit;
	if @data = nil then Exit;

  // 送信バッファを作る
  New(p);
  p^.Size := len;
  p^.Buff := AllocMem(len);
  p^.Sendpoint := p.Buff;
  Move(data, p^.Buff^, len);
  FSendBuff.Add(p);
  Inc(FSendCount);
  //
	PostMessage(FWnd,WM_KOK_ASYNCCMD,GetHandle,WSAMAKESELECTREPLY(FD_WRITE,0));
end;

procedure TKStreamTranciverSocket.SendString(str: string);
begin
	Send(str[1],Length(str));
end;

function TKStreamTranciverSocket.RecvReal(var data; len: Integer):Integer;
begin
	result:=0;
	if len<1 then Exit;
	if @data=nil then Exit;
	if Handle=INVALID_SOCKET then Exit;
	result:=Winsock.recv(Handle,data,len,0);
	if result=SOCKET_ERROR then begin
		Result:=0;
		if WSAGetLastError<>WSAEWOULDBLOCK then begin
			ThrowError(WSAGetLastError);
		end;
	end;
end;

function TKStreamTranciverSocket.RecvStringReal:string;
var
	b:	string;
	i:	integer;
begin
	result:='';
	while TRUE do begin
		SetLength(b,8*1024);
		i:=RecvReal(b[1],Length(b));
		if i>0 then begin
			SetLength(b,i);
			result:=result+b;
		end
		else begin
			Exit;
		end;
	end;
end;

function TKStreamTranciverSocket.Recv(var data; len: Integer):Integer;
var
	l:	integer;
begin
	result:=0;
	if (len<1) or (@data=nil) then Exit;
	if RecvMode=ktrmBinary then begin
		l:=Length(FRecvBuf);
		if l<1 then Exit;
		if l>len then begin
			Move(FRecvBuf[1],data,len);
			System.Delete(FRecvBuf,1,len);
			Result:=len;
		end
		else begin
			Move(FRecvBuf[1],data,l);
			Result:=l;
			System.Delete(FRecvBuf,1,l);
		end;
	end
	else begin
		l:=Pos(#13#10,FRecvBuf)+2-1;
		if l<2 then Exit;
		if l<=len then begin
			Move(FRecvBuf[1],data,l);
			Result:=l;
			System.Delete(FRecvBuf,1,l);
		end
		else begin
			if l-1=len then len:=len-1; // #10が余ってしまう
			Move(FRecvBuf[1],data,len);
			System.Delete(FRecvBuf,1,len);
			Result:=len;
		end;
	end;
	if Length(FRecvBuf)<>0 then begin
		PostMessage(FWnd,WM_KOK_ASYNCCMD,Handle,WSAMAKESELECTREPLY(FD_READ,0));
	end;
end;

function TKStreamTranciverSocket.RecvString:string;
var
	l:	integer;
begin
	if RecvMode=ktrmBinary then begin
		result:=FRecvBuf;
		FRecvBuf:='';
	end
	else begin
		l:=Pos(#13#10,FRecvBuf)+2-1;
		if l<2 then Exit;
		result:=Copy(FRecvBuf,1,l);
		System.Delete(FRecvBuf,1,l);
		if Pos(#13#10,FRecvBuf)>0 then begin
			PostMessage(FWnd,WM_KOK_ASYNCCMD,Handle,WSAMAKESELECTREPLY(FD_READ,0));
		end;
	end;
end;

procedure TKStreamTranciverSocket.SetRecvMode(Newval: TKTcpRecvMode);
begin
	if Newval=FRecvMode then Exit;
	FRecvMode:=Newval;
	if (FRecvMode=ktrmBinary) and (Length(FRecvBuf)>0) then begin
		PostMessage(FWnd,WM_KOK_ASYNCCMD,Handle,WSAMAKESELECTREPLY(FD_READ,0));
	end;
end;

{****************************************************************}
{* クライアントソケット						*}
{****************************************************************}
constructor TKTcpClient.Create(AOwner:TComponent);
begin
	inherited Create(AOwner);
	FIpFinder:=TKIpFinder.Create(Self);
	FIpFinder.OnFind:=FindServerAddr;
	FIpFinder.OnError:=DoError;
	FServerAddr.S_addr:=LongInt(INADDR_NONE);
	FPort:=0;
end;

destructor TKTcpClient.Destroy;
begin
	FIpFinder.Free;
	inherited;
end;

procedure TKTcpClient.Loaded;
begin
	inherited;
	if FActive then begin
		FActive:=False;
		Active:=True;
	end;
end;

procedure TKTcpClient.DoError(Sender: TObject; E: TKError);
begin
	if Active then FActive:=False;
	if assigned(FOnError) then FOnError(Self,E);
end;

procedure TKTcpClient.FindServerAddr(Sender: TObject; addr: TInAddr);
begin
	FServerAddr:=addr;
	DoConnect;
end;

procedure TKTcpClient.SetServerName(Newval:string);
begin
	if FServerName=Newval then Exit;
	FServerName:=Newval;
	if csDesigning in ComponentState then Exit;
	FIpFinder.Search(Newval);
end;

procedure TKTcpClient.SetServerAddr(Newval:TInAddr);
var
	act:	Boolean;
begin
	if FServerAddr.S_addr=Newval.S_addr then Exit;
	act:=Active;
	Active:=False;
	FIpFinder.Cancel;
	FServerAddr:=Newval;
	FServerName:=inet_ntoa(FServerAddr);
	Active:=act;
end;

procedure TKTcpClient.SetPort(Newval:WORD);
var
	act:	Boolean;
begin
	if FPort=Newval then Exit;
	act:=Active;
	Active:=False;
	FPort:=Newval;
	Active:=act;
end;

procedure TKTcpClient.DoConnect;
var
	SvAddr:	TSockAddr;
	lparam:	LongInt;
begin
	if not FActive then Exit;
	if Handle=INVALID_SOCKET then Exit;
	FillChar(SvAddr,sizeof(SvAddr),0);
	SvAddr.sin_family:=AF_INET;
	SvAddr.sin_port:=htons(FPort);
	SvAddr.sin_addr:=FServerAddr;
	lParam:=FD_CONNECT or FD_WRITE or FD_READ or FD_CLOSE;
	if WSAASyncSelect(Handle,FWnd,WM_KOK_ASYNCCMD,lparam)=SOCKET_ERROR then begin
		ThrowError(WSAGetLastError);
		Exit;
	end;
	if winsock.connect(Handle,SvAddr,sizeof(SvAddr))=SOCKET_ERROR then begin
		if WSAGetLastError<>WSAEWOULDBLOCK then begin
			ThrowError(WSAGetLastError);
			Exit;
		end;
	end
	else begin
		PostMessage(FWnd,WM_KOK_ASYNCCMD,Handle,WSAMAKESELECTREPLY(FD_CONNECT,0));
	end;
end;

procedure TKTcpClient.SetActive(Newval:Boolean);
begin
	if FActive=Newval then Exit;
	FActive:=Newval;
	if csDesigning in ComponentState then Exit;
	if csLoading in ComponentState then Exit;
	if FActive then begin
		if not FIpFinder.Searching then
			DoConnect;
	end
	else		Close;
end;

procedure TKTcpClient.Connect;
begin
	Active:=True;
end;

procedure TKTcpClient.WndProc(var Msg:TMessage);
begin
	if (Msg.Msg=WM_KOK_ASYNCCMD) and (FHandle=Msg.wparam) and (WSAGetSelectEvent(msg.lParam)=FD_Connect) then begin
		ConnectEvent(Msg);
	end
	else begin
		inherited;
	end;
end;

procedure TKTcpClient.ConnectEvent(var Msg:TMessage);
begin
	if WSAGetSelectError(Msg.lParam)<>0 then
  begin
		ThrowError(WSAGetSelectError(Msg.lParam));
		Exit;
	end;
	FConnected := True;
  
	if Assigned(FOnConnect) then
  begin
    FOnConnect(Self);
  end;
end;

procedure TKTcpClient.WriteReadyEvent(var Msg:TMessage);
begin
	if not FConnected then Exit;
	inherited;
end;

procedure TKTcpClient.Close;
begin
	FActive:=False;
	inherited;
	FConnected:=False;
end;

procedure TkTcpClient.DisconnectEvent(var Msg:TMessage);
begin
	FConnected:=False;
	inherited;
end;

{****************************************************************}
{* サーバーの中でクライアントの相手をするソケット		*}
{****************************************************************}
constructor TKTcpChildSock.Create(AOwner:TComponent);
begin
	inherited Create(AOwner);
end;

destructor TKTcpChildSock.Destroy;
begin
	if assigned(FOnDestroy) then FOnDestroy(Self);
	inherited;
end;

function TKTcpChildSock.GetIndex:Integer;
begin
	result:=Componentindex;
end;

procedure TKTcpChildSock.Close;
begin
	inherited;
	PostMessage((Owner as TKTcpServer).Wnd,WM_KOK_CHILDFREE,0,LongInt(Self));
end;

procedure TKTcpChildSock.DisconnectEvent(var Msg:TMessage);
begin
	inherited;
	Close;
end;

procedure TKTcpChildSock.SetUp;
var
        lParam: LongInt;
begin
	lParam:=FD_CONNECT or FD_WRITE or FD_READ or FD_CLOSE;
	if WSAASyncSelect(Handle,FWnd,WM_KOK_ASYNCCMD,lparam)=SOCKET_ERROR then begin
		ThrowError(WSAGetLastError);
		Exit;
	end;
end;

{****************************************************************}
{* サーバーソケット						*}
{****************************************************************}
procedure TKTcpServer.Loaded;
begin
	inherited;
	if FActive then begin
		FActive:=False;
		Active:=True;
	end;
end;

procedure TKTcpServer.SetActive(Newval:Boolean);
begin
	if FActive=Newval then Exit;
	if (csLoading in ComponentState) or (csDesigning in ComponentState) then begin
		FActive:=Newval;
		Exit;
	end;
	if Newval then	Open
	else		Close;
end;

procedure TkTcpServer.Open;
var
	addr:	TSockAddr;
begin
	if FActive then Exit;
	FActive:=True;
	if Handle=INVALID_SOCKET then Exit;
	FillChar(addr,sizeof(addr),0);
	addr.sin_family:=AF_INET;
	addr.sin_port:=htons(Port);
	if winsock.bind(Handle,addr,sizeof(addr))=SOCKET_ERROR then begin
		ThrowError(WSAGetLastError);
		Exit;
	end;
	if winsock.listen(Handle,5)=SOCKET_ERROR then begin
		ThrowError(WSAGetLastError);
		Exit;
	end;
	if WSAASyncSelect(Handle,FWnd,WM_KOK_ASYNCCMD,FD_ACCEPT)=SOCKET_ERROR then begin
		ThrowError(WSAGetLastError);
		Exit;
	end;
end;

procedure TKTcpServer.Close;
begin
	if not FActive then Exit;
	while ChildCount>0 do begin
		ChildSock[0].Free;
	end;
	FActive:=False;
	inherited;
end;

procedure TKTcpServer.WndProc(var msg:TMessage);
var
	i:	Integer;
	addr:		TSockAddr;
	addrlen:	Integer;
	sock:	TSocket;
	NewSock:	TKTcpChildSock;
begin
	if Msg.Msg=WM_KOK_CHILDFREE then begin
		Msg.Result:=0;
		if ChildCount<0 then Exit;
		for i:=0 to ChildCount-1 do begin
			if Pointer(ChildSock[i])=Pointer(Msg.lParam) then begin
				ChildSock[i].Free;
				Exit;
			end;
		end;
		Exit;
	end;
	if (Msg.Msg=WM_KOK_ASYNCCMD) and (WSAGetSelectEvent(Msg.lParam)=FD_ACCEPT) then begin
		Msg.Result:=0;
		if WSAGetSelectError(Msg.lParam)<>0 then begin
			ThrowError(WSAGetSelectError(Msg.lParam));
			Exit;
		end;
		addrlen:=sizeof(addr);
		FillChar(addr,sizeof(addr),0);
{$IFDEF VER90}
{ Delphi2 }
		sock:=Winsock.accept(Handle,addr,addrlen);
{$ELSE}
{ Delphi3,4 }
		sock:=Winsock.accept(Handle,@addr,@addrlen);
{$ENDIF}
		if sock=INVALID_SOCKET then begin
			ThrowError(WSAGetlastError);
			Exit;
		end;
		NewSock:=TKTcpChildSock.Create(Self);
    NewSock._SetHandle(sock);
		NewSock.OnSendEmpty:=DoSendEmpty;
		NewSock.OnRcvReady:=DoRcvReady;
		NewSock.OnDisconnect:=DoDisconnect;
		NewSock.OnDestroy:=DoDestroy;
		NewSock.OnError:=DoError;
		NewSock.RecvMode:=FRecvMode;
		if assigned(FOnConnect) then FOnConnect(Self,Newsock);
		NewSock.SetUp;
		Exit;
	end;
	inherited;
end;

procedure TKTcpServer.DoSendEmpty(Sender:TObject);
begin
	if assigned(FOnSendEmpty) then FOnSendEmpty(Self,Sender as TKTcpChildSock);
end;

procedure TKTcpServer.DoRcvReady(Sender:TObject);
begin
	if assigned(FOnRcvReady) then FOnRcvReady(Self,Sender as TKTcpChildSock);
end;

procedure TKTcpServer.DoDisconnect(Sender:TObject);
begin
	if assigned(FOnDisConnect) then FOnDisConnect(Self,Sender as TKTcpChildSock);
end;

procedure TKTcpServer.DoDestroy(Sender:TObject);
begin
	if assigned(FOnChildDestroy) then FOnChildDestroy(Self,Sender as TKTcpChildSock);
end;

procedure TKTcpServer.DoError(Sender:TObject; E:TKError);
begin
	if assigned(FOnChildError) then FOnChildError(Self,Sender as TKTcpChildSock,E);
end;

function TKTcpServer.GetChildSock(idx:Integer):TKTcpChildSock;
begin
	Result:=Components[idx] as TKTcpChildSock;
end;

function TKTcpServer.GetChildCount:Integer;
begin
	Result:=ComponentCount;
end;

procedure TKTcpServer.SetOnRcvReady(Newval: TKServerNotifyEvent);
var
	i:	Integer;
begin
	FOnRcvReady:=Newval;
	if ChildCount=0 then Exit;
	for i:=0 to ChildCount-1 do begin
		ChildSock[i].OnRcvReady:=DoRcvReady;
	end;
end;

{****************************************************************}
{* Winsockが使えるか						*}
{****************************************************************}
function CanUseWinsock:Boolean;
begin
	result:=WSAError;
end;

{****************************************************************}
{* ローカルホスト名を取得する					*}
{****************************************************************}
function LocalHostName:string;
begin
	if not CanUseWinsock then begin
		SetLength(result,512);
		if gethostname(PChar(result),512)<>0 then begin
			result:='';
		end
		else begin
			SetLength(result,StrLen(PChar(result)));
		end;
	end
	else begin
		result:='';
	end;
end;

{****************************************************************}
{* ソケットのエラーを文字列で表現する				*}
{****************************************************************}
type
TWinSockErrorStr=RECORD
	ErCode:	Integer;
	ErStr:	string;
end;

const
CWinSockErrorStrSize = 50;
CWinSockErrorStr: array [0..CWinSockErrorStrSize-1] of TWinSockErrorStr =(
	(ErCode:WSAEINTR;		ErStr:'WSAEINTR 中止命令により中断しました'),
	(ErCode:WSAEBADF;		ErStr:'WSAEBADF ファイル番号が違います'),
	(ErCode:WSAEACCES;		ErStr:'WSAEACCES アクセスが拒否されました'),
	(ErCode:WSAEFAULT;		ErStr:'WSAEFAULT アドレスが違います'),
	(ErCode:WSAEINVAL;		ErStr:'WSAEINVAL パラメータが解釈できません'),
	(ErCode:WSAEMFILE;		ErStr:'WSAEMFILE ファイルのオープン数が多すぎます'),
	(ErCode:WSAEWOULDBLOCK;		ErStr:'WSAEWOULDBLOCK 操作がブロックされます'),
	(ErCode:WSAEINPROGRESS;		ErStr:'WSAEINPROGRESS 操作が処理中です'),
	(ErCode:WSAEALREADY;		ErStr:'WSAEALREADY すでに実行中です'),
	(ErCode:WSAENOTSOCK;		ErStr:'WSAENOTSOCK ソケット以外でソケット操作がありました'),
	(ErCode:WSAEDESTADDRREQ;	ErStr:'WSAEDESTADDRREQ 宛先アドレスが設定されていません'),
	(ErCode:WSAEMSGSIZE;		ErStr:'WSAEMSGSIZE メッセージが長すぎます'),
	(ErCode:WSAEPROTOTYPE;		ErStr:'WSAEPROTOTYPE プロトコル種類が不正です'),
	(ErCode:WSAENOPROTOOPT;		ErStr:'WSAENOPROTOOPT プロトコルが使用できません'),
	(ErCode:WSAEPROTONOSUPPORT;	ErStr:'WSAEPROTONOSUPPORT プロトコルがサポートされていません'),
	(ErCode:WSAESOCKTNOSUPPORT;	ErStr:'WSAESOCKTNOSUPPORT ソケットがサポートされていません'),
	(ErCode:WSAEOPNOTSUPP;		ErStr:'WSAEOPNOTSUPP 操作がソケットでサポートされていません'),
	(ErCode:WSAEPFNOSUPPORT;	ErStr:'WSAEPFNOSUPPORT プロトコルファミリがサポートされていません'),
	(ErCode:WSAEAFNOSUPPORT;	ErStr:'WSAEAFNOSUPPORT アドレスファミリがサポートされていません'),
	(ErCode:WSAEADDRINUSE;		ErStr:'WSAEADDRINUSE アドレスがすでに使用中です'),
	(ErCode:WSAEADDRNOTAVAIL;	ErStr:'WSAEADDRNOTAVAIL 設定されたアドレスを割り当てられません'),
	(ErCode:WSAENETDOWN;		ErStr:'WSAENETDOWN ネットワークダウンしています'),
	(ErCode:WSAENETUNREACH;		ErStr:'WSAENETUNREACH ネットワークが到達できません'),
	(ErCode:WSAENETRESET;		ErStr:'WSAENETRESET リセットされたのでネットワーク接続が落とされました'),
	(ErCode:WSAECONNABORTED;	ErStr:'WSAECONNABORTED 接続中断要求により中断されました'),
	(ErCode:WSAECONNRESET;		ErStr:'WSAECONNRESET ピア側での接続がリセットされました'),
	(ErCode:WSAENOBUFS;		ErStr:'WSAENOBUFS バッファがありません'),
	(ErCode:WSAEISCONN;		ErStr:'WSAEISCONN ソケットはすでに接続されています'),
	(ErCode:WSAENOTCONN;		ErStr:'WSAENOTCONN ソケットが接続されていません'),
	(ErCode:WSAESHUTDOWN;		ErStr:'WSAESHUTDOWN ソケットがすでに解放されているため送信できません'),
	(ErCode:WSAETOOMANYREFS;	ErStr:'WSAETOOMANYREFS 参照が多すぎます'),
	(ErCode:WSAETIMEDOUT;		ErStr:'WSAETIMEDOUT 接続タイムアウトが発生しました'),
	(ErCode:WSAECONNREFUSED;	ErStr:'WSAECONNREFUSED 接続が拒否されました'),
	(ErCode:WSAELOOP;		ErStr:'WSAELOOP シンボリックリンクレベルが大きすぎます'),
	(ErCode:WSAENAMETOOLONG;	ErStr:'WSAENAMETOOLONG ファイル名が長すぎます'),
	(ErCode:WSAEHOSTDOWN;		ErStr:'WSAEHOSTDOWN ホストがダウンしています'),
	(ErCode:WSAEHOSTUNREACH;	ErStr:'WSAEHOSTUNREACH ホストへの到達経路が見つかりません'),
	(ErCode:WSAENOTEMPTY;		ErStr:'WSAENOTEMPTY ディレクトリが空ではありません'),
	(ErCode:WSAEPROCLIM;		ErStr:'WSAEPROCLIM プロセス数が多すぎます'),
	(ErCode:WSAEUSERS;		ErStr:'WSAEUSERS ユーザ数が多すぎます'),
	(ErCode:WSAEDQUOT;		ErStr:'WSAEDQUOT ディスク割り当てを超えました'),
	(ErCode:WSAESTALE;		ErStr:'WSAESTALE NFSファイルハンドルが失効しました'),
	(ErCode:WSAEREMOTE;		ErStr:'WSAEREMOTE パス中の遠隔レベルが過剰です'),
	(ErCode:WSASYSNOTREADY;		ErStr:'WSASYSNOTREADY アプリケーションがWinsock.DLLでサポートできません'),
	(ErCode:WSAVERNOTSUPPORTED;	ErStr:'WSAVERNOTSUPPORTED サーバーが対応していません'),
	(ErCode:WSANOTINITIALISED;	ErStr:'WSANOTINITIALISED Winsockが初期化されていません'),
	(ErCode:WSAHOST_NOT_FOUND;	ErStr:'WSAHOST_NOT_FOUND ホストが見つかりません'),
	(ErCode:WSATRY_AGAIN;		ErStr:'WSATRY_AGAIN もう1度試せば回復するかもしれません'),
	(ErCode:WSANO_RECOVERY;		ErStr:'WSANO_RECOVERY 回復できないエラーです'),
	(ErCode:WSANO_DATA;		ErStr:'WSANO_DATA 見つかりません')
);
function SockErrorString(code:Integer):string;
var
	i:	Integer;
begin
	for i:=0 to CWinSockErrorStrSize-1 do begin
		if CWinSockErrorStr[i].ErCode=code then begin
			Result:=CWinSockErrorStr[i].ErStr;
			Exit;
		end;
	end;
	Result:='エラーコード: '+IntToStr(code);
end;

procedure TKTcpChildSock._SetHandle(h: TSocket);
begin
  FHandle := h;
end;

function TKStreamTranciverSocket.RecvStrByte(len: Integer): string;
var
  s: string;
begin
  Result := '';
  while len > Length(Result) do
  begin
    try
      Result := Result + RecvString;
    except
      raise;
    end;
  end;
  if len < Length(Result) then
  begin
    s := Result;
    Result := Copy(Result, 1, len);
    System.Delete(s, 1, len);
    FRecvBuf := s + FRecvBuf;
  end;
end;

Initialization
	WSAError:=(WSAStartUp($0101,WSAData)<>0) or (WSAData.wVersion<>$0101);
Finalization
	WSACleanUp;

end.
