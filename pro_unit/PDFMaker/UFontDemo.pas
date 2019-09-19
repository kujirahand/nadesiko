unit UFontDemo;
{*
 *  FontList.dpr �t�H���g����ѕ�����֘A�̃f��
 *
 *  Copyright(c) 2000 Takezou
 *
 *}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  {*
   * uses ��PDFMaker��PWFonts��ǉ����̃f���̓v���V�[�W���̈����Ƃ���
   * TPDFMaker��Canvas���킽���Ă��邽�߁A������uses�ɒǉ�����B
   *
   *}
  PDFMaker, PMFonts;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    FPDFMaker: TPDFMaker;
    procedure MakeFontList(X, Y: Single; ACanvas: TPDFContents);
    procedure MakeFontSizeList(X, Y: Single; ACanvas: TPDFContents);
    procedure MakeCharSpaceList(X, Y: Single; ACanvas: TPDFContents);
    procedure MakeWordSpaceList(X, Y: Single; ACanvas: TPDFContents);
    procedure MakeAlignmentList(X, Y: Single; ACanvas: TPDFContents);
    procedure MakeWordwrapList(X, Y: Single; ACanvas: TPDFContents);
  public
    { Public �錾 }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.MakeFontList(X, Y: Single; ACanvas: TPDFContents);
begin
{*
 *  MakeFontList
 *
 *  �e��t�H���g�̃T���v����ACanvas�ɏo�͂���B
 *  �t�H���g�͌���8��ނ̂ݎg�p�\�B�����ǉ����Ă����\��
 *
 *}

  // ���o��
  ACanvas.Font := fiMincyo;
  ACanvas.FontSize := 12;
  ACanvas.TextOut(X, Y, 'Font');
  ACanvas.LineWidth := 0.75;
  ACanvas.DrawRect(X, Y - 5, X + 220, Y - 290, false);

  X := X + 10;

  // Century�t�H���g
  Y := Y - 20;
  ACanvas.Font := fiCentury;
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'Century');
  ACanvas.FontSize := 12;
  Y := Y - 15;
  ACanvas.TextOut(X, Y, 'ABCDFEGabcdefg123456$%&?');

  // Century�t�H���g(Bold)
  Y := Y - 20;
  ACanvas.Font := fiCenturyBold;
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'Century Bold');
  ACanvas.FontSize := 12;
  Y := Y - 15;
  ACanvas.TextOut(X, Y, 'ABCDFEGabcdefg123456$%&?');

  // Arial�t�H���g
  Y := Y - 20;
  ACanvas.Font := fiArial;
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'Arial');
  ACanvas.FontSize := 12;
  Y := Y - 15;
  ACanvas.TextOut(X, Y, 'ABCDFEGabcdefg123456$%&?');

  // Arial�t�H���g(Bold)
  Y := Y - 20;
  ACanvas.Font := fiArialBold;
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'Arial Bold');
  ACanvas.FontSize := 12;
  Y := Y - 15;
  ACanvas.TextOut(X, Y, 'ABCDFEGabcdefg123456$%&?');

  // Courier�t�H���g
  Y := Y - 20;
  ACanvas.Font := fiCourier;
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'Courier');
  ACanvas.FontSize := 12;
  Y := Y - 15;
  ACanvas.TextOut(X, Y, 'ABCDFEGabcdefg123456$%&?');

  // Courier�t�H���g(Bold)
  Y := Y - 20;
  ACanvas.Font := fiCourierBold;
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'Courier Bold');
  ACanvas.FontSize := 12;
  Y := Y - 15;
  ACanvas.TextOut(X, Y, 'ABCDFEGabcdefg123456$%&?');

  // �����t�H���g
  Y := Y - 20;
  ACanvas.Font := fiMincyo;
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, '����');
  ACanvas.FontSize := 12;
  Y := Y - 15;
  ACanvas.TextOut(X, Y, '�����������A�C�E�G�IABCabc123$%&?');

  // �����t�H���g
  Y := Y - 20;
  ACanvas.Font := fiGothic;
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, '�S�V�b�N');
  ACanvas.FontSize := 12;
  Y := Y - 15;
  ACanvas.TextOut(X, Y, '�����������A�C�E�G�IABCabc123$%&?');
