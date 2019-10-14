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
  IdLogFile,
  IdURI;

const
  NAKONET_DLL_VERSION = '1.512';

type
  TNetDialogStatus = (statWork, statError, statComplete, statCancel);

  TNetDialog = class(TComponent)
  private
    hParent: HWND;
    hProgress: HWND;
    WorkCount: Integer;
    bMinMaxInitialized: boolean;
    iPrevPercent: Integer;
  public
    target: string;
    ResultData: string;
    errormessage: string;
    Status: TNetDialogStatus;
    procedure WorkBegin(Sender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Integer);
    procedure WorkEnd(Sender: TObject; AWorkMode: TWorkMode);
    procedure Work(Sender: TObject; AWorkMode: TWorkMode; AWorkCount: Integer);
    procedure WorkBegin64(Sender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure Work64(Sender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    function ShowDialog(stext, sinfo: AnsiString; Visible: Boolean;hObj:THANDLE=0): Boolean;
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
  hima_types, unit_content_type, IdAttachment, unit_string, unit_date,
  Math;

var pProgDialog: PHiValue = nil;
var FNetDialog: TNetDialog = nil;

const NAKO_HTTP_OPTION = 'HTTP�I�v�V����';
const FTP_NG_PATTERN   = 'FTP�t�H���_���O�p�^�[��';

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
  s := nako_http_opt_get('BASIC�F��');
  if (s = '�I�t') or (s = '0') or (s = '�O') or (s = '������') or (s = '')then
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
  Result := nako_http_opt_get('�p�X���[�h');
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

function http_opt_getReferer: string;
begin
  Result := nako_http_opt_get('Referer');
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

// HTTP/HTTPS �Ή�
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

  // �X���b�h���g���ăA�N�Z�X
  h := TkskHttpDialog.Create;
  try
    kskFtp.MainWindowHandle := nako_getMainWindowHandle;
    h.UseBasicAuth  := http_opt_useBasicAuth;
    h.id            := AnsiString(http_opt_getId);
    h.password      := AnsiString(http_opt_getPassword);
    h.UserAgent     := AnsiString(http_opt_getUA);
    h.UseDialog     := hi_bool(pProgDialog);
    h.httpVersion   := AnsiString(http_opt_getHttpVersion);
    h.Referer       := AnsiString(http_opt_getReferer);
    h.DownloadDialog(url);
    h.Stream.SaveToFile(string(local));
  finally
    h.Free;
  end;

  Result := nil;
end;

// HTTP/HTTPS �Ή�
function sys_http_downloaddata(args: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
  url, local, s: AnsiString;

  procedure subDownload;
  begin
    // ���炩�̗��R�ŕW�����߂��g���Ȃ������Ƃ��Ɏg���T�u���\�b�h
    local := AnsiString(TempDir + 'temp');
    if URLDownloadToFileA(nil, PAnsiChar(url), PAnsiChar(local), 0, nil) <> s_ok then
    begin
      raise Exception.Create(string(url)+'���_�E�����[�h�ł��܂���ł����B');
    end;
    s := FileLoadAll(local);
    if FileExists(string(local)) then DeleteFile(string(local));
  end;

  procedure _download;
  var
    h: TkskHttpDialog;
  begin
    // �X���b�h���g���ăA�N�Z�X
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
  http: TkskHttp; // WinInet �g�p
begin
  a := nako_getFuncArg(args, 0);
  url   := hi_str(a);

  http := TkskHttp.Create;
  try
    s := http.GetHeader(url);
  except on E: Exception do
    // ���炩�̗��R�ŕW�����߂��g���Ȃ������Ƃ�
    raise Exception.Create('�w�b�_���擾�ł��܂���ł����B' + e.Message);
  end;
  http.Free;

  Result := hi_newStr(s);
end;

function sys_http_downloadhead2(args: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
  url, s: AnsiString;
  http: TKHttpClient; // �Ǝ��d�l
begin
  a := nako_getFuncArg(args, 0);
  url   := hi_str(a);

  http :=TKHttpClient.Create(nil);
  try
    try
      http.GetProxySettingFromRegistry; // ���W�X�g������Proxy��ǂ�
      s := AnsiString(http.Head(string(url)));
    except
      on E: Exception do
        // ���炩�̗��R�ŕW�����߂��g���Ȃ������Ƃ�
        raise Exception.Create('�w�b�_���擾�ł��܂���ł����B' + e.Message);
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
  str := JReplaceW(str, '�I��','1');
  str := JReplaceW(str, '�I�t','0');
  str := JReplaceW(str, '�͂�','1');
  str := JReplaceW(str, '������','0');
  str := JReplaceW(str, '�P','1');
  str := JReplaceW(str, '�O','0');
  Result := (StrToIntDef(string(str), 0) <> 0);
end;

function sys_ftp_connect(args: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
  s : TStringList;
  ssloption : string;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  ps := nako_getFuncArg(args, 0);
  s  := TStringList.Create;
  s.Text := hi_strU(ps);

  _idftp := Tidftp.Create(nil);
  if _idftp_logfile <> nil then // logfile
  begin
    // _idftp.Intercept := _idftp_logfile;
    _idftp_logfile.Active := True;
  end;

  _idftp.Username  := Trim(s.Values['ID']);
  _idftp.Password  := Trim(s.Values['�p�X���[�h']);
  if _idftp.Password = '' then _idftp.Password := Trim(s.Values['PASSWORD']);
  _idftp.Host      := Trim(s.Values['�z�X�g']);
  if _idftp.Host = '' then _idftp.Host := Trim(s.Values['HOST']);
  _idftp.Port      := StrToIntDef(Trim(s.Values['PORT']), 21);
  if Trim(s.Values['PASV']) <> '' then
  begin
    _idftp.Passive   := get_on_off(Trim(s.Values['PASV']));
  end else begin
    _idftp.Passive := True;
  end;
  ssloption := Trim(s.Values['SSL�I�v�V����']);
  if ssloption <> '' then
  begin
    SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    _idftp.IOHandler := SSLHandler;    //TIdSSLIOHandlerSocketOpenSSL
    if (ssloption='ON') or (ssloption='�n�m') or (ssloption='�I��') or (ssloption='�͂�') or (ssloption='1') or (ssloption='�P') then
    begin
      _idftp.UseTLS := utUseExplicitTLS;
    end else
    if ssloption='EXPLICIT_TLS' then
    begin
      _idftp.UseTLS := utUseExplicitTLS;
    end else
    if ssloption='IMPLICIT_TLS' then
    begin
      _idftp.UseTLS := utUseImplicitTLS;
    end else
    if ssloption='REQUIRE_TLS' then
    begin
      _idftp.UseTLS := utUseRequireTLS;
    end else begin
      _idftp.UseTLS := utNoTLSSupport ;
    end;
    if Trim(s.Values['�f�[�^�Í���']) = '' then
    begin
      if _idftp.UseTLS = utNoTLSSupport then
      begin
        _idftp.DataPortProtection := ftpdpsClear;
      end else begin
        _idftp.DataPortProtection := ftpdpsPrivate;
      end;
    end else
    if get_on_off(Trim(s.Values['�f�[�^�Í���'])) then
    begin
      _idftp.DataPortProtection := ftpdpsPrivate;
    end else begin
      _idftp.DataPortProtection := ftpdpsClear;
    end;
    if (_idftp.DataPortProtection = ftpdpsPrivate) and (_idftp.UseTLS = utNoTLSSupport) then raise Exception.Create('FTP�f�[�^�o�H�݂̂��Í������邱�Ƃ͂ł��܂���B');
  end else begin
    if get_on_off(Trim(s.Values['�f�[�^�Í���'])) then
    begin
      _idftp.DataPortProtection := ftpdpsPrivate;
    end else begin
      _idftp.DataPortProtection := ftpdpsClear;
    end;
    if _idftp.DataPortProtection = ftpdpsPrivate then raise Exception.Create('FTP�f�[�^�o�H�݂̂��Í������邱�Ƃ͂ł��܂���B');
  end;

  _idftp.TransferType := ftBinary; // �d�v

  if _idftp.Username = '' then raise Exception.Create('FTP�̐ݒ��ID�����ݒ�ł��B');
  if _idftp.Password = '' then raise Exception.Create('FTP�̐ݒ��PASSWORD�����ݒ�ł��B');
  if _idftp.Host     = '' then raise Exception.Create('FTP�̐ݒ��HOST�����ݒ�ł��B');
  try
    _idftp.Connect;
    _idftp.OnWorkBegin := NetDialog.WorkBegin64;
    _idftp.OnWork      := NetDialog.Work64;
    _idftp.OnWorkEnd   := NetDialog.WorkEnd;
  except
    on e: Exception do
      raise Exception.Create('FTP�Őڑ����ł��܂���ł����B' + e.Message);
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
    raise Exception.Create('�u' + local + '�v�͑��݂��Ȃ��t�H���_���ł��B');
  end;

  _upload(local, remote);

  NetDialog.Comlete;
end;

function sys_ftp_setTimeout(args: DWORD): PHiValue; stdcall;
var
  i: Integer;
begin
  i := getArgInt(args, 0);
  if _idftp = nil then raise Exception.Create('���̖��߂̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
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

  if _idftp = nil then raise Exception.Create('�A�b�v���[�h�̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
  _idftp.Tag := hi_int(pProgDialog);
  try
    fname := hi_str(pLocal);
    if CheckFileExists(fname) = False then
    begin
      raise Exception.CreateFmt('�A�b�v���[�h�Ώۃt�@�C��"%s"������܂���B',[fname]);
    end;
    remote := hi_str(pRemote);
    try
      if _idftp.Connected = False then raise Exception.Create('�ڑ����Ă��܂���B');
      uploader := TNetThread.Create(True);
      bShow := hi_bool(nako_getVariable('�o�߃_�C�A���O'));
      uploader.arg0 := _idftp;
      uploader.arg1 := @fname;
      uploader.arg2 := @remote;
      uploader.method := @proc_ftp_upload;
      uploader.FreeOnTerminate := True;
      uploader.Resume;
      if False = NetDialog.ShowDialog('FTP�A�b�v���[�h', hi_str(pRemote)+'�փA�b�v��', bShow) then
      begin
        try
          _idftp.Abort;
        except end;
        raise Exception.Create('���[�U�[�ɂ�蒆�f�{�^����������܂����B');
      end;
    except
      raise;
    end;
  except
    on e: Exception do
    begin
      raise Exception.Create('FTP�A�b�v���[�h�Ɏ��s�B' + e.Message);
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

  if _idftp = nil then raise Exception.Create('�A�b�v���[�h�̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
  _idftp.Tag := hi_int(pProgDialog);
  try
    fname := hi_strU(pLocal);
    if DirectoryExists(fname) = False then
    begin
      raise Exception.CreateFmt('�A�b�v���[�h�Ώۃt�@�C��"%s"������܂���B',[fname]);
    end;
    remote := hi_strU(pRemote);
    try
    try
      if _idftp.Connected = False then raise Exception.Create('�ڑ����Ă��܂���B');
      uploader := TNetThread.Create(True);
      bShow := hi_bool(nako_getVariable('�o�߃_�C�A���O'));
      uploader.arg0 := _idftp;
      uploader.arg1 := @fname;
      uploader.arg2 := @remote;
      uploader.method := @proc_ftp_uploadDir;
      uploader.FreeOnTerminate := True;
      uploader.Resume;
      if False = NetDialog.ShowDialog('FTP�ꊇ�A�b�v���[�h', hi_str(pRemote)+'�փA�b�v��', bShow) then
      begin
        try
          _idftp.Abort;
        except end;
        raise Exception.Create('���[�U�[�ɂ�蒆�f�{�^����������܂����B');
      end;
    except
      raise;
    end;
    finally
    end;
  except
    on e: Exception do
    begin
      raise Exception.Create('FTP�A�b�v���[�h�Ɏ��s�B' + e.Message);
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

  //if _kskFtp = nil then raise Exception.Create('���[�h�ݒ�̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
  if _idftp = nil then raise Exception.Create('���[�h�ݒ�̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');

  //if s <> '�A�X�L�[' then _kskFtp.Mode := FTP_TRANSFER_TYPE_BINARY
  //                   else _kskFtp.Mode := FTP_TRANSFER_TYPE_ASCII;

  if s <> '�A�X�L�[' then _idftp.TransferType := ftBinary
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

  if _idftp = nil then raise Exception.Create('���[�h�ݒ�̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
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
        NetDialog.setInfo('����:' + _remote);
        NetDialog.target := '�ړ�:' + _remote;
        ftp.ChangeDir(_remote);
        NetDialog.target := '�ꗗ�̎擾:' + _remote;
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
            // --- �����_�E�����[�h
            if FileExists(_local + tmp) then
            begin
              if FindFirst(_local + tmp, faAnyFile, f) = 0 then
              begin
                {$WARN SYMBOL_PLATFORM OFF}
                d1 := FileTimeToDateTimeEx(f.FindData.ftLastWriteTime);
                d2 := item.ModifiedDate;
                i1 := DelphiDateTimeToUNIXTime(d1);
                i2 := DelphiDateTimeToUNIXTime(d2);
                if Abs(i1 - i2) < 30 then // �덷30�b�͋��e����
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
            // --- �_�E�����[�h
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
        NetDialog.setText('�f�B���N�g������Ɉړ�');
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

  if _idftp = nil then raise Exception.Create('�_�E�����[�h�̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');

  _idftp.Tag := hi_int(pProgDialog);
  dat := TMemoryStream.Create;
  try
    fname  := hi_strU(pLocal);
    remote := hi_strU(pRemote);

    NetDialog.errormessage := '';

    thread  := TNetThread.Create(True);
    bShow   := hi_bool(nako_getVariable('�o�߃_�C�A���O'));
    thread.arg0 := _idftp;
    thread.arg1 := dat;
    thread.arg2 := @remote;
    thread.method := @proc_ftp_download;
    thread.FreeOnTerminate := True;
    thread.Resume;
    if False = NetDialog.ShowDialog('FTP�_�E�����[�h', hi_str(pRemote)+'����_�E�����[�h��', bShow) then
    begin
      try
        _idftp.Abort;
      except end;
      raise Exception.Create('���[�U�[�ɂ�蒆�f�{�^����������܂����B');
    end;

    dat.SaveToFile(fname);
  except
    on e: Exception do
    begin
      raise Exception.Create('FTP�_�E�����[�h�Ɏ��s�B' + e.Message);
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

  if (_idftp = nil)or(not _idftp.Connected) then raise Exception.Create('�_�E�����[�h�̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');

  _idftp.Tag := hi_int(pProgDialog);
  try
    fname  := hi_str(pLocal);
    remote := hi_str(pRemote);
    
    NetDialog.errormessage := '';

    thread  := TNetThread.Create(True);
    bShow   := hi_bool(nako_getVariable('�o�߃_�C�A���O'));
    thread.arg0 := _idftp;
    thread.arg1 := @fname;
    thread.arg2 := @remote;
    thread.method := @proc_ftp_downloadDir;
    thread.FreeOnTerminate := True;
    thread.Resume;
    if False = NetDialog.ShowDialog('FTP�ꊇ�_�E�����[�h', hi_str(pRemote)+'����_�E�����[�h��', bShow) then
    begin
      try
        _idftp.Abort;
      except end;
      raise Exception.Create('���[�U�[�ɂ�蒆�f�{�^����������܂����B');
    end;
    if NetDialog.errormessage <> '' then
    begin
      raise Exception.Create(NetDialog.errormessage);
    end;
  except
    on e: Exception do
    begin
      raise Exception.Create('FTP�_�E�����[�h�Ɏ��s�B' + e.Message);
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

  if _idftp = nil then raise Exception.Create('FTP�����̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
  sl := TStringList.Create;
  try
    try
      _idftp.List(sl, s, True); // �ڍ׃��[�h�ɂ��Ȃ��ƃf�B���N�g�����ǂ�������ł��Ȃ�
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
  if _idftp = nil then raise Exception.Create('FTP�����̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
  try
    _idftp.List(s);
    res := _idftp.ListResult.Text;
    Result := hi_newStrU(res);
  except on e: Exception do
    raise Exception.Create('FTP�Ńf�B���N�g���ꗗ�̎擾�Ɏ��s���܂����B' + e.Message);
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

  if _idftp = nil then raise Exception.Create('FTP�����̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
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

  if _idftp = nil then raise Exception.Create('FTP�����̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
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

  //if _kskFtp = nil then raise Exception.Create('FTP�����̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
  //_kskFtp.DeleteDir(s);

  if _idftp = nil then raise Exception.Create('FTP�����̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
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

  //if _kskFtp = nil then raise Exception.Create('FTP�����̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
  //_kskFtp.ChangeDir(s);

  if _idftp = nil then raise Exception.Create('FTP�����̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
  _idftp.ChangeDir(s);

  Result := nil;
end;

function sys_ftp_getCurDir(args: DWORD): PHiValue; stdcall;
begin
  //if _kskFtp = nil then raise Exception.Create('FTP�����̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
  //s := _kskFtp.CurrentDir;
  if _idftp = nil then raise Exception.Create('FTP�����̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
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

  //if _kskFtp = nil then raise Exception.Create('FTP�����̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
  //_kskFtp.DeleteFile(s);
  if _idftp = nil then raise Exception.Create('FTP�����̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
  _idftp.Delete(s);

  Result := nil;
end;

function sys_ftp_rename(args: DWORD): PHiValue; stdcall;
var
  pa, pb: PHiValue;
begin
  pa := nako_getFuncArg(args, 0);
  pb := nako_getFuncArg(args, 1);

  //if _kskFtp = nil then raise Exception.Create('FTP�����̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
  //_kskFtp.RanemeFile(hi_str(pa), hi_str(pb));

  if _idftp = nil then raise Exception.Create('FTP�����̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
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
  if _kskFtp = nil then raise Exception.Create('FTP�����̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
  if not _kskFtp.Command(hi_str(ps), True, res) then
  begin
    raise Exception.Create('�R�}���h"' + hi_str(ps) + '"�Ɏ��s�B');
  end;
  }
  if _idftp = nil then raise Exception.Create('FTP�����̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
  try
    i:=_idftp.Quote(hi_strU(ps));
  except
    raise Exception.Create('�R�}���h"' + hi_strU(ps) + '"�Ɏ��s�B');
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

  //if _kskFtp = nil then raise Exception.Create('FTP�����̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');

  if _idftp = nil then raise Exception.Create('FTP�����̑O�ɁwFTP�ڑ��x�Őڑ����Ă��������B');
  cmd := 'CHMOD ' + a + ' ' + s;
  {
  if not _kskFtp.Command(cmd, False, res) then
  begin
    raise Exception.Create('�����ύX�Ɏ��s�B');
  end;
  }
  try
    _idftp.Site(cmd);
  except
    raise Exception.Create('�R�}���h"' + cmd + '"�Ɏ��s�B');
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
  pop3.Host       := hi_strU(nako_getVariable('���[���z�X�g'));
  pop3.Port       := StrToIntDef(hi_strU(nako_getVariable('���[���|�[�g')), 110);
  pop3.User       := hi_strU(nako_getVariable('���[��ID'));
  pop3.Password   := hi_strU(nako_getVariable('���[���p�X���[�h'));
  option          := UpperCase(hi_strU(nako_getVariable('���[���I�v�V����')));
  if Pos('APOP',option) > 0 then pop3.APop := True;
  // CHECK
  if pop3.Host = '' then raise Exception.Create('���[���z�X�g����ł��B');
  if pop3.Port < 0  then raise Exception.Create('���[���|�[�g���s���Ȑ��l�ł��B');
  if pop3.User = '' then raise Exception.Create('���[�����[�U�[����ł��B');
  if pop3.Password = '' then raise Exception.Create('���[���p�X���[�h����ł��B');
end;


procedure getPop3InfoIndy(pop3: TIdPOP3);
var
  option: string;
  Login: TIdSASLLogin;
  Provider: TIdUserPassProvider;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  pop3.Host       := hi_strU(nako_getVariable('���[���z�X�g'));
  pop3.Port       := StrToIntDef(hi_strU(nako_getVariable('���[���|�[�g')), 110);
  pop3.Username   := hi_strU(nako_getVariable('���[��ID'));
  pop3.Password   := hi_strU(nako_getVariable('���[���p�X���[�h'));
  option          := UpperCase(hi_strU(nako_getVariable('���[���I�v�V����')));
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
  if pop3.Host = '' then raise Exception.Create('���[���z�X�g����ł��B');
  if pop3.Port <= 0  then raise Exception.Create('���[���|�[�g���s���Ȑ��l�ł��B');
  if pop3.Username = '' then raise Exception.Create('���[�����[�U�[����ł��B');
  if pop3.Password = '' then raise Exception.Create('���[���p�X���[�h����ł��B');
end;

function Popd3CheckMessageIdAsFileName(msgid: string): string;
var
  i: Integer;
  function _CheckId(ch: string): string;
  begin
    if Length(ch) <= 0 then
    begin
      Result := ch; Exit;
    end;
    // Windows�̃t�@�C�����Ƃ��Ďg������̂̂ݑI��
    if not (ch[1] in ['A'..'Z','a'..'z','0'..'9','!','%','(',')','#']) then
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
  bRemove:= hi_bool(nako_getVariable('���[����M���폜'));
  iFrom := Integer(Sender.arg3);
  iTo   := Integer(Sender.arg4);

  if Sender.Terminated then Exit;

  NetDialog.setInfo('�T�[�o�[�Ɛڑ���:' + pop3.Host);
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
      // ���b�Z�[�WID�̈ꗗ���擾
      NetDialog.setInfo('UIDL�ꗗ���擾��:' + pop3.Host);
      if pop3.UIDL(msgidsNow) then
      begin
        // save to uidl
        Sender.critical.Enter;
        try
          msgidsNow.SaveToFile(tmpDir + 'UIDL.txt');
        finally
          Sender.critical.Release;
        end;
        // ���l�w��̎�
        if (iTo < 0)  then
        begin
          iTo := msgidsNow.Count - 1;
        end;
        // ��M����
        for i := iFrom to iTo do
        begin
          fmt := Format('���[����M��(%3d/%3d)',
            [(i+1),msgidsNow.Count]);
          NetDialog.setInfo(fmt);
          // 1������M���Ă���
          msgid := msgidsNow.Strings[i];
          getToken_s(msgid, ' ');
          msgid := Popd3CheckMessageIdAsFileName(msgid);
          raw := TStringList.Create;
          try
            // ��M�ς݂��m�F����
            if msgids.IndexOf(msgid) < 0 then
            begin // ����M�Ȃ̂Ŏ�M����
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
    pop3.OnWorkBegin := NetDialog.WorkBegin64;
    pop3.OnWork      := NetDialog.Work64;
    pop3.OnWorkEnd   := NetDialog.WorkEnd;
    bShow := hi_bool(nako_getVariable('�o�߃_�C�A���O'));
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
      '���[���̎�M���������Ă��܂�', '���[���̎�M', bShow, th.Handle) then
    begin
      raise Exception.Create('���[����M�Ɏ��s�B' + NetDialog.errormessage);
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
        // �w�b�_�����擾
        from    := ExtractMailAddress(eml.Header.GetDecodeValue('From'));
        replyto := ExtractMailAddress(eml.Header.GetDecodeValue('Reply-To'));
        txt := txt + '���o�l: ' + eml.Header.GetDecodeValue('From')   + #13#10;
        if (from <> replyto)and(replyto <> '') then txt := txt + '�ԐM��: ' + replyto + #13#10;
        txt := txt + '����: '   + eml.Header.GetDecodeValue('To')     + #13#10;
        txt := txt + '����: '   + eml.Header.GetDecodeValue('Subject')+ #13#10;
        txt := txt + '���t: '   + FormatDateTime('yyyy/mm/dd hh:nn:ss', eml.Header.GetDateTime('Date')) + #13#10;
        // �Y�t�t�@�C�������邩
        if eml.GetPartsCount > 0 then
        begin
          attach_dir := tmpDir + msgid + '\';
          ForceDirectories(attach_dir);
          k := 0;
          // �Y�t�t�@�C�����P���ۑ����Ă���
          for j := 0 to eml.GetPartsCount - 1 do
          begin
            sub := eml.GetParts(j);
            afile := sub.GetAttachFilename;
            if afile <> '' then
            begin
              sub.BodySaveAsAttachment(attach_dir + afile);
              txt := txt + '�Y�t�t�@�C��:' + msgid + '\' + afile + #13#10;
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
          '���[����M�Ŏ�M�������[���w' + msgid + '�x�̉�͂ŃG���[�B' +
          e.Message);
      end;
    end;
    cnt := fs.Count;
  end;

begin
  //===================
  // �����̎擾
  tmpDir := recv_dir;
  if Copy(tmpDir, Length(tmpDir), 1) <> '\' then tmpDir := tmpDir + '\';

  //===================
  // ��M�t�H���_�̃`�F�b�N
  if not ForceDirectories(tmpDir) then
  begin
    raise Exception.Create('�t�H���_�w'+tmpDir+'�x���쐬�ł��܂���ł����B');
  end;

  //
  msgids := TStringList.Create;
  pop3   := TIdPOP3.Create(nil);
  try
    cnt := 0;
    // ���b�Z�[�WID�̈ꗗ���`�F�b�N
    if FileExists(tmpDir + FILE_MSGIDS) then
    begin
      msgids.LoadFromFile(tmpDir + FILE_MSGIDS);
    end;
    getPop3InfoIndy(pop3);
    // ��M����
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
  p_id   := nako_getVariable('���[��ID');
  p_pass := nako_getVariable('���[���p�X���[�h');
  p_opt  := nako_getVariable('���[���I�v�V����');
  p_port := nako_getVariable('���[���|�[�g');
  p_host := nako_getVariable('���[���z�X�g');

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
  p_id   := nako_getVariable('���[��ID');
  p_pass := nako_getVariable('���[���p�X���[�h');
  p_opt  := nako_getVariable('���[���I�v�V����');
  p_port := nako_getVariable('���[���|�[�g');
  p_host := nako_getVariable('���[���z�X�g');

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
  p_id   := nako_getVariable('���[��ID');
  p_pass := nako_getVariable('���[���p�X���[�h');
  p_opt  := nako_getVariable('���[���I�v�V����');
  p_port := nako_getVariable('���[���|�[�g');
  p_host := nako_getVariable('���[���z�X�g');

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
    pop3.OnWorkBegin := NetDialog.WorkBegin64;
    pop3.OnWork      := NetDialog.Work64;
    pop3.OnWorkEnd   := NetDialog.WorkEnd;
    bShow := hi_bool(nako_getVariable('�o�߃_�C�A���O'));
    //
    th := TNetThread.Create(True);
    th.arg0 := pop3;
    th.method := __sys_pop3_list_indy;
    th.Resume;
    //
    if not NetDialog.ShowDialog(
      '���[���ꗗ���擾���Ă��܂�', '���[���ꗗ�̎擾', bShow) then
    begin
      raise Exception.Create('���[���ꗗ�̎擾�Ɏ��s�B' + NetDialog.errormessage);
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
    NetDialog.errormessage := '���b�Z�[�W�̍폜�Ɏ��s���܂����B';
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
    pop3.OnWorkBegin := NetDialog.WorkBegin64;
    pop3.OnWork      := NetDialog.Work64;
    pop3.OnWorkEnd   := NetDialog.WorkEnd;
    bShow := hi_bool(nako_getVariable('�o�߃_�C�A���O'));
    //
    th := TNetThread.Create(True);
    th.arg0 := pop3;
    th.arg1 := @no;
    th.method := __sys_pop3_dele_indy;
    th.Resume;
    //
    if not NetDialog.ShowDialog(
      '���[���ꗗ���擾���Ă��܂�', '���[���ꗗ�̎擾', bShow) then
    begin
      raise Exception.Create('���[���ꗗ�̎擾�Ɏ��s�B' + NetDialog.errormessage);
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
  // �����̎擾
  dir := hi_str(nako_getFuncArg(args, 0));
  if Copy(dir, Length(dir), 1) <> '\' then dir := dir + '\';

  //===================
  // ��M�t�H���_�̃`�F�b�N
  if not ForceDirectories(dir) then
  begin
    raise Exception.Create('�t�H���_�w'+dir+'�x���쐬�ł��܂���ł����B');
  end;

  //===================
  // �ꎞ�t�H���_�֎�M
  tmpDir := TempDir + 'pop3_' + FormatDateTime('yymmddhhnnsszzz',Now) + '\';
  ForceDirectories(tmpDir);

  //===================
  msgids := TStringList.Create;
  pop3 := TKPop3Dialog.Create(nil);
  try
    // ���b�Z�[�WID�̈ꗗ���`�F�b�N
    if FileExists(dir + FILE_MSGIDS) then msgids.LoadFromFile(dir + FILE_MSGIDS);
    //
    pop3.ShowDialog := hi_bool(nako_getVariable('�o�߃_�C�A���O'));
    getPop3Info(pop3);
    // ��M����
    try
      Result := hi_newInt(
        pop3.Pop3RecvAll(tmpDir, hi_bool(nako_getVariable('���[����M���폜')))
      );
    except
      raise;
    end;
    // ��͏���
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
        if msgids.IndexOf(msgid) >= 0 then Continue;// ���Ɏ�M�ς݂Ȃ�X�L�b�v
        msgids.Add(msgid);
        // �w�b�_�����擾
        from    := ExtractMailAddress(eml.Header.GetDecodeValue('From'));
        replyto := ExtractMailAddress(eml.Header.GetDecodeValue('Reply-To'));
        txt := txt + '���o�l: ' + eml.Header.GetDecodeValue('From')   + #13#10;
        if (from <> replyto)and(replyto <> '') then txt := txt + '�ԐM��: ' + replyto + #13#10;
        txt := txt + '����: '   + eml.Header.GetDecodeValue('To')     + #13#10;
        txt := txt + '����: '   + eml.Header.GetDecodeValue('Subject')+ #13#10;
        txt := txt + '���t: '   + FormatDateTime('yyyy/mm/dd hh:nn:ss', eml.Header.GetDateTime('Date')) + #13#10;
        // �Y�t�t�@�C�������邩
        if eml.GetPartsCount > 0 then
        begin
          // �Y�t�t�@�C�����P���ۑ����Ă���
          for j := 0 to eml.GetPartsCount - 1 do
          begin
            sub := eml.GetParts(j);
            if (sub.EmlType = typeApplication)or(sub.EmlType = typeImage) then
            begin
              afile := sub.GetAttachFilename;
              while FileExists(dir + afile) do afile := '_' + afile;
              sub.BodySaveAsAttachment(dir + afile);
              txt := txt + '�Y�t�t�@�C��:' + afile + #13#10;
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
        raise Exception.Create('���[����M�Ŏ�M�������[��'+IntToStr(i)+'�̉�͂ŃG���[�B' + e.Message);
      end;
    end;
    msgids.SaveToFile(dir + FILE_MSGIDS); // ���b�Z�[�WID�̈ꗗ��ۑ�
  finally
    //======
    // �ꎞ�t�H���_���폜
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
    pop3.ShowDialog := hi_bool(nako_getVariable('�o�߃_�C�A���O'));
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
  // todo: �񓯊��C�x���g�Ń}���`�X���b�h���l�����邱��
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

  // �����̎擾
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
        raise Exception.Create('�z�X�g���������ł��܂���B' + e.Message);
      end;
      //---
      p.Port := StrToIntDef(s, 80);
      try
        p.Connect;
      except on e: Exception do
        raise Exception.Create('�ڑ��Ɏ��s�B' + e.Message);
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
    {if cmd = 'ssl' then
    begin
      i := StrToIntDef(value, 0);
      if i = 0 then
        p.ActiveSSL := false
      else
        p.ActiveSSL := true;
      Result := hi_newBool(p.ActiveSSL);
    end else}
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
    // �I�u�W�F�N�g������
    p := udp_clients[ udpid ];

    if cmd = 'connect' then
    begin
      s := (value);
      try
        p.Host := getToken_s(s, ':');
      except on e: Exception do
        raise Exception.Create('�z�X�g���������ł��܂���B');
      end;
      //---
      try
        p.PortNo := StrToIntDef(getToken_s(s, ':'), 80);
      except on e: Exception do
        raise Exception.Create('�|�[�g�ԍ��������ł��܂���B');
      end;
      if s <> '' then
      begin
        try
          p.OwnHost := getToken_s(s, ':');
        except on e: Exception do
          raise Exception.Create('���z�X�g���������ł��܂���B');
        end;
        try
          p.OwnPortNo := StrToIntDef(s, p.PortNo);
        except on e: Exception do
          p.OwnPortNo := p.PortNo;
        end;
      end else begin
        p.OwnHost := '';
        p.OwnPortNo := p.PortNo;
      end;
      try
        p.Open;
      except on e: Exception do
        raise Exception.Create('�ڑ��Ɏ��s�B' + e.Message);
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
    // �R�}���h�����
    cmd2 := cmd;
    cmd := getToken_s(cmd2, ' ');
    // �I�u�W�F�N�g������
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
    pop3.ShowDialog := hi_bool(nako_getVariable('�o�߃_�C�A���O'));
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
    smtp.ShowDialog := hi_bool(nako_getVariable('�o�߃_�C�A���O'));

    // �T�[�o�[���
    smtp.Host       := hi_str(nako_getVariable('���[���z�X�g'));
    smtp.Port       := StrToIntDef(hi_str(nako_getVariable('���[���|�[�g')), 25);
    smtp.User       := hi_str(nako_getVariable('���[��ID'));
    smtp.Password   := hi_str(nako_getVariable('���[���p�X���[�h'));
    addHead         := hi_str(nako_getVariable('���[���w�b�_'));
    // CHECK
    if smtp.Host = '' then raise Exception.Create('���[���z�X�g����ł��B');
    // �F��
    option := UpperCase(hi_str(nako_getVariable('���[���I�v�V����')));
    if Pos('LOGIN',    option) > 0 then smtp.AuthLogin := True;
    if Pos('CRAM-MD5', option) > 0 then smtp.AuthMD5   := True;
    if Pos('PLAIN',    option) > 0 then smtp.AuthPlain := True;
    // ����Ȃ�
    from   := hi_str(nako_getVariable('���[�����o�l'));
    rcptto := hi_str(nako_getVariable('���[������'));
    title  := hi_str(nako_getVariable('���[������'));
    body   := hi_str(nako_getVariable('���[���{��'));
    attach := hi_str(nako_getVariable('���[���Y�t�t�@�C��'));
    html   := hi_str(nako_getVariable('���[��HTML'));
    cc     := hi_str(nako_getVariable('���[��CC'));
    bcc    := hi_str(nako_getVariable('���[��BCC'));
    // ���ۂɑ��M
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
  // �T�[�o�[���
  smtp.Host       := hi_str(nako_getVariable('���[���z�X�g'));
  smtp.Port       := StrToIntDef(hi_str(nako_getVariable('���[���|�[�g')), 25);
  smtp.Username   := hi_str(nako_getVariable('���[��ID'));
  smtp.Password   := hi_str(nako_getVariable('���[���p�X���[�h'));
  // CHECK
  if smtp.Host = '' then raise Exception.Create('���[���z�X�g����ł��B');
  // option
  option := UpperCase(hi_str(nako_getVariable('���[���I�v�V����')));
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
    SMTP.AuthType := IdSMTP.satSASL;
    SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(SMTP);
    SSLHandler.SSLOptions.Method := sslvSSLv23;
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
    NetDialog.setInfo('�T�[�o�[�ɐڑ�����' + smtp.Host);
    smtp.Connect;
    NetDialog.setInfo('�F�ؒ���' + smtp.Host);
    smtp.Authenticate;
    NetDialog.setInfo('���[�����M��');
    smtp.Send(msg);
    NetDialog.setInfo('���[�����M�������܂����B');
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
    // �F��
    addHead := hi_str(nako_getVariable('���[���w�b�_'));
    // ����Ȃ�
    from   := hi_strU(nako_getVariable('���[�����o�l'));
    rcptto := hi_strU(nako_getVariable('���[������'));
    title  := hi_strU(nako_getVariable('���[������'));
    body   := hi_strU(nako_getVariable('���[���{��'));
    attach := hi_strU(nako_getVariable('���[���Y�t�t�@�C��'));
    html   := hi_strU(nako_getVariable('���[��HTML'));
    cc     := hi_strU(nako_getVariable('���[��CC'));
    bcc    := hi_strU(nako_getVariable('���[��BCC'));
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
    // ���ۂɑ��M
    smtp.OnWorkBegin  := NetDialog.WorkBegin64;
    smtp.OnWork       := NetDialog.Work64;
    smtp.OnWorkEnd    := NetDialog.WorkEnd;
    th := TNetThread.Create(True);
    th.arg0 := smtp;
    th.arg1 := msg;
    th.method := __sys_smtp_send_indy;
    th.Resume;
    if not NetDialog.ShowDialog(
      '���[���𑗐M���܂��B',
      '���M������',
      hi_bool(nako_getVariable('�o�߃_�C�A���O'))) then
    begin
      if (NetDialog.Status = statCancel) then begin
        try smtp.Disconnect; except end;
        NetDialog.errormessage := '���[�U�[�ɂ���Ē��f����܂����B';
      end;
      raise Exception.Create('���[�����M�Ɏ��s�B' + NetDialog.errormessage);
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
  p_id   := nako_getVariable('���[��ID');
  p_pass := nako_getVariable('���[���p�X���[�h');
  p_opt  := nako_getVariable('���[���I�v�V����');
  p_port := nako_getVariable('���[���|�[�g');
  p_host := nako_getVariable('���[���z�X�g');

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
  p_id   := nako_getVariable('���[��ID');
  p_pass := nako_getVariable('���[���p�X���[�h');
  p_opt  := nako_getVariable('���[���I�v�V����');
  p_port := nako_getVariable('���[���|�[�g');
  p_host := nako_getVariable('���[���z�X�g');

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


var eml: TEml = nil; // EML�����̂��߂̕ϐ�

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

function sys_mail_convHeader(args: DWORD): PHiValue; stdcall;
var
  s: AnsiString;
begin
  s := getArgStr(args, 0, True);
  Result := hi_newStr(CreateHeaderStringEx(s));
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
  h: TkskHttpDialog;
  url, head,body: AnsiString;
  res: string;
begin
  head := getArgStr(args, 0, True);
  body := getArgStr(args, 1, False);
  url  := getArgStr(args, 2);

  // �X���b�h���g���ăA�N�Z�X
  h := TkskHttpDialog.Create;
  try
    kskFtp.MainWindowHandle := nako_getMainWindowHandle;
    h.Header := head;
    h.Method := 'POST';
    h.PostBody := body;
    h.UseBasicAuth  := http_opt_useBasicAuth;
    h.id            := AnsiString(http_opt_getId);
    h.password      := AnsiString(http_opt_getPassword);
    h.UserAgent     := AnsiString(http_opt_getUA);
    h.UseDialog     := hi_bool(pProgDialog);
    h.httpVersion   := AnsiString(http_opt_getHttpVersion);
    h.Referer       := AnsiString(http_opt_getReferer);
    res := '';
    if h.DownloadDialog(url) then
    begin
      SetLength(res, h.Stream.Size);
      h.Stream.Position := 0;
      h.Stream.Read(res[1], h.Stream.Size);
    end;
    Result := hi_newStr(res);
  finally
    h.Free;
  end;
end;


function sys_http_post_easy(args: DWORD): PHiValue; stdcall;
var
  h: TkskHttpDialog;
  url, head, body, res: AnsiString;
  key, keys: AnsiString;
  value, fname, name, mime: AnsiString;
  hash, pv: PHiValue;
  sl: TStringList;
  i: Integer;
  rnd: string;
begin
  Result := nil;
  url  := getArgStr(args, 0, True);
  hash := nako_getFuncArg(args, 1);
  nako_hash_create(hash);
  rnd := IntToStr(RandomRange(11111, 99999));

  SetLength(keys, 65536);
  nako_hash_keys(hash, PAnsiChar(keys), 65535);

  sl := TStringList.Create;
  h := TkskHttpDialog.Create;
  try
    sl.Text := Trim(keys);
    head := 'Content-Type: multipart/form-data; boundary=---------------------------1870989367997'+rnd+#13#10;
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
          raise Exception.Create('�wHTTP�ȈՃ|�X�g�x�Ńt�@�C���̖��ߍ��݂Ɏ��s:' + fname);
        end;
        body := body + '-----------------------------1870989367997' + rnd + #13#10 +
          'Content-Disposition: form-data; name="' + key + '"; filename="' + name + '"' + #13#10 +
          'Content-Type:' + mime + #13#10#13#10 +
          value + #13#10;
      end else
      begin
        body := body + '-----------------------------1870989367997' + rnd + #13#10 +
          'Content-Disposition: form-data; name="' + key + '"'#13#10#13#10 +
          value + #13#10;
      end;
    end;
    body := body + '-----------------------------1870989367997' + rnd + '--'#13#10;
    // FileSaveAll(body, DesktopDir + 'test.txt');

    // POST�̏���
    kskFtp.MainWindowHandle := nako_getMainWindowHandle;
    h.Header        := head;
    h.Method        := 'POST';
    h.PostBody      := body;
    h.UseBasicAuth  := http_opt_useBasicAuth;
    h.id            := AnsiString(http_opt_getId);
    h.password      := AnsiString(http_opt_getPassword);
    h.UserAgent     := AnsiString(http_opt_getUA);
    h.UseDialog     := hi_bool(pProgDialog);
    h.httpVersion   := AnsiString(http_opt_getHttpVersion);
    h.Referer       := AnsiString(http_opt_getReferer);
    res := '';
    if h.DownloadDialog(url) then
    begin
      SetLength(res, h.Stream.Size);
      h.Stream.Position := 0;
      h.Stream.Read(res[1], h.Stream.Size);
    end;
    Result := hi_newStr(res);
  finally
    h.Free;
  end;
end;

function sys_http_get(args: DWORD): PHiValue; stdcall;
var
  h: TkskHttpDialog;
  url, head: AnsiString;
  res: string;

begin
  head := getArgStr(args, 0, True);
  url  := getArgStr(args, 1);

  // �X���b�h���g���ăA�N�Z�X
  h := TkskHttpDialog.Create;
  try
    kskFtp.MainWindowHandle := nako_getMainWindowHandle;
    h.Header := head;
    h.UseBasicAuth  := http_opt_useBasicAuth;
    h.id            := AnsiString(http_opt_getId);
    h.password      := AnsiString(http_opt_getPassword);
    h.UserAgent     := AnsiString(http_opt_getUA);
    h.UseDialog     := hi_bool(pProgDialog);
    h.httpVersion   := AnsiString(http_opt_getHttpVersion);
    h.Referer       := AnsiString(http_opt_getReferer);
    res := '';
    if h.DownloadDialog(url) then
    begin
      SetLength(res, h.Stream.Size);
      h.Stream.Position := 0;
      h.Stream.Read(res[1], h.Stream.Size);
    end;
    Result := hi_newStr(res);
  finally
    h.Free;
  end;
end;

function sys_http_delete(args: DWORD): PHiValue; stdcall;
var
  http: TKHttpClient;
  url, head: AnsiString;
begin
  head := getArgStr(args, 0, True);
  url  := getArgStr(args, 1);

  http := TKHttpClient.Create(nil);
  try
    // http �Z�b�e�B���O�𓾂�
    http.GetProxySettingFromRegistry;
    http.Port := 80;
    // post
    Result := hi_newStr(http.Delete(url, head));
  finally
    http.Free;
  end;
end;

function sys_http_put(args: DWORD): PHiValue; stdcall;
var
  http: TKHttpClient;
  url, head,body: AnsiString;

begin
  head := getArgStr(args, 0, True);
  body := getArgStr(args, 1, False);
  url  := getArgStr(args, 2);

  http := TKHttpClient.Create(nil);
  try
    // http �Z�b�e�B���O�𓾂�
    http.GetProxySettingFromRegistry;
    http.Port := 80;
    // post
    Result := hi_newStr(http.Put(url, head, body));
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
  kabin_server.port := hi_int(nako_getVariable('�ԕrPORT'));
  kabin_server.password := hi_str(nako_getVariable('�ԕr�p�X���[�h'));
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

function sys_show_map(args: DWORD): PHiValue; stdcall;
var
  uri, place: string;
begin
  place := getArgStr(args, 0, True);
  uri := TIdURI.URLEncode('https://www.google.co.jp/maps/place/' + place);
  OpenApp(uri);
  Result := nil;
end;

function sys_show_route(args: DWORD): PHiValue; stdcall;
var
  uri, a, b: string;
begin
  // https://www.google.co.jp/maps/dir/A/B
  a := getArgStr(args, 0, True);
  b := getArgStr(args, 1);
  uri := TIdURI.URLEncode('https://www.google.co.jp/maps/dir/' + a + '/' + b);
  OpenApp(uri);
  Result := nil;
end;


procedure RegistFunction;

  procedure _option;
  begin
    nako_dialog_function.DialogParent := nako_getMainWindowHandle;
    MainWindowHandle := nako_getMainWindowHandle;
    pProgDialog := nako_getVariable('�o�߃_�C�A���O');
  end;

begin
  //todo: ���ߒǉ�
  //<����>
  //+�l�b�g���[�N(nakonet.dll)
  //-HTTP
  AddFunc  ('HTTP�_�E�����[�h', 'URL��FILE��|URL����FILE��',  4010, sys_http_download,      'URL�����[�J��FILE�փ_�E�����[�h����B',          'HTTP�������[��');
  AddFunc  ('HTTP�f�[�^�擾',   'URL����|URL��|URL��',        4011, sys_http_downloaddata,  'URL����f�[�^���_�E�����[�h���ē��e��Ԃ��B',    'HTTP�Ł[������Ƃ�');
  AddFunc  ('HTTP�w�b�_�擾',   'URL����|URL��|URL��',        4012, sys_http_downloadhead,  'URL����w�b�_���擾���ē��e��Ԃ��B(WinInet�֐����g�p�Blocation������΍Ď擾)', 'HTTP�ւ�������Ƃ�');
  AddFunc  ('HTTP�ȈՃw�b�_�擾','URL����|URL��|URL��',       4013, sys_http_downloadhead2,  'URL����w�b�_���擾���ē��e��Ԃ��B(�P����HEAD�R�}���h�̉�����Ԃ�)', 'HTTP���񂢂ւ�������Ƃ�');
  AddFunc  ('HTTP�w�b�_�n�b�V���ϊ�','{=?}S��|S��|S��',       4014, sys_http_head2hash, 'HTTP�Ŏ擾�����w�b�_�����n�b�V���ɕϊ����ĕԂ��B', 'HTTP�ւ����͂�����ւ񂩂�');
  AddFunc  ('HTTP�|�X�g','{������=?}HEAD��BODY��URL��|BODY��',4015, sys_http_post, '�|�X�g���������e��HEAD��BODY��URL�փ|�X�g�����̌��ʂ�Ԃ��B', 'HTTP�ۂ���');
  AddFunc  ('HTTP�Q�b�g','{������=?}HEAD��URL��|HEAD��',      4016, sys_http_get, '���M�w�b�_HEAD���w�肵��URL��GET�R�}���h�𔭍s����B�����Ă��̌��ʂ�Ԃ��B', 'HTTP������');
  AddFunc  ('HTTP�ȈՃ|�X�g','URL��VALUES��|URL��',4017, sys_http_post_easy, '�|�X�g�������l(�n�b�V���`��)VALUES��URL�փ|�X�g�����̌��ʂ�Ԃ��B', 'HTTP���񂢂ۂ���');
  AddStrVar('HTTP�I�v�V����',   '',                4018, 'HTTP�Ɋւ���I�v�V�������n�b�V���`���Őݒ肷��BBASIC�F�؂́uBASIC�F��=�I��{~}ID=xxx{~}�p�X���[�h=xxx�v�Ə����B���ɁA�uUA=nadesiko{~}HTTP_VERSION=HTTP/1.1{~}Referer=***�v�B','HTTP���Ղ����');
  AddFunc  ('�I�����C������','',4019, sys_checkOnline, 'IE���I�����C�����ǂ������ʂ����ʂ�1(�I�����C��)��0(�I�t���C��)�ŕԂ��B', '����炢��͂�Ă�');
  AddFunc  ('�C���^�[�l�b�g�ڑ�����','',4150, sys_IsInternetConnected, '�C���^�[�l�b�g�ɐڑ����Ă��邩�ǂ������ʂ����ʂ�1(�I�����C��)��0(�I�t���C��)�ŕԂ��B', '���񂽁[�˂��Ƃ������͂�Ă�');
  AddFunc  ('HTTP�v�b�g','{������=?}HEAD��BODY��URL��|BODY��',4151, sys_http_put, '�v�b�g���������e��HEAD��BODY��URL�փ|�X�g�����̌��ʂ�Ԃ��B', 'HTTP�Ղ���');
  AddFunc  ('HTTP�f���[�g','{������=?}HEAD��URL��|HEAD��',      4152, sys_http_delete, '���M�w�b�_HEAD���w�肵��URL��DELETE�R�}���h�𔭍s����B�����Ă��̌��ʂ�Ԃ��B', 'HTTP�ł�[��');
  //AddStrVar('HTTP�_�C�W�F�X�g�F�؏��',   '',                   -1, 'HTTP�_�C�W�F�X�g�F�؂Ɋւ�������n�b�V���`���Őݒ肷��B�urealm={~}nonce={~}algorithm={~}qop={~}nc={~}cnonce=�v�Ə����B','HTTP�����������Ƃɂ񂵂傤���傤�ق�');

  //-FTP
  AddFunc  ('FTP�ڑ�',          'S��',                        4020, sys_ftp_connect,        '�ڑ����u�z�X�g=xxx{~}ID=xxx{~}�p�X���[�h=xxx{~}PORT=xx{~}PASV=�I��|�I�t{~}SSL�I�v�V����=�I��|�I�t|IMPLICIT_TLS|REQUIRE_TLS|EXPLICIT_TLS{~}�f�[�^�Í���=�I��|�I�t�v��FTP�ɐڑ�����', 'FTP������');
  AddFunc  ('FTP�ؒf',          '',                           4021, sys_ftp_disconnect,     'FTP�̐ڑ���ؒf����',                                      'FTP������');
  AddFunc  ('FTP�A�b�v���[�h',  'A��B��|A����B��',            4022, sys_ftp_upload,         '���[�J���t�@�C��A�������[�h�t�@�C��B�փA�b�v���[�h����',   'FTP�����Ղ�[��');
  AddFunc  ('FTP�t�H���_�A�b�v���[�h',  'A��B��|A����B��',    4038, sys_ftp_uploadDir,      '���[�J���t�H���_A�������[�h�t�H���_B�փA�b�v���[�h����',   'FTP�ӂ��邾�����Ղ�[��');
  AddFunc  ('FTP�]�����[�h�ݒ�','S��',                        4023, sys_ftp_mode,           'FTP�̓]�����[�h���u�o�C�i��|�A�X�L�[�v�ɕύX����',   'FTP�Ă񂻂����[�ǂ����Ă�');
  AddFunc  ('FTP�_�E�����[�h',  'A��B��|A����B��',            4024, sys_ftp_download,       '�����[�g�t�@�C��A�����[�J���t�@�C��B�փ_�E�����[�h����',   'FTP�������[��');
  AddFunc  ('FTP�t�H���_�_�E�����[�h',  'A��B��|A����B��',    4037, sys_ftp_downloadDir,    '�����[�g�p�XA�����[�J���t�H���_B�ֈꊇ�_�E�����[�h����','FTP�ӂ��邾�������[��');
  AddStrVar('FTP�t�H���_���O�p�^�[��',      '',4041,'','FTP�ӂ��邾���傪���ς��[��');
  AddFunc  ('FTP�t�@�C����',  'S��|S��',                    4025, sys_ftp_glob,           'FTP�z�X�g�̃t�@�C��S��񋓂���',   'FTP�ӂ�����������');
  AddFunc  ('FTP�t�H���_��',  'S��|S��',                    4026, sys_ftp_globDir,        'FTP�z�X�g�̃t�H���_S��񋓂���',   'FTP�ӂ��邾�������');
  AddFunc  ('FTP�t�H���_�쐬',  'S��|S��|S��',                4027, sys_ftp_mkdir,          'FTP�z�X�g��S�̃t�H���_�����',     'FTP�ӂ��邾��������');
  AddFunc  ('FTP�t�H���_�폜',  'S��',                        4028, sys_ftp_rmdir,          'FTP�z�X�g��S�̃t�H���_���폜����', 'FTP�ӂ��邾��������');
  AddFunc  ('FTP��ƃt�H���_�ύX',  'S��|S��',                4029, sys_ftp_changeDir,      'FTP��ƃt�H���_��S�ɕύX����',     'FTP�����傤�ӂ��邾�ւ񂱂�');
  AddFunc  ('FTP��ƃt�H���_�擾',  '',                       4030, sys_ftp_getCurDir,      'FTP��ƃt�H���_���擾���ĕԂ�',    'FTP�����傤�ӂ��邾����Ƃ�');
  AddFunc  ('FTP�t�@�C���폜',  'S��|S��',                    4031, sys_ftp_delFile,        'FTP�t�@�C��S���폜����',           'FTP�ӂ����邳������');
  AddFunc  ('FTP�t�@�C�����ύX','A��B��|A����B��',            4032, sys_ftp_rename,         'FTP�t�@�C��A��B�ɕύX����',        'FTP�ӂ�����߂��ւ񂱂�');
  AddFunc  ('FTP�R�}���h���M',  'S��|S��|S��',                4033, sys_ftp_command,        'FTP�R�}���hS�𑗐M�����̌��ʂ�Ԃ��B',           'FTP���܂�ǂ�������');
  AddFunc  ('FTP�����ύX',      'FILE��S��|S��',              4034, sys_ftp_chmod,          'FTP�t�@�C����FILE�̑�����A(���=644/CGI=755)�ɕύX', 'FTP���������ւ񂱂�');
  AddFunc  ('FTP��ƃt�H���_��ړ�',  '',                     4035, sys_ftp_upCurDir,       'FTP�Ώۃt�H���_����Ɉړ�', 'FTP�����傤�ӂ��邾�������ǂ�');
  AddFunc  ('FTP�t�@�C���ڍח�',  'S��|S��',                4036, sys_ftp_glob2,          'FTP�z�X�g�̃t�@�C��S���ڍׂɗ񋓂���',   'FTP�ӂ����邵�傤�����������');
  AddFunc  ('FTP�^�C���A�E�g�ݒ�',  'V��|V��|V��',            4039, sys_ftp_setTimeout,     '�ڑ�����FTP�̃^�C���A�E�g���Ԃ��~���b�P�ʂŐݒ肷��',   'FTP�����ނ����Ƃ����Ă�');
  AddFunc  ('FTP���O�t�@�C���ݒ�',  '{=?}FILE��|FILE��',      4040, sys_ftp_setLogFile,     'FTP�̃R�}���h���O��FILE�ɋL�^����',   'FTP�낮�ӂ����邹���Ă�');
  //-���[��
  AddFunc  ('���[����M',        'DIR��|DIR��',  4050, sys_pop3_recv_indy10, 'POP3�Ńt�H���_DIR�փ��[������M���A��M�������[���̌�����Ԃ��B', '�߁[�邶�サ��');
  AddFunc  ('���[�����M',        '',             4051, sys_smtp_send_indy10, 'SMTP�Ń��[���𑗐M����', '�߁[�邻������');
  AddStrVar('���[���z�X�g',      '',4052,'','�߁[��ق���');
  AddStrVar('���[��ID',          '',4053,'','�߁[��ID');
  AddStrVar('���[���p�X���[�h',  '',4054,'','�߁[��ς���[��');
  AddStrVar('���[���|�[�g',      '',4055,'','�߁[��ہ[��');
  AddIntVar('���[����M���폜',   0,4056,'','�߁[�邶�サ�񂶂�������');
  AddStrVar('���[�����o�l',      '',4057,'','�߁[�邳�������ɂ�');
  AddStrVar('���[������',        '',4058,'','�߁[�邠�Ă���');
  AddStrVar('���[������',        '',4059,'','�߁[�邯��߂�');
  AddStrVar('���[���{��',        '',4060,'','�߁[��ق�Ԃ�');
  AddStrVar('���[���Y�t�t�@�C��','',4061,'','�߁[��Ă�Ղӂ�����');
  AddStrVar('���[��HTML',        '',4065,'HTML���[�������Ƃ���HTML��ݒ�','�߁[��HTML');
  AddStrVar('���[��CC',          '',4066,'','�߁[��CC');
  AddStrVar('���[��BCC',         '',4067,'','�߁[��BCC');
  AddStrVar('���[���w�b�_',      '',4068,'���M���ɒǉ��������w�b�_���n�b�V���`���ő�����Ă����B','�߁[��ւ���');
  AddStrVar('���[���I�v�V����',  '',4062,'���[����M��(APOP|SASL|SSL)�A���[�����M��(LOGIN|PLAIN|SSL)�𕡐��w��\�B������(IMPLICIT_TLS|REQUIRE_TLS|EXPLICIT_TLS)���w��\�B','�߁[�邨�Ղ����');
  AddFunc  ('���[�����X�g�擾',  '',4063, sys_pop3_list_indy10, 'POP3�Ń��[���̌����ƃT�C�Y�̈ꗗ���擾����', '�߁[��肷�Ƃ���Ƃ�');
  AddFunc  ('���[���폜',     'A��',4064, sys_pop3_dele_indy10, 'POP3��A�Ԗڂ̃��[�����폜����', '�߁[�邳������');
  AddFunc  ('GMAIL��M','ACCOUNT��PASSWORD��DIR��|DIR��',4069, sys_gmail_recv, 'ACCOUNT��PASSWORD�𗘗p����GMail����M����B', 'GMAIL���サ��');
  AddFunc  ('GMAIL���M','ACCOUNT��PASSWORD��',4049, sys_gmail_send, 'ACCOUNT��PASSWORD�𗘗p����GMail�֑��M����B', 'GMAIL��������');
  AddFunc  ('YAHOO���[����M','ACCOUNT��PASSWORD��DIR��|DIR��',4133, sys_yahoo_recv, 'ACCOUNT��PASSWORD�𗘗p����Yahoo!���[������M����B', 'YAHOO�߁[�邶�サ��');
  AddFunc  ('YAHOO���[�����M','ACCOUNT��PASSWORD��',4134, sys_yahoo_send, 'ACCOUNT��PASSWORD�𗘗p����Yahoo!���[���𑗐M����B', 'YAHOO�߁[�邶�サ��');
  AddFunc  ('YAHOOBB���[����M','ACCOUNT��PASSWORD��DIR��|DIR��',4135, sys_yahoobb_recv, 'ACCOUNT��PASSWORD�𗘗p����Yahoo!BB���[������M����B', 'YAHOOBB�߁[�邶�サ��');
  AddFunc  ('YAHOOBB���[�����M','ACCOUNT��PASSWORD��',4136, sys_yahoobb_send, 'ACCOUNT��PASSWORD�𗘗p����Yahoo!BB���[���𑗐M����B', 'YAHOOBB�߁[�邶�サ��');
  AddFunc  ('���[��������M',    'DIR��FROM����TO�܂�|DIR��',  4137, sys_pop3_recv_indy10split, 'FROM(0�N�_)����TO�܂ł̌������w�肵��POP3�Ńt�H���_DIR�փ��[������M����B', '�߁[��Ԃ񂩂��サ��');
  AddFunc  ('GMAIL������M','ACCOUNT��PASSWORD��DIR��FROM����TO�܂�|DIR��',4138, sys_gmail_recv_split, 'FROM(0�N�_)����TO�܂Ō������w�肵��ACCOUNT��PASSWORD�𗘗p����GMail����M����B', 'GMAIL�Ԃ񂩂��サ��');
  //-EML
  AddFunc  ('EML�t�@�C���J��', 'F��',4080, sys_eml_load , 'EML�t�@�C�����J��', 'EML�ӂ�����Ђ炭');
  AddFunc  ('EML�p�[�g���擾','',4081, sys_eml_part_count, 'EML�t�@�C���ɂ����p�[�g�����邩���擾���ĕԂ��B', 'EML�ρ[�Ƃ�������Ƃ�');
  AddFunc  ('EML�p�[�g�ꗗ�擾','',4082, sys_eml_part_type, 'EML�t�@�C���̃p�[�g��ނ̈ꗗ�擾���ĕԂ��B', 'EML�ρ[�Ƃ�����񂵂�Ƃ�');
  AddFunc  ('EML�e�L�X�g�擾','A��',4083, sys_eml_getText, 'EML�t�@�C����A�Ԗڂ̃p�[�g���e�L�X�g�Ƃ��Ď擾����B', 'EML�Ă����Ƃ���Ƃ�');
  AddFunc  ('EML�Y�t�t�@�C���ۑ�','A��F��|F��',4084,sys_eml_getAttach,'EML�t�@�C����A�Ԗ�(1~n)�̃p�[�g�����o����F�֕ۑ�����B', 'EML�Ă�Ղӂ�����ق���');
  AddFunc  ('EML�S�e�L�X�g�擾','',4085,sys_eml_getAllText,'EML�t�@�C���Ɋ܂܂��e�L�X�g��S���擾���ĕԂ��B', 'EML����Ă����Ƃ���Ƃ�');
  AddFunc  ('EML�w�b�_�擾','',4086,sys_eml_getHeader,'EML�t�@�C���̃w�b�_���n�b�V���`���ɂ��ĕԂ�', 'EML�ւ�������Ƃ�');
  AddFunc  ('���[���w�b�_�G���R�[�h','{=?}S��',4087,sys_mail_convHeader,'���[���w�b�_�p�ɕ�����S��ϊ�����', '�߁[��ւ������񂱁[��');

  //-TCP/IP
  AddFunc  ('IP�A�h���X�擾','{=?}S��|S��|S����', 4073, sys_get_ip, '�h���C��S��IP�A�h���X���擾����', 'IP���ǂꂷ����Ƃ�');
  AddFunc  ('�z�X�g���擾','{=?}S��|S��|S����', 4074, sys_get_host, 'IP�A�h���XS����z�X�g�����擾����', '�ق��Ƃ߂�����Ƃ�');
  AddFunc  ('TCP_COMMAND','TCPID,A,B', 4070, sys_tcp_command, 'lib\nakonet.nako��TCP�N���C�A���g�Ŏg��', 'TCP_COMMAND');
  AddFunc  ('TCP_SVR_COMMAND','{�O���[�v}S,A,B', 4071, sys_tcp_svr_command, 'lib\nakonet.nako��TCP�T�[�o�[�Ŏg��', 'TCP_SVR_COMMAND');
  AddFunc  ('UDP_COMMAND','{�O���[�v}S,A,B', 4075, sys_udp_command, 'lib\nakonet.nako��UDP�Ŏg��', 'UDP_COMMAND');

  //-NTP
  AddFunc  ('NTP��������','{=?}S��', 4076, sys_ntp_sync, 'NTP�T�[�o�[S�ɐڑ����Č��ݎ������C������B�����ȗ�����ƁAring�T�[�o�[�𗘗p����B���������1�A���s�����0��Ԃ�', 'NTP�������ǂ���');

  //-PING
  AddFunc  ('PING','{=?}HOST��|HOST��|HOST��', 4072, sys_ping, 'HOST��PING���ʂ邩�m�F����B�ʂ�Ȃ����0��Ԃ�', 'PING');
  AddFunc  ('�񓯊�PING','{=?}EVENT��HOST��', 4077, sys_ping_async, 'HOST��PING���ʂ邩�񓯊��Ŋm�F����B���ʂ͑������Ŏw�肵���֐��̈����Ƃ��ĕԂ��B', '�Ђǂ���PING');
  //-�I�v�V����
  AddIntVar('�o�߃_�C�A���O',1, 4090, 'FTP/HTTP�Ōo�߃_�C�A���O��\�����邩�ǂ����B', '�������������낮');

  //-JSON
  AddFunc  ('JSON�G���R�[�h','{=?}V��|V��',     4130, sys_json_encode, '�lV��JSON�`���ɕϊ�����', 'JSON���񂱁[��');
  AddFunc  ('JSON�f�R�[�h','{=?}JSON��|JSON��', 4131, sys_json_decode, '������JSON��ϐ��ɕϊ�����', 'JSON�ł��[��');

  //-Web�T�[�r�X
  AddFunc  ('�n�}�\��','{=?}V��',          4139, sys_show_map, '�ꏊV��\������', '�����Ђ傤��');
  AddFunc  ('�o�H�\��','{=?}A����B��|B��', 4140, sys_show_route, 'A����B�ւ̌o�H��\������', '������Ђ傤��');

  //-nakonet.dll
  AddFunc  ('NAKONET_DLL�o�[�W����','', 4132, get_nakonet_dll_version, 'nakonet.dll�̃o�[�W�����𓾂�', 'NAKONET_DLL�΁[�����');

  //+�ԕr�T�[�r�X/���A�g(nakonet.dll)
  //-�ݒ�
  AddStrVar('�ԕrPORT',      '5029',    4100, '', '���т�PORT');
  AddStrVar('�ԕr�p�X���[�h','',          4101, '', '���т�ς���[��');
  //-�ԕr�T�[�r�X�̎��s��~
  AddFunc  ('�ԕr�T�[�r�X�N��','', 4105, sys_kabin_open, '�ԕr�T�[�r�X(���A�g�p)���J�n����', '���т񂳁[�т����ǂ�');
  AddFunc  ('�ԕr�T�[�r�X�I��','', 4106, sys_kabin_close, '�ԕr�T�[�r�X(���A�g�p)���I������', '���т񂳁[�т����イ��傤');
  //</����>

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

function TNetDialog.ShowDialog(stext, sinfo: AnsiString; Visible: Boolean;hObj:THANDLE=0): Boolean;
var
  msg: TMsg;
begin
  if hParent = 0 then hParent := nako_getMainWindowHandle;
  Status := statWork;

  // �_�C�A���O�̕\��
  hProgress  := CreateDialogA(
      hInstance, PAnsiChar(IDD_DIALOG_PROGRESS), hParent, @procProgress);

  // �_�C�A���O�ɏ���\��
  SetDlgWinText(hProgress, IDC_EDIT_TEXT, stext);
  SetDlgWinText(hProgress, IDC_EDIT_INFO, sinfo);
  if Visible then
    ShowWindow(hProgress, SW_SHOW)
  else
    ShowWindow(hProgress, SW_HIDE);

  // �_�E�����[�h���I������܂Ń_�C�A���O��\��
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
      // �A�C�h��
      //sleep(10);
      if hObj = 0 then
        WaitMessage()
      else
      begin
        if MsgWaitForMultipleObjects(1,hObj,false,100,QS_ALLINPUT) = WAIT_OBJECT_0 then
          hObj := 0;
      end;
    end;
  end;

  DestroyWindow(hProgress);
  Result := (Status = statComplete);
end;

var zero_progress_max_count: Integer;

procedure TNetDialog.Work(Sender: TObject; AWorkMode: TWorkMode; AWorkCount: Integer);
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
  if s_max = '0' then s_max := '�s��';
  s := '�ʐM�� (' + IntToStr(Trunc(AWorkCount/1024)) + '/' + s_max + ' KB) ' + target;
  setText(s);

  if not bMinMaxInitialized then
  begin
    // progress bar
    SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
      PBM_SETSTEP, 1, 0);
    // range
    SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
      PBM_SETRANGE, 0, MakeLong(0, 100));
    bMinMaxInitialized := true;
  end;
  // set pos

  if w_max > 0 then
  begin
    if iPrevPercent <> w_per then
    begin
      iPrevPercent := w_per;
      try
        SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
          PBM_SETPOS, w_per , LParam(BOOL(True)));
      except
      end;
    end;
  end else
  begin
    if AWorkCount > 0 then
    begin
      if iPrevPercent <> 100 then
      begin
        iPrevPercent := 100;
        SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
          PBM_SETPOS, 100 , LParam(BOOL(True)));
      end;
    end else
    begin
      if iPrevPercent <> 0 then
      begin
        iPrevPercent := 0;
        SendMessage(GetDlgItem(hProgress, IDC_PROGRESS1),
          PBM_SETPOS, 0 , LParam(BOOL(True)));
      end;
    end;
  end;
end;

procedure TNetDialog.Work64(Sender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  Work(Sender, AWorkMode, Integer(AWorkCOunt));
end;

procedure TNetDialog.WorkBegin(Sender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Integer);
begin
  hParent := nako_getMainWindowHandle;
  Self.WorkCount := AWorkCountMax;
  zero_progress_max_count := 0;
  bMinMaxInitialized := false;
  iPrevPercent := -1;
end;

procedure TNetDialog.WorkBegin64(Sender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  hParent := nako_getMainWindowHandle;
  Self.WorkCount := AWorkCountMax;
  zero_progress_max_count := 0;
  bMinMaxInitialized := false;
  iPrevPercent := -1;
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
