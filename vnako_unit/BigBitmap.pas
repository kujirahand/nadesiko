{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}

////////////
//
// TBigBitmap �͑傫�ȃr�b�g�}�b�v�� Win95/98/ME
// �ň��S�ɕێ�����N���X�ł��B
// TGraphic ����p�����Ă���ATBitmap��
// �قړ����g������ɂ��ėL��܂��B
//
// TBigBitmap �̓r�b�g�}�b�v�����ɐ؂���
// �����ɕ����� ������TBitmap�ŕێ����܂��B
// Win95�n���Windows�̐���(64MB���x)
// �ɐ�������Ȃ����ߐ��S���K�o�C�g�̑傫��
// �r�b�g�}�b�v��ێ��ł��܂��B
//
// TBigBitmap�͕`��̍� DrawMode=dmBanding �ł�API ��
// ���g���4�{�܂łɂƂǂ߂܂��B����Ȃ��g���
// TBigBitmap���� Scanline ���g�����g��p�R�[�h�ɂ���čs���܂��B
// ���̂��߁A�r�b�g�}�b�v�̕`��ɂ�����
// �g�嗦�Ɏ����㐧��������܂���B�܂����̏����ł�
// �����ȃr�b�g�}�b�v�Ɋg�債�ĕ`���Ă��炻���
// �P�`�S�{�ŃR�s�[���邱�Ƃŕ`����s�����߁A��������
// ���܂������邱�ƂȂ��`�悪�s���܂��B
// �܂����̕`���StretchDIBits
// �ōs���邽�߁A�v�����^�Ɉ��S�Ɉ����
// �s���܂��B
//
// �܂�TBigBitmap�͋���ȃr�b�g�}�b�v��
// ���S�ɕێ��ł��A������ǂ�Ȋg�嗦�ł�
// ���S�Ɉ���^�`��ł��܂��B


unit BigBitmap;

interface

uses
  Windows, SysUtils, Classes, Graphics;

