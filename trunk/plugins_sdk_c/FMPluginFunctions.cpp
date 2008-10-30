
/*
  Copyright 1998-2006 FileMaker, Inc.  All Rights Reserved.
  
*/



#include "FMPluginGlobalDefines.h"

#if defined(FMX_WIN_TARGET)
	#include "Windows.h"
	#include "dnako_import_types.h"
	#include "dnako_import.h"
	#include "benri.h"
	#include <locale.h>
#endif

#if defined(FMX_MAC_TARGET)
	#include <CoreServices/CoreServices.h>
	#include <Carbon/Carbon.h>
#endif 


#include "FMWrapper/FMXExtern.h"
#include "FMWrapper/FMXTypes.h"
#include "FMWrapper/FMXFixPt.h"
#include "FMWrapper/FMXText.h"
#include "FMWrapper/FMXData.h"
#include "FMWrapper/FMXCalcEngine.h"

#include "FMPluginFunctions.h"
#include "FMPluginPrefs.h"

#include "resource.h"

using namespace fmx;

FMX_PROC(fmx::errcode) Do_XMpl_Version(short /* funcId */, const fmx::ExprEnv& /* environment */, const fmx::DataVect& /* dataVect */, fmx::Data& results)
{
	fmx::errcode errorResult = 0;
	
	fmx::FixPtAutoPtr	num;
	num->AssignInt( 90 );

	results.SetAsNumber(*num);

return(errorResult);
} // Do_XMpl_Version



FMX_PROC(fmx::errcode) Do_XMpl_Add(short /* funcId */, const fmx::ExprEnv& /* environment */, const fmx::DataVect& dataVect, fmx::Data& results)
{
	fmx::errcode errorResult = 0;

	// Add the first two parameters together.
		fmx::FixPtAutoPtr	num;
		num->AssignFixPt( dataVect.AtAsNumber(0) );

		num->Add( dataVect.AtAsNumber(1), *num );

		results.SetAsNumber(*num);

return(errorResult);
} // Do_XMpl_Add



FMX_PROC(fmx::errcode) Do_XMpl_Append(short /* funcId */, const fmx::ExprEnv& /* environment */, const fmx::DataVect& dataVect, fmx::Data& results)
{
	fmx::errcode errorResult = 0;
	
	// if (funcId != kXMpl_Append) // Then somehow this function was called incorrectly. This is not likely
	//		to happen unless the plugin registers a different number of functions depending on some condition.

	// Append an arbitrary number of strings together.
		fmx::TextAutoPtr	resultTxt;
		fmx::ulong nParams = dataVect.Size();
		fmx::ulong j;

		if (nParams > 0)
		{
			for ( j = 0; j < nParams; j++ )
			{
				resultTxt->AppendText( dataVect.AtAsText(j), 0, static_cast<fmx::ulong>(-1) );
			}

			results.SetAsText( *resultTxt, dataVect.At(0).GetLocale() );
		}
		else
		{
			errorResult = -1;	// This is just an example of returning an error.

		}// nParams > 0


return(errorResult);
} // Do_XMpl_Append



FMX_PROC(fmx::errcode) Do_XMpl_Evaluate(short /* funcId */, const fmx::ExprEnv& environment, const fmx::DataVect& dataVect, fmx::Data& results)
{
	fmx::errcode errorResult = 0;

	// environment.Evaluate() is identical to the Evaluate function built into FileMaker.
	errorResult = environment.Evaluate( dataVect.AtAsText(0), results );


return(errorResult);
} // Do_XMpl_Evaluate



FMX_PROC(fmx::errcode) Do_XMpl_StartScript(short /* funcId */, const fmx::ExprEnv& /* environment */, const fmx::DataVect& dataVect, fmx::Data& /* results */)
{
	fmx::errcode errorResult = 0;
	
	fmx::ulong nParams = dataVect.Size();

	if (nParams > 1)
	{
		// This function will trigger the execution of a script in FileMaker Pro.
		errorResult = FMX_StartScript( &(dataVect.AtAsText(0)), &(dataVect.AtAsText(1)), kFMXT_Pause, NULL );
	}
	else
	{
		errorResult = -1;	// This is just an example of returning an error

	}// nParams > 1


return(errorResult);
} // Do_XMpl_StartScript



FMX_PROC(fmx::errcode) Do_XMpl_CommonFormatNumber(short funcId, const fmx::ExprEnv& environment, const fmx::DataVect& dataVect, fmx::Data& results)
{
	fmx::errcode errorResult = -1;
	
	/*
	switch(funcId)
	{
		case kXMpl_UserFormatNumber :
			{
				errorResult = Do_XMpl_UserFormatNumber(funcId, environment, dataVect, results);
			}
			break;

		case kXMpl_FormatNumber :
			{
				errorResult = Do_XMpl_FormatNumber(funcId, environment, dataVect, results);
			}
			break;
			
	}// switch funcId
	*/
	
	
return(errorResult);
} // Do_XMpl_CommonFormatNumber



