unit JpegEx;

// *****************************************************************************
//   TJpegEx クラス Version 2.1    copyright(c) みず, 2004-2005
// *****************************************************************************

interface

uses
  Windows, Classes, SysUtils, Graphics, Jpeg, ClipBrd;

type
  TJpegEx = class;
  TJpegBuffer = class;

  // $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
  // $$ データ型                                                              $$
  // $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

  TBit = 0..1;

  PHuffmanItem = ^THuffmanItem;
  THuffmanItem = record
    Index: Integer;
    pNext: array[TBit] of PHuffmanItem;
    Bit: TBit;
    Code: Word;
    Level: Integer;
    ZeroRun: Byte;
    Vm: Byte;
    Flag: Boolean;
  end;
  THuffmanItems = array[0..16] of PHuffmanItem;
  THuffBitCount = 1..16;
  THuffmanValues = array[THuffBitCount] of Integer;
  TCodeData = record
    Code: Word;
    Col: Byte;
  end;
  TCodeDatas = array of TCodeData;

  TJPEGSamplingRate = (jsr411, jsr422, jsr444, jsrCustom);
  TJPEGElement = packed record
    HorzRate: Byte;      // 水平サンプリングレート
    VertRate: Byte;      // 垂直サンプリングレート
    Quan: Integer;       // 量子化テーブル番号
    DCTable: Integer;    // DC成分ハフマンテーブル
    ACTable: Integer;    // AC成分ハフマンテーブル
  end;
  TJPEGElementArray = array[0..2] of TJPEGElement;
  TQuantium = array[0..63] of SmallInt;
  PQuantium = ^TQuantium;
  TDensityUnit = (duUndefine, duDotPerInch, duDotPerCM);
  TYccImages = array[0..2] of PByteArray;

  // $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
  // $$ クラス                                                                $$
  // $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

  // ###########################################################################
  // ## 例外クラス                                                            ##
  // ###########################################################################
  EJpegEx = class(Exception);

  // ###########################################################################
  // ## ハフマンテーブルクラス                                                ##
  // ###########################################################################
  THuffmanTable = class(TPersistent)
  private
    // ********************************************Private宣言**
    // ===========================================フィールド==
    FCodeItems: TList;
    FEOBIndex: Integer;
    FItems: TList;
    FTcTh: Byte;
    FTop: PHuffmanItem;
    FZero: array[0..16] of THuffmanItems;
    FZRLIndex: Integer;
    // =============================================メソッド==
    procedure AddItem(Code: Word; ZeroRun, Column, CodeLength: Byte);
    procedure ClearItems;
    procedure CreateTable;
    procedure MakeCodeList(Values: THuffmanValues; var Codes: TCodeDatas);
    // ---------------------------------プロパティアクセス--
    function GetCount: Integer;
    function GetVm(Index: Integer): Byte;
  protected
    // ******************************************Protected宣言**
    // =============================================メソッド==
    procedure AssignTo(Dest: TPersistent); override;
    procedure CreateCAC; dynamic;
    procedure CreateCDC; dynamic;
    procedure CreateYAC; dynamic;
    procedure CreateYDC; dynamic;
  public
    // *********************************************Public宣言**
    // =============================================メソッド==
    constructor Create(ATcTh: Byte);
    destructor Destroy; override;
    procedure Clear;
    function CodeCount(BitLength: Integer): Integer;
    function Decode(Buffer: TJpegBuffer; out ZeroRun: Integer): Integer;
    procedure Encode(Buffer: TJpegBuffer; const ZeroRun, Value: SmallInt);
    function FieldLength: Integer;
    procedure SaveCodeList(const FileName: string);
    // ===========================================プロパティ==
    property Count: Integer read GetCount;
    property TcTh: Byte read FTcTh;
    property Vm[Index: Integer]: Byte read GetVm;
  end;

  // ###########################################################################
  // ## ハフマンテーブルリストクラス                                          ##
  // ###########################################################################
  THuffmanTables = class(TPersistent)
  private
    // ********************************************Private宣言**
    // ===========================================フィールド==
    FTables: TList;
    // =============================================メソッド==
    // ---------------------------------プロパティアクセス--
    function GetTable(Index: Integer): THuffmanTable;
    function GetCount: Integer;
  protected
    // ******************************************Protected宣言**
    // =============================================メソッド==
    procedure AssignTo(Dest: TPersistent); override;
  public
    // *********************************************Public宣言**
    // =============================================メソッド==
    constructor Create(NowCreation: Boolean);
    destructor Destroy; override;
    function Add(TcTh: Byte): Integer;
    procedure Clear;
    function FindTable(ATcTh: Byte): Integer;
    function RecordLength: Integer;
    // ===========================================プロパティ==
    property Count: Integer read GetCount;
    property Tables[Index: Integer]: THuffmanTable read GetTable;
  end;

  // ###########################################################################
  // ## JPEGストリームバッファクラス                                          ##
  // ###########################################################################
  TJpegBuffer = class(TObject)
  private
    // ********************************************Private宣言**
    // ===========================================フィールド==
    FBuffer: TMemoryStream;
    FBuffered: Boolean;
    FBufferSize: Integer;
    FImage: TJpegEx;
    FStream: TStream;
    // =============================================メソッド==
    procedure CreateBuffer;
    procedure WriteBuffer;
  protected
  public
    // *********************************************Public宣言**
    // =============================================メソッド==
    constructor Create(AImage: TJpegEx; ABufferSize: Integer);
    destructor Destroy; override;
    function AsSmall(Vm: Byte): SmallInt;
    procedure Buffering;
    procedure Clear;
    function ReadBit: Byte;
    procedure WriteBitAll;
    procedure WriteBits(const Value: Cardinal; Count: Integer);
  end;

  // ###########################################################################
  // ## JPEGイメージクラス                                                    ##
  // ###########################################################################
  TJpegEx = class(TGraphic)
  private
    // ********************************************Private宣言**
    // ===========================================フィールド==
    FComment: string;
    FCompressionQuality: TJPEGQualityRange;
    FDensityUnit: TDensityUnit;
    FElem: TJPEGElementArray;
    FGrayImage: Boolean;
    FGrayScale: Boolean;
    FHeight: Integer;
    FHuffs: THuffmanTables;
    FImage: TBitmap;
    FJpegStream: TMemoryStream;
    FPixelFormat: TJPEGPixelFormat;
    FQuanAccurate: array of Byte;
    FQuanTable: TList;
    FRateOld: array[0..2] of Byte;
    FRestartInterval: Integer;
    FSampling: TJPEGSamplingRate;
    FWidth: Integer;
    FXDensity: Word;
    FYDensity: Word;
    // =============================================メソッド==
    procedure ClearQuanTable;
    procedure CreateMemoryStream;
    procedure FreeImageObject;
    procedure FreeJpegStream;
    procedure GetImageSize;
    procedure InitDIB;
    procedure InitJpegStream;
    procedure InitQuantiumTable;
    procedure LoadToMemory(Stream: TStream; Len: Int64);
    procedure ReadHuffmanTable(Stream: TStream);
    procedure ReadQuanTable(Stream: TStream);
    procedure ReadSOF0;
    procedure ReadSOF2;
    procedure ReadSOS;
    function RGBToYCC(Source: TBitmap; var Dest: TYccImages): Integer;
    procedure SetQuanArray(TableNum: Integer; const V: array of SmallInt);
    procedure WriteJpegHeader;
    procedure YCCToRGB(Source: TYccImages; Dest: TBitmap; W: Integer);
    // --------------------------------プロパティアクセス--
    procedure SetSampling(const Value: TJPEGSamplingRate);
    function GetCanvas: TCanvas;
    procedure SetCompressionQuality(const Value: TJPEGQualityRange);
    procedure SetGrayScale(const Value: Boolean);
    procedure SetRestartInterval(const Value: Integer);
  protected
    // ******************************************Protected宣言**
    // =============================================メソッド==
    procedure AssignTo(Dest: TPersistent); override;
    function CreateHuffmanTables(NowCreation: Boolean): THuffmanTables; virtual;
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); override;
    function GetEmpty: Boolean; override;
    function GetHeight: Integer; override;
    function GetWidth: Integer; override;
    procedure NeedHuffmanTables(NowCreation: Boolean);
    procedure SetHeight(Value: Integer); override;
    procedure SetWidth(Value: Integer); override;
    // ===========================================プロパティ==
    property JpegStream: TMemoryStream read FJpegStream;
  public
    // *********************************************Public宣言**
    // =============================================メソッド==
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure ChangeGrayScale;
    function CustomSampling(Y, Cb, Cr: Integer): Boolean;
    procedure LoadFromClipboardFormat(AFormat: Word; AData: THandle;
      APalette: HPALETTE); override;
    procedure LoadFromFile(const FileName: string); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure NeedDIB;
    procedure NeedJpegInfo;
    procedure NeedJpegStream;
    procedure SaveToClipboardFormat(var AFormat: Word; var Data: THandle;
        var APalette: HPALETTE); override;
    procedure SaveToStream(Stream: TStream); override;
    // ===========================================プロパティ==
    property Canvas: TCanvas read GetCanvas;
    property Comment: string read FComment write FComment;
    property CompressionQuality: TJPEGQualityRange read FCompressionQuality
        write SetCompressionQuality;
    property DensityUnit: TDensityUnit read FDensityUnit write FDensityUnit;
    property GrayScale: Boolean read FGrayScale write SetGrayScale;
    property RestartInterval: Integer read FRestartInterval
        write SetRestartInterval;
    property Sampling: TJPEGSamplingRate read FSampling write SetSampling;
    property XDensity: Word read FXDensity write FXDensity;
    property YDensity: Word read FYDensity write FYDensity;
  end;

var
  CosRate: array[0..63] of Double;
  LoopX, LoopY: ShortInt;

implementation

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// $$ ローカルデータ型                                                        $$
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
type
  TRGBQuantium = packed record
    B: Byte;
    G: Byte;
    R: Byte;
  end;
  PRGBQuantium = ^TRGBQuantium;
  TRGBQuanArray = array[0..10921] of TRGBQuantium;
  PRGBQuanArray = ^TRGBQuanArray;

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// $$ ローカル定数                                                            $$
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
const
  BitRate: array[0..31] of LongWord = (
      $80000000, $40000000, $20000000, $10000000, $8000000, $4000000, $2000000,
      $1000000, $800000, $400000, $200000, $100000, $80000, $40000, $20000,
      $10000, $8000, $4000, $2000, $1000, $800, $400, $200, $100, $80, $40, $20,
      $10, $8, $4, $2, $1);
  ScanNumber: array[0..63] of Byte =
      (0, 1, 8, 16, 9, 2, 3, 10, 17, 24, 32, 25, 18, 11, 4, 5, 12, 19, 26, 33,
       40, 48, 41, 34, 27, 20, 13, 6, 7, 14, 21, 28, 35, 42, 49, 56, 57, 50,
       43, 36, 29, 22, 15, 23, 30, 37, 44, 51, 58, 59, 52, 45, 38, 31, 39, 46,
       53, 60, 61, 54, 47, 55, 62, 63);
  DCTRate: array[0..63] of Double =
      (0.125, 0.17678, 0.17678, 0.17678, 0.17678, 0.17678, 0.17678, 0.17678,
       0.17678, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25,
       0.17678, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25,
       0.17678, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25,
       0.17678, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25,
       0.17678, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25,
       0.17678, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25,
       0.17678, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25);
  BitInt: array[Boolean] of TBit = (0, 1);

  MSG_E_EMPTY = 'JpegEx: イメージがありません';
  MSG_E_FAILOPEN = 'JpegEx: オープンに失敗しました';
  MSG_E_EMPTYSTREAM = 'JpegEx: JPEGイメージがありません';
  MSG_E_STREAM = 'JpegEx: JPEGイメージが不正です';
  MSG_E_CORRESPONDENCE = 'JpegEx: 未対応の形式です';
  MSG_E_CLIPBOARDNODATA =
      'JpegEx: クリップボードが空か、または有効な形式のデータがありません';
  MSG_E_CANTCHANGESIZE = 'JpegEx: サイズを変更できません';
  MSG_INITIALIZING = '初期化中';
  MSG_ANALYZING = '解析中';
  MSG_DECODING = 'デコード中';
  MSG_ENCODING = 'エンコード中';

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// $$ ローカル関数・手続き                                                    $$
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

procedure SaveYcc(Ycc: TYccImages; W: Integer; const FileName: string);
var
  F: TFileStream;
  L1, L2: Integer;
  P: PByteArray;
  Buffer: Byte;
begin
  F := TFileStream.Create(FileName, fmCreate);
  try
    for L1 := 0 to 2 do
    begin
      P := Ycc[L1];
      for L2 := 0 to W do
      begin
        Buffer := P[L2];
        F.WriteBuffer(Buffer, 1);
      end;
    end;
  finally
    F.Free;
  end;
end;

// #############################################################################
// ## L Func: 文字列をストリームから読み取る
function ReadString(Stream: TStream): string;
var
  Buf: Char;
begin
  Result := '';
  repeat
    Stream.ReadBuffer(Buf, 1);
    if Buf <> #0 then Result := Result + Buf;
  until Buf = #0;
end;

// #############################################################################
// ## L Func: Word値をストリームから読み取る
function ReadWord(Stream: TStream): Word;
var
  Buffer: Word;
begin
  Stream.ReadBuffer(Buffer, 2);
  Result := Swap(Buffer);
end;

// #############################################################################
// ## L Proc: バイト値をストリームに書き込む
procedure WriteByte(Stream: TStream; Value: Byte);
begin
  Stream.WriteBuffer(Value, 1);
end;

// #############################################################################
// ## L Proc: 文字列をストリームに書き込む
procedure WriteString(Stream: TStream; const S: string);
begin
  Stream.WriteBuffer(PChar(S)^, Length(S) + 1);
end;

