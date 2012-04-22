unit UIWebBrowser;
//***********************************************************************
// UIWebBrowser ver 6     for Delphi6
//  2001/09/02
//  このコンポーネントは、フリーウェアです。
//   このコンポーネントは、法を犯すこと、反道徳的なことに
//   使ってはいけません。
//   それ以外に基本的に、制限はありません。
//     再配布のさいには、ご連絡ください。
//       著作権者　由木尾　晃 e-mail　yukio@ca.mbn.or.jp
//           蛸薬師倶楽部　http://plaza21.mbn.or.jp/~takoyakusi/

//delphi4 delphi5用のTUIWebBrowserはTUIWebBrowserバージョン5.1をお使いください。
//  history

// ActiveXの取り込みから、
// Microsoft Internet Controlなどのインストール必要です。

interface

uses
  Windows, ActiveX, Classes, SysUtils,Graphics, OleCtrls, StdVCL,axctrls,
    Controls,messages,
    {$IF RTLVersion>=15}
    SHDocVw,
    {$ELSE}
    SHDocVw_TLB,
    {$IFEND}
    MSHTML_TLB,
    Registry,
    variants,
    forms, IEconst ,
    activex_helper,
    wininet,
    urlmon,
    ShellAPI,
    SHlObj;

  const UnitVersion = 6.0;

{$R-}


 type

// *********************************************************************//
// UIWebbrowser custom event
// *********************************************************************//
TUIWebBrowserShowContextMenu = procedure( Sender :Tobject; const dwID: DWORD; const ppt: PPOINT) of Object;
TUIWebBrowserGetHostInfo = procedure ( Sender : TObject ; var pInfo: TDOCHOSTUIINFO )  of Object;
TUIWebBrowserShowUI = procedure  ( Sender : TObject; const dwID: DWORD; const pActiveObject: IOleInPlaceActiveObject;
      const pCommandTarget: IOleCommandTarget; const pFrame: IOleInPlaceFrame;
      const pDoc: IOleInPlaceUIWindow )  of Object;
TUIWebBrowserHideUI = procedure( Sender :TObject)  of Object;
TUIWebBrowserUpdateUI = procedure( Sender :TObject)  of Object;
TUIWebBrowserEnableModeless = procedure ( Sender :TObject; const fEnable: BOOL )  of Object;

TUIWebBrowserTranslateAccelerator = procedure ( Sender :TObject; Var VirtualKey: word; var ShiftStates: TShiftState; var Done :Hresult ) of Object;
TUIWebBrowserGetExternal          = procedure ( sender :TObject; out ppDispatch: IDispatch ) of OBject;
TUIWebBrowserShowHelp             = procedure ( Sender :TObject; hwnd : THandle;
                                                pszHelpFile : POLESTR;
                                                uCommand : integer;
                                                dwData : longint;
                                                ptMouse : TPoint;
                                                var pDispachObjectHit : IDispatch) of Object;

TUIWebBrowserShowMessage          = procedure (Sender :TObject; hwnd : THandle;
                                                   lpstrText : POLESTR;
                                                   lpstrCaption : POLESTR;
                                                   dwType : longint;
                                                   lpstrHelpFile : POLESTR;
                                                   dwHelpContext : longint;
                                                   var plResult : LRESULT)  of object;


TUIWebBrowserGetDropTarget        = procedure ( sender :Tobject; const pDropTarget: IDropTarget;
                                                 out ppDropTarget: IDropTarget; var Done :Hresult ) of Object;
TUIWebBrowserTranslateUrl         = procedure ( sender : TObject; const dwTranslate: DWORD; const pchURLIn: POLESTR;
                                                         var ppchURLOut: POLESTR;var Done:HResult ) of object;
TUIWebBrowserFilterDataObject     = procedure ( sender : TObject; const pDO: IDataObject;
                                                 out ppDORet: IDataObject ;Var Done:hresult) of object;


{    function OnDocWindowActivate( const fActivate: BOOL ): HRESULT; stdcall;
    function OnFrameWindowActivate( const fActivate: BOOL ): HRESULT; stdcall;
    function ResizeBorder( const prcBorder: PRECT;
      const pUIWindow: IOleInPlaceUIWindow;
      const fRameWindow: BOOL ): HRESULT; stdcall;
    function TranslateAccelerator( const lpMsg: PMSG; const pguidCmdGroup: PGUID;
      const nCmdID: DWORD ): HRESULT; stdcall;
    function GetOptionKeyPath( var pchKey: POLESTR; const dw: DWORD ): HRESULT; stdcall;

       function ShowMessage(hwnd : THandle;
                          lpstrText : POLESTR;
                          lpstrCaption : POLESTR;
                          dwType : longint;
                          lpstrHelpFile : POLESTR;
                          dwHelpContext : longint;
                          var plResult : LRESULT) : HRESULT; stdcall;

      function ShowHelp(hwnd : THandle;
                        pszHelpFile : POLESTR;
                        uCommand : integer;
                        dwData : longint;
                        ptMouse : TPoint;
                        var pDispachObjectHit : IDispatch) : HRESULT; stdcall; Virtual ;
 }
  TUIWebBrowserStatusTextChange = procedure(Sender: TObject; const Text: WideString) of object;
  TUIWebBrowserProgressChange = procedure(Sender: TObject; Progress: Integer; ProgressMax: Integer) of object;
  TUIWebBrowserCommandStateChange = procedure(Sender: TObject; Command: Integer; Enable: WordBool) of object;
  TUIWebBrowserTitleChange = procedure(Sender: TObject; const Text: WideString) of object;
  TUIWebBrowserPropertyChange = procedure(Sender: TObject; const szProperty: WideString) of object;
  TUIWebBrowserBeforeNavigate2 = procedure(Sender: TObject; const pDisp: IDispatch;
                                                          var URL: OleVariant;
                                                          var Flags: OleVariant;
                                                          var TargetFrameName: OleVariant;
                                                          var PostData: OleVariant;
                                                          var Headers: OleVariant;
                                                          var Cancel: WordBool) of object;
  TUIWebBrowserNewWindow2 = procedure(Sender: TObject; var ppDisp: IDispatch; var Cancel: WordBool) of object;
  TUIWebBrowserNavigateComplete2 = procedure(Sender: TObject; const pDisp: IDispatch;
                                                            var URL: OleVariant) of object;
  TUIWebBrowserDocumentComplete = procedure(Sender: TObject; const pDisp: IDispatch;
                                                           var URL: OleVariant) of object;
  TUIWebBrowserOnVisible = procedure(Sender: TObject; Visible: WordBool) of object;
  TUIWebBrowserOnToolBar = procedure(Sender: TObject; ToolBar: WordBool) of object;
  TUIWebBrowserOnMenuBar = procedure(Sender: TObject; MenuBar: WordBool) of object;
  TUIWebBrowserOnStatusBar = procedure(Sender: TObject; StatusBar: WordBool) of object;
  TUIWebBrowserOnFullScreen = procedure(Sender: TObject; FullScreen: WordBool) of object;
  TUIWebBrowserOnTheaterMode = procedure(Sender: TObject; TheaterMode: WordBool) of object;


