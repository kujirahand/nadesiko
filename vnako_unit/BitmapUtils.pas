{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
unit BitmapUtils;

interface

uses Windows, Classes, Graphics, BigBitmap;


////////////////////
//
// �r�b�g�}�b�v�̕ό`�p���[�`���Q
//


type
  // �ό`�����W�v�Z�֐��̌^
  TBitmapTransFormFunction = function(Pos: TPoint; p: Pointer): TPoint;

// �r�b�g�}�b�v��ό`����
function TransformBitmap(
  OrgBitmap: TBitmap;
  NewWidth, NewHeight: Integer;                // �V�����r�b�g�}�b�v�̑傫��
  TransFormFunction: TBitmapTransFormFunction; // �ό`�����W�v�Z�֐�
  DefaultColor: Longint;                       // �f�t�H���g�J���[
  p: Pointer                                   // �I�v�V���i���p�����[�^
  ): TBitmap; overload;

// �r�b�g�}�b�v�g��k������
function StretchBitmap(Bitmap: TBitmap;
                       NewWidth,           // �V�����r�b�g�}�b�v�̑傫��
                       NewHeight: Integer)
                       : TBitmap; overload;

// �r�b�g�}�b�v����]������
function RotateBitmap(Bitmap: TBitmap;
                      NewWidth,           // �V�����r�b�g�}�b�v�̑傫��
                      NewHeight: Integer;
                      DestCenterX,        // �ό`��̉�]���S
                      DestCenterY,
                      SourceCenterX,      // �ό`���̉�]���S
                      SourceCenterY: Double;
                      Angle: Double;      // ��]�p(���v���)
                      DefaultColor: Longint) // �f�t�H���g�J���[
                      : TBitmap; overload;

type
  TRotateAngle = (raAngle90, raAngle180, raAngle270); // ��]�p�̎w��
                                                      // ���v���

function RotateBitmap(Bitmap: TBitmap;
                      RotateAngle: TRotateAngle)  // ��]�p�̎w��
                      : TBitmap; overload;

// �r�b�g�}�b�v���A�t�B���ϊ�����
function AffineTransformBitmap(Bitmap: TBitmap;
                               NewWidth,           // �V�����r�b�g�}�b�v�̑傫��
                               NewHeight: Integer;
                               A, B, C, D,         // �A�t�B���ϊ��̌W��
                               E, F, G, H: Double;
                               DefaultColor: Longint) // �f�t�H���g�J���[
                               : TBitmap; overload;

// �r�b�g�}�b�v���������Ƀ~���[���]������
function HorzMirrorBitmap(Bitmap: TBitmap): TBitmap; overload;
// �r�b�g�}�b�v���c�����Ƀ~���[���]������B
function VertMirrorBitmap(Bitmap: TBitmap): TBitmap; overload;

//////////////////////////////
//
// �������� TBigBitmap �p
//

// �r�b�g�}�b�v��ό`����
function TransformBitmap(
  OrgBitmap: TBigBitmap;                       // �ό`���r�b�g�}�b�v
  NewWidth, NewHeight: Integer;                // �V�r�b�g�}�b�v�̑傫��
  TransFormFunction: TBitmapTransFormFunction; // �ό`�����W�v�Z�֐�
  DefaultColor: Longint;                       // �f�t�H���g�J���[
  p: Pointer                                   // �I�v�V���i���p�����[�^
  ): TBigBitmap; overload;

// �r�b�g�}�b�v�g��k������
function StretchBitmap(Bitmap: TBigBitmap;
                          NewWidth,           // �V�����r�b�g�}�b�v�̑傫��
                          NewHeight: Integer)
                          : TBigBitmap; overload;

// �r�b�g�}�b�v����]������
function RotateBitmap(Bitmap: TBigBitmap;
                      NewWidth, NewHeight: Integer;    //�V�r�b�g�}�b�v�̑傫��
                      DestCenterX,            // �ό`��̉�]���S
                      DestCenterY,
                      SourceCenterX,          // �ό`���̉�]���S
                      SourceCenterY: Double;
                      Angle: Double;          // ��]�p(���v���)
                      DefaultColor: Longint)  // �f�t�H���g�J���[
                      : TBigBitmap; overload;

function RotateBitmap(Bitmap: TBigBitmap;
                         RotateAngle: TRotateAngle) // ��]�̎w��
                         : TBigBitmap; overload;

// �r�b�g�}�b�v���A�t�B���ϊ�����
function AffineTransformBitmap(Bitmap: TBigBitmap;
                               NewWidth,           // �V�����r�b�g�}�b�v�̑傫��
                               NewHeight: Integer;
                               A, B, C, D,         // �A�t�B���ϊ��̌W��
                               E, F, G, H: Double;
                               DefaultColor: Longint) // �f�t�H���g�J���[
                               : TBigBitmap; overload;

// �r�b�g�}�b�v���������Ƀ~���[���]������
function HorzMirrorBitmap(Bitmap: TBigBitmap): TBigBitmap; overload;
// �r�b�g�}�b�v���c�����Ƀ~���[���]������B
function VertMirrorBitmap(Bitmap: TBigBitmap): TBigBitmap; overload;


//////////////////////
//
// �r�b�g�}�b�v��������g��k�����郋�[�`���S
//

// Bi-Linear�@�Ŋg��
function Enlarge(Bitmap: TBitmap; Width, Height: Integer): TBitmap;
  overload;
// �ϕ��@�ŏk��
function Shrink(Bitmap: TBitmap; Width, Height: Integer): TBitmap;
  overload;
// Bi-Linear & �ϕ��@�Ł@�g��k��
function Stretch(Bitmap: TBitmap; Width, Height: Integer): TBitmap;
  overload;

////////////
//
//  TBigBitmap�p
//

// Bi-Linear�@�Ŋg��
function Enlarge(Bitmap: TBigBitmap; Width, Height: Integer): TBigBitmap;
  overload;
// �ϕ��@�ŏk��
function Shrink(Bitmap: TBigBitmap; Width, Height: Integer): TBigBitmap;
  overload;
// Bi-Linear & �ϕ��@�Ł@�g��k��
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
// �t�B���^����
//
function BitmapFilter(Bitmap: TBitmap; Filter: TFilterProc;
                      pData: Pointer): TBitmap; overload;

function BitmapFilter(Bitmap: TBigBitmap; Filter: TFilterProc;
                      pData: Pointer): TBigBitmap; overload;

implementation

uses SysUtils, Math;

// �r�b�g�}�b�v��ό`����
function TransformBitmap(
  OrgBitmap: TBitmap;
  NewWidth, NewHeight: Integer;
  TransFormFunction: TBitmapTransFormFunction;
  DefaultColor: Longint;
  p: Pointer
  ): TBitmap;
var
  NewBitmap,              // �V�K�ɍ쐬����r�b�g�}�b�v
  SourceBitmap: TBitmap;  // �I���W�i���̃r�b�g�}�b�v�̃R�s�[
  DS: TDIBSection;        // �r�b�g�}�b�v�̏��
  X, Y: Integer;          // �V�K�r�b�g�}�b�v��ł̍��W
  //�X�L�������C���̃L���b�V��
  SourceScanline, DestScanline: array of Pointer;
  BitCount: Integer;      //�s�N�Z���̃r�b�g��
  SourcePos: TPoint;      // SoucreBitmap��ł̍��W
  // SourceBitmap �̑傫��
  SourceWidth, SourceHeight: Integer;
  Bits: Byte;             // 1bpp, 4bpp �s�N�Z������̂��߂̃��[�N
  DefaultColor24: TTriple;// 24bpp �̏ꍇ�̃f�t�H���g�J���[
  i: Integer;
begin
  // 24bpp �̃f�t�H���g�J���[�����
  DefaultColor24.R := GetRValue(DefaultColor);
  DefaultColor24.G := GetGValue(DefaultColor);
  DefaultColor24.B := GetBValue(DefaultColor);

  SourceBitmap := TBitmap.Create;
  try
    // �ό`���r�b�g�}�b�v�� DIB Section �ł��邱�Ƃ��K�v�B
    // DDB �̉\��������̂ŃR�s�[���� DIB Section�ɕϊ�����
    SourceBitmap.Assign(OrgBitmap);
    SourceBitmap.HandleType := bmDIB;

    // �ό`���Ƃ̃s�N�Z���̃r�b�g���𓾂�
    GetObject(SourceBitmap.Handle, SizeOf(TDIBSection), @DS);
    BitCount := DS.dsBmih.biBitCount;

    NewBitmap := TBitmap.Create;
    try
      // �V�K�r�b�g�}�b�v(�ό`��)�̌`���𐮂���(�ό`���Ɠ����ɂ���)
      NewBitmap.PixelFormat := SourceBitmap.PixelFormat;
      NewBitmap.Palette := CopyPalette(SourceBitmap.Palette); // Modified 2002.2.27
      NewBitmap.Width := NewWidth;
      NewBitmap.Height := NewHeight;

      // Scanline���L���b�V������
      SetLength(SourceScanline, SourceBitmap.Height);
      SetLength(DestScanline, NewBitmap.Height);
      for i := 0 to SourceBitmap.Height-1 do
        SourceScanline[i] := SourceBitmap.Scanline[i];
      for i := 0 to NewBitmap.Height-1 do
        DestScanline[i] := NewBitmap.Scanline[i];

      // Width/Height �v���p�e�B�͒x���̂ŃL���b�V������
      SourceWidth := SourceBitmap.Width;
      SourceHeight := SourceBitmap.Height;

      for Y := 0 to NewBitmap.Height-1 do
      begin
        for X := 0 to NewBitmap.Width-1 do
        begin
          // �ό`��̍��W����ό`���̍��W�����߂�
          SourcePos := TransformFunction(Point(X, Y), p);

          // ����ꂽ���W���ό`���̃r�b�g�}�b�v���Ŗ����Ȃ�f�t�H���g
          // �J���[��ό`��ɃZ�b�g����B
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
          // ����ꂽ���W���ό`���̃r�b�g�}�b�v���Ȃ�A���W�̎w���s�N�Z����ǂ�
          // �����ό`��ɃR�s�[����B
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
    SourceWidth,  // �ό`���r�b�g�}�b�v�̑傫��
    SourceHeight,
    DestWidth,    // �ό`��r�b�g�}�b�v�̑傫��
    DestHeight: Integer;
  end;
  PStretchParams = ^TStretchParams;

// �g��k���p �ό`�����W�v�Z�֐�
function StretchTransformFunc(Pos: TPoint; p: Pointer): TPoint;
var
  pParams: PStretchParams;
begin
  pParams := p;

  // �r�b�g�}�b�v�̑傫���̔���g���ĕό`���r�b�g�}�b�v��
  // ���W�����߂�
  with pParams^ do
    Result := Point(Pos.x * SourceWidth div DestWidth,
                    Pos.y * SourceHeight div DestHeight);
end;

function StretchBitmap(Bitmap: TBitmap;
                       NewWidth,           // �V�����r�b�g�}�b�v�̑傫��
                       NewHeight: Integer)
                       : TBitmap;
var
  Params: TStretchParams;
begin
  // �ό`���A�ό`�����̃r�b�g�}�b�v�̑傫�����Z�b�g
  Params.SourceWidth := Bitmap.Width;
  Params.SourceHeight := Bitmap.Height;
  Params.DestWidth := NewWidth;
  Params.DestHeight := NewHeight;

  // StretchTransformFunc ���g���ăr�b�g�}�b�v��ό`
  Result := TransformBitmap(Bitmap, NewWidth, NewHeight,
                            StretchTransformFunc,
                            0, @Params);
end;

// �r�b�g�}�b�v����]������
function RotateBitmap(Bitmap: TBitmap;
                      NewWidth,           // �V�����r�b�g�}�b�v�̑傫��
                      NewHeight: Integer;
                      DestCenterX,        // �ό`��̉�]���S
                      DestCenterY,
                      SourceCenterX,      // �ό`���̉�]���S
                      SourceCenterY: Double;
                      Angle: Double;      // ��]�p(���v���)
                      DefaultColor: Longint) // �f�t�H���g�J���[
                      : TBitmap; overload;
begin
  // �A�t�B���ϊ����g���ĕό`����B
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
    A, B, C, D, E, F, G, H: Double; // �A�t�B���ϊ��̏����@�̌W��
    AD, BD, CD, DD, ED, FD: Double; // �t�����̃A�t�B���ϊ��̌W��
    AffineCoffsCached: Boolean;     // �t�����̌W�����������̌W������
                                    // �Z�o�ς݂���\���t���O
  end;
  PAffineParams = ^TAffineParams;

// �t�A�t�B���ϊ��ŕό`���̍��W���Z�o����
function AffineTransformFunc(Pos: TPoint; p: Pointer): TPoint;
var
  pParams: PAffineParams;
begin
  pParams := p;

  // �t�����̃A�t�B���ϊ��p�W�������v�Z�Ȃ�v�Z
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

// �A�t�B���ϊ��Ńr�b�g�}�b�v��ό`����
function AffineTransformBitmap(Bitmap: TBitmap;
                               NewWidth,           // �V�����r�b�g�}�b�v�̑傫��
                               NewHeight: Integer;
                               A, B, C, D,         // �A�t�B���ϊ��̌W��
                               E, F, G, H: Double;
                               DefaultColor: Longint) // �f�t�H���g�J���[
                               : TBitmap;
var
  Params: TAffineParams;
begin
  // �A�t�B���ϊ��̌W�����Z�b�g����
  Params.A := A; Params.B := B; Params.C := C;
  Params.D := D; Params.E := E; Params.F := F;
  Params.G := G; Params.H := H;
  Params.AffineCoffsCached := False;

  // AffineTransformFunc �Ńr�b�g�}�b�v��ό`����B
  Result := TransformBitmap(Bitmap, NewWidth, NewHeight,
                            AffineTransformFunc,
                            DefaultColor, @Params);
end;

type
  THorzMirrorParams = record
    SourceWidth: Integer;    // �ό`���̃r�b�g�}�b�v�̕�
  end;
  PHorzMirrorParams = ^THorzMirrorParams;

// �������~���[�p�̕ό`�����W�v�Z�֐�
function HorzMirrorFunc(Pos: TPoint; p: Pointer): TPoint;
begin
  Result := Point(PHorzMirrorParams(p).SourceWidth -1 - Pos.X, Pos.Y);
end;

// �r�b�g�}�b�v���������ɗ��Ԃ��B
function HorzMirrorBitmap(Bitmap: TBitmap): TBitmap;
var
  Params: THorzMirrorParams;
begin
  Params.SourceWidth := Bitmap.Width;

  // HorzMirrorFunc ���g���ĕό`����
  Result := TransformBitmap(Bitmap, Bitmap.Width, Bitmap.Height,
                            HorzMirrorFunc,
                            0, @Params);
end;

type
  TVertMirrorParams = record
    SourceHeight: Integer;  // �ϊ����r�b�g�}�b�v�̍���
  end;
  PVertMirrorParams = ^TVertMirrorParams;

// �c�����~���[�p�ό`�����W�v�Z�֐�
function VertMirrorFunc(Pos: TPoint; p: Pointer): TPoint;
begin
  Result := Point(Pos.X, PVertMirrorParams(p).SourceHeight -1 - Pos.Y);
end;

// �r�b�g�}�b�v���c�����ɗ��Ԃ�
function VertMirrorBitmap(Bitmap: TBitmap): TBitmap;
var
  Params: TVertMirrorParams;
begin
  Params.SourceHeight := Bitmap.Height;

  // VertMirrorFunc ���g���ĕό`����
  Result := TransformBitmap(Bitmap, Bitmap.Width, Bitmap.Height,
                            VertMirrorFunc,
                            0, @Params);
end;

type
  TRotateParams = record
    SourceWidth : Integer;     // �ό`���r�b�g�}�b�v�̕�
    SourceHeight: Integer;     // �ό`���r�b�g�}�b�v�̍���
    RotateAngle: TRotateAngle; // ��]�`��(�����v���)
  end;
  PRotateParams = ^TRotateParams;

// ��]�p �ό`�����W�v�Z�֐�
function RotateFunc(Pos: TPoint; p: Pointer): TPoint;
var
  pParams: PRotateParams;
begin
  pParams := p;
  // ��]�p�ƕό`����W����ό`�����W���v�Z����
  with pParams^ do
    case RotateAngle of
      raAngle90:  Result := Point(Pos.Y, SourceHeight-1-Pos.X);
      raAngle180: Result := Point(SourceWidth-1-Pos.X, SourceHeight-1-Pos.Y);
      raAngle270: Result := Point(SourceWidth-1-Pos.Y, Pos.X);
    end;
end;

// �r�b�g�}�b�v����]����B
function RotateBitmap(Bitmap: TBitmap;
                      RotateAngle: TRotateAngle) // ��]�p(���v���)
                      : TBitmap; overload;
var
  Params: TRotateParams;
begin
  Params.SourceWidth := Bitmap.Width;
  Params.SourceHeight := Bitmap.Height;
  Params.RotateAngle := RotateAngle;

  // RotateFunc ���g���ăr�b�g�}�b�v����]������
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
// �������� TBitBitmap �p
//

//�r�b�g�}�b�v��ό`����
function TransformBitmap(
  OrgBitmap: TBigBitmap;                       // �ό`���r�b�g�}�b�v
  NewWidth, NewHeight: Integer;                // �V�r�b�g�}�b�v�̑傫��
  TransFormFunction: TBitmapTransFormFunction; // �ό`�����W�v�Z�֐�
  DefaultColor: Longint;                       // �f�t�H���g�J���[
  p: Pointer                                   // �I�v�V���i���p�����[�^
  ): TBigBitmap;

var
  NewBitmap: TBigBitmap;  // �V�K�ɍ쐬����r�b�g�}�b�v
  X, Y: Integer;          // �V�K�r�b�g�}�b�v��ł̍��W
  //�X�L�������C���̃L���b�V��
  SourceScanline, DestScanline: array of Pointer;
  SourcePos: TPoint;      // SoucreBitmap��ł̍��W
  // SourceBitmap �̑傫��
  SourceWidth, SourceHeight: Integer;
  Bits: Byte;             // 1bpp, 4bpp �s�N�Z������̂��߂̃��[�N
  DefaultColor24: TTriple;// 24bpp �̏ꍇ�̃f�t�H���g�J���[
  PixelFormat: TBigBitmapPixelFormat;
  i: Integer;
begin
  // 24bpp �̃f�t�H���g�J���[�����
  DefaultColor24.R := GetRValue(DefaultColor);
  DefaultColor24.G := GetGValue(DefaultColor);
  DefaultColor24.B := GetBValue(DefaultColor);

  NewBitmap := TBigBitmap.Create;
  try
    // �V�K�r�b�g�}�b�v(�ό`��)�̌`���𐮂���(�ό`���Ɠ����ɂ���)
    NewBitmap.PixelFormat := OrgBitmap.PixelFormat;
    NewBitmap.Width := NewWidth;
    NewBitmap.Height := NewHeight;
    NewBitmap.Palette := CopyPalette(OrgBitmap.Palette); // modified 2002.2.27

    // Scanline���L���b�V������
    SetLength(SourceScanline, OrgBitmap.Height);
    SetLength(DestScanline, NewBitmap.Height);
    for i := 0 to OrgBitmap.Height-1 do
      SourceScanline[i] := OrgBitmap.Scanline[i];
    for i := 0 to NewBitmap.Height-1 do
      DestScanline[i] := NewBitmap.Scanline[i];

    // Width/Height �v���p�e�B�͒x���̂ŃL���b�V������
    SourceWidth := OrgBitmap.Width;
    SourceHeight := OrgBitmap.Height;

    // PixelFormat ���L���b�V������
    PixelFormat := OrgBitmap.PixelFormat;

    for Y := 0 to NewBitmap.Height-1 do
    begin
      for X := 0 to NewBitmap.Width-1 do
      begin
        // �ό`��̍��W����ό`���̍��W�����߂�
        SourcePos := TransformFunction(Point(X, Y), p);

        // ����ꂽ���W���ό`���̃r�b�g�}�b�v���Ŗ����Ȃ�f�t�H���g
        // �J���[��ό`��ɃZ�b�g����B
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
        // ����ꂽ���W���ό`���̃r�b�g�}�b�v���Ȃ�A���W�̎w���s�N�Z����ǂ�
        // �����ό`��ɃR�s�[����B
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

// �r�b�g�}�b�v�g��k������
function StretchBitmap(Bitmap: TBigBitmap;
                          NewWidth, NewHeight: Integer) // �V�r�b�g�}�b�v�̑傫��
                          : TBigBitmap;
var
  Params: TStretchParams;
begin
  Params.SourceWidth := Bitmap.Width;
  Params.SourceHeight := Bitmap.Height;
  Params.DestWidth := NewWidth;
  Params.DestHeight := NewHeight;

  // StretchTransformFunc ���g���ĕό`����
  Result := TransformBitmap(Bitmap, NewWidth, NewHeight,
                            StretchTransformFunc,
                            0, @Params);
end;

// �r�b�g�}�b�v����]������
function RotateBitmap(Bitmap: TBigBitmap;
                      NewWidth, NewHeight: Integer;    //�V�r�b�g�}�b�v�̑傫��
                      DestCenterX,            // �ό`��̉�]���S
                      DestCenterY,
                      SourceCenterX,          // �ό`���̉�]���S
                      SourceCenterY: Double;
                      Angle: Double;          // ��]�p(���v���)
                      DefaultColor: Longint)  // �f�t�H���g�J���[
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
                         RotateAngle: TRotateAngle) // ��]�̎w��
                         : TBigBitmap;