// #############################################################################
// ## L Proc: Word値をストリームに書き込む
procedure WriteWord(Stream: TStream; Value: Word);
var
  Buffer: Word;
begin
  // %%%%%%%%%%%%%%%%%%モトローラ形式で書き込む%%
  Buffer := Swap(Value);
  Stream.WriteBuffer(Buffer, 2);
end;

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// $$ { THuffmanTable }                                                       $$
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

// #############################################################################
// ## Method: テーブルアイテムの追加
procedure THuffmanTable.AddItem(Code: Word; ZeroRun, Column, CodeLength: Byte);
var
  Bit: TBit;
  Lc: Integer;
  pItems: THuffmanItems;
  pParent, pItem: PHuffmanItem;
begin
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%デコードツリー%%
  // :::::::::::::::::::::::::::::ツリー位置を検索して追加::
  Lc := 0;
  pParent := FTop;
  repeat
    Bit := BitInt[Code and BitRate[Lc + 16] <> 0];
    Inc(Lc);
    pItem := pParent.pNext[Bit];
    if pItem = nil then
    begin
      New(pItem);
      pItem^.pNext[0] := nil;
      pItem^.pNext[1] := nil;
      pItem^.Bit := Bit;
      pItem^.Code := 0;
      pItem^.Level := Lc;
      pItem^.ZeroRun := 0;
      pItem^.Vm := 0;
      pItem^.Flag := False;
      pItem^.Index := FItems.Add(pItem);
    end;
    pParent.pNext[Bit] := pItem;
    pParent := pItem;
  until Lc >= CodeLength;
  pItem^.Code := Code;
  pItem^.ZeroRun := ZeroRun;
  pItem^.Vm := Column;
  pItem^.Flag := True;
  pItem^.Index := FCodeItems.Add(pItem);
  if (Column = 0) and (FTcTh > $01) then
  begin
    case ZeroRun of
      0,99: begin
              pItem^.ZeroRun := 99;
              FEOBIndex := pItem^.Index;
            end;
      15  : FZRLIndex := pItem^.Index;
    end;
  end;
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%エンコードツリー%%
  pItems := FZero[ZeroRun];
  pItems[Column] := pItem;
  FZero[ZeroRun] := pItems;
end;

// #############################################################################
// ## Method: オブジェクトのコピー
procedure THuffmanTable.AssignTo(Dest: TPersistent);
var
  L: Integer;
  pItem: PHuffmanItem;
begin
  if Dest is THuffmanTable then
    with THuffmanTable(Dest) do
    begin
      ClearItems;
      FTcTh := Self.FTcTh;
      for L := 0 to Self.FItems.Count - 1 do
      begin
        pItem := Self.FItems[L];
        if pItem^.Flag then
          AddItem(pItem^.Code, pItem^.ZeroRun, pItem^.Vm, pItem^.Level);
      end;
    end
  else
    inherited;
end;

// #############################################################################
// ## Method: アイテムのクリア
procedure THuffmanTable.Clear;
begin
  ClearItems;
end;

// #############################################################################
// ## Method: アイテムのクリア
procedure THuffmanTable.ClearItems;
var
  pItem: PHuffmanItem;
  Item2: THuffmanItems;
  L, L2: Integer;
begin
  for L := 0 to FItems.Count - 1 do
  begin
    try
      pItem := PHuffmanItem(FItems[L]);
      Dispose(pItem);
      FItems[L] := nil;
    except
      FItems[L] := nil;
    end;
  end;
  for L := 0 to 16 do
  begin
    Item2 := FZero[L];
    for L2 := 0 to 16 do
      Item2[L2] := nil;
  end;
  FItems.Clear;
  FCodeItems.Clear;
  FTop^.pNext[0] := nil;
  FTop^.pNext[1] := nil;
end;

// #############################################################################
// ## Method: 指定ビット数のコード数を取得
function THuffmanTable.CodeCount(BitLength: Integer): Integer;
var
  L: Integer;
begin
  Result := 0;
  for L := 0 to FCodeItems.Count - 1 do
    if BitLength = PHuffmanItem(FCodeItems[L])^.Level then Inc(Result);
end;

// #############################################################################
// ## Method: コンストラクタ
constructor THuffmanTable.Create(ATcTh: Byte);
var
  L, L2: Integer;
begin
  inherited Create;
  FCodeItems := TList.Create;
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%初期化%%
  New(FTop);
  FTop^.Code := 0;
  FTop^.pNext[0] := nil;
  FTop^.pNext[1] := nil;
  FTop^.Flag := False;
  FTop^.Level := 0;
  FTop^.ZeroRun := 0;
  FTcTh := ATcTh;
  for L := 0 to 16 do
    for L2 := 0 to 16 do
      FZero[L][L2] := nil;
 // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%テーブル作成%%
  CreateTable;
end;

// #############################################################################
// ## Method: 色差のAC成分テーブルの作成
procedure THuffmanTable.CreateCAC;
const
  Vm1: array[0..161] of Byte =
      ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,15, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7,
        7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9,
        9, 9,10,10,10,10,10,10,10,10,10,10,11,11,11,11,11,11,11,11,
       11,11,12,12,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,13,
       13,13,14,14,14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15,
       15,15);
  Vm2: array[0..161] of Byte =
      ( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10, 1, 2, 3, 4, 5, 6, 7, 8, 9,
       10, 1, 2, 3, 4, 5, 6, 7, 8, 9,10, 0, 1, 2, 3, 4, 5, 6, 7, 8,
        9,10, 1, 2, 3, 4, 5, 6, 7, 8, 9,10, 1, 2, 3, 4, 5, 6, 7, 8,
        9,10, 1, 2, 3, 4, 5, 6, 7, 8, 9,10, 1, 2, 3, 4, 5, 6, 7, 8,
        9,10, 1, 2, 3, 4, 5, 6, 7, 8, 9,10, 1, 2, 3, 4, 5, 6, 7, 8,
        9,10, 1, 2, 3, 4, 5, 6, 7, 8, 9,10, 1, 2, 3, 4, 5, 6, 7, 8,
        9,10, 1, 2, 3, 4, 5, 6, 7, 8, 9,10, 1, 2, 3, 4, 5, 6, 7, 8,
        9,10, 1, 2, 3, 4, 5, 6, 7, 8, 9,10, 1, 2, 3, 4, 5, 6, 7, 8,
        9,10);
var
  CodeCount: Integer;
  Codes: TCodeDatas;
  Haff: THuffmanValues;
  L: Integer;
begin
  Haff[1] := 0;
  Haff[2] := 2;
  Haff[3] := 1;
  Haff[4] := 2;
  Haff[5] := 4;
  Haff[6] := 4;
  Haff[7] := 3;
  Haff[8] := 4;
  Haff[9] := 7;
  Haff[10] := 5;
  Haff[11] := 4;
  Haff[12] := 4;
  Haff[13] := 0;
  Haff[14] := 1;
  Haff[15] := 2;
  Haff[16] := $77;
  CodeCount := 0;
  for L := 1 to 16 do
    Inc(CodeCount, Haff[L]);
  SetLength(Codes, CodeCount);
  MakeCodeList(Haff, Codes);
  for L := 0 to CodeCount - 1 do
    AddItem(Codes[L].Code, Vm1[L], Vm2[L], Codes[L].Col);
end;

// #############################################################################
// ## Method: 色差のDC成分テーブルの作成
procedure THuffmanTable.CreateCDC;
begin
  AddItem($0000, 0, 0, 2);
  AddItem($4000, 0, 1, 2);
  AddItem($8000, 0, 2, 2);
  AddItem($C000, 0, 3, 3);
  AddItem($E000, 0, 4, 4);
  AddItem($F000, 0, 5, 5);
  AddItem($F800, 0, 6, 6);
  AddItem($FC00, 0, 7, 7);
  AddItem($FE00, 0, 8, 8);
  AddItem($FF00, 0, 9, 9);
  AddItem($FF80, 0, 10, 10);
  AddItem($FFC0, 0, 11, 11);
end;

// #############################################################################
// ## Method: テーブルの作成
procedure THuffmanTable.CreateTable;
begin
  if FItems = nil then FItems := TList.Create else ClearItems;
  case FTcTh of
    $00: CreateYDC;
    $01: CreateCDC;
    $10: CreateYAC;
    $11: CreateCAC;
  end;
end;

// #############################################################################
// ## Method: 輝度のAC成分テーブルの作成
procedure THuffmanTable.CreateYAC;
const
  Vm1: array[0..161] of Byte =
      ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,15, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7,
        7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9,
        9, 9,10,10,10,10,10,10,10,10,10,10,11,11,11,11,11,11,11,11,
       11,11,12,12,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,13,
       13,13,14,14,14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15,
       15,15);
  Vm2: array[0..161] of Byte =
      ( 1, 2, 3, 0, 4, 5, 6, 7, 8, 9,10, 1, 2, 3, 4, 5, 6, 7, 8, 9,
       10, 1, 2, 3, 4, 5, 6, 7, 8, 9,10, 1, 2, 3, 4, 5, 6, 7, 8, 9,
       10, 1, 2, 3, 4, 5, 6, 7, 8, 9,10, 0, 1, 2, 3, 4, 5, 6, 7, 8,
        9,10, 1, 2, 3, 4, 5, 6, 7, 8, 9,10, 1, 2, 3, 4, 5, 6, 7, 8,
        9,10, 1, 2, 3, 4, 5, 6, 7, 8, 9,10, 1, 2, 3, 4, 5, 6, 7, 8,
        9,10, 1, 2, 3, 4, 5, 6, 7, 8, 9,10, 1, 2, 3, 4, 5, 6, 7, 8,
        9,10, 1, 2, 3, 4, 5, 6, 7, 8, 9,10, 1, 2, 3, 4, 5, 6, 7, 8,
        9,10, 1, 2, 3, 4, 5, 6, 7, 8, 9,10, 1, 2, 3, 4, 5, 6, 7, 8,
        9,10);
var
  CodeCount: Integer;
  Codes: TCodeDatas;
  Haff: THuffmanValues;
  L: Integer;
begin
  Haff[1] := 0;
  Haff[2] := 2;
  Haff[3] := 1;
  Haff[4] := 3;
  Haff[5] := 3;
  Haff[6] := 2;
  Haff[7] := 4;
  Haff[8] := 3;
  Haff[9] := 5;
  Haff[10] := 5;
  Haff[11] := 4;
  Haff[12] := 4;
  Haff[13] := 0;
  Haff[14] := 0;
  Haff[15] := 1;
  Haff[16] := $7D;
  CodeCount := 0;
  for L := 1 to 16 do
    Inc(CodeCount, Haff[L]);
  SetLength(Codes, CodeCount);
  MakeCodeList(Haff, Codes);
  for L := 0 to CodeCount - 1 do
    AddItem(Codes[L].Code, Vm1[L], Vm2[L], Codes[L].Col);
end;

// #############################################################################
// ## Method: 輝度のDC成分テーブルの作成
procedure THuffmanTable.CreateYDC;
begin
  AddItem($0000, 0, 0, 2);
  AddItem($4000, 0, 1, 3);
  AddItem($6000, 0, 2, 3);
  AddItem($8000, 0, 3, 3);
  AddItem($A000, 0, 4, 3);
  AddItem($C000, 0, 5, 3);
  AddItem($E000, 0, 6, 4);
  AddItem($F000, 0, 7, 5);
  AddItem($F800, 0, 8, 6);
  AddItem($FC00, 0, 9, 7);
  AddItem($FE00, 0, 10, 8);
  AddItem($FF00, 0, 11, 9);
end;

// #############################################################################
// ## Method: デコード
function THuffmanTable.Decode(Buffer: TJpegBuffer; out ZeroRun: Integer): Integer;
var
  Bit: Byte;
  pItem: PHuffmanItem;
begin
  pItem := FTop;
  repeat
    Bit := Buffer.ReadBit;
    if Bit <= 1 then pItem := pItem^.pNext[Bit];
  until pItem^.Flag or (Bit > 1);
  if Bit > 1 then Result := Integer(Bit) + $FF00
  else
  begin
    //if pItem^.ZeroRun = 16 then ZeroRun := 15 else ZeroRun := Integer(pItem^.ZeroRun);
    ZeroRun := Integer(pItem^.ZeroRun);
    Result := Buffer.AsSmall(pItem^.Vm);
  end;
end;

// #############################################################################
// ## Method: デストラクタ
destructor THuffmanTable.Destroy;
begin
  ClearItems;
  FItems.Free;
  FCodeItems.Free;
  Dispose(FTop);
  inherited;
end;

// #############################################################################
// ## Method: エンコードしてバッファに保存
procedure THuffmanTable.Encode(Buffer: TJpegBuffer; const ZeroRun, Value: SmallInt);
var
  Enc, Enc2, Len: LongWord;
  Mask: SmallInt;
  pItem: PHuffmanItem;
  VmCount: Integer;
  Zr, V: SmallInt;
