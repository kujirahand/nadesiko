unit GLDPNGStream;

// ******************************************************
// *                                                    *
// *  GLDPNGStream ver 3.4.1                            *
// *                                   2001.07.08 ����  *
// *                                                    *
// *   1998-2001 CopyRight Tarquin All Rights Reserved. *
// *                                                    *
// ******************************************************
//
// PNG�t�H�[�}�b�g�̓ǂݏ����X�g���[���N���X�ł��B

{$I taki.inc}

// �ȉ��͎g�p�󋵂ɉ����Đݒ肵�Ă��������B
// �Ȃ��A�v���W�F�N�g�̏�����`�Ŏw�肵�Ă��������B
//
//  �EGLD_READONLY    �@�E�E�E �ǂݍ��݂݂̂̃N���X�쐬
//  �EGLD_SUPPORT_BIT15 �E�E�E bitcount=15(3���F)�̓ǂݍ��݃T�|�[�g
//  �EGLD_NOREVERSE_ALPHA   �E�E�E �A���t�@�`�����l����0=���� 255=�s�����ɕύX���܂�
//  
// �ȉ��͎g���܂���
//  �EGLD_SUPPORT_48BIT
//  �EGLD_SUPPORT_16BIT_ALPHA

interface

uses
 Windows, Classes, SysUtils, Graphics,
 SFunc, GLDZLIB, GLDStream;

const
 LFCR = #13+#10;  // ���s�R�[�h

 gpfJust   = 0;
 gpfNone   = 1;
 gpfSub    = 2;
 gpfUp     = 3;
 gpfAvg    = 4;
 gpfPaeth  = 5;

 gptNone   = 0;
 gptAdam7  = 1;

 gpuAspect = 0;
 gpuMeter  = 1;
 gpuInch   = 2;

type
 EGLDPNG     = class(EInvalidGraphic);

 TGLDPNGChunkFlag = (pcIHDR,pcIDAT,pcIEND,pcPLTE,pcTPNG);
 TGLDPNGChunk = set of TGLDPNGChunkFlag;

 TPNGDECodeEvent = procedure (sender: TObject; pbuf: pbyte; buflen,lineno: integer; password: string) of object;
 TPNGPasswordEvent = procedure (sender: TObject; var password: string) of object;

 PPNGTime=^TPNGTime;
 TPNGTime=packed record
  Year:   Word;
  Month:  byte;
  Day:    byte;
  Hour:   byte;
  Minute: byte;
  Second: byte;
 end;

 PPNGChromaticities=^TPNGChromaticities;
 TPNGChromaticities=packed record
  White_PX: DWORD;
  White_PY: DWORD;
  Red_X:    DWORD;
  Red_Y:    DWORD;
  Green_X:  DWORD;
  Green_Y:  DWORD;
  Blue_X:   DWORD;
  Blue_Y:   DWORD;
 end;

 PPNGGIFExtension=^TPNGGIFExtension;
 TPNGGIFExtension=packed record
  DisposalMethod: byte;
  UserInputFlag:  byte;
  DelayTime:      Word;
 end;


{$IFNDEF GLD_READONLY}
 TGLDPNGWriteStream=class(TGLDCustomGraphicWriteStream)
   private
     FPNGInfo:        TGLDPNGInfo;
     FIDATSize:       integer;              // IDAT�̃T�C�Y
     FCompressLevel:  integer;              // ZLIB���k�I�v�V�����ݒ�
     FFilterType:     integer;              // ���k���̎g�p�t�B���^�[
     FInterlaceType:  integer;              // �C���^�[���[�X�̎��
     FGrayScale:      boolean;              // �O���C�X�P�[���ۑ�
     FBGColor:        COLORREF;             // �w�i�F(�������p)
     FTransColor:     COLORREF;             // �����F(�������p)
     FText:           string;               // �R�����g��(�������p)
     FGamma:          double;               // �K���}�l
     FUnitSpecifier:  integer;              // �𑜓x�P��
     FWidthSpecific:  integer;              // ���𑜓x
     FHeightSpecific: integer;              // �c�𑜓x
     FShiftRGB:       integer;              // �e�E�V�t�g��
     FPassword:       string;               // �p�X���[�h�f�[�^

     FAlphaFlag:      boolean;              // �A���t�@�`�����l���̗L��
     FGrayOK:         boolean;              // �O���C�X�P�[���ۑ��n�j�H
     FAlpha256OK:     boolean;              // �Q�T�U�F�{�A���t�@�ۑ��n�j�H(���[�J��)
     FPassWidth:      integer;              // ���̃p�X�ł̉��ǂݍ��݃s�N�Z����
     FInterStartX:    integer;              // �C���^���[�X�J�n���W
     FInterIncX:      integer;              // �C���^���[�X�����W���Z�l
     FInterStartAX:   integer;              // �C���^���[�X�J�n���W(Alpha�p)
     FInterIncAX:     integer;              // �C���^���[�X�����W���Z�l(Alpha�p)
     FBufMemPtr:      pointer;              // �o�b�t�@�擪�|�C���^

     FAlphaBmp,FAmp:  TGLDBmp;              // �A���t�@�`�����l���ۑ��Ώ�Bitmap
     FDestBitCount:   integer;              // PNG�ۑ�����ꍇ�̃r�b�g��
     FOrgBitCount:    integer;              // �ۑ�����Bitmap�̃r�b�g��
     FSrcLineSize:    integer;              // �ۑ�����Bitmap�̕��̃o�C�g��

     FSigflg:         boolean;              // �V�O�l�X�`���o�́H
     FAlpha256flg:    boolean;              // 256�F�{�A���t�@�o�́H(���[�J��)
     FNowTime:        boolean;              // �������̏o��
     FTime:           PPNGTime;             // �w�莞��
     FChrm:           PPNGChromaticities;   // �F�x���
     FGIFExt:         PPNGGIFExtension;     // GIF�f�[�^

     FOnEncode:       TPNGDECodeEvent;      // �Í����C�x���g
     FPalGrayIndex:   array [0..255] of byte; // �O���C�X�P�[���ϊ����̃e�[�u��

     procedure WritePLTE;
     procedure WriteIHDR;
     procedure WriteImage;
     procedure WritetExt;
     procedure WritepHYs;
     procedure WritetRNS;
     procedure WritebKGD;
     procedure WritegAMA;
     procedure WritesBIT;
     procedure WritetpNg;
     procedure WritetIMe;
     procedure WritecHRM;
     procedure WritegIFg;
     procedure WriteTextMes(keyword,mes: AnsiString);
     procedure WriteChunk(cname: DWORD; data: pointer; len: integer);
     procedure GetBufMem;
     procedure FreeBufMem;
     procedure GetLinePixels(ps,pa: pbyte);
     procedure SetGrayScalePaletteIndex;

     procedure SetIDATSize(n: integer);
   protected
     procedure WriteStream; override;
   public
     constructor Create; override;

     property CompressLevel:  integer            read FCompressLevel write FCompressLevel;
     property FilterType:     integer            read FFilterType write FFilterType;
     property IDATSize:       integer            read FIDATSize write SetIDATSize;
     property InterlaceType:  integer            read FInterlaceType write FInterlaceType;
     property GrayScale:      boolean            read FGrayScale write FGrayScale;
     property AlphaBitmap:    TGLDBmp            read FAlphaBmp write FAlphaBmp;
     property BGColor:        COLORREF           read FBGColor write FBGColor;
     property TransColor:     COLORREF           read FTransColor write FTransColor;
     property Text:           string             read FText write FText;
     property Gamma:          double             read FGamma write FGamma;
     property ShiftRGB:       integer            read FShiftRGB write FShiftRGB;
     property UnitSpecifier:  integer            read FUnitSpecifier write FUnitSpecifier;
     property WidthSpecific:  integer            read FWidthSpecific write FWidthSpecific;
     property HeightSpecific: integer            read FHeightSpecific write FHeightSpecific;

     property Signature:      boolean            read FSigflg write FSigflg;
     property Alpha256:       boolean            read FAlpha256flg write FAlpha256flg;
     property NowTime:        boolean            read FNowTime write FNowTime;
     property Time:           PPNGTime           read FTime write FTime;
     property Chromaticities: PPNGChromaticities read FChrm write FChrm;
     property GIFExtension:   PPNGGIFExtension   read FGIFExt write FGIFExt;

     property Password:       string             read FPassword write FPassword;
     property OnEncode:       TPNGDECodeEvent    read FOnEncode write FOnEncode;
 end;
 {$ENDIF}

 TGLDPNGReadStream=class(TGLDCustomGraphicReadStream)
   private
     FPNGInfo:        TGLDPNGInfo;          // ZLIB�A�N�Z�X�p�f�[�^
     FBufMemPtr:      pointer;              // �o�b�t�@�������|�C���^
     FLineBuf:        pbyte;                // �ϊ���̂P���C���s�N�Z���f�[�^�p�o�b�t�@
     FAlphaBuf:       pbyte;                // �P���C���A���t�@�f�[�^�p�o�b�t�@

     FChunkSize:      integer;              // �ǂݍ��ݒ��̃`�����N�T�C�Y
     FChunkName:      integer;              // �ǂݍ��ݒ��̃`�����N�^�C�v
     FChunkFlag:      TGLDPNGChunk;         // �ʉ߃`�����N�t���O

     FMaxPass:        integer;              // �C���^���[�X�C���[�W�̃p�X��
     FPassWidth:      integer;              // ���̃p�X�ł̉��ǂݍ��݃s�N�Z����
     FPassLineSize:   integer;              // �ϊ���̓]���o�C�g��
     FInterStartX:    integer;              // �C���^���[�X�J�n���W
     FInterIncX:      integer;              // �C���^���[�X�����W���Z�l
     FInterAStartX:   integer;              // �C���^���[�X�J�n���W(Alpha�p)
     FInterAIncX:     integer;              // �C���^���[�X�����W���Z�l(Alpha�p)
     FPass:           string;               // �p�X���[�h
     FAlpha256OK:     boolean;              // 256�F�{�A���t�@�ǂݍ��݁H

     FAlphaFlag:      boolean;              // �A���t�@�`�����l���̗L��
     FGrayFlag:       boolean;              // �O���C�X�P�[���̗L��
     FConvertPAlpha:  boolean;              // �p���b�g�A���t�@�̕ϊ��̕K�v�̗L��
     FInterlaceType:  integer;              // �C���^���[�X�^�C�v
     FColorType:      integer;              // �J���[�^�C�v
     FAlphaBmp,FAmp:  TGLDBmp;              // �A���t�@�`�����l���ۑ��pBitmap
     FGamma:          double;               // �K���}�l
     FShiftRGB:       integer;              // �e�E�V�t�g��
     FTime:           PPNGTime;             // �ۑ�����
     FChrm:           PPNGChromaticities;   // �F�x���
     FGIFExt:         PPNGGIFExtension;     // GIF�f�[�^

     FBGColor:        COLORREF;             // �w�i�F
     FTransColor:     COLORREF;             // �����F
     FTransBuf:       array [0..255] of byte; // �p���b�g�A���t�@�p�o�b�t�@

     ConvertProc:     function :pbyte of Object;           // �ǂݍ��݃f�[�^�R���o�[�^
     CopyProc:        procedure (pd,ps: pbyte) of Object; // DIB�ւ̓]��
     CopyAlphaProc:   procedure (pd,ps: pbyte) of Object; // �A���t�@�`�����l���]��

     FSigflg:         boolean;              // �V�O�l�X�`���`�F�b�N�H
     FAlpha256flg:    boolean;              // 256�F�{�A���t�@�ǂݍ��݁H(���[�J��)
     FRead16BitFlag:  boolean;              // 16Bit�s�N�Z���ǂݍ��ݗL��

     FPassword:       string;               // �p�X���[�h
     FOnPassword:     TPNGPasswordEvent;    // �p�X���[�h���̓C�x���g
     FOnDecode:       TPNGDECodeEvent;      // �Í����C�x���g

     procedure CheckImageFormat;
     procedure GetBufMem;
     procedure FreeBufMem;
     procedure ConvertPAlpha;

     procedure SkipChunk;
     procedure ReadImage;
     procedure ReadHeader;
     procedure ReadPalette;
     procedure EndChunk;
     procedure ReadAspectData;
     procedure ReadTransColor;
     procedure ReadBGColor;
     procedure ReadText;
     procedure ReadsBIT;
     procedure ReadGamma;
     procedure ReadTime;
     procedure ReadChrm;
     procedure ReadGIFExt;
     procedure ReadGLDData;
     procedure ReadChunk;

     procedure SetPixels_Inter1(pd,ps: pbyte);
     procedure SetPixels_Inter4(pd,ps: pbyte);
     procedure SetPixels_Inter8(pd,ps: pbyte);
     procedure SetPixels_Inter16(pd,ps: pbyte);
     procedure SetPixels_Inter24(pd,ps: pbyte);
     procedure SetPixels_Inter32(pd,ps: pbyte);
     procedure SetPixels_InterA(pd,ps: pbyte);
     procedure SetPixels_Normal(pd,ps: pbyte);
     procedure SetPixels_Normal_A(pd,ps: pbyte);
     function  ChangeGray8A: pbyte;
     function  ChangeGray16: pbyte;
     function  ChangeGray16A: pbyte;
     function  Change2to4: pbyte;
     function  RGBAtoBGRA64: pbyte;
     function  RGBAtoBGRA32: pbyte;
     function  RGBAtoBGRA16: pbyte;
     function  RGBtoBGR48: pbyte;
     function  RGBtoBGR24: pbyte;
     function  RGBtoBGR16: pbyte;
     function  ConvertNone: pbyte;
   protected
     procedure CreateDIB; override;
     procedure ReadStream; override;
   public
     constructor Create; override;
     property AlphaChannel:   boolean            read FAlphaFlag write FAlphaFlag;
     property GrayScale:      boolean            read FGrayFlag;
     property InterlaceType:  integer            read FInterlaceType;
     property BGColor:        COLORREF           read FBGColor;
     property TransColor:     COLORREF           read FTransColor;
     property Gamma:          double             read FGamma;
     property ShiftRGB:       integer            read FShiftRGB;
     property Time:           PPNGTime           read FTime write FTime;
     property Chromaticities: PPNGChromaticities read FChrm write FChrm;
     property GIFExtension:   PPNGGIFExtension   read FGIFExt write FGIFExt;

     property Signature:      boolean            read FSigflg write FSigflg;
     property Alpha256:       boolean            read FAlpha256flg write FAlpha256flg;
     property Read16Bit:      boolean            read FRead16BitFlag write FRead16BitFlag;
     property AlphaBitmap:    TGLDBmp            read FAlphaBmp write FAlphaBmp;

     property Password:       string             read FPassword write FPassword;
     property OnPassword:     TPNGPasswordEvent  read FOnPassword write FOnPassword;
     property OnDecode:       TPNGDECodeEvent    read FOnDecode write FOnDecode;
 end;