var
  Params: TRotateParams;
begin
  Params.SourceWidth := Bitmap.Width;
  Params.SourceHeight := Bitmap.Height;
  Params.RotateAngle := RotateAngle;

  // RotateFunc ���g���ăr�b�g�}�b�v����]������
  if RotateAngle = raAngle180 then
    Result := TransformBitmap(Bitmap, Bitmap.Width, Bitmap.Height,
                              RotateFunc,
                              0, @Params)
  else
    Result := TransformBitmap(Bitmap, Bitmap.Height, Bitmap.Width,
                              RotateFunc,
                              0, @Params);
end;

// �r�b�g�}�b�v���A�t�B���ϊ�����
function AffineTransformBitmap(Bitmap: TBigBitmap;
                               NewWidth,           // �V�����r�b�g�}�b�v�̑傫��
                               NewHeight: Integer;
                               A, B, C, D,         // �A�t�B���ϊ��̌W��
                               E, F, G, H: Double;
                               DefaultColor: Longint) // �f�t�H���g�J���[
                               : TBigBitmap;
var
  Params: TAffineParams;
begin
  // �A�t�B���ϊ��̌W�����Z�b�g����
  Params.A := A; Params.B := B; Params.C := C;
  Params.D := D; Params.E := E; Params.F := F;
  Params.G := G; Params.H := H;
  Params.AffineCoffsCached := False;

  // AffineTransformFunc �Ńr�b�g�}�b�v��ό`����B
  Result := TransformBitmap(Bitmap, NewWidth, NewHeight,
                            AffineTransformFunc,
                            DefaultColor, @Params);
