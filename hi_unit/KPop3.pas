unit KPop3;

interface
uses
  SysUtils, Classes, Windows, WinSock, WSockUtils, CommCtrl;

type
  TKPop3Thread = class; // �O���錾
  TPop3ProgressEvent = TKTcpProgressEvent;

  PPop3Info = ^TPop3Info;
  TPop3Info = record
    User: string;
    Pass: string;
    Port: Integer;
    Host: string;
    APop: Boolean;
    command: string;
    OnComplete: TNotifyEvent;
    OnError   : TNotifyEvent;
    OnProgress: TPop3ProgressEvent;
  end;

  EKPop3 = class(Exception); // �G���[
  TKPop3 = class(TComponent)
  private
    // ���
    FHost       : string;
    FPort       : Integer;
    FUser       : string;
    FPassword   : string;
    FAPop       : Boolean;
    // �C�x���g�߂�l
    FErrorCode  : Integer;
    FErrorMsg   : string;
    FResult     : Boolean;
    // �C�x���g
    FOnComplete : TNotifyEvent;
    FOnError    : TNotifyEvent;
    FOnProgress : TPop3ProgressEvent;
    // �����Ŏg��
    FJobThread  : TKPop3Thread;
    procedure ThreadOnTerminate(Sender: TObject);
    procedure ThreadOnError(Sender: TObject);
    function SetInfo: TPop3Info;
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure GetList;
    procedure RecvAll(SaveDir: string);
    procedure DeleteMail(no: Integer);
    procedure DeleteMailAll;
    // --- property
    property Host: string read FHost write FHost;
    property Port: Integer read FPort write FPort;
    property User: string read FUser write FUser;
    property Password: string read FPassword write FPassword;
    property ErrorCode: Integer read FErrorCode write FErrorCode;
    property ErrorMsg: string read FErrorMsg write FErrorMsg;
    property Result: Boolean read FResult write FResult;
    property APop: Boolean read FAPop write FAPop;
    // --- event
    property OnComplete: TNotifyEvent read FOnComplete write FOnComplete;
    property OnError: TNotifyEvent read FOnError write FOnError;
    property OnProgress: TPop3ProgressEvent read FOnProgress write FOnProgress;
  end;

  TThreadDummy = class
  private
    FFreeOnTerminate: Boolean;
  protected
    procedure Execute; virtual;
  public
    Terminated: Boolean;
    constructor Create(Suspend:Boolean);
    destructor Destroy; override;
    procedure Terminate;
    property FreeOnTerminate: Boolean read FFreeOnTerminate write FFreeOnTerminate;
  end;

  TKPop3Thread = class(TThread)
  private
    FPop3Info: TPop3Info;
    tcp: TKTcpClient;
    // �O�����J�p
    FErrorCode: Integer;
    FErrorMsg: string;
    FResult: Boolean;
    FResultStr: string;
    procedure RaiseError(Code: Integer; Msg: string);
    function CheckRetCode(var ret: string): Boolean;
    function Progress(PerDone: Integer; Msg: string): Boolean;
  protected
    procedure Execute; override;
    function LoginProc: Boolean;
    function ListProc: Boolean;
    function LoginAPopProc(LoginCode: string): Boolean;
    function LoginNormalProc(LoginCode: string): Boolean;
    function RecvAllProc(SaveDir: string): Boolean;
    function DeleteOne(no: Integer): Boolean;
    function DeleteAll: Boolean;
  public
    constructor Create(info: TPop3Info); virtual;
    destructor Destroy; override;
    property ErrorCode: Integer read FErrorCode write FErrorCode;
    property ErrorMsg: string read FErrorMsg write FErrorMsg;
    property Result: Boolean read FResult write FResult;
    property ResultStr: string read FResultStr;
  end;

  TKPop3Dialog = class(TKPop3)
  private
    procedure pop3OnProgress(PerDone: Integer; msg: string; var Cancel: Boolean);
    procedure pop3OnComplete(Sender: TObject);
    procedure pop3OnError(Sender: TObject);
  public
    ShowDialog: Boolean;
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    function Pop3RecvAll(SaveDir: string; FlagDelete: Boolean): Integer; // ��M����������Ԃ�
    function Pop3List: string;
    procedure Pop3Dele(no: Integer);
  end;


implementation

uses unit_string, nako_dialog_function, nako_dialog_const, md5;

{ TKPop3 }