end;

procedure TForm1.MakeFontSizeList(X, Y: Single; ACanvas: TPDFContents);
begin
{*
 *  MakeFontSizeList
 *
 *  �t�H���g�T�C�X��ύX�����Ƃ��̂̃T���v����ACanvas�ɏo�͂���B
 *  �t�H���g�T�C�X��1/100�h�b�h�P�ʂŎw��\
 *
 *}

  // �g���ƌ��o���̏o��
  ACanvas.Font := fiMincyo;
  ACanvas.FontSize := 12;
  ACanvas.TextOut(X, Y, 'FontSize');
  ACanvas.LineWidth := 0.75;
  ACanvas.DrawRect(X, Y - 5, X + 220, Y - 290, false);

  X := X + 10;

  Y := Y - 20;

  // FonrSize = 6
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'FonrSize = 6');
  ACanvas.FontSize := 6;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, '�������A�C�EABCabc123$%&?');
  Y := Y - 18;

  // FonrSize = 8
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'FonrSize = 8');
  ACanvas.FontSize := 8;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, '�������A�C�EABCabc123$%&?');
  Y := Y - 18;

  // FonrSize = 10
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'FonrSize = 10');
  ACanvas.FontSize := 10;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, '�������A�C�EABCabc123$%&?');
  Y := Y - 18;

  // FonrSize = 14
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'FonrSize = 14');
  ACanvas.FontSize := 14;
  Y := Y - ACanvas.FontSize - 2;
  ACanvas.TextOut(X, Y, '�������A�C�EABCabc123$%&?');
  Y := Y - 18;

  // FonrSize = 20
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'FonrSize = 20');
  ACanvas.FontSize := 20;
  Y := Y - ACanvas.FontSize - 1;
  ACanvas.TextOut(X, Y, '�����A�CABab123$%&?');
  Y := Y - 18;

  // FonrSize = 32
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'FonrSize = 32');
  ACanvas.FontSize := 32;
  Y := Y - ACanvas.FontSize;
  ACanvas.TextOut(X, Y, '���AABab123$');
  Y := Y - 18;

  // FonrSize = 48
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'FonrSize = 48');
  ACanvas.FontSize := 48;
  Y := Y - ACanvas.FontSize;
  ACanvas.TextOut(X, Y, '���AAa1$');

end;

procedure TForm1.MakeCharSpaceList(X, Y: Single; ACanvas: TPDFContents);
begin
{*
 *  MakeCharWidthList
 *
 *  CharWidth(�����Ԋu)��ύX�����Ƃ��̂̃T���v����ACanvas�ɏo�͂���B
 *  �����Ԋu��1/100�h�b�h�P�ʂŎw��\
 *
 *}
  ACanvas.Font := fiMincyo;
  ACanvas.FontSize := 12;
  ACanvas.TextOut(X, Y, 'CharSpace');
  ACanvas.LineWidth := 0.75;
  ACanvas.DrawRect(X, Y - 5, X + 220, Y - 140, false);

  X := X + 10;

  Y := Y - 20;

  ACanvas.FontSize := 8;
  ACanvas.CharSpace := 0;
  ACanvas.TextOut(X-5, Y, 'CharSpace = -0.5');
  ACanvas.FontSize := 12;
  ACanvas.CharSpace := -0.5;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, '�������A�C�EABCabc123$%&?');
  Y := Y - 18;

  ACanvas.FontSize := 8;
  ACanvas.CharSpace := 0;
  ACanvas.TextOut(X-5, Y, 'CharSpace = 0 (Default)');
  ACanvas.FontSize := 12;
  ACanvas.CharSpace := 0;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, '�������A�C�EABCabc123$%&?');
  Y := Y - 18;

  ACanvas.FontSize := 8;
  ACanvas.CharSpace := 0;
  ACanvas.TextOut(X-5, Y, 'CharSpace = 1');
  ACanvas.FontSize := 12;
  ACanvas.CharSpace := 1;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, '�������A�C�EABCabc123$%&?');
  Y := Y - 18;

  ACanvas.FontSize := 8;
  ACanvas.CharSpace := 0;
  ACanvas.TextOut(X-5, Y, 'CharSpace = 2');
  ACanvas.FontSize := 12;
  ACanvas.CharSpace := 2;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, '�������A�C�EABCabc123$%&?');

  ACanvas.CharSpace := 0;
