unit UHelloWorld;
{*
 *  HelloWorld Å‚à’Pƒ‚ÈƒvƒƒOƒ‰ƒ€
 *
 *  Copyright(c) 1999 Takezou
 *
 *}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  THelloWorldForm = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private éŒ¾ }
  public
    { Public éŒ¾ }
  end;

var
  HelloWorldForm: THelloWorldForm;

implementation

uses PDFMaker, PMFonts;

{$R *.DFM}

procedure THelloWorldForm.Button1Click(Sender: TObject);
begin
  with TPDFMaker.Create do
  begin
    BeginDoc(TFileStream.Create('HelloWorld.pdf', fmCreate));

    Canvas.FontSize := 20;
    Canvas.TextOut(200, 500, 'Hello World');

    EndDoc(true);
    Free;
  end;
  ShowMessage('HelloWorld.pdf‚ğì¬‚µ‚Ü‚µ‚½');
  Close;
end;

end.
