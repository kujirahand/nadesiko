unit GLDStream;

// ******************************************
// *  GLDGraphicStream                      *
// *                                        *
// *      2001.07.04  Copyright by Tarquin  *
// *                                        *
// ******************************************
//
// これは、TBitmap用ストリームアクセスクラスです。
// ※スレッドには非対応です。
//
// (注意)
//
//  TGLDCustomReadStream
//   ・ReadStreamをoverrideすること
//
//  TGLDCustomWriteStream


{$I taki.inc}

interface

uses
 Windows, Classes, SysUtils, Graphics,
 SFunc;

const
 // 解像度の単位
 GLD_US_ASPECT = 0;
 GLD_US_METER  = 1;
 GLD_US_INCH   = 2;

type
 TGLDBmp = Graphics.TBitmap;

 // 汎用リードカスタムクラス
 TGLDCustomReadStream=class(TObject)
  private
   FStartCount:          integer;       // コールバック用データ
   FOldCount:            integer;
   FStdParcent:          integer;
   FMaxParcent:          integer;
   FMaxSize:             integer;
   FCallType:            integer;
   FStartPosition:       integer;
   FOldLineCount:        integer;

   FStreamSize:          integer;       // ストリームの全体のサイズ
   FReadPos:             integer;       // 現在の位置
   FBuf,FReadBuf:        pbyte;         // バッファポインタ
   FBufLength:           integer;       // バッファ内のデータ数
   FFilePosition:        integer;       // 最初に読み込む位置

   FCancelFlag:          boolean;       // キャンセル
   FEOFFlag:             boolean;       // ファイル終端？(TRUE=終端）

   FMacBinaryFlag:       boolean;       // マックバイナリチェックの有無
   FMacBinary:           boolean;       // マックバイナリの有無

   FStream:              TStream;       // 読み込み先

   function  ReadBuf(zure: integer): boolean;
  protected
   procedure ReadSkipByte(n: integer);
   procedure ReadByte(pp: pointer; len: integer);
   function  Read1Byte: Byte;
   function  ReadWord: Word;
   function  ReadMWord: Word;
   function  ReadDWord: DWORD;
   function  ReadMDword: DWORD;

   procedure SetCallBackParam(ctype,msize,par: integer);
   procedure StartCallBack;
   procedure EndCallBack;
   procedure DoCallBack(cnt: integer);
   function  CallBackProc(cnt: integer): boolean; virtual;

   procedure SetLoadStream(stream: TStream; size: integer);
   procedure FlushStream;

   property Position: integer read FReadPos;
   property EOFFlag: boolean read FEOFFlag;
   property CancelFlag: boolean read FCancelFlag;
   property Stream: TStream read FStream;
  public
   destructor  Destroy; override;
   property MacBinary: boolean read FMacBinary write FMacBinary;
   property MacBinaryCheck: boolean read FMacBinaryFlag write FMacBinaryFlag;
 end;

 // 画像フォーマット用リードカスタムクラス
 TGLDCustomGraphicReadStream=class(TGLDCustomReadStream)
  private
   FText:                string;        // テキストデータ
   FImgWidth,FImgHeight: integer;       // イメージの大きさ
   FImgBitCount:         integer;       // イメージのビット数（DIB用に修正済）
   FOrgBitCount:         integer;       // イメージのオリジナルビット数
   FPaletteSize:         integer;       // パレットの色数
   FUnitSpecifier:       integer;
   FWidthSpecific:       integer;
   FHeightSpecific:      integer;

   FImage:               TGLDBmp;       // 新しく入れるイメージクラス
   FColorBufPtr:         PGLDPalRGB;    // カラーテーブル保管用バッファ
   FMes:                 string;        // 表示メッセージ

   function  CreateColorBuf: PGLDPalRGB;
   procedure FreeColorBuf;
  protected
   procedure ReadStream; virtual; abstract;
   procedure CreateDIB; virtual;
   function  CallBackProc(cnt: integer): boolean; override;

   property Image: TGLDBmp read FImage;
   property ColorTBLBuf: PGLDPalRGB read CreateColorBuf;
   property Mes: string read FMes write FMes;
  public
   constructor Create; virtual;
   destructor  Destroy; override;
   procedure LoadFromStream(img: TGLDBmp; stream: TStream; size: integer);

   // 読み込み画像情報
   property Width: integer read FImgWidth write FImgWidth;
   property Height: integer read FImgHeight write FImgHeight;
   property BitCount: integer read FImgBitcount write FImgBitCount;
   property OriginalBitCount: integer read FOrgBitCount write FOrgBitCount;
   property PaletteSize: integer read FPaletteSize write FPaletteSize;
   property UnitSpecifier: integer read FUnitSpecifier write FUnitSpecifier;
   property WidthSpecific: integer read FWidthSpecific write FWidthSpecific;
   property HeightSpecific: integer read FHeightSpecific write FHeightSpecific;

   property TextData: string read FText write FText;
 end;

 // 汎用ライトカスタムクラス
 TGLDCustomWriteStream=class(TObject)
  private
   FStartCount:         integer;       // コールバック用データ
   FOldCount:           integer;
   FStdParcent:         integer;
   FMaxParcent:         integer;
   FMaxSize:            integer;
   FCallType:           integer;
   FStartPosition:      integer;

   FWriteLength:        integer;       // バッファに書き込んだデータ数
   FWriteStreamSize:    integer;       // ストリームに書き込んだデータ数
   FWriteBuf,FBuf:      pbyte;         // バッファポインタ

   FStream:             TStream;       // 書き込み先

   FCancelFlag:         boolean;       // キャンセル
   FMes:                string;        // 表示メッセージ
   procedure WriteBuf;
  protected
   procedure WriteByte(buf: pointer; cnt: integer);
   procedure Write1Byte(i: integer);
   procedure WriteWord(i: integer);
   procedure WriteMWord(i: integer);
   procedure WriteDWord(i: integer);
   procedure WriteMDWord(i: integer);
   procedure FlushStream;

   procedure SetCallBackParam(ctype,msize,par: integer);
   procedure StartCallBack;
   procedure EndCallBack;
   procedure DoCallBack(cnt: integer);
   function  CallBackProc(cnt: integer): boolean; virtual;

   procedure SetWriteStream(stream: TStream);

   property CancelFlag: boolean read FCancelFlag;
   property Stream: TStream read FStream;
  public
   constructor Create; virtual;
   destructor  Destroy; override;
 end;

 // 画像フォーマット用ライトカスタムクラス
 TGLDCustomGraphicWriteStream=class(TGLDCustomWriteStream)
  private
   FImage:              TGLDBmp;       // 保存するイメージ
  protected
   procedure WriteStream; virtual; abstract;
   function  CallBackProc(cnt: integer): boolean; override;

   property Mes: string read FMes write FMes;
   property Image: TGLDBmp read FImage;
  public
   procedure SaveToStream(img: TGLDBmp; stream: TStream);
 end;

