{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  58416: IdFTPListTypes.pas 
{
{   Rev 1.3    10/26/2004 9:27:34 PM  JPMugaas
{ Updated references.
}
{
{   Rev 1.2    6/27/2004 1:45:36 AM  JPMugaas
{ Can now optionally support LastAccessTime like Smartftp's FTP Server could. 
{ I also made the MLST listing object and parser support this as well.
}
{
{   Rev 1.1    6/4/2004 2:11:00 PM  JPMugaas
{ Added an indexed read-only Facts property to the MLST List Item so you can
{ get information that we didn't parse elsewhere.  MLST is extremely flexible.
}
{
{   Rev 1.0    4/20/2004 2:43:20 AM  JPMugaas
{ Abstract FTPList objects for reuse.
}
unit IdFTPListTypes;

interface
uses Classes, IdFTPList, IdTStrings;

type
  //For NLST and Cisco IOS
  TIdMinimalFTPListItem = class(TIdFTPListItem)
  public
    constructor Create(AOwner: TCollection); override;
  end;
  //This is for some mainframe items which are based on records
  TIdRecFTPListItem = class(TIdFTPListItem)
  protected
      //These are for VM/CMS which uses a record type of file system
    FRecLength : Integer;
    FRecFormat : String;
    FNumberRecs : Integer;
    property RecLength : Integer read FRecLength write FRecLength;
    property RecFormat : String read FRecFormat write FRecFormat;
    property NumberRecs : Integer read FNumberRecs write FNumberRecs;

  public
  end;
  //for MLST output
  TIdMLSTFTPListItem = class(TIdFTPListItem)
  protected
    FCreationDate: TDateTime;
    FCreationDateGMT : TDateTime;
    FLastAccessDate: TDateTime;
    FLastAccessDateGMT : TDateTime;
    //Unique ID for an item to prevent yourself from downloading something twice
    FUniqueID : String;
    //MLIST things
    FMLISTPermissions : String;
    function GetFact(const AName : String) : String;
  public
    //Creation time values are for MLSD data output and can be returned by the
    //the MLSD parser in some cases
    property ModifiedDateGMT;
    property CreationDate: TDateTime read FCreationDate write FCreationDate;
    property CreationDateGMT : TDateTime read FCreationDateGMT write FCreationDateGMT;

    property LastAccessDate: TDateTime read FLastAccessDate write FLastAccessDate;
    property LastAccessDateGMT : TDateTime read FLastAccessDateGMT write FLastAccessDateGMT;

    //Valid only with EPLF and MLST
    property UniqueID : string read FUniqueID write FUniqueID;
    //MLIST Permissions
    property MLISTPermissions : string read FMLISTPermissions write FMLISTPermissions;
    property Facts[const Name: string] : string read GetFact;
  end;
  //for some parsers that output an owner sometimes
  TIdOwnerFTPListItem = class(TIdFTPListItem)
  protected
    FOwnerName : String;
  public
    property OwnerName : String read FOwnerName write FOwnerName;
  end;
  //This class type is used by Novell Netware,
  //Novell Print Services for Unix with DOS namespace, and HellSoft FTPD for Novell Netware
  TIdNovellBaseFTPListItem = class(TIdOwnerFTPListItem)
  protected
    FNovellPermissions : String;
  public
    property NovellPermissions : string read FNovellPermissions write FNovellPermissions;
  end;
  //Bull GCOS 8 uses this and Unix will use a descendent
  TIdUnixPermFTPListItem = class(TIdOwnerFTPListItem)
  protected
    FUnixGroupPermissions: string;
     FUnixOwnerPermissions: string;
     FUnixOtherPermissions: string;
  public
    property UnixOwnerPermissions: string read FUnixOwnerPermissions write FUnixOwnerPermissions;
    property UnixGroupPermissions: string read FUnixGroupPermissions write FUnixGroupPermissions;
    property UnixOtherPermissions: string read FUnixOtherPermissions write FUnixOtherPermissions;
  end;
  // Unix and Novell Netware Print Services for Unix with NFS namespace need to use this
  TIdUnixBaseFTPListItem = class(TIdUnixPermFTPListItem)
  protected
    FLinkCount: Integer;
    FGroupName: string;
    FLinkedItemName : string;
  public
    property LinkCount: Integer read FLinkCount write FLinkCount;
    property GroupName: string read FGroupName write FGroupName;
    property LinkedItemName : string read FLinkedItemName write FLinkedItemName;
  end;

implementation
uses IdFTPCommon, IdGlobal, SysUtils;
{ TIdMinimalFTPListItem }

constructor TIdMinimalFTPListItem.Create(AOwner: TCollection);
begin
  inherited;
  FSizeAvail := False;
  FModifiedAvail := False;
end;

{ TIdMLSTFTPListItem }

function TIdMLSTFTPListItem.GetFact(const AName: String): String;
var LFacts : TIdStrings;
begin
  LFacts := TIdStringList.Create;
  try
    ParseFacts(Data,LFacts);
    Result := LFacts.Values[AName];
  finally
    FreeAndNil(LFacts);
  end;
end;

end.
