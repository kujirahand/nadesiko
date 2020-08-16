unit dll_rs232c_function;

interface
uses
  classes, windows, rs232c, comthd,
  dll_plugin_helper, dnako_import, dnako_import_types, SysUtils;

type
  Trs232cN = class(Trs232c)
  public
    rxdata_cnt: Integer;       // �ǉ�
    rxdata_packet: String;     // �ǉ�
  public
    instanceName: string;
    oid: Integer;
    procedure FFOnBREAK(Sender: TObject);
    procedure FFOnCTS(Sender: TObject);
    procedure FFOnDSR(Sender: TObject);
    procedure FFOnERR(Sender: TObject);
    procedure FFOnRING(Sender: TObject);
    procedure FFOnRLSD(Sender: TObject);
    procedure FFOnRXCHAR(Sender: TObject);
    procedure FFOnRXFLAG(Sender: TObject);
    procedure FFOnTXEMPTY(Sender: TObject);
    procedure FFOnCreate(Sender: TObject);
    procedure FFOnOpen(Sender: TObject);
    procedure FFOnClose(Sender: TObject);
    procedure FFOnPACKET(Sender: TObject);
    procedure FFOnError(Sender: TObject);
    procedure OnEvent(ename: string);
    constructor Create(AOwner: TComponent); override;
  end;

procedure RegistFunction;

implementation

var rs232c_list : array of Trs232cN;

function getPropStr(g:Trs232cN; prop: string): string;
var
  s: string;
  p: PHiValue;
begin
  Result := '';
  s := g.instanceName + '��' + prop;
  nako_evalEx(PChar(s), p);
  if p <> nil then
  begin
    Result := hi_str(p);
    nako_var_free(p);
  end;
end;

function getPropInt(g:Trs232cN; prop: string; def: Integer = 0): Integer;
var s: string;
begin
  s := getPropStr(g, prop);
  Result := StrToIntDef( s, def );
end;

function rs232c_cmd(arg: DWORD): PHiValue; stdcall;
var
  cmd, v, s: string;
  Frs232c, g: Trs232cN;
  oid, flowflag: Integer;
