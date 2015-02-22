unit unit_exif;

interface

uses
  Windows, Classes, SysUtils
//  ,Dialogs // for DEBUG
  ;

  // EXIF 一番分かりやすい解説
  // http://park2.wakwak.com/~tsuruzoh/Computer/Digicams/exif.html#JpegMarker

const
  JPEG_MARKER = #$FF;
  SOI    = JPEG_MARKER + #$D8; // Start Of Image
  EOI    = JPEG_MARKER + #$D9; // End Of Image
  APP0   = JPEG_MARKER + #$E0; // APP0 : JFIF format
  APP1   = JPEG_MARKER + #$E1; // APP1 : Exif Marker
  APP2   = JPEG_MARKER + #$E2; // APP2 : Color Profile
  SOS    = JPEG_MARKER + #$DA; // Stream
  COM_MAK= JPEG_MARKER + #$FE; // Comment Marker
  DQT    = JPEG_MARKER + #$DB;
  DHT    = JPEG_MARKER + #$C4;
  SOF0   = JPEG_MARKER + #$C0;

  BLOCK_IFD_BASE = 0;
  BLOCK_IFD_SUB = 1;
  BLOCK_IFD_IIFD = 2;
  BLOCK_IFD_GPS = 3;

  
  // === JPEG STRUCTURE
  // SOI
  // 0xFF??
  //    SSSS : UInt16 : Data Size
  //    Data..
  // EOI
  // ===
  //  0xFFE0：JFIF形式で使われるマーカ、APP0マーカと呼ばれる
  //  0xFFE1：Exif形式で使われるマーカ、APP1マーカと呼ばれる
  // === EXIF STRUCTURE
  // APP1
  //   APP1 SIZE (2byte)
  //   EXIF HEADER 0x45786966 0000 = 'Exif'#0#0 (6byte)
  //   TIFF HEADER (4 Byte) (II or MM) + 0x2A(WORD)
  //   LinkToFirst IFD  (DWORD:4byte)
  //   IFD0(Image File Directory No.0)
  //     Count Of Entry (2 Byte)
  //       Entry1    (12 Byte)
  //       Entry2..
  //       NextEntryLink (4 Byte)
  //         Data Area Entry IFD0
  //  IFD1 (Thumbnaiil Image **160x120)
  //     Count Of Entry
  //       Entry1..
  //       NextEntry

  EXIF_HEADER_ID = 'Exif'#0#0;
  TIFF_HEADER_ID_II = 'II'#$2A#$00;
  TIFF_HEADER_ID_MM = 'MM'#$00#$2A;
  //
  //
  // === EXIF DATA FORMAT
  TV_TYPE_UBYTE     = 1; // 1byte
  TV_TYPE_ASCII     = 2;
  TV_TYPE_USHORT    = 3; // 2byte
  TV_TYPE_ULONG     = 4;
  TV_TYPE_URATION   = 5; // 8byte
  TV_TYPE_SBYTE     = 6;
  TV_TYPE_UNDEFINED = 7;
  TV_TYPE_SSHORT    = 8;  // 2byte
  TV_TYPE_SLONG     = 9;  // 4byte
  TV_TYPE_SRATION   = 10; // 8byte
  TV_TYPE_SFLOAT    = 11; // 4byte
  TV_TYPE_SDOUBLE   = 12; // 8byte
  TV_TYPE_DATA_SIZE: Array [1..12] of Integer = (1,MaxInt,2,4,8,1,1,2,4,8,4,8);
  //
  EXIF_TAG_SUBIFD = $8769;
  EXIF_INTEROPERABILITY_OFFSET = $A005;
  //EXIF_TAG_GPSINFO = $8825;
  //
  EXIF_TAG_EXIF_IMAGE_WIDTH   = $0A002;
  EXIF_TAG_EXIF_IMAGE_HTIGHT  = $0A003;

  // for Thumbnail tag
  EXIF_TAG_COMPRESSION        = $0103; // 6(JPEG) / 1(TIFF)
  EXIF_TAG_JPEG_IF_OFFSET     = $0201; // JPEG
  EXIF_TAG_JPEG_IF_BYTE_COUNT = $0202;
  EXIF_TAG_STRIP_OFFSET       = $0111; // TIFF
  EXIF_TAG_STRIP_BYTE_COUNT   = $0117;


  // OLD CONVERT
  EXIF_TAG_DATETIMEORIGINAL = 36867;
  EXIF_TAG_DATETIME = 306;
  EXIF_TAG_EXPOSURETIME = 33434;
  EXIF_TAG_IMAGEWIDTH = 256;
  EXIF_TAG_IMAGELENGTH = 257;
  EXIF_TAG_BITSPERSAMPLE = 258;
  EXIF_TAG_PHOTOMETRICINTERPRETATION = 262;
  EXIF_TAG_FILLORDER = 266;
  EXIF_TAG_DOCUMENTNAME = 269;
  EXIF_TAG_IMAGEDESCRIPTION = 270;
  EXIF_TAG_MAKE = 271;
  EXIF_TAG_MODEL = 272;
  EXIF_TAG_STRIPOFFSETS = 273;
  EXIF_TAG_ORIENTATION = 274;
  EXIF_TAG_SAMPLESPERPIXEL = 277;
  EXIF_TAG_ROWSPERSTRIP = 278;
  EXIF_TAG_STRIPBYTECOUNTS = 279;
  EXIF_TAG_XRESOLUTION = 282;
  EXIF_TAG_YRESOLUTION = 283;
  EXIF_TAG_PLANARCONFIGURATION = 284;
  EXIF_TAG_RESOLUTIONUNIT = 296;
  EXIF_TAG_TRANSFERFUNCTION = 301;
  EXIF_TAG_SOFTWARE = 305;
  EXIF_TAG_ARTIST = 315;
  EXIF_TAG_WHITEPOINT = 318;
  EXIF_TAG_PRIMARYCHROMATICITIES = 319;
  EXIF_TAG_TRANSFERRANGE = 342;
  EXIF_TAG_JPEGPROC = 512;
  EXIF_TAG_JPEGINTERCHANGEFORMAT = 513;
  EXIF_TAG_JPEGINTERCHANGEFORMATLENGTH = 514;
  EXIF_TAG_YCBCRCOEFFICIENTS = 529;
  EXIF_TAG_YCBCRSUBSAMPLING = 530;
  EXIF_TAG_YCBCRPOSITIONING = 531;
  EXIF_TAG_REFERENCEBLACKWHITE = 532;
  EXIF_TAG_CFAREPEATPATTERNDIM = 33421;
  EXIF_TAG_CFAPATTERN = 33422;
  EXIF_TAG_BATTERYLEVEL = 33423;
  EXIF_TAG_COPYRIGHT = 33432;
  EXIF_TAG_FNUMBER = 33437;
  EXIF_TAG_IPTC_NAA = 33723;
  EXIF_TAG_EXIFOFFSET = 34665;
  EXIF_TAG_INTERCOLORPROFILE = 34675;
  EXIF_TAG_EXPOSUREPROGRAM = 34850;
  EXIF_TAG_SPECTRALSENSITIVITY = 34852;
  EXIF_TAG_GPSINFO = 34853;
  EXIF_TAG_ISOSPEEDRATINGS = 34855;
  EXIF_TAG_OECF = 34856;
  EXIF_TAG_EXIFVERSION = 36864;
  EXIF_TAG_DATETIMEDIGITIZED = 36868;
  EXIF_TAG_COMPONENTSCONFIGURATION = 37121;
  EXIF_TAG_COMPRESSEDBITSPERPIXEL = 37122;
  EXIF_TAG_SHUTTERSPEEDVALUE = 37377;
  EXIF_TAG_APERTUREVALUE = 37378;
  EXIF_TAG_BRIGHTNESSVALUE = 37379;
  EXIF_TAG_EXPOSUREBIASVALUE = 37380;
  EXIF_TAG_MAXAPERTUREVALUE = 37381;
  EXIF_TAG_SUBJECTDISTANCE = 37382;
  EXIF_TAG_METERINGMODE = 37383;
  EXIF_TAG_LIGHTSOURCE = 37384;
  EXIF_TAG_FLASH = 37385;
  EXIF_TAG_FOCALLENGTH = 37386;
  EXIF_TAG_MAKERNOTE = 37500;
  EXIF_TAG_USERCOMMENT = 37510;
  EXIF_TAG_SUBSECTIME = 37520;
  EXIF_TAG_SUBSECTIMEORIGINAL = 37521;
  EXIF_TAG_SUBSECTIMEDIGITIZED = 37522;
  EXIF_TAG_FLASHPIXVERSION = 40960;
  EXIF_TAG_COLORSPACE = 40961;
  EXIF_TAG_EXIFIMAGEWIDTH = 40962;
  EXIF_TAG_EXIFIMAGELENGTH = 40963;
  EXIF_TAG_INTEROPERABILITYOFFSET = 40965;
  EXIF_TAG_FLASHENERGY = 41483;
  EXIF_TAG_SPATIALFREQUENCYRESPONSE = 41484;
  EXIF_TAG_FOCALPLANEXRESOLUTION = 41486;
  EXIF_TAG_FOCALPLANEYRESOLUTION = 41487;
  EXIF_TAG_FOCALPLANERESOLUTIONUNIT = 41488;
  EXIF_TAG_SUBJECTLOCATION = 41492;
  EXIF_TAG_EXPOSUREINDEX = 41493;
  EXIF_TAG_SENSINGMETHOD = 41495;
  EXIF_TAG_FILESOURCE = 41728;
  EXIF_TAG_SCENETYPE = 41729;

