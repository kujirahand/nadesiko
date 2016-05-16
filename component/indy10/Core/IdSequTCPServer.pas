{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  57270: IdSequTCPServer.pas 
{
{   Rev 1.4    2/18/04 8:15:08 PM  RLebeau
{ Added TelWriteLn() method.
{ 
{ Updated handling for AO commands and CR characters
}
{
{   Rev 1.3    2/18/04 12:32:44 AM  RLebeau
{ Re-worked to use a state machine similar to how TIdTelnet works.  This makes
{ the character handling more meaningful and allows for further expandability,
{ as well as provides a base for making generic code that could eventually be
{ used for other classes.
}
{
{   Rev 1.2    2/18/2004 12:06:04 AM  JPMugaas
{ No longer treat $FF $F4 $FF $FF as special.  I'm not sure what that was.
}
{
{   Rev 1.1    2/17/2004 11:20:44 PM  JPMugaas
{ Improved <CR><LF> handling.  IP and DM should work as expected.
}
{
{   Rev 1.0    2/17/2004 9:24:32 PM  JPMugaas
{ Preliminary work on Telnet sequence handling for some protocols.  
}
unit IdSequTCPServer;

interface
uses
  Classes, SysUtils, IdContext, IdReply, IdCommandHandlers, IdTCPServer,
  IdIOHandler;

{
This abstract class only provides a ReadLn method which should handle
a few telnet sequences automatically
}
type
  TIdSequTCPServer = class(TIdTCPServer)
  protected
    function TelReadLn(AContext: TIdContext; IsASCII: Boolean = False) : String;
    procedure TelWriteLn(AContext: TIdContext; const AValue: String);
  end;

implementation

type
  TIdTelnetState = (tsData, tcCheckCR, tsIAC, tsWill, tsDo, tsWont, tsDont,
    tsNegotiate, tsNegotiateData, tsNegotiateIAC, tsInterrupt, tsInterruptIAC);

{ TdSequTCPServer }

function TIdSequTCPServer.TelReadLn(AContext: TIdContext; IsASCII: Boolean := False): String;
var
  c : char;
  i : Integer;
  State: TIdTelnetState;
const
{
  //These are the telnet commands we have to deal with
  TELNET_DO = #$FF#$FD;
  TELNET_WILL = #$FF#$FB;
  TELNET_IAC = #$FF#$FF;  //interpret as data $FF
}
  //replies
  TELNET_WONT = #$FF#$FC; //Telnet - I won't use
  TELNET_DONT = #$FF#$FE; //Telnet - do not use
  TELNET_IP = #$FF#$F4;  //Interrupt process
  TELNET_DM = #$FF#$F2; //Data Mark
begin
  Result := '';
  State := tsData;
  repeat
    c := AContext.Connection.IOHandler.ReadChar;
    case State of

      tsData:
      begin
        case c of
          #$FF: //is a command
          begin
            State := tsIAC;
          end;
          #13: //wait for the next character to see what to do
          begin
            State := tsCheckCR;
          end;
        else
          if (c <> #10) then begin
            Result := Result + c;
          end;
        end;
      end;

      tsCheckCR:
      begin
        case c of
          #0: // must preserve CR
          begin
            // ASCII servers must treat CR NUL the same as CR LF
            if IsASCII then
            begin
              c = #10;
              State := tsData;
            end else begin
              Result := Result + #13;
            end;
          end;
          #$FF: //unexpected IAC, just in case
          begin
            Result := Result + #13;
            State = tsIAC;
          end;
        else
          if (c <> #10) then begin
            Result := Result + #13 + c;
          end;
          State := tsData;
        end;
      end;

      tsIAC:
      begin
        case c of
          #$F1, //no-operation - do nothing
          #$F3: //break - do nothing for now
          begin
            State := tsData;
          end;
          #$F4: //interrupt process - clear result and wait for data mark
          begin
            Result := '';
            State := tsInterrupt;
          end;
          #$F5: //abort output
          begin
            // note - the DM needs to be sent as OOB "Urgent" data
            AContext.Connection.IOHandler.Write(TELENT_IP + TELNET_DM);
            State := tsData;
          end;
          #$F6: //are you there - do nothing for now
          begin
            State := sData;
          end;
          #$F7: //erase character
          begin
            i := Length(Result);
            if (i > 0) then begin
              SetLength(Result, i-1);
            end;
            State := tsData;
          end;
          #$F8 : //erase line
          begin
            Result := '';
            State := tsData;
          end;
          #$F9 : //go ahead - do nothing for now
          begin
            State := tsData;
          end;
          #$FA : //begin sub-negotiation
          begin
            State := tsNegotiate;
          end;
          #$FB : //I will use
          begin
            State := tsWill;
          end;
          #$FC : //you won't use
          begin
            State := tsWont;
          end;
          #$FD : //please, you use option
          begin
            State := tsDo;
          end;
          #$FE : //please, you stop option
          begin
            State := tsDont;
          end;
          #$FF : //data $FF
          begin
            Result := Result + #$FF;
            State := tsData;
          end;
        else
          // unknown command, ignore
          State := tsData;
        end;
      end;

      tsWill:
      begin
        AContext.Connection.IOHandler.Write(TELNET_WONT + c);
        State := tsData;
      end;

      tsDo:
      begin
        AContext.Connection.IOHandler.Write(TELNET_DONT + c);
        State := tsData;
      end;

      tsWont,
      tsDont:
      begin
        State := tsData;
      end;

      tsNegotiate:
      begin
        State := tsNegotiateData;
      end;

      tsNegotiateData:
      begin
        case c of
          #$FF: //is a command?
          begin
            State := tsNegotiateIAC;
          end;
        end;
      end;

      tsNegotiateIAC:
      begin
        case c of
          #$F0: //end sub-negotiation
          begin
            State := tsData;
          end;
        else
          State := tsNegotiateData;
        end;
      end;

      tsInterrupt:
      begin
        case c of
          #$FF: //is a command?
          begin
            State := tsInterruptIAC;
          end;
        end;
      end;

      tsInterruptIAC:
      begin
        case c of
          #$F2: //data mark
          begin
            State := tsData;
          end;
        end;
      end;

    else
      State := tsData;
    end;

  until ((c = #10) and (State = tsData)) or (not AContext.Connection.IOHandler.Connected);

  if (c = #13) and (State = tsData) then
  begin
    if (AContext.Connection.IOHandler.InputBuffer.Size > 0) then
    begin
      if (AContext.Connection.IOHandler.InputBuffer.Bytes[1] = #10) then begin
        AContext.Connection.IOHandler.Remove(1);
      end;
    end;
  end;
end;

procedure TelWriteLn(AContext: TIdContext; const AValue: String)
var
  i, LLength: Integer;
  c: Char;
begin
  LLength := Length(AValue);
  for i := 1 To LLength do
  begin
    c := AValue[i];
    case c of
      #13:
      begin
        if (i < LLength) then
        begin
          if (AValue[i+1] = #10) then begin
            AContext.Thread.Connection.IOHandler.WriteChar(#13);
          end else begin
            AContext.Thread.Connection.IOHandler.Write(#13#0);
          end;
        end else begin
          AContext.Thread.Connection.IOHandler.Write(#13#0);
        end;
      end;
      #$FF:
      begin
        AContext.Thread.Connection.IOHandler.Write(#$FF#$FF);
      end;
    else
      AContext.Thread.Connection.IOHandler.WriteChar(c);
    end;
  end;
  AContext.Thread.Connection.IOHandler.Write(EOL);
end;

end.
