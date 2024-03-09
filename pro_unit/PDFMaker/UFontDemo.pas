unit UFontDemo;
{*
 *  FontList.dpr フォントおよび文字列関連のデモ
 *
 *  Copyright(c) 2000 Takezou
 *
 *}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  {*
   * uses にPDFMakerとPWFontsを追加このデモはプロシージャの引数として
   * TPDFMakerのCanvasをわたしているため、ここのusesに追加する。
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
    { Public 宣言 }
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
 *  各種フォントのサンプルをACanvasに出力する。
 *  フォントは現在8種類のみ使用可能。順次追加していく予定
 *
 *}

  // 見出し
  ACanvas.Font := fiMincyo;
  ACanvas.FontSize := 12;
  ACanvas.TextOut(X, Y, 'Font');
  ACanvas.LineWidth := 0.75;
  ACanvas.DrawRect(X, Y - 5, X + 220, Y - 290, false);

  X := X + 10;

  // Centuryフォント
  Y := Y - 20;
  ACanvas.Font := fiCentury;
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'Century');
  ACanvas.FontSize := 12;
  Y := Y - 15;
  ACanvas.TextOut(X, Y, 'ABCDFEGabcdefg123456$%&?');

  // Centuryフォント(Bold)
  Y := Y - 20;
  ACanvas.Font := fiCenturyBold;
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'Century Bold');
  ACanvas.FontSize := 12;
  Y := Y - 15;
  ACanvas.TextOut(X, Y, 'ABCDFEGabcdefg123456$%&?');

  // Arialフォント
  Y := Y - 20;
  ACanvas.Font := fiArial;
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'Arial');
  ACanvas.FontSize := 12;
  Y := Y - 15;
  ACanvas.TextOut(X, Y, 'ABCDFEGabcdefg123456$%&?');

  // Arialフォント(Bold)
  Y := Y - 20;
  ACanvas.Font := fiArialBold;
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'Arial Bold');
  ACanvas.FontSize := 12;
  Y := Y - 15;
  ACanvas.TextOut(X, Y, 'ABCDFEGabcdefg123456$%&?');

  // Courierフォント
  Y := Y - 20;
  ACanvas.Font := fiCourier;
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'Courier');
  ACanvas.FontSize := 12;
  Y := Y - 15;
  ACanvas.TextOut(X, Y, 'ABCDFEGabcdefg123456$%&?');

  // Courierフォント(Bold)
  Y := Y - 20;
  ACanvas.Font := fiCourierBold;
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'Courier Bold');
  ACanvas.FontSize := 12;
  Y := Y - 15;
  ACanvas.TextOut(X, Y, 'ABCDFEGabcdefg123456$%&?');

  // 明朝フォント
  Y := Y - 20;
  ACanvas.Font := fiMincyo;
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, '明朝');
  ACanvas.FontSize := 12;
  Y := Y - 15;
  ACanvas.TextOut(X, Y, 'あいうえおアイウエオABCabc123$%&?');

  // 明朝フォント
  Y := Y - 20;
  ACanvas.Font := fiGothic;
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'ゴシック');
  ACanvas.FontSize := 12;
  Y := Y - 15;
  ACanvas.TextOut(X, Y, 'あいうえおアイウエオABCabc123$%&?');
end;

procedure TForm1.MakeFontSizeList(X, Y: Single; ACanvas: TPDFContents);
begin
{*
 *  MakeFontSizeList
 *
 *  フォントサイスを変更したときののサンプルをACanvasに出力する。
 *  フォントサイスは1/100ドッド単位で指定可能
 *
 *}

  // 枠線と見出しの出力
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
  ACanvas.TextOut(X, Y, 'あいうアイウABCabc123$%&?');
  Y := Y - 18;

  // FonrSize = 8
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'FonrSize = 8');
  ACanvas.FontSize := 8;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, 'あいうアイウABCabc123$%&?');
  Y := Y - 18;

  // FonrSize = 10
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'FonrSize = 10');
  ACanvas.FontSize := 10;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, 'あいうアイウABCabc123$%&?');
  Y := Y - 18;

  // FonrSize = 14
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'FonrSize = 14');
  ACanvas.FontSize := 14;
  Y := Y - ACanvas.FontSize - 2;
  ACanvas.TextOut(X, Y, 'あいうアイウABCabc123$%&?');
  Y := Y - 18;

  // FonrSize = 20
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'FonrSize = 20');
  ACanvas.FontSize := 20;
  Y := Y - ACanvas.FontSize - 1;
  ACanvas.TextOut(X, Y, 'あいアイABab123$%&?');
  Y := Y - 18;

  // FonrSize = 32
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'FonrSize = 32');
  ACanvas.FontSize := 32;
  Y := Y - ACanvas.FontSize;
  ACanvas.TextOut(X, Y, 'あアABab123$');
  Y := Y - 18;

  // FonrSize = 48
  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'FonrSize = 48');
  ACanvas.FontSize := 48;
  Y := Y - ACanvas.FontSize;
  ACanvas.TextOut(X, Y, 'あアAa1$');

end;