type
  TKJpegInfo = class;
  TKJepgDebugOutProc = procedure (msg: string);

  TKTiffHead = record
    ByteOrder : Array [0..1] of Char; // 'II' or 'MM'
    TIFF_ID   : Array [0..1] of Char; // 2A00 or 002A
    Offset    : DWORD; // 0x00000008 = 8
  end;

  PKTiffIFDValue = ^TKTiffIFDValue;
  TKTiffIFDValue = record
    TagNo       : WORD;
    DataType    : WORD;
    DataCount   : DWORD;
    Value       : DWORD; // Value or Offset
  end;
  TKExifByteOrder = (II, MM);

  TKExifRationValue = packed record
    numerator:   DWORD; // 分子
    denominator: DWORD; // 分母
  end;

  TKTiffIFDValueIO = class
  private
    function GetDataFormat: Word;
    function GetTagNo: Word;
    function GetDataCount: DWORD;
    procedure SetDataCount(const Value: DWORD);
    function GetNativeData: DWORD;
    procedure SetNativeData(const Value: DWORD);
    function GetValueAscii: string;
    function GetValueUByte: Byte;
    function GetValueULong: DWORD;
    function GetValueUShort: WORD;
    function GetValueRational: TKExifRationValue;
    procedure SetValueUByte(const Value: Byte);
    procedure SetValueULong(const Value: DWORD);
    procedure SetValueUShort(const Value: WORD);
  protected
    FValue: PKTiffIFDValue;
    info: TKJpegInfo;
  public
    constructor Create(v: PKTiffIFDValue; info: TKJpegInfo);
    property DataFormat : Word read GetDataFormat;
    property TagNo      : Word read GetTagNo;
    property DataCount  : DWORD read GetDataCount write SetDataCount;
    property NativeData : DWORD read GetNativeData write SetNativeData;
    property ValueUByte : Byte read GetValueUByte write SetValueUByte;
    property ValueAscii : string read GetValueAscii;
    property ValueUShort: WORD read GetValueUShort write SetValueUShort;
    property ValueULong : DWORD read GetValueULong write SetValueULong;
  end;

  // TIFF Image File Directory
  TKTiffIFD = class
  private
    FIFDCount: DWORD;
    FValues: array of TKTiffIFDValue;
    FNextIFD: TKTiffIFD;
    FSubIFD: TKTiffIFD;
    FGpsIFD: TKTiffIFD;
    FBlock: Integer;
    FIFD_StartPos: DWORD;
  public
    offset: DWORD;
    stream: TMemoryStream;
    info:   TKJpegInfo;
    constructor Create(info: TKJpegInfo; Offset: DWORD; Block: Integer); // Tiff ヘッダの直後にしておくこと
    destructor Destroy; override;
    function FindValue(TagNo: WORD; Block: Integer): PKTiffIFDValue;
  public
    procedure WriteValues; // 書き換えたデータを上書きする(書き換えはOKだが、要素を追加してはならない)
    function getValue(TagNo: WORD; Block: Integer): TKTiffIFDValueIO; // 解放が必要
    property Count: DWORD read FIFDCount;
    property NextIFD: TKTiffIFD read FNextIFD;
  end;

  TKIFDIO = class;
  
  TKIFDEntry = class
  private
    function getTagNo: Integer;
    function getTagTyp: Integer;
    function getValue: DWORD;
    function getCount: DWORD;
    procedure setValue(const Value: DWORD);
  public
    value   : TKTiffIFDValue;
    data    : string;
    subIFD  : TKIFDIO;
    order: TKExifByteOrder;
    constructor Create(order:TKExifByteOrder); overload;
    constructor Create(Tag: WORD; Typ:WORD; Cnt:DWORD; Val:DWORD; order:TKExifByteOrder); overload;
    function checkWord(w: Word): Word;
    function checkDWord(w: DWord): DWord;
  public
    function getValueChar: Short;
    function getValueByte: Byte;
    function getValueShort: Short;
    function getValueUShort: WORD;
    function getValueULong: DWORD;
    function getValueLong: Integer;
    function getAscii: string;
    function toString: string;
    procedure setFromString(s: string);
    property TagNo: Integer read getTagNo;
    property Typ: Integer read getTagTyp;
    property DValue: DWORD read getValue write setValue;
    property Count: DWORD read getCount;
  end;

  TKIFDIO = class
  private
    stream: TMemoryStream;
    offset: Int64;
    order: TKExifByteOrder;
    EntryCount: Word;
    FBlock  : Integer;
    FNextIFD: DWORD;
    procedure ReadEntry;
    function readWord: WORD;
    function readDWord: DWORD;
    function checkWord(v:WORD):WORD;
    function checkDWord(v:DWORD):DWORD;
    procedure debug(msg: string);
  public
    list: TList;  // list of TKIFDEntry
    debugOut: TKJepgDebugOutProc;
    constructor Create(stream:TMemoryStream; Block: Integer; Offset:Int64; ByteOrder: TKExifByteOrder; debugOut: TKJepgDebugOutProc);
    destructor Destroy; override;
    procedure clear;
    function findTag(tagNo: Integer): TKIFDEntry;overload;
    function findTag(tagNo: Integer; Block: Integer): TKIFDEntry;overload;
    function getTagValue(tagNo: Integer): DWORD;overload;
    function getTagValue(tagNo: Integer; Block: Integer): DWORD;overload;
    function getThumbnail: TMemoryStream;
    procedure writeEntry(mem: TMemoryStream; offset: Int64; ExtDat: string; isLast: Boolean; subifd_pos: Int64 = 0);
    procedure writeEntryApp1(mem: TMemoryStream; offset: Int64; thumb: TMemoryStream; isLast: Boolean);
    function getTagList: string;
    procedure setTagList(tags: string);
    function getExifIndexFromTagNo(TagNo: Integer; Block: Integer): Integer;
    function getExifIndexFromTagName(TagName: string): Integer;
  published
    property NextIFD: DWORD read FNextIFD;
  end;

  TKRawExif = class
  private
    stream: TMemoryStream;
    procedure debug(msg:string);
    procedure readIFD;
    function getIFD0: TKIFDIO;
    function getMaker: string;
    function getModel: string;
    function getModifyDate: string;
    function getOrientation: Integer;
    function getTitle: string;
    procedure setMaker(const Value: string);
    procedure setModel(const Value: string);
    procedure setModifyDate(const Value: string);
    procedure setOrientation(const Value: Integer);
    procedure setTitle(const Value: string);
    function getCopyright: string;
    procedure setCopyright(const Value: string);
  protected
    function readStr(count:Integer): String;
    function CheckWord(b: Word): Word;
    function CheckDWord(b: DWord): DWord;
  public
    list: TList; // of TKIFDIO
    thumb: TMemoryStream;
    ByteOrder: TKExifByteOrder;
    Offset: Int64;
  public
    debugOut: TKJepgDebugOutProc;
    constructor Create(exif_stream: TMemoryStream; debugOut: TKJepgDebugOutProc = nil);
    destructor Destroy; override;
    procedure clear;
  public
    function genExifData: TMemoryStream;
    function getEntry(tag:Integer):TKIFDEntry;
    property ifd0: TKIFDIO read getIFD0;
    //
    function getValueAscii(tagNo: Integer): string;
    procedure setValueAscii(tagNo: Integer; value: string);
    //
    function getValueUShort(tagNo: Integer): Word;
    procedure setValueUShort(tagNo: Integer; value: Word);
  public
    property Title: string read getTitle write setTitle;
    property Maker: string read getMaker write setMaker;
    property Model: string read getModel write setModel;
    property ModifyDate: string read getModifyDate write setModifyDate;
    property Orientation: Integer read getOrientation write setOrientation;
    property Copyright: string read getCopyright write setCopyright;
  end;

  TKJpegInfo = class
  private
    FHasSOI: Boolean;
    FHasAPP1: Boolean;
    FHasSOS: Boolean;
    FHasSOF0: Boolean;
    FHasEOI: Boolean;
    FHasAPP0: Boolean;
    FBrokenJPEG: Boolean;
    FHasAPP2: Boolean;
    function GetImageWidth: DWORD;
    procedure SetImageWidth(const Value: DWORD);
    function GetImageHeight: DWORD;
    procedure SetImageHeight(const Value: DWORD);
    function GetImageOrientation: WORD;
    procedure SetImageOrientation(const Value: WORD);
    function GetDateTime:TDateTime;
    function GetMake: string;
    function GetModel: string;
    function GetExposureTimeStr: string;
    function GetFNumber: TKExifRationValue;
    function GetOrientation: Integer;
    function GetFNumberStr: string;
    function GetISOSpeedRatings: Integer;
    procedure SetOrientation(const Value: Integer);
    procedure CheckMaker;
  protected
    FByteOrder: TKExifByteOrder;
    function FindMarker(Marker: string): Boolean;
    function ReadWordFromStream: Word;
    function ReadDWordFromStream: DWord;
    function CheckWord(b: Word): Word;
    function CheckDWord(b: DWord): DWord;
  public
    stream: TMemoryStream;
    TiffIFD: TKTiffIFD;
    debugOut: TKJepgDebugOutProc;
    constructor Create;
    destructor Destroy; override;
    function LoadFromFile(fname: string; TryCheckExif:Boolean = True): Boolean;
    procedure SaveToFile(fname: string);
    function ExtractExifSegment:TMemoryStream;
    function ExtractExifSegmentAsRawExifObj: TKRawExif;
    function ExtractExifSegmentStr:string;
    procedure SwapExifSegment(exifs: TStream);
    procedure SwapExifSegmentStr(exifstr: string);
    function RemoveExif:Boolean;
    procedure RewriteValues;
    function GetExifValueAsString(TagNo: Integer; Block: Integer): string;
    function GetExifValueAsUShort(TagNo: Integer; Block: Integer): Integer;
    function GetExifValueAsRation(TagNo: Integer; Block: Integer): TKExifRationValue;
  public
    function CheckSOI: Boolean;
    function HasExif: Boolean;
    function ReadExif: Boolean;
  public
    property ImageWidth: DWORD read GetImageWidth write SetImageWidth;
    property ImageHeight: DWORD read GetImageHeight write SetImageHeight;
    property ImageOrientation: WORD read GetImageOrientation write SetImageOrientation;
    property ByteOrder: TKExifByteOrder read FByteOrder;
    property DateTime: TDateTime read GetDateTime;
    property Make: string read GetMake;
    property Model: string read GetModel;
    property ExposureTimeStr: string read GetExposureTimeStr;
    property FNumber: TKExifRationValue read GetFNumber;
    property FNumberStr: string read GetFNumberStr;
    property Orientation: Integer read GetOrientation write SetOrientation;
    property ISOSpeedRatings: Integer read GetISOSpeedRatings;
    // hasXXX
    property hasSOI: Boolean read FHasSOI;
    property hasAPP0: Boolean read FHasAPP0;
    property hasAPP1: Boolean read FHasAPP1;
    property hasAPP2: Boolean read FHasAPP2;
    property hasSOF0: Boolean read FHasSOF0;
    property hasSOS: Boolean read FHasSOS;
    property hasEOI: Boolean read FHasEOI;
    property brokenJPEG: Boolean read FBrokenJPEG;
  end;

function SwapWord(d: WORD): WORD;
function SwapDWord(d: DWORD): DWORD;

function MakeRationType(ko, oya:DWORD): string;
procedure GetRationType(const s:string; var ko:DWORD; var oya:DWORD);

function RewriteOrientation(
  fname:String; orientation:DWORD; w:DWORD; h:DWORD):DWORD;

function JpegGetDateTime(fname: string): string;

procedure str2file(str, fname: string);

procedure JPEG_RemoveAppArea(fname: string; onlyApp0: Boolean = False);
procedure JPEG_Elmonize(fname: string);


implementation

uses DateUtils, unit_exif_taglist, unit_string2;

procedure JPEG_RemoveAppArea(fname: string; onlyApp0: Boolean = False);
var
  m: TMemoryStream;
  o: TMemoryStream;
  buf: string;
  mark: string;
  sz, szi: WORD;
