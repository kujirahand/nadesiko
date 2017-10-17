(***********************************************************************
 *	MAG Image classes
 *							Copyright (c)1997,1999 Masahiro Yoshida.
 *							mailto:mas@pb.highway.ne.jp
 *							http://home3.highway.ne.jp/mas/
 *
 *	1997.01.13	first.(Delphi 2 and Uncomress only)
 *	1999.06.26	Delphi 4 only. But uncompress speed up.
 *	1999.06.30	Compress support.
 *	1999.08.26	...
 *	1999.10.20	DIBNeeded bug fix.
 *--------------------------------------------------------------------*
 *	classes
 ***********************************************************************)

UNIT Mag;

INTERFACE

USES
	Windows, SysUtils, Classes, Graphics,
	MagTypes;

(*--------------------------------------------------------------------*)
TYPE
	(* MAG pixel format *)
	TMagPixelFormat = (mpf4Bit, mpf8Bit);

TYPE
	(* Exception *)
	EMagError = CLASS(Exception);
	(* Exception *)
	EInvalidMagOperation = CLASS(EInvalidGraphicOperation);

TYPE
	(* Raw data *)
	TMagData = CLASS(TSharedImage)
	PRIVATE
		FData		: TMemoryStream;
		FID			: TMagID;
		FHeader		: TMagHeader;
		FWidth, 
		FHeight		: INTEGER;
	PROTECTED
		PROCEDURE FreeHandle; OVERRIDE;
	PUBLIC
		DESTRUCTOR Destroy; OVERRIDE;
	END;

(*--------------------------------------------------------------------*)

TYPE
	(* Image *)
	TMAGImage = CLASS(TGraphic)
	PRIVATE
		FImage		: TMagData;
		FBitmap		: TBitmap;
		FPixelFormat: TMagPixelFormat;
		FPalette	: HPALETTE;
		FUser,
		FComment	: STRING;
		FHalfHeight	: BOOLEAN;
		FTop, FLeft	: WORD;
		(* new *)
		PROCEDURE CompressPixel(FlagA: PBYTE; FlagB, Pixel: TStream);
		FUNCTION GetBitmap: TBitmap;
		PROCEDURE SetPixelFormat(value: TMagPixelFormat);
		PROCEDURE SetComment(value: STRING);
		PROCEDURE SetUser(value: STRING);
		PROCEDURE SetHalfHeight(value: BOOLEAN);
		PROCEDURE SetTop(value: WORD);
		PROCEDURE SetLeft(value: WORD);

	PROTECTED
		(* abstract *)
		PROCEDURE Draw(ACanvas: TCanvas; CONST Rect: TRect); OVERRIDE;
		FUNCTION GetEmpty: BOOLEAN; OVERRIDE;
		FUNCTION GetHeight: INTEGER; OVERRIDE;
		FUNCTION GetWidth: INTEGER; OVERRIDE;
		PROCEDURE SetHeight(Value: INTEGER); OVERRIDE;
		PROCEDURE SetWidth(Value: INTEGER); OVERRIDE;
		(* override *)
		PROCEDURE AssignTo(Dest: TPersistent); OVERRIDE;
		FUNCTION Equals(Graphic: TGraphic): BOOLEAN; OVERRIDE;
		FUNCTION GetPalette: HPALETTE; OVERRIDE;
		PROCEDURE SetPalette(value: HPALETTE); OVERRIDE;
		PROCEDURE ReadData(Stream: TStream); OVERRIDE;
		PROCEDURE WriteData(Stream: TStream); OVERRIDE;
		(* new *)
		(* init *)
		PROCEDURE SetDefaultData; VIRTUAL;
		(* free palette *)
		PROCEDURE FreePalette;
		(* free bitmap *)
		PROCEDURE FreeBitmap;
		(* new bitmap *)
		PROCEDURE NewBitmap;
		(* new Raw data *)
		PROCEDURE NewImage;
		(* reader *)
		PROCEDURE ReadStream(Size: INTEGER; Stream: TStream);
		(* decode *)
		PROCEDURE LoadPalette;
		PROCEDURE Uncompress;

		(* bitmap *)
		PROPERTY Bitmap: TBitmap READ GetBitmap;

	PUBLIC
		CONSTRUCTOR Create; OVERRIDE;
		DESTRUCTOR Destroy; OVERRIDE;
		(* abstract *)
		PROCEDURE LoadFromStream(Stream: TStream); OVERRIDE;
		PROCEDURE SaveToStream(Stream: TStream); OVERRIDE;
		PROCEDURE LoadFromClipboardFormat(AFormat: WORD; AData: THandle;
				APalette: HPALETTE); OVERRIDE;
		PROCEDURE SaveToClipboardFormat(VAR AFormat: WORD; VAR AData: THandle;
				VAR APalette: HPALETTE); OVERRIDE;
		(* override *)
		PROCEDURE Assign(Source: TPersistent); OVERRIDE;

		(* new *)
		(* encode *)
		PROCEDURE Compress;
		(* make MAG *)
		PROCEDURE MAGNeeded;
		(* make DIB *)
		PROCEDURE DIBNeeded;

	(* PROPERTY *)
		(* pixel format *)
		PROPERTY PixelFormat: TMagPixelFormat READ FPixelFormat WRITE SetPixelFormat;
		(* aspect h 1/2 *)
		PROPERTY HalfHeight: BOOLEAN READ FHalfHeight WRITE SetHalfHeight;
		(* user name *)
		PROPERTY User: STRING READ FUser WRITE SetUser;
		(* comment *)
		PROPERTY Comment: STRING READ FComment WRITE SetComment;
		(* position top *)
		PROPERTY Top: WORD READ FTop WRITE SetTop;
		(* position left *)
		PROPERTY Left: WORD READ FLeft WRITE SetLeft;
	END;

