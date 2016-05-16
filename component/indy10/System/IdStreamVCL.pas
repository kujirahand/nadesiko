{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  88065: IdStreamVCL.pas 
{
{   Rev 1.1    2004.05.20 12:15:34 PM  czhower
{ IdStream completion
}
unit IdStreamVCL;

{$I IdCompilerDefines.inc}

interface

uses
  {$IFDEF DotNet}IdStreamVCLDotNet;{$ELSE}IdStreamVCLWin32;{$ENDIF}

type
  TIdStreamVCL = class({$IFDEF DotNet}TIdStreamVCLDotNet{$ELSE}TIdStreamVCLWin32{$ENDIF});

implementation

end.
