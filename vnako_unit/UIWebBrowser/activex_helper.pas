{

1999年2月28日
1999.28.Feb
1999年12月1日
2001年4月３日
2001年７月１日
activeXのためのライブラリ

}
//@version 1.5
//widestringで受渡するとstring変数との関係でEUC文字列などが化ける。
//function  IStreamToString(pStream : IStream ) : String;
//返値をwidestringからstringに変更

//function  StringToIstream(Strings : String) : IStream;
//引数をwidestringからstringに変更

//@author 由木尾　晃

unit ActiveX_Helper;
{$WARN SYMBOL_PLATFORM OFF}
interface

uses
  Windows, Messages, SysUtils, Classes, Controls,Dialogs,
  activeX, OleCtrls,axctrls, StdCtrls,Comobj ,Registry;

   const UnitVersion = 1.5;
Type
  //イベントシンクを作るためのディスパッチルーチン
  //T_ConnectPointのexampleを参照
//@see T_ConnectPoint
//@see TEvent_Sink
 T_DispatchEvent =procedure(Disp_ID: Integer; var Params) of object;

 //接続ポイントオブジェクト
 //activeXのコンテナのイベントをイベントシンクに渡す

 {example:
activeXのイベントを拾う
　activeXのタイプライブラリのディスパッチテーブルからIDを調べる。
　それに基づいていベントシンクを作成する。
　イベントシンクはTEvent_SinkにT_DispatchEvent型のプロシージャを渡して作成する。
  例えば
      // arg：引数のリスト
//      Arg:=TDispParams(Params);
      //イベントの種類は、DispIDで指定。

procedure TDom_Event.DocumentEvent_sink(Disp_ID: Integer; var Params);
begin
　　　　case Disp_Id  of
　　　　　 -600      :  DocClick ;
　　　　　　-601      :  DocDblclick ;
　　　　　　-607:  DocMouseUp ;
　　　　end; //case Disp
end;

というT_DispatchEvent型のプロシージャを作成し

     DocumentEventSink := TEvent_Sink.Create(DocumentEvent_sink );
とすればイベントシンクができる。
このイベントシンクとactiveXの接続ポイントをつなげることによってactiveXのイベントを拾うことができる。

以下は、イベントシンクを接続ポイントに接続する例

       DocumenteventConnect :=  T_ConnectPoint.create(
                    GUID_DocumentEvent,DocumentEventsink as IUnKnown,doc);

必要がなくなった場合には、T_ConnectPointをfreeすれば、TEvent_Sinkも開放される。
 }

//@see TEvent_Sink

 T_ConnectPoint = class
 protected
  pCPC       : IConnectionPointContainer;
  m_pCP      : IConnectionPoint;
  Fdw        : integer;
  EGUID :TGUID;
   m_i:IUnKnown ;
 public
 //接続ポイントオブジェクトを作成する。
 //@param EventGUID イベントのguidタイプライブラリを参照のこと
 //@param m_pIe　イベントシンクを結びつけるインスタンス。
 //詳しくは T_ConnectPoint のexampleを参照のこと
  constructor create(EventGUID : TGUID;Sink,m_pIe:IUnKnown);
  destructor  destroy; override;
 end;

//イベントシンクオブジェクト
  //T_ConnectPoint のexampleを参照
//@see T_ConnectPoint
TEvent_Sink = class(TInterfacedObject,Idispatch)
 protected
    Fsink : T_DispatchEvent;
       Arg:TDispParams;
  public
    invokeResult : pointer;
    function GetTypeInfoCount(out Count: Integer): HRESULT; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HRESULT; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount,
       LocaleID: Integer; DisplDs: Pointer): HRESULT; stdcall;

    function Invoke(Disp_ID: Integer; const IID: TGUID; LocaleID: Integer;
                                    Flags: Word; var Params; VarResult,
                       ExcepInfo, ArgErr: Pointer): HRESULT; stdcall;

//  //T_ConnectPoint のexampleを参照
//@see T_ConnectPoint

    constructor Create(Devent:T_DispatchEvent);
    //destructor  Destroy; override;
 published