begin
  Result := nil;
  if rs232c_list = nil then SetLength(rs232c_list, 255);

  // �����̎擾
  oid := getArgInt(arg, 0, True);
  cmd := getArgStr(arg, 1);
  v   := getArgStr(arg, 2);

  // �R�}���h�̉��
  if cmd = 'create' then
  begin
    //
    Frs232c := Trs232cN.Create(nil);
    Frs232c.instanceName := v;
    rs232c_list[ oid ] := Frs232c;
    //
    Exit;
  end;

  g := rs232c_list[ oid ];
  if g = nil then raise Exception.Create('�I�u�W�F�N�g������ł��܂���B');
  Frs232c := Trs232cN(g);

  if cmd = 'open' then
  begin
    // �ݒ�
    Frs232c.bps         := getPropInt(g, 'BPS', 9600);
    Frs232c.charbit     := getPropInt(g, 'CHARBIT', 8);
    Frs232c.stopbit     := getPropStr(g, 'STOPBIT');
    Frs232c.paritymode  := getPropStr(g, 'PARITYMODE');
    Frs232c.rxtimeout   := getPropInt(g, '�^�C���A�E�g', 3000);
    Frs232c.txtimeout   := getPropInt(g, '�^�C���A�E�g', 3000);
    Frs232c.portname    := getPropStr(g, '�|�[�g');
    Frs232c.packetsize  := getPropInt(g, '�p�P�b�g�T�C�Y', 0);
    Frs232c.XonLim      := getPropInt(g, 'XonLim', 17);
    Frs232c.XoffLim     := getPropInt(g, 'XoffLim', 19);
    Frs232c.XonChar     := Char((getPropInt(g,'XonChar')));
    Frs232c.XoffChar    := Char((getPropInt(g,'XoffChar')));
    Frs232c.ErrorChar   := Char((getPropInt(g,'ErrorChar')));
    Frs232c.EvtChar     := Char((getPropInt(g,'EvtChar')));
    Frs232c.EofChar     := Char((getPropInt(g,'EofChar')));

    // Frs232c.flowflag    := getPropInt(g,'�t���[����t���O',$1);
    flowflag := 0;
    flowflag := flowflag + $1; // fBinary($1)��Windows�ł͕K�{�̂��ߌŒ�Őݒ�B
    if getPropStr(g, '�p���e�B�`�F�b�N') = '�L��' then flowflag := flowflag + $02;
    if getPropStr(g, 'CTS�t���[����') = '�L��' then flowflag := flowflag + $04;
    if getPropStr(g, 'DSR�t���[����') = '�L��' then flowflag := flowflag + $08;
    s := getPropStr(g, 'DTR�t���[����');
    if s = '�L��' then flowflag := flowflag + $20
    else if s = '�펞�I��' then flowflag := flowflag + $10
    else if s = '�g�O��' then flowflag := flowflag + $30;
    if getPropStr(g, 'DSR�I�t����M�j��') = '�L��' then flowflag := flowflag + $40;
    s := getPropStr(g, 'XONXOFF�t���[����');
    if (s = '�L��') or (s = '����M') or (s = '���M��M') then flowflag := flowflag + $300
    else if s = '���M' then flowflag := flowflag + $100
    else if s = '��M' then flowflag := flowflag + $200;
    if getPropStr(g, 'XOFF���M��f�[�^���M') = '�L��' then flowflag := flowflag + $80;
    if getPropStr(g, '�p���e�B�G���[�����u��') = '�L��' then flowflag := flowflag + $400;
    if getPropStr(g, 'NULL����') = '�L��' then flowflag := flowflag + $800;
    s := getPropStr(g, 'RTS�t���[����');
    if s = '�L��' then flowflag := flowflag + $2000
    else if s = '�펞�I��' then flowflag := flowflag + $1000
    else if s = '�g�O��' then flowflag := flowflag + $3000;
    // ���C�u���������̑Ή��ۂ��s���̂���fAborrtOnError($40000)�͏�ɃI�t�Ƃ���B
    Frs232c.flowflag := flowflag;

    if not Frs232c.rsopen then raise Exception.Create('RS232C�̃|�[�g�w'+Frs232c.portname+'�x���J���܂���B');
  end else
  if cmd = 'close' then
  begin
    Frs232c.rsclose;
  end else
  if cmd = 'send' then
  begin
    if v <> '' then
    begin
      Frs232c.rswrite(v[1], Length(v));
    end;
  end else
  if cmd = 'handle�擾' then
  begin
    Result := hi_var_new;
    hi_setInt(Result, Frs232c.getcommhandle());
  end else
  if cmd = 'cts�擾' then
  begin
    Result := hi_var_new;
    hi_setBool(Result, Frs232c.getcts());
  end else
  if cmd = 'dsr�擾' then
  begin
    Result := hi_var_new;
    hi_setBool(Result, Frs232c.getdsr());
  end else
  if cmd = 'ring�擾' then
  begin
    Result := hi_var_new;
    hi_setBool(Result, Frs232c.getring());
  end else
  if cmd = 'rlsd�擾' then
  begin
    Result := hi_var_new;
    hi_setBool(Result, Frs232c.getrlsd());
  end else
  if cmd = 'rts�ݒ�' then
  begin
    if v <> '' then
    begin
      if v = '0' then
      begin
        Frs232c.set_rts(false);
      end else begin
        Frs232c.set_rts(true);
      end;
    end;
  end else
  if cmd = 'dtr�ݒ�' then
  begin
    if v <> '' then
    begin
      if v = '0' then
      begin
        Frs232c.set_dtr(false);
      end else begin
        Frs232c.set_dtr(true);
      end;
    end;
  end else
  ;
end;

procedure RegistFunction;
begin
  //4400-4499
  AddFunc('RS232C_COMMAND', 'OID,CMD,V',  4400, rs232c_cmd, 'RS232C�̐ݒ���s��', 'RS232C_COMMAND');
end;


{ Trs232cN }

constructor Trs232cN.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  rxdata_cnt := 0;         // �ǉ�
  rxdata_packet := '';     // �ǉ�


  // ���ׂ�Ƃ��Ƃ����
  OnBREAK := FFOnBREAK;
  OnCTS := FFOnCTS;
  OnDSR := FFOnDSR;
  OnERR := FFOnERR;
  OnRING := FFOnRING;
  OnRLSD := FFOnRLSD;
  OnRXCHAR := FFOnRXCHAR;
  OnRXFLAG := FFOnRXFLAG;
  OnTXEMPTY := FFOnTXEMPTY;
  OnCreate := FFOnCreate;
  OnOpen := FFOnOpen;
  OnClose := FFOnClose;
  OnPACKET := FFOnPACKET;
  OnError := FFOnError;
end;

procedure Trs232cN.FFOnBREAK(Sender: TObject);
begin
  OnEvent('BREAK���o������');