function PNGTime(y,m,d,h,mi,s: integer): TPNGTime;
function SystemPNGTime: TPNGTime;

implementation

uses
 TkZLIB;

type
 PPNGRGB=^TPNGRGB;
 TPNGRGB=record
  R,G,B: byte;
 end;

 PPNGRGBA=^TPNGRGBA;
 TPNGRGBA=record
  R,G,B,A: byte;
 end;

const
 IHDR = $49484452;
 IDAT = $49444154;
 IEND = $49454E44;
 PLTE = $504C5445;
 bKGD = $624B4744;
 tRNS = $74524E53;
 sPLT = $73504C54;
 hIST = $68495354;
 cHRM = $6348524D;
 gAMA = $67414D41;
 oFFs = $6F464673;
 pCAL = $7043414C;
 sCAL = $7343414C;
 iCCP = $69434350;
 sRGB = $73524742;
 pHYs = $70485973;
 sBIT = $73424954;
 tXt  = $74455874; // TEXT�v���p�e�B�ƂԂ��邽��
 tME  = $74494D45; // TIME�֐��ƂԂ��邽��
 zTXt = $7A545874;
 gIFg = $67494667;

 tpNG = $74704E47; // �V�X�e���p�f�[�^�`�����N

 GLDPNG3Chunk = $474C4433; // 'GLD3' �`�����N�o�[�W����

var
 pass_start_X:  array [0..6] of integer=(0, 4, 0, 2, 0, 1, 0);
 pass_inc_X:    array [0..6] of integer=(8, 8, 4, 4, 2, 2, 1);
 pass_start_Y:  array [0..6] of integer=(0, 0, 4, 0, 2, 0, 1);
 pass_inc_Y:    array [0..6] of integer=(8, 8, 8, 4, 4, 2, 2);

var
 png_sig:         array [0..7] of byte=(
                    $89,$50,$4e,$47,$0d,$0a,$1a,$0a);


//***************************************************
//*   �⏕�֐�                                      *
//***************************************************


//------- PNGTime => PNG�^�C���ɕϊ�


function PNGTime(y,m,d,h,mi,s: integer): TPNGTime;
begin
 with result do
 begin
  Year:=y;
  Month:=m;
  Day:=d;
  Hour:=h;
  Minute:=mi;
  Second:=s;
 end;
end;


//------ SystemPNGTime => �V�X�e������(UTC)��PNG�^�C���ɕϊ�


function SystemPNGTime: TPNGTime;
var
 tm: TSystemTime;

begin
 GetSystemTime(tm);
 with result do
 begin
  Year:=tm.wYear;
  Month:=tm.wMonth;
  Day:=tm.wDay;
  Hour:=tm.wHour;
  Minute:=tm.wMinute;
  Second:=tm.wSecond;
 end;
end;


//------- GetCallBackCount => �R�[���o�b�N���J�E���g


function GetCallBackCount(itype: integer; h: integer): integer;
begin
 case itype of
  gptNone:
   result:=h;
  gptAdam7:
   begin
    result:=((h+7) shr 3)*2 + //pass 3 5 7�ȊO
            ((h+3) shr 2)   +
            ((h+1) shr 1);
    if h>=5 then result:=result+((h+3) shr 3);  // pass 3
    if h>=3 then result:=result+((h+1) shr 2);  // pass 5
    if h>=2 then result:=h shr 1;               // pass 7
   end;
 end;
end;


{$IFNDEF GLD_READONLY}

//***************************************************
//*   TGLDPNGWriteStream                            *
//***************************************************


type
 TPNGHeader=packed record
  Width:         DWORD;
  Height:        DWORD;
  BitDepth:      byte;
  ColorType:     byte;
  CompressType:  byte;
  FilterType:    byte;
  InterlaceType: byte;
 end;


//------- png_ZlibWrite => ZLIB�f�[�^�f���o��


function png_ZlibWrite(pg: PGLDZLIBInfo): integer;
begin
 with TGLDPNGWriteStream(pg^.owner) do
 begin
  // IDAT�Ƃ��ēf���o��
  WriteChunk(IDAT,pg^.zbuf,pg^.zbuflen-pg^.zstream.avail_out);
  result:=0;
 end;
end;


//------- Create => �N���X�쐬


constructor TGLDPNGWriteStream.Create;
begin
 inherited;
 FSigflg:=TRUE;
 FPNGInfo.zinfo.IOProc:=png_ZlibWrite;
 FPNGInfo.zinfo.owner:=self;
 FIDATSize:=32768;
 FCompressLevel:=Z_DEFAULT_COMPRESSION;
 FFilterType:=gpfNone;
 FTransColor:=GLDNONECOLOR;
 FBGColor:=GLDNONECOLOR;
 FNowTime:=TRUE;
end;


//------- WriteStream => �������݃��C��


procedure TGLDPNGWriteStream.WriteStream;
begin
 // ������
 FAmp:=nil;
 FAlphaFlag:=FALSE;
 FGrayOK:=FALSE;
 FAlpha256OK:=FALSE;
 try
  // �P�s�N�Z���̃r�b�g���擾
  FOrgBitCount:=GLDBitCount(Image.PixelFormat);
  if (FOrgBitCount=15) or (FOrgBitCount=16) then
   FDestBitCount:=24
  else
   FDestBitCount:=FOrgBitCount;

  // Bmp�ڑ��H�A���t�@�`�����l���`�F�b�N
  if Assigned(FAlphaBmp) then
   if (Image<>FAlphaBmp) then
    if (not FAlphaBmp.Empty) and (FAlphaBmp.Width=Image.Width)
     and (FAlphaBmp.Height=Image.Height) and
      (FAlphaBmp.PixelFormat=pf8bit) then
       FAmp:=FAlphaBmp;

  if (FAlpha256flg and (FOrgBitCount=8) and (FAmp<>nil) and (not FGrayScale)) then FAlpha256OK:=TRUE;

  while TRUE do
  begin
   // �R�[���o�b�N�X�^�[�g
   StartCallBack;
   SetCallBackParam(1,10,30);
   // �w�b�_��������
   if FSigflg then WriteByte(@png_sig,8);
   WriteIHDR;
   WritetIMe;
   WritetEXt;
   WriteTextMes('Software','GLDPNG ver 3.4');
   WritetpNg;
   WritegIFg;
   WritegAMA;
   WritecHRM;
   WritesBIT;
   WritePLTE;
   WritebKGD;
   WritetRNS;
   WritepHYs;
   // �R�[���o�b�N
   DoCallBack(10);
   if CancelFlag then Break;
   // �C���[�W��������
   WriteImage;
   if CancelFlag then Break;
   // IEND�`�����N��������
   WriteChunk(IEND,nil,0);
   // �R�[���o�b�N�I��
   EndCallBack;
   Break;
  end;
 finally
  ZLIBEncodeFinish(@(FPNGInfo.zinfo));
  FreeBufMem;
 end;
end;


//------- SetIDATSize => IDAT�T�C�Y�ݒ�


procedure TGLDPNGWriteStream.SetIDATSize(n: integer);
begin
 if (n<256) or (n>100000) then
  raise EGLDPNG.Create('Write PNG Param: Err IDAT Size(min:256  max:100000)');
 FIDATSize:=n;
end;


//-----------------------------------------------
// �Q�E�S�o�C�g�ݒ�֐�
//-----------------------------------------------


//------- SetMDWord => �S�o�C�g���


procedure SetMDWord(var pd; n: integer);
begin
 TArrayByte(pd)[0]:=(n shr 24) and $FF;
 TArrayByte(pd)[1]:=(n shr 16) and $FF;
 TArrayByte(pd)[2]:=(n shr  8) and $FF;
 TArrayByte(pd)[3]:=n and $FF;
end;


//------- SetMWord => �Q�o�C�g���


procedure SetMWord(var pd; n: integer);
begin
 TArrayByte(pd)[0]:=(n shr  8) and $FF;
 TArrayByte(pd)[1]:=n and $FF;
end;


//---------------------------------------------------------
//  �`�����N����
//---------------------------------------------------------


//------- WriteChunk => �`�����N��������


procedure TGLDPNGWriteStream.WriteChunk(cname: DWORD; data: pointer; len: integer);
var
 crc: integer;
 chunk_name: array [0..3] of byte;

begin
 // CRC�N���A
 crc:=crc32(0,nil,0);
 // �`�����N���E�`�����N�f�[�^�o�C�g����������
 WriteMDWord(len);
 WriteMDWord(cname);
 // �`�����N����CRC�v�Z
 SetMDWORD(chunk_name,cname);
 crc:=crc32(crc,@chunk_name,4);
 if (data<>nil) and (len>0) then
  begin
   // �`�����N�f�[�^��������
   WriteByte(data,len);
   // �`�����N�f�[�^��CRC�v�Z
   crc:=crc32(crc,data,len);
  end;
 // CRC��������
 WriteMDWORD(crc);
end;


//------- WritegIFg => gIFg�`�����N��������


procedure TGLDPNGWriteStream.WritegIFg;
begin
 if FGIFExt<>nil then
  if (FGIFExt^.DelayTime or FGIFExt^.DisposalMethod or FGIFExt^.UserInputFlag)<>0 then
   WriteChunk(gIFg,FGIFExt,sizeof(TPNGGIFExtension));
end;


//------- WritecHRM => cHRM�`�����N��������


procedure TGLDPNGWriteStream.WritecHRM;
var
 cm: TPNGChromaticities;

begin
 if FChrm<>nil then
  if (FChrm^.White_PX>0) and (Fchrm^.White_PY>0) then
   begin
    with cm do
    begin
     SetMDWORD(White_PX,FChrm^.White_PX);
     SetMDWORD(White_PY,FChrm^.White_PY);
     SetMDWORD(Red_X,FChrm^.Red_X);
     SetMDWORD(Red_Y,FChrm^.Red_Y);
     SetMDWORD(Green_X,FChrm^.Green_X);
     SetMDWORD(Green_Y,FChrm^.Green_Y);
     SetMDWORD(Blue_X,FChrm^.Blue_X);
     SetMDWORD(Blue_Y,FChrm^.Blue_Y);
    end;
    WriteChunk(cHRM,@cm,sizeof(TPNGChromaticities));
   end;
end;


//------- WritetIMe => tIMe�`�����N��������


procedure TGLDPNGWriteStream.WritetIMe;
var
 tm: TPNGTime;
 n: integer;

begin
 if FNowTime then
  tm:=SystemPNGTime
 else
  if FTime<>nil then
   Move(FTime^,tm,sizeof(TPNGTime))
  else
   Exit;

 n:=tm.Year;
 if (n>0) and
    ((tm.Month>0) and (tm.Month<13)) and
    ((tm.Day>0) and (tm.Day<32)) and
    ((tm.Hour>=0) and (tm.Hour<24)) and
    ((tm.Minute>=0) and (tm.Minute<60)) and
    ((tm.Second>=0) and (tm.Month<61)) then
  begin
   SetMWord(tm.Year,n);
   WriteChunk(tMe,@tm,sizeof(TPNGTime));
  end;
end;


//------- GetGray => �O���C�X�P�[���l�ɕϊ�


function GetGray(bcnt: integer; cor: COLORREF): integer;
var
 n: integer;

begin
 n:=((cor and $FF)*77+((cor shr 8) and $FF)*150+((cor shr 16) and $FF)*29) shr 8;
 case bcnt of
  1: if n<128 then result:=0 else result:=1;
  4: result:=n shr 4;
 else
  result:=n;
 end;
end;


//------- WritebKGD => bKGD�`�����N��������


procedure TGLDPNGWriteStream.WritebKGD;
var
 cordat1: array [0..2] of word;
 i,n,m: integer;
 cor: COLORREF;

begin
 cor:=FBGColor;

 if cor<>GLDNONECOLOR then
  if FGrayOK and (not FAlpha256OK) then
   begin
    if ((cor and $1000000)>0) and (FOrgBitCount<=8) then
     cor:=GetPaletteColor(Image.Palette,cor and $FF);
    SetMWORD(cordat1,GetGray(FOrgBitCount,cor));
    WriteChunk(bKGD,@cordat1,2)
   end
  else
   case FOrgBitCount of
    1,4,8: // �C���f�B�b�N�X�Z�[�u
     begin
      if ((cor and $1000000)>0) then
       n:=cor and $FF
      else
       n:=SFunc.GetNearestPaletteIndex(Image.Palette,cor and $FFFFFF);
      if n>=0 then
       begin
        cordat1[0]:=n;
        WriteChunk(bKGD,@cordat1,1);
       end;
     end;
    15,16,24,32: // RGB
     begin
      SetMWord(cordat1[0],cor and $FF);
      SetMWord(cordat1[1],(cor shr 8) and $FF);
      SetMWord(cordat1[2],(cor shr 16) and $FF);
      WriteChunk(bKGD,@cordat1,6);
     end;
   end;