(* use design *)
PROCEDURE Register;

(***********************************************************************)
IMPLEMENTATION

(*====================================================================*)
TYPE
	PByteArray = ^TByteArray;
	TByteArray = ARRAY [0..MaxInt-1] OF BYTE;

CONST
	MagCommentDefault	= 'mas''s TMAGImage Ver 1.01';
	MagUserDefault		= '>??<';
	MagMachine			= 'masP';

PROCEDURE MagError(msg: STRING) ;
BEGIN
	RAISE EMagError.Create('MAG image error:' + msg) ;
END ;

PROCEDURE MagInvaild(msg: STRING);
BEGIN
	raise EInvalidMagOperation.Create('MAG invaild operation:' + msg);
END;
(*--------------------------------------------------------------------*)
PROCEDURE NormalBitmap(Bitmap: TBitmap);
BEGIN
	IF Bitmap = NIL THEN	Exit;

	(* 利用できない Palette を変更 *)
	CASE Bitmap.PixelFormat OF
		pf1Bit	: Bitmap.PixelFormat := pf4Bit;
		pf4Bit, pf8Bit: ;
		ELSE
			Bitmap.PixelFormat := pf8Bit;
	END;
	(* 幅の調整 *)
	CASE Bitmap.PixelFormat OF
		pf4Bit	: 	Bitmap.Width := (Bitmap.Width + 7) AND (NOT 7);
		pf8Bit	: 	Bitmap.Width := (Bitmap.Width + 3) AND (NOT 3);
	END;
END;

(*--------------------------------------------------------------------*)
//{###TMagData
DESTRUCTOR TMagData.Destroy; (*IS*)
BEGIN
	FData.Free;
	inherited Destroy;
END;

PROCEDURE TMagData.FreeHandle; (*IS*)
BEGIN
END;

(*====================================================================*)
(*--------------------------------------------------------------------*)
CONSTRUCTOR TMAGImage.Create;
BEGIN
	inherited Create;
	NewImage;
	SetDefaultData;
{
	FPixelFormat := mpf4Bit;
	FComment := MagCommentDefault;
	FUser := MagUserDefault;
	FHalfHeight := FALSE;
}
END;

DESTRUCTOR TMAGImage.Destroy;
BEGIN
	IF FPalette <> 0 THEN
		DeleteObject(FPalette);
	FBitmap.Free;
	FImage.Release;
	inherited Destroy;
END;

(*--------------------------------------------------------------------*)
PROCEDURE TMAGImage.Draw(ACanvas: TCanvas; CONST Rect: TRect); 
BEGIN
	ACanvas.StretchDraw(Rect, Bitmap);
END;

(*--------------------------------------------------------------------*)
FUNCTION TMAGImage.GetEmpty: BOOLEAN;
BEGIN
	Result := (FImage.FData = NIL) AND FBitmap.Empty;