constructor TKPop3.Create(AOwner: TComponent);
begin
  inherited;

  FUser := '';
  FPassword := '';

  FPort := 110;
  FHost := '';
end;

procedure TKPop3.DeleteMail(no: Integer);
var
  info: TPop3Info;
begin
  info := SetInfo;
  info.command := 'dele ' + IntToStr(no);
  FJobThread := TKPop3Thread.Create(info);
end;

procedure TKPop3.DeleteMailAll;
var
  info: TPop3Info;
begin
  info := SetInfo;
  info.command := 'deleteall';
  FJobThread := TKPop3Thread.Create(info);
end;

destructor TKPop3.Destroy;
begin
  inherited;
end;

procedure TKPop3.GetList;
var
  info: TPop3Info;
begin
  info := SetInfo;
  info.command := 'list';
  FJobThread := TKPop3Thread.Create(info);
end;

procedure TKPop3.RecvAll(SaveDir: string);
var
  info: TPop3Info;
begin
  // CreateDir
  if Copy(SaveDir, Length(SaveDir), 1) <> '\' then
  begin
    SaveDir := SaveDir + '\';
  end;
  ForceDirectories(SaveDir);
  //
  info := SetInfo;
  info.command := 'recvall ' + SaveDir;
  FJobThread := TKPop3Thread.Create(info);
end;

function TKPop3.SetInfo: TPop3Info;
begin
  // �ڑ����
  Result.User := User;
  Result.Pass := Password;
  Result.Host := Host;
  Result.Port := Port;
  Result.APop := APop;
  // �C�x���g
  Result.OnComplete := ThreadOnTerminate;
  Result.OnError    := ThreadOnError;
  Result.OnProgress := OnProgress;
end;

procedure TKPop3.ThreadOnError(Sender: TObject);
begin
  // �W���u�̃G���[�ʒm
  FErrorMsg := FJobThread.ErrorMsg;
  if Assigned(FOnError) then
  begin
    FOnError(Self);
  end;
end;

procedure TKPop3.ThreadOnTerminate(Sender: TObject);
begin
  // �W���u�̏I���ʒm
  FErrorMsg := FJobThread.ResultStr;
  FResult   := FJobThread.Result;
  if Assigned(FOnComplete) then
  begin
    FOnComplete(Self);
  end;
end;

{ TKPop3Thread }

function TKPop3Thread.CheckRetCode(var ret: string): Boolean;
var
  code: string;
begin
  Result := False;
  code := UpperCase(Copy(ret, 1,3));
  if code = '+OK' then
  begin
    Result := True;
    System.Delete(ret, 1, 3);
  end else
  begin
    code := UpperCase(Copy(ret, 1,4));
    if code = '-ERR' then
    begin
      System.Delete(ret, 1, 4);
    end;
  end;
  ret := Trim(ret);
end;

constructor TKPop3Thread.Create(info: TPop3Info);
begin
  // ������
  FResult := False;

  // ���𓾂�
  FPop3Info := info;

  // TCP�N���C�A���g�ɋ�����
  tcp := TKTcpClient.Create(nil);
  tcp.Host := info.Host;
  tcp.Port := info.Port;
  tcp.Timeout := 30 * 1000;
  Self.FreeOnTerminate := True;

  // �I�����ʒm
  { �Ȃ����������Ȃ��̂Ŏ蓮�ŌĂ�
  if Assigned(info.OnComplete) then
    Self.OnTerminate := info.OnComplete;
  }

  inherited Create(False);
end;

function TKPop3Thread.DeleteAll: Boolean;
var
  ret: string;
  i, cnt: Integer;
begin
  Result := False;

  if not Progress(0, '���[���{�b�N�X����ɂ��܂��B') then Exit;

  // STAT �Ń��[���̌����`�F�b�N
  tcp.SendLn('STAT');
  ret := tcp.RecvLn;
  if not CheckRetCode(ret) then
  begin
    RaiseError(0, '���[���폜��STAT���G���[��Ԃ��܂����B'); Exit;
  end;
  cnt := StrToIntDef(getChars_s(ret, ['0'..'9']), 0);
  // DELE �Ŏ��X�ƍ폜
  for i := 1 to cnt do
  begin
    if not Progress(Trunc((i-1) / cnt * 100), IntToStr(i) + '�Ԗڂ��폜') then Exit;
    tcp.SendLn('DELE ' + IntToStr(i));
    ret := tcp.RecvLn;
    if not CheckRetCode(ret) then
    begin
      RaiseError(0, IntToStr(i) + '�Ԗڂ̃��[���폜�Ɏ��s�B'); Exit;
    end;
  end;
  // QUIT �Ŕ��f
  tcp.SendLn('QUIT');
  ret := tcp.RecvLn;
  if not CheckRetCode(ret) then
  begin
    RaiseError(0, '���[���폜�ł��܂���ł����B'); Exit;
  end;
  Result := True;
