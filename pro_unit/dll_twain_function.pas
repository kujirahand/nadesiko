unit dll_twain_function;

interface

uses
  Windows,
  SysUtils,
  Classes,
  Graphics,
  GldPng,
  Jpeg;

procedure RegistFunction;

implementation

uses dll_plugin_helper, dnako_import, dnako_import_types, twain,
  TwainUtils;


//------------------------------------------------------------------------------
// 以下関数
//------------------------------------------------------------------------------

function dll_twain_select(h: DWORD): PHiValue; stdcall;
var
  res: Boolean;
begin
  res := False;
  try
    res := TwainDevice.SelectDevice(nako_getMainWindowHandle);
    //FreeTwain;
  except end;
  Result := hi_var_new;
  hi_setBool(Result, res);
end;

function dll_twain_scan(h: DWORD): PHiValue; stdcall;
var
  f, ext: string;
  res: Boolean;
  bmp: TBitmap;
  png: TGLDPNG;
  jpg: TJpegImage;
begin
  f := getArgStr(h, 0, True);
  res := False;
  bmp := TBitmap.Create;
  try
  try
    res := TwainDevice.TransferImage(bmp, True, nako_getMainWindowHandle);
    ext := LowerCase(ExtractFileExt(f));
    if ext = '.png' then
    begin
      bmp.PixelFormat := pf24bit;
      png := TGLDPNG.Create;
      png.Assign(bmp);
      png.SaveToFile(f);
      png.Free;
    end else
    if (ext = '.jpg')or(ext = '.jpeg') then
    begin
      bmp.PixelFormat := pf24bit;
      jpg := TJPEGImage.Create;
      jpg.Assign(bmp);
      jpg.SaveToFile(f);
      jpg.Free;
    end else
    begin
      bmp.SaveToFile(f);
    end;
    //FreeTwain;
  except
  end;
  finally
    bmp.Free;
  end;
  Result := hi_var_new;
  hi_setBool(Result, res);
end;

procedure RegistFunction;
begin
  // ＩＤの範囲:::6550-6559
  // <命令>
  //+スキャナー(nako_twain.dll)
  //-スキャナー
  AddFunc('TWAIN機器選択', '', 6550, dll_twain_select, 'TWAIN機器を選択する。選択を行うとはい(=1)を返す。', 'TWAINききせんたく');
  AddFunc('スキャナー読み取り', '{=?}FILEへ|FILEに', 6551, dll_twain_scan, 'スキャナーを読み取りFILEへ保存する。読み取るとはい(=1)を返す。', 'すきゃなーよみとり');
  // </命令>
end;

end.
