{ RS-232C通信コンポーネント Ver2.3

	(C)Copyright 1998-2003 千々岩幸治

  改変: ナデシコ用に改変 by クジラ飛行机(2005/01/24)
}
unit rs232c;

interface

{
	以下のコンパイラのみプロパティエディタを有効にする
	
	Delphi2.0
	C++Builder1.0
	Delphi3.X
	C++Builder3.0
	Delphi4.0
	C++Builder4.0
}

uses
	Windows, Messages, SysUtils, Classes, comthd

{$IFDEF VER90}
	,rs232ced;
{$ELSE}
	{$IFDEF VER93}
		,rs232ced;
	{$ELSE}
		{$IFDEF VER93}
			,rs232ced;
		{$ELSE}
			{$IFDEF VER100}
				,rs232ced;
			{$ELSE}
				{$IFDEF VER110}
					,rs232ced;
				{$ELSE}
					{$IFDEF VER120}
						,rs232ced;
					{$ELSE}
						{$IFDEF VER125}
							,rs232ced;
						{$ELSE}
							;
						{$ENDIF}
					{$ENDIF}
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
	{$ENDIF}
{$ENDIF}

const
	//とりあえずメッセージ番号は WM_APP+501～WM_APP+510とします。
	//他とかち合う場合は変更して下さい。
	WM_RS232C_BREAK	=WM_APP+501;
	WM_RS232C_CTS		=WM_APP+502;
	WM_RS232C_DSR		=WM_APP+503;
	WM_RS232C_ERR		=WM_APP+504;
	WM_RS232C_RING	=WM_APP+505;
	WM_RS232C_RLSD	=WM_APP+506;
	WM_RS232C_PACKET=WM_APP+507;
	WM_RS232C_RXCHAR=WM_APP+508;
	WM_RS232C_RXFLAG=WM_APP+509;
	WM_RS232C_TXEMPTY=WM_APP+510;

