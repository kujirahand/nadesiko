unit GLDPNG;

// ******************************************************
// *                                                    *
// *  GLDPNG ver 3.4                                    *
// *                                   2001.07.03 改変  *
// *                                                    *
// *   1998-2001 CopyRight Tarquin All Rights Reserved. *
// *                                                    *
// ******************************************************
//
// PNGフォーマットの読み書きクラスです。
//
// 以下は使用状況に応じて設定してください。
// なお、プロジェクトの条件定義で指定してください。
//
//  ・GLD_READONLY    　・・・ 読み込みのみのクラス作成
//  ・GLD_SUPPORT_BIT15 ・・・ bitcount=15(3万色)の読み込みサポート
//  ・GLD_NOREVERSE_ALPHA   ・・・ アルファチャンネルを0=透明 255=不透明に変更します

{$I taki.inc}

interface

uses
 Windows, Classes, SysUtils, Graphics,
 SFunc, GLDStream, GLDPNGStream, tkZLIB;

const
 GLD_NONECOLOR = COLORREF(-1);  // 指定カラーなし

 gplNone    = Z_NO_COMPRESSION;
 gplDefault = Z_DEFAULT_COMPRESSION;
 gplSpeed   = Z_BEST_SPEED;
 gplBest    = Z_BEST_COMPRESSION;

