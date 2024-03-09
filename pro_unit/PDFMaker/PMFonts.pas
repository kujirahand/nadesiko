{*
 *
 *   PMFonts.pas
 *
 *   PDFMakerで使用するフォント定義のユニット

     2000/01/19 MSPXXXフォントをMSXXXに変更（このほうが仮名が奇麗に表示される）
     2000/01/20 GetCharWidthルーチンの実装
 *
 *   ToDo Widthsから各文字の幅を取得するルーチンの作成。
 *        日本語フォントの1バイト文字の幅取得が難しい

          日本語フォントは漢字・平仮名はすべて1000
          英字はＷ文字列の１～が文字コード#31～に相当する。


 *
 *}
unit PMFonts;

interface

uses
  Windows, SysUtils, Classes;

const
  MAX_PDF_FONT_INDEX = 7;

type
  TPDFFontDescriptorDef = class;

  TPDFFontID = (fiCentury,
                fiCenturyBold,
                fiArial,
                fiArialBold,
                fiCourier,
                fiCourierBold,
                fiMincyo,
                fiGothic);

  {*
   *  TPDFFontDef
   *  Font定義の基本型
   *
   *}
  TPDFFontDef = class(TObject)
  private
    FSubtype: string;
    FBaseFont: string;
    FFontDescriptor: TPDFFontDescriptorDef;
    FDescendantFont: TPDFFontDef;
    FFontID: TPDFFontID;
    FWArray: array[0..255] of Integer;
  protected
    function GetDetailString: string; virtual;
    procedure CreateFontDef; virtual;
    procedure InitFontDef; virtual;
    property Subtype: string read FSubtype write FSubtype;
    property BaseFont: string read FBaseFont write FBaseFont;
  public
    constructor Create; virtual;
    function GetCharWidth(C: Char): integer;
    property DetailString: string read GetDetailString;
    property FontDescriptor: TPDFFontDescriptorDef read FFontDescriptor;
    property DescendantFont: TPDFFontDef read FDescendantFont;
    property FontID: TPDFFontID read FFontID;
  end;

  {*
   *  TPDFTrueTypeFontDef
   *  TrueTypeFont定義の基本型
   *
   *}
  TPDFTrueTypeFontDef = class(TPDFFontDef)
  private
    FFirstChar: Byte;
    FLastChar: Byte;
    FWidths: string;
    FEncoding: string;
  protected
    function GetDetailString: string; override;
    procedure InitFontDef; override;
  public
    property FirstChar: Byte read FFirstChar write FFirstChar;
    property LastChar: Byte read FLastChar write FLastChar;
    property Encoding: string read FEncoding write FEncoding;
    property Widths: string read FWidths write FWidths;
  end;

  {*
   *  TPDFType0FontDef
   *  Type0Font定義の基本型
   *
   *}
  TPDFType0FontDef = class(TPDFFontDef)
  private
    FEncoding: string;
  protected
    function GetDetailString: string; override;
  public
    property Encoding: string read FEncoding write FEncoding;
  end;

  {*
   *  TPDFCID2FontDef
   *  CID type2 Font定義の基本型
   *
   *}
  TPDFCID2FontDef = class(TPDFFontDef)
  private
    FWinCharSet: integer;
    FCIDSystemInfo: string;
    FDW: integer;
    FW: string;
  protected
    function GetDetailString: string; override;
    procedure InitFontDef; override;
  public
    property WinCharSet: integer read FWinCharSet write FWinCharSet;
    property CIDSystemInfo: string read FCIDSystemInfo write FCIDSystemInfo;
    property DW: integer read FDW write FDW;
    property W: string read FW write FW;
  end;

  {*
   *  TPDFFontDescriptorDef
   *  FontDescriptor定義
   *
   *}
  TPDFFontDescriptorDef = class(TObject)
  private
    FAscent: integer;
    FCapHeight: integer;
    FDescent: integer;
    FFlags: integer;
    FFontBBox: TRect;
    FFontName: string;
    FItalicAngle: integer;
    FStemV: integer;
  public
    property Ascent: integer read FAscent write FAscent;
    property CapHeight: integer read FCapHeight write FCapHeight;
    property Descent: integer read FDescent write FDescent;
    property Flags: integer read FFlags write FFlags;
    property FontBBox: TRect read FFontBBox write FFontBBox;
    property FontName: string read FFontName write FFontName;
    property ItalicAngle: integer read FItalicAngle write FItalicAngle;
    property StemV: integer read FStemV write FStemV;
  end;

  {*
   *  TCenturyFontDef
   *
   *}
  TCenturyFontDef = class(TPDFTrueTypeFontDef)
  protected
    procedure CreateFontDef; override;
  public
  end;

  {*
   *  TCenturyBoldFontDef
   *
   *}
  TCenturyBoldFontDef = class(TPDFTrueTypeFontDef)
  protected
    procedure CreateFontDef; override;
  public
  end;

  {*
   *  TArialFontDef
   *
   *}
  TArialFontDef = class(TPDFTrueTypeFontDef)
  protected
    procedure CreateFontDef; override;
  public
  end;

  {*
   *  TArialBoldFontDef
   *
   *}
  TArialBoldFontDef = class(TPDFTrueTypeFontDef)
  protected
    procedure CreateFontDef; override;
  public
  end;

  {*
   *  TCourierFontDef
   *
   *}
  TCourierFontDef = class(TPDFTrueTypeFontDef)
  protected
    procedure CreateFontDef; override;
  public
  end;

  {*
   *  TCourierBoldFontDef
   *
   *}
  TCourierBoldFontDef = class(TPDFTrueTypeFontDef)
  protected
    procedure CreateFontDef; override;
  public
  end;

  {*
   *  TMSMincyoFontDef
   *
   *}
  TMSMincyoFontDef = class(TPDFType0FontDef)
  protected
    procedure CreateFontDef; override;
  public
  end;

  {*
   *  TMSMincyoDFontDef -- TMSMincyoFontDefのDescendantFont
   *
   *}
  TMSMincyoDFontDef = class(TPDFCID2FontDef)
  protected
    procedure CreateFontDef; override;
  public
  end;

  {*
   *  TMSGothicFontDef
   *
   *}
  TMSGothicFontDef = class(TPDFType0FontDef)
  protected
    procedure CreateFontDef; override;
  public
  end;

  {*
   *  TMSGothicDFontDef -- TMSGothicFontDefのDescendantFont
   *
   *}
  TMSGothicDFontDef = class(TPDFCID2FontDef)
  protected
    procedure CreateFontDef; override;
  public
  end;

  function CreateFont(FontID: TPDFFontID): TPDFFontDef;

