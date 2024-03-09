�E�I���W�i���̔z�z���\�\
	http://j-faul.virtualave.net/atl/
	Copyright � 2001,2002 by Jurgen Faul 
	All rights reserved by the author. This library is freeware for all purposes (unlimited distribution). 
	���Ƀ����e�i���X���[�h�ɓ����Ă���悤�ł��B

�E���ώҁ\�\
	sayray (kaon@gmx.net)

�E�ǉ����ꂽ�t�@�C���\�\
	sMediaTag.pas
	sMediaTagReader.pas

�E�ύX�_�\�\
	RTTI�ŃA�N�Z�X�\�Ɂ\�\
		�^�O�R���e�i�N���X���A�N�Z�X�N���X TsMediaTag(TPersistent����p��)����p���B�������̃��\�b�h���I�[�o�[���C�h�B
		���X�̃N���X�̃v���p�e�B�� Published�Ɉړ��B
	�A�v���P�[�V��������Ⴄ�C���^�[�t�F�C�X�̃N���X�𓝈�I�Ɉ������߂̃A�N�Z�X�N���X TsMediaTagReader��ǉ��B
	v1.10�\�\
		�������݂Ɨ񋓂ɑΉ������B
		�Ȃ񂩕ςȏ��Ƃ��𒼂����B
		�p���ł���悤�� virtual�ɂ��܂������B
		������Ƃ����T���v���v���W�F�N�g��ǉ������B

�E�g�����\�\
{
	AACfile.pas
	APEtag.pas
	CDAtrack.pas
	FLACfile.pas
	ID3v1.pas
	ID3v2.pas
	Monkey.pas
	MPEGaudio.pas
	MPEGplus.pas
	OggVorbis.pas
	sMediaTag.pas
	sMediaTagReader.pas
	TwinVQ.pas
	WAVfile.pas
	WMAfile.pas
	�ȏ�̃t�@�C�����p�X�̒ʂ����ꏊ�ɂ����Ԃ�
}
uses
	sMediaTagReader;
var
	tag: TsMediaTagReader;
begin
	tag := TsMediaTagReader.Create();
	tag.ReadFromFile('test.mp3');
	ShowMessgageFmt('%s - %s - %s', [tag.Properties['Title'], tag.Properties['Artist'], tag.Properties['Album']]);
	tag.Free();
end;

{ �T���v���̃v���W�F�N�g(Projct1.dpr)������̂ł��ꂪ�Q�l�ɂȂ�Ǝv���܂��B }

�E�N���X���\�\
	TsMediaTagReader
		constructor Create(); virtual;
			�R���X�g���N�^
		destructor Destroy(); OverRide;
			�f�X�g���N�^
		function LoadFromFile(const FileName: string): Boolean; virtual;
			�t�@�C������ǂݍ��݁B������True�B
		function RemoveFromFile(const FileName: string): Boolean; virtual;
			�t�@�C������^�O�������B������True�B
		function SaveToFile(const FileName: String): Boolean; virtual;
			�t�@�C���Ƀ^�O��ۑ��B
		function EnumProperties(): TStringList; virtual;
			�ǂݍ��݉\�ȃ^�O���̗񋓁B
			�����ł͒P��Published�ȃv���p�e�B�̗񋓂����Ă��邾���Ȃ̂ŗ]�v�Ȃ��̂��Ԃ��Ă���B
			�Ō��Free()���邱�ƁB
		function GetProperty(Index: String): String; virtual;
			ReadFromFile�Ńt�@�C���t�H�[�}�b�g�ɉ�����ATL�̃^�O�R���e�i�N���X������ɐ������AIndex�ɉ��������ڂ𕶎���ŕԂ��B
			Index��'Title', 'Album', 'Artist', 'SampleRate', 'Year', 'Comment'�Ȃǂ��l������B
			�t�H�[�}�b�g�ɂ���ē������Ă����񂪈Ⴄ�̂Œ��ӁB.wav�t�@�C������Album��ǂݍ��ނ��Ƃ͂ł��Ȃ��B
			���s�͔��ʂł��Ȃ��B
		procedure SetProperty(Index: String; Value: String); virtual;
			�^�O�����������ށBSaveToFile���Ȃ��Ɣ��f����Ȃ��B
			���s���Ă�����Ȃ��B
		property Properties[Index: String]: String read GetProperty write SetProperty; default;
			GetProperty�̃v���p�e�B�ŁB

�E�Ō�Ɂ\�\
	�f�U�C���p�^�[���̗p��悭�m��Ȃ��́B
	���ǂ��ꂽ����������K���ɔz�z���Ă��������B
	fnmatch��Masks�ł�������������̂����B

