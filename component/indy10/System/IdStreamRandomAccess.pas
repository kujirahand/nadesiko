{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  88162: IdStreamRandomAccess.pas 
{
{   Rev 1.1    2004.05.20 1:40:30 PM  czhower
{ Last of the IdStream updates
}
unit IdStreamRandomAccess;

interface

uses
  IdStream;

type
  TIdStreamRandomAccess = class(TIdStream)
  protected
    function GetPosition: Integer; virtual; abstract;
    function GetSize: Integer; virtual; abstract;
    procedure SetPosition(const AValue: Integer); virtual; abstract;
  public
    function BOF: Boolean; virtual;
    function EOF: Boolean; virtual;
    procedure Skip(
      ASize: Integer
      ); virtual; abstract;
    //
    property Position: Integer read GetPosition write SetPosition;
    property Size: Integer read GetSize;
  end;

implementation

{ TIdStreamRandomAccess }

function TIdStreamRandomAccess.BOF: Boolean;
begin
  Result := Position = 0;
end;

function TIdStreamRandomAccess.EOF: Boolean;
begin
  Result := Position >= Size - 1;
end;

end.