implementation

const
  CRLF = #13#10;

function CreateFont(FontID: TPDFFontID): TPDFFontDef;
begin
  case FontID of
    fiCentury: result := TCenturyFontDef.Create;
    fiCenturyBold: Result := TCenturyBoldFontDef.Create;
    fiArial: Result := TArialFontDef.Create;
    fiArialBold: Result := TArialBoldFontDef.Create;
    fiCourier: Result := TCourierFontDef.Create;
    fiCourierBold: Result := TCourierBoldFontDef.Create;
    fiMincyo: Result := TMSMincyoFontDef.Create;
    fiGothic: Result := TMSGothicFontDef.Create;
  else
    raise Exception.CreateFmt('このフォントは現在サポートされていません (%d)', [ord(FontID)]);
  end;
end;

{ TPDFFontDef }

function TPDFFontDef.GetDetailString: string;
begin
  { virtual method }
  result := '';
end;

procedure TPDFFontDef.InitFontDef;
begin
  {*
   * virtual method
   * このメソッドは、CreateFontDefで各フォントごとの初期設定が行われた
   * 後に呼び出される。主にフォント幅のテーブルを作成する。
   *
   * CreateFontDef: 各フォントごとの個別設定
   * InitFont: フォント種別（グループ）ごとの個別設定
   *
   *}
