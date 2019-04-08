(*********************************************************************

  hOledd.pas

  start  2001/12/01
  update 2001/12/13

  Copyright (c) 2001 本田勝彦 <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  OLE Drag & Drop に必要なクラス群が記述されている。

**********************************************************************)

unit hOledd;

{$I heverdef.inc}

interface

uses
  Windows, Classes, ActiveX, ShellApi;

type
  PFormatEtc = ^TFormatEtc;
  TFormatEtcArray = array[0..0] of TFormatEtc;

  TFormatEtcList = class(TList)
  private
    function GetFormat(Index: Integer): TFormatEtc;
    procedure SetFormat(Index: Integer; Value: TFormatEtc);
  public
    destructor Destroy; override;
    function Add(FormatEtc: TFormatEtc): Integer;
    procedure Assign(Source: TFormatEtcList);
    procedure Clear; {$IFDEF TLIST_CLEAR_VIRTUAL} override; {$ENDIF}
    property Formats[Index: Integer]: TFormatEtc read GetFormat write SetFormat;
  end;

  TFormatEtcListObject = class(TInterfacedObject)
  private
    FList: TFormatEtcList;
  public
    constructor Create;
    destructor Destroy; override;
    property FormatList: TFormatEtcList read FList;
  end;

  TEnumFormatEtc = class(TFormatEtcListObject, IEnumFormatEtc)
  protected
    FIndex: Integer;
  public
    // IEnumFormatEtc
    function Next(celt: Longint; out elt; pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out enum: IEnumFormatEtc): HResult; stdcall;
  end;

  TDataObject = class(TFormatEtcListObject, IDataObject)
  protected
    function GetMedium(const FormatEtc: TFormatEtc; var Medium: TStgMedium;
      CreateMedium: Boolean): HResult; virtual; abstract;
  public
    // IDataObject
    function GetData(const formatetcIn: TFormatEtc; out medium: TStgMedium): HResult; stdcall;
    function GetDataHere(const formatetc: TFormatEtc; out medium: TStgMedium): HResult; stdcall;
    function QueryGetData(const formatetc: TFormatEtc): HResult; stdcall;
    function GetCanonicalFormatEtc(const formatetc: TFormatEtc;
      out formatetcOut: TFormatEtc): HResult; stdcall;
    function SetData(const formatetc: TFormatEtc; var medium: TStgMedium;
      fRelease: BOOL): HResult; stdcall;
    function EnumFormatEtc(dwDirection: Longint; out enumFormatEtc:
      IEnumFormatEtc): HResult; stdcall;
    function DAdvise(const formatetc: TFormatEtc; advf: Longint;
      const advSink: IAdviseSink; out dwConnection: Longint): HResult; stdcall;
    function DUnadvise(dwConnection: Longint): HResult; stdcall;
    function EnumDAdvise(out enumAdvise: IEnumStatData): HResult; stdcall;
  end;

  TDropSource = class (TInterfacedObject, IDropSource)
    function QueryContinueDrag(fEscapePressed: BOOL;
      grfKeyState: Longint): HResult; stdcall;
    function GiveFeedback(dwEffect: Longint): HResult; stdcall;
  end;

  TDropTargetEvent = procedure (const DataObj: IDataObject;
    KeyState: Longint; Point: TPoint; var Effect: Longint) of Object;

  TDragLeaveEvent = procedure (const DataObj: IDataObject) of Object;

  TDropTarget = class(TFormatEtcListObject, IDropTarget)
  protected
    FDataObject: IDataObject; // 参照保存用
    FOnDragEnter: TDropTargetEvent;
    FOnDragOver: TDropTargetEvent;
    FOnDragDrop: TDropTargetEvent;
    FOnDragLeave: TDragLeaveEvent;
  protected
    procedure DoDragEnter(const DataObj: IDataObject; KeyState: Longint;
      Point: TPoint; var Effect: Longint); virtual;
    procedure DoDragOver(const DataObj: IDataObject; KeyState: Longint;
      Point: TPoint; var Effect: Longint); virtual;
    procedure DoDragLeave(const DataObj: IDataObject); virtual;
    procedure DoDragDrop(const DataObj: IDataObject; KeyState: Longint;
      Point: TPoint; var Effect: Longint); virtual;
  public
    // IDroopTarget
    function DragEnter(const DataObj: IDataObject; grfKeyState: Longint;
      pt: TPoint; var dwEffect: Longint): HResult; virtual; stdcall;
    function DragOver(grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; virtual; stdcall;
    function DragLeave: HResult; virtual; stdcall;
    function Drop(const DataObj: IDataObject; grfKeyState: Longint;
      pt: TPoint; var dwEffect: Longint): HResult; virtual; stdcall;
    // properties
    property OnDragEnter: TDropTargetEvent read FOnDragEnter write FOnDragEnter;
    property OnDragOver: TDropTargetEvent read FOnDragOver write FOnDragOver;
    property OnDragDrop: TDropTargetEvent read FOnDragDrop write FOnDragDrop;
    property OnDragLeave: TDragLeaveEvent read FOnDragLeave write FOnDragLeave;
  end;


implementation


{ TFormatEtcList }

destructor TFormatEtcList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TFormatEtcList.Add(FormatEtc: TFormatEtc): Integer;
var
  P: PFormatEtc;
begin
  New(P);
  P.cfFormat := FormatEtc.cfFormat;
  P.ptd := FormatEtc.ptd;
  P.dwAspect := FormatEtc.dwAspect;
  P.lindex := FormatEtc.lindex;
  P.tymed := FormatEtc.tymed;
  Result := inherited Add(P);
end;

procedure TFormatEtcList.Assign(Source: TFormatEtcList);
var
  I: Integer;
begin
  Clear;
  if Source <> nil then
    for I := 0 to Source.Count - 1 do
      Add(Source.Formats[I]);
end;

procedure TFormatEtcList.Clear;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Dispose(PFormatEtc(Items[I]));
  inherited Clear;
end;

function TFormatEtcList.GetFormat(Index: Integer): TFormatEtc;
var
  P: PFormatEtc;
begin
  P := PFormatEtc(Items[Index]);
  Result.cfFormat := P.cfFormat;
  Result.ptd := P.ptd;
  Result.dwAspect := P.dwAspect;
  Result.lindex := P.lindex;
  Result.tymed := P.tymed;
end;

procedure TFormatEtcList.SetFormat(Index: Integer; Value: TFormatEtc);
var
  P: PFormatEtc;
begin
  P := PFormatEtc(Items[Index]);
  P.cfFormat := Value.cfFormat;
  P.ptd := Value.ptd;
  P.dwAspect := Value.dwAspect;
  P.lindex := Value.lindex;
  P.tymed := Value.tymed;
end;


{ TFormatEtcListObject }

constructor TFormatEtcListObject.Create;
begin
  inherited Create;
  FList := TFormatEtcList.Create;
end;

destructor TFormatEtcListObject.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;


{ TEnumFormatEtc }

function TEnumFormatEtc.Next(celt: Longint; out elt; pceltFetched: PLongint): HResult; stdcall;
(*
  FormatList が保持している TFormatEtc データを FIndex から celt 個
  elt に格納する。elt は TFormatEtc の配列であることに注意
*)
var
  I: Integer;
begin
  I := 0;
  while (I < celt) and (FIndex <= FormatList.Count - 1) do
  begin
    TFormatEtcArray(elt)[I] := FormatList.Formats[FIndex];
    Inc(FIndex);
    Inc(I);
  end;
  // 取得出来た数を格納する
  if pceltFetched <> nil then
    pceltFetched^ := I;
  if I = celt then
    Result := S_OK
  else
    Result := S_FALSE;
end;

function TEnumFormatEtc.Skip(celt: Longint): HResult; stdcall;
// celt 分インデックスを進める
begin
  if celt <= FormatList.Count - FIndex then
  begin
    FIndex := FIndex + celt;
    Result := S_OK;
  end
  else
  begin
    FIndex := FormatList.Count;
    Result := S_FALSE;
  end;
end;

function TEnumFormatEtc.Reset: HResult; stdcall;
// FIndex を初期化する
begin
  FIndex := 0;
  Result := S_OK;
end;

function TEnumFormatEtc.Clone(out enum: IEnumFormatEtc): HResult; stdcall;
// 複製する
var
  I: Integer;
begin
  enum := TEnumFormatEtc.Create;
  for I := 0 to FormatList.Count - 1 do
    TEnumFormatEtc(enum).FormatList.Add(FormatList.Formats[I]);
  Result := S_OK;
end;


{ TDataObject }

function TDataObject.GetData(const formatetcIn: TFormatEtc; out medium: TStgMedium): HResult; stdcall;
begin
  // init
  Result := DV_E_FORMATETC;
  medium.tymed := 0;
  medium.hGlobal := 0;
  medium.UnkForRelease := nil;
  try
    // confirm & getdata
    if QueryGetData(formatetcIn) = S_OK then
      Result := GetMedium(formatetcIn, medium, True);
  except
    Result := E_UNEXPECTED;
  end;
end;

function TDataObject.GetDataHere(const formatetc: TFormatEtc; out medium: TStgMedium): HResult; stdcall;
begin
  Result := DV_E_FORMATETC;
  try
    // confirm & getdata
    if QueryGetData(formatetc) = S_OK then
      Result := GetMedium(formatetc, medium, False);
  except
    Result := E_UNEXPECTED;
  end;
end;

function TDataObject.QueryGetData(const formatetc: TFormatEtc): HResult; stdcall;
var
  I: Integer;
begin
  Result := DV_E_FORMATETC;
  for I := 0 to FormatList.Count - 1 do
    if (formatetc.cfFormat = FormatList.Formats[I].cfFormat) and
       (formatetc.dwAspect = FormatList.Formats[I].dwAspect) and
       (formatetc.tymed and FormatList.Formats[I].tymed <> 0) then
    begin
      Result := NOERROR;
      Break;
    end;
end;

function TDataObject.GetCanonicalFormatEtc(const formatetc: TFormatEtc;
  out formatetcOut: TFormatEtc): HResult; stdcall;
begin
  formatetcOut := formatetc;
  formatetcOut.ptd := nil;
  Result := DATA_S_SAMEFORMATETC;
end;

function TDataObject.SetData(const formatetc: TFormatEtc; var medium: TStgMedium;
  fRelease: BOOL): HResult; stdcall;
begin
  Result := E_NOTIMPL; // not support
end;

function TDataObject.EnumFormatEtc(dwDirection: Longint; out enumFormatEtc:
  IEnumFormatEtc): HResult; stdcall;
(*
  enumFormatEtc に IEnumFormatEtc の実装への参照を格納する。
  IEnumFormatEtc は FormatList を知らないので、一旦 TEnumFormatEtc 型の
  変数に TEnumFormatEtc のインスタンスを格納し、FormatList を更新した後
  で enumFormatEtc に代入する。

  enumFormatEtc := TEnumFormatEtc.Create;
  TEnumFormatEtc(enumFormatEtc).FormatList.Assign(FormatList);

  とキャストで楽出来そうだが、コンパイラは騙せても、アクセス違反が発生
  する。
*)
var
  Etc: TEnumFormatEtc;
begin
  Result := E_NOTIMPL;
  enumFormatEtc := nil;
  if dwDirection = DATADIR_GET then
  begin
    Etc := TEnumFormatEtc.Create;
    Etc.FormatList.Assign(FormatList);
    enumFormatEtc := Etc;
    Result := S_OK;
  end
end;

function TDataObject.DAdvise(const formatetc: TFormatEtc; advf: Longint;
  const advSink: IAdviseSink; out dwConnection: Longint): HResult; stdcall;
begin
  Result := OLE_E_ADVISENOTSUPPORTED; // not support
end;

function TDataObject.DUnadvise(dwConnection: Longint): HResult; stdcall;
begin
  Result := OLE_E_ADVISENOTSUPPORTED; // not support
end;

function TDataObject.EnumDAdvise(out enumAdvise: IEnumStatData): HResult;
  stdcall;
begin
  Result := OLE_E_ADVISENOTSUPPORTED; // not support
end;


{ TDropSource }

function TDropSource.QueryContinueDrag(fEscapePressed: BOOL;
  grfKeyState: Longint): HResult; stdcall;
begin
  if fEscapePressed or (grfKeyState and MK_RBUTTON = MK_RBUTTON) then
    // エスケープキーが押されたか、マウスの右ボタンが押された
    Result := DRAGDROP_S_CANCEL
  else
    if grfKeyState and MK_LBUTTON = 0 then
      // マウスの左ボタンが離されている
      Result := DRAGDROP_S_DROP
    else
      Result := S_OK;
end;

function TDropSource.GiveFeedback(dwEffect: Longint): HResult; stdcall;
begin
  Result := DRAGDROP_S_USEDEFAULTCURSORS;
end;


{ TDropTarget }

procedure TDropTarget.DoDragEnter(const DataObj: IDataObject;
  KeyState: Longint; Point: TPoint; var Effect: Longint);
begin
  if Assigned(FOnDragEnter) then
    FOnDragEnter(DataObj, KeyState, Point, Effect);
end;

procedure TDropTarget.DoDragOver(const DataObj: IDataObject;
  KeyState: Longint; Point: TPoint; var Effect: Longint);
begin
  if Assigned(FOnDragOver) then
    FOnDragOver(DataObj, KeyState, Point, Effect);
end;

procedure TDropTarget.DoDragLeave(const DataObj: IDataObject);
begin
  if Assigned(FOnDragLeave) then
    FOnDragLeave(DataObj);
end;

procedure TDropTarget.DoDragDrop(const DataObj: IDataObject;
  KeyState: Longint; Point: TPoint; var Effect: Longint);
begin
  if Assigned(FOnDragDrop) then
    FOnDragDrop(DataObj, KeyState, Point, Effect);
end;

function TDropTarget.DragEnter(const DataObj: IDataObject;
  grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
var
  I: Integer;
begin
  // FormatList に登録された形式の IDataObject かどうかを判別して
  // FOnDragEnter イベントハンドラを呼び出す。
  FDataObject := nil;
  for I := 0 to FormatList.Count - 1 do
    if DataObj.QueryGetData(FormatList.Formats[I]) = S_OK then
    begin
      FDataObject := DataObj;
      Break;
    end;
  if FDataObject = nil then
    dwEffect := DROPEFFECT_NONE
  else
  begin
    dwEffect := DROPEFFECT_COPY;
    DoDragEnter(FDataObject, grfKeyState, pt, dwEffect);
  end;
  Result := S_OK;
end;

function TDropTarget.DragOver(grfKeyState: Longint; pt: TPoint;
  var dwEffect: Longint): HResult; stdcall;
begin
  // DragEnter で有効な IDataObject を取得している場合だけ処理を行う。
  if FDataObject = nil then
    dwEffect := DROPEFFECT_NONE
  else
  begin
    dwEffect := DROPEFFECT_COPY;
    DoDragOver(FDataObject, grfKeyState, pt, dwEffect);
  end;
  Result := S_OK;
end;

function TDropTarget.DragLeave: HResult; stdcall;
begin
  if FDataObject <> nil then
    DoDragLeave(FDataObject);
  // 取得した IDragObject への参照を破棄する。
  FDataObject := nil;
  Result := S_OK;
end;

function TDropTarget.Drop(const DataObj: IDataObject;
  grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
begin
  // DragEnter で有効な IDataObject を取得している場合だけ処理を行う。
  if FDataObject = nil then
    dwEffect := DROPEFFECT_NONE
  else
  begin
    dwEffect := DROPEFFECT_COPY;
    DoDragDrop(FDataObject, grfKeyState, pt, dwEffect);
  end;
  // 取得した IDragObject への参照を破棄する。
  FDataObject := nil;
  Result := S_OK;
end;


initialization
  OleInitialize(nil);
finalization
  OleUninitialize;
end.
