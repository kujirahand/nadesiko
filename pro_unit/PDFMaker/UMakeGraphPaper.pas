unit UMakeGraphPaper;
{*
 *  ���|�[�g�݌v���ɕ֗��ȕ��ᎆ���o�͂���v���O����
 *
 *  Copyright 2000 (c) Takezou
 *
 *}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private �錾 }
  public
    { Public �錾 }
  end;

var
  Form1: TForm1;

implementation

uses PDFMaker, PMFonts;

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
  Flg: boolean;
  X, Y: integer;
  BaseRect: TRect;
  i: integer;
begin
  with TPDFMaker.Create do
  begin
    // ���̉���2�s�̃R�����g���͂����ďC�����邱�ƂŁA�T�C�Y�ύX���o����B
    // PageHeight := XXX;
    // PageWidth := XXX;

    BeginDoc(TFileStream.Create('���ᎆ.pdf', fmCreate));

    BaseRect := Rect(50, 50, PageWidth - 50, PageHeight - 50);
    i := BaseRect.Top;
    flg := true;
    X := 35;
    Canvas.pSetFontAndSize(fiArial, 8);
    while i < BaseRect.Bottom do
    begin
      flg := not flg;
      if flg then
      begin
        {*
         * �_�����������ߒ჌�x�����[�`�����g�p
         * �჌�x�����[�`���̃h�L�������g�͂܂��쐬���Ă��Ȃ��B
         * �ǂ����Ă��g�p�������ꍇ�́AAdobe�Ђ̃T�C�g����PDF�̎d�l�������
         * ���ĕ׋�����̂������߁B
         *
         *}
        Canvas.pSetDash(3, 0, 0);
        Canvas.pMoveTo(BaseRect.Left, i);
        Canvas.pLineTo(BaseRect.Right, i);
        Canvas.pStroke;
      end
      else
      begin
        Y := i;
        Canvas.pBeginText;
        Canvas.pMoveTextPoint(X, Y-3);
        Canvas.pShowText(IntToStr(Y));
        Canvas.pEndText;
        Canvas.pSetDash(0, 0, 0);
        Canvas.pMoveTo(BaseRect.Left, i);
        Canvas.pLineTo(BaseRect.Right, i);
        Canvas.pStroke;
      end;
      inc(i, 10)
    end;

    flg := true;
    i := BaseRect.Left;
    Y := 35;
    while i < BaseRect.Right do
    begin
      flg := not flg;
      if flg then
      begin
        Canvas.pSetDash(3, 0, 0);
        Canvas.pMoveTo(i, BaseRect.Top);
        Canvas.pLineTo(i, BaseRect.Bottom);
        Canvas.pStroke;
      end
      else
      begin
        X := i;
        Canvas.pBeginText;
        Canvas.pMoveTextPoint(X-4, Y+2);
        Canvas.pShowText(IntToStr(X));
        Canvas.pEndText;
        Canvas.pSetDash(0, 0, 0);
        Canvas.pMoveTo(i, BaseRect.Top);
        Canvas.pLineTo(i, BaseRect.Bottom);
        Canvas.pStroke;
      end;
      inc(i, 10)
    end;

    EndDoc(true);
    Free;
  end;

  ShowMessage('���ᎆ.pdf���쐬���܂���');
  Close;

end;

end.