type
 TGLDPNGFilterType = (gpfJust,gpfNone,gpfSub,gpfUp,gpfAvg,gpfPaeth);
 TGLDPNGInterlaceType = (gptNone, gptAdam7);
 TGLDPNGUnitSpecifier = (gpuAspect,gpuMeter,gpuInch);

 TGLDPNGDECodeEvent = procedure (sender: TObject; pbuf: pbyte; buflen,lineno: integer; password: string) of object;
 TGLDPNGPasswordEvent = procedure (sender: TObject; var password: string) of object;

 TGLDPNG=class(TGraphic)
  private
   FTransFlag:      boolean;
   FIDATSize:       integer;              // IDATのサイズ
   FCompressLevel:  integer;              // ZLIB圧縮オプション設定
   FFilterType:     TGLDPNGFilterType;    // 圧縮時の使用フィルター
   FInterlaceType:  TGLDPNGInterlaceType; // インターレースの種類
   FGrayScale:      boolean;              // グレイスケール保存
   FABmpIn,FABmp:   TGLDBmp;              // アルファチャンネル入出力用ビットマップ
   FImgIn,FImg:     TGLDBmp;              // 保持イメージ

   FAlphaFlag:      boolean;              // アルファチャンネルの有無
   FOrgBitCount:    integer;              // 読み込んだデータの本当のビット数
   FBGColor:        COLORREF;             // 背景色(無い時用)
   FTransColor:     COLORREF;             // 透明色(無い時用)
   FText:           string;               // コメント文(無い時用)
   FGamma:          double;               // ガンマ値
   FPassword:       string;               // パスワード
   FShiftRGB:       integer;              // 各要素のシフト数
   FUnitSpecifier:  TGLDPNGUnitSpecifier; // 解像度単位
   FWidthSpecific:  integer;              // 横解像度
   FHeightSpecific: integer;              // 縦解像度
   FMacBinaryFlag:  boolean;              // マックバイナリチェックの有無
   FNowTime:        boolean;              // 現在時間を出力
   FTime:           TPNGTime;             // 指定時間
   FChrm:           TPNGChromaticities;   // 色度情報
   FGIFExt:         TPNGGIFExtension;     // GIFデータ
   FRead16BitFlag:  boolean;              // 16BITピクセル読み込み有効

   FOnPassword:     TGLDPNGPasswordEvent; // パスワード入力イベント
   FOnEncode:       TGLDPNGDECodeEvent;   // 暗号化イベント
   FOnDecode:       TGLDPNGDECodeEvent;   // 復号化イベント

   procedure SetIDATSize(n: integer);
   procedure SetTransColor(cor: COLORREF);
   procedure SetTransFlag(obj: TGraphic);
   procedure SetABmp(obj: TGLDBmp);
   procedure SetImage(obj: TGLDBmp);
   procedure SetTime(tm: TPNGTime);
   function  GetTime: TPNGTime;
   procedure SetChrm(cm: TPNGChromaticities);
   function  GetChrm: TPNGChromaticities;
   procedure SetGIFExt(gif: TPNGGIFExtension);
   function  GetGIFEXt: TPNGGIFExtension;
  protected
   procedure ReadData(Stream: TStream); override;
   procedure WriteData(Stream: TStream); override;
   function  GetEmpty: boolean; override;
   function  GetPalette: HPALETTE; override;
   procedure SetPalette(hpal: HPALETTE); override;
   function  GetHeight: integer; override;
   function  GetWidth: integer; override;
   procedure AssignTo(dest: TPersistent); override;
   procedure Draw(ACanvas: TCanvas; const Rect: TRect); override;
   procedure SetWidth(n: integer); override;
   procedure SetHeight(n: integer); override;
   procedure SetTransparent(Value: Boolean); override;

   function  GetAlphaBitmap: TGLDBmp;
   function  GetImage: TGLDBmp;
  public
   constructor Create; override;
   destructor  Destroy; override;
   procedure Assign(source: TPersistent); override;
   procedure LoadFromStream(Stream: TStream); override;
   procedure SaveToStream(Stream: TStream); override;
   procedure LoadFromClipboardFormat(AFormat: Word;
                                     AData: THandle;
                                     APalette: HPALETTE); override;
   procedure SaveToClipboardFormat(var Format: Word;
                                   var Data: THandle;
                                   var APalette: HPALETTE); override;
   function  AlphaBitmapAssignTo(dest: TGraphic): boolean;
   procedure FreeAlphaBitmap;
   procedure AlphaBitmapAssign(source: TGraphic);

   property Image:            TGLDBmp read FImgIn write SetImage;
   property AlphaBitmap:      TGLDBmp read FABmpIn write SetABmp;
   property GrayScale:        boolean read FGrayScale write FGrayScale;
   property AlphaChannel:     boolean read FAlphaFlag write FAlphaFlag;

   property CompressLevel:    integer read FCompressLevel write FCompressLevel;
   property FilterType:       TGLDPNGFilterType read FFilterType write FFilterType;
   property IDATSize:         integer read FIDATSize write SetIDATSize;
   property InterlaceType:    TGLDPNGInterlaceType read FInterlaceType write FInterlaceType;
   property ShiftRGB:         integer read FShiftRGB write FShiftRGB;

   property BGColor:          COLORREF read FBGColor write FBGColor;
   property TransColor:       COLORREF read FTransColor write SetTransColor;
   property Text:             string read FText write FText;
   property Gamma:            double read FGamma write FGamma;
   property UnitSpecifier:    TGLDPNGUnitSpecifier read FUnitSpecifier write FUnitSpecifier;
   property WidthSpecific:    integer read FWidthSpecific write FWidthSpecific;
   property HeightSpecific:   integer read FHeightSpecific write FHeightSpecific;
   property NowTime:          boolean read FNowTime write FNowTime;
   property Time:             TPNGTime read GetTime write SetTime;
   property Chromaticities:   TPNGChromaticities read GetChrm write SetChrm;
   property GIFExtension:     TPNGGIFExtension read GetGIFExt write SetGIFExt;

   property OriginalBitCount: integer read FOrgBitCount;
   property MacBinary:        boolean read FMacBinaryFlag write FMacBinaryFlag;
   property Read16Bit:        boolean read FRead16BitFlag write FRead16BitFlag;
   property Password:         string read FPassword write FPassword;

   property OnPassword:       TGLDPNGPasswordEvent read FOnPassword write FOnPassword;
   property OnEncode:         TGLDPNGDECodeEvent read FOnEncode write FOnEncode;
   property OnDecode:         TGLDPNGDECodeEvent read FOnDecode write FOnDecode;
 end;

implementation


//***************************************************
//*   TGLDPNG                                       *
//***************************************************


//------- Create => クラス作成


