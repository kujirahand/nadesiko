// AlphaBitmap2 for Delphi 6- ,C++Builder 6- 
// Copyright(C)'2000- buin2gou(buin2gou@jcom.home.ne.jp)
// Copyright(C)'2000- nakao-kun(knakao@mx2.tiki.ne.jp)
//
// ���̃R���|�[�l���g�͎��R�Ɏg�p���Ă�����č\���܂���
// �]�ځE���ς����R�ł��B�s�̃\�t�g�Ɏg�p���Ă����C�����e�B
// �̐����͐�΂ɂ��肦�܂���B�g�p�����K�v����܂���B
// TBitmap�Ƀ�������]���̊ȈՉ����{�������ړI�O���t�B�b�N
// ���C�u�����ł��B
// MMX���g�p���Ă���֐�������܂����A���ʃ��[�`���Ɣ�MMX��
// �S�������@�\�����֐���p�ӂ��Ă���̂ň��S�ł��B
//
//
// �ꕔ�̊֐��͒�������ɂ���ăC�����C���A�Z���u��������Ă��܂��B
// MMX���͕����󍆂��s���Ă��܂��B
//
// �Q�l�E����Ɉ��p�z�[���y�[�W
//
// http://www.ngy.1st.ne.jp/~kengo/
// http://www2s.biglobe.ne.jp/~aks-lab/
// http://hp.vector.co.jp/authors/VA012950/aa/
// http://homepage1.nifty.com/beny/
//
// Version 0.9
// MMX�œK���B
//
//
//
//


unit ABitmap;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls;


function MMXCheck:Boolean;
//bit����
function  getbit(i,cnt:byte):byte;
function  setbit(i,cnt,inbit:byte):byte;


type
  TABitmap = class(TBitmap)
  private
    { Private �錾 }

  protected
    { Protected �錾 }
  public
    { Public �錾 }





    //�����E�J��
    constructor Create; override;
    destructor  Destroy; override;

    //�I�[�o�[���C�h���ăt���J���[��
    procedure LoadFromFile(const FileName:String);override;
    procedure Assign(Source:TPersistent);override;

    //�_��`��(�X�L�������C����S�Ďg�p)
    procedure PutRGB(x,y:Integer;r,g,b:Byte);
    procedure PutColor(x,y:Integer;col:TColor);
    procedure GetRGB(x,y:Integer;var r,g,b:Byte);
    procedure GetColor(x,y:Integer;var col:TColor);


    //���u�����h�֘A
    //�m�[�}������
    procedure ColorAlpha(x,y,w,h:Integer;BMP:TBitmap;iA:WORD);
    procedure ColorAlphaMMX(x,y,w,h:Integer;BMP:TBitmap;iA:WORD);
    //�J���[�L�[����
    procedure ColorKey(x,y,w,h:Integer;BMP:TBitmap;Col:TColor);
    procedure ColorKeyAlpha(x,y,w,h:Integer;BMP:TBitmap;Col:TColor;iA:BYTE);
    //�������Z���n��
    procedure RectAngleAlpha(x,y,w,h:Integer;Col:TColor;iA:BYTE);
    procedure RectAngleAlphaMMX(x,y,w,h:Integer;Col:TColor;iA:BYTE);
    //����
    procedure ColorAlphaPic(x,y,w,h:Integer;BMP:TBitmap);
    procedure ColorAlphaPicMMX(x,y,w,h:Integer;BMP:TBitmap);
    procedure ColorAlphaPicAlpha(x,y,w,h:Integer;BMP:TBitmap;iA:Word);
    procedure ColorAlphaPicAlphaMMX(x,y,w,h:Integer;BMP:TBitmap;iA:Word);
    //�L�����Ȃǃ}�X�N����������
    procedure ColorAlphaPicCh(x,y,w,h:Integer;BMP:TBitmap);
    procedure ColorAlphaPicChMMX(x,y,w,h:Integer;BMP:TBitmap);
    procedure ColorAlphaPicAlphaCh(x,y,w,h:Integer;BMP:TBitmap;iA:Word);
    procedure ColorAlphaPicAlphaChMMX(x,y,w,h:Integer;BMP:TBitmap;iA:Word);
    //�����J���[�L�[�E�p�^�[������
    procedure ColorKeyMask(x,y,w,h,ax,ay:Integer;MaskBMP,BMP:TBitmap);

    //�Ƃ�񂶂����
    procedure ColorAlphaPicTrans(x,y,w,h:Integer;alphaBMP,BMP:TBitmap;iA:Word);
    procedure ColorAlphaPicTransMMX(x,y,w,h:Integer;alphaBMP,BMP:TBitmap;iA:Word);

    //�T�C�Y�ύX
    procedure SetSize(W,H:Integer);






  published
    { Published �錾 }
  end;

  

  procedure Bright32(BMP:TBitmap;iPower:SmallInt);
  function RoundByte(data:Integer):Byte;



implementation

Function RoundByte(data:Integer):Byte;
begin
  if Data>255 then Data:=255
  else if Data< 0 then Data:=0;
  Result:=Data;
end;


procedure Bright32(BMP:TBitmap;iPower:SmallInt);
var
  x,y  :SmallInt;  //�r�b�g�}�b�v�̂w���A�x��
  PBit :PByteArray;
  w    :Integer;


begin


  BMP.PixelFormat := pf32Bit;

  w:=(BMP.Width*4-1);

  //���邳����
  for y:=0 to BMP.Height-1 do begin
     pBit:=BMP.ScanLine[y];

     for x:=0 to w do begin
         pBit[x]:=RoundByte(pBit[x]+iPower);
     end;
  end;
end;


constructor TABitmap.Create;
begin
  Inherited Create;

  PixelFormat:=pf32Bit;

end;

destructor TABitmap.Destroy;
begin

  Inherited Destroy;
end;

