
#ifndef __dnako_import_h
#define __dnako_import_h

#include "dnako_import_types.h"

#ifdef DNAKO_DEF
#	undef DNAKO_DEF
#endif
#define DNAKO_DEF extern

#include "dnako_import_def.h"

extern BOOL dnako_load(char* fname);
extern BOOL dnako_unload(void);
extern BOOL dnako_enabled();

#define nako_OK	1
#define nako_NG	0

#endif /* __dnako_import_h */