FMX_PROC(fmx::errcode) Do_XMpl_UserFormatNumber(short /* funcId */, const fmx::ExprEnv& /* environment */, const fmx::DataVect& dataVect, fmx::Data& results)
{
	fmx::errcode		errorResult = -1;
	fmx::ulong			numParams = dataVect.Size();
	
	if(numParams == 1) // This function should have been given only one parameter.
	{
		fmx::TextAutoPtr	enteredTxt;
		enteredTxt->SetText( dataVect.AtAsText(0), 0, dataVect.AtAsText(0).GetSize() );

		fmx::TextAutoPtr	formattedResultTxt;

		errorResult = FormatNumberWithMask(enteredTxt, gFMPluginExamplePrefs.formattingStringTxt, formattedResultTxt);
		results.SetAsText( *formattedResultTxt, dataVect.At(0).GetLocale() ); 

	}// numParams == 1


return(errorResult);
} // Do_XMpl_UserFormatNumber



FMX_PROC(fmx::errcode) Do_XMpl_FormatNumber(short /* funcId */, const fmx::ExprEnv& /* environment */, const fmx::DataVect& dataVect, fmx::Data& results)
{
	fmx::errcode		errorResult = -1;
	fmx::ulong			numParams = dataVect.Size();
	
	if(numParams == 2) // This function needs at least two parameters. 
	{
		fmx::TextAutoPtr	formattingStringTxt;
		formattingStringTxt->SetText( dataVect.AtAsText(0), 0, dataVect.AtAsText(0).GetSize() );

		fmx::TextAutoPtr	enteredTxt;
		enteredTxt->SetText( dataVect.AtAsText(1), 0, dataVect.AtAsText(1).GetSize() );

		fmx::TextAutoPtr	formattedResultTxt;

		errorResult = FormatNumberWithMask(enteredTxt, formattingStringTxt, formattedResultTxt);
		results.SetAsText( *formattedResultTxt, dataVect.At(0).GetLocale() );

	}// numParams == 2


return(errorResult);
} // Do_XMpl_FormatNumber



fmx::errcode FormatNumberWithMask(const fmx::TextAutoPtr& formatThis, const fmx::TextAutoPtr& withThis, fmx::TextAutoPtr& intoThis)
{
	fmx::ulong		enteredTxtSize = formatThis->GetSize();
	fmx::ulong		formatterStringTxtSize = withThis->GetSize();


	// By default, this function will return "-01", which means an error occurred, and will also
	// return an error code.
	
	//	However, note that if you return an error back to the application, the result
	//	of your function will be "unknown" (i.e. "?"), no matter what the external 
	//	function passes back as data.  It is up to you to decide if you want your
	//	functions to pass back an error code and have the result be "?", or pass
	//	your error code back as data, but return no error so that the data will 
	//	be used as the result of the function.
	fmx::errcode	errorResult = -1;
	{
		fmx::ushort	tempErrChars[4];
		tempErrChars[0] = 0x002D; // '-'
		tempErrChars[1] = 0x0030; // '0'
		tempErrChars[2] = 0x0031; // '1'

		intoThis->AssignUnicodeWithLength(tempErrChars, 3);
	}


	// If the plug-in has something to parse, and it isn't too large, apply the formatter string
	//		to the text that was provided, padding any extra #s in the formatter string with zeros.
	if( (enteredTxtSize > 0) && (formatterStringTxtSize > 0) && 
		(enteredTxtSize < kXMpl_FilterMaxBufferSize) && (formatterStringTxtSize < kXMpl_FilterMaxBufferSize) )
	{
		//  Now filter input from the user and loop through the parameter, copying only 0-9 into filteredTxt.
		fmx::ulong		filteredTxtSize = kXMpl_FilterMaxBufferSize;
		fmx::ushort		filteredTxt[kXMpl_FilterMaxBufferSize];
		Sub_GetFilteredChars(formatThis, filteredTxt, filteredTxtSize);

		if(filteredTxtSize > 0)
		{
			fmx::ushort		formatterStringTxt[kXMpl_FilterMaxBufferSize];
			withThis->GetUnicode(formatterStringTxt, 0, formatterStringTxtSize);

			fmx::ushort		tempUnichar = 0;
			unsigned long	onChar = 0;
			unsigned long	numOfnumerics = 0;

			// If the input had numbers in it, and if the input (numbers only) was 
			//		less than or equal to the formatter string, we can process the input. 
			if(filteredTxtSize <= formatterStringTxtSize)
			{
				// Count the number of #s.
				for (onChar=0; (onChar < formatterStringTxtSize); onChar++) 
				{
					tempUnichar = formatterStringTxt[onChar];
					if (tempUnichar == 0x0023)	//  0x0023  = '#'
					{
						numOfnumerics++;
					}

				} // for onChar <= formatterStringTxtSize

				
				if( (numOfnumerics > 0) && (filteredTxtSize <= numOfnumerics) )
				{
					// The output is always the same as the formatting string.
					fmx::ushort		formattedTxt[kXMpl_FilterMaxBufferSize];

					// Loop backwards, replacing the #s of the formatter string with the numbers of the user provided string.
					unsigned long		filteredTxtCharsLeft = filteredTxtSize;
					for(onChar=formatterStringTxtSize; (onChar > 0); onChar--) 
					{
						tempUnichar = formatterStringTxt[onChar-1];
						if (tempUnichar == 0x0023)	//  0x0023  = '#'
						{
							if(filteredTxtCharsLeft > 0)
							{								
								formattedTxt[onChar-1] = filteredTxt[ filteredTxtCharsLeft-1 ];
								filteredTxtCharsLeft--;
							}
							else
							{
								// If there are #s left in the formatter string, but no numbers left in the filtered text, then use zeros.
								formattedTxt[onChar-1] = 0x0030; 

							}// filteredTxtCharsLeft
						}
						else
						{
							// Copy over from formatterStringTxt directly into formattedTxt.
							formattedTxt[onChar-1] = tempUnichar;

						}// tempUnichar == 0x0023 

					}// onChar < formatterStringTxtSize

					intoThis->AssignUnicodeWithLength(formattedTxt, formatterStringTxtSize);
					errorResult = 0; // User input has been formatted successfully.

				}// numOfnumerics && filteredTxtSize <= numOfnumerics

			}// filteredTxtSize <= formatterStringTxtSize

		}// filteredTxtSize

	}// TxtSize > 0
	

return(errorResult);
} // FormatNumberWithMask