//**************
//**************
 TMessageHandler = procedure( msg:tmsg ; Handled : boolean ) of object;

  TDownLoadControl_  =set of ( CS_Images , CS_Videos , CS_BGSounds ,CS_NoScripts
  ,CS_NoJava , CS_NoActiveXRun , cs_NoActiveXDownLoad
  ,CS_DownLoadOnly , CS_ReSynchronize , CS_NoCash
  ,CS_NoFrame, CS_ForceOffLine , CS_NoClientPull , CS_Silent , CS_OffLine);

   //application.onMessageを管理する。

THookApplicationMessage = class
private
  messageList : TList;
public

  constructor Create;
  destructor  destroy;override;
  procedure HookMessage( Hook : TMessageEvent );
  procedure UnHookMessage( Hook : TMessageEvent );
  procedure Handler(var Msg: TMsg; var Handled: Boolean);
end;




  TUIWebBrowser = class( TWebBrowser, Idispatch,IDocHostShowUI,IDocHostUIHandler) //,IOleDocumentSite)
  private
//    FVersion : single;


    FIeEnableAccelerator :boolean;
    FIeNoContext: boolean;
    FieSCROLL_no: boolean;
    FIeNO3DBORDER: boolean;
    FIeDontSCRIPT: boolean;


    FIeNoBehavior  :boolean ;
    FIeAutoComplete  :boolean;
    FIeLunaStyle:Boolean;


    FDownLoadControl : TDownLoadControl_ ;
    FOleInPlaceActiveObject : IOleInPlaceActiveObject;
 //  FonMessageHandler : TMessagehandler;

    FTranseURL : Widestring ;

    FonTranslateAccelerator :TUIWebBrowserTranslateAccelerator;
    FOnUIShowContextMenu : TUIWebBrowserShowContextMenu;
    FonUIGetHostInfo     : TUIWebBrowserGetHostInfo;
//    FonUIShowUI          : TUIWebBrowserShowUI;
//    FonUIHideUI          : TUIWebBrowserHideUI;
//    FOnUIUpdateUI          : TUIWebBrowserUpdateUI;
    FonUIGetExternal       : TUIWebBrowserGetExternal;
    FonUIShowHelp          : TUIWebBrowserShowHelp;
    FonUIShowMessage : TUIWebBrowserShowMessage;

    FonUIGetDropTarget       : TUIWebBrowserGetDropTarget;
    FonUITranslateUrl        : TUIWebBrowserTranslateUrl ;
    FonUIFilterDataObject      : TUIWebBrowserFilterDataObject;
    FfpExceptions: Boolean;




    { IDispatch }
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;

  //     function GetIDispatchProp: IDispatch;

//Reserve

//    property onUIShowUI          : TUIWebBrowserShowUI          read FonUIShowUI           write FonUIShowUI;
//    property onUIHideUI          : TUIWebBrowserHideUI          read FonUIHideUI           write FonUIHideUI;
//    property OnUIUpdateUI          : TUIWebBrowserUpdateUI        read FOnUIUpdateUI           Write FOnUIUpdateUI;

   //delphiのバグをfix
   function GetDocument : IDispatch;
   function GetDocumentSource  : string;
   procedure  SetDocumentSource(HTMLCode  : string);
  protected