begin
  m := TMemoryStream.Create;
  o := TMemoryStream.Create;
  try
    m.LoadFromFile(fname);
    m.Position := 0;
    // SOI
    buf := 'xx';
    m.Read(buf[1], 2);
    if buf <> SOI then raise Exception.Create('JPEG形式ではありません。');
    o.Write(buf[1], 2);
    // Read FF
    while True do
    begin
      // Marker
      mark := 'xx';
      if m.Read(mark[1], 2) < 2 then Break;
      if mark = EOI then
      begin
        o.Write(mark[1], 2);
        Break;
      end;
      if mark[1] <> #$ff then
      begin
        raise Exception.Create('JPEGが壊れています。マーカーのヘッダが見つかりません。');
      end;
      if mark = SOS then
      begin
        o.Write(mark[1],2);
        // EOI までコピー
        buf := 'x';
        while True do
        begin
          m.Read(buf[1], 1);
          o.Write(buf[1], 1);
          if buf[1] = #$FF then
          begin
            m.Read(buf[1], 1);
            o.Write(buf[1],1);
            if buf[1] = #$D9 then
            begin
              Break;
            end;
          end;
        end;
        Break;
      end;
      // Size
      if m.Read(sz, 2) < 2 then Break;
      szi := SwapWord(sz) - 2;
      // Contents
      SetLength(buf, szi);
      if m.Read(buf[1], szi) < Int64(szi) then Break;
      // Copy ?
      if onlyApp0 then
      begin
        if (mark = APP0) then Continue;
      end else begin
        if (mark = APP0)or(mark = APP1)or(mark = APP2) then Continue;
      end;
      o.Write(mark[1], 2);
      o.Write(sz, 2);
      o.Write(buf[1], szi);
    end;
    o.SaveToFile(fname);
  finally
    FreeAndNil(m);
    FreeANdNil(o);
  end;
end;

procedure JPEG_Elmonize(fname: string);
var
  m: TMemoryStream;
  o: TMemoryStream;
  buf: string;
  mark: string;
  sz, szi: WORD;
  app1s, sof0s, images: string;
  dqts, dhts: Array [0..64] of string;
  dqti, dhti, i: Integer;

  procedure _write(mark, dat: string);
  var
    szi, sz:WORD;
  begin
    szi := Length(dat) + 2;
    sz  := SwapWord(szi);
    o.Write(mark[1], 2);
    o.Write(sz, 2);
    o.Write(dat[1], szi - 2);
  end;

