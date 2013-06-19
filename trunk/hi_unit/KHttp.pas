unit KHttp;

interface

uses
  SysUtils, Classes, Windows, WinSock, messages, WSockUtils;

type
  THttpHead = class
  public
    Key: string;
    Value: string;
    function GetSubKey(SubKey: string): string;
  end;

  THttpHeadList = class(TList)
  private
    FRetCode: string; // 改行コード
    FHttpVersion: string;
    FResponse: Integer;
  public
    constructor Create;
    procedure Clear; override;
    procedure SetAsText(s: string); // POST DATA
    function GetAsText(boundary: string): string;
    function Find(key: string): THttpHead;
    function GetValue(key: string): string;
    function GetBoundary: string;
    property RetCode: string read FRetCode;
    property Response: Integer read FResponse;
    property HttpVersion: string read FHttpVersion;
    procedure AddKey(key, value: string);
  end;

  THttpAuthMode = (httpNone, httpBASIC, httpDigest);

  EKHttpClient = class(Exception);
  TKHttpClient = class(TKTcpClient)
  private
    FProxy: string;
    FUserAgent: string;
    FUsername: string;
    FPassword: string;
    FAuthMode: THttpAuthMode;
    FDigestNonce: string;
    FDigestRealm: string;
    FDigestNC: Integer;
    procedure getProxySettingFromFProxy(var Xhost: string; var Xport: string);
  public
    Cookie: THttpHeadList; // 適当に実装したCookie
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Get(url, head: string): string;
    function Post(url, head, data: string): string; overload;
    function Post(url: string; Data:THttpHeadList): string; overload;
    function Head(url: string): string; // ヘッダを取得する(http://nadesi.com/index.htm)と直接指定が可能
    function RecvToCRLFCRLF: string;
    procedure GetProxySettingFromRegistry;
    procedure OpenUrl(var url: string); // PROXYに対応
    function GetBasicAuth: string; // BASIC認証用のBASE64を返す
    function GetDigestAuth(uri, method: string): string; // DIGEST認証用
    procedure CheckCookie(headList: THttpHeadList);
  published
    property Proxy: string read FProxy write FProxy;
    property UserAgent: string read FUserAgent write FUserAgent;
    property Username: string read FUsername write FUsername;
    property Password: string read FPassword write FPassword;
    property AuthMode: THttpAuthMode read FAuthMode write FAuthMode;
  end;

procedure SplitUrl(url:string;
  var protocol: string; var domain: string; var port: string; var dir: string);

implementation

uses unit_string2, Registry, jconvert, md5;

procedure SplitUrl(url:string;
  var protocol: string; var domain: string; var port: string; var dir: string);
var s: string;
begin
  // http:// を落とす
  protocol := getToken_s(url, '://');
  // dir までを取得
  s := getToken_s(url, '/');
  // domain 取得
  domain := getToken_s(s, ':');
  // port 取得
  port := s;
  // dir
  dir := url;
end;

{ TKHttpClient }


function TKHttpClient.GetBasicAuth: string;
var s: string;
begin
  s := Username + ':' + password;
  Result := EncodeBase64(s);
end;

constructor TKHttpClient.Create(AOwner: TComponent);
begin
  inherited;
  Port := 80;
  FDigestNC := 1;
  Cookie := THttpHeadList.Create;
end;

destructor TKHttpClient.Destroy;
begin
  inherited;
  FreeAndNil(Cookie);
end;

function TKHttpClient.Get(url, head: string): string;
var
  h: THttpHeadList; p: THttpHead;
  ret: string;
  len: Integer;
  s: string;
