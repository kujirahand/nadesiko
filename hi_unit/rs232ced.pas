{ RS-232C�R���|�[�l���g�ׂ̈̃v���p�e�B�G�f�B�^

	(C)Copyright 2002-2003 ��X��K��
}

unit rs232ced;

interface

uses
	Windows,Classes,SysUtils,Registry,DsgnIntf;

type
	//�������p
	TcharbitProperty=class(TIntegerProperty)
	public
		function GetAttributes:TPropertyAttributes; Override;
		procedure GetValues(Proc:TGetStrProc); Override;
	end;

	//�X�g�b�v�r�b�g�p
	TStopBitProperty=class(TStringProperty)
	public
		function GetAttributes:TPropertyAttributes; Override;
		procedure GetValues(Proc:TGetStrProc); Override;
	end;

	//�{�[���[�g�p
	TbpsProperty=class(TIntegerProperty)
	public
		function GetAttributes:TPropertyAttributes; Override;
		procedure GetValues(Proc:TGetStrProc); Override;
	end;

	//�|�[�g���p
	TportnameProperty=class(TStringProperty)
	public
		function GetAttributes:TPropertyAttributes; Override;
		procedure GetValues(Proc:TGetStrProc); Override;
	end;

	//�p���e�B�p
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

//�������p
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

//�X�g�b�v�r�b�g�p
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

//�{�[���[�g
function TbpsProperty.GetAttributes:TPropertyAttributes;
begin
	Result:=[paMultiSelect,paValueList];
end;

procedure TBpsProperty.GetValues(Proc:TGetStrProc);
begin
	Proc('128000');
	Proc('56000');
	Proc('38400');
	Proc('31250');	//MIDI�p�ɓ��ʒǉ�
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
	Proc('134'); //�{����134.5
	Proc('110');
	Proc('75');
end;

//�|�[�g���p
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
	//�ʐM�|�[�g�ꗗ�����W�X�g������擾����
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

//�p���e�B�p
function TParitymodeProperty.GetAttributes:TPropertyAttributes;
begin
	Result:=[paMultiSelect,paValueList];
end;

procedure TParitymodeProperty.GetValues(Proc:TGetStrProc);
begin
	Proc('����');
	Proc('EVEN');
	Proc('ODD');
	Proc('MARK');
	Proc('SPACE');
end;


end.