constructor TGLDPNG.Create;
begin
 inherited;
 FIDATSize:=32768;
 FCompressLevel:=gplDefault;
 FFilterType:=gpfNone;
 FGamma:=0.45455;
 FBGColor:=GLD_NONECOLOR;
 FTransColor:=GLD_NONECOLOR;
 FMacBinaryFlag:=TRUE;
 FNowTime:=TRUE;
 FTime:=SystemPNGTime;
 FImg:=TGLDBmp.Create;
 FABmp:=TGLDBmp.Create;
end;


//------- Destroy => クラス開放


destructor TGLDPNG.Destroy;
begin
 if FABmp<>nil then FABmp.Free;
 if FImg<>nil then FImg.Free;
 inherited;
end;


//------- SetIDATSize => IDATサイズ設定


procedure TGLDPNG.SetIDATSize(n: integer);
begin
 if (n<256) or (n>100000) then
  raise EGLDPNG.Create('PNG Param: Err IDAT Size(min:256  max:100000)');
 FIDATSize:=n;
end;


//------- SaveToStream => PNGを書き込む


procedure TGLDPNG.SaveToStream(Stream: TStream);
var
{$IFNDEF GLD_READONLY}
 pngstream: TGLDPNGWriteStream;
 oldevt: TProgressEvent;
{$ENDIF}
 img: TGLDBmp;

begin
 img:=GetImage;
{$IFNDEF GLD_READONLY}
 pngstream:=TGLDPNGWriteStream.Create;
 try
  // パラメータ設定
  pngstream.CompressLevel :=integer(FCompressLevel);
  pngstream.FilterType    :=integer(FFilterType);
  pngstream.IDATSize      :=FIDATSize;
  pngstream.InterlaceType :=integer(FInterlaceType);
  pngstream.GrayScale     :=FGrayScale;
  pngstream.Text          :=FText;
  pngstream.BGColor       :=FBGColor;
  pngstream.TransColor    :=FTransColor;
  pngstream.Gamma         :=FGamma;
  pngstream.ShiftRGB      :=FShiftRGB;
  pngstream.UnitSpecifier :=integer(FUnitSpecifier);
  pngstream.WidthSpecific :=FWidthSpecific;
  pngstream.HeightSpecific:= FHeightSpecific;
  pngstream.NowTime       :=FNowTime;
  pngstream.Time          :=@FTime;
  pngstream.Chromaticities:=@FChrm;
  pngstream.GIFExtension  :=@FGIFExt;

  pngstream.OnEncode      :=FOnEncode;
  pngstream.Password      :=FPassword;
  if AlphaChannel then
   pngstream.AlphaBitmap:=GetAlphaBitmap;
  // セーブ
  oldevt:=img.OnProgress;
  if Assigned(OnProgress) then img.OnProgress:=OnProgress;
  pngstream.SaveToStream(img,stream);
  img.OnProgress:=oldevt;
 finally
  pngstream.Free;
 end;
 {$ELSE}
 Img.SaveToStream(Stream);
 {$ENDIF}
end;


//------- LoadFromStream => PNGで読み込む


procedure TGLDPNG.LoadFromStream(Stream: TStream);
var
 pngstream: TGLDPNGReadStream;
 img: TGLDBmp;
 oldevt: TProgressEvent;

begin
 pngstream:=TGLDPNGReadStream.Create;
 img:=GetImage;
 try
  // パラメータ代入
  pngstream.OnDecode      :=FOnDecode;
  pngstream.OnPassword    :=FOnPassword;
  pngstream.Password      :=FPassword;
  pngstream.MacBinaryCheck:=FMacBinaryFlag;
  pngstream.Read16Bit     :=FRead16BitFlag;
  pngstream.Time          :=@FTime;
  pngstream.Chromaticities:=@FChrm;
  pngstream.GIFExtension  :=@FGIFExt;
  // 内部アルファチャンネルビットマップクリア
  if FABmp<>nil then FABmp.Assign(nil);
  // ロード
  pngstream.AlphaBitmap:=GetAlphaBitmap;

  oldevt:=img.OnProgress;
  if Assigned(OnProgress) then img.OnProgress:=OnProgress;
  pngstream.LoadFromStream(img,stream,0);
  img.OnProgress:=oldevt;

  // リードデータ代入
  FAlphaFlag     :=pngstream.AlphaChannel;
  FText          :=pngstream.TextData;
  FBGColor       :=pngstream.BGColor;
  FTransColor    :=pngstream.TransColor;
  FInterlaceType :=TGLDPNGInterlaceType(pngstream.InterlaceType);
  FGamma         :=pngstream.Gamma;
  FUnitSpecifier :=TGLDPNGUnitSpecifier(pngstream.UnitSpecifier);
  FWidthSpecific :=pngstream.WidthSpecific;
  FHeightSpecific:=pngstream.HeightSpecific;
  FShiftRGB      :=pngstream.ShiftRGB;
  FOrgBitCount   :=pngstream.OriginalBitCount;
  FGrayScale     :=pngstream.GrayScale;

  SetTransFlag(img);
 finally
  pngstream.Free;
 end;
