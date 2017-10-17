// SusiePlugIn export library for Delphi
// Copyright(C)'2000 buin2gou
// 
// このコンポーネントは自由に使用してもらって構いません
// 転載・改変も自由です。市販ソフトに使用してもロイヤリティ
// の請求は絶対にありえません。許可も必要ありません。

unit SPILib;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  // TPictureInfo
  PPictureInfo = ^TPictureInfo;
  TPictureInfo = packed record
    Left:       Longint;
    Top:        Longint;
    Width:      Longint;
    Height:     Longint;
    x_Density:  Word;
    y_Density:  Word;
    colorDepth: Smallint;
    hInfo:      HLOCAL;
  end;

  // TFileInfo
  PFileInfo = ^TFileInfo;
  TFileInfo = record
    Method:    array[0..7] of Char;
    Position:  Longint;
    CompSize:  Longint;
    FileSize:  Longint;
    TimeStamp: Longint;
    Path:      array[0..199] of Char;
    FileName:  array[0..199] of Char;
    CRC:       Longint;
  end;

  PFIleInfoArray=^TFIleInfoArray;
  TFIleInfoArray=array[0..512] of TFileInfo;

  // TProgressCallback(Callback function)
  TProgressCallback = function(nNum, nDenom: Integer; lData: Longint): Integer;stdcall;

    // Plug-inに関する情報を得る
  FGetPluginInfo =function(InfoNo: Integer; Buf: PChar; BufLen: Integer): Integer; stdcall;
    // 展開可能な(対応している)ファイル形式か調べる
  FIsSupported   =function(FileName: PChar; DW: DWORD): Integer; stdcall;
    // 画像ファイルに関する情報を得る
  FGetPictureInfo=function(Buf: PChar; Len: Longint; Flag: Integer;var PictureInfo: TPictureInfo): Integer; stdcall;
    // 画像を展開する
  FGetPicture    =function(Buf: PChar; Len: Longint; Flag: Integer;var HBInfo: HLOCAL; var HBm: HLOCAL;ProgressCallback: TProgressCallback; lData: Longint): Integer; stdcall;
    // プレビュー・カタログ表示用画像縮小展開ルーティン
  FGetPreview    =function(Buf: PChar; Len: Longint; Flag: Integer;var HBInfo: HLOCAL; var HBm: HLOCAL;ProgressCallback: TProgressCallback; lData: Longint): Integer; stdcall;

  //アーカイブ関係

    // アーカイブ内のすべてのファイルの情報を取得する
  FGetArchiveInfo=function(Buf: PChar; Len: Longint; Flag: Integer;var PictureInfoHandle: HLocal): Integer; stdcall;
    // アーカイブ内の指定したファイルの情報を取得する
  FGetFileInfo   =function(Buf: PChar; Len: Longint; FileName: PChar; Flag: Integer;var FileInfo: TFileInfo): Integer; stdcall;
    // アーカイブ内のファイルを取得する
  FGetFile       =function(Src: PChar; Len: Longint; Dest: PChar; Flag: Integer;ProgressCallback: TProgressCallback; lData: Longint): Integer; stdcall;
    // Plug-in設定ダイアログ表示
  FConfigurationDlg=function (Parent: HWND; fnc: Integer): Integer; stdcall;


  //画像プラグイン
  PPicPlug=^TPicPlug;
  TPicPlug=record
      //ＤＬＬのハンドル
      DllHandle :THandle;

      //プラグインデータ
      sPath     :AnsiString;
      sVersion  :AnsiString;
      sFinleInfo:AnsiString;
      sFileExt  :AnsiString;
      sFileType :AnsiString;

      //関数
      GetPluginInfo   :FGetPluginInfo;
      IsSupported     :FIsSupported;
      GetPictureInfo  :FGetPictureInfo;
      GetPicture      :FGetPicture;
      GetPreview      :FGetPreview;
      ConfigurationDlg:FConfigurationDlg;
  end;

  //アーカイブプラグイン
  PArcPlug=^TArcPlug;
  TArcPlug=record
      //ＤＬＬのハンドル
      DllHandle :THandle;

      //プラグインデータ
      sPath     :AnsiString;
      sVersion  :AnsiString;
      sFinleInfo:AnsiString;
      sFileExt  :AnsiString;
      sFileType :AnsiString;

      //関数
      GetPluginInfo :FGetPluginInfo;
      IsSupported   :FIsSupported;
      GetArchiveInfo:FGetArchiveInfo;
      GetFileInfo   :FGetFileInfo;
      GetFile       :FGetFile;
      ConfigurationDlg:FConfigurationDlg;
  end;



