library nako_exif;

uses
  FastMM4 in 'FastMM4.pas',
  Windows, SysUtils, Classes,
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',

  jpeg,
  graphics,
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  unit_exif in 'hi_unit\unit_exif.pas',
  JpegEx in 'hi_unit\JpegEx.pas',
  ABitmap in 'vnako_unit\ABitmap.pas',
  ABitmapFilters in 'vnako_unit\ABitmapFilters.PAS',
  unit_exif_taglist in 'hi_unit\unit_exif_taglist.pas',
  unit_string2 in 'hi_unit\unit_string2.pas';


const
  NAKO_EXIF_DLL_VERSION = '1.5041';

//------------------------------------------------------------------------------
// 以下関数
//------------------------------------------------------------------------------
function getNakoExifDllVersion(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(NAKO_EXIF_DLL_VERSION);
end;

function exif_extract(h: DWORD): PHiValue; stdcall;
var
  j: TKJpegInfo;
  res, fname: string;
begin
  Result := nil;
  fname := getArgStr(h, 0, True);
  //
  j := TKJpegInfo.Create;
  try
    j.LoadFromFile(fname, False);
    res := j.ExtractExifSegmentStr;
    Result := hi_newStr(res);
  finally
    FreeAndNil(j);
  end;
end;

function exif_embed(h: DWORD): PHiValue; stdcall;
var
  j: TKJpegInfo;
  fname, s: string;
begin
  Result := nil;
  fname  := getArgStr(h, 0, True);
  s      := getArgStr(h, 1);
  //
  j := TKJpegInfo.Create;
  try
    if j.LoadFromFile(fname, False) = False then
    begin
      Result := hi_newBool(False);
      Exit;
    end;
    try
      j.SwapExifSegmentStr(s);
      j.SaveToFile(fname);
      Result := hi_newBool(True);
    except
      Result := hi_newBool(False);
    end;
  finally
    FreeAndNil(j);
  end;
end;

function exif_remove(h: DWORD): PHiValue; stdcall;
var
  j: TKJpegInfo;
  fname: string;
begin
  Result := nil;
  fname := getArgStr(h, 0, True);
  //
  j := TKJpegInfo.Create;
  try
    j.LoadFromFile(fname, False);
    j.RemoveExif;
    j.SaveToFile(fname);
  finally
    FreeAndNil(j);
  end;
end;


function exif_thumb_extract(h: DWORD): PHiValue; stdcall;
var
  j: TKJpegInfo;
  mainfile, subfile: string;
  exif_stream: TMemoryStream;
  exif: TKRawExif;
begin
  Result := nil;
  mainfile := getArgStr(h, 0, True);
  subfile  := getArgStr(h, 1);
  //
  j := TKJpegInfo.Create;
  try
    j.LoadFromFile(mainfile, False);
    exif_stream := j.ExtractExifSegment;
    if exif_stream <> nil then
    begin
      exif := TKRawExif.Create(exif_stream);
      try
        if exif.thumb <> nil then
        begin
          exif.thumb.SaveToFile(subfile);
        end else
        begin // no thumbnail
        end;
      finally
        FreeAndNil(exif);
        FreeAndNil(exif_stream);
      end;
    end else
    begin
      // no thumbnail
    end;
  finally
    FreeAndNil(j);
  end;
end;

function exif_thumb_embed(h: DWORD): PHiValue; stdcall;
var
  j: TKJpegInfo;
  mainfile, subfile: string;
  exif_stream, new_exif: TMemoryStream;
  exif: TKRawExif;
begin
  Result := nil;
  mainfile := getArgStr(h, 0, True);
  subfile  := getArgStr(h, 1);
  //
  j := TKJpegInfo.Create;
  try
    j.LoadFromFile(mainfile, False);
    exif_stream := j.ExtractExifSegment;
    if exif_stream <> nil then
    begin
      exif := TKRawExif.Create(exif_stream);
      try
        exif.thumb.LoadFromFile(subfile);
        new_exif := exif.genExifData;
        try
          j.SwapExifSegment(new_exif);
          j.SaveToFile(mainfile);
        finally
          FreeAndNil(new_exif);
        end;
      finally
        FreeAndNil(exif);
        FreeAndNil(exif_stream);
      end;
    end else
    begin
      raise Exception.Create('基本となるExifデータを『EXIFブロック埋込』で先に埋め込んでから実行してください。');
    end;
  finally
    FreeAndNil(j);
  end;
end;

function getSampling: TJPEGSamplingRate;
var
  p: PHiValue;
  s: string;
begin
  p := nako_getVariable('JPEGEXサンプリング率');
  s := hi_str(p);
  if s = '4:1:1' then Result := jsr411 else
  if s = '4:2:2' then Result := jsr422 else
  if s = '4:4:4' then Result := jsr444 else
  raise Exception.Create('『JPEGEXサンプリング率』は4:1:1,4:2:2,4:4:4から選択してください');
end;

function getSamplingToStr(j:TJPEGSamplingRate): string;
begin
  case j of
    jsr411: Result := '4:1:1';
    jsr422: Result := '4:2:2';
    jsr444: Result := '4:4:4';
    else    Result := 'custom';
  end;
end;

function getCompQ: Integer;
var
  p: PHiValue;
begin
  p := nako_getVariable('JPEGEX圧縮率');
  Result := hi_int(p);
end;

function exif_jpegex_save(h: DWORD): PHiValue; stdcall;
var
  fname1, fname2: string;
  ww, hh:Integer;
  j2: TJpegEx;
  j: TJpegImage;

  function _jpegex_resize(j:TJpegImage; w: Integer; h: Integer): TJpegEx;
  var
    bmp: TBitmap;
  begin
    bmp := TBitmap.Create;
    try
      bmp.Width  := j.Width;
      bmp.Height := j.Height;
      bmp.PixelFormat := pf24bit;
      bmp.Canvas.Draw(0, 0, j);
      BMPAutoSizeChangeBlack(w,h, bmp);
      //
      Result := TJpegEx.Create;
      Result.Assign(bmp);
    finally
      FreeAndNil(bmp);
    end;
  end;

  procedure _checkExif;
  var
    ji, j2:TKJpegInfo;
    es:TMemoryStream;
  begin
    ji := TKJpegInfo.Create;
    try
      ji.LoadFromFile(fname1, False);
      if ji.hasAPP0 or ji.hasAPP1 then
      begin
        es := ji.ExtractExifSegment;
        j2 := TKJpegInfo.Create;
        try
          j2.LoadFromFile(fname2, False);
          j2.SwapExifSegment(es);
          j2.SaveToFile(fname2);
        finally
          es.Free;
          j2.Free;
        end;
      end;
    finally
      ji.Free;
    end;
  end;

begin
  Result := nil;
  fname1 := getArgStr(h, 0, True);
  ww := getArgInt(h, 1);
  hh := getArgInt(h, 2);
  fname2 := getArgStr(h, 3);
  j := TJpegImage.Create;
  try
    // load jpeg
    j.LoadFromFile(fname1);
    // save & resize
    j2 := _jpegex_resize(j, ww, hh);
    try
      j2.Sampling := getSampling;
      j2.CompressionQuality := getCompQ;
      j2.SaveToFile(fname2);
    finally
      FreeAndNil(j2);
    end;
    // check exif
    _checkExif;
  finally
    j.Free;
  end;
end;

function exif_getTagsIFD0(h: DWORD): PHiValue; stdcall;
var
  fname, res: string;
  j: TKJpegInfo;
  exif: TKRawExif;
begin
  res := '';
  fname := getArgStr(h, 0, True);
  j := TKJpegInfo.Create;
  try
    j.LoadFromFile(fname, False);
    exif := j.ExtractExifSegmentAsRawExifObj;
    try
      if (exif <> nil) and (exif.ifd0 <> nil) then
        res := exif.ifd0.getTagList;
    finally
      FreeAndNil(exif);
    end;
  finally
    FreeAndNil(j);
  end;
  Result := hi_newStr(res);
end;

function exif_setTagsIFD0(h: DWORD): PHiValue; stdcall;
var
  fname, s: string;
  j: TKJpegInfo;
  exif: TKRawExif;
  mem: TMemoryStream;
begin
  Result := nil;
  fname := getArgStr(h, 0, True);
  s     := getArgStr(h, 1);
  j := TKJpegInfo.Create;
  try
    j.LoadFromFile(fname, False);
    exif := j.ExtractExifSegmentAsRawExifObj;
    try
      if exif.ifd0 <> nil then
      begin
        exif.ifd0.setTagList(s);
        mem := exif.genExifData;
        if mem <> nil then
        begin
          j.SwapExifSegment(mem);
          j.SaveToFile(fname);
        end;
        FreeAndNil(mem);
      end;
    finally
      FreeAndNil(exif);
    end;
  finally
    FreeAndNil(j);
  end;
end;


function exif_exists(h: DWORD): PHiValue; stdcall;
var
  fname: string;
  j: TKJpegInfo;
begin
  Result := nil;
  fname := getArgStr(h, 0, True);
  j := TKJpegInfo.Create;
  try
    j.LoadFromFile(fname);
    Result := hi_newBool(j.HasExif);
  finally
    FreeAndNil(j);
  end;
end;

function exif_jpegex_sampling(h: DWORD): PHiValue; stdcall;
var
  fname: string;
  j: TJpegEx;
begin
  Result := nil;
  fname := getArgStr(h, 0, True);
  j := TJpegEx.Create;
  try
    j.LoadFromFile(fname);
    Result := hi_newStr(getSamplingToStr(j.Sampling));
  finally
    FreeAndNil(j);
  end;
end;

function exif_remove_app(h: DWORD): PHiValue; stdcall;
var
  fname: string;
begin
  fname := getArgStr(h, 0, True);
  JPEG_RemoveAppArea(fname);
  Result := nil;
end;

function exif_remove_app0(h: DWORD): PHiValue; stdcall;
var
  fname: string;
begin
  fname := getArgStr(h, 0, True);
  JPEG_RemoveAppArea(fname, True);
  Result := nil;
end;

function exif_elmonize(h: DWORD): PHiValue; stdcall;
var
  fname: string;
begin
  fname := getArgStr(h, 0, True);
  JPEG_Elmonize(fname);
  Result := nil;
end;

//------------------------------------------------------------------------------
// 以下絶対に必要な関数
//------------------------------------------------------------------------------
// 関数追加用
procedure ImportNakoFunction; stdcall;
begin
  // todo: ■関数を追加
  // nako_exif.dll,7100-7199
  // <命令>
  //+Jpeg/Exif処理
  //-Jpeg
  AddFunc('JPEGサムネイル抽出','{=?}FILE1からFILE2へ|FILE1をFILE2へ',  7100, exif_thumb_extract, '', 'JPEGさむねいるちゅうしゅつ');
  AddFunc('JPEGサムネイル埋込','{=?}FILE1にFILE2を|FILE1へ',  7101, exif_thumb_embed, '', 'JPEGさむねいるうめこむ');
  AddStrVar('JPEGEXサンプリング率','4:1:1',7102,'JPEGのサブサンプリングレートを指定する(JPEGxxx命令に限定)','JPEGEXさんぷりんぐりつ');
  AddIntVar('JPEGEX圧縮率',90,7103,'JPEGの圧縮率を指定する(JPEGxxx命令に限定)','JPEGEXあっしゅくりつ');
  AddFunc('JPEGEXリサイズ保存','{=?}FILE1をWIDTH,HEIGHTでFILE2へ',  7104, exif_jpegex_save, 'JPEG(FILE1)をWIDTH/HEIGHTでリサイズしてFILE2へ保存する。', 'JPEGEXりさいずほぞん');
  AddFunc('JPEGEXサンプリング率取得','{=?}FILEの',  7118, exif_jpegex_sampling, 'JPEG(FILE)のサンプリング率を文字列で返す。', 'JPEGEXさんぷりんぐりつしゅとく');
  AddFunc('JPEG_APP領域除去','{=?}FILEの',  7119, exif_remove_app, 'JPEG(FILE)のAPP0/1/2領域を削除する', 'JPEG_APPりょういきじょきょ');
  AddFunc('JPEG_APP0領域除去','{=?}FILEの', 7120, exif_remove_app0, 'JPEG(FILE)のAPP0領域を削除する', 'JPEG_APP0りょういきじょきょ');
  AddFunc('JPEG_E社形式変換','{=?}FILEの', 7121, exif_elmonize, 'JPEG(FILE)のAPP0領域を削除しE*社の形式に変換する', 'JPEG_Eしゃけいしきへんかん');

  //-Exif
  AddFunc('EXIFブロック抽出','{=?}FILEから|FILEの',  7110, exif_extract, 'JPEGファイルからEXIFを取りだして結果を文字列で返す', 'EXIFぶろっくちゅうしゅつ');
  AddFunc('EXIFブロック埋込','{=?}FILEにSを|FILEへ', 7111, exif_embed,   'JPEGファイルへ文字列S(EXIF)を埋め込みむ。そして実行結果を真偽型で返す', 'EXIFぶろっくうめこむ');
  AddFunc('EXIFブロック除去','{=?}FILEから|FILEの',  7112, exif_remove,  'JPEGファイルからEXIFを取り除く。', 'EXIFぶろっくじょきょ');
  AddFunc('EXIFタグ取得','{=?}FILEから|FILEの',  7114, exif_getTagsIFD0, 'JPEGファイルからExifタグを取り出して結果をハッシュ形式で返す。', 'EXIFたぐしゅとく');
  AddFunc('EXIFタグ設定','{=?}FILEにHASHを|FILEへ',  7115, exif_setTagsIFD0, 'JPEGファイルのExifをV(ハッシュ形式)に書き換える(一部のタグのみ対応/書き換えのみ対応)。', 'EXIFたぐせってい');
  AddFunc('EXIF存在','{=?}FILEに|FILEの',  7116, exif_exists, 'JPEGファイルにExifがあるかどうか調べる', 'EXIFそんざい');
  //-nako_exif.dll
  AddFunc('NAKO_EXIF_DLLバージョン','{=?}FILEに|FILEの',  7117, getNakoExifDllVersion, 'nako_exif.dllバージョンを返す', 'NAKO_EXIF_DLLばーじょん');
  // </命令>
end;

//------------------------------------------------------------------------------
// プラグインの情報
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
const STR_INFO = 'JPEG/EXIFプラグイン by クジラ飛行机';
begin
  Result := Length(STR_INFO);
  if (str <> nil)and(len > 0) then
  begin
    StrLCopy(str, STR_INFO, len);
  end;
end;

//------------------------------------------------------------------------------
// プラグインのバージョン
function PluginVersion: DWORD; stdcall;
begin
  Result := 2; // プラグイン自体のバージョン
end;

//------------------------------------------------------------------------------
// なでしこプラグインバージョン
function PluginRequire: DWORD; stdcall;
begin
  Result := 2; // 必ず2を返すこと
end;

procedure PluginInit(Handle: DWORD); stdcall;
begin
  dnako_import_initFunctions(Handle);
end;
function PluginFin: DWORD; stdcall;
begin
  Result := 0;
end;



exports
  ImportNakoFunction,
  PluginInfo,
  PluginVersion,
  PluginRequire,
  PluginInit;


begin
end.
