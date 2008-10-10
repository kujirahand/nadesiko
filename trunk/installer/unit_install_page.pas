unit unit_install_page;

interface

uses
  Classes;

type
  TInstallEvent = procedure of Object;
  TInstallPage = class
  public
    prev: Integer;
    next: Integer;
    cur:  Integer;
    onActive: TInstallEvent;
    constructor Create(cur, prev, next: Integer; onActive: TInstallEvent);
  end;

implementation

{ TInstallPage }

constructor TInstallPage.Create(cur, prev, next: Integer; onActive: TInstallEvent);
begin
  Self.cur  := cur;
  Self.prev := prev;
  Self.next := next;
  Self.onActive := onActive;
end;

end.