end;

// �r�b�g�}�b�v���������Ƀ~���[���]������
function HorzMirrorBitmap(Bitmap: TBigBitmap): TBigBitmap;
var
  Params: THorzMirrorParams;
begin
  Params.SourceWidth := Bitmap.Width;

  // HorzMirrorFunc ���g���ĕό`����
  Result := TransformBitmap(Bitmap, Bitmap.Width, Bitmap.Height,
                            HorzMirrorFunc,
                            0, @Params);
end;

// �r�b�g�}�b�v���c�����Ƀ~���[���]������B
function VertMirrorBitmap(Bitmap: TBigBitmap): TBigBitmap;
var
  Params: TVertMirrorParams;
begin
  Params.SourceHeight := Bitmap.Height;

  // VertMirrorFunc ���g���ĕό`����
  Result := TransformBitmap(Bitmap, Bitmap.Width, Bitmap.Height,
                            VertMirrorFunc,
                            0, @Params);
end;



////////////////////
//
//  ��������������g��k�����邽�߂̃��[�`���Q
//

function Enlarge(Bitmap: TBitmap; Width, Height: Integer): TBitmap;
type
  TDoubleTriple = record
    B, G, R: Double;
  end;
var NewBitmap, SourceBitmap: TBitmap;
    // �ϊ���� x, y ���W�l
    x, y: Integer;
    // �ϊ����̃r�b�g�}�b�v�̑傫��
    SourceWidth, SourceHeight: Integer;
    // �g�嗦�̋t��
    XRatio, YRatio, Temp: Double;
    // x, y ��ϊ����ɓ��e�������́@�ߖT�̃s�N�Z��4�_
    a, b, c, d: TTriple;
    // �ߖT�̃s�N�Z��4�_���狁�߂� Bi-Linear �̌W��
    p, q, r, s: TDoubleTriple;
    // �ϊ����A�ϊ���̃X�L�������C���|�C���^�̃L���b�V��
    SourceScans, NewScans: array of PTripleArray;
    // �X�L�������C���ւ̃|�C���^
    pSourceScan1, pSourceScan2, pNewScan: PTripleArray;
    // x, y ��ϊ����֓��e�����Ƃ��́@���W�l�̏�����
    FracX, FracY: Extended;
    // x, y ��ϊ����֓��e�����Ƃ��́@���W�l�̐�����
    IntX, IntY: Integer;

    i: Integer;
