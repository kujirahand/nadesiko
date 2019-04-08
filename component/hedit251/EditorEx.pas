(***********************************************************

  TEditorEx (2004/02/11)

  Copyright (c) 2001-2004 Km <CQE03114@nifty.ne.jp>
  http://homepage2.nifty.com/Km/

***********************************************************)
unit EditorEx;

{$BOOLEVAL OFF}

interface

uses
  Windows, Classes, Controls, Graphics, SysUtils, Messages, ShellApi,
  HEditor, hOleddEditor, heClasses, heUtils, heRaStrings, hOleddUtils, heFountain,
  bmRegExp;

const
  // ������
  ckSeparator = #$30; // '0':�Z�p���[�^
  ckHAnk      = #$31; // '1':���p�p����
  ckHKatakana = #$32; // '2':���p�J�^�J�i
  ckZAnk      = #$33; // '3':�S�p�p����
  ckZKatakana = #$34; // '4':�S�p�J�^�J�i
  ckZHiragana = #$35; // '5':�Ђ炪��
  ckZKanji    = #$36; // '6':����

type
  // �����I�v�V����
  TExSearchOption = (soMatchCase, soRegexp, soFuzzy, soWholeWord);
  TExSearchOptions = set of TExSearchOption;

  TEditorExMarks = class;
  TAWKStrEx      = class;
  TVerticalLine  = class;
  TVerticalLines = class;

  // �P�s�������`�悷��ۂ̌���������̏��
  PSearchInfo = ^TSearchInfo;
  TSearchInfo = record
    Start, Len: Integer;
    Str: string;
  end;

  // ���ʂ̏��
  TParenInfo = record
    Row, Index: Integer;
    Paren: string;
  end;


// ---------------------------------------------------------
// TEditorEx
// ---------------------------------------------------------

  TEditorEx = class(TOleddEditor)
  private
    FExMarks: TEditorExMarks;
    FDropFileNames: TStrings;
    FFindString: string;
    FExSearchOptions: TExSearchOptions;
    FSearchInfoList: TList;
    FAWKStrEx: TAWKStrEx;
    FVerticalLines: TVerticalLines;
    FParen: Boolean;
    FLeftParenInfo: TParenInfo;
    FRightParenInfo: TParenInfo;
    FLastLine: Integer;
    FChanged: Boolean;
    FCaretMoveCount: Integer;
    procedure SetExMarks(Value: TEditorExMarks);
    procedure SetFindString(const S: string);
    procedure SetExSearchOptions(Value: TExSearchOptions);
    procedure SetVerticalLines(Value: TVerticalLines);
    procedure ClearSearchInfo;
    function SetSearchInfoList(const ARow: Integer): Integer;
    function SetParenInfo(ARow, Index: Integer): Boolean;
  protected
    procedure DoCaretMoved; override;
    procedure DoChange; override;
    procedure DoDrawLine(ARect: TRect; X, Y: Integer; LineStr: string; Index: Integer; SelectedArea: Boolean); override;
    procedure DoDropFiles(Drop: HDrop; KeyState: Longint; Point: TPoint); override;
    procedure DrawDBSpaceMark(X, Y: Integer; IsLeadByte: Boolean); virtual;
    procedure DrawSpaceMark(X, Y: Integer); virtual;
    procedure DrawTabMark(X, Y: Integer); virtual;
    procedure DrawFindMark(Xp, Xq, Y: Integer); virtual;
    procedure DrawFindString(ARect: TRect; X: Integer; S: string); virtual;
    procedure DrawParenMark(X, Y: Integer; S: string); virtual;
    procedure DrawLineMark(ARect: TRect; X, Y: Integer; S: String; Index: Integer; AColor: TColor); virtual;
    procedure DrawEof(X, Y: Integer); override;
    procedure DrawUnderline(ARow: Integer); override;
    procedure DrawVerticalLine(Index: Integer); virtual;
    procedure DrawVerticalLines; virtual;
    procedure Paint; override;
    function CharKind(const S: string; Index: Integer): Char; virtual;
    function ColToListChar(ARow, ACol: Integer): Integer; virtual;
    function GetLineFirstRow(ARow: Integer): Integer; virtual;
    function GetLineLastRow(ARow: Integer): Integer; virtual;
    function CreateEditorExMarks: TEditorExMarks; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function LineString(const ARow: Integer): string;
    function CharKindFromCaret: Char;
    function CharKindFromPos(const Pos: TPoint): Char;
    function IsWholeWord(const S: string; const Start, Len: Integer): Boolean;
    function FindNext: Boolean;
    function FindPrev: Boolean;
    function Replace(const S: string): Boolean;
    function ReplaceAll(const S: string; Visible: Boolean): Integer;
    function EscSeqToString(const S: string): string;
    function IsRowSelected: Boolean;
    function IsRowHit(const ARow: Integer): Boolean;
    procedure GotoParenMark;
    property DropFileNames: TStrings read FDropFileNames;
  published
    property ExMarks: TEditorExMarks read FExMarks write SetExMarks;
    property FindString: string read FFindString write SetFindString;
    property ExSearchOptions: TExSearchOptions read FExSearchOptions write SetExSearchOptions;
    property VerticalLines: TVerticalLines read FVerticalLines write SetVerticalLines;
  end;

// ---------------------------------------------------------
// TEditorExMarks
// ---------------------------------------------------------

  TEditorExMarks = class(TNotifyPersistent)
  private
    FDBSpaceMark: TEditorMark;
    FSpaceMark: TEditorMark;
    FTabMark: TEditorMark;
    FFindMark: TEditorMark;
    FHit: TFountainColor;
    FParenMark: TEditorMark;
    FCurrentLine: TEditorMark;
    FDigitLine: TEditorMark;
    FImageLine: TEditorMark;
    FImg0Line: TEditorMark;
    FImg1Line: TEditorMark;
    FImg2Line: TEditorMark;
    FImg3Line: TEditorMark;
    FImg4Line: TEditorMark;
    FImg5Line: TEditorMark;
    FEvenLine: TEditorMark;
    function  GetIndicated: Boolean;
    procedure SetDBSpaceMark(Value: TEditorMark);
    procedure SetSpaceMark(Value: TEditorMark);
    procedure SetTabMark(Value: TEditorMark);
    procedure SetFindMark(Value: TEditorMark);
    procedure SetHit(Value: TFountainColor);
    procedure SetParenMark(Value: TEditorMark);
    procedure SetCurrentLine(Value: TEditorMark);
    procedure SetDigitLine(Value: TEditorMark);
    procedure SetImageLine(Value: TEditorMark);
    procedure SetImg0Line(Value: TEditorMark);
    procedure SetImg1Line(Value: TEditorMark);
    procedure SetImg2Line(Value: TEditorMark);
    procedure SetImg3Line(Value: TEditorMark);
    procedure SetImg4Line(Value: TEditorMark);
    procedure SetImg5Line(Value: TEditorMark);
    procedure SetEvenLine(Value: TEditorMark);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Indicated: Boolean read GetIndicated;
    property DBSpaceMark: TEditorMark read FDBSpaceMark write SetDBSpaceMark;
    property SpaceMark: TEditorMark read FSpaceMark write SetSpaceMark;
    property TabMark: TEditorMark read FTabMark write SetTabMark;
    property FindMark: TEditorMark read FFindMark write SetFindMark;
    property Hit: TFountainColor read FHit write SetHit;
    property ParenMark: TEditorMark read FParenMark write SetParenMark;
    property CurrentLine: TEditorMark read FCurrentLine write SetCurrentLine;
    property DigitLine: TEditorMark read FDigitLine write SetDigitLine;
    property ImageLine: TEditorMark read FImageLine write SetImageLine;
    property Img0Line: TEditorMark read FImg0Line write SetImg0Line;
    property Img1Line: TEditorMark read FImg1Line write SetImg1Line;
    property Img2Line: TEditorMark read FImg2Line write SetImg2Line;
    property Img3Line: TEditorMark read FImg3Line write SetImg3Line;
    property Img4Line: TEditorMark read FImg4Line write SetImg4Line;
    property Img5Line: TEditorMark read FImg5Line write SetImg5Line;
    property EvenLine: TEditorMark read FEvenLine write SetEvenLine;
  end;

