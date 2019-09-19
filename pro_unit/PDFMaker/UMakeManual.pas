unit UMakeManual;
{*
 *  PDFMaker�}�j���A���쐬�v���O����
 *
 *  �f�[�^�t�H�[�}�b�g
 *
 *  �P�����ڂ�'-'�̏ꍇ�i�������o�́j
 *     �Q�����ڂ���T�����ڂ܂ł��I�t�Z�b�g
 *     �U�����ڂ���X�����ڂ܂ł����̑���
 *  �P�����ڂ�'P'�̏ꍇ�i���y�[�W�j
 *     ���y�[�W
 *  �P�����ڂ�'T'�̏ꍇ�i�e�L�X�g���o�́j
 *     �Q�����ڂ���T�����ڂ��I�t�Z�b�g
 *     �U�����ڂ���X�����ڂ܂ł��t�H���g�T�C�Y
 *
 *}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, PDFMaker, PMFonts;

type
  TMakeManualForm = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    FPDFMaker: TPDFMaker;
    FSrcFile: TextFile;
    FPage: integer;
    FCurrentY: Single;
    procedure ReadLine;
    procedure WriteHeader;
    procedure WriteFooter;
    procedure WriteNewPage;
  public
    { Public �錾 }
  end;

var
  MakeManualForm: TMakeManualForm;

implementation

{$R *.DFM}

const
  SRC_FILE = 'ManualSrc.txt';
  BASE_OFFSETX = 50;
  BASE_OFFSETY = 50;
  PDF_FILENAME = 'PDFMaker�h�L�������g.pdf';
  PAGE_HEIGHT = 842;
  PAGE_WIDTH = 596;

procedure TMakeManualForm.Button1Click(Sender: TObject);
begin
  FPDFMaker := TPDFMaker.Create;
  FPDFMaker.Author := 'Takezou';
  FPDFMaker.Title := 'PDFMaker�h�L�������g';
  // Creater�ɂ�Exe�t�@�C����������B
  FPDFMaker.Creator := ExtractFileName(ParamStr(0));
  FPDFMaker.Subject := '����';
  AssignFile(FSrcFile, SRC_FILE);
  try
    FPDFMaker.BeginDoc(TFileStream.Create(PDF_FILENAME, fmCreate));
    Reset(FSrcFile);
    WriteHeader;
    while not EOF(FSrcFile) do
      ReadLine;
    WriteFooter;
    FPDFMaker.EndDoc(true);
  finally
    CloseFile(FSrcFile);
  end;
  ShowMessage(PDF_FILENAME + '���쐬���܂���');
  FPDFMaker.Free;
  Close;
end;

procedure TMakeManualForm.ReadLine;
var
  S, S2, S3: string;
  X1, X2, Y1: Single;
  LC: Integer;
begin
  with FPDFMaker.Canvas do
  begin
    ReadLn(FSrcFile, S);
    if Length(S) = 0 then
      Exit;
    if S[1] = 'P' then
    begin
      WriteNewPage;
    end
    else
    if S[1] = '-' then
    begin
      X1 := BASE_OFFSETX + StrToFloat(Copy(S, 2, 4));
      X2 := PAGE_WIDTH - BASE_OFFSETX;
      LineWidth := StrToFloat(Copy(S, 6, 4));
      LineTo(X1, FCurrentY - 5, X2, FCurrentY - 5);
      FCurrentY := FCurrentY - FontSize - 2;
    end
    else
    if S[1] = '*' then
    begin
      X1 := BASE_OFFSETX + StrToFloat(Copy(S, 2, 4));
      X2 := PAGE_WIDTH - BASE_OFFSETX;
      FontSize := StrToFloat(Copy(S, 6, 4));
      Leading := FontSize + 2;

      S2 := Copy(S, 10, Length(S) - 9);
      LC := ArrangeText(S2, S3, X2 - X1);
      if LC = 0 then
        LC := 1;

      Y1 := FCurrentY - ((Leading * LC) + 5);
      if Y1 < BASE_OFFSETY + 20 then
        WriteNewPage;
      // ���y�[�W���FPDFMaker.Canvas�������I�u�W�F�N�g���ύX����邽�߁A
      // �ēxwith���ŎQ�Ɛ���Đݒ肷��K�v������B
      with FPDFMaker.Canvas do
      begin
        FontSize := StrToFloat(Copy(S, 6, 4));
        Leading := FontSize + 2;
        FCurrentY := FCurrentY - (Leading + 5);

        TextOut(X1, FCurrentY, S3);

        FCurrentY := FCurrentY - ((Leading * (LC - 1)));
      end;
    end;
  end;

end;

procedure TMakeManualForm.WriteHeader;
var
  X1, Y1: Single;
  W: Single;
begin
  with FPDFMaker.Canvas do
  begin
    Font := fiMincyo;
    FontSize := 8;

    W := TextWidth(PDF_FILENAME);
    X1 := PAGE_WIDTH - BASE_OFFSETX - W;
    Y1 := PAGE_HEIGHT - BASE_OFFSETY;

    TextOut(X1, Y1 - FontSize, PDF_FILENAME);

    Y1 := Y1 - FontSize - 5;

    LineWidth := 0.5;

    FCurrentY := Y1 - 10;
    inc(FPage);
  end;
end;

procedure TMakeManualForm.WriteFooter;
var
  X1, Y1, X2, SW: Single;
  S: string;
begin
  with FPDFMaker.Canvas do
  begin
    Font := fiMincyo;
    FontSize := 10;

    X1 := BASE_OFFSETX;
    X2 := PAGE_WIDTH - BASE_OFFSETX;
    Y1 := BASE_OFFSETY;

    s := 'Page: ' + IntToStr(FPage);
    SW := TextWidth(s);
    X1 := X1 + (X2-X1-SW)/2;
    TextOut(X1, Y1 - FontSize, s);

    Y1 := Y1 + FontSize;

    LineWidth := 1.25;
    X1 := BASE_OFFSETX;
    X2 := PAGE_WIDTH - BASE_OFFSETX;
    LineTo(X1, Y1, X2, Y1);
  end;
end;

procedure TMakeManualForm.WriteNewPage;
begin
  WriteFooter;
  FPDFMaker.NewPage;
  WriteHeader;
end;

end.