begin
  OpenUrl(url);
  try
    if Pos('//', url) = 0 then
    begin
      if Copy(url, 1,1) <> '/' then url := '/' + url;
    end;

    // コマンドを送る
    Self.SendLn('GET ' + url + ' HTTP/1.1');
    Self.SendLn('Accept-Language: ja');
    Self.SendLn('Host: ' + Self.Host);
    // 追加ヘッダ
    if head <> '' then // 追加ヘッダを足す
    begin
      Self.send(Trim(head) + #13#10);
    end;
    // 認証
    case AuthMode of
      httpBASIC:
        begin
          Self.SendLn('Authorization: Basic '+GetBasicAuth);
        end;
      httpDigest:
        begin
          raise Exception.Create('未対応');
          Self.SendLn('Authorization: Digest '+GetDigestAuth(url, 'GET'));
        end;
    end;

    if FUserAgent <> '' then Self.SendLn('User-Agent: ' + FUserAgent);

    // 区切り
    Self.SendLn('');
    Self.SendLn('');

    // レスポンスを得る
    ret := Self.RecvToCRLFCRLF; // head
    h := THttpHeadList.Create;
    h.SetAsText(ret);

    // Set-Cookieがあるか？
    CheckCookie(h);
    Result := ret;

    // Content-Length があるか？
    p := h.Find('Content-Length');
    if p <> nil then
    begin
      // Content-Lengthに従って受信する
      len := StrToIntDef(p.Value, -1);
      if len > 0 then
      begin
        ret := Self.RecvData(len);
        Result := Result + #13#10#13#10 + ret;
      end;
    end else
    if (h.Find('Transfer-Encoding') <> nil) and (h.Find('Transfer-Encoding').value = 'chunked') then
    begin
      // chunkにしたがって受信する
      Result := Result + #13#10#13#10;
      while true do
      begin
        // chunkサイズの行を取得
        s := Self.RecvLn;
        // パラメータを捨てる
        s := getToken_s(s,';');
        // サイズ(16進数)を取得
        len := StrToIntDef('$'+s,-1);
        // サイズが0なら終了マークなのでループを抜ける
        if len = 0 then break;
        // chunkサイズ分だけ受信する
        ret := Self.RecvData(len);
        Result := Result + ret;
        // 直後に改行があるはずなので読取＆チェック
        ret := Self.RecvLn;
        if ret <> '' then break;
      end;
      // ヘッダと改行があるはずなので読み取る。ほんとはヘッダに加えるべき？
      ret := RecvToCRLFCRLF;
    end else begin
      ret := Self.RecvDataToEnd;
      Result := Result + #13#10#13#10 + ret;
    end;

    // 読み残りをクリア
    Self.ClearBuffer;

  finally
    Close;
  end;

end;

procedure TKHttpClient.getProxySettingFromFProxy(var Xhost, Xport: string);
var
  s, key, value: string;
begin
  // setting
  Xhost := '';
  Xport := '';
  // proxy
  s := FProxy;
  while (s <> '') do
  begin
    value := Trim(getToken_s(s, ';'));
    key   := Trim(UpperCase(getToken_s(value, '=')));
    if value = '' then begin value := key; key := 'HTTP'; end;
    if (key = 'HTTP') then
    begin
      Xhost := Trim(getToken_s(value, ':'));
      Xport := Trim(value);
      Break;
    end;
  end;
end;

procedure TKHttpClient.GetProxySettingFromRegistry;
const
  proxy_key = 'Software\Microsoft\Windows\CurrentVersion\Internet Settings';
var
  reg: TRegistry;
  UseProxy: DWORD;
begin
  // レジストリからProxy設定を読む
  // HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyServer
  // 形式
  // ftp=127.0.0.1:8000;http=127.0.0.1:8000
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKeyReadOnly(proxy_key) then
    begin
      UseProxy := reg.ReadInteger('ProxyEnable');
      if UseProxy <> 0 then
      begin
        FProxy := reg.ReadString('ProxyServer');
      end else
      begin
        FProxy := '';
      end;
      FUserAgent := reg.ReadString('User Agent');
    end;
  finally
    reg.Free;
  end;
end;

function TKHttpClient.Head(url: string): string;
begin
  // OPEN server
  OpenUrl(url);
  try
    // DOMAIN がない場合
    if Pos('//', url) = 0 then
    begin
      if Copy(url, 1,1) <> '/' then url := '/' + url;
    end;

    // コマンドを送る
    Self.SendLn('HEAD ' + url + ' HTTP/1.1');
    //Self.SendLn('Accept-Language: ja');
    Self.SendLn('Host: ' + Self.Host);
    if FUserAgent <> '' then Self.SendLn('User-Agent: ' + FUserAgent);

    // 区切り
    Self.SendLn('');

    // レスポンスを得る
    Result := Self.RecvToCRLFCRLF;
    
  finally
    Close;
  end;
end;

procedure TKHttpClient.OpenUrl(var url: string);
var
  proxyHost, proxyPort, tmpHost: string;
  tmpPort: Integer;
  defPort: Integer;
  urlProtocol, urlDomain, urlPort, urlDir: string;
  h: THttpHeadList;
  enableSSL: boolean;
  ret: string;
begin
  // PROXY 設定を読む
  getProxySettingFromFProxy(proxyHost, proxyPort);

  // URL にHOST情報を持っているか
  if Pos('//', url) > 0 then
  begin
    SplitUrl(url, urlProtocol, urlDomain, urlPort, urlDir);
    if urlDir = '' then
    begin
      if Copy(url, Length(url), 1) <> '/' then url := url + '/';
    end;
  end;

  enableSSL:=false;
  tmpPort:=0;
  if (urlProtocol<>'') and (urlDomain<>'') then
  begin
    if LowerCase(urlProtocol) = 'https' then
    begin
      defPort := 443;
      // SSL on
      enableSSL := true;
    end else begin
      defPort := 80;
      // SSL off
      enableSSL := false;
    end;
    tmpHost := urlDomain;
    tmpPort := StrToIntDef(urlPort, defPort);
  end;
  // PROXY以外でつなぐ
  if proxyHost = '' then
  begin
    if tmpHost<>'' then
    begin
      Host := tmpHost;
      Port := tmpPort;
    end;
    url := urlDir;
    inherited Open;
  end else
  // PROXYでつなぐ
  begin
    Host := proxyHost;
    Port := StrToIntDef(proxyPort, 8080);
    inherited Open;
    if  enableSSL then
    begin
      self.SendLn('CONNECT ' + tmpHost + ':' + IntToStr(tmpPort) + ' HTTP/1.1');
      self.SendLn('Host: ' + tmpHost);
      self.SendLn('');
      ret := self.RecvToCRLFCRLF;
      h := THttpHeadList.Create;
      try
        h.SetAsText(ret);
        if h.Response <> 200 then
        begin
          raise Exception.Create('プロクシーサーバへの接続エラー' + h.RetCode);
        end;
      finally
        h.free;
      end;
    end;
    // HOST を元に戻す
    Host := urlDomain;
    Port := StrToIntDef(urlPort, tmpPort);
  end;
  if  enableSSL then
  begin
    inherited ConnectSSL;
  end;
end;

function TKHttpClient.RecvToCRLFCRLF: string;
var
  s: string;
begin
  // 改行改行までを受信する
  Result := '';
  while True do
  begin
    try
      s := Self.RecvLn;
    except
      raise;
    end;
    if s = '' then Break;
    Result := Result + s + #13#10;
  end;
end;

function TKHttpClient.GetDigestAuth(uri, method: string): string;
var
  cnonce, qop: string;

  function tekitou: string;
  var i: Integer;
  begin
    Result := '';
    for i := 0 to 4 + Random(4) do begin
      Result := Result + IntToHex(Random(16),1);
    end;
  end;
(*
http://x68000.q-e-d.net/~68user/net/http-auth-2.html
# response を生成
$a1 = "$username:$realm:$passwd";
$h_a1 = md5_hex($a1);
$a2 = "$method:$uri";
$h_a2 = md5_hex($a2);
$response = "$h_a1:$auth_info{nonce}:$nc:$cnonce:$qop:$h_a2";
$h_response = md5_hex($response);
*)

  function nc: string;
  begin
    Result := IntToHex(FDigestNC, 8);
  end;

  function response: string;
  var a1, h_a1, a2, h_a2: string;
  begin
    a1 := Username + ':' + FDigestRealm + ':' + Password;
    h_a1 := md5.MD5Print(md5.MD5String(a1));
    a2 := method + ':' + uri;
    h_a2 := md5.MD5Print(md5.MD5String(a2));
    Result := h_a1 + ':' + FDigestNonce + ':' + nc + ':' + cnonce + ':' +
              qop + ':' + h_a2;
  end;

begin
  cnonce := tekitou;
  qop    := 'auth';

  Result := 'username="'+ Username +'",';
  Result := Result + ' realm="'+FDigestRealm+'",'+#13#10;
  Result := Result + ' nonce="'+FDigestNonce+'",'+#13#10;
  Result := Result + ' uri="'+uri+'", algorithm=MD5,'+#13#10;
  Result := Result + ' qop='+qop+',nc='+nc + ','#13#10;
  Result := Result + ' cnonce="'+cnonce+'",'#13#10;
  Result := Result + ' response="'+response+'"';
  Inc(FDigestNC);
end;

function TKHttpClient.Post(url, head, data: string): string;
var
  h: THttpHeadList; p: THttpHead;
  ret: string;
  len: Integer;
  s: string;
begin
  try
    OpenUrl(url);
  except on e: Exception do
    raise Exception.Create('サーバーとの接続エラー。' + e.Message);
  end;
  try
    if Pos('//', url) = 0 then
    begin
      if Copy(url, 1,1) <> '/' then url := '/' + url;
    end;

    // コマンドを送る
    Self.SendLn('POST ' + url + ' HTTP/1.1');
    Self.SendLn('Accept-Language: ja');
    Self.SendLn('Host: ' + Self.Host);
    // 追加ヘッダ
    if head <> '' then // 追加ヘッダを足す
    begin
      Self.send(Trim(head) + #13#10);
    end;
    // 認証
    case AuthMode of
      httpBASIC:
        begin
          Self.SendLn('Authorization: Basic '+GetBasicAuth);
        end;
      httpDigest:
        begin
          raise Exception.Create('未対応');
          Self.SendLn('Authorization: Digest '+GetDigestAuth(url, 'GET'));
        end;
    end;

    if FUserAgent <> '' then Self.SendLn('User-Agent: ' + FUserAgent);

    // 区切り
    Self.SendLn('Content-Length:' + IntToStr(Length(Trim(data))));
    Self.SendLn('');

    // データを送信する
    Self.send(Trim(data));
    Self.send(#13#10#13#10);

    // レスポンスを得る
    ret := Self.RecvToCRLFCRLF; // head
    h := THttpHeadList.Create;
    h.SetAsText(ret);

    // Set-Cookieがあるか？
    CheckCookie(h);
    Result := ret;

    // Content-Length があるか？
    p := h.Find('Content-Length');
    if p <> nil then
    begin
      len := StrToIntDef(p.Value, -1);
      if len > 0 then
      begin
        ret := Self.RecvData(len);
        Result := Result + #13#10#13#10 + ret;
      end;
    end else
    if (h.Find('Content-Encoding') <> nil) and (h.Find('Content-Encoding').value = 'chunked') then
    begin
      // chunkにしたがって受信する
      // とりあえず、ヘッダの後ろに改行追加
      Result := Result + #13#10#13#10;
      while true do
      begin
        // chunkサイズの行を取得
        s := Self.RecvLn;
        // パラメータを捨てる
        s := getToken_s(s,';');
        // サイズ(16進数)を取得
        len := StrToIntDef('$'+s,-1);
        // サイズが0なら終了マークなのでループを抜ける
        if len = 0 then break;
        // chunkサイズ分だけ受信する
        ret := Self.RecvData(len);
        Result := Result + ret;
        // 直後に改行があるはずなので読取＆チェック
        ret := Self.RecvLn;
        if ret <> '' then break;
      end;
      // ヘッダと改行があるはずなので読み取る。ほんとはヘッダに加えるべき？
      ret := RecvToCRLFCRLF;
    end else begin
      ret := Self.RecvDataToEnd;
      Result := Result + #13#10#13#10 + ret;
    end;

    // 読み残りをクリア
    Self.ClearBuffer;

  finally
    Close;
  end;

end;

function TKHttpClient.Post(url: string; Data: THttpHeadList): string;
var
  head, b: string;
begin
  b := Data.GetBoundary;
  head := 'Content-Type: multipart/form-data; boundary=' + b;
  Result := Self.Post(url, head, Data.GetAsText(b));
end;

procedure TKHttpClient.CheckCookie(headList: THttpHeadList);
var
  i: Integer;
  p: THttpHead;
  s, name, value: string;
begin
  for i := 0 to headList.Count - 1 do
  begin
    p := headList.Items[i];
    if (UpperCase(p.Key) = 'SET-COOKIE') then
    begin
      s := p.Value;
      name  := Trim(getToken_s(s, '='));
      value := Trim(getToken_s(s, ';'));
      Cookie.AddKey(name, value);
    end;
  end;
end;

{ THttpHeadList }

procedure THttpHeadList.AddKey(key, value: string);
var
  h: THttpHead;
begin
  h := Self.Find(key);
  if h = nil then
  begin
    h := THttpHead.Create;
    h.Key := key;
    h.Value := value;
    Self.Add(h);
  end else
  begin
    h.Value := value;
  end;
end;

procedure THttpHeadList.Clear;
var
  i: Integer;
  h: THttpHead;
begin
  for i := 0 to Count - 1 do
  begin
    h := Items[i];
    FreeAndNil(h);
  end;
  inherited;
end;

constructor THttpHeadList.Create;
begin
  FRetCode := #13#10;
  FResponse := -1;
  inherited;
end;

function THttpHeadList.Find(key: string): THttpHead;
var
  i: Integer;
  h: THttpHead;
begin
  Result := nil;
  key := UpperCase(key);
  for i := 0 to Count - 1 do
  begin
    h := Items[i];
    if UpperCase(h.Key) = key then
    begin
      Result := h; Break;
    end;
  end;
end;

function THttpHeadList.GetAsText(boundary: string): string;
var
  i: Integer;
  h: THttpHead;
begin
  Result := '';
  for i := 0 to Count - 1 do
  begin
    h := Items[i];
    Result := '--' + boundary + #13#10 +
              'Content-Disposition: form-data; name="' + h.Key + '";'#13#10#13#10 +
              h.Value;
  end;
  Result := Result + '--' + boundary + '--'; // end
end;

function THttpHeadList.GetBoundary: string;
begin
  Result := '-----------------__' + IntToHex(Random(65536),4) + '__' +
            FormatDateTime('yymmddhhnnsszzz', Now) + '--';
end;

function THttpHeadList.GetValue(key: string): string;
var
  h: THttpHead;
begin
  h := Find(key);
  if h <> nil then Result := h.Value else Result := '';
end;

procedure THttpHeadList.SetAsText(s: string);
var
  line: string;
  h: THttpHead;
begin
  Self.Clear;

  // 一行目レスポンスコード
  line := getToken_s(s, RetCode);
  if line <> '' then
  begin
    FHttpVersion := getToken_s(line, ' ');
    FResponse    := StrToIntDef(getToken_s(line, ' '), 0);
  end;

  //二行目以降
  while s <> '' do
  begin
    line := getToken_s(s, RetCode);
    // 続きがある
    while (s <> '')and(s[1] in [' ',#9]) do
    begin
      line := line + RetCode + getToken_s(s, RetCode);
    end;
    // ---
    if line = '' then //ヘッダの区切り・・・終わり
    begin
      Break;
    end;
    // --- ヘッダへ登録
    h := THttpHead.Create;
    h.Key   := getToken_s(line, ':');
    while line <> '' do if line[1] in [' ',#9] then System.Delete(line,1,1) else Break;
    h.Value := line;
    Self.Add(h);
  end;

end;

{ THttpHead }

function THttpHead.GetSubKey(SubKey: string): string;
var
  s, mainkey, sKey, sVal: string;
  p: PChar;
begin
{WWW-Authenticate: Digest realm="Secret Zone",
  nonce="RMH1usDrAwA=6dc290ea3304de42a7347e0a94089ff5912ce0de",
  algorithm=MD5, qop="auth"}

  // get Value
  s := Value;

  // get MainKey
  mainkey := getToken_s(s, ' ');
  SubKey := UpperCase(SubKey);
  if SubKey = '' then
  begin
    Result := Trim(mainKey); Exit;
  end;
  // get sub
  p := PChar(s);
  while p^ <> #0 do
  begin
    sKey := UpperCase(Trim(getTokenCh(p, ['='])));
    skipSpace(p);
    if p^ = '"' then
    begin
      sVal := getTokenCh(p, ['"']);
    end else
    if p^ = '''' then
    begin
      sVal := getTokenCh(p, ['''']);
    end else
    begin
      sVal := getTokenCh(p, [' ',#9, #13,#10]);
    end;
    if sKey = SubKey then
    begin
      Result := sVal; Exit;
    end;
    skipSpace(p);
    while p^ in [#13,#10,#9,' ',';',','] do Inc(p);
  end;
  Result := '';
end;

end.