begin
  if ZeroRun = 99 then
  begin
    pItem := FCodeItems[FEOBIndex];
    Buffer.WriteBits(pItem^.Code * $10000, pItem^.Level);
  end
  else
  begin
    Zr := ZeroRun;
    pItem := FCodeItems[FZRLIndex];
    while Zr >= 16 do
    begin
      Dec(Zr, 16);
      Buffer.WriteBits(pItem^.Code * $10000, pItem^.Level);
    end;
    // %%%%%%%%%%%%%%%%%%%%%%%%%%%%Valueの最小ビットを取得%%
    case Value of
      -1, 1:
        begin
          VmCount := 1;
          Mask := $0001;
        end;
      -3, -2, 2, 3:
        begin
          VmCount := 2;
          Mask := $0003;
        end;
      -7..-4, 4..7:
        begin
          VmCount := 3;
          Mask := $0007;
        end;
      -15..-8, 8..15:
        begin
          VmCount := 4;
          Mask := $000F;
        end;
      -31..-16, 16..31:
        begin
          VmCount := 5;
          Mask := $001F;
        end;
      -63..-32, 32..63:
        begin
          VmCount := 6;
          Mask := $003F;
        end;
      -127..-64, 64..127:
        begin
          VmCount := 7;
          Mask := $007F;
        end;
      -255..-128, 128..255:
        begin
          VmCount := 8;
          Mask := $00FF;
        end;
      -511..-256, 256..511:
        begin
          VmCount := 9;
          Mask := $01FF;
        end;
      -1023..-512, 512..1023:
        begin
          VmCount := 10;
          Mask := $03FF;
        end;
      -2047..-1024, 1024..2047:
        begin
          VmCount := 11;
          Mask := $07FF;
        end;
      -4095..-2048, 2048..4095:
        begin
          VmCount := 12;
          Mask := $0FFF;
        end;
      -8191..-4096, 4096..8191:
        begin
          VmCount := 13;
          Mask := $1FFF;
        end;
      else
        begin
          VmCount := 0;
          Mask := $0000;
        end;
    end;
    // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ハフマンコードの検索%%
    pItem := FZero[Zr][VmCount];
    if Value < 0 then V := Value - 1 else V := Value;
    Enc := pItem^.Code;
    Len := pItem^.Level + VmCount;
    Enc2 := LongWord(V and Mask) shl (32 - Len) + Enc * $10000;
    Buffer.WriteBits(Enc2, Len);
  end;
end;

// #############################################################################
// ## Method: フィールド長の取得
function THuffmanTable.FieldLength: Integer;
var
  L: Integer;
begin
  Result := 17;
  for L := 0 to FItems.Count - 1 do
    if PHuffmanItem(FItems[L])^.Flag then Inc(Result);
end;

// #############################################################################
// ## Get: Count
function THuffmanTable.GetCount: Integer;
begin
  Result := FCodeItems.Count;
end;

// #############################################################################
// ## Get: Vm
function THuffmanTable.GetVm(Index: Integer): Byte;
var
  P: PHuffmanItem;
begin
  P := FCodeItems[Index];
  case FTcTh of
    $00, $01: Result := P^.Vm;
    else
      case P^.ZeroRun of
        16: Result := $F0;
        99: Result := 0;
        else Result := (P^.ZeroRun and $0F) shl 4 + (P^.Vm and $0F);
      end;
  end;
end;

// #############################################################################
// ## Method: コード表の作成
procedure THuffmanTable.MakeCodeList(Values: THuffmanValues;
  var Codes: TCodeDatas);
var
  Code: Word;
  CodeCount: Integer;
  LLen, LIndex, LCode: Integer;
begin
  LIndex := 0;
  Code := 0;
  for LLen := 1 to 16 do
  begin
    CodeCount := Values[LLen];
    Code := Code * 2;
    for LCode := 1 to CodeCount do
    begin
      Codes[LIndex].Code := Code shl (16 - LLen);
      Codes[LIndex].Col := Byte(LLen);
      Inc(LIndex);
      Inc(Code);
    end;
  end;
end;

// #############################################################################
// ## Method: コード表の保存
procedure THuffmanTable.SaveCodeList(const FileName: string);
var
  L, L2: Integer;
  List: TStringList;
  P: PHuffmanItem;
  S: string;
begin
  List := TStringList.Create;
  try
    for L := 0 to FCodeItems.Count - 1 do
    begin
      P := FCodeItems[L];
      S := '';
      for L2 := 0 to P^.Level - 1 do
        S := S + IntToStr(BitInt[P^.Code and BitRate[16 + L2] <> 0]);
      S := Format('%d:  %s  Z.%d V.%d', [L, S, P^.ZeroRun, P^.Vm]);
      List.Append(S);
    end;
    List.SaveToFile(FileName);
  finally
    List.Free;
  end;
end;

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// $$ { THuffmanTables }                                                      $$
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

// #############################################################################
// ## Method: テーブルの追加
function THuffmanTables.Add(TcTh: Byte): Integer;
begin
  Result := FTables.Add(THuffmanTable.Create(TcTh));
end;

// #############################################################################
// ## Method: オブジェクトのコピー
procedure THuffmanTables.AssignTo(Dest: TPersistent);
var
  L: Integer;
  Table: THuffmanTable;
begin
  if Dest is THuffmanTables then
    with THuffmanTables(Dest) do
    begin
      Clear;
      for L := 0 to Self.FTables.Count - 1 do
      begin
        Table := THuffmanTable.Create(Self.Tables[L].TcTh);
        Self.Tables[L].AssignTo(Table);
        FTables.Add(Table);
      end;
    end
  else
    inherited;
end;

// #############################################################################
// ## Method: テーブルのクリア
procedure THuffmanTables.Clear;
var
  L: Integer;
begin
  for L := 0 to FTables.Count - 1 do
    if Assigned(FTables[L]) then
    begin
      THuffmanTable(FTables[L]).Free;
      FTables[L] := nil;
    end;
  FTables.Clear;
end;

// #############################################################################
// ## Method: コンストラクタ
constructor THuffmanTables.Create(NowCreation: Boolean);
begin
  inherited Create;
  // :::::::::::::::::::::::::::::::::::::::テーブルの作成::
  FTables := TList.Create;
  if NowCreation then
  begin
    FTables.Add(THuffmanTable.Create($00));
    FTables.Add(THuffmanTable.Create($01));
    FTables.Add(THuffmanTable.Create($10));
    FTables.Add(THuffmanTable.Create($11));
  end;
end;

// #############################################################################
// ## Method: デストラクタ
destructor THuffmanTables.Destroy;
begin
  Clear;
  FTables.Free;
  inherited;
end;

// #############################################################################
// ## Method: テーブルの検索
function THuffmanTables.FindTable(ATcTh: Byte): Integer;
var
  L: Integer;
begin
  Result := -1;
  L := 0;
  while (L < FTables.Count) and (Result = -1) do
  begin
    if Assigned(FTables[L]) then
      if THuffmanTable(FTables[L]).TcTh = ATcTh then Result := L;
    Inc(L);
  end;
end;

// #############################################################################
// ## Get: Count
function THuffmanTables.GetCount: Integer;
begin
  Result := FTables.Count;
end;

// #############################################################################
// ## Get: Tables
function THuffmanTables.GetTable(Index: Integer): THuffmanTable;
begin
  Result := THuffmanTable(FTables[Index]);
end;

// #############################################################################
// ## Method: レコード長の取得
function THuffmanTables.RecordLength: Integer;
var
  L: Integer;
begin
  Result := 2;
  for L := 0 to FTables.Count - 1 do
    Inc(Result, THuffmanTable(FTables[L]).FieldLength);
end;

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// $$ { TJpegEx }                                                             $$
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

// #############################################################################
// ## Method: オブジェクトのコピー
procedure TJpegEx.Assign(Source: TPersistent);
var
  Bmp: TBitmap;
  Buf: PChar;
  L: Integer;
  pQuan, pQuanDest: PQuantium;
begin
  if Source is TJpegEx then
    with TJpegEx(Source) do
    begin
      Self.FComment := FComment;
      Self.FCompressionQuality := FCompressionQuality;
      Self.FDensityUnit := FDensityUnit;
      Self.FElem := FElem;
      Self.FGrayScale := FGrayScale;
      if FHuffs = nil then
      begin
        if Assigned(Self.FHuffs) then FreeAndNil(Self.FHuffs);
      end
      else
      begin
        if Self.FHuffs = nil then
          Self.FHuffs := THuffmanTables.Create(False);
        Self.FHuffs.Assign(FHuffs);
      end;
      Self.FHeight := FHeight;
      if Assigned(FImage) then
      begin
        if Self.FImage = nil then Self.FImage := TBitmap.Create;
        Self.FImage.Assign(FImage);
      end
      else
      begin
        if Self.FImage <> nil then FreeAndNil(Self.FImage);
      end;
      if Assigned(FJpegStream) then
      begin
        InitJpegStream;
        Buf := FJpegStream.Memory;
        Self.FJpegStream.WriteBuffer(Buf^, FJpegStream.Size);
      end
      else if Assigned(Self.FJpegStream) then
        FreeAndNil(Self.FJpegStream);
      if Length(FQuanAccurate) > 0 then
      begin
        SetLength(Self.FQuanAccurate, Length(FQuanAccurate));
        for L := 0 to Length(FQuanAccurate) - 1 do
          Self.FQuanAccurate[L] := FQuanAccurate[L];
      end;
      if Assigned(FQuanTable) then
      begin
        if Self.FQuanTable = nil then Self.FQuanTable := TList.Create;
        for L := 0 to FQuanTable.Count - 1 do
        begin
          pQuan := FQuanTable[L];
          New(pQuanDest);
          pQuanDest^ := pQuan^;
          Self.FQuanTable.Add(pQuanDest);
        end;
      end;
      Self.FRestartInterval := FRestartInterval;
      Self.FSampling := FSampling;
      Self.FWidth := FWidth;
      Self.FXDensity := FXDensity;
      Self.FYDensity := FYDensity;
      Self.FGrayImage := FGrayImage;
    end
  else if Source is TJPEGImage then
    with TJPEGImage(Source) do
    begin
      if Assigned(FJpegStream) then FreeJpegStream;
      FreeImageObject;
      InitDIB;
      FImage.Assign(TJPEGImage(Source));
      FImage.PixelFormat := pf24bit;
      FImage.Palette := 0;
      Self.FCompressionQuality := CompressionQuality;
      Self.FGrayScale := Grayscale;
      Self.FHeight := Height;
      Self.FWidth := Width;
      Self.FGrayImage := Self.FGrayScale;
      FreeJpegStream;
    end
  else if Source is TBitmap then
  begin
    FreeImageObject;
    InitDIB;
    FImage.Assign(TBitmap(Source));
    Self.FHeight := TBitmap(Source).Height;
    Self.FWidth := TBitmap(Source).Width;
    FImage.PixelFormat := pf24bit;
    Self.FGrayImage := False;
    FreeJpegStream;
  end
  else if Source is TClipBoard then
  begin
    with TClipBoard(Source) do
      if HasFormat(CF_BITMAP) or HasFormat(CF_METAFILEPICT) or
         HasFormat(CF_PICTURE) then
      begin
        FreeImageObject;
        InitDIB;
        FImage.Assign(TClipBoard(Source));
        FImage.PixelFormat := pf24bit;
        FImage.Palette := 0;
        Self.FHeight := FImage.Height;
        Self.FWidth := FImage.Width;
        Self.FGrayImage := False;
        FreeJpegStream;
      end
  end
  else if Source is TGraphic then
  begin
    try
      Bmp := TBitmap.Create;
      try
        Bmp.Assign(Source);
        FreeImageObject;
        InitDIB;
        FImage.Assign(Bmp);
      finally
        Bmp.Free;
      end;
      FHeight := FImage.Height;
      FWidth := FImage.Width;
      FImage.PixelFormat := pf24bit;
      FGrayImage := False;
      FreeJpegStream;
    except
      inherited;
    end;
  end
  else
    inherited;
end;

// #############################################################################
// ## Method: オブジェクトのコピー
procedure TJpegEx.AssignTo(Dest: TPersistent);
begin
  if Dest is TJpegEx then
    TJpegEx(Dest).Assign(Self)
  else if Dest is TBitmap then
  begin
    if FImage = nil then NeedDIB;
    TBitmap(Dest).Assign(FImage);
  end
  else if Dest is TJPEGImage then
  begin
    if FImage = nil then NeedDIB;
    TJPEGImage(Dest).Assign(FImage);
  end
  else if Dest is TClipBoard then
  begin
    if FImage = nil then NeedDIB;
    TClipBoard(Dest).Assign(FImage);
  end
  else if Dest is TGraphic then
  begin
    if FImage = nil then NeedDIB;
    Dest.Assign(FImage);
  end
  else
    inherited;
end;

// #############################################################################
// ## Method: グレイスケールに変換
procedure TJpegEx.ChangeGrayScale;
var
  Ycc: TYccImages;
  YccSize: Integer;
begin
  if FImage = nil then Exit;
  YccSize := 0;
  Ycc[0] := nil;
  Ycc[1] := nil;
  Ycc[2] := nil;
  try
    YccSize := RGBToYCC(FImage, Ycc);
    FillChar(Ycc[1]^, YccSize, 128);
    FillChar(Ycc[2]^, YccSize, 128);
    YCCToRGB(Ycc, FImage, FWidth);
  finally
    if Assigned(Ycc[0]) then FreeMem(Ycc[0], YccSize);
    if Assigned(Ycc[1]) then FreeMem(Ycc[1], YccSize);
    if Assigned(Ycc[2]) then FreeMem(Ycc[2], YccSize);
  end;
  FGrayImage := True;
end;

// #############################################################################
// ## Method: 量子化テーブルのクリア
procedure TJpegEx.ClearQuanTable;
var
  L: Integer;
  P: PQuantium;
begin
  if FQuanTable = nil then Exit;
  for L := 0 to  FQuanTable.Count - 1 do
  begin
    P := FQuanTable[L];
    Dispose(P);
  end;
  FQuanTable.Clear;
end;

// #############################################################################
// ## Method: コンストラクタ
constructor TJpegEx.Create;
begin
  inherited;
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%初期化%%
  FCompressionQuality := 75;
  FSampling := jsr411;
  FElem[0].HorzRate := 2;
  FElem[0].VertRate := 2;
  FElem[1].HorzRate := 1;
  FElem[1].VertRate := 1;
  FElem[2].HorzRate := 1;
  FElem[2].VertRate := 1;
  InitQuantiumTable;
  FPixelFormat := jf24Bit;
  FRateOld[0] := 4;
  FRateOld[1] := 1;
  FRateOld[2] := 1;
end;

// #############################################################################
// ## Method: ハフマンテーブルの作成
function TJpegEx.CreateHuffmanTables(NowCreation: Boolean): THuffmanTables;
begin
  Result := THuffmanTables.Create(NowCreation);
