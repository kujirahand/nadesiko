unit GLDStream;

// ******************************************
// *  GLDGraphicStream                      *
// *                                        *
// *      2001.07.04  Copyright by Tarquin  *
// *                                        *
// ******************************************
//
// ����́ATBitmap�p�X�g���[���A�N�Z�X�N���X�ł��B
// ���X���b�h�ɂ͔�Ή��ł��B
//
// (����)
//
//  TGLDCustomReadStream
//   �EReadStream��override���邱��
//
//  TGLDCustomWriteStream


{$I taki.inc}

interface

uses
 Windows, Classes, SysUtils, Graphics,
 SFunc;

const
 // �𑜓x�̒P��
 GLD_US_ASPECT = 0;
 GLD_US_METER  = 1;
 GLD_US_INCH   = 2;

type
 TGLDBmp = Graphics.TBitmap;

 // �ėp���[�h�J�X�^���N���X
 TGLDCustomReadStream=class(TObject)
  private
   FStartCount:          integer;       // �R�[���o�b�N�p�f�[�^
   FOldCount:            integer;
   FStdParcent:          integer;
   FMaxParcent:          integer;
   FMaxSize:             integer;
   FCallType:            integer;
   FStartPosition:       integer;
   FOldLineCount:        integer;

   FStreamSize:          integer;       // �X�g���[���̑S�̂̃T�C�Y
   FReadPos:             integer;       // ���݂̈ʒu
   FBuf,FReadBuf:        pbyte;         // �o�b�t�@�|�C���^
   FBufLength:           integer;       // �o�b�t�@���̃f�[�^��
   FFilePosition:        integer;       // �ŏ��ɓǂݍ��ވʒu

   FCancelFlag:          boolean;       // �L�����Z��
   FEOFFlag:             boolean;       // �t�@�C���I�[�H(TRUE=�I�[�j

   FMacBinaryFlag:       boolean;       // �}�b�N�o�C�i���`�F�b�N�̗L��
   FMacBinary:           boolean;       // �}�b�N�o�C�i���̗L��

   FStream:              TStream;       // �ǂݍ��ݐ�

   function  ReadBuf(zure: integer): boolean;
  protected
   procedure ReadSkipByte(n: integer);
   procedure ReadByte(pp: pointer; len: integer);
   function  Read1Byte: Byte;
   function  ReadWord: Word;
   function  ReadMWord: Word;
   function  ReadDWord: DWORD;
   function  ReadMDword: DWORD;

   procedure SetCallBackParam(ctype,msize,par: integer);
   procedure StartCallBack;
   procedure EndCallBack;
   procedure DoCallBack(cnt: integer);
   function  CallBackProc(cnt: integer): boolean; virtual;

   procedure SetLoadStream(stream: TStream; size: integer);
   procedure FlushStream;

   property Position: integer read FReadPos;
   property EOFFlag: boolean read FEOFFlag;
   property CancelFlag: boolean read FCancelFlag;
   property Stream: TStream read FStream;
  public
   destructor  Destroy; override;
   property MacBinary: boolean read FMacBinary write FMacBinary;
   property MacBinaryCheck: boolean read FMacBinaryFlag write FMacBinaryFlag;
 end;

 // �摜�t�H�[�}�b�g�p���[�h�J�X�^���N���X
 TGLDCustomGraphicReadStream=class(TGLDCustomReadStream)
  private
   FText:                string;        // �e�L�X�g�f�[�^
   FImgWidth,FImgHeight: integer;       // �C���[�W�̑傫��
   FImgBitCount:         integer;       // �C���[�W�̃r�b�g���iDIB�p�ɏC���ρj
   FOrgBitCount:         integer;       // �C���[�W�̃I���W�i���r�b�g��
   FPaletteSize:         integer;       // �p���b�g�̐F��
   FUnitSpecifier:       integer;
   FWidthSpecific:       integer;
   FHeightSpecific:      integer;

   FImage:               TGLDBmp;       // �V���������C���[�W�N���X
   FColorBufPtr:         PGLDPalRGB;    // �J���[�e�[�u���ۊǗp�o�b�t�@
   FMes:                 string;        // �\�����b�Z�[�W

   function  CreateColorBuf: PGLDPalRGB;
   procedure FreeColorBuf;
  protected
   procedure ReadStream; virtual; abstract;
   procedure CreateDIB; virtual;
   function  CallBackProc(cnt: integer): boolean; override;

   property Image: TGLDBmp read FImage;
   property ColorTBLBuf: PGLDPalRGB read CreateColorBuf;
   property Mes: string read FMes write FMes;
  public
   constructor Create; virtual;
   destructor  Destroy; override;
   procedure LoadFromStream(img: TGLDBmp; stream: TStream; size: integer);

   // �ǂݍ��݉摜���
   property Width: integer read FImgWidth write FImgWidth;
   property Height: integer read FImgHeight write FImgHeight;
   property BitCount: integer read FImgBitcount write FImgBitCount;
   property OriginalBitCount: integer read FOrgBitCount write FOrgBitCount;
   property PaletteSize: integer read FPaletteSize write FPaletteSize;
   property UnitSpecifier: integer read FUnitSpecifier write FUnitSpecifier;
   property WidthSpecific: integer read FWidthSpecific write FWidthSpecific;
   property HeightSpecific: integer read FHeightSpecific write FHeightSpecific;

   property TextData: string read FText write FText;
 end;

 // �ėp���C�g�J�X�^���N���X
 TGLDCustomWriteStream=class(TObject)
  private
   FStartCount:         integer;       // �R�[���o�b�N�p�f�[�^
   FOldCount:           integer;
   FStdParcent:         integer;
   FMaxParcent:         integer;
   FMaxSize:            integer;
   FCallType:           integer;
   FStartPosition:      integer;

   FWriteLength:        integer;       // �o�b�t�@�ɏ������񂾃f�[�^��
   FWriteStreamSize:    integer;       // �X�g���[���ɏ������񂾃f�[�^��
   FWriteBuf,FBuf:      pbyte;         // �o�b�t�@�|�C���^

   FStream:             TStream;       // �������ݐ�

   FCancelFlag:         boolean;       // �L�����Z��
   FMes:                string;        // �\�����b�Z�[�W
   procedure WriteBuf;
  protected
   procedure WriteByte(buf: pointer; cnt: integer);
   procedure Write1Byte(i: integer);
   procedure WriteWord(i: integer);
   procedure WriteMWord(i: integer);
   procedure WriteDWord(i: integer);
   procedure WriteMDWord(i: integer);
   procedure FlushStream;

   procedure SetCallBackParam(ctype,msize,par: integer);
   procedure StartCallBack;
   procedure EndCallBack;
   procedure DoCallBack(cnt: integer);
   function  CallBackProc(cnt: integer): boolean; virtual;

   procedure SetWriteStream(stream: TStream);

   property CancelFlag: boolean read FCancelFlag;
   property Stream: TStream read FStream;
  public
   constructor Create; virtual;
   destructor  Destroy; override;
 end;

 // �摜�t�H�[�}�b�g�p���C�g�J�X�^���N���X
 TGLDCustomGraphicWriteStream=class(TGLDCustomWriteStream)
  private
   FImage:              TGLDBmp;       // �ۑ�����C���[�W
  protected
   procedure WriteStream; virtual; abstract;
   function  CallBackProc(cnt: integer): boolean; override;

   property Mes: string read FMes write FMes;
   property Image: TGLDBmp read FImage;
  public
   procedure SaveToStream(img: TGLDBmp; stream: TStream);
 end;

