{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
unit DIBUtils;

interface

uses Windows, SysUtils, Classes;

// �r�b�g�}�b�v���̃T�C�Y
const BitmapInfoSize =
  SizeOf(TBitmapInfoHeader) + 259 * SizeOf(TRgbQuad);
type
  EDIBUtilsError = class(Exception);

  TDynamicByteArray = array of Byte;

  // DIB �̏���ێ����郌�R�[�h�ł��B
  // Bits:      �s�N�Z������ێ����铮�I�o�C�g�z��ł��B
  // W3Head:     Windows 3.1 �`���̃r�b�g�}�b�v�w�b�_�ł��B
  // W3HeadInfo: Windows 3.1 �`���̃r�b�g�}�b�v���ł��B
  // PMHead:     PM1.X �`���̃r�b�g�}�b�v�w�b�_�ł��B
  // PMHeadInfo: PM 1.X �`���̃r�b�g�}�b�v���ł��B
  // Dummy:      �J���[�e�[�u���̃G���A�m�ۂ̂��߂̃_�~�[�ł��B
  TSepDIB = record
    Bits: TDynamicByteArray;
    case Integer of
      1:(W3Head: TBitmapInfoHeader;);
      2:(W3HeadInfo: TBitmapInfo;);
      3:(PMHead: TBitmapCoreheader;);
      4:(PMHeadInfo: TBitmapCoreInfo;);
      5:(Dummy: array[0..BitmapInfoSize] of Byte;);
  end;

// �|�C���^���I�t�Z�b�g�����炷
function AddOffset(p: Pointer; Offset: LongInt): Pointer;


// �X�g���[������ DIB �� SepDIB���R�[�h�ɓǂݍ���
procedure LoadDIBFromStream(var SepDIB: TSepDIB; Stream: TStream);

// �X�g���[���� DIB �� SepDIB���R�[�h���珑������
procedure SaveDIBToStream(var SepDIB: TSepDIB; Stream: TStream);

// 16bpp/ 32bpp �� DIB �� 24bpp �ɕϊ�
procedure  DIB32_16ToDIB24(var OldSepDIB: TSepDIB;
                           var NewSepDIB: TSepDIB);

// 8Bit RLE -> 8Bit RGB  �ϊ�
procedure Convert8BitRLETo8BitRGB(var OldSepDIB: TSepDIB;
                                  var NewSepDIB: TSepDIB);
// 4Bit RLE -> 4Bit RGB  �ϊ�
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

// �s�N�Z���̃r�b�g�� ����F�������߂�B16/24/32 bpp �� �O��Ԃ��B
// biClrUsed ��␳����̂Ɏg���B
// biClrUsed �� �O�̏ꍇ�Ɏg�����Ɓi�d�v�I�j
function GetNumColors(BitCount: Integer): Integer;
begin
  if BitCount in [1, 4, 8] then
    Result := 1 shl BitCount
  else
    Result := 0;
end;


// �r�b�g�}�b�v���w�b�_�� PM1.X �`������ Windows 3.X �`���ɕϊ�����
procedure ConvertBitmapHeaderPMToW3(var PmSepDIB: TSepDIB);
var SepDIB: TSepDIB;
    i: Integer;
begin
  // PmSepDIB(PM �`�� BitmapInfo) ���� BitmapInfoHeader �����
  SepDIB.W3Head.biSize          := SizeOf(TBitmapInfoheader);
  SepDIB.W3Head.biWidth         := PMSepDIB.PMHead.bcWidth;
  SepDIB.W3Head.biHeight        := PMSepDIB.PMHead.bcHeight;
  SepDIB.W3Head.biPlanes        := PMSepDIB.PMHead.bcPlanes;
  SepDIB.W3Head.biBitCount      := PMSepDIB.PMHead.bcBitCount;
  SepDIB.W3Head.biCompression   := BI_RGB; // PM �`���Ɉ��k�͖����I�I
  SepDIB.W3Head.biSizeImage     := 0;
  SepDIB.W3Head.biXPelsPerMeter := 3780;  // 96dpi
  SepDIB.W3Head.biYPelsPerMeter := 3780;  // 96dpi
  // �J���[�e�[�u������ PM �ł� bcBitCount �Ō��܂�B
  SepDIB.W3Head.biClrUsed       := GetNumColors(PMSepDIB.PMHead.bcBitCount);
  SepDIB.W3Head.biClrImportant  := 0;


  // PM �� W3 �ł� �J���[�e�[�u���̌`�����Ⴄ�̂ŕϊ�����
  for i := 0 to SepDIB.W3Head.biClrUsed - 1 do begin
    SepDIB.W3HeadInfo.bmiColors[i].rgbRed :=
          PMSepDIB.PMHeadInfo.bmciColors[i].rgbtRed;
    SepDIB.W3HeadInfo.bmiColors[i].rgbGreen :=
          PMSepDIB.PMHeadInfo.bmciColors[i].rgbtGreen;
    SepDIB.W3HeadInfo.bmiColors[i].rgbBlue :=
          PMSepDIB.PMHeadInfo.bmciColors[i].rgbtBlue;
    SepDIB.W3HeadInfo.bmiColors[i].rgbReserved := 0;
  end;


  PMSepDIB := SepDIB;  // �ϊ����ʂ���������
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

// �X�g���[������ DIB �� SepDIB���R�[�h�ɓǂݍ���
procedure LoadDIBFromStream(var SepDIB: TSepDIB; Stream: TStream);
var
  bfh: TBitmapFileHeader;
  BitsSize: Integer;
  StreamPos: Integer;
begin
  // �X�g���[���̊J�n�ʒu���Z�[�u
  StreamPos := Stream.Position;

  // �t�@�C���w�b�_�[��ǂ�
  Stream.ReadBuffer(bfh, SizeOf(bfh));

  // �t�@�C���^�C�v���`�F�b�N
  if bfh.bfType <> $4D42 then
    RaiseError('LoadDIBFromStream: File type is invalid');

  // �s�N�Z�����̃������ʌv�Z
  BitsSize := bfh.bfSize - bfh.bfOffBits;

  // W3 �� PM ���𔻒f���邽�߃r�b�g�}�b�v�w�b�_�T�C�Y��ǂݍ���
  Stream.ReadBuffer(SepDIB.W3Head, SizeOf(DWORD));

  if SepDIB.W3Head.biSize >= SizeOf(TBitmapInfoHeader) then
  begin
    // Windows �`��
    // BitmapInfoHeader(V3, V4, V5) �̎c���ǂݍ���
    Stream.ReadBuffer(AddOffset(@SepDIB.W3Head, SizeOf(DWORD))^,
                      SepDIB.W3Head.biSize - SizeOf(DWORD));

    // �F�r�b�g���`�F�b�N
    if not (SepDIB.W3Head.biBitCount in [1, 4, 8, 16, 24, 32]) then
      RaiseError('LoadDIBFromStream: Invalid BitCout');

    // �F�������߂�B
    if SepDIB.W3Head.biClrUsed = 0 then
      SepDIB.W3Head.biClrUsed := GetNumColors(SepDIB.W3Head.biBitCount);

    // �J���[�e�[�u����ǂݍ���
    //------------------------------
    // Note:
    // �J���[�e�[�u���͐擪�� 3 DWORD �� BitFields ���܂ނ��Ƃ�����B
    // ���̏ꍇ�̓J���[�e�[�u���̑傫���� (3 + biClrUsed) ��
    // �Ȃ�̂Œ��ӂ��K�v�B�܂� biClrUsed ���Q�T�V�ȏ�ɂȂ邱�Ƃ��L�蓾��
    // �܂� V4, V5 �w�b�_�̃}�X�N�̎�舵���ɒ��ӁB�}�X�N�� V3 �ł�
    // �J���[�e�[�u���Ɋ܂܂�邪, V4, V5 �ł̓w�b�_�̒��ɂ���(�ʒu��V3�ƌ݊�)

    if SepDIB.W3Head.biCompression <> BI_BITFIELDS then begin
    // BitFields ���܂܂Ȃ��ꍇ
      if SepDIB.W3Head.biClrUsed <= 256 then
        // V3�w�b�_�̒���ɓǂݍ��ށBV4, V5 �̒ǉ��t�B�[���h�ׂ͒�
        Stream.ReadBuffer(
          AddOffset(@SepDIB.W3Head, SizeOf(TBitmapInfoHeader))^,
                    SepDIB.W3Head.biClrUsed * SizeOf(TRgbQuad))
      else begin
        // �J���[�e�[�u�����Q�T�U���傫����ΐ擪256�����g���B
        // V3�w�b�_�̒���ɓǂݍ��ށBV4, V5 �̒ǉ��t�B�[���h�ׂ͒�
        Stream.ReadBuffer(
          AddOffset(@SepDIB.W3Head, SizeOf(TBitmapInfoHeader))^,
                    256 * SizeOf(TRgbQuad));
      end;
    end
    else begin
    // BitFields ���܂ޏꍇ
      if SepDIB.W3Head.biSize = SizeOf(TBitmapInfoHeader) then // V3
      begin
        if SepDIB.W3Head.biClrUsed <= 256 then
        // �w�b�_�̒���ɓǂݍ��ށB�}�X�N12�o�C�g���������ēǂ�
          Stream.ReadBuffer(
            AddOffset(@SepDIB.W3Head, SizeOf(TBitmapInfoHeader))^,
                      (SepDIB.W3Head.biClrUsed+3) * SizeOf(TRgbQuad))
        else begin
          // �J���[�e�[�u�����Q�T�U���傫����ΐ擪256�����g���B
          // �w�b�_�̒���ɓǂݍ��ށB�}�X�N12�o�C�g���������ēǂ�
          Stream.ReadBuffer(
            AddOffset(@SepDIB.W3Head, SizeOf(TBitmapInfoHeader))^,
                      (256+3) * SizeOf(TRgbQuad));
        end;
      end
      else // V4 or V5
           // V4 or V5 �̃w�b�_�ł̓J���[�e�[�u���Ƀ}�X�N�͂Ȃ�
           // �w�b�_�Ɋ܂܂�Ă���
      begin
        // V4, V5�w�b�_�̃}�X�N�̒���ɓǂݍ��ށB V4, V5 �̃t�B�[���h�ׂ͒�
        if SepDIB.W3Head.biClrUsed <= 256 then
          Stream.ReadBuffer(
            AddOffset(@SepDIB.W3Head, SizeOf(TBitmapInfoHeader) +
                                        SizeOf(TRGBQuad) * 3)^,
                      (SepDIB.W3Head.biClrUsed) * SizeOf(TRgbQuad))
        else begin
          // �J���[�e�[�u�����Q�T�U���傫����ΐ擪256�����g���B
         // V4, V5�w�b�_�̃}�X�N�̒���ɓǂݍ��ށB V4, V5 �̃t�B�[���h�ׂ͒�
          Stream.ReadBuffer(
            AddOffset(@SepDIB.W3Head, SizeOf(TBitmapInfoHeader) +
                                        SizeOf(TRGBQuad) * 3)^,
                      256 * SizeOf(TRgbQuad));
        end;
      end;
    end;

    // �F������������Ȃ�Q�T�U�ɒ����B
    if SepDIB.W3Head.biClrUsed > 256 then
      SepDIB.W3Head.biClrUsed := 256;

    SepDIB.W3Head.biSize := SizeOf(TBitmapInfoHeader); // V3 �w�b�_�ɂ���
  end
  else if SepDIB.PMHead.bcSize = SizeOf(TBitmapCoreHeader) then begin
    // PM 1.X �`��
    // BitmapCoreHeader ��ǂݍ���
    Stream.ReadBuffer(AddOffset(@SepDIB.PMHead, SizeOf(DWORD))^,
                      SizeOf(TBitmapCoreHeader) - SizeOf(DWORD));

    // �F�r�b�g���`�F�b�N
    if not (SepDIB.PMHead.bcBitCount in [1, 4, 8, 24]) then
      RaiseError('TBigBitmap.LoadFromStream: Invalid BitCount');

    // �J���[�e�[�u����ǂݍ��ށBPM �`���̏ꍇ�� BitField ��������
    // �J���[�e�[�u���̑傫���� bcBitCount �Ŏ����I�Ɍ��܂�B
    Stream.ReadBuffer(
      Pointer(LongInt(@SepDIB.PMHead)+SizeOf(TBitmapCoreHeader))^,
      GetNumColors(SepDIB.PMHead.bcBitCount) * SizeOf(TRgbTriple));

    // �r�b�g�}�b�v�w�b�_�ƃJ���[�e�[�u���� Windows 3.X �`���ɕϊ�
    ConvertBitmapHeaderPmToW3(SepDIB);
  end
  else
    RaiseError('LoadDIBFromStream: Invalid Bitmap Header Size');

  // �s�N�Z���f�[�^�̐擪�Ɉړ�
  Stream.Position := StreamPos + bfh.bfOffBits;

  // �s�N�Z�����p���������m��
  SetLength(SepDIB.Bits, BitsSize);
  // �s�N�Z������ǂݍ���
  Stream.ReadBuffer(SepDIB.Bits[0], BitsSize);
end;


// �X�g���[���� DIB �� SepDIB���R�[�h���珑������
// DIB �� Windows �`��������
procedure SaveDIBToStream(var SepDIB: TSepDIB; Stream: TStream);
var
  bfh: TBitmapFileHeader;
  ColorCount: Integer;
begin
    // �J���[�e�[�u�������v�Z����
    ColorCount := SepDIB.W3Head.biClrUsed;
    if ColorCount = 0 then
      ColorCount := GetNumColors(SepDIB.W3Head.biBitCount);

    if SepDIB.W3Head.biCompression = BI_BITFIELDS then
      Inc(ColorCount, 3);

    // �t�@�C���w�b�_�𐮂���
    bfh.bfSize := SizeOf(bfh);
    bfh.bfType := $4D42;
    bfh.bfSize := SizeOf(bfh) + SizeOf(TBitmapInfoHeader) +
                  ColorCount*SizeOf(TRGBQuad) + 
                  Length(SepDIB.Bits);
    bfh.bfOffBits := SizeOf(bfh) + SizeOf(TBitmapInfoHeader) +
                     ColorCount*SizeOf(TRGBQuad);

    // �����I
    Stream.WriteBuffer(bfh, SizeOf(bfh));        // �t�@�C���w�b�_
    Stream.WriteBuffer(SepDIB.W3Head,          // �r�b�g�}�b�v����
                   SizeOf(TBitmapInfoHeader) +   // �J���[�e�[�u��
                   ColorCount*SizeOf(TRGBQuad));
    // �s�N�Z��
    Stream.WriteBuffer(SepDIB.Bits[0], Length(SepDIB.Bits));
end;

// BI_BITFIELDS �`���̃r�b�g�}�b�v�� �}�X�N�̃V�t�g�ʂ��v�Z����
// >0 �͉E�V�t�g <0 �͍��V�t�g��\���B
//  �}�X�N�l�� 128 �` 255(MSB ON) �ɂȂ�悤����V�t�g�ʂ��v�Z����
//    (Mask �� �O ������Ɩ\������̂Œ��ӁI�I)
function GetMaskShift(Mask: DWORD): Integer;
begin
  Result := 0;

  // Mask �� $100 �ȏ�Ȃ� �E�V�t�g�ʂ����߂�
  while Mask >= 256 do begin
    Mask := Mask shr 1;
    Result := Result +1;
  end;

  // Mask �� $80 �����Ȃ� ���V�t�g�ʂ����߂�i�}�C�i�X�l�j
  while Mask < 128 do begin
    Mask := Mask shl 1;
    Result := Result -1;
  end;
end;


// 16bpp/ 32bpp �� DIB �� 24bpp �ɕϊ�
procedure  DIB32_16ToDIB24(var OldSepDIB: TSepDIB;
                           var NewSepDIB: TSepDIB);
type
  // TrueColor �̃r�b�g�}�b�v�f�[�^�A�N�Z�X�p�̃��R�[�h�^�ł��B
  // Scanline Property �� TrueColor �̃f�[�^���A�N�Z�X����Ƃ��ɕ֗��ł��B
  TTriple = packed record
    B, G, R: Byte;
  end;
  // DWORD �z��A�N�Z�X�p�̌^�B16bpp/32bpp �p
  TDWordArray = array[0..100000000] of DWORD;
  PDWordArray = ^TDWordArray;
var
  SourceLineSize: Integer;         // 16/32 bpp �̃X�L�������C���T�C�Y
  DestLineSize: Integer;           // 24bpp �̃X�L�������C���T�C�Y
  BitsSize: Integer;               // 24bpp �̃s�N�Z���f�[�^��
  Masks: array[0..2] of DWORD;     // Masks[0]: Red Mask Masks[1]: Green Mask
                                   // Masks[2]: Blue Mask
  RShift, GShift, BShift: LongInt; // �}�X�N�̃V�t�g��
  MaxR, MaxG, MaxB: DWORD;         // BitFields �Ŏ��o���� R, G, B �l��
                                   // �␳�O�̍ő�l
  pTriple: ^TTriple;               // 24 bpp �X�L�������C���A�N�Z�X�p�|�C���^
                                   // 16/32 bpp -> 24 bpp �ϊ��p
  pConvert: Pointer;                // 16/32bpp -> 24bpp �ϊ��p�o�b�t�@
  i, j, w: LongInt;

begin
  // 16/32 bpp �̃X�L�������C���̒���
  if OldSepDIB.W3Head.biBitCount = 16 then
    SourceLineSize := ((OldSepDIB.W3Head.biWidth*2+3) div 4) * 4
  else
    SourceLineSize := ((OldSepDIB.W3Head.biWidth*4+3) div 4) * 4;

  // 24bpp �̃��C����
  DestLineSize   := ((OldSepDIB.W3Head.biWidth*3+3) div 4) * 4;

  // 24bpp �̃T�C�Y���v�Z
  BitsSize := DestLineSize * abs(OldSepDIB.W3Head.biHeight);

  // 24bpp �� Pixel �p���������m��
  SetLength(NewSepDIB.Bits, BitsSize);

  // �r�b�g�}�X�N�𓾂�
  if OldSepDIB.W3Head.biCompression = BI_RGB then begin
    // BitFields �������ꍇ
    // 16bpp �p�f�t�H���g�}�X�N�p�^���̍쐬�B
    if OldSepDIB.W3Head.biBitCount = 16 then begin
      Masks[0] := $7C00; Masks[1] := $03E0; Masks[2] := $001F;
    end
    else begin
    // 32bpp �p�f�t�H���g�}�X�N�p�^���̍쐬�B
      Masks[0] := $FF0000; Masks[1] := $00FF00; Masks[2] := $0000FF;
    end;
  end
  else begin
    // BitFields ���� �}�X�N�� Masks �փR�s�[�B
    Move(OldSepDIB.W3HeadInfo.bmiColors[0], Masks[0], SizeOf(DWORD)*3);
  end;

  // �}�X�N�����킩�`�F�b�N�B�r�b�g�̎������d�Ȃ�̓`�F�b�N���Ă��Ȃ�(^^
  // 0 ���`�F�b�N���Ă���̂� GetMaskShift ���\�����Ȃ��悤�ɂ��邽��
  if (Masks[0] = 0) or (Masks[1] = 0) or (Masks[2] = 0) then
    RaiseError('TBigBitmap.LoadFromStream: Invalid Masks');


  // �}�X�N��̃V�t�g�ʂ��v�Z
  RShift := GetMaskShift(Masks[0]);
  GShift := GetMaskShift(Masks[1]);
  BShift := GetMaskShift(Masks[2]);

  // �␳�O�� R, G, B �l�̍ő�l���v�Z
  if RShift >= 0 then MaxR := Masks[0] shr RShift
                 else MaxR := Masks[0] shl (-RShift);
  if GShift >= 0 then MaxG := Masks[1] shr GShift
                 else MaxG := Masks[1] shl (-GShift);
  if BShift >= 0 then MaxB := Masks[2] shr BShift
                 else MaxB := Masks[2] shl (-BShift);

  // �������� �ǂݍ��݃X�^�[�g

  for i := 0 to abs(OldSepDIB.W3Head.biHeight) -1 do begin

    pConvert := @OldSepDIB.Bits[SourceLineSize * i];

    // �ϊ�����v�Z
    pTriple := @NewSepDIB.Bits[DestLineSize * i];

    // ��������O�N���A���Ă��� �X�L�������C���̃p�f�B���O
    // ���O�ȊO�ɂȂ�̂�h�����߁B
    FillChar(AddOffset(pTriple, DestLineSize -4)^, 4, 0);

    w := OldSepDIB.W3Head.biWidth -1;

    if OldSepDIB.W3Head.biBitCount = 16 then
      // 16bpp �̏ꍇ
      for j := 0 to w do begin

         // 1 pixel �ϊ�
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
      // 32 bpp �̏ꍇ
      for j := 0 to w do begin
         // 1 pixel �ϊ�
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

  // �S�s�N�Z���͕ϊ��ł����̂ō��x�� �r�b�g�}�b�v��������������
  NewSepDIB.Dummy := OldSepDIB.Dummy;
  with NewSepDIB.W3Head do begin
    // �J���[�e�[�u���̈ʒu��␳
    if biCompression = BI_BITFIELDS then
      for i := 0 to 255 do
        with NewSepDIB.W3HeadInfo do
          bmiColors[i] := bmiColors[i+3];

    // �w�b�_��␳ 24bpp �ɂ���
    biCompression := BI_RGB;
    biBitCount := 24;
    biSizeImage := 0;
  end;
end;


// 4Bit RLE -> 4Bit RGB  �ϊ�
procedure Convert4BitRLETo4BitRGB(var OldSepDIB: TSepDIB;
                                  var NewSepDIB: TSepDIB);
var
  i: Integer;
  x, y: Integer;                      // ���W
  LineLength,                         // 4Bit RGB �̃X�L�������C���̒���
  BitsSize,                           // �ϊ���̃r�b�g�}�b�v�f�[�^�̃T�C�Y
  Width, Height: Integer;             // �r�b�g�}�b�v�̑傫��
  Width2: Integer;                    // Width �������ɐ؂�グ������
  Count,                              // Encode Mode �̃s�N�Z���l
  Color: BYTE;                        // Encode Mode �� Color Index
                                      // Absolute Mode �̃s�N�Z�����B
  Bits: TDynamicByteArray;
  pSourceByte,                        // �ϊ����f�[�^�ւ̃|�C���^
  pDestByte,                              // �ϊ���f�[�^�ւ̃|�C���^
  pTemp: PByte;

begin
  // ��DIB �� 4BitRLE ���`�F�b�N
  if (OldSepDIB.W3Head.biBitCount <> 4) or
     (OldSepDIB.W3Head.biCompression <> BI_RLE4) then
    RaiseError('Convert4BitRLETo4BitRGB: ' +
               'Invalid Bitcount & Compression Combination');

  // �������̂��� Width �� Height ��ϐ��ɓ����B
  Width := OldSepDIB.W3Head.biWidth;
  Height := abs(OldSepDIB.W3Head.biHeight);

  //�X�L�������C���̒������v�Z
  LineLength := ((Width * 4 + 31) div 32) * 4;

  // Pixel �f�[�^�̑傫�����v�Z�B
  BitsSize   :=  LineLength * Height;

  // �s�N�Z�����p�������i�o�͐�j���m��
  SetLength(Bits, BitsSize);
  // ���W�����Z�b�g
  x := 0; y := 0;

  // ���^�V DIB �̃s�N�Z�����ւ̃|�C���^��ݒ�
  pSourceByte := PByte(OldSepDIB.Bits);
  pDestByte := PBYTE(Bits);


  // 4Bit RLE �̏ꍇ�A ������s�N�Z���̏ꍇ�A1�s�N�Z���]���� Encode
  // �����P�[�X������B���̂��߁A���̃`�F�b�N�������s�N�Z������
  // �s���悤�ɂ���B
  //
  // Note: �{���s���ȃr�b�g�}�b�v���� ���Ȃ�̐������݂���̂ł�������Ȃ��B
  //       Windows API �����������Ȃ��悤��(StretchDIBits �Ȃ�)
  Width2 := ((Width + 1) div 2) * 2;

  while True do begin
    //�Q�o�C�g�ǂ�
    Count := pSourceByte^; Inc(pSourceByte);
    Color := pSourceByte^; Inc(pSourceByte);

    if Count = 0 then begin // if RLE_ESCAPE
      case Color of
        1{End Of Bitmap}: Break;
        0{End Of Line  }: begin
          // ���W�Əo�͐�|�C���^�����̃��C���ɐݒ�
          x := 0; Inc(y);
          pDestByte := @Bits[LineLength * y];
          if y > Height then
            RaiseError('Convert4BitRLETo4BitRGB: Bad RLE Data 5');
        end;
        2{Delta}: begin
          // Delta �̓A�j���[�V�����p�Ȃ̂ŁA�r�b�g�}�b�v�t�@�C���ɂ�
          // �܂܂�Ȃ��͂������A�ꉞ����
          // �X�L�b�v�ʂ�ǂݍ��݁A���W�Əo�͐��␳
          Inc(x, pSourceByte^); Inc(pSourceByte);
          Inc(y, pSourceByte^); Inc(pSourceByte);
          pDestByte := @Bits[LineLength * y + x];
          if (x > Width2) or (y > Height) then
            RaiseError('Convert4BitRLETo4BitRGB: Bad RLE Data 6');
        end;
        else begin // Absolute Mode, Color is Number of Colors to be copied!
          if (x + Color > Width2) or (y >= Height) then
            RaiseError('Convert4BitRLETo4BitRGB: Bad RLE Data 7');

          // ��΃��[�h�A�Q�o�C�g�ڂ̐��������A�s�N�Z���l���R�s�[
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
          // ���͌��|�C���^��WORD ���E�Ɉʒu����悤�ɍX�V����B
          Inc(pSourceByte, ((Color * 4 + 15) div 16) * 2);
          Inc(x, Color);
        end;
      end;
    end
    else begin
      // Encoded Mode
      if (x + Count > Width2) or (y >= Height) then
        RaiseError('Convert4BitRLETo4BitRGB: Bad RLE Data 8');

      // Count ���������AColor ���o��
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

  // ������
  NewSepDIB := OldSepDIB;
  NewSepDIB.Bits := Bits;
  NewSepDIB.W3Head.biBitCount := 4;            // 4Bit �񈳏k
  NewSepDIB.W3Head.biCompression := BI_RGB;
  NewSepDIB.W3Head.biSizeImage := 0;
end;

// 8Bit RLE -> 8Bit RGB  �ϊ�
procedure Convert8BitRLETo8BitRGB(var OldSepDIB: TSepDIB;
                                  var NewSepDIB: TSepDIB);
var
  x, y: Integer;                      // ���W
  LineLength,                         // 8Bit RGB �̃X�L�������C���̒���
  BitsSize,                           // �ϊ���̃r�b�g�}�b�v�f�[�^�̃T�C�Y
  Width, Height: Integer;             // �r�b�g�}�b�v�̑傫��
  Bits: TDynamicByteArray;
  Count,                              // �s�N�Z����
  Color: BYTE;                        // �J���[�C���f�b�N�X(Encode)/
                                      // �s�N�Z����(Absolute)
  pSourceByte, pDestByte: PBYTE;      // �ϊ����f�[�^�ւ̃|�C���^
begin
  // ��DIB �� 8BitRLE ���`�F�b�N
  if (OldSepDIB.W3Head.biBitCount <> 8) or
     (OldSepDIB.W3Head.biCompression <> BI_RLE8) then
    RaiseError('Convert8BitRLETo8BitRGB: ' +
               'Invalid Bitcount & Compression Combination');

  // �������̂��� Width �� Height ��ϐ��ɓ����B
  Width := OldSepDIB.W3Head.biWidth;
  Height := abs(OldSepDIB.W3Head.biHeight);

  //�X�L�������C���̒������v�Z
  LineLength := ((Width * 8 + 31) div 32) * 4;

  // Pixel �f�[�^�̑傫�����v�Z�B
  BitsSize   :=  LineLength * Height;

  // �s�N�Z�����p�������i�o�͐�j���m��
  SetLength(Bits, BitsSize);
  // ���W�����Z�b�g
  x := 0; y := 0;

  // ���^�V DIB �̃s�N�Z�����ւ̃|�C���^��ݒ�
  pSourceByte := PByte(OldSepDIB.Bits);
  pDestByte := PByte(Bits);

  while True do begin
    // 2 Byte �ǂ�
    Count := pSourceByte^; Inc(pSourceByte);
    Color := pSourceByte^; Inc(pSourceByte);

    if Count = 0 then begin // if RLE_ESCAPE
      case Color of
        1{End Of Bitmap}: Break;
        0{EndOf Line  }: begin
          // ���W�Əo�͐�|�C���^�����̃��C���ɐݒ�
          x := 0; Inc(y);
          pDestByte := @Bits[LineLength * y];
          if y > Height then
            RaiseError('Convert8BitRLETo8BitRGB: Bad RLE Data 1');
        end;
        2{Delta}: begin
          // Delta �̓A�j���[�V�����p�Ȃ̂ŁA�r�b�g�}�b�v�t�@�C���ɂ�
          // �܂܂�Ȃ��͂������A�ꉞ����
          // �X�L�b�v�ʂ�ǂݍ��݁A���W�Əo�͐��␳
          Inc(x, pSourceByte^); Inc(pSourceByte);
          Inc(y, pSourceByte^); Inc(pSourceByte);
          pDestByte := @Bits[LineLength * y + x];
          if (x > Width) or (y > Height) then
            RaiseError('Convert8BitRLETo8BitRGB: Bad RLE Data 2');
        end;
        else begin // Absolute Mode, Color is Number of Colors to be copied!
          if (x + Color > Width) or (y >= Height) then
            RaiseError('Convert8BitRLETo8BitRGB: Bad RLE Data 3');
          // ��΃��[�h�A�Q�o�C�g�ڂ̐��������A�s�N�Z���l���R�s�[
          System.Move(pSourceByte^, pDestByte^, Color);

          // ���͌��|�C���^��WORD ���E�Ɉʒu����悤�ɍX�V����B
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
      // Count ���������AColor ���o��
      FillChar(pDestByte^, Count, Color);
      Inc(x, Count);
      Inc(pDestByte, Count);
    end;
  end;

  // ������
  NewSepDIB := OldSepDIB;
  NewSepDIB.Bits := Bits;
  NewSepDIB.W3Head.biBitCount := 8;            // 8Bit �񈳏k
  NewSepDIB.W3Head.biCompression := BI_RGB;
  NewSepDIB.W3Head.biSizeImage := 0;
end;


end.