begin
{
memo: Elmo JPEG Format
SOI
APP1
DQT(FF DB)
DHT(FF C4
SOF0(FF C0)
SOS(FF DA)
Image
EOI
}
  images := '';
  dqti := 0; dhti := 0;
  m := TMemoryStream.Create;
  o := TMemoryStream.Create;
  try
    m.LoadFromFile(fname);
    m.Position := 0;
    // SOI
    buf := 'xx';
    m.Read(buf[1], 2);
    if buf <> SOI then raise Exception.Create('JPEG形式ではありません。');
    o.Write(buf[1], 2);
    // Read FF
    while True do
    begin
      // Marker
      mark := 'xx';
      if m.Read(mark[1], 2) < 2 then Break;
      if mark = EOI then
      begin
        o.Write(mark[1], 2);
        Break;
      end;
      if mark[1] <> #$ff then
      begin
        raise Exception.Create('JPEGが壊れています。マーカーのヘッダが見つかりません。');
      end;
      if mark = SOS then
      begin
        SetLength(images, m.Size - m.Position);
        m.Read(images[1], Length(images));
        Break;
      end;
      // Size
      if m.Read(sz, 2) < 2 then Break;
      szi := SwapWord(sz) - 2;
      // Contents
      SetLength(buf, szi);
      if m.Read(buf[1], szi) < Int64(szi) then Break;
      //
      if mark = APP1  then app1s  := buf
      else if mark = DQT   then
      begin
        dqts[dqti] := buf; Inc(dqti);
      end else
      if mark = DHT   then
      begin
        dhts[dhti] := buf; Inc(dhti);
      end else
      if mark = SOF0  then sof0s  := buf;
    end;
    // elmo jpeg format order
    _write(APP1, app1s);
    for i := 0 to dqti - 1 do
    begin
      _write(DQT, DQTs[i]);
    end;
    for i := 0 to dhti - 1 do
    begin
      _write(DHT, DHTs[i]);
    end;
    _write(SOF0, SOF0s);
    // sos
    o.Write(SOS[1],2);
    o.Write(images[1], Length(images));
    //o.Write(EOI[1],2); // include images
    o.SaveToFile(fname);
  finally
    FreeAndNil(m);
    FreeANdNil(o);
  end;
end;


procedure str2file(str, fname: string);
var
  m:TMemoryStream;
begin
  m := TMemoryStream.Create;
  try
    m.Write(str[1], Length(str));
    m.SaveToFile(fname);
  finally
    m.Free;
  end;
end;

function MakeRationType(ko, oya:DWORD): string;
begin
  SetLength(Result, 8);
  Move(ko,  Result[1], 4);
  Move(oya, Result[5], 4);
end;

procedure GetRationType(const s:string; var ko:DWORD; var oya:DWORD);
begin
  Move(s[1], ko,  4);
  Move(s[5], oya, 4);
end;

function JpegGetDateTime(fname: string): string;
var
  jpg: TKJpegInfo;
  d: TDateTime;
begin
  Result := '';
  jpg := TKJpegInfo.Create;
  try
    jpg.LoadFromFile(fname);
    d := jpg.GetDateTime;
    if d = 0 then
    begin
      Result := '';
    end else
    begin
      Result := FormatDateTime('yyyy-mm-dd hh-nn-ss', d);
    end;
  finally
    jpg.Free;
  end;
end;

function RewriteOrientation(
  fname:String; orientation:DWORD; w:DWORD; h:DWORD):DWORD;
var
  jpg: TKJpegInfo;
  exif: TKRawExif;
  ent: TKIFDEntry;
begin
  jpg := TKJpegInfo.Create;
  try
    try
      jpg.LoadFromFile(fname, false);
      //
      exif := jpg.ExtractExifSegmentAsRawExifObj;
      try
        ent := exif.getEntry(EXIF_TAG_ORIENTATION);
        if ent <> nil then
        begin
          ent.DValue := orientation;
          jpg.SwapExifSegment(exif.genExifData);
        end;
      finally
        FreeAndNil(exif);
      end;
      Result := 0;
    except
      Result := 1;
    end;
  finally
    jpg.Free;
  end;
end;

function SwapWord(d: WORD): WORD;
begin
  Result := ((d shr 8)and $FF) or ((d shl 8) and $FF00);
end;

function SwapDWord(d: DWORD): DWORD;
var
  b: array [0..3] of Byte;
begin
  Move(d, b[0], 4);
  // 0 1 2 3
  // 3 2 1 0
  Result := b[3] or (b[2] shl 8) or (b[1] shl 16) or (b[0] shl 24);
end;


{ TKJpegInfo }

function TKJpegInfo.CheckDWord(b: DWord): DWord;
begin
  Result := b;
  if FByteOrder = MM then Result := SwapDWord(Result);
end;

procedure TKJpegInfo.CheckMaker;
var
  b: string;
  sz: WORD;
begin
  FBrokenJPEG := False;
  FHasAPP0 := False;
  FHasAPP1 := False;
  FHasAPP2 := False;
  FHasSOS  := False;
  FHasSOF0 := False;
  // Check SOI
  if not CheckSOI then Exit;
  SetLength(b, 2);
  while True do
  begin
    // Check Marker
    if stream.Read(b[1], 2) <> 2  then begin Break; end;
    if b[1] <> JPEG_MARKER        then begin FBrokenJPEG := True; Break; end;

    if b = SOS then // Start Of Stream
    begin
      if Assigned(debugOut) then debugOut('SOS');
      FHasSOS := True; Break;
    end;

    // Move Next Segment
    if stream.Read(sz, 2) <> 2    then begin FBrokenJPEG := True; Break; end;
    sz := SwapWord(sz);
    stream.Seek(sz - 2, soFromCurrent);

    // Check Marker TAG
    if b = APP0 then FHasAPP0 := True;
    if b = APP1 then FHasAPP1 := True;
    if b = APP2 then FHasAPP2 := True;

    if Assigned(debugOut) then
    begin
      debugOut('JPEG MARKER:' + IntToHex(Ord(b[2]), 2));
      if b = APP1 then debugOut('Exif');
      debugOut(IntToHex(stream.Position,8) + ':');
    end;
  end;
end;

function TKJpegInfo.CheckSOI: Boolean;
var
  b: string;
begin
  FHasSOI := False;
  try
    stream.Position := 0;
    SetLength(b, 2);
    stream.Read(b[1], 2);
    Result := (b = SOI);
    FHasSOI := Result;
  except
    Result := False;
  end;
end;

function TKJpegInfo.CheckWord(b: Word): Word;
begin
  Result := b;
  if FByteOrder = MM then Result := SwapWord(Result);
end;

constructor TKJpegInfo.Create;
begin
  stream  := TMemoryStream.Create;
  TiffIFD := nil;
end;

destructor TKJpegInfo.Destroy;
begin
  if TiffIFD <> nil then FreeAndNil(TiffIFD);
  stream.Free;
  inherited;
end;

function TKJpegInfo.ExtractExifSegment: TMemoryStream;
var
  sz: WORD;
begin
  Result := nil;
  // Find Marker
  if not FindMarker(APP1) then Exit;
  // Read Size
  if stream.Read(sz, 2) <> 2 then Exit;
  sz := SwapWord(sz);
  if sz = 0 then Exit;
  Result := TMemoryStream.Create;
  stream.Seek(-4, soFromCurrent);
  Result.CopyFrom(stream, sz + 2); // Marker(2byte) + Data(include size)
end;

function TKJpegInfo.ExtractExifSegmentAsRawExifObj: TKRawExif;
var
  mem: TMemoryStream;
begin
  mem := ExtractExifSegment;
  if mem <> nil then
  begin
    Result := TKRawExif.Create(mem, debugOut);
    mem.Free;
  end else
  begin
    Result := nil;
  end;
end;

function TKJpegInfo.ExtractExifSegmentStr: string;
var
  sz: WORD;
begin
  Result := '';
  // Find Marker
  if not FindMarker(APP1) then Exit;
  // Read Size
  if stream.Read(sz, 2) <> 2 then Exit;
  sz := SwapWord(sz);
  if sz = 0 then Exit;
  stream.Seek(-4, soFromCurrent);
  SetLength(Result, sz + 2);
  stream.Read(Result[1], sz + 2); // Marker(2byte) + Data(include size)
end;

function TKJpegInfo.FindMarker(Marker: string): Boolean;
var
  b: string;
  sz: WORD;
begin
  Result := False;

  if not CheckSOI then Exit;

  while True do
  begin
    // Check Marker
    SetLength(b, 2);
    if stream.Read(b[1], 2) <> 2 then Break;
    if b[1] <> JPEG_MARKER then Break;
    if b = Marker then
    begin
      Result := True;
      Break;
    end;
    if b = SOS then Break;
    // Check Size
    if stream.Read(sz, 2) <> 2 then Break;
    sz := SwapWord(sz);
    // next Chunk
    stream.Seek(sz - 2, soFromCurrent);
  end;
end;

function getIntAndOne(var s: string): Integer;
begin
  Result := 0;
  while s <> '' do
  begin
    if s[1] in ['0'..'9'] then
    begin
      Result := Result * 10;
      Result := Result + ( Ord(s[1]) - Ord('0') );
      System.Delete(s, 1, 1);
    end else
    begin
      System.Delete(s, 1, 1); // 区切り記号を消す
      Break;
    end;
  end;
end;

function getExifDateToDateTime(s: string): TDateTime;
var
  yy,mm,dd,hh,nn,ss: Integer;
begin
  s := Trim(s);
  yy := getIntAndOne(s);
  mm := getIntAndOne(s);
  dd := getIntAndOne(s);
  hh := getIntAndOne(s);
  nn := getIntAndOne(s);
  ss := getIntAndOne(s);

  try
    if dd = 0 then Result := 0 else
    Result := EncodeDateTime(yy, mm, dd, hh, nn, ss, 0);
  except
    Result := 0;
  end;
end;

function TKJpegInfo.GetDateTime: TDateTime;
var
  f: TKTiffIFDValueIO;
  s: string;
begin
  // 日付情報の取得
  if not Self.HasExif then begin
    Result := 0;
    Exit;
  end;
  f := TiffIFD.getValue(EXIF_TAG_DATETIMEORIGINAL,BLOCK_IFD_SUB);
  if f = nil  then f := TiffIFD.getValue(EXIF_TAG_DATETIME,BLOCK_IFD_BASE);
  if f <> nil then
  begin
    if f.DataFormat = TV_TYPE_ASCII then
    begin
      s := f.GetValueAscii;
      Result := getExifDateToDateTime(s);
    end else
    begin
      Result := 0;
    end;
    f.Free;
  end else
  begin
    Result := 0;
  end;
end;


function TKJpegInfo.GetExifValueAsRation(
  TagNo, Block: Integer): TKExifRationValue;
var
  f: TKTiffIFDValueIO;
begin
  f := TiffIFD.getValue(TagNo, Block);
  if f <> nil then
  begin
    if f.DataFormat = TV_TYPE_URATION then
    begin
      Result := f.GetValueRational;
    end else
    if f.DataFormat = TV_TYPE_SRATION then
    begin
      Result := f.GetValueRational;
    end;
    f.Free;
  end else
  begin
    Result.numerator   := 0;
    Result.denominator := 0;
  end;
end;

function TKJpegInfo.GetExifValueAsString(TagNo, Block: Integer): string;
var
  f: TKTiffIFDValueIO;
begin
  f := TiffIFD.getValue(TagNo,Block);
  if f <> nil then
  begin
    if f.DataFormat = TV_TYPE_ASCII then
    begin
      Result := f.GetValueAscii;
    end;
    f.Free;
  end else
  begin
    Result := '';
  end;
end;

function TKJpegInfo.GetExifValueAsUShort(TagNo, Block: Integer): Integer;
var
  f: TKTiffIFDValueIO;
begin
  f := TiffIFD.getValue(TagNo, Block);
  if f <> nil then
  begin
    if f.DataFormat = TV_TYPE_USHORT then
    begin
      Result := f.GetValueUShort;
    end else
    begin
      Result := 0;
    end;
    f.Free;
  end else
  begin
    Result := 0;
  end;
end;

function TKJpegInfo.GetExposureTimeStr: string;
var
  r: TKExifRationValue;
  d: Extended;
  s: string;
begin
  r := GetExifValueAsRation(EXIF_TAG_EXPOSURETIME,BLOCK_IFD_SUB);
  if r.numerator = 0 then
  begin
    Result := '';
  end else
  begin
    d := (r.numerator / r.denominator);
    if d > 1 then
      s := Format('%0.2f',[ (r.numerator / r.denominator) ])
    else
      s := Format('1/%0.0f',[ (r.denominator/r.numerator) ]);
    Result := s;
  end;
end;

function TKJpegInfo.GetFNumber: TKExifRationValue;
begin
  Result := GetExifValueAsRation(EXIF_TAG_FNUMBER,BLOCK_IFD_SUB);
end;

function TKJpegInfo.GetFNumberStr: string;
var
  r: TKExifRationValue;
begin
  r := GetFNumber;
  if r.numerator = 0 then
  begin
    Result := '';
  end else
  begin
    Result := Format('%0.1f',[(r.numerator / r.denominator)]);
  end;
end;

function TKJpegInfo.GetImageHeight: DWORD;
var
  f: TKTiffIFDValueIO;
begin
  f := TiffIFD.getValue(EXIF_TAG_EXIF_IMAGE_HTIGHT,BLOCK_IFD_SUB);
  if f <> nil then
  begin
    if f.DataFormat = TV_TYPE_USHORT then
    begin
      Result := f.ValueUShort;
    end else
    begin
      Result := f.ValueULong;
    end;
    f.Free;
  end else
  begin
    Result := 0;
  end;
end;

function TKJpegInfo.GetImageOrientation: WORD;
var
  f: TKTiffIFDValueIO;
begin
  f := TiffIFD.getValue(EXIF_TAG_ORIENTATION,BLOCK_IFD_BASE);
  if f <> nil then
  begin
    Result := f.ValueUShort;
    f.Free;
  end else
  begin
    Result := 0;
  end;
end;

function TKJpegInfo.GetImageWidth: DWORD;
var
  f: TKTiffIFDValueIO;
begin
  f := TiffIFD.getValue(EXIF_TAG_EXIF_IMAGE_WIDTH,BLOCK_IFD_SUB);
  if f <> nil then
  begin
    if f.DataFormat = TV_TYPE_USHORT then
    begin
      Result := f.ValueUShort;
    end else
    begin
      Result := f.ValueULong;
    end;
    f.Free;
  end else
  begin
    Result := 0;
  end;
end;

function TKJpegInfo.GetISOSpeedRatings: Integer;
begin
  Result := GetExifValueAsUShort(EXIF_TAG_ISOSPEEDRATINGS,BLOCK_IFD_SUB);
end;

function TKJpegInfo.GetMake: string;
begin
  Result := GetExifValueAsString(EXIF_TAG_Make,BLOCK_IFD_BASE);
end;

function TKJpegInfo.GetModel: string;
begin
  Result := GetExifValueAsString(EXIF_TAG_Model,BLOCK_IFD_BASE);
end;

function TKJpegInfo.GetOrientation: Integer;
begin
  Result := GetExifValueAsUShort(EXIF_TAG_ORIENTATION,BLOCK_IFD_BASE);
end;

function TKJpegInfo.HasExif: Boolean;
var
  tiff_size: WORD;
  tmp: string;
begin
  // Reset
  stream.Position := 0;
  
  // Move APP1 Maker (Exif Chunk)
  Result := FindMarker(APP1);

  // Check Exif Header
  if Result then
  begin
    // Read Size
    stream.Read(tiff_size, 2); tiff_size := SwapWord(tiff_size);

    // Read Exif Header
    SetLength(tmp, 6);
    stream.Read(tmp[1], 6);
    if tmp <> EXIF_HEADER_ID then Result := False;
  end;
end;

function TKJpegInfo.LoadFromFile(fname: string; TryCheckExif:Boolean = True): Boolean;
begin
  stream.LoadFromFile(fname);
  CheckMaker;
  if TryCheckExif then
  begin
    Result := ReadExif;
    Exit;
  end;
  Result := not brokenJPEG;
end;

function TKJpegInfo.ReadDWordFromStream: DWord;
begin
  if SizeOf(Result) <> stream.Read(Result, SizeOf(Result)) then
  begin
    raise Exception.Create('Broken Stream : Can not read DWord');
  end;
  if FByteOrder = MM then Result := SwapDWord(Result);
end;

function TKJpegInfo.ReadExif: Boolean;
var
  tiff: TKTiffHead;
  TiffOffset: DWord;
begin
  // Move Exif Header id
  Result := HasExif;
  if Result = False then Exit;
  TiffOffset := stream.Position;

  // Read Tiff Header
  if SizeOf(TKTiffHead) <> stream.Read(tiff, SizeOf(TKTiffHead)) then
  begin
    Result := False; Exit;
  end;
  if tiff.ByteOrder = 'II' then FByteOrder := II else FByteOrder := MM;

  // IFD(Image File Directory)
  try
    // Set First FID
    stream.Position := TiffOffset + CheckDWord(tiff.Offset);
    TiffIFD := TKTiffIFD.Create(Self, TiffOffset,BLOCK_IFD_BASE);
  except
    Result := False;
    Exit;
  end;
end;

function TKJpegInfo.ReadWordFromStream: Word;
begin
  if SizeOf(Result) <> stream.Read(Result, SizeOf(Result)) then
  begin
    raise Exception.Create('Broken Stream : Can not read Word');
  end;
  if FByteOrder = MM then Result := SwapWord(Result);
end;

function TKJpegInfo.RemoveExif:Boolean;
var
  st: TMemoryStream;
  b, data: string;
  bin_sz, sz: Word;
  offset: LongWord;
begin
  Result := False;
  if not FHasAPP1 then Exit;
  st := TMemoryStream.Create;
  try
    // copy SOI
    SetLength(b, 2);
    stream.Position := 0;
    stream.Read(b[1], 2); // read  SOI
    st.Write(b[1], 2);    // write SOI
    while True do
    begin
      // Read Marker
      offset := stream.Position;
      if stream.Read(b[1],  2) <> 2 then Exit;
      if b[1] <> JPEG_MARKER then Exit;
      if b = SOS then // 正しくメタタグの終端を発見
      begin
        st.Write(b[1], 2); // Write SOS
        // 残りの Stream をコピー
        SetLength(data, (stream.Size - stream.Position));
        stream.Read(data[1], Length(data));
        st.Write(data[1], Length(data));
        Break;
      end;
      // Read Size
      if stream.Read(bin_sz,2) <> 2 then Exit;
      sz := SwapWord(bin_sz);
      // Read Data Body
      SetLength(data, sz - 2);
      if stream.Read(data[1], sz - 2) <> (sz - 2) then Exit;
      // APP1 ?
      if b = APP1 then Continue; // Exif なら追加しない
      // Write Maker
      st.Write(b[1],    2);
      st.Write(bin_sz,  2);
      st.Write(data[1], sz-2);
      if Assigned(debugOut) then
      begin
        debugOut(IntToHex(offset, 8) + ': Marker.' + IntToHex(Ord(b[2]), 2));
      end;
    end;
    // st -> stream
    st.Position := 0;
    stream.Clear;
    stream.CopyFrom(st, st.Size);
    Result := True;
  finally
    FreeAndNil(st);
  end;
end;

procedure TKJpegInfo.RewriteValues;
begin
  //
  if TiffIFD <> nil then
  begin
    TiffIFD.WriteValues;
  end;
end;

procedure TKJpegInfo.SaveToFile(fname: string);
begin
  stream.SaveToFile(fname);
end;

procedure TKJpegInfo.SetImageHeight(const Value: DWORD);
var
  f: TKTiffIFDValueIO;
begin
  f := TiffIFD.getValue(EXIF_TAG_EXIF_IMAGE_HTIGHT,BLOCK_IFD_SUB);
  if f <> nil then
  begin
    if f.DataFormat = TV_TYPE_USHORT then
    begin
      f.ValueUShort := Value;
    end else
    begin
      f.ValueULong := Value;
    end;
    f.Free;
  end;
end;

procedure TKJpegInfo.SetImageOrientation(const Value: WORD);
var
  f: TKTiffIFDValueIO;
begin
  f := TiffIFD.getValue(EXIF_TAG_ORIENTATION,BLOCK_IFD_BASE);
  if f <> nil then
  begin
    f.ValueUShort := Value;
    f.Free;
  end;
end;

procedure TKJpegInfo.SetImageWidth(const Value: DWORD);
var
  f: TKTiffIFDValueIO;
begin
  f := TiffIFD.getValue(EXIF_TAG_EXIF_IMAGE_WIDTH,BLOCK_IFD_SUB);
  if f <> nil then
  begin
    if f.DataFormat = TV_TYPE_USHORT then
    begin
      f.ValueUShort := Value;
    end else
    begin
      f.ValueULong := Value;
    end;
    f.Free;
  end;
end;

procedure TKJpegInfo.SetOrientation(const Value: Integer);
begin
  SetImageOrientation(Value);
end;

procedure TKJpegInfo.SwapExifSegment(exifs: TStream);
var
  b: string;
  result: TMemoryStream;
  buf: string;
  mark: string;
  sz: WORD;
const
  JPEG_ERROR = 'JPEGファイルが壊れています';
begin
  if FHasAPP1 then
  begin
    RemoveExif;
  end;
  if exifs = nil then Exit;
  result := TMemoryStream.Create;
  try
    SetLength(b, 2);
    stream.Position := 0;
    stream.Read (b[1], 2); // read  SOI
    result.Write(b[1], 2); // write SOI

    // copy app0
    mark := 'xx';
    if stream.Read(mark[1], 2) < 2 then raise Exception.Create(JPEG_ERROR);

    if mark = APP0 then
    begin
      if stream.Read(sz, 2) < 2 then raise Exception.Create(JPEG_ERROR);
      SetLength(buf, SwapWord(sz));
      stream.Read(buf[1], SwapWord(sz) - 2);
      result.Write(mark[1], 2);
      result.Write(sz, 2);
      result.Write(buf[1], SwapWord(sz) - 2);
    end else
    begin
      stream.Position := stream.Position - 2;
    end;
    
    // write exif to result
    SetLength(buf, exifs.Size);
    exifs.Position := 0;
    exifs.Read(buf[1], exifs.Size);
    result.Write(buf[1], exifs.Size);
    // copy JPEG Stream
    SetLength(buf, (stream.Size - stream.Position));
    stream.Read(buf[1], Length(buf));
    result.Write(buf[1], Length(buf));
    // result -> stream (swap result, stream)
    result.Position := 0;
    stream.Clear;
    stream.CopyFrom(result, result.Size);
  finally
    FreeAndNil(result);
  end;
end;

procedure TKJpegInfo.SwapExifSegmentStr(exifstr: string);
var
  mem: TMemoryStream;
begin
  mem := TMemoryStream.Create;
  try
    if exifstr = '' then
    begin
      Self.RemoveExif;
      Exit;
    end;
    mem.Write(exifstr[1], Length(exifstr));
    SwapExifSegment(mem);
  finally
    FreeAndNil(mem);
  end;
end;

{ TKTiffIFD }

constructor TKTiffIFD.Create(info: TKJpegInfo; Offset: DWORD; Block: Integer);
var
  i: Integer;
  NextLink: DWORD;
  tmpPos: DWORD;
  tagNo: WORD;
begin
  // Set Stream
  Self.info   := info;
  Self.stream := info.stream;
  Self.offset := Offset;
  FNextIFD    := nil;
  FSubIFD     := nil;
  FGpsIFD     := nil;
  FBlock      := BLOCK_IFD_BASE;
  FIFD_StartPos  := info.stream.Position;
  FIFDCount := 0;

  // set block type
  FBlock := Block;
  // Read Number of directory entory
  FIFDCount := info.ReadWordFromStream;
  if FIFDCount > 0 then
  begin
    SetLength(FValues, FIFDCount);
  end;

  // Read Value
  for i := 0 to FIFDCount - 1 do
  begin
    if SizeOf(TKTiffIFDValue) <> stream.Read(FValues[i], SizeOf(TKTiffIFDValue)) then
    begin
      raise Exception.Create('Broken stream : IFD Value');
    end;
    tagNo := info.CheckWord(FValues[i].TagNo);
    if (FSubIFD = nil) and (tagNo = EXIF_TAG_SUBIFD) then
    begin
      tmpPos := stream.Position;
      stream.Position := info.CheckDWord(FValues[i].Value) + Offset;
      try
        FSubIFD := TKTiffIFD.Create(info, Offset, BLOCK_IFD_SUB);
      except
        raise Exception.Create('Broken stream : Sub IFD(exif) Value');
      end;
      stream.Position := tmpPos;
    end;
    if (FGpsIFD = nil) and (tagNo = EXIF_TAG_GPSINFO) then
    begin
      tmpPos := stream.Position;
      stream.Position := info.CheckDWord(FValues[i].Value) + Offset;
      try
        FGpsIFD := TKTiffIFD.Create(info, Offset, BLOCK_IFD_GPS);
      except
        raise Exception.Create('Broken stream : Sub IFD(gps) Value');
      end;
      stream.Position := tmpPos;
    end;
    //WriteLn('TagNo=',IntToHex(tagNo, 4));
  end;

  // Next Image File Directory
  //ShowMessage(IntToStr(info.stream.Position));
  NextLink := info.ReadDWordFromStream;
  if NextLink <> 0 then
  begin
    stream.Position := NextLink + Offset;
    FNextIFD := TKTiffIFD.Create(info, Offset, BLOCK_IFD_BASE);
  end;

end;

destructor TKTiffIFD.Destroy;
begin
  if FNextIFD <> nil then FreeAndNil(FNextIFD);
  if FGpsIFD  <> nil then FreeAndNil(FGpsIFD);
  if FSubIFD  <> nil then FreeAndNil(FSubIFD);
  inherited;
end;

function TKTiffIFD.FindValue(TagNo: WORD; Block: Integer): PKTiffIFDValue;
var
  i: Integer;
  v: PKTiffIFDValue;
  tag: WORD;
begin
  Result := nil;

  if ((Block =  BLOCK_IFD_GPS) and (FBlock =  BLOCK_IFD_GPS)) or
     ((Block <> BLOCK_IFD_GPS) and (FBlock <> BLOCK_IFD_GPS)) then
  begin
    for i := 0 to Count - 1 do
    begin
      v := @FValues[i];
      tag := info.CheckWord(v^.TagNo);
      if tag = TagNo then
      begin
        Result := v;
        Break;
      end;
    end;
  end;

  // Find SUB
  if (Result = nil) and (FSubIFD <> nil) then
  begin
    Result := FSubIFD.FindValue(TagNo, Block);
  end;
  if (Result = nil) and (FGpsIFD <> nil) then
  begin
    Result := FGpsIFD.FindValue(TagNo, Block);
  end;

  if Result = nil then
  begin
    if FNextIFD <> nil then
    begin
      Result := FNextIFD.FindValue(TagNo, Block);
    end;
  end;

end;

function TKTiffIFD.getValue(TagNo: WORD; Block: Integer): TKTiffIFDValueIO;
var
  v: PKTiffIFDValue;
begin
  // find
  v := FindValue(TagNo, Block);
  if v = nil then
  begin
    Result := nil;
    Exit;
  end;
  // new Adapter
  Result := TKTiffIFDValueIO.Create(v, Self.info);
end;

procedure TKTiffIFD.WriteValues;
var
  i: Integer;
begin
  // Set Position
  stream.Position := FIFD_StartPos;

  // Skip Size
  info.ReadWordFromStream;

  // Rewrite Values
  for i := 0 to Self.FIFDCount - 1 do
  begin
    stream.Write(Self.FValues[i], SizeOf(TKTiffIFDValue));
  end;

  // Skip Next Link
  info.ReadDWordFromStream;

  // Write SubIFD
  if FSubIFD <> nil then FSubIFD.WriteValues;

  // Write GpsIFD
  if FGpsIFD <> nil then FGpsIFD.WriteValues;

  // Write Next Exif
  if FNextIFD <> nil then FNextIFD.WriteValues;
end;

{ TKTiffIFDValueIO }

constructor TKTiffIFDValueIO.Create(v: PKTiffIFDValue; info: TKJpegInfo);
begin
  FValue := v;
  Self.info := info;
end;

function TKTiffIFDValueIO.GetDataCount: DWORD;
begin
  Result := info.CheckDWord(FValue^.DataCount);
end;

function TKTiffIFDValueIO.GetDataFormat: Word;
begin
  Result := info.CheckWord(FValue^.DataType);
end;


function TKTiffIFDValueIO.GetNativeData: DWORD;
begin
  Result := info.CheckDWord(FValue^.Value);
end;

function TKTiffIFDValueIO.GetTagNo: Word;
begin
  Result := info.CheckWord(FValue^.TagNo);
end;

function TKTiffIFDValueIO.GetValueAscii: string;
var
  len: WORD;
begin
  len := GetDataCount;
  try
    info.stream.Position := info.TiffIFD.offset + NativeData;
    SetLength(Result, len);
    info.stream.Read(Result[1], len);
    Result := Trim(Result);
  except
    Result := '';
  end;
end;

function TKTiffIFDValueIO.GetValueRational: TKExifRationValue;
begin
  try
    info.stream.Position := info.TiffIFD.offset + NativeData;
    info.stream.Read(Result, 8);
    info.CheckDWord(Result.numerator);
    info.CheckDWord(Result.denominator);
  except
    Result.numerator  := 0;
    Result.denominator := 0;
  end;
end;

function TKTiffIFDValueIO.GetValueUByte: Byte;
begin
  Result := Byte(NativeData);
end;

function TKTiffIFDValueIO.GetValueULong: DWORD;
begin
  Result := info.CheckDWord(FValue^.Value);
end;

function TKTiffIFDValueIO.GetValueUShort: WORD;
begin
  Result := info.CheckWord(FValue^.Value);
end;

procedure TKTiffIFDValueIO.SetDataCount(const Value: DWORD);
var
  v: DWORD;
begin
  v := info.CheckDWord(Value);
  FValue^.DataCount := v;
end;

procedure TKTiffIFDValueIO.SetNativeData(const Value: DWORD);
begin
  FValue^.Value := info.CheckDWord(Value);
end;

procedure TKTiffIFDValueIO.SetValueUByte(const Value: Byte);
begin
  NativeData := Value;
end;

procedure TKTiffIFDValueIO.SetValueULong(const Value: DWORD);
begin
  FValue^.Value := info.CheckDWord(Value);
end;

procedure TKTiffIFDValueIO.SetValueUShort(const Value: WORD);
begin
  FValue^.Value := info.CheckWord(Value);
end;

{ TKIFDIO }

function TKIFDIO.checkDWord(v: DWORD): DWORD;
begin
  Result := v;
  if order = MM then Result := SwapDWord(v);
end;

function TKIFDIO.checkWord(v: WORD): WORD;
begin
  Result := v;
  if order = MM then Result := SwapWord(v);
end;

procedure TKIFDIO.clear;
var
  i: Integer;
  p: TKIFDEntry;
begin
  for i := 0 to list.Count - 1 do
  begin
    p := TKIFDEntry(list.Items[i]);
    FreeAndNil(p);
  end;
  list.Clear;
end;

constructor TKIFDIO.Create(stream:TMemoryStream; Block: Integer; Offset:Int64; ByteOrder: TKExifByteOrder; debugOut: TKJepgDebugOutProc);
begin
  list := TList.Create;
  Self.stream := stream;
  Self.offset := Offset;
  Self.order  := ByteOrder;
  Self.debugOut := debugOut;
  Self.FBlock := Block;
  // --- read
  ReadEntry;
end;

destructor TKIFDIO.Destroy;
begin
  clear;
  FreeAndNil(list);
end;

function TKIFDIO.findTag(tagNo: Integer): TKIFDEntry;
var
  i: Integer;
  p: TKIFDEntry;
begin
  tagNo := checkWord(tagNo);
  Result := nil;
  for i := 0 to list.Count - 1 do
  begin
    p := TKIFDEntry(list.Items[i]);
    if p = nil then Continue;
    if p.value.TagNo = tagNo then
    begin
      Result := p; Exit;
    end;
  end;
end;

function TKIFDIO.findTag(tagNo: Integer; Block: Integer): TKIFDEntry;
var
  i: Integer;
  p: TKIFDEntry;
begin
  tagNo := checkWord(tagNo);
  Result := nil;
  if ((Block =  BLOCK_IFD_GPS) and (FBlock =  BLOCK_IFD_GPS)) or
     ((Block <> BLOCK_IFD_GPS) and (FBlock <> BLOCK_IFD_GPS)) then
  begin
    for i := 0 to list.Count - 1 do
    begin
      p := TKIFDEntry(list.Items[i]);
      if p = nil then Continue;
      if p.value.TagNo = tagNo then
      begin
         Result := p; Exit;
      end;
    end;
  end;
end;

function TKIFDIO.getTagValue(tagNo: Integer): DWORD;
var
  entry: TKIFDEntry;
  v:DWORD;
begin
  Result := 0;
  entry := findTag(tagNo);
  if entry = nil then Exit;
  v := entry.value.Value;
  if order = MM then v := SwapDWord(v);
  Result := v;
end;

function TKIFDIO.getTagValue(tagNo: Integer; Block: Integer): DWORD;
var
  entry: TKIFDEntry;
  v:DWORD;
begin
  Result := 0;
  entry := findTag(tagNo,Block);
  if entry = nil then Exit;
  v := entry.value.Value;
  if order = MM then v := SwapDWord(v);
  Result := v;
end;

function TKIFDIO.getThumbnail: TMemoryStream;
var
  data: string;
  v, f_offset,f_count:DWORD;
begin
  Result := nil;
  v := getTagValue(EXIF_TAG_COMPRESSION);
  if v = 0 then // ERROR
  begin
    Exit;
  end;
  if v = 6 then // JPEG
  begin
    f_offset := getTagValue(EXIF_TAG_JPEG_IF_OFFSET);
    f_count  := getTagValue(EXIF_TAG_JPEG_IF_BYTE_COUNT);
  end else
  if v = 1 then // TIFF
  begin
    f_offset := getTagValue(EXIF_TAG_STRIP_OFFSET);
    f_count  := getTagValue(EXIF_TAG_STRIP_BYTE_COUNT);
  end else Exit; // ERROR
  Result := TMemoryStream.Create;
  stream.Position := Offset + f_offset;
  SetLength(data, f_count);
  stream.Read(data[1], f_count);
  Result.Write(data[1], f_count);
end;

function TKIFDIO.readDWord: DWORD;
begin
  stream.Read(Result, 4);
  if order = MM then Result := SwapDWord(Result);
end;

procedure TKIFDIO.ReadEntry;
var
  i: Integer;
  rec: TKTiffIFDValue;
  entry: TKIFDEntry;
  ent_pos,val: Int64;
  typ, cnt, tag, dataCount: Integer;
  s: string;
  ko,oya: DWORD;

  procedure _readDataArea(p:TKIFDEntry);
  var
    data_size: Int64;
    block: Integer;
  begin
    tag := checkWord(p.value.TagNo);
    typ := checkWord(p.value.DataType);
    cnt := checkDWord(p.value.DataCount);
    val := checkDWord(p.value.Value);
    // debug
    debug('@'+IntToStr(ent_pos)+':$' + IntToHex(tag, 2) + '(' + IntToStr(tag) + '),type=' + IntToStr(typ) + ',value=' + IntToStr(val)+',cnt='+IntToStr(p.value.DataCount));
    // Check Sub IFD
    if (tag = EXIF_TAG_SUBIFD)or(tag = EXIF_INTEROPERABILITY_OFFSET)or(tag = EXIF_TAG_GPSINFO) then
    begin
      if tag = EXIF_TAG_SUBIFD then debug('<subifd sub>')
      else if tag = EXIF_TAG_GPSINFO then debug('<subifd GPSINFO>')
      else debug('<subifd INTEROPERABILITY>');
      if tag = EXIF_TAG_SUBIFD then block := BLOCK_IFD_SUB
      else if tag = EXIF_TAG_GPSINFO then block := BLOCK_IFD_GPS
      else block := BLOCK_IFD_IIFD;

      stream.Position := offset + val;
      p.subIFD := TKIFDIO.Create(stream, block, Offset, order, debugOut);
      debug('</subifd>');
    end else
    // Check Data Area
    if ((typ = TV_TYPE_ASCII)and(cnt > 4))or(typ = TV_TYPE_SRATION)or(typ = TV_TYPE_SDOUBLE)or
       (typ = TV_TYPE_URATION)or
       (cnt >= 5) then
    begin
      stream.Position := offset + val;

      if typ = TV_TYPE_ASCII then
      begin
        data_size := cnt;
      end else
      begin
        data_size := TV_TYPE_DATA_SIZE[typ] * cnt;
      end;
      // Exif の範囲外
      if data_size > $FFFF then raise Exception.Create('Exif Broken');
      SetLength(s, data_size);
      if data_size <> stream.Read(s[1], data_size) then debug('maybe broken.read entry');
      p.data := s;
      Inc(dataCount, data_size);
      // debug
      if typ = TV_TYPE_ASCII then
      begin
        debug('data:' + s);
      end else
      if typ = TV_TYPE_URATION then
      begin
        GetRationType(s, ko, oya);
        ko := CheckDWord(ko);
        oya := CheckDWord(oya);
        debug('data:' + IntToStr((ko)) + '/' + IntToStr((oya)));
      end;
    end else
    if typ = TV_TYPE_UNDEFINED then
    begin
      SetLength(s, 4);
      Move(p.value.Value, s[1], 4);
      debug('data:' + s);
    end;
  end;

begin
  // todo: readEntry
  dataCount := 0;
  // read Entry Count
  EntryCount := readWord;
  debug('entryCount:' +IntToStr(EntryCount));
  for i := 0 to EntryCount - 1 do
  begin
    // read entry
    ent_pos := stream.Position;
    if stream.Read(rec, SizeOf(rec)) <> SizeOf(rec) then raise Exception.Create('Broken Exif Data');
    entry := TKIFDEntry.Create(order);
    entry.value := rec;
    list.Add(entry);
    _readDataArea(entry);
    stream.Position := ent_pos + SizeOf(rec);
  end;
  FNextIFD := readDWord;
  //
  debug('DataArea:%' + IntToStr(stream.Position - Offset) + '/DataCountLow:' + IntToStr(dataCount));
  debug('NextIFD:%' + IntToStr(FNextIFD));
end;

function TKIFDIO.readWord: WORD;
begin
  stream.Read(Result, 2);
  if order = MM then Result := SwapWord(Result);
end;

procedure TKIFDIO.writeEntryApp1(mem: TMemoryStream; offset: Int64;
  thumb: TMemoryStream; isLast: Boolean);
var
  s: string;
  p: TKIFDEntry;

  function ent(tag, typ, cnt, val: DWORD):TKIFDEntry;
  begin
    Result := findTag(tag);
    if Result = nil then
    begin
      Result := TKIFDEntry.Create(
        checkWord(tag),
        checkWord(typ),
        checkDWord(cnt),
        checkDWord(val),
        order);
      list.Add(Result);
    end else
    begin
      Result.value.DataType  := CheckWord(typ);
      Result.value.DataCount := CheckDWord(cnt);
      Result.value.Value     := checkDWord(val);
    end;
  end;

begin
  if thumb = nil then Exit;
  ent(EXIF_TAG_COMPRESSION, 3, 1, 6);
  //ent(EXIF_TAG_ORIENTATION, 3, 1, 1);

  p := ent(EXIF_TAG_XRESOLUTION, 5, 1, 0);
  p.data := MakeRationType(checkDWord(72), checkDWord(1));
  p := ent(EXIF_TAG_YRESOLUTION, 5, 1, 0);
  p.data := MakeRationType(checkDWord(72), checkDWord(1));

  ent(EXIF_TAG_RESOLUTIONUNIT,     3, 1, 2);
  ent(EXIF_TAG_JPEG_IF_OFFSET,     4, 1, 0);
  ent(EXIF_TAG_JPEG_IF_BYTE_COUNT, 4, 1, thumb.Size);

  // write thumb
  thumb.Position := 0;
  SetLength(s, thumb.Size);
  thumb.Read(s[1], thumb.Size);
  //
  writeEntry(mem, offset, s, isLast);
end;

procedure TKIFDIO.writeEntry(mem: TMemoryStream; offset: Int64; ExtDat: string; isLast: Boolean; subifd_pos: Int64 = 0);
var
  dat: string;
  i: Integer;
  w: Word;

  start_ifd_pos, start_ext_pos, dataarea_pos: Int64;
  data_pos: Int64;
  thumb_offset_ent, tmp_pos: Int64;
  thumb_ent: TKTiffIFDValue;
  next_ifd: DWORD;

  procedure _writeSubIDF(p: TKIFDEntry);
  var buf: string; submem: TMemoryStream;
  begin
    // Offsetからのデータの書き込み位置(Exifの値)
    dataarea_pos := data_pos + Length(dat) - offset + subifd_pos;
    p.value.Value := checkDWord(dataarea_pos);
    //dat := dat + #0#0 + #0#0#0#0;
    //Exit;

    if (p.subIFD = nil) then raise Exception.Create('Exif SubFID not set.');

    submem := TMemoryStream.Create;
    debug('<subifd>');
    p.subIFD.writeEntry(submem, offset, '', True, dataarea_pos + offset);
    debug('</subifd>');
    SetLength(buf, submem.Size);
    submem.Position := 0;
    submem.Read(buf[1], submem.Size);
    //submem.SaveToFile('a.bin');
    debug('subifd.size=' + IntToStr(submem.size));
    dat := dat + buf;
    submem.Free;
  end;

  procedure _writeEnt(p: TKIFDEntry);
  var tag: Word;
  begin
    tag := checkWord(p.value.TagNo);
    // SubIFD
    if p.subIFD <> nil then
    begin
      _writeSubIDF(p);
    end else
    if Length(p.data) > 0 then //has DataArea
    begin
      // Offsetからのデータの書き込み位置(Exifの値)
      dataarea_pos := data_pos + Length(dat) - offset + subifd_pos;
      p.value.Value := checkDWord(dataarea_pos);
      dat := dat + p.data;
    end else
    // THUMBNAIL
    if tag = EXIF_TAG_JPEG_IF_OFFSET then // 例外的に
    begin
      thumb_offset_ent := mem.Position;
      thumb_ent        := p.value;
      p.value.Value    := 0; // dummy
    end;
    // write ENTRY
    mem.Write(p.value, SizeOf(p.value));
    // debug
    debug('@'+IntToStr(mem.Position)+':tag=' + IntToStr(p.value.TagNo) +
      ',typ=' + IntToStr(p.value.DataType) + 
      ',val=' + IntToStr(p.value.Value) + ',cnt=' + IntToStr(p.value.DataCount));
  end;

begin
  // todo: Write Entry

  // mem           .. 実際に書き込むストリーム
  // mem.position  .. 書き込み位置
  // start_ifd_pos .. 書き込み開始位置
  // data_pos      .. データの書き込み位置

  EntryCount    := list.Count;
  start_ifd_pos := mem.Position;
  data_pos      := start_ifd_pos + 2{EntCount} + SizeOf(TKTiffIFDValue) * EntryCount + 4{next_ifd};

  debug('*start_ifd_pos='+IntToStr(start_ifd_pos));
  debug('*data_pos     ='+IntToStr(data_pos));
  debug('*offset       ='+IntToStr(offset));
  debug('*entryCount   ='+IntToStr(EntryCount));

  thumb_offset_ent := 0;

  // Write Entry Count
  w := list.Count;
  mem.Write(w, 2);

  // Write Basic entry
  dat := '';
  for i := 0 to list.Count - 1 do
  begin
    _writeEnt(TKIFDEntry(list.Items[i]));
  end;

  // Write Next IFD
  if isLast then
  begin
    next_ifd := 0;
  end else
  begin
    next_ifd := mem.Position - offset + 4{NextIFD} + Length(dat) + Length(ExtDat);
  end;
  mem.Write(next_ifd, 4);

  // Write DataArea
  if Length(dat) > 0 then
  begin
    debug('dataarea.fpos=' + IntToStr(mem.Position));
    debug('dataarea.len=' + IntToStr(Length(dat)));
    mem.Write(dat[1], Length(dat));
  end;

  // Write Thumbnail
  if (Length(ExtDat) > 0) and (thumb_offset_ent > 0) then
  begin
    debug('extdata.fpos=' + IntToStr(mem.Position));
    start_ext_pos := mem.Position - offset;
    debug('extdata.fpos=' + IntToStr(start_ext_pos));
    mem.Write(ExtDat[1], Length(ExtDat));
    //
    tmp_pos := mem.Position;
    // rewrite Entry
    thumb_ent.Value := CheckDWord(start_ext_pos);
    mem.Position := thumb_offset_ent;
    mem.Write(thumb_ent, SizeOf(thumb_ent)); // rewrite
    //
    mem.Position := tmp_pos;
  end;
  debug('end.of.ifd.fpos=' + IntToStr(mem.Position));

  // check next ifd
  if not isLast then
  begin
    if next_ifd <> (mem.Position - offset) then
    begin
      raise Exception.Create('Exif Entry Calc error:' + IntToStr(next_ifd) + '<>' +
        IntToStr(mem.Position - offset));
    end;
  end;
end;

procedure TKIFDIO.debug(msg: string);
begin
  if Assigned(debugOut) then
  begin
    debugOut(msg);
  end;
end;

function TKIFDIO.getTagList: string;
var
  p, sub: TKIFDEntry;
  ei,i: Integer;
begin
  Result := '';
  // main
  for i := 0 to list.Count - 1 do
  begin
    p := TKIFDEntry(list.Items[i]);
    ei := getExifIndexFromTagNo(p.TagNo, FBlock);
    // 念のため含めない
    if (p.TagNo = EXIF_TAG_SUBIFD) or
       (p.TagNo = EXIF_INTEROPERABILITY_OFFSET) or
       (p.TagNo = EXIF_TAG_GPSINFO) then
    begin
      Continue;
    end;
    //
    if ei < 0 then
    begin
      Result := Result + '$' + IntToHex(p.TagNo, 4) + '=' + p.toString;
    end else
    begin
      Result := Result + F_EXIF_NAME[ei] + '=' + p.toString;
    end;
    Result := Result + #13#10;
  end;
  // sub
  sub := findTag(EXIF_TAG_SUBIFD);
  if sub <> nil then
  begin
    Result := Result + sub.subIFD.getTagList;
  end;
  // gps
  sub := findTag(EXIF_TAG_GPSINFO);
  if sub <> nil then
  begin
    Result := Result + sub.subIFD.getTagList;
  end;
end;

function TKIFDIO.getExifIndexFromTagNo(TagNo: Integer; Block: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to high(F_EXIF_TAG) do
  begin
    if F_EXIF_TAG[i] = TagNo then
    begin
      if (Block = BLOCK_IFD_GPS) and (F_EXIF_PLACE[i] = F_GpsIFD) then
      begin
        Result := i;
        Break;
      end else
      if (Block <> BLOCK_IFD_GPS) and (F_EXIF_PLACE[i] <> F_GpsIFD) then
      begin
        Result := i;
        Break;
      end;
    end;
  end;
end;

function TKIFDIO.getExifIndexFromTagName(TagName: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to high(F_EXIF_TAG) do
  begin
    if F_EXIF_NAME[i] = TagName then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TKIFDIO.setTagList(tags: string);
var
  i: Integer;
  taglist: TStringList;
  tagidx, tagno: Integer;
  line, tag: string;
  p, sub: TKIFDEntry;
  block: Integer;
begin
  taglist := TStringList.Create;
  try
    taglist.Text := tags;
    for i := 0 to taglist.Count - 1 do
    begin
      line := taglist.Strings[i];
      tag := getToken_s(line, '=');
      tagidx := getExifIndexFromTagName(tag);
      if tagidx < 0 then continue;
      tagno := F_EXIF_TAG[tagidx];
      block := BLOCK_IFD_BASE;
      if F_EXIF_PLACE[tagidx] = F_GpsIFD then
      begin
        block := BLOCK_IFD_GPS;
      end;
      p := findTag(tagno, block);
      if p = nil then Continue; //todo: 現在書き換えのみ対応
      p.setFromString(line);
    end;
    // sub
    sub := findTag(EXIF_TAG_SUBIFD);
    if sub <> nil then
    begin
      sub.subIFD.setTagList(tags);
    end;
    // gps
    sub := findTag(EXIF_TAG_GPSINFO);
    if sub <> nil then
    begin
      sub.subIFD.setTagList(tags);
    end;
  finally
    FreeAndNil(taglist);
  end;
end;

{ TKRawExif }

function TKRawExif.CheckDWord(b: DWord): DWord;
begin
  Result := b;
  if ByteOrder = MM then Result := SwapDWord(Result);
end;

function TKRawExif.CheckWord(b: Word): Word;
begin
  Result := b;
  if ByteOrder = MM then Result := SwapWord(Result);
end;

procedure TKRawExif.clear;
var
  i: Integer;
  p: TKIFDIO;
begin
  for i := 0 to list.Count - 1 do
  begin
    p := TKIFDIO(list.Items[i]);
    FreeAndNil(p);
  end;
  list.Clear;
end;

constructor TKRawExif.Create(exif_stream: TMemoryStream; debugOut: TKJepgDebugOutProc = nil);
begin
  stream := exif_stream;
  thumb  := nil;
  list := TList.Create;
  Self.debugOut := debugOut;
  // --- read
  readIFD;
end;

procedure TKRawExif.debug(msg: string);
begin
  if Assigned(debugOut) then
  begin
    debugOut(msg);
  end;
end;

destructor TKRawExif.Destroy;
begin
  clear;
  FreeAndNil(list);
  inherited;
end;

function TKRawExif.genExifData: TMemoryStream;
var
  mOffset: Int64;
  posSegLen: Integer;
  w: WORD;
  dw: DWORD;
  i: Integer;
  p: TKIFDIO;
begin
  Result := TMemoryStream.Create;
  w := 0;
  // APP1
  Result.Write(APP1[1], 2);
  // ** Seg Length
  posSegLen := Result.Position;
  Result.Write(w, 2);
  // Exif Header
  Result.Write(EXIF_HEADER_ID[1], 6);
  mOffset := Result.Position;
  // TIFF Header
  if ByteOrder = II then
  begin
    Result.Write(TIFF_HEADER_ID_II[1], 2);
  end else begin
    Result.Write(TIFF_HEADER_ID_MM[1], 2);
  end;
  w := CheckWord($2A); // 0x2a
  Result.Write(w, 2);
  dw := CheckDWord(8);
  Result.Write(dw, 4);
  //
  for i := 0 to list.Count - 1 do
  begin
    p := TKIFDIO(list.Items[i]);
    if i = 1 then // Thumb
    begin
      p.writeEntryApp1(Result, mOffset, thumb, (i = (list.Count - 1)));
    end else
    begin
      p.writeEntry(Result, mOffset, '', (i = (list.Count - 1)));
    end;
  end;
  //
  Result.Position := posSegLen;
  w := SwapWord(Result.Size - 2{Marker}); // must be MM
  Result.Write(w, 2);
end;

function TKRawExif.getCopyright: string;
begin
  Result := getValueAscii(EXIF_TAG_COPYRIGHT);
end;

function TKRawExif.getEntry(tag: Integer): TKIFDEntry;
begin
  Result := nil;
  if (ifd0 = nil) then Exit;
  Result := ifd0.findTag(tag);
end;




function TKRawExif.getIFD0: TKIFDIO;
begin
  Result := nil;
  if list.Count >= 1 then
  begin
    Result := TKIFDIO(list.Items[0]);
  end;
end;

function TKRawExif.getMaker: string;
begin
  Result := getValueAscii(EXIF_TAG_MAKE);
end;

function TKRawExif.getModel: string;
begin
  Result := getValueAscii(EXIF_TAG_MODEL);
end;

function TKRawExif.getModifyDate: string;
begin
  Result := getValueAscii(EXIF_TAG_DATETIME);
end;

function TKRawExif.getOrientation: Integer;
begin
  Result := getValueUShort(EXIF_TAG_ORIENTATION);
end;

function TKRawExif.getTitle: string;
begin
  Result := getValueAscii(EXIF_TAG_IMAGEDESCRIPTION);
end;

function TKRawExif.getValueAscii(tagNo: Integer): string;
var
  p: TKIFDEntry;
begin
  Result := '';
  p := getEntry(tagNo);
  if p = nil then Exit;
  Result := p.getAscii;
end;

function TKRawExif.getValueUShort(tagNo: Integer): Word;
var
  p: TKIFDEntry;
begin
  Result := 0;
  p := getEntry(tagNo);
  if p = nil then Exit;
  Result := p.getValueUShort;
end;

procedure TKRawExif.readIFD;
var
  mak, head, order: string;
  sz: WORD;
  linkIFD0: DWORD;
  p, ifd1: TKIFDIO;
begin
  // read JPEG.APP1 Marker
  stream.Position := 0;
  mak := readStr(2);
  if (mak <> APP1) then Exit;
  // sizeof APP1
  if stream.Read(sz, 2) <> 2 then Exit;

  // Exif Header
  head := readStr(6);
  if head <> EXIF_HEADER_ID then Exit;
  Offset := stream.Position;
  // TIFF Header (8byte)
  // Byte Order
  order := readStr(4);
  debug('ORDER:' + order);
  if (order = TIFF_HEADER_ID_II) then
  begin
    ByteOrder := II;
  end else
  if (order = TIFF_HEADER_ID_MM) then
  begin
    ByteOrder := MM;
  end else
  begin // ng
    Exit;
  end;
  if stream.Read(linkIFD0, 4) <> 4 then Exit;
  linkIFD0 := CheckDWord(linkIFD0);

  // move to IFD0
  stream.Position := Offset + linkIFD0;

  // Read IFDs
  while True do
  begin
    debug('---ReadIDF');
    if (stream.Position + 6) >= stream.Size then
    begin
      debug('[ERROR]Maybe Broken');
      Break;
    end;
    p := TKIFDIO.Create(stream, BLOCK_IFD_BASE, Offset, ByteOrder, debugOut);
    list.Add(p);
    if p.NextIFD = 0 then Break;
    if ((Offset + p.NextIFD) >= stream.Size) then
    begin
      debug('[ERROR]Maybe Broken');
    end;
    stream.Position := Offset + p.NextIFD;
  end;

  if list.Count >= 1 then
  begin
    // ifd0 := TKIFDIO(list.Items[0]);
  end;
  if list.Count >= 2 then
  begin
    ifd1 := TKIFDIO(list.Items[1]);
    thumb := ifd1.getThumbnail;
  end;
  
end;

function TKRawExif.readStr(count: Integer): String;
begin
  SetLength(Result, Count);
  if count <> stream.Read(Result[1], count) then
  begin
    Result := '';
  end;
end;

procedure TKRawExif.setCopyright(const Value: string);
begin
  setValueAscii(EXIF_TAG_COPYRIGHT, Value);
end;

procedure TKRawExif.setMaker(const Value: string);
begin
  setValueAscii(EXIF_TAG_MAKE, Value);
end;

procedure TKRawExif.setModel(const Value: string);
begin
  setValueAscii(EXIF_TAG_MODEL, Value);
end;

procedure TKRawExif.setModifyDate(const Value: string);
begin
  setValueAscii(EXIF_TAG_DATETIME, Value);
end;

procedure TKRawExif.setOrientation(const Value: Integer);
begin
  setValueUShort(EXIF_TAG_ORIENTATION, Value);
end;

procedure TKRawExif.setTitle(const Value: string);
begin
  setValueAscii(EXIF_TAG_IMAGEDESCRIPTION, Value);
end;

procedure TKRawExif.setValueAscii(tagNo: Integer; value: string);
var
  p: TKIFDEntry;
begin
  p := getEntry(tagNo);
  if p = nil then
  begin
    p := TKIFDEntry.Create(tagNo, 2, 0, 0, ByteOrder);
    ifd0.list.Add(p);
  end;
  p.value.DataCount := CheckDWord(Length(value) + 1);
  p.data := value + #0;
end;

procedure TKRawExif.setValueUShort(tagNo: Integer; value: Word);
begin

end;

{ TKIFDEntry }

function TKIFDEntry.checkDWord(w: DWord): DWord;
begin
  Result := w;
  if order = MM then Result := SwapDWord(Result);
end;

function TKIFDEntry.checkWord(w: Word): Word;
begin
  Result := w;
  if order = MM then Result := SwapWord(Result);
end;

constructor TKIFDEntry.Create(Tag: WORD; Typ:WORD; Cnt:DWORD; Val:DWORD; order:TKExifByteOrder);
begin
  value.TagNo := Tag;
  value.DataType := Typ;
  value.DataCount := Cnt;
  value.Value := Val;
  Create(order);
end;

constructor TKIFDEntry.Create(order:TKExifByteOrder);
begin
  Self.order := order;
  data := '';
  subIFD := nil;
end;


function TKIFDEntry.getAscii: string;
begin
  Result := PChar(data);
end;

function TKIFDEntry.getValueByte: BYTE;
begin
  Result := value.Value;
end;

function TKIFDEntry.getValueChar: Short;
begin
  Result := value.Value;
end;

function TKIFDEntry.getValueUShort: WORD;
begin
  Result := checkWord(value.Value);
end;

function TKIFDEntry.getValueShort: Short;
begin
  Result := checkWord(value.Value);
end;

function TKIFDEntry.getValueULong: DWORD;
begin
  Result := checkDWord(value.Value);
end;

function TKIFDEntry.getValueLong: Integer;
begin
  Result := checkDWord(value.Value);
end;

function TKIFDEntry.getTagNo: Integer;
begin
  Result := checkWord(value.TagNo);
end;

function TKIFDEntry.getTagTyp: Integer;
begin
  Result := checkWord(value.DataType);
end;

function TKIFDEntry.getValue: DWORD;
begin
  Result := checkDWord(value.Value);
end;

function TKIFDEntry.getCount: DWORD;
begin
  Result := checkDWord(value.DataCount);
end;

function TKIFDEntry.toString: string;
var
  oya,ko:DWORD;
  ioya,iko: Integer;
  f: Single;
  d: Double;
  i: Integer;
begin
  Result := '';
  case Self.Typ of
  TV_TYPE_ASCII:
    begin
      if Self.Count <= 4 then
      begin
        Result := #0#0#0#0;
        Move(value.Value, Result[1], 4);
      end else
      begin
        Result := PChar(Self.data);
      end;
    end;
  TV_TYPE_UNDEFINED,
  TV_TYPE_UBYTE:
    begin
      Result := IntToStr(getValueByte);
    end;
  TV_TYPE_USHORT:
    begin
      Result := IntToStr(getValueUShort);
    end;
  TV_TYPE_ULONG:
    begin
      Result := IntToStr(getValueULong);
    end;
  TV_TYPE_SBYTE:
    begin
      Result := IntToStr(getValueChar);
    end;
  TV_TYPE_SSHORT:
    begin
      Result := IntToStr(getValueShort);
    end;
  TV_TYPE_SLONG:
    begin
      Result := IntToStr(getValueLong);
    end;
  TV_TYPE_URATION:
    begin
      for i := 0 to getCount -1 do
      begin
        GetRationType(Copy(data,i*8+1,i*8+8), ko, oya);
        Result := Result + IntToStr(checkDWord(ko)) + '/' + IntToStr(checkDWord(oya))+',';
      end;
      if Result <> '' then Result := Copy(Result,1,Length(Result)-1);
    end;
  TV_TYPE_SRATION:
    begin
      for i := 0 to getCount -1 do
      begin
        GetRationType(Copy(data,i*8+1,i*8+8), DWORD(iko), DWORD(ioya));
        Result := Result + IntToStr(checkDWord(iko)) + '/' + IntToStr(checkDWord(ioya))+',';
      end;
      if Result <> '' then Result := Copy(Result,1,Length(Result)-1);
    end;
  TV_TYPE_SFLOAT:
    begin
      Move(value.value, f, 4);
      Result := FloatToStr(f);
    end;
  TV_TYPE_SDOUBLE:
    begin
      Move(data, d, 8);
    end;
  end;
  Result := PChar(Result);
end;

procedure TKIFDEntry.setFromString(s: string);
begin
  case Self.Typ of
  TV_TYPE_ASCII:
    begin
      if Length(s) <= 4 then
      begin
        value.value := 0;
        Move(s[1], value.value, 4);
        value.DataCount := checkDWord(Length(s));
        data := '';
      end else
      begin
        data := s + #0;
        value.Value := 0;
        value.DataCount := checkDWord(Length(s) + 1);
      end;
    end;
  TV_TYPE_UBYTE,
  TV_TYPE_USHORT,
  TV_TYPE_UNDEFINED,
  TV_TYPE_ULONG:
    begin
      if Pos(',', s) = 0 then
        value.Value := checkDWord(StrToIntDef(s, 0));
    end;
  TV_TYPE_SBYTE,
  TV_TYPE_SSHORT,
  TV_TYPE_SLONG:
    begin
      if Pos(',', s) = 0 then
        value.Value := checkDWord(StrToIntDef(s, 0));
    end;
  TV_TYPE_URATION:
    begin
    end;
  TV_TYPE_SRATION:
    begin
    end;
  TV_TYPE_SFLOAT:
    begin
      if Pos(',', s) = 0 then
      begin
      end;
    end;
  TV_TYPE_SDOUBLE:
    begin
      if Pos(',', s) = 0 then
      begin
      end;
    end;
  end;
end;

procedure TKIFDEntry.setValue(const Value: DWORD);
begin
  Self.value.Value := checkDWord(Value);
end;

end.
