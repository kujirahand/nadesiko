{*
 *
 *   PDFMaker
 *
 *   Copyright(c) 1999-2000 Takezou
 *
 *   PDF�t�@�C���o�̓��j�b�g
 *
 *   99.12.03 0.1��  �쐬
 *   99.12.08 0.2��  �v���g�^�C�v����̂܂Ƃ܂����̂ŁA�e���𐮗�
 *   99.12.10 0.21�� Font�̎����ύX
 *   99.12.11 0.22�� PDFContents(Canvas)�̎����J�n
 *   99.12.19 0.3��  ���{��t�H���g�̎���
 *   99.12.25 0.31�� �W���`�惋�[�`���̎���
 *   2000.01.28 0.32�� TextWidth���[�`���̎���
 *   2000.02.02 0.33�� Clip�����MeasureText�̎���
 *   2000.02.04 0.34�� ArrangeText�̒ǉ�
 *   2000.02.08 0.4��  ���񃊃��[�X
 *
 *}
unit PDFMaker;

interface

uses
  Windows, SysUtils, Classes, PMFonts, Graphics;

const
  PDFMAKER_VERSION_TEXT = 'PDFMaker0.4';

type
  TLineJoinStyle = (ljMiterJoin, ljRoundJoin, ljBevelJoin);

  TLineCapStyle = (lcButtEnd, lcRoundEnd, lcProjectingSquareEnd);

  TTextRenderingMode = (trFill,
                        trStroke,
                        trFillThenStroke,
                        trInvisible,
                        trFillClipping,
                        trStrokeClipping,
                        trFillStrokeClipping,
                        trClipping);

  TPDFRect = record
    Left, Top, Right, Bottom: Single;
  end;

  TPDFPoint = record
    X, Y: Single;
  end;

  TPDFMaker = class;

  {*
   *  TPDFObject
   *  PDF�t�@�C�����̃I�u�W�F�N�g�̊�{�^ObjectID���Ǘ�����
   *
   *}
  TPDFObject = class(TObject)
  private
    FObjectID: integer;
    FOwner: TPDFMaker;
    function GetObjectHeader: string;
    function GetObjectDetail: string; virtual;
  public
    constructor Create(AOwner: TPDFMaker); virtual;
    function GetObjectString: string;
    property ObjectID: integer read FObjectID;
  end;

  {*
   *  TPDFObjectList
   *  PDF�t�@�C�����̃I�u�W�F�N�g�̏W�����Ǘ�����B
   *
   *}
  TPDFObjectList = class(TObject)
  private
    FItems: TList;
    function GetItem(Index: integer): TPDFObject;
    function GetCount: integer;
  public
    constructor Create; virtual;
    procedure Clear;
    function AddItem(AItem: TPDFObject): integer; virtual;
    function GetArrayString: string;
    property Items[index: integer]: TPDFObject read GetItem; default;
    property Count: integer read GetCount;
    destructor Destroy; override;
  end;

  {*
   *  TPDFInfo
   *  Info�I�u�W�F�N�g�B���������Ǘ�����I�u�W�F�N�g
   *
   *}
  TPDFInfo = class(TPDFObject)
  private
    function GetObjectDetail: string; override;
  public
  end;

  TPDFPage = class;

  {*
   *  TPDFPages
   *  Pages�I�u�W�F�N�g�BMediabox�����Page�I�u�W�F�N�g�̏W�����Ǘ�����B
   *
   *}
  TPDFPages = class(TPDFObject)
  private
    FKids: TPDFObjectList;
    FHeight, FWidth: integer;
    procedure SetHeight(Value: integer);
    procedure SetWidth(Value: integer);
    function GetKids(Index: integer): TPDFObject;
    function GetObjectDetail: string; override;
  protected
    function AddPage: TPDFPage;
  public
    constructor Create(AOwner: TPDFMaker); override;
    property Kids[index: integer]: TPDFObject read GetKids; default;
    property Height: integer read FHeight write SetHeight;
    property Width: integer read FWidth write SetWidth;
  end;

  {*
   *  TPDFFontDescriptor
   *  FontDescriptor�I�u�W�F�N�g�B
   *  �t�H���g�̏����Ǘ�����B
   *  ���ۂ̏���FontDescriptorDef�Ɏ���
   *
   *}
  TPDFFontDescriptor = class(TPDFObject)
  private
    FFontDescriptorDef: TPDFFontDescriptorDef;
    function GetObjectDetail: string; override;
  public
    destructor Destroy; override;
    procedure SetFontDescriptorDef(AFontDescriptorDef: TPDFFontDescriptorDef);
  end;

  {*
   *  TPDFFont
   *  Font�I�u�W�F�N�g�B
   *  ���ۂ̏���FontDef�Ɏ���
   *  FontName�̓t�H���g�̖���(ex. Arial, Century)�ł͂Ȃ�PDF�t�@�C���Ŏg�p
   *  ���������(ex /F0, /F1)�������B
   *
   *}
  TPDFFont = class(TPDFObject)
  private
    FFontDef: TPDFFontDef;
    FFontDescriptor: TPDFFontDescriptor;
    FDescendantFont: TPDFFont;
    FFontName: integer;
    function GetFontID: TPDFFontID;
  protected
    function GetObjectDetail: string; override;
    function GetCharWidth(C: Char): integer;
  public
    constructor Create(AOwner: TPDFMaker); override;
    destructor Destroy; override;
    procedure SetFontDef(AFontDef: TPDFFontDef); virtual;
    property FontName: integer read FFontName;
    property FontID: TPDFFontID read GetFontID;
  end;

  {*
   *  TPDFContents
   *  Contents�I�u�W�F�N�g�B
   *  ���̃I�u�W�F�N�g�����ۂɕ`�ʂ��s���L�����o�X�̖�ڂ��s���B
   *
   *}
  TPDFContents = class(TPDFObject)
  private
    FBuf: string;
    { �v���p�e�B�p�̃t�B�[���h }
    FFont: TPDFFontID;
    FFontSize: Single;
    FLineWidth: Single;
    FLineJoinStyle: TLineJoinStyle;
    FLineCapStyle: TLineCapStyle;
    FFillColor: TColor;
    FStrokeColor: TColor;
    FLeading: Single;
    FCharSpace: Single;
    FWordSpace: Single;
    FStateSaved: boolean;
    { ���ʃ��[�`�� }
    procedure SaveDefaultGState;
    function GetObjectDetail: string; override;
    function GetColorStr(Color: TColor): string;
    function EscapeText(Value: string): string;
    function StrToHex(s: string): string;
  public
    constructor Create(AOwner: TPDFMaker); override;
    {*
     *
     * 'p'�Ŏn�܂郋�[�`���́APDF�̃I�y���[�^�����̂܂܏o�͂���჌�x���̃��[�`��
     *  �����̃��[�`���́A�Ăяo��������p�����^�ɂ���Ă͕\�����ɃG���[�ɂȂ�
     *  �ꍇ������̂Œ��ӁB
     *
     *}                                                         {Operator}
    procedure pCFillStroke;                                     {  b     }
    procedure pFillStroke;                                      {  B     }
    procedure pCEofillStroke;                                   {  b*    }
    procedure pEofillStroke;                                    {  B*    }
    procedure pBeginText;                                       {  BT    }
    procedure pCurveTo(x1, y1, x2, y2, x3, y3: Single);         {  c     }
    procedure pSetDash(Length1, Length2, Phase: Byte);          {  d     }
    procedure pEndText;                                         {  ET    }
    procedure pFillPath;                                        {  f     }
    procedure pEofillPath;                                      {  f*    }
    procedure pClosePath;                                       {  h     }
    procedure pSetFlatness(Value: Single);                      {  i     }
    procedure pSetLineJoin(Value: TLineJoinStyle);              {  j     }
    procedure pSetLineCap(Value: TLineCapStyle);                {  J     }
    procedure pLineTo(x, y: Single);                            {  l     }
    procedure pMoveTo(x, y: Single);                            {  m     }
    procedure pSetMitterLimit(Value: Single);                   {  M     }
    procedure pEndPath;                                         {  n     }
    procedure pSetRGBFillColor(Value: TColor);                  {  rg    }
    procedure pSetRGBStrokeColor(Value: TColor);                {  RG    }
    procedure pClosePathStroke;                                 {  s     }
    procedure pStroke;                                          {  S     }
    procedure pSetCharSpace(Value: Single);                     {  Tc    }
    procedure pMoveTextPoint(x, y: Single);                     {  Td    }
    procedure pSetFontAndSize(AFont: TPDFFontID; ASize: Single);{  Tf    }
    procedure pShowText(Value: string);                         {  Tj    }
    procedure pShowJText(Value: string);                        {  Tj    }
    procedure pSetLeading(Value: Single);                       {  TL    }
    procedure pSetTextRendering(Value: TTextRenderingMode);     {  Tr    }
    procedure pSetWordSpace(Value: Single);                     {  Tw    }
    procedure pSetHolizontalScaling(Value: Byte);               {  Tz    }
    procedure pMoveToNextLine;                                  {  T*    }
    procedure pSetLineWidth(Value: Single);                     {  w     }
    procedure pClip;                                            {  W     }
    procedure pSaveGState;                                      {  q     }
    procedure pRestoreGState;                                   {  Q     }
    procedure pEoclip;                                          {  W*    }
    procedure pTextShowNextLine(Value: string);                 {  '     }
    procedure pJTextShowNextLine(Value: string);                {  '     }
    {*
     *  �W���`�惋�[�`��
     *}
    function TextWidth(S: string): Single;
    function MeasureText(S: string; AWidth: Single): integer;
    function ArrangeText(Src: string; var Dst: string; AWidth: Single): integer;
    procedure LineTo(x1, y1, x2, y2: Single);
    procedure DrawRect(x1, y1, x2, y2: Single; Clip: boolean);
    procedure FillRect(x1, y1, x2, y2: Single; Clip: boolean);
    procedure DrawAndFillRect(x1, y1, x2, y2: Single; Clip: boolean);
    procedure TextOut(X, Y: Single; Text: string);
    procedure CancelClip;
    {*
     *  �W���`�ʃ��[�`���p�̃v���p�e�B
     *}
    property Font: TPDFFontID read FFont write FFont;
    property FontSize: Single read FFontSize write FFontSize;
    property LineWidth: Single read FLineWidth write FLineWidth;
    property LineJoinStyle: TLineJoinStyle read FLineJoinStyle write FLineJoinStyle;
    property LineCapStyle: TLineCapStyle read FLineCapStyle write FLineCapStyle;
    property FillColor: TColor read FFillColor write FFillColor;
    property StrokeColor: TColor read FStrokeColor write FStrokeColor;
    property Leading: Single read FLeading write FLeading;
    property CharSpace: Single read FCharSpace write FCharSpace;
    property WordSpace: Single read FWordSpace write FWordSpace;
  end;

  {*
   *  TPDFPage
   *  Page�I�u�W�F�N�g�B
   *
   *}
  TPDFPage = class(TPDFObject)
  private
    FContents: TPDFContents;
    FParent: TPDFPages;
    function GetObjectDetail: string; override;
  public
    constructor Create(AOwner: TPDFMaker); override;
    procedure SetParent(AParent: TPDFPages);
    property Contents: TPDFContents read FContents;
  end;

  {*
   *  TPDFCatalog
   *  Catalog�I�u�W�F�N�g�B
   *
   *}
  TPDFCatalog = class(TPDFObject)
  private
    FPagesObject: TPDFPages;
    function GetObjectDetail: string; override;
  public
    constructor Create(AOwner: TPDFMaker); override;
    property Pages: TPDFPages read FPagesObject;
  end;

  {*
   *  TPDFMaker
   *
   *}
  TPDFMaker = class(TObject)
  public
  private
    FStream: TStream;
    FRoot: TPDFCatalog;
    FObjectList: TPDFObjectList;
    FFonts: TPDFObjectList;
    FCanvas: TPDFContents;
    FInfo: TPDFInfo;
    FAuthor: string;
    FTitle: string;
    FCreator: string;
    FSubject: string;
    FFontsStatus: array[0..MAX_PDF_FONT_INDEX] of boolean;
    FPrinting: boolean;
    FPage: integer;
    FPageWidth: Integer;
    FPageHeight: Integer;
  {  FDefaultFont: TPDFFontID;    �ۗ�}
    function GetCanvas: TPDFContents;
    procedure SetPageHeight(Value: Integer);
    procedure SetPageWidth(Value: Integer);
  protected
    function RegisterObject(AObject: TPDFObject): integer;
    function RegisterFont(AFont: TPDFFont): integer;
    function GetFont(FontID: TPDFFontID): TPDFFont;
    function GetFontNameList: string;
    procedure WriteObject;
    procedure ClearObject;
    procedure CheckStatus;
  public
    constructor Create;
    destructor Destroy; override;
    procedure BeginDoc(AStream: TStream);
    procedure EndDoc(ACloseStream: boolean);
    procedure NewPage;
    property Canvas: TPDFContents read GetCanvas;
    property Author: string read FAuthor write FAuthor;
    property Title: string read FTitle write FTitle;
    property Creator: string read FCreator write FCreator;
    property Subject: string read FSubject write FSubject;
    property Page: integer read FPage;
    property PageHeight: integer read FPageHeight write SetPageHeight;
    property PageWidth: integer read FPageWidth write SetPageWidth;
  {  property DefaultFont: TPDFFontID read FDefaultFont write FDefaultFont;  �ۗ�}
  end;

  function PDFRect(Left, Top, Right, Bottom: Single): TPDFRect;
  function PDFPoint(x, y: Single): TPDFPoint;

implementation

const
  CRLF = #13#10;
  CR = #13;

{* common routines *}
function PDFRect(Left, Top, Right, Bottom: Single): TPDFRect;
begin
  Result.Left := Left;
  Result.Top := Top;
  Result.Right := Right;
  Result.Bottom := Bottom;
end;

function PDFPoint(x, y: Single): TPDFPoint;
begin
  Result.X := x;
  Result.Y := y;
end;

function PDFRectToString(ARect: TPDFRect): string;
begin
  result := '[ ' + FloatToStr(ARect.Left) +
            ' ' + FLoatToStr(ARect.Top) +
            ' ' + FLoatToStr(ARect.Right) +
            ' ' + FLoatToStr(ARect.Bottom) + ' ]';
end;

function RectToString(ARect: TRect): string;
begin
  result := '[ ' + IntToStr(ARect.Left) +
            ' ' + IntToStr(ARect.Top) +
            ' ' + IntToStr(ARect.Right) +
            ' ' + IntToStr(ARect.Bottom) + ' ]';
end;

function PDFPointToString(APoint: TPDFPoint): string;
begin
  result := '[ ' + FLoatToStr(APoint.X) +
            ' ' + FLoatToStr(APoint.Y) + ' ]';
end;

function FloatToStrR(Value: Extended): string;
begin
  {*
   * ������Q�ʈȉ����l�̌ܓ�����
   *
   *}
  result := FloatToStr(Trunc(Value * 100 + 0.5) / 100);
end;

{*
 * TPDFObject
 *
 *}
constructor TPDFObject.Create(AOwner: TPDFMaker);
begin
  FOwner := AOwner;
  FObjectID := AOwner.RegisterObject(Self);
end;

function TPDFObject.GetObjectHeader: string;
begin
  result := IntToStr(FObjectID) + ' 0 obj' + CRLF;
end;

function TPDFObject.GetObjectDetail: string;
begin
  result := '';
end;

function TPDFObject.GetObjectString: string;
begin
  result := GetObjectHeader +
            GetObjectDetail +
            'endobj' + CRLF;
end;

{*
 *  TPDFObjectList
 *
 *}
constructor TPDFObjectList.Create;
begin
  FItems := TList.Create;
  FItems.Clear;
end;

destructor TPDFObjectList.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TPDFObjectList.AddItem(AItem: TPDFObject): integer;
begin
  if (AItem <> nil) and (AItem is TPDFObject) then
    result := FItems.Add(AItem)
  else
    result := -1;
end;

function TPDFObjectList.GetItem(Index: integer): TPDFObject;
begin
  if (Index < FItems.Count) and (Index >= 0) then
    result := TPDFObject(FItems[Index])
  else
    raise Exception.CreateFmt('Internel Error Invalid Index %d', [Index]);
end;

function TPDFObjectList.GetCount: integer;
begin
  result := FItems.Count;
end;

function TPDFObjectList.GetArrayString: string;
var
  i: integer;
begin
  result := '[';
  for i := 0 to FItems.Count - 1 do
    result := result + IntToStr(Items[i].ObjectID) + ' 0 R ';
  result := result + ']'
end;

procedure TPDFObjectList.Clear;
begin
 {*
  *  �I�u�W�F�N�g�̃��X�g���N���A����B
  *  ���X�g���̃I�u�W�F�N�g���̂̉���͕ʓr�s���K�v������B
  *
  *}
  FItems.Clear;
end;

{*
 * TPDFMaker
 *
 *}
function TPDFMaker.GetCanvas: TPDFContents;
begin
  if FCanvas = nil then
    raise Exception.Create('BeginDoc���Ăяo����Ă��܂���');
  result := FCanvas;
end;

procedure TPDFMaker.SetPageHeight(Value: Integer);
begin
  if FCanvas <> nil then
    raise Exception.Create('�o�͒��̓T�C�Y�ύX�͂ł��܂���B');
  if Value > 0 then
    FPageHeight := Value;
end;

procedure TPDFMaker.SetPageWidth(Value: Integer);
begin
  if FCanvas <> nil then
    raise Exception.Create('�o�͒��̓T�C�Y�ύX�͂ł��܂���B');
  if Value > 0 then
    FPageWidth := Value;
end;

function TPDFMaker.RegisterObject(AObject: TPDFObject): integer;
begin
  result := FObjectList.AddItem(AObject) + 1;
end;

function TPDFMaker.RegisterFont(AFont: TPDFFont): integer;
begin
  {*
   *  AFont�Ŏw�肳�ꂽ�t�H���g���t�H���g�B�X�g�ɓo�^����B
   *  result��PDF�t�@�C�������Ŏg�p����t�H���g���ɂȂ�B
   *
   *}
  result := FFonts.AddItem(AFont);
end;

function TPDFMaker.GetFontNameList: string;
var
  i: integer;
begin
  result := '';
  for i := 0 to FFonts.Count - 1 do
    result := Result + '/F' + IntToStr(TPDFFont(FFonts[i]).FontName) +
              ' ' + IntToStr(TPDFFont(FFonts[i]).ObjectID) + ' 0 R' + CRLF;
end;

function TPDFMaker.GetFont(FontID: TPDFFontID): TPDFFont;
var
  PDFFont: TPDFFont;
  i: integer;
begin
  {*
   * �w�肳�ꂽFont���g�p����Ă��Ȃ�������쐬���ēo�^����
   * ���Ɏg�p����Ă����炻��Font��T���ĕԂ�
   *
   *}
  result := nil;
  if not FFontsStatus[ord(FontID)] then
  begin
    PDFFont := TPDFFont.Create(Self);
    PDFFont.FFontName := RegisterFont(PDFFont);
    PDFFont.SetFontDef(CreateFont(FontID));
    FFontsStatus[ord(FontID)] := true;
    result := PDFFont;
  end
  else
    for i := 0 to FFonts.Count - 1 do
      if TPDFFont(FFonts[i]).FontID = FontID then
      begin
        result := TPDFFont(FFonts[i]);
        break;
      end
end;

constructor TPDFMaker.Create;
begin
  FObjectList := TPDFObjectList.Create;
  FFonts := TPDFObjectList.Create;
  FCanvas := nil;
  FPrinting := false;
  FPageHeight := 842;
  FPageWidth := 596;
end;

destructor TPDFMaker.Destroy;
begin
  ClearObject;
  FFonts.Free;
  FObjectList.Free;
  inherited;
end;

procedure TPDFMaker.CheckStatus;
begin
  if FPrinting then
    raise Exception.Create('������ɂ͎��s�ł��Ȃ����\�b�h�ł�');
end;

procedure TPDFMaker.BeginDoc(AStream: TStream);
var
  i: integer;
begin
  {*
   * �e�ϐ������������āAInfo�����쐬
   *
   *}
  if AStream = nil then
    raise Exception.Create('Invarid Stream');
  FStream := AStream;
  ClearObject;
  FRoot := TPDFCatalog.Create(Self);
  for i := 0 to MAX_PDF_FONT_INDEX do
    FFontsStatus[i] := false;
  FInfo := TPDFInfo.Create(Self);
  FPage := 0;
  NewPage;
  FPrinting := true;
end;

procedure TPDFMaker.EndDoc(ACloseStream: boolean);
begin
  {*
   * �I�u�W�F�N�g���X�g���[���ɏ������ށBACloseStream��True���w�肳��Ă����ꍇ
   * �̓X�g���[�����N���[�Y����B
   *
   *}
  FPrinting := false;
  WriteObject;
  FCanvas := nil;
  if ACloseStream then
    FStream.Free;
end;

procedure TPDFMaker.NewPage;
begin
  {*
   * Contents�I�u�W�F�N�g��V�K�ɍ쐬
   *
   *}
  FCanvas := FRoot.Pages.AddPage.Contents;
  inc(FPage);
end;

procedure TPDFMaker.ClearObject;
var
  i: integer;
begin
  {*
   * �o�^����Ă���S�ẴI�u�W�F�N�g���폜
   *
   *}
  for i := FObjectList.Count - 1 downto 0 do
    if FObjectList.Items[i] <> nil then
      FObjectList.Items[i].Free;
  FObjectList.Clear;
  FFonts.Clear;
end;

procedure TPDFMaker.WriteObject;
var
  i: integer;
  s: string;
  xrefBuf: string;
  xrefPos: integer;

  procedure WriteHeader;
  var
    S: string;
  begin
    S := '%PDF-1.2 ' + CRLF;
    FStream.Write(PChar(S)^, Length(S));
  end;

  procedure WriteFooter;
  var
    S: string;
  begin
  {*
   *  trailer���o��
   *
   *}
    S := 'trailer' + CRLF +
         '<<' + CRLF +
         '/Size ' + IntToStr(FObjectList.Count+1) + CRLF +
         '/Root ' + IntToStr(FRoot.ObjectID) + ' 0 R' + CRLF +
         '/Info ' + IntToStr(FInfo.ObjectID) + ' 0 R' + CRLF +
         '>>' + CRLF +
         'startxref' + CRLF +
         IntToStr(xrefPos) + CRLF +
         '%%EOF' + CRLF;
    FStream.Write(PChar(S)^, Length(S));
  end;

  function SetAddrLength(Value: integer): string;
  begin
    {*
     *  Value�ŗ^����ꂽ�����i�I�u�W�F�N�g�̃t�@�C����̃A�h���X�j
     *  ��xref�Ŏg�p����10���̕�����ɕϊ�����
     *
     *}
    result := IntToStr(Value);
    while Length(Result) < 10 do
      Result := '0' + Result;
  end;

begin
  {*
   * ���X�g���̊e�I�u�W�F�N�g��GetObjectString���Ăяo����
   * �I�u�W�F�N�g�̓��e���X�g���[���ɏ����o���B
   * ���̎�cross refarence table ���쐬���ďo�͌�A�t�b�^�[���o��
   *
   *}
  xrefbuf := 'xref' + CRLF + '0 ' + IntToStr(FObjectList.Count+1) + CRLF +
             '0000000000 65535 f' + CRLF;
  FStream.Position := 0;
  WriteHeader;
  for i := 0 to FObjectList.Count - 1 do
  begin
    xrefBuf := xrefBuf + SetAddrLength(FStream.Position) + ' 00000 n' + CRLF;
    s := FObjectList.Items[i].GetObjectString;
    FStream.Write(PChar(s)^, Length(S));
  end;
  xrefPos := FStream.Position;
  FStream.Write(PChar(xrefbuf)^, Length(xrefbuf));
  WriteFooter;
end;

{* TPDFCatalog *}
constructor TPDFCatalog.Create(AOwner: TPDFMaker);
begin
  inherited Create(AOwner);
  FPagesObject := TPDFPages.Create(AOwner);
  FPagesObject.Width := AOwner.PageWidth;
  FPagesObject.Height := AOwner.PageHeight;
end;

function TPDFCatalog.GetObjectDetail: string;
begin
  result := '<<' + CRLF +
            '/Type /Catalog' + CRLF +
            '/Pages ' + IntToStr(FPagesObject.ObjectID) + ' 0 R' + CRLF +
            '>>' + CRLF;
end;

{* TPDFPages *}
constructor TPDFPages.Create(AOwner: TPDFMaker);
begin
  inherited Create(AOwner);
  FKids := TPDFObjectList.Create;
end;

function TPDFPages.GetKids(Index: integer): TPDFObject;
begin
  result := FKids.Items[Index];
end;

function TPDFPages.GetObjectDetail: string;
begin
  result := '<<' + CRLF +
            '/Kids ' + FKids.GetArrayString + CRLF +
            '/Count ' + IntToStr(FKids.Count) + CRLF +
            '/Type /Pages' + CRLF +
            '/MediaBox [ 0 0 ' + IntToStr(FWidth) + ' ' + IntToStr(FHeight) + ' ]' + CRLF +
            '>>' + CRLF;
end;

function TPDFPages.AddPage: TPDFPage;
begin
  result := TPDFPage.Create(FOwner);
  FKids.AddItem(result);
  result.SetParent(Self);
end;

procedure TPDFPages.SetHeight(Value: integer);
begin
  if Value > 0 then
    FHeight := Value;
end;

procedure TPDFPages.SetWidth(Value: integer);
begin
  if Value > 0 then
    FWidth := Value;
end;

{* TPDFPage *}
function TPDFPage.GetObjectDetail: string;
begin
  result := '<<' + CRLF +
            '/Type /Page' + CRLF +
            '/Parent ' + IntToStr(FParent.ObjectID) + ' 0 R' + CRLF +
            '/Resources <<' + CRLF +
            '/Font <<' + CRLF +
            FOwner.GetFontNameList +
            '>>' + CRLF +
            '/ProcSet [ /PDF /Text ]' + CRLF +
            '>>'  + CRLF +
            '/Contents ' + IntToStr(FContents.ObjectID) + ' 0 R' + CRLF +
            '>>' + CRLF;
end;

constructor TPDFPage.Create(AOwner: TPDFMaker);
begin
  inherited Create(AOwner);
  FContents := TPDFContents.Create(AOwner);
end;

procedure TPDFPage.SetParent(AParent: TPDFPages);
begin
  FParent := AParent;
end;

{* TPDFContents *}

constructor TPDFContents.Create(AOwner: TPDFMaker);
begin
  inherited Create(AOwner);
  FBuf := '';
  FFont := fiCentury;
  FFontSize := 10;
  FLineWidth := 1;
  FLineJoinStyle := ljMiterJoin;
  FLineCapStyle := lcButtEnd;
  FFillColor := clBlack;
  FStrokeColor := clBlack;
  FLeading := 0;
  FStateSaved := false;
end;

function TPDFContents.GetObjectDetail: string;
const
  LF = #10;
begin
  result := '<<' + CRLF +
            '/Length ' + IntToStr(Length(FBuf)) + CRLF +
            '>>' + CRLF +
            'stream' + CRLF +
            FBuf + LF +
            'endstream' + CRLF;
end;

procedure TPDFContents.SaveDefaultGState;
begin
  {*
   *  �f�t�H���g��GraphicState��ۑ�����B�N���b�s���O��Ԃ��畜�A���邽�߂�
   *  �g�p����B
   *
   *}
  if not FStateSaved then
  begin
    pSaveGState;
    FStateSaved := true;
  end;
end;

procedure TPDFContents.LineTo(x1, y1, x2, y2: Single);
begin
  pMoveTo(x1, y1);
  pSetLineCap(FLineCapStyle);
  pSetRGBStrokeColor(StrokeColor);
  pSetLineWidth(FLineWidth);
  pLineTo(x2, y2);
  pStroke;
  pEndPath;
end;

function TPDFContents.TextWidth(S: string): Single;
var
  i: integer;
  SW: Single;
  FPDFFont: TPDFFont;
begin
  {*
   *  ���݂̃t�H���g�̏��i��ށE�T�C�Y�j����ɁA�e�L�X�g�̕����v�Z����B
   *
   *}
  FPDFFont := FOwner.GetFont(FFont);
  SW := 0;
  i := 1;
  while i <= Length(S) do
  begin
    if (ByteType(S, i) = mbSingleByte) then
    begin
      if i <> 1 then
        SW := SW + FCharSpace;
      SW := SW + FPDFFont.GetCharWidth(S[i]) * FFontSize / 1000;
      if S[i] = ' ' then
        SW := SW + FWordSpace;
    end
    else
    if (ByteType(S, i) = mbTrailByte) and (i > 2) then
      SW := SW + FPDFFont.GetCharWidth(Chr(0)) / 2 * FFontSize / 1000 + FCharSpace
    else
      SW := SW + FPDFFont.GetCharWidth(Chr(0)) / 2 * FFontSize / 1000;
    inc(i);
  end;
  result := SW;
end;

function TPDFContents.MeasureText(S: string; AWidth: Single): integer;
var
  i: integer;
  SW: Single;
  SL: integer;
  FPDFFont: TPDFFont;
begin
  {*
   *  ���݂̃t�H���g�̏��i��ށE�T�C�Y�j����ɁA�^����ꂽ��(Width)����
   *  ���镶�������o�C�g�ŕԂ��B
   *  ���[�h���b�v�������s�����߂Ɏg�p����B
   *
   *}
  FPDFFont := FOwner.GetFont(FFont);
  SW := 0;
  i := 1;
  result := 0;
  SL := Length(S);
  while i <= SL do
  begin
    if (ByteType(S, i) = mbSingleByte) then
    begin
      if i > 1 then
        SW := SW + FCharSpace;
      SW := SW + FPDFFont.GetCharWidth(S[i]) * FFontSize / 1000;
      if i = SL then
        result := i
      else
      if S[i] = ' ' then
      begin
        SW := SW + FWordSpace;
        result := i;
      end;
    end
    else
    begin
      SW := SW + FPDFFont.GetCharWidth(Chr(0)) / 2 * FFontSize / 1000;
      // �Q�o�C�g�����̑� 2 �o�C�g�ڂ�������A�L���Ȑ؂�ڂɂȂ�B
      if (ByteType(S, i) = mbTrailByte) then
      begin
        if i > 2 then
          SW := SW + FCharSpace;
        result := i;
      end;
    end;
    inc(i);
    {*
     * �w�肳�ꂽ���𒴂����炻���܂łŃJ�E���g����߂邪�A���𒴂��Ă��Œ�P�P
     * ��͓����悤�ɂ���B�i�������[�v�h�~�j
     *
     *}
    if (SW > AWidth) and (result > 0) then Exit;
  end;
end;

function TPDFContents.ArrangeText(Src: string; var Dst: string; AWidth: Single): integer;
var
  i, j: integer;
begin
  {*
   * �w�肳�ꂽ���ɓ���悤��Src�œn���ꂽ������ɉ��s�R�[�h�����Đ��`����
   * ���`���ꂽ�e�L�X�g��Dst�ɓ���B�߂�l�ɂ͐��`���ꂽ������̍s��������B
   *
   *}
  j := 1;
  result := 0;
  Dst := '';
  while j <= Length(Src) do
  begin
    i := MeasureText(Copy(Src, j, Length(Src) - (j - 1)), AWidth);
    Dst := Dst + Copy(Src, j, i) + #13#10;
    result := result + 1;
    j := j + i;
  end;
end;

procedure TPDFContents.DrawRect(x1, y1, x2, y2: Single; Clip: boolean);
begin
  pMoveTo(x1, y1);
  pSetLineWidth(FLineWidth);
  pSetLineJoin(FLineJoinStyle);
  pSetRGBStrokeColor(FStrokeColor);
  pLineTo(x1, y2);
  pLineTo(x2, y2);
  pLineTo(x2, y1);
  if Clip then
  begin
    SaveDefaultGState;
    pClip;
  end;
  pClosePathStroke;
end;

procedure TPDFContents.FillRect(x1, y1, x2, y2: Single; Clip: boolean);
begin
  pMoveTo(x1, y1);
  pSetLineWidth(FLineWidth);
  pSetLineJoin(FLineJoinStyle);
  pSetRGBFillColor(FFillColor);
  pLineTo(x1, y2);
  pLineTo(x2, y2);
  pLineTo(x2, y1);
  if Clip then
  begin
    SaveDefaultGState;
    pClip;
  end
  else
    pClosePath;
  pFillPath;
end;

procedure TPDFContents.DrawAndFillRect(x1, y1, x2, y2: Single; Clip: boolean);
begin
  pMoveTo(x1, y1);
  pSetLineWidth(FLineWidth);
  pSetLineJoin(FLineJoinStyle);
  pSetRGBFillColor(FFillColor);
  pSetRGBStrokeColor(FStrokeColor);
  pLineTo(x1, y2);
  pLineTo(x2, y2);
  pLineTo(x2, y1);
  if Clip then
  begin
    SaveDefaultGState;
    pClip;
  end
  else
    pClosePath;
  pFillStroke;
end;

procedure TPDFContents.TextOut(X, Y: Single; Text: string);
var
  StrPos, CurPos: integer;
  StrLen: integer;
  procedure InternalTextOut(s: string);
  var
    HasDoubleByteChar: boolean;
    i: integer;
  begin
    {*
     *  �����񒆂ɂQ�o�C�g�������܂܂�Ă���ꍇ��pShowJText,
     *  �����łȂ��ꍇ��pShowText�ŕ`�ʂ���
     *}
    HasDoubleByteChar := false;
    for i := 1 to Length(s) do
      if ByteType(s, i) <> mbSingleByte then
      begin
        HasDoubleByteChar := true;
        Break;
      end;
    if HasDoubleByteChar then
      pShowJText(s)
    else
      pShowText(s);
  end;
begin
  pBeginText;
  pSetFontAndSize(FFont, FFontSize);
  pSetRGBFillColor(FFillColor);
  pSetLeading(FLeading);
  pSetCharSpace(FCharSpace);
  pSetWordSpace(FWordSpace);
  pMoveTextPoint(X, Y);
  StrPos := 1;
  CurPos := 1;
  StrLen := Length(Text);
  while CurPos <= StrLen do
  begin
    // ���s�R�[�h�ɏo��������
    if Text[CurPos] = #13 then
    begin
      // �o�b�t�@���o��
      InternalTextOut(Copy(Text, StrPos, (CurPos-StrPos)));
      // �ŏI������������I���
      if CurPos >= StrLen then
        Break
      else
      // #10�͖���
      if Text[(CurPos+1)] = #10 then
        inc(CurPos);
      // ���̃o�b�t�@�̐擪���Z�b�g
      StrPos := CurPos + 1;
      pMoveToNextLine;
    end;
    inc(CurPos);
  end;
  if StrPos < CurPos then
    InternalTextOut(Copy(Text, StrPos, CurPos-1));
  pEndText;
end;

procedure TPDFContents.CancelClip;
begin
  if FStateSaved then
  begin
    pRestoreGState;
    FStateSaved := false;
  end;
end;

function TPDFContents.GetColorStr(Color: TColor): string;
var
  X: array[0..3] of Byte;
  i: integer;
begin
{*
 * Color�p�����^�ŗ^����ꂽ�F��RGB�l�ɕϊ����A���ꂼ��̒l���O����P�̊Ԃ�
 * �����l�ɂ���B
 *
 *}
  i := ColorToRGB(Color);
  Move(i, x[0], 4);
  result := FloatToStrR(X[0] / 255) + ' ' +
            FloatToStrR(X[1] / 255) + ' ' +
            FloatToStrR(X[2] / 255);
end;

function TPDFContents.EscapeText(Value: string): string;
const
  EscapeChars = ['(',')','\'];
var
  i: integer;
begin
{*
 *  EscapeChars�Œ�`���ꂽ�e�L�X�g��\�ŃG�X�P�C�v����B
 *
 *}
  result := '';
  for i := 1 to Length(Value) do
  begin
    if (Value[i] in EscapeChars) and (ByteType(Value, i - 1) = mbSingleByte) then
       result := result + '\' + Value[i]
    else
       result := result + Value[i];
  end;
end;

function TPDFContents.StrToHex(s: string): string;
var
  i: integer;
begin
{*
 *  �������16�i�ŃG���R�[�h���ĕԂ��B
 *
 *}
  result := '';
  for i := 1 to Length(s) do
    result := result + IntToHex(ord(s[i]), 2);
end;

procedure TPDFContents.pCFillStroke;
begin
  FBuf := FBuf + 'b' + CR;
end;

procedure TPDFContents.pFillStroke;
begin
  FBuf := FBuf + 'B' + CR;
end;

procedure TPDFContents.pCEofillStroke;
begin
  FBuf := FBuf + 'b*' + CR;
end;

procedure TPDFContents.pEofillStroke;
begin
  FBuf := FBuf + 'B*' + CR;
end;

procedure TPDFContents.pBeginText;
begin
  FBuf := FBuf + 'BT' + CR;
end;

procedure TPDFContents.pSetDash(Length1, Length2, Phase: Byte);
var
  s: string;
begin
  s := '[';
  if Length1 > 0 then
    s := s + IntToStr(Length1) + ' ';
  if Length2 > 0 then
    s := s + IntToStr(Length2);
  s := s + ']' + IntToStr(Phase) + ' d' + CR;
  FBuf := FBuf + s;
end;

procedure TPDFContents.pCurveTo(x1, y1, x2, y2, x3, y3: Single);
begin
  FBuf := FBuf + FloatToStrR(x1) +
          ' ' + FloatToStrR(y1) +
          ' ' + FloatToStrR(x2) +
          ' ' + FloatToStrR(y2) +
          ' ' + FloatToStrR(x3) +
          ' ' + FloatToStrR(y3) +
          ' c' + CR;
end;

procedure TPDFContents.pFillPath;
begin
  FBuf := FBuf + 'f' + CR;
end;

procedure TPDFContents.pEofillPath;
begin
  FBuf := FBuf + 'f*' + CR;
end;

procedure TPDFContents.pClosePath;
begin
  FBuf := FBuf + 'h' + CR;
end;

procedure TPDFContents.pEndPath;
begin
  FBuf := FBuf + 'n' + CR;
end;

procedure TPDFContents.pEndText;
begin
  FBuf := FBuf + 'ET' + CR;
end;

procedure TPDFContents.pSetFlatness(Value: Single);
begin
  FBuf := FBuf + FloatToStrR(Value) + ' i' + CR;
end;

procedure TPDFContents.pSetLineJoin(Value: TLineJoinStyle);
begin
  FBuf := FBuf + IntToStr(ord(Value)) + ' j' + CR;
end;

procedure TPDFContents.pSetLineCap(Value: TLineCapStyle);
begin
  FBuf := FBuf + IntToStr(ord(Value)) + ' J' + CR;
end;

procedure TPDFContents.pLineTo(x, y: Single);
begin
  FBuf := FBuf + FloatToStrR(x) + ' ' + FloatToStrR(y) + ' l' + CR;
end;

procedure TPDFContents.pMoveTo(x, y: Single);
begin
  FBuf := FBuf + FloatToStrR(x) + ' ' + FloatToStrR(y) + ' m' + CR;
end;

procedure TPDFContents.pSetMitterLimit(Value: Single);
begin
  FBuf := FBuf + FloatToStrR(Value) + ' M' + CR;
end;

procedure TPDFContents.pSetRGBFillColor(Value: TColor);
begin
  FBuf := FBuf + GetColorStr(Value) + ' rg ' + CR;
end;

procedure TPDFContents.pSetRGBStrokeColor(Value: TColor);
begin
  FBuf := FBuf + GetColorStr(Value) + ' RG ' + CR;
end;

procedure TPDFContents.pClosePathStroke;
begin
  FBuf := FBuf + 's' + CR;
end;

procedure TPDFContents.pStroke;
begin
  FBuf := FBuf + 'S' + CR;
end;

procedure TPDFContents.pSetCharSpace(Value: Single);
begin
  FBuf := FBuf + FloatToStrR(Value) + ' Tc' + CR;
end;

procedure TPDFContents.pMoveTextPoint(x, y: Single);
begin
  FBuf := FBuf + FloatToStrR(x) + ' ' + FloatToStrR(y) + ' Td' + CR;
end;

procedure TPDFContents.pSetFontAndSize(AFont: TPDFFontID; ASize: Single);
begin
  FBuf := FBuf + '/F' + IntToStr(FOwner.GetFont(AFont).FontName) +
                                 ' ' + FloatToStrR(ASize) + ' Tf' + CR;
end;

procedure TPDFContents.pShowText(Value: string);
begin
  FBuf := FBuf + '(' + EscapeText(Value) + ') Tj' + CR;
end;

procedure TPDFContents.pShowJText(Value: string);
begin
{*
 *  ���{����܂񂾕�����̏o�́B�������16�i�R�[�h�ɕϊ�����"<",">"�ň͂�
 *
 *}
  FBuf := FBuf + '<' + StrToHex(Value) + '> Tj' + CR;
end;

procedure TPDFContents.pSetLeading(Value: Single);
begin
  FBuf := FBuf + FloatToStrR(Value) + ' TL' + CR;
end;

procedure TPDFContents.pSetTextRendering(Value: TTextRenderingMode);
begin
  FBuf := FBuf + IntToStr(ord(Value)) + ' Tr' + CR;
end;

procedure TPDFContents.pSetWordSpace(Value: Single);
begin
  FBuf := FBuf + FloatToStrR(Value) + ' Tw' + CR;
end;

procedure TPDFContents.pSetHolizontalScaling(Value: Byte);
begin
  FBuf := FBuf + FloatToStrR(Value) + ' Tz' + CR;
end;

procedure TPDFContents.pMoveToNextLine;
begin
  FBuf := FBuf + 'T*' + CR;
end;

procedure TPDFContents.pSetLineWidth(Value: Single);
begin
  FBuf := FBuf + FloatToStrR(Value) + ' w' + CR;
end;

procedure TPDFContents.pClip;
begin
  FBuf := FBuf + 'W' + CR;
end;

procedure TPDFContents.pSaveGState;
begin
  FBuf := FBuf + 'q' + CR;
end;

procedure TPDFContents.pRestoreGState;
begin
  FBuf := FBuf + 'Q' + CR;
end;

procedure TPDFContents.pEoclip;
begin
  FBuf := FBuf + 'W*' + CR;
end;

procedure TPDFContents.pTextShowNextLine(Value: string);
begin
  FBuf := FBuf + '(' + Value + ') ''' + CR;
end;

procedure TPDFContents.pJTextShowNextLine(Value: string);
begin
  FBuf := FBuf + '<' + StrToHex(Value) + '> ''' + CR;
end;

{* TPDFFont *}
constructor TPDFFont.Create(AOwner: TPDFMaker);
begin
  inherited Create(AOwner);
  FFontDescriptor := nil;
  FDescendantFont := nil;
end;

destructor TPDFFont.Destroy;
begin
  if FFontDef <> nil then
    FFontDef.Free;
  inherited;
end;

function TPDFFont.GetFontID: TPDFFontID;
begin
  result := FFontDef.FontID;
end;

procedure TPDFFont.SetFontDef(AFontDef: TPDFFontDef);
begin
  FFontDef := AFontDef;
  { FontDescripter�����ꍇ�iTrueTypeFont,CIDFont�jFontDescripter���쐬 }
  if FFontDef.FontDescriptor <> nil then
  begin
    FFontDescriptor := TPDFFontDescriptor.Create(FOwner);
    FFontDescriptor.FFontDescriptorDef := FFontDef.FontDescriptor;
  end;
  { DescendantFont�����ꍇ�iType0Font�jDescendantFont���쐬 }
  if FFontDef.DescendantFont <> nil then
  begin
    FDescendantFont := TPDFFont.Create(FOwner);
    FDescendantFont.SetFontDef(FFontDef.DescendantFont);
  end;
end;

function TPDFFont.GetCharWidth(C: Char): integer;
begin
  result := FFontDef.GetCharWidth(C);
end;

function TPDFFont.GetObjectDetail: string;
begin
  result := '<<' + CRLF +
            '/Type /Font' + CRLF +
            '/Name /F' + IntToStr(FontName) + CRLF +
            FFontDef.DetailString;
  if FFontDescriptor <> nil then
    result := result + '/FontDescriptor ' + IntToStr(FFontDescriptor.ObjectID) + ' 0 R' + CRLF;
  if FDescendantFont <> nil then
    result := result + '/DescendantFonts [' + IntToStr(FDescendantFont.ObjectID) + ' 0 R]' + CRLF;

  result := result + '>>' + CRLF;

end;

{* TPDFFontDescriptor *}
function TPDFFontDescriptor.GetObjectDetail: string;
begin
  {*
   * ����́AFontDescripter�ɕK�v�ȍŒ���̍��ڂ����������Ă��Ȃ��B
   * �i�ǂ��Ӗ����������Ă��Ȃ��̂ŁB�j
   *
   *}
  result := '<<' + CRLF +
  '/Type /FontDescriptor' + CRLF +
  '/FontName /' + FFontDescriptorDef.FontName + CRLF +
  '/Flags ' + IntToStr(FFontDescriptorDef.Flags) + CRLF +
  '/FontBBox ' + RectToString(FFontDescriptorDef.FontBBox) + CRLF +
  '/StemV ' + IntToStr(FFontDescriptorDef.StemV) + CRLF +
  '/Ascent ' + IntToStr(FFontDescriptorDef.Ascent) + CRLF +
  '/CapHeight ' + IntToStr(FFontDescriptorDef.CapHeight) + CRLF +
  '/Descent ' + IntToStr(FFontDescriptorDef.Descent) + CRLF +
  '/ItalicAngle ' + IntToStr(FFontDescriptorDef.ItalicAngle) + CRLF +
  '>>' + CRLF;
end;

procedure TPDFFontDescriptor.SetFontDescriptorDef(AFontDescriptorDef: TPDFFontDescriptorDef);
begin
  FFontDescriptorDef := AFontDescriptorDef;
end;

destructor TPDFFontDescriptor.Destroy;
begin
  FFontDescriptorDef.Free;
  inherited;
end;

{* TPDFInfo *}
function TPDFInfo.GetObjectDetail: string;
  function StrToUnicodeHex(Value: string): string;
  var
    Buf: array[0..1024] of char;
    Len: integer;
    i: integer;
  begin
    result := 'FEFF001B6A61001B';
    // Value�ŗ^����ꂽ�������UniCode�ɕϊ�
    Len := MultiByteToWideChar(0, 0, PChar(Value), Length(Value), @Buf, 1024);
    i := 0;
    {*
     * �ϊ����ꂽ�������16�i�\���ɕϊ����ď�ʃo�C�g�Ɖ��ʃo�C�g�����ւ���B
     * �Ȃ�œ���ւ��邩�͂킩��Ȃ��B
     *}
    while i < Len * 2 do
    begin
      result := result + IntToHex(Ord(Buf[i+1]), 2) + IntToHex(Ord(Buf[i]), 2);
      inc(i, 2);
    end;
  end;
begin
  result := '<<' + CRLF +
            '/CreationDate (D:' + FormatDateTime('yyyymmddhhnnss', now) + ')' + CRLF +
            '/Creator <' + StrToUnicodeHex(FOwner.Creator) + '>' + CRLF +
            '/Producer (' + PDFMAKER_VERSION_TEXT + ')' + CRLF +
            '/Author <' + StrToUnicodeHex(FOwner.Author) + '>' + CRLF +
            '/Title <' + StrToUnicodeHex(FOwner.Title) + '>' + CRLF +
            '/Subject <' + StrToUnicodeHex(FOwner.Subject) + '>' + CRLF +
            '>>' + CRLF;
end;

end.
