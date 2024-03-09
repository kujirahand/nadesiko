unit GLDPNG;

// ******************************************************
// *                                                    *
// *  GLDPNG ver 3.4                                    *
// *                                   2001.07.03 ����  *
// *                                                    *
// *   1998-2001 CopyRight Tarquin All Rights Reserved. *
// *                                                    *
// ******************************************************
//
// PNG�t�H�[�}�b�g�̓ǂݏ����N���X�ł��B
//
// �ȉ��͎g�p�󋵂ɉ����Đݒ肵�Ă��������B
// �Ȃ��A�v���W�F�N�g�̏�����`�Ŏw�肵�Ă��������B
//
//  �EGLD_READONLY    �@�E�E�E �ǂݍ��݂݂̂̃N���X�쐬
//  �EGLD_SUPPORT_BIT15 �E�E�E bitcount=15(3���F)�̓ǂݍ��݃T�|�[�g
//  �EGLD_NOREVERSE_ALPHA   �E�E�E �A���t�@�`�����l����0=���� 255=�s�����ɕύX���܂�

{$I taki.inc}

interface

uses
 Windows, Classes, SysUtils, Graphics,
 SFunc, GLDStream, GLDPNGStream, tkZLIB;

const
 GLD_NONECOLOR = COLORREF(-1);  // �w��J���[�Ȃ�

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
   FIDATSize:       integer;              // IDAT�̃T�C�Y
   FCompressLevel:  integer;              // ZLIB���k�I�v�V�����ݒ�
   FFilterType:     TGLDPNGFilterType;    // ���k���̎g�p�t�B���^�[
   FInterlaceType:  TGLDPNGInterlaceType; // �C���^�[���[�X�̎��
   FGrayScale:      boolean;              // �O���C�X�P�[���ۑ�
   FABmpIn,FABmp:   TGLDBmp;              // �A���t�@�`�����l�����o�͗p�r�b�g�}�b�v
   FImgIn,FImg:     TGLDBmp;              // �ێ��C���[�W

   FAlphaFlag:      boolean;              // �A���t�@�`�����l���̗L��
   FOrgBitCount:    integer;              // �ǂݍ��񂾃f�[�^�̖{���̃r�b�g��
   FBGColor:        COLORREF;             // �w�i�F(�������p)
   FTransColor:     COLORREF;             // �����F(�������p)
   FText:           string;               // �R�����g��(�������p)
   FGamma:          double;               // �K���}�l
   FPassword:       string;               // �p�X���[�h
   FShiftRGB:       integer;              // �e�v�f�̃V�t�g��
   FUnitSpecifier:  TGLDPNGUnitSpecifier; // �𑜓x�P��
   FWidthSpecific:  integer;              // ���𑜓x
   FHeightSpecific: integer;              // �c�𑜓x
   FMacBinaryFlag:  boolean;              // �}�b�N�o�C�i���`�F�b�N�̗L��
   FNowTime:        boolean;              // ���ݎ��Ԃ��o��
   FTime:           TPNGTime;             // �w�莞��
   FChrm:           TPNGChromaticities;   // �F�x���
   FGIFExt:         TPNGGIFExtension;     // GIF�f�[�^
   FRead16BitFlag:  boolean;              // 16BIT�s�N�Z���ǂݍ��ݗL��

   FOnPassword:     TGLDPNGPasswordEvent; // �p�X���[�h���̓C�x���g
   FOnEncode:       TGLDPNGDECodeEvent;   // �Í����C�x���g
   FOnDecode:       TGLDPNGDECodeEvent;   // �������C�x���g

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


//------- Create => �N���X�쐬


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


//------- Destroy => �N���X�J��


destructor TGLDPNG.Destroy;
begin
 if FABmp<>nil then FABmp.Free;
 if FImg<>nil then FImg.Free;
 inherited;
end;


//------- SetIDATSize => IDAT�T�C�Y�ݒ�


procedure TGLDPNG.SetIDATSize(n: integer);
begin
 if (n<256) or (n>100000) then
  raise EGLDPNG.Create('PNG Param: Err IDAT Size(min:256  max:100000)');
 FIDATSize:=n;
end;


//------- SaveToStream => PNG����������


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
  // �p�����[�^�ݒ�
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
  // �Z�[�u
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


//------- LoadFromStream => PNG�œǂݍ���


procedure TGLDPNG.LoadFromStream(Stream: TStream);
var
 pngstream: TGLDPNGReadStream;
 img: TGLDBmp;
 oldevt: TProgressEvent;