end;

procedure TForm1.MakeWordSpaceList(X, Y: Single; ACanvas: TPDFContents);
begin
{*
 *  MakeWordSpaceList
 *
 *  WordSpace(�P��Ԋu)��ύX�����Ƃ��̂̃T���v����ACanvas�ɏo�͂���B
 *  �P��Ԋu��1/100�h�b�h�P�ʂŎw��\
 *
 *}
  ACanvas.Font := fiMincyo;
  ACanvas.FontSize := 12;
  ACanvas.TextOut(X, Y, 'WordSpace');
  ACanvas.LineWidth := 0.75;
  ACanvas.DrawRect(X, Y - 5, X + 220, Y - 140, false);

  X := X + 10;

  Y := Y - 20;

  ACanvas.FontSize := 8;
  ACanvas.WordSpace := 0;
  ACanvas.TextOut(X-5, Y, 'WordSpace = -2');
  ACanvas.FontSize := 12;
  ACanvas.WordSpace := -2;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, 'Hello World ����ɂ��͐��E');
  Y := Y - 18;

  ACanvas.FontSize := 8;
  ACanvas.WordSpace := 0;
  ACanvas.TextOut(X-5, Y, 'WordSpace = 0 (Default)');
  ACanvas.FontSize := 12;
  ACanvas.WordSpace := 0;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, 'Hello World ����ɂ��͐��E');
  Y := Y - 18;

  ACanvas.FontSize := 8;
  ACanvas.WordSpace := 0;
  ACanvas.TextOut(X-5, Y, 'WordSpace = 4');
  ACanvas.FontSize := 12;
  ACanvas.WordSpace := 4;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, 'Hello World ����ɂ��͐��E');
  Y := Y - 18;

  ACanvas.FontSize := 8;
  ACanvas.WordSpace := 0;
  ACanvas.TextOut(X-5, Y, 'WordSpace = 10');
  ACanvas.FontSize := 12;
  ACanvas.WordSpace := 10;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, 'Hello World ����ɂ��͐��E');

  ACanvas.WordSpace := 0;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  X, Y: Single;
begin
  {*
   * �K���Ȉʒu�Ɋe��T���v�����o�͂���B
   *
   *}
  FPDFMaker := TPDFMaker.Create;
  with FPDFMaker do
  begin
    X := 80;
    Y := 750;
    BeginDoc(TFileStream.Create('FontDemo.pdf', fmCreate));

    MakeFontList(X, Y, Canvas);

    X := 310;
    MakeFontSizeList(X, Y, Canvas);

    X := 80;
    Y := 420;
    MakeCharSpaceList(X, Y, Canvas);

    X := 310;
    MakeWordSpaceList(X, Y, Canvas);

    X := 80;
    Y := 240;
    MakeAlignmentList(X, Y, Canvas);

    X := 310;
    Y := 240;
    MakeWordwrapList(X, Y, Canvas);

    EndDoc(true);
    Free;
  end;
  ShowMessage('FontDemo.pdf���쐬���܂����B');
  Close;
end;

procedure TForm1.MakeAlignmentList(X, Y: Single; ACanvas: TPDFContents);
var
  S: string;
  SW, X2: Single;