function  GLDBitCount(pf: TPixelFormat): integer;
function  GLDPixelFormat(bcnt: integer): TPIxelFormat;

implementation

const
 MaxBufLength         = 65536; // バッファの大きさ


//------- GLDPixelFormat => ビットカウントをTPixelFormatで返す


function GLDPixelFormat(bcnt: integer): TPIxelFormat;
begin
 case bcnt of
   1: result:=pf1bit;
   4: result:=pf4bit;
   8: result:=pf8bit;
  15: result:=pf15bit; 
  16: result:=pf16bit;
  32: result:=pf32bit;
 else
  result:=pf24bit;
 end;
end;


//------- GLDBitCount => TPixelFormatをビットカウントで返す


function GLDBitCount(pf: TPixelFormat): integer;
begin
 case pf of
    pf1bit: result:=1;
    pf4bit: result:=4;
    pf8bit: result:=8;
   pf15bit: result:=15;
   pf16bit: result:=16;
   pf32bit: result:=32;
  pfCustom: result:=15;
 else
  result:=24;
 end;
end;


//***************************************************
//*   TGLDCustomGraphicReadStream                   *
//***************************************************


//------- Create => クラス作成


constructor TGLDCustomGraphicReadStream.Create;
begin
 inherited;
 FMacBinaryFlag:=TRUE;
 FText:='';
end;


//------- Destroy => クラス解放


destructor TGLDCustomGraphicReadStream.Destroy;
begin
 FreeColorBuf;
 inherited Destroy;
end;


//------- CreateDIB => ＤＩＢ作成


procedure TGLDCustomGraphicReadStream.CreateDIB;
var
 i: integer;
 pcor: PDWORD;
 bmp: TBitmap;

