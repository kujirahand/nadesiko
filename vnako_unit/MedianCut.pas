{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
//////////
//
// 本ユニットにはメディアンカットで減色を
// 行う各種ルーチンが含まれています。

unit MedianCut;

interface

uses Windows, SysUtils, Graphics, BigBitmap, BitmapUtils;

// 減色処理(辺の長さでで分割)
function ReduceColorsByMedianCut(Bitmap: TBitmap; Depth: Integer)
  : TBitmap; overload;

// 減色処理(分散で分割)
function ReduceColorsByMedianCutV(Bitmap: TBitmap; Depth: Integer)
  : TBitmap; overload;

// 減色処理(辺の長さで分割＋誤差拡散)
function ReduceColorsByMedianCutED(Bitmap: TBitmap;
                                   Depth: Integer): TBitmap; overload;

// 減色処理(分散で分割＋誤差拡散)
function ReduceColorsByMedianCutVED(Bitmap: TBitmap;
                                    Depth: Integer): TBitmap; overload;

// TBigBitmap版

// 減色処理(辺の長さでで分割)
function ReduceColorsByMedianCut(Bitmap: TBigBitmap; Depth: Integer)
  : TBigBitmap; overload;

// 減色処理(分散で分割)
function ReduceColorsByMedianCutV(Bitmap: TBigBitmap; Depth: Integer)
  : TBigBitmap; overload;

// 減色処理(辺の長さで分割＋誤差拡散)
function ReduceColorsByMedianCutED(Bitmap: TBigBitmap;
                                   Depth: Integer): TBigBitmap; overload;

// 減色処理(分散で分割＋誤差拡散)
function ReduceColorsByMedianCutVED(Bitmap: TBigBitmap;
                                    Depth: Integer): TBigBitmap; overload;

type
  // メディアンカットの Cube
  TMedianCutCube = record
    ColorIndex:  WORD;     // このノードのカラーインデックス
    Index:       Integer;  // このノードの配列インデックス
    NumPixels:   Integer;  // Cube内のピクセル数の総計
    Red:         DWORD;    // Cube内の赤(積算または平均)
    Green:       DWORD;    // Cube内の緑(積算または平均)
    Blue:        DWORD;    // Cube内の青(積算または平均)
  end;

  // ヒストグラムの宣言。
  // Cube とは RGB立方体を赤方向に64分割, 緑方向に64分割、青方向に32分割
  // した場合のセルのことで、Cube にはCubeに含まれる色数や色の積算など
  // が入る。 131072個 で 3MB のメモリを占める。
  // Cube の配列をヒストグラムと呼ぶ
  const
    NumRed=64; NumGreen=64; NumBlue = 32;
    NumTotalCubes = NumRed * NumGreen * NumBlue;

  type
  TRGBHistogram = array[0..NumRed-1, 0..NumGreen-1, 0..NumBlue-1]
                  of TMedianCutCube;
  PRGBHistogram = ^TRGBHistogram;
  THistogram    = array[0..NumTotalCubes-1]of TMedianCutCube;
  PHistogram    = ^THistogram;

  // RGBQuad の配列
  TRGBQuadArray    = array[0..255] of TRGBQuad;
  PRGBQuadArray    = ^TRGBQuadArray;

  // メディアンカット クラス
  TMedianCut = class
  private
    FHistogram: PRGBHistogram;
    FColorConvertTable: array[0..NumTotalCubes-1] of Byte;
    FNumColors: Integer;   // 抽出される色数
    FColors: TRGBQuadArray;

    // ヒストグラムを分割する(辺の長さで分割)
    procedure CutCubes(Low,        // Color Cube 群の最初の Cube を指す
                                   // インデックス
                       High,       // Color Cube 群の最後の次の Cube を指す
                                   //インデックス
                       Depth,      // 分割の深さ
                       MaxDepth: LongInt;     // 分割の深さの最大値
                       var Cubes: THistogram; // Color Cube 配列
                       var Colors: TRGBQuadArray; // 減色カラー出力用の
                                                  // カラーテーブル
                       var NumColors: LongInt);   // 出力された減色カラー色の数

    // ヒストグラムを分割する
    procedure CutCubesByVariance(
                       Low,        // Color Cube 群の最初の Cube を指す
                                   // インデックス
                       High,       // Color Cube 群の最後の次の Cube を指す
                                   //インデックス
                       Depth,                 // 分割の深さ
                       MaxDepth: LongInt;     // 分割の深さの最大値
                       var Cubes: THistogram; // Color Cube 配列
                       var Colors: TRGBQuadArray; // 減色カラー出力用の
                                                  // カラーテーブル
                       var NumColors: LongInt);   // 出力された減色カラー色の数

  public
    constructor Create;
    destructor  Destroy; override;

    //ヒストグラムに色を加える
    procedure AddColor(AColor: TTriple);


    // 減色する。ヒストグラムの分割は辺の長さを用いる。
    // ShrinkCubes はヒストグラムの中のピクセルを持たないCubeを
    // 処理しないことを指定する。処理しない場合、分割されたヒストグラムを
    // 使って 色 -> カラーテーブルインデックスする場合、ヒストグラムに
    // 含まれない色は変換できない。
    procedure ReduceColors(MaxDepth: Integer; ShrinkCubes: Boolean);
    // 減色する。ヒストグラムの分割は分散を用いる。
    // ShrinkCubes はヒストグラムの中のピクセルを持たないCubeを
    // 処理しないことを指定する。処理しない場合、分割されたヒストグラムを
    // 使って 色 -> カラーテーブルインデックスする場合、ヒストグラムに
    // 含まれない色は変換できない。
    procedure ReduceColorsByVariance(MaxDepth: Integer; ShrinkCubes: Boolean);

    // 分割されたヒストグラムかパレットを作る
    function MakePalette: HPALETTE;

    // 色 -> カラーテーブルインデックス変換を行う。
    // 上の ShrinkCubes の説明に注意
    function GetColorIndex(Color: TTriple): Integer;
  end;

implementation

uses ErrDef;

type
  // カラー -> カラーインデックス変換テーブル用の配列型
  T3DByteArray = array[0..63, 0..63, 0..31] of Byte;
  P3DByteArray = ^T3DByteArray;


// 減色処理(辺の長さでで分割)
function ReduceColorsByMedianCut(Bitmap: TBitmap; Depth: Integer)
  : TBitmap; overload;
var
  NewBitmap: TBitmap;       // 新しく作るビットマップ
  MedianCut: TMedianCut;    // メディアンカット
  x, y: Integer;            // 座標
  SourceScan: PTripleArray; // 新旧ビットマップの Scanline
  DestScan: PByteArray;
begin
  Assert(Depth >= 0);
  Assert(Bitmap.PixelFormat = pf24bit);

  MedianCut := TMedianCut.Create;  // MedianCut を作成
  try
    // ヒストグラム の構築
    for y := 0 to Bitmap.Height-1 do
    begin
      SourceScan := Bitmap.Scanline[y];
      for x := 0 to Bitmap.Width-1 do
        MedianCut.AddColor(SourceScan[x]);
    end;

    // 減色。誤差拡散処理が無いので、効率の良い ShrinCubes = True を使う
    MedianCut.ReduceColors(Depth, True);    // 減色

    //新しい 8bpp のビットマップの作成
    NewBitmap := TBitmap.Create;
    try
      NewBitmap.PixelFormat := pf8bit;
      NewBitmap.Width := Bitmap.Width;
      NewBitmap.Height := Bitmap.Height;
      NewBitmap.Palette := MedianCut.MakePalette; // 減色されたパレット

      // 色変換のループ
      for y := 0 to Bitmap.Height-1 do
      begin
        SourceScan := Bitmap.Scanline[y];
        DestScan := NewBitmap.Scanline[y];
        for x := 0 to Bitmap.Width-1 do
        begin
          // MedianCut の GetColorIndex で 24bit Color を パレットの
          // エントリ番号に変換
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

// 減色処理(分散で分割)
function ReduceColorsByMedianCutV(Bitmap: TBitmap; Depth: Integer)
  : TBitmap; overload;
var
  NewBitmap: TBitmap;       // 新しく作るビットマップ
  MedianCut: TMedianCut;    // メディアンカット
  x, y: Integer;            // 座標
  SourceScan: PTripleArray; // 新旧ビットマップの Scanline
  DestScan: PByteArray;
begin
  Assert(Depth >= 0);
  Assert(Bitmap.PixelFormat = pf24bit);

  MedianCut := TMedianCut.Create;  // MedianCut を作成
  try
    // ヒストグラム の構築
    for y := 0 to Bitmap.Height-1 do
    begin
      SourceScan := Bitmap.Scanline[y];
      for x := 0 to Bitmap.Width-1 do
        MedianCut.AddColor(SourceScan[x]);
    end;

    // 分散でメディアンカットする。
    // 誤差拡散しないので効率の良い ShrinkCubes=True を使う
    MedianCut.ReduceColorsByVariance(Depth, True);    // 256色以下に減色

    //新しい8bppのビットマップの作成
    NewBitmap := TBitmap.Create;
    try
      NewBitmap.PixelFormat := pf8bit;
      NewBitmap.Width := Bitmap.Width;
      NewBitmap.Height := Bitmap.Height;
      NewBitmap.Palette := MedianCut.MakePalette; // 減色されたパレット

      // 色変換のループ
      for y := 0 to Bitmap.Height-1 do
      begin
        SourceScan := Bitmap.Scanline[y];
        DestScan := NewBitmap.Scanline[y];
        for x := 0 to Bitmap.Width-1 do
        begin
          // MedianCut の GetColorIndex で 24bit Color を パレットの
          // エントリ番号に変換
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

// 減色処理(辺の長さで分割＋誤差拡散)
function ReduceColorsByMedianCutED(Bitmap: TBitmap;
                                   Depth: Integer): TBitmap;
var
  NewBitmap, NewBitmap2: TBitmap; // 新しく作るビットマップ
  MedianCut: TMedianCut;          // メディアンカット
  x, y: Integer;                  // 座標
  SourceScan: PTripleArray;       // 新旧ビットマップの Scanline
  DestScan: PByteArray;
  QuantizeColor: TMedianCutQuantizeColor; // 色量子化クラス
begin
  Assert(Depth >= 0);
  Assert(Bitmap.PixelFormat = pf24bit);

  MedianCut := TMedianCut.Create;  // MedianCut を作成
  try
    // MedianCut の構築
    for y := 0 to Bitmap.Height-1 do
    begin
      SourceScan := Bitmap.Scanline[y];
      for x := 0 to Bitmap.Width-1 do
        MedianCut.AddColor(SourceScan[x]);
    end;

    // 誤差拡散では拡散処理でいろいろな色が生じるので
    // 全ての Cube を処理しないと色のインデックスへの変換ができなくなる
    MedianCut.ReduceColors(Depth, False);    // 256色以下に減色

    // 誤差拡散処理
    QuantizeColor := TMedianCutQuantizeColor.Create(MedianCut);
    try
      NewBitmap := ErrorDefusion(Bitmap, QuantizeColor);
    finally
      QuantizeColor.Free;
    end;

    try
      //新しい8bppのビットマップの作成
      NewBitmap2 := TBitmap.Create;
      try
        NewBitmap2.PixelFormat := pf8bit;
        NewBitmap2.Width := Bitmap.Width;
        NewBitmap2.Height := Bitmap.Height;
        NewBitmap2.Palette := MedianCut.MakePalette; // 減色されたパレット

        // 色変換のループ
        for y := 0 to Bitmap.Height-1 do
        begin
          SourceScan := NewBitmap.Scanline[y];
          DestScan := NewBitmap2.Scanline[y];
          for x := 0 to Bitmap.Width-1 do
            // GetColorIndex で 24bit Color を パレットの
            // エントリ番号に変換
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

// 減色処理(分散で分割＋誤差拡散)
function ReduceColorsByMedianCutVED(Bitmap: TBitmap;
                                    Depth: Integer): TBitmap;
var
  NewBitmap, NewBitmap2: TBitmap; // 新しく作るビットマップ
  MedianCut: TMedianCut;          // メディアンカット
  x, y: Integer;                  // 座標
  SourceScan: PTripleArray;       // 新旧ビットマップの Scanline
  DestScan: PByteArray;
  QuantizeColor: TMedianCutQuantizeColor; // 色量子化クラス
begin
  Assert(Depth >= 0);
  Assert(Bitmap.PixelFormat = pf24bit);

  MedianCut := TMedianCut.Create;  // MedianCut を作成
  try
    // MedianCut の構築
    for y := 0 to Bitmap.Height-1 do
    begin
      SourceScan := Bitmap.Scanline[y];
      for x := 0 to Bitmap.Width-1 do
        MedianCut.AddColor(SourceScan[x]);
    end;
    // 誤差拡散では拡散処理でいろいろな色が生じるので
    // 全ての Cube を処理しないと色のインデックスへの変換ができなくなる
    MedianCut.ReduceColorsByVariance(Depth, False);    // 256色以下に減色

    // 誤差拡散処理
    // 誤差拡散処理
    QuantizeColor := TMedianCutQuantizeColor.Create(MedianCut);
    try
      NewBitmap := ErrorDefusion(Bitmap, QuantizeColor);
    finally
      QuantizeColor.Free;
    end;

    try
      //新しい8bppのビットマップの作成
      NewBitmap2 := TBitmap.Create;
      try
        NewBitmap2.PixelFormat := pf8bit;
        NewBitmap2.Width := Bitmap.Width;
        NewBitmap2.Height := Bitmap.Height;
        NewBitmap2.Palette := MedianCut.MakePalette; // 減色されたパレット

        // 色変換のループ
        for y := 0 to Bitmap.Height-1 do
        begin
          SourceScan := NewBitmap.Scanline[y];
          DestScan := NewBitmap2.Scanline[y];
          for x := 0 to Bitmap.Width-1 do
            // GetColorIndex で 24bit Color を パレットの
            // エントリ番号に変換
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

// TBigBitmap版

// 減色処理(辺の長さでで分割)
function ReduceColorsByMedianCut(Bitmap: TBigBitmap; Depth: Integer)
  : TBigBitmap; overload;
var
  NewBitmap: TBigBitmap;    // 新しく作るビットマップ
  MedianCut: TMedianCut;    // メディアンカット
  x, y: Integer;            // 座標
  SourceScan: PTripleArray; // 新旧ビットマップの Scanline
  DestScan: PByteArray;
begin
  Assert(Depth >= 0);
  Assert(Bitmap.PixelFormat = bbpf24bit);

  MedianCut := TMedianCut.Create;  // MedianCut を作成
  try
    // ヒストグラム の構築
    for y := 0 to Bitmap.Height-1 do
    begin
      SourceScan := Bitmap.Scanline[y];
      for x := 0 to Bitmap.Width-1 do
        MedianCut.AddColor(SourceScan[x]);
    end;

    // 辺の長さを使ってヒストグラムを分割
    MedianCut.ReduceColors(Depth, True);    // 256色以下に減色

    //新しいビットマップの作成
    NewBitmap := TBigBitmap.Create;
    try
      NewBitmap.PixelFormat := bbpf8bit;
      NewBitmap.Width := Bitmap.Width;
      NewBitmap.Height := Bitmap.Height;
      NewBitmap.Palette := MedianCut.MakePalette; // 減色されたパレット

      // 色変換のループ
      for y := 0 to Bitmap.Height-1 do
      begin
        SourceScan := Bitmap.Scanline[y];
        DestScan := NewBitmap.Scanline[y];
        for x := 0 to Bitmap.Width-1 do
          // MedianCut の GetColorIndex で 24bit Color を パレットの
          // エントリ番号に変換
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


// 減色処理(分散で分割)
function ReduceColorsByMedianCutV(Bitmap: TBigBitmap; Depth: Integer)
  : TBigBitmap; overload;
var
  NewBitmap: TBigBitmap;    // 新しく作るビットマップ
  MedianCut: TMedianCut;    // メディアンカット
  x, y: Integer;            // 座標
  SourceScan: PTripleArray; // 新旧ビットマップの Scanline
  DestScan: PByteArray;
begin
  Assert(Depth >= 0);
  Assert(Bitmap.PixelFormat = bbpf24bit);

  MedianCut := TMedianCut.Create;  // MedianCut を作成
  try
    // ヒストグラム の構築
    for y := 0 to Bitmap.Height-1 do
    begin
      SourceScan := Bitmap.Scanline[y];
      for x := 0 to Bitmap.Width-1 do
      begin
        MedianCut.AddColor(SourceScan[x]);
      end;
    end;

    // 分散を使ってヒストグラムを分割
    MedianCut.ReduceColorsByVariance(Depth, True);    // 256色以下に減色

    //新しい 8bpp のビットマップの作成
    NewBitmap := TBigBitmap.Create;
    try
      NewBitmap.PixelFormat := bbpf8bit;
      NewBitmap.Width := Bitmap.Width;
      NewBitmap.Height := Bitmap.Height;
      NewBitmap.Palette := MedianCut.MakePalette; // 減色されたパレット

      // 色変換のループ
      for y := 0 to Bitmap.Height-1 do
      begin
        SourceScan := Bitmap.Scanline[y];
        DestScan := NewBitmap.Scanline[y];
        for x := 0 to Bitmap.Width-1 do
          // MedianCut の GetColorIndex で 24bit Color を パレットの
          // エントリ番号に変換
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

// 減色処理(辺の長さで分割＋誤差拡散)
function ReduceColorsByMedianCutED(Bitmap: TBigBitmap;
                                   Depth: Integer): TBigBitmap; overload;
var
  NewBitmap, NewBitmap2: TBigBitmap; // 新しく作るビットマップ
  MedianCut: TMedianCut;             // メディアンカット
  x, y: Integer;                     // 座標
  SourceScan: PTripleArray;          // 新旧ビットマップの Scanline
  DestScan: PByteArray;
  QuantizeColor: TMedianCutQuantizeColor; // 色量子化クラス
begin
  Assert(Depth >= 0);
  Assert(Bitmap.PixelFormat = bbpf24bit);

  MedianCut := TMedianCut.Create;  // MedianCut を作成
  try
    // MedianCut の構築
    for y := 0 to Bitmap.Height-1 do
    begin
      SourceScan := Bitmap.Scanline[y];
      for x := 0 to Bitmap.Width-1 do
        MedianCut.AddColor(SourceScan[x]);
    end;
    // 辺の長さを使ってヒストグラムを分割
    MedianCut.ReduceColors(Depth, False);    // 256色以下に減色

    // 誤差拡散処理
    QuantizeColor := TMedianCutQuantizeColor.Create(MedianCut);
    try
      NewBitmap := ErrorDefusion(Bitmap, QuantizeColor);
    finally
      QuantizeColor.Free;
    end;

    // 8bpp の新ビットマップを作成
    try
      NewBitmap2 := TBigBitmap.Create;
      try
        NewBitmap2.PixelFormat := bbpf8bit;
        NewBitmap2.Width := Bitmap.Width;
        NewBitmap2.Height := Bitmap.Height;
        NewBitmap2.Palette := MedianCut.MakePalette; // 減色されたパレット

        // 色変換のループ
        for y := 0 to Bitmap.Height-1 do
        begin
          SourceScan := NewBitmap.Scanline[y];
          DestScan := NewBitmap2.Scanline[y];
          for x := 0 to Bitmap.Width-1 do
            // GetColorIndex で 24bit Color を パレットの
            // エントリ番号に変換
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

// 減色処理(分散で分割＋誤差拡散)
function ReduceColorsByMedianCutVED(Bitmap: TBigBitmap;
                                    Depth: Integer): TBigBitmap; overload;
var
  NewBitmap, NewBitmap2: TBigBitmap; // 新しく作るビットマップ
  MedianCut: TMedianCut;             // メディアンカット
  x, y: Integer;                     // 座標
  SourceScan: PTripleArray;          // 新旧ビットマップの Scanline
  DestScan: PByteArray;
  QuantizeColor: TMedianCutQuantizeColor; // 色量子化クラス
begin
  Assert(Depth >= 0);
  Assert(Bitmap.PixelFormat = bbpf24bit);

  MedianCut := TMedianCut.Create;  // MedianCut を作成
  try
    // MedianCut の構築(ヒストグラムの作成)
    for y := 0 to Bitmap.Height-1 do
    begin
      SourceScan := Bitmap.Scanline[y];
      for x := 0 to Bitmap.Width-1 do
        MedianCut.AddColor(SourceScan[x]);
    end;
    //分散を使って減色
    MedianCut.ReduceColorsByVariance(Depth, False); // 256色以下に減色

    // 誤差拡散処理
    QuantizeColor := TMedianCutQuantizeColor.Create(MedianCut);
    try
      NewBitmap := ErrorDefusion(Bitmap, QuantizeColor);
    finally
      QuantizeColor.Free;
    end;

    try
      // 8bpp の新しいビットマップを作成
      NewBitmap2 := TBigBitmap.Create;
      try
        NewBitmap2.PixelFormat := bbpf8bit;
        NewBitmap2.Width := Bitmap.Width;
        NewBitmap2.Height := Bitmap.Height;
        NewBitmap2.Palette := MedianCut.MakePalette; // 減色されたパレット

        // 色変換のループ
        for y := 0 to Bitmap.Height-1 do
        begin
          SourceScan := NewBitmap.Scanline[y];
          DestScan := NewBitmap2.Scanline[y];
          for x := 0 to Bitmap.Width-1 do
            // GetColorIndex で 24bit Color を パレットの
            // エントリ番号に変換
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

// ヒストグラムを構築する
procedure TMedianCut.AddColor(AColor: TTriple);
var
  ri, gi, bi: Integer;
begin
  ri := AColor.r shr 2; gi := AColor.g shr 2; bi := AColor.b shr 3;
  Inc(FHistogram[ri, gi, bi].NumPixels);

  // (ri, gi, bi) の示す基準色に対する差分だけを足しこむ
  // こうすることで 32bit で色を充分に積算できる。
  // 4G div 7 = 585M Pixelまで大丈夫
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

// ヒストグラムを辺の長さで再帰的に分割する
procedure TMedianCut.CutCubes(Low, High, Depth, MaxDepth: Integer;
  var Cubes: THistogram; var Colors: TRGBQuadArray;
  var NumColors: Integer);
var
  i, j, NumPixels: LongInt;
  RAve, GAve, BAve: Int64;                   // 赤、緑、青の平均値
  R, G, B: Byte;
  RMin, RMax, GMin, GMax, BMin, BMax: Byte;  // 赤、緑、青の最大、最小値
  temp: TMedianCutCube;
begin
   // Low = High では Cube 群は Cube を一つも持っていない。
  if Low = High then Exit;

  // Cube 群の色の平均と分散を計算
  RAve := 0; GAve := 0; BAve := 0;
  RMin := 255; RMax := 0;
  GMin := 255; GMax := 0;
  BMin := 255; BMax := 0;
  NumPixels := 0;

  for i := Low to High-1 do begin
    Inc(NumPixels, Cubes[i].NumPixels);  // ピクセルの総数をカウント

    R := Cubes[i].Red;
    G := Cubes[i].Green;
    B := Cubes[i].Blue;

    // 各色の最大／最小を求める
    if R < RMin then RMin := R;
    if G < GMin then GMin := G;
    if B < BMin then BMin := B;

    if R > RMax then RMax := R;
    if G > GMax then GMax := G;
    if B > BMax then BMax := B;

    // 各色を積算する
    {$IFDEF ORIGINAL} // 2002/7/26 バグ修正 DHGL1.2　
    RAve := RAve + R * Cubes[i].NumPixels;
    GAve := GAve + G * Cubes[i].NumPixels;
    BAve := BAve + B * Cubes[i].NumPixels;
    {$ELSE}
    RAve := RAve + Int64(R) * Cubes[i].NumPixels;
    GAve := GAve + Int64(G) * Cubes[i].NumPixels;
    BAve := BAve + Int64(B) * Cubes[i].NumPixels;
    {$ENDIF}
  end;

  // ピクセルが一つも無い時は全Cube の平均の色で
  // おちゃを濁す。
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

  // Depth = MaxDepth つまり、2^MaxDepth群に分けられているならば、色の平均を
  // カラーテーブルに登録する。ピクセルが無い時も登録する。
  if (Depth = MaxDepth) or (NumPixels = 0) then begin
    Colors[NumColors].rgbRed      := RAve;
    Colors[NumColors].rgbGreen    := GAve;
    Colors[NumColors].rgbBlue     := BAve;
    Colors[NumColors].rgbReserved := 0;
    for i := Low to High -1 do
      Cubes[i].ColorIndex := NumColors;
    // 減色カラーが一つ登録された
    Inc(NumColors);
    Exit;
  end;

  // Color Cube 群を分割する。
  // 赤、緑、青 のうち、最もひろがりの大きい色で分割する。但し、比較する時
  // 赤は1.2倍、緑は1.4倍、青は1倍してから比較する。緑や赤の方が重要なため、
  // 緑や赤で分割が起きやすい方が、良い品質のカラーテーブルが得られる。

  i := Low; j := High;

  if ((RMax-Rmin)*1.2 >= (GMax-GMin)*1.4) and
     ((RMax-RMin)*1.2 >= (BMax-BMin)*1.0) then begin
    // 赤で Color Cube 群を分割する
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
    // 緑で Color Cube 群を分割する
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
    // 青で Color Cube 群を分割する
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

  // 明るい方を先にカットする。この方がカラーテーブルの先頭に
  // 明るい色が集まる。
  CutCubes(i, High, Depth+1, MaxDepth, Cubes, Colors, NumColors);
  CutCubes(Low, i, Depth+1, MaxDepth, Cubes, Colors, NumColors);
end;

// 分散を使ってヒストグラムを分割する
procedure TMedianCut.CutCubesByVariance(Low, High, Depth,
  MaxDepth: Integer; var Cubes: THistogram; var Colors: TRGBQuadArray;
  var NumColors: Integer);
var
  i, j, NumPixels: LongInt;
  RAve, GAve, BAve: Int64;                   // 赤、緑、青の平均値
  R, G, B: Byte;
  temp: TMedianCutCube;
  RV, GV, BV: Extended;                      // 赤、緑、青の分散

begin
   // Low = High では Cube 群は Cube を一つも持っていない。
  if Low = High then Exit;

  // Cube 群の色の平均と分散を計算
  RAve := 0; GAve := 0; BAve := 0;
  RV := 0; GV := 0; BV := 0;
  NumPixels := 0;

  for i := Low to High-1 do begin
    Inc(NumPixels, Cubes[i].NumPixels);  // ピクセルの総数をカウント
    R := Cubes[i].Red;
    G := Cubes[i].Green;
    B := Cubes[i].Blue;

    {$IFDEF ORIGINAL} // 2002/7/26 バグ修正　DHGL 1.2
    // 各色を積算する
    RAve := RAve + R * Cubes[i].NumPixels;
    GAve := GAve + G * Cubes[i].NumPixels;
    BAve := BAve + B * Cubes[i].NumPixels;
    {$ELSE}
    // 各色を積算する
    RAve := RAve + Int64(R) * Cubes[i].NumPixels;
    GAve := GAve + Int64(G) * Cubes[i].NumPixels;
    BAve := BAve + Int64(B) * Cubes[i].NumPixels;
    {$ENDIF}

    // 書く色の２乗和も積算する
    RV := RV + sqr(Cubes[i].Red * 1.0) * Cubes[i].NumPixels;
    GV := GV + sqr(Cubes[i].Green * 1.0) * Cubes[i].NumPixels;
    BV := BV + sqr(Cubes[i].Blue * 1.0) * Cubes[i].NumPixels;

  end;

  // ピクセルが一つも無い時は全Cube の平均のいろで
  // おちゃを濁す。
  if NumPixels = 0 then
  begin
    RAve := 0; GAve := 0; BAve := 0;
    for i := Low to High-1 do
    begin
      RAve := RAve + Cubes[i].Red;
      GAve := GAve + Cubes[i].Green;
      BAve := BAve + Cubes[i].Blue;
    end;
    //各色の平均計算する
    RAve := RAve div (High - Low);
    GAve := GAve div (High - Low);
    BAve := BAve div (High - Low);
  end
  else
  begin
    //各色の平均計算する
    RAve := RAve div NumPixels;
    GAve := GAve div NumPixels;
    BAve := BAve div NumPixels;

    //各色の分散も計算する
    RV := RV / NumPixels - sqr(RAve);
    GV := GV / NumPixels - sqr(GAve);
    BV := BV / NumPixels - sqr(BAve);
  end;


  // Depth = MaxDepth つまり、2^MaxDepth群に分けられているならば、色の平均を
  // カラーテーブルに登録する。ピクセルが無い時も登録する。
  if (Depth = MaxDepth) or (NumPixels = 0) then begin
    Colors[NumColors].rgbRed      := RAve;
    Colors[NumColors].rgbGreen    := GAve;
    Colors[NumColors].rgbBlue     := BAve;
    Colors[NumColors].rgbReserved := 0;
    for i := Low to High -1 do
      Cubes[i].ColorIndex := NumColors;
    // 減色カラーが一つ登録された
    Inc(NumColors);
    Exit;
  end;

  // Color Cube 群を分割する。
  // 赤、緑、青 のうち、最も分散の大きい色で分割する。但し、比較する時
  // 赤は3倍、緑は4倍、青は2倍してから比較する。緑や赤の方が重要なため、
  // 緑や赤で分割が起きやすい方が、良い品質のカラーテーブルが得られる。

  i := Low; j := High;

  if (RV*3 >= GV*4) and
     (RV*3 >= BV*2) then begin
    // 赤で Color Cube 群を分割する
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
    // 緑で Color Cube 群を分割する
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
    // 青で Color Cube 群を分割する
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

  // 明るい方を先にカットする。この方がカラーテーブルの先頭に
  // 明るい色が集まる。
  CutCubesByVariance(i, High, Depth+1, MaxDepth, Cubes, Colors, NumColors);
  CutCubesByVariance(Low, i, Depth+1, MaxDepth, Cubes, Colors, NumColors);
end;

destructor TMedianCut.Destroy;
begin
  FreeMem(FHistogram);
  inherited;
end;

//色をカラーテーブルインデックスに変換する
function TMedianCut.GetColorIndex(Color: TTriple): Integer;
begin
  Result := P3DByteArray(@FColorConvertTable)[Color.R shr 2,
                                              Color.G shr 2,
                                              Color.B shr 3];

end;

// ヒストグラムの分割結果を使ってパレットを作る
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

// ヒストグラムを分割する
procedure TMedianCut.ReduceColors(MaxDepth: Integer; ShrinkCubes: Boolean);
var
  ri, gi, bi: Integer;  // ヒストグラムのインデックス
  NumPixels: Integer;   // 各 Cube のピクセル数
  i: Integer;
  NumCubes: Integer;    // Cube の数
begin
  // 各 Color Cube の RGB 値の平均値を得る。
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

  FNumColors := 0; //抽出される色数を初期設定

  if ShrinkCubes then
  begin
    // ピクセルが1個以上入っている Color Cube だけを選ぶ
    NumCubes := 0;

    for i := 0 to NumTotalCubes-1 do
      if PHistogram(FHistogram)[i].NumPixels <> 0 then begin
        PHistogram(FHistogram)[NumCubes] := PHistogram(FHistogram)[i];
        Inc(NumCubes);
      end;
  end
  else
    NumCubes := NumTotalCubes;;

  // 色を抽出する
  CutCubes(0, NumCubes, 0, MaxDepth, PHistogram(FHistogram)^,
           FColors, FNumColors);

  // 色変換テーブルを作る
  FillChar(FColorConvertTable, NumTotalCubes, 0);
  for i := 0 to NumCubes-1 do
    FColorConvertTable[PHistogram(FHistogram)[i].Index] :=
      PHistogram(FHistogram)[i].ColorIndex;
end;

// 分散を使ってヒストグラムを分割する
procedure TMedianCut.ReduceColorsByVariance(MaxDepth: Integer; ShrinkCubes: Boolean);
var
  ri, gi, bi: Integer;  // ヒストグラムのインデックス
  NumPixels: Integer;   // 各 Cube のピクセル数
  NumCubes: Integer;    // Cube の数
  i: Integer;
begin
  // 各 Color Cube の RGB 値の平均値を得る。
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

  FNumColors := 0; //抽出される色数を初期設定

  if ShrinkCubes then
  begin
    // ピクセルが1個以上入っている Color Cube だけを選ぶ
    NumCubes := 0;

    for i := 0 to NumTotalCubes-1 do
      if PHistogram(FHistogram)[i].NumPixels <> 0 then begin
        PHistogram(FHistogram)[NumCubes] := PHistogram(FHistogram)[i];
        Inc(NumCubes);
      end;
  end
  else
    NumCubes := NumTotalCubes;

  // 色を抽出する
  CutCubesByVariance(0, NumCubes, 0, MaxDepth, PHistogram(FHistogram)^,
           FColors, FNumColors);

  // 色変換テーブルを作る
  FillChar(FColorConvertTable, NumTotalCubes, 0);
  for i := 0 to NumCubes-1 do
    FColorConvertTable[PHistogram(FHistogram)[i].Index] :=
      PHistogram(FHistogram)[i].ColorIndex;
end;


end.
