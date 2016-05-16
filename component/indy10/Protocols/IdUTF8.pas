{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  57396: IdUTF8.pas 
{
{   Rev 1.1    2/29/2004 6:18:38 AM  JPMugaas
{ More functions added for UTF8 support.  This still needs to be tested.
}
{
{   Rev 1.0    2/29/2004 3:36:16 AM  JPMugaas
{ Preliminary version of UTF8 encode and decode.  We may need this later on for
{ some FTP work and for other protocol support.
}
unit IdUTF8;

interface
uses IdGlobal, IdGlobalProtocols, SysUtils;

{$I IdCompilerDefines.inc}
{$IFDEF DOTNET}
type
  UTF8String = string;
{$ENDIF}

function UTF8ToUnicode(const AUTF8 : UTF8String): WideString; overload;
function UTF8ToUnicode(const AUTF8 : TIdBytes) : WideString; overload;

function UnicodeToUTF8(const AUnicode : WideString): UTF8String; overload;
function UnicodeToUTF8(const AUnicode : TIdBytes) : UTF8String; overload;

implementation
{$IFDEF DOTNET}
uses System.Text;
{$ENDIF}
{
This is code partially based on GpTextFile.

Appropriate notice is:

  Stream wrapper class that automatically converts another stream (containing
   text data) into a Unicode stream. Underlying stream can contain 8-bit text
   (in any codepage) or 16-bit text (in 16-bit or UTF8 encoding).
author Primoz Gabrijelcic

This software is distributed under the BSD license.

Copyright (c) 2003, Primoz Gabrijelcic
All rights reserved.


Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
- Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.
- The name of the Primoz Gabrijelcic may not be used to endorse or promote
  products derived from this software without specific prior written permission.

}

{      RFC 2279 table for reference
UCS-4   range   (hex.)  UTF-8 octet sequence (binary)
 0000 0000-0000  007F   0xxxxxxx
 0000 0080-0000  07FF   110xxxxx 10xxxxxx

 0000 0800-0000  FFFF   1110xxxx 10xxxxxx 10xxxxxx
 0001 0000-001F  FFFF   11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
 0020 0000-03FF  FFFF   111110xx 10xxxxxx 10xxxxxx 10xxxxxx
 0400 0000-7FFF  FFFF   1111110x 10xxxxxx ... 10xxxxxx


}
function UTF8ToUnicode(const AUTF8 : UTF8String): WideString; overload;
begin
  Result := UTF8ToUnicode(ToBytes(AUTF8));
end;

function UTF8ToUnicode(const AUTF8 : TIdBytes) : WideString; overload;
var i : Integer;
   LBytesLeft : Integer;
   LWC : WideChar;
   LCh,
   LCh2,
   LCh3 : Byte;
begin
  Result := '';
  LBytesLeft := Length(AUTF8);
  i := 0;
  while LBytesLeft >0 do
  begin
    LCh := AUTF8[i];
    if (LCh AND $80) = 0 then
    begin
      //one byte
      Result := Result + Char(LCh);
      inc(i);
      dec(LBytesLeft);
    end
    else
    begin
      if (LCh AND $E0) = $C0 then  // 2-byte code
      begin
        if LBytesLeft <2 then
        begin
          Exit;
        end
        else
        begin
          LWC := WideChar(TwoByteToWord(AUTF8[i],AUTF8[i+1]));
          Result := Result + LWC;
        end;
        inc(i,2);
        dec(LBytesLeft,2);
      end
      else
      begin  //at least 3 bytes
        if LBytesLeft<3 then
        begin
          Exit;
        end;
        LCh := AUTF8[i];
        LCh2 := AUTF8[i+1];
        LCh3 := AUTF8[i+2];
        LWC :=  WideChar( (word(LCh AND $0F) SHL 12) OR
         (word(LCh2 AND $3F) SHL 6) OR
         (LCh3 AND $3F));
        Result := Result + LWC;
        inc(i,3);
        dec(LBytesLeft,3);
      end;
    end;
  end;
end;

{}
function UnicodeToUTF8(const AUnicode : WideString): UTF8String;
begin
  Result := UnicodeToUTF8(ToBytes(AUnicode));
end;

function UnicodeToUTF8(const AUnicode : TIdBytes) : UTF8String;
var
  LWC : Word;
  i : Integer;
  LCh : Char;
begin
  Result := '';
  for i := 0 to ((Length(AUnicode)-1) div 2) do
  begin
    LWC := TwoByteToWord( AUnicode[i*2],AUnicode[(i*2)+1]);
    if (LWC >= $0001) and (LWC <= $007F) then
    begin
      //One Byte
      LCh := Char(LWC and $7F);
      Result := Result + LCh;
    end
    else
    begin
       if (LWC >= $0080) and (LWC <= $07FF) then begin
       //two bytes
         Result := Result +  Char($C0 OR ((LWC SHR 6) AND $1F));
         Result := Result +  Char($80 OR (LWC AND $3F));
       end
       else
       begin // (wc >= $0800) and (wc <= $FFFF)
         //three bytes
         Result := Result +  Char($E0 OR ((LWC SHR 12) AND $0F));
         Result := Result +  Char($80 OR ((LWC SHR 6) AND $3F));
         Result := Result +  Char($80 OR (LWC AND $3F));
       end;
    end;
  end;
end;

end.
