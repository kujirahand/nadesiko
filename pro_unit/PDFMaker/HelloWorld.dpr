program HelloWorld;

uses
  Forms,
  UHelloWorld in 'UHelloWorld.pas' {HelloWorldForm},
  PDFMaker in 'PDFMaker.pas',
  PMFonts in 'PMFonts.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(THelloWorldForm, HelloWorldForm);
  Application.Run;
end.