end;

function TPDFFontDef.GetCharWidth(C: Char): integer;
begin
  if DescendantFont = nil then
    result := FWArray[ord(C)]
  else
    result := FDescendantFont.GetCharWidth(C);
end;

procedure TPDFFontDef.CreateFontDef;
begin
  {*
   * virtual method
   * この中で、各Fontごとの個別の設定を行う。
   * 必要であればDecendantFontやFontDescriptorを作成する。
   * 作成されたDecendantFontやFontDescriptorは基本的にPDFMaker側で
   * 開放する。
   *
   *}
end;

constructor TPDFFontDef.Create;
begin
  FFontDescriptor := nil;
  FDescendantFont := nil;
  CreateFontDef;
  InitFontDef;
end;

{ TPDFTrueTypeFontDef }

procedure TPDFTrueTypeFontDef.InitFontDef;
var
  CurPos, MaxPos: integer;
  i: integer;
  tmpStr: string;
begin
  {*
   *  FWidthの文字列を基にして、FWArrayを作成する。
   *
   *}
  CurPos := 1;
  i := FirstChar;
  MaxPos := Length(FWidths);
  while CurPos <= MaxPos do
  begin
    // 数字がみつかったら
    if FWidths[CurPos] in ['0'..'9'] then
    begin
      tmpStr := '';
      while (CurPos <= MaxPos) and (FWidths[CurPos] in ['0'..'9']) do
      begin
        tmpStr := tmpStr + FWidths[CurPos];
        inc(CurPos);
      end;
      FWArray[i] := StrToInt(tmpStr);
      inc(i);
    end
    else
      inc(CurPos);
  end;
  // 半角スペースは小文字"i"の幅（とりあえず）
  FWArray[20] := FWArray[ord(i)];
end;

function TPDFTrueTypeFontDef.GetDetailString: string;
begin
  result := '/Subtype /' + Subtype + CRLF +
            '/BaseFont /' + BaseFont + CRLF +
            '/FirstChar ' + IntToStr(FirstChar) + CRLF +
            '/LastChar ' + IntToStr(LastChar) + CRLF +
            '/Widths ' + Widths + CRLF +
            '/Encoding /' + Encoding  + CRLF;
end;

{ TPDFType0FontDef }
function TPDFType0FontDef.GetDetailString: string;
begin
  result := '/Subtype /' + Subtype + CRLF +
            '/BaseFont /' + BaseFont + CRLF +
            '/Encoding /' + Encoding  + CRLF;
end;

{ TPDFCID2FontDef }
procedure TPDFCID2FontDef.InitFontDef;
var
  CurPos, MaxPos: integer;
  i: integer;
  tmpStr: string;
begin
  {*
   *  FWの文字列を基にして、FWArrayを作成する。
   *  2バイト文字の幅は、FWArrey[0]であらわす。
   *
   *}
  MaxPos := Length(FW);
  CurPos := Pos('1 [' , FW) + Length('1 [');
  i := 32;
  while (CurPos <= MaxPos) and (FW[CurPos] <> ']') do
  begin
    // 数字がみつかったら
    if FW[CurPos] in ['0'..'9'] then
    begin
      tmpStr := '';
      while (CurPos <= MaxPos) and (FW[CurPos] in ['0'..'9']) do
      begin
        tmpStr := tmpStr + FW[CurPos];
        inc(CurPos);
      end;
      FWArray[i] := StrToInt(tmpStr);
      inc(i);
    end
    else
      inc(CurPos);
  end;

  MaxPos := Length(FW);
  CurPos := Pos('326 [' , FW) + Length('326 [');
  i := 160;
  while (CurPos <= MaxPos) and (FW[CurPos] <> ']') do
  begin
    // 数字がみつかったら
    if FW[CurPos] in ['0'..'9'] then
    begin
      tmpStr := '';
      while (CurPos <= MaxPos) and (FW[CurPos] in ['0'..'9']) do
      begin
        tmpStr := tmpStr + FW[CurPos];
        inc(CurPos);
      end;
      FWArray[i] := StrToInt(tmpStr);
      inc(i);
    end
    else
      inc(CurPos);
  end;
  // 半角スペースは小文字"i"の幅（とりあえず）
  FWArray[20] := FWArray[ord(i)];
  // ２バイト文字の幅はFWArray[0]であらわす.
  FWArray[0] := DW;
