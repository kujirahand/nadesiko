(*********************************************************************

  TEditor version 2.50

  start  1998/07/05
  update 2004/10/23

  Copyright (c) 1998,2004 �{�c���F <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  key words B-)
  $VScrollMax ......... �c�X�N���[���̏���ɂ��āi�R�J���j
  $OriginBase ......... Leftbar, Ruler �̌������镔���ɂ���
  $DotUnderline ....... fsUnderline ����_�j���ŕ`�悵�Ȃ��ꍇ�ɂ���

  comments
  #MaxLineCharacter ... �P�C�O�O�O�����ɂ���
  #ScreenStrings ...... ������̍X�V�Aundo, redo, �ĕ`��̎d�g��
  #UndoObj ............ TEditorUndoObj �I�u�W�F�N�g�̓���ɂ���
  #IME ................ SetImeComposition IME �E�B���h�D�̈ړ��ɂ���
  #Scroll ............. ScrollWindowEx �ɂ���
  #Caret .............. �`��ƃL�����b�g�ɂ���
  #Leftbar, #Ruler .... Leftbar, Ruler �����p����r�b�g�}�b�v�ɂ���
  #Drawing ............ �`��ɂ���
  #Selection .......... �I��̈�̏����ɂ���
  #SelectionMove ...... �I��̈�̈ړ��ɂ���
  #WM_IME_COMOISITION . IME ������擾�ɂ���
  #RowMarks ........... Imagebar �ɕ\������ RowMarks �̈����ɂ���
  #HitSelLength ....... ������v������̕`��ɂ���
  #HScroll ............ �X�N���[���{�^���ɂ�鉡�X�N���[����
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
    FAutoCursor: Boolean;                // TEditor ���}�E�X�J�[�\����ύX���邵�Ȃ��t���O
    FAutoIndent: Boolean;                // �I�[�g�C���f���g���邵�Ȃ��t���O
    FBackSpaceUnIndent: Boolean;         // �o�b�N�X�y�[�X�A���C���f���g���邵�Ȃ��t���O
    FCursors: TEditorCursors;            // �I��̈���ړ�����ۂ̃}�E�X�J�[�\���Q
    FFreeCaret: Boolean;                 // �t���[�L�����b�g�t���O
    FFreeRow: Boolean;                   // FreeCaret = False �̎��A�����iVK_UP, VK_DOWN�j�L�[���������������t���[�L�����b�g�ɂȂ邼�t���O
    FInTab: Boolean;                     // �^�u�̒����ړ��o����o���Ȃ��t���O
    FKeepCaret: Boolean;                 // not FreeCaret ���ɃL�����b�g�ʒu���L�����邵�Ȃ��t���O
    FLockScroll: Boolean;                // �X�N���[���o�[�ɂ��c�X�N���[�����ɃL�����b�g���Œ肷�邵�Ȃ��t���O
    FNextLine: Boolean;                  // �s���A�s�����玟�̍s�փL�����b�g���ړ����邵�Ȃ��t���O
    FPrevSpaceIndent: Boolean;           // ���ݍs�̍s���ɋ󔒂������ꍇ�ł��A�s��k���ċ󔒐����擾���C���f���g���邵�Ȃ��t���O
    FRowSelect: Boolean;                 // ���t�g�}�[�W�����Ń}�E�X�̍��{�^���������������A���̍s��I�����邵�Ȃ��t���O
    FSelDragMode: TDragMode;             // dmManual, dmAutomatic
    FSelMove: Boolean;                   // �}�E�X�őI��̈���ړ����邵�Ȃ��t���O
    FSoftTab: Boolean;                   // �\�t�g�^�u�t���O
    FStyle: TEditorCaretStyle;           // �L�����b�g�X�^�C�� csDefault |, csBrief _
    FTabIndent: Boolean;                 // �^�u�C���f���g
    FTabSpaceCount: Integer;             // �^�u�̓W�J��
    FTokenEndStop: Boolean;              // Ctrl + VK_LEFT, Ctrl + VK_RIGHT ���͎��Ƀg�[�N���̏I�[�Ŏ~�܂�~�܂�Ȃ��B
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
    FCharacter: Integer;                 // �����ԃ}�[�W�� 0..MarginLimit
    FLeft: Integer;                      // ���t�g�}�[�W�� 0..MarginLimit
    FLine: Integer;                      // �s�ԃ}�[�W��   0..MarginLimit
    FTop: Integer;                       // �g�b�v�}�[�W�� 0..MarginLimit
    FUnderline: Integer;                 // �A���_�[���C���}�[�W�� 0..1
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
    FColor: TColor;                      // �\���F
    FVisible: Boolean;                   // �\�����邵�Ȃ��t���O
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
    FEofMark: TEditorMark;               // [EOF] �}�[�N
    FRetMark: TEditorMark;               // ���s�}�[�N
    FWrapMark: TEditorMark;              // �܂�Ԃ��}�[�N
    FHideMark: TEditorMark;              // MaxLineCharacter ���z���镶���񂪂��邱�Ƃ�\������}�[�N
    FUnderline: TEditorMark;             // �A���_�[���C��
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
    FBkColor: TColor;                    // �w�i�F
    FColor: TColor;                      // �O�i�F
    FEdge: Boolean;                      // �����
    FGaugeRange: Integer;                // 8, 10
    FMarkColor: TColor;                  // ���[���[�}�[�J�[�F
    FVisible: Boolean;                   // �\�����邵�Ȃ��t���O
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
    FBkColor: TColor;                       // �w�i�F
    FColor: TColor;                         // �O�i�F
    FColumn: Integer;                       // ���� 1..8
    FEdge: Boolean;                         // �����
    FLeftMargin: Integer;                   // ���}�[�W�� 0..MarginLimit
    FRightMargin: Integer;                  // �E�}�[�W�� 0..MarginLimit
    FShowNumber: Boolean;                   // �s�ԍ��\���t���O
    FShowNumberMode: TEditorShowNumberMode; // nmRow, nmLine
    FVisible: Boolean;                      // �\�����邵�Ȃ��t���O
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
    procedure StrToWrapList(const S: String; List: TEditorStringList); virtual; // S �� FWrapByte �ŕ������AList �Ɋi�[����
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
    FFollowRetMark: Boolean;     // ���s�}�[�N���Ԃ牺����
    FFollowPunctuation: Boolean; // ��Ǔ_���Ԃ牺����
    FFollowStr: String;          // �s���֑����� '�A�B�C�D�E�H�I�J�K�R�S�T�U�X�[�j�n�p�v�x!),.:;?]}�������'
    FLeading: Boolean;           // �ǂ��o���������s��
    FLeadStr: String;            // �s���֑����� '�i�m�o�u�w([{�'
    FPunctuationStr: String;     // ��Ǔ_ '�A�B�C�D,.��';
    FWordBreak: Boolean;         // �p���i���p�����jWordWrap
    FWrapByte: Integer;          // �܂�Ԃ������� 20..250
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
    // �v���p�e�B�f�[�^�t�B�[���h
    FBorderStyle: TBorderStyle;
    FCaret: TEditorCaret;                   // TEditorCaret �I�u�W�F�N�g
    FCol: Integer;                          // 0 base �̌��݂̌��ʒu�i�`��p�j
    FColCount: Integer;                     // ��ʂɕ\���\�Ȍ���
    FFontWidth: integer;                    // ������ FFontWidth := TM.tmAveCharWidth + FCharacterMargin; �Őݒ肳��Ă���
    FCursorState: TEditorMouseCursorState;  // �}�E�X�J�[�\���̏�Ԃ�\������ mcClient, mcLeftMargin, mcTopMargin, mcInSel, mcDragging, mcDraggingCopy
    FDelimiters: TCharSet;                  // �������܂�Ԃ��\�����鏈�����邽�߂̋�؂蕶���W��
    FFontHeight: integer;                   // ������ FFontHeight := TM.tmHeight + TM.tmExternalLeading; �Őݒ肳��Ă���
    FFountain: TFountain;                   // Fountain �v���p�e�B�f�[�^�t�B�[���h TFountain �̎��̂ւ̃|�C���^
    FHitSelLength: Integer;                 // ������v������
    FHitStyle: TEditorHitStyle;             // ������v������`��X�^�C��
    FImagebar: TEditorImagebar;             // �C���[�W�\���I�v�V����
    FImageDigits: TImageList;               // �W�����v�}�[�N�p�C���[�W���X�g�i�P�O�A�C�e���j
    FImageMarks: TImageList;                // �}�[�N�p�C���[�W���X�g�i�ő�U�A�C�e���j
    FLeftbar: TEditorLeftbar;               // �s�ԍ��\���I�v�V����
    FLines: TStrings;                       // ������ TEditorStrings ���ւ̃C���^�[�t�F�[�X�Ƃ��ċ@�\����
    FMarks: TEditorMarks;                   // TEditorMarks �I�u�W�F�N�g
    FMargin: TEditorMargin;                 // TEditorMargin �I�u�W�F�N�g
    FModified: Boolean;
    FOverWrite: Boolean;                    // �㏑�����[�h
    FReadOnly: Boolean;
    FRow: Integer;                          // 0 base �̌��ݍs�ʒu
    FRowCount: Integer;                     // ��ʂɕ\���o����s��
    FRuler: TEditorRuler;                   // ���[���[�\���I�v�V����
    FScrollBars: TScrollStyle;
    FSpeed: TEditorSpeed;                   // �X�s�[�h
    FTopCol: Integer;                       // ���ݕ\������Ă��鍶�[�� Col �l �O�x�[�X
    FTopRow: Integer;                       // ���ݕ\������Ă����[�� Row �l �O�x�[�X
    FView: TEditorViewInfo;                 // TEditorViewInfo �I�u�W�F�N�g
    FWantReturns: Boolean;                  // VK_RETURN ����͂��邵�Ȃ��t���O default = True;
    FWantTabs: Boolean;                     // �^�u��������͂��邵�Ȃ��t���O default = True;

    // �v���p�e�B�f�[�^�t�B�[���h�i�I��̈�j
    FSelDraw: TSelectedPosition;            // �I��̈�i�`��p�j
    FSelectionMode: TEditorSelectionMode;   // smLine, smBox
    FSelStr: TSelectedPosition;             // �I��̈�i������p�j

    // �C�x���g�n���h��
    FOnCaretMoved: TNotifyEvent;
    FOnChange: TNotifyEvent;
    FOnDrawLine: TDrawLineEvent;
    FOnSelectionChange: TSelectionChangeEvent;
    FOnSelectionModeChange: TNotifyEvent;
    FOnTopColChange: TNotifyEvent;
    FOnTopRowChange: TNotifyEvent;

    // �v���p�e�B�̃A�N�Z�X���\�b�h
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

    // ���b�Z�[�W�n���h��
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
    // �f�[�^
    FCaretNoMove: Boolean;                  // Row, Col ���ݒ肳��Ă��L�����b�g���ړ����Ȃ��t���O WMLButtonDown �Ŏg�p
    FCaretUpdateCount: Integer;             // CaretBeginUpdate ���ꂽ��
    FCaretShowing: Boolean;                 // �L�����b�g���o�Ă�t���O
    FColBuf: Integer;                       // �L�����ꂽ�L�����b�g�ʒu
    FColKeeping: Boolean;                   // �L�����b�g�ʒu���L������Ă��܂��t���O
    FCompositionCanceled: Boolean;          // SetImeCompositionWindow ���L�����Z�����ꂽ���Ƃ�ێ�����t���O�BMoveCaret, SetTopRow, SetTopCol �Őݒ肳��AWM_KEYUP, WM_CHAR �Ŕ��ʂ��� SetImeComposition ���Ă���
    FDxArray: array[0..MaxLineCharacter] of Integer; // DrawTextRect �� ExtTextOut �֓n����W�����Ƃ��ė��p����B�P�C�O�O�P�����܂ŕ`��o����d�l
    FHScrollMax: Integer;                   // ���X�N���[���\�� MaxLineCharacter �ɐݒ肳���
    FImeCount: Integer;                     // WM_IME_COMPOSITION ���b�Z�[�W�n���h���Ŏ擾����������̒����BWM_CHAR ���b�Z�[�W�n���h���ŁA�������L�����Z�����邽�߂̒l�Ƃ��ė��p����B
    FItalicFontStyle: Boolean;              // fsItalic ���w�肳��Ă��邼�t���O�B�`��̍ێQ�Ƃ��ĕ`����@��ύX���Ă���
    FKeyRepeat: Boolean;                    // Col, Row �̕ω���A��ʃX�N���[������Ƃ� SetImeCompositionWindow �����s���邪�A�L�[���s�[�g��Ԃ̎��͎��s���L�����Z�����ăL�����b�g�̈ړ������������邽�߂̃t���O WMKeyDown �Őݒ� WMKeyUp �ŉ���
    FLeftScrollWidth: Integer;              // ���X�N���[���ɂ���ĉB��Ă��镝�i�s�N�Z���l�j
    FList: TEditorScreenStrings;            // ���ۂɕ������ێ�����I�u�W�F�N�g
    FMouseSelStartPos: TPoint;              // WMLButtonDown �Őݒ� WMMouseMove �Ŕ��ʂ��� StartSelection �ŗ��p
    FScreen: TEditorScreen;                 // TEditorScreen �I�u�W�F�N�g
    FUnderlineUpdateCount: Integer;         // UnderlineBeginUpdate ���ꂽ��
    FVScrollMax: Integer;                   // �c�X�N���[���\�� Lines.Count - 1 + RowCount - 1 �Őݒ肳��Ă���

    // �I��̈揈���p�f�[�^
    FClearingSelection: Boolean;            // �I��̈���N���A���܂��t���O�B�A���_�[���C�������ɕ`�悳�ꂽ�I��̈�F���N���A���邽�߂ɗ��p����
    FRowSelecting: Boolean;                 // �s�I���������t���O
    FSelDragState: TEditorSelDragState;     // sdNone, sdInit, sdDragging
    FSelectionState: TEditorSelectionState; // sstNone, sstInit, sstSelected
    FSelStartCol: Integer;                  // �I���J�n���i�`��p�j
    FSelStartSi: Integer;                   // �I���J�n���i������p�j
    FSelStartRow: Integer;                  // �I���J�n�s
    FSelOld: TSelectedPosition;             // �I��̈�i�`�攻�ʗp�j
    FSelRow: TSelectedPosition;             // �s�I��̈�
    FHitSelecting: Boolean;                 // sstHitSelected �ֈڍs���邽�߂̃t���O StartSelection �ŎQ�Ƃ����

    // Imagebar, Leftbar, Ruler �֘A�f�[�^
    FImagebarWidth: Integer;                // Imagebar �\�����s�N�Z��
    FLeftbarColumn: Integer;                // Leftbar �Ɏ��ۂɕ\������ۂ̌���
    FLeftbarEdge: TBitmap;                  // Edge �̎� Leftbar �̉E���ɕ`�悳���
    FLeftbarWidth: Integer;                 // Leftbar �\�����s�N�Z��
    FOriginBase: TBitmap;                   // ���_�ɕ`�悳���
    FRulerBase: TBitmap;                    // ����ɕ`�悵�����̂� Ruler �� CopyRect ����
    FRulerDigit: TBitmap;                   // 0..9 �̃r�b�g�}�b�v�i���[���[�p�j
    FRulerDigitHeight: Integer;             // Ruler �ɕ`�悳��鐔���̍��� 9
    FRulerDigitMask: TBitmap;               // 0..9 �̃r�b�g�}�b�v�쐬�p�}�X�N
    FRulerDigitWidth: Integer;              // Ruler �ɕ`�悳��鐔���̕�   5
    FRulerEdge: TBitmap;                    // Edge �̎� Ruler �̉����ɕ`�悳���
    FRulerGauge: TBitmap;                   // �W���P�O���ɑΉ������Q�[�W
    FRulerHeight: Integer;                  // Ruler �̍���                 10..11
    FRulerMarkBase: TBitmap;                // �V�L�����b�g�ʒu�������}�[�J�[�p
    FRulerMarkDigit: TBitmap;               // 0..9 �̃r�b�g�}�b�v�i���[���[�}�[�J�[�p�j

    // Imagebar, Leftbar, Ruler �֘A���\�b�h
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

    // �����񑀍상�\�b�h
    function ExpandListLength(Index: Integer): Integer;
    function ExpandListStr(Index: Integer): String;
    function ListInfoFromPos(Pos: TPoint; var Info: TEditorStrInfo): Boolean; virtual;
    function ListRows(Index: Integer): TEditorRowAttribute;
    function ListStr(Index: Integer): String;
    function ListToStr(Source: TEditorStringList): String;
    function PosTokenString(Pos: TPoint; Editor: TEditor; var C: Char; Bracket: Boolean): String; virtual;
    function PrevTopSpace(ARow: Integer): Integer;     // ARow �̑�����s���O�̍s�œ��ɋ󔒂������m������΂��̋󔒐���Ԃ�
    procedure PutStringToLine(Source: String);         // ���ݍs�̃L�����b�g�ʒu�� Str ��}������
    procedure SelectPosToken(Pos: TPoint; Editor: TEditor; Bracket: Boolean); virtual;
    function StrToAttributes(const S: String): String;  // S ���̕���������\�����镶�����Ԃ��B
    function TabbedTopSpace(const S: String): Integer; // S �̑O�̕����̃X�y�[�X����Ԃ��B�S�p�X�y�[�X�A�^�u�����ɑΉ�����

    // �`��֘A���\�b�h
    procedure AdjustColCount;                          // �\���������擾���� InitDrawInfo, DoChange �ŗ��p���Ă���
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
    procedure InitDrawInfo;                            // ��ʕ\�����̍Đݒ�
    procedure InitScroll;                              // SetScrollInfo ����
    procedure InitView;                                // ���Q���Ăяo���čĕ`�悷��
    procedure InvalidateLine(Index: Integer);          // Index �Ŏw�肳�ꂽ�P�s�̈�𖳌�������BUpdateWindow �͂��Ȃ�
    procedure InvalidateRow(StartRow, EndRow: Integer);// �w��s�Ԃ��s�ԍ��������܂߂Ė������� UpdateWindow ����
    procedure ImagebarScroll(Line, Count: Integer);    // Imagebar ������ Line ���牺�[�܂ł̗̈�� Count �s���X�N���[���� UpdateWindow ����
    procedure LineScroll(Line, Count: Integer);        // Line ���牺�[�܂ł̍s�ԍ������������̈�� Count �s���X�N���[���� UpdateWindow ����
    procedure PageVScroll(Value: Integer);             // Value �s����ʑS�̂��X�N���[��������
    procedure PaintLine(R: TRect; X, Y: Integer;       // R �̒��� S ���p�[�X���Ȃ���`�悷��
      S: String; Index: Integer; Parser: TFountainParser);
    procedure PaintLineSelected(R: TRect; X, Y:        // PaintLine �̑I��̈�o�[�W����
      Integer; S: String; Index: Integer; Parser: TFountainParser);
    procedure PaintRect(R: TRect);                     // �����̈���󂯎���ĕ`�揈���֕��򂷂�
    procedure PaintRectSelected(R: TRect; X, Y:        // �I������ PaintRect �w���p�[���\�b�h PaintLine, PaintLineSelected ���g��������
      Integer; S: String; Index: Integer; Parser: TFountainParser);
    procedure UnderlineBeginUpdate; virtual;
    procedure UnderlineEndUpdate; virtual;
    function UnderlinePos(ARow: Integer): Integer; virtual;

    // �L�����b�g�֘A���\�b�h public ���� PosToRowCol, SetRowCol ������
    procedure AdjustCol(RowChanged: Boolean; Direction: Integer); // �S�p�����A�^�u�ɑ΂���L�����b�g�ʒu����
    procedure CaretBeginUpdate; virtual;
    procedure CaretEndUpdate; virtual;
    procedure CaretHide; virtual;
    procedure CaretShow; virtual;
    function FindNextWordStart(var R, C: Integer; Direction: Integer): Boolean; virtual;// ���݂̌��ԍ��A�s�ԍ��i���ɂO�x�[�X�j�A�������w�肵�Ď��̌�̍s�ԍ����ԍ����擾����B��������� True ��Ԃ�
    function GetSelIndex(StartRow, ARow, ACol: Integer): Integer;
    function IsCaretNoClient: Boolean; virtual;
    procedure MoveCaret; virtual;                      // ���݂� Row, Col �ʒu�փL�����b�g���ړ�����B
    procedure RecreateCaret; virtual;
    procedure ScrollCaret; virtual;                    // ���݂� Row, Col �ʒu����ʏ�ɕ\�����邽�߂ɕK�v������Ή�ʃX�N���[�����s��
    procedure SetCaretPosition(var X, Y: Integer); virtual;
    procedure SetImeComposition;                       // SetImeCompositionWindow �Ăяo��
    procedure SetSelIndex(StartRow, SelIndex: Integer);
    procedure UpdateCaret; virtual;                    // �L�����b�g���ړ�����Ƃ����p����BWM_SETFOCUS �ł͗��p���Ă��Ȃ��B
    {$IFDEF COMP2}
    function SetImeCompositionWindow(Font: TFont; XPos, YPos: Integer): Boolean;
    {$ENDIF}

    // �I��̈�̏������\�b�h public ���ɂ� ClearSelection �Ȃǂ�����
    function BoxLeftIndex(const Attr: String; I: Integer): Integer; // ��`�I��̈捶���̕����C���f�b�N�X��Ԃ�
    function BoxRightIndex(const Attr: String; I: Integer): Integer; // ��`�I��̈�E���̕����C���f�b�N�X��Ԃ�
    function BoxSelRect(const S: String; Index, StartCol, EndCol: Integer): TRect; // ��`�I��`��̈�擾
    procedure DeleteSelection;     // �I��̈�̕�������폜���A�I����Ԃ���������
    procedure DrawSelection;       // �I��̈�̕`��
    procedure DrawSelectionBox;    // �V��`
    procedure DrawSelectionLine;   // �V�m�[�}��
    procedure InitSelection;       // �I��̈�f�[�^�̏����� -> sstInit
    procedure SelDeletedList(Dest: TEditorStringList); // �I��̈���폜������̕����񃊃X�g���擾����
    procedure SetSelection;        // ��Ԃɉ����� StartSelection, UpdateSelection ���Ăяo��
    procedure StartSelection;      // �I����Ԃւ̓���� -> sstSelected
    procedure UpdateSelection;     // �I��̈�f�[�^���X�V���čĕ`�悷��

    // �s�I������
    procedure StartRowSelection(ARow: Integer);  // �s�I���J�n
    procedure UpdateRowSelection(ARow: Integer); // �s�I���X�V

    // �I��̈�̈ړ����� public ���ɂ� IsSelectedArea �Ȃǂ�����
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

    // �t�@�N�g���[���\�b�h
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

    // �C�x���g�n���h���Ăяo��
    procedure DoCaretMoved; virtual;
    procedure DoChange; virtual;
    procedure DoDrawLine(ARect: TRect; X, Y: Integer; LineStr: String;
      Index: Integer; SelectedArea: Boolean); virtual;
    procedure DoSelectionChange(Selection: Boolean); virtual;
    procedure DoSelectionModeChange; virtual;
    procedure DoTopColChange; virtual;
    procedure DoTopRowChange; virtual;

    // �����I�u�W�F�N�g�̃C�x���g�n���h��
    procedure ViewChanged(Sender: TObject); virtual;

    // �����v���p�e�B
    property SelDragging: Boolean read GetSelDragging;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {$IFDEF COMP4_UP} // exclude D2..D3 cf protected section
    procedure DefaultHandler(var Message); override;
    {$ENDIF}
    // �I��̈�̃h���b�O���h���b�v���������邽�� public ���������\�b�h�Q
    function CanSelDrag: Boolean; virtual;                 // �I�𕶎�����}�E�X�h���b�O�o�����Ԃɂ��邩�ǂ�����Ԃ�
    procedure CancelSelDrag;                               // �I��̈敶����̃h���b�O�𒆒f����
    procedure CleanSelection;                              // �I����Ԃ̉��� -> sstNone
    procedure CopySelection(ARow, ACol: Integer); virtual; // �I��̈�̕������ ARow, ACol �ʒu�փR�s�[����B�������I��̈���̏ꍇ�͖�������
    function IsSelectedArea(ARow, ACol: Integer): Boolean; // ARow, ACol �ʒu���I��̈���ɂ��邩�ǂ�����Ԃ�
    procedure MoveSelection(ARow, ACol: Integer);          // �I��̈�̕������ ARow, ACol �ʒu�ֈړ�����B�������I��̈���̏ꍇ�͖�������
    procedure PosToRowCol(XPos, YPos: Integer;
      var ARow, ACol: Integer; Split: Boolean);            // XPos, YPos �Ŏw�肳�ꂽ�ꏊ�� Row, Col �l�� ARow, ACol �֊i�[���� Split �� True ��n���ƕ����Ԃ̃L�����b�g�ʒu��Ԃ�
    procedure SetRowCol(ARow, ACol: Integer);              // ARow, ACol �̈ʒu�� Row, Col ���ړ����� Row, Col ��ʁX�ɃZ�b�g����̂Ƃ͈Ⴄ���������

    // RowMark �֘A
    procedure PutRowMark(Index: Integer; Mark: TRowMark); virtual;
    procedure DeleteRowMark(Index: Integer; Mark: TRowMark); virtual;
    procedure GotoRowMark(Mark: TRowMark); virtual;

    // public ���\�b�h
    function CanRedo: Boolean; virtual;
    function CanUndo: Boolean; virtual;
    function CharFromPos(Pos: TPoint): Integer;        // �w��|�C���g�̕����C���f�b�N�X��Ԃ��i�����C���f�b�N�X�� SelStart �Ɠ��l�j���s�����ꍇ�� -1 ���Ԃ�
    procedure Clear;
    procedure ClearSelection;
    function ColToChar(ARow, ACol: Integer): Integer;  // ARow �s�� ACol �ʒu���󂯎���āALines ��ł̕����C���f�b�N�X��Ԃ��B���s�����ꍇ�� -1 ���Ԃ�
    procedure CopyToClipboard;
    procedure CutToClipboard;
    procedure DeleteRow(Index: Integer);               // FList �� Index �Ŏw�肳�ꂽ�s�f�[�^���폜���A�ĕ`�悷��
    procedure DrawTextRect(Rect: TRect; X, Y: Integer;
      const S: String; Options: Word);                 // ExtTextOut �� Rect, X, Y, S, Options �� FDxArray ��n���ĕ`�悷��
    procedure ExchangeList(Source: TEditor); virtual;  // ���g�� FList �ւ̎Q�Ƃ�j�����ASource �� FList ���Q�Ƃ���B
    function ExpandTab(const S: String): String;       // �^�u���X�y�[�X�ɓW�J�����������Ԃ�
    function ExpandTabLength(const S: String): Integer; // �^�u���X�y�[�X�ɓW�J����������̒�����Ԃ�
    function GetSelTextBuf(Buffer: PChar; BufSize: Integer): Integer;
    function GetTextLen: Integer;
    procedure HitToSelected;                           // sstHitSelected -> sstSelected �̏�ԕύX���s���i�u�����������ŕK�v�j
    function LeftMargin: Integer;
    function LinesToRow(Index: Integer): Integer;      // Lines �� Row ��̃C���f�b�N�X�ɕϊ����ĕԂ�
    procedure ListToFile(const FileName: String);
    procedure ListToStream(Stream: TStream);
    procedure PasteFromClipboard;
    procedure Redo; virtual;
    function RowToLines(Index: Integer): Integer;      // Row �� Lines ��̃C���f�b�N�X�ɕϊ����ĕԂ�
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
    function StrInfoFromPos(Pos: TPoint): TEditorStrInfo; // �w��|�C���g�̍s�ԍ��A���̍s��������ł̕����C���f�b�N�X���擾����i���ɂO�x�[�X�ł��邱�Ƃɒ��Ӂj���s�����ꍇ�́ALine, CharIndex �̂ǂ��炩�� -1 ���Ԃ�
    function TokenBracketFromCaret: Char;              // �L�����b�g�ʒu�̌��̎�ނ�Ԃ� toBracket ���Ԃ�
    function TokenBracketFromPos(Pos: TPoint): Char;   // �w��|�C���g�̌��̎�ނ�Ԃ� toBracket ���Ԃ�
    function TokenFromCaret: Char;                     // �L�����b�g�ʒu�̌��̎�ނ�Ԃ� toBracket ��Ԃ����Ƃ͖���
    function TokenFromPos(Pos: TPoint): Char;          // �w��|�C���g�̌��̎�ނ�Ԃ� toBracket ��Ԃ����Ƃ͖���
    function TokenStringBracketFromCaret: String;      // �L�����b�g�ʒu�̌���Ԃ��iView.Bracets ���l������j
    function TokenStringBracketFromPos(Pos: TPoint): String; // �w��|�C���g�̌���Ԃ��iView.Bracets ���l������j
    function TokenStringFromCaret: String;             // �L�����b�g�ʒu�̌���Ԃ��iView.Bracets �͖��������j
    function TokenStringFromPos(Pos: TPoint): String;  // �w��|�C���g�̌���Ԃ��iView.Bracets �͖��������j
    function TopMargin: Integer;                       // ���[���[�� Margin.Top �̍��v�l
    procedure Undo; virtual;
    function WordFromCaret: String;                    // �L�����b�g�ʒu�̂P���Ԃ��iView �̊e�v���p�e�B�ݒ�͖��������j
    function WordFromPos(Pos: TPoint): String;         // �w��|�C���g�̂P���Ԃ��iView �̊e�v���p�e�B�ݒ�͖��������j

    // �v���p�e�B
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
    property OnCaretMoved: TNotifyEvent read FOnCaretMoved write FOnCaretMoved; // �L�����b�g���ړ�������ɔ�������C�x���g
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
  TEditorScreenStrings.StrToWrapList, WrapCount ���\�b�h�̃w���p�[
  �I�u�W�F�N�g�B�R���X�g���N�^�� Attributes �����ɂ́ASource ����
  �Z�������񂪂���Ă���ꍇ������Bcf TEditor.StrToAttributes
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
#ScreenStrings ������̍X�V�Aundo, redo, �ĕ`��̎d�g��

Loaded, LoadFromFile �ȂǁA�����񂪑S�ʓI�ɕύX���ꂽ�ꍇ�́A
InitBrackets ���\�b�h�����s����B�܂������I�ȕ�����X�V�̏ꍇ�́A
UpdateBrackets ���\�b�h�����s����B

������̍X�V�Aundo, redo �ւ̑Ή��A�ĕ`��̎d�g�݂ɂ���

������̍X�V�́ATEditorScreenStrings.UpdateList ��ʂ��čs����B
UpdateList �ł́ATEditorUndoObj ���X�V���A�ĕ`�悷��ׂ��̈��
UpdateDrawInfo ���\�b�h�ɂ���� DrawInfo �Ɋi�[���Ă��� ChangeList,
DeleteList, InsertList �e���\�b�h�𗘗p���ĕ�������X�V���A
UpdateBrackets ���Ă���B

UpdateList ���\�b�h���� EndUpdate ���ꂽ���_�ŁAOnChange �� Assign
����Ă��� ChangeLink ���� FClients �Ɋi�[����Ă���e TEditor ��
�ύX���ʒm����A�e TEditor �� DoChange ���\�b�h�����s�����B

TEditor.DoChange �ł́A�X�N���[���o�[�̍X�V���s���A
TEditorScreenStrings.DrawInfo ���Q�Ƃ��ANeedUpdate �t���O���^�̏ꍇ
���� Modified �v���p�e�B���X�V���A�ĕ`����s���Ă���B

��A�̍�Ƃ��I����ATEditorScreenStrings.SetUpdateState �ŁADrawInfo
�̏������ƁAClientsAdjustRow ���\�b�h�Ăяo���ɂ�� FClients �̊e
TEditor �� Row, TopRow �̐������m�ۂ̏������s���Ă���B

UpdateList ���\�b�h�𗘗p�ł��Ȃ����\�b�h�Q�ɂ��āA

TEditorUndoObj �̃f�[�^�����ɓ��삷�� Undo, Redo ���\�b�h�A
�y�� TEditorUndoObj ���N���A���� Clear, WrapLines, StretchLines �ł́A
UpdateList �𗘗p���邱�Ƃ��o���Ȃ��B

Undo, Redo ���\�b�h�ł́A������̍X�V�AUpdateBrackets, UpdateDrawInfo
�����O�ōs���A�ĕ`��� EndUpdate ����̎d�g�݂𗘗p���Ă���B

Clear ���\�b�h�ł́AUpdateDrawInfo ���\�b�h���Ăяo������A
inherited �� Clear ���\�b�h�ɂ�� ChangeLink -> DoChange �̎d�g�݂�
����čĕ`����s���Ă���B
�܂��AClear ���\�b�h�ł́ABeginUpdate, EndUpdate ���s���Ȃ�
�iSetUpdateState �����s����Ȃ��j�̂ŁADrawInfo �����������AFClients ��
�e TEditor �� Row, Col �� �����I�� 0 �ɏ��������Ă���B

WrapLines, StretchLines �ł́AModified �v���p�e�B���X�V���ׂ��ł͂Ȃ�
�̂ŁAOnChange ����̘A������U�f���؂��Ă��珈�����s���Ă���B
�]���āA�����Q�̃��\�b�h���Ăяo���ꍇ�́AChangeLink -> DoChange
�ɂ��ĕ`��̎d�g�݂𗘗p���邱�Ƃ��o���Ȃ��̂ŁA
InitScroll, Invalidate �� FClients �̊e TEditor �ɂ��čs��
ClientsInitView ���\�b�h�y�сAClientsAdjustRow, ClientsInitCol
���\�b�h�����s����K�v������B

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
    // EndUpdate ��̏���
    FDrawInfo.Start := 0;
    FDrawInfo.Delete := 0;
    FDrawInfo.Insert := 0;
    FDrawInfo.Invalid := 0;
    FDrawInfo.NeedUpdate := False;
    // Row, TopRow �̐��������m�ۂ���B
    // Col �� SetRow -> AdjustCol �ōs����
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
  inherited Clear �ɂ�� ChangeLink -> DoChange �̎d�g�݂ɂ����
  �ĕ`�悪�s����B
  BeginUpdate, EndUpdate �͍s���Ȃ��iSetUpdateState �����s����
  �Ȃ��j�̂ŁAFDrawInfo �����������A�����I�Ɋe TEditor �� Row, Col
  �� 0 �ɏ���������B
*)
var
  I: Integer;
begin
  ClientsCleanSelection;
  FUndoObj.Clear;
  UpdateDrawInfo(0, Count, 0, 0); // Modified �ݒ�ƍĕ`��̂���
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
  Index ���� DeleteCount �s���폜���AIndex �̈ʒu�� List ��}������
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
  Index �̈ʒu����� DeleteCount �s���폜����
  DeleteCount ���̗̈���ړ�������A�s�v�ɂȂ��� DeleteCount ����
  �������폜����
  �폜�����̈�ɂ����� RowMarks �̘a��Ԃ�l�Ƃ���
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
  Index �̈ʒu�� List ��}���o���邾���̗̈��
  �m�ۂ��Ă���A���̗̈�� List �ōX�V����
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
  Index �Ŏw�肳�ꂽ�s����ATargetCount �� -1 �̏ꍇ�́ACount - 1 ��
  raCrlf or raEof �ȍs�܂ł́ATargetCount �� �� -1 �̏ꍇ��
  Index + TargetCount - 1 �̍s�܂ł̕�����f�[�^���쐬���� S �ɑ������
  TakenRowCount �ɂ́A�f�[�^���쐬����ێ�荞�񂾍s��
  RowAttribute �ɂ́A�Ō�Ɏ�荞�񂾍s�̑�������������
  raCrlf �ȍs������ɂ� #13#10 ���t�������
  Index + TargetCount - 1 �� Count - 1 ���z����ꍇ�̓G���[�ɂȂ�̂ŁA
  ���ӂ��K�v
*)
var
  I, Last, Size, L: Integer;
  P: PChar;
  Str: String;
begin
  // ������
  S := '';
  TakenRowCount := 0;
  RowAttribute := raInvalid;
  if (Index < 0) or (Count - 1 < Index) then
    Exit;

  // �擾����s�����J�E���g
  if TargetCount = -1 then
  begin
    Last := Index;
    while (Last < Count - 1) and (Rows[Last] = raWrapped) do
      Inc(Last);
  end
  else
    Last := Index + TargetCount - 1;

  // ��荞�ލs��
  TakenRowCount := Last - Index + 1;
  // �Ō�Ɏ�荞�ލs����
  RowAttribute := Rows[Last];
  // ��������쐬
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
  // Index ���܂ނP�s�f�[�^���I��� Row ��Ԃ�
  // �G���[�`�F�b�N�͍s��Ȃ�
  Result := Index;
  while (Result >= 0) and (Result < Count - 1) and
        (Rows[Result] = raWrapped) do
    Inc(Result);
end;

function TEditorScreenStrings.RowStart(Index: Integer): Integer;
begin
  // Index ���܂ނP�s�f�[�^���n�܂� Row ��Ԃ�
  // �G���[�`�F�b�N�͍s��Ȃ�
  Result := Index;
  while (Result > 0) and (Rows[Result - 1] = raWrapped) do
    Dec(Result);
end;

function TEditorScreenStrings.UpdateBrackets(Index: Integer; InvalidateFlag: Boolean): Integer;
(*
  Index ����̍s�� Brackets �v���p�e�B�l�� -2 ����Ȃ��Ƃ���܂ők��A
  �ȍ~�� PrevRows, Brackets, Elements, WrappedBytes, Remains, Tokens,
  PrevTokens, DataStrings �v���p�e�B�l���X�V����B

  �X�V����͈͂�
  �E���������m�ۂ����܂�
  �E��ʃT�C�Y (Client.FRowCount) �̂Q�{
    �iver 1.42 ���AScreen.Height div GetRowHeight * 2 �Ƃ���j
  �ECount - 1
  �̍ŏ��l�Ƃ���
  InvalidateFlag �� True �̏ꍇ�́A�v���p�e�B�l���X�V�����̈�𖳌�������B
  UpdateWindow �͍s��Ȃ��B�����������s�����Ԓl�ƂȂ�
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
    // -2 ����Ȃ��s�܂ők���āA�����̃f�[�^���擾����B
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
    // Index = 0 �ŏ�̃��[�v�����Ȃ��������A�m�肵�Ȃ������ꍇ��
    // �擪�̍s����X�V����
    if Idx = -1 then
    begin
      Idx := 0;                                // �O�s�ڂ��珈������B
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

    // ���[�v�̏��
    // ���I�ɐ��������ꍇ�AClient.GetRowHeight �� 0 �ɂȂ�ꍇ������̂�
    J := Min(Index + Screen.Height div Max(Client.GetRowHeight, 1) * 2, Count - 1);

    (*
      ��� Idx - 1 �s���p�[�X���ē����f�[�^�� Idx �s���p�[�X���邽�߂�
      �f�[�^�ƂȂ�B
      PrevRows[I], Brackets[I], Elements[I], WrappedBytes[I], Remains[I],
      Tokens[I], PrevTokens[I], DataStrings[I]
      �v���p�e�B�l�����̃f�[�^�ōX�V���Ȃ��烋�[�v������B
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
        // ���������m�ۂ��ꂽ
        Exit;
      Data.RowAttribute := Rows[I];
      // Rows[I] := Data.RowAttribte; ����Ă͂����Ȃ��B
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
  // �X�V���Ă��Ȃ��f�[�^���c�����̂ŁA�ȉ��� -2 �ɂ���
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
  FList �e�s�� Brackets, Elements ���������E�X�V����B
  ��U InvalidBracketIndex, InvalidElementIndex, toEof �ŏ�����������
  LoadFromFile �����������邽�߂ɁA�擪���猩���Ă��镔���������X�V����B
  ����ȊO�̗̈�́A�`�悷��� InvalidBracketIndex �𔻕ʂ�
  UpdateBrackets �ōX�V�����d�l�Ƃ���B
  Client.FSpeed.FInitBracketsFull �̎��́A�S�s���X�V����B
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
  Index ���� DeleteCount �s���폜���AIndex �� S ��}������
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
  Rs := Max(RowStart(Index), Index - 1); // ���`�f�[�^�͂P�s�ォ��ŏ\��
  Id := Index + DeleteCount - 1;
  Re := RowEnd(Id);
  BeginUpdate;
  try
    // insert data
    if (Rs = Index) and (Re = Id) and (S = '') and (DeleteCount <> 0) then
    begin
      // ���`��ɑ}������f�[�^�������̂� Undo �f�[�^��ۑ���A�폜
      // ���邾��
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
      // ���`��̃f�[�^��}������̂ŁARowAttribute ���K�v
      if (Id < Re) and (Re <= Count - 1) then
        // �s�����폜���Ȃ��ꍇ�ŁARe �����X�g��̏ꍇ
        RowAttribute := Rows[Re]
      else
        // �s�����폜���邩�A���X�g����O��Ă���ꍇ
        if Re < Count - 1 then
        begin
          // ���X�g��Ȃ̂ŁA���̂P�s������������Ώۂɉ�����
          Re := RowEnd(Re + 1);
          RowAttribute := Rows[Re];
        end
        else
          // ���X�g�̍Ō�������X�g���O��Ă���̂ŁA
          // �}�����镶����̌�[�Ŕ��ʂ���
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
        // Brackets �̍X�V
        Ivr := UpdateBrackets(Rs, True);
      finally
        WrapList.Free;
      end;
    end;
    // �`����̍X�V
    UpdateDrawInfo(Rs, Dr, Ir, Ivr);
  finally
    EndUpdate; // -> OnChange (ChangeLink) -> FClients.DoChange -> FScreenUpdate (Draw)
  end;
end;

procedure TEditorScreenStrings.ClientsAdjustRow;
(*
  FClients �̊e TEditor �� Row �̐��������m�ۂ���BRow ���X�V����Ă��A
  �t�H�[�J�X�������Ă��Ȃ� Editor �̃L�����b�g�͓����Ȃ��̂ŁATopRow
  ���ω����Ȃ��Ƃ����d�l�Ȃ̂ŁATopRow ���X�V����B
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
  // ��l�߂ŏ������A�s�v�������폜����
  if Count = 0 then
    Exit;
  ClientsCleanSelection;
  // Count - 1 �̑����������p�����߂̏��� raWrapped ��
  // �ŏI�s�̏ꍇ������̂� raEof �ɕϊ�����
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
  S �� #13#10 �Ő؂蕪���� List �Ɋi�[����B
  S = '' �̏ꍇ�́A�󔒍s���P�s�ǉ������d�l�Ƃ���B
  WrapLines �����������d�l��]��ł��邩��ł���B
  WordWrap ���́A�؂蕪����������� BufList �Ɋi�[���A
  BufList[n] �� WrapByte, WordBreak, FollowPunctuation, Leading,
  FollowRetMark �̃v���p�e�B�l�ɉ����Đ؂蕪���Ă��� List �Ɋi�[����B
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
    Inc(Li); // ���s�����̂Ԃ牺���ŁA�K�v�ɂȂ鏈��
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
          // #13#10 �ŕ���
          StrToStrings(S, BufList);
          // SetSelTextBuf �����e�ʂ� S ������Ă���ꍇ������̂ŁA
          // BufList.Count ���̗̈�����炩���ߊm�ۂ��Ă����B
          Capacity := BufList.Count;
          for I := 0 to Capacity - 1 do
            List.Add('');
          Li := 0; // List �ւ̃C���f�b�N�X
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
                    // �����������񒷂� FWapOption.FWrapByte ��蒷���ꍇ
                    // FWrapByte �̂P�^�R�����x�� PositionString ���f��
                    // �~�^���S�p�����̂Q�o�C�g�ڂɂȂ�܂Ŗ߂��B
                    if FWrapOption.FWordBreak and
                       (AttrArray.Size > FWrapOption.FWrapByte) then
                    while not (AttrArray.Attribute in [caTabSpace, caDBCS2, caDelimiter]) and
                          (AttrArray.Position > FWrapOption.FWrapByte div 3) do
                    begin
                      AttrArray.Prior;
                      if AttrArray.Attribute = caDBCS1 then
                        AttrArray.Prior;
                    end;
                  // ��Ǔ_�̂Ԃ牺��
                  // ���̍s���ɋ�Ǔ_������ꍇ�́A2 byte �����x��
                  // �Ԃ牺����B�S�p���p���݂̏ꍇ�� 3 byte �ɂȂ�
                  // �ꍇ������
                  if FWrapOption.FFollowPunctuation then
                  while (AttrArray.Position < FWrapOption.FWrapByte + 2) and
                        IsInclude(AttrArray.NextPositionString, FWrapOption.FPunctuationStr) do
                  begin
                    AttrArray.Next;
                    if AttrArray.Attribute = caDBCS1 then
                      AttrArray.Next;
                  end;

                  // �ǂ��o��
                  if FWrapOption.FLeading and (AttrArray.Size > AttrArray.Position) then
                  begin
                    // �s���֑�����
                    // PositionString �� LeadStr�i�s���֑������j�Ɋ܂܂��
                    // �ꍇ�� FWrapByte �� �S�^�T�����x�ɒǂ��o��
                    while (AttrArray.Position > (FWrapOption.FWrapByte div 5) * 4) and
                          IsInclude(AttrArray.PositionString, FWrapOption.FLeadStr) do
                    begin
                      AttrArray.Prior;
                      if AttrArray.Attribute = caDBCS1 then
                        AttrArray.Prior;
                    end;

                    // �s���֑�����
                    // ���̍s�����Q�ȏ゠���āANextPositionString ��
                    // FollowStr�i�s���֑������j�̏ꍇ�A
                    // PositionString �� LeadStr�i�s���֑������j��
                    // NextPositionString �� FollowStr�i�s���֑������j��
                    // �ꍇ�� FWrapByte �� �S�^�T�����x��
                    // �ǂ��o��
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

                  // �s���̃^�u�����W�J���� WrapByte ���z���Ă��\��Ȃ��d�l�Ƃ���

                  // Str �̐擪���� AttrArray.SourcePos �܂ł̕������ǉ����A�폜����
                  CheckAdd(Copy(Str, 1, AttrArray.SourcePos), raWrapped);
                  System.Delete(Str, 1, AttrArray.SourcePos);
                  // ���̃��[�v�̂��߂̏���
                  Attr := Client.StrToAttributes(Str);
                  AttrArray.NewData(Str, Attr);
                  AttrArray.Position := FWrapOption.FWrapByte;
                end;
                // ���[�v�𔲂������_�ł̏���
                if Length(Str) > 0 then
                  // �����񂪎c���Ă���� raCrlf �ȍs�Ƃ��Ēǉ�
                  CheckAdd(Str, raCrlf)
                else
                  // Str ���󔒂̏ꍇ
                  if not FWrapOption.FFollowRetMark then
                    // ���s�̂Ԃ牺�����s�Ȃ�Ȃ��ꍇ
                    CheckAdd('', raCrlf)
                  else
                    // ���s�̂Ԃ牺�����s�Ȃ��ꍇ
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
  FWrapOption �v���p�e�B�l�� S �����s�ɐ܂�Ԃ���邩��
  �J�E���g����B
  S �� #13#10 �͊܂܂�Ă��Ȃ����̂Ƃ���
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
          // ��Ǔ_�̂Ԃ牺��
          if FWrapOption.FFollowPunctuation then
          while (AttrArray.Position < FWrapOption.FWrapByte + 2) and
                IsInclude(AttrArray.NextPositionString, FWrapOption.FPunctuationStr) do
          begin
            AttrArray.Next;
            if AttrArray.Attribute = caDBCS1 then
              AttrArray.Next;
          end;
          // �ǂ��o��
          if FWrapOption.FLeading and (AttrArray.Size > AttrArray.Position) then
          begin
            // �s���֑�����
            while (AttrArray.Position > (FWrapOption.FWrapByte div 5) * 4) and
                  IsInclude(AttrArray.PositionString, FWrapOption.FLeadStr) do
            begin
              AttrArray.Prior;
              if AttrArray.Attribute = caDBCS1 then
                AttrArray.Prior;
            end;
            // �s���֑�����
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
        // ���[�v�𔲂������_�ł̏���
        if Length(S) > 0 then
          // �����񂪂܂��������ꍇ
          Inc(Result)
        else
          // ���������ꍇ
          if not FWrapOption.FFollowRetMark then
            // ���s�}�[�N���Ԃ牺����ꍇ
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
        // FollowRetmark ���l������̂Ł��̔��ʂ� <= �ł͂Ȃ�
        if Client.ExpandTabLength(S) < FWrapOption.FWrapByte then
          Inc(NewListCount)
        else
          Inc(NewListCount, WrapCount(S));
        S := '';
      end;
    end;
    // Count - 1 �̑�����ۑ�
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
  // IDE ���ŃR�s�[���y�[�X�g�����ꍇ�P�s���ɍĕ`�悪�s���Ă��܂��̂�
  // BeginUpdate, EndUpdate ����
  BeginUpdate;
  try
    Clear;
    while not Reader.EndOfList do
      FEditor.FList.Add(Reader.ReadString);
  finally
    EndUpdate;
  end;
  Reader.ReadListEnd;
  // csLoading, csReading �Ȃ̂ŁAWrapLines �͍s��Ȃ�
  // Loaded �� WrapLines ���s����
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
    // ListInfo �ł́A������ #13#10 ��t�����Ă���̂Ŏ�菜��
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
  FLines ��ł� Index �� FEditor.FList �� Index �ɕϊ�����
  ��O�𔭐������邽�߂Ɋ�����
  Max(0, Min(Index, FEditor.FList.Count))
  and (Result <= FEditor.FList.Count - 1)
  �Ȃǂ̔��ʂ��s��Ȃ��B
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
// #26 ��ǂݍ��܂Ȃ��o�[�W����
// ���s������ #13#10, #13, #10 �ɑΉ�
const
  BufferSize = $2000;
var
  I, ReadCount, LineCount: Integer;
  LineRemained, CREnd: Boolean;
  S, Str: String;
  Buffer, P, Start: PChar;
  Fs: TFileStream;
begin
  // FEditor.Flist �֒��ړǂݍ��ނ̂ŁA�ǂݍ��݌� WordWrap �ɑΉ�����
  BeginUpdate;
  try
    Clear;
    try
      Fs := TFileStream.Create(FileName, fmOpenRead);
    except
      raise Exception.Create('"'+FileName+'"���J���܂���B');
    end;
    try
      Buffer := StrAlloc(BufferSize + 1);
      try
        // #13, #10 ���J�E���g���� #26 �ȍ~�͓ǂݍ��܂Ȃ�
        LineCount := 0;
        LineRemained := False;
        CREnd := False;
        repeat
          ReadCount := Fs.Read(Buffer^, BufferSize);
          if ReadCount > 0 then
            LineRemained := False;
          Buffer[ReadCount] := #0;
          P := Buffer;
          // �o�b�t�@�ɂ���� #13#10 �����f���ꂽ�ꍇ�̂��߂�
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

        // �擾�����s������ Capacity ���m��
        for I := 0 to LineCount - 1 do
          FEditor.FList.Add('');
        // �o�b�t�@�𗘗p���ēǂݍ��� #26 �ȍ~�͓ǂݍ��܂Ȃ�
        Fs.Seek(0, 0);
        LineCount := 0;
        CREnd := False;
        Str := '';
        repeat
          ReadCount := Fs.Read(Buffer^, BufferSize);
          Buffer[ReadCount] := #0;
          P := Buffer;
          // �o�b�t�@�ɂ���� #13#10 �����f���ꂽ�ꍇ�̂��߂�
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
          // #13#10 �̖����s���ǉ����ꂽ
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
  �ŏ��� BeginUpdate �� True ���A�Ō�� EndUpdate �� False ������Ă���
  OnChange �C�x���g�� FEditor.FList.OnChange �𗘗p���Ă���̂ŁA
  FEditor.FList.BeginUpdate, EndUpdate ���Ă���
  �܂��A�L�����b�g��A���_�[���C���̕`������f����
*)
begin
  // TEditorStrings �Ǝ��� FUpdateCount ���Z�b�g
  if Updating then
  begin
    Inc(FUpdateCount);
    FEditor.FList.BeginUpdate;
    FEditor.CaretBeginUpdate;
    FEditor.UnderlineBeginUpdate;
    // UpdateCaret �Ăяo�����L�����Z�����č���������
    FEditor.FCaretNoMove := True;
  end
  else
  begin
    Dec(FUpdateCount);
    FEditor.FList.EndUpdate;
    FEditor.UnderlineEndUpdate;
    FEditor.CaretEndUpdate;
    // �t���O�̃N���A�Ǝ��O�ŃL�����b�g�ړ�
    FEditor.FCaretNoMove := False;
    FEditor.UpdateCaret;
  end;
  // ��؂̕`����~�E�ĕ`��
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
  TList ���g������ TUndoDataList �ł́A���ڂ��j�������Ƃ���
  ���ڂ��ێ�����|�C���^�� Dispose ����B
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
  #UndoObj TEditorUndoObj �I�u�W�F�N�g�̓���ɂ���

  TUndoData = record
    Row,                   ���ݍs
    Col,                   ���݌�
    DataRow,               �f�[�^�𕜋A����s
    DeleteCount: Integer   ���A���s���ۍ폜�����s��
    RowAttribute: TEditorRowAttribute;
                           InsertStr ��}������ۃZ�b�g����鑮��
    InsertStr: String;     ���A����ۑ}������镶����
  end;

  InsertStr �́A���s���܂ނP������Ƃ��č쐬����B
  �Ⴆ�Ή��̏�Ԃ� a ���폜����ꍇ�� 1..n + #13#10 + o..u �̕�����ƂȂ�
  1234567890abcdefghijklmn <- wrap
  opqrstu��

  Undo �̎��s
  FUndoList �̍Ō������f�[�^�� FEditor.FList �֕���������B
  DeleteCount > 0 �ł���� DataRow ���� DeleteCount �s�̕�������폜���A
  RowAttribute <> raInvalid �ł���� DataRow �� InsertStr ��}������B

  �f�[�^�̍X�V
  DataRow ���� DeleteCount �s�̕�����ƍŏI�s�̑����͍폜����O�ɕۑ�
  ���Ă����A���A�����I����A���̕ۑ��f�[�^�ŁAInsertStr, RowAttribute ��
  �X�V����B
  InsertStr ���}�����ꂽ�ꍇ�� InsertStr ����L����s���� DeleteCount ��
  �X�V����

  �f�[�^�̈ڍs
  �X�V�����f�[�^�� FRedoList �֒ǉ�����BFUndoList �̍Ō���̃f�[�^��
  �폜�����BUndo ���s�����񐔂��� Redo ���\�ɂȂ�d�l�ł���B

  Redo �̎��s
  Undo �ƑS�������������s�����A�����ς݂̃f�[�^�� FUndoList �֒ǉ�
  �����B
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
  // ���݂̏�Ԃ��擾
  P.Row := FList.ActiveClient.FRow;
  P.Col := FList.ActiveClient.FCol;
  // ������
  P.DataRow := -1;
  P.DeleteCount := 0;
  P.RowAttribute := raInvalid;
  P.InsertStr := '';
  // ���X�g�ɒǉ����āA�ő�l�`�F�b�N
  FUndoList.Add(P);
  if FUndoList.Count > FListMax then
    FUndoList.Delete(0);
  // Redo ����Ă΂�Ă��Ȃ���΁AFRedoList ���N���A����
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
        // �폜����s�������ꍇ
        S := '';
        Dr := 0;
        RowAttribute := raInvalid;
      end
      else
        // �폜���镶����ƍŏI�s�̑�����ۑ�
        FList.ListInfo(P.DataRow, P.DeleteCount, S, Dr, RowAttribute);
      // delete & insert
      Ir := 0;
      if P.RowAttribute = raInvalid then
      begin
        // �}������f�[�^�������̂ŁADr �s���폜���邾��
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
          // raWrapped �ȏꍇ�ɕK�v�ȏ���
          if (P.RowAttribute = raWrapped) and
             (Length(WrapList[WrapList.Count - 1]) = 0) then
            WrapList.Delete(WrapList.Count - 1);
          WrapList.Rows[WrapList.Count - 1] := P.RowAttribute;
          // �����ő}�������s���� Undo ����ۂ� DeleteCount �ɂȂ�
          Ir := WrapList.Count;
          FList.ChangeList(P.DataRow, Dr, WrapList);
        finally
          WrapList.Free;
        end;
      end;
      // Brackets �̍X�V
      Ivr := FList.UpdateBrackets(P.DataRow, True);
      // �`����̍X�V
      FList.UpdateDrawInfo(P.DataRow, Dr, Ir, Ivr);
      // FUndoList �ɒǉ� FRedoList ���N���A����Ȃ��悤�Ƀt���O�𗘗p����
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
    // �L�����b�g�̕��A
    FList.ActiveClient.Row := P.Row;
    FList.ActiveClient.Col := P.Col;
  finally
    FList.ActiveClient.CaretEndUpdate;
  end;
  // �Ō���̃f�[�^���폜
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
        // �폜����s�������ꍇ
        S := '';
        Dr := 0;
        RowAttribute := raInvalid;
      end
      else
        // �폜���镶����ƍŏI�s�̑�����ۑ�
        FList.ListInfo(P.DataRow, P.DeleteCount, S, Dr, RowAttribute);
      // delete & insert
      Ir := 0;
      if P.RowAttribute = raInvalid then
      begin
        // �}������f�[�^�������̂ŁADr �s���폜���邾��
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
          // raWrapped �ȏꍇ�ɕK�v�ȏ���
          if (P.RowAttribute = raWrapped) and
             (Length(WrapList[WrapList.Count - 1]) = 0) then
            WrapList.Delete(WrapList.Count - 1);
          WrapList.Rows[WrapList.Count - 1] := P.RowAttribute;
          // �����ő}�������s���� Redo ����ۂ� DeleteCount �ɂȂ�
          Ir := WrapList.Count;
          FList.ChangeList(P.DataRow, Dr, WrapList);
        finally
          WrapList.Free;
        end;
      end;
      // Brackets �̍X�V
      Ivr := FList.UpdateBrackets(P.DataRow, True);
      // �`����̍X�V
      FList.UpdateDrawInfo(P.DataRow, Dr, Ir, Ivr);
      // �ێ����Ă���f�[�^���X�V���� FRedoList �ɒǉ�
      P.DeleteCount := Ir;
      P.RowAttribute := RowAttribute;
      P.InsertStr := S;
      UndoToRedo(P);
    finally
      FList.EndUpdate; // draw
    end;
    // �L�����b�g�̕��A
    FList.ActiveClient.Row := P.Row;
    FList.ActiveClient.Col := P.Col;
  finally
    FList.ActiveClient.CaretEndUpdate;
  end;
  // �Ō���̃f�[�^���폜
  FUndoList.Delete(FUndoList.Count - 1);
end;

procedure TEditorUndoObj.UndoToRedo(Data: PUndoData);
var
  P: PUndoData;
begin
  New(P);
  // FUndoList ����̃f�[�^���󂯎��
  P.DataRow := Data.DataRow;
  P.DeleteCount := Data.DeleteCount;
  P.RowAttribute := Data.RowAttribute;
  P.InsertStr := Data.InsertStr;
  // ���݂̏�Ԃ��擾
  P.Row := FList.ActiveClient.FRow;
  P.Col := FList.ActiveClient.FCol;
  // FUndoList ����ǉ������̂ōő�l�`�F�b�N�͍s��Ȃ�
  FRedoList.Add(P);
end;


{  TEditorWrapOption  }

constructor TEditorWrapOption.Create;
begin
  FFollowStr := WrapOption_Default_FollowStr;           // '�A�B�C�D�E�H�I�J�K�R�S�T�U�X�[�j�n�p�v�x!),.:;?]}�������';
  FLeadStr := WrapOption_Default_LeadStr;               //'�i�m�o�u�w([{�';
  FPunctuationStr := WrapOption_Default_PunctuationStr; // '�A�B�C�D,.��';
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
  FEditor.FList.FDrawInfo �������ɉ�ʂ��X�V����
  FList �͊��ɍX�V����Ă��܂��Ă��邱�Ƃɒ��ӁB
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
      Sp := I + Ir + Max(0, Ivr - Ir); // �X�N���[���|�C���g
      if Ir <> Dr then
      begin
        // �X�N���[������������ꍇ
        InvalidateRow(I, Sp - 1);      // �̈���ĕ`��
        if FImagebar.FVisible then
          ImagebarScroll(Sp, Ir - Dr);
        LineScroll(Sp, Ir - Dr);       // �X�N���[���ɑΉ�
        if Sp > FList.Count - 1 then   // [EOF] �֑Ή�
          InvalidateRow(Sp, Sp + 1);   // EndUpdate ��� Add �Ȃǂ����s����ƁA���̗̈�܂ōĕ`�悪�K�v
      end
      else
        // �X�N���[������
        if Sp > FList.Count - 1 then   // [EOF] ����Ƃ�
          InvalidateRow(I, Sp + 1)     // EndUpdate ��� Add �Ȃǂ����s����ƁA���̗̈�܂ōĕ`�悪�K�v
        else
          InvalidateRow(I, Sp - 1);    // �̈�̂�

      // FLeftbar
      if FLeftbar.FVisible and FLeftbar.FShowNumber and
         ((FLeftbar.FShowNumberMode = nmLine) or
          ((FList.Count <= FTopRow + FRowCount) and (Dr <> Ir))) then
        // �s�ԍ���\�����Ă��āAnmLine ���[�h���A[EOF] �s��������
        // ���āA�X�N���[�������������ꍇ�́A��ʉ��[�܂ł��ĕ`�悷��B
        // InvalidateRow �ł͍s�ԍ��\�����������������Ă���̂ŁA����
        // �ł� Sp �����ʉ��[�܂łƂ���
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
  FSetMark.Caption := PopupMenu_MarkSet; //          = '�}�[�N�ݒ�';
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
  FGotoMark.Caption := PopupMenu_MarkJump; //        = '�}�[�N�W�����v';
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
  FUndo.Caption := PopupMenu_Undo; //                = '���ɖ߂�(&U)';
  FUndo.ShortCut := TextToShortCut('Ctrl+Z');
  FUndo.OnClick := UndoClick;
  FUndo.Enabled := False;
  Items.Add(FUndo);

  FRedo := TMenuItem.Create(Self);
  FRedo.Caption := PopupMenu_Redo; //                = '��蒼��(&R)';
  FRedo.ShortCut := TextToShortCut('Ctrl+A');
  FRedo.OnClick := RedoClick;
  FRedo.Enabled := False;
  Items.Add(FRedo);

  FN1 := TMenuItem.Create(Self);
  FN1.Caption := '-';
  Items.Add(FN1);

  FCut := TMenuItem.Create(Self);
  FCut.Caption := PopupMenu_Cut; //                  = '�؂���(&T)';
  FCut.ShortCut := TextToShortCut('Ctrl+X');
  FCut.OnClick := CutClick;
  FCut.Enabled := False;
  Items.Add(FCut);

  FCopy := TMenuItem.Create(Self);
  FCopy.Caption := PopupMenu_Copy; //                = '�R�s�[(&C)';
  FCopy.ShortCut := TextToShortCut('Ctrl+C');
  FCopy.OnClick := CopyClick;
  FCopy.Enabled := False;
  Items.Add(FCopy);

  FPaste := TMenuItem.Create(Self);
  FPaste.Caption := PopupMenu_Paste;//               = '�\��t��(&P)';
  FPaste.ShortCut := TextToShortCut('Ctrl+V');
  FPaste.OnClick := PasteClick;
  FPaste.Enabled := False;
  Items.Add(FPaste);

  FBoxPaste := TMenuItem.Create(Self);
  FBoxPaste.Caption := PopupMenu_BoxPaste; //        = 'Box�\��t��(&B)';
  FBoxPaste.ShortCut := TextToShortCut('Ctrl+B');
  FBoxPaste.OnClick := BoxPasteClick;
  FBoxPaste.Enabled := False;
  Items.Add(FBoxPaste);

  FDelete := TMenuItem.Create(Self);
  FDelete.Caption := PopupMenu_Delete; //            = '�폜(&D)';
  FDelete.OnClick := DeleteClick;
  FDelete.Enabled := False;
  Items.Add(FDelete);

  FN2 := TMenuItem.Create(Self);
  FN2.Caption := '-';
  Items.Add(FN2);

  FSelAll := TMenuItem.Create(Self);
  FSelAll.Caption := PopupMenu_SelectAll; //         = '���ׂđI��(&A)';
  FSelAll.OnClick := SelAllClick;
  FSelAll.Enabled := False;
  Items.Add(FSelAll);

  FN3 := TMenuItem.Create(Self);
  FN3.Caption := '-';
  Items.Add(FN3);

  FSelMode := TMenuItem.Create(Self);
  FSelMode.Caption := PopupMenu_BoxSelectionMode; // = 'Box�I�����[�h(&K)';
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

�� #IME SetImeComposition IME �E�B���h�D�̈ړ��ɂ���

Col, Row, TopRow, TopCol �̕ω���A��ʃX�N���[���ɂ���ăN���C�A���g��
���ŃL�����b�g�ʒu���ω������ꍇ�� IME �E�B���h�D���ړ����Ȃ���΂Ȃ�
�Ȃ��BTEditor �ł́A���̈ړ������� MoveCaret, SetTopRow, SetTopCol�ōs��
�Ă���B�A���X�N���[���Ȃǂňړ��������p�ɂɍs����̂�����邽�߁A
WMKeyDown �ł̓L�[���s�[�g�t���O FKeyRepeat ��ݒ肵�Ă���B�ړ��������s
���O�ɁA���̃t���O���Q�Ƃ� FKeyRepeat ���^�̏ꍇ�͈ړ��������s�킸��
FCompositionCanceled �t���O��^�ɐݒ肵�Ă���BWMKeyUp �ł́AFKeyRepeat
�t���O���N���A���� FCompositionCanceled ���^�ȏꍇ SetImeComposition ��
�яo�����s���Ă��� SetImeComposition �� FCompositionCanceled �t���O���N
���A�����

�� #Scroll ScrollWindowEx �ɂ���

  �X�N���[������̈�� FMargin.FLeft, FMargin.FTop, Width, Height ��
�ő�l�Ƃ���N���b�v���ōs���B�}�[�W�������̓X�N���[�����Ȃ��d�l�Ƃ���B
���ۂɃX�N���[������ۂ́ADoScroll ���\�b�h���Ăяo���ă��[�U�[�̊g����
�Ή��o����d�l�ƂȂ��Ă���B
  ���A��O�͂����āAScrollWindowEx �𒼐ڌĂяo���Ă��镔��������

�ERuler ��\�����Ă���ꍇ�̏c�X�N���[���́A
  Rect(0, TopMargin, Width, Height) �̗̈���N���b�v���Ă���B
       ^
�ELeftbar ��\�����Ă���ꍇ�̉��X�N���[���́A
  Rect(LeftMargin, 0, Width, Height) �̗̈���N���b�v���Ă���B
                   ^
  ��S������ TRect �ւ̃|�C���^��n���ꍇ�͏����O�� UpdateWindow ���s���B
��T������ TRect �ւ̃|�C���^��n���ꍇ�́A�L�����b�g�������čs�����
CaretBeginUpdate, CaretEndUpdate ���p���Ȃ��Ȃ��BLineScroll �����s����
�ۂ́A������ Row, Col �̐ݒ���s���d�l�Ƃ���

  �c�X�N���[���̍ۂ́A�A���_�[���C�����`���c�N�̂�h�����߁A
UnderlineBeginUpdate, UnderlineEndUpdate ���s���B

  DoScroll �ł� �ȉ��̂悤�� ScrollWindowEx ���g�p����A���O�Ŗ����̈��
�������� UpdateWindow ���Ă���B���̖����̈�͓h��Ԃ���邱�Ƃ��Ȃ�
�̂ŁA�`�揈���ł́AFillRect ���邩�AExtTextOut �� ETO_OPAQUE ��n����
��x�͗̈��h��Ԃ���Ƃ��K�v�ɂȂ�

ScrollWindowEx(Handle, X, Y, Rect, ClipRect, 0, @R, SW_SCROLLCHILDREN);
InvalidateRect(Handle, @R, False);
UpdateWindow(Handle);

�� #Caret �`��ƃL�����b�g�ɂ���

  �Ȃ�炩�̕`����s���ۂ́A�L�����b�g����ʂɒ蒅����Ă��܂��̂ŁA
CaretBeginUpdate, CaretEndUpdate ���s���BIME �E�B���h�D���\�������ۂ�
�L�����b�g�̒蒅���N����ꍇ������̂� WM_IME_COMPOSITION ���b�Z�[�W�n��
�h���ł��ACaretBeginUpdate, CaretEndUpdate ���s���Ă���

not Showing �̏�Ԃŕ`�揈�����s����� Canvas.MoveTo �̂Ƃ���Ō�
�܂��Ă��܂����ۂ����������̂ŁACanvas �Ɏ��L�΂����\�b�h�ł́A
Showing �𔻕ʂ���d�l�Ƃ���B
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
  // Font.Name �ւ̑�� �� CMFontChanged �� InitDrawInfo �� FLines �Q��
  // ������̂ŁA���X�g�I�u�W�F�N�g�̐������ɍs��
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
    // D2 RecreatWnd �Ăяo���ɂ�� TComponent ���B�ꎖ���΍�
    if (csDesigning in ComponentState) and (Parent <> nil) and
       (Parent is TForm) then
      SetZOrder(False);
  {$ENDIF}

  // Handle ���o���オ�������_�Ŏ��s����鏉�������\�b�h�Q
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
  // �����̈���擾���� PaintRect �ɓn��
  R := Canvas.ClipRect;
  PaintRect(R);
end;

{$IFDEF COMP2}

function TEditor.SetImeCompositionWindow(Font: TFont;
  XPos, YPos: Integer): Boolean;
(*
  D2 �ł͎�������Ă��Ȃ� SetImeCompositionWindow
  �L�[���͂����s�[�g��Ԃ̎��A����� IME Window �ɕ�����������Ԃ�
  ��ʃX�N���[���������� SetImeCompositionWindow �Ăяo�����L�����Z����
  �t���O���Z�b�g���Ă����BWMKeyUp, WMChar �ł́A���̃t���O���Q�Ƃ���
  SetImeCompositinWidow ���Ăяo���Ă���B
  �ʏ�̃L�����b�g�ړ��AIME Window �ɕ��������͂��ꂽ��Ԃŉ��
  �X�N���[���������͂��̂ǌĂяo���Ă���
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


// �t�@�N�g���[���\�b�h //////////////////////////////////////////////

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


// �`��p�����[�^�[�C�x���g�n���h�� //////////////////////////////////

procedure TEditor.ViewChanged(Sender: TObject);
(*
  �`�悷�邽�߂̃p�����[�^���ω������ꍇ�͂����ւ���Ă���
  TEditorCaret, TEditorMarks, TEditorMargin, TEditorViewInfo
  TEditorRuler, TEditorLeftbar �I�u�W�F�N�g�� OnChange ��
  Assign ����Ă���
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


// Imagebar, Leftbar, Ruler �֘A //////////////////////////////////////////////

(*
  #Leftbar, #Ruler

  �}�[�W�����ւ̕`��́A�쐬�����r�b�g�}�b�v�� CopyRect ���Ă���B
  �s�ԍ��� DrawTextRect ���\�b�h�𗘗p���Ă���B
  �r�b�g�}�b�v�́A
    �ERect(0, 0, LeftMargin, TopMargin) �ɕ`�悳��� FOriginBase
    �ERuler �ɕ`�悳���r�b�g�}�b�v�Q
    �ELeftbar �̉��ɕ`�悳��� FLeftbarEdge
  �� CreateMarginBitmaps �Ő�������A���ꂼ����������E�X�V����
  ���\�b�h�Q���p�ӂ���Ă���B�������E�X�V�ɂ́AFFontWidth �̒l��
  �K�v�Ƃ���̂ŁAHandleAllocated �� True ��Ԃ��܂Ŏ��s����Ȃ��B
  ���̂܂ܕ��u���Ă����Ə���������Ȃ��܂܂ɂȂ�̂ŁACreateHandle ��
  �P�x�S���������\�b�h�����s���Ă���B

  �v���p�e�B�̕ύX�C�x���g�ɑ΂��čX�V�����ׂ��f�[�^�ɂ���
  -- event --------  -- bitmaps ----------------------  -- data --------------------------------------
                     Rulers  FLeftbarEdge  FOriginBase  FLeftbarColumn  FLeftbarWidth  FImagebarWidth
  CreateHandle         o       o             o            o               o              o
  Imagebar.OnChange                          o                                           o
  Leftbar.OnChange             o             o            o               o
  Margin.OnChange      o                     o                            o
  Ruler.OnChange       o                     o
  CMFontChanged        o                     o                            o
  CMColorChanged       o                     o
  ������̍X�V                               o            o               o
  ExchangeList                               o            o               o
  WrapOption.OnChange                        o            o               o

  �������E�X�V���\�b�h�Q
  AdjustImagebarWidth;
  AdjustLeftbarColumn;
  AdjustLeftbarWidth;
  AdjustRulerHeight;
  InitLeftbarEdge;
  InitRulerBitmaps;
  InitOriginBase;

  InitDrawInfo �ł͈ȉ��̏��������\�b�h�����s����Ă���B
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
      { $OriginBase ... FOriginBase �֏\������ Edge ��t����ꍇ
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
  Leftbar �̊e�v���p�e�B�l�ƁA������I�u�W�F�N�g FList �̍s����
  �����ĕ\������ FLeftbarColumn ���X�V����B�X�V���������ꍇ��
  True ��Ԃ�

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
  Leftbar �̊e�v���p�e�B�l�ƁAFLeftbarColumn ��
  �����ĕ\�������X�V����B
*)
begin
  if not FLeftbar.FVisible then
    FLeftbarWidth := 0
  else
    FLeftbarWidth := FLeftbar.FLeftMargin +
                     FLeftbarColumn * FFontWidth +
                     FLeftbar.FRightMargin + 2; // 2 �� FLeftbarEdge �̕�
end;

procedure TEditor.UpdateLeftBarWidth(OldWidth, NewWidth: Integer);
(*
  OldWidth, NewWidth �̍����ɑ΂����ʃX�N���[���ƍX�V���s��
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
  �w��s�Ԃ̍s�ԍ������𖳌����� UpdateWindow ����
  TEditorScreen.Update �̃w���p�[���\�b�h�Ƃ��ė��p����Ă���B
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
  // FLeftbarEdge: TBitmap �� Leftbar.Edge �v���p�e�B�l�ɉ��������m
  // �ɕ`�悳��Ă��� FRulerEdge �Ƃ͈Ⴄ
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
      // �����l 0 base
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
      // FList.Count < Sr �̏ꍇ�� N ���s��ɂȂ邪�A�`�悳��Ȃ��̂ŁA
      // �Q�Ƃ���邱�Ƃ͖����B���A�R���p�C�����{��̂� -1 ������B

      // �`�悳�ꂴ�鏉���l��������
      if (Sr <> 0) and (ListRows(Sr - 1) <> raCrlf) then
        Inc(N);

      for I := Sr to Er do
      begin
        if (I = 0) or (ListRows(I - 1) = raCrlf) then
        begin
          //  procedure �� procedure �͒x���̂ŁA�x�^�ɓ������[�`���������Ă���
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
      Bitmap.Canvas.CopyMode := cmSrcAnd; // �}�X�N�� AND
      Bitmap.Canvas.CopyRect(D, FRulerDigitMask.Canvas, S);
      // �}�X�N�𔽓]
      InvertMask;
      // PenColor
      Digit.Canvas.Brush.Color := PenColor;
      Digit.Canvas.FillRect(Digit.Canvas.ClipRect);
      Digit.Canvas.CopyMode := cmSrcAnd; // �}�X�N�� AND
      Digit.Canvas.CopyRect(D, FRulerDigitMask.Canvas, S);
      // ����
      Digit.Canvas.CopyMode := cmSrcPaint; // OR
      Digit.Canvas.CopyRect(D, Bitmap.Canvas, S);
      // �}�X�N�����ɖ߂�
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
    // �h��Ԃ���
    if FRuler.FBkColor = clNone then
      Brush.Color := Color
    else
      Brush.Color := FRuler.FBkColor;
    FillRect(ClipRect);
    // �P��悾������`��
    if FRuler.FColor = clNone then
      Pen.Color := Self.Font.Color
    else
      Pen.Color := FRuler.FColor;
    Pen.Width := 1;
    // �c��
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
    // ����
    if not FRuler.FEdge then
    begin
      MoveTo(0, FRulerHeight - 1);
      LineTo(W, FRulerHeight - 1);
    end
    else
      Draw(0, FRulerHeight - 2, FRulerEdge);
  end;
  // �R�s�[
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
    X := LeftMargin + (ACol - TC) * C + 1; // + 1 �̓Q�[�W�̐���
    D := Rect(X, 0, X + C - 1, FRulerHeight - 1); // - 1 �̓Q�[�W�̐���
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


// �C�x���g�n���h���Ăяo�� /////////////////////////////////////////

procedure TEditor.DoCaretMoved;
begin
  if Assigned(FOnCaretMoved) then
    FOnCaretMoved(Self);
end;

procedure TEditor.DoChange;
(*
  ������ɕω����������ꍇ�́A�����ւ���Ă���
  BeginUpdate ��Ԃł����ɓ��邱�Ƃ͂Ȃ��Bcf.TStringList.Changed

  �݌v���̃v���p�e�B�G�f�B�^�ɂ�� Lines �v���p�e�B�̍X�V�ł́A
  Assign, Add, Insert �Ȃǂ����s����邱�ƂȂ������ւ���Ă���
  �i SetOrdValue �Ƃ͂����������̂炵���j������ FWordWrap �ւ�
  �Ή��������s��
*)
var
  W: Integer;
begin
  // �݌v���̕�����ύX�� WordWrap �̏���
  if (csDesigning in ComponentState) and WordWrap then
  begin
    FList.WrapLines;
    FList.InitBrackets;
  end;
  // TEditorScreen �֒ʒm���ĕ`�悷��
  FScreen.Update;
  // �s�ԍ��\�����E�����X�V
  if FLeftbar.FVisible and FLeftbar.FShowNumber and AdjustLeftbarColumn then
  begin
    W := FLeftbarWidth;
    AdjustLeftbarWidth;
    InitOriginBase;
    UpdateLeftbarWidth(W, FLeftbarWidth);
    AdjustColCount;
  end;
  // �X�N���[���o�[�X�V
  InitScroll;
  // �������ύX���Ă��Ȃ��Ă��ABeginUpdate, EndUpdate �����
  // OnChange �C�x���g����������̂�������邽�߂ɁA
  // FList.FDrawInfo.NeedUpdate �𔻕ʂ���
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

// �v���p�e�B�̃A�N�Z�X���\�b�h /////////////////////////////////////

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
          Inc(Result, Length(Copy(S, Idx, L)) + 2); // + 2 �� #13#10
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
        // �f�[�^�擾
        if FSelectionMode = smLine then
        begin
          // smLine
          // �Ō�̍s�܂� BufList �Ɏ擾���� Result := BufList.Text;
          // �Ƃ���ƁA������̍Ō�� #13#10 ���t������邽�� Er - 1 �Ƃ���
          // ��芸�����̈�m�ہi���̕��������j
          for I := Sr to Er - 1 do
            BufList.Add('');
          Idx := 0;
          S := '';
          for I := Sr to Er - 1 do
          begin
            Str := ListStr(I);
            if I = Sr then
              // �P�s��
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
          // �s�v�ɂȂ����s�̍폜
          while Idx <= BufList.Count - 1 do
            BufList.Delete(Idx);
          // BufList �ɒǉ�����Ȃ�����������ƍŌ�̍s��ǉ�
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
  #MaxLineCharacter �P�C�O�O�O�����ɂ���

  �L�����b�g�̈ړ�
  �P�C�O�O�O�����ڂ̌�Ƀ��^�[���L�[����͏o����悤�ɂ��邱�ƂƁB
  �P�C�O�O�O�����ڂ��S�p�P�o�C�g�ڂ̏ꍇ�͂P�C�O�O�P�����ڂ̌��܂�
  �ړ��\�Ȏd�l�Ƃ��邽�� Value �̍ő�l�� MaxLineCharacter + 1
  �Ƃ���B�P�C�O�O�O�����ڂ��S�p�P�o�C�g�ڂ��ǂ����̔��ʂ� AdjustCol
  �ōs���Ă���B

  �`��
  FDxArray �� MaxLineCharacter + 1 �����̕`��ɑΉ����Ă���B
  DrawTextRect �ł́A�����̕����񂪂P�C�O�O�O�������z����ꍇ�A����
  ��������P�C�O�O�O�����ڂ��S�p�P�o�C�g�ڂ̏ꍇ�͂P�C�O�O�P�����ɁA
  �����łȂ��ꍇ�͂P�C�O�O�O�����ɐ��`���Ă���`�悵�Ă���B
  PaintLine, PaintLineSelected �ł��A���s�}�[�N�AEOF �}�[�N��`��
  ����ہA�P�C�O�O�O�������z���邩�ǂ����A�S�p�P�o�C�g�ڂ��ǂ�����
  ���ʂ��s���Ă���B
*)

  // �� ��� FRow ���ݒ肳��Ă��Ȃ���΂Ȃ�Ȃ�

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
  #HitSelLength ....... ������v������̕`��ɂ���

  �� HitStyle, HitSelLength �v���p�e�B
  
  ver 2.30 �ł́A������v������̕\�������ƕ`��F���w��o����悤�ɂ����B
  �w�i�F�E�O�i�F�� View.Colors.Hit.BkColor, Color �v���p�e�B�ɕێ������
  ����B�\�������� TEditorHitStyle �ŕ\�������

  TEditorHitStyle
    hsSelect ... �]���^�̑I�����
    hsDraw ..... View.Colors.Hit �ɕێ������w�i�F�E�O�i�F�ŕ`��
    hsCaret .... ������v�����񒷂̃L�����b�g���쐬���_�ł�����
                 �i�܂�Ԃ��A���s���܂ރq�b�g������ɂ͔�Ή��j

  ������v��������w��F�ŕ`�悳����ꍇ�́AHitStyle �v���p�e�B�� hsDraw
  ���w�肵�A�L�����b�g��\��������ꍇ�� hsCaret ���w�肵�Ă��� 
  HitSelLength �v���p�e�B�Ɍ�����v�����񒷂�������B

  �� �I��̈�f�[�^�̗��p
  
  �ȉ��ł́AhsDraw, hsCaret �����̎����ɂ��ċL�q����B

  ������v������̎w��F�`��́A�I��̈�̍쐬�ɕK�v�ȃf�[�^��d�g�݂�
  ���̂܂ܗ��p���A�w�i�F�E�O�i�F��ύX���邾���ŗǂ����ƂɂȂ邪�ADelphi
  �̃R�[�h�G�f�B�^�̂悤�ɁA�u�I����Ԃł͂Ȃ��v��Ԃ����o���Ȃ����
  �Ȃ�Ȃ��B
  �����ŁATEditorSelectionState �� sstHitSelected ���ڂ�ǉ����A�`���
  �K�v�ȃf�[�^��d�g�݂͑I��̈�̂��̂𗬗p���邪�A�I����Ԃł͂Ȃ����
  �����o�����Ƃɂ���B
  
  �`�揈���𔺂�Ȃ� hsCaret �̏ꍇ�ł��A���L�̒u�������������l������
  �I��̈�f�[�^�̏������E�X�V���s�����Ƃɂ���B�i�u�������� hsCaret��
  �g���Ȃ�����q����j
  
  ���ۂɂ́ASetHitSelLength ���\�b�h�ŁAHitStyle �� hsDraw, hsCaret �̏ꍇ
  FHitSelecting �t���O�𗧂Ă邱�Ƃɂ���āAStartSelection ���\�b�h�ł�
  ��ԑJ�ڂ��R���g���[������B

    sstSelected ...... �]���̑I����ԁB
    sstHitSelected ... ������v�������\�����Ă����ԁB
                       = hsDraw or hsCaret ���

  �u�������������s���ꍇ�A�ʏ�A�Y���������I��������Ԃ� SelText �v���p
  �e�B�ɒu������������������邪�AsstHitSelected �͑I����Ԃł͂Ȃ��̂�
  ���̏������s���Ȃ��B�����ŁAsstHitSelected ��Ԃ� sstSelected ��ԂɕύX
  ���郁�\�b�h HitToSelected ��p�ӂ���B
  
  �I����ԂƂ��Ĉ������߂ɂ́AsstHitSelected ��Ԃ��I��̈�f�[�^�𐳂���
  �ێ����Ă���K�v������̂ŁAhsCaret �̏ꍇ���I��̈�f�[�^���������E�X
  �V����d�l�Ƃ���̂͑O�q�̒ʂ肾���AhsCaret �̏�ԂŒu�������m�F�_�C�A
  ���O���o���ƁATEditor ���t�H�[�J�X�������̂ŁA�L�����b�g�������Ă��܂�
  �ǂ����I������Ă���̂����A�����ڔ��ʕs�\�ɂȂ�̂ŁA�u�u������������
  �����錟����v�\���ɂ����āAhsCaret �͎g���Ȃ��v���ƂɂȂ�A�����
  �u�u�������m�F�_�C�A���O���o���u�����������v���s���ۂɂ� hsCaret ���g��
  �Ȃ��悤�ȍH�v�����[�U�[�ɍs���Ē��������@�͖����B
  
  �� ��Ԃ𔻕ʂ��邽�߂̃v���p�e�B
  
  �v���p�e�B     ��Ԃɂ��Ԃ�l                    �Ӗ�                            ���p������
                 sstSelected      sstHitSelected
                 �ʏ�̑I�����   hsDraw   hsCaret
  Selected       o                x        x         sstSelected                     �]���̑I�����ꂽ�����񑀍�ŗ��p�����B

  SelectedData   o                o        o         sstSelected or sstHitSelected   �I��̈�f�[�^��ێ����Ă���̂ŁA�������i�̈��
                                                                                     �m�[�}���`�悷�邩�A�L�����b�g�����ɖ߂��j������
                                                                                     �s���ׂ����ǂ����𔻕ʂ��邽�߂ɗ��p�����B

  SelectedDraw   o                o        x         sstSelected or                  �I��̈�f�[�^�𗘗p���ĕ`�悷�ׂ��ł��邩�A
                                                     (sstHitSelected and hsDraw)     ���͕`�悳��Ă��邩�𔻕ʂ��邽�߂ɗ��p�����B

  HitSelected    x                o        o         sstHitSelected                  �E�L�[���͂ɂ����ẮA�� Selected ��Ԃ̏ꍇ�A�I��
                                                                                       �̈�f�[�^�����������邩�ǂ����̔��ʂɗ��p���A
                                                                                     �ESelectedDraw �ɂ���ĕ��򂵂��I��̈�f�[�^�ɂ��
                                                                                       �`�揈���ɂ����ẮAView.Colors.Select ����
                                                                                       View.Colors.Hit �̂ǂ���𗘗p���邩�̔��ʂɗ��p
                                                                                       �����B

  �� CleanSelection ���\�b�h
  
  CleanSelection ���\�b�h�ł́ASelectedData ��Ԃ��N���A���鏈�����s����B
  �E�I��̈�f�[�^�ɂ��`�悪�s���Ă���ꍇ�i SelectedDraw ��� �j�͂�����
    �m�[�}���`�悷��B
  �E�q�b�g�����񒷂̃L�����b�g���\������Ă���ꍇ��
    �i HitSelected and (HitStyle = hsCaret) �j�L�����b�g�����ɖ߂��B
  �E�܂� FHitSelLength ���O�ŏ��������鏈�����s����B
  
  SetHitSelLength �ł́A�I��̈�f�[�^������������i�K�ŁA���� CleanSelection
  �����s�����̂ŁAFHitSelLength �̍X�V�������̍Ō�ōs���Ă���B

  �� �I����Ԃ̉���

  �]���́ASelected �̒l�𔻕ʂ��đI����Ԃ��������Ă������A���̏�����
  SelectedData �̒l�𔻕ʂ��邱�ƂɂȂ�B�L�[���͎��ɂ́ASelected,
  HitSelected �̑g�����ɂ�锻�ʂ��K�v�ɂȂ�ꍇ������̂Œ��ӁB
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
          // �L�����b�g�ʒu��ۑ�
          R := FRow;
          C := FCol;
          // �I��̈�f�[�^�ݒ�
          FHitSelecting := True;
          try
            SelLength := Value;
          finally
            FHitSelecting := False;
          end;
          if HandleAllocated and Focused then
          begin
            // �L�����b�g�ʒu�𕜋A
            SetRowCol(R, C);
            // �I��̈�f�[�^�𗘗p���āA
            // ������v�����񒷂̃L�����b�g���쐬���A�\������B
            // �����s�ɂ܂�����L�����b�g�͍쐬�o���Ȃ��d�l
            with FSelDraw do
            begin
              if Sr <> Er then
                // �����s�ɂ܂������ăq�b�g���Ă���ꍇ
                CaretWidth := Max(DefaultCaretWidth, FFontWidth * (ExpandListLength(FRow) - Sc))
              else
                // �P��s��ł̕\��
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
  // SelLength �����r���� CleanSelection �� FHitSelLength ���O�ɏ�����
  // �����̂ōŌ�ɍs���B
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
  // �I�𕶎���ړ����͕ύX�o���Ȃ�
  if (FReadOnly <> Value) and not SelDragging then
  begin
    FReadOnly := Value;
    // �I��̈�̒��Ƀ}�E�X�J�[�\��������ꍇ�̂��߂�
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
      // FList.Count �̍s�ɂ��L�����b�g���ړ��\�Ȏd�l�Ƃ���
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
      // -1 ... AdjustCol �őS�p�Q�o�C�g�ڂɓ˓��������͍��ֈړ�����d�l
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
  // �I�𕶎���ړ����͕ύX�o���Ȃ�
  if (FSelectionMode <> Value) and not SelDragging then
  begin
    FSelectionMode := Value;
    if Selected then
    begin
      // �I��̈�̒��Ƀ}�E�X�J�[�\��������ꍇ���l����
      if Value = smBox then
        Cursor := FCaret.FCursors.FDefaultCursor;
      // FSelDraw �̒l�����[�h�ɂ���ĈႤ�̂�
      // ��x�X�V���Ă���ĕ`�悷��B
      UpdateSelection;
      Invalidate;
    end;
    DoSelectionModeChange;
  end;
end;

procedure TEditor.SetSelLength(Value: Integer);
(*
  ���݂̃L�����b�g�ʒu����AValue �Ŏw�肳�ꂽ�������I����Ԃɂ���B
  SelectedData ��ԂɑΉ����Ă���B
  HitSelected and (FHitStyle = hsCaret) �̏ꍇ�́A�L�����b�g�ړ����s�킸��
  �I��̈�f�[�^�̍X�V�������s���B
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
      // �I�𒆂ł���΁A�I��̈�̐擪�ɃL�����b�g���ړ�
      Row := FSelDraw.Sr;
      Col := FSelDraw.Sc;
      // �I����Ԃ̉���
      CleanSelection;
    end;
    Exit;
  end;
  FCaretNoMove := True;
  try
    if SelectedData then
    begin
      // �I�𒆂ł���΁A�I��̈�̐擪�ɃL�����b�g���ړ�
      Row := FSelDraw.Sr;
      Col := FSelDraw.Sc;
    end;
    // �I��̈�̏�����
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
    // [EOF] �ȍ~
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
  // FList �̐擪���當�������J�E���g���AValue ���z��������
  // Row �ɑ΂��� Col ���Z�b�g����
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
  // [EOF] �ȍ~
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
    // �ړ��ʁi�����j���擾
    I := FTopCol - Value;
    // �V�����l��ݒ�
    FTopCol := Value;
    // �������h�b�g���ɕϊ�
    // �����Ŏw�肷�� HScrollInc �́AFLeftScrollWidth �ɒǉ��ۑ������
    // �`��̍ێQ�Ƃ����
    HScrollInc := I * FFontWidth;
    if HScrollInc <> 0 then
    begin
      // �N���b�v���쐬 Ruler ���X�N���[�������邽�� C.Top = 0
      C := Rect(LeftMargin, 0, Width, Height);
      DoScroll(HScrollInc, 0, nil, @C);
      SetScrollPos(Handle, SB_HORZ, FTopCol, True);
      // IME �E�B���h�D�̈ړ�
      if FKeyRepeat then
        FCompositionCanceled := True
      else
        SetImeComposition;
      // OnTopColChange �C�x���g
      DoTopColChange;
    end;
  finally
    CaretEndUpdate;
    // DrawRulerMark �� PaintRuler �Ŏ��s����Ă���
  end;
end;

procedure TEditor.SetTopRow(Value: Integer);
var
  V: Integer;
  C: TRect;
begin
  if not HandleAllocated then
    Exit;
  // �A���X�N���[���̍ہA��ʏ㉺�[�ɃA���_�[���C�����c���Ƃ���
  // �c��̂� UnderlineBeginUpdate ����BCaretBeginUpdate ���s��
  // FTopRow ���ω�����O�� HideUnderline ����
  CaretBeginUpdate;
  UnderlineBeginUpdate;
  try
    // 0..FList.Count - 1
    Value := Max(0, Min(Value, FList.Count));

    { $VScrollMax ... [EOF] ����ʏ�[�ɍs���Ă��܂�Ȃ��悤�ɂ���ꍇ}
    // 0..FList.Count - FRowCount + 1
    // Value := Max(0, Min(Value, FList.Count - FRowCount + 1));

    // �ړ��ʁi�s���j���擾
    V := FTopRow - Value;
    // �V�����l��ݒ�
    FTopRow := Value;
    // �s�����h�b�g���ɕϊ�
    // ��ʍ����ȏ�̃X�N���[���͈Ӗ����Ȃ��B�܂��P����
    // V * (FFontHeight + FMargin.FUnderline + FMargin.FLine) �ł́A
    // Integer �̋��e�͈͂𒴂���ꍇ������̂�
    V := Max(Min(V, FRowCount + 1), (FRowCount + 1) * -1) * GetRowHeight;
    if V <> 0 then
    begin
      // �N���b�v���쐬 Leftbar ���X�N���[�������邽�� C.Left = 0
      C := Rect(0, TopMargin, Width, Height);
      DoScroll(0, V, nil, @C);
      SetScrollPos(Handle, SB_VERT, FTopRow, True);
      // IME �E�B���h�D�̈ړ�
      if FKeyRepeat then
        FCompositionCanceled := True
      else
        SetImeComposition;
      // OnTopRowChange �C�x���g
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
  // InitView; FView.OnChange �� ViewChanged �� Assign ����Ă���
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


// ���b�Z�[�W�n���h�� ///////////////////////////////////////////////

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
  �t�H���g���ς�������̃C�x���g���甭�s����郁�b�Z�[�W
  TControl.CMFontChaged �� Invalidate �����̂ŁA
  �����ł� InitView �Ăяo�����s��Ȃ�
*)
begin
  if HandleAllocated then
  begin
    // ���X�N���[����Ԃ��������āAFLeftScrollWidth ������������
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
            // FCol ���w�������C���f�b�N�X�i�O�x�[�X�j
            Si := C - IncludeCharCount(Attr, caTabSpace, C + 1);
            if Si > 0 then
            begin
              // �s���ł͂Ȃ�
              S := ListStr(R);
              L := Length(S);

              (*

                �o�b�N�X�y�[�X�A���C���f���g

                // ����

                �L�����b�g�ʒu���s���łȂ��ꍇ
                Caret.BackSpaceUnIndent �� True �ŁA�Y���s��

                �E'' ���A
                �E���p�󔒁A�S�p�󔒁A�^�u���������ō\������Ă��邩�A
                �E��L�󔒂̌�ɑ���������̐擪�ɃL�����b�g������

                �ꍇ�ɁA���݂̃L�����b�g�ʒu�����������s���󔒐���
                ���s���Y���s����k���ĒT���A���̈ʒu�܂ŃA���C��
                �f���g����B

                // ����̒�`

                �Y���s�̕����񂪁A�s������V�����L�����b�g�ʒu�܂ł�
                ������ƌ��݂̃L�����b�g�ʒu����I�[�܂ł̕������
                �u�������B

                �Y���s�����񒷂��V�����L�����b�g�ʒu�ȉ��̏ꍇ��
                �L�����b�g���ړ����邾���Ƃ���B

                �V�����L�����b�g�ʒu��
                �E�^�u�������̏ꍇ�͂��̃^�u�����𔼊p�󔒂ɒu��������
                �E�S�p�󔒂̂Q�o�C�g�ڂ̏ꍇ�͔��p�󔒂ɒu��������

              *)

              Ts := TabbedTopSpace(S); // S = '' �̏ꍇ Ts = -1
              if FCaret.FBackSpaceUnIndent and
                 ((Ts = -1) or              // S = ''
                  (Ts = Length(Attr)) or    // �󔒂����̍s�i�P�O�O�O�����ȏ�̋󔒂̌�ɔ�󔒕���������ꍇ�������ΏۂɂȂ�d�l�j
                  (Ts = C)) then            // �󔒂ɑ���������̐擪
              begin
                // �V�����L�����b�g�ʒu���擾
                Rs := FList.RowStart(R);
                Ri := R;
                // �܂�Ԃ��W������Ă���s Rs + 1..R �̒��ɂ���
                // 0 �łȂ� C ��菬�����󔒐���
                // Rs ���܂ޏ�̍s�ɂ��� 0 ���܂� C ��菬����
                // �󔒐���T��
                repeat
                  Dec(Ri);
                  Pts := Max(0, TabbedTopSpace(ListStr(Ri))); // -1 ���Ԃ�ꍇ������̂� Max(0,
                until (Ri <= 0) or
                      ((Rs < Ri) and (Pts <> 0) and (Pts < C)) or // exclude 0
                      ((Ri <= Rs) and (Pts < C));                 // include 0
                if Pts >= C then
                  // C ��菬�����󔒐���������Ȃ������ꍇ�͂O
                  Pts := 0;
                if Pts >= Length(Attr) then
                  // �L�����b�g�̈ړ��̂�
                  Col := Pts
                else
                begin
                  // ��������X�V
                  // �V�����L�����b�g�ʒu���O�̕�������擾
                  I := Pts;
                  J := 0;
                  // �V�����L�����b�g�ʒu�ɊY�����镶���C���f�b�N�X�i�O�x�[�X�j
                  Bsi := I - IncludeCharCount(Attr, caTabSpace, I + 1);
                  if IndexChar(Attr, I + 1) = caDBCS2 then
                  begin
                    // �S�p�󔒂Q�o�C�g�ڂ̏���
                    Dec(Bsi);
                    Inc(J);
                  end
                  else
                    // �^�u���W�J���ꂽ�����̏���
                    while IndexChar(Attr, I + 1) = caTabSpace do
                    begin
                      Dec(I);
                      Inc(J);
                    end;
                  Buf := Copy(S, 1, Bsi) + StringOfChar(#$20, J);

                  // ���݂̃L�����b�g�ʒu����I�[�܂ł̕������ǉ�
                  J := 0;
                  if IndexChar(Attr, C + 1) = caTabSpace then
                  begin
                    // �^�u���W�J���ꂽ�����̏���
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
                  // ���������������̏I�[
                  if IndexChar(Attr, C) = caDBCS2 then
                    Dc := 2 // delete count
                  else
                  begin
                    Dc := 1;
                    // Caret.InTab = True �Ń^�u�������� FCol ������ꍇ��
                    // Si + 1 ���^�u�������w���Ă���̂ł��̃^�u������
                    // �폜����悤�� Si ���ЂƂi�߂�
                    if IndexChar(Attr, C + 1) = caTabSpace then
                      Inc(Si);
                    while IndexChar(Attr, C) = caTabSpace do
                      Dec(C);
                  end;
                  // �L�����b�g�ʒu��␳
                  Dec(C, Dc);
                  Rs := Max(FList.RowStart(R), R - 1);
                  SelIndex := GetSelIndex(Rs, R, C);
                  // �P�s�����񂩂�폜
                  Delete(S, Si + 1 - Dc, Dc);
                  // put
                  FList.CheckCrlf(R, S);
                  CaretBeginUpdate;
                  try
                    FList.UpdateList(R, 1, S);
                    // �L�����b�g��ݒ�
                    SetSelIndex(Rs, SelIndex);
                  finally
                    CaretEndUpdate;
                  end;
                end
                else
                  // ������̏I�[�����E��
                  Col := Col - 1;
            end
            else
              // �s���ɃL�����b�g������̂ŁA���ݍs�������A���
              // �P�s��̍Ō���ֈړ�
              if R > 0 then
              begin
                // �V�����L�����b�g�ʒu
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
            // TabbedTopSpace ���擾����̂� Min(RowStart(FRow), FRow - 1)
            // �ł͂Ȃ�
            // ���^�[���L�[�ɂ��ʏ�̃L�����b�g�ʒu
            C := 0;
            // �I�[�g�C���f���g���̃L�����b�g�ʒu
            if FCaret.FAutoIndent then
            begin
              // �s���̋󔒂��擾
              I := TabbedTopSpace(ListStr(Rs));
              if I > 0 then
                // �L�����b�g�ʒu�ƁA�󔒐��̏�������
                if (FRow = Rs) and (FCol < I) then
                  C := FCol
                else
                  C := I
              else
                if FCaret.FPrevSpaceIndent and (Rs = FRow) and (S = '') then
                  // ���ݍs���󔒂̏ꍇ�͏���̃C���f���g�ʒu���擾
                  C := Max(0, PrevTopSpace(Rs)); // -1 ���Ԃ�ꍇ������
            end;
            if ssShift in Shift then
            begin
              // �C���f���g���ꂽ�V�����s��}��
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
              // ���ʂ̃��^�[������
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
      VK_BACK, VK_TAB, VK_RETURN �ȊO�� CharCode �̏���
      ���p������ #$20..#$7E, #$A0..#$FF ����������BChr(CharCode) ��
      LeadBytes �̏ꍇ�́A���b�Z�[�W�L���[���玟�� WM_CHAR ����荞��
      �ŁA�Q�o�C�g�����Ƃ��ď�������Ƃ��� TMemo ���S�݊��d�l�ł���B
      ����ɂ���āAWM_IME_CHAR ���b�Z�[�W�ɂ��Ή��o����悤�ɂȂ����B

      �������A����R�[�h���܂� WM_IME_CHAR ���|�X�g���ꂽ�ꍇ�A
      PutStringToLine ���\�b�h�ȉ��̏����ɂ����ẮA���̃f�[�^���^����
      ������ł��邱�Ƃ�O��Ƃ��Ă���̂ŁA���X�g�G���[�Ȃǂ̕s���
      ������ꍇ������BPeekMessage ����ۂɂ́A���ꂪ $40..$FF �ł���
      ���ǂ����𔻕ʂ��Ă���B
        SendMessage(Editor1.Handle, WM_IME_CHAR, $820D, 0);
        SendMessage(Editor1.Handle, WM_CHAR, $8F, 0);
      �Ȃǂ����s����Ɓu���v�̕��� ($8F82) �����͂��ꂽ��u���s�����v
      �Ƃ��낪 TMemo �Ƃ͈���Ă���B�ڍׂ� #WM_IME_COMPOSITION �R�����g
      ���Q�Ƃ̂��ƁB

      WM_IME_COMPOSITION ���b�Z�[�W�n���h���Őݒ肳�ꂽ FImeCount ���f�N
      �������g���鏈�����s���Ă���B
      IME ���� [#$20..#$7E, #$A0..#$FF], LeadBytes �ȊO�̕�������͂���
      ���Ƃ͏o���Ȃ��Ƃ����O��� FImeCount ���f�N�������g���Ă���B
    *)
    if Message.CharCode in [$20..$7E, $A0..$FF] then
    begin
      // �P�o�C�g����
      if FImeCount > 0 then
        Dec(FImeCount)
      else
        if not FReadOnly then
        begin
          // IME Window �̈ʒu�ݒ�m�F
          if FCompositionCanceled then
            SetImeComposition;
          PutStringToLine(Chr(Message.CharCode));
        end;
    end
    else
    begin
      // �Q�o�C�g����
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
    �X�N���[���{�^���ɂ�鉡�X�N���[���ʂ���ʂ̂S���̂P�Ƃ���ꍇ��
    �ȉ��̒ʂ�
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
  WM_IME �̂���ė��鏇��
  1. WM_IME_STARTCOMPOSITION
  2. WM_IME_NOTIFY ( IMN_OPENCANDIDATE )
  3. WM_IME_COMPOSITION ( GCS_RESULTSTR )
  4. WM_IME_ENDCOMPOSITION
  5. WM_IME_NOTIFY ( IMN_CLOSECANDIDATE )

  ��

  MSIME95 ���g�p���āA�S�p�X�y�[�X����͂����
  WM_IME_STARTCOMPOSITION �͗��Ă��Ȃ����ǁA
  WM_IME_ENDCOMPOSITION �����������������Ă��錻�ۂ�
  ���邽�߁Aver 0.61 �Ŏ������� WMImeStartComposition,
  WMImeEndComposition ���b�Z�[�W�n���h���� ver 0.63 �ł�
  �폜����
*)

(*
  #WM_IME_COMOISITION 
  
  IME ����̓��͏����ɂ��� 2002/05/31

  IME �ł̓��͂��m�肵�����_�� TEditor �� WM_IME_COMPOSITION ���b�Z�[�W
  ���󂯎��BWM_IME_COMPOSITION ���b�Z�[�W�n���h���ł́AIME ����m�蕶
  ������擾���APutStringToLine ���\�b�h��ʂ��ĕ�������X�V���Ă���B
  
  �܂��AWM_IME_COMPOSITION ���b�Z�[�W�́A���b�Z�[�W�n���h������ 
  inherited; �����s�������ɁAWindows �ɂ�鏈�����s����B
  
  ���̎��AWindows �͊m�蕶����̕��������� WM_IME_CHAR ���b�Z�[�W���E�C
  ���h�v���V�[�W���ɑ�����ė���BWM_IME_CHAR ���b�Z�[�W�� Windows ��
  ����āA�S�p�����͂Q�́A���p�����͂P�� WM_CHAR ���b�Z�[�W�ɕϊ���
  ��A���x�́A���b�Z�[�W�L���[�ɗ��߂���B
  
  �Ⴆ�΁A'����������' �� IME ������͂��ꂽ�ꍇ�A�i ' �͏����jTEditor 
  �� WM_IME_COMPOSITION ���󂯎�� '����������' ����������B�������� 
  inherited; �����s�������_�ŁA�T�� WM_IME_CHAR ���󂯎��B�iTEditor 
  �� WM_IME_CHAR ���b�Z�[�W���������邱�Ƃ͂��Ȃ����A��q����j���̌�A
  ��������i���������_�Ń��b�Z�[�W�L���[�����ɍs���ƂP�O�� WM_CHAR ��
  ���܂��Ă���Ƃ�������ɂȂ�B
  
  ���̗��܂��Ă���P�O�� WM_CHAR �͖������Ȃ���΂Ȃ�Ȃ��̂ŁA
  TEditor �ł́AWM_IME_COMPOSITION ���b�Z�[�W�n���h�����ŁA�����񒷂�
  �L�����Ă����AWM_CHAR ���b�Z�[�W�n���h�����ŁA�L�������l���� WM_CHAR
  ���b�Z�[�W�𖳎��������������Ă���BFImeCount �����̂��߂̕ϐ��B
  
  ���āA�ٍ� TKeyMacro �R���|�ɑΉ����邱�ƂƁA���[�U�[�� WM_IME_CHAR,
  WM_CHAR ���b�Z�[�W�� TEditor �� SendMessage ����ꍇ�ɂ��čl����B
  
  Windows �W���R���g���[���� TMemo, TEdit �Ȃǂł́A�Ⴆ��
  SendMessage(Memo1.Handle, WM_IME_CHAR, $82A0, 0);
  �Ƃ��邱�ƂŁA'��' ��\�������邱�Ƃ��o���邪�A����� Windows �ɂ��
  �� WM_IME_CHAR -> �Q�� WM_CHAR �Ƃ����ϊ����s��ꂽ��AWM_CHAR ���b
  �Z�[�W�n���h���ŏ�������Ă���̂ł͂Ȃ����v����B�ȉ��̎����Ŏ���
  �o����Ǝv���B
  PostMessage(Memo1.Handle, WM_CHAR, $A0, 0); // �Q�o�C�g�ڂ��L���[�ɗ��߂�
  SendMessage(Memo1.Handle, WM_CHAR, $82, 0); // �P�o�C�g�ڂ�����������
  �܂�A��L�W���R���g���[���� WM_CHAR ���b�Z�[�W�n���h���ł́A
  �S�p�P�o�C�g�ڂ��󂯎�������A���b�Z�[�W�L���[�ɗ��܂��Ă���ł��낤
  �Q�o�C�g�ڂ��L���[������o���đS�p�P�����Ƃ��ď������Ă���Ǝv���
  ��B
  
  TEditor �ł��A���̕������̗p���Ă���BWM_CHAR ���b�Z�[�W�n���h���őS
  �p�P�o�C�g�ڂ��󂯎�����ꍇ�A���b�Z�[�W�L���[���玟�̂Q�o�C�g�ڂ���
  ��o���ď������Ă���B�������邱�ƂŁAWM_IME_CHAR ���b�Z�[�W�̏�����
  �L�����Z�����Ă���B
  
*)

procedure TEditor.WMImeComposition(var Msg: TMessage);
var
  Imc: HIMC;
  L: Integer;
  S: String;
begin
  inherited;
  // WM_IME_CHAR ���b�Z�[�W�����s����AIME �����񒷕��� WM_CHAR ��
  // Windows �� DefWindowsProc �ɂ���ă|�X�g�����B
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
          // debug �Ƃ肠�����ړ����Č��ē����Ă��Ȃ���� cf AdjustCol
          C := FCol;
          Col := Col + 1;
          if (FCol = C) and (FRow < FList.Count) and
             (FList.Rows[FRow] <> raEof) and
             (FCaret.FNextLine or (FList.Rows[FRow] = raWrapped)) then
          begin
            // ��s���ֈړ�����̂�������̂�
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
          // �L�����b�g�� FList �ɏ���Ă���Ƃ�������������
          R := FRow;
          C := FCol;
          S := FList[R];
          L := Length(S);
          Attr := StrToAttributes(S);
          Si := C - IncludeCharCount(Attr, caTabSpace, C + 1);
          if Si < L then
          begin
            // �L�����b�g����������ɂ���ꍇ�̏���
            if IndexChar(Attr, C + 1) = caDBCS1 then
              Dc := 2
            else
            begin
              Dc := 1;
              // Caret.InTab = True �Ń^�u�������� FCol ������ꍇ��
              // �L�����b�g�ʒu����
              while IndexChar(Attr, C + 1) = caTabSpace do
                Dec(C);
            end;
            Rs := Max(FList.RowStart(R), R - 1);
            SelIndex := GetSelIndex(Rs, R, C);
            // �P�s�����񂩂�폜
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
            // �L�����b�g��������̍Ō�����A�󔒒��ɂ���ꍇ�̏���
            // raEof or raCrlf �ȍs���ł������蓾�Ȃ� cf. AdjustCol
            if FList.Rows[R] = raEof then
              Exit;
            // �ȉ��� raCrlf �ȍs���ȍ~�ł̏���
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
  // �L�[���s�[�g��Ԃ����������̂ŁASetImeComposition ����
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
      // �L�����b�g���ړ�����O�̏�ԂőI��̈�f�[�^������������
      InitSelection;
    // �L�����b�g�ʒu�擾�E�ړ��E�I����Ԃֈڍs�܂��͍ē�
    PosToRowCol(Message.XPos, Message.YPos, R, C, True);
    SetRowCol(R, C);
    SetSelection;
  end
  else
  begin
    L := LeftMargin;
    // �I��̈�̊J�n�ʒu�ɂȂ邩������Ȃ��|�C���g���擾
    FMouseSelStartPos.X := Message.XPos;
    FMouseSelStartPos.Y := Message.YPos;
    // �h���b�O�̔���
    PosToRowCol(Message.XPos, Message.YPos, R, C, False);
    if CanSelDrag and (L <= Message.XPos) and IsSelectedArea(R, C) then
    begin
      // �I��̈���ɃL�����b�g���ړ�
      SetRowCol(R, C);
      if FCaret.FSelDragMode = dmAutomatic then
      begin
        // WM_LBUTTONUP �𔭍s���āAcsLButtonDown �� ControlState ����
        // ��菜���AMouseCapture �v���p�e�B����������
        Perform(WM_LBUTTONUP, 0, Longint(PointToSmallPoint(Point(Message.xpos, message.ypos))));
        // �t���O�ݒ�
        InitSelDrag;
      end;
    end
    else
    begin
      // �L�����b�g�ʒu�擾
      PosToRowCol(Message.XPos, Message.YPos, R, C, True);
      // ���t�g�}�[�W�����ł̂P�s�I��
      if (Message.XPos < L) and FCaret.FRowSelect then
        StartRowSelection(R)
      else
      begin
        CaretBeginUpdate;
        try
          // �L�����b�g���ړ����āA�I��̈�f�[�^��������
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
    // �I�𕶎���ړ������̏I��
    // �������� WM_MOUSEMOVE ���������A�����ŃJ�[�\�����߂�
    EndSelDrag
  else
    if FSelDragState = sdInit then
      // �I��̈���ō��{�^�������������āA�h���b�O�����Ƀ{�^���𗣂���
      // �ꍇ�̏���
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
    // �L�����b�g�ړ����đI��̈���X�V
    PosToRowCol(Message.XPos, Message.YPos, R, C, True);
    // ������ւ̃X�N���[���ɑΉ�
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
        // WM_LBUTTONDOWN �ŃZ�b�g���� FMouseSelStartPos
        // ���� Threshold �s�N�Z���ȏ�ړ����Ă�����I����Ԃֈڍs����
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
      // �h���b�O�������ς݂̏ꍇ�͈ړ��ʂ𔻕ʂ��ăh���b�O���J�n����
      Threshold := FFontWidth div 2;
      if (Abs(FMouseSelStartPos.X - Message.XPos) >= Threshold) or
         (Abs(FMouseSelStartPos.Y - Message.YPos) >= Threshold) then
        StartSelDrag;
    end
    else
      if SelDragging then
      begin
        // �I��̈�ړ����̓L�����b�g�ړ�����
        PosToRowCol(Message.XPos, Message.YPos, R, C, False);
        // ������ւ̃X�N���[���ɑΉ�
        if Message.YPos < TopMargin then
          R := Max(0, R - 1);
        SetRowCol(R, C);
      end
      else
        // CursorState �̍X�V�B
        if Message.XPos < LeftMargin then
          // ���t�g�}�[�W����
          CursorState := mcLeftMargin
        else
          if Message.YPos < TopMargin then
            CursorState := mcTopMargin
          else
            if CanSelDrag then
            begin
              PosToRowCol(Message.XPos, Message.YPos, R, C, True);
              if IsSelectedArea(R, C) then
                // �I��̈��
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
    { SB_THUMBxxx �ł͂P�U�r�b�g�l���������Ȃ�}
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

  { $VScrollMax ... [EOF] ����ʏ�[�ɍs���Ă��܂�Ȃ��悤�ɂ���ꍇ}
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


// �X�N���[�� ///////////////////////////////////////////////////////

(*
  #Scroll

  �X�N���[���́ASetTopRow, SetTopCol �ɏW�񂳂�A������ FTopRow,
FTopCol ���ݒ肳��Ă���BWMVScroll, WMHScroll ���b�Z�[�W�n���h��
�ł́A�X�N���[���o�[�ɂ��X�N���[����A���[�U�[�̃��b�Z�[�W���s��
���X�N���[���ɑΉ����� TopRow, TopCol �l��ω������Ă���

�X�N���[���̈�̐ݒ�ł́ARect ��ݒ肵�Ă�n���� Windows �ɂ����
�L�����b�g�ʒu�����߂���Ă��܂��AFCol �̂���ׂ��ꏊ�Ƃ���Ă��܂�
�̂ŁAnil ��n���ĉ�ʑS�̂��X�N���[������ ClipRect �ɂ��̗̈��
�ݒ肵�ēn������
*)

procedure TEditor.DoScroll(X, Y: Integer; Rect, ClipRect: PRect);
(*
  ScrollWindowEx API ���Ăяo���Ė����̈���ĕ`�悷��
  FLeftScrollWidth �������Őݒ肳���
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

  // �ێ�����镶����̍s������A�c�X�N���[���̍ő�l���擾
  FVScrollMax := Max(0, FList.Count + FRowCount - 1);

  { $VScrollMax ... [EOF] ����ʏ�[�ɍs���Ă��܂�Ȃ��悤�ɂ���ꍇ}
  // FVScrollMax := Max(0, FList.Count);

  FTopRow := Min(FTopRow, FVScrollMax);
  // ���X�N���[���͌Œ�
  FHScrollMax := MaxLineCharacter;
  FTopCol := Min(FTopCol, FHScrollMax - FColCount div 2);
  // FLeftScrollWidth �̒���
  FLeftScrollWidth := FTopCol * FFontWidth;
  if FScrollBars in [ssVertical, ssBoth] then
  begin
    // �c�X�N���[���o�[����ɕ\�����邽�߂�
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
  TEditorScreen.Update �̃w���p�[���\�b�h�Ƃ��ė��p����Ă���B
  Imagebar ������ Line �Ŏw�肳�ꂽ�s����ABottom �܂ł̃N���b�v���쐬��
  �N���b�v���̑S�̈�� Count �Ŏw�肳�ꂽ�s�����X�N���[������
  Count �ɕ��̒l���w�肵���ꍇ�͏�փX�N���[�������
  DoScroll ���\�b�h�� UpdateWindow �����
*)
var
  C: TRect;
  H, V: Integer;
begin
  // �X�N���[���J�n�s�́A��ʓ��ɔ[�߂�
  Line := Min(Max(FTopRow, Line), FTopRow + FRowCount);
  H := GetRowHeight;
  // �N���b�v�̍쐬
  C := Rect(
         0,
         TopMargin + H * (Line - FTopRow),
         FImagebarWidth,
         Height
       );
  // ��ʍ����ȏ�̃X�N���[���͈Ӗ����Ȃ��B�܂��P����
  // (FFontHeight + FMargin.FUnderline + FMargin.FLine) * Count �ł́A
  // Count �̒l�ɂ���Ă� Integer �̋��e�͈͂𒴂���ꍇ������̂�
  V := Max(Min(Count, FRowCount + 1), (FRowCount + 1) * -1) * H;
  DoScroll(0, V, nil, @C);
end;

procedure TEditor.LineScroll(Line, Count: Integer);
(*
  TEditorScreen.Update �̃w���p�[���\�b�h�Ƃ��ė��p����Ă���B
  Line �Ŏw�肳�ꂽ�s����ABottom �܂ł̃N���b�v���쐬��
  �N���b�v���̑S�̈�� Count �Ŏw�肳�ꂽ�s�����X�N���[������
  Count �ɕ��̒l���w�肵���ꍇ�͏�փX�N���[�������
  DoScroll ���\�b�h�� UpdateWindow �����
  �s�ԍ������̓X�N���[�����Ȃ�
*)
var
  C: TRect;
  H, V: Integer;
begin
  // �X�N���[���J�n�s�́A��ʓ��ɔ[�߂�
  Line := Min(Max(FTopRow, Line), FTopRow + FRowCount);
  CaretBeginUpdate;
  UnderlineBeginUpdate; // �c�X�N���[���̂���
  try
    H := GetRowHeight;
    // �N���b�v�̍쐬
    C := Rect(
           LeftMargin,
           TopMargin + H * (Line - FTopRow),
           Width,
           Height
         );
    // ��ʍ����ȏ�̃X�N���[���͈Ӗ����Ȃ��B�܂��P����
    // (FFontHeight + FMargin.FUnderline + FMargin.FLine) * Count �ł́A
    // Count �̒l�ɂ���Ă� Integer �̋��e�͈͂𒴂���ꍇ������̂�
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
  // TopRow ���� [EOF] �ɃL�����b�g���s�������܂ł̓X�N���[������
  if (TopRow = 0) and (Value < 0) then
  begin
    Row := 0;
    Exit;
  end
  else
    if (ListRows(FTopRow) = raEof) and (Value > 0) then
      Exit;
  // �L�����b�g�ʒu�͕ω��������� Value �Ŏw�肳�ꂽ�s�����c�X�N���[������
  // ��ʏ�ł̃L�����b�g�ʒu��ۑ�
  R := FRow - FTopRow;
  CaretBeginUpdate;
  try
    // �X�N���[��
    TopRow := Max(0, Min(FTopRow + Value, FList.Count));
    // �L�����b�g�𒲐�
    Row := FTopRow + R;
  finally
    CaretEndUpdate;
  end;
end;

// �L�����b�g  //////////////////////////////////////////////////////
(*
  �L�����b�g�̃I���E�I�t�́ACareShow, CaretHide ���\�b�h��ʂ��čs���A
  �}�[�W������AClientRect �O�ŃL�����b�g���\������Ȃ��d�l�Ƃ���B
*)

procedure TEditor.AdjustCol(RowChanged: Boolean; Direction: Integer);
(*
  �L�����b�g�ʒu FCol ��␳����

  �P�Dnot FreeCaret and not FreeRow ��Ԃŕ����񒷂��z�����Ƃ���
  �Q�D�S�p�Q�o�C�g��
  �R�Dnot InTab �Ń^�u�����̒�
  �S�DWordWrap �ŕ����񒷈ȏ�̂Ƃ���
  �T�D�P�C�O�O�O�����ڑ΍�

  �␳���鎞�́AFColBuf �Ɍ��݂� FCol ��ۑ��� FColKeeping �t���O��
  �Z�b�g����B

  �Ăяo����
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
  // ���ݍs�̕����������擾
  Attr := StrToAttributes(ListStr(FRow));
  L := Length(Attr);

  // ����s���ł� Col �̕ύX�������������_�ŁA�t���O�̓N���A�����
  // FColKeeping := RowChanged; �ł͂Ȃ����Ƃɒ���
  if not RowChanged then
    FColKeeping := False
  else
    // �ۑ�����Ă���ꍇ�͕��A���Ă���ȉ��̔��ʂɂ��␳���s��
    if FColKeeping then
      FCol := FColBuf;

  // not FreeCaret �ŕ����񒷂��z�����Ƃ���
  if not FCaret.FFreeCaret and (L < FCol) then
  begin
    if FCaret.FKeepCaret then
      if csLButtonDown in ControlState then
        // �}�E�X�ɂ��L�����b�g�ړ��̏ꍇ�͕����񒷂Ƃ���
        KeepCol(L)
      else
        KeepCol(FCol);
    if not FCaret.FFreeRow or not RowChanged or (csLButtonDown in ControlState) then
    begin
      FCol := L;
      if not FCaret.FKeepCaret then
        // �ێ����Ă����␳���N���A����B
        // �������[�Ȃ̂ŁA�ȉ��̔��ʂ� KeepCol ����邱�Ƃ͂Ȃ��B
        FColKeeping := False;
    end;
  end;

  // �S�p�Q�o�C�g��
  if IndexChar(Attr, FCol + 1) = caDBCS2 then
  begin
    KeepCol(FCol);
    Inc(FCol, Direction);
  end;

  // not InTab �Ń^�u�����̒�
  if not FCaret.FInTab and (IndexChar(Attr, FCol + 1) = caTabSpace) then
  begin
    KeepCol(FCol);
    while IndexChar(Attr, FCol + 1) = caTabSpace do
      Inc(FCol, Direction);
  end;

  // WordWrap �ŕ����񒷈ȏ�̂Ƃ���
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

  // �P�C�O�O�O�����ڂ��S�p�P�o�C�g�ڂ̏ꍇ�́A�P�C�O�O�P�����ڂ̌��܂�
  // �ړ��o����d�l�Ƃ���B
  // cf SetCol, FDxArray, DrawTextRect, PaintLine, PaintLineSelected

  // ��́u�S�p�Q�o�C�g�ځv�̏����ɂ���� FCol �� 1002 �̏ꍇ������̂�
  // Dec(FCol) �ł͂Ȃ��AMaxLineCharacter �������Ă���B

  if (FCol > MaxLineCharacter) and
     (IndexChar(Attr, MaxLineCharacter) <> caDBCS1) then
    FCol := MaxLineCharacter;

  // �L�����b�g���ړ�
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
  Caret.TokenEndStop �v���p�e�B�� False �̏ꍇ
  ���݂̌��ԍ��A�s�ԍ��i���ɂO�x�[�X�j�A�������w�肵�Ď��̌��̐擪�̍s�ԍ�
  ���ԍ����擾����B��������� True ��Ԃ�

  Caret.TokenEndStop �v���p�e�B�� True �̏ꍇ
  ���݂̌��ԍ��A�s�ԍ��i���ɂO�x�[�X�j�A�������w�肵��
  �E���݂̌��̍Ō�E���݂̌��̐擪�E���̌��̐擪�E�O�̌��̍Ō�
  �̂����ꂩ�̍s�ԍ����ԍ����擾����B��������� True ��Ԃ�
*)
var
  S: String;
  Rb, Cb, I: Integer;
  Parser: TFountainParser;
  Data: TRowAttributeData;
begin
  // R, C �͍s�ԍ��A���ԍ����󂯎��̂ŁA�O�x�[�X
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
      // �O������
      if (ExpandListLength(R) <= C) and (R < FList.Count) then
      begin
        // �s���̏ꍇ�͎��̍s�̐擪���猟��
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
      // R ��ɖ����ꍇ
      if ListRows(R) = raWrapped then
      begin
        // raWrapped �Ȃ�Ύ��̍s�̐擪�Ɉړ����ďI���i�蔲���j
        Inc(R);
        C := 0;
      end
      else
        // �s���Ɉړ����ďI��
        C := Length(S);
    end
    else
    begin
      // �������
      if C = 0 then
      begin
        // �s���̏ꍇ�́A�P�s��̍s���Ɉړ����Ă����� raCrlf �Ȃ�ΏI��
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
              // �g�[�N���̓r�����Ō�ɃL�����b�g������ꍇ
              C := Parser.SourcePos;
              Exit;
            end
            else
              if (Parser.SourcePos >= C) and (I <> -1) and (I < C) then
              begin
                // �g�[�N���̐擪�ƑO�̃g�[�N���̊ԂɃL�����b�g������ꍇ
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
      // �s���ȍ~�ɃL�����b�g�����邩�A
      // �L�����b�g�ʒu���O�Ƀg�[�N���������ꍇ
      if (I <> -1) and (I < C) then
        // �Ō�̗L���ȃg�[�N���ֈړ�
        C := I
      else
        // �L�����b�g�ʒu���O�Ƀg�[�N���������ꍇ�P�s���
        if 0 < R then
        begin
          Dec(R);
          C := ExpandListLength(R);
        end
        else
          // �O�s�ڂ̏ꍇ�͐擪
          C := 0;
    end;
  finally
    Result := (Rb <> R) or (Cb <> C);
  end;
end;

function TEditor.GetSelIndex(StartRow, ARow, ACol: Integer): Integer;
(*
  ARow, ACol �Ŏw�肳�ꂽ�L�����b�g�ʒu�� StartRow ����n�܂镶��
  �C���f�b�N�X (0 base) ��Ԃ��B
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
  ���݂� FRow, FCol �փL�����b�g���ړ�����
*)
var
  X, Y: Integer;
begin
  if not HandleAllocated or not Focused then
    Exit;
  // �\���ʒu���擾
  SetCaretPosition(X, Y);
  // �L�����b�g���ړ�
  SetCaretPos(X, Y);
  // IME �E�B���h�D���ړ�
  if FKeyRepeat then
    FCompositionCanceled := True
  else
    SetImeComposition;
  // OnCaretMoved �C�x���g
  DoCaretMoved;
end;

procedure TEditor.PosToRowCol(XPos, YPos: Integer;
  var ARow, ACol: Integer; Split: Boolean);
(*
  X, Y �Ŏw�肳�ꂽ�ʒu�� Row, Col �l�� ARow, ACol �֊i�[����B
  Split �� True ���n���ꂽ�ꍇ�͕����Ԃ̃L�����b�g�ʒu��
  False �̏ꍇ�͕����O�̃L�����b�g�ʒu��Ԃ��B
  ���ۂɂ����փL�����b�g���ړ��o���邩�ǂ����̔��ʂ͍s���Ă��Ȃ��B
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
  ���݂� Row, Col �ʒu����ʏ�ɕ\�����邽�߂ɕK�v�������
  ��ʃX�N���[�����s��
*)
begin
  if not HandleAllocated or not Focused then
    Exit;
  // �c�X�N���[��
  // ��ʏ�[�ɏ��������Ȏ��́A�\���P�s�ڂ� FRow �ɂ���
  if FRow < FTopRow then
    TopRow := FRow
  else
    // ��ʉ��[�ɏ��������Ȏ��́A�\���ŉ��s�� FRow �ɂ���
    if FTopRow + FRowCount - 1 < FRow then
      TopRow := FRow - (FRowCount - 1);
  // ���X�N���[��
  // �X�N���[���ʂ͉�ʕ��̂S���̂P�Ƃ���
  // ��ʍ��[�ɏ��������Ȏ�
  if FCol < FTopCol then
    TopCol := Max(0, Min(FCol, FTopCol - (FColCount div 4)))
  else
    // ��ʉE�[�ɏ��������Ȏ�
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
  ARow, ACol �Ŏw�肳�ꂽ�ʒu�� Row, Col ��ݒ肷��B
  ���ۂɐݒ肳���ʒu�́ASetRow, SetCol, AdjustCol �ɂ���Č��܂�
  Row ���ݒ肳�ꂽ���_�Ō��݂� Col �ʒu�ɃL�����b�g���ړ�
  ���悤�Ƃ���d�l�Ȃ̂ŁA������L�����Z������t���O��p�ӂ���
  �w�肳�ꂽ Row, Col �ֈ�C�ɃL�����b�g���ړ����邽�߂̃��\�b�h
  �}�E�X�ɂ��I���������ɑS�p������^�u���������ړ�����ۃL�����b�g��
  ������̂ŁA����ւ̑Ή����K�v
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
    // �S�p�Q�o�C�g�ڂ̏���
    if IndexChar(Attr, ACol + 1) = caDBCS2 then
      Dec(ACol);
    // �^�u�̏���
    if not FCaret.FInTab and
       (IndexChar(Attr, ACol + 1) = caTabSpace) then
      while IndexChar(Attr, ACol + 1) = caTabSpace do
        Dec(ACol);
    Col := ACol;
  finally
    // �t���O���N���A
    FCaretNoMove := False;
    // ���O�ňړ�
    UpdateCaret;
  end;
end;

procedure TEditor.SetSelIndex(StartRow, SelIndex: Integer);
(*
  FList �� StartRow ���當�������J�E���g���ASelIndex ���z��������
  Row �ɑ΂��� Col ���Z�b�g����
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
  // [EOF] �ȍ~
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


// �`�� /////////////////////////////////////////////////////////////

(*
  #Drawing

  DrawTextRect ���\�b�h�����Ă̕`����s���A���t�g�}�[�W���̎����ƕ���
  �Ԋu�𒲐߂��邽�߂� ExtTextOut ���g�p���Ă���B
  InvalidateRow, DoScroll �ōs���� InvalidateRect, ScrollWindowEx �ł�
  �������閳���̈��h��Ԃ��Ȃ��d�l
    InvalidateRect(Handle, @R, False);
    ScrollWindowEx(Handle, X, Y, Rect, ClipRect, 0, @R, SW_SCROLLCHILDREN);
  �Ȃ̂ŁADrawTextRect ����O�ɁA�`��̈�� FillRect ���邩 ETO_OPAQUE
  ��n���K�v������B

  �������`�悷��̈�ɂ���
  �P�s�̍��� RowHeight �� FFontHeight + FMargin.FUnderline + FMargin.FLine
  �ƂȂ��Ă���B�s�ԕ����͕`�悵�Ȃ��B

  ��I����Ԃł̕`��
  �A���_�[���C��������������Ȃ��悤�� FFontHeight �̗̈�ɕ`�悷��B
  �I����Ԃł̕`��
  �A���_�[���C���������h��Ԃ��K�v������̂Łi�Ƃ������A�������Ȃ���
  Margin.Line = 0 �� Underline = True �ȏꍇ�A�P�h�b�g���̎Ȗ͗l���I��
  �̈�ɏo��̂Ŕ������Ȃ��jFFontHeight + FMargin.FUnderline �̗̈�ɕ`��
  ����B

  ���� FMargin.FUnderline �̒��߂́APaintRect ���ŁA�P�s���̗̈�ɐ؂蕪
  ����ۂɍs���Ă���B

  �`��菇

  ��I�����
    �����̈�̔���
    Paint                 ... �����̈�̎擾
    PaintRect             ... �̈�𒲐߂��ĂP�s���������ɐ؂蕪����
                              �^�u��W�J�����`�敶����E�`��ʒu���擾��
                              PaintLine �֓n��
    PaintLine             ... �w��ʒu�֕`�悵�� OnDrawLine �n���h�����Ăяo��

  �I�����
    �����̈�̔���
    Paint                 ... �����̈�̎擾
    PaintRect             ... �̈�𒲐߂��ĂP�s���������ɐ؂蕪����
                              �^�u��W�J�����`�敶����E�`��ʒu���擾��
                              PaintRectSelected �֓n��
    PaintRectSelected     ... FSelDraw �f�[�^���Q�Ƃ��Ȃ���
                              PaintLine, PaintLineSelected ���g�������ĕ`��
    PaintLineSelected     ... �w��ʒu�� View.Colors.Select �̐F�ŕ`�悵��
                              OnDrawLine �n���h�����Ăяo��

  �I��̈�̍X�V
    DrawSelection             SelectionMode �ɉ����� DrawSelectionLine,
                              DrawSelectionBox ���g��������B����炩��
                              PaintLine, PaintLineSelected ���g�������ĕ`��

  �P�C�O�O�O�������z���镶����̈����ɂ���
  DrawTextRect �ł� MaxLineCharacter ���z���镶�����n�����ƁA�����
  MaxLineCharacter �̒����ɒ��߂��Ă���`�悷�邱�Ƃ� ExtTextOut API
  �ɓn����镶���Ԋu�̔z��T�C�Y�ȏ�̕������`�悷�邱�Ƃɂ��G���[
  ��������Ă���BPaintLine, PaintLineSelected �ł́A�n���ꂽ�����̈��
  ��U�h��Ԃ�����ŁAMaxLineCharacter �ɑΉ������V�����̈��ʂɗp��
  ���āADrawTextRect �ɓn���Ă���B
*)

procedure TEditor.CaretBeginUpdate;
begin
  Inc(FCaretUpdateCount);
  if (FCaretUpdateCount = 1) and HandleAllocated and Focused then
    CaretHide;
end;

procedure TEditor.CaretEndUpdate;
begin
  if FCaretUpdateCount > 0 then // ������ IME �΍�
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
  fsUnderline ����_�j���ŕ`�悵�Ȃ��ꍇ�́A���L {$DEFINE DOT_UNDERLINE}
  �� // �ŃR�����g�A�E�g���邱��
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
  // S �̓^�u�������W�J���ꂽ������
  if Showing then
  begin
    Underline := fsUnderline in Canvas.Font.Style;
    if Underline then
      Canvas.Font.Style := Canvas.Font.Style - [fsUnderline];
    if Length(S) > MaxLineCharacter then
    begin
      // �P�C�O�O�O�������z���镶����
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
          // ETO_CLIPPED ���w�肳��Ă��Ȃ��Ă��ARect ���ɃN���b�v���Ă���
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
          // ETO_CLIPPED ���w�肳��Ă��Ȃ��Ă��ARect ���ɃN���b�v���Ă���
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
  // S �̓^�u�������W�J���ꂽ������
  if Showing then
  begin
    if Length(S) > MaxLineCharacter then
    begin
      // �P�C�O�O�O�������z���镶����
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
  �\������ FColCount ���擾����
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
  for I := 0 to MaxLineCharacter do // MaxLineCharacter + 1 ��
    FDxArray[I] := FFontWidth;
  // �\���s��
  H := Height - TopMargin - 5; // Brief �L�����b�g�̂��߂̔�����
  if FScrollBars in [ssHorizontal, ssBoth] then
    H := H - GetSystemMetrics(SM_CYHSCROLL);
  FRowCount := Max(1, H div GetRowHeight);
  // �\������
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
  Index �s�̃A���_�[���C���������c���Ė��������� UpdateWindow �͍s��Ȃ�
  TEditorScreenStrings.UpdateBrackets �̃w���p�[���\�b�h�Ƃ��ė��p�����
  ����B�s�ԍ��\�������͖��������Ȃ�
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
           T + H * (Index - FTopRow) + FFontHeight // �A���_�[���C���������c��
         );
    InvalidateRect(Handle, @R, False);
  end;
end;

procedure TEditor.InvalidateRow(StartRow, EndRow: Integer);
(*
  EndRow �s�̃A���_�[���C���������c���āA�w��s�Ԃ��s�ԍ�������
  �܂߂Ė������������� UpdateWindow ����BFScreen.Update �̃w���p�[
  ���\�b�h�Ƃ��āA������X�V�󋵂ɉ������ĕ`����s�����߁A�s�ԍ�
  ���������������Ă���
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
         0, // �s�ԍ��\��������������
         T + H * (Sr - FTopRow),
         Width,
         T + H * (Er - FTopRow) + FFontHeight // �A���_�[���C���������c��
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
  // Brackets �v���p�e�B�̍X�V
  if FList.Brackets[Index] = InvalidBracketIndex then
    FList.UpdateBrackets(Index, False);
  // �̈� R ��`��
  Canvas.Brush.Color := Color;
  if not FItalicFontStyle then
  begin
    // �̈��h��Ԃ��Ȃ���A�P�s��������P�x�`�悷��
    Canvas.Font.Assign(Font);
    DrawTextRect(R, X, Y, S, ETO_CLIPPED or ETO_OPAQUE);
  end
  else
    // �̈��h��Ԃ�����
    Canvas.FillRect(R);
  // �����񒷁{[EOF]�}�[�N�����ɉB��Ă���ꍇ�̓L�����Z��
  SL := Length(S);
  //if (SL + 5) * FFontWidth < FLeftScrollWidth then
  //  Exit;
  // �P�C�O�O�O�����ڈȍ~�ɕ`�悵�Ȃ��悤�ɂ��邽�߂̏���
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
      // Index �s�̃g�[�N�������`�悷��
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
            // �����Ă���g�[�N�������`�悷��
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
          // �����Ă���g�[�N�������`�悷��
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
  // Brackets �v���p�e�B�̍X�V
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
    // �̈��h��Ԃ��Ȃ���A�P�s��������P�x�`�悷��
    Canvas.Font.Assign(Font);
    Canvas.Font.Color := C;
    DrawTextRect(R, X, Y, S, ETO_CLIPPED or ETO_OPAQUE);
  end
  else
    // �̈��h��Ԃ�����
    Canvas.FillRect(R);
  // �����񒷁{[EOF]�}�[�N�����ɉB��Ă���ꍇ�̓L�����Z��
  SL := Length(S);
  if (SL + 5) * FFontWidth < FLeftScrollWidth then
    Exit;
  // �P�C�O�O�O�����ڈȍ~�ɕ`�悵�Ȃ��悤�ɂ��邽�߂̏���
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
      // Index �s�̃g�[�N�������`�悷��
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
            // �����Ă���g�[�N�������`�悷��
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
          // �����Ă���g�[�N�������`�悷��
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
  �󂯎�����̈���A���t�g�}�[�W���A�g�b�v�}�[�W���A�������ɒ��߂�����
  �P�s������̕������ɐ؂蕪���Ă��炻���֕`�悷�ׂ��^�u��W�J��������
  ��ƁA�`��ʒu���擾���� PaintLine ���� PaintRectSelected �֓n��
  �̈�̓h��Ԃ��́A�`�悷��ۂ� FillRect ������ADrawTextRect
  �� ETOOPAQUE ��n���Ȃǂ���
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
  // LeftMargin �ƕ����ʒu�ւ̑Ή�
  R.Left := Max(L, L + ((R.Left - L) div FFontWidth) * FFontWidth);
  // TopMargin �ւ̑Ή�
  R.Top := Max(T, R.Top);
  // �������ɍ��킹�ď㉺�Ɋg������B
  H := GetRowHeight;
  R.Top := R.Top - (R.Top - T) mod H;
  B := (R.Bottom - T) mod H;
  if B > 0 then
    R.Bottom := R.Bottom + H - B;
  // �J�n�s�i������ Sr < 0 �ɂ͂Ȃ�Ȃ��j
  Sr := FTopRow + (R.Top - T) div H;
  // �I���s�iFList.Count �ȏ�ɂȂ�ꍇ������j
  Er := Sr + (R.Bottom - R.Top) div H - 1;
  // ���[�v���ŎQ�Ƃ���̂ŁA�ϐ��Ƃ��ĕێ�����
  LinesCount := FList.Count;
  // �`��J�n�ʒu�i���X�N���[����Ԃł̓}�C�i�X�l�ɂ��Ȃ�j
  X := L - FLeftScrollWidth;
  // �P�s���� Rect ��p�ӂ��� OffsetRect ���Ȃ���`����s��
  // �s�ԕ����͕`�悵�Ȃ��B
  // �A���_�[���C�������͑I����Ԃ̎��ƁA
  // �I����Ԃ����I����Ԃֈڍs���鎞�ɕ`�悷��
  if SelectedData or FClearingSelection then
    R.Bottom := R.Top + FFontHeight + FMargin.FUnderline
  else
    R.Bottom := R.Top + FFontHeight;

  CaretBeginUpdate; // �`��O�̂���
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
            // LinesCount �ȍ~�̓h��Ԃ�
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
  �I��̈��ێ�������ԂŁAWM_PAINT ���b�Z�[�W���󂯎�����ꍇ�̏���
  FSelDraw �f�[�^�� X, Y, Index ���r���A��I��̈�� PaintLine �ŁA
  �I��̈�� PaintLineSelected ���g���ĕ`�悷��B
  S �ɂ́A�^�u��W�J���������񂪓n�����
*)
var
  DRect, SRect: TRect;
  L: Integer;
begin
  L := LeftMargin;
  with FSelDraw do
  begin
    // �I��̈�O�͕��ʂɕ`��
    if (Index < Sr) or (Er < Index) then
      PaintLine(R, X, Y, S, Index, Parser)
    else
      if FSelectionMode = smLine then
        // �m�[�}���I�����
        // �P�s�I�����
        if Sr = Er then
        begin
          // �I��̈�̍�����`��
          SRect :=
            Rect(
              L,
              R.Top,
              Max(L, L + (Sc - FTopCol) * FFontWidth),
              R.Bottom
            );
          if IntersectRect(DRect, R, SRect) then
            PaintLine(DRect, X, Y, S, Index, Parser);
          // �I��̈��`��
          SRect :=
            Rect(
              Max(L, L + (Sc - FTopCol) * FFontWidth),
              R.Top,
              Max(L, L + (Ec - FTopCol) * FFontWidth),
              R.Bottom
            );
          if IntersectRect(DRect, R, SRect) then
            PaintLineSelected(DRect, X, Y, S, Index, Parser);

          // �I��̈�̉E����`��
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
          // �����s�I�����

          // �P�s��
          if Index = Sr then
          begin
            // �I��̈�̍�����`��
            SRect :=
              Rect(
                L,
                R.Top,
                Max(L, L + (Sc - FTopCol) * FFontWidth),
                R.Bottom
              );
            if IntersectRect(DRect, R, SRect) then
              PaintLine(DRect, X, Y, S, Index, Parser);
            // �I��̈��`��
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
            // �Ō�̍s
            if Index = Er then
            begin
              // �I��̈��`��
              SRect :=
                Rect(
                  L,
                  R.Top,
                  Max(L, L + (Ec - FTopCol) * FFontWidth),
                  R.Bottom
                );
              if IntersectRect(DRect, R, SRect) then
                PaintLineSelected(DRect, X, Y, S, Index, Parser);
              // �I��̈�̉E����`��
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
              // �r���̍s
              PaintLineSelected(R, X, Y, S, Index, Parser)
      else
      begin
        // ��`�I�����
        // �I��̈�̍�����`��
        SRect := BoxSelRect(S, Index, 0, Sc);
        if IntersectRect(DRect, R, SRect) then
          PaintLine(DRect, X, Y, S, Index, Parser);
        // �I��̈��`��
        SRect := BoxSelRect(S, Index, Sc, Ec);
        if IntersectRect(DRect, R, SRect) then
          PaintLineSelected(DRect, X, Y, S, Index, Parser);
        // �I��̈�̉E����`��
        SRect := BoxSelRect(S, Index, Ec, Ec + FColCount);
        SRect.Right := Width; // ���X
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
  // �̈���ɂ����`��
  if (T < Y) and (Y <= Height) then
    Result := Y;
end;

function TEditor.TopMargin: Integer;
begin
  Result := FMargin.FTop;
  if FRuler.FVisible then
    Inc(Result, FRulerHeight);
end;

// �I��̈� /////////////////////////////////////////////////////////

(*

#Selection

FSelectionState
  sstNone        ��I�����
  sstInit        �I��̈�f�[�^�����������ꂽ��� ( = �I����Ԃւ̌����擾������ԁj
  sstSelected    �I�����
  sstHitSelected �q�b�g�������\�����Ă�����
  
InitSelection    -> sstInit
                 �I��̈�f�[�^������������
SetSelection     FSelectionState �̏�Ԃɉ����� StartSelection,
                 UpdateSelection ���Ăяo��
StartSelection   -> sstSelected ���� -> sstHitSelected
                 �A���_�[���C���������� UpdateSelection ���Ăяo��
UpdateSelection  �I��̈�f�[�^���X�V���ĕ`��A
                 FOnSelectionChange �C�x���g�Ăяo��
CleanSelection   -> sstNone
                 �I��̈���m�[�}���`�悵�ăA���_�[���C���𕜊�������
                 FOnSelectionChange �Ăяo��
DeleteSelection  �I��̈�̕�������폜���ACleanSelection ���Ăяo��

*)

procedure TEditor.HitToSelected;
(*
  sstHitSelected ��Ԃ� sstSelected �Ƃ���B
  HitStyle �� hsDraw, hsCaret �̎��ɒu�������������s�����̂��߂̃��\�b�h�B
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
  ��`�I����ԂŁAFList[Index] �̃^�u��W�J���������� S ��I���E��I��
  �̈�Ƃ��ĕ`�悷��ۂ̗̈�� BoxLeftIndex, BoxRightIndex �̎d�l��
  �]���ĕԂ��B

  �Ԃ��̈�͕����񂪕`�悳���̈�������Ƃ���B

  Paint ��������p�����̂ŁA�ĕ`��̌�Őݒ肳��� FTopCol �͎g�p���Ȃ��B
  ��`�I��̈���E����`�悷��ꍇ�́A�Ԓl�� Right �� Width �ɂ��邱�ƁB
*)
var
  I, L, T, R, B, LM: Integer;
begin
  StartCol := Min(StartCol, Length(S));
  EndCol := Min(EndCol, Length(S));
  T := TopMargin + (Index - FTopRow) * GetRowHeight;
  B := T + FFontHeight + FMargin.FUnderline;
  LM := LeftMargin;
  // �̈捶��
  L := LM + StartCol * FFontWidth - FLeftScrollWidth;
  I := StartCol + 1;
  if (0 < I) and (I <= Length(S)) and IsDBCS2(S, I) then
    L := L + FFontWidth;
  L := Max(LM, L);
  // �̈�E��
  R := LM + EndCol * FFontWidth - FLeftScrollWidth;
  I := EndCol + 1;
  if (0 < I) and (I <= Length(S)) and IsDBCS2(S, I) then
    R := R + FFontWidth;
  R := Max(LM, R);
  Result := Rect(L, T, R, B);
end;

function TEditor.BoxLeftIndex(const Attr: String; I: Integer): Integer;
(*
  ��`�I��̈捶���̕����C���f�b�N�X��Ԃ�
  Attr �ɂ͕��������z���n�����ƁB
  �^�u�������W�J���ꂽ�����ɗ̈�̍��[������ꍇ�A���̃^�u������
  �I��̈�Ɋ܂܂�Ȃ��d�l
  I �ɂ́AFCol + 1, FSelDraw.Sc + 1 �𐄏�
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
  ��`�I��̈�E���̕����C���f�b�N�X��Ԃ�
  Attr �͕��������z���n���B
  I �ɂ́AFSelDraw.Ec �𐄏�
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
  �I�𕶎�����}�E�X�h���b�O�o�����Ԃɂ��邩�ǂ�����Ԃ��B
  �}�E�X�J�[�\�����̈���ɂ��邩�ǂ����͔��ʂ��Ȃ��B
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
  // �I����Ԃ̏I������
  FSelectionState := sstNone;
  // ������v�����񒷂̏�����
  FHitSelLength := 0;
  // hsCaret �̏ꍇ�A�L�����b�g�����ɖ߂�
  if HitSelected and (FHitStyle = hsCaret) then
    UpdateCaret;
  // �I��̈悪����΃m�[�}���`��
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
      // �A���_�[���C���������ĕ`��œh��Ԃ��Ă��炤���߂̃t���O
      FClearingSelection := True;
      try
        InvalidateRect(Handle, @R, False);
        // FClearingSelection �t���O���L���ȓ��ɍĕ`�悷��
        UpdateWindow(Handle);
      finally
        FClearingSelection := False;
      end;
    end;
  // StartSelection �ŏ������A���_�[���C���𕜊�
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
  // �I��̈���܂ލs�̕�������A�I��̈���폜����������Œu��������
  if not HandleAllocated or not Selected then
    Exit;
  with FSelStr do
  begin
    // �L�����b�g�ʒu FSelStr.Sc �ł͂Ȃ����Ƃɒ���
    Ri := Max(FList.RowStart(Sr), Sr - 1);
    SelIndex := GetSelIndex(Ri, FSelDraw.Sr, FSelDraw.Sc);
    // RowEnd
    Re := Min(Er, FList.Count - 1);
    // �u�������镶������쐬
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
      // �I��̈���m�[�}���`�悷��
      CleanSelection;
      FList.UpdateList(Sr, Re - Sr + 1, Buf);
      // �L�����b�g�̈ړ�
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
  // �P�s�̍���
  H := GetRowHeight;
  TM := TopMargin;
  LM := LeftMargin;
  // �����̕`��J�n�ʒu�i�}�C�i�X�̏ꍇ������j
  X := LM - FLeftScrollWidth;
  // �I��̈�Ƃ��ĕ`�悷��P�s�̍��� Margin.Line �����͑I��F�ɂ��Ȃ�
  LineHeight := FFontHeight + FMargin.FUnderline;

  CaretBeginUpdate;
  try
    Parser := ActiveFountain.ParserClass.Create(ActiveFountain);
    try
      // �� �I������I���ɂȂ����s���m�[�}���`��

      // �I��̈悪������ɏk�܂���
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
        // �I��̈悪�������ɏk�܂���
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
          // �P�s�I�����畡���s�I���ֈڍs����ۂɔ����������ȏ��
          //    abcdefg
          //    hijklmn
          //    f..b -> f..i �ɂȂ����ꍇ b..e ���m�[�}���`��
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
            //    i..m -> i..f �ɂȂ����ꍇ i..m ���m�[�}���`��
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

      // �� �I������I���ɂȂ����������m�[�}���`��

      // �I��̈悪�������ɏk�܂���
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
        // �I��̈悪�E�����ɏk�܂���
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

      // �� ��I�����I���ɂȂ����s��`��

      // �I��̈悪���ɐL�т�
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
        // �I��̈悪��ɐL�т�
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
          // �����s�I������P�s�I���ֈڍs����ۂɔ����������ȏ�ԂP
          // �I��̈悪��ɏk��łP�s�ɂȂ�AFSelStartCol �����O��
          // FSelDraw.Sc ������ꍇ�̏���
          //    abcdefg
          //    hijklmn
          //    f..i -> f..b �ɂȂ����ꍇ b..f ��I��`��
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
            // �����s�I������P�s�I���ֈڍs����ۂɔ����������ȏ�ԂQ
            // �I��̈悪���ɏk��łP�s�ɂȂ�AFSelStartCol ��������
            // FSelDraw.Ec ������ꍇ�̏���
            //    abcdefg
            //    hijklmn
            //    i..f -> i..m �ɂȂ����ꍇ i..m ��I��`��
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

      // �� ��I�����I���ɂȂ���������`��

      // �I��̈悪�E�ɐL�т�
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
        // �I��̈悪���ɐL�т�
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
  // �P�s�̍���
  H := GetRowHeight;
  TM := TopMargin;
  LM := LeftMargin;
  // �����̕`��J�n�ʒu�i�}�C�i�X�̏ꍇ������j
  X := LM - FLeftScrollWidth;
  // �I��̈�Ƃ��ĕ`�悷��P�s�̍��� Margin.Line �����͑I��F�ɂ��Ȃ�
  LineHeight := FFontHeight + FMargin.FUnderline;

  CaretBeginUpdate;
  try
    Parser := ActiveFountain.ParserClass.Create(ActiveFountain);
    try
      // �� �I������I���ɂȂ����s���m�[�}���`��

      // �I��̈悪������ɏk�܂���
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
        // �I��̈悪�������ɏk�܂���
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

      // �� �I������I���ɂȂ����������m�[�}���`��

      // �I��̈悪�������ɏk�܂���
      if FSelDraw.Ec < FSelOld.Ec then
      begin
        dsr := Max(FTopRow, FSelDraw.Sr);
        der := Min(FTopRow + FRowCount, FSelDraw.Er);
        for I := dsr to der do
          if I < LinesCount then
          begin
            S := ExpandListStr(I);
            R := BoxSelRect(S, I, FSelDraw.Ec, FSelDraw.Ec + FColCount);
            R.Right := Width;  // ���X
            PaintLine(R, X, R.Top, S, I, Parser);
          end;
      end
      else
        // �I��̈悪�E�����ɏk�܂���
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

      // �� ��I�����I���ɂȂ����s��`��

      // �I��̈悪���ɐL�т�
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
        // �I��̈悪��ɐL�т�
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

      // �� ��I�����I���ɂȂ���������`��

      // �I��̈悪�E�ɐL�т�
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
        // �I��̈悪���ɐL�т�
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
  ���݂� Row, Col �ʒu�őI��̈�̊J�n�ʒu�A�I��̈�f�[�^������������
  �f�[�^�͂��ׂĂO�x�[�X cf UpdateSelection
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
  // ��Ԃ̕ύX
  if SelectedData then
    CleanSelection;
  if FList.Count = 0 then
    Exit;
  FSelectionState := sstInit;
  S := ListStr(FRow);
  Attr := StrToAttributes(S);
  Si := Min(Length(S), FCol - IncludeCharCount(Attr, caTabSpace, FCol + 1));
  // �I���J�n�ʒu������
  FSelStartRow := FRow;
  FSelStartSi := Si;
  if FSelectionMode = smLine then
    FSelStartCol := Min(FCol, ExpandListLength(FRow))
  else
    FSelStartCol := FCol;
  // �I��̈�f�[�^������
  FSelStr := SelPos(FRow, FRow, Si, Si);
  FSelDraw := SelPos(FRow, FRow, FSelStartCol, FSelStartCol);
  FSelOld := FSelDraw;
end;

procedure TEditor.SelDeletedList(Dest: TEditorStringList);
(*
  �I��̈���폜�������X�g�C���[�W���쐬�� Dest �Ɋi�[����B
  smLine �̏ꍇ�́ADest.Count = 1 �ɂȂ�B
  Dest.Rows[n] �ɂ́A�Ή����� FList.Rows[n] ���i�[�����B
  Dest.Datas[n] �ɂ́AFSelDraw.Sc + 1 �����ۂ̕����C���f�b�N�X��
  �ϊ��������̂��i�[����B�ϊ��́A��`�I��̈捶���̋K���ɏ]��
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
    // Sc �̑O
    S := S + Copy(ListStr(Sr), 1, Sc);
    // Ec �̌�
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
  ���݂� Row, Col ���� FSelStr, FSelDraw ���X�V���� DrawSelection
  ���Ăяo���BDrawSelection �ł́AFSelOld �� FSelDraw �̍�����
  �I��̈�Ƃ��ĕ`�悵�Ă���

  FSelDraw.Ec �́A�I��̈扺�E�[ Col �ɑΉ����Ă��邪�A
  FSelStr.Ec �́A�I��̈扺�E�[�̂O�x�[�X�̕����C���f�b�N�X - 1
  �ɂȂ�Ƃ����Y�܂����d�l
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
  // FSelStr �̍X�V
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

  // FSelDraw �̍X�V
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
    // ��`�I��
    with FSelDraw do
    begin
      Sr := Min(FSelStartRow, FRow);
      Er := Max(FSelStartRow, FRow);
      Sc := Min(FSelStartCol, FCol);
      Ec := Max(FSelStartCol, FCol);
    end;
  // �I��̈��`��
  if SelectedDraw then
    DrawSelection;
  DoSelectionChange(Boolean(Byte(FSelectionState)));
end;

procedure TEditor.StartRowSelection(ARow: Integer);
(*
  ARow �Ŏw�肳�ꂽ�P�s��I����Ԃɂ��A�L�����b�g�� ARow ��
  �s���ֈړ�����B
  ARow ��I���\�ȍs�ԍ��֒��߂��AARow �̍s�����玟�̍s��
  �܂ł�I��̈�Ƃ���BARow �� raEof �̏ꍇ�͂��̍s������
  �s���܂ł�I��̈�Ƃ���B
*)
begin
  if FList.Count = 0 then
    Exit;
  // adjust ARow
  ARow := Min(ARow, FList.Count);
  if (ARow = FList.Count) and (ListRows(FList.Count - 1) = raEof) then
    ARow := FList.Count - 1;
  // �I��̈�f�[�^�����������đI����Ԃֈڍs
  if ListRows(ARow) = raEof then
  begin
    SetRowCol(ARow, ExpandListLength(ARow));
    InitSelection;
    SetRowCol(ARow, 0);
    StartSelection;
    FSelRow.Sr := ARow;
    FSelRow.Er := ARow;
    FSelRow.Sc := 1;
    // raEof �ȍs����n�܂�ꍇ�́AUpdateRowSelection �� (2) ��
    // �������s�v�ɂȂ�̂ŁA���̃t���O�Ƃ��� Sc �𗘗p����
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
  // �L�����b�g���ړ�
  SetRowCol(ARow, 0);
  //�t���O�ݒ�
  FRowSelecting := True; // FRowSelecting := False in WMLButtonUp
end;

procedure TEditor.UpdateRowSelection(ARow: Integer);
(*
  FSelRow.Sr, FSelRow.Er �� ARow ���r���đI��̈���X�V����
  FSelRow.Er..ARow �� FSelRow.Sr ���ׂ��ꍇ�́A�̈�̏�����������
  �K�v�ɂȂ�

  �������  ARow -> Sr, Er(eof)
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
  // ����
  if ARow >= FSelRow.Sr then
  begin
    // Sr ���牺�֗̈�ړ�
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
    // Sr ����֗̈�ړ�
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


// �I��̈�̈ړ����� ///////////////////////////////////////////////

(*

#SelectionMove

FSelDragState
  sdNone
  sdInit         �I��̈�� WM_LBUTTONDOWN ���ꂽ���
  sdDragging     �������琔�s�N�Z�������ăh���b�O���n�܂������
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
    // CursorState �̍X�V
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
  ARow, ACol ���I��̈���ɂ��邩�ǂ�����Ԃ��B
  ���̊֐��ł́A��`�I����Ԃ��T�|�[�g���Ă���B
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
  �I��̈�̕������ ARow, ACol �ʒu�փR�s�[����B
  �������I��̈���̏ꍇ�͖��������B
  ��`�I���̓T�|�[�g���Ă��Ȃ��B
  ARow, ACol �̔��ʂɂ��ẮAMoveSelection �Ɠ���
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
  �I��̈�̕������ ARow, ACol �ʒu�ֈړ�����B
  �������I��̈���̏ꍇ�͖�������B��`�I���̓T�|�[�g���Ȃ��B

  ARow, ACol �ʒu���L�����b�g�ړ��\�Ȉʒu�ł��邩�ǂ�����
  ���ʂ͍s���Ă��Ȃ��̂ŁA�]�܂��ʒu�փL�����b�g���ړ���
  (SetRowCol ���Ă���)���ۂ̃L�����b�g�ʒu��n������
  ARow, ACol �����ۂ̃L�����b�g�ʒu�ł͂Ȃ��ꍇ�̓���͕ۏ�
  ����Ȃ��B

     <-         a          ->(1)<-           c              ->
                              d
                    Sc
  Sr <-    e      ->+----------------------------------------+
          (2)<- g ->|                                        |
     +--------------+                                        |
     |                 �I��̈� GetSelText b                 |
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

  // �X�V����̈�ƃL�����b�g�ړ��̂��߂̃f�[�^
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

  // �}�����镶������쐬
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
  // �I��̈�̉���
  CleanSelection;
  // ������̍X�V�ƕ`��
  CaretBeginUpdate;
  try
    if Rs > FList.Count - 1 then
      FList.UpdateList(Rs, 0, Buf)
    else
      if Re <= FList.Count - 1 then
        FList.UpdateList(Rs, Re - Rs + 1, Buf)
      else
        FList.UpdateList(Rs, Re - Rs, Buf);
    // �L�����b�g���ړ�
    SetSelIndex(Ri, SelIndex);
  finally
    CaretEndUpdate;
  end;
end;


// �g�[�N�� /////////////////////////////////////////////////////////

(*
    TTokenParser

    TFountain �𗘗p���Ȃ��p�[�T�[�N���X�B
    PosTokenString, SelectPosToken ���\�b�h�̂��߂����ɑ��݂���B
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
  Pos �ʒu�̌���Ԃ��BEditor �� Self ��n���ꍇ View �v���p�e�B�ւ�
  �ݒ肪���d����Anil ��n���� View �v���p�e�B�̐ݒ�͖��������B
  C �ɂ́A���̎�ނ��i�[�����B

  Editor �� Self ���ABracket �� True ���n�����ƁAActiveFountain.Brackets
  �v���p�e�B�ւ̐ݒ�����d����邪�A�Ԃ����̂͂P�s��������ɂ�����
  �����ɂȂ�B
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
    Data �̎擾
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
  Pos �ʒu�̌���I������BEditor �� Self ��n���ꍇ View �v���p�e�B
  �ւ̐ݒ肪���d����Anil ��n���� View �v���p�e�B�̐ݒ�͖��������B

  Editor �� Self ���ABracket �� True ���n�����ƁAActiveFountain.Brackets
  �v���p�e�B�ւ̐ݒ�����d����邪�A�I�������̂͂P�s��������ɂ�����
  �����ɂȂ�B
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
    Data �̎擾
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
  �L�����b�g�ʒu�̌���I������ View �v���p�e�B�̐ݒ�𑸏d����
  ActiveFountain.Brackets �v���p�e�B�̐ݒ�𑸏d���邪�A�I�������̂�
  �P�s��������ɂ����傾���ɂȂ�
*)
var
  Pos: TPoint;
begin
  GetCaretPos(Pos);
  SelectTokenBracketFromPos(Pos);
end;

procedure TEditor.SelectTokenBracketFromPos(Pos: TPoint);
(*
  Pos �ʒu�̌���I������ View �v���p�e�B�̐ݒ�𑸏d����
  ActiveFountain.Brackets �v���p�e�B�̐ݒ�𑸏d���邪�A�I�������̂�
  �P�s��������ɂ����傾���ɂȂ�
*)
begin
  SelectPosToken(Pos, Self, True);
end;

procedure TEditor.SelectTokenFromCaret;
(*
  �L�����b�g�ʒu�̌���I������ View �v���p�e�B�̐ݒ�𑸏d���邪
  ActiveFountain.Brackets �v���p�e�B�ւ̐ݒ�͖��������
*)
var
  Pos: TPoint;
begin
  GetCaretPos(Pos);
  SelectTokenFromPos(Pos);
end;

procedure TEditor.SelectTokenFromPos(Pos: TPoint);
(*
  Pos �ʒu�̌���I������ View �v���p�e�B�̐ݒ�𑸏d���邪
  ActiveFountain.Brackets �v���p�e�B�ւ̐ݒ�͖��������
*)
begin
  SelectPosToken(Pos, Self, False);
end;

procedure TEditor.SelectWordFromCaret;
(*
  �L�����b�g�ʒu�̂P���I������ View �v���p�e�B�̐ݒ�͖��������
*)
var
  Pos: TPoint;
begin
  GetCaretPos(Pos);
  SelectWordFromPos(Pos);
end;

procedure TEditor.SelectWordFromPos(Pos: TPoint);
(*
  Pos �ʒu�̂P���I������ View �v���p�e�B�̐ݒ�͖��������
*)
begin
  SelectPosToken(Pos, Self, False);
end;

function TEditor.TokenBracketFromCaret: Char;
(*
  �L�����b�g�ʒu�ɂ�����̎�ނ�Ԃ� View �v���p�e�B�̐ݒ��
  ���d���AActiveFountain.Brackets �ւ̐ݒ�����d�����
*)
var
  Pos: TPoint;
begin
  GetCaretPos(Pos);
  Result := TokenBracketFromPos(Pos);
end;

function TEditor.TokenBracketFromPos(Pos: TPoint): Char;
(*
  Pos �ʒu�ɂ�����̎�ނ�Ԃ� View �v���p�e�B�̐ݒ��
  ���d���AActiveFountain.Brackets �ւ̐ݒ�����d�����
*)
begin
  PosTokenString(Pos, Self, Result, True);
end;

function TEditor.TokenFromCaret: Char;
(*
  �L�����b�g�ʒu�ɂ�����̎�ނ�Ԃ� View �v���p�e�B�̐ݒ��
  ���d���邪 ActiveFountain.Brackets �ւ̐ݒ�͖��������
*)
var
  Pos: TPoint;
begin
  GetCaretPos(Pos);
  Result := TokenFromPos(Pos);
end;

function TEditor.TokenFromPos(Pos: TPoint): Char;
(*
  Pos �ʒu�ɂ�����̎�ނ�Ԃ� View �v���p�e�B�̐ݒ��
  ���d���邪 ActiveFountain.Brackets �ւ̐ݒ�͖��������
*)
begin
  PosTokenString(Pos, Self, Result, False);
end;

function TEditor.TokenStringBracketFromCaret: String;
(*
  �L�����b�g�ʒu�̌���Ԃ� View �v���p�e�B�̐ݒ��
  ���d���AActiveFountain.Brackets �ւ̐ݒ�����d����邪�A
  ���ʂɊi�[����镶����͂P�s��������ɂ����傾���ɂȂ�
*)
var
  Pos: TPoint;
begin
  GetCaretPos(Pos);
  Result := TokenStringBracketFromPos(Pos);
end;

function TEditor.TokenStringBracketFromPos(Pos: TPoint): String;
(*
  Pos �ʒu�̌���Ԃ� View �v���p�e�B�̐ݒ��
  ���d���AActiveFountain.Brackets �ւ̐ݒ�����d����邪�A
  ���ʂɊi�[����镶����͂P�s��������ɂ����傾���ɂȂ�
*)
var
  C: Char;
begin
  Result := PosTokenString(Pos, Self, C, True);
end;

function TEditor.TokenStringFromCaret: String;
(*
  �L�����b�g�ʒu�̌���Ԃ� View �v���p�e�B�̐ݒ��
  ���d���邪 ActiveFountain.Brackets �ւ̐ݒ�͖��������
*)
var
  Pos: TPoint;
begin
  GetCaretPos(Pos);
  Result := TokenStringFromPos(Pos);
end;

function TEditor.TokenStringFromPos(Pos: TPoint): String;
(*
  Pos �ʒu�̌���Ԃ� View �v���p�e�B�̐ݒ��
  ���d���邪 ActiveFountain.Brackets �ւ̐ݒ�͖��������
*)
var
  C: Char;
begin
  Result := PosTokenString(Pos, Self, C, False);
end;

function TEditor.WordFromCaret: String;
(*
  �L�����b�g�ʒu�̂P���Ԃ� View �v���p�e�B�̐ݒ�͖��������
*)
var
  Pos: TPoint;
begin
  GetCaretPos(Pos);
  Result := WordFromPos(Pos);
end;

function TEditor.WordFromPos(Pos: TPoint): String;
(*
  Pos �ʒu�̂P���Ԃ� View �v���p�e�B�̐ݒ�͖��������
*)
var
  C: Char;
begin
  Result := PosTokenString(Pos, nil, C, False);
end;


// �����񑀍� ///////////////////////////////////////////////////////

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
  // Pos ��̕����C���f�b�N�X�i SelStart �Ɠ��l�j��Ԃ�
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
  ARow ��� ACol �ʒu�̕����C���f�b�N�X��Ԃ��i�O�x�[�X�j
  �s���� ARow �ȏꍇ�� -1 ��Ԃ�
  WordWrap �ȏꍇ�� ARow ����� raWrapped �ȍs�̕����������Z�����
*)
var
  S, Attr: String;
  I, C: Integer;
begin
  Result := -1;
  if (ARow < 0) or (FList.Count < ARow) or (ACol < 0) then
    Exit;
  // FList �� ARow �s�̕�������
  S := ListStr(ARow);
  Attr := StrToAttributes(S);
  // �S�p�Q�o�C�g�ځH
  if IndexChar(Attr, ACol + 1) = caDBCS2 then
    Dec(ACol);
  // �^�u�̒��H
  while IndexChar(Attr, ACol + 1) = caTabSpace do
    Dec(ACol);
  // ACol �� FList[ARow] ��ł̕����C���f�b�N�X�i�O�x�[�X�j
  C := Min(Length(S), ACol - IncludeCharCount(Attr, caTabSpace, ACol + 1));
  Result := C;
  // ARow ������� raWrapped �ȍs�̒�����ǉ�
  I := ARow - 1;
  while (I >= 0) and (ListRows(I) = raWrapped) do
  begin
    Inc(Result, Length(ListStr(I)));
    Dec(I);
  end;
end;

procedure TEditor.DeleteRow(Index: Integer);
begin
  { ��ʏ�̂P�s��������폜���� }
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
      // �ŏI�s���폜�����ꍇ
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
  �w�肳�ꂽ�|�C���g���� FList �̍s�ԍ��Ƃ��̍s��������ł̕���
  �C���f�b�N�X�� Info �Ɋi�[����B���[�h���b�v�͍l�����Ȃ��B
  �s�ԍ��A�����C���f�b�N�X�͋��ɂO�x�[�X�ł��邱�Ƃɒ���
*)
var
  R, C: Integer;
  S, Attr: String;
begin
  Result := False;
  Info.Line := -1;
  Info.CharIndex := -1;
  // ���l�� OnMouseMove �n���h���ɓ������ꍇ�AFFontWidth �� 0 �̏ꍇ������̂�
  if (FList.Count = 0) or (FFontWidth = 0) then
    Exit;
  // �}�[�W���̒�
  if (Pos.X < LeftMargin) or (Pos.Y < TopMargin) then
    Exit;
  PosToRowCol(Pos.X, Pos.Y, R, C, True);
  if (R < 0) or (FList.Count < R) then
    Exit;
  Info.Line := R;
  // �s��������
  S := ListStr(R);
  Attr := StrToAttributes(S);
  // �s������ȍ~�� MaxLineCharacter ���E��
  if C >= Length(Attr) then
    Exit;
  if C >= 0 then
  begin
    // �S�p�Q�o�C�g�ځH
    if IndexChar(Attr, C + 1) = caDBCS2 then
      Dec(C);
    // �^�u�̒��H
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
  Source.Rows �v���p�e�B���l������ Text ��Ԃ�
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
  ���ݍs�̃L�����b�g�ʒu�� Source ��}������B
  �㏑�����[�h�ɑΉ�����B
  ReadOnly �̔��ʂ͍s���Ă��Ȃ��B
  �I����Ԃ̏ꍇ�́A�I��̈�̕����� Source �ɒu������邾���Ƃ��A
  �㏑�����[�h�ɂ͑Ή����Ȃ��d�l�Ƃ���B
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
    // �L�����b�g�ʒu FSelStr.Sc �ł͂Ȃ����Ƃɒ���
    Ri := Max(FList.RowStart(Sr), Sr - 1);
    SelIndex := GetSelIndex(Ri, FSelDraw.Sr, FSelDraw.Sc) + L;
    Rs := Sr;
    Re := Er;
    // �u�������镶������쐬�BSc, Ec �� 0 base �ł��邱�Ƃɒ���
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
    // FRow �̕����񑮐��ƁA�������ł̃C���f�b�N�X�擾
    S := ListStr(FRow);
    Attr := StrToAttributes(S);
    // Si �͂O�x�[�X
    Si := FCol - IncludeCharCount(Attr, caTabSpace, FCol + 1);
    if Si < Length(S) then
    begin
      // �s�̕������
      if FOverWrite then
      begin
        // �㏑�����[�h
        // ver 1.30 ���AraWrapped �ȍs�� IME ���璷�������񂪓���
        // ���ꂽ���AFRow �ȍ~�̍s��������㏑������d�l�Ƃ���B
        // �L�����b�g���O�� Source
        Buf := Copy(S, 1, Si) + Source;
        // Source �I�[�̕����C���f�b�N�X���擾
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
        // �}�����[�h
        Insert(Source, S, Si + 1);
        Buf := S;
      end;
    end
    else
      // �s�I�[���E���A�󔒍s�̍ŏ��̕���
      // waRapped �ȍs�ł͔������Ȃ�
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
  FList �� Index �� FLines �� Index �ɕϊ�����
  ��O�𔭐������邽�߂Ɋ�����
  Max(0, Min(Index, FList.Count))
  and (Result <= FEditor.FList.Count - 1)
  �Ȃǂ̔��ʂ��s��Ȃ��B
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
        // raWrapped ��AsfrIncludeCRLF, sfrIncludeSpace �ɑΉ����邽��
        // �P�s���Ԃ点�Ď��̌������s��
        // R �s�̕����񒷂� $2000 �o�C�g�ȏ�̏ꍇ�̂��߂̔��ʂ��s��
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
        // raWrapped ��AsfrIncludeCRLF, sfrIncludeSpace �ɑΉ����邽��
        // �P�s���Ԃ点�Ď��̌������s��
        // R �s�̕����񒷂� $2000 �o�C�g�ȏ�̏ꍇ�̂��߂̔��ʂ��s��
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
  �I��̈���̊e�s���ɔ��p�X�y�[�X(#$20)���P�}������
  �e�s���ɂ���A�������󔒕����i���p�E�S�p�X�y�[�X�A�^�u�����ƃ^�u
  �������W�J���ꂽ�����j�͔��p�X�y�[�X�ɒu���������B�s�������
  �r���ɂ���^�u������S�p�X�y�[�X�͂��̂܂܂ɂȂ�B

  ��`�I����Ԃ̏ꍇ�́A�I��̈捶�[�ɕ���������Γ��l�ɏ��������
  ���A��`�I��̈�̍��[���^�u������W�J�����������A�S�p�󔒂Q�o�C
  �g�ڂ̏ꍇ�́A���̃^�u�����܂��͑S�p�󔒂����p�X�y�[�X�ɒu������
  ����B

  raWrapped �ȍs�͏������Ȃ�
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
    // �ʏ�I�����
    // start row, end row
    Sr := FSelStr.Sr;
    if FSelStr.Ec = -1 then
      Er := Max(Sr, FSelStr.Er - 1)
    else
      Er := FSelStr.Er;
    // �I������t���O
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
      // �I��̈�J�n�ʒu�ύX�𔽉f������
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
      // �I��̈�J�n�ʒu�ύX�𔽉f������
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
      // �I��̈�`��f�[�^�̍X�V
      FSelOld := FSelDraw;
  end
  else
  begin
    // ��`�I�����

    // ��`�I��̈�̍��[���^�u������W�J�����������A�S�p�Q�o�C�g�ڂ�
    // �ꍇ BoxLeftIndex �͂��̎��̕������w���l��Ԃ��ė���B
    // �^�u������W�J���������̏ꍇ�͊Y���^�u�����������Ώۂɉ�����
    // �S�p�Q�o�C�g�ڂ̏ꍇ���ꂪ�S�p�� (#$81#$40) �ł���Ώ����Ώ�
    // �ɉ�����Ƃ����d�l

    // start row, end row
    Sr := FSelDraw.Sr;
    Er := Min(FList.Count - 1, FSelDraw.Er);
    // insert string;
    Buf := '';
    for I := Sr to Er do
    begin
      S := ListStr(I);
      Attr := StrToAttributes(S);
      L := ExpandTabLength(S); // Length(Attr); �ł͂Ȃ�
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
        // �Y���s�擪����̕�����ł͂Ȃ��̂� TabbedTopSpace �͎g���Ȃ�
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
  �I��̈���̊e�s���ɋ󔒕����i���p�E�S�p�X�y�[�X�A�^�u�����ƃ^�u
  �������W�J���ꂽ�����j������΁A�󔒕����̒��� - 1 �̔��p�X�y�[�X
  �ɒu��������B�s������̓r���ɂ���^�u������S�p�X�y�[�X�͂��̂�
  �܂ɂȂ�B

  ��`�I����Ԃ̏ꍇ�́A�I��̈捶�[�ɋ󔒕���������Γ��l�ɏ�����
  ��邪�A��`�I��̈�̍��[���^�u������W�J�����������A�S�p��
  �Q�o�C�g�ڂ̏ꍇ�́A���̃^�u�����܂��͑S�p�󔒂����p�X�y�[�X��
  �u����������B

  raWrapped �ȍs�͏������Ȃ�
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
    // �ʏ�I�����
    // start row, end row
    Sr := FSelStr.Sr;
    if FSelStr.Ec = -1 then
      Er := Max(Sr, FSelStr.Er - 1)
    else
      Er := FSelStr.Er;
    // �I������t���O
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
      // �I��̈�J�n�ʒu�ύX�𔽉f������
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
      // �I��̈�J�n�ʒu�ύX�𔽉f������
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
      // �I��̈�`��f�[�^�̍X�V
      FSelOld := FSelDraw;
  end
  else
  begin
    // ��`�I�����

    // ��`�I��̈�̍��[���^�u������W�J�����������A�S�p�Q�o�C�g�ڂ�
    // �ꍇ BoxLeftIndex �͂��̎��̕������w���l��Ԃ��ė���B
    // �^�u������W�J���������̏ꍇ�͊Y���^�u�����������Ώۂɉ�����
    // �S�p�Q�o�C�g�ڂ̏ꍇ���ꂪ�S�p�� (#$81#$40) �ł���Ώ����Ώ�
    // �ɉ�����Ƃ����d�l

    // start row, end row
    Sr := FSelDraw.Sr;
    Er := Min(FList.Count - 1, FSelDraw.Er);
    // insert string;
    Buf := '';
    for I := Sr to Er do
    begin
      S := ListStr(I);
      Attr := StrToAttributes(S);
      L := ExpandTabLength(S); // Length(Attr); �ł͂Ȃ�
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
        // �Y���s�擪����̕�����ł͂Ȃ��̂� TabbedTopSpace �͎g���Ȃ�
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
  �I��̈���̊e�s���Ƀ^�u (#$09) ���P�}������
  WordWrap ���́AraWrapped �ȍs�ƃ^�u������}�����邱�Ƃɂ����
  �܂�Ԃ��\������Ă��܂��s�͏������Ȃ�
  ��`�I����Ԃ̏ꍇ�́A�I��̈捶�[�Ƀ^�u��}������
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
    // �ʏ�I�����
    // start row, end row
    Sr := FSelStr.Sr;
    if FSelStr.Ec = -1 then
      Er := Max(Sr, FSelStr.Er - 1)
    else
      Er := FSelStr.Er;
    // �I������t���O
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
      // �I��̈�J�n�ʒu�ύX�𔽉f������
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
      // �I��̈�J�n�ʒu�ύX�𔽉f������
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
      // �I��̈�`��f�[�^�̍X�V
      FSelOld := FSelDraw;
  end
  else
  begin
    // ��`�I�����
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
  �I��̈���̊e�s���Ƀ^�u���� (#$09) ������΂�����P�폜����
  WordWrap ���́AraWrapped �ȍs�͏������Ȃ�
  ��`�I����Ԃ̏ꍇ�́A�I��̈捶�[�̃^�u���폜����
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
    // �ʏ�I�����
    // start row, end row
    Sr := FSelStr.Sr;
    if FSelStr.Ec = -1 then
      Er := Max(Sr, FSelStr.Er - 1)
    else
      Er := FSelStr.Er;
    // �I������t���O
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
      // �I��̈�J�n�ʒu�ύX�𔽉f������
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
      // �I��̈�J�n�ʒu�ύX�𔽉f������
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
      // �I��̈�`��f�[�^�̍X�V
      FSelOld := FSelDraw;
  end
  else
  begin
    // ��`�I�����
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
  �L�����b�g�ʒu�ɕ��������`�ɑ}������B
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

    // �̈��u�������镶������쐬
    Dest := TEditorStringList.Create;
    try
      // Source �̊e�s��Ή�����s�� Ci �ɑ}�����邽��
      // Source.Count - 1 �s�̃f�[�^�� FList[Ri] ���� Dest �Ɏ擾����
      // Ri �� FList.Count - 1 ���z����ꍇ�́ADest �ɋ󔒂�Source[n]
      // ��ǉ�����
      // Dest[0..Count - 1] �� FList ���X�V����B
      if Selected then
        SelDeletedList(Dest);
      for I := 0 to Source.Count - 1 do
      begin
        if I <= Dest.Count - 1 then
        begin
          // Dest[I] �� Source[I] ��}��
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
          // Dest �ɒǉ�
          if Ri <= FList.Count - 1 then
          begin
            // FList ����擾
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
            // �󔒁{ Source[I] ��ǉ�
            Dest.Add(StringOfChar(#$20, Ci - 1) + Source[I]);
            Li := Ci;
          end;
        end;
        // �L�����b�g�ʒu
        C := Li - 1 + Length(Source[I]);
      end;
      // ��`�}�����ꂽ�f�[�^�� raEof �ɂȂ邱�Ƃ͖����Ƃ����d�l
      for I := 0 to Dest.Count - 1 do
        if Dest.Rows[I] = raEof then
          Dest.Rows[I] := raCrlf;
      // �X�V���镶������쐬
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
  FRow �̃L�����b�g���O + Buffer + �L�����b�g�����̕������
  �쐬���AFRow ��u��������
  �I����Ԃ̏ꍇ�́A�I��̈�̑O + Buffer + �̈�̌��̕������
  �쐬����
  ��`�I����Ԃł͂���ɁA�I�𕶎������`�ɐ؂������������
  �쐬����
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
    // �L�����b�g�ʒu FSelStr.Sc �ł͂Ȃ����Ƃɒ���
    SelIndex := GetSelIndex(Ri, FSelDraw.Sr, FSelDraw.Sc);
    Rs := Sr;
    Re := Er;
    // �u�������镶������쐬
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
    // �u�������镶������쐬�B
    // FRow, FCol �̕����C���f�b�N�X
    S := ListStr(FRow);
    L := Length(S);
    Attr := StrToAttributes(S);
    // Si �͂O�x�[�X
    Si := FCol - IncludeCharCount(Attr, caTabSpace, FCol + 1);
    // FRow �̃L�����b�g���O
    if L < Si then
      FS := S + StringOfChar(#$20, Si - L)
    else
      FS := Copy(S, 1, Si);
    // FRow �̃L�����b�g����
    BS := Copy(S, Si + 1, Length(S));
    FList.CheckCrlf(Re, BS);
    // �}�����镶����̊���
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
  �w�肳�ꂽ�|�C���g���� FLines �̍s�ԍ��Ƃ��̍s��������ł̕���
  �C���f�b�N�X��Ԃ��B
  �s�ԍ��A�����C���f�b�N�X�͋��ɂO�x�[�X�ł��邱�Ƃɒ���
  ���[�h���b�v�A�S�p�����A�^�u�ɂ͑Ή����Ă��Ȃ��B
*)
var
  R, C: Integer;
begin
  Result.Line := -1;
  Result.CharIndex := -1;
  // ���l�� OnMouseMove �n���h���ɓ������ꍇ�AFFontWidth �� 0 �̏ꍇ������̂�
  if (FList.Count = 0) or (FFontWidth = 0) then
    Exit;
  PosToRowCol(Pos.X, Pos.Y, R, C, True);
  if (R < 0) or (FList.Count < R) then
    Exit;
  // Lines �ɕϊ�
  Result.Line := RowToLines(R);
  Result.CharIndex := ColToChar(R, C);
end;

function TEditor.StrToAttributes(const S: String): String;
(*
  S ���\������e�����̕���������\�����镶�����Ԃ�

  caEof        = #$30; {'0'}
  caAnk        = #$31; {'1'}
  caDelimiter  = #$32; {'2'}
  caTabSpace   = #$33; {'3'}
  caDBCS1      = #$34; {'4'}
  caDBCS2      = #$35; {'5'}

  �Ԓl�̒����� MaxLineCharacter �ȏ�ɂȂ������_�ŏ����𒆒f����B
  �������S�p�P�o�C�g�ڂ̏ꍇ�A�Ԓl�̒����� MaxLineCharacter + 1
  �ɂȂ�B�^�u�����̏ꍇ�́A����ȏ�ɂȂ�ꍇ������B
  WordWrap = True �̏ꍇ�́AWrapByte + 3 �ȏ�ɂȂ������_�Œ��f����B
  + 3 �́AWordWrap ���̕����񒷂̏���l�Bcf StrToWrapList
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
  ������ S �̑O�̕����̃X�y�[�X����Ԃ��B
  �S�p�X�y�[�X���J�E���g����
  �^�u�����ɂ��Ή�����B
  S = '' �̎��� -1 ��Ԃ�
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


// RowMark �֘A //////////////////////////////////

(*
  #RowMarks
  �ȉ��̃��\�b�h�ł́A������̍X�V�ɍ��킹�āARowMarks �f�[�^��
  �X�V���Ă���B
    TEditorScreenStrings
      ChangeList
      UpdateList
      StretchLines
      WrapLines
    TEditorUndoObj
      Redo
      Undo
  �܂��A�ݒ肳��Ă��� RowMarks ��ێ����āA�|�b�v�A�b�v���j���[�ɔ��f
  �����邽�߁ATEditorScreenStrings �� FValidRowMarks: TRowMarks �ϐ���
  IncludeRowMarks, ExcludeRowMarks ���\�b�h��p�ӂ��Ă���B
  ��L���\�b�h�Q�̂����ATEditorScreenStrings.DeleteList �𗘗p���郁�\
  �b�h�� TEditor.SetListRowMarks ���\�b�h�� FValidRowMarks �f�[�^��
  �X�V���Ă���B
*)

procedure TEditor.PutRowMark(Index: Integer; Mark: TRowMark);
var
  I: Integer;
begin
  if Mark in [rm0..rm9] then
    for I := 0 to FList.Count - 1 do
      if Mark in FList.RowMarks[I] then
      begin
        // ListRowMarks �v���p�e�B�ɑ�����ĕ`�悳����
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