FMX_PROC(fmx::errcode) Do_XMpl_NumToWords(short /* funcId */, const fmx::ExprEnv& /* environment */, const fmx::DataVect& dataVect, fmx::Data& results)
{
	fmx::errcode		errorResult = -1;
	fmx::ulong			numParams = dataVect.Size();
	fmx::TextAutoPtr	tempResult;

	if(numParams == 1) // The plug-in should have been given only one parameter.
	{
		fmx::TextAutoPtr	enteredTxt;
		unsigned long		enteredTxtSize = dataVect.AtAsText(0).GetSize();
		enteredTxt->SetText( dataVect.AtAsText(0), 0, enteredTxtSize);


		// By default, this function will return "-01", which means an error occurred and will also
		// return an error code. (See also FormatNumberWithMask.)
		{
			fmx::ushort	tempErrChars[4];
			tempErrChars[0] = 0x002D; // '-'
			tempErrChars[1] = 0x0030; // '0'
			tempErrChars[2] = 0x0031; // '1'

			tempResult->AssignUnicodeWithLength(tempErrChars, 3);
		}


		//First "compact" the number by removing all non-numbers. Locate the decimal 
		//	separator (stored in gFMPluginExamplePrefs.decimalPoint) to use as a point of reference and cut off anything
		//	beyond two digits to the right of the decimal point.
		fmx::ulong		filteredTxtSize = kXMpl_FilterMaxBufferSize-4; // Leave room for trailing ".00" if needed.
		fmx::ushort		filteredTxt[kXMpl_FilterMaxBufferSize];
		Sub_GetFilteredChars(enteredTxt, filteredTxt, filteredTxtSize, true); 

		if(filteredTxtSize > 0)
		{
			unsigned long		decAt = 0;
			unsigned long		onChar;


			// Locate the decimal point, if any.  Remove any extra decimal points, and anything beyond two digits to the right of the decimal point.
			bool		foundADecimal = false;
			for(onChar = 0; (onChar<filteredTxtSize) && (!foundADecimal); onChar++)
			{
				if(filteredTxt[onChar] == gFMPluginExamplePrefs.decimalPoint)
				{
					foundADecimal = true;
					decAt = onChar;

				}// gFMPluginExamplePrefs.decimalPoint

			}// onChar<filteredTxtSize

			if(foundADecimal)
			{
				unsigned long	charsRightOfDecimal = filteredTxtSize-decAt-1;
				switch(charsRightOfDecimal)
				{
					case 0:
					{
						filteredTxt[filteredTxtSize] = 0x0030;
						filteredTxt[filteredTxtSize+1] = 0x0030;
						filteredTxtSize += 2;
					}
					break;

					case 1:
					{
						filteredTxt[filteredTxtSize] = 0x0030;
						filteredTxtSize++;
					}
					break;

					default: // There were two or more, adjust length appropriately.
					{
						filteredTxtSize = filteredTxtSize - (charsRightOfDecimal-2);
					}

				}// switch charsRightOfDecimal
			}
			else
			{
				// There was no decimal, so add one with trailing zeros.
				filteredTxt[filteredTxtSize] = gFMPluginExamplePrefs.decimalPoint;
				filteredTxt[filteredTxtSize+1] = 0x0030;
				filteredTxt[filteredTxtSize+2] = 0x0030;

				decAt = filteredTxtSize;

				filteredTxtSize += 3;

			}// foundADecimal



		// At this point, filteredTxt should contain a number from ".00" to "999999999999.99", but with no more than 12 digits to the left of the decimal point.
			if(decAt < 13)
			{			
				int				magnitudePos;
				unsigned short	nextUnichar;
				bool			skipPlace;
				bool			millionsFlag=false;
				bool			thousandsFlag=false;
				bool			pluralCentsFlag=false;


				// At this point, the plug-in will return a result, so clear out the "-01"
				//		because the following code only appends text into tempResult.
				tempResult->DeleteText(0, 3);
				errorResult = 0;

				// The following code processes each character in filteredTxt, translating it into words.
				for (onChar=0; onChar < filteredTxtSize; onChar++)
				{
					skipPlace = false;   // Used for teens, when the character is 1 (i.e. 14 = fourteen).
					magnitudePos = (int)(decAt - onChar);  // Used for the significance of the decimal place.
					
					if ( (onChar+1) < filteredTxtSize ) 
					{
						nextUnichar = filteredTxt[onChar+1];
					}
					else
					{
						nextUnichar = 0;
					}

					// The remaining logic is contained in the function below:
					
					// magnitudePos will determine hundreds, thousands, etc.
					// filteredTxt[onChar] will determine three, four, etc.
					//		Whenthe number is one, nextUnichar will determine (4)fourteen, (5)fifteen, etc.
					// skipPlace will be false, unless both onThisNumChar and onNextNumChar are used.
					Sub_GetWordFromNum(onChar==0, magnitudePos, filteredTxt[onChar], nextUnichar, tempResult, skipPlace, millionsFlag, thousandsFlag, pluralCentsFlag);
					if (skipPlace)
					{
						onChar++;
					}								
					
				} // for onChar < filteredTxtSize

			}// decAt < 13


		}// filteredTxtSize
	

	}// numParams


	if(errorResult == 0)
	{
		results.SetAsText( *tempResult, dataVect.At(0).GetLocale() );
	}

return(errorResult);
} // Do_XMpl_NumToWords



