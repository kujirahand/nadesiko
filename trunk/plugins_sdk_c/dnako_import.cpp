/*
dnako.dllをロード/アンロードする関数を定義
*/
#include<windows.h>

#include "dnako_import.h"
#include "dnako_import_types.h"

#ifdef DNAKO_DEF
#	undef DNAKO_DEF
#endif
#define DNAKO_DEF
#include "dnako_import_def.h"


static HINSTANCE hDll = NULL;

BOOL dnako_load(char* fname){
	
	if (hDll) dnako_unload();

	hDll = ::LoadLibrary(fname);
	
	if( ! hDll ){
		return FALSE;
	}

#include "dnako_import_let.h"

	nako_setDNAKO_DLL_handle((DWORD)hDll);
	
	return TRUE;
}

BOOL dnako_unload(void){
	if (hDll == NULL) return TRUE;
	::FreeLibrary( hDll );
	hDll = NULL;
	return TRUE;
}

BOOL dnako_enabled() {
	return (hDll != NULL);
}
