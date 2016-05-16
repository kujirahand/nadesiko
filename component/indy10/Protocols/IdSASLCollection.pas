{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  55713: IdSASLCollection.pas
{
{   Rev 1.3    10/26/2004 10:55:32 PM  JPMugaas
{ Updated refs.
}
{
    Rev 1.2    6/11/2004 9:38:38 AM  DSiders
  Added "Do not Localize" comments.
}
{
{   Rev 1.1    2004.02.03 5:45:50 PM  czhower
{ Name changes
}
{
{   Rev 1.0    1/25/2004 3:09:54 PM  JPMugaas
{ New collection class for SASL mechanism processing.
}
unit IdSASLCollection;

interface
uses
  Classes, IdBaseComponent, IdSASL, IdTCPConnection, IdException,
  IdTStrings;

type
  TIdSASLListEntry = class(TCollectionItem)
  protected
    FSASL : TIdSASL;
  public
    procedure Assign(Source: TPersistent); override;
  published
    property SASL : TIdSASL read FSASL write FSASL;
  end;
  TIdSASLEntries = class ( TOwnedCollection )
  protected
    function GetItem ( Index: Integer ) : TIdSASLListEntry;
    procedure SetItem ( Index: Integer; const Value: TIdSASLListEntry );
  public
    constructor Create ( AOwner : TPersistent ); reintroduce;
    function Add: TIdSASLListEntry;
    function LoginSASL(const ACmd: String;
      const AOkReplies, AContinueRplies: array of string;
      AClient : TIdTCPConnection;
      ACapaReply : TIdStrings;
      const AAuthString : String = 'AUTH'): Boolean;      {Do not Localize}
    function ParseCapaReply(ACapaReply: TIdStrings;
      const AAuthString: String = 'AUTH') : TIdStrings; {do not localize}
    function Insert(Index: Integer): TIdSASLListEntry;
    procedure RemoveByComp(AComponent : TComponent);
    function IndexOfComp(AItem : TIdSASL): Integer;
    property Items [ Index: Integer ] : TIdSASLListEntry read GetItem write
      SetItem; default;
  end;

  EIdSASLException = class(EIdException);
  EIdEmptySASLList = class(EIdSASLException);
  EIdSASLNotSupported = class(EIdSASLException);
  EIdSASLMechNeeded = class(EIdSASLException);
  // for use in implementing components
  TAuthenticationType = (atNone, atUserPass, atAPOP, atSASL);
  TAuthenticationTypes = set of TAuthenticationType;
  EIdSASLMsg = class(EIdException);
  EIdSASLNotValidForProtocol = class(EIdSASLMsg);

implementation

uses
  IdCoderMIME,
  IdGlobal,
  IdGlobalProtocols,
  SysUtils;

{ TIdSASLListEntry }

procedure TIdSASLListEntry.Assign(Source: TPersistent);
begin
  if Source is TIdSASLListEntry then
  begin
    FSASL := TIdSASLListEntry(Source).SASL;
  end
  else
  begin
    inherited;
  end;
end;

{ TIdSASLEntries }

function TIdSASLEntries.Add: TIdSASLListEntry;
begin
  Result := TIdSASLListEntry ( inherited Add );
end;

constructor TIdSASLEntries.Create(AOwner: TPersistent);
begin
   inherited Create ( AOwner, TIdSASLListEntry );
end;

function TIdSASLEntries.GetItem(Index: Integer): TIdSASLListEntry;
begin
  Result := TIdSASLListEntry ( inherited Items [ Index ] );
end;

function TIdSASLEntries.IndexOfComp(AItem: TIdSASL): Integer;
begin
  for Result := 0 to Count -1 do
  begin
    if Items[Result].FSASL = AItem then
    begin
      Exit;
    end;
  end;
  Result := -1;
end;

function TIdSASLEntries.Insert(Index: Integer): TIdSASLListEntry;
begin
  Result := Inherited Insert(Index) as TIdSASLListEntry;
end;

function TIdSASLEntries.LoginSASL(const ACmd: String; const AOkReplies,
  AContinueRplies: array of string; AClient: TIdTCPConnection;
  ACapaReply: TIdStrings; const AAuthString: String): Boolean;
var i : Integer;
  LSASLMechanisms: TIdSASLEntries;
  LE : TIdEncoderMIME;
  LD : TIdDecoderMIME;
  LSupportedSASL : TIdStrings;
  LS : TIdSASLListEntry;

  function CheckStrFail(const AStr : String; const AOk, ACont: array of string) : Boolean;
  begin
    Result := ( PosInStrArray (AStr,AOk)=-1) and
          (PosInStrArray(AStr,ACont)=-1)
  end;

begin
//  if (AuthenticationType = atSASL) and ((SASLMechanisms=nil) or (SASLMechanisms.Count = 0)) then begin
//    raise EIdSASLMechNeeded.Create(RSASLRequired);
//  end;
  Result := False;

    LSASLMechanisms := TIdSASLEntries.Create(nil);
    LE := TIdEncoderMIME.Create(nil);
    LD := TIdDecoderMIME.Create(nil);
    try
      LSupportedSASL := ParseCapaReply(ACapaReply);
      //create a list of supported mechanisms we also support
      for i := Count - 1 downto 0 do begin
        if Assigned(Items[i].FSASL) then
        begin
          if LSupportedSASL.IndexOf(Items[i].FSASL.ServiceName) >= 0 then begin
            LS := LSASLMechanisms.Add;
            LS.SASL.Assign(Items[i].SASL);
          end;
        end;
      end;
      //now do it
      for i := 0 to LSASLMechanisms.Count - 1 do begin
        AClient.SendCmd(ACmd+' '+LSASLMechanisms.Items[i].SASL.ServiceName,[]);//[334, 504]);
        if CheckStrFail(AClient.LastCmdResult.Code,AOkReplies,AContinueRplies) then begin
          break; // this mechanism is not supported, skip to the next
        end else begin
          if (PosInStrArray(AClient.LastCmdResult.Code,AOkReplies)>-1) then begin
            Result := True;
            break; // we've authenticated successfully :)
          end;
        end;
        AClient.SendCmd(LE.Encode(LSASLMechanisms.Items[i].SASL.StartAuthenticate(
          LD.DecodeString(TrimRight(AClient.LastCmdResult.Text.Text))
        )));
        if CheckStrFail(AClient.LastCmdResult.Code,AOkReplies,AContinueRplies) then
        begin
          AClient.RaiseExceptionForLastCmdResult;
        end;
        while PosInStrArray(AClient.LastCmdResult.Code,AContinueRplies)>-1 do begin
          AClient.SendCmd( LE.Encode(LSASLMechanisms.Items[i].SASL.ContinueAuthenticate(
            LD.DecodeString(TrimRight(AClient.LastCmdResult.Text.Text))
          )));
          if CheckStrFail(AClient.LastCmdResult.Code,AOkReplies,AContinueRplies) then
          begin
            AClient.RaiseExceptionForLastCmdResult;
          end;
        end;
        if PosInStrArray(AClient.LastCmdResult.Code,AOkReplies)>-1 then begin
          Result := True;
          break; // we've authenticated successfully :)
        end;
      end;
    finally
      FreeAndNil(LSupportedSASL);
      FreeAndNil(LSASLMechanisms);
      FreeAndNil(LE);
      FreeAndNil(LD);
    end;
end;

function TIdSASLEntries.ParseCapaReply(ACapaReply: TIdStrings;
  const AAuthString: String = 'AUTH'): TIdStrings; {do not localize}
var
  i: Integer;
  s: string;
  LEntry : String;

begin
  Result := TIdStringList.Create;
  for i := 0 to ACapaReply.Count - 1 do begin
    s := UpperCase(ACapaReply[i]);
    if TextIsSame(Copy(s, 1, Length(AAuthString)+1), AAuthString+' ') or TextIsSame(Copy(s, 1, Length(AAuthString)+1), AAuthString+'=') then begin    {Do not Localize}
      s := Copy(s, Length(AAuthString)+1, MaxInt);
      while Length(s) > 0 do begin
        s := StringReplace(s, '=', ' ', [rfReplaceAll]);    {Do not Localize}
        LEntry := Fetch(s, ' ');    {Do not Localize}
        if LEntry<>'' then
        begin
          if Result.IndexOf(LEntry) = -1 then begin
            Result.Add(LEntry);
          end;
        end;
      end;
    end;
  end;
end;

procedure TIdSASLEntries.RemoveByComp(AComponent: TComponent);
var i : Integer;
begin
  for i := Self.Count-1 downto 0 do
  begin
    if Items[i].FSASL = AComponent then
    begin
      Delete(i);
    end;
  end;
end;

procedure TIdSASLEntries.SetItem(Index: Integer;
  const Value: TIdSASLListEntry);
begin
  inherited SetItem ( Index, Value );
end;

end.

