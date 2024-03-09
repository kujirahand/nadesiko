unit ms_agent;
//Microsoft Agent ���ȒP�Ɏg�����߂̃��b�p�[���j�b�g
// MS-Agent URL -> http://www.microsoft.com/msagent/downloads/user.asp
{
�y��{���z
 ��ҁF�N�W����s�� (http://hima.chu.jp/)
 �쐬���̂Ђ܂��̃o�[�W���� 1.84j
 �����F2004/01/23
}
{
�y�g�����z
AgentInit;
AgentLoad('Merlin','Merlin.acs'
AgentShow;
AgentPlay('Greet');
AgentSpeak('Hello!');
}


interface

uses
  Windows,
  ActiveX,
  ComObj,
  shellapi,
  Variants,
  mmsystem;

function AgentCheckInstall: Boolean;
function AgentCheckInstallLanguage(lang: string): Boolean;
function AgentCheckSAPI: Boolean; // SAPI.DLL
function AgentInit: Boolean;
procedure AgentFin;
function AgentLoad(CharID, CharACS: string): Boolean;
procedure AgentShow;
procedure AgentHide;
procedure AgentPlay(command: string);
procedure AgentSpeak(text: string);
procedure AgentMoveTo(x, y: Integer);
procedure AgentUnload;
procedure AgentChangeLanguage(ID: Integer);
procedure AgentStopAll;
procedure AgentWaitFor;
procedure AgentSpeakSpeed(v: integer);
procedure AgentSpeakPitch(v: integer);
procedure AgentSize(width, height: Integer);
function AgentGetInfo: string;
function CheckCLSID(id: string): Boolean;

implementation

uses
  Forms, SysUtils, VarCmplx;

var
  objAgent: Variant;
  objChar, objReq : Variant;
  FCharID: string;
  FPitch, FSpeed: Integer;

function CheckCLSID(id: string): Boolean;
var
  s: string;
begin
  if Copy(id, 1,1) <> '{' then id := '{' + id + '}';
  s := GetRegStringValue('CLSID\'+id, '');
  if s <> '' then Result := True else Result := False;
end;


function AgentCheckSAPI: Boolean; //0C7F3F20-8BAB-11d2-9432-00C04F8EF48F
begin
  Result := CheckCLSID('0C7F3F20-8BAB-11d2-9432-00C04F8EF48F');
end;


{ActiveX�T�[�o�[�������オ���Ă���΁A�����̃T�[�o�[�𓾂�}
function GetOrCreateObject (const ClassName: string): IDispatch;
var
  ClassID: TGUID;
  Unknown: IUnknown;
begin
  ClassID := ProgIDToClassID (ClassName);
  if Succeeded (GetActiveObject (ClassID, nil, Unknown)) then
    OleCheck (Unknown.QueryInterface (IDispatch, Result))
  else
    Result := CreateOleObject (ClassName);
end;


function AgentInit: Boolean;
var
  i: Integer;
begin
  //-------------------------------
  // �擾 or ����
  objAgent := GetOrCreateObject('Agent.Control.2');

  //-------------------------------
  // �����ł��Ȃ���΃w���v��\��
  if IDispatch(objAgent) = nil then
  begin
    i := MessageBox(0, 'MS Agent ���������G���W�����C���X�g�[������Ă��܂���B'#13#10+
                  'MS Agent�̃_�E�����[�h�y�[�W��\�����܂��B', '�m�F', MB_YESNO or MB_ICONQUESTION);
    if i = IDYES then ShellExecute(0, 'open', 'http://www.microsoft.com/msagent/downloads/user.asp', '', '', SW_SHOW);
    Result := False;
    Exit;
  end;

  objAgent.connected := True;

  Result := True;
end;

function AgentCheckInstall: Boolean;
begin
  //-------------------------------
  // �擾 or ����
  objAgent := GetOrCreateObject('Agent.Control.2');
  Result := (IDispatch(objAgent) <> nil);
  if Result then
  begin
    IDispatch(objAgent)._Release ;
    objAgent := Unassigned;
  end;
end;


function AgentCheckInstallLanguage(lang: string): Boolean;
var
  cid: string;
begin
  Result := True;

  // ����̃C���X�g�[���`�F�b�N
  if lang = '���{��'  then lang := '0411' else
  if lang = '�p��'    then lang := '0409' else
  if lang = '������'  then lang := '0804' else
  if lang = '�؍���'  then lang := '0412' else
  ;

  cid := '{C348'+lang+'-A7F8-11D1-AA75-00C04FA34D72}';

  if GetRegStringValue('CLSID\'+cid,'') = '' then
  begin
    Result := False;
  end;
end;

procedure AgentFin;
begin
  if VarIsEmpty(objChar) then Exit;
  IDispatch(objAgent)._Release ;
end;

function AgentLoad(CharID, CharACS: string): Boolean;
begin
  Result := False;
  if VarIsEmpty(objAgent) then if not AgentInit then Exit;
  try
    // ���ɃL�����N�^�[���Ă΂�Ă��邩�H --- �Ȃ�Έ�C�����܂�
    if not VarIsEmpty(objChar) then
    begin
      objAgent.Characters.Unload(FCharID);
      {$IF RTLVersion>=15}
        FindVarData(objReq)^.VType := varEmpty;
      {$ELSE}
        objReq := Unassigned ;//���
      {$IFEND}
    end;
    // LOAD
    objAgent.Characters.Load(string(CharID), string(CharACS));
    // �L�����N�^�[�̃Z�b�g
    objChar := objAgent.Characters[string(CharID)];
    FCharID := CharID;
  except
    raise;
    Exit;
  end;
  FPitch := -1; FSpeed := -1;
  Result := True;
end;

procedure AgentShow;
begin
  if VarIsEmpty(objChar) then
  begin
    AgentLoad('Merlin','Merlin.acs');
  end;
  objChar.Show;
end;

procedure AgentHide;
begin
  if VarIsEmpty(objChar) then
  begin
    AgentLoad('Merlin','Merlin.acs');
  end;
  objChar.Hide;
end;

procedure AgentPlay(command: string);
begin
  if VarIsEmpty(objChar) then
  begin
    AgentLoad('Merlin','Merlin.acs');
  end;
  objChar.Play(Trim(string(command)));
end;

procedure AgentStopAll;
begin
  if VarIsEmpty(objChar) then
  begin
    AgentLoad('Merlin','Merlin.acs');
  end;
  objChar.StopAll('Speak');
end;

procedure AgentWaitFor;
var
  t: DWORD;
begin
  t := timeGetTime ;
  if not VarIsEmpty(objReq) then
  begin
    try
      while (objReq.Status <> 0) do
      begin
        sleep(100);
        Application.ProcessMessages ;
        if (timeGetTime - t) > 8 * 1000 then Break; // �w��b�ȏ�Ȃ甲����
      end;
    except
    end;
  end;
end;

procedure AgentSpeak(text: string);
begin
  if VarIsEmpty(objChar) then
  begin
    AgentLoad('Merlin','Merlin.acs');
  end;
  if FPitch >= 0 then text := '\Pit='+IntToStr(FPitch)+'\'+text;
  if FSpeed >= 0 then text := '\Spd='+IntToStr(FSPeed)+'\'+text;
  objReq := objChar.Speak(string(text));
end;

procedure AgentMoveTo(x, y: Integer);
begin
  if VarIsEmpty(objChar) then
  begin
    AgentLoad('Merlin','Merlin.acs');
  end;
  objChar.MoveTo(x, y);
end;

procedure AgentUnload;
begin
  if VarIsEmpty(objChar) then Exit;
  objAgent.Characters.Unload(FCharID);
end;

procedure AgentChangeLanguage(ID: Integer);
var
  s, cid: string;
begin
  // ����̃C���X�g�[���`�F�b�N
  cid := '{C348'+IntToHex(ID,4)+'-A7F8-11D1-AA75-00C04FA34D72}';

  if GetRegStringValue('CLSID\'+cid,'') = '' then
  begin
    s := IntToHex(ID,4);
    if s = '0411' then s := '���{��' else
    if s = '0409' then s := '�p��' else
    if s = '0804' then s := '������' else
    if s = '0412' then s := '�؍���' else s := '����ID:'+s;
    raise Exception.Create('MS Agent�̌���('+s+')���C���X�g�[������Ă��܂���B');
  end;

  if VarIsEmpty(objChar) then
  begin
    AgentLoad('Merlin','Merlin.acs');
  end;
  AgentWaitFor; // �������Ă���Ԃ͑҂��Ă�ׂ�
  objChar.LanguageID := ID;
end;

procedure AgentSpeakSpeed(v: integer);
begin
  FSpeed := v;
end;
procedure AgentSpeakPitch(v: integer);
begin
  FPitch := v;
end;
procedure AgentSize(width, height: Integer);
begin
  objChar.Width := width;
  objChar.Height := height;
end;

// Agent ���𓾂�
function AgentGetInfo: string;
var
  pit, spd: Integer;
begin
  if VarIsEmpty(objChar) then
  begin
    Result := ''; Exit;
  end;
  pit := FPitch; if pit < 0 then pit := objChar.Pitch;
  spd := FSpeed; if spd < 0 then spd := objChar.Speed;

  Result := '��='+IntToStr(objChar.Width)+#13#10+
            '����='+IntToStr(objChar.Height)+#13#10+
            '�s�b�`='+IntToStr(pit)+#13#10+
            '���x='+IntToStr(spd)+#13#10+
            '�����s�b�`='+IntToStr(objChar.Pitch)+#13#10+
            '�������x='+IntToStr(objChar.Speed)+#13#10+
            '�L�����N�^ID='+FCharID+#13#10+
            '����ID='+IntToStr(objChar.LanguageID)+#13#10;
end;

end.
