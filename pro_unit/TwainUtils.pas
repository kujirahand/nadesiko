{==============================================================================
                        TwainUtils
[���C�Z���X]
  �{�\�t�g�E�F�A�� LGPL2(not 2.1) �Ŕz�z����Ă��܂��B

  �E���ۏ�
    �ύX�҂͖{�\�t�g�E�F�A�̎g�p�ɋN�����邠���鑹�Q�E��Q�ɂ��Ă��̐ӔC��
    ��ؕ���Ȃ����̂Ƃ��܂��B�܂��o�O�C���̋`���𕉂�Ȃ����̂Ƃ��܂��B
  �E�g�p����
    ���p�A�񏤗p���킸���R�Ɏg�p���Ă��܂��܂���B�g�p�\�����K�v����܂���B
  �E�A�[�J�C�u�̕ύX
    �Ǝ��A�[�J�C�u�Ɋ܂߂čĔz�z���Ă����܂��܂���B���𓾂�K�v������܂���B
  �E���ϔł�z�z�������
    �ȉ���[�ύX����]�ɕύX�_�A�ύX�҂��L���̏� LGPL2 �Ŕz�z���Ă��������B

  �E���Ă͂����Ȃ�����
    �{�\�t�g�E�F�A�܂��͉��ϔł����C�Z���X��ύX����(LGPL2 �ȊO��)�z�z���邱�ƁB

[�ύX����]
v1.04   2004/11/20 t_kumagai@ot.olympus.co.jp(http://kuma.webj.net/)
  �E�s�v�� Variants �폜�A�\���̂� packed �֕ύX
v1.03   2003/12/24 t_kumagai@ot.olympus.co.jp(http://kuma.webj.net/)
  �ETBigBitmap(������j��)�Ή� USE_BIGBITMAP, USE_BIGBITMAP_FAST
  �ETransferImage (ImageNativeXfer) �s�N�Z���t�H�[�}�b�g���擾 DIB �ɂ��킹��
    �悤�Ɏd�l�ύX�BUSE_BIGBITMAP(_FAST) ���Ǝd�l�𑵂��邽�߁B
  �E�X�L�����ATWAIN �\�[�X�ύX�A�X�L�������� TWCC_SEQERROR ���o��o�O���C��
v1.02   2003/03/10 t_kumagai@ot.olympus.co.jp(http://kuma.webj.net/)
  �E�u�s���ȕ��������_���Z�v���N���� TWAIN �h���C�o�ǉ��΍�
v1.01   2003/02/01 t_kumagai@ot.olympus.co.jp(http://kuma.webj.net/)
  �E�u�s���ȕ��������_���Z�v���N���� TWAIN �h���C�o�΍�
v1.00   2003/01/22 t_kumagai@ot.olympus.co.jp(http://kuma.webj.net/)
  �E�V�K�쐬
==============================================================================}
unit TwainUtils;

interface

{$IFDEF USE_BIGBITMAP_FAST}
  {$DEFINE USE_BIGBITMAP}
{$ENDIF}

uses
{$IFDEF USE_BIGBITMAP}
  BigBitmap, DIBUtils,
{$ENDIF}
  Windows, Classes, Forms, SysUtils, Graphics, twain;

type
{$IFDEF USE_BIGBITMAP}
  TBitmap = TBigBitmap;
{$ENDIF}
  TTwain = class
  private
    HandleWnd: HWND;
    procedure RaiseError(pDest: pTW_IDENTITY);
  protected
    function CallDSMEntry(pOrigin, pDest: pTW_IDENTITY;
      DG: TW_UINT32; DAT: TW_UINT16; MSG: TW_UINT16; pData: TW_MEMREF): TW_UINT16;
    function CallDSM(pDest: pTW_IDENTITY;
      DG: TW_UINT32; DAT: TW_UINT16; MSG: TW_UINT16; pData: TW_MEMREF): TW_UINT16;
    function SafeCallDSM(pDest: pTW_IDENTITY;
      DG: TW_UINT32; DAT: TW_UINT16; MSG: TW_UINT16; pData: TW_MEMREF): TW_UINT16;
    procedure OpenDSM(Parent: HWND);
    procedure CloseDSM;
    procedure OpenDS;
    procedure CloseDS;
    function UserSelect: TW_UINT16;
    procedure EnableDS(ShowUI, ModalUI: Boolean; Parent: THandle);
    procedure DisableDS;
    procedure ImageNativeXfer(Bitmap: TBitmap);
    function GetLastErrorMessage(pDest: pTW_IDENTITY): string;
  public
    AppId: TW_IDENTITY;
    SrcId: TW_IDENTITY;
    DSMOpened: Boolean;
    DSOpened: Boolean;
    DSEnabled: Boolean;
    constructor Create;
    destructor Destroy; override;
    function TransferImage(Bitmap: TBitmap; UI: Boolean = True; Parent: THandle = 0): Boolean;
    function SelectDevice(Parent: THandle): Boolean;
    function GetFloatValue(Cap: TW_UINT16): Double;
    procedure SetFloatValue(Cap: TW_UINT16; NewValue: Double);
  end;

function Fix32ToFloat(fix32: TW_FIX32): Double;
function FloatToFix32(Floater: Double): TW_FIX32;
function GetDIBBitCount(PDIB: Pointer): DWORD;
function BitToColorTableCount(Bit: DWORD): DWORD;
function IsBitmapInfoHeader(PDIB: Pointer): Boolean;
function GetDIBColorTableCount(PDIB: Pointer): DWORD;
function GetDIBWidth(PDIB: Pointer): Integer;
function GetDIBHeight(PDIB: Pointer): Integer;
procedure FreeTwain;

function TwainDevice: TTwain;

implementation

var
  FInstanceCount: Integer;
  Lib: THandle;
  DSM_Entry: DSMENTRYPROC;
  FTwain: TTwain;

function TwainDevice: TTwain;
begin
  if (not Assigned(FTwain)) then
    FTwain := TTwain.Create;
  Result := FTwain;
end;

function Fix32ToFloat(fix32: TW_FIX32): Double;
// TW_FIX32 -> Double
begin
  Result := fix32.Whole + fix32.Frac / 65536;
end;

function FloatToFix32(Floater: Double): TW_FIX32;
// Double -> TW_FIX32
  function RoundOff(X: Double): Integer;
  begin
    if (X >= 0) then
      Result := Trunc(X + 0.5)
    else
      Result := Trunc(X - 0.5);
  end;
var
  Value: TW_INT32;
begin
  Value := RoundOff(Floater * 65536);
  Result.Whole := Value shr 16;
  Result.Frac := Value and $FFFF;
end;

function GetDIBBitCount(PDIB: Pointer): DWORD;
// Bitmap �w�b�_�[����r�b�g�����擾
begin
  if (IsBitmapInfoHeader(PDIB)) then
    Result := PBitmapInfoHeader(PDIB).biBitCount
  else
    Result := PBitmapCoreHeader(PDIB).bcBitCount;
end;

function BitToColorTableCount(Bit: DWORD): DWORD;
// �r�b�g������J���[�e�[�u���T�C�Y�̎擾
// 8�r�b�g����̓J���[�e�[�u������
begin
  if (Bit > 8) then
    Result := 0
  else
    Result := 1 shl Bit;
end;

function IsBitmapInfoHeader(PDIB: Pointer): Boolean;
// True:  BitmapInfoHeader
// False: BitmapCoreHeader
begin
  Result := PBitmapInfoHeader(PDIB).biSize <> SizeOf(BITMAPCOREHEADER);
end;

function GetDIBColorTableCount(PDIB: Pointer): DWORD;
// �J���[�e�[�u���T�C�Y�̎擾
// 0(24bit�ȏ�), 2(1bit), 16(4bit), 256(8bit)
begin
  if (IsBitmapInfoHeader(PDIB)) then
  begin
    Result := PBitmapInfoHeader(PDIB).biClrUsed;
    if (Result <> 0) then
      Exit;
  end;

  Result := BitToColorTableCount(GetDIBBitCount(PDIB));
end;

function GetDIBWidth(PDIB: Pointer): Integer;
// �r�b�g�}�b�v�����擾
begin
  if (IsBitmapInfoHeader(PDIB)) then
    Result := PBitmapInfoHeader(PDIB).biWidth
  else
    Result := PBitmapCoreHeader(PDIB).bcWidth;
end;

function GetDIBHeight(PDIB: Pointer): Integer;
// �r�b�g�}�b�v�������擾
begin
  if (IsBitmapInfoHeader(PDIB)) then
    Result := PBitmapInfoHeader(PDIB).biHeight
  else
    Result := PBitmapCoreHeader(PDIB).bcHeight;
end;

procedure InitializeTwain;
// TWAIN ������
const
  TWAIN_DLL = 'TWAIN_32.DLL';
begin
  Lib := LoadLibrary(TWAIN_DLL);
  if (Lib = 0) then
    raise Exception.Create(TWAIN_DLL + '��������܂���');

  DSM_Entry := DSMENTRYPROC(GetProcAddress(Lib, 'DSM_Entry'));
  Assert(Assigned(DSM_Entry));
end;

procedure TerminateTwain;
// TWAIN �I������
begin
  FreeLibrary(Lib);
end;

{ TTwain }
constructor TTwain.Create;
// TWAIN �h���C�o�쐬
begin
  inherited;
  if (FInstanceCount = 0) then
    InitializeTwain;
  Inc(FInstanceCount);
  ZeroMemory(@AppId, SizeOf(AppId));
  ZeroMemory(@SrcID, SizeOf(SrcID));
  AppId.Id := 0;
  AppId.ProtocolMajor := TWON_PROTOCOLMAJOR;
  AppId.ProtocolMinor := TWON_PROTOCOLMINOR;
  AppId.SupportedGroups := DG_IMAGE or DG_CONTROL;

  AppId.Version.MajorNum := 0;
  AppId.Version.MinorNum := 0;
  AppId.Version.Language := TW_UINT16(TWLG_USERLOCALE);
  AppId.Version.Country := TWCY_JAPAN;
  AppId.Version.Info := 'VERSION INFO';
  AppId.Manufacturer := 'MANUFACTURER';
  AppId.ProductFamily := 'PRODUCT FAMILY';
  AppId.ProductName := 'PRODUCT NAME';
end;

destructor TTwain.Destroy;
// TWAIN �h���C�o�J��
begin
  inherited;
  try
    if (DSEnabled) then DisableDS;
    if (DSOpened) then CloseDS;
    if (DSMOpened) then CloseDSM;
  except
    //Application.HandleException(Self);
  end;
  Dec(FInstanceCount);
  if (FInstanceCount = 0) then
    TerminateTwain;
end;

function TTwain.CallDSMEntry(pOrigin, pDest: pTW_IDENTITY;
  DG: TW_UINT32; DAT: TW_UINT16; MSG: TW_UINT16; pData: TW_MEMREF): TW_UINT16;
// TWAIN API �Ăяo��
var
  Saved8087CW: Word;
begin
  Saved8087CW := Default8087CW;
  Set8087CW($133F);  { FPU ��O���ׂĖ��� }
  try
    Result := DSM_Entry(pOrigin, pDest, DG, DAT, MSG, pData);
  finally
    Set8087CW(Saved8087CW);
  end;
end;

function TTwain.CallDSM(pDest: pTW_IDENTITY; DG: TW_UINT32; DAT,
  MSG: TW_UINT16; pData: TW_MEMREF): TW_UINT16;
// TWAIN API �Ăяo��
begin
  Result := CallDSMEntry(@AppId, pDest, DG, DAT, MSG, pData);
end;

function TTwain.SafeCallDSM(pDest: pTW_IDENTITY; DG: TW_UINT32; DAT,
  MSG: TW_UINT16; pData: TW_MEMREF): TW_UINT16;
// TWAIN API �Ăяo��(�߂�l�`�F�b�N�L��)
begin
  Result := CallDSM(pDest, DG, DAT, MSG, pData);
  if (Result <> TWRC_SUCCESS) then
    RaiseError(pDest);
end;

procedure TTwain.OpenDSM(Parent: HWND);
// Data Source Manager �I�[�v��
begin
  HandleWnd := Parent;
  SafeCallDSM(nil, DG_CONTROL, DAT_PARENT, MSG_OPENDSM, @HandleWnd);
  DSMOpened := True;
end;

procedure TTwain.CloseDSM;
// Data Source Manager �N���[�Y
begin
  SafeCallDSM(nil, DG_CONTROL, DAT_PARENT, MSG_CLOSEDSM, @HandleWnd);
  DSMOpened := False;
end;

procedure TTwain.OpenDS;
// Data Source �I�[�v��
begin
  SafeCallDSM(nil, DG_CONTROL, DAT_IDENTITY, MSG_OPENDS, @SrcID);
  DSOpened := True;
end;

procedure TTwain.CloseDS;
// Data Source �N���[�Y
begin
  SafeCallDSM(nil, DG_CONTROL, DAT_IDENTITY, MSG_CLOSEDS, @SrcId);
  DSOpened := False;
end;

function TTwain.UserSelect: TW_UINT16;
// TWAIN �f�o�C�X�I��
begin
  Result := CallDSM(nil, DG_CONTROL, DAT_IDENTITY, MSG_USERSELECT, @SrcId);
end;

procedure TTwain.EnableDS(ShowUI, ModalUI: Boolean; Parent: THandle);
// Data Source �L��
const
  TF: array [Boolean] of TW_BOOL = (0, 1);
var
  UI: TW_USERINTERFACE;
begin
  UI.ShowUI := TF[ShowUI];
  UI.ModalUI := TF[ModalUI];
  UI.hParent := Parent;
  SafeCallDSM(@SrcId, DG_CONTROL, DAT_USERINTERFACE, MSG_ENABLEDS, @UI);
  DSEnabled := True;
end;

procedure TTwain.DisableDS;
// Data Source ����
var
  UI: TW_USERINTERFACE;
begin
  UI.ShowUI := 0;
  UI.ModalUI := 0;
  UI.hParent := 0;
  SafeCallDSM(@SrcId, DG_CONTROL, DAT_USERINTERFACE, MSG_DISABLEDS, @UI);
  DSEnabled := False;
end;

procedure TTwain.ImageNativeXfer(Bitmap: TBitmap);
// �L���� Data Source ���� Bitmap �փf�[�^�]��
  procedure SetDIBitsToBitmap(Bitmap: TBitmap; PDIB: PBitmapInfoHeader; DIBSize: Integer);
  var
  {$IFDEF USE_BIGBITMAP_FAST}
    BitCount: Integer;
    ScanLineLength: Integer;
    SepDIB: TSepDIB;
    Y: Integer;
  {$ENDIF}
    TS: DWORD;
    Bits: PByteArray;
    W, H: Integer;
    Stream: TMemoryStream;
  begin
    W := GetDIBWidth(PDIB);
    H := GetDIBHeight(PDIB);
    Bitmap.Width := Abs(W);
    Bitmap.Height := Abs(H);
    TS := GetDIBColorTableCount(PDIB) * SizeOf(RGBQUAD);
    Bits := Pointer(DWORD(PDIB) + PDIB.biSize + TS);

{$IFNDEF USE_BIGBITMAP_FAST}
    // �X�g���[���o�R
    Stream := TMemoryStream.Create;
    try
      Stream.Size := SizeOf(TBitmapFileHeader) + DIBSize;
      with (PBitmapFileHeader(Stream.Memory)^) do
      begin
        bfType := $4D42;
        bfSize := Stream.Size;
        bfReserved1 := 0;
        bfReserved2 := 0;
        bfOffBits := SizeOf(BitmapFileHeader) + DWORD(Bits) - DWORD(PDIB);
      end;
      Move(PDIB^, (PChar(Stream.Memory) + SizeOf(TBitmapFileHeader))^, DIBSize);
      Stream.Position := 0;
      Bitmap.LoadFromStream(Stream);
    finally
      Stream.Free;
    end;
{$ELSE}
    BitCount := GetDIBBitCount(PDIB);
    // �X�L�������C����
    ScanLineLength := (Abs(W) * BitCount + 31) div 32 * 4;
    // �t�H�[�}�b�g�ݒ�
    case (BitCount) of
     1: Bitmap.PixelFormat := bbpf1bit;
     4: Bitmap.PixelFormat := bbpf4bit;
     8: Bitmap.PixelFormat := bbpf8bit;
    24: Bitmap.PixelFormat := bbpf24bit;
    end;

    // �p���b�g�ݒ�
    Stream := TMemoryStream.Create;
    try
      Stream.Size := SizeOf(BitmapFileHeader) + DWORD(Bits) - DWORD(PDIB);
      with (PBitmapFileHeader(Stream.Memory)^) do
      begin
        bfType := $4D42;
        bfSize := Stream.Size;
        bfReserved1 := 0;
        bfReserved2 := 0;
        bfOffBits := Stream.Size;
      end;
      Move(PDIB^, (PChar(Stream.Memory) + SizeOf(TBitmapFileHeader))^, Stream.Size);
      LoadDIBFromStream(SepDIB, Stream);
      Bitmap.Palette := CreatePaletteFromDIB(SepDIB);
    finally
      Stream.Free;
    end;

    // �s�N�Z���]��
    if (H > 0) then
      for Y := 0 to Abs(H) - 1 do
        Move(Bits[(H - 1 - Y) * ScanLineLength], Bitmap.ScanLine[Y]^, ScanLineLength)
    else
      for Y := 0 to Abs(H) - 1 do
        Move(Bits[Y * ScanLineLength], Bitmap.ScanLine[Y]^, ScanLineLength);
{$ENDIF}
  end;
var
  RC: TW_UINT16;
  hBitmap: TW_UINT32;
  PDIB: PBitmapInfoHeader;
  PendingXfer: TW_BOOL;
begin
  RC := CallDSM(@SrcId, DG_IMAGE, DAT_IMAGENATIVEXFER, MSG_GET, @hBitmap);
  PDIB := PBitmapInfoHeader(GlobalLock(hBitmap));
  if (not Assigned(PDIB)) then
    RaiseError(@SrcId);

  try
    case (RC) of
    TWRC_XFERDONE:
      begin
        // �]������
        SetDIBitsToBitmap(Bitmap, PDIB, GlobalSize(hBitmap));

        // �]���I������
        SafeCallDSM(@SrcId,
          DG_CONTROL, DAT_PENDINGXFERS, MSG_ENDXFER,
          @PendingXfer);
      end;
    TWRC_CANCEL:
      raise Exception.Create('�L�����Z������܂���');
    TWRC_FAILURE:
      raise Exception.Create('�]�����ɃG���[����');
    end;
  finally
    GlobalUnlock(hBitmap);
    GlobalFree(hBitmap);
  end;
end;

function TTwain.GetFloatValue(Cap: TW_UINT16): Double;
// �l�̎擾
var
  Capability: TW_CAPABILITY;
  POneValue: pTW_ONEVALUE;
begin
  Result := 0;
  Capability.Cap := Cap;
  Capability.ConType := TWON_ONEVALUE;
  Capability.hContainer := 0;

  SafeCallDSM(@SrcId, DG_CONTROL, DAT_CAPABILITY, MSG_GET, @Capability);

  if (Capability.hContainer <> 0) then
  begin
    POneValue := pTW_ONEVALUE(GlobalLock(Capability.hContainer));
    Result := Fix32ToFloat(TW_FIX32(POneValue.Item));
    GlobalUnlock(Capability.hContainer);
    GlobalFree(Capability.hContainer);
  end;
end;

procedure TTwain.SetFloatValue(Cap: TW_UINT16; NewValue: Double);
// �l�̐ݒ�
var
  Capability: TW_CAPABILITY;
  POneValue: pTW_ONEVALUE;
  TW: TW_FIX32;
begin
  Capability.hContainer := GlobalAlloc(GHND, SizeOf(TW_ONEVALUE));
  POneValue := pTW_ONEVALUE(GlobalLock(Capability.hContainer));
  try
    POneValue.ItemType := TWTY_FIX32;
    TW := FloatToFix32(NewValue);
    Move(TW, POneValue.Item, SizeOf(TW));

    Capability.Cap := Cap;
    Capability.ConType := TWON_ONEVALUE;

    SafeCallDSM(@SrcId, DG_CONTROL, DAT_CAPABILITY, MSG_SET, @Capability);
  finally
    GlobalUnlock(Capability.hContainer);
    GlobalFree(Capability.hContainer);
  end;
end;

function TTwain.GetLastErrorMessage(pDest: pTW_IDENTITY): string;
// �G���[���b�Z�[�W�̎擾
const
  ErrorMessages: array [0..22-1] of TIdentMapEntry = (
    (Value: TWCC_SUCCESS          ; Name: 'It worked!'),
    (Value: TWCC_BUMMER           ; Name: 'Failure due to unknown causes'),
    (Value: TWCC_LOWMEMORY        ; Name: 'Not enough memory to perform operation'),
    (Value: TWCC_NODS             ; Name: 'No Data Source'),
    (Value: TWCC_MAXCONNECTIONS   ; Name: 'DS is connected to max possible applications'),
    (Value: TWCC_OPERATIONERROR   ; Name: 'DS or DSM reported error, application shouldn''t'),
    (Value: TWCC_BADCAP           ; Name: 'Unknown capability'),
    (Value: TWCC_BADPROTOCOL      ; Name: 'Unrecognized MSG DG DAT combination'),
    (Value: TWCC_BADVALUE         ; Name: 'Data parameter out of range'),
    (Value: TWCC_SEQERROR         ; Name: 'DG DAT MSG out of expected sequence'),
    (Value: TWCC_BADDEST          ; Name: 'Unknown destination Application/Source in DSM_Entry'),
    (Value: TWCC_CAPUNSUPPORTED   ; Name: 'Capability not supported by source'),
    (Value: TWCC_CAPBADOPERATION  ; Name: 'Operation not supported by capability'),
    (Value: TWCC_CAPSEQERROR      ; Name: 'Capability has dependancy on other capability'),
    (Value: TWCC_DENIED           ; Name: 'File System operation is denied (file is protected)'),
    (Value: TWCC_FILEEXISTS       ; Name: 'Operation failed because file already exists.'),
    (Value: TWCC_FILENOTFOUND     ; Name: 'File not found'),
    (Value: TWCC_NOTEMPTY         ; Name: 'Operation failed because directory is not empty'),
    (Value: TWCC_PAPERJAM         ; Name: 'The feeder is jammed'),
    (Value: TWCC_PAPERDOUBLEFEED  ; Name: 'The feeder detected multiple pages'),
    (Value: TWCC_FILEWRITEERROR   ; Name: 'Error writing the file (meant for things like disk full conditions)'),
    (Value: TWCC_CHECKDEVICEONLINE; Name: 'The device went offline prior to or during this operation')
  );
var
  Status: TW_STATUS;
begin
  CallDSM(@SrcId, DG_CONTROL, DAT_STATUS, MSG_GET,@Status);

  IntToIdent(Status.ConditionCode, Result, ErrorMessages);
end;

procedure TTwain.RaiseError(pDest: pTW_IDENTITY);
// ��O����
begin
  raise Exception.Create('TWAIN: ' + GetLastErrorMessage(pDest));
end;


function TTwain.TransferImage(Bitmap: TBitmap; UI: Boolean = True; Parent: THandle = 0): Boolean;
// TWAIN �@�킩��̎捞
// Bitmap : �捞�� TBitmap
// UI     : True: �_�C�A���O�\��
// Parent : �_�C�A���O�̐e�E�B���h�E
  function GetTWMessage(const M: MSG; var TWMsg: TW_UINT16): Boolean;
  var
    Event: TW_EVENT;
    RC: TW_UINT16;
  begin
    Event.pEvent := @M;
    RC := CallDSM(@SrcID, DG_CONTROL, DAT_EVENT, MSG_PROCESSEVENT, @Event);
    TWMsg := Event.TWMessage;
    Result := (RC = TWRC_DSEVENT);
  end;
  function MessageLoop: Boolean;
  // �]������: True
  var
    M: MSG;
    TWMsg: TW_UINT16;
  begin
    Result := False;
    while (GetMessage(M, 0, 0, 0)) do
    begin
      if (GetTWMessage(M, TWMsg)) then
      begin
        case (TWMsg) of
        MSG_XFERREADY:
          begin
            ImageNativeXfer(Bitmap);
            Result := True;
            Exit;
          end;
        MSG_CLOSEDSREQ, MSG_CLOSEDSOK:
          Exit;
        end;
      end else
      begin
        TranslateMessage(M);
        DispatchMessage(M);
      end;
    end;
  end;
var
  Saved8087CW: Word;
begin
  if (not DSMOpened) then OpenDSM(Parent);
  if (not DSOpened) then OpenDS;
  if (not DSEnabled) then EnableDS(UI, UI, Parent);
  Saved8087CW := Default8087CW;
  Set8087CW($133F);  { FPU ��O���ׂĖ��� }
  try
    Result := MessageLoop;
  finally
    Set8087CW(Saved8087CW);
    DisableDS;
  end;
end;

function TTwain.SelectDevice(Parent: THandle): Boolean;
// TWAIN �@��̑I��
begin
  if (DSEnabled) then DisableDS;
  if (DSOpened) then CloseDS;
  if (not DSMOpened) then OpenDSM(Parent);
  Result := (UserSelect = TWRC_SUCCESS);
end;

procedure FreeTwain;
begin
  try
    if (Assigned(FTwain)) then FreeAndNil(FTwain);
  except
  end;
end;

initialization

finalization
  FreeTwain;

end.
