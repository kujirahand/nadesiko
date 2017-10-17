{ RS-232Cコンポーネントの為のプロパティエディタ

	(C)Copyright 2002-2003 千々岩幸治
}

unit rs232ced;

interface

uses
	Windows,Classes,SysUtils,Registry,DsgnIntf;

type
	//文字長用
	TcharbitProperty=class(TIntegerProperty)
	public
		function GetAttributes:TPropertyAttributes; Override;
		procedure GetValues(Proc:TGetStrProc); Override;
	end;

	//ストップビット用
	TStopBitProperty=class(TStringProperty)
	public
		function GetAttributes:TPropertyAttributes; Override;
		procedure GetValues(Proc:TGetStrProc); Override;
	end;

	//ボーレート用
	TbpsProperty=class(TIntegerProperty)
	public
		function GetAttributes:TPropertyAttributes; Override;
		procedure GetValues(Proc:TGetStrProc); Override;
	end;

	//ポート名用
	TportnameProperty=class(TStringProperty)
	public
		function GetAttributes:TPropertyAttributes; Override;
		procedure GetValues(Proc:TGetStrProc); Override;
	end;

	//パリティ用
	TParitymodeProperty=class(TStringProperty)
	public
		function GetAttributes:TPropertyAttributes; Override;
		procedure GetValues(Proc:TGetStrProc); Override;
	end;

procedure Register;

implementation

uses
	rs232c;

procedure Register;
begin
	RegisterPropertyEditor(
		TypeInfo(integer),Trs232c,'charbit',TcharbitProperty);

	RegisterPropertyEditor(
		TypeInfo(string),Trs232c,'stopbit',TStopBitProperty);

	RegisterPropertyEditor(
		TypeInfo(Integer),Trs232c,'bps',TbpsProperty);

	RegisterPropertyEditor(
		TypeInfo(string),Trs232c,'portname',TportnameProperty);

	RegisterPropertyEditor(
		TypeInfo(string),Trs232c,'paritymode',TParitymodeProperty);
end;

//文字長用
function TcharbitProperty.GetAttributes:TPropertyAttributes;
begin
	result:=[paMultiSelect,paValueList];
end;

procedure TcharbitProperty.GetValues(Proc:TGetStrProc);
begin
	proc('5');
	proc('6');
	proc('7');
	proc('8');
end;

//ストップビット用
function TStopBitProperty.GetAttributes:TPropertyAttributes;
begin
	result:=[paMultiSelect,paValueList];
end;

procedure TStopBitProperty.GetValues(Proc:TGetStrProc);
begin
	proc('1');
	proc('1.5');
	proc('2');
end;

//ボーレート
function TbpsProperty.GetAttributes:TPropertyAttributes;
begin
	Result:=[paMultiSelect,paValueList];
end;

procedure TBpsProperty.GetValues(Proc:TGetStrProc);
begin
	Proc('128000');
	Proc('56000');
	Proc('38400');
	Proc('31250');	//MIDI用に特別追加
	Proc('19200');
	Proc('14400');
	Proc('9600');
	Proc('7200');
	Proc('4800');
	Proc('2400');
	Proc('1800');
	Proc('1200');
	Proc('600');
	Proc('300');
	Proc('150');
	Proc('134'); //本当は134.5
	Proc('110');
	Proc('75');
end;

//ポート名用
function TportnameProperty.GetAttributes:TPropertyAttributes;
begin
	result:=[paMultiSelect,paValueList];
end;

procedure TportnameProperty.GetValues(Proc:TGetStrProc);
var
	reg:TRegistry;
	port:string;
	counter:integer;
begin
	//通信ポート一覧をレジストリから取得する
	reg:=TRegistry.Create;
	try
		reg.RootKey:=HKEY_LOCAL_MACHINE;
		if reg.OpenKey('\HARDWARE\DEVICEMAP\SERIALCOMM\',false) then
		begin
			for counter:=0 to 50 do
			begin
				port:=reg.ReadString('\Device\Serial'+inttostr(counter));
				if port<>'' then
					proc(port);
			end
		end
		else
		begin
			proc('COM1');
			proc('COM2');
		end;
	finally
		reg.CloseKey;
		reg.Free;
	end;
end;

//パリティ用
function TParitymodeProperty.GetAttributes:TPropertyAttributes;
begin
	Result:=[paMultiSelect,paValueList];
end;

procedure TParitymodeProperty.GetValues(Proc:TGetStrProc);
begin
	Proc('無し');
	Proc('EVEN');
	Proc('ODD');
	Proc('MARK');
	Proc('SPACE');
end;


end.