end;

// #############################################################################
// ## Method: JPEGストリームの作成
procedure TJpegEx.CreateMemoryStream;
begin
  if FJpegStream = nil then FJpegStream := TMemoryStream.Create;
end;

// #############################################################################
// ## Method: カスタムサンプリングレートの設定
function TJpegEx.CustomSampling(Y, Cb, Cr: Integer): Boolean;
var
  V, Rh, Rv, Ch, Cv, Ch2, Cv2: Integer;
begin
  Result := (Y + Cb + Cr <= 10) and (Y > 0) and (Cb >= 0) and (Cr >= 0) and
            (Y >= Cb) and (Y >= Cr);
  if Result then
  begin
    FRateOld[0] := Byte(Y);
    FRateOld[1] := Byte(Cb);
    FRateOld[2] := Byte(Cr);
    // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%最大公約数を求める%%
    // ::::::::::::::::::::::::::::::::::::::::::::::Y::
    V := Y div 2 + 1;
    while Y mod V > 0 do
      Dec(V);
    Rh := Y div V;
    Rv := V;
    if Rh < Rv then
    begin
      Rv := Y div V;
      Rh := V;
    end;
    // ::::::::::::::::::::::::::::::::::::::::::::::Cb::
    V := Cb div 2 + 1;
    if V > 1 then
    begin
      repeat
        while Cb mod V > 0 do
          Dec(V);
        Ch := Cb div V;
        Cv := V;
        if Ch < Cv then
        begin
          Cv := Cb div V;
          Ch := V;
        end;
      until (V <= 1) or ((Ch <= Rh) and (Cv <= Rv));
      Result := (Ch <= Rh) and (Cv <= Rv);
    end
    else
    begin
      Ch := 0;
      Cv := 0;
    end;
    // ::::::::::::::::::::::::::::::::::::::::::::::Cr::
    if Result then
    begin
      V := Cr div 2 + 1;
      if V > 1 then
      begin
        repeat
          while Cr mod V > 0 do
            Dec(V);
          Ch2 := Cr div V;
          Cv2 := V;
          if Ch2 < Cv2 then
          begin
            Cv2 := Cr div V;
            Ch2 := V;
          end;
        until (V <= 1) or ((Ch2 <= Rh) and (Cv2 <= Rv));
        Result := (Ch2 <= Rh) and (Cv2 <= Rv);
      end
      else
      begin
        Ch2 := 0;
        Cv2 := 0;
      end;
      // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%設定%%
      if Result then
      begin
        FElem[0].HorzRate := Rh;
        FElem[0].VertRate := Rv;
        FElem[1].HorzRate := Ch;
        FElem[1].VertRate := Cv;
        FElem[2].HorzRate := Ch2;
        FElem[2].VertRate := Cv2;
        // :::::::::::::::::::::::::::::::プロパティ変更::
        FSampling := jsrCustom;
        if FGrayScale then
        begin
          FElem[0].HorzRate := 1;
          FElem[0].VertRate := 1;
          FElem[1].HorzRate := 0;
          FElem[1].VertRate := 0;
          FElem[2].HorzRate := 0;
          FElem[2].VertRate := 0;
        end;
      end;
    end;
  end;
end;

// #############################################################################
// ## Method: デストラクタ
destructor TJpegEx.Destroy;
begin
  if Assigned(FJpegStream) then FJpegStream.Free;
  if Assigned(FImage) then FImage.Free;
  if Assigned(FHuffs) then FHuffs.Free;
  if Assigned(FQuanTable) then
  begin
    ClearQuanTable;
    FQuanTable.Free;
  end;
  inherited;
end;

// #############################################################################
// ## Method: イメージの描画
procedure TJpegEx.Draw(ACanvas: TCanvas; const Rect: TRect);
var
  Bmp: TBitmap;
  Dest: TYccImages;
  YccSize: Integer;
begin
  if Empty then Exit;
  if FImage = nil then NeedDIB;
  FImage.Transparent := Transparent;
  if not FGrayScale or FGrayImage then
  begin
    if (FWidth = Rect.Right - Rect.Left) and (FHeight = Rect.Bottom - Rect.Top) then
      ACanvas.Draw(Rect.Left, Rect.Top, FImage)
    else
      ACanvas.StretchDraw(Rect, FImage);
  end
  else
  begin
    // :::::::::::::::::::イメージをグレイスケールに変換::
    Dest[0] := nil;
    Dest[1] := nil;
    Dest[2] := nil;
    YccSize := 0;
    try
      YccSize := RGBToYCC(FImage, Dest);
      FillChar(Dest[1]^, YccSize, 128);
      FillChar(Dest[2]^, YccSize, 128);
      Bmp := TBitmap.Create;
      try
        Bmp.PixelFormat := pf24bit;
        Bmp.HandleType := bmDIB;
        YCCToRGB(Dest, Bmp, FWidth);
        if (FWidth = Rect.Right - Rect.Left) and (FHeight = Rect.Bottom - Rect.Top) then
          ACanvas.Draw(Rect.Left, Rect.Top, Bmp)
        else
          ACanvas.StretchDraw(Rect, Bmp);
      finally
        Bmp.Free;
      end;
    finally
      if Assigned(Dest[0]) then FreeMem(Dest[0], YccSize);
      if Assigned(Dest[1]) then FreeMem(Dest[1], YccSize);
      if Assigned(Dest[2]) then FreeMem(Dest[2], YccSize);
    end;
  end;
  FImage.Transparent := False;
end;

// #############################################################################
// ## Method: 内部イメージの破棄
procedure TJpegEx.FreeImageObject;
begin
  if Assigned(FImage) then FreeAndNil(FImage);
  if FJpegStream = nil then
  begin
    FHeight := 0;
    FWidth := 0;
  end
  else
    GetImageSize;
end;

// #############################################################################
// ## Method: JPEGストリームの破棄
procedure TJpegEx.FreeJpegStream;
begin
  if Assigned(FJpegStream) then FreeAndNil(FJpegStream);
  if Assigned(FImage) then
  begin
    FHeight := FImage.Height;
    FWidth := FImage.Width;
  end
  else
  begin
    FHeight := 0;
    FWidth := 0;
  end;
end;

// #############################################################################
// ## Get: Canvas
function TJpegEx.GetCanvas: TCanvas;
begin
  if FImage = nil then Result := nil else Result := FImage.Canvas;
end;

// #############################################################################
// ## Get: Empty
function TJpegEx.GetEmpty: Boolean;
begin
  Result := (FImage = nil) and (FJpegStream = nil);
end;

// #############################################################################
// ## Get: Height
function TJpegEx.GetHeight: Integer;
begin
  if FHeight = 0 then
    if Assigned(FJpegStream) then
      GetImageSize
    else if Assigned(FImage) then
    begin
      FWidth := FImage.Width;
      FHeight := FImage.Height;
    end;
  Result := FHeight;
end;

// #############################################################################
// ## Method: JPEGストリームから画像サイズを取得
procedure TJpegEx.GetImageSize;
var
  Tag, Offset: Word;
begin
  if FJpegStream = nil then Exit;
  FJpegStream.Seek(2, soBeginning);
  repeat
    Tag := ReadWord(FJpegStream);
    Offset := ReadWord(FJpegStream);
    if (Tag <> $FFC0) and (Tag <> $FFC2) then
      FJpegStream.Seek(Offset - 2, soCurrent);
  until (Tag = $FFC0) or (Tag = $FFC2) or (Tag = $FFDA) or (Tag and $FF00 <> $FF00);
  if (Tag = $FFC0) or (Tag = $FFC2) then
  begin
    FJpegStream.Seek(1, soCurrent);
    FHeight := ReadWord(FJpegStream);
    FWidth := ReadWord(FJpegStream);
  end;
end;

// #############################################################################
// ## Get: Width
function TJpegEx.GetWidth: Integer;
begin
  if FWidth = 0 then
    if Assigned(FJpegStream) then
      GetImageSize
    else if Assigned(FImage) then
    begin
      FHeight := FImage.Height;
      FWidth := FImage.Width;
    end;
  Result := FWidth;
end;

// #############################################################################
// ## Method: 内部イメージの初期化
procedure TJpegEx.InitDIB;
begin
  if Assigned(Self.FImage) then Self.FImage.Free;
  Self.FImage := TBitmap.Create;
  Self.FImage.HandleType := bmDIB;
  Self.FImage.PixelFormat := pf24bit;
end;

// #############################################################################
// ## Method: JPEGストリームの初期化
procedure TJpegEx.InitJpegStream;
begin
  if Assigned(FJpegStream) then FreeAndNil(FJpegStream);
  CreateMemoryStream;
end;

// #############################################################################
// ## Method: 量子化テーブルの初期化
procedure TJpegEx.InitQuantiumTable;
var
  K: Integer;
  P1, P2: PQuantium;
  R: Double;
  Z: Integer;
begin
  if FQuanTable = nil then FQuanTable := TList.Create;
  ClearQuanTable;
  New(P1);
  FQuanTable.Add(P1);
  New(P2);
  FQuanTable.Add(P2);
  SetLength(FQuanAccurate, 2);
  FElem[0].Quan := 0;
  FElem[1].Quan := 1;
  FElem[2].Quan := 1;
  FQuanAccurate[0] := 0;  // 8bit精度
  FQuanAccurate[1] := 0;
  // ******************************* Q=50で初期化 **
  // =================================== 輝度 ==
  SetQuanArray(0, [8,6,5,8,12,20,26,31,6,6,7,10,13,29,30,28,7,7,8,12,
                   20,29,35,28,7,9,11,15,26,44,40,31,9,11,19,28,34,55,52,
                   39,12,18,28,32,41,52,57,46,25,32,39,44,52,61,60,51,36,
                   46,48,49,56,50,52,50]);
  // =================================== 色差 ==
  SetQuanArray(1, [8,6,5,8,12,20,26,31,6,6,7,10,13,29,30,28,7,7,8,12,
                   20,29,35,28,7,9,11,15,26,44,40,31,9,11,19,28,34,55,52,
                   39,12,18,28,32,41,52,57,46,25,32,39,44,52,61,60,51,36,
                   46,48,49,56,50,52,50]);
  // ****************** Qに合わせてテーブルを調整 **
  if FCompressionQuality >= 50 then
    R := (100 - FCompressionQuality) / 50
  else
    R := 50 / FCompressionQuality;
  for Z := 0 to 63 do
  begin
    K := Round(P1[Z] * R);
    if K > 255 then
      K := 255
    else if K < 1 then
      K := 1;
    P1[Z] := K;
    K := Round(P2[Z] * R);
    if K > 255 then
      K := 255
    else if K < 1 then
      K := 1;
    P2[Z] := K;
  end;
end;

// #############################################################################
// ## Method: クリップボード形式でのロード
procedure TJpegEx.LoadFromClipboardFormat(AFormat: Word; AData: THandle;
  APalette: HPALETTE);
begin
  if AData = 0 then raise EJpegEx.Create(MSG_E_CLIPBOARDNODATA);
  FreeImageObject;
  FreeJpegStream;
  FImage.LoadFromClipboardFormat(AFormat, AData, APalette);
  FImage.PixelFormat := pf24bit;
  FImage.Palette := 0;
  FHeight := FImage.Height;
  FWidth := FImage.Width;
end;

// #############################################################################
// ## Method: ファイルからロード
procedure TJpegEx.LoadFromFile(const FileName: string);
var
  Stream: TFileStream;
begin
  FreeJpegStream;
  Stream := TFileStream.Create(FileName, fmOpenRead);
  try
    Stream.Seek(0, soBeginning);
    LoadToMemory(Stream, Stream.Size);
  finally
    Stream.Free;
  end;
  FreeImageObject;
end;

// #############################################################################
// ## Method: ストリームからロード
procedure TJpegEx.LoadFromStream(Stream: TStream);
begin
  FreeJpegStream;
  LoadToMemory(Stream, 0);
  FreeImageObject;
end;

// #############################################################################
// ## Method: ストリームからメモリに読み取る
procedure TJpegEx.LoadToMemory(Stream: TStream; Len: Int64);
var
  Buf: Byte;
  BufWord: Word;
  Flag: Boolean;
  StartPos: Int64;
  Tag, Offset: Word;
begin
  InitJpegStream;
  // ::::::::::::::::::::::::::::::::::SOI識別子の確認::
  StartPos := Stream.Position;
  BufWord := ReadWord(Stream);
  if BufWord <> $FFD8 then raise EJpegEx.Create(MSG_E_FAILOPEN);
  if Len = 0 then
  begin
    // :::::::::::::::::::::::::::::::::::::APP0を確認::
    Tag := ReadWord(Stream);
    if (Tag < $FFE0) or (Tag > $FFEF) then raise EJpegEx.Create(MSG_E_FAILOPEN);
    Offset := ReadWord(Stream);
    // ::::::::::::::::::::::::::::SOSセグメントを探す::
    Stream.Seek(StartPos + 2 + 2 + Offset, soBeginning);
    repeat
      Tag := ReadWord(Stream);
      Offset := ReadWord(Stream);
      if Tag <> $FFDA then Stream.Seek(Offset - 2, soCurrent);
    until Tag = $FFDA;
    Stream.Seek(Offset - 2, soCurrent);
    // :::::::::::::::::::::::イメージデータ末尾を探す::
    Flag := False;
    while (Stream.Position < Stream.Size) and not Flag do
    begin
      Stream.ReadBuffer(Buf, 1);
      if Buf = $FF then
      begin
        Stream.ReadBuffer(Buf, 1);
        Flag := Buf = $D9;
        if (Buf > 0) and ((Buf < $D0) or (Buf > $D9)) then
        begin
          Offset := ReadWord(Stream);
          Stream.Seek(Offset, soCurrent);
        end;
      end;
    end;
    Len := Stream.Position - StartPos;
  end
  else
  begin
    Stream.Seek(Len - 4, soCurrent);
    BufWord := ReadWord(Stream);
    if BufWord <> $FFD9 then raise EJpegEx.Create(MSG_E_FAILOPEN);
  end;
  // :::::::::::::::::::::::::::::::::メモリに読み取り::
  Stream.Seek(StartPos, soBeginning);
  FJpegStream.CopyFrom(Stream, Len);
  NeedJpegInfo;