//******* IDocHostUIHandle
    function ShowContextMenu( const dwID: DWORD; const ppt: PPOINT;
      const pcmdtReserved: IUnknown; const pdispReserved: IDispatch ): HRESULT; stdcall;
    function GetHostInfo( var pInfo: TDOCHOSTUIINFO ): HRESULT; stdcall;
    function ShowUI( const dwID: DWORD; const pActiveObject: IOleInPlaceActiveObject;
      const pCommandTarget: IOleCommandTarget; const pFrame: IOleInPlaceFrame;
      const pDoc: IOleInPlaceUIWindow ): HRESULT; stdcall;
    function HideUI: HRESULT; stdcall;
    function UpdateUI: HRESULT; stdcall;
    function EnableModeless( const fEnable: BOOL ): HRESULT; stdcall;
    function OnDocWindowActivate( const fActivate: BOOL ): HRESULT; stdcall;
    function OnFrameWindowActivate( const fActivate: BOOL ): HRESULT; stdcall;
    function ResizeBorder( const prcBorder: PRECT;
      const pUIWindow: IOleInPlaceUIWindow;
      const fRameWindow: BOOL ): HRESULT; stdcall;
    function TranslateAccelerator( const lpMsg: PMSG; const pguidCmdGroup: PGUID;
      const nCmdID: DWORD ): HRESULT; stdcall;
    function GetOptionKeyPath( var pchKey: POLESTR; const dw: DWORD ): HRESULT; stdcall;
    function GetDropTarget( const pDropTarget: IDropTarget;
      out ppDropTarget: IDropTarget ): HRESULT; stdcall;
    function GetExternal( out ppDispatch: IDispatch ): HRESULT; stdcall;
    function TranslateUrl( const dwTranslate: DWORD; const pchURLIn: POLESTR;
      var ppchURLOut: POLESTR ): HRESULT; stdcall;
    function FilterDataObject( const pDO: IDataObject;
      out ppDORet: IDataObject ): HRESULT; stdcall;

       function ShowMessage(hwnd : THandle;
                          lpstrText : POLESTR;
                          lpstrCaption : POLESTR;
                          dwType : longint;
                          lpstrHelpFile : POLESTR;
                          dwHelpContext : longint;
                          var plResult : LRESULT) : HRESULT; stdcall;

      function ShowHelp(hwnd : THandle;
                        pszHelpFile : POLESTR;
                        uCommand : integer;
                        dwData : longint;
                        ptMouse : TPoint;
                        var pDispachObjectHit : IDispatch) : HRESULT; stdcall;

      procedure MessageHandler(var Msg: TMsg; var Handled: Boolean);


 //************

  public
   constructor create( AOwner : TComponent ); override;
   destructor  destroy; override;

    procedure DocFocus;
    // お気に入りフォルダをを取得
    function getFavfolder :string;

    procedure addURLFavorites( URL , Title :olevariant);
    procedure AddFavorites;
    procedure OrganizeFav;


    function QueryStatusWB(cmdID: OLECMDID): OLECMDF;
    procedure ExecWB(cmdID: OLECMDID; cmdexecopt: OLECMDEXECOPT; var pvaIn: OleVariant;
                     var pvaOut: OleVariant);

    {ブラウザに読み込まれた、ドキュメントのオートメーションを返す。
    delphiのTOleControlのGetIDispatchPropは、参照カウントの仕方に問題がありTWebBrowserのDocumentプロパティはリソースもれを起こす。
　読み込まれた、ドキュメントの種類（ＨＴＭＬ・ＶＲＭＬだとか）によってドキュメントの構造は違います。}

  {
   Documentプロパティの使い方
   どのような構造のオートメーションかは、activeXによってちがいます。
一番簡単なアクセス方法としては、DocumentプロパティをOlevariantでラップする方法です。(レイトバインディング)
}
{example:
 var ovDoc : Olevariant;
 begin
   ovDoc := oleVariant( webBrowser.Document );
   ovDoc.innerHTML;
end;
{
delphiのタイプライブラリの取り込み機能でactiveXのpascal形式のタイプライブラリを得て、アーリーバインディングする方法もあります。
この場合、Delphiのエディタの補完機能がつかえますので確実なプログラムが可能です。
}
{example:
var Doc : IHTMLDocument2;
Begin
  Doc := WebBrowser.Document as IHTMLDocument2;
  Doc.innerHTML;
end;
}
    property Document: IDispatch  read GetDocument;

{busyがtrueのときは、webBrowserが作業中（ダウンロード・レンダリング)であることをしめす。

BusyプロパティがTrueのとき、Documentオブジェクトを操作してはならない。
なぜなら、busyがTrueであるときは、Documentオブジェクトの構築している最中だからである。
なお、readyStateプロパティがcompleteであれば、busyがtrueでもよいはずなのだが、必ずしも
タイミングは一致していないので注意が必要である。
}

    Property TranseURL : Widestring  read FTranseURL ;

    Property DocumentSource : String Read GetDocumentSource  write SetDocumentSource;

    procedure loadHTTP(URLName: string);
    procedure LoadDocumentSource( FileName : WideString );

    PROCEDURE EditMode;
    procedure BrowserMode;
  procedure SetFontZoom(ZoomValue: Integer);

  function FontZoomRangeLow: Integer;

  function FontZoomRangeHigh: Integer;

  function GetFontZoom: Integer;

  published
  {/コンテックスメニューにTPopUpコンポーネントを指定します。
  説明

  PopUpプロパティにTPopUpコンポーネントを割り当て、IeNoContextプロパティをTrueにセットするとTPopUpコンポーネントを使用することができます。
  IeNoContextプロパティをFalseにセットするとTPopUpコンポーネントの使用は禁止されます
  }
  //@see IeNoContext
    property  PopupMenu;


    property onUITranslateAccelerator :TUIWebBrowserTranslateAccelerator read FonTranslateAccelerator write FonTranslateAccelerator;
    property OnUIShowContextMenu : TUIWebBrowserShowContextMenu read FOnUIShowContextMenu write FOnUIShowContextMenu;
    property onUIGetHostInfo     : TUIWebBrowserGetHostInfo     read FonUIGetHostInfo      write FonUIGetHostInfo;
    property onUIGetExternal       : TUIWebBrowserGetExternal     read FonUIGetExternal        write FonUIGetExternal;
    property onUIShowHelp          : TUIWebBrowserShowHelp        read FonUIShowHelp           write FonUIShowHelp ;
    property onUIGetDropTarget       : TUIWebBrowserGetDropTarget read FonUIGetDropTarget    write FonUIGetDropTarget;
    property OnUITranslateUrl        : TUIWebBrowserTranslateUrl  read FonUITranslateUrl   write FonUITranslateUrl;
    property onUIFilterDataObject    : TUIWebBrowserFilterDataObject read FonUIFilterDataObject write FonUIFilterDataObject;

    property onUIShowMessage         : TUIWebBrowserShowMessage      read  FonUIShowMessage  write FonUIShowMessage ;

{
Internetexplorer標準のコンテックスメニューを禁止します。

説明
IeNoContextをTrueにセットするとInternetExplorer標準のコンテックストメニューを禁止し、PopUpPopupMenuプロパティで任意のコンテクストメニューを割り当てることができます。
}
//@see PopUpPopupMenu
    property IeNoContext :boolean read FIeNoContext write FIeNoContext;
    property IeNO3DBORDER  :boolean read FIeNO3DBORDER  write FIeNO3DBORDER;
    property IeSCROLL_hidden   :boolean read FIeSCROLL_NO   write FIeSCROLL_NO;
    property IeDontSCRIPT    :boolean read FIeDontSCRIPT    write FIeDontSCRIPT;
{InternetExplore標準のショートカットキーを許可します。


説明

 IeEnableAcceleratorプロパティをTrueにセットすることによってInternetExplorer標準のショートカットキーを許可します。

 IeEnableAcceleratorプロパティをfalseにセットすることによってInternetExplorer標準のショートカットキーを禁止します。

onUITranslateAcceleratorイベントを使用すると、任意のショートカットキーを禁止したり、新たに、新しいショートカットを付け加えたりできます。（サンプルプログラムIeCont.pasのTForm1.BrowserUITranslateAcceleratorを参考にして下さい）
}
//@see onUITranslateAccelerator
    property IeEnableAccelerator :boolean read FIeEnableAccelerator write FIeEnableAccelerator;
    //trueにすることでビハビアスクリプトを禁止することができる。
    //ie5only
    property IeNoBehavior    :boolean read FIeNoBehavior    write FIeNoBehavior;
    //オートコンプリート機能の設定。
    //入力フォームにおけるEditコントロール自動補完機能の設定ができる。
    //ie5only
    property IeAutoComplete  :boolean read FIeAutoComplete  write FIeAutoComplete;
    property IeLunaStyle :boolean read FIeLunaStyle write FIeLunaStyle;