begin
 with FImage do
 begin
  Assign(nil);
  Transparent:=FALSE;
  PixelFormat:=GLDPixelFormat(FImgBitCount);
  Width:=FImgWidth; Height:=FImgHeight;
  if FColorBufPtr<>nil then
   Palette:=CreatePaletteHandle(ColorTBLBuf,FPaletteSize);
 end;
end;


//------- CreateColorBuf => カラーテーブル用バッファ作成


function TGLDCustomGraphicReadStream.CreateColorBuf: PGLDPalRGB;
begin
 if FColorBufPtr=nil then GetMem(FColorBufPtr,256*sizeof(TGLDPalRGB));
 result:=FColorBufPtr;
end;


//------- FreeColorBuf => カラーテーブル用バッファ解放


procedure TGLDCustomGraphicReadStream.FreeColorBuf;
begin
 if FColorBufPtr<>nil then
  begin
   FreeMem(FColorBufPtr);
   FColorBufPtr:=nil;
  end;
end;


//------- LoadFromStream => ストリームから読み込み
// (注意) imgのクラスは呼び出し前に作っておくこと！！
//        sizeはリードできる最大バイト数です。
//        連続したファイルなどの特別な場合を除き
//        通常は0（ストリームの最大値になる）でかまいません。


procedure TGLDCustomGraphicReadStream.LoadFromStream(img: TGLDBmp; stream: TStream; size: integer);
var
 ivn: TNotifyEvent;

begin
 // 二重イベント発生を阻止するため
 ivn:=img.OnChange;
 img.OnChange:=nil;
 try
  // データ初期化
  SetLoadStream(stream,size);
  FImage:=img;
  FText:='';
  FPaletteSize:=0;
  FUnitSpecifier:=0;
  FWidthSpecific:=0;
  FHeightSpecific:=0;

  // 読み込みメイン
  ReadStream;
 finally
  // 閉じる
  FlushStream;
  FreeColorBuf;
  // イベントを戻す
  img.OnChange:=ivn;
 end;
end;


//------- CallBackProc => コールバック本体


function TGLDCustomGraphicReadStream.CallBackProc(cnt: integer): boolean;
var
 n: integer;
 md: TProgressStage;
 flg: boolean;

begin
 result:=FALSE;
 if Assigned(FImage.OnProgress) then
  begin
   case cnt of
    0:     md:=psStarting;
    1..99: md:=psRunning;
   else
    begin
     md:=psEnding;
     cnt:=100;
    end;
   end;
   FImage.OnProgress(FImage,md,cnt,FALSE,Rect(0,0,0,0),FMes);
  end;
end;


//***************************************************
//*   TGLDCustomReadStream                          *
//***************************************************


//------- Destroy => クラス解放


destructor TGLDCustomReadStream.Destroy;
begin
 if FReadBuf<>nil then
  begin
   FreeMem(FReadBuf);
   FReadBuf:=nil;
  end;
 inherited Destroy;
end;


//------- SetLoadStream => 読み込み対象のストリーム設定
// (注意)
//        sizeはリードできる最大バイト数です。
//        連続したファイルなどの特別な場合を除き
//        通常は0（ストリームの最大値になる）でかまいません。


procedure TGLDCustomReadStream.SetLoadStream(stream: TStream; size: integer);
begin
 // データ初期化
 FStream:=stream;
 FFilePosition:=stream.Position;
 if size>0 then
  FStreamSize:=size
 else
  FStreamSize:=stream.Size-FFilePosition;
 FReadPos:=0;
 FCancelFlag:=FALSE;
 FEOFFlag:=FALSE;

 // サイズ0なら何もしない
 if FStreamSize<=0 then
  begin
   FEOFFlag:=TRUE;
   Exit;
  end;
 if (stream is TMemoryStream) then
  begin
   FBuf:=(stream as TMemoryStream).Memory;
   Inc(FBuf,FFilePosition);
   FBufLength:=FStreamSize;
  end
 else
  begin
   if FReadBuf=nil then GetMem(FReadBuf,MaxBufLength);
   FBufLength:=0;
   FBuf:=FReadBuf;
  end;

 // マックバイナリチェック
 if FBufLength=0 then ReadBuf(0);
 if FMacBinaryFlag and (FStreamSize>128) then
  begin
   if (PArrayByte(FBuf)^[0]=0) and (PArrayByte(FBuf)^[74]=0) then
    begin
     MacBinary:=TRUE;
     Inc(FBuf,128);
     FReadPos:=128;
    end
   else
    begin
     MacBinary:=FALSE;
     FReadPos:=0;
    end;
  end;
