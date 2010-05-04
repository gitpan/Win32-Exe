#include "perl.h"
#include "XSUB.h"
#include "EXTERN.h"

MODULE = Win32::Exe::InsertResourceSection		PACKAGE = Win32::Exe::InsertResourceSection	

PROTOTYPES: DISABLE

#define  WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <shellapi.h>

void
_insert_resource_section( szFileName, lpData, cbData  )
    LPCSTR szFileName
    LPVOID lpData
    DWORD cbData
  PPCODE:
    int bDeleteExistingResources = 0;
    LPCTSTR lpType = RT_VERSION;
	LPCTSTR lpName = RT_VERSION;
	WORD wLanguage = MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL);
    BOOL ok;
    int fDiscard;
    
  	HANDLE hUpdate = BeginUpdateResource(szFileName, bDeleteExistingResources);
    
	if (hUpdate == NULL) XSRETURN_UNDEF;
    
    ok = UpdateResource(hUpdate, lpType, lpName, wLanguage, lpData, cbData);
    
    fDiscard = ( ok ) ? 0 : 1;
    
    if (!EndUpdateResource(hUpdate, fDiscard)) XSRETURN_UNDEF;
    
	if (!ok) XSRETURN_UNDEF;
    
	XSRETURN_YES;