//

     //TUIWebBrowser custom
    property DownLoadControl : TDownLoadControl_ read FDownLoadControl write FDownLoadControl;




end;

const DISPID_AMBIENT_DLCONTROL  = -5512;
const
DLCTL_DLIMAGES               = $00000010;
DLCTL_VIDEOS                 = $00000020;
DLCTL_BGSOUNDS               = $00000040;
DLCTL_NO_SCRIPTS             = $00000080;
DLCTL_NO_JAVA                = $00000100;
DLCTL_NO_RUNACTIVEXCTLS      = $00000200;
DLCTL_NO_DLACTIVEXCTLS       = $00000400;
DLCTL_DOWNLOADONLY           = $00000800;
DLCTL_NO_FRAMEDOWNLOAD       = $00001000;
DLCTL_RESYNCHRONIZE          = $00002000;
DLCTL_PRAGMA_NO_CACHE        = $00004000;
DLCTL_FORCEOFFLINE           = $10000000;
DLCTL_NO_CLIENTPULL          = $20000000;
DLCTL_SILENT                  = $40000000;
DLCTL_OFFLINEIFNOTCONNECTED  = $80000000;
DLCTL_OFFLINE               = DLCTL_OFFLINEIFNOTCONNECTED;



var HookOnMessage : THookApplicationMessage ;
    defMessage    : TMessageEvent;


    //小数点例外を無効にする。
procedure DisEnableExceptions;

procedure Register;
 //InternetExplorのバージョンを得る。
 function GetIEVersion: string;

 //offLineモードかどうか調べる。
 //@result offLineであればtrue
 //@see  GlobalOffline
 function IsGlobalOffline: boolean;

 //offLineモードを設定する。
 //@param value : offLineであればtrue
 //@see  IsGlobalOffline
 procedure GlobalOffline(Value: Boolean = true);

 function DoOrganizeFavDlg(handle :THandle ; dir :pAnsiChar ): hresult;stdcall; external 'Shdocvw.dll';

 //navigate2メソッドのpostdata headerで使う。
 function EncodeVariantString(const S: string): Variant;

 function DecodeVariantString(const V: Variant): string;

 var Saved8087CW :word;
implementation

uses ComObj;


function EncodeVariantString(const S: string): Variant;
begin
  Result := Unassigned;
  if S <> '' then
  begin
    Result := VarArrayCreate([0, Length(S) - 1], varByte);
    Move(Pointer(S)^, VarArrayLock(Result)^, Length(S));
    VarArrayUnlock(Result);
  end;
end;

function DecodeVariantString(const V: Variant): string;
var
  i, j: Integer;
begin
  if VarIsArray(V) then
    for I := 0 to VarArrayHighBound(V, 1) do
    begin
      j := V[i];
      result := result + chr(j);
    end;
end;

function IsGlobalOffline : boolean;
var
  dwState,
  dwSize : DWORD;
begin
  dwState := 0;
  dwSize := SizeOf(dwState);
  result := false;
  if (InternetQueryOption(nil, INTERNET_OPTION_CONNECTED_STATE, @dwState,
    dwSize)) then
    if ((dwState and INTERNET_STATE_DISCONNECTED_BY_USER) <> 0) then
      result := true;
end;

procedure GlobalOffline(Value: Boolean =true);
const
  INTERNET_STATE_DISCONNECTED_BY_USER = $10;
  ISO_FORCE_DISCONNECTED = $1;
  INTERNET_STATE_CONNECTED = $1;
var
  ci: TInternetConnectedInfo;
  dwSize: DWORD;
begin
  dwSize := SizeOf(ci);
  if (Value) then begin
    ci.dwConnectedState := INTERNET_STATE_DISCONNECTED_BY_USER;
    ci.dwFlags := ISO_FORCE_DISCONNECTED;
  end else begin
    ci.dwFlags := 0;
    ci.dwConnectedState := INTERNET_STATE_CONNECTED;
  end;
  InternetSetOption(nil, INTERNET_OPTION_CONNECTED_STATE, @ci, dwSize);
end;


function GetIEVersion: string;
begin
  result := getOcxVersion( class_WebBrowser );
end;

function TUIWebBrowser.GetDocument : Idispatch;
begin
 result :=  Idispatch( olevariant( ControlInterface).document);

end;


procedure TUIWebBrowser.setFontZoom(ZoomValue: Integer);
var
  WEB , vaIn, vaOut: Olevariant;
begin
    web :=ControlInterface;
  if ZoomValue < FontZoomRangeLow then vaIn := FontZoomRangeLow else
    if ZoomValue > FontZoomRangeHigh then vaIn := FontZoomRangeHigh else
      vaIn := ZoomValue;

    web.ExecWB(OLECMDID_ZOOM,
          OLECMDEXECOPT_DONTPROMPTUSER,
               VaIn ,VaOut);

end;

function TUIWebBrowser.FontZoomRangeLow: Integer;
var
 web ,  vaIn, vaOut: Olevariant;
begin
    web :=ControlInterface;
    web.ExecWB(OLECMDID_GETZOOMRANGE,
          OLECMDEXECOPT_DONTPROMPTUSER,
               VaIn,VaOut);

   result := LoWord(Dword(vaOut));
end;

