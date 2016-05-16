{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  88129: IdStream.pas
{
{   Rev 1.8    27.08.2004 22:02:22  Andreas Hausladen
{ Speed optimization ("const" for string parameters)
{ rewritten PosIdx function with AStartPos = 0 handling
{ new ToArrayF() functions (faster in native code because the TIdBytes array
{ must have the required len before the ToArrayF function is called)
}
{
{   Rev 1.7    2004.08.13 11:14:06  czhower
{ Fixed compile error with implicit overloads
}
{
{   Rev 1.6    6/13/04 12:26:00 AM  RLebeau
{ Bug fix for ReadInteger() passing the wrong arguments to ReadBytes()
}
{
{   Rev 1.5    6/12/04 12:16:26 PM  RLebeau
{ Updated ReadInteger() to call ReadBytes() with the AAppend parameter set to
{ False
}
{
    Rev 1.4    5/22/2004 1:06:02 PM  DSiders
  Added IFDEF for System.IO in the interface uses for .Net.
}
{
{   Rev 1.3    2004.05.20 3:23:36 PM  czhower
{ Moved implicit operators
}
{
{   Rev 1.2    2004.05.20 1:40:20 PM  czhower
{ Last of the IdStream updates
}
{
{   Rev 1.1    2004.05.20 12:15:36 PM  czhower
{ IdStream completion
}
unit IdStream;

{
Note:

IFDEFs allowed in this tree because of necessary differences in calls to TStream

Im not fond of IdStream, but it was necessary before unless we made really poor
implementations for readln and more. And with the way Borland implemented TStream
methods in .Net and made the indexes different, we are really screwed if we try
to use TStream. This IdStream will be expanded and used even more.

Currently for .NET we implement an implicit type convertor to TStream in
Classes.pas (Custom mod).

A few options exist to solve all issues:

1) Add overloads for TStream everywehre TIdStreamVCL is accepted.

2) Add an implicit conversion for System.IO.Stream to TIdStreamVCL.
This still requires TStream users to convert manually however.

3) Move EVERY internal reference of TStream to TIdStreamVCL and implement two
polymorhpic versions - one for .net and one for VCL. This solves all issues
except the conversion from TStream to TIdStreamVCL. Users would need to manually
do this. We could add overloads - but this will keep our dependence on RTL which
we are trying to lessen and also add a lot of overloads.

As a temporary solution I have added an implicit conversion for .NET.
}

interface

uses
  Classes,
  {$IFDEF DotNet}
  System.IO,
  {$ENDIF}
  IdGlobal;

type
  TIdStream = class(TObject)
  public
    {$IFDEF DotNet}
    class operator Implicit(AValue: System.IO.Stream): TIdStream;
    class operator Implicit(AValue: TStream): TIdStream;
    {$ENDIF}
    function ReadBytes(
      var VBytes: TIdBytes;
      ACount: Integer = -1;
      AOffset: Integer = 0;
      AExceptionOnCountDiffer: Boolean = True
      ): Integer; virtual; abstract;
    function ReadInteger: Integer; virtual;
    function ReadLn(AMaxLineLength: Integer = -1; AExceptionIfEOF: Boolean = FALSE): String;
     virtual; abstract;
    function ReadString: string; virtual; abstract;
    procedure Write(
      const AValue: string
      ); overload; virtual; abstract;
    procedure Write(
      const ABytes: TIdBytes;
      ACount: Integer = -1
      ); overload; virtual; abstract;
    procedure Write(AValue: Integer); overload;
    procedure WriteLn(const AData: string = ''); overload;
    procedure WriteLn(const AData: string; AArgs: array of const); overload;
  end;

implementation

uses
  IdStreamVCL, IdStack,
  SysUtils;

{ TIdStream }

{$IFDEF DotNet}
class operator TIdStream.Implicit(AValue: System.IO.Stream): TIdStream;
begin
  Result := TIdStreamVCL.Create(TCLRStreamWrapper.Create(AValue), True);
end;

class operator TIdStream.Implicit(AValue: TStream): TIdStream;
begin
  Result := TIdStreamVCL.Create(AValue, True);
end;
{$ENDIF}

procedure TIdStream.WriteLn(const AData: string);
begin
  // Which is more efficient? Its hard to say for every situation. But for
  // most this is probably better as it does not require a string realloc
  Write(AData);
  Write(EOL);
end;

function TIdStream.ReadInteger: Integer;
var
  LBytes: TIdBytes;
begin
  ReadBytes(LBytes, SizeOf(Integer));
  Result := Integer(GStack.NetworkToHost(LongWord(BytesToInteger(LBytes))));
end;

procedure TIdStream.WriteLn(const AData: string; AArgs: array of const);
begin
  WriteLn(Format(AData, AArgs));
end;

procedure TIdStream.Write(AValue: Integer);
begin
  Write(ToBytes(Integer(GStack.HostToNetwork(LongWord(AValue)))));
end;

end.