end;

procedure Trs232cN.FFOnClose(Sender: TObject);
begin
  OnEvent('������');
end;

procedure Trs232cN.FFOnCreate(Sender: TObject);
begin
  OnEvent('����������');
end;

procedure Trs232cN.FFOnCTS(Sender: TObject);
begin
  OnEvent('CTS�ω�������');
end;

procedure Trs232cN.FFOnDSR(Sender: TObject);
begin
  OnEvent('DSR�ω�������');
end;

procedure Trs232cN.FFOnERR(Sender: TObject);
begin
  OnEvent('�G���[����������');
end;

procedure Trs232cN.FFOnError(Sender: TObject);
begin
  OnEvent('�G���[����������');
end;

procedure Trs232cN.FFOnOpen(Sender: TObject);
begin
  OnEvent('�J������');
end;

procedure Trs232cN.FFOnRING(Sender: TObject);
begin
  OnEvent('RING���o������');
end;

procedure Trs232cN.FFOnRLSD(Sender: TObject);
begin
  OnEvent('RLSD�ω�������');
end;

procedure Trs232cN.FFOnPACKET(Sender: TObject);
var
  s: string;
  p: PHiValue;
  c: Char;
  max_data_len: integer;
begin

  // ���L��while���̂ɏ��������Ȃ���
  // ��M�f�[�^����肱�ڂ����肵��
  while 0 < rxdatalen do
  begin
    self.rsread(c, 1);
    rxdata_packet := rxdata_packet + c;

    max_data_len := Length(rxdata_packet);

    // �w�肵���p�P�b�g�T�C�Y����M������A
    // �p�P�b�g�T�C�Y���؂����āA�C�x���g����������
    if (max_data_len >= packetsize) then begin
      s := Copy(rxdata_packet,1,packetsize);

      // ��M�f�[�^���Z�b�g
      p := nako_getGroupMember(PAnsiChar(self.instanceName),PAnsiChar('��M�f�[�^'));
      if p <> nil then nako_bin2var(PAnsiChar(s),Length(s),p);

      OnEvent('�p�P�b�g��M������');

      rxdata_packet := '';
      rxdata_packet := Copy(rxdata_packet,packetsize+1,max_data_len-packetsize);
    end;
  end;
end;


procedure Trs232cN.FFOnRXCHAR(Sender: TObject);
var
  s: string;
  p: PHiValue;
  c: Char;
begin

  s := '';
  while 0 < rxdatalen do
  begin
    self.rsread(c, 1);
    s := s + c;
  end;

  // ��M�f�[�^�������Ƃ��́A�C�x���g�𔭐������Ȃ�
  // ��M�f�[�^������ΌĂ΂��Ǝv���̂ł����E�E�E
  // ������A����Ă����Ȃ��ƃC�x���g�͔������邯��
  // ��M�f�[�^������ۂɂȂ�܂��B
  if s = '' then
    Exit;

  // ��M�f�[�^���Z�b�g
  p := nako_getGroupMember(PAnsiChar(InstanceName),PAnsiChar('��M�f�[�^'));
  if p <> nil then nako_bin2var(PAnsiChar(s),Length(s),p);

  OnEvent('��M������');
end;

procedure Trs232cN.FFOnTXEMPTY(Sender: TObject);
begin
  OnEvent('���M����������');
end;

procedure Trs232cN.OnEvent(ename: string);
var
  e: string;
  p: PHiValue;
begin
  e := Self.instanceName + '��' + ename + ';';
  nako_evalEx(PChar(e), p);
  if p <> nil then nako_var_free(p);
end;

procedure Trs232cN.FFOnRXFLAG(Sender: TObject);
var
  s: string;
  p: PHiValue;
begin
  if rxdatalen > 0 then
  begin
    SetLength(s, rxdatalen);
    self.rsread(s[1], Length(s));

    // ��M�f�[�^���Z�b�g
    p := nako_getGroupMember(PAnsiChar(InstanceName),PAnsiChar('��M�f�[�^'));
    if p <> nil then nako_bin2var(PAnsiChar(s),Length(s),p);

    OnEvent('�C�x���g������M������');
  end;
end;

procedure free_rs232c_list;
var
  i: Integer;
begin
  if rs232c_list = nil then Exit;
  for i := 0 to High(rs232c_list) do
  begin
    FreeAndNil(rs232c_list[i]);
  end;
end;

initialization

finalization
  free_rs232c_list;

end.
