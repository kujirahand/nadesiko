(**********************************************************************
 *
 *	MAG
 *
 **********************************************************************)
UNIT MagTypes;

INTERFACE

USES
	Windows;

{$R-}  
(* Mag comments *)
CONST
	MagID : ARRAY [0..7] OF CHAR = 'MAKI02  ';
	MagCommentEnd : CHAR = #$1A;
	MagMachineDefault	= $00;(* 98/68 その他多く *)
	MagMachineMsx		= $03;(* msx  （Meron版) *)
	MagMachine88		= $88;(* 88    (Argon版) *)
	MagMachine68		= $68;(* PST68 (Kenna) *)
	MagMachineEse		= $FF;(* 似非キース (Hironon) *)

(*--------------------------------------------------------------------*)
TYPE
	TMagScreens = (
		msHalfHeight,	ms8Colors,		msDigitalColor,	msReserved1,	
		msReserved2,	msReserved3,	msReserved4,	ms256Colors	
	);
	TMagScreenFlag = SET OF TMagScreens;

(* Mag file header *)
TYPE
	PMagID = ^TMagID;
	TMagID = PACKED RECORD
		ID		: ARRAY [0..7] OF CHAR;
		Machine	: ARRAY [0..3] OF CHAR;
		User	: ARRAY [0..19] OF CHAR;
	END;(*RECORD*)

	PMagHeader = ^TMagHeader;
	TMagHeader = PACKED RECORD
		Head		: BYTE;			(* ヘッダの先頭 = $00 *)
		Machine		: BYTE;			(* 機種コード *)
		MachineFlag	: BYTE;			(* 機種依存フラグ *)
		ScreenMode	: TMagScreenFlag;(* スクリーンモード *)
		BeginX		: WORD;			(* 表示開始位置Ｘ *)
		BeginY		: WORD;			(* 表示開始位置Ｙ *)
		EndX		: WORD;			(* 表示終了位置Ｘ *)
		EndY		: WORD;			(* 表示終了位置Ｙ *)
		FlagAOfs	: CARDINAL;		(* フラグＡのオフセット *)
		FlagBOfs	: CARDINAL;		(* フラグＢのオフセット *)
		FlagBSize	: CARDINAL;		(* フラグＢのサイズ *)
		PixelOfs	: CARDINAL;		(* ピクセルのオフセット *)
		PixelSize	: CARDINAL;		(* ピクセルのサイズ *)
	END;(*RECORD*)

TYPE
	PMagPalette = ^TMagPalette;
	TMagPalette = PACKED RECORD
		Green, Red, Blue : BYTE;
	END;(*RECORD*)
	PMagPalette16 = ^TMagPalette16;
	TMagPalette16 = PACKED ARRAY [0..15] OF TMagPalette;
	PMagPalette256 = ^TMagPalette256;
	TMagPalette256 = PACKED ARRAY [0..255] OF TMagPalette;

CONST
	MagBTableX : ARRAY [0..15] OF BYTE = (
		0, 2, 4, 8, 0, 2, 0, 2, 4, 0, 2, 4, 0, 2, 4, 0
	);
	MagBTableY : ARRAY [0..15] OF BYTE = (
		0, 0, 0, 0, 1, 1, 2, 2, 2, 4, 4, 4, 8, 8, 8,16
	);
	MagEncodeSearch : ARRAY [0..15] OF BYTE = 
		( 0, 1, 4, 5, 6, 7, 9,10, 2, 8,11,12,13,14, 3,15 ) ;

(*--------------------------------------------------------------------*)
FUNCTION MagPaletteToHPalette(CONST header: TMagHeader; pal: PMagPalette): HPALETTE;
PROCEDURE HPaletteToMagPalette(CONST header: TMagHeader; hp: HPALETTE; pal : PMagPalette);

FUNCTION MagGetHeader(data : POINTER; VAR id : TMagID; VAR comment : STRING): PMagHeader;
FUNCTION MagReadPalette(data : POINTER; CONST header: TMagHeader; pal : PMagPalette): POINTER;
FUNCTION MagImageWidth(CONST header: TMagHeader): INTEGER;
FUNCTION MagImageHeight(CONST header: TMagHeader): INTEGER;
FUNCTION MagImageSize(CONST header: TMagHeader): INTEGER;

(**********************************************************************
//{###IMPLEMENTATION
 **********************************************************************)
IMPLEMENTATION

USES
	SysUtils;

(*--------------------------------------------------------------------*)
//##Mag utils

//##HPaletteToMagPalette
PROCEDURE HPaletteToMagPalette(CONST header: TMagHeader; hp: HPALETTE; pal : PMagPalette);
VAR
	p, p2 : PPaletteEntry;
	Num, i : INTEGER;
