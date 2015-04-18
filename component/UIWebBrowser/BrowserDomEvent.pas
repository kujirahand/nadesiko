unit BrowserDomEvent;

{
  TDomEvent component ver6.2
  2002 8 Aug.

        All the  Copyright By Yukio Akira
              http://plaza21.mbn.or.jp/~takoyakusi/
              e-mail yukio@ca.mbn.or.jp

 TDomEventコンポーネントは、プログラムソースコードを公開していますが、シェアウエアです。
  TDomEventの利用権の値段は、1000円です。
支払い先
　七十七銀行　八木山支店
店コード　２６９　普通預金口座番号 9015477
   由木尾　晃　（ユキオ　アキラ）
　となっています。
再配布するときは、必ず私の許可を得て下さい。


e-mail yukio@ca.mbn.or.jp
The TDomEvent component is shareware, although it is disclosing the program source cord.

history
}
interface

uses
  Windows, Messages, SysUtils
  , Classes, Graphics, Controls, Forms, Dialogs
  ,MSHTML_TLB,StdCtrls ,menus ,OleCtnrs
  ,comobj, ComCtrls,ActiveX_Helper ,ActiveX, OleCtrls
  , SHDocVw  ,urlmon ,wininet , ShlObj
  ,Registry , ieconst , javaSctipyHTMLParser,Variants;

//**************
// delphi4 delphi5で使う方は、バージョン５・１１をお使いください

{type

TAdjucentTagPos = record
   beforeBegin , afterBegin
  ,beforeEnd   , afterEnd : cardinal;
end;
}
  const UnitVersion = 6.2;

type
  tagREADYSTATE = TOleEnum;
const
  READYSTATE_UNINITIALIZED = $00000000;
  READYSTATE_LOADING = $00000001;
  READYSTATE_LOADED = $00000002;
  READYSTATE_INTERACTIVE = $00000003;
  READYSTATE_COMPLETE = $00000004;

type
  DHTMLEDITCMDF = TOleEnum;
const
  DECMDF_NOTSUPPORTED = $00000000;
  DECMDF_DISABLED = $00000001;
  DECMDF_ENABLED = $00000003;
  DECMDF_LATCHED = $00000007;
  DECMDF_NINCHED = $0000000B;


//　TDomLibsを使用するには、下記のように必ず
// _setDocumentにWebBrowserオブジェクトのDocumentを代入してください。

//var DomLib : TDomLibs
//begin
//   DomLib := TDomLibs.create( self );
//    DomLib._SetDocument( WebBrowser1.documet as IHTMLDocument2);


type TDomLibs = class( TComponent)
private
    FDocument : IHTMLDocument2;
protected
    OLEControl : Olevariant;

public
   CommandTarget : IOleCommandTarget;
   property Document : IHTMLDocument2 read FDocument;
   procedure _setDocument( Document : IHTMLDocument2 );
//*****テキストレンジ

//body全体のtextRangeをえる
//TextRange of whole body is obtained .
  function GetBODYTextRange :IHTMLTxtRange ;
//bodyエレメントを取得する。
  function Body : IHTMLBodyElement ;
//選択されているtextRangeをえる
  function getSelectTextRnge : IHTMLTxtRange;
//選択されているHTMLElementを得る
  function GetSelectElemet : IHTMLElement;
  //ブラウザ上で、選択されているエレメントをBeginTag, EndTagではさむ。
  procedure InsertBlockTag( BeginTag, EndTag : string );
//ブラウザ上で、選択されているエレメントにtagが含まれているかどうか
  function SelectElement_As_Tag(tagName :string ): IHTMLElement;



//textRangeをsearchStringで検索する。検索に失敗するとnilを返す。
//@param TextRange :IHTMLTxtRange ;  検索をするテキストレンジ
//@param SearchString : wideString 検索文字
//@param Count : integer 2:大文字小文字を区別　4:語で検索
//@param condition :integer  検索する文字数　正なら上方向へ　負なら下方向に検索をすすめる。
  function TextRangeFind( TextRange :IHTMLTxtRange ; SearchString : wideString;  Count , condition :integer ) : IHTMLTxtRange;

   //選択されているブロックエレメントに指定されたタグがあれば、
   //そのタグを含むエレメントを返す。
   //If there be tag that was designated to the block element
   //that is selected the element including the tag is returned.
  function HTMLWalkSearchElement(TagName :string) :iHTMLElement;
//指定したエレメントに指定したタグがないか調べる。
  procedure HTMLwalkSearchTag( TagName : String;var HTMLElement: IHTMLElement);

//*******コレクション
   procedure GetID_List( IDLists :Tstrings);
//アンカーのコレクションを得る
  function GetAnchorsCollection : IHTMLElementCollection;
//アンカーの一覧を得る
  procedure GetAnchorsList( AnchorsList :Tstrings);
//ブックマークの一覧を得る。
  procedure GetBookMark( BookMarks :Tstrings);
 //ハイパーリンクのコレクションを得る
  function  getHyperLinksCollection :IHTMLElementCollection;
  procedure GetHyperLinksList( LInksLists:TStrings );

//********スタイルシート
//************************
   procedure SetClass( Element : IHTMLElement ; ClassName : string );
   procedure SetID( Element : IHTMLElement ; ID : string );
   procedure styleInsert( id : string );

   function WriteAbsoluteURL( RelativeDoc : string) : string;


//スタイルシートに付けたtitleでスタイルシートを検索する。
 function findStyleSheet( StyleSheetTitle :string ) :IHTMLStyleSheet;
 function findRule(Selector :String;StyleSheet: IHTMLStyleSheet): IHTMLRuleStyle;

//スタイルシートのコレクションを得る
 function GetStyleSheets : IHTMLStyleSheetsCollection;

 procedure getTagSelectClassNameList( classes : TStrings ; TagName :string);

//スタイルシートを得る。
 function GetStyleSheet(ovNameindex : OLevariant) :IHTMLStyleSheet ;
  procedure WalkStyleSheetLink( StyleSheets  : Olevariant;
                                         LinKURLs  : TStrings  );
 procedure GetStyleSheetLinkList( LinKURLs  : TStrings  );
procedure WalkStyleSheetText( StyleSheets  : OleVariant ;
                        CSSTexts  : TStrings  );
 procedure GetStyleText (styles : Tstrings);
//スタイルエレメントを得る
//最初にindex=-1;をセットcssの優先順位が高い順にセレクターを検索する。
//indexに検索したセレクターのruleの順位が入る
// index=0 and result:=nil 検索セレクタはない
// index<0 index値が異常
//
 function getStyleRoulBySelector( StyleSheet : IHTMLStyleSheet ;
                    Selector : WideString; var index :integer):IHTMLRuleStyle;

 function GetStyleElement(ovNameindex : OLevariant) : IHTMLStyleElement ;

 function findRuleInStyleSheets( Selector :string ) : IHTMLRuleStyle;

//SheetIndexで指定されたスタイルシートからselectorを検索する。
//もし、selectorが含まれない場合は、selectorをつけ足す。
 function SetStyleRule(Selector :string; SheetIndex :integer) : IHTMLRuleStyle; overload;
 function SetStyleRule(Selector :string; StyleSheet : IHTMLStyleSheet ) : IHTMLRuleStyle; overload;


 function GetHyperLink :WideString;


////レイヤのオブジェクトを呼び出す。
//@param ojName : WideString レイヤの名前

 //@see getLayOj
 //@see zindexLAYER
 //@see GetzindexLAYER
 //@see moveByLAYER
 //@see moveLAYER
 //@see outputLAYER
 function  getLayOj( ojName : WideString ) : IHTMLElement; //Olevariant;

 //レイヤオブジェクトの表示する優先順位を指定する。
 //@param　oj :　IHTMLStyle
 //@param　zindex　: integer　大きいほど前面に表示される。
 //@see getLayOj
 //@see zindexLAYER
 //@see GetzindexLAYER
 //@see moveByLAYER
 //@see moveLAYER
 //@see outputLAYER
 procedure zindexLAYER( oj :IHTMLStyle; zindex : integer );
 //@see getLayOj
 //@see zindexLAYER
 //@see GetzindexLAYER
 //@see moveByLAYER
 //@see moveLAYER
 //@see outputLAYER
 function   GetzindexLAYER(oj: IHTMLStyle) : integer;
 //レイヤーを指定した位置へ移動させる.
 //@see getLayOj
 //@see zindexLAYER
 //@see GetzindexLAYER
 //@see moveByLAYER
 //@see moveLAYER
 //@see outputLAYER
 procedure moveLAYER(oj : Olevariant {IHTMLStyle } ; x , y : integer) ;
 //レイヤーの現在位置を起点として指定したピクセル分だけ位置を移動
 //@see getLayOj
 //@see zindexLAYER
 //@see GetzindexLAYER
 //@see moveByLAYER
 //@see moveLAYER
 //@see outputLAYER
 procedure moveByLAYER(oj : IHTMLStyle; offsetx,offsety : integer) ;
 //レイヤー内のHTMLをタグごと書き換える
 //@see getLayOj
 //@see zindexLAYER
 //@see GetzindexLAYER
 //@see moveByLAYER
 //@see moveLAYER
 //@see outputLAYER
 procedure outputLAYER(ov_oj : Olevariant ; html :wideString);

 procedure setCLIP(oj : IHTMLStyle; clipTop , clipRight , clipBottom , clipLeft : integer);


  //ドキュメント上でコマンドの値を得る
 function queryCommandvalue( CMD : WideString ) :WideString;
  //フォーカスをセットする。
  procedure  setFocus;
    //タグの名前からHTMLエレメントのコレクションをえる。
    function Tags_get( TagName : String ) : IHTMLElementCollection;

published
//  property Version : single read FVersion;




end;




type
TDom_Event = class(TDomLibs)
private
  FOwner : TObject;

  DocumentEventConnect :T_ConnectPoint ;
  DocumentEventSink : TEvent_Sink;


  WindowEventConnect :T_ConnectPoint ;
  WindowEventSink : TEvent_Sink ;


  //  procedure onDocKeyPress(const Value: TDomEvent);
    procedure ProcessingKey(var VirtualKey: word;
              var ShiftStates: TShiftState );
    procedure ProcessingMouse(var VirtualKey: word; var Button :integer ;
              var ShiftStates: TShiftState );
{              0  No button.
1  Left button is pressed.
2  Right button is pressed.
4  Middle button is pressed.
 }

   procedure DocumentEvent_sink(Disp_ID: Integer; var Params);
   procedure WindowEvent_Sink(Disp_ID: integer; var Params);
 //イベント発生時のmouseの座標を得る。
  function MouseCoordinate : TPoint;

//  procedure HTMLwalkSearchTag( TagName : String;var HTMLElement: IHTMLElement);

protected
 isDestroy : boolean;

  procedure DocKeyPress;
  procedure dockeyDown;
  procedure DocKeyUP ;
  procedure DocMOuseDown;
  procedure DocMouseUP;
  procedure DocClick ;
  procedure DocDblclick ;
  procedure DocMousemove;
  procedure DocMouseOut;
  procedure DocMouseover;
  procedure DocReadystatechange;
  procedure DocDragstart;
  procedure DocSelectstart;

  function  GetTitleElement: IHTMLTitleElement ;
  procedure WalkFrames( window : IHTMLWindow2 ; FrameLocations , FrameNames: TStrings  );




public
  MouseDownEventElement :IHTMLElement;
  IDM_Result : HRESult;
  CommandTarget : IOleCommandTarget;
  MousePoint : TPoint;
//  Eventelement : IHTMLEvent;
 constructor create;   overload;
 procedure SetDocument(Document : IDispatch ;AOwner :Tobject);

  function  GetFrameCollection :  IHTMLFramesCollection2;
  procedure GetFrameList( FrameLists , FrameNames : TStrings );



//procedure GetStyleSheetLinkList( LinKURLs  : TStrings  );
//******IDM系コマンド( UIWebBrowser.pasのヘッダ.pas参考）
    //コマンドの情況を問いあわせる。
 function GetCommandStatus( CmdGUID : TGUID ; IDM_cmd : Cardinal ) : DHTMLEDITCMDF; overload ;
 function GetCommandStatus( IDM_cmd : Cardinal ) : DHTMLEDITCMDF;  overload;
 function queryUsed_IDM( CmdGUID : TGUID ; IDM_cmd : Cardinal ) : boolean; overload ;
 function queryUsed_IDM( IDM_cmd : Cardinal ) : Boolean;  overload;
    //IDM系のこまんどの実行

 function Exec_IDMCommand( CmdGUID : TGUID;
                  IDM_cmd : cardinal;
                  const pVarIn : OleVariant;
                    dwCmdOpt : cardinal
                   ) : Olevariant ; overload;

 function Exec_IDMCommand( CmdGUID : TGUID;
                  IDM_cmd : cardinal;
                  dwCmdOpt : cardinal
                   ) : Olevariant ; overload;

 function Exec_IDMCommand( IDM_cmd : cardinal;
                  const pVarIn : OleVariant;
                  dwCmdOpt : cardinal
                   ) : Olevariant ;    overload;

 function Exec_IDMCommand( IDM_cmd : cardinal;
                           dwCmdOpt : cardinal
                   ) : Olevariant ;    overload;



 function GetDocumentSource  : string;
 procedure setDocumentSource( HTMLCode : string);
 procedure LoadDocumentSource( FileName : WideString );

 destructor destroy;  override;

 property DocumentSource : String read GetDocumentSource write setDocumentSource;
  function GetTitle : string ;
published


end;



type
TDomKeyEvent = procedure( Client : TDom_Event
                ;VirtualKey: word; ShiftStates: TShiftState; fireElement : IHTMLElement ) of Object;
TDomMouseEvent = procedure ( Client : TDom_Event ; mousePoint : Tpoint
                ;button :integer; ShiftStates: TShiftState; fireElement : IHTMLElement ) of Object;
TDomMouseWithOutBtnEvent =procedure( Client : TDom_Event
                ; ShiftStates: TShiftState; fireElement : IHTMLElement ) of Object;
TDomErrorEvent  = procedure( Client : TDom_Event ; ErrMsg,url:string ; line :integer; fireElement : IHTMLElement ) of object;

TDomReadyStateChange = procedure( Client : TDom_Event; ReadyStates : tagREADYSTATE ; fireElement : IHTMLElement) of Object;

TWinEvent = procedure( Container : TDom_Event) of object;
TWinEvent1 =procedure( Container : TDom_Event ; fireElement : IHTMLElement ) of object;
TWinEvent2 =procedure( DomContainer : TDom_Event ) of object;

//UTF8変換用
T_DoubleByte = record

     case integer of
      0: (LoByte , HiByte : byte) ;
      1: (WByte :word);
     end;