begin
{*
 *  MakeAlignmentList
 *
 *  �E�񂹁A���񂹁A�Z���^�����O�̃T���v����ACanvas�ɏo�͂���B
 *  �E�񂹁A�Z���^�����O��TextWidth�֐��ŕ�����̒������v�Z���Œ�������B
 *
 *}
  // ���o���Ƙg�����o��
  ACanvas.Font := fiMincyo;
  ACanvas.FontSize := 12;
  ACanvas.TextOut(X, Y, 'Alignment');
  ACanvas.LineWidth := 0.75;
  ACanvas.DrawRect(X, Y - 5, X + 220, Y - 100, false);

  X := X + 10;
  X2 := X + 200;

  Y := Y - 20;

  S := 'Hello World ����ɂ��͐��E';

  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, '����');
  Y := Y - 12;
  ACanvas.FontSize := 12;
  ACanvas.TextOut(X, Y, S);
  Y := Y - 18;

  ACanvas.FontSize := 8;
  ACanvas.WordSpace := 0;
  ACanvas.TextOut(X-5, Y, '�E��');
  Y := Y - 12;
  ACanvas.FontSize := 12;
  {*
   * ������̕����v��i����Font,FontSize,CharSpace,WordSpace�ɂ���ĕς���Ă���
   * ���ߊe��ݒ肪�I����Ă���v��B
   *}
  SW := ACanvas.TextWidth(S);
  // X2�̈ʒu����ɂ��ĉE�񂹂ŕ�������o��
  ACanvas.TextOut(X2 - SW, Y, S);
  Y := Y - 18;

  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, '�Z���^�����O');
  Y := Y - 12;
  ACanvas.FontSize := 12;
  {*
   * �O��TextWidth�Ōv�������Ƃ��Ɠ���������E�ݒ�̂��߁ASW�̒l�����̂܂܎g�p�B
   * X�`X2�̊ԂɃZ���^�����O���ďo�͂���B
   *}
  ACanvas.TextOut(X + (X2 - X - SW) / 2, Y, S);

end;

procedure TForm1.MakeWordwrapList(X, Y: Single; ACanvas: TPDFContents);
var
  S: string;
  S2: string;
begin
{*
 *  MakeWordwrapList
 *
 *  ��������������[�h���b�v���ĕ\������T���v���B
 *  Leading�v���p�e�B�ōs�Ԋu���w�肷��B
 *
 *}
  // ���o���Ƙg�����o��
  ACanvas.Font := fiMincyo;
  ACanvas.FontSize := 10.5;
  ACanvas.TextOut(X, Y, 'Wordwrap');
  ACanvas.LineWidth := 0.75;
  ACanvas.DrawRect(X, Y - 5, X + 220, Y - 110, false);

  X := X + 10;
  Y := Y - 20;

  S := 'PDFMaker�ł�ArrengeText�v���V�[�V�����g�p���邱�Ƃ�' +
       '�ȒP�Ƀ��[�h���b�v�������s���܂��B' +
       '�܂��ALeading�v���p�e�B�ɂ���ĊȒP�ɍs�Ԋu��ύX�ł��܂��B' +
       '���[�h���b�v�����͂P�o�C�g�����̏ꍇ�͒P��P�ʁA�Q�o�C�g�����̏ꍇ��' +
       '�����P�ʂŋ�؂���̂ŁASunday Monday Tuesday Wednesday Thursday Friday ' +
       'Saturday �̂悤�ȉp�������K�؂ɋ�؂��܂��B';

  // ������S��200�h�b�h���ɐ��`����B
  ACanvas.ArrangeText(S, S2, 200);
  // ���s�Ԋu���t�H���g�T�C�Y�Ɠ����ɐݒ�
  ACanvas.Leading := ACanvas.FontSize;

  ACanvas.TextOut(X, Y, S2);

end;

end.
