unit ULineDemo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, PDFMaker, PMFonts;

type
  TLineDemoForm = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    FPDFMaker: TPDFMaker;
    procedure LineCapStyleDemo(X, Y: Single; ACanvas: TPDFContents);
    procedure LineJoinStyleDemo(X, Y: Single; ACanvas: TPDFContents);
    procedure RectDemo(X, Y: Single; ACanvas: TPDFContents);
  public
    { Public �錾 }
  end;

var
  LineDemoForm: TLineDemoForm;

implementation

{$R *.DFM}

procedure TLineDemoForm.Button1Click(Sender: TObject);
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
    BeginDoc(TFileStream.Create('LineDemo.pdf', fmCreate));

    LineCapStyleDemo(X, Y, Canvas);

    X := 310;
    Y := 750;
    LineJoinStyleDemo(X, Y, Canvas);

    X := 80;
    Y := 500;
    RectDemo(X, Y, Canvas);

    EndDoc(true);
    Free;
  end;
  ShowMessage('LineDemo.pdf���쐬���܂����B');
  Close;
end;

procedure TLineDemoForm.LineCapStyleDemo(X, Y: Single; ACanvas: TPDFContents);

  procedure DrawCloss(X, Y: Single);
  var
    X1, Y1, X2, Y2: Single;
  begin
    X1 := X - 5;
    X2 := X + 5;
    Y1 := Y - 5;
    Y2 := Y + 5;
    ACanvas.LineWidth := 0.25;
    ACanvas.StrokeColor := clRed;
    ACanvas.LineTo(X, Y1, X, Y2);
    ACanvas.LineTo(X1, Y, X2, Y);
  end;
begin
{*
 *  LineCapStyle
 *
 *  �e��LineCapStyle�̃T���v����ACanvas�ɏo�͂���B
 *
 *}

  // ���o��
  ACanvas.Font := fiGothic;
  ACanvas.FontSize := 9;
  ACanvas.TextOut(X, Y, 'LineCapStyle');
  ACanvas.LineWidth := 0.75;
  ACanvas.DrawRect(X, Y - 5, X + 220, Y - 230, false);

  X := X + 10;

  Y := Y - 10;
  ACanvas.StrokeColor := clWhite;

  // �N���b�s���O�i���̍��[���B�����߁j
  ACanvas.DrawRect(X, Y, X + 200, Y - 200, true);

  // LineCapStyle��lcButtEnd�ɐݒ�
  ACanvas.StrokeColor := clGreen;     // �F�͗ΐF
  ACanvas.LineWidth := 40;            // ���̕���40
  ACanvas.LineCapStyle := lcButtEnd;
  Y := Y - 40;
  ACanvas.LineTo(X - 10, Y, X + 70, Y);  // ��������
  DrawCloss(X + 70, Y);                  // ���[�̃|�C���g���\���Ŏ���

  ACanvas.TextOut(X + 100, Y - 4, 'lcButtEnd(Default)');

  // LineCapStyle��lcProjectingSquareEnd�ɐݒ�
  ACanvas.StrokeColor := clGreen;
  ACanvas.LineWidth := 40;
  ACanvas.LineCapStyle := lcProjectingSquareEnd;
  Y := Y - 70;
  ACanvas.LineTo(X - 10, Y, X + 70, Y);
  DrawCloss(X + 70, Y);

  ACanvas.TextOut(X + 100, Y - 4, 'lcProjectingSquareEnd');

  // LineCapStyle��lcRoundEnd�ɐݒ�
  ACanvas.StrokeColor := clGreen;
  ACanvas.LineWidth := 40;
  ACanvas.LineCapStyle := lcRoundEnd;
  Y := Y - 70;
  ACanvas.LineTo(X - 10, Y, X + 70, Y);
  DrawCloss(X + 70, Y);

  ACanvas.TextOut(X + 100, Y - 4, 'lcRoundEnd');

  // �N���b�s���O����
  ACanvas.CancelClip;
end;