end;

function TPDFCID2FontDef.GetDetailString: string;
begin
  result := '/Subtype /' + Subtype + CRLF +
            '/BaseFont /' + BaseFont + CRLF +
            '/WinCharSet /' + IntToStr(WinCharSet)  + CRLF +
            '/CIDSystemInfo <<' + CRLF + CIDSystemInfo + CRLF + '>>' + CRLF +
            '/DW ' + IntToStr(DW) + CRLF +
            '/W ' + W + CRLF;
end;

{ TCenturyFontDef }
procedure TCenturyFontDef.CreateFontDef;
begin
  FFontID := fiCentury;
  Subtype := 'TrueType';
  BaseFont := 'Century';
  FirstChar := 31;
  LastChar := 255;
  Widths := '[ 719 266 283 373 533 533 798 781 196 319 319 479 581 266 319 266 ' + CRLF +
    '266 533 533 533 533 533 533 533 533 533 533 266 266 581 581 581 ' + CRLF +
    '426 706 692 692 692 745 692 639 745 798 390 533 745 639 904 781 ' + CRLF +
    '745 639 745 692 604 639 781 692 940 675 675 585 319 581 319 581 ' + CRLF +
    '479 319 533 533 426 550 479 319 515 585 302 283 568 302 852 585 ' + CRLF +
    '479 550 533 426 443 373 585 515 745 515 515 461 319 581 319 581 ' + CRLF +
    '719 719 719 196 533 373 958 479 479 319 958 604 248 958 719 719 ' + CRLF +
    '719 719 196 196 373 373 581 533 958 319 958 443 248 798 719 719 ' + CRLF +
    '675 275 283 533 533 581 675 581 479 319 706 320 408 581 319 706 ' + CRLF +
    '719 383 526 319 319 319 552 581 266 319 319 288 408 798 798 798 ' + CRLF +
    '426 692 692 692 692 692 692 958 692 692 692 692 692 390 390 390 ' + CRLF +
    '390 745 781 745 745 745 745 745 581 745 781 781 781 781 675 639 ' + CRLF +
    '550 533 533 533 533 533 533 763 426 479 479 479 479 302 302 302 ' + CRLF +
    '302 479 585 479 479 479 479 479 526 479 585 585 585 585 515 550 ' + CRLF +
    '515 ]';
  Encoding := 'WinAnsiEncoding';
  FFontDescriptor := TPDFFontDescriptorDef.Create;
  with FFontDescriptor do
  begin
    FontName := 'Century';
    Flags := 34;
    FontBBox := Rect(-219, -219, 1188, 1001);
    Stemv := 78;
    ItalicAngle := 0;
    CapHeight := 1001;
    Ascent := 1001;
    Descent := -219;
  end;
end;