end;


//------- WritetRNS => �����F�ۑ�


procedure TGLDPNGWriteStream.WritetRNS;
var
 padat: array [0..255] of byte;
 n: integer;
 no: COLORREF;

begin
 // �A���t�@�`�����l��������Ȃ珑�����߂Ȃ�
 if FAlphaFlag then Exit;
// no:=GLDNONECOLOR;
// if Image.Transparent then
//  no:=Image.TransparentColor
// else
  no:=FTransColor;
 if no<>GLDNONECOLOR then
  if FGrayOK then
   begin
    if ((no and $1000000)>0) and (FOrgBitCount<=8) then
     no:=GetPaletteColor(Image.Palette,no and $FF);
    SetMWORD(padat,GetGray(FOrgBitCount,no));
    WriteChunk(tRNS,@padat,2)
   end
  else
   case FOrgBitCount of
    1,4,8:
     begin
      if ((FTransColor and $1000000)>0) then
       no:=FTransColor and $FF
      else
       no:=SFunc.GetNearestPaletteIndex(Image.Palette,no and $FFFFFF);
      FillChar(padat,sizeof(padat),255);
      padat[no]:=0;
      WriteChunk(tRNS,@padat,no+1);
     end;
    15,16,24,32:
     begin
      SetMWord(padat[0],no and $FF);
      SetMWord(padat[2],(no shr 8) and $FF);
      SetMWord(padat[4],(no shr 16) and $FF);
      WriteChunk(tRNS,@padat,6);
     end;
   end;
end;


//------- WritepHYs => �𑜓x�ۑ�


procedure TGLDPNGWriteStream.WritepHYs;
var
 dat: array [0..8] of byte;
 x,y,m: integer;
 mode: integer;

begin
 mode:=FUnitSpecifier;
 x:=FWidthSpecific;
 y:=FHeightSpecific;

 // �����H
 if (x<=0) or (y<=0) then Exit;
 case mode of
  gpuAspect: // �A�X�y�N�g�䗦
     m:=0;
  gpuMeter: // ���[�g��
     m:=1;
  gpuInch: // �C���` => ���[�g��
    begin
     x:=Round(Int(((x*100)/254)*100));
     y:=Round(Int(((y*100)/254)*100));
     m:=1;
    end;
 end;
 SetMDWord(dat[0],x);
 SetMDWord(dat[4],y);
 dat[8]:=m;
 WriteChunk(pHYs,@dat,9);
end;


//------- WritetpNg => GLDPNG�`�����N�ۑ�


procedure TGLDPNGWriteStream.WritetpNg;
var
 pp,pd: pbyte;
 pc: pchar;
 len,len1: integer;

begin
 len:=8;
 GetMem(pp,len);
 pd:=pp;
 try
  FillChar(pp^,len,0);
  SetMDWord(pd^,GLDPNG3Chunk); Inc(pd,4);
  if (FPassword<>'') and (Assigned(FOnEncode)) then pd^:=1;
  Inc(pd);
  if FAlpha256OK then pd^:=1 else pd^:=0;
  Inc(pd);
  SetMWord(pd^,0);
  WriteChunk(tpNg,pp,len);
 finally
  FreeMem(pp);
 end;
end;


//------- WriteTextMes => �e�L�X�g�ۑ�


procedure TGLDPNGWriteStream.WriteTextMes(keyword,mes: AnsiString);
var
 pp,pd: pchar;
 len1,len2: integer;

begin
 if mes<>'' then
  begin
   len1:=Length(AnsiString(keyword));
   // 79�����ȏ�̓G���[
   if len1>79 then Exit;
   len2:=Length(AnsiString(mes));
   GetMem(pp,len1+len2+1);
   try
    pd:=pp;
    Move(pchar(keyword)^,pd^,len1);
    Inc(pd,len1);
    pd^:=char(0);
    Inc(pd);
    Move(pchar(mes)^,pd^,len2);
    WriteChunk(tXt,pp,len1+len2+1);
   finally
    FreeMem(pp);
   end;
  end;
end;


//------- WritetEXt => �e�L�X�g�ۑ�


procedure TGLDPNGWriteStream.WritetExt;
var
 mes: string;

begin
 if FText<>'' then mes:=FText else mes:='';
 WriteTextMes('Comment',mes);
end;


//------- WritegAMA => �K���}�`�����N��������


procedure TGLDPNGWriteStream.WritegAMA;
var
 dat: array [0..3] of byte;
 n: integer;

begin
 n:=Trunc(FGamma*100000);
 if n>0 then
  begin
   SetMDWord(dat,n);
   WriteChunk(gAMA,@dat,4);
  end;
end;


//------- WritesBIT => sBIT�`�����N��������


procedure TGLDPNGWriteStream.WritesBIT;
var
 dat: array [0..3] of byte;
 n: integer;

begin
 // 16�r�b�g�摜�̏ꍇ����ɐݒ�
 if (FOrgBitCount=15) or (FOrgBitCount=16) then
  begin
   if (FOrgBitCount=15) then FShiftRGB:=$50505 else FShiftRGB:=$50605;
   if FAlphaFlag then FShiftRGB:=FShiftRGB or $8000000;
  end;
 if (FShiftRGB>0) and (not FGrayOK) then
  begin
   PDWORD(@dat[0])^:=FShiftRGB;
   if FAlphaFlag then n:=4 else n:=3;
   WriteChunk(sBIT,@dat,n);
  end;
end;


//------- WriteIHDR => IHDR�`�����N��������


procedure TGLDPNGWriteStream.WriteIHDR;
var
 hed: TPNGHeader;

begin
 with hed do
 begin
  SetMDWord(Width,Image.Width);
  SetMDWord(Height,Image.Height);
  if FGrayScale or FAlpha256OK then
   // �O���C�X�P�[���o��
   begin
    FGrayOK:=TRUE;
    if FDestBitCount>8 then
     begin
      BitDepth:=8;
      FPNGInfo.pixel_depth:=8;
      FDestBitCount:=8;
     end
    else
     begin
      BitDepth:=FDestBitCount;
      FPNGInfo.pixel_depth:=FDestBitCount;
     end;
    if (FAmp<>nil) and (BitDepth=8) then
     begin
      FAlphaFlag:=TRUE;
      FPNGInfo.pixel_depth:=16;
      ColorType:=4;
     end
    else
     ColorType:=0;
   end
  else
   // �J���[�o��
   case FDestBitCount of
    1..8:
     begin
      BitDepth:=FDestBitCount;
      FPNGInfo.pixel_depth:=FDestBitCount;
      ColorType:=3;
     end;
    24,32:
     begin
      BitDepth:=8;
      if FAmp<>nil then
       begin
        FAlphaFlag:=TRUE;
        ColorType:=6;
        FPNGInfo.pixel_depth:=32;
       end
      else
       begin
        FPNGInfo.pixel_depth:=24;
        ColorType:=2;
       end;
     end;
   end;
  FSrcLineSize:=GetLineSize(Image.Width,FDestBitCount);
  FPNGInfo.bitcnt:=FDestBitCount;

  CompressType:=0;
  FilterType:=0;
  InterlaceType:=integer(FInterlaceType);
 end;
 WriteChunk(IHDR,@hed,sizeof(TPNGHeader));
end;


//------- WritePLTE => PLTE�`�����N��������


procedure TGLDPNGWriteStream.WritePLTE;
var
 i,j,len,cinc: integer;
 cor: COLORREF;
 ps,pd: PPNGRGB;

begin
 if (not FGrayOK) or (FAlpha256OK) then
  // �ʏ�p���b�g
  if FDestBitCount<=8 then
   begin
    with Image do
    begin
     GetMem(ps,sizeof(PGLDPalRGB)*256);
     GetMem(pd,sizeof(TPNGRGB)*256);
     try
      len:=GetPaletteColorTable(Palette,PGLDPalRGB(ps));
      if len>0 then
       begin
        for i:=0 to Pred(len) do
        begin
         PArrayByte(pd)^[i*3+0]:=PArrayRGB(ps)^[i].rgbRed;
         PArrayByte(pd)^[i*3+1]:=PArrayRGB(ps)^[i].rgbGreen;
         PArrayByte(pd)^[i*3+2]:=PArrayRGB(ps)^[i].rgbBlue;
        end;
        WriteChunk(PLTE,pd,len*sizeof(TPNGRGB));
       end;
     finally
      FreeMem(ps);
      FreeMem(pd);
     end;
    end;
   end;
end;


//------- GetBufMem => �o�b�t�@�������m��


procedure TGLDPNGWriteStream.GetBufMem;
var
 n,m,s: integer;
 p: pbyte;

begin
 FreeBufMem;
 n:=(GetLineSize(Image.Width,FPNGInfo.pixel_depth)+31+8) and (not 31);
 m:=(GetLineSize(Image.Width,FPNGInfo.pixel_depth)+31+8) and (not 31);
 GetMem(p,n*2 + m*2 + (258*sizeof(longint)) + 32);
 FBufMemPtr:=p;
 Inc(p,31);
 p:=pbyte(integer(p) and (not 31));
 FPNGInfo.outbuf:=p;
 Inc(p,n);
 FPNGInfo.prev_row:=p;
 Inc(p,n);
 FPNGInfo.filbuf1:=p;
 Inc(p,m);
 FPNGInfo.filbuf2:=p;
 Inc(p,m);
 FPNGInfo.hist:=p;
end;


//------- FreeBufMem => �o�b�t�@���������


procedure TGLDPNGWriteStream.FreeBufMem;
begin
 if FBufMemPtr<>nil then
  begin
   FreeMem(FBufMemPtr);
   FBufMemPtr:=nil;
  end;
end;


//------- WriteImage => �C���[�W�o��


procedure TGLDPNGWriteStream.WriteImage;
var
 w,h,ly,y,cbcnt,i,maxpass: integer;
 sx,sy,ycnt: integer;
 ps,pa,pp: pbyte;

begin
 pa:=nil;
 try
  // �������m��
  GetBufMem;

  // �O���C�X�P�[���p�ϊ��e�[�u���쐬
  if FGrayOK and (not FAlpha256OK) and (FOrgBitCount<=8) then SetGrayScalePaletteIndex;

  // ZLIB�ݒ�
  if (FCompressLevel>=0) and (FCompressLevel<=9) then
   i:=FCompressLevel
  else
   i:=Z_DEFAULT_COMPRESSION;

  ZLIBEncodeInit(@(FPNGInfo.zinfo),i,FIDATSize);
  // �p�����[�^�ݒ�
  FPNGInfo.compressmode:=integer(FFilterType);
  case FInterlaceType of
   gptNone:  maxpass:=0;
   gptAdam7: maxpass:=6;
  end;
  w:=Image.Width;
  h:=Image.Height;
  cbcnt:=1; SetCallBackParam(1,GetCallBackCount(FInterlaceType,h),0);

  for i:=0 to maxpass do
  begin
   case FInterlaceType of
    gptNone: // �m�[�}��
       begin
        FPassWidth:=w;
        ly:=h; sy:=0; ycnt:=1;
        FInterStartX:=0;
        FInterIncX:=1;
        FInterStartAX:=0;
        FInterIncAX:=1;
       end;
    gptAdam7: // �C���^���[�X
       begin
        case i of
         0: // pass 1
            begin
             FPassWidth:=((w+7) shr 3);
             ly:=((h+7) shr 3);
            end;
         1: // pass 2
            begin
             if w<5 then
              Continue
             else
              FPassWidth:=((w+3) shr 3);
             ly:=((h+7) shr 3);
            end;
         2: // pass 3
            begin
             FPassWidth:=((w+3) shr 2);
             if h<5 then
              Continue
             else
              ly:=((h+3) shr 3);
            end;
         3: // pass 4
            begin
             if w<3 then
              Continue
             else
              FPassWidth:=((w+1) shr 2);
             ly:=((h+3) shr 2);
            end;
         4: // pass 5
            begin
             FPassWidth:=((w+1) shr 1);
             if h<3 then
              Continue
             else
              ly:=((h+1) shr 2);
            end;
         5: // pass 6
            begin
             if w<2 then
              Continue
             else
              FPassWidth:=w shr 1;
             ly:=((h+1) shr 1);
            end;
         6: // pass 7
            begin
             FPassWidth:=w;
             if h<2 then
              Continue
             else
              ly:=h shr 1;
            end;
        end;
        sy:=pass_start_Y[i];
        ycnt:=pass_inc_Y[i];
        case FOrgBitCount of
         15,16: y:=2;
         24:    y:=3;
         32:    y:=4;
        else
         y:=1;
        end;
        FInterStartAX:=pass_start_X[i];
        FInterIncAX:=pass_inc_X[i];
        FInterStartX:=pass_start_X[i]*y;
        FInterIncX:=pass_inc_X[i]*y;
       end;
   end;

   FPNGInfo.linelen:=(((FPassWidth*FPNGInfo.pixel_depth)+7) shr 3)+1;
   FillChar(FPNGInfo.prev_row^,FPNGInfo.linelen,0);
   Dec(ly);

   for y:=ly downto 0 do
   begin
    ps:=Image.ScanLine[sy];
    if FAlphaFlag then pa:=FAmp.ScanLine[sy];
    // ���C���f�[�^�����o��
    GetLinePixels(ps,pa);
    // �Í���
    if (FPassword<>'') and Assigned(FOnEncode) then
     OnEncode(self,FPNGInfo.outbuf,FPNGInfo.linelen-1,cbcnt-1,FPassword);
    // �P���C���o��
    if png_write_line(@FPNGInfo)<0 then
     raise EGLDPNG.Create('Write Image (PNG): Write Error');
    // �|�C���^����
    pp:=FPNGInfo.outbuf;
    FPNGInfo.outbuf:=FPNGInfo.prev_row;
    FPNGInfo.prev_row:=pp;
    // ����
    Inc(sy,ycnt);
    // �R�[���o�b�N
    if ((cbcnt and 3)=2) or (h<4) then DoCallBack(cbcnt);
    Inc(cbcnt);
    if CancelFlag then Break;
   end;
   // �`�F�b�N
   if CancelFlag then Break;
  end;
 finally
  // �c���Ă���̂�f���o��
  ZLIBEncodeFlush(@(FPNGInfo.zinfo));
  ZLIBEncodeFinish(@(FPNGInfo.zinfo));
  FreeBufMem;
 end;