procedure TABitmap.SetSize(W,H:Integer);
begin
  //�T�C�Y�̐ݒ�i�����Ƀ������擾�ł��j
  self.Width :=W;
  self.Height:=H;
end;

procedure TABitmap.LoadFromFile(const FileName:String);
begin
  Inherited LoadFromFile(FileName);

  PixelFormat:=pf32Bit;

end;

procedure TAbitmap.Assign(Source:TPersistent);
begin
  Inherited Assign(Source);

  PixelFormat:=pf32Bit;

end;





//�h�b�g�ł�

procedure TABitmap.PutRGB(x,y:Integer;r,g,b:Byte);
var i   :Integer;
    pBit:PByteArray;
begin
    PixelFormat:=pf32Bit;

    //�X�L�������C���擾
    pBit:=ScanLine[y];

    i:=x*4;
    pBit[i]  :=r;
    pBit[i+1]:=g;
    pBit[i+2]:=b;
end;

procedure TABitmap.PutColor(x,y:Integer;col:TColor);
var r,g,b:Byte;
begin

    r:=GetRValue(col);
    g:=GetGValue(col);
    b:=GetBValue(col);

    PutRGB(x,y,r,g,b);
end;

procedure TABitmap.GetRGB(x,y:Integer;var r,g,b:Byte);
var i   :Integer;
    pBit:PByteArray;
begin

    PixelFormat:=pf32Bit;

    //�X�L�������C���擾
    pBit:=ScanLine[y];

    i:=x*4;
    r:=pBit[i];
    g:=pBit[i+1];
    b:=pBit[i+2];

end;

procedure TABitmap.GetColor(x,y:Integer;var col:TColor);
var r,g,b:Byte;
begin

  GetRGB(x,y,r,g,b);
  col:=RGB(r,g,b);

end;



procedure TABitmap.ColorKey(x,y,w,h:Integer;BMP:TBitmap;Col:TColor);
var
  e         : Integer;
  pBit,pBit2: PByteArray;
  s, t      : Integer;
  pxlRGB    : LongInt;
  XCountMax : Integer;
  StartX    : Integer;
begin

   BMP.PixelFormat:=pf32Bit;
   Self.PixelFormat:=pf32Bit;

   //

   //���ߐF
   pxlRGB:=ColorToRGB(Col);
   //pxlRGB:=Col;
   //�T�C�Y�̒���
   s:=y+h;
   t:=x+w;
   If s>BMP.Height then s:=BMP.Height;
   If t>BMP.Width  then t:=BMP.Width;

   StartX:= x*4;
   XCountMax:= t-x;

   if XCountMax<=0 then Exit;


   for e:=y to s-1 do begin
     pBit:= ScanLine[e-y];
     pBit2:= BMP.ScanLine[e];
     pBit2:= @(pBit2[StartX]);
     asm
       push esi; push edi; push ebx; // ���W�X�^�ޔ�
       mov esi,pBit;
       mov edi,pBit2;
       mov ebx,pxlRGB;
       and ebx,$00FFFFFF;
       mov ecx,XCountMax;
      @loop_horz:
         mov eax,[esi];
         and eax,$00FFFFFF;
         cmp eax,ebx;
         jne @put_pixel;
           add edi,4;
           jmp @put_pixel_end;

            @put_pixel:
               mov [edi],eax;
               add edi,4;
         @put_pixel_end:
         add esi,4;
         dec ecx;
         jnz @loop_horz;

       pop ebx; pop edi; pop esi;    // ���W�X�^����
     end;
   end;

end;

procedure TABitmap.ColorAlpha(x,y,w,h:Integer;BMP:TBitmap;iA:WORD);
var
  e         :Integer;
  pBit,pBit2:PByteArray;
  s,t       :Integer;
  StartX, XCountMax: Integer;
  Alpha, Rev_Alpha: Byte;
begin

   BMP.PixelFormat:=pf32Bit;
   Self.PixelFormat:=pf32Bit;


   if iA=0 then Exit;
   if iA>255 then iA:= 255;
   Alpha:= iA;
   Rev_Alpha:= 256-iA;

   //�T�C�Y�̒���
   s:=y+h;
   t:=x+w;
   If s>BMP.Height then s:=BMP.Height;
   If t>BMP.Width  then t:=BMP.Width;

   StartX:= x*4;
   XCountMax:= t*4 - StartX;

   if XCountMax<=0 then Exit;

   e:= y;
   while e<s do begin
     pBit :=ScanLine[e-y];
     pBit2:=BMP.ScanLine[e];
     pBit2:= @(pBit2[StartX]);
     asm
       push esi; push edi; push ebx; // ���W�X�^�ޔ�
       mov esi,pBit;
       mov edi,pBit2;
       mov bl,Alpha;
       mov bh,Rev_Alpha;
       mov ecx,XCountMax;
      @loop_horz:
         mov al,[esi];
         inc esi;
         mul bl;
         mov dx,ax;
         mov al,[edi];
         mul bh;
         add ax,dx;
         mov [edi],ah;
         inc edi;
         loop @loop_horz;
       pop ebx; pop edi; pop esi;    // ���W�X�^����
     end;
     inc(e);
   end;
end;


procedure TABitmap.ColorAlphaMMX(x,y,w,h:Integer;BMP:TBitmap;iA:WORD);
var dwAlpha,dwAlpha2,dwLength:DWORD;
    dwAlpha64,dwAlpha264:array[0..1] of DWORD;

    s,t,e            :Integer;
    StartX:Integer;
    lpSrc1,lpSrc2:PByteArray;