function TUIWebBrowser.FontZoomRangeHigh: Integer;
var
 web ,  vaIn, vaOut: Olevariant;
begin
    web :=ControlInterface;
    web.ExecWB(OLECMDID_GETZOOMRANGE,
          OLECMDEXECOPT_DONTPROMPTUSER,
               VaIn,VaOut);
   result := HiWord(Dword(vaOut));
end;

function TUIWebBrowser.GetFontZoom: Integer;
var
 web ,  vaIn, vaOut: Olevariant;
begin
   vaIn := null;
   web := ControlInterface;
    web.ExecWB(OLECMDID_ZOOM,
          OLECMDEXECOPT_DONTPROMPTUSER,
               VaIn,VaOut);
  result := vaOut;
end;


procedure TUIWebBrowser.DocFocus;
begin
   if Document <> nil then
    with Application as IOleobject do
      DoVerb(OLEIVERB_UIACTIVATE, nil, Self, 0, Handle, GetClientRect);
end;

procedure TUIWebBrowser.addURLFavorites( URL , Title :olevariant);
var  ShellUIHelper : IShellUIHelper;

begin
   ShellUIHelper := CreatecomObject(CLASS_ShellUIHelper) as  IShellUIHelper;
    ShellUIHelper.AddFavorite( URL , Title);

end;

procedure TUIWebBrowser.AddFavorites;
var doc :IHTMLDocument2;
begin
   doc := self.ControlInterface.Document as IHTMLDocument2;
   addURLFavorites( doc.location.href , doc.title );
end;

function TUIWebBrowser.getFavFolder : string;
var   SFolder: pItemIDList;
      SpecialPath: array[0..MAX_PATH] of Char;
begin
  SHGetSpecialFolderLocation(0, CSIDL_FAVORITES, SFolder);
  SHGetPathFromIDList(SFolder, SpecialPath);
  result := StrPas(SpecialPath);
end;

procedure TUIWebBrowser.OrganizeFav;

begin

 DoOrganizeFavDlg( self.Handle,pAnsichar( GetFavFolder ));

end;





constructor TUIWebBrowser.create( AOwner : TComponent);
begin
 oleInitialize(nil);
  FfpExceptions := True;
 inherited create(Aowner);
 IeAutoComplete := true;
 IeEnableAccelerator := true;
 IeLunaStyle := true;

 IeEnableAccelerator := true;
 downloadControl := [  CS_Images , CS_Videos , CS_BGSounds ];
// defMessage :=nil;

 if csDesigning in ComponentState  then exit;

  if HookOnMessage = nil then
  begin
    HookOnMessage := THookApplicationMessage.create;
   Forms.application.OnMessage :=  hookOnMessage.Handler;
  end;

  HookOnMessage.HookMessage( MessageHandler );


end;

destructor  TUIWebbrowser.destroy;
begin

 if not(csDesigning in ComponentState)  then
    HookOnMessage.UnHookMessage( MessageHandler );


 inherited destroy;
  OleUninitialize;

end;





procedure TUIWebBrowser.MessageHandler(var Msg: TMsg; var Handled: Boolean);
begin
  if handled =true then exit;

  try
    Handled := (IsDialogMessage( Handle, Msg) = True);
    if handled =false then exit;
  except
    HookOnMessage.UnHookMessage( MessageHandler );
    Halt; // 
    Exit;
  end;

    if (Msg.message=WM_CHAR) and (Msg.wParam=VK_TAB) then
    begin
      Msg.wParam:=WM_NULL;
      exit;
    end;

    if  not(
           (Msg.message =WM_KEYDOWN) or (Msg.message = WM_SYSKEYDOWN)
              or
           (Msg.message = WM_COMMAND) or (Msg.message =WM_SYSCOMMAND)
           )
        or
           ((Msg.message = WM_KEYDOWN) or (Msg.message = WM_KEYUP))
              and
              (
               (Msg.wParam = VK_BACK) or
               (Msg.wParam = VK_LEFT) or
               (Msg.wParam = VK_RIGHT)or
               (Msg.wParam = VK_DOWN) or
               (Msg.wParam = VK_UP)
              )
    then        exit;

   try
   if FOleInPlaceActiveObject = nil then
    begin
     FOleInPlaceActiveObject := ControlInterface as IOleInPlaceActiveObject;
    end;
    FOleInPlaceActiveObject.TranslateAccelerator(Msg)
  except
  end;
end;

function TUIWebBrowser.QueryStatusWB(cmdID: OLECMDID): OLECMDF;
begin
  Result := ControlInterface.QueryStatusWB(cmdID);
end;

procedure TUIWebBrowser.ExecWB(cmdID: OLECMDID; cmdexecopt: OLECMDEXECOPT; var pvaIn: OleVariant;
                             var pvaOut: OleVariant);
begin
try
  ControlInterface.ExecWB(cmdID, cmdexecopt, pvaIn, pvaOut);
except
end;
end;


{ TUIWebBrowser.IDispatch }

function TUIWebBrowser.GetTypeInfoCount(out Count: Integer): HResult;
begin
  Count := 0;
  Result := E_NOTIMPL;
end;

function TUIWebBrowser.GetTypeInfo(Index, LocaleID: Integer;
  out TypeInfo): HResult;
begin
  Pointer(TypeInfo) := nil;
  Result := E_NOTIMPL;
end;

function TUIWebBrowser.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
begin
  Result := E_NOTIMPL;
end;







// ＊＊＊＊＊＊＊＊環境プロパティの設定＊＊＊＊＊＊＊＊

function TUIWebBrowser.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params;
  VarResult, ExcepInfo, ArgErr: Pointer): HResult;
var
  dlc : DWORD ; //cardinal; //:Olevariant ;
//  F: TFont;
 const DISPID_AMBIENT_DLCONTROL  = -5512;
{ #define DISPID_AMBIENT_OFFLINEIFNOTCONNECTED          (-5501)
#define DISPID_AMBIENT_SILENT                         (-5502)

 }