begin
 pngstream:=TGLDPNGReadStream.Create;
 img:=GetImage;
 try
  // �p�����[�^���
  pngstream.OnDecode      :=FOnDecode;
  pngstream.OnPassword    :=FOnPassword;
  pngstream.Password      :=FPassword;
  pngstream.MacBinaryCheck:=FMacBinaryFlag;
  pngstream.Read16Bit     :=FRead16BitFlag;
  pngstream.Time          :=@FTime;
  pngstream.Chromaticities:=@FChrm;
  pngstream.GIFExtension  :=@FGIFExt;
  // �����A���t�@�`�����l���r�b�g�}�b�v�N���A
  if FABmp<>nil then FABmp.Assign(nil);
  // ���[�h
  pngstream.AlphaBitmap:=GetAlphaBitmap;

  oldevt:=img.OnProgress;
  if Assigned(OnProgress) then img.OnProgress:=OnProgress;
  pngstream.LoadFromStream(img,stream,0);
  img.OnProgress:=oldevt;

  // ���[�h�f�[�^���
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


//------- AlphaBitmapAssign => �����ɂ���A���t�@�`�����l���ɃR�s�[


procedure TGLDPNG.AlphaBitmapAssign(source: TGraphic);
begin
 // �����N�͉���
 FABmpIn:=nil;

 if source is TGLDPNG then
  begin
   // �����A���t�@�`�����l�����R�s�[����
   FABmp.Assign(TGLDPNG(source).FABmp);
  end
 else
  FABmp.Assign(Source);
end;


//------- AlphaBitmapAssignTo => ���ݓ����ɂ���A���t�@�`�����l���r�b�g�}�b�v���R�s�[


function TGLDPNG.AlphaBitmapAssignTo(dest: TGraphic): boolean;
begin
 result:=not FABmp.Empty;
 if result and (dest<>nil) then dest.Assign(FABmp);
end;


//------- FreeAlphaBitmap => ���ݓ����ɂ���A���t�@�`�����l���r�b�g�}�b�v���N���A


procedure TGLDPNG.FreeAlphaBitmap;
begin
 FABmp.Assign(nil);
end;


//------- ���s���ǂݍ���(IDE�p)


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
  // �����A���t�@�`�����l���r�b�g�}�b�v�N���A
  FABmpIn:=nil; FImgIn:=nil;
  if FABmp<>nil then FABmp.Assign(nil);
  png.AlphaBitmap:=FABmp;
  // ���[�h
  png.LoadFromStream(FImg,stream,0);
  // ���[�h�f�[�^���
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


//------ ���\�[�X������������(IDE�p)


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
    // �p�����[�^�ݒ�
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
    // �Z�[�u
    png.SaveToStream(FImg,stream);
   finally
    png.Free;
   end;
  end;
end;
{$ENDIF}


//------- SetTransparent => ���ߎw��


procedure TGLDPNG.SetTransparent(Value: Boolean);
begin
 if not FTransFlag then
  begin
   if GetImage.Transparent<>Value then GetImage.Transparent:=Value;
  end;
 inherited SetTransparent(Value);
end;


//------- SetTransColor => �����F�ݒ�


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


//------- Assign => �ʃN���X�f�[�^�����R�s�[


procedure TGLDPNG.Assign(source: TPersistent);
begin
 // �����N�͉���
 FImgIn:=nil;

 if source is TGLDPNG then
  begin
   // �����r�b�g�}�b�v�ɃR�s�[����
   FImg.Assign(TGLDPNG(source).FImg);
   // �����A���t�@�`�����l�����R�s�[����
   FABmp.Assign(TGLDPNG(source).FABmp);
   // �������R�s�[
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


//------- AssignTo => �ʃN���X�ɃR�s�[


procedure TGLDPNG.AssignTo(dest: TPersistent);
begin
 if dest is TGraphic then
  dest.Assign(GetImage)
 else
  inherited AssignTo(dest);
end;


//------- LoadFromClipboardFormat => �N���b�v�{�[�h����ǂݍ���


procedure TGLDPNG.LoadFromClipboardFormat(AFormat: Word;
                                          AData: THandle;
                                          APalette: HPALETTE);
begin
 // �����r�b�g�}�b�v�ɓǂݍ���
 // ���̏ꍇ�A�����N�͉���
 FImgIn:=nil;
 FImg.LoadFromClipboardFormat(AFormat,AData,APalette);
 SetTransFlag(FImg);
