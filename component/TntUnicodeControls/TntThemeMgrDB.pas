
{*****************************************************************************}
{                                                                             }
{    Tnt Delphi Unicode Controls                                              }
{      http://www.tntware.com/delphicontrols/unicode/                         }
{        Version: 2.2.5                                                       }
{                                                                             }
{    Copyright (c) 2002-2006, Troy Wolbrink (troy.wolbrink@tntware.com)       }
{                                                                             }
{*****************************************************************************}

unit TntThemeMgrDB;

{$INCLUDE TntCompilers.inc}

//---------------------------------------------------------------------------------------------
// TTntThemeManagerDB is a TThemeManagerDB descendant that knows about Tnt Unicode controls.
//   Most of the code is a complete copy from the Mike Lischke's original with only a
//     few modifications to enabled Unicode support of Tnt controls.
//---------------------------------------------------------------------------------------------
// The initial developer of ThemeMgrDB.pas is:
//   Dipl. Ing. Mike Lischke (public@lischke-online.de, www.lischke-online.de).
//     http://www.delphi-gems.com/ThemeManager.php
//
// Portions created by Mike Lischke are
// (C) 2001-2002 Mike Lischke. All Rights Reserved.
//---------------------------------------------------------------------------------------------

interface

uses
  Windows, Sysutils, Messages, Classes, Controls, Graphics, ThemeMgrDB, TntThemeMgr;

{TNT-WARN TThemeManagerDB}
type
  TTntThemeManagerDB = class(TThemeManagerDB{TNT-ALLOW TThemeManagerDB})
  private
    FThemeMgrHelper: TTntThemeManagerHelper;
  protected
    function DoControlMessage(Control: TControl; var Message: TMessage): Boolean; override;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

procedure Register;

implementation

uses
  ThemeMgr, ThemeSrv, TntClasses;

procedure Register;
begin
  RegisterComponents('Tnt Additional', [TTntThemeManagerDB]);
end;

{ TTntThemeManagerDB }

constructor TTntThemeManagerDB.Create(AOwner: TComponent);
begin
  inherited;
  FThemeMgrHelper := TTntThemeManagerHelper.Create(Self);
end;

procedure TTntThemeManagerDB.Loaded;
begin
  if  (not (csDesigning in ComponentState))
  and (not ThemeServices.ThemesAvailable) then begin
    Options := Options - [toResetMouseCapture];
    FixControls(nil);
  end;
  inherited;
end;

function TTntThemeManagerDB.DoControlMessage(Control: TControl; var Message: TMessage): Boolean;
begin
  // if Control is TTntDB...
  //   handle it here...
  // else
    Result := FThemeMgrHelper.DoControlMessage(Control, Message);
end;

end.
