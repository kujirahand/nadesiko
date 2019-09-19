unit UMakeGraphPaper;
{*
 *  レポート設計時に便利な方眼紙を出力するプログラム
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
    { Private 宣言 }
  public
    { Public 宣言 }
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
    // この下の2行のコメントをはずして修正することで、サイズ変更が出来る。
    // PageHeight := XXX;
    // PageWidth := XXX;

    BeginDoc(TFileStream.Create('方眼紙.pdf', fmCreate));

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
         * 点線を書くため低レベルルーチンを使用
         * 低レベルルーチンのドキュメントはまだ作成していない。
         * どうしても使用したい場合は、Adobe社のサイトからPDFの仕様書を入手
         * して勉強するのがお勧め。
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

  ShowMessage('方眼紙.pdfを作成しました');
  Close;

end;

end.
