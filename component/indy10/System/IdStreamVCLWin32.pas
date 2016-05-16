{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  88135: IdStreamVCLWin32.pas 
{
{   Rev 1.7    27.08.2004 22:02:24  Andreas Hausladen
{ Speed optimization ("const" for string parameters)
{ rewritten PosIdx function with AStartPos = 0 handling
{ new ToArrayF() functions (faster in native code because the TIdBytes array
{ must have the required len before the ToArrayF function is called)
}
{
{   Rev 1.6    8/10/04 8:41:46 PM  RLebeau
{ Updated Write(TIdBytes) to not try to write more than the TIdBytes actually
{ contains.
}
{
{   Rev 1.5    6/29/04 12:20:42 PM  RLebeau
{ Updated Write() to check the string length before referencing the string data
}
{
{   Rev 1.4    6/12/04 12:15:48 PM  RLebeau
{ Updated ReadBytes() to set the length of the caller's buffer if it is too
{ small
}
{
{   Rev 1.3    2004.06.03 10:22:20 PM  czhower
{ Bug fix with -1 length to ReadBytes.
}
{
{   Rev 1.2    2004.05.20 1:40:24 PM  czhower
{ Last of the IdStream updates
}
{
{   Rev 1.1    2004.05.20 12:15:38 PM  czhower
{ IdStream completion
}
unit IdStreamVCLWin32;

interface

uses
  IdGlobal, IdStreamVCLBase;

type
  TIdStreamVCLWin32 = class(TIdStreamVCLBase)
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

{ TIdStreamVCLWin32 }

procedure TIdStreamVCLWin32.Write(const AValue: string);
var
  LLen: Integer;
begin
  LLen := Length(AValue);
  if LLen > 0 then begin
    VCLStream.WriteBuffer(AValue[1], LLen);
  end;
end;

function TIdStreamVCLWin32.ReadBytes(var VBytes: TIdBytes; ACount,
  AOffset: Integer; AExceptionOnCountDiffer: Boolean): Integer;
begin
  if ACount = -1 then begin
    ACount := VCLStream.Size - VCLStream.Position;
  end;
  if Length(VBytes) < (AOffset+ACount) then begin
    SetLength(VBytes, AOffset+ACount);
  end;
  Result := VCLStream.Read(VBytes[AOffset], ACount);
  EIdException.IfTrue(AExceptionOnCountDiffer and (Result <> ACount), RSStreamNotEnoughBytes);
end;

function TIdStreamVCLWin32.ReadString: string;
var
  L: Integer;
Begin
  L := ReadInteger;
  if L > 0 then begin
    SetString(Result, nil, L);
    VCLStream.ReadBuffer(Pointer(Result)^, L);
  end else begin
    Result := '';
  end;
end;

procedure TIdStreamVCLWin32.Write(const ABytes: TIdBytes; ACount: Integer);
begin
  if ABytes <> nil then begin
    if ACount = -1 then begin
      ACount := Length(ABytes);
    end else begin
      ACount := Min(ACount, Length(ABytes));
    end;
    if ACount > 0 then begin
      VCLStream.WriteBuffer(ABytes[0], ACount);
    end;
  end;
end;

end.