end;

// #############################################################################
// ## Method: JPEGストリームの展開
procedure TJpegEx.NeedDIB;
var
  AllMcuCount, McuMax, McuCount: Integer;
  Ap: Int64;
  Bits: TJpegBuffer;
  ImageRect: TRect;
  isProgressive: Boolean;
  LBlock, BlockCount: Integer;
  LCode: Byte;
  X, Y, Y0, X1, Y1, X2, Y2, Lx2, Ly2: Integer;
  NextInterval, Ival, IvalTemp: Integer;
  Offset: Word;
  OldDc: array[0..2] of SmallInt;  // 前回のDC成分
  Quan: TQuantium;
  RestartCount: Integer;
  Tag, TagOld: Word;
  Ycc: TYccImages;
  YccSize: Integer;
  YWidth, YHeight: Integer;
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // ++ P Proc: 逆DCT変換
  procedure ReverseDCT;
  var
    F: Double;
    Q: TQuantium;
    X, Y, I, J, C1, C2, C3: Integer;
  begin
    Inc(Quan[0], 1024);
    for X := 0 to 7 do
      for Y := 0 to 7 do
      begin
        C2 := Y * 8;
        F := 0;
        for I := 0 to 7 do
        begin
          C1 := X * 8 + I;
          for J := 0 to 7 do
          begin
            C3 := J * 8 + I;
            F := F + CosRate[C1] * CosRate[C2 + J] * Quan[C3] * DCTRate[C3];
          end;
        end;
        Q[C2 + X] := Round(F);
      end;
    Quan := Q;
  end;
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // ++ P Proc: YCCデータの書き込み
  procedure WriteYcc(ACode, ABlock: Integer);
  var
    BlockRect: TRect;
    Buf2: SmallInt;
    Ly, Lx, Bx, By: Integer;
  begin
    BlockRect.Left := X + (ABlock mod Integer(FElem[ACode].HorzRate)) * 8;
    BlockRect.Top := Y + (ABlock div Integer(FElem[ACode].HorzRate)) * 8;
    BlockRect.Right := BlockRect.Left +  8 * FElem[0].HorzRate div
                       FElem[ACode].HorzRate - 1;
    BlockRect.Bottom := BlockRect.Top + 8 * FElem[0].VertRate div
                        FElem[ACode].VertRate - 1;
    for Ly := BlockRect.Top to BlockRect.Bottom do
    begin
      By := (Ly - BlockRect.Top) * Integer(FElem[ACode].VertRate) div
            Integer(FElem[0].VertRate);
      for Lx := BlockRect.Left to BlockRect.Right do
      begin
        Bx := (Lx - BlockRect.Left) * Integer(FElem[ACode].HorzRate) div
              Integer(FElem[0].HorzRate);
        Buf2 := Quan[Bx + By * 8];
        if Buf2 < 0 then Buf2 := 0 else if Buf2 > 255 then Buf2 := 255;
        Ycc[ACode][Ly * YWidth + Lx] := Buf2;
      end;
    end;
  end;
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // ++ P Func: リスタート処理
  function ExecRestart(Mark, BlockNum: Integer): Boolean;
  var
    Bv: Byte;
    L, Lc, Lm: Integer;
  begin
    Result := False;
    if Mark = 0 then
    begin
      // %%%%%%%%%%%%%%%%%%%%%%%%リスタートマーカーを検索%%
      Bv := Bits.ReadBit;
      while ((Bv < $D0) or (Bv > $D7)) and (Bv <> $D9) do
        Bv := Bits.ReadBit;
      if Bv <> $D9 then Mark := $FF00 + Integer(Bv);
      Result := Bv = $D9;
    end
    else
    begin
      // %%%%%%%%%%%%%%%%%%%%%%%%%%残りブロックの書き込み%%
      // ::::::::::::::::::::::::::::::::現在のブロック::
      ReverseDCT;
      WriteYcc(LCode, LBlock);
      // ::::::::::::::::::::::::::::::::::残りブロック::
      FillChar(Quan, 128, 0);
      for L := BlockNum + 1 to BlockCount do
        WriteYcc(LCode, L);
      // ::::::::::::::::::::::::::::残りコードブロック::
      for Lc := LCode + 1 to 2 do
        for L := 0 to BlockCount do
          WriteYcc(Lc, L);
    end;
    // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%リスタート確認%%
    Inc(RestartCount);
    if (Mark - $FFD0 <> NextInterval) and not Result then
    begin
      Lm := Mark;
      repeat
        for Lc := 0 to 2 do
          for L := 0 to BlockCount do
            WriteYcc(Lc, L);
        Inc(Lm);
        Inc(RestartCount);
        if Lm > $FFD7 then Lm := $FFD0;
        Inc(X, 8 * FElem[0].HorzRate);
        if X >= YWidth then
        begin
          X := 0;
          Inc(Y, 8 * FElem[0].VertRate);
        end;
      until Lm - $FFD0 = NextInterval;
    end;
    // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%次のマーカー%%
    NextInterval := (NextInterval + 1) mod 8;
    AllMcuCount := RestartCount * FRestartInterval;
    OldDc[0] := 0;
    OldDc[1] := 0;
    OldDc[2] := 0;
  end;
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
var
  ACTable, DCTable: THuffmanTable;
  Buf: Byte;
  Buffer: Word;
  BufferLen: Integer;
  LoopExit: Boolean;
  Lpi, Lq: Integer;
  MRect: TRect;
  pQuan: PQuantium;                // 量子化テーブル
  Qv: SmallInt;
  Restarted: Boolean;
  SmpRate: array[0..2, 0..1] of Integer;
  V: Integer;
  Zr: Integer;
begin
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%準備%%
  if FJpegStream = nil then raise EJpegEx.Create(MSG_E_EMPTYSTREAM);
  // ::::::::::::::::::::::::::::::::::::::::::::初期化::
  Ycc[0] := nil;
  Ycc[1] := nil;
  Ycc[2] := nil;
  YccSize := 0;
  // ************************ストリームがJPEGであるか**
  FJpegStream.Seek(0, soBeginning);
  Tag := ReadWord(FJpegStream);
  if Tag <> $FFD8 then raise EJpegEx.Create(MSG_E_STREAM);
  Tag := ReadWord(FJpegStream);
  if (Tag < $FFE0) or (Tag = $FFFF) then raise EJpegEx.Create(MSG_E_STREAM);
  // **************************************************
  FWidth := 0;
  FHeight := 0;
  AllMcuCount := 0;
  RestartCount := 0;
  YWidth := 0;
  FRestartInterval := 0;
  isProgressive := False;
  NextInterval := 0;
  McuMax := 0;
  Ival := 0;
  ImageRect := Rect(0, 0, 0, 0);
  for Lq := 0 to 2 do
  begin
    SmpRate[Lq, 0] := Round(10 * FElem[0].HorzRate / FElem[Lq].HorzRate);
    SmpRate[Lq, 1] := Round(10 * FElem[0].VertRate / FElem[Lq].VertRate);
  end;
  X := 0;
  Y := 0;
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%展開%%
  try
    // ::::::::::::::::::::::::::::::::::::::::::前処理::
    Progress(Self, psStarting, FJpegStream.Position * 100 div FJpegStream.Size,
             False, ImageRect, MSG_INITIALIZING);
    InitDIB;
    NeedHuffmanTables(False);
    Bits := TJpegBuffer.Create(Self, 1048576);
    try
      // ::::::::::::::::::::::::::::::::::::展開ループ::
      repeat
        // ****************************セグメント解析**
        repeat
          Progress(Self, psRunning, FJpegStream.Position * 100 div
                   FJpegStream.Size, False, ImageRect, MSG_ANALYZING);
          if Tag = 0 then Tag := ReadWord(FJpegStream);
          Offset := ReadWord(FJpegStream);
          case Tag of
            $FFC0:
              begin
                ReadSOF0;
                ImageRect := Rect(0, 0, FWidth, FHeight);
                YWidth := FWidth div (FElem[0].HorzRate * 8);
                if FWidth mod (FElem[0].HorzRate * 8) > 0 then Inc(YWidth);
                YHeight := FHeight div (FElem[0].VertRate * 8);
                if FHeight mod (FElem[0].VertRate * 8) > 0 then Inc(YHeight);
                YWidth := YWidth * FElem[0].HorzRate * 8;
                YHeight := YHeight * FElem[0].VertRate * 8;
                YccSize := YWidth * YHeight;
                McuMax := YWidth div (FElem[0].HorzRate * 8) *
                          (YHeight div (FElem[0].VertRate * 8));
                GetMem(Ycc[0], YccSize);
                GetMem(Ycc[1], YccSize);
                GetMem(Ycc[2], YccSize);
                FillChar(Ycc[0]^, YccSize, 128);
                FillChar(Ycc[1]^, YccSize, 128);
                FillChar(Ycc[2]^, YccSize, 128);
              end;
            $FFC2:
              begin
                ReadSOF2;
                isProgressive := True;
                Tag := $FFDA;
              end;
            $FFC4: ReadHuffmanTable(FJpegStream);
            $FFDA: ReadSOS;
            $FFDB: ReadQuanTable(FJpegStream);
            $FFDD:
              begin
                FJpegStream.Seek(1, soCurrent);
                FJpegStream.Read(Buf, 1);
                FRestartInterval := Buf;
                Ival := FRestartInterval;
              end;
            $FFE0:
              begin
                Ap := FJpegStream.Position;
                FJpegStream.Seek(7, soCurrent);
                FJpegStream.ReadBuffer(Buf, 1);
                if Buf <= Byte(Ord(High(TDensityUnit))) then
                  FDensityUnit := TDensityUnit(Buf)
                else
                  FDensityUnit := duUndefine;
                FXDensity := ReadWord(FJpegStream);
                FYDensity := ReadWord(FJpegStream);
                FJpegStream.Seek(Ap + Offset - 2, soBeginning);
              end;
            $FFFE: FComment := ReadString(FJpegStream);
            else FJpegStream.Seek(Offset - 2, soCurrent);
          end;
          TagOld := Tag;
          Tag := 0;
        until TagOld = $FFDA;
        // ********************************展開前処理**
        if Ival = 0 then Ival := McuMax;
        OldDc[0] := 0;
        OldDc[1] := 0;
        OldDc[2] := 0;
        McuCount := 0;
        if isProgressive then
        begin
          FJpegStream.Seek(-2, soEnd);
          Tag := $FFD9;
          Continue;
        end;
        Bits.Clear;
        Bits.Buffering;
        Restarted := False;
        LoopExit := False;
        // ************************イメージ展開ループ**
        repeat
          Progress(Self, psRunning, FJpegStream.Position * 100 div
                   FJpegStream.Size, False, ImageRect, MSG_DECODING);
          LCode := 0;
          repeat
            pQuan := FQuanTable[FElem[LCode].Quan];
            BlockCount := FElem[LCode].HorzRate * FElem[LCode].VertRate - 1;
            DCTable := FHuffs.Tables[FElem[LCode].DCTable];
            ACTable := FHuffs.Tables[FElem[LCode].ACTable];
            for LBlock := 0 to BlockCount do
            begin
              FillChar(Quan, 128, 0);
              // ============================DC成分==
              V := DCTable.Decode(Bits, Zr);
              Restarted := (V >= $FFD0) and (V <= $FFD7);
              LoopExit := V > $FF00;
              if LoopExit then
              begin
                if Restarted then ExecRestart(V, LBlock);
                Tag := V;
                Break;
              end;
              OldDc[LCode] := OldDc[LCode] + V;
              Quan[0] := pQuan[0] * OldDc[LCode];
              // ============================AC成分==
              Lpi := 1;
              repeat
                V := ACTable.Decode(Bits, Zr);
                Restarted := (V >= $FFD0) and (V <= $FFD7);
                LoopExit := V > $FF00;
                if LoopExit then
                begin
                  if Restarted then ExecRestart(V, LBlock);
                  Tag := V;
                  Break;
                end;
                Inc(Lpi, Zr);
                if (Zr < 16) and (Lpi < 64) then
                  Quan[ScanNumber[Lpi]] := pQuan[Lpi] * V;
                Inc(Lpi);
              until Lpi > 63;
              // =============================逆DCT==
              if LoopExit then Break;
              ReverseDCT;
              // ===========================YCC配列==
              WriteYcc(LCode, LBlock);
            end;
            Inc(LCode);
          until (LCode >= 3) or LoopExit;
          if Restarted then
          begin
            Restarted := False;
            LoopExit := False;
            McuCount := 0;
          end
          else if not LoopExit then
          begin
            Inc(AllMcuCount);
            Inc(McuCount);
            Inc(X, 8 * FElem[0].HorzRate);
            if X >= YWidth then
            begin
              X := 0;
              Inc(Y, 8 * FElem[0].VertRate);
            end;
            if (Ival <= McuCount) and (FRestartInterval > 0) then
            begin
              LoopExit := ExecRestart(0, 0);
              if LoopExit then Tag := $FFD9;
              McuCount := 0;
            end;
          end;
        until (McuMax <= AllMcuCount) or LoopExit;
        // ********************************************
        if (FJpegStream.Position < FJpegStream.Size) and (Tag <> $FFD9) then
          Tag := ReadWord(FJpegStream)
        else
          Tag := $FFD9;
      until (Ival <= AllMcuCount) or (Tag = $FFD9);
      // ::::::::::::::::::::::::::::::::::::::::::::::::
      // ::::::::::::::::::::::::::::::::::::::YCC->RGB::
      if not isProgressive then YCCToRGB(Ycc, FImage, YWidth);
    finally
      Bits.Free;
      Progress(Self, psEnding, 100, True, ImageRect, '');
    end;
    if Assigned(Ycc[0]) then
    begin
      FreeMem(Ycc[0], YccSize);
      Ycc[0] := nil;
    end;
    if Assigned(Ycc[1]) then
    begin
      FreeMem(Ycc[1], YccSize);
      Ycc[1] := nil;
    end;
    if Assigned(Ycc[2]) then
    begin
      FreeMem(Ycc[2], YccSize);
      Ycc[2] := nil;
    end;
  except
    if Assigned(Ycc[0]) then FreeMem(Ycc[0], YccSize);
    if Assigned(Ycc[1]) then FreeMem(Ycc[1], YccSize);
    if Assigned(Ycc[2]) then FreeMem(Ycc[2], YccSize);
    raise EJpegEx.Create(MSG_E_STREAM);
  end;
  Changed(Self);
