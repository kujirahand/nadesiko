program DBList;

uses
  Forms,
  UDBList in 'UDBList.pas' {DBListForm},
  PDFMaker in 'PDFMaker.pas',
  PMFonts in 'PMFonts.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TDBListForm, DBListForm);
  Application.Run;
end.
