{ RS-232C�R���|�[�l���g Ver2.3�p ��M�X���b�h

	(C)Copyright 1998-2003 ��X��K��
}

unit comthd;

interface

uses
	Classes,windows;

type
	tcommthread = class(TThread)
	private
		{ Private �錾 }
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

{����:
	���C���X���b�h�����L���� VCL �̃��\�b�h/�֐�/�v���p�e�B��
	�����ɂ́A���̃N���X�ɑ��̃I�u�W�F�N�g���Q�Ƃ��邽�߂�
	���\�b�h��ǉ����CSynchronize ���\�b�h�̈����Ƃ��ēn���K�v��
	����܂��B

	���Ƃ��΁CUpdateCaption ���\�b�h���ȉ��̂悤�ɒ�`���C

		procedure tcommthread.UpdateCaption;
		begin
			Form1.Caption := '�X���b�h���珑�������܂���';
		end;

	Execute ���\�b�h�̒��� Synchronize ���\�b�h�ɓn���܂��B

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
		//�C�x���g�҂�
		if waitcommevent(handle,mask,nil)=true then
//			Synchronize(Trs232c(oya).event_proc);
			Trs232c(oya).event_proc;
	end;
end;

end.