end;


 T_NotifyProcedure = procedure of object;
//引数をとらない場合の簡略なイベント動作の定義

 TDispatchEquipInvoke = class (TInterfacedObject,Idispatch)
  protected
  FNotifyProcedure :T_NotifyProcedure ;
  public
    function GetTypeInfoCount(out Count: Integer): HRESULT; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HRESULT; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount,
       LocaleID: Integer; DisplDs: Pointer): HRESULT; stdcall;

    function Invoke(Disp_ID: Integer; const IID: TGUID; LocaleID: Integer;
                                    Flags: Word; var Params; VarResult,
                       ExcepInfo, ArgErr: Pointer): HRESULT; stdcall;

    constructor Create(NotifyProcedure : T_NotifyProcedure);

 published
end;

//com　activeXの登録
//@see getOCXName
//@see UnregistOcx
function registOcx( ocxName : string) : boolean;

//com activeXの登録削除
//@see getOCXName
//@see registOcx
function UnregistOcx( OcxName : string) : boolean;

//GUIDからocxの名前をえる
//@see UnregistOcx
//@see registOcx
//@see GetOCXpath
//@see GetOCXVersion
//@@see AverSmallerBver
function getOCXName( class_GUID : TGUID ) : string;

//GUIDからocxのフルパスをえる
//@see getOCXName
//@see GetOCXVersion
//@@see AverSmallerBver
function GetOCXpath( class_GUID : TGUID ) : string;

//GUIDからocxのバージョンをえる
//@see getOCXName
//@see GetOCXpath
//@@see AverSmallerBver
function GetOCXVersion( classGUID: TGUID) :string;

//バージョンの比較    AVer < Bver　ならtrue
//@see getOCXName
//@see GetOCXVersion
//@@see GetOCXpath
function AverSmallerBver( Aver, Bver :string) : boolean;

//ファイルの中身をIstreamに変換
//@param fileName ファイル名
//@param ppiStream 書き込むIstream 呼び出す前に用意して渡す必要がある。
//@see IStreamToFile
procedure FileToIStream( fileName : WideString; var ppiStream : IStream);

//Istreamの中身をファイルに書きこむ
//ファイルの中身をIstreamに変換
//@param fileName 書き込むファイルの名前
//@param pStream 読み出すIstream
//@see FileToIStream
procedure IStreamToFile(pStream : IStream;fileName : string) ;

//Istreamを文字列に変換する。
//@see  StringToIstream
function  IStreamToString(pStream : IStream ) : String;
//文字列をIstremaに変換する。
//@see   IStreamToString
function  StringToIstream(Strings : String) : IStream;

//ocxのストリームにIStreamの内容を書き込む。
//@param Document IPersistStreamInitをサポートしているインスタンス
//@param Stream 書き込む内容が入っているIstream
//@see StringToOCX
//@see  OCXToString
//@see  OcxToIStream
//@see  LoadFromStrings
//@see  LoadFromStream
procedure IStreamToOcx( Document : IDispatch ; Stream : IStream) ;

//ocxのストリームに文字列を書きこむ。
//@param Document IPersistStreamInitをサポートしているインスタンス
//@param Astring 書き込む文字列
//@see  IStreamToOcx
//@see  OCXToString
//@see  OcxToIStream
//@see  LoadFromStrings
//@see  LoadFromStream
procedure StringToOCX( Document : IDispatch ;  Astring : string );

//ocxのストリームの中身をIstreamに書き出す。
//@param Document IPersistStreamInitをサポートしているインスタンス
//@result Istream
//@see  OCXToString
//@see  IStreamToOcx
//@see StringToOCX
//@see  OCXToString
//@see  LoadFromStrings
//@see  LoadFromStream

function OcxToIStream( Document : IDispatch) : IStream ;

//ocxのストリームの中身を文字列に書き出す。
//@param Document IPersistStreamInitをサポートしているインスタンス
//@result Istream
//@see  IStreamToOcx
//@see StringToOCX
//@see  OCXToString
//@see  LoadFromStrings
//@see  LoadFromStream
function OCXToString( Document : IDispatch  ) : String;

