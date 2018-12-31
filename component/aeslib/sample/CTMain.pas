unit CTMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TForm1 = class(TForm)
    Label2: TLabel;
    edtFiles: TEdit;
    FileBtn: TSpeedButton;
    btnQuit: TButton;
    btnEncrypt: TButton;
    OpenDialog: TOpenDialog;
    Label4: TLabel;
    edtPwd: TEdit;
    btnDecrypt: TButton;
    procedure FileBtnClick(Sender: TObject);
    procedure btnQuitClick(Sender: TObject);
    procedure btnEncryptClick(Sender: TObject);
    procedure btnDecryptClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses AesLib;

procedure TForm1.FileBtnClick(Sender: TObject);
var
  s : string;
begin
  with Opendialog do begin
    s:=edtFiles.Text;
    InitialDir:=ExtractFilePath(s);
    if Execute then begin
      edtFiles.Text:=FileName;
      edtPwd.SetFocus;
      end;
    end;
  end;

procedure TForm1.btnQuitClick(Sender: TObject);
begin
  Close;
  end;

procedure TForm1.btnEncryptClick(Sender: TObject);
var
  sSource,sDest    : TFileStream;
  s                : string;
begin
  s:= edtFiles.Text+'.enc';
  sSource:=TFileStream.Create(edtFiles.Text,fmOpenRead+fmShareDenyNone);
  sDest:=TFileStream.Create(s,fmCreate);
  with TEncryption.Create(edtPwd.Text,defCryptBufSize) do begin
    if EncryptStream(sSource,sDest) then begin
      MessageDlg ('File encrypted to: '#13+s,mtInformation,[mbOK],0);
      edtFiles.Text:=s;
      end
    else
      MessageDlg ('Error on encrypting file!',mtError,[mbOK],0);
    Free;
    end;
  sSource.Free;
  sDest.Free;
  end;

procedure TForm1.btnDecryptClick(Sender: TObject);
var
  sSource,sDest    : TFileStream;
  s                : string;
begin
  s:= ChangeFileExt(edtFiles.Text,'.dec');
  sSource:=TFileStream.Create(edtFiles.Text,fmOpenRead+fmShareDenyNone);
  sDest:=TFileStream.Create(s,fmCreate);
   with TEncryption.Create(edtPwd.Text,defCryptBufSize) do begin
    if DecryptStream(sSource,sDest,sSource.Size) then
      MessageDlg ('File decrypted to: '#13+s,mtInformation,[mbOK],0)
    else begin
      MessageDlg ('Error on decrypting file!',mtError,[mbOK],0);
      edtPwd.SetFocus;
      end;
    Free;
    end;
  sSource.Free;
  sDest.Free;
  end;

end.