type
  TSpiLib32 = class(TComponent)
  private
    { Private 宣言 }

    //プラグインリスト
    PicList:TList;
    ArcList:TList;
    //変数
    ARCfilters:AnsiString;
    PICfilters:AnsiString;

    APIL      :TStrings;
    SPIL      :TStrings;


  protected
    { Protected 宣言 }
  public
    { Public 宣言 }


    //生成・開放
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    //プラグイン読み込み・開放
    procedure LoadPlugIn(Dir: AnsiString);
    procedure LoadPlugInArc(Dir: AnsiString);
    procedure FreePlugIn;

    //画像読み込み関数
    procedure LoadFromStream(Stream:TStream;BMP:TBitmap);
    procedure LoadFromFile(FileName: AnsiString;BMP:TBitmap);
    procedure LoadFromMemory(Buf: PChar; Len: Longint;BMP:TBitmap);

    {
    //アーカイブから画像を読み出し
    procedure LoadFromStreamArcPic(Stream,Stream2:TStream;BMP:TBitmap);
    procedure LoadFromFileArcPic(ARCName,PicName: AnsiString;BMP:TBitmap);
    }
    //アーカイブからファイルをそのままセーブ処理
    procedure SaveToFile(ArcFIleName,FileName: AnsiString);
    procedure SaveToStream(FileName,ArcFileName: AnsiString;Stream:TStream);
    procedure SaveToMemory(Buf: PChar;FIleName,ArcFileName: AnsiString);

    //プラグインのリスト
    procedure ListArc(List:TStrings;bClear:Boolean);
    procedure ListPic(List:TStrings;bClear:Boolean);

    //アーカイブ内ファイルのリスト
    procedure ArcFileList(ArcFileName: AnsiString;List:TStrings);

    //サポートしてるか
    function SupportArcFile(FIleName: AnsiString):Boolean;
    function SupportPicFile(FIleName: AnsiString):Boolean; // by Mine
    function SupportPicFileList: AnsiString;
  published
    { Published 宣言 }
    //プロパティ
    property  AFilter: AnsiString read ARCFilters;
    property  PFilter: AnsiString read PICFilters;
    property  ArcPlugInList:TStrings read APIL;
    property  PicPlugInList:TStrings read SPIL;

  end;

procedure Register;

implementation

const
	SearchAttr = faReadOnly + faSysFile + faArchive;


procedure Register;
begin
  RegisterComponents('buin2gou', [TSpiLib32]);
end;

constructor TSpiLib32.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);

  //リストのクリエイト
  ArcList:=TList.Create;
  PicList:=TList.Create;

  //プラグイン情報
  APIL:=TStringList.Create;
  SPIL:=TStringList.Create;

  APIL.Clear;
  SPIL.Clear;

end;

destructor TSpiLib32.Destroy;
begin

  FreePlugIn;

  //リストの開放
  ArcList.Free;
  PicList.Free;

  //プラグイン情報
  APIL.Free;
  SPIL.Free;

  Inherited;
end;

procedure TSpiLib32.LoadPlugIn(Dir: AnsiString);
var SR  :TSearchRec;
    Re  :Integer;
    s   : AnsiString;
    pPo :Pointer;
    pPic:PPicPlug;
    buf :PChar;
    List:TStringList;
    i   :Integer;
    bOk :Boolean;