begin
   If x>=BMP.Width then exit;

   Self.PixelFormat  :=pf32Bit;
   BMP.PixelFormat :=pf32Bit;

   //�T�C�Y�̒���
   s:=y+h;
   t:=x+w;
   If s>BMP.Height then s:=BMP.Height;
   If t>BMP.Width  then t:=BMP.Width;

   StartX:=x*4;
   dwLength:=(t-x);

   dwAlpha:=iA;
   dwAlpha2:=256-iA;

   //�O�ɏo���Ă����č������B
   asm
     movd mm4,dwAlpha;
     punpcklwd mm4,mm4;
     punpckldq mm4,mm4; // mm4 =  0��0��0��0��
     movq dwAlpha64,mm4;

     movd mm5,dwAlpha2;
     punpcklwd mm5,mm5;
     punpckldq mm5,mm5; // mm5 = 0(1-��)0(1-��)0(1-��)0(1-��)
     movq dwAlpha264,mm5;

     emms;
   end;



  for e:=y to s-1 do begin

      lpSrc1:=Self.ScanLine[e-y];
      lpSrc2:=BMP.ScanLine[e];

      asm
        push eax;push ecx;push edx; // ���W�X�^�ޔ�
        mov eax,dwLength;  // eax = �J�E���^
        mov ecx,lpSrc1;  // ecx = �R�s�[��1�@�A�h���X
        mov edx,lpSrc2;  // edx = �R�s�[���E��@�A�h���X

        //�i�߂Ă���
        add edx,Startx;

        movq mm4,dwAlpha64;
        movq mm5,dwAlpha264;
        pxor mm6,mm6; // mm6 = �p�b�N�p�_�~�[ = 0
        pxor mm7,mm7; // mm7 = �p�b�N�p�_�~�[ = 0

      @LOOP1:
        // �f�[�^�ǂݍ���(32 bit)
	movd mm0,[ecx];
	movd mm1,[edx];

	// byte -> word �ɃA���p�b�N
	punpcklbw mm0,mm6;
	punpcklbw mm1,mm7;

	// �p�b�N�|���Z
	pmullw mm0,mm4;
	pmullw mm1,mm5;

	//  word �P�ʂő�����256�Ŋ���
	paddw mm0,mm1;
	psrlw mm0,8;

	// word->byte �Ƀp�b�N���ē]��
	packuswb mm0,mm6;
	movd [edx],mm0;

	// �J�E���^�A�b�v
	add ecx,4;
	add edx,4;

	dec eax;
	jne @LOOP1;
	emms;
        pop edx;pop ecx;pop eax;    // ���W�X�^����
      end;
  end;

end;



procedure TABitmap.ColorKeyAlpha(x,y,w,h:Integer;BMP:TBitmap;Col:TColor;iA:BYTE);
var e,f,i,j,k :Integer;
    pBit,pBit2:PByteArray;
    r,g,b     :BYTE;
    r2,g2,b2  :BYTE;
    pxlRGB    :LongInt;
    iA2       :Integer;
    w2,h2     :Integer;
begin

   BMP.PixelFormat:=pf32bit;
   PixelFormat:=pf32bit;

   iA2:=256-iA;

   //���ߐF
   pxlRGB:=ColorToRGB(Col);
   R:=GetRValue(pxlRGB);
   G:=GetGValue(pxlRGB);
   B:=GetBValue(pxlRGB);

   //�T�C�Y���K��
   If y+h>BMP.Height then h2:=BMP.Height-1
   else h2:=y+h-1;

   If x+w>BMP.Width then w2:=BMP.Width-1
   else w2:=x+w-1;

   k:=x*4;

   //�����J�n
   for e:=y to h2 do begin
       pBit :=ScanLine[e-y];
       pBit2:=BMP.ScanLine[e];
       i:=0;
       j:=k;

       for f:=x to w2 do begin
           r2:=pBit[i];
           inc(i);
           g2:=pBit[i];
           inc(i);
           b2:=pBit[i];
           inc(i,2);

           //���ߐF�ݒ�

           If not ((r2=r) and (b2=b) and (g2=g)) then begin

              pBit2[j]:=(r2*iA+pBit2[j]*iA2) shr 8;
              inc(j);
              pBit2[j]:=(g2*iA+pBit2[j]*iA2) shr 8;
              inc(j);
              pBit2[j]:=(b2*iA+pBit2[j]*iA2) shr 8;
              inc(j,2);
           end else begin
              inc(j,4);
           end;;
       end;
   end;
end;


procedure TABitmap.ColorAlphaPic(x,y,w,h:Integer;BMP:TBitmap);
var e,f,i,j,k,ew,w2,h2      :Integer;
    pBit,pBit2:PByteArray;
    r,g  :Integer;
begin
   If x>=BMP.Width then exit;

   BMP.PixelFormat  :=pf32bit;
   PixelFormat:=pf32bit;

   If y+h>BMP.Height then h2:=BMP.Height-1
   else h2:=y+h-1;

   If x+w>BMP.Width then w2:=BMP.Width-1
   else w2:=x+w-1;


   k:=x*4;
   ew:=(w2-x-1);

    for e:=y to h2 do begin
        pBit :=ScanLine[e-y];
        pBit2:=BMP.ScanLine[e];
        i:=0;
        j:=k;

       for f:=0 to ew do begin

           r:=pBit[i+3];
           g:=256-r;

           pBit2[j]:=Byte((pBit[i]*g+pBit2[j]*r) shr 8);
           inc(i);
           inc(j);
           pBit2[j]:=Byte((pBit[i]*g+pBit2[j]*r) shr 8);
           inc(i);
           inc(j);
           pBit2[j]:=Byte((pBit[i]*g+pBit2[j]*r) shr 8);
           inc(i,2);
           inc(j,2);
       end;


   end;
end;

procedure TABitmap.ColorAlphaPicMMX(x,y,w,h:Integer;BMP:TBitmap);
var e,k,ew,w2,h2      :Integer;
    pBit,pBit2:PByteArray;
