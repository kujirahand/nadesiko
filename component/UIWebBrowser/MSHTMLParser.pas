unit MSHTMLParser;

interface

uses
 mshtml_tlb,dialogs, ComObj, Urlmon, ActiveX, Windows, Messages, Classes,
 ActiveX_Helper;

   const UnitVersion = 0.5;
const
  DISPID_AMBIENT_DLCONTROL = (-5512);

  READYSTATE_UNINITIALIZED = $00000000;
  READYSTATE_LOADING = $00000001;
  READYSTATE_LOADED = $00000002;
  READYSTATE_INTERACTIVE = $00000003;
  READYSTATE_COMPLETE = $00000004;


  DLCTL_DLIMAGES = $00000010;
  DLCTL_VIDEOS = $00000020;
  DLCTL_BGSOUNDS = $00000040;
  DLCTL_NO_SCRIPTS = $00000080;
  DLCTL_NO_JAVA = $00000100;
  DLCTL_NO_RUNACTIVEXCTLS = $00000200;
  DLCTL_NO_DLACTIVEXCTLS = $00000400;
  DLCTL_DOWNLOADONLY = $00000800;
  DLCTL_NO_FRAMEDOWNLOAD = $00001000;
  DLCTL_RESYNCHRONIZE = $00002000;
  DLCTL_PRAGMA_NO_CACHE = $00004000;
  DLCTL_FORCEOFFLINE = $10000000;
  DLCTL_NO_CLIENTPULL = $20000000;
  DLCTL_SILENT = $40000000;
  DLCTL_OFFLINEIFNOTCONNECTED = $80000000;
  DLCTL_OFFLINE = DLCTL_OFFLINEIFNOTCONNECTED;

type


  TMSHTMLParser = class(TInterfacedObject, IDispatch, IPropertyNotifySink, IOleClientSite)
  private
    FReadyState : integer;
    FDoc: IhtmlDocument2;
    FonDocumentComplete :TNotifyEvent;
    FonNavigateComplete :TNotifyEvent;
    FEvent : T_ConnectPoint;

  protected
/// IDISPATCH
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
/// IPROPERTYNOTIFYSINK
    function OnChanged(dispid: TDispID): HResult; stdcall;
    function OnRequestEdit(dispid: TDispID): HResult; stdcall;
/// IOLECLIENTSITE
    function SaveObject: HResult; stdcall;
    function GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
      out mk: IMoniker): HResult; stdcall;
    function GetContainer(out container: IOleContainer): HResult; stdcall;
    function ShowObject: HResult; stdcall;
    function OnShowWindow(fShow: BOOL): HResult; stdcall;
    function RequestNewObjectLayout: HResult; stdcall;

///
    procedure createDocument(URL: string);

  public
    DownloadControl : integer;
    function Navigate( URL : WideString ): HResult;
//    function setURL(url: string): IHTMLELEMENTCollection;

    property document : IHTMLDocument2  read FDoc;
    property Readystate : integer read FReadystate;
  published
    property  onDocumentComplete :TNotifyEvent read FonDocumentComplete write  FonDocumentComplete ;
    property  onNavigateComplete :TNotifyEvent read FonNavigateComplete write FonNavigateComplete ;


    destructor  destroy ; override;
    constructor create( url : string ='about:blank');

  end;


/// Utils
procedure GetAnchorList(IC: IHTMLElementCollection; Anchorlist: TStrings);
procedure GetBookMarkList(IC: IHTMLElementCollection; BookmarkList: TStrings);

procedure GetImageList(IC: IHTMLElementCollection; ImageList: TStrings);



implementation
//uses ComServ;





/// CORE ---->>>>>>>>>

procedure TMSHTMLParser.createDocument(URL: string);
var
  OleObject: IOleObject;
  OleControl: IOleControl;
  ConnectionPointContainer: IConnectionPointContainer;

begin

  fReadystate :=  READYSTATE_UNINITIALIZED;
  CoCreateInstance(CLASS_HTMLDocument, nil, CLSCTX_INPROC_SERVER, IID_IHTMLDocument2, FDoc);

  oleObject := FDoc as IOleObject;
  OleObject.SetClientSite(self);

  oleControl := FDoc as IOleControl ;
  OleControl.OnAmbientPropertyChange(DISPID_AMBIENT_DLCONTROL);

  FEvent := T_ConnectPoint.create( IpropertyNotifySink ,  Self as IDispatch , FDoc);
 // ConnectionPointContainer := FDoc  as IConnectionPointContainer;
//  ConnectionPointContainer.FindConnectionPoint(IpropertyNotifySink, ConnectionPoint);
//  ConnectionPoint.Advise((Self as IDispatch), Cookie);
  Navigate( URL ) ;
 // fReadystate :=READYSTATE_COMPLETE;
end;



function TMSHTMLParser.Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
  Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult;
begin
  if DISPID_AMBIENT_DLCONTROL = DispId then begin
    PVariant(VarResult)^ := DownLoadControl;
    Result := S_OK;
  end else
    Result := DISP_E_MEMBERNOTFOUND;
end;


function TMSHTMLParser.OnChanged(dispid: TDispID): HResult;
var
  dp: TDispParams;
  vResult: OleVariant;