type
TieEvent = class
  private
    { Private 宣言 }
       Arg:TDispParams;
       vURL, vFlag, vTargetFrameName, vPostData, vHeaders: OleVariant;
       Cancel: WordBool;
       ppDisp: IDispatch;

    FAowner : TObject;
    Ie4EventConnect :T_ConnectPoint ;
    Ie4EventSink : TEvent_Sink ;
    procedure IE4Event_sink(Disp_ID: Integer; var Params);

  protected
    { Protected 宣言 }
  public
    { Public 宣言 }
    OnStatusTextChange   : TWebbrowserStatusTextChange;
    OnProgressChange     : TWebbrowserProgressChange;
    OnCommandStateChange : TWebbrowserCommandStateChange;
    OnDownloadBegin      : TNotifyEvent;
    OnDownloadComplete   : TNotifyEvent;
    OnTitleChange        : TWebbrowserTitleChange;
    OnPropertyChange     : TWebbrowserPropertyChange;
    OnBeforeNavigate2    : TWebbrowserBeforeNavigate2;
    OnNewWindow2         : TWebbrowserNewWindow2;
    OnNavigateComplete2  : TWebbrowserNavigateComplete2;
    OnDocumentComplete   : TWebbrowserDocumentComplete;
    OnQuit               : TNotifyEvent;
    OnVisible            : TWebbrowserOnVisible;
    OnToolBar            : TWebbrowserOnToolBar;
    OnMenuBar            : TWebbrowserOnMenuBar;
    OnStatusBar          : TWebbrowserOnStatusBar;
    OnFullScreen         : TWebbrowserOnFullScreen;
    OnTheaterMode        : TWebbrowserOnTheaterMode;
    constructor Create(Aowner : Tobject ; WebBrowser : IWebbrowser2 );
    destructor destroy; override;
  published
    { Published 宣言 }

  end;


TDomEvent = class(TDomLibs , IBindStatusCallback)
 private
    { Private 宣言 }
    WinFirst:boolean; //バグfix用

    // フォーカスをもっているクライアント
    FFocusDomContainer : TDom_event;
    FEditElement : IHTMLElement;     //

    FEventElement : IHTMLElement;
  //クライアントウインドウを管理する配列
   FDomContainers :  TList;
//Documentオブジェクトのイベント
   FonDocClick     : TDomMouseEvent;
   FonDocDblclick  : TDomMouseEvent;

   FonDocMouseover : TDomMouseEvent;
   FonDocReadystatechange : TDomReadyStateChange;
   FonDocDragstart : TDomMouseEvent;
   FonDocSelectstart : TDomMouseEvent;
   FonDocKeyPress : TDomKeyEvent;
   FonDocKeyDown  : TDomKeyEvent;
   FonDockeyUP    : TDomKeyEvent;
   FonDocMouseDown: TDomMouseEvent;
   FonDocMouseUp  : TDomMouseEvent;
   FonDocMouseMove :TDomMouseEvent;
   FonDocMouseOut : TDomMouseEvent;


//windowsオブジェクトイベント
     FonwinFocus  : TWinEvent1 ;
     FonWinUnload : TWinEvent2 ;
     Fonwinload   : TwinEvent ;
     Fonwinhelp      : TWinEvent1 ;
     Fonwinblur      : TWinEvent1 ;
     Fonwinerror     : TWinEvent1 ;
     Fonwinresize    : TWinEvent ;
     Fonwinscroll    : TWinEvent ;
     Fonwinbeforeunload: TWinEvent ;


    ieEvent : TieEvent;
    FFocusDocument :IHTMLDocument2; //フォーカスのあるドキュメント
    FWebBrowser :IWebbrowser2;

 //**************************IBindStatusCallback

    function OnStartBinding(dwReserved:
                              {$IFDEF VER120} Longint{$ELSE}
                               DWORD {$ENDIF};
                                pib: IBinding): HResult; stdcall;
    function GetPriority(out nPriority
                              {$IFDEF VER120}: Longint{$ENDIF}): HResult; stdcall;
    function OnLowResource(reserved:
                                {$IFDEF VER120} Longint{$ELSE}
                                 DWORD {$ENDIF}): HResult; stdcall;
    function OnProgress(ulProgress, ulProgressMax, ulStatusCode:
                                {$IFDEF VER120} Longint{$ELSE}
                                 ULONG {$ENDIF} ;
                                 szStatusText:
                                 {$IFDEF VER120} PWideChar {$ELSE} LPCWSTR {$ENDIF}): HResult; stdcall;
    function OnStopBinding(hresult: HResult; szError:
                                 {$IFDEF VER120} PWideChar {$ELSE} LPCWSTR {$ENDIF}): HResult; stdcall;
    function GetBindInfo(out grfBINDF:
                                {$IFDEF VER120} Longint{$ELSE} DWORD {$ENDIF};
                                 var bindinfo: TBindInfo): HResult; stdcall;
    function OnDataAvailable(grfBSCF:
                                 {$IFDEF VER120} Longint{$ELSE} DWORD {$ENDIF};
                             dwSize:    {$IFDEF VER120} Longint{$ELSE} DWORD {$ENDIF};
                             {$IFDEF VER120} var {$ENDIF}
                             formatetc: {$IFDEF VER120} TFormatEtc{$ELSE} PFormatEtc {$ENDIF};
                             {$IFDEF VER120} var {$ENDIF}
                                  stgmed:    {$IFDEF VER120} TSTGMEDIUM {$ELSE} PStgMedium {$ENDIF}
                             ): HResult; stdcall;

    function OnObjectAvailable(const iid: TGUID; {$IFDEF VER120} CONST {$ENDIF}punk: IUnknown): HResult; stdcall;



    procedure SetWebBrowser(WebBrowser : IWebBrowser2);
    procedure mobjIEDownloadComplete( Sender : Tobject );
    procedure mobjIENavigateComplete2(Sender: TObject; const pDisp: IDispatch;
                                                            var URL: OleVariant);
  protected
   procedure WalkFrames( window : IHTMLWindow2 ; FrameLocations , FrameNames: TStrings  );
   procedure winFocus(Container : TDom_Event ;  fireElement : IHTMLElement );
   procedure WinUnload(DomContainer : TDom_event);
   procedure winload(Container : TDom_Event);
   procedure Winhelp(Container : TDom_Event ;  fireElement : IHTMLElement );

   procedure winblur(Container : TDom_Event ; fireElement : IHTMLElement );
   procedure winerror(Container : TDom_Event ; fireElement : IHTMLElement );
   procedure winresize(Container : TDom_Event);
   procedure winscroll(Container : TDom_Event);
   procedure winbeforeunload(Container : TDom_Event);


  public
    { Public 宣言 }

    //クライアントウインドウを管理する配列
    //Arrangement that controls the client window
    property  DomContainers :  TList read FDomContainers;
     // フォーカスをもっているクライアント
     // Client who has a focus
    property FocusDomContainer : TDom_event read FFocusDomContainer;
    property WebBrowser  : IWebbrowser2 read FWebBrowser write SetWebBrowser;

   procedure GetBrowsURLlist(URLList,CashURLList : TStrings );
   //表示されているすべてのURLのキャッシュファイルを列挙する
   //Cash files of all URL that are displayed are listed
   procedure GetCashURLlist(URLList,CashList : Tstrings );

    procedure GetFrameList( FrameLists , FrameNames : TStrings );
    procedure findHTMLSource;
    procedure InternetOption;
    Procedure ViewSource;
    procedure addURLFavorites( URL , Title :olevariant);
    procedure AddFavorites;
    //印刷する　useDialogがtrueであれば印刷のダイアローグを表示
    procedure print( useDialog : boolean = true);
    procedure SetUPPrinter;

    procedure SetDisp_WebBrowser(WebBrowser: Idispatch);

    //アクティブなクライアントウインドウのDocumentが入る
    // Document property of an active client window enters
   property  FocusDocument:IHTMLDocument2 read  FFocusDocument ;
   property  EventElement : IHTMLElement read FEventElement;
    property EditElement : IHTMLElement read FEditElement ;

   constructor Create(AComponent : TComponent) ;  override;
    destructor destroy; override;

   procedure GetHTMLFile( URL , FileName : string);

  published
   property onDocKeyPress : TDomKeyEvent read FonDocKeyPress write FonDocKeyPress;
   property onDocKeyDown  : TDomKeyEvent read FonDocKeyDown  write FonDocKeyDown;
   property onDockeyUP    : TDomKeyEvent read FonDockeyUP    write FonDockeyUP ;
   property onDocMouseDown: TDomMouseEvent read FonDocMouseDown write FonDocMouseDown;
   property onDocMouseUp  : TDomMouseEvent read FonDocMouseUp  Write FonDocMouseUp   ;
   property onDocClick    : TDomMouseEvent  read FonDocClick    write FonDocClick;
   property onDocDblclick : TDomMouseEvent read FonDocDblclick write FonDocDblclick;
   property onDocMouseOut : TDomMouseEvent read FonDocMouseOut write  FonDocMouseOut ;
   property onDocMouseover: TDomMouseEvent read FonDocMouseover write FonDocMouseover;
   property onDocDragstart   : TDomMouseEvent read FonDocDragstart Write FonDocDragstart;
   property onDocSelectstart : TDomMouseEvent read FonDocSelectstart write FonDocSelectstart;
   property onDocReadystatechange : TDomReadystatechange read FonDocReadystatechange write FonDocReadystatechange;
   property onDocMouseMove: TDomMouseEvent read FonDocMouseMove write FonDocMouseMove;


    property onwinFocus  : TWinEvent1 read FonwinFocus write FonwinFocus;
    property onWinUnload : TWinEvent2 read FonWinUnload write FonWinUnload;
    property onwinload   : TwinEvent read FonWinLoad   write FonWinLoad;
    property onwinhelp   : TWinEvent1 read FonWinhelp   write FonWinhelp;

    property onwinblur      : TWinEvent1 read Fonwinblur write Fonwinblur ;
    property onwinerror     : TWinEvent1 read Fonwinerror write Fonwinerror;
    property onwinresize    : TWinEvent read Fonwinresize write Fonwinresize;
    property onwinscroll    : TWinEvent read Fonwinscroll  write Fonwinscroll;
    property onwinbeforeunload: TWinEvent read Fonwinbeforeunload write Fonwinbeforeunload;


  end;


//ＵＲＬからcasheFileNameを取得する。
//CasheFileName is acquired from URL.
function  get_HTMLCashFileName(URL :string) : string;
function URLtoFile(var s: string): boolean;
function ReplaceChar(src, dst: char; var s: string): Integer;



 const GUID_IE4EventGUID : TGUID='{34A715A0-6587-11D0-924A-0020AFC7AC4D}';
 const  GUID_DocumentEvent :TGUID = '{3050F260-98B5-11CF-BB82-00AA00BDCE0B}';
 const  DIID_HTMLWindowEvents: TGUID = '{96A0A4E0-D062-11CF-94B6-00AA0060275C}';


//***********************************
 {   function  AdjacentTag( Doc, Tag : string ;
                            var  adjTagPos : TAdjucentTagPos) : boolean;
}
     function isLinkElementWithHREF( StyleSheets  : OleVariant  ) : boolean;
    //url( http://xxx )を文字列から探し出す。
    function AdjacentURL( Doc : string ;
                             var adjTagPos : TAdjucentTagPos) : boolean ;


    procedure ChangeTitle(var doc :string ;sTitle :string);

    function  NextSearch( substr: string; var Upcasedoc :string ;
            var index : cardinal; var ofs:integer):bool;

    //合成URLからURLの値をえる。
    function GetfromSynthesisURL( doc :string ; var startPos : integer) : string;
    //合成URLにURL値を書き換える。
    function PutfromSynthesisURL( doc ,  Source : string ; var startPos : integer) : string;
     //合成URLを相対アドレスに変換する。
    function reWriteRelativeURLinCSS( STYLE , pathName : string) : string;
    //docからtagを検索し、挟まれたtagを含まないＨＴＭＬをえる。
    function GetInnerHTML(doc , tag : string; container : boolean = false):string;

    //docからtagを検索し、挟まれたtagの間にＨＴＭＬをいれる。
    function PutInnerHTML(doc , tag , Source : string; container : boolean = false ) :string;
    //docからtagを検索し、挟まれたtagも含めて、ＨＴＭＬを置き換える。
    function PutOuterHTML(doc , tag , Source : string; container : boolean = false ) : string;

    //docからtagを検索し、挟まれたtagを含むＨＴＭＬをえる。
    function  GetOuterHTML(doc , tag : string; container : boolean = false) : string;

    function FormatTitle(sTitle: String): String;
//ドキュメントのなかのブロックタグをけす。
   function DeleteTagFromDocument( tag , document : string ) :string;
   procedure CollectionTAG( tag , document: string ; List : TSTrings);

   function NextAdjacentTag( Doc, Tag : string ;
                             var adjTagPos : TAdjucentTagPos) : boolean ;


   function attributeAnalysis( doc , Tag : string; var attribute : string): tpoint ;
   //name内のkeyのアトリビュートをえる
   function GetAttribute( Name , Key :string ): string;
   function GetATTR( doc ,TAG , Key :string ; var startPos : integer ; var succes : boolean) : string;
   function Putattr(  doc ,TAG , Key ,  Source : string ; var startPos : integer  ) : string;

    function setBASE(Doc , path : string): string;
    function delBASE(Doc : string) : string ;


//URL形式のパスをwindows形式のパスに変換
function FileProtocolToFileName( FileProtocol : string ) : string;
// /を￥にかえる
function SlashToYen( Slash : string ) :string;

// ￥マークを/マークになおす。
function YenToSlash( Yen : string ) :string;

//url形式で記述されたパスを、window形式のパスになおし、相対パスをえる
function FileRelativePath( baseFile , AbsolutePath :string ) : string;

//セレクターからID名を抽出する。
function idBySellector( sellector  : string ): string;
//セレクターからクラス名を抽出する。
function  ClassBySellector( sellector  : string ): string;

//セレクターからタグ名を抽出する。
function  TagBySellector( sellector  : string ): string;
//セレクターを正規化する
//セレクターがタグ名をともなうクラスをさすときに、タグ名を大文字にそろえる。
function Selector_Nomalization( selector :string) :string;

//hrefからブックマークを取り除き純粋なURLを取り出す。
function  URLbyHREF( href  : string ): string;

//hrefからリンク先のブックマークを取り出す。
function  NAMEbyHREF( HREF  : string ): string;

function URLDecode(const AStr: String): String;
function urlEncode(const S: string): string;

//＊＊＊＊ユニコードからUTF8へ変換
procedure UnitoUTF8(  unich:pWidechar; var j:cardinal ;UTFCh :Pchar; var i:cardinal);
{＊＊＊＊＊＊＊UTF8をユニコードunichに変換}
procedure UTF8toUni( UTFCh :Pchar;var i:cardinal ; unich:pchar;var j:cardinal);


//********ストリング文字列をUTF8文字列に変換
function StringtoUTF8(s : string ) : pchar;
//UTF8文字列をストリングに文字列に変換する。
function UTF8toString(UTF8 : pchar) : string;





procedure Register;