begin
   If x>=BMP.Width then exit;

   BMP.PixelFormat  :=pf32bit;
   PixelFormat:=pf32bit;

   If y+h>BMP.Height then h2:=BMP.Height-1
   else h2:=y+h-1;

   If x+w>BMP.Width then w2:=BMP.Width
   else w2:=x+w-1;


   k:=x*4;
   ew:=(w2-x-1);

    for e:=y to h2 do begin
        pBit :=ScanLine[e-y];
        pBit2:=BMP.ScanLine[e];

      asm
        push eax;push ebx;push ecx;push edx;push edi;push esi; // ���W�X�^�ޔ�
        mov eax,ew;  // eax = �J�E���^
        mov ebx,pBit;
        mov ecx,pBit2;//�o�͐�

        //�i�߂Ă���
        add ecx,k;

        pxor mm6,mm6; // mm6 = �p�b�N�p�_�~�[ = 0
        pxor mm7,mm7; // mm7 = �p�b�N�p�_�~�[ = 0

      @LOOP1:
        // �f�[�^�ǂݍ���(32 bit)
	movd mm0,[ebx];
	movd mm1,[ecx];

        //���`�����l���ǂݍ���

        movd esi,mm0;
        and  esi,$FF000000;
        shr  esi,24;

        mov edx,esi;
        not dl;

        movd mm4,esi;
        punpcklwd mm4,mm4;
        punpckldq mm4,mm4; // mm4 = 0��0��0��0��
        movd mm5,edx;
        punpcklwd mm5,mm5;
        punpckldq mm5,mm5; // mm5 = 0(1-��)0(1-��)0(1-��)0(1-��)

	// byte -> word �ɃA���p�b�N
	punpcklbw mm0,mm6;
	punpcklbw mm1,mm7;

	// �p�b�N�|���Z
	pmullw mm0,mm5;
	pmullw mm1,mm4;

	//  word �P�ʂő�����256�Ŋ���
	paddw mm0,mm1;
	psrlw mm0,8;

	// word->byte �Ƀp�b�N���ē]��
	packuswb mm0,mm6;
	movd [ecx],mm0;

	// �J�E���^�A�b�v
        add ebx,4;
	add ecx,4;
	inc edi;

	dec eax;
	jne @LOOP1;
	emms;
        pop esi;pop edi;pop edx;pop ecx;pop ebx;pop eax;    // ���W�X�^����
      end;

   end;
end;



procedure TABitmap.ColorAlphaPicAlpha(x,y,w,h:Integer;BMP:TBitmap;iA:Word);
var e,f,i,j,k,ew,w2,h2      :Integer;
    pBit,pBit2:PByteArray;
    r,b :WORD;
begin
   If x>=BMP.Width then exit;

   BMP.PixelFormat  :=pf32bit;
   PixelFormat:=pf32bit;

   inc(iA);

   If y+h>BMP.Height then h2:=BMP.Height-1
   else h2:=y+h-1;

   If x+w>BMP.Width then w2:=BMP.Width-1
   else w2:=x+w-1;


   k:=x*4;
   ew:=(w2-x-1);


    for e:=y to h2 do begin
        pBit :=ScanLine[e-y];
        pBit2:=BMP.ScanLine[e];
        i:=0;
        j:=k;

       for f:=0 to ew do begin

           r:=(256-pBit[i+3])*iA shr 8;
           b:=256-r;

           pBit2[j] :=(pBit[i]*r+pBit2[j]*b) shr 8;
           inc(i);
           inc(j);
           pBit2[j] :=(pBit[i]*r+pBit2[j]*b) shr 8;
           inc(i);
           inc(j);
           pBit2[j] :=(pBit[i]*r+pBit2[j]*b) shr 8;
           inc(i,2);
           inc(j,2);



       end;
   end;
end;

procedure TABitmap.ColorAlphaPicAlphaMMX(x,y,w,h:Integer;BMP:TBitmap;iA:Word);
var e,k,ew,w2,h2      :Integer;
    pBit,pBit2:PByteArray;
    iA2:DWORD;
begin
   If x>=BMP.Width then exit;

   BMP.PixelFormat  :=pf32bit;
   PixelFormat:=pf32bit;

   If y+h>BMP.Height then h2:=BMP.Height-1
   else h2:=y+h-1;

   If x+w>BMP.Width then w2:=BMP.Width
   else w2:=x+w-1;

   iA2:=iA+1;


   k:=x*4;
   ew:=(w2-x-1);

    for e:=y to h2 do begin
        pBit :=ScanLine[e-y];
        pBit2:=BMP.ScanLine[e];

      asm
        push eax;push ebx;push ecx;push edx;push edi;push esi; // ���W�X�^�ޔ�
        mov ecx,ew;  // ecx = �J�E���^
        mov ebx,pBit; //�L�����N�^�摜
        mov esi,pBit2;//�o�͐�

        //�i�߂Ă���
        add esi,k;

        pxor mm6,mm6; // mm6 = �p�b�N�p�_�~�[ = 0
        pxor mm7,mm7; // mm7 = �p�b�N�p�_�~�[ = 0

      @LOOP1:

        // �f�[�^�ǂݍ���(32 bit)
	movd mm0,[ebx];
	movd mm1,[esi];

        //���`�����l���ǂݍ���
        //movzx edx,byte [edi];
        movd edx,mm0;
        and  edx,$FF000000;
        shr  edx,24;
        mov eax,edx;
        not al;

        //���`�����l�����v�Z����B
        mul iA2;
        shr eax,8;
        //mov edx,256;
        //sub edx,eax;
        mov edx,eax;
        not dl;


        //�����l�l�w�p�ɕύX����
        movd mm4,edx;
        punpcklwd mm4,mm4;
        punpckldq mm4,mm4; // mm4 = 0��0��0��0��
        movd mm5,eax;
        punpcklwd mm5,mm5;
        punpckldq mm5,mm5; // mm5 = 0(1-��)0(1-��)0(1-��)0(1-��)


	// byte -> word �ɃA���p�b�N
	punpcklbw mm0,mm6;
	punpcklbw mm1,mm7;

	// �p�b�N�|���Z
	pmullw mm0,mm5;
	pmullw mm1,mm4;

	//  word �P�ʂő�����256�Ŋ���
	paddw mm0,mm1;
	psrlw mm0,8;

	// word->byte �Ƀp�b�N���ē]��
	packuswb mm0,mm6;
	movd [esi],mm0;

	// �J�E���^�A�b�v
        add ebx,4;
	add esi,4;
	add edi,1;

	loop @LOOP1;
	emms;
        pop esi;pop edi;pop edx;pop ecx;pop ebx;pop eax;    // ���W�X�^����
      end;

   end;