procedure TForm1.MakeCharSpaceList(X, Y: Single; ACanvas: TPDFContents);
begin
{*
 *  MakeCharWidthList
 *
 *  CharWidth(文字間隔)を変更したときののサンプルをACanvasに出力する。
 *  文字間隔は1/100ドッド単位で指定可能
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
  ACanvas.TextOut(X, Y, 'あいうアイウABCabc123$%&?');
  Y := Y - 18;

  ACanvas.FontSize := 8;
  ACanvas.CharSpace := 0;
  ACanvas.TextOut(X-5, Y, 'CharSpace = 0 (Default)');
  ACanvas.FontSize := 12;
  ACanvas.CharSpace := 0;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, 'あいうアイウABCabc123$%&?');
  Y := Y - 18;

  ACanvas.FontSize := 8;
  ACanvas.CharSpace := 0;
  ACanvas.TextOut(X-5, Y, 'CharSpace = 1');
  ACanvas.FontSize := 12;
  ACanvas.CharSpace := 1;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, 'あいうアイウABCabc123$%&?');
  Y := Y - 18;

  ACanvas.FontSize := 8;
  ACanvas.CharSpace := 0;
  ACanvas.TextOut(X-5, Y, 'CharSpace = 2');
  ACanvas.FontSize := 12;
  ACanvas.CharSpace := 2;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, 'あいうアイウABCabc123$%&?');

  ACanvas.CharSpace := 0;
end;

procedure TForm1.MakeWordSpaceList(X, Y: Single; ACanvas: TPDFContents);
begin
{*
 *  MakeWordSpaceList
 *
 *  WordSpace(単語間隔)を変更したときののサンプルをACanvasに出力する。
 *  単語間隔は1/100ドッド単位で指定可能
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
  ACanvas.TextOut(X, Y, 'Hello World こんにちは世界');
  Y := Y - 18;

  ACanvas.FontSize := 8;
  ACanvas.WordSpace := 0;
  ACanvas.TextOut(X-5, Y, 'WordSpace = 0 (Default)');
  ACanvas.FontSize := 12;
  ACanvas.WordSpace := 0;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, 'Hello World こんにちは世界');
  Y := Y - 18;

  ACanvas.FontSize := 8;
  ACanvas.WordSpace := 0;
  ACanvas.TextOut(X-5, Y, 'WordSpace = 4');
  ACanvas.FontSize := 12;
  ACanvas.WordSpace := 4;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, 'Hello World こんにちは世界');
  Y := Y - 18;

  ACanvas.FontSize := 8;
  ACanvas.WordSpace := 0;
  ACanvas.TextOut(X-5, Y, 'WordSpace = 10');
  ACanvas.FontSize := 12;
  ACanvas.WordSpace := 10;
  Y := Y - ACanvas.FontSize - 3;
  ACanvas.TextOut(X, Y, 'Hello World こんにちは世界');

  ACanvas.WordSpace := 0;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  X, Y: Single;
begin
  {*
   * 適当な位置に各種サンプルを出力する。
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
  ShowMessage('FontDemo.pdfを作成しました。');
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
 *  右寄せ、左寄せ、センタリングのサンプルをACanvasに出力する。
 *  右寄せ、センタリングはTextWidth関数で文字列の長さを計算しで調整する。
 *
 *}
  // 見出しと枠線を出力
  ACanvas.Font := fiMincyo;
  ACanvas.FontSize := 12;
  ACanvas.TextOut(X, Y, 'Alignment');
  ACanvas.LineWidth := 0.75;
  ACanvas.DrawRect(X, Y - 5, X + 220, Y - 100, false);

  X := X + 10;
  X2 := X + 200;

  Y := Y - 20;

  S := 'Hello World こんにちは世界';

  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, '左寄せ');
  Y := Y - 12;
  ACanvas.FontSize := 12;
  ACanvas.TextOut(X, Y, S);
  Y := Y - 18;

  ACanvas.FontSize := 8;
  ACanvas.WordSpace := 0;
  ACanvas.TextOut(X-5, Y, '右寄せ');
  Y := Y - 12;
  ACanvas.FontSize := 12;
  {*
   * 文字列の幅を計る（幅はFont,FontSize,CharSpace,WordSpaceによって変わってくる
   * ため各種設定が終わってから計る。
   *}
  SW := ACanvas.TextWidth(S);
  // X2の位置を基準にして右寄せで文字列を出力
  ACanvas.TextOut(X2 - SW, Y, S);
  Y := Y - 18;

  ACanvas.FontSize := 8;
  ACanvas.TextOut(X-5, Y, 'センタリング');
  Y := Y - 12;
  ACanvas.FontSize := 12;
  {*
   * 前回TextWidthで計測したときと同じ文字列・設定のため、SWの値をそのまま使用。
   * X～X2の間にセンタリングして出力する。
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
 *  長い文字列をワードラップして表示するサンプル。
 *  Leadingプロパティで行間隔を指定する。
 *
 *}
  // 見出しと枠線を出力
  ACanvas.Font := fiMincyo;
  ACanvas.FontSize := 10.5;
  ACanvas.TextOut(X, Y, 'Wordwrap');
  ACanvas.LineWidth := 0.75;
  ACanvas.DrawRect(X, Y - 5, X + 220, Y - 110, false);

  X := X + 10;
  Y := Y - 20;

  S := 'PDFMakerではArrengeTextプロシーシャを使用することで' +
       '簡単にワードラップ処理が行えます。' +
       'また、Leadingプロパティによって簡単に行間隔を変更できます。' +
       'ワードラップ処理は１バイト文字の場合は単語単位、２バイト文字の場合は' +
       '文字単位で区切られるので、Sunday Monday Tuesday Wednesday Thursday Friday ' +
       'Saturday のような英文字も適切に区切られます。';

  // 文字列Sを200ドッド幅に整形する。
  ACanvas.ArrangeText(S, S2, 200);
  // 改行間隔をフォントサイズと同じに設定
  ACanvas.Leading := ACanvas.FontSize;

  ACanvas.TextOut(X, Y, S2);

end;

end.