// ---------------------------------------------------------
// TAWKStrEx
// ---------------------------------------------------------

  TAWKStrEx = class(TAWKStr)
  private
    FMatchProc: TAWKStrMatchProc;
  protected
    procedure SetRegExp(S: String); override;
    function SetSearchInfoList(Line, Text: string; List: TList): Integer; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

// ---------------------------------------------------------
// TVerticalLine
// ---------------------------------------------------------

  TVerticalLine = class(TCollectionItem)

  private
    FPosition: Integer;
    FColor: TColor;
    FVisible: Boolean;
    FPrevPosition: Integer;
    procedure SetPosition(Value: Integer);
    procedure SetColor(Value: TColor);
    procedure SetVisible(Value: Boolean);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Position: Integer read FPosition write SetPosition;
    property Color: TColor read FColor write SetColor;
    property Visible: Boolean read FVisible write SetVisible;
  end;

// ---------------------------------------------------------
// TVerticalLines
// ---------------------------------------------------------

  TVerticalLines = class(TCollection)

  private
    FOwner: TPersistent;
    function GetItem(Index: Integer): TVerticalLine;
    procedure SetItem(Index: Integer; Value: TVerticalLine);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TVerticalLine;
    procedure Show;
    procedure Hide;
    property Items[Index: Integer]: TVerticalLine read GetItem write SetItem; default;
  end;

implementation

// ---------------------------------------------------------
// TEditorEx
// ---------------------------------------------------------

procedure TEditorEx.SetExMarks(Value: TEditorExMarks);
begin
  FExMarks.Assign(Value);
end;


procedure TEditorEx.SetFindString(const S: string);
begin
  if FFindString <> S then
  begin
    FFindString := S;
    if ExMarks.FFindMark.Visible then Refresh;
  end;
end;


procedure TEditorEx.SetExSearchOptions(Value: TExSearchOptions);
var
  Opts: TExSearchOptions;
begin
  // �����I�v�V�����̑g�ݍ��킹
  // soMatchCase 01010011
  // soRegexp    00001111
  // soFuzzy     00000101
  // soWholeWord 00110000
  if FExSearchOptions <> Value then
  begin
    Opts := [];
    if soWholeWord in Value then Opts := [soWholeWord];
    if soRegexp in Value then
    begin
      Opts := [soRegexp];
      if soFuzzy in Value then Opts := Opts + [soFuzzy];
      FAWKStrEx.UseFuzzyCharDic := soFuzzy in Value;
    end;
    if soMatchCase in Value then Opts := Opts + [soMatchCase];
    FExSearchOptions := Opts;
    if ExMarks.FFindMark.Visible then Refresh;
  end;
end;


procedure TEditorEx.SetVerticalLines(Value: TVerticalLines);
begin
  FVerticalLines.Assign(Value);
end;


procedure TEditorEx.ClearSearchInfo;
var
  I: Integer;
begin
  for I := FSearchInfoList.Count - 1 downto 0 do
  begin
    Dispose(PSearchInfo(FSearchInfoList.Items[I]));
    FSearchInfoList.Delete(I);
  end;
end;


// SearchInfoList�̐ݒ�
//
// ��s�����񒆂̌���������̊J�n�ʒu�ƒ��������X�g�Ɋi�[����B
// �q�b�g����������̒�����0�ƂȂ�ꍇ�̓q�b�g���ĂȂ��悤�ɂ���B
//
function TEditorEx.SetSearchInfoList(const ARow: Integer): Integer;
var
  Line, FindStr, LineStr: string;
  I, FindLen, Start:      Integer;
  pText:                  PChar;
  IsWholeWordOption:      Boolean;
  Info:                   PSearchInfo;
begin
  ClearSearchInfo;
  // ARow�s���܂ނP�s������
  Line := LineString(ARow);
  // �啶���Ə���������ʂ���ꍇ�A����������ƈ�s�������
  // �������ɓ��ꂵ�Č�������������B
  if soMatchCase in FExSearchOptions then
  begin
    FindStr := FFindString;
    LineStr := Line;
  end
  else
  begin
    FindStr := AnsiLowerCase(FFindString);
    LineStr := AnsiLowerCase(Line);
  end;
  // ���K�\�����g���ꍇ
  if soRegexp in FExSearchOptions then
  begin
    FAWKStrEx.RegExp := FindStr;
    // �ŏI�s���܂ވ�s������ȊO�͉��s(#13#10)��t�����`��
    // FAWKStrEx�ŏ�������B
    I := ARow;
    while (I < ListCount) and (ListRow[I] = raWrapped) do Inc(I);
    if (ListRow[I] <> raEof) then LineStr := LineStr + #13#10;
    Result := FAWKStrEx.SetSearchInfoList(Line, LineStr, FSearchInfoList);
    Exit;
  end;
  // ���K�\�����g��Ȃ��ꍇ
  IsWholeWordOption := soWholeWord in FExSearchOptions;
  FindLen := Length(FindStr);
  pText := PChar(LineStr);
  I := AnsiPos(FindStr, LineStr);
  while I > 0 do
  begin
    Start := pText - PChar(LineStr) + I;
    if not IsWholeWordOption or (IsWholeWordOption and IsWholeWord(LineStr, Start, FindLen)) then
    begin
      New(Info);
      Info^.Start := Start;
      Info^.Len   := FindLen;
      Info^.Str   := Copy(Line, Info^.Start, Info^.Len);
      FSearchInfoList.Add(Info);
    end;
    pText := pText + I + FindLen - 1;
    I := AnsiPos(FindStr, string(pText));
  end;
  Result := FSearchInfoList.Count;
end;


// �Ή����銇��
//
// ARow�AIndex(1�x�[�X)�ʒu�̊��ʂƂ��̊��ʂɑΉ����銇�ʂ�ݒ肷��B
// �^�u�����W�J�O�ŏ������邽�߁ACol�ł͂Ȃ�Index�Ƃ��Ă���B
// ���ʂłȂ�������Ή����銇�ʂ������ꍇ��False��Ԃ��B
//
function TEditorEx.SetParenInfo(ARow, Index: Integer): Boolean;
const
  LPAREN = '(<[{�e�g�i�u�w�y����';
  RPAREN = ')>]}�f�h�j�v�x�z����';
var
  S, T, P, C:      string;
  ByteSize, Stack: Integer;
  LPos, RPos:      Integer;
  I, R:            Integer;