begin
 //初期化
 PICfilters:='';
 GetMem(buf,256);

 //指定ディレクトリを検索にセット
 List:=TStringList.Create;
 List.Clear;


 Re:=FindFirst(Dir+'*.SPI', SearchAttr, SR);
 try
   while Re=0 do begin
         //ＤＬＬのフルパスを得る
         s:=Dir + StrPas(SR.FindData.cFileName);

         List.Add(s);
         //次へ
         Re:=FindNext(SR);
   end;
 finally
   FindClose(SR);
 end;


 for i:=0 to List.COunt-1 do begin
   s:=List[i];

   bOK:=True;
   //ＤＬＬの読み込み・取得
   New(pPic);

   pPic.DllHandle:=LoadLibrary(PChar(s));
   If pPic.DllHandle<>0 then begin
     //関数のアドレスを取得
     pPo:=GetProcAddress(pPic.DllHandle,'GetPluginInfo');
     If pPo<>nil then begin
        //アーカイブプラグインか画像プラグインか分ける
        @pPic.GetPluginInfo:=pPo;
        pPic.GetPluginInfo(0,buf,255);
        s:=AnsiString(buf);


        If s='00IN' then begin
           //画像プラグイン取得


           //プラグイン情報の取得
           @pPic.GetPluginInfo:=pPo;

           pPic.GetPluginInfo(0,buf,255);
           pPic.sFinleInfo:=AnsiString(buf);

           pPic.GetPluginInfo(1,buf,255);
           pPic.sVersion:=AnsiString(buf);

           pPic.GetPluginInfo(2,buf,255);
           pPic.sFileExt:=AnsiString(buf);

           pPic.GetPluginInfo(3,buf,255);
           pPic.sFileType:=AnsiString(buf);

           pPic.sPath:=dir;

           //関数の取得
           @pPic.GetPicture      :=GetProcAddress(pPic.DllHandle,'GetPicture');
           @pPic.GetPictureInfo  :=GetProcAddress(pPic.DllHandle,'GetPictureInfo');
           @pPic.GetPreview      :=GetProcAddress(pPic.DllHandle,'GetPreview');
           @pPic.IsSupported     :=GetProcAddress(pPic.DllHandle,'IsSupported');
           @pPic.ConfigurationDlg:=GetProcAddress(pPic.DllHandle,'ConfigurationDlg');

           PicList.Add(pPic);
           PicFIlters:=PicFilters+pPic.sFileExt+';';

         end else begin
           bOK:=False;
         end;
      end else begin
         bOK:=False;
      end;
   end else begin
      bOK:=False;
   end;

   If not bOK then begin
      //ＤＬＬを開放
      FreeLibrary(pPic.DllHandle);
      DisPose(pPic);
   end;
  end;
  List.Free;
  FreeMEM(buf);

  ListPic(SPIL,False);


end;

procedure TSpiLib32.LoadPlugInArc(Dir: AnsiString);
var SR  :TSearchRec;
    Re  :Integer;
    s   : AnsiString;
    pPo :Pointer;
    pArc:PArcPlug;
    buf :PChar;
    List:TStringList;
    i   :Integer;
    bOk :Boolean;
begin
 //初期化
 ARCfilters:='';

 GetMem(buf,256);

 //指定ディレクトリを検索にセット
 List:=TStringList.Create;
 Re:=FindFirst(Dir+'*.SPI', SearchAttr, SR);
 try
   while Re=0 do begin
         //ＤＬＬのフルパスを得る
         s:=Dir + StrPas(SR.FindData.cFileName);

         List.Add(s);
         //次へ
         Re:=FindNext(SR);
   end;
 finally
   FindClose(SR);
 end;

 for i:=0 to List.COunt-1 do begin
   s:=List[i];


   bOK:=True;
   //ＤＬＬの読み込み・取得
   New(pArc);
   pArc.DllHandle:=LoadLibrary(PChar(s));
   If pArc.DllHandle<>0 then begin
     //関数のアドレスを取得
     pPo:=GetProcAddress(pArc.DllHandle,'GetPluginInfo');
     If pPo<>nil then begin
        //アーカイブプラグインか画像プラグインか分ける
        @pArc.GetPluginInfo:=pPo;
        pArc.GetPluginInfo(0,buf,255);
        s:=AnsiString(buf);

        If s='00AM' then begin
           //アーカイブプラグイン取得

           //プラグイン情報の取得
           @pArc.GetPluginInfo:=pPo;

           pArc.GetPluginInfo(0,buf,255);
           pArc.sFinleInfo:=AnsiString(buf);

           pArc.GetPluginInfo(1,buf,255);
           pArc.sVersion:=AnsiString(buf);

           pArc.GetPluginInfo(2,buf,255);
           pArc.sFileExt:=AnsiString(buf);

           pArc.GetPluginInfo(3,buf,255);
           pArc.sFileType:=AnsiString(buf);

           //関数の取得
           @pARC.GetArchiveInfo  :=GetProcAddress(pArc.DllHandle,'GetArchiveInfo');
           @pARC.GetFile         :=GetProcAddress(pArc.DllHandle,'GetFile');
           @pARC.GetFileInfo     :=GetProcAddress(pArc.DllHandle,'GetFileInfo');
           @pARC.IsSupported     :=GetProcAddress(pArc.DllHandle,'IsSupported');
           @pARC.ConfigurationDlg:=GetProcAddress(pArc.DllHandle,'ConfigurationDlg');

           ArcList.Add(pArc);
           ArcFIlters:=ArcFilters+pArc.sFileExt+';';
         end else begin
           bOK:=False;
         end;
      end else begin
         bOK:=False;
      end;
   end else begin
      bOK:=False;
   end;

   If not bOK then begin
      //ＤＬＬを開放
      FreeLibrary(pArc.DllHandle);
      DisPose(pArc);
   end;
  end;
  List.Free;
  FreeMEM(buf);

  //リスト生成
  ListArc(APIL,False);