end;


//------- SetGrayScalePaletteIndex => �p���b�g�C���f�b�N�X���O���C�X�P�[����


procedure TGLDPNGWriteStream.SetGrayScalePaletteIndex;
var
 pal: array [0..255] of TGLDPalRGB;
 i,n: integer;

begin
 FillChar(pal,256*sizeof(TGLDPalRGB),0);
 n:=GetPaletteColorTable(Image.Palette,PGLDPalRGB(@pal));
 if n>0 then
  begin
   case FOrgBitCount of
    1:
     if (((pal[0].rgbRed*77)+(pal[0].rgbGreen*150)+(pal[0].rgbBlue*29)) shr 8) <=
        (((pal[1].rgbRed*77)+(pal[1].rgbGreen*150)+(pal[1].rgbBlue*29)) shr 8) then
      FPalGrayIndex[0]:=0
     else
      FPalGrayIndex[0]:=255;
    4:
     for i:=0 to Pred(n) do
      FPalGrayIndex[i]:=((pal[i].rgbRed*77)+(pal[i].rgbGreen*150)+(pal[i].rgbBlue*29)) shr 12;
    8:
     for i:=0 to Pred(n) do
      FPalGrayIndex[i]:=((pal[i].rgbRed*77)+(pal[i].rgbGreen*150)+(pal[i].rgbBlue*29)) shr 8;
   end;
  end
 else
  begin
   for i:=0 to Pred(1 shl FOrgBitCount) do FPalGrayIndex[i]:=i;
  end;
end;


//------- GetLinePilxes => �P���C���f�[�^�擾


procedure TGLDPNGWriteStream.GetLinePixels(ps,pa: pbyte);
var
 pd,pp,pss,pdd: pbyte;
 psx,pax,psinc,painc,len,dbcnt,sbcnt,d,i,n,m: integer;

begin
 // �s�N�Z���ݒ�
 pd:=pointer(FPNGInfo.outbuf);
 len:=FPassWidth-1;
 case FInterlaceType of
  gptNone: // �ʏ�
   begin
    case FOrgBitCount of
     1:
      begin
       Move(ps^,pd^,FSrcLineSize);
       if FGrayOK and (FPalGrayIndex[0]=255) then
        for i:=0 to Pred(FSrcLineSize) do
        begin
         pd^:=not pd^;
         Inc(pd);
        end;
      end;
     4:
      begin
       Move(ps^,pd^,FSrcLineSize);
       if FGrayOK then
        for i:=0 to Pred(FSrcLineSize) do
        begin
         m:=pd^;
         pd^:=FPalGrayIndex[m and $F] or ((FPalGrayIndex[(m shr 4) and $F]) shl 4);
         Inc(pd);
        end;
      end;
     8:
      begin
       if FGrayOK then
        if FAlpha256OK then
         // 256�F�{�A���t�@
         begin
          for i:=0 to len do
          begin
           PArrayByte(pd)^[0]:=ps^;
           PArrayByte(pd)^[1]:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} pa^;
           Inc(pa); Inc(pd,2);
           Inc(ps);
          end;
         end
        else
         // �O���C�X�P�[��
         begin
          for i:=0 to len do
          begin
           PArrayByte(pd)^[0]:=FPalGrayIndex[ps^];
           if pa<>nil then
            begin
             PArrayByte(pd)^[1]:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} pa^;
             Inc(pa); Inc(pd,2);
            end
           else
            Inc(pd);
           Inc(ps);
          end;
         end
       else
        // �ʏ�
        if pa=nil then
         Move(ps^,pd^,FSrcLineSize)
        else
         for i:=0 to len do
         begin
          PArrayByte(pd)^[0]:=ps^;
          PArrayByte(pd)^[1]:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} pa^;
          Inc(pd,2);
          Inc(pa);
          Inc(ps);
         end;
      end;
     15:
      begin
       if FGrayOK then
        // �O���C�X�P�[���ϊ�
        begin
         if pa<>nil then m:=2 else m:=1;
         for i:=0 to len do
         begin
          n:=PWORD(ps)^;
          PArrayByte(pd)^[0]:=
           ( (((n and GLDRMask15) shr 7) or ((n and GLDRMask15) shr 12))*77+
             (((n and GLDGMask15) shr 2) or ((n and GLDGMask15) shr 8))*150+
             (((n and GLDBMask15) shl 3) or ((n and GLDBMask15) shr 2))*29) shr 8;
          if pa<>nil then
           begin
            PArrayByte(pd)^[1]:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} pa^; Inc(pa);
           end;
          Inc(ps,2);
          Inc(pd,m);
         end;
        end
       else
        // �ʏ�
        begin
         if pa<>nil then m:=4 else m:=3;
         for i:=0 to len do
         begin
          n:=PWORD(ps)^;
          with PPNGRGBA(pd)^ do
          begin
           R:=((n and GLDRMask15) shr 7) or ((n and GLDRMask15) shr 12);
           G:=((n and GLDGMask15) shr 2) or ((n and GLDGMask15) shr 8);
           B:=((n and GLDBMask15) shl 3) or ((n and GLDBMask15) shr 2);
           if pa<>nil then
            begin
             A:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} pa^; Inc(pa);
            end;
          end;
          Inc(ps,2);
          Inc(pd,m);
         end;
        end;
      end;
     16:
      begin
       if FGrayOK then
        // �O���C�X�P�[��
        begin
         if pa<>nil then m:=2 else m:=1;
         for i:=0 to len do
         begin
          n:=PWORD(ps)^;
          PArrayByte(pd)^[0]:=
           ( (((n and GLDRMask16) shr 8) or ((n and GLDRMask16) shr 13))*77+
             (((n and GLDGMask16) shr 3) or ((n and GLDGMask16) shr 9))*150+
             (((n and GLDBMask16) shl 3) or ((n and GLDBMask16) shr 2))*29) shr 8;
          if pa<>nil then
           begin
            PArrayByte(pd)^[1]:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} pa^; Inc(pa);
           end;
          Inc(ps,2);
          Inc(pd,m);
         end;
        end
       else
        // �ʏ�
        begin
         if pa<>nil then m:=4 else m:=3;
         for i:=0 to len do
         begin
          n:=PWORD(ps)^;
          with PPNGRGBA(pd)^ do
          begin
           R:=((n and GLDRMask16) shr 8) or ((n and GLDRMask16) shr 13);
           G:=((n and GLDGMask16) shr 3) or ((n and GLDGMask16) shr 9);
           B:=((n and GLDBMask16) shl 3) or ((n and GLDBMask16) shr 2);
           if pa<>nil then
            begin
             A:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} pa^; Inc(pa);
            end;
          end;
          Inc(ps,2);
          Inc(pd,m);
         end;
        end;
      end;
     24,32:
      begin
       if FGrayOK then
        // �O���C�X�P�[��
        begin
         if FOrgBitCount=24 then n:=3 else n:=4;
         if pa<>nil then m:=2 else m:=1;
         for i:=0 to len do
         begin
          with PGLDPixRGB24(ps)^ do
          begin
           PArrayByte(pd)^[0]:=
            (rgbRed*77+rgbGreen*150+rgbBlue*29) shr 8;
           if pa<>nil then
            begin
             PArrayByte(pd)^[1]:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} pa^; Inc(pa);
            end;
          end;
          Inc(ps,n);
          Inc(pd,m);
         end;
        end
       else
        // �ʏ�
        begin
         if FOrgBitCount=24 then n:=3 else n:=4;
         if pa<>nil then m:=4 else m:=3;
         for i:=0 to len do
         begin
          with PGLDPixRGB24(ps)^ do
          begin
           PArrayByte(pd)^[0]:=rgbRed;
           PArrayByte(pd)^[1]:=rgbGreen;
           PArrayByte(pd)^[2]:=rgbBlue;
           if pa<>nil then
            begin
             PArrayByte(pd)^[3]:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} pa^; Inc(pa);
            end;
          end;
          Inc(ps,n);
          Inc(pd,m);
         end;
        end;
      end;
    end;
   end;
  gptAdam7: // �C���^���[�X
   begin
    psx:=FInterStartX;
    psinc:=FInterIncX;
    case FOrgBitCount of
     1:  begin
          pdd:=pd;
          dbcnt:=$80;
          d:=0; n:=1;
          for i:=0 to len do
          begin
           if (BitROr[psx and 7] and PArrayByte(ps)^[psx shr 3])<>0 then d:=d or dbcnt;
           dbcnt:=dbcnt shr 1;
           if dbcnt=0 then
            begin
             dbcnt:=$80;
             pd^:=d;
             Inc(pd);
             Inc(n);
             d:=0;
            end;
           Inc(psx,psinc);
          end;
          if dbcnt<>$80 then pd^:=d else Dec(n);
          if FGrayOK and (FPalGrayIndex[0]=255) then
           for i:=0 to Pred(n) do
           begin
            pdd^:=not pdd^;
            Inc(pdd);
           end;
         end;
     4:  begin
          pdd:=pd;
          dbcnt:=0;
          d:=0; n:=1;
          for i:=0 to len do
          begin
           sbcnt:=psx and 1;
           if sbcnt<>0 then
            if dbcnt<>0 then
             d:=d or (PArrayByte(ps)^[psx shr 1] and $0F)
            else
             d:=d or ((PArrayByte(ps)^[psx shr 1] and $0F) shl 4)
           else
            if dbcnt<>0 then
             d:=d or ((PArrayByte(ps)^[psx shr 1] and $F0) shr 4)
            else
             d:=d or (PArrayByte(ps)^[psx shr 1] and $F0);
           if dbcnt<>0 then
            begin
             dbcnt:=0;
             pd^:=d;
             Inc(pd);
             Inc(n);
             d:=0;
            end
           else
            dbcnt:=1;
           Inc(psx,psinc);
          end;
          if dbcnt<>0 then pd^:=d else Dec(n);
          if FGrayOK then
           for i:=0 to Pred(n) do
           begin
            m:=pdd^;
            pdd^:=FPalGrayIndex[m and $F] or ((FPalGrayIndex[(m shr 4) and $F]) shl 4);
            Inc(pdd);
           end;
         end;
     8:  begin
          if FGrayOK then
           if FAlpha256OK then
            // 256�F�{�A���t�@
            for i:=0 to len do
            begin
             PArrayByte(pd)^[0]:=PArrayByte(ps)^[psx];
             PArrayByte(pd)^[1]:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} PArrayByte(pa)^[psx];
             Inc(pd,2);
             Inc(psx,psinc);
            end
           else
            // �O���C�X�P�[��
            for i:=0 to len do
            begin
             PArrayByte(pd)^[0]:=FPalGrayIndex[PArrayByte(ps)^[psx]];
             if pa<>nil then
              begin
               PArrayByte(pd)^[1]:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} PArrayByte(pa)^[psx];
               Inc(pd,2);
              end
             else
              Inc(pd);
             Inc(psx,psinc);
            end
          else
           // �ʏ�
           for i:=0 to len do
           begin
            PArrayByte(pd)^[0]:=PArrayByte(ps)^[psx];
            if pa<>nil then
             begin
              PArrayByte(pd)^[1]:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} PArrayByte(pa)^[psx];
              Inc(pd,2);
             end
            else
             Inc(pd);
            Inc(psx,psinc);
           end;
         end;
     15: begin
          pax:=FInterStartAX;
          painc:=FInterIncAX;
          if FGrayOK then
           // �O���C�X�P�[��
           begin
            if pa<>nil then m:=2 else m:=1;
            for i:=0 to len do
            begin
             pss:=ps; Inc(pss,psx);
             n:=PWORD(pss)^;
             PArrayByte(pd)^[0]:=
              ( (((n and GLDRMask15) shr 7) or ((n and GLDRMask15) shr 12))*77+
                (((n and GLDGMask15) shr 2) or ((n and GLDGMask15) shr 8))*150+
                (((n and GLDBMask15) shl 3) or ((n and GLDBMask15) shr 2))*29) shr 8;
             if pa<>nil then
              begin
               PArrayByte(pd)^[1]:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} PArrayByte(pa)^[pax]; Inc(pax,painc);
              end;
             Inc(pd,m);
             Inc(psx,psinc);
            end;
           end
          else
           // �ʏ�
           begin
            if pa<>nil then m:=4 else m:=3;
            for i:=0 to len do
            begin
             pss:=ps; Inc(pss,psx);
             n:=PWORD(pss)^;
             with PPNGRGBA(pd)^ do
             begin
              R:=((n and GLDRMask15) shr 7) or ((n and GLDRMask15) shr 12);
              G:=((n and GLDGMask15) shr 2) or ((n and GLDGMask15) shr 8);
              B:=((n and GLDBMask15) shl 3) or ((n and GLDBMask15) shr 2);
              if pa<>nil then
               begin
                A:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} PArrayByte(pa)^[pax]; Inc(pax,painc);
               end;
             end;
             Inc(pd,m);
             Inc(psx,psinc);
            end;
           end;
         end;
     16: begin
          pax:=FInterStartAX;
          painc:=FInterIncAX;
          if FGrayOK then
           // �O���C�X�P�[��
           begin
            if pa<>nil then m:=2 else m:=1;
            for i:=0 to len do
            begin
             pss:=ps; Inc(pss,psx);
             n:=PWORD(pss)^;
             PArrayByte(pd)^[0]:=
              ( (((n and GLDRMask16) shr 8) or ((n and GLDRMask16) shr 13))*77+
                (((n and GLDGMask16) shr 3) or ((n and GLDGMask16) shr 9))*150+
                (((n and GLDBMask16) shl 3) or ((n and GLDBMask16) shr 2))*29) shr 8;
             if pa<>nil then
              begin
               PArrayByte(pd)^[1]:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} PArrayByte(pa)^[pax]; Inc(pax,painc);
              end;
             Inc(pd,m);
             Inc(psx,psinc);
            end;
           end
          else
           // �ʏ�
           begin
            if pa<>nil then m:=4 else m:=3;
            for i:=0 to len do
            begin
             pss:=ps; Inc(pss,psx);
             n:=PWORD(pss)^;
             with PPNGRGBA(pd)^ do
             begin
              R:=((n and GLDRMask16) shr 8) or ((n and GLDRMask16) shr 13);
              G:=((n and GLDGMask16) shr 3) or ((n and GLDGMask16) shr 9);
              B:=((n and GLDBMask16) shl 3) or ((n and GLDBMask16) shr 2);
              if pa<>nil then
               begin
                A:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} PArrayByte(pa)^[pax]; Inc(pax,painc);
               end;
             end;
             Inc(pd,m);
             Inc(psx,psinc);
            end;
           end;
         end;
  24,32: begin
          pax:=FInterStartAX;
          painc:=FInterIncAX;
          if FGrayOK then
           begin
            if pa<>nil then m:=2 else m:=1;
            for i:=0 to len do
            begin
             PArrayByte(pd)^[0]:=
              (PArrayByte(ps)^[psx+GLDCorRed]*77+
               PArrayByte(ps)^[psx+GLDCorGreen]*150+
               PArrayByte(ps)^[psx+GLDCorBlue]*29) shr 8;
             if pa<>nil then
              begin
               PArrayByte(pd)^[1]:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} PArrayByte(pa)^[pax]; Inc(pax,painc);
              end;
             Inc(pd,m);
             Inc(psx,psinc);
            end;
           end
          else
           begin
            if pa<>nil then m:=4 else m:=3;
            for i:=0 to len do
            begin
             PArrayByte(pd)^[0]:=PArrayByte(ps)^[psx+GLDCorRed];    // B,R �� ����ւ�
             PArrayByte(pd)^[1]:=PArrayByte(ps)^[psx+GLDCorGreen];
             PArrayByte(pd)^[2]:=PArrayByte(ps)^[psx+GLDCorBlue];
             if pa<>nil then
              begin
               PArrayByte(pd)^[3]:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} PArrayByte(pa)^[pax]; Inc(pax,painc);
              end;
             Inc(pd,m);
             Inc(psx,psinc);
            end;
           end;
         end;
    end;
   end;
 end;