begin
  Result := False;
  FLeftParenInfo.Paren  := '';
  FRightParenInfo.Paren := '';
  if Index <= 0 then Index := 1;

  // (ARow, Index)�ʒu�̈ꕶ�����擾(T)
  S := ListString[ARow];
  // ByteType�͂O�x�[�X
  if ByteType(S, Index) = mbSingleByte then ByteSize := 1
  else
  begin
    // Index�ʒu�̕�����2�o�C�g������2�Ԗڂ̏ꍇ��Index��1���炷
    if ByteType(S, Index) = mbTrailByte then Dec(Index);
    ByteSize := 2;
  end;
  T:= Copy(S, Index, ByteSize);
  // T�������ʂȂ̂��E���ʂȂ̂����擾���A�ǂ���ł��Ȃ��ꍇ�͏I��
  LPos := AnsiPos(T, LPAREN);
  RPos := AnsiPos(T, RPAREN);
  if (LPos = 0) and (RPos = 0) then Exit;

  // �����ʂ̏ꍇ�͉E���ʂ�T��
  if LPos > 0 then
  begin
    // �����ʂ̏����i�[
    FLeftParenInfo.Row   := ARow;
    FLeftParenInfo.Index := Index;
    FLeftParenInfo.Paren := T;
    // ������(T)�ɑΉ�����E����(P)
    P := Copy(RPAREN, LPos, ByteSize);
    // ����銇�ʂ̓X�^�b�N�ɐςݏグ��
    // Stack��0�ɂȂ��������Ή����銇�ʂ�����������
    Stack := 0;
    for R := ARow to ListCount - 1 do
    begin
      S := ListString[R];
      for I := Index to Length(S) do
      begin
        // Index�ʒu�̕�����2�o�C�g������2�Ԗڂ̏ꍇ�͎�
        if ByteType(S, I) = mbTrailByte then Continue;
        C := Copy(S, I, ByteSize);
        if T = C then Inc(Stack);
        if P = C then Dec(Stack);
        if Stack = 0 then
        begin
          FRightParenInfo.Row   := R;
          FRightParenInfo.Index := I;
          FRightParenInfo.Paren := P;
          Result := True;
          Exit;
        end;
      end;
      Index := 1;
    end;
  end;
  // �E���ʂ̏ꍇ�͍����ʂ�T��
  if RPos > 0 then
  begin
    // �E���ʂ̏����i�[
    FRightParenInfo.Row   := ARow;
    FRightParenInfo.Index := Index;
    FRightParenInfo.Paren := T;
    // �E����(T)�ɑΉ����鍶����(P)
    P := Copy(LPAREN, RPos, ByteSize);
    // ����銇�ʂ̓X�^�b�N�ɐςݏグ��
    // Stack��0�ɂȂ��������Ή����銇�ʂ�����������
    Stack := 0;
    S := ListString[ARow];
    for R := ARow downto 0 do
    begin
      for I := Index downto 1 do
      begin
        // Index�ʒu�̕�����2�o�C�g������2�Ԗڂ̏ꍇ�͎�
        if ByteType(S, I) = mbTrailByte then Continue;
        C := Copy(S, I, ByteSize);
        if T = C then Inc(Stack);
        if P = C then Dec(Stack);
        if Stack = 0 then
        begin
          FLeftParenInfo.Row   := R;
          FLeftParenInfo.Index := I;
          FLeftParenInfo.Paren := P;
          Result := True;
          Exit;
        end;
      end;
      S := ListString[R - 1];
      Index := Length(S);
    end;
  end;
end;


// ---------------------------------------------------------

// �L�����b�g�ړ���
//
procedure TEditorEx.DoCaretMoved;
var
  Index: Integer;
  // ���ʂ̂���s���ĕ`��
  procedure InvalidateParen(L, R: Integer);
  begin
    InvalidateLine(L);
    if L <> R then InvalidateLine(R);
  end;
begin
  inherited DoCaretMoved;
  if FExMarks.FCurrentLine.Visible and (FLastLine <> Row) then
  begin
    InvalidateLine(FLastLine);
    InvalidateLine(Row);
    FLastLine := Row;
  end;
  if not FExMarks.FParenMark.Visible then Exit;
  // �O��̊��ʂ̍s���ĕ`�悵�Ă���
  if FParen then InvalidateParen(FLeftParenInfo.Row, FRightParenInfo.Row);
  // ����̊���
  Index  := ColToListChar(Row, Col) + 1;
  FParen := SetParenInfo(Row, Index);
  // �L�����b�g�ʒu�����ʂŖ����ꍇ�A���O�����ׂ�
  if not FParen then FParen := SetParenInfo(Row, Index - 1);
  // ����̊��ʂ̍s���ĕ`�悷��
  if FParen then InvalidateParen(FLeftParenInfo.Row, FRightParenInfo.Row);
  // �s���܂����悤�ȓ��͂��������ꍇ�ARow,Col�̏���2��DoCaretMoved��
  // �Ă΂�邽�߁A2��ڂ����\�����Ă���S�s�`�悷��B
  if FChanged then
  begin
    Inc(FCaretMoveCount);
    if FCaretMoveCount = 2 then
    begin
      InvalidateRow(TopRow, TopRow + RowCount);
      FChanged := False;
    end;
  end;
end;


procedure TEditorEx.DoChange;
begin
  inherited DoChange;
  FChanged := True;
  FCaretMoveCount := 0;
end;


// �s�̕`��
//
// �ʏ�̕������}�[�N��PaintLine/PaintLineSelected�ŕ`�悷�邽�߁A
// �����ł͊g�������}�[�N�̕`��������Ȃ��B
//
procedure TEditorEx.DoDrawLine(
  ARect:        TRect;
  X, Y:         Integer;
  LineStr:      string;
  Index:        Integer;
  SelectedArea: Boolean);
var
  DM, SM, TM, FM, PM, CLM, DLM, ELM: Boolean;
  ILM, I0M, I1M, I2M, I3M, I4M, I5M: Boolean;
  S, FindStr:             string;
  CW, LMSW, LPos, RPos:   Integer;
  I, Xp, Xq, Xs, LC, RC:  Integer;
  Count, FindLC, FindRC:  Integer;
  Info:                   PSearchInfo;
  AColor:                 TColor;

  // �`��ʒu�̌v�Z(1�x�[�X)
  function DrawPos(I: Integer): Integer;
  begin
    Result := ExpandTabLength(Copy(S, 1, I - 1)) * CW + LMSW;
  end;
  // �`��\�̈悩�ǂ����̔���
  function IsDrawArea(Xp: Integer): Boolean;
  begin
    Result := (Xp >= LPos) and (Xp < RPos);
  end;
  // �����s��0�x�[�X�Ƃ��邩�̔���
  function IsEvenLine: Boolean;
  var
    Even, Zero: Boolean;
  begin
    Even := (Index mod 2) = 0;
    Zero := Leftbar.ZeroBase;
    Result := (Even and Zero) or (not Even and not Zero);
  end;