end;

function TKPop3Thread.DeleteOne(no: Integer): Boolean;
var ret: string;
begin
  Result := False;
  if no <= 0 then Exit;
  if not Progress(0, IntToStr(no) + '�Ԗڂ̃��[�����폜���܂��B') then Exit;

  // DELE
  tcp.SendLn('DELE ' + IntToStr(no));
  ret := tcp.RecvLn;
  if not CheckRetCode(ret) then
  begin
    RaiseError(0, IntToStr(no) + '�Ԗڂ̃��[���폜�Ɏ��s�B'); Exit;
  end;
  // QUIT �Ŕ��f
  tcp.SendLn('QUIT');
  ret := tcp.RecvLn;
  if not CheckRetCode(ret) then
  begin
    RaiseError(0, '���[���폜�ł��܂���ł����B'); Exit;
  end;
  Result := True;
end;

destructor TKPop3Thread.Destroy;
begin
  FreeAndNil(tcp);
  inherited;
end;

procedure TKPop3Thread.Execute;
var
  s, cmd, arg: string;
begin
  // �X���b�h�J�n
  try
    if not Progress(0, tcp.Host + '�ɐڑ����܂��B') then Exit;
    tcp.Open; // �\�P�b�g���J��
  except
    on e: Exception do
    begin
      RaiseError(tcp.ErrorCode, e.Message);
      Exit;
    end;
  end;
  try
    try
      // �R�}���h���s�O�Ƀ��O�C������
      if LoginProc = False then Exit;

      // �ڑ����ĉ������s����̂��R�}���h�����
      s := FPop3Info.command;
      cmd := LowerCase(getToken_s(s, ' '));
      arg := s;

      if cmd = 'list' then // ���[���ꗗ�𓾂�
      begin
        FResult := ListProc;
      end else
      if cmd = 'recvall' then // �S�Ď�M����
      begin
        FResult := RecvAllProc(arg);
      end else
      if cmd = 'dele' then // �S�Ẵ��[�����폜����
      begin
        FResult := DeleteOne(StrToIntDef(arg,-1));
      end else
      if cmd = 'deleteall' then // �S�Ẵ��[�����폜����
      begin
        FResult := DeleteAll;
      end;
    except
      on e:Exception do
      begin
        RaiseError(tcp.ErrorCode, e.Message);
        Exit;
      end;
    end;
  finally
    tcp.Close; // ���ďI��
  end;

  // �Ō�̃C�x���g
  if Assigned(self.FPop3Info.OnComplete) then
  begin
    self.FPop3Info.OnComplete(Self);
  end;
end;

function TKPop3Thread.ListProc: Boolean;
var
  ret: string;
begin
  Result := False;

  // ���f�H
  if Terminated then Exit;

  // LIST
  if not Progress(0, '���[���̈ꗗ���擾���܂��B') then Exit;
  tcp.SendLn('LIST');
  ret := tcp.RecvLn;
  if CheckRetCode(ret) = False then
  begin
    RaiseError(0, '���b�Z�[�W�ꗗ�������܂���B'); Exit;
  end;
  // �S�Ẵ��X�g����M
  ret := ret + #13#10 + tcp.RecvLnToDot;
  // ���ʂ���
  FResultStr := ret;

  Result := True;
end;

function TKPop3Thread.LoginAPopProc(LoginCode: string): Boolean;
var
  key, ret, pass: string;
begin
  Result := False;

  ret := LoginCode;
  getToken_s(ret, '<');
  key := getToken_s(ret, '>');
  if key = '' then // APOP ���Ή��̂Ƃ�
  begin
    Result := LoginNormalProc(LoginCode); Exit;
  end;

  // MD5 ����
  key  := Trim('<' + key + '>' + FPop3Info.Pass);
  pass := MD5Print(md5.MD5String(key));

  // APOP
  if not Progress(0, FPop3Info.User + '�Ń��O�C�����܂��B') then Exit;
  tcp.SendLn('APOP ' + FPop3Info.User + ' ' + pass);
  ret := tcp.RecvLn;
  if CheckRetCode(ret) = False then
  begin
    RaiseError(0, FPop3Info.User + '�͋��ۂ���܂����B'); Exit;
  end;

  Result := True;
