program FontDemo;

uses
  Forms,
  PDFMaker in 'PDFMaker.pas',
  PMFonts in 'PMFonts.pas',
  UFontDemo in 'UFontDemo.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