begin
  SourceWidth := Bitmap.Width; SourceHeight := Bitmap.Height;
  assert((SourceWidth > 0) and (SourceHeight > 0));
  XRatio := SourceWidth / Width;
  YRatio := SourceHeight / Height;
  NewBitmap := TBitmap.Create;
  try
    // �ϊ��� �r�b�g�}�b�v�����
    NewBitmap.PixelFormat := pf24bit;
    NewBitmap.Width := Width; NewBitmap.Height := Height;

    // �ϊ������t���J���[�ɂ���
    SourceBitmap := TBitmap.Create;
    try
      SourceBitmap.Assign(Bitmap);
      SourceBitmap.PixelFormat := pf24Bit;

      // �X�L�������C���|�C���^�̃L���b�V�������
      SetLength(SourceScans, SourceHeight);
      SetLength(NewScans, Height);

      for i := 0 to SourceHeight-1 do
        SourceScans[i] := SourceBitmap.ScanLine[i];

      for i := 0 to Height-1 do
        NewScans[i] := NewBitmap.Scanline[i];


      for y := 0 to Height-1 do begin
        // �ϊ���X�L�������C���|�C���^�𓾂�
        pNewScan := NewScans[y];

        // y ��ϊ����ɓ��e����
        Temp := (y+0.5) * YRatio - 0.5;
        IntY := floor(Temp);
        FracY := Temp - IntY;

        // IntY ����Y������X�L�������C����
        // ���̎��̃X�L�������C�������߂�
        // �r�b�g�}�b�v�̒[���l������B
        if IntY < 0  then
          pSourceScan1:= SourceScans[0]
        else
          pSourceScan1:= SourceScans[IntY];
        if IntY + 1 > SourceHeight-1 then
          pSourceScan2 := SourceScans[SourceHeight-1]
        else
          pSourceScan2 := SourceScans[IntY+1];

        for x := 0 to Width-1 do begin

          // x ��ϊ����ɓ��e����
          Temp := (x+0.5) * XRatio - 0.5;
          IntX := Floor(Temp);
          FracX := Temp - IntX;

          // IntX, IntY ����A�ߖT��4�s�N�Z����I��
          // �r�b�g�}�b�v�̒[���l������
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

          // Bi-Linear �̌W�������߂�
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

          // RGB �l���v�Z���A�ϊ���ɑ������
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
    // �ϊ���� x, y ���W�l
    x, y: Integer;
    // �ϊ����̃r�b�g�}�b�v�̑傫��
    SourceWidth, SourceHeight: Integer;
    // �ϊ����ɓ��e���ꂽ�ϊ���s�N�Z���̈ʒu
    RectTop, RectLeft, RectRight, RectBottom: Double;
    // �ϊ����ɓ��e���ꂽ�ϊ���s�N�Z���ƕϊ����s�N�Z����
    // ������Ă��镔���̑傫��
    w, h: Double;
    // �k����(�ʐϔ�)
    Ratio: Single;
    // �X�L�������C���|�C���^
    pSourceScan, pNewScan: PTripleArray;
    // X�����AY�����̏k����
    XRatio, YRatio: Double;
    // �X�L�������C���|�C���^�̃L���b�V��
    SourceScans, NewScans: array of PTripleArray;
    // �ϊ���̃s�N�Z���n
    Pixel: TDoubleTriple;
    // �ϊ����Ƃ̃s�N�Z���l
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
    // �ϊ��� �r�b�g�}�b�v�����
    NewBitmap.PixelFormat := pf24bit;
    NewBitmap.Width := Width; NewBitmap.Height := Height;

    // �ϊ������t���J���[�ɂ���
    SourceBitmap := TBitmap.Create;
    try
      SourceBitmap.Assign(Bitmap);
      SourceBitmap.PixelFormat := pf24Bit;

      // �X�L�������C���|�C���^�̃L���b�V�������
      SetLength(SourceScans, SourceHeight);
      SetLength(NewScans, Height);

      for i := 0 to SourceHeight-1 do
        SourceScans[i] := SourceBitmap.ScanLine[i];

      for i := 0 to Height-1 do
        NewScans[i] := NewBitmap.Scanline[i];

      for y := 0 to Height-1 do begin
        // �ϊ���X�L�������C���|�C���^�𓾂�
        pNewScan := NewScans[y];
        for x := 0 to Width-1 do begin
          // �ϊ���s�N�Z����ϊ����ɓ��e����B
          RectLeft   := x * XRatio;
          RectTop    := y * YRatio;
          RectRight  := (x+1) * XRatio  - 0.000001;
          RectBottom := (y+1) * YRatio - 0.000001;

          // �ϊ����ɓ��e���ꂽ�ϊ���s�N�Z���ƌ�����Ă���
          // �ϊ����s�N�Z����I�яo���ϕ�����
          Pixel.R := 0; Pixel.G := 0; Pixel.B := 0;

          for j := floor(RectTop) to floor(RectBottom) do begin
            pSourceScan:= SourceScans[j];
            for i := floor(RectLeft) to floor(RectRight) do begin
              SourcePixel := pSourceScan[i];

              // ���e���ꂽ�s�N�Z���ƕϊ����s�N�Z���̌�����Ă���
              // �����̑傫�������߂�
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

              // �ϊ����@1 �s�N�Z�����@�ϕ�
              Pixel.R := Pixel.R + w * h * SourcePixel.R;
              Pixel.G := Pixel.G + w * h * SourcePixel.G;
              Pixel.B := Pixel.B + w * h * SourcePixel.B;
            end;
          end;
          // �ϕ��l���畽�ϒl�����ߕϊ���ɑ������
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
    // �ϊ���� x, y ���W�l
    x, y: Integer;
    // �ϊ����̃r�b�g�}�b�v�̑傫��
    SourceWidth, SourceHeight: Integer;
    // �ϊ����ɓ��e���ꂽ�ϊ���s�N�Z���̈ʒu
    RectTop, RectLeft, RectRight, RectBottom: Double;
    // �ϊ����ɓ��e���ꂽ�ϊ���s�N�Z���ƕϊ����s�N�Z����
    // ������Ă��镔���̑傫��
    w, h: Double;
    // �ϊ����ɓ��e���ꂽ�ϊ���s�N�Z���ƕϊ����s�N�Z����
    // ������Ă��镔���̒��S�ʒu�B�ϊ����s�N�Z���̍��オ�
    XAve, YAve: Double;
    // x, y ��ϊ����ɓ��e�������́@�ߖT�̃s�N�Z��4�_
    a, b, c, d: TTriple;
    // �ߖT�̃s�N�Z��4�_���狁�߂� Bi-Linear �̌W��
    p, q, r, s: TDoubleTriple;
    // �g�嗦�̋t��(�ʐϔ�)
    Ratio: Double;
    // �X�L�������C���|�C���^
    pSourceScan1, pSourceScan2, pNewScan: PTripleArray;
    // X�����AY�����̊g�嗦�̋t���B
    XRatio, YRatio: Double;
    // �X�L�������C���̃L���b�V��
    SourceScans, NewScans: array of PTripleArray;
    // �ϊ���̃s�N�Z���l
    Pixel: TDoubleTriple;

    i, j: Integer;