END;

FUNCTION TMAGImage.Equals(Graphic: TGraphic): BOOLEAN;
BEGIN
	Result := (Graphic is TMAGImage) AND 
		(FImage = TMAGImage(Graphic).FImage);
END;

(*--------------------------------------------------------------------*)
FUNCTION TMAGImage.GetHeight: INTEGER;
BEGIN
	IF FBitmap <> NIL THEN
		Result := FBitmap.Height 
	ELSE
		Result := FImage.FHeight;
END;

FUNCTION TMAGImage.GetWidth: INTEGER;
BEGIN
	IF FBitmap <> NIL THEN
		Result := FBitmap.Width 
	ELSE
		Result := FImage.FWidth;
END;

PROCEDURE TMAGImage.SetHeight(Value: INTEGER);
BEGIN
	IF (FTop + Value) > $FFFF THEN
		MagInvaild('range over');
	Bitmap.Height := Value;
	Changed(Self);
END;

PROCEDURE TMAGImage.SetWidth(Value: INTEGER);
BEGIN
	CASE FPixelFormat OF
		mpf4Bit	: 	Value := (Value + 7) AND (NOT 7);
		mpf8Bit	: 	Value := (Value + 3) AND (NOT 3);
	END;
	IF (FLeft + Value) > $FFFF THEN
		MagInvaild('range over');
	Bitmap.Width := Value ;
	Changed(Self);
END;

(*--------------------------------------------------------------------*)

FUNCTION TMAGImage.GetPalette: HPALETTE;
BEGIN
	IF FBitmap <> NIL THEN
		Result := FBitmap.Palette 
	ELSE
		Result := FPalette;
END;

PROCEDURE TMAGImage.SetPalette(value: HPALETTE);
BEGIN
	Bitmap.Palette := value;
	PaletteModified := TRUE;
	Changed(Self);
END;
(*--------------------------------------------------------------------*)
PROCEDURE TMAGImage.SetDefaultData;
BEGIN
	FPixelFormat := mpf4Bit;
	FComment := MagCommentDefault;
	FUser := MagUserDefault;
	FHalfHeight := FALSE;
	FTop := 0;
	FLEft := 0;
END;

FUNCTION TMAGImage.GetBitmap: TBitmap;
BEGIN
	IF FBitmap = NIL THEN
	BEGIN
		NewBitmap;
		IF FImage.FData <> NIL THEN
			Uncompress;
	END;
	Result := FBitmap;
END;

PROCEDURE TMAGImage.SetPixelFormat(value: TMagPixelFormat);
BEGIN
	IF FPixelFormat = value THEN	Exit;
	FPixelFormat := value;
	CASE value OF
		mpf4Bit	: FBitmap.PixelFormat := pf4Bit;
		mpf8Bit	: FBitmap.PixelFormat := pf8Bit;
	END;
	Changed(Self);
END;

PROCEDURE TMAGImage.SetComment(value: STRING);
BEGIN
	FComment := value;
	Changed(Self);
END;

PROCEDURE TMAGImage.SetUser(value: STRING);
BEGIN
	FUser := Copy(value, 1, 18);
	Changed(Self);
END;

PROCEDURE TMAGImage.SetHalfHeight(value: BOOLEAN);
BEGIN
	IF FHalfHeight = value THEN	Exit;
	FHalfHeight := value;
	Changed(Self);
END;

PROCEDURE TMAGImage.SetTop(value: WORD);
BEGIN
	IF (FTop + Height) > $FFFF THEN
		MagInvaild('range over');
	FTop := value;
	Changed(Self);
END;

PROCEDURE TMAGImage.SetLeft(value: WORD);
BEGIN
	CASE FPixelFormat OF
		mpf4Bit	: 	Value := Value AND (NOT 7);
		mpf8Bit	: 	Value := Value AND (NOT 3);
	END;
	IF (FLeft + Width) > $FFFF THEN
		MagInvaild('range over');
	FLeft := value;
	Changed(Self);
END;

(*--------------------------------------------------------------------*)
(* desined *)
PROCEDURE TMAGImage.ReadData(Stream: TStream);
VAR
	Size	: LONGINT;
BEGIN
	Stream.Read(Size, SizeOf(Size));
	ReadStream(Size, Stream);