bool Sub_GetWordFromNum(bool firstPos, int mag, 
						unsigned short firstch, unsigned short secondch, 
						fmx::TextAutoPtr& returnText, 
						bool& skipch, 
						bool& displayMillions, bool& displayThousands, bool& pluralcents)
{
	int					tempMag(mag);	// This function needs to change magnitude during processing.
	bool				tempReturn = false;
	fmx::TextAutoPtr	wordsToAdd;
	unsigned long		wordsToAddSize;
	unsigned long		wordsToAddID = 0;


// First, take care of displayMillions, displayThousands and pluralcents flags.
	if( (!displayMillions) && (firstch > 0x0030) )
	{
		displayMillions = ((tempMag >= 7) && (tempMag <= 9));

	}// displayMillions

	if( (!displayThousands) && (firstch > 0x0030) )
	{
		displayThousands = ((tempMag >= 4) && (tempMag <= 6));

	}// displayThousands

	if( (!pluralcents) && (firstch > 0x0030) )
	{
		// .23 -> Cents
		// .10 -> Cents
		// .02 -> Cents
		// .01 -> Cent
		pluralcents = (  ((tempMag == -2) && (firstch > 0x0031))  || (tempMag == -1) );

	}// pluralcents

	
// Determine hundreds, tens and teens, or ones.
	switch (tempMag) 
	{
		// Hundreds
		case 12 :  
		case  9 :
		case  6 :
		case  3 :
		{
			if((firstch >= 0x0031) && (firstch <= 0x0039)) // '1'..'9'
			{
				// Map firstch to kFMEX_NTW_1Hundred..kFMEX_NTW_9Hundred
				wordsToAddID = (unsigned long)(kFMEX_NTW_BaseHundred + ( (firstch-0x0031) * 100 ));

			}// firstch  '1'..'9'

			if(wordsToAddID != 0)
			{
				Do_GetString(wordsToAddID,  wordsToAdd);
				wordsToAddSize = wordsToAdd->GetSize();
				if(wordsToAddSize > 0)
				{
					returnText->AppendText(*wordsToAdd, 0, wordsToAddSize);
					tempReturn = true;

				}// wordsToAddSize

			}// wordsToAddID
		}
		break;// Hundreds


		// Tens / Teens
		case 11 :  
		case  8 :
		case  5 :
		case  2 :
		case -1 :
		{
			if((firstch >= 0x0032) && (firstch <= 0x0039)) // '2'..'9'
			{
				// Map firstch to kFMEX_NTW_Twenty..kFMEX_NTW_Ninty.
				wordsToAddID = (unsigned long)(kFMEX_NTW_BaseTens + ( (firstch-0x0032) * 10 ));
			}
			else
			{
				// This is the teens, so include the secondch and skip it in the next loop.
				if(firstch == 0x0031) // '1'
				{
					if((secondch >= 0x0030) && (secondch <= 0x0039)) // '0'..'9'
					{
						// Map firstch to kFMEX_NTW_Ten..kFMEX_NTW_Nineteen.
						wordsToAddID = (unsigned long)(kFMEX_NTW_BaseTeens + (secondch-0x0030));
						skipch = true;
						tempMag--;

					}// secondch		

				}// firstch == '1'

			}// firstch  '2'..'9'

			if((tempMag == -1) && (firstch > 0x0030))
			{
				pluralcents = true;
			}

			if(wordsToAddID != 0)
			{
				Do_GetString(wordsToAddID,  wordsToAdd);
				wordsToAddSize = wordsToAdd->GetSize();
				if(wordsToAddSize > 0)
				{
					tempReturn = true;
					returnText->AppendText(*wordsToAdd, 0, wordsToAddSize);
					if((secondch > 0x0030) && (!skipch))// Second digit means more is on the way ("Ninety" vs "Ninety-Five").
					{
						Do_GetString(kFMEX_NTW_Hyphen,  wordsToAdd);
						wordsToAddSize = wordsToAdd->GetSize();
						if(wordsToAddSize > 0)
						{
							// Remove the previous trailing space.
							unsigned long	returnTextCurSize = returnText->GetSize();
							if(returnTextCurSize > 0)
							{
								returnText->DeleteText( returnTextCurSize-1, 1);
							}
		
							// Add the hyphen.
							returnText->AppendText(*wordsToAdd, 0, wordsToAddSize);

						}// wordsToAddSize

					}// returnText[tempLen] = '-';

				}// wordsToAddSize

			}// wordsToAddID
		}
		break;// Tens / Teens


		// Ones
		case 10 :  
		case  7 :
		case  4 :
		case  1 :
		case -2 :
		{
			if((firstch >= 0x0031) && (firstch <= 0x0039)) // '1'..'9'
			{
				// Map firstch to kFMEX_NTW_One..kFMEX_NTW_Nine
				wordsToAddID = (unsigned long)(kFMEX_NTW_BaseOnes + (firstch-0x0031));

			}// firstch  '1'..'9'

			if( (tempMag == -2) && (firstch == 0x0030) && (!pluralcents) )
			{
				// ".00" -> No Cents
				wordsToAddID = kFMEX_NTW_NoCents;

			}// No Cents

			if(wordsToAddID != 0)
			{
				Do_GetString(wordsToAddID,  wordsToAdd);
				wordsToAddSize = wordsToAdd->GetSize();
				if(wordsToAddSize > 0)
				{
					returnText->AppendText(*wordsToAdd, 0, wordsToAddSize);
					tempReturn = true;

				}// wordsToAddSize

			}// wordsToAddID
		}
		break;// Hundreds

		case 0 :
		{
			// This is the decimal place, so don't do any processing here.
			tempReturn = true;
		}
		break;

	}// switch tempMag  Determine hundreds, tens and teens, or ones.



// Billions, Millions, Thousands, Dollars, And, Cents	

	// Always display even if 0 encountered in ones, thousands, millions or billions place.
	if(!tempReturn)
	{
		if(tempMag == 1)
		{
			tempReturn = true;
		}

		if((tempMag == 4) && displayThousands )
		{
			tempReturn = true;
		}
		
		if((tempMag == 7) && displayMillions )
		{
			tempReturn = true;
		}
		
		if(tempMag == 10)
		{
			tempReturn = true;
		}
		
	}// !tempReturn

	if(tempReturn)
	{
		wordsToAddID = 0;

		switch (tempMag) 
		{
			case 10 :
			{
				wordsToAddID = kFMEX_NTW_Billion;
			}
			break;

			case 7 :
			{
				if(displayMillions)// In cases like 8000000000, we don't want to display "million".
					wordsToAddID = kFMEX_NTW_Million;
			}
			break;

			case 4 :
			{
				if(displayThousands)// In cases like 8000000, we don't want to display "thousand".
					wordsToAddID = kFMEX_NTW_Thousand;
			}
			break;

			case 1 :
			{
				// If there is only one dollar, then display "dollar".
				if( (firstPos) && (firstch < 0x0032) && (!skipch) )
				{
					wordsToAddID = kFMEX_NTW_Dollar;
				}
				else
				{
					wordsToAddID = kFMEX_NTW_Dollars;
				}
			}
			break;

			case 0 :
			{
				if  (!firstPos)  // If there are cents, but no dollars, do not display "and".
				{
					wordsToAddID = kFMEX_NTW_And;
				}		
			}
			break;

			case -1 :
			{
				if( (firstch == 0x0030) && (secondch == 0x0030) )
				{
					skipch = true;
					wordsToAddID = kFMEX_NTW_NoCents;
				}
				else
				{
					if( (secondch == 0x0030) || ( pluralcents && skipch ) )
					{
						wordsToAddID = kFMEX_NTW_Cents;
						if(secondch == 0x0030)
						{
							skipch = true; // Processing is now complete, so skip the last decimal place.

						}// secondch == 0x0030

					}// x Cents

				}// "00"
			}
			break;

			case -2 :
			{
				// As in 02 or 11 cents.
				if((firstch > 0x0031) || (pluralcents))
				{
					wordsToAddID = kFMEX_NTW_Cents;
				}
				else
				{
					if(firstch == 0x0031) // This is needed for the special "No Cents" case, where firstChar will be '0' and pluralcents == false.
					{
						wordsToAddID = kFMEX_NTW_Cent;
					}

				}// pluralcents
			}
			break;

		}// switch tempMag


		if(wordsToAddID != 0)
		{
			Do_GetString(wordsToAddID,  wordsToAdd);
			wordsToAddSize = wordsToAdd->GetSize();
			if(wordsToAddSize > 0)
			{
				returnText->AppendText(*wordsToAdd, 0, wordsToAddSize);
				tempReturn = true;

			}// wordsToAddSize

		}// wordsToAddID

	}// Billions, Millions, Thousands, Dollars, Cents	


return(tempReturn);
} // Sub_GetWordFromNum



