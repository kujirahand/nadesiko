
/*
  Copyright 1998-2005 FileMaker, Inc.  All Rights Reserved.
  
*/



#if !defined(FMPLUGINFUNCTIONS_H)
	#define FMPLUGINFUNCTIONS_H


#if defined(FMX_WIN_TARGET)
	#include "Windows.h"
#endif


#include "FMWrapper/FMXExtern.h"
#include "FMWrapper/FMXTypes.h"
#include "FMWrapper/FMXText.h"


#include "FMPluginGlobalDefines.h"


// General String IDs

	// The following string cannot be localized.
	enum { kXMpl_OptionsStringID = 1 };



// Function IDs
	enum
	{ 
		/*
		kXMpl_Add, 
		kXMpl_Append, 
		kXMpl_Evaluate, 
		kXMpl_StartScript, 
		kXMpl_UserFormatNumber, 
		kXMpl_FormatNumber, 
		kXMpl_NumToWords,
		kXMpl_Version,
		*/
		f_nako_getVersion,
		f_nako_eval,
		f_nako_reset,
		f_nako_exec
	};



	// The following functions are registered with FileMaker as the external functions made available via the plug-in.
		FMX_PROC(fmx::errcode) Do_XMpl_Add(short funcId, const fmx::ExprEnv& environment, const fmx::DataVect& dataVect, fmx::Data& results);
		FMX_PROC(fmx::errcode) Do_XMpl_Append(short funcId, const fmx::ExprEnv& environment, const fmx::DataVect& dataVect, fmx::Data& results);
		FMX_PROC(fmx::errcode) Do_XMpl_Evaluate(short funcId, const fmx::ExprEnv& environment, const fmx::DataVect& dataVect, fmx::Data& results);
		FMX_PROC(fmx::errcode) Do_XMpl_StartScript(short funcId, const fmx::ExprEnv& environment, const fmx::DataVect& dataVect, fmx::Data& results);
		FMX_PROC(fmx::errcode) Do_XMpl_CommonFormatNumber(short funcId, const fmx::ExprEnv& environment, const fmx::DataVect& dataVect, fmx::Data& results);
		FMX_PROC(fmx::errcode) Do_XMpl_NumToWords(short funcId, const fmx::ExprEnv& environment, const fmx::DataVect& dataVect, fmx::Data& results);
		FMX_PROC(fmx::errcode) Do_XMpl_Version(short funcId, const fmx::ExprEnv& environment, const fmx::DataVect& dataVect, fmx::Data& results);
		// todo: User Function
		FMX_PROC(fmx::errcode) Do_nako_getVersion(short /* funcId */, const fmx::ExprEnv& /* environment */, const fmx::DataVect&  dataVect, fmx::Data& results);
		FMX_PROC(fmx::errcode) Do_nako_eval(short /* funcId */, const fmx::ExprEnv& /* environment */, const fmx::DataVect&  dataVect, fmx::Data& results);
		FMX_PROC(fmx::errcode) Do_nako_exec(short /* funcId */, const fmx::ExprEnv& /* environment */, const fmx::DataVect&  dataVect, fmx::Data& results);
		FMX_PROC(fmx::errcode) Do_nako_reset(short /* funcId */, const fmx::ExprEnv& /* environment */, const fmx::DataVect&  dataVect, fmx::Data& results);

		//--- load and unload
		BOOL _dnako_load();
		extern char dnako_path[MAX_PATH];


	// Used by Do_XMpl_CommonFormatNumber, based on funcId.
		FMX_PROC(fmx::errcode) Do_XMpl_UserFormatNumber(short funcId, const fmx::ExprEnv& environment, const fmx::DataVect& dataVect, fmx::Data& results);
		FMX_PROC(fmx::errcode) Do_XMpl_FormatNumber(short funcId, const fmx::ExprEnv& environment, const fmx::DataVect& dataVect, fmx::Data& results);



	// Used by Do_PluginInit, FMExternCallProc, and the example functions listed above.
		void Do_GetString(unsigned long whichString, FMX_ULong winLangID, FMX_Long resultsize, FMX_Unichar* string);
		void Do_GetString(unsigned long whichString,  fmx::TextAutoPtr& intoHere, bool stripFunctionParams = false);


	// Used by Do_XMpl_UserFormatNumber and Do_XMpl_FormatNumber.
		fmx::errcode FormatNumberWithMask(const fmx::TextAutoPtr& formatThis, const fmx::TextAutoPtr& withThis, fmx::TextAutoPtr& intoThis);

	// Used by FormatNumberWithMask and Do_XMpl_NumToWords.
		void Sub_GetFilteredChars(const fmx::TextAutoPtr& filterThis, fmx::ushort* filteredIntoHere, unsigned long& filteredIntoHereMaxSize, bool saveDecimal=false);

	// Used by Do_XMpl_NumToWords.
		bool Sub_GetWordFromNum(bool firstPos, int mag, 
						unsigned short firstch, unsigned short secondch, 
						fmx::TextAutoPtr& returnText, 
						bool& skipch, 
						bool& displayMillions, bool& displayThousands, bool& pluralcents);

	// Used by Do_GetString.
		#if defined(FMX_MAC_TARGET)
			unsigned long  Sub_OSXLoadString(unsigned long stringID, FMX_Unichar* intoHere, long intoHereMax);
		#endif

#endif // FMPLUGINFUNCTIONS_H