end;


{$ENDIF}


//***************************************************
//*   TGLDPNGReadStream                             *
//***************************************************


//------- png_ZlibRead => ZLIB����


function png_ZlibRead(pg: PGLDZLIBInfo): integer;
begin
 with TGLDPNGReadStream(pg^.owner) do
 begin
  // �t�@�C������ǂݍ���
  if FChunkSize<=0 then
   begin
    // ��IDAT
    ReadSkipByte(4);
    FChunkSize:=ReadMDWord;
    FChunkName:=ReadMDWord;
    if (FChunkName<>IDAT) then
     begin
      result:=-1;
      Exit;
     end;
   end;
  pg^.zstream.next_in:=pchar(pg^.zbuf);
  // �����T�C�Y���o�b�t�@��菬�����ꍇ�͑����T�C�Y
  if (pg^.zbuflen>FChunkSize) then
   pg^.zstream.avail_in:=FChunkSize
  else
   pg^.zstream.avail_in:=pg^.zbuflen;
  // �o�b�t�@�ɓǂݍ���
  ReadByte(pg^.zbuf,pg^.zstream.avail_in);
  // �����T�C�Y�������
  Dec(FChunkSize,pg^.zstream.avail_in);
  if EOFFlag then result:=-1 else result:=0;
 end;
end;


//------- Create => �N���X�쐬


constructor TGLDPNGReadStream.Create;
begin
 inherited;
 FSigflg:=TRUE;
 FPNGInfo.zinfo.IOProc:=png_ZlibRead;
 FPNGINfo.zinfo.owner:=self;
end;


//------- GetBufMem => �o�b�t�@�������m��


procedure TGLDPNGReadStream.GetBufMem;
var
 n,m,a: integer;
 p: pbyte;

begin
 if FBufMemPtr<>nil then FreeBufMem;
 n:=GetLineSize(Width,FPNGInfo.pixel_depth)+4;
 m:=GetLineSize(Width,BitCount)+4;
 FPassLineSize:=m-4;
 {$IFDEF GLD_SUPPORT_16BIT_ALPHA}
 a:=GetLineSize(Width,16);
 {$ELSE}
 a:=GetLineSize(Width,8);
 {$ENDIF}
 GetMem(p,n*2+m+a);
 FBufMemPtr:=p;
 FPNGInfo.outbuf:=p;
 Inc(p,n);
 FPNGInfo.prev_row:=p;
 Inc(p,n);
 FLineBuf:=p;
 Inc(p,m);
 FAlphaBuf:=p;
end;


//------- FreeBufMem => �o�b�t�@���������


procedure TGLDPNGReadStream.FreeBufMem;
begin
 if FBufMemPtr<>nil then
  begin
   FreeMem(FBufMemPtr);
   FBufMemPtr:=nil;
  end;
end;


//------- CreateDIB => �c�h�a�m��


procedure TGLDPNGReadStream.CreateDIB;
var
 i,j,n, c0,c255: integer;
 alphatbl: array [0..255] of TGLDPalRGB;

begin
 // �O���C�X�P�[���p���b�g�ݒ�
 if (not FAlpha256OK) and (FColorType=0) and (BitCount<=8)  then
  begin
   PaletteSize:=CreateGrayScalePalette(ColorTBLBuf,OriginalBitCount);
  end;

 // �p���b�g�A���t�@�ϊ�
 // �����w�肪1�̏ꍇ���������F�ɕϊ��B
 // ��̓A���t�@�`�����l���Ƃ��Ĉ�����
 if (FTransColor=$1FFFFFF) then
  begin
   n:=-1; c0:=0; c255:=0;
   for i:=0 to 255 do
   begin
    j:=FTransBuf[i];
    if not((j=0) or (j=255)) then
     begin
      n:=-1;
      break;
     end;
   {$IFDEF GLD_NOREVERSE_ALPHA}
    if j=0 then begin n:=i; Inc(c0); end else Inc(c255);
   {$ELSE}
    if j=255 then begin n:=i; Inc(c255); end else Inc(c0);
   {$ENDIF}
   end;
   {$IFDEF GLD_NOREVERSE_ALPHA}
   if (c0=1) and (c255=255) and (n<>-1) then
   {$ELSE}
   if (c255=1) and (c0=255) and (n<>-1) then
   {$ENDIF}
    FTransColor:=COLORREF(n or $1000000)
   else
    begin
     FTransColor:=GLDNONECOLOR;
     FConvertPAlpha:=TRUE;
    end;
  end;

 // DIB�쐬
 inherited CreateDIB;

 // �A���t�@�`�����l���r�b�g�}�b�v�����ݒ�
 if (FAlphaFlag or FConvertPAlpha) then
   if FAlphaBmp<>nil then
    with FAlphaBmp do
    begin
     Assign(nil);
     Transparent:=FALSE;
     PixelFormat:=pf8bit; HandleType:=bmDIB;
     Width:=Image.Width; Height:=Image.Height;
     CreateGrayScalePalette(PGLDPalRGB(@alphatbl),8);
     Palette:=CreatePaletteHandle(PGLDPalRGB(@alphatbl),256);
     FAmp:=FAlphaBmp;
    end;
end;


//------- ConvertPAlpha => �p���b�g�A���t�@���A���t�@�}�X�N��


procedure TGLDPNGReadStream.ConvertPAlpha;
var
 w,h,x,y,bcnt: integer;
 pa,ps: pbyte;

begin
 w:=Width-1;
 h:=Height-1;
 bcnt:=BitCount;

 for y:=0 to h do
 begin
  pa:=FAmp.ScanLine[y];
  ps:=Image.ScanLine[y];
  case bcnt of
   1: begin
       for x:=0 to w do
       begin
        if (PArrayByte(ps)^[x shr 3] and BitROr[x and 7])=0 then
         pa^:=FTransBuf[0]
        else
         pa^:=FTransBuf[1];
        Inc(pa);
       end;
      end;
   4: begin
       for x:=0 to w do
       begin
        if (x and 1)=0 then
         pa^:=FTransBuf[(PArrayByte(ps)^[x shr 1] and $F0) shr 4]
        else
         pa^:=FTransBuf[PArrayByte(ps)^[x shr 1] and $F];
        Inc(pa);
       end;
      end;
   8: begin
       for x:=0 to w do
       begin
        pa^:=FTransBuf[PArrayByte(ps)^[x]];
        Inc(pa);
       end;
      end;
  end;
 end;
 // �ꉞ����̂Ńt���O�𗧂Ă�
 FAlphaFlag:=TRUE;
end;


//------- ReadStream => �ǂݍ���


procedure TGLDPNGReadStream.ReadStream;
var
 sig: array [0..7] of byte;
 i,n: integer;
 flg: boolean;

begin
 StartCallBack;
 SetCallBackParam(0,0,30);

 // �t�H�[�}�b�g�p�����[�^������
 FAmp:=nil;
 FAlphaFlag:=FALSE;
 FGrayFlag:=FALSE;
 FAlpha256OK:=FALSE;
 FInterlaceType:=gptNone;
 FColorType:=-1;
 FPass:='';
 FConvertPAlpha:=FALSE;
 FBGColor:=GLDNONECOLOR;
 FTransColor:=GLDNONECOLOR;
 FShiftRGB:=0;
 FGamma:=0;
 FillChar(FTransBuf,sizeof(FTransBuf),255);
 if FTime<>nil then FillChar(FTime^,sizeof(TPNGTime),0);
 if FGIFExt<>nil then FillChar(FGIFExt^,sizeof(TPNGGIFExtension),0);
 if FChrm<>nil then FillChar(FChrm^,sizeof(TPNGChromaticities),0);
 OriginalBitCount:=0;

 // �V�O�l�X�`���`�F�b�N
 if FSigflg then
  begin
   flg:=FALSE;
   ReadByte(pointer(@sig),8);
   for i:=0 to 7 do
    if sig[i]<>png_sig[i] then flg:=TRUE;
   if flg then
    raise EGLDPNG.Create('PNG LoadStream: Not PNG Format');
  end;

 try
  // �W�J
  ReadChunk;
  // �����F�ݒ�
  if not (EOFFlag or CancelFlag or FAlphaFlag) then
   begin
    if FTransColor<>GLDNONECOLOR then
     begin
      Image.Transparent:=TRUE;
      Image.TransparentColor:=FTransColor;
     end;
   end;
  // �p���b�g�A���t�@���A���t�@�}�X�N�ɓW�J
  if FConvertPAlpha and (FAmp<>nil) then ConvertPAlpha;
  // �Ō�̃R�[���o�b�N
  EndCallBack;
 finally
  // ZLIB�f�[�^���
  ZLIBDecodeFinish(@FPNGInfo.zinfo);
  // ���������
  FreeBufMem;
 end;
end;


//---------------------------------------------------------
//  �ǂݍ���
//---------------------------------------------------------


//------- ReadHeader => �w�b�_�ǂݍ���


procedure TGLDPNGReadStream.ReadHeader;
var
 i,j: integer;

begin
 // ��x�߁H
 if pcIHDR in FChunkFlag then
  raise EGLDPNG.Create('Read Header(PNG): appear two IHDR');
 // �c����
 Width:=ReadMDWord;
 Height:=ReadMDWord;

 // �F�r�b�g�����J���[���[�h
 OriginalBitCount:=Read1Byte;
 j:=Read1Byte;
 j:=j and $7;
 if (j in [1,5,7]) then
  raise EGLDPNG.Create('Read Header(PNG): Error ColorType');
 if (j and 4)<>0 then
  begin
   FAlphaFlag:=TRUE;
   j:=j and 3;
  end;
 if j=0 then FGrayFlag:=TRUE;
 FColortype:=j;

 // ���k�`��
 i:=Read1Byte;
 if i>1 then
  raise EGLDPNG.Create('Read Header(PNG): not support Compression');

 // �t�B���^���
 i:=Read1Byte;
 if i>1 then
  raise EGLDPNG.Create('Read Header(PNG): not supprt Filter');

 // �C���^���[�X
 i:=Read1Byte;
 if i>1 then
  raise EGLDPNG.Create('Read Header(PNG): not interlace type');
 FInterlaceType:=i;

 // IHDR�t���O���Ă�
 FChunkFlag:=FChunkFlag+[pcIHDR];
 // �R�[���o�b�N
 DoCallBack(0);
 // �ǂݍ��݃f�[�^������������
 Dec(FChunkSize,13);