end;



//�}�X�N�摜�ɍœK�������o�[�W�����ʏ��
procedure TABitmap.ColorAlphaPicCh(x,y,w,h:Integer;BMP:TBitmap);
var e,f,i,j,k,ew,w2,h2      :Integer;
    pBit,pBit2:PByteArray;
    r,g  :Integer;
begin
   If x>=BMP.Width then exit;

   BMP.PixelFormat  :=pf32bit;
   PixelFormat:=pf32bit;

   If y+h>BMP.Height then h2:=BMP.Height-1
   else h2:=y+h-1;

   If x+w>BMP.Width then w2:=BMP.Width-1
   else w2:=x+w-1;


   k:=x*4;
   ew:=(w2-x-1);


    for e:=y to h2 do begin
        pBit :=ScanLine[e-y];
        pBit2:=BMP.ScanLine[e];
        i:=0;
        j:=k;

       for f:=0 to ew do begin

           r:=pBit[i+3]+1;
           If r=256 then begin
              inc(i,4);
              inc(j,4);
           end else if r=1 then begin

              pBit2[j] :=pBit[i];
              inc(i);
              inc(j);
              pBit2[j] :=pBit[i];
              inc(i);
              inc(j);
              pBit2[j] :=pBit[i];
              inc(i,2);
              inc(j,2);
           end else begin
              g:=256-r;

              pBit2[j] :=(pBit[i]*g+pBit2[j]*r) shr 8;
              inc(i);
              inc(j);
              pBit2[j] :=(pBit[i]*g+pBit2[j]*r) shr 8;
              inc(i);
              inc(j);
              pBit2[j] :=(pBit[i]*g+pBit2[j]*r) shr 8;
              inc(i,2);
              inc(j,2);
           end;
       end;


   end;
end;

//�}�X�N�摜�ɍœK�������o�[�W����MMX��
procedure TABitmap.ColorAlphaPicChMMX(x,y,w,h:Integer;BMP:TBitmap);
var e,k,ew,w2,h2      :Integer;
    pBit,pBit2:PByteArray;
begin
   If x>=BMP.Width then exit;

   BMP.PixelFormat  :=pf32bit;
   PixelFormat:=pf32bit;


   If y+h>BMP.Height then h2:=BMP.Height-1
   else h2:=y+h-1;

   If x+w>BMP.Width then w2:=BMP.Width
   else w2:=x+w-1;




   k:=x*4;
   ew:=(w2-x-1);

    for e:=y to h2 do begin
        pBit :=ScanLine[e-y];
        pBit2:=BMP.ScanLine[e];

      asm
        push eax;push ebx;push ecx;push edx;push edi;push esi; // ���W�X�^�ޔ�
        mov eax,ew;  // eax = �J�E���^
        mov ebx,pBit;
        mov ecx,pBit2;//�o�͐�

        //�i�߂Ă���
        add ecx,k;

        pxor mm6,mm6; // mm6 = �p�b�N�p�_�~�[ = 0
        pxor mm7,mm7; // mm7 = �p�b�N�p�_�~�[ = 0

      @LOOP1:

        // �f�[�^�ǂݍ���(32 bit)
	movd mm0,[ebx];
	movd mm1,[ecx];

        //���`�����l���ǂݍ���
        movd esi,mm0;
        and  esi,$FF000000;
        shr  esi,24;

        //�`�F�b�N
        cmp esi,255;
        jz @JPOINT;  // if edx=255 then goto @JPOINT
        cmp esi,0;
        jz @ZPOINT;  // if edx=0 then goto @ZPOINT

        //mov esi,256;
        //sub esi,edx;
        mov edx,esi;
        not dl;

        movd mm4,esi;
        punpcklwd mm4,mm4;
        punpckldq mm4,mm4; // mm4 = 0��0��0��0��
        movd mm5,edx;
        punpcklwd mm5,mm5;
        punpckldq mm5,mm5; // mm5 = 0(1-��)0(1-��)0(1-��)0(1-��)


	// byte -> word �ɃA���p�b�N
	punpcklbw mm0,mm6;
	punpcklbw mm1,mm7;

	// �p�b�N�|���Z
	pmullw mm0,mm5;
	pmullw mm1,mm4;

	//  word �P�ʂő�����256�Ŋ���
	paddw mm0,mm1;
	psrlw mm0,8;
	// word->byte �Ƀp�b�N���ē]��
	packuswb mm0,mm6;

        jmp @WPOINT;

        //���̂܂ܒ��ɏ������ށB
      @ZPOINT:
        movd mm0,[ebx];

        //�]����֏�������
      @WPOINT:
	movd [ecx],mm0;

      @JPOINT:// �J�E���^�A�b�v
        add ebx,4;
	add ecx,4;
	add edi,1;

	dec eax;
	jne @LOOP1;// if eax<>0 then goto @LOOP1
	emms;
        pop esi;pop edi;pop edx;pop ecx;pop ebx;pop eax;    // ���W�X�^����
      end;

   end;
end;



procedure TABitmap.ColorAlphaPicAlphaCh(x,y,w,h:Integer;BMP:TBitmap;iA:Word);
var e,f,i,j,k,ew,ew2,w2,h2:Integer;
    pBit,pBit2:PByteArray;
    r,b :WORD;