end;


procedure TSpiLib32.FreePlugIn;
var i,imax:Integer;
    pPic  :PPicPlug;
    pArc  :PArcPlug;
begin

  //画像プラグイン開放
  imax:=PicList.Count;
  If imax>0 then begin
     for i:=0 to imax-1 do begin
         pPic:=PicList.Items[i];
         FreeLibrary(pPic.DLLHandle);
         DisPose(pPic);
     end;
  end;

  //アーカイブプラグイン開放
  imax:=ArcList.Count;
  If imax>0 then begin
     for i:=0 to imax-1 do begin
         pArc:=ArcList.Items[i];
         FreeLibrary(pArc.DLLHandle);
         DisPose(pARC);
     end;
  end;
end;

procedure TSpiLib32.LoadFromStream(Stream:TStream;BMP:TBitmap);
var ms:TMemoryStream;
begin

 //一々メモリストリームを生成
 ms:=TMemoryStream.Create;
 try
  //メモリからロード。
  ms.LoadFromStream(Stream);
  LoadFromMemory(ms.Memory,Stream.Size,BMP);
 finally
  ms.Free;
 end;


end;

procedure TSpiLib32.LoadFromMemory(Buf: PChar; Len: Longint;BMP:TBitmap);
var
    pHBm    :HGLOBAL;
    pHBInfo :HGLOBAL;
    pHBmP   :Pointer;
    pHBInfoP:Pointer;
    pbmi    :^TBitmapInfo;
    pPic    :PPicPlug;
    i       :Integer;
begin



    for i:=0 to PicList.Count-1 do begin
        pPic:=PicList.Items[i];

        //対応画像かチェック
        If pPic.IsSupported(nil,DWORD(buf))<>0 then begin

           pPic.GetPicture(buf,len, $001, pHBInfo, pHBm,nil,0);

           try
               //ビットマップの読み込み
               pHBmP   :=GlobalLock(pHBm);
               pHBInfoP:=GlobalLock(pHBInfo);
               pbmi    :=pHBInfoP;

               //サイズの設定
               Bmp.Width :=pbmi^.bmiHeader.biWidth;
               Bmp.Height:=pbmi^.bmiHeader.biHeight;

               //転送
               SetDiBits(Bmp.Canvas.Handle,Bmp.Handle,0,pbmi^.bmiHeader.biHeight,pHBmP, pbmi^,DIB_RGB_COLORS);
           finally
             GlobalUnlock(pHBm);
             GlobalUnlock(pHBInfo);
             GlobalFree(pHBm);
             GlobalFree(pHBInfo);
           end;
           break;
        end;
    end;
end;


procedure TSpiLib32.LoadFromFile(FileName: AnsiString;BMP:TBitmap);
var Stream:TMemoryStream;
begin

    Stream:=TMemorySTream.Create;
    try
      Stream.LoadFromFile(FileName);
      LoadFromStream(Stream,BMP);
    finally
      Stream.Free;
    end;
end;

procedure TSpiLib32.SaveToFile(ArcFIleName,FileName: AnsiString);
var ms:TMemoryStream;
begin

   ms :=TMemoryStream.Create;
   try
     SaveToStream(FileName,ArcFileName,ms);
     ms.SaveToFile(FileName);
   finally
     ms.Free;
   end;
end;

procedure TSpiLib32.SaveToStream(FileName,ArcFileName: AnsiString;Stream:TStream);
var ms:TMemoryStream;
begin

  ms:=TMemoryStream.Create;
  try
    ms.LoadFromStream(Stream);
    SaveToMemory(ms.Memory,FileName,ArcFileName);
  finally
    ms.Free;
  end;
end;

procedure TSpiLib32.SaveToMemory(Buf: PChar;FIleName,ArcFileName: AnsiString);
var i   :Integer;
    pArc:pArcPlug;
    finf:TFileInfo;
begin

    for i:=0 to ARCList.Count-1 do begin
        pArc:=ArcList.Items[i];

        //対応画像かチェック
        If pArc.IsSupported(nil,DWORD(buf))<>0 then begin

           pArc.GetFileInfo(PChar(FileName),SizeOf(FileName),PChar(ArcFileName),0,finf);

           pArc.GetFile(PChar(FileName),finf.Position,buf,$001,nil,0);

           break;
        end;
    end;
end;

