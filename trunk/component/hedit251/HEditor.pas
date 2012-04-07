(*********************************************************************

  TEditor version 2.50

  start  1998/07/05
  update 2004/10/23

  Copyright (c) 1998,2004 本田勝彦 <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  key words B-)
  $VScrollMax ......... 縦スクロールの上限について（３カ所）
  $OriginBase ......... Leftbar, Ruler の交差する部分について
  $DotUnderline ....... fsUnderline を一点破線で描画しない場合について

  comments
  #MaxLineCharacter ... １，０００文字について
  #ScreenStrings ...... 文字列の更新、undo, redo, 再描画の仕組み
  #UndoObj ............ TEditorUndoObj オブジェクトの動作について
  #IME ................ SetImeComposition IME ウィンドゥの移動について
  #Scroll ............. ScrollWindowEx について
  #Caret .............. 描画とキャレットについて
  #Leftbar, #Ruler .... Leftbar, Ruler が利用するビットマップについて
  #Drawing ............ 描画について
  #Selection .......... 選択領域の処理について
  #SelectionMove ...... 選択領域の移動について
  #WM_IME_COMOISITION . IME 文字列取得について
  #RowMarks ........... Imagebar に表示する RowMarks の扱いについて
  #HitSelLength ....... 検索一致文字列の描画について
  #HScroll ............ スクロールボタンによる横スクロール量
  --------------------------------------------------------------------
  
**********************************************************************)

unit HEditor;

{$I heverdef.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, Imm, Clipbrd, Menus, heClasses, heFountain, heRaStrings,
  EditorFountain, htSearch;

const

{ TEditor consts }

  DefaultCaretWidth   = 2;
  BriefCaretHeight    = 2;
  MaxLineCharacter    = 1000;
  MarginLimit         = 100;
  UndoListMin         = 64;
  MaxWrapByte         = 250;
  MinWrapByte         = 20;

{ TEditorAttributeArray special attributes }

  caEof        = #$30; {'0'}
  caAnk        = #$31; {'1'}
  caDelimiter  = #$32; {'2'}
  caTabSpace   = #$33; {'3'}
  caDBCS1      = #$34; {'4'}
  caDBCS2      = #$35; {'5'}

type
  TEditorCursors = class(TNotifyPersistent)
  private
    FDefaultCursor: TCursor;
    FDragSelCursor: TCursor;
    FDragSelCopyCursor: TCursor;
    FInSelCursor: TCursor;
    FLeftMarginCursor: TCursor;
    FTopMarginCursor: TCursor;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property DefaultCursor: TCursor read FDefaultCursor write FDefaultCursor;
    property DragSelCursor: TCursor read FDragSelCursor write FDragSelCursor;
    property DragSelCopyCursor: TCursor read FDragSelCopyCursor write FDragSelCopyCursor;
    property InSelCursor: TCursor read FInSelCursor write FInSelCursor;
    property LeftMarginCursor: TCursor read FLeftMarginCursor write FLeftMarginCursor;
    property TopMarginCursor: TCursor read FTopMarginCursor write FTopMarginCursor;
  end;

  TEditorCaretStyle = (csDefault, csBrief);

  TEditorCaret = class(TNotifyPersistent)
  private
    FAutoCursor: Boolean;                // TEditor がマウスカーソルを変更するしないフラグ
    FAutoIndent: Boolean;                // オートインデントするしないフラグ
    FBackSpaceUnIndent: Boolean;         // バックスペースアンインデントするしないフラグ
    FCursors: TEditorCursors;            // 選択領域を移動する際のマウスカーソル群
    FFreeCaret: Boolean;                 // フリーキャレットフラグ
    FFreeRow: Boolean;                   // FreeCaret = False の時、↑↓（VK_UP, VK_DOWN）キー押し下げ時だけフリーキャレットになるぞフラグ
    FInTab: Boolean;                     // タブの中を移動出来る出来ないフラグ
    FKeepCaret: Boolean;                 // not FreeCaret 時にキャレット位置を記憶するしないフラグ
    FLockScroll: Boolean;                // スクロールバーによる縦スクロール時にキャレットを固定するしないフラグ
    FNextLine: Boolean;                  // 行頭、行末から次の行へキャレットが移動するしないフラグ
    FPrevSpaceIndent: Boolean;           // 現在行の行頭に空白が無い場合でも、行を遡って空白数を取得しインデントするしないフラグ
    FRowSelect: Boolean;                 // レフトマージン内でマウスの左ボタン押し下げた時、その行を選択するしないフラグ
    FSelDragMode: TDragMode;             // dmManual, dmAutomatic
    FSelMove: Boolean;                   // マウスで選択領域を移動するしないフラグ
    FSoftTab: Boolean;                   // ソフトタブフラグ
    FStyle: TEditorCaretStyle;           // キャレットスタイル csDefault |, csBrief _
    FTabIndent: Boolean;                 // タブインデント
    FTabSpaceCount: Integer;             // タブの展開数
    FTokenEndStop: Boolean;              // Ctrl + VK_LEFT, Ctrl + VK_RIGHT 入力時にトークンの終端で止まる止まらない。
    procedure SetStyle(Value: TEditorCaretStyle);
    procedure SetTabSpaceCount(Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property AutoCursor: Boolean read FAutoCursor write FAutoCursor;
    property AutoIndent: Boolean read FAutoIndent write FAutoIndent;
    property BackSpaceUnIndent: Boolean read FBackSpaceUnIndent write FBackSpaceUnIndent;
    property Cursors: TEditorCursors read FCursors write FCursors;
    property FreeCaret: Boolean read FFreeCaret write FFreeCaret;
    property FreeRow: Boolean read FFreeRow write FFreeRow;
    property InTab: Boolean read FInTab write FInTab;
    property KeepCaret: Boolean read FKeepCaret write FKeepCaret;
    property LockScroll: Boolean read FLockScroll write FLockScroll;
    property NextLine: Boolean read FNextLine write FNextLine;
    property PrevSpaceIndent: Boolean read FPrevSpaceIndent write FPrevSpaceIndent;
    property RowSelect: Boolean read FRowSelect write FRowSelect;
    property SelDragMode: TDragMode read FSelDragMode write FSelDragMode;
    property SelMove: Boolean read FSelMove write FSelMove;
    property SoftTab: Boolean read FSoftTab write FSoftTab;
    property Style: TEditorCaretStyle read FStyle write SetStyle;
    property TabIndent: Boolean read FTabIndent write FTabIndent;
    property TabSpaceCount: Integer read FTabSpaceCount write SetTabSpaceCount;
    property TokenEndStop: Boolean read FTokenEndStop write FTokenEndStop;
  end;

  TEditorMargin = class(TNotifyPersistent)
  private
    FCharacter: Integer;                 // 文字間マージン 0..MarginLimit
    FLeft: Integer;                      // レフトマージン 0..MarginLimit
    FLine: Integer;                      // 行間マージン   0..MarginLimit
    FTop: Integer;                       // トップマージン 0..MarginLimit
    FUnderline: Integer;                 // アンダーラインマージン 0..1
    procedure SetCharacter(Value: Integer);
    procedure SetLeft(Value: Integer);
    procedure SetLine(Value: Integer);
    procedure SetTop(Value: Integer);
    procedure SetUnderline(Value: Integer);
  protected
    property Underline: Integer read FUnderline write SetUnderline;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property Character: Integer read FCharacter write SetCharacter;
    property Left: Integer read FLeft write SetLeft;
    property Line: Integer read FLine write SetLine;
    property Top: Integer read FTop write SetTop;
  end;

  TEditorMark = class(TNotifyPersistent)
  private
    FColor: TColor;                      // 表示色
    FVisible: Boolean;                   // 表示するしないフラグ
    procedure SetColor(Value: TColor);
    procedure SetVisible(Value: Boolean);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property Color: TColor read FColor write SetColor;
    property Visible: Boolean read FVisible write SetVisible;
  end;

  TEditorMarks = class(TNotifyPersistent)
  private
    FEofMark: TEditorMark;               // [EOF] マーク
    FRetMark: TEditorMark;               // 改行マーク
    FWrapMark: TEditorMark;              // 折り返しマーク
    FHideMark: TEditorMark;              // MaxLineCharacter を越える文字列があることを表現するマーク
    FUnderline: TEditorMark;             // アンダーライン
    procedure SetEofMark(Value: TEditorMark);
    procedure SetRetMark(Value: TEditorMark);
    procedure SetWrapMark(Value: TEditorMark);
    procedure SetHideMark(Value: TEditorMark);
    procedure SetUnderline(Value: TEditorMark);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property EofMark: TEditorMark read FEofMark write SetEofMark;
    property RetMark: TEditorMark read FRetMark write SetRetMark;
    property WrapMark: TEditorMark read FWrapMark write SetWrapMark;
    property HideMark: TEditorMark read FHideMark write SetHideMark;
    property Underline: TEditorMark read FUnderline write SetUnderline;
  end;

  TEditorViewInfo = class(TNotifyPersistent)
  private
    FEditorFountain: TEditorFountain;
    function GetBrackets: TEditorBracketCollection;
    function GetColors: TEditorColors;
    function GetCommenter: String;
    function GetControlCode: Boolean;
    function GetHexPrefix: String;
    function GetMail: Boolean;
    function GetQuotation: String;
    function GetUrl: Boolean;
    procedure SetBrackets(Value: TEditorBracketCollection);
    procedure SetColors(Value: TEditorColors);
    procedure SetCommenter(Value: String);
    procedure SetControlCode(Value: Boolean);
    procedure SetHexPrefix(Value: String);
    procedure SetMail(Value: Boolean);
    procedure SetQuotation(Value: String);
    procedure SetUrl(Value: Boolean);
  protected
    FComponent: TPersistent; // for PropertyEditor
    function CreateEditorFountain: TEditorFountain; virtual;
    function GetOwner: TPersistent; {$IFDEF COMP3_UP} override; {$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property EditorFountain: TEditorFountain read FEditorFountain;
  published
    property Brackets: TEditorBracketCollection read GetBrackets write SetBrackets;
    property Colors: TEditorColors read GetColors write SetColors;
    property Commenter: String read GetCommenter write SetCommenter;
    property ControlCode: Boolean read GetControlCode write SetControlCode;
    property HexPrefix: String read GetHexPrefix write SetHexPrefix;
    property Mail: Boolean read GetMail write SetMail;
    property Quotation: String read GetQuotation write SetQuotation;
    property Url: Boolean read GetUrl write SetUrl;
  end;

  TEditorRuler = class(TNotifyPersistent)
  private
    FBkColor: TColor;                    // 背景色
    FColor: TColor;                      // 前景色
    FEdge: Boolean;                      // 縁取り
    FGaugeRange: Integer;                // 8, 10
    FMarkColor: TColor;                  // ルーラーマーカー色
    FVisible: Boolean;                   // 表示するしないフラグ
    procedure SetBkColor(Value: TColor);
    procedure SetColor(Value: TColor);
    procedure SetEdge(Value: Boolean);
    procedure SetGaugeRange(Value: Integer);
    procedure SetMarkColor(Value: TColor);
    procedure SetVisible(Value: Boolean);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property BkColor: TColor read FBkColor write SetBkColor;
    property Color: TColor read FColor write SetColor;
    property Edge: Boolean read FEdge write SetEdge;
    property GaugeRange: Integer read FGaugeRange write SetGaugeRange;
    property MarkColor: TColor read FMarkColor write SetMarkColor;
    property Visible: Boolean read FVisible write SetVisible;
  end;

  TEditorShowNumberMode = (nmRow, nmLine);

  TEditorLeftbar = class(TNotifyPersistent)
  private
    FBkColor: TColor;                       // 背景色
    FColor: TColor;                         // 前景色
    FColumn: Integer;                       // 桁数 1..8
    FEdge: Boolean;                         // 縁取り
    FLeftMargin: Integer;                   // 左マージン 0..MarginLimit
    FRightMargin: Integer;                  // 右マージン 0..MarginLimit
    FShowNumber: Boolean;                   // 行番号表示フラグ
    FShowNumberMode: TEditorShowNumberMode; // nmRow, nmLine
    FVisible: Boolean;                      // 表示するしないフラグ
    FZeroBase: Boolean;                     // 0 base
    FZeroLead: Boolean;                     // 0001
    procedure SetBkColor(Value: TColor);
    procedure SetColor(Value: TColor);
    procedure SetColumn(Value: Integer);
    procedure SetEdge(Value: Boolean);
    procedure SetLeftMargin(Value: Integer);
    procedure SetRightMargin(Value: Integer);
    procedure SetShowNumber(Value: Boolean);
    procedure SetShowNumberMode(Value: TEditorShowNumberMode);
    procedure SetVisible(Value: Boolean);
    procedure SetZeroBase(Value: Boolean);
    procedure SetZeroLead(Value: Boolean);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property BkColor: TColor read FBkColor write SetBkColor;
    property Color: TColor read FColor write SetColor;
    property Column: Integer read FColumn write SetColumn;
    property Edge: Boolean read FEdge write SetEdge;
    property LeftMargin: Integer read FLeftMargin write SetLeftMargin;
    property RightMargin: Integer read FRightMargin write SetRightMargin;
    property ShowNumber: Boolean read FShowNumber write SetShowNumber;
    property ShowNumberMode: TEditorShowNumberMode read FShowNumberMode write SetShowNumberMode;
    property Visible: Boolean read FVisible write SetVisible;
    property ZeroBase: Boolean read FZeroBase write SetZeroBase;
    property ZeroLead: Boolean read FZeroLead write SetZeroLead;
  end;

  TEditorImagebar = class(TNotifyPersistent)
  private
    FDigitWidth: Integer;
    FLeftMargin: Integer;
    FMarkWidth: Integer;
    FRightmargin: Integer;
    FVisible: Boolean;
    procedure SetDigitWidth(Value: Integer);
    procedure SetLeftMargin(Value: Integer);
    procedure SetMarkWidth(Value: Integer);
    procedure SetRightMargin(Value: Integer);
    procedure SetVisible(Value: Boolean);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property DigitWidth: Integer read FDigitWidth write SetDigitWidth;
    property LeftMargin: Integer read FLeftMargin write SetLeftMargin;
    property MarkWidth: Integer read FMarkWidth write SetMarkWidth;
    property RightMargin: Integer read FRightMargin write SetRightMargin;
    property Visible: Boolean read FVisible write SetVisible;
  end;

  TEditorSpeedRange = 1..4;

  TEditorSpeed = class(TPersistent)
  private
    FCaretVerticalAc: TEditorSpeedRange;
    FInitBracketsFull: Boolean;
    FPageVerticalRange: TEditorSpeedRange;   // 1 = (RowCount - 1) div 2
    FPageVerticalRangeAc: TEditorSpeedRange; // 1 = (RowCount - 1) div 2
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property CaretVerticalAc : TEditorSpeedRange read FCaretVerticalAc write FCaretVerticalAc;
    property InitBracketsFull: Boolean read FInitBracketsFull write FInitBracketsFull;
    property PageVerticalRange: TEditorSpeedRange read FPageVerticalRange write FPageVerticalRange;
    property PageVerticalRangeAc: TEditorSpeedRange read FPageVerticalRangeAc write FPageVerticalRangeAc;
  end;

  TEditor = class;

  TEditorScreenStrings = class;

  TEditorAttributeArray = class(TObject)
  private
    FAttribute: Char;
    FAttributes: String;
    FPosition: Integer;
    FSource: String;
    FSourcePos: Integer;
    function GetSize: Integer;
    procedure SetPosition(Value: Integer);
  public
    constructor Create(const Source, Attributes: String);
    procedure Next;
    function NextPositionString: String;
    function PositionString: String;
    procedure NewData(const Source, Attributes: String);
    procedure Prior;
    property Attribute: Char read FAttribute;
    property Position: Integer read FPosition write SetPosition;
    property SourcePos: Integer read FSourcePos;
    property Size: Integer read GetSize;
  end;

  TEditorRowAttribute = TRowAttribute;

  TEditorStringList = class(TRowAttributeStringList);

  TEditorDrawInfo = record
    Start, Delete, Insert, Invalid: Integer;
    NeedUpdate: Boolean;
  end;

  TEditorUndoObj = class;
  TEditorWrapOption = class;

  TEditorScreenStrings = class(TEditorStringList)
  protected
    FClients: TList;
    FDrawInfo: TEditorDrawInfo;
    FValidRowMarks: TRowMarks;
    FUndoObj: TEditorUndoObj;
    FWordWrap: Boolean;
    FWrapOption: TEditorWrapOption;
    procedure ChangeLink(Sender: TObject);
    procedure ChangeList(Index, DeleteCount: Integer; List: TEditorStringList);
    procedure CheckCrlf(Index: Integer; var S: String);
    procedure ClientsAdjustRow;
    procedure ClientsCleanSelection;
    procedure ClientsInitCol;
    procedure ClientsInitView;
    function GetActiveClient: TEditor;
    function GetClient: TEditor;
    function CreateUndoObj: TEditorUndoObj; virtual;
    function CreateWrapOption: TEditorWrapOption; virtual;
    function DeleteList(Index, DeleteCount: Integer): TRowMarks;
    procedure InitBrackets;
    procedure InsertList(Index: Integer; List: TEditorStringList);
    procedure ListInfo(Index, TargetCount: Integer; var S: String;
      var TakenRowCount: Integer; var RowAttribute: TEditorRowAttribute);
    procedure Reference(Value: TEditor);
    procedure Release(Value: TEditor);
    function RowEnd(Index: Integer): Integer;
    function RowStart(Index: Integer): Integer;
    procedure SetUpdateState(Updating: Boolean); override;
    procedure SetWordWrap(Value: Boolean);
    procedure StretchLines;
    procedure StrToWrapList(const S: String; List: TEditorStringList); virtual; // S を FWrapByte で分割し、List に格納する
    function UpdateBrackets(Index: Integer; InvalidateFlag: Boolean): Integer;
    procedure UpdateDrawInfo(Index, DeleteCount, InsertCount, InvalidCount: Integer);
    procedure UpdateList(Index, DeleteCount: Integer; const S: String);
    function WrapCount(S: String): Integer; virtual;
    procedure WrapLines;
    procedure WrapOptionChanged(Sender: TObject);
    property ActiveClient: TEditor read GetActiveClient;
    property Client: TEditor read GetClient;
    property WordWrap: Boolean read FWordWrap write SetWordWrap;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; override;
    procedure ExcludeRowMarks(Marks: TRowMarks); virtual;
    procedure IncludeRowMarks(Marks: TRowMarks); virtual;
    procedure Redo; virtual;
    procedure Undo; virtual;
    function ValidRowMarks: TRowMarks; virtual;
  end;

  TEditorStrings = class(TStrings)
  private
    procedure ReadData(Reader: TReader);
    procedure WriteData(Writer: TWriter);
  protected
    FEditor: TEditor;
    FUpdateCount: Integer;
    procedure DefineProperties(Filer: TFiler); override;
    function Get(Index: Integer): String; override;
    function GetCount: Integer; override;
    function GetTextStr: String; override;
    function LinesToRow(Index: Integer): Integer;
    procedure Put(Index: Integer; const S: String); override;
    procedure SetTextStr(const Value: String); override;
    procedure SetUpdateState(Updating: Boolean); override;
  public
    function Add(const S: String): Integer; override;
    procedure Assign(Source: TPersistent); override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: String); override;
    procedure LoadFromFile(const FileName: String); override;
  end;

  PUndoData = ^TUndoData;
  TUndoData = record
    Row, Col, DataRow, DeleteCount: Integer;
    RowAttribute: TEditorRowAttribute;
    InsertStr: String;
  end;

  TUndoDataList = class(TList)
  public
    destructor Destroy; override;
    procedure Clear; {$IFDEF TLIST_CLEAR_VIRTUAL} override; {$ENDIF}
    procedure Delete(Index: Integer);
  end;

  TEditorUndoObj = class(TObject)
  protected
    FList: TEditorScreenStrings;
    FListMax: Integer;
    FRedoing: Boolean;
    FRedoList: TUndoDataList;
    FUndoList: TUndoDataList;
    function Add: PUndoData; virtual;
    function CanRedo: Boolean; virtual;
    function CanUndo: Boolean; virtual;
    procedure Redo; virtual;
    procedure Undo; virtual;
    procedure UndoToRedo(Data: PUndoData); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; virtual;
  end;

  TEditorWrapOption = class(TNotifyPersistent)
  private
    FFollowRetMark: Boolean;     // 改行マークをぶら下げる
    FFollowPunctuation: Boolean; // 句読点をぶら下げる
    FFollowStr: String;          // 行頭禁則文字 '、。，．・？！゛゜ヽヾゝゞ々ー）］｝」』!),.:;?]}｡｣､･ｰﾞﾟ'
    FLeading: Boolean;           // 追い出し処理を行う
    FLeadStr: String;            // 行末禁則文字 '（［｛「『([{｢'
    FPunctuationStr: String;     // 句読点 '、。，．,.｡､';
    FWordBreak: Boolean;         // 英文（半角文字）WordWrap
    FWrapByte: Integer;          // 折り返す文字数 20..250
    procedure SetFollowPunctuation(Value: Boolean);
    procedure SetFollowRetMark(Value: Boolean);
    procedure SetFollowStr(Value: String);
    procedure SetLeading(Value: Boolean);
    procedure SetLeadStr(Value: String);
    procedure SetPunctuationStr(Value: String);
    procedure SetWordBreak(Value: Boolean);
    procedure SetWrapByte(Value: Integer);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property FollowRetMark: Boolean read FFollowRetMark write SetFollowRetMark;
    property FollowPunctuation: Boolean read FFollowPunctuation write SetFollowPunctuation;
    property FollowStr: String read FFollowStr write SetFollowStr;
    property Leading: Boolean read FLeading write SetLeading;
    property LeadStr: String read FLeadStr write SetLeadStr;
    property PunctuationStr: String read FPunctuationStr write SetPunctuationStr;
    property WordBreak: Boolean read FWordBreak write SetWordBreak;
    property WrapByte: Integer read FWrapByte write SetWrapByte;
  end;

  TEditorPopupMenu = class(TPopupMenu)
  protected
    FEditor: TEditor;
    FSetMark: TMenuItem;
    FN0: TMenuItem;
    FGotoMark: TMenuItem;
    FUndo: TMenuItem;
    FRedo: TMenuItem;
    FN1: TMenuItem;
    FCut: TMenuItem;
    FCopy: TMenuItem;
    FPaste: TMenuItem;
    FBoxPaste: TMenuItem;
    FDelete: TMenuItem;
    FN2: TMenuItem;
    FSelAll: TMenuItem;
    FN3: TMenuItem;
    FSelMode: TMenuItem;
    procedure SetMarkClick(Sender: TObject); virtual;
    procedure GotoMarkClick(Sender: TObject); virtual;
    procedure UndoClick(Sender: TObject); virtual;
    procedure RedoClick(Sender: TObject); virtual;
    procedure CutClick(Sender: TObject); virtual;
    procedure CopyClick(Sender: TObject); virtual;
    procedure PasteClick(Sender: TObject); virtual;
    procedure BoxPasteClick(Sender: TObject); virtual;
    procedure DeleteClick(Sender: TObject); virtual;
    procedure SelAllClick(Sender: TObject); virtual;
    procedure SelModeClick(Sender: TObject); virtual;
    procedure SetMenu(Sender: TObject); virtual;
    procedure CreateMenuItem; virtual;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TEditorScreen = class(TObject)
  protected
    FEditor: TEditor;
    procedure Update; virtual;
  end;

  TEditorStrInfo = record
    Line, CharIndex: Integer;
  end;

  TSelectedPosition = record
    Sr, Er, Sc, Ec: Integer;
  end;

  TEditorHitStyle = (hsSelect, hsDraw, hsCaret);

  TEditorSelectionState = (sstNone, sstInit, sstSelected, sstHitSelected);

  TEditorSelectionMode = (smLine, smBox);

  TEditorSelDragState = (sdNone, sdInit, sdDragging);

  TEditorMouseCursorState = (mcClient, mcLeftMargin, mcTopMargin,
    mcInSel, mcDragging, mcDraggingCopy);

  TDrawLineEvent = procedure (Sender: TObject; LineStr: String;
    X, Y, Index: Integer; ARect: TRect; Selected: Boolean) of Object;

  TSelectionChangeEvent = procedure (Sender: TObject; Selected: Boolean) of Object;

  TEditor = class(TCustomControl)
  private
    // プロパティデータフィールド
    FBorderStyle: TBorderStyle;
    FCaret: TEditorCaret;                   // TEditorCaret オブジェクト
    FCol: Integer;                          // 0 base の現在の桁位置（描画用）
    FColCount: Integer;                     // 画面に表示可能な桁数
    FFontWidth: integer;                    // 文字幅 FFontWidth := TM.tmAveCharWidth + FCharacterMargin; で設定されている
    FCursorState: TEditorMouseCursorState;  // マウスカーソルの状態を表現する mcClient, mcLeftMargin, mcTopMargin, mcInSel, mcDragging, mcDraggingCopy
    FDelimiters: TCharSet;                  // 文字列を折り返し表示する処理するための区切り文字集合
    FFontHeight: integer;                   // 文字高 FFontHeight := TM.tmHeight + TM.tmExternalLeading; で設定されている
    FFountain: TFountain;                   // Fountain プロパティデータフィールド TFountain の実体へのポインタ
    FHitSelLength: Integer;                 // 検索一致文字列長
    FHitStyle: TEditorHitStyle;             // 検索一致文字列描画スタイル
    FImagebar: TEditorImagebar;             // イメージ表示オプション
    FImageDigits: TImageList;               // ジャンプマーク用イメージリスト（１０アイテム）
    FImageMarks: TImageList;                // マーク用イメージリスト（最大６アイテム）
    FLeftbar: TEditorLeftbar;               // 行番号表示オプション
    FLines: TStrings;                       // 実装は TEditorStrings ↓へのインターフェースとして機能する
    FMarks: TEditorMarks;                   // TEditorMarks オブジェクト
    FMargin: TEditorMargin;                 // TEditorMargin オブジェクト
    FModified: Boolean;
    FOverWrite: Boolean;                    // 上書きモード
    FReadOnly: Boolean;
    FRow: Integer;                          // 0 base の現在行位置
    FRowCount: Integer;                     // 画面に表示出来る行数
    FRuler: TEditorRuler;                   // ルーラー表示オプション
    FScrollBars: TScrollStyle;
    FSpeed: TEditorSpeed;                   // スピード
    FTopCol: Integer;                       // 現在表示されている左端の Col 値 ０ベース
    FTopRow: Integer;                       // 現在表示されている上端の Row 値 ０ベース
    FView: TEditorViewInfo;                 // TEditorViewInfo オブジェクト
    FWantReturns: Boolean;                  // VK_RETURN を入力するしないフラグ default = True;
    FWantTabs: Boolean;                     // タブ文字を入力するしないフラグ default = True;

    // プロパティデータフィールド（選択領域）
    FSelDraw: TSelectedPosition;            // 選択領域（描画用）
    FSelectionMode: TEditorSelectionMode;   // smLine, smBox
    FSelStr: TSelectedPosition;             // 選択領域（文字列用）

    // イベントハンドラ
    FOnCaretMoved: TNotifyEvent;
    FOnChange: TNotifyEvent;
    FOnDrawLine: TDrawLineEvent;
    FOnSelectionChange: TSelectionChangeEvent;
    FOnSelectionModeChange: TNotifyEvent;
    FOnTopColChange: TNotifyEvent;
    FOnTopRowChange: TNotifyEvent;

    // プロパティのアクセスメソッド
    function GetHitSelected: Boolean;
    function GetListBracket(Index: Integer): Integer;
    function GetListCount: Integer;
    function GetListData(Index: Integer): TRowAttributeData;
    function GetListDataString(Index: Integer): String;
    function GetListElement(Index: Integer): Integer;
    function GetListRemain(Index: Integer): Integer;
    function GetListRowMarks(Index: Integer): TRowMarks;
    function GetListPrevRow(Index: Integer): TRowAttribute;
    function GetListPrevToken(Index: Integer): Char;
    function GetListRow(Index: Integer): TEditorRowAttribute;
    function GetListString(Index: Integer): String;
    function GetListToken(Index: Integer): Char;
    function GetListWrappedByte(Index: Integer): Integer;
    function GetReserveWordList: TStringList;
    function GetRowHeight: Integer;
    function GetSelected: Boolean;
    function GetSelectedData: Boolean;
    function GetSelectedDraw: Boolean;
    function GetSelDragging: Boolean;
    function GetSelLength: Integer;
    function GetSelStart: Integer;
    function GetSelText: String;
    function GetUndoListMax: Integer;
    function GetUndoObj: TEditorUndoObj;
    function GetWordWrap: Boolean;
    function GetWrapOption: TEditorWrapOption;
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetCaret(Value: TEditorCaret);
    procedure SetCol(Value: Integer);
    procedure SetCursorState(Value: TEditorMouseCursorState);
    procedure SetFountain(Value: TFountain);
    procedure SetHitSelLength(Value: Integer);
    procedure SetHitStyle(Value: TEditorHitStyle);
    procedure SetImagebar(Value: TEditorImagebar);
    procedure SetImageDigits(Value: TImageList);
    procedure SetImageMarks(Value: TImageList);
    procedure SetLines(Value: TStrings);
    procedure SetListRowMarks(Index: Integer; Value: TRowMarks);
    procedure SetMarks(Value: TEditorMarks);
    procedure SetMargin(Value: TEditorMargin);
    procedure SetLeftbar(Value: TEditorLeftbar);
    procedure SetOverWrite(Value: Boolean);
    procedure SetReadOnly(Value: Boolean);
    procedure SetReserveWordList(Value: TStringList);
    procedure SetRow(Value: Integer);
    procedure SetRuler(Value: TEditorRuler);
    procedure SetScrollBars(Value: TScrollStyle);
    procedure SetSelectionMode(Value: TEditorSelectionMode);
    procedure SetSelLength(Value: Integer);
    procedure SetSelStart(Value: Integer);
    procedure SetSelText(const Value: String);
    procedure SetSpeed(Value: TEditorSpeed);
    procedure SetTopCol(Value: Integer);
    procedure SetTopRow(Value: Integer);
    procedure SetUndoListMax(Value: Integer);
    procedure SetView(Value: TEditorViewInfo);
    procedure SetWordWrap(Value: Boolean);
    procedure SetWrapOption(Value: TEditorWrapOption);

    // メッセージハンドラ
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure EMCanUndo(var Message: TMessage); message EM_CANUNDO;
    procedure EMCharFromPos(var Message: TMessage); message EM_CHARFROMPOS;
    procedure EMEmptyUndoBuffer(var Message: TMessage); message EM_EMPTYUNDOBUFFER;
    procedure EMGetFirstVisibleLine(var Message: TMessage); message EM_GETFIRSTVISIBLELINE;
    procedure EMGetLine(var Message: TMessage); message EM_GETLINE;
    procedure EMGetLineCount(var Message: TMessage); message EM_GETLINECOUNT;
    procedure EMGetModify(var Message: TMessage); message EM_GETMODIFY;
    procedure EMGetSel(var Message: TMessage); message EM_GETSEL;
    procedure EMLineFromChar(var Message: TMessage); message EM_LINEFROMCHAR;
    procedure EMLineIndex(var Message: TMessage); message EM_LINEINDEX;
    procedure EMLineLength(var Message: TMessage); message EM_LINELENGTH;
    procedure EMPosFromChar(var Message: TMessage); message EM_POSFROMCHAR;
    procedure EMReplaceSel(var Message: TMessage); message EM_REPLACESEL;
    procedure EMScrollCaret(var Message: TMessage); message EM_SCROLLCARET;
    procedure EMSetModiry(var Message: TMessage); message EM_SETMODIFY;
    procedure EMSetReadOnly(var Message: TMessage); message EM_SETREADONLY;
    procedure EMUndo(var Message: TMessage); message EM_UNDO;
    procedure EMSetSel(var Message: TMessage); message EM_SETSEL;
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure WMClear(var Message: TMessage); message WM_CLEAR;
    procedure WMCopy(var Message: TMessage); message WM_COPY;
    procedure WMCut(var Message: TMessage); message WM_CUT;
    procedure WMPaste(var Message: TMessage); message WM_Paste;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMGetText(var Message: TMessage); message WM_GETTEXT;
    procedure WMGetTextLength(var Message: TMessage); message WM_GETTEXTLENGTH;
    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;
    procedure WMImeComposition(var Msg: TMessage); message WM_IME_COMPOSITION;
    procedure WMImeNotify(var Msg: TMessage); message WM_IME_NOTIFY;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyUp); message WM_KEYUP;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSetText(var Message: TMessage); message WM_SETTEXT;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
  protected
    // データ
    FCaretNoMove: Boolean;                  // Row, Col が設定されてもキャレットを移動しないフラグ WMLButtonDown で使用
    FCaretUpdateCount: Integer;             // CaretBeginUpdate された回数
    FCaretShowing: Boolean;                 // キャレットが出てるフラグ
    FColBuf: Integer;                       // 記憶されたキャレット位置
    FColKeeping: Boolean;                   // キャレット位置が記憶されていますフラグ
    FCompositionCanceled: Boolean;          // SetImeCompositionWindow がキャンセルされたことを保持するフラグ。MoveCaret, SetTopRow, SetTopCol で設定され、WM_KEYUP, WM_CHAR で判別して SetImeComposition している
    FDxArray: array[0..MaxLineCharacter] of Integer; // DrawTextRect で ExtTextOut へ渡す第８引数として利用する。１，００１文字まで描画出来る仕様
    FHScrollMax: Integer;                   // 横スクロール可能幅 MaxLineCharacter に設定される
    FImeCount: Integer;                     // WM_IME_COMPOSITION メッセージハンドラで取得した文字列の長さ。WM_CHAR メッセージハンドラで、処理をキャンセルするための値として利用する。
    FItalicFontStyle: Boolean;              // fsItalic が指定されているぞフラグ。描画の際参照して描画方法を変更している
    FKeyRepeat: Boolean;                    // Col, Row の変化や、画面スクロールするとき SetImeCompositionWindow を実行するが、キーリピート状態の時は実行をキャンセルしてキャレットの移動を高速化するためのフラグ WMKeyDown で設定 WMKeyUp で解除
    FLeftScrollWidth: Integer;              // 横スクロールによって隠れている幅（ピクセル値）
    FList: TEditorScreenStrings;            // 実際に文字列を保持するオブジェクト
    FMouseSelStartPos: TPoint;              // WMLButtonDown で設定 WMMouseMove で判別して StartSelection で利用
    FScreen: TEditorScreen;                 // TEditorScreen オブジェクト
    FUnderlineUpdateCount: Integer;         // UnderlineBeginUpdate された回数
    FVScrollMax: Integer;                   // 縦スクロール可能幅 Lines.Count - 1 + RowCount - 1 で設定されている

    // 選択領域処理用データ
    FClearingSelection: Boolean;            // 選択領域をクリアしますフラグ。アンダーライン部分に描画された選択領域色をクリアするために利用する
    FRowSelecting: Boolean;                 // 行選択処理中フラグ
    FSelDragState: TEditorSelDragState;     // sdNone, sdInit, sdDragging
    FSelectionState: TEditorSelectionState; // sstNone, sstInit, sstSelected
    FSelStartCol: Integer;                  // 選択開始桁（描画用）
    FSelStartSi: Integer;                   // 選択開始桁（文字列用）
    FSelStartRow: Integer;                  // 選択開始行
    FSelOld: TSelectedPosition;             // 選択領域（描画判別用）
    FSelRow: TSelectedPosition;             // 行選択領域
    FHitSelecting: Boolean;                 // sstHitSelected へ移行するためのフラグ StartSelection で参照される

    // Imagebar, Leftbar, Ruler 関連データ
    FImagebarWidth: Integer;                // Imagebar 表示幅ピクセル
    FLeftbarColumn: Integer;                // Leftbar に実際に表示する際の桁数
    FLeftbarEdge: TBitmap;                  // Edge の時 Leftbar の右縁に描画される
    FLeftbarWidth: Integer;                 // Leftbar 表示幅ピクセル
    FOriginBase: TBitmap;                   // 原点に描画される
    FRulerBase: TBitmap;                    // これに描画したものを Ruler に CopyRect する
    FRulerDigit: TBitmap;                   // 0..9 のビットマップ（ルーラー用）
    FRulerDigitHeight: Integer;             // Ruler に描画される数字の高さ 9
    FRulerDigitMask: TBitmap;               // 0..9 のビットマップ作成用マスク
    FRulerDigitWidth: Integer;              // Ruler に描画される数字の幅   5
    FRulerEdge: TBitmap;                    // Edge の時 Ruler の下縁に描画される
    FRulerGauge: TBitmap;                   // ８桁１０桁に対応したゲージ
    FRulerHeight: Integer;                  // Ruler の高さ                 10..11
    FRulerMarkBase: TBitmap;                // 〃キャレット位置を示すマーカー用
    FRulerMarkDigit: TBitmap;               // 0..9 のビットマップ（ルーラーマーカー用）

    // Imagebar, Leftbar, Ruler 関連メソッド
    procedure AdjustImagebarWidth; virtual;
    procedure CreateMarginBitmaps; virtual;
    procedure DestroyMarginBitmaps; virtual;
    function AdjustLeftbarColumn: Boolean; virtual;
    procedure AdjustLeftbarWidth; virtual;
    procedure AdjustRulerHeight; virtual;
    procedure DrawRulerBases; virtual;
    procedure DrawRulerMark(ACol: Integer); virtual;
    procedure HideRulerMark(ACol: Integer); virtual;
    procedure InitLeftbarEdge; virtual;
    procedure InitOriginBase; virtual;
    procedure InitRulerBases; virtual;
    procedure InitRulerBitmaps; virtual;
    procedure InitRulerDigitMask; virtual;
    procedure InitRulerDigits; virtual;
    procedure InitRulerEdge; virtual;
    procedure InitRulerGauge; virtual;
    procedure InvalidateLeftbar(StartRow, EndRow: Integer); virtual;
    procedure PaintLeftbar(Sr, Er: Integer); virtual;
    procedure PaintRuler; virtual;
    procedure PaintImagebar(Sr, Er: Integer);
    function RulerWidth: Integer; virtual;
    procedure UpdateLeftBarWidth(OldWidth, NewWidth: Integer); virtual;

    // 文字列操作メソッド
    function ExpandListLength(Index: Integer): Integer;
    function ExpandListStr(Index: Integer): String;
    function ListInfoFromPos(Pos: TPoint; var Info: TEditorStrInfo): Boolean; virtual;
    function ListRows(Index: Integer): TEditorRowAttribute;
    function ListStr(Index: Integer): String;
    function ListToStr(Source: TEditorStringList): String;
    function PosTokenString(Pos: TPoint; Editor: TEditor; var C: Char; Bracket: Boolean): String; virtual;
    function PrevTopSpace(ARow: Integer): Integer;     // ARow の属する行より前の行で頭に空白を持つモノがあればその空白数を返す
    procedure PutStringToLine(Source: String);         // 現在行のキャレット位置に Str を挿入する
    procedure SelectPosToken(Pos: TPoint; Editor: TEditor; Bracket: Boolean); virtual;
    function StrToAttributes(const S: String): String;  // S 内の文字属性を表現する文字列を返す。
    function TabbedTopSpace(const S: String): Integer; // S の前の部分のスペース数を返す。全角スペース、タブ文字に対応する

    // 描画関連メソッド
    procedure AdjustColCount;                          // 表示桁数を取得する InitDrawInfo, DoChange で利用している
    procedure DoScroll(X, Y: Integer; Rect, ClipRect: PRect); virtual;
    procedure DrawEof(X, Y: Integer); virtual;
    procedure DrawRetMark(X, Y: Integer); virtual;
    procedure DrawRetMarkSelected(X, Y: Integer); virtual;
    procedure DrawWrapMark(X, Y: Integer); virtual;
    procedure DrawWrapMarkSelected(X, Y: Integer); virtual;
    procedure DrawHideMark(X, Y: Integer); virtual;
    procedure DrawHideMarkSelected(X, Y: Integer); virtual;
    procedure DrawUnderline(ARow: Integer); virtual;
    procedure HideUnderline(ARow: Integer); virtual;
    procedure InitDrawInfo;                            // 画面表示情報の再設定
    procedure InitScroll;                              // SetScrollInfo する
    procedure InitView;                                // ↑２つを呼び出して再描画する
    procedure InvalidateLine(Index: Integer);          // Index で指定された１行領域を無効化する。UpdateWindow はしない
    procedure InvalidateRow(StartRow, EndRow: Integer);// 指定行間を行番号部分も含めて無効化し UpdateWindow する
    procedure ImagebarScroll(Line, Count: Integer);    // Imagebar 内部の Line から下端までの領域を Count 行分スクロールし UpdateWindow する
    procedure LineScroll(Line, Count: Integer);        // Line から下端までの行番号部分を除く領域を Count 行分スクロールし UpdateWindow する
    procedure PageVScroll(Value: Integer);             // Value 行分画面全体をスクロールさせる
    procedure PaintLine(R: TRect; X, Y: Integer;       // R の中へ S をパースしながら描画する
      S: String; Index: Integer; Parser: TFountainParser);
    procedure PaintLineSelected(R: TRect; X, Y:        // PaintLine の選択領域バージョン
      Integer; S: String; Index: Integer; Parser: TFountainParser);
    procedure PaintRect(R: TRect);                     // 無効領域を受け取って描画処理へ分岐する
    procedure PaintRectSelected(R: TRect; X, Y:        // 選択時の PaintRect ヘルパーメソッド PaintLine, PaintLineSelected を使い分ける
      Integer; S: String; Index: Integer; Parser: TFountainParser);
    procedure UnderlineBeginUpdate; virtual;
    procedure UnderlineEndUpdate; virtual;
    function UnderlinePos(ARow: Integer): Integer; virtual;

    // キャレット関連メソッド public 部に PosToRowCol, SetRowCol がある
    procedure AdjustCol(RowChanged: Boolean; Direction: Integer); // 全角文字、タブに対するキャレット位置調節
    procedure CaretBeginUpdate; virtual;
    procedure CaretEndUpdate; virtual;
    procedure CaretHide; virtual;
    procedure CaretShow; virtual;
    function FindNextWordStart(var R, C: Integer; Direction: Integer): Boolean; virtual;// 現在の桁番号、行番号（共に０ベース）、方向を指定して次の語の行番号桁番号を取得する。成功すると True を返す
    function GetSelIndex(StartRow, ARow, ACol: Integer): Integer;
    function IsCaretNoClient: Boolean; virtual;
    procedure MoveCaret; virtual;                      // 現在の Row, Col 位置へキャレットを移動する。
    procedure RecreateCaret; virtual;
    procedure ScrollCaret; virtual;                    // 現在の Row, Col 位置を画面上に表示するために必要があれば画面スクロールを行う
    procedure SetCaretPosition(var X, Y: Integer); virtual;
    procedure SetImeComposition;                       // SetImeCompositionWindow 呼び出し
    procedure SetSelIndex(StartRow, SelIndex: Integer);
    procedure UpdateCaret; virtual;                    // キャレットを移動するとき利用する。WM_SETFOCUS では利用していない。
    {$IFDEF COMP2}
    function SetImeCompositionWindow(Font: TFont; XPos, YPos: Integer): Boolean;
    {$ENDIF}

    // 選択領域の処理メソッド public 部にも ClearSelection などがある
    function BoxLeftIndex(const Attr: String; I: Integer): Integer; // 矩形選択領域左側の文字インデックスを返す
    function BoxRightIndex(const Attr: String; I: Integer): Integer; // 矩形選択領域右側の文字インデックスを返す
    function BoxSelRect(const S: String; Index, StartCol, EndCol: Integer): TRect; // 矩形選択描画領域取得
    procedure DeleteSelection;     // 選択領域の文字列を削除し、選択状態を解除する
    procedure DrawSelection;       // 選択領域の描画
    procedure DrawSelectionBox;    // 〃矩形
    procedure DrawSelectionLine;   // 〃ノーマル
    procedure InitSelection;       // 選択領域データの初期化 -> sstInit
    procedure SelDeletedList(Dest: TEditorStringList); // 選択領域を削除した後の文字列リストを取得する
    procedure SetSelection;        // 状態に応じて StartSelection, UpdateSelection を呼び出す
    procedure StartSelection;      // 選択状態への入り口 -> sstSelected
    procedure UpdateSelection;     // 選択領域データを更新して再描画する

    // 行選択処理
    procedure StartRowSelection(ARow: Integer);  // 行選択開始
    procedure UpdateRowSelection(ARow: Integer); // 行選択更新

    // 選択領域の移動処理 public 部にも IsSelectedArea などがある
    procedure EndSelDrag;
    procedure InitSelDrag;
    procedure StartSelDrag;

    // Fountain
    function GetActiveFountain: TFountain; virtual;

    // VCL override
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateHandle; override;
    {$IFDEF COMP3_UP}
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    {$ENDIF}
    {$IFNDEF COMP4_UP} // D2..D3 cf public section
    procedure DefaultHandler(var Message); override;
    {$ENDIF}
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure WndProc(var Message: TMessage); override;

    // ファクトリーメソッド
    function CreateDelimiters: TCharSet; virtual;
    function CreateEditorCaret: TEditorCaret; virtual;
    function CreateEditorImagebar: TEditorImagebar; virtual;
    function CreateEditorLeftbar: TEditorLeftbar; virtual;
    function CreateEditorMarks: TEditorMarks; virtual;
    function CreateEditorMargin: TEditorMargin; virtual;
    function CreateEditorRuler: TEditorRuler; virtual;
    function CreateEditorSpeed: TEditorSpeed; virtual;
    function CreatePopupMenu: TPopupMenu; virtual;
    function CreateScreen: TEditorScreen; virtual;
    function CreateScreenStrings: TEditorScreenStrings; virtual;
    function CreateStrings: TStrings; virtual;
    function CreateViewInfo: TEditorViewInfo; virtual;

    // イベントハンドラ呼び出し
    procedure DoCaretMoved; virtual;
    procedure DoChange; virtual;
    procedure DoDrawLine(ARect: TRect; X, Y: Integer; LineStr: String;
      Index: Integer; SelectedArea: Boolean); virtual;
    procedure DoSelectionChange(Selection: Boolean); virtual;
    procedure DoSelectionModeChange; virtual;
    procedure DoTopColChange; virtual;
    procedure DoTopRowChange; virtual;

    // 内部オブジェクトのイベントハンドラ
    procedure ViewChanged(Sender: TObject); virtual;

    // 内部プロパティ
    property SelDragging: Boolean read GetSelDragging;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {$IFDEF COMP4_UP} // exclude D2..D3 cf protected section
    procedure DefaultHandler(var Message); override;
    {$ENDIF}
    // 選択領域のドラッグ＆ドロップを実装するため public 化したメソッド群
    function CanSelDrag: Boolean; virtual;                 // 選択文字列をマウスドラッグ出来る状態にあるかどうかを返す
    procedure CancelSelDrag;                               // 選択領域文字列のドラッグを中断する
    procedure CleanSelection;                              // 選択状態の解除 -> sstNone
    procedure CopySelection(ARow, ACol: Integer); virtual; // 選択領域の文字列を ARow, ACol 位置へコピーする。そこが選択領域内の場合は無視する
    function IsSelectedArea(ARow, ACol: Integer): Boolean; // ARow, ACol 位置が選択領域内にあるかどうかを返す
    procedure MoveSelection(ARow, ACol: Integer);          // 選択領域の文字列を ARow, ACol 位置へ移動する。そこが選択領域内の場合は無視する
    procedure PosToRowCol(XPos, YPos: Integer;
      var ARow, ACol: Integer; Split: Boolean);            // XPos, YPos で指定された場所の Row, Col 値を ARow, ACol へ格納する Split に True を渡すと文字間のキャレット位置を返す
    procedure SetRowCol(ARow, ACol: Integer);              // ARow, ACol の位置へ Row, Col を移動する Row, Col を別々にセットするのとは違う動作をする

    // RowMark 関連
    procedure PutRowMark(Index: Integer; Mark: TRowMark); virtual;
    procedure DeleteRowMark(Index: Integer; Mark: TRowMark); virtual;
    procedure GotoRowMark(Mark: TRowMark); virtual;

    // public メソッド
    function CanRedo: Boolean; virtual;
    function CanUndo: Boolean; virtual;
    function CharFromPos(Pos: TPoint): Integer;        // 指定ポイントの文字インデックスを返す（文字インデックスは SelStart と同値）失敗した場合は -1 が返る
    procedure Clear;
    procedure ClearSelection;
    function ColToChar(ARow, ACol: Integer): Integer;  // ARow 行の ACol 位置を受け取って、Lines 上での文字インデックスを返す。失敗した場合は -1 が返る
    procedure CopyToClipboard;
    procedure CutToClipboard;
    procedure DeleteRow(Index: Integer);               // FList の Index で指定された行データを削除し、再描画する
    procedure DrawTextRect(Rect: TRect; X, Y: Integer;
      const S: String; Options: Word);                 // ExtTextOut に Rect, X, Y, S, Options と FDxArray を渡して描画する
    procedure ExchangeList(Source: TEditor); virtual;  // 自身の FList への参照を破棄し、Source の FList を参照する。
    function ExpandTab(const S: String): String;       // タブをスペースに展開した文字列を返す
    function ExpandTabLength(const S: String): Integer; // タブをスペースに展開した文字列の長さを返す
    function GetSelTextBuf(Buffer: PChar; BufSize: Integer): Integer;
    function GetTextLen: Integer;
    procedure HitToSelected;                           // sstHitSelected -> sstSelected の状態変更を行う（置き換え処理で必要）
    function LeftMargin: Integer;
    function LinesToRow(Index: Integer): Integer;      // Lines を Row 上のインデックスに変換して返す
    procedure ListToFile(const FileName: String);
    procedure ListToStream(Stream: TStream);
    procedure PasteFromClipboard;
    procedure Redo; virtual;
    function RowToLines(Index: Integer): Integer;      // Row を Lines 上のインデックスに変換して返す
    function Search(const SearchValue: String; SearchOptions: TSearchOptions): Boolean; virtual;
    procedure SelectAll;
    procedure SelectTokenBracketFromCaret;
    procedure SelectTokenBracketFromPos(Pos: TPoint);
    procedure SelectTokenFromCaret;
    procedure SelectTokenFromPos(Pos: TPoint);
    procedure SelectWordFromCaret;
    procedure SelectWordFromPos(Pos: TPoint);
    procedure SelIndent;
    procedure SelUnIndent;
    procedure SelTabIndent;
    procedure SelTabUnIndent;
    procedure SetSelTextBox(Buffer: PChar);
    procedure SetSelTextBuf(Buffer: PChar);
    function StrInfoFromPos(Pos: TPoint): TEditorStrInfo; // 指定ポイントの行番号、その行文字列内での文字インデックスを取得する（共に０ベースであることに注意）失敗した場合は、Line, CharIndex のどちらかに -1 が返る
    function TokenBracketFromCaret: Char;              // キャレット位置の語句の種類を返す toBracket も返す
    function TokenBracketFromPos(Pos: TPoint): Char;   // 指定ポイントの語句の種類を返す toBracket も返す
    function TokenFromCaret: Char;                     // キャレット位置の語句の種類を返す toBracket を返すことは無い
    function TokenFromPos(Pos: TPoint): Char;          // 指定ポイントの語句の種類を返す toBracket を返すことは無い
    function TokenStringBracketFromCaret: String;      // キャレット位置の語句を返す（View.Bracets を考慮する）
    function TokenStringBracketFromPos(Pos: TPoint): String; // 指定ポイントの語句を返す（View.Bracets を考慮する）
    function TokenStringFromCaret: String;             // キャレット位置の語句を返す（View.Bracets は無視される）
    function TokenStringFromPos(Pos: TPoint): String;  // 指定ポイントの語句を返す（View.Bracets は無視される）
    function TopMargin: Integer;                       // ルーラーと Margin.Top の合計値
    procedure Undo; virtual;
    function WordFromCaret: String;                    // キャレット位置の１語を返す（View の各プロパティ設定は無視される）
    function WordFromPos(Pos: TPoint): String;         // 指定ポイントの１語を返す（View の各プロパティ設定は無視される）

    // プロパティ
    property ActiveFountain: TFountain read GetActiveFountain;
    property Canvas;
    property Col: Integer read FCol write SetCol;
    property ColCount: Integer read FColCount;
    property ColWidth: Integer read FFontWidth;
    property CursorState: TEditorMouseCursorState read FCursorState write SetCursorState;
    property Delimiters: TCharSet read FDelimiters write FDelimiters;
    property EditorUndoObj: TEditorUndoObj read GetUndoObj;
    property FontHeight: Integer read FFontHeight;
    property HitSelected: Boolean read GetHitSelected;
    property HitSelLength: Integer read FHitSelLength write SetHitSelLength;
    property InternalList: TEditorScreenStrings read FList;
    property ListBracket[Index: Integer]: Integer read GetListBracket;
    property ListCount: Integer read GetListCount;
    property ListData[Index: Integer]: TRowAttributeData read GetListData;
    property ListDataString[Index: Integer]: String read GetListDataString;
    property ListElement[Index: Integer]: Integer read GetListElement;
    property ListPrevToken[Index: Integer]: Char read GetListPrevToken;
    property ListPrevRow[Index: Integer]: TRowAttribute read GetListPrevRow;
    property ListRemain[Index: Integer]: Integer read GetListRemain;
    property ListRow[Index: Integer]: TEditorRowAttribute read GetListRow;
    property ListString[Index: Integer]: String read GetListString;
    property ListToken[Index: Integer]: Char read GetListToken;
    property ListWrappedByte[Index: Integer]: Integer read GetListWrappedByte;
    property ListRowMarks[Index: Integer]: TRowMarks read GetListRowMarks write SetListRowMarks;
    property LeftScrollWidth: Integer read FLeftScrollWidth;
    property Modified: Boolean read FModified write FModified;
    property OverWrite: Boolean read FOverWrite write SetOverWrite;
    property Row: Integer read FRow write SetRow;
    property RowCount: Integer read FRowCount;
    property RowHeight: Integer read GetRowHeight;
    property SelDrawPosition: TSelectedPosition read FSelDraw;
    property Selected: Boolean read GetSelected;
    property SelectedData: Boolean read GetSelectedData;
    property SelectedDraw: Boolean read GetSelectedDraw;
    property SelectionMode: TEditorSelectionMode read FSelectionMode write SetSelectionMode;
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelStrPosition: TSelectedPosition read FSelStr;
    property SelText: String read GetSelText write SetSelText;
    property TopCol: Integer read FTopCol write SetTopCol;
    property TopRow: Integer read FTopRow write SetTopRow;
  published
    {$IFDEF COMP4_UP} // exclude D2..D3
    property Anchors;
    property Constraints;
    property DragKind;
    {$ENDIF}
    property Align;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property Caret: TEditorCaret read FCaret write SetCaret;
    property Color default clWhite;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Fountain: TFountain read FFountain write SetFountain;
    property Font;
   {debug property HideSelection: Boolean read FHideSelection write FHideSelection;}
    property HitStyle: TEditorHitStyle read FHitStyle write SetHitStyle;
    property Imagebar: TEditorImagebar read FImagebar write SetImagebar;
    property ImageDigits: TImageList read FImageDigits write SetImageDigits;
    property ImageMarks: TImageList read FImageMarks write SetImageMarks;
    property ImeMode;
    property Lines: TStrings read FLines write SetLines;
    property Marks: TEditorMarks read FMarks write SetMarks;
    property Margin: TEditorMargin read FMargin write SetMargin;
    property Leftbar: TEditorLeftbar read FLeftbar write SetLeftbar;
    property ParentColor default False;
    property ParentCtl3D;
    property ParentFont default False;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly;
    property ReserveWordList: TStringList read GetReserveWordList write SetReserveWordList;
    property Ruler: TEditorRuler read FRuler write SetRuler;
    property ScrollBars: TScrollStyle read FScrollBars write SetScrollBars;
    property ShowHint;
    property Speed: TEditorSpeed read FSpeed write SetSpeed;
    property TabOrder;
    property TabStop default True;
    property UndoListMax: Integer read GetUndoListMax write SetUndoListMax;
    property View: TEditorViewInfo read FView write SetView;
    property Visible;
    property WantReturns: Boolean read FWantReturns write FWantReturns;
    property WantTabs: Boolean read FWantTabs write FWantTabs;
    property WordWrap: Boolean read GetWordWrap write SetWordWrap;
    property WrapOption: TEditorWrapOption read GetWrapOption write SetWrapOption;
    property OnCaretMoved: TNotifyEvent read FOnCaretMoved write FOnCaretMoved; // キャレットが移動した後に発生するイベント
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
    property OnDblClick;
    property OnDrawLine: TDrawLineEvent read FOnDrawLine write FOnDrawLine;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnSelectionChange: TSelectionChangeEvent read FOnSelectionChange write FOnSelectionChange;
    property OnSelectionModeChange: TNotifyEvent read FOnSelectionModeChange write FOnSelectionModeChange;
    property OnTopColChange: TNotifyEvent read FOnTopColChange write FOnTopColChange;
    property OnTopRowChange: TNotifyEvent read FOnTopRowChange write FOnTopRowChange;
    property OnStartDrag;
    {$IFDEF COMP4_UP} // exclude D2..D3
    property OnCanResize;
    property OnResize;
    property OnEndDock;
    property OnStartDock;
    {$ENDIF}
    {$IFDEF COMP5_UP} // exclude D2..D4
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    {$ENDIF}
  end;


implementation

uses
  heUtils, heStrConsts;


{ TEditorCursors }

constructor TEditorCursors.Create;
begin
  FDefaultCursor := crIBeam;
  FDragSelCursor := crDrag;
  FDragSelCopyCursor := crDragSelCopy;
  FInSelCursor := crDefault;
  FLeftMarginCursor := crRightArrow;
  FTopMarginCursor := crDefault;
end;

procedure TEditorCursors.Assign(Source: TPersistent);
begin
  if Source is TEditorCursors then
  begin
    FDefaultCursor := TEditorCursors(Source).FDefaultCursor;
    FDragSelCursor := TEditorCursors(Source).FDragSelCursor;
    FDragSelCopyCursor := TEditorCursors(Source).FDragSelCopyCursor;
    FInSelCursor := TEditorCursors(Source).FInSelCursor;
    FLeftMarginCursor := TEditorCursors(Source).FLeftMarginCursor;
    FTopMarginCursor := TEditorCursors(Source).FTopMarginCursor;
    Changed;
  end
  else
    inherited Assign(Source);
end;


{ TEditorCaret }

constructor TEditorCaret.Create;
begin
  FAutoCursor := True;
  FAutoIndent := True;
  FBackSpaceUnIndent := True;
  FFreeCaret := True;
  FRowSelect := True;
  FSelDragMode := dmAutomatic;
  FSelMove := True;
  FTabSpaceCount := 8;
  FCursors := TEditorCursors.Create;
end;

destructor TEditorCaret.Destroy;
begin
  FCursors.Free;
  inherited Destroy;
end;

procedure TEditorCaret.Assign(Source: TPersistent);
begin
  if Source is TEditorCaret then
  begin
    BeginUpdate;
    try
      FAutoCursor := TEditorCaret(Source).FAutoCursor;
      FAutoIndent := TEditorCaret(Source).FAutoIndent;
      FBackSpaceUnIndent := TEditorCaret(Source).FBackSpaceUnIndent;
      FCursors.Assign(TEditorCaret(Source).FCursors);
      FFreeCaret := TEditorCaret(Source).FFreeCaret;
      FFreeRow := TEditorCaret(Source).FFreeRow;
      FInTab := TEditorCaret(Source).FInTab;
      FKeepCaret := TEditorCaret(Source).FKeepCaret;
      FLockScroll := TEditorCaret(Source).FLockScroll;
      FNextLine := TEditorCaret(Source).FNextLine;
      FPrevSpaceIndent := TEditorCaret(Source).FPrevSpaceIndent;
      FRowSelect := TEditorCaret(Source).FRowSelect;
      FSelDragMode := TEditorCaret(Source).FSelDragMode;
      FSelMove := TEditorCaret(Source).FSelMove;
      FSoftTab := TEditorCaret(Source).FSoftTab;
      FStyle := TEditorCaret(Source).FStyle;
      FTabIndent := TEditorCaret(Source).FTabIndent;
      FTabSpaceCount := TEditorCaret(Source).FTabSpaceCount;
      FTokenEndStop := TEditorCaret(Source).FTokenEndStop;
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TEditorCaret.SetStyle(Value: TEditorCaretStyle);
begin
  if FStyle <> Value then
  begin
    FStyle := Value;
    Changed;
  end;
end;

procedure TEditorCaret.SetTabSpaceCount(Value: Integer);
begin
  Value := Max(2, Min(8, Value));
  Value := Value - Value mod 2;
  if FTabSpaceCount <> Value then
  begin
    FTabSpaceCount := Value;
    Changed;
  end;
end;


{ TEditorMargin }

constructor TEditorMargin.Create;
begin
  FCharacter := 0;
  FLeft := 19;
  FLine := 0;
  FTop := 2;
  FUnderline := 0;
end;

procedure TEditorMargin.Assign(Source: TPersistent);
begin
  if Source is TEditorMargin then
  begin
    BeginUpdate;
    try
      FCharacter := TEditorMargin(Source).FCharacter;
      FLeft := TEditorMargin(Source).FLeft;
      FLine := TEditorMargin(Source).FLine;
      FTop := TEditorMargin(Source).FTop;
      FUnderline := TEditorMargin(Source).FUnderline;
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TEditorMargin.SetCharacter(Value: Integer);
begin
  Value := Min(MarginLimit, Max(0, Value));
  if FCharacter <> Value then
  begin
    FCharacter := Value;
    Changed;
  end;
end;

procedure TEditorMargin.SetLeft(Value: Integer);
begin
  Value := Min(MarginLimit, Max(0, Value));
  if FLeft <> Value then
  begin
    FLeft := Value;
    Changed;
  end;
end;

procedure TEditorMargin.SetLine(Value: Integer);
begin
  Value := Min(MarginLimit, Max(0, Value));
  if FLine <> Value then
  begin
    FLine := Value;
    Changed;
  end;
end;

procedure TEditorMargin.SetTop(Value: Integer);
begin
  Value := Min(MarginLimit, Max(0, Value));
  if FTop <> Value then
  begin
    FTop := Value;
    Changed;
  end;
end;

procedure TEditorMargin.SetUnderline(Value: Integer);
begin
  Value := Min(MarginLimit, Max(0, Value));
  if FUnderline <> Value then
  begin
    FUnderline := Value;
    Changed;
  end;
end;


{ TEditorMark }

constructor TEditorMark.Create;
begin
  FColor := clGray;
end;

procedure TEditorMark.Assign(Source: TPersistent);
begin
  if Source is TEditorMark then
  begin
    FColor := TEditorMark(Source).FColor;
    FVisible := TEditorMark(Source).FVisible;
    Changed;
  end
  else
    inherited Assign(Source);
end;

procedure TEditorMark.SetColor(Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Changed;
  end;
end;

procedure TEditorMark.SetVisible(Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Changed;
  end;
end;


{ TEditorMarks }

constructor TEditorMarks.Create;
begin
  FEofMark := TEditorMark.Create;
  FEofMark.OnChange := ChangedProc;
  FRetMark := TEditorMark.Create;
  FRetMark.OnChange := ChangedProc;
  FWrapMark := TEditorMark.Create;
  FWrapMark.OnChange := ChangedProc;
  FHideMark := TEditorMark.Create;
  FHideMark.OnChange := ChangedProc;
  FUnderline := TEditorMark.Create;
  FUnderline.OnChange := ChangedProc;
end;

destructor TEditorMarks.Destroy;
begin
  FEofMark.Free;
  FRetMark.Free;
  FWrapMark.Free;
  FHideMark.Free;
  FUnderline.Free;
  inherited Destroy;
end;

procedure TEditorMarks.Assign(Source: TPersistent);
begin
  if Source is TEditorMarks then
  begin
    BeginUpdate;
    try
      FEofMark.Assign(TEditorMarks(Source).FEofMark);
      FRetMark.Assign(TEditorMarks(Source).FRetMark);
      FWrapMark.Assign(TEditorMarks(Source).FWrapMark);
      FHideMark.Assign(TEditorMarks(Source).FHideMark);
      FUnderline.Assign(TEditorMarks(Source).FUnderline);
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TEditorMarks.SetEofMark(Value: TEditorMark);
begin
  FEofMark.Assign(Value);
end;

procedure TEditorMarks.SetRetMark(Value: TEditorMark);
begin
  FRetMark.Assign(Value);
end;

procedure TEditorMarks.SetWrapMark(Value: TEditorMark);
begin
  FWrapMark.Assign(Value);
end;

procedure TEditorMarks.SetHideMark(Value: TEditorMark);
begin
  FHideMark.Assign(Value);
end;

procedure TEditorMarks.SetUnderline(Value: TEditorMark);
begin
  FUnderline.Assign(Value);
end;


{ TEditorViewInfo }

constructor TEditorViewInfo.Create;
begin
  FEditorFountain := CreateEditorFountain;
end;

destructor TEditorViewInfo.Destroy;
begin
  FEditorFountain.Free;
  inherited Destroy;
end;

function TEditorViewInfo.CreateEditorFountain: TEditorFountain;
begin
  Result := TEditorFountain.Create(nil);
  Result.NotifyEventList.Add(ChangedProc);
end;

procedure TEditorViewInfo.Assign(Source: TPersistent);
begin
  if Source is TEditorViewInfo then
  begin
    BeginUpdate;
    try
      Brackets.Assign(TEditorViewInfo(Source).Brackets);
      Colors.Assign(TEditorViewInfo(Source).Colors);
      Commenter := TEditorViewInfo(Source).Commenter;
      ControlCode := TEditorViewInfo(Source).ControlCode;
      HexPrefix := TEditorViewInfo(Source).HexPrefix;
      Mail := TEditorViewInfo(Source).Mail;
      Quotation := TEditorViewInfo(Source).Quotation;
      Url := TEditorViewInfo(Source).Url;
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

function TEditorViewInfo.GetOwner: TPersistent;
begin
  Result := FComponent;
end;

function TEditorViewInfo.GetBrackets: TEditorBracketCollection;
begin
  Result := TEditorBracketCollection(FEditorFountain.Brackets);
end;

function TEditorViewInfo.GetColors: TEditorColors;
begin
  Result := FEditorFountain.Colors;
end;

function TEditorViewInfo.GetCommenter: String;
begin
  Result := FEditorFountain.Commenter;
end;

function TEditorViewInfo.GetControlCode: Boolean;
begin
  Result := FEditorFountain.ControlCode;
end;

function TEditorViewInfo.GetHexPrefix: String;
begin
  Result := FEditorFountain.HexPrefix;
end;

function TEditorViewInfo.GetMail: Boolean;
begin
  Result := FEditorFountain.Mail;
end;

function TEditorViewInfo.GetQuotation: String;
begin
  Result := FEditorFountain.Quotation;
end;

function TEditorViewInfo.GetUrl: Boolean;
begin
  Result := FEditorFountain.Url;
end;

procedure TEditorViewInfo.SetBrackets(Value: TEditorBracketCollection);
begin
  FEditorFountain.Brackets.Assign(Value);
end;

procedure TEditorViewInfo.SetColors(Value: TEditorColors);
begin
  FEditorFountain.Colors.Assign(Value);
end;

procedure TEditorViewInfo.SetHexPrefix(Value: String);
begin
  if FEditorFountain.HexPrefix <> Value then
  begin
    FEditorFountain.HexPrefix := Value;
    Changed;
  end;
end;

procedure TEditorViewInfo.SetCommenter(Value: String);
begin
  if FEditorFountain.Commenter <> Value then
  begin
    FEditorFountain.Commenter := Value;
    Changed;
  end;
end;

procedure TEditorViewInfo.SetControlCode(Value: Boolean);
begin
  if FEditorFountain.ControlCode <> Value then
  begin
    FEditorFountain.ControlCode := Value;
    Changed;
  end;
end;

procedure TEditorViewInfo.SetMail(Value: Boolean);
begin
  if FEditorFountain.Mail <> Value then
  begin
    FEditorFountain.Mail := Value;
    Changed;
  end;
end;

procedure TEditorViewInfo.SetQuotation(Value: String);
var
  S: String;
begin
  if Length(Value) > 0 then
    S := Value[1]
  else
    S := '';
  if FEditorFountain.Quotation <> S then
  begin
    FEditorFountain.Quotation := S;
    Changed;
  end;
end;

procedure TEditorViewInfo.SetUrl(Value: Boolean);
begin
  if FEditorFountain.Url <> Value then
  begin
    FEditorFountain.Url := Value;
    Changed;
  end;
end;


{ TEditorRuler }

constructor TEditorRuler.Create;
begin
  FBkColor := clSilver;
  FColor := clBlack;
  FEdge := True;
  FMarkColor := clBlack;
  FGaugeRange := 10;
end;

procedure TEditorRuler.Assign(Source: TPersistent);
begin
  if Source is TEditorRuler then
  begin
    FBkColor := TEditorRuler(Source).FBkColor;
    FColor := TEditorRuler(Source).FColor;
    FEdge := TEditorRuler(Source).FEdge;
    FGaugeRange := TEditorRuler(Source).FGaugeRange;
    FMarkColor := TEditorRuler(Source).FMarkColor;
    FVisible := TEditorRuler(Source).FVisible;
    Changed;
  end
  else
    inherited Assign(Source);
end;

procedure TEditorRuler.SetBkColor(Value: TColor);
begin
  if FBkColor <> Value then
  begin
    FBkColor := Value;
    Changed;
  end;
end;

procedure TEditorRuler.SetColor(Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Changed;
  end;
end;

procedure TEditorRuler.SetEdge(Value: Boolean);
begin
  if FEdge <> Value then
  begin
    FEdge := Value;
    Changed;
  end;
end;

procedure TEditorRuler.SetGaugeRange(Value: Integer);
begin
  Value := Max(8, Min(10, Value));
  Value := Value - Value mod 2;
  if FGaugeRange <> Value then
  begin
    FGaugeRange := Value;
    Changed;
  end;
end;

procedure TEditorRuler.SetMarkColor(Value: TColor);
begin
  if FMarkColor <> Value then
  begin
    FMarkColor := Value;
    Changed;
  end;
end;

procedure TEditorRuler.SetVisible(Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Changed;
  end;
end;


{ TEditorLeftbar }

constructor TEditorLeftbar.Create;
begin
  FBkColor := clSilver;
  FColor := clBlack;
  FColumn := 4;
  FEdge := True;
  FLeftMargin := 8;
  FRightMargin := 4;
  FShowNumber := True;
end;

procedure TEditorLeftbar.Assign(Source: TPersistent);
begin
  if Source is TEditorLeftbar then
  begin
    FBkColor := TEditorLeftbar(Source).FBkColor;
    FColor := TEditorLeftbar(Source).FColor;
    FColumn := TEditorLeftbar(Source).FColumn;
    FEdge := TEditorLeftbar(Source).FEdge;
    FLeftMargin := TEditorLeftbar(Source).FLeftMargin;
    FRightMargin := TEditorLeftbar(Source).FRightMargin;
    FShowNumber := TEditorLeftbar(Source).FShowNumber;
    FShowNumberMode := TEditorLeftbar(Source).FShowNumberMode;
    FVisible := TEditorLeftbar(Source).FVisible;
    FZeroBase := TEditorLeftbar(Source).FZeroBase;
    FZeroLead := TEditorLeftbar(Source).FZeroLead;
    Changed;
  end
  else
    inherited Assign(Source);
end;

procedure TEditorLeftbar.SetBkColor(Value: TColor);
begin
  if FBkColor <> Value then
  begin
    FBkColor := Value;
    Changed;
  end;
end;

procedure TEditorLeftbar.SetColor(Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Changed;
  end;
end;

procedure TEditorLeftbar.SetColumn(Value: Integer);
begin
  Value := Min(8, Max(1, Value));
  if FColumn <> Value then
  begin
    FColumn := Value;
    Changed;
  end;
end;

procedure TEditorLeftbar.SetEdge(Value: Boolean);
begin
  if FEdge <> Value then
  begin
    FEdge := Value;
    Changed;
  end;
end;

procedure TEditorLeftbar.SetLeftMargin(Value: Integer);
begin
  Value := Min(MarginLimit, Max(0, Value));
  if FLeftMargin <> Value then
  begin
    FLeftMargin := Value;
    Changed;
  end;
end;

procedure TEditorLeftbar.SetRightMargin(Value: Integer);
begin
  Value := Min(MarginLimit, Max(0, Value));
  if FRightMargin <> Value then
  begin
    FRightMargin := Value;
    Changed;
  end;
end;

procedure TEditorLeftbar.SetShowNumber(Value: Boolean);
begin
  if FShowNumber <> Value then
  begin
    FShowNumber := Value;
    Changed;
  end;
end;

procedure TEditorLeftbar.SetShowNumberMode(Value: TEditorShowNumberMode);
begin
  if FShowNumberMode <> Value then
  begin
    FShowNumberMode := Value;
    Changed;
  end;
end;

procedure TEditorLeftbar.SetVisible(Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Changed;
  end;
end;

procedure TEditorLeftbar.SetZeroBase(Value: Boolean);
begin
  if FZeroBase <> Value then
  begin
    FZeroBase := Value;
    Changed;
  end;
end;

procedure TEditorLeftbar.SetZeroLead(Value: Boolean);
begin
  if FZeroLead <> Value then
  begin
    FZeroLead := Value;
    Changed;
  end;
end;


{ TEditorImagebar }

constructor TEditorImagebar.Create;
begin
  FDigitWidth := 8;
  FLeftMargin := 2;
  FMarkWidth := 0;
  FRightMargin := 2;
  FVisible := True;
end;

procedure TEditorImagebar.Assign(Source: TPersistent);
begin
  if Source is TEditorImagebar then
  begin
    FDigitWidth := TEditorImagebar(Source).FDigitWidth;
    FLeftMargin := TEditorImagebar(Source).FLeftMargin;
    FMarkWidth := TEditorImagebar(Source).FMarkWidth;
    FRightMargin := TEditorImagebar(Source).FRightMargin;
    FVisible := TEditorImagebar(Source).FVisible;
    Changed;
  end
  else
    inherited Assign(Source);
end;

procedure TEditorImagebar.SetDigitWidth(Value: Integer);
begin
  Value := Min(MarginLimit, Max(0, Value));
  if FDigitWidth <> Value then
  begin
    FDigitWidth := Value;
    Changed;
  end;
end;

procedure TEditorImagebar.SetLeftMargin(Value: Integer);
begin
  Value := Min(MarginLimit, Max(0, Value));
  if FLeftMargin <> Value then
  begin
    FLeftMargin := Value;
    Changed;
  end;
end;

procedure TEditorImagebar.SetMarkWidth(Value: Integer);
begin
  Value := Min(MarginLimit, Max(0, Value));
  if FMarkWidth <> Value then
  begin
    FMarkWidth := Value;
    Changed;
  end;
end;

procedure TEditorImagebar.SetRightMargin(Value: Integer);
begin
  Value := Min(MarginLimit, Max(0, Value));
  if FRightMargin <> Value then
  begin
    FRightMargin := Value;
    Changed;
  end;
end;

procedure TEditorImagebar.SetVisible(Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Changed;
  end;
end;


{ TEditorSpeed }

constructor TEditorSpeed.Create;
begin
  FInitBracketsFull := False;
  FCaretVerticalAc := 2;
  FPageVerticalRange := 2;
  FPageVerticalRangeAc := 2;
end;

procedure TEditorSpeed.Assign(Source: TPersistent);
begin
  if Source is TEditorSpeed then
  begin
    FInitBracketsFull := TEditorSpeed(Source).FInitBracketsFull;
    FCaretVerticalAc := TEditorSpeed(Source).FCaretVerticalAc;
    FPageVerticalRange := TEditorSpeed(Source).FPageVerticalRange;
    FPageVerticalRangeAc := TEditorSpeed(Source).FPageVerticalRangeAc;
  end
  else
    inherited Assign(Source);
end;


{ TEditorAttributeArray }

(*
  TEditorScreenStrings.StrToWrapList, WrapCount メソッドのヘルパー
  オブジェクト。コンストラクタの Attributes 引数には、Source よりも
  短い文字列がやってくる場合もある。cf TEditor.StrToAttributes
*)

constructor TEditorAttributeArray.Create(const Source, Attributes: String);
begin
  NewData(Source, Attributes);
end;

procedure TEditorAttributeArray.NewData(const Source, Attributes: String);
begin
  FSource := Source;
  FAttributes := Attributes + caEof;
  FPosition := 0;
  FSourcePos := 0;
  Next;
end;

function TEditorAttributeArray.GetSize: Integer;
begin
  Result := Length(FAttributes) - 1;
end;

procedure TEditorAttributeArray.Next;
begin
  if FAttribute <> caEof then
  begin
    Inc(FPosition);
    FAttribute := FAttributes[FPosition];
    if FAttribute <> caTabSpace then
      Inc(FSourcePos);
  end;
end;

function TEditorAttributeArray.NextPositionString: String;
begin
  Next;
  Result := PositionString;
  Prior;
end;

function TEditorAttributeArray.PositionString: String;
begin
  if FAttribute = caEof then
    Result := ''
  else
    if FAttribute = caDBCS2 then
      Result := FSource[FSourcePos - 1] +
                FSource[FSourcePos]
    else
      if FAttribute = caDBCS1 then
        Result := FSource[FSourcePos] +
                  FSource[FSourcePos + 1]
      else
        Result := FSource[FSourcePos];
end;

procedure TEditorAttributeArray.Prior;
var
  Old: Char;
begin
  if FPosition > 1 then
  begin
    Old := FAttribute;
    Dec(FPosition);
    FAttribute := FAttributes[FPosition];
    if FAttribute <> caTabSpace then
      Dec(FSourcePos)
    else
      if Old <> caTabSpace then
        Dec(FSourcePos);
  end;
end;

procedure TEditorAttributeArray.SetPosition(Value: Integer);
begin
  if FPosition < Value then
    while (FAttribute <> caEof) and (FPosition < Value) do Next
  else
    if FPosition > Value then
      while (FPosition > 1) and (FPosition > Value) do Prior;
end;


{ TEditorScreenStrings }

(*
#ScreenStrings 文字列の更新、undo, redo, 再描画の仕組み

Loaded, LoadFromFile など、文字列が全面的に変更された場合は、
InitBrackets メソッドを実行する。また部分的な文字列更新の場合は、
UpdateBrackets メソッドを実行する。

文字列の更新、undo, redo への対応、再描画の仕組みについて

文字列の更新は、TEditorScreenStrings.UpdateList を通して行われる。
UpdateList では、TEditorUndoObj を更新し、再描画するべき領域を
UpdateDrawInfo メソッドによって DrawInfo に格納してから ChangeList,
DeleteList, InsertList 各メソッドを利用して文字列を更新し、
UpdateBrackets している。

UpdateList メソッド内で EndUpdate された時点で、OnChange に Assign
されている ChangeLink から FClients に格納されている各 TEditor に
変更が通知され、各 TEditor の DoChange メソッドが実行される。

TEditor.DoChange では、スクロールバーの更新を行い、
TEditorScreenStrings.DrawInfo を参照し、NeedUpdate フラグが真の場合
だけ Modified プロパティを更新し、再描画を行っている。

一連の作業が終了後、TEditorScreenStrings.SetUpdateState で、DrawInfo
の初期化と、ClientsAdjustRow メソッド呼び出しによる FClients の各
TEditor の Row, TopRow の整合性確保の処理が行われている。

UpdateList メソッドを利用できないメソッド群について、

TEditorUndoObj のデータを元に動作する Undo, Redo メソッド、
及び TEditorUndoObj をクリアする Clear, WrapLines, StretchLines では、
UpdateList を利用することが出来ない。

Undo, Redo メソッドでは、文字列の更新、UpdateBrackets, UpdateDrawInfo
を自前で行い、再描画は EndUpdate からの仕組みを利用している。

Clear メソッドでは、UpdateDrawInfo メソッドを呼び出した後、
inherited な Clear メソッドによる ChangeLink -> DoChange の仕組みに
よって再描画を行っている。
また、Clear メソッドでは、BeginUpdate, EndUpdate が行われない
（SetUpdateState が実行されない）ので、DrawInfo を初期化し、FClients の
各 TEditor の Row, Col を 明示的に 0 に初期化している。

WrapLines, StretchLines では、Modified プロパティを更新すべきではない
ので、OnChange からの連鎖を一旦断ち切ってから処理を行っている。
従って、これら２つのメソッドを呼び出す場合は、ChangeLink -> DoChange
による再描画の仕組みを利用することが出来ないので、
InitScroll, Invalidate を FClients の各 TEditor について行う
ClientsInitView メソッド及び、ClientsAdjustRow, ClientsInitCol
メソッドを実行する必要がある。

*)

constructor TEditorScreenStrings.Create;
begin
  inherited Create; // create Items, Datas
  FUndoObj := CreateUndoObj;
  FWrapOption := CreateWrapOption;
  FClients := TList.Create;
  OnChange := ChangeLink;
end;

destructor TEditorScreenStrings.Destroy;
begin
  FClients.Free;
  FWrapOption.Free;
  FUndoObj.Free;
  inherited Destroy;
end;

procedure TEditorScreenStrings.Reference(Value: TEditor);
begin
  FClients.Add(Value);
end;

procedure TEditorScreenStrings.Release(Value: TEditor);
var
  I: Integer;
begin
  for I := 0 to FClients.Count - 1 do
    if FClients[I] = Value then
    begin
      FClients.Delete(I);
      Break;
    end;
  if FClients.Count = 0 then
    Free;
end;

function TEditorScreenStrings.CreateUndoObj: TEditorUndoObj;
begin
  Result := TEditorUndoObj.Create;
  Result.FList := Self;
end;

function TEditorScreenStrings.CreateWrapOption: TEditorWrapOption;
begin
  Result := TEditorWrapOption.Create;
  Result.OnChange := WrapOptionChanged;
end;

procedure TEditorScreenStrings.ChangeLink(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FClients.Count - 1 do
    TEditor(FClients[I]).DoChange;
end;

procedure TEditorScreenStrings.SetUpdateState(Updating: Boolean);
begin
  inherited SetUpdateState(Updating);
  (*
     TStringList.Changed -> TStringList.FOnChange ->
     TEditorScreenStrings.ChangeLink ->
     TEditor.DoChange -> TEditorScreen.Update
  *)
  if not Updating then
  begin
    // EndUpdate 後の処理
    FDrawInfo.Start := 0;
    FDrawInfo.Delete := 0;
    FDrawInfo.Insert := 0;
    FDrawInfo.Invalid := 0;
    FDrawInfo.NeedUpdate := False;
    // Row, TopRow の整合性を確保する。
    // Col は SetRow -> AdjustCol で行われる
    ClientsAdjustRow;
  end;
end;

procedure TEditorScreenStrings.WrapOptionChanged(Sender: TObject);
begin
  if csLoading in Client.ComponentState then
    Exit; // operate in Client.Loaded
  if FWordWrap then
  begin
    FUndoObj.Clear;
    WrapLines;
    InitBrackets;
    ClientsInitView;
    ClientsAdjustRow;
    ClientsInitCol;
  end;
end;

procedure TEditorScreenStrings.SetWordWrap(Value: Boolean);
begin
  if FWordWrap <> Value then
  begin
    FWordWrap := Value;
    if csLoading in Client.ComponentState then
      Exit; // Operate in Client.Loaded
    FUndoObj.Clear;
    if FWordWrap then
      WrapLines
    else
      StretchLines;
    InitBrackets;
    ClientsInitView;
    ClientsAdjustRow;
    ClientsInitCol;
  end;
end;

function TEditorScreenStrings.GetActiveClient: TEditor;
var
  I: Integer;
begin
  for I := 0 to FClients.Count - 1 do
    if TEditor(FClients[I]).Focused then
    begin
      Result := TEditor(FClients[I]);
      Exit;
    end;
  Result := GetClient;
end;

function TEditorScreenStrings.GetClient: TEditor;
begin
  Result := TEditor(FClients[0]);
end;

procedure TEditorScreenStrings.Clear;
(*
  inherited Clear による ChangeLink -> DoChange の仕組みによって
  再描画が行われる。
  BeginUpdate, EndUpdate は行われない（SetUpdateState が実行され
  ない）ので、FDrawInfo を初期化し、明示的に各 TEditor の Row, Col
  を 0 に初期化する。
*)
var
  I: Integer;
begin
  ClientsCleanSelection;
  FUndoObj.Clear;
  UpdateDrawInfo(0, Count, 0, 0); // Modified 設定と再描画のため
  inherited Clear;
  FDrawInfo.Start := 0;
  FDrawInfo.Delete := 0;
  FDrawInfo.Insert := 0;
  FDrawInfo.Invalid := 0;
  FDrawInfo.NeedUpdate := False;
  for I := 0 to FClients.Count - 1 do
  begin
    TEditor(FClients[I]).Row := 0;
    TEditor(FClients[I]).Col := 0;
  end;
  FValidRowMarks := [];
end;

procedure TEditorScreenStrings.Undo;
begin
  FUndoObj.Undo;
end;

procedure TEditorScreenStrings.Redo;
begin
  FUndoObj.Redo;
end;

procedure TEditorScreenStrings.ExcludeRowMarks(Marks: TRowMarks);
begin
  FValidRowMarks := FValidRowMarks - Marks;
end;

procedure TEditorScreenStrings.IncludeRowMarks(Marks: TRowMarks);
begin
  FValidRowMarks := FValidRowMarks + Marks;
end;

function TEditorScreenStrings.ValidRowMarks: TRowMarks;
begin
  Result := FValidRowMarks;
end;

procedure TEditorScreenStrings.ChangeList(Index, DeleteCount: Integer;
  List: TEditorStringList);
(*
  Index から DeleteCount 行を削除し、Index の位置に List を挿入する
*)
var
  I, Ir, Idx: Integer;
  M: TRowMarks;
begin
  BeginUpdate;
  try
    Ir := List.Count;
    M := [];
    if DeleteCount > Ir then
    begin
      // delete
      M := DeleteList(Index, DeleteCount - Ir);
      // RowMarks
      for I := 0 to Ir - 1 do
        List.RowMarks[I] := RowMarks[Index + I];
      if Ir > 0 then
        List.RowMarks[0] := List.RowMarks[0] + M
      else
        ExcludeRowMarks(M);
    end
    else
      if DeleteCount < Ir then
      begin
        // allocate
        Idx := Count - 1;
        for I := 0 to Ir - DeleteCount - 1 do
          Add('');
        // move
        for I := Idx downto Index + DeleteCount do
        begin
          Put(I + Ir - DeleteCount, Strings[I]);
          Items[I + Ir - DeleteCount] := Items[I];
          Items2[I + Ir - DeleteCount] := Items2[I];
          Datas[I + Ir - DeleteCount] := Datas[I];
          DataStrings[I + Ir - DeleteCount] := DataStrings[I];
        end;
        // RowMarks
        for I := Index + DeleteCount - 1 downto Index + 1 do
          List.RowMarks[I - Index + Ir - DeleteCount] := RowMarks[I];
        if DeleteCount > 0 then
          if ActiveClient.Col = 0 then
            List.RowMarks[Ir - DeleteCount] := RowMarks[Index]
          else
            List.RowMarks[0] := RowMarks[Index];
      end
      else
        // DeleteCount = Ir
        // RowMarks
        for I := 0 to Ir - 1 do
          List.RowMarks[I] := RowMarks[Index + I];
    // put
    for I := 0 to Ir - 1 do
    begin
      if Index + I > Count - 1 then
        Add('');
      Put(Index + I, List[I]);
      Items[Index + I] := List.Items[I];
      Items2[Index + I] := List.Items2[I];
      Datas[Index + I] := List.Datas[I];
      DataStrings[Index + I] := List.DataStrings[I];
    end;
  finally
    EndUpdate;
  end;
end;

function TEditorScreenStrings.DeleteList(Index, DeleteCount: Integer): TRowMarks;
(*
  Index の位置からの DeleteCount 行を削除する
  DeleteCount 分の領域を移動した後、不要になった DeleteCount 分の
  末尾を削除する
  削除される領域にあった RowMarks の和を返り値とする
*)
var
  I: Integer;
begin
  Result := [];
  if (Index < 0) or (Index > Count - 1) or (DeleteCount = 0) then
    Exit;
  BeginUpdate;
  try
    // RowMarks;
    for I := Index to Index + DeleteCount - 1 do
      Result := Result + RowMarks[I];
    // move
    for I := Index + DeleteCount to Count - 1 do
      if I - DeleteCount >= 0 then
      begin
        Put(I - DeleteCount, Strings[I]);
        Items[I - DeleteCount] := Items[I];
        Items2[I - DeleteCount] := Items2[I];
        Datas[I - DeleteCount] := Datas[I];
        DataStrings[I - DeleteCount] := DataStrings[I];
      end;
    // delete
    for I := 0 to DeleteCount - 1 do
      Delete(Count - 1);
  finally
    EndUpdate;
  end;
end;

procedure TEditorScreenStrings.InsertList(Index: Integer;
  List: TEditorStringList);
(*
  Index の位置に List を挿入出来るだけの領域を
  確保してから、その領域を List で更新する
*)
var
  Ir, I, Idx: Integer;
begin
  BeginUpdate;
  try
    Ir := List.Count;
    Idx := Count - 1;
    // allocate
    for I := 0 to Ir - 1 do
      Add('');
    // move
    for I := Idx downto Index do
    begin
      Put(I + Ir, Strings[I]);
      Items[I + Ir] := Items[I];
      Items2[I + Ir] := Items2[I];
      Datas[I + Ir] := Datas[I];
      DataStrings[I + Ir] := DataStrings[I];
    end;
    // update
    for I := 0 to Ir - 1 do
    begin
      Put(I + Index, List[I]);
      Items[I + Index] := List.Items[I];
      Items2[I + Index] := List.Items2[I];
      Datas[I + Index] := List.Datas[I];
      DataStrings[I + Index] := List.DataStrings[I];
    end;
  finally
    EndUpdate;
  end;
end;

procedure TEditorScreenStrings.CheckCrlf(Index: Integer; var S: String);
begin
  if (Index <= Count - 1) and (Rows[Index] = raCrlf) then
    S := S + #13#10;
end;

procedure TEditorScreenStrings.ListInfo(Index, TargetCount: Integer;
  var S: String; var TakenRowCount: Integer;
  var RowAttribute: TEditorRowAttribute);
(*
  Index で指定された行から、TargetCount が -1 の場合は、Count - 1 か
  raCrlf or raEof な行までの、TargetCount が 非 -1 の場合は
  Index + TargetCount - 1 の行までの文字列データを作成して S に代入する
  TakenRowCount には、データを作成する際取り込んだ行数
  RowAttribute には、最後に取り込んだ行の属性が代入される
  raCrlf な行文字列には #13#10 が付加される
  Index + TargetCount - 1 が Count - 1 を越える場合はエラーになるので、
  注意が必要
*)
var
  I, Last, Size, L: Integer;
  P: PChar;
  Str: String;
begin
  // 初期化
  S := '';
  TakenRowCount := 0;
  RowAttribute := raInvalid;
  if (Index < 0) or (Count - 1 < Index) then
    Exit;

  // 取得する行数をカウント
  if TargetCount = -1 then
  begin
    Last := Index;
    while (Last < Count - 1) and (Rows[Last] = raWrapped) do
      Inc(Last);
  end
  else
    Last := Index + TargetCount - 1;

  // 取り込む行数
  TakenRowCount := Last - Index + 1;
  // 最後に取り込む行属性
  RowAttribute := Rows[Last];
  // 文字列を作成
  Size := 0;
  for I := Index to Last do
  begin
    Inc(Size, Length(Get(I)));
    if Rows[I] = raCrlf then
      Inc(Size, 2);
  end;
  SetString(S, nil, Size);
  P := Pointer(S);
  for I := Index to Last do
  begin
    Str := Get(I);
    L := Length(Str);
    if L <> 0 then
    begin
      System.Move(Pointer(Str)^, P^, L);
      Inc(P, L);
    end;
    if Rows[I] = raCrlf then
    begin
      P^ := #13;
      Inc(P);
      P^ := #10;
      Inc(P);
    end;
  end;
end;

function TEditorScreenStrings.RowEnd(Index: Integer): Integer;
begin
  // Index を含む１行データが終わる Row を返す
  // エラーチェックは行わない
  Result := Index;
  while (Result >= 0) and (Result < Count - 1) and
        (Rows[Result] = raWrapped) do
    Inc(Result);
end;

function TEditorScreenStrings.RowStart(Index: Integer): Integer;
begin
  // Index を含む１行データが始まる Row を返す
  // エラーチェックは行わない
  Result := Index;
  while (Result > 0) and (Rows[Result - 1] = raWrapped) do
    Dec(Result);
end;

function TEditorScreenStrings.UpdateBrackets(Index: Integer; InvalidateFlag: Boolean): Integer;
(*
  Index より上の行で Brackets プロパティ値が -2 ぢゃないところまで遡り、
  以降の PrevRows, Brackets, Elements, WrappedBytes, Remains, Tokens,
  PrevTokens, DataStrings プロパティ値を更新する。

  更新する範囲は
  ・整合性が確保されるまで
  ・画面サイズ (Client.FRowCount) の２倍
    （ver 1.42 より、Screen.Height div GetRowHeight * 2 とする）
  ・Count - 1
  の最小値とする
  InvalidateFlag が True の場合は、プロパティ値を更新した領域を無効化する。
  UpdateWindow は行わない。無効化した行数が返値となる
*)
var
  Data: TRowAttributeData;
  I, Idx, J, K: Integer;
  Parser: TFountainParser;
begin
  Result := 0;
  if (Index < 0) or (Count - 1 < Index) then
    Exit;
  Parser := Client.ActiveFountain.ParserClass.Create(Client.ActiveFountain);
  try
    // -2 ぢゃない行まで遡って、そこのデータを取得する。
    Idx := -1;
    for I := Index - 1 downto 0 do
      if Brackets[I] <> InvalidBracketIndex then
      begin
        Data.RowAttribute := Rows[I];
        Data.PrevRowAttribute := PrevRows[I];
        Data.BracketIndex := Brackets[I];
        Data.ElementIndex := Elements[I];
        Data.WrappedByte := WrappedBytes[I];
        Data.Remain := Remains[I];
        Data.StartToken := Tokens[I];
        Data.PrevToken := PrevTokens[I];
        Data.DataStr := DataStrings[I];
        Parser.LastTokenBracket(I, Self, Data);
        Idx := I + 1;
        Break;
      end;
    // Index = 0 で上のループが回らなかったか、確定しなかった場合は
    // 先頭の行から更新する
    if Idx = -1 then
    begin
      Idx := 0;                                // ０行目から処理する。
      Data.RowAttribute := raCrlf;
      Data.PrevRowAttribute := raCrlf;
      Data.BracketIndex := NormalBracketIndex; // -1
      Data.ElementIndex := NormalElementIndex; //  0
      Data.WrappedByte := 0;
      Data.Remain := 0;
      Data.StartToken := toEof;
      Data.PrevToken := toEof;
      Data.DataStr := '';
    end;

    // ループの上限
    // 動的に生成される場合、Client.GetRowHeight が 0 になる場合があるので
    J := Min(Index + Screen.Height div Max(Client.GetRowHeight, 1) * 2, Count - 1);

    (*
      上の Idx - 1 行をパースして得たデータは Idx 行をパースするための
      データとなる。
      PrevRows[I], Brackets[I], Elements[I], WrappedBytes[I], Remains[I],
      Tokens[I], PrevTokens[I], DataStrings[I]
      プロパティ値をこのデータで更新しながらループさせる。
    *)

    for I := Idx to J do
    begin
      if (PrevRows[I] = Data.PrevRowAttribute) and
         (Brackets[I] = Data.BracketIndex) and
         (Elements[I] = Data.ElementIndex) and
         (WrappedBytes[I] = Data.WrappedByte) and
         (Remains[I] = Data.Remain) and
         (Tokens[I] = Data.StartToken) and
         (PrevTokens[I] = Data.PrevToken) and
         (DataStrings[I] = Data.DataStr) then
        // 整合性が確保された
        Exit;
      Data.RowAttribute := Rows[I];
      // Rows[I] := Data.RowAttribte; やってはいけない。
      PrevRows[I] := Data.PrevRowAttribute;
      Brackets[I] := Data.BracketIndex;
      Elements[I] := Data.ElementIndex;
      WrappedBytes[I] := Data.WrappedByte;
      Remains[I] := Data.Remain;
      Tokens[I] := Data.StartToken;
      PrevTokens[I] := Data.PrevToken;
      DataStrings[I] := Data.DataStr;
      if InvalidateFlag then
      begin
        Inc(Result);
        for K := 0 to FClients.Count - 1 do
          TEditor(FClients[K]).InvalidateLine(I);
      end;
      Parser.LastTokenBracket(I, Self, Data);
      Data.PrevRowAttribute := Rows[I];
    end;
  finally
    Parser.Free;
  end;
  // 更新していないデータを残したので、以下を -2 にする
  for I := J + 1 to Count - 1 do
  begin
    PrevRows[I] := raCrlf;
    Brackets[I] := InvalidBracketIndex; // -2
    Elements[I] := NormalElementIndex;  //  0
    WrappedBytes[I] := 0;
    Remains[I] := 0;
    Tokens[I] := toEof;
    PrevTokens[I] := toEof;
    DataStrings[I] := '';
  end;
end;

procedure TEditorScreenStrings.InitBrackets;
(*
  FList 各行の Brackets, Elements を初期化・更新する。
  一旦 InvalidBracketIndex, InvalidElementIndex, toEof で初期化した後
  LoadFromFile を高速化するために、先頭から見えている部分だけを更新する。
  それ以外の領域は、描画する際 InvalidBracketIndex を判別し
  UpdateBrackets で更新される仕様とする。
  Client.FSpeed.FInitBracketsFull の時は、全行を更新する。
*)
var
  Data: TRowAttributeData;
  I, J: Integer;
  Parser: TFountainParser;
begin
  if (csLoading in Client.ComponentState) or
     (csDestroying in Client.ComponentState) then
    Exit;
  // init
  for I := 0 to Count - 1 do
  begin
    // Rows[I] := raCrlf; never
    PrevRows[I] := raCrlf;
    Brackets[I] := InvalidBracketIndex; // -2
    Elements[I] := NormalElementIndex;  //  0
    WrappedBytes[I] := 0;
    Remains[I] := 0;
    Tokens[I] := toEof;
    PrevTokens[I] := toEof;
    DataStrings[I] := '';
  end;
  // update
  Data.RowAttribute := raCrlf;
  Data.PrevRowAttribute := raCrlf;
  Data.BracketIndex := NormalBracketIndex; // -1
  Data.ElementIndex := NormalElementIndex; //  0
  Data.WrappedByte := 0;
  Data.Remain := 0;
  Data.StartToken := toEof;
  Data.PrevToken := toEof;
  Data.DataStr := '';
  if Client.FSpeed.FInitBracketsFull then
    J := Count - 1
  else
    J := Min(
           Count - 1,
           Client.FTopRow +
             Screen.Height div Max(Client.GetRowHeight, 1) * 2
         );
  Parser := Client.ActiveFountain.ParserClass.Create(Client.ActiveFountain);
  try
    for I := 0 to J do
    begin
      Data.RowAttribute := Rows[I];
      // Rows[I] := raCrlf; never
      PrevRows[I] := Data.PrevRowAttribute;
      Brackets[I] := Data.BracketIndex;
      Elements[I] := Data.ElementIndex;
      WrappedBytes[I] := Data.WrappedByte;
      Remains[I] := Data.Remain;
      Tokens[I] := Data.StartToken;
      PrevTokens[I] := Data.PrevToken;
      DataStrings[I] := Data.DataStr;
      Parser.LastTokenBracket(I, Self, Data);
      Data.PrevRowAttribute := Rows[I];
    end;
  finally
    Parser.Free;
  end;
end;

procedure TEditorScreenStrings.UpdateDrawInfo(Index, DeleteCount,
  InsertCount, InvalidCount: Integer);
begin
  FDrawInfo.Start := Index;
  FDrawInfo.Delete := DeleteCount;
  FDrawInfo.Insert := InsertCount;
  FDrawInfo.Invalid := InvalidCount;
  FDrawInfo.NeedUpdate := True;
end;

procedure TEditorScreenStrings.UpdateList(Index, DeleteCount: Integer;
  const S: String);
(*
  Index から DeleteCount 行を削除し、Index へ S を挿入する
*)
var
  I, Rs, Re, Id, Dr, Ir, Ivr: Integer;
  Buf: String;
  RowAttribute: TEditorRowAttribute;
  WrapList: TEditorStringList;
  U: PUndoData;
  M: TRowMarks;

  function ListStr(Idx: Integer): String;
  begin
    if Rows[Idx] = raCrlf then
      Result := Strings[Idx] + #13#10
    else
      Result := Strings[Idx];
  end;

begin
  if (Index < 0) or (Index + DeleteCount - 1 > Count - 1) or
     ((DeleteCount = 0) and (S = '')) then
    Exit;
  // RowStart, RowEnd
  Rs := Max(RowStart(Index), Index - 1); // 整形データは１行上からで十分
  Id := Index + DeleteCount - 1;
  Re := RowEnd(Id);
  BeginUpdate;
  try
    // insert data
    if (Rs = Index) and (Re = Id) and (S = '') and (DeleteCount <> 0) then
    begin
      // 整形後に挿入するデータが無いので Undo データを保存後、削除
      // するだけ
      // undo data
      U := FUndoObj.Add;
      U.DataRow := Index;
      ListInfo(Index, DeleteCount, U.InsertStr, Dr, U.RowAttribute);
      Ir := 0;
      M := DeleteList(Index, DeleteCount);
      if Count > 0 then
      begin
        I := Min(Index, Count - 1);
        RowMarks[I] := RowMarks[I] + M;
      end
      else
        ExcludeRowMarks(M);
      Ivr := UpdateBrackets(Index, True);
    end
    else
    begin
      // 整形後のデータを挿入するので、RowAttribute が必要
      if (Id < Re) and (Re <= Count - 1) then
        // 行末を削除しない場合で、Re がリスト上の場合
        RowAttribute := Rows[Re]
      else
        // 行末を削除するか、リストから外れている場合
        if Re < Count - 1 then
        begin
          // リスト上なので、次の１行文字列を処理対象に加える
          Re := RowEnd(Re + 1);
          RowAttribute := Rows[Re];
        end
        else
          // リストの最後尾かリストを外れているので、
          // 挿入する文字列の後端で判別する
          if (Length(S) > 0) and (S[Length(S)] = #10) then
            RowAttribute := raCrlf
          else
            RowAttribute := raEof;
      // undo data
      U := FUndoObj.Add;
      U.DataRow := Rs;
      ListInfo(Rs, Re - Rs + 1, U.InsertStr, Dr, U.RowAttribute);
      // insert data
      Buf := '';
      for I := Rs to Index - 1 do
        Buf := Buf + ListStr(I);
      Buf := Buf + S;
      if DeleteCount = 0 then
        for I := Index to Id do
          Buf := Buf + ListStr(I);
      for I := Id + 1 to Re do
        Buf := Buf + ListStr(I);
      // changelist
      WrapList := TEditorStringList.Create;
      try
        StrToWrapList(Buf, WrapList);
        WrapList.Rows[WrapList.Count - 1] := RowAttribute;
        Ir := WrapList.Count;
        U.DeleteCount := Ir;
        ChangeList(Rs, Re - Rs + 1, WrapList);
        // Brackets の更新
        Ivr := UpdateBrackets(Rs, True);
      finally
        WrapList.Free;
      end;
    end;
    // 描画情報の更新
    UpdateDrawInfo(Rs, Dr, Ir, Ivr);
  finally
    EndUpdate; // -> OnChange (ChangeLink) -> FClients.DoChange -> FScreenUpdate (Draw)
  end;
end;

procedure TEditorScreenStrings.ClientsAdjustRow;
(*
  FClients の各 TEditor の Row の整合性を確保する。Row が更新されても、
  フォーカスを持っていない Editor のキャレットは動かないので、TopRow
  が変化しないという仕様なので、TopRow も更新する。
*)
var
  I: Integer;
  Editor: TEditor;
begin
  for I := 0 to FClients.Count - 1 do
  begin
    Editor := TEditor(FClients[I]);
    // Row
    if Editor.Row > Count - 1 then
      if Editor.ListRows(Count - 1) = raEof then
        Editor.Row := Count - 1
      else
        Editor.Row := Count;
    // TopRow
    if Editor.TopRow > Count - 1 then
      if Editor.ListRows(Count - 1) = raEof then
        Editor.TopRow := Count - 1
      else
        Editor.TopRow := Count;
  end;
end;

procedure TEditorScreenStrings.ClientsCleanSelection;
var
  I: Integer;
  Editor: TEditor;
begin
  for I := 0 to FClients.Count - 1 do
  begin
    Editor := TEditor(FClients[I]);
    if Editor.SelectedData then
      Editor.CleanSelection;
  end;
end;

procedure TEditorScreenStrings.ClientsInitCol;
var
  I: Integer;
begin
  for I := 0 to FClients.Count - 1 do
    TEditor(FClients[I]).Col := 0;
end;

procedure TEditorScreenStrings.ClientsInitView;
var
  I: Integer;
  Editor: TEditor;
begin
  for I := 0 to FClients.Count - 1 do
  begin
    Editor := TEditor(FClients[I]);
    Editor.InitDrawInfo;
    Editor.InitScroll;
    Editor.InitOriginBase;
    Editor.Invalidate;
  end;
end;

procedure TEditorScreenStrings.StretchLines;
var
  I, Idx: Integer;
  S: String;
  RowAttribute: TEditorRowAttribute;
  M: TRowMarks;
begin
  // 先詰めで処理し、不要部分を削除する
  if Count = 0 then
    Exit;
  ClientsCleanSelection;
  // Count - 1 の属性を引き継ぐための処理 raWrapped な
  // 最終行の場合もあるので raEof に変換する
  if Rows[Count - 1] = raWrapped then
    RowAttribute := raEof
  else
    RowAttribute := Rows[Count - 1];
  // stretch lines
  OnChange := nil;
  BeginUpdate;
  try
    Idx := 0;
    S := '';
    M := [];
    for I := 0 to Count - 1 do
    begin
      S := S + Get(I);
      M := M + RowMarks[I];
      if (I = Count - 1) or (Rows[I] <> raWrapped) then
      begin
        Put(Idx, S);
        Rows[Idx] := raCrlf;
        RowMarks[Idx] := M;
        Inc(Idx);
        S := '';
        M := [];
      end
    end;
    Rows[Idx - 1] := RowAttribute;
    DeleteList(Idx, Count - Idx);
  finally
    EndUpdate;
    OnChange := ChangeLink;
  end;
end;

procedure TEditorScreenStrings.StrToWrapList(const S: String; List: TEditorStringList);
(*
  S を #13#10 で切り分けて List に格納する。
  S = '' の場合は、空白行が１行追加される仕様とする。
  WrapLines がそういう仕様を望んでいるからである。
  WordWrap 時は、切り分けた文字列を BufList に格納し、
  BufList[n] を WrapByte, WordBreak, FollowPunctuation, Leading,
  FollowRetMark のプロパティ値に応じて切り分けてから List に格納する。
*)
var
  Str, FBuf, LBuf, Attr: String;
  I, Li, Capacity: Integer;
  BufList: TStringList;
  AttrArray: TEditorAttributeArray;

  procedure CheckAdd(const Value: String; RowAttribute: TEditorRowAttribute);
  begin
    if Li < Capacity then // if Li <= Capacity - 1 then
    begin
      List[Li] := Value;
      List.Rows[Li] := RowAttribute;
    end
    else
    begin
      List.Add(Value);
      List.Rows[List.Count - 1] := RowAttribute;
    end;
    Inc(Li); // 改行文字のぶら下げで、必要になる処理
  end;

begin
  List.BeginUpdate;
  try
    List.Clear;
    if S = '' then
      List.Add('')
    else
      if not FWordWrap then
        StrToStrings(S, List)
      else
      begin
        BufList := TStringList.Create;
        try
          // #13#10 で分割
          StrToStrings(S, BufList);
          // SetSelTextBuf から大容量の S がやってくる場合もあるので、
          // BufList.Count 分の領域をあらかじめ確保しておく。
          Capacity := BufList.Count;
          for I := 0 to Capacity - 1 do
            List.Add('');
          Li := 0; // List へのインデックス
          for I := 0 to BufList.Count - 1 do
          begin
            Str := BufList[I];
            Attr := Client.StrToAttributes(Str);
            if Length(Attr) < FWrapOption.FWrapByte then
              CheckAdd(Str, raCrlf)
            else
            begin
              AttrArray := TEditorAttributeArray.Create(Str, Attr);
              try
                AttrArray.Position := FWrapOption.FWrapByte;
                while AttrArray.Attribute <> caEof do
                begin
                  // caDBCS1
                  if AttrArray.Attribute = caDBCS1 then
                    AttrArray.Prior
                  else
                    // WordBreak
                    // 未処理文字列長が FWapOption.FWrapByte より長い場合
                    // FWrapByte の１／３を限度に PositionString がデリ
                    // ミタか全角文字の２バイト目になるまで戻す。
                    if FWrapOption.FWordBreak and
                       (AttrArray.Size > FWrapOption.FWrapByte) then
                    while not (AttrArray.Attribute in [caTabSpace, caDBCS2, caDelimiter]) and
                          (AttrArray.Position > FWrapOption.FWrapByte div 3) do
                    begin
                      AttrArray.Prior;
                      if AttrArray.Attribute = caDBCS1 then
                        AttrArray.Prior;
                    end;
                  // 句読点のぶら下げ
                  // 次の行頭に句読点が来る場合は、2 byte を限度に
                  // ぶら下げる。全角半角混在の場合は 3 byte になる
                  // 場合もある
                  if FWrapOption.FFollowPunctuation then
                  while (AttrArray.Position < FWrapOption.FWrapByte + 2) and
                        IsInclude(AttrArray.NextPositionString, FWrapOption.FPunctuationStr) do
                  begin
                    AttrArray.Next;
                    if AttrArray.Attribute = caDBCS1 then
                      AttrArray.Next;
                  end;

                  // 追い出し
                  if FWrapOption.FLeading and (AttrArray.Size > AttrArray.Position) then
                  begin
                    // 行末禁則処理
                    // PositionString が LeadStr（行末禁則文字）に含まれる
                    // 場合は FWrapByte の ４／５を限度に追い出す
                    while (AttrArray.Position > (FWrapOption.FWrapByte div 5) * 4) and
                          IsInclude(AttrArray.PositionString, FWrapOption.FLeadStr) do
                    begin
                      AttrArray.Prior;
                      if AttrArray.Attribute = caDBCS1 then
                        AttrArray.Prior;
                    end;

                    // 行頭禁則処理
                    // 次の行長が２以上あって、NextPositionString が
                    // FollowStr（行頭禁則文字）の場合、
                    // PositionString が LeadStr（行末禁則文字）か
                    // NextPositionString が FollowStr（行頭禁則文字）の
                    // 場合は FWrapByte の ４／５を限度に
                    // 追い出す
                    if AttrArray.Size > AttrArray.Position + 1 then
                    begin
                      FBuf := AttrArray.NextPositionString;
                      LBuf := AttrArray.PositionString;
                      if IsInclude(FBuf, FWrapOption.FFollowStr) then
                      while (AttrArray.Position > (FWrapOption.FWrapByte div 5) * 4) and
                            (IsInclude(LBuf, FWrapOption.FLeadStr) or IsInclude(FBuf, FWrapOption.FFollowStr)) do
                      begin
                        AttrArray.Prior;
                        if AttrArray.Attribute = caDBCS1 then
                          AttrArray.Prior;
                        FBuf := LBuf;
                        LBuf := AttrArray.PositionString;
                      end;
                    end;
                  end;

                  // 行末のタブ文字展開部が WrapByte を越えても構わない仕様とする

                  // Str の先頭から AttrArray.SourcePos までの文字列を追加し、削除する
                  CheckAdd(Copy(Str, 1, AttrArray.SourcePos), raWrapped);
                  System.Delete(Str, 1, AttrArray.SourcePos);
                  // 次のループのための処理
                  Attr := Client.StrToAttributes(Str);
                  AttrArray.NewData(Str, Attr);
                  AttrArray.Position := FWrapOption.FWrapByte;
                end;
                // ループを抜けた時点での処理
                if Length(Str) > 0 then
                  // 文字列が残っていれば raCrlf な行として追加
                  CheckAdd(Str, raCrlf)
                else
                  // Str が空白の場合
                  if not FWrapOption.FFollowRetMark then
                    // 改行のぶら下げを行なわない場合
                    CheckAdd('', raCrlf)
                  else
                    // 改行のぶら下げを行なう場合
                    if Li <= Capacity then // if Li - 1 <= Capacity - 1 then
                      List.Rows[Li - 1] := raCrlf
                    else
                      List.Rows[List.Count - 1] := raCrlf;
              finally
                AttrArray.Free;
              end;
            end;
          end;
        finally
          BufList.Free;
        end;
      end;
  finally
    List.EndUpdate;
  end;
end;

function TEditorScreenStrings.WrapCount(S: String): Integer;
(*
  FWrapOption プロパティ値で S が何行に折り返されるかを
  カウントする。
  S に #13#10 は含まれていないものとする
*)
var
  Attr, FBuf, LBuf: String;
  AttrArray: TEditorAttributeArray;
begin
  if not FWordWrap then
    Result := 1
  else
  begin
    Attr := Client.StrToAttributes(S);
    if Length(Attr) < FWrapOption.FWrapByte then
      Result := 1
    else
    begin
      Result := 0;
      AttrArray := TEditorAttributeArray.Create(S, Attr);
      try
        AttrArray.Position := FWrapOption.FWrapByte;
        while AttrArray.Attribute <> caEof do
        begin
          // caDBCS1
          if AttrArray.Attribute = caDBCS1 then
            AttrArray.Prior
          else
            // WordBreak
            if FWrapOption.FWordBreak and (AttrArray.Size > FWrapOption.FWrapByte) then
            while not (AttrArray.Attribute in [caTabSpace, caDBCS2, caDelimiter]) and
                  (AttrArray.Position > FWrapOption.FWrapByte div 3) do
            begin
              AttrArray.Prior;
              if AttrArray.Attribute = caDBCS1 then
                AttrArray.Prior;
            end;
          // 句読点のぶら下げ
          if FWrapOption.FFollowPunctuation then
          while (AttrArray.Position < FWrapOption.FWrapByte + 2) and
                IsInclude(AttrArray.NextPositionString, FWrapOption.FPunctuationStr) do
          begin
            AttrArray.Next;
            if AttrArray.Attribute = caDBCS1 then
              AttrArray.Next;
          end;
          // 追い出し
          if FWrapOption.FLeading and (AttrArray.Size > AttrArray.Position) then
          begin
            // 行末禁則処理
            while (AttrArray.Position > (FWrapOption.FWrapByte div 5) * 4) and
                  IsInclude(AttrArray.PositionString, FWrapOption.FLeadStr) do
            begin
              AttrArray.Prior;
              if AttrArray.Attribute = caDBCS1 then
                AttrArray.Prior;
            end;
            // 行頭禁則処理
            if AttrArray.Size > AttrArray.Position + 1 then
            begin
              FBuf := AttrArray.NextPositionString;
              LBuf := AttrArray.PositionString;
              if IsInclude(FBuf, FWrapOption.FFollowStr) then
              while (AttrArray.Position > (FWrapOption.FWrapByte div 5) * 4) and
                    (IsInclude(LBuf, FWrapOption.FLeadStr) or IsInclude(FBuf, FWrapOption.FFollowStr)) do
              begin
                AttrArray.Prior;
                if AttrArray.Attribute = caDBCS1 then
                  AttrArray.Prior;
                FBuf := LBuf;
                LBuf := AttrArray.PositionString;
              end;
            end;
          end;
          Inc(Result);
          System.Delete(S, 1, AttrArray.SourcePos);
          Attr := Client.StrToAttributes(S);
          AttrArray.NewData(S, Attr);
          AttrArray.Position := FWrapOption.FWrapByte;
        end;
        // ループを抜けた時点での処理
        if Length(S) > 0 then
          // 文字列がまだあった場合
          Inc(Result)
        else
          // 無かった場合
          if not FWrapOption.FFollowRetMark then
            // 改行マークをぶら下げる場合
            Inc(Result);
      finally
        AttrArray.Free;
      end;
    end;
  end;
end;

procedure TEditorScreenStrings.WrapLines;
var
  I, J, L, ListCount, NewListCount: Integer;
  S: String;
  BufList, WrapList: TEditorStringList;
  RowAttribute: TEditorRowAttribute;
  M: TRowMarks;
  MarkList: TList;
begin
  if (Count = 0) or (csLoading in Client.ComponentState) then
    Exit;
  ClientsCleanSelection;
  OnChange := nil;
  BeginUpdate;
  try
    // new list count
    NewListCount := 0;
    S := '';
    for I := 0 to Count - 1 do
    begin
      S := S + Get(I);
      if (I = Count - 1) or (Rows[I] <> raWrapped) then
      begin
        // FollowRetmark を考慮するので↓の判別は <= ではない
        if Client.ExpandTabLength(S) < FWrapOption.FWrapByte then
          Inc(NewListCount)
        else
          Inc(NewListCount, WrapCount(S));
        S := '';
      end;
    end;
    // Count - 1 の属性を保存
    RowAttribute := Rows[Count - 1];
    // word wrapp
    BufList := TEditorStringList.Create;
    try
      // alloc
      for I := 0 to NewListCount - 1 do
        BufList.Add('');
      // Strings -> BufList
      WrapList := TEditorStringList.Create;
      try
        L := 0;
        S := '';
        M := [];
        MarkList := TList.Create;
        try
          for I := 0 to Count - 1 do
          begin
            S := S + Get(I);
            M := M + RowMarks[I];
            MarkList.Add(Pointer(Word(RowMarks[I])));
            if (I = Count - 1) or (Rows[I] <> raWrapped) then
            begin
              if Client.ExpandTabLength(S) < FWrapOption.FWrapByte then
              begin
                BufList[L] := S;
                BufList.Rows[L] := raCrlf;
                BufList.RowMarks[L] := M;
                Inc(L);
              end
              else
              begin
                StrToWrapList(S, WrapList);
                // RowMarks
                if WrapList.Count >= MarkList.Count then
                  for J := 0 to MarkList.Count - 1 do
                    WrapList.RowMarks[J] := TRowMarks(Word(MarkList[J]))
                else
                begin
                  for J := 0 to WrapList.Count - 1 do
                    WrapList.RowMarks[J] := TRowMarks(Word(MarkList[J]));
                  for J := WrapList.Count to MarkList.Count - 1 do
                    WrapList.RowMarks[WrapList.Count - 1] :=
                      WrapList.RowMarks[WrapList.Count - 1] +
                      TRowMarks(Word(MarkList[J]));
                end;
                for J := 0 to WrapList.Count - 1 do
                begin
                  BufList[L] := WrapList[J];
                  BufList.Rows[L] := WrapList.Rows[J];
                  BufList.RowMarks[L] := WrapList.RowMarks[J];
                  Inc(L);
                end;
              end;
              S := '';
              M := [];
              MarkList.Clear;
            end;
          end;
        finally
          MarkList.Free;
        end;
      finally
        WrapList.Free;
      end;
      // BufList -> Strings
      ListCount := Count;
      if ListCount < NewListCount then
        for I := 0 to NewListCount - ListCount - 1 do
          Add('')
      else
        if ListCount > NewListCount then
          for I := 0 to ListCount - NewListCount - 1 do
            Delete(Count - 1);
      for I := 0 to BufList.Count - 1 do
      begin
        Put(I, BufList[I]);
        Rows[I] := BufList.Rows[I];
        RowMarks[I] := BufList.RowMarks[I];
      end;
      Rows[Count - 1] := RowAttribute;
    finally
      BufList.Free;
    end;
  finally
    EndUpdate;
    OnChange := ChangeLink;
  end;
end;



{  TEditorStrings  }

function TEditorStrings.Add(const S: String): Integer;
var
  Idx, Rs: Integer;
  Buf: String;
begin
  Result := GetCount;
  FEditor.CleanSelection;
  Idx := FEditor.FList.Count;
  FEditor.CaretBeginUpdate;
  try
    if (Idx = 0) or
       (FEditor.FList.Rows[FEditor.FList.Count - 1] = raCrlf) then
    begin
      Rs := Idx;
      Buf := S + #13#10;
      FEditor.FList.UpdateList(Idx, 0, Buf);
    end
    else
    begin
      // (Idx <> 0) and (Rows[Count - 1] = raEof)
      Rs := Idx - 1;
      Buf := FEditor.FList[FEditor.FList.Count - 1] + #13#10 + S;
      FEditor.FList.UpdateList(Idx - 1, 1, Buf);
    end;
    // caret
    FEditor.SetSelIndex(Rs, Length(Buf));
  finally
    FEditor.CaretEndUpdate;
  end;
end;

procedure TEditorStrings.Assign(Source: TPersistent);
begin
  if Source is TStrings then
  begin
    SetTextStr(TStrings(Source).Text);
    FEditor.Row := FEditor.FList.Count;
    FEditor.Col := 0;
  end
  else
    inherited Assign(Source);
end;

procedure TEditorStrings.Clear;
begin
  FEditor.FList.Clear;
end;

procedure TEditorStrings.ReadData(Reader: TReader);
begin
  Reader.ReadListBegin;
  // IDE 内でコピー＆ペーストした場合１行毎に再描画が行われてしまうので
  // BeginUpdate, EndUpdate する
  BeginUpdate;
  try
    Clear;
    while not Reader.EndOfList do
      FEditor.FList.Add(Reader.ReadString);
  finally
    EndUpdate;
  end;
  Reader.ReadListEnd;
  // csLoading, csReading なので、WrapLines は行わない
  // Loaded で WrapLines が行われる
end;

procedure TEditorStrings.WriteData(Writer: TWriter);
var
  I: Integer;
  S: String;
begin
  Writer.WriteListBegin;
  S := '';
  for I := 0 to FEditor.FList.Count - 1 do
  begin
    S := S + FEditor.FList[I];
    if (I = FEditor.FList.Count - 1) or
       (FEditor.FList.Rows[I] = raCrlf) then
    begin
      Writer.WriteString(S);
      S := '';
    end
  end;
  Writer.WriteListEnd;
end;

procedure TEditorStrings.DefineProperties(Filer: TFiler);

  function DoWrite: Boolean;
  begin
    if Filer.Ancestor <> nil then
    begin
      Result := True;
      if Filer.Ancestor is TStrings then
        Result := not Equals(TStrings(Filer.Ancestor))
    end
    else Result := Count > 0;
  end;

begin
  Filer.DefineProperty('Strings', ReadData, WriteData, DoWrite);
end;

procedure TEditorStrings.Delete(Index: Integer);
var
  Idx, Rs, Re: Integer;
begin
  FEditor.CleanSelection;
  Idx := LinesToRow(Index);
  Rs := FEditor.FList.RowStart(Idx);
  Re := FEditor.FList.RowEnd(Idx);
  FEditor.CaretBeginUpdate;
  try
    FEditor.FList.UpdateList(Idx, Re - Rs + 1, '');
    FEditor.SetSelIndex(Idx, 0);
  finally
    FEditor.CaretEndUpdate;
  end;
end;

function TEditorStrings.Get(Index: Integer): String;
var
  Idx, Dr: Integer;
  RowAttribute: TEditorRowAttribute;
begin
  if not FEditor.WordWrap then
    Result := FEditor.FList[Index]
  else
  begin
    Idx := LinesToRow(Index);
    FEditor.FList.ListInfo(Idx, -1, Result, Dr, RowAttribute);
    // ListInfo では、末尾に #13#10 を付加してくるので取り除く
    while (Length(Result) > 0) and (Result[Length(Result)] = #10) do
      System.Delete(Result, Length(Result) - 1, 2);
  end;
end;

function TEditorStrings.GetCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  if not FEditor.WordWrap then
    Result := FEditor.FList.Count
  else
    for I := 0 to FEditor.FList.Count - 1 do
      if (FEditor.FList.Rows[I] <> raWrapped) or
         (I = FEditor.FList.Count - 1) then
        Inc(Result);
end;

function TEditorStrings.GetTextStr: String;
begin
  Result := FEditor.ListToStr(FEditor.FList);
end;

procedure TEditorStrings.Insert(Index: Integer; const S: String);
var
  Idx: Integer;
begin
  Idx := LinesToRow(Index);
  if Idx = FEditor.FList.Count then
    Add(S)
  else
  begin
    FEditor.CleanSelection;
    FEditor.CaretBeginUpdate;
    try
      // insert
      FEditor.FList.UpdateList(Idx, 0, S + #13#10);
      // caret
      FEditor.SetSelIndex(Idx, Length(S + #13#10));
    finally
      FEditor.CaretEndUpdate;
    end;
  end;
end;

function TEditorStrings.LinesToRow(Index: Integer): Integer;
(*
  FLines 上での Index を FEditor.FList の Index に変換する
  例外を発生させるために敢えて
  Max(0, Min(Index, FEditor.FList.Count))
  and (Result <= FEditor.FList.Count - 1)
  などの判別を行わない。
*)
var
  I: Integer;
begin
  if not FEditor.WordWrap then
    Result := Index
  else
  begin
    Result := 0;
    I := 0;
    while I < Index do
    begin
      if (FEditor.FList.Count - 1 = Result) or
         (FEditor.FList.Rows[Result] = raCrlf) then
        Inc(I);
      Inc(Result);
    end;
  end;
end;

procedure TEditorStrings.LoadFromFile(const FileName: String);
// #26 を読み込まないバージョン
// 改行文字は #13#10, #13, #10 に対応
const
  BufferSize = $2000;
var
  I, ReadCount, LineCount: Integer;
  LineRemained, CREnd: Boolean;
  S, Str: String;
  Buffer, P, Start: PChar;
  Fs: TFileStream;
begin
  // FEditor.Flist へ直接読み込むので、読み込み後 WordWrap に対応する
  BeginUpdate;
  try
    Clear;
    try
      Fs := TFileStream.Create(FileName, fmOpenRead);
    except
      raise Exception.Create('"'+FileName+'"が開けません。');
    end;
    try
      Buffer := StrAlloc(BufferSize + 1);
      try
        // #13, #10 をカウントする #26 以降は読み込まない
        LineCount := 0;
        LineRemained := False;
        CREnd := False;
        repeat
          ReadCount := Fs.Read(Buffer^, BufferSize);
          if ReadCount > 0 then
            LineRemained := False;
          Buffer[ReadCount] := #0;
          P := Buffer;
          // バッファによって #13#10 が分断された場合のために
          if CREnd and (P^ = #10) then
            Inc(P);
          while not(P^ in [#0, #26]) do
          begin
            while not (P^ in [#0, #10, #13, #26]) do
              Inc(P);
            if P^ in [#10, #13] then
              Inc(LineCount)
            else
              LineRemained := True;
            if P^ = #13 then
            begin
              CREnd := P - Buffer = ReadCount - 1;
              Inc(P);
            end;
            if P^ = #10 then
              Inc(P);
          end;
          if P^ = #26 then Break;
        until ReadCount = 0;
        if LineRemained then
          Inc(LineCount);

        // 取得した行数分の Capacity を確保
        for I := 0 to LineCount - 1 do
          FEditor.FList.Add('');
        // バッファを利用して読み込み #26 以降は読み込まない
        Fs.Seek(0, 0);
        LineCount := 0;
        CREnd := False;
        Str := '';
        repeat
          ReadCount := Fs.Read(Buffer^, BufferSize);
          Buffer[ReadCount] := #0;
          P := Buffer;
          // バッファによって #13#10 が分断された場合のために
          if CREnd and (P^ = #10) then
            Inc(P);
          while not(P^ in [#0, #26]) do
          begin
            Start := P;
            while not (P^ in [#0, #10, #13, #26]) do
              Inc(P);
            SetString(S, Start, P - Start);
            if P^ in [#0, #26] then
              if Str <> '' then
                Str := Str + S
              else
                Str := S
            else
            begin
              if Str <> '' then
              begin
                S := Str + S;
                Str := '';
              end;
              FEditor.FList[LineCount] := S;
              Inc(LineCount);
            end;
            if P^ = #13 then
            begin
              CREnd := P - Buffer = ReadCount - 1;
              Inc(P);
            end;
            if P^ = #10 then
              Inc(P);
          end;
          if P^ = #26 then Break;
        until ReadCount = 0;
        if Str <> '' then
        begin
          // #13#10 の無い行が追加された
          FEditor.FList[LineCount] := Str;
          FEditor.FList.Rows[LineCount] := raEof;
        end;
      finally
        StrDispose(Buffer);
      end;
    finally
      Fs.Free;
    end;
    if FEditor.WordWrap then
      FEditor.FList.WrapLines;
    FEditor.FList.InitBrackets;
    FEditor.FList.ClientsInitView;
  finally
    EndUpdate;
  end;
end;

procedure TEditorStrings.Put(Index: Integer; const S: String);
var
  Rs, Re: Integer;
  Buf: String;
begin
  FEditor.CleanSelection;
  Rs := LinesToRow(Index);
  Re := FEditor.FList.RowEnd(Rs);
  if FEditor.FList.Rows[Re] = raCrlf then
    Buf := S + #13#10
  else
    Buf := S;
  FEditor.CaretBeginUpdate;
  try
    FEditor.FList.UpdateList(Rs, Re - Rs + 1, Buf);
    FEditor.SetSelIndex(Rs, Length(Buf));
  finally
    FEditor.CaretEndUpdate;
  end;
end;

procedure TEditorStrings.SetTextStr(const Value: String);
var
  L: Integer;
begin
  BeginUpdate;
  try
    Clear;
    FEditor.FList.Text := Value;
    L := Length(Value);
    if (L > 0) and not (Value[L] in [#10, #13]) then
      FEditor.FList.Rows[FEditor.FList.Count - 1] := raEof;
    if FEditor.WordWrap then
      FEditor.FList.WrapLines;
    FEditor.FList.InitBrackets;
  finally
    EndUpdate;
  end;
end;

procedure TEditorStrings.SetUpdateState(Updating: Boolean);
(*
  最初の BeginUpdate で True が、最後の EndUpdate で False がやってくる
  OnChange イベントは FEditor.FList.OnChange を利用しているので、
  FEditor.FList.BeginUpdate, EndUpdate している
  また、キャレットやアンダーラインの描画も中断する
*)
begin
  // TEditorStrings 独自の FUpdateCount をセット
  if Updating then
  begin
    Inc(FUpdateCount);
    FEditor.FList.BeginUpdate;
    FEditor.CaretBeginUpdate;
    FEditor.UnderlineBeginUpdate;
    // UpdateCaret 呼び出しをキャンセルして高速化する
    FEditor.FCaretNoMove := True;
  end
  else
  begin
    Dec(FUpdateCount);
    FEditor.FList.EndUpdate;
    FEditor.UnderlineEndUpdate;
    FEditor.CaretEndUpdate;
    // フラグのクリアと自前でキャレット移動
    FEditor.FCaretNoMove := False;
    FEditor.UpdateCaret;
  end;
  // 一切の描画を停止・再描画
  if FEditor.Visible then
  begin
    if FEditor.HandleAllocated then
      SendMessage(FEditor.Handle, WM_SETREDRAW, Ord(not Updating), 0);
    if not Updating then
      FEditor.FList.ClientsInitView;
  end;
end;


{ TUndoDataList }

(*
  TList を拡張した TUndoDataList では、項目が破棄されるときに
  項目が保持するポインタを Dispose する。
*)

destructor TUndoDataList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TUndoDataList.Clear;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Dispose(PUndoData(Items[I]));
  inherited Clear; // SetCount(0); SetCapacity(0);
end;

procedure TUndoDataList.Delete(Index: Integer);
begin
  Dispose(PUndoData(Items[Index]));
  inherited Delete(Index);
end;


{  TEditorUndoObj  }

(*
  #UndoObj TEditorUndoObj オブジェクトの動作について

  TUndoData = record
    Row,                   現在行
    Col,                   現在桁
    DataRow,               データを復帰する行
    DeleteCount: Integer   復帰を行う際削除される行数
    RowAttribute: TEditorRowAttribute;
                           InsertStr を挿入する際セットされる属性
    InsertStr: String;     復帰する際挿入される文字列
  end;

  InsertStr は、改行を含む１文字列として作成する。
  例えば下の状態で a を削除する場合は 1..n + #13#10 + o..u の文字列となる
  1234567890abcdefghijklmn <- wrap
  opqrstu↓

  Undo の実行
  FUndoList の最後尾からデータを FEditor.FList へ復活させる。
  DeleteCount > 0 であれば DataRow から DeleteCount 行の文字列を削除し、
  RowAttribute <> raInvalid であれば DataRow に InsertStr を挿入する。

  データの更新
  DataRow から DeleteCount 行の文字列と最終行の属性は削除する前に保存
  しておき、復帰処理終了後、この保存データで、InsertStr, RowAttribute を
  更新する。
  InsertStr が挿入された場合は InsertStr が占有する行数で DeleteCount を
  更新する

  データの移行
  更新したデータは FRedoList へ追加する。FUndoList の最後尾のデータは
  削除される。Undo を行った回数だけ Redo が可能になる仕様である。

  Redo の実行
  Undo と全く同じ処理を行うが、処理済みのデータは FUndoList へ追加
  される。
*)

constructor TEditorUndoObj.Create;
begin
  FListMax := UndoListMin; // const
  FRedoList := TUndoDataList.Create;
  FUndoList := TUndoDataList.Create;
end;

destructor TEditorUndoObj.Destroy;
begin
  FRedoList.Free;
  FUndoList.Free;
  inherited Destroy;
end;

function TEditorUndoObj.Add: PUndoData;
var
  P: PUndoData;
begin
  New(P);
  // 現在の状態を取得
  P.Row := FList.ActiveClient.FRow;
  P.Col := FList.ActiveClient.FCol;
  // 初期化
  P.DataRow := -1;
  P.DeleteCount := 0;
  P.RowAttribute := raInvalid;
  P.InsertStr := '';
  // リストに追加して、最大値チェック
  FUndoList.Add(P);
  if FUndoList.Count > FListMax then
    FUndoList.Delete(0);
  // Redo から呼ばれていなければ、FRedoList をクリアする
  if not FRedoing then
    FRedoList.Clear;
  Result := P;
end;

function TEditorUndoObj.CanRedo: Boolean;
begin
  Result := FRedoList.Count > 0;
end;

function TEditorUndoObj.CanUndo: Boolean;
begin
  Result := FUndoList.Count > 0;
end;

procedure TEditorUndoObj.Clear;
begin
  FUndoList.Clear;
  FRedoList.Clear;
end;

procedure TEditorUndoObj.Redo;
var
  P, Data: PUndoData;
  WrapList: TEditorStringList;
  I, Dr, Ir, Ivr: Integer;
  S: String;
  RowAttribute: TEditorRowAttribute;
  M: TRowMarks;
begin
  if FRedoList.Count <= 0 then
    Exit;
  P := PUndoData(FRedoList[FRedoList.Count - 1]);
  FList.ActiveClient.CaretBeginUpdate;
  try
    FList.BeginUpdate;
    try
      // undo data & delete count
      if P.DeleteCount = 0 then
      begin
        // 削除する行が無い場合
        S := '';
        Dr := 0;
        RowAttribute := raInvalid;
      end
      else
        // 削除する文字列と最終行の属性を保存
        FList.ListInfo(P.DataRow, P.DeleteCount, S, Dr, RowAttribute);
      // delete & insert
      Ir := 0;
      if P.RowAttribute = raInvalid then
      begin
        // 挿入するデータが無いので、Dr 行を削除するだけ
        // cf TEditorScreenStrings.UpdateList
        M := FList.DeleteList(P.DataRow, Dr);
        if FList.Count > 0 then
        begin
          I := Min(P.DataRow, FList.Count - 1);
          FList.RowMarks[I] := FList.RowMarks[I] + M;
        end
        else
          FList.ExcludeRowMarks(M);
      end
      else
      begin
        WrapList := TEditorStringList.Create;
        try
          FList.StrToWrapList(P.InsertStr, WrapList);
          // raWrapped な場合に必要な処理
          if (P.RowAttribute = raWrapped) and
             (Length(WrapList[WrapList.Count - 1]) = 0) then
            WrapList.Delete(WrapList.Count - 1);
          WrapList.Rows[WrapList.Count - 1] := P.RowAttribute;
          // ここで挿入される行数が Undo する際の DeleteCount になる
          Ir := WrapList.Count;
          FList.ChangeList(P.DataRow, Dr, WrapList);
        finally
          WrapList.Free;
        end;
      end;
      // Brackets の更新
      Ivr := FList.UpdateBrackets(P.DataRow, True);
      // 描画情報の更新
      FList.UpdateDrawInfo(P.DataRow, Dr, Ir, Ivr);
      // FUndoList に追加 FRedoList がクリアされないようにフラグを利用する
      FRedoing := True;
      try
        Data := Add;
        Data.DataRow := P.DataRow;
        Data.DeleteCount := Ir;
        Data.RowAttribute := RowAttribute;
        Data.InsertStr := S;
      finally
        FRedoing := False;
      end;
    finally
      FList.EndUpdate; // draw
    end;
    // キャレットの復帰
    FList.ActiveClient.Row := P.Row;
    FList.ActiveClient.Col := P.Col;
  finally
    FList.ActiveClient.CaretEndUpdate;
  end;
  // 最後尾のデータを削除
  FRedoList.Delete(FRedoList.Count - 1);
end;

procedure TEditorUndoObj.Undo;
var
  P: PUndoData;
  WrapList: TEditorStringList;
  I, Dr, Ir, Ivr: Integer;
  S: String;
  RowAttribute: TEditorRowAttribute;
  M: TRowMarks;
begin
  if FUndoList.Count <= 0 then
    Exit;
  P := PUndoData(FUndoList[FUndoList.Count - 1]);
  FList.ActiveClient.CaretBeginUpdate;
  try
    FList.BeginUpdate;
    try
      // redo data & delete count
      if P.DeleteCount = 0 then
      begin
        // 削除する行が無い場合
        S := '';
        Dr := 0;
        RowAttribute := raInvalid;
      end
      else
        // 削除する文字列と最終行の属性を保存
        FList.ListInfo(P.DataRow, P.DeleteCount, S, Dr, RowAttribute);
      // delete & insert
      Ir := 0;
      if P.RowAttribute = raInvalid then
      begin
        // 挿入するデータが無いので、Dr 行を削除するだけ
        // cf TEditorScreenStrings.UpdateList
        M := FList.DeleteList(P.DataRow, Dr);
        if FList.Count > 0 then
        begin
          I := Min(P.DataRow, FList.Count - 1);
          FList.RowMarks[I] := FList.RowMarks[I] + M;
        end
        else
          FList.ExcludeRowMarks(M);
      end
      else
      begin
        WrapList := TEditorStringList.Create;
        try
          FList.StrToWrapList(P.InsertStr, WrapList);
          // raWrapped な場合に必要な処理
          if (P.RowAttribute = raWrapped) and
             (Length(WrapList[WrapList.Count - 1]) = 0) then
            WrapList.Delete(WrapList.Count - 1);
          WrapList.Rows[WrapList.Count - 1] := P.RowAttribute;
          // ここで挿入される行数が Redo する際の DeleteCount になる
          Ir := WrapList.Count;
          FList.ChangeList(P.DataRow, Dr, WrapList);
        finally
          WrapList.Free;
        end;
      end;
      // Brackets の更新
      Ivr := FList.UpdateBrackets(P.DataRow, True);
      // 描画情報の更新
      FList.UpdateDrawInfo(P.DataRow, Dr, Ir, Ivr);
      // 保持しているデータを更新して FRedoList に追加
      P.DeleteCount := Ir;
      P.RowAttribute := RowAttribute;
      P.InsertStr := S;
      UndoToRedo(P);
    finally
      FList.EndUpdate; // draw
    end;
    // キャレットの復帰
    FList.ActiveClient.Row := P.Row;
    FList.ActiveClient.Col := P.Col;
  finally
    FList.ActiveClient.CaretEndUpdate;
  end;
  // 最後尾のデータを削除
  FUndoList.Delete(FUndoList.Count - 1);
end;

procedure TEditorUndoObj.UndoToRedo(Data: PUndoData);
var
  P: PUndoData;
begin
  New(P);
  // FUndoList からのデータを受け取る
  P.DataRow := Data.DataRow;
  P.DeleteCount := Data.DeleteCount;
  P.RowAttribute := Data.RowAttribute;
  P.InsertStr := Data.InsertStr;
  // 現在の状態を取得
  P.Row := FList.ActiveClient.FRow;
  P.Col := FList.ActiveClient.FCol;
  // FUndoList から追加されるので最大値チェックは行わない
  FRedoList.Add(P);
end;


{  TEditorWrapOption  }

constructor TEditorWrapOption.Create;
begin
  FFollowStr := WrapOption_Default_FollowStr;           // '、。，．・？！゛゜ヽヾゝゞ々ー）］｝」』!),.:;?]}｡｣､･ｰﾞﾟ';
  FLeadStr := WrapOption_Default_LeadStr;               //'（［｛「『([{｢';
  FPunctuationStr := WrapOption_Default_PunctuationStr; // '、。，．,.｡､';
  FWrapByte := 80;
end;

procedure TEditorWrapOption.Assign(Source: TPersistent);
begin
  if Source is TEditorWrapOption then
  begin
    FFollowRetMark := TEditorWrapOption(Source).FFollowRetMark;
    FFollowPunctuation := TEditorWrapOption(Source).FFollowPunctuation;
    FFollowStr := TEditorWrapOption(Source).FFollowStr;
    FLeading := TEditorWrapOption(Source).FLeading;
    FLeadStr := TEditorWrapOption(Source).FLeadStr;
    FPunctuationStr := TEditorWrapOption(Source).FPunctuationStr;
    FWordBreak := TEditorWrapOption(Source).FWordBreak;
    FWrapByte := TEditorWrapOption(Source).FWrapByte;
    Changed;
  end
  else
    inherited Assign(Source);
end;

procedure TEditorWrapOption.SetFollowPunctuation(Value: Boolean);
begin
  if FFollowPunctuation <> Value then
  begin
    FFollowPunctuation := Value;
    Changed;
  end;
end;

procedure TEditorWrapOption.SetFollowRetMark(Value: Boolean);
begin
  if FFollowRetMark <> Value then
  begin
    FFollowRetMark := Value;
    Changed;
  end;
end;

procedure TEditorWrapOption.SetFollowStr(Value: String);
begin
  if FFollowStr <> Value then
  begin
    FFollowStr := Value;
    Changed;
  end;
end;

procedure TEditorWrapOption.SetLeading(Value: Boolean);
begin
  if FLeading <> Value then
  begin
    FLeading := Value;
    Changed;
  end;
end;

procedure TEditorWrapOption.SetLeadStr(Value: String);
begin
  if FLeadStr <> Value then
  begin
    FLeadStr := Value;
    Changed;
  end;
end;

procedure TEditorWrapOption.SetPunctuationStr(Value: String);
begin
  if FPunctuationStr <> Value then
  begin
    FPunctuationStr := Value;
    Changed;
  end;
end;

procedure TEditorWrapOption.SetWordBreak(Value: Boolean);
begin
  if FWordBreak <> Value then
  begin
    FWordBreak := Value;
    Changed;
  end;
end;

procedure TEditorWrapOption.SetWrapByte(Value: Integer);
begin
  Value := Min(MaxWrapByte, Max(MinWrapByte, Value));
  if FWrapByte <> Value then
  begin
    FWrapByte := Value;
    Changed;
  end;
end;


{ TEditorScreen }

procedure TEditorScreen.Update;
(*
  FEditor.FList.FDrawInfo 情報を元に画面を更新する
  FList は既に更新されてしまっていることに注意。
*)
var
  I, Dr, Ir, Ivr, Sp: Integer;
  R: TRect;
begin
  with FEditor.FList.FDrawInfo do
  begin
    if not NeedUpdate then
      Exit;
    I := Start;
    Dr := Delete;
    Ir := Insert;
    Ivr := Invalid;
  end;
  with FEditor do
  begin
    if Abs(Ir - Dr) > FRowCount then
    begin
      R := Rect(0, TopMargin, Width, Height);
      InvalidateRect(Handle, @R, False);
      UpdateWindow(Handle);
    end
    else
    begin
      // FList
      Sp := I + Ir + Max(0, Ivr - Ir); // スクロールポイント
      if Ir <> Dr then
      begin
        // スクロールが発生する場合
        InvalidateRow(I, Sp - 1);      // 領域を再描画
        if FImagebar.FVisible then
          ImagebarScroll(Sp, Ir - Dr);
        LineScroll(Sp, Ir - Dr);       // スクロールに対応
        if Sp > FList.Count - 1 then   // [EOF] へ対応
          InvalidateRow(Sp, Sp + 1);   // EndUpdate 後に Add などを実行すると、この領域まで再描画が必要
      end
      else
        // スクロール無し
        if Sp > FList.Count - 1 then   // [EOF] もろとも
          InvalidateRow(I, Sp + 1)     // EndUpdate 後に Add などを実行すると、この領域まで再描画が必要
        else
          InvalidateRow(I, Sp - 1);    // 領域のみ

      // FLeftbar
      if FLeftbar.FVisible and FLeftbar.FShowNumber and
         ((FLeftbar.FShowNumberMode = nmLine) or
          ((FList.Count <= FTopRow + FRowCount) and (Dr <> Ir))) then
        // 行番号を表示していて、nmLine モードか、[EOF] 行が見えて
        // いて、スクロールが発生した場合は、画面下端までを再描画する。
        // InvalidateRow では行番号表示部分も無効化しているので、ここ
        // では Sp から画面下端までとする
        InvalidateLeftbar(Sp, I + FRowCount);
    end;
  end;
end;


{ TEditorPopupMenu }

constructor TEditorPopupMenu.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CreateMenuItem;
  OnPopup := SetMenu;
end;

procedure TEditorPopupMenu.CreateMenuItem;
var
  I: Integer;
  Item: TMenuItem;
begin

  FSetMark := TMenuItem.Create(Self);
  FSetMark.Caption := PopupMenu_MarkSet; //          = 'マーク設定';
  Items.Add(FSetMark);
  for I := 0 to 9 do
  begin
    Item := TMenuItem.Create(Self);
    Item.Caption := IntToStr(I);
    Item.ShortCut := TextToShortCut('Shift+Ctrl+' + IntToStr(I));
    Item.Tag := I;
    Item.OnClick := SetMarkClick;
    FSetMark.Add(Item);
  end;

  FGotoMark := TMenuItem.Create(Self);
  FGotoMark.Caption := PopupMenu_MarkJump; //        = 'マークジャンプ';
  Items.Add(FGotoMark);
  for I := 0 to 9 do
  begin
    Item := TMenuItem.Create(Self);
    Item.Caption := IntToStr(I);
    Item.ShortCut := TextToShortCut('Ctrl+' + IntToStr(I));
    Item.Tag := I;
    Item.OnClick := GotoMarkClick;
    FGotoMark.Add(Item);
  end;

  FN0 := TMenuItem.Create(Self);
  FN0.Caption := '-';
  Items.Add(FN0);

  FUndo := TMenuItem.Create(Self);
  FUndo.Caption := PopupMenu_Undo; //                = '元に戻す(&U)';
  FUndo.ShortCut := TextToShortCut('Ctrl+Z');
  FUndo.OnClick := UndoClick;
  FUndo.Enabled := False;
  Items.Add(FUndo);

  FRedo := TMenuItem.Create(Self);
  FRedo.Caption := PopupMenu_Redo; //                = 'やり直し(&R)';
  FRedo.ShortCut := TextToShortCut('Ctrl+A');
  FRedo.OnClick := RedoClick;
  FRedo.Enabled := False;
  Items.Add(FRedo);

  FN1 := TMenuItem.Create(Self);
  FN1.Caption := '-';
  Items.Add(FN1);

  FCut := TMenuItem.Create(Self);
  FCut.Caption := PopupMenu_Cut; //                  = '切り取り(&T)';
  FCut.ShortCut := TextToShortCut('Ctrl+X');
  FCut.OnClick := CutClick;
  FCut.Enabled := False;
  Items.Add(FCut);

  FCopy := TMenuItem.Create(Self);
  FCopy.Caption := PopupMenu_Copy; //                = 'コピー(&C)';
  FCopy.ShortCut := TextToShortCut('Ctrl+C');
  FCopy.OnClick := CopyClick;
  FCopy.Enabled := False;
  Items.Add(FCopy);

  FPaste := TMenuItem.Create(Self);
  FPaste.Caption := PopupMenu_Paste;//               = '貼り付け(&P)';
  FPaste.ShortCut := TextToShortCut('Ctrl+V');
  FPaste.OnClick := PasteClick;
  FPaste.Enabled := False;
  Items.Add(FPaste);

  FBoxPaste := TMenuItem.Create(Self);
  FBoxPaste.Caption := PopupMenu_BoxPaste; //        = 'Box貼り付け(&B)';
  FBoxPaste.ShortCut := TextToShortCut('Ctrl+B');
  FBoxPaste.OnClick := BoxPasteClick;
  FBoxPaste.Enabled := False;
  Items.Add(FBoxPaste);

  FDelete := TMenuItem.Create(Self);
  FDelete.Caption := PopupMenu_Delete; //            = '削除(&D)';
  FDelete.OnClick := DeleteClick;
  FDelete.Enabled := False;
  Items.Add(FDelete);

  FN2 := TMenuItem.Create(Self);
  FN2.Caption := '-';
  Items.Add(FN2);

  FSelAll := TMenuItem.Create(Self);
  FSelAll.Caption := PopupMenu_SelectAll; //         = 'すべて選択(&A)';
  FSelAll.OnClick := SelAllClick;
  FSelAll.Enabled := False;
  Items.Add(FSelAll);

  FN3 := TMenuItem.Create(Self);
  FN3.Caption := '-';
  Items.Add(FN3);

  FSelMode := TMenuItem.Create(Self);
  FSelMode.Caption := PopupMenu_BoxSelectionMode; // = 'Box選択モード(&K)';
  FSelMode.ShortCut := TextToShortCut('Ctrl+K');
  FSelMode.OnClick := SelModeClick;
  Items.Add(FSelMode);

end;

procedure TEditorPopupMenu.SetMenu(Sender: TObject);
var
  Sel, ReadOnly, HasText: Boolean;
  I: Integer;
begin
  if FEditor <> nil then
  begin
    Sel := FEditor.SelLength > 0;
    ReadOnly := FEditor.FReadOnly;
    HasText := ClipBoard.HasFormat(CF_TEXT);
    FUndo.Enabled := FEditor.CanUndo and not ReadOnly;
    FRedo.Enabled := FEditor.CanRedo and not ReadOnly;
    FCut.Enabled := Sel and not ReadOnly;
    FCopy.Enabled := Sel;
    FPaste.Enabled := HasText and not ReadOnly;
    FBoxPaste.Enabled := HasText and not ReadOnly;
    FDelete.Enabled := Sel and not ReadOnly;
    FSelAll.Enabled := FEditor.GetTextLen > 0;
    FSelMode.Checked := Boolean(Byte(FEditor.SelectionMode));
    for I := 0 to 9 do
    begin
      FSetMark.Items[I].Checked := TRowMark(I) in FEditor.FList.ValidRowMarks;
      FGotoMark.Items[I].Checked := TRowMark(I) in FEditor.FList.ValidRowMarks;
    end;
  end;
end;

procedure TEditorPopupMenu.SetMarkClick(Sender: TObject);
var
  M: TRowMark;
begin
  M := TRowMark(TMenuItem(Sender).Tag);
  if M in FEditor.ListRowMarks[FEditor.Row] then
    FEditor.DeleteRowMark(FEditor.Row, M)
  else
    FEditor.PutRowMark(FEditor.Row, M);
end;

procedure TEditorPopupMenu.GotoMarkClick(Sender: TObject);
var
  M: TRowMark;
begin
  M := TRowMark(TMenuItem(Sender).Tag);
  FEditor.GotoRowMark(M);
end;

procedure TEditorPopupMenu.UndoClick(Sender: TObject);
begin
  FEditor.Undo;
end;

procedure TEditorPopupMenu.RedoClick(Sender: TObject);
begin
  FEditor.Redo;
end;

procedure TEditorPopupMenu.CutClick(Sender: TObject);
begin
  FEditor.CutToClipboard;
end;

procedure TEditorPopupMenu.CopyClick(Sender: TObject);
begin
  FEditor.CopyToClipboard;
end;

procedure TEditorPopupMenu.PasteClick(Sender: TObject);
begin
  FEditor.PasteFromClipboard;
end;

procedure TEditorPopupMenu.BoxPasteClick(Sender: TObject);
begin
  FEditor.SetSelTextBox(PChar(Clipboard.AsText));
end;

procedure TEditorPopupMenu.DeleteClick(Sender: TObject);
begin
  FEditor.ClearSelection;
end;

procedure TEditorPopupMenu.SelAllClick(Sender: TObject);
begin
  FEditor.SelectAll;
end;

procedure TEditorPopupMenu.SelModeClick(Sender: TObject);
begin
  FSelMode.Checked := not FSelMode.Checked;
  FEditor.SelectionMode := TEditorSelectionMode(Byte(FSelMode.Checked));
end;


{  TEditor  }

(*

■ #IME SetImeComposition IME ウィンドゥの移動について

Col, Row, TopRow, TopCol の変化や、画面スクロールによってクライアント領
域上でキャレット位置が変化した場合は IME ウィンドゥを移動しなければなら
ない。TEditor では、その移動処理を MoveCaret, SetTopRow, SetTopColで行っ
ている。連続スクロールなどで移動処理が頻繁に行われるのを避けるため、
WMKeyDown ではキーリピートフラグ FKeyRepeat を設定している。移動処理を行
う前に、このフラグを参照し FKeyRepeat が真の場合は移動処理を行わずに
FCompositionCanceled フラグを真に設定している。WMKeyUp では、FKeyRepeat
フラグをクリアして FCompositionCanceled が真な場合 SetImeComposition 呼
び出しを行っている SetImeComposition で FCompositionCanceled フラグがク
リアされる

■ #Scroll ScrollWindowEx について

  スクロールする領域は FMargin.FLeft, FMargin.FTop, Width, Height を
最大値とするクリップ内で行う。マージン部分はスクロールしない仕様とする。
実際にスクロールする際は、DoScroll メソッドを呼び出してユーザーの拡張に
対応出来る仕様となっている。
  が、例外はあって、ScrollWindowEx を直接呼び出している部分もある

・Ruler を表示している場合の縦スクロールは、
  Rect(0, TopMargin, Width, Height) の領域をクリップしている。
       ^
・Leftbar を表示している場合の横スクロールは、
  Rect(LeftMargin, 0, Width, Height) の領域をクリップしている。
                   ^
  第４引数に TRect へのポインタを渡す場合は処理前に UpdateWindow を行う。
第５引数に TRect へのポインタを渡す場合は、キャレットが持って行かれる
CaretBeginUpdate, CaretEndUpdate も用をなさない。LineScroll を実行する
際は、処理後 Row, Col の設定を行う仕様とする

  縦スクロールの際は、アンダーラインがチラツクのを防ぐため、
UnderlineBeginUpdate, UnderlineEndUpdate を行う。

  DoScroll では 以下のように ScrollWindowEx が使用され、自前で無効領域を
発生させ UpdateWindow している。この無効領域は塗りつぶされることがない
ので、描画処理では、FillRect するか、ExtTextOut に ETO_OPAQUE を渡して
一度は領域を塗りつぶす作業が必要になる

ScrollWindowEx(Handle, X, Y, Rect, ClipRect, 0, @R, SW_SCROLLCHILDREN);
InvalidateRect(Handle, @R, False);
UpdateWindow(Handle);

■ #Caret 描画とキャレットについて

  なんらかの描画を行う際は、キャレットが画面に定着されてしまうので、
CaretBeginUpdate, CaretEndUpdate を行う。IME ウィンドゥが表示される際も
キャレットの定着が起きる場合があるので WM_IME_COMPOSITION メッセージハン
ドラでも、CaretBeginUpdate, CaretEndUpdate を行っている

not Showing の状態で描画処理が行われると Canvas.MoveTo のところで固
まってしまう現象が発生したので、Canvas に手を伸ばすメソッドでは、
Showing を判別する仕様とする。
*)

// VCL //////////////////////////////////////////////////////////////

constructor TEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Height := 89;
  Width := 185;
  FBorderStyle := bsSingle;
  Cursor := crIBeam;
  TabStop := True;
  FWantReturns := True;
  FWantTabs := True;
  // Font.Name への代入 → CMFontChanged → InitDrawInfo → FLines 参照
  // があるので、リストオブジェクトの生成を先に行う
  FDelimiters := CreateDelimiters;
  FList := CreateScreenStrings;
  FList.Reference(Self);
  FLines := CreateStrings;
  FScreen := CreateScreen;
  FView := CreateViewInfo;

  ParentColor := False;
  Color := clWhite;
  Font.Color := clBlack;
  Font.Name := 'FixedSys';    // -> CMFontChanged

  FCaret := CreateEditorCaret;
  FMarks := CreateEditorMarks;
  FMargin := CreateEditorMargin;
  FImagebar := CreateEditorImagebar;
  FLeftbar := CreateEditorLeftbar;
  FRuler := CreateEditorRuler;
  CreateMarginBitmaps;
  FSpeed := CreateEditorSpeed;

  if not (csDesigning in ComponentState) then
    PopupMenu := CreatePopupMenu;
end;

destructor TEditor.Destroy;
begin
  Destroying;
  Fountain := nil; // FFountain.NotifyEventList.Remove(ViewChanged);
  FScreen.Free;
  FView.Free;
  FList.Release(Self); // FList.Free;
  FLines.Free;
  FCaret.Free;
  FMarks.Free;
  FMargin.Free;
  FImagebar.Free;
  FLeftbar.Free;
  FRuler.Free;
  DestroyMarginBitmaps;
  FSpeed.Free;
  inherited Destroy;
end;

procedure TEditor.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);
  ScrollBar: array[TScrollStyle] of DWORD = (0, WS_HSCROLL,
    WS_VSCROLL, WS_HSCROLL or WS_VSCROLL);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or
             BorderStyles[FBorderStyle] or
             ScrollBar[FScrollBars];
    WindowClass.Style := WindowClass.Style
                         and not(CS_VREDRAW or CS_HREDRAW);
    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
  end;
end;

procedure TEditor.CreateHandle;
begin
  inherited CreateHandle;

  {$IFDEF COMP2}
    // D2 RecreatWnd 呼び出しによる TComponent お隠れ事件対策
    if (csDesigning in ComponentState) and (Parent <> nil) and
       (Parent is TForm) then
      SetZOrder(False);
  {$ENDIF}

  // Handle が出来上がった時点で実行される初期化メソッド群
  InitDrawInfo;
  InitScroll;
  InitLeftbarEdge;
  InitRulerBitmaps;
  InitOriginBase;
end;

{$IFDEF COMP3_UP}
procedure TEditor.CreateWindowHandle(const Params: TCreateParams);
begin
  with Params do
  begin
    WindowHandle := CreateWindowEx(ExStyle, WinClassName, '', Style,
      X, Y, Width, Height, WndParent, 0, WindowClass.hInstance, Param);
    if Caption <> nil then
      SendMessage(WindowHandle, WM_SETTEXT, 0, Longint(Caption));
  end;
end;
{$ENDIF}

procedure TEditor.DefaultHandler(var Message);
begin
  inherited DefaultHandler(Message);
  case TMessage(Message).Msg of
    WM_LBUTTONDOWN, WM_MBUTTONDOWN, WM_RBUTTONDOWN:
      if not (csDesigning in ComponentState) and not Focused then
        Windows.SetFocus(Handle);
    WM_NCLBUTTONDOWN, WM_NCMBUTTONDOWN, WM_NCRBUTTONDOWN:
      if not (csDesigning in ComponentState) and not Focused and
         (TWMNCHitMessage(Message).HitTest = HTCLIENT) then
        Windows.SetFocus(Handle);
  end;
end;

procedure TEditor.WndProc(var Message: TMessage);
begin
  if (FSelDragState <> sdNone) or (csLButtonDown in ControlState) then
    case Message.Msg of
      WM_KEYDOWN:
        if not SelDragging then
          Exit
        else
          case TWMKey(Message).CharCode of
            VK_CONTROL:
              CursorState := mcDraggingCopy;
            VK_ESCAPE:
              CancelSelDrag;
          end;
      WM_KEYUP:
        if SelDragging and (TWMKey(Message).CharCode = VK_CONTROL) then
          CursorState := mcDragging
        else
          Exit;
      WM_CHAR..WM_KEYLAST, WM_LBUTTONDBLCLK..WM_MOUSELAST:
        Exit;
    end;
  inherited WndProc(Message);
end;

procedure TEditor.ExchangeList(Source: TEditor);
begin
  if Source <> nil then
  begin
    FList.Release(Self);
    FList := Source.FList;
    Source.FList.Reference(Self);
    InitDrawInfo;
    InitScroll;
    InitOriginBase;
    Invalidate;
  end;
end;

procedure TEditor.Loaded;
begin
  inherited Loaded;
  if WordWrap then
    FList.WrapLines;
  FList.InitBrackets;
  FModified := False;
end;

procedure TEditor.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if AComponent = FFountain then
    begin
      FFountain := nil;
      Invalidate;
    end;
    if AComponent = FImageDigits then
    begin
      FImageDigits := nil;
      Invalidate;
    end;
    if AComponent = FImageMarks then
    begin
      FImageMarks := nil;
      Invalidate;
    end;
  end;
end;

procedure TEditor.Paint;
var
  R: TRect;
begin
  // 無効領域を取得して PaintRect に渡す
  R := Canvas.ClipRect;
  PaintRect(R);
end;

{$IFDEF COMP2}

function TEditor.SetImeCompositionWindow(Font: TFont;
  XPos, YPos: Integer): Boolean;
(*
  D2 では実装されていない SetImeCompositionWindow
  キー入力がリピート状態の時、および IME Window に文字が無い状態で
  画面スクロールした時は SetImeCompositionWindow 呼び出しをキャンセルし
  フラグをセットしておく。WMKeyUp, WMChar では、このフラグを参照して
  SetImeCompositinWidow を呼び出している。
  通常のキャレット移動、IME Window に文字が入力された状態で画面
  スクロールした時はそのつど呼び出している
*)
var
  H: HIMC;
  CForm: TCompositionForm;
  LFont: TLogFont;
begin
  Result := False;
  if not HandleAllocated then
    Exit;
  H := ImmGetContext(Handle);
  if H <> 0 then
  begin
    with CForm do
    begin
      dwStyle := CFS_POINT;
      ptCurrentPos.x := XPos;
      ptCurrentPos.y := YPos;
    end;
    ImmSetCompositionWindow(H, @CForm);
    if Assigned(Font) then
    begin
      GetObject(Font.Handle, SizeOf(TLogFont), @LFont);
      ImmSetCompositionFont(H, @LFont);
    end;
    ImmReleaseContext(Handle, H);
    Result := True;
  end;
end;

{$ENDIF}


// ファクトリーメソッド //////////////////////////////////////////////

function TEditor.CreateDelimiters: TCharSet;
begin
  Result := [#$0..#$FF] -
    ['_', 'a'..'z','A'..'Z','1'..'9','0',#$81..#$9F,#$E0..#$FC, #$A6..#$DF];
end;

function TEditor.CreatePopupMenu: TPopupMenu;
begin
  Result := TEditorPopupMenu.Create(Self);
  TEditorPopupMenu(Result).FEditor := Self;
end;

function TEditor.CreateScreen: TEditorScreen;
begin
  Result := TEditorScreen.Create;
  Result.FEditor := Self;
end;

function TEditor.CreateScreenStrings: TEditorScreenStrings;
begin
  Result := TEditorScreenStrings.Create;
end;

function TEditor.CreateStrings: TStrings;
begin
  Result := TEditorStrings.Create;
  TEditorStrings(Result).FEditor := Self;
end;

function TEditor.CreateViewInfo: TEditorViewInfo;
begin
  Result := TEditorViewInfo.Create;
  Result.FComponent := Self; // for GetOwner
  Result.OnChange := ViewChanged;
end;

function TEditor.CreateEditorCaret: TEditorCaret;
begin
  Result := TEditorCaret.Create;
  Result.OnChange := ViewChanged;
end;

function TEditor.CreateEditorImagebar: TEditorImagebar;
begin
  Result := TEditorImagebar.Create;
  Result.OnChange := ViewChanged;
end;

function TEditor.CreateEditorLeftbar: TEditorLeftbar;
begin
  Result := TEditorLeftbar.Create;
  Result.OnChange := ViewChanged;
end;

function TEditor.CreateEditorMarks: TEditorMarks;
begin
  Result := TEditorMarks.Create;
  Result.OnChange := ViewChanged;
end;

function TEditor.CreateEditorMargin: TEditorMargin;
begin
  Result := TEditorMargin.Create;
  Result.OnChange := ViewChanged;
end;

function TEditor.CreateEditorRuler: TEditorRuler;
begin
  Result := TEditorRuler.Create;
  Result.OnChange := ViewChanged;
end;

function TEditor.CreateEditorSpeed: TEditorSpeed;
begin
  Result := TEditorSpeed.Create;
end;


// 描画パラメーターイベントハンドラ //////////////////////////////////

procedure TEditor.ViewChanged(Sender: TObject);
(*
  描画するためのパラメータが変化した場合はここへやってくる
  TEditorCaret, TEditorMarks, TEditorMargin, TEditorViewInfo
  TEditorRuler, TEditorLeftbar オブジェクトの OnChange に
  Assign されている
*)
begin
  if Sender is TEditorMarks then
  begin
    if FMarks.FUnderline.FVisible then
      FMargin.FUnderline := 1
    else
      FMargin.FUnderline := 0;
  end
  else
    if (Sender is TEditorViewInfo) or (Sender is TFountain) then
      FList.InitBrackets;        // need not (csLoading in ComponentState)

  if not HandleAllocated then
    Exit;

  InitDrawInfo; // set FFontWidth, FFontHeight, FRulerHeight, FLeftbarColumn, FLeftbarWidth, FImagebarWidth etc.
  InitScroll;   // FTopCol is adjusted

  if Sender is TEditorLeftbar then
  begin
    InitLeftbarEdge;             // not need handle
    InitOriginBase;              // need handle
  end;
  if (Sender is TEditorMargin) or (Sender is TEditorRuler) then
  begin
    InitRulerBitmaps;            // need handle
    InitOriginBase;              // need handle
  end;
  if Sender is TEditorImagebar then
    InitOriginBase;              // need handle

  Invalidate;

  // caret
  if Sender is TEditorCaret then
  begin
    EditorUndoObj.Clear;         // for TabSpaceCount changed
    UpdateCaret;                 // need handle
  end
  else
  begin
    ScrollCaret;                 // need handle
    MoveCaret;                   // need handle
  end;
end;


// Imagebar, Leftbar, Ruler 関連 //////////////////////////////////////////////

(*
  #Leftbar, #Ruler

  マージン内への描画は、作成したビットマップを CopyRect している。
  行番号は DrawTextRect メソッドを利用している。
  ビットマップは、
    ・Rect(0, 0, LeftMargin, TopMargin) に描画される FOriginBase
    ・Ruler に描画されるビットマップ群
    ・Leftbar の縁に描画される FLeftbarEdge
  が CreateMarginBitmaps で生成され、それぞれを初期化・更新する
  メソッド群が用意されている。初期化・更新には、FFontWidth の値を
  必要とするので、HandleAllocated が True を返すまで実行されない。
  そのまま放置しておくと初期化されないままになるので、CreateHandle で
  １度全初期化メソッドを実行している。

  プロパティの変更イベントに対して更新されるべきデータについて
  -- event --------  -- bitmaps ----------------------  -- data --------------------------------------
                     Rulers  FLeftbarEdge  FOriginBase  FLeftbarColumn  FLeftbarWidth  FImagebarWidth
  CreateHandle         o       o             o            o               o              o
  Imagebar.OnChange                          o                                           o
  Leftbar.OnChange             o             o            o               o
  Margin.OnChange      o                     o                            o
  Ruler.OnChange       o                     o
  CMFontChanged        o                     o                            o
  CMColorChanged       o                     o
  文字列の更新                               o            o               o
  ExchangeList                               o            o               o
  WrapOption.OnChange                        o            o               o

  初期化・更新メソッド群
  AdjustImagebarWidth;
  AdjustLeftbarColumn;
  AdjustLeftbarWidth;
  AdjustRulerHeight;
  InitLeftbarEdge;
  InitRulerBitmaps;
  InitOriginBase;

  InitDrawInfo では以下の初期化メソッドが実行されている。
    AdjustImagebarWidth
    AdjustLeftbarColumn
    AdjustLeftbarWidth
    AdjustRulerHeight
*)

procedure TEditor.CreateMarginBitmaps;
begin
  FLeftbarEdge := TBitmap.Create;
  FOriginBase := TBitmap.Create;
  FRulerBase := TBitmap.Create;
  FRulerMarkBase := TBitmap.Create;
  FRulerGauge := TBitmap.Create;
  FRulerDigitMask := TBitmap.Create;
  FRulerDigit := TBitmap.Create;
  FRulerMarkDigit := TBitmap.Create;
  FRulerEdge := TBitmap.Create;
  FRulerDigitHeight := 9;
  FRulerDigitWidth := 5;
  InitRulerDigitMask; // Assign FRulerDigitMask.Handle
  InitRulerEdge;
end;

procedure TEditor.DestroyMarginBitmaps;
begin
  FLeftbarEdge.Free;
  FOriginBase.Free;
  FRulerBase.Free;
  FRulerMarkBase.Free;
  FRulerGauge.Free;
  FRulerDigitMask.Free;
  FRulerDigit.Free;
  FRulerMarkDigit.Free;
  FRulerEdge.Free;
end;


// FOriginBase  /////////////////////////////////

procedure TEditor.InitOriginBase;
(*
                Ruler Edge
  Leftbar Edge    o   x
            o     |   |
            x     __  x
*)
var
  T, L: Integer;
  R: TRect;
begin
  if not HandleAllocated then
    Exit;
  T := TopMargin;
  L := LeftMargin;
  FOriginBase.Width := L;
  FOriginBase.Height := T;
  with FOriginBase.Canvas do
  begin
    Brush.Color := Color;
    FillRect(Rect(0, 0, L, T));
    if FLeftbar.FVisible and FLeftbar.FEdge then
    begin
      R := Rect(0, 0, FImagebarWidth + FLeftbarWidth, T);
      if FLeftbar.FBkColor = clNone then
        Brush.Color := Color
      else
        Brush.Color := FLeftbar.FBkColor;
      FillRect(R);
      Draw(FImagebarWidth + FLeftbarWidth - 2, 0, FLeftbarEdge);
    end;
    if FRuler.FVisible and FRuler.FEdge then
    begin
      if FLeftbar.FVisible and FLeftbar.FEdge then
        R := Rect(FImagebarWidth + FLeftbarWidth, 0, L, FRulerHeight)
      else
        R := Rect(0, 0, L, FRulerHeight);
      if FRuler.FBkColor = clNone then
        Brush.Color := Color
      else
        Brush.Color := FRuler.FBkColor;
      FillRect(R);
      Draw(R.Left - 1, FRulerHeight - 2, FRulerEdge);
      { $OriginBase ... FOriginBase へ十文字に Edge を付ける場合
      if FLeftbar.FEdge then
      begin
        R := Rect(0, FRulerHeight - 2, FLeftbarWidth - 2, FRulerHeight);
        FOriginBase.Canvas.CopyRect(R, FRulerEdge.Canvas, Rect(0, 0, FLeftbarWidth - 2, 2));
      end;}
    end;
  end;
end;


// Imagebar //////////////////////////////////////

procedure TEditor.AdjustImagebarWidth;
begin
  with FImagebar do
    if not FVisible then
      FImagebarWidth := 0
    else
      FImagebarWidth := FLeftMargin + FDigitWidth + FMarkWidth + FRightMargin;
end;

procedure TEditor.PaintImagebar(Sr, Er: Integer);
var
  R: TRect;
  T, H, I: Integer;
  M: TRowMark;
begin
  if not Showing then
    Exit;
  T := TopMargin;
  H := GetRowHeight;
  if FLeftbar.FVisible and (FLeftbar.FBkColor <> clNone) then
    Canvas.Brush.Color := FLeftbar.FBkColor
  else
    Canvas.Brush.Color := Color;
  R := Rect(0, T + (Sr - FTopRow) * H, FImagebarWidth, T + (Sr - FTopRow + 1) * H);
  for I := Sr to Er do
  begin
    Canvas.FillRect(R);
    if (I >= 0) and (I <= FList.Count - 1) and (FList.RowMarks[I] <> []) then
    begin
      // digits
      for M := rm0 to rm9 do
        if M in FList.RowMarks[I] then
        begin
          if (FImageDigits <> nil) and (Byte(M) <= FImageDigits.Count - 1) then
            FImageDigits.Draw(Canvas, R.Left + FImagebar.FLeftMargin, R.Top + 2, Byte(M))
          else
            DefaultDigits.Draw(Canvas, R.Left + FImagebar.FLeftMargin, R.Top + 2, Byte(M));
          Break;
        end;
      // marks
      for M := rm10 to rm15 do
        if M in FList.RowMarks[I] then
        begin
          if (FImageMarks <> nil) and (Byte(M) - 11 <= FImageMarks.Count - 1) then
            FImageMarks.Draw(Canvas, R.Left + FImagebar.FLeftMargin + FImagebar.FDigitWidth, R.Top + 2, Byte(M) - 10)
          else
            DefaultMarks.Draw(Canvas, R.Left + FImagebar.FLeftMargin + FImagebar.FDigitWidth, R.Top + 2, Byte(M) - 10);
          Break;
        end;
    end;
    OffsetRect(R, 0, H);
  end;
end;


// Leftbar //////////////////////////////////////

function TEditor.AdjustLeftbarColumn: Boolean;
(*
  Leftbar の各プロパティ値と、文字列オブジェクト FList の行数に
  応じて表示桁数 FLeftbarColumn を更新する。更新があった場合は
  True を返す

       ZeroBase      not ZeroBase
       0             1
       1             2
       .             .
       8             9    [EOF]
       9   [EOF]    10[EOF]
      10[EOF]
*)
var
  C, L: Integer;
begin
  Result := False;
  if HandleAllocated and FLeftbar.FVisible and FLeftbar.FShowNumber then
  begin
    C := FLeftbarColumn;
    L := FList.Count - 1;
    if FLeftbar.FShowNumberMode = nmLine then
      L := RowToLines(L);
    if not FLeftbar.FZeroBase then
      Inc(L);
    if ListRows(FList.Count - 1) <> raEof then
      Inc(L);
    FLeftbarColumn :=
      Min(8, Max(FLeftbar.FColumn, Length(IntToStr(Max(0, L)))));
    Result := C <> FLeftbarColumn;
  end
  else
    FLeftbarColumn := FLeftbar.FColumn;
end;

procedure TEditor.AdjustLeftbarWidth;
(*
  Leftbar の各プロパティ値と、FLeftbarColumn に
  応じて表示幅を更新する。
*)
begin
  if not FLeftbar.FVisible then
    FLeftbarWidth := 0
  else
    FLeftbarWidth := FLeftbar.FLeftMargin +
                     FLeftbarColumn * FFontWidth +
                     FLeftbar.FRightMargin + 2; // 2 は FLeftbarEdge の幅
end;

procedure TEditor.UpdateLeftBarWidth(OldWidth, NewWidth: Integer);
(*
  OldWidth, NewWidth の差分に対する画面スクロールと更新を行う
*)
var
  C, R: TRect;
begin
  if Showing then
  begin
    C := Rect(FImagebarWidth, 0, Width, Height);
    ScrollWindowEx(Handle, NewWidth - OldWidth, 0, nil, @C, 0, @R, SW_SCROLLCHILDREN);
    InvalidateRect(Handle, @R, False);
    R := Rect(FImagebarWidth, 0, FImagebarWidth + NewWidth, Height);
    InvalidateRect(Handle, @R, False);
    UpdateWindow(Handle);
  end;
end;

procedure TEditor.InitLeftbarEdge;
var
  R: TRect;
begin
  FLeftbarEdge.Width := 2;
  FLeftbarEdge.Height := Screen.Height;
  R := Rect(0, 0, 1, FLeftbarEdge.Height);
  with FLeftbarEdge.Canvas do
    if FLeftbar.FEdge then
    begin
      Brush.Color := clWhite;
      FillRect(R);
      OffsetRect(R, 1, 0);
      Brush.Color := clGray;
      FillRect(R);
    end
    else
    begin
      if FLeftbar.FBkColor = clNone then
        Brush.Color := Color
      else
        Brush.Color := FLeftbar.FBkColor;
      FillRect(R);
      OffsetRect(R, 1, 0);
      if FLeftbar.FColor = clNone then
        Brush.Color := Self.Font.Color
      else
        Brush.Color := FLeftbar.FColor;
      FillRect(R);
    end;
end;

procedure TEditor.InvalidateLeftbar(StartRow, EndRow: Integer);
(*
  指定行間の行番号部分を無効化し UpdateWindow する
  TEditorScreen.Update のヘルパーメソッドとして利用されている。
*)
var
  Sr, Er, H, T: Integer;
  R: TRect;
begin
  if not HandleAllocated then
    Exit;
  Sr := Max(Min(StartRow, EndRow), FTopRow);
  Er := Min(Max(StartRow, EndRow), FTopRow + FRowCount);
  H := GetRowHeight;
  T := TopMargin;
  R := Rect(
         FImagebarWidth,
         T + H * (Sr - FTopRow),
         FImagebarWidth + FLeftbarWidth,
         T + H * (Er - FTopRow) + FFontHeight
       );
  InvalidateRect(Handle, @R, False);
  UpdateWindow(Handle);
end;

procedure TEditor.PaintLeftbar(Sr, Er: Integer);
var
  R: TRect;
  T, H, I, Id, J, N: Integer;
  S: String;
begin
  if not Showing then
    Exit;
  T := TopMargin;
  H := GetRowHeight;
  // FLeftbarEdge: TBitmap は Leftbar.Edge プロパティ値に応じたモノ
  // に描画されている FRulerEdge とは違う
  Canvas.Draw(FImagebarWidth + FLeftbarWidth - 2, T, FLeftbarEdge);
  if FLeftbar.FBkColor = clNone then
    Canvas.Brush.Color := Color
  else
    Canvas.Brush.Color := FLeftbar.FBkColor;
  Canvas.Font.Assign(Font);
  if FLeftbar.FColor = clNone then
    Canvas.Font.Color := Font.Color
  else
    Canvas.Font.Color := FLeftbar.FColor;
  if not FLeftbar.FShowNumber then
  begin
    R := Rect(FImagebarWidth, T + (Sr - FTopRow) * H, FImagebarWidth + FLeftbarWidth - 2, T + (Er - FTopRow + 1) * H);
    Canvas.FillRect(R);
  end
  else
  begin
    R := Rect(FImagebarWidth, T + (Sr - FTopRow) * H, FImagebarWidth + FLeftbarWidth - 2, T + (Sr - FTopRow + 1) * H);
    if FLeftbar.FShowNumberMode = nmRow then
      for I := Sr to Er do
      begin
        Id := I;
        if not FLeftbar.FZeroBase then
          Inc(Id);
        Str(Id: FLeftbarColumn, S);
        if FLeftbar.FZeroLead then
          for J := 1 to Length(S) do
            if S[J] = #$20 then
              S[J] := #$30;
        if (I = 0) or
           (I < FList.Count) or
           ((I = FList.Count) and (FList.Rows[I - 1] <> raEof)) then
          DrawTextRect(R, FImagebarWidth + FLeftbar.FLeftMargin, R.Top, S, ETO_CLIPPED or ETO_OPAQUE)
        else
          Canvas.FillRect(R);
        OffsetRect(R, 0, H);
      end
    else
    begin
      // 初期値 0 base
      Sr := Max(0, Sr);
      if Sr = 0 then
        N := 0
      else
        if Sr <= FList.Count - 1 then
          N := RowToLines(Sr)
        else
          if (Sr = FList.Count) and (ListRows(Sr - 1) = raCrlf) then
            N := RowToLines(Sr - 1) + 1
          else
            N := -1;
      // FList.Count < Sr の場合は N が不定になるが、描画されないので、
      // 参照されることは無い。が、コンパイラが怒るので -1 を入れる。

      // 描画されざる初期値だったら
      if (Sr <> 0) and (ListRows(Sr - 1) <> raCrlf) then
        Inc(N);

      for I := Sr to Er do
      begin
        if (I = 0) or (ListRows(I - 1) = raCrlf) then
        begin
          //  procedure 内 procedure は遅いので、ベタに同じルーチンが書いてある
          Id := N;
          Inc(N);
          if not FLeftbar.FZeroBase then
            Inc(Id);
          Str(Id: FLeftbarColumn, S);
          if FLeftbar.FZeroLead then
            for J := 1 to Length(S) do
              if S[J] = #$20 then
                S[J] := #$30;
          DrawTextRect(R, FImagebarWidth + FLeftbar.FLeftMargin, R.Top, S, ETO_CLIPPED or ETO_OPAQUE);
        end
        else
          Canvas.FillRect(R);
        OffsetRect(R, 0, H);
      end
    end;
  end;
end;


// Ruler ////////////////////////////////////////

procedure TEditor.AdjustRulerHeight;
begin
  if not FRuler.FVisible then
    FRulerHeight := 0
  else
    if FRuler.FEdge then
      FRulerHeight := 11
    else
      FRulerHeight := 10;
end;

procedure TEditor.InitRulerEdge;
var
  R: TRect;
begin
  FRulerEdge.Width := Screen.Width;
  FRulerEdge.Height := 2;
  R := Rect(0, 0, FRulerEdge.Width, 1);
  with FRulerEdge.Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(R);
    OffsetRect(R, 0, 1);
    Brush.Color := clGray;
    FillRect(R);
  end;
end;

procedure TEditor.InitRulerDigitMask;
(*

 01234567012345670123456701234567012345670123456701234567
0
1  **   *    **   **    *  ****  **  ****  **   **
2 *  * **   *  * *  *  **  *    *  *    * *  * *  *
3 *  *  *      *    *  **  ***  *      *  *  * *  *
4 *  *  *     *    *  * *  *  * ***    *   **   ***
5 *  *  *    *      * ****    * *  *  *   *  *    *
6 *  *  *   *    *  *   *  *  * *  *  *   *  * *  *
7  **   *   ****  **    *   **   **   *    **   **
8
          0         1         2         3         4         5         6         7
  0123 4567 0123 4567 0123 4567 0123 4567 0123 4567 0123 4567 0123 4567 0123 4567
0 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111
1 1100 1110 1111 0011 1001 1110 1100 0011 0011 0000 1100 1110 0111 1111 1111 1111
2 1011 0100 1110 1101 0110 1100 1101 1110 1101 1110 1011 0101 1011 1111 1111 1111
3 1011 0110 1111 1101 1110 1100 1100 0110 1111 1101 1011 0101 1011 1111 1111 1111
4 1011 0110 1111 1011 1101 1010 1101 1010 0011 1101 1100 1110 0011 1111 1111 1111
5 1011 0110 1111 0111 1110 1000 0111 1010 1101 1011 1011 0111 1011 1111 1111 1111
6 1011 0110 1110 1111 0110 1110 1101 1010 1101 1011 1011 0101 1011 1111 1111 1111
7 1100 1110 1110 0001 1001 1110 1110 0111 0011 1011 1100 1110 0111 1111 1111 1111
8 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111

0-0000 1-0001 2-0010 3-0011  4-0111 5-0101 6-0110 7-0111
8-1000 9-1001 A-1010 B-1011  C-1100 D-1101 E-1110 F-1111

*)
const
  DigitMaskBits: array[0..71] of Byte = (
    //    0    1    2    3    4    5    6    7
    {0} $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    {1} $CE, $F3, $9E, $C3, $30, $CE, $7F, $FF,
    {2} $B4, $ED, $6C, $DE, $DE, $B5, $BF, $FF,
    {3} $B6, $FD, $EC, $C6, $FD, $B5, $BF, $FF,
    {4} $B6, $FB, $DA, $DA, $3D, $CE, $3F, $FF,
    {5} $B6, $F7, $E8, $7A, $DB, $B7, $BF, $FF,
    {6} $B6, $EF, $6E, $DA, $DB, $B5, $BF, $FF,
    {7} $CE, $E1, $9E, $E7, $3B, $CE, $7F, $FF,
    {8} $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF);
begin
  FRulerDigitMask.Handle := CreateBitmap(56, 9, 1, 1, @DigitMaskBits);
end;

procedure TEditor.InitRulerDigits;
var
  S, D: TRect;
  B, C: TColor;

  procedure InvertMask;
  begin
    FRulerDigitMask.Canvas.CopyMode := cmNotSrcCopy;
    FRulerDigitMask.Canvas.CopyRect(D, FRulerDigitMask.Canvas, S);
  end;

  procedure InitDigit(Digit: TBitmap; BrushColor, PenColor: TColor);
  var
    Bitmap: TBitmap;
  begin
    S := Rect(0, 0, Digit.Width, Digit.Height);
    D := S;
    Bitmap := TBitmap.Create;
    try
      Bitmap.Width := Digit.Width;
      Bitmap.Height := Digit.Height;
      // BrushColor
      Bitmap.Canvas.Brush.Color := BrushColor;
      Bitmap.Canvas.FillRect(Bitmap.Canvas.ClipRect);
      Bitmap.Canvas.CopyMode := cmSrcAnd; // マスクと AND
      Bitmap.Canvas.CopyRect(D, FRulerDigitMask.Canvas, S);
      // マスクを反転
      InvertMask;
      // PenColor
      Digit.Canvas.Brush.Color := PenColor;
      Digit.Canvas.FillRect(Digit.Canvas.ClipRect);
      Digit.Canvas.CopyMode := cmSrcAnd; // マスクと AND
      Digit.Canvas.CopyRect(D, FRulerDigitMask.Canvas, S);
      // 合成
      Digit.Canvas.CopyMode := cmSrcPaint; // OR
      Digit.Canvas.CopyRect(D, Bitmap.Canvas, S);
      // マスクを元に戻す
      InvertMask;
    finally
      Bitmap.Free;
    end;
  end;

begin
  FRulerDigit.Width := FRulerDigitMask.Width;
  FRulerDigit.Height := FRulerDigitMask.Height;
  if FRuler.FBkColor = clNone then
    B := Color
  else
    B := FRuler.FBkColor;
  if FRuler.FColor = clNone then
    C := Font.Color
  else
    C := FRuler.FColor;
  InitDigit(FRulerDigit, B, C);
  FRulerMarkDigit.Width := FRulerDigitMask.Width;
  FRulerMarkDigit.Height := FRulerDigitMask.Height;
  if FRuler.FMarkColor = clNone then
    C := Font.Color
  else
    C := FRuler.FMarkColor;
  InitDigit(FRulerMarkDigit, C, B);
end;

function TEditor.RulerWidth: Integer;
var
  W: Integer;
begin
  W := FFontWidth * FRuler.FGaugeRange;
  Result := Screen.Width div W * W + W + W;
end;

procedure TEditor.InitRulerBases;
begin
  if not HandleAllocated then
    Exit;
  FRulerBase.Width := RulerWidth;
  FRulerBase.Height := FRulerHeight;
  FRulerMarkBase.Width := FRulerBase.Width;
  FRulerMarkBase.Height := FRulerHeight;
end;

procedure TEditor.InitRulerGauge;
var
  C, W, I: Integer;
  S, D: TRect;
begin
  if not HandleAllocated then
    Exit;
  C := FFontWidth;
  FRulerGauge.Width := RulerWidth;
  FRulerGauge.Height := FRulerHeight;
  W := C * FRuler.FGaugeRange;
  with FRulerGauge.Canvas do
  begin
    // 塗りつぶして
    if FRuler.FBkColor = clNone then
      Brush.Color := Color
    else
      Brush.Color := FRuler.FBkColor;
    FillRect(ClipRect);
    // １区画だけ線を描く
    if FRuler.FColor = clNone then
      Pen.Color := Self.Font.Color
    else
      Pen.Color := FRuler.FColor;
    Pen.Width := 1;
    // 縦線
    for I := 0 to FRuler.FGaugeRange - 1 do
    begin
      if I mod FRuler.FGaugeRange = 0 then
        MoveTo(I * C, 0)
      else
        if I mod FRuler.FGaugeRange = FRuler.FGaugeRange div 2 then
          MoveTo(I * C, 3)
        else
          MoveTo(I * C, 6);
      LineTo(I * C, FRulerHeight - 1);
    end;
    // 横線
    if not FRuler.FEdge then
    begin
      MoveTo(0, FRulerHeight - 1);
      LineTo(W, FRulerHeight - 1);
    end
    else
      Draw(0, FRulerHeight - 2, FRulerEdge);
  end;
  // コピー
  S := Rect(0, 0, W, FRulerHeight);
  D := Rect(W, 0, W * 2, FRulerHeight);
  for I := 0 to FRulerGauge.Width div W do
  begin
    FRulerGauge.Canvas.CopyRect(D, FRulerGauge.Canvas, S);
    OffsetRect(S, W, 0);
    OffsetRect(D, W, 0);
  end;
end;

procedure TEditor.InitRulerBitmaps;
begin
  if not HandleAllocated then
    Exit;
  AdjustRulerHeight;
  InitRulerDigits;
  InitRulerGauge;
  InitRulerBases;
end;

procedure TEditor.DrawRulerBases;
var
  GaugeNumber: Integer;
  B, M: TColor;

  procedure DrawNumberToBase(Base, Digit: TBitmap; StartNumber: Integer);
  var
    X, Xp, I, J, Id, W: Integer;
    N: String;
    S, D: TRect;
  begin
    X := 1;
    for I := 0 to Base.Width div FFontWidth div FRuler.FGaugeRange do
    begin
      Xp := X;
      if StartNumber >= MaxLineCharacter then
      begin
        if Base = FRulerBase then
          Base.Canvas.Brush.Color := B
        else
          Base.Canvas.Brush.Color := M;
        if not FRuler.FEdge then
          D := Rect(Xp, 0, Base.Width, Base.Height - 1)
        else
          D := Rect(Xp, 0, Base.Width, Base.Height - 2);
        Base.Canvas.FillRect(D);
      end;
      N := IntToStr(StartNumber);
      for J := 1 to Length(N) do
      begin
        Id := Ord(N[J]) - 48;
        if Id = 1 then
          W := FRulerDigitWidth - 2
        else
          W := FRulerDigitWidth;
        D := Rect(Xp, 0, Xp + W, FRulerDigitHeight);
        S := Rect(Id * FRulerDigitWidth, 0, Id * FRulerDigitWidth + W, FRulerDigitHeight);
        Base.Canvas.CopyRect(D, Digit.Canvas, S);
        Inc(Xp, W);
      end;
      if StartNumber >= MaxLineCharacter then
        Exit;
      Inc(StartNumber, FRuler.FGaugeRange);
      Inc(X, FRuler.FGaugeRange * FFontWidth);
    end;
  end;

begin
  if not HandleAllocated then
    Exit;
  if FRuler.FBkColor = clNone then
    B := Color
  else
    B := FRuler.FBkColor;
  if FRuler.FMarkColor = clNone then
    M := Font.Color
  else
    M := FRuler.FMarkColor;
  GaugeNumber := FLeftScrollWidth div FFontWidth div FRuler.FGaugeRange * FRuler.FGaugeRange;
  // FRulerBase
  FRulerBase.Canvas.Draw(0, 0, FRulerGauge);
  DrawNumberToBase(FRulerBase, FRulerDigit, GaugeNumber);
  // FRulerMarkBase
  FRulerMarkBase.Canvas.Brush.Color := M;
  FRulerMarkBase.Canvas.FillRect(FRulerMarkBase.Canvas.ClipRect);
  DrawNumberToBase(FRulerMarkBase, FRulerMarkDigit, GaugeNumber);
end;

procedure TEditor.DrawRulerMark(ACol: Integer);
var
  C, TC, X, Offset: Integer;
  S, D: TRect;
begin
  if not Showing then
    Exit;
  C := FFontWidth;
  TC := FLeftScrollWidth div C;
  if (ACol >= TC) and (ACol <= TC + FColCount) then
  begin
    X := LeftMargin + (ACol - TC) * C + 1;
    D := Rect(X, 0, X + C - 1, FRulerHeight - 1);
    if FRuler.FEdge then
      D.Bottom := D.Bottom - 1;
    Offset := FLeftScrollWidth div C mod FRuler.FGaugeRange * C;
    X := Offset + (ACol - TC) * C + 1;
    S := Rect(X, 0, X + D.Right - D.Left, D.Bottom);
    Canvas.CopyRect(D, FRulerMarkBase.Canvas, S);
  end;
end;

procedure TEditor.HideRulerMark(ACol: Integer);
var
  C, TC, X, Offset: Integer;
  S, D: TRect;
begin
  if not Showing then
    Exit;
  C := FFontWidth;
  TC := FLeftScrollWidth div C;
  if (ACol >= TC) and (ACol <= TC + FColCount) then
  begin
    X := LeftMargin + (ACol - TC) * C + 1; // + 1 はゲージの線幅
    D := Rect(X, 0, X + C - 1, FRulerHeight - 1); // - 1 はゲージの線幅
    if FRuler.FEdge then
      D.Bottom := D.Bottom - 1;
    Offset := FLeftScrollWidth div C mod FRuler.FGaugeRange * C;
    X := Offset + (ACol - TC) * C + 1;
    S := Rect(X, 0, X + D.Right - D.Left, D.Bottom);
    Canvas.CopyRect(D, FRulerBase.Canvas, S);
  end;
end;

procedure TEditor.PaintRuler;
var
  S, D: TRect;
  Offset: Integer;
begin
  if not Showing then
    Exit;
  DrawRulerBases;
  D := Rect(LeftMargin, 0, Width, FRulerHeight);
  Offset := FLeftScrollWidth div FFontWidth mod FRuler.FGaugeRange * FFontWidth;
  S := Rect(Offset, 0, Offset + D.Right - D.Left, D.Bottom);
  Canvas.CopyRect(D, FRulerBase.Canvas, S);
  DrawRulerMark(FCol);
end;


// イベントハンドラ呼び出し /////////////////////////////////////////

procedure TEditor.DoCaretMoved;
begin
  if Assigned(FOnCaretMoved) then
    FOnCaretMoved(Self);
end;

procedure TEditor.DoChange;
(*
  文字列に変化があった場合は、ここへやってくる
  BeginUpdate 状態でここに入ることはない。cf.TStringList.Changed

  設計時のプロパティエディタによる Lines プロパティの更新では、
  Assign, Add, Insert などが実行されることなくここへやってくる
  （ SetOrdValue とはそういうものらしい）ここで FWordWrap への
  対応処理を行う
*)
var
  W: Integer;
begin
  // 設計時の文字列変更と WordWrap の処理
  if (csDesigning in ComponentState) and WordWrap then
  begin
    FList.WrapLines;
    FList.InitBrackets;
  end;
  // TEditorScreen へ通知して描画する
  FScreen.Update;
  // 行番号表示桁・幅を更新
  if FLeftbar.FVisible and FLeftbar.FShowNumber and AdjustLeftbarColumn then
  begin
    W := FLeftbarWidth;
    AdjustLeftbarWidth;
    InitOriginBase;
    UpdateLeftbarWidth(W, FLeftbarWidth);
    AdjustColCount;
  end;
  // スクロールバー更新
  InitScroll;
  // 文字列を変更していなくても、BeginUpdate, EndUpdate すると
  // OnChange イベントが発生するのを回避するために、
  // FList.FDrawInfo.NeedUpdate を判別する
  if FList.FDrawInfo.NeedUpdate then
  begin
    FModified := True;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TEditor.DoDrawLine(ARect: TRect; X, Y: Integer;
  LineStr: String; Index: Integer; SelectedArea: Boolean);
begin
  if Assigned(FOnDrawLine) then
    FOnDrawLine(Self, LineStr, X, Y, Index, ARect, SelectedArea);
end;

procedure TEditor.DoSelectionChange(Selection: Boolean);
begin
  if Assigned(FOnSelectionChange) then
    FOnSelectionChange(Self, Selection);
end;

procedure TEditor.DoSelectionModeChange;
begin
  if Assigned(FOnSelectionModeChange) then
    FOnSelectionModeChange(Self);
end;

procedure TEditor.DoTopColChange;
begin
  if Assigned(FOnTopColChange) then
    FOnTopColChange(Self);
end;

procedure TEditor.DoTopRowChange;
begin
  if Assigned(FOnTopRowChange) then
    FOnTopRowChange(Self);
end;

// プロパティのアクセスメソッド /////////////////////////////////////

function TEditor.GetActiveFountain: TFountain;
begin
  if Assigned(FFountain) then
    Result := FFountain
  else
    Result := FView.FEditorFountain;
end;

function TEditor.GetListBracket(Index: Integer): Integer;
begin
  Result := FList.Brackets[Index];
end;

function TEditor.GetListCount: Integer;
begin
  Result := FList.Count;
end;

function TEditor.GetListData(Index: Integer): TRowAttributeData;
begin
  with Result do
  begin
    RowAttribute := FList.Rows[Index];
    PrevRowAttribute := FList.PrevRows[Index];
    BracketIndex := FList.Brackets[Index];
    ElementIndex := FList.Elements[Index];
    WrappedByte := FList.WrappedBytes[Index];
    Remain := FList.Remains[Index];
    StartToken := FList.Tokens[Index];
    PrevToken := FList.PrevTokens[Index];
    DataStr := FList.DataStrings[Index];
  end;
end;

function TEditor.GetListDataString(Index: Integer): String;
begin
  Result := FList.DataStrings[Index];
end;

function TEditor.GetListElement(Index: Integer): Integer;
begin
  Result := FList.Elements[Index];
end;

function TEditor.GetListPrevRow(Index: Integer): TRowAttribute;
begin
  Result := FList.PrevRows[Index];
end;

function TEditor.GetListPrevToken(Index: Integer): Char;
begin
  Result := FList.PrevTokens[Index];
end;

function TEditor.GetListRemain(Index: Integer): Integer;
begin
  Result := FList.Remains[Index];
end;

function TEditor.GetListRow(Index: Integer): TEditorRowAttribute;
begin
  Result := ListRows(Index);
end;

function TEditor.GetListString(Index: Integer): String;
begin
  Result := ListStr(Index);
end;

function TEditor.GetListToken(Index: Integer): Char;
begin
  Result := FList.Tokens[Index];
end;

function TEditor.GetListWrappedByte(Index: Integer): Integer;
begin
  Result := FList.WrappedBytes[Index];
end;

function TEditor.GetListRowMarks(Index: Integer): TRowMarks;
begin
  if (Index >= 0) and (Index <= FList.Count - 1) then
    Result := FList.RowMarks[Index]
  else
    Result := [];
end;

procedure TEditor.SetListRowMarks(Index: Integer; Value: TRowMarks);
var
  R: TRect;
  T, H: Integer;
begin
  if (Index >= 0) and (Index <= FList.Count - 1) and
     (FList.RowMarks[Index] <> Value) then
  begin
    FList.IncludeRowMarks(Value - FList.RowMarks[Index]);
    FList.ExcludeRowMarks(FList.RowMarks[Index] - Value);
    FList.RowMarks[Index] := Value;
    if FImagebar.FVisible then
    begin
      T := TopMargin;
      H := GetRowHeight;
      R := Rect(0, T + (Index - FTopRow) * H, FImagebarWidth, T + (Index - FTopRow + 1) * H);
      InvalidateRect(Handle, @R, False);
      UpdateWindow(Handle);
    end;
  end;
end;

function TEditor.GetReserveWordList: TStringList;
begin
  Result := FView.FEditorFountain.ReserveWordList;
end;

function TEditor.GetRowHeight: Integer;
begin
  Result := FFontHeight + FMargin.FUnderline + FMargin.FLine;
end;

function TEditor.GetSelected: Boolean;
begin
  Result := FSelectionState = sstSelected;
end;

function TEditor.GetSelectedData: Boolean;
begin
  Result := FSelectionState in [sstSelected, sstHitSelected];
end;

function TEditor.GetSelectedDraw: Boolean;
begin
  Result := (FSelectionState = sstSelected) or
            ((FSelectionState = sstHitSelected) and (FHitStyle = hsDraw));
end;

function TEditor.GetHitSelected: Boolean;
begin
  Result := FSelectionState = sstHitSelected;
end;

function TEditor.GetSelDragging: Boolean;
begin
  Result := FSelDragState = sdDragging;
end;

function TEditor.GetSelLength: Integer;
var
  I, Idx, L: Integer;
  S, Attr: String;
begin
  Result := 0;
  if not Selected then
    Exit;
  with FSelStr do
  begin
    if Sr = Er then
      Result := Length(Copy(ListStr(Sr), Sc + 1, Ec - Sc + 1))
    else
      if FSelectionMode = smLine then
        for I := Sr to Er do
          if I = Sr then
          begin
            S := ListStr(I);
            Inc(Result,
                Length(Copy(S, Sc + 1, Length(S))) +
                2 * Byte(ListRows(I) = raCrlf))
          end
          else
            if I = Er then
              Inc(Result,
                  Length(Copy(ListStr(I), 1, Ec + 1)))
            else
              Inc(Result,
                  Length(ListStr(I)) +
                  2 * Byte(ListRows(I) = raCrlf))
      else
        for I := Sr to Er do
        begin
          S := ListStr(I);
          Attr := StrToAttributes(S);
          Idx := BoxLeftIndex(Attr, FSelDraw.Sc + 1);
          L := BoxRightIndex(Attr, FSelDraw.Ec) - Idx + 1;
          Inc(Result, Length(Copy(S, Idx, L)) + 2); // + 2 は #13#10
        end;
  end;
end;

function TEditor.GetSelStart: Integer;
var
  I, R, C: Integer;
  S, Attr: String;
begin
  Result := 0;
  if FList.Count = 0 then
    Exit;
  if SelectedData then
  begin
    R := FSelStr.Sr;
    C := FSelStr.Sc;
  end
  else
  begin
    R := FRow;
    S := ListStr(FRow);
    Attr := StrToAttributes(S);
    C := Min(Length(S),
             FCol - IncludeCharCount(Attr, caTabSpace, FCol + 1));
  end;
  for I := 0 to R - 1 do
    Inc(Result, Length(ListStr(I)) + 2 * Byte(ListRows(I) = raCrlf));
  Inc(Result, C);
end;

function TEditor.GetSelText: String;
var
  I, Idx, L: Integer;
  S, Str, Attr: String;
  BufList: TStringList;
begin
  Result := '';
  if not Selected then
    Exit;
  with FSelStr do
  begin
    if Sr = Er then
      Result := Copy(ListStr(Sr), Sc + 1, Ec - Sc + 1)
    else
    begin
      BufList := TStringList.Create;
      try
        // データ取得
        if FSelectionMode = smLine then
        begin
          // smLine
          // 最後の行まで BufList に取得して Result := BufList.Text;
          // とすると、文字列の最後に #13#10 が付加されるため Er - 1 とする
          // 取り敢えず領域確保（この方が速い）
          for I := Sr to Er - 1 do
            BufList.Add('');
          Idx := 0;
          S := '';
          for I := Sr to Er - 1 do
          begin
            Str := ListStr(I);
            if I = Sr then
              // １行目
              S := Copy(Str, Sc + 1, Length(Str))
            else
              // 2..Er - 1
              S := S + Str;
            if (I = FList.Count - 1) or (ListRows(I) = raCrlf) then
            begin
              BufList[Idx] := S;
              S := '';
              Inc(Idx);
            end
          end;
          // 不要になった行の削除
          while Idx <= BufList.Count - 1 do
            BufList.Delete(Idx);
          // BufList に追加されなかった文字列と最後の行を追加
          Result := BufList.Text + S + Copy(ListStr(Er), 1, Ec + 1);
        end
        else
        begin
          // smBox
          for I := Sr to Er do
            BufList.Add('');
          for I := Sr to Er do
          begin
            S := ListStr(I);
            Attr := StrToAttributes(S);
            Idx := BoxLeftIndex(Attr, FSelDraw.Sc + 1);
            L := BoxRightIndex(Attr, FSelDraw.Ec) - Idx + 1;
            BufList[I - Sr] := Copy(S, Idx, L);
          end;
          Result := BufList.Text;
        end;
      finally
        BufList.Free;
      end;
    end;
  end;
end;

function TEditor.GetUndoListMax: Integer;
begin
  Result := FList.FUndoObj.FListMax;
end;

function TEditor.GetUndoObj: TEditorUndoObj;
begin
  Result := FList.FUndoObj;
end;

function TEditor.GetWordWrap: Boolean;
begin
  Result := FList.FWordWrap;
end;

function TEditor.GetWrapOption: TEditorWrapOption;
begin
  Result := FList.FWrapOption;
end;

procedure TEditor.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TEditor.SetCaret(Value: TEditorCaret);
begin
  FCaret.Assign(Value);
end;

procedure TEditor.SetCol(Value: Integer);
var
  Direction: Integer;
begin
(*
  #MaxLineCharacter １，０００文字について

  キャレットの移動
  １，０００文字目の後にリターンキーを入力出来るようにすることと。
  １，０００文字目が全角１バイト目の場合は１，００１文字目の後ろまで
  移動可能な仕様とするため Value の最大値は MaxLineCharacter + 1
  とする。１，０００文字目が全角１バイト目かどうかの判別は AdjustCol
  で行っている。

  描画
  FDxArray は MaxLineCharacter + 1 文字の描画に対応している。
  DrawTextRect では、引数の文字列が１，０００文字を越える場合、その
  文字列を１，０００文字目が全角１バイト目の場合は１，００１文字に、
  そうでない場合は１，０００文字に整形してから描画している。
  PaintLine, PaintLineSelected でも、改行マーク、EOF マークを描画
  する際、１，０００文字を越えるかどうか、全角１バイト目かどうかの
  判別を行っている。
*)

  // ※ 先に FRow が設定されていなければならない

  Value := Min(Max(0, Value), MaxLineCharacter + 1);
  if FRuler.FVisible then
    HideRulerMark(FCol);
  if FCol < Value then
    Direction := 1
  else
    Direction := -1;
  FCol := Value;
  AdjustCol(False, Direction);
  if FRuler.FVisible then
    DrawRulerMark(FCol);
end;

procedure TEditor.SetCursorState(Value: TEditorMouseCursorState);
begin
  if FCursorState <> Value then
  begin
    FCursorState := Value;
    if FCaret.FAutoCursor then
      case Value of
        mcClient:
          Cursor := FCaret.FCursors.FDefaultCursor;
        mcLeftMargin:
          Cursor := FCaret.FCursors.FLeftMarginCursor;
        mcTopMargin:
          Cursor := FCaret.FCursors.FTopMarginCursor;
        mcInSel:
          Cursor := FCaret.FCursors.FInSelCursor;
        mcDragging:
          Windows.SetCursor(Screen.Cursors[FCaret.FCursors.FDragSelCursor]);
        mcDraggingCopy:
          Windows.SetCursor(Screen.Cursors[FCaret.FCursors.FDragSelCopyCursor]);
      end;
  end;
end;

procedure TEditor.SetFountain(Value: TFountain);
begin
  if FFountain <> Value then
  begin
    if FFountain <> nil then
      FFountain.NotifyEventList.Remove(ViewChanged);
    if Value <> nil then
    begin
      Value.NotifyEventList.Add(ViewChanged);
      Value.FreeNotification(Self);
    end;
    FFountain := Value;
    FList.InitBrackets;
    Invalidate;
  end;
end;

(*
  #HitSelLength ....... 検索一致文字列の描画について

  ■ HitStyle, HitSelLength プロパティ
  
  ver 2.30 では、検索一致文字列の表示方式と描画色を指定出来るようにした。
  背景色・前景色は View.Colors.Hit.BkColor, Color プロパティに保持されて
  いる。表示方式は TEditorHitStyle で表現される

  TEditorHitStyle
    hsSelect ... 従来型の選択方式
    hsDraw ..... View.Colors.Hit に保持される背景色・前景色で描画
    hsCaret .... 検索一致文字列長のキャレットを作成し点滅させる
                 （折り返し、改行を含むヒット文字列には非対応）

  検索一致文字列を指定色で描画させる場合は、HitStyle プロパティに hsDraw
  を指定し、キャレットを表示させる場合は hsCaret を指定してから 
  HitSelLength プロパティに検索一致文字列長を代入する。

  ■ 選択領域データの利用
  
  以下では、hsDraw, hsCaret 方式の実現について記述する。

  検索一致文字列の指定色描画は、選択領域の作成に必要なデータや仕組みを
  そのまま利用し、背景色・前景色を変更するだけで良いことになるが、Delphi
  のコードエディタのように、「選択状態ではない」状態を作り出さなければ
  ならない。
  そこで、TEditorSelectionState に sstHitSelected 項目を追加し、描画に
  必要なデータや仕組みは選択領域のものを流用するが、選択状態ではない状態
  を作り出すことにする。
  
  描画処理を伴わない hsCaret の場合でも、下記の置き換え処理を考慮して
  選択領域データの初期化・更新を行うことにする。（置き換えに hsCaretは
  使えないが後述する）
  
  実際には、SetHitSelLength メソッドで、HitStyle が hsDraw, hsCaret の場合
  FHitSelecting フラグを立てることによって、StartSelection メソッドでの
  状態遷移をコントロールする。

    sstSelected ...... 従来の選択状態。
    sstHitSelected ... 検索一致文字列を表現している状態。
                       = hsDraw or hsCaret 状態

  置き換え処理を行う場合、通常、該当文字列を選択した状態で SelText プロパ
  ティに置き換え文字列を代入するが、sstHitSelected は選択状態ではないので
  この処理が行えない。そこで、sstHitSelected 状態を sstSelected 状態に変更
  するメソッド HitToSelected を用意する。
  
  選択状態として扱うためには、sstHitSelected 状態が選択領域データを正しく
  保持している必要があるので、hsCaret の場合も選択領域データを初期化・更
  新する仕様とするのは前述の通りだが、hsCaret の状態で置き換え確認ダイア
  ログを出すと、TEditor がフォーカスを失うので、キャレットが消えてしまい
  どこが選択されているのかが、見た目判別不能になるので、「置き換え処理に
  おける検索一致表現において、hsCaret は使えない」ことになり、これは
  「置き換え確認ダイアログを出す置き換え処理」を行う際には hsCaret を使わ
  ないような工夫をユーザーに行って頂くより方法は無い。
  
  ■ 状態を判別するためのプロパティ
  
  プロパティ     状態による返り値                    意味                            利用する場面
                 sstSelected      sstHitSelected
                 通常の選択状態   hsDraw   hsCaret
  Selected       o                x        x         sstSelected                     従来の選択された文字列操作で利用される。

  SelectedData   o                o        o         sstSelected or sstHitSelected   選択領域データを保持しているので、初期化（領域を
                                                                                     ノーマル描画するか、キャレットを元に戻す）処理を
                                                                                     行うべきかどうかを判別するために利用される。

  SelectedDraw   o                o        x         sstSelected or                  選択領域データを利用して描画すべきであるか、
                                                     (sstHitSelected and hsDraw)     又は描画されているかを判別するために利用される。

  HitSelected    x                o        o         sstHitSelected                  ・キー入力においては、非 Selected 状態の場合、選択
                                                                                       領域データを初期化するかどうかの判別に利用し、
                                                                                     ・SelectedDraw によって分岐した選択領域データによる
                                                                                       描画処理においては、View.Colors.Select 又は
                                                                                       View.Colors.Hit のどちらを利用するかの判別に利用
                                                                                       される。

  ■ CleanSelection メソッド
  
  CleanSelection メソッドでは、SelectedData 状態をクリアする処理が行われる。
  ・選択領域データによる描画が行われている場合（ SelectedDraw 状態 ）はそこを
    ノーマル描画する。
  ・ヒット文字列長のキャレットが表示されている場合は
    （ HitSelected and (HitStyle = hsCaret) ）キャレットを元に戻す。
  ・また FHitSelLength を０で初期化する処理も行われる。
  
  SetHitSelLength では、選択領域データを初期化する段階で、この CleanSelection
  が実行されるので、FHitSelLength の更新を処理の最後で行っている。

  ■ 選択状態の解除

  従来は、Selected の値を判別して選択状態を解除していたが、この処理は
  SelectedData の値を判別することになる。キー入力時には、Selected,
  HitSelected の組合せによる判別が必要になる場合があるので注意。
*)

procedure TEditor.SetHitSelLength(Value: Integer);
var
  R, C, CaretWidth: Integer;
begin
  case FHitStyle of
    hsSelect:
      SelLength := Value;
    hsDraw:
      begin
        FHitSelecting := True;
        try
          SelLength := Value;
        finally
          FHitSelecting := False;
        end;
      end;
    hsCaret:
      begin
        if Value <= 0 then
          SelLength := Value
        else
        begin
          // キャレット位置を保存
          R := FRow;
          C := FCol;
          // 選択領域データ設定
          FHitSelecting := True;
          try
            SelLength := Value;
          finally
            FHitSelecting := False;
          end;
          if HandleAllocated and Focused then
          begin
            // キャレット位置を復帰
            SetRowCol(R, C);
            // 選択領域データを利用して、
            // 検索一致文字列長のキャレットを作成し、表示する。
            // 複数行にまたがるキャレットは作成出来ない仕様
            with FSelDraw do
            begin
              if Sr <> Er then
                // 複数行にまたがってヒットしている場合
                CaretWidth := Max(DefaultCaretWidth, FFontWidth * (ExpandListLength(FRow) - Sc))
              else
                // 単一行上での表示
                CaretWidth := Max(DefaultCaretWidth, FFontWidth * (Ec - Sc));
            end;
            CaretHide;
            DestroyCaret;
            CreateCaret(Handle, 0, CaretWidth, FFontHeight);
            CaretShow;
          end;
        end;
      end;
  end;
  // SelLength 処理途中の CleanSelection で FHitSelLength が０に初期化
  // されるので最後に行う。
  FHitSelLength := Value;
end;

procedure TEditor.SetHitStyle(Value: TEditorHitStyle);
begin
  if FHitStyle <> Value then
  begin
    if SelectedData then
      CleanSelection;
    FHitStyle := Value;
  end;
end;

procedure TEditor.SetImagebar(Value: TEditorImagebar);
begin
  FImagebar.Assign(Value);
end;

procedure TEditor.SetImageDigits(Value: TImageList);
begin
  if FImageDigits <> Value then
  begin
    FImageDigits := Value;
    if FImageDigits <> nil then
      FImageDigits.FreeNotification(Self);
    if FImagebar.FVisible then
      Invalidate;
  end;
end;

procedure TEditor.SetImageMarks(Value: TImageList);
begin
  if FImageMarks <> Value then
  begin
    FImageMarks := Value;
    if FImageMarks <> nil then
      FImageMarks.FreeNotification(Self);
    if FImagebar.FVisible then
      Invalidate;
  end;
end;

procedure TEditor.SetLeftbar(Value: TEditorLeftbar);
begin
  FLeftbar.Assign(Value);
end;

procedure TEditor.SetLines(Value: TStrings);
begin
  FList.Assign(Value);
  FList.ClientsInitView;
end;

procedure TEditor.SetMarks(Value: TEditorMarks);
begin
  FMarks.Assign(Value);
end;

procedure TEditor.SetMargin(Value: TEditorMargin);
begin
  FMargin.Assign(Value);
end;

procedure TEditor.SetOverWrite(Value: Boolean);
begin
  if FOverWrite <> Value then
  begin
    FOverWrite := Value;
    UpdateCaret;
  end;
end;

procedure TEditor.SetReadOnly(Value: Boolean);
begin
  // 選択文字列移動中は変更出来ない
  if (FReadOnly <> Value) and not SelDragging then
  begin
    FReadOnly := Value;
    // 選択領域の中にマウスカーソルが居る場合のために
    if Selected and Value then
      Cursor := FCaret.FCursors.FDefaultCursor;
  end;
end;

procedure TEditor.SetReserveWordList(Value: TStringList);
begin
  if not FView.FEditorFountain.ReserveWordList.Equals(Value) then
  begin
    FView.FEditorFountain.ReserveWordList.Assign(Value);
    FList.InitBrackets;
    Invalidate;
  end;
end;

procedure TEditor.SetRow(Value: Integer);
var
  C: Integer;
begin
  if (FRow <> Value) or (FRow = FList.Count) then
  begin
    UnderlineBeginUpdate;
    try
      // FList.Count の行にもキャレットを移動可能な仕様とする
      FRow := Max(0, Min(Value, FList.Count));
      if (FRow = FList.Count) and
         (FRow > 0) and
         (FList.Rows[FList.Count - 1] = raEof) then
        Dec(FRow);
      C := FCol;
      AdjustCol(True, -1);
      if FRuler.FVisible and (C <> FCol) then
      begin
        HideRulerMark(C);
        DrawRulerMark(FCol);
      end;
      // -1 ... AdjustCol で全角２バイト目に突入した時は左へ移動する仕様
    finally
      UnderlineEndUpdate;
    end;
  end;
end;

procedure TEditor.SetRuler(Value: TEditorRuler);
begin
  FRuler.Assign(Value);
end;

procedure TEditor.SetScrollBars(Value: TScrollStyle);
begin
  if FScrollBars <> Value then
  begin
    FScrollBars := Value;
    // RecreateWnd;
    if HandleAllocated then
    begin
      case FScrollBars of
        ssNone:
          ShowScrollBar(Handle, SB_BOTH, False);
        ssHorizontal:
          begin
            ShowScrollBar(Handle, SB_HORZ, True);
            ShowScrollBar(Handle, SB_VERT, False);
          end;
        ssVertical:
          begin
            ShowScrollBar(Handle, SB_VERT, True);
            ShowScrollBar(Handle, SB_HORZ, False);
          end;
        ssBoth:
          ShowScrollBar(Handle, SB_BOTH, True);
      end;
      InitDrawInfo;
      InitScroll;
    end;
  end;
end;

procedure TEditor.SetSelectionMode(Value: TEditorSelectionMode);
begin
  // 選択文字列移動中は変更出来ない
  if (FSelectionMode <> Value) and not SelDragging then
  begin
    FSelectionMode := Value;
    if Selected then
    begin
      // 選択領域の中にマウスカーソルが居る場合を考えて
      if Value = smBox then
        Cursor := FCaret.FCursors.FDefaultCursor;
      // FSelDraw の値がモードによって違うので
      // 一度更新してから再描画する。
      UpdateSelection;
      Invalidate;
    end;
    DoSelectionModeChange;
  end;
end;

procedure TEditor.SetSelLength(Value: Integer);
(*
  現在のキャレット位置から、Value で指定された文字列を選択状態にする。
  SelectedData 状態に対応している。
  HitSelected and (FHitStyle = hsCaret) の場合は、キャレット移動を行わずに
  選択領域データの更新だけを行う。
*)
var
  Count, I, R, Cp, L, C: Integer;
  S, Attr: String;
begin
  if FList.Count = 0 then
    Exit;
  if FSelectionMode = smBox then
    SelectionMode := smLine;
  if Value <= 0 then
  begin
    if SelectedData then
    begin
      // 選択中であれば、選択領域の先頭にキャレットを移動
      Row := FSelDraw.Sr;
      Col := FSelDraw.Sc;
      // 選択状態の解除
      CleanSelection;
    end;
    Exit;
  end;
  FCaretNoMove := True;
  try
    if SelectedData then
    begin
      // 選択中であれば、選択領域の先頭にキャレットを移動
      Row := FSelDraw.Sr;
      Col := FSelDraw.Sc;
    end;
    // 選択領域の初期化
    InitSelection;
    Count := FList.Count;
    I := Value;
    R := FRow;
    S := ListStr(R);
    Attr := StrToAttributes(S);
    Cp := Min(Length(S),
              FCol - IncludeCharCount(Attr, caTabSpace, FCol + 1));
    while R <= Count - 1 do
    begin
      if FList.Rows[R] = raCrlf then
        L := Length(FList[R]) + 2
      else
        if FList.Rows[R] = raEof then
          L := Length(FList[R]) + 1
        else
          L := Length(FList[R]);
      if (I >= L - Cp) and (FList.Rows[R] <> raEof) then
        Dec(I, L - Cp)
      else
      begin
        Row := R;
        C := ExpandTabLength(Copy(FList[FRow], 1, I + Cp));
        Col := Min(C, ExpandListLength(FRow));
        Exit; // Exit to finally
      end;
      Inc(R);
      Cp := 0;
    end;
    // [EOF] 以降
    Row := R;
    Col := ExpandListLength(FRow);
  finally
    FCaretNoMove := False;
    UpdateCaret;
    SetSelection;
  end;
end;

procedure TEditor.SetSelStart(Value: Integer);
var
  I, R, L, C, Count: Integer;
begin
  // FList の先頭から文字数をカウントし、Value を越えそうな
  // Row に対して Col をセットする
  if SelectedData then
    CleanSelection;
  if FList.Count = 0 then
    Exit;
  if Value <= 0 then
  begin
    Row := 0;
    Col := 0;
    Exit;
  end;
  Count := FList.Count;
  I := Value;
  R := 0;
  while R <= Count - 1 do
  begin
    if FList.Rows[R] = raCrlf then
      L := Length(FList[R]) + 2
    else
      if FList.Rows[R] = raEof then
        L := Length(FList[R]) + 1
      else
        L := Length(FList[R]);
    if (I >= L) and (FList.Rows[R] <> raEof) then
      Dec(I, L)
    else
    begin
      Row := R;
      C := ExpandTabLength(Copy(FList[FRow], 1, I));
      Col := Min(C, ExpandListLength(FRow));
      Exit;
    end;
    Inc(R);
  end;
  // [EOF] 以降
  Row := R;
  Col := ExpandListLength(FRow);
end;

procedure TEditor.SetSelText(const Value: String);
begin
  SetSelTextBuf(PChar(Value));
end;

procedure TEditor.SetSpeed(Value: TEditorSpeed);
begin
  FSpeed.Assign(Value);
end;

procedure TEditor.SetTopCol(Value: Integer);
var
  I, HScrollInc: Integer;
  C: TRect;
begin
  if not HandleAllocated then
    Exit;
  if FRuler.Visible then
    HideRulerMark(FCol);
  CaretBeginUpdate;
  try
    // 0..FHScrollMax - FColCount div 2
    Value := Max(0, Min(Value, FHScrollMax - FColCount div 2));
    // 移動量（桁数）を取得
    I := FTopCol - Value;
    // 新しい値を設定
    FTopCol := Value;
    // 桁数→ドット数に変換
    // ここで指定する HScrollInc は、FLeftScrollWidth に追加保存されて
    // 描画の際参照される
    HScrollInc := I * FFontWidth;
    if HScrollInc <> 0 then
    begin
      // クリップを作成 Ruler もスクロールさせるため C.Top = 0
      C := Rect(LeftMargin, 0, Width, Height);
      DoScroll(HScrollInc, 0, nil, @C);
      SetScrollPos(Handle, SB_HORZ, FTopCol, True);
      // IME ウィンドゥの移動
      if FKeyRepeat then
        FCompositionCanceled := True
      else
        SetImeComposition;
      // OnTopColChange イベント
      DoTopColChange;
    end;
  finally
    CaretEndUpdate;
    // DrawRulerMark は PaintRuler で実行されている
  end;
end;

procedure TEditor.SetTopRow(Value: Integer);
var
  V: Integer;
  C: TRect;
begin
  if not HandleAllocated then
    Exit;
  // 連続スクロールの際、画面上下端にアンダーラインが残像として
  // 残るので UnderlineBeginUpdate する。CaretBeginUpdate も行う
  // FTopRow が変化する前に HideUnderline する
  CaretBeginUpdate;
  UnderlineBeginUpdate;
  try
    // 0..FList.Count - 1
    Value := Max(0, Min(Value, FList.Count));

    { $VScrollMax ... [EOF] が画面上端に行ってしまわないようにする場合}
    // 0..FList.Count - FRowCount + 1
    // Value := Max(0, Min(Value, FList.Count - FRowCount + 1));

    // 移動量（行数）を取得
    V := FTopRow - Value;
    // 新しい値を設定
    FTopRow := Value;
    // 行数→ドット数に変換
    // 画面高さ以上のスクロールは意味がない。また単純に
    // V * (FFontHeight + FMargin.FUnderline + FMargin.FLine) では、
    // Integer の許容範囲を超える場合もあるので
    V := Max(Min(V, FRowCount + 1), (FRowCount + 1) * -1) * GetRowHeight;
    if V <> 0 then
    begin
      // クリップを作成 Leftbar もスクロールさせるため C.Left = 0
      C := Rect(0, TopMargin, Width, Height);
      DoScroll(0, V, nil, @C);
      SetScrollPos(Handle, SB_VERT, FTopRow, True);
      // IME ウィンドゥの移動
      if FKeyRepeat then
        FCompositionCanceled := True
      else
        SetImeComposition;
      // OnTopRowChange イベント
      DoTopRowChange;
    end;
  finally
    UnderlineEndUpdate;
    CaretEndUpdate;
  end;
end;

procedure TEditor.SetUndoListMax(Value: Integer);
begin
  Value := Max(UndoListMin, Value); // const
  FList.FUndoObj.FListMax := Value;
end;

procedure TEditor.SetView(Value: TEditorViewInfo);
begin
  FView.Assign(Value);
  // InitView; FView.OnChange に ViewChanged が Assign されている
  ScrollCaret;
  MoveCaret;
end;

procedure TEditor.SetWordWrap(Value: Boolean);
begin
  FList.WordWrap := Value;
end;

procedure TEditor.SetWrapOption(Value: TEditorWrapOption);
begin
  FList.FWrapOption.Assign(Value);
end;


// メッセージハンドラ ///////////////////////////////////////////////

procedure TEditor.CMColorChanged(var Message: TMessage);
begin
  InitRulerBitmaps;
  InitOriginBase;
  inherited; // set brush.color, invalidate
end;

procedure TEditor.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls and (FBorderStyle = bsSingle) then
    RecreateWnd;
  inherited;
end;

procedure TEditor.CMFontChanged(var Message: TMessage);
(*
  TControl.SetFont -> FontChanged -> CM_FONTCHANGED
  フォントが変わった時のイベントから発行されるメッセージ
  TControl.CMFontChaged で Invalidate されるので、
  ここでは InitView 呼び出しを行わない
*)
begin
  if HandleAllocated then
  begin
    // 横スクロール状態を解除して、FLeftScrollWidth を初期化する
    if FLeftScrollWidth > 0 then
      Col := 0;
    InitDrawInfo;
    InitScroll;
    InitRulerBitmaps;
    InitOriginBase;
    UpdateCaret;
  end;
  inherited; { Invalidate in TControl.CMFontChanged }
end;

procedure TEditor.EMCanUndo(var Message: TMessage);
begin
  Message.Result := Byte(not ReadOnly and CanUndo);
end;

procedure TEditor.EMCharFromPos(var Message: TMessage);
var
  X, Y: Word;
  R, C, I, L: Integer;
  S, Attr: String;
begin
  X := Message.LParamLo;
  Y := Message.LParamHi;
  if not PtInRect(ClientRect, Point(X, Y)) then
    Message.Result := -1
  else
  begin
    PosToRowCol(X, Y, R, C, True);
    S := ListStr(R);
    Attr := StrToAttributes(S);
    if IndexChar(Attr, C + 1) = caDBCS2 then
      Dec(C);
    C := Min(Length(S),
             C - IncludeCharCount(Attr, caTabSpace, C + 1));
    L := 0;
    for I := 0 to R - 1 do
      Inc(L, Length(ListStr(I)) + 2 * Byte(ListRows(I) = raCrlf));
    Inc(L, C);
    Message.Result := MakeLong(L, R);
  end;
end;

procedure TEditor.EMEmptyUndoBuffer(var Message: TMessage);
begin
  if not ReadOnly then
    EditorUndoObj.Clear;
end;

procedure TEditor.EMGetFirstVisibleLine(var Message: TMessage);
begin
  Message.Result := TopRow;
end;

procedure TEditor.EMGetLine(var Message: TMessage);
var
  R: Longint;
  L: Word;
  S: String;
begin
  Message.Result := 0;
  R := Message.WParam;
  if (R > FList.Count) or
     ((R = FList.Count) and (ListRows(R) = raEof)) then
    Exit;
  if Message.LParam <> 0 then
  begin
    S := ListStr(R);
    L := Min(Message.LParamLo, Length(S));
    if L > 0 then
      System.Move(S[1], Pointer(Message.LParam)^, L);
    Message.Result := L;
  end;
end;

procedure TEditor.EMGetLineCount(var Message: TMessage);
begin
  Message.Result := ListCount;
end;

procedure TEditor.EMGetModify(var Message: TMessage);
begin
  Message.Result := Byte(Modified);
end;

procedure TEditor.EMGetSel(var Message: TMessage);
var
  L, H: Longint;
begin
  L := SelStart;
  H := L + SelLength;
  if Message.WParam <> 0 then
    System.Move(L, Pointer(Message.WParam)^, SizeOf(L));
  if Message.LParam <> 0 then
    System.Move(H, Pointer(Message.LParam)^, SizeOf(H));
  Message.Result := MakeLong(L, H);
end;

procedure TEditor.EMLineFromChar(var Message: TMessage);
var
  C: Longint;
  R, L: Integer;
  Ra: TEditorRowAttribute;
begin
  C := Message.WParam;
  if C = -1 then
    if SelectedData then
      Message.Result := FSelStr.Sr
    else
      Message.Result := Row
  else
  begin
    Message.Result := 0;
    R := 0;
    while R <= FList.Count - 1 do
    begin
      L := Length(FList[R]);
      Ra := FList.Rows[R];
      case Ra of
        raCrlf: Inc(L, 2);
        raEof: Inc(L, 1);
      end;
      if (C >= L) and (Ra <> raEof) then
        Dec(C, L)
      else
      begin
        Message.Result := R;
        Exit;
      end;
      Inc(R);
    end;
    Message.Result := R;
  end;
end;

procedure TEditor.EMLineIndex(var Message: TMessage);
var
  R: Longint;
  C, I: Integer;
begin
  Message.Result := -1;
  R := Message.WParam;
  if (R > FList.Count) or
     ((R = FList.Count) and (ListRows(R) = raEof)) then
    Exit;
  if R = -1 then
    R := Row;
  C := 0;
  for I := 0 to R - 1 do
    case ListRows(I) of
      raCrlf: Inc(C, Length(ListStr(I)) + 2);
      raEof: Inc(C, Length(ListStr(I)) + 1);
    else
      Inc(C, Length(ListStr(I)));
    end;
  Message.Result := C;
end;

procedure TEditor.EMLineLength(var Message: TMessage);
var
  C: Longint;
  R, L: Integer;
  Ra: TEditorRowAttribute;
begin
  C := Message.WParam;
  if C = -1 then
    if SelectedData then
      Message.Result := FSelStr.Sc + Length(ListStr(FSelStr.Er)) - FSelStr.Ec - 1
    else
      Message.Result := Length(ListStr(Row))
  else
  begin
    R := 0;
    while R <= FList.Count - 1 do
    begin
      L := Length(FList[R]);
      Ra := FList.Rows[R];
      case Ra of
        raCrlf: Inc(L, 2);
        raEof: Inc(L);
      end;
      if (C >= L) and (Ra <> raEof) then
        Dec(C, L)
      else
        Break;
      Inc(R);
    end;
    Message.Result := Length(ListStr(R));
  end;
end;

procedure TEditor.EMPosFromChar(var Message: TMessage);
var
  C: Longint;
  X, Y: Word;
  R, L: Integer;
  Ra: TEditorRowAttribute;
begin
  C := Message.WParam;
  R := 0;
  while R <= FList.Count - 1 do
  begin
    L := Length(FList[R]);
    Ra := FList.Rows[R];
    case Ra of
      raCrlf: Inc(L, 2);
      raEof: Inc(L, 1);
    end;
    if (C >= L) and (Ra <> raEof) then
      Dec(C, L)
    else
      Break;
    Inc(R);
  end;
  Y := TopMargin + (FRow - FTopRow) * GetRowHeight;
  X := LeftMargin + (FCol - FTopCol) * FFontWidth;
  Message.Result := MakeLong(X, Y);
end;

procedure TEditor.EMReplaceSel(var Message: TMessage);
begin
  if not ReadOnly then
    SetSelTextBuf(PChar(Message.LParam));
end;

procedure TEditor.EMScrollCaret(var Message: TMessage);
begin
  if (Row < TopRow) or (TopRow + RowCount - 1 < Row) then
    TopRow := Row - RowCount div 3;
  if (Col < TopCol) or (TopCol + ColCount - 1 < Col) then
    TopCol := Col - ColCount div 3;
end;

procedure TEditor.EMSetModiry(var Message: TMessage);
begin
  if not ReadOnly then
    Modified := Boolean(Message.WParam);
end;

procedure TEditor.EMSetReadOnly(var Message: TMessage);
begin
  ReadOnly := Boolean(Message.WParam);
end;

procedure TEditor.EMSetSel(var Message: TMessage);
var
  W, L: Longint;
begin
  with Message do
    if (WParam = 0) and (LParam = -1) then
      SelectAll
    else
      if WParam = -1 then
        CleanSelection
      else
      begin
        W := Min(WParam, LParam);
        L := Max(WParam, LParam);
        SelStart := W;
        SelLength := L - W;
      end;
end;

procedure TEditor.EMUndo(var Message: TMessage);
begin
  Message.Result := Byte(False);
  if not ReadOnly and CanUndo then
  begin
    Undo;
    Message.Result := Byte(True);
  end;
end;

procedure TEditor.WMClear(var Message: TMessage);
begin
  if not ReadOnly then
    ClearSelection;
end;

procedure TEditor.WMCopy(var Message: TMessage);
begin
  if Selected then
    CopyToClipboard
  else
    Clipboard.AsText := '';
end;

procedure TEditor.WMCut(var Message: TMessage);
begin
  if not ReadOnly and Selected then
    CutToClipboard
  else
    Clipboard.AsText := '';
end;

procedure TEditor.WMPaste(var Message: TMessage);
begin
  if not ReadOnly then
    PasteFromClipboard;
end;

procedure TEditor.WMChar(var Message: TWMChar);
var
  Shift: TShiftState;
  Dc, Rs, I, C, L, Si, ExpandTabCount, R, SelIndex, T: Integer;
  Ts, Ri, Pts, Bsi, J: Integer;
  Buf, S, Attr: String;
  M: TMsg;
  CH, CL: Char;
begin
  inherited;
  Message.Result := 0;
  T := FCaret.FTabSpaceCount;
  case Message.CharCode of
    VK_BACK:
      begin
        if FReadOnly then
          Exit;
        if Selected then
          DeleteSelection
        else
          if FList.Count = 0 then
            Col := Col - 1
          else
          begin
            if HitSelected then
              CleanSelection;
            R := FRow;
            C := FCol;
            Attr := StrToAttributes(ListStr(R));
            // FCol が指す文字インデックス（０ベース）
            Si := C - IncludeCharCount(Attr, caTabSpace, C + 1);
            if Si > 0 then
            begin
              // 行頭ではない
              S := ListStr(R);
              L := Length(S);

              (*

                バックスペースアンインデント

                // 条件

                キャレット位置が行頭でない場合
                Caret.BackSpaceUnIndent が True で、該当行が

                ・'' か、
                ・半角空白、全角空白、タブ文字だけで構成されているか、
                ・上記空白の後に続く文字列の先頭にキャレットが居る

                場合に、現在のキャレット位置よりも小さい行頭空白数を
                持つ行を該当行から遡って探し、その位置までアンイン
                デントする。

                // 動作の定義

                該当行の文字列が、行頭から新しいキャレット位置までの
                文字列と現在のキャレット位置から終端までの文字列に
                置き換わる。

                該当行文字列長が新しいキャレット位置以下の場合は
                キャレットが移動するだけとする。

                新しいキャレット位置が
                ・タブ文字中の場合はそのタブ文字を半角空白に置き換える
                ・全角空白の２バイト目の場合は半角空白に置き換える

              *)

              Ts := TabbedTopSpace(S); // S = '' の場合 Ts = -1
              if FCaret.FBackSpaceUnIndent and
                 ((Ts = -1) or              // S = ''
                  (Ts = Length(Attr)) or    // 空白だけの行（１０００文字以上の空白の後に非空白文字がある場合も処理対象になる仕様）
                  (Ts = C)) then            // 空白に続く文字列の先頭
              begin
                // 新しいキャレット位置を取得
                Rs := FList.RowStart(R);
                Ri := R;
                // 折り返し標示されている行 Rs + 1..R の中にある
                // 0 でない C より小さい空白数か
                // Rs を含む上の行にある 0 を含む C より小さい
                // 空白数を探す
                repeat
                  Dec(Ri);
                  Pts := Max(0, TabbedTopSpace(ListStr(Ri))); // -1 が返る場合もあるので Max(0,
                until (Ri <= 0) or
                      ((Rs < Ri) and (Pts <> 0) and (Pts < C)) or // exclude 0
                      ((Ri <= Rs) and (Pts < C));                 // include 0
                if Pts >= C then
                  // C より小さい空白数が見つからなかった場合は０
                  Pts := 0;
                if Pts >= Length(Attr) then
                  // キャレットの移動のみ
                  Col := Pts
                else
                begin
                  // 文字列を更新
                  // 新しいキャレット位置より前の文字列を取得
                  I := Pts;
                  J := 0;
                  // 新しいキャレット位置に該当する文字インデックス（０ベース）
                  Bsi := I - IncludeCharCount(Attr, caTabSpace, I + 1);
                  if IndexChar(Attr, I + 1) = caDBCS2 then
                  begin
                    // 全角空白２バイト目の処理
                    Dec(Bsi);
                    Inc(J);
                  end
                  else
                    // タブが展開された部分の処理
                    while IndexChar(Attr, I + 1) = caTabSpace do
                    begin
                      Dec(I);
                      Inc(J);
                    end;
                  Buf := Copy(S, 1, Bsi) + StringOfChar(#$20, J);

                  // 現在のキャレット位置から終端までの文字列を追加
                  J := 0;
                  if IndexChar(Attr, C + 1) = caTabSpace then
                  begin
                    // タブが展開された部分の処理
                    Inc(Si);
                    while IndexChar(Attr, C + 1) = caTabSpace do
                    begin
                      Inc(C);
                      Inc(J);
                    end;
                  end;
                  Buf := Buf + StringOfChar(#$20, J) +
                         Copy(S, Si + 1, Length(S));
                  // put
                  FList.CheckCrlf(R, Buf);
                  CaretBeginUpdate;
                  try
                    FList.UpdateList(R, 1, Buf);
                    Col := Pts;
                  finally
                    CaretEndUpdate;
                  end;
                end;
              end
              else
                if Si <= L then
                begin
                  // 文字列内か文字列の終端
                  if IndexChar(Attr, C) = caDBCS2 then
                    Dc := 2 // delete count
                  else
                  begin
                    Dc := 1;
                    // Caret.InTab = True でタブ文字中に FCol が居る場合は
                    // Si + 1 がタブ文字を指しているのでそのタブ文字を
                    // 削除するように Si をひとつ進める
                    if IndexChar(Attr, C + 1) = caTabSpace then
                      Inc(Si);
                    while IndexChar(Attr, C) = caTabSpace do
                      Dec(C);
                  end;
                  // キャレット位置を補正
                  Dec(C, Dc);
                  Rs := Max(FList.RowStart(R), R - 1);
                  SelIndex := GetSelIndex(Rs, R, C);
                  // １行文字列から削除
                  Delete(S, Si + 1 - Dc, Dc);
                  // put
                  FList.CheckCrlf(R, S);
                  CaretBeginUpdate;
                  try
                    FList.UpdateList(R, 1, S);
                    // キャレットを設定
                    SetSelIndex(Rs, SelIndex);
                  finally
                    CaretEndUpdate;
                  end;
                end
                else
                  // 文字列の終端よりも右側
                  Col := Col - 1;
            end
            else
              // 行頭にキャレットがあるので、現在行を引き連れて
              // １行上の最後尾へ移動
              if R > 0 then
              begin
                // 新しいキャレット位置
                Rs := Max(FList.RowStart(R - 1), R - 2);
                S := ListStr(R - 1);
                Attr := StrToAttributes(S);
                C := Length(Attr);
                if FList.Rows[R - 1] = raWrapped then
                begin
                  if IndexChar(Attr, C) = caDBCS2 then
                    Dec(C)
                  else
                    while IndexChar(Attr, C) = caTabSpace do
                      Dec(C);
                  Dec(C);
                  Si := C - IncludeCharCount(Attr, caTabSpace, C + 1);
                end
                else
                  // raCrlf
                  Si := Length(S);
                SelIndex := GetSelIndex(Rs, R - 1, C);
                S := Copy(FList[R - 1], 1, Si);
                CaretBeginUpdate;
                UnderlineBeginUpdate;
                try
                  if R > FList.Count - 1 then
                    FList.UpdateList(R - 1, 1, S)
                  else
                  begin
                    S := S + FList[R];
                    FList.CheckCrlf(R, S);
                    FList.UpdateList(R - 1, 2, S);
                  end;
                  SetSelIndex(Rs, SelIndex);
                finally
                  UnderlineEndUpdate;
                  CaretEndUpdate;
                end;
              end;
          end;
      end;
    VK_TAB:
      begin
        Shift := KeyDataToShiftState(Message.KeyData);
        if (ssShift in Shift) or (ssCtrl in Shift) then
          Exit;
        if FReadOnly then
          Exit;
        if FWantTabs then
        begin
          if not WordWrap then
            ExpandTabCount := T - FCol mod T
          else
          begin
            I := FList.FWrapOption.FWrapByte;
            ExpandTabCount := Min(T - FCol mod T,
                                  I - FCol mod I);
          end;
          if FOverWrite then
            Col := Col + ExpandTabCount
          else
            if FCaret.FSoftTab then
              PutStringToLine(StringOfChar(#$20, ExpandTabCount))
            else
              PutStringToLine(#$09);
        end;
      end;
    VK_RETURN:
      begin
        if FReadOnly then
          Exit;
        Shift := KeyDataToShiftState(Message.KeyData);
        if Selected then
          if not (ssShift in Shift) then
            DeleteSelection
          else
            Exit;
        if HitSelected then
          CleanSelection;
        if FList.Count - 1 < FRow then
        begin
          // FRow is out of FList
          CaretBeginUpdate;
          UnderlineBeginUpdate;
          try
            FList.UpdateList(FList.Count, 0, #13#10);
            Row := FRow + 1;
            Col := 0;
          finally
            UnderlineEndUpdate;
            CaretEndUpdate;
          end;
        end
        else
        begin
          // FRow is on FList
          if FOverWrite then
          begin
            Row := FRow + 1;
            Col := 0;
          end
          else
          begin
            S := ListStr(FRow);
            L := Length(S);
            Attr := StrToAttributes(S);
            Si := FCol - IncludeCharCount(Attr, caTabSpace, FCol + 1);
            Rs := FList.RowStart(FRow);
            // TabbedTopSpace を取得するので Min(RowStart(FRow), FRow - 1)
            // ではない
            // リターンキーによる通常のキャレット位置
            C := 0;
            // オートインデント時のキャレット位置
            if FCaret.FAutoIndent then
            begin
              // 行頭の空白を取得
              I := TabbedTopSpace(ListStr(Rs));
              if I > 0 then
                // キャレット位置と、空白数の小さい方
                if (FRow = Rs) and (FCol < I) then
                  C := FCol
                else
                  C := I
              else
                if FCaret.FPrevSpaceIndent and (Rs = FRow) and (S = '') then
                  // 現在行が空白の場合は上方のインデント位置を取得
                  C := Max(0, PrevTopSpace(Rs)); // -1 が返る場合もある
            end;
            if ssShift in Shift then
            begin
              // インデントされた新しい行を挿入
              if not FCaret.FTabIndent then
              begin
                Buf := StringOfChar(#$20, C) + #13#10;
                SelIndex := C;
              end
              else
              begin
                Buf := StringOfChar(#$09, C div T) +
                       StringOfChar(#$20, C mod T) + #13#10;
                SelIndex := C div T + C mod T;
              end;
              CaretBeginUpdate;
              UnderlineBeginUpdate;
              try
                FList.UpdateList(Rs, 0, Buf);
                SetSelIndex(Rs, SelIndex);
              finally
                UnderlineEndUpdate;
                CaretEndUpdate;
              end;
            end
            else
            begin
              // 普通のリターン入力
              Buf := Copy(S, 1, Si) + #13#10;
              if not FCaret.FTabIndent then
              begin
                Buf := Buf + StringOfChar(#$20, C) + Copy(S, Si + 1, L);
                SelIndex := GetSelIndex(Rs, FRow, Min(Length(Attr), FCol)) + 2 + C;
              end
              else
              begin
                Buf := Buf +
                       StringOfChar(#$09, C div T) +
                       StringOfChar(#$20, C - (C div T) * T) +
                       Copy(S, Si + 1, L);
                SelIndex := GetSelIndex(Rs, FRow, Min(Length(Attr), FCol)) + 2 + C div T + C mod T;
              end;
              FList.CheckCrlf(FRow, Buf);
              CaretBeginUpdate;
              UnderlineBeginUpdate;
              try
                FList.UpdateList(FRow, 1, Buf);
                SetSelIndex(Rs, SelIndex);
              finally
                UnderlineEndUpdate;
                CaretEndUpdate;
              end;
            end;
          end;
        end;
      end;
  else // case
    (*
      VK_BACK, VK_TAB, VK_RETURN 以外の CharCode の処理
      半角文字は #$20..#$7E, #$A0..#$FF を処理する。Chr(CharCode) が
      LeadBytes の場合は、メッセージキューから次の WM_CHAR を取り込ん
      で、２バイト文字として処理するという TMemo 完全互換仕様である。
      これによって、WM_IME_CHAR メッセージにも対応出来るようになった。

      しかし、制御コードを含む WM_IME_CHAR をポストされた場合、
      PutStringToLine メソッド以下の処理においては、そのデータが真正な
      文字列であることを前提としているので、リストエラーなどの不具合が
      生じる場合がある。PeekMessage する際には、それが $40..$FF である
      かどうかを判別している。
        SendMessage(Editor1.Handle, WM_IME_CHAR, $820D, 0);
        SendMessage(Editor1.Handle, WM_CHAR, $8F, 0);
      などを実行すると「盾」の文字 ($8F82) が入力された後「改行される」
      ところが TMemo とは違っている。詳細は #WM_IME_COMPOSITION コメント
      を参照のこと。

      WM_IME_COMPOSITION メッセージハンドラで設定された FImeCount をデク
      リメントする処理も行われている。
      IME から [#$20..#$7E, #$A0..#$FF], LeadBytes 以外の文字を入力する
      ことは出来ないという前提で FImeCount をデクリメントしている。
    *)
    if Message.CharCode in [$20..$7E, $A0..$FF] then
    begin
      // １バイト文字
      if FImeCount > 0 then
        Dec(FImeCount)
      else
        if not FReadOnly then
        begin
          // IME Window の位置設定確認
          if FCompositionCanceled then
            SetImeComposition;
          PutStringToLine(Chr(Message.CharCode));
        end;
    end
    else
    begin
      // ２バイト文字
      CH := Chr(Message.CharCode);
      if (CH in LeadBytes) and
         PeekMessage(M, Handle, 0, 0, PM_NOREMOVE) and
         (M.Message = WM_CHAR) and
         (M.wParam in [$40..$FF]) and
         PeekMessage(M, Handle, 0, 0, PM_REMOVE) then
      begin
        if FImeCount > 0 then
          Dec(FImeCount, 2)
        else
          if not FReadOnly then
          begin
            CL := Chr(M.wParam);
            PutStringToLine(CH + CL);
          end;
      end;
    end;
  end; // case
end;

procedure TEditor.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTCHARS or DLGC_WANTARROWS;
  if FWantTabs then
    Message.Result := Message.Result or DLGC_WANTTAB
  else
    Message.Result := Message.Result and not DLGC_WANTTAB;
  if FWantReturns then
    Message.Result := Message.Result or DLGC_WANTALLKEYS
  else
    Message.Result := Message.Result and not DLGC_WANTALLKEYS;
end;

procedure TEditor.WMGetText(var Message: TMessage);
var
  P: PChar;
begin
  with Message do
  begin
    P := PChar(Lines.Text);
    Result := StrLen(StrLCopy(PChar(LParam), P, WParam - 1));
  end;
end;

procedure TEditor.WMGETTextLength(var Message: TMessage);
begin
  Message.Result := GetTextLen;
end;

procedure TEditor.WMHScroll(var Message: TWMHScroll);
var
  HScrollInc: Integer;
begin
  case Message.ScrollCode of
    SB_LINELEFT  : HScrollInc := -1;
    SB_LINERIGHT : HScrollInc := 1;
   {#HScroll
    スクロールボタンによる横スクロール量を画面の４分の１とする場合は
    以下の通り
    SB_LINELEFT  : HScrollInc := Min(-1, (FColCount div 4) * -1);
    SB_LINERIGHT : HScrollInc := Max(1, FColCount div 4);}
    SB_PAGELEFT  : HScrollInc := Min(-1, FColCount * -1);
    SB_PAGERIGHT : HScrollInc := Max(1, FColCount);
    SB_THUMBPOSITION,
    SB_THUMBTRACK: HScrollInc := Message.Pos - FTopCol;
    SB_LEFT      : HScrollInc := FTopCol * -1;
    SB_RIGHT     : HScrollInc := FHScrollMax + FColCount div 2 - FTopCol;
    else Exit;
  end;
  HScrollInc :=
    Max(FTopCol * -1,                              // SB_LEFT
    Min(HScrollInc,                                // SB_LINELEFT..SB_THUMBTRACK
        FHScrollMax + FColCount div 2 - FTopCol)); // SB_RIGHT
  if HScrollInc <> 0 then
    TopCol := TopCol + HScrollInc;
  Message.Result := 0;
end;

(*
  WM_IME のやって来る順番
  1. WM_IME_STARTCOMPOSITION
  2. WM_IME_NOTIFY ( IMN_OPENCANDIDATE )
  3. WM_IME_COMPOSITION ( GCS_RESULTSTR )
  4. WM_IME_ENDCOMPOSITION
  5. WM_IME_NOTIFY ( IMN_CLOSECANDIDATE )

  が

  MSIME95 を使用して、全角スペースを入力すると
  WM_IME_STARTCOMPOSITION は来ていないけど、
  WM_IME_ENDCOMPOSITION だけがしっかりやってくる現象が
  あるため、ver 0.61 で実装した WMImeStartComposition,
  WMImeEndComposition メッセージハンドラを ver 0.63 では
  削除した
*)

(*
  #WM_IME_COMOISITION 
  
  IME からの入力処理について 2002/05/31

  IME での入力が確定した時点で TEditor は WM_IME_COMPOSITION メッセージ
  を受け取る。WM_IME_COMPOSITION メッセージハンドラでは、IME から確定文
  字列を取得し、PutStringToLine メソッドを通して文字列を更新している。
  
  また、WM_IME_COMPOSITION メッセージは、メッセージハンドラ内で 
  inherited; を実行した時に、Windows による処理も行われる。
  
  この時、Windows は確定文字列の文字数分の WM_IME_CHAR メッセージをウイ
  ンドプロシージャに送りつけて来る。WM_IME_CHAR メッセージは Windows に
  よって、全角文字は２個の、半角文字は１個の WM_CHAR メッセージに変換さ
  れ、今度は、メッセージキューに溜められる。
  
  例えば、'あいうえお' と IME から入力された場合、（ ' は除く）TEditor 
  は WM_IME_COMPOSITION を受け取り 'あいうえお' を処理する。処理中に 
  inherited; を実行した時点で、５個の WM_IME_CHAR を受け取る。（TEditor 
  は WM_IME_CHAR メッセージを処理することはしないが、後述する）その後、
  処理が一段落した時点でメッセージキューを見に行くと１０個の WM_CHAR が
  溜まっているという流れになる。
  
  この溜まっている１０個の WM_CHAR は無視しなければならないので、
  TEditor では、WM_IME_COMPOSITION メッセージハンドラ内で、文字列長を
  記憶しておき、WM_CHAR メッセージハンドラ内で、記憶した値分の WM_CHAR
  メッセージを無視する方式を取っている。FImeCount がそのための変数。
  
  さて、拙作 TKeyMacro コンポに対応することと、ユーザーが WM_IME_CHAR,
  WM_CHAR メッセージを TEditor に SendMessage する場合について考える。
  
  Windows 標準コントロールの TMemo, TEdit などでは、例えば
  SendMessage(Memo1.Handle, WM_IME_CHAR, $82A0, 0);
  とすることで、'あ' を表示させることが出来るが、これは Windows によっ
  て WM_IME_CHAR -> ２個の WM_CHAR という変換が行われた後、WM_CHAR メッ
  セージハンドラで処理されているのではないか思われる。以下の実験で実証
  出来ると思う。
  PostMessage(Memo1.Handle, WM_CHAR, $A0, 0); // ２バイト目をキューに溜める
  SendMessage(Memo1.Handle, WM_CHAR, $82, 0); // １バイト目を処理させる
  つまり、上記標準コントロールの WM_CHAR メッセージハンドラでは、
  全角１バイト目を受け取った時、メッセージキューに溜まっているであろう
  ２バイト目をキューから取り出して全角１文字として処理していると思われ
  る。
  
  TEditor でも、この方式を採用している。WM_CHAR メッセージハンドラで全
  角１バイト目を受け取った場合、メッセージキューから次の２バイト目を取
  り出して処理している。こうすることで、WM_IME_CHAR メッセージの処理を
  キャンセルしている。
  
*)

procedure TEditor.WMImeComposition(var Msg: TMessage);
var
  Imc: HIMC;
  L: Integer;
  S: String;
begin
  inherited;
  // WM_IME_CHAR メッセージが発行され、IME 文字列長分の WM_CHAR が
  // Windows の DefWindowsProc によってポストされる。
  if (Msg.LParam and GCS_RESULTSTR <> 0) and not FReadOnly then
  begin
    Imc := ImmGetContext(Handle);
    L := ImmGetCompositionString(Imc, GCS_RESULTSTR, nil, 0);
    SetLength(S, L + 1);
    ImmGetCompositionString(Imc, GCS_RESULTSTR, PChar(S), L + 1);
    ImmReleaseContext(Handle, Imc);
    SetLength(S, L);
    FImeCount := L;
    PutStringToLine(S);
  end;
end;

procedure TEditor.WMImeNotify(var Msg: TMessage);
begin
  inherited;
  if Msg.WParam = IMN_OPENCANDIDATE then
    CaretBeginUpdate
  else
    if Msg.WParam = IMN_CLOSECANDIDATE then
      CaretEndUpdate;
end;

procedure TEditor.WMKeyDown(var Message: TWMKeyDown);
var
  Shift: TShiftState;
  Dc, Rs, L, Si, R, C, IncRow, SelIndex: Integer;
  Buf, S, Attr: String;
  Selecting: Boolean;
begin
  inherited;
  Message.Result := 0;
  FKeyRepeat := Message.KeyData and $40000000 <> 0;
  Shift := KeyDataToShiftState(Message.KeyData);
  Selecting := ssShift in Shift;
  if Message.CharCode in [VK_PRIOR..VK_DOWN] then
    if not Selected and Selecting then
      InitSelection
    else
      if (Selected and not Selecting) or HitSelected then
        CleanSelection;
  case Message.CharCode of
    VK_PRIOR:
      begin
        if FKeyRepeat then
          PageVScroll((FRowCount - 1) div 2 * FSpeed.FPageVerticalRangeAc * -1)
        else
          PageVScroll((FRowCount - 1) div 2 * FSpeed.FPageVerticalRange * -1);
        if Selecting then SetSelection;
      end;
    VK_NEXT:
      begin
        if FKeyRepeat then
          PageVScroll((FRowCount - 1) div 2 * FSpeed.FPageVerticalRangeAc)
        else
          PageVScroll((FRowCount - 1) div 2 * FSpeed.FPageVerticalRange);
        if Selecting then SetSelection;
      end;
    VK_END:
      begin
        if ssCtrl in Shift then
          Row := FList.Count; // cf SetRow
        if FRow = FList.Count then
          Col := 0
        else
          Col := ExpandListLength(FRow); // cf SetCol & AdjustCol
        if Selecting then SetSelection;
      end;
    VK_HOME:
      begin
        if ssCtrl in Shift then
          Row := 0;
        Col := 0;
        if Selecting then SetSelection;
      end;
    VK_LEFT:
      begin
        if ssCtrl in Shift then
        begin
          R := FRow;
          C := FCol;
          if FindNextWordStart(R, C, -1) then
            SetRowCol(R, C)
        end
        else
          if FCol > 0 then
            Col := Col - 1
          else
            if (FRow > 0) and
               (FCaret.FNextLine or (FList.Rows[FRow - 1] = raWrapped)) then
            begin
              CaretBeginUpdate;
              try
                SetRowCol(FRow - 1, ExpandListLength(FRow - 1));
              finally
                CaretEndUpdate;
              end;
            end;
        if Selecting then SetSelection;
      end;
    VK_UP:
      begin
        if FRow > 0 then
        begin
          if FKeyRepeat and (FRow = FTopRow) then
            IncRow := FSpeed.FCaretVerticalAc
          else
            IncRow := 1;
          if ssCtrl in Shift then
          begin
            TopRow := TopRow - IncRow;
            if FTopRow + FRowCount <= FRow then
              Row := Row - IncRow;
          end
          else
            Row := Row - IncRow;
        end;
        if Selecting then SetSelection;
      end;
    VK_RIGHT:
      begin
        if ssCtrl in Shift then
        begin
          R := FRow;
          C := FCol;
          if FindNextWordStart(R, C, 1) then
            SetRowCol(R, C)
        end
        else
        begin
          // debug とりあえず移動して見て動いていなければ cf AdjustCol
          C := FCol;
          Col := Col + 1;
          if (FCol = C) and (FRow < FList.Count) and
             (FList.Rows[FRow] <> raEof) and
             (FCaret.FNextLine or (FList.Rows[FRow] = raWrapped)) then
          begin
            // 一行下へ移動するのが見えるので
            CaretBeginUpdate;
            try
              SetRowCol(FRow + 1, 0);
            finally
              CaretEndUpdate;
            end;
          end;
        end;
        if Selecting then SetSelection;
      end;
    VK_DOWN:
      begin
        if FKeyRepeat and (FRow = FTopRow + FRowCount - 1) then
          IncRow := FSpeed.FCaretVerticalAc
        else
          IncRow := 1;
        if ssCtrl in Shift then
        begin
          TopRow := TopRow + IncRow;
          if FRow < FTopRow then
            Row := Row + IncRow;
        end
        else
          if ListRows(FRow) <> raEof then
            Row := Row + IncRow;
        if Selecting then SetSelection;
      end;
    VK_DELETE:
      begin
        if FReadOnly then
          Exit;
        if Selected then
          DeleteSelection
        else
        begin
          if HitSelected then
            CleanSelection;
          if (FRow < 0) or (FRow > FList.Count - 1) then
            Exit;
          // キャレットが FList に乗っているときだけ処理する
          R := FRow;
          C := FCol;
          S := FList[R];
          L := Length(S);
          Attr := StrToAttributes(S);
          Si := C - IncludeCharCount(Attr, caTabSpace, C + 1);
          if Si < L then
          begin
            // キャレットが文字列内にある場合の処理
            if IndexChar(Attr, C + 1) = caDBCS1 then
              Dc := 2
            else
            begin
              Dc := 1;
              // Caret.InTab = True でタブ文字中に FCol が居る場合の
              // キャレット位置調節
              while IndexChar(Attr, C + 1) = caTabSpace do
                Dec(C);
            end;
            Rs := Max(FList.RowStart(R), R - 1);
            SelIndex := GetSelIndex(Rs, R, C);
            // １行文字列から削除
            Delete(S, Si + 1, Dc);
            // put
            FList.CheckCrlf(R, S);
            CaretBeginUpdate;
            try
              FList.UpdateList(R, 1, S);
              // caret
              SetSelIndex(Rs, SelIndex);
            finally
              CaretEndUpdate;
            end;
          end
          else
          begin
            // キャレットが文字列の最後尾か、空白中にある場合の処理
            // raEof or raCrlf な行末でしかあり得ない cf. AdjustCol
            if FList.Rows[R] = raEof then
              Exit;
            // 以下は raCrlf な行末以降での処理
            Rs := Max(FList.RowStart(R), R - 1);
            SelIndex := GetSelIndex(Rs, R, C);
            Buf := FList[R] + StringOfChar(#$20, Si - L);
            CaretBeginUpdate;
            UnderlineBeginUpdate;
            try
              if R = FList.Count - 1 then
                FList.UpdateList(R, 1, Buf)
              else
              begin
                Buf := Buf + FList[R + 1];
                FList.CheckCrlf(R + 1, Buf);
                FList.UpdateList(R, 2, Buf);
              end;
              SetSelIndex(Rs, SelIndex);
            finally
              UnderlineEndUpdate;
              CaretEndUpdate;
            end;
          end;
        end;
      end;
    else
      Exit;
  end;
end;

procedure TEditor.WMKeyUp(var Message: TWMKeyUp);
begin
  inherited;
  // キーリピート状態が解除されるので、SetImeComposition する
  FKeyRepeat := False;
  if FCompositionCanceled then
    SetImeComposition;
  Message.Result := 0;
end;

procedure TEditor.WMKillFocus(var Msg: TWMKillFocus);
begin
  inherited;
  CaretHide;
  DestroyCaret;
  Msg.Result := 0;
end;

procedure TEditor.WMLButtonDown(var Message: TWMLButtonDown);
var
  R, C, L: Integer;
begin
  if ssShift in KeyDataToShiftState(Message.Keys) then
  begin
    if not Selected then
      // キャレットを移動する前の状態で選択領域データを初期化する
      InitSelection;
    // キャレット位置取得・移動・選択状態へ移行または再入
    PosToRowCol(Message.XPos, Message.YPos, R, C, True);
    SetRowCol(R, C);
    SetSelection;
  end
  else
  begin
    L := LeftMargin;
    // 選択領域の開始位置になるかもしれないポイントを取得
    FMouseSelStartPos.X := Message.XPos;
    FMouseSelStartPos.Y := Message.YPos;
    // ドラッグの判別
    PosToRowCol(Message.XPos, Message.YPos, R, C, False);
    if CanSelDrag and (L <= Message.XPos) and IsSelectedArea(R, C) then
    begin
      // 選択領域内にキャレットを移動
      SetRowCol(R, C);
      if FCaret.FSelDragMode = dmAutomatic then
      begin
        // WM_LBUTTONUP を発行して、csLButtonDown を ControlState から
        // 取り除き、MouseCapture プロパティを解除する
        Perform(WM_LBUTTONUP, 0, Longint(PointToSmallPoint(Point(Message.xpos, message.ypos))));
        // フラグ設定
        InitSelDrag;
      end;
    end
    else
    begin
      // キャレット位置取得
      PosToRowCol(Message.XPos, Message.YPos, R, C, True);
      // レフトマージン内での１行選択
      if (Message.XPos < L) and FCaret.FRowSelect then
        StartRowSelection(R)
      else
      begin
        CaretBeginUpdate;
        try
          // キャレットを移動して、選択領域データを初期化
          SetRowCol(R, C);
          InitSelection;
        finally
          CaretEndUpdate;
        end;
      end;
    end;
  end;
  inherited; // Windows.SetFocus cf DefaultHandler
end;

procedure TEditor.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  if SelDragging then
    // 選択文字列移動処理の終了
    // 処理直後 WM_MOUSEMOVE が発生し、そこでカーソルが戻る
    EndSelDrag
  else
    if FSelDragState = sdInit then
      // 選択領域内で左ボタンを押し下げて、ドラッグせずにボタンを離した
      // 場合の処理
      CancelSelDrag
    else
      if FRowSelecting then
        FRowSelecting := False;
end;

procedure TEditor.WMMouseMove(var Message: TWMMouseMove);
var
  Threshold: Integer;
  R, C: Integer;
begin
  if csLButtonDown in ControlState then
  begin
    // キャレット移動して選択領域を更新
    PosToRowCol(Message.XPos, Message.YPos, R, C, True);
    // 上方向へのスクロールに対応
    if Message.YPos < TopMargin then
      R := Max(0, R - 1);
    if FRowSelecting then
      UpdateRowSelection(R)
    else
    begin
      SetRowCol(R, C);
      if Selected then
        UpdateSelection
      else
      begin
        // WM_LBUTTONDOWN でセットした FMouseSelStartPos
        // から Threshold ピクセル以上移動していたら選択状態へ移行する
        Threshold := FFontWidth div 2;
        if (Abs(FMouseSelStartPos.X - Message.XPos) >= Threshold) or
           (Abs(FMouseSelStartPos.Y - Message.YPos) >= Threshold) then
          StartSelection
      end;
    end;
  end
  else
    if FSelDragState = sdInit then
    begin
      // ドラッグ初期化済みの場合は移動量を判別してドラッグを開始する
      Threshold := FFontWidth div 2;
      if (Abs(FMouseSelStartPos.X - Message.XPos) >= Threshold) or
         (Abs(FMouseSelStartPos.Y - Message.YPos) >= Threshold) then
        StartSelDrag;
    end
    else
      if SelDragging then
      begin
        // 選択領域移動中はキャレット移動だけ
        PosToRowCol(Message.XPos, Message.YPos, R, C, False);
        // 上方向へのスクロールに対応
        if Message.YPos < TopMargin then
          R := Max(0, R - 1);
        SetRowCol(R, C);
      end
      else
        // CursorState の更新。
        if Message.XPos < LeftMargin then
          // レフトマージン内
          CursorState := mcLeftMargin
        else
          if Message.YPos < TopMargin then
            CursorState := mcTopMargin
          else
            if CanSelDrag then
            begin
              PosToRowCol(Message.XPos, Message.YPos, R, C, True);
              if IsSelectedArea(R, C) then
                // 選択領域内
                CursorState := mcInSel
              else
                CursorState := mcClient
            end
            else
              CursorState := mcClient;
  inherited;
end;

procedure TEditor.WMSetFocus(var Msg: TWMSetFocus);
begin
  inherited;
  RecreateCaret;
  // ScrollCaret; no operate
  MoveCaret;
  CaretShow;
  Msg.Result := 0;
end;

procedure TEditor.WMSetText(var Message: TMessage);
var
  P: PChar;
begin
  with Message do
    if not ReadOnly then
    begin
      P := StrNew(PChar(LParam));
      Lines.Text := String(P);
      StrDispose(P);
      {$IFDEF COMP4_UP} // exclude D2..D3
      SendDockNotification(Msg, WParam, LParam);
      {$ENDIF}
    end;
end;

procedure TEditor.WMSize(var Msg: TWMSize);
begin
  inherited;
  InitView;
  Msg.Result := 0;
end;

procedure TEditor.WMVScroll(var Message: TWMVScroll);
var
  VScrollInc: Integer;
  Info: TScrollInfo;
begin
  case Message.ScrollCode of
    SB_LINEUP    : VScrollInc := -1;
    SB_LINEDOWN  : VScrollInc := 1;
    SB_PAGEUP    : VScrollInc := Min(-1, FRowCount * -1);
    SB_PAGEDOWN  : VScrollInc := Max(1, FRowCount);
    { SB_THUMBxxx では１６ビット値しか扱えない}
    SB_THUMBPOSITION,
    SB_THUMBTRACK: begin
                     Info.cbSize := SizeOf(TScrollInfo);
                     Info.fMask := SIF_ALL;
                     GetScrollInfo(Handle, SB_VERT, Info);
                     VScrollInc := Info.nTrackPos - FTopRow;
                   end;
    SB_TOP       : VScrollInc := FTopRow * -1;
    SB_BOTTOM    : VScrollInc := FVScrollMax - FTopRow;
    else Exit;
  end;
  VScrollInc :=
    Max(FTopRow * -1,            // SB_TOP
    Min(VScrollInc,              // SB_LINEUP..SB_THUMBTRACK
        FVScrollMax - FTopRow)); // SB_BOTTOM

  { $VScrollMax ... [EOF] が画面上端に行ってしまわないようにする場合}
  // if (VScrollInc > 0) and (FVScrollMax - FTopRow < FRowCount ) then
  //   VScrollInc := 0;

  if VScrollInc <> 0 then
  begin
    TopRow := TopRow + VScrollInc;
    if FCaret.FLockScroll then
      Row := Row + VScrollInc;
  end;
  Message.Result := 0;
end;


// スクロール ///////////////////////////////////////////////////////

(*
  #Scroll

  スクロールは、SetTopRow, SetTopCol に集約され、そこで FTopRow,
FTopCol が設定されている。WMVScroll, WMHScroll メッセージハンドラ
では、スクロールバーによるスクロールや、ユーザーのメッセージ発行に
よるスクロールに対応して TopRow, TopCol 値を変化させている

スクロール領域の設定では、Rect を設定してを渡すと Windows によって
キャレット位置が調節されてしまい、FCol のあるべき場所とずれてしまう
ので、nil を渡して画面全体をスクロールさせ ClipRect にその領域を
設定して渡すこと
*)

procedure TEditor.DoScroll(X, Y: Integer; Rect, ClipRect: PRect);
(*
  ScrollWindowEx API を呼び出して無効領域を再描画する
  FLeftScrollWidth がここで設定される
*)
var
  R: TRect;
begin
  if not HandleAllocated then
    Exit;
  UnderlineBeginUpdate;
  try
    if Rect <> nil then
      UpdateWindow(Handle);
    Dec(FLeftScrollWidth, X);
    ScrollWindowEx(Handle, X, Y, Rect, ClipRect, 0, @R, SW_SCROLLCHILDREN);
    InvalidateRect(Handle, @R, False);
    UpdateWindow(Handle);
  finally
    UnderlineEndUpdate;
  end;
end;

procedure TEditor.InitScroll;
var
  V: Integer;
  Info: TScrollInfo;
begin
  if not HandleAllocated then
    Exit;

  // 保持される文字列の行数から、縦スクロールの最大値を取得
  FVScrollMax := Max(0, FList.Count + FRowCount - 1);

  { $VScrollMax ... [EOF] が画面上端に行ってしまわないようにする場合}
  // FVScrollMax := Max(0, FList.Count);

  FTopRow := Min(FTopRow, FVScrollMax);
  // 横スクロールは固定
  FHScrollMax := MaxLineCharacter;
  FTopCol := Min(FTopCol, FHScrollMax - FColCount div 2);
  // FLeftScrollWidth の調節
  FLeftScrollWidth := FTopCol * FFontWidth;
  if FScrollBars in [ssVertical, ssBoth] then
  begin
    // 縦スクロールバーを常に表示するために
    V := Max(FRowCount, FVScrollMax);
    Info.cbSize := SizeOf(Info);
    Info.fMask := SIF_ALL;
    Info.nMin := 0;
    Info.nMax := V;
    Info.nPage := FRowCount;
    Info.nPos := FTopRow;
    Info.nTrackPos := 0;
    SetScrollInfo(Handle, SB_VERT, Info, True);
  end;
  if FScrollBars in [ssHorizontal, ssBoth] then
  begin
    Info.cbSize := SizeOf(Info);
    Info.fMask := SIF_ALL;
    Info.nMin := 0;
    Info.nMax := FHScrollMax + FColCount div 2;
    Info.nPage := FColCount;
    Info.nPos := FTopCol;
    Info.nTrackPos := 0;
    SetScrollInfo(Handle, SB_HORZ, Info, True);
  end;
end;

procedure TEditor.ImagebarScroll(Line, Count: Integer);
(*
  TEditorScreen.Update のヘルパーメソッドとして利用されている。
  Imagebar 内部で Line で指定された行から、Bottom までのクリップを作成し
  クリップ内の全領域を Count で指定された行数分スクロールする
  Count に負の値を指定した場合は上へスクロールされる
  DoScroll メソッドで UpdateWindow される
*)
var
  C: TRect;
  H, V: Integer;
begin
  // スクロール開始行は、画面内に納める
  Line := Min(Max(FTopRow, Line), FTopRow + FRowCount);
  H := GetRowHeight;
  // クリップの作成
  C := Rect(
         0,
         TopMargin + H * (Line - FTopRow),
         FImagebarWidth,
         Height
       );
  // 画面高さ以上のスクロールは意味がない。また単純に
  // (FFontHeight + FMargin.FUnderline + FMargin.FLine) * Count では、
  // Count の値によっては Integer の許容範囲を超える場合もあるので
  V := Max(Min(Count, FRowCount + 1), (FRowCount + 1) * -1) * H;
  DoScroll(0, V, nil, @C);
end;

procedure TEditor.LineScroll(Line, Count: Integer);
(*
  TEditorScreen.Update のヘルパーメソッドとして利用されている。
  Line で指定された行から、Bottom までのクリップを作成し
  クリップ内の全領域を Count で指定された行数分スクロールする
  Count に負の値を指定した場合は上へスクロールされる
  DoScroll メソッドで UpdateWindow される
  行番号部分はスクロールしない
*)
var
  C: TRect;
  H, V: Integer;
begin
  // スクロール開始行は、画面内に納める
  Line := Min(Max(FTopRow, Line), FTopRow + FRowCount);
  CaretBeginUpdate;
  UnderlineBeginUpdate; // 縦スクロールのお約束
  try
    H := GetRowHeight;
    // クリップの作成
    C := Rect(
           LeftMargin,
           TopMargin + H * (Line - FTopRow),
           Width,
           Height
         );
    // 画面高さ以上のスクロールは意味がない。また単純に
    // (FFontHeight + FMargin.FUnderline + FMargin.FLine) * Count では、
    // Count の値によっては Integer の許容範囲を超える場合もあるので
    V := Max(Min(Count, FRowCount + 1), (FRowCount + 1) * -1) * H;
    DoScroll(0, V, nil, @C);
  finally
    UnderlineEndUpdate;
    CaretEndUpdate;
  end;
end;

procedure TEditor.PageVScroll(Value: Integer);
var
  R: Integer;
begin
  // TopRow 又は [EOF] にキャレットが行き着くまではスクロールする
  if (TopRow = 0) and (Value < 0) then
  begin
    Row := 0;
    Exit;
  end
  else
    if (ListRows(FTopRow) = raEof) and (Value > 0) then
      Exit;
  // キャレット位置は変化させずに Value で指定された行数を縦スクロールする
  // 画面上でのキャレット位置を保存
  R := FRow - FTopRow;
  CaretBeginUpdate;
  try
    // スクロール
    TopRow := Max(0, Min(FTopRow + Value, FList.Count));
    // キャレットを調節
    Row := FTopRow + R;
  finally
    CaretEndUpdate;
  end;
end;

// キャレット  //////////////////////////////////////////////////////
(*
  キャレットのオン・オフは、CareShow, CaretHide メソッドを通して行い、
  マージン内や、ClientRect 外でキャレットが表示されない仕様とする。
*)

procedure TEditor.AdjustCol(RowChanged: Boolean; Direction: Integer);
(*
  キャレット位置 FCol を補正する

  １．not FreeCaret and not FreeRow 状態で文字列長を越えたところ
  ２．全角２バイト目
  ３．not InTab でタブ文字の中
  ４．WordWrap で文字列長以上のところ
  ５．１，０００文字目対策

  補正する時は、FColBuf に現在の FCol を保存し FColKeeping フラグを
  セットする。

  呼び出し方
  SetRow -> AdjustCol(True, -1);
  SetCol -> AdjustCol(False, Direction);

*)
var
  L: Integer;
  Attr: String;

  procedure KeepCol(Value: Integer);
  begin
    if RowChanged and not FColKeeping then
    begin
      FColBuf := Value;
      FColKeeping := True;
    end;
  end;

begin
  // 現在行の文字属性を取得
  Attr := StrToAttributes(ListStr(FRow));
  L := Length(Attr);

  // 同一行内での Col の変更が発生した時点で、フラグはクリアされる
  // FColKeeping := RowChanged; ではないことに注意
  if not RowChanged then
    FColKeeping := False
  else
    // 保存されている場合は復帰してから以下の判別による補正を行う
    if FColKeeping then
      FCol := FColBuf;

  // not FreeCaret で文字列長を越えたところ
  if not FCaret.FFreeCaret and (L < FCol) then
  begin
    if FCaret.FKeepCaret then
      if csLButtonDown in ControlState then
        // マウスによるキャレット移動の場合は文字列長とする
        KeepCol(L)
      else
        KeepCol(FCol);
    if not FCaret.FFreeRow or not RowChanged or (csLButtonDown in ControlState) then
    begin
      FCol := L;
      if not FCaret.FKeepCaret then
        // 保持していた補正をクリアする。
        // 文字列後端なので、以下の判別で KeepCol されることはない。
        FColKeeping := False;
    end;
  end;

  // 全角２バイト目
  if IndexChar(Attr, FCol + 1) = caDBCS2 then
  begin
    KeepCol(FCol);
    Inc(FCol, Direction);
  end;

  // not InTab でタブ文字の中
  if not FCaret.FInTab and (IndexChar(Attr, FCol + 1) = caTabSpace) then
  begin
    KeepCol(FCol);
    while IndexChar(Attr, FCol + 1) = caTabSpace do
      Inc(FCol, Direction);
  end;

  // WordWrap で文字列長以上のところ
  if WordWrap and (FCol >= L) then
  begin
    KeepCol(FCol);
    if ListRows(FRow) = raWrapped then
      FCol := L - 1
    else
      if FCol >= FList.FWrapOption.FWrapByte then
        FCol := Max(L, FList.FWrapOption.FWrapByte - 1);
    if IndexChar(Attr, FCol + 1) = caDBCS2 then
      Dec(FCol);
    if not FCaret.FInTab and (IndexChar(Attr, FCol + 1) = caTabSpace) then
      while IndexChar(Attr, FCol + 1) = caTabSpace do
        Dec(FCol);
  end;

  // １，０００文字目が全角１バイト目の場合は、１，００１文字目の後ろまで
  // 移動出来る仕様とする。
  // cf SetCol, FDxArray, DrawTextRect, PaintLine, PaintLineSelected

  // 上の「全角２バイト目」の処理によって FCol が 1002 の場合もあるので
  // Dec(FCol) ではなく、MaxLineCharacter を代入している。

  if (FCol > MaxLineCharacter) and
     (IndexChar(Attr, MaxLineCharacter) <> caDBCS1) then
    FCol := MaxLineCharacter;

  // キャレットを移動
  if not FCaretNoMove then
    UpdateCaret;
end;

procedure TEditor.CaretHide;
begin
  if HandleAllocated and Focused and FCaretShowing then
  begin
    FCaretShowing := False;
    HideCaret(Handle);
  end;
end;

procedure TEditor.CaretShow;
begin
  if (FCaretUpdateCount = 0) and HandleAllocated and Focused and
     not FCaretShowing and not IsCaretNoClient then
  begin
    FCaretShowing := True;
    ShowCaret(Handle);
  end;
end;

function TEditor.FindNextWordStart(var R, C: Integer; Direction: Integer): Boolean;
(*
  Caret.TokenEndStop プロパティが False の場合
  現在の桁番号、行番号（共に０ベース）、方向を指定して次の語句の先頭の行番号
  桁番号を取得する。成功すると True を返す

  Caret.TokenEndStop プロパティが True の場合
  現在の桁番号、行番号（共に０ベース）、方向を指定して
  ・現在の語句の最後・現在の語句の先頭・次の語句の先頭・前の語句の最後
  のいずれかの行番号桁番号を取得する。成功すると True を返す
*)
var
  S: String;
  Rb, Cb, I: Integer;
  Parser: TFountainParser;
  Data: TRowAttributeData;
begin
  // R, C は行番号、桁番号を受け取るので、０ベース
  Result := False;
  if (R < 0) or (R > FList.Count) or
     ((R = FList.Count) and (ListRows(R) = raEof)) then
    Exit;
  Rb := R;
  Cb := C;
  FillChar(Data, SizeOf(Data), 0);
  Data.BracketIndex := InvalidBracketIndex; // -2
  try
    if Direction = 1 then
    begin
      // 前方検索
      if (ExpandListLength(R) <= C) and (R < FList.Count) then
      begin
        // 行末の場合は次の行の先頭から検索
        Inc(R);
        C := -1;
      end;
      S := ExpandListStr(R);
      Parser := ActiveFountain.ParserClass.Create(ActiveFountain);
      try
        Parser.NewData(S, Data);
        while Parser.NextToken <> toEof do
          if Caret.TokenEndStop then
          begin
            if Parser.SourcePos > C then
            begin
              C := Parser.SourcePos;
              Exit;
            end
            else
              if Parser.SourcePos + Parser.TokenLength > C then
              begin
                C := Parser.SourcePos + Parser.TokenLength;
                Exit;
              end;
          end
          else
          begin
            if (Parser.Token <> toSymbol) and (Parser.SourcePos > C) then
            begin
              C := Parser.SourcePos;
              Exit;
            end;
          end;
      finally
        Parser.Free;
      end;
      // R 上に無い場合
      if ListRows(R) = raWrapped then
      begin
        // raWrapped ならば次の行の先頭に移動して終了（手抜き）
        Inc(R);
        C := 0;
      end
      else
        // 行末に移動して終了
        C := Length(S);
    end
    else
    begin
      // 後方検索
      if C = 0 then
      begin
        // 行頭の場合は、１行上の行末に移動してそこが raCrlf ならば終了
        if 0 < R then
        begin
          Dec(R);
          C := ExpandListLength(R);
          if ListRows(R) = raCrlf then
            Exit;
        end
        else
          Exit;
      end;
      S := ExpandListStr(R);
      I := -1;
      Parser := ActiveFountain.ParserClass.Create(ActiveFountain);
      try
        Parser.NewData(S, Data);
        while Parser.NextToken <> toEof do
          if Caret.TokenEndStop then
          begin
            if (Parser.SourcePos < C) and (Parser.SourcePos + Parser.TokenLength >= C) then
            begin
              // トークンの途中か最後にキャレットが居る場合
              C := Parser.SourcePos;
              Exit;
            end
            else
              if (Parser.SourcePos >= C) and (I <> -1) and (I < C) then
              begin
                // トークンの先頭と前のトークンの間にキャレットが居る場合
                C := I;
                Exit;
              end;
            I := Parser.SourcePos + Parser.TokenLength;
          end
          else
          begin
            if (Parser.Token <> toSymbol) and (Parser.SourcePos >= C) and
               (I <> -1) and (I < C) then
            begin
              C := I;
              Exit;
            end;
            if Parser.Token <> toSymbol then
              I := Parser.SourcePos;
          end;
      finally
        Parser.Free;
      end;
      // 行末以降にキャレットが居るか、
      // キャレット位置より前にトークンが無い場合
      if (I <> -1) and (I < C) then
        // 最後の有効なトークンへ移動
        C := I
      else
        // キャレット位置より前にトークンが無い場合１行上へ
        if 0 < R then
        begin
          Dec(R);
          C := ExpandListLength(R);
        end
        else
          // ０行目の場合は先頭
          C := 0;
    end;
  finally
    Result := (Rb <> R) or (Cb <> C);
  end;
end;

function TEditor.GetSelIndex(StartRow, ARow, ACol: Integer): Integer;
(*
  ARow, ACol で指定されたキャレット位置の StartRow から始まる文字
  インデックス (0 base) を返す。
*)
var
  I, L: Integer;
  Attr: String;
begin
  Result := 0;
  for I := StartRow to ARow do
    if I < ARow then
    begin
      if FList.Rows[I] = raCrlf then
        L := Length(FList[I]) + 2
      else
        if FList.Rows[I] = raEof then
          L := Length(FList[I]) + 1
        else
          L := Length(FList[I]);
      Inc(Result, L);
    end
    else
    begin
      Attr := StrToAttributes(ListStr(I));
      Inc(Result, ACol - IncludeCharCount(Attr, caTabSpace, ACol + 1));
    end;
end;

function TEditor.IsCaretNoClient: Boolean;
begin
  Result := (FRow < FTopRow) or (FTopRow + FRowCount < FRow) or
            (FCol < FTopCol) or (FTopCol + FColCount < FCol);
end;

procedure TEditor.MoveCaret;
(*
  現在の FRow, FCol へキャレットを移動する
*)
var
  X, Y: Integer;
begin
  if not HandleAllocated or not Focused then
    Exit;
  // 表示位置を取得
  SetCaretPosition(X, Y);
  // キャレットを移動
  SetCaretPos(X, Y);
  // IME ウィンドゥを移動
  if FKeyRepeat then
    FCompositionCanceled := True
  else
    SetImeComposition;
  // OnCaretMoved イベント
  DoCaretMoved;
end;

procedure TEditor.PosToRowCol(XPos, YPos: Integer;
  var ARow, ACol: Integer; Split: Boolean);
(*
  X, Y で指定された位置の Row, Col 値を ARow, ACol へ格納する。
  Split に True が渡された場合は文字間のキャレット位置を
  False の場合は文字前のキャレット位置を返す。
  実際にそこへキャレットが移動出来るかどうかの判別は行っていない。
*)
var
  L: Integer;
begin
  L := LeftMargin;
  if XPos < L then
    Dec(XPos, FFontWidth - 1);
  if Split then
    ACol := Max(0, FTopCol + (XPos + FFontWidth div 2 - 1 - L) div FFontWidth)
  else
    ACol := Max(0, FTopCol + (XPos - L) div FFontWidth);
  ARow := FTopRow + (YPos - TopMargin) div GetRowHeight;
end;

function TEditor.PrevTopSpace(ARow: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  I := FList.RowStart(ARow) - 1;
  while I >= 0 do
  begin
    if (I = 0) or (ListRows(I - 1) = raCrlf) then
    begin
      Result := TabbedTopSpace(ListStr(I));
      if Result <> -1 then
        Exit;
    end;
    Dec(I);
  end;
end;

procedure TEditor.RecreateCaret;
var
  X, Y, W: Integer;
  Attr: String;
begin
  if not HandleAllocated or not Focused then
    Exit;
  Attr := StrToAttributes(ListStr(FRow));
  W := FFontWidth - FMargin.FCharacter;
  if FOverWrite then
  begin
    if IndexChar(Attr, FCol + 1) = caDBCS1 then
      X := W * 2
    else
      X := W;
    Y := FFontHeight;
  end
  else
    if FCaret.FStyle = csDefault then
    begin
      X := DefaultCaretWidth;
      Y := FFontHeight;
    end
    else
    begin
      if IndexChar(Attr, FCol + 1) = caDBCS1 then
        X := W * 2
      else
        X := W;
      Y := BriefCaretHeight;
    end;
  CaretHide;
  DestroyCaret;
  CreateCaret(Handle, 0, X, Y);
end;

procedure TEditor.ScrollCaret;
(*
  現在の Row, Col 位置を画面上に表示するために必要があれば
  画面スクロールを行う
*)
begin
  if not HandleAllocated or not Focused then
    Exit;
  // 縦スクロール
  // 画面上端に消えそうな時は、表示１行目を FRow にする
  if FRow < FTopRow then
    TopRow := FRow
  else
    // 画面下端に消えそうな時は、表示最下行を FRow にする
    if FTopRow + FRowCount - 1 < FRow then
      TopRow := FRow - (FRowCount - 1);
  // 横スクロール
  // スクロール量は画面幅の４分の１とする
  // 画面左端に消えそうな時
  if FCol < FTopCol then
    TopCol := Max(0, Min(FCol, FTopCol - (FColCount div 4)))
  else
    // 画面右端に消えそうな時
    if FTopCol + FColCount - 1 < FCol then
      TopCol := Min(
                Max(FCol - (FColCount - 1), FTopCol + (FColCount div 4)),
                FHScrollMax - FColCount div 2);
end;

procedure TEditor.SetCaretPosition(var X, Y: Integer);
begin
  X := LeftMargin + FFontWidth * (FCol - FTopCol);
  if FCaret.FStyle = csDefault then
    Y := TopMargin + (FRow - FTopRow) * GetRowHeight
  else
    if FOverWrite then
      Y := TopMargin + GetRowHeight * (FRow - FTopRow)
    else
      Y := FFontHeight + GetRowHeight * (FRow - FTopRow) +
           TopMargin - BriefCaretHeight;
end;

procedure TEditor.SetImeComposition;
var
  X, Y: Integer;
begin
  X := LeftMargin + (FCol - FTopCol) * FFontWidth;
  Y := TopMargin +
       (FRow - FTopRow) * GetRowHeight;
  SetImeCompositionWindow(Font, X, Y);
  FCompositionCanceled := False;
end;

procedure TEditor.SetRowCol(ARow, ACol: Integer);
(*
  ARow, ACol で指定された位置へ Row, Col を設定する。
  実際に設定される位置は、SetRow, SetCol, AdjustCol によって決まる
  Row が設定された時点で現在の Col 位置にキャレットを移動
  しようとする仕様なので、それをキャンセルするフラグを用意して
  指定された Row, Col へ一気にキャレットを移動するためのメソッド
  マウスによる選択処理中に全角文字やタブ文字中を移動する際キャレットが
  ちらつくので、それへの対応が必要
*)
var
  S, Attr: String;
begin
  if (FRow = ARow) and (FCol = ACol) then
    Exit;
  FCaretNoMove := True;
  try
    Row := ARow;
    S := ListStr(FRow);
    Attr := StrToAttributes(S);
    // 全角２バイト目の処理
    if IndexChar(Attr, ACol + 1) = caDBCS2 then
      Dec(ACol);
    // タブの処理
    if not FCaret.FInTab and
       (IndexChar(Attr, ACol + 1) = caTabSpace) then
      while IndexChar(Attr, ACol + 1) = caTabSpace do
        Dec(ACol);
    Col := ACol;
  finally
    // フラグをクリア
    FCaretNoMove := False;
    // 自前で移動
    UpdateCaret;
  end;
end;

procedure TEditor.SetSelIndex(StartRow, SelIndex: Integer);
(*
  FList の StartRow から文字数をカウントし、SelIndex を越えそうな
  Row に対して Col をセットする
*)
var
  Count, I, R, L, C: Integer;
begin
  I := SelIndex;
  R := StartRow;
  Count := FList.Count;
  while R <= Count - 1 do
  begin
    if FList.Rows[R] = raCrlf then
      L := Length(FList[R]) + 2
    else
      if FList.Rows[R] = raEof then
        L := Length(FList[R]) + 1
      else
        L := Length(FList[R]);
    if (I >= L) and (FList.Rows[R] <> raEof) then
      Dec(I, L)
    else
    begin
      Row := R;
      C := ExpandTabLength(Copy(FList[FRow], 1, I));
      Col := Min(C, ExpandListLength(FRow));
      Exit;
    end;
    Inc(R);
  end;
  // [EOF] 以降
  Row := R;
  Col := ExpandListLength(FRow);
end;

procedure TEditor.UpdateCaret;
begin
  RecreateCaret; // HandleAllocated & Focused
  ScrollCaret;   // HandleAllocated & Focused
  MoveCaret;     // HandleAllocated & Focused
  CaretShow;     // HandleAllocated & Focused & others
end;


// 描画 /////////////////////////////////////////////////////////////

(*
  #Drawing

  DrawTextRect メソッドが総ての描画を行い、レフトマージンの実現と文字
  間隔を調節するために ExtTextOut を使用している。
  InvalidateRow, DoScroll で行われる InvalidateRect, ScrollWindowEx では
  発生する無効領域を塗りつぶさない仕様
    InvalidateRect(Handle, @R, False);
    ScrollWindowEx(Handle, X, Y, Rect, ClipRect, 0, @R, SW_SCROLLCHILDREN);
  なので、DrawTextRect する前に、描画領域を FillRect するか ETO_OPAQUE
  を渡す必要がある。

  文字列を描画する領域について
  １行の高さ RowHeight は FFontHeight + FMargin.FUnderline + FMargin.FLine
  となっている。行間部分は描画しない。

  非選択状態での描画
  アンダーライン部分がちらつかないように FFontHeight の領域に描画する。
  選択状態での描画
  アンダーライン部分も塗りつぶす必要があるので（というか、そうしないと
  Margin.Line = 0 で Underline = True な場合、１ドット分の縞模様が選択
  領域に出るので美しくない）FFontHeight + FMargin.FUnderline の領域に描画
  する。

  この FMargin.FUnderline の調節は、PaintRect 内で、１行分の領域に切り分
  ける際に行っている。

  描画手順

  非選択状態
    無効領域の発生
    Paint                 ... 無効領域の取得
    PaintRect             ... 領域を調節して１行文字高さに切り分けて
                              タブを展開した描画文字列・描画位置を取得後
                              PaintLine へ渡す
    PaintLine             ... 指定位置へ描画して OnDrawLine ハンドラを呼び出す

  選択状態
    無効領域の発生
    Paint                 ... 無効領域の取得
    PaintRect             ... 領域を調節して１行文字高さに切り分けて
                              タブを展開した描画文字列・描画位置を取得後
                              PaintRectSelected へ渡す
    PaintRectSelected     ... FSelDraw データを参照しながら
                              PaintLine, PaintLineSelected を使い分けて描画
    PaintLineSelected     ... 指定位置へ View.Colors.Select の色で描画して
                              OnDrawLine ハンドラを呼び出す

  選択領域の更新
    DrawSelection             SelectionMode に応じて DrawSelectionLine,
                              DrawSelectionBox を使い分ける。これらから
                              PaintLine, PaintLineSelected を使い分けて描画

  １，０００文字を越える文字列の扱いについて
  DrawTextRect では MaxLineCharacter を越える文字列を渡されると、それを
  MaxLineCharacter の長さに調節してから描画することで ExtTextOut API
  に渡される文字間隔の配列サイズ以上の文字列を描画することによるエラー
  を回避している。PaintLine, PaintLineSelected では、渡された無効領域を
  一旦塗りつぶした後で、MaxLineCharacter に対応した新しい領域を別に用意
  して、DrawTextRect に渡している。
*)

procedure TEditor.CaretBeginUpdate;
begin
  Inc(FCaretUpdateCount);
  if (FCaretUpdateCount = 1) and HandleAllocated and Focused then
    CaretHide;
end;

procedure TEditor.CaretEndUpdate;
begin
  if FCaretUpdateCount > 0 then // おぞい IME 対策
    Dec(FCaretUpdateCount);
  if (FCaretUpdateCount = 0) and HandleAllocated and Focused then
    CaretShow;
end;

procedure TEditor.DrawEof(X, Y: Integer);
var
  R: TRect;
  T, L: Integer;
begin
  if not Showing then
    Exit;
  T := TopMargin;
  L := LeftMargin;
  R := Rect(
         Min(Max(L, X), Width),
         Min(Max(T, Y), Height),
         Min(Max(L, X + FFontWidth * 6), Width),
         Min(Max(T, Y + FFontHeight), Height)
       );
  Canvas.Font.Assign(Font);
  Canvas.Brush.Color := Color;
  if FMarks.FEofMark.FColor = clNone then
    Canvas.Font.Color := Font.Color
  else
    Canvas.Font.Color := FMarks.FEofMark.FColor;
  CaretBeginUpdate;
  try
    DrawTextRect(R, X, Y, '[EOF]', ETO_CLIPPED or ETO_OPAQUE);
  finally
    CaretEndUpdate;
  end;
end;

procedure TEditor.DrawRetMark(X, Y: Integer);
var
  I, J, K: Integer;
begin
  if (X >= LeftMargin) and Showing then
  begin
    X := X + FFontWidth div 2;
    I := Max(1, FFontHeight div 8);
    J := Y + FFontHeight - I * 2;
    K := Max(I, 3);
    with Canvas do
    begin
      Pen.Style := psSolid;
      Pen.Width := 1;
      if FMarks.FRetMark.FColor = clNone then
        Pen.Color := Self.Font.Color
      else
        Pen.Color := FMarks.FRetMark.FColor;
      MoveTo(X, Y + I * 2);
      LineTo(X, J);
      LineTo(X + K, J - K);
      MoveTo(X, J);
      LineTo(X - K, J - K);
    end;
  end;
end;

procedure TEditor.DrawRetMarkSelected(X, Y: Integer);
var
  I, J, K: Integer;
  C: TColor;
begin
  if (X >= LeftMargin) and Showing then
  begin
    X := X + FFontWidth div 2;
    I := Max(1, FFontHeight div 8);
    J := Y + FFontHeight - I * 2;
    K := Max(I, 3);
    with Canvas do
    begin
      Pen.Style := psSolid;
      Pen.Width := 1;
      if HitSelected then
        C := FView.Colors.Hit.Color
      else
        C := FView.Colors.Select.Color;
      if C = clNone then
        C := Color;
      Pen.Color := C;
      MoveTo(X, Y + I * 2);
      LineTo(X, J);
      LineTo(X + K, J - K);
      MoveTo(X, J);
      LineTo(X - K, J - K);
    end;
  end;
end;

procedure TEditor.DrawWrapMark(X, Y: Integer);
var
  W: Integer;
begin
  if (X >= LeftMargin) and Showing then
  begin
    X := X + FFontWidth;
    Y := Y + FFontHeight div 2;
    W := Max(2, FFontWidth * 3 div 5);
    with Canvas do
    begin
      Pen.Style := psSolid;
      Pen.Width := 1;
      if FMarks.FWrapMark.FColor = clNone then
        Pen.Color := Self.Font.Color
      else
        Pen.Color := FMarks.FWrapMark.FColor;
      MoveTo(X, Y - W);
      LineTo(X - W, Y);
      LineTo(X + 1, Y + W + 1);
    end;
  end;
end;

procedure TEditor.DrawWrapMarkSelected(X, Y: Integer);
var
  W: Integer;
  C: TColor;
begin
  if (X >= LeftMargin) and Showing then
  begin
    X := X + FFontWidth;
    Y := Y + FFontHeight div 2;
    W := Max(2, FFontWidth * 3 div 5);
    with Canvas do
    begin
      Pen.Style := psSolid;
      Pen.Width := 1;
      if HitSelected then
        C := FView.Colors.Hit.Color
      else
        C := FView.Colors.Select.Color;
      if C = clNone then
        C := Color;
      Pen.Color := C;
      MoveTo(X, Y - W);
      LineTo(X - W, Y);
      LineTo(X + 1, Y + W + 1);
    end;
  end;
end;

procedure TEditor.DrawHideMark(X, Y: Integer);
var
  W: Integer;
begin
  if (X >= LeftMargin) and Showing then
  begin
    X := X + FFontWidth;
    Y := Y + FFontHeight div 2;
    W := Max(2, FFontWidth * 3 div 5);
    with Canvas do
    begin
      Pen.Style := psSolid;
      Pen.Width := 1;
      if FMarks.FHideMark.FColor = clNone then
        Pen.Color := Self.Font.Color
      else
        Pen.Color := FMarks.FHideMark.FColor;
      MoveTo(X - W, Y - W);
      LineTo(X, Y);
      LineTo(X - W - 1, Y + W + 1);
    end;
  end;
end;

procedure TEditor.DrawHideMarkSelected(X, Y: Integer);
var
  W: Integer;
  C: TColor;
begin
  if (X >= LeftMargin) and Showing then
  begin
    X := X + FFontWidth;
    Y := Y + FFontHeight div 2;
    W := Max(2, FFontWidth * 3 div 5);
    with Canvas do
    begin
      Pen.Style := psSolid;
      Pen.Width := 1;
      if HitSelected then
        C := FView.Colors.Hit.Color
      else
        C := FView.Colors.Select.Color;
      if C = clNone then
        C := Color;
      Pen.Color := C;
      MoveTo(X - W, Y - W);
      LineTo(X, Y);
      LineTo(X - W - 1, Y + W + 1);
    end;
  end;
end;

(*
  $DotUnderline
  fsUnderline を一点破線で描画しない場合は、下記 {$DEFINE DOT_UNDERLINE}
  を // でコメントアウトすること
*)

{$DEFINE DOT_UNDERLINE}

{$IFDEF DOT_UNDERLINE}

procedure TEditor.DrawTextRect(Rect: TRect; X, Y: Integer;
  const S: String; Options: Word);
var
  Buf: String;
  Underline: Boolean;
  L, SX, EX: Integer;
begin
  // S はタブ文字が展開された文字列
  if Showing then
  begin
    Underline := fsUnderline in Canvas.Font.Style;
    if Underline then
      Canvas.Font.Style := Canvas.Font.Style - [fsUnderline];
    if Length(S) > MaxLineCharacter then
    begin
      // １，０００文字を越える文字列
      if IsDBCS1(S, MaxLineCharacter) then
        Buf := Copy(S, 1, MaxLineCharacter + 1)
      else
        Buf := Copy(S, 1, MaxLineCharacter);
      Windows.ExtTextOut(Canvas.Handle, X, Y, Options, @Rect,
        PChar(Buf), Length(Buf), PInteger(@FDxArray));
      if Underline then
      begin
        L := Length(Buf) * FFontWidth;
        if (X < Rect.Right) and (Rect.Left < X + L) then
        begin
          // ETO_CLIPPED が指定されていなくても、Rect 内にクリップしている
          Y := Y + FFontHeight - 1;
          SX := Max(X, Rect.Left);
          EX := Min(X + L, Rect.Right);
          DrawDotLine(Canvas, SX, Y, EX, Canvas.Font.Color, Canvas.Brush.Color);
        end;
      end;
    end
    else
    begin
      Windows.ExtTextOut(Canvas.Handle, X, Y, Options, @Rect,
        PChar(S), Length(S), PInteger(@FDxArray));
      if Underline then
      begin
        L := Length(S) * FFontWidth;
        if (X < Rect.Right) and (Rect.Left < X + L) then
        begin
          // ETO_CLIPPED が指定されていなくても、Rect 内にクリップしている
          Y := Y + FFontHeight - 1;
          SX := Max(X, Rect.Left);
          EX := Min(X + L, Rect.Right);
          DrawDotLine(Canvas, SX, Y, EX, Canvas.Font.Color, Canvas.Brush.Color);
        end;
      end;
    end;
  end;
end;

{$ELSE}

procedure TEditor.DrawTextRect(Rect: TRect; X, Y: Integer;
  const S: String; Options: Word);
var
  Buf: String;
begin
  // S はタブ文字が展開された文字列
  if Showing then
  begin
    if Length(S) > MaxLineCharacter then
    begin
      // １，０００文字を越える文字列
      if IsDBCS1(S, MaxLineCharacter) then
        Buf := Copy(S, 1, MaxLineCharacter + 1)
      else
        Buf := Copy(S, 1, MaxLineCharacter);
      Windows.ExtTextOut(Canvas.Handle, X, Y, Options, @Rect,
        PChar(Buf), Length(Buf), PInteger(@FDxArray));
    end
    else
      Windows.ExtTextOut(Canvas.Handle, X, Y, Options, @Rect,
        PChar(S), Length(S), PInteger(@FDxArray));
  end;
end;

{$ENDIF}

procedure TEditor.DrawUnderline(ARow: Integer);
var
  Y: Integer;
begin
  if Showing then
  begin
    Y := UnderlinePos(ARow);
    if Y <> -1 then
    begin
      CaretBeginUpdate;
      try
        with Canvas do
        begin
          Pen.Style := psSolid;
          if FMarks.FUnderline.FColor = clNone then
            Pen.Color := Self.Font.Color
          else
            Pen.Color := FMarks.FUnderline.FColor;
          Pen.Width := 1;
          MoveTo(LeftMargin, Y);
          LineTo(Width, Y);
        end;
      finally
        CaretEndUpdate;
      end;
    end;
  end;
end;

procedure TEditor.HideUnderline(ARow: Integer);
var
  Y: Integer;
begin
  if Showing then
  begin
    Y := UnderlinePos(ARow);
    if Y <> -1 then
    begin
      CaretBeginUpdate;
      try
        with Canvas do
        begin
          Pen.Style := psSolid;
          Pen.Color := Color;
          Pen.Width := 1;
          MoveTo(LeftMargin, Y);
          LineTo(Width, Y);
        end;
      finally
        CaretEndUpdate;
      end;
    end;
  end;
end;

procedure TEditor.AdjustColCount;
(*
  表示桁数 FColCount を取得する
*)
var
  W: Integer;
begin
  if HandleAllocated then
  begin
    W := Width - LeftMargin - FFontWidth div 2;
    if FScrollBars in [ssVertical, ssBoth] then
      W := W - GetSystemMetrics(SM_CYVSCROLL);
    try
      FColCount := W div FFontWidth;
    except
      FColCount := 0;
    end;
  end;
end;

procedure TEditor.InitDrawInfo;
var
  TM: TTextMetric;
  I, H: Integer;
begin
  if not HandleAllocated then
    Exit;
  Canvas.Font.Assign(Font);
  GetTextMetrics(Canvas.Handle, TM);
  // FontHeight
  FFontHeight := TM.tmHeight + TM.tmExternalLeading;
  // ColWidth
  FFontWidth := TM.tmAveCharWidth + FMargin.FCharacter;
  // for DrawTextRect
  for I := 0 to MaxLineCharacter do // MaxLineCharacter + 1 個分
    FDxArray[I] := FFontWidth;
  // 表示行数
  H := Height - TopMargin - 5; // Brief キャレットのための微調整
  if FScrollBars in [ssHorizontal, ssBoth] then
    H := H - GetSystemMetrics(SM_CYHSCROLL);
  FRowCount := Max(1, H div GetRowHeight);
  // 表示桁数
  AdjustColCount;
  // fsItalic
  FItalicFontStyle := (fsItalic in Font.Style) or
                      ActiveFountain.HasItalicFontStyle(ActiveFountain);
  // FRulerHeight
  if FRuler.FVisible then
    AdjustRulerHeight;
  // FLeftbarColumn, FLeftbarWidth
  if FLeftbar.FVisible then
  begin
    AdjustLeftbarColumn;
    AdjustLeftbarWidth;
  end;
  // FImagebarWidth
  AdjustImagebarWidth;
end;

procedure TEditor.InitView;
begin
  InitDrawInfo;
  InitScroll;
  Invalidate;
end;

procedure TEditor.InvalidateLine(Index: Integer);
(*
  Index 行のアンダーライン部分を残して無効化する UpdateWindow は行わない
  TEditorScreenStrings.UpdateBrackets のヘルパーメソッドとして利用されて
  いる。行番号表示部分は無効化しない
*)
var
  H, T: Integer;
  R: TRect;
begin
  if not HandleAllocated then
    Exit;
  if (FTopRow <= Index) and (Index <= FTopRow + FRowCount) then
  begin
    H := GetRowHeight;
    T := TopMargin;
    R := Rect(
           LeftMargin,
           T + H * (Index - FTopRow),
           Width,
           T + H * (Index - FTopRow) + FFontHeight // アンダーライン部分を残す
         );
    InvalidateRect(Handle, @R, False);
  end;
end;

procedure TEditor.InvalidateRow(StartRow, EndRow: Integer);
(*
  EndRow 行のアンダーライン部分を残して、指定行間を行番号部分も
  含めて無効化し直ちに UpdateWindow する。FScreen.Update のヘルパー
  メソッドとして、文字列更新状況に応じた再描画を行うため、行番号
  部分も無効化している
*)
var
  Sr, Er, H, T: Integer;
  R: TRect;
begin
  if not HandleAllocated then
    Exit;
  Sr := Max(Min(StartRow, EndRow), FTopRow);
  Er := Min(Max(StartRow, EndRow), FTopRow + FRowCount);
  H := GetRowHeight;
  T := TopMargin;
  R := Rect(
         0, // 行番号表示部分も無効化
         T + H * (Sr - FTopRow),
         Width,
         T + H * (Er - FTopRow) + FFontHeight // アンダーライン部分を残す
       );
  InvalidateRect(Handle, @R, False);
  UpdateWindow(Handle);
end;

type
  TEditorColorStyle = record
    B, C: TColor;
    S: TFontStyles;
  end;

procedure TEditor.PaintLine(R: TRect; X, Y: Integer; S: String;
  Index: Integer; Parser: TFountainParser);
var
  bcs: TEditorColorStyle;
  Xp, L, SL, RightMax: Integer;
  EditorColor: TFountainColor;
  B, C: TColor;
  Style: TFontStyles;
  DR: TRect;
  Data: TRowAttributeData;
begin
  if not Showing then
    Exit;
  // Brackets プロパティの更新
  if FList.Brackets[Index] = InvalidBracketIndex then
    FList.UpdateBrackets(Index, False);
  // 領域 R を描画
  Canvas.Brush.Color := Color;
  if not FItalicFontStyle then
  begin
    // 領域を塗りつぶしながら、１行文字列を１度描画する
    Canvas.Font.Assign(Font);
    DrawTextRect(R, X, Y, S, ETO_CLIPPED or ETO_OPAQUE);
  end
  else
    // 領域を塗りつぶすだけ
    Canvas.FillRect(R);
  // 文字列長＋[EOF]マークが左に隠れている場合はキャンセル
  SL := Length(S);
  //if (SL + 5) * FFontWidth < FLeftScrollWidth then
  //  Exit;
  // １，０００文字目以降に描画しないようにするための処理
  RightMax := MaxLineCharacter * FFontWidth - FLeftScrollWidth + LeftMargin;
  DR := R;
  DR.Right := Min(DR.Right, RightMax);
  if SL > 0 then
  begin
    // init
    Data := ListData[Index];
    B := Color;
    C := Font.Color;
    Style := Font.Style;
    L := LeftMargin;
    // wrapped next one line
    if WordWrap and
       (Index < FList.Count - 1) and (FList.Rows[Index] = raWrapped) then
    begin
      S := S + FList[Index + 1];
      DR.Right := Min(DR.Right, X + SL * FFontWidth);
    end;
    Parser.NewData(S, Data);
    while Parser.NextToken <> toEof do
    begin
      // Index 行のトークンだけ描画する
      if Parser.SourcePos >= SL then
        Break;
      EditorColor := Parser.TokenToFountainColor;
      if EditorColor = nil then
      begin
        bcs.B := B;
        bcs.C := C;
        bcs.S := Style;
      end
      else
      begin
        if EditorColor.BkColor = clNone then
          bcs.B := B
        else
          bcs.B := EditorColor.BkColor;
        if EditorColor.Color = clNone then
          bcs.C := C
        else
          bcs.C := EditorColor.Color;
        bcs.S := EditorColor.Style;
      end;
      if not FItalicFontStyle then
      begin
        if  ((C <> bcs.C) or
            (B <> bcs.B) or
            (Style <> bcs.S)) then
        begin
          Xp := X + Parser.SourcePos * FFontWidth;
          if (L <= Xp + Parser.TokenLength * FFontWidth) and
             (Xp <= DR.Right) then
          begin
            // 見えているトークンだけ描画する
            Canvas.Brush.Color := bcs.B;
            Canvas.Brush.Style := bsSolid;
            Canvas.Font.Color := bcs.C;
            Canvas.Font.Style := bcs.S;
            DrawTextRect(DR, Xp, Y, Parser.TokenString, ETO_CLIPPED);
          end
          else
            if DR.Right < Xp then
              Break;
        end
      end
      else
      begin
        Xp := X + Parser.SourcePos * FFontWidth;
        if (L <= Xp + Parser.TokenLength * FFontWidth) and
           (Xp <= DR.Right) then
        begin
          // 見えているトークンだけ描画する
          Canvas.Font.Color := bcs.C;
          Canvas.Font.Style := bcs.S;
          if B <> bcs.B then
          begin
            Canvas.Brush.Style := bsSolid;
            Canvas.Brush.Color := bcs.B;
          end
          else
            Canvas.Brush.Style := bsClear;
          DrawTextRect(DR, Xp, Y, Parser.TokenString, ETO_CLIPPED);
        end
        else
          if DR.Right < Xp then
            Break;
      end;
    end;
  end;
  DoDrawLine(R, X, Y, S, Index, Boolean(Byte(sstNone)));
  // Marks
  if (SL > MaxLineCharacter) and IsDBCS1(S, MaxLineCharacter) then
    Xp := RightMax + FFontWidth
  else
    Xp := Min(X + SL * FFontWidth, RightMax);
  if Xp < R.Right then
    if (SL > MaxLineCharacter) and (Xp < X + SL * FFontWidth) then
    begin
      if FMarks.FHideMark.FVisible then
        DrawHideMark(Xp, Y);
    end
    else
      if FMarks.FEofMark.FVisible and (Index = FList.Count - 1) and
         (FList.Rows[Index] = raEof) then
        DrawEof(Xp, Y)
      else
        if FMarks.FRetMark.FVisible and (FList.Rows[Index] = raCrlf) then
          DrawRetMark(Xp, Y)
        else
          if FMarks.FWrapMark.FVisible and (FList.Rows[Index] = raWrapped) then
            DrawWrapMark(Xp, Y);
end;

procedure TEditor.PaintLineSelected(R: TRect; X, Y: Integer;
  S: String; Index: Integer; Parser: TFountainParser);
var
  Xp, L, SL, RightMax: Integer;
  EditorColor: TFountainColor;
  Style: TFontStyles;
  DR: TRect;
  Data: TRowAttributeData;
  B, C: TColor;
begin
  if not Showing then
    Exit;
  // Brackets プロパティの更新
  if FList.Brackets[Index] = InvalidBracketIndex then
    FList.UpdateBrackets(Index, False);
  if HitSelected then
    B := FView.Colors.Hit.BkColor
  else
    B := FView.Colors.Select.BkColor;
  if B = clNone then
    B := Font.Color;
  if HitSelected then
    C := FView.Colors.Hit.Color
  else
    C := FView.Colors.Select.Color;
  if C = clNone then
    C := Color;
  Canvas.Brush.Color := B;
  if not FItalicFontStyle then
  begin
    // 領域を塗りつぶしながら、１行文字列を１度描画する
    Canvas.Font.Assign(Font);
    Canvas.Font.Color := C;
    DrawTextRect(R, X, Y, S, ETO_CLIPPED or ETO_OPAQUE);
  end
  else
    // 領域を塗りつぶすだけ
    Canvas.FillRect(R);
  // 文字列長＋[EOF]マークが左に隠れている場合はキャンセル
  SL := Length(S);
  if (SL + 5) * FFontWidth < FLeftScrollWidth then
    Exit;
  // １，０００文字目以降に描画しないようにするための処理
  RightMax := MaxLineCharacter * FFontWidth - FLeftScrollWidth + LeftMargin;
  DR := R;
  DR.Right := Min(DR.Right, RightMax);
  if S <> '' then
  begin
    // init
    Data := ListData[Index];
    Style := Font.Style;
    L := LeftMargin;
    // wrapped next one line
    if WordWrap and
       (Index < FList.Count - 1) and (FList.Rows[Index] = raWrapped) then
    begin
      S := S + FList[Index + 1];
      DR.Right := Min(DR.Right, X + SL * FFontWidth);
    end;
    Parser.NewData(S, Data);
    while Parser.NextToken <> toEof do
    begin
      // Index 行のトークンだけ描画する
      if Parser.SourcePos >= SL then
        Break;
      EditorColor := Parser.TokenToFountainColor;
      if not FItalicFontStyle then
      begin
        if (EditorColor <> nil) and (Style <> EditorColor.Style) then
        begin
          Xp := X + Parser.SourcePos * FFontWidth;
          if (L <= Xp + Parser.TokenLength * FFontWidth) and
             (Xp <= DR.Right) then
          begin
            // 見えているトークンだけ描画する
            Canvas.Font.Style := EditorColor.Style;
            Canvas.Brush.Color := B;
            Canvas.Brush.Style := bsSolid;
            Canvas.Font.Color := C;
            DrawTextRect(DR, Xp, Y, Parser.TokenString, ETO_CLIPPED);
          end
          else
            if DR.Right < Xp then
              Break;
        end
      end
      else
      begin
        Xp := X + Parser.SourcePos * FFontWidth;
        if (L <= Xp + Parser.TokenLength * FFontWidth) and
           (Xp <= DR.Right) then
        begin
          // 見えているトークンだけ描画する
          if EditorColor = nil then
            Canvas.Font.Style := Style
          else
            Canvas.Font.Style := EditorColor.Style;
          Canvas.Font.Color := C;
          Canvas.Brush.Style := bsClear;
          DrawTextRect(DR, Xp, Y, Parser.TokenString, ETO_CLIPPED);
        end
        else
          if DR.Right < Xp then
            Break;
      end;
    end;
  end;
  DoDrawLine(R, X, Y, S, Index, Boolean(Byte(FSelectionState)));
  // Marks
  if (SL > MaxLineCharacter) and IsDBCS1(S, MaxLineCharacter) then
    Xp := RightMax + FFontWidth
  else
    Xp := Min(X + SL * FFontWidth, RightMax);
  if Xp < R.Right then
    if (SL > MaxLineCharacter) and (Xp < X + SL * FFontWidth) then
    begin
      if FMarks.FHideMark.FVisible then
        DrawHideMarkSelected(Xp, Y);
    end
    else
      if FMarks.FEofMark.FVisible and (Index = FList.Count - 1) and
         (FList.Rows[Index] = raEof) then
        DrawEof(Xp, Y)
      else
        if FMarks.FRetMark.FVisible and (FList.Rows[Index] = raCrlf) then
          DrawRetMarkSelected(Xp, Y)
        else
          if FMarks.FWrapMark.FVisible and (FList.Rows[Index] = raWrapped) then
            DrawWrapMarkSelected(Xp, Y);
end;

procedure TEditor.PaintRect(R: TRect);
(*
  受け取った領域を、レフトマージン、トップマージン、文字高に調節した後
  １行文字列の文字高に切り分けてからそこへ描画すべきタブを展開した文字
  列と、描画位置を取得して PaintLine 又は PaintRectSelected へ渡す
  領域の塗りつぶしは、描画する際に FillRect したり、DrawTextRect
  に ETOOPAQUE を渡すなどする
*)
var
  H, B, I, Sr, Er, LinesCount, X, T, L: Integer;
  S: String;
  D: TRect;
  OriginDraw, RulerDraw, ImagebarDraw, LeftbarDraw, LineDraw, UnderlineDraw: Boolean;
  Parser: TFountainParser;
begin
  if not Showing then
    Exit;
  T := TopMargin;
  L := LeftMargin;
  // FOriginBase draw ?
  OriginDraw := IntersectRect(D, R, Rect(0, 0, L, T));
  // Ruler draw ?
  RulerDraw :=
    FRuler.FVisible and IntersectRect(D, R, Rect(L, 0, Width, FRulerHeight)) ;
  // Imagebar draw ?
  ImagebarDraw :=
    FImagebar.FVisible and IntersectRect(D, R, Rect(0, T, FImagebarWidth, Height));
  // Leftbar draw ?
  LeftbarDraw :=
    FLeftbar.FVisible and IntersectRect(D, R, Rect(FImagebarWidth, T, FImagebarWidth + FLeftbarWidth, Height));
  // Line draw ?
  LineDraw :=
    IntersectRect(D, R, Rect(L, T, Width, Height));
  // Underline draw ?
  UnderlineDraw := FMarks.FUnderline.FVisible and
                   (FUnderlineUpdateCount = 0) and
                   (UnderlinePos(FRow) <> -1);
  // LeftMargin と文字位置への対応
  R.Left := Max(L, L + ((R.Left - L) div FFontWidth) * FFontWidth);
  // TopMargin への対応
  R.Top := Max(T, R.Top);
  // 文字高に合わせて上下に拡張する。
  H := GetRowHeight;
  R.Top := R.Top - (R.Top - T) mod H;
  B := (R.Bottom - T) mod H;
  if B > 0 then
    R.Bottom := R.Bottom + H - B;
  // 開始行（決して Sr < 0 にはならない）
  Sr := FTopRow + (R.Top - T) div H;
  // 終了行（FList.Count 以上になる場合もある）
  Er := Sr + (R.Bottom - R.Top) div H - 1;
  // ループ内で参照するので、変数として保持する
  LinesCount := FList.Count;
  // 描画開始位置（横スクロール状態ではマイナス値にもなる）
  X := L - FLeftScrollWidth;
  // １行分の Rect を用意して OffsetRect しながら描画を行う
  // 行間部分は描画しない。
  // アンダーライン部分は選択状態の時と、
  // 選択状態から非選択状態へ移行する時に描画する
  if SelectedData or FClearingSelection then
    R.Bottom := R.Top + FFontHeight + FMargin.FUnderline
  else
    R.Bottom := R.Top + FFontHeight;

  CaretBeginUpdate; // 描画前のお約束
  try
    if OriginDraw then
      Canvas.Draw(0, 0, FOriginBase);
    if RulerDraw then
      PaintRuler;
    if LeftbarDraw then
      PaintLeftbar(Sr, Er);
    if ImagebarDraw then
      PaintImagebar(Sr, Er);
    if LineDraw then
    begin
      Parser := ActiveFountain.ParserClass.Create(ActiveFountain);
      try
        for I := Sr to Er do
        begin
          if I < LinesCount then
          begin
            S := ExpandListStr(I);
            if SelectedDraw then
              PaintRectSelected(R, X, R.Top, S, I, Parser)
            else
              PaintLine(R, X, R.Top, S, I, Parser);
          end
          else
          begin
            // LinesCount 以降の塗りつぶし
            Canvas.Brush.Color := Color;
            Canvas.FillRect(R);
            if FMarks.FEofMark.FVisible and (I = LinesCount) and
               ((I = 0) or (ListRows(I - 1) <> raEof)) then
              DrawEof(X, R.Top);
          end;
          OffsetRect(R, 0, H);
        end;
      finally
        Parser.Free;
      end;
    end;
  finally
    CaretEndUpdate;
  end;
  if UnderlineDraw then
    DrawUnderline(FRow);
end;

procedure TEditor.PaintRectSelected(R: TRect; X, Y: Integer; S: String;
  Index: Integer; Parser: TFountainParser);
(*
  選択領域を保持した状態で、WM_PAINT メッセージを受け取った場合の処理
  FSelDraw データと X, Y, Index を比較し、非選択領域は PaintLine で、
  選択領域は PaintLineSelected を使って描画する。
  S には、タブを展開した文字列が渡される
*)
var
  DRect, SRect: TRect;
  L: Integer;
begin
  L := LeftMargin;
  with FSelDraw do
  begin
    // 選択領域外は普通に描画
    if (Index < Sr) or (Er < Index) then
      PaintLine(R, X, Y, S, Index, Parser)
    else
      if FSelectionMode = smLine then
        // ノーマル選択状態
        // １行選択状態
        if Sr = Er then
        begin
          // 選択領域の左側を描画
          SRect :=
            Rect(
              L,
              R.Top,
              Max(L, L + (Sc - FTopCol) * FFontWidth),
              R.Bottom
            );
          if IntersectRect(DRect, R, SRect) then
            PaintLine(DRect, X, Y, S, Index, Parser);
          // 選択領域を描画
          SRect :=
            Rect(
              Max(L, L + (Sc - FTopCol) * FFontWidth),
              R.Top,
              Max(L, L + (Ec - FTopCol) * FFontWidth),
              R.Bottom
            );
          if IntersectRect(DRect, R, SRect) then
            PaintLineSelected(DRect, X, Y, S, Index, Parser);

          // 選択領域の右側を描画
          SRect :=
            Rect(
              Max(L, L + (Ec - FTopCol) * FFontWidth),
              R.Top,
              Width,
              R.Bottom
            );
          if IntersectRect(DRect, R, SRect) then
            PaintLine(DRect, X, Y, S, Index, Parser);
        end
        else
          // 複数行選択状態

          // １行目
          if Index = Sr then
          begin
            // 選択領域の左側を描画
            SRect :=
              Rect(
                L,
                R.Top,
                Max(L, L + (Sc - FTopCol) * FFontWidth),
                R.Bottom
              );
            if IntersectRect(DRect, R, SRect) then
              PaintLine(DRect, X, Y, S, Index, Parser);
            // 選択領域を描画
            SRect :=
              Rect(
                Max(L, L + (Sc - FTopCol) * FFontWidth),
                R.Top,
                Width,
                R.Bottom
              );
            if IntersectRect(DRect, R, SRect) then
              PaintLineSelected(DRect, X, Y, S, Index, Parser);
          end
          else
            // 最後の行
            if Index = Er then
            begin
              // 選択領域を描画
              SRect :=
                Rect(
                  L,
                  R.Top,
                  Max(L, L + (Ec - FTopCol) * FFontWidth),
                  R.Bottom
                );
              if IntersectRect(DRect, R, SRect) then
                PaintLineSelected(DRect, X, Y, S, Index, Parser);
              // 選択領域の右側を描画
              SRect :=
                Rect(
                  Max(L, L + (Ec - FTopCol) * FFontWidth),
                  R.Top,
                  Width,
                  R.Bottom
                );
              if IntersectRect(DRect, R, SRect) then
                PaintLine(DRect, X, Y, S, Index, Parser);
            end
            else
              // 途中の行
              PaintLineSelected(R, X, Y, S, Index, Parser)
      else
      begin
        // 矩形選択状態
        // 選択領域の左側を描画
        SRect := BoxSelRect(S, Index, 0, Sc);
        if IntersectRect(DRect, R, SRect) then
          PaintLine(DRect, X, Y, S, Index, Parser);
        // 選択領域を描画
        SRect := BoxSelRect(S, Index, Sc, Ec);
        if IntersectRect(DRect, R, SRect) then
          PaintLineSelected(DRect, X, Y, S, Index, Parser);
        // 選択領域の右側を描画
        SRect := BoxSelRect(S, Index, Ec, Ec + FColCount);
        SRect.Right := Width; // 味噌
        if IntersectRect(DRect, R, SRect) then
          PaintLine(DRect, X, Y, S, Index, Parser);
      end;
  end;
end;

procedure TEditor.UnderlineBeginUpdate;
begin
  Inc(FUnderlineUpdateCount);
  if (FUnderlineUpdateCount = 1) and FMarks.FUnderline.FVisible and
     not SelectedData then
    HideUnderline(FRow);
end;

procedure TEditor.UnderlineEndUpdate;
begin
  Dec(FUnderlineUpdateCount);
  if (FUnderlineUpdateCount = 0) and FMarks.FUnderline.FVisible and
     not SelectedData then
    DrawUnderline(FRow);
end;

function TEditor.UnderlinePos(ARow: Integer): Integer;
var
  Y, T: Integer;
begin
  Result := -1;
  T := TopMargin;
  Y := T + (ARow - FTopRow) * GetRowHeight + FFontHeight;
  // 領域内にだけ描画
  if (T < Y) and (Y <= Height) then
    Result := Y;
end;

function TEditor.TopMargin: Integer;
begin
  Result := FMargin.FTop;
  if FRuler.FVisible then
    Inc(Result, FRulerHeight);
end;

// 選択領域 /////////////////////////////////////////////////////////

(*

#Selection

FSelectionState
  sstNone        非選択状態
  sstInit        選択領域データが初期化された状態 ( = 選択状態への鍵を取得した状態）
  sstSelected    選択状態
  sstHitSelected ヒット文字列を表現している状態
  
InitSelection    -> sstInit
                 選択領域データを初期化する
SetSelection     FSelectionState の状態に応じて StartSelection,
                 UpdateSelection を呼び出す
StartSelection   -> sstSelected 又は -> sstHitSelected
                 アンダーライン消去して UpdateSelection を呼び出す
UpdateSelection  選択領域データを更新して描画、
                 FOnSelectionChange イベント呼び出し
CleanSelection   -> sstNone
                 選択領域をノーマル描画してアンダーラインを復活させる
                 FOnSelectionChange 呼び出し
DeleteSelection  選択領域の文字列を削除し、CleanSelection を呼び出す

*)

procedure TEditor.HitToSelected;
(*
  sstHitSelected 状態を sstSelected とする。
  HitStyle が hsDraw, hsCaret の時に置き換え処理を行う時のためのメソッド。
*)
begin
  if HitSelected then
  begin
    if FHitStyle = hsCaret then
      SetRowCol(FSelDraw.Er, FSelDraw.Ec);
    FSelectionState := sstSelected;
  end;
end;

function TEditor.BoxSelRect(const S: String; Index, StartCol,
  EndCol: Integer): TRect;
(*
  矩形選択状態で、FList[Index] のタブを展開した文字列 S を選択・非選択
  領域として描画する際の領域を BoxLeftIndex, BoxRightIndex の仕様に
  従って返す。

  返す領域は文字列が描画される領域内だけとする。

  Paint からも利用されるので、再描画の後で設定される FTopCol は使用しない。
  矩形選択領域より右側を描画する場合は、返値の Right を Width にすること。
*)
var
  I, L, T, R, B, LM: Integer;
begin
  StartCol := Min(StartCol, Length(S));
  EndCol := Min(EndCol, Length(S));
  T := TopMargin + (Index - FTopRow) * GetRowHeight;
  B := T + FFontHeight + FMargin.FUnderline;
  LM := LeftMargin;
  // 領域左側
  L := LM + StartCol * FFontWidth - FLeftScrollWidth;
  I := StartCol + 1;
  if (0 < I) and (I <= Length(S)) and IsDBCS2(S, I) then
    L := L + FFontWidth;
  L := Max(LM, L);
  // 領域右側
  R := LM + EndCol * FFontWidth - FLeftScrollWidth;
  I := EndCol + 1;
  if (0 < I) and (I <= Length(S)) and IsDBCS2(S, I) then
    R := R + FFontWidth;
  R := Max(LM, R);
  Result := Rect(L, T, R, B);
end;

function TEditor.BoxLeftIndex(const Attr: String; I: Integer): Integer;
(*
  矩形選択領域左側の文字インデックスを返す
  Attr には文字属性配列を渡すこと。
  タブ文字が展開された部分に領域の左端がある場合、そのタブ文字は
  選択領域に含まれない仕様
  I には、FCol + 1, FSelDraw.Sc + 1 を推奨
*)
begin
  if IndexChar(Attr, I) = caDBCS2 then
    Inc(I)
  else
    while IndexChar(Attr, I) = caTabSpace do
      Inc(I);
  Result := I - IncludeCharCount(Attr, caTabSpace, I);
end;

function TEditor.BoxRightIndex(const Attr: String; I: Integer): Integer;
(*
  矩形選択領域右側の文字インデックスを返す
  Attr は文字属性配列を渡す。
  I には、FSelDraw.Ec を推奨
*)
begin
  if IndexChar(Attr, I) = caDBCS1 then
    Inc(I)
  else
    while IndexChar(Attr, I) = caTabSpace do
      Dec(I);
  Result := I - IncludeCharCount(Attr, caTabSpace, I);
end;

function TEditor.CanSelDrag: Boolean;
(*
  選択文字列をマウスドラッグ出来る状態にあるかどうかを返す。
  マウスカーソルが領域内にあるかどうかは判別しない。
*)
begin
  Result := not ReadOnly and Selected and (FSelectionMode = smLine) and
            FCaret.FSelMove;
end;

procedure TEditor.CleanSelection;
var
  H, T: Integer;
  R: TRect;
begin
  if not HandleAllocated or not SelectedData then
    Exit;
  // 選択状態の終了処理
  FSelectionState := sstNone;
  // 検索一致文字列長の初期化
  FHitSelLength := 0;
  // hsCaret の場合、キャレットを元に戻す
  if HitSelected and (FHitStyle = hsCaret) then
    UpdateCaret;
  // 選択領域があればノーマル描画
  with FSelDraw do
    if (Sr <> Er) or (Sc <> Ec) then
    begin
      Sr := Min(FTopRow + FRowCount, Max(FTopRow, Sr));
      Er := Min(FTopRow + FRowCount, Max(FTopRow, Er));
      H := GetRowHeight;
      T := TopMargin;
      R := Rect(
             LeftMargin,
             T + (Sr - FTopRow - 1) * H,
             Width,
             T + (Er - FTopRow + 1) * H
           );
      // アンダーライン部分も再描画で塗りつぶしてもらうためのフラグ
      FClearingSelection := True;
      try
        InvalidateRect(Handle, @R, False);
        // FClearingSelection フラグが有効な内に再描画する
        UpdateWindow(Handle);
      finally
        FClearingSelection := False;
      end;
    end;
  // StartSelection で消したアンダーラインを復活
  UnderlineEndUpdate;
  FColKeeping := False;
  DoSelectionChange(Boolean(Byte(FSelectionState)));
end;

procedure TEditor.DeleteSelection;
var
  Ri, Re, SelIndex: Integer;
  Buf: String;
  UpdateFlag: Boolean;
  List: TEditorStringList;
begin
  // 選択領域を含む行の文字列を、選択領域を削除した文字列で置き換える
  if not HandleAllocated or not Selected then
    Exit;
  with FSelStr do
  begin
    // キャレット位置 FSelStr.Sc ではないことに注意
    Ri := Max(FList.RowStart(Sr), Sr - 1);
    SelIndex := GetSelIndex(Ri, FSelDraw.Sr, FSelDraw.Sc);
    // RowEnd
    Re := Min(Er, FList.Count - 1);
    // 置き換える文字列を作成
    Buf := '';
    List := TEditorStringList.Create;
    try
      SelDeletedList(List);
      Buf := ListToStr(List);
    finally
      List.Free;
    end;

    UpdateFlag := FSelDraw.Sr <> FSelDraw.Er;
    if UpdateFlag then
    begin
      CaretBeginUpdate;
      UnderlineBeginUpdate;
    end;
    try
      // 選択領域をノーマル描画する
      CleanSelection;
      FList.UpdateList(Sr, Re - Sr + 1, Buf);
      // キャレットの移動
      SetSelIndex(Ri, SelIndex);
    finally
      if UpdateFlag then
      begin
        UnderlineEndUpdate;
        CaretEndUpdate;
      end;
    end;
  end;
end;

procedure TEditor.DrawSelection;
begin
  if Showing then
  begin
    if FSelectionMode = smLine then
      DrawSelectionLine
    else
      DrawSelectionBox;
  end;
end;

procedure TEditor.DrawSelectionLine;
var
  LinesCount, X, H, LineHeight, I, T, dsr, der, TM, LM: Integer;
  R: TRect;
  S: String;
  Parser: TFountainParser;
begin
  if FList.Count = 0 then
    Exit;
  LinesCount := FList.Count;
  // １行の高さ
  H := GetRowHeight;
  TM := TopMargin;
  LM := LeftMargin;
  // 文字の描画開始位置（マイナスの場合もあり）
  X := LM - FLeftScrollWidth;
  // 選択領域として描画する１行の高さ Margin.Line 部分は選択色にしない
  LineHeight := FFontHeight + FMargin.FUnderline;

  CaretBeginUpdate;
  try
    Parser := ActiveFountain.ParserClass.Create(ActiveFountain);
    try
      // ■ 選択→非選択になった行をノーマル描画

      // 選択領域が上方向に縮まった
      if FSelDraw.Er < FSelOld.Er then
      begin
        dsr := Max(FTopRow, FSelDraw.Er);
        der := Min(FTopRow + FRowCount, FSelOld.Er);
        for I := dsr to der do
          if I < LinesCount then
          begin
            S := ExpandListStr(I);
            T := TM + (I - FTopRow) * H;
            if I = FSelDraw.Er then
            begin
              R := Rect(
                     Max(LM,
                         LM + (FSelDraw.Ec - FTopCol) * FFontWidth),
                     T,
                     Width,
                     T + LineHeight
                   );
              PaintLine(R, X, R.Top, S, I, Parser);
            end
            else
            begin
              R := Rect(LM, T, Width, T + LineHeight);
              PaintLine(R, X, R.Top, S, I, Parser);
            end;
          end;
        if FSelOld.Sr < FSelDraw.Er then
          Exit;
      end
      else
        // 選択領域が下方向に縮まった
        if FSelOld.Sr < FSelDraw.Sr then
        begin
          dsr := Max(FTopRow, FSelOld.Sr);
          der := Min(FTopRow + FRowCount, FSelDraw.Sr);
          for I := dsr to der do
            if I < LinesCount then
            begin
              S := ExpandListStr(I);
              T := TM + (I - FTopRow) * H;
              if I = FSelDraw.Sr then
              begin
                R := Rect(
                       LM,
                       T,
                       Max(LM,
                           LM + (FSelDraw.Sc - FTopCol) * FFontWidth),
                       T + LineHeight
                     );
                PaintLine(R, X, R.Top, S, I, Parser);
              end
              else
              begin
                R := Rect(LM, T, Width, T + LineHeight);
                PaintLine(R, X, R.Top, S, I, Parser);
              end;
            end;
          if FSelOld.Er < FSelDraw.Sr then
            Exit;
        end
        else
          // １行選択から複数行選択へ移行する際に発生する特殊な状態
          //    abcdefg
          //    hijklmn
          //    f..b -> f..i になった場合 b..e をノーマル描画
          if (FSelOld.Sr = FSelOld.Er) and (FSelOld.Sc < FSelStartCol) and
             (FSelOld.Er < FSelDraw.Er) then
          begin
            R := Rect(
                   Max(LM,
                       LM + (FSelOld.Sc - FTopCol) * FFontWidth),
                   TM + (FSelOld.Sr - FTopRow) * H,
                   Max(LM,
                       LM + (FSelOld.Ec - FTopCol) * FFontWidth),
                   TM + (FSelOld.Sr - FTopRow) * H + LineHeight
                 );
            S := ExpandListStr(FSelOld.Sr);
            PaintLine(R, X, R.Top, S, FSelOld.Sr, Parser);
          end
          else
            //    abcdefg
            //    hijklmn
            //    i..m -> i..f になった場合 i..m をノーマル描画
            if (FSelOld.Sr = FSelOld.Er) and (FSelStartCol < FSelOld.Ec) and
               (FSelDraw.Sr < FSelOld.Sr) then
            begin
              R := Rect(
                     Max(LM,
                         LM + (FSelOld.Sc - FTopCol) * FFontWidth),
                     TM + (FSelOld.Sr - FTopRow) * H,
                     Max(LM,
                         LM + (FSelOld.Ec - FTopCol) * FFontWidth),
                     TM + (FSelOld.Sr - FTopRow) * H + LineHeight
                   );
              S := ExpandListStr(FSelOld.Sr);
              PaintLine(R, X, R.Top, S, FSelOld.Sr, Parser);
            end;

      // ■ 選択→非選択になった文字をノーマル描画

      // 選択領域が左方向に縮まった
      if (FSelDraw.Sr = FSelOld.Sr) and (FSelDraw.Er = FSelOld.Er) and
         (FSelDraw.Ec < FSelOld.Ec) and (FSelDraw.Er < LinesCount) then
      begin
        R := Rect(
               Max(LM,
                   LM + (FSelDraw.Ec - FTopCol) * FFontWidth),
               TM + (FSelDraw.Er - FTopRow) * H,
               Max(LM,
                   LM + (FSelOld.Ec - FTopCol) * FFontWidth),
               TM + (FSelDraw.Er - FTopRow) * H + LineHeight
             );
        S := ExpandListStr(FSelDraw.Er);
        PaintLine(R, X, R.Top, S, FSelDraw.Er, Parser);
      end
      else
        // 選択領域が右方向に縮まった
        if (FSelDraw.Sr = FSelOld.Sr) and (FSelDraw.Er = FSelOld.Er) and
           (FSelOld.Sc < FSelDraw.Sc) then
        begin
          R := Rect(
                 Max(LM,
                     LM + (FSelOld.Sc - FTopCol) * FFontWidth),
                 TM + (FSelDraw.Sr - FTopRow) * H,
                 Max(LM,
                     LM + (FSelDraw.Sc - FTopCol) * FFontWidth),
                 TM + (FSelDraw.Sr - FTopRow) * H + LineHeight
               );
          S := ExpandListStr(FSelDraw.Sr);
          PaintLine(R, X, R.Top, S, FSelDraw.Sr, Parser);
        end;

      // ■ 非選択→選択になった行を描画

      // 選択領域が下に伸びた
      if FSelOld.Er < FSelDraw.Er then
      begin
        dsr := Max(FTopRow, FSelOld.Er);
        der := Min(FTopRow + FRowCount, FSelDraw.Er);
        for I := dsr to der do
          if I < LinesCount then
          begin
            S := ExpandListStr(I);
            T := TM + (I - FTopRow) * H;
            if I = FSelOld.Er then
              R := Rect(
                     Max(LM,
                         LM + (FSelOld.Ec - FTopCol) * FFontWidth),
                     T,
                     Width,
                     T + LineHeight
                   )
            else
              if I = FSelDraw.Er then
                R := Rect(
                       LM,
                       T,
                       Max(LM,
                           LM + (FSelDraw.Ec - FTopCol) * FFontWidth),
                       T + LineHeight
                     )
              else
                R := Rect(LM, T, Width, T + LineHeight);
            PaintLineSelected(R, X, R.Top, S, I, Parser);
          end;
        Exit;
      end
      else
        // 選択領域が上に伸びた
        if FSelDraw.Sr < FSelOld.Sr then
        begin
          dsr := Max(FTopRow, FSelDraw.Sr);
          der := Min(FTopRow + FRowCount, FSelOld.Sr);
          for I := dsr to der do
            if I < LinesCount then
            begin
              S := ExpandListStr(I);
              T := TM + (I - FTopRow) * H;
              if I = FSelDraw.Sr then
                R := Rect(
                       Max(LM,
                           LM + (FSelDraw.Sc - FTopCol) * FFontWidth),
                       T,
                       Width,
                       T + LineHeight
                     )
              else
                if I = FSelOld.Sr then
                  R := Rect(
                         LM,
                         T,
                         Max(LM,
                             LM + (FSelOld.Sc - FTopCol) * FFontWidth),
                         T + LineHeight
                       )
                else
                  R := Rect(LM, T, Width, T + LineHeight);
              PaintLineSelected(R, X, R.Top, S, I, Parser);
            end;
          Exit;
        end
        else
          // 複数行選択から１行選択へ移行する際に発生する特殊な状態１
          // 選択領域が上に縮んで１行になり、FSelStartCol よりも前に
          // FSelDraw.Sc が居る場合の処理
          //    abcdefg
          //    hijklmn
          //    f..i -> f..b になった場合 b..f を選択描画
          if (FSelDraw.Sr = FSelDraw.Er) and (FSelDraw.Sc < FSelStartCol) and
             (FSelDraw.Er < FSelOld.Er) then
          begin
            R := Rect(
                   Max(LM,
                       LM + (FSelDraw.Sc - FTopCol) * FFontWidth),
                   TM + (FSelDraw.Sr - FTopRow) * H,
                   Max(LM,
                       LM + (FSelDraw.Ec - FTopCol) * FFontWidth),
                   TM + (FSelDraw.Sr - FTopRow) * H + LineHeight
                 );
            S := ExpandListStr(FSelDraw.Sr);
            PaintLineSelected(R, X, R.Top, S, FSelDraw.Sr, Parser);
            Exit;
          end
          else
            // 複数行選択から１行選択へ移行する際に発生する特殊な状態２
            // 選択領域が下に縮んで１行になり、FSelStartCol よりも後ろに
            // FSelDraw.Ec が居る場合の処理
            //    abcdefg
            //    hijklmn
            //    i..f -> i..m になった場合 i..m を選択描画
            if (FSelDraw.Sr = FSelDraw.Er) and (FSelStartCol < FSelDraw.Ec) and
               (FSelOld.Sr < FSelDraw.Sr) then
            begin
              R := Rect(
                     Max(LM,
                         LM + (FSelDraw.Sc - FTopCol) * FFontWidth),
                     TM + (FSelDraw.Sr - FTopRow) * H,
                     Max(LM,
                         LM + (FSelDraw.Ec - FTopCol) * FFontWidth),
                     TM + (FSelDraw.Sr - FTopRow) * H + LineHeight
                   );
              S := ExpandListStr(FSelDraw.Sr);
              PaintLineSelected(R, X, R.Top, S, FSelDraw.Sr, Parser);
              Exit;
            end;

      // ■ 非選択→選択になった文字を描画

      // 選択領域が右に伸びた
      if (FSelDraw.Sr = FSelOld.Sr) and (FSelDraw.Er = FSelOld.Er) and
         (FSelOld.Ec < FSelDraw.Ec) and (FSelDraw.Er < LinesCount) then
      begin
        R := Rect(
               Max(LM,
                   LM + (FSelOld.Ec - FTopCol) * FFontWidth),
               TM + (FSelDraw.Er - FTopRow) * H,
               Max(LM,
                   LM + (FSelDraw.Ec - FTopCol) * FFontWidth),
               TM + (FSelDraw.Er - FTopRow) * H + LineHeight
             );
        S := ExpandListStr(FSelDraw.Er);
        PaintLineSelected(R, X, R.Top, S, FSelDraw.Er, Parser);
      end
      else
        // 選択領域が左に伸びた
        if (FSelDraw.Sr = FSelOld.Sr) and (FSelDraw.Er = FSelOld.Er) and
           (FSelDraw.Sc < FSelOld.Sc) then
        begin
          R := Rect(
                 Max(LM,
                     LM + (FSelDraw.Sc - FTopCol) * FFontWidth),
                 TM + (FSelDraw.Sr - FTopRow) * H,
                 Max(LM,
                     LM + (FSelOld.Sc - FTopCol) * FFontWidth),
                 TM + (FSelDraw.Sr - FTopRow) * H + LineHeight
               );
          S := ExpandListStr(FSelDraw.Sr);
          PaintLineSelected(R, X, R.Top, S, FSelDraw.Sr, Parser);
        end;
    finally
      Parser.Free;
    end;
  finally
    CaretEndUpdate;
    FSelOld := FSelDraw;
  end;
end;

procedure TEditor.DrawSelectionBox;
var
  LinesCount, X, H, LineHeight, I, T, dsr, der, TM, LM: Integer;
  R: TRect;
  S: String;
  Parser: TFountainParser;
begin
  if FList.Count = 0 then
    Exit;
  LinesCount := FList.Count;
  // １行の高さ
  H := GetRowHeight;
  TM := TopMargin;
  LM := LeftMargin;
  // 文字の描画開始位置（マイナスの場合もあり）
  X := LM - FLeftScrollWidth;
  // 選択領域として描画する１行の高さ Margin.Line 部分は選択色にしない
  LineHeight := FFontHeight + FMargin.FUnderline;

  CaretBeginUpdate;
  try
    Parser := ActiveFountain.ParserClass.Create(ActiveFountain);
    try
      // ■ 選択→非選択になった行をノーマル描画

      // 選択領域が上方向に縮まった
      if FSelDraw.Er < FSelOld.Er then
      begin
        dsr := Max(FTopRow, FSelDraw.Er + 1);
        der := Min(FTopRow + FRowCount, FSelOld.Er);
        for I := dsr to der do
          if I < LinesCount then
          begin
            S := ExpandListStr(I);
            T := TM + (I - FTopRow) * H;
            R := Rect(LM, T, Width, T + LineHeight);
            PaintLine(R, X, R.Top, S, I, Parser);
          end;
      end
      else
        // 選択領域が下方向に縮まった
        if FSelOld.Sr < FSelDraw.Sr then
        begin
          dsr := Max(FTopRow, FSelOld.Sr);
          der := Min(FTopRow + FRowCount, FSelDraw.Sr - 1);
          for I := dsr to der do
            if I < LinesCount then
            begin
              S := ExpandListStr(I);
              T := TM + (I - FTopRow) * H;
              R := Rect(LM, T, Width, T + LineHeight);
              PaintLine(R, X, R.Top, S, I, Parser);
            end;
        end;

      // ■ 選択→非選択になった文字をノーマル描画

      // 選択領域が左方向に縮まった
      if FSelDraw.Ec < FSelOld.Ec then
      begin
        dsr := Max(FTopRow, FSelDraw.Sr);
        der := Min(FTopRow + FRowCount, FSelDraw.Er);
        for I := dsr to der do
          if I < LinesCount then
          begin
            S := ExpandListStr(I);
            R := BoxSelRect(S, I, FSelDraw.Ec, FSelDraw.Ec + FColCount);
            R.Right := Width;  // 味噌
            PaintLine(R, X, R.Top, S, I, Parser);
          end;
      end
      else
        // 選択領域が右方向に縮まった
        if FSelOld.Sc < FSelDraw.Sc then
        begin
          dsr := Max(FTopRow, FSelDraw.Sr);
          der := Min(FTopRow + FRowCount, FSelDraw.Er);
          for I := dsr to der do
            if I < LinesCount then
            begin
              S := ExpandListStr(I);
              R := BoxSelRect(S, I, 0, FSelDraw.Sc);
              PaintLine(R, X, R.Top, S, I, Parser);
            end;
        end;

      // ■ 非選択→選択になった行を描画

      // 選択領域が下に伸びた
      if FSelOld.Er < FSelDraw.Er then
      begin
        dsr := Max(FTopRow, FSelOld.Er);
        der := Min(FTopRow + FRowCount, FSelDraw.Er);
        for I := dsr to der do
          if I < LinesCount then
          begin
            S := ExpandListStr(I);
            R := BoxSelRect(S, I, FSelDraw.Sc, FSelDraw.Ec);
            PaintLineSelected(R, X, R.Top, S, I, Parser);
          end;
      end
      else
        // 選択領域が上に伸びた
        if FSelDraw.Sr < FSelOld.Sr then
        begin
          dsr := Max(FTopRow, FSelDraw.Sr);
          der := Min(FTopRow + FRowCount, FSelOld.Sr);
          for I := dsr to der do
            if I < LinesCount then
            begin
              S := ExpandListStr(I);
              R := BoxSelRect(S, I, FSelDraw.Sc, FSelDraw.Ec);
              PaintLineSelected(R, X, R.Top, S, I, Parser);
            end;
        end;

      // ■ 非選択→選択になった文字を描画

      // 選択領域が右に伸びた
      if FSelOld.Ec < FSelDraw.Ec then
      begin
        dsr := Max(FTopRow, FSelDraw.Sr);
        der := Min(FTopRow + FRowCount, FSelDraw.Er);
        for I := dsr to der do
          if I < LinesCount then
          begin
            S := ExpandListStr(I);
            R := BoxSelRect(S, I, FSelDraw.Sc, FSelDraw.Ec);
            PaintLineSelected(R, X, R.Top, S, I, Parser);
          end;
      end
      else
        // 選択領域が左に伸びた
        if FSelDraw.Sc < FSelOld.Sc then
        begin
          dsr := Max(FTopRow, FSelDraw.Sr);
          der := Min(FTopRow + FRowCount, FSelDraw.Er);
          for I := dsr to der do
            if I < LinesCount then
            begin
              S := ExpandListStr(I);
              R := BoxSelRect(S, I, FSelDraw.Sc, FSelDraw.Ec);
              PaintLineSelected(R, X, R.Top, S, I, Parser);
            end;
        end;
    finally
      Parser.Free;
    end;
  finally
    CaretEndUpdate;
    FSelOld := FSelDraw;
  end;
end;

procedure TEditor.InitSelection;
(*
  現在の Row, Col 位置で選択領域の開始位置、選択領域データを初期化する
  データはすべて０ベース cf UpdateSelection
*)
var
  Si: Integer;
  S, Attr: String;

  function SelPos(Sr, Er, Sc, Ec: Integer): TSelectedPosition;
  begin
    Result.Sr := Sr;
    Result.Er := Er;
    Result.Sc := Sc;
    Result.Ec := Ec;
  end;

begin
  // 状態の変更
  if SelectedData then
    CleanSelection;
  if FList.Count = 0 then
    Exit;
  FSelectionState := sstInit;
  S := ListStr(FRow);
  Attr := StrToAttributes(S);
  Si := Min(Length(S), FCol - IncludeCharCount(Attr, caTabSpace, FCol + 1));
  // 選択開始位置初期化
  FSelStartRow := FRow;
  FSelStartSi := Si;
  if FSelectionMode = smLine then
    FSelStartCol := Min(FCol, ExpandListLength(FRow))
  else
    FSelStartCol := FCol;
  // 選択領域データ初期化
  FSelStr := SelPos(FRow, FRow, Si, Si);
  FSelDraw := SelPos(FRow, FRow, FSelStartCol, FSelStartCol);
  FSelOld := FSelDraw;
end;

procedure TEditor.SelDeletedList(Dest: TEditorStringList);
(*
  選択領域を削除したリストイメージを作成し Dest に格納する。
  smLine の場合は、Dest.Count = 1 になる。
  Dest.Rows[n] には、対応する FList.Rows[n] が格納される。
  Dest.Datas[n] には、FSelDraw.Sc + 1 を実際の文字インデックスに
  変換したものを格納する。変換は、矩形選択領域左側の規則に従う
  (cf.BoxLeftIndex)
*)
var
  I, Li: Integer;
  S, Attr: String;
begin
  Dest.Clear;
  if not Selected then
    Exit;
  if FSelectionMode = smLine then
  with FSelStr do
  begin
    // smLine
    S := '';
    // Sc の前
    S := S + Copy(ListStr(Sr), 1, Sc);
    // Ec の後
    if Er <= FList.Count - 1 then
      S := S + Copy(ListStr(Er), Ec + 2, Length(ListStr(Er)));
    Dest.Add(S);
    Dest.Rows[0] := ListRows(Er);
    Dest.Datas[0] := Pointer(Sc + 1);
  end
  else
  with FSelDraw do
  begin
    // smBox
    for I := Sr to Er do
      Dest.Add('');
    for I := Sr to Er do
    begin
      S := ListStr(I);
      Attr := StrToAttributes(S);
      Li := BoxLeftIndex(Attr, Sc + 1);
      Dest[I - Sr] := Copy(S, 1, Li - 1) +
                      Copy(S, BoxRightIndex(Attr, Ec) + 1, Length(S));
      Dest.Rows[I - Sr] := ListRows(I);
      Dest.Datas[I - Sr] := Pointer(Li);
    end;
  end;
end;

procedure TEditor.SetSelection;
begin
  if FSelectionState = sstInit then
    StartSelection
  else
    if FSelectionState = sstSelected then
      UpdateSelection;
end;

procedure TEditor.StartSelection;
begin
  if FSelectionState = sstInit then
  begin
    UnderlineBeginUpdate;
    if FHitSelecting then
      FSelectionState := sstHitSelected
    else
      FSelectionState := sstSelected;
    UpdateSelection;
  end;
end;

procedure TEditor.UpdateSelection;
(*
  現在の Row, Col から FSelStr, FSelDraw を更新して DrawSelection
  を呼び出す。DrawSelection では、FSelOld と FSelDraw の差分を
  選択領域として描画している

  FSelDraw.Ec は、選択領域下右端 Col に対応しているが、
  FSelStr.Ec は、選択領域下右端の０ベースの文字インデックス - 1
  になるという悩ましい仕様
*)
var
  Si: Integer;
  S, Attr: String;
begin
  if not SelectedData then
    Exit;
  S := ListStr(FRow);
  Attr := StrToAttributes(S);
  Si := Min(Length(S),
            FCol - IncludeCharCount(Attr, caTabSpace, FCol + 1));
  // FSelStr の更新
  with FSelStr do
  begin
    Sr := Min(FSelStartRow, FRow);
    Er := Max(FSelStartRow, FRow);
    if Sr = Er then
      if FSelStartSi < Si then
      begin
        Sc := FSelStartSi;
        Ec := Si - 1;
      end
      else
      begin
        Sc := Si;
        Ec := FSelStartSi - 1;
      end
    else
      if FSelStartRow < FRow then
      begin
        Sc := FSelStartSi;
        Ec := Si - 1;
      end
      else
      begin
        Sc := Si;
        Ec := FSelStartSi - 1;
      end;
  end;

  // FSelDraw の更新
  if FSelectionMode = smLine then
  begin
    with FSelDraw do
    begin
      Sr := Min(FSelStartRow, FRow);
      Er := Max(FSelStartRow, FRow);
      if FSelStartRow = FRow then
      begin
        Sc := Min(Min(FSelStartCol, FCol), ExpandListLength(FRow));
        Ec := Min(Max(FSelStartCol, FCol), ExpandListLength(FRow));
      end
      else
        if FSelStartRow < FRow then
        begin
          Sc := Min(FSelStartCol, ExpandListLength(FSelStartRow));
          Ec := Min(FCol, ExpandListLength(FRow));
        end
        else
        begin
          Sc := Min(FCol, ExpandListLength(FRow));
          Ec := Min(FSelStartCol, ExpandListLength(FSelStartRow));
        end;
    end;
  end
  else
    // 矩形選択
    with FSelDraw do
    begin
      Sr := Min(FSelStartRow, FRow);
      Er := Max(FSelStartRow, FRow);
      Sc := Min(FSelStartCol, FCol);
      Ec := Max(FSelStartCol, FCol);
    end;
  // 選択領域を描画
  if SelectedDraw then
    DrawSelection;
  DoSelectionChange(Boolean(Byte(FSelectionState)));
end;

procedure TEditor.StartRowSelection(ARow: Integer);
(*
  ARow で指定された１行を選択状態にし、キャレットを ARow の
  行頭へ移動する。
  ARow を選択可能な行番号へ調節し、ARow の行頭から次の行頭
  までを選択領域とする。ARow が raEof の場合はその行末から
  行頭までを選択領域とする。
*)
begin
  if FList.Count = 0 then
    Exit;
  // adjust ARow
  ARow := Min(ARow, FList.Count);
  if (ARow = FList.Count) and (ListRows(FList.Count - 1) = raEof) then
    ARow := FList.Count - 1;
  // 選択領域データを初期化して選択状態へ移行
  if ListRows(ARow) = raEof then
  begin
    SetRowCol(ARow, ExpandListLength(ARow));
    InitSelection;
    SetRowCol(ARow, 0);
    StartSelection;
    FSelRow.Sr := ARow;
    FSelRow.Er := ARow;
    FSelRow.Sc := 1;
    // raEof な行から始まる場合は、UpdateRowSelection の (2) の
    // 処理が不要になるので、そのフラグとして Sc を利用する
  end
  else
  begin
    SetRowCol(ARow, 0);
    InitSelection;
    SetRowCol(ARow + 1, 0);
    StartSelection;
    FSelRow.Sr := ARow;
    FSelRow.Er := ARow + 1;
    FSelRow.Sc := 0;
  end;
  // キャレットを移動
  SetRowCol(ARow, 0);
  //フラグ設定
  FRowSelecting := True; // FRowSelecting := False in WMLButtonUp
end;

procedure TEditor.UpdateRowSelection(ARow: Integer);
(*
  FSelRow.Sr, FSelRow.Er と ARow を比較して選択領域を更新する
  FSelRow.Er..ARow が FSelRow.Sr を跨ぐ場合は、領域の初期化処理が
  必要になる

  初期状態  ARow -> Sr, Er(eof)
                    Er

  (1)       ARow ->           Er
                    Sr --+
                    Er   +--> Sr

  (2)               Er   +--> Sr
                    Sr --+
            ARow ->           Er
*)
begin
  if not FRowSelecting then
    Exit;
  // adjust ARow
  ARow := Min(ARow, FList.Count);
  if (ARow = FList.Count) and (ListRows(FList.Count - 1) = raEof) then
    ARow := FList.Count - 1;
  // 判別
  if ARow >= FSelRow.Sr then
  begin
    // Sr から下へ領域移動
    if (FSelRow.Er < FSelRow.Sr) and (FSelRow.Sc = 0) then // (2)
    begin
      Dec(FSelRow.Sr);
      SetRowCol(FSelRow.Sr, 0);
      InitSelection;
    end;
    if ListRows(ARow) = raEof then
      if FSelRow.Sc = 0 then
        SetRowCol(ARow, ExpandListLength(ARow))
      else
        SetRowCol(ARow, 0)
    else
    begin
      Inc(ARow);
      SetRowCol(ARow, 0);
    end;
  end
  else
  begin
    // Sr より上へ領域移動
    if FSelRow.Sr < FSelRow.Er then // (1)
    begin
      Inc(FSelRow.Sr);
      SetRowCol(FSelRow.Sr, 0);
      InitSelection;
    end;
    SetRowCol(ARow, 0);
  end;
  FSelRow.Er := ARow;
  SetSelection;
end;

procedure TEditor.ClearSelection;
begin
  DeleteSelection;
end;

procedure TEditor.CopyToClipboard;
var
  S: String;
  Size: Integer;
  Data: THandle;
  DataPtr, Buffer: Pointer;
begin
  if Selected then
    if FSelectionMode = smLine then
      Clipboard.SetTextBuf(PChar(GetSelText))
    else
    begin
      S := GetSelText;
      Size := Length(S) + 1;
      Data := GlobalAlloc(GMEM_MOVEABLE, Size);
      DataPtr := GlobalLock(Data);
      try
        Buffer := PChar(S);
        Move(Buffer^, DataPtr^, Size);
        Clipboard.Open;
        try
          Clipboard.SetTextBuf(PChar(S));
          Clipboard.SetAsHandle(CF_BOXTEXT, Data);
        finally
          Clipboard.Close;
        end;
      finally
        GlobalUnlock(Data);
      end;
    end;
end;

procedure TEditor.CutToClipboard;
begin
  if Selected then
  begin
    CopyToClipboard;
    DeleteSelection;
  end;
end;

procedure TEditor.PasteFromClipboard;
begin
  if Clipboard.HasFormat(CF_TEXT) then
    if Clipboard.HasFormat(CF_BOXTEXT) then
      SetSelTextBox(PChar(Clipboard.AsText))
    else
      SetSelTextBuf(PChar(Clipboard.AsText));
end;

procedure TEditor.SelectAll;
begin
  CaretBeginUpdate;
  try
    SelStart := 0;
    SelLength := GetTextLen;
  finally
    CaretEndUpdate;
  end;
end;


// 選択領域の移動処理 ///////////////////////////////////////////////

(*

#SelectionMove

FSelDragState
  sdNone
  sdInit         選択領域で WM_LBUTTONDOWN された状態
  sdDragging     そこから数ピクセル動いてドラッグが始まった状態
InitSelDrag      -> sdInit
StartSelDrag     -> sdDragging
EndSelDrag       -> sdNone
CancelSelDrag    -> sdNone

*)

procedure TEditor.InitSelDrag;
begin
  FSelDragState := sdInit;
end;

procedure TEditor.StartSelDrag;
begin
  if FSelDragState = sdInit then
  begin
    FSelDragState := sdDragging;
    // CursorState の更新
    if GetKeyState(VK_CONTROL) < 0 then
      CursorState := mcDraggingCopy
    else
      CursorState := mcDragging;
  end;
end;

procedure TEditor.EndSelDrag;
var
  Pos: TPoint;
begin
  if FSelDragState = sdDragging then
  begin
    FSelDragState := sdNone;
    GetCursorPos(Pos);
    Pos := ScreenToClient(Pos);
    if not PtInRect(ClientRect, Pos) or IsSelectedArea(FRow, FCol) then
      CleanSelection
    else
    begin
      if GetKeyState(VK_CONTROL) < 0 then
        CopySelection(FRow, FCol)
      else
        MoveSelection(FRow, FCol);
    end;
  end;
end;

procedure TEditor.CancelSelDrag;
begin
  FSelDragState := sdNone;
  if (GetKeyState(VK_ESCAPE) < 0) and FCaret.FAutoCursor then
    Windows.SetCursor(Screen.Cursors[FCaret.FCursors.FDefaultCursor])
  else
    CursorState := mcClient;
  CleanSelection;
end;

function TEditor.IsSelectedArea(ARow, ACol: Integer): Boolean;
(*
  ARow, ACol が選択領域内にあるかどうかを返す。
  この関数では、矩形選択状態もサポートしている。
*)
var
  Attr: String;
begin
  Result := False;
  if Selected then
  with FSelDraw do
    if not Selected or (ARow < Sr) or (Er < ARow) then
      Exit
    else
      if FSelectionMode = smLine then
        Result := not ((ARow = Sr) and (ACol < Sc)) and
                  not ((ARow = Er) and (Ec - 1 < ACol))
      else
      begin
        Attr := StrToAttributes(ListStr(ARow));
        Result := (BoxLeftIndex(Attr, Sc + 1) - 1 <= ACol) and
                  (ACol <= BoxRightIndex(Attr, Ec - 1));
      end;
end;

procedure TEditor.CopySelection(ARow, ACol: Integer);
(*
  選択領域の文字列を ARow, ACol 位置へコピーする。
  そこが選択領域内の場合は無視される。
  矩形選択はサポートしていない。
  ARow, ACol の判別については、MoveSelection と同じ
*)
var
  S: String;
begin
  if not CanSelDrag or IsSelectedArea(ARow, ACol) then
  begin
    CleanSelection;
    Exit;
  end;
  S := GetSelText;
  CleanSelection;
  SetRowCol(ARow, ACol);
  SetSelTextBuf(PChar(S));
end;

procedure TEditor.MoveSelection(ARow, ACol: Integer);
(*
  選択領域の文字列を ARow, ACol 位置へ移動する。
  そこが選択領域内の場合は無視する。矩形選択はサポートしない。

  ARow, ACol 位置がキャレット移動可能な位置であるかどうかの
  判別は行っていないので、望まれる位置へキャレットを移動後
  (SetRowCol してから)実際のキャレット位置を渡すこと
  ARow, ACol が実際のキャレット位置ではない場合の動作は保証
  されない。

     <-         a          ->(1)<-           c              ->
                              d
                    Sc
  Sr <-    e      ->+----------------------------------------+
          (2)<- g ->|                                        |
     +--------------+                                        |
     |                 選択領域 GetSelText b                 |
     |                                                       |
     |                                       +---------------+
     |                                       |<- h ->(3)
  Er +---------------------------------------+<-      f     ->
                                             Ec
                              i
     <-         a          ->(4)<-           c              ->

*)
var
  I, Rs, Re, Ri, SelIndex: Integer;
  Buf: String;
  Si: Integer;
  Attr, S: String;

  function BeforeCol: String; // a
  begin
    S := ListStr(ARow);
    Attr := StrToAttributes(S);
    Si := ACol - IncludeCharCount(Attr, caTabSpace, ACol + 1);
    Result := Copy(S, 1, Si);
    if Length(Attr) < ACol then
      Result := Result + StringOfChar(#$20, ACol - Length(Attr))
  end;

  function AfterCol: String; // c
  begin
    S := ListStr(ARow);
    Attr := StrToAttributes(S);
    Si := ACol - IncludeCharCount(Attr, caTabSpace, ACol + 1);
    Result := Copy(S, Si + 1, Length(S));
    FList.CheckCrlf(ARow, Result);
  end;

  function BeforeSc: String; // e
  begin
    Result := Copy(ListStr(FSelStr.Sr), 1, FSelStr.Sc);
  end;

  function AfterEc: String; // f
  begin
    S := ListStr(FSelStr.Er);
    Result := Copy(S, FSelStr.Ec + 2, Length(S));
    FList.CheckCrlf(FSelStr.Er, Result);
  end;

  function BetweenColSc: String; // g
  begin
    S := ListStr(FSelStr.Sr);
    Attr := StrToAttributes(S);
    Si := ACol - IncludeCharCount(Attr, caTabSpace, ACol + 1);
    Result := Copy(S, Si + 1, FSelStr.Sc - Si);
  end;

  function BetweenEcCol: String; // h
  begin
    S := ListStr(FSelStr.Er);
    Attr := StrToAttributes(S);
    Si := ACol - IncludeCharCount(Attr, caTabSpace, ACol + 1);
    Result := Copy(S, FSelStr.Ec + 2, Si - FSelStr.Ec - 1);
    if Length(Attr) < ACol then
      Result := Result + StringOfChar(#$20, ACol - Length(Attr))
  end;

begin
  if not CanSelDrag or IsSelectedArea(ARow, ACol) then
  begin
    CleanSelection;
    Exit;
  end;

  // 更新する領域とキャレット移動のためのデータ
  with FSelDraw do
    if ARow <= Sr then
    begin
      Rs := ARow;
      Re := Er;
      Ri := Max(FList.RowStart(ARow), ARow - 1);
    end
    else
    begin
      Rs := Sr;
      Re := ARow;
      Ri := Max(FList.RowStart(Sr), Sr - 1);
    end;

  // 挿入する文字列を作成
  with FSelDraw do
  begin
    if ARow < Sr then
    begin
      // (1) a, b, c, d, e, f
      Buf := GetSelText; // b
      SelIndex := GetSelIndex(Ri, ARow, ACol) + Length(Buf);
      Buf := BeforeCol + Buf + AfterCol; // a + b + c
      for I := ARow + 1 to Sr - 1 do     // d
      begin
        Buf := Buf + ListStr(I);
        FList.CheckCrlf(I, Buf);
      end;
      Buf := Buf + BeforeSc + AfterEc;   // e + f
    end
    else
      if (ARow = Sr) and (ACol < Sc) then
      begin
        // (2) a, b, g, f
        Buf := GetSelText; // b
        SelIndex := GetSelIndex(Ri, ARow, ACol) + Length(Buf);
        Buf := BeforeCol + Buf + BetweenColSc + AfterEc; // a + b + g + f
      end
      else
        if (ARow = Er) and (Ec <= ACol) then
        begin
          // (3) e, h, b, c
          Buf := BetweenEcCol + GetSelText; // h + b
          SelIndex := GetSelIndex(Ri, Sr, Sc) + Length(Buf);
          Buf := BeforeSc + Buf + AfterCol; // e + h + b + c
        end
        else
        begin
          // (4) e, f, i, a, b, c
          Buf := AfterEc;                      // f
          for I := Er + 1 to ARow - 1 do       // i
          begin
            Buf := Buf + ListStr(I);
            FList.CheckCrlf(I, Buf);
          end;
          Buf := Buf + BeforeCol + GetSelText; // a + b
          SelIndex := GetSelIndex(Ri, Sr, Sc) + Length(Buf);
          Buf := BeforeSc + Buf + AfterCol; // e + f + i + a + b + c
        end;
  end;
  // 選択領域の解除
  CleanSelection;
  // 文字列の更新と描画
  CaretBeginUpdate;
  try
    if Rs > FList.Count - 1 then
      FList.UpdateList(Rs, 0, Buf)
    else
      if Re <= FList.Count - 1 then
        FList.UpdateList(Rs, Re - Rs + 1, Buf)
      else
        FList.UpdateList(Rs, Re - Rs, Buf);
    // キャレットを移動
    SetSelIndex(Ri, SelIndex);
  finally
    CaretEndUpdate;
  end;
end;


// トークン /////////////////////////////////////////////////////////

(*
    TTokenParser

    TFountain を利用しないパーサークラス。
    PosTokenString, SelectPosToken メソッドのためだけに存在する。
*)

type
  TTokenParser = class(TFountainParser)
  public
    constructor Create(Fountain: TFountain); override;
    function TokenToFountainColor: TFountainColor; override;
  end;

constructor TTokenParser.Create(Fountain: TFountain);
begin
  InitMethodTable;
end;

function TTokenParser.TokenToFountainColor: TFountainColor;
begin
  Result := nil;
end;


function TEditor.PosTokenString(Pos: TPoint; Editor: TEditor;
  var C: Char; Bracket: Boolean): String;
(*
  Pos 位置の語句を返す。Editor に Self を渡す場合 View プロパティへの
  設定が尊重され、nil を渡すと View プロパティの設定は無視される。
  C には、語句の種類が格納される。

  Editor に Self を、Bracket に True が渡されると、ActiveFountain.Brackets
  プロパティへの設定も尊重されるが、返されるのは１行文字列内にある語句
  だけになる。
*)
var
  Info: TEditorStrInfo;
  Attr: TEditorRowAttribute;
  R, I: Integer;
  S, Buf: String;
  Parser: TFountainParser;
  Data: TRowAttributeData;
begin
  Result := '';
  C := toEof;
  if not ListInfoFromPos(Pos, Info) then
    Exit;
  R := FList.RowStart(Info.Line);
  (*
    Data の取得
             Editor
    Bracket  true                 false
    true     ListData             FillChar(,,0)
                                  InvalidBracketIndex
    false    ListData             FillChar(,,0)
             InvalidBracketIndex  InvalidBracketIndex
  *)
  if Editor = nil then
  begin
    FillChar(Data, SizeOf(Data), 0);
    Data.BracketIndex := InvalidBracketIndex;
  end
  else
  begin
    Data := ListData[R];
    if not Bracket then
      Data.BracketIndex := InvalidBracketIndex;
  end;
  for I := R to Info.Line - 1 do
    Inc(Info.CharIndex, Length(ListStr(I)));
  FList.ListInfo(R, -1, S, I, Attr);
  if Editor = nil then
    Parser := TTokenParser.Create(nil)
  else
    Parser := ActiveFountain.ParserClass.Create(ActiveFountain);
  try
    Parser.NewData(S, Data);
    while Parser.NextToken <> toEof do
    begin
      Buf := Parser.TokenString;
      if (Parser.SourcePos <= Info.CharIndex) and
         (Info.CharIndex <= Parser.SourcePos + Length(Buf) - 1) then
      begin
        Result := Copy(S, Parser.SourcePos + 1, Length(Buf));
        C := Parser.Token;
        Exit;
      end;
    end;
  finally
    Parser.Free;
  end;
end;

procedure TEditor.SelectPosToken(Pos: TPoint; Editor: TEditor; Bracket: Boolean);
(*
  Pos 位置の語句を選択する。Editor に Self を渡す場合 View プロパティ
  への設定が尊重され、nil を渡すと View プロパティの設定は無視される。

  Editor に Self を、Bracket に True が渡されると、ActiveFountain.Brackets
  プロパティへの設定も尊重されるが、選択されるのは１行文字列内にある語句
  だけになる。
*)
var
  Info: TEditorStrInfo;
  Attr: TEditorRowAttribute;
  R, I: Integer;
  S, Buf: String;
  Parser: TFountainParser;
  Data: TRowAttributeData;
begin
  if not ListInfoFromPos(Pos, Info) then
    Exit;
  R := FList.RowStart(Info.Line);
  (*
    Data の取得
             Editor
    Bracket  true                 false
    true     ListData             FillChar(,,0)
                                  InvalidBracketIndex
    false    ListData             FillChar(,,0)
             InvalidBracketIndex  InvalidBracketIndex
  *)
  if Editor = nil then
  begin
    FillChar(Data, SizeOf(Data), 0);
    Data.BracketIndex := InvalidBracketIndex;
  end
  else
  begin
    Data := ListData[R];
    if not Bracket then
      Data.BracketIndex := InvalidBracketIndex;
  end;
  for I := R to Info.Line - 1 do
    Inc(Info.CharIndex, Length(ListStr(I)));
  FList.ListInfo(R, -1, S, I, Attr);
  if Editor = nil then
    Parser := TTokenParser.Create(nil)
  else
    Parser := ActiveFountain.ParserClass.Create(ActiveFountain);
  try
    Parser.NewData(S, Data);
    while Parser.NextToken <> toEof do
    begin
      Buf := Parser.TokenString;
      if (Parser.SourcePos <= Info.CharIndex) and
         (Info.CharIndex <= Parser.SourcePos + Length(Buf) - 1) then
      begin
        SetSelIndex(R, Parser.SourcePos);
        SetSelLength(Length(Buf));
        Exit;
      end;
    end;
  finally
    Parser.Free;
  end;
end;

procedure TEditor.SelectTokenBracketFromCaret;
(*
  キャレット位置の語句を選択する View プロパティの設定を尊重する
  ActiveFountain.Brackets プロパティの設定を尊重するが、選択されるのは
  １行文字列内にある語句だけになる
*)
var
  Pos: TPoint;
begin
  GetCaretPos(Pos);
  SelectTokenBracketFromPos(Pos);
end;

procedure TEditor.SelectTokenBracketFromPos(Pos: TPoint);
(*
  Pos 位置の語句を選択する View プロパティの設定を尊重する
  ActiveFountain.Brackets プロパティの設定を尊重するが、選択されるのは
  １行文字列内にある語句だけになる
*)
begin
  SelectPosToken(Pos, Self, True);
end;

procedure TEditor.SelectTokenFromCaret;
(*
  キャレット位置の語句を選択する View プロパティの設定を尊重するが
  ActiveFountain.Brackets プロパティへの設定は無視される
*)
var
  Pos: TPoint;
begin
  GetCaretPos(Pos);
  SelectTokenFromPos(Pos);
end;

procedure TEditor.SelectTokenFromPos(Pos: TPoint);
(*
  Pos 位置の語句を選択する View プロパティの設定を尊重するが
  ActiveFountain.Brackets プロパティへの設定は無視される
*)
begin
  SelectPosToken(Pos, Self, False);
end;

procedure TEditor.SelectWordFromCaret;
(*
  キャレット位置の１語を選択する View プロパティの設定は無視される
*)
var
  Pos: TPoint;
begin
  GetCaretPos(Pos);
  SelectWordFromPos(Pos);
end;

procedure TEditor.SelectWordFromPos(Pos: TPoint);
(*
  Pos 位置の１語を選択する View プロパティの設定は無視される
*)
begin
  SelectPosToken(Pos, Self, False);
end;

function TEditor.TokenBracketFromCaret: Char;
(*
  キャレット位置にある語句の種類を返す View プロパティの設定を
  尊重し、ActiveFountain.Brackets への設定も尊重される
*)
var
  Pos: TPoint;
begin
  GetCaretPos(Pos);
  Result := TokenBracketFromPos(Pos);
end;

function TEditor.TokenBracketFromPos(Pos: TPoint): Char;
(*
  Pos 位置にある語句の種類を返す View プロパティの設定を
  尊重し、ActiveFountain.Brackets への設定も尊重される
*)
begin
  PosTokenString(Pos, Self, Result, True);
end;

function TEditor.TokenFromCaret: Char;
(*
  キャレット位置にある語句の種類を返す View プロパティの設定を
  尊重するが ActiveFountain.Brackets への設定は無視される
*)
var
  Pos: TPoint;
begin
  GetCaretPos(Pos);
  Result := TokenFromPos(Pos);
end;

function TEditor.TokenFromPos(Pos: TPoint): Char;
(*
  Pos 位置にある語句の種類を返す View プロパティの設定を
  尊重するが ActiveFountain.Brackets への設定は無視される
*)
begin
  PosTokenString(Pos, Self, Result, False);
end;

function TEditor.TokenStringBracketFromCaret: String;
(*
  キャレット位置の語句を返す View プロパティの設定を
  尊重し、ActiveFountain.Brackets への設定も尊重されるが、
  結果に格納される文字列は１行文字列内にある語句だけになる
*)
var
  Pos: TPoint;
begin
  GetCaretPos(Pos);
  Result := TokenStringBracketFromPos(Pos);
end;

function TEditor.TokenStringBracketFromPos(Pos: TPoint): String;
(*
  Pos 位置の語句を返す View プロパティの設定を
  尊重し、ActiveFountain.Brackets への設定も尊重されるが、
  結果に格納される文字列は１行文字列内にある語句だけになる
*)
var
  C: Char;
begin
  Result := PosTokenString(Pos, Self, C, True);
end;

function TEditor.TokenStringFromCaret: String;
(*
  キャレット位置の語句を返す View プロパティの設定を
  尊重するが ActiveFountain.Brackets への設定は無視される
*)
var
  Pos: TPoint;
begin
  GetCaretPos(Pos);
  Result := TokenStringFromPos(Pos);
end;

function TEditor.TokenStringFromPos(Pos: TPoint): String;
(*
  Pos 位置の語句を返す View プロパティの設定を
  尊重するが ActiveFountain.Brackets への設定は無視される
*)
var
  C: Char;
begin
  Result := PosTokenString(Pos, Self, C, False);
end;

function TEditor.WordFromCaret: String;
(*
  キャレット位置の１語を返す View プロパティの設定は無視される
*)
var
  Pos: TPoint;
begin
  GetCaretPos(Pos);
  Result := WordFromPos(Pos);
end;

function TEditor.WordFromPos(Pos: TPoint): String;
(*
  Pos 位置の１語を返す View プロパティの設定は無視される
*)
var
  C: Char;
begin
  Result := PosTokenString(Pos, nil, C, False);
end;


// 文字列操作 ///////////////////////////////////////////////////////

function TEditor.CanRedo: Boolean;
begin
  Result := FList.FUndoObj.CanRedo;
end;

function TEditor.CanUndo: Boolean;
begin
  Result := FList.FUndoObj.CanUndo;
end;

function TEditor.CharFromPos(Pos: TPoint): Integer;
var
  I: Integer;
  Info: TEditorStrInfo;
begin
  // Pos 上の文字インデックス（ SelStart と同値）を返す
  Result := -1;
  if not ListInfoFromPos(Pos, Info) then
    Exit;
  Result := 0;
  for I := 0 to Info.Line - 1 do
    if ListRows(I) = raCrlf then
      Result := Result + Length(ListStr(I)) + 2
    else
      Result := Result + Length(ListStr(I));
  Result := Result + Info.CharIndex;
end;

procedure TEditor.Clear;
begin
  FLines.Clear;
end;

function TEditor.ColToChar(ARow, ACol: Integer): Integer;
(*
  ARow 上の ACol 位置の文字インデックスを返す（０ベース）
  不正な ARow な場合は -1 を返す
  WordWrap な場合は ARow より上の raWrapped な行の文字数も加算される
*)
var
  S, Attr: String;
  I, C: Integer;
begin
  Result := -1;
  if (ARow < 0) or (FList.Count < ARow) or (ACol < 0) then
    Exit;
  // FList の ARow 行の文字属性
  S := ListStr(ARow);
  Attr := StrToAttributes(S);
  // 全角２バイト目？
  if IndexChar(Attr, ACol + 1) = caDBCS2 then
    Dec(ACol);
  // タブの中？
  while IndexChar(Attr, ACol + 1) = caTabSpace do
    Dec(ACol);
  // ACol の FList[ARow] 上での文字インデックス（０ベース）
  C := Min(Length(S), ACol - IncludeCharCount(Attr, caTabSpace, ACol + 1));
  Result := C;
  // ARow よりも上の raWrapped な行の長さを追加
  I := ARow - 1;
  while (I >= 0) and (ListRows(I) = raWrapped) do
  begin
    Inc(Result, Length(ListStr(I)));
    Dec(I);
  end;
end;

procedure TEditor.DeleteRow(Index: Integer);
begin
  { 画面上の１行文字列を削除する }
  if (Index < 0) or (FList.Count - 1 < Index) then
    Exit;
  if SelectedData then
    CleanSelection;
  // delete
  CaretBeginUpdate;
  UnderlineBeginUpdate;
  try
    FList.UpdateList(Index, 1, '');
    if (Index > 0) and (FList.Rows[Index - 1] = raEof) then
    begin
      // 最終行を削除した場合
      Row := Index - 1;
      Col := ExpandListLength(Index - 1);
    end
    else
    begin
      Row := Index;
      Col := 0;
    end;
  finally
    UnderlineEndUpdate;
    CaretEndUpdate;
  end;
end;

function TEditor.ExpandListLength(Index: Integer): Integer;
begin
  if (Index < 0) or (FList.Count - 1 < Index) then
    Result := 0
  else
    Result := ExpandTabLength(FList[Index]);
end;

function TEditor.ExpandListStr(Index: Integer): String;
begin
  if (Index < 0) or (FList.Count - 1 < Index) then
    Result := ''
  else
    Result := ExpandTab(FList[Index]);
end;

function TEditor.ExpandTab(const S: String): String;
var
  I, L, B, T: Integer;
begin
  if Pos(#$09, S) = 0 then
  begin
    Result := S;
    Exit;
  end;
  Result := '';
  L := Length(S);
  I := 1;
  B := FList.FWrapOption.FWrapByte;
  T := FCaret.FTabSpaceCount;
  while I <= L do
  begin
    if S[I] in LeadBytes then
    begin
      Result := Result + S[I] + S[I + 1];
      Inc(I);
    end
    else
      if S[I] <> #$09 then
        Result := Result + S[I]
      else
        if not WordWrap then
          Result := Result +
                    StringOfChar(#$20,
                      T - (Length(Result) mod T)
                    )
        else
          Result := Result +
                    StringOfChar(#$20,
                      Min(T - (Length(Result) mod T),
                          B - Length(Result) mod B)
                    );
    Inc(I);
  end;
end;

function TEditor.ExpandTabLength(const S: String): Integer;
var
  I, L, B, T: Integer;
begin
  if Pos(#$09, S) = 0 then
  begin
    Result := Length(S);
    Exit;
  end;
  Result := 0;
  L := Length(S);
  I := 1;
  B := FList.FWrapOption.FWrapByte;
  T := FCaret.FTabSpaceCount;
  while I <= L do
  begin
    if S[I] in LeadBytes then
    begin
      Inc(Result, 2);
      Inc(I);
    end
    else
      if S[I] <> #$09 then
        Inc(Result)
      else
        if not WordWrap then
          Inc(Result, T - (Result mod T))
        else
          Inc(Result, Min(T - (Result mod T), B - Result mod B));
    Inc(I);
  end;
end;

function TEditor.GetSelTextBuf(Buffer: PChar; BufSize: Integer): Integer;
var
  S: String;
begin
  S := GetSelText;
  Result := Length(S);
  if Result >= BufSize then
    Result := BufSize - 1;
  StrPLCopy(Buffer, Copy(S, 1, Result), Result);
end;

function TEditor.GetTextLen: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FList.Count - 1 do
    if FList.Rows[I] = raCrlf then
      Inc(Result, Length(FList[I]) + 2)
    else
      Inc(Result, Length(FList[I]));
end;

function TEditor.ListInfoFromPos(Pos: TPoint; var Info: TEditorStrInfo): Boolean;
(*
  指定されたポイントから FList の行番号とその行文字列内での文字
  インデックスを Info に格納する。ワードラップは考慮しない。
  行番号、文字インデックスは共に０ベースであることに注意
*)
var
  R, C: Integer;
  S, Attr: String;
begin
  Result := False;
  Info.Line := -1;
  Info.CharIndex := -1;
  // 他人の OnMouseMove ハンドラに入った場合、FFontWidth が 0 の場合があるので
  if (FList.Count = 0) or (FFontWidth = 0) then
    Exit;
  // マージンの中
  if (Pos.X < LeftMargin) or (Pos.Y < TopMargin) then
    Exit;
  PosToRowCol(Pos.X, Pos.Y, R, C, True);
  if (R < 0) or (FList.Count < R) then
    Exit;
  Info.Line := R;
  // 行文字属性
  S := ListStr(R);
  Attr := StrToAttributes(S);
  // 行文字列以降か MaxLineCharacter より右側
  if C >= Length(Attr) then
    Exit;
  if C >= 0 then
  begin
    // 全角２バイト目？
    if IndexChar(Attr, C + 1) = caDBCS2 then
      Dec(C);
    // タブの中？
    while IndexChar(Attr, C + 1) = caTabSpace do
      Dec(C);
    Info.CharIndex :=
      Min(Length(S), C - IncludeCharCount(Attr, caTabSpace, C + 1));
  end;
  Result := True;
end;

function TEditor.ListRows(Index: Integer): TEditorRowAttribute;
begin
  if (Index < 0) or (FList.Count - 1 < Index) then
    Result := raEof
  else
    Result := FList.Rows[Index];
end;

function TEditor.ListStr(Index: Integer): String;
begin
  if (Index < 0) or (FList.Count - 1 < Index) then
    Result := ''
  else
    Result := FList[Index];
end;

function TEditor.LeftMargin: Integer;
begin
  Result := FMargin.FLeft;
  if FImagebar.FVisible then
    Inc(Result, FImagebarWidth);
  if FLeftbar.FVisible then
    Inc(Result, FLeftbarWidth);
end;

function TEditor.LinesToRow(Index: Integer): Integer;
begin
  Result := TEditorStrings(FLines).LinesToRow(Index);
end;

procedure TEditor.ListToFile(const FileName: String);
begin
  FList.SaveToFile(FileName);
end;

procedure TEditor.ListToStream(Stream: TStream);
begin
  FList.SaveToStream(Stream);
end;

function TEditor.ListToStr(Source: TEditorStringList): String;
(*
  Source.Rows プロパティを考慮した Text を返す
*)
var
  I, L, Size: Integer;
  P: PChar;
  S: String;
begin
  Size := 0;
  for I := 0 to Source.Count - 1 do
  begin
    Inc(Size, Length(Source.Strings[I]));
    if Source.Rows[I] = raCrlf then
      Inc(Size, 2)
  end;
  SetString(Result, nil, Size);
  P := Pointer(Result);
  for I := 0 to Source.Count - 1 do
  begin
    S := Source.Strings[I];
    L := Length(S);
    if L <> 0 then
    begin
      System.Move(Pointer(S)^, P^, L);
      Inc(P, L);
    end;
    if Source.Rows[I] = raCrlf then
    begin
      P^ := #13;
      Inc(P);
      P^ := #10;
      Inc(P);
    end;
  end;
end;

procedure TEditor.PutStringToLine(Source: String);
(*
  現在行のキャレット位置に Source を挿入する。
  上書きモードに対応する。
  ReadOnly の判別は行っていない。
  選択状態の場合は、選択領域の文字列が Source に置き換わるだけとし、
  上書きモードには対応しない仕様とする。
*)
var
  S, Attr, Buf: String;
  L, Ri, Rs, Re, SelIndex, Si, I: Integer;
  List: TEditorStringList;
begin
  L := Length(Source);
  if L = 0 then
    Exit;
  if Selected then
  with FSelStr do
  begin
    // キャレット位置 FSelStr.Sc ではないことに注意
    Ri := Max(FList.RowStart(Sr), Sr - 1);
    SelIndex := GetSelIndex(Ri, FSelDraw.Sr, FSelDraw.Sc) + L;
    Rs := Sr;
    Re := Er;
    // 置き換える文字列を作成。Sc, Ec は 0 base であることに注意
    List := TEditorStringList.Create;
    try
      SelDeletedList(List);
      if List.Count > 0 then
      begin
        S := List[0];
        Insert(Source, S, Integer(List.Datas[0]));
        List[0] := S;
      end;
      Buf := ListToStr(List);
    finally
      List.Free;
    end;
  end
  else
  begin
    Ri := Max(FList.RowStart(FRow), FRow - 1);
    SelIndex := GetSelIndex(Ri, FRow, FCol) + L;
    Rs := FRow;
    Re := FRow;
    // FRow の文字列属性と、文字列上でのインデックス取得
    S := ListStr(FRow);
    Attr := StrToAttributes(S);
    // Si は０ベース
    Si := FCol - IncludeCharCount(Attr, caTabSpace, FCol + 1);
    if Si < Length(S) then
    begin
      // 行の文字列内
      if FOverWrite then
      begin
        // 上書きモード
        // ver 1.30 より、raWrapped な行で IME から長い文字列が入力
        // された時、FRow 以降の行文字列も上書きする仕様とする。
        // キャレットより前と Source
        Buf := Copy(S, 1, Si) + Source;
        // Source 終端の文字インデックスを取得
        I := FCol + L;
        while (Length(Attr) < I) and (ListRows(Re) = raWrapped) do
        begin
          Dec(I, Length(Attr));
          Inc(Re);
          S := ListStr(Re);
          Attr := StrToAttributes(S);
          if I < Length(Attr) then
            Break;
        end;
        Si := I - IncludeCharCount(Attr, caTabSpace, I + 1);
        if IndexChar(Attr, I + 1) = caDBCS2 then
          Buf := Buf + #$20 + Copy(S, Si + 2, Length(S))
        else
          Buf := Buf + Copy(S, Si + 1, Length(S));
      end
      else
      begin
        // 挿入モード
        Insert(Source, S, Si + 1);
        Buf := S;
      end;
    end
    else
      // 行終端より右か、空白行の最初の文字
      // waRapped な行では発生しない
      Buf := S + StringOfChar(#$20, Si - Length(S)) + Source;
    FList.CheckCrlf(Re, Buf);
  end;
  // put & caret
  if SelectedData then
    CleanSelection;
  CaretBeginUpdate;
  try
    if Rs > FList.Count - 1 then
      FList.UpdateList(Rs, 0, Buf)
    else
      if Re <= FList.Count - 1 then
        FList.UpdateList(Rs, Re - Rs + 1, Buf)
      else
        FList.UpdateList(Rs, Re - Rs, Buf);
    SetSelIndex(Ri, SelIndex);
  finally
    CaretEndUpdate;
  end;
end;

procedure TEditor.Redo;
begin
  if SelectedData then
    CleanSelection;
  FList.Redo;
end;

function TEditor.RowToLines(Index: Integer): Integer;
(*
  FList の Index を FLines の Index に変換する
  例外を発生させるために敢えて
  Max(0, Min(Index, FList.Count))
  and (Result <= FEditor.FList.Count - 1)
  などの判別を行わない。
*)
var
  I: Integer;
begin
  if not WordWrap then
    Result := Index
  else
  begin
    Result := 0;
    I := 0;
    while I < Index do
    begin
      if FList.Rows[I] = raCrlf then
        Inc(Result);
      Inc(I);
    end;
  end;
end;

function TEditor.Search(const SearchValue: String; SearchOptions: TSearchOptions): Boolean;
const
  BufferSize = $2000;
var
  Info: TSearchInfo;
  R, C, I: Integer;
  S, Buf: String;
begin
  Result := False;
  if FList.Count = 0 then
    Exit;
  if sfrDown in SearchOptions then
  begin
    // Row, Col
    if SelectedData then // sstSelected or sstHitSelected
    begin
      R := FSelStr.Er;
      C := FSelStr.Ec + 1;
    end
    else
    begin
      R := FRow;
      S := ListStr(R);
      Buf := StrToAttributes(S);
      C := Min(Length(S),
               FCol - IncludeCharCount(Buf, caTabSpace, FCol + 1));
    end;
    // search forward
    I := R;
    repeat
      S := '';
      while (Length(S) < BufferSize) and (I <= FList.Count - 1) do
      begin
        S := S + FList[I];
        if FList.Rows[I] = raCrlf then
          S := S + #13#10;
        Inc(I);
      end;
      Info.Start := C;
      Info.Length := 0;
      if (FHitStyle = hsCaret) and (FHitSelLength > 0) then
        Inc(Info.Length, FHitSelLength);
      if SearchText(PChar(S), Info, SearchValue, SearchOptions) then
      begin
        if SelectedData then
          CleanSelection;
        SetSelIndex(R, Info.Start);
        HitSelLength := Info.Length;
        SendMessage(Handle, EM_SCROLLCARET, 0, 0);
        Result := True;
      end
      else
      begin
        if I > FList.Count - 1 then
          Exit;
        // raWrapped や、sfrIncludeCRLF, sfrIncludeSpace に対応するため
        // １行だぶらせて次の検索を行う
        // R 行の文字列長が $2000 バイト以上の場合のための判別を行う
        if R + 1 < I then
          Dec(I);
        R := I;
        C := 0;
      end;
    until Result;
  end
  else
  begin
    // Row, Col
    if SelectedData then
    begin
      R := FSelStr.Sr;
      C := FSelStr.Sc;
    end
    else
    begin
      if FRow <= FList.Count - 1 then
      begin
        R := FRow;
        S := ListStr(R);
        Buf := StrToAttributes(S);
        C := Min(Length(S),
                 FCol - IncludeCharCount(Buf, caTabSpace, FCol + 1));
      end
      else
      begin
        R := FList.Count - 1;
        C := Length(FList[R]);
        if FList.Rows[R] = raCrlf then
          Inc(C, 2);
      end;
    end;
    // search backward
    I := R;
    repeat
      S := '';
      while (Length(S) < BufferSize) and (I >= 0) and (I <= FList.Count - 1) do
      begin
        Buf := FList[I];
        if FList.Rows[I] = raCrlf then
          Buf := Buf + #13#10;
        if I <> R then
          Inc(C, Length(Buf));
        S := Buf + S;
        Dec(I);
      end;
      Info.Start := C;
      Info.Length := 0;
      if SearchText(PChar(S), Info, SearchValue, SearchOptions) then
      begin
        if SelectedData then
          CleanSelection;
        SetSelIndex(I + 1, Info.Start);
        HitSelLength := Info.Length;
        SendMessage(Handle, EM_SCROLLCARET, 0, 0);
        Result := True;
      end
      else
      begin
        if I < 0 then
          Exit;
        // raWrapped や、sfrIncludeCRLF, sfrIncludeSpace に対応するため
        // １行だぶらせて次の検索を行う
        // R 行の文字列長が $2000 バイト以上の場合のための判別を行う
        if R - 1 > I then
          Inc(I);
        R := I;
        if I <= FList.Count - 1 then
        begin
          C := Length(FList[I]);
          if FList.Rows[I] = raCrlf then
            Inc(C, 2);
        end
        else
          C := 0;
      end;
    until Result;
  end;
end;

procedure TEditor.SelIndent;
(*
  選択領域内の各行頭に半角スペース(#$20)を１個挿入する
  各行頭にある連続した空白部分（半角・全角スペース、タブ文字とタブ
  文字が展開された部分）は半角スペースに置き換えらる。行文字列の
  途中にあるタブ文字や全角スペースはそのままになる。

  矩形選択状態の場合は、選択領域左端に文字があれば同様に処理される
  が、矩形選択領域の左端がタブ文字を展開した部分か、全角空白２バイ
  ト目の場合は、そのタブ文字または全角空白も半角スペースに置き換え
  られる。

  raWrapped な行は処理しない
*)
var
  I, Sr, Er, C, Si, Li, L, T: Integer;
  S, Buf, Attr, InsertSpace: String;
  RightDownSelect: Boolean;

  function CanIndent(const S: String; Index: Integer): Boolean;
  begin
    Result := not WordWrap or
              ((ListRows(Index) <> raWrapped) and
               (ListRows(Index - 1) <> raWrapped) and
               (ExpandTabLength(#$20 + S) < WrapOption.WrapByte));
  end;

  function BoxCanIndent(const S: String; Index, Si: Integer): Boolean;
  begin
    Result := (Si <= Length(S)) and
              (not WordWrap or
               ((ListRows(Index) <> raWrapped) and
                (ListRows(Index - 1) <> raWrapped) and
                (ExpandTabLength(Copy(S, 1, Si - 1) + #$20 +
                 Copy(S, Si, Length(S))) < WrapOption.WrapByte)));
  end;

begin
  if not Selected then
    Exit;
  if SelectionMode = smLine then
  begin
    // 通常選択状態
    // start row, end row
    Sr := FSelStr.Sr;
    if FSelStr.Ec = -1 then
      Er := Max(Sr, FSelStr.Er - 1)
    else
      Er := FSelStr.Er;
    // 選択方向フラグ
    RightDownSelect := (FSelStartRow < FSelStr.Er) or
                       ((FSelStartRow = FSelStr.Er) and (FSelStartCol < FSelDraw.Ec));
    // Sc
    S := ListStr(Sr);
    if CanIndent(S, Sr) then
    begin
      T := TabbedTopSpace(S);
      InsertSpace := StringOfChar(#$20, T + 1);
      FSelDraw.Sc := Max(T + 1,
                         ExpandTabLength(InsertSpace + TrimLeftDBCS(Copy(S, 1, FSelStr.Sc))));
      Attr := StrToAttributes(InsertSpace + TrimLeftDBCS(S));
      FSelStr.Sc := FSelDraw.Sc - IncludeCharCount(Attr, caTabSpace, FSelDraw.Sc + 1);
      // 選択領域開始位置変更を反映させる
      if RightDownSelect then
      begin
        FSelStartSi := FSelStr.Sc;
        FSelStartCol := FSelDraw.Sc;
      end;
    end;
    // Ec
    S := ListStr(Er);
    if (FSelStr.Ec <> -1) and CanIndent(S, Er) then
    begin
      T := TabbedTopSpace(S);
      InsertSpace := StringOfChar(#$20, T + 1);
      FSelDraw.Ec := Max(T + 1,
                         ExpandTabLength(InsertSpace + TrimLeftDBCS(Copy(S, 1, FSelStr.Ec + 1)))); // + 1 cf UpdateSelection
      Attr := StrToAttributes(InsertSpace + TrimLeftDBCS(S));
      FSelStr.Ec := FSelDraw.Ec - IncludeCharCount(Attr, caTabSpace, FSelDraw.Ec + 1) - 1; // - 1 cf UpdateSelection
      // 選択領域開始位置変更を反映させる
      if not RightDownSelect then
      begin
        FSelStartSi := FSelStr.Ec + 1;
        FSelStartCol := FSelDraw.Ec;
      end;
    end;
    // caret
    S := ListStr(FRow);
    if (Sr <= FRow) and (FRow <= Er) and CanIndent(S, FRow) then
    begin
      Attr := StrToAttributes(S);
      Si := Min(Length(S), FCol - IncludeCharCount(Attr, caTabSpace, FCol + 1));
      T := TabbedTopSpace(S);
      C := Max(T + 1,
               ExpandTabLength(StringOfChar(#$20, T + 1) + TrimLeftDBCS(Copy(S, 1, Si))));
    end
    else
      C := FCol;
    // insert string;
    Buf := '';
    for I := Sr to Er do
    begin
      S := ListStr(I);
      if CanIndent(S, I) then
        Buf := Buf + StringOfChar(#$20, TabbedTopSpace(S) + 1) +
               TrimLeftDBCS(S)
      else
        Buf := Buf + S;
      if ListRows(I) = raCrlf then
        Buf := Buf + #13#10;
    end;
    // update & draw
    CaretBeginUpdate;
    try
      FList.UpdateList(Sr, Er - Sr + 1, Buf);
      // caret
      Col := C;
    finally
      CaretEndUpdate;
    end;
    // check CleanSelection
    if (Sr = Er) and (FSelStr.Sc = FSelStr.Ec + 1) then
      CleanSelection
    else
      // 選択領域描画データの更新
      FSelOld := FSelDraw;
  end
  else
  begin
    // 矩形選択状態

    // 矩形選択領域の左端がタブ文字を展開した部分か、全角２バイト目の
    // 場合 BoxLeftIndex はその次の文字を指す値を返して来る。
    // タブ文字を展開した部分の場合は該当タブ文字を処理対象に加える
    // 全角２バイト目の場合それが全角空白 (#$81#$40) であれば処理対象
    // に加えるという仕様

    // start row, end row
    Sr := FSelDraw.Sr;
    Er := Min(FList.Count - 1, FSelDraw.Er);
    // insert string;
    Buf := '';
    for I := Sr to Er do
    begin
      S := ListStr(I);
      Attr := StrToAttributes(S);
      L := ExpandTabLength(S); // Length(Attr); ではない
      C := FSelDraw.Sc + 1;
      Li := BoxLeftIndex(Attr, C);
      if C <= L then
        if Attr[C] = caTabSpace then
        begin
          Dec(Li);
          while Attr[C] = caTabSpace do
            Dec(C);
        end
        else
          if Attr[C] = caDBCS2 then
            if S[Li - 1] = #$40 then
            begin
              Dec(Li, 2);
              Dec(C);
            end
            else
              Inc(C);
      if BoxCanIndent(S, I, Li) then
      begin
        // 該当行先頭からの文字列ではないので TabbedTopSpace は使えない
        T := TopSpace(Copy(ExpandTab(S), C, L));
        Buf := Buf + Copy(S, 1, Li - 1) +
               StringOfChar(#$20, T + 1) +
               TrimLeftDBCS(Copy(S, Li, Length(S)));
      end
      else
        Buf := Buf + S;
      if ListRows(I) = raCrlf then
        Buf := Buf + #13#10;
    end;
    // update & draw
    CaretBeginUpdate;
    try
      FList.UpdateList(Sr, Er - Sr + 1, Buf);
    finally
      CaretEndUpdate;
    end;
  end;
end;

procedure TEditor.SelUnIndent;
(*
  選択領域内の各行頭に空白部分（半角・全角スペース、タブ文字とタブ
  文字が展開された部分）があれば、空白部分の長さ - 1 の半角スペース
  に置き換える。行文字列の途中にあるタブ文字や全角スペースはそのま
  まになる。

  矩形選択状態の場合は、選択領域左端に空白部分があれば同様に処理さ
  れるが、矩形選択領域の左端がタブ文字を展開した部分か、全角空白
  ２バイト目の場合は、そのタブ文字または全角空白も半角スペースに
  置き換えられる。

  raWrapped な行は処理しない
*)
var
  I, Sr, Er, C, Si, Li, L, T: Integer;
  S, Buf, Attr, InsertSpace: String;
  RightDownSelect: Boolean;

  function CanUnIndent(const S: String; Index: Integer): Boolean;
  begin
    Result :=
      (Length(S) > 0) and
      ((S[1] in [#$09, #$20]) or ((S[1] = #$81) and (S[2] = #$40))) and
      (ListRows(Index) <> raWrapped) and
      (ListRows(Index - 1) <> raWrapped);
  end;

  function BoxCanUnIndent(const S: String; Index, Si: Integer): Boolean;
  begin
    Result :=
      (Si <= Length(S)) and
      ((S[Si] in [#$09, #$20]) or ((S[Si] = #$81) and (S[Si + 1] = #$40))) and
      (ListRows(Index) <> raWrapped) and
      (ListRows(Index - 1) <> raWrapped);
  end;

begin
  if not Selected then
    Exit;
  if FSelectionMode = smLine then
  begin
    // 通常選択状態
    // start row, end row
    Sr := FSelStr.Sr;
    if FSelStr.Ec = -1 then
      Er := Max(Sr, FSelStr.Er - 1)
    else
      Er := FSelStr.Er;
    // 選択方向フラグ
    RightDownSelect := (FSelStartRow < FSelStr.Er) or
                       ((FSelStartRow = FSelStr.Er) and (FSelStartCol < FSelDraw.Ec));
    // Sc
    S := ListStr(Sr);
    if CanUnIndent(S, Sr) then
    begin
      T := TabbedTopSpace(S);
      InsertSpace := StringOfChar(#$20, T - 1);
      FSelDraw.Sc := Max(T - 1,
                         ExpandTabLength(InsertSpace + TrimLeftDBCS(Copy(S, 1, FSelStr.Sc))));
      Attr := StrToAttributes(InsertSpace + TrimLeftDBCS(S));
      FSelStr.Sc := FSelDraw.Sc - IncludeCharCount(Attr, caTabSpace, FSelDraw.Sc + 1);
      // 選択領域開始位置変更を反映させる
      if RightDownSelect then
      begin
        FSelStartSi := FSelStr.Sc;
        FSelStartCol := FSelDraw.Sc;
      end;
    end;
    // Ec
    S := ListStr(Er);
    if (FSelStr.Ec <> -1) and CanUnIndent(S, Er) then
    begin
      T := TabbedTopSpace(S);
      InsertSpace := StringOfChar(#$20, T - 1);
      FSelDraw.Ec := Max(T - 1,
                         ExpandTabLength(InsertSpace + TrimLeftDBCS(Copy(S, 1, FSelStr.Ec + 1)))); // + 1 cf UpdateSelection
      Attr := StrToAttributes(InsertSpace + TrimLeftDBCS(S));
      FSelStr.Ec := FSelDraw.Ec - IncludeCharCount(Attr, caTabSpace, FSelDraw.Ec + 1) - 1; // - 1 cf UpdateSelection
      // 選択領域開始位置変更を反映させる
      if not RightDownSelect then
      begin
        FSelStartSi := FSelStr.Ec + 1;
        FSelStartCol := FSelDraw.Ec;
      end;
    end;
    // caret
    S := ListStr(FRow);
    if (Sr <= FRow) and (FRow <= Er) and CanUnIndent(S, FRow) then
    begin
      Attr := StrToAttributes(S);
      Si := Min(Length(S), FCol - IncludeCharCount(Attr, caTabSpace, FCol + 1));
      T := TabbedTopSpace(S);
      C := Max(T - 1,
               ExpandTabLength(StringOfChar(#$20, T - 1) + TrimLeftDBCS(Copy(S, 1, Si))));
    end
    else
      C := FCol;
    // insert string;
    Buf := '';
    for I := Sr to Er do
    begin
      S := ListStr(I);
      if CanUnIndent(S, I) then
        Buf := Buf + StringOfChar(#$20, TabbedTopSpace(S) - 1) +
               TrimLeftDBCS(S)
      else
        Buf := Buf + S;
      if ListRows(I) = raCrlf then
        Buf := Buf + #13#10;
    end;
    // update & draw
    CaretBeginUpdate;
    try
      FList.UpdateList(Sr, Er - Sr + 1, Buf);
      // caret
      Col := C;
    finally
      CaretEndUpdate;
    end;
    // check CleanSelection
    if (Sr = Er) and (FSelStr.Sc = FSelStr.Ec + 1) then
      CleanSelection
    else
      // 選択領域描画データの更新
      FSelOld := FSelDraw;
  end
  else
  begin
    // 矩形選択状態

    // 矩形選択領域の左端がタブ文字を展開した部分か、全角２バイト目の
    // 場合 BoxLeftIndex はその次の文字を指す値を返して来る。
    // タブ文字を展開した部分の場合は該当タブ文字を処理対象に加える
    // 全角２バイト目の場合それが全角空白 (#$81#$40) であれば処理対象
    // に加えるという仕様

    // start row, end row
    Sr := FSelDraw.Sr;
    Er := Min(FList.Count - 1, FSelDraw.Er);
    // insert string;
    Buf := '';
    for I := Sr to Er do
    begin
      S := ListStr(I);
      Attr := StrToAttributes(S);
      L := ExpandTabLength(S); // Length(Attr); ではない
      C := FSelDraw.Sc + 1;
      Li := BoxLeftIndex(Attr, C);
      if C <= L then
        if Attr[C] = caTabSpace then
        begin
          Dec(Li);
          while Attr[C] = caTabSpace do
            Dec(C);
        end
        else
          if Attr[C] = caDBCS2 then
            if S[Li - 1] = #$40 then
            begin
              Dec(Li, 2);
              Dec(C);
            end
            else
              Inc(C);
      if BoxCanUnIndent(S, I, Li) then
      begin
        // 該当行先頭からの文字列ではないので TabbedTopSpace は使えない
        T := TopSpace(Copy(ExpandTab(S), C, L));
        Buf := Buf + Copy(S, 1, Li - 1) +
               StringOfChar(#$20, T - 1) +
               TrimLeftDBCS(Copy(S, Li, Length(S)));
      end
      else
        Buf := Buf + S;
      if ListRows(I) = raCrlf then
        Buf := Buf + #13#10;
    end;
    // update & draw
    CaretBeginUpdate;
    try
      FList.UpdateList(Sr, Er - Sr + 1, Buf);
    finally
      CaretEndUpdate;
    end;
  end;
end;

procedure TEditor.SelTabIndent;
(*
  選択領域内の各行頭にタブ (#$09) を１個挿入する
  WordWrap 時は、raWrapped な行とタブ文字を挿入することによって
  折り返し表示されてしまう行は処理しない
  矩形選択状態の場合は、選択領域左端にタブを挿入する
*)
var
  I, Sr, Er, C, Li: Integer;
  S, Buf, Attr: String;
  RightDownSelect: Boolean;

  function CanIndent(const ExpandedStr: String; Index: Integer): Boolean;
  begin
    Result := not WordWrap or
              ((ListRows(Index) <> raWrapped) and
               (ListRows(Index - 1) <> raWrapped) and
               (Length(ExpandedStr) + FCaret.FTabSpaceCount < WrapOption.WrapByte));
  end;

  function BoxCanIndent(const S: String; Index, Si: Integer): Boolean;
  begin
    Result := (Si <= Length(S)) and
              (not WordWrap or
               ((ListRows(Index) <> raWrapped) and
                (ListRows(Index - 1) <> raWrapped) and
                (ExpandTabLength(Copy(S, 1, Si - 1) + #$09 +
                 Copy(S, Si, Length(S))) < WrapOption.WrapByte)));
  end;

begin
  if not Selected then
    Exit;
  if SelectionMode = smLine then
  begin
    // 通常選択状態
    // start row, end row
    Sr := FSelStr.Sr;
    if FSelStr.Ec = -1 then
      Er := Max(Sr, FSelStr.Er - 1)
    else
      Er := FSelStr.Er;
    // 選択方向フラグ
    RightDownSelect := (FSelStartRow < FSelStr.Er) or
                       ((FSelStartRow = FSelStr.Er) and (FSelStartCol < FSelDraw.Ec));
    // Sc
    S := ListStr(Sr);
    Buf := ExpandTab(S);
    if CanIndent(Buf, Sr) then
    begin
      FSelDraw.Sc := Max(TopSpace(Buf) + FCaret.FTabSpaceCount,
                         FSelDraw.Sc + FCaret.FTabSpaceCount);
      Attr := StrToAttributes(#$09 + S);
      FSelStr.Sc := FSelDraw.Sc - IncludeCharCount(Attr, caTabSpace, FSelDraw.Sc + 1);
      // 選択領域開始位置変更を反映させる
      if RightDownSelect then
      begin
        FSelStartSi := FSelStr.Sc;
        FSelStartCol := FSelDraw.Sc;
      end;
    end;
    // Ec
    S := ListStr(Er);
    Buf := ExpandTab(S);
    if (FSelStr.Ec <> -1) and CanIndent(Buf, Er) then
    begin
      FSelDraw.Ec := Max(TopSpace(Buf) + FCaret.FTabSpaceCount,
                         FSelDraw.Ec + FCaret.FTabSpaceCount);
      Attr := StrToAttributes(#$09 + S);
      FSelStr.Ec := FSelDraw.Ec - IncludeCharCount(Attr, caTabSpace, FSelDraw.Ec + 1) - 1; // - 1 cf UpdateSelection
      // 選択領域開始位置変更を反映させる
      if not RightDownSelect then
      begin
        FSelStartSi := FSelStr.Ec + 1;
        FSelStartCol := FSelDraw.Ec;
      end;
    end;
    // caret
    S := ListStr(FRow);
    Buf := ExpandTab(S);
    if (Sr <= FRow) and (FRow <= Er) and CanIndent(Buf, FRow) then
      C := Max(TopSpace(Buf) + FCaret.FTabSpaceCount,
               FCol + FCaret.FTabSpaceCount)
    else
      C := FCol;
    // insert string;
    Buf := '';
    for I := Sr to Er do
    begin
      S := ListStr(I);
      if CanIndent(ExpandTab(S), I) then
        Buf := Buf + #$09;
      Buf := Buf + S;
      if ListRows(I) = raCrlf then
        Buf := Buf + #13#10;
    end;
    // update & draw
    CaretBeginUpdate;
    try
      FList.UpdateList(Sr, Er - Sr + 1, Buf);
      // caret
      Col := C;
    finally
      CaretEndUpdate;
    end;
    // check CleanSelection
    if (Sr = Er) and (FSelStr.Sc = FSelStr.Ec + 1) then
      CleanSelection
    else
      // 選択領域描画データの更新
      FSelOld := FSelDraw;
  end
  else
  begin
    // 矩形選択状態
    // start row, end row
    Sr := FSelDraw.Sr;
    Er := Min(FList.Count - 1, FSelDraw.Er);
    // insert string;
    Buf := '';
    for I := Sr to Er do
    begin
      S := ListStr(I);
      Li := BoxLeftIndex(StrToAttributes(S), FSelDraw.Sc + 1);
      if BoxCanIndent(S, I, Li) then
        Buf := Buf + Copy(S, 1, Li - 1) + #$09 + Copy(S, Li, Length(S))
      else
        Buf := Buf + S;
      if ListRows(I) = raCrlf then
        Buf := Buf + #13#10;
    end;
    // update & draw
    CaretBeginUpdate;
    try
      FList.UpdateList(Sr, Er - Sr + 1, Buf);
    finally
      CaretEndUpdate;
    end;
  end;
end;

procedure TEditor.SelTabUnIndent;
(*
  選択領域内の各行頭にタブ文字 (#$09) があればそれを１個削除する
  WordWrap 時は、raWrapped な行は処理しない
  矩形選択状態の場合は、選択領域左端のタブを削除する
*)
var
  I, Sr, Er, C, Li: Integer;
  S, Buf, Attr: String;
  RightDownSelect: Boolean;

  function CanUnIndent(const S: String; Index: Integer): Boolean;
  begin
    Result := (Length(S) > 0) and (S[1] = #$09) and
              (ListRows(Index) <> raWrapped) and
              (ListRows(Index - 1) <> raWrapped);
  end;

  function BoxCanUnIndent(const S: String; Index, Si: Integer): Boolean;
  begin
    Result := (Si <= Length(S)) and (S[Si] = #$09) and
              (ListRows(Index) <> raWrapped) and
              (ListRows(Index - 1) <> raWrapped);
  end;

begin
  if not Selected then
    Exit;
  if FSelectionMode = smLine then
  begin
    // 通常選択状態
    // start row, end row
    Sr := FSelStr.Sr;
    if FSelStr.Ec = -1 then
      Er := Max(Sr, FSelStr.Er - 1)
    else
      Er := FSelStr.Er;
    // 選択方向フラグ
    RightDownSelect := (FSelStartRow < FSelStr.Er) or
                       ((FSelStartRow = FSelStr.Er) and (FSelStartCol < FSelDraw.Ec));
    // Sc
    S := ListStr(Sr);
    if CanUnIndent(S, Sr) then
    begin
      FSelDraw.Sc := Max(TabbedTopSpace(S) - FCaret.FTabSpaceCount,
                         FSelDraw.Sc - FCaret.FTabSpaceCount);
      Attr := StrToAttributes(Copy(S, 2, Length(S)));
      FSelStr.Sc := FSelDraw.Sc - IncludeCharCount(Attr, caTabSpace, FSelDraw.Sc + 1);
      // 選択領域開始位置変更を反映させる
      if RightDownSelect then
      begin
        FSelStartSi := FSelStr.Sc;
        FSelStartCol := FSelDraw.Sc;
      end;
    end;
    // Ec
    S := ListStr(Er);
    if (FSelStr.Ec <> -1) and CanUnIndent(S, Er) then
    begin
      FSelDraw.Ec := Max(TabbedTopSpace(S) - FCaret.FTabSpaceCount,
                         FSelDraw.Ec - FCaret.FTabSpaceCount);
      Attr := StrToAttributes(Copy(S, 2, Length(S)));
      FSelStr.Ec := FSelDraw.Ec - IncludeCharCount(Attr, caTabSpace, FSelDraw.Ec + 1) - 1; // - 1 cf UpdateSelection
      // 選択領域開始位置変更を反映させる
      if not RightDownSelect then
      begin
        FSelStartSi := FSelStr.Ec + 1;
        FSelStartCol := FSelDraw.Ec;
      end;
    end;
    // caret
    S := ListStr(FRow);
    if (Sr <= FRow) and (FRow <= Er) and CanUnIndent(S, FRow) then
      C := Max(TabbedTopSpace(S) - FCaret.FTabSpaceCount,
               FCol - FCaret.FTabSpaceCount)
    else
      C := FCol;
    // insert string;
    Buf := '';
    for I := Sr to Er do
    begin
      S := ListStr(I);
      if CanUnIndent(S, I) then
        Buf := Buf + Copy(S, 2, Length(S))
      else
        Buf := Buf + S;
      if ListRows(I) = raCrlf then
        Buf := Buf + #13#10;
    end;
    // update & draw
    CaretBeginUpdate;
    try
      FList.UpdateList(Sr, Er - Sr + 1, Buf);
      // caret
      Col := C;
    finally
      CaretEndUpdate;
    end;
    // check CleanSelection
    if (Sr = Er) and (FSelStr.Sc = FSelStr.Ec + 1) then
      CleanSelection
    else
      // 選択領域描画データの更新
      FSelOld := FSelDraw;
  end
  else
  begin
    // 矩形選択状態
    // start row, end row
    Sr := FSelDraw.Sr;
    Er := Min(FList.Count - 1, FSelDraw.Er);
    // insert string;
    Buf := '';
    for I := Sr to Er do
    begin
      S := ListStr(I);
      Li := BoxLeftIndex(StrToAttributes(S), FSelDraw.Sc + 1);
      if BoxCanUnIndent(S, I, Li) then
        Buf := Buf + Copy(S, 1, Li - 1) + Copy(S, Li + 1, Length(S))
      else
        Buf := Buf + S;
      if ListRows(I) = raCrlf then
        Buf := Buf + #13#10;
    end;
    // update & draw
    CaretBeginUpdate;
    try
      FList.UpdateList(Sr, Er - Sr + 1, Buf);
    finally
      CaretEndUpdate;
    end;
  end;
end;

procedure TEditor.SetSelTextBox(Buffer: PChar);
(*
  キャレット位置に文字列を矩形に挿入する。
*)
var
  Buf, S, Attr: String;
  Rs, Re, Ri, Ci, Li: Integer;
  I, C, Idx, L: Integer;
  Source: TStringList;
  Dest: TEditorStringList;
begin
  if FReadOnly then
    Exit;
  Buf := String(Buffer);
  if Length(Buf) = 0 then
  begin
    if Selected then
      DeleteSelection;
    Exit;
  end;
  Source := TStringList.Create;
  try
    Source.Text := Buf;
    if Selected then
    begin
      Rs := FSelStr.Sr;
      Re := Min(FList.Count - 1, Max(Rs + Source.Count - 1, FSelStr.Er));
      Ri := FSelStr.Er + 1;
      Ci := FSelDraw.Sc + 1;
    end
    else
    begin
      Rs := FRow;
      Re := Min(FList.Count - 1, FRow + Source.Count - 1);
      Ri := FRow;
      Ci := FCol + 1;
    end;
    C := Ci + Length(Source[Source.Count - 1]);

    // 領域を置き換える文字列を作成
    Dest := TEditorStringList.Create;
    try
      // Source の各行を対応する行の Ci に挿入するため
      // Source.Count - 1 行のデータを FList[Ri] から Dest に取得する
      // Ri が FList.Count - 1 を越える場合は、Dest に空白とSource[n]
      // を追加する
      // Dest[0..Count - 1] で FList を更新する。
      if Selected then
        SelDeletedList(Dest);
      for I := 0 to Source.Count - 1 do
      begin
        if I <= Dest.Count - 1 then
        begin
          // Dest[I] に Source[I] を挿入
          S := Dest[I];
          L := Length(S);
          Li := Integer(Dest.Datas[I]);
          if Li <= L then
          begin
            Insert(Source[I], S, Li);
            Dest[I] := S;
          end
          else
            Dest[I] := S + StringOfChar(#$20, Li - L - 1) + Source[I];
        end
        else
        begin
          // Dest に追加
          if Ri <= FList.Count - 1 then
          begin
            // FList から取得
            S := FList[Ri];
            L := Length(S);
            Attr := StrToAttributes(S);
            Li := BoxLeftIndex(Attr, Ci);
            if Li <= L then
              Insert(Source[I], S, Li)
            else
              S := S + StringOfChar(#$20, Li - L - 1) + Source[I];
            Idx := Dest.Add(S);
            Dest.Rows[Idx] := ListRows(Ri);
            Inc(Ri);
          end
          else
          begin
            // 空白＋ Source[I] を追加
            Dest.Add(StringOfChar(#$20, Ci - 1) + Source[I]);
            Li := Ci;
          end;
        end;
        // キャレット位置
        C := Li - 1 + Length(Source[I]);
      end;
      // 矩形挿入されたデータが raEof になることは無いという仕様
      for I := 0 to Dest.Count - 1 do
        if Dest.Rows[I] = raEof then
          Dest.Rows[I] := raCrlf;
      // 更新する文字列を作成
      S := ListToStr(Dest);
      // put & caret
      CaretBeginUpdate;
      UnderlineBeginUpdate;
      try
        if SelectedData then
          CleanSelection;
        if Rs > FList.Count - 1 then
          FList.UpdateList(Rs, 0, S)
        else
          if Re <= FList.Count - 1 then
            FList.UpdateList(Rs, Re - Rs + 1, S)
          else
            FList.UpdateList(Rs, Re - Rs, S);
        Row := Rs + Source.Count - 1;
        Col := C;
      finally
        UnderlineEndUpdate;
        CaretEndUpdate;
      end;
    finally
      Dest.Free;
    end;
  finally
    Source.Free;
  end;
end;

procedure TEditor.SetSelTextBuf(Buffer: PChar);
(*
  FRow のキャレットより前 + Buffer + キャレットより後ろの文字列を
  作成し、FRow を置き換える
  選択状態の場合は、選択領域の前 + Buffer + 領域の後ろの文字列を
  作成する
  矩形選択状態ではさらに、選択文字列を矩形に切り取った文字列を
  作成する
*)
var
  L, Si, Rs, Re, Ri, IncSelIndex, SelIndex: Integer;
  Buf, S, FS, BS, Attr: String;
  UpdateFlag: Boolean;
  List: TEditorStringList;
begin
  if FReadOnly then
    Exit;
  Buf := String(Buffer);
  IncSelIndex := Length(Buf);
  if IncSelIndex = 0 then
  begin
    if Selected then
      DeleteSelection
    else
      if SelectedData then
        CleanSelection;
    Exit;
  end;

  if Selected then
  with FSelStr do
  begin
    Ri := Max(FList.RowStart(Sr), Sr - 1);
    // キャレット位置 FSelStr.Sc ではないことに注意
    SelIndex := GetSelIndex(Ri, FSelDraw.Sr, FSelDraw.Sc);
    Rs := Sr;
    Re := Er;
    // 置き換える文字列を作成
    S := '';
    List := TEditorStringList.Create;
    try
      SelDeletedList(List);
      if List.Count > 0 then
      begin
        List[0] := Copy(List[0], 1, Integer(List.Datas[0]) - 1) + Buf +
                   Copy(List[0], Integer(List.Datas[0]), Length(List[0]));
        S := ListToStr(List);
      end
      else
        S := Buf;
    finally
      List.Free;
    end;
  end
  else
  begin
    Ri := Max(FList.RowStart(FRow), FRow - 1);
    SelIndex := GetSelIndex(Ri, FRow, FCol);
    Rs := FRow;
    Re := FRow;
    // 置き換える文字列を作成。
    // FRow, FCol の文字インデックス
    S := ListStr(FRow);
    L := Length(S);
    Attr := StrToAttributes(S);
    // Si は０ベース
    Si := FCol - IncludeCharCount(Attr, caTabSpace, FCol + 1);
    // FRow のキャレットより前
    if L < Si then
      FS := S + StringOfChar(#$20, Si - L)
    else
      FS := Copy(S, 1, Si);
    // FRow のキャレットより後
    BS := Copy(S, Si + 1, Length(S));
    FList.CheckCrlf(Re, BS);
    // 挿入する文字列の完成
    S := FS + Buf + BS;
  end;
  // put & caret
  UpdateFlag := Pos(#13, S) > 0;
  if UpdateFlag then
  begin
    CaretBeginUpdate;
    UnderlineBeginUpdate;
  end;
  try
    if SelectedData then
      CleanSelection;
    if Rs > FList.Count - 1 then
      FList.UpdateList(Rs, 0, S)
    else
      if Re <= FList.Count - 1 then
        FList.UpdateList(Rs, Re - Rs + 1, S)
      else
        FList.UpdateList(Rs, Re - Rs, S);
    SetSelIndex(Ri, SelIndex + IncSelIndex);
  finally
    if UpdateFlag then
    begin
      UnderlineEndUpdate;
      CaretEndUpdate;
    end;
  end;
end;

function TEditor.StrInfoFromPos(Pos: TPoint): TEditorStrInfo;
(*
  指定されたポイントから FLines の行番号とその行文字列内での文字
  インデックスを返す。
  行番号、文字インデックスは共に０ベースであることに注意
  ワードラップ、全角文字、タブには対応していない。
*)
var
  R, C: Integer;
begin
  Result.Line := -1;
  Result.CharIndex := -1;
  // 他人の OnMouseMove ハンドラに入った場合、FFontWidth が 0 の場合があるので
  if (FList.Count = 0) or (FFontWidth = 0) then
    Exit;
  PosToRowCol(Pos.X, Pos.Y, R, C, True);
  if (R < 0) or (FList.Count < R) then
    Exit;
  // Lines に変換
  Result.Line := RowToLines(R);
  Result.CharIndex := ColToChar(R, C);
end;

function TEditor.StrToAttributes(const S: String): String;
(*
  S を構成する各文字の文字属性を表現する文字列を返す

  caEof        = #$30; {'0'}
  caAnk        = #$31; {'1'}
  caDelimiter  = #$32; {'2'}
  caTabSpace   = #$33; {'3'}
  caDBCS1      = #$34; {'4'}
  caDBCS2      = #$35; {'5'}

  返値の長さが MaxLineCharacter 以上になった時点で処理を中断する。
  そこが全角１バイト目の場合、返値の長さは MaxLineCharacter + 1
  になる。タブ文字の場合は、それ以上になる場合もある。
  WordWrap = True の場合は、WrapByte + 3 以上になった時点で中断する。
  + 3 は、WordWrap 時の文字列長の上限値。cf StrToWrapList
*)
var
  L, I, B, T, LL: Integer;
begin
  Result := '';
  L := Length(S);
  I := 1;
  B := FList.FWrapOption.FWrapByte;
  T := FCaret.FTabSpaceCount;
  if WordWrap then
    LL := B + 3
  else
    LL := MaxLineCharacter;
  while I <= L do
  begin
    if S[I] in LeadBytes then
    begin
      Result := Result + '45'; // caDBCS1, caDBCS2
      Inc(I);
    end
    else
    begin
      if S[I] in FDelimiters then
        Result := Result + '2' // caDelimiter
      else
        Result := Result + '1'; // caAnk
      if S[I] = #$09 then
        if not WordWrap then
          Result := Result + StringOfChar('3', // caTabSpace
            T - ((Length(Result) - 1) mod T + 1))
        else
          Result := Result +
            StringOfChar('3', // caTabSpace
              Min(T - ((Length(Result) - 1) mod T + 1),
                  B - ((Length(Result) - 1) mod B + 1)
              )
            );
    end;
    if Length(Result) >= LL then
      Exit;
    Inc(I);
  end;
end;

function TEditor.TabbedTopSpace(const S: String): Integer;
(*
  文字列 S の前の部分のスペース数を返す。
  全角スペースもカウントする
  タブ文字にも対応する。
  S = '' の時は -1 を返す
*)
var
  I, L, B, T: Integer;
begin
  Result := -1;
  if S = '' then
    Exit;
  Result := 0;
  L := Length(S);
  I := 1;
  B := FList.FWrapOption.FWrapByte;
  T := FCaret.FTabSpaceCount;
  while I <= L do
  begin
    if (S[I] = #$81) and (S[I + 1] = #$40) then
    begin
      Inc(Result, 2);
      Inc(I);
    end
    else
      if S[I] = #$20 then
        Inc(Result)
      else
        if S[I] = #9 then
          if not WordWrap then
            Inc(Result, T - (Result mod T))
          else
            Inc(Result, Min(T - (Result mod T), B - Result mod B))
        else
          Exit;
    Inc(I);
  end;
end;

procedure TEditor.Undo;
begin
  if SelectedData then
    CleanSelection;
  FList.Undo;
end;


// RowMark 関連 //////////////////////////////////

(*
  #RowMarks
  以下のメソッドでは、文字列の更新に合わせて、RowMarks データも
  更新している。
    TEditorScreenStrings
      ChangeList
      UpdateList
      StretchLines
      WrapLines
    TEditorUndoObj
      Redo
      Undo
  また、設定されている RowMarks を保持して、ポップアップメニューに反映
  させるため、TEditorScreenStrings に FValidRowMarks: TRowMarks 変数と
  IncludeRowMarks, ExcludeRowMarks メソッドを用意している。
  上記メソッド群のうち、TEditorScreenStrings.DeleteList を利用するメソ
  ッドと TEditor.SetListRowMarks メソッドで FValidRowMarks データを
  更新している。
*)

procedure TEditor.PutRowMark(Index: Integer; Mark: TRowMark);
var
  I: Integer;
begin
  if Mark in [rm0..rm9] then
    for I := 0 to FList.Count - 1 do
      if Mark in FList.RowMarks[I] then
      begin
        // ListRowMarks プロパティに代入し再描画させる
        ListRowMarks[I] := FList.RowMarks[I] - [Mark];
        Break;
      end;
  if (Index >= 0) and (Index <= FList.Count - 1) then
    ListRowMarks[Index] := FList.RowMarks[Index] + [Mark];
end;

procedure TEditor.DeleteRowMark(Index: Integer; Mark: TRowMark);
begin
  if (Index >= 0) and (Index <= FList.Count - 1) then
    ListRowMarks[Index] := FList.RowMarks[Index] - [Mark];
end;

procedure TEditor.GotoRowMark(Mark: TRowMark);
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    if Mark in FList.RowMarks[I] then
    begin
      if (I < TopRow) or (I > TopRow + RowCount - 1) then
        TopRow := I - RowCount div 2;
      Row := I;
      Break;
    end;
end;

end.