void Sub_GetFilteredChars(const fmx::TextAutoPtr& filterThis, fmx::ushort* filteredIntoHere, unsigned long& filteredIntoHereMaxSize, bool saveDecimal)
{
	unsigned long	filterThisSize(filterThis->GetSize());
	if((filterThisSize > 0) && (filteredIntoHere != NULL) && (filteredIntoHereMaxSize > 0))
	{
		unsigned long	tempSize = 0;
		filteredIntoHere[0] = 0;

		fmx::ushort		tempScanBuffer[kXMpl_FilterMaxBufferSize];
		filterThis->GetUnicode(tempScanBuffer, 0, filterThisSize);

		bool			gotNonLeadingZero = false;
		bool			alreadyGotADecimal = false;
		bool			curUnicharIsValidNumber = false;
		fmx::ushort		tempUnichar = 0;
		for(unsigned long onChar=0; (onChar<filterThisSize) && (tempSize<filteredIntoHereMaxSize); onChar++)
		{
			tempUnichar = tempScanBuffer[onChar];

			// To this routine, a valid character is anything from'0'..'9', but only if we have already been given
			//		a character in the range of '1'..'9'. If saveDecimal is true, the character stored in
			//		gFMPluginExamplePrefs.decimalPoint is also a valid character, but only once.  More than
			//		one decimal point is not valid.
			curUnicharIsValidNumber = (  ((tempUnichar >= 0x0030) && (tempUnichar <= 0x0039)) || ((saveDecimal) && (tempUnichar==gFMPluginExamplePrefs.decimalPoint)) );
			if( (curUnicharIsValidNumber) && (alreadyGotADecimal) && (tempUnichar == gFMPluginExamplePrefs.decimalPoint))
			{
				curUnicharIsValidNumber = false;
			}


			if( (!gotNonLeadingZero) && (tempUnichar != 0x0030) && (curUnicharIsValidNumber) )
			{
				gotNonLeadingZero = true; // Got a non-zero leading number character ('1'..'9'), or a decimal point, if applicable.

			}// !gotNonLeadingZero

			if((gotNonLeadingZero) && (curUnicharIsValidNumber))
			{
				filteredIntoHere[tempSize] = tempUnichar;
				tempSize++;

				if(tempUnichar == gFMPluginExamplePrefs.decimalPoint)
				{
					alreadyGotADecimal = true;
				}

			}// gotNonLeadingZero

		}// for onChar<enteredTxtSize

		filteredIntoHereMaxSize = tempSize;
		
	}// filterThisSize

} // Sub_GetFilteredChars