{ TCenturyBoldFontDef }
procedure TCenturyBoldFontDef.CreateFontDef;
begin
  FFontID := fiCenturyBold;
  Subtype := 'TrueType';
  BaseFont := 'Century,Bold';
  FirstChar := 31;
  LastChar := 255;
  Widths := '[ 719 267 284 374 533 533 799 781 196 320 320 480 581 267 320 267 ' + CRLF +
    '267 533 533 533 533 533 533 533 533 533 533 267 267 581 581 581 ' + CRLF +
    '426 707 693 693 693 746 693 640 746 799 391 533 746 640 905 781 ' + CRLF +
    '746 640 746 693 604 640 781 693 941 676 676 586 320 581 320 581 ' + CRLF +
    '480 320 533 533 426 551 480 320 515 586 303 284 569 303 852 586 ' + CRLF +
    '480 551 533 426 444 374 586 515 746 515 515 461 320 581 320 581 ' + CRLF +
    '719 719 719 196 533 374 959 480 480 320 959 604 249 959 719 719 ' + CRLF +
    '719 719 196 196 374 374 581 533 959 320 959 444 249 799 719 719 ' + CRLF +
    '676 276 284 533 533 581 676 581 480 320 707 321 409 581 320 707 ' + CRLF +
    '719 384 527 320 320 320 553 581 267 320 320 288 409 799 799 799 ' + CRLF +
    '426 693 693 693 693 693 693 959 693 693 693 693 693 391 391 391 ' + CRLF +
    '391 746 781 746 746 746 746 746 581 746 781 781 781 781 676 640 ' + CRLF +
    '551 533 533 533 533 533 533 763 426 480 480 480 480 303 303 303 ' + CRLF +
    '303 480 586 480 480 480 480 480 527 480 586 586 586 586 515 551 ' + CRLF +
    '515 ]';
  Encoding := 'WinAnsiEncoding';
  FFontDescriptor := TPDFFontDescriptorDef.Create;
  with FFontDescriptor do
  begin
    FontName := 'Century,Bold';
    Flags := 16416;
    FontBBox := Rect(-219, -219, 1189, 1001);
    Stemv := 156;
    ItalicAngle := 0;
    CapHeight := 1001;
    Ascent := 1001;
    Descent := -219;
  end;
end;

{ TArialFontDef }
procedure TArialFontDef.CreateFontDef;
begin
  FFontID := fiArial;
  Subtype := 'TrueType';
  BaseFont := 'Arial';
  FirstChar := 31;
  LastChar := 255;
  Widths := '[ 719 266 266 340 533 533 852 639 183 319 319 373 559 266 319 266 ' + CRLF +
    '266 533 533 533 533 533 533 533 533 533 533 266 266 559 559 559 ' + CRLF +
    '533 972 639 639 692 692 639 585 745 692 266 479 639 533 798 692 ' + CRLF +
    '745 639 745 692 639 585 692 639 904 639 639 585 266 266 266 449 ' + CRLF +
    '533 319 533 533 479 533 533 266 533 533 213 213 479 213 798 533 ' + CRLF +
    '533 533 533 319 479 266 533 479 692 479 479 479 320 249 320 559 ' + CRLF +
    '719 533 719 213 533 319 958 533 533 319 958 639 319 958 719 585 ' + CRLF +
    '719 719 213 213 319 319 336 533 958 319 958 479 319 904 719 479 ' + CRLF +
    '639 266 319 533 533 533 533 249 533 319 706 354 533 559 319 706 ' + CRLF +
    '529 383 526 319 319 319 552 515 266 319 319 350 533 799 799 799 ' + CRLF +
    '585 639 639 639 639 639 639 958 692 639 639 639 639 266 266 266 ' + CRLF +
    '266 692 692 745 745 745 745 745 559 745 692 692 692 692 639 639 ' + CRLF +
    '585 533 533 533 533 533 533 852 479 533 533 533 533 266 266 266 ' + CRLF +
    '266 533 533 533 533 533 533 533 526 585 533 533 533 533 479 533 ' + CRLF +
    '479 ]';
  Encoding := 'WinAnsiEncoding';
  FFontDescriptor := TPDFFontDescriptorDef.Create;
  with FFontDescriptor do
  begin
    FontName := 'Arial';
    Flags := 32;
    FontBBox := Rect(-215, -215, 1313, 919);
    Stemv := 78;
    ItalicAngle := 0;
    CapHeight := 919;
    Ascent := 919;
    Descent := -215;
  end;