//ストリームの中身をocxのストリームに書き出す。
//@param Document IPersistStreamInitをサポートしているインスタンス
//@param AStream TStream 書き込むストリーム
//@see  IStreamToOcx
//@see StringToOCX
//@see  OCXToString
//@see  OcxToIStream
//@see  LoadFromStream
function LoadFromStream(document : IDispatch ; const AStream: TStream): HRESULT;

//文字列をocxのストリームに書き出す。
//@param Document IPersistStreamInitをサポートしているインスタンス
//@param AString  書き込む文字列
//@see  IStreamToOcx
//@see StringToOCX
//@see  OCXToString
//@see  OcxToIStream
//@see  LoadFromStrings
function LoadFromStrings( document : IDispatch ; const AString: String): HResult;


implementation


function LoadFromStream(document : IDispatch ; const AStream: TStream): HRESULT;
begin
  AStream.seek(0, 0);
  Result := (Document as IPersistStreamInit).Load(TStreamadapter.Create(AStream));
end;

function LoadFromStrings( document : IDispatch ; const AString: String): HResult;
var
  M: TMemoryStream;
  astrings : TStringList;
begin
  //Result := S_FALSE;
  astrings := TStringList.Create;
  astrings.Text := astring;
  M := TMemoryStream.Create;
  try
    AStrings.SaveToStream(M);
    Result := LoadFromStream(document , M);
  finally


  M.free;
  astrings.free;
 end;
end;




  //**************************************************
  //Idispatchメソッド
//イベントシンクでは、Invokeメソッドしか使われないので、他のメッソドは、からにした。

 constructor TEvent_Sink.create(DEvent:T_DispatchEvent);
 begin
   inherited create;
   FSink :=DEvent;
 end;

 function TEvent_Sink.GetTypeInfoCount(out Count: Integer): HRESULT;
  begin
    result := S_ok;
  end;
 function TEvent_Sink.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HRESULT;
   begin
      result := E_NotImpl;
   end;
 function TEvent_Sink.GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount,
       LocaleID: Integer; DisplDs: Pointer): HRESULT; stdcall;
  begin
     result := E_NotImpl;
  end;

 //イベントが発生するとInvokeメッソドが呼ばれる。


  function TEvent_Sink.Invoke(Disp_ID: Integer; const IID: TGUID; LocaleID: Integer;
                          Flags: Word; var Params; VarResult, ExcepInfo,
                                           ArgErr: Pointer): HRESULT;
   begin
     self.invokeResult := VarResult;
     result := S_ok;
     if (assigned(FSink)) then
            FSink(Disp_ID,Params)
     else
      result :=E_NOTIMPL;
//      varResult := invokeResult;
   end;


{ Connect an IConnectionPoint interface }

procedure InterfaceConnect(const Source: IUnknown; const IID: TIID;
  const Sink: IUnknown; var Connection: Longint);
var
  CPC: IConnectionPointContainer;
  CP: IConnectionPoint;
begin
  Connection := 0;
  if Succeeded(Source.QueryInterface(IConnectionPointContainer, CPC)) then
    if Succeeded(CPC.FindConnectionPoint(IID, CP)) then
      CP.Advise(Sink, Connection);
end;

{ Disconnect an IConnectionPoint interface }

procedure InterfaceDisconnect(const Source: IUnknown; const IID: TIID;
  var Connection: Longint);
var
  CPC: IConnectionPointContainer;
  CP: IConnectionPoint;
begin
  if Connection <> 0 then
    if Succeeded(Source.QueryInterface(IConnectionPointContainer, CPC)) then
      if Succeeded(CPC.FindConnectionPoint(IID, CP)) then
        if Succeeded(CP.Unadvise(Connection)) then Connection := 0;
end;


  //*********ＣＯＭからのイベントコンテナの接続
constructor T_ConnectPoint.create(EventGUID : TGUID; Sink,m_pIe:IUnKnown);

begin
     inherited create;
      EGUID :=EventGUID;
     InterfaceConnect(m_pIe,EventGUID,sink,Fdw);
     m_i:=m_pie;