type
	rsflowset=set of (
		dfBinary,	//バイナリ モード､ EOFをチェックしない
		dfParity,	//パリティ チェックを有効
		dfOutxCtsFlow,	//CTS出力フロー制御
		dfOutxDsrFlow,	//DSR出力フロー制御
		dfDtrControl_b0,		//DTRフロー制御の種類(bit0)
		dfDtrControl_b1,		//DTRフロー制御の種類(bit1)
		dfDsrSensitivity,	 //DSRの感度
		dfTXContinueOnXoff,	//XOFF後も送信を継続
		dfOutX,		//XON/XOFF出力フロー制御
		dfInX,		//XON/XOFF入力フロー制御
		dfErrorChar,	//エラーによる置換を有効
		dfNull,		//ヌル ストリッピングを有効
		dfRtsControl_b0,	//RTSフロー制御(bit0)
		dfRtsControl_b1,	//RTSフロー制御(bit1)
		dfAbortOnError	//エラー時に読み取りまたは書き込みを中止
	);

	Trs232c = class(TComponent)
	private
		{ Private 宣言 }
		rshandle:thandle; //通信ハンドル
		dcb:tdcb;
		timeout:tcommtimeouts;
		evmask:DWORD;
		data_size:integer;

		commthd:tcommthread;

		fbps:integer;
		frxbuffsize:integer;
		ftxbuffsize:integer;
		fportname:string;
		fcharbit:integer;
		fstopbit:string;
		freadinterval:integer;
		frxtimeout:integer;
		ftxtimeout:integer;
		fparity:string;
		fflowflag:integer;

		fXonLim:integer;
		fXoffLim:integer;
		fXonChar:char;
		fXoffChar:char;
		fErrorChar:char;
		fEofChar:char;
		fEvtChar:char;

		fdebug:boolean;

		openflg:boolean;

		makethread:boolean;

		fpacketsize:integer;

		readnum:dword;
		readsize:dword;
		readEvent:THandle;
		readOverLap:TOverLapped;
		writenum:dword;
		writesize:dword;
		writeEvent:THandle;
		writeOverLap:TOverLapped;

		fevbreak:TNotifyEvent;
		fevcts:TNotifyEvent;
		fevdsr:TNotifyEvent;
		feverr:TNotifyEvent;
		fevring:TNotifyEvent;
		fevrlsd:TNotifyEvent;
		fevrxchar:TNotifyEvent;
		fevrxflag:TNotifyEvent;
		fevtxempty:TNotifyEvent;
		fevcreate:TNotifyEvent;
		fevopen:TNotifyEvent;
		fevclose:TNotifyEvent;
		fevpacket:TNotifyEvent;

		rshwnd:HWND;
    FEvError: TNotifyEvent;
    FErrorMsg: string;
		procedure WndProc(var Msg:TMessage);
	protected
		{ Protected 宣言 }
		charbuff:array[0..1] of char;
	public
		{ Public 宣言 }
		constructor create(aowner:tcomponent); override;
		destructor destroy; override;

		function rsopen:boolean;
		function rsclose:boolean;
		function rsread(var data:array of char;size:integer):boolean;
		function rswrite(const data;size:integer):boolean;
		function rswritechar(data:char):boolean;
		function rsreadchar(var data:char):boolean;
		function rxdatalen:integer;
		function txdatalen:integer;
		function rswritestr(data:array of char;size:integer):boolean;
		function getcommhandle:THandle;

		function getcts:boolean;
		function getdsr:boolean;
		function getring:boolean;
		function getrlsd:boolean;
		function set_rts(flg:boolean):boolean;
		function set_dtr(flg:boolean):boolean;

		function read_fflow_read:rsflowset;
		procedure fflow_write(flow:rsflowset);

		procedure event_proc;
	published
		{ Published 宣言 }
		property charbit:integer read fcharbit write fcharbit;
		property stopbit:string read fstopbit write fstopbit;
		property bps:integer read fbps write fbps;
		property portname:string read fportname write fportname;
		property rxbuffsize:integer read frxbuffsize write frxbuffsize;
		property txbuffsize:integer read ftxbuffsize write ftxbuffsize;
		property readinterval:integer read freadinterval write freadinterval;
		property txtimeout:integer read ftxtimeout write ftxtimeout;
		property rxtimeout:integer read frxtimeout write frxtimeout;
		property paritymode:string read fparity write fparity;
		property flowflag:integer read fflowflag write fflowflag;
		property packetsize:integer read fpacketsize write fpacketsize;

		property flow:rsflowset read read_fflow_read write fflow_write;

		property debug:boolean read fdebug write fdebug;

		property XonLim:integer read fXonLim write fXonLim;
		property XoffLim:integer read fXoffLim write fXoffLim;
		property XonChar:char read fXonChar write fXonChar;
		property XoffChar:char read fXoffChar write fXoffChar;
		property ErrorChar:char read fErrorChar write fErrorChar;
		property EofChar:char read fEofChar write fEofChar;
		property EvtChar:char read fEvtChar write fEvtChar;

		property OnBREAK:TNotifyEvent read fevbreak write fevbreak;
		property OnCTS:TNotifyEvent read fevcts write fevcts;
		property OnDSR:TNotifyEvent read fevdsr write fevdsr;
		property OnERR:TNotifyEvent read feverr write feverr;
		property OnRING:TNotifyEvent read fevring write fevring;
		property OnRLSD:TNotifyEvent read fevrlsd write fevrlsd;
		property OnRXCHAR:TNotifyEvent read fevrxchar write fevrxchar;
		property OnRXFLAG:TNotifyEvent read fevrxflag write fevrxflag;
		property OnTXEMPTY:TNotifyEvent read fevtxempty write fevtxempty;
		property OnCreate:TNotifyEvent read fevcreate write fevcreate;
		property OnOpen:TNotifyEvent read fevopen write fevopen;
		property OnClose:TNotifyEvent read fevclose write fevclose;
		property OnPACKET:TNotifyEvent read fevpacket write fevpacket;
    property OnError: TNotifyEvent read FEvError write FEvError;

    property ErrorMsg: string read FErrorMsg write FErrorMsg;
	end;

procedure Register;

implementation

procedure Register;
begin
	RegisterComponents('MyVCL', [TRS232C]);
end;