function  GLDBitCount(pf: TPixelFormat): integer;
function  GLDPixelFormat(bcnt: integer): TPIxelFormat;

implementation

const
 MaxBufLength         = 65536; // �o�b�t�@�̑傫��


//------- GLDPixelFormat => �r�b�g�J�E���g��TPixelFormat�ŕԂ�


function GLDPixelFormat(bcnt: integer): TPIxelFormat;
begin
 case bcnt of
   1: result:=pf1bit;
   4: result:=pf4bit;
   8: result:=pf8bit;
  15: result:=pf15bit; 
  16: result:=pf16bit;
  32: result:=pf32bit;
 else
  result:=pf24bit;
 end;
end;


//------- GLDBitCount => TPixelFormat���r�b�g�J�E���g�ŕԂ�


function GLDBitCount(pf: TPixelFormat): integer;
begin
 case pf of
    pf1bit: result:=1;
    pf4bit: result:=4;
    pf8bit: result:=8;
   pf15bit: result:=15;
   pf16bit: result:=16;
   pf32bit: result:=32;
  pfCustom: result:=15;
 else
  result:=24;
 end;
end;


//***************************************************
//*   TGLDCustomGraphicReadStream                   *
//***************************************************


//------- Create => �N���X�쐬


constructor TGLDCustomGraphicReadStream.Create;
begin
 inherited;
 FMacBinaryFlag:=TRUE;
 FText:='';