end;

function TKPop3Thread.LoginNormalProc(LoginCode: string): Boolean;
var
  ret: string;
begin
  Result := False;

  // USER
  if not Progress(0, FPop3Info.User + '�Ń��O�C�����܂��B') then Exit;
  tcp.SendLn('USER ' + FPop3Info.User);
  ret := tcp.RecvLn;
  if CheckRetCode(ret) = False then
  begin
    RaiseError(0, FPop3Info.User + '�͋��ۂ���܂����B'); Exit;
  end;

  // PASS
  if not Progress(0, '�p�X���[�h���ƍ����܂��B') then Exit;
  tcp.SendLn('PASS ' + FPop3Info.Pass);
  ret := tcp.RecvLn;
  if CheckRetCode(ret) = False then
  begin
    RaiseError(0, '�p�X���[�h���Ⴂ�܂��B'); Exit;
  end;

  Result := True;
end;

function TKPop3Thread.LoginProc: Boolean;
var
  ret: string;
begin
  Result := False;

  // ���f�H
  if Terminated then Exit;

  // �������b�Z�[�W����M
  ret := tcp.RecvLn;
  if CheckRetCode(ret) = False then
  begin
    RaiseError(0, '�T�[�o�[����ڑ������ۂ���܂����B'); Exit;
  end;

  if FPop3Info.APop then
  begin
    Result := LoginApopProc(ret);
  end else
  begin
    Result := LoginNormalProc(ret);
  end;
  
end;

function TKPop3Thread.Progress(PerDone: Integer; Msg: string): Boolean;
var
  Cancel: Boolean;
begin
  Result := True;
  if Assigned(FPop3Info.OnProgress) then
  begin
    Cancel := False;
    FPop3Info.OnProgress(PerDone, Msg, Cancel);
    if Cancel = True then
    begin
      Result := False;
      RaiseError(0, '���[�U�[�̑����钆�f�ł��B');
    end;
  end;
end;

procedure TKPop3Thread.RaiseError(Code: Integer; Msg: string);
begin
  FErrorCode := Code;
  FErrorMsg  := Msg;

  if Assigned(FPop3Info.OnError) then
  begin
    FPop3Info.OnError(Self);
  end;

  if Assigned(self.FPop3Info.OnComplete) then
  begin
    self.FPop3Info.OnComplete(Self);
  end;

  Self.Terminate;
end;

function TKPop3Thread.RecvAllProc(SaveDir: string): Boolean;
var
  ret, s: string;
  MailCount, bytes: Integer;
  i, j: Integer;
  f: TFileStream;
begin
  Result := False;

  // ���f�H
  if Terminated then Exit;

  // LIST
  if not Progress(0, '���[���̈ꗗ���擾���܂��B') then Exit;
  tcp.SendLn('STAT');
  ret := tcp.RecvLn;
  if CheckRetCode(ret) = False then
  begin
    RaiseError(0, '���b�Z�[�W�ꗗ�������܂���B'); Exit;
  end;

  // STAT �̉�� // (COUNT) (TOTAL)
  s := getToken_s(ret, ' ');
  MailCount  := StrToIntDef(s, 0);
  s := getChars_s(ret, ['0'..'9']);

  // ��M
  ForceDirectories(SaveDir);
  if Copy(SaveDir, Length(SaveDir), 1) <> '\' then SaveDir := SaveDir + '\';
  for i := 1 to MailCount do
  begin
    if not Progress(0, Format('%d/%d����M���܂��B',[i, MailCount])) then Exit;
    // �o�C�g���𓾂�
    tcp.SendLn('LIST ' + IntToStr(i));
    ret := tcp.RecvLn;
    //LIST 1 ->+OK 1 305
    if CheckRetCode(ret) = False then
    begin
      RaiseError(0, IntToStr(i) + '�Ԗڂ̎�M���ł��܂���B'); Exit;
    end;
    getToken_s(ret, ' '); // msg �ԍ���؂���
    s := getChars_s(ret, ['0'..'9']); // �o�C�g���𓾂�
    bytes := StrToIntDef(s, 1);
    if not Progress(0, Format('%d/%d(%dB)����M���ł��B',[i, MailCount,bytes])) then Exit;
    // �w�b�_�{�{���̎�M
    tcp.SendLn('RETR ' + IntToStr(i));
    ret := tcp.RecvLn;
    if CheckRetCode(ret) = False then
    begin
      RaiseError(0, IntToStr(i) + '�Ԗڂ̎�M���ł��܂���B'); Exit;
    end;
    // �ۑ�
    f := TFileStream.Create(SaveDir + IntToStr(i) + '.eml', fmCreate);
    try
      j := 0;
      while not Self.Terminated do
      begin
        // �o�ߕ\��
        if (j mod 128) = 0 then
        begin
          if not Progress(Trunc(f.Size / bytes * 100),
            Format('%d/%d����M���B',[i, MailCount])) then
          begin
            RaiseError(tcp.ErrorCode, IntToStr(i)+'�Ԃ̎�M�Ɏ��s�B');
          end;
        end;
        // ��M
        ret := tcp.RecvLn;
        // �I������
        if ret = '.' then Break;
        ret := ret + #13#10;
        f.Write(ret[1], Length(ret));
        Inc(j);
      end;
    finally
      f.Free;
    end;
  end;
  Result := True;
  FResultStr := IntToStr(MailCount);
  if not Progress(0, Format('%d�ʎ�M�����ł��B',[MailCount])) then Exit;