end;


//------- AlphaBitmapAssign => 内部にあるアルファチャンネルにコピー


procedure TGLDPNG.AlphaBitmapAssign(source: TGraphic);
begin
 // リンクは解除
 FABmpIn:=nil;

 if source is TGLDPNG then
  begin
   // 内部アルファチャンネルをコピーする
   FABmp.Assign(TGLDPNG(source).FABmp);
  end
 else
  FABmp.Assign(Source);
end;


//------- AlphaBitmapAssignTo => 現在内部にあるアルファチャンネルビットマップをコピー


function TGLDPNG.AlphaBitmapAssignTo(dest: TGraphic): boolean;
begin
 result:=not FABmp.Empty;
 if result and (dest<>nil) then dest.Assign(FABmp);
end;


//------- FreeAlphaBitmap => 現在内部にあるアルファチャンネルビットマップをクリア


procedure TGLDPNG.FreeAlphaBitmap;
begin
 FABmp.Assign(nil);
end;


//------- 実行時読み込み(IDE用)


procedure TGLDPNG.ReadData(Stream: TStream);
{$IFDEF GLD_READONLY}
begin
 FImg.LoadFromStream(stream);
 Changed(self);
end;
{$ELSE}
var
 png: TGLDPNGReadStream;

begin
 png:=TGLDPNGReadStream.Create;
 try
  png.Time:=@FTime;
  png.Chromaticities:=@FChrm;
  png.GIFExtension:=@FGIFExt;
  // 内部アルファチャンネルビットマップクリア
  FABmpIn:=nil; FImgIn:=nil;
  if FABmp<>nil then FABmp.Assign(nil);
  png.AlphaBitmap:=FABmp;
  // ロード
  png.LoadFromStream(FImg,stream,0);
  // リードデータ代入
  FAlphaFlag     :=png.AlphaChannel;
  FText          :=png.TextData;
  FBGColor       :=png.BGColor;
  FTransColor    :=png.TransColor;
  FGamma         :=png.Gamma;
  FUnitSpecifier :=TGLDPNGUnitSpecifier(png.UnitSpecifier);
  FWidthSpecific :=png.WidthSpecific;
  FHeightSpecific:=png.HeightSpecific;
  FShiftRGB      :=png.ShiftRGB;
  FOrgBitCount   :=png.OriginalBitCount;
  FGrayScale     :=png.GrayScale;

  SetTransFlag(FImg);
 finally
  png.Free;
 end;
 Changed(self);
end;
{$ENDIF}


//------ リソース自動書き込み(IDE用)


procedure TGLDPNG.WriteData(Stream: TStream);
{$IFDEF GLD_READONLY}
begin
 if (not FImg.Empty) then
  begin
   FImg.SaveToStream(stream);
  end;
end;
{$ELSE}
var
 png: TGLDPNGWriteStream;

begin
 if (not FImg.Empty) then
  begin
   png:=TGLDPNGWriteStream.Create;
   try
    // パラメータ設定
    png.GrayScale     :=FGrayScale;
    png.Text          :=FText;
    png.BGColor       :=FBGColor;
    png.TransColor    :=FTransColor;
    png.Gamma         :=FGamma;
    png.ShiftRGB      :=FShiftRGB;
    png.UnitSpecifier :=integer(FUnitSpecifier);
    png.WidthSpecific :=FWidthSpecific;
    png.HeightSpecific:=FHeightSpecific;
    png.Time          :=@FTime;
    png.Chromaticities:=@FChrm;
    png.GIFExtension  :=@FGIFExt;

    if AlphaChannel then
     png.AlphaBitmap:=FABmp;
    // セーブ
    png.SaveToStream(FImg,stream);
   finally
    png.Free;
   end;
  end;