end;


//------- Destroy => �N���X���


destructor TGLDCustomGraphicReadStream.Destroy;
begin
 FreeColorBuf;
 inherited Destroy;
end;


//------- CreateDIB => �c�h�a�쐬


procedure TGLDCustomGraphicReadStream.CreateDIB;
var
 i: integer;
 pcor: PDWORD;
 bmp: TBitmap;

begin
 with FImage do
 begin
  Assign(nil);
  Transparent:=FALSE;
  PixelFormat:=GLDPixelFormat(FImgBitCount);
  Width:=FImgWidth; Height:=FImgHeight;
  if FColorBufPtr<>nil then
   Palette:=CreatePaletteHandle(ColorTBLBuf,FPaletteSize);
 end;
end;


//------- CreateColorBuf => �J���[�e�[�u���p�o�b�t�@�쐬


function TGLDCustomGraphicReadStream.CreateColorBuf: PGLDPalRGB;
begin
 if FColorBufPtr=nil then GetMem(FColorBufPtr,256*sizeof(TGLDPalRGB));
 result:=FColorBufPtr;
end;


//------- FreeColorBuf => �J���[�e�[�u���p�o�b�t�@���


procedure TGLDCustomGraphicReadStream.FreeColorBuf;
begin
 if FColorBufPtr<>nil then
  begin
   FreeMem(FColorBufPtr);
   FColorBufPtr:=nil;
  end;
end;


//------- LoadFromStream => �X�g���[������ǂݍ���
// (����) img�̃N���X�͌Ăяo���O�ɍ���Ă������ƁI�I
//        size�̓��[�h�ł���ő�o�C�g���ł��B
//        �A�������t�@�C���Ȃǂ̓��ʂȏꍇ������
//        �ʏ��0�i�X�g���[���̍ő�l�ɂȂ�j�ł��܂��܂���B


procedure TGLDCustomGraphicReadStream.LoadFromStream(img: TGLDBmp; stream: TStream; size: integer);
var
 ivn: TNotifyEvent;

begin
 // ��d�C�x���g������j�~���邽��
 ivn:=img.OnChange;
 img.OnChange:=nil;
 try
  // �f�[�^������
  SetLoadStream(stream,size);
  FImage:=img;
  FText:='';
  FPaletteSize:=0;
  FUnitSpecifier:=0;
  FWidthSpecific:=0;
  FHeightSpecific:=0;

  // �ǂݍ��݃��C��
  ReadStream;
 finally
  // ����
  FlushStream;
  FreeColorBuf;
  // �C�x���g��߂�
  img.OnChange:=ivn;
 end;
end;


//------- CallBackProc => �R�[���o�b�N�{��


function TGLDCustomGraphicReadStream.CallBackProc(cnt: integer): boolean;
var
 n: integer;
 md: TProgressStage;
 flg: boolean;

begin
 result:=FALSE;
 if Assigned(FImage.OnProgress) then
  begin
   case cnt of
    0:     md:=psStarting;
    1..99: md:=psRunning;
   else
    begin
     md:=psEnding;
     cnt:=100;
    end;
   end;
   FImage.OnProgress(FImage,md,cnt,FALSE,Rect(0,0,0,0),FMes);
  end;
end;


//***************************************************
//*   TGLDCustomReadStream                          *
//***************************************************


//------- Destroy => �N���X���


destructor TGLDCustomReadStream.Destroy;
begin
 if FReadBuf<>nil then
  begin
   FreeMem(FReadBuf);
   FReadBuf:=nil;
  end;
 inherited Destroy;
end;