begin

  if (Flags and DISPATCH_PROPERTYGET <> 0) and (VarResult <> nil) and
    (DispId = DISPID_AMBIENT_DLCONTROL) then
  begin
    Result := S_OK;
    case DispID of
      DISPID_AMBIENT_DLCONTROL:
      begin
      dlc:= 0;


        if CS_images in DownloadControl then
           dlc := dlc + DLCTL_DLIMAGES;

        if CS_Videos in DownloadControl then
           dlc := dlc or DLCTL_VIDEOS;

        if CS_BGSounds in DownloadControl then
           dlc := dlc or DLCTL_BGSOUNDS;


        if CS_NOSCRIPTS in DownloadControl then
           dlc := dlc or DLCTL_NO_SCRIPTs;

        if CS_NOJava in DownloadControl then
           dlc := dlc or DLCTL_NO_Java;

         if CS_NOActiveXRun in DownloadControl then
           dlc := dlc or DLCTL_NO_RUNACTIVEXCTLS;

        if CS_NOActiveXDownLoad in DownloadControl then
           dlc := dlc or DLCTL_NO_DLACTIVEXCTLS;

        if CS_DownLoadOnly in DownloadControl then
           dlc := dlc or  DLCTL_DOWNLOADONLY;

        if CS_NoFrame in DownloadControl then
           dlc := dlc or  DLCTL_NO_FRAMEDOWNLOAD ;

        if CS_Resynchronize in DownloadControl then
           dlc := dlc or  DLCTL_RESYNCHRONIZE ;

        if CS_NOCash in DownloadControl then
           dlc := dlc or  DLCTL_PRAGMA_NO_CACHE;

        if CS_ForceOffLine in DownloadControl then
           dlc := dlc or DLCTL_FORCEOFFLINE ;

        if CS_NoClientPull  in DownloadControl then
           dlc := dlc or DLCTL_NO_CLIENTPULL ;

        if CS_Silent in DownloadControl then
           dlc := dlc or DLCTL_SILENT;

        if CS_OffLine in DownloadControl then
           dlc := dlc or DLCTL_OFFLINEIFNOTCONNECTED;

        PVariant(VarResult)^ := Integer(dlc);
     end;
    end;
   end
     else
      Result := inherited Invoke(DispID, IID, LocaleID, Flags, Params,
        VarResult, ExcepInfo, ArgErr);
end;




//***************************************************************
//       IDocHostShowUI
//***************************************************************
function TUIWebBrowser.EnableModeless(const fEnable: BOOL): HRESULT;
begin
  result := E_NOTIMPL;
end;

function TUIWebBrowser.FilterDataObject(const pDO: IDataObject;
  out ppDORet: IDataObject): HRESULT;

var Done :Hresult;
begin
  if assigned(onUIFilterDataObject) then
  begin
    onUIFilterDataObject(self , PDO , ppDORet ,  done);
    result :=done;
    exit;
  end;
  result := S_FALSE ;
end;

function TUIWebBrowser.GetDropTarget(const pDropTarget: IDropTarget;
  out ppDropTarget: IDropTarget): HRESULT;

var done : HResult;
begin
  if assigned(onUIGetDropTarget ) then
  begin
    onUIGetDropTarget( self ,pDropTarget,ppDropTarget,Done);
    result :=done;
    exit;
  end;
 //重要＊＊＊＊＊＊＊＊＊＊＊
 //ファイルがドロップ出来るようになる。
    result := S_OK ;

end;

function TUIWebBrowser.GetExternal(out ppDispatch: IDispatch): HRESULT;
begin
   result := E_NOTIMPL;
 if assigned( onUIGetExternal ) then
 begin
  onUIGetExternal(self,ppDispatch);
  result :=s_ok;
 end;
end;

function TUIWebBrowser.GetHostInfo(var pInfo: TDOCHOSTUIINFO): HRESULT;
//var TDOCHOSTUIINFO
var flag :DWord ;
begin
{
Retrieves the UI capabilities of the IE4/MSHTML host.

Returns S_OK If successful, or an OLE-defined error code otherwise.

pInfo : Address of a DOCHOSTUIINFO structure that receives the host's UI capabilities.
}

//*******

{*********
DOCHOSTUIINFO
 **********
type
  PDOCHOSTUIINFO = ^TDOCHOSTUIINFO;
  TDOCHOSTUIINFO = record
    cbSize: ULONG;
    dwFlags: DWORD;
    dwDoubleClick: DWORD;
  end;

  IE4/MSHTML to retrieve information about the host's UI requirements.

cbSize  :       Size of this structure, in bytes.
dwFlags :       One or more of the DOCHOSTUIFLAG values that specify the UI capabilities of the host.
dwDoubleClick : One of the DOCHOSTUIDBLCLK values that specify the operation that should take place in response to a double-click.
}

{************DOCHOSTUIFLAG

Defines a set of flags that indicate the capabilities of a IDocHostUIHandler implementation.

DOCHOSTUIFLAG_DIALOG
  IE4/MSHTML will not allow selection of the text in the form.
DOCHOSTUIFLAG_DISABLE_HELP_MENU
  IE4/MSHTML will not display context menus.
DOCHOSTUIFLAG_NO3DBORDER
  IE4/MSHTML does not use 3-D borders.
DOCHOSTUIFLAG_SCROLL_NO
  IE4/MSHTML does not have scroll bars.
DOCHOSTUIFLAG_DISABLE_SCRIPT_INACTIVE
  IE4/MSHTML will not execute any script when loading pages.
DOCHOSTUIFLAG_OPENNEWWIN
  IE4/MSHTML will open a site in a new window when a link is clicked rather than browse to the new site using the same browser window.
DOCHOSTUIFLAG_DISABLE_OFFSCREEN
  Not implemented or used.
DOCHOSTUIFLAG_FLAT_SCROLLBAR
  IE4/MSHTML will use flat scroll bars for any UI it displays. Not currently supported.
DOCHOSTUIFLAG_DIV_BLOCKDEFAULT
  IE4/MSHTML will insert the <DIV> tag if a return is entered in edit mode. Without this flag, IE4/MSHTML will use the <P> tag.
DOCHOSTUIFLAG_ACTIVATE_CLIENTHIT_ONLY
  IE4/MSHTML will only become UI-active if the mouse is clicked in the client area of the window. It will not become UI-active if the mouse is clicked on a nonclient area, such as a scroll bar.

}
{*******DOCHOSTUIDBLCLK*****

Defines values used to indicate the proper action on a double-click event.

DOCHOSTUIDBLCLK_DEFAULT
Perform the default action.
DOCHOSTUIDBLCLK_SHOWPROPERTIES
Show the item's properties.
DOCHOSTUIDBLCLK_SHOWCODE
Show the page's source.
}
//*********

 flag :=0;