constructor Trs232c.create(aowner:tcomponent);
begin
	inherited create(aowner); {親のコンストラクタを呼ぶ}

	//初期値を設定
	bps:=9600;
	charbit:=8;
	stopbit:='1';
	paritymode:='無し';
	portname:='COM1';
	rxbuffsize:=1024;
	txbuffsize:=1024;
	txtimeout:=30000;
	rxtimeout:=30000;
	readinterval:=0;
	packetsize:=0;
//  flowflag:=($2000 or $0004); //RTS CTSハードフロー制御
	flowflag:=$1;

	XonLim:=0;
	XoffLim:=0;
	XonChar:=#17;
	XoffChar:=#19;
	ErrorChar:=#0;
	EofChar:=#0;
	EofChar:=#0;

	debug:=false;

	rshwnd:=AllocateHWnd(WndProc);

	if assigned(OnCreate) then
		OnCreate(self);
end;

destructor Trs232c.destroy;
begin
	rsclose();

	DeallocateHWnd(rshwnd);

	inherited destroy;  {親のデストラクタを呼ぶ}
end;

function Trs232c.rsopen:boolean;
begin
	//既にオープンされていたら抜ける
	if openflg=true then
	begin
		rsopen:=false;
		exit;
	end;

	//ポートをオープンする
	rshandle:=createfile(
		pchar(portname),
		GENERIC_READ or GENERIC_WRITE,
		0,
{   FILE_SHARE_READ or FILE_SHARE_WRITE,}
		nil,
		OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED,
		0);

	if rshandle=INVALID_HANDLE_VALUE then
	begin
		if debug then
      if Assigned(FEvError) then
      begin
			  FErrorMsg := ('回線オープンエラー');
        FEvError(Self);
      end;
		rsopen:=false;
		exit;
	end;

	//バッファサイズの設定
	if setupcomm(rshandle,rxbuffsize,txbuffsize)=false then
	begin
		if debug then
      if Assigned(FEvError) then
      begin
			  FErrorMsg := ('バッファサイズ設定エラー');
        FEvError(Self);
      end;
		rsopen:=false;
		PurgeComm(rshandle,PURGE_TXABORT or PURGE_RXABORT);
		exit;
	end;

	//パラメータ設定
	getcommstate(rshandle,dcb);

	with dcb do
	begin
		baudrate:=bps;

		if stopbit='1' then
			stopbits:=0
		else if stopbit='1.5' then
			stopbits:=1
		else if stopbit='2' then
			stopbits:=2;

		if paritymode='無し' then
			parity:=0
		else if paritymode='なし' then
			parity:=0
		else if paritymode='奇数' then
			parity:=1
		else if paritymode='きすう' then
			parity:=1
		else if paritymode='ODD' then
			parity:=1
		else if paritymode='odd' then
			parity:=1
		else if paritymode='ＯＤＤ' then
			parity:=1
		else if paritymode='ｏｄｄ' then
			parity:=1
		else if paritymode='偶数' then
			parity:=2
		else if paritymode='ぐうすう' then
			parity:=2
		else if paritymode='EVEN' then
			parity:=2
		else if paritymode='even' then
			parity:=2
		else if paritymode='ＥＶＥＮ' then
			parity:=2
		else if paritymode='ｅｖｅｎ' then
			parity:=2
		else if paritymode='マーク' then
			parity:=3
		else if paritymode='まーく' then
			parity:=3
		else if paritymode='MARK' then
			parity:=3
		else if paritymode='mark' then
			parity:=3
		else if paritymode='ＭＡＲＫ' then
			parity:=3
		else if paritymode='ｍａｒｋ' then
			parity:=3
		else if paritymode='スペース' then
			parity:=4
		else if paritymode='すぺーす' then
			parity:=4
		else if paritymode='SPACE' then
			parity:=4
		else if paritymode='space' then
			parity:=4
		else if paritymode='ＳＰＡＣＥ' then
			parity:=4
		else if paritymode='ｓｐａｃｅ' then
			parity:=4;

		bytesize:=charbit;

		flags:=flowflag;

		if fXonLim<>0 then
			XonLim:=fXonLim;

		if fXoffLim<>0 then
			XoffLim:=fXoffLim;

		if fXonChar<>#0 then
			XonChar:=fXonChar;

		if fXoffChar<>#0 then
			XoffChar:=fXoffChar;

		if fErrorChar<>#0 then
			ErrorChar:=fErrorChar;

		if fEofChar<>#0 then
			EofChar:=fEofChar;

		if fEvtChar<>#0 then
			EvtChar:=fEvtChar;
	end;

	if setcommstate(rshandle,dcb)=false then
	begin
		if debug then
      if Assigned(FEvError) then
      begin
			  FErrorMsg := ('通信条件設定エラー');
        FEvError(Self);
      end;
		rsopen:=false;
		PurgeComm(rshandle,PURGE_TXABORT or PURGE_RXABORT);
		exit;
	end;

	//タイムアウト値を設定
	getcommtimeouts(rshandle,timeout);

	with timeout do
	begin
		readintervaltimeout:=readinterval;
		readtotaltimeoutmultiplier:=0;
		readtotaltimeoutconstant:=rxtimeout;
		writetotaltimeoutmultiplier:=0;
		writetotaltimeoutconstant:=txtimeout;
	end;

	if setcommtimeouts(rshandle,timeout)=false then
	begin
		if debug then
      if Assigned(FEvError) then
      begin
			  FErrorMsg := ('タイムアウト時間設定エラー');
        FEvError(Self);
      end;
		rsopen:=false;
		PurgeComm(rshandle,PURGE_TXABORT or PURGE_RXABORT);
		exit;
	end;

	//イベントマスクの設定
	evmask:=0;

	if assigned(OnBREAK) then
		evmask:=evmask or EV_BREAK;
	if assigned(OnCTS) then
		evmask:=evmask or EV_CTS;
	if assigned(OnDSR) then
		evmask:=evmask or EV_DSR;
	if assigned(OnERR) then
		evmask:=evmask or EV_ERR;
	if assigned(OnRING) then
		evmask:=evmask or EV_RING;
	if assigned(OnRLSD) then
		evmask:=evmask or EV_RLSD;
	if assigned(OnRXCHAR) then
		evmask:=evmask or EV_RXCHAR;
	if assigned(OnPACKET) then
		evmask:=evmask or EV_RXCHAR;
	if assigned(OnRXFLAG) then
		evmask:=evmask or EV_RXFLAG;
	if assigned(OnTXEMPTY) then
		evmask:=evmask or EV_TXEMPTY;

	setcommmask(rshandle,evmask);

	//バッファをクリアする
	purgecomm(rshandle,PURGE_TXABORT or PURGE_RXABORT or
		PURGE_TXCLEAR or PURGE_RXCLEAR);

	//イベントが定義されていれば，スレッドを作成する
	if evmask<>0 then
		makethread:=true
	else
		makethread:=false;

	if makethread=true then
	begin
		commthd:=TCommthread.create(True);
		with commthd do
		begin
			FreeOnTerminate:=false;	//自動的に破棄しない
			data_size:=0;
			oya:=self;
			handle:=rshandle;
		end;
	end;

	readEvent:=createEvent(nil,true,false,nil);
	resetEvent(readEvent);

	with readOverLap do
	begin
		offset:=0;
		offsethigh:=0;
		hEvent:=readEvent;
	end;

	writeEvent:=createEvent(nil,true,false,nil);
	resetevent(writeEvent);
	with writeOverLap do
	begin
		offset:=0;
		offsethigh:=0;
		hEvent:=writeEvent;
	end;

	//スレッドを実行させる
	if makethread=true then
		commthd.Resume;

	openflg:=true;
	rsopen:=true;

	if assigned(OnOpen) then
		OnOpen(self);