//------- SetLoadStream => �ǂݍ��ݑΏۂ̃X�g���[���ݒ�
// (����)
//        size�̓��[�h�ł���ő�o�C�g���ł��B
//        �A�������t�@�C���Ȃǂ̓��ʂȏꍇ������
//        �ʏ��0�i�X�g���[���̍ő�l�ɂȂ�j�ł��܂��܂���B


procedure TGLDCustomReadStream.SetLoadStream(stream: TStream; size: integer);
begin
 // �f�[�^������
 FStream:=stream;
 FFilePosition:=stream.Position;
 if size>0 then
  FStreamSize:=size
 else
  FStreamSize:=stream.Size-FFilePosition;
 FReadPos:=0;
 FCancelFlag:=FALSE;
 FEOFFlag:=FALSE;

 // �T�C�Y0�Ȃ牽�����Ȃ�
 if FStreamSize<=0 then
  begin
   FEOFFlag:=TRUE;
   Exit;
  end;
 if (stream is TMemoryStream) then
  begin
   FBuf:=(stream as TMemoryStream).Memory;
   Inc(FBuf,FFilePosition);
   FBufLength:=FStreamSize;
  end
 else
  begin
   if FReadBuf=nil then GetMem(FReadBuf,MaxBufLength);
   FBufLength:=0;
   FBuf:=FReadBuf;
  end;

 // �}�b�N�o�C�i���`�F�b�N
 if FBufLength=0 then ReadBuf(0);
 if FMacBinaryFlag and (FStreamSize>128) then
  begin
   if (PArrayByte(FBuf)^[0]=0) and (PArrayByte(FBuf)^[74]=0) then
    begin
     MacBinary:=TRUE;
     Inc(FBuf,128);
     FReadPos:=128;
    end
   else
    begin
     MacBinary:=FALSE;
     FReadPos:=0;
    end;
  end;
end;


//------- FlushStream => �X�g���[���I������


procedure TGLDCustomReadStream.FlushStream;
begin
 if FReadBuf<>nil then
  begin
   FreeMem(FReadBuf);
   FReadBuf:=nil;
  end;
 // �ǂ񂾕������i�߂�
 // ���o�b�t�@���߂Ƃ�����Ă���̂Ő��m�ȃ��[�h������Ȃ��̂�
 //   ���̂悤�ɂ��Ă��܂��B
 if FStream<>nil then FStream.Seek(FReadPos+FFilePosition,soFromBeginning);
end;


//------- SetCallBackParam => �R�[���o�b�N���[�h�ݒ�
// ctype=�R�[���o�b�N�^�C�v(0=�t�@�C���ǂݍ��݈ʒu 1=�J�E���g)
// msize=ctype=0�̎��̍ő�J�E���g��
// par=�c���%���犄��^����%(0=�ő� 1-100(%))
// ���̊֐����Ăяo���ƃR�[���o�b�N�J�E���g�̓N���A�����

procedure TGLDCustomReadStream.SetCallBackParam(ctype,msize,par: integer);
begin
 // �O�f�[�^�N���A
 Inc(FStartCount,FStdParcent);
 FOldCount:=FStartCount;
 Dec(FMaxParcent,FStdParcent);
 // �V�f�[�^�ݒ�
 if ctype=0 then
  begin
   FMaxSize:=FStreamSize;
   FStartPosition:=FReadPos;
  end
 else
  FMaxSize:=msize;
 if FMaxSize=0 then FMaxSize:=1;
 FCallType:=ctype;
 if (par=0) or (par>=100) then FStdParcent:=FMaxParcent
 else FStdParcent:=(FMaxParcent*par) div 100;
end;


//------- StartCallBack => �X�^�[�g�R�[���o�b�N


procedure TGLDCustomReadStream.StartCallBack;
begin
 FStartCount:=0;
 FOldCount:=0;
 FStdParcent:=0;
 FMaxParcent:=99;
 FCancelFlag:=FALSE;

 FCancelFlag:=CallBackProc(0);
end;


//------- EndCallBack => �G���h�R�[���o�b�N


procedure TGLDCustomReadStream.EndCallBack;
begin
 FCancelFlag:=CallBackProc(100);
end;


//------- DoCallback => �R�[���o�b�N


