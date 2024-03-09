unit CrcUtils;
{******************************************************************************
  CRC16/32

[�T�v]
  CRC16(ITU-T), CRC16(ASCII), CRC32(ITU-U) �������Ή��A
  �e�[�u���ɂ�鍂�����A�E���A�����A�r�b�g���]�L�薳���Ή�

[�Q�l����]
  C����ɂ��A���S���Y�����T �������F�� �Z�p�]�_��

  2004/11/28 t_kumagai


===============================================================================
				CRC16/32 ���j�b�g
===============================================================================

���T�v
	CRC16/32 ���Z�o���܂�
	CRC16(ITU-T), CRC16(ASCII), CRC32(ITU-U) �������Ή��A
	�e�[�u���ɂ�鍂�����A�E���A�����A�r�b�g���]�L�薳���Ή�

�������
	�EBorland Delphi 5,6,7

���g�p���@
	GZIP ������ CRC ���Z�o����ꍇ
	uses �� CrcUtils ���w�肵��

	procedure TForm1.Button1Click(Sender: TObject);
	const
	  Code = 'ABCDEFG';
	var
	  Crc: TCrc32;
	begin
	  // CRC32 ITU-T �������A�E���A�r�b�g���]����(GZIP ����)
	  Crc := TCrc32R.Create(CRC32_ITU_T, True);
	  try
	    Crc.Reset;
	    Crc.Update(Code);
	    ShowMessageFmt('%s -> CRC32:%.8X', [Code, Crc.Value]);
	  finally
	    Crc.Free;
	  end;
	end;

���Q�l����
	�EC����ɂ��A���S���Y�����T �������F�� �Z�p�]�_��

�����C�Z���X
	�g�p�A���ρA���p�A�Ĕz�z�A��ؐ����͂���܂���B

							2004/11/28 t_kumagai
===============================================================================

******************************************************************************}

interface

uses
  SysUtils, Classes, Windows;

const
 CRC16_ITU_T: array [0..2] of Byte = (0,5,12);
 CRC16_ASCII: array [0..2] of Byte = (0,2,15);
 CRC32_ITU_T: array [0..13] of Byte = (0,1,2,4,5,7,8,10,11,12,16,22,23,26);

type
  TCrc = class
  protected
    Inverse: Boolean;
  public
    constructor Create(const Polynomial: array of Byte; Inverse: Boolean);
    procedure Init(const Polynomial: array of Byte); virtual; abstract;
    procedure Reset; virtual; abstract;
    procedure Update(Data: Byte); overload;
    procedure Update(DataArray: PByteArray; Index, Size: Integer); overload; virtual; abstract;
    procedure Update(const S: string); overload;
  end;
  TCrc16 = class(TCrc)
  protected
    Table: array [Byte] of Word;
    FValue: Word;
  public
    procedure Reset; override;
    function Value: Word; virtual;
  end;
  TCrc16L = class(TCrc16)
    procedure Init(const Polynomial: array of Byte); override;
    procedure Update(DataArray: PByteArray; Index, Size: Integer); override;
  end;
  TCrc16R = class(TCrc16)
    procedure Init(const Polynomial: array of Byte); override;
    procedure Update(DataArray: PByteArray; Index, Size: Integer); override;
  end;
  TCrc32 = class(TCrc)
  protected
    Table: array [Byte] of DWORD;
    FValue: DWORD;
  public
    procedure Reset; override;
    function Value: DWORD; virtual;
  end;
  TCrc32L = class(TCrc32)
    procedure Init(const Polynomial: array of Byte); override;
    procedure Update(DataArray: PByteArray; Index, Size: Integer); override;
  end;
  TCrc32R = class(TCrc32)
    procedure Init(const Polynomial: array of Byte); override;
    procedure Update(DataArray: PByteArray; Index, Size: Integer); override;
  end;

implementation

uses
  Math;

const
  CHAR_BIT = 8;

{ TCrc }

constructor TCrc.Create(const Polynomial: array of Byte; Inverse: Boolean);
begin
  Init(Polynomial);
  Self.Inverse := Inverse;
  Reset;
end;

procedure TCrc.Update(Data: Byte);
begin
  Update(@Data, 0, 1);
end;

procedure TCrc.Update(const S: string);
begin
  Update(@S[1], 0, Length(S));
end;

{ TCrc16 }

procedure TCrc16.Reset;
begin
  FValue := 0;
  if (Inverse) then
    FValue := not FValue;