begin
  SourceWidth := Bitmap.Width; SourceHeight := Bitmap.Height;
  assert((SourceWidth > 0) and (SourceHeight > 0));
  Ratio := SourceWidth * Sourceheight / Width / Height;
  XRatio := SourceWidth / Width;
  YRatio := SourceHeight / Height;

  // �ϊ��� �r�b�g�}�b�v�����
  NewBitmap := TBitmap.Create;
  try
    NewBitmap.PixelFormat := pf24bit;
    NewBitmap.Width := Width; NewBitmap.Height := Height;

    // �ϊ������t���J���[�ɂ���
    SourceBitmap := TBitmap.Create;
    try
      SourceBitmap.Assign(Bitmap);
      SourceBitmap.PixelFormat := pf24Bit;

      // �X�L�������C���|�C���^�̃L���b�V�������
      SetLength(SourceScans, SourceHeight);
      SetLength(NewScans, Height);

      for i := 0 to SourceHeight-1 do
        SourceScans[i] := SourceBitmap.ScanLine[i];

      for i := 0 to Height-1 do
        NewScans[i] := NewBitmap.Scanline[i];

      for y := 0 to Height-1 do begin
        // �ϊ���X�L�������C���|�C���^�𓾂�
        pNewScan := NewScans[y];

        for x := 0 to Width-1 do begin

          // �ϊ���s�N�Z����ϊ����ɓ��e����(0.5 �Â��炷)�B
          RectLeft   := x * XRatio - 0.5;
          RectTop    := y * YRatio - 0.5;
          RectRight  := (x+1) * XRatio  - 0.500001;
          RectBottom := (y+1) * YRatio - 0.500001;

          // �ϊ����ɓ��e���ꂽ�ϊ���s�N�Z���ƌ�����Ă���
          // �ϊ����s�N�Z���Ԃ� Bi-Linera �Ȗʂ�I�яo���ϕ�����
          Pixel.R := 0; Pixel.G := 0; Pixel.B := 0;

          for j := floor(RectTop) to floor(RectBottom) do begin
            // Bi-Linear �Ȗʂ̏�Ɖ��̃s�N�Z���̃X�L�������C�������߂�
            // �r�b�g�}�b�v�̒[���l��
            if j < 0 then
              pSourceScan1:= SourceScans[0]
            else
              pSourceScan1:= SourceScans[j];
            if j+1 > SourceHeight-1 then
              pSourceScan2 := SourceScans[SourceHeight-1]
            else
              pSourceScan2 := SourceScans[j+1];

            for i := floor(RectLeft) to floor(RectRight) do begin

              // Bi-Linear �Ȗʂ�4���̃s�N�Z���𓾂�
              // �r�b�g�}�b�v�̒[���l��
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

              // Bi-Linear �Ȗʂ̌W�����v�Z����B
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

              //���e���ꂽ�s�N�Z���� Bi-Linear �Ȗʂ̌�����Ă��镔����
              //�傫���ƒ��S�ʒu�����߂�
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

              // ���e���ꂽ�s�N�Z���� Bi-Linear �Ȗʂ̌�����Ă��镔����
              // �ϕ�����
              Pixel.R := Pixel.R +
                w * h * (p.R*XAve + q.R*XAve * YAve + r.R*YAve + s.R);
              Pixel.G := Pixel.G +
                w * h * (p.G*XAve + q.G*XAve * YAve + r.G*YAve + s.G);
              Pixel.B := Pixel.B +
                w * h * (p.B*XAve + q.B*XAve * YAve + r.B*YAve + s.B);
            end;
          end;
          // �ϕ��l���畽�ϒl�����ߕϊ���ɑ������B
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
// �������� TBigBitmap�p