end;
{$ENDIF}


//------- SetTransparent => 透過指定


procedure TGLDPNG.SetTransparent(Value: Boolean);
begin
 if not FTransFlag then
  begin
   if GetImage.Transparent<>Value then GetImage.Transparent:=Value;
  end;
 inherited SetTransparent(Value);
end;


//------- SetTransColor => 透明色設定


procedure TGLDPNG.SetTransColor(cor: COLORREF);
var
 img: TGLDBmp;

begin
 img:=GetImage;
 FTransColor:=cor;
 if not img.Empty then
  begin
   if cor=GLD_NONECOLOR then
    begin
     Transparent:=FALSE;
    end
   else
    begin
     img.TransparentColor:=cor;
    end;
  end;
end;


//------- Assign => 別クラスデータを代入コピー


procedure TGLDPNG.Assign(source: TPersistent);
begin
 // リンクは解除
 FImgIn:=nil;

 if source is TGLDPNG then
  begin
   // 内部ビットマップにコピーする
   FImg.Assign(TGLDPNG(source).FImg);
   // 内部アルファチャンネルをコピーする
   FABmp.Assign(TGLDPNG(source).FABmp);
   // 内部情報コピー
   TGLDPNG(source).FImgIn         :=FImgIn;
   TGLDPNG(source).FABmpIn        :=FABmpIn;
   TGLDPNG(source).FCompressLevel :=FCompressLevel;
   TGLDPNG(source).FFilterType    :=FFilterType;
   TGLDPNG(source).FIDATSize      :=FIDATSize;
   TGLDPNG(source).FInterlaceType :=FInterlaceType;
   TGLDPNG(source).FGrayScale     :=FGrayScale;
   TGLDPNG(source).FText          :=FText;
   TGLDPNG(source).FBGColor       :=FBGColor;
   TGLDPNG(source).FTransColor    :=FTransColor;
   TGLDPNG(source).FGamma         :=FGamma;
   TGLDPNG(source).FShiftRGB      :=FShiftRGB;
   TGLDPNG(source).FUnitSpecifier :=FUnitSpecifier;
   TGLDPNG(source).FWidthSpecific :=FWidthSpecific;
   TGLDPNG(source).FHeightSpecific:=FHeightSpecific;
   TGLDPNG(source).FNowTime       :=FNowTime;
   TGLDPNG(source).FTime          :=FTime;
   TGLDPNG(source).FChrm          :=FChrm;
  end
 else
  if Source is TGraphic then
   begin
    FImg.Assign(Source);
   end
  else
   begin
    inherited Assign(Source);
    Exit;
   end;

 SetTransFlag(FImg);
end;


//------- AssignTo => 別クラスにコピー


procedure TGLDPNG.AssignTo(dest: TPersistent);
begin
 if dest is TGraphic then
  dest.Assign(GetImage)
 else
  inherited AssignTo(dest);
end;


//------- LoadFromClipboardFormat => クリップボードから読み込み


procedure TGLDPNG.LoadFromClipboardFormat(AFormat: Word;
                                          AData: THandle;
                                          APalette: HPALETTE);
begin
 // 内部ビットマップに読み込み
 // この場合、リンクは解除
 FImgIn:=nil;
 FImg.LoadFromClipboardFormat(AFormat,AData,APalette);
 SetTransFlag(FImg);
end;


//------- SaveToClipBoardFormat => クリップボードに書き込み


procedure TGLDPNG.SaveToClipboardFormat(var Format: Word;
                                        var Data: THandle;
                                        var APalette: HPALETTE);
begin
 GetImage.SaveToClipboardFormat(Format,Data,APalette);
end;


//------- Draw => 表示


procedure TGLDPNG.Draw(ACanvas: TCanvas; const Rect: TRect);
begin
 ACanvas.StretchDraw(Rect,GetImage);
end;


//------- GetEmpty => イメージの有無を返す


