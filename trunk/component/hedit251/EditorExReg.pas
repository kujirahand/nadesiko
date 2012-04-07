(***************************************************************

  TEditorEx ver 2.77 (Yellow) (2004/02/11)

  Copyright (c) 2001-2004 Km <CQE03114@nifty.ne.jp>
  http://homepage2.nifty.com/Km/

***************************************************************)
unit EditorExReg;

{$I heverdef.inc}

interface

uses
  Classes,
  {$IFDEF COMP6_UP}
    DesignIntf, DesignEditors;
  {$ELSE}
    Dsgnintf;
  {$ENDIF}

procedure Register;

implementation

uses
  EditorEx, EditorExProp;

procedure Register;
begin
  // components
  RegisterComponents('TEditor', [TEditorEx, TEditorExProp]);
end;

end.