procedure TGLDCustomReadStream.DoCallBack(cnt: integer);
var
 i,j,k: integer;

begin
 j:=FStdParcent;
 k:=FMaxSize;
 case FCallType of
  0: // �t�@�C���T�C�Y�J�E���g����
     begin
      i:=((FReadPos-FStartPosition)*j) div k;
     end;
  1: // �w��J�E���g����
     begin
      if cnt>=k then i:=j else i:=(cnt*j) div k;
     end;
 end;
 Inc(i,FStartCount);
 if (i>FOldCount) then
  begin
   FOldCount:=i;
   if FCallType=1 then
    begin
     FOldLineCount:=cnt;
    end;
   FCancelFlag:=CallBackProc(i);
  end;
end;


//------- CallBackProc => �R�[���o�b�N�{��


function TGLDCustomReadStream.CallBackProc(cnt: integer): boolean;
begin
 result:=FALSE;
end;


//------- ReadBuf => �o�b�t�@�ɓǂݍ���


function TGLDCustomReadStream.ReadBuf(zure: integer): boolean;
var
 i,nn: integer;
 pp: pbyte;

begin
 result:=FALSE;
 // �o�b�t�@���ɓǂݍ��ރo�C�g���v�Z
 i:=FStreamSize-FReadPos;
 if i>MaxBufLength-zure then
  begin
   i:=MaxBufLength-zure;
   FBufLength:=MaxBufLength;
  end
 else
  FBufLength:=i+zure;
 // ���炷
 pp:=FReadBuf;
 Inc(pp,zure);
 // �ǂݍ���
 FStream.ReadBuffer(pp^,i);
 // �o�b�t�@�|�C���^������
 FBuf:=FReadBuf;
 result:=TRUE;
end;


//------- ReadSkipByte => �ǂݔ�΂�


procedure TGLDCustomReadStream.ReadSkipByte(n: integer);
begin
 // �ǂݍ��߂�H
 if FEOFFlag or FCancelFlag then Exit;
 if n+FReadPos>FStreamSize then
  begin
   FEOFFlag:=TRUE;
   Exit;
  end;
 // �����O�Ȃ�G���[
 if n=0 then
  begin
   FCancelFlag:=TRUE;
   Exit;
  end;

 if n<=FBufLength then
  // �o�b�t�@�����ő����
  begin
   Inc(FBuf,n);
   Inc(FReadPos,n);
   Dec(FBufLength,n);
  end
 else
  // �o�b�t�@�����ő���Ȃ�
  begin
   Inc(FReadPos,n);
   Dec(n,FBufLength);
   FBufLength:=0;
   // �t�@�C���̕����Ƃ΂�
   FStream.Seek(n,soFromCurrent);
  end;
end;


//------- ReadByte => �����ǂݍ���


procedure TGLDCustomReadStream.ReadByte(pp: pointer; len: integer);
var
 n: integer;

begin
 if FEOFFlag or FCancelFlag then Exit;
 // �����O�Ȃ璆�~
 if len<=0 then
  begin
   FCancelFlag:=TRUE;
   Exit;
  end;
 // �������f�[�^�������ꍇ�̓G���[
 if FStreamSize<FReadPos+len then
  begin
   FEOFFlag:=TRUE;
   Exit;
  end;

 if len<=FBufLength then
  // �o�b�t�@�����ő����
  begin
   Move(FBuf^,pp^,len);
   Inc(FBuf,len);
   Inc(FReadPos,len);
   Dec(FBufLength,len);
  end
 else
  // �o�b�t�@�����ő���Ȃ�
  begin
   // �o�b�t�@����c��f�[�^��ǂݍ���
   if FBufLength>0 then
    begin
     Move(FBuf^,pp^,FBufLength);
     Inc(pbyte(pp),FBufLength);
     Dec(len,FBufLength);
     Inc(FReadPos,FBufLength);
     FBufLength:=0;
    end;
   // �X�g���[������ǂݏo��
   if len>=MaxBufLength then
    begin
     n:=len-MaxBufLength;
     FStream.ReadBuffer(pp^,n);
     Dec(len,n);
     Inc(pbyte(pp),n);
     Inc(FReadPos,n);
    end;
   // �ő�o�b�t�@���ȉ��ɂȂ�����o�b�t�@�ɓǂݍ���ł������炾��
   if len>0 then
    begin
     ReadBuf(0);
     Move(FBuf^,pp^,len);
     Inc(FBuf,len);
     Inc(FReadPos,len);
     Dec(FBufLength,len);
    end;
  end;
