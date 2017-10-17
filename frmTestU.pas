unit frmTestU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private éŒ¾ }
  public
    { Public éŒ¾ }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


function nako_show_dialog(hParent: Integer): Integer; stdcall; external 'nakodialog.dll';

procedure TForm1.Button1Click(Sender: TObject);
begin
  nako_show_dialog(Self.Handle);
end;

end.