end;


//------- CheckImageFormat => �w�b�_�f�[�^����ǂݍ��ݐݒ�


procedure TGLDPNGReadStream.CheckImageFormat;
var
 i,j: integer;

begin
 i:=OriginalBitCount;
 case FColorType of
  0: // �O���C�X�P�[��
     begin
      if not (i in [1,2,4,8,16]) then
       raise EGLDPNG.Create('Read Header(PNG): Error Bitdepth');
      if FAlphaFlag and (i<8) then
       raise EGLDPNG.Create('Read Header(PNG): not Use AlphaChannel');
      case i of
        2: // �S�i�K
           begin
            BitCount:=4;
            ConvertProc:=Change2to4;
           end;
        8: // 256�i�K
           begin
            BitCount:=8;
            if FAlphaFlag then
             ConvertProc:=ChangeGray8A
            else
             ConvertProc:=ConvertNone;
           end;
       16: // 65536�i�K
           begin
            BitCount:=8;
            if FAlphaFlag then
             ConvertProc:=ChangeGray16A
            else
             ConvertProc:=ChangeGray16;
           end;
      else
       begin
        BitCount:=i;
        ConvertProc:=ConvertNone;
       end;
      end;
      if FAlphaFlag then FPNGInfo.pixel_depth:=i*2 else FPNGInfo.pixel_depth:=i;
     end;
  2: // �q�f�a
     begin
      if not (i in [8,16]) then
       raise EGLDPNG.Create('Read Header(PNG): Error BitDepth');
      if (((FShiftRGB and $FFFFFF)=$50505) or ((FShiftRGB and $FFFFFF)=$50605)) and FRead16BitFlag then
       // for 16bit
       begin
        if (FShiftRGB and $FFFFFF)=$50505 then
         OriginalBitCount:=15
        else
         OriginalBitCount:=16;
        {$IFDEF GLD_SUPPORT_BIT15}
        BitCount:=OriginalBitCount;
        {$ELSE}
        BitCount:=16;
        {$ENDIF}
        if FAlphaFlag then
         begin
          ConvertProc:=RGBAtoBGRA16;
          FPNGInfo.pixel_depth:=i*4;
         end
        else
         begin
          ConvertProc:=RGBtoBGR16;
          FPNGInfo.pixel_depth:=i*3;
         end;
       end
      else
       begin
        BitCount:=24;
        OriginalBitCount:=i*3;
        if FAlphaFlag then
         begin
          if i=8 then
           ConvertProc:=RGBAtoBGRA32
          else
           ConvertProc:=RGBAtoBGRA64;
          FPNGInfo.pixel_depth:=i*4;
         end
        else
         begin
          if i=8 then
           ConvertProc:=RGBtoBGR24
          else
           ConvertProc:=RGBtoBGR48;
          FPNGInfo.pixel_depth:=i*3;
         end;
       end;
     end;
  3: // �p���b�g�C���f�b�N�X
     begin
      if not (i in [1,2,4,8]) then
       raise EGLDPNG.Create('Read Header(PNG): Error BitDepth');
      case i of
        2: // 4�F����16�F�ϊ�
           begin
            BitCount:=4;
            ConvertProc:=Change2to4;
           end;
      else
       begin
        BitCount:=i;
        ConvertProc:=ConvertNone;
       end;
      end;
      FPNGInfo.pixel_depth:=i;
     end;
 end;

 // �c�h�a�]�����[�`���ݒ�
 case FInterlaceType of
  gptNone: // �m�[�}��
     begin
      FMaxPass:=0;
      CopyProc:=SetPixels_Normal;
      CopyAlphaProc:=SetPixels_Normal_A;
     end;
  gptAdam7: // �C���^���[�X
     begin
      FMaxPass:=6;
      CopyAlphaProc:=SetPixels_InterA;
      case BitCount of
        1: CopyProc:=SetPixels_Inter1;
        4: CopyProc:=SetPixels_Inter4;
        8: CopyProc:=SetPixels_Inter8;
       16: CopyProc:=SetPixels_Inter16;
       24: CopyProc:=SetPixels_Inter24;
      end;
     end;
 end;
end;


//------- ReadImage => �C���[�W�W�J


procedure TGLDPNGReadStream.ReadImage;
var
 ps,pd,pa,pp: pbyte;
 i,j,y,ly,ydec,aydec,w,h,sy,syinc,cbcnt: integer;

begin
 // ��x�߁H
 if pcIDAT in FChunkFlag then
  begin
   SkipChunk;
   Exit;
  end;

 // ZLIB�W�J������
 if ZLIBDecodeInit(@FPNGInfo.zinfo)<>0 then
  raise EGLDPNG.Create('PNG LoadStream: Error ZLIB');

 // �C���[�W�`�F�b�N
 CheckImageFormat;
 // �c�h�a�m��
 CreateDIB;
 // �o�b�t�@�m��
 GetBufMem;

 try
  pa:=nil;
  w:=Image.Width;
  h:=Image.Height;
  cbcnt:=1; SetCallBackParam(1,GetCallBackCount(FInterlaceType,h),98);
  for i:=0 to FMaxPass do
  begin
   case FInterlaceType of
    gptNone: // �m�[�}��
       begin
        FPassWidth:=w;
        ly:=h; syinc:=1; sy:=0;
        FInterStartX:=0;
        FInterIncX:=1;
       end;
    gptAdam7: // �C���^���[�X
       begin
        case i of
         0: // pass 1
            begin
             FPassWidth:=((w+7) shr 3);
             ly:=((h+7) shr 3);
            end;
         1: // pass 2
            begin
             if w<5 then
              Continue
             else
              FPassWidth:=((w+3) shr 3);
             ly:=((h+7) shr 3);
            end;
         2: // pass 3
            begin
             FPassWidth:=((w+3) shr 2);
             if h<5 then
              Continue
             else
              ly:=((h+3) shr 3);
            end;
         3: // pass 4
            begin
             if w<3 then
              Continue
             else
              FPassWidth:=((w+1) shr 2);
             ly:=((h+3) shr 2);
            end;
         4: // pass 5
            begin
             FPassWidth:=((w+1) shr 1);
             if h<3 then
              Continue
             else
              ly:=((h+1) shr 2);
            end;
         5: // pass 6
            begin
             if w<2 then
              Continue
             else
              FPassWidth:=w shr 1;
             ly:=((h+1) shr 1);
            end;
         6: // pass 7
            begin
             FPassWidth:=w;
             if h<2 then
              Continue
             else
              ly:=h shr 1;
            end;
        end;
        sy:=pass_start_Y[i];
        syinc:=pass_inc_Y[i];
        Dec(pd,ydec*sy);
        ydec:=ydec*syinc;

        {$IFDEF GLD_SUPPORT_16BIT_ALPHA}
        FInterAStartX:=pass_start_X[i]*2;
        FInterAIncX:=pass_inc_X[i]*2;
        {$ELSE}
        FInterAStartX:=pass_start_X[i];
        FInterAIncX:=pass_inc_X[i];
        {$ENDIF}

        case BitCount of
         16: // 16bit
          begin
           FInterStartX:=pass_start_X[i]*2;
           FInterIncX:=pass_inc_X[i]*2;
          end;
         24: // 24bit
          begin
           FInterStartX:=pass_start_X[i]*3;
           FInterIncX:=pass_inc_X[i]*3;
          end;
         {$IFDEF GLD_SUPPORT_48BIT}
         48: // 48bit
          begin
           FInterStartX:=pass_start_X[i]*6;
           FInterIncX:=pass_inc_X[i]*6;
          end;
         {$ENDIF}
        else
         begin
          FInterStartX:=pass_start_X[i];
          FInterIncX:=pass_inc_X[i];
         end;
        end;
       end;
   end;

   FPNGInfo.linelen:=(((FPassWidth*FPNGInfo.pixel_depth)+7) shr 3)+1;
   FillChar(FPNGInfo.prev_row^,FPNGInfo.linelen,0);
   Dec(ly);

   for y:=ly downto 0 do
   begin
    pd:=Image.ScanLine[sy];
    if FAmp<>nil then pa:=FAmp.ScanLine[sy];
    // �P���C���ǂݍ���
    if png_read_line(@FPNGInfo)<0 then
     raise EGLDPNG.Create('Read Image (PNG): Read Error');
    if (FPass<>'') and Assigned(OnDecode) then
     begin
      ps:=FPNGInfo.outbuf; j:=FPNGInfo.linelen;
      // ���C���f�[�^��ۑ�
      Move(FPNGInfo.outbuf^,FPNGInfo.prev_row^,j);
      Inc(ps);
      // ������
      OnDecode(self,ps,j-1,cbcnt-1,FPass);
      // �c�h�a�o��
      CopyProc(pd,ConvertProc);
      // �A���t�@�}�X�N�ɏo��
      if pa<>nil then CopyAlphaProc(pa,FAlphaBuf);
     end
    else
     begin
      // �c�h�a�o��
      CopyProc(pd,ConvertProc);
      // �A���t�@�}�X�N�ɏo��
      if pa<>nil then CopyAlphaProc(pa,FAlphaBuf);
      // �|�C���^����
      ps:=FPNGInfo.outbuf;
      FPNGInfo.outbuf:=FPNGInfo.prev_row;
      FPNGInfo.prev_row:=ps;
     end;
    // ����
    Inc(sy,syinc);
    // �R�[���o�b�N
    if ((cbcnt and 3)=2) or (h<4) then DoCallBack(cbcnt);
    Inc(cbcnt);
    if (CancelFlag) then Break;
   end;
   // �`�F�b�N
   if (EOFFlag) or (CancelFlag) then Break;
  end;
  // �t���O����
  FChunkFlag:=FChunkFlag+[pcIDAT];
 finally
  // ZLib�W�J���Z�b�g
  ZLIBDecodeFlush(@(FPNGInfo.zinfo));
  ZLIBDecodeFinish(@(FPNGInfo.zinfo));
  // �o�b�t�@���
  FreeBufMem;
  // �R�[���o�b�N�ݒ�
  SetCallBackParam(0,0,0);
 end;
end;


//------- SkipChunk => �`�����N�Ƃ΂�


procedure TGLDPNGReadStream.SkipChunk;
begin
 if FChunkSize>0 then ReadSkipByte(FChunkSize);
end;


//------- ReadPalette => �p���b�g�ǂݍ���


procedure TGLDPNGReadStream.ReadPalette;
var
 len,i: integer;
 paldat: TPNGRGB;

begin
 if (FColorType<>0) or ((FColorType=0) and (FAlphaFlag) and (OriginalBitCount=8) and (FAlpha256OK)) then
  // PLTE���P��ځH
  if (not (pcPLTE in FChunkFlag)) and (pcIHDR in FChunkFlag) and (not (pcIDAT in FChunkFlag)) then
   begin
    len:=FChunkSize div 3;
    if (len>256) then len:=256;
    // RGB�f�[�^�ǂݍ���
    if len>0 then
     for i:=0 to Pred(len) do
     begin
      ReadByte(@paldat,sizeof(paldat));
      with PArrayRGB(ColorTBLBuf)^[i] do
      begin
       rgbRed:=paldat.R;
       rgbGreen:=paldat.G;
       rgbBlue:=paldat.B;
      end;
     end;
    Dec(FChunkSize,len*sizeof(paldat));
    PaletteSize:=len;
    FChunkFlag:=FChunkFlag+[pcPLTE];
    // �R�[���o�b�N
    DoCallBack(0);
   end;
end;


//------- EndChunk => �G���h����


procedure TGLDPNGReadStream.EndChunk;
begin
 FChunkFlag:=FChunkFlag+[pcIEND];
end;


//------- ReadAspectData => �A�X�y�N�g��⃁�[�g�������擾


procedure TGLDPNGReadStream.ReadAspectData;
begin
 if (pcIHDR in FChunkFlag) and (not (pcIDAT in FChunkFlag)) then
  begin
   WidthSpecific:=ReadMDWord;
   HeightSpecific:=ReadMDWord;
   UnitSpecifier:=Read1Byte;
   // �ǂݍ��݃f�[�^������������
   Dec(FChunkSize,4+4+1);
   // �R�[���o�b�N
   DoCallBack(0);
  end;
end;


//------- ReadGamma => �K���}�l�擾


procedure TGLDPNGReadStream.ReadGamma;
begin
 if (pcIHDR in FChunkFlag) and (not ((pcIDAT in FChunkFlag) or (pcPLTE in FChunkFlag))) then
  begin
   FGamma:=ReadMDWord/100000;
   // �ǂݍ��݃f�[�^������������
   Dec(FChunkSize,4);
   // �R�[���o�b�N
   DoCallBack(0);
  end;
end;


//------- ReadsBIT => sBIT�擾


procedure TGLDPNGReadStream.ReadsBIT;
var
 r,g,b: integer;

begin
 if (pcIHDR in FChunkFlag) and (not ((pcIDAT in FChunkFlag) or (pcPLTE in FChunkFlag))) then
  if (FColorType and 3)>1 then
   begin
    r:=Read1Byte; g:=Read1Byte; b:=Read1Byte;
    FShiftRGB:=r or (g shl 8) or (b shl 16);
    // �ǂݍ��݃f�[�^������������
    Dec(FChunkSize,3);
    if FAlphaFlag then
     begin
      FShiftRGB:=FShiftRGB or (Read1Byte shl 24);
      Dec(FChunkSize);
     end;
    // �R�[���o�b�N
    DoCallBack(0);
   end;
