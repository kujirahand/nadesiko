program MakeGraphPaper;

uses
  Forms,
  UMakeGraphPaper in 'UMakeGraphPaper.pas' {Form1},
  PDFMaker in 'PDFMaker.pas',
  PMFonts in 'PMFonts.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
