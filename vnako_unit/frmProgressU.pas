unit frmProgressU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TCancel = procedure() ;
  TfrmProgress = class(TForm)
    lblCaption: TLabel;
    prog: TProgressBar;
    btnCalcel: TButton;
    lblInfo: TLabel;
    procedure btnCalcelClick(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
    procCancel: TCancel;
  end;

var
  frmProgress: TfrmProgress;

implementation

{$R *.dfm}

procedure TfrmProgress.btnCalcelClick(Sender: TObject);
begin
  if Assigned(procCancel) then procCancel;
end;

end.