end;


//------- FlushStream => ストリーム終了処理


procedure TGLDCustomReadStream.FlushStream;
begin
 if FReadBuf<>nil then
  begin
   FreeMem(FReadBuf);
   FReadBuf:=nil;
  end;
 // 読んだ分だけ進める
 // ※バッファ貯めとかやっているので正確なリード数じゃないので
 //   このようにしています。
 if FStream<>nil then FStream.Seek(FReadPos+FFilePosition,soFromBeginning);
end;


//------- SetCallBackParam => コールバックモード設定
// ctype=コールバックタイプ(0=ファイル読み込み位置 1=カウント)
// msize=ctype=0の時の最大カウント数
// par=残りの%から割り与える%(0=最大 1-100(%))
// この関数を呼び出すとコールバックカウントはクリアされる

procedure TGLDCustomReadStream.SetCallBackParam(ctype,msize,par: integer);
begin
 // 前データクリア
 Inc(FStartCount,FStdParcent);
 FOldCount:=FStartCount;
 Dec(FMaxParcent,FStdParcent);
 // 新データ設定
 if ctype=0 then
  begin
   FMaxSize:=FStreamSize;
   FStartPosition:=FReadPos;
  end
 else
  FMaxSize:=msize;
 if FMaxSize=0 then FMaxSize:=1;
 FCallType:=ctype;
 if (par=0) or (par>=100) then FStdParcent:=FMaxParcent
 else FStdParcent:=(FMaxParcent*par) div 100;
end;


//------- StartCallBack => スタートコールバック


procedure TGLDCustomReadStream.StartCallBack;
begin
 FStartCount:=0;
 FOldCount:=0;
 FStdParcent:=0;
 FMaxParcent:=99;
 FCancelFlag:=FALSE;

 FCancelFlag:=CallBackProc(0);
end;


//------- EndCallBack => エンドコールバック


procedure TGLDCustomReadStream.EndCallBack;
begin
 FCancelFlag:=CallBackProc(100);
end;


//------- DoCallback => コールバック


procedure TGLDCustomReadStream.DoCallBack(cnt: integer);
var
 i,j,k: integer;

begin
 j:=FStdParcent;
 k:=FMaxSize;
 case FCallType of
  0: // ファイルサイズカウント方式
     begin
      i:=((FReadPos-FStartPosition)*j) div k;
     end;
  1: // 指定カウント方式
     begin
      if cnt>=k then i:=j else i:=(cnt*j) div k;
     end;
 end;
 Inc(i,FStartCount);
 if (i>FOldCount) then
  begin
   FOldCount:=i;
   if FCallType=1 then
    begin
     FOldLineCount:=cnt;
    end;
   FCancelFlag:=CallBackProc(i);
  end;
end;


//------- CallBackProc => コールバック本体


function TGLDCustomReadStream.CallBackProc(cnt: integer): boolean;
begin
 result:=FALSE;
end;


//------- ReadBuf => バッファに読み込む


function TGLDCustomReadStream.ReadBuf(zure: integer): boolean;
var
 i,nn: integer;
 pp: pbyte;

begin
 result:=FALSE;
 // バッファ内に読み込むバイト数計算
 i:=FStreamSize-FReadPos;
 if i>MaxBufLength-zure then
  begin
   i:=MaxBufLength-zure;
   FBufLength:=MaxBufLength;
  end
 else
  FBufLength:=i+zure;
 // ずらす
 pp:=FReadBuf;
 Inc(pp,zure);
 // 読み込み
 FStream.ReadBuffer(pp^,i);
 // バッファポインタ初期化
 FBuf:=FReadBuf;
 result:=TRUE;
end;


//------- ReadSkipByte => 読み飛ばし


procedure TGLDCustomReadStream.ReadSkipByte(n: integer);
begin
 // 読み込める？
 if FEOFFlag or FCancelFlag then Exit;
 if n+FReadPos>FStreamSize then
  begin
   FEOFFlag:=TRUE;
   Exit;
  end;
 // 長さ０ならエラー
 if n=0 then
  begin
   FCancelFlag:=TRUE;
   Exit;
  end;

 if n<=FBufLength then
  // バッファだけで足りる
  begin
   Inc(FBuf,n);
   Inc(FReadPos,n);
   Dec(FBufLength,n);
  end
 else
  // バッファだけで足りない
  begin
   Inc(FReadPos,n);
   Dec(n,FBufLength);
   FBufLength:=0;
   // ファイルの方をとばす
   FStream.Seek(n,soFromCurrent);
  end;