// if FIeNoContext then flag := flag or DOCHOSTUIFLAG_DISABLE_HELP_MENU;
 if FIeNO3DBORDER  then flag := flag or DOCHOSTUIFLAG_NO3DBORDER;
 if FieSCROLL_NO   then flag := flag or DOCHOSTUIFLAG_SCROLL_NO;
 if FieDontSCRIPT  then flag := flag or DOCHOSTUIFLAG_DISABLE_SCRIPT_INACTIVE ;
  if FIeNoBehavior     then  flag := flag or DOCHOSTUIFLAG_OVERRIDEBEHAVIORFACTORY;
 if FIeAutoComplete   then  flag := flag or DOCHOSTUIFLAG_ENABLE_FORMS_AUTOCOMPLETE;
 if FIeLunaStyle then flag:=flag or DOCHOSTUIFLAG_THEME;

 pinfo.dwFlags := flag ;
   pInfo.cbSize := SizeOf(pInfo);
  pInfo.dwDoubleClick := DOCHOSTUIDBLCLK_DEFAULT;
// pInfo := pDocInfo;
 result := s_OK;
end;

function TUIWebBrowser.GetOptionKeyPath(var pchKey: POLESTR;
  const dw: DWORD): HRESULT;
begin
 // pchkey :='HKEY_CURRENT_USER\test';
//  pchkey:=nil;
//  result :=S_FALSE;
//    result := E_NOTIMPL;
result :=S_FALSE;
end;

function TUIWebBrowser.HideUI: HRESULT;
begin
    result := S_FALSE;
end;

function TUIWebBrowser.OnDocWindowActivate(const fActivate: BOOL): HRESULT;
begin
     result := S_FALSE;
end;

function TUIWebBrowser.OnFrameWindowActivate(
  const fActivate: BOOL): HRESULT;
begin
     result := S_FALSE;
end;

function TUIWebBrowser.ResizeBorder(const prcBorder: PRECT;
  const pUIWindow: IOleInPlaceUIWindow; const fRameWindow: BOOL): HRESULT;
begin
     result := S_FALSE;
end;

function TUIWebBrowser.ShowContextMenu(const dwID: DWORD;
  const ppt: PPOINT; const pcmdtReserved: IUnknown;
  const pdispReserved: IDispatch): HRESULT;

//var Done :Hresult;
begin
{
 Called from IE4/MSHTML when it is about to show its context menu.

  Result Values: S_OK  Host displayed its own UI. IE4/MSHTML will not attempt to display its UI.
                 S_FALSE  Host did not display any UI. IE4/MSHTML will display its UI.
                 DOCHOST_E_UNKNOWN  Menu identifier is unknown. IE4/MSHTML may attempt an alternative identifier from a previous version.


 dwID            : Identifier of the context menu to be displayed.
 ppt              : Screen coordinates for the menu.
 pcmdtReserved   : The IOleCommandTarget interface used to query command status and execute commands on this object.
pdispReserved    : The IDispatch interface of the object at the screen coordinates. This allows a host to differentiate particular objects to provide more specific context.

The following menu identifiers are currently used.
Note: These identifiers are likely to change and are not currently exposed in a header file as part of the IE4/MSHTML SDK.
#define CONTEXT_MENU_DEFAULT 0
#define CONTEXT_MENU_IMAGE 1
#define CONTEXT_MENU_CONTROL 2
#define CONTEXT_MENU_TABLE 3
#define CONTEXT_MENU_DEBUG 4
#define CONTEXT_MENU_1DSELECT 5
#define CONTEXT_MENU_ANCHOR 6
#define CONTEXT_MENU_IMGDYNSRC 7

}
if assigned( FOnUIShowContextMenu ) then
  begin
     FOnUIShowContextMenu(self,dwID,ppt);
  end;

result := s_false;
if FIeNoContext then
 begin
  result := S_OK;
  if assigned(PopupMenu)  then
  //PopUpMenuがハンドルされていれば表示
  begin
    if PopupMenu.AutoPopup then
      popupMenu.Popup(ppt.x,ppt.y);
  end;
 end;
end;



function TUIWebBrowser.TranslateAccelerator(const lpMsg: PMSG;
  const pguidCmdGroup: PGUID; const nCmdID: DWORD): HRESULT;
var Done :Hresult;
 VirtualKey: word;  ShiftStates: TShiftState;
begin

{ Called by IE4/MSHTML when IOleInPlaceActiveObject::TranslateAccelerator or IOleControlSite::TranslateAccelerator is called.

  Returns S_OK if successful, or S_FALSE otherwise.
lpMsg           : Points to the message that might need to be translated.
pguidCmdGroup   : Command group identifier.
nCmdID          : Command identifier.
}

  if not FIeEnableAccelerator then
   begin
     result := s_ok ;
      exit
   end;
   ShiftStates :=[];
  if  GetKeyState(VK_CONTROL) <0  then
      	Include(ShiftStates, ssCtrl);
  if GetKeyState(VK_SHIFT) <0  then
      	Include(ShiftStates, ssShift);
  if GetKeyState(VK_MENU) <0  then
      	Include(ShiftStates, ssalt);

  virtualKey := lpmsg^.wParam;

  result :=s_FALSE;
  done := result;
  if  assigned(onUITranslateAccelerator) then
  begin
   onUITranslateAccelerator(Self, VirtualKey, ShiftStates ,done );
   result := Done;
   exit;
  end;
end;

function TUIWebBrowser.TranslateUrl(const dwTranslate: DWORD;
  const pchURLIn: POLESTR; var ppchURLOut: POLESTR): HRESULT;