procedure TLineDemoForm.LineJoinStyleDemo(X, Y: Single; ACanvas: TPDFContents);
begin
{*
 *  LineJoinStyleDemo
 *
 *  �e��LineJoinStyleDemo�̃T���v����ACanvas�ɏo�͂���B
 *
 *}

  // ���o��
  ACanvas.Font := fiGothic;
  ACanvas.FontSize := 9;
  ACanvas.TextOut(X, Y, 'LineJoinStyle');

  ACanvas.StrokeColor := clBlack;
  ACanvas.LineWidth := 0.75;
  ACanvas.DrawRect(X, Y - 5, X + 220, Y - 230, false);

  X := X + 10;

  Y := Y - 10;

  // �N���b�s���O�i���̍��[���B�����߁j
  ACanvas.StrokeColor := clWhite;
  ACanvas.DrawRect(X, Y, X + 200, Y - 60, true);

  ACanvas.LineJoinStyle := ljMiterJoin;
  ACanvas.StrokeColor := clBlue;
  ACanvas.LineWidth := 15;
  ACanvas.DrawRect(X - 10, Y - 30, X + 80, Y - 80, false);

  // �N���b�s���O����
  ACanvas.CancelClip;

  ACanvas.TextOut(X + 100, Y - 40, 'ljMiterJoin(Default)');

  Y := Y - 70;

  // �N���b�s���O�i���̍��[���B�����߁j
  ACanvas.StrokeColor := clWhite;
  ACanvas.DrawRect(X, Y, X + 200, Y - 60, true);

  ACanvas.LineJoinStyle := ljBevelJoin;
  ACanvas.StrokeColor := clBlue;
  ACanvas.LineWidth := 15;
  ACanvas.DrawRect(X - 10, Y - 30, X + 80, Y - 80, false);

  // �N���b�s���O����
  ACanvas.CancelClip;

  ACanvas.TextOut(X + 100, Y - 40, 'ljBevelJoin');

  Y := Y - 70;

  // �N���b�s���O�i���̍��[���B�����߁j
  ACanvas.StrokeColor := clWhite;
  ACanvas.DrawRect(X, Y, X + 200, Y - 60, true);

  ACanvas.LineJoinStyle := ljRoundJoin;
  ACanvas.StrokeColor := clBlue;
  ACanvas.LineWidth := 15;
  ACanvas.DrawRect(X - 10, Y - 30, X + 80, Y - 80, false);

  // �N���b�s���O����
  ACanvas.CancelClip;

  ACanvas.TextOut(X + 100, Y - 40, 'ljRoundJoin');

end;

procedure TLineDemoForm.RectDemo(X, Y: Single; ACanvas: TPDFContents);
begin
{*
 *  RectDemo
 *
 *  Draw�����Fill���\�b�h�̃T���v����ACanvas�ɏo�͂���B
 *
 *}

  // ���o��
  ACanvas.Font := fiGothic;
  ACanvas.FontSize := 9;
  ACanvas.TextOut(X, Y, 'Draw and Fill Rectangle');

  ACanvas.StrokeColor := clBlack;
  ACanvas.LineWidth := 0.75;
  ACanvas.DrawRect(X, Y - 5, X + 220, Y - 230, false);

  X := X + 15;

  Y := Y - 10;

  ACanvas.LineJoinStyle := ljMiterJoin;
  ACanvas.StrokeColor := clBlack;
  ACanvas.FillColor := clYellow;
  ACanvas.LineWidth := 1;

  ACanvas.DrawRect(X, Y - 10, X + 80, Y - 60, false);

  ACanvas.FillColor := clBlack;
  ACanvas.TextOut(X + 100, Y - 40, 'DrawRect');
  ACanvas.FillColor := clYellow;

  Y := Y - 70;

  ACanvas.FillRect(X, Y - 10, X + 80, Y - 60, false);

  ACanvas.FillColor := clBlack;
  ACanvas.TextOut(X + 100, Y - 40, 'FillRect');
  ACanvas.FillColor := clYellow;

  Y := Y - 70;

  ACanvas.DrawAndFillRect(X, Y - 10, X + 80, Y - 60, false);

  ACanvas.FillColor := clBlack;
  ACanvas.TextOut(X + 100, Y - 40, 'DrawAndFillRect');
  ACanvas.FillColor := clYellow;

end;

end.
