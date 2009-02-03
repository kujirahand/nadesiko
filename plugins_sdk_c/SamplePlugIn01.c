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
// コールバックして呼ばれるユーザー関数
PHiValue __stdcall sample01(DWORD h) {
	PHiValue arg1;
	PHiValue result;
	char* caption;
	// 引数の取得
	arg1 = nako_getFuncArg(h, 0);
	// 戻り値の生成
	result = nako_var_new(NULL);
	// 処理(ここでは、引数をそのまま戻り値としてコピー)
	nako_varCopyData(arg1, result);
	// 引数を char* 型にキャスト
	caption = hi_str(arg1);
	MessageBox(0, caption, "sample01.c", MB_OK);
	return result;
}

//---------------------------------------------------------------------------
// プラグインに必要な関数

NAKO_API(void) ImportNakoFunction(void) {
	// ユーザー命令の追加
	nako_addFunction("サンプル1実行","STRで", sample01, 0);
}

NAKO_API(int) PluginInfo(char* str, int len) {
	const char* tmp = "サンプルプラグイン";
	if (str == NULL) {
		return strlen(tmp);
	}
	strcpy(str, tmp);
	return strlen(tmp);
}

NAKO_API(DWORD) PluginVersion(void) {
	return 2; // プラグインのバージョン
}

NAKO_API(DWORD) PluginRequire() {
	return 2; // 必ず２を返すこと
}

NAKO_API(void) PluginInit(DWORD hDll) {
	// プラグインの初期化
	dnako_import_initFunctions(hDll);
}

NAKO_API(void) PluginFin(void) {
}

//---------------------------------------------------------------------------
