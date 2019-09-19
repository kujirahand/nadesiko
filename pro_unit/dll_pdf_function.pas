unit dll_pdf_function;

interface

uses
  Windows, SysUtils, Classes;

procedure RegistFunction;

implementation

uses dll_plugin_helper, dnako_import, dnako_import_types, Variants,
  PDFMaker, PMFonts, Graphics;


var
  fpdf: TPDFMaker = nil;
  fpdf_closed: Boolean;
  fillColor: Integer = 0;
  penColor: Integer = 0;
  fontid: TPDFFontID = fiGothic;
  fontsize: Integer = 12;


function RGB2Color(c: Integer): Integer;
var
  r,g,b:Byte;
begin
  // RR GG BB
  // BB GG RR
  r := (c shr 16) and $FF;
  g := (c shr 8 ) and $FF;
  b := (c       ) and $FF;
  Result := RGB(r, g, b);
end;

function Color2RGB(c: TColor): Integer;
var
  r,g,b:Byte;
begin
  c := ColorToRGB(c);
  //
  r := (c shr 16) and $FF;
  g := (c shr 8 ) and $FF;
  b := (c       ) and $FF;
  //
  Result := (b shl 16) or (g shl 8) or r;
end;

function pdf: TPDFMaker;
begin
  if fpdf = nil then fpdf := TPDFMaker.Create;
  Result := fpdf;
end;

function cmd_pdf_open(h: DWORD): PHiValue; stdcall;
var
  fname: string;
begin
  fname := getArgStr(h, 0);
  pdf.Title   := '無題';
  pdf.Author  := '日本語プログラミング言語「なでしこ」';
  pdf.BeginDoc(TFileStream.Create(fname, fmCreate));
  pdf.Canvas.Font     := fiGothic;
  pdf.Canvas.FontSize := 12;
  Result := nil;
end;

function cmd_pdf_close(h: DWORD): PHiValue; stdcall;
begin
  pdf.EndDoc(True);
  Result := nil;
  fpdf_closed := True;
end;