end;


//------- SaveToClipBoardFormat => �N���b�v�{�[�h�ɏ�������


procedure TGLDPNG.SaveToClipboardFormat(var Format: Word;
                                        var Data: THandle;
                                        var APalette: HPALETTE);
begin
 GetImage.SaveToClipboardFormat(Format,Data,APalette);
end;


//------- Draw => �\��


procedure TGLDPNG.Draw(ACanvas: TCanvas; const Rect: TRect);
begin
 ACanvas.StretchDraw(Rect,GetImage);
end;


//------- GetEmpty => �C���[�W�̗L����Ԃ�


function  TGLDPNG.GetEmpty: boolean;
begin
 result:=GetImage.Empty;
end;


//------- GetPalette => �p���b�g��Ԃ�


function  TGLDPNG.GetPalette: HPALETTE;
begin
 result:=GetImage.Palette;
end;


//------- SetPalette => �p���b�g�w��


procedure TGLDPNG.SetPalette(hpal: HPALETTE);
begin
 GetImage.Palette:=hpal;
 Changed(self);
end;


//------- GetHeight => ������Ԃ�


function  TGLDPNG.GetHeight: integer;
begin
 result:=GetImage.Height
end;


//------- SetWidth => ����Ԃ�


function  TGLDPNG.GetWidth: integer;
begin
 result:=GetImage.Width;
end;


//------- SetWidth => ���w��


procedure TGLDPNG.SetWidth(n: integer);
var
 img: TGLDBmp;

begin
 img:=GetImage;
 if not img.Empty then img.Width:=n;
 // �A���t�@�`�����l�������ύX
 img:=GetAlphaBitmap;
 if not img.Empty then img.Width:=n;
 Changed(self);
end;


//------- SetHeight => �����w��


procedure TGLDPNG.SetHeight(n: integer);
var
 img: TGLDBmp;

begin
 img:=GetImage;
 if not img.Empty then img.Height:=n;
 // �A���t�@�`�����l�������ύX
 img:=GetAlphaBitmap;
 if not img.Empty then img.Height:=n;
 Changed(self);
end;


//------- GetAlphaBitmap => �ǂݏ����A���t�@�`�����l���r�b�g�}�b�v��Ԃ�


function TGLDPNG.GetAlphaBitmap: TGLDBmp;
begin
 if FABmpIn=nil then result:=FABmp else result:=FABmpIn;
end;


//------- SetABmp => �A���t�@�`�����l���r�b�g�}�b�v�����N


procedure TGLDPNG.SetABmp(obj: TGLDBmp);
begin
 if (obj<>FImgIn) and (obj<>nil) then FABmpIn:=obj else FABmpIn:=nil;
end;


//------- GetImage => �ǂݏ����ΏۃC���[�W��Ԃ�


function TGLDPNG.GetImage: TGLDBmp;
begin
 if FImgIn=nil then result:=FImg else result:=FImgIn;
end;


//------- SetImage => �C���[�W�����N


procedure TGLDPNG.SetImage(obj: TGLDBmp);
begin
 // �A���t�@�`�����l���̃����N�Ɠ������̂Ȃ�
 // �A���t�@�`�����l���̕��̃����N��؂�
 if (obj=FABmpIn) and (obj<>nil) then FABmpIn:=nil;
 FImgIn:=obj;
 if obj=nil then obj:=FImg;
 SetTransFlag(obj);
end;


//------- SetTransFlag => �C���[�W�ύX�ɔ������߂Ȃǂ�ύX


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


//------- SetGIFExt => GIF�f�[�^�ݒ�


procedure TGLDPNG.SetGIFExt(gif: TPNGGIFExtension);
begin
 FGifExt:=gif;
end;


//------- GetGifExt => GIF�f�[�^��Ԃ�


function TGLDPNG.GetGIFExt: TPNGGIFExtension;
begin
 result:=FGIFExt;
end;


//------- SetChrm => �F�x�ݒ�


procedure TGLDPNG.SetChrm(cm: TPNGChromaticities);
begin
 FChrm:=cm;
end;


//------- GetChrm => �F�x��Ԃ�


function TGLDPNG.GetChrm: TPNGChromaticities;
begin
 result:=FChrm;
end;


//------- SetTime => ���Ԑݒ�


procedure TGLDPNG.SetTime(tm: TPNGTime);
begin
 FTime:=tm;
end;


//------- GetTime => ���ԓǂݍ���


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
