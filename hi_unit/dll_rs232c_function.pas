unit dll_rs232c_function;

interface
uses
  classes, windows, rs232c, comthd,
  dll_plugin_helper, dnako_import, dnako_import_types, SysUtils;

type
  Trs232cN = class(Trs232c)
  public
    rxdata_cnt: Integer;       // 追加
    rxdata_packet: String;     // 追加
  public
    group: PHiValue;
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


function rs232c_cmd(arg: DWORD): PHiValue; stdcall;
var
  g, p: PHiValue;
  cmd, v: string;
  Frs232c: Trs232cN;
begin
  Result := nil;
  // 引数の取得
  g   := nako_getFuncArg(arg, 0);
  cmd := hi_str( nako_getFuncArg(arg, 1) );
  v   := hi_str( nako_getFuncArg(arg, 2) );

  // コマンドの解析
  if cmd = 'create' then
  begin
    p := nako_group_findMember(g, 'オブジェクト');
    if p = nil then raise Exception.Create('オブジェクトが特定できません。');
    //
    Frs232c := Trs232cN.Create(nil);
    Frs232c.group := g;
    hi_setInt(p, Integer(Frs232c));
    //
    Exit;
  end;

  p := nako_group_findMember(g, 'オブジェクト');
  if p = nil then raise Exception.Create('オブジェクトが特定できません。');
  Frs232c := Trs232cN(hi_int(p));

  if cmd = 'open' then
  begin
    // 設定
    Frs232c.bps         := hi_int(nako_group_findMember(g, 'BPS'));
    Frs232c.charbit     := hi_int(nako_group_findMember(g, 'CHARBIT'));
    Frs232c.stopbit     := hi_str(nako_group_findMember(g, 'STOPBIT'));
    Frs232c.paritymode  := hi_str(nako_group_findMember(g, 'PARITYMODE'));
    Frs232c.rxtimeout   := hi_int(nako_group_findMember(g, 'タイムアウト'));
    Frs232c.txtimeout   := hi_int(nako_group_findMember(g, 'タイムアウト'));
    Frs232c.portname    := hi_str(nako_group_findMember(g, 'ポート'));
    Frs232c.packetsize  := hi_int(nako_group_findMember(g, 'パケットサイズ'));
    Frs232c.XonLim      := hi_int(nako_group_findMember(g, 'XonLim'));
    Frs232c.XoffLim     := hi_int(nako_group_findMember(g, 'Xoff'));
    Frs232c.XonChar     := Char(hi_int(nako_group_findMember(g,'XonChar')));
    Frs232c.XoffChar    := Char(hi_int(nako_group_findMember(g,'XoffChar')));
    Frs232c.ErrorChar   := Char(hi_int(nako_group_findMember(g,'ErrorChar')));
    Frs232c.EvtChar     := Char(hi_int(nako_group_findMember(g,'EvtChar')));
    Frs232c.EofChar     := Char(hi_int(nako_group_findMember(g,'EofChar')));

    if not Frs232c.rsopen then raise Exception.Create('RS232Cのポートが開けません。');
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
  ;
end;

procedure RegistFunction;
begin
  //4400-4499
  AddFunc('RS232C_COMMAND','{グループ}G,CMD,V',  4400, rs232c_cmd, 'RS232Cの設定を行う', 'RS232C_COMMAND');
end;


{ Trs232cN }

constructor Trs232cN.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  rxdata_cnt := 0;         // 追加
  rxdata_packet := '';     // 追加


  // いべんとをとらっぷ
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
  OnEvent('BREAK検出した時');
end;

procedure Trs232cN.FFOnClose(Sender: TObject);
begin
  OnEvent('閉じた時');
end;

procedure Trs232cN.FFOnCreate(Sender: TObject);
begin
  OnEvent('生成した時');
end;

procedure Trs232cN.FFOnCTS(Sender: TObject);
begin
  OnEvent('CTS変化した時');
end;

procedure Trs232cN.FFOnDSR(Sender: TObject);
begin
  OnEvent('DSR変化した時');
end;

procedure Trs232cN.FFOnERR(Sender: TObject);
begin
  OnEvent('エラー発生した時');
end;

procedure Trs232cN.FFOnError(Sender: TObject);
begin
  OnEvent('エラー発生した時');
end;

procedure Trs232cN.FFOnOpen(Sender: TObject);
begin
  OnEvent('開いた時');
end;

procedure Trs232cN.FFOnRING(Sender: TObject);
begin
  OnEvent('RING検出した時');
end;

procedure Trs232cN.FFOnRLSD(Sender: TObject);
begin
  OnEvent('RLSD変化した時');
end;

procedure Trs232cN.FFOnPACKET(Sender: TObject);
var
  s: string;
  p: PHiValue;
  c: Char;
  max_data_len: integer;
begin

  // 下記のwhile文のに処理を入れないと
  // 受信データを取りこぼしたりした
  while 0 < rxdatalen do
  begin
    self.rsread(c, 1);
    rxdata_packet := rxdata_packet + c;

    max_data_len := Length(rxdata_packet);

    // 指定したパケットサイズ分受信したら、
    // パケットサイズ分切り取って、イベント発生させる
    if (max_data_len >= packetsize) then begin
      s := Copy(rxdata_packet,1,packetsize);

      p := nako_group_findMember(group, '受信データ');
      if p = nil then Exit;

      hi_setStr(p, s);

      OnEvent('パケット受信した時');

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

  // 受信データが無いときは、イベントを発生させない
  // 受信データがあれば呼ばれると思うのですが・・・
  // これを、入れておかないとイベントは発生するけど
  // 受信データが空っぽになります。
  if s = '' then
    Exit;

  p := nako_group_findMember(group, '受信データ');
  if p = nil then Exit;

  hi_setStr(p, s);

  OnEvent('受信した時');
end;

procedure Trs232cN.FFOnTXEMPTY(Sender: TObject);
begin
  OnEvent('送信完了した時');
end;

procedure Trs232cN.OnEvent(ename: string);
var
  p: PHiValue;
begin
  p := nako_group_findMember(group, PChar(ename));
  if p = nil then Exit;
  //if p^.VType = varFunc then
  if (p<>nil)and(p.ptr <> nil) then
  begin
    nako_continue;
    nako_group_exec(group, PChar(ename));
  end;
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

    p := nako_group_findMember(group, '受信データ');
    if p = nil then Exit;
    hi_setStr(p, s);
    OnEvent('イベント文字受信した時');
  end;
end;

end.