function Enlarge(Bitmap: TBigBitmap; Width, Height: Integer): TBigBitmap;
type
  TDoubleTriple = record
    B, G, R: Double;
  end;

var NewBitmap, SourceBitmap: TBigBitmap;
    // �ϊ���� x, y ���W�l
    x, y: Integer;
    // �ϊ����̃r�b�g�}�b�v�̑傫��
    SourceWidth, SourceHeight: Integer;
    // �g�嗦�̋t��
    XRatio, YRatio, Temp: Double;
    // x, y ��ϊ����ɓ��e�������́@�ߖT�̃s�N�Z��4�_
    a, b, c, d: TTriple;
    // �ߖT�̃s�N�Z��4�_���狁�߂� Bi-Linear �̌W��
    p, q, r, s: TDoubleTriple;
    // �ϊ����A�ϊ���̃X�L�������C���|�C���^�̃L���b�V��
    SourceScans, NewScans: array of PTripleArray;
    // �X�L�������C���ւ̃|�C���^
    pSourceScan1, pSourceScan2, pNewScan: PTripleArray;
    // x, y ��ϊ����֓��e�����Ƃ��́@���W�l�̏�����
    FracX, FracY: Extended;
    // x, y ��ϊ����֓��e�����Ƃ��́@���W�l�̐�����
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
    // �ϊ��� �r�b�g�}�b�v�����
    NewBitmap.PixelFormat := bbpf24bit;
    NewBitmap.Width := Width; NewBitmap.Height := Height;

    // �ϊ������t���J���[�ɂ���
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

      // �X�L�������C���|�C���^�̃L���b�V�������
      SetLength(SourceScans, SourceHeight);
      SetLength(NewScans, Height);

      for i := 0 to SourceHeight-1 do
        SourceScans[i] := SourceBitmap.ScanLine[i];

      for i := 0 to Height-1 do
        NewScans[i] := NewBitmap.Scanline[i];


      for y := 0 to Height-1 do begin
        // �ϊ���X�L�������C���|�C���^�𓾂�
        pNewScan := NewScans[y];

        // y ��ϊ����ɓ��e����
        Temp := (y+0.5) * YRatio - 0.5;
        IntY := floor(Temp);
        FracY := Temp - IntY;

        // IntY ����Y������X�L�������C����
        // ���̎��̃X�L�������C�������߂�
        // �r�b�g�}�b�v�̒[���l������B
        if IntY < 0  then
          pSourceScan1:= SourceScans[0]
        else
          pSourceScan1:= SourceScans[IntY];
        if IntY + 1 > SourceHeight-1 then
          pSourceScan2 := SourceScans[SourceHeight-1]
        else
          pSourceScan2 := SourceScans[IntY+1];

        for x := 0 to Width-1 do begin

          // x ��ϊ����ɓ��e����
          Temp := (x+0.5) * XRatio - 0.5;
          IntX := Floor(Temp);
          FracX := Temp - IntX;

          // IntX, IntY ����A�ߖT��4�s�N�Z����I��
          // �r�b�g�}�b�v�̒[���l������
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

          // Bi-Linear �̌W�������߂�
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

          // RGB �l���v�Z���A�ϊ���ɑ������
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
    // �ϊ���� x, y ���W�l
    x, y: Integer;
    // �ϊ����̃r�b�g�}�b�v�̑傫��
    SourceWidth, SourceHeight: Integer;
    // �ϊ����ɓ��e���ꂽ�ϊ���s�N�Z���̈ʒu
    RectTop, RectLeft, RectRight, RectBottom: Double;
    // �ϊ����ɓ��e���ꂽ�ϊ���s�N�Z���ƕϊ����s�N�Z����
    // ������Ă��镔���̑傫��
    w, h: Double;
    // �k����(�ʐϔ�)
    Ratio: Single;
    // �X�L�������C���|�C���^
    pSourceScan, pNewScan: PTripleArray;
    // X�����AY�����̏k����
    XRatio, YRatio: Double;
    // �X�L�������C���|�C���^�̃L���b�V��
    SourceScans, NewScans: array of PTripleArray;
    // �ϊ���̃s�N�Z���n
    Pixel: TDoubleTriple;
    // �ϊ����Ƃ̃s�N�Z���l
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
    // �ϊ��� �r�b�g�}�b�v�����
    NewBitmap.PixelFormat := bbpf24bit;
    NewBitmap.Width := Width; NewBitmap.Height := Height;

    // �ϊ������t���J���[�ɂ���
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

      // �X�L�������C���|�C���^�̃L���b�V�������
      SetLength(SourceScans, SourceHeight);
      SetLength(NewScans, Height);

      for i := 0 to SourceHeight-1 do
        SourceScans[i] := SourceBitmap.ScanLine[i];

      for i := 0 to Height-1 do
        NewScans[i] := NewBitmap.Scanline[i];

      for y := 0 to Height-1 do begin
        // �ϊ���X�L�������C���|�C���^�𓾂�
        pNewScan := NewScans[y];
        for x := 0 to Width-1 do begin
          // �ϊ���s�N�Z����ϊ����ɓ��e����B
          RectLeft   := x * XRatio;
          RectTop    := y * YRatio;
          RectRight  := (x+1) * XRatio  - 0.000001;
          RectBottom := (y+1) * YRatio - 0.000001;

          // �ϊ����ɓ��e���ꂽ�ϊ���s�N�Z���ƌ�����Ă���
          // �ϊ����s�N�Z����I�яo���ϕ�����
          Pixel.R := 0; Pixel.G := 0; Pixel.B := 0;

          for j := floor(RectTop) to floor(RectBottom) do begin
            pSourceScan:= SourceScans[j];
            for i := floor(RectLeft) to floor(RectRight) do begin
              SourcePixel := pSourceScan[i];

              // ���e���ꂽ�s�N�Z���ƕϊ����s�N�Z���̌�����Ă���
              // �����̑傫�������߂�
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

              // �ϊ����@1 �s�N�Z�����@�ϕ�
              Pixel.R := Pixel.R + w * h * SourcePixel.R;
              Pixel.G := Pixel.G + w * h * SourcePixel.G;
              Pixel.B := Pixel.B + w * h * SourcePixel.B;
            end;
          end;
          // �ϕ��l���畽�ϒl�����ߕϊ���ɑ������
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
    // �ϊ���� x, y ���W�l
    x, y: Integer;
    // �ϊ����̃r�b�g�}�b�v�̑傫��
    SourceWidth, SourceHeight: Integer;
    // �ϊ����ɓ��e���ꂽ�ϊ���s�N�Z���̈ʒu
    RectTop, RectLeft, RectRight, RectBottom: Double;
    // �ϊ����ɓ��e���ꂽ�ϊ���s�N�Z���ƕϊ����s�N�Z����
    // ������Ă��镔���̑傫��
    w, h: Double;
    // �ϊ����ɓ��e���ꂽ�ϊ���s�N�Z���ƕϊ����s�N�Z����
    // ������Ă��镔���̒��S�ʒu�B�ϊ����s�N�Z���̍��オ�
    XAve, YAve: Double;
    // x, y ��ϊ����ɓ��e�������́@�ߖT�̃s�N�Z��4�_
    a, b, c, d: TTriple;
    // �ߖT�̃s�N�Z��4�_���狁�߂� Bi-Linear �̌W��
    p, q, r, s: TDoubleTriple;
    // �g�嗦�̋t��(�ʐϔ�)
    Ratio: Double;
    // �X�L�������C���|�C���^
    pSourceScan1, pSourceScan2, pNewScan: PTripleArray;
    // X�����AY�����̊g�嗦�̋t���B
    XRatio, YRatio: Double;
    // �X�L�������C���̃L���b�V��
    SourceScans, NewScans: array of PTripleArray;
    // �ϊ���̃s�N�Z���l
    Pixel: TDoubleTriple;

    DrawMode: TBigBitmapDrawMode;
    i, j: Integer;
