unit dll_net_function;

interface

uses
  Windows, SysUtils, Classes, UrlMon, WinInet, kskFtp,
  dll_plugin_helper, dnako_import, dnako_import_types,
  winsock,unit_eml,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdFTPCommon,
  IdFTP, IdFTPList, IdHttp, IdTcpServer, IdSNTP;

const
  NAKONET_DLL_VERSION = '1.509';

type
  TNetDialog = class(TComponent)
  private
    hParent: HWND;
    hProgress: HWND;
    WorkCount: Integer;
  public
    target: string;
    errormessage: string;
    procedure WorkBegin(Sender: TObject; AWorkMode: TWorkMode; const AWorkCountMax: Integer);
    procedure WorkEnd(Sender: TObject; AWorkMode: TWorkMode);
    procedure Work(Sender: TObject; AWorkMode: TWorkMode; const AWorkCount: Integer);
    function ShowDialog(stext, sinfo: string; Visible: Boolean): Boolean;
    procedure setInfo(s: string);
    procedure setText(s: string);
  end;

  TNetThread = class(TThread)
  protected
    procedure Execute; override;
  public
    method: procedure (Sender: TNetThread; ptr: Pointer);
    arg0: Pointer;
    arg1: Pointer;
    arg2: Pointer;
    arg3: Pointer;
    arg4: Pointer;
  end;

function NetDialog:TNetDialog;
function get_on_off(str: string): Boolean;

procedure RegistFunction;

implementation

uses mini_file_utils, unit_file, KPop3, KSmtp, KTcp, KTCPW, unit_string2,
  WSockUtils, Icmp, KHttp, jconvert, md5, nako_dialog_function,
  nadesiko_version, messages, nako_dialog_const, CommCtrl, unit_kabin,
  hima_types, unit_content_type;

var pProgDialog: PHiValue = nil;
var FNetDialog: TNetDialog = nil;
var net_dialog_cancel:   Boolean = False;
var net_dialog_complete: Boolean = False;

const NAKO_HTTP_OPTION = 'HTTPオプション';

function NetDialog:TNetDialog;
begin
  if FNetDialog = nil then
  begin
    FNetDialog := TNetDialog.Create(nil);
  end;
  Result := FNetDialog;
end;

function nako_http_opt_get(name:string): string;
var
  p: PHiValue;
  s: TStringList;
begin
  p := nako_getVariable(NAKO_HTTP_OPTION);
  s := TStringList.Create;
  s.Text := hi_str(p);
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


function sys_http_download(args: DWORD): PHiValue; stdcall;
var
  a, b: PHiValue;
  url, local: string;
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
    h.id            := http_opt_getId;
    h.password      := http_opt_getPassword;
    h.UserAgent     := http_opt_getUA;
    h.UseDialog     := hi_bool(pProgDialog);
    h.DownloadDialog(url);
    h.Stream.SaveToFile(local);
  finally
    h.Free;
  end;

  Result := nil;
end;