var done :HREsult ;
begin
   FTranseURL := Widestring( pchURLin );

  if assigned( onUITranslateUrl ) then
  begin
    onUITranslateUrl( self , dwTranslate , pchURLIn , ppchURLOut , Done ) ;
    result := Done ;
    exit
  end;

   result := S_FALSE;
end;

function TUIWebBrowser.UpdateUI: HRESULT;
begin
   result := S_FALSE;
end;

function TUIWebBrowser.ShowUI(const dwID: DWORD;
  const pActiveObject: IOleInPlaceActiveObject;
  const pCommandTarget: IOleCommandTarget; const pFrame: IOleInPlaceFrame;
  const pDoc: IOleInPlaceUIWindow): HRESULT;
begin

    result := S_FALSE;
end;


//****************** IDocSHowUI
function TUIWebBrowser.ShowMessage(hwnd: THandle; lpstrText,
  lpstrCaption: POLESTR; dwType: Integer; lpstrHelpFile: POLESTR;
  dwHelpContext: Integer; var plResult: LRESULT): HRESULT;
begin
   if assigned( onUIShowMessage ) then
   begin
      onUIShowMessage( self , hwnd , lpstrText,
        lpstrCaption , dwType , lpstrHelpFile ,
        dwHelpContext , plResult);
      Result := S_FALSE;
   end
   else
     result :=S_FALSE

end;

function TUIWebBrowser.ShowHelp(hwnd: THandle; pszHelpFile: POLESTR;
  uCommand, dwData: Integer; ptMouse: TPoint;
  var pDispachObjectHit: IDispatch): HRESULT;
begin
    if assigned( onUIShowHelp ) then
    begin
     onUIShowHelp( self ,hwnd , pszHelpFile , uCommand
             , dwData , ptMouse , pDispachObjectHit );
     result :=S_OK;
     exit;
    end;

     result := S_OK;

end;


{ THookApplicationMessage }

constructor THookApplicationMessage.Create;
begin
  inherited create;
   messageList := TList.Create;
   messageList.Clear;
end;

destructor THookApplicationMessage.destroy;
begin
  messageList.free;

  inherited destroy;
end;

procedure THookApplicationMessage.Handler(var Msg: TMsg;  var Handled: Boolean);
var i :integer;
begin
    i :=0 ;
    While I < messageList.Count  do
    begin
      try
       TMessageEvent(messageList[I]^)(Msg , Handled);
       if handled then break;
       inc(i);
      except
        Break;
      end;
    end;
end;

procedure THookApplicationMessage.HookMessage(Hook: TMessageEvent);
var
  MessageHook: ^TMessageEvent;
begin
    messageList.Expand;
    New(MessageHook);
    messageHook^ := Hook;
    messageList.Add( messageHook );
end;


procedure THookApplicationMessage.UnHookMessage(Hook: TMessageEvent);
var
  I: Integer;
  MessageHook: ^TMessageEvent;
begin
    i:=0;
    While I < messageList.Count  do
    begin

      MessageHook := messageList[I];
      if (TMethod(MessageHook^).Code = TMethod(Hook).Code) and
        (TMethod(MessageHook^).Data = TMethod(Hook).Data) then
      begin

        Dispose(MessageHook);
        MessageList.Delete(I);
     //  東風さんのおかげでbugFix  http://free.oc.to/
//        if messageList.Count = 0 then application.OnMessage :=nil;

        Break;
      end;
      inc(i);
    end;
end;

function TUIWebbrowser.GetDocumentSource  : string;
var
  pPStm : IPersistStreamInit;
  pStream : IStream;
  hMem : HGLOBAL ;
begin

  	      pPStm := document  as  IPersistStreamInit;

              hMem := GlobalAlloc(GHND , 0 );
              CreateStreamOnHGlobal(Hmem, TRUE, pStream);

              pPStm.Save(pstream , true);
              result := IStreamToString( pstream);
end;


procedure TUIWebbrowser.SetDocumentSource(HTMLCode  : string);
begin

              LoadFromStrings( document , HTMLCode );
end;


procedure TUIWebBrowser.loadHTTP(URLName: string);
var pIMoniker : IMoniker;
     hr : HRESULT;
     szwName : Widestring;
      pPMk : IPersistMoniker;
      pBCtx : IBindCtx ;
      stm : IStream;
begin

  // Ask the system for a URL Moniker
  szwName := URLName;
  hr := CreateURLMoniker(nil, PWideChar(szwName), pIMoniker);
  if ( (hr) = S_OK ) then
  begin
    pPMK := document as   IPersistMoniker;
    hr := CreateBindCtx(0, pBCtx);
    if ( hr = s_OK)  then
    begin
      pPMk.Load(FALSE, pIMoniker ,  pBCtx, STGM_READ);
      pIMoniker.Save(stm,false);
    end;
  end;

end;


procedure TUIWebbrowser.LoadDocumentSource( FileName : WideString );
var
  pPStm :  IPersistFile;
begin
  pPStm := document  as  IPersistFile;

  pPstm.load(PwideChar(Filename) , 0);   //( pInputStream );
end;

PROCEDURE TUIWebbrowser.EditMode;
VAR DD :OLEVARIANT;
com : IOleCommandTarget;
begin
  dd:=null;
  com := document as IOleCommandTarget ;

  com.Exec(@CMDSETID_Forms3,
           IDM_EditMODE , OLECMDEXECOPT_DODEFAULT, dd,dd) ;
end;

procedure TUIWebbrowser.BrowserMode;
VAR DD :OLEVARIANT;
com : IOleCommandTarget;
begin
  dd:=null;
  com := document as IOleCommandTarget ;

  com.Exec(@CMDSETID_Forms3,
           IDM_BROWSEMODE , OLECMDEXECOPT_DODEFAULT, dd,dd) ;

end;



procedure Register;
begin
  RegisterComponents('www',[ TUIWebBrowser ]);
end;

procedure DisEnableExceptions;
begin
    Set8087CW($133F);

end;


initialization

 HookOnMessage := nil;

finalization

 //  東風さんのおかげでbugFix  http://free.oc.to/
 if  ( HookOnMessage <> nil) then
                  HookOnMessage.Free;
     application.OnMessage := nil;

 //＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊




end.