end;

destructor T_ConnectPoint.destroy;
begin
 InterfaceDisconnect(m_I,EGUID,fdw);

//      m_pcp.Unadvise(Fdw);
      inherited Destroy;
end;

constructor TDispatchEquipInvoke.Create(NotifyProcedure : T_NotifyProcedure);
 begin
   inherited Create;
   FNotifyProcedure := NotifyProcedure;
 end;

  function TDispatchEquipInvoke.GetTypeInfoCount(out Count: Integer): HRESULT;
  begin
    result :=  E_NotImpl;
  end;
 function TDispatchEquipInvoke.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HRESULT;
   begin
     result := E_NotImpl;
   end;
 function TDispatchEquipInvoke.GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount,
       LocaleID: Integer; DisplDs: Pointer): HRESULT; stdcall;
  begin
     result:= E_NotImpl;
  end;

 function TDispatchEquipInvoke.Invoke(Disp_ID: Integer; const IID: TGUID;
                                     LocaleID: Integer;
                                    Flags: Word; var Params; VarResult,
                       ExcepInfo, ArgErr: Pointer): HRESULT; stdcall;
 begin
  if assigned( FNotifyProcedure) then
    FNotifyProcedure;
   result:=s_ok;
 end;

procedure IStreamToFile(pStream: IStream; fileName: string);
var

        MemoryStream :TMemoryStream;

        oleStream : TOleStream;
begin
    olestream := TOleStream.Create( pStream );

    MemoryStream := TMemoryStream.Create;
    MemoryStream.CopyFrom( oleStream ,0);
    MemoryStream.SaveToFile( fileName ) ;
    MemoryStream.Free;
    oleStream.Free;

end;

procedure FileToIStream(fileName: WideString;
  var ppiStream: IStream);
var
  MemoryStream :TMemoryStream;
  hMem : HGLOBAL ;
  OleStream : TOleStream ;
begin

  MemoryStream := TMemoryStream.Create;
  try
    MemoryStream.LoadFromFile( fileName ) ;

    hMem := GlobalAlloc(GHND , MemoryStream.Size );
    CreateStreamOnHGlobal(hMem, TRUE, ppiStream) ;
    oleStream := TOleStream.Create(ppiStream);
    try
      OleStream.CopyFrom( MemoryStream ,0);
    finally
      OleStream.Free;
    end;

  finally
    Memorystream.Free;
  end;
end;

function  IStreamToString(pStream : IStream ) : String;
var
                        st : TStringStream;
                        o:toleStream;
begin


              o :=TOLEStream.Create(pstream);
              o.Seek(0,0);

              st := TSTringStream.Create('');
              st.CopyFrom( o , 0);
              st.Seek( 0 , 0);


              result := st.datastring;
              st.free;
             o.free;
end;
function  StringToIstream(strings : String): IStream;
var
 o:toleStream;
 hMem : HGLOBAL ;
 stringList : TStringList;
begin
 stringList := TstringList.create;
 stringlist.Text := strings;
 hMem := GlobalAlloc(GHND , 0 );
 CreateStreamOnHGlobal(Hmem, TRUE, result);

 o :=TOLEStream.Create( result );
 stringlist.SaveToStream( o );
 o.Free;
 stringList.Free;
 // .CopyFrom

end;

function registOcx( ocxName : string) : boolean;
begin
try
 result :=true;
 registerComServer(OcxName );
except
 showmessage( OcxName+'が登録できませんでした。');
 result := false;
end;
end;

function UnregistOcx( OcxName : string) : boolean;
type
  TRegProc   = function : HResult ; stdcall;
const
  RegProcName ='DllUnregisterServer';
var
  Handle : THandle;
  RegProc : TregProc;
begin
 result := false;
  handle := LoadLibrary(pChar( OcxName ));
  if handle < HINSTANCE_ERROR then
    raise Exception.CreateFmt('%S:%S' , [ SysErrorMessage( getLasterror ) , OcxName ]);
  try
    regProc := getProcAddress(handle , RegProcName );
    try
     if assigned( regProc ) then oleCheck( RegProc )
     else
        {$WARNINGS OFF}
        RaiseLastWin32error;
        {$WARNINGS ON}
        result := true; //アンレジスト成功
    except
      showMessage( OcxName + 'を削除できませんでした。');
    end;
  finally
    freeLibrary( handle );
  end;

