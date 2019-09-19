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
  pdf.Title   := '����';
  pdf.Author  := '���{��v���O���~���O����u�Ȃł����v';
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
    raise Exception.Create('��ɁuPDF�J���v�Ńt�@�C�����w�肵�Ă��������B');  
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
    raise Exception.Create('��ɁuPDF�J���v�Ńt�@�C�����w�肵�Ă��������B');
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
    raise Exception.Create('��ɁuPDF�J���v�Ńt�@�C�����w�肵�Ă��������B');
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
    raise Exception.Create('��ɁuPDF�J���v�Ńt�@�C�����w�肵�Ă��������B');
  end;
  if pos('����', s) > 0 then
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
    raise Exception.Create('��ɁuPDF�J���v�Ńt�@�C�����w�肵�Ă��������B');
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
    raise Exception.Create('��ɁuPDF�J���v�Ńt�@�C�����w�肵�Ă��������B');
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
    raise Exception.Create('��ɁuPDF�J���v�Ńt�@�C�����w�肵�Ă��������B');
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
    raise Exception.Create('��ɁuPDF�J���v�Ńt�@�C�����w�肵�Ă��������B');
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
    raise Exception.Create('��ɁuPDF�J���v�Ńt�@�C�����w�肵�Ă��������B');
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
    raise Exception.Create('��ɁuPDF�J���v�Ńt�@�C�����w�肵�Ă��������B');
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
    raise Exception.Create('��ɁuPDF�J���v�Ńt�@�C�����w�肵�Ă��������B');
  end;
  pdf.Canvas.StrokeColor := RGB2Color(col);
  penColor := pdf.Canvas.StrokeColor;
  Result := nil;
end;

function cmd_pdf_getPageWidth(h: DWORD): PHiValue; stdcall;
begin
  if fpdf = nil then
  begin
    raise Exception.Create('��ɁuPDF�J���v�Ńt�@�C�����w�肵�Ă��������B');
  end;
  Result := hi_newFloat(pdf.PageWidth);
end;

function cmd_pdf_getPageHeight(h: DWORD): PHiValue; stdcall;
begin
  if fpdf = nil then
  begin
    raise Exception.Create('��ɁuPDF�J���v�Ńt�@�C�����w�肵�Ă��������B');
  end;
  Result := hi_newFloat(pdf.PageHeight);
end;

function cmd_pdf_newpage(h: DWORD): PHiValue; stdcall;
begin
  if fpdf = nil then
  begin
    raise Exception.Create('��ɁuPDF�J���v�Ńt�@�C�����w�肵�Ă��������B');
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
  //todo: ���߂̒�`
  //<����>

  //+PDF[�f���b�N�X�ł̂�](nakopdf.dll)
  //-PDF��{
  AddFunc('PDF�J��',            'FNAME��|FNAME��|FNAME��',  6500, cmd_pdf_open,     '�쐬����PDF�t�@�C��FNAME���������ݐ�p�ŊJ���B','PDF�Ђ炭');
  AddFunc('PDF����','',                                   6501, cmd_pdf_close,    'PDF�t�@�C���̏������݂��I������B','PDF�Ƃ���');
  //PDF�`��
  AddFunc('PDF�����`��',        '{=?}S��X,Y��|Y��',         6502, cmd_pdf_textout,  'PDF�ɕ�����S��X,Y(��{�_�͍���)�̈ʒu�ɕ`�悷��','PDF�����т傤��');
  AddFunc('PDF���`��',          'X1,Y1����X2,Y2��',         6503, cmd_pdf_line,     'PDF��X1,Y1����X2,Y2��(��{�_�͍���)����`�悷��','PDF����т傤��');
  AddFunc('PDF�l�p�`��',        'X1,Y1����X2,Y2��',         6504, cmd_pdf_rectangle,'PDF��X1,Y1����X2,Y2��(��{�_�͍���)�l�p��`�悷��','PDF�������т傤��');
  AddFunc('PDF���y�[�W',        '',                         6505, cmd_pdf_newpage,  'PDF�ŐV�K�y�[�W�ɉ��y�[�W����B','PDF�����؁[��');
  //-PDF�ݒ�
  AddFunc('PDF��Ґݒ�',        'NAME��|NAME��',            6510, cmd_pdf_author,   'PDF�t�@�C���̍�҂��w�肷��B','PDF�������Ⴙ���Ă�');
  AddFunc('PDF�^�C�g���ݒ�',    'TITLE��|TITLE��',          6511, cmd_pdf_title,    'PDF�t�@�C���̃^�C�g�����w�肷��B','PDF�����Ƃ邹���Ă�');
  AddFunc('PDF�t�H���g�ݒ�',    'FONT��|FONT��',            6512, cmd_pdf_font,     'PDF�̃t�H���g��FONT�ɕύX����B�u�S�V�b�N|�����v�̉��ꂩ���w�肷��B','PDF�ӂ���Ƃ����Ă�');
  AddFunc('PDF�����T�C�Y�ݒ�',  'SIZE��|SIZE��',            6513, cmd_pdf_fontsize, 'PDF�̕����T�C�Y��SIZE�ɕύX����B�u�S�V�b�N|�����v�̉��ꂩ���w�肷��B','PDF���������������Ă�');
  AddFunc('PDF�����F�ݒ�',      'COL��|COL��',              6514, cmd_pdf_fontcol,  'PDF�̕����F��COL($RRGGBB)�ɕύX����B','PDF�������傭�����Ă�');
  AddFunc('PDF���F�ݒ�',        'COL��|COL��',              6515, cmd_pdf_pencol,   'PDF�̐��̐F��COL($RRGGBB)�ɕύX����B','PDF���񂢂낹���Ă�');
  AddFunc('PDF�������ݒ�',      'SIZE��|SIZE��',            6516, cmd_pdf_penwidth, 'PDF�̐��̑�����SIZE�ɕύX����B','PDF����ӂƂ������Ă�');
  AddFunc('PDF�h��F�ݒ�',      'COL��|COL��',              6517, cmd_pdf_brushcol, 'PDF�̓h��̐F��COL($RRGGBB)�ɕύX����B','PDF�ʂ肢�낹���Ă�');
  //-PDF�擾
  AddFunc('PDF�y�[�W���擾',    '',                         6530, cmd_pdf_getPageWidth,   'PDF�Ńy�[�W�̕����擾����',    'PDF�؁[���͂΂���Ƃ�');
  AddFunc('PDF�y�[�W�����擾',  '',                         6531, cmd_pdf_getPageHeight,  'PDF�Ńy�[�W�̍������擾����',  'PDF�؁[������������Ƃ�');

  //</����>
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