END;

PROCEDURE TMAGImage.WriteData(Stream: TStream);
VAR
	Size	: LONGINT;
BEGIN
	IF (FImage.FData = NIL) OR (Modified) THEN
		Compress;
	Size := FImage.FData.Size;
	Stream.Write(Size, SizeOf(Size));
	FImage.FData.SaveToStream(Stream);
END;

(*--------------------------------------------------------------------*)
PROCEDURE TMAGImage.LoadFromStream(Stream: TStream);
BEGIN
	ReadStream(Stream.Size - Stream.Position, Stream);
END;

PROCEDURE TMAGImage.SaveToStream(Stream: TStream);
BEGIN
	IF (FImage.FData = NIL) OR (Modified) THEN
		Compress;
	FImage.FData.SaveToStream(Stream);
END;

PROCEDURE TMAGImage.LoadFromClipboardFormat(AFormat: WORD; 
		AData: THandle; APalette: HPALETTE);
BEGIN
	Bitmap.LoadFromClipboardFormat(AFormat, AData, APalette);
END;

PROCEDURE TMAGImage.SaveToClipboardFormat(VAR AFormat: WORD; 
		VAR AData: THandle; VAR APalette: HPALETTE);
BEGIN
	Bitmap.SaveToClipboardFormat(AFormat, AData, APalette);
END;

(*--------------------------------------------------------------------*)
PROCEDURE TMAGImage.AssignTo(Dest: TPersistent);
BEGIN
	IF (Dest IS TGraphic) THEN
	BEGIN
		Dest.Assign(Bitmap);
	END
	ELSE
		inherited AssignTo(Dest);
END;

PROCEDURE TMAGImage.Assign(Source: TPersistent);
BEGIN
	IF (Source IS TMAGImage) THEN
	BEGIN
		FImage.Release;
		FImage := TMAGImage(Source).FImage;
		FImage.Reference;
		FComment := TMAGImage(Source).FComment;
		FUser := TMAGImage(Source).FUser;
		FPixelFormat := TMAGImage(Source).FPixelFormat;
		FHalfHeight := TMAGImage(Source).FHalfHeight;
		FTop := TMAGImage(Source).FTop;
		FLeft := TMAGImage(Source).FLeft;

		FreePalette;
		IF TMAGImage(Source).FPalette <> 0 THEN
			FPalette := CopyPalette(TMAGImage(Source).FPalette);

		IF TMAGImage(Source).FBitmap <> nil THEN
		BEGIN
			(* Has Bitmap *)
			NewBitmap;
			FBitmap.Assign( TMAGImage(Source).FBitmap );
		END;
		PaletteModified := TRUE;
		Changed(Self);
	END
	ELSE IF Source IS TGraphic THEN
	BEGIN
		(* Bitmap *)
		NewImage;
		NewBitmap;
		FreePalette;
		FBitmap.Assign(Source);
		(* 微調整 *)
		SetDefaultData;
		NormalBitmap(FBitmap);
		CASE FBitmap.PixelFormat OF
			pf4Bit	: 	FPixelFormat := mpf4Bit;
			pf8Bit	: 	FPixelFormat := mpf8Bit;
		END;
		PaletteModified := TRUE;
		Changed(Self);
	END
	ELSE
		INHERITED Assign(Source);
END;

(*--------------------------------------------------------------------*)
PROCEDURE TMAGImage.FreePalette;
BEGIN
	IF FPalette <> 0 THEN
	BEGIN
		DeleteObject(FPalette);
		FPalette := 0;
	END;
END;

PROCEDURE TMAGImage.FreeBitmap;
BEGIN
	FBitmap.Free;
	FBitmap := nil;
END;

PROCEDURE TMAGImage.NewBitmap;
BEGIN
	FBitmap.Free;
	FBitmap := TBitmap.Create;
	FBitmap.PixelFormat := pf4Bit;
	FBitmap.Width := 8;
END;

PROCEDURE TMAGImage.NewImage;
BEGIN
	IF FImage <> nil THEN FImage.Release;
	FImage := TMAGData.Create;
	FImage.Reference;

	WITH FImage DO
	BEGIN
		FillChar(FID, SizeOf(FID), $20);
		Move(MagID, FID.ID, SizeOf(FID.ID));
		Move(MagMachine, FID.Machine, SizeOf(FID.Machine));
	END;