end;


//------- Read1Byte => 1�o�C�g�ǂݍ���


function TGLDCustomReadStream.Read1Byte: byte;
var
 x: longint;

begin
 result:=0;
 // �ǂ߂�H
 if FEOFFlag or FCancelFlag then Exit;
 if FReadPos+1>FStreamSize then
  begin
   FEOFFlag:=TRUE;
   Exit;
  end;
 // �o�b�t�@�f�[�^���󂫁H
 if FBufLength=0 then ReadBuf(0);
 result:=FBuf^;
 Inc(FReadPos);
 Inc(FBuf);
 Dec(FBufLength);
end;


//------- ReadMWord => 2�o�C�g�ǂݍ���(���g���[���`��)


function TGLDCustomReadStream.ReadMWord: Word;
var
 x: longint;

begin
 result:=0;
 // �ǂ߂�H
 if FEOFFlag or FCancelFlag then Exit;
 if FReadPos+2>FStreamSize then
  begin
   FEOFFlag:=TRUE;
   Exit;
  end;
 // �o�b�t�@�f�[�^������Ȃ��H
 x:=FBufLength;
 if x<2 then
  begin
   if x>0 then Move(FBuf^,FReadBuf^,x);
   ReadBuf(x);
  end;
 x:=PWORD(FBuf)^;
 result:=((x and $FF) shl 8) or ((x and $FF00) shr 8);
 Inc(FReadPos,2);
 Inc(FBuf,2);
 Dec(FBufLength,2);
end;


//------- ReadMDWord => 4�o�C�g�ǂݍ���(���g���[���`��)


function TGLDCustomReadStream.ReadMDWord: DWORD;
var
 x: longint;

begin
 result:=0;
 // �ǂ߂�H
 if FEOFFlag or FCancelFlag then Exit;
 if FReadPos+4>FStreamSize then
  begin
   FEOFFlag:=TRUE;
   Exit;
  end;
 // �o�b�t�@�f�[�^������Ȃ��H
 x:=FBufLength;
 if x<4 then
  begin
   if x>0 then Move(FBuf^,FReadBuf^,x);
   ReadBuf(x);
  end;
 x:=PDWORD(FBuf)^;
 result:=((x and $FF000000) shr 24)+((x and $FF0000) shr 8)+
         ((x and $FF00) shl 8)+((x and $FF) shl 24);
 Inc(FReadPos,4);
 Inc(FBuf,4);
 Dec(FBufLength,4);
end;


//------- ReadWord => 2�o�C�g�ǂݍ���


function TGLDCustomReadStream.ReadWord: Word;
var
 x: longint;

begin
 result:=0;
 // �ǂ߂�H
 if FEOFFlag or FCancelFlag then Exit;
 if FReadPos+2>FStreamSize then
  begin
   FEOFFlag:=TRUE;
   Exit;
  end;
 // �o�b�t�@�f�[�^������Ȃ��H
 x:=FBufLength;
 if x<2 then
  begin
   if x>0 then Move(FBuf^,FReadBuf^,x);
   ReadBuf(x);
  end;
 result:=PWORD(FBuf)^;
 Inc(FReadPos,2);
 Inc(FBuf,2);
 Dec(FBufLength,2);
end;


//------- ReadDword => 4�o�C�g�ǂݍ���


function TGLDCustomReadStream.ReadDWord: DWORD;
var
 x: longint;

begin
 result:=0;
 // �ǂ߂�H
 if FEOFFlag or FCancelFlag then Exit;
 if FReadPos+4>FStreamSize then
  begin
   FEOFFlag:=TRUE;
   Exit;
  end;
 // �o�b�t�@�f�[�^������Ȃ��H
 x:=FBufLength;
 if x<4 then
  begin
   if x>0 then Move(FBuf^,FReadBuf^,x);
   ReadBuf(x);
  end;
 result:=PDWORD(FBuf)^;
 Inc(FReadPos,4);
 Inc(FBuf,4);
 Dec(FBufLength,4);
