{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
unit BitmapUtils;

interface

uses Windows, Classes, Graphics, BigBitmap;


////////////////////
//
// ビットマップの変形用ルーチン群
//


type
  // 変形元座標計算関数の型
  TBitmapTransFormFunction = function(Pos: TPoint; p: Pointer): TPoint;

// ビットマップを変形する
function TransformBitmap(
  OrgBitmap: TBitmap;
  NewWidth, NewHeight: Integer;                // 新しいビットマップの大きさ
  TransFormFunction: TBitmapTransFormFunction; // 変形元座標計算関数
  DefaultColor: Longint;                       // デフォルトカラー
  p: Pointer                                   // オプショナルパラメータ
  ): TBitmap; overload;

// ビットマップ拡大縮小する
function StretchBitmap(Bitmap: TBitmap;
                       NewWidth,           // 新しいビットマップの大きさ
                       NewHeight: Integer)
                       : TBitmap; overload;

// ビットマップを回転させる
function RotateBitmap(Bitmap: TBitmap;
                      NewWidth,           // 新しいビットマップの大きさ
                      NewHeight: Integer;
                      DestCenterX,        // 変形先の回転中心
                      DestCenterY,
                      SourceCenterX,      // 変形元の回転中心
                      SourceCenterY: Double;
                      Angle: Double;      // 回転角(時計回り)
                      DefaultColor: Longint) // デフォルトカラー
                      : TBitmap; overload;

type
  TRotateAngle = (raAngle90, raAngle180, raAngle270); // 回転角の指定
                                                      // 時計回り

function RotateBitmap(Bitmap: TBitmap;
                      RotateAngle: TRotateAngle)  // 回転角の指定
                      : TBitmap; overload;

// ビットマップをアフィン変換する
function AffineTransformBitmap(Bitmap: TBitmap;
                               NewWidth,           // 新しいビットマップの大きさ
                               NewHeight: Integer;
                               A, B, C, D,         // アフィン変換の係数
                               E, F, G, H: Double;
                               DefaultColor: Longint) // デフォルトカラー
                               : TBitmap; overload;

// ビットマップを横方向にミラー反転させる
function HorzMirrorBitmap(Bitmap: TBitmap): TBitmap; overload;
// ビットマップを縦方向にミラー反転させる。
function VertMirrorBitmap(Bitmap: TBitmap): TBitmap; overload;

//////////////////////////////
//
// ここから TBigBitmap 用
//

// ビットマップを変形する
function TransformBitmap(
  OrgBitmap: TBigBitmap;                       // 変形元ビットマップ
  NewWidth, NewHeight: Integer;                // 新ビットマップの大きさ
  TransFormFunction: TBitmapTransFormFunction; // 変形元座標計算関数
  DefaultColor: Longint;                       // デフォルトカラー
  p: Pointer                                   // オプショナルパラメータ
  ): TBigBitmap; overload;

// ビットマップ拡大縮小する
function StretchBitmap(Bitmap: TBigBitmap;
                          NewWidth,           // 新しいビットマップの大きさ
                          NewHeight: Integer)
                          : TBigBitmap; overload;

// ビットマップを回転させる
function RotateBitmap(Bitmap: TBigBitmap;
                      NewWidth, NewHeight: Integer;    //新ビットマップの大きさ
                      DestCenterX,            // 変形先の回転中心
                      DestCenterY,
                      SourceCenterX,          // 変形元の回転中心
                      SourceCenterY: Double;
                      Angle: Double;          // 回転角(時計回り)
                      DefaultColor: Longint)  // デフォルトカラー
                      : TBigBitmap; overload;

function RotateBitmap(Bitmap: TBigBitmap;
                         RotateAngle: TRotateAngle) // 回転の指定
                         : TBigBitmap; overload;

// ビットマップをアフィン変換する
function AffineTransformBitmap(Bitmap: TBigBitmap;
                               NewWidth,           // 新しいビットマップの大きさ
                               NewHeight: Integer;
                               A, B, C, D,         // アフィン変換の係数
                               E, F, G, H: Double;
                               DefaultColor: Longint) // デフォルトカラー
                               : TBigBitmap; overload;

// ビットマップを横方向にミラー反転させる
function HorzMirrorBitmap(Bitmap: TBigBitmap): TBigBitmap; overload;
// ビットマップを縦方向にミラー反転させる。
function VertMirrorBitmap(Bitmap: TBigBitmap): TBigBitmap; overload;


//////////////////////
//
// ビットマップを美しく拡大縮小するルーチン郡
//

// Bi-Linear法で拡大
function Enlarge(Bitmap: TBitmap; Width, Height: Integer): TBitmap;
  overload;
// 積分法で縮小
function Shrink(Bitmap: TBitmap; Width, Height: Integer): TBitmap;
  overload;
// Bi-Linear & 積分法で　拡大縮小
function Stretch(Bitmap: TBitmap; Width, Height: Integer): TBitmap;
  overload;

////////////
//
//  TBigBitmap用
//

// Bi-Linear法で拡大
function Enlarge(Bitmap: TBigBitmap; Width, Height: Integer): TBigBitmap;
  overload;
// 積分法で縮小
function Shrink(Bitmap: TBigBitmap; Width, Height: Integer): TBigBitmap;
  overload;
// Bi-Linear & 積分法で　拡大縮小
function Stretch(Bitmap: TBigBitmap; Width, Height: Integer): TBigBitmap;
  overload;

type
  TTriple = packed record
    B, G, R: Byte;
  end;
  TTripleArray = array[0..40000000] of TTriple;
  PTripleArray = ^TTripleArray;

  TDWordArray = array[0..100000000] of DWORD;
  PDWordArray = ^TDWordArray;

  TTriples = array[-5..5] of TTriple;
  PTriples = ^TTriples;
  TTripleMatrix = array[-5..5] of PTriples;

  TFilterProc = function(x, y: Integer; Mat: TTripleMatrix;
                       pData: Pointer): TTriple;


////////////////////
//
// フィルタ処理
//
function BitmapFilter(Bitmap: TBitmap; Filter: TFilterProc;
                      pData: Pointer): TBitmap; overload;

function BitmapFilter(Bitmap: TBigBitmap; Filter: TFilterProc;
                      pData: Pointer): TBigBitmap; overload;

implementation

uses SysUtils, Math;

// ビットマップを変形する
function TransformBitmap(
  OrgBitmap: TBitmap;
  NewWidth, NewHeight: Integer;
  TransFormFunction: TBitmapTransFormFunction;
  DefaultColor: Longint;
  p: Pointer
  ): TBitmap;
var
  NewBitmap,              // 新規に作成するビットマップ
  SourceBitmap: TBitmap;  // オリジナルのビットマップのコピー
  DS: TDIBSection;        // ビットマップの情報
  X, Y: Integer;          // 新規ビットマップ上での座標
  //スキャンラインのキャッシュ
  SourceScanline, DestScanline: array of Pointer;
  BitCount: Integer;      //ピクセルのビット数
  SourcePos: TPoint;      // SoucreBitmap上での座標
  // SourceBitmap の大きさ
  SourceWidth, SourceHeight: Integer;
  Bits: Byte;             // 1bpp, 4bpp ピクセル操作のためのワーク
  DefaultColor24: TTriple;// 24bpp の場合のデフォルトカラー
  i: Integer;
begin
  // 24bpp のデフォルトカラーを作る
  DefaultColor24.R := GetRValue(DefaultColor);
  DefaultColor24.G := GetGValue(DefaultColor);
  DefaultColor24.B := GetBValue(DefaultColor);

  SourceBitmap := TBitmap.Create;
  try
    // 変形元ビットマップは DIB Section であることが必要。
    // DDB の可能性があるのでコピーして DIB Sectionに変換する
    SourceBitmap.Assign(OrgBitmap);
    SourceBitmap.HandleType := bmDIB;

    // 変形もとのピクセルのビット数を得る
    GetObject(SourceBitmap.Handle, SizeOf(TDIBSection), @DS);
    BitCount := DS.dsBmih.biBitCount;

    NewBitmap := TBitmap.Create;
    try
      // 新規ビットマップ(変形先)の形式を整える(変形元と同じにする)
      NewBitmap.PixelFormat := SourceBitmap.PixelFormat;
      NewBitmap.Palette := CopyPalette(SourceBitmap.Palette); // Modified 2002.2.27
      NewBitmap.Width := NewWidth;
      NewBitmap.Height := NewHeight;

      // Scanlineをキャッシュする
      SetLength(SourceScanline, SourceBitmap.Height);
      SetLength(DestScanline, NewBitmap.Height);
      for i := 0 to SourceBitmap.Height-1 do
        SourceScanline[i] := SourceBitmap.Scanline[i];
      for i := 0 to NewBitmap.Height-1 do
        DestScanline[i] := NewBitmap.Scanline[i];

      // Width/Height プロパティは遅いのでキャッシュする
      SourceWidth := SourceBitmap.Width;
      SourceHeight := SourceBitmap.Height;

      for Y := 0 to NewBitmap.Height-1 do
      begin
        for X := 0 to NewBitmap.Width-1 do
        begin
          // 変形先の座標から変形元の座標を求める
          SourcePos := TransformFunction(Point(X, Y), p);

          // 得られた座標が変形元のビットマップ内で無いならデフォルト
          // カラーを変形先にセットする。
          if (SourcePos.x < 0) or (SourcePos.x >= SourceWidth) or
             (SourcePos.y < 0) or (SourcePos.y >= SourceHeight) then
            case Bitcount of
              32: PDWordArray(DestScanline[y])^[x]  := DefaultColor;
              24: PTripleArray(DestScanline[y])^[x] := DefaultColor24;
              16: PWordArray(DestScanline[y])^[x]   := DefaultColor;
               8: PByteArray(DestScanline[y])^[x]   := DefaultColor;
               4: begin
                    Bits := DefaultColor and $0f;
                    PByteArray(DestScanline[y])^[x div 2] :=
                      (PByteArray(DestScanline[y])^[x div 2] and
                       not ($f0 shr (4*(x mod 2)))) or
                      (Bits shl (4*(1 - x mod 2)));
                  end;
               1: begin
                    Bits := DefaultColor and $01;
                    PByteArray(DestScanline[y])^[x div 8] :=
                      (PByteArray(DestScanline[y])^[X div 8] and
                       not ($80 shr (x mod 8))) or
                      (Bits shl (7 - X mod 8));
                  end;
            end
          else
          // 得られた座標が変形元のビットマップ内なら、座標の指すピクセルを読み
          // それを変形先にコピーする。
            case Bitcount of
              32: PDWordArray(DestScanline[y])^[x] :=
                    PDWordArray(SourceScanline[SourcePos.y])^[SourcePos.x];
              24: PTripleArray(DestScanline[y])^[x] :=
                    PTripleArray(SourceScanline[SourcePos.y])^[SourcePos.x];
              16: PWordArray(DestScanline[y])^[x] :=
                    PWordArray(SourceScanline[SourcePos.y])^[SourcePos.x];
               8: PByteArray(DestScanline[y])^[x] :=
                    PByteArray(SourceScanline[SourcePos.y])^[SourcePos.X];
               4: begin
                    Bits := PByteArray(SourceScanline[SourcePos.y])^
                            [SourcePos.x div 2];
                    Bits := (Bits shr (4*(1 - SourcePos.x mod 2))) and $0f;
                    PByteArray(DestScanline[y])^[x div 2] :=
                      (PByteArray(DestScanline[y])^[x div 2] and
                       not ($f0 shr (4*(x mod 2)))) or
                      (Bits shl (4*(1 - x mod 2)));
                  end;
               1: begin
                    Bits := PByteArray(SourceScanline[SourcePos.y])^
                            [SourcePos.x div 8];
                    Bits := (Bits shr (7 - SourcePos.x mod 8)) and $01;
                    PByteArray(DestScanline[y])^[x div 8] :=
                      (PByteArray(DestScanline[y])^[X div 8] and
                       not ($80 shr (x mod 8))) or
                      (Bits shl (7 - X mod 8));
                  end;
            end;
        end;
      end;
      result := NewBitmap;
    except
      NewBitmap.Free;
      raise;
    end;
  finally
    SourceBitmap.Free;
  end;
end;

type
  TStretchParams = record
    SourceWidth,  // 変形元ビットマップの大きさ
    SourceHeight,
    DestWidth,    // 変形先ビットマップの大きさ
    DestHeight: Integer;
  end;
  PStretchParams = ^TStretchParams;

// 拡大縮小用 変形元座標計算関数
function StretchTransformFunc(Pos: TPoint; p: Pointer): TPoint;
var
  pParams: PStretchParams;
begin
  pParams := p;

  // ビットマップの大きさの比を使って変形元ビットマップの
  // 座標を求める
  with pParams^ do
    Result := Point(Pos.x * SourceWidth div DestWidth,
                    Pos.y * SourceHeight div DestHeight);
end;

function StretchBitmap(Bitmap: TBitmap;
                       NewWidth,           // 新しいビットマップの大きさ
                       NewHeight: Integer)
                       : TBitmap;
var
  Params: TStretchParams;
begin
  // 変形元、変形さきのビットマップの大きさをセット
  Params.SourceWidth := Bitmap.Width;
  Params.SourceHeight := Bitmap.Height;
  Params.DestWidth := NewWidth;
  Params.DestHeight := NewHeight;

  // StretchTransformFunc を使ってビットマップを変形
  Result := TransformBitmap(Bitmap, NewWidth, NewHeight,
                            StretchTransformFunc,
                            0, @Params);
end;

// ビットマップを回転させる
function RotateBitmap(Bitmap: TBitmap;
                      NewWidth,           // 新しいビットマップの大きさ
                      NewHeight: Integer;
                      DestCenterX,        // 変形先の回転中心
                      DestCenterY,
                      SourceCenterX,      // 変形元の回転中心
                      SourceCenterY: Double;
                      Angle: Double;      // 回転角(時計回り)
                      DefaultColor: Longint) // デフォルトカラー
                      : TBitmap; overload;
begin
  // アフィン変換を使って変形する。
  Result := AffineTransformBitmap(Bitmap, NewWidth, NewHeight,
                                  cos(Angle), -sin(Angle),
                                  sin(Angle), cos(Angle),
                                  SourceCenterX, SourceCenterY,
                                  DestCenterX, DestCenterY,
                                  DefaultColor);
end;

// X' - G = A x (X - E) + B x (Y - F);
// Y' - H = C x (X - E) + D x (Y - F);
//
// X = A' x X' + B' x Y' + E'
// Y = C' x X' + D' x Y' + F'
//
//        D              -B          - D x G + B x H
// A' = -------,  B' = -------, E' = --------------- + E
//      AxD-BxC        AxD-BxC          AxD-BxC
//
//        -C             A            C x G  - A x H
// C' = -------,  D' = -------, F' = ---------------- + F
//      AxD-BxC        AxD-BxC           AxD-BxC

type
  TAffineParams = record
    A, B, C, D, E, F, G, H: Double; // アフィン変換の順方法の係数
    AD, BD, CD, DD, ED, FD: Double; // 逆方向のアフィン変換の係数
    AffineCoffsCached: Boolean;     // 逆方向の係数が順方向の係数から
                                    // 算出済みかを表すフラグ
  end;
  PAffineParams = ^TAffineParams;

// 逆アフィン変換で変形元の座標を算出する
function AffineTransformFunc(Pos: TPoint; p: Pointer): TPoint;
var
  pParams: PAffineParams;
begin
  pParams := p;

  // 逆方向のアフィン変換用係数が未計算なら計算
  if not pParams.AffineCoffsCached then
    with pParams^ do
    begin
      AD := D / (A*D-B*C); BD := -B / (A*D-B*C);
      CD := - C / (A*D-B*C); DD := A / (A*D-B*C);
      ED := (-D*G + B*H) / (A*D-B*C) + E;
      FD := (C*G - A*H) / (A*D-B*C) + F;
      AffineCoffsCached := True;
    end;

  with pParams^ do
  Result := Point(Round(Pos.x * AD + Pos.y * BD + ED),
                  Round(Pos.x * CD + Pos.y * DD + FD));
end;

// アフィン変換でビットマップを変形する
function AffineTransformBitmap(Bitmap: TBitmap;
                               NewWidth,           // 新しいビットマップの大きさ
                               NewHeight: Integer;
                               A, B, C, D,         // アフィン変換の係数
                               E, F, G, H: Double;
                               DefaultColor: Longint) // デフォルトカラー
                               : TBitmap;
var
  Params: TAffineParams;
begin
  // アフィン変換の係数をセットする
  Params.A := A; Params.B := B; Params.C := C;
  Params.D := D; Params.E := E; Params.F := F;
  Params.G := G; Params.H := H;
  Params.AffineCoffsCached := False;

  // AffineTransformFunc でビットマップを変形する。
  Result := TransformBitmap(Bitmap, NewWidth, NewHeight,
                            AffineTransformFunc,
                            DefaultColor, @Params);
end;

type
  THorzMirrorParams = record
    SourceWidth: Integer;    // 変形元のビットマップの幅
  end;
  PHorzMirrorParams = ^THorzMirrorParams;

// 横方向ミラー用の変形元座標計算関数
function HorzMirrorFunc(Pos: TPoint; p: Pointer): TPoint;
begin
  Result := Point(PHorzMirrorParams(p).SourceWidth -1 - Pos.X, Pos.Y);
end;

// ビットマップを横方向に裏返す。
function HorzMirrorBitmap(Bitmap: TBitmap): TBitmap;
var
  Params: THorzMirrorParams;
begin
  Params.SourceWidth := Bitmap.Width;

  // HorzMirrorFunc を使って変形する
  Result := TransformBitmap(Bitmap, Bitmap.Width, Bitmap.Height,
                            HorzMirrorFunc,
                            0, @Params);
end;

type
  TVertMirrorParams = record
    SourceHeight: Integer;  // 変換元ビットマップの高さ
  end;
  PVertMirrorParams = ^TVertMirrorParams;

// 縦方向ミラー用変形元座標計算関数
function VertMirrorFunc(Pos: TPoint; p: Pointer): TPoint;
begin
  Result := Point(Pos.X, PVertMirrorParams(p).SourceHeight -1 - Pos.Y);
end;

// ビットマップを縦方向に裏返す
function VertMirrorBitmap(Bitmap: TBitmap): TBitmap;
var
  Params: TVertMirrorParams;
begin
  Params.SourceHeight := Bitmap.Height;

  // VertMirrorFunc を使って変形する
  Result := TransformBitmap(Bitmap, Bitmap.Width, Bitmap.Height,
                            VertMirrorFunc,
                            0, @Params);
end;

type
  TRotateParams = record
    SourceWidth : Integer;     // 変形元ビットマップの幅
    SourceHeight: Integer;     // 変形元ビットマップの高さ
    RotateAngle: TRotateAngle; // 回転描く(反時計回り)
  end;
  PRotateParams = ^TRotateParams;

// 回転用 変形元座標計算関数
function RotateFunc(Pos: TPoint; p: Pointer): TPoint;
var
  pParams: PRotateParams;
begin
  pParams := p;
  // 回転角と変形先座標から変形元座標を計算する
  with pParams^ do
    case RotateAngle of
      raAngle90:  Result := Point(Pos.Y, SourceHeight-1-Pos.X);
      raAngle180: Result := Point(SourceWidth-1-Pos.X, SourceHeight-1-Pos.Y);
      raAngle270: Result := Point(SourceWidth-1-Pos.Y, Pos.X);
    end;
end;

// ビットマップを回転する。
function RotateBitmap(Bitmap: TBitmap;
                      RotateAngle: TRotateAngle) // 回転角(時計回り)
                      : TBitmap; overload;
var
  Params: TRotateParams;
begin
  Params.SourceWidth := Bitmap.Width;
  Params.SourceHeight := Bitmap.Height;
  Params.RotateAngle := RotateAngle;

  // RotateFunc を使ってビットマップを回転させる
  if RotateAngle = raAngle180 then
    Result := TransformBitmap(Bitmap, Bitmap.Width, Bitmap.Height,
                              RotateFunc,
                              0, @Params)
  else
    Result := TransformBitmap(Bitmap, Bitmap.Height, Bitmap.Width,
                              RotateFunc,
                              0, @Params);
end;


//////////////////////
//
// ここから TBitBitmap 用
//

//ビットマップを変形する
function TransformBitmap(
  OrgBitmap: TBigBitmap;                       // 変形元ビットマップ
  NewWidth, NewHeight: Integer;                // 新ビットマップの大きさ
  TransFormFunction: TBitmapTransFormFunction; // 変形元座標計算関数
  DefaultColor: Longint;                       // デフォルトカラー
  p: Pointer                                   // オプショナルパラメータ
  ): TBigBitmap;

var
  NewBitmap: TBigBitmap;  // 新規に作成するビットマップ
  X, Y: Integer;          // 新規ビットマップ上での座標
  //スキャンラインのキャッシュ
  SourceScanline, DestScanline: array of Pointer;
  SourcePos: TPoint;      // SoucreBitmap上での座標
  // SourceBitmap の大きさ
  SourceWidth, SourceHeight: Integer;
  Bits: Byte;             // 1bpp, 4bpp ピクセル操作のためのワーク
  DefaultColor24: TTriple;// 24bpp の場合のデフォルトカラー
  PixelFormat: TBigBitmapPixelFormat;
  i: Integer;
begin
  // 24bpp のデフォルトカラーを作る
  DefaultColor24.R := GetRValue(DefaultColor);
  DefaultColor24.G := GetGValue(DefaultColor);
  DefaultColor24.B := GetBValue(DefaultColor);

  NewBitmap := TBigBitmap.Create;
  try
    // 新規ビットマップ(変形先)の形式を整える(変形元と同じにする)
    NewBitmap.PixelFormat := OrgBitmap.PixelFormat;
    NewBitmap.Width := NewWidth;
    NewBitmap.Height := NewHeight;
    NewBitmap.Palette := CopyPalette(OrgBitmap.Palette); // modified 2002.2.27

    // Scanlineをキャッシュする
    SetLength(SourceScanline, OrgBitmap.Height);
    SetLength(DestScanline, NewBitmap.Height);
    for i := 0 to OrgBitmap.Height-1 do
      SourceScanline[i] := OrgBitmap.Scanline[i];
    for i := 0 to NewBitmap.Height-1 do
      DestScanline[i] := NewBitmap.Scanline[i];

    // Width/Height プロパティは遅いのでキャッシュする
    SourceWidth := OrgBitmap.Width;
    SourceHeight := OrgBitmap.Height;

    // PixelFormat もキャッシュする
    PixelFormat := OrgBitmap.PixelFormat;

    for Y := 0 to NewBitmap.Height-1 do
    begin
      for X := 0 to NewBitmap.Width-1 do
      begin
        // 変形先の座標から変形元の座標を求める
        SourcePos := TransformFunction(Point(X, Y), p);

        // 得られた座標が変形元のビットマップ内で無いならデフォルト
        // カラーを変形先にセットする。
        if (SourcePos.x < 0) or (SourcePos.x >= SourceWidth) or
           (SourcePos.y < 0) or (SourcePos.y >= SourceHeight) then
          case PixelFormat of
          bbpf24bit: PTripleArray(DestScanline[y])^[x] := DefaultColor24;
          bbpf8bit:  PByteArray(DestScanline[y])^[x]   := DefaultColor;
          bbpf4bit:
            begin
              Bits := DefaultColor and $0f;
              PByteArray(DestScanline[y])^[x div 2] :=
                (PByteArray(DestScanline[y])^[x div 2] and
                 not ($f0 shr (4*(x mod 2)))) or
                (Bits shl (4*(1 - x mod 2)));
            end;
          bbpf1bit:
            begin
              Bits := DefaultColor and $01;
              PByteArray(DestScanline[y])^[x div 8] :=
                (PByteArray(DestScanline[y])^[X div 8] and
                 not ($80 shr (x mod 8))) or
                (Bits shl (7 - X mod 8));
            end;
          end
        else
        // 得られた座標が変形元のビットマップ内なら、座標の指すピクセルを読み
        // それを変形先にコピーする。
          case PixelFormat of
            bbpf24bit: PTripleArray(DestScanline[y])^[x] :=
                         PTripleArray(SourceScanline[SourcePos.y])^[SourcePos.x];
            bbpf8bit:  PByteArray(DestScanline[y])^[x] :=
                         PByteArray(SourceScanline[SourcePos.y])^[SourcePos.X];
            bbpf4bit:
              begin
                Bits := PByteArray(SourceScanline[SourcePos.y])^
                        [SourcePos.x div 2];
                Bits := (Bits shr (4*(1 - SourcePos.x mod 2))) and $0f;
                PByteArray(DestScanline[y])^[x div 2] :=
                  (PByteArray(DestScanline[y])^[x div 2] and
                   not ($f0 shr (4*(x mod 2)))) or
                  (Bits shl (4*(1 - x mod 2)));
              end;
            bbpf1bit:
              begin
                Bits := PByteArray(SourceScanline[SourcePos.y])^
                        [SourcePos.x div 8];
                Bits := (Bits shr (7 - SourcePos.x mod 8)) and $01;
                PByteArray(DestScanline[y])^[x div 8] :=
                  (PByteArray(DestScanline[y])^[X div 8] and
                   not ($80 shr (x mod 8))) or
                  (Bits shl (7 - X mod 8));
              end;
          end;
      end;
    end;
    result := NewBitmap;
  except
    NewBitmap.Free;
    raise;
  end;
end;

// ビットマップ拡大縮小する
function StretchBitmap(Bitmap: TBigBitmap;
                          NewWidth, NewHeight: Integer) // 新ビットマップの大きさ
                          : TBigBitmap;
var
  Params: TStretchParams;
begin
  Params.SourceWidth := Bitmap.Width;
  Params.SourceHeight := Bitmap.Height;
  Params.DestWidth := NewWidth;
  Params.DestHeight := NewHeight;

  // StretchTransformFunc を使って変形する
  Result := TransformBitmap(Bitmap, NewWidth, NewHeight,
                            StretchTransformFunc,
                            0, @Params);
end;

// ビットマップを回転させる
function RotateBitmap(Bitmap: TBigBitmap;
                      NewWidth, NewHeight: Integer;    //新ビットマップの大きさ
                      DestCenterX,            // 変形先の回転中心
                      DestCenterY,
                      SourceCenterX,          // 変形元の回転中心
                      SourceCenterY: Double;
                      Angle: Double;          // 回転角(時計回り)
                      DefaultColor: Longint)  // デフォルトカラー
                      : TBigBitmap;
begin
  Result := AffineTransformBitmap(Bitmap, NewWidth, NewHeight,
                                  cos(Angle), -sin(Angle),
                                  sin(Angle), cos(Angle),
                                  SourceCenterX, SourceCenterY,
                                  DestCenterX, DestCenterY,
                                  DefaultColor);
end;

function RotateBitmap(Bitmap: TBigBitmap;
                         RotateAngle: TRotateAngle) // 回転の指定
                         : TBigBitmap;
var
  Params: TRotateParams;
begin
  Params.SourceWidth := Bitmap.Width;
  Params.SourceHeight := Bitmap.Height;
  Params.RotateAngle := RotateAngle;

  // RotateFunc を使ってビットマップを回転させる
  if RotateAngle = raAngle180 then
    Result := TransformBitmap(Bitmap, Bitmap.Width, Bitmap.Height,
                              RotateFunc,
                              0, @Params)
  else
    Result := TransformBitmap(Bitmap, Bitmap.Height, Bitmap.Width,
                              RotateFunc,
                              0, @Params);
end;

// ビットマップをアフィン変換する
function AffineTransformBitmap(Bitmap: TBigBitmap;
                               NewWidth,           // 新しいビットマップの大きさ
                               NewHeight: Integer;
                               A, B, C, D,         // アフィン変換の係数
                               E, F, G, H: Double;
                               DefaultColor: Longint) // デフォルトカラー
                               : TBigBitmap;
var
  Params: TAffineParams;
begin
  // アフィン変換の係数をセットする
  Params.A := A; Params.B := B; Params.C := C;
  Params.D := D; Params.E := E; Params.F := F;
  Params.G := G; Params.H := H;
  Params.AffineCoffsCached := False;

  // AffineTransformFunc でビットマップを変形する。
  Result := TransformBitmap(Bitmap, NewWidth, NewHeight,
                            AffineTransformFunc,
                            DefaultColor, @Params);
end;

// ビットマップを横方向にミラー反転させる
function HorzMirrorBitmap(Bitmap: TBigBitmap): TBigBitmap;
var
  Params: THorzMirrorParams;
begin
  Params.SourceWidth := Bitmap.Width;

  // HorzMirrorFunc を使って変形する
  Result := TransformBitmap(Bitmap, Bitmap.Width, Bitmap.Height,
                            HorzMirrorFunc,
                            0, @Params);
end;

// ビットマップを縦方向にミラー反転させる。
function VertMirrorBitmap(Bitmap: TBigBitmap): TBigBitmap;
var
  Params: TVertMirrorParams;
begin
  Params.SourceHeight := Bitmap.Height;

  // VertMirrorFunc を使って変形する
  Result := TransformBitmap(Bitmap, Bitmap.Width, Bitmap.Height,
                            VertMirrorFunc,
                            0, @Params);
end;



////////////////////
//
//  ここから美しく拡大縮小するためのルーチン群
//

function Enlarge(Bitmap: TBitmap; Width, Height: Integer): TBitmap;
type
  TDoubleTriple = record
    B, G, R: Double;
  end;
var NewBitmap, SourceBitmap: TBitmap;
    // 変換先の x, y 座標値
    x, y: Integer;
    // 変換元のビットマップの大きさ
    SourceWidth, SourceHeight: Integer;
    // 拡大率の逆数
    XRatio, YRatio, Temp: Double;
    // x, y を変換元に投影した時の　近傍のピクセル4点
    a, b, c, d: TTriple;
    // 近傍のピクセル4点から求めた Bi-Linear の係数
    p, q, r, s: TDoubleTriple;
    // 変換元、変換先のスキャンラインポインタのキャッシュ
    SourceScans, NewScans: array of PTripleArray;
    // スキャンラインへのポインタ
    pSourceScan1, pSourceScan2, pNewScan: PTripleArray;
    // x, y を変換元へ投影したときの　座標値の小数部
    FracX, FracY: Extended;
    // x, y を変換元へ投影したときの　座標値の整数部
    IntX, IntY: Integer;

    i: Integer;
begin
  SourceWidth := Bitmap.Width; SourceHeight := Bitmap.Height;
  assert((SourceWidth > 0) and (SourceHeight > 0));
  XRatio := SourceWidth / Width;
  YRatio := SourceHeight / Height;
  NewBitmap := TBitmap.Create;
  try
    // 変換先 ビットマップを作る
    NewBitmap.PixelFormat := pf24bit;
    NewBitmap.Width := Width; NewBitmap.Height := Height;

    // 変換元をフルカラーにする
    SourceBitmap := TBitmap.Create;
    try
      SourceBitmap.Assign(Bitmap);
      SourceBitmap.PixelFormat := pf24Bit;

      // スキャンラインポインタのキャッシュを作る
      SetLength(SourceScans, SourceHeight);
      SetLength(NewScans, Height);

      for i := 0 to SourceHeight-1 do
        SourceScans[i] := SourceBitmap.ScanLine[i];

      for i := 0 to Height-1 do
        NewScans[i] := NewBitmap.Scanline[i];


      for y := 0 to Height-1 do begin
        // 変換先スキャンラインポインタを得る
        pNewScan := NewScans[y];

        // y を変換元に投影する
        Temp := (y+0.5) * YRatio - 0.5;
        IntY := floor(Temp);
        FracY := Temp - IntY;

        // IntY から該当するスキャンラインと
        // その次のスキャンラインを求める
        // ビットマップの端を考慮する。
        if IntY < 0  then
          pSourceScan1:= SourceScans[0]
        else
          pSourceScan1:= SourceScans[IntY];
        if IntY + 1 > SourceHeight-1 then
          pSourceScan2 := SourceScans[SourceHeight-1]
        else
          pSourceScan2 := SourceScans[IntY+1];

        for x := 0 to Width-1 do begin

          // x を変換元に投影する
          Temp := (x+0.5) * XRatio - 0.5;
          IntX := Floor(Temp);
          FracX := Temp - IntX;

          // IntX, IntY から、近傍の4ピクセルを選ぶ
          // ビットマップの端を考慮する
          if IntX < 0 then begin
            a := pSourceScan1[0];
            c := pSourceScan2[0]
          end
          else begin
            a := pSourceScan1[IntX];
            c := pSourceScan2[IntX];
          end;

          if IntX+1 > SourceWidth-1 then begin
            b := pSourceScan1[SourceWidth-1];
            d := pSourceScan2[SourceWidth-1];
          end
          else begin
            b := pSourceScan1[IntX+1];
            d := pSourceScan2[IntX+1];
          end;

          // Bi-Linear の係数を求める
          p.R := b.R - a.R;
          s.R := a.R;
          r.R := c.R - a.R;
          q.R := d.R + a.R - b.R - c.R;
          p.G := b.G - a.G;
          s.G := a.G;
          r.G := c.G - a.G;
          q.G := d.G + a.G - b.G - c.G;
          p.B := b.B - a.B;
          s.B := a.B;
          r.B := c.B - a.B;
          q.B := d.B + a.B - b.B - c.B;

          // RGB 値を計算し、変換先に代入する
          pNewScan[x].R := Round(p.R*FracX + q.R*FracX*FracY + r.R*FracY + s.R);
          pNewScan[x].G := Round(p.G*FracX + q.G*FracX*FracY + r.G*FracY + s.G);
          pNewScan[x].B := Round(p.B*FracX + q.B*FracX*FracY + r.B*FracY + s.B);
        end;
      end;
    finally
      SourceBitmap.Free;
    end;
  except
    NewBitmap.Free;
    Raise;
  end;
  Result := NewBitmap;
end;


function Shrink(Bitmap: TBitmap; Width, Height: Integer): TBitmap;
type
  TDoubleTriple = record
    B, G, R: Double;
  end;
var NewBitmap, SourceBitmap: TBitmap;
    // 変換先の x, y 座標値
    x, y: Integer;
    // 変換元のビットマップの大きさ
    SourceWidth, SourceHeight: Integer;
    // 変換元に投影された変換先ピクセルの位置
    RectTop, RectLeft, RectRight, RectBottom: Double;
    // 変換元に投影された変換先ピクセルと変換元ピクセルが
    // 交わっている部分の大きさ
    w, h: Double;
    // 縮小率(面積比)
    Ratio: Single;
    // スキャンラインポインタ
    pSourceScan, pNewScan: PTripleArray;
    // X方向、Y方向の縮小率
    XRatio, YRatio: Double;
    // スキャンラインポインタのキャッシュ
    SourceScans, NewScans: array of PTripleArray;
    // 変換先のピクセル地
    Pixel: TDoubleTriple;
    // 変換もとのピクセル値
    SourcePixel: TTriple;
    i, j: Integer;
begin
  SourceWidth := Bitmap.Width; SourceHeight := Bitmap.Height;
  assert((SourceWidth > 0) and (SourceHeight > 0));
  Ratio := SourceWidth * Sourceheight / Width / Height;
  XRatio := SourceWidth / Width;
  YRatio := SourceHeight / Height;
  NewBitmap := TBitmap.Create;
  try
    // 変換先 ビットマップを作る
    NewBitmap.PixelFormat := pf24bit;
    NewBitmap.Width := Width; NewBitmap.Height := Height;

    // 変換元をフルカラーにする
    SourceBitmap := TBitmap.Create;
    try
      SourceBitmap.Assign(Bitmap);
      SourceBitmap.PixelFormat := pf24Bit;

      // スキャンラインポインタのキャッシュを作る
      SetLength(SourceScans, SourceHeight);
      SetLength(NewScans, Height);

      for i := 0 to SourceHeight-1 do
        SourceScans[i] := SourceBitmap.ScanLine[i];

      for i := 0 to Height-1 do
        NewScans[i] := NewBitmap.Scanline[i];

      for y := 0 to Height-1 do begin
        // 変換先スキャンラインポインタを得る
        pNewScan := NewScans[y];
        for x := 0 to Width-1 do begin
          // 変換先ピクセルを変換元に投影する。
          RectLeft   := x * XRatio;
          RectTop    := y * YRatio;
          RectRight  := (x+1) * XRatio  - 0.000001;
          RectBottom := (y+1) * YRatio - 0.000001;

          // 変換元に投影された変換先ピクセルと交わっている
          // 変換元ピクセルを選び出し積分する
          Pixel.R := 0; Pixel.G := 0; Pixel.B := 0;

          for j := floor(RectTop) to floor(RectBottom) do begin
            pSourceScan:= SourceScans[j];
            for i := floor(RectLeft) to floor(RectRight) do begin
              SourcePixel := pSourceScan[i];

              // 投影されたピクセルと変換元ピクセルの交わっている
              // 部分の大きさを求める
              if (RectLeft < i) and ((i+1) < RectRight) then
                w := 1
              else if (i <= RectLeft) and ((i+1) < RectRight) then
                w := 1 - (RectLeft - i)
              else if (RectLeft < i) and (RectRight <= (i+1)) then
                w := RectRight - i
              else
                w := RectRight - RectLeft;

              if (RectTop < j) and ((j+1) < RectBottom) then
                h := 1
              else if (j <= RectTop) and ((j+1) < RectBottom) then
                h := 1 - (RectTop - j)
              else if (RectTop < j) and (RectBottom < (j+1)) then
                h := RectBottom - j
              else
                h := RectBottom - RectTop;

              // 変換元　1 ピクセル分　積分
              Pixel.R := Pixel.R + w * h * SourcePixel.R;
              Pixel.G := Pixel.G + w * h * SourcePixel.G;
              Pixel.B := Pixel.B + w * h * SourcePixel.B;
            end;
          end;
          // 積分値から平均値を求め変換先に代入する
          pNewScan[x].R := Round(Pixel.R / Ratio);
          pNewScan[x].G := Round(Pixel.G / Ratio);
          pNewScan[x].B := Round(Pixel.B / Ratio);
        end;
      end;
    finally
      SourceBitmap.Free;
    end;
  except
    NewBitmap.Free;
    Raise;
  end;
  Result := NewBitmap;
end;


function Stretch(Bitmap: TBitmap; Width, Height: Integer): TBitmap;
type
  TDoubleTriple = record
    B, G, R: Double;
  end;
var NewBitmap, SourceBitmap: TBitmap;
    // 変換先の x, y 座標値
    x, y: Integer;
    // 変換元のビットマップの大きさ
    SourceWidth, SourceHeight: Integer;
    // 変換元に投影された変換先ピクセルの位置
    RectTop, RectLeft, RectRight, RectBottom: Double;
    // 変換元に投影された変換先ピクセルと変換元ピクセルが
    // 交わっている部分の大きさ
    w, h: Double;
    // 変換元に投影された変換先ピクセルと変換元ピクセルが
    // 交わっている部分の中心位置。変換元ピクセルの左上が基準
    XAve, YAve: Double;
    // x, y を変換元に投影した時の　近傍のピクセル4点
    a, b, c, d: TTriple;
    // 近傍のピクセル4点から求めた Bi-Linear の係数
    p, q, r, s: TDoubleTriple;
    // 拡大率の逆数(面積比)
    Ratio: Double;
    // スキャンラインポインタ
    pSourceScan1, pSourceScan2, pNewScan: PTripleArray;
    // X方向、Y方向の拡大率の逆数。
    XRatio, YRatio: Double;
    // スキャンラインのキャッシュ
    SourceScans, NewScans: array of PTripleArray;
    // 変換先のピクセル値
    Pixel: TDoubleTriple;

    i, j: Integer;
begin
  SourceWidth := Bitmap.Width; SourceHeight := Bitmap.Height;
  assert((SourceWidth > 0) and (SourceHeight > 0));
  Ratio := SourceWidth * Sourceheight / Width / Height;
  XRatio := SourceWidth / Width;
  YRatio := SourceHeight / Height;

  // 変換先 ビットマップを作る
  NewBitmap := TBitmap.Create;
  try
    NewBitmap.PixelFormat := pf24bit;
    NewBitmap.Width := Width; NewBitmap.Height := Height;

    // 変換元をフルカラーにする
    SourceBitmap := TBitmap.Create;
    try
      SourceBitmap.Assign(Bitmap);
      SourceBitmap.PixelFormat := pf24Bit;

      // スキャンラインポインタのキャッシュを作る
      SetLength(SourceScans, SourceHeight);
      SetLength(NewScans, Height);

      for i := 0 to SourceHeight-1 do
        SourceScans[i] := SourceBitmap.ScanLine[i];

      for i := 0 to Height-1 do
        NewScans[i] := NewBitmap.Scanline[i];

      for y := 0 to Height-1 do begin
        // 変換先スキャンラインポインタを得る
        pNewScan := NewScans[y];

        for x := 0 to Width-1 do begin

          // 変換先ピクセルを変換元に投影する(0.5 づつずらす)。
          RectLeft   := x * XRatio - 0.5;
          RectTop    := y * YRatio - 0.5;
          RectRight  := (x+1) * XRatio  - 0.500001;
          RectBottom := (y+1) * YRatio - 0.500001;

          // 変換元に投影された変換先ピクセルと交わっている
          // 変換元ピクセル間の Bi-Linera 曲面を選び出し積分する
          Pixel.R := 0; Pixel.G := 0; Pixel.B := 0;

          for j := floor(RectTop) to floor(RectBottom) do begin
            // Bi-Linear 曲面の上と下のピクセルのスキャンラインを求める
            // ビットマップの端を考慮
            if j < 0 then
              pSourceScan1:= SourceScans[0]
            else
              pSourceScan1:= SourceScans[j];
            if j+1 > SourceHeight-1 then
              pSourceScan2 := SourceScans[SourceHeight-1]
            else
              pSourceScan2 := SourceScans[j+1];

            for i := floor(RectLeft) to floor(RectRight) do begin

              // Bi-Linear 曲面の4隅のピクセルを得る
              // ビットマップの端を考慮
              if i < 0 then begin
                a := pSourceScan1[0];
                c := pSourceScan2[0];
              end
              else begin
                a := pSourceScan1[i];
                c := pSourceScan2[i];
              end;

              if i+1 > SourceWidth-1 then begin
                b := pSourceScan1[SourceWidth-1];
                d := pSourceScan2[SourceWidth-1];
              end
              else begin
                b := pSourceScan1[i+1];
                d := pSourceScan2[i+1];
              end;

              // Bi-Linear 曲面の係数を計算する。
              p.R := b.R - a.R;
              s.R := a.R;
              r.R := c.R - a.R;
              q.R := d.R + a.R - b.R - c.R;
              p.G := b.G - a.G;
              s.G := a.G;
              r.G := c.G - a.G;
              q.G := d.G + a.G - b.G - c.G;
              p.B := b.B - a.B;
              s.B := a.B;
              r.B := c.B - a.B;
              q.B := d.B + a.B - b.B - c.B;

              //投影されたピクセルと Bi-Linear 曲面の交わっている部分の
              //大きさと中心位置を求める
              if (RectLeft < i) and ((i+1) < RectRight) then begin
                w := 1; XAve := 0.5;
              end
              else if (i <= RectLeft) and ((i+1) < RectRight) then begin
                w := 1 - (RectLeft - i);
                XAve := (RectLeft - i + 1) / 2;
              end
              else if (RectLeft < i) and (RectRight <= (i+1)) then begin
                w := RectRight - i;
                XAve := w / 2;
              end
              else begin
                w := RectRight - RectLeft;
                XAve := ((RectRight - i) + (RectLeft - i)) / 2;
              end;

              if (RectTop < j) and ((j+1) < RectBottom) then begin
                h := 1; YAve := 0.5;
              end
              else if (j <= RectTop) and ((j+1) < RectBottom) then begin
                h := 1 - (RectTop - j);
                YAve := (RectTop - j + 1) / 2;
              end
              else if (RectTop < j) and (RectBottom < (j+1)) then begin
                h := RectBottom - j;
                YAve := h / 2;
              end
              else begin
                h := RectBottom - RectTop;
                YAve := ((RectBottom - j) + (RectTop - j)) / 2;
              end;

              // 投影されたピクセルと Bi-Linear 曲面の交わっている部分を
              // 積分する
              Pixel.R := Pixel.R +
                w * h * (p.R*XAve + q.R*XAve * YAve + r.R*YAve + s.R);
              Pixel.G := Pixel.G +
                w * h * (p.G*XAve + q.G*XAve * YAve + r.G*YAve + s.G);
              Pixel.B := Pixel.B +
                w * h * (p.B*XAve + q.B*XAve * YAve + r.B*YAve + s.B);
            end;
          end;
          // 積分値から平均値を求め変換先に代入する。
          pNewScan[x].R := Round(Pixel.R / Ratio);
          pNewScan[x].G := Round(Pixel.G / Ratio);
          pNewScan[x].B := Round(Pixel.B / Ratio);
        end;
      end;
    finally
      SourceBitmap.Free;
    end;
  except
    NewBitmap.Free;
    Raise;
  end;
  Result := NewBitmap;
end;

////////////
//
// ここから TBigBitmap用

function Enlarge(Bitmap: TBigBitmap; Width, Height: Integer): TBigBitmap;
type
  TDoubleTriple = record
    B, G, R: Double;
  end;

var NewBitmap, SourceBitmap: TBigBitmap;
    // 変換先の x, y 座標値
    x, y: Integer;
    // 変換元のビットマップの大きさ
    SourceWidth, SourceHeight: Integer;
    // 拡大率の逆数
    XRatio, YRatio, Temp: Double;
    // x, y を変換元に投影した時の　近傍のピクセル4点
    a, b, c, d: TTriple;
    // 近傍のピクセル4点から求めた Bi-Linear の係数
    p, q, r, s: TDoubleTriple;
    // 変換元、変換先のスキャンラインポインタのキャッシュ
    SourceScans, NewScans: array of PTripleArray;
    // スキャンラインへのポインタ
    pSourceScan1, pSourceScan2, pNewScan: PTripleArray;
    // x, y を変換元へ投影したときの　座標値の小数部
    FracX, FracY: Extended;
    // x, y を変換元へ投影したときの　座標値の整数部
    IntX, IntY: Integer;

    DrawMode: TBigBitmapDrawMode;
    i: Integer;
begin
  SourceWidth := Bitmap.Width; SourceHeight := Bitmap.Height;
  assert((SourceWidth > 0) and (SourceHeight > 0));
  XRatio := SourceWidth / Width;
  YRatio := SourceHeight / Height;
  NewBitmap := TBigBitmap.Create;
  try
    // 変換先 ビットマップを作る
    NewBitmap.PixelFormat := bbpf24bit;
    NewBitmap.Width := Width; NewBitmap.Height := Height;

    // 変換元をフルカラーにする
    SourceBitmap := TBigBitmap.Create;
    try
      SourceBitmap.PixelFormat := bbpf24Bit;
      SourceBitmap.Width := Bitmap.Width;
      SourceBitmap.Height := Bitmap.Height;
      SourceBitmap.Palette := CopyPalette(Bitmap.Palette);
      DrawMode := Bitmap.DrawMode;
      Bitmap.DrawMode := dmUseBanding;
      try
        SourceBitmap.Canvas.Draw(0, 0, Bitmap);
      finally
        Bitmap.DrawMode := DrawMode;
      end;

      // スキャンラインポインタのキャッシュを作る
      SetLength(SourceScans, SourceHeight);
      SetLength(NewScans, Height);

      for i := 0 to SourceHeight-1 do
        SourceScans[i] := SourceBitmap.ScanLine[i];

      for i := 0 to Height-1 do
        NewScans[i] := NewBitmap.Scanline[i];


      for y := 0 to Height-1 do begin
        // 変換先スキャンラインポインタを得る
        pNewScan := NewScans[y];

        // y を変換元に投影する
        Temp := (y+0.5) * YRatio - 0.5;
        IntY := floor(Temp);
        FracY := Temp - IntY;

        // IntY から該当するスキャンラインと
        // その次のスキャンラインを求める
        // ビットマップの端を考慮する。
        if IntY < 0  then
          pSourceScan1:= SourceScans[0]
        else
          pSourceScan1:= SourceScans[IntY];
        if IntY + 1 > SourceHeight-1 then
          pSourceScan2 := SourceScans[SourceHeight-1]
        else
          pSourceScan2 := SourceScans[IntY+1];

        for x := 0 to Width-1 do begin

          // x を変換元に投影する
          Temp := (x+0.5) * XRatio - 0.5;
          IntX := Floor(Temp);
          FracX := Temp - IntX;

          // IntX, IntY から、近傍の4ピクセルを選ぶ
          // ビットマップの端を考慮する
          if IntX < 0 then begin
            a := pSourceScan1[0];
            c := pSourceScan2[0]
          end
          else begin
            a := pSourceScan1[IntX];
            c := pSourceScan2[IntX];
          end;

          if IntX+1 > SourceWidth-1 then begin
            b := pSourceScan1[SourceWidth-1];
            d := pSourceScan2[SourceWidth-1];
          end
          else begin
            b := pSourceScan1[IntX+1];
            d := pSourceScan2[IntX+1];
          end;

          // Bi-Linear の係数を求める
          p.R := b.R - a.R;
          s.R := a.R;
          r.R := c.R - a.R;
          q.R := d.R + a.R - b.R - c.R;
          p.G := b.G - a.G;
          s.G := a.G;
          r.G := c.G - a.G;
          q.G := d.G + a.G - b.G - c.G;
          p.B := b.B - a.B;
          s.B := a.B;
          r.B := c.B - a.B;
          q.B := d.B + a.B - b.B - c.B;

          // RGB 値を計算し、変換先に代入する
          pNewScan[x].R := Round(p.R*FracX + q.R*FracX*FracY + r.R*FracY + s.R);
          pNewScan[x].G := Round(p.G*FracX + q.G*FracX*FracY + r.G*FracY + s.G);
          pNewScan[x].B := Round(p.B*FracX + q.B*FracX*FracY + r.B*FracY + s.B);
        end;
      end;
    finally
      SourceBitmap.Free;
    end;
  except
    NewBitmap.Free;
    Raise;
  end;
  Result := NewBitmap;
end;


function Shrink(Bitmap: TBigBitmap; Width, Height: Integer): TBigBitmap;
type
  TDoubleTriple = record
    B, G, R: Double;
  end;
var NewBitmap, SourceBitmap: TBigBitmap;
    // 変換先の x, y 座標値
    x, y: Integer;
    // 変換元のビットマップの大きさ
    SourceWidth, SourceHeight: Integer;
    // 変換元に投影された変換先ピクセルの位置
    RectTop, RectLeft, RectRight, RectBottom: Double;
    // 変換元に投影された変換先ピクセルと変換元ピクセルが
    // 交わっている部分の大きさ
    w, h: Double;
    // 縮小率(面積比)
    Ratio: Single;
    // スキャンラインポインタ
    pSourceScan, pNewScan: PTripleArray;
    // X方向、Y方向の縮小率
    XRatio, YRatio: Double;
    // スキャンラインポインタのキャッシュ
    SourceScans, NewScans: array of PTripleArray;
    // 変換先のピクセル地
    Pixel: TDoubleTriple;
    // 変換もとのピクセル値
    SourcePixel: TTriple;
    i, j: Integer;
    DrawMode: TBigBitmapDrawMode;
begin
  SourceWidth := Bitmap.Width; SourceHeight := Bitmap.Height;
  assert((SourceWidth > 0) and (SourceHeight > 0));
  Ratio := SourceWidth * Sourceheight / Width / Height;
  XRatio := SourceWidth / Width;
  YRatio := SourceHeight / Height;
  NewBitmap := TBigBitmap.Create;
  try
    // 変換先 ビットマップを作る
    NewBitmap.PixelFormat := bbpf24bit;
    NewBitmap.Width := Width; NewBitmap.Height := Height;

    // 変換元をフルカラーにする
    SourceBitmap := TBigBitmap.Create;
    try
      SourceBitmap.PixelFormat := bbpf24Bit;
      SourceBitmap.Width := Bitmap.Width;
      SourceBitmap.Height := Bitmap.Height;
      SourceBitmap.Palette := CopyPalette(Bitmap.Palette);
      DrawMode := Bitmap.DrawMode;
      Bitmap.DrawMode := dmUseBanding;
      try
        SourceBitmap.Canvas.Draw(0, 0, Bitmap);
      finally
        Bitmap.DrawMode := DrawMode;
      end;

      // スキャンラインポインタのキャッシュを作る
      SetLength(SourceScans, SourceHeight);
      SetLength(NewScans, Height);

      for i := 0 to SourceHeight-1 do
        SourceScans[i] := SourceBitmap.ScanLine[i];

      for i := 0 to Height-1 do
        NewScans[i] := NewBitmap.Scanline[i];

      for y := 0 to Height-1 do begin
        // 変換先スキャンラインポインタを得る
        pNewScan := NewScans[y];
        for x := 0 to Width-1 do begin
          // 変換先ピクセルを変換元に投影する。
          RectLeft   := x * XRatio;
          RectTop    := y * YRatio;
          RectRight  := (x+1) * XRatio  - 0.000001;
          RectBottom := (y+1) * YRatio - 0.000001;

          // 変換元に投影された変換先ピクセルと交わっている
          // 変換元ピクセルを選び出し積分する
          Pixel.R := 0; Pixel.G := 0; Pixel.B := 0;

          for j := floor(RectTop) to floor(RectBottom) do begin
            pSourceScan:= SourceScans[j];
            for i := floor(RectLeft) to floor(RectRight) do begin
              SourcePixel := pSourceScan[i];

              // 投影されたピクセルと変換元ピクセルの交わっている
              // 部分の大きさを求める
              if (RectLeft < i) and ((i+1) < RectRight) then
                w := 1
              else if (i <= RectLeft) and ((i+1) < RectRight) then
                w := 1 - (RectLeft - i)
              else if (RectLeft < i) and (RectRight <= (i+1)) then
                w := RectRight - i
              else
                w := RectRight - RectLeft;

              if (RectTop < j) and ((j+1) < RectBottom) then
                h := 1
              else if (j <= RectTop) and ((j+1) < RectBottom) then
                h := 1 - (RectTop - j)
              else if (RectTop < j) and (RectBottom < (j+1)) then
                h := RectBottom - j
              else
                h := RectBottom - RectTop;

              // 変換元　1 ピクセル分　積分
              Pixel.R := Pixel.R + w * h * SourcePixel.R;
              Pixel.G := Pixel.G + w * h * SourcePixel.G;
              Pixel.B := Pixel.B + w * h * SourcePixel.B;
            end;
          end;
          // 積分値から平均値を求め変換先に代入する
          pNewScan[x].R := Round(Pixel.R / Ratio);
          pNewScan[x].G := Round(Pixel.G / Ratio);
          pNewScan[x].B := Round(Pixel.B / Ratio);
        end;
      end;
    finally
      SourceBitmap.Free;
    end;
  except
    NewBitmap.Free;
    Raise;
  end;
  Result := NewBitmap;
end;


function Stretch(Bitmap: TBigBitmap; Width, Height: Integer): TBigBitmap;
type
  TDoubleTriple = record
    B, G, R: Double;
  end;
var NewBitmap, SourceBitmap: TBigBitmap;
    // 変換先の x, y 座標値
    x, y: Integer;
    // 変換元のビットマップの大きさ
    SourceWidth, SourceHeight: Integer;
    // 変換元に投影された変換先ピクセルの位置
    RectTop, RectLeft, RectRight, RectBottom: Double;
    // 変換元に投影された変換先ピクセルと変換元ピクセルが
    // 交わっている部分の大きさ
    w, h: Double;
    // 変換元に投影された変換先ピクセルと変換元ピクセルが
    // 交わっている部分の中心位置。変換元ピクセルの左上が基準
    XAve, YAve: Double;
    // x, y を変換元に投影した時の　近傍のピクセル4点
    a, b, c, d: TTriple;
    // 近傍のピクセル4点から求めた Bi-Linear の係数
    p, q, r, s: TDoubleTriple;
    // 拡大率の逆数(面積比)
    Ratio: Double;
    // スキャンラインポインタ
    pSourceScan1, pSourceScan2, pNewScan: PTripleArray;
    // X方向、Y方向の拡大率の逆数。
    XRatio, YRatio: Double;
    // スキャンラインのキャッシュ
    SourceScans, NewScans: array of PTripleArray;
    // 変換先のピクセル値
    Pixel: TDoubleTriple;

    DrawMode: TBigBitmapDrawMode;
    i, j: Integer;
begin
  SourceWidth := Bitmap.Width; SourceHeight := Bitmap.Height;
  assert((SourceWidth > 0) and (SourceHeight > 0));
  Ratio := SourceWidth * Sourceheight / Width / Height;
  XRatio := SourceWidth / Width;
  YRatio := SourceHeight / Height;

  // 変換先 ビットマップを作る
  NewBitmap := TBigBitmap.Create;
  try
    NewBitmap.PixelFormat := bbpf24bit;
    NewBitmap.Width := Width; NewBitmap.Height := Height;

    // 変換元をフルカラーにする
    SourceBitmap := TBigBitmap.Create;
    try
      SourceBitmap.PixelFormat := bbpf24Bit;
      SourceBitmap.Width := Bitmap.Width;
      SourceBitmap.Height := Bitmap.Height;
      SourceBitmap.Palette := CopyPalette(Bitmap.Palette);
      DrawMode := Bitmap.DrawMode;
      Bitmap.DrawMode := dmUseBanding;
      try
        SourceBitmap.Canvas.Draw(0, 0, Bitmap);
      finally
        Bitmap.DrawMode := DrawMode;
      end;

      // スキャンラインポインタのキャッシュを作る
      SetLength(SourceScans, SourceHeight);
      SetLength(NewScans, Height);

      for i := 0 to SourceHeight-1 do
        SourceScans[i] := SourceBitmap.ScanLine[i];

      for i := 0 to Height-1 do
        NewScans[i] := NewBitmap.Scanline[i];

      for y := 0 to Height-1 do begin
        // 変換先スキャンラインポインタを得る
        pNewScan := NewScans[y];

        for x := 0 to Width-1 do begin

          // 変換先ピクセルを変換元に投影する(0.5 づつずらす)。
          RectLeft   := x * XRatio - 0.5;
          RectTop    := y * YRatio - 0.5;
          RectRight  := (x+1) * XRatio  - 0.500001;
          RectBottom := (y+1) * YRatio - 0.500001;

          // 変換元に投影された変換先ピクセルと交わっている
          // 変換元ピクセル間の Bi-Linera 曲面を選び出し積分する
          Pixel.R := 0; Pixel.G := 0; Pixel.B := 0;

          for j := floor(RectTop) to floor(RectBottom) do begin
            // Bi-Linear 曲面の上と下のピクセルのスキャンラインを求める
            // ビットマップの端を考慮
            if j < 0 then
              pSourceScan1:= SourceScans[0]
            else
              pSourceScan1:= SourceScans[j];
            if j+1 > SourceHeight-1 then
              pSourceScan2 := SourceScans[SourceHeight-1]
            else
              pSourceScan2 := SourceScans[j+1];

            for i := floor(RectLeft) to floor(RectRight) do begin

              // Bi-Linear 曲面の4隅のピクセルを得る
              // ビットマップの端を考慮
              if i < 0 then begin
                a := pSourceScan1[0];
                c := pSourceScan2[0];
              end
              else begin
                a := pSourceScan1[i];
                c := pSourceScan2[i];
              end;

              if i+1 > SourceWidth-1 then begin
                b := pSourceScan1[SourceWidth-1];
                d := pSourceScan2[SourceWidth-1];
              end
              else begin
                b := pSourceScan1[i+1];
                d := pSourceScan2[i+1];
              end;

              // Bi-Linear 曲面の係数を計算する。
              p.R := b.R - a.R;
              s.R := a.R;
              r.R := c.R - a.R;
              q.R := d.R + a.R - b.R - c.R;
              p.G := b.G - a.G;
              s.G := a.G;
              r.G := c.G - a.G;
              q.G := d.G + a.G - b.G - c.G;
              p.B := b.B - a.B;
              s.B := a.B;
              r.B := c.B - a.B;
              q.B := d.B + a.B - b.B - c.B;

              //投影されたピクセルと Bi-Linear 曲面の交わっている部分の
              //大きさと中心位置を求める
              if (RectLeft < i) and ((i+1) < RectRight) then begin
                w := 1; XAve := 0.5;
              end
              else if (i <= RectLeft) and ((i+1) < RectRight) then begin
                w := 1 - (RectLeft - i);
                XAve := (RectLeft - i + 1) / 2;
              end
              else if (RectLeft < i) and (RectRight <= (i+1)) then begin
                w := RectRight - i;
                XAve := w / 2;
              end
              else begin
                w := RectRight - RectLeft;
                XAve := ((RectRight - i) + (RectLeft - i)) / 2;
              end;

              if (RectTop < j) and ((j+1) < RectBottom) then begin
                h := 1; YAve := 0.5;
              end
              else if (j <= RectTop) and ((j+1) < RectBottom) then begin
                h := 1 - (RectTop - j);
                YAve := (RectTop - j + 1) / 2;
              end
              else if (RectTop < j) and (RectBottom < (j+1)) then begin
                h := RectBottom - j;
                YAve := h / 2;
              end
              else begin
                h := RectBottom - RectTop;
                YAve := ((RectBottom - j) + (RectTop - j)) / 2;
              end;

              // 投影されたピクセルと Bi-Linear 曲面の交わっている部分を
              // 積分する
              Pixel.R := Pixel.R +
                w * h * (p.R*XAve + q.R*XAve * YAve + r.R*YAve + s.R);
              Pixel.G := Pixel.G +
                w * h * (p.G*XAve + q.G*XAve * YAve + r.G*YAve + s.G);
              Pixel.B := Pixel.B +
                w * h * (p.B*XAve + q.B*XAve * YAve + r.B*YAve + s.B);
            end;
          end;
          // 積分値から平均値を求め変換先に代入する。
          pNewScan[x].R := Round(Pixel.R / Ratio);
          pNewScan[x].G := Round(Pixel.G / Ratio);
          pNewScan[x].B := Round(Pixel.B / Ratio);
        end;
      end;
    finally
      SourceBitmap.Free;
    end;
  except
    NewBitmap.Free;
    Raise;
  end;
  Result := NewBitmap;
end;

function BitmapFilter(Bitmap: TBitmap; Filter: TFilterProc;
                      pData: Pointer): TBitmap;
var MatSave,            // 11ライン分のScanlineを保持するバッファ
    Mat: TTripleMatrix; // ピクセルを受け取る 11x11 のマトリックス
    i: Integer;
    x, y: Integer;               // 座標
    NewBitmap: TBitmap;          // 作成するビットマップ
    DestLine: PTripleArray;      // 新しいビットマップのスキャンライン
    LineSize, BufSize: Integer;  // 行サイズとバッファサイズ
begin
  // BitmapFilter は 24bpp しかサポートしません。
  if Bitmap.PixelFormat <> Pf24Bit then
    Raise Exception.Create('BitmapFiletr accepts only 24Bit DIB');


  // １ライン分ピクセルデータを保持するためのバッファ長を計算します。
  // 10足しているのは、マトリックスがビットマップからはみ出すことを
  // 考慮しているからです。
  BufSize := (Bitmap.Width + 10) * 3;
  LineSize := Bitmap.Width * 3;

  // マトリックスをクリア
  FillChar(Mat, SizeOf(Mat), 0);

  // 新しいビットマップを作る
  NewBitmap := TBitmap.Create;
  try
    NewBitmap.Width := Bitmap.Width; NewBitmap.Height := Bitmap.Height;
    NewBitmap.PixelFormat := pf24bit;

    try
      // MatSvae を作成する。MaSaveはビットマップの11ライン分の
      // スキャンラインを保持する。MatSave の各行は ビットマップの幅+10
      // ピクセル分の大きさで、6ピクセル目からビットマップの
      // スキャンラインをコピーする。つまり前後5ピクセルは常に０になる
      // MatSave[0][0] は6ライン目の6ピクセル目をアクセスすることになる。
      for i := -5 to 5 do MatSave[i] := Nil;
      for i:= -5 to 5  do begin
        GetMem(MatSave[i], BufSize);
        FillChar(MatSave[i]^, BufSize, 0);
        if (i < 0) or (i >= Bitmap.Height) then begin
        end
        else begin
          System.Move(Bitmap.ScanLine[i]^, MatSave[i][0], LineSize);
        end;
      end;

      for y := 0 to Bitmap.Height-1 do begin
        DestLine := NewBitmap.Scanline[y];
        Mat := MatSave;
        for x := 0 to Bitmap.Width-1 do begin
          // フィルタの演算処理を呼ぶ
          DestLine[x] := Filter(x, y, Mat, pData);
          // マトリックスの行ポインタを１ピクセル分ずらす
          for i := -5 to 5 do Mat[i] := PTriples(LongInt(Mat[i])+3);
        end;

        // MatSave の内容を1行分上にスクロールする
        FreeMem(MatSave[-5]);
        MatSave[-5] := Nil;

        for i := -5 to 4 do MatSave[i] := MatSave[i+1];
        MatSave[5] := Nil;

        //最下行に元のビットマップからスキャンラインを読み込む
        GetMem(MatSave[5], BufSize);
        FillChar(MatSave[5]^, BufSize, 0);

        if y + 6 < Bitmap.Height then begin
          System.Move(Bitmap.ScanLine[y+6]^, MatSave[5][0], LineSize);
        end;
      end;
    finally
      for i := -5 to 5 do
        if MatSave[i] <> Nil then
          FreeMem(MatSave[i]);
    end;
  except
    NewBitmap.Free;
    raise;
  end;

  Result := NewBitmap;
end;

function BitmapFilter(Bitmap: TBigBitmap; Filter: TFilterProc;
                      pData: Pointer): TBigBitmap;
var MatSave,            // 11ライン分のScanlineを保持するバッファ
    Mat: TTripleMatrix; // ピクセルを受け取る 11x11 のマトリックス
    i: Integer;
    x, y: Integer;               // 座標
    NewBitmap: TBigBitmap;       // 作成するビットマップ
    DestLine: PTripleArray;      // 新しいビットマップのスキャンライン
    LineSize, BufSize: Integer;  // 行サイズとバッファサイズ
begin
  // BitmapFilter は 24bpp しかサポートしません。
  if Bitmap.PixelFormat <> bbPf24Bit then
    Raise Exception.Create('BitmapFiletr accepts only 24Bit DIB');


  // １ライン分ピクセルデータを保持するためのバッファ長を計算します。
  // 10足しているのは、マトリックスがビットマップからはみ出すことを
  // 考慮しているからです。
  BufSize := (Bitmap.Width + 10) * 3;
  LineSize := Bitmap.Width * 3;

  // マトリックスをクリア
  FillChar(Mat, SizeOf(Mat), 0);

  // 新しいビットマップを作る
  NewBitmap := TBigBitmap.Create;
  try
    NewBitmap.Width := Bitmap.Width; NewBitmap.Height := Bitmap.Height;
    NewBitmap.PixelFormat := bbpf24bit;

    try
      // MatSvae を作成する。MaSaveはビットマップの11ライン分の
      // スキャンラインを保持する。MatSave の各行は ビットマップの幅+10
      // ピクセル分の大きさで、6ピクセル目からビットマップの
      // スキャンラインをコピーする。つまり前後5ピクセルは常に０になる
      // MatSave[0][0] は6ライン目の6ピクセル目をアクセスすることになる。
      for i := -5 to 5 do MatSave[i] := Nil;
      for i:= -5 to 5  do begin
        GetMem(MatSave[i], BufSize);
        FillChar(MatSave[i]^, BufSize, 0);
        if (i < 0) or (i >= Bitmap.Height) then begin
        end
        else begin
          System.Move(Bitmap.ScanLine[i]^, MatSave[i][0], LineSize);
        end;
      end;

      for y := 0 to Bitmap.Height-1 do begin
        DestLine := NewBitmap.Scanline[y];
        Mat := MatSave;
        for x := 0 to Bitmap.Width-1 do begin
          // フィルタの演算処理を呼ぶ
          DestLine[x] := Filter(x, y, Mat, pData);
          // マトリックスの行ポインタを１ピクセル分ずらす
          for i := -5 to 5 do Mat[i] := PTriples(LongInt(Mat[i])+3);
        end;

        // MatSave の内容を1行分上にスクロールする
        FreeMem(MatSave[-5]);
        MatSave[-5] := Nil;

        for i := -5 to 4 do MatSave[i] := MatSave[i+1];
        MatSave[5] := Nil;

        //最下行に元のビットマップからスキャンラインを読み込む
        GetMem(MatSave[5], BufSize);
        FillChar(MatSave[5]^, BufSize, 0);

        if y + 6 < Bitmap.Height then begin
          System.Move(Bitmap.ScanLine[y+6]^, MatSave[5][0], LineSize);
        end;
      end;
    finally
      for i := -5 to 5 do
        if MatSave[i] <> Nil then
          FreeMem(MatSave[i]);
    end;
  except
    NewBitmap.Free;
    raise;
  end;

  Result := NewBitmap;
end;


end.
