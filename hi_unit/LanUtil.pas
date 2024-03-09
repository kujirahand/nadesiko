unit LanUtil;
{
�쐬�ҁF�N�W����s��(http://kujirahand.com)
���@���FLAN��̃R���s���[�^�[�𐧌䂷��̂ɕ֗��ȃ��j�b�g

���̃��j�b�g�����ɂ�����ADelphi Acid Floor(http://www.wwlnk.com/boheme/)�̃T���v�����Q�l�ɂ��܂����B
}

interface
uses
  SysUtils, Classes, Windows, WinSock;

type
  {NETRESOURCE�\����}
  PNetResourceArray = ^TNetResourceArray;
  TNetResourceArray = array[0..MaxInt div SizeOf(TNetResource) - 1] of TNetResource;

{�l�b�g���[�N��̃R���s���[�^�[����񋓂���}
function LanEnumComputer(domain: string; IncludeDomain: Boolean) : string;
{�l�b�g���[�N��̃R���s���[�^�[��������Ƌ��L�ɂȂ��Ă��郊�\�[�X��񋓂���}
function LanGetCommonResource(computer: string): string;
{�l�b�g���[�N��̃h���C������񋓂���}
function LanEnumDomain : string;

{���[�U�[���擾}
function GetUserName: string;
{�R���s���[�^�[���擾}
function GetComputerName: string;

{IP�A�h���X���擾����}
function GetIpAddress(s: string): string;

procedure AddNetworkDrive(Drive, UNC, Comment: PChar; Pass:PChar=nil;User:PChar=nil);

implementation

uses unit_windows_api;

// �l�b�g���[�N�h���C�u�̊��蓖��
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


{���[�U�[���擾}
function GetUserName: string;
var
    c: array[0..255]of char;
    d: DWORD;
begin
    d := 255;
    Windows.GetUserName(@c[0], d);
    Result := c;
end;

{�R���s���[�^�[���擾}
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
  hEnum         : THandle;  {�񋓃n���h��}
  cEntries      : integer;  {�v���G���g����}
  BufSize       : integer;  {�o�b�t�@�T�C�Y(NETRESOURCE�̃T�C�Y)}
  ix            : integer;  {�Y����}
  NetResources  : PNetResourceArray;  {�o�b�t�@�p}
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
    lpnr.lpProvider    :=  'Microsoft Windows Network'; // ����������Ȃ��ƁAwin2k�ł́A"Micorosoft Windows Network"�ƕԂ���Ă��܂��B
  end else
  begin
    lpnr.lpProvider    :=  '';
  end;

  {�l�b�g���[�N���\�[�X�̗񋓂��J�n����}
  if  WNetOpenEnum(RESOURCE_GLOBALNET,RESOURCETYPE_ANY,0,@lpnr,hEnum) <> NO_ERROR  then begin
    {���s}
    WNetCloseEnum(hEnum);
    exit;
  end;
  {�o�b�t�@�̊m��}
  BufSize := 50 * SizeOf(TNetResource); {�\���ȃT�C�Y��^����I}
  GetMem(NetResources, BufSize);
  cEntries := -1;
  {���\�[�X���̎擾 : ���������C��}
  if  WNetEnumResource( hEnum,DWORD(cEntries),NetResources,DWORD(BufSize)) <> NO_ERROR then begin
    {���s}
    WNetCloseEnum(hEnum);
    FreeMem(NetResources, BufSize);
    exit;
  end;
  for ix  :=  0 to  cEntries - 1  do  begin
    {�����[�g���i�h���C���j}
    Result := Result + (NetResources^[ix].lpRemoteName) + #13#10;
  end;
  {�񋓃n���h���̕�}
  WNetCloseEnum(hEnum);
  {�o�b�t�@�̊J��}
  FreeMem(NetResources, BufSize);
end;

function LanEnumComputer(domain: string; IncludeDomain: Boolean) : string;
var
  hEnum         : THandle;  {�񋓃n���h��}
  cEntries      : integer;  {�v���G���g����}
  BufSize       : integer;  {�o�b�t�@�T�C�Y(NETRESOURCE�̃T�C�Y)}
  ix            : integer;  {�Y����}
  NetResources  : PNetResourceArray;  {�o�b�t�@�p}
  lpnr : TNETRESOURCE;

  domains: TStringList;//domain ���ȗ����ꂽ���̏���
  i: Integer;
  s: string;
begin
  Result := '';
  if domain='' then
  begin
    //�h���C�����ȗ����ꂽ���̏���
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
  {�l�b�g���[�N���\�[�X�̗񋓂��J�n����}
  if  WNetOpenEnum(RESOURCE_GLOBALNET,RESOURCETYPE_ANY,0,@lpnr,hEnum) <> NO_ERROR  then begin
    {���s}
    WNetCloseEnum(hEnum);
    exit;
  end;
  {�o�b�t�@�̊m��}
  BufSize := 127 * SizeOf(TNetResource); {�\���ȃT�C�Y��^����I}
  GetMem(NetResources, BufSize);
  cEntries := -1;
  {���\�[�X���̎擾 : ���������C��}
  if  WNetEnumResource( hEnum,DWORD(cEntries),NetResources,DWORD(BufSize)) <> NO_ERROR then begin
    {���s}
    WNetCloseEnum(hEnum);
    FreeMem(NetResources, BufSize);
    exit;
  end;
  for ix  :=  0 to  cEntries - 1  do  begin
    {���[�J����}
    //Result := Result + (NetResources^[ix].lpLocalName) + #13#10;
    {�����[�g��}
    if IncludeDomain then
        Result := Result + domain + (NetResources^[ix].lpRemoteName) + #13#10
    else
        Result := Result + (NetResources^[ix].lpRemoteName) + #13#10;
    {�R�����g}
    //Result := Result + (NetResources^[ix].lpComment) + #13#10;
  end;
  {�񋓃n���h���̕�}
  WNetCloseEnum(hEnum);
  {�o�b�t�@�̊J��}
  FreeMem(NetResources, BufSize);
end;

function LanGetCommonResource(computer: string): string;
var
  hEnum         : THandle;  {�񋓃n���h��}
  cEntries      : integer;  {�v���G���g����}
  BufSize       : integer;  {�o�b�t�@�T�C�Y(NETRESOURCE�̃T�C�Y)}
  ix            : integer;  {�Y����}
  NetResources  : PNetResourceArray;  {�o�b�t�@�p}
  lpnr : TNETRESOURCE;
  i: Integer;
begin
  Result := '';
  // computer �� \\name �̌`���ŗ^����K�v������
  // WORKGROUP\\COMPUTER ���H
  i := Pos('\\', computer);
  if i > 3 then
  begin
    System.Delete(computer, 1, i - 1);
  end else
  // COMPUTER ���H ... "\\"�������ꍇ
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
  {�l�b�g���[�N���\�[�X�̗񋓂��J�n����}
  if  WNetOpenEnum(RESOURCE_GLOBALNET,RESOURCETYPE_ANY,0,@lpnr,hEnum) <> NO_ERROR  then begin
    {���s}
    WNetCloseEnum(hEnum);
    exit;
  end;
  {�o�b�t�@�̊m��}
  BufSize := 127 * SizeOf(TNetResource); {�\���ȃT�C�Y��^����I}
  GetMem(NetResources, BufSize);
  cEntries := -1;
  {���\�[�X���̎擾 : ���������C��}
  if  WNetEnumResource( hEnum,DWORD(cEntries),NetResources,DWORD(BufSize)) <> NO_ERROR then begin
    {���s}
    WNetCloseEnum(hEnum);
    FreeMem(NetResources, BufSize);
    exit;
  end;
  for ix  :=  0 to  cEntries - 1  do  begin
    {���[�J����}
    //Result := Result + (NetResources^[ix].lpLocalName) + #13#10;
    {�����[�g��}
    Result := Result + (NetResources^[ix].lpRemoteName) + #13#10;
    {�R�����g}
    //Result := Result + (NetResources^[ix].lpComment) + #13#10;
  end;
  {�񋓃n���h���̕�}
  WNetCloseEnum(hEnum);
  {�o�b�t�@�̊J��}
  FreeMem(NetResources, BufSize);
end;




end.