end;


//***************************************************
//*   TGLDCustomGraphicWriteStream                  *
//***************************************************


//------- CallBackProc => �R�[���o�b�N�{��


function TGLDCustomGraphicWriteStream.CallBackProc(cnt: integer): boolean;
var
 n: integer;
 md: TProgressStage;
 flg: boolean;

begin
 result:=FALSE;
 if Assigned(FImage.OnProgress) then
  begin
   case cnt of
    0:     md:=psStarting;
    1..99: md:=psRunning;
   else
    begin
     md:=psEnding;
     cnt:=100;
    end;
   end;
   FImage.OnProgress(FImage,md,cnt,FALSE,Rect(0,0,0,0),FMes);
  end;
end;


//------- SaveToStream => �X�g���[���ɏ�������


procedure TGLDCustomGraphicWriteStream.SaveToStream(img: TGLDBmp; stream: TStream);
begin
 // �`�F�b�N
 SetWriteStream(stream);
 FImage:=img;
 // ��������
 WriteStream;
 // ����
 FlushStream;
end;


//***************************************************
//*   TGLDCustomWriteStream                         *
//***************************************************


//------- Create => �N���X�쐬


constructor TGLDCustomWriteStream.Create;
begin
 inherited Create;
 GetMem(FWriteBuf,MaxBufLength);
end;


//------- Destroy => �N���X���


destructor TGLDCustomWriteStream.Destroy;
begin
 if FWriteBuf<>nil then FreeMem(FWriteBuf);
 inherited Destroy;
end;


//------- SetWriteStream => �X�g���[���ɏ�������


procedure TGLDCustomWriteStream.SetWriteStream(stream: TStream);
begin
 // �`�F�b�N
 FStream:=stream;
 FBuf:=FWriteBuf;
 FWriteStreamSize:=0;
 FWriteLength:=0;
end;


//------- SetCallBackParam => �R�[���o�b�N���[�h�ݒ�


procedure TGLDCustomWriteStream.SetCallBackParam(ctype,msize,par: integer);
begin
 // �O�f�[�^�N���A
 Inc(FStartCount,FStdParcent);
 FOldCount:=FStartCount;
 Dec(FMaxParcent,FStdParcent);
 // �V�f�[�^�ݒ�
 FMaxSize:=msize;
 if FMaxSize=0 then FMaxSize:=1;
 FCallType:=1;  // Write�ł�0�͂Ȃ��I
 if (par=0) or (par>=100) then FStdParcent:=FMaxParcent
 else FStdParcent:=(FMaxParcent*par) div 100;
end;


//------- StartCallBack => �X�^�[�g�R�[���o�b�N


procedure TGLDCustomWriteStream.StartCallBack;
var
 rec: TRECT;

begin
 FStartCount:=0;
 FOldCount:=0;
 FStdParcent:=0;
 FMaxParcent:=99;
 FCancelFlag:=FALSE;

 FCancelFlag:=CallBackProc(0);
end;


//------- EndCallBack => �G���h�R�[���o�b�N


procedure TGLDCustomWriteStream.EndCallBack;
var
 rec: TRECT;

begin
 FCancelFlag:=CallBackProc(100);
end;


//------- DoCallback => �R�[���o�b�N


procedure TGLDCustomWriteStream.DoCallBack(cnt: integer);
var
 i,j,k: integer;
 rec: TRECT;

begin
 j:=FStdParcent;
 k:=FMaxSize;
 case FCallType of
  0: // �t�@�C���T�C�Y�J�E���g
     // ���̃^�C�v��Write�ł͎w��֎~
     begin
      //i:=((FStream.Position-FStartPosition)*j) div k;
     end;
  1: // �x���C��
     begin
      i:=(cnt*j) div k;
     end;
 end;
 Inc(i,FStartCount);
 if (i>FOldCount) then
  begin
   FOldCount:=i;
   FCancelFlag:=CallBackProc(i);
  end;
end;


//------- CallBackProc => �R�[���o�b�N�{��


function TGLDCustomWriteStream.CallBackProc(cnt: integer): boolean;
begin
 result:=FALSE;
