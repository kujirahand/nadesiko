{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  11998: IdTCPClient.pas
{
{   Rev 1.32    2004.11.05 10:58:34 PM  czhower
{ Changed connect overloads for C#.
}
{
{   Rev 1.31    8/8/04 12:32:08 AM  RLebeau
{ Redeclared ReadTimeout and ConnectTimeout properties as public instead of
{ protected in TIdTCPClientCustom
}
{
    Rev 1.30    8/4/2004 5:37:34 AM  DSiders
  Changed camel-casing on ReadTimeout to be consistent with ConnectTimeout.
}
{
{   Rev 1.29    8/3/04 11:17:30 AM  RLebeau
{ Added support for ReadTimeout property
}
{
{   Rev 1.28    8/2/04 5:50:58 PM  RLebeau
{ Added support for ConnectTimeout property
}
{
{   Rev 1.27    2004.03.06 10:40:28 PM  czhower
{ Changed IOHandler management to fix bug in server shutdowns.
}
{
{   Rev 1.26    2004.02.03 4:16:54 PM  czhower
{ For unit name changes.
}
{
{   Rev 1.25    1/8/2004 8:22:54 PM  JPMugaas
{ SetIPVersion now virtual so I can override in TIdFTP.  Other stuff may need
{ the override as well.
}
{
{   Rev 1.24    1/2/2004 12:02:18 AM  BGooijen
{ added OnBeforeBind/OnAfterBind
}
{
{   Rev 1.23    12/31/2003 9:52:04 PM  BGooijen
{ Added IPv6 support
}
{
{   Rev 1.20    2003.10.14 1:27:00 PM  czhower
{ Uupdates + Intercept support
}
{
{   Rev 1.19    2003.10.01 9:11:26 PM  czhower
{ .Net
}
{
{   Rev 1.18    2003.10.01 2:30:42 PM  czhower
{ .Net
}
{
{   Rev 1.17    2003.10.01 11:16:36 AM  czhower
{ .Net
}
{
{   Rev 1.16    2003.09.30 1:23:06 PM  czhower
{ Stack split for DotNet
}
{
{   Rev 1.15    2003.09.18 2:59:46 PM  czhower
{ Modified port and host overrides to only override if values exist.
}
{
    Rev 1.14    6/3/2003 11:48:32 PM  BGooijen
  Undid change from version 1.12, is now fixed in iohandlersocket
}
{
{   Rev 1.13    2003.06.03 7:27:56 PM  czhower
{ Added overloaded Connect method
}
{
    Rev 1.12    5/23/2003 6:45:32 PM  BGooijen
  ClosedGracefully is now set if Connect failes.
}
{
{   Rev 1.11    2003.04.10 8:05:34 PM  czhower
{ removed unneeded self. reference
}
{
{   Rev 1.10    4/7/2003 06:58:32 AM  JPMugaas
{ Implicit IOHandler now created in virtual method
{
{ function TIdTCPClientCustom.MakeImplicitClientHandler: TIdIOHandler;
}
{
    Rev 1.9    3/17/2003 9:40:16 PM  BGooijen
  Host and Port were not properly synchronised with the IOHandler, fixed that
}
{
    Rev 1.8    3/5/2003 11:05:24 PM  BGooijen
  Intercept
}
{
{   Rev 1.7    2003.02.25 1:36:16 AM  czhower
}
{
{   Rev 1.6    12-14-2002 22:52:34  BGooijen
{ now also saves host and port settings when an explicit iohandler is used. the
{ host and port settings are copied to the iohandler if the iohandler doesn't
{ have them specified.
}
{
{   Rev 1.5    12-14-2002 22:38:26  BGooijen
{ The host and port settings were lost when the implicit iohandler  was created
{ in .Connect, fixed that.
}
{
{   Rev 1.4    2002.12.07 12:26:12 AM  czhower
}
{
{   Rev 1.2    12/6/2002 02:11:42 PM  JPMugaas
{ Protected Port and Host properties added to TCPClient because those are
{ needed by protocol implementations.  Socket property added to TCPConnection.
}
{
{   Rev 1.1    6/12/2002 4:08:34 PM  SGrobety
}
{
{   Rev 1.0    11/13/2002 09:00:26 AM  JPMugaas
}
unit IdTCPClient;

interface

uses
  Classes,
  IdGlobal, IdExceptionCore, IdIOHandler, IdTCPConnection;

type
  TIdTCPClientCustom = class(TIdTCPConnection)
  protected
    FConnectTimeout: Integer;
    FDestination: string;
    FHost: string;
    FIPVersion: TIdIPVersion;
    FOnConnected: TNotifyEvent;
    FPassword: string;
    FPort: TIdPort;
    FReadTimeout: Integer;
    FUsername: string;
    //
    FOnBeforeBind: TNotifyEvent;
    FOnAfterBind: TNotifyEvent;
    //
    procedure DoOnConnected; virtual;
    function GetConnectTimeout: Integer;
    procedure SetConnectTimeout(AValue: Integer);
    function GetReadTimeout: Integer;
    procedure SetReadTimeout(AValue: Integer);
    function GetHost: string;
    function GetPort: TIdPort;
    function MakeImplicitClientHandler: TIdIOHandler; virtual;
    procedure SetHost(const AValue: string); virtual;
    procedure SetPort(const AValue: TIdPort); virtual;
    procedure SetIPVersion(const AValue: TIdIPVersion); virtual;
    function GetIPVersion: TIdIPVersion;
    //
    procedure SetOnBeforeBind(const AValue: TNotifyEvent);
    procedure SetOnAfterBind(const AValue: TNotifyEvent);
    //
    procedure SetIOHandler(AValue: TIdIOHandler); override;
    //
    property Host: string read GetHost write SetHost;
    property IPVersion: TIdIPVersion read GetIPVersion write SetIPVersion;
    property Password: string read FPassword write FPassword;
    property Port: TIdPort read GetPort write SetPort;
    property Username: string read FUsername write FUsername;
    //
    property OnConnected: TNotifyEvent read FOnConnected write FOnConnected;
  public
    procedure Connect; overload; virtual;
    // This is overridden and not as default params so that descendants
    // do not have to worry about the arguments.
    // Also has been split further to allow usage from C# as it does not have optional
    // params
    procedure Connect(const AHost: string); overload;
    procedure Connect(const AHost: string; const APort: Integer); overload;
    function ConnectAndGetAll: string; virtual;

    property ConnectTimeout: Integer read GetConnectTimeout write SetConnectTimeout;
    property ReadTimeout: Integer read GetReadTimeout write SetReadTimeout;
    property OnBeforeBind:TNotifyEvent read FOnBeforeBind write SetOnBeforeBind;
    property OnAfterBind:TNotifyEvent read FOnAfterBind write SetOnAfterBind;

  published
  end;

  TIdTCPClient = class(TIdTCPClientCustom)
  published
    property ConnectTimeout;
    property Host;
    property IPVersion;
    property OnConnected;
    property Port;
    property ReadTimeout;

    property OnBeforeBind;
    property OnAfterBind;
  end;

implementation

uses
  IdComponent, IdResourceStringsCore, IdIOHandlerSocket,
  SysUtils;

{ TIdTCPClientCustom }

procedure TIdTCPClientCustom.Connect;
begin
  // Do not call Connected here, it will call CheckDisconnect
  EIdAlreadyConnected.IfTrue(Connected, RSAlreadyConnected);
  if IOHandler = nil then begin
    IOHandler := MakeImplicitClientHandler;
    IOHandler.OnStatus := OnStatus;
    ManagedIOHandler := True;
  end;
  try
    // Bypass GetDestination
    if FDestination <> '' then begin
      IOHandler.Destination := FDestination;
    end;

{BGO: not any more, TIdTCPClientCustom has precedence now (for port protocols, and things like that)
    // We retain the settings that are in here (filled in by the user)
    // we only do this when the iohandler has no settings,
    // because the iohandler has precedence
    if (IOHandler.Port = 0) and (IOHandler.Host = '') then begin
      IOHandler.Port := FPort;
      IOHandler.Host := FHost;
    end;
}

    IOHandler.Port := FPort; //BGO: just to make sure
    IOHandler.Host := FHost;
    if IOHandler is TIdIOHandlerSocket then begin
      TIdIOHandlerSocket(IOHandler).IPVersion := FIPVersion;
    end;

    if FConnectTimeout > 0 then begin
      IOHandler.ConnectTimeout := FConnectTimeout;
    end;
    if FReadTimeout > 0 then begin
      IOHandler.ReadTimeout := FReadTimeout;
    end;

    IOHandler.Open;
    if IOHandler.Intercept <> nil then begin
      IOHandler.Intercept.Connect(Self);
    end;

    DoStatus(hsConnected, [Host]);
    DoOnConnected;
  except
    IOHandler.Close;
    raise;
  end;
end;

function TIdTCPClientCustom.ConnectAndGetAll: string;
begin
  Connect; try
    Result := IOHandler.AllData;
  finally Disconnect; end;
end;

procedure TIdTCPClientCustom.DoOnConnected;
begin
  if Assigned(OnConnected) then begin
    OnConnected(Self);
  end;
end;

function TIdTCPClientCustom.GetConnectTimeout: Integer;
begin
  if IOHandler <> nil then begin
    Result := IOHandler.ConnectTimeout;
  end else begin
    Result := FConnectTimeout;
  end;
end;

procedure TIdTCPClientCustom.SetConnectTimeout(AValue: Integer);
begin
  FConnectTimeout := AValue;
  if IOHandler <> nil then begin
    IOHandler.ConnectTimeout := AValue;
  end;
end;

function TIdTCPClientCustom.GetReadTimeout: Integer;
begin
  if IOHandler <> nil then begin
    Result := IOHandler.ReadTimeout;
  end else begin
    Result := FReadTimeout;
  end;
end;

procedure TIdTCPClientCustom.SetReadTimeout(AValue: Integer);
begin
  FReadTimeout := AValue;
  if IOHandler <> nil then begin
    IOHandler.ReadTimeout := AValue;
  end;
end;

function TIdTCPClientCustom.GetHost: string;
begin
  Result := FHost;
end;

function TIdTCPClientCustom.GetPort: Integer;
begin
  Result := FPort;
end;

procedure TIdTCPClientCustom.SetHost(const AValue: string);
begin
  FHost := AValue;
  if Assigned(IOHandler) and (AValue <> '')then begin
    IOHandler.Host := AValue;
  end;
end;

procedure TIdTCPClientCustom.SetPort(const AValue: integer);
begin
  FPort := AValue;
  if Assigned(IOHandler) and (AValue > 0) then begin
    IOHandler.Port := AValue;
  end;
end;

procedure TIdTCPClientCustom.SetIPVersion(const AValue: TIdIPVersion);
begin
  FIPVersion := AValue;
  if Assigned(IOHandler) then begin
    if IOHandler is TIdIOHandlerSocket then begin
      TIdIOHandlerSocket(IOHandler).IPVersion := AValue;
    end;
  end;
end;

function TIdTCPClientCustom.GetIPVersion: TIdIPVersion;
begin
  Result := FIPVersion;
end;

procedure TIdTCPClientCustom.SetOnBeforeBind(const AValue: TNotifyEvent);
begin
  FOnBeforeBind := AValue;
  if Assigned(IOHandler) then begin
    if IOHandler is TIdIOHandlerSocket then begin
      TIdIOHandlerSocket(IOHandler).OnBeforeBind := AValue;
    end;
  end;
end;

procedure TIdTCPClientCustom.SetOnAfterBind(const AValue: TNotifyEvent);
begin
  FOnAfterBind := AValue;
  if Assigned(IOHandler) then begin
    if IOHandler is TIdIOHandlerSocket then begin
      TIdIOHandlerSocket(IOHandler).OnAfterBind := AValue;
    end;
  end;
end;

procedure TIdTCPClientCustom.SetIOHandler(AValue: TIdIOHandler);
begin
  inherited SetIOHandler(AValue);
  // TIdTCPClientCustom overrides settings in iohandler to initialize
  // protocol defaults.
  if IOHandler <> nil then begin
    if FConnectTimeout > 0 then begin
      IOHandler.ConnectTimeout := FConnectTimeout;
    end;
    if FReadTimeout > 0 then begin
      IOHandler.ReadTimeout := FReadTimeout;
    end;
  end;
  if Socket <> nil then begin
    if FPort > 0 then begin
      Socket.Port := FPort;
    end;
    if FHost <> '' then begin
      Socket.Host := FHost;
    end;
    Socket.IPVersion := FIPVersion;
    Socket.OnBeforeBind := FOnBeforeBind;
    Socket.OnAfterBind := FOnAfterBind;
  end;
end;

function TIdTCPClientCustom.MakeImplicitClientHandler: TIdIOHandler;
begin
  Result := TIdIOHandler.MakeDefaultIOHandler(Self);
end;

procedure TIdTCPClientCustom.Connect(const AHost: string);
begin
  Host := AHost;
  Connect;
end;

procedure TIdTCPClientCustom.Connect(const AHost: string; const APort: Integer);
begin
  Host := AHost;
  Port := APort;
  Connect;
end;

end.
