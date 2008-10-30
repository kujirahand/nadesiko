
#include <windows.h>
#include <shlobj.h>
#include "benri.h"

char* file_get_common_appdata_dir(char* szPath, size_t buflen)
{
	return file_get_special_dir(CSIDL_COMMON_APPDATA, szPath, buflen);
}

char* file_get_special_dir(DWORD id, char* szPath, size_t buflen)
{
    LPITEMIDLIST pidl;
    HWND hWnd = NULL;

    IMalloc *pMalloc;
    SHGetMalloc( &pMalloc );

    if( SUCCEEDED(SHGetSpecialFolderLocation(hWnd, id, &pidl)) )
    { 
        SHGetPathFromIDList(pidl,szPath); // ƒpƒX‚É•ÏŠ·‚·‚é
        pMalloc->Free(pidl);              // Žæ“¾‚µ‚½IDL‚ð‰ð•ú‚·‚é (CoTaskMemFree‚Å‚à‰Â)
	} else {
		szPath = NULL;
	}

    pMalloc->Release();
	return szPath;
}

char* file_get_apppath(char* buf, size_t buflen)
{
	char* p_cmd = GetCommandLine();
	MessageBox(0, p_cmd, "test", MB_OK);
	strcpy_s(buf, buflen, p_cmd);

	char* p = buf;
	char* p_last = NULL;

	int flag_str = 0;
	while (*p != '\0') {
		if (*p == '"') {
			if (flag_str) {
				p++;
				*p = '\0';
				break;
			} else {
				p++;
				flag_str = 1;
				continue;
			}
		}
		if (flag_str == 0 && *p == ' ') {
			*p = '\0';
			break;
		}
		if (*p == '\\') p_last = p;
		p++;
	}
	// set last path
	if (*p_last == '\\') {
		p_last++;
		*p_last = '\0';
	}
	// copy
	if (*buf == '"') {
		char f[MAX_PATH];
		strcpy_s(f, MAX_PATH, buf+1);
		strcpy_s(buf, buflen, f);
	}
	return buf;
}

