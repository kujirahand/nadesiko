{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16203: IdFTPListParseOS2.pas
{
{   Rev 1.5    10/26/2004 9:51:16 PM  JPMugaas
{ Updated refs.
}
{
{   Rev 1.4    4/19/2004 5:05:46 PM  JPMugaas
{ Class rework Kudzu wanted.
}
{
{   Rev 1.3    2004.02.03 5:45:28 PM  czhower
{ Name changes
}
{
    Rev 1.2    10/19/2003 3:36:14 PM  DSiders
  Added localization comments.
}
{
{   Rev 1.1    10/1/2003 05:27:36 PM  JPMugaas
{ Reworked OS/2 FTP List parser for Indy.  The aprser wasn't detecting OS/2 in
{ some more samples I was able to get ahold of.
}
{
{   Rev 1.0    2/19/2003 05:50:28 PM  JPMugaas
{ Parsers ported from old framework.
}
unit IdFTPListParseOS2;

interface
uses classes, IdFTPList, IdFTPListParseBase, IdTStrings;

{
This parser is based on some data that I had managed to obtain second hand
from what people posted on the newsgroups.
}
type
  TIdOS2FTPListItem = class(TIdFTPListItem);
  TIdFTPLPOS2 = class(TIdFTPListBase)
  protected
    class function MakeNewItem(AOwner : TIdFTPListItems)  : TIdFTPListItem; override;
    class function IsValidOSAttr(const AAttr : String) : Boolean;
    class function ParseLine(const AItem : TIdFTPListItem; const APath : String=''): Boolean; override;
  public
    class function GetIdent : String; override;
    class function CheckListing(AListing : TIdStrings; const ASysDescript : String =''; const ADetails : Boolean = True): boolean; override;
  end;

const
  OS2PARSER = 'OS/2'; {do not localize}

implementation

uses
  IdGlobal, IdFTPCommon, IdGlobalProtocols,
  SysUtils;

const VALID_ATTR = 'RASH';  {do not localize}


{ TIdFTPLPOS2 }

class function TIdFTPLPOS2.CheckListing(AListing: TIdStrings;
  const ASysDescript: String; const ADetails: Boolean): boolean;
var LBuf, LBuf2 : String;
  LNum : String;
begin
  if AListing.Count > 0 then
  begin
  {
 "             73098      A          04-06-97   15:15  ds0.internic.net1996052434624.txt"
 "                 0           DIR   12-11-95   13:55  z"
  or maybe this:
  taken from the FileZilla source-code comments
 "     0           DIR   05-12-97   16:44  PSFONTS"
 "36611      A    04-23-103   10:57  OS2 test1.file"
 " 1123      A    07-14-99   12:37  OS2 test2.file"
 "    0 DIR       02-11-103   16:15  OS2 test1.dir"
 " 1123 DIR  A    10-05-100   23:38  OS2 test2.dir"


  }
    LBuf := AListing[0];
    LBuf := TrimLeft(LBuf);
    LNum := Fetch(LBuf);
    if IsNumeric(LNum)=False then
    begin
      Result := False;
      Exit;
    end;
    repeat
      LBuf := TrimLeft(LBuf);
      LBuf2 := Fetch(LBuf);
        if LBuf2='DIR' then {do not localize}
        begin
          LBuf := TrimLeft(LBuf);
          LBuf2 := Fetch(LBuf);
        end;
      if IsMMDDYY(LBuf2,'-') then
      begin
        //we found a date
        break;
      end;
      if IsValidOSAttr(LBuf2)=False then
      begin
        Result := False;
        Exit;
      end;
    until False;
    //there must be two spaces between the date and time
    if (Copy(LBuf,1,2)<>'  ') then
    begin
      Result := False;
      Exit;
    end;
    if (Copy(LBuf,3,1)=' ') then
    begin
      Result := False;
      Exit;
    end;
    LBuf := TrimLeft(LBuf);
    LBuf2 := Fetch(LBuf);
    Result := IsHHMMSS(LBuf2,':');
  end
  else
  begin
    Result := False;
  end;
end;

class function TIdFTPLPOS2.GetIdent: String;
begin
  Result := OS2PARSER;
end;

class function TIdFTPLPOS2.IsValidOSAttr(const AAttr: String): Boolean;
var i : Integer;
begin
  Result := True;
  for i := 1 to Length(AAttr) do
  begin
    if IndyPos(AAttr[i],VALID_ATTR) = 0 then
    begin
      Result := False;
      Break;
    end;
  end;
end;

class function TIdFTPLPOS2.MakeNewItem(
  AOwner: TIdFTPListItems): TIdFTPListItem;
begin
  Result := TIdOS2FTPListItem.Create(AOwner);
end;

class function TIdFTPLPOS2.ParseLine(const AItem: TIdFTPListItem;
  const APath: String): Boolean;
var LBuf, lBuf2, LNum : String;
{
Assume layout such as:

                 0           DIR   02-18-94   19:47  BC
             79836      A          11-19-96   19:08  w.txt
12345678901234567890123456789012345678901234567890123456789012345678
         1         2         3         4         5         6
}
begin
  Result := False;
  LBuf := AItem.Data;
  LBuf := TrimLeft(LBuf);
  LNum := Fetch(LBuf);
  AItem.Size := StrToIntDef(LNum,0);

  repeat
  //keep going until we find a date
      LBuf := TrimLeft(LBuf);
      LBuf2 := Fetch(LBuf);
      if LNum='0' then
      begin
        if LBuf2 = 'DIR' then {do not localize}
        begin
          AItem.ItemType := ditDirectory;
          LBuf := TrimLeft(LBuf);
          LBuf2 := Fetch(LBuf);
        end;
      end;
      if IsMMDDYY(LBuf2,'-') then
      begin
        //we found a date
        AItem.ModifiedDate := DateMMDDYY(LBuf2);
        break;
      end;
      if LBuf = '' then
      begin
        Exit;
      end;
  until False;
  //time
  LBuf := TrimLeft(LBuf);
  LBuf2 := Fetch(LBuf);
  if IsHHMMSS(LBuf2,':') then
  begin
    AItem.ModifiedDate := AItem.ModifiedDate + TimeHHMMSS(LBuf2);
  end;
  //fetch removes one space.  We ned to remove an adidtional one
  //before the filename as a filename might start with a space
  Delete(LBuf,1,1);
  AItem.FileName := LBuf;
  Result := True;
end;

initialization
  RegisterFTPListParser(TIdFTPLPOS2);
finalization
  UnRegisterFTPListParser(TIdFTPLPOS2);
end.

