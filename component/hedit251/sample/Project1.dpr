program Project1;

uses
//  MemCheck,
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Form2},
  Unit3 in 'Unit3.pas' {Props: TDataModule};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TProps, Props);
  Form1.MoveEditorsFromTForm2;
  Application.Run;
end.