end;


//------- ReadByte => 複数読み込み


procedure TGLDCustomReadStream.ReadByte(pp: pointer; len: integer);
var
 n: integer;

begin
 if FEOFFlag or FCancelFlag then Exit;
 // 長さ０なら中止
 if len<=0 then
  begin
   FCancelFlag:=TRUE;
   Exit;
  end;
 // 長さ分データが無い場合はエラー
 if FStreamSize<FReadPos+len then
  begin
   FEOFFlag:=TRUE;
   Exit;
  end;

 if len<=FBufLength then
  // バッファだけで足りる
  begin
   Move(FBuf^,pp^,len);
   Inc(FBuf,len);
   Inc(FReadPos,len);
   Dec(FBufLength,len);
  end
 else
  // バッファだけで足りない
  begin
   // バッファから残りデータを読み込み
   if FBufLength>0 then
    begin
     Move(FBuf^,pp^,FBufLength);
     Inc(pbyte(pp),FBufLength);
     Dec(len,FBufLength);
     Inc(FReadPos,FBufLength);
     FBufLength:=0;
    end;
   // ストリームから読み出し
   if len>=MaxBufLength then
    begin
     n:=len-MaxBufLength;
     FStream.ReadBuffer(pp^,n);
     Dec(len,n);
     Inc(pbyte(pp),n);
     Inc(FReadPos,n);
    end;
   // 最大バッファ数以下になったらバッファに読み込んでそこからだす
   if len>0 then
    begin
     ReadBuf(0);
     Move(FBuf^,pp^,len);
     Inc(FBuf,len);
     Inc(FReadPos,len);
     Dec(FBufLength,len);
    end;
  end;
end;


//------- Read1Byte => 1バイト読み込み


function TGLDCustomReadStream.Read1Byte: byte;
var
 x: longint;

begin
 result:=0;
 // 読める？
 if FEOFFlag or FCancelFlag then Exit;
 if FReadPos+1>FStreamSize then
  begin
   FEOFFlag:=TRUE;
   Exit;
  end;
 // バッファデータが空き？
 if FBufLength=0 then ReadBuf(0);
 result:=FBuf^;
 Inc(FReadPos);
 Inc(FBuf);
 Dec(FBufLength);
end;


//------- ReadMWord => 2バイト読み込み(モトローラ形式)


function TGLDCustomReadStream.ReadMWord: Word;
var
 x: longint;

begin
 result:=0;
 // 読める？
 if FEOFFlag or FCancelFlag then Exit;
 if FReadPos+2>FStreamSize then
  begin
   FEOFFlag:=TRUE;
   Exit;
  end;
 // バッファデータが足りない？
 x:=FBufLength;
 if x<2 then
  begin
   if x>0 then Move(FBuf^,FReadBuf^,x);
   ReadBuf(x);
  end;
 x:=PWORD(FBuf)^;
 result:=((x and $FF) shl 8) or ((x and $FF00) shr 8);
 Inc(FReadPos,2);
 Inc(FBuf,2);
 Dec(FBufLength,2);
end;


//------- ReadMDWord => 4バイト読み込み(モトローラ形式)


function TGLDCustomReadStream.ReadMDWord: DWORD;
var
 x: longint;

begin
 result:=0;
 // 読める？
 if FEOFFlag or FCancelFlag then Exit;
 if FReadPos+4>FStreamSize then
  begin
   FEOFFlag:=TRUE;
   Exit;
  end;
 // バッファデータが足りない？
 x:=FBufLength;
 if x<4 then
  begin
   if x>0 then Move(FBuf^,FReadBuf^,x);
   ReadBuf(x);
  end;
 x:=PDWORD(FBuf)^;
 result:=((x and $FF000000) shr 24)+((x and $FF0000) shr 8)+
         ((x and $FF00) shl 8)+((x and $FF) shl 24);
 Inc(FReadPos,4);
 Inc(FBuf,4);
 Dec(FBufLength,4);
end;


//------- ReadWord => 2バイト読み込み


function TGLDCustomReadStream.ReadWord: Word;
var
 x: longint;