end;

{ TArialBoldFontDef }
procedure TArialBoldFontDef.CreateFontDef;
begin
  FFontID := fiArialBold;
  Subtype := 'TrueType';
  BaseFont := 'Arial,Bold';
  FirstChar := 31;
  LastChar := 255;
  Widths := '[ 719 266 319 454 533 533 852 692 228 319 319 373 559 266 319 266 ' + CRLF +
    '266 533 533 533 533 533 533 533 533 533 533 319 319 559 559 559 ' + CRLF +
    '585 934 692 692 692 692 639 585 745 692 266 533 692 585 798 692 ' + CRLF +
    '745 639 745 692 639 585 692 639 904 639 639 585 319 266 319 559 ' + CRLF +
    '533 319 533 585 533 585 533 319 585 585 266 266 533 266 852 585 ' + CRLF +
    '585 585 585 373 533 319 585 533 745 533 533 479 373 268 373 559 ' + CRLF +
    '719 533 719 266 533 479 958 533 533 319 958 639 319 958 719 585 ' + CRLF +
    '719 719 266 266 479 479 336 533 958 319 958 533 319 904 719 479 ' + CRLF +
    '639 266 319 533 533 533 533 268 533 319 706 354 533 559 319 706 ' + CRLF +
    '529 383 526 319 319 319 552 533 266 319 319 350 533 799 799 799 ' + CRLF +
    '585 692 692 692 692 692 692 958 692 639 639 639 639 266 266 266 ' + CRLF +
    '266 692 692 745 745 745 745 745 559 745 692 692 692 692 639 639 ' + CRLF +
    '585 533 533 533 533 533 533 852 533 533 533 533 533 266 266 266 ' + CRLF +
    '266 585 585 585 585 585 585 585 526 585 585 585 585 585 533 585 ' + CRLF +
    '533 ]';
  Encoding := 'WinAnsiEncoding';
  FFontDescriptor := TPDFFontDescriptorDef.Create;
  with FFontDescriptor do
  begin
    FontName := 'Arial,Bold';
    Flags := 16416;
    FontBBox := Rect(-215, -215, 1261, 919);
    Stemv := 78;
    ItalicAngle := 0;
    CapHeight := 919;
    Ascent := 919;
    Descent := -215;
  end;
end;


{ TCourierFontDef }
procedure TCourierFontDef.CreateFontDef;
begin
  FFontID := fiCourier;
  Subtype := 'TrueType';
  BaseFont := 'Courier';
  FirstChar := 31;
  LastChar := 255;
  Widths := '[ 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 ]';
  Encoding := 'WinAnsiEncoding';
  FFontDescriptor := TPDFFontDescriptorDef.Create;
  with FFontDescriptor do
  begin
    FontName := 'Courier';
    Flags := 32;
    FontBBox := Rect(-305, -305, 669, 845);
    Stemv := 78;
    ItalicAngle := 0;
    CapHeight := 845;
    Ascent := 845;
    Descent := -305;
  end;
end;

{ TCourierBoldFontDef }
procedure TCourierBoldFontDef.CreateFontDef;
begin
  FFontID := fiCourierBold;
  Subtype := 'TrueType';
  BaseFont := 'Courier,Bold';
  FirstChar := 31;
  LastChar := 255;
  Widths := '[ 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 575 ' + CRLF +
    '575 ]';
  Encoding := 'WinAnsiEncoding';
  FFontDescriptor := TPDFFontDescriptorDef.Create;
  with FFontDescriptor do
  begin
    FontName := 'Courier,Bold';
    Flags := 16416;
    FontBBox := Rect(-305, -305, 759, 845);
    Stemv := 78;
    ItalicAngle := 0;
    CapHeight := 845;
    Ascent := 845;
    Descent := -305;
  end;
end;

