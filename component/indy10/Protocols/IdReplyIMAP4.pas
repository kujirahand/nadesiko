{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  19404: IdReplyIMAP4.pas
{
{   Rev 1.23    10/26/2004 10:39:54 PM  JPMugaas
{ Updated refs.
}
{
    Rev 1.22    6/11/2004 9:38:30 AM  DSiders
  Added "Do not Localize" comments.
}
{
{   Rev 1.21    5/17/04 9:53:00 AM  RLebeau
{ Changed TIdRepliesIMAP4 constructor to use 'reintroduce' instead
}
{
{   Rev 1.20    5/16/04 5:31:24 PM  RLebeau
{ Added constructor to TIdRepliesIMAP4 class
}
{
{   Rev 1.19    03/03/2004 01:16:56  CCostelloe
{ Yet another check-in as part of continuing development
}
{
{   Rev 1.18    26/02/2004 02:02:22  CCostelloe
{ A few updates to support IdIMAP4Server development
}
{
{   Rev 1.17    05/02/2004 00:26:06  CCostelloe
{ Changes to support TIdIMAP4Server
}
{
{   Rev 1.16    2/3/2004 4:12:34 PM  JPMugaas
{ Fixed up units so they should compile.
}
{
{   Rev 1.15    2004.01.29 12:07:52 AM  czhower
{ .Net constructor problem fix.
}
{
{   Rev 1.14    1/3/2004 8:05:48 PM  JPMugaas
{ Bug fix:  Sometimes, replies will appear twice due to the way functionality
{ was enherited.
}
{
{   Rev 1.13    22/12/2003 00:45:40  CCostelloe
{ .NET fixes
}
{
{   Rev 1.12    03/12/2003 09:48:34  CCostelloe
{ IsItANumber and IsItAValidSequenceNumber made public for use by TIdIMAP4.
}
{
{   Rev 1.11    28/11/2003 21:02:46  CCostelloe
{ Fixes for Courier IMAP
}
{
{   Rev 1.10    22/10/2003 12:18:06  CCostelloe
{ Split out DoesLineHaveExpectedResponse for use by other functions in IdIMAP4.
}
{
    Rev 1.9    10/19/2003 5:57:12 PM  DSiders
  Added localization comments.
}
{
{   Rev 1.8    18/10/2003 22:33:00  CCostelloe
{ RemoveUnsolicitedResponses added.
}
{
{   Rev 1.7    20/09/2003 19:36:42  CCostelloe
{ Multiple changes to clear up older issues
}
{
{   Rev 1.6    2003.09.20 10:38:40 AM  czhower
{ Bug fix to allow clearing code field (Return to default value)
}
{
{   Rev 1.5    18/06/2003 21:57:00  CCostelloe
{ Rewrote SetFormattedReply.  Compiles and works.  Needs tidying up, as does
{ IdIMAP4.
}
{
{   Rev 1.4    17/06/2003 01:38:12  CCostelloe
{ Updated to suit LoginSASL changes.  Compiles OK.
}
{
{   Rev 1.3    15/06/2003 08:41:48  CCostelloe
{ Bug fix: i was undefined in SetFormattedReply in posted version, changed to LN
}
{
{   Rev 1.2    12/06/2003 10:26:14  CCostelloe
{ Unfinished but compiles.  Checked in to show problem with Get/SetNumericCode.
}
{
{   Rev 1.1    6/5/2003 04:54:26 AM  JPMugaas
{ Reworkings and minor changes for new Reply exception framework.
}
{
{   Rev 1.0    5/27/2003 03:03:54 AM  JPMugaas
}
unit IdReplyIMAP4;

{
  2003-Sep-26: CC2: Added Extra property.
  2003-Oct-18: CC3: Added RemoveUnsolicitedResponses function.
  2003-Nov-28: CC4: Fixes for Courier IMAP server.
}

interface
uses
  Classes,
  IdReply,
  IdReplyRFC,
  IdTStrings;

const
  IMAP_OK      = 'OK';      {Do not Localize}
  IMAP_NO      = 'NO';      {Do not Localize}
  IMAP_BAD     = 'BAD';     {Do not Localize}
  IMAP_PREAUTH = 'PREAUTH'; {Do not Localize}
  IMAP_BYE     = 'BYE';     {Do not Localize}
  IMAP_CONT    = '+';       {Do not Localize}

  VALID_TAGGEDREPLIES : array [0..5] of string =
    (IMAP_OK, IMAP_NO, IMAP_BAD, IMAP_PREAUTH, IMAP_BYE, IMAP_CONT);

type
  TIdReplyIMAP4 = class(TIdReply)
  protected
    {CC: A tagged IMAP response is 'C41 OK Completed', where C41 is the
    command sequence number identifying the command you sent to get that
    response.  An untagged one is '* OK Bad parameter'.  The codes are
    the same, some just start with *.
    FSequenceNumber is either a *, C41 or '' (if the response line starts with
    a valid response code like OK)...}
    FSequenceNumber: string;
    {IMAP servers can send extra info after a command like "BAD Bad parameter".
    Keep these for error messages (may be more than one).}
    FExtra: TIdStrings;
    function GetExtra: TIdStrings;  //Added to get over .NET not calling TIdReplyIMAP4's constructor
    {You would think that we need to override IdReply's Get/SetNumericCode
    because they assume the code is like '32' whereas IMAP codes are text like
    'OK' (when IdReply's StrToIntDef always returns 0), but Indy 10 has switched
    from numeric codes to string codes (i.e. we use 'OK' and never a
    numeric equivalent like 4).}
    {function GetNumericCode: Integer;
    procedure SetNumericCode(const AValue: Integer);}
    {Get/SetFormattedReply need to be overriden for IMAP4}
    function GetFormattedReply: TIdStrings; override;
    procedure SetFormattedReply(const AValue: TIdStrings); override;
    {CC: Need this also, otherwise the virtual one in IdReply uses
    TIdReplyRFC.CheckIfCodeIsValid which will only convert numeric
    codes like '22' to integer 22.}
    function CheckIfCodeIsValid(const ACode: string): Boolean; override;
    {The Indy10 version that hopefully deals with all TIdIMAP's possibilities...}
    { Moved back to IdIMAP4...
    function GetResponse: string;
    }
  public
    constructor Create(
      ACollection: TCollection = nil;
      AReplyTexts: TIdReplies = nil
      ); override;
    procedure Clear; override;
    //
    //CLIENT-SIDE (TIdIMAP4) FUNCTIONS...
    //procedure RaiseReplyError(ADescription: string; AnOffendingLine: string = ''); reintroduce;
    procedure RaiseReplyError; override;
    procedure DoReplyError(ADescription: string; AnOffendingLine: string = ''); reintroduce;
    procedure RemoveUnsolicitedResponses(AExpectedResponses: array of String);
    function DoesLineHaveExpectedResponse(ALine: string; AExpectedResponses: array of string): Boolean;
    {CC: The following decides if AThing is a valid command sequence number
    like C41...}
    function IsItAValidSequenceNumber(const AThing: string): Boolean;
    {CC2: The following determines if AText consists only of digits...}
    function IsItANumber(const AThing: string): Boolean;
    //
    //SERVER-SIDE (TIdIMAP4Server) FUNCTIONS...
    function ParseRequest(ARequest: string): Boolean;
    //
    property NumericCode: Integer read GetNumericCode write SetNumericCode;
    //property Extra: TIdStrings read FExtra;
    property Extra: TIdStrings read GetExtra;
    property SequenceNumber: string read FSequenceNumber;
    //
    //Added to stop constructor giving run-time error
    procedure SetReply(const ACode: Integer; const AText: string); override;
  end;

  TIdRepliesIMAP4 = class(TIdReplies)
  public
    constructor Create(AOwner: TPersistent); reintroduce;
  end;

  //This error method came from the POP3 Protocol reply exceptions
  // SendCmd / GetResponse
  EIdReplyIMAP4Error = class(EIdReplyError)
  {protected
    FErrorCode : String;}
  public
    {constructor CreateError(const AErrorCode: String; const AReplyMessage: string); reintroduce; virtual;}
    constructor CreateError(const AReplyMessage: string); {reintroduce; virtual;}
    {property ErrorCode : String read FErrorCode;}
  end;

implementation
uses IdGlobal, IdGlobalProtocols, SysUtils;

{ TIdReplyIMAP4 }
{
function TIdReplyIMAP4.GetNumericCode: Integer;
begin
  {Result := StrToIntDef(Code, 0);}
{  Result := PosInStrArray(Code,VALID_TAGGEDREPLIES) + 1;
end;
}
{
procedure TIdReplyIMAP4.SetNumericCode(const AValue: Integer);
begin
  {FCode := IntToStr(AValue);}
{  FCode := VALID_TAGGEDREPLIES[AValue-1];
end;
}

function TIdReplyIMAP4.ParseRequest(ARequest: string): Boolean;
begin
  FSequenceNumber := Fetch(ARequest, #32);
  Result := False;
  if IsItAValidSequenceNumber(FSequenceNumber) then begin
    Result := True;
  end;
end;

function TIdReplyIMAP4.GetExtra: TIdStrings;
begin
  if not assigned(FExtra) then begin
    FExtra := TIdStringList.Create;
  end;
  Result := FExtra;
end;

constructor TIdReplyIMAP4.Create(
      ACollection: TCollection = nil;
      AReplyTexts: TIdReplies = nil
      );
begin
  inherited;
  FExtra := TIdStringList.Create;
  Clear;
end;

procedure TIdReplyIMAP4.Clear;
begin
  inherited Clear;
  FSequenceNumber := '';
  //FExtra.Clear;
  Extra.Clear;
end;

procedure TIdReplyIMAP4.RaiseReplyError;
begin
  raise EIdReplyIMAP4Error.CreateError('Default RaiseReply error'); {do not localize}
end;

function TIdReplyIMAP4.IsItANumber(const AThing: string): Boolean;
var
    LN: integer;
begin
    Result := False;
    for LN := 1 to Length(AThing) do begin
        if ( (Ord(AThing[LN]) < Ord('0')) or (Ord(AThing[LN]) > Ord('9')) ) then begin  {Do not Localize}
            Exit;
        end;
    end;
    Result := True;
end;

function TIdReplyIMAP4.IsItAValidSequenceNumber(const AThing: string): Boolean;
    {CC: The following decides if AThing is a valid command sequence number
    like C41...}
begin
    Result := False;
    {CC: Cannot be a C or a digit on its own...}
    if Length(AThing) < 2 then begin
        Exit;
    end;
    {CC: Must start with a C...}
    if AThing[1] <> 'C' then begin  {Do not Localize}
        Exit;
    end;
    {CC: Check if other characters are digits...}
    Result := IsItANumber(Copy(AThing, 2, MAXINT));
end;

function TIdReplyIMAP4.CheckIfCodeIsValid(const ACode: string): Boolean;
var
  LOrd : Integer;
begin
  LOrd := {IdGlobal.}PosInStrArray(ACode, VALID_TAGGEDREPLIES, False);
  Result := (LOrd <> -1) or (Trim(ACode) = '');
end;

function TIdReplyIMAP4.GetFormattedReply: TIdStrings;
begin
  {Used by TIdIMAP4Server to assemble a string reply from our fields...}
  //Result := GetFormattedReplyStrings;
  FFormattedReply.Clear;
  //FFormattedReply.Add('Doh, why was this outputted?');
  Result := FFormattedReply;
end;

procedure TIdReplyIMAP4.SetFormattedReply(const AValue: TIdStrings);
{CC: AValue may be in one of a few formats:
1) Many commands just give a simple result to the command issued:
    C41 OK Completed
2) Some commands give you data first, then the result:
    * LIST (\UnMarked) "/" INBOX
    * LIST (\UnMarked) "/" Junk
    * LIST (\UnMarked) "/" Junk/Subbox1
    C42 OK Completed
3) Some responses have a result but * instead of a command number (like C42):
    * OK CommuniGate Pro IMAP Server 3.5.7 ready
4) Some have neither a * nor command number, but start with a result:
    + Send the additional command text
or:
    BAD Bad parameter

Because you may get data first, which you need to put into Text, you need to
accept all the above possibilities.

Again, is that messy enough for you?

In this function, we can assume that the last line of AValues has previously been
identified (by GetResponse).

For the Text parameter, data lines are added with the starting * stripped off.
The last Text line is the response line (the OK, BAD, etc., line) with any *
and response (OK, BAD) stripped out - this is usefully just Completed or the
error message.

Set FSequenceNumber to C41 for cases (1) and (2) above, * for case (3), and
empty '' for case 4.  This tells the caller the context of the reply.
}
label
    TryAgain;
var
    LWord: string;
    LPos: integer;
    LBuf : String;
    LN: integer;
    LLine: string;
begin
    Clear;
    LWord := '';
    if AValue.Count <= 0 then begin
        {Throw an exception.  Something is badly messed up if we were called with
        an empty string list.}
        DoReplyError('Unexpected: Logic error, SetFormattedReply called with an empty list of parameters');  {do not localize}
    end else begin
        {CC: Any lines before the last one should be data lines, which begin with
        a * ...}
        for LN := 0 to AValue.Count - 2 do begin
            LLine := AValue[LN];
            if LLine <> '' then begin
                LPos := Pos(' ', LLine); {Do not Localize}
                if LPos <> 0 then begin
                    LWord := Trim(Copy(LLine, 1, LPos-1));
                    if LWord = '*' then begin {Do not Localize}
                        LLine := Trim(Copy(LLine, LPos+1, MaxInt));
                        Text.Add(LLine);
                    end else begin
                        //Throw an exception: No * as first word of a data line.
                        DoReplyError('Unexpected: Non-last response line (i.e. a data line) did not start with a *', AValue[LN]);  {do not localize}
                    end;
                end else begin
                    {Throw an exception: No space, so this line is a single word,
                    not a valid data line since it does not have a * plus at least
                    one word of data.}
                    DoReplyError('Unexpected: Non-last response line (i.e. a data line) only contained one word, instead of a * followed by one or more words', AValue[LN]); {do not localize}
                end;
            end;
        end;
        {The response (OK, BAD, etc.) is in the LAST line received (or else the
        function that got the response, such as GetResponse, is broken).}
        LLine := AValue[AValue.Count-1];
        if LLine = '' then begin
            {Throw an exception: The previous function (GetResponse, or whatever)
            messed up and passed an empty line as the response (last) line...}
            DoReplyError('Unexpected: Response (last) line was empty instead of containing a line with a response code like OK, NO, BAD, etc');  {do not localize}
        end else begin
            LPos := Pos(' ', LLine); {Do not Localize}
            if LPos <> 0 then begin
                {There are at least two words on this line...}
                LWord := Trim(Copy(LLine, 1, LPos-1));
                LBuf := Trim(Copy(LLine, LPos+1, MaxInt));  {The rest of the line, without the 1st word}
            end else begin
                {No space, so this line is a single word.  A bit weird, but it
                could be just an OK...}
                LWord := LLine;  {A bit pedantic, but emphasises we have a word, not a line}
                LBuf := '';
            end;
            {We can assume, if the previous function (GetResponse) did its
            job, that either the first or the second word (if it exists) is the
            response code...}
            LPos := PosInStrArray(LWord, VALID_TAGGEDREPLIES); {Do not Localize}
            if LPos > -1 then begin
                {The first word is a valid response.  Leave FSequenceNumber as ''
                because there was nothing before it.}
                Code := LWord;
                Text.Add(LBuf);
            end else if LWord = '*' then begin  {Do not Localize}
                if LBuf = '' then begin
                    {Throw an exception: it is a line that is just '*'}
                    DoReplyError('Unexpected: Response (last) line contained only a *'); {do not localize}
                end;
                FSequenceNumber := LWord;   {Record that it is a * line}
                {The next word had better be a response...}
                LPos := Pos(' ', LBuf); {Do not Localize}
                if LPos <> 0 then begin
                    LWord := Trim(Copy(LBuf, 1, LPos-1));
                    LBuf := Trim(Copy(LBuf, LPos+1, MaxInt));  {The rest of the line, without the 1st word}
                end else begin
                    {Should never get to here: LBuf should have been ''.  Might as
                    well throw an exception since we are down here anyway.}
                    DoReplyError('Unexpected: Response (last) line contained only a * (type 2)');  {do not localize}
                end;
                LPos := PosInStrArray(LWord, VALID_TAGGEDREPLIES); {Do not Localize}
                if LPos > -1 then begin {Do not Localize}
                    {A valid resonse code...}
                    Code := LWord;
                    Text.Add(LBuf);
                end else begin
                    {A line beginning with * but no valid response code as the 2nd
                    word.  It is invalid, but maybe a data line that GetResponse
                    missed.  Throw an exception anyway.}
                    DoReplyError('Unexpected: Response (last) line started with a * but next word was not a valid response like OK, BAD, etc', LLine); {do not localize}
                end;
            end else if IsItAValidSequenceNumber(LWord) = True then begin
                if LBuf = '' then begin
                    {Throw an exception: it is a line that is just 'C41' or whatever}
                    DoReplyError('Unexpected: Response (last) line started with a command reference (like C41) but nothing else', LLine);  {do not localize}
                end;
                FSequenceNumber := LWord;   {Record that it is a C41 line}
                {The next word had better be a response...}
                LPos := Pos(' ', LBuf); {Do not Localize}
                if LPos <> 0 then begin
                    LWord := Trim(Copy(LBuf, 1, LPos-1));
                    LBuf := Trim(Copy(LBuf, LPos+1, MaxInt));  {The rest of the line, without the 1st word}
                end else begin
                    {Should never get to here: LBuf should have been ''.  Might as
                    well throw an exception since we are down here anyway.}
                    DoReplyError('Unexpected: Logic error, line starts with a command reference (like C41) but nothing else, why was an exception not thrown earlier?', LLine);  {do not localize}
                end;
                LPos := PosInStrArray(LWord,VALID_TAGGEDREPLIES); {Do not Localize}
                if LPos > -1 then begin {Do not Localize}
                    {A valid response code...}
                    Code := LWord;
                    //CC4: LBuf will contain "SEARCH completed" if LLine was "C64 OK SEARCH completed".
                    //Ditch LBuf, otherwise we will confuse the later parser that checks for
                    //"expected response" keywords.
                    //Text.Add(LBuf);
                    Extra.Add(LBuf);
                end else begin
                    {A line beginning with C41 but no valid response code as the 2nd
                    word.  Throw an exception.}
                    DoReplyError('Unexpected: Line starts with a command reference (like C41) but next word was not a valid response like OK, BAD, etc', LLine); {do not localize}
                end;
            end else begin
                {Not a response, * or command (e.g. C41).  Throw an exception, as usual.}
                DoReplyError('Unexpected: Line does not start with a command reference (like C41), a *, or a valid response like OK, BAD, etc', LLine);  {do not localize}
            end;
        end;
        {if LWord = '' then begin}
        if Code = '' then begin
            {Did not get a valid response line, copy ALL of the last line we received
            into Text[] for error display.  This is paranoid programming, we probably
            would have thrown an exception by now.}
            Text.Add(AValue[AValue.Count-1]);
        end;
        {The worry I now have is that the IMAP server may have thrown in a
        line like "BAD Bad parameter", even after an OK or BAD response.  Pull
        anything that is lying around in the stack.}
        {For the moment, the 1 is the timeout.  Should maybe use three times the time it
        takes the server to respond to a NOOP?  Criminally wasteful of processor
        time, but what else do you do with IMAP servers?}
        { TO DO: Following gives a weird error...
      TryAgain:
        LLine := ReadLn(LF, 1, -1);
        if LLine <> '' then begin
            FExtra.Add(LLine);
            goto TryAgain;
        end;
        }
    end;
end;

procedure TIdReplyIMAP4.RemoveUnsolicitedResponses(AExpectedResponses: array of String);
    {CC3: This goes through the lines in Text and moves any that are not "expected" into
    Extra.  Lines that are "expected" are those that have a command in one of the
    strings in AExpectedResponses, which has entries like "FETCH", "UID", "LIST".
    Unsolicited responses are typically lines like "* RECENT 3", which are sent by
    the server to tell you that new messages arrived.  The problem is that they can
    be anywhere in a reply from the server, the RFC does not stipulate where, or
    what their format may be, but they wont be expected by the caller and will cause
    the caller's parsing to fail.
    The Text variable also has the bits stripped off from the final response, i.e.
    it will have "Completed" as the last entry, stripped from "C62 OK Completed".}
var
    LLine: string;
    LN, LIndex: integer;
    LLast: integer;  {Need to calculate this outside the loop}
begin

    {The (valid) lines are of one of two formats:
    * LIST BlahBlah
    * 53 FETCH BlahBlah
    The "53" arises with commands that reference a specific email, the server returns
    the relative message number in that case.
    Note the * has been stripped off before this procedure is called.}
    LLast := Text.Count-1;
    LIndex := 0;
    for LN := 0 to LLast do begin
        LLine := Text[LIndex];
        if LLine = '' then begin
            {Unlikely to happen, but paranoia is always a better approach...}
            Text.Delete(LIndex);
        end else begin
            if DoesLineHaveExpectedResponse(LLine, AExpectedResponses) then begin
                {We were expecting this word, so don't remove this line.}
                Inc(LIndex);
                continue;
            end;
            {We were not expecting this response, it is an unsolicited response or
            something else we are not interested in.  Transfer the UNSTRIPPED
            line to Extra (i.e. not LLine).}
            Extra.Add(Text[LIndex]);
            Text.Delete(LIndex);
        end;
    end;
end;

function TIdReplyIMAP4.DoesLineHaveExpectedResponse(ALine: string; AExpectedResponses: array of string): Boolean;
var
    LWord: string;
    LPos: integer;
begin
    Result := False;
    {Get the first word, it may be a relative message number like "53".
    CC4: Note the line may only consist of a single word, e.g. "SEARCH" with some
    servers (e.g. Courier) where there were no matches to the search.}
    LPos := Pos(' ', ALine); {Do not Localize}
    if LPos > 0 then begin
        if IsItANumber(Copy(ALine, 1, LPos-1)) then begin
            ALine := Copy(ALine, LPos+1, MAXINT);
        end;
        {If there was a relative message number, it is now stripped from LLine.}
        {The first word in LLine is the one that may hold our expected response.}
        LPos := Pos(' ', ALine);    {Do not Localize}
        if LPos > 0 then begin
            LWord := Copy(ALine, 1, LPos-1);
        end else begin
            LWord := ALine;
        end;
    end else begin
        LWord := ALine;
    end;
        if PosInStrArray(LWord, AExpectedResponses) > -1 then begin
            {We were expecting this word...}
            Result := True;
        end;
    //end;
end;

//procedure TIdReplyIMAP4.RaiseReplyError(ADescription: string; AnOffendingLine: string);
procedure TIdReplyIMAP4.DoReplyError(ADescription: string; AnOffendingLine: string);
var
    LMsg: string;
begin
    {raise EIdReplyIMAP4Error.CreateError(Code,Text.Text);}
    LMsg := ADescription;
    if AnOffendingLine <> '' then begin
        LMsg := LMsg + ', offending line: '+AnOffendingLine;  {do not localize}
    end;
    raise EIdReplyIMAP4Error.CreateError(LMsg);
end;

procedure TIdReplyIMAP4.SetReply(const ACode: Integer; const AText: string);
//This is only here to stop constructor giving a run-time error
begin
  //Code := ACode;
  Code := 'OK'; {do not localize}
  FText.Text := AText;
end;

{ TIdRepliesIMAP4 }

constructor TIdRepliesIMAP4.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TIdReplyIMAP4);
end;

{ EIdReplyIMAP4Error }

{constructor EIdReplyIMAP4Error.CreateError(const AErrorCode, AReplyMessage: string);}
constructor EIdReplyIMAP4Error.CreateError(const AReplyMessage: string);
begin
  inherited Create(AReplyMessage);
  {FErrorCode := AErrorCode;}
end;

end.