void Do_GetString(unsigned long whichString, FMX_ULong /* winLangID */, FMX_Long resultsize, FMX_Unichar* string)
{
	bool		processedSpecialStringID = false;

	// Map whichString (if needed).
	// kFMXT_OptionsStr is not the same as kXMpl_OptionsStringID.
	switch (whichString)
	{
		case kFMXT_OptionsStr:
		{
			#if defined(FMX_WIN_TARGET)
				LoadStringW( (HINSTANCE)(gFMX_ExternCallPtr->instanceID), kXMpl_OptionsStringID, (LPWSTR)string, resultsize);
				processedSpecialStringID = true;
			#endif
			
			#if defined(FMX_MAC_TARGET)
				Sub_OSXLoadString(kXMpl_OptionsStringID, string, resultsize);
				processedSpecialStringID = true;
			#endif
		}
		break;

	}// switch (whichString)

	
	if( !processedSpecialStringID )
	{
		#if defined(FMX_WIN_TARGET)
			LoadStringW( (HINSTANCE)(gFMX_ExternCallPtr->instanceID), (unsigned int)whichString, (LPWSTR)string, resultsize);
		#endif

		#if defined(FMX_MAC_TARGET)
			Sub_OSXLoadString(whichString, string, resultsize);
		#endif

	}// !processedSpecialStringID

} // Do_GetString (FMX_Unichar* version)



enum { kXMpl_GetStringMaxBufferSize = 1024 };

