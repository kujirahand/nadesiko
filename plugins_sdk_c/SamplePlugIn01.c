//---------------------------------------------------------------------------
// DLL
#ifndef NAKO_API_EXPORTS
#define NAKO_API_EXPORTS
#endif

#include <windows.h>
#include <string.h>

#include "dnako_import_types.h"
#include "dnako_import.h"


BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fwdreason, LPVOID lpvReserved)
{
	return 1;
}

//---------------------------------------------------------------------------
// �R�[���o�b�N���ČĂ΂�郆�[�U�[�֐�
PHiValue __stdcall sample01(DWORD h) {
	PHiValue arg1;
	PHiValue result;
	char* caption;
	// �����̎擾
	arg1 = nako_getFuncArg(h, 0);
	// �߂�l�̐���
	result = nako_var_new(NULL);
	// ����(�����ł́A���������̂܂ܖ߂�l�Ƃ��ăR�s�[)
	nako_varCopyData(arg1, result);
	// ������ char* �^�ɃL���X�g
	caption = hi_str(arg1);
	MessageBox(0, caption, "sample01.c", MB_OK);
	return result;
}

//---------------------------------------------------------------------------
// �v���O�C���ɕK�v�Ȋ֐�

NAKO_API(void) ImportNakoFunction(void) {
	// ���[�U�[���߂̒ǉ�
	nako_addFunction("�T���v��1���s","STR��", sample01, 0);
}

NAKO_API(int) PluginInfo(char* str, int len) {
	const char* tmp = "�T���v���v���O�C��";
	if (str == NULL) {
		return strlen(tmp);
	}
	strcpy(str, tmp);
	return strlen(tmp);
}

NAKO_API(DWORD) PluginVersion(void) {
	return 2; // �v���O�C���̃o�[�W����
}

NAKO_API(DWORD) PluginRequire() {
	return 2; // �K���Q��Ԃ�����
}

NAKO_API(void) PluginInit(DWORD hDll) {
	// �v���O�C���̏�����
	dnako_import_initFunctions(hDll);
}

NAKO_API(void) PluginFin(void) {
}

//---------------------------------------------------------------------------