begin
 result:=0;
 // 読める？
 if FEOFFlag or FCancelFlag then Exit;
 if FReadPos+2>FStreamSize then
  begin
   FEOFFlag:=TRUE;
   Exit;
  end;
 // バッファデータが足りない？
 x:=FBufLength;
 if x<2 then
  begin
   if x>0 then Move(FBuf^,FReadBuf^,x);
   ReadBuf(x);
  end;
 result:=PWORD(FBuf)^;
 Inc(FReadPos,2);
 Inc(FBuf,2);
 Dec(FBufLength,2);
end;


//------- ReadDword => 4バイト読み込み


function TGLDCustomReadStream.ReadDWord: DWORD;
var
 x: longint;

begin
 result:=0;
 // 読める？
 if FEOFFlag or FCancelFlag then Exit;
 if FReadPos+4>FStreamSize then
  begin
   FEOFFlag:=TRUE;
   Exit;
  end;
 // バッファデータが足りない？
 x:=FBufLength;
 if x<4 then
  begin
   if x>0 then Move(FBuf^,FReadBuf^,x);
   ReadBuf(x);
  end;
 result:=PDWORD(FBuf)^;
 Inc(FReadPos,4);
 Inc(FBuf,4);
 Dec(FBufLength,4);
end;


//***************************************************
//*   TGLDCustomGraphicWriteStream                  *
//***************************************************


//------- CallBackProc => コールバック本体


function TGLDCustomGraphicWriteStream.CallBackProc(cnt: integer): boolean;
var
 n: integer;
 md: TProgressStage;
 flg: boolean;

begin
 result:=FALSE;
 if Assigned(FImage.OnProgress) then
  begin
   case cnt of
    0:     md:=psStarting;
    1..99: md:=psRunning;
   else
    begin
     md:=psEnding;
     cnt:=100;
    end;
   end;
   FImage.OnProgress(FImage,md,cnt,FALSE,Rect(0,0,0,0),FMes);
  end;
end;


//------- SaveToStream => ストリームに書き込み


procedure TGLDCustomGraphicWriteStream.SaveToStream(img: TGLDBmp; stream: TStream);
begin
 // チェック
 SetWriteStream(stream);
 FImage:=img;
 // 書き込み
 WriteStream;
 // 閉じる
 FlushStream;
end;


//***************************************************
//*   TGLDCustomWriteStream                         *
//***************************************************


//------- Create => クラス作成


constructor TGLDCustomWriteStream.Create;
begin
 inherited Create;
 GetMem(FWriteBuf,MaxBufLength);
end;


//------- Destroy => クラス解放


destructor TGLDCustomWriteStream.Destroy;
begin
 if FWriteBuf<>nil then FreeMem(FWriteBuf);
 inherited Destroy;
end;


//------- SetWriteStream => ストリームに書き込み


procedure TGLDCustomWriteStream.SetWriteStream(stream: TStream);
begin
 // チェック
 FStream:=stream;
 FBuf:=FWriteBuf;
 FWriteStreamSize:=0;
 FWriteLength:=0;
end;


//------- SetCallBackParam => コールバックモード設定


procedure TGLDCustomWriteStream.SetCallBackParam(ctype,msize,par: integer);
begin
 // 前データクリア
 Inc(FStartCount,FStdParcent);
 FOldCount:=FStartCount;
 Dec(FMaxParcent,FStdParcent);
 // 新データ設定
 FMaxSize:=msize;
 if FMaxSize=0 then FMaxSize:=1;
 FCallType:=1;  // Writeでは0はなし！
 if (par=0) or (par>=100) then FStdParcent:=FMaxParcent
 else FStdParcent:=(FMaxParcent*par) div 100;
end;


//------- StartCallBack => スタートコールバック


procedure TGLDCustomWriteStream.StartCallBack;
var
 rec: TRECT;

begin
 FStartCount:=0;
 FOldCount:=0;
 FStdParcent:=0;
 FMaxParcent:=99;
 FCancelFlag:=FALSE;

 FCancelFlag:=CallBackProc(0);
end;


//------- EndCallBack => エンドコールバック


procedure TGLDCustomWriteStream.EndCallBack;
var
 rec: TRECT;

begin
 FCancelFlag:=CallBackProc(100);
end;


//------- DoCallback => コールバック


procedure TGLDCustomWriteStream.DoCallBack(cnt: integer);
var
 i,j,k: integer;
 rec: TRECT;