void Do_GetString(unsigned long whichStringID, fmx::TextAutoPtr& intoHere, bool stripFunctionParams)
{
	FMX_Unichar			tempBuffer[kXMpl_GetStringMaxBufferSize];

	Do_GetString(whichStringID, 0, kXMpl_GetStringMaxBufferSize, tempBuffer);
	intoHere->AssignUnicode(tempBuffer);
	
	if(stripFunctionParams)
	{
		// The string for this whichStringID is a Function Prototype, but all the plug-in needs now is the Function Name by itself.

		fmx::TextAutoPtr		parenToken;
		parenToken->Assign("(");

		unsigned long		originalSize = intoHere->GetSize();
		unsigned long		firstParenLocation; 
		firstParenLocation = intoHere->Find(*parenToken, 0);
	
		intoHere->DeleteText(firstParenLocation, originalSize-firstParenLocation);

	}// stripFunctionParams

} // Do_GetString (TextAutoPtr version)


const fmx::ExprEnv *fm_env;


PHiValue __stdcall fmp_runScript(DWORD info) {

	PHiValue file   = nako_getFuncArg(info, 0);
	PHiValue script = nako_getFuncArg(info, 1);
	
	fmx::TextAutoPtr file_txt;
	fmx::TextAutoPtr script_txt;

	file_txt->Assign(file->ptr_s, fmx::Text::kEncoding_ShiftJIS_Win);
	script_txt->Assign(script->ptr_s,fmx::Text::kEncoding_ShiftJIS_Win);

	fmx::DataAutoPtr t1;
	fmx::DataAutoPtr t2;
	
	t1->SetAsText(*file_txt, t1->GetLocale());
	t2->SetAsText(*script_txt,t1->GetLocale());

	FMX_StartScript(&(t1->GetAsText()), &(t2->GetAsText()), kFMXT_Pause, NULL);

	return NULL;
}

PHiValue __stdcall fmp_runEval(DWORD info) {

	PHiValue str   = nako_getFuncArg(info, 0);

	fmx::TextAutoPtr str_txt;
	str_txt->Assign(str->ptr_s, fmx::Text::kEncoding_ShiftJIS_Win);

	fmx::DataAutoPtr t1;
	t1->SetAsText(*str_txt, t1->GetLocale());
	
	fmx::errcode errorResult = 0;
	fmx::DataAutoPtr results; // この辺でエラーになる
	fm_env->Evaluate(t1->GetAsText(), *(fmx::Data*)results.get());

	char buf[ 4064 ];
	results->GetAsText().GetBytes(buf, 4095, 0, 4095, fmx::Text::kEncoding_ShiftJIS_Win);
	
	PHiValue res = nako_var_new(NULL);
	nako_str2var(buf, res);
	return res;

}


// FileMaker 固有の命令を追加する
void _dnako_addFMCommand() {
	nako_addFunction2("FMスクリプト実行","FILEのSTRを", fmp_runScript, 0, NULL);
	nako_addFunction2("FMデータ取得","STRの", fmp_runEval, 0, NULL);
}

char dnako_path[MAX_PATH];
char plugin_path[MAX_PATH];
BOOL flag_dnako_running = FALSE;

BOOL _dnako_load() {

	// COMMON_APPDATA
	char appdata[MAX_PATH];
	file_get_common_appdata_dir(appdata, MAX_PATH);
	// dnako
	strcpy_s(dnako_path, appdata);
	strcat_s(dnako_path, "\\com.nadesi\\plug-ins\\dnako.dll");
	// plugin dir
	strcpy_s(plugin_path, appdata);
	strcat_s(plugin_path, "\\com.nadesi\\plug-ins\\");

	if (dnako_enabled()) {
		dnako_unload();
	}

	BOOL r = dnako_load(dnako_path);
	if (r) {
		// set plug-ins dir
		nako_setPluginsDir(plugin_path);
		//
		nako_LoadPlugins();
		nako_addFileCommand();
		_dnako_addFMCommand();
	}
	return r;
}

FMX_PROC(fmx::errcode) Do_nako_getVersion(short /* funcId */,
	const fmx::ExprEnv& /* environment */,
	const fmx::DataVect&  dataVect, fmx::Data& results)
{
    // System variable
    fmx::errcode errorResult = 0;
	if (!dnako_enabled()) {
		errorResult = -1;
		return(errorResult);
	}
    // Store entered text
    fmx::TextAutoPtr    resultTxt;
	// check dnako version
	char* p = nako_getVersion();
	resultTxt->Assign(p);
    results.SetAsText( *resultTxt, results.GetLocale());

	return(errorResult);
}

FMX_PROC(fmx::errcode) Do_nako_reset(short /* funcId */,
	const fmx::ExprEnv& /* environment */,
	const fmx::DataVect&  dataVect, fmx::Data& results)
{
    // System variable
    fmx::errcode errorResult = 0;
	if (flag_dnako_running) return(errorResult);
	// Cehck enabled?
	if (!dnako_enabled()) {
		errorResult = -1;
		return(errorResult);
	}
	dnako_unload();
	_dnako_load();

	return(errorResult);
}