implementation
//headのみを返す
function delBASE(Doc : string) : string ;
var head  : string;
adjTagPos : TAdjucentTagPos;
begin
  head := getinnerHTML( doc , 'HEAD');

  while NextAdjacentTag( head,'BASE' , adjtagPos) do // AdjacentTag( parser ,'BASE' ,adjTagPos)  do
  begin
     delete( head , adjTagpos.beforeBegin+1 , (adjTagpos.afterBegin - adjTagpos.beforeBegin)-1  );
  end;
  result := head;
end;

function setBASE(Doc , path : string): string;
var head  : string;

begin
  head :=getOuterHTML( doc , 'HEAD' );
  if head='' then
  begin
  //headがない場合
    result := putouterHTML( doc , 'BODY','<head>'+ head + '</head>'+getOUterHTML(doc , 'BODY') );
  end
  else
  begin
  //headがある場合
    head :=  delBASE( doc);
   head := '<BASE HREF="'+ Path  +'">' + head;
   result :=putinnerHtml(doc , 'Head',head);
  end;
end;

//＊＊＊＊ユニコードからUTF8へ変換
procedure UnitoUTF8(  unich:pWidechar; var j:cardinal ;UTFCh :Pchar; var i:cardinal);
var  dummy,uniw :T_DoubleByte;

begin
//    16ビットUnicode    ->  UTF8形式Unicode
//    00000000 0xxxxxxx  ->  0xxxxxxx


   uniw.WByte := word(uniCh[j]);
   dummy.WByte := Word(UniCh[j+1]);
   if (uniw.WByte =0) //and ( dummy.WByte =0)
      then begin j:=2147483647;	exit; end;

  if not(bool((uniw.LoByte and $80 )) or(uniw.HiByte<>0)) then
  begin
    byte(UTFCh[i]):= byte(uniw.LoByte) and $7F;
   // byte(UTFCh[i+1]):= 0;
    i := i +1 ; j:= j +1 ;
    exit;
  end;

//    16ビットUnicode    ->  UTF8形式Unicode
//    00000xxx xxyyyyyy  ->  110xxxxx 10yyyyyy
  if ((uniw.HiByte) and $f8)=0 then
     begin
      //xxxxx
         dummy.WByte :=(uniW.WByte*4);
         byte(UTFCh[i]) :=( dummy.HiByte or $c0) and $DF;
      //yyyyyyy
         byte(UTFCh[i+1]):= (uniW.LoByte and $3F) or $80;
         i := I+2 ; j := j + 1 ;
         exit;
     end;

     //    16ビットUnicode    ->  UTF8形式Unicode
//    xxxxyyyy yyzzzzzz  ->  1110xxxx 10yyyyyy 10zzzzzz

      //xxxxx
         dummy.HiByte :=uniw.HiByte;//uniCh[j+1];
         byte(UTFCh[i]) :=(((dummy.HiByte div 16))and $0f) or $E0;

      //yyyyyyy
         dummy.WByte :=uniw.WByte;

         byte(UTFCh[i+1]) :=((dummy.WByte div 64) and $3f) or $80;

      //zzzzzz
        // uniw.HiByte := 0;//uniCh[j+1];
         byte(UTFCh[i+2]) :=(uniw.LoByte and $3f) or $80;

         i := I+3 ; j := j + 1 ;
end;



{＊＊＊＊＊＊＊UTF8をユニコードunichに変換}
procedure UTF8toUni( UTFCh :Pchar;var i:cardinal ; unich:pchar;var j:cardinal);

  var UTFW,Dummy : T_DoubleByte;
      sw :integer;
begin
//    16ビットUnicode    <-  UTF8形式Unicode
//    00000000 0xxxxxxx  <-  0xxxxxxx
  if (Byte(UTFCh[i]) =0 )and (Byte(UTFCh[i+1])=0)  then
  begin j:=2147483647;	exit; end;

  if not(((byte(UTFCh[i])and $80)=$80)) then
         begin
           byte(unich[j+1]) :=0;
           uniCh[j+0] := UTFCh[i];

           i:=i+1; j := j+2;
            exit
         end;

   sw := integer(byte(UTFCh[i]) and $E0 );
  case sw of
//    16ビットUnicode    <-  UTF8形式Unicode
//    00000xxx xxyyyyyy  <-  110xxxxx 10yyyyyy

       $c0:
           begin
             //yyyyyy
             UTFW.HiByte := 0 ;
             UTFW.LoByte := Byte(UTFCh[i+1]) and $3f;
             //xxxxxx
             dummy.HiByte := Byte(UTFch[i])   and $1f;
             dummy.LoByte := 0;
             dummy.WByte :=(dummy.WByte div 4) ;

             UTFW.WByte := dummy.WByte or UTFW.WByte ;

             Byte(unich[j+1])   :=UTFW.HiByte;
             Byte(unich[j+0]) :=UTFW.LoByte;
             i:=I+2;
           end;
//    16ビットUnicode    <-  UTF8形式Unicode
//    xxxxyyyy yyzzzzzz  <-  1110xxxx 10yyyyyy 10zzzzzz

       $e0:
           begin
             //zzzzzz
             UTFW.HiByte := 0 ;
             UTFW.LoByte := byte(UTFCh[i+2]) and $3f;

             //yyyyyyy
             dummy.HiByte :=byte(UTFch[i+1]) and $3f;
             dummy.LoByte := 0;
             //yyyyyyzzzzzzz
             dummy.WByte :=dummy.WByte div 4 ;
             UTFW.WByte := dummy.WByte or UTFW.WByte ;

             //xxxxx
             dummy.HiByte := byte(UTFch[i]) and $0f;
             dummy.HiByte := dummy.HiByte*16;
             dummy.LoByte:=0;
             UTFW.WByte := dummy.WByte or UTFW.WByte ;


             Byte(unich[j+1])   :=UTFW.HiByte;
             Byte(unich[j+0]) :=UTFW.LoByte;

             i:=I+3;
          end;
      end;
      j:=J+2;
end;

//***********
//UTF8文字列をストリングに文字列に変換する。
function UTF8toString(UTF8 : pchar) : string;
var indexUni,IndexUTF,len : cardinal;
    uniCh : pchar;
begin
  len := strlen(UTF8);
  try
    uniCh := StrAlloc(len*2+2);

    indexUni:=0; indexUTF:=0;
    while (indexUTF< len) do
      UTF8toUni(UTF8,indexUTF , unich,indexUni);

     //ターミネータ
     byte(unich[indexUni])   := 0;
     byte(unich[indexUni+1]) := 0;
    Result := WideCharToString(PWideChar(uniCh));
  finally
    StrDispose(uniCh);
  end;
end;

//*********
//********ストリング文字列をUTF8文字列に変換
function StringtoUTF8(s : string ) : pchar;
var indexUni,IndexUTF , len: cardinal;
    utf8 :Pchar;
    unich : pWidechar;
begin

  try
    len := length(s);
     UTF8 := StrAlloc(len*3+3);




    unich := pwidechar( StrAlloc(len*2+2));

    StringToWideChar(s,unich,len*2);

    indexUni := 0; indexUTF := 0;
    while (indexUni < (len)) do
      UnitouTF8((unich),indexUni , UTF8,indexUTF);
      byte(UTF8[indexUTF])   := 0  ;
      byte(UTF8[IndexUTF+1]) := 0 ;
      byte(UTF8[IndexUTF+2]) := 0 ;
    Result := utf8;
  finally
    StrDispose(pchar(unich));
  end;
end;