end;

// #############################################################################
// ## Method: ハフマンテーブルの取得
procedure TJpegEx.NeedHuffmanTables(NowCreation: Boolean);
var
  L: Integer;
begin
  if FHuffs = nil then FHuffs := CreateHuffmanTables(NowCreation)
  else if not NowCreation then FHuffs.Clear;
  for L := FHuffs.Count - 1 downto 0 do
  begin
    case FHuffs.Tables[L].TcTh of
      $00:  FElem[0].DCTable := L;
      $01:  begin
              FElem[1].DCTable := L;
              FElem[2].DCTable := L;
            end;
      $10:  FElem[0].ACTable := L;
      $11:  begin
              FElem[1].ACTable := L;
              FElem[2].ACTable := L;
            end;
    end;
    //FHuffs.Tables[L].SaveCodeList('d:\Work\' + IntToStr(FHuffs.Tables[L].TcTh) + '.txt');
  end;
end;

// #############################################################################
// ## Method: JPEGヘッダの解析
procedure TJpegEx.NeedJpegInfo;
var
  Ap: Int64;
  Buf: Byte;
  Tag, Offset, TagOld: Word;
begin
  if FJpegStream = nil then raise EJpegEx.Create(MSG_E_EMPTYSTREAM);
  // ::::::::::::::::::::::::::::::::::::::::::::::ストリームがJPEGであるか::
  FJpegStream.Seek(0, soBeginning);
  Tag := ReadWord(FJpegStream);
  if Tag <> $FFD8 then raise EJpegEx.Create(MSG_E_STREAM);
  Tag := ReadWord(FJpegStream);
  if (Tag < $FFE0) or (Tag = $FFFF) then raise EJpegEx.Create(MSG_E_STREAM);
  FWidth := 0;
  FHeight := 0;
  FRestartInterval := 0;
  // ::::::::::::::::::::::::::::::::::::::::::::::::::::::::セグメント解析::
  try
    NeedHuffmanTables(False);
    repeat
      if Tag = 0 then Tag := ReadWord(FJpegStream);
      Offset := ReadWord(FJpegStream);
      case Tag of
        $FFC0: ReadSOF0;
        $FFC2:
          begin
            ReadSOF2;
            Tag := $FFDA;
          end;
        $FFC4: ReadHuffmanTable(FJpegStream);
        $FFDA: ReadSOS;
        $FFDB: ReadQuanTable(FJpegStream);
        $FFDD:
          begin
            FJpegStream.Seek(1, soCurrent);
            FJpegStream.Read(Buf, 1);
            FRestartInterval := Buf;
          end;
        $FFE0:
          begin
            Ap := FJpegStream.Position;
            FJpegStream.Seek(7, soCurrent);
            FJpegStream.ReadBuffer(Buf, 1);
            if Buf <= Byte(Ord(High(TDensityUnit))) then
              FDensityUnit := TDensityUnit(Buf)
            else
              FDensityUnit := duUndefine;
            FXDensity := ReadWord(FJpegStream);
            FYDensity := ReadWord(FJpegStream);
            FJpegStream.Seek(Ap + Offset - 2, soBeginning);
          end;
        $FFFE: FComment := ReadString(FJpegStream);
        else FJpegStream.Seek(Offset - 2, soCurrent);
      end;
      TagOld := Tag;
      Tag := 0;
    until (TagOld = $FFDA) or (TagOld = $FFD9);
  except
    raise EJpegEx.Create(MSG_E_STREAM);
  end;
end;

// #############################################################################
// ## Method: JPEGストリームの作成
procedure TJpegEx.NeedJpegStream;
const
  R: TRect = (Left: 0; Top: 0; Right: 0; Bottom: 0);
var
  L, LCode, LBlock: Integer;
  Lpx, Lpy, Lcx, Lcy: Integer;
  MaxBlock: array[0..2] of Integer;
  Mcu, McuX, McuY, MaxMcu: Integer;
  OldDC: array[0..2] of SmallInt;
  pQuan: PQuantium;
  Quan: TQuantium;
  RstCount, IvalCount: Integer;
  SubX, SubY: Integer;
  Ycc: TYccImages;
  YccSize: Integer;
  YHeight, YWidth: Integer;
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // ++ P Proc: DCT変換
  procedure ConvertDCT;
  var
    F: Double;
    Q: TQuantium;
    X, Y, I, J, C1, C2: Integer;
  begin
    for I := 0 to 7 do
      for J := 0 to 7 do
      begin
        F := 0;
        for X := 0 to 7 do
        begin
          C1 := X * 8 + I;
          for Y := 0 to 7 do
          begin
            C2 := Y * 8;
            F := F + CosRate[C1] * CosRate[C2 + J] * Quan[C2 + X];
          end;
        end;
        C2 := J * 8 + I;
        Q[C2] := Round(F * DCTRate[C2]);
      end;
    Dec(Q[0], 1024);
    Quan := Q;
  end;
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
var
  ACTable, DCTable: THuffmanTable;
  Bits: TJpegBuffer;
  Buf2: SmallInt;
  LScan: Integer;
  Rate: array[0..2, 0..1] of Integer;
  SubDC: SmallInt;
  YIndex: Integer;
  Zr: Integer;
begin
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%準備%%
  if FImage = nil then Exit;
  YccSize := 0;
  Ycc[0] := nil;
  Ycc[1] := nil;
  Ycc[2] := nil;
  Progress(Self, psStarting, 0, False, R, MSG_INITIALIZING);
  InitJpegStream;
  NeedHuffmanTables(True);
  InitQuantiumTable;
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%メイン処理%%
  try
    // :::::::::::::::::::::::::::::::::::::::RGB->YCC変換::
    YccSize := RGBToYCC(FImage, Ycc);
    // :::::::::::::::::::::::::::::::::::::::::ヘッダ保存::
    WriteJpegHeader;
    // ::::::::::::::::::::::::::::::::::::::::::MCUの圧縮::
    // *****************************************圧縮準備**
    Mcu := 0;
    YHeight := FImage.Height;
    YWidth := FImage.Width;
    McuX := (YWidth + 8 * FElem[0].HorzRate - 1) div (8 * FElem[0].HorzRate);
    McuY := (YHeight + 8 * FElem[0].VertRate - 1) div (8 * FElem[0].VertRate);
    YWidth := McuX * 8 * FElem[0].HorzRate;
    for L := 0 to 2 do
    begin
      OldDC[L] := 0;
      MaxBlock[L] := SmallInt(FElem[L].HorzRate) * SmallInt(FElem[L].VertRate);
      Rate[L, 0] := Integer(FElem[0].HorzRate) * 10 div Integer(FElem[L].HorzRate);
      Rate[L, 1] := Integer(FElem[0].VertRate) * 10 div Integer(FElem[L].VertRate);
    end;
    RstCount := 0;
    IvalCount := 0;
    MaxMcu := McuX * McuY;
    Bits := TJpegBuffer.Create(Self, 1048576);
    try
      // *******************************************圧縮**
      repeat
        Progress(Self, psRunning, Mcu * 100 div MaxMcu, False, R, MSG_ENCODING);
        SubX := Mcu mod McuX * 8 * Integer(FElem[0].HorzRate);
        SubY := Mcu div McuX * 8 * Integer(FElem[0].VertRate);
        // ================================MCUブロック==
        for LCode := 0 to 2 do
        begin
          DCTable := FHuffs.Tables[FElem[LCode].DCTable];
          ACTable := FHuffs.Tables[FElem[LCode].ACTable];
          pQuan := FQuanTable[FElem[LCode].Quan];
          // -------------------------------成分抽出--
          for LBlock := 0 to MaxBlock[LCode] - 1 do
          begin
            Lpx := LBlock mod Integer(FElem[LCode].HorzRate) * 8 + SubX;
            Lpy := LBlock div Integer(FElem[LCode].HorzRate) * 8 + SubY;
            for Lcy := 0 to 7 do
              for Lcx := 0 to 7 do
              begin
                YIndex := (Lpy + Lcy * Rate[LCode, 1] div 10) * YWidth + Lpx +
                          Lcx * Rate[LCode, 0] div 10;
                Quan[Lcy * 8 + Lcx] := Ycc[LCode][YIndex];
              end;
            // ............................DCT変換..
            ConvertDCT;
            // ...................ジグザグスキャン..
            Buf2 := (Quan[ScanNumber[0]] + pQuan[0] div 2) div pQuan[0];
            SubDC := Buf2 - OldDC[LCode];
            OldDC[LCode] := Buf2;
            DCTable.Encode(Bits, 0, SubDC);
            Zr := 0;
            for LScan := 1 to 63 do
            begin
              Buf2 := (Quan[ScanNumber[LScan]] + pQuan[LScan] div 2) div
                      pQuan[LScan];
              if Buf2 = 0 then Inc(Zr)
              else
              begin
                ACTable.Encode(Bits, Zr, Buf2);
                Zr := 0;
              end;
            end;
            if Zr > 0 then ACTable.Encode(Bits, 99, 0);
          end;
          // -----------------------------------------
        end;
        // =============================================
        // ====================================次のMCU==
        Inc(Mcu);
        Inc(IvalCount);
        // -------------------リスタートインターバル--
        if (IvalCount = FRestartInterval) and (Mcu < MaxMcu) then
        begin
          // .............................圧縮保存..
          Bits.WriteBitAll;
          WriteWord(FJpegStream, $FFD0 + RstCount);
          IvalCount := 0;
          RstCount := (RstCount + 1) mod 8;
          OldDC[0] := 0;
          OldDC[1] := 0;
          OldDC[2] := 0;
        end;
        // -------------------------------------------
      until Mcu >= MaxMcu;
      // *************************************************
    finally
      Bits.WriteBitAll;
      Bits.Free;
      WriteWord(FJpegStream, $FFD9);
    end;
    // ::::::::::::::::::::::::::::::::::::::EOIの書き込み::
  finally
    if Assigned(Ycc[0]) then FreeMem(Ycc[0], YccSize);
    if Assigned(Ycc[1]) then FreeMem(Ycc[1], YccSize);
    if Assigned(Ycc[2]) then FreeMem(Ycc[2], YccSize);
    Progress(Self, psEnding, 100, False, R, '');
  end;
end;

// #############################################################################
// ## Method: ハフマンテーブルの読み取り
procedure TJpegEx.ReadHuffmanTable(Stream: TStream);
var
  Buf: Byte;
  CodeCount: Integer;
  Codes: TCodeDatas;
  HuffType: Integer;
  Hv: THuffmanValues;
  L: Integer;
  Table: THuffmanTable;
  Zero: Byte;
begin
  Stream.ReadBuffer(Buf, 1);
  repeat
    // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%識別子%%
    HuffType := FHuffs.Add(Buf);
    case Buf of
      $00:  FElem[0].DCTable := HuffType;
      $01:  begin
              FElem[1].DCTable := HuffType;
              FElem[2].DCTable := HuffType;
            end;
      $10:  FElem[0].ACTable := HuffType;
      $11:  begin
              FElem[1].ACTable := HuffType;
              FElem[2].ACTable := HuffType;
            end;
    end;
    Table := FHuffs.Tables[HuffType];
    Table.Clear;
    // %%%%%%%%%%%%%%%%%%%%%%コード長ごとのコード数%%
    CodeCount := 0;
    for L := 1 to 16 do
    begin
      Stream.ReadBuffer(Buf, 1);
      Hv[L] := Buf;
      Inc(CodeCount, Buf);
    end;
    // %%%%%%%%%%%%%%%%%%%%%%%%%%コードリストの作成%%
    SetLength(Codes, CodeCount);
    Table.MakeCodeList(Hv, Codes);
    for L := 0 to CodeCount - 1 do
    begin
      Stream.ReadBuffer(Buf, 1);
      if (Table.TcTh = $00) or (Table.TcTh = $01) then
        Table.AddItem(Codes[L].Code, 0, Buf, Codes[L].Col)
      else
      begin
        Zero := (Buf shr 4) and $0F;
        Table.AddItem(Codes[L].Code, Zero, Buf and $0F, Codes[L].Col);
      end;
    end;
    //Table.SaveCodeList('d:\Work\' + IntToStr(Table.TcTh) + '.txt');
    Stream.ReadBuffer(Buf, 1);
  until Buf = $FF;
  Stream.Seek(-1, soCurrent);
end;

// #############################################################################
// ## Method: 量子化テーブルの読み取り
procedure TJpegEx.ReadQuanTable(Stream: TStream);
var
  BufByte: Byte;
  L: Integer;
  Num: Byte;          // 識別子
  P: PQuantium;