function sys_http_downloaddata(args: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
  url, local, s: string;
  h: TkskHttpDialog;

  procedure subDownload;
  begin
    // 何らかの理由で標準命令が使えなかったときに使うサブメソッド
    local := TempDir + 'temp';
    if URLDownloadToFile(nil, PChar(url), PChar(local), 0, nil) <> s_ok then
    begin
      raise Exception.Create(url+'をダウンロードできませんでした。');
    end;
    s := FileLoadAll(local);
    if FileExists(local) then DeleteFile(local);
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
      h.id       := http_opt_getId;
      h.password := http_opt_getPassword;
      h.UserAgent     := http_opt_getUA;
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
  url, s: string;
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
  url, s: string;
  http: TKHttpClient; // 独自仕様
begin
  a := nako_getFuncArg(args, 0);
  url   := hi_str(a);

  http :=TKHttpClient.Create(nil);
  try
    try
      http.GetProxySettingFromRegistry; // レジストリからProxyを読む
      s := http.Head(url);
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

var _kskFtp: TkskFtp = nil;
var _idftp: Tidftp = nil;

function get_on_off(str: string): Boolean;
begin
  str := JReplace_(str, 'オン','1');
  str := JReplace_(str, 'オフ','0');
  str := JReplace_(str, 'はい','1');
  str := JReplace_(str, 'いいえ','0');
  str := JReplace_(str, '１','1');
  str := JReplace_(str, '０','0');
  Result := (StrToIntDef(str, 0) <> 0);
end;

function sys_ftp_connect(args: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
  s : TStringList;
begin
  ps := nako_getFuncArg(args, 0);
  s  := TStringList.Create;
  s.Text := hi_str(ps);

  _idftp := Tidftp.Create(nil);

  _idftp.Username  := Trim(s.Values['ID']);
  _idftp.Password  := Trim(s.Values['パスワード']);
  if _idftp.Password = '' then _idftp.Password := Trim(s.Values['PASSWORD']);
  _idftp.Host      := Trim(s.Values['ホスト']);
  if _idftp.Host = '' then _idftp.Host := Trim(s.Values['HOST']);
  _idftp.Port      := StrToIntDef(Trim(s.Values['PORT']), 21);
  _idftp.Passive   := get_on_off(Trim(s.Values['PASV']));
  if _idftp.Username = '' then raise Exception.Create('FTPの設定でIDが未設定です。');
  if _idftp.Password = '' then raise Exception.Create('FTPの設定でPASSWORDが未設定です。');
  if _idftp.Host     = '' then raise Exception.Create('FTPの設定でHOSTが未設定です。');
  try
    _idftp.Connect(True);
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
  //FreeAndNil(_kskFtp);
  if _idftp <> nil then try if _idftp.Connected then _idftp.DisconnectSocket; except end;
  FreeAndNil(_idftp);
  Result := nil;
end;

procedure proc_ftp_upload(Sender: TNetThread; ptr: Tidftp);
var
  dat: TMemoryStream;
  ps: PString;
begin
  dat := TMemoryStream(Sender.arg1);
  ps  := Sender.arg2;
  ptr.Put(dat, ps^);
  net_dialog_complete := True;
end;

procedure proc_ftp_uploadDir(Sender: TNetThread; ftp: Tidftp);
var
  local, remote: String;

  procedure _upload(local, remote: string);
  var
    dirs, files: THStringList;
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

  net_dialog_complete := True;
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
  dat: TMemoryStream;
  fname,remote: string;
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
    dat := TMemoryStream.Create;
    try
    try
      dat.LoadFromFile(fname);
      if _idftp.Connected = False then raise Exception.Create('接続していません。');
      uploader := TNetThread.Create(True);
      bShow := hi_bool(nako_getVariable('経過ダイアログ'));
      uploader.arg0 := _idftp;
      uploader.arg1 := dat;
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
    finally
      dat.Free;
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
    fname := hi_str(pLocal);
    if DirectoryExists(fname) = False then
    begin
      raise Exception.CreateFmt('アップロード対象ファイル"%s"がありません。',[fname]);
    end;
    remote := hi_str(pRemote);
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
  s: string;
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
  s: string;
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
  net_dialog_complete := True;
end;

procedure proc_ftp_downloadDir(Sender: TNetThread; ftp: Tidftp);
var
  local, remote: string;
  isError: Boolean;
  errors: string;

  procedure _getDir(_local, _remote: string);
  var
    tmp, tmp_d: string;
    dirs, saiki: TStringList;
    i: Integer;
    p: PChar;
    item: TIdFTPListItem;
    f: TSearchRec;
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
            if tmp <> '' then
            begin
              p := PChar(tmp);
              tmp_d := sjis_copyByte(p,24);
              if tmp <> tmp_d then tmp_d := tmp_d + '..';
              NetDialog.target :=
                IntToStr(i+1) + '/' + IntToStr(ftp.DirectoryListing.Count) + ',' +
                tmp_d;
            end;
            // --- 差分ダウンロード
            if FileExists(_local + tmp) then
            begin
              if FindFirst(_local + tmp, faAnyFile, f) = 0 then
              begin
                if FileTimeToDateTimeEx(f.FindData.ftLastWriteTime) = item.ModifiedDate then
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
  net_dialog_complete := True;
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
    fname  := hi_str(pLocal);
    remote := hi_str(pRemote);

    NetDialog.errormessage := '';
    net_dialog_cancel      := False;
    net_dialog_complete    := False;

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
  fname, remote: string;
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
    net_dialog_cancel      := False;
    net_dialog_complete    := False;

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
begin
  p := nako_getFuncArg(args, 0);
  s := hi_str(p);

  if _idftp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  sl := TStringList.Create;
  try
    _idftp.List(sl, s);
    res := '';
    for i := 0 to _idftp.DirectoryListing.Count - 1 do
    begin
      if (_idftp.DirectoryListing.Items[i].ItemType = ditFile) and
         (_idftp.DirectoryListing.Items[i].ModifiedDate > 0) then
      begin
        tmp := _idftp.DirectoryListing.Items[i].FileName;
        if (tmp = '.')or(tmp = '..') then Continue;
        res := res + tmp + #13#10;
      end;
    end;
    Result := hi_newStr(res);
  except
    Result := hi_newStr('');
    sl.Free;
  end;
  sl.Free;
end;



function sys_ftp_glob2(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  s, res: string;
  sl: TStringList;
begin
  p := nako_getFuncArg(args, 0);
  s := hi_str(p);

  if _idftp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  sl := TStringList.Create;
  try
    _idftp.List(sl, s);
    res := sl.Text;
    Result := hi_newStr(res);
  except
    Result := hi_newStr('');
    sl.Free;
  end;
  sl.Free;
end;


function sys_ftp_globDir(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  s, res, tmp: string;
  sl: TStringList;
  i: Integer;
begin
  p := nako_getFuncArg(args, 0);
  s := hi_str(p);

  //if _kskFtp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  //Result := hi_newStr(Trim(_kskFtp.GlobDir(s)));

  if _idftp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  sl := TStringList.Create;
  try
    _idftp.List(sl, s);
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
    Result := hi_newStr(res);
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
  s := hi_str(p);

  //if _kskFtp = nil then raise Exception.Create('FTP処理の前に『FTP接続』で接続してください。');
  //_kskFtp.CreateDir(s);
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
  s := hi_str(p);

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
  s := hi_str(p);

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
  Result := hi_newStr(_idftp.RetrieveCurrentDir);
end;

function sys_ftp_delFile(args: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  s: string;
begin
  p := nako_getFuncArg(args, 0);
  s := hi_str(p);

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
  _idftp.Rename(hi_str(pa), hi_str(pb));


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
    i:=_idftp.Quote(hi_str(ps));
  except
    raise Exception.Create('コマンド"' + hi_str(ps) + '"に失敗。');
  end;
  Result := hi_newStr(IntToStr(i)+' '+_idftp.LastCmdResult.Text.Text);
end;

function sys_ftp_chmod(args: DWORD): PHiValue; stdcall;
var
  ps, pa: PHiValue;
  s, a, cmd: string;
begin
  ps := nako_getFuncArg(args, 0);
  pa := nako_getFuncArg(args, 1);

  s := Trim(hi_str(ps));
  a := Trim(hi_str(pa));

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

procedure getPop3Info(pop3: TKPop3Dialog);
var
  option: string;
begin
  pop3.Host       := hi_str(nako_getVariable('メールホスト'));
  pop3.Port       := StrToIntDef(hi_str(nako_getVariable('メールポート')), 110);
  pop3.User       := hi_str(nako_getVariable('メールID'));
  pop3.Password   := hi_str(nako_getVariable('メールパスワード'));
  option          := UpperCase(hi_str(nako_getVariable('メールオプション')));
  if Pos('APOP',option) > 0 then pop3.APop := True;
  // CHECK
  if pop3.Host = '' then raise Exception.Create('メールホストが空です。');
  if pop3.Port < 0  then raise Exception.Create('メールポートが不正な数値です。');
  if pop3.User = '' then raise Exception.Create('メールユーザーが空です。');
  if pop3.Password = '' then raise Exception.Create('メールパスワードが空です。');
end;

function sys_pop3_recv(args: DWORD): PHiValue; stdcall;
var
  tmpDir, dir, fname, afile, txtFile,emlFile: string;
  from, replyto: string;
  pop3: TKPop3Dialog;
  i, j, sid: Integer;
  eml, sub: TEml;
  txt, msgid: string;
  msgids: TStringList;
const
  FILE_MSGIDS = 'msgids.___';
begin
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
        CopyFile(PChar(fname), PChar(emlFile), False);
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
begin
  p := TICMP.Create;
  try
    try
      p.Address := getArgStr(args, 0, True);
      Result := hi_newInt(p.Ping);
    except
      Result := hi_newInt(0);
    end;
  finally
    p.Free;
  end;
end;

function sys_tcp_command(args: DWORD): PHiValue; stdcall;
var
  obj, group, command, value: PHiValue;
  cmd, s: string; i: Integer;
  p: TNakoTcpClient;
begin
  Result := nil;

  group     := nako_getFuncArg(args, 0);
  command   := nako_getFuncArg(args, 1);
  value     := nako_getFuncArg(args, 2);

  cmd := LowerCase(hi_str(command));
  if cmd = 'create' then
  begin
    p := TNakoTcpClient.Create(nil);
    p.InstanceVar := group;
    Result := hi_newInt(Integer(p));
  end else
  begin
    // オブジェクトを検索
    obj := nako_group_findMember(group, 'オブジェクト');
    if obj = nil then raise Exception.Create('オブジェクトが特定できません。');
    i   := hi_int(obj);
    p := TNakoTcpClient(Integer(i));

    if cmd = 'connect' then
    begin
      s := hi_str(value);
      try
        p.ServerAddr := PInAddr(GetHostEnt(getToken_s(s, ':')).h_addr_list^)^;
      except on e: Exception do
        raise Exception.Create('ホスト名が解決できません。');
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
      s := hi_str(value);
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
      Result := hi_newStr(p.RecvStrByte(i));
    end else
    ;
  end;
end;

function sys_udp_command(args: DWORD): PHiValue; stdcall;
var
  obj, group, command, value: PHiValue;
  cmd, s: string; i: Integer;
  p: TNakoUdp;
begin
  Result := nil;

  group     := nako_getFuncArg(args, 0);
  command   := nako_getFuncArg(args, 1);
  value     := nako_getFuncArg(args, 2);

  cmd := LowerCase(hi_str(command));
  if cmd = 'create' then
  begin
    p := TNakoUdp.Create(nil);
    p.InstanceVar := group;
    Result := hi_newInt(Integer(p));
  end else
  begin
    // オブジェクトを検索
    obj := nako_group_findMember(group, 'オブジェクト');
    if obj = nil then raise Exception.Create('オブジェクトが特定できません。');
    i   := hi_int(obj);
    p := TNakoUdp(Integer(i));

    if cmd = 'connect' then
    begin
      s := hi_str(value);
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
      s := hi_str(value);
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

function sys_tcp_svr_command(args: DWORD): PHiValue; stdcall;
var
  obj, group, command, value: PHiValue;
  cmd, cmd2: string; i: Integer;
  p: TNakoTcpServer;
begin
  Result := nil;

  group     := nako_getFuncArg(args, 0);
  command   := nako_getFuncArg(args, 1);
  value     := nako_getFuncArg(args, 2);

  cmd := LowerCase(hi_str(command));
  if cmd = 'create' then
  begin
    p := TNakoTcpServer.Create(nil);
    p.InstanceVar := group;
    Result := hi_newInt(Integer(p));
  end else
  begin
    // コマンドを解析
    cmd2 := cmd;
    cmd := getToken_s(cmd2, ' ');
    // オブジェクトを検索
    obj := nako_group_findMember(group, 'オブジェクト');
    if obj = nil then raise Exception.Create('オブジェクトが特定できません。');
    i   := hi_int(obj);
    p := TNakoTcpServer(Integer(i));
    //---
    if cmd = 'active' then
    begin
      i := hi_int(value);
      p.Port := StrToIntDef(cmd2, 10001);
      p.Active := (i <> 0);
    end
    else if cmd = 'close' then
    begin
      p.CloseFromIp(hi_str(value));
    end
    else if cmd = 'list' then
    begin
      Result := hi_newStr(p.getClientList);
    end
    else if cmd = 'send' then
    begin
      p.SendToData(cmd2, hi_str(value))
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
  addHead, option, from, rcptto, title, body, attach, html, cc, bcc: string;
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
  s: string;
begin
  Result := hi_var_new;
  nako_hash_create(Result);
  for i := 0 to eml.Header.Count - 1 do
  begin
    e := eml.Header.Get(i);
    s := e.Name;
    nako_hash_set(Result, PChar(s), hi_newStr(eml.Header.GetDecodeValue(s)));
  end;
end;


function sys_http_head2hash(args: DWORD): PHiValue; stdcall;
var
  e: THttpHeadList;
  i: Integer;
  h: THttpHead;
  k, v: string;
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
      nako_hash_set(Result, PChar(k), hi_newStr(v));
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
  url, head,body: string;
begin
  head := getArgStr(args, 0, True);
  body := getArgStr(args, 1, False);
  url  := getArgStr(args, 2);

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
  url, body, head: string;
  key, keys: string;
  value, fname, name, mime: string;
  hash, pv: PHiValue;
  sl: TStringList;
  i: Integer;
begin
  url  := getArgStr(args, 0, True);
  hash := nako_getFuncArg(args, 1);
  nako_hash_create(hash);

  SetLength(keys, 65536);
  nako_hash_keys(hash, PChar(keys), 65535);

  sl := TStringList.Create;
  http := TKHttpClient.Create(nil);
  try
    sl.Text := Trim(keys);
    head := 'Content-Type: multipart/form-data; boundary=---------------------------1870989367997'#13#10;
    for i := 0 to sl.Count - 1 do
    begin
      key := sl.Strings[i];
      pv := nako_hash_get(hash, PChar(key));
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
  url, head: string;
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
  server: string;
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
  AddStrVar('HTTPオプション',   '',                4018, 'HTTPに関するオプションをハッシュ形式で設定する。BASIC認証は「BASIC認証=オン{~}ID=xxx{~}パスワード=xxx」と書く。UAの変更は「UA=nadesiko」のように書く。','HTTPおぷしょん');

  //-FTP
  AddFunc  ('FTP接続',          'Sで',                        4020, sys_ftp_connect,        '接続情報「ホスト=xxx{~}ID=xxx{~}パスワード=xxx{~}PORT=xx{~}PASV=オン|オフ」でFTPに接続する', 'FTPせつぞく');
  AddFunc  ('FTP切断',          '',                           4021, sys_ftp_disconnect,     'FTPの接続を切断する',                                      'FTPせつだん');
  AddFunc  ('FTPアップロード',  'AをBへ|AからBに',            4022, sys_ftp_upload,         'ローカルファイルAをリモードファイルBへアップロードする',   'FTPあっぷろーど');
  AddFunc  ('FTPフォルダアップロード',  'AをBへ|AからBに',    4038, sys_ftp_uploadDir,      'ローカルフォルダAをリモードフォルダBへアップロードする',   'FTPふぉるだあっぷろーど');
  AddFunc  ('FTP転送モード設定','Sに',                        4023, sys_ftp_mode,           'FTPの転送モードを「バイナリ|アスキー」に変更する',   'FTPてんそうもーどせってい');
  AddFunc  ('FTPダウンロード',  'AをBへ|AからBに',            4024, sys_ftp_download,       'リモートファイルAをローカルファイルBへダウンロードする',   'FTPだうんろーど');
  AddFunc  ('FTPフォルダダウンロード',  'AをBへ|AからBに',    4037, sys_ftp_downloadDir,    'リモートパスAをローカルフォルダBへ一括ダウンロードする','FTPふぉるだだうんろーど');
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
  //-メール
  AddFunc  ('メール受信',        'DIRへ|DIRに',  4050, sys_pop3_recv, 'POP3でフォルダDIRへメールを受信し、受信したメールの件数を返す。', 'めーるじゅしん');
  AddFunc  ('メール送信',        '',             4051, sys_smtp_send, 'SMTPでメールを送信する', 'めーるそうしん');
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
  AddStrVar('メールオプション',  '',4062,'メール受信時(APOP)、メール送信時(LOGIN|CRAM-MD5|PLAIN)を複数指定可能。','めーるおぷしょん');
  AddFunc  ('メールリスト取得',  '',4063, sys_pop3_list, 'POP3でメールの件数とサイズの一覧を取得する', 'めーるりすとしゅとく');
  AddFunc  ('メール削除',     'Aの',4064, sys_pop3_dele, 'POP3でA番目のメールを削除する', 'めーるさくじょ');
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
  AddFunc  ('TCP_COMMAND','{グループ}S,A,B', 4070, sys_tcp_command, 'lib\nakonet.nakoのTCPクライアントで使う', 'TCP_COMMAND');
  AddFunc  ('TCP_SVR_COMMAND','{グループ}S,A,B', 4071, sys_tcp_svr_command, 'lib\nakonet.nakoのTCPサーバーで使う', 'TCP_SVR_COMMAND');
  AddFunc  ('UDP_COMMAND','{グループ}S,A,B', 4075, sys_udp_command, 'lib\nakonet.nakoのUDPで使う', 'UDP_COMMAND');

  //-NTP
  AddFunc  ('NTP時刻同期','{=?}Sで', 4076, sys_ntp_sync, 'NTPサーバーSに接続して現在時刻を修正する。引数省略すると、ringサーバーを利用する。成功すれば1、失敗すれば0を返す', 'NTPじこくどうき');

  //-PING
  AddFunc  ('PING','{=?}Sへ|Sに|Sを', 4072, sys_ping, 'SへPINGが通るか確認する。通らなければ0を返す', 'PING');
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
  AddFunc  ('花瓶サービス起動','', 4105, sys_kabin_open, '花瓶サービス(葵連携用)を開始する', 'かびんさーびすかいし');
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
          net_dialog_cancel := True;
        end;
      end;
  end;
end;

procedure TNetDialog.setInfo(s: string);
begin
  SetDlgWinText(hProgress, IDC_EDIT_INFO, s);
end;

procedure TNetDialog.setText(s: string);
begin
  SetDlgWinText(hProgress, IDC_EDIT_TEXT, s);
end;

function TNetDialog.ShowDialog(stext, sinfo: string; Visible: Boolean): Boolean;
var
  msg: TMsg;
begin
  if hParent = 0 then hParent := nako_getMainWindowHandle;
  net_dialog_complete := False;

  // ダイアログの表示
  hProgress  := CreateDialog(
      hInstance, PChar(IDD_DIALOG_PROGRESS), hParent, @procProgress);

  // ダイアログに情報を表示
  SetDlgWinText(hProgress, IDC_EDIT_TEXT, stext);
  SetDlgWinText(hProgress, IDC_EDIT_INFO, sinfo);
  if Visible then
    ShowWindow(hProgress, SW_SHOW)
  else
    ShowWindow(hProgress, SW_HIDE);

  // ダウンロードが終了するまでダイアログを表示
  while (net_dialog_cancel = False)and(net_dialog_complete = False) do
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
  Result := net_dialog_complete;
end;

procedure TNetDialog.Work(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCount: Integer);
var
  s: string;
begin
  if hProgress = 0 then Exit;

  // download text
  s := '通信中 (' + IntToStr(Trunc(AWorkCount/1024)) + '/' + IntToStr(Trunc(Self.WorkCount/1024)) + 'KB) ' + target;
  setText(s);

  // progress bar
  SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
    PBM_SETSTEP, 1, 0);
  // range
  SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
    PBM_SETRANGE, 0, MakeLong(0, 100));
  // set pos
  if AWorkCount > 0 then
  begin
    SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
      PBM_SETPOS, Trunc(AWorkCount/Self.WorkCount*100) , LParam(BOOL(True)));
  end else
  begin
    SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
      PBM_SETPOS, 100 , LParam(BOOL(True)));
  end;
end;

procedure TNetDialog.WorkBegin(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCountMax: Integer);
begin
  hParent := nako_getMainWindowHandle;
  Self.WorkCount := AWorkCountMax;
  // 初期設定
  net_dialog_cancel   := False;
  net_dialog_complete := False;
end;

procedure TNetDialog.WorkEnd(Sender: TObject; AWorkMode: TWorkMode);
begin
  Work(Self, AWorkMode, Self.WorkCount);
end;

{ TNetThread }

procedure TNetThread.Execute;
begin
  if Terminated then Exit;
  method(Self, arg0);
end;

initialization
  //

finalization
  FreeAndNil(FNetDialog);

end.