begin

   If x>=BMP.Width then exit;

   BMP.PixelFormat  :=pf32bit;
   PixelFormat:=pf32bit;

   inc(iA);

   If y+h>BMP.Height then h2:=BMP.Height-1
   else h2:=y+h-1;

   If x+w>BMP.Width then w2:=BMP.Width-1
   else w2:=x+w-1;


   k:=x*4;
   ew:=(w2-x-1);
   ew2:=ew*4;

    for e:=y to h2 do begin
        pBit :=ScanLine[e-y];
        pBit2:=BMP.ScanLine[e];
        i:=0+ew2;
        j:=k+ew2;

       for f:=0 to ew do begin

           r:=(256-pBit[i+3])*iA shr 8;
           b:=256-r;

           If r=256 then begin
              inc(i,4);
              inc(j,4);
           end else begin

              pBit2[j] :=(pBit[i]*r+pBit2[j]*b) shr 8;
              inc(i);
              inc(j);
              pBit2[j] :=(pBit[i]*r+pBit2[j]*b) shr 8;
              inc(i);
              inc(j);
              pBit2[j] :=(pBit[i]*r+pBit2[j]*b) shr 8;
              inc(i,2);
              inc(j,2);
           end;
       end;
   end;
end;

procedure TABitmap.ColorAlphaPicAlphaChMMX(x,y,w,h:Integer;BMP:TBitmap;iA:Word);
var e,k,ew,w2,h2      :Integer;
    pBit,pBit2:PByteArray;
    iA2:DWORD;
begin
   If x>=BMP.Width then exit;

   BMP.PixelFormat  :=pf32bit;
   PixelFormat:=pf32bit;

   If y+h>BMP.Height then h2:=BMP.Height-1
   else h2:=y+h-1;

   If x+w>BMP.Width then w2:=BMP.Width
   else w2:=x+w-1;

   iA2:=iA+1;


   k:=x*4;
   ew:=(w2-x-1);

    for e:=y to h2 do begin
        pBit :=ScanLine[e-y];
        pBit2:=BMP.ScanLine[e];

      asm
        push eax;push ebx;push ecx;push edx;push edi;push esi; // ���W�X�^�ޔ�
        mov ecx,ew;  // ecx = �J�E���^
        mov ebx,pBit; //�L�����N�^�摜
        mov esi,pBit2;//�o�͐�

        //�i�߂Ă���
        add esi,k;

        pxor mm6,mm6; // mm6 = �p�b�N�p�_�~�[ = 0
        pxor mm7,mm7; // mm7 = �p�b�N�p�_�~�[ = 0

      @LOOP1:

        // �f�[�^�ǂݍ���(32 bit)
	movd mm0,[ebx];
	movd mm1,[esi];

        //���`�����l���ǂݍ���
        movd edx,mm0;
        and  edx,$FF000000;
        shr  edx,24;

        //�`�F�b�N
        cmp edx,255;
        jz @JPOINT; // if edx=255 then goto @JPOINT

        //���̌v�Z
        mov eax,edx;
        not al;//256-iA

        //���`�����l�����v�Z����B
        mul iA2;//iA*iA2
        shr eax,8;//iA div 256
        mov edx,eax;
        not dl;//256-iA

        //�����l�l�w�p�ɕύX����
        movd mm4,edx;
        punpcklwd mm4,mm4;
        punpckldq mm4,mm4; // mm4 = 0��0��0��0��
        movd mm5,eax;
        punpcklwd mm5,mm5;
        punpckldq mm5,mm5; // mm5 = 0(1-��)0(1-��)0(1-��)0(1-��)


	// byte -> word �ɃA���p�b�N
	punpcklbw mm0,mm6;
	punpcklbw mm1,mm7;

	// �p�b�N�|���Z
	pmullw mm0,mm5;
	pmullw mm1,mm4;

	//  word �P�ʂő�����256�Ŋ���
	paddw mm0,mm1;
	psrlw mm0,8;

	// word->byte �Ƀp�b�N���ē]��
	packuswb mm0,mm6;
	movd [esi],mm0;


     @JPOINT:
	// �J�E���^�A�b�v
        add ebx,4;
	add esi,4;
	inc edi;

	loop @LOOP1;   // dec ecx & if ecx<>0 then goto @LOOP1
	emms;
        pop esi;pop edi;pop edx;pop ecx;pop ebx;pop eax;    // ���W�X�^����
      end;

   end;
end;



procedure TABitmap.ColorAlphaPicTrans(x,y,w,h:Integer;alphaBMP,BMP:TBitmap;iA:Word);
var e,f,i,j,k,ew,w2,h2,ba:Integer;
    pBit,pBit2,pBit3:PByteArray;
    r,g  :Integer;
begin
   If x>=BMP.Width then exit;

   BMP.PixelFormat  :=pf32bit;
   AlphaBMP.PixelFormat:=pf8bit;
   PixelFormat:=pf32bit;

   If y+h>BMP.Height then h2:=BMP.Height-1
   else h2:=y+h-1;

   If x+w>BMP.Width then w2:=BMP.Width-1
   else w2:=x+w-1;

   ba:=257-(iA*2);


   k:=x*4;
   ew:=(w2-x);

    for e:=y to h2 do begin
        pBit :=ScanLine[e-y];
        pBit2:=BMP.ScanLine[e];
        pBit3:=AlphaBMP.ScanLine[e-y];
        i:=0;
        j:=k;

       for f:=0 to ew do begin

           r:=RoundByte(pBit3[f]+ba);
           g:=256-r;

           pBit2[j] :=(pBit[i]*g+pBit2[j]*r) shr 8;
           inc(i);
           inc(j);
           pBit2[j] :=(pBit[i]*g+pBit2[j]*r) shr 8;
           inc(i);
           inc(j);
           pBit2[j] :=(pBit[i]*g+pBit2[j]*r) shr 8;
           inc(i,2);
           inc(j,2);
       end;


   end;

end;

procedure TABitmap.ColorAlphaPicTransMMX(x,y,w,h:Integer;alphaBMP,BMP:TBitmap;iA:Word);
var e,k,ew,w2,h2,ba:Integer;
    pBit,pBit2,pBit3:PByteArray;
