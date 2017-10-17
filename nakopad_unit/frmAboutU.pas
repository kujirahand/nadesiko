unit frmAboutU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, GLDPNG, jpeg;

const LOGO = 'tools\logo-nadesiko.jpg';

type
  TfrmAbout = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnOK: TButton;
    Shape1: TShape;
    Label1: TLabel;
    imgMain: TImage;
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  frmAbout: TfrmAbout;

implementation

uses gui_benri;

{$R *.dfm}

procedure TfrmAbout.btnOKClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmAbout.FormShow(Sender: TObject);
begin
  if FileExists(AppPath + LOGO) then
  begin
    imgMain.Picture.LoadFromFile(AppPath + LOGO);
  end;
end;

end.