{ TMSMincyoFontDef }
procedure TMSMincyoFontDef.CreateFontDef;
begin
  FFontID := fiMincyo;
  Subtype := 'Type0';
  BaseFont := '#82#6C#82#72#20#96#BE#92#A9';
  Encoding := '90msp-RKSJ-H';
  {*
   * MincyoFontDef内でMincyoDFontDef(DecandantFont)を作成する。
   *
   *}
  FDescendantFont := TMSMincyoDFontDef.Create;
end;

{ TMSMincyoDFontDef }
procedure TMSMincyoDFontDef.CreateFontDef;
begin
  Subtype := 'CIDFontType2';
  BaseFont := '#82#6C#82#72#20#96#BE#92#A9';
  WinCharSet := 128;
  CIDSystemInfo := '/Registry(Adobe)' + CRLF +
                   '/Ordering(Japan1)' + CRLF +
                   '/Supplement 2';
  DW := 1000;
  W := '[' + CRLF +
    '1 [ 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 ' + CRLF +
    '479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 ' + CRLF +
    '479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 ' + CRLF +
    '479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 ' + CRLF +
    '479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 ' + CRLF +
    '479 479 479 479 479 479 479 479 479 479 479 479 479 479]' + CRLF +
    '326 [ 958 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 ' + CRLF +
    '479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 ' + CRLF +
    '479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 ' + CRLF +
    '479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 ' + CRLF +
    ']' + CRLF +
    '631 631 479' + CRLF +
    ']' + CRLF;
  FFontDescriptor := TPDFFontDescriptorDef.Create;
  with FFontDescriptor do
  begin
    FontName := '#82#6C#82#72#20#96#BE#92#A9';
    Flags := 6;
    FontBBox := Rect(-143, -143, 1015, 872);
    Stemv := 78;
    ItalicAngle := 0;
    CapHeight := 872;
    Ascent := 872;
    Descent := -143;
  end;
end;

{ TMSGothicFontDef }
procedure TMSGothicFontDef.CreateFontDef;
begin
  FFontID := fiGothic;
  Subtype := 'Type0';
  BaseFont := '#82#6C#82#72#20#83#53#83#56#83#62#83#4E';
  Encoding := '90msp-RKSJ-H';
  {*
   * GothicFontDef内でGothicDFontDef(DecandantFont)を作成する。
   *
   *}
  FDescendantFont := TMSGothicDFontDef.Create;
end;

{ TMSGothicDFontDef }
procedure TMSGothicDFontDef.CreateFontDef;
begin
  Subtype := 'CIDFontType2';
  BaseFont := '#82#6C#82#72#20#83#53#83#56#83#62#83#4E';
  WinCharSet := 128;
  CIDSystemInfo := '/Registry(Adobe)' + CRLF +
                   '/Ordering(Japan1)' + CRLF +
                   '/Supplement 2';
  DW := 1000;
  W := '[' + CRLF +
    '1 [ 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 ' + CRLF +
    '479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 ' + CRLF +
    '479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 ' + CRLF +
    '479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 ' + CRLF +
    '479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 ' + CRLF +
    '479 479 479 479 479 479 479 479 479 479 479 479 479 479]' + CRLF +
    '326 [ 958 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 ' + CRLF +
    '479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 ' + CRLF +
    '479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 ' + CRLF +
    '479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 479 ' + CRLF +
    ']' + CRLF +
    '631 631 479' + CRLF +
    ']' + CRLF;
  FFontDescriptor := TPDFFontDescriptorDef.Create;
  with FFontDescriptor do
  begin
    FontName := '#82#6C#82#72#20#83#53#83#56#83#62#83#4E';
    Flags := 4;
    FontBBox := Rect(-143, -143, 1015, 872);
    Stemv := 78;
    ItalicAngle := 0;
    CapHeight := 872;
    Ascent := 872;
    Descent := -143;
  end;
end;

end.