begin
  Stream.ReadBuffer(BufByte, 1);
  repeat
    // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%精度と識別子%%
    Num := BufByte and $0F;
    if Num >= FQuanTable.Count then
    begin
      FQuanTable.Count := Num + 1;
      New(P);
      FQuanTable[Num] := P;
      SetLength(FQuanAccurate, Num + 1);
    end
    else
    begin
      P := FQuanTable[Num];
      if P = nil then
      begin
        New(P);
        FQuanTable[Num] := P;
      end;
    end;
    FQuanAccurate[Num] := (BufByte shr 4) and $01;
    // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%テーブル取得%%
    if FQuanAccurate[Num] = 0 then
      for L := 0 to 63 do
      begin
        Stream.ReadBuffer(BufByte, 1);
        P[L] := BufByte;
      end
    else
      for L := 0 to 63 do
        P[L] := ReadWord(Stream);
    Stream.ReadBuffer(BufByte, 1);
  until BufByte = $FF;
  Stream.Seek(-1, soCurrent);
end;

// #############################################################################
// ## Method: SOF0セグメントの解析
procedure TJpegEx.ReadSOF0;
var
  BufByte: Byte;
  L: Integer;
  Nf, Num: Byte;        // 構成要素数,識別子
  Y, Cb, Cr: Byte;      // サンプリング
begin
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%サンプル精度%%
  FJpegStream.ReadBuffer(BufByte, 1);
  if BufByte <> 8 then raise EJpegEx.Create(MSG_E_CORRESPONDENCE);
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%画像サイズ%%
  FHeight := ReadWord(FJpegStream);
  FWidth := ReadWord(FJpegStream);
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%構成要素数%%
  FJpegStream.ReadBuffer(Nf, 1);
  if Nf = 4 then EJpegEx.Create(MSG_E_CORRESPONDENCE);
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%構成要素%%
  for L := 0 to 2 do
  begin
    FElem[L].HorzRate := 0;
    FElem[L].VertRate := 0;
    FElem[L].Quan := 0;
    FElem[L].DCTable := 0;
    FElem[L].ACTable := 0;
  end;
  for L := 1 to Nf do
  begin
    FJpegStream.ReadBuffer(Num, 1);
    FJpegStream.ReadBuffer(BufByte, 1);
    FElem[Num - 1].HorzRate := (BufByte shr 4) and $0F;
    FElem[Num - 1].VertRate := BufByte and $0F;
    FJpegStream.ReadBuffer(BufByte, 1);
    FElem[Num - 1].Quan := BufByte;
  end;
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%サンプリングの確認%%
  Y := FElem[0].HorzRate * FElem[0].VertRate;
  Cb := FElem[1].HorzRate * FElem[1].VertRate;
  Cr := FElem[2].HorzRate * FElem[2].VertRate;
  if (Cb = Cr) and (4 mod Y = 0) then
  begin
    Cb := 4 div Y * Cb;
    case Cb of
      0: FSampling := jsr444;
      1: FSampling := jsr411;
      2: FSampling := jsr422;
      4: FSampling := jsr444;
      else
        begin
          FSampling := jsrCustom;
          FRateOld[0] := FElem[0].HorzRate * FElem[0].VertRate;
          FRateOld[1] := FElem[1].HorzRate * FElem[1].VertRate;
          FRateOld[2] := FElem[2].HorzRate * FElem[2].VertRate;
        end;
    end;
    FGrayImage := Cb = 0;
  end
  else
  begin
    FSampling := jsrCustom;
    FRateOld[0] := FElem[0].HorzRate * FElem[0].VertRate;
    FRateOld[1] := FElem[1].HorzRate * FElem[1].VertRate;
    FRateOld[2] := FElem[2].HorzRate * FElem[2].VertRate;
  end;
end;

// #############################################################################
// ## Method: SOF2セグメントの解析
procedure TJpegEx.ReadSOF2;
var
  Jpg: TJPEGImage;
begin
  ReadSOF0;
  FJpegStream.Seek(0, soBeginning);
  Jpg := TJPEGImage.Create;
  try
    Jpg.LoadFromStream(FJpegStream);
    FImage.Assign(Jpg);
  finally
    Jpg.Free;
  end;
end;

// #############################################################################
// ## Method: SOSセグメントの解析
procedure TJpegEx.ReadSOS;
var
  Buf: Byte;
  L: Integer;
  Ns, Num, Tb: Byte;    // 構成要素数,識別子
begin
  FJpegStream.ReadBuffer(Ns, 1);
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%構成の読み取り%%
  for L := 1 to Ns do
  begin
    // :::::::::::::::::::::::::::::::::::識別子::
    FJpegStream.ReadBuffer(Num, 1);
    // ::::::::::::::::::::::::::::::::DHT識別子::
    FJpegStream.ReadBuffer(Buf, 1);
    Tb := (Buf and $F0) shr 4;
    FElem[Num - 1].DCTable := FHuffs.FindTable(Tb);
    Tb := (Buf and $0F) + $10;
    FElem[Num - 1].ACTable := FHuffs.FindTable(Tb);
  end;
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%残りデータのシーク%%
  repeat
    FJpegStream.ReadBuffer(Buf, 1);
  until Buf = $3F;
  FJpegStream.Seek(1, soCurrent);
end;

// #############################################################################
// ## Method: RGBをYCCに変換
function TJpegEx.RGBToYCC(Source: TBitmap; var Dest: TYccImages): Integer;
var
  CaSource: array of Pointer;
  Ps: PRGBQuanArray;
  R0, G0, B0: Integer;
  Y, Cr, Cb: Integer;
  Lx, Ly, Z0, Z1: Integer;
  W, H, Bx, By: Integer;
begin
  // ********************************** サイズを合わせる **
  W := Source.Width;
  H := Source.Height;
  Bx := W div (8 * FElem[0].HorzRate);
  By := H div (8 * FElem[0].VertRate);
  if W mod (8 * FElem[0].HorzRate) > 0 then Inc(Bx);
  if H mod (8 * FElem[0].VertRate) > 0 then Inc(By);
  Bx := Bx * 8 * FElem[0].HorzRate;
  By := By * 8 * FElem[0].VertRate;
  Result := Bx * By;
  GetMem(Dest[0], Result);
  GetMem(Dest[1], Result);
  GetMem(Dest[2], Result);
  FillChar(Dest[0]^, Result, 128);
  FillChar(Dest[1]^, Result, 128);
  FillChar(Dest[2]^, Result, 128);
  // **************************スキャンラインのキャッシュ**
  SetLength(CaSource, H);
  for Ly := 0 to H - 1 do
    CaSource[Ly] := Source.ScanLine[Ly];
  // ******************************** ピクセルごとに変換 **
  for Ly := 0 to H - 1 do
  begin
    Ps := CaSource[Ly];
    Z0 := Ly * Bx;
    for Lx := 0 to W - 1 do
    begin
      // ================================= RGBの取得 ==
      B0 := Integer(Ps[Lx].B);
      G0 := Integer(Ps[Lx].G);
      R0 := Integer(Ps[Lx].R);
      // ================================= YCCに変換 ==
      Y := (29900 * R0 + 58700 * G0 + 11400 * B0 + 50000) div 100000;
      Cb := (-16874 * R0 - 33126 * G0 + 50000 * B0 + 50000) div 100000 + 128;
      Cr := (50000 * R0 - 41869 * G0 - 8131 * B0 + 50000) div 100000 + 128;
      Y := Y - (Y * Integer(BitInt[Y < 0])) - ((Y - 255) * Integer(BitInt[Y > 255]));
      Cb := Cb - (Cb * Integer(BitInt[Cb < 0])) -
            ((Cb - 255) * Integer(BitInt[Cb > 255]));
      Cr := Cr - (Cr * Integer(BitInt[Cr < 0])) -
            ((Cr - 255) * Integer(BitInt[Cr > 255]));
      // ============================== 画像にセット ==
      Z1 := Z0 + Lx;
      Dest[0][Z1] := Byte(Y);
      Dest[1][Z1] := Byte(Cb);
      Dest[2][Z1] := Byte(Cr);
    end;
  end;
end;

// #############################################################################
// ## Method: クリップボード形式での保存
procedure TJpegEx.SaveToClipboardFormat(var AFormat: Word; var Data: THandle;
  var APalette: HPALETTE);
begin
  if Empty then raise EJpegEx.Create(MSG_E_EMPTY);
  if FImage = nil then NeedJpegStream;
  FImage.SaveToClipboardFormat(AFormat, Data, APalette);
end;

// #############################################################################
// ## Method: ストリームに保存
procedure TJpegEx.SaveToStream(Stream: TStream);
var
  Buf: PChar;
begin
  if Empty then raise EJpegEx.Create(MSG_E_EMPTY);
  if FJpegStream = nil then NeedJpegStream;
  FJpegStream.Seek(0, soBeginning);
  Buf := FJpegStream.Memory;
  Stream.WriteBuffer(Buf^, FJpegStream.Size);
end;

// #############################################################################
// ## Set: CompressionQuality
procedure TJpegEx.SetCompressionQuality(const Value: TJPEGQualityRange);
begin
  FCompressionQuality := Value;
  InitQuantiumTable;
end;

// #############################################################################
// ## Set: GrayScale
procedure TJpegEx.SetGrayScale(const Value: Boolean);
begin
  FGrayScale := Value;
  SetSampling(FSampling);
end;

// #############################################################################
// ## Set: Height
procedure TJpegEx.SetHeight(Value: Integer);
begin
  if Assigned(FImage) and (Value > 0) then
  begin
    FImage.ReleaseHandle;
    FImage.Height := Value;
    FHeight := Value;
  end
  else
    raise EJpegEx.Create(MSG_E_CANTCHANGESIZE);
end;

// #############################################################################
// ## Method: 量子化テーブルの設定
procedure TJpegEx.SetQuanArray(TableNum: Integer; const V: array of SmallInt);
var
  P: PQuantium;
  X: Integer;
begin
  P := FQuanTable[TableNum];
  for X := 0 to High(V) do
    P[X] := V[ScanNumber[X]];
end;

// #############################################################################
// ## Set: RestartInterval
procedure TJpegEx.SetRestartInterval(const Value: Integer);
begin
  FRestartInterval := Integer(Word(Value));
end;

// #############################################################################
// ## Set: Sampling
procedure TJpegEx.SetSampling(const Value: TJPEGSamplingRate);
begin
  FSampling := Value;
  case Value of
    jsr411:
      begin
        FElem[0].HorzRate := 2;
        FElem[0].VertRate := 2;
        FElem[1].HorzRate := 1;
        FElem[1].VertRate := 1;
        FElem[2].HorzRate := 1;
        FElem[2].VertRate := 1;
      end;
    jsr422:
      begin
        FElem[0].HorzRate := 2;
        FElem[0].VertRate := 1;
        FElem[1].HorzRate := 1;
        FElem[1].VertRate := 1;
        FElem[2].HorzRate := 1;
        FElem[2].VertRate := 1;
      end;
    jsr444:
      begin
        FElem[0].HorzRate := 1;
        FElem[0].VertRate := 1;
        FElem[1].HorzRate := 1;
        FElem[1].VertRate := 1;
        FElem[2].HorzRate := 1;
        FElem[2].VertRate := 1;
      end;
    else
      CustomSampling(FRateOld[0], FRateOld[1], FRateOld[2]);
  end;
  if FGrayScale then
  begin
    FElem[0].HorzRate := 1;
    FElem[0].VertRate := 1;
    FElem[1].HorzRate := 0;
    FElem[1].VertRate := 0;
    FElem[2].HorzRate := 0;
    FElem[2].VertRate := 0;
  end;
end;

// #############################################################################
// ## Set: Width
procedure TJpegEx.SetWidth(Value: Integer);
begin
  if Assigned(FImage) and (Value > 0) then
  begin
    FImage.ReleaseHandle;
    FImage.Width := Value;
    FWidth := Value;
  end
  else
    raise EJpegEx.Create(MSG_E_CANTCHANGESIZE);
end;

// #############################################################################
// ## Method: ストリームにヘッダを書き込む
procedure TJpegEx.WriteJpegHeader;
var
  Buf: Byte;
  Lq, L, Count: Integer;
  P: PQuantium;
  Table: THuffmanTable;
  V: Word;