type
  // TBigBitmap �̗�O
  EBigBitmapError = class(Exception);

  // TBigBitmap ��PixelFormat �v���p�e�B�̌^
  TBigBitmapPixelFormat = (bbpf1bit, bbpf4bit, bbpf8bit, bbpf24bit);

  // TBigBitmap �� DrawMode �v���p�e�B�̌^
  // dmUseStretchDraw: TBitmap �� StretchDraw �܂� StretchBlt API
  // �@�ŕ`���B�M�����͒Ⴂ������
  // dmUseBanding: Scanline ���g����API�𗊂炸�g��k���������s������
  //    ����������ȃr�b�g�}�b�v�ɕ`���A�����`�悷��B
  //    �g�嗦�ɐ����������A�����ȃr�b�g�}�b�v��傫���g�債��
  //    ������\�B�A�����X�x��
  TBigBitmapDrawMode    = (dmUseOriginalDraw, dmUseBanding);

  TBitmapArray = array of TBitmap;

  TBigBitmap = class;

  // TBigBitmap �� Canvas. TCanvas����p�����Ă͂��Ȃ�
  TBigBitmapCanvas = class
  private
    FBrush: TBrush;
    FFont: TFont;
    FPen: TPen;
    FTextFlags: Longint;
    FCopyMode: TCopyMode;
    FBigBitmap: TBigBitmap;

    {$IFNDEF ORIGINAL} // 2002/7/25 DHGL 1.2
    FClipRgn: HRGN;
    FCopyRectMode: Integer;
    {$ENDIF}

    procedure SetBrush(const Value: TBrush);
    procedure SetFont(const Value: TFont);
    procedure SetPen(const Value: TPen);

    procedure SetupBitmaps;  // �`��̂��ߊe�r�b�g�}�b�v��
                             // ���W�n���̑���ݒ肷��B
    procedure ResetBitmaps;  // ���W�n�����ɖ߂�

    function GetPixel(X, Y: Integer): TColor;
    procedure SetPixel(X, Y: Integer; Value: TColor);

    {$IFNDEF ORIGINAL} // 2002/7/25 �ǉ� DHGL 1.2
    procedure SetClipRgn(const Value: HRGN);
    procedure SetupClipRgn(Force: Boolean);
    {$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;

    // TCanvas �݊����\�b�h
    procedure Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
    procedure BrushCopy(const Dest: TRect; Bitmap: TBitmap;
      const Source: TRect; Color: TColor);
    procedure Chord(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
    procedure CopyRect(const Dest: TRect; Canvas: TCanvas;
      const Source: TRect); overload;
    procedure DrawFocusRect(const Rect: TRect);
    procedure Ellipse(X1, Y1, X2, Y2: Integer); overload;
    procedure Ellipse(const Rect: TRect); overload;
    procedure FillRect(const Rect: TRect);
    procedure FloodFill(X, Y: Integer; Color: TColor; FillStyle: TFillStyle);
    procedure FrameRect(const Rect: TRect);
    procedure LineTo(X, Y: Integer);

    procedure MoveTo(X, Y: Integer);
    procedure Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
    procedure Polygon(const Points: array of TPoint);
    procedure Polyline(const Points: array of TPoint);
    procedure PolyBezier(const Points: array of TPoint);
    procedure PolyBezierTo(const Points: array of TPoint);
    procedure Rectangle(X1, Y1, X2, Y2: Integer); overload;
    procedure Rectangle(const Rect: TRect); overload;
    procedure RoundRect(X1, Y1, X2, Y2, X3, Y3: Integer);
    function TextExtent(const Text: string): TSize;
    function TextHeight(const Text: string): Integer;
    procedure TextOut(X, Y: Integer;
                      const Text: string);
    procedure TextRect(Rect: TRect; X, Y: Integer; const Text: string);
    function TextWidth(const Text: string): Integer;

    procedure Draw(X, Y: Integer; Graphic: TGraphic);
    procedure StretchDraw(const Rect: TRect; Graphic: TGraphic);

    {$IFNDEF ORIGINAL} //2002/7/25 �V�� DHGL 1.2
    procedure CopyRect(Dest: TRect; Bitmap: TBigBitmap; Source: TRect); overload;
    {$ENDIF}

    // TCanvas �݊��v���p�e�B
    property Font: TFont read FFont write SetFont;
    property Brush: TBrush read FBrush write SetBrush;
    property Pen: TPen read FPen write SetPen;
    property TextFlags: Longint read FTextFlags write FTextFlags;
    property CopyMode: TCopyMode read FCopyMode write FCopyMode
                                 default cmSrcCopy;
    property Pixels[X, Y: Integer]: TColor read GetPixel write SetPixel;

    {$IFNDEF ORIGINAL} // 2002/7/25 DHGL 1.2
    // �N���b�v���[�W�����v���p�e�B 2002/7/25 �V�� DHGL 1.2
    property ClipRgn: HRGN read FClipRgn write SetClipRgn;
    property CopyRectMode: Integer read FCopyRectMode write FCopyRectMode;
    {$ENDIF}
  end;

  // TBigBitmap �̐錾
  TBigBitmap = class(TGraphic)
  private
    FBitmaps: TBitmapArray;              // TBitmap �̔z��
    FPixelFormat: TBigBitmapPixelFormat; // Pixel Format
    FWidth: Integer;                     // �r�b�g�}�b�v�̕�
    FHeight: Integer;                    // �r�b�g�}�b�v�̍���
    FCanvas: TBigBitmapCanvas;           // TBigBitmap�pCanvas
    FDrawMode: TBigBitmapDrawMode;       // �`�惂�[�h
    FPreview: Boolean;                   // �v���r���[�p���[�h

    {$IFNDEF ORIGINAL} // 2002/7/25 DHGL 1.2
    WorkAsCopyRect: Boolean;  // Draw �� CopyRect �̂悤��
                              // �������t���O
    {$ENDIF}
    // �STBitmap ��p������
    procedure DiscardBitmaps;
    // �STBitmap ���쐬����
    procedure SetupBitmaps(NewWidth, NewHeight: Integer;
                           NewPixelFormat: TBigBitmapPixelFormat);


    // �v���p�e�B�A�N�Z�X���\�b�h
    function GetPixelBits(APixelFormat: TBigBitmapPixelFormat): Integer;

    procedure SetPixelFormat(const Value: TBigBitmapPixelFormat);

    function GetScanline(Index: Integer): Pointer;
    procedure SetDrawMode(const Value: TBigBitmapDrawMode);
    procedure SetPreview(Value: Boolean);
  protected
    // TGraphic �W���C���^�[�t�F�[�X
    function  GetWidth: Integer; override;
    function  GetHeight: Integer; override;
    procedure SetHeight(Value: Integer); override;
    procedure SetWidth(Value: Integer); override;
    function  GetEmpty: Boolean; override;
    function  GetPalette: HPALETTE; override;
    procedure SetPalette(Value: HPALETTE); override;

    procedure Draw(ACanvas: TCanvas; const Rect: TRect); override;

    procedure AssignTo(Dest: TPersistent); override;
  public
    // TGraphic �W���C���^�[�t�F�[�X
    procedure Assign(Source: TPersistent); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromClipboardFormat(AFormat: Word; AData: THandle;
      APalette: HPALETTE); override;
    procedure SaveToClipboardFormat(var AFormat: Word; var AData: THandle;
      var APalette: HPALETTE); override;

    constructor Create; override;
    destructor  Destroy; override;

    // �`�惂�[�h
    property PixelFormat: TBigBitmapPixelFormat read FPixelFormat
                                                write SetPixelFormat
                                                default bbpf8bit;
    // TBigBitmap �� Canvas
    property Canvas: TBigBitmapCanvas read FCanvas;
    // Scanline : TBitmap�݊�
    property ScanLine[Index: Integer]: Pointer read GetScanline;
    // �`�惂�[�h
    property DrawMode: TBigBitmapDrawMode read FDrawMode
                                          write SetDrawMode
                                          default dmUseOriginalDraw;
    // �v���r���[���[�h
    property Preview: Boolean read FPreview write SetPreview;
  end;

  {$IFNDEF ORIGINAL} // 2002/7/28 DHGL 1.2
  procedure CopyRectBigBitmap(Dest: TRect; ACanvas: TCanvas;
                              Source: TRect; Bitmap: TBigBitmap);
  {$ENDIF}

procedure Register;

implementation

uses DIBUtils, ClipBrd;

procedure Register;
begin end;

procedure RaiseError(s: string);
begin
  raise EBigBitmapError.Create(s);
end;

// TBigBitmap ���� TBitmap �̑傫���̍ő�l
const MaxOneBitmapSize  = 1024*1024*8;
// TBigBitmap ���� TBitmap ��Scanline�傫���̍ő�l
const MaxBitmapScanline = 65536-256;


type
  // TrueColor �̃r�b�g�}�b�v�f�[�^�A�N�Z�X�p�̃��R�[�h�^�ł��B
  // Scanline Property �� TrueColor �̃f�[�^���A�N�Z�X����Ƃ��ɕ֗��ł��B
  TTriple = packed record
    B, G, R: Byte;
  end;
  TTripleArray = array[0..40000000] of TTriple;
  PTripleArray = ^TTripleArray;

  // DWORD �z��A�N�Z�X�p�̌^�B16bpp/32bpp �p
  TDWordArray = array[0..100000000] of DWORD;
  PDWordArray = ^TDWordArray;



{ TBigBitmap }

// TBigBitmap �̃R�s�[
procedure TBigBitmap.Assign(Source: TPersistent);
var
  i: Integer;
  Bitmaps: TBitmapArray;
  nBitmaps: Integer;
  Clip: TClipBoard;    // �N���b�v�{�[�h
  AData: THandle;      // �N���b�v�{�[�h�̃f�[�^�n���h��
  MS: TMemoryStream;
begin
  if Source is TBigBitmap then
  begin
    // ������ TBitmap ���R�s�[����
    nBitmaps := Length(TBigBitmap(Source).FBitmaps);
    SetLength(Bitmaps, nBitmaps);
    FillChar(Bitmaps[0], SizeOf(TBitmap) * nBitmaps, 0);
    try
      for i := 0 to nBitmaps-1 do
      begin
        Bitmaps[i] := TBitmap.Create;
        Bitmaps[i].Assign(TBigBitmap(Source).FBitmaps[i]);
      end
    except
      for i := 0 to nBitmaps-1 do
        Bitmaps[i].Free;
      raise;
    end;
    // TBitmap�Q�������ւ���
    DiscardBitmaps;
    FBitmaps := Bitmaps;
    FWidth := TBigBitmap(Source).FWidth;
    FHeight := TBigBitmap(Source).FHeight;

    // �������R�s�[����
    FPixelFormat := TBigBitmap(Source).FPixelFormat;
    FDrawMode := TBigBitmap(Source).FDrawMode;

    PaletteModified := True;
    Modified := True; // OnChange
  end
  else if Source is TClipBoard then
  begin
    Clip := Source as TClipBoard;
    Clip.Open;
    try
      // �N���b�v�{�[�h���� ClipboardFormat �^�̃f�[�^���擾
      AData := Clip.GetAsHandle(CF_DIB);
      // �����ŁA�f�[�^���擾�ł������̃`�F�b�N�͂��Ȃ��B
      // AData�� LoadFromClipboardFormat ���s���B

      // �f�[�^����������
      LoadFromClipboardFormat(CF_DIB, AData, 0);
    finally
      Clip.Close;
    end;
  end
  else if Source is TBitmap then
  begin
    MS := TMemoryStream.Create;
    try
      (Source as TBitmap).SaveToStream(MS);
      MS.Position := 0;
      LoadFromStream(MS);
    finally
      MS.Free;
    end;
  end
  {$IFNDEF ORIGINAL} // 2002/7/25 �ǉ� DHGL 1.2
  else if Source = Nil then
  begin
    Width := 0; Height := 0;
  end
  {$ENDIF}
  else
    inherited;
end;

procedure TBigBitmap.AssignTo(Dest: TPersistent);
var
  MS: TMemoryStream;
begin
  if Dest is TBitmap then
  begin
    MS := TMemoryStream.Create;
    try
      SaveToStream(MS);
      MS.Position := 0;
      (Dest as TBitmap).LoadFromStream(MS);
    finally
      MS.Free;
    end;
  end
  else
    inherited;
end;

constructor TBigBitmap.Create;
begin
  inherited;
  // �����̏����l���Z�b�g���ACanvas �����
  FPixelFormat := bbpf8bit;
  FDrawMode := dmUseOriginalDraw;
  FCanvas := TBigBitmapCanvas.Create;
  FCanvas.FBigBitmap := Self;
end;

destructor TBigBitmap.Destroy;
begin
  // Canvas �� TBitmap�Q��j������
  FCanvas.Free;
  DiscardBitmaps;
  inherited;
end;

procedure TBigBitmap.DiscardBitmaps;
var
  i: Integer;
begin
  // TBigBitmap���� TBitmap�Q��S�Ĕj������
  for i := 0 to Length(FBitmaps)-1 do
    FBitmaps[i].Free;
  SetLength(FBitmaps, 0);
end;

procedure TBigBitmap.Draw(ACanvas: TCanvas; const Rect: TRect);
var
  i: Integer;

  // dmUseOriginalDraw �p
  SumOfHeights: Integer;     //�eTBitmap�̍����̐ώZ
  NextHeight: Integer;       //���ɕ`�悷�ׂ��ʒu(����)

  // ���p
  w, h: Integer;             // �`��̈�̕��ƍ���(��Βl�e)

  // dmBanding �p
  Band: TBitmap;             // Banding�p�r�b�g�}�b�v
  ScanlineLength: Integer;   // Banding�p�r�b�g�}�b�v��Scanline��
  UsedBitmapWidth: Integer;  // Banding�p�r�b�g�}�b�v�̒��Ŏ��ۂ�
  UsedBitmapHeight: Integer; //  �g���Ă���̈�
  RestWidth: Integer;        // �ŏI�I��Zoom���s����O�̕`��̈�̖������̕�
  RestHeight: Integer;       // �ŏI�I��Zoom���s����O�̕`��̈�̖������̍���
  //�`�挳��Banding�p�r�b�g�}�b�v�̃X�L�������C��
  DestScan, SourceScan: Pointer;
  X, Y: Integer;             // Banding�p�r�b�g�}�b�v�̍��W
  Bits: Byte;                // �s�N�Z���̒l(bbpf4bit, bbpf1bit�p)
  Index: Integer;            // �`�挳�s�N�Z���A�N�Z�X�p�C���f�b�N�X
                             //  (bbpf4bit, bbpf1bit�p)
  SepDIB: TSepDIB;           // Banding�r�b�g�}�b�v�� StretchDIBits ����Ƃ���
                             // DIB���
  pBits: Pointer;            // DIB�̃s�N�Z���f�[�^�ւ̃|�C���^
  BPP: Integer;              // �X�N���[���̃s�N�Z���̃r�b�g���B
  XOrient, YOrient: Integer; // �`��̈�̌���
  OldPalette: HPALETTE;      // �p���b�g��I������O�̃p���b�g

  ZoomFactorX,               // Banding �r�b�g�}�b�v���� Canvas �ւ�
  ZoomFactorY: Integer;      // Zoom Factor  1�`4�{

  BandDrawWidth,             // Zoom ���Banding �r�b�g�}�b�v��
  BandDrawHeight: Integer;   //  �u�g�p�̈�v�̑傫��

  BandWidth,                 // Banding �r�b�g�}�b�v�̑傫���̃L���b�V��
  BandHeight: Integer;       //  �v���p�e�B�ɃA�N�Z�X����ƒx���̂ł����ɂ����

  // �o���h�̃C���f�b�N�X�B���݂� Band ���S�����Ă���̈�̈ʒu��\���܂��B
  XBandIndex, YBandIndex: Integer;

  {$IFNDEF ORIGINAL} // 2002/7/27 �}�� DHGL 1.2
  ClipBox: TRect;            // �`���̃N���b�s���O��`
  DestRect: TRect;           // �o���h�̕`��G���A
  Temp: TRect;
  {$ENDIF}

  const MaxBandWidth  = 1024;// Band �̍ő�̑傫�� 32bpp �� 4MB
        MaxBandHeight = 1024;
begin
  if Empty then Exit;

  {$IFNDEF ORIGINAL} // 2002/7/27 �}�� DHGL 1.2
  GetClipBox(ACanvas.Handle, ClipBox);
  {$ENDIF}

  Canvas.SetupBitmaps;  // �e�r�b�g�}�b�v��Canvas ���ŐV��ԂɃA�b�v�f�[�g
  Canvas.ResetBitmaps;  // 2002.2.3 �ǉ�

  // �e TBitmap ��`���� StretchDraw �ŕ`�悷��
  if FDrawMode = dmUseOriginalDraw then // StretchDraw ���g��
  begin
    // �`��̈�̑傫�����Z�o����
    w := Rect.Right - Rect.Left;
    h := Rect.Bottom - Rect.Top;

    if (w = 0) or (h = 0) then Exit;


    // TBitmap �� Draw �ŏ����ȃr�b�g�}�b�v��`�悷��
    SumOfHeights := 0;
    for i := 0 to Length(FBitmaps)-1 do
    begin
      // �eTBitmap�̕`��ʒu���v�Z���`�悷��
      NextHeight := SumOfHeights + FBitmaps[i].Height;
      {$IFDEF ORIGINAL} // 2002/7/26 DHGL 1.2
      ACanvas.StretchDraw(
        Classes.Rect(Rect.Left,
                     Rect.Top + SumOfHeights * h div FHeight,
                     Rect.Right,
                     Rect.Top + NextHeight * h div FHeight),
        FBitmaps[i]);
      {$ELSE}
      if not WorkAsCopyRect then
        ACanvas.StretchDraw(
          Classes.Rect(Rect.Left,
                       Rect.Top + SumOfHeights * h div FHeight,
                       Rect.Right,
                       Rect.Top + NextHeight * h div FHeight),
          FBitmaps[i])
      else
        ACanvas.CopyRect(
          Classes.Rect(Rect.Left,
                       Rect.Top + SumOfHeights * h div FHeight,
                       Rect.Right,
                       Rect.Top + NextHeight * h div FHeight),
          FBitmaps[i].Canvas,
          Classes.Rect(0, 0, FBitmaps[i].Width, FBitmaps[i].Height));
      {$ENDIF}
      SumOfHeights := NextHeight;
    end;
  end
  // �o���f�B���O�ɂ��\��(���)
  else if FDrawMode = dmUseBanding then
  begin
    // �`���̑傫���̐�Βl�𓾂�
    w := abs(Rect.Right - Rect.Left);
    h := abs(Rect.Bottom - Rect.Top);

    if (w = 0) or (h = 0) then Exit;

    // ZoomFactor �����߂܂��B�傫�Ȋg�嗦�ő傫�ȗ̈��
    // ������鎞�� �ŏI�I�� StretchDIBits �ɂ��g�嗦��
    // 4�{�܂ő傫�����܂��B����͈�����Ƀv�����^�֑���
    // �f�[�^�ʂ����������܂��B
    if      w < 256         then ZoomFactorX := 1
    else if FPreview        then ZoomFactorX := 4
    else if w <= FWidth     then ZoomFactorX := 1
    else if w >= FWidth * 4 then ZoomFactorX := 4
    else if w >= FWidth * 2 then ZoomFactorX := 2
    else                         ZoomFactorX := 1;

    if      h <= 256         then ZoomFactorY := 1
    else if FPreview         then ZoomFactorY := 4
    else if h <= FHeight     then ZoomFactorY := 1
    else if h >= FHeight * 4 then ZoomFactorY := 4
    else if h >= FHeight * 2 then ZoomFactorY := 2
    else                          ZoomFactorY := 1;


    // �`���̌�������B
    if Rect.Right > Rect.Left then XOrient := 1
                              else XOrient := -1;

    if Rect.Bottom > Rect.Top then YOrient := 1
                              else YOrient := -1;

    // �܂�Banding�p�r�b�g�}�b�v�����
    Band := TBitmap.Create;
    try
      Band.PixelFormat := FBitmaps[0].PixelFormat;
      Band.Canvas.Font := Canvas.Font;    // 2002.2.3 �ǉ�
      Band.Canvas.Brush := Canvas.Brush;  // 2002.2.3 �ǉ�

      // �`��悪 1024 x 1024 �ȏ�ɂȂ�Ȃ��悤�ɑ傫�������߂�
      BandWidth :=  MaxBandWidth div ZoomFactorX;
      BandHeight := MaxBandHeight div ZoomFactorY;
      Band.Width := BandWidth;
      Band.Height := BandHeight;

      // ��Ŋg��k�������̂��߂� Scanline �����Z�o���Ă���
      ScanlineLength := (Band.Width * GetPixelBits(FPixelFormat) + 31) div 32 * 4;

      // �p���b�g���R�s�[����
      Band.Palette := CopyPalette(Palette);

      {$IFDEF ORIGINAL} // 2002/7/26 DHGL 1.1
      // �p���b�g�����̉�����
      if Palette <> 0 then
      begin
        OldPalette := SelectPalette(ACanvas.Handle, Palette, True);
        RealizePalette(ACanvas.Handle);
      end;
      {$ELSE}
      if (Palette <> 0) and not WorkAsCopyRect then
      begin
        OldPalette := SelectPalette(ACanvas.Handle, Palette, True);
        RealizePalette(ACanvas.Handle);
      end;
      {$ENDIF}

      BPP := GetDeviceCaps(ACanvas.Handle, BITSPIXEL) *
             GetDeviceCaps(ACanvas.Handle, PLANES);

      // �`��悪8bpp�ȉ��ŕ`����̂� 16bpp�ȏ�Ȃ�
      // Canvas ���n�[�t�g�[�����[�h�ɐݒ肷��
      {$IFDEF ORIGINAL} // 2002/7/26 DHGL 1.2
      if (BPP <= 8) and
         not (Band.PixelFormat in [pf1bit, pf4bit, pf8bit]) then
        SetStretchBltMode(ACanvas.Handle, HALFTONE)
      else
        SetStretchBltMode(ACanvas.Handle, COLORONCOLOR);
      {$ELSE}
      if not WorkAsCopyRect then
        if (BPP <= 8) and
           not (Band.PixelFormat in [pf1bit, pf4bit, pf8bit]) then
          SetStretchBltMode(ACanvas.Handle, HALFTONE)
        else
          SetStretchBltMode(ACanvas.Handle, COLORONCOLOR);
      {$ENDIF}

      try
        RestWidth := w div ZoomFactorX; // Zoom �O�̕`��̈�̕����Z�o
        UsedBitmapWidth := Band.Width;  // Band�̎g�p�̈�̕���������

        XBandIndex := 0;                // �\���� X �����̃��[�v
        while RestWidth > 0 do
        begin
          RestHeight := h div ZoomFactorY; // Zoom �O�̕`��̈�̍������Z�o
          UsedBitmapHeight := Band.Height; // Band�̎g�p�̈�̍�����������

          YBandIndex := 0;                 // �\���� Y �����̃��[�v
          while RestHeight > 0 do
          begin
            // Zoom�O�̕\���̈�̎c�ɏ]���ăr�b�g�}�b�v�̏c�̎g�p�̈��␳
            if RestHeight < UsedBitmapHeight then
              UsedBitmapHeight := RestHeight;


            {$IFNDEF ORIGINAL} // 2002/7/27 �}��}
            BandDrawWidth  := UsedBitmapWidth * ZoomFactorX;
            BandDrawHeight := UsedBitmapHeight * ZoomFactorY;

            // Zoom �ɂ���ĕ`�悷��ꍇ�ACanvas �̕`��悪�ő� ZoomFactor-1
            // �]���ĕ`�悳��Ȃ��̈悪�o����B�����h�����ߔ�����
            // �g�嗦��ς���(1%���x)�B
            if w - (Band.Width * XBandIndex * ZoomFactorX + BandDrawWidth) <
               ZoomFactorX then
              BandDrawWidth := w - Band.Width * XBandIndex * ZoomFactorX;
            if h - (Band.Height * YBandIndex * ZoomFactorY + BandDrawHeight) <
               ZoomFactorY then
              BandDrawHeight := h - Band.Height * YBandIndex * ZoomFactorY;

            // �`����`���v�Z
            DestRect.Left := Rect.Left + Band.Width * XBandIndex *
                             ZoomFactorX * XOrient;
            DestRect.Top  := Rect.Top + Band.Height * YBandIndex *
                             ZoomFactorY * YOrient;

            // �`���̑傫�������E���W�ŋ��߂�
            DestRect.Right := DestRect.Left + BandDrawWidth * XOrient;
            DestRect.Bottom := DestRect.Top + BandDrawHeight * YOrient;

            temp := DestRect;
            if DestRect.Left > DestRect.Right then
            begin
              DestRect.Left := Temp.Right + 1;
              DestRect.Right := Temp.Left + 1;
            end;
            if DestRect.Top > DestRect.Bottom then
            begin
              DestRect.Top := Temp.Bottom + 1;
              DestRect.Bottom := Temp.Top + 1;
            end;

            if IntersectRect(Temp, ClipBox, DestRect) then
            begin
            {$ENDIF}


              //�@�`����Ƃ��� Band �ւ̊g��k������
              for Y := 0 to UsedBitmapHeight-1 do
              begin
                SourceScan := Scanline[(YBandIndex*BandHeight + y) *
                                       FHeight div (h  div ZoomFactorY)];
                DestScan := Band.Scanline[Y];
                FillChar(DestScan^, ScanLinelength, 0);

                if RestWidth < UsedBitmapWidth then UsedBitmapWidth := RestWidth;


                for X := 0 to UsedBitmapWidth-1 do
                begin
                  case PixelFormat of
                    bbpf8bit:
                      begin
                        PByteArray(DestScan)^[x] :=
                          PByteArray(SourceScan)^[(XBandIndex * BandWidth + x) *
                          FWidth div (w div ZoomFactorX)];
                      end;
                    bbpf24bit:
                      begin
                        PTripleArray(DestScan)^[X] :=
                          PTripleArray(SourceScan)^[(XBandIndex * BandWidth + x) *
                          FWidth div (w div ZoomFactorX)];
                      end;
                    bbpf4bit:
                      begin
                        Index := (XBandIndex * BandWidth + x) * FWidth
                                 div (w div ZoomFactorX);
                        Bits := PByteArray(SourceScan)^[Index div 2];
                        Bits := (Bits shr (4*(1 - Index mod 2))) and $0f;

                        PByteArray(DestScan)^[X div 2] :=
                          PByteArray(DestScan)^[X div 2] or
                          (Bits shl (4*(1 - X mod 2)));
                      end;
                    bbpf1bit:
                      begin
                        Index := (XBandIndex * BandWidth + x) * FWidth
                                 div (w div ZoomFactorX);
                        Bits := PByteArray(SourceScan)^[Index div 8];
                        Bits := (Bits shr (7 - Index mod 8)) and $01;

                        PByteArray(DestScan)^[X div 8] :=
                          PByteArray(DestScan)^[X div 8] or
                          (Bits shl (7 - X mod 8));
                      end;
                  end;
                end;
              end;

              // Band �� DIB�������
              FillChar(SepDIB, SizeOf(SepDIB), 0);
              SepDIB.W3Head.biSize := SizeOf(TBitmapInfoHeader);
              SepDIB.W3Head.biWidth := Band.Width;
              SepDIB.W3Head.biPlanes := 1;
              SepDIB.W3Head.biBitCount := GetPixelBits(FPixelFormat);
              SepDIB.W3Head.biCompression := BI_RGB;
              SepDIB.W3Head.biHeight := Band.Height;

              // �J���[�e�[�u�����擾����
              SepDIB.W3Head.biClrUsed :=
                GetDIBColorTable(Band.Canvas.Handle,
                                 0, 256,
                                 SepDIB.W3HeadInfo.bmiColors[0]);
              SepDIB.W3Head.biClrImportant := SepDIB.W3Head.biClrUsed;

              // �s�N�Z���f�[�^�̐擪�����߂�
              pBits := Band.Scanline[Band.Height-1];

              {$IFDEF ORIGINAL} // 2002/7/27 �폜 DHGL 1.2
              BandDrawWidth  := UsedBitmapWidth * ZoomFactorX;
              BandDrawHeight := UsedBitmapHeight * ZoomFactorY;

              // Zoom �ɂ���ĕ`�悷��ꍇ�ACanvas �̕`��悪�ő� ZoomFactor-1
              // �]���ĕ`�悳��Ȃ��̈悪�o����B�����h�����ߔ�����
              // �g�嗦��ς���(1%���x)�B
              if w - (Band.Width * XBandIndex * ZoomFactorX + BandDrawWidth) <
                 ZoomFactorX then
                BandDrawWidth := w - Band.Width * XBandIndex * ZoomFactorX;
              if h - (Band.Height * YBandIndex * ZoomFactorY + BandDrawHeight) <
                 ZoomFactorY then
                BandDrawHeight := h - Band.Height * YBandIndex * ZoomFactorY;
              {$ENDIF}

              // �ʒu���v�Z����StretchDIBits�œ��{�ŕ`�悷��
              StretchDIBits(ACanvas.Handle,
                            // �`���̈ʒu
                            Rect.Left + Band.Width * XBandIndex *
                            ZoomFactorX * XOrient,
                            Rect.Top + Band.Height * YBandIndex *
                            ZoomFactorY * YOrient,
                            // �`���̑傫��
                            BandDrawWidth * XOrient,
                            BandDrawHeight * YOrient,
                            // �`�挳(Band)�̈ʒu�B���������_�ł��邱�Ƃɒ��ӁI
                            0,
                            Band.Height - UsedBitmapHeight,
                            // �`�挳(Band)�̎g�p�̈�̑傫��
                            UsedBitmapWidth,
                            UsedBitmapHeight,
                            pBits,
                            SepDIB.W3HeadInfo,
                            DIB_RGB_COLORS,
                            ACanvas.CopyMode);

            {$IFNDEF ORIGINAL} // 2002/7/27 �}�� DHGL 1.2
            end;
            {$ENDIF}

            // �c�� Zoom�O�̖������̕`��̈���Z�o����
            if BandDrawHeight = h - Band.Height * YBandIndex * ZoomFactorY then
              RestHeight := 0
            else
              Dec(RestHeight, UsedBitmapHeight);
            Inc(YBandIndex);
          end;
          // �c�� Zoom�O�̖������̕`��̈���Z�o����
          if BandDrawWidth = w - Band.Width * XBandIndex * ZoomFactorX then
            RestWidth := 0
          else
            Dec(RestWidth, UsedBitmapWidth);
          Inc(XBandIndex);
        end;
      finally
        {$IFDEF ORIGINAL} // 2002/7/26 DHGL 1.2
        if Palette <> 0 then
          SelectPalette(ACanvas.Handle, OldPalette, True);
        {$ELSE}
        if (Palette <> 0) and not WorkAsCopyRect then
          SelectPalette(ACanvas.Handle, OldPalette, True);
        {$ENDIF}
      end;
    finally
      Band.Free;
    end;
  end
  else
    RaiseError('TBigBitmap.Draw: Unknown Mode');
end;

// �󂩂ǂ�����Ԃ�
function TBigBitmap.GetEmpty: Boolean;
begin
  Result := (FWidth = 0) or (FHeight = 0);
end;

// TBigBitmap �̍�����Ԃ�
function TBigBitmap.GetHeight: Integer;
begin
  Result := FHeight;
end;

// TBigBitmap �̃p���b�g��Ԃ�
function TBigBitmap.GetPalette: HPALETTE;
begin
  if Length(FBitmaps) >= 1 then
    Result := FBitmaps[0].Palette
  else
    Result := 0;
end;

// PixelFormat����s�N�Z��������̃r�b�g�����v�Z����
function TBigBitmap.GetPixelBits(APixelFormat: TBigBitmapPixelFormat)
  : Integer;
begin
  case APixelFormat of
    bbpf1bit: Result := 1;
    bbpf4bit: Result := 4;
    bbpf8bit: Result := 8;
    bbpf24bit: Result := 24;
    else
      RaiseError('TBigBitmap.GetPixelBits: Invalid Pixel Format');
  end;
end;

// TBigBitmapPixelFormat �� TPixelFormat �ɕϊ�
function BBPixelFormatToPixelFormat(ABBPixelFormat: TBigBitmapPixelFormat)
  : TPixelFormat;
begin
  case ABBPixelFormat of
    bbpf1bit: Result := pf1bit;
    bbpf4bit: Result := pf4bit;
    bbpf8bit: Result := pf8bit;
    bbpf24bit: Result := pf24bit;
    else
      RaiseError('BBPixelFormatToPixelFormat: Invalid Pixel Format');
  end;
end;

// TPixelFormat �� TBigBitmapPixelFormat �ɕϊ�
function PixelFormatToBBPixelFormat(APixelFormat: TPixelFormat)
  : TBigBitmapPixelFormat;
begin
  case APixelFormat of
    pf1bit: Result := bbpf1bit;
    pf4bit: Result := bbpf4bit;
    pf8bit: Result := bbpf8bit;
    pf24bit: Result := bbpf24bit;
    else
      RaiseError('PixelFormatToBBPixelFormat: Invalid Pixel Format');
  end;
end;

// TBigBitmap �� ScanLine �𓾂�
// TBiitmap �ƌ݊��ŁA����ȃr�b�g�}�b�v��
// Scanline �Ɠ����̂��̂�������
function TBigBitmap.GetScanline(Index: Integer): Pointer;
var
  BitmapHeight: Integer;
begin
  if Empty then
    RaiseError('TBigBitmap.GetScanline: No Bitomaps');
  if (Index >= FHeight) or (Index < 0) then
    RaiseError('TBigBitmap.GetScanline: Index is out of Range');

  BitmapHeight := FBitmaps[0].Height;
  Result := FBitmaps[Index div BitmapHeight].Scanline[Index mod BitmapHeight];
end;

// TBigBitmap �̍�����Ԃ�
function TBigBitmap.GetWidth: Integer;
begin
  Result := FWidth;
end;

type
  // ���������e���V�t�g���ēǂݏ������郁�����X�g���[��
  TShiftedMemoryStream = class(TStream)
  private
    FBufferForShift: PChar;   // �V�t�g���̃f�[�^������o�b�t�@
    FShiftLength: DWORD;      // �V�t�g���̃f�[�^������o�b�t�@�̒���
    FMemPtr: PChar;           // �X�g���[�����̃������ւ̃|�C���^
    FMemSize: DWORD;          // �X�g���[�����̃�������
    FPosition: Integer;      // �O���猩���X�g���[���̌��݈ʒu
  public
    constructor Create(BufferForShift: Pointer; ShiftLength: DWORD;
                       MemPtr: Pointer; MemSize: DWORD);
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

{ TShiftedMemoryStream }

constructor TShiftedMemoryStream.Create(BufferForShift: Pointer;
  ShiftLength: DWORD; MemPtr: Pointer; MemSize: DWORD);
begin
  inherited Create;
  FBufferForShift := BufferForShift;
  FShiftLength := ShiftLength;
  FMemPtr := MemPtr;
  FMemSize := MemSize;
end;

// Seek
function TShiftedMemoryStream.Seek(Offset: Integer; Origin: Word): Longint;
begin
  // �X�g���[���T�C�Y�� FMemSize + FShiftLength �ɂȂ邱�Ƃ��l��
  case Origin of
    soFromBeginning: FPosition := Offset;
    soFromCurrent: Inc(FPosition, Offset);
    soFromEnd: FPosition := FMemSize + FShiftLength + Offset;
  end;
  Result := FPosition;
end;

// �X�g���[����ǂ�
// Position �� 0 ���� FShiftLength-1 �܂ł� FBufferForShift ����
// Position �� FShiftLength ������ FMemPtr ����ǂ�
function TShiftedMemoryStream.Read(var Buffer; Count: Longint): Longint;
var
  CopyLength: Integer;
begin
  if (FPosition >= 0) and (Count >= 0) then
  begin
    Result := Size - FPosition; // �c�T�C�Y�v�Z
    if Result > 0 then
    begin
      if Result > Count then Result := Count;  // �c�T�C�Y�� Count ���
                                               // �傫����� COunt �����ǂ�
      if FPosition < FShiftLength then
      // �Q�̈���܂��������R�s�[
      begin
        // FPosition ���� FShiftLength-1 �܂ł̃R�s�[
        CopyLength := FShiftLength - FPosition;
        if CopyLength > Count then CopyLength := Count;
        Move((FBufferForShift + FPosition)^, Buffer, CopyLength);
        // FShiftLength �ȍ~�̃R�s�[
        if FPosition + Count > FShiftLength then
        Move(FMemPtr^, (PChar(@Buffer) + FShiftLength - FPosition)^,
             FPosition + Count - FShiftLength);
      end
      else
      // �Q�̈���܂�����Ȃ��R�s�[
        Move((FMemPtr + FPosition - FShiftLength)^, Buffer, Count);

      Inc(FPosition, Result);
      Exit;
    end;
  end;
  Result := 0;
end;

// �X�g���[���ɏ���
// Position �� 0 ���� FShiftLength-1 �܂ł� FBufferForShift ��
// Position �� FShiftLength ������ FMemPtr �ɏ���
function TShiftedMemoryStream.Write(const Buffer; Count: Longint): Longint;
var
  CopyLength: Integer;
begin
  if (FPosition >= 0) and (Count >= 0) then
  begin
    Result := Size - FPosition;   // �c�T�C�Y�v�Z
    if Result > 0 then
    begin
      if Result > Count then Result := Count;  // �c�T�C�Y�� Count ���
                                               // �傫����� COunt ��������

      if FPosition < FShiftLength then
      // �Q�̈���܂��������R�s�[
      begin
        // FPosition ���� FShiftLength-1 �܂ł̃R�s�[
        CopyLength := FShiftLength - FPosition;
        if CopyLength > Count then CopyLength := Count;
        Move(Buffer, (FBufferForShift + FPosition)^, CopyLength);
        // FShiftLength �ȍ~�̃R�s�[
        if FPosition + Count > FShiftLength then
        Move((PChar(@Buffer) + FShiftLength - FPosition)^, FMemPtr^,
             FPosition + Count - FShiftLength);
      end
      else
      // �Q�̈���܂�����Ȃ��R�s�[
        Move(Buffer, (FMemPtr + FPosition - FShiftLength)^, Count);

      Inc(FPosition, Result);
      Exit;
    end;
  end;
  Result := 0;
end;


procedure TBigBitmap.LoadFromClipboardFormat(AFormat: Word; AData: THandle;
  APalette: HPALETTE);

var FileHeader: TBitmapFileHeader; // �r�b�g�}�b�v�t�@�C���w�b�_
    pDIB: Pointer;
    DIBSize: Integer;
    ShiftedStream: TShiftedMemoryStream;

  function CreateBitmapFileHeaderFromPackedDIB(pHead: PBitmapInfoHeader;
                                               MemorySize: Integer)
    : TBitmapFileHeader;
  var
    pCoreHead: PBitmapCoreHeader;
    HeadSize: Integer; // �r�b�g�}�b�v�̂փb�_�T�C�Y�B�J���[�e�[�u�����܂�
  begin
    if pHead.biSize < SizeOf(TBitmapInfoHeader) then
    // OS2 �w�b�_
    begin
      pCoreHead := PBitmapCoreHeader(PHead);
      HeadSize := pCorehead.bcSize;  // �w�b�_�T�C�Y
      // �J���[�e�[�u���T�C�Y�����Z
      case pCoreHead.bcBitCount * pCoreHead.bcPlanes of
      1: Inc(HeadSize, Sizeof(TRGBTriple) * 2);
      4: Inc(HeadSize, Sizeof(TRGBTriple) * 16);
      8: Inc(HeadSize, Sizeof(TRGBTriple) * 256);
      24: ;
      else raise EInvalidGraphic.Create('Invalid Clipbboard Data');
      end;
    end
    else
    begin
      HeadSize := pHead.biSize;    // �փb�_�T�C�Y
      // V3 �w�b�_�Ńr�b�g�t�B�[���h�`���Ȃ�}�X�N�T�C�Y�����Z
      if (pHead.biCompression = BI_BITFIELDS) and
          (pHead.biSize = SizeOf(TBitmapInfoHeader)) then
        Inc(HeadSize, SizeOf(DWORD) * 3);
      // �J���[�e�[�u���T�C�Y�����Z
      if pHead.biClrUsed <> 0 then
        Inc(HeadSize, SizeOf(DWORD) * pHead.biClrUsed)
      else
        case pHead.biPlanes * phead.biBitCount of
        1: Inc(HeadSize, SizeOf(DWORD) * 2);
        4: Inc(HeadSize, SizeOf(DWORD) * 16);
        8: Inc(HeadSize, SizeOf(DWORD) * 256);
        16, 24, 32: ;
        else raise EInvalidGraphic.Create('Invalid Clipbboard Data');
        end;
    end;
    Result.bfType := $4D42;
    Result.bfSize := SizeOf(TBitmapFileHeader) + MemorySize;
    Result.bfReserved1 := 0; Result.bfReserved2 := 0;
    Result.bfOffBits := SizeOf(TBitmapFileHeader) + HeadSize;
  end;
begin
  if (AFormat <> CF_DIB)then
    raise EInvalidGraphic.Create('Invalid Clipbboard Data');

  DIBSize := GlobalSize(AData);
  if DIBSize < SizeOf(TBitmapCoreHeader) then
    raise EInvalidGraphic.Create('Invalid Clipbboard data');
  pDIB := GlobalLock(AData);
  if pDIB = Nil then raise EInvalidGraphic.Create('Invalid Clipbboard data');
  try
    FileHeader := CreateBitmapFileHeaderFromPackedDIB(pDIB, DIBSize);
    ShiftedStream := TShiftedMemoryStream.Create(@FileHeader,
                                                 SizeOf(FileHeader),
                                                 pDIB, DIBSize);
    try
      LoadFromStream(ShiftedStream);
    finally
      ShiftedStream.Free;
    end;

  finally
    GlobalUnlock(AData);
  end;
end;

procedure TBigBitmap.LoadFromStream(Stream: TStream);
const
  Black: TRGBQUAD = (rgbBlue:0; rgbGreen:0; rgbRed:0; rgbReserved:0);
var
  SepDIB, NewSepDIB: TSepDIB;   // DIB���
  i, j: LongInt;

  ScanlineLength: Integer;  // �eTBitmap�̃X�L�������C����
  nBitmaps: Integer;        // TBitmap�̐�
  BitmapHeight: Integer;    // TBitmap�̍���(�Ō�̂��̂͏���)
  Bitmaps: TBitmapArray;    // TBitmap�̔z��
  TotalHeight: Integer;     // TBitmap�̍����̌v
  RestHeight: Integer;      // �������̍���
  BottomUp: Boolean;        // �r�b�g�}�b�v�̌���
  BitsSize: Integer;        // �r�b�g�}�b�v�̃s�N�Z���f�[�^�̑傫��
begin

  LoadDIBFromStream(SepDIB, Stream);

  // 16 or 32 bpp �Ȃ� 24bpp �ɒ����B
  if SepDIB.W3Head.biBitCount in [16, 32] then
  begin
    DIB32_16ToDIB24(SepDIB, NewSepDIB);
    SepDIB := NewSepDIB;
  end;

  // ���k���ꂽ�܂܂ł̓r�b�g�}�b�v�� TBitmap�Q�ɕ��z�ł��Ȃ��̂�
  // �ŃR�[�h����

  if SepDIB.W3Head.biCompression = BI_RLE4 then
  begin
    Convert4BitRLETo4bitRGB(SepDIB, NewSepDIB);
    SepDIB := NewSepDIB;
  end
  else if SepDIB.W3Head.biCompression = BI_RLE8 then
  begin
    Convert8BitRLETo8bitRGB(SepDIB, NewSepDIB);
    SepDIB := NewSepDIB;
  end;

  // TBitmap�Q�̑傫���Ɛ������߂�
  ScanLineLength := (SepDIB.W3Head.biWidth * SepDIB.W3Head.biBitCount + 31)
                     div 32 * 4;

  // �S�s�N�Z���f�[�^�T�C�Y���v�Z
  BitsSize := ScanLineLength * abs(SepDIB.W3Head.biHeight);

  if  ScanLineLength >= MaxBitmapScanline then
    RaiseError('TBigBitmap.LoadFromStream: Too Big Width or Too Many Pixel Bits');

  BitmapHeight := MaxOneBitmapSize div ScanLineLength;
  if BitmapHeight > abs(SepDIB.W3Head.biHeight) then
    BitmapHeight := abs(SepDIB.W3Head.biHeight);
  nBitmaps := (abs(SepDIB.W3Head.biHeight) + BitmapHeight - 1) div BitmapHeight;

  // �z����m��
  SetLength(Bitmaps, nBitmaps);
  FillChar(Bitmaps[0], SizeOf(TBitmap) * nBitmaps, 0);

  TotalHeight := abs(SepDIB.W3Head.biHeight);
  RestHeight := TotalHeight;


  if SepDIB.W3Head.biHeight > 0 then BottomUp := True
                                else BottomUp := False;
  try
    for i := 0 to nBitmaps-1 do
    begin
      Bitmaps[i] := TBitmap.Create;
      case SepDIB.W3Head.biBitCount of
        1: Bitmaps[i].PixelFormat := pf1bit;
        4: Bitmaps[i].PixelFormat := pf4bit;
        8: Bitmaps[i].PixelFormat := pf8bit;
       24: Bitmaps[i].PixelFormat := pf24bit;
      end;
      Bitmaps[i].Width := SepDIB.W3Head.biWidth;
      Bitmaps[i].Palette := CreatePaletteFromDIB(SepDIB);

      if RestHeight > BitmapHeight then
      begin
        Bitmaps[i].Height := BitmapHeight;
        for j := 0 to Bitmaps[i].Height-1 do
          if BottomUp then
            System.Move(AddOffset(Pointer(SepDIB.Bits),
                                  BitsSize - i * BitmapHeight * ScanlineLength -
                                  (j+1) * ScanlineLength)^,
                                  Bitmaps[i].Scanline[j]^, ScanLineLength)
          else
            System.Move(AddOffset(Pointer(SepDIB.Bits),
                                  i * BitmapHeight * ScanlineLength +
                                  j * ScanlineLength)^,
                                  Bitmaps[i].Scanline[j]^, ScanLineLength);
      end
      else
      begin
        Bitmaps[i].Height := RestHeight;
        for j := 0 to Bitmaps[i].Height-1 do
          if BottomUp then
            System.Move(AddOffset(Pointer(SepDIB.Bits),
                                  RestHeight * ScanlineLength -
                                  (j+1) * ScanlineLength)^,
                                  Bitmaps[i].Scanline[j]^, ScanLineLength)
          else
            System.Move(AddOffset(Pointer(SepDIB.Bits),
                                  j * ScanlineLength)^,
                                  Bitmaps[i].Scanline[j]^, ScanLineLength);
      end;
      Dec(RestHeight, BitmapHeight);
    end;
  except
    for i := 0 to nBitmaps-1 do
      Bitmaps[i].Free;
    raise;
  end;
  // �d�グ
  DiscardBitmaps;        // �Â��r�b�g�}�b�v���̂č����ւ���
  FBitmaps := Bitmaps;
  FWidth := SepDIB.W3Head.biWidth;
  FHeight := TotalHeight;
  FPixelFormat := PixelFormatToBBPixelFormat(FBitmaps[0].PixelFormat);
  PaletteModified := True;
  Modified := True;
end;

procedure TBigBitmap.SaveToClipboardFormat(var AFormat: Word;
  var AData: THandle; var APalette: HPALETTE);
var
  FileHeader: TBitmapFileHeader;       // �_�~�[�̃t�@�C���w�b�_
  DIBSize, ScanlineLength: Integer;    // Packed DIB �̃T�C�Y
  Colors: array[0..255] of DWORD;      // �_�~�[�̃J���[�e�[�u��
  ColorCount: Integer;                 // �r�b�g�}�b�v�̐F��
  ShiftedStream: TShiftedMemoryStream; // �t�@�C���w�b�_���J�b�g����X�g���[��
  DIBPtr: Pointer;                     // PackedDIB �ւ̃|�C���^
begin
  if Empty then
  begin
    AData := 0;
    AFormat := CF_DIB;
    Exit;
  end;

  DIBSize := SizeOf(TBitmapInfoHeader);                     // �w�b�_��
  ColorCount := GetDIBColorTable(FBitmaps[0].Canvas.Handle, //�J���[�e�[�u��
                     0, 256,                                // �������Z
                     Colors[0]);
  Inc(DIBSize, SizeOf(DWORD) * ColorCount);
  case PixelFormat of                                       //�s�N�Z���f�[�^
  bbpf1bit:  ScanlineLength := ((Width + 31) div 32) * 4;   // �������Z
  bbpf4bit:  ScanlineLength := ((Width * 4 + 31) div 32) * 4;
  bbpf8bit:  ScanlineLength := ((Width * 8 + 31) div 32) * 4;
  bbpf24bit: ScanlineLength := ((Width * 24 + 31) div 32) * 4;
  end;

  Inc(DiBSize, ScanlineLength * Height);
  AFormat := CF_DIB;

  // �N���b�v�{�[�h�ɓn�����������m��
  AData := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, DIBSize);
  if AData = 0 then RaiseError('Cannot Allocate Memory');
  try
    DIBPtr := GlobalLock(AData);
    if DIBPtr = Nil then RaiseError('Cannnot Lock Memory for CLipboard');
    try
      ShiftedStream := TShiftedMemoryStream.Create(@FileHeader,
                                                   SizeOf(FileHeader),
                                                   DIBPtr,
                                                   DIBSize);
      try
        SaveToStream(ShiftedStream);
      finally
        ShiftedStream.Free;
      end;
    finally
      GlobalUnlock(AData);
    end;
  except
    GlobalFree(AData);
  end;
end;

procedure TBigBitmap.SaveToStream(Stream: TStream);
var
  bfh: TBitmapFileHeader;
  SepDIB: TSepDIB;
  ScanLineLength: Integer;
  i: Integer;
begin
  if Empty then Exit;

  // �����̃r�b�g�}�b�v���ЂƂ�DIB�t�@�C���C���[�W�ɂ��ď����o��
  ScanLineLength := (FWidth * GetPixelBits(FPixelFormat) + 31) div 32 * 4;

  FillChar(SepDIB, SizeOf(SepDIB), 0);
  SepDIB.W3Head.biSize := SizeOf(TBitmapInfoHeader);
  SepDIB.W3Head.biWidth := FWidth;
  SepDIB.W3Head.biHeight := FHeight;
  SepDIB.W3Head.biPlanes := 1;
  SepDIB.W3Head.biBitCount := GetPixelBits(FPixelFormat);
  SepDIB.W3Head.biCompression := BI_RGB;

  SepDIB.W3Head.biClrUsed :=
    GetDIBColorTable(FBitmaps[0].Canvas.Handle,
                     0, 256,
                     SepDIB.W3HeadInfo.bmiColors[0]);

  SepDIB.W3Head.biHeight := FHeight;

  bfh.bfType := $4D42;
  bfh.bfSize := SizeOf(bfh) + SizeOf(SepDIB.W3Head) +
                SizeOf(TRGBQUAD) * SepDIB.W3Head.biClrUsed +
                ScanLineLength * FHeight;
  bfh.bfReserved1 := 0;
  bfh.bfReserved2 := 0;
  bfh.bfOffBits   := SizeOf(bfh) + SizeOf(SepDIB.W3Head) +
                     SizeOf(TRGBQUAD) * SepDIB.W3Head.biClrUsed;
  Stream.WriteBuffer(bfh, SizeOf(bfh));
  Stream.WriteBuffer(SepDIB.Dummy, SizeOf(SepDIB.W3Head) +
                     SizeOf(TRGBQUAD) * SepDIB.W3Head.biClrUsed);

  for i := Length(FBitmaps)-1 downto 0 do
    Stream.WriteBuffer(FBitmaps[i].Scanline[FBitmaps[i].Height-1]^,
                       ScanlineLength * FBitmaps[i].Height);
end;

// �`�惂�[�h�̐ݒ�
procedure TBigBitmap.SetDrawMode(const Value: TBigBitmapDrawMode);
begin
  FDrawMode := Value;
  PaletteModified := True;
  Modified := True;
end;

// ������ύX����B�r�b�g�}�b�v�̓N���A�����
procedure TBigBitmap.SetHeight(Value: Integer);
begin
  SetupBitmaps(FWidth, Value, FPixelFormat);
end;

// �p���b�g��ύX����B
procedure TBigBitmap.SetPalette(Value: HPALETTE);
var
  i: Integer;
begin
  for i := 0 to Length(FBitmaps) -1 do
    FBitmaps[i].Palette := CopyPalette(Value);

  DeleteObject(Value);

  PaletteModified := True;
  Modified := True;
end;

// �s�N�Z���`����ύX����B�r�b�g�}�b�v�̓N���A�����B
procedure TBigBitmap.SetPixelFormat(const Value: TBigBitmapPixelFormat);
begin
  SetupBitmaps(FWidth, FHeight, Value);
end;

// ���A�����A�s�N�Z���`�������� TBitmap�Q�����
procedure TBigBitmap.SetPreview(Value: Boolean);
begin
  if FPreview <> Value then
  begin
    FPreview := Value;
    Modified := True;
  end;
end;

procedure TBigBitmap.SetupBitmaps(NewWidth, NewHeight: Integer;
                                  NewPixelFormat: TBigBitmapPixelFormat);
var
  nBitmaps: Integer;
  BitmapHeight: Integer;
  ScanLineLength: Integer;
  Bitmaps: TBitmapArray;
  RestHeight: Integer;
  i: Integer;
begin
  if NewWidth < 0 then
    RaiseError('TBigBitmap.SetBitmaps: Negative Width');
  if NewHeight < 0 then
    RaiseError('TBigBitmap.SetBitmaps: Negative Height');

  ScanLineLength := (NewWidth * GetPixelBits(NewPixelFormat) + 31) div 32 * 4;
  if  ScanLineLength >= MaxBitmapScanline then
    RaiseError('TBigBitmap.SetBitmaps: Too Big Width or Too Many Pixel Bits');
  if (NewWidth = 0) or (NewHeight = 0) then
  begin
    DiscardBitmaps;
    FWidth := NewWidth; FHeight := NewHeight;
    FPixelFormat := NewPixelFormat;
    PaletteModified := True;
    Modified := True;
    Exit;
  end;

  // TBitmap �̑傫���Ɛ������߂�v
  BitmapHeight := MaxOneBitmapSize div ScanLineLength;
  if BitmapHeight > NewHeight then
    BitmapHeight := NewHeight;
  nBitmaps := (NewHeight + BitmapHeight - 1) div BitmapHeight;

  // �z���p�ӂ���
  SetLength(Bitmaps, nBitmaps);
  FillChar(Bitmaps[0], SizeOf(TBitmap) * nBitmaps, 0);
  RestHeight := NewHeight;
  try
    // �r�b�g�}�b�v�Q�����
    for i := 0 to nBitmaps-1 do
    begin
      Bitmaps[i] := TBitmap.Create;
      Bitmaps[i].PixelFormat := BBPixelFormatToPixelFormat(NewPixelFormat);
      Bitmaps[i].Width := NewWidth;
      if RestHeight > BitmapHeight then
        Bitmaps[i].Height := BitmapHeight
      else
        Bitmaps[i].Height := RestHeight;

      // ���ɏ���������
      Bitmaps[i].Canvas.FillRect(Rect(0, 0, NewWidth, Bitmaps[i].Height));

      Dec(RestHeight, BitmapHeight);
  end
  except
    for i := 0 to nBitmaps-1 do
      Bitmaps[i].Free;
    raise;
  end;
  //�d�グ�v
  DiscardBitmaps;     // �Â��r�b�g�}�b�v���̂č����ւ���
  FBitmaps := Bitmaps;
  FWidth := NewWidth;
  FHeight := NewHeight;
  FPixelFormat := NewPixelFormat;
  PaletteModified := True;
  Modified := True;
  Canvas.MoveTo(0, 0); // �y���̏����ʒu�� (0, 0) ��
end;

// ����ύX����B�r�b�g�}�b�v�̓N���A�����
procedure TBigBitmap.SetWidth(Value: Integer);
begin
  SetupBitmaps(Value, FHeight, FPixelFormat);
end;

{ TBigBitmapCanvas }

// �ʂ�`��
procedure TBigBitmapCanvas.Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// BrushCopy
procedure TBigBitmapCanvas.BrushCopy(const Dest: TRect; Bitmap: TBitmap;
  const Source: TRect; Color: TColor);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.BrushCopy(Dest, Bitmap, Source, Color);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// ����`��
procedure TBigBitmapCanvas.Chord(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.Chord(X1, Y1, X2, Y2, X3, Y3, X4, Y4);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// CopyRect
procedure TBigBitmapCanvas.CopyRect(const Dest: TRect; Canvas: TCanvas;
  const Source: TRect);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    {$IFNDEF ORIGINAL} // 2002/7/26 DHGL 1.2
    SetStretchBltMode(FBigBitmap.FBitmaps[i].Canvas.Handle,
                      FCopyRectMode);
    {$ENDIF}
    FBigBitmap.FBitmaps[i].Canvas.CopyRect(Dest, Canvas, Source);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// Canvas �̍쐬
constructor TBigBitmapCanvas.Create;
begin
  FFont := TFont.Create;
  FBrush := TBrush.Create;
  FPen := TPen.Create;
  FCopyMode := cmSrcCopy;
  {$IFNDEF ORIGINAL} // 2002/7/26 �ǉ� DHGL 1.2
  FCopyRectMode := COLORONCOLOR;
  {$ENDIF}
end;

destructor TBigBitmapCanvas.Destroy;
begin
  FPen.Free;
  FBrush.Free;
  FFont.Free;

  {$IFNDEF ORIGINAL} // 2002/7/26 DHGL 1.2
  if FClipRgn <> 0 then DeleteObject(FClipRgn);
  {$ENDIF}
  inherited;
end;

// DrawFocusRect
procedure TBigBitmapCanvas.Draw(X, Y: Integer; Graphic: TGraphic);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.Draw(X, Y, Graphic);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

procedure TBigBitmapCanvas.DrawFocusRect(const Rect: TRect);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.DrawFocusRect(Rect);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

{$IFNDEF ORIGINAL} // 2002/7/25 DHGL 1.2
// TBigBitmap ���� TBigBitmap �ւ� CopyRect
procedure TBigBitmapCanvas.CopyRect(Dest: TRect; Bitmap: TBigBitmap;
  Source: TRect);
var
  DestRectForDraw: TRect;
  DestRGN, SavedClipRgn: HRGN;

  function SourceToDest(Pt: TPoint): TPoint;
  begin
    Result.x := (Pt.x - Source.Left) *
                (Dest.Right - Dest.Left) div
                (Source.Right - Source.Left) +
                Dest.Left;

    Result.y := (Pt.y - Source.Top) *
                (Dest.Bottom - Dest.Top) div
                (Source.Bottom - Source.Top) +
                Dest.Top;
  end;
begin
  // �r�b�g�}�b�v�S�̂� Draw �ŃR�s�[���邪�A�s�v��
  // �����̓N���b�s���O�ŃJ�b�g����
  if Source.Left = Source.Right then
    Inc(Source.Right);
  if Source.Top = Source.Bottom then
    Inc(Source.Bottom);

  // �N���b�s���O�����̏ꍇ�̕`����`���v�Z
  DestRectForDraw.TopLeft := SourceToDest(Point(0, 0));
  DestRectForDraw.BottomRight := SourceToDest(Point(Bitmap.Width,
                                                    Bitmap.Height));
  // �`���G���A�����W���]���l�������ĕ␳(��CopyRect �ɍ��킹��)
  with Dest do
  begin
    if Left > Right then begin Inc(Left); Inc(Right); end;
    if Top > Bottom then begin Inc(Top); Inc(Bottom); end;
    DestRgn := CreateRectRgn(Left, Top, Right, Bottom);
  end;

  if DestRgn = 0 then
    RaiseError('TBigBitmap.CopyRect: Cannot Create Rgn for Dest');
  try
    // �N���b�s���O���Z�b�g���� StretchDraw ����
    if FClipRgn <> 0 then
      if CombineRgn(DestRgn, FClipRgn, DestRgn, RGN_AND) = ERROR then
        RaiseError('TBigBitmap.CopyRect: Cannot Create Rgn for Bitmaps');

    SavedClipRgn := FClipRgn;
    FClipRgn := DestRgn;
    SetupClipRgn(True);
    try
      Bitmap.WorkAsCopyRect := True;
      FBigBitmap.WorkAsCopyRect := True;
      try
        StretchDraw(DestRectForDraw, Bitmap);
      finally
        FBigBitmap.WorkAsCopyRect := True;
        Bitmap.WorkAsCopyRect := False;
      end;
    finally
      FClipRgn := SavedClipRgn;
      SetupClipRgn(True);
    end;
  finally
    DeleteObject(DestRgn);
  end;
end;
{$ENDIF}

// �ȉ~��`��
procedure TBigBitmapCanvas.Ellipse(const Rect: TRect);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.Ellipse(Rect);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// �ȉ~��`��
procedure TBigBitmapCanvas.Ellipse(X1, Y1, X2, Y2: Integer);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.Ellipse(X1, Y1, X2, Y2);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// FillRect
procedure TBigBitmapCanvas.FillRect(const Rect: TRect);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.FillRect(Rect);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// FloodFill
procedure TBigBitmapCanvas.FloodFill(X, Y: Integer; Color: TColor;
  FillStyle: TFillStyle);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.FloodFill(X, Y, Color, FillStyle);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// FrameRect
procedure TBigBitmapCanvas.FrameRect(const Rect: TRect);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.FrameRect(Rect);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// ��������
function TBigBitmapCanvas.GetPixel(X, Y: Integer): TColor;
var
  SmallBitmapHeight: Integer;
begin
  Result := -1;
  if (X <0) or (Y < 0) or (X >= FBigBitmap.Width) or
     (Y >= FBigBitmap.Height) then Exit;

  SmallBitmapHeight := FBigBitmap.FBitmaps[0].Height;
  Result := FBigBitmap.FBitmaps[Y div SmallBitmapHeight].Canvas.Pixels[x, Y mod SmallBitmapHeight];
end;

procedure TBigBitmapCanvas.LineTo(X, Y: Integer);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.LineTo(X, Y);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// �y���ʒu�𓮂���
procedure TBigBitmapCanvas.MoveTo(X, Y: Integer);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.MoveTo(X, Y);
  end;
  ResetBitmaps;
end;

// ��`��`��
procedure TBigBitmapCanvas.Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// �׃W�G�Ȑ���`��
procedure TBigBitmapCanvas.PolyBezier(const Points: array of TPoint);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.PolyBezier(Points);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// �׃W�G�Ȑ���`��
procedure TBigBitmapCanvas.PolyBezierTo(const Points: array of TPoint);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.PolyBezierTo(Points);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// ���p�`��`��
procedure TBigBitmapCanvas.Polygon(const Points: array of TPoint);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.Polygon(Points);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// �܂����`��
procedure TBigBitmapCanvas.Polyline(const Points: array of TPoint);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.Polyline(Points);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// ��`��`��
procedure TBigBitmapCanvas.Rectangle(X1, Y1, X2, Y2: Integer);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.Rectangle(X1, Y1, X2, Y2);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// ��`��`��
procedure TBigBitmapCanvas.Rectangle(const Rect: TRect);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.Rectangle(Rect);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// �eTBitmap�̌��_�����Z�b�g����
procedure TBigBitmapCanvas.ResetBitmaps;
var
  i: Integer;
begin
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
    SetWindowOrgEx(FBigBitmap.FBitmaps[i].Canvas.Handle, 0, 0, Nil);
end;

// �p�ۋ�`��`��
procedure TBigBitmapCanvas.RoundRect(X1, Y1, X2, Y2, X3, Y3: Integer);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.RoundRect(X1, Y1, X2, Y2, X3, Y3);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

//�u���V�̍X�V
procedure TBigBitmapCanvas.SetBrush(const Value: TBrush);
begin
  FBrush.Assign(Value);
end;

{$IFNDEF ORIGINAL} // 2002/7/25 �ǉ� DHGL 1.2
// �N���b�s���O���[�W�����̐ݒ�
procedure TBigBitmapCanvas.SetClipRgn(const Value: HRGN);
begin
  if FClipRgn <> Value then
  begin
    if FClipRgn <> 0 then DeleteObject(FClipRgn);
    FClipRgn := Value;
  end;
  SetupClipRgn(True);
end;
{$ENDIF}

//�t�H���g�̍X�V
procedure TBigBitmapCanvas.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

// �y���̍X�V
procedure TBigBitmapCanvas.SetPen(const Value: TPen);
begin
  FPen.Assign(Value);
end;

procedure TBigBitmapCanvas.SetPixel(X, Y: Integer; Value: TColor);
var
  SmallBitmapHeight: Integer;
begin
  if (X <0) or (Y < 0) or (X >= FBigBitmap.Width) or
     (Y >= FBigBitmap.Height) then Exit;

  SmallBitmapHeight := FBigBitmap.FBitmaps[0].Height;
  FBigBitmap.FBitmaps[Y div SmallBitmapHeight].Canvas.Pixels[x, Y mod SmallBitmapHeight]
    := Value;
  FBigBitmap.Modified := True;
end;

// �eTBitmap��Canvas�𐮂���
procedure TBigBitmapCanvas.SetupBitmaps;
var
  i: Integer;
begin
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    // Canvas�̑������X�V����
    FBigBitmap.FBitmaps[i].Canvas.Font := Font;
    FBigBitmap.FBitmaps[i].Canvas.Brush := Brush;
    FBigBitmap.FBitmaps[i].Canvas.Pen := Pen;
    FBigBitmap.FBitmaps[i].Canvas.CopyMode := CopyMode;
    FBigBitmap.FBitmaps[i].Canvas.TextFlags := TextFlags;

    //���W�n��TBitmap�̈ʒu�ɂ��킹�ĕ␳����
    SetWindowOrgEx(FBigBitmap.FBitmaps[i].Canvas.Handle,
      0, i * FBigBitmap.FBitmaps[0].Height, Nil);
  end;
  {$IFNDEF ORIGINAL} // 2002/7/25 DHGL 1.2
  // �r�b�g�}�b�v�̃f�o�C�X�R���e�L�X�g���󂳂�Ă���
  // ���ꂪ����̂� �N���b�s���O�̍Đݒ肪�K�v
  if FClipRgn <> 0 then SetupClipRgn(False);
  {$ENDIF}
end;

{$IFNDEF ORIGINAL} // 2002/7/25 DHGL 1.2
// �e�r�b�g�}�b�v�ɃN���b�v���[�W������ݒ�
procedure TBigBitmapCanvas.SetupClipRgn(Force: Boolean);
var
  i: Integer;
  Rgn: HRGN;
  Ret: Integer;
begin
  // �����͎��ԓI�ɃN���`�J���Ȃ̂Œ��Ӑ[���R�[�f�B���O
  if FClipRgn <> 0 then
  begin
    if Length(FBigBitmap.FBitmaps) = 0 then Exit;

    if Not Force then
    begin
      // �r�b�g�}�b�v�̃f�o�C�X�R���e�L�X�g���j������
      // �N���b�s���O���[�W�������j������Ă��Ȃ����`�F�b�N����B
      // �j������Ă��Ȃ���΍Đݒ�͂��Ȃ�(�������I)�B
      // �Đݒ�͑傫�Ȏ��Ԃ�������̂Ŏ��Ԃ��啝�ɖ��ʂɂȂ�B
      Rgn := CreateRectRgn(0, 0, 1, 1);
      try
      if Rgn = 0 then
        RaiseError('TBigBitmapCanvas.SetupClipRgn: ' +
                   'Cannot Create Rgn for Test');
      ret := GetClipRgn(FBigBitmap.FBitmaps[0].Canvas.Handle, Rgn);
      if Ret = 1 then Exit
      else if Ret = Error then
        RaiseError('TBigBitmapCanvas.SetupClipRgn: ' +
                   'Failed to retrieve Clipping Region');
      finally
        DeleteObject(Rgn);
      end;
    end;

    // ���[�W�����̃R�s�[�����
    Rgn := CreateRectRgn(0, 0, 1, 1);
    if Rgn = 0 then
      RaiseError('TBigBitmapCanvas.SetupClipRgn: ' +
                 'Cannot Create Rgn for Clipping');
    if CombineRgn(Rgn, FClipRgn, 0, RGN_COPY) = ERROR then
      RaiseError('TBigBitmapCanvas.SetupClipRgn: ' +
                 'Cannot Copy Rgn for Clipping');
    try
      for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
      begin
        // Canvas�̃N���b�v���[�W������ύX����
        SelectClipRgn(FBigBitmap.FBitmaps[i].Canvas.Handle, Rgn);

        //�N���b�v���[�W�����̓f�o�C�X���W�Ȃ̂ŁA
        //TBitmap�̈ʒu�ɂ��킹�ĕ␳����
        OffsetRgn(Rgn, 0, -FBigBitmap.FBitmaps[0].Height);
      end;
    finally
      DeleteObject(Rgn); // �R�s�[�Ȃ̂Ŕj��
    end;
  end
  else
    // Canvas�̃N���b�v���[�W�������폜����
    for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
      SelectClipRgn(FBigBitmap.FBitmaps[i].Canvas.Handle, 0);
end;
{$ENDIF}

// �r�b�g�}�b�v�փO���t�B�b�N�`��
procedure TBigBitmapCanvas.StretchDraw(const Rect: TRect;
  Graphic: TGraphic);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    {$IFNDEF ORIGINAL} // 2002/7/26 DHGL 1.2
    if FBigBitmap.WorkAsCopyRect then
      SetStretchBltMode(FBigBitmap.FBitmaps[i].Canvas.Handle, FCopyRectMode);
    {$ENDIF}
    FBigBitmap.FBitmaps[i].Canvas.StretchDraw(Rect, Graphic);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// �e�L�X�g�̑傫��
function TBigBitmapCanvas.TextExtent(const Text: string): TSize;
begin
  if Length(FBigBitmap.FBitmaps) = 0 then
    raise EInvalidOperation.Create(
      'TBigBitmapCanvas.TExtExtent: No Bitmap');
  SetupBitmaps;
    Result := FBigBitmap.FBitmaps[0].Canvas.TextExtent(Text);
  ResetBitmaps;
end;

// �e�L�X�g�̍���
function TBigBitmapCanvas.TextHeight(const Text: string): Integer;
begin
  if Length(FBigBitmap.FBitmaps) = 0 then
    raise EInvalidOperation.Create(
      'TBigBitmapCanvas.TExtExtent: No Bitmap');
  SetupBitmaps;
    Result := FBigBitmap.FBitmaps[0].Canvas.TextHeight(Text);
  ResetBitmaps;
end;

// �e�L�X�g�̕�
procedure TBigBitmapCanvas.TextOut(X, Y: Integer; const Text: string);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.TextOut(X, Y, Text);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// TextRect
procedure TBigBitmapCanvas.TextRect(Rect: TRect; X, Y: Integer;
  const Text: string);
var
  i: Integer;
begin
  SetupBitmaps;
  for i := 0 to Length(FBigBitmap.FBitmaps)-1 do
  begin
    FBigBitmap.FBitmaps[i].Canvas.TextRect(Rect, X, Y, Text);
  end;
  ResetBitmaps;
  FBigBitmap.Modified := True;
end;

// �e�L�X�g�̕�
function TBigBitmapCanvas.TextWidth(const Text: string): Integer;
begin
  if Length(FBigBitmap.FBitmaps) = 0 then
    raise EInvalidOperation.Create(
      'TBigBitmapCanvas.TExtExtent: No Bitmap');
  SetupBitmaps;
    Result := FBigBitmap.FBitmaps[0].Canvas.TextWidth(Text);
  ResetBitmaps;
end;

{$IFNDEF ORIGINAL} // 2002/7/28 DHGL 1.2
// TBigBitmap ���� TCanvas �ւ� CopyRect
procedure CopyRectBigBitmap(Dest: TRect; ACanvas: TCanvas;
                            Source: TRect; Bitmap: TBigBitmap);
var
  DestRectForDraw: TRect;
  DestRgn: HRGN;

  function SourceToDest(Pt: TPoint): TPoint;
  begin
    Result.x := (Pt.x - Source.Left) *
                (Dest.Right - Dest.Left) div
                (Source.Right - Source.Left) +
                Dest.Left;

    Result.y := (Pt.y - Source.Top) *
                (Dest.Bottom - Dest.Top) div
                (Source.Bottom - Source.Top) +
                Dest.Top;
  end;
begin
  // �r�b�g�}�b�v�S�̂� Draw �ŃR�s�[���邪�A�s�v��
  // �����̓N���b�s���O�ŃJ�b�g����
  if Source.Left = Source.Right then
    Inc(Source.Right);
  if Source.Top = Source.Bottom then
    Inc(Source.Bottom);

  // �N���b�s���O�����̏ꍇ�̕`����`���v�Z
  DestRectForDraw.TopLeft := SourceToDest(Point(0, 0));
  DestRectForDraw.BottomRight := SourceToDest(Point(Bitmap.Width,
                                                    Bitmap.Height));
  // �`���G���A�����W���]���l�������ĕ␳(��CopyRect �ɍ��킹��)
  with Dest do
  begin
    if Left > Right then begin Inc(Left); Inc(Right); end;
    if Top > Bottom then begin Inc(Top); Inc(Bottom); end;
    DestRgn := CreateRectRgn(Left, Top, Right, Bottom);
  end;

  if DestRgn = 0 then
    RaiseError('CopyRectBigBitmap: Cannot Create Rgn for Dest');

  try
    // �N���b�s���O���Z�b�g���� Draw ����
    SaveDC(ACanvas.Handle);
    ExtSelectClipRgn(ACAnvas.Handle, DestRgn, RGN_AND);
    try
      Bitmap.WorkAsCopyRect := True;
      try
        ACanvas.StretchDraw(DestRectForDraw, Bitmap);
      finally
        Bitmap.WorkAsCopyRect := False;
      end;
    finally
      RestoreDC(ACanvas.Handle, -1);
    end;
  finally
    DeleteObject(DestRgn);
  end;
end;
{$ENDIF}



{
initialization
  TPicture.RegisterClipboardFormat(CF_DIB, TBigBitmap);
  TPicture.RegisterClipboardFormat(CF_DIB, TBigBitmap);

finalization
  TPicture.UnregisterGraphicClass(TBigBitmap);
}
end.