begin
  inherited DoDrawLine(ARect, X, Y, LineStr, Index, SelectedArea);
  DrawVerticalLines;
  // ExMark�������\�����Ȃ��ꍇ�͏I��
  if not FExMarks.Indicated then Exit;

  DM  := FExMarks.FDBSpaceMark.Visible;
  SM  := FExMarks.FSpaceMark.Visible;
  TM  := FExMarks.FTabMark.Visible;
  FM  := FExMarks.FFindMark.Visible;
  PM  := FExMarks.FParenMark.Visible;
  CLM := FExMarks.FCurrentLine.Visible;
  DLM := FExMarks.FDigitLine.Visible;
  ILM := FExMarks.FImageLine.Visible;
  I0M := FExMarks.FImg0Line.Visible;
  I1M := FExMarks.FImg1Line.Visible;
  I2M := FExMarks.FImg2Line.Visible;
  I3M := FExMarks.FImg3Line.Visible;
  I4M := FExMarks.FImg4Line.Visible;
  I5M := FExMarks.FImg5Line.Visible;
  ELM := FExMarks.FEvenLine.Visible;

  S    := ListStr(Index);
  CW   := ColWidth;
  LMSW := LeftMargin - LeftScrollWidth;
  LPos := ARect.Left;
  RPos := Min(ARect.Right, MaxLineCharacter * CW + LMSW);
  // �s�̐F�t��
  if (CLM or DLM or ILM or I0M or I1M or I2M or I3M or I4M or I5M or ELM) and  not SelectedArea then
  begin
    AColor := clNone;
    if CLM and (Index = Row) then AColor := FExMarks.FCurrentLine.Color
    else if DLM and (ListRowMarks[Index] * [rm0..rm9] <> []) then AColor := FExMarks.FDigitLine.Color
    else if I0M and (rm10 in ListRowMarks[Index]) then AColor := FExMarks.FImg0Line.Color
    else if I1M and (rm11 in ListRowMarks[Index]) then AColor := FExMarks.FImg1Line.Color
    else if I2M and (rm12 in ListRowMarks[Index]) then AColor := FExMarks.FImg2Line.Color
    else if I3M and (rm13 in ListRowMarks[Index]) then AColor := FExMarks.FImg3Line.Color
    else if I4M and (rm14 in ListRowMarks[Index]) then AColor := FExMarks.FImg4Line.Color
    else if I5M and (rm15 in ListRowMarks[Index]) then AColor := FExMarks.FImg5Line.Color
    else if ILM and (ListRowMarks[Index] * [rm10..rm15] <> []) then AColor := FExMarks.FImageLine.Color
    else if ELM and IsEvenLine then AColor := FExMarks.FEvenLine.Color;
    // �s�̕`��
    if AColor <> clNone then DrawLineMark(ARect, X, Y, LineStr, Index, AColor);
  end;
  // �����}�[�N
  if FM then
  begin
    // �^�u�����W�J�O
    //       |1234567890|
    //       +----------+
    //       |*.........|*
    //       +----------+
    //        LC         RC
    //       +----------+
    // 1 ooo |..........|
    // 2   oo|oo........|
    // 3     |...oooo...|
    // 4     |........oo|oo
    // 5    o|oooooooooo|o
    // 6     |..........| ooo
    // 7     |..........|
    //       +----------+
    // �p�^�[��2,3,4,5�̏ꍇ�`�悷��
    //       +----------+
    //       |...oooo...|
    //       |...*...*..|
    //       |...FLC.FRC|
    //       +----------+
    //
    // �`��s�̈�(�P�x�[�X)
    LC := ColToChar(Index, 0) + 1;
    RC := LC + Length(S);
    // �`��s���܂ނP�s������̌�������ݒ�
    try
      Count := SetSearchInfoList(Index);
      for I := 0 to Count - 1 do
      begin
        Info := FSearchInfoList.Items[I];
        FindLC := Info^.Start;
        FindRC := Info^.Start + Info^.Len;
        // �p�^�[��1,6�͏���(7�͍ŏ����疳��)
        if (FindRC <= LC) or (FindLC >= RC) then Continue;
        // �p�^�[��2,5
        if (FindLC < LC) then FindLC := LC;
        // �p�^�[��4,5
        if (FindRC > RC) then FindRC := RC;
        // �c�����̂̓p�^�[��3
        Xp := DrawPos(FindLC - LC + 1);
        Xq := DrawPos(FindRC - LC + 1);
        Xs := Xp;
        if (Xp < LPos) and (Xq >= LPos) then Xp := LPos;
        if (Xp <= RPos) and (Xq > RPos) then Xq := RPos;
        if (Xp >= LPos) and (Xq <= RPos) then
        begin
          if not SelectedArea then
          begin
            // �`�悷�镶����
            FindStr := Copy(Info^.Str, FindLC - Info^.Start + 1, FindRC - FindLC);
            FindStr := ExpandTab(FindStr);
            DrawFindString(Rect(Xp, Y, Xq - 1, Y + FontHeight), Xs, FindStr);
          end;
          DrawFindMark(Xp, Xq, Y);
        end;
      end;
    except
      //on ERegExpParser do Exit;
    end;
  end;
  // �`��s����o�C�g���E����ExMark�̏ꍇ�͕`�悷��B
  for I := 1 to Length(S) do
  begin
    // �S�p�󔒃}�[�N
    if  DM and (S[I] = #$81) and (S[I+1] = #$40) then
    begin
      Xp := DrawPos(I);
      if IsDrawArea(Xp) then DrawDBSpaceMark(Xp, Y, True)
      else
        // �S�p�󔒂̑�2�o�C�g�ڂ��`��̈�ɂ������Ă���ꍇ
        if IsDrawArea(Xp + CW) then DrawDBSpaceMark(Xp, Y, False);
      Continue;
    end;
    // ���p�󔒃}�[�N
    if SM and (S[I] = #$20) then
    begin
      Xp := DrawPos(I);
      if IsDrawArea(Xp) then DrawSpaceMark(Xp, Y);
      Continue;
    end;
    // �^�u�}�[�N
    if TM and (S[I] = #09) then
    begin
      Xp := DrawPos(I);
      if IsDrawArea(Xp) then DrawTabMark(Xp, Y);
      Continue;
    end;
    // ���ʃ}�[�N
    if PM and FParen then
    begin
      Xp := DrawPos(I);
      if IsDrawArea(Xp) and FParen then
      begin
        if (Index = FLeftParenInfo.Row) and (I = FLeftParenInfo.Index) then
          DrawParenMark(Xp, Y, FLeftParenInfo.Paren);
        if (Index = FRightParenInfo.Row) and (I = FRightParenInfo.Index) then
          DrawParenMark(Xp, Y, FRightParenInfo.Paren);
      end;
    end;
  end;
end;


procedure TEditorEx.DoDropFiles(Drop: HDrop; KeyState: Longint; Point: TPoint);
begin
  HandleToFileNames(Drop, FDropFileNames);
  inherited DoDropFiles(Drop, KeyState, Point);
end;


procedure TEditorEx.DrawDBSpaceMark(X, Y: Integer; IsLeadByte: Boolean);
var
  CW, FH: Integer;
  R:      TRect;
begin
  if not Showing then Exit;
  CW := ColWidth;
  FH := FontHeight;
  with Canvas do
  begin
    CaretBeginUpdate;
    try
      // �Q�o�C�g�����̂P�o�C�g�ڂ�
      if IsLeadByte then
      begin
        // �S�p�󔒃}�[�N�S�̂̕`��
        Brush.Style := bsSolid;
        Brush.Color := FExMarks.FDBSpaceMark.Color;
        R := Rect(X, Y + 1, X + CW * 2 - 1, Y + FH - 2);
        FrameRect(R);
      end
      else
      begin
        // �S�p�󔒃}�[�N��딼���̕`��
        Pen.Style := psSolid;
        Pen.Width := 1;
        Pen.Color := FExMarks.FDBSpaceMark.Color;
        MoveTo(X + CW, Y + 1);
        LineTo(X + CW * 2 - 2, Y + 1);
        LineTo(X + CW * 2 - 2, Y + FH - 3);
        LineTo(X + CW - 1, Y + FH - 3);
      end;
    finally
      CaretEndUpdate;
    end;
  end;
end;


procedure TEditorEx.DrawSpaceMark(X, Y: Integer);
var
  R: TRect;
begin
  if not Showing then Exit;
  R := Rect(X, Y + 1, X + ColWidth - 1, Y + FontHeight - 2);
  with Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := FExMarks.FSpaceMark.Color;
    CaretBeginUpdate;
    try
      FrameRect(R);
    finally
      CaretEndUpdate;
    end;
  end;
end;


procedure TEditorEx.DrawTabMark(X, Y: Integer);
var
  I, J, K: Integer;
begin
  if not Showing then Exit;
  Y := Y + FontHeight div 2;
  I := Max(1, FontHeight div 8);
  J := X + ColWidth - 1;
  K := Max(I, 3);
  with Canvas do
  begin
    Pen.Style := psSolid;
    Pen.Width := 1;
    Pen.Color := FExMarks.FTabMark.Color;
    CaretBeginUpdate;
    try
      MoveTo(X + 1, Y);
      LineTo(J, Y);
      LineTo(J - K, Y - K);
      MoveTo(J, Y);
      LineTo(J - K, Y + K);
    finally
      CaretEndUpdate;
    end;
  end;
end;


procedure TEditorEx.DrawFindMark(Xp, Xq, Y: Integer);
begin
  if not Showing then Exit;
  Y := Y + FontHeight - 1;
  with Canvas do
  begin
    CaretBeginUpdate;
    try
      // �����}�[�N�̕`���1�h�b�g�̐��ɂ���ꍇ(2.7x-)
      Pen.Width := 1;
      Pen.Style := psSolid;
      Pen.Color := FExMarks.FFindMark.Color;
      MoveTo(Xp, Y);
      LineTo(Xq - 1, Y);
      // �����}�[�N�̕`���2�h�b�g�̐��ɂ���ꍇ(-2.6x)
      //Brush.Style := bsSolid;
      //Brush.Color := FExMarks.FFindMark.Color;
      //FrameRect(Rect(Xp, Y, Xq - 1, Y));
    finally
      CaretEndUpdate;
    end;
  end;
end;


procedure TEditorEx.DrawFindString(ARect: TRect; X: Integer; S: string);
begin
  if not Showing then Exit;
  with Canvas do
  begin
    CaretBeginUpdate;
    try
      if FExMarks.FHit.Color = clNone then
      begin
        Font.Style  := Self.FExMarks.FHit.Style;
        Font.Color  := Self.FExMarks.FHit.Color;
      end
      else
      begin
        Font.Style  := FExMarks.FHit.Style;
        Font.Color  := FExMarks.FHit.Color;
      end;
      Brush.Style := bsSolid;
      if FExMarks.FHit.BkColor = clNone then Brush.Color := Color
      else Brush.Color := FExMarks.FHit.BkColor;
      DrawTextRect(ARect, X, ARect.Top, S, ETO_CLIPPED);
    finally
      CaretEndUpdate;
    end;
  end;
end;


procedure TEditorEx.DrawParenMark(X, Y: Integer; S: string);
var
  R: TRect;
begin
  if not Showing then Exit;
  R := Rect(X, Y, X + ColWidth * Length(S), Y + FontHeight);
  with Canvas do
  begin
    Font.Style  := [fsBold];
    Brush.Style := bsSolid;
    Brush.Color := FExMarks.FParenMark.Color;
    CaretBeginUpdate;
    try
      DrawTextRect(R, X, Y, S, ETO_CLIPPED);
    finally
      CaretEndUpdate;
    end;
  end;
end;


procedure TEditorEx.DrawLineMark(
  ARect:  TRect;
  X, Y:   Integer;
  S:      String;
  Index:  Integer;
  AColor: TColor);
var
  CW, LMSW, LPos, RPos: Integer;
  Xp, SL:               Integer;
  FountainColor:        TFountainColor;
  Style:                TFontStyles;
  FontColor:            TColor;
  Parser:               TFountainParser;
begin
  if not Showing then Exit;
  SL   := ExpandTabLength(ListStr(Index));
  CW   := ColWidth;
  LMSW := LeftMargin - LeftScrollWidth;
  LPos := LeftMargin;
  RPos := Min(ARect.Right, Min(X + SL * CW, MaxLineCharacter * CW + LMSW));
  CaretBeginUpdate;
  try
    // �̈��h��Ԃ�
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := AColor;
    Canvas.FillRect(ARect);
    // ��������p�[�X���ĕ`��
    if S <> '' then
    begin
      Style     := Font.Style;
      FontColor := Font.Color;
      Parser    := ActiveFountain.CreateParser;
      try
        Parser.NewData(S, ListData[Index]);
        while Parser.NextToken <> toEof do
        begin
          if Parser.SourcePos >= SL then Break;
          FountainColor := Parser.TokenToFountainColor;
          Xp := X + Parser.SourcePos * CW;
          if (LPos <= Xp + Parser.TokenLength * CW) and (Xp <= RPos) then
          begin
            if FountainColor <> nil then
            begin
              Canvas.Font.Style := FountainColor.Style;
              if FountainColor.Color = clNone then Canvas.Font.Color := FontColor
              else Canvas.Font.Color := FountainColor.Color;
            end
            else
            begin
              Canvas.Font.Style := Style;
              Canvas.Font.Color := FontColor;
            end;
            ARect.Right := RPos;
            DrawTextRect(ARect, Xp, Y, Parser.TokenString, ETO_CLIPPED);
          end
          else
            if RPos < Xp then Break;
        end;
      finally
        Parser.Free;
      end;
    end;
  finally
    CaretEndUpdate;
  end;
end;


procedure TEditorEx.DrawEof(X, Y: Integer);
var
  R: TRect;
  TM, LM: Integer;
begin
  if not Showing then Exit;
  TM := TopMargin;
  LM := LeftMargin;
  R  := Rect(Min(Max(LM, X), Width),
             Min(Max(TM, Y), Height),
             Min(Max(LM, X + ColWidth * 6), Width),
             Min(Max(TM, Y + FontHeight), Height));
  Canvas.Font.Assign(Font);
  if Marks.EofMark.Color = clNone then Canvas.Font.Color := Font.Color
  else  Canvas.Font.Color := Marks.EofMark.Color;
  Canvas.Brush.Style := bsClear;
  CaretBeginUpdate;
  try
    DrawTextRect(R, X, Y, '[EOF]', ETO_CLIPPED);
  finally
    CaretEndUpdate;
  end;
end;


procedure TEditorEx.DrawUnderline(ARow: Integer);
begin
  inherited DrawUnderline(ARow);
  DrawVerticalLines;
end;


// �c���̕`��
//
procedure TEditorEx.DrawVerticalLine(Index: Integer);
var
  IX :Integer;
begin
  if HandleAllocated then
  begin
    CaretBeginUpdate;
    try
      if FVerticalLines.Items[Index].Visible then
      begin
        with Canvas do
        begin
          Pen.Color := FVerticalLines.Items[Index].Color;
          IX := LeftMargin - LeftScrollWidth + ColWidth * FVerticalLines.Items[Index].Position;
          if IX >= LeftMargin then
          begin
            MoveTo(IX, FRulerHeight);
            LineTo(IX, Height);
          end;
        end;
      end;
    finally
      CaretEndUpdate;
    end;
  end;
end;


// �c���̕`��
//
procedure TEditorEx.DrawVerticalLines;
var
  I :Integer;
begin
  I := 0;
  while I < FVerticalLines.Count do
  begin
    DrawVerticalLine(I);
    Inc(I);
  end;
end;


procedure TEditorEx.Paint;
begin
  inherited Paint;
  DrawVerticalLines;
end;


// ������̎擾
//
// �����񒆂̔C�ӂ̈ʒu(1�x�[�X)�̕������Ԃ��B
//
function TEditorEx.CharKind(const S: string; Index: Integer): Char;
const
  // ���p��؂�q
  ANKSEP = #9#10#13' !"#$%&''()=~^\|{}[]`@;+:*,<.>/?_���';
  // �S�p��؂�q
  ZENSEP = '�@�A�B�C�D�E�F�G�H�I�J�K�L�M�N�O�P�Q�Z�[�\�]�^�_�`�a�b�c�d'+
           '�e�f�g�h�i�j�k�l�m�n�o�p�q�r�s�t�u�v�w�x�y�z�{�|�}�~������'+
           '����������������������������������������������������������'+
           '����������';
var
  Code: Integer;
begin
  Result := ckSeparator;
  // �͈͊O�̏ꍇ�̓Z�p���[�^��Ԃ�
  if (Index < 1) or (Length(S) < Index) then Exit;

  // Index�ʒu�̕�����1�o�C�g�����̏ꍇ
  if ByteType(S, Index) = mbSingleByte then
  begin
    // ���p��؂�q�̒��Ɍ���������Z�p���[�^��Ԃ�
    if AnsiPos(S[Index], ANKSEP) > 0 then Exit;
    // ���l�Ɋ��Z���Ĕ�r����
    Code := Ord(S[Index]);
    // �k�������̓Z�p���[�^��Ԃ�
    if Code = 0 then Exit;
    // ���p�p����
    if Code < $80 then
    begin
      Result := ckHAnk;
      Exit;
    end;
    // ���p�J�^�J�i
    if Code in [$A1..$DF] then
    begin
      Result := ckHKatakana;
      Exit;
    end;
    Exit;
  end;
  // Index�ʒu�̕�����2�o�C�g������2�Ԗڂ̏ꍇ��Index��1���炷
  if ByteType(S, Index) = mbTrailByte then Dec(Index);
  // �S�p��؂�q�̒��Ɍ���������Z�p���[�^��Ԃ�
  if AnsiPos(Copy(S, Index, 2), ZENSEP) > 0 then Exit;
  // �S�p�𐔒l�Ɋ��Z���Ĕ�r����
  Code := Ord(S[Index]) shl 8 + Ord(S[Index + 1]);
  // �S�p�p����
  if (Code >= $824F) and (Code <= $829A) then
  begin
    Result := ckZAnk;
    Exit;
  end;
  // �S�p�J�^�J�i
  if (Code >= $8340) and (Code <= $8396) then
  begin
    Result := ckZKatakana;
    Exit;
  end;
  // �S�p�Ђ炪��
  if (Code >= $829F) and (Code <= $82F1) then
  begin
    Result := ckZHiragana;
    Exit;
  end;
  // �S�p����
  if Code >= $889F then Result := ckZKanji;
end;


// �����C���f�b�N�X�̎擾
//
// Col��Row�s��̕����C���f�b�N�X�ɕϊ�����(�O�x�[�X)
// ColToChar�̃��W�b�N����raWrapped�̏����𔲂������́B
//
function TEditorEx.ColToListChar(ARow, ACol: Integer): Integer;
var
  S, Attr: String;
begin
  Result := -1;
  if (ARow < 0) or (FList.Count < ARow) or (ACol < 0) then Exit;
  S := ListString[ARow];
  Attr := StrToAttributes(S);
  if IndexChar(Attr, ACol + 1) = caDBCS2 then Dec(ACol);
  while IndexChar(Attr, ACol + 1) = caTabSpace do Dec(ACol);
  Result := Min(Length(S), ACol - IncludeCharCount(Attr, caTabSpace, ACol + 1));
end;


// �P�s������̍ŏ���Row
//
function TEditorEx.GetLineFirstRow(ARow: Integer): Integer;
begin
  Result := ARow;
  if (ARow < 0) or (FList.Count < ARow) then Exit;
  while (Result > 0) and (ListRow[Result - 1] = raWrapped) do Dec(Result);
end;


// �P�s������̍Ō��Row
//
function TEditorEx.GetLineLastRow(ARow: Integer): Integer;    
begin
  Result := ARow;
  if (ARow < 0) or (FList.Count < ARow) then Exit;
  while (Result < FList.Count) and (ListRow[Result] = raWrapped) do Inc(Result);
end;


function TEditorEx.CreateEditorExMarks: TEditorExMarks;
begin
  Result := TEditorExMarks.Create;
  Result.OnChange := ViewChanged;
end;


// ---------------------------------------------------------

constructor TEditorEx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FExMarks          := CreateEditorExMarks;
  FDropFileNames    := TStringList.Create;
  Caret.SelDragMode := dmManual;
  FAWKStrEx         := TAWKStrEx.Create(Self);
  FSearchInfoList   := TList.Create;
  FVerticalLines    := TVerticalLines.Create(self);
end;


destructor TEditorEx.Destroy;
begin
  FExMarks.Free;
  FDropFileNames.Free;
  FAWKStrEx.Free;
  ClearSearchInfo;
  FSearchInfoList.Free;
  FVerticalLines.Free;
  inherited Destroy;
end;


// �P�s������̎擾
//
// Index�s(0�x�[�X)���܂ނP�s��������擾����B
// WordWrap = True �̏ꍇ�ALines.Strings[RowToLines(Index)]���������B
//
function TEditorEx.LineString(const ARow: Integer): string;
var
  S: string;
  I: Integer;
begin
  Result := '';
  // �͈͊O�̏ꍇ��''��Ԃ��B
  if (ARow < 0) or (FList.Count < ARow) then Exit;
  // WordWrap����Ė����ꍇ��ListString�ɂ��镶��������̂܂ܕԂ��B
  if not WordWrap then
  begin
    Result := ListStr(ARow);
    Exit;
  end;
  // WordWrap����Ă���ꍇ�͂P�s������̊J�n�s�܂ők��Ȃ���A�����A
  // ���̌�P�s������̏I���s�܂Ői�߂Ȃ���A������B
  //       ....       raWrapped�ȊO
  //    -1 .......... raWrapped      ] �P�s������
  // Index .......... raWrapped      ]
  //    +1 .......    raWrapped�ȊO  ]
  S := '';
  I := ARow - 1;
  while (I >= 0) and (ListRow[I] = raWrapped) do
  begin
    S := ListStr(I) + S;
    Dec(I);
  end;
  I := ARow;
  while ListRow[I] = raWrapped do
  begin
    S := S + ListStr(I);
    Inc(I);
  end;
  Result := S + ListStr(I);
end;


// �L�����b�g�ʒu�̕�������擾
//
function TEditorEx.CharKindFromCaret: Char;
begin
  Result := CharKind(LineString(Row), ColToChar(Row, Col) + 1);
end;


// �w��ʒu�̕�������擾
//
function TEditorEx.CharKindFromPos(const Pos: TPoint): Char;
var
  R, C: Integer;
begin
  PosToRowCol(Pos.X, Pos.Y, R, C, True);
  Result := CharKind(LineString(R), ColToChar(R, C) + 1);
end;


// �P��̔���
//
// �P��̐擪�̕�����ƒP��̂P�����O�̕����킪�قȂ�A����
// �P��̍Ō�̕�����ƒP��̂P������̕����킪�قȂ�ꍇ�A�P��Ƃ݂Ȃ��B
// �Z�p���[�^�͕K�������킪�قȂ�Ƃ���B
//
function TEditorEx.IsWholeWord(const S: string; const Start, Len: Integer): Boolean;
var
  SFirst, SLast, SPrev, SNext: Char;
begin
  Result := False;
  if (Start < 0) or (Length(S) < Start) then Exit;
  // S�̐擪
  SFirst := CharKind(S, Start);
  // S�̍Ō�
  SLast  := CharKind(S, Start + Len - 1);
  // S�̂P�����O
  SPrev  := CharKind(S, Start - 1);
  // S�̂P������̕�����
  SNext  := CharKind(S, Start + Len);
  Result := (SFirst <> SPrev) and (SLast <> SNext);
end;


// �O������
//
// �L�����b�g�ʒu�ȍ~�̌����B�������AHitStyle = hsCaret��
// �ꍇ�̓L�����b�g�̖�����������������B
//
function TEditorEx.FindNext: Boolean;
var
  ARow, Index, FindStart, FindLen: Integer;
  Info:  PSearchInfo;
  // ��s������̒�����Index�o�C�g�ڈȍ~�ɂ��錟��������̈ʒu
  function FindFirst(ARow, Start: Integer): Boolean;
  var
    Count, I: Integer;
  begin
    Result := False;
    Count  := SetSearchInfoList(ARow);
    for I := 1 to Count do
    begin
      Info := FSearchInfoList.Items[I - 1];
      if Info^.Start > Start then
      begin
        // MaxLineCharacter�𒴂���悤�ȏꍇ�͌����s�Ƃ���
        // �d�l�Ƃ��܂��B���̏ꍇ�͐܂�Ԃ���O��Ƃ��܂��B
        if not WordWrap and (Info^.Start > MaxLineCharacter) then Exit;
        FindStart := Info^.Start;
        FindLen   := Info^.Len;
        Result    := True;
        Exit;
      end;
    end;
  end;
begin
  ARow   := Row;
  Index  := ColToChar(ARow, Col);
  if HitStyle = hsCaret then Index := Index + HitSelLength;
  Result := FindFirst(ARow, Index);
  //�����J�n�s�ɖ����ꍇ�͎��̂P�s�����񂩂猟��
  while not Result and (ARow < ListCount) do
  begin
    ARow := GetLineLastRow(ARow) + 1;
    Result := FindFirst(ARow, 0);
  end;
  // ���������񂪌��������ꍇ�̃L�����b�g�ړ�
  if Result then
  begin
    CleanSelection;
    ARow := GetLineFirstRow(ARow);
    SetSelIndex(ARow, FindStart  - 1);
    HitSelLength := FindLen;
  end;
end;


// �������
//
// �L�����b�g�ʒu�ȑO�̌����B�������AHitStyle = hsCaret��
// �ꍇ�̓L�����b�g�̖�����������������B
//
function TEditorEx.FindPrev: Boolean;
var
  ARow, Index, FindStart, FindLen: Integer;
  Found: Boolean;
  Info: PSearchInfo;
  // ��s������̒�����Index�o�C�g�ڈȑO�ɂ��錟��������̈ʒu
  function FindLast(const ARow: Integer; Last: Integer): Boolean;
  var
    Count, I: Integer;
  begin
    Result := False;
    if not WordWrap and (Last > MaxLineCharacter) then Last := MaxLineCharacter;
    Count := SetSearchInfoList(ARow);
    for I := Count downto 1 do
    begin
      Info := FSearchInfoList.Items[I - 1];
      if Info^.Start <= Last then
      begin
        FindStart := Info^.Start;
        FindLen   := Info^.Len;
        Result    := True;
        Exit;
      end;
    end;
  end;
begin
  Result := False;
  ARow   := Row;
  Index  := ColToChar(ARow, Col);
  Found  := FindLast(ARow, Index);
  while not Found do
  begin
    ARow := GetLineFirstRow(ARow) - 1;
    if ARow < 0 then Break;
    Found := FindLast(ARow, Length(LineString(ARow)) + 2);
  end;

  if Found then
  begin
    CleanSelection;
    ARow := GetLineFirstRow(ARow);
    SetSelIndex(ARow, FindStart  - 1);
    HitSelLength := FindLen;
    if HitStyle <> hsCaret then SetSelIndex(ARow, FindStart  - 1);
    Result := True;
  end;
end;


// �u��
//
// �u������ɂ͂܂�FindNext/FindPrev�Ō�������K�v������B
//
function TEditorEx.Replace(const S: string): Boolean;
begin
  HitToSelected;
  Result := Selected;
  if Result then SelText := S;
end;


// �S�u��
//
// �u����������Ԃ��B
//
function TEditorEx.ReplaceAll(const S: string; Visible: Boolean): Integer;
begin
  Result := 0;
  if not Visible then Lines.BeginUpdate;
  try
    SetRowCol(0, 0);
    while FindNext do
    begin
      Inc(Result);
      HitToSelected;
      SelText := S;
    end;
  finally
    if not Visible then Lines.EndUpdate;
  end;
end;


// �G�X�P�[�v�V�[�P���X�ϊ�
//
// �G�X�P�[�v�V�[�P���X��Ή�����L�����N�^�ɕϊ����ĕԂ��B
//
function TEditorEx.EscSeqToString(const S: string): string;
begin
  Result := FAWKStrEx.ProcessEscSeq(S);
end;


// �s�I���̔���
//
function TEditorEx.IsRowSelected: Boolean;
begin
  Result := Selected and (SelStrPosition.Ec < 0);
end;


// ���������񂪊܂܂�Ă��邩�̔���
//
// �w��s���܂ނP�s������Ɋ܂܂�Ă��邩
//
function TEditorEx.IsRowHit(const ARow: Integer): Boolean;
begin
  Result := SetSearchInfoList(ARow) > 0;
end;


// �Ή����銇�ʂֈړ�
//
procedure TEditorEx.GotoParenMark;
var
  Index, ARow: Integer;
  Paren: Boolean;
begin
  ARow := Row;
  Index := ColToListChar(ARow, Col) + 1;
  Paren := SetParenInfo(ARow, Index);
  if not Paren then
  begin
    Dec(Index);
    Paren := SetParenInfo(ARow, Index);
  end;
  if Paren then
  begin
    if (ARow = FLeftParenInfo.Row) and (Index = FLeftParenInfo.Index) then
    begin
      ARow  := FRightParenInfo.Row;
      Index := FRightParenInfo.Index;
    end
    else
    begin
      if (ARow = FRightParenInfo.Row) and (Index = FRightParenInfo.Index) then
      begin
        ARow  := FLeftParenInfo.Row;
        Index := FLeftParenInfo.Index;
      end;
    end;
    SetSelIndex(ARow, Index - 1);
  end;
end;


// ---------------------------------------------------------
// TEditorExMarks
// ---------------------------------------------------------

function TEditorExMarks.GetIndicated: Boolean;
begin
 Result := FDBSpaceMark.Visible or
           FSpaceMark.Visible   or
           FTabMark.Visible     or
           FFindMark.Visible    or
           FParenMark.Visible   or
           FCurrentLine.Visible or
           FDigitLine.Visible   or
           FImageLine.Visible   or
           FImg0Line.Visible    or
           FImg1Line.Visible    or
           FImg2Line.Visible    or
           FImg3Line.Visible    or
           FImg4Line.Visible    or
           FImg5Line.Visible    or
           FEvenLine.Visible;
end;


procedure TEditorExMarks.SetDBSpaceMark(Value: TEditorMark);
begin
  FDBSpaceMark.Assign(Value);
end;


procedure TEditorExMarks.SetSpaceMark(Value: TEditorMark);
begin
  FSpaceMark.Assign(Value);
end;


procedure TEditorExMarks.SetTabMark(Value: TEditorMark);
begin
  FTabMark.Assign(Value);
end;


procedure TEditorExMarks.SetFindMark(Value: TEditorMark);
begin
  FFindMark.Assign(Value);
end;


procedure TEditorExMarks.SetHit(Value: TFountainColor);
begin
  FHit.Assign(Value);
end;


procedure TEditorExMarks.SetParenMark(Value: TEditorMark);
begin
  FParenMark.Assign(Value);
end;


procedure TEditorExMarks.SetCurrentLine(Value: TEditorMark);
begin
  FCurrentLine.Assign(Value);
end;


procedure TEditorExMarks.SetDigitLine(Value: TEditorMark);
begin
  FDigitLine.Assign(Value);
end;


procedure TEditorExMarks.SetImageLine(Value: TEditorMark);
begin
  FImageLine.Assign(Value);
end;


procedure TEditorExMarks.SetImg0Line(Value: TEditorMark);
begin
  FImg0Line.Assign(Value);
end;


procedure TEditorExMarks.SetImg1Line(Value: TEditorMark);
begin
  FImg1Line.Assign(Value);
end;


procedure TEditorExMarks.SetImg2Line(Value: TEditorMark);
begin
  FImg2Line.Assign(Value);
end;


procedure TEditorExMarks.SetImg3Line(Value: TEditorMark);
begin
  FImg3Line.Assign(Value);
end;


procedure TEditorExMarks.SetImg4Line(Value: TEditorMark);
begin
  FImg4Line.Assign(Value);
end;


procedure TEditorExMarks.SetImg5Line(Value: TEditorMark);
begin
  FImg5Line.Assign(Value);
end;


procedure TEditorExMarks.SetEvenLine(Value: TEditorMark);
begin
  FEvenLine.Assign(Value);
end;


constructor TEditorExMarks.Create;
begin
  FDBSpaceMark     := TEditorMark.Create;
  FSpaceMark       := TEditorMark.Create;
  FTabMark         := TEditorMark.Create;
  FFindMark        := TEditorMark.Create;
  FHit             := TFountainColor.Create;
  FParenMark       := TEditorMark.Create;
  FCurrentLine     := TEditorMark.Create;
  FDigitLine       := TEditorMark.Create;
  FImageLine       := TEditorMark.Create;
  FImg0Line        := TEditorMark.Create;
  FImg1Line        := TEditorMark.Create;
  FImg2Line        := TEditorMark.Create;
  FImg3Line        := TEditorMark.Create;
  FImg4Line        := TEditorMark.Create;
  FImg5Line        := TEditorMark.Create;
  FEvenLine        := TEditorMark.Create;
  FDBSpaceMark.OnChange := ChangedProc;
  FSpaceMark.OnChange   := ChangedProc;
  FTabMark.OnChange     := ChangedProc;
  FFindMark.OnChange    := ChangedProc;
  FHit.OnChange         := ChangedProc;
  FParenMark.OnChange   := ChangedProc;
  FCurrentLine.OnChange := ChangedProc;
  FDigitLine.OnChange   := ChangedProc;
  FImageLine.OnChange   := ChangedProc;
  FImg0Line.OnChange    := ChangedProc;
  FImg1Line.OnChange    := ChangedProc;
  FImg2Line.OnChange    := ChangedProc;
  FImg3Line.OnChange    := ChangedProc;
  FImg4Line.OnChange    := ChangedProc;
  FImg5Line.OnChange    := ChangedProc;
  FEvenLine.OnChange    := ChangedProc;
end;


destructor TEditorExMarks.Destroy;
begin
  FDBSpaceMark.Free;
  FSpaceMark.Free;
  FTabMark.Free;
  FFindMark.Free;
  FHit.Free;
  FParenMark.Free;
  FCurrentLine.Free;
  FDigitLine.Free;
  FImageLine.Free;
  FImg0Line.Free;
  FImg1Line.Free;
  FImg2Line.Free;
  FImg3Line.Free;
  FImg4Line.Free;
  FImg5Line.Free;
  FEvenLine.Free;
  inherited Destroy;
end;


procedure TEditorExMarks.Assign(Source: TPersistent);
begin
  if Source is TEditorExMarks then
  begin
    BeginUpdate;
    try
      FDBSpaceMark.Assign(TEditorExMarks(Source).FDBSpaceMark);
      FSpaceMark.Assign(TEditorExMarks(Source).FSpaceMark);
      FTabMark.Assign(TEditorExMarks(Source).FTabMark);
      FFindMark.Assign(TEditorExMarks(Source).FFindMark);
      FHit.Assign(TEditorExMarks(Source).FHit);
      FParenMark.Assign(TEditorExMarks(Source).FParenMark);
      FCurrentLine.Assign(TEditorExMarks(Source).FCurrentLine);
      FDigitLine.Assign(TEditorExMarks(Source).FDigitLine);
      FImageLine.Assign(TEditorExMarks(Source).FImageLine);
      FImg0Line.Assign(TEditorExMarks(Source).FImg0Line);
      FImg1Line.Assign(TEditorExMarks(Source).FImg1Line);
      FImg2Line.Assign(TEditorExMarks(Source).FImg2Line);
      FImg3Line.Assign(TEditorExMarks(Source).FImg3Line);
      FImg4Line.Assign(TEditorExMarks(Source).FImg4Line);
      FImg5Line.Assign(TEditorExMarks(Source).FImg5Line);
      FEvenLine.Assign(TEditorExMarks(Source).FEvenLine);
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;


// ---------------------------------------------------------
// TAWKStrEx
// ---------------------------------------------------------

procedure TAWKStrEx.SetRegExp(S: String);
begin
  inherited SetRegExp(S);
  if HasLHead or HasLTail then
    FMatchProc := MatchEx
  else
    FMatchProc := MatchStd;
end;

// �����ʒu�ƒ����̎擾
//
// ���K�\���Ƀ}�b�`���镔��������̊J�n�ʒu(1�x�[�X)�ƒ�����List�Ɋi�[����
// �q�b�g����������̒�����0�ƂȂ�ꍇ�̓q�b�g���ĂȂ��悤�ɂ���B
//
function TAWKStrEx.SetSearchInfoList(Line, Text: string; List: TList): Integer;
var
  pStart, pEnd: PChar;
  I, Len:       Integer;
  Info:         PSearchInfo;
begin
  I := 0;
  pStart := nil;
  pEnd   := nil;
  while Text <> '' do
  begin
    FMatchProc(PChar(Text), pStart, pEnd);
    // �}�b�`���Ȃ������Ƃ�
    if pStart = nil then Break;
    if pStart = pEnd then
    begin
       // ����0�̏ꍇ�͎��ɐi�߂�
      if ByteType(Text, 0) = mbLeadByte then
      begin
        Text := Copy(Text, 3, Length(Text));
        Inc(I, 2);
      end
      else
      begin
        Text := Copy(Text, 2, Length(Text));
        Inc(I);
      end;
    end
    else
    begin
      // �}�b�`�����Ƃ�
      New(Info);
      I := I + (pStart - PChar(Text));
      Len := pEnd - pStart;
      Info^.Start := I + 1;
      Info^.Len := Len;
      Info^.Str := Copy(Line, Info^.Start, Info^.Len);
      List.Add(Info);
      I := I + Len;
      Text := String(pEnd);
   end;
    FMatchProc := MatchEX_Inside;
  end;
  Result := List.Count;
end;


constructor TAWKStrEx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;


destructor TAWKStrEx.Destroy;
begin
  inherited Destroy;
end;


// ---------------------------------------------------------
// TVerticalLine
// ---------------------------------------------------------

procedure TVerticalLine.SetPosition(Value: Integer);
begin
  if (FPosition <> Value) and (Value >= 0) then
  begin
    FPrevPosition := FPosition;
    FPosition := Value;
    Changed(False);
  end;
end;


procedure TVerticalLine.SetColor(Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Changed(False);
  end;
end;


procedure TVerticalLine.SetVisible(Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Changed(False);
  end;
end;


constructor TVerticalLine.Create(Collection: TCollection);
begin
  FPosition := 0;
  FColor    := clBlack;
  FVisible  := True;
  inherited Create(Collection);
end;


procedure TVerticalLine.Assign(Source: TPersistent);
begin
  if Source is TVerticalLine then
  begin
    Position := TVerticalLine(Source).Position;
    Color    := TVerticalLine(Source).Color;
    Visible  := TVerticalLine(Source).Visible;
  end
  else inherited Assign(Source);
end;


// ---------------------------------------------------------
// TVerticalLines
// ---------------------------------------------------------

function TVerticalLines.GetItem(Index: Integer): TVerticalLine;
begin
  Result := TVerticalLine(inherited GetItem(Index));
end;


procedure TVerticalLines.SetItem(Index: Integer; Value: TVerticalLine);
begin
  inherited SetItem(Index, Value);
end;


function TVerticalLines.GetOwner: TPersistent;
begin
  Result := FOwner;
end;


procedure TVerticalLines.Update(Item: TCollectionItem);
begin
  if FOwner is TEditorEx then
  begin
    TEditorEx(FOwner).Repaint;
  end;
end;


constructor TVerticalLines.Create(AOwner: TPersistent);
begin
  inherited Create(TVerticalLine);
  FOwner := AOwner;
end;


function TVerticalLines.Add: TVerticalLine;
begin
  Result := TVerticalLine(inherited Add);
end;


procedure TVerticalLines.Show;
var
  I :Integer;
begin
  I := 0;
  BeginUpdate;
  try
    while I < Count do
    begin
      Items[I].Visible := True;
      Inc(I);
    end;
  finally
    EndUpdate;
  end;
end;


procedure TVerticalLines.Hide;
var
  I :Integer;
begin
  I := 0;
  BeginUpdate;
  try
    while I < Count do
    begin
      Items[I].Visible := False;
      Inc(I);
    end;
  finally
    EndUpdate;
  end;
end;


end.