begin
   If x>=BMP.Width then exit;

   BMP.PixelFormat  :=pf32bit;
   AlphaBMP.PixelFormat:=pf8bit;
   PixelFormat:=pf32bit;

   If y+h>BMP.Height then h2:=BMP.Height-1
   else h2:=y+h-1;

   If x+w>BMP.Width then w2:=BMP.Width
   else w2:=x+w-1;

   ba:=(128-iA) shl 1;

   k:=x*4;
   ew:=(w2-x+1);

   If ba>=0 then begin
    for e:=y to h2 do begin
        pBit :=ScanLine[e-y];
        pBit2:=BMP.ScanLine[e];
        pBit3:=AlphaBMP.ScanLine[e-y];

      asm
        push eax;push ebx;push ecx;push edx;push edi;push esi; // ���W�X�^�ޔ�
        mov eax,ew;  // eax = �J�E���^
        mov ebx,pBit;
        mov ecx,pBit2;//�o�͐�
        mov edi,pBit3;//���`�����l��

        //�i�߂Ă���
        add ecx,k;

        pxor mm6,mm6; // mm6 = �p�b�N�p�_�~�[ = 0
        pxor mm7,mm7; // mm7 = �p�b�N�p�_�~�[ = 0

      @LOOP1:
        // �f�[�^�ǂݍ���(32 bit)
	movd mm0,[ebx];
	movd mm1,[ecx];

        //���`�����l���ǂݍ���
        movzx edx,byte[edi];
        add edx,ba;

        //�����ɁARoundByte�̏�����u���̂����E�E�E�B
        cmp edx,256; //ba+Alpha�̃`�F�b�N
        jb @CONTINUE;
        //���ӂ�Ă���̂łQ�T�T�ɌŒ�B
        mov edx,255;

        //����
        @CONTINUE:
        //mov esi,256;
        //sub esi,edx;
        mov esi,edx;
        not dl;

        movd mm4,esi;
        punpcklwd mm4,mm4;
        punpckldq mm4,mm4; // mm4 = 0��0��0��0��
        movd mm5,edx;
        punpcklwd mm5,mm5;
        punpckldq mm5,mm5; // mm5 = 0(1-��)0(1-��)0(1-��)0(1-��)

	// byte -> word �ɃA���p�b�N
	punpcklbw mm0,mm6;
	punpcklbw mm1,mm7;

	// �p�b�N�|���Z
	pmullw mm0,mm5;
	pmullw mm1,mm4;

	//  word �P�ʂő�����256�Ŋ���
	paddw mm0,mm1;
	psrlw mm0,8;

	// word->byte �Ƀp�b�N���ē]��
	packuswb mm0,mm6;
	movd [ecx],mm0;

	// �J�E���^�A�b�v
        add ebx,4;
	add ecx,4;
	inc edi;

	dec eax;
	jne @LOOP1;
	emms;
        pop esi;pop edi;pop edx;pop ecx;pop ebx;pop eax;    // ���W�X�^����
      end;
   end;
  end else begin
    //ba:=Abs(ba);

    for e:=y to h2 do begin
        pBit :=ScanLine[e-y];
        pBit2:=BMP.ScanLine[e];
        pBit3:=AlphaBMP.ScanLine[e-y];

      asm
        push eax;push ebx;push ecx;push edx;push edi;push esi; // ���W�X�^�ޔ�
        mov eax,ew;  // eax = �J�E���^
        mov ebx,pBit;
        mov ecx,pBit2;//�o�͐�
        mov edi,pBit3;//���`�����l��
        xor edx,edx;

        //�i�߂Ă���
        add ecx,k;

        pxor mm6,mm6; // mm6 = �p�b�N�p�_�~�[ = 0
        pxor mm7,mm7; // mm7 = �p�b�N�p�_�~�[ = 0

      @LOOP1:
        // �f�[�^�ǂݍ���(32 bit)
	movd mm0,[ebx];
	movd mm1,[ecx];

        //���`�����l���ǂݍ���
        movzx esi,byte[edi];

        //���]������B
        mov edx,esi;
        not dl;

        sub edx,ba;

        //�����ɁARoundByte�̏�����u���̂����E�E�E�B
        cmp edx,255; //ba+Alpha�̃`�F�b�N

        jb @CONTINUE;

        //���ӂ�Ă���̂łQ�T�T�ɌŒ�B
        mov edx,255;
        //����

        @CONTINUE:
        //mov esi,256;
        //sub esi,edx;

        mov esi,edx;
        not dl;

        movd mm4,edx;
        punpcklwd mm4,mm4;
        punpckldq mm4,mm4; // mm4 = 0��0��0��0��
        movd mm5,esi;
        punpcklwd mm5,mm5;
        punpckldq mm5,mm5; // mm5 = 0(1-��)0(1-��)0(1-��)0(1-��)

	// byte -> word �ɃA���p�b�N
	punpcklbw mm0,mm6;
	punpcklbw mm1,mm7;

	// �p�b�N�|���Z
	pmullw mm0,mm5;
	pmullw mm1,mm4;

	//  word �P�ʂő�����256�Ŋ���
	paddw mm0,mm1;
	psrlw mm0,8;

	// word->byte �Ƀp�b�N���ē]��
	packuswb mm0,mm6;
	movd [ecx],mm0;

	// �J�E���^�A�b�v
        add ebx,4;
	add ecx,4;
	inc edi;

	dec eax;
	jne @LOOP1;
	emms;
        pop esi;pop edi;pop edx;pop ecx;pop ebx;pop eax;    // ���W�X�^����
      end;
   end;   
  end;
end;


