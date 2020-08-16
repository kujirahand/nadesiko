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
  s := g.instanceName + '→' + prop;
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

  // 引数の取得
  oid := getArgInt(arg, 0, True);
  cmd := getArgStr(arg, 1);
  v   := getArgStr(arg, 2);

  // コマンドの解析
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
  if g = nil then raise Exception.Create('オブジェクトが特定できません。');
  Frs232c := Trs232cN(g);

  if cmd = 'open' then
  begin
    // 設定
    Frs232c.bps         := getPropInt(g, 'BPS', 9600);
    Frs232c.charbit     := getPropInt(g, 'CHARBIT', 8);
    Frs232c.stopbit     := getPropStr(g, 'STOPBIT');
    Frs232c.paritymode  := getPropStr(g, 'PARITYMODE');
    Frs232c.rxtimeout   := getPropInt(g, 'タイムアウト', 3000);
    Frs232c.txtimeout   := getPropInt(g, 'タイムアウト', 3000);
    Frs232c.portname    := getPropStr(g, 'ポート');
    Frs232c.packetsize  := getPropInt(g, 'パケットサイズ', 0);
    Frs232c.XonLim      := getPropInt(g, 'XonLim', 17);
    Frs232c.XoffLim     := getPropInt(g, 'XoffLim', 19);
    Frs232c.XonChar     := Char((getPropInt(g,'XonChar')));
    Frs232c.XoffChar    := Char((getPropInt(g,'XoffChar')));
    Frs232c.ErrorChar   := Char((getPropInt(g,'ErrorChar')));
    Frs232c.EvtChar     := Char((getPropInt(g,'EvtChar')));
    Frs232c.EofChar     := Char((getPropInt(g,'EofChar')));

    // Frs232c.flowflag    := getPropInt(g,'フロー制御フラグ',$1);
    flowflag := 0;
    flowflag := flowflag + $1; // fBinary($1)はWindowsでは必須のため固定で設定。
    if getPropStr(g, 'パリティチェック') = '有効' then flowflag := flowflag + $02;
    if getPropStr(g, 'CTSフロー制御') = '有効' then flowflag := flowflag + $04;
    if getPropStr(g, 'DSRフロー制御') = '有効' then flowflag := flowflag + $08;
    s := getPropStr(g, 'DTRフロー制御');
    if s = '有効' then flowflag := flowflag + $20
    else if s = '常時オン' then flowflag := flowflag + $10
    else if s = 'トグル' then flowflag := flowflag + $30;
    if getPropStr(g, 'DSRオフ時受信破棄') = '有効' then flowflag := flowflag + $40;
    s := getPropStr(g, 'XONXOFFフロー制御');
    if (s = '有効') or (s = '送受信') or (s = '送信受信') then flowflag := flowflag + $300
    else if s = '送信' then flowflag := flowflag + $100
    else if s = '受信' then flowflag := flowflag + $200;
    if getPropStr(g, 'XOFF送信後データ送信') = '有効' then flowflag := flowflag + $80;
    if getPropStr(g, 'パリティエラー文字置換') = '有効' then flowflag := flowflag + $400;
    if getPropStr(g, 'NULL除去') = '有効' then flowflag := flowflag + $800;
    s := getPropStr(g, 'RTSフロー制御');
    if s = '有効' then flowflag := flowflag + $2000
    else if s = '常時オン' then flowflag := flowflag + $1000
    else if s = 'トグル' then flowflag := flowflag + $3000;
    // ライブラリ部分の対応可否が不明のためfAborrtOnError($40000)は常にオフとする。
    Frs232c.flowflag := flowflag;

    if not Frs232c.rsopen then raise Exception.Create('RS232Cのポート『'+Frs232c.portname+'』が開けません。');
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
  if cmd = 'handle取得' then
  begin
    Result := hi_var_new;
    hi_setInt(Result, Frs232c.getcommhandle());
  end else
  if cmd = 'cts取得' then
  begin
    Result := hi_var_new;
    hi_setBool(Result, Frs232c.getcts());
  end else
  if cmd = 'dsr取得' then
  begin
    Result := hi_var_new;
    hi_setBool(Result, Frs232c.getdsr());
  end else
  if cmd = 'ring取得' then
  begin
    Result := hi_var_new;
    hi_setBool(Result, Frs232c.getring());
  end else
  if cmd = 'rlsd取得' then
  begin
    Result := hi_var_new;
    hi_setBool(Result, Frs232c.getrlsd());
  end else
  if cmd = 'rts設定' then
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
  if cmd = 'dtr設定' then
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
  AddFunc('RS232C_COMMAND', 'OID,CMD,V',  4400, rs232c_cmd, 'RS232Cの設定を行う', 'RS232C_COMMAND');
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

      // 受信データをセット
      p := nako_getGroupMember(PAnsiChar(self.instanceName),PAnsiChar('受信データ'));
      if p <> nil then nako_bin2var(PAnsiChar(s),Length(s),p);

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

  // 受信データをセット
  p := nako_getGroupMember(PAnsiChar(InstanceName),PAnsiChar('受信データ'));
  if p <> nil then nako_bin2var(PAnsiChar(s),Length(s),p);

  OnEvent('受信した時');
end;

procedure Trs232cN.FFOnTXEMPTY(Sender: TObject);
begin
  OnEvent('送信完了した時');
end;

procedure Trs232cN.OnEvent(ename: string);
var
  e: string;
  p: PHiValue;
begin
  e := Self.instanceName + 'の' + ename + ';';
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

    // 受信データをセット
    p := nako_getGroupMember(PAnsiChar(InstanceName),PAnsiChar('受信データ'));
    if p <> nil then nako_bin2var(PAnsiChar(s),Length(s),p);

    OnEvent('イベント文字受信した時');
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
