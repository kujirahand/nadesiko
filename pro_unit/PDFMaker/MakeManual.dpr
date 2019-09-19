program MakeManual;

uses
  Forms,
  UMakeManual in 'UMakeManual.pas' {MakeManualForm},
  PDFMaker in 'PDFMaker.pas',
  PMFonts in 'PMFonts.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMakeManualForm, MakeManualForm);
  Application.Run;
end.
