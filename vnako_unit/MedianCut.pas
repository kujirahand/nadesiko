{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
//////////
//
// �{���j�b�g�ɂ̓��f�B�A���J�b�g�Ō��F��
// �s���e�탋�[�`�����܂܂�Ă��܂��B

unit MedianCut;

interface

uses Windows, SysUtils, Graphics, BigBitmap, BitmapUtils;

// ���F����(�ӂ̒����łŕ���)
function ReduceColorsByMedianCut(Bitmap: TBitmap; Depth: Integer)
  : TBitmap; overload;

// ���F����(���U�ŕ���)
function ReduceColorsByMedianCutV(Bitmap: TBitmap; Depth: Integer)
  : TBitmap; overload;

// ���F����(�ӂ̒����ŕ����{�덷�g�U)
function ReduceColorsByMedianCutED(Bitmap: TBitmap;
                                   Depth: Integer): TBitmap; overload;

// ���F����(���U�ŕ����{�덷�g�U)
function ReduceColorsByMedianCutVED(Bitmap: TBitmap;
                                    Depth: Integer): TBitmap; overload;

// TBigBitmap��

// ���F����(�ӂ̒����łŕ���)
function ReduceColorsByMedianCut(Bitmap: TBigBitmap; Depth: Integer)
  : TBigBitmap; overload;

// ���F����(���U�ŕ���)
function ReduceColorsByMedianCutV(Bitmap: TBigBitmap; Depth: Integer)
  : TBigBitmap; overload;

// ���F����(�ӂ̒����ŕ����{�덷�g�U)
function ReduceColorsByMedianCutED(Bitmap: TBigBitmap;
                                   Depth: Integer): TBigBitmap; overload;

// ���F����(���U�ŕ����{�덷�g�U)
function ReduceColorsByMedianCutVED(Bitmap: TBigBitmap;
                                    Depth: Integer): TBigBitmap; overload;

type
  // ���f�B�A���J�b�g�� Cube
  TMedianCutCube = record
    ColorIndex:  WORD;     // ���̃m�[�h�̃J���[�C���f�b�N�X
    Index:       Integer;  // ���̃m�[�h�̔z��C���f�b�N�X
    NumPixels:   Integer;  // Cube���̃s�N�Z�����̑��v
    Red:         DWORD;    // Cube���̐�(�ώZ�܂��͕���)
    Green:       DWORD;    // Cube���̗�(�ώZ�܂��͕���)
    Blue:        DWORD;    // Cube���̐�(�ώZ�܂��͕���)
  end;

  // �q�X�g�O�����̐錾�B
  // Cube �Ƃ� RGB�����̂�ԕ�����64����, �Ε�����64�����A������32����
  // �����ꍇ�̃Z���̂��ƂŁACube �ɂ�Cube�Ɋ܂܂��F����F�̐ώZ�Ȃ�
  // ������B 131072�� �� 3MB �̃��������߂�B
  // Cube �̔z����q�X�g�O�����ƌĂ�
  const
    NumRed=64; NumGreen=64; NumBlue = 32;
    NumTotalCubes = NumRed * NumGreen * NumBlue;

  type
  TRGBHistogram = array[0..NumRed-1, 0..NumGreen-1, 0..NumBlue-1]
                  of TMedianCutCube;
  PRGBHistogram = ^TRGBHistogram;
  THistogram    = array[0..NumTotalCubes-1]of TMedianCutCube;
  PHistogram    = ^THistogram;

  // RGBQuad �̔z��
  TRGBQuadArray    = array[0..255] of TRGBQuad;
  PRGBQuadArray    = ^TRGBQuadArray;

  // ���f�B�A���J�b�g �N���X
  TMedianCut = class
  private
    FHistogram: PRGBHistogram;
    FColorConvertTable: array[0..NumTotalCubes-1] of Byte;
    FNumColors: Integer;   // ���o�����F��
    FColors: TRGBQuadArray;

    // �q�X�g�O�����𕪊�����(�ӂ̒����ŕ���)
    procedure CutCubes(Low,        // Color Cube �Q�̍ŏ��� Cube ���w��
                                   // �C���f�b�N�X
                       High,       // Color Cube �Q�̍Ō�̎��� Cube ���w��
                                   //�C���f�b�N�X
                       Depth,      // �����̐[��
                       MaxDepth: LongInt;     // �����̐[���̍ő�l
                       var Cubes: THistogram; // Color Cube �z��
                       var Colors: TRGBQuadArray; // ���F�J���[�o�͗p��
                                                  // �J���[�e�[�u��
                       var NumColors: LongInt);   // �o�͂��ꂽ���F�J���[�F�̐�

    // �q�X�g�O�����𕪊�����
    procedure CutCubesByVariance(
                       Low,        // Color Cube �Q�̍ŏ��� Cube ���w��
                                   // �C���f�b�N�X
                       High,       // Color Cube �Q�̍Ō�̎��� Cube ���w��
                                   //�C���f�b�N�X
                       Depth,                 // �����̐[��
                       MaxDepth: LongInt;     // �����̐[���̍ő�l
                       var Cubes: THistogram; // Color Cube �z��
                       var Colors: TRGBQuadArray; // ���F�J���[�o�͗p��
                                                  // �J���[�e�[�u��
                       var NumColors: LongInt);   // �o�͂��ꂽ���F�J���[�F�̐�

  public
    constructor Create;
    destructor  Destroy; override;

    //�q�X�g�O�����ɐF��������
    procedure AddColor(AColor: TTriple);


    // ���F����B�q�X�g�O�����̕����͕ӂ̒�����p����B
    // ShrinkCubes �̓q�X�g�O�����̒��̃s�N�Z���������Ȃ�Cube��
    // �������Ȃ����Ƃ��w�肷��B�������Ȃ��ꍇ�A�������ꂽ�q�X�g�O������
    // �g���� �F -> �J���[�e�[�u���C���f�b�N�X����ꍇ�A�q�X�g�O������
    // �܂܂�Ȃ��F�͕ϊ��ł��Ȃ��B
    procedure ReduceColors(MaxDepth: Integer; ShrinkCubes: Boolean);
    // ���F����B�q�X�g�O�����̕����͕��U��p����B
    // ShrinkCubes �̓q�X�g�O�����̒��̃s�N�Z���������Ȃ�Cube��
    // �������Ȃ����Ƃ��w�肷��B�������Ȃ��ꍇ�A�������ꂽ�q�X�g�O������
    // �g���� �F -> �J���[�e�[�u���C���f�b�N�X����ꍇ�A�q�X�g�O������
    // �܂܂�Ȃ��F�͕ϊ��ł��Ȃ��B
    procedure ReduceColorsByVariance(MaxDepth: Integer; ShrinkCubes: Boolean);

    // �������ꂽ�q�X�g�O�������p���b�g�����
    function MakePalette: HPALETTE;

    // �F -> �J���[�e�[�u���C���f�b�N�X�ϊ����s���B
    // ��� ShrinkCubes �̐����ɒ���
    function GetColorIndex(Color: TTriple): Integer;
  end;

implementation

uses ErrDef;

type
  // �J���[ -> �J���[�C���f�b�N�X�ϊ��e�[�u���p�̔z��^
  T3DByteArray = array[0..63, 0..63, 0..31] of Byte;
  P3DByteArray = ^T3DByteArray;


// ���F����(�ӂ̒����łŕ���)
function ReduceColorsByMedianCut(Bitmap: TBitmap; Depth: Integer)
  : TBitmap; overload;
var
  NewBitmap: TBitmap;       // �V�������r�b�g�}�b�v
  MedianCut: TMedianCut;    // ���f�B�A���J�b�g
  x, y: Integer;            // ���W
  SourceScan: PTripleArray; // �V���r�b�g�}�b�v�� Scanline
  DestScan: PByteArray;
begin
  Assert(Depth >= 0);
  Assert(Bitmap.PixelFormat = pf24bit);

  MedianCut := TMedianCut.Create;  // MedianCut ���쐬
  try
    // �q�X�g�O���� �̍\�z
    for y := 0 to Bitmap.Height-1 do
    begin
      SourceScan := Bitmap.Scanline[y];
      for x := 0 to Bitmap.Width-1 do
        MedianCut.AddColor(SourceScan[x]);
    end;

    // ���F�B�덷�g�U�����������̂ŁA�����̗ǂ� ShrinCubes = True ���g��
    MedianCut.ReduceColors(Depth, True);    // ���F

    //�V���� 8bpp �̃r�b�g�}�b�v�̍쐬
    NewBitmap := TBitmap.Create;
    try
      NewBitmap.PixelFormat := pf8bit;
      NewBitmap.Width := Bitmap.Width;
      NewBitmap.Height := Bitmap.Height;
      NewBitmap.Palette := MedianCut.MakePalette; // ���F���ꂽ�p���b�g

      // �F�ϊ��̃��[�v
      for y := 0 to Bitmap.Height-1 do
      begin
        SourceScan := Bitmap.Scanline[y];
        DestScan := NewBitmap.Scanline[y];
        for x := 0 to Bitmap.Width-1 do
        begin
          // MedianCut �� GetColorIndex �� 24bit Color �� �p���b�g��
          // �G���g���ԍ��ɕϊ�
          DestScan[x] := MedianCut.GetColorIndex(SourceScan[x]);
        end;
      end;
      Result := NewBitmap;
    except
      NewBitmap.Free;
      raise;
    end;
  finally
    MedianCut.Free;
  end;
end;

// ���F����(���U�ŕ���)
function ReduceColorsByMedianCutV(Bitmap: TBitmap; Depth: Integer)
  : TBitmap; overload;
var
  NewBitmap: TBitmap;       // �V�������r�b�g�}�b�v
  MedianCut: TMedianCut;    // ���f�B�A���J�b�g
  x, y: Integer;            // ���W
  SourceScan: PTripleArray; // �V���r�b�g�}�b�v�� Scanline
  DestScan: PByteArray;
begin
  Assert(Depth >= 0);
  Assert(Bitmap.PixelFormat = pf24bit);

  MedianCut := TMedianCut.Create;  // MedianCut ���쐬
  try
    // �q�X�g�O���� �̍\�z
    for y := 0 to Bitmap.Height-1 do
    begin
      SourceScan := Bitmap.Scanline[y];
      for x := 0 to Bitmap.Width-1 do
        MedianCut.AddColor(SourceScan[x]);
    end;

    // ���U�Ń��f�B�A���J�b�g����B
    // �덷�g�U���Ȃ��̂Ō����̗ǂ� ShrinkCubes=True ���g��
    MedianCut.ReduceColorsByVariance(Depth, True);    // 256�F�ȉ��Ɍ��F

    //�V����8bpp�̃r�b�g�}�b�v�̍쐬
    NewBitmap := TBitmap.Create;
    try
      NewBitmap.PixelFormat := pf8bit;
      NewBitmap.Width := Bitmap.Width;
      NewBitmap.Height := Bitmap.Height;
      NewBitmap.Palette := MedianCut.MakePalette; // ���F���ꂽ�p���b�g

      // �F�ϊ��̃��[�v
      for y := 0 to Bitmap.Height-1 do
      begin
        SourceScan := Bitmap.Scanline[y];
        DestScan := NewBitmap.Scanline[y];
        for x := 0 to Bitmap.Width-1 do
        begin
          // MedianCut �� GetColorIndex �� 24bit Color �� �p���b�g��
          // �G���g���ԍ��ɕϊ�
          DestScan[x] := MedianCut.GetColorIndex(SourceScan[x]);
        end;
      end;
      Result := NewBitmap;
    except
      NewBitmap.Free;
      raise;
    end;
  finally
    MedianCut.Free;
  end;
end;

type
  TMedianCutQuantizeColor = class(TQuantizeColor)
  private
    FMediancut: TMedianCut;
    ColorTable: array[0..255] of TPaletteEntry;
  public
    constructor Create(AMedianCut: TMedianCut);
    function GetQuantizedColor(Color: TTriple): TTriple; override;
  end;

{ TMedianCutQuantizeColor }

constructor TMedianCutQuantizeColor.Create(AMedianCut: TMedianCut);
var
  Palette: HPALETTE;
begin
  FMedianCut := AMedianCut;
  Palette := AMedianCut.MakePalette;
  try
    GetPaletteEntries(Palette, 0, 256, ColorTable);
  finally
    DeleteObject(Palette);
  end;
end;

function TMedianCutQuantizeColor.GetQuantizedColor(
  Color: TTriple): TTriple;
var
  Index: Integer;
  PalEntry: TPaletteEntry;
begin
  Index := FMedianCut.GetColorIndex(Color);
  PalEntry := ColorTable[Index];
  Result.r := PalEntry.peRed;
  Result.g := PalEntry.peGreen;
  Result.b := PalEntry.peBlue;
end;

// ���F����(�ӂ̒����ŕ����{�덷�g�U)
function ReduceColorsByMedianCutED(Bitmap: TBitmap;
                                   Depth: Integer): TBitmap;
var
  NewBitmap, NewBitmap2: TBitmap; // �V�������r�b�g�}�b�v
  MedianCut: TMedianCut;          // ���f�B�A���J�b�g
  x, y: Integer;                  // ���W
  SourceScan: PTripleArray;       // �V���r�b�g�}�b�v�� Scanline
  DestScan: PByteArray;
  QuantizeColor: TMedianCutQuantizeColor; // �F�ʎq���N���X
begin
  Assert(Depth >= 0);
  Assert(Bitmap.PixelFormat = pf24bit);

  MedianCut := TMedianCut.Create;  // MedianCut ���쐬
  try
    // MedianCut �̍\�z
    for y := 0 to Bitmap.Height-1 do
    begin
      SourceScan := Bitmap.Scanline[y];
      for x := 0 to Bitmap.Width-1 do
        MedianCut.AddColor(SourceScan[x]);
    end;

    // �덷�g�U�ł͊g�U�����ł��낢��ȐF��������̂�
    // �S�Ă� Cube ���������Ȃ��ƐF�̃C���f�b�N�X�ւ̕ϊ����ł��Ȃ��Ȃ�
    MedianCut.ReduceColors(Depth, False);    // 256�F�ȉ��Ɍ��F

    // �덷�g�U����
    QuantizeColor := TMedianCutQuantizeColor.Create(MedianCut);
    try
      NewBitmap := ErrorDefusion(Bitmap, QuantizeColor);
    finally
      QuantizeColor.Free;
    end;

    try
      //�V����8bpp�̃r�b�g�}�b�v�̍쐬
      NewBitmap2 := TBitmap.Create;
      try
        NewBitmap2.PixelFormat := pf8bit;
        NewBitmap2.Width := Bitmap.Width;
        NewBitmap2.Height := Bitmap.Height;
        NewBitmap2.Palette := MedianCut.MakePalette; // ���F���ꂽ�p���b�g

        // �F�ϊ��̃��[�v
        for y := 0 to Bitmap.Height-1 do
        begin
          SourceScan := NewBitmap.Scanline[y];
          DestScan := NewBitmap2.Scanline[y];
          for x := 0 to Bitmap.Width-1 do
            // GetColorIndex �� 24bit Color �� �p���b�g��
            // �G���g���ԍ��ɕϊ�
            DestScan[x] := MedianCut.GetColorIndex(SourceScan[x]);
        end;
        Result := NewBitmap2;
      except
        NewBitmap2.Free;
        raise;
      end;
    finally
      NewBitmap.Free;
    end;
  finally
    MedianCut.Free;
  end;
end;

// ���F����(���U�ŕ����{�덷�g�U)
function ReduceColorsByMedianCutVED(Bitmap: TBitmap;
                                    Depth: Integer): TBitmap;
var
  NewBitmap, NewBitmap2: TBitmap; // �V�������r�b�g�}�b�v
  MedianCut: TMedianCut;          // ���f�B�A���J�b�g
  x, y: Integer;                  // ���W
  SourceScan: PTripleArray;       // �V���r�b�g�}�b�v�� Scanline
  DestScan: PByteArray;
  QuantizeColor: TMedianCutQuantizeColor; // �F�ʎq���N���X
begin
  Assert(Depth >= 0);
  Assert(Bitmap.PixelFormat = pf24bit);

  MedianCut := TMedianCut.Create;  // MedianCut ���쐬
  try
    // MedianCut �̍\�z
    for y := 0 to Bitmap.Height-1 do
    begin
      SourceScan := Bitmap.Scanline[y];
      for x := 0 to Bitmap.Width-1 do
        MedianCut.AddColor(SourceScan[x]);
    end;
    // �덷�g�U�ł͊g�U�����ł��낢��ȐF��������̂�
    // �S�Ă� Cube ���������Ȃ��ƐF�̃C���f�b�N�X�ւ̕ϊ����ł��Ȃ��Ȃ�
    MedianCut.ReduceColorsByVariance(Depth, False);    // 256�F�ȉ��Ɍ��F

    // �덷�g�U����
    // �덷�g�U����
    QuantizeColor := TMedianCutQuantizeColor.Create(MedianCut);
    try
      NewBitmap := ErrorDefusion(Bitmap, QuantizeColor);
    finally
      QuantizeColor.Free;
    end;

    try
      //�V����8bpp�̃r�b�g�}�b�v�̍쐬
      NewBitmap2 := TBitmap.Create;
      try
        NewBitmap2.PixelFormat := pf8bit;
        NewBitmap2.Width := Bitmap.Width;
        NewBitmap2.Height := Bitmap.Height;
        NewBitmap2.Palette := MedianCut.MakePalette; // ���F���ꂽ�p���b�g

        // �F�ϊ��̃��[�v
        for y := 0 to Bitmap.Height-1 do
        begin
          SourceScan := NewBitmap.Scanline[y];
          DestScan := NewBitmap2.Scanline[y];
          for x := 0 to Bitmap.Width-1 do
            // GetColorIndex �� 24bit Color �� �p���b�g��
            // �G���g���ԍ��ɕϊ�
            DestScan[x] := MedianCut.GetColorIndex(SourceScan[x]);
        end;
        Result := NewBitmap2;
      except
        NewBitmap2.Free;
        raise;
      end;
    finally
      NewBitmap.Free;
    end;
  finally
    MedianCut.Free;
  end;
end;

// TBigBitmap��

// ���F����(�ӂ̒����łŕ���)
function ReduceColorsByMedianCut(Bitmap: TBigBitmap; Depth: Integer)
  : TBigBitmap; overload;
var
  NewBitmap: TBigBitmap;    // �V�������r�b�g�}�b�v
  MedianCut: TMedianCut;    // ���f�B�A���J�b�g
  x, y: Integer;            // ���W
  SourceScan: PTripleArray; // �V���r�b�g�}�b�v�� Scanline
  DestScan: PByteArray;
begin
  Assert(Depth >= 0);
  Assert(Bitmap.PixelFormat = bbpf24bit);

  MedianCut := TMedianCut.Create;  // MedianCut ���쐬
  try
    // �q�X�g�O���� �̍\�z
    for y := 0 to Bitmap.Height-1 do
    begin
      SourceScan := Bitmap.Scanline[y];
      for x := 0 to Bitmap.Width-1 do
        MedianCut.AddColor(SourceScan[x]);
    end;

    // �ӂ̒������g���ăq�X�g�O�����𕪊�
    MedianCut.ReduceColors(Depth, True);    // 256�F�ȉ��Ɍ��F

    //�V�����r�b�g�}�b�v�̍쐬
    NewBitmap := TBigBitmap.Create;
    try
      NewBitmap.PixelFormat := bbpf8bit;
      NewBitmap.Width := Bitmap.Width;
      NewBitmap.Height := Bitmap.Height;
      NewBitmap.Palette := MedianCut.MakePalette; // ���F���ꂽ�p���b�g

      // �F�ϊ��̃��[�v
      for y := 0 to Bitmap.Height-1 do
      begin
        SourceScan := Bitmap.Scanline[y];
        DestScan := NewBitmap.Scanline[y];
        for x := 0 to Bitmap.Width-1 do
          // MedianCut �� GetColorIndex �� 24bit Color �� �p���b�g��
          // �G���g���ԍ��ɕϊ�
          DestScan[x] := MedianCut.GetColorIndex(SourceScan[x]);
      end;
      Result := NewBitmap;
    except
      NewBitmap.Free;
      raise;
    end;
  finally
    MedianCut.Free;
  end;
end;


// ���F����(���U�ŕ���)
function ReduceColorsByMedianCutV(Bitmap: TBigBitmap; Depth: Integer)
  : TBigBitmap; overload;
var
  NewBitmap: TBigBitmap;    // �V�������r�b�g�}�b�v
  MedianCut: TMedianCut;    // ���f�B�A���J�b�g
  x, y: Integer;            // ���W
  SourceScan: PTripleArray; // �V���r�b�g�}�b�v�� Scanline
  DestScan: PByteArray;
begin
  Assert(Depth >= 0);
  Assert(Bitmap.PixelFormat = bbpf24bit);

  MedianCut := TMedianCut.Create;  // MedianCut ���쐬
  try
    // �q�X�g�O���� �̍\�z
    for y := 0 to Bitmap.Height-1 do
    begin
      SourceScan := Bitmap.Scanline[y];
      for x := 0 to Bitmap.Width-1 do
      begin
        MedianCut.AddColor(SourceScan[x]);
      end;
    end;

    // ���U���g���ăq�X�g�O�����𕪊�
    MedianCut.ReduceColorsByVariance(Depth, True);    // 256�F�ȉ��Ɍ��F

    //�V���� 8bpp �̃r�b�g�}�b�v�̍쐬
    NewBitmap := TBigBitmap.Create;
    try
      NewBitmap.PixelFormat := bbpf8bit;
      NewBitmap.Width := Bitmap.Width;
      NewBitmap.Height := Bitmap.Height;
      NewBitmap.Palette := MedianCut.MakePalette; // ���F���ꂽ�p���b�g

      // �F�ϊ��̃��[�v
      for y := 0 to Bitmap.Height-1 do
      begin
        SourceScan := Bitmap.Scanline[y];
        DestScan := NewBitmap.Scanline[y];
        for x := 0 to Bitmap.Width-1 do
          // MedianCut �� GetColorIndex �� 24bit Color �� �p���b�g��
          // �G���g���ԍ��ɕϊ�
          DestScan[x] := MedianCut.GetColorIndex(SourceScan[x]);
      end;
      Result := NewBitmap;
    except
      NewBitmap.Free;
      raise;
    end;
  finally
    MedianCut.Free;
  end;
end;

// ���F����(�ӂ̒����ŕ����{�덷�g�U)
function ReduceColorsByMedianCutED(Bitmap: TBigBitmap;
                                   Depth: Integer): TBigBitmap; overload;
var
  NewBitmap, NewBitmap2: TBigBitmap; // �V�������r�b�g�}�b�v
  MedianCut: TMedianCut;             // ���f�B�A���J�b�g
  x, y: Integer;                     // ���W
  SourceScan: PTripleArray;          // �V���r�b�g�}�b�v�� Scanline
  DestScan: PByteArray;
  QuantizeColor: TMedianCutQuantizeColor; // �F�ʎq���N���X
begin
  Assert(Depth >= 0);
  Assert(Bitmap.PixelFormat = bbpf24bit);

  MedianCut := TMedianCut.Create;  // MedianCut ���쐬
  try
    // MedianCut �̍\�z
    for y := 0 to Bitmap.Height-1 do
    begin
      SourceScan := Bitmap.Scanline[y];
      for x := 0 to Bitmap.Width-1 do
        MedianCut.AddColor(SourceScan[x]);
    end;
    // �ӂ̒������g���ăq�X�g�O�����𕪊�
    MedianCut.ReduceColors(Depth, False);    // 256�F�ȉ��Ɍ��F

    // �덷�g�U����
    QuantizeColor := TMedianCutQuantizeColor.Create(MedianCut);
    try
      NewBitmap := ErrorDefusion(Bitmap, QuantizeColor);
    finally
      QuantizeColor.Free;
    end;

    // 8bpp �̐V�r�b�g�}�b�v���쐬
    try
      NewBitmap2 := TBigBitmap.Create;
      try
        NewBitmap2.PixelFormat := bbpf8bit;
        NewBitmap2.Width := Bitmap.Width;
        NewBitmap2.Height := Bitmap.Height;
        NewBitmap2.Palette := MedianCut.MakePalette; // ���F���ꂽ�p���b�g

        // �F�ϊ��̃��[�v
        for y := 0 to Bitmap.Height-1 do
        begin
          SourceScan := NewBitmap.Scanline[y];
          DestScan := NewBitmap2.Scanline[y];
          for x := 0 to Bitmap.Width-1 do
            // GetColorIndex �� 24bit Color �� �p���b�g��
            // �G���g���ԍ��ɕϊ�
            DestScan[x] := MedianCut.GetColorIndex(SourceScan[x]);
        end;
        Result := NewBitmap2;
      except
        NewBitmap.Free;
        raise;
      end;
    finally
      NewBitmap.Free;
    end;
  finally
    MedianCut.Free;
  end;
end;

// ���F����(���U�ŕ����{�덷�g�U)
function ReduceColorsByMedianCutVED(Bitmap: TBigBitmap;
                                    Depth: Integer): TBigBitmap; overload;
var
  NewBitmap, NewBitmap2: TBigBitmap; // �V�������r�b�g�}�b�v
  MedianCut: TMedianCut;             // ���f�B�A���J�b�g
  x, y: Integer;                     // ���W
  SourceScan: PTripleArray;          // �V���r�b�g�}�b�v�� Scanline
  DestScan: PByteArray;
  QuantizeColor: TMedianCutQuantizeColor; // �F�ʎq���N���X
begin
  Assert(Depth >= 0);
  Assert(Bitmap.PixelFormat = bbpf24bit);

  MedianCut := TMedianCut.Create;  // MedianCut ���쐬
  try
    // MedianCut �̍\�z(�q�X�g�O�����̍쐬)
    for y := 0 to Bitmap.Height-1 do
    begin
      SourceScan := Bitmap.Scanline[y];
      for x := 0 to Bitmap.Width-1 do
        MedianCut.AddColor(SourceScan[x]);
    end;
    //���U���g���Č��F
    MedianCut.ReduceColorsByVariance(Depth, False); // 256�F�ȉ��Ɍ��F

    // �덷�g�U����
    QuantizeColor := TMedianCutQuantizeColor.Create(MedianCut);
    try
      NewBitmap := ErrorDefusion(Bitmap, QuantizeColor);
    finally
      QuantizeColor.Free;
    end;

    try
      // 8bpp �̐V�����r�b�g�}�b�v���쐬
      NewBitmap2 := TBigBitmap.Create;
      try
        NewBitmap2.PixelFormat := bbpf8bit;
        NewBitmap2.Width := Bitmap.Width;
        NewBitmap2.Height := Bitmap.Height;
        NewBitmap2.Palette := MedianCut.MakePalette; // ���F���ꂽ�p���b�g

        // �F�ϊ��̃��[�v
        for y := 0 to Bitmap.Height-1 do
        begin
          SourceScan := NewBitmap.Scanline[y];
          DestScan := NewBitmap2.Scanline[y];
          for x := 0 to Bitmap.Width-1 do
            // GetColorIndex �� 24bit Color �� �p���b�g��
            // �G���g���ԍ��ɕϊ�
            DestScan[x] := MedianCut.GetColorIndex(SourceScan[x]);
        end;
        Result := NewBitmap2;
      except
        NewBitmap2.Free;
        raise;
      end;
    finally
      NewBitmap.Free;
    end;
  finally
    MedianCut.Free;
  end;
end;



{ TMedianCut }

// �q�X�g�O�������\�z����
procedure TMedianCut.AddColor(AColor: TTriple);
var
  ri, gi, bi: Integer;
begin
  ri := AColor.r shr 2; gi := AColor.g shr 2; bi := AColor.b shr 3;
  Inc(FHistogram[ri, gi, bi].NumPixels);

  // (ri, gi, bi) �̎�����F�ɑ΂��鍷�������𑫂�����
  // �������邱�Ƃ� 32bit �ŐF���[���ɐώZ�ł���B
  // 4G div 7 = 585M Pixel�܂ő��v
  Inc(FHistogram[ri, gi, bi].Red,   AColor.r and $03);
  Inc(FHistogram[ri, gi, bi].Green, AColor.g and $03);
  Inc(FHistogram[ri, gi, bi].Blue,  AColor.b and $07);
end;

constructor TMedianCut.Create;
var
  i: Integer;
begin
  FHistogram := AllocMem(SizeOf(TRGBHistogram));
  for i := 0 to NumTotalCubes-1 do
  begin
    PHistogram(FHistogram)[i].Index := i;
  end;
end;

// �q�X�g�O������ӂ̒����ōċA�I�ɕ�������
procedure TMedianCut.CutCubes(Low, High, Depth, MaxDepth: Integer;
  var Cubes: THistogram; var Colors: TRGBQuadArray;
  var NumColors: Integer);
var
  i, j, NumPixels: LongInt;
  RAve, GAve, BAve: Int64;                   // �ԁA�΁A�̕��ϒl
  R, G, B: Byte;
  RMin, RMax, GMin, GMax, BMin, BMax: Byte;  // �ԁA�΁A�̍ő�A�ŏ��l
  temp: TMedianCutCube;
begin
   // Low = High �ł� Cube �Q�� Cube ����������Ă��Ȃ��B
  if Low = High then Exit;

  // Cube �Q�̐F�̕��ςƕ��U���v�Z
  RAve := 0; GAve := 0; BAve := 0;
  RMin := 255; RMax := 0;
  GMin := 255; GMax := 0;
  BMin := 255; BMax := 0;
  NumPixels := 0;

  for i := Low to High-1 do begin
    Inc(NumPixels, Cubes[i].NumPixels);  // �s�N�Z���̑������J�E���g

    R := Cubes[i].Red;
    G := Cubes[i].Green;
    B := Cubes[i].Blue;

    // �e�F�̍ő�^�ŏ������߂�
    if R < RMin then RMin := R;
    if G < GMin then GMin := G;
    if B < BMin then BMin := B;

    if R > RMax then RMax := R;
    if G > GMax then GMax := G;
    if B > BMax then BMax := B;

    // �e�F��ώZ����
    {$IFDEF ORIGINAL} // 2002/7/26 �o�O�C�� DHGL1.2�@
    RAve := RAve + R * Cubes[i].NumPixels;
    GAve := GAve + G * Cubes[i].NumPixels;
    BAve := BAve + B * Cubes[i].NumPixels;
    {$ELSE}
    RAve := RAve + Int64(R) * Cubes[i].NumPixels;
    GAve := GAve + Int64(G) * Cubes[i].NumPixels;
    BAve := BAve + Int64(B) * Cubes[i].NumPixels;
    {$ENDIF}
  end;

  // �s�N�Z��������������͑SCube �̕��ς̐F��
  // �����������B
  if NumPixels = 0 then
  begin
    RAve := 0; GAve := 0; BAve := 0;
    for i := Low to High-1 do
    begin
      RAve := RAve + Cubes[i].Red;
      GAve := GAve + Cubes[i].Green;
      BAve := BAve + Cubes[i].Blue;
    end;
    RAve := RAve div (High - Low);
    GAve := GAve div (High - Low);
    BAve := BAve div (High - Low);
  end
  else
  begin
    RAve := RAve div NumPixels;
    GAve := GAve div NumPixels;
    BAve := BAve div NumPixels;
  end;

  // Depth = MaxDepth �܂�A2^MaxDepth�Q�ɕ������Ă���Ȃ�΁A�F�̕��ς�
  // �J���[�e�[�u���ɓo�^����B�s�N�Z�������������o�^����B
  if (Depth = MaxDepth) or (NumPixels = 0) then begin
    Colors[NumColors].rgbRed      := RAve;
    Colors[NumColors].rgbGreen    := GAve;
    Colors[NumColors].rgbBlue     := BAve;
    Colors[NumColors].rgbReserved := 0;
    for i := Low to High -1 do
      Cubes[i].ColorIndex := NumColors;
    // ���F�J���[����o�^���ꂽ
    Inc(NumColors);
    Exit;
  end;

  // Color Cube �Q�𕪊�����B
  // �ԁA�΁A�� �̂����A�ł��Ђ낪��̑傫���F�ŕ�������B�A���A��r���鎞
  // �Ԃ�1.2�{�A�΂�1.4�{�A��1�{���Ă����r����B�΂�Ԃ̕����d�v�Ȃ��߁A
  // �΂�Ԃŕ������N���₷�������A�ǂ��i���̃J���[�e�[�u����������B

  i := Low; j := High;

  if ((RMax-Rmin)*1.2 >= (GMax-GMin)*1.4) and
     ((RMax-RMin)*1.2 >= (BMax-BMin)*1.0) then begin
    // �Ԃ� Color Cube �Q�𕪊�����
    while i < j do begin
      while (i < j) and (Cubes[i].Red <= RAve) do inc(i);
      while (i < j) and (Cubes[j-1].Red > RAve) do dec(j);
      if i <> j then begin
        temp := Cubes[i];
        Cubes[i] := Cubes[j-1];
        Cubes[j-1] := temp;
      end;
    end;
  end else if ((GMax-GMin)*1.4 >= (RMax-Rmin)*1.2) and
              ((GMax-GMin)*1.4 >= (BMax-BMin)*1.0) then begin
    // �΂� Color Cube �Q�𕪊�����
    while i < j do begin
      while (i < j) and (Cubes[i].Green <= GAve) do inc(i);
      while (i < j) and (Cubes[j-1].Green >  GAve) do dec(j);
      if i <> j then begin
        temp := Cubes[i];
        Cubes[i] := Cubes[j-1];
        Cubes[j-1] := temp;
      end;
    end;
  end else begin
    // �� Color Cube �Q�𕪊�����
    while i < j do begin
      while (i < j) and (Cubes[i].Blue <= BAve) do inc(i);
      while (i < j) and (Cubes[j-1].Blue > BAve) do dec(j);
      if i <> j then begin
        temp := Cubes[i];
        Cubes[i] := Cubes[j-1];
        Cubes[j-1] := temp;
      end;
    end;
  end;

  // ���邢�����ɃJ�b�g����B���̕����J���[�e�[�u���̐擪��
  // ���邢�F���W�܂�B
  CutCubes(i, High, Depth+1, MaxDepth, Cubes, Colors, NumColors);
  CutCubes(Low, i, Depth+1, MaxDepth, Cubes, Colors, NumColors);
end;

// ���U���g���ăq�X�g�O�����𕪊�����
procedure TMedianCut.CutCubesByVariance(Low, High, Depth,
  MaxDepth: Integer; var Cubes: THistogram; var Colors: TRGBQuadArray;
  var NumColors: Integer);
var
  i, j, NumPixels: LongInt;
  RAve, GAve, BAve: Int64;                   // �ԁA�΁A�̕��ϒl
  R, G, B: Byte;
  temp: TMedianCutCube;
  RV, GV, BV: Extended;                      // �ԁA�΁A�̕��U

begin
   // Low = High �ł� Cube �Q�� Cube ����������Ă��Ȃ��B
  if Low = High then Exit;

  // Cube �Q�̐F�̕��ςƕ��U���v�Z
  RAve := 0; GAve := 0; BAve := 0;
  RV := 0; GV := 0; BV := 0;
  NumPixels := 0;

  for i := Low to High-1 do begin
    Inc(NumPixels, Cubes[i].NumPixels);  // �s�N�Z���̑������J�E���g
    R := Cubes[i].Red;
    G := Cubes[i].Green;
    B := Cubes[i].Blue;

    {$IFDEF ORIGINAL} // 2002/7/26 �o�O�C���@DHGL 1.2
    // �e�F��ώZ����
    RAve := RAve + R * Cubes[i].NumPixels;
    GAve := GAve + G * Cubes[i].NumPixels;
    BAve := BAve + B * Cubes[i].NumPixels;
    {$ELSE}
    // �e�F��ώZ����
    RAve := RAve + Int64(R) * Cubes[i].NumPixels;
    GAve := GAve + Int64(G) * Cubes[i].NumPixels;
    BAve := BAve + Int64(B) * Cubes[i].NumPixels;
    {$ENDIF}

    // �����F�̂Q��a���ώZ����
    RV := RV + sqr(Cubes[i].Red * 1.0) * Cubes[i].NumPixels;
    GV := GV + sqr(Cubes[i].Green * 1.0) * Cubes[i].NumPixels;
    BV := BV + sqr(Cubes[i].Blue * 1.0) * Cubes[i].NumPixels;

  end;

  // �s�N�Z��������������͑SCube �̕��ς̂����
  // �����������B
  if NumPixels = 0 then
  begin
    RAve := 0; GAve := 0; BAve := 0;
    for i := Low to High-1 do
    begin
      RAve := RAve + Cubes[i].Red;
      GAve := GAve + Cubes[i].Green;
      BAve := BAve + Cubes[i].Blue;
    end;
    //�e�F�̕��όv�Z����
    RAve := RAve div (High - Low);
    GAve := GAve div (High - Low);
    BAve := BAve div (High - Low);
  end
  else
  begin
    //�e�F�̕��όv�Z����
    RAve := RAve div NumPixels;
    GAve := GAve div NumPixels;
    BAve := BAve div NumPixels;

    //�e�F�̕��U���v�Z����
    RV := RV / NumPixels - sqr(RAve);
    GV := GV / NumPixels - sqr(GAve);
    BV := BV / NumPixels - sqr(BAve);
  end;


  // Depth = MaxDepth �܂�A2^MaxDepth�Q�ɕ������Ă���Ȃ�΁A�F�̕��ς�
  // �J���[�e�[�u���ɓo�^����B�s�N�Z�������������o�^����B
  if (Depth = MaxDepth) or (NumPixels = 0) then begin
    Colors[NumColors].rgbRed      := RAve;
    Colors[NumColors].rgbGreen    := GAve;
    Colors[NumColors].rgbBlue     := BAve;
    Colors[NumColors].rgbReserved := 0;
    for i := Low to High -1 do
      Cubes[i].ColorIndex := NumColors;
    // ���F�J���[����o�^���ꂽ
    Inc(NumColors);
    Exit;
  end;

  // Color Cube �Q�𕪊�����B
  // �ԁA�΁A�� �̂����A�ł����U�̑傫���F�ŕ�������B�A���A��r���鎞
  // �Ԃ�3�{�A�΂�4�{�A��2�{���Ă����r����B�΂�Ԃ̕����d�v�Ȃ��߁A
  // �΂�Ԃŕ������N���₷�������A�ǂ��i���̃J���[�e�[�u����������B

  i := Low; j := High;

  if (RV*3 >= GV*4) and
     (RV*3 >= BV*2) then begin
    // �Ԃ� Color Cube �Q�𕪊�����
    while i < j do begin
      while (i < j) and (Cubes[i].Red <= RAve) do inc(i);
      while (i < j) and (Cubes[j-1].Red > RAve) do dec(j);
      if i <> j then begin
        temp := Cubes[i];
        Cubes[i] := Cubes[j-1];
        Cubes[j-1] := temp;
      end;
    end;
  end else if (GV*4 >= RV*3) and
              (GV*3 >= BV*2) then begin
    // �΂� Color Cube �Q�𕪊�����
    while i < j do begin
      while (i < j) and (Cubes[i].Green <= GAve) do inc(i);
      while (i < j) and (Cubes[j-1].Green >  GAve) do dec(j);
      if i <> j then begin
        temp := Cubes[i];
        Cubes[i] := Cubes[j-1];
        Cubes[j-1] := temp;
      end;
    end;
  end else begin
    // �� Color Cube �Q�𕪊�����
    while i < j do begin
      while (i < j) and (Cubes[i].Blue <= BAve) do inc(i);
      while (i < j) and (Cubes[j-1].Blue > BAve) do dec(j);
      if i <> j then begin
        temp := Cubes[i];
        Cubes[i] := Cubes[j-1];
        Cubes[j-1] := temp;
      end;
    end;
  end;

  // ���邢�����ɃJ�b�g����B���̕����J���[�e�[�u���̐擪��
  // ���邢�F���W�܂�B
  CutCubesByVariance(i, High, Depth+1, MaxDepth, Cubes, Colors, NumColors);
  CutCubesByVariance(Low, i, Depth+1, MaxDepth, Cubes, Colors, NumColors);
end;

destructor TMedianCut.Destroy;
begin
  FreeMem(FHistogram);
  inherited;
end;

//�F���J���[�e�[�u���C���f�b�N�X�ɕϊ�����
function TMedianCut.GetColorIndex(Color: TTriple): Integer;
begin
  Result := P3DByteArray(@FColorConvertTable)[Color.R shr 2,
                                              Color.G shr 2,
                                              Color.B shr 3];

end;

// �q�X�g�O�����̕������ʂ��g���ăp���b�g�����
function TMedianCut.MakePalette: HPALETTE;
var
  LogPalette: TMaxLogPalette;
  i: Integer;
begin
  LogPalette.palVersion := $0300;
  LogPalette.palNumEntries := FNumColors;
  for i := 0 to FNumColors-1 do
  begin
    LogPalette.palPalEntry[i].peRed   := FColors[i].rgbRed;
    LogPalette.palPalEntry[i].peGreen := FColors[i].rgbGreen;
    LogPalette.palPalEntry[i].peBlue  := FColors[i].rgbBlue;
    LogPalette.palPalEntry[i].peFlags := 0;
  end;
  Result := CreatePalette(PLogPalette(@LogPalette)^);
end;

// �q�X�g�O�����𕪊�����
procedure TMedianCut.ReduceColors(MaxDepth: Integer; ShrinkCubes: Boolean);
var
  ri, gi, bi: Integer;  // �q�X�g�O�����̃C���f�b�N�X
  NumPixels: Integer;   // �e Cube �̃s�N�Z����
  i: Integer;
  NumCubes: Integer;    // Cube �̐�
begin
  // �e Color Cube �� RGB �l�̕��ϒl�𓾂�B
  for ri := 0 to 63 do
    for gi := 0 to 63 do
      for bi := 0 to 31 do begin
        NumPixels := FHistogram[ri, gi, bi].NumPixels;
        if NumPixels <> 0 then begin
          FHistogram[ri, gi, bi].Red :=
            (ri shl 2) + FHistogram[ri, gi, bi].Red div NumPixels;
          FHistogram[ri, gi, bi].Green :=
            (gi shl 2) + FHistogram[ri, gi, bi].Green div NumPixels;
          FHistogram[ri, gi, bi].Blue :=
            (bi shl 3) + FHistogram[ri, gi, bi].Blue div NumPixels;
        end
        else
        begin
          FHistogram[ri, gi, bi].Red :=   (ri shl 2) + 2;
          FHistogram[ri, gi, bi].Green := (gi shl 2) + 2;
          FHistogram[ri, gi, bi].Blue :=  (bi shl 3) + 4;
        end;
      end;

  FNumColors := 0; //���o�����F���������ݒ�

  if ShrinkCubes then
  begin
    // �s�N�Z����1�ȏ�����Ă��� Color Cube ������I��
    NumCubes := 0;

    for i := 0 to NumTotalCubes-1 do
      if PHistogram(FHistogram)[i].NumPixels <> 0 then begin
        PHistogram(FHistogram)[NumCubes] := PHistogram(FHistogram)[i];
        Inc(NumCubes);
      end;
  end
  else
    NumCubes := NumTotalCubes;;

  // �F�𒊏o����
  CutCubes(0, NumCubes, 0, MaxDepth, PHistogram(FHistogram)^,
           FColors, FNumColors);

  // �F�ϊ��e�[�u�������
  FillChar(FColorConvertTable, NumTotalCubes, 0);
  for i := 0 to NumCubes-1 do
    FColorConvertTable[PHistogram(FHistogram)[i].Index] :=
      PHistogram(FHistogram)[i].ColorIndex;
end;

// ���U���g���ăq�X�g�O�����𕪊�����
procedure TMedianCut.ReduceColorsByVariance(MaxDepth: Integer; ShrinkCubes: Boolean);
var
  ri, gi, bi: Integer;  // �q�X�g�O�����̃C���f�b�N�X
  NumPixels: Integer;   // �e Cube �̃s�N�Z����
  NumCubes: Integer;    // Cube �̐�
  i: Integer;
begin
  // �e Color Cube �� RGB �l�̕��ϒl�𓾂�B
  for ri := 0 to 63 do
    for gi := 0 to 63 do
      for bi := 0 to 31 do begin
        NumPixels := FHistogram[ri, gi, bi].NumPixels;
        if NumPixels <> 0 then begin
          FHistogram[ri, gi, bi].Red :=
            (ri shl 2) + FHistogram[ri, gi, bi].Red div NumPixels;
          FHistogram[ri, gi, bi].Green :=
            (gi shl 2) + FHistogram[ri, gi, bi].Green div NumPixels;
          FHistogram[ri, gi, bi].Blue :=
            (bi shl 3) + FHistogram[ri, gi, bi].Blue div NumPixels;
        end
        else
        begin
          FHistogram[ri, gi, bi].Red :=   (ri shl 2) + 2;
          FHistogram[ri, gi, bi].Green := (gi shl 2) + 2;
          FHistogram[ri, gi, bi].Blue :=  (bi shl 3) + 4;
        end;
      end;

  FNumColors := 0; //���o�����F���������ݒ�

  if ShrinkCubes then
  begin
    // �s�N�Z����1�ȏ�����Ă��� Color Cube ������I��
    NumCubes := 0;

    for i := 0 to NumTotalCubes-1 do
      if PHistogram(FHistogram)[i].NumPixels <> 0 then begin
        PHistogram(FHistogram)[NumCubes] := PHistogram(FHistogram)[i];
        Inc(NumCubes);
      end;
  end
  else
    NumCubes := NumTotalCubes;

  // �F�𒊏o����
  CutCubesByVariance(0, NumCubes, 0, MaxDepth, PHistogram(FHistogram)^,
           FColors, FNumColors);

  // �F�ϊ��e�[�u�������
  FillChar(FColorConvertTable, NumTotalCubes, 0);
  for i := 0 to NumCubes-1 do
    FColorConvertTable[PHistogram(FHistogram)[i].Index] :=
      PHistogram(FHistogram)[i].ColorIndex;
end;


end.