end;
function OcxToIStream( Document : IDispatch ) : IStream ;
var       persist : IPersistStreamInit;
 hMem : HGLOBAL ;
 p : int64;
begin
 try
  hMem := GlobalAlloc(GHND , 0 );
  CreateStreamOnHGlobal(Hmem, TRUE, Result);
  persist := document as  IPersistStreamInit;
  persist.save( result , true );
  result.Seek( 0 , 0 , P);
 except
  result := nil ;
 end;
end;


function OcxToString( Document : IDispatch ) : String;
begin
  Result := IStreamToString( OcxtoIStream( Document ) );
end;

procedure IStreamToOcx( Document : IDispatch ; Stream : Istream ) ;
var p: int64;
begin
   stream.Seek( 0, 0 , P);
   (Document as IPersistStreamInit).Load(Stream);
end;


procedure StringToOCX( Document : IDispatch ;  Astring : string ) ;
begin
        IstreamtoOcx(Document ,   StringToIstream(Astring));
end;

function RegistoryReadString( path : string) : string;
var
 registry : TRegistry;

begin
  registry := TRegistry.Create;
  try
    registry.RootKey :=HKEY_CLASSES_ROOT;
    registry.OpenKeyReadOnly('\CLSID\' + path);

    result := registry.ReadString('') ;
    if result ='' then
      raise EOleException.Create( path + ' There is not OCX. '
        ,0,'','',0);
  finally
    registry.closeKey;
    registry.Free;
  end;

end;

function getOCXName( class_GUID : TGUID ) : string;
begin
    result := RegistoryReadString( GUIDtoString( class_GUID) );
end;

function GetOCXpath( class_GUID : TGUID ) : string;
 begin
    result := RegistoryReadString( GUIDtoString( class_GUID) + '\InprocServer32' );
end;

function GetOCXVersion( classGUID: TGUID) :string;
var
  InfoType :string;
  Info: Pointer;
  InfoData: Pointer;
  InfoSize: LongInt;
  Len: DWORD;
  FName: Pchar;
  LangPtr: Pointer;
begin
  Len := MAX_PATH + 1;
  result := '';
  InfoType := 'FileVersion';
  FName := Pchar( getOCXPath( classGUID) )     ;
  InfoSize := GetFileVersionInfoSize(Fname, Len);
  if (InfoSize > 0) then
  begin
    GetMem(Info, InfoSize);
    try
      if GetFileVersionInfo(FName, Len, InfoSize, Info) then
      begin
        Len := MAX_PATH;
        if VerQueryValue(Info, '\VarFileInfo\Translation', LangPtr, Len) then
          InfoType := Format('\StringFileInfo\%0.4x%0.4x\%s'#0, [LoWord(LongInt(LangPtr^)),
            HiWord(LongInt(LangPtr^)), InfoType]);
        if VerQueryValue(Info, Pchar(InfoType), InfoData, len) then
          Result := StrPas(PAnsiChar(InfoData));
      end;
    finally
      FreeMem(Info, InfoSize);
    end;
  end;
end;

function GetNum(var VerNum : string) : string;
var i : integer;
begin
  result :='';
  i := pos( '.' , VerNum );
  if i >0 then
  begin
    result :=   copy( verNum , 1 , i-1 );
    delete( verNum , 1 ,i );
  end
  else
  if VerNum<>'' then
  begin
    result := verNum;
    verNum :='';
  end;
end;

// AVer =< Bver
function AverSmallerBver( Aver, Bver :string) : boolean;
var i   : integer;
   Ast , Bst :string;

begin
  result := false;
  i :=0;
  while i < 3 do
  begin
   Ast := getNum( Aver );
   Bst := getNum( Bver );
     if strtoint( Ast ) > strtoint( Bst ) then exit;
   inc( i) ;
  end;
  result := true;

end;
 end.