begin
 j:=FStdParcent;
 k:=FMaxSize;
 case FCallType of
  0: // ファイルサイズカウント
     // このタイプはWriteでは指定禁止
     begin
      //i:=((FStream.Position-FStartPosition)*j) div k;
     end;
  1: // Ｙライン
     begin
      i:=(cnt*j) div k;
     end;
 end;
 Inc(i,FStartCount);
 if (i>FOldCount) then
  begin
   FOldCount:=i;
   FCancelFlag:=CallBackProc(i);
  end;
end;


//------- CallBackProc => コールバック本体


function TGLDCustomWriteStream.CallBackProc(cnt: integer): boolean;
begin
 result:=FALSE;
end;


//------- FlushStream => ストリーム終了処理


procedure TGLDCustomWriteStream.FlushStream;
begin
 if FWriteLength>0 then WriteBuf;
end;


//------- WriteBuf => バッファ書き出し


procedure TGLDCustomWriteStream.WriteBuf;
begin
 if FWriteLength=0 then Exit;
 FStream.WriteBuffer(FWriteBuf^,FWriteLength);
 Inc(FWriteStreamSize,FWriteLength);
 FWriteLength:=0;
 FBuf:=FWriteBuf;
end;


//------- WriteByte => バイト単位書き込み


procedure TGLDCustomWriteStream.WriteByte(buf: pointer; cnt: integer);
begin
 if FCancelFlag then Exit;
 if cnt=0 then
  begin
   FCancelFlag:=TRUE;
   Exit;
  end;

 // バッファより大きいデータの場合は直に書込む
 if (cnt>=(MaxBufLength-16)) then
  begin
   // 今バッファにあるデータを吐き出す
   WriteBuf;
   // 直書込み
   FStream.WriteBuffer(buf^,cnt);
   Inc(FWriteStreamSize,cnt);
  end
 else
  begin
   // バッファの空きが足りない
   if FWriteLength+cnt>=MaxBufLength then WriteBuf;
   // バッファにいれる
   Move(buf^,FBuf^,cnt);
   Inc(FWriteLength,cnt);
   Inc(FBuf,cnt);
  end;
end;


//------- Wrute1Byte => 1バイト書き込み


procedure TGLDCustomWriteStream.Write1Byte(i: integer);
begin
 if FCancelFlag then Exit;
 // バッファの空きが足りない
 if FWriteLength+1>=MaxBufLength then WriteBuf;
 // バッファにいれる
 FBuf^:=i;
 Inc(FWriteLength);
 Inc(FBuf);
end;


//-------- WriteWord => ２バイト書き込み


procedure TGLDCustomWriteStream.WriteWord(i: integer);
begin
 if FCancelFlag then Exit;
 // バッファの空きが足りない
 if FWriteLength+2>=MaxBufLength then WriteBuf;
 // バッファにいれる
 PWORD(FBuf)^:=i;
 Inc(FWriteLength,2);
 Inc(FBuf,2);
end;


//------- WriteMWord => ２バイト書き込み(モトローラ）


procedure TGLDCustomWriteStream.WriteMWord(i: integer);
begin
 if FCancelFlag then Exit;
 // バッファの空きが足りない
 if FWriteLength+2>=MaxBufLength then WriteBuf;
 // バッファにいれる
 PWORD(FBuf)^:=((i and $FF) shl 8) or ((i and $FF00) shr 8);
 Inc(FWriteLength,2);
 Inc(FBuf,2);
end;


//------- WriteDWord => ４バイト書き込み


procedure TGLDCustomWriteStream.WriteDWord(i: integer);
begin
 if FCancelFlag then Exit;
 // バッファの空きが足りない
 if FWriteLength+4>=MaxBufLength then WriteBuf;
 // バッファにいれる
 PDWORD(FBuf)^:=i;
 Inc(FWriteLength,4);
 Inc(FBuf,4);
end;


//------- WriteMDWord => ４バイト書き込み(モトローラ）


procedure TGLDCustomWriteStream.WriteMDWord(i: integer);
begin
 if FCancelFlag then Exit;
 // バッファの空きが足りない
 if FWriteLength+4>=MaxBufLength then WriteBuf;
 // バッファにいれる
 PDWORD(FBuf)^:=((i and $FF) shl 24) or ((i and $FF00) shl 8) or
                ((i and $FF0000) shr 8) or ((i and $FF000000) shr 24);
 Inc(FWriteLength,4);
 Inc(FBuf,4);
end;

end.
