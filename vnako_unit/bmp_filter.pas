unit bmp_filter;
// ���@���F�摜�Ƀt�B���^�[�������郆�j�b�g�^�Q�l�Fhttp://homepage1.nifty.com/beny/delphi.html Rinka Kouzuki�l
// ��@�ҁF�N�W����s��(http://kujirahand.com)
// ���J���F2001/10/21

interface
uses Windows, SysUtils, Classes, Graphics, forms;

type
  PRGB24 = ^TRGB24;
  TRGB24 = packed record
    B: Byte;
    G: Byte;
    R: Byte;
  end;

  TLine24 = array[0..MaxInt div SizeOf(TRGB24) -1]of TRGB24;
  PLine24 = ^TLine24;

  TCacheLines = array[0..MaxInt div SizeOf(Pointer) -1]of Pointer;
  PCacheLines = ^TCacheLines;

  TOperator3   = array[-1..1, -1..1]of Integer;
  TMatrix3     = array[-1..1, -1..1]of TRGB24;
  TLineMatrix3 = array[-1..1]of PLine24;

  TByteTable = array[Byte]of Byte;

  //�֐�
  function MakeOperator3(X: array of Integer): TOperator3;
  function GetCacheLines(Source: TBitmap): PCacheLines;
  procedure CopyDIB(Source, Dest: TBitmap);
  procedure StdTableFilter(Bitmap: TBitmap; Table: TByteTable);

  procedure NegaPosi(Bitmap: TBitmap);      // �l�K�|�W���]
  procedure Solarization(Bitmap: TBitmap);  // �\�����[�[�V����(�\�����[�[�V�����͑Ώۃs�N�Z���̋P�x�𔽓]���A�Ώۃs�N�Z���Ɣ�r���ċP�x�̒Ⴂ�������t�B���^�ł��B
  procedure Grayscale(Bitmap: TBitmap);
  procedure Gamma(Bitmap: TBitmap; Value: Double);
  procedure Brightness(Bitmap: TBitmap; Value: Integer);

  procedure BmpColorChange(Bitmap: TBitmap; c1, c2: Integer);

  {�摜��90�x��]�����܂��B���E�𕪂��ď����̂��ʓ|�Ȃ̂ň�̊֐��ɂ܂Ƃ߂܂���(�ǂ������������̃��[�v���Ⴄ��������)�B���ɐ����͗v��Ȃ��ł��傤�B
  ���܂Œ�`�������đS���g��Ȃ����� GetCacheLines �����߂Ďg�p���܂����B���̊֐��̓r�b�g�}�b�v�̑S�X�L�������C�����L���b�V������֐��ł��B����̂悤�ɐ��������Ɛ����������u�������悤�ȏꍇ�ATBitmap.ScanLine�����x���Ăяo�����ƂɂȂ�܂��B�֐��Ăяo���͌����������̂ŁA�������s���O�ɑS�ẴX�L�������C�����L���b�V�����Ċ֐��̌Ăяo���񐔂����炵�č��������Ă��܂��B}
  procedure Rotate90(Source: TBitmap; Right: Boolean);
  {�摜�𐂒������ɔ��]�����܂��B��Ɨp�ɓ��T�C�Y�̉摜��p�ӂ��ă��C�����R�s�[���Ă������@�ł������̂ł����A�����ł͈ꃉ�C�����̃o�b�t�@��p�ӂ��ă��C���̓���ւ����s�����@���g���܂��B}
  procedure VertReverse(Source: TBitmap);
  {�摜�𐅕������ɔ��]�����܂��B�������]�Ɠ������o�b�t�@���g�p����^�C�v�ł��B�Ƃ����Ă����������̔��]�̓s�N�Z���P�ʂŏ������Ȃ���΂Ȃ�Ȃ��̂ŁA1�s�N�Z�����̃o�b�t�@�Ŏ�����܂�(^^;}
  procedure HorzReverse(Source: TBitmap);
  {�摜��C�ӂ̊p�x�ŉ�]�����܂��B}
  procedure RotateDraw(Canvas: TCanvas; iX, iY, iAngle: Integer;
    bmpSrc: TBitmap; clBackGround: TColor);

// ����:1999/01/31�A�͖M ���iGCC02240@nifty.ne.jp�j�l�F����
// �t�H�[�����r�b�g�}�b�v�ɍ��킹�ĕό`���܂�
function CreateRgnFromBitmap(Src: TBitmap;
   TransparentColor: TColor): HRGN;
// �r�b�g�}�b�v���烊�[�W�������쐬���܂�
function SetRgnFromBitmap(Form: TForm; Bitmap: TBitmap;
  Repaint: Boolean = TRUE): Boolean;
// �����o���^�Ƀ��[�W�������쐬���܂�
function SetRgnHukidasi(Form: TForm; Repaint: Boolean = TRUE): Boolean;

implementation

uses Math, Types;

const
  EMes_InvalidGraphic = '�r�b�g�}�b�v���s���ł��B';


// �r�b�g�}�b�v���烊�[�W�������쐬���܂�
function CreateRgnFromBitmap(Src: TBitmap;
   TransparentColor: TColor): HRGN;
var
  Stream: TMemoryStream;
var
  Bitmap: TBitmap;
  pLine: PWORD;
  x, y, StartPos: Integer;
  R: TRect;
begin
  Result := HRGN(0);
  Bitmap := TBitmap.Create;
  try
    // ���̃r�b�g�}�b�v���畡��������ă}�X�N�����܂�
    Bitmap.Assign(Src);
    if not Bitmap.Empty then
    begin
      Stream := TMemoryStream.Create;
      try
        Stream.SetSize(sizeof(TRGNDATAHEADER));
        with PRgnDataHeader(Stream.Memory)^ do
        begin
          dwSize := sizeof(TRGNDATAHEADER);
          iType := RDH_RECTANGLES;
          nCount := 0;
          nRgnSize := 0;
          rcBound := RECT(0, 0, Bitmap.Width, Bitmap.Height);
        end;
        Stream.Position := sizeof(TRGNDATAHEADER);

        // �}�X�N�i���m�N���j�ɂ��܂�
        Bitmap.Mask(TransparentColor);

        // ScanLine ����f�[�^�����₷���悤�� 2bytes/pixel �ɂ��܂�
        Bitmap.PixelFormat := pf15bit;

        for y := 0 to Bitmap.Height - 1 do
        begin
          pLine := Bitmap.ScanLine[y];
          StartPos := -1;
          for x := 0 to Bitmap.Width - 1 do
          begin
            if(StartPos < 0)and(pLine^ = 0)then
              StartPos := x;
            if(StartPos >= 0)then
            begin
              if(pLine^ <> 0)then
              begin
                R.Left := StartPos;
                R.Right := x;
                R.Top := y;
                R.Bottom := R.Top + 1;

                Stream.Write(R, sizeof(TRect));
                Inc(PRgnDataHeader(Stream.Memory)^.nCount);

                StartPos := -1;
              end
              else if x = (Bitmap.Width - 1)then
              begin
                R.Left := StartPos;
                R.Right := x + 1;
                R.Top := y;
                R.Bottom := R.Top + 1;

                // RECT ���������ނ��тɃ������X�g���[���̃��T�C�Y��
                // �s����̂ŁA���̕��A������I�ł��� Delphi4 �ł�
                // ���p�X�s�[�h�ł��i���Ԃ� Delphi3 �ł����v�j
                Stream.Write(R, sizeof(TRect));
                Inc(PRgnDataHeader(Stream.Memory)^.nCount);

                StartPos := -1;
              end;
            end;
            Inc(pLine);
          end;
        end; // for y := ...
        Result := ExtCreateRegion(nil, Stream.Size, 
                                  PRgnData(Stream.Memory)^);
        if Result = 0 then
          Result := CreateRectRgn(0, 0, Bitmap.Width, Bitmap.Height);
      finally
        Stream.Free;
      end;
    end;
  finally
    Bitmap.Free;
  end;
end;

// �t�H�[�����r�b�g�}�b�v�ɍ��킹�ĕό`���܂�
function SetRgnFromBitmap(Form: TForm; Bitmap: TBitmap;
  Repaint: Boolean = TRUE): Boolean;
var
  hrgnNew: HRGN;
  R: TRect;
begin
  Result := FALSE;
  // �r�b�g�}�b�v���烊�[�W�����������
  hrgnNew := CreateRgnFromBitmap(Bitmap, Bitmap.TransparentColor);
  if Integer(hrgnNew) = 0 then Exit;
  if GetRgnBox(hrgnNew, R) <> NULLREGION then
  begin
    // ���[�W�������N���C�A���g�̈�ɂ��炵�܂�
    if Form.Parent = nil then
      R.TopLeft := Form.ClientToScreen(Point(-Form.Left, -Form.Top))
    else
      R.TopLeft := Form.Parent.ScreenToClient(Form.ClientToScreen(Point(-Form.Left, -Form.Top)));
    OffsetRgn(hrgnNew, R.Left, R.Top);

    // ���[�W�������t�H�[���ɓK�p���܂�
    Result := (SetWindowRgn(Form.Handle, hrgnNew, Repaint) <> 0);
  end
  else
  begin
    DeleteObject(hrgnNew);
  end;
end;

// �����o���^�Ƀ��[�W�������쐬���܂�
function SetRgnHukidasi(Form: TForm; Repaint: Boolean = TRUE): Boolean;
var
  hrgn1, hrgn2, hrgnNew: HRGN;
  PointArray: array[1..3]of TPoint;
  R: TRect;
begin
  Result := FALSE;
  // ��
  hrgn1 := CreateEllipticRgn(0,0,Form.ClientWidth, Form.ClientHeight);
  // �����o���̊p
  PointArray[1] := Point(Trunc(Form.ClientWidth * 0.75), Trunc(Form.ClientHeight * 0.5));
  PointArray[2] := Point(Form.ClientWidth,  Form.ClientHeight);
  PointArray[3] := Point(Trunc(Form.ClientWidth * 0.5), Trunc(Form.ClientHeight * 0.75));
  hrgn2 := CreatePolygonRgn(PointArray, 3, ALTERNATE);
  // ����
  hrgnNew := CreateRectRgn(0,0,9,9); // �K���ȃ��[�W���������
  CombineRgn(hrgnNew, hrgn1, hrgn2, RGN_OR);

  if Integer(hrgnNew) = 0 then Exit;
  if GetRgnBox(hrgnNew, R) <> NULLREGION then
  begin
    // ���[�W�������N���C�A���g�̈�ɂ��炵�܂�
    R.TopLeft := Form.ClientToScreen(Point(-Form.Left, -Form.Top));
    OffsetRgn(hrgnNew, R.Left, R.Top);

    // ���[�W�������t�H�[���ɓK�p���܂�
    Result := (SetWindowRgn(Form.Handle, hrgnNew, Repaint) <> 0);
  end
  else
  begin
    DeleteObject(hrgnNew);
  end;
  DeleteObject(hrgn1);
  DeleteObject(hrgn2);
end;


procedure RotateDraw(Canvas: TCanvas; iX, iY, iAngle: Integer;
  bmpSrc: TBitmap; clBackGround: TColor);
//1997/10/25�A�͖M ���l�̒񋟁iGCC02240@niftyserve.or.jp�j
var
  dwBackGround: DWORD;
  CosValue, SinValue: Extended;
  bmpTmp, bmpDst: TBitmap;
  x, y: Integer;
  exX, exY: Extended;
  pointTmp: TPoint;
  pdwDstLine: PDWORD;
begin
  // �f�t�H���g�̔w�i�F���r�b�g�}�b�v���̃t�H�[�}�b�g�ɕϊ�����
  dwBackGround := (DWORD(clBackGround) and $ff shl 16)
               or (DWORD(clBackGround) and $ff00)
               or (DWORD(clBackGround) and $ff0000 shr 16);

  // �O�p�֐��̌v�Z���ʂ��L�[�v����
  CosValue := Cos(iAngle * Pi / 180);
  SinValue := Sin(iAngle * Pi / 180);

  bmpTmp := TBitmap.Create;
  try
    // �\�[�X�r�b�g�}�b�v���R�s�[���Ă���t�H�[�}�b�g�� pf32Bit �ɂ���
    bmpTmp.Assign(bmpSrc);
    bmpTmp.PixelFormat := pf32Bit;

    // ��]��̉摜������r�b�g�}�b�v�̍쐬
    bmpDst := TBitmap.Create;
    try
      bmpDst.PixelFormat := pf32Bit;

      // ��]��̉摜������傫���ɂ���
      bmpDst.Width  := Round(abs(CosValue * bmpTmp.Width)
                           + abs(-SinValue * bmpTmp.Height)) + 1;
      bmpDst.Height := Round(abs(SinValue * bmpTmp.Width)
                           + abs(CosValue * bmpTmp.Height)) + 1;

      // ��]�R�s�[��̃r�b�g�}�b�v�̃X�L�����J�n�_�i0,0�j�̃\�[�X�r�b�g
      // �}�b�v���W����ł̈ʒu���v�Z���� exX �� exY �ɑ������
      pointTmp := Point(bmpDst.Width div 2, bmpDst.Height div 2);
      exX := (bmpTmp.Width  / 2) - (CosValue * pointTmp.x)
                                 - (SinValue * pointTmp.y);
      exY := (bmpTmp.Height / 2) - (-SinValue * pointTmp.x)
                                 - (CosValue * pointTmp.y);

      // �X�L�����J�n
      for y := 0 to bmpDst.Height - 1 do
      begin
        pdwDstLine := bmpDst.ScanLine[y];
        for x := 0 to bmpDst.Width - 1 do
        begin
          pointTmp := Point(Round(exX), Round(exY));

          // exX & exY ���\�[�X�r�b�g�}�b�v�̗L���͈͂ł���ꍇ
          if(0 <= pointTmp.x)and(pointTmp.x < bmpTmp.Width)and
            (0 <= pointTmp.y)and(pointTmp.y < bmpTmp.Height)then
            pdwDstLine^ := PDWORD(PChar(bmpTmp.ScanLine[pointTmp.y])
                                       + (pointTmp.x * sizeof(DWORD)))^
          // exX & exY ���\�[�X�r�b�g�}�b�v�̗L���͈͊O�Ȃ�w�i�F�ɂ���
          else
            pdwDstLine^ := dwBackGround;

          // odwDstLine, exX & exY �����̃s�N�Z���Ɉڂ�
          Inc(pdwDstLine);
          exX := exX + CosValue;
          exY := exY - SinValue;
        end;
        // exX & exY �����̍s�̐擪�ɖ߂�
        exX := exX + (SinValue - (CosValue * bmpDst.Width));
        exY := exY + (CosValue - (-SinValue * bmpDst.Width));
      end;
      // ��]�����r�b�g�}�b�v���L�����o�X�ɕ`�悷��
      Canvas.Draw(iX, iY, bmpDst);
    finally
      bmpDst.Free;
    end;
  finally
    bmpTmp.Free;
  end;
end;


function MakeOperator3(X: array of Integer): TOperator3;
// �I�y���[�^�[���쐬
var
  I, MX, MY, Count: Integer;
begin
  FillChar(Result, SizeOf(Result), 0);
  Count := High(X);
  if Count = -1 then Exit;
  I := 0;
  for MX := -1 to 1 do
    for MY := -1 to 1 do
    begin
      Result[MX, MY] := X[I];
      Inc(I);
      if I > Count then Break;
    end;
end;

function GetCacheLines(Source: TBitmap): PCacheLines;
// �r�b�g�}�b�v�̃X�L�������C�����L���b�V������
var
  Y: Integer;
begin
  if (Source = nil) or Source.Empty then
    raise EInvalidGraphicOperation.Create(EMes_InvalidGraphic);
  with Source do
  begin
    GetMem(Result, SizeOf(Pointer) * Height);
    try
      for Y := 0 to Height -1 do
        Result^[Y] := ScanLine[Y];
    except
      FreeMem(Result);
      raise;
    end;
  end;
end;

procedure CopyDIB(Source, Dest: TBitmap);
// DIB���R�s�[����
var
  Y, Bytes: Integer;
begin
  if (Source = nil) or Source.Empty or (Dest = nil) then
    raise EInvalidGraphicOperation.Create(EMes_InvalidGraphic);
  Source.PixelFormat := pf24bit;
  Dest.PixelFormat   := pf24bit;
  Dest.Width  := Source.Width;
  Dest.Height := Source.Height;
  Bytes := BytesPerScanline(Source.Width, 24, 32);
  for Y := 0 to Source.Height -1 do
    Move(Source.ScanLine[Y]^, Dest.ScanLine[Y]^, Bytes);
end;

procedure StdTableFilter(Bitmap: TBitmap; Table: TByteTable);
//�P���ȃe�[�u���ϊ����s���֐�
var
  X, Y: Integer;
  pLine: PLine24;
begin
  Bitmap.PixelFormat := pf24bit;

  { �s�N�Z���̕ϊ����� }
  for Y := 0 to Bitmap.Height -1 do
  begin
    pLine := Bitmap.ScanLine[Y];
    for X := 0 to Bitmap.Width -1 do
      with pLine^[X] do
      begin
        R := Table[R];
        G := Table[G];
        B := Table[B];
      end;
  end;
end;

procedure NegaPosi(Bitmap: TBitmap);
// �l�K�|�W���]
var
  X, Y: Integer;
  pLine: PLine24;
begin
  Bitmap.PixelFormat := pf24bit;
  for Y := 0 to Bitmap.Height -1 do
  begin
    pLine := Bitmap.ScanLine[Y];
    for X := 0 to Bitmap.Width -1 do
      with pLine^[X] do
      begin
        R := R xor $FF;
        G := G xor $FF;
        B := B xor $FF;
      end;
  end;
  if Assigned(Bitmap.OnChange) then
    Bitmap.OnChange(Bitmap);
end;

procedure BmpColorChange(Bitmap: TBitmap; c1, c2: Integer);
var
  X, Y: Integer;
  C1R,C1G,C1B,C2R,C2G,C2B: Byte;
  pLine: PLine24;
begin
  C1R := (c1       ) and $FF;
  C1G := (c1 shr  8) and $FF;
  C1B := (c1 shr 16) and $FF;
  //
  C2R := (c2       ) and $FF;
  C2G := (c2 shr  8) and $FF;
  C2B := (c2 shr 16) and $FF;

  Bitmap.PixelFormat := pf24bit;
  for Y := 0 to Bitmap.Height -1 do
  begin
    pLine := Bitmap.ScanLine[Y];
    for X := 0 to Bitmap.Width -1 do
    begin
      with pLine^[X] do
      begin // RGB -> BGR
        if (R=C1R)and(G=C1G)and(B=C1B) then
        begin
          R := C2R;
          G := C2G;
          B := C2B;
        end;
      end;
    end;
  end;
  if Assigned(Bitmap.OnChange) then
    Bitmap.OnChange(Bitmap);
end;


procedure Solarization(Bitmap: TBitmap);
var
  X, Y: Integer;
  Table: TByteTable;
begin
  { �ϊ��e�[�u���𐶐� }
  for X := 0 to 255 do
  begin
    //Table[X] := Min(X, X xor $FF);
    Y := X xor $FF;
    if X < Y then Y := X;
    Table[X] := Y;
  end;

  //�s�N�Z���̕ϊ�����
  StdTableFilter(Bitmap, Table);

  if Assigned(Bitmap.OnChange) then
    Bitmap.OnChange(Bitmap);
end;

procedure Grayscale(Bitmap: TBitmap);
//�O���C�X�P�[��
var
  X, Y, Gray: Integer;
  pLine: PLine24;
begin
  Bitmap.PixelFormat := pf24bit;
  { �s�N�Z���̕ϊ����� }
  for Y := 0 to Bitmap.Height -1 do
  begin
    pLine := Bitmap.ScanLine[Y];
    for X := 0 to Bitmap.Width -1 do
      with pLine^[X] do
      begin
        Gray := Round((R * 30 + G * 59 + B * 11) / 100);
        { 0..255�͈̔͂ɖO�a(����������ƕK�v�Ȃ�����(^^;) }
        if Gray > 255 then Gray := 255
        else if Gray < 0 then Gray := 0;
        R := Gray;
        G := Gray;
        B := Gray;
      end;
  end;
  if Assigned(Bitmap.OnChange) then
    Bitmap.OnChange(Bitmap);
end;

procedure Gamma(Bitmap: TBitmap; Value: Double);
//�K���}�␳
var
  X, Y: Integer;
  Table: TByteTable;
begin
  { �ϊ��e�[�u���̍쐬 }
  Value := Value / 2.2;
  for Y := 0 to 255 do
  begin
    X := Round(Power(Y / 255, Value) * 255);
    if X > 255 then X := 255 else if X < 0 then X := 0;
    Table[Y] := X;
  end;

  //�s�N�Z���̕ϊ�����
  StdTableFilter(Bitmap, Table);

  if Assigned(Bitmap.OnChange) then
    Bitmap.OnChange(Bitmap);
end;

procedure Brightness(Bitmap: TBitmap; Value: Integer);
//���邳�␳
var
  X, Y: Integer;
  Table: TByteTable;
begin
  if (Value = 0) or (Value > 255) or (Value < -255) then Exit;
  { �ϊ��e�[�u���̍쐬 }
  for Y := 0 to 255 do
  begin
    X := Y + Value;
    if X > 255 then X := 255 else if X < 0 then X := 0;
    Table[Y] := X;
  end;

  //�s�N�Z���̕ϊ�����
  StdTableFilter(Bitmap, Table);

  if Assigned(Bitmap.OnChange) then
    Bitmap.OnChange(Bitmap);
end;



procedure HorzReverse(Source: TBitmap);
var
  X, Y, W: Integer;
  pLine: PLine24;
  Temp: TRGB24;
begin
  Source.PixelFormat := pf24bit;
  W := Source.Width -1;
  for Y := 0 to Source.Height -1 do
  begin
    pLine := Source.ScanLine[Y];
    for X := 0 to W div 2 do
    begin
      Temp := pLine^[X];
      pLine^[X]   := pLine^[W-X];
      pLine^[W-X] := Temp;
    end;
  end;
  if Assigned(Source.OnChange) then
    Source.OnChange(Source);
end;


procedure VertReverse(Source: TBitmap);
var
  Y, H, BufSize: Integer;
  pLine1, pLine2, pBuffer: Pointer;
begin
  Source.PixelFormat := pf24bit;
  BufSize := BytesPerScanline(Source.Width, 24, 32);
  H := Source.Height -1;
  GetMem(pBuffer, BufSize);
  try
    with Source do
      for Y := 0 to H div 2 do
      begin
        pLine1 := ScanLine[Y];
        pLine2 := ScanLine[H-Y];
        Move(pLine1^, pBuffer^, BufSize);
        Move(pLine2^, pLine1^, BufSize);
        Move(pBuffer^, pLine2^, BufSize);
      end;
  finally
    FreeMem(pBuffer);
  end;
  if Assigned(Source.OnChange) then
    Source.OnChange(Source);
end;



procedure Rotate90(Source: TBitmap; Right: Boolean);
var
  X, Y, W, H: Integer;
  Dest: TBitmap;
  pDstLine: PLine24;
  pSrcCache: PCacheLines;
begin
  W := Source.Width;
  H := Source.Height;
  Source.PixelFormat := pf24bit;
  Dest := TBitmap.Create;
  pSrcCache := GetCacheLines(Source);//�S���C���̃L���b�V��
  try
    Dest.PixelFormat := pf24bit;
    Dest.Width  := H;
    Dest.Height := W;
    Dec(W);
    Dec(H);
    for X := 0 to W do
    begin
      pDstLine := Dest.ScanLine[X];
      if Right then
      begin
      { ���v��� }
        for Y := 0 to H do
          pDstLine^[H-Y] := PLine24(pSrcCache^[Y])^[X];
      end else begin
      { �����v��� }
        for Y := 0 to H do
          pDstLine^[Y] := PLine24(pSrcCache^[Y])^[W-X];
      end;
    end;
    Source.Assign(Dest);
  finally
    Dest.Free;
    FreeMem(pSrcCache);
  end;
end;

 

end.