end;


//------- ReadTransColor => �����F�擾


procedure TGLDPNGReadStream.ReadTransColor;
var
 i,j: integer;
 pp: pbyte;

begin
 if (pcIHDR in FChunkFlag) and (not (pcIDAT in FChunkFlag)) and (not FAlphaFlag) then
  case FColortype of
   0,4:  // �O���C�X�P�[��
         begin
          i:=ReadMWord;
          {$IFDEF GLD_SUPPORT_48BIT}
           // �Ή����ĂȂ��̂Ŗ���
          {$ELSE}
          if OriginalBitCount>8 then i:=i shr 8;
          FTransColor:=COLORREF((i shl 16)+(i shl 8)+i);
          {$ENDIF}
          // �ǂݍ��݃f�[�^������������
          Dec(FChunkSize,2);
          // �R�[���o�b�N
          DoCallBack(0);
         end;
  2,6:  // �q�f�a
        begin
         {$IFDEF GLD_SUPPORT_48BIT}
          // �Ή����ĂȂ��̂Ŗ���
         {$ELSE}
         if OriginalBitCount>24 then
          begin
           j:=(ReadMWord and $FF00) shr 8;
           i:=(ReadMWord and $FF00);
           FTransColor:=COLORREF(i or j or ((ReadMWord and $FF00) shl 8));
          end
         else
          begin
           j:=(ReadMWord and $FF);
           i:=(ReadMWord and $FF) shl 8;
           FTransColor:=COLORREF(i or j or ((ReadMWord and $FF) shl 16));
          end;
         {$ENDIF}
         // �ǂݍ��݃f�[�^������������
         Dec(FChunkSize,6);
         // �R�[���o�b�N
         DoCallBack(0);
        end;
   3:  // �p���b�g
       if (not FAlphaFlag) and (pcPLTE in FChunkFlag) then
        begin
         i:=FChunkSize;
         if i>PaletteSize then i:=PaletteSize;
         ReadByte(@FTransBuf,i);
         {$IFNDEF GLD_NOREVERSE_ALPHA}
         for i:=0 to 255 do FTransBuf[i]:=not FTransBuf[i];
         {$ENDIF}
         Dec(FChunkSize,i);
         FTransColor:=COLORREF($1FFFFFF);
         // �R�[���o�b�N
         DoCallBack(0);
        end;
  end;
end;


//------- ReadBGColor => �o�b�N�O���E���h�J���[�擾


procedure TGLDPNGReadStream.ReadBGColor;
var
 i,j: integer;

begin
 if (pcIHDR in FChunkFlag) or (not (pcIDAT in FChunkFlag)) then
  begin
   case FColorType of
    0,4:  // �O���C�X�P�[��
          begin
           i:=ReadMWord;
           {$IFDEF GLD_SUPPORT_48BIT}
           // �Ή����ĂȂ��̂Ŗ���
           {$ELSE}
           if OriginalBitCount>8 then i:=i shr 8;
           if FAlpha256OK then
            FBGColor:=COLORREF(i or $1000000)
           else
            FBGColor:=COLORREF((i shl 16) or (i shl 8) or i);
           {$ENDIF}
           // �ǂݍ��݃f�[�^������������
           Dec(FChunkSize,2);
           // �R�[���o�b�N
           DoCallBack(0);
          end;
    2,6:  // �q�f�a
          begin
           {$IFDEF GLD_SUPPORT_48BIT}
           // �Ή����ĂȂ��̂Ŗ���
           {$ELSE}
           if OriginalBitCount>24 then
            begin
             j:=(ReadMWord and $FF00) shr 8;
             i:=(ReadMWord and $FF00);
             FBGColor:=COLORREF(i or j or ((ReadMWord and $FF00) shl 8));
            end
           else
            begin
             j:=(ReadMWord and $FF);
             i:=(ReadMWord and $FF) shl 8;
             FBGColor:=COLORREF(i or j or ((ReadMWord and $FF) shl 16));
            end;
           {$ENDIF}
           // �ǂݍ��݃f�[�^������������
           Dec(FChunkSize,6);
           // �R�[���o�b�N
           DoCallBack(0);
          end;
     3:  // �p���b�g
         begin
          FBGColor:=COLORREF(Read1Byte or $1000000);
          // �ǂݍ��݃f�[�^������������
          Dec(FChunkSize);
          // �R�[���o�b�N
          DoCallBack(0);
         end;
   end;
  end;
end;


//------- ReadText => �e�L�X�g�擾


procedure TGLDPNGReadStream.ReadText;
var
 len: integer;
 pp,ps: pchar;
 txt,key: ansistring;

begin
 len:=FChunkSize;
 if len>0 then
  begin
   txt:=TextData;
   if txt<>'' then txt:=txt+LFCR;
   GetMem(pp,len+4);
   FChunkSize:=0;
   ps:=pp;
   try
    // �S���ǂ�
    ReadByte(ps,len);
    // �L�[�ǂݍ���
    while (ps^<>char(0)) and (len>0) do
    begin
     key:=key+ps^;
     Dec(len);
     Inc(ps);
    end;
    Inc(ps);
    // 'Comment'�ȊO�Ȃ�Ƃ΂�
    if key<>'Comment' then Exit;
    Dec(len);
    // �c��̃R�����g�t��
    if len>0 then
     begin
      while (len>0) do
      begin
       txt:=txt+ps^;
       Inc(ps);
       Dec(len);
      end;
      // ���s
      txt:=txt+LFCR;
      // �C���[�W�N���X�ɑ��
      TextData:=txt;
     end;
    // �R�[���o�b�N
    DoCallBack(0);
   finally
    FreeMem(pp);
   end;
  end;
end;


//------- ReadTime => �C���[�W�ۑ����Ԃ�ǂݍ���


procedure TGLDPNGReadStream.ReadTime;
begin
 if (FChunkSize=sizeof(TPNGTime)) and (FTime<>niL) then
  begin
   FTime^.Year:=ReadMWORD;
   ReadByte(@(FTime^.Month),sizeof(TPNGTime)-sizeof(FTime^.Year));
   Dec(FChunkSize,sizeof(TPNGTime));
   // �R�[���o�b�N
   DoCallBack(0);
  end;
end;


//------- ReadChrm => �F�x�ƃz���C�g�|�C���g�ǂݍ���


procedure TGLDPNGReadStream.ReadChrm;
begin
 if (pcIHDR in FChunkFlag) and (not ((pcIDAT in FChunkFlag) or (pcPLTE in FChunkFlag))) then
  if (FChunkSize=sizeof(TPNGChromaticities)) and (FChrm<>nil) then
   begin
    with FChrm^ do
    begin
     White_PX:=ReadMDWORD;
     White_PY:=ReadMDWORD;
     Red_X:=ReadMDWORD;
     Red_Y:=ReadMDWORD;
     Green_X:=ReadMDWORD;
     Green_Y:=ReadMDWORD;
     Blue_X:=ReadMDWORD;
     Blue_Y:=ReadMDWORD;
    end;
    Dec(FChunkSize,sizeof(TPNGChromaticities));
    // �R�[���o�b�N
    DoCallBack(0);
   end;
end;


//------- ReadGIFExt => GIF�f�[�^�ǂݍ���


procedure TGLDPNGReadStream.ReadGIFExt;
begin
 if (pcIHDR in FChunkFlag) and (not ((pcIDAT in FChunkFlag) or (pcPLTE in FChunkFlag))) then
  if (FChunkSize=sizeof(TPNGGIFExtension)) and (FGIFExt<>nil) then
   begin
    // ���̃`�����N�����C���e���`���ő������Ă���̂�
    // �Q�o�C�g�ȏ�̃f�[�^�ł����̂܂ܓǂݍ��݉\
    ReadByte(FGIFExt,sizeof(TPNGGIFExtension));
    Dec(FChunkSize,sizeof(TPNGGIFExtension));
    // �R�[���o�b�N
    DoCallBack(0);
   end;
end;


//------- ReadGLDData => GLDPNG���쐬�����`�����N�ǂݍ���


procedure TGLDPNGReadStream.ReadGLDData;
var
 dat,len: integer;
 pas: string;

begin
 if (pcIHDR in FChunkFlag) and (not ((pcTPNG in FChunkFlag) or (pcIDAT in FChunkFlag))) then
  begin
   FChunkFlag:=FChunkFlag+[pcTPNG];
   dat:=ReadMDWord;
   Dec(FChunkSize,4);
   if FChunkSize>0 then
    case dat of
     GLDPNG3Chunk:
      begin
       if Read1Byte<>0 then
        begin
         FPass:=FPassword;
         if (pas='') and (Assigned(FOnPassword)) then FOnPassword(self,FPass);
        end;
       Dec(FChunkSize);
       if (Read1Byte=1) and (FAlpha256flg) then FAlpha256OK:=TRUE;
       Dec(FChunkSize);
      end;
    end;
  end;
end;


//------- ReadChunk => �`�����N����


procedure TGLDPNGReadStream.ReadChunk;
begin
 while not (EOFFlag or CancelFlag or (pcIEND in FChunkFlag)) do
 begin
  FChunkSize:=ReadMDWord;
  FChunkName:=ReadMDWord;
  // �`�����N�ʏ���
  case FChunkName of
   IHDR: ReadHeader;
   IDAT: ReadImage;
   IEND: EndChunk;
   PLTE: ReadPalette;
   //sPLT:
   //hIST:
   tRNS: ReadTransColor;
   bKGD: ReadBGColor;
   sBIT: ReadsBIT;
   cHRM: ReadChrm;
   gAMA: ReadGamma;
   //pCAL:
   //sCAL:
   //sRGB:
   //iCCP:
   pHYs: ReadAspectData;
   tXt:  ReadText;
   //zTXt:
   tME:  ReadTime;
   gIFg: ReadGIFExt;
   //oFFs:
   tpNg: ReadGLDData;
  end;
  if FChunkSize>0 then SkipChunk;
  // CRC
  ReadMDWord;
 end;
end;


//---------------------------------------------------------
//  �s�N�Z������
//---------------------------------------------------------


//------- ConvertNone => ���̂܂�


function TGLDPNGReadStream.ConvertNone: pbyte;
begin
 result:=FPNGInfo.outbuf;
 Inc(result);
end;


//------- RGBtoBGR16 => �q�f�a�i15/16�r�b�g�p�j


function TGLDPNGReadStream.RGBtoBGR16: pbyte;
var
 i: integer;
 ps: PPNGRGB;
 pd: PWORD;
 pp: pointer;

begin
 ps:=PPNGRGB(FPNGInfo.outbuf);
 Inc(pbyte(ps));
 pd:=PWORD(FLineBuf);
 {$IFDEF GLD_SUPPORT_BIT15}
 if OriginalBitCount=15 then
  // 5:5:5
  for i:=Pred(FPassWidth) downto 0 do
  begin
   with ps^ do
    pd^:=(B shr 3) or ((G shl 2) and GLDGMask15) or ((R shl 7) and GLDRMask15);
   Inc(pbyte(ps),3);
   Inc(pbyte(pd),2);
  end
 else
 {$ENDIF}
  // 5:6:5
  for i:=Pred(FPassWidth) downto 0 do
  begin
   with ps^ do
    pd^:=(B shr 3) or ((G shl 3) and GLDGMask16) or ((R shl 8) and GLDRMask16);
   Inc(pbyte(ps),3);
   Inc(pbyte(pd),2);
  end;
 result:=FLineBuf;
end;


//------- RGBtoBGR24 => �q�f�a�i24�r�b�g�p�j


function TGLDPNGReadStream.RGBtoBGR24: pbyte;
var
 i: integer;
 ps: PPNGRGB;
 pd: PGLDPixRGB32;
 pp: pointer;

begin
 ps:=PPNGRGB(FPNGInfo.outbuf);
 Inc(pbyte(ps));
 pd:=PGLDPixRGB32(FLineBuf);
 for i:=Pred(FPassWidth) downto 0 do
 begin
  pd^.rgbRed:=ps^.R;
  pd^.rgbGreen:=ps^.G;
  pd^.rgbBlue:=ps^.B;
  Inc(pbyte(ps),3);
  Inc(pbyte(pd),3);
 end;
 result:=FLineBuf;
end;


//------- RGBtoBGR48 => �q�f�a(48�r�b�g�p)


function TGLDPNGReadStream.RGBtoBGR48: pbyte;
var
 i: integer;
 pd: PGLDPixRGB32;
 ps: PArrayByte;
 pp: pointer;

begin
 ps:=PArrayByte(FPNGInfo.outbuf);
 Inc(pbyte(ps));
 pd:=PGLDPixRGB32(FLineBuf);
 for i:=Pred(FPassWidth) downto 0 do
 begin
 {$IFDEF GLD_SUPPORT_48BIT}
  // �����̂c�h�a�̂P�v�f�̕��т��C���e�������g���[���킩��Ȃ��̂�
  // ���g���[���ɓ��ꂵ�Ă����B
  PArrayWord(pd)^[0]:=PArrayWord(ps)^[4];
  PArrayWord(pd)^[2]:=PArrayWord(ps)^[2];
  PArrayWord(pd)^[4]:=PArrayWord(ps)^[0];
  Inc(pbyte(ps),6);
  Inc(pbyte(pd),6);
 {$ELSE}
  pd^.rgbRed:=ps^[0];
  pd^.rgbGreen:=ps^[2];
  pd^.rgbBlue:=ps^[4];
  Inc(pbyte(ps),6);
  Inc(pbyte(pd),3);
 {$ENDIF}
 end;
 result:=FLineBuf;
end;


//------- RGBAtoBGRA16 => �q�f�a�`�i�r�b�g16�p�j


