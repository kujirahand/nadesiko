unit unit_qrcode;

interface

uses
  SysUtils,
  Classes,
  Graphics,
  QRCode,
  gldpng;

var qr_option  : string;
var qr_version : Integer = 2;

procedure qr_makeCode(code:PChar; fname:PChar; bairitu:Integer);
procedure qr_setOpt(qr:TQRCode; code: string);

implementation

uses unit_string2;

procedure qr_setOpt(qr:TQRCode; code: string);
const
  qrver_w: array [1..10] of Integer = (21,25,29,33,37,41,45,49,53,57);
begin
  qr.SymbolPicture := psymBMP;
  qr.Eclevel := QR_ECL_M;
  qr.Version := qr_version;

  try
    qr.Width :=  qrver_w[qr_version];
  except
    qr.Width := 57;
  end;
  qr.Height := qr.Width;
  //
  //
  qr.RepaintSymbol;
  //
  if Pos('レベルL', qr_option) > 0 then qr.Eclevel := QR_ECL_L else
  if Pos('レベルM', qr_option) > 0 then qr.Eclevel := QR_ECL_M else
  if Pos('レベルQ', qr_option) > 0 then qr.Eclevel := QR_ECL_Q else
  if Pos('レベルH', qr_option) > 0 then qr.Eclevel := QR_ECL_H else
  ;
  //
  if Pos('数字モード', qr_option)    > 0 then qr.Emode := QR_EM_NUMERIC else
  if Pos('英数字モード', qr_option)  > 0 then qr.Emode := QR_EM_ALNUM   else
  if Pos('8ビットモード', qr_option) > 0 then qr.Emode := QR_EM_8BIT    else
  if Pos('漢字モード', qr_option)    > 0 then qr.Emode := QR_EM_KANJI   else
  ;
  // set CODE
  qr.Code := string(code);
end;

procedure qr_makeCode(code:PChar; fname:PChar; bairitu:Integer);
var
  arow, acol: Integer;
  f, ext: string;
  row, col, cell, ret, line, s: string;
  qr: TQRCode;
  bmp: TBitmap;
  x,y: Integer;
  png: TGldPng;
begin
  qr := TQRCode.Create(nil);
  try
    qr_setOpt(qr, code);
    ret := qr.PBM.Text;
    getToken_s(ret, #13#10);
    cell := getToken_s(ret, #13#10);
    col := Trim(getToken_s(cell, ' '));
    row := Trim(cell);
    arow := StrToInt(row);
    acol := StrToInt(col);
    ret := JReplace_(ret, ' ','');
    bmp := TBitmap.Create;
    try
      bmp.Width  := bairitu * arow;
      bmp.Height := bairitu * acol;
      bmp.PixelFormat := pf24bit;
      bmp.Canvas.Pen.Style := psClear;
      bmp.Canvas.Brush.Style := bsSolid;
      bmp.Canvas.Brush.Color := clWhite;
      bmp.Canvas.Rectangle(0,0,bmp.Width,bmp.Height);
      bmp.Canvas.Pen.Style := psSolid;
      bmp.Canvas.Pen.Color := clBlack;
      bmp.Canvas.Brush.Color := clBlack;
      for y := 0 to arow-1 do
      begin
        line := Trim(getToken_s(ret, #13#10));
        for x := 0 to acol-1 do
        begin
          s := Copy(line, x+1, 1);
          if s = '1' then
          begin
            if bairitu = 1 then
            begin
              bmp.Canvas.Pixels[x,y] := 0;
            end else
            begin
              bmp.Canvas.Rectangle(x*bairitu, y*bairitu, (x+1)*bairitu, (y+1)*bairitu);
            end;
          end else
          begin
            //
          end;
        end;
      end;
      f := fname;
      ext := lowercase(ExtractFileExt(f));
      if (ext = '.png') then
      begin
        png := TGLDPNG.Create;
        png.Assign(bmp);
        png.SaveToFile(f);
        png.Free;
      end else
      begin
        bmp.SaveToFile(f);
      end;
    finally
      FreeAndNil(bmp);
    end;
  finally
    FreeAndNil(qr);
  end;
end;

(*
procedure qr_makeCode(code:PChar; fname:PChar; bairitu:Integer);
var
  qr: TQRCode;
  png: TGldPng;
  s, ext: string;
  bmp: TBitmap;

begin
  qr := TQRCode.Create(nil);
  qr.Left := 0;
  qr.Top := 0;
  qr.Width := 32;
  qr.Height := 32;

  qr.SymbolLeft := 0;
  qr.SymbolTop  := 0;

  qr_setOpt(qr, code);

  //
  if qr.Width < qr.SymbolWidth then
  begin
    qr.Width  := qr.SymbolWidth;
    qr.Height := qr.SymbolHeight;
    qr.Code := string(code);
    qr.RepaintSymbol;
  end;
  bmp := TBitmap.Create;
  try
    bmp.PixelFormat := pf8bit;
    bmp.Width  := qr.Width * bairitu;
    bmp.Height := qr.Height * bairitu;
    bmp.Canvas.StretchDraw(RECT(0,0,bmp.Width,bmp.Height), qr.Picture.Graphic);
    //bmp.SaveToFile('bk.bmp');
    s := fname;
    ext := LowerCase(ExtractFileExt(s));

    if ext = '.png' then
    begin
      //bmp.PixelFormat := pf24bit;
      png := TGLDPNG.Create;
      png.Assign(bmp);
      png.SaveToFile(s);
      png.Free;
    end else
    begin
      bmp.SaveToFile(s);
    end;
  finally
    bmp.Free;
  end;
  ;
end;
*)

end.
