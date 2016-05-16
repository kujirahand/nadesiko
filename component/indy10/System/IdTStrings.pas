{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  110925: IdTStrings.pas
{
{   Rev 1.6    08.11.2004 ã. 22:35:48  DBondzhev
{ Fixed problem with AddStrings
}
{
{   Rev 1.5    08.11.2004 ã. 20:00:46  DBondzhev
{ changed TObject to &Object
}
{
{   Rev 1.4    08.11.2004 ã. 19:38:00  DBondzhev
{ TStrings does not implement methods for Objects property to work.
{ Now these are implemented in IndyStringsList  that is used in DotNetDistro
}
{
{   Rev 1.3    2004.10.26 9:07:30 PM  czhower
{ More .NET implicit conversions
}
{
{   Rev 1.2    2004.10.26 7:51:58 PM  czhower
{ Fixed ifdef and renamed TCLRStrings to TIdCLRStrings
}
{
{   Rev 1.1    2004.10.26 7:34:50 PM  czhower
{ First working version
}
{
{   Rev 1.0    2004.10.26 4:28:08 PM  czhower
{ Initial checkin
}
unit IdTStrings;

{$I IdCompilerDefines.inc}
// IFDEF's allowed

interface

uses
  {$IFDEF DotNetDistro}
  System.Collections.Specialized,
  System.Collections,
  {$ENDIF}
  Classes;

type
  // only do this for VS.NET. Delphi.NET users will still want to use normal
  // TStrings and may pass in other TString descendants like Listbox.Items etc.
  // The .NET handling will break this. While VS.NET users will only use FCL
  // items and not VCL.
  {$IFNDEF DotNetDistro}
  // Dont include the type word. In Win32 we want it to be completely compatible
  // for parameter passing
  TIdStrings = TStrings;
  TIdStringList = TStringList;
  {$ENDIF}

  {$IFDEF DotNetDistro}
  // For .NET we have to introduce type convertors

  TIdStrings = class(TStrings)
  public
    // Allows conversion back to StringCollection
    // This one is here instead of TIdCLRStrings as many instances are
    // TIdStringList but the refereces (properties usually) are of type
    // TIdStrings (Base interface)
    class operator Implicit(const aValue: TIdStrings): StringCollection;
    // Convert from StringCollection
    class operator Implicit(AValue: StringCollection): TIdStrings;
  end;

  // Cannot implicit convert back from StringCollection to CLRStrings
  // or StringList. Reverse implicit conversions require explicit implicit
  // convertors on each class. However all external references shoudl be
  // TIdStrings anyways.
  TIdCLRStrings = class(TIdStrings)
  protected
    FCollection: StringCollection;
    FObjectArray: ArrayList;
    //
    function Get(Index: Integer): string; override;
    function GetCount: Integer; override;

    function GetObject(Index: Integer): &Object; override;
    procedure PutObject(Index: Integer; AObject: &Object); override;
  public
    function Add(const S: string): Integer; override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;
  public
    constructor Create(AValue: StringCollection);
    procedure Clear; override;
  end;

  // TStrings compatible. Separate from TIdCLRStrings to keep encapselation
  // But operates on a StringCollection instead
  TIdStringList = class(TIdCLRStrings)
  public
    constructor Create;
  end;

  {$ENDIF}

implementation

uses
  IdException;

{$IFDEF DotNetDistro}
class operator TIdStrings.Implicit(const aValue: TIdStrings): StringCollection;
begin
  EIdException.IfFalse(aValue is TIdStrings, 'Invalid implicit conversion.');
  Result := TIdCLRStrings(aValue).FCollection;
end;

constructor TIdStringList.Create;
begin
  inherited Create(StringCollection.Create);
end;

procedure TIdCLRStrings.Clear;
begin
  FCollection.Clear;
end;

constructor TIdCLRStrings.Create(AValue: StringCollection);
begin
  inherited Create;
  FCollection := AValue;
  FObjectArray := ArrayList.Create;
end;

function TIdCLRStrings.Add(const S: string): Integer;
begin
  result := inherited Add(S);
  PutObject(result, nil);
end;

procedure TIdCLRStrings.Delete(Index: Integer);
begin
  if (Index >= 0) and (Index < Count) then begin
    FCollection.RemoveAt(Index);
  end;
end;

function TIdCLRStrings.Get(Index: Integer): string;
begin
  Result := FCollection.Item[Index];
end;

function TIdCLRStrings.GetCount: Integer;
begin
  Result := FCollection.Count;
end;

function TIdCLRStrings.GetObject(Index: Integer): &Object;
begin
  result := FObjectArray.Item[Index];
end;

procedure TIdCLRStrings.Insert(Index: Integer; const S: string);
begin
  FCollection.Insert(Index, S);
end;

class operator TIdStrings.Implicit(AValue: StringCollection): TIdStrings;
begin
  Result := TIdCLRStrings.Create(AValue);
end;

procedure TIdCLRStrings.PutObject(Index: Integer; AObject: &Object);
begin
  FObjectArray.Insert(Index, AObject);
end;

{$ENDIF}

end.