begin
  // ********************************* SOIマーカー **
  WriteWord(FJpegStream, $FFD8);
  // ************************************ コメント **
  if FComment <> '' then
  begin
    // ================================ マーカー ==
    WriteWord(FJpegStream, $FFFE);
    // ================================== サイズ ==
    V := Length(FComment) + 3;
    WriteWord(FJpegStream, V);
    // ========================== コメント文字列 ==
    WriteString(FJpegStream, FComment);
  end;
  // ****************************** APP0セグメント **
  // ================================== マーカー ==
  WriteWord(FJpegStream, $FFE0);
  // ============================== フィールド長 ==
  WriteWord(FJpegStream, 16);
  // ================================ JFIF識別子 ==
  WriteString(FJpegStream, 'JFIF');
  // ============================ JFIFバージョン ==
  WriteWord(FJpegStream, $0101);
  // ==================================== 解像度 ==
  WriteByte(FJpegStream, Byte(Ord(FDensityUnit)));
  WriteWord(FJpegStream, FXDensity);
  WriteWord(FJpegStream, FYDensity);
  // ========================== サムネイルサイズ ==
  WriteWord(FJpegStream, 0);
  // ****************************** 量子化テーブル **
  // ================================== マーカー ==
  WriteWord(FJpegStream, $FFDB);
  // ================================ テーブル長 ==
  if FGrayScale then
  begin
    V := 3;
    if FQuanAccurate[0] = 0 then Inc(V, 64) else Inc(V, 128);
    Count := 1;
  end
  else
  begin
    V := 2 + FQuanTable.Count;
    Count := Length(FQuanAccurate);
    for L := 0 to Count - 1 do
      if FQuanAccurate[L] = 0 then Inc(V, 64) else Inc(V, 128);
  end;
  WriteWord(FJpegStream, V);
  // ================================== テーブル ==
  for L := 0 to Count - 1 do
  begin
    P := FQuanTable[L];
    WriteByte(FJpegStream, L + FQuanAccurate[L] * $10);
    for Lq := 0 to 63 do
      case FQuanAccurate[L] of
        0: WriteByte(FJpegStream, Byte(P[Lq]));
        else WriteWord(FJpegStream, Word(P[Lq]));
      end;
  end;
  // ********************************SOF0セグメント**
  // ====================================マーカー==
  WriteWord(FJpegStream, $FFC0);
  // ================================フィールド長==
  if FGrayScale then WriteWord(FJpegStream, 11)
                else WriteWord(FJpegStream, 17);
  // ================================サンプル精度==
  WriteByte(FJpegStream, 8);
  // ==============================イメージサイズ==
  WriteWord(FJpegStream, FImage.Height);
  WriteWord(FJpegStream, FImage.Width);
  // ==================================構成要素数==
  if FGrayScale then WriteByte(FJpegStream, 1) else WriteByte(FJpegStream, 3);
  // ========================================構成==
  // -----------------------------------------Y--
  Buf := (FElem[0].HorzRate and $0F) shl 4 + FElem[0].VertRate and $0F;
  WriteByte(FJpegStream, 1);
  WriteByte(FJpegStream, Buf);
  WriteByte(FJpegStream, 0);
  if not FGrayScale then
  begin
    // --------------------------------------Cb--
    WriteByte(FJpegStream, 2);
    Buf := (FElem[1].HorzRate and $0F) shl 4 + FElem[1].VertRate and $0F;
    WriteByte(FJpegStream, Buf);
    WriteByte(FJpegStream, $01);
    // --------------------------------------Cr--
    WriteByte(FJpegStream, 3);
    WriteByte(FJpegStream, Buf);
    WriteByte(FJpegStream, $01);
  end;
  // ********************** ハフマンコードテーブル **
  NeedHuffmanTables(True);
  // ====================================マーカー==
  WriteWord(FJpegStream, $FFC4);
  // ================================フィールド長==
  if FGrayScale then
  begin
    V := 2 + FHuffs.Tables[FHuffs.FindTable($00)].FieldLength +
         FHuffs.Tables[FHuffs.FindTable($10)].FieldLength;
    WriteWord(FJpegStream, V);
  end
  else
    WriteWord(FJpegStream, FHuffs.RecordLength);
  // ============================== 輝度のDC成分 ==
  // ---------------------------------- 識別子 --
  WriteByte(FJpegStream, $00);
  // -------------------- ビットごとのコード数 --
  Table := FHuffs.Tables[FElem[0].DCTable];
  for L := 1 to 16 do
    WriteByte(FJpegStream, Byte(Table.CodeCount(L)));
  // ---------------------------- 付加ビット数 --
  for L := 0 to Table.Count - 1 do
    WriteByte(FJpegStream, Table.Vm[L]);
  if not FGrayScale then
  begin
    // ==============================色差のDC成分==
    // ----------------------------------識別子--
    WriteByte(FJpegStream, $01);
    // --------------------ビットごとのコード数--
    Table := FHuffs.Tables[FElem[1].DCTable];
    for L := 1 to 16 do
      WriteByte(FJpegStream, Byte(Table.CodeCount(L)));
    // ----------------------------付加ビット数--
    for L := 0 to Table.Count - 1 do
      WriteByte(FJpegStream, Table.Vm[L]);
  end;
  // ================================輝度のAC成分==
  // ------------------------------------識別子--
  WriteByte(FJpegStream, $10);
  // ----------------------ビットごとのコード数--
  Table := FHuffs.Tables[FElem[0].ACTable];
  for L := 1 to 16 do
    WriteByte(FJpegStream, Byte(Table.CodeCount(L)));
  // -----------------------ゼロラン+付加ビット--
  for L := 0 to Table.Count - 1 do
    WriteByte(FJpegStream, Table.Vm[L]);
  if not FGrayScale then
  begin
    // ==============================色差のAC成分==
    // ----------------------------------識別子--
    WriteByte(FJpegStream, $11);
    // --------------------ビットごとのコード数--
    Table := FHuffs.Tables[FElem[1].ACTable];
    for L := 1 to 16 do
      WriteByte(FJpegStream, Byte(Table.CodeCount(L)));
    // ---------------------ゼロラン+付加ビット--
    for L := 0 to Table.Count - 1 do
      WriteByte(FJpegStream, Table.Vm[L]);
  end;
  // ************************リスタートインターバル**
  if FRestartInterval > 0 then
  begin
    V := Word(FRestartInterval);
    WriteWord(FJpegStream, $FFDD);
    WriteWord(FJpegStream, 4);
    WriteWord(FJpegStream, V);
  end;
  // *********************************SOSセグメント**
  // ====================================マーカー==
  WriteWord(FJpegStream, $FFDA);
  // =========================ヘッダ長+構成要素数==
  if FGrayScale then
  begin
    WriteWord(FJpegStream, 8);
    WriteByte(FJpegStream, 1);
  end
  else
  begin
    WriteWord(FJpegStream, 12);
    WriteByte(FJpegStream, 3);
  end;
  // ========================================構成==
  // -----------------------------------------Y--
  WriteByte(FJpegStream, 1);
  WriteByte(FJpegStream, 0);
  if not FGrayScale then
  begin
    // --------------------------------------Cb--
    WriteByte(FJpegStream, 2);
    WriteByte(FJpegStream, $11);
    // --------------------------------------Cr--
    WriteByte(FJpegStream, 3);
    WriteByte(FJpegStream, $11);
  end;
  // ==============================スペクトル選択==
  WriteByte(FJpegStream, 0);
  WriteByte(FJpegStream, $3F);
  WriteByte(FJpegStream, 0);
end;

// #############################################################################
// ## Method: YCCをRGBに変換
procedure TJpegEx.YCCToRGB(Source: TYccImages; Dest: TBitmap; W: Integer);
  var
    Lx, Ly, Zy, Z: Integer;
    pDest: PRGBQuanArray;          // 各行へのアクセス
    R, G, B: Integer;
    Y, Cb, Cr: Integer;
begin
  Dest.ReleaseHandle;
  Dest.Width := FWidth;
  Dest.Height := FHeight;
  for Ly := 0 to FHeight - 1 do
  begin
    pDest := Dest.ScanLine[Ly];
    Zy := Ly * W;
    for Lx := 0 to FWidth - 1 do
    begin
      Z := Zy + Lx;
      Y := Source[0][Z];
      Cb := Source[1][Z] - 128;
      Cr := Source[2][Z] - 128;
      R := Round(Y + 1.402 * Cr);
      G := Round(Y - 0.34414 * Cb - 0.71414 * Cr);
      B := Round(Y + 1.772 * Cb);
      R := R - (R * Integer(BitInt[R < 0])) - ((R - 255) * Integer(BitInt[R > 255]));
      G := G - (G * Integer(BitInt[G < 0])) - ((G - 255) * Integer(BitInt[G > 255]));
      B := B - (B * Integer(BitInt[B < 0])) - ((B - 255) * Integer(BitInt[B > 255]));
      pDest[Lx].B := Byte(B);
      pDest[Lx].G := Byte(G);
      pDest[Lx].R := Byte(R);
    end;
  end;
end;

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// $$ { TJpegBuffer }                                                         $$
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

// #############################################################################
// ## Method: SmallIntとして読み取る
function TJpegBuffer.AsSmall(Vm: Byte): SmallInt;
var
  Bit: Byte;
  Minus: Boolean;
  RateIndex, L: Byte;
begin
  if Vm > 0 then
  begin
    Bit := ReadBit;
    Minus := Bit = 0;
    RateIndex := 32 - Vm;
    Result := SmallInt(BitRate[RateIndex]) * Bit;
    for L := 1 to Vm - 1 do
    begin
      Bit := ReadBit;
      Result := Result + SmallInt(BitRate[RateIndex + L]) * Bit;
    end;
    if Minus then Result := Result - SmallInt(BitRate[31 - Vm]) + 1;
  end
  else
    Result := 0;
end;

// #############################################################################
// ## Method: バッファに読み取る
procedure TJpegBuffer.Buffering;
var
  Buf, Buf2, Buf3: Byte;
  LPos, Lb: Integer;
  MemSize: Int64;
  P: PByteArray;
begin
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%データを先頭に詰める%%
  if (FBuffer.Position > 0) and (FBuffer.Position < FBufferSize) then
  begin
    P := FBuffer.Memory;
    for LPos := FBuffer.Position to FBufferSize - 1 do
      P[LPos - FBuffer.Position] := P[LPos];
  end;
  if FBuffer.Position = FBufferSize then FBuffered := False;
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%空き領域にデータを読み込む%%
  if FBuffered then FBuffer.Position := FBufferSize - FBuffer.Position
  else FBuffer.Position := 0;
  LPos := FBuffer.Position;
  MemSize := FStream.Size;
  if (LPos < FBufferSize) and (FStream.Position < MemSize) then
    repeat
      FStream.ReadBuffer(Buf, 1);
      Buf2 := 0;
      if Buf = $FF then
      begin
        if FStream.Position < MemSize then
          FStream.ReadBuffer(Buf2, 1)
        else
          Buf2 := $D9;
        if Buf2 <> 0 then
        begin
          FBuffer.WriteBuffer(Buf2, 1);
          Inc(LPos);
        end;
      end;
      if Buf2 = 0 then
        for Lb := 0 to 7 do
        begin
          Buf3 := BitInt[Buf and BitRate[Lb + 24] <> 0];
          FBuffer.WriteBuffer(Buf3, 1);
          Inc(LPos);
        end;
    until (LPos >= FBufferSize) or (FStream.Position >= MemSize);
  FBuffer.Position := 0;
  FBuffered := True;
end;

// #############################################################################
// ## Method: バッファのクリア
procedure TJpegBuffer.Clear;
begin
  FBuffered := False;
  FBuffer.Position := 0;
end;

// #############################################################################
// ## Method: コンストラクタ
constructor TJpegBuffer.Create(AImage: TJpegEx; ABufferSize: Integer);
begin
  inherited Create;
  FImage := AImage;
  FBufferSize := ABufferSize;
  if FBufferSize < 0 then FBufferSize := 1024;
  if FBufferSize mod 8 > 0 then FBufferSize := (FBufferSize div 8 + 1) * 8;
  FStream := FImage.JpegStream;
  CreateBuffer;
  Clear;
end;

// #############################################################################
// ## Method: バッファメモリの確保
procedure TJpegBuffer.CreateBuffer;
begin
  if FBuffer = nil then FBuffer := TMemoryStream.Create;
  FBuffer.Size := FBufferSize;
end;

// #############################################################################
// ## Method: デストラクタ
destructor TJpegBuffer.Destroy;
begin
  if Assigned(FBuffer) then FreeAndNil(FBuffer);
  inherited;
end;

// #############################################################################
// ## Method: ビットの読み取り
function TJpegBuffer.ReadBit: Byte;
var
  Buf: Byte;
begin
  FBuffer.ReadBuffer(Buf, 1);
  Result := Buf;
  if FBuffer.Position = FBufferSize then Buffering;
end;

// #############################################################################
// ## Method: バッファの全ビットをストリームに書き込む
procedure TJpegBuffer.WriteBitAll;
var
  Buf: Byte;
  LPos, Last, LBit: Integer;
  P: PByteArray;
begin
  LPos := 0;
  Last := (FBuffer.Position + 7) div 8 * 8;
  P := FBuffer.Memory;
  while LPos < Last do
  begin
    Buf := 0;
    for LBit := 24 to 31 do
    begin
      if LPos < FBuffer.Position then
        Inc(Buf, P[LPos] * BitRate[LBit])
      else
        Inc(Buf, BitRate[LBit]);
      Inc(LPos);
    end;
    FStream.WriteBuffer(Buf, 1);
    if Buf = $FF then
    begin
      Buf := 0;
      FStream.WriteBuffer(Buf, 1);
    end;
  end;
  FBuffer.Position := 0;
end;

// #############################################################################
// ## Method: ビットの書き込み
procedure TJpegBuffer.WriteBits(const Value: Cardinal; Count: Integer);
var
  Buf: Byte;
  LBit: Integer;
begin
  if Count > FBufferSize - FBuffer.Position then WriteBuffer;
  for LBit := 0 to Count - 1 do
  begin
    Buf := BitInt[Value and BitRate[LBit] <> 0];
    FBuffer.WriteBuffer(Buf, 1);
  end;
end;


// #############################################################################
// ## Method: バッファをストリームに書き込む
procedure TJpegBuffer.WriteBuffer;
var
  Buf: Byte;
  LPos, LBit, Last: Integer;
  P: PByteArray;
begin
  LPos := 0;
  Last := FBuffer.Position div 8 * 8;
  P := FBuffer.Memory;
  while LPos < Last do
  begin
    Buf := 0;
    for LBit := 24 to 31 do
    begin
      Inc(Buf, P[LPos] * BitRate[LBit]);
      Inc(LPos);
    end;
    FStream.WriteBuffer(Buf, 1);
    if Buf = $FF then
    begin
      Buf := 0;
      FStream.WriteBuffer(Buf, 1);
    end;
  end;
  for LBit := LPos to FBuffer.Position - 1 do
    P[LBit - LPos] := P[LBit];
  FBuffer.Position := FBuffer.Position - Last;
end;

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// $$ 初期化部                                                                $$
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
initialization
  TPicture.RegisterFileFormat('jpg', 'JPEGイメージ', TJpegEx);
  TPicture.RegisterFileFormat('jpeg', 'JPEGイメージ', TJpegEx);
  for LoopX := 0 to 7 do
    for LoopY := 0 to 7 do
      CosRate[LoopX * 8 + LoopY] := Cos(PI * (2 * LoopX + 1) * LoopY / 16);

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// $$ 終了処理部                                                              $$
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
finalization
  TPicture.UnregisterGraphicClass(TJpegEx);

end.
