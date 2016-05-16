{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16201: IdFTPListParseTOPS20.pas
{
{   Rev 1.6    10/26/2004 9:55:58 PM  JPMugaas
{ Updated refs.
}
{
{   Rev 1.5    6/5/2004 7:48:56 PM  JPMugaas
{ In TOPS32, a FTP dir listing will often not contain dates or times.  It's
{ usually just the name.
}
{
{   Rev 1.4    4/19/2004 5:05:44 PM  JPMugaas
{ Class rework Kudzu wanted.
}
{
{   Rev 1.3    2004.02.03 5:45:26 PM  czhower
{ Name changes
}
{
    Rev 1.2    10/19/2003 3:36:22 PM  DSiders
  Added localization comments.
}
{
{   Rev 1.1    4/7/2003 04:04:18 PM  JPMugaas
{ User can now descover what output a parser may give.
}
{
{   Rev 1.0    2/19/2003 05:49:58 PM  JPMugaas
{ Parsers ported from old framework.
}
unit IdFTPListParseTOPS20;

interface
uses classes, IdFTPList, IdFTPListParseBase, IdTStrings;

type
  TIdTOPS20FTPListItem = class(TIdFTPListItem)
  protected
    FCreationDate: TDateTime;
  public
    constructor Create(AOwner: TCollection); override;
    property CreationDate: TDateTime read FCreationDate write FCreationDate;
  end;
  TIdFTPLPTOPS20 = class(TIdFTPListBase)
  protected
    class function MakeNewItem(AOwner : TIdFTPListItems)  : TIdFTPListItem; override;
    class function ParseLine(const AItem : TIdFTPListItem; const APath : String=''): Boolean; override;
  public
    class function GetIdent : String; override;
    class function CheckListing(AListing : TIdStrings; const ASysDescript : String =''; const ADetails : Boolean = True): boolean; override;
  end;

implementation

uses
  IdGlobal, IdFTPCommon, IdGlobalProtocols, IdStrings, SysUtils;


{ TIdFTPLPTOPS20 }

class function TIdFTPLPTOPS20.CheckListing(AListing: TIdStrings;
  const ASysDescript: String; const ADetails: Boolean): boolean;
var s : String;
begin
  s := ASysDescript;
  s := Fetch(s);
  Result := (s = 'TOPS20'); {do not localize}
end;

class function TIdFTPLPTOPS20.GetIdent: String;
begin
  Result := 'TOPS20'; {do not localize}
end;

class function TIdFTPLPTOPS20.MakeNewItem(
  AOwner: TIdFTPListItems): TIdFTPListItem;
begin
  Result := TIdTOPS20FTPListItem.Create(AOwner);
end;

class function TIdFTPLPTOPS20.ParseLine(const AItem: TIdFTPListItem;
  const APath: String): Boolean;
var LBuf : String;
  LI : TIdTOPS20FTPListItem;
{
Notes from the FTP Server greeting at toad.xkl.com

230- Welcome!  You are logged in to a Tops-20 system, probably not familiar
230- to you.  We therefore offer this short note on directory and file naming
230- conventions:
230-
230- A file name consists of 2 required parts, and several optional parts, of
230- which 3 are important to you as an FTP user.  These 5 parts together are
230-
230- device:<directory>filename.filetype.generation
230-
230- where the punctuation is required.  The DEVICE:, <DIRECTORY>, and GENERATION
230- fields are optional, defaulting to current device and directory and latest
230- generation of the file.  File names are NOT in general case-sensitive.
230-
230- <DIRECTORY> may have subparts, separated by dots.  All the following are
230- syntactically valid directory specifications (though they may not exist on
230- this particular system):
230-
230- <FOO>  or  <FOO.BAR>  or  <FOO.BAR.QUUX>  or  <SRC.7.MONITOR.BUILD>
230-
230- GENERATION is numeric; it may take the special values 0 (latest generation),
230- -1 (new, next higher generation), -2 (oldest generation), and -3 (wildcard
230- for all generations), as well as specific numeric generations.
230-
230- DEVICE: usually represents the name of a file system.
230-
230- Wildcards are specified as * (match 0 or more characters) and % (match 1
230- single character).  To obtain all the command files in a directory, you
230- would ask for the retrieval of
230-
230- *.CMD.*
230-
230- To obtain the latest version of all the files with a 1-character FILETYPE,
230- you would request
230-
230- *.%.0
}
  function StripBuild(const AFileName : String): String;
  var LPos : Integer;
  begin
    LPos := RPos('.',AFileName,-1);
    if LPos=0 then
    begin
      Result := AFileName;
    end
    else
    begin
      Result := Copy(AFileName,1,LPos-1);
    end;
  end;

begin
  LI := AItem as TIdTOPS20FTPListItem;
  LBuf := AItem.Data;
  if (IndyPos(':<',LBuf)>0) and (IndyPos('>',LBuf)=Length(LBuf)) then
  begin
      //Tape and subdir should work for CD
      //Note this is probably something like a "CD ." on other systems.
      //From what I saw at one server, they had to give a list including
      //subdirectories because the server never returned those.
      AItem.FileName := LBuf;
      //You can tree this like a directory.  It contains the device so it might
      //look weird.
      AItem.ItemType := ditDirectory;

      //strip off device in and path suffix >
      Fetch(LBuf,':<');
      LBuf := Fetch(LBuf,'>');
      AItem.LocalFileName := LowerCase(LBuf);
      AItem.SizeAvail := False;
      AItem.ModifiedAvail := False;
      Result := True;
      Exit;
  end;
  if IndyPos('<',LBuf)=1 then
  begin
      //we may be dealing with a data format such as this:
      //
      //<ANONYMOUS>INSTALL.MEM.1;P775252;A,210,10-Apr-1990 13:17:41,10-Apr-1990 13:18:26,11-Jan-2003 11:34:26
      AItem.FileName := Fetch(LBuf,';');
      //P775252;
      Fetch(LBuf,';');
      //A,
      Fetch(LBuf,',');
      //210,
      Fetch(LBuf,',');
      //Creation Date - date - I think
      LI.CreationDate := IdFTPCommon.DateDDStrMonthYY(Fetch(LBuf));
      //creation date - time
      LI.CreationDate := LI.CreationDate + IdFTPCommon.TimeHHMMSS(Trim(Fetch(LBuf,',')));
      //Last modified - date
      AItem.ModifiedDate := IdFTPCommon.DateDDStrMonthYY(Fetch(LBuf));
      //Last modified - time
      AItem.ModifiedDate := AItem.ModifiedDate + IdFTPCommon.TimeHHMMSS(Trim(LBuf));
      //strip off path information and build no for file
      LBuf := LowerCase(AItem.FileName);
      Fetch(LBuf,'>');
      AItem.LocalFileName := StripBuild(LBuf);
  end
  else
  begin
    //That's right - it only returned the file name, no dates, no size, nothing else
    AItem.FileName := LBuf;
    AItem.LocalFileName := LowerCase(StripBuild(LBuf));
    AItem.ModifiedAvail := False;
    AItem.SizeAvail := False;
  end;
  Result := True;
end;

{ TIdTOPS20FTPListItem }

constructor TIdTOPS20FTPListItem.Create(AOwner: TCollection);
begin
  inherited;
  SizeAvail := False;
end;

initialization
  RegisterFTPListParser(TIdFTPLPTOPS20);
finalization
  UnRegisterFTPListParser(TIdFTPLPTOPS20);
end.
