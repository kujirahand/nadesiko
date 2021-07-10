{ RS-232C�ʐM�R���|�[�l���g Ver2.3

	(C)Copyright 1998-2003 ��X��K��

  ����: �i�f�V�R�p�ɉ��� by �N�W����s��(2005/01/24)
}
unit rs232c;

interface

{
	�ȉ��̃R���p�C���̂݃v���p�e�B�G�f�B�^��L���ɂ���
	
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
	//�Ƃ肠�������b�Z�[�W�ԍ��� WM_APP+501�`WM_APP+510�Ƃ��܂��B
	//���Ƃ��������ꍇ�͕ύX���ĉ������B
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
		dfBinary,	//�o�C�i�� ���[�h� EOF���`�F�b�N���Ȃ�
		dfParity,	//�p���e�B �`�F�b�N��L��
		dfOutxCtsFlow,	//CTS�o�̓t���[����
		dfOutxDsrFlow,	//DSR�o�̓t���[����
		dfDtrControl_b0,		//DTR�t���[����̎��(bit0)
		dfDtrControl_b1,		//DTR�t���[����̎��(bit1)
		dfDsrSensitivity,	 //DSR�̊��x
		dfTXContinueOnXoff,	//XOFF������M���p��
		dfOutX,		//XON/XOFF�o�̓t���[����
		dfInX,		//XON/XOFF���̓t���[����
		dfErrorChar,	//�G���[�ɂ��u����L��
		dfNull,		//�k�� �X�g���b�s���O��L��
		dfRtsControl_b0,	//RTS�t���[����(bit0)
		dfRtsControl_b1,	//RTS�t���[����(bit1)
		dfAbortOnError	//�G���[���ɓǂݎ��܂��͏������݂𒆎~
	);

	Trs232c = class(TComponent)
	private
		{ Private �錾 }
		rshandle:thandle; //�ʐM�n���h��
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
		{ Protected �錾 }
		charbuff:array[0..1] of char;
	public
		{ Public �錾 }
		constructor Create(AOwner:TComponent); override;
		destructor Destroy; override;

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
		{ Published �錾 }
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

constructor Trs232c.Create(AOwner:TComponent);
begin
	inherited create(aowner); {�e�̃R���X�g���N�^���Ă�}

	//�����l��ݒ�
	bps:=9600;
	charbit:=8;
	stopbit:='1';
	paritymode:='����';
	portname:='COM1';
	rxbuffsize:=1024;
	txbuffsize:=1024;
	txtimeout:=30000;
	rxtimeout:=30000;
	readinterval:=0;
	packetsize:=0;
//  flowflag:=($2000 or $0004); //RTS CTS�n�[�h�t���[����
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

destructor Trs232c.Destroy;
begin
	rsclose();

	DeallocateHWnd(rshwnd);

	inherited destroy;  {�e�̃f�X�g���N�^���Ă�}
end;

function Trs232c.rsopen:boolean;
begin
	//���ɃI�[�v������Ă����甲����
	if openflg=true then
	begin
		rsopen:=false;
		exit;
	end;

	//�|�[�g���I�[�v������
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
			  FErrorMsg := ('����I�[�v���G���[');
        FEvError(Self);
      end;
		rsopen:=false;
		exit;
	end;

	//�o�b�t�@�T�C�Y�̐ݒ�
	if setupcomm(rshandle,rxbuffsize,txbuffsize)=false then
	begin
		if debug then
      if Assigned(FEvError) then
      begin
			  FErrorMsg := ('�o�b�t�@�T�C�Y�ݒ�G���[');
        FEvError(Self);
      end;
		rsopen:=false;
		PurgeComm(rshandle,PURGE_TXABORT or PURGE_RXABORT);
		exit;
	end;

	//�p�����[�^�ݒ�
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

		if paritymode='����' then
			parity:=0
		else if paritymode='�Ȃ�' then
			parity:=0
		else if paritymode='�' then
			parity:=1
		else if paritymode='������' then
			parity:=1
		else if paritymode='ODD' then
			parity:=1
		else if paritymode='odd' then
			parity:=1
		else if paritymode='�n�c�c' then
			parity:=1
		else if paritymode='������' then
			parity:=1
		else if paritymode='����' then
			parity:=2
		else if paritymode='��������' then
			parity:=2
		else if paritymode='EVEN' then
			parity:=2
		else if paritymode='even' then
			parity:=2
		else if paritymode='�d�u�d�m' then
			parity:=2
		else if paritymode='��������' then
			parity:=2
		else if paritymode='�}�[�N' then
			parity:=3
		else if paritymode='�܁[��' then
			parity:=3
		else if paritymode='MARK' then
			parity:=3
		else if paritymode='mark' then
			parity:=3
		else if paritymode='�l�`�q�j' then
			parity:=3
		else if paritymode='��������' then
			parity:=3
		else if paritymode='�X�y�[�X' then
			parity:=4
		else if paritymode='���؁[��' then
			parity:=4
		else if paritymode='SPACE' then
			parity:=4
		else if paritymode='space' then
			parity:=4
		else if paritymode='�r�o�`�b�d' then
			parity:=4
		else if paritymode='����������' then
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
			  FErrorMsg := ('�ʐM�����ݒ�G���[');
        FEvError(Self);
      end;
		rsopen:=false;
		PurgeComm(rshandle,PURGE_TXABORT or PURGE_RXABORT);
		exit;
	end;

	//�^�C���A�E�g�l��ݒ�
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
			  FErrorMsg := ('�^�C���A�E�g���Ԑݒ�G���[');
        FEvError(Self);
      end;
		rsopen:=false;
		PurgeComm(rshandle,PURGE_TXABORT or PURGE_RXABORT);
		exit;
	end;

	//�C�x���g�}�X�N�̐ݒ�
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

	//�o�b�t�@���N���A����
	purgecomm(rshandle,PURGE_TXABORT or PURGE_RXABORT or
		PURGE_TXCLEAR or PURGE_RXCLEAR);

	//�C�x���g����`����Ă���΁C�X���b�h���쐬����
	if evmask<>0 then
		makethread:=true
	else
		makethread:=false;

	if makethread=true then
	begin
		commthd:=TCommthread.create(True);
		with commthd do
		begin
			FreeOnTerminate:=false;	//�����I�ɔj�����Ȃ�
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

	//�X���b�h�����s������
	if makethread=true then
		commthd.Resume;

	openflg:=true;
	rsopen:=true;

	if assigned(OnOpen) then
		OnOpen(self);
end;

function Trs232c.rsclose:boolean;
begin
	//���ɏI�����Ă����甲����
	if openflg=false then
	begin
		rsclose:=false;
		exit;
	end;

	PurgeComm(rshandle,PURGE_TXABORT or PURGE_RXABORT);

	//�X���b�h���I��������
	if makethread=true then
	begin
		commthd.Terminate;

		//�}�X�N�𑀍삷�邱�ƂŁA�C�x���g�҂�����������
		setcommmask(rshandle,0);

		//�X���b�h�I���܂ő҂�
		commthd.WaitFor;

		//�X���b�h��j��
		commthd.Destroy;
	end;

	openflg:=false;

	if assigned(OnClose) then
		OnClose(self);

	//�C�x���g�n���h�������
	closehandle(readEvent);
	closehandle(writeEvent);

	rsclose:=closehandle(rshandle);
end;

//�f�[�^����M����
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

//�f�[�^�𑗐M����
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

//�f�[�^���P�o�C�g�����M����
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

//�P�o�C�g�f�[�^����M����
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

//�P�o�C�g�f�[�^�𑗐M����
function Trs232c.rswritechar(data:char):boolean;
begin
	charbuff[0]:=data;
	if rswrite(charbuff,1)=true then
		rswritechar:=true
	else
		rswritechar:=false;
end;

//��M�f�[�^�����擾����
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

//���M�\�f�[�^�����擾����
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

//�ʐM�n���h���̎擾
function Trs232c.getcommhandle:THandle;
begin
	if openflg=false then
	begin
		getcommhandle:=0;
		exit;
	end;

	getcommhandle:=rshandle;
end;

//CTS���`�F�b�N
function Trs232c.getcts:boolean;
var
	status:dword;
begin
	//������I�[�v������Ă��邩�`�F�b�N
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

//DSR���`�F�b�N
function Trs232c.getdsr:boolean;
var
	status:dword;
begin
	//������I�[�v������Ă��邩�`�F�b�N
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
	//������I�[�v������Ă��邩�`�F�b�N
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
	//������I�[�v������Ă��邩�`�F�b�N
	if openflg=false then
	begin
		getrlsd:=false;
		exit;
	end;

	status:=MS_RLSD_ON;
	getrlsd:=getcommmodemstatus(rshandle,status);
end;

//RTS��ݒ肷��
function Trs232c.set_rts(flg:boolean):boolean;
begin
	//������I�[�v������Ă��邩�`�F�b�N
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

//DTR��ݒ肷��
function Trs232c.set_dtr(flg:boolean):boolean;
begin
	//������I�[�v������Ă��邩�`�F�b�N
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
	//�a�q�d�`�j�M�����o
	if (commthd.mask and EV_BREAK)=EV_BREAK then
	begin
		if Assigned(OnBREAK) then
			PostMessage(rshwnd,WM_RS232C_BREAK,0,0);
	end;

	//�b�s�r�M���̕ω�
	if (commthd.mask and EV_CTS)=EV_CTS then
	begin
		if Assigned(OnCTS) then
			PostMessage(rshwnd,WM_RS232C_CTS,0,0);
	end;

	//�c�r�q�M���̕ω�
	if (commthd.mask and EV_DSR)=EV_DSR then
	begin
		if Assigned(OnDSR) then
			PostMessage(rshwnd,WM_RS232C_DSR,0,0);
	end;

	//�G���[
	if (commthd.mask and EV_ERR)=EV_ERR then
	begin
		if Assigned(OnERR) then
			PostMessage(rshwnd,WM_RS232C_ERR,0,0);
	end;

	//�q�h�m�f���o
	if (commthd.mask and EV_RING)=EV_RING then
	begin
		if Assigned(OnRING) then
			PostMessage(rshwnd,WM_RS232C_RING,0,0);
	end;

	//�q�k�r�c�M���̕ω�
	if (commthd.mask and EV_RLSD)=EV_RLSD then
	begin
		if Assigned(OnRLSD) then
			PostMessage(rshwnd,WM_RS232C_RLSD,0,0);
	end;

{
	//������M
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

	//�C�x���g������M
	if (commthd.mask and EV_RXFLAG)=EV_RXFLAG then
	begin
		if Assigned(OnRXFLAG) then
			PostMessage(rshwnd,WM_RS232C_RXFLAG,0,0);
	end;
}

  // ����ł����̂��A�g���Č��Ȃ��Ƃ킩��Ȃ�^^;
  // �ł��A�����̃C�x���g�����Ŏ�M�f�[�^����荇��
  // ���Ƃ͂Ȃ��Ȃ肻���I
  //
  // �p�P�b�g�T�C�Y���O�ȊO�Ȃ�p�P�b�g�Ŏ�M����
  if (packetsize<>0) then begin
    if Assigned(OnPACKET) then begin
      data_size:=0;
      PostMessage(rshwnd,WM_RS232C_PACKET,0,0);
    end;
  end
  // �p�P�b�g�T�C�Y���O�Ȃ�ʏ��M����
  else begin
    if Assigned(OnRXCHAR) then begin
      PostMessage(rshwnd,WM_RS232C_RXCHAR,0,0);
    end;
  end;

	//�o�̓o�b�t�@����
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
      FErrorMsg := ('�^�C���A�E�g���Ԑݒ�G���[');
      FEvError(Self);
    end;
 	end
end;

end.





