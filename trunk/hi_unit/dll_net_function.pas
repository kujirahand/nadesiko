unit dll_net_function;

interface

uses
  Windows, SysUtils, Classes, UrlMon, WinInet, kskFtp, SyncObjs,
  dll_plugin_helper, dnako_import, dnako_import_types,
  winsock,unit_eml,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdFTPCommon,
  IdFTP, IdFTPList, IdHttp, IdTcpServer, IdSNTP, IdSMTP,
  IdMessage,
  //IdAllFTPListParsers,
  IdPOP3,
  IdReplyPOP3,
  IdSASLLogin,
  IdAttachmentFile,
  IdMessageParts,
  IdUserPassProvider, IdSSLOpenSSL, IdExplicitTLSClientServerBase,
  IdLogFile;

const
  NAKONET_DLL_VERSION = '1.511';

type
  TNetDialogStatus = (statWork, statError, statComplete, statCancel);

  TNetDialog = class(TComponent)
  private
    hParent: HWND;
    hProgress: HWND;
    WorkCount: Integer;
  public
    target: string;
    ResultData: string;
    errormessage: string;
    Status: TNetDialogStatus;
    procedure WorkBegin(Sender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure WorkEnd(Sender: TObject; AWorkMode: TWorkMode);
    procedure Work(Sender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    function ShowDialog(stext, sinfo: AnsiString; Visible: Boolean): Boolean;
    procedure setInfo(s: string);
    procedure setText(s: string);
    procedure Cancel;
    procedure Comlete;
    procedure Error;
  end;

  TNetThread = class(TThread)
  protected
    critical: TCriticalSection;
    procedure Execute; override;
  public
    method: procedure (Sender: TNetThread; ptr: Pointer);
    arg0: Pointer;
    arg1: Pointer;
    arg2: Pointer;
    arg3: Pointer;
    arg4: Pointer;
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;
  end;

function NetDialog:TNetDialog;
function get_on_off(str: string): Boolean;
procedure alert(msg: AnsiString);

procedure RegistFunction;

implementation

uses mini_file_utils, unit_file, KPop3, KSmtp, KTcp, KTCPW, unit_string2,
  WSockUtils, Icmp, KHttp, jconvert, md5, nako_dialog_function,
  nadesiko_version, messages, nako_dialog_const, CommCtrl, unit_kabin,
  hima_types, unit_content_type, IdAttachment, unit_string, unit_date;

var pProgDialog: PHiValue = nil;
var FNetDialog: TNetDialog = nil;

const NAKO_HTTP_OPTION = 'HTTPオプション';
const FTP_NG_PATTERN   = 'FTPフォルダ除外パターン';

procedure alert(msg: AnsiString);
begin
  Windows.MessageBoxA(0, PAnsiChar(msg), 'Alert', MB_OK);
end;

function NetDialog:TNetDialog;
begin
  if FNetDialog = nil then
  begin
    FNetDialog := TNetDialog.Create(nil);
  end;
  Result := FNetDialog;
end;

function nako_http_opt_get(name: string): string;
var
  p: PHiValue;
  s: TStringList;
begin
  p := nako_getVariable(NAKO_HTTP_OPTION);
  s := TStringList.Create;
  s.Text := string(hi_str(p));
  Result := Trim(s.Values[name]);
  s.Free;
end;

function http_opt_useBasicAuth: Boolean;
var
  s: string;
begin
  s := nako_http_opt_get('BASIC認証');
  if (s = 'オフ') or (s = '0') or (s = '０') or (s = 'いいえ') or (s = '')then
  begin
    Result := False;
  end else
  begin
    Result := True;
  end;
end;

function http_opt_getId: string;
begin
  Result := nako_http_opt_get('ID');
end;

function http_opt_getPassword: string;
begin
  Result := nako_http_opt_get('パスワード');
  if Result = '' then
  begin
    Result := nako_http_opt_get('PASSWORD');
  end;
end;

function http_opt_getUA: string;
begin
  Result := nako_http_opt_get('UA');
  if Result = '' then
  begin
    Result := 'nadesiko';
  end;
end;

function http_opt_getHttpVersion: string;
begin
  Result := nako_http_opt_get('HTTP_VERSION');
  if Result = '' then
  begin
    Result := 'HTTP/1.1';
  end;
end;

function http_opt_getTimeout: Integer;
var
  s: string;
begin
  s := nako_http_opt_get('TIMEOUT');
  Result := StrToIntDef(s, 60);
end;

// HTTP/HTTPS 対応
function sys_http_download(args: DWORD): PHiValue; stdcall;
var
  a, b: PHiValue;
  url, local: AnsiString;
  h: TkskHttpDialog;

begin
  a := nako_getFuncArg(args, 0);
  b := nako_getFuncArg(args, 1);

  url   := hi_str(a);
  local := hi_str(b);

  // スレッドを使ってアクセス
  h := TkskHttpDialog.Create;
  try
    kskFtp.MainWindowHandle := nako_getMainWindowHandle;
    h.UseBasicAuth  := http_opt_useBasicAuth;
    h.id            := AnsiString(http_opt_getId);
    h.password      := AnsiString(http_opt_getPassword);
    h.UserAgent     := AnsiString(http_opt_getUA);
    h.UseDialog     := hi_bool(pProgDialog);
    h.httpVersion   := AnsiString(http_opt_getHttpVersion);
    h.DownloadDialog(url);
    h.Stream.SaveToFile(string(local));
  finally
    h.Free;
  end;

  Result := nil;
end;

// HTTP/HTTPS 対応
function sys_http_downloaddata(args: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
  url, local, s: AnsiString;

  procedure subDownload;
  begin
    // 何らかの理由で標準命令が使えなかったときに使うサブメソッド
    local := AnsiString(TempDir + 'temp');
    if URLDownloadToFileA(nil, PAnsiChar(url), PAnsiChar(local), 0, nil) <> s_ok then
    begin
      raise Exception.Create(string(url)+'をダウンロードできませんでした。');
    end;
    s := FileLoadAll(local);
    if FileExists(string(local)) then DeleteFile(string(local));
  end;

  procedure _download;
  var
    h: TkskHttpDialog;
  begin
    // スレッドを使ってアクセス
    h := TkskHttpDialog.Create;
    try
      kskFtp.MainWindowHandle := nako_getMainWindowHandle;
      h.UseBasicAuth := http_opt_useBasicAuth;
      h.id       := AnsiString(http_opt_getId);
      h.password := AnsiString(http_opt_getPassword);
      h.UserAgent     := AnsiString(http_opt_getUA);
      h.UseDialog     := hi_bool(pProgDialog);
      if h.DownloadDialog(url) then
      begin
        SetLength(s, h.Stream.Size);
        h.Stream.Position := 0;
        h.Stream.Read(s[1], h.Stream.Size);
      end else
      begin
        s := '';
      end;
    finally
      h.Free;
    end;
  end;

begin
  a := nako_getFuncArg(args, 0);

  url   := hi_str(a);

  try
    _download;
  except
    subDownload;
  end;
  Result := hi_newStr(s);
  
end;

function sys_http_downloadhead(args: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
  url, s: AnsiString;
  http: TkskHttp; // WinInet 使用
begin
  a := nako_getFuncArg(args, 0);
  url   := hi_str(a);

  http := TkskHttp.Create;
  try
    s := http.GetHeader(url);
  except on E: Exception do
    // 何らかの理由で標準命令が使えなかったとき
    raise Exception.Create('ヘッダが取得できませんでした。' + e.Message);
  end;
  http.Free;

  Result := hi_newStr(s);
end;

function sys_http_downloadhead2(args: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
  url, s: AnsiString;
  http: TKHttpClient; // 独自仕様
begin
  a := nako_getFuncArg(args, 0);
  url   := hi_str(a);

  http :=TKHttpClient.Create(nil);
  try
    try
      http.GetProxySettingFromRegistry; // レジストリからProxyを読む
      s := AnsiString(http.Head(string(url)));
    except
      on E: Exception do
        // 何らかの理由で標準命令が使えなかったとき
        raise Exception.Create('ヘッダが取得できませんでした。' + e.Message);
    end;
  finally
    http.Free;
  end;

  Result := hi_newStr(s);
end;

var _idftp: Tidftp = nil;
var _idftp_logfile:TIdLogFile = nil;

function get_on_off(str: string): Boolean;
begin
  str := JReplaceW(str, 'オン','1');
  str := JReplaceW(str, 'オフ','0');
  str := JReplaceW(str, 'はい','1');
  str := JReplaceW(str, 'いいえ','0');
  str := JReplaceW(str, '１','1');
  str := JReplaceW(str, '０','0');
  Result := (StrToIntDef(string(str), 0) <> 0);
end;

function sys_ftp_connect(args: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
  s : TStringList;
begin
  ps := nako_getFuncArg(args, 0);
  s  := TStringList.Create;
  s.Text := hi_strU(ps);

  _idftp := Tidftp.Create(nil);
  if _idftp_logfile <> nil then // logfile
  begin
    _idftp.Intercept := _idftp_logfile;
    _idftp_logfile.Active := True;
  end;

  _idftp.Username  := Trim(s.Values['ID']);
  _idftp.Password  := Trim(s.Values['パスワード']);
  if _idftp.Password = '' then _idftp.Password := Trim(s.Values['PASSWORD']);
  _idftp.Host      := Trim(s.Values['ホスト']);
  if _idftp.Host = '' then _idftp.Host := Trim(s.Values['HOST']);
  _idftp.Port      := StrToIntDef(Trim(s.Values['PORT']), 21);
  if Trim(s.Values['PASV']) <> '' then
  begin
    _idftp.Passive   := get_on_off(Trim(s.Values['PASV']));
  end else begin
    _idftp.Passive := True;
  end;
  _idftp.TransferType := ftBinary; // 重要
  
  if _idftp.Username = '' then raise Exception.Create('FTPの設定でIDが未設定です。');
  if _idftp.Password = '' then raise Exception.Create('FTPの設定でPASSWORDが未設定です。');
  if _idftp.Host     = '' then raise Exception.Create('FTPの設定でHOSTが未設定です。');
  try
    _idftp.Connect;
    _idftp.OnWorkBegin := NetDialog.WorkBegin;
    _idftp.OnWork      := NetDialog.Work;
    _idftp.OnWorkEnd   := NetDialog.WorkEnd;
  except
    on e: Exception do
      raise Exception.Create('FTPで接続ができませんでした。' + e.Message);
  end;

  FreeAndNil(s);
  Result := nil;
end;

function sys_ftp_disconnect(args: DWORD): PHiValue; stdcall;
begin
  if _idftp <> nil then
  begin
    if _idftp.Connected then
    begin
      try _idftp.Abort;      except end;
      try _idftp.Disconnect; except end;
    end;
  end;
  FreeAndNil(_idftp);
  FreeAndNil(_idftp_logfile);
  Result := nil;
end;

procedure proc_ftp_upload(Sender: TNetThread; ptr: Tidftp);
var
  fs: TFileStream;
  pfname: PString;
  ps: PString;
  localname: string;
  servername: string;
begin
  pfname := Sender.arg1;
  ps     := Sender.arg2;
  localname  := PString(pfname)^;
  servername := PString(ps)^;

  try
    fs := TFileStream.Create(localname, fmOpenRead or fmShareDenyWrite);
    fs.Position := 0;
  except
    on e:Exception do
    begin
      NetDialog.errormessage := e.Message;
      NetDialog.Cancel;
      Exit;
    end;
  end;

  try
    try
      ptr.Put(fs, servername);
    except
      on e:Exception do
      begin
        NetDialog.errormessage := e.Message;
        NetDialog.Cancel;
        Exit;
      end;
    end;
  finally
    FreeAndNil(fs);
    NetDialog.Comlete;
  end;
end;


procedure proc_ftp_uploadDir(Sender: TNetThread; ftp: Tidftp);
var
  local, remote, pat: string;

  procedure _upload(local, remote: string);
  var
    dirs, files: TStringList;
    tmp: string;
    i: Integer;
    flgSubDir: Boolean;
  begin
    // make dir
    flgSubDir := False;
    if remote <> '' then
    begin
      try
        ftp.MakeDir(remote);
      except
      end;
      ftp.ChangeDir(remote);
      flgSubDir := True;
    end;
    // file
    files := EnumFiles(local + '*');
    try
      for i := 0 to files.Count - 1 do
      begin
        tmp := files.Strings[i];
        if pat <> '' then
        begin
          if MatchesMaskEx(AnsiString(tmp), AnsiString(pat)) then Continue;
        end;
        ftp.Put(local + tmp, tmp);
      end;
    finally
      files.Free;
    end;
    // dir
    dirs := EnumDirs(local + '*');
    try
      for i := 0 to dirs.Count - 1 do
      begin
        tmp := dirs.Strings[i];
        if pat <> '' then
        begin
          if MatchesMaskEx(AnsiString(tmp), AnsiString(pat)) then Continue;
        end;
        _upload(local + tmp + '\', tmp);
      end;
    finally
      dirs.Free;
    end;
    if flgSubDir then
    begin
      ftp.ChangeDirUp;
    end;
  end;

begin
  pat    := hi_strU(nako_getVariable(FTP_NG_PATTERN));

  local  := PString(Sender.arg1)^;
  remote := PString(Sender.arg2)^;


  if Copy(local, Length(local), 1) <> '\' then
  begin
    local := local + '\';
  end;

  if DirectoryExists(local) = False then
  begin
    raise Exception.Create('「' + local + '」は存在しないフォルダ名です。');
  end;

  _upload(local, remote);

  NetDialog.Comlete;
end;

function sys_ftp_setTimeout(args: DWORD): PHiValue; stdcall;
var
  i: Integer;
begin
  i := getArgInt(args, 0);
  if _idftp = nil then raise Exception.Create('この命令の前に『FTP接続』で接続してください。');
  _idftp.ReadTimeout := i;
  Result := nil;
end;

function sys_ftp_upload(args: DWORD): PHiValue; stdcall;
var
  pLocal, pRemote: PHiValue;
  fname,remote: AnsiString;
  uploader: TNetThread;
  bShow: Boolean;
begin
  pLocal  := nako_getFuncArg(args, 0);
  pRemote := nako_getFuncArg(args, 1);

  if _idftp = nil then raise Exception.Create('アップロードの前に『FTP接続』で接続してください。');
  _idftp.Tag := hi_int(pProgDialog);
  try
    fname := hi_str(pLocal);
    if CheckFileExists(fname) = False then
    begin
      raise Exception.CreateFmt('アップロード対象ファイル"%s"がありません。',[fname]);
    end;
    remote := hi_str(pRemote);
    try
      if _idftp.Connected = False then raise Exception.Create('接続していません。');
      uploader := TNetThread.Create(True);
      bShow := hi_bool(nako_getVariable('経過ダイアログ'));
      uploader.arg0 := _idftp;
      uploader.arg1 := @fname;
      uploader.arg2 := @remote;
      uploader.method := @proc_ftp_upload;
      uploader.FreeOnTerminate := True;
      uploader.Resume;
      if False = NetDialog.ShowDialog('FTPアップロード', hi_str(pRemote)+'へアップ中', bShow) then
      begin
        try
          _idftp.Abort;
        except end;
        raise Exception.Create('ユーザーにより中断ボタンが押されました。');
      end;
    except
      raise;
    end;
  except
    on e: Exception do
    begin
      raise Exception.Create('FTPアップロードに失敗。' + e.Message);
    end;
  end;
  Result := nil;
end;

function sys_ftp_uploadDir(args: DWORD): PHiValue; stdcall;
var
  pLocal, pRemote: PHiValue;
  fname, remote: string;
  uploader: TNetThread;
  bShow: Boolean;
begin
  pLocal  := nako_getFuncArg(args, 0);
  pRemote := nako_getFuncArg(args, 1);

  if _idftp = nil then raise Exception.Create('アップロードの前に『FTP接続』で接続してください。');
  _idftp.Tag := hi_int(pProgDialog);
  try
    fname := hi_strU(pLocal);
    if DirectoryExists(fname) = False then
    begin
      raise Exception.CreateFmt('アップロード対象ファイル"%s"がありません。',[fname]);
    end;
    remote := hi_strU(pRemote);
    try
    try
      if _idftp.Connected = False then raise Exception.Create('接続していません。');
      uploader := TNetThread.Create(True);
      bShow := hi_bool(nako_getVariable('経過ダイアログ'));
      uploader.arg0 := _idftp;
      uploader.arg1 := @fname;
      uploader.arg2 := @remote;
      uploader.method := @proc_ftp_uploadDir;
      uploader.FreeOnTerminate := True;
      uploader.Resume;
      if False = NetDialog.ShowDialog('FTP一括アップロード', hi_str(pRemote)+'へアップ中', bShow) then
      begin
        try
          _idftp.Abort;
        except end;
        raise Exception.Create('ユーザーにより中断ボタンが押されました。');
      end;
    except
      raise;
    end;
    finally
    end;
  except
    on e: Exception do
    begin
      raise Exception.Create('FTPアップロードに失敗。' + e.Message);
    end;
  end;
  Result := nil;
end;


function sys_ftp_mode(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  s: AnsiString;
begin
  p  := nako_getFuncArg(args, 0);
  s  := hi_str(p);

  //if _kskFtp = nil then raise Exception.Create('モード設定の前に『FTP接続』で接続してください。');
  if _idftp = nil then raise Exception.Create('モード設定の前に『FTP接続』で接続してください。');

  //if s <> 'アスキー' then _kskFtp.Mode := FTP_TRANSFER_TYPE_BINARY
  //                   else _kskFtp.Mode := FTP_TRANSFER_TYPE_ASCII;

  if s <> 'アスキー' then _idftp.TransferType := ftBinary
                     else _idftp.TransferType := ftAscii;

  Result := nil;
end;


function sys_ftp_upCurDir(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  s: AnsiString;
begin
  p  := nako_getFuncArg(args, 0);
  s  := hi_str(p);

  if _idftp = nil then raise Exception.Create('モード設定の前に『FTP接続』で接続してください。');
  _idftp.ChangeDirUp;
  Result := nil;
end;


procedure proc_ftp_download(Sender: TNetThread; ptr: Tidftp);
var
  dat: TMemoryStream;
  ps: PString;
begin
  dat := TMemoryStream(Sender.arg1);
  ps  := Sender.arg2;
  _idftp.Get(ps^, dat);
  NetDialog.Comlete;
end;

procedure proc_ftp_downloadDir(Sender: TNetThread; ftp: Tidftp);
var
  local, remote, pat: string;
  isError: Boolean;
  errors: string;

  procedure _getDir(_local, _remote: string);
  var
    tmp: string;
    dirs, saiki: TStringList;
    i: Integer;
    item: TIdFTPListItem;
    f: TSearchRec;
    d1, d2: TDateTime;
    i1, i2: LongInt;
  begin
    if isError then Exit;
    if Sender.Terminated then Exit;

    // enum dirs
    saiki := TStringList.Create;
    dirs  := TStringList.Create;
    try
      try
        NetDialog.setInfo('処理:' + _remote);
        NetDialog.target := '移動:' + _remote;
        ftp.ChangeDir(_remote);
        NetDialog.target := '一覧の取得:' + _remote;
        ftp.List(dirs);
        if dirs.Count = 0 then Exit;

        for i := 0 to ftp.DirectoryListing.Count - 1 do
        begin
          item := ftp.DirectoryListing.Items[i];
          if (item.ItemType = ditFile) and
             (item.ModifiedDate > 0) then
          begin
            tmp := item.FileName;
            if MatchesMaskEx(AnsiString(tmp), AnsiString(pat)) then Continue;
            if tmp <> '' then
            begin
              NetDialog.target :=
                IntToStr(i+1) + '/' + IntToStr(ftp.DirectoryListing.Count) + ',' +
                Copy(tmp, 1, 12) + '..';
            end;
            // --- 差分ダウンロード
            if FileExists(_local + tmp) then
            begin
              if FindFirst(_local + tmp, faAnyFile, f) = 0 then
              begin
                {$WARN SYMBOL_PLATFORM OFF}
                d1 := FileTimeToDateTimeEx(f.FindData.ftLastWriteTime);
                d2 := item.ModifiedDate;
                i1 := DelphiDateTimeToUNIXTime(d1);
                i2 := DelphiDateTimeToUNIXTime(d2);
                if Abs(i1 - i2) < 30 then // 誤差30秒は許容する
                begin
                  if f.Size = item.Size then
                  begin
                    FindClose(f);
                    Continue;
                  end;
                end;
                DeleteFile(_local + tmp);
              end;
              FindClose(f);
            end;
            // --- ダウンロード
            try
              ftp.Get(tmp, _local + tmp);
              SetFileTimeEx(_local + tmp, item.ModifiedDate, item.ModifiedDate, item.ModifiedDate);
            except
              on e: Exception do
              begin
                errors := errors + tmp + ':' + e.Message + #13#10;
                // continue;
              end;
            end;
          end else
          if (item.ItemType = ditDirectory) and
             (item.ModifiedDate > 0) then
          begin
            tmp := item.FileName;
            if (tmp = '.')or(tmp = '..') then Continue;
            saiki.Add(tmp);
          end;
        end;
        for i := 0 to saiki.Count - 1 do
        begin
          tmp := saiki.Strings[i];
          ForceDirectories(_local + tmp + '\');
          _getDir(_local + tmp + '\', tmp);
        end;
        NetDialog.setText('ディレクトリを上に移動');
        ftp.ChangeDirUp;
      except
        on e:Exception do
        begin
          isError := True;
          errors := errors + _remote + ':' + e.Message + #13#10;
          Exit;
        end;
      end;
    finally
      dirs.Free;
      saiki.Free;
    end;
  end;

begin
  //
  local  := PString(Sender.arg1)^;
  remote := PString(Sender.arg2)^;

  pat := hi_strU(nako_getVariable(FTP_NG_PATTERN));

  isError := False;
  errors := '';

  if Copy(local, Length(local), 1) <> '\' then
  begin
    local := local + '\';
  end;
  if not DirectoryExists(local) then
  begin
    ForceDirectories(local);
  end;
  _getDir(local, remote);
  //
  NetDialog.errormessage := errors;
  NetDialog.Comlete;
end;


function sys_ftp_download(args: DWORD): PHiValue; stdcall;
var
  pLocal, pRemote: PHiValue;
  dat: TMemoryStream;
  fname, remote: string;
  thread: TNetThread;
  bShow: Boolean;
begin
  pRemote := nako_getFuncArg(args, 0);
  pLocal  := nako_getFuncArg(args, 1);

  if _idftp = nil then raise Exception.Create('ダウンロードの前に『FTP接続』で接続してください。');

  _idftp.Tag := hi_int(pProgDialog);
  dat := TMemoryStream.Create;
  try
    fname  := hi_strU(pLocal);
    remote := hi_strU(pRemote);

    NetDialog.errormessage := '';

    thread  := TNetThread.Create(True);
    bShow   := hi_bool(nako_getVariable('経過ダイアログ'));
    thread.arg0 := _idftp;
    thread.arg1 := dat;
    thread.arg2 := @remote;
    thread.method := @proc_ftp_download;
    thread.FreeOnTerminate := True;
    thread.Resume;
    if False = NetDialog.ShowDialog('FTPダウンロード', hi_str(pRemote)+'からダウンロード中', bShow) then
    begin
      try
        _idftp.Abort;
      except end;
      raise Exception.Create('ユーザーにより中断ボタンが押されました。');
    end;

    dat.SaveToFile(fname);
  except
    on e: Exception do
    begin
      raise Exception.Create('FTPダウンロードに失敗。' + e.Message);
    end;
  end;
  FreeAndNil(dat);

  Result := nil;
end;

function sys_ftp_downloadDir(args: DWORD): PHiValue; stdcall;
var
  pLocal, pRemote: PHiValue;
  fname, remote: AnsiString;
  thread: TNetThread;
  bShow: Boolean;
begin
  pRemote := nako_getFuncArg(args, 0);
  pLocal  := nako_getFuncArg(args, 1);

  if (_idftp = nil)or(not _idftp.Connected) then raise Exception.Create('ダウンロードの前に『FTP接続』で接続してください。');

  _idftp.Tag := hi_int(pProgDialog);
  try
    fname  := hi_str(pLocal);
    remote := hi_str(pRemote);
    
    NetDialog.errormessage := '';

    thread  := TNetThread.Create(True);
    bShow   := hi_bool(nako_getVariable('経過ダイアログ'));
    thread.arg0 := _idftp;
    thread.arg1 := @fname;
    thread.arg2 := @remote;
    thread.method := @proc_ftp_downloadDir;
    thread.FreeOnTerminate := True;
    thread.Resume;
    if False = NetDialog.ShowDialog('FTP一括ダウンロード', hi_str(pRemote)+'からダウンロード中', bShow) then
    begin
      try
        _idftp.Abort;
      except end;
      raise Exception.Create('ユーザーにより中断ボタンが押されました。');
    end;
    if NetDialog.errormessage <> '' then
    begin
      raise Exception.Create(NetDialog.errormessage);
    end;
  except
    on e: Exception do
    begin
      raise Exception.Create('FTPダウンロードに失敗。' + e.Message);
    end;
  end;

  Result := nil;
end;

function sys_ftp_glob(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  s, res, tmp: string;
  sl: TStringList;
  i: Integer;
  item: TIdFTPListItem;
begin
  p := nako_getFuncArg(args, 0);
  s := hi_strU(p);
  Result := nil;

  if _idftp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  sl := TStringList.Create;
  try
    try
      _idftp.List(sl, s, True); // 詳細モードにしないとディレクトリかどうか判定できない
      res := '';
      for i := 0 to _idftp.DirectoryListing.Count - 1 do
      begin
        item := _idftp.DirectoryListing.Items[i];
        if (_idftp.DirectoryListing.Items[i].ItemType = ditFile) then
        begin
          tmp := item.FileName;
          if (tmp = '.')or(tmp = '..') then Continue;
          res := res + tmp + #13#10;
        end;
      end;
      Result := hi_newStr(AnsiString(res));
    except
      on e:Exception do
        raise Exception.Create(e.Message);
    end;
  finally
    sl.Free;
  end;
end;



function sys_ftp_glob2(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  s, res: string;
begin
  p := nako_getFuncArg(args, 0);
  s := hi_strU(p);
  if _idftp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  try
    _idftp.List(s);
    res := _idftp.ListResult.Text;
    Result := hi_newStrU(res);
  except on e: Exception do
    raise Exception.Create('FTPでディレクトリ一覧の取得に失敗しました。' + e.Message);
  end;
end;


function sys_ftp_globDir(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  s, res, tmp: string;
  sl: TStringList;
  i: Integer;
begin
  p := nako_getFuncArg(args, 0);
  s := hi_strU(p);

  if _idftp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  sl := TStringList.Create;
  try
    _idftp.List(sl, s, True);
    res := '';
    for i := 0 to _idftp.DirectoryListing.Count - 1 do
    begin
      if (_idftp.DirectoryListing.Items[i].ItemType = ditDirectory) and
         (_idftp.DirectoryListing.Items[i].ModifiedDate > 0) then
      begin
        tmp := _idftp.DirectoryListing.Items[i].FileName;
        if (tmp = '.')or(tmp = '..') then Continue;
        res := res + tmp + #13#10;
      end;
    end;
    Result := hi_newStrU(res);
  except
    Result := hi_newStr('');
    sl.Free;
  end;
  sl.Free;
end;

function sys_ftp_mkdir(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  s: string;
begin
  p := nako_getFuncArg(args, 0);
  s := hi_strU(p);

  if _idftp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  _idftp.MakeDir(s);

  Result := nil;
end;

function sys_ftp_rmdir(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  s: string;
begin
  p := nako_getFuncArg(args, 0);
  s := hi_strU(p);

  //if _kskFtp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  //_kskFtp.DeleteDir(s);

  if _idftp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  _idftp.RemoveDir(s);

  Result := nil;
end;

function sys_ftp_changeDir(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  s: string;
begin
  p := nako_getFuncArg(args, 0);
  s := hi_strU(p);

  //if _kskFtp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  //_kskFtp.ChangeDir(s);

  if _idftp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  _idftp.ChangeDir(s);

  Result := nil;
end;

function sys_ftp_getCurDir(args: DWORD): PHiValue; stdcall;
begin
  //if _kskFtp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  //s := _kskFtp.CurrentDir;
  if _idftp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  //
  Result := hi_newStrU(_idftp.RetrieveCurrentDir);
end;

function sys_ftp_delFile(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  s: string;
begin
  p := nako_getFuncArg(args, 0);
  s := hi_strU(p);

  //if _kskFtp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  //_kskFtp.DeleteFile(s);
  if _idftp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  _idftp.Delete(s);

  Result := nil;
end;

function sys_ftp_rename(args: DWORD): PHiValue; stdcall;
var
  pa, pb: PHiValue;
begin
  pa := nako_getFuncArg(args, 0);
  pb := nako_getFuncArg(args, 1);

  //if _kskFtp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  //_kskFtp.RanemeFile(hi_str(pa), hi_str(pb));

  if _idftp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  _idftp.Rename(hi_strU(pa), hi_strU(pb));


  Result := nil;
end;

function sys_ftp_command(args: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
  i:smallint;
  res:string;
begin
  ps := nako_getFuncArg(args, 0);
  res:='';
  {
  if _kskFtp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  if not _kskFtp.Command(hi_str(ps), True, res) then
  begin
    raise Exception.Create('コマンド"' + hi_str(ps) + '"に失敗。');
  end;
  }
  if _idftp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  try
    i:=_idftp.Quote(hi_strU(ps));
  except
    raise Exception.Create('コマンド"' + hi_strU(ps) + '"に失敗。');
  end;
  Result := hi_newStrU(IntToStr(i)+' '+_idftp.LastCmdResult.Text.Text);
end;

function sys_ftp_chmod(args: DWORD): PHiValue; stdcall;
var
  ps, pa: PHiValue;
  s, a, cmd: string;
begin
  ps := nako_getFuncArg(args, 0);
  pa := nako_getFuncArg(args, 1);

  s := Trim(hi_strU(ps));
  a := Trim(hi_strU(pa));

  //if _kskFtp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');

  if _idftp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  cmd := 'CHMOD ' + a + ' ' + s;
  {
  if not _kskFtp.Command(cmd, False, res) then
  begin
    raise Exception.Create('属性変更に失敗。');
  end;
  }
  try
    _idftp.Site(cmd);
  except
    raise Exception.Create('コマンド"' + cmd + '"に失敗。');
  end;
  //
  Result := nil;
end;

function sys_ftp_setLogFile(args: DWORD): PHiValue; stdcall;
var
  f: string;
begin
  f := getArgStrU(args, 0, True);
  if _idftp_logfile = nil then
  begin
    _idftp_logfile := TIdLogFile.Create(nil);
  end;
  _idftp_logfile.Filename := f;
  Result := nil;
end;

procedure getPop3Info(pop3: TKPop3Dialog);
var
  option: string;
begin
  pop3.Host       := hi_strU(nako_getVariable('メールホスト'));
  pop3.Port       := StrToIntDef(hi_strU(nako_getVariable('メールポート')), 110);
  pop3.User       := hi_strU(nako_getVariable('メールID'));
  pop3.Password   := hi_strU(nako_getVariable('メールパスワード'));
  option          := UpperCase(hi_strU(nako_getVariable('メールオプション')));
  if Pos('APOP',option) > 0 then pop3.APop := True;
  // CHECK
  if pop3.Host = '' then raise Exception.Create('メールホストが空です。');
  if pop3.Port < 0  then raise Exception.Create('メールポートが不正な数値です。');
  if pop3.User = '' then raise Exception.Create('メールユーザーが空です。');
  if pop3.Password = '' then raise Exception.Create('メールパスワードが空です。');
end;


procedure getPop3InfoIndy(pop3: TIdPOP3);
var
  option: string;
  Login: TIdSASLLogin;
  Provider: TIdUserPassProvider;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  pop3.Host       := hi_strU(nako_getVariable('メールホスト'));
  pop3.Port       := StrToIntDef(hi_strU(nako_getVariable('メールポート')), 110);
  pop3.Username   := hi_strU(nako_getVariable('メールID'));
  pop3.Password   := hi_strU(nako_getVariable('メールパスワード'));
  option          := UpperCase(hi_strU(nako_getVariable('メールオプション')));
  pop3.AuthType := patUserPass;
  if Pos('APOP',option) > 0 then
  begin
    pop3.AuthType := patAPOP;
  end;
  if Pos('SASL', option) > 0 then
  begin
    pop3.AuthType := patSASL;
  end;
  if Pos('SSL', option) > 0 then
  begin
    // IOHandler
    SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(pop3);
    pop3.IOHandler := SSLHandler;
    // POP3.AuthType := patSASL;
    pop3.UseTLS := utUseImplicitTLS;
    // Login & Provider
    Login := TIdSASLLogin.Create(pop3);
    Provider := TIdUserPassProvider.Create(Login);
    Login.UserPassProvider := Provider;
    Provider.Username := pop3.Username;
    Provider.Password := pop3.Password;
    if Pos('IMPLICIT_TLS', option) > 0 then pop3.UseTLS := utUseImplicitTLS;
    if Pos('REQUIRE_TLS', option)  > 0 then pop3.UseTLS := utUseRequireTLS;
    if Pos('EXPLICIT_TLS', option) > 0 then pop3.UseTLS := utUseExplicitTLS;
  end;
  // CHECK
  if pop3.Host = '' then raise Exception.Create('メールホストが空です。');
  if pop3.Port <= 0  then raise Exception.Create('メールポートが不正な数値です。');
  if pop3.Username = '' then raise Exception.Create('メールユーザーが空です。');
  if pop3.Password = '' then raise Exception.Create('メールパスワードが空です。');
end;

function Popd3CheckMessageIdAsFileName(msgid: string): string;
var
  i: Integer;
  function _CheckId(ch: string): string;
  begin
    if Pos(string(ch), '<>/?"%\;:''`') > 0 then
    begin
      ch := '%' + IntToHex(Ord(ch[1]), 2);
    end;
    Result := ch;
  end;
begin
  Result := '';
  for i := 1 to Length(msgid) do
  begin
    Result := Result + (_CheckId(msgid[i]));
  end;
end;

procedure __sys_pop3_recv_indy(Sender: TNetThread; ptr: Pointer);
var
  pop3: TIdPOP3;
  msgids, msgidsNow, raw: TStringList;
  tmpDir, msgid, fmt: string;
  i: Integer;
  bRemove: Boolean;
  iFrom: Integer;
  iTo: Integer;
begin
  pop3   := TIdPOP3(ptr);
  tmpDir := PString(Sender.arg1)^;
  msgids := TStringList(Sender.arg2);
  bRemove:= hi_bool(nako_getVariable('メール受信時削除'));
  iFrom := Integer(Sender.arg3);
  iTo   := Integer(Sender.arg4);

  if Sender.Terminated then Exit;

  NetDialog.setInfo('サーバーと接続中:' + pop3.Host);
  try
    pop3.Connect;
  except
    on e: Exception do
    begin
      NetDialog.Error;
      NetDialog.errormessage := e.Message;
      Exit;
    end;
  end;
  try
    msgidsNow := TStringList.Create;
    try
      // メッセージIDの一覧を取得
      NetDialog.setInfo('UIDL一覧を取得中:' + pop3.Host);
      if pop3.UIDL(msgidsNow) then
      begin
        // save to uidl
        Sender.critical.Enter;
        try
          msgidsNow.SaveToFile(tmpDir + 'UIDL.txt');
        finally
          Sender.critical.Release;
        end;
        // 数値指定の時
        if (iTo < 0)  then
        begin
          iTo := msgidsNow.Count - 1;
        end;
        // 受信処理
        for i := iFrom to iTo do
        begin
          fmt := Format('メール受信中(%3d/%3d)',
            [(i+1),msgidsNow.Count]);
          NetDialog.setInfo(fmt);
          // 1件ずつ受信していく
          msgid := msgidsNow.Strings[i];
          getToken_s(msgid, ' ');
          msgid := Popd3CheckMessageIdAsFileName(msgid);
          raw := TStringList.Create;
          try
            // 受信済みか確認する
            if msgids.IndexOf(msgid) < 0 then
            begin // 未受信なので受信する
              if pop3.RetrieveRaw(i + 1, raw) then
              begin
                // save to .eml
                raw.SaveToFile(tmpDir + msgid + '.eml');
                msgids.Add(msgid);
              end;
            end;
            // remove
            if bRemove then
            begin
              pop3.Delete(i + 1);
            end;
          finally
            FreeAndNil(raw);
          end;
        end;
      end;
      NetDialog.Comlete;
    finally
      FreeAndNil(msgidsNow);
    end;
  except
    on e:Exception do
    begin
      NetDialog.errormessage := e.Message;
      NetDialog.Cancel;
    end;
  end;
end;

function __sys_pop3_recv_indy10(recv_dir: AnsiString; iFrom:Integer = 0; iTo:Integer = -1): PHiValue; stdcall;
var
  tmpDir, fname, txtFile: string;
  from, replyto: AnsiString;
  pop3: TIdPop3;
  eml, sub: TEml;
  txt, msgid, afile, attach_dir: AnsiString;
  msgids: TStringList;
  fs: TStringList;
  th: TNetThread;
  cnt: Integer;
const
  FILE_MSGIDS = 'msgids.___';

  procedure _recv;
  var bShow: Boolean;
  begin
    //
    pop3.OnWorkBegin := NetDialog.WorkBegin;
    pop3.OnWork      := NetDialog.Work;
    pop3.OnWorkEnd   := NetDialog.WorkEnd;
    bShow := hi_bool(nako_getVariable('経過ダイアログ'));
    //
    th := TNetThread.Create(True);
    th.arg0 := pop3;
    th.arg1 := @tmpDir;
    th.arg2 := msgids;
    th.arg3 := Pointer(iFrom);
    th.arg4 := Pointer(iTo);
    th.method := __sys_pop3_recv_indy;
    th.Resume;
    //
    if not NetDialog.ShowDialog(
      'メールの受信を準備しています', 'メールの受信', bShow) then
    begin
      raise Exception.Create('メール受信に失敗。' + NetDialog.errormessage);
    end;
  end;

  procedure _analize;
  var i, j, k: Integer;
  begin
    fs := EnumFiles(tmpDir + '*.eml');
    for i := 0 to fs.Count - 1 do
    begin
      msgid := ChangeFileExt(fs.Strings[i], '');
      fname := tmpDir + fs.Strings[i];
      txtFile := ChangeFileExt(fname, '.txt');
      if FileExists(txtFile) then Continue;

      try
        txt := '';
        eml := TEml.Create(nil);
        eml.LoadFromFile(fname);
        // msgid := eml.Header.Items['Message-Id'];
        // ヘッダ情報を取得
        from    := ExtractMailAddress(eml.Header.GetDecodeValue('From'));
        replyto := ExtractMailAddress(eml.Header.GetDecodeValue('Reply-To'));
        txt := txt + '差出人: ' + eml.Header.GetDecodeValue('From')   + #13#10;
        if (from <> replyto)and(replyto <> '') then txt := txt + '返信先: ' + replyto + #13#10;
        txt := txt + '宛先: '   + eml.Header.GetDecodeValue('To')     + #13#10;
        txt := txt + '件名: '   + eml.Header.GetDecodeValue('Subject')+ #13#10;
        txt := txt + '日付: '   + FormatDateTime('yyyy/mm/dd hh:nn:ss', eml.Header.GetDateTime('Date')) + #13#10;
        // 添付ファイルがあるか
        if eml.GetPartsCount > 0 then
        begin
          attach_dir := tmpDir + msgid + '\';
          ForceDirectories(attach_dir);
          k := 0;
          // 添付ファイルを１つずつ保存していく
          for j := 0 to eml.GetPartsCount - 1 do
          begin
            sub := eml.GetParts(j);
            afile := sub.GetAttachFilename;
            if afile <> '' then
            begin
              sub.BodySaveAsAttachment(attach_dir + afile);
              txt := txt + '添付ファイル:' + msgid + '\' + afile + #13#10;
              Inc(k);
            end;
          end;
          if k = 0 then RemoveDir(attach_dir);
        end;
        txt := txt + #13#10;
        txt := txt + ConvertJCode(eml.GetTextBody, SJIS_OUT);
        //
        StrWriteFile(txtFile, txt);
        //---
        eml.Free;
      except on e: Exception do
        raise Exception.Create(
          'メール受信で受信したメール『' + msgid + '』の解析でエラー。' +
          e.Message);
      end;
    end;
    cnt := fs.Count;
  end;

begin
  //===================
  // 引数の取得
  tmpDir := recv_dir;
  if Copy(tmpDir, Length(tmpDir), 1) <> '\' then tmpDir := tmpDir + '\';

  //===================
  // 受信フォルダのチェック
  if not ForceDirectories(tmpDir) then
  begin
    raise Exception.Create('フォルダ『'+tmpDir+'』が作成できませんでした。');
  end;

  //
  msgids := TStringList.Create;
  pop3   := TIdPOP3.Create(nil);
  try
    cnt := 0;
    // メッセージIDの一覧をチェック
    if FileExists(tmpDir + FILE_MSGIDS) then
    begin
      msgids.LoadFromFile(tmpDir + FILE_MSGIDS);
    end;
    getPop3InfoIndy(pop3);
    // 受信処理
    _recv;
    _analize;
    msgids.SaveToFile(tmpDir + FILE_MSGIDS);
    Result := hi_newInt(cnt);
    pop3.DisconnectNotifyPeer;
  finally
    FreeAndNil(pop3);
  end;
end;

function sys_pop3_recv_indy10(args: DWORD): PHiValue; stdcall;
var
  dir: AnsiString;
begin
  dir := getArgStr(args, 0);
  Result := __sys_pop3_recv_indy10(dir);
end;

function sys_pop3_recv_indy10split(args: DWORD): PHiValue; stdcall;
var
  dir: AnsiString;
  iFrom, iTo: Integer;
begin
  dir   := getArgStr(args, 0);
  iFrom := getArgInt(args, 1);
  iTo   := getArgInt(args, 2);
  Result := __sys_pop3_recv_indy10(dir,iFrom,iTo);
end;


function sys_gmail_recv(args: DWORD): PHiValue; stdcall;
var
  account, password, dir: AnsiString;
  p_id, p_pass, p_opt, p_port, p_host: PHiValue;
begin
  // get Args
  account  := getArgStr(args, 0);
  password := getArgStr(args, 1);
  dir      := getArgStr(args, 2);
  // rewrite
  p_id   := nako_getVariable('メールID');
  p_pass := nako_getVariable('メールパスワード');
  p_opt  := nako_getVariable('メールオプション');
  p_port := nako_getVariable('メールポート');
  p_host := nako_getVariable('メールホスト');

  hi_setStr(p_id,   account);
  hi_setStr(p_pass, password);
  hi_setStr(p_host, 'pop.gmail.com');
  hi_setStr(p_opt,  'SSL');
  hi_setInt(p_port, 995);
  // recv
  Result := __sys_pop3_recv_indy10(dir);
end;

function sys_gmail_recv_split(args: DWORD): PHiValue; stdcall;
var
  iFrom, iTo: Integer;
  account, password, dir: AnsiString;
  p_id, p_pass, p_opt, p_port, p_host: PHiValue;
begin
  // get Args
  account  := getArgStr(args, 0);
  password := getArgStr(args, 1);
  dir      := getArgStr(args, 2);
  iFrom    := getArgInt(args, 3);
  iTo      := getArgInt(args, 4);
  // rewrite
  p_id   := nako_getVariable('メールID');
  p_pass := nako_getVariable('メールパスワード');
  p_opt  := nako_getVariable('メールオプション');
  p_port := nako_getVariable('メールポート');
  p_host := nako_getVariable('メールホスト');

  hi_setStr(p_id,   account);
  hi_setStr(p_pass, password);
  hi_setStr(p_host, 'pop.gmail.com');
  hi_setStr(p_opt,  'SSL');
  hi_setInt(p_port, 995);
  // recv
  Result := __sys_pop3_recv_indy10(dir, iFrom, iTo);
end;




function __yahoo_recv(args: DWORD; IsBB: Boolean): PHiValue; stdcall;
var
  account, password, dir: AnsiString;
  p_id, p_pass, p_opt, p_port, p_host: PHiValue;
begin
  // get Args
  account  := getArgStr(args, 0);
  password := getArgStr(args, 1);
  dir      := getArgStr(args, 2);
  // rewrite
  p_id   := nako_getVariable('メールID');
  p_pass := nako_getVariable('メールパスワード');
  p_opt  := nako_getVariable('メールオプション');
  p_port := nako_getVariable('メールポート');
  p_host := nako_getVariable('メールホスト');

  hi_setStr(p_id,   account);
  hi_setStr(p_pass, password);
  if IsBB then
  begin
    hi_setStr(p_host, 'ybbpop.mail.yahoo.co.jp');
  end else
  begin
    hi_setStr(p_host, 'pop.mail.yahoo.co.jp');
  end;
  hi_setStr(p_opt,  '');
  hi_setInt(p_port, 110);
  // recv
  Result := __sys_pop3_recv_indy10(dir);
end;


function sys_yahoo_recv(args: DWORD): PHiValue; stdcall;
begin
  Result := __yahoo_recv(args, False);
end;

function sys_yahoobb_recv(args: DWORD): PHiValue; stdcall;
begin
  Result := __yahoo_recv(args, True);
end;


procedure __sys_pop3_list_indy(Sender: TNetThread; ptr: Pointer);
var
  pop3: TIdPOP3;
  line, res: AnsiString;
begin
  pop3 := TIdPOP3(ptr);
  //
  res := '';
  pop3.SendCmd('LIST', IdReplyPOP3.ST_OK);
  while True do
  begin
    try
      line := pop3.IOHandler.ReadLn;
    except
      NetDialog.Cancel;
      Exit;
    end;
    if (line = '.')or(line = '') then
    begin
      Break;
    end;
    res := res + line + #13#10;
  end;
  Sender.critical.Enter;
  NetDialog.ResultData := res;
  Sender.critical.Release;
  NetDialog.Comlete;
end;

function sys_pop3_list_indy10(args: DWORD): PHiValue; stdcall;
var
  pop3: TIdPop3;
  th: TNetThread;

  procedure _recv;
  var bShow: Boolean;
  begin
    pop3.OnWorkBegin := NetDialog.WorkBegin;
    pop3.OnWork      := NetDialog.Work;
    pop3.OnWorkEnd   := NetDialog.WorkEnd;
    bShow := hi_bool(nako_getVariable('経過ダイアログ'));
    //
    th := TNetThread.Create(True);
    th.arg0 := pop3;
    th.method := __sys_pop3_list_indy;
    th.Resume;
    //
    if not NetDialog.ShowDialog(
      'メール一覧を取得しています', 'メール一覧の取得', bShow) then
    begin
      raise Exception.Create('メール一覧の取得に失敗。' + NetDialog.errormessage);
    end;
  end;

begin
  pop3   := TIdPOP3.Create(nil);
  try
    getPop3InfoIndy(pop3);
    pop3.Connect;
    _recv;
    Result := hi_newStr(NetDialog.ResultData);
  finally
    FreeAndNil(pop3);
  end;
end;

procedure __sys_pop3_dele_indy(Sender: TNetThread; ptr: Pointer);
var
  pop3: TIdPOP3;
  res: Boolean;
  no: Integer;
begin
  pop3 := TIdPOP3(ptr);
  no := PInteger(Sender.arg1)^;
  try
    res := pop3.Delete(no);
  except
    NetDialog.errormessage := 'メッセージの削除に失敗しました。';
    NetDialog.Cancel;
    Exit;
  end;
  Sender.critical.Enter;
  if res then
  begin
    NetDialog.ResultData := '1';
  end else begin
    NetDialog.ResultData := '0';
  end;
  Sender.critical.Release;
  NetDialog.Comlete;
end;

function sys_pop3_dele_indy10(args: DWORD): PHiValue; stdcall;
var
  pop3: TIdPop3;
  th: TNetThread;
  no: Integer;

  procedure _recv;
  var bShow: Boolean;
  begin
    //
    pop3.OnWorkBegin := NetDialog.WorkBegin;
    pop3.OnWork      := NetDialog.Work;
    pop3.OnWorkEnd   := NetDialog.WorkEnd;
    bShow := hi_bool(nako_getVariable('経過ダイアログ'));
    //
    th := TNetThread.Create(True);
    th.arg0 := pop3;
    th.arg1 := @no;
    th.method := __sys_pop3_dele_indy;
    th.Resume;
    //
    if not NetDialog.ShowDialog(
      'メール一覧を取得しています', 'メール一覧の取得', bShow) then
    begin
      raise Exception.Create('メール一覧の取得に失敗。' + NetDialog.errormessage);
    end;
  end;

begin
  no := getArgInt(args, 0, True);
  pop3 := TIdPOP3.Create(nil);
  try
    getPop3InfoIndy(pop3);
    pop3.Connect;
    _recv;
    pop3.DisconnectNotifyPeer;
    Result := hi_newInt(StrToIntDef(NetDialog.ResultData, 0));
  finally
    FreeAndNil(pop3);
  end;
end;

function sys_pop3_recv(args: DWORD): PHiValue; stdcall;
var
  tmpDir, dir, fname, afile, txtFile,emlFile: AnsiString;
  from, replyto: AnsiString;
  pop3: TKPop3Dialog;
  i, j, sid: Integer;
  eml, sub: TEml;
  txt, msgid: AnsiString;
  msgids: TStringList;
const
  FILE_MSGIDS = 'msgids.___';
begin
  Result := nil;
  //===================
  // 引数の取得
  dir := hi_str(nako_getFuncArg(args, 0));
  if Copy(dir, Length(dir), 1) <> '\' then dir := dir + '\';

  //===================
  // 受信フォルダのチェック
  if not ForceDirectories(dir) then
  begin
    raise Exception.Create('フォルダ『'+dir+'』が作成できませんでした。');
  end;

  //===================
  // 一時フォルダへ受信
  tmpDir := TempDir + 'pop3_' + FormatDateTime('yymmddhhnnsszzz',Now) + '\';
  ForceDirectories(tmpDir);

  //===================
  msgids := TStringList.Create;
  pop3 := TKPop3Dialog.Create(nil);
  try
    // メッセージIDの一覧をチェック
    if FileExists(dir + FILE_MSGIDS) then msgids.LoadFromFile(dir + FILE_MSGIDS);
    //
    pop3.ShowDialog := hi_bool(nako_getVariable('経過ダイアログ'));
    getPop3Info(pop3);
    // 受信処理
    try
      Result := hi_newInt(
        pop3.Pop3RecvAll(tmpDir, hi_bool(nako_getVariable('メール受信時削除')))
      );
    except
      raise;
    end;
    // 解析処理
    sid := 1;
    for i := 1 to hi_int(Result) do
    begin
      fname := tmpDir + IntToStr(i) + '.eml';
      try
        txt := '';
        eml := TEml.Create(nil);
        eml.LoadFromFile(fname);
        msgid := eml.Header.Items['Message-Id'];
        if msgid = '' then begin msgid := MD5FileS(fname); end;
        if msgids.IndexOf(msgid) >= 0 then Continue;// 既に受信済みならスキップ
        msgids.Add(msgid);
        // ヘッダ情報を取得
        from    := ExtractMailAddress(eml.Header.GetDecodeValue('From'));
        replyto := ExtractMailAddress(eml.Header.GetDecodeValue('Reply-To'));
        txt := txt + '差出人: ' + eml.Header.GetDecodeValue('From')   + #13#10;
        if (from <> replyto)and(replyto <> '') then txt := txt + '返信先: ' + replyto + #13#10;
        txt := txt + '宛先: '   + eml.Header.GetDecodeValue('To')     + #13#10;
        txt := txt + '件名: '   + eml.Header.GetDecodeValue('Subject')+ #13#10;
        txt := txt + '日付: '   + FormatDateTime('yyyy/mm/dd hh:nn:ss', eml.Header.GetDateTime('Date')) + #13#10;
        // 添付ファイルがあるか
        if eml.GetPartsCount > 0 then
        begin
          // 添付ファイルを１つずつ保存していく
          for j := 0 to eml.GetPartsCount - 1 do
          begin
            sub := eml.GetParts(j);
            if (sub.EmlType = typeApplication)or(sub.EmlType = typeImage) then
            begin
              afile := sub.GetAttachFilename;
              while FileExists(dir + afile) do afile := '_' + afile;
              sub.BodySaveAsAttachment(dir + afile);
              txt := txt + '添付ファイル:' + afile + #13#10;
            end;
          end;
        end;
        txt := txt + #13#10;
        txt := txt + ConvertJCode(eml.GetTextBody, SJIS_OUT);
        //=== SaveFileName
        while True do
        begin
          txtFile := dir + IntToStr(sid) + '.txt';
          emlFile := dir + IntToStr(sid) + '.eml';
          if FileExists(txtFile) then begin Inc(sid); Continue; end;
          Break;
        end;
        StrWriteFile(txtFile, txt);
        CopyFileA(PAnsiChar(fname), PAnsiChar(emlFile), False);
        //---
        eml.Free;
      except on e: Exception do
        raise Exception.Create('メール受信で受信したメール'+IntToStr(i)+'の解析でエラー。' + e.Message);
      end;
    end;
    msgids.SaveToFile(dir + FILE_MSGIDS); // メッセージIDの一覧を保存
  finally
    //======
    // 一時フォルダを削除
    tmpDir := Copy(tmpDir, 1, Length(tmpDir) - 1);
    SHFileDeleteComplete(tmpDir);
    //======
    pop3.Free;
    msgids.Free;
  end;
end;

function sys_pop3_list(args: DWORD): PHiValue; stdcall;
var
  pop3: TKPop3Dialog;
begin
  //Result := nil;
  pop3 := TKPop3Dialog.Create(nil);
  try
    pop3.ShowDialog := hi_bool(nako_getVariable('経過ダイアログ'));
    getPop3Info(pop3);
    Result := hi_newStr(pop3.Pop3List);
  finally
    pop3.Free;
  end;
end;


function sys_ping(args: DWORD): PHiValue; stdcall;
var
  p: TICMP;
  i: Integer;
  res: Boolean;
begin
  res := False;
  p := TICMP.Create;
  try
    p.Address := getArgStr(args, 0, True);
    i := p.Ping;
    if i >= 1 then
    begin
      res := (p.Reply.Status = IP_SUCCESS);
      //Result := hi_newBool(p.Reply.Status = IP_SUCCESS);
    end;
  finally
    p.Free;
  end;
  Result := hi_newBool(res);
end;

procedure _sys_ping_async(Sender: TNetThread; ptr: Pointer);
var
  i: Integer;
  p: TICMP;
  event, tmp: AnsiString;
  bRes: Boolean;
  function _r: AnsiString;
  begin
    if bRes then Result := '1' else Result := '0';
  end;
begin
  bRes := True;
  //
  p := TICMP(ptr);
  event := string(PAnsiChar(Sender.arg1));
  //
  try
    i := p.Ping;
    if i >= 1 then
    begin
      bRes := (p.Reply.Status = IP_SUCCESS);
    end;
  except
  end;
  // todo: 非同期イベントでマルチスレッドを考慮すること
  if bRes then
  begin
    tmp := event + '(' + _r + ')';
    nako_eval(PAnsiChar(tmp));
  end;
end;

function sys_ping_async(args: DWORD): PHiValue; stdcall;
var
  p: TICMP;
  event, host: AnsiString;
  th: TNetThread;
begin
  Result := nil;
  //
  event := getArgStr(args, 0, True);
  host  := getArgStr(args, 1);
  //
  p := TICMP.Create;
  p.Address := host;
  //
  th := TNetThread.Create(True);
  th.method := _sys_ping_async;
  th.arg0 := p;
  th.arg1 := PAnsiChar(event);
  th.Resume;
end;

var tcp_clients: Array of TNakoTcpClient;
function sys_tcp_command(args: DWORD): PHiValue; stdcall;
var
  tcpid: Integer;
  cmd, value, s: AnsiString;
  i: Integer;
  p: TNakoTcpClient;
begin
  Result := nil;
  
  if tcp_clients = nil then
  begin
    SetLength(tcp_clients, 255);
  end;

  // 引数の取得
  tcpid  := getArgInt(args, 0, True);
  cmd    := getArgStr(args, 1);
  value  := getArgStr(args, 2);

  if cmd = 'create' then
  begin
    p := TNakoTcpClient.Create(nil);
    p.InstanceName := value; // set name
    p.tcpid:= tcpid;
    tcp_clients[tcpid] := p;
  end else
  begin
    p := tcp_clients[tcpid];
    if cmd = 'connect' then
    begin
      s := value;
      try
        p.ServerAddr := PInAddr(GetHostEnt(getToken_s(s, ':')).h_addr_list^)^;
      except on e: Exception do
        raise Exception.Create('ホスト名が解決できません。' + e.Message);
      end;
      //---
      p.Port := StrToIntDef(s, 80);
      try
        p.Connect;
      except on e: Exception do
        raise Exception.Create('接続に失敗。' + e.Message);
      end;
    end else
    if cmd = 'disconnect' then p.Close else
    if cmd = 'send' then
    begin
      s := value;
      try
        p.SendString(s);
      except
        raise;
      end;
    end else
    if cmd = 'recv' then
    begin
      Result := hi_newStr(p.RecvString);
    end else
    if cmd = 'recvbyte' then
    begin
      i := StrToIntDef(value, 0);
      Result := hi_newStr(p.RecvStrByte(i));
    end else
    ;
  end;
end;

var udp_clients: Array of TNakoUdp;

function sys_udp_command(args: DWORD): PHiValue; stdcall;
var
  udpid: Integer;
  cmd: AnsiString;
  value, s: AnsiString;
  p: TNakoUdp;
begin
  Result := nil;
  if udp_clients = nil then SetLength(udp_clients, 255);

  udpid := getArgInt(args, 0, True);
  cmd   := getArgStr(args, 1);
  value := getArgStr(args, 2);

  cmd := LowerCase(cmd);
  if cmd = 'create' then
  begin
    p := TNakoUdp.Create(nil);
    p.InstanceName := value;
    p.udpid := udpid;
    udp_clients[ udpid ] := p;
  end else
  begin
    // オブジェクトを検索
    p := udp_clients[ udpid ];

    if cmd = 'connect' then
    begin
      s := (value);
      try
        p.Host := getToken_s(s, ':');
      except on e: Exception do
        raise Exception.Create('ホスト名が解決できません。');
      end;
      //---
      p.PortNo := StrToIntDef(s, 80);
      try
        p.Open;
      except on e: Exception do
        raise Exception.Create('接続に失敗。' + e.Message);
      end;
    end else
    if cmd = 'send' then
    begin
      s := (value);
      try
        if s <> '' then p.Send(s[1], Length(s));
      except
        raise;
      end;
    end else
    if cmd = 'disconnect' then p.Close else
    if cmd = 'multicast'  then p.AddMultiCast else
    ;
  end;
end;

function sys_get_ip(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr( GetIpAddressStr( getArgStr(args,0,True) ) );
end;

function sys_get_host(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr( GetHostNameByAddr( getArgStr(args,0,True) ) );
end;

var tcp_servers: Array of TNakoTcpServer;
function sys_tcp_svr_command(args: DWORD): PHiValue; stdcall;
var
  tcpid: Integer;
  cmd, cmd2: AnsiString;
  value: AnsiString;
  i: Integer;
  p: TNakoTcpServer;
begin
  Result := nil;

  if tcp_servers = nil then
  begin
    SetLength(tcp_servers, 255);
  end;

  tcpid := getArgInt(args, 0, True);
  cmd   := getArgStr(args, 1);
  value := getArgStr(args, 2);

  cmd := LowerCase(cmd);
  if cmd = 'create' then
  begin
    p := TNakoTcpServer.Create(nil);
    p.InstanceName := value;
    tcp_servers[tcpid] := p;
  end else
  begin
    // コマンドを解析
    cmd2 := cmd;
    cmd := getToken_s(cmd2, ' ');
    // オブジェクトを検索
    p := tcp_servers[tcpid];
    //---
    if cmd = 'active' then
    begin
      i := StrToIntDef(value, 0);
      p.Port := StrToIntDef(cmd2, 10001);
      p.Active := (i <> 0);
    end
    else if cmd = 'close' then
    begin
      p.CloseFromIp(value);
    end
    else if cmd = 'list' then
    begin
      Result := hi_newStr(p.getClientList);
    end
    else if cmd = 'send' then
    begin
      p.SendToData(cmd2, value);
    end
    else
    ;
  end;
end;

function sys_pop3_dele(args: DWORD): PHiValue; stdcall;
var
  pop3: TKPop3Dialog;
  no: PHiValue;
begin
  Result := nil;
  no   := nako_getFuncArg(args, 0);
  pop3 := TKPop3Dialog.Create(nil);
  try
    pop3.ShowDialog := hi_bool(nako_getVariable('経過ダイアログ'));
    getPop3Info(pop3);
    pop3.Pop3Dele(hi_int(no));
  finally
    pop3.Free;
  end;
end;


function sys_smtp_send(args: DWORD): PHiValue; stdcall;
var
  smtp: TKSmtpDialog;
  addHead, option, from, rcptto, title, body, attach, html, cc, bcc: AnsiString;
begin
  smtp := TKSmtpDialog.Create(nil);
  try
    smtp.ShowDialog := hi_bool(nako_getVariable('経過ダイアログ'));

    // サーバー情報
    smtp.Host       := hi_str(nako_getVariable('メールホスト'));
    smtp.Port       := StrToIntDef(hi_str(nako_getVariable('メールポート')), 25);
    smtp.User       := hi_str(nako_getVariable('メールID'));
    smtp.Password   := hi_str(nako_getVariable('メールパスワード'));
    addHead         := hi_str(nako_getVariable('メールヘッダ'));
    // CHECK
    if smtp.Host = '' then raise Exception.Create('メールホストが空です。');
    // 認証
    option := UpperCase(hi_str(nako_getVariable('メールオプション')));
    if Pos('LOGIN',    option) > 0 then smtp.AuthLogin := True;
    if Pos('CRAM-MD5', option) > 0 then smtp.AuthMD5   := True;
    if Pos('PLAIN',    option) > 0 then smtp.AuthPlain := True;
    // 宛先など
    from   := hi_str(nako_getVariable('メール差出人'));
    rcptto := hi_str(nako_getVariable('メール宛先'));
    title  := hi_str(nako_getVariable('メール件名'));
    body   := hi_str(nako_getVariable('メール本文'));
    attach := hi_str(nako_getVariable('メール添付ファイル'));
    html   := hi_str(nako_getVariable('メールHTML'));
    cc     := hi_str(nako_getVariable('メールCC'));
    bcc    := hi_str(nako_getVariable('メールBCC'));
    // 実際に送信
    smtp.Send(from, rcptto, title, body, attach, html, cc, bcc, addHead);
  finally
    smtp.Free;
  end;

  Result := nil;
end;

procedure getSmtpInfoIndy(smtp: TIdSMTP);
var
  option: AnsiString;
  Login : TIdSASLLogin;
  Provider : TIdUserPassProvider;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  // サーバー情報
  smtp.Host       := hi_str(nako_getVariable('メールホスト'));
  smtp.Port       := StrToIntDef(hi_str(nako_getVariable('メールポート')), 25);
  smtp.Username   := hi_str(nako_getVariable('メールID'));
  smtp.Password   := hi_str(nako_getVariable('メールパスワード'));
  // CHECK
  if smtp.Host = '' then raise Exception.Create('メールホストが空です。');
  // option
  option := UpperCase(hi_str(nako_getVariable('メールオプション')));
  if Pos('LOGIN',    option) > 0 then smtp.AuthType := satDefault;
  if Pos('PLAIN',    option) > 0 then smtp.AuthType := satDefault;
  if Pos('SASL',     option) > 0 then smtp.AuthType := satSASL;
  if Pos('SSL',      option) > 0 then
  begin
    Login     := TIdSASLLogin.Create(SMTP);
    Provider  := TIdUserPassProvider.Create(Login);
    Login.UserPassProvider := Provider;
    Provider.Username := smtp.Username;
    Provider.Password := smtp.Password;
    SMTP.SASLMechanisms.Add.SASL := Login;
    SMTP.AuthType := satSASL;
    SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(SMTP);
    SMTP.IOHandler := SSLHandler;    //TIdSSLIOHandlerSocketOpenSSL
    //SMTP.UseTLS := utUseExplicitTLS; // Explict
    SMTP.UseTLS := utUseImplicitTLS; // Explict
    if Pos('IMPLICIT_TLS', option) > 0 then SMTP.UseTLS := utUseImplicitTLS;
    if Pos('REQUIRE_TLS', option)  > 0 then SMTP.UseTLS := utUseRequireTLS;
    if Pos('EXPLICIT_TLS', option) > 0 then SMTP.UseTLS := utUseExplicitTLS;
  end;
end;

procedure __sys_smtp_send_indy(Sender: TNetThread; ptr: Pointer);
var
  smtp: TIdSMTP;
  msg: TIdMessage;
begin
  smtp := TIdSMTP(ptr);
  msg  := TIdMessage(Sender.arg1);
  try
    NetDialog.setInfo('サーバーに接続中→' + smtp.Host);
    smtp.Connect;
    NetDialog.setInfo('認証中→' + smtp.Host);
    smtp.Authenticate;
    NetDialog.setInfo('メール送信中');
    smtp.Send(msg);
    NetDialog.setInfo('メール送信完了しました。');
    smtp.Disconnect;
    //
    NetDialog.Comlete;
  except
    on e:Exception do
    begin
      NetDialog.errormessage := e.Message;
      NetDialog.Error;
    end;
  end;
end;

function sys_smtp_send_indy10(args: DWORD): PHiValue; stdcall;
var
  smtp: TIdSMTP;
  msg: TIdMessage;
  addHead, from, rcptto, title, body, attach, html, cc, bcc: string;
  tmp: AnsiString;
  eml: TEml;
  th: TNetThread;
begin
  smtp := TIdSMTP.Create(nil);
  try
    // 認証
    addHead := hi_str(nako_getVariable('メールヘッダ'));
    // 宛先など
    from   := hi_strU(nako_getVariable('メール差出人'));
    rcptto := hi_strU(nako_getVariable('メール宛先'));
    title  := hi_strU(nako_getVariable('メール件名'));
    body   := hi_strU(nako_getVariable('メール本文'));
    attach := hi_strU(nako_getVariable('メール添付ファイル'));
    html   := hi_strU(nako_getVariable('メールHTML'));
    cc     := hi_strU(nako_getVariable('メールCC'));
    bcc    := hi_strU(nako_getVariable('メールBCC'));
    // SMTP
    getSmtpInfoIndy(smtp);
    // Message
    msg := TIdMessage.Create(smtp);
    msg.From.Address := ExtractMailAddress(from, false);
    msg.Recipients.EMailAddresses := rcptto;
    msg.CCList.EMailAddresses     := cc;
    msg.BccList.EMailAddresses    := bcc;
    msg.Subject   := jConvert.CreateHeaderStringEx(title);
    msg.Body.Text := jConvert.ConvertJCode(body, JIS_OUT);
    msg.NoEncode  := true;
    // -------------------------------------------------------------------------
    // set to eml
    eml := TEml.Create(nil);
    try
      eml.SetEmlEasy(from, rcptto, title, body, attach, html, cc, addHead);
      tmp := eml.GetAsEml.Text;
      msg.Headers.Text := getToken_s(tmp, #13#10#13#10);
      msg.Body.Text    := tmp;
    finally
      FreeAndNil(eml);
    end;
    // -------------------------------------------------------------------------
    // 実際に送信
    smtp.OnWorkBegin  := NetDialog.WorkBegin;
    smtp.OnWork       := NetDialog.Work;
    smtp.OnWorkEnd    := NetDialog.WorkEnd;
    th := TNetThread.Create(True);
    th.arg0 := smtp;
    th.arg1 := msg;
    th.method := __sys_smtp_send_indy;
    th.Resume;
    if not NetDialog.ShowDialog(
      'メールを送信します。',
      '送信準備中',
      hi_bool(nako_getVariable('経過ダイアログ'))) then
    begin
      if (NetDialog.Status = statCancel) then begin
        try smtp.Disconnect; except end;
        NetDialog.errormessage := 'ユーザーによって中断されました。';
      end;
      raise Exception.Create('メール送信に失敗。' + NetDialog.errormessage);
    end;
  finally
    FreeAndNil(msg);
    FreeAndNil(smtp);
  end;
  Result := nil;
end;

function sys_gmail_send(args: DWORD): PHiValue; stdcall;
var
  account, password, dir: AnsiString;
  p_id, p_pass, p_opt, p_port, p_host: PHiValue;
begin
  // get Args
  account  := getArgStr(args, 0);
  password := getArgStr(args, 1);
  dir      := getArgStr(args, 2);
  // rewrite
  p_id   := nako_getVariable('メールID');
  p_pass := nako_getVariable('メールパスワード');
  p_opt  := nako_getVariable('メールオプション');
  p_port := nako_getVariable('メールポート');
  p_host := nako_getVariable('メールホスト');

  hi_setStr(p_id,   account);
  hi_setStr(p_pass, password);
  hi_setStr(p_host, 'smtp.gmail.com');
  hi_setStr(p_opt,  'SSL');
  hi_setInt(p_port, 465);
  // recv
  Result := sys_smtp_send_indy10(args);
end;

function __yahoo_send(args: DWORD; IsBB:Boolean): PHiValue; stdcall;
var
  account, password, dir: AnsiString;
  p_id, p_pass, p_opt, p_port, p_host: PHiValue;
begin
  // get Args
  account  := getArgStr(args, 0);
  password := getArgStr(args, 1);
  dir      := getArgStr(args, 2);
  // rewrite
  p_id   := nako_getVariable('メールID');
  p_pass := nako_getVariable('メールパスワード');
  p_opt  := nako_getVariable('メールオプション');
  p_port := nako_getVariable('メールポート');
  p_host := nako_getVariable('メールホスト');

  hi_setStr(p_id,   account);
  hi_setStr(p_pass, password);
  if IsBB then
  begin
    hi_setStr(p_host, 'ybbsmtp.mail.yahoo.co.jp');
  end else
  begin
    hi_setStr(p_host, 'smtp.mail.yahoo.co.jp');
  end;
  hi_setStr(p_opt,  'LOGIN');
  hi_setInt(p_port, 587);
  // recv
  Result := sys_smtp_send_indy10(args);
end;

function sys_yahoo_send(args: DWORD): PHiValue; stdcall;
begin
  Result := __yahoo_send(args, False);
end;

function sys_yahoobb_send(args: DWORD): PHiValue; stdcall;
begin
  Result := __yahoo_send(args, False);
end;


var eml: TEml = nil; // EML処理のための変数

function sys_eml_load(args: DWORD): PHiValue; stdcall;
var f: PHiValue;
begin
  Result := nil;
  f := nako_getFuncArg(args, 0);
  FreeAndNil(eml);
  eml := TEml.Create(nil);
  eml.LoadFromFile(hi_str(f));
end;
function sys_eml_part_count(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newInt(eml.GetPartsCount);
end;
function sys_eml_part_type(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(eml.GetPartTypeList);
end;
function sys_eml_getText(args: DWORD): PHiValue; stdcall;
var i: PHiValue;
begin
  i := nako_getFuncArg(args, 0);
  Result := hi_newStr(eml.GetParts(hi_int(i)-1).GetTextBody);
end;
function sys_eml_getAttach(args: DWORD): PHiValue; stdcall;
var a,f: PHiValue;
begin
  Result := nil;
  a := nako_getFuncArg(args, 0);
  f := nako_getFuncArg(args, 1);
  eml.GetParts(hi_int(a)-1).BodySaveAsAttachment(hi_str(f));
end;
function sys_eml_getAllText(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(eml.GetTextBody);
end;
function sys_eml_getHeader(args: DWORD): PHiValue; stdcall;
var
  i: Integer;
  e: TEmlHeaderRec;
  s: AnsiString;
begin
  Result := hi_var_new;
  nako_hash_create(Result);
  for i := 0 to eml.Header.Count - 1 do
  begin
    e := eml.Header.Get(i);
    s := e.Name;
    nako_hash_set(Result, PAnsiChar(s), hi_newStr(eml.Header.GetDecodeValue(s)));
  end;
end;


function sys_http_head2hash(args: DWORD): PHiValue; stdcall;
var
  e: THttpHeadList;
  i: Integer;
  h: THttpHead;
  k, v: AnsiString;
begin
  // set hash
  Result := hi_var_new;
  nako_hash_create(Result);
  //
  e := THttpHeadList.Create;
  try
    e.SetAsText(getArgStr(args, 0, True));
    for i := 0 to e.Count - 1 do
    begin
      h := e.Items[i];
      k := h.Key;
      v := h.Value;
      nako_hash_set(Result, PAnsiChar(k), hi_newStr(v));
    end;
    if e.HttpVersion <> '' then
    begin
      v := e.HttpVersion;
      nako_hash_set(Result, 'HTTP.Version', hi_newStr(v));
    end;
    if e.Response >= 0 then
    begin
      nako_hash_set(Result, 'HTTP.Response', hi_newInt(e.Response));
    end;
  finally
    e.Free;
  end;
end;

function sys_http_post(args: DWORD): PHiValue; stdcall;
var
  http: TKHttpClient;
  url, head,body: AnsiString;

  function _method_https: PHiValue;
  begin
    raise Exception.Create('未サポートです。');
  end;

begin
  head := getArgStr(args, 0, True);
  body := getArgStr(args, 1, False);
  url  := getArgStr(args, 2);

  if Copy(url,1,8) = 'https://' then
  begin
    Result := _method_https;
    Exit;
  end;

  http := TKHttpClient.Create(nil);
  try
    // http セッティングを得る
    http.GetProxySettingFromRegistry;
    http.Port := 80;
    // post
    Result := hi_newStr(http.Post(url, head, body));
  finally
    http.Free;
  end;
end;


function sys_http_post_easy(args: DWORD): PHiValue; stdcall;
var
  http: TKHttpClient;
  url, body, head: AnsiString;
  key, keys: AnsiString;
  value, fname, name, mime: AnsiString;
  hash, pv: PHiValue;
  sl: TStringList;
  i: Integer;
begin
  Result := nil;
  url  := getArgStr(args, 0, True);
  hash := nako_getFuncArg(args, 1);
  nako_hash_create(hash);

  SetLength(keys, 65536);
  nako_hash_keys(hash, PAnsiChar(keys), 65535);

  sl := TStringList.Create;
  http := TKHttpClient.Create(nil);
  try
    sl.Text := Trim(keys);
    head := 'Content-Type: multipart/form-data; boundary=---------------------------1870989367997'#13#10;
    for i := 0 to sl.Count - 1 do
    begin
      key := sl.Strings[i];
      pv := nako_hash_get(hash, PAnsiChar(key));
      value := hi_str(pv);
      if key = '' then Continue;
      // value is file ?
      if (copy(value, 1, 6)) = '@file=' then
      begin
        System.Delete(value,1,6);
        value := Trim(value);
        fname := getToken_s(value, ';');
        name  := getToken_s(value, ';');
        name  := Trim(name);
        if name = '' then name := ExtractFileName(fname);
        mime := getToken_s(value, ';');
        mime := Trim(mime);
        if mime = '' then mime := getContentType(fname);
        try
          value := FileLoadAll(fname);
        except
          raise Exception.Create('『HTTP簡易ポスト』でファイルの埋め込みに失敗:' + fname);
        end;
        body := body + '-----------------------------1870989367997' + #13#10 +
          'Content-Disposition: form-data; name="' + key + '"; filename="' + name + '"' + #13#10 +
          'Content-Type:' + mime + #13#10#13#10 +
          value + #13#10;
      end else
      begin
        body := body + '-----------------------------1870989367997' + #13#10 +
          'Content-Disposition: form-data; name="' + key + '"'#13#10#13#10 +
          value + #13#10;
      end;
    end;
    body := body + '-----------------------------1870989367997--'#13#10;
    // FileSaveAll(body, DesktopDir + 'test.txt');
    //
    // http セッティングを得る
    http.GetProxySettingFromRegistry;
    http.Port := 80;
    if http_opt_useBasicAuth then
    begin
      http.AuthMode := httpBASIC;
      http.Username := http_opt_getId;
      http.Password := http_opt_getPassword;
    end;
    // post
    Result := hi_newStr(http.Post(url, head, body));
  finally
    sl.Free;
    http.Free;
  end;
end;


function sys_http_get(args: DWORD): PHiValue; stdcall;
var
  http: TKHttpClient;
  url, head: AnsiString;
begin
  head := getArgStr(args, 0, True);
  url  := getArgStr(args, 1);

  http := TKHttpClient.Create(nil);
  try
    // http セッティングを得る
    http.GetProxySettingFromRegistry;
    http.Port := 80;
    // post
    Result := hi_newStr(http.Get(url, head));
  finally
    http.Free;
  end;
end;

function sys_ntp_sync(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  server: AnsiString;
  IdNTP:TIdSNTP;
begin
  s := nako_getFuncArg(args, 0);
  if s = nil then server := 'ntp.ring.gr.jp'
             else server := hi_str(s);
  IdNTP := TIdSNTP.Create(nil);
  IdNtp.Host := server;

  Result := hi_newBool(IdNTP.SyncTime);
  IdNTP.Free;
end;

function sys_checkOnline(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newBool(not IsGlobalOffline);
end;

function sys_IsInternetConnected(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newBool(IsInternetConnected);
end;

var kabin_server:TKabin = nil;

function sys_kabin_open(args: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if (kabin_server <> nil) then FreeAndNil(kabin_server);
  kabin_server := TKabin.Create;
  kabin_server.port := hi_int(nako_getVariable('花瓶PORT'));
  kabin_server.password := hi_str(nako_getVariable('花瓶パスワード'));
  kabin_server.Open;
end;

function sys_kabin_close(args: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  if (kabin_server <> nil) then
  begin
    FreeAndNil(kabin_server);
  end;
end;


function sys_json_encode(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
begin
  p := getArg(args, 0, True);
  Result := hi_newStr(PHiValue2Json(p));
end;

function sys_json_decode(args: DWORD): PHiValue; stdcall;
begin
  Result := Json2PHiValue(getArgStr(args,0,True));
end;


function get_nakonet_dll_version(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(NAKONET_DLL_VERSION);
end;


procedure RegistFunction;

  procedure _option;
  begin
    nako_dialog_function.DialogParent := nako_getMainWindowHandle;
    MainWindowHandle := nako_getMainWindowHandle;
    pProgDialog := nako_getVariable('経過ダイアログ');
  end;

begin
  //todo: 命令追加
  //<命令>
  //+ネットワーク(nakonet.dll)
  //-HTTP
  AddFunc  ('HTTPダウンロード', 'URLをFILEへ|URLからFILEに',  4010, sys_http_download,      'URLをローカルFILEへダウンロードする。',          'HTTPだうんろーど');
  AddFunc  ('HTTPデータ取得',   'URLから|URLの|URLを',        4011, sys_http_downloaddata,  'URLからデータをダウンロードして内容を返す。',    'HTTPでーたしゅとく');
  AddFunc  ('HTTPヘッダ取得',   'URLから|URLの|URLを',        4012, sys_http_downloadhead,  'URLからヘッダを取得して内容を返す。(WinInet関数を使用。locationがあれば再取得)', 'HTTPへっだしゅとく');
  AddFunc  ('HTTP簡易ヘッダ取得','URLから|URLの|URLを',       4013, sys_http_downloadhead2,  'URLからヘッダを取得して内容を返す。(単純にHEADコマンドの応答を返す)', 'HTTPかんいへっだしゅとく');
  AddFunc  ('HTTPヘッダハッシュ変換','{=?}Sを|Sの|Sで',       4014, sys_http_head2hash, 'HTTPで取得したヘッダ情報をハッシュに変換して返す。', 'HTTPへっだはっしゅへんかん');
  AddFunc  ('HTTPポスト','{文字列=?}HEADとBODYをURLへ|BODYで',4015, sys_http_post, 'ポストしたい内容のHEADとBODYをURLへポストしその結果を返す。', 'HTTPぽすと');
  AddFunc  ('HTTPゲット','{文字列=?}HEADをURLへ|HEADで',      4016, sys_http_get, '送信ヘッダHEADを指定してURLへGETコマンドを発行する。そしてその結果を返す。', 'HTTPげっと');
  AddFunc  ('HTTP簡易ポスト','URLへVALUESを|URLに',4017, sys_http_post_easy, 'ポストしたい値(ハッシュ形式)VALUESをURLへポストしその結果を返す。', 'HTTPかんいぽすと');
  AddStrVar('HTTPオプション',   '',                4018, 'HTTPに関するオプションをハッシュ形式で設定する。BASIC認証は「BASIC認証=オン{~}ID=xxx{~}パスワード=xxx」と書く。他に、「UA=nadesiko{~}HTTP_VERSION=HTTP/1.1」。','HTTPおぷしょん');
  AddFunc  ('オンライン判定','',4019, sys_checkOnline, 'IEがオンラインかどうか判別し結果を1(オンライン)か0(オフライン)で返す。', 'おんらいんはんてい');
  AddFunc  ('インターネット接続判定','',4150, sys_IsInternetConnected, 'インターネットに接続しているかどうか判別し結果を1(オンライン)か0(オフライン)で返す。', 'いんたーねっとせつぞくはんてい');

  //-FTP
  AddFunc  ('FTP接続',          'Sで',                        4020, sys_ftp_connect,        '接続情報「ホスト=xxx{~}ID=xxx{~}パスワード=xxx{~}PORT=xx{~}PASV=オン|オフ」でFTPに接続する', 'FTPせつぞく');
  AddFunc  ('FTP切断',          '',                           4021, sys_ftp_disconnect,     'FTPの接続を切断する',                                      'FTPせつだん');
  AddFunc  ('FTPアップロード',  'AをBへ|AからBに',            4022, sys_ftp_upload,         'ローカルファイルAをリモードファイルBへアップロードする',   'FTPあっぷろーど');
  AddFunc  ('FTPフォルダアップロード',  'AをBへ|AからBに',    4038, sys_ftp_uploadDir,      'ローカルフォルダAをリモードフォルダBへアップロードする',   'FTPふぉるだあっぷろーど');
  AddFunc  ('FTP転送モード設定','Sに',                        4023, sys_ftp_mode,           'FTPの転送モードを「バイナリ|アスキー」に変更する',   'FTPてんそうもーどせってい');
  AddFunc  ('FTPダウンロード',  'AをBへ|AからBに',            4024, sys_ftp_download,       'リモートファイルAをローカルファイルBへダウンロードする',   'FTPだうんろーど');
  AddFunc  ('FTPフォルダダウンロード',  'AをBへ|AからBに',    4037, sys_ftp_downloadDir,    'リモートパスAをローカルフォルダBへ一括ダウンロードする','FTPふぉるだだうんろーど');
  AddStrVar('FTPフォルダ除外パターン',      '',4041,'','FTPふぉるだじょがいぱたーん');
  AddFunc  ('FTPファイル列挙',  'Sの|Sを',                    4025, sys_ftp_glob,           'FTPホストのファイルSを列挙する',   'FTPふぁいるれっきょ');
  AddFunc  ('FTPフォルダ列挙',  'Sの|Sを',                    4026, sys_ftp_globDir,        'FTPホストのフォルダSを列挙する',   'FTPふぉるだれっきょ');
  AddFunc  ('FTPフォルダ作成',  'Sへ|Sに|Sの',                4027, sys_ftp_mkdir,          'FTPホストへSのフォルダを作る',     'FTPふぉるださくせい');
  AddFunc  ('FTPフォルダ削除',  'Sの',                        4028, sys_ftp_rmdir,          'FTPホストへSのフォルダを削除する', 'FTPふぉるださくじょ');
  AddFunc  ('FTP作業フォルダ変更',  'Sに|Sへ',                4029, sys_ftp_changeDir,      'FTP作業フォルダをSに変更する',     'FTPさぎょうふぉるだへんこう');
  AddFunc  ('FTP作業フォルダ取得',  '',                       4030, sys_ftp_getCurDir,      'FTP作業フォルダを取得して返す',    'FTPさぎょうふぉるだしゅとく');
  AddFunc  ('FTPファイル削除',  'Sを|Sの',                    4031, sys_ftp_delFile,        'FTPファイルSを削除する',           'FTPふぁいるさくじょ');
  AddFunc  ('FTPファイル名変更','AをBへ|AからBに',            4032, sys_ftp_rename,         'FTPファイルAをBに変更する',        'FTPふぁいるめいへんこう');
  AddFunc  ('FTPコマンド送信',  'Sを|Sで|Sの',                4033, sys_ftp_command,        'FTPコマンドSを送信しその結果を返す。',           'FTPこまんどそうしん');
  AddFunc  ('FTP属性変更',      'FILEをSに|Sへ',              4034, sys_ftp_chmod,          'FTPファイル名FILEの属性をA(一般=644/CGI=755)に変更', 'FTPぞくせいへんこう');
  AddFunc  ('FTP作業フォルダ上移動',  '',                     4035, sys_ftp_upCurDir,       'FTP対象フォルダを上に移動', 'FTPさぎょうふぉるだうえいどう');
  AddFunc  ('FTPファイル詳細列挙',  'Sの|Sを',                4036, sys_ftp_glob2,          'FTPホストのファイルSを詳細に列挙する',   'FTPふぁいるしょうさいれっきょ');
  AddFunc  ('FTPタイムアウト設定',  'Vに|Vを|Vへ',            4039, sys_ftp_setTimeout,     '接続中のFTPのタイムアウト時間をミリ秒単位で設定する',   'FTPたいむあうとせってい');
  AddFunc  ('FTPログファイル設定',  '{=?}FILEに|FILEへ',      4040, sys_ftp_setLogFile,     'FTPのコマンドログをFILEに記録する',   'FTPろぐふぁいるせってい');
  //-メール
  AddFunc  ('メール受信',        'DIRへ|DIRに',  4050, sys_pop3_recv_indy10, 'POP3でフォルダDIRへメールを受信し、受信したメールの件数を返す。', 'めーるじゅしん');
  AddFunc  ('メール送信',        '',             4051, sys_smtp_send_indy10, 'SMTPでメールを送信する', 'めーるそうしん');
  AddStrVar('メールホスト',      '',4052,'','めーるほすと');
  AddStrVar('メールID',          '',4053,'','めーるID');
  AddStrVar('メールパスワード',  '',4054,'','めーるぱすわーど');
  AddStrVar('メールポート',      '',4055,'','めーるぽーと');
  AddIntVar('メール受信時削除',   0,4056,'','めーるじゅしんじさくじょ');
  AddStrVar('メール差出人',      '',4057,'','めーるさしだしにん');
  AddStrVar('メール宛先',        '',4058,'','めーるあてさき');
  AddStrVar('メール件名',        '',4059,'','めーるけんめい');
  AddStrVar('メール本文',        '',4060,'','めーるほんぶん');
  AddStrVar('メール添付ファイル','',4061,'','めーるてんぷふぁいる');
  AddStrVar('メールHTML',        '',4065,'HTMLメールを作るときにHTMLを設定','めーるHTML');
  AddStrVar('メールCC',          '',4066,'','めーるCC');
  AddStrVar('メールBCC',         '',4067,'','めーるBCC');
  AddStrVar('メールヘッダ',      '',4068,'送信時に追加したいヘッダをハッシュ形式で代入しておく。','めーるへっだ');
  AddStrVar('メールオプション',  '',4062,'メール受信時(APOP|SASL|SSL)、メール送信時(LOGIN|PLAIN|SSL)を複数指定可能。加えて(IMPLICIT_TLS|REQUIRE_TLS|EXPLICIT_TLS)を指定可能。','めーるおぷしょん');
  AddFunc  ('メールリスト取得',  '',4063, sys_pop3_list_indy10, 'POP3でメールの件数とサイズの一覧を取得する', 'めーるりすとしゅとく');
  AddFunc  ('メール削除',     'Aの',4064, sys_pop3_dele_indy10, 'POP3でA番目のメールを削除する', 'めーるさくじょ');
  AddFunc  ('GMAIL受信','ACCOUNTのPASSWORDでDIRへ|DIRに',4069, sys_gmail_recv, 'ACCOUNTとPASSWORDを利用してGMailを受信する。', 'GMAILじゅしん');
  AddFunc  ('GMAIL送信','ACCOUNTのPASSWORDで',4049, sys_gmail_send, 'ACCOUNTとPASSWORDを利用してGMailへ送信する。', 'GMAILそうしん');
  AddFunc  ('YAHOOメール受信','ACCOUNTのPASSWORDでDIRへ|DIRに',4133, sys_yahoo_recv, 'ACCOUNTとPASSWORDを利用してYahoo!メールを受信する。', 'YAHOOめーるじゅしん');
  AddFunc  ('YAHOOメール送信','ACCOUNTのPASSWORDで',4134, sys_yahoo_send, 'ACCOUNTとPASSWORDを利用してYahoo!メールを送信する。', 'YAHOOめーるじゅしん');
  AddFunc  ('YAHOOBBメール受信','ACCOUNTのPASSWORDでDIRへ|DIRに',4135, sys_yahoobb_recv, 'ACCOUNTとPASSWORDを利用してYahoo!BBメールを受信する。', 'YAHOOBBめーるじゅしん');
  AddFunc  ('YAHOOBBメール送信','ACCOUNTのPASSWORDで',4136, sys_yahoobb_send, 'ACCOUNTとPASSWORDを利用してYahoo!BBメールを送信する。', 'YAHOOBBめーるじゅしん');
  AddFunc  ('メール分割受信',    'DIRへFROMからTOまで|DIRに',  4137, sys_pop3_recv_indy10split, 'FROM(0起点)からTOまでの件数を指定してPOP3でフォルダDIRへメールを受信する。', 'めーるぶんかつじゅしん');
  AddFunc  ('GMAIL分割受信','ACCOUNTのPASSWORDでDIRへFROMからTOまで|DIRに',4138, sys_gmail_recv_split, 'FROM(0起点)からTOまで件数を指定しつつACCOUNTとPASSWORDを利用してGMailを受信する。', 'GMAILぶんかつじゅしん');
  //-EML
  AddFunc  ('EMLファイル開く', 'Fの',4080, sys_eml_load , 'EMLファイルを開く', 'EMLふぁいるひらく');
  AddFunc  ('EMLパート数取得','',4081, sys_eml_part_count, 'EMLファイルにいくつパートがあるかを取得して返す。', 'EMLぱーとすうしゅとく');
  AddFunc  ('EMLパート一覧取得','',4082, sys_eml_part_type, 'EMLファイルのパート種類の一覧取得して返す。', 'EMLぱーといちらんしゅとく');
  AddFunc  ('EMLテキスト取得','Aを',4083, sys_eml_getText, 'EMLファイルのA番目のパートをテキストとして取得する。', 'EMLてきすとしゅとく');
  AddFunc  ('EML添付ファイル保存','AをFへ|Fに',4084,sys_eml_getAttach,'EMLファイルのA番目(1~n)のパートを取り出してFへ保存する。', 'EMLてんぷふぁいるほぞん');
  AddFunc  ('EML全テキスト取得','',4085,sys_eml_getAllText,'EMLファイルに含まれるテキストを全部取得して返す。', 'EMLぜんてきすとしゅとく');
  AddFunc  ('EMLヘッダ取得','',4086,sys_eml_getHeader,'EMLファイルのヘッダをハッシュ形式にして返す', 'EMLへっだしゅとく');

  //-TCP/IP
  AddFunc  ('IPアドレス取得','{=?}Sの|Sで|Sから', 4073, sys_get_ip, 'ドメインSのIPアドレスを取得する', 'IPあどれすしゅとく');
  AddFunc  ('ホスト名取得','{=?}Sの|Sで|Sから', 4074, sys_get_host, 'IPアドレスSからホスト名を取得する', 'ほすとめいしゅとく');
  AddFunc  ('TCP_COMMAND','TCPID,A,B', 4070, sys_tcp_command, 'lib\nakonet.nakoのTCPクライアントで使う', 'TCP_COMMAND');
  AddFunc  ('TCP_SVR_COMMAND','{グループ}S,A,B', 4071, sys_tcp_svr_command, 'lib\nakonet.nakoのTCPサーバーで使う', 'TCP_SVR_COMMAND');
  AddFunc  ('UDP_COMMAND','{グループ}S,A,B', 4075, sys_udp_command, 'lib\nakonet.nakoのUDPで使う', 'UDP_COMMAND');

  //-NTP
  AddFunc  ('NTP時刻同期','{=?}Sで', 4076, sys_ntp_sync, 'NTPサーバーSに接続して現在時刻を修正する。引数省略すると、ringサーバーを利用する。成功すれば1、失敗すれば0を返す', 'NTPじこくどうき');

  //-PING
  AddFunc  ('PING','{=?}HOSTへ|HOSTに|HOSTを', 4072, sys_ping, 'HOSTへPINGが通るか確認する。通らなければ0を返す', 'PING');
  AddFunc  ('非同期PING','{=?}EVENTでHOSTに', 4077, sys_ping_async, 'HOSTへPINGが通るか非同期で確認する。結果は第一引数で指定した関数の引数として返す。', 'ひどうきPING');
  //-オプション
  AddIntVar('経過ダイアログ',1, 4090, 'FTP/HTTPで経過ダイアログを表示するかどうか。', 'けいかだいあろぐ');

  //-JSON
  AddFunc  ('JSONエンコード','{=?}Vを|Vの',     4130, sys_json_encode, '値VをJSON形式に変換する', 'JSONえんこーど');
  AddFunc  ('JSONデコード','{=?}JSONを|JSONの', 4131, sys_json_decode, '文字列JSONを変数に変換する', 'JSONでこーど');

  //-nakonet.dll
  AddFunc  ('NAKONET_DLLバージョン','', 4132, get_nakonet_dll_version, 'nakonet.dllのバージョンを得る', 'NAKONET_DLLばーじょん');

  //+花瓶サービス/葵連携(nakonet.dll)
  //-設定
  AddStrVar('花瓶PORT',      '5029',    4100, '', 'かびんPORT');
  AddStrVar('花瓶パスワード','',          4101, '', 'かびんぱすわーど');
  //-花瓶サービスの実行停止
  AddFunc  ('花瓶サービス起動','', 4105, sys_kabin_open, '花瓶サービス(葵連携用)を開始する', 'かびんさーびすきどう');
  AddFunc  ('花瓶サービス終了','', 4106, sys_kabin_close, '花瓶サービス(葵連携用)を終了する', 'かびんさーびすしゅうりょう');
  //</命令>

  _option;
end;

{ TNetDialog }

function procProgress(
    hDlg: HWND;    // handle to dialog box
    uMsg: UINT;    // message
    wp  : WPARAM;  // first message parameter
    lp  : LPARAM   // second message parameter
   ): BOOL; stdcall;
var id: WORD;
begin
  Result := False;
  case uMsg of
    WM_COMMAND:
      begin
        id := LOWORD(wp);
        if id = IDCANCEL then
        begin
          NetDialog.Cancel;
        end;
      end;
  end;
end;

procedure TNetDialog.Cancel;
begin
  Status := statCancel;
end;

procedure TNetDialog.Comlete;
begin
  Status := statComplete;
end;

procedure TNetDialog.Error;
begin
  Status := statError;
end;

procedure TNetDialog.setInfo(s: string);
begin
  SetDlgWinText(hProgress, IDC_EDIT_INFO, s);
end;

procedure TNetDialog.setText(s: string);
begin
  SetDlgWinText(hProgress, IDC_EDIT_TEXT, s);
end;

function TNetDialog.ShowDialog(stext, sinfo: AnsiString; Visible: Boolean): Boolean;
var
  msg: TMsg;
begin
  if hParent = 0 then hParent := nako_getMainWindowHandle;
  Status := statWork;

  // ダイアログの表示
  hProgress  := CreateDialogA(
      hInstance, PAnsiChar(IDD_DIALOG_PROGRESS), hParent, @procProgress);

  // ダイアログに情報を表示
  SetDlgWinText(hProgress, IDC_EDIT_TEXT, stext);
  SetDlgWinText(hProgress, IDC_EDIT_INFO, sinfo);
  if Visible then
    ShowWindow(hProgress, SW_SHOW)
  else
    ShowWindow(hProgress, SW_HIDE);

  // ダウンロードが終了するまでダイアログを表示
  while (Status = statWork) do
  begin
    if PeekMessage(msg, hProgress, 0, 0, PM_REMOVE) then
    begin
      if not IsDialogMessage(hProgress, msg) then
      begin
        TranslateMessage(msg);
        DispatchMessage (msg);
      end;
    end else
    begin
      // アイドル
      sleep(10);
    end;
  end;

  DestroyWindow(hProgress);
  Result := (Status = statComplete);
end;

var zero_progress_max_count: Integer;

procedure TNetDialog.Work(Sender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
var
  s: AnsiString;
  w_max, w_per: Integer;
  s_max: AnsiString;
begin
  if hProgress = 0 then Exit;

  // unknown mode
  w_max := Self.WorkCount;
  if (w_max = 0)and(AWorkCount > 0) then
  begin
    if (zero_progress_max_count * 0.9) < (AWorkCount) then
    begin
      zero_progress_max_count := AWorkCount * 2;
    end;
    w_max := zero_progress_max_count;
  end;
  // calc percent
  if w_max > 0 then
  begin
    w_per := Trunc(AWorkCount / w_max * 100);
  end else
  begin
    w_per := 0;
  end;

  // download text
  s_max := IntToStr(Trunc(Self.WorkCount/1024));
  if s_max = '0KB' then s_max := '不明';
  s := '通信中 (' + IntToStr(Trunc(AWorkCount/1024)) + '/' + s_max + ' KB) ' + target;
  setText(s);

  // progress bar
  SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
    PBM_SETSTEP, 1, 0);
  // range
  SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
    PBM_SETRANGE, 0, MakeLong(0, 100));
  // set pos
  if w_max > 0 then
  begin
    try
      SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
        PBM_SETPOS, w_per , LParam(BOOL(True)));
    except
    end;
  end else
  begin
    if AWorkCount > 0 then
    begin
      SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
        PBM_SETPOS, 100 , LParam(BOOL(True)));
    end else
    begin
      SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
        PBM_SETPOS, 0 , LParam(BOOL(True)));
    end;
  end;
end;

procedure TNetDialog.WorkBegin(Sender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  hParent := nako_getMainWindowHandle;
  Self.WorkCount := AWorkCountMax;
  zero_progress_max_count := 0;
end;

procedure TNetDialog.WorkEnd(Sender: TObject; AWorkMode: TWorkMode);
begin
  Work(Self, AWorkMode, Self.WorkCount);
end;

{ TNetThread }

constructor TNetThread.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  critical := TCriticalSection.Create;
end;

destructor TNetThread.Destroy;
begin
  FreeAndNil(critical);
  inherited;
end;

procedure TNetThread.Execute;
begin
  if Terminated then Exit;
  method(Self, arg0);
end;

procedure FreeTCP;
var
  i: Integer;
  svr: TNakoTcpServer;
  cli: TNakoTcpClient;
begin
  if tcp_servers <> nil then
  begin
    for i := 0 to High(tcp_servers) do
    begin
      svr := tcp_servers[i];
      FreeAndNil(svr);
    end;
  end;
  if tcp_clients <> nil then
  begin
    for i := 0 to High(tcp_clients) do
    begin
      cli := tcp_clients[i];
      FreeAndNil(cli);
    end;
  end;
end;

initialization
  //

finalization
begin
  if _idftp <> nil then sys_ftp_disconnect(0);
  FreeAndNil(FNetDialog);
  FreeTCP;
end;

end.
