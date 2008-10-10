unit jvIcon;

{ jvIcon is written/copyright by Jan Verhoeven

  Date: 16-september-1999

  Email: jan1.verhoeven@wxs.nl

  website: http://members.xoom.com/JanVee/jfdelphi.htm}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TjvIcon = class(TComponent)
  private
    { Private declarations }
    procedure WriteIcon(Stream: TStream; Icon: HICON; WriteLength: Boolean);
    function BytesPerScanline(PixelsPerScanline, BitsPerPixel,
      Alignment: Integer): Longint;
    procedure CheckBool(Result: Bool);
    procedure InitializeBitmapInfoHeader(Bitmap: HBITMAP;
      var BI: TBitmapInfoHeader; Colors: Integer);
    function InternalGetDIB(Bitmap: HBITMAP; Palette: HPALETTE;
      var BitmapInfo; var Bits; Colors: Integer): Boolean;
    procedure InternalGetDIBSizesA(Bitmap: HBITMAP; var InfoHeaderSize,
      ImageSize: DWORD; Colors: Integer);
    procedure InvalidBitmap;
    procedure InvalidGraphic(const Str: string);
    procedure WinError;
  protected
    { Protected declarations }
  public
    { Public declarations }
    function  CreateIcon(ABitmap:TBitmap):TIcon;
    procedure SaveToFileIcon16(AIcon:Ticon;Afile:string);
    procedure SaveToFileIcon256(AIcon:Ticon;Afile:string);
    procedure SaveAsIcon16(ABitmap:TBitmap;Afile:string);
    procedure SaveAsIcon256(ABitmap:TBitmap;Afile:string);    
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('jans', [TjvIcon]);
end;


resourcestring
  SInvalidBitmap = 'Bitmap image is not valid';

const
  rc3_Icon = 1;

type
  EInvalidGraphic = class(Exception);


procedure TjvIcon.SaveToFileIcon16(AIcon:Ticon;Afile:string);
begin
     AIcon.SaveToFile (Afile);
end;

procedure TjvIcon.SaveToFileIcon256(AIcon:Ticon;Afile:string);
var
   fs:TFilestream;
begin
     fs:=Tfilestream.Create (afile, fmcreate or fmopenwrite);
     writeIcon(fs,AIcon.handle,false);
     fs.Free;
end;


function TjvIcon.CreateIcon(ABitmap:TBitmap):TIcon;
var
  IconSizeX : integer;
  IconSizeY : integer;
  XOrMask : TBitmap;
  MonoMask:TBitmap;
  BlackMask:TBitmap;
  IconInfo : TIconInfo;
  R:trect;
  transcolor:Tcolor;
begin
 {Get the icon size}
  //IconSizeX := GetSystemMetrics(SM_CXICON);
  //IconSizeY := GetSystemMetrics(SM_CYICON);
  IconSizeX := ABitmap.Width;
  IconSizeY := ABitmap.Height;
  R:=Rect(0, 0, IconSizeX, IconSizeY);


 {Create the "XOr" mask}
  XOrMask := TBitmap.Create;
  XOrMask.Width := IconSizeX;
  XOrMask.Height := IconSizeY;

  {stretchdraw mypaint}
  XorMask.canvas.draw(0,0,Abitmap);
  transcolor:=XorMask.Canvas.Pixels [0,IconSizeY-1];

 {Create the Monochrome mask}
  MonoMask := TBitmap.Create;
  MonoMask.Width := IconSizeX;
  MonoMask.Height := IconSizeY;
  MonoMask.Canvas.Brush.Color := Clwhite;
  MonoMask.Canvas.FillRect(R);

 {Create the Black mask}
  BlackMask := TBitmap.Create;
  BlackMask.Width := IconSizeX;
  BlackMask.Height := IconSizeY;


 {if black is not the transcolor we must replace black
  with a temporary color}
  if transcolor<>clblack then begin
   BlackMask.Canvas.Brush.Color := $F8F9FA;
   BlackMask.Canvas.FillRect(R);
   BlackMask.canvas.BrushCopy(R,XorMask,R,clblack);
   XorMask.Assign (BlackMask);
   end;

  {now make the black mask}
  BlackMask.Canvas.Brush.Color := Clblack;
  BlackMask.Canvas.FillRect(R);

 {draw the XorMask with brushcopy}
  BlackMask.canvas.BrushCopy(R,XorMask,R,transcolor);
  XorMask.Assign (BlackMask);

 {Assign and draw the mono mask}
  XorMask.Transparent:=true;
//  XorMask.TransparentColor :=transcolor;
  XorMask.TransparentColor :=clblack;
  MonoMask.Canvas.draw(0,0,XorMask);
  MonoMask.canvas.copymode:=cmsrcinvert;
  MonoMask.canvas.CopyRect (R,XorMask.canvas,R);
  MonoMask.monochrome:=true;

//  XorMask.transparent:=false;

  {restore the black color in the image}
  BlackMask.Canvas.Brush.Color := Clblack;
  BlackMask.Canvas.FillRect(R);
  BlackMask.canvas.BrushCopy(R,XorMask,R,$F8F9FA);
  XorMask.Assign (BlackMask);


 {Create a icon}
  result := TIcon.Create;
  IconInfo.fIcon := true;
  IconInfo.xHotspot := 0;
  IconInfo.yHotspot := 0;
  IconInfo.hbmMask := MonoMask.Handle;
  IconInfo.hbmColor := XOrMask.Handle;
  result.Handle := CreateIconIndirect(IconInfo);

 {Destroy the temporary bitmaps}
  XOrMask.Free;
  MonoMask.free;
  BlackMask.free;
end;

procedure TjvIcon.WinError;
begin
end;



procedure TjvIcon.CheckBool(Result: Bool);
begin
  if not Result then WinError;
end;

function TjvIcon.BytesPerScanline(PixelsPerScanline, BitsPerPixel, Alignment: Longint): Longint;
begin
  Dec(Alignment);
  Result := ((PixelsPerScanline * BitsPerPixel) + Alignment) and not Alignment;
  Result := Result div 8;
end;

procedure TjvIcon.InvalidGraphic(const Str: string);
begin
  raise EInvalidGraphic.Create(Str);
end;

procedure TjvIcon.InvalidBitmap;
begin
  InvalidGraphic(SInvalidBitmap);
end;


procedure TjvIcon.InitializeBitmapInfoHeader(Bitmap: HBITMAP; var BI: TBitmapInfoHeader;
  Colors: Integer);
var
  DS: TDIBSection;
  Bytes: Integer;
begin
  DS.dsbmih.biSize := 0;
  Bytes := GetObject(Bitmap, SizeOf(DS), @DS);
  if Bytes = 0 then InvalidBitmap
  else if (Bytes >= (sizeof(DS.dsbm) + sizeof(DS.dsbmih))) and
    (DS.dsbmih.biSize >= DWORD(sizeof(DS.dsbmih))) then
    BI := DS.dsbmih
  else
  begin
    FillChar(BI, sizeof(BI), 0);
    with BI, DS.dsbm do
    begin
      biSize := SizeOf(BI);
      biWidth := bmWidth;
      biHeight := bmHeight;
    end;
  end;
  if Colors <> 0 then
    case Colors of
      2: BI.biBitCount := 1;
      16: BI.biBitCount := 4;
      256: BI.biBitCount := 8;
    end
  else BI.biBitCount := DS.dsbm.bmBitsPixel * DS.dsbm.bmPlanes;
  BI.biPlanes := 1;
  if BI.biSizeImage = 0 then
    BI.biSizeImage := BytesPerScanLine(BI.biWidth, BI.biBitCount, 32) * Abs(BI.biHeight);
end;



procedure TjvIcon.InternalGetDIBSizesA(Bitmap: HBITMAP; var InfoHeaderSize: DWORD;
  var ImageSize: DWORD; Colors: Integer);
var
  BI: TBitmapInfoHeader;
begin
  InitializeBitmapInfoHeader(Bitmap, BI, Colors);
  if BI.biBitCount > 8 then
  begin
    InfoHeaderSize := SizeOf(TBitmapInfoHeader);
    if (BI.biCompression and BI_BITFIELDS) <> 0 then
      Inc(InfoHeaderSize, 12);
  end
  else
    InfoHeaderSize := SizeOf(TBitmapInfoHeader) + SizeOf(TRGBQuad) *
      (1 shl BI.biBitCount);
  ImageSize := BI.biSizeImage;
end;

function TjvIcon.InternalGetDIB(Bitmap: HBITMAP; Palette: HPALETTE;
  var BitmapInfo; var Bits; Colors: Integer): Boolean;
var
  OldPal: HPALETTE;
  DC: HDC;
begin
  InitializeBitmapInfoHeader(Bitmap, TBitmapInfoHeader(BitmapInfo), Colors);
  OldPal := 0;
  DC := CreateCompatibleDC(0);
  try
    if Palette <> 0 then
    begin
      OldPal := SelectPalette(DC, Palette, False);
      RealizePalette(DC);
    end;
    Result := GetDIBits(DC, Bitmap, 0, TBitmapInfoHeader(BitmapInfo).biHeight, @Bits,
      TBitmapInfo(BitmapInfo), DIB_RGB_COLORS) <> 0;
  finally
    if OldPal <> 0 then SelectPalette(DC, OldPal, False);
    DeleteDC(DC);
  end;
end;


procedure TjvIcon.WriteIcon(Stream: TStream; Icon: HICON; WriteLength: Boolean);
type
  TCursorOrIcon = packed record
    Reserved: Word;
    wType: Word;
    Count: Word;
  end;
  PIconRec = ^TIconRec;
  TIconRec = packed record
    Width: Byte;
    Height: Byte;
    Colors: Word;
    Reserved1: Word;
    Reserved2: Word;
    DIBSize: Longint;
    DIBOffset: Longint;
  end;

var
  IconInfo: TIconInfo;
  MonoInfoSize, ColorInfoSize: DWORD;
  MonoBitsSize, ColorBitsSize: DWORD;
  MonoInfo, MonoBits, ColorInfo, ColorBits: Pointer;
  CI: TCursorOrIcon;
  List: TIconRec;
  Length: Longint;
begin
  FillChar(CI, SizeOf(CI), 0);
  FillChar(List, SizeOf(List), 0);
  CheckBool(GetIconInfo(Icon, IconInfo));
  try
    InternalGetDIBSizesA(IconInfo.hbmMask, MonoInfoSize, MonoBitsSize, 2);
    InternalGetDIBSizesA(IconInfo.hbmColor, ColorInfoSize, ColorBitsSize, 256);
    MonoInfo := nil;
    MonoBits := nil;
    ColorInfo := nil;
    ColorBits := nil;
    try
      MonoInfo := AllocMem(MonoInfoSize);
      MonoBits := AllocMem(MonoBitsSize);
      ColorInfo := AllocMem(ColorInfoSize);
      ColorBits := AllocMem(ColorBitsSize);
      InternalGetDIB(IconInfo.hbmMask, 0, MonoInfo^, MonoBits^, 2);
      InternalGetDIB(IconInfo.hbmColor, 0, ColorInfo^, ColorBits^, 256);
      if WriteLength then
      begin
        Length := SizeOf(CI) + SizeOf(List) + ColorInfoSize +
          ColorBitsSize + MonoBitsSize;
        Stream.Write(Length, SizeOf(Length));
      end;
      with CI do
      begin
        CI.wType := RC3_ICON;
        CI.Count := 1;
      end;
      Stream.Write(CI, SizeOf(CI));
      with List, PBitmapInfoHeader(ColorInfo)^ do
      begin
        Width := biWidth;
        Height := biHeight;
        Colors := biPlanes * biBitCount;
        DIBSize := ColorInfoSize + ColorBitsSize + MonoBitsSize;
        DIBOffset := SizeOf(CI) + SizeOf(List);
      end;
      Stream.Write(List, SizeOf(List));
      with PBitmapInfoHeader(ColorInfo)^ do
        Inc(biHeight, biHeight); { color height includes mono bits }
      Stream.Write(ColorInfo^, ColorInfoSize);
      Stream.Write(ColorBits^, ColorBitsSize);
      Stream.Write(MonoBits^, MonoBitsSize);
    finally
      FreeMem(ColorInfo, ColorInfoSize);
      FreeMem(ColorBits, ColorBitsSize);
      FreeMem(MonoInfo, MonoInfoSize);
      FreeMem(MonoBits, MonoBitsSize);
    end;
  finally
    DeleteObject(IconInfo.hbmColor);
    DeleteObject(IconInfo.hbmMask);
  end;
end;



procedure TjvIcon.SaveAsIcon16(ABitmap: TBitmap; Afile: string);
var ic:Ticon;
begin
 ic:=CreateIcon(Abitmap);
 SavetoFileIcon16(ic,afile);
 ic.free;
end;

procedure TjvIcon.SaveAsIcon256(ABitmap: TBitmap; Afile: string);
var ic:Ticon;
begin
 ic:=CreateIcon(Abitmap);
 SavetoFileIcon256(ic,afile);
 ic.free;
end;

end.