end;

function Trs232c.rsclose:boolean;
begin
	//既に終了していたら抜ける
	if openflg=false then
	begin
		rsclose:=false;
		exit;
	end;

	PurgeComm(rshandle,PURGE_TXABORT or PURGE_RXABORT);

	//スレッドを終了させる
	if makethread=true then
	begin
		commthd.Terminate;

		//マスクを操作することで、イベント待ちを解除する
		setcommmask(rshandle,0);

		//スレッド終了まで待つ
		commthd.WaitFor;

		//スレッドを破棄
		commthd.Destroy;
	end;

	openflg:=false;

	if assigned(OnClose) then
		OnClose(self);

	//イベントハンドルを閉じる
	closehandle(readEvent);
	closehandle(writeEvent);

	rsclose:=closehandle(rshandle);
end;

//データを受信する
function Trs232c.rsread(var data:array of char;size:integer):boolean;
begin
	if openflg=false then
	begin
		rsread:=false;
		exit;
	end;

	resetEvent(readEvent);
	rsread:=false;
	if readfile(rshandle,data,size,readnum,@readOverLap)=false then
		if GetLastError=ERROR_IO_PENDING then
			if waitforsingleobject(readEvent,rxtimeout)=WAIT_OBJECT_0 then
				if GetOverlappedResult(rshandle,readOverLap,readsize,false)=true then
					if readsize=dword(size) then
						rsread:=true
					else
				else
			else
		else
	else
		rsread:=true;
