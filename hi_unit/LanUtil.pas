unit LanUtil;
{
作成者：クジラ飛行机(http://kujirahand.com)
説　明：LAN上のコンピューターを制御するのに便利なユニット

このユニットを作るにあたり、Delphi Acid Floor(http://www.wwlnk.com/boheme/)のサンプルを参考にしました。
}

interface
uses
  SysUtils, Classes, Windows, WinSock;

type
  {NETRESOURCE構造体}
  PNetResourceArray = ^TNetResourceArray;
  TNetResourceArray = array[0..MaxInt div SizeOf(TNetResource) - 1] of TNetResource;

{ネットワーク上のコンピューター名を列挙する}
function LanEnumComputer(domain: string; IncludeDomain: Boolean) : string;
{ネットワーク上のコンピューター名を入れると共有になっているリソースを列挙する}
function LanGetCommonResource(computer: string): string;
{ネットワーク上のドメイン名を列挙する}
function LanEnumDomain : string;

{ユーザー名取得}
function GetUserName: string;
{コンピューター名取得}
function GetComputerName: string;

{IPアドレスを取得する}
function GetIpAddress(s: string): string;

procedure AddNetworkDrive(Drive, UNC, Comment: PChar; Pass:PChar=nil;User:PChar=nil);

implementation

uses unit_windows_api;

// ネットワークドライブの割り当て
procedure AddNetworkDrive(Drive, UNC, Comment: PChar; Pass:PChar=nil;User:PChar=nil);
var
  NetResource: TNetResource;
begin
  ZeroMemory(@NetResource, SizeOf(TNetResource));
  with NetResource do
  begin
    dwType        :=  RESOURCETYPE_DISK;
    lpLocalName   :=  Drive;
    lpRemoteName  :=  UNC;
    lpComment     :=  Comment;
    lpProvider    :=  nil;
  end;
  //if (WNetAddConnection2(NetResource, nil{pass}, nil{user}, 0) <> NO_ERROR) then
  if (WNetAddConnection2(NetResource, pass, user, 0) <> NO_ERROR) then
  begin
    raise Exception.Create(GetLastErrorStr);
  end;
end;


{ユーザー名取得}
function GetUserName: string;
var
    c: array[0..255]of char;
    d: DWORD;
begin
    d := 255;
    Windows.GetUserName(@c[0], d);
    Result := c;
end;

{コンピューター名取得}
function GetComputerName: string;
var
    c: array[0..255]of char;
    d: DWORD;
begin
    d := 255;
    Windows.GetComputerName(@c[0], d);
    Result := c;
end;


function GetIpAddress(s: string): string;
var
  wVersionRequired: Word;
  WSData: TWSAData;
  //Status: Integer;
  Name: array[0..255] of Char;
  HostEnt: PHostEnt;
  IP: PChar;
begin
    wVersionRequired := MAKEWORD(1, 1);
    WSAStartup(wVersionRequired, WSData);
    try
        StrPCopy(Name, s);
        HostEnt := GetHostByName(@Name);

        if HostEnt <> nil then begin
        IP := HostEnt^.h_addr_list^;
        Result := IntToStr(Integer(IP[0]))
           + '.' + IntToStr(Integer(IP[1]))
           + '.' + IntToStr(Integer(IP[2]))
           + '.' + IntToStr(Integer(IP[3]));
        end
        else
            Result := '(N/A)';
    finally
        WSACleanup;
    end;
end;


function LanEnumDomain : string;
var
  hEnum         : THandle;  {列挙ハンドル}
  cEntries      : integer;  {要求エントリ数}
  BufSize       : integer;  {バッファサイズ(NETRESOURCEのサイズ)}
  ix            : integer;  {添え字}
  NetResources  : PNetResourceArray;  {バッファ用}
  lpnr : TNETRESOURCE;
  Info: TOSVersionInfo;
begin
  Result := '';

  Info.dwOSVersionInfoSize := SizeOf(Info);
  GetVersionEx(Info);

  lpnr.dwScope       :=    RESOURCE_GLOBALNET;
  lpnr.dwType        :=    RESOURCETYPE_ANY;
  lpnr.dwDisplayType :=    RESOURCEDISPLAYTYPE_GENERIC;
  lpnr.dwUsage       :=    RESOURCEUSAGE_CONTAINER;
  lpnr.lpLocalName   :=    '';
  lpnr.lpRemoteName  :=    ''; //Domain
  lpnr.lpComment     :=    '';
  if Info.dwPlatformId=VER_PLATFORM_WIN32_NT then
  begin
    lpnr.lpProvider    :=  'Microsoft Windows Network'; // これを書かないと、win2kでは、"Micorosoft Windows Network"と返されてしまう。
  end else
  begin
    lpnr.lpProvider    :=  '';
  end;

  {ネットワークリソースの列挙を開始する}
  if  WNetOpenEnum(RESOURCE_GLOBALNET,RESOURCETYPE_ANY,0,@lpnr,hEnum) <> NO_ERROR  then begin
    {失敗}
    WNetCloseEnum(hEnum);
    exit;
  end;
  {バッファの確保}
  BufSize := 50 * SizeOf(TNetResource); {十分なサイズを与えろ！}
  GetMem(NetResources, BufSize);
  cEntries := -1;
  {リソース情報の取得 : ここがメイン}
  if  WNetEnumResource( hEnum,DWORD(cEntries),NetResources,DWORD(BufSize)) <> NO_ERROR then begin
    {失敗}
    WNetCloseEnum(hEnum);
    FreeMem(NetResources, BufSize);
    exit;
  end;
  for ix  :=  0 to  cEntries - 1  do  begin
    {リモート名（ドメイン）}
    Result := Result + (NetResources^[ix].lpRemoteName) + #13#10;
  end;
  {列挙ハンドルの閉鎖}
  WNetCloseEnum(hEnum);
  {バッファの開放}
  FreeMem(NetResources, BufSize);
end;

function LanEnumComputer(domain: string; IncludeDomain: Boolean) : string;
var
  hEnum         : THandle;  {列挙ハンドル}
  cEntries      : integer;  {要求エントリ数}
  BufSize       : integer;  {バッファサイズ(NETRESOURCEのサイズ)}
  ix            : integer;  {添え字}
  NetResources  : PNetResourceArray;  {バッファ用}
  lpnr : TNETRESOURCE;

  domains: TStringList;//domain が省略された時の処理
  i: Integer;
  s: string;
begin
  Result := '';
  if domain='' then
  begin
    //ドメインが省略された時の処理
    domains := TStringList.Create ;
    try
        domains.Text := LanEnumDomain ;
        for i:=0 to domains.Count -1 do
        begin
            s := Trim(domains.Strings[i]);
            if s<>'' then
            begin
                s := LanEnumComputer(s, IncludeDomain);
                if s<>'' then
                    Result := Result + Trim(s) + #13#10;
            end;
        end;
    finally
        domains.Free;
    end;
    Result := Trim(Result);
    Exit;
  end;

  lpnr.dwScope       :=    RESOURCE_GLOBALNET;
  lpnr.dwType        :=    RESOURCETYPE_ANY;
  lpnr.dwDisplayType :=    RESOURCEDISPLAYTYPE_DOMAIN;
  lpnr.dwUsage       :=    RESOURCEUSAGE_CONNECTABLE;
  lpnr.lpLocalName   :=    '';
  lpnr.lpRemoteName  :=    PChar(Domain); //Domain
  lpnr.lpComment     :=    '';
  lpnr.lpProvider    :=    '';
  {ネットワークリソースの列挙を開始する}
  if  WNetOpenEnum(RESOURCE_GLOBALNET,RESOURCETYPE_ANY,0,@lpnr,hEnum) <> NO_ERROR  then begin
    {失敗}
    WNetCloseEnum(hEnum);
    exit;
  end;
  {バッファの確保}
  BufSize := 127 * SizeOf(TNetResource); {十分なサイズを与えろ！}
  GetMem(NetResources, BufSize);
  cEntries := -1;
  {リソース情報の取得 : ここがメイン}
  if  WNetEnumResource( hEnum,DWORD(cEntries),NetResources,DWORD(BufSize)) <> NO_ERROR then begin
    {失敗}
    WNetCloseEnum(hEnum);
    FreeMem(NetResources, BufSize);
    exit;
  end;
  for ix  :=  0 to  cEntries - 1  do  begin
    {ローカル名}
    //Result := Result + (NetResources^[ix].lpLocalName) + #13#10;
    {リモート名}
    if IncludeDomain then
        Result := Result + domain + (NetResources^[ix].lpRemoteName) + #13#10
    else
        Result := Result + (NetResources^[ix].lpRemoteName) + #13#10;
    {コメント}
    //Result := Result + (NetResources^[ix].lpComment) + #13#10;
  end;
  {列挙ハンドルの閉鎖}
  WNetCloseEnum(hEnum);
  {バッファの開放}
  FreeMem(NetResources, BufSize);
end;

function LanGetCommonResource(computer: string): string;
var
  hEnum         : THandle;  {列挙ハンドル}
  cEntries      : integer;  {要求エントリ数}
  BufSize       : integer;  {バッファサイズ(NETRESOURCEのサイズ)}
  ix            : integer;  {添え字}
  NetResources  : PNetResourceArray;  {バッファ用}
  lpnr : TNETRESOURCE;
  i: Integer;
begin
  Result := '';
  // computer は \\name の形式で与える必要がある
  // WORKGROUP\\COMPUTER か？
  i := Pos('\\', computer);
  if i > 3 then
  begin
    System.Delete(computer, 1, i - 1);
  end else
  // COMPUTER か？ ... "\\"が無い場合
  if i = 0 then
  begin
    computer := '\\'+computer;
  end;
  lpnr.dwScope       :=    RESOURCE_GLOBALNET;
  lpnr.dwType        :=    RESOURCETYPE_DISK;
  lpnr.dwDisplayType :=    RESOURCEDISPLAYTYPE_GENERIC;
  lpnr.dwUsage       :=    RESOURCEUSAGE_CONNECTABLE;
  lpnr.lpLocalName   :=    '';
  lpnr.lpRemoteName  :=    PChar(computer);
  lpnr.lpComment     :=    '';
  lpnr.lpProvider    :=    '';
  {ネットワークリソースの列挙を開始する}
  if  WNetOpenEnum(RESOURCE_GLOBALNET,RESOURCETYPE_ANY,0,@lpnr,hEnum) <> NO_ERROR  then begin
    {失敗}
    WNetCloseEnum(hEnum);
    exit;
  end;
  {バッファの確保}
  BufSize := 127 * SizeOf(TNetResource); {十分なサイズを与えろ！}
  GetMem(NetResources, BufSize);
  cEntries := -1;
  {リソース情報の取得 : ここがメイン}
  if  WNetEnumResource( hEnum,DWORD(cEntries),NetResources,DWORD(BufSize)) <> NO_ERROR then begin
    {失敗}
    WNetCloseEnum(hEnum);
    FreeMem(NetResources, BufSize);
    exit;
  end;
  for ix  :=  0 to  cEntries - 1  do  begin
    {ローカル名}
    //Result := Result + (NetResources^[ix].lpLocalName) + #13#10;
    {リモート名}
    Result := Result + (NetResources^[ix].lpRemoteName) + #13#10;
    {コメント}
    //Result := Result + (NetResources^[ix].lpComment) + #13#10;
  end;
  {列挙ハンドルの閉鎖}
  WNetCloseEnum(hEnum);
  {バッファの開放}
  FreeMem(NetResources, BufSize);
end;




end.
