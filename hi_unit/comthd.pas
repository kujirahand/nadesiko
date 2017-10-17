{ RS-232Cコンポーネント Ver2.3用 受信スレッド

	(C)Copyright 1998-2003 千々岩幸治
}

unit comthd;

interface

uses
	Classes,windows;

type
	tcommthread = class(TThread)
	private
		{ Private 宣言 }
	protected
		procedure Execute; override;
	public
		oya:Tcomponent;
		mask:DWORD;
    handle:thandle;
		constructor Create(flg:boolean);
	end;

implementation

uses
	rs232c;

{注意:
	メインスレッドが所有する VCL のメソッド/関数/プロパティを
	扱うには、このクラスに他のオブジェクトを参照するための
	メソッドを追加し，Synchronize メソッドの引数として渡す必要が
	あります。

	たとえば，UpdateCaption メソッドを以下のように定義し，

		procedure tcommthread.UpdateCaption;
		begin
			Form1.Caption := 'スレッドから書き換えました';
		end;

	Execute メソッドの中で Synchronize メソッドに渡します。

			Synchronize(UpdateCaption);
}

{ tcommthread }

constructor tcommthread.Create(flg:boolean);
begin
	inherited Create(flg);
end;

procedure tcommthread.Execute;
begin
	while not Terminated do
	begin
		//イベント待ち
		if waitcommevent(handle,mask,nil)=true then
//			Synchronize(Trs232c(oya).event_proc);
			Trs232c(oya).event_proc;
	end;
end;

end.

