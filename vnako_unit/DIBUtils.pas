{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
unit DIBUtils;

interface

uses Windows, SysUtils, Classes;

// ビットマップ情報のサイズ
const BitmapInfoSize =
  SizeOf(TBitmapInfoHeader) + 259 * SizeOf(TRgbQuad);
type
  EDIBUtilsError = class(Exception);

  TDynamicByteArray = array of Byte;

  // DIB の情報を保持するレコードです。
  // Bits:      ピクセル情報を保持する動的バイト配列です。
  // W3Head:     Windows 3.1 形式のビットマップヘッダです。
  // W3HeadInfo: Windows 3.1 形式のビットマップ情報です。
  // PMHead:     PM1.X 形式のビットマップヘッダです。
  // PMHeadInfo: PM 1.X 形式のビットマップ情報です。
  // Dummy:      カラーテーブルのエリア確保のためのダミーです。
  TSepDIB = record
    Bits: TDynamicByteArray;
    case Integer of
      1:(W3Head: TBitmapInfoHeader;);
      2:(W3HeadInfo: TBitmapInfo;);
      3:(PMHead: TBitmapCoreheader;);
      4:(PMHeadInfo: TBitmapCoreInfo;);
      5:(Dummy: array[0..BitmapInfoSize] of Byte;);
  end;

// ポインタをオフセット分ずらす
function AddOffset(p: Pointer; Offset: LongInt): Pointer;


// ストリームから DIB を SepDIBレコードに読み込む
procedure LoadDIBFromStream(var SepDIB: TSepDIB; Stream: TStream);

// ストリームに DIB を SepDIBレコードから書き込む
procedure SaveDIBToStream(var SepDIB: TSepDIB; Stream: TStream);

// 16bpp/ 32bpp の DIB を 24bpp に変換
procedure  DIB32_16ToDIB24(var OldSepDIB: TSepDIB;
                           var NewSepDIB: TSepDIB);

// 8Bit RLE -> 8Bit RGB  変換
procedure Convert8BitRLETo8BitRGB(var OldSepDIB: TSepDIB;
                                  var NewSepDIB: TSepDIB);
// 4Bit RLE -> 4Bit RGB  変換
procedure Convert4BitRLETo4BitRGB(var OldSepDIB: TSepDIB;
                                  var NewSepDIB: TSepDIB);

function CreatePaletteFromDIB(var SepDIB: TSepDIB): HPALETTE;

implementation

function AddOffset(p: Pointer; Offset: LongInt): Pointer;
begin Result := Pointer(LongInt(p) + Offset); end;

procedure RaiseError(s: string);
begin
  raise EDIBUtilsError.Create(s);
end;

// ピクセルのビット数 から色数を求める。16/24/32 bpp は ０を返す。
// biClrUsed を補正するのに使う。
// biClrUsed は ０の場合に使うこと（重要！）
function GetNumColors(BitCount: Integer): Integer;
begin
  if BitCount in [1, 4, 8] then
    Result := 1 shl BitCount
  else
    Result := 0;
end;


// ビットマップ情報ヘッダを PM1.X 形式から Windows 3.X 形式に変換する
procedure ConvertBitmapHeaderPMToW3(var PmSepDIB: TSepDIB);
var SepDIB: TSepDIB;
    i: Integer;
begin
  // PmSepDIB(PM 形式 BitmapInfo) から BitmapInfoHeader を作る
  SepDIB.W3Head.biSize          := SizeOf(TBitmapInfoheader);
  SepDIB.W3Head.biWidth         := PMSepDIB.PMHead.bcWidth;
  SepDIB.W3Head.biHeight        := PMSepDIB.PMHead.bcHeight;
  SepDIB.W3Head.biPlanes        := PMSepDIB.PMHead.bcPlanes;
  SepDIB.W3Head.biBitCount      := PMSepDIB.PMHead.bcBitCount;
  SepDIB.W3Head.biCompression   := BI_RGB; // PM 形式に圧縮は無い！！
  SepDIB.W3Head.biSizeImage     := 0;
  SepDIB.W3Head.biXPelsPerMeter := 3780;  // 96dpi
  SepDIB.W3Head.biYPelsPerMeter := 3780;  // 96dpi
  // カラーテーブル長は PM では bcBitCount で決まる。
  SepDIB.W3Head.biClrUsed       := GetNumColors(PMSepDIB.PMHead.bcBitCount);
  SepDIB.W3Head.biClrImportant  := 0;


  // PM と W3 では カラーテーブルの形式が違うので変換する
  for i := 0 to SepDIB.W3Head.biClrUsed - 1 do begin
    SepDIB.W3HeadInfo.bmiColors[i].rgbRed :=
          PMSepDIB.PMHeadInfo.bmciColors[i].rgbtRed;
    SepDIB.W3HeadInfo.bmiColors[i].rgbGreen :=
          PMSepDIB.PMHeadInfo.bmciColors[i].rgbtGreen;
    SepDIB.W3HeadInfo.bmiColors[i].rgbBlue :=
          PMSepDIB.PMHeadInfo.bmciColors[i].rgbtBlue;
    SepDIB.W3HeadInfo.bmiColors[i].rgbReserved := 0;
  end;


  PMSepDIB := SepDIB;  // 変換結果を書き込む
end;

function CreatePaletteFromDIB(var SepDIB: TSepDIB): HPALETTE;
var
  LogPalette: TMaxLogPalette;
  ColorCount: Integer;
  i: Integer;
begin
  LogPalette.palVersion := $0300;
  ColorCount := SepDIB.W3Head.biClrUsed;
  if ColorCount = 0 then
    ColorCount := GetNumColors(SepDIB.W3Head.biBitCount);
  LogPalette.palNumEntries := ColorCount;
  if SepDIB.W3Head.biCompression = BI_BITFIELDS then
    for i := 0 to ColorCount-1 do
    begin
      LogPalette.palPalEntry[i].peRed :=
        SepDIB.W3HeadInfo.bmiColors[i+3].rgbRed;
      LogPalette.palPalEntry[i].peGreen :=
        SepDIB.W3HeadInfo.bmiColors[i+3].rgbGreen;
      LogPalette.palPalEntry[i].peBlue :=
        SepDIB.W3HeadInfo.bmiColors[i+3].rgbBlue;
      LogPalette.palPalEntry[i].peFlags := 0;
    end
  else
    for i := 0 to ColorCount-1 do
    begin
      LogPalette.palPalEntry[i].peRed :=
        SepDIB.W3HeadInfo.bmiColors[i].rgbRed;
      LogPalette.palPalEntry[i].peGreen :=
        SepDIB.W3HeadInfo.bmiColors[i].rgbGreen;
      LogPalette.palPalEntry[i].peBlue :=
        SepDIB.W3HeadInfo.bmiColors[i].rgbBlue;
      LogPalette.palPalEntry[i].peFlags := 0;
    end;

  Result := CreatePalette(PLogPalette(@LogPalette)^);
end;

// ストリームから DIB を SepDIBレコードに読み込む
procedure LoadDIBFromStream(var SepDIB: TSepDIB; Stream: TStream);
var
  bfh: TBitmapFileHeader;
  BitsSize: Integer;
  StreamPos: Integer;
begin
  // ストリームの開始位置をセーブ
  StreamPos := Stream.Position;

  // ファイルヘッダーを読む
  Stream.ReadBuffer(bfh, SizeOf(bfh));

  // ファイルタイプをチェック
  if bfh.bfType <> $4D42 then
    RaiseError('LoadDIBFromStream: File type is invalid');

  // ピクセル情報のメモリ量計算
  BitsSize := bfh.bfSize - bfh.bfOffBits;

  // W3 か PM かを判断するためビットマップヘッダサイズを読み込む
  Stream.ReadBuffer(SepDIB.W3Head, SizeOf(DWORD));

  if SepDIB.W3Head.biSize >= SizeOf(TBitmapInfoHeader) then
  begin
    // Windows 形式
    // BitmapInfoHeader(V3, V4, V5) の残りを読み込む
    Stream.ReadBuffer(AddOffset(@SepDIB.W3Head, SizeOf(DWORD))^,
                      SepDIB.W3Head.biSize - SizeOf(DWORD));

    // 色ビット数チェック
    if not (SepDIB.W3Head.biBitCount in [1, 4, 8, 16, 24, 32]) then
      RaiseError('LoadDIBFromStream: Invalid BitCout');

    // 色数を求める。
    if SepDIB.W3Head.biClrUsed = 0 then
      SepDIB.W3Head.biClrUsed := GetNumColors(SepDIB.W3Head.biBitCount);

    // カラーテーブルを読み込む
    //------------------------------
    // Note:
    // カラーテーブルは先頭に 3 DWORD の BitFields を含むことがある。
    // その場合はカラーテーブルの大きさは (3 + biClrUsed) 個に
    // なるので注意が必要。また biClrUsed が２５７以上になることも有り得る
    // また V4, V5 ヘッダのマスクの取り扱いに注意。マスクは V3 では
    // カラーテーブルに含まれるが, V4, V5 ではヘッダの中にある(位置はV3と互換)

    if SepDIB.W3Head.biCompression <> BI_BITFIELDS then begin
    // BitFields を含まない場合
      if SepDIB.W3Head.biClrUsed <= 256 then
        // V3ヘッダの直後に読み込む。V4, V5 の追加フィールドは潰す
        Stream.ReadBuffer(
          AddOffset(@SepDIB.W3Head, SizeOf(TBitmapInfoHeader))^,
                    SepDIB.W3Head.biClrUsed * SizeOf(TRgbQuad))
      else begin
        // カラーテーブルが２５６個より大きければ先頭256だけ使う。
        // V3ヘッダの直後に読み込む。V4, V5 の追加フィールドは潰す
        Stream.ReadBuffer(
          AddOffset(@SepDIB.W3Head, SizeOf(TBitmapInfoHeader))^,
                    256 * SizeOf(TRgbQuad));
      end;
    end
    else begin
    // BitFields を含む場合
      if SepDIB.W3Head.biSize = SizeOf(TBitmapInfoHeader) then // V3
      begin
        if SepDIB.W3Head.biClrUsed <= 256 then
        // ヘッダの直後に読み込む。マスク12バイト分を加えて読む
          Stream.ReadBuffer(
            AddOffset(@SepDIB.W3Head, SizeOf(TBitmapInfoHeader))^,
                      (SepDIB.W3Head.biClrUsed+3) * SizeOf(TRgbQuad))
        else begin
          // カラーテーブルが２５６個より大きければ先頭256だけ使う。
          // ヘッダの直後に読み込む。マスク12バイト分を加えて読む
          Stream.ReadBuffer(
            AddOffset(@SepDIB.W3Head, SizeOf(TBitmapInfoHeader))^,
                      (256+3) * SizeOf(TRgbQuad));
        end;
      end
      else // V4 or V5
           // V4 or V5 のヘッダではカラーテーブルにマスクはなく
           // ヘッダに含まれている
      begin
        // V4, V5ヘッダのマスクの直後に読み込む。 V4, V5 のフィールドは潰す
        if SepDIB.W3Head.biClrUsed <= 256 then
          Stream.ReadBuffer(
            AddOffset(@SepDIB.W3Head, SizeOf(TBitmapInfoHeader) +
                                        SizeOf(TRGBQuad) * 3)^,
                      (SepDIB.W3Head.biClrUsed) * SizeOf(TRgbQuad))
        else begin
          // カラーテーブルが２５６個より大きければ先頭256だけ使う。
         // V4, V5ヘッダのマスクの直後に読み込む。 V4, V5 のフィールドは潰す
          Stream.ReadBuffer(
            AddOffset(@SepDIB.W3Head, SizeOf(TBitmapInfoHeader) +
                                        SizeOf(TRGBQuad) * 3)^,
                      256 * SizeOf(TRgbQuad));
        end;
      end;
    end;

    // 色数が多すぎるなら２５６に直す。
    if SepDIB.W3Head.biClrUsed > 256 then
      SepDIB.W3Head.biClrUsed := 256;

    SepDIB.W3Head.biSize := SizeOf(TBitmapInfoHeader); // V3 ヘッダにする
  end
  else if SepDIB.PMHead.bcSize = SizeOf(TBitmapCoreHeader) then begin
    // PM 1.X 形式
    // BitmapCoreHeader を読み込む
    Stream.ReadBuffer(AddOffset(@SepDIB.PMHead, SizeOf(DWORD))^,
                      SizeOf(TBitmapCoreHeader) - SizeOf(DWORD));

    // 色ビット数チェック
    if not (SepDIB.PMHead.bcBitCount in [1, 4, 8, 24]) then
      RaiseError('TBigBitmap.LoadFromStream: Invalid BitCount');

    // カラーテーブルを読み込む。PM 形式の場合は BitField も無いし
    // カラーテーブルの大きさは bcBitCount で自動的に決まる。
    Stream.ReadBuffer(
      Pointer(LongInt(@SepDIB.PMHead)+SizeOf(TBitmapCoreHeader))^,
      GetNumColors(SepDIB.PMHead.bcBitCount) * SizeOf(TRgbTriple));

    // ビットマップヘッダとカラーテーブルを Windows 3.X 形式に変換
    ConvertBitmapHeaderPmToW3(SepDIB);
  end
  else
    RaiseError('LoadDIBFromStream: Invalid Bitmap Header Size');

  // ピクセルデータの先頭に移動
  Stream.Position := StreamPos + bfh.bfOffBits;

  // ピクセル情報用メモリを確保
  SetLength(SepDIB.Bits, BitsSize);
  // ピクセル情報を読み込む
  Stream.ReadBuffer(SepDIB.Bits[0], BitsSize);
end;


// ストリームに DIB を SepDIBレコードから書き込む
// DIB は Windows 形式を仮定
procedure SaveDIBToStream(var SepDIB: TSepDIB; Stream: TStream);
var
  bfh: TBitmapFileHeader;
  ColorCount: Integer;
begin
    // カラーテーブル長を計算する
    ColorCount := SepDIB.W3Head.biClrUsed;
    if ColorCount = 0 then
      ColorCount := GetNumColors(SepDIB.W3Head.biBitCount);

    if SepDIB.W3Head.biCompression = BI_BITFIELDS then
      Inc(ColorCount, 3);

    // ファイルヘッダを整える
    bfh.bfSize := SizeOf(bfh);
    bfh.bfType := $4D42;
    bfh.bfSize := SizeOf(bfh) + SizeOf(TBitmapInfoHeader) +
                  ColorCount*SizeOf(TRGBQuad) + 
                  Length(SepDIB.Bits);
    bfh.bfOffBits := SizeOf(bfh) + SizeOf(TBitmapInfoHeader) +
                     ColorCount*SizeOf(TRGBQuad);

    // 書く！
    Stream.WriteBuffer(bfh, SizeOf(bfh));        // ファイルヘッダ
    Stream.WriteBuffer(SepDIB.W3Head,          // ビットマップ情報と
                   SizeOf(TBitmapInfoHeader) +   // カラーテーブル
                   ColorCount*SizeOf(TRGBQuad));
    // ピクセル
    Stream.WriteBuffer(SepDIB.Bits[0], Length(SepDIB.Bits));
end;

// BI_BITFIELDS 形式のビットマップの マスクのシフト量を計算する
// >0 は右シフト <0 は左シフトを表す。
//  マスク値が 128 ～ 255(MSB ON) になるようするシフト量を計算する
//    (Mask に ０ が入ると暴走するので注意！！)
function GetMaskShift(Mask: DWORD): Integer;
begin
  Result := 0;

  // Mask が $100 以上なら 右シフト量を求める
  while Mask >= 256 do begin
    Mask := Mask shr 1;
    Result := Result +1;
  end;

  // Mask が $80 未満なら 左シフト量を求める（マイナス値）
  while Mask < 128 do begin
    Mask := Mask shl 1;
    Result := Result -1;
  end;
end;


// 16bpp/ 32bpp の DIB を 24bpp に変換
procedure  DIB32_16ToDIB24(var OldSepDIB: TSepDIB;
                           var NewSepDIB: TSepDIB);
type
  // TrueColor のビットマップデータアクセス用のレコード型です。
  // Scanline Property で TrueColor のデータをアクセスするときに便利です。
  TTriple = packed record
    B, G, R: Byte;
  end;
  // DWORD 配列アクセス用の型。16bpp/32bpp 用
  TDWordArray = array[0..100000000] of DWORD;
  PDWordArray = ^TDWordArray;
var
  SourceLineSize: Integer;         // 16/32 bpp のスキャンラインサイズ
  DestLineSize: Integer;           // 24bpp のスキャンラインサイズ
  BitsSize: Integer;               // 24bpp のピクセルデータ長
  Masks: array[0..2] of DWORD;     // Masks[0]: Red Mask Masks[1]: Green Mask
                                   // Masks[2]: Blue Mask
  RShift, GShift, BShift: LongInt; // マスクのシフト量
  MaxR, MaxG, MaxB: DWORD;         // BitFields で取り出した R, G, B 値の
                                   // 補正前の最大値
  pTriple: ^TTriple;               // 24 bpp スキャンラインアクセス用ポインタ
                                   // 16/32 bpp -> 24 bpp 変換用
  pConvert: Pointer;                // 16/32bpp -> 24bpp 変換用バッファ
  i, j, w: LongInt;

begin
  // 16/32 bpp のスキャンラインの長さ
  if OldSepDIB.W3Head.biBitCount = 16 then
    SourceLineSize := ((OldSepDIB.W3Head.biWidth*2+3) div 4) * 4
  else
    SourceLineSize := ((OldSepDIB.W3Head.biWidth*4+3) div 4) * 4;

  // 24bpp のライン幅
  DestLineSize   := ((OldSepDIB.W3Head.biWidth*3+3) div 4) * 4;

  // 24bpp のサイズを計算
  BitsSize := DestLineSize * abs(OldSepDIB.W3Head.biHeight);

  // 24bpp の Pixel 用メモリを確保
  SetLength(NewSepDIB.Bits, BitsSize);

  // ビットマスクを得る
  if OldSepDIB.W3Head.biCompression = BI_RGB then begin
    // BitFields が無い場合
    // 16bpp 用デフォルトマスクパタンの作成。
    if OldSepDIB.W3Head.biBitCount = 16 then begin
      Masks[0] := $7C00; Masks[1] := $03E0; Masks[2] := $001F;
    end
    else begin
    // 32bpp 用デフォルトマスクパタンの作成。
      Masks[0] := $FF0000; Masks[1] := $00FF00; Masks[2] := $0000FF;
    end;
  end
  else begin
    // BitFields から マスクを Masks へコピー。
    Move(OldSepDIB.W3HeadInfo.bmiColors[0], Masks[0], SizeOf(DWORD)*3);
  end;

  // マスクが正常かチェック。ビットの歯抜け重なりはチェックしていない(^^
  // 0 かチェックしているのは GetMaskShift が暴走しないようにするため
  if (Masks[0] = 0) or (Masks[1] = 0) or (Masks[2] = 0) then
    RaiseError('TBigBitmap.LoadFromStream: Invalid Masks');


  // マスク後のシフト量を計算
  RShift := GetMaskShift(Masks[0]);
  GShift := GetMaskShift(Masks[1]);
  BShift := GetMaskShift(Masks[2]);

  // 補正前の R, G, B 値の最大値を計算
  if RShift >= 0 then MaxR := Masks[0] shr RShift
                 else MaxR := Masks[0] shl (-RShift);
  if GShift >= 0 then MaxG := Masks[1] shr GShift
                 else MaxG := Masks[1] shl (-GShift);
  if BShift >= 0 then MaxB := Masks[2] shr BShift
                 else MaxB := Masks[2] shl (-BShift);

  // 準備完了 読み込みスタート

  for i := 0 to abs(OldSepDIB.W3Head.biHeight) -1 do begin

    pConvert := @OldSepDIB.Bits[SourceLineSize * i];

    // 変換先を計算
    pTriple := @NewSepDIB.Bits[DestLineSize * i];

    // おしりを０クリアしておく スキャンラインのパディング
    // が０以外になるのを防ぐため。
    FillChar(AddOffset(pTriple, DestLineSize -4)^, 4, 0);

    w := OldSepDIB.W3Head.biWidth -1;

    if OldSepDIB.W3Head.biBitCount = 16 then
      // 16bpp の場合
      for j := 0 to w do begin

         // 1 pixel 変換
         if RShift >= 0 then
           pTriple.R := DWORD((PWordArray(pConvert)^[j] and Masks[0])
                        shr RShift) * 255 div MaxR
         else
           pTriple.R := DWORD((PWordArray(pConvert)^[j] and Masks[0])
                        shl (-RShift)) * 255 div MaxR;
         if GShift >= 0 then
           pTriple.G := DWORD((PWordArray(pConvert)^[j] and Masks[1])
                        shr GShift) * 255 div MaxG
         else
           pTriple.G := DWORD((PWordArray(pConvert)^[j] and Masks[1])
                        shl (-GShift)) * 255 div MaxG;
         if BShift >= 0 then
           pTriple.B := DWORD((PWordArray(pConvert)^[j] and Masks[2])
                        shr BShift) * 255 div MaxB
         else
           pTriple.B := DWORD((PWordArray(pConvert)^[j] and Masks[2])
                        shl (-BShift)) * 255 div MaxB;
         inc(pTriple);
      end
    else
      // 32 bpp の場合
      for j := 0 to w do begin
         // 1 pixel 変換
         if RShift >= 0 then
           pTriple.R := DWORD((PDWordArray(pConvert)^[j] and Masks[0])
                        shr RShift) * 255 div MaxR
         else
           pTriple.R := DWORD((PDWordArray(pConvert)^[j] and Masks[0])
                        shl (-RShift)) * 255 div MaxR;
         if GShift >= 0 then
           pTriple.G := DWORD((PDWordArray(pConvert)^[j] and Masks[1])
                        shr GShift) * 255 div MaxG
         else
           pTriple.G := DWORD((PDWordArray(pConvert)^[j] and Masks[1])
                        shl (-GShift)) * 255 div MaxG;
         if BShift >= 0 then
           pTriple.B := DWORD((PDWordArray(pConvert)^[j] and Masks[2])
                        shr BShift) * 255 div MaxB
         else
           pTriple.B := DWORD((PDWordArray(pConvert)^[j] and Masks[2])
                        shl (-BShift)) * 255 div MaxB;
         inc(pTriple);
      end
  end;

  // 全ピクセルは変換できたので今度は ビットマップ情報を書き換える
  NewSepDIB.Dummy := OldSepDIB.Dummy;
  with NewSepDIB.W3Head do begin
    // カラーテーブルの位置を補正
    if biCompression = BI_BITFIELDS then
      for i := 0 to 255 do
        with NewSepDIB.W3HeadInfo do
          bmiColors[i] := bmiColors[i+3];

    // ヘッダを補正 24bpp にする
    biCompression := BI_RGB;
    biBitCount := 24;
    biSizeImage := 0;
  end;
end;


// 4Bit RLE -> 4Bit RGB  変換
procedure Convert4BitRLETo4BitRGB(var OldSepDIB: TSepDIB;
                                  var NewSepDIB: TSepDIB);
var
  i: Integer;
  x, y: Integer;                      // 座標
  LineLength,                         // 4Bit RGB のスキャンラインの長さ
  BitsSize,                           // 変換後のビットマップデータのサイズ
  Width, Height: Integer;             // ビットマップの大きさ
  Width2: Integer;                    // Width を偶数に切り上げたもの
  Count,                              // Encode Mode のピクセル値
  Color: BYTE;                        // Encode Mode の Color Index
                                      // Absolute Mode のピクセル数。
  Bits: TDynamicByteArray;
  pSourceByte,                        // 変換元データへのポインタ
  pDestByte,                              // 変換先データへのポインタ
  pTemp: PByte;

begin
  // 旧DIB が 4BitRLE かチェック
  if (OldSepDIB.W3Head.biBitCount <> 4) or
     (OldSepDIB.W3Head.biCompression <> BI_RLE4) then
    RaiseError('Convert4BitRLETo4BitRGB: ' +
               'Invalid Bitcount & Compression Combination');

  // 高速化のため Width と Height を変数に入れる。
  Width := OldSepDIB.W3Head.biWidth;
  Height := abs(OldSepDIB.W3Head.biHeight);

  //スキャンラインの長さを計算
  LineLength := ((Width * 4 + 31) div 32) * 4;

  // Pixel データの大きさを計算。
  BitsSize   :=  LineLength * Height;

  // ピクセル情報用メモリ（出力先）を確保
  SetLength(Bits, BitsSize);
  // 座標をリセット
  x := 0; y := 0;

  // 旧／新 DIB のピクセル情報へのポインタを設定
  pSourceByte := PByte(OldSepDIB.Bits);
  pDestByte := PBYTE(Bits);


  // 4Bit RLE の場合、 幅が奇数ピクセルの場合、1ピクセル余分に Encode
  // されるケースがある。そのため、幅のチェックを偶数ピクセル数で
  // 行うようにする。
  //
  // Note: 本来不正なビットマップだが かなりの数が存在するのでやもうえない。
  //       Windows API も文句を言わないようだ(StretchDIBits など)
  Width2 := ((Width + 1) div 2) * 2;

  while True do begin
    //２バイト読む
    Count := pSourceByte^; Inc(pSourceByte);
    Color := pSourceByte^; Inc(pSourceByte);

    if Count = 0 then begin // if RLE_ESCAPE
      case Color of
        1{End Of Bitmap}: Break;
        0{End Of Line  }: begin
          // 座標と出力先ポインタを次のラインに設定
          x := 0; Inc(y);
          pDestByte := @Bits[LineLength * y];
          if y > Height then
            RaiseError('Convert4BitRLETo4BitRGB: Bad RLE Data 5');
        end;
        2{Delta}: begin
          // Delta はアニメーション用なので、ビットマップファイルには
          // 含まれないはずだが、一応処理
          // スキップ量を読み込み、座標と出力先を補正
          Inc(x, pSourceByte^); Inc(pSourceByte);
          Inc(y, pSourceByte^); Inc(pSourceByte);
          pDestByte := @Bits[LineLength * y + x];
          if (x > Width2) or (y > Height) then
            RaiseError('Convert4BitRLETo4BitRGB: Bad RLE Data 6');
        end;
        else begin // Absolute Mode, Color is Number of Colors to be copied!
          if (x + Color > Width2) or (y >= Height) then
            RaiseError('Convert4BitRLETo4BitRGB: Bad RLE Data 7');

          // 絶対モード、２バイト目の数分だけ、ピクセル値をコピー
          pTemp := pSourceByte;

          for i := 0 to Color -1 do
            if (i mod 2) = 0 then begin
              if ((x + i) mod 2) = 0 then
                pDestByte^ := pTemp^ and $f0
              else begin
                pDestByte^ := pDestByte^ or ((pTemp^ shr 4) and $0f);
                Inc(pDestByte);
              end;
            end
            else begin
              if ((x + i) mod 2) = 0 then
                pDestByte^ := (pTemp^ shl 4) and $f0
              else begin
                pDestByte^ := pDestByte^ or (pTemp^ and $0f);
                Inc(pDestByte);
              end;
              Inc(pTemp);
            end;
          // 入力元ポインタをWORD 境界に位置するように更新する。
          Inc(pSourceByte, ((Color * 4 + 15) div 16) * 2);
          Inc(x, Color);
        end;
      end;
    end
    else begin
      // Encoded Mode
      if (x + Count > Width2) or (y >= Height) then
        RaiseError('Convert4BitRLETo4BitRGB: Bad RLE Data 8');

      // Count 数分だけ、Color を出力
      for i := 0 to Count -1 do
        if (i mod 2) = 0 then begin
          if ((x + i) mod 2) = 0 then
            pDestByte^ := Color and $f0
          else begin
            pDestByte^ := pDestByte^ or ((Color shr 4) and $0f);
            Inc(pDestByte);
          end;
        end
        else begin
          if ((x + i) mod 2) = 0 then
            pDestByte^ := (Color shl 4) and $f0
          else begin
            pDestByte^ := pDestByte^ or (Color and $0f);
            Inc(pDestByte);
          end;
        end;

        Inc(x, Count);
      end;
    end;

  // しあげ
  NewSepDIB := OldSepDIB;
  NewSepDIB.Bits := Bits;
  NewSepDIB.W3Head.biBitCount := 4;            // 4Bit 非圧縮
  NewSepDIB.W3Head.biCompression := BI_RGB;
  NewSepDIB.W3Head.biSizeImage := 0;
end;

// 8Bit RLE -> 8Bit RGB  変換
procedure Convert8BitRLETo8BitRGB(var OldSepDIB: TSepDIB;
                                  var NewSepDIB: TSepDIB);
var
  x, y: Integer;                      // 座標
  LineLength,                         // 8Bit RGB のスキャンラインの長さ
  BitsSize,                           // 変換後のビットマップデータのサイズ
  Width, Height: Integer;             // ビットマップの大きさ
  Bits: TDynamicByteArray;
  Count,                              // ピクセル数
  Color: BYTE;                        // カラーインデックス(Encode)/
                                      // ピクセル数(Absolute)
  pSourceByte, pDestByte: PBYTE;      // 変換元データへのポインタ
begin
  // 旧DIB が 8BitRLE かチェック
  if (OldSepDIB.W3Head.biBitCount <> 8) or
     (OldSepDIB.W3Head.biCompression <> BI_RLE8) then
    RaiseError('Convert8BitRLETo8BitRGB: ' +
               'Invalid Bitcount & Compression Combination');

  // 高速化のため Width と Height を変数に入れる。
  Width := OldSepDIB.W3Head.biWidth;
  Height := abs(OldSepDIB.W3Head.biHeight);

  //スキャンラインの長さを計算
  LineLength := ((Width * 8 + 31) div 32) * 4;

  // Pixel データの大きさを計算。
  BitsSize   :=  LineLength * Height;

  // ピクセル情報用メモリ（出力先）を確保
  SetLength(Bits, BitsSize);
  // 座標をリセット
  x := 0; y := 0;

  // 旧／新 DIB のピクセル情報へのポインタを設定
  pSourceByte := PByte(OldSepDIB.Bits);
  pDestByte := PByte(Bits);

  while True do begin
    // 2 Byte 読む
    Count := pSourceByte^; Inc(pSourceByte);
    Color := pSourceByte^; Inc(pSourceByte);

    if Count = 0 then begin // if RLE_ESCAPE
      case Color of
        1{End Of Bitmap}: Break;
        0{EndOf Line  }: begin
          // 座標と出力先ポインタを次のラインに設定
          x := 0; Inc(y);
          pDestByte := @Bits[LineLength * y];
          if y > Height then
            RaiseError('Convert8BitRLETo8BitRGB: Bad RLE Data 1');
        end;
        2{Delta}: begin
          // Delta はアニメーション用なので、ビットマップファイルには
          // 含まれないはずだが、一応処理
          // スキップ量を読み込み、座標と出力先を補正
          Inc(x, pSourceByte^); Inc(pSourceByte);
          Inc(y, pSourceByte^); Inc(pSourceByte);
          pDestByte := @Bits[LineLength * y + x];
          if (x > Width) or (y > Height) then
            RaiseError('Convert8BitRLETo8BitRGB: Bad RLE Data 2');
        end;
        else begin // Absolute Mode, Color is Number of Colors to be copied!
          if (x + Color > Width) or (y >= Height) then
            RaiseError('Convert8BitRLETo8BitRGB: Bad RLE Data 3');
          // 絶対モード、２バイト目の数分だけ、ピクセル値をコピー
          System.Move(pSourceByte^, pDestByte^, Color);

          // 入力元ポインタをWORD 境界に位置するように更新する。
          Inc(pSourceByte, ((Color + 1) div 2) * 2);
          Inc(x, Color);
          Inc(pDestByte , Color);
        end;
      end;
    end
    else begin
      // Encoded Mode
      if (x + Count > Width) or (y >= Height) then
        RaiseError('Convert8BitRLETo8BitRGB: Bad RLE Data 4');
      // Count 数分だけ、Color を出力
      FillChar(pDestByte^, Count, Color);
      Inc(x, Count);
      Inc(pDestByte, Count);
    end;
  end;

  // しあげ
  NewSepDIB := OldSepDIB;
  NewSepDIB.Bits := Bits;
  NewSepDIB.W3Head.biBitCount := 8;            // 8Bit 非圧縮
  NewSepDIB.W3Head.biCompression := BI_RGB;
  NewSepDIB.W3Head.biSizeImage := 0;
end;


end.