END;

(*--------------------------------------------------------------------*)
PROCEDURE TMAGImage.MAGNeeded;
BEGIN
	IF FImage.FData = NIL THEN
		Compress;
END;

PROCEDURE TMAGImage.DIBNeeded;
BEGIN
	GetBitmap;
END;

(*--------------------------------------------------------------------*)
PROCEDURE TMAGImage.ReadStream(Size: INTEGER; Stream: TStream);
VAR
	p		: PChar;
BEGIN
	NewImage;
	FreePalette;
	NewBitmap;
	WITH FImage DO
	BEGIN
		FData.Free ;
		FData := TMemoryStream.Create ;
		FData.Size := Size;
		Stream.ReadBuffer(FData.Memory^, Size);

		(* header + size *)
		p := PChar( MagGetHeader(FData.Memory, FID, FComment) );
		IF p = NIL THEN
			MagError( 'is not MAG.' ) ;
		Move(p^, FHeader, SizeOf(TMagHeader));

		SetLength(FUser, 18);
		Move(FID.User[1], FUser[1], 18);
		FHalfHeight := msHalfHeight IN FHeader.ScreenMode;
		FTop := FHeader.BeginY;
		FLeft:= FHeader.BeginX;
		FWidth := MagImageWidth(FHeader);
		FHeight := MagImageHeight(FHeader);

		IF (ms256Colors IN FHeader.ScreenMode) THEN
		BEGIN
			FPixelFormat := mpf8Bit;
			FLeft := FLeft AND (NOT 3);
		END
		ELSE
		BEGIN
			FPixelFormat := mpf4Bit;
			FLeft := FLeft AND (NOT 7);
		END;
	END;

	Uncompress;
END;

(*--------------------------------------------------------------------*)
CONST
	MagBTableXW : ARRAY [0..15] OF BYTE = 
		( 0, 1, 2, 4, 0, 1, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0 ) ;

PROCEDURE TMAGImage.LoadPalette;
VAR
	p		: PChar;
	mpal	: TMagPalette256;
BEGIN
	FreePalette;

	p := FImage.FData.Memory;
	WHILE p^ <> #$00 DO
	BEGIN
		INC(p);
	END;
	INC(p, SizeOf(TMagHeader));

	MagReadPalette(p, FImage.FHeader, @mpal);
	FPalette := MagPaletteToHPalette(FImage.FHeader, @mpal);

	PaletteModified := True;
END;

PROCEDURE TMAGImage.Uncompress;
VAR
	Lines		: PPointerList;
	pP, pPic	: PWORD;
	y			: INTEGER;

	PROCEDURE PutPixel(flag: BYTE; xx: INTEGER);
	VAR
		p: PWORD;
	BEGIN
		IF flag = 0 THEN
		BEGIN
			pPic^ := pP^;
			INC(pP);
		END
		ELSE
		BEGIN
			p := Lines^[ y - MagBTableY[flag] ];
			INC(p, xx - MagBTableXW[flag] );
			pPic^ := p^;
		END;
	END;

VAR
	pA, pB	: PBYTE;
	Mask	: BYTE;
	Buff	: PByteArray;
	x, w	: INTEGER;