function SlashToYen( Slash : string ) :string;
begin
     result := StringReplace( slash ,'/' ,'\', [rfIgnoreCase]+[rfReplaceAll]  );
end;

function YenToSlash( Yen : string ) :string;
begin
     result := StringReplace( Yen ,'\' ,'/', [rfIgnoreCase]+[rfReplaceAll]  );
end;

function FileProtocolToFileName( FileProtocol : string ) : string;
begin
     result := '';
     fileProtocol := urlDecode(fileProtocol);

     if ansipos('file:',FileProtocol) = 0 then
         if ansipos(':',FileProtocol) <> 2 then  exit; //すでにプロトコルがはずれている場合。

       result :=StringReplace( FileProtocol ,'file:///' ,'', [rfIgnoreCase] );
       result :=StringReplace(  result ,'file://' ,'', [rfIgnoreCase] );
       result := StringReplace( result ,'/' ,'\', [rfIgnoreCase]+[rfReplaceAll]  );
end;

function FileRelativePath( baseFile , AbsolutePath :string ) : string;
begin
       result := AbsolutePath;
     if ansipos('file:',result ) = 0 then
         if ansipos(':',result ) <> 2 then  exit;

         AbsolutePath := FileProtocolToFileName( AbsolutePath );
         result := ExtractRelativePath( baseFile , AbsolutePath );
end;



function GetInnerHTML(doc , tag : string; container : boolean = false) : string;
 var
 parser : TSCParser;
begin
  parser := TTagParser.Create( doc , container );
   parser.Reset;
  result :=get_innerHTML( parser , tag);
  parser.Free;
end;

function GetOuterHTML(doc , tag : string; container : boolean = false) : string;
 var  parser : TSCParser;
begin
  parser := TTagParser.Create( doc , container );
  parser.Reset;
  result := get_outerHTML( parser ,tag);
  parser.Free;
end;

function PutInnerHTML(doc , tag , Source : string; container : boolean = false ) : string;
 var
 adjTagPos  : TAdjucentTagPos;
 tmpdoc : string;
 parser : TScParser;
begin

     parser :=TTagParser.Create(doc , container);
     parser.Reset;
     result :='';
     if  adjacentTag(parser , tag , adjTagPos ) then
     begin
       tmpDoc := copy(Doc,1,adjTagPos.afterBegin -1);
       delete( doc, 1 , adjTagPos.beforeEnd );
       result := tmpdoc + Source + doc;
     end;
     parser.Free;
end;

function PutOuterHTML(doc , tag , Source : string; container : boolean = false ) : string;
 var   adjTagPos  : TAdjucentTagPos;
 tmpdoc : string;
 parser : TSCParser;
begin
     parser := TTAgParser.Create( doc , container) ;
     parser.Reset;
     result :='';
     if  adjacentTag(parser , tag , adjTagPos ) then
     begin
       tmpDoc := copy(Doc,1,adjTagPos.beforeBegin -1);
       delete( doc, 1 , adjTagPos.afterEnd  );
       doc := trim(doc);
       result := tmpdoc + Source + doc;
     end;
   parser.Free;
end;


procedure ChangeTitle(var doc : string;sTitle :string);
var
    HTML:string;
begin
  HTML := getouterHTML( doc , 'TITLE');
  if HTML='' then    //head tagあり title　tagなし
   begin
     HTML := getinnerHTML( doc , 'HEAD');
     HTML := HTML + formatTitle(sTitle);
     doc := putinnerHTML( doc ,'HEAD' , HTML);
   end
  else      //title あり
   begin
    doc := putinnerHTML( doc , 'TITLE' , sTitle );
  end;
end;
//文字列のサーチ
function NextSearch( substr: string;var UpCasedoc :string ;
            var index : cardinal; var ofs:integer):bool;

var
    StartPos : integer ;

begin
        result := false;

        StartPos := ansipos(substr, UpcaseDoc );
        if StartPos = 0 then exit;

        index := index+ofs+ Startpos;
        ofs := length(substr)-1;
        result := true;
       delete(upcaseDoc,1,startPos+ofs);
end;

function FormatTitle(sTitle: String): String;
begin

  Result := '<title>' + sTitle + '</title>';
end;

function DeleteTagFromDocument( tag , document : string ) :string;
var doc  :string;
begin
//現在のタグを削る
   doc := PutOuterHTML( document , Tag , '');


   while doc <> '' do
   begin
       doc := PutOuterHTML( document , tag , '');
       if doc <> '' then
           Document := doc ;
   end;
   result :=document;
end;


procedure CollectionTAG( tag , document: string ; List : TSTrings);
var doc, HTML :string;
begin
//現在のタグを削る
   HTML := getOuterHTML( document , Tag );
   doc :=  putOuterHTML( document , tag , '');

   while doc <> '' do
   begin
       List.Add( HTML );
       HTML := getOuterHTML( doc , Tag );
       doc := PutOuterHTML( doc , tag , '');
       if doc <> '' then
           Document := doc ;
   end;
end;


function GetAttributeSub(var  Att : string ) :string;
begin


 result:='';
 if pos('=',att)<>0 then
  begin
   result := Att;
   delete(result ,1,pos('=',att));
   att :=copy(att ,1,pos('=',att)-1);

    result := trim( result );

end;
end;

function GetAttribute( Name , Key :string ): string;
var
    bw, param:string;
    keyPos : integer;
begin
  result :='';
     if Name ='' then exit;

  repeat
     KeyPos := AnsiPos( AnsiUpperCase( key ), AnsiUpperCase( Name ));
     if  KeyPos <1 then Exit;
     bw := name[KeyPos - 1] ;
          Delete( Name , 1 , keyPos - 1);
     param := name;
     delete( name , 1 , length( key));
     name := trim( name );
  until ( name[ 1 ] = '=' ) and ((bw =' ' ) or (keyPos = 1 ) or (bw ='''') or (bw ='"'));


//     if pos( key ,  Name )<1 then exit;
  result := getAttributeSub( Name );


  if result ='' then exit;

  param :=copy( result , 1 , pos(' ' ,result ) -1 ) ;

  if  param ='' then
     param :=copy( result , 1 , pos('>' ,result ) -1 ) ;

   result :=param;
    result := trim( result );

   if Length(result )>1 then
    if (result[1]='"') and (result[Length(result)]='"')
       or
       (result[1]='''') and (result[Length(result)]='''')
       then
     begin
      delete(result,1,1);
      delete(result,Length(result),1);
     end;
    result := trim( result );


end;


function NextAdjacentTag( Doc, Tag : string ;
                             var adjTagPos : TAdjucentTagPos) : boolean ;
var
 Uptag,UpcaseDoc :string ;

 ofs :integer ;
 begin
  with adjTagPos do
  begin
   result := false ;
   UpcaseDoc := AnsiUpperCase(doc);
   UPtag := UpperCase(tag);
   beforeBegin := 0;
 ofs :=0 ;
  if not nextSearch('<'+UPTag , UpcaseDoc , beforeBegin  , ofs)   then exit ;
   afterBegin  := beforebegin  ;
   dec(beforeBegin );

   nextsearch('>',UpcaseDoc, afterBegin  , ofs);
   beforeEnd  := afterBegin ;
   inc(afterBegin )  ;

   nextSearch('</'+UPTag, UpcaseDoc , beforeEnd  , ofs);
   afterEnd  := beforeEnd ;
   dec(beforeEnd );

   nextsearch('>',UpcaseDoc, afterEnd  , ofs);
   inc(afterEnd );
   result :=true;

  end;
 end;


function attributeAnalysis( doc , Tag : string; var attribute : string): tpoint ;
var
  Parser2 : TScriptParser;
  s :string;
begin
         parser2 := TScriptParser.Create( doc );
         parser2.isCKBracket := false;

         while Parser2.Token <> toEof do
         begin
           s:=parser2.TokenString;
           if  ((Parser2.TokenString[1]) ='<') then
           begin

            parser2.NextToken;

            if not boolean(strIComp( pchar(Parser2.TokenString), pchar( TAG )) )  then
            begin
               while  ((parser2.Token <> toEof) and (parser2.TokenString[1] <> '>')) do
               begin
                 if upperCase(parser2.TokenString )=upperCase( attribute ) then
                 begin
                   parser2.NextToken;
                   if parser2.TokenString='=' then
                   begin

                     parser2.NextToken;
                     if (parser2.TokenString[1]='''') or (parser2.TokenString[1]='"') then
                       parser2.NextToken ;
                     if parser2.Token = toANK then
                     begin
                       result.x  :=parser2.beginToken ;
                       result.y  :=parser2.endToken;

                       attribute := parser2.TokenString;
                       parser2.Free;
                       system.Exit;
                      // break;
                     end;
                   end;
                 end;
                 parser2.NextToken;
               end;
            end;
           end;
          parser2.NextToken;
         end;   //while
         parser2.Free;

         result.x:= 0;//
         result.y:=0;
         attribute :='';
end;

function AdjacentAttr(  Doc , TAG , Key  : string ;
                             var adjTagPos : TAdjucentTagPos) : boolean ;
var  UpcaseDoc :string;
  Pos : TAdjucentTagPos ;
  parser : TTagParser;

 ofs , i,index :integer ;
 begin
  with adjTagPos do
  begin
   result := false ;
   UpcaseDoc := AnsiUpperCase(doc);
   beforeBegin := 0; ofs :=0 ;

     parser :=TTagParser.Create(doc );
     parser.Reset;

// if not NextAdjacentTag( doc ,tag ,adjTagPos) then
  if not AdjacentTag( parser , tag , adjTagPos )  then
  begin
   adjTagPos.afterEnd :=0;
   parser.Free;
  exit;
  end;
  parser.free;
  pos := adjTagPos;

   ofs :=0 ;
   delete(UpCaseDoc , 1 , beforeBegin );
   key :=uppercase(key);
   nextSearch(Key , UpcaseDoc , beforeBegin  , ofs);
    if beforebegin  = 0 then
    begin
     adjTagPos.afterEnd :=0;
     exit;
    end;

   beforeEnd  := beforebegin  ;
   dec(beforeBegin );

    doc :=TrimLeft( UpcaseDoc);
    if doc[1] <> '=' then  exit;

    afterBegin := BeforeBegin + length(Key)+ ansipos('=' , UpcaseDoc ) ;


   nextSearch('=', UpcaseDoc , beforeEnd  , ofs);

    doc :=TrimLeft( UpcaseDoc);
    if doc[1] = '''' then
     begin
       nextSearch('''', UpcaseDoc , afterBegin  , ofs);
       nextSearch('''', UpcaseDoc , beforeEnd  , ofs);
     end
     else
         if doc[1] = '"' then
      begin
       nextSearch('"', UpcaseDoc , afterBegin  , ofs);
       nextSearch('"', UpcaseDoc , beforeEnd  , ofs);
      end
      else
        begin
         index := beforeEnd;
         i :=ansipos('>', UpcaseDoc)+index-1;
         nextSearch(' ', UpcaseDoc , beforeEnd  , ofs);
         while (index+1) = beforeEnd do
         begin
           index := beforeEnd;
           nextSearch(' ', UpcaseDoc , beforeEnd  , ofs);
         end;
           if  (i<>0)and( i < beforeEnd) then beforeEnd := i;
       end;

   afterEnd  := beforeEnd +1 ;
   dec(beforeEnd );
  if pos.afterBegin <= beforeEnd  then
  begin
   adjTagPos  := pos ;

  exit;
  end;
//   inc(afterBegin) ;
   result :=true;
  end;
 end;

function Putattr(  doc ,TAG , Key ,  Source : string ; var startPos : integer  ) : string;

 var tmpdoc : string;
  adjTagPos : TAdjucentTagPos ;
 begin  tmpDoc := Doc;
     delete(tmpdoc,1,StartPos);

     result :='';
     if  AdjacentAttr(tmpDoc , Tag ,Key ,  adjTagPos ) then
     begin
       tmpDoc := copy(Doc, 1 ,adjTagPos.afterBegin  +startPos);
       delete( doc, 1  , adjTagPos.beforeEnd + startPos +1);
       result := tmpdoc + Source + doc;

        startPos :=  adjTagPos.afterBegin + startPos;
     end
     else
      StartPos :=0;
end;

function GetATTR( doc ,TAG , Key :string ; var startPos : integer;  var succes : boolean) : string;
    var
       tmpDoc : string;
       adjTagPos : TAdjucentTagPos ;

begin

 succes :=false;
 tmpDoc :=doc;
 result := '';
  delete( tmpDoc , 1 , startPos );
 if tmpdoc='' then exit;

 if  AdjacentAttr( tmpdoc ,tag ,  Key , adjTagPos ) then
 begin
  result := Copy(Doc, adjTagPos.afterBegin + startPos+1  , (adjTagPos.beforeEnd - adjTagPos.afterBegin)+1);
  StartPos := adjTagPos.afterBegin + startPos+1 ;
 end
 else
  StartPos := StartPos+adjTagpos.afterEnd;
  if  adjTagpos.afterEnd <> 0 then succes :=true;
end;



function AdjacentURL(  Doc : string ;
                             var adjTagPos : TAdjucentTagPos) : boolean ;
var UpcaseDoc :string;

 ofs :integer ;
 begin
  with adjTagPos do
  begin
   result := false ;
   UpcaseDoc := AnsiUpperCase(doc);


   beforeBegin := 0;
   ofs :=0 ;
   nextSearch('URL(' , UpcaseDoc , beforeBegin  , ofs);
    if beforebegin  = 0 then exit ;
   beforeEnd  := beforebegin  ;
   dec(beforeBegin );

   afterBegin := BeforeBegin + 5 ;

   nextSearch(')', UpcaseDoc , beforeEnd  , ofs);
   afterEnd  := beforeEnd +1 ;
   dec(beforeEnd );


   result :=true;
  end;
 end;
//**************************************************
 //***********

 function idBySellector( sellector  : string ): string;
begin
  result := '';
  if ansiPos(  '#' , sellector ) <> 1 then exit;
  begin
    delete( sellector , 1 , 1 );
    result := sellector;
  end;
end;

function  ClassBySellector( sellector  : string ): string;
var po : integer;
begin
     result :='';
      if idBySellector( sellector ) <>'' then exit;

      po := ansipos('.',sellector );
      if po = 0 then sellector :='';
      while  po <> 0 do
      begin
        delete(sellector , 1 ,po);
        po := ansipos('.',sellector );
      end; //while  po <> 0 do
      result := sellector;

end;


function  TagBySellector( sellector  : string ): string;
var po : integer ;
begin

  result :='';
  if idBySellector( sellector ) <>'' then exit;
  RESULT := sellector;
        po := ansipos('.',sellector );
      if po>0 then
          result := AnsiUpperCase(copy(sellector , 1 , po-1 ));

end;



function Selector_Nomalization( selector :string) :string;
var tagName : string;
    i : integer;
begin
   result :='';
 //セレクタの正規化

   if selector = '' then exit ;

   //擬似セレクタの処理
   i := ansipos(':' , selector );
   if i<>0 then
   begin
    tagname  :=uppercase( copy ( selector ,1 ,i-1 ) );
    delete( selector , 1 , i-1 );
    result:= tagname + Selector;
    exit
   end;

   if (idBySellector( selector )) = '' then
   begin
    tagName := uppercase(  TagBySellector( selector ) );

    if ClassBySellector( selector ) <> '' then
      tagName := tagName + '.'+ClassBySellector( selector );
        selector := tagName;
   end;


   result := selector;
end;


function  URLbyHREF( href  : string ): string;
var po : integer ;
begin
  result :='';
//  if idBySellector( sellector ) <>'' then exit;
  RESULT := Href;
        po := ansipos('#', Href );
      if po>0 then
          result := (copy(Href  , 1 , po-1 ));

end;

function  NAMEbyHREF( HREF  : string ): string;
var po : integer;
begin
     result :='';

      po := ansipos('#',HREF );
      if po = 0 then Href :='';

        delete(HREF , 1 ,po);

      result := HREF;

end;

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




const  CGID_WebBrowser:TGUID ='{ED016940-BD5B-11cf-BA4E-00C04FD70816}';


      HTMLID_FIND         = 1;
      HTMLID_VIEWSOURCE   = 2;
      HTMLID_OPTIONS      = 3;


function ReplaceChar(src, dst: char; var s: string): Integer;
var P: PChar;
begin
  Result := 0;
  P := StrScan(PChar(s), src);
  while P <> nil do begin
    P^ := dst;
    Inc(Result);
    Inc(P);
    P := StrScan(P, src);
  end;
end;

function URLtoFile(var s: string): boolean;
const FileHead = 'file:///';
begin
  Result := LowerCase(copy(s, 1, Length(FileHead))) = FileHead;
  if Result then begin
    Delete(s, 1, Length(FileHead));
    ReplaceChar('/', '\', s);
  end;
end;


//ＵＲＬからcasheFileNameを取得する。
//CasheFileName is acquired from URL.
function  get_HTMLCashFileName(URL : string ) : string;
var
  pEntryInfo  : PInternetCacheEntryInfo;
  BufSize: CARDINAL;
  bi: bool;
  ppmem: IMalloc;

begin
    if pos('file:/', URL)<> 0 then
    begin
      URLtoFile( url );
      result := URL;
      exit;
    end;

  result :='';
  if FAILED(SHGetMalloc(ppmem)) then exit;

  // Securing of the CasheEntory　buffer
  //キャッシュバッファの確保
  BufSize:= MAX_CACHE_ENTRY_INFO_SIZE;
  pEntryInfo:= PInternetCacheEntryInfo(ppmem.Alloc(BufSize));
  pEntryInfo^.dwStructSize:= BufSize;

   bi := RetrieveUrlCacheEntryFile(pchar(url) , PEntryInfo^ , bufSize , 0);

   if bi =false then
    begin
       UnlockUrlCacheEntryFile(pchar(url) , 0);
       ppmem.free(pEntryInfo);
         exit;
    end;

  result :=pentryinfo^.lpszLocalFileName;
  UnlockUrlCacheEntryFile( pchar(url)  , 0);
  ppmem.free(pEntryInfo);

end;


procedure Register;
begin
  RegisterComponents('WWW', [TDomEvent]);

end;
constructor TDomEvent.Create(AComponent : TComponent) ;
begin
 inherited Create( AComponent );
   FDomContainers := TList.create;

end;
procedure TDomEvent.GetFrameList( FrameLists , FrameNames: TStrings  );
var doc : IHTMLDocument2;
begin
   FrameLists.Clear;
   FrameNames.clear;
   doc := FWebBrowser.document as IHTMLDocument2;
   WalkFrames( doc.parentWindow , FrameLists , Framenames );
end;

procedure TDomEvent.WalkFrames( window : IHTMLWindow2 ;
                        FrameLocations , FrameNames : TStrings  );
var i :Olevariant;

begin
  i := 0;
  FrameLocations.Add( window.location.href );
  FrameNames.Add( window.name );

  while i < window.frames.length do
  begin
    walkFrames( Idispatch(window.frames.item(i)) as IHTMLWindow2 , FrameLocations , FrameNames );
    inc(i);
  end;

end;

procedure TDomEvent.addURLFavorites( URL , Title :olevariant);
var  ShellUIHelper : IShellUIHelper;

begin
   ShellUIHelper := CreatecomObject(CLASS_ShellUIHelper) as  IShellUIHelper;
    ShellUIHelper.AddFavorite( URL , Title);

end;

procedure TDomEvent.AddFavorites;
var doc :IHTMLDocument2;
begin
  if  (FWebBrowser.ReadyState < READYSTATE_INTERACTIVE)
      then exit;
   doc := FWebBrowser.Document as IHTMLDocument2;
   addURLFavorites( doc.location.href , doc.title );
end;

procedure TDomEvent.SetUPPrinter;
var dumy:olevariant;
begin
 try
  if  (FWebBrowser.ReadyState < READYSTATE_INTERACTIVE)
      then exit;

    FWebBrowser.ExecWB(  OLECMDID_PAGESETUP,
          OLECMDEXECOPT_DODEFAULT,
               dumy,dumy);
 except
  on Eoleexception do exit;
 end;
end;

procedure TDomEvent.print( useDialog : boolean = true);
var dumy:olevariant;
   Dialog : TOLEEnum ;
begin
 if useDialog then Dialog := OLECMDEXECOPT_DODEFAULT
 else
   Dialog := OLECMDEXECOPT_DONTPROMPTUSER;

 try
  if  (FWebBrowser.ReadyState <= READYSTATE_INTERACTIVE)
      then exit;

    FWebBrowser.ExecWB(OLECMDID_PRINT,
               dialog ,
               dumy,dumy);
 except
  on Eoleexception do exit;
 end;
end;




//検索ダイアローグの表示
procedure TDomEvent.findHTMLSource;
var
    CommandTarget : IOleCommandTarget;
    d:olevariant;

begin
     if  (FWebBrowser.ReadyState < READYSTATE_INTERACTIVE)
      then exit;

    try
       if FocusDocument = nil then exit;
       CommandTarget := FocusDocument as IOleCommandTarget;
       CommandTarget.Exec(@CGID_WebBrowser,HTMLID_FIND
                 , OLECMDEXECOPT_PROMPTUSER ,d,d);
    except
    end;
end;

//インターネットオプションダイアログの表示
procedure TDomEvent.InternetOption;
var
    CommandTarget : IOleCommandTarget;
    d:olevariant;

begin
      if  (FWebBrowser.ReadyState < READYSTATE_INTERACTIVE)
      then exit;

    try
       CommandTarget := FWebBrowser.Document as IOleCommandTarget;
       CommandTarget.Exec(@CGID_WebBrowser
            , HTMLID_OPTIONS ,OLECMDEXECOPT_PROMPTUSER , d , d  );
   except
   end;
end;

//htmlソースの表示(memo)
Procedure TDomEvent.ViewSource;
var
    CommandTarget : IOleCommandTarget;
    d:olevariant;

begin
        if  (FWebBrowser.ReadyState < READYSTATE_INTERACTIVE)
      then exit;

       CommandTarget := FWebBrowser.Document as IOleCommandTarget;
       CommandTarget.Exec(@CGID_WebBrowser
           ,HTMLID_VIEWSOURCE,OLECMDEXECOPT_PROMPTUSER,d,d);
end;

procedure TDomEvent.SetDisp_WebBrowser(WebBrowser: Idispatch);
begin
//   if assigned(mobjIe) then exit;
    FWebBrowser := WebBrowser as IWebBrowser2;
//    ieEvent := TieEvent.Create( self , FWebBrowser );
    SetWebBrowser(FWebBrowser);
//      ieEvent.OnDownloadComplete := mobjIEDownloadComplete;
//     ieEvent.OnNavigateComplete2 := mobjIENavigateComplete2;

end;



procedure TDomEvent.SetWebBrowser(WebBrowser : IWebBrowser2);
var d, fl  :olevariant;
begin
    FWebBrowser := WebBrowser;
    fl:=0;  d:='';
    webbrowser.Navigate ('about:blank' ,fl , d,d,d);
    while webbrowser.document =nil do
       application.ProcessMessages;
                                                           // INTERACTIVE
    while not( (IHTMLDocument2(webbrowser.document).ReadyState ='interactive')
       or (IHTMLDocument2(webbrowser.document).ReadyState ='complete')) do
       application.ProcessMessages;
       WinFirst := true; // ie5 バグフィックス
    ieEvent := TieEvent.Create( self , WebBrowser );
      ieEvent.OnDownloadComplete := mobjIEDownloadComplete;
     ieEvent.OnNavigateComplete2 := mobjIENavigateComplete2;
end;




//*********
//*********

destructor TDomEvent.Destroy;
var i:integer;
begin
try
    i :=0;
  if  DomContainers.Count>0 then
  begin
    while  i <  DomContainers.Count do
    begin
      TDom_Event(DomContainers.items[i]).free; //<>nil) then
      inc( i );
    end;
    //IwebBrowser2のイベントシンク開放

    IeEvent.free;
  end;
finally
     domContainers.Free;
end;
    inherited Destroy;
end;



 procedure TDomEvent.winFocus(Container : TDom_Event ;fireElement : IHTMLElement );
begin
 if  not assigned( Container) then exit;
  FFocusDocument := Container.Document;
  
 if assigned(FonWinFocus) then
      FonWinFocus(Container , fireElement);
end;

procedure TDomEvent.winload(Container : TDom_Event);
begin
 if  not assigned( Container) then exit;
  FFocusDocument := Container.Document;


 if assigned(FonWinload) then
      FonWinLoad(Container);
end;

procedure TDomEvent.WinUnload(DomContainer : TDom_Event );

var
i :integer ;

begin


  if  not assigned( domContainer) then exit;

  //フォカスのあるコンテナがunloadする場合には,focusDomContainerをnilにする
  if FFocusDomContainer = DomContainer then
  begin
   FFocusDomContainer := nil ;
   FFocusDocument := nil;
  end;
   
  if assigned(FonWinUnload) then
      FonWinUnload( doMcontainer );

   i := DomContainers.IndexOf( Pointer( DomContainer ) );
   DomContainers.Delete( i );

   domcontainer.Free;


end;

procedure TDomEvent.winbeforeunload(Container : TDom_Event);
begin
 if  not assigned( Container) then exit;

 if assigned(Fonwinbeforeunload) then
      FonWinbeforeunload(Container);

end;

procedure TDomEvent.winblur(Container : TDom_Event ; fireElement : IHTMLElement );
begin
 if  not assigned( Container) then exit;
 if assigned(Fonwinblur) then
      Fonwinblur(Container , fireElement);
end;

procedure TDomEvent.winerror(Container : TDom_Event ; fireElement : IHTMLElement );
begin
 if  not assigned( Container) then exit;
 if assigned(Fonwinerror) then
      Fonwinerror(Container , fireElement);
end;

procedure TDomEvent.Winhelp(Container : TDom_Event ; fireElement : IHTMLElement );
begin
 if  not assigned( Container) then exit;
 if assigned(FonWinhelp) then
      FonWinhelp(Container , fireElement);
end;

procedure TDomEvent.winresize(Container : TDom_Event);
begin
 if  not assigned( Container) then exit;
 if assigned(Fonwinresize) then
      Fonwinresize(Container);
end;

procedure TDomEvent.winscroll(Container : TDom_Event);
begin
 if  not assigned( Container) then exit;
 if assigned(Fonwinscroll) then
      Fonwinscroll(Container);
end;



procedure TDomEvent.GetBrowsURLlist(URLList , CashURLList: Tstrings);
var i : integer;
  URL,CashURL :string;
begin
  i:=0;
  URLList.Clear;
  CashURLList.Clear;
  while i < DomContainers.Count do
  begin
    URL := TDom_event( DomContainers.Items[ i ] ).document.location.href;
    URLList.Add(url);
     CashURL:= get_HTMLCashFileName( URL ) ;

    CashURLLIst.add(CashURL);
   i:=i+1;
  end;
end;

procedure TDomEvent.GetCashURLlist(URLList , CashList : Tstrings);
var i : integer;
  URL,CashURL :string;
begin
  i:=0;
  URLList.Clear;
  CashList.Clear;
  while i < DomContainers.Count do
  begin
    URL := TDom_event( DomContainers.Items[ i ] ).document.location.href;
    URLList.Add(url);
     CashURL:= get_HTMLCashFileName( URL ) ;

    CashLIst.add(CashURL);
   i:=i+1;
  end;
end;

//*************************
function TDomEvent.GetBindInfo(out grfBINDF:
                                {$IFDEF VER120} Longint{$ELSE} DWORD {$ENDIF};
                                 var bindinfo: TBindInfo): HResult;
begin
   result := E_NOTIMPL;
end;

function TDomEvent.GetPriority(out nPriority
                              {$IFDEF VER120}: Longint{$ENDIF}): HResult;
begin
   result := E_NOTIMPL;
end;

function TDomEvent.OnDataAvailable(grfBSCF:
                                 {$IFDEF VER120} Longint{$ELSE} DWORD {$ENDIF};
                              dwSize: {$IFDEF VER120} Longint{$ELSE} DWORD {$ENDIF};
                         {$IFDEF VER120} var {$ENDIF}
                                   formatetc: {$IFDEF VER120} TFormatEtc{$ELSE} PFormatEtc {$ENDIF};
                         {$IFDEF VER120} var {$ENDIF}
                         stgmed:{$IFDEF VER120} TSTGMEDIUM {$ELSE} PStgMedium {$ENDIF} ): HResult;
begin
   result := E_NOTIMPL;
end;

function TDomEvent.OnLowResource(reserved:
                                {$IFDEF VER120} Longint{$ELSE}
                                 DWORD {$ENDIF}): HResult;

begin
   result := E_NOTIMPL;
end;

function TDomEvent.OnObjectAvailable(const iid: TGUID; {$IFDEF VER120} CONST {$ENDIF}punk: IUnknown): HResult; 

begin
   result := E_NOTIMPL;
end;

function TDomEvent.OnProgress(ulProgress, ulProgressMax, ulStatusCode:
                                {$IFDEF VER120} Longint{$ELSE}
                                 ULONG {$ENDIF} ;
                                 szStatusText:
                                 {$IFDEF VER120} PWideChar {$ELSE} LPCWSTR {$ENDIF}): HResult;
begin
   result := E_NOTIMPL;
end;

function TDomEvent.OnStartBinding(dwReserved:
                              {$IFDEF VER120} Longint{$ELSE}
                               DWORD {$ENDIF};
                                pib: IBinding): HResult;

begin
   result := E_NOTIMPL;
end;

function TDomEvent.OnStopBinding(hresult: HResult; szError:
                                 {$IFDEF VER120} PWideChar {$ELSE} LPCWSTR {$ENDIF}): HResult;
begin
   result := E_NOTIMPL;
end;

procedure TDomEvent.GetHTMLFile( URL , FileName : string);
 var status : IBindStatusCallback ;
begin
  status := IBindStatusCallback(self);
  URLDownloadToFile(nil, pChar( URL ) ,pChar( FileName ), 0 ,Status );
end;

{ TieEvent }

constructor TieEvent.Create(Aowner : Tobject ; WebBrowser: IWebbrowser2);
begin
 inherited create;
      //イベントシンクの設定
       //Setting of event sinK.
     FAowner := Aowner;
     //contenerでつくったieにイベントを結びつける
     Ie4EventSink    := TEvent_Sink.Create( IE4Event_sink );
     Ie4eventConnect :=  T_ConnectPoint.create
                  (
                    GUID_IE4EventGUID , IE4Eventsink as IUnKnown
                    ,IUnKnown( WebBrowser )
                   );

 end;

destructor TieEvent.destroy;
begin
      //IwebBrowser2のイベントシンク開放
      Ie4EventConnect.Free;
      inherited destroy;
end;
//**************ディスパッチテーブル
procedure TieEvent.IE4Event_sink(Disp_ID: Integer; var Params);
//ie4のイベントシンク
type      PVarDataList = ^TVarDataList;
  TVarDataList = array[0..3] of TVarData;

var s :string;
   v: olevariant;

     Args: PVarDataList;
  begin
      // arg：引数のリスト
      Arg:=TDispParams(Params);
             //イベントの種類は、DispIDで指定。
     //exit;
      case Disp_ID of
      102:  if assigned(onStatusTextChange) then
               onStatusTextChange(FAowner,widestring(OleVariant(Arg.rgvarg[0])));

      108:  if (assigned(OnProgressChange)) then
               OnProgressChange(FAowner
                           , integer(Olevariant(Arg.rgvarg[1]))
                           , integer(Olevariant(Arg.rgvarg[0])));
      105:  if (assigned(OnCommandStateChange)) then
                OnCommandStateChange(FAowner
                           , integer(Olevariant(Arg.rgvarg[1]))
                           , Wordbool(OleVariant(Arg.rgvarg[0])));
      106:  if (assigned(OnDownloadBegin)) then
                OnDownloadBegin(FAOwner);
      104:  if assigned(onDownloadComplete) then
                OnDownloadComplete(FAOwner);


      113:  if assigned(onTitleChange) then
                OnTitleChange(FAowner
                            , widestring(OleVariant(Arg.rgvarg[0])));
                //(const Text: WideString);
      112:   if assigned(onPropertyChange) then
                 OnPropertyChange(FAowner
                            , widestring(OleVariant(Arg.rgvarg[0])));
                //(const szProperty: WideString); dispid 112;


      250 : if  assigned(onBeforeNavigate2) then
             begin

                vURL             := OleVariant(Arg.rgvarg[5]);

                vFlag            := OleVariant(Arg.rgvarg[4]);
                vTargetFrameName := OleVariant(Arg.rgvarg[3]);
                 try
                //  vPostData      := OleVariant(Arg.rgvarg[2]);
                 except
                  vPostData := unassigned;
                 end;
                 try
                  vHeaders       := OleVariant(Arg.rgvarg[1]);
                 except
                  vHeaders  := unAssigned;
                 end;
                cancel           := WordBool(OleVariant(Arg.rgvarg[0]));

                OnBeforeNavigate2(FAowner
                            , IDispatch(OleVariant(Arg.rgvarg[6]))
                            , vURL
                            , vFlag
                            , vTargetFrameName
                            , vPostData
                            , vHeaders
                            , Cancel);
                OleVariant(Arg.rgvarg[5]) := OleVariant(vURL);
                OleVariant(Arg.rgvarg[4]) := OleVariant(vFlag);
                OleVariant(Arg.rgvarg[3]) := OleVariant(vTargetFrameName);
                OleVariant(Arg.rgvarg[2]) := OleVariant(vPostData);
                OleVariant(Arg.rgvarg[1]) := OleVariant(vHeaders );
                OleVariant(Arg.rgvarg[0]) := OleVariant(Cancel);

                //(pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData, Headers: OleVariant; var Cancel: WordBool); dispid 250;
            end;

      251: if assigned(onNewWindow2) then
            begin
                ppDisp := IDispatch(OleVariant(Arg.rgvarg[1]));
                Cancel := WordBool(OleVariant(Arg.rgvarg[0]));

                  onNewWindow2(Faowner , ppDisp ,Cancel);

                OleVariant(Arg.rgvarg[1]) := OleVariant(ppDisp);
                OleVariant(Arg.rgvarg[0]) := OleVariant(Cancel);

               //(var ppDisp: IDispatch; var Cancel: WordBool); dispid 251;
            end;

      //原因不明イベント後にargのポインターが書き換えられる(D6以降）
      //対処として別のポインタargsを使う

      252:if assigned(onNavigateComplete2) then
           begin
             Args := PVarDataList(arg.rgvarg);
               vURL :=  OleVariant(Arg.rgvarg[0]);


               OnNavigateComplete2(Faowner
                            , IDispatch(OleVariant(Arg.rgvarg^[1]))
                            , vURL);
               oleVariant(Args^[0]) := vURL;

               //(pDisp: IDispatch; var URL: OleVariant); dispid 252;
           end;

      259:if assigned(onDocumentComplete) then
           begin
               vURL := OleVariant(Arg.rgvarg[0]);
               OnDocumentComplete(Faowner
                            , IDispatch(OleVariant(Arg.rgvarg[1]))
                            , vURL);
               OleVariant(Arg.rgvarg[0]) := vURL;
               //(pDisp: IDispatch; var URL: OleVariant); dispid 259;
           end;
      253:begin



             if assigned(OnQuit) then
                    OnQuit(FAOwner);
             self.destroy;
             self :=nil;
          end;

      254:if assigned(OnVisible) then
             Begin
                OnVisible(Faowner , WordBool(OleVariant(Arg.rgvarg[0])) );
      //Visible: WordBool); dispid 254;
             end;

      255:if assigned(OnToolBar) then
             begin
                OnToolBar(Faowner , WordBool(OleVariant(Arg.rgvarg[0])));
       //(ToolBar: WordBool); dispid 255;
             end;

      256:if assigned(OnMenuBar) then
             begin

                OnMenuBar(Faowner , WordBool(OleVariant(Arg.rgvarg[0])));
      //(MenuBar: WordBool); dispid 256;
             end;

      257:if assigned(OnStatusBar) then
            begin

                OnStatusBar(Faowner ,WordBool(OleVariant(Arg.rgvarg[0])));
            end;
      //(StatusBar: WordBool); dispid 257;

      258:if assigned(OnFullScreen) then
            begin
                OnFullScreen(Faowner , WordBool(OleVariant(Arg.rgvarg[0])));
            end;
      //(FullScreen: WordBool); dispid 258;

      260:if assigned(OnTheaterMode) then
            begin
                OnTheaterMode(Faowner , WordBool(OleVariant(Arg.rgvarg[0])));
            end;
      //(TheaterMode: WordBool); dispid 260;


  //  : ;
     end;

 end;


procedure TDomEvent.mobjIEDownloadComplete(Sender : Tobject);
var
    doc : IHtMLDocument2;
 i: integer;
 domContainer : TDom_Event;

begin
try
   //webBrowserオブジェクトのDocumentをえる
   doc :=FWebbrowser.document as IHTMLDocument2;

   //まだ、documentが使用不可ならリターン
   if doc = nil then exit;
   if  doc.readyState = 'loading'  then exit;

   //トップレベルのドキュメントを保存
                self._setDocument( doc );

  //フレームのコンテンツでなく、まだオブジェクトに登録されていなければ
  //DomContainersオブジェクトに登録
  //*インラインフレームのコンテンツは保存
 //              if (doc.frames.length<>0) and (doc.parentWindow.frames.length <> 0) then exit;
if (doc.all.tags('FRAMESET') as IHTMLElementCollection).length  <> 0 then  exit;
               i:=0;
               while i < DomContainers.Count do
               begin
                 if TDom_Event( DomContainers.Items[ i ]).Document = doc then exit ;
                 inc(i);
               end;


              DomContainer := TDom_Event.Create ;
              DomContainer.SetDocument( doc, self );

              DomContainers.Add( pointer( DomContainer ) );
              //フォーカスのあるオブジェクトとして登録
              FFocusDomContainer := DomContainer ;
              DomContainer.Setfocus;
except
end;
end;

procedure TDomEvent.mobjIENavigateComplete2(Sender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
var doc , doc2 :IHTMLdocument2;
    i: integer;
    web :IWebBrowser2 ;
    DomContainer : TDom_event;
begin

 i:=0;
 web :=pdisp as IWebBrowser2 ;
try
 doc :=web.document as IHTMLDocument2;

 //Documentがnilかどうかをテストするのは重要！！
      if Doc = nil then
      exit;

  doc2 := FWebBrowser.document as IHTMLDocument2;
  if Document <> doc2 then
      self._setDocument( doc2  );

 //フレームセットのクライアントのときは、parentWindowのイベントを結びつけない。
 //*インラインフレームは、保存

 if (doc.all.tags('FRAMESET') as IHTMLElementCollection).length  <> 0 then  exit;

  while i < DomContainers.Count do
  begin
     if TDom_Event(DomContainers.Items[ i ]).Document = doc then exit ;
     inc(i);
  end;

 //生成されるすべてのウインドウにparentWindowのイベントを結びつける
  //Event of parentWindow is connected to all the windows that are generated .

         DomContainer := TDom_Event.Create ;
         DomContainer.SetDocument( doc,self );

         DomContainers.Add( pointer( DomContainer ) );
         FFocusDomContainer := DomContainer ;
         DomContainer.Setfocus;
except
end;
end;


//エラーコードは、IDM_Resultに代入される。
//The error cord is substituted to IDM_Result.
function TDom_Event.Exec_IDMCommand( CmdGUID : TGUID;
                  IDM_cmd : cardinal;
                  const pVarIn : OleVariant;
                  dwCmdOpt : cardinal
                   ) : Olevariant ;
var pVarOut : olevariant ;
begin
try
   IDM_Result := E_Fail;
   if (Not Assigned(CommandTarget)) then
   begin
       raise EOleException.Create('UIWebBrowserの準備がすんでいません',IDM_Result,'','',0);

      Exit;
   end;

     if  not queryUsed_IDM(  CmdGUID , IDM_cmd ) then
      begin
       raise EOleException.Create(inttostr( IDM_cmd )+' コマンドをサポートしていません',IDM_Result,'','',0);

      Exit;
      end;




     IDM_Result := CommandTarget.Exec(@CmdGUID , IDM_CMD ,
							dwCmdOpt,
							pVarIn,
							pVarOut);
     result := pVarOut;
     if IDM_Result<> S_OK then
        raise EOleException.Create(inttostr( IDM_cmd )+' UIWebBrowserコマンドエラー',IDM_Result,'','',0);
except
  raise;
end;
end;

function TDom_Event.Exec_IDMCommand( CmdGUID : TGUID;
                  IDM_cmd : cardinal;
                  dwCmdOpt : cardinal
                   ) : Olevariant ;
var pVarin : olevariant;
begin
    pVarin :=null;
    result := Exec_IDMCommand( cmdGUID ,IDM_Cmd , pVarIn , dwCmdOpt );
end;




function TDom_Event.Exec_IDMCommand(        IDM_cmd : cardinal;
                                       const pVarIn : OleVariant;
                                             dwCmdOpt : cardinal
          ) : Olevariant ;
begin
  result := Exec_IDMCommand( CMDSETID_Forms3 ,IDM_Cmd , pVarIn , dwCmdOpt );
end;

function TDom_Event.Exec_IDMCommand( IDM_cmd : cardinal;
                          dwCmdOpt : cardinal
         ) : Olevariant ;
var pVarin : olevariant ;
begin
  pVarin := '';
  Exec_IDMCommand( CMDSETID_Forms3 ,IDM_Cmd , pVarIn , dwCmdOpt );
end;

function TDom_Event.GetTitleElement: IHTMLTitleElement ;
var
 // title : IHTMLTitleElement;
  HTMLCollection : ihtmlelementcollection;
begin

           HTMLCollection := (document.all.tags('TITLE')) as ihtmlelementcollection;
           result :=HTMLCollection.item(0,0) as IHTMLTitleElement;;
end;

//*******HTMLのタイトルを得る
function TDom_event.GetTitle : String;
var
  title : IHTMLTitleElement;
begin
  title :=  GetTitleElement ;
  result := title.text;
end;






//ドキュメントをセットする documentプロパティの書き込み
procedure TDom_Event.SetDocument(Document : IDispatch; AOwner : TObject);
var doc :IHTMLDocument2;
begin
     doc := Document as IHTMLDocument2;
     FOwner := AOWner ;

     _setDocument( doc);
     isDestroy := false;


     //イベントシンクの設定




     DocumentEventSink := TEvent_Sink.Create(DocumentEvent_sink );
       DocumenteventConnect :=  T_ConnectPoint.create(
                    GUID_DocumentEvent,DocumentEventsink as IUnKnown,doc);


     WindowEventSink := TEvent_Sink.Create(WindowEvent_sink );

      WindoweventConnect :=  T_ConnectPoint.create(
                    DIID_HTMLWindowEvents ,WindowEventsink as IUnKnown
                    ,doc.parentWindow);




end;

constructor TDom_Event.create;
var compo : TComponent;
begin
   compo :=nil;
   create( compo );
end;

destructor TDom_Event.destroy;
begin
//イベントハンドラの解放
  FDocument :=nil;
  isDestroy := true;
  if assigned(DocumenteventConnect) then
     DocumenteventConnect.free;
  if assigned(WindowEventConnect) then
     WindowEventConnect.free;
 //DocumenteventConectが開放されれば、eventSinkも開放される
//If DocumenteventConect is opened even eventSink is opened .
  inherited destroy;

end;



//******イベント



procedure TDom_Event.ProcessingKey(Var VirtualKey: word; var ShiftStates: TShiftState);
begin
  ShiftStates := [];
  VirtualKey := Document.parentWindow.event.KeyCode;

//  VirtualKey := VkKeyScan(Chr(Key));
//  VirtualKey := WordRec(VirtualKey).Lo;

	if Document.parentWindow.event.shiftKey then
  	Include(ShiftStates, ssShift);

	if Document.parentWindow.event.altKey then
  	Include(ShiftStates, ssAlt);

	if Document.parentWindow.event.CtrlKey then
  	  Include(ShiftStates, ssCtrl);

end;


procedure TDom_Event.ProcessingMouse(var VirtualKey: word;var  Button :integer ;
              var ShiftStates: TShiftState );

begin
  ShiftStates := [];
    VirtualKey := Document.parentWindow.event.KeyCode;

  Button := Document.parentWindow.event.button;
	if Document.parentWindow.event.shiftKey then
  	Include(ShiftStates, ssShift);

	if Document.parentWindow.event.altKey then
  	Include(ShiftStates, ssAlt);

	if Document.parentWindow.event.CtrlKey then
  	  Include(ShiftStates, ssCtrl);

end;


procedure TDom_Event.DocKeyPress;
var
  ShiftStates: TShiftState;
  virtualKey :word;
  EventElement : IHTMLElement;
  DomEvent : TdomEvent;
begin
  DomEvent := FOwner as TDomEvent;
  EventElement:= Document.parentWindow.event.srcElement;
  DomEvent.FEventElement:=EventElement;


        if assigned(DomEvent.onDocKeyPress) then
        begin
           processingKey( virtualKey , ShiftStates);
               DomEvent.onDocKeyPress(  Self
                  , VirtualKey , ShiftStates , EventElement );
        end;

 end;

procedure TDom_Event.dockeyDown;
var
  ShiftStates: TShiftState;
  virtualKey :word;
  eventElement : IHTMLElement;
  DomEvent : TdomEvent;
begin
  EventElement := Document.parentWindow.event.srcElement;
  DomEvent :=FOwner as TDomEvent;
  DomEvent.FEventElement := EventElement;
  MouseDownEventElement := DomEvent.FEventElement;
   DomEvent.FEditElement := EventElement;

        if assigned(DomEvent.onDocKeyDown) then
        begin
           processingKey( virtualKey , ShiftStates);
               DomEvent.onDocKeyDown(  Self  , VirtualKey
               , ShiftStates , EventElement );
        end;

end;

procedure TDom_Event.DocKeyUp;
var

  ShiftStates: TShiftState;
 VirtualKey: Word;
  DomEvent : TdomEvent;
begin
  DomEvent := FOwner as TDomEvent;

  DomEvent.FEventElement := Document.parentWindow.event.srcElement;


        if assigned(DomEvent.onDocKeyPress) then
        begin
           processingKey( virtualKey , ShiftStates);
               DomEvent.onDocKeyUP(  Self  , VirtualKey , ShiftStates
               ,DomEvent.EventElement );
        end;

end;

procedure TDom_Event.DocMouseDown;
var
  VirtualKey: Word;
  Button :integer;
  ShiftStates: TShiftState;
  DomEvent : TdomEvent;
begin
  DomEvent := FOwner as TDomEvent;
  domevent.FFocusDocument := self.Document;
  domevent.FFocusDomContainer := self;
  
  DomEvent.FEventElement := Document.parentWindow.event.srcElement;
  MouseDownEventElement := DomEvent.FEventElement;
  MousePoint := MouseCoordinate;
//  domevent.winFocus( self , DomEvent.FEventElement );


        if assigned(DomEvent.onDocMouseDown) then
        begin
           processingMouse( virtualKey , button, ShiftStates);
               DomEvent.onDocMouseDown(  Self  ,TPoint(MousePoint)
               , button , ShiftStates , DomEvent.EventElement );
        end;

end;

procedure TDom_Event.DocMouseUP;
var
  Button :integer;
  ShiftStates: TShiftState;
   VirtualKey: Word;
  DomEvent : TdomEvent;
begin
  DomEvent := FOwner as TDomEvent;

  DomEvent.FEventElement := Document.parentWindow.event.srcElement;
  MousePoint := MouseCoordinate;

        if assigned(DomEvent.onDocMouseUp) then
        begin
           processingMouse( virtualKey , Button, ShiftStates);
               DomEvent.onDocMouseUP(  Self  ,TPoint(MousePoint)
               , button , ShiftStates , DomEvent.EventElement );
        end;

end;

procedure TDom_Event.DocClick;
var
  Button :integer;
  ShiftStates: TShiftState;
   VirtualKey: Word;
  DomEvent : TdomEvent;
begin

  DomEvent := FOwner as TDomEvent;

  DomEvent.FEventElement := Document.parentWindow.event.srcElement;
  MouseDownEventElement := DomEvent.FEventElement;
  MousePoint := MouseCoordinate;

        if assigned(DomEvent.onDocClick) then
        begin
           processingMouse( virtualKey , Button, ShiftStates);
               DomEvent.onDocClick(  Self  ,TPoint(MousePoint) , button
               , ShiftStates , DomEvent.EventElement );
        end;

end;
procedure TDom_Event.DocDblclick;
var
  Button :integer;
  ShiftStates: TShiftState;
   VirtualKey: Word;
  DomEvent : TdomEvent;
begin
  DomEvent := FOwner as TDomEvent;

  DomEvent.FEventElement := Document.parentWindow.event.srcElement;
  MousePoint := MouseCoordinate;

        if assigned(DomEvent.onDocDblclick) then
        begin
           processingMouse( virtualKey , Button, ShiftStates);
               DomEvent.onDocDblclick(  Self  ,TPoint(MousePoint)
               , button , ShiftStates , DomEvent.EventElement );
        end;
end;

procedure TDom_Event.DocDragstart;
var
  Button :integer;
  ShiftStates: TShiftState;
   VirtualKey: Word;
  DomEvent : TdomEvent;
begin
  DomEvent := FOwner as TDomEvent;

  DomEvent.FEventElement := Document.parentWindow.event.srcElement;
  MousePoint := MouseCoordinate;

        if assigned(DomEvent.onDocDragstart) then
        begin
           processingMouse( virtualKey , Button, ShiftStates);
               DomEvent.onDocDragstart(  Self  ,TPoint(MousePoint)
               , button , ShiftStates , DomEvent.EventElement );
        end;
end;

procedure TDom_Event.DocMousemove;
var
  Button :integer;
  ShiftStates: TShiftState;
   VirtualKey: Word;
  DomEvent : TdomEvent;
begin
  DomEvent := FOwner as TDomEvent;

  DomEvent.FEventElement := Document.parentWindow.event.srcElement;
  MousePoint := MouseCoordinate;

        if assigned(DomEvent.onDocMousemove) then
        begin
           processingMouse( virtualKey , Button, ShiftStates);
               DomEvent.onDocMousemove(  Self  ,TPoint(MousePoint)
                 , button , ShiftStates , DomEvent.FEventElement );
        end;
end;
procedure TDom_Event.DocMouseOut;
var
  Button :integer;
  ShiftStates: TShiftState;
   VirtualKey: Word;
  DomEvent : TdomEvent;
  eventElement :IHTMLElement;
begin

  DomEvent := FOwner as TDomEvent;
  EventElement := Document.parentWindow.event.srcElement;
  DomEvent.FEventElement := Eventelement ;
  MousePoint := MouseCoordinate;

        if assigned(DomEvent.onDocMouseout) then
        begin
           processingMouse( virtualKey , Button, ShiftStates);
               DomEvent.onDocMouseout(  Self  ,TPoint(MousePoint) , button , ShiftStates , EventElement );
        end;
end;

procedure TDom_Event.DocMouseover;
var
  Button :integer;
  ShiftStates: TShiftState;
   VirtualKey: Word;
  DomEvent : TdomEvent;
  eventElement :IHTMLElement;
begin
  DomEvent := FOwner as TDomEvent;
  EventElement := Document.parentWindow.event.srcElement;
  DomEvent.FEventElement := Eventelement ;
  MousePoint := MouseCoordinate;

        if assigned(DomEvent.onDocMouseover) then
        begin
           processingMouse( virtualKey , Button, ShiftStates);
               DomEvent.onDocMouseover(  Self  ,TPoint(MousePoint) , button , ShiftStates , EventElement );
        end;
end;

procedure TDom_Event.DocReadystatechange;
var state : WideString;
   States : tagREADYSTATE;
  DomEvent : TdomEvent;
begin
  if FOwner =nil then exit;
  DomEvent := FOwner as TDomEvent;
  DomEvent.FEventElement := self.Document.parentWindow.event.srcElement;
 if not assigned( DomEvent.onDocReadystatechange) then
 exit ;
  states :=READYSTATE_UNINITIALIZED;
  state :=self.document.readyState;
  if  state = 'uninitialized' then states := READYSTATE_UNINITIALIZED
  else
    if  state = 'loading'       then states := READYSTATE_LOADING
     else
       if  state = 'loaded'        then states := READYSTATE_LOADED
       else
       if  state = 'interactive'   then states := READYSTATE_INTERACTIVE
        else
        if  state = 'complete'      then states := READYSTATE_COMPLETE;

  DomEvent.onDocReadystatechange( Self , states ,DomEvent.EventElement);
end;

procedure TDom_Event.DocSelectstart;
var
  Button :integer;
  ShiftStates: TShiftState;
   VirtualKey: Word;
  DomEvent : TdomEvent;
begin
  DomEvent := FOwner as TDomEvent;
  DomEvent.FEventElement := Document.parentWindow.event.srcElement;
  MousePoint := MouseCoordinate;

        if assigned(TDomEvent(FOwner).onDocSelectstart) then
        begin
           processingMouse( virtualKey , Button, ShiftStates);
               DomEvent.onDocSelectstart(  Self  ,TPoint(MousePoint)
                  , button , ShiftStates , DomEvent.EventElement );
        end;
end;


procedure TDom_Event.DocumentEvent_sink(Disp_ID: Integer; var Params);

//**************ディスパッチテーブル
begin

if isDestroy or ( Document = nil ) then
begin
exit;
end;
      // arg：引数のリスト
//      Arg:=TDispParams(Params);
             //イベントの種類は、DispIDで指定。

         case Disp_Id  of
          -600      :  DocClick ;
          -601      :  DocDblclick ;
          -606      :  DocMousemove;
      -2147418103   :  Docmouseout;

          -2147418104 : DocMouseover;
          -609        : DocReadystatechange;
          -2147418101 : DocDragstart;
          -2147418100 : DocSelectstart;
          -602:  DockeyDown ;
          -603:  DocKeyPress ;

          -604:  DocKeyup ;
          -605:  DocMouseDown;
          -607:  DocMouseUp ;
         end; //case Disp
end;


function TDom_Event.MouseCoordinate: TPoint;
begin
  //result := nil;
  if assigned( document ) then
   begin
    result.X := Document.parentWindow.event.clientX;
    Result.Y := Document.parentWindow.event.clientY;
   end;                   
end;
procedure TDom_Event.WindowEvent_Sink(Disp_ID: integer; var Params);
var       Arg:TDispParams;
//**************ディスパッチテーブル
begin

if isDestroy or ( self.document = nil ) then
begin
  exit;
end;
      // arg：引数のリスト
      Arg:=TDispParams(Params);
             //イベントの種類は、DispIDで指定。

   with TDomEvent(FOwner) do
   begin
      case Disp_Id of
      -2147418111:
            begin
               FFocusDomContainer := Self ;
                winFocus( self , self.document.parentWindow.event.srcElement) ;
            end;

            1008:  WinUnload( self );
            1003:  winload( self );
    -2147418102 : winhelp( self , self.document.parentWindow.event.srcElement);

    -2147418112 :
                 begin
                  if (not isDestroy) and (self.document <> nil ) then
                   winblur( self , self.document.parentWindow.event.srcElement);
                 end;
    -2147412083 : winerror( self , nil ); //self.document.parentWindow.event.srcElement);
    1016 : winresize( self );
    1014 : winscroll( self );
    1017 : winbeforeunload( self );
      end;
    end;
end;

function TDom_Event.GetCommandStatus( CmdGUID : TGUID;
                                      IDM_cmd: Cardinal    ): DHTMLEDITCMDF;
var
   MsoCmd : TOleCmd;
begin
   result := 0;
   if (Not Assigned(CommandTarget)) then
      Exit;

   MsoCmd.CmdID := IDM_cmd;
   MsoCmd.cmdf := 0;
   CommandTarget.QueryStatus(@CmdGUID, 1, @MsoCmd, nil);

   result := MsoCmd.cmdf;
end;

function TDom_Event.GetCommandStatus( IDM_cmd: Cardinal    ): DHTMLEDITCMDF;
begin
   result := GetCommandStatus( CMDSETID_Forms3 , IDM_cmd  );
end;

function TDom_Event.queryUsed_IDM( IDM_cmd : Cardinal ) : boolean;
var
   dwStatus : DWORD;
begin
   dwStatus := GetCommandStatus(IDM_cmd );
   REsult := ((dwStatus and OLECMDF_ENABLED) <> 0);
end;


function TDom_Event.queryUsed_IDM(  CmdGUID : TGUID; IDM_cmd : Cardinal ) : boolean;
var
   dwStatus : DWORD;
begin
   dwStatus := GetCommandStatus(cmdGUID , IDM_cmd );
   result := ((dwStatus and OLECMDF_ENABLED) <> 0);
end;

function TDom_Event.GetFrameCollection: IHTMLFramesCollection2;
begin
  result := document.parentWindow.frames;
end;

procedure TDom_Event.GetFrameList( FrameLists , FrameNames: TStrings  );
begin
//   FrameLists.Clear;
//   FrameNames.clear;
   WalkFrames( document.parentWindow , FrameLists , Framenames );
end;

procedure TDom_Event.WalkFrames( window : IHTMLWindow2 ;
                        FrameLocations , FrameNames : TStrings  );
var i :Olevariant;

begin
  i := 0;
  FrameLocations.Add( window.location.href );
  FrameNames.Add( window.name );

  while i < window.frames.length do
  begin
    walkFrames( Idispatch(window.frames.item(i)) as IHTMLWindow2 , FrameLocations , FrameNames );
    inc(i);
  end;

end;





function TDom_Event.GetDocumentSource: string;
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

procedure TDom_Event.SetDocumentSource(HTMLCode  : string);
begin

              LoadFromStrings( document , HTMLCode );
end;

procedure TDom_Event.LoadDocumentSource(FileName: WideString);
var
  pPStm :  IPersistFile;
begin
  pPStm := document  as  IPersistFile;
  pPstm.load(PwideChar(Filename) , 0);   //( pInputStream );
end;



{ TDomLibs }

procedure TDomLibs._setDocument(Document: IHTMLDocument2);
begin
   FDocument := Document;
   CommandTarget := Document as IOleCommandTarget;


end;

procedure TDOMLibs.getTagSelectClassNameList( classes : TStrings ; TagName :string);
var rules : IHTMLStyleSheetRulesCollection;
i  :integer;
styleSheets : IHTMLStyleSheetsCollection;
StyleSheet: IHTMLStyleSheet;
selector  : string;
ov : olevariant;
begin
  styleSheets := GetStyleSheets;
  ov := 0 ;
  while ov < styleSheets.length do
  begin
   styleSheet := IDispatch(styleSheets.item( ov )) as IHTMLStyleSheet;
   rules := StyleSheet.rules;

      //itemのナンバーが大きいほどCSSの優先順位が高い
    i:=0;
    while i<rules.length do
    begin
      selector := (rules.item(i).selectorText);
        if AnsiUpperCase(TagBySellector( selector ) )  = tagName then
        begin
          selector := classBySellector( selector );
          if   selector <>''  then
            classes.Add( selector );
        //end;
      end; //if AnsiUpperCase(TagBySellector( selector ) )  = tag then
          inc(i);
    end;   //while i<rules.length do
       ov := ov+1;
  end;  //while ov < styleSheets.length do

end;

function TDOMLibs.findRule(Selector :String;StyleSheet: IHTMLStyleSheet): IHTMLRuleStyle;
var rules : IHTMLStyleSheetRulesCollection;
i :integer;
begin
   rules := StyleSheet.rules;
 //itemのナンバーが大きいほどCSSの優先順位が高い
  i:=0;
  while i<rules.length do
  begin
  if (rules.item(i).selectorText=Selector) then
  begin
   result := rules.item(i).style;
   exit;
  end;
  inc(i);
  end;
  result := nil;
end;

//スタイルシートに付けたtitleでスタイルシートを検索する。

function TDOMLibs.findStyleSheet(StyleSheetTitle: string): IHTMLStyleSheet;
var ov_Sheets :Olevariant;
    i         :integer;
begin
 ov_sheets := GetStyleSheets;
 i:=0;

 while i<ov_sheets.length do
 begin
  if ov_sheets.item(i).title = StyleSheetTitle then
  begin
    result :=IDispatch(ov_sheets.item(i)) as IHTMLStyleSheet;
    exit
  end;
   inc(i);
 end;
result := nil;
end;

//スタイルシートのコレクションを得る
function TDOMLibs.GetStyleSheets : IHTMLStyleSheetsCollection ;
begin

    Result := document.styleSheets ;
end;

//スタイルシートを得る。
function TDOMLibs.GetStyleSheet(ovNameindex : OLevariant) :IHTMLStyleSheet ;

begin

  Result := IHTMLStyleSheet(IDispatch(document.styleSheets.item(ovNameindex)))  ;
end;


//スタイルエレメントを得る
function TDOMLibs.GetStyleElement(ovNameindex : OLevariant) : IHTMLStyleElement ;
begin

  Result := IHTMLStyleElement(IDispatch(document.styleSheets.item(ovNameindex)) ) ;
end;

function TDOMLibs.findRuleInStyleSheets( Selector :string ) : IHTMLRuleStyle;
var index : integer;
begin
   result :=nil;
   if getStyleSheets.length <= 0 then
   begin
       //スタイルシートがない場合
     exit;
   end;

     index := document.styleSheets.length;
     while( (index>0) and (not assigned(result)) )do
     begin
       dec( index);
       result :=self.findRule( Selector , GetStyleSheet( Index ));
    end;

end;

function TDOMLibs.SetStyleRule(Selector :string; StyleSheet : IHTMLStyleSheet ) : IHTMLRuleStyle;
var
    ruleIndex : integer;
    rule : IHTMLRuleStyle;
begin
{ //設定するセレクタ
 Selector := 'BODY';
 //スタイルシートの指定。
 SheetIndex :=0;
}
   RuleIndex := -1;
   if getStyleSheets.length > 0 then
   begin
    repeat
     rule := getStyleRoulBySelector(StyleSheet,Selector , ruleIndex );
     { if assigned(rule) then
        //＊＊スタイルの属性が存在するかどうかチェックする
        s := rule.background;
      }
    until( assigned( rule ) or  (ruleIndex < 0 ));
   end
   else
          //スタイルシートがない場合
      document.createStyleSheet(Selector+'{display:}',0);


  try
    if ruleIndex < 0 then
    begin
      //指定したセレクタがない
      RuleIndex := styleSheet.rules.length;
      stylesheet.addRule(Selector,'display: ',RuleIndex);
      inc(ruleIndex);// :=-1;
      rule := getStyleRoulBySelector( StyleSheet ,Selector, ruleIndex );
    end;
        RUle.display :='';

  result :=rule;
  except
   raise EOleException.Create('セレクタの入力が間違っています。',0,'','',0);

   result := nil;
  end;
 end;

function TDOMLibs.SetStyleRule(Selector :string; SheetIndex :integer) : IHTMLRuleStyle;

var
    ruleIndex : integer;
    styleSheet : IHTMLStyleSheet;
    ov_StyleSheet : Olevariant;
    rule : IHTMLRuleStyle;
begin
{ //設定するセレクタ
 Selector := 'BODY';
 //スタイルシートの指定。
 SheetIndex :=0;
}
   RuleIndex := -1;
   if getStyleSheets.length > 0 then
   begin
    repeat
     rule := getStyleRoulBySelector(GetStyleSheet( SheetIndex ),Selector , ruleIndex );
     { if assigned(rule) then
        //＊＊スタイルの属性が存在するかどうかチェックする
        s := rule.background;
      }
    until( assigned( rule ) or  (ruleIndex < 0 ));
   end
   else
          //スタイルシートがない場合
      document.createStyleSheet(Selector+'{display:}',0);



    if ruleIndex < 0 then
    begin
      //指定したセレクタがない
      stylesheet := GetStyleSheet( SheetIndex ) ;
      ov_styleSheet :=Olevariant( StyleSheet as IDispatch);
      RuleIndex := ov_styleSheet.rules.length;
      ov_stylesheet.addRule(Selector,'display:',RuleIndex);
      inc(ruleIndex);// :=-1;
      rule := getStyleRoulBySelector(GetStyleSheet( SheetIndex ),Selector, ruleIndex );
    end;

  result :=rule;
 end;


function TDOMLibs.getStyleRoulBySelector( StyleSheet : IHTMLStyleSheet ;
                    Selector : WideString; var index :integer):IHTMLRuleStyle;
var rules :IHTMLStyleSheetRulesCollection;
    i,len : integer;
begin
 Rules := StyleSheet.rules ;
  len:=Rules.length ;
  result :=nil;
  if index<0 then
      i := len
  else
      i:= index;

 if len<i  then
 begin
   index:=-1;
   result:=nil;
   exit
 end;

 while   (i>0) and ( not assigned(result))  do
 begin
    dec( i );

 //itemのナンバーが大きいほどCSSの優先順位が高い
  if (rules.item(i).selectorText=Selector) then
   result := rules.item(i).style;
 end;
 if  (i=0) and not(assigned(result)) then
   i:=-1;
 index := i;
end;

function TDOMLibs.WriteAbsoluteURL( RelativeDoc : string) : string;
var URL,header : string;
   startPos1 , startPos2 : integer ;
begin
  header := getInnerHTML( Relativedoc , 'HEAD' );

 startPos1 := 0;
 startPos2 := 0;
 URL := GetfromSynthesisURL( Header , Startpos1);

 while URL<>'' do
 begin
  url := ExpandFileName(  slashtoYen(URL) );
  Header := PutfromSynthesisURL( Header , YenToSlash( url ), StartPos2 );
  URL := GetfromSynthesisURL( Header , Startpos1);
 end;

   result := PUtInnerHTML( RelativeDoc ,'HEAD' , Header );

end;





////////////////

procedure TDOMLibs.GetStyleSheetLinkList( LinKURLs  : TStrings  );
begin
    WalkStyleSheetLink( document.styleSheets , LinkURLs );

end;


procedure TDOMLibs.WalkStyleSheetLink( StyleSheets  : OleVariant ;
                        LinKURLs  : TStrings  );
var i :Olevariant;
    stylesheet : IHTMLStyleSheet;
    url :string;
begin
  i := 0;
   if s_OK =  IDispatch(StyleSheets).QueryInterface( IHTMLStyleSheet , stylesheet ) then
    begin
     styleSheet :=Idispatch(styleSheets ) as IHTMLStyleSheet;
     URL := styleSheet.href ;
     if URL <> '' then
       LinkURLs.Add( URL  );
     exit;
    end;

  while i < styleSheets.length do
  begin
    WalkStyleSheetLink( styleSheets.item(i) , LinkURLs );
    inc(i);
  end;

end;

function isLinkElementWithHREF( StyleSheets  : OleVariant  ) : boolean;
var st : olevariant;
begin
  result := false;
  st :=styleSheets.owningElement;
  if (st.tagName = 'LINK')   then
     if (pos( '{' , st.href)  = 0 ) then
        if uppercase(st.rel)='STYLESHEET'  then
          result := true;



end;
procedure TDOMLibs.WalkStyleSheetText( StyleSheets  : OleVariant ;
                        CSSTexts  : TStrings  );
var i :Olevariant;
    stylesheet : IHTMLStyleSheet;
      css,CSSText :string;
begin
  i := 0;
   if s_OK =  IDispatch(StyleSheets).QueryInterface( IHTMLStyleSheet , stylesheet ) then
    begin
 //    styleSheet :=Idispatch(styleSheets ) as IHTMLStyleSheet;
     if  (
       (styleSheet.owningElement.tagName = 'STYLE')  And (styleSheet.href <>'' )
       )
       or
       (
          isLinkElementWithHREF(styleSheet)
       )

       then  exit;
//     begin
       cssText := styleSheet.csstext ;
       cssText := AdjustLineBreaks( cssText );

       if cssText <> '' then
       begin
         css := '<STYLE TYPE="text/css"';
         if  styleSheet.id <>'' then
           css := css+' id=' + styleSheet.id + ' ';
         if  styleSheet.media <>'' then       
           css := css + ' media=' +  styleSheet.media + ' ';
         if styleSheet.title <>'' then
           css := css + ' title=' + styleSheet.title +' ';
         css := css + '>' +#13+#10  + cssText + #13+#10 + '</STYLE>'+#13+#10;
         css := AdjustLineBreaks( css );
         CSSTexts.Add( css );
      exit;
     end; //if cssText <> '' then
//    end; //se = nil
   end; // if s_OK =  IDispatch(
try
  while i < styleSheets.length do
  begin
    WalkStyleSheetText( styleSheets.item(i) , CSSTexts );
    inc(i);
  end;
except
end;
end;

Procedure TDOMLibs.GetStyleText(Styles : Tstrings);
begin
       self.WalkStyleSheetText( document.styleSheets , Styles );


end;

procedure TDOMLibs.zindexLAYER(oj: IHTMLStyle; Zindex: integer);
begin
   if Zindex < 0 then Zindex := 0;
   oj.zIndex := Zindex ;
end;

function TDOMLibs.GetzindexLAYER(oj: IHTMLStyle) : integer;

begin
   result := integer(oj.zIndex) ;
end;

procedure TDOMLibs.moveLAYER(oj: Olevariant{IHTMLStyle }; x, y: integer);

begin
  oj.posLeft := x;
  oj.posTop := y;
end;

procedure TDOMLibs.moveByLAYER(oj : IHTMLStyle; offsetx,offsety : integer) ;
begin
  oj.pixelLeft:= oj.pixelLeft +offsetx;
  oj.pixelTop := oj.pixelTop  + offsety;
end;

procedure TDOMLibs.outputLAYER(ov_oj : Olevariant ; html: wideString);
begin
 //    element :=IDispatch( oj ) as IHTMLElement;
      ov_oj.innerHTML := html;

end;

procedure TDOMLibs.setCLIP(oj: IHTMLStyle; clipTop, clipRight,
  clipBottom, clipLeft: integer);
begin
oj.clip := 'rect('+inttostr( clipTop    )+','
                  +inttostr( clipRight  )+','
                  +inttostr( clipBottom )+','
                  +inttostr( clipLeft   )+')';
end;

procedure TDOMLibs.StyleInsert( id : string );
var
    s: string;
begin
      s:='<STYLE '+'ID='+id+'></STYLE>' ;
         DOCUMENT.body.insertAdjacentHTML( 'afterBegin' , s);

    while ( document.readyState <> 'complete' )  do
     Application.ProcessMessages;
end;

function TDOMLibs.getLayOj(ojName: WideString): IHTMLElement; //Olevariant;
var ov : olevariant;
begin
 try
//ov  := Olevariant((Document.all.item( ojName ,0 )) );
//ov :=
  result := IHTMLElement( Document.all.item( ojName ,0 ) );
 except
 end;
end;



/////////////////////////////////


//ブラウザ上で、選択されているエレメントにtagが含まれているかどうか
function TDOMLibs.SelectElement_As_Tag(tagName :string ): IHTMLElement;
begin
try
    result := nil;
    result := GetSelectElemet;

 if not assigned(result) then
 begin
 result :=nil;
 exit;
 end;
   if not ( result.tagName = tagname ) then
     result := nil;
 except
  result :=nil;
 end;
end;


function TDOMLibs.GetSelectElemet : IHTMLElement;
var TR : IHTMLtxtRange;
    CR :IHTMLControlRange;
begin
  if (Document.readyState<>'complete')  then
    begin result := nil; exit; end;

  try
  if ( document.selection.type_ = 'Control' )   then
  begin

    CR := (document.selection.createRange) as IHTMLControlRange;
    result := CR.commonParentElement;
  end
  else
  begin
    tr := (document.selection.createRange) as IHTMLtxtRange;
    tr.collapse(true);
    result := tr.parentElement;
  end;
  except
//  begin
    result := nil;

  end;

end;
function TDOMLibs.TextRangeFind( TextRange :IHTMLTxtRange ; SearchString : wideString ;
  Count , condition :integer   ): IHTMLTxtRange;
begin

   result := TextRange.duplicate;
   if  not assigned(result) then exit;

   if  textRange.findText( SearchString , count , condition) then
   begin
     textrange.select;
     if count>0 then
           result.setEndPoint('StartToEnd' , TextRange)
         else
           result.setEndPoint('EndToStart', TextRange);
   end  //if textrange...
   else result := nil ;


end;


function TDOMLibs.getSelectTextRnge : IHTMLTxtRange;
begin


  if ( document.selection.type_ <> 'Control' )   then
     result := (document.selection.
             createRange as IHTMLtxtRange)
  else

 result := nil;

end;
//アンカーのコレクションを得る
function TDOMLibs.GetAnchorsCollection : IHTMLElementCollection;

begin
  result := document.anchors;
end;

//アンカーの一覧を得る
procedure TDOMLibs.GetAnchorsList( AnchorsList :Tstrings);
var
        Anchors :IHTMLElementCollection ;
        i :integer;

begin

   Anchors := GetAnchorsCollection;

    i := 0;
    AnchorsList.Clear;
try
    while (I < Anchors.length) do
    begin
      AnchorsList.Add(
          (Anchors.item(i,0) as IHTMLAnchorElement).href);
      Inc(I)
    end
except
end;
end;

procedure TDOMLibs.GetBookMark( BookMarks :Tstrings);
var
        Anchors :IHTMLElementCollection ;
        i :integer;
        bookMark : String;
begin

//   Anchors := self.getHyperLinksCollection;

    i := 0;
    BookMarks.Clear;
    Anchors := document.all.tags('A') as IHTMLElementCollection;
    while (I < Anchors.length) do
    begin
      bookMark :=(Anchors.item(i,0) as IHTMLAnchorElement).name;
      if bookMark<>'' then
        BookMarks.Add( BookMark   );
      Inc(I)
    end
end;


procedure TDOMLibs.GetID_List( IDLists :Tstrings);
var  ov : integer;
    s : string;
     ov_element : olevariant;
    Element : IHTMLElement;
begin
  ov := 0 ;
  while ( ov < (document.all.length) ) do
  begin
    ov_element := document.all.item( ov , 0 );
    element := IDispatch(ov_element) as IHTMLElement;
    s := element.id;
    element.tagName;
    if s<>'' then
       IDLists.Add( s );
    inc( ov )
  end;

end;

function TDOMLibs.getHyperLinksCollection : IHTMLElementCollection;
begin
  result := document.links;
end;

procedure TDOMLibs.GetHyperLinksList( LInksLists:TStrings );
var
  Links: IHTMLElementCollection ;
  I: integer;
begin
    Links := GetHyperLinksCollection ;
    I := 0;
    while (I < Links.length) do
    begin
    LinksLists.
//*      Add((Links.item(I,0) as IHTMLAnchorElement ).href);

         Add(olevariant(Links.item(I,0)).href);

      Inc(I)
    end

end;

function TDOMLibs.Body : IHTMLBodyElement ;
var
 // title : IHTMLTitleElement;
     ov_Document,body : olevariant ;

begin
   ov_document :=olevariant(document);

   body := Ov_document.body;
   result := Idispatch(body) as IHTMLBodyElement;
end;




 //選択したエレメントが含まれるブロックに指定されたタグがないか調べる。
function TDOMLibs.HTMLWalkSearchElement(TagName :string) :iHTMLElement;
begin
   result := GetSelectElemet;
   HTMLwalkSearchTag(TagName,result);
end;

//指定したエレメントが含まれるブロックに指定されたタグがないか調べる。
procedure TDOMLibs.HTMLwalkSearchTag( TagName : String;var HTMLElement: IHTMLElement);
begin
  if HTMLElement = nil then exit;
  while HTMLElement.tagName <>'HTML' do
  begin
    if HTMLElement.tagname = TagName then   Exit;
    HTMLElement := HTMLElement.parentElement;
  end;
  HTMLelement := nil;
 end;

//MSHTMLにフォーカスを渡す
procedure TDOMLibs.setFocus;
begin
  DOCUMENT.parentWindow.focus;

end;
function TDOMLibs.GetBODYTextRange :IHTMLTxtRange ;
var
  ov : olevariant ;
begin
    ov  := olevariant((Olevariant(document as idispatch).body)  );
    result := (IDispatch(ov.createTextrange) ) as IHTMLTxtrange;
end;

function TDOMLibs.Tags_get( TagName : String ) : IHTMLElementCollection;
begin
  result := (document.all.tags(TagName)) as IHTMLElementCollection;
end;

 //ドキュメント上でコマンドの値を得る
function TDOMLibs.queryCommandvalue( CMD : WideString ) :WideString;
begin
 result :='undefine'; //'不明' ;
 if Document.queryCommandEnabled( CMD ) then
    result := Document.queryCommandvalue( CMD );
end;



///////////////////
procedure TDOMLibs.SetClass( Element : IHTMLElement ; ClassName : string );
begin


    if className <>'' then
     element.className := className
    else
    begin
     if element.className='' then exit;

     element.className := '';
      while ( document.readyState <> 'complete' )  do
      Application.ProcessMessages;
     element.removeAttribute('class' , 0);
    end;
end;

procedure TDOMLibs.SetID( Element : IHTMLElement ; ID : string );
begin

      while ( document.readyState <> 'complete' )  do
       Application.ProcessMessages;

    if id <>'' then
      element.setAttribute('ID' , id , 0)
    else
    begin
      if Element.id ='' then exit;
       element.removeAttribute('id' , 0);
    end;


end;

function TDOMLibs.GetHyperLink: WideString;
var
//   TempBaseURL : WideString;
   ScanElement:IHTMLElement;
        href : string;
begin
    result :='';
    scanElement := GetSelectElemet ;
    HTMLwalkSearchTag('A', scanElement ) ;

   if scanElement <> nil then
   begin
   href := (scanelement as IHTMLAnchorElement).href;

   if ansipos('file:' , href ) <>0 then
   begin
     href := FileProtocolToFileName( href );
//     href := StringReplace( href ,tempBaseURL ,'', [rfIgnoreCase] );
     href := StringReplace( href ,'\' ,'/', [rfIgnoreCase]+[rfReplaceAll]  );
   end;
      result := href;
   end;
end;

function PutfromSynthesisURL(  doc ,  Source : string ; var startPos : integer ) : string;
 var   adjTagPos  : TAdjucentTagPos;
 tmpdoc : string;
begin  tmpDoc := Doc;
     delete(tmpdoc,1,StartPos);
     result :='';
     if  adjacentURL(tmpDoc ,  adjTagPos ) then
     begin
       tmpDoc := copy(Doc, 1 ,adjTagPos.afterBegin -1 +startPos);
       delete( doc, 1  , adjTagPos.beforeEnd + startPos);
       result := tmpdoc + Source + doc;

        startPos :=  adjTagPos.afterBegin + startPos;
     end
     else
      StartPos :=0;
end;




function GetfromSynthesisURL( doc :string ; var startPos : integer ) : string;
 var   adjTagPos : TAdjucentTagPos;
       tmpDoc : string;
begin
 tmpDoc :=doc;
 result := '';
  delete( tmpDoc , 1 , startPos );
 if tmpdoc='' then exit;

 if  AdjacentURL( tmpdoc , adjTagPos ) then
 begin
  result := Copy(Doc, adjTagPos.afterBegin + startPos  , (adjTagPos.beforeEnd - adjTagPos.afterBegin)+1);
  StartPos := adjTagPos.afterBegin + startPos ;
 end
 else
  StartPos :=0;
end;

function reWriteRelativeURLinCSS( STYLE , pathName : string) : string;
var URL,header : string;
   startPos1 , startPos2 : integer ;

begin

 startPos1 := 0;
 startPos2 := 0;
 URL := GetfromSynthesisURL( STYLE , Startpos1);

 while URL<>'' do
 begin
  url := ExtractRelativePath( PathName , ExpandFileName(slashtoYen(URL)) );
  STYLE := PutfromSynthesisURL( STYLE , YenToSlash( url  ), StartPos2 );
  URL := GetfromSynthesisURL( STYLE , Startpos1);
 end;

   result := STYLE;

end;

procedure TDOMLibs.InsertBlockTag(BeginTag, EndTag: string);
var
   HTML : string;
   element : IHTMLElement;
  tr : IHTMLTxTRange;
begin
try
  tr := self.getSelectTextRnge ;

         HTML := BeginTag + tr.htmlText + EndTag;
         tr.pasteHTML( HTML );
except
   element := self.GetSelectElemet;
   if element = nil then exit;

   HTML := element.outerHTML;
   element.outerHTML := BeginTag + HTML + EndTag;


end;
end;

function urlEncode(const S: string): string;
var
  I: Integer;
  Hex: string;
begin
  for I := 1 to Length(S) do

    case S[i] of
      ' ': result := Result + '+';
      'A'..'Z', 'a'..'z', '*', '@', '.', '_', '-',
        '0'..'9', '$', '!', '''', '(', ')':
        result := Result + s[i];
    else
      begin
        Hex := IntToHex(ord(S[i]), 2);
        if Length(Hex) = 2 then Result := Result + '%' + Hex else
          Result := Result + '%0' + hex;
      end;
    end;
end;


function URLDecode(const AStr: String): String;
var
  Sp, Rp, Cp: PChar;
begin
  SetLength(Result, Length(AStr));
  Sp := PChar(AStr);
  Rp := PChar(Result);
  while Sp^ <> #0 do
  begin
    if not (Sp^ in ['+','%']) then
      Rp^ := Sp^
    else
      if Sp^ = '+' then
        Rp^ := ' '
      else
      begin
        inc(Sp);
        if Sp^ = '%' then
          Rp^ := '%'
        else
        begin
          Cp := Sp;
          Inc(Sp);
          Rp^ := Chr(StrToInt(Format('$%s%s',[Cp^, Sp^])));
        end;
      end;
    Inc(Rp);
    Inc(Sp);
  end;
  SetLength(Result, Rp - PChar(Result));
end;




end.