begin
  SourceWidth := Bitmap.Width; SourceHeight := Bitmap.Height;
  assert((SourceWidth > 0) and (SourceHeight > 0));
  Ratio := SourceWidth * Sourceheight / Width / Height;
  XRatio := SourceWidth / Width;
  YRatio := SourceHeight / Height;

  // �ϊ��� �r�b�g�}�b�v�����
  NewBitmap := TBigBitmap.Create;
  try
    NewBitmap.PixelFormat := bbpf24bit;
    NewBitmap.Width := Width; NewBitmap.Height := Height;

    // �ϊ������t���J���[�ɂ���
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

      // �X�L�������C���|�C���^�̃L���b�V�������
      SetLength(SourceScans, SourceHeight);
      SetLength(NewScans, Height);

      for i := 0 to SourceHeight-1 do
        SourceScans[i] := SourceBitmap.ScanLine[i];

      for i := 0 to Height-1 do
        NewScans[i] := NewBitmap.Scanline[i];

      for y := 0 to Height-1 do begin
        // �ϊ���X�L�������C���|�C���^�𓾂�
        pNewScan := NewScans[y];

        for x := 0 to Width-1 do begin

          // �ϊ���s�N�Z����ϊ����ɓ��e����(0.5 �Â��炷)�B
          RectLeft   := x * XRatio - 0.5;
          RectTop    := y * YRatio - 0.5;
          RectRight  := (x+1) * XRatio  - 0.500001;
          RectBottom := (y+1) * YRatio - 0.500001;

          // �ϊ����ɓ��e���ꂽ�ϊ���s�N�Z���ƌ�����Ă���
          // �ϊ����s�N�Z���Ԃ� Bi-Linera �Ȗʂ�I�яo���ϕ�����
          Pixel.R := 0; Pixel.G := 0; Pixel.B := 0;

          for j := floor(RectTop) to floor(RectBottom) do begin
            // Bi-Linear �Ȗʂ̏�Ɖ��̃s�N�Z���̃X�L�������C�������߂�
            // �r�b�g�}�b�v�̒[���l��
            if j < 0 then
              pSourceScan1:= SourceScans[0]
            else
              pSourceScan1:= SourceScans[j];
            if j+1 > SourceHeight-1 then
              pSourceScan2 := SourceScans[SourceHeight-1]
            else
              pSourceScan2 := SourceScans[j+1];

            for i := floor(RectLeft) to floor(RectRight) do begin

              // Bi-Linear �Ȗʂ�4���̃s�N�Z���𓾂�
              // �r�b�g�}�b�v�̒[���l��
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

              // Bi-Linear �Ȗʂ̌W�����v�Z����B
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

              //���e���ꂽ�s�N�Z���� Bi-Linear �Ȗʂ̌�����Ă��镔����
              //�傫���ƒ��S�ʒu�����߂�
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

              // ���e���ꂽ�s�N�Z���� Bi-Linear �Ȗʂ̌�����Ă��镔����
              // �ϕ�����
              Pixel.R := Pixel.R +
                w * h * (p.R*XAve + q.R*XAve * YAve + r.R*YAve + s.R);
              Pixel.G := Pixel.G +
                w * h * (p.G*XAve + q.G*XAve * YAve + r.G*YAve + s.G);
              Pixel.B := Pixel.B +
                w * h * (p.B*XAve + q.B*XAve * YAve + r.B*YAve + s.B);
            end;
          end;
          // �ϕ��l���畽�ϒl�����ߕϊ���ɑ������B
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
var MatSave,            // 11���C������Scanline��ێ�����o�b�t�@
    Mat: TTripleMatrix; // �s�N�Z�����󂯎�� 11x11 �̃}�g���b�N�X
    i: Integer;
    x, y: Integer;               // ���W
    NewBitmap: TBitmap;          // �쐬����r�b�g�}�b�v
    DestLine: PTripleArray;      // �V�����r�b�g�}�b�v�̃X�L�������C��
    LineSize, BufSize: Integer;  // �s�T�C�Y�ƃo�b�t�@�T�C�Y