function cmd_pdf_author(h: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  s := getArgStr(h, 0);
  if fpdf = nil then
  begin
    raise Exception.Create('先に「PDF開く」でファイルを指定してください。');  
  end;
  pdf.Author  := s;
  Result := nil;
end;

function cmd_pdf_title(h: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  s := getArgStr(h, 0);
  if fpdf = nil then
  begin
    raise Exception.Create('先に「PDF開く」でファイルを指定してください。');
  end;
  pdf.Title  := s;
  Result := nil;
end;

function cmd_pdf_textout(h: DWORD): PHiValue; stdcall;
var
  s: string;
  x,y: Extended;
begin
  s := getArgStr(h, 0);
  x := getArgFloat(h, 1);
  y := getArgFloat(h, 2);
  if fpdf = nil then
  begin
    raise Exception.Create('先に「PDF開く」でファイルを指定してください。');
  end;
  pdf.Canvas.TextOut(x, y, s);
  Result := nil;
end;

function cmd_pdf_font(h: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  s := getArgStr(h, 0);
  if fpdf = nil then
  begin
    raise Exception.Create('先に「PDF開く」でファイルを指定してください。');
  end;
  if pos('明朝', s) > 0 then
  begin
    pdf.Canvas.Font := fiMincyo;
  end else
  begin
    pdf.Canvas.Font := fiGothic;
  end;
  fontid := pdf.Canvas.Font;
  Result := nil;
end;

function cmd_pdf_fontsize(h: DWORD): PHiValue; stdcall;
var
  sz: Integer;
begin
  sz := getArgInt(h, 0);
  if fpdf = nil then
  begin
    raise Exception.Create('先に「PDF開く」でファイルを指定してください。');
  end;
  pdf.Canvas.FontSize := sz;
  fontsize := sz;
  Result := nil;
end;

function cmd_pdf_fontcol(h: DWORD): PHiValue; stdcall;
var
  c: Integer;
begin
  c := getArgInt(h, 0);
  if fpdf = nil then
  begin
    raise Exception.Create('先に「PDF開く」でファイルを指定してください。');
  end;
  pdf.Canvas.FillColor := RGB2Color(c);
  fillColor := pdf.Canvas.FillColor;
  Result := nil;
end;

function cmd_pdf_brushcol(h: DWORD): PHiValue; stdcall;
var
  c: Integer;
begin
  c := getArgInt(h, 0);
  if fpdf = nil then
  begin
    raise Exception.Create('先に「PDF開く」でファイルを指定してください。');
  end;
  pdf.Canvas.FillColor := RGB2Color(c);
  fillColor := pdf.Canvas.FillColor;
  Result := nil;
end;

function cmd_pdf_penwidth(h: DWORD): PHiValue; stdcall;
var
  c: Integer;
begin
  c := getArgInt(h, 0);
  if fpdf = nil then
  begin
    raise Exception.Create('先に「PDF開く」でファイルを指定してください。');
  end;
  pdf.Canvas.LineWidth := c;
  Result := nil;
end;

function cmd_pdf_line(h: DWORD): PHiValue; stdcall;
var
  x1,y1, x2,y2: Extended;
begin
  x1 := getArgFloat(h, 0);
  y1 := getArgFloat(h, 1);
  x2 := getArgFloat(h, 2);
  y2 := getArgFloat(h, 3);
  if fpdf = nil then
  begin
    raise Exception.Create('先に「PDF開く」でファイルを指定してください。');
  end;
  pdf.Canvas.LineTo(x1,y1,x2,y2);
  Result := nil;
end;

function cmd_pdf_rectangle(h: DWORD): PHiValue; stdcall;
var
  x1,y1, x2,y2: Extended;
begin
  x1 := getArgFloat(h, 0);
  y1 := getArgFloat(h, 1);
  x2 := getArgFloat(h, 2);
  y2 := getArgFloat(h, 3);
  if fpdf = nil then
  begin
    raise Exception.Create('先に「PDF開く」でファイルを指定してください。');
  end;
  pdf.Canvas.FillRect(x1, y1, x2, y2, False);
  Result := nil;
end;

function cmd_pdf_pencol(h: DWORD): PHiValue; stdcall;
var
  col: Integer;
begin
  col := getArgInt(h, 0);
  if fpdf = nil then
  begin
    raise Exception.Create('先に「PDF開く」でファイルを指定してください。');
  end;
  pdf.Canvas.StrokeColor := RGB2Color(col);
  penColor := pdf.Canvas.StrokeColor;
  Result := nil;
end;

function cmd_pdf_getPageWidth(h: DWORD): PHiValue; stdcall;
begin
  if fpdf = nil then
  begin
    raise Exception.Create('先に「PDF開く」でファイルを指定してください。');
  end;
  Result := hi_newFloat(pdf.PageWidth);
end;

function cmd_pdf_getPageHeight(h: DWORD): PHiValue; stdcall;
begin
  if fpdf = nil then
  begin
    raise Exception.Create('先に「PDF開く」でファイルを指定してください。');
  end;
  Result := hi_newFloat(pdf.PageHeight);
end;

function cmd_pdf_newpage(h: DWORD): PHiValue; stdcall;
begin
  if fpdf = nil then
  begin
    raise Exception.Create('先に「PDF開く」でファイルを指定してください。');
  end;
  pdf.NewPage;
  pdf.Canvas.FillColor    := fillColor;
  pdf.Canvas.StrokeColor  := penColor;
  pdf.Canvas.Font         := fontid;
  pdf.Canvas.FontSize     := fontsize;
  Result := nil;
end;

procedure RegistFunction;
begin
  //:::::::nakopdf.dll,6500-6550
  //todo: 命令の定義
  //<命令>

  //+PDF[デラックス版のみ](nakopdf.dll)
  //-PDF基本
  AddFunc('PDF開く',            'FNAMEで|FNAMEの|FNAMEを',  6500, cmd_pdf_open,     '作成するPDFファイルFNAMEを書き込み専用で開く。','PDFひらく');
  AddFunc('PDF閉じる','',                                   6501, cmd_pdf_close,    'PDFファイルの書き込みを終了する。','PDFとじる');
  //PDF描画
  AddFunc('PDF文字描画',        '{=?}SをX,Yへ|Yに',         6502, cmd_pdf_textout,  'PDFに文字列SをX,Y(基本点は左下)の位置に描画する','PDFもじびょうが');
  AddFunc('PDF線描画',          'X1,Y1からX2,Y2へ',         6503, cmd_pdf_line,     'PDFにX1,Y1からX2,Y2へ(基本点は左下)線を描画する','PDFせんびょうが');
  AddFunc('PDF四角描画',        'X1,Y1からX2,Y2へ',         6504, cmd_pdf_rectangle,'PDFにX1,Y1からX2,Y2へ(基本点は左下)四角を描画する','PDFしかくびょうが');
  AddFunc('PDF改ページ',        '',                         6505, cmd_pdf_newpage,  'PDFで新規ページに改ページする。','PDFかいぺーじ');
  //-PDF設定
  AddFunc('PDF作者設定',        'NAMEに|NAMEで',            6510, cmd_pdf_author,   'PDFファイルの作者を指定する。','PDFさくしゃせってい');
  AddFunc('PDFタイトル設定',    'TITLEに|TITLEで',          6511, cmd_pdf_title,    'PDFファイルのタイトルを指定する。','PDFたいとるせってい');
  AddFunc('PDFフォント設定',    'FONTに|FONTへ',            6512, cmd_pdf_font,     'PDFのフォントをFONTに変更する。「ゴシック|明朝」の何れかを指定する。','PDFふぉんとせってい');
  AddFunc('PDF文字サイズ設定',  'SIZEに|SIZEへ',            6513, cmd_pdf_fontsize, 'PDFの文字サイズをSIZEに変更する。「ゴシック|明朝」の何れかを指定する。','PDFもじさいずせってい');
  AddFunc('PDF文字色設定',      'COLに|COLへ',              6514, cmd_pdf_fontcol,  'PDFの文字色をCOL($RRGGBB)に変更する。','PDFもじしょくせってい');
  AddFunc('PDF線色設定',        'COLに|COLへ',              6515, cmd_pdf_pencol,   'PDFの線の色をCOL($RRGGBB)に変更する。','PDFせんいろせってい');
  AddFunc('PDF線太さ設定',      'SIZEに|SIZEへ',            6516, cmd_pdf_penwidth, 'PDFの線の太さをSIZEに変更する。','PDFせんふとさせってい');
  AddFunc('PDF塗り色設定',      'COLに|COLへ',              6517, cmd_pdf_brushcol, 'PDFの塗りの色をCOL($RRGGBB)に変更する。','PDFぬりいろせってい');
  //-PDF取得
  AddFunc('PDFページ幅取得',    '',                         6530, cmd_pdf_getPageWidth,   'PDFでページの幅を取得する',    'PDFぺーじはばしゅとく');
  AddFunc('PDFページ高さ取得',  '',                         6531, cmd_pdf_getPageHeight,  'PDFでページの高さを取得する',  'PDFぺーじたかさしゅとく');

  //</命令>
end;

initialization
  fpdf := nil;
  fpdf_closed := False;
  
finalization
  if (false = fpdf_closed) and (fpdf <> nil) then
  begin
    fpdf.EndDoc(True);
  end;
  FreeAndNil(fpdf);

end.