function  TGLDPNG.GetEmpty: boolean;
begin
 result:=GetImage.Empty;
end;


//------- GetPalette => パレットを返す


function  TGLDPNG.GetPalette: HPALETTE;
begin
 result:=GetImage.Palette;
end;


//------- SetPalette => パレット指定


procedure TGLDPNG.SetPalette(hpal: HPALETTE);
begin
 GetImage.Palette:=hpal;
 Changed(self);
end;


//------- GetHeight => 高さを返す


function  TGLDPNG.GetHeight: integer;
begin
 result:=GetImage.Height
end;


//------- SetWidth => 幅を返す


function  TGLDPNG.GetWidth: integer;
begin
 result:=GetImage.Width;
end;


//------- SetWidth => 幅指定


procedure TGLDPNG.SetWidth(n: integer);
var
 img: TGLDBmp;

begin
 img:=GetImage;
 if not img.Empty then img.Width:=n;
 // アルファチャンネルも幅変更
 img:=GetAlphaBitmap;
 if not img.Empty then img.Width:=n;
 Changed(self);
end;


//------- SetHeight => 高さ指定


procedure TGLDPNG.SetHeight(n: integer);
var
 img: TGLDBmp;

begin
 img:=GetImage;
 if not img.Empty then img.Height:=n;
 // アルファチャンネルも幅変更
 img:=GetAlphaBitmap;
 if not img.Empty then img.Height:=n;
 Changed(self);
end;


//------- GetAlphaBitmap => 読み書きアルファチャンネルビットマップを返す


function TGLDPNG.GetAlphaBitmap: TGLDBmp;
begin
 if FABmpIn=nil then result:=FABmp else result:=FABmpIn;
end;


//------- SetABmp => アルファチャンネルビットマップリンク


procedure TGLDPNG.SetABmp(obj: TGLDBmp);
begin
 if (obj<>FImgIn) and (obj<>nil) then FABmpIn:=obj else FABmpIn:=nil;
end;


//------- GetImage => 読み書き対象イメージを返す


function TGLDPNG.GetImage: TGLDBmp;
begin
 if FImgIn=nil then result:=FImg else result:=FImgIn;
end;


//------- SetImage => イメージリンク


procedure TGLDPNG.SetImage(obj: TGLDBmp);
begin
 // アルファチャンネルのリンクと同じものなら
 // アルファチャンネルの方のリンクを切る
 if (obj=FABmpIn) and (obj<>nil) then FABmpIn:=nil;
 FImgIn:=obj;
 if obj=nil then obj:=FImg;
 SetTransFlag(obj);
end;


//------- SetTransFlag => イメージ変更に伴い透過などを変更


procedure TGLDPNG.SetTransFlag(obj: TGraphic);
begin
 PaletteModified:=TRUE;
 if Transparent<>obj.Transparent then
  begin
   FTransFlag:=TRUE;
   try
    Transparent:=obj.Transparent;
   finally
    FTransFlag:=FALSE;
   end;
  end
 else
  Changed(self);
end;


//------- SetGIFExt => GIFデータ設定


procedure TGLDPNG.SetGIFExt(gif: TPNGGIFExtension);
begin
 FGifExt:=gif;
end;


//------- GetGifExt => GIFデータを返す


function TGLDPNG.GetGIFExt: TPNGGIFExtension;
begin
 result:=FGIFExt;
end;


//------- SetChrm => 色度設定


procedure TGLDPNG.SetChrm(cm: TPNGChromaticities);
begin
 FChrm:=cm;
end;


//------- GetChrm => 色度を返す


function TGLDPNG.GetChrm: TPNGChromaticities;
begin
 result:=FChrm;
end;


//------- SetTime => 時間設定


procedure TGLDPNG.SetTime(tm: TPNGTime);
begin
 FTime:=tm;
end;


//------- GetTime => 時間読み込み


function  TGLDPNG.GetTime: TPNGTime;
begin
 result:=FTime;
end;


initialization

 TPicture.RegisterFileFormat('PNG','PNG Format',TGLDPNG);

finalization

 {$IFNDEF DEL2}
 TPicture.UnRegisterGraphicClass(TGLDPNG);
 {$ENDIF}

end.
