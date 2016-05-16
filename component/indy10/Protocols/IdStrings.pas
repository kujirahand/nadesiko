{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  11765: IdStrings.pas 
{
{   Rev 1.6    7/30/2004 7:49:30 AM  JPMugaas
{ Removed unneeded DotNET excludes.
}
{
{   Rev 1.5    2004.02.03 5:44:26 PM  czhower
{ Name changes
}
{
{   Rev 1.4    2004.02.03 2:12:20 PM  czhower
{ $I path change
}
{
{   Rev 1.3    24/01/2004 19:30:28  CCostelloe
{ Cleaned up warnings
}
{
{   Rev 1.2    10/12/2003 2:01:48 PM  BGooijen
{ Compiles in DotNet
}
{
{   Rev 1.1    10/10/2003 11:06:54 PM  SPerry
{ -
}
{
{   Rev 1.0    11/13/2002 08:02:02 AM  JPMugaas
}
unit IdStrings;

interface

Uses
  Classes;

{
2000-03-27  Pete Mee
 - Added FindFirstOf, FindFirstNotOf and TrimAllOf functions.
2002-01-03  Andrew P.Rybin
 - StrHTMLEnc/Dec,BinToHexStr,SplitColumns,IsWhiteString
2002-03-12 Andrew P.Rybin
 - SplitColumns[NoTrim]
}

function  FindFirstOf(AFind, AText: String): Integer;
function  FindFirstNotOf(AFind, AText : String) : Integer;
function  TrimAllOf(ATrim, AText : String) : String;

// Empty or contain only TAB and Space. Use it vs Length(Trim(AStr))>0
function  IsWhiteString(const AStr: String): Boolean;
function  BinToHexStr(AData: Byte): String;

// Encode reserved html chars: < > ' & "    {Do not Localize}
function  StrHtmlEncode (const AStr: String): String;
function  StrHtmlDecode (const AStr: String): String;

// SplitString splits a string into left and right parts,
// i.e. SplitString('Namespace:tag', ':'..) will return 'Namespace' and 'Tag'
procedure SplitString(const AStr, AToken: String; var VLeft, VRight: String);

// commaadd will append AStr2 to the right of AStr1 and return the result.
// if there is any content in AStr1, a comma will be added
function CommaAdd(Const AStr1, AStr2:String):string;

implementation

uses
  IdException,
  IdGlobal,
  IdGlobalProtocols,
  SysUtils;

function StrHtmlEncode (const AStr: String): String;
begin
  Result := StringReplace(AStr,   '&', '&amp;', [rfReplaceAll]);    {Do not Localize}
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);    {Do not Localize}
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);    {Do not Localize}
  Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);    {Do not Localize}
  Result := StringReplace(Result, '''', '&apos;', [rfReplaceAll]);    {Do not Localize}
end;

function StrHtmlDecode (const AStr: String): String;
begin
  Result := StringReplace(AStr,   '&apos;', '''', [rfReplaceAll]);    {Do not Localize}
  Result := StringReplace(Result, '&quot;', '"', [rfReplaceAll]);    {Do not Localize}
  Result := StringReplace(Result, '&gt;', '>', [rfReplaceAll]);    {Do not Localize}
  Result := StringReplace(Result, '&lt;', '<', [rfReplaceAll]);    {Do not Localize}
  Result := StringReplace(Result, '&amp;', '&', [rfReplaceAll]);    {Do not Localize}
end;


{Function  ReadTimeStampCounter: Int64;
Asm
  db $0F,$31 //RDTSC
End;//Read CPU TimeStamp}

function FindFirstOf(AFind, AText: string): Integer;
var
  nCount, nPos: Integer;
begin
  Result := 0;
  for nCount := 1 to Length(AFind) do begin
    nPos := IndyPos(AFind[nCount], AText);
    if nPos > 0 then begin
      if Result = 0 then begin
        Result := nPos;
      end else if Result > nPos then begin
        Result := nPos;
      end;
    end;
  end;
end;

function FindFirstNotOf(AFind, AText : String) : Integer;
var
  i : Integer;
begin
  result := 0;
  if length(AFind) = 0 then
  begin
    result := 1;
    exit;
  end;

  if length(AText) = 0 then
  begin
    exit;
  end;

  for i := 1 to length(AText) do
  begin
    if IndyPos(AText[i], AFind) = 0 then
    begin
      result := i;
      exit;
    end;
  end;
end;

function TrimAllOf(ATrim, AText : String) : String;
begin
  while Length(AText) > 0 do
  begin
    if Pos(AText[1], ATrim) > 0 then
    begin
      IdDelete(AText, 1, 1);
    end else break;
  end;
  while Length(AText) > 0 do begin
    if Pos(AText[length(AText)], ATrim) > 0 then
    begin
      IdDelete(AText, Length(AText), 1);
    end else break;
  end;
  result := AText;
End;

//SP - 10/10/2003
function BinToHexStr(AData: Byte): String;
begin
  result := IdHexDigits[AData shr 4] + IdHexDigits[AData and $F];
end;

function IsWhiteString(const AStr: String): Boolean;
const
  WhiteSet = [TAB, CHAR32];    {Do not Localize}
var
  i: Integer;
  LLen: Integer;
Begin
  LLen := Length(AStr);
  if LLen > 0 then begin
    Result:=TRUE; //only white
    for i:=1 to LLen do begin
      if not CharIsInSet(AStr, i, WhiteSet) then begin
        Result:=FALSE;
        break;
      end;
    end;
  end
  else begin
    Result:=TRUE; //empty
  end;
End;//IsWhiteString


procedure SplitString(const AStr, AToken: String; var VLeft, VRight: String);
var
  i: Integer;
  LLocalStr: String;
begin
  { It is possible that VLeft or VRight may be the same variable as AStr. So we copy it first }
  LLocalStr := AStr;
  i := Pos(AToken, LLocalStr);
  if i = 0 then
    begin
    VLeft := LLocalStr;
    VRight := '';
    end
  else
    begin
    VLeft := Copy(LLocalStr, 1, i - 1);
    VRight := Copy(LLocalStr, i + Length(AToken), Length(LLocalStr));
    end;
end;

function CommaAdd(Const AStr1, AStr2:String):string;
begin
  if AStr1 = '' then
    result := AStr2
  else
    result := AStr1 + ',' + AStr2;
end;

END.