fmx::errcode _nako_eval(const fmx::DataVect&  dataVect, fmx::Data& results, BOOL ResultIsSore)
{
    fmx::errcode errorResult = 0;
	
	if (flag_dnako_running) return errorResult;
	flag_dnako_running = TRUE;

	if (!dnako_enabled()) {
		errorResult = -1;
		/// message
		MessageBox(NULL, "dnako.dllのロードに失敗しています。", "NADESIKO ERROR", MB_OK);
		flag_dnako_running = FALSE;
		return(errorResult);
	}

    // Store entered text
    fmx::TextAutoPtr    resultTxt;
	//
	fmx::TextAutoPtr	sText;
	sText->SetText( dataVect.AtAsText(0), 0 );
	unsigned long len = sText->GetSize() * 2;
	char*	src = (char*)malloc(len+1);
	sText->GetBytes(src, len+1, 0, fmx::Text::kSize_End, fmx::Text::kEncoding_ShiftJIS_Win);
	
	// debug src
	/*
	char msg[1024];
	sprintf(msg, "%d:%s", len, src);
	MessageBox(NULL, msg, "SRC", MB_OK);
	*/
	
	//
	PHiValue res = NULL;
	char err[4096];
	DWORD err_len = 0;
	string s;
	BOOL nadesiko_result = true;
	//
	if (ResultIsSore) {
		char* src2 = (char*)malloc(strlen(src) + 512);
		sprintf(src2, "FM結果=空。%s;", src);
		nadesiko_result = nako_evalEx(src2, &res);
		free(src2);
		nako_var_free(res);
		res = nako_getVariable("FM結果");	
	} else {
		nadesiko_result = nako_evalEx(src, &res);
	}
	//
	if (nadesiko_result == false) {
		err_len = nako_getError(err, 4095);
	}
	//
	// has Error ?
	if (err_len > 0) {
		MessageBox(NULL, err, "NADESIKO ERROR", MB_OK | MB_ICONERROR);
		errorResult = -1;
		nako_clearError();
	} else {
		s = hi_str(res);
		const char* ps = (const char*)s.c_str();
		size_t sz = s.length() + 2;
		resultTxt->Assign(ps);
		//MessageBox(NULL, ps, "OK", MB_OK);
	}
	free(src);
	nako_var_free(res);
	// set Result
	results.SetAsText( *resultTxt, results.GetLocale());
	flag_dnako_running = FALSE;
	return(errorResult);
}

FMX_PROC(fmx::errcode) Do_nako_eval(short /* funcId */,
	const fmx::ExprEnv& environment,
	const fmx::DataVect&  dataVect, fmx::Data& results)
{
    // System variable
	fm_env = &environment;
	return(_nako_eval(dataVect, results, FALSE));
}

FMX_PROC(fmx::errcode) Do_nako_exec(short /* funcId */,
	const fmx::ExprEnv& environment,
	const fmx::DataVect&  dataVect, fmx::Data& results)
{
    fmx::errcode errorResult = 0;
	fm_env = &environment;

	// RESET
    if (!dnako_enabled()) {
		errorResult = -1;
		return(errorResult);
	}
	dnako_unload();
	_dnako_load();

	// EVAL
	errorResult = _nako_eval(dataVect, results, TRUE);
	return(errorResult);
}

#if defined(FMX_MAC_TARGET)

	unsigned long Sub_OSXLoadString(unsigned long stringID, FMX_Unichar* intoHere, long intoHereMax)
	{
		unsigned long		returnResult = 0;
		
		
		if( (intoHere != NULL) && (intoHereMax > 1) )
		{
			// Turn stringID to a textual identifier, then get the string from the .strings file as a null-term unichar array.
			CFStringRef 	strIdStr = CFStringCreateWithFormat( kCFAllocatorDefault, NULL, CFSTR("FMPluginExample %d"), stringID );
			
			// Note: The plug-in must be explicit about the bundle and file it wants to pull the string from.
			CFStringRef 	osxStr = CFBundleCopyLocalizedString( reinterpret_cast<CFBundleRef>(gFMX_ExternCallPtr->instanceID), strIdStr, strIdStr, CFSTR("FMPluginExample") );
			if((osxStr != NULL) && (osxStr != strIdStr))
			{
				long	osxStrLen = CFStringGetLength(osxStr);
				if( osxStrLen < (intoHereMax-1) )
				{
					CFRange		allChars;
					allChars.location = 0;
					allChars.length = osxStrLen;
					
					CFStringGetCharacters(osxStr, allChars, (UniChar*)(intoHere));
					intoHere[osxStrLen] = 0x0000;
					returnResult = (unsigned long)osxStrLen;
					
				}// osxStrLen
				
				CFRelease( osxStr );
				
			}// osxStr
			
			CFRelease( strIdStr );
			
		}// intoHere
			
	return(returnResult);
	
	} // Sub_OSXLoadString
	
#endif