end;


//------- FlushStream => �X�g���[���I������


procedure TGLDCustomWriteStream.FlushStream;
begin
 if FWriteLength>0 then WriteBuf;
end;


//------- WriteBuf => �o�b�t�@�����o��


procedure TGLDCustomWriteStream.WriteBuf;
begin
 if FWriteLength=0 then Exit;
 FStream.WriteBuffer(FWriteBuf^,FWriteLength);
 Inc(FWriteStreamSize,FWriteLength);
 FWriteLength:=0;
 FBuf:=FWriteBuf;
end;


//------- WriteByte => �o�C�g�P�ʏ�������


procedure TGLDCustomWriteStream.WriteByte(buf: pointer; cnt: integer);
begin
 if FCancelFlag then Exit;
 if cnt=0 then
  begin
   FCancelFlag:=TRUE;
   Exit;
  end;

 // �o�b�t�@���傫���f�[�^�̏ꍇ�͒��ɏ�����
 if (cnt>=(MaxBufLength-16)) then
  begin
   // ���o�b�t�@�ɂ���f�[�^��f���o��
   WriteBuf;
   // ��������
   FStream.WriteBuffer(buf^,cnt);
   Inc(FWriteStreamSize,cnt);
  end
 else
  begin
   // �o�b�t�@�̋󂫂�����Ȃ�
   if FWriteLength+cnt>=MaxBufLength then WriteBuf;
   // �o�b�t�@�ɂ����
   Move(buf^,FBuf^,cnt);
   Inc(FWriteLength,cnt);
   Inc(FBuf,cnt);
  end;
end;


//------- Wrute1Byte => 1�o�C�g��������


procedure TGLDCustomWriteStream.Write1Byte(i: integer);
begin
 if FCancelFlag then Exit;
 // �o�b�t�@�̋󂫂�����Ȃ�
 if FWriteLength+1>=MaxBufLength then WriteBuf;
 // �o�b�t�@�ɂ����
 FBuf^:=i;
 Inc(FWriteLength);
 Inc(FBuf);
end;


//-------- WriteWord => �Q�o�C�g��������


procedure TGLDCustomWriteStream.WriteWord(i: integer);
begin
 if FCancelFlag then Exit;
 // �o�b�t�@�̋󂫂�����Ȃ�
 if FWriteLength+2>=MaxBufLength then WriteBuf;
 // �o�b�t�@�ɂ����
 PWORD(FBuf)^:=i;
 Inc(FWriteLength,2);
 Inc(FBuf,2);
end;


//------- WriteMWord => �Q�o�C�g��������(���g���[���j


procedure TGLDCustomWriteStream.WriteMWord(i: integer);
begin
 if FCancelFlag then Exit;
 // �o�b�t�@�̋󂫂�����Ȃ�
 if FWriteLength+2>=MaxBufLength then WriteBuf;
 // �o�b�t�@�ɂ����
 PWORD(FBuf)^:=((i and $FF) shl 8) or ((i and $FF00) shr 8);
 Inc(FWriteLength,2);
 Inc(FBuf,2);
end;


//------- WriteDWord => �S�o�C�g��������


procedure TGLDCustomWriteStream.WriteDWord(i: integer);
begin
 if FCancelFlag then Exit;
 // �o�b�t�@�̋󂫂�����Ȃ�
 if FWriteLength+4>=MaxBufLength then WriteBuf;
 // �o�b�t�@�ɂ����
 PDWORD(FBuf)^:=i;
 Inc(FWriteLength,4);
 Inc(FBuf,4);
end;


//------- WriteMDWord => �S�o�C�g��������(���g���[���j


procedure TGLDCustomWriteStream.WriteMDWord(i: integer);
begin
 if FCancelFlag then Exit;
 // �o�b�t�@�̋󂫂�����Ȃ�
 if FWriteLength+4>=MaxBufLength then WriteBuf;
 // �o�b�t�@�ɂ����
 PDWORD(FBuf)^:=((i and $FF) shl 24) or ((i and $FF00) shl 8) or
                ((i and $FF0000) shr 8) or ((i and $FF000000) shr 24);
 Inc(FWriteLength,4);
 Inc(FBuf,4);
end;

end.
