unit UDBList;
{*
 *  DBList.dpr データベースからのリスト出力デモ
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
    procedure WriteHeader;  // ヘッダーの出力
    procedure WriteFooter;  // フッターの出力
    procedure WritePage;    // 明細の出力
    procedure WriteRow(YPos: Single);  // 各行データの出力
  public
    { Public 宣言 }
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
  // ヘッダーの出力
  with FPDFMaker do
  begin
    // フォントの設定して見出しを出力
    Canvas.Font := fiCenturyBold;
    Canvas.FontSize := 16;
    Canvas.FillColor := clNavy;
    Canvas.TextOut(90, 770, 'Customer.DB');
    // フォントの設定して日付を右寄せで出力
    Canvas.Font := fiCentury;
    Canvas.FontSize := 9;
    S := FormatDateTime('YYYY/MM/DD', Date);
    w := Canvas.TextWidth(S);
    Canvas.TextOut(530 - w, 770, s);
    // 下線を出力
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
    // フォントを設定してページ番号を真ん中に出力
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
    // 外枠を書く
    Canvas.LineWidth := 1.25;
    Canvas.DrawRect(90, 760, 530, 80, false);
    Canvas.LineTo(90, 740, 530, 740);

    // 横罫線を書く
    YPos := 740;
    Canvas.LineWidth := 0.75;
    for i := 0 to 31 do
    begin
      YPos := YPos - 20;
      Canvas.LineTo(90, YPos, 530, YPos);
    end;

    // 縦罫線と項目名を書く
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

    // 明細行のフォントの設定
    Canvas.Font := fiMincyo;
    Canvas.FontSize := 10.5;
    Canvas.FillColor := clBlack;
  end;

  // 20ドット間隔で明細行を出力
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
   // 各行データの出力
  with FPDFMaker do
  begin
    if not Query1.Eof then
    begin
      Canvas.TextOut(95, YPos - 15, Query1.FieldByName('CustNo').AsString);

      // MeasureTextで項目に入る文字列の数をはかり、入る分だけ出力
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
  // FPDFMakerのインスタンスを作成
  FPDFMaker := TPDFMaker.Create;
  with FPDFMaker do
  begin
    Author := 'Takezou';
    Title := 'データベースからの印刷';
    // BeginDocを呼び出す（パラメタにはTFileStreamを作成して渡す）
    BeginDoc(TFileStream.Create('DBList.pdf', fmCreate));
    // Queryをオープンし、データが無くなるまでページ単位で出力
    Query1.Open;
    while not Query1.Eof do
    begin
      WriteHeader;
      WritePage;
      WriteFooter;
      if not Query1.Eof then
        NewPage;
    end;

    // 終了処理
    Query1.Close;
    EndDoc(true);
    Free;
  end;

  // ここから先はおまけ。作成したPDFファイルを表示
  if MessageDlg('レポート(DBDemo.pdf)作成が終了しました。表示しますか？',
                           mtInformation, [mbYes, mbNO], 0) = mrYes then
    ShellExecute(Self.Handle, 'open', 'DBList.pdf', '', '', SW_SHOW);
  Close;
end;

end.