BEGIN
	(* init bitmap *)
	FBitmap.Width := FImage.FWidth;
	FBitmap.Height := FImage.FHeight;
	IF (ms256Colors IN FImage.FHeader.ScreenMode) THEN
		FBitmap.PixelFormat := pf8bit
	ELSE
		FBitmap.PixelFormat := pf4bit;
	LoadPalette;
	FBitmap.Palette := CopyPalette(FPalette);

	(* init *)
	pA := PBYTE( StrEnd(PAnsiChar(FImage.FData.Memory)) );
	pB := pA;
	pP := PWORD(pA);
	INC(pA, FImage.FHeader.FlagAOfs );
	INC(pB, FImage.FHeader.FlagBOfs ) ;
	INC(PBYTE(pP), FImage.FHeader.PixelOfs ) ;
	Mask := $80;

	w := FImage.FWidth DIV 4;
	IF FPixelFormat = mpf4Bit THEN
		w := w DIV 2;
	Buff := AllocMem(w);
	TRY
		Lines := AllocMem(SizeOf(POINTER) * FImage.FHeight);
		TRY
			(* アクセス速度を上げるため、あらかじめラインの先頭アドレスを設定 *)
			(*  ScanLine 呼び出しごとにラインの先頭アドレスが変わるのも回避する *)
			pPic := FBitmap.ScanLine[FImage.FHeight-1];
			FOR y := FImage.FHeight-1 DOWNTO 0 DO
			BEGIN
				Lines^[y] := pPic;
				INC(pPic, w*2);
			END;

			(* pixel *)
			FOR y := 0 TO FImage.FHeight-1 DO
			BEGIN
				pPic := Lines^[y];
				FOR x := 0 TO w-1 DO
				BEGIN
					IF (pA^ AND Mask)<>0 THEN
					BEGIN
						Buff^[x] := Buff^[x] XOR pB^;
						INC(pB) ;
					END ;

					Mask := Mask SHR 1;
					IF Mask = $00 THEN
					BEGIN
						Mask := $80 ;
						INC(pA) ;
					END ;

					PutPixel(Buff^[x] SHR 4, x*2);//LoNibble(Buff^[x]), x*2);
					INC(pPic);
					PutPixel(Buff^[x] AND $0F, x*2+1);//HiNibble(Buff^[x]), x*2+1);
					INC(pPic);
				END ;
			END ;
		FINALLY
			FreeMem(Lines);
		END;
	FINALLY
		FreeMem(Buff);
	END;
	Changed(Self);
END;

(*--------------------------------------------------------------------*)
(*--------------------------------------------------------------------*)
PROCEDURE TMAGImage.CompressPixel(FlagA: PBYTE; FlagB, Pixel: TStream);
VAR
	Lines	: PPointerList;
	y		: INTEGER;
	pPic	: PWORD;

	FUNCTION SearchPixel(x: INTEGER; upper: BYTE): BYTE;
	VAR
		p	: PWORD;
	BEGIN
		(* 真上のフラグと同じのほうが圧縮率がよい *)
		Result := upper;
		IF (Result <> 0) AND ((y - MagBTableY[Result]) >= 0) AND ((x - MagBTableXW[Result]) >= 0) THEN
		BEGIN
			p := Lines^[ y - MagBTableY[Result] ];
			INC(p, x - MagBTableXW[Result] );
			IF pPic^ = p^ THEN	Exit;
		END;

		FOR Result := 1 TO 15 DO
		BEGIN
			IF ((y - MagBTableY[Result]) >= 0) AND ((x - MagBTableXW[Result]) >= 0) THEN
			BEGIN
				p := Lines^[ y - MagBTableY[Result] ];
				INC(p, x - MagBTableXW[Result] );
				IF pPic^ = p^ THEN	Exit;
			END;
		END;
		Result := 0;
	END;

VAR
	Buff	: PByteArray;
	x, w	: INTEGER;
	bh, bl	: BYTE;
	Mask, b	: BYTE;
BEGIN
	Mask := $80;
	w := FBitmap.Width DIV 4;
	IF FPixelFormat = mpf4Bit THEN
		w := w DIV 2;

	Buff := AllocMem(w);
	TRY
		Lines := AllocMem(SizeOf(POINTER) * FBitmap.Height);
		TRY
			(* アクセス速度を上げるため、あらかじめラインの先頭アドレスを設定 *)
			(*  ScanLine 呼び出しごとにラインの先頭アドレスが変わるのも回避する *)
			pPic := FBitmap.ScanLine[FBitmap.Height-1];
			FOR y := FBitmap.Height-1 DOWNTO 0 DO
			BEGIN
				Lines^[y] := pPic;
				INC(pPic, w*2);
			END;

			(* pixel *)
			FOR y := 0 TO FBitmap.Height-1 DO
			BEGIN
				pPic := Lines^[y];
				FOR x := 0 TO w-1 DO
				BEGIN
					bl := SearchPixel(x*2, Buff^[x] SHR 4);
					IF bl = 0 THEN		Pixel.WriteBuffer(pPic^, SizeOf(WORD));
					INC(pPic);
					bh := SearchPixel(x*2+1, Buff^[x] AND $0F);
					IF bh = 0 THEN		Pixel.WriteBuffer(pPic^, SizeOf(WORD));
					INC(pPic);

					(* １ライン上のフラグと XOR なのだ *)
					b := Buff^[x] XOR ((bl SHL 4) OR bh);
					Buff^[x] := (bl SHL 4) OR bh;
					IF b <> $00 THEN
					BEGIN
						FlagA^ := FlagA^ OR Mask;
						FlagB.WriteBuffer(b, SizeOf(BYTE));
					END;

					Mask := Mask SHR 1;
					IF Mask = $00 THEN
					BEGIN
						Mask := $80 ;
						INC(FlagA);
					END;
				END;
			END ;
		FINALLY
			FreeMem(Lines);
		END;
	FINALLY
		FreeMem(Buff);
	END;

	(* 正規化 *)
	b := $00;
	IF (FlagB.Size MOD 2) = 1 THEN
		FlagB.WriteBuffer(b, SizeOf(BYTE));