begin
  // BitmapFilter �� 24bpp �����T�|�[�g���܂���B
  if Bitmap.PixelFormat <> Pf24Bit then
    Raise Exception.Create('BitmapFiletr accepts only 24Bit DIB');


  // �P���C�����s�N�Z���f�[�^��ێ����邽�߂̃o�b�t�@�����v�Z���܂��B
  // 10�����Ă���̂́A�}�g���b�N�X���r�b�g�}�b�v����͂ݏo�����Ƃ�
  // �l�����Ă��邩��ł��B
  BufSize := (Bitmap.Width + 10) * 3;
  LineSize := Bitmap.Width * 3;

  // �}�g���b�N�X���N���A
  FillChar(Mat, SizeOf(Mat), 0);

  // �V�����r�b�g�}�b�v�����
  NewBitmap := TBitmap.Create;
  try
    NewBitmap.Width := Bitmap.Width; NewBitmap.Height := Bitmap.Height;
    NewBitmap.PixelFormat := pf24bit;

    try
      // MatSvae ���쐬����BMaSave�̓r�b�g�}�b�v��11���C������
      // �X�L�������C����ێ�����BMatSave �̊e�s�� �r�b�g�}�b�v�̕�+10
      // �s�N�Z�����̑傫���ŁA6�s�N�Z���ڂ���r�b�g�}�b�v��
      // �X�L�������C�����R�s�[����B�܂�O��5�s�N�Z���͏�ɂO�ɂȂ�
      // MatSave[0][0] ��6���C���ڂ�6�s�N�Z���ڂ��A�N�Z�X���邱�ƂɂȂ�B
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
          // �t�B���^�̉��Z�������Ă�
          DestLine[x] := Filter(x, y, Mat, pData);
          // �}�g���b�N�X�̍s�|�C���^���P�s�N�Z�������炷
          for i := -5 to 5 do Mat[i] := PTriples(LongInt(Mat[i])+3);
        end;

        // MatSave �̓��e��1�s����ɃX�N���[������
        FreeMem(MatSave[-5]);
        MatSave[-5] := Nil;

        for i := -5 to 4 do MatSave[i] := MatSave[i+1];
        MatSave[5] := Nil;

        //�ŉ��s�Ɍ��̃r�b�g�}�b�v����X�L�������C����ǂݍ���
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
var MatSave,            // 11���C������Scanline��ێ�����o�b�t�@
    Mat: TTripleMatrix; // �s�N�Z�����󂯎�� 11x11 �̃}�g���b�N�X
    i: Integer;
    x, y: Integer;               // ���W
    NewBitmap: TBigBitmap;       // �쐬����r�b�g�}�b�v
    DestLine: PTripleArray;      // �V�����r�b�g�}�b�v�̃X�L�������C��
    LineSize, BufSize: Integer;  // �s�T�C�Y�ƃo�b�t�@�T�C�Y
begin
  // BitmapFilter �� 24bpp �����T�|�[�g���܂���B
  if Bitmap.PixelFormat <> bbPf24Bit then
    Raise Exception.Create('BitmapFiletr accepts only 24Bit DIB');


  // �P���C�����s�N�Z���f�[�^��ێ����邽�߂̃o�b�t�@�����v�Z���܂��B
  // 10�����Ă���̂́A�}�g���b�N�X���r�b�g�}�b�v����͂ݏo�����Ƃ�
  // �l�����Ă��邩��ł��B
  BufSize := (Bitmap.Width + 10) * 3;
  LineSize := Bitmap.Width * 3;

  // �}�g���b�N�X���N���A
  FillChar(Mat, SizeOf(Mat), 0);

  // �V�����r�b�g�}�b�v�����
  NewBitmap := TBigBitmap.Create;
  try
    NewBitmap.Width := Bitmap.Width; NewBitmap.Height := Bitmap.Height;
    NewBitmap.PixelFormat := bbpf24bit;

    try
      // MatSvae ���쐬����BMaSave�̓r�b�g�}�b�v��11���C������
      // �X�L�������C����ێ�����BMatSave �̊e�s�� �r�b�g�}�b�v�̕�+10
      // �s�N�Z�����̑傫���ŁA6�s�N�Z���ڂ���r�b�g�}�b�v��
      // �X�L�������C�����R�s�[����B�܂�O��5�s�N�Z���͏�ɂO�ɂȂ�
      // MatSave[0][0] ��6���C���ڂ�6�s�N�Z���ڂ��A�N�Z�X���邱�ƂɂȂ�B
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
          // �t�B���^�̉��Z�������Ă�
          DestLine[x] := Filter(x, y, Mat, pData);
          // �}�g���b�N�X�̍s�|�C���^���P�s�N�Z�������炷
          for i := -5 to 5 do Mat[i] := PTriples(LongInt(Mat[i])+3);
        end;

        // MatSave �̓��e��1�s����ɃX�N���[������
        FreeMem(MatSave[-5]);
        MatSave[-5] := Nil;

        for i := -5 to 4 do MatSave[i] := MatSave[i+1];
        MatSave[5] := Nil;

        //�ŉ��s�Ɍ��̃r�b�g�}�b�v����X�L�������C����ǂݍ���
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