BEGIN
	IF ms256Colors IN header.ScreenMode THEN
		Num := 256
	ELSE
		Num := 16;

	GetMem(p, SizeOf(TPaletteEntry) * Num);
	GetPaletteEntries(hp, 0, Num, p^);
	p2 := p;
	FOR i := 0 TO Num-1 DO
	BEGIN
		pal^.Green := p2^.peGreen;
		pal^.Red := p2^.peRed;
		pal^.Blue := p2^.peBlue;
		INC(p2);
		INC(pal);
	END;
	FreeMem(p);
END;

{$IFDEF	OLDMAG}
PROCEDURE MagPalette16Load(VAR pal : TMagPalette16);
VAR
	i : INTEGER;
BEGIN
	FOR i := 0 TO 15 DO
	BEGIN
		pal[i].Green := (pal[i].Green SHR 4) * $11;
		pal[i].Red   := (pal[i].Red   SHR 4) * $11;
		pal[i].Blue  := (pal[i].Blue  SHR 4) * $11;
	END;
END;
{$ENDIF}

//##MagPaletteToHPalette
FUNCTION MagPaletteToHPalette(CONST header: TMagHeader; pal: PMagPalette): HPALETTE;
VAR
	p : PLogPalette;
	i, Num : INTEGER;
BEGIN
	IF ms256Colors IN header.ScreenMode THEN
		Num := 256
	ELSE
		Num := 16;

	GetMem(p, SizeOf(TLogPalette) + SizeOf(TPaletteEntry) * Num);
	p^.palVersion := $0300;
	p^.palNumEntries := Num;
	FOR i := 0 TO Num-1 DO
	BEGIN
		p^.palPalEntry[i].peRed   := pal^.Red;
		p^.palPalEntry[i].peGreen := pal^.Green;
		p^.palPalEntry[i].peBlue  := pal^.Blue;
		p^.palPalEntry[i].peFlags := 0;
		Inc(pal);
	END;
	Result := CreatePalette(p^);
	FreeMem(p);
END;

(*--------------------------------------------------------------------*)
//##MagReadHeader
FUNCTION MagGetHeader(data: POINTER; VAR id: TMagID; VAR comment: STRING): PMagHeader;
VAR
	ch, tmp : PChar;
	i : INTEGER;
BEGIN
	Result := NIL;

	Move(data^, id, SizeOf(TMagID));
	if CompareMem(@id.ID, @MagID, 8) = FALSE THEN
		Exit;
	ch := data;
	Inc(ch , SizeOf(TMagID));

	i := 0;
	tmp := ch;
	WHILE tmp^ <> MagCommentEnd DO
	BEGIN
		Inc(tmp);
		INC(i);
	END;
	SetLength(comment, i);
	Move(ch^, comment[1], i);
	ch := tmp;
	Inc(ch);
	Result := PMagHeader(ch);
END;

(*--------------------------------------------------------------------*)
//##MagReadPalette
FUNCTION MagReadPalette(data : POINTER; CONST header: TMagHeader; pal : PMagPalette): POINTER;
VAR
	Num : INTEGER;
BEGIN
	IF ms256Colors IN header.ScreenMode THEN
		Num := 256
	ELSE
		Num := 16;

	Move(data^, pal^, SizeOf(TMagPalette)*Num);
{$IFDEF OLDMAG}
	(* 古い MAG 形式なら 12bits なので必要だが、新しいものは不要 *)
	IF (Num = 16) THEN
		MagPalette16Load(PMagPalette16(pal)^);
{$ENDIF}
	Inc(PBYTE(data), SizeOf(TMagPalette)*Num);
	Result := data;
END;

(*--------------------------------------------------------------------*)
FUNCTION MagImageWidth(CONST header: TMagHeader): INTEGER;
VAR
	i: INTEGER;
BEGIN
	IF ms256Colors IN header.ScreenMode THEN
		i := 4
	ELSE
		i := 8;

	Result := (header.EndX - (header.EndX MOD i)+(i-1)) -
			(header.BeginX - (header.BeginX MOD i)) +1 ;
END;

FUNCTION MagImageHeight(CONST header: TMagHeader): INTEGER;
BEGIN
	Result := header.EndY - header.BeginY +1 ;
END;

FUNCTION MagImageSize(CONST header: TMagHeader): INTEGER;
BEGIN
	Result := MagImageHeight(header) * MagImageWidth(header) ;

	IF NOT(ms256Colors IN header.ScreenMode) THEN
		Result := Result DIV 2;
END;





(*--------------------------------------------------------------------*)

(**********************************************************************
 *	end of file.
 **********************************************************************)
END.