function TGLDPNGReadStream.RGBAtoBGRA16: pbyte;
var
 i: integer;
 pd: PWORD;
 ps: PArrayByte;
 pa: pbyte;
 pp: pointer;

begin
 ps:=PArrayByte(FPNGInfo.outbuf);
 Inc(pbyte(ps));
 pd:=PWORD(FLineBuf);
 pa:=FAlphaBuf;
 {$IFDEF GLD_SUPPORT_BIT15}
 if OriginalBitCount=15 then
  // 5:5:5
  for i:=Pred(FPassWidth) downto 0 do
  begin
   pd^:=(ps^[2] shr 3) or ((ps^[1] shl 2) and GLDGMask15) or ((ps^[0] shl 7) and GLDRMask15);
   pa^:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} ps^[3];
   Inc(pbyte(ps),4);
   Inc(pbyte(pd),2);
   Inc(pa);
  end
 else
 {$ENDIF}
  // 5:6:5
  for i:=Pred(FPassWidth) downto 0 do
  begin
   pd^:=(ps^[2] shr 3) or ((ps^[1] shl 3) and GLDGMask16) or ((ps^[0] shl 8) and GLDRMask16);
   pa^:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} ps^[3];
   Inc(pbyte(ps),4);
   Inc(pbyte(pd),2);
   Inc(pa);
  end;
 result:=FLineBuf;
end;


//------- RGBAtoBGRA32 => �q�f�a�`�i�r�b�g32�p�j


function TGLDPNGReadStream.RGBAtoBGRA32: pbyte;
var
 i: integer;
 pd: PGLDPixRGB32;
 ps: PArrayByte;
 pa: pbyte;
 pp: pointer;

begin
 ps:=PArrayByte(FPNGInfo.outbuf);
 Inc(pbyte(ps));
 pd:=PGLDPixRGB32(FLineBuf);
 pa:=FAlphaBuf;
 for i:=Pred(FPassWidth) downto 0 do
 begin
  pd^.rgbRed:=ps^[0];
  pd^.rgbGreen:=ps^[1];
  pd^.rgbBlue:=ps^[2];
  pa^:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} ps^[3];
  Inc(pbyte(ps),4);
  Inc(pbyte(pd),3);
  Inc(pa);
 end;
 result:=FLineBuf;
end;


//------- RGBAtoBGRA64 => �q�f�a�`�i�r�b�g64�p�j


function TGLDPNGReadStream.RGBAtoBGRA64: pbyte;
var
 i: integer;
 pd: PGLDPixRGB32;
 ps: PArrayByte;
 {$IFDEF GLD_SUPPORT_16BIT_ALPHA}
 pa: pword;
 {$ELSE}
 pa: pbyte;
 {$ENDIF}
 pp: pointer;

begin
 ps:=PArrayByte(FPNGInfo.outbuf);
 Inc(pbyte(ps));
 pd:=PGLDPixRGB32(FLineBuf);
 pa:=pointer(FAlphaBuf);
 for i:=Pred(FPassWidth) downto 0 do
 begin
 {$IFDEF GLD_SUPPORT_48BIT}
  // �����̂c�h�a�̂P�v�f�̕��т��C���e�������g���[���킩��Ȃ��̂�
  // ���g���[���ɓ��ꂵ�Ă����B
  PArrayWord(pd)^[0]:=PArrayWord(ps)^[4];
  PArrayWord(pd)^[2]:=PArrayWord(ps)^[2];
  PArrayWord(pd)^[4]:=PArrayWord(ps)^[0];
  {$IFDEF GLD_SUPPORT_16BIT_ALPHA}
  pa^:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} PArrayWord(ps)^[6];
  {$ELSE}
  pa^:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} ps^[6];
  {$ENDIF}
  Inc(pbyte(ps),8);
  Inc(pbyte(pd),6);
  Inc(pa);
 {$ELSE}
  pd^.rgbRed:=ps^[0];
  pd^.rgbGreen:=ps^[2];
  pd^.rgbBlue:=ps^[4];
  {$IFDEF GLD_SUPPORT_16BIT_ALPHA}
  pa^:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} PArrayWord(ps)^[6];
  {$ELSE}
  pa^:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} ps^[6];
  {$ENDIF}
  Inc(pbyte(ps),8);
  Inc(pbyte(pd),3);
  Inc(pa);
 {$ENDIF}
 end;
 result:=FLineBuf;
end;


//------- Change2to4 => 2����4�r�b�g�ϊ�


function TGLDPNGReadStream.Change2to4: pbyte;
var
 ps,pd: pbyte;
 i,j,k: integer;

begin
 ps:=pbyte(FPNGInfo.outbuf);
 Inc(pbyte(ps));
 pd:=FLineBuf;
 i:=FPassWidth;
 while (i>0) do
 begin
  j:=ps^;
  k:=(j shr 2) and $30;
  pd^:=(k or ((j shr 4) and 3));
  Inc(pd);
  k:=(j shl 2) and $30;
  pd^:=k or (j and 3);
  Inc(ps);
  Inc(pd);
  Dec(i,4);
 end;
 result:=FLineBuf;
end;


//------- ChangeGray16 => 16����8�r�b�g�ϊ��i�A���t�@�Ȃ��j


function TGLDPNGReadStream.ChangeGray16: pbyte;
var
 ps,pd: pbyte;
 i,j,k: integer;

begin
 ps:=FPNGInfo.outbuf;
 Inc(pbyte(ps));
 pd:=FLineBuf;
 for i:=Pred(FPassWidth) downto 0 do
 begin
  pd^:=ps^;
  Inc(ps,2);
  Inc(pd);
 end;
 result:=FLineBuf;
end;


//------- ChangeGray16A => 16����8�r�b�g�ϊ��i�A���t�@����j


function TGLDPNGReadStream.ChangeGray16A: pbyte;
var
 ps,pd: pbyte;
 {$IFDEF GLD_SUPPORT_16BIT_ALPHA}
 pa: pword;
 {$ELSE}
 pa: pbyte;
 {$ENDIF}
 i,j,k: integer;

begin
 ps:=FPNGInfo.outbuf;
 Inc(pbyte(ps));
 pd:=FLineBuf;
 pa:=pointer(FAlphaBuf);
 for i:=Pred(FPassWidth) downto 0 do
 begin
  pd^:=ps^;
  {$IFDEF GLD_SUPPORT_16BIT_ALPHA}
  pa^:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} PArrayWord(ps)^[1];
  {$ELSE}
  pa^:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} PArrayByte(ps)^[2];
  {$ENDIF}
  Inc(ps,4);
  Inc(pd);
  Inc(pa);
 end;
 result:=FLineBuf;
end;


//------- ChangeGray8A => 8�r�b�g�ϊ��i�A���t�@����j


function TGLDPNGReadStream.ChangeGray8A: pbyte;
var
 ps,pd,pa: pbyte;
 i,j,k: integer;

begin
 ps:=FPNGInfo.outbuf;
 Inc(pbyte(ps));
 pd:=FLineBuf;
 pa:=FAlphaBuf;
 for i:=Pred(FPassWidth) downto 0 do
 begin
  pd^:=ps^;
  pa^:={$IFNDEF GLD_NOREVERSE_ALPHA}not{$ENDIF} PArrayByte(ps)^[1];
  Inc(ps,2);
  Inc(pd);
  Inc(pa);
 end;
 result:=FLineBuf;
end;


//------- SetPixels_Inter1 => �c�h�a�ɑ��(�C���^���[�X�F�Q�F)


procedure TGLDPNGReadStream.SetPixels_Inter1(pd,ps: pbyte);
var
 pp: pbyte;
 p,i,j,pdinc,psbcnt,pdbcnt,pdx: integer;

begin
 psbcnt:=$80;
 pp:=pd;
 pdx:=FInterStartX;
 Inc(pp,pdx shr 3);
 pdbcnt:=BitROr[pdx and 7];
 pdinc:=FInterIncX;

 for i:=Pred(FPassWidth) downto 0 do
 begin
  if psbcnt=$80 then p:=ps^;
  if (psbcnt and p)=0 then j:=0 else j:=1;
  psbcnt:=psbcnt shr 1;
  if psbcnt=0 then
   begin
    psbcnt:=$80;
    Inc(ps);
   end;

  if j=0 then
   pp^:=pp^ and (not pdbcnt)
  else
   pp^:=pp^ or pdbcnt;

  Inc(pdx,pdinc);
  pp:=pd;
  Inc(pp,pdx shr 3);
  pdbcnt:=BitROr[pdx and 7];
 end;
end;


//------- SetPixels_Inter4 =>  �c�h�a�ɑ��(�C���^���[�X�F�P�U�F)


procedure TGLDPNGReadStream.SetPixels_Inter4(pd,ps: pbyte);
var
 pp: pbyte;
 p,i,j,lx,pdinc,psbcnt,pdbcnt,pdx: integer;

begin
 psbcnt:=0;

 pdx:=FInterStartX;
 pp:=pd;
 Inc(pp,pdx shr 1);
 pdbcnt:=pdx and 1;
 pdinc:=FInterIncX;

 for i:=Pred(FPassWidth) downto 0 do
 begin
  if psbcnt=0 then
   begin
    p:=ps^;
    j:=(p and $F0) shr 4;
    Inc(psbcnt);
   end
  else
   begin
    j:=(p and $F);
    psbcnt:=0;
    Inc(ps);
   end;

  if pdbcnt=0 then
   begin
    pp^:=(pp^ and $0F) or (j shl 4);
   end
  else
   begin
    pp^:=(pp^ and $F0) or j;
   end;

  Inc(pdx,pdinc);
  pp:=pd;
  Inc(pp,pdx shr 1);
  pdbcnt:=pdx and 1;
 end;
end;


//------- SetPixels_Inter8 => �c�h�a�ɑ��(�C���^���[�X�F�Q�T�U�F)


procedure TGLDPNGReadStream.SetPixels_Inter8(pd,ps: pbyte);
var
 i,lx,pdinc: integer;

begin
 pdinc:=FInterIncX;
 Inc(pd,FInterStartX);

 for i:=Pred(FPassWidth) downto 0 do
 begin
  pd^:=ps^;
  Inc(pd,pdinc);
  Inc(ps);
 end;
end;


//------- SetPixels_Inter16 =>  �c�h�a�ɑ��(�C���^���[�X�F16bit)


procedure TGLDPNGReadStream.SetPixels_Inter16(pd,ps: pbyte);
var
 i,lx,pdinc: integer;

begin
 pdinc:=FInterIncX;
 Inc(pd,FInterStartX);

 for i:=Pred(FPassWidth) downto 0 do
 begin
  PWORD(pd)^:=PWORD(ps)^;
  Inc(pd,pdinc);
  Inc(ps,2);
 end;
end;


//------- SetPixels_Inter24 =>  �c�h�a�ɑ��(�C���^���[�X�F24bit)


procedure TGLDPNGReadStream.SetPixels_Inter24(pd,ps: pbyte);
var
 i,lx,pdinc: integer;

begin
 pdinc:=FInterIncX;
 Inc(pd,FInterStartX);

 for i:=Pred(FPassWidth) downto 0 do
 begin
  PGLDPixRGB32(pd)^.rgbBlue :=PGLDPixRGB32(ps)^.rgbBlue;
  PGLDPixRGB32(pd)^.rgbGreen:=PGLDPixRGB32(ps)^.rgbGreen;
  PGLDPixRGB32(pd)^.rgbRed  :=PGLDPixRGB32(ps)^.rgbRed;
  Inc(pd,pdinc);
  Inc(ps,3);
 end;
end;


//------- SetPixels_Inter32 =>  �c�h�a�ɑ��(�C���^���[�X�F32bit)


procedure TGLDPNGReadStream.SetPixels_Inter32(pd,ps: pbyte);
var
 i,lx,pdinc: integer;

begin
 pdinc:=FInterIncX;
 Inc(pd,FInterStartX);

 for i:=Pred(FPassWidth) downto 0 do
 begin
  PGLDPixRGB32(pd)^.rgbBlue :=PGLDPixRGB32(ps)^.rgbBlue;
  PGLDPixRGB32(pd)^.rgbGreen:=PGLDPixRGB32(ps)^.rgbGreen;
  PGLDPixRGB32(pd)^.rgbRed  :=PGLDPixRGB32(ps)^.rgbRed;
  Inc(pd,pdinc);
  Inc(ps,4);
 end;
end;


//------- SetPixels_InterA => �c�h�a�ɑ��(�C���^���[�X�F�A���t�@�`�����l���p)


procedure TGLDPNGReadStream.SetPixels_InterA(pd,ps: pbyte);
var
 i,lx,pdinc: integer;

begin
 pdinc:=FInterAIncX;
 Inc(pd,FInterAStartX);

 for i:=Pred(FPassWidth) downto 0 do
 begin
  {$IFDEF GLD_SUPPORT_16BIT_ALPHA}
  PWORD(pd)^:=PWORD(ps)^;
  Inc(pd,pdinc);
  Inc(PWORD(ps));
  {$ELSE}
  pd^:=ps^;
  Inc(pd,pdinc);
  Inc(ps);
  {$ENDIF}
 end;
end;


//------- SetPixels_Normal =>  �c�h�a�ɑ��(����)


procedure TGLDPNGReadStream.SetPixels_Normal(pd,ps: pbyte);
begin
 Move(ps^,pd^,FPassLineSize);
end;


//------- SetPixels_Normal_A =>  �c�h�a�ɑ��(�A���t�@�`�����l���p)


procedure TGLDPNGReadStream.SetPixels_Normal_A(pd,ps: pbyte);
begin
 Move(ps^,pd^,FPassWidth);
end;

end.