end;

//データを送信する
function Trs232c.rswrite(const data;size:integer):boolean;
begin
	if openflg=false then
	begin
		rswrite:=false;
		exit;
	end;

	resetevent(writeEvent);
	rswrite:=false;
	if writefile(rshandle,data,size,writenum,@writeOverLap)=false then
		if GetLastError=ERROR_IO_PENDING then
			if waitforsingleobject(writeEvent,txtimeout)=WAIT_OBJECT_0 then
				if GetOverlappedResult(rshandle,writeOverLap,writesize,false)=true then
					if writesize=dword(size) then
						rswrite:=true
					else
				else
			else
		else
	else
		rswrite:=true;
end;

//データを１バイトずつ送信する
function Trs232c.rswritestr(data:array of char;size:integer):boolean;
var
	counter:integer;
begin
	if openflg=false then
	begin
		rswritestr:=false;
		exit;
	end;

	for counter:=1 to size do
	begin
		if rswritechar(data[counter-1])=false then
		begin
			rswritestr:=false;
			exit;
		end;
		// application.processmessages;
	end;
	rswritestr:=true;
end;

//１バイトデータを受信する
function Trs232c.rsreadchar(var data:char):boolean;
begin
	if rsread(charbuff,1)=true then
	begin
		data:=charbuff[0];
		rsreadchar:=true;
	end
	else
		rsreadchar:=false;
end;

//１バイトデータを送信する
function Trs232c.rswritechar(data:char):boolean;
begin
	charbuff[0]:=data;
	if rswrite(charbuff,1)=true then
		rswritechar:=true
	else
		rswritechar:=false;
end;

//受信データ数を取得する
function Trs232c.rxdatalen:integer;
var
	errcode:DWORD;
	comstat2:tcomstat;
begin
	if openflg=false then
	begin
		rxdatalen:=-1;
		exit;
	end;

	clearcommerror(rshandle,errcode,@comstat2);
	rxdatalen:=comstat2.cbInQue;
end;

//送信可能データ数を取得する
function Trs232c.txdatalen:integer;
var
	errcode:DWORD;
	comstat2:tcomstat;
begin
	if openflg=false then
	begin
		txdatalen:=-1;
		exit;
	end;

	clearcommerror(rshandle,errcode,@comstat2);
	txdatalen:=comstat2.cbOutQue;
end;

//通信ハンドルの取得
function Trs232c.getcommhandle:THandle;
begin
	if openflg=false then
	begin
		getcommhandle:=0;
		exit;
	end;

	getcommhandle:=rshandle;
end;

//CTSをチェック
function Trs232c.getcts:boolean;
var
	status:dword;
begin
	//回線がオープンされているかチェック
	if openflg=false then
	begin
		getcts:=false;
		exit;
	end;

	status:=MS_CTS_ON;
	getcommmodemstatus(rshandle,status);
	if (status and MS_CTS_ON)<>0 then
		getcts:=true
	else
		getcts:=false;
end;

//DSRをチェック
function Trs232c.getdsr:boolean;
var
	status:dword;
begin
	//回線がオープンされているかチェック
	if openflg=false then
	begin
		getdsr:=false;
		exit;
	end;

	status:=MS_DSR_ON;
	getcommmodemstatus(rshandle,status);
	if (status and MS_DSR_ON)<>0 then
		getdsr:=true
	else
		getdsr:=false;
end;

function Trs232c.getring:boolean;
var
	status:dword;