END;


(*--------------------------------------------------------------------*)
PROCEDURE TMAGImage.Compress;
VAR
	A		: PBYTE;
	B, P	: TMemoryStream;
	pal		: TMagPalette256;
	ASize	: CARDINAL;
	colors	: INTEGER;
BEGIN
	IF FBitmap = NIL THEN
		MagInvaild('not have DIB');

	NewImage;
	colors := 256;

	ASize := ((FBitmap.Width DIV 4) * FBitmap.Height) DIV 8;
	IF FPixelFormat = mpf4Bit THEN
	BEGIN
		ASize := ASize DIV 2;//((FBitmap.Width DIV 8) * FBitmap.Height) DIV 8;
		colors := 16;
	END;
	(* 正規化 *)
	IF (ASize MOD 2) = 1 THEN	INC(ASize);

	WITH FImage DO
	BEGIN
		FData.Free;
		FData := TMemoryStream.Create;

		Move(FUser[1], FID.User[1], Length(FUser));
		FWidth := FBitmap.Width;
		FHeight := FBitmap.Height;

		(* set Header *)
		FillChar(FHeader, SizeOf(FHeader), $00);
		FHeader.BeginX := FLeft;
		FHeader.BeginY := FTop;
		FHeader.EndX := FLeft + FBitmap.Width-1;
		FHeader.EndY := FTop + FBitmap.Height-1;
		IF FPixelFormat = mpf8Bit THEN
			Include(FHeader.ScreenMode, ms256Colors);
		IF FHalfHeight THEN
			Include(FHeader.ScreenMode, msHalfHeight);

		FHeader.FlagAOfs := (SizeOf(TMagPalette) * colors) + SizeOf(FHeader);
		FHeader.FlagBOfs := FHeader.FlagAOfs + ASize;

		HPaletteToMagPalette(FHeader, FBitmap.Palette, @pal);

		(* コメント部を先に書き出しておく *)
		FData.WriteBuffer(FID, SizeOf(FID));
		IF (Length(FComment) MOD 2) = 0 THEN
			FComment := FComment + ' ';
		FData.WriteBuffer(FComment[1], Length(FComment));
		FData.WriteBuffer(MagCommentEnd, 1);

		P := TMemoryStream.Create;
		TRY
			B := TMemoryStream.Create;
			TRY
				A := AllocMem(ASize);
				TRY
					(* 圧縮 *)
					CompressPixel(A, B, P);

					FHeader.FlagBSize := B.Size;
					FHeader.PixelOfs := FHeader.FlagBOfs + B.Size;
					FHeader.PixelSize := P.Size;

					(* 書き出し *)
					FData.WriteBuffer(FHeader, SizeOf(FHeader));
					FData.WriteBuffer(pal, SizeOf(TMagPalette)*colors);
					FData.WriteBuffer(A^, ASize);
					FData.CopyFrom(B, 0);
					FData.CopyFrom(P, 0);
				FINALLY
					FreeMem(A);
				END;
			FINALLY
				B.Free;
			END;
		FINALLY
			P.Free;
		END;
	END;	(* with FImage *)
	Modified := FALSE;
END;


(**********************************************************************
//{###init & final
 **********************************************************************)
(* use design *)
PROCEDURE Register;
BEGIN
END;

INITIALIZATION
	TPicture.RegisterFileFormat('MAG', 'MAki chan Graphic format', TMAGImage);

FINALIZATION
	TPicture.UnregisterGraphicClass(TMAGImage);

(***********************************************************************)
END.
