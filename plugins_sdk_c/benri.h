#ifndef __benri_h

char* file_get_apppath(char* buf, size_t buflen);
char* file_get_special_dir(DWORD id, char* szPath, size_t buflen);
char* file_get_common_appdata_dir(char* szPath, size_t buflen);


#endif /* __benri_h */