begin
	//回線がオープンされているかチェック
	if openflg=false then
	begin
		getring:=false;
		exit;
	end;

	status:=MS_RING_ON;
	getcommmodemstatus(rshandle,status);
	if (status and MS_RING_ON)<>0 then
		getring:=true
	else
		getring:=false;
end;

function Trs232c.getrlsd:boolean;
var
	status:dword;
begin
	//回線がオープンされているかチェック
	if openflg=false then
	begin
		getrlsd:=false;
		exit;
	end;

	status:=MS_RLSD_ON;
	getrlsd:=getcommmodemstatus(rshandle,status);
end;

//RTSを設定する
function Trs232c.set_rts(flg:boolean):boolean;
begin
	//回線がオープンされているかチェック
	if openflg=false then
	begin
		set_rts:=false;
		exit;
	end;

	if flg then
		set_rts:=EscapeCommFunction(rshandle,SETRTS)
	else
		set_rts:=EscapeCommFunction(rshandle,CLRRTS);
end;

//DTRを設定する
function Trs232c.set_dtr(flg:boolean):boolean;
begin
	//回線がオープンされているかチェック
	if openflg=false then
	begin
		set_dtr:=false;
		exit;
	end;

	if flg then
		set_dtr:=EscapeCommFunction(rshandle,SETDTR)
	else
		set_dtr:=EscapeCommFunction(rshandle,CLRDTR);
end;


function Trs232c.read_fflow_read:rsflowset;
var
	flow:rsflowset;
begin
	flow:=[];
	if (flowflag and $1)=$1 then
		flow:=flow+[dfBinary];
	if (flowflag and $2)=$2 then
		flow:=flow+[dfParity];
	if (flowflag and $4)=$4 then
		flow:=flow+[dfOutxCtsFlow];
	if (flowflag and $8)=$8 then
		flow:=flow+[dfOutxDsrFlow];
	if (flowflag and $10)=$10 then
		flow:=flow+[dfDtrControl_b0];
	if (flowflag and $20)=$20 then
		flow:=flow+[dfDtrControl_b1];
	if (flowflag and $40)=$40 then
		flow:=flow+[dfDsrSensitivity];
	if (flowflag and $80)=$80 then
		flow:=flow+[dfTXContinueOnXoff];
	if (flowflag and $100)=$100 then
		flow:=flow+[dfOutX];
	if (flowflag and $200)=$200 then
		flow:=flow+[dfInX];
	if (flowflag and $400)=$400 then
		flow:=flow+[dfErrorChar];
	if (flowflag and $800)=$800 then
		flow:=flow+[dfNull];
	if (flowflag and $1000)=$1000 then
		flow:=flow+[dfRtsControl_b0];
	if (flowflag and $2000)=$2000 then
		flow:=flow+[dfRtsControl_b1];
	if (flowflag and $4000)=$4000 then
		flow:=flow+[dfAbortOnError];

	result:=flow;
end;

procedure Trs232c.fflow_write(flow:rsflowset);
var
	res:integer;
begin
	res:=0;
	if (dfBinary in flow) then
		res:=res+$01;
	if (dfParity in flow) then
		res:=res+$02;
	if (dfOutxCtsFlow in flow) then
		res:=res+$04;
	if (dfOutxDsrFlow in flow) then
		res:=res+$08;
	if (dfDtrControl_b0 in flow) then
		res:=res+$10;
	if (dfDtrControl_b1 in flow) then
		res:=res+$20;
	if (dfDsrSensitivity in flow) then
		res:=res+$40;
	if (dfTXContinueOnXoff in flow) then
		res:=res+$80;
	if (dfOutX in flow) then
		res:=res+$100;
	if (dfInX in flow) then
		res:=res+$200;
	if (dfErrorChar in flow) then
		res:=res+$400;
	if (dfNull in flow) then
		res:=res+$800;
	if (dfRtsControl_b0 in flow) then
		res:=res+$1000;
	if (dfRtsControl_b1 in flow) then
		res:=res+$2000;
	if (dfAbortOnError in flow) then
		res:=res+$4000;

	flowflag:=res;
end;

procedure Trs232c.event_proc;
var
	errcode:DWORD;
	comstat2:tcomstat;
