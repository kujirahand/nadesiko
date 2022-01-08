unit KSmtp;

interface
uses
  SysUtils, Classes, Windows, WinSock, WSockUtils, CommCtrl, unit_eml;

type
  TKSmtpThread = class;

  TSmtpInfo = record
    Host: string;
    Port: Integer;
    From: string;
    Rcpt: string;
    CC,
    BCC: string;
    User,
    Password: string;
    AuthLogin: Boolean;
    AuthMD5: Boolean;
    AuthPlain: Boolean;
    OnError: TNotifyEvent;
    OnComplete: TNotifyEvent;
    OnProgress: TKTcpProgressEvent;
  end;

  EKSmtp = class(Exception);
  TKSmtp = class(TComponent)
  private
    FHost: string;
    FPort: Integer;
    FFrom: string;
    FRcptTo: string;
    FJobThread: TKSmtpThread;
    FErrorCode: Integer;
    FErrorMsg: string;
    FResult: Boolean;
    FUser: string;
    FPassword: string;
    FAuthLogin: Boolean;
    FAuthMD5: Boolean;
    FAuthPlain: Boolean;
    //
    FOnError: TNotifyEvent;
    FOnComplete: TNotifyEvent;
    FOnProgress: TKTcpProgressEvent;
    FBCC: string;
    FCC: string;
    function SetInfo: TSmtpInfo;
    procedure JobOnError(Sender: TObject);
    procedure JobOnComplete(Sender: TObject);
    procedure setBCC(const Value: string);
    procedure setCC(const Value: string);
    procedure setFrom(const Value: string);
    procedure setRcptTo(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SendMailEasy(From, RcptTo, subject, body: string);
    procedure SendMailRawData(raw: TStringList);
    property Host: string read FHost write FHost;
    property Port: Integer read FPort write FPort;
    property From: string read FFrom write setFrom;
    property RcptTo: string read FRcptTo write setRcptTo;
    property CC: string read FCC write setCC;
    property BCC: string read FBCC write setBCC;
    property OnError: TNotifyEvent read FOnError write FOnError;
    property OnComplete: TNotifyEvent read FOnComplete write FOnComplete;
    property OnProgress: TKTcpProgressEvent read FOnProgress write FOnProgress;
    property ErrorCode: Integer read FErrorCode write FErrorCode;
    property ErrorMsg: string read FErrorMsg write FErrorMsg;
    property Result: Boolean read FResult write FResult;
    property AuthLogin: Boolean read FAuthLogin write FAuthLogin;
    property AuthMD5: Boolean read FAuthMD5 write FAuthMD5;
    property AuthPlain: Boolean read FAuthPlain write FAuthPlain;
    property User: string read FUser write FUser;
    property Password: string read FPassword write FPassword;
  end;

  TKSmtpThread = class(TThread)
  private
    tcp: TKTcpClient;
    FInfo: TSmtpInfo;
    FResult: Boolean;
    FBody: TStringList;
    _PerDone: Integer;
    _ProgMsg: string;
    _Cancel: Boolean;
    procedure tcpOnError(Sender: TObject);
    procedure RaiseError(code:Integer; msg: string);
    function CheckRetCode(var ret: string; OkCode: Integer): Boolean;
    function Progress(PerDone: Integer; msg: string): Boolean;
    //procedure ProgressSync;
    function GetAuthMD5Response(key: string): string;
    function GetAuthPainResponse: string;
  protected
    procedure Execute; override;
  public
    ErrorCode: Integer;
    ErrorMsg: string;
    constructor Create(info: TSmtpInfo; Body: TStringList); virtual;
    destructor Destroy; override;
    property Result: Boolean read FResult;
  end;

  TKSmtpDialog = class(TKSmtp)
  private
    procedure smtpOnProgress(PerDone: Integer; msg: string; var Cancel: Boolean);
    procedure smtpOnComplete(Sender: TObject);
    procedure smtpOnError(Sender: TObject);
  public
    ShowDialog: Boolean;
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure Send(from, rcptto, title, body, attach, html, cc, bcc, addHead: string);
  end;



implementation

uses unit_string, jconvert, jconvertex, DateUtils, nako_dialog_const,
  nako_dialog_function, md5, nadesiko_version;

var
  FEmlId: Integer = 0;


{ TKSmtpThread }

function TKSmtpThread.CheckRetCode(var ret: string;
  OkCode: Integer): Boolean;
var
  s: string;
begin
  s := getChars_s(ret, ['0'..'9']);
  ret := Trim(ret);
  Result := (OkCode = StrToIntDef(s, -1));
end;

constructor TKSmtpThread.Create(info: TSmtpInfo; Body: TStringList);
begin
  // �ݒ�
  tcp := TKTcpClient.Create(nil);
  tcp.Host := info.Host;
  tcp.Port := info.Port;
  tcp.OnError := tcpOnError; // wrap
  tcp.Timeout := 30 * 1000;
  // �{��
  FBody := TStringList.Create;
  FBody.Assign(Body);
  // ���p��
  FInfo := info;
  Self.FreeOnTerminate := True;
  Self.OnTerminate := FInfo.OnComplete;
  FResult := False;

  // Check field
  FInfo.From := ExtractMailAddress(FInfo.From);
  FInfo.Rcpt := FInfo.Rcpt; // ExtractMailAddress�̓����A�h���P��������B
  if Copy(FInfo.From,1,1) <> '<' then FInfo.From := '<' + FInfo.From + '>';
  
  inherited Create(False);
end;

destructor TKSmtpThread.Destroy;
begin
  FreeAndNil(FBody);
  FreeAndNil(tcp);
  inherited;
end;

procedure TKSmtpThread.Execute;
var
  ret, cmd, s, ss: string;
  i: Integer;
  CanAuthLogin  : Boolean;
  CanAuthMD5    : Boolean;
  CanAuthPlain  : Boolean;
  ToList: TStringList;
begin
  // �ڑ�
  if not Progress(0, FInfo.Host +  '�ɐڑ����܂��B') then Exit;
  try
    tcp.Open;
  except on E: Exception do
    RaiseError(0, E.Message);
  end;
  if Terminated then Exit;
  // ���M����
  try
  try
    // �菇�ʂ��
    // �T�[�o�[�̈��A����M
    ret := tcp.recvln; // 220 SMTP ready
    if CheckRetCode(ret, 220) = False then begin RaiseError(0,'�T�[�o�[�̏������ł��Ă��܂���B'); Exit; end;

    // �N���C�A���g�̈��A
    tcp.sendLn('EHLO ' + tcp.SelfIP); // ���O��^����
    ret := tcp.RecvLn; // 250-xxx OR 250 xxx

    CanAuthLogin := False;
    CanAuthMD5   := False;
    CanAuthPlain := False;

    //--------------------------------------------------------------------------
    // �F�؃��[�`��
    //--------------------------------------------------------------------------
    // �F�؂��T�|�[�g���邩�`�F�b�N
    if Copy(ret,1,3) <> '250' then
    begin
      // EHLO ���T�|�[�g���Ȃ��Â��T�[�o�[�p
      // �F�؂Ȃ����O�C��
      tcp.SendLn('HELO ' + tcp.SelfIP);
      ret := tcp.RecvLn; // 250 OK
      if CheckRetCode(ret, 250) = False then begin RaiseError(0,'�T�[�o�[���狑�₳��܂����B'); Exit; end;
    end else
    begin
      // �T�|�[�g���Ă���g���R�}���h���擾
      while True do begin
        ret := UpperCase(ret);
        s   := ret;
        System.Delete(s, 1, 4); // del 250-
        cmd := getToken_s(s, ' ');
        if cmd = 'AUTH' then
        begin
          if Pos('LOGIN',    s) > 0 then CanAuthLogin := True;
          if Pos('CRAM-MD5', s) > 0 then CanAuthMD5   := True;
          if Pos('PLAIN',    s) > 0 then CanAuthPlain := True;
        end;
        if Copy(ret,1,4) = '250 ' then Break; // �R�}���h�Ō�
        ret := tcp.RecvLn;
      end;
    end;

    // �F��
    if FInfo.AuthMD5 and CanAuthMD5 then
    begin
      // AUTH CRAM-MD5
      tcp.SendLn('AUTH CRAM-MD5'); // �F�ؕ������w��
      ret := tcp.RecvLn; // 334 PDQ4NzQuMTAwNzI3Njc3N0Bhc2FvLmdjZC5vcmc+
      if CheckRetCode(ret, 334) = False then begin RaiseError(0,'���O�C���Ɏ��s���܂����B"AUTH CRAM-MD5"���󂯕t���܂���B'); Exit; end;
      ret := DecodeBase64(ret);
      // CRAM-MD5 ���v�Z
      cmd := GetAuthMD5Response(ret);
      // ���M
      tcp.SendLn(cmd);
      if CheckRetCode(ret, 235) = False then begin RaiseError(0,'���O�C���Ɏ��s���܂����B�p�X���[�h���Ⴂ�܂��B'); Exit; end;
    end else
    if FInfo.AuthLogin and CanAuthLogin then
    begin
      // AUTH LOGIN
      tcp.SendLn('AUTH LOGIN');
      ret := tcp.RecvLn; // 334 VXNlcm5hbWU6
      if CheckRetCode(ret, 334) = False then begin RaiseError(0,'���O�C���Ɏ��s���܂����BLOGIN�R�}���h���󂯕t���܂���B'); Exit; end;
      ret := UpperCase(DecodeBase64(ret));
      if ret <> 'USERNAME:' then begin RaiseError(0,'���O�C���Ɏ��s���܂����BLOGIN�R�}���h�֖��Ή��̕ԓ�������܂��B'); Exit; end;
      // Username:
      cmd := EncodeBase64(FInfo.User);
      tcp.SendLn(cmd);
      ret := tcp.RecvLn; // 334 UGFzc3dvcmQ6
      if CheckRetCode(ret, 334) = False then begin RaiseError(0,'���O�C���Ɏ��s���܂����B���[�U�[��'+FInfo.User+'�����₳��܂����B'); Exit; end;
      ret := UpperCase(DecodeBase64(ret));
      if ret <> 'PASSWORD:' then begin RaiseError(0,'���O�C���Ɏ��s���܂����BLOGIN�R�}���h�֖��Ή��̕ԓ�������܂��B'); Exit; end;
      // Password:
      cmd := EncodeBase64(FInfo.Password);
      tcp.SendLn(cmd);
      ret := tcp.RecvLn; // 334 UGFzc3dvcmQ6
      if CheckRetCode(ret, 235) = False then begin RaiseError(0,'���O�C���Ɏ��s���܂����B�p�X���[�h���Ⴂ�܂��B'); Exit; end;
    end else
    if FInfo.AuthPlain and CanAuthPlain then
    begin
      // AUTH PLAIN xxx
      cmd := 'AUTH PLAIN ' + GetAuthPainResponse;
      tcp.SendLn(cmd);
      ret := tcp.RecvLn; //235 go ahead
      if CheckRetCode(ret, 235) = False then begin RaiseError(0,'���O�C���Ɏ��s���܂����B���[�U�[�����p�X���[�h���Ⴂ�܂��B'); Exit; end;
    end else
    ;

    if not Progress(0, DecodeHeaderString2(FInfo.Rcpt)+'�֑��M��𑗐M���܂��B') then Exit;

    //--------------------------------------------------------------------------
    // ���Đ�w�b�_���M
    //--------------------------------------------------------------------------
    // ���M���̑��M
    tcp.SendLn('MAIL FROM: ' + FInfo.From);
    ret := tcp.recvln; // 250 OK
    if CheckRetCode(ret, 250) = False then begin RaiseError(0,'���o�l�̐ݒ�ŃT�[�o�[���狑�ۂ���܂����B�T�[�o�[�ւ̔F�؂��K�v��������܂���B'); Exit; end;

    // ����̑��M
    ToList := TStringList.Create;
    try
    try
      ss := FInfo.Rcpt + ','#13#10' ' + FInfo.CC + ','#13#10' ' + FInfo.BCC;
      ToList.Text := ss;
      ss := '';
      for i := 0 to ToList.Count - 1 do
      begin
        s := Trim(ExtractMailAddress(ToList.Strings[i]));
        if s = ''             then Continue;
        if Pos('@', s) = 0    then Continue;
        if Copy(s,1,2) = '<=' then Continue;
        s := Trim(s);
        tcp.SendLn('RCPT TO: ' + s);
        ret := tcp.recvln; // 250 OK
        if CheckRetCode(ret, 250) = False then begin RaiseError(0,'���M��"'+s+'"���ݒ�ł��܂���ł����B����:"' + ret + '"'); Exit; end;
        if Terminated then Exit;
        ss := ss + s + #13#10; // for log
      end;
      // for log
      ToList.Text := ss;
      ToList.SaveToFile(ExtractFilePath(ParamStr(0)) + 'rcptto.txt');
    except
      on E:Exception do
      begin
        RaiseError(0, E.Message);
        Exit;
      end;
    end;
    finally
      ToList.Free;
    end;
    if not Progress(0, '���[���{�̂𑗐M:' + DecodeHeaderString2(ss)) then Exit;

    // ���[���f�[�^�̑��M
    tcp.SendLn('DATA');
    ret := tcp.recvln; // 354 Enter mail,end with "." on a line by ltself
    if CheckRetCode(ret, 354) = False then begin RaiseError(0,'�f�[�^���ݒ�ł��܂���ł����B'); Exit; end;
    // �{�����ǂ�ǂ񑗐M
    for i := 0 to FBody.Count - 1 do
    begin
      if not Progress(Trunc(100*i/FBody.Count), FInfo.Rcpt+'�֑��M��') then Exit;
      if Terminated then Exit;
      tcp.SendLn(FBody.Strings[i]);
    end;
    // �{���̏I�[
    tcp.SendLn('.');
    // OK ?
    ret := tcp.recvln; // 250 OK
    if CheckRetCode(ret, 250) = False then begin RaiseError(0,'�{���̑��M�Ɏ��s���܂����B'); Exit; end;
    // ���M����������
    tcp.SendLn('QUIT');
    ret := tcp.recvln; // 221 delivering mail
    if CheckRetCode(ret, 221) = False then begin RaiseError(0,'�{���̑��M�Ɏ��s'); Exit; end;
    //---
    FResult := True;
  except
    on E:Exception do
    begin
      RaiseError(0, E.Message);
      Exit;
    end;
  end;
  finally
    tcp.Close; // �Ō�ɐؒf����
  end;
  if Assigned(FInfo.OnComplete) then FInfo.OnComplete(Self);
end;

function TKSmtpThread.GetAuthMD5Response(key: string): string;
var
  i: Integer;
  pass, ipad, opad: string;
  ihash, ohash: MD5Digest;
begin
  // ��������p�X���[�h�͔F���s�\
  pass := FInfo.Password;
  if Length(pass) > 64 then pass := Copy(pass,1,64);

  // ipad/opad ��������
  SetLength(ipad, 64);
  SetLength(opad, 64);
  for i := 1 to Length(ipad) do
  begin
    ipad[i] := #$36;
    opad[i] := #$5c;
  end;

  // password �� ipad/opad �� xor
  for i := 1 to Length(pass) do
  begin
    ipad[i] := Char( Ord(ipad[i]) xor Ord(pass[i]) );
    opad[i] := Char( Ord(opad[i]) xor Ord(pass[i]) );
  end;

  // Charenge �� �Ȃ��� MD5 ���擾
  ihash := MD5String(key + ipad);
  ohash := MD5String(key + opad);

  // MD5 �� 16�i�\�L���ĘA��
  Result := FInfo.User + ' ';
  for i := 0 to High(ihash) do
  begin
    Result := Result + IntToHex(ihash[i], 2);
  end;
  for i := 0 to High(ohash) do
  begin
    Result := Result + IntToHex(ohash[i], 2);
  end;

  // ���ʂ� base64 ���Ċ���
  Result := EncodeBase64(Result);
end;

function TKSmtpThread.GetAuthPainResponse: string;
begin
  Result := EncodeBase64( #0 + FInfo.User + #0 + FInfo.Password );
end;

function TKSmtpThread.Progress(PerDone: Integer; msg: string): Boolean;
begin
  Result := True;
  if Assigned(FInfo.OnProgress) then
  begin
    _PerDone := PerDone;
    _ProgMsg := msg;
    _Cancel  := False;
    FInfo.OnProgress(_PerDone, _ProgMsg, _Cancel);
    //Synchronize(ProgressSync);
    if _Cancel = True then Result := False;
  end;
end;
{
procedure TKSmtpThread.ProgressSync;
begin
  FInfo.OnProgress(_PerDone, _ProgMsg, _Cancel);
end;
}
procedure TKSmtpThread.RaiseError(code: Integer; msg: string);
begin
  ErrorCode := code;
  ErrorMsg  := msg;
  if Assigned(FInfo.OnError) then
  begin
    FInfo.OnError(Self);
  end;
  Terminate;
end;

procedure TKSmtpThread.tcpOnError(Sender: TObject);
begin
  ErrorCode := tcp.ErrorCode;
  ErrorMsg  := tcp.ErrorMsg;
  if Assigned(FInfo.OnError) then
  begin
    FInfo.OnError(Self);
  end;
  Terminate;
end;

{ TKSmtp }

constructor TKSmtp.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHost := '';
  FPort := 25;
  FJobThread := nil;
end;

destructor TKSmtp.Destroy;
begin
  inherited;
end;

procedure TKSmtp.JobOnComplete(Sender: TObject);
begin
  ErrorCode := FJobThread.ErrorCode;
  ErrorMsg  := FJobThread.ErrorMsg;
  FResult := FJobThread.Result;
  if Assigned(FOnComplete) then
  begin
    FOnComplete(Self);
  end;
end;

procedure TKSmtp.JobOnError(Sender: TObject);
begin
  ErrorCode := FJobThread.ErrorCode;
  ErrorMsg  := FJobThread.ErrorMsg;
  if Assigned(FOnError) then
  begin
    FOnComplete(Self);
  end;
end;

procedure TKSmtp.SendMailEasy(From, RcptTo, subject, body: string);
var
  raw: TStringList;
begin
  Self.From := From;
  Self.RcptTo := RcptTo;

  // ENCODE
  subject := jconvert.CreateHeaderString2(subject);
  body := jconvert.sjis2jis83(body);

  raw := TStringList.Create;
  try
    raw.Add('From: ' + From);
    raw.Add('Reply-to: ' + From);
    raw.Add('To: ' + RcptTo);
    raw.Add('Content-type: text/plain;');
    raw.Add(#9'charset="iso-2022-jp"');
    raw.Add('Date: ' + GetMailDate(Now));
    raw.Add('X-Priority: 3');
    raw.Add('X-Mailer: nadesiko-mail 0.1');
    raw.Add('Subject: ' + subject);
    raw.Add('');
    raw.Add(body);

    SendMailRawData(raw);
  finally
    raw.Free;
  end;
end;

procedure TKSmtp.SendMailRawData(raw: TStringList);
var
  info: TSmtpInfo;
begin
  info := SetInfo;
  FJobThread := TKSmtpThread.Create(info, CheckDot(raw));
end;

procedure TKSmtp.setBCC(const Value: string);
begin
  FBCC := CreateHeaderStringMail(Value);
end;

procedure TKSmtp.setCC(const Value: string);
begin
  FCC := CreateHeaderStringMail(Value);
end;

procedure TKSmtp.setFrom(const Value: string);
begin
  FFrom := ExtractMailAddress(Value);
end;

function TKSmtp.SetInfo: TSmtpInfo;
begin
  Result.Host     := Host;
  Result.Port     := Port;
  Result.From     := ExtractMailAddress(From);
  Result.Rcpt     := CreateHeaderStringMail(RcptTo);
  Result.OnError    := JobOnError;
  Result.OnComplete := JobOnComplete;
  Result.OnProgress := OnProgress;
  Result.CC         := FCC;
  Result.BCC        := FBCC;
  // �F�ؗp
  Result.User      := User;
  Result.Password  := Password;
  Result.AuthLogin := AuthLogin;
  Result.AuthMD5   := AuthMD5;
  Result.AuthPlain := AuthPlain;
end;

procedure TKSmtp.setRcptTo(const Value: string);
begin
    FRcptTo := CreateHeaderStringMail(Value);
    //FRcptTo := ExtractMailAddress(Value);
end;


function CheckFilename(fname: string): string;
const
  fchars: TSysCharSet = ['0'..'9','a'..'z','A'..'Z','!','#','$','%','(',')',
                    '-','=','~','@','.','_', '\', ' ',':','[',']'];
var
  i: Integer;
begin
  i := 1;
  while i <= Length(fname) do
  begin
    if fname[i] in LeadBytes then
    begin
      Result := Result + fname[i];
      Inc(i);
      if i < Length(fname) then
      begin
        Result := Result + fname[i];
        Inc(i);
      end;
    end else
    begin
      if fname[i] in fchars then Result := Result + fname[i]
                            else Result := Result + '_';
      Inc(i);

    end;
  end;
end;





{ TKSmtpDialog }

constructor TKSmtpDialog.Create(AOwner: TComponent);
begin
  inherited;
  Self.OnError    := smtpOnError;
  Self.OnComplete := smtpOnComplete;
  Self.OnProgress := smtpOnProgress;
  ShowDialog := True;
end;

destructor TKSmtpDialog.Destroy;
begin

  inherited;
end;

procedure TKSmtpDialog.Send(from, rcptto, title, body, attach, html, cc, bcc, addHead: string);
var
  eml: TEml;
begin
  eml := TEml.Create(nil);
  try
    // ���[���̍쐬
    eml.SetEmlEasy(from, rcptto, title, body, attach, html, cc, addHead);

    // �����̐ݒ�
    Self.From   := from;
    Self.RcptTo := rcptto;
    Self.CC     := cc;
    Self.BCC    := bcc;

    // ���M����
    // eml.SaveToFile(ExtractFilePath(ParamStr(0)) + 'sendmail.eml');
    Self.SendMailRawData(eml.GetAsEml);

    // �_�C�A���O�̕\��
    ShowProgressDialog('���[�����M','���[�����M������','', ShowDialog);
    if Self.Result = False then
    begin
      raise Exception.Create('���[�����M�Ɏ��s�B' + Self.ErrorMsg);
    end;
  finally
    eml.Free;
  end;
end;

procedure TKSmtpDialog.smtpOnComplete(Sender: TObject);
begin
  DialogFlagComplete := True;
end;

procedure TKSmtpDialog.smtpOnError(Sender: TObject);
begin
  DialogFlagComplete := True;
end;

procedure TKSmtpDialog.smtpOnProgress(PerDone: Integer; msg: string;
  var Cancel: Boolean);
begin
  // download text
  SetDlgWinText(DialogHandle, IDC_EDIT_TEXT, msg);

  // progress bar
  SendMessage(GetDlgItem(DialogHandle, IDC_PROGRESS1),
    PBM_SETSTEP, 1, 0);
  // range
  SendMessage(GetDlgItem(DialogHandle, IDC_PROGRESS1),
    PBM_SETRANGE, 0, MakeLong(0, 100));

  // pos
  SendMessage(GetDlgItem(DialogHandle, IDC_PROGRESS1),
    PBM_SETPOS, PerDone , LParam(BOOL(True)));

  Cancel := DialogFlagStop;
  SetDlgWinText(DialogHandle, IDC_EDIT_TEXT, msg);
end;

end.
