{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  13758: IdCoderMIME.pas 
{
{   Rev 1.2    2004.01.21 1:04:54 PM  czhower
{ InitComponenet
}
{
{   Rev 1.1    10/6/2003 5:37:02 PM  SGrobety
{ Bug fix in decoders.
}
{
{   Rev 1.0    11/14/2002 02:14:54 PM  JPMugaas
}
unit IdCoderMIME;

interface

uses
  Classes,
  IdCoder3to4;

type
  TIdEncoderMIME = class(TIdEncoder3to4)
  protected
    procedure InitComponent; override;
  end;

  TIdDecoderMIME = class(TIdDecoder4to3)
  protected
    procedure InitComponent; override;
  end;

const
  GBase64CodeTable: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';    {Do not Localize}

var
  GBase64DecodeTable: TIdDecodeTable;

implementation

uses
  IdGlobal,
  SysUtils;

{ TIdDecoderMIME }

procedure TIdDecoderMIME.InitComponent;
begin
  inherited;
  FDecodeTable := GBase64DecodeTable;
  FCodingTable := GBase64CodeTable;
  FFillChar := '=';  {Do not Localize}
end;

{ TIdEncoderMIME }

procedure TIdEncoderMIME.InitComponent;
begin
  inherited;
  FCodingTable := GBase64CodeTable;
  FFillChar := '=';   {Do not Localize}
end;

initialization
  TIdDecoder4to3.ConstructDecodeTable(GBase64CodeTable, GBase64DecodeTable);
end.