begin
	//ＢＲＥＡＫ信号検出
	if (commthd.mask and EV_BREAK)=EV_BREAK then
	begin
		if Assigned(OnBREAK) then
			PostMessage(rshwnd,WM_RS232C_BREAK,0,0);
	end;

	//ＣＴＳ信号の変化
	if (commthd.mask and EV_CTS)=EV_CTS then
	begin
		if Assigned(OnCTS) then
			PostMessage(rshwnd,WM_RS232C_CTS,0,0);
	end;

	//ＤＳＲ信号の変化
	if (commthd.mask and EV_DSR)=EV_DSR then
	begin
		if Assigned(OnDSR) then
			PostMessage(rshwnd,WM_RS232C_DSR,0,0);
	end;

	//エラー
	if (commthd.mask and EV_ERR)=EV_ERR then
	begin
		if Assigned(OnERR) then
			PostMessage(rshwnd,WM_RS232C_ERR,0,0);
	end;

	//ＲＩＮＧ検出
	if (commthd.mask and EV_RING)=EV_RING then
	begin
		if Assigned(OnRING) then
			PostMessage(rshwnd,WM_RS232C_RING,0,0);
	end;

	//ＲＬＳＤ信号の変化
	if (commthd.mask and EV_RLSD)=EV_RLSD then
	begin
		if Assigned(OnRLSD) then
			PostMessage(rshwnd,WM_RS232C_RLSD,0,0);
	end;

{
	//文字受信
	if (commthd.mask and EV_RXCHAR)=EV_RXCHAR then
	begin
		clearcommerror(rshandle,errcode,@comstat2);
		data_size:=comstat2.cbInQue;
		if Assigned(OnPACKET) then
			if (packetsize<>0) and
				 (data_size>=packetsize) then
			begin
				data_size:=0;
				PostMessage(rshwnd,WM_RS232C_PACKET,0,0);
			end;
		if Assigned(OnRXCHAR) then
			PostMessage(rshwnd,WM_RS232C_RXCHAR,0,0);
	end;

	//イベント文字受信
	if (commthd.mask and EV_RXFLAG)=EV_RXFLAG then
	begin
		if Assigned(OnRXFLAG) then
			PostMessage(rshwnd,WM_RS232C_RXFLAG,0,0);
	end;
}


  // これでいいのか、使って見ないとわからない^^;
  // でも、両方のイベント処理で受信データを取り合う
  // ことはなくなりそう！
  //
  // パケットサイズが０以外ならパケットで受信する
  if (packetsize<>0) then begin
    if Assigned(OnPACKET) then begin
      data_size:=0;
      PostMessage(rshwnd,WM_RS232C_PACKET,0,0);
    end;
  end
  // パケットサイズが０なら通常受信する
  else begin
    if Assigned(OnRXCHAR) then begin
      PostMessage(rshwnd,WM_RS232C_RXCHAR,0,0);
    end;
  end;

	//出力バッファが空
	if (commthd.mask and EV_TXEMPTY)=EV_TXEMPTY then
	begin
		if Assigned(OnTXEMPTY) then
			PostMessage(rshwnd,WM_RS232C_TXEMPTY,0,0);
	end;
end;

procedure Trs232c.WndProc(var Msg: TMessage);
begin
	try
		with Msg do
			case Msg of
				WM_RS232C_BREAK	:OnBREAK(Self);
				WM_RS232C_CTS		:OnCTS(Self);
				WM_RS232C_DSR		:OnDSR(Self);
				WM_RS232C_ERR		:OnERR(Self);
				WM_RS232C_RING	:OnRING(Self);
				WM_RS232C_RLSD	:OnRLSD(Self);
				WM_RS232C_PACKET:OnPACKET(Self);
				WM_RS232C_RXCHAR:OnRXCHAR(Self);
				WM_RS232C_RXFLAG:OnRXFLAG(Self);
				WM_RS232C_TXEMPTY:OnTXEMPTY(Self);
			else
				result:=DefWindowProc(rshwnd,Msg,wParam,lParam);
			end;
	except
    if Assigned(FEvError) then
    begin
      FErrorMsg := ('タイムアウト時間設定エラー');
      FEvError(Self);
    end;
 	end
end;

end.





