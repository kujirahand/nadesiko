unit UDBList;
{*
 *  DBList.dpr �f�[�^�x�[�X����̃��X�g�o�̓f��
 *
 *  Copyright(c) 2000 Takezou
 *
 *}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Db, DBTables, ShellAPI;

type
  TDBListForm = class(TForm)
    MakeReport: TButton;
    Query1: TQuery;
    procedure MakeReportClick(Sender: TObject);
  private
    procedure WriteHeader;  // �w�b�_�[�̏o��
    procedure WriteFooter;  // �t�b�^�[�̏o��
    procedure WritePage;    // ���ׂ̏o��
    procedure WriteRow(YPos: Single);  // �e�s�f�[�^�̏o��
  public
    { Public �錾 }
  end;

var
  DBListForm: TDBListForm;

implementation

uses PDFMaker, PMFonts;

{$R *.DFM}

var
  FPDFMaker: TPDFMaker;

procedure TDBListForm.WriteHeader;
var
  s: string;
  w: Single;
begin
  // �w�b�_�[�̏o��
  with FPDFMaker do
  begin
    // �t�H���g�̐ݒ肵�Č��o�����o��
    Canvas.Font := fiCenturyBold;
    Canvas.FontSize := 16;
    Canvas.FillColor := clNavy;
    Canvas.TextOut(90, 770, 'Customer.DB');
    // �t�H���g�̐ݒ肵�ē��t���E�񂹂ŏo��
    Canvas.Font := fiCentury;
    Canvas.FontSize := 9;
    S := FormatDateTime('YYYY/MM/DD', Date);
    w := Canvas.TextWidth(S);
    Canvas.TextOut(530 - w, 770, s);
    // �������o��
    Canvas.StrokeColor := clBlack;
    Canvas.LineTo(90, 765, 530, 765);
  end;
end;

procedure TDBListForm.WriteFooter;
var
  w: Single;
  s: string;
begin
  with FPDFMaker do
  begin
    // �t�H���g��ݒ肵�ăy�[�W�ԍ���^�񒆂ɏo��
    Canvas.Font := fiCenturyBold;
    Canvas.FontSize := 9;
    Canvas.StrokeColor := clBlack;
    Canvas.LineTo(90, 70, 530, 70);
    s := 'Page ' + IntToStr(Page);
    w := Canvas.TextWidth(s);
    Canvas.TextOut((90 + 530) / 2 - w / 2, 55, s);
  end;
end;

procedure TDBListForm.WritePage;
var
  i: integer;
  XPos, YPos: Single;
begin
  with FPDFMaker do
  begin
    // �O�g������
    Canvas.LineWidth := 1.25;
    Canvas.DrawRect(90, 760, 530, 80, false);
    Canvas.LineTo(90, 740, 530, 740);

    // ���r��������
    YPos := 740;
    Canvas.LineWidth := 0.75;
    for i := 0 to 31 do
    begin
      YPos := YPos - 20;
      Canvas.LineTo(90, YPos, 530, YPos);
    end;

    // �c�r���ƍ��ږ�������
    Canvas.LineWidth := 1;
    Canvas.FontSize := 10.5;

    XPos := 90;
    Canvas.TextOut(XPos + 5, 745, 'NO.');

    XPos := 130;
    Canvas.LineTo(XPos, 760, XPos, 80);
    Canvas.TextOut(XPos + 5, 745, 'Company');

    XPos := 270;
    Canvas.LineTo(XPos, 760, XPos, 80);
    Canvas.TextOut(XPos + 5, 745, 'Address');

    XPos := 450;
    Canvas.LineTo(XPos, 760, XPos, 80);
    Canvas.TextOut(XPos + 5, 745, 'Phone');

    XPos := 530;
    Canvas.LineTo(XPos, 760, XPos, 80);

    // ���׍s�̃t�H���g�̐ݒ�
    Canvas.Font := fiMincyo;
    Canvas.FontSize := 10.5;
    Canvas.FillColor := clBlack;
  end;

  // 20�h�b�g�Ԋu�Ŗ��׍s���o��
  YPos := 740;
  for i := 0 to 32 do
  begin
    WriteRow(YPos);
    YPos := YPos - 20;
  end;
end;

procedure TDBListForm.WriteRow(YPos: Single);
var
  i: integer;
  s: string;
begin
   // �e�s�f�[�^�̏o��
  with FPDFMaker do
  begin
    if not Query1.Eof then
    begin
      Canvas.TextOut(95, YPos - 15, Query1.FieldByName('CustNo').AsString);

      // MeasureText�ō��ڂɓ��镶����̐����͂���A���镪�����o��
      s := Query1.FieldByName('Company').AsString;
      i := Canvas.MeasureText(s, 130);
      Canvas.TextOut(135, YPos - 15, Copy(s, 1, i));

      s := Query1.FieldByName('State').AsString +
           Query1.FieldByName('City').AsString +
           Query1.FieldByName('Addr1').AsString;
      i := Canvas.MeasureText(s, 175);
      Canvas.TextOut(275, YPos - 15, Copy(s, 1, i));

      Canvas.TextOut(455, YPos - 15, Query1.FieldByName('Phone').AsString);

      Query1.Next;
    end;
  end;
end;

procedure TDBListForm.MakeReportClick(Sender: TObject);
begin
  // FPDFMaker�̃C���X�^���X���쐬
  FPDFMaker := TPDFMaker.Create;
  with FPDFMaker do
  begin
    Author := 'Takezou';
    Title := '�f�[�^�x�[�X����̈��';
    // BeginDoc���Ăяo���i�p�����^�ɂ�TFileStream���쐬���ēn���j
    BeginDoc(TFileStream.Create('DBList.pdf', fmCreate));
    // Query���I�[�v�����A�f�[�^�������Ȃ�܂Ńy�[�W�P�ʂŏo��
    Query1.Open;
    while not Query1.Eof do
    begin
      WriteHeader;
      WritePage;
      WriteFooter;
      if not Query1.Eof then
        NewPage;
    end;

    // �I������
    Query1.Close;
    EndDoc(true);
    Free;
  end;

  // ���������͂��܂��B�쐬����PDF�t�@�C����\��
  if MessageDlg('���|�[�g(DBDemo.pdf)�쐬���I�����܂����B�\�����܂����H',
                           mtInformation, [mbYes, mbNO], 0) = mrYes then
    ShellExecute(Self.Handle, 'open', 'DBList.pdf', '', '', SW_SHOW);
  Close;
end;

end.