end;

{ TKPop3Dialog }

constructor TKPop3Dialog.Create(AOwner: TComponent);
begin
  inherited;
  FOnComplete := pop3OnComplete;
  FOnError    := pop3OnError;
  FOnProgress := pop3OnProgress;
  ShowDialog := True;
end;

destructor TKPop3Dialog.Destroy;
begin
  inherited;
end;

procedure TKPop3Dialog.Pop3Dele(no: Integer);
begin
  try
    Self.DeleteMail(no);
  except
    raise;
  end;
  ShowProgressDialog('���[���폜','���[���T�[�o�[�ɐڑ����܂����B','',ShowDialog);

  if not Self.Result then
  begin
    raise Exception.Create(Self.ErrorMsg);
  end;
end;

function TKPop3Dialog.Pop3List: string;
begin
  try
    Self.GetList;
  except
    raise;
  end;
  ShowProgressDialog('���[�����X�g�擾','���[���T�[�o�[�ɐڑ����܂����B','',ShowDialog);

  if not Self.Result then
  begin
    raise Exception.Create(Self.ErrorMsg);
  end;

  Result := Self.ErrorMsg;
end;

procedure TKPop3Dialog.pop3OnComplete(Sender: TObject);
begin
  DialogFlagComplete := True;
end;

procedure TKPop3Dialog.pop3OnError(Sender: TObject);
begin
  DialogFlagComplete := True;
  FResult := False;
  //raise Exception.Create(Self.ErrorMsg);
end;

procedure TKPop3Dialog.pop3OnProgress(PerDone: Integer; msg: string;
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

function TKPop3Dialog.Pop3RecvAll(SaveDir: string; FlagDelete: Boolean): Integer;
begin
  try
    Self.RecvAll(SaveDir);
  except
    raise;
  end;
  ShowProgressDialog('���[����M','���[���T�[�o�[�ɐڑ����Ă��܂��B','',ShowDialog);

  if not Self.Result then
  begin
    //todo: �����Ńn���O����
    raise Exception.Create(Self.ErrorMsg);
  end;

  Result := StrToIntDef(Self.ErrorMsg, 0);

  if FlagDelete and (Result > 0) then
  begin
    Self.DeleteMailAll;
    ShowProgressDialog('���[���폜','���[���T�[�o�[�ɐڑ����Ă��܂��B','', ShowDialog);
  end;

  if not Self.Result then
  begin
    raise Exception.Create(Self.ErrorMsg);
  end;

end;

{ TThreadDummy }

constructor TThreadDummy.Create(Suspend:Boolean);
begin
  Terminated := False;
  FFreeOnTerminate := Suspend;
  Execute;
end;

destructor TThreadDummy.Destroy;
begin

  inherited;
end;

procedure TThreadDummy.Execute;
begin
  inherited;
  if FFreeOnTerminate then
  begin
    FreeAndNil(Self);
  end;
end;

procedure TThreadDummy.Terminate;
begin
  Terminated := True;
end;

end.
