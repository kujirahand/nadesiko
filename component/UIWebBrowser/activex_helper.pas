{

1999�N2��28��
1999.28.Feb
1999�N12��1��
2001�N4���R��
2001�N�V���P��
activeX�̂��߂̃��C�u����

}
//@version 1.5
//widestring�Ŏ�n�����string�ϐ��Ƃ̊֌W��EUC������Ȃǂ�������B
//function  IStreamToString(pStream : IStream ) : String;
//�Ԓl��widestring����string�ɕύX

//function  StringToIstream(Strings : String) : IStream;
//������widestring����string�ɕύX

//@author �R�ؔ��@�W

unit ActiveX_Helper;
{$WARN SYMBOL_PLATFORM OFF}
interface

uses
  Windows, Messages, SysUtils, Classes, Controls,Dialogs,
  activeX, OleCtrls,axctrls, StdCtrls,Comobj ,Registry;

   const UnitVersion = 1.5;
Type
  //�C�x���g�V���N����邽�߂̃f�B�X�p�b�`���[�`��
  //T_ConnectPoint��example���Q��
//@see T_ConnectPoint
//@see TEvent_Sink
 T_DispatchEvent =procedure(Disp_ID: Integer; var Params) of object;

 //�ڑ��|�C���g�I�u�W�F�N�g
 //activeX�̃R���e�i�̃C�x���g���C�x���g�V���N�ɓn��

 {example:
activeX�̃C�x���g���E��
�@activeX�̃^�C�v���C�u�����̃f�B�X�p�b�`�e�[�u������ID�𒲂ׂ�B
�@����Ɋ�Â��Ă��x���g�V���N���쐬����B
�@�C�x���g�V���N��TEvent_Sink��T_DispatchEvent�^�̃v���V�[�W����n���č쐬����B
  �Ⴆ��
      // arg�F�����̃��X�g
//      Arg:=TDispParams(Params);
      //�C�x���g�̎�ނ́ADispID�Ŏw��B

procedure TDom_Event.DocumentEvent_sink(Disp_ID: Integer; var Params);
begin
�@�@�@�@case Disp_Id  of
�@�@�@�@�@ -600      :  DocClick ;
�@�@�@�@�@�@-601      :  DocDblclick ;
�@�@�@�@�@�@-607:  DocMouseUp ;
�@�@�@�@end; //case Disp
end;

�Ƃ���T_DispatchEvent�^�̃v���V�[�W�����쐬��

     DocumentEventSink := TEvent_Sink.Create(DocumentEvent_sink );
�Ƃ���΃C�x���g�V���N���ł���B
���̃C�x���g�V���N��activeX�̐ڑ��|�C���g���Ȃ��邱�Ƃɂ����activeX�̃C�x���g���E�����Ƃ��ł���B

�ȉ��́A�C�x���g�V���N��ڑ��|�C���g�ɐڑ������

       DocumenteventConnect :=  T_ConnectPoint.create(
                    GUID_DocumentEvent,DocumentEventsink as IUnKnown,doc);

�K�v���Ȃ��Ȃ����ꍇ�ɂ́AT_ConnectPoint��free����΁ATEvent_Sink���J�������B
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
 //�ڑ��|�C���g�I�u�W�F�N�g���쐬����B
 //@param EventGUID �C�x���g��guid�^�C�v���C�u�������Q�Ƃ̂���
 //@param m_pIe�@�C�x���g�V���N�����т���C���X�^���X�B
 //�ڂ����� T_ConnectPoint ��example���Q�Ƃ̂���
  constructor create(EventGUID : TGUID;Sink,m_pIe:IUnKnown);
  destructor  destroy; override;
 end;

//�C�x���g�V���N�I�u�W�F�N�g
  //T_ConnectPoint ��example���Q��
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

//  //T_ConnectPoint ��example���Q��
//@see T_ConnectPoint

    constructor Create(Devent:T_DispatchEvent);
    //destructor  Destroy; override;
 published
end;


 T_NotifyProcedure = procedure of object;
//�������Ƃ�Ȃ��ꍇ�̊ȗ��ȃC�x���g����̒�`

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

//com�@activeX�̓o�^
//@see getOCXName
//@see UnregistOcx
function registOcx( ocxName : string) : boolean;

//com activeX�̓o�^�폜
//@see getOCXName
//@see registOcx
function UnregistOcx( OcxName : string) : boolean;

//GUID����ocx�̖��O������
//@see UnregistOcx
//@see registOcx
//@see GetOCXpath
//@see GetOCXVersion
//@@see AverSmallerBver
function getOCXName( class_GUID : TGUID ) : string;

//GUID����ocx�̃t���p�X������
//@see getOCXName
//@see GetOCXVersion
//@@see AverSmallerBver
function GetOCXpath( class_GUID : TGUID ) : string;

//GUID����ocx�̃o�[�W����������
//@see getOCXName
//@see GetOCXpath
//@@see AverSmallerBver
function GetOCXVersion( classGUID: TGUID) :string;

//�o�[�W�����̔�r    AVer < Bver�@�Ȃ�true
//@see getOCXName
//@see GetOCXVersion
//@@see GetOCXpath
function AverSmallerBver( Aver, Bver :string) : boolean;

//�t�@�C���̒��g��Istream�ɕϊ�
//@param fileName �t�@�C����
//@param ppiStream ��������Istream �Ăяo���O�ɗp�ӂ��ēn���K�v������B
//@see IStreamToFile
procedure FileToIStream( fileName : WideString; var ppiStream : IStream);

//Istream�̒��g���t�@�C���ɏ�������
//�t�@�C���̒��g��Istream�ɕϊ�
//@param fileName �������ރt�@�C���̖��O
//@param pStream �ǂݏo��Istream
//@see FileToIStream
procedure IStreamToFile(pStream : IStream;fileName : string) ;

//Istream�𕶎���ɕϊ�����B
//@see  StringToIstream
function  IStreamToString(pStream : IStream ) : String;
//�������Istrema�ɕϊ�����B
//@see   IStreamToString
function  StringToIstream(Strings : String) : IStream;

//ocx�̃X�g���[����IStream�̓��e���������ށB
//@param Document IPersistStreamInit���T�|�[�g���Ă���C���X�^���X
//@param Stream �������ޓ��e�������Ă���Istream
//@see StringToOCX
//@see  OCXToString
//@see  OcxToIStream
//@see  LoadFromStrings
//@see  LoadFromStream
procedure IStreamToOcx( Document : IDispatch ; Stream : IStream) ;

//ocx�̃X�g���[���ɕ�������������ށB
//@param Document IPersistStreamInit���T�|�[�g���Ă���C���X�^���X
//@param Astring �������ޕ�����
//@see  IStreamToOcx
//@see  OCXToString
//@see  OcxToIStream
//@see  LoadFromStrings
//@see  LoadFromStream
procedure StringToOCX( Document : IDispatch ;  Astring : string );

//ocx�̃X�g���[���̒��g��Istream�ɏ����o���B
//@param Document IPersistStreamInit���T�|�[�g���Ă���C���X�^���X
//@result Istream
//@see  OCXToString
//@see  IStreamToOcx
//@see StringToOCX
//@see  OCXToString
//@see  LoadFromStrings
//@see  LoadFromStream

function OcxToIStream( Document : IDispatch) : IStream ;

//ocx�̃X�g���[���̒��g�𕶎���ɏ����o���B
//@param Document IPersistStreamInit���T�|�[�g���Ă���C���X�^���X
//@result Istream
//@see  IStreamToOcx
//@see StringToOCX
//@see  OCXToString
//@see  LoadFromStrings
//@see  LoadFromStream
function OCXToString( Document : IDispatch  ) : String;

//�X�g���[���̒��g��ocx�̃X�g���[���ɏ����o���B
//@param Document IPersistStreamInit���T�|�[�g���Ă���C���X�^���X
//@param AStream TStream �������ރX�g���[��
//@see  IStreamToOcx
//@see StringToOCX
//@see  OCXToString
//@see  OcxToIStream
//@see  LoadFromStream
function LoadFromStream(document : IDispatch ; const AStream: TStream): HRESULT;

//�������ocx�̃X�g���[���ɏ����o���B
//@param Document IPersistStreamInit���T�|�[�g���Ă���C���X�^���X
//@param AString  �������ޕ�����
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
  //Idispatch���\�b�h
//�C�x���g�V���N�ł́AInvoke���\�b�h�����g���Ȃ��̂ŁA���̃��b�\�h�́A����ɂ����B

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

 //�C�x���g�����������Invoke���b�\�h���Ă΂��B


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


  //*********�b�n�l����̃C�x���g�R���e�i�̐ڑ�
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
 showmessage( OcxName+'���o�^�ł��܂���ł����B');
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
        result := true; //�A�����W�X�g����
    except
      showMessage( OcxName + '���폜�ł��܂���ł����B');
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