procedure TABitmap.ColorKeyMask(x,y,w,h,ax,ay:Integer;MaskBMP,BMP:TBitmap);
begin

  BitBlt(BMP.Canvas.Handle,x,y,w,h,MaskBMP.Canvas.Handle,ax,ay,SRCPAINT);
  BitBlt(BMP.Canvas.Handle,x,y,w,h,Canvas.Handle,ax,ay,SRCAND);

end;

procedure TABitmap.RectAngleAlpha(x,y,w,h:Integer;Col:TColor;iA:BYTE);
var e,f,i,k,w2,h2   :Integer;
    pBit2     :PByteArray;
    r2,g2,b2  :BYTE;
    iA2,iA3,r3,g3,b3   :WORD;
    procedure ColToRGB(Color:TColor;var R,G,B:BYTE);
    var pxlRGB:LongInt;
    begin
      pxlRGB:=ColorToRGB(Color);
      B:=GetRValue(pxlRGB);
      g:=GetGValue(pxlRGB);
      R:=GetBValue(pxlRGB);
    end;


begin

   Self.PixelFormat:=pf32Bit;


   //���ߐF
   R2:=0;
   G2:=0;
   B2:=0;

   ColToRGB(Col,R2,G2,B2);

   //�A���t�@�l
   ia3:=ia+1;
   iA2:=256-iA3;

   If y+h>Self.Width then h2:=Self.Height-1
   else h2:=y+h-1;

   If x+w>Self.Width then w2:=Self.Width-1
   else w2:=x+w-1;


   r3:=r2*iA3;
   g3:=g2*iA3;
   b3:=b2*iA3;



   k:=x*4;

   for e:=y to h2 do begin
       pBit2:=ScanLine[e];
       i:=k;
       for f:=x to w2 do begin
           pBit2[i]:=(r3+pBit2[i]*iA2) shr 8;
           inc(i);
           pBit2[i]:=(g3+pBit2[i]*iA2) shr 8;
           inc(i);
           pBit2[i]:=(b3+pBit2[i]*iA2) shr 8;
           inc(i,2);
       end;
   end;
end;

procedure TABitmap.RectAngleAlphaMMX(x,y,w,h:Integer;Col:TColor;iA:BYTE);
var e,k,w2,h2   :Integer;
    pBit2     :PByteArray;
    r2,g2,b2  :BYTE;
    iA2,iA3   :DWORD;
    bitrgb    :array[0..3] of Byte;
    procedure ColToRGB(Color:TColor;var R,G,B:BYTE);
    var pxlRGB:LongInt;
    begin
      pxlRGB:=ColorToRGB(Color);
      B:=GetRValue(pxlRGB);
      g:=GetGValue(pxlRGB);
      R:=GetBValue(pxlRGB);
    end;
begin

   Self.PixelFormat:=pf32Bit;


   //���ߐF
   R2:=0;
   G2:=0;
   B2:=0;

   ColToRGB(Col,R2,G2,B2);

   //�A���t�@�l
   ia3:=ia;
   iA2:=256-iA3;



   bitrgb[0]:=r2;
   bitrgb[1]:=g2;
   bitrgb[2]:=b2;

   If y+h>Self.Height then h2:=Self.Height-1
   else h2:=y+h-1;

   If x+w>Self.Width then w2:=Self.Width-1
   else w2:=x+w-1;


   k:=x*4;
   w:=w2-x+1;

   for e:=y to h2 do begin
       pBit2:=ScanLine[e];

       asm
          push ebx;push eax;

          //�J�E���^�[
          mov eax,w;

          //�|�C���^����
          mov ebx,pBit2;
          add ebx,k;

          //�l�l�w����
          movd mm4,iA2;
          punpcklwd mm4,mm4;
          punpckldq mm4,mm4; // mm4 =  0��0��0��0��
          movd mm5,iA3;
          punpcklwd mm5,mm5;
          punpckldq mm5,mm5; // mm4 =  0��0��0��0��
          pxor mm6,mm6; // mm6 = �p�b�N�p�_�~�[ = 0
          pxor mm7,mm7; // mm7 = �p�b�N�p�_�~�[ = 0

      @LOOP1:
          // �f�[�^�ǂݍ���(32 bit)
          movd mm0,[ebx];
	  movd mm1,[bitrgb];

	  // byte -> word �ɃA���p�b�N
	  punpcklbw mm0,mm6;
	  punpcklbw mm1,mm7;

	  // �p�b�N�|���Z
	  pmullw mm0,mm4;
	  pmullw mm1,mm5;

	  //  word �P�ʂő�����256�Ŋ���
	  paddw mm0,mm1;
	  psrlw mm0,8;

	  // word->byte �Ƀp�b�N���ē]��
	  packuswb mm0,mm6;
	  movd [ebx],mm0;

	  // �J�E���^�A�b�v
	  add ebx,4;
          //�J�E���^�[�����炷
	  dec eax;

          //�[������Ȃ�������W�����v
          jne @LOOP1;      // if eax<>0 then goto @LOOP1

          //MMX���ߏI��
          emms;

          //���W�X�^�𕜊�
          pop eax;pop ebx;
       end;
   end;
end;



function getbit(i,cnt:byte):byte;
begin
    i := i shl cnt;
    i := i shr 7;
    result := i;
end;

function setbit(i,cnt,inbit:byte):byte;
begin
    inbit:=inbit shl (7-cnt);
    i := i or inbit;
    result:=i;
end;

function MMXCheck:Boolean;
var dwMMX,dwinfo:DWORD;
begin

  asm
     push eax;push ebx;push ecx;push edx
     mov eax,0
     cpuid
     mov dwMMX,eax
     pop edx;pop ecx;pop ebx;pop eax;
  end;

  If dwMMX<1 then begin
     Result:=False;
     exit;
  end;

  asm
        push eax;push ebx;push ecx;push edx;
        mov     eax, 1
        cpuid
        mov     dwMMX, edx
        mov     dwInfo,eax
        pop edx;pop ecx;pop ebx;pop eax;
  end;


  Result:=((dwMMX and $800000) shr 23)=1;


end;




end.