function TSpiLib32.SupportArcFile(FIleName: AnsiString):Boolean;
var i,j :Integer;
    pArc:pArcPlug;
    ms  :TMemoryStream;
begin

  Result:=False;

  ms:=TMemoryStream.Create;
  try
    ms.LoadFromFile(FileName);

    for i:=0 to ARCList.Count-1 do begin
        pArc:=ArcList.Items[i];

        //対応画像かチェック
        j:=pArc.IsSupported(nil,DWORD(MS.Memory));

        If j<>0 then begin
           Result:=True;
           break;
        end;
    end;
  finally
    ms.Free;
  end;
end;

procedure TSpiLib32.ArcFileList(ArcFileName: AnsiString;List:TStrings);
var i,j :Integer;
    pArc:pArcPlug;
    LMem:HLOCAL;
    ms  :TMemoryStream;
    PInf:PFileInfoArray;
    AllCount:Integer;
    TInf:TFileInfo;
begin

  ms:=TMemoryStream.Create;
  try
    ms.LoadFromFile(ArcFileName);

    for i:=0 to ARCList.Count-1 do begin
        pArc:=ArcList.Items[i];
        //対応画像かチェック
        If pArc.IsSupported(nil,DWORD(ms.Memory))<>0 then begin

           pArc.GetArchiveInfo(MS.Memory,MS.Size,0,LMEM);

           //LMEMをロック＆取得
           PInf:=LocalLock(LMEM);
           try
            ALLCount:=LocalSize(LMEM) div SizeOf(TFileInfo);

            for j:=0 to ALLCount do begin
                If PInf^[j].Method[0]=#0 then break;

                TInf:=PInf[j];

                List.Add(TInf.FileName);

            end;
           finally
             LocalUnLock(LMEM);
           end;
           break;
        end;
    end;
  finally
    ms.Free;
  end;
end;



procedure TSpiLib32.ListArc(List:TStrings;bClear:Boolean);
var i   :Integer;
    pArc:PArcPlug;
    buf :PChar;
begin

   //バッファを取得
   GetMem(buf,256);

   //リストのクリア
   If bClear then List.Clear;

   for i:=0 to ARCList.Count-1 do begin
       //アーカイブプラグイン情報を取得
       pArc:=ArcList.Items[i];

       //プラグインデータを読み出す
       pArc.GetPluginInfo(1,buf,255);
       List.Add(buf);
   end;

   //バッファを開放
   FreeMem(buf);

end;

procedure TSpiLib32.ListPic(List:TStrings;bClear:Boolean);
var i   :Integer;
    pPic:PPicPlug;
    buf :PChar;
begin

   //バッファを取得
   GetMem(buf,256);

   //リストのクリア
   If bClear then List.Clear;

   for i:=0 to PicList.Count-1 do begin
       //アーカイブプラグイン情報を取得
       pPic:=PicList.Items[i];

       //プラグインデータを読み出す
       pPic.GetPluginInfo(1,buf,255);
       List.Add(buf);
   end;

   //バッファを開放
   FreeMem(buf);

end;


function TSpiLib32.SupportPicFile(FileName: AnsiString): Boolean;
var i :Integer;
    pPic:PPicPlug;
    ext, s, token: AnsiString;

    function GetToken(const delimiter: AnsiString; var str: AnsiString): AnsiString;
    var
        i: Integer;
    begin
        i := Pos(delimiter, str);
        if i=0 then
        begin
            Result := str;
            str := '';
            Exit;
        end;
        Result := Copy(str, 1, i-1);
        Delete(str,1,i + Length(delimiter) -1);
    end;

begin
    ext := UpperCase(ExtractFileExt(FIleName));
    Result:=False;
    for i:=0 to PicList.Count-1 do
    begin
        pPic:=PicList.Items[i];

        //対応画像かチェック
        s := UpperCase(pPic.sFileExt);
        while True do
        begin
            token := GetToken(';', s);
            if ExtractFileExt(token) = ext then
            begin
                Result := True; Break;
            end;
            if s = '' then Break;

        end;
    end;
end;

function TSpiLib32.SupportPicFileList: AnsiString;
var i :Integer;
    pPic:PPicPlug;
    ext, s, token: AnsiString;

begin
    Result := '';
    for i:=0 to PicList.Count-1 do
    begin
      pPic:=PicList.Items[i];
      s := Trim(UpperCase(pPic.sFileExt));
      Result := Result + s + ';';
    end;
    if Copy(Result,Length(Result),1)=';' then System.Delete(s, Length(s), 1);
end;

end.