begin
  result := s_ok;
  if (DISPID_READYSTATE = Dispid) then

      if SUCCEEDED((FDoc as Ihtmldocument2).Invoke(DISPID_READYSTATE, GUID_null,
      LOCALE_SYSTEM_DEFAULT, DISPATCH_PROPERTYGET, dp, @vresult, nil, nil)) then
      begin

       FReadyState := Integer(vresult);

       case FReadyState of
         READYSTATE_COMPLETE :begin
              //  PostThreadMessage(GetCurrentThreadId(), WM_USER_STARTWALKING, 0, 0);
                      if assigned( FondocumentComplete ) then
                            FonDocumentComplete( self );

          end;
          READYSTATE_INTERACTIVE : begin
                      if assigned( FonNavigateComplete ) then
                          FonNavigateComplete( self );

          end;
       end;
      end;
end;

function TMSHTMLParser.Navigate( URL : WideString ): HResult;
var
  Moniker: IMoniker;
  BindCtx: IBindCTX;
  PersistMoniker: IPersistMoniker;
begin
   result := s_OK;
  if succeeded(createURLMoniker(nil, PWideChar( Url ), Moniker)) then
    if Succeeded(CreateBindCtx(0, BindCtx)) then
      if Succeeded(FDoc.queryinterface(IPersistMoniker, PersistMoniker)) then
      begin
        FreadyState :=   READYSTATE_UNINITIALIZED;
        result := PersistMoniker.Load(LongBool(0), Moniker, BindCtx, STGM_READ)

      end
      else Result := S_FALSE;
end;



///  UTILILIES ---------- >>>>>>>>>>>>>>>>>>>>>



procedure GetImageList(IC: IHtmlElementCollection; ImageList: TStrings);
var
  Image: IHTMLImgElement;
  Disp: IDispatch;
  x: Integer;
begin
  if IC <> nil then begin
    for x := 0 to IC.length - 1 do begin
      Disp := IC.item(x, 0);
      if SUCCEEDED(Disp.QueryInterface(IHTMLImgElement, Image))
        then ImageList.add(Image.src);
    end;
  end;
end;


procedure GetAnchorList(Ic: IHTMLElementCOllection; Anchorlist: TStrings);
var
  Anchor: IHTMLaNCHORElement;
  Disp: IDispatch;
  x: Integer;
begin
  if IC <> nil then begin
    for x := 0 to IC.length - 1 do begin
      Disp := IC.item(x, 0);
      if SUCCEEDED(Disp.QueryInterface(IHTMLAnchorElement, Anchor))
        and (anchor.href <> '')
        then Anchorlist.add(Anchor.href);
    end;
  end;
end;



procedure GetBookMarkList( Ic: IHTMLElementCOllection; BookmarkList: TStrings);
var
  Anchor: IHTMLANCHORElement;
  Disp: IDispatch;
  x: Integer;
begin
  if IC <> nil then begin
    for x := 0 to IC.length - 1 do begin
      Disp := IC.item(x, 0);
      if SUCCEEDED(Disp.QueryInterface(IHTMLAnchorElement, Anchor))
        and (anchor.NAME <> '')
        then BookMarklist.add(Anchor.name);
    end;
  end;
end;


/// Don't Care ------>>>>>>>>>>>


function TMSHTMLParser.OnRequestEdit(dispid: TDispID): HResult;
begin
  RESULT := E_NOTIMPL;
end;

function TMSHTMLParser.SaveObject: HResult;
begin
  result := E_NOTIMPL;
end;

function TMSHTMLParser.GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
  out mk: IMoniker): HResult;
begin
  result := E_NOTIMPL;
end;

function TMSHTMLParser.GetContainer(out container: IOleContainer): HResult;
begin
  result := E_NOTIMPL;
end;

function TMSHTMLParser.ShowObject: HResult;
begin
  result := E_NOTIMPL;
end;

function TMSHTMLParser.OnShowWindow(fShow: BOOL): HResult;
begin
  result := E_NOTIMPL;
end;

function TMSHTMLParser.RequestNewObjectLayout: HResult;
begin
  result := E_NOTIMPL;
end;

function TMSHTMLParser.GetTypeInfoCount(out Count: Integer): HResult;
begin
  result := E_NOTIMPL;
end;

function TMSHTMLParser.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
begin
  result := E_NOTIMPL;
end;

function TMSHTMLParser.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
begin
  result := E_NOTIMPL;
end;

constructor TMSHTMLParser.create(url : string ='about:blank');
begin
 inherited create ;
 oleInitialize(nil);

 FreadyState :=   READYSTATE_UNINITIALIZED;
 DownloadControl :=  DLCTL_DOWNLOADONLY + DLCTL_NO_SCRIPTS +
    DLCTL_NO_JAVA + DLCTL_NO_DLACTIVEXCTLS + DLCTL_SILENT+
    DLCTL_NO_RUNACTIVEXCTLS + DLCTL_OFFLINEIFNOTCONNECTED;

    createDocument( url )
end;

destructor TMSHTMLParser.destroy;
begin
  inherited;
  FEvent.Free;
    OleUninitialize;

end;

initialization

//  TComObjectFactory.Create(ComServer, TMSHTMLParser, Class_MS_HTMLParser,
//    'MS_HTMLParser', '', ciMultiInstance, tmApartment);
end.

