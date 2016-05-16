{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  88132: IdStreamVCLDotNET.pas
{
{   Rev 1.9    27.08.2004 22:02:24  Andreas Hausladen
{ Speed optimization ("const" for string parameters)
{ rewritten PosIdx function with AStartPos = 0 handling
{ new ToArrayF() functions (faster in native code because the TIdBytes array
{ must have the required len before the ToArrayF function is called)
}
{
{   Rev 1.8    7/2/04 12:49:26 PM  RLebeau
{ Bug fix for ReadString()
}
{
{   Rev 1.7    6/12/04 12:15:48 PM  RLebeau
{ Updated ReadBytes() to set the length of the caller's buffer if it is too
{ small
}
{
{   Rev 1.6    2004.06.03 10:22:20 PM  czhower
{ Bug fix with -1 length to ReadBytes.
}
{
{   Rev 1.5    5/24/2004 10:56:56 AM  JPMugaas
{ Should compile properly.
}
{
    Rev 1.4    5/22/2004 1:06:48 PM  DSiders
  Removed System.IO from the interface uses clause.  Moved to IdStream.pas.
}
{
{   Rev 1.3    2004.05.20 3:23:36 PM  czhower
{ Moved implicit operators
}
{
{   Rev 1.2    2004.05.20 1:40:22 PM  czhower
{ Last of the IdStream updates
}
{
{   Rev 1.1    2004.05.20 12:15:38 PM  czhower
{ IdStream completion
}
unit IdStreamVCLDotNET;

interface

uses
  IdGlobal, IdStreamVCLBase;

type
  TIdStreamVCLDotNET = class(TIdStreamVCLBase)
  public
    function ReadBytes(
      var VBytes: TIdBytes;
      ACount: Integer = -1;
      AOffset: Integer = 0;
      AExceptionOnCountDiffer: Boolean = True
      ): Integer; override;
    function ReadString: string; override;
    procedure Write(
      const AValue: string
      ); overload; override;
    procedure Write(
      const ABytes: TIdBytes;
      ACount: Integer = -1
      ); overload; override;
  end;

implementation

uses
  IdException, IdResourceStrings;

procedure TIdStreamVCLDotNET.Write(const AValue: string);
begin
  Write(ToBytes(AValue));
end;

procedure TIdStreamVCLDotNET.Write( const ABytes: TIdBytes; ACount: Integer = -1
      );
begin
  if ACount = -1 then begin
    ACount := Length(ABytes);
  end;
  VCLStream.WriteBuffer(ABytes, ACount);
end;

function TIdStreamVCLDotNET.ReadBytes(var VBytes: TIdBytes; ACount,
  AOffset: Integer; AExceptionOnCountDiffer: Boolean): Integer;
begin
  if ACount = -1 then begin
    ACount := VCLStream.Size - VCLStream.Position;
  end;
  if Length(VBytes) < (AOffset+ACount) then begin
    SetLength(VBytes, AOffset+ACount);
  end;
  Result := VCLStream.Read(VBytes, AOffset, ACount);
  EIdException.IfTrue(AExceptionOnCountDiffer and (Result <> ACount), RSStreamNotEnoughBytes);
end;

function TIdStreamVCLDotNET.ReadString: string;
var
  L: Integer;
  LBytes: TIdBytes;
Begin
  L := ReadInteger;
  if L > 0 then begin
    ReadBytes(LBytes, L);
    Result := BytesToString(LBytes);
  end else begin
    Result := '';
  end;
end;

end.

