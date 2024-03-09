program LineDemo;

uses
  Forms,
  ULineDemo in 'ULineDemo.pas' {LineDemoForm},
  PDFMaker in 'PDFMaker.pas',
  PMFonts in 'PMFonts.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TLineDemoForm, LineDemoForm);
  Application.Run;
end.