end;

function TCrc16.Value: Word;
begin
  Result := FValue;
  if (Inverse) then
    Result := not Result;
end;

{ TCrc16L }

procedure TCrc16L.Init(const Polynomial: array of Byte);
var
  I, J: Word;
  R: Word;
  CrcPolynomial: Word;
begin
  CrcPolynomial := 0;
  for I := Low(Polynomial) to High(Polynomial) do
    CrcPolynomial := CrcPolynomial or (1 shl Polynomial[I]);

  for I := Low(Byte) to High(Byte) do
  begin
		R := I shl (16 - CHAR_BIT);
		for J := 0 to CHAR_BIT - 1 do
    	if (R and $8000 <> 0) then
        R := (R shl 1) xor CrcPolynomial
			else
        R := R shl 1;
    Table[I] := R;
  end;
end;

procedure TCrc16L.Update(DataArray: PByteArray; Index, Size: Integer);
var
  I: Integer;
begin
  for I := Index to Index + Size - 1 do
		FValue := (FValue shl CHAR_BIT) xor Table[Byte(FValue shr (16 - CHAR_BIT)) xor DataArray[I]];
end;

{ TCrc16R }

procedure TCrc16R.Init(const Polynomial: array of Byte);
var
  I, J: Word;
  R: Word;
  CrcPolynomial: Word;
begin
  CrcPolynomial := 0;
  for I := Low(Polynomial) to High(Polynomial) do
    CrcPolynomial := CrcPolynomial or (1 shl (16 - 1 - Polynomial[I]));

  for I := Low(Byte) to High(Byte) do
  begin
		R := I;
    for J := 0 to CHAR_BIT - 1 do
      if (R and 1 <> 0) then
        R := (R shr 1) xor CrcPolynomial
      else
        R := R shr 1;
    Table[I] := R;
  end;
end;

procedure TCrc16R.Update(DataArray: PByteArray; Index, Size: Integer);
var
  I: Integer;
begin
  for I := Index to Index + Size - 1 do
		FValue := (FValue shr CHAR_BIT) xor Table[Byte(FValue) xor DataArray[I]];
end;

{ TCrc32 }

procedure TCrc32.Reset;
begin
  FValue := 0;
  if (Inverse) then
    FValue := not FValue;
end;

function TCrc32.Value: DWORD;
begin
  Result := FValue;
  if (Inverse) then
	  Result := not Result;
end;

{ TCrc32L }

procedure TCrc32L.Init(const Polynomial: array of Byte);
var
  I, J: DWORD;
  R: DWORD;
  CrcPolynomial: DWORD;
begin
  CrcPolynomial := 0;
  for I := Low(Polynomial) to High(Polynomial) do
    CrcPolynomial := CrcPolynomial or (1 shl Polynomial[I]);

  for I := Low(Byte) to High(Byte) do
  begin
		R := I shl (32 - CHAR_BIT);
		for J := 0 to CHAR_BIT - 1 do
    	if (R and $80000000 <> 0) then
        R := (R shl 1) xor CrcPolynomial
			else
        R := R shl 1;
    Table[I] := R;
  end;
end;

procedure TCrc32L.Update(DataArray: PByteArray; Index, Size: Integer);
var
  I: Integer;
begin
  for I := Index to Index + Size - 1 do
		FValue := (FValue shl CHAR_BIT) xor Table[Byte(FValue shr (32 - CHAR_BIT)) xor DataArray[I]];
end;

{ TCrc32R }

procedure TCrc32R.Init(const Polynomial: array of Byte);
var
  I, J: DWORD;
  R: DWORD;
  CrcPolynomial: DWORD;
begin
  CrcPolynomial := 0;
  for I := Low(Polynomial) to High(Polynomial) do
    CrcPolynomial := CrcPolynomial or (1 shl (32 - 1 - Polynomial[I]));

  for I := Low(Byte) to High(Byte) do
  begin
		R := I;
    for J := 0 to CHAR_BIT - 1 do
      if (R and 1 <> 0) then
        R := (R shr 1) xor CrcPolynomial
      else
        R := R shr 1;
    Table[I] := R;
  end;
end;

procedure TCrc32R.Update(DataArray: PByteArray; Index, Size: Integer);
var
  I: Integer;
begin
  for I := Index to Index + Size - 1 do
		FValue := (FValue shr CHAR_BIT) xor Table[Byte(FValue) xor DataArray[I]];
end;

end.
