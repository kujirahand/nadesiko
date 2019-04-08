(*********************************************************************

  hOleddUtils.pas

  start  2001/12/02
  update 2001/12/13

  Copyright (c) 2001 本田勝彦 <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  TTextDataObject クラス
  IDropTargetEvents インターフェース

**********************************************************************)

unit hOleddUtils;

interface

uses
  Windows, SysUtils, Classes, ActiveX, ShellApi, hOledd;

const
  FilesFormatEtc: TFormatEtc = (
    cfFormat: CF_HDROP;
    ptd: nil;
    dwAspect: DVASPECT_CONTENT;
    lindex: -1;
    tymed : TYMED_HGLOBAL;
  );

  TextFormatEtc: TFormatEtc = (
    cfFormat: CF_TEXT;
    ptd: nil;
    dwAspect: DVASPECT_CONTENT;
    lindex: -1;
    tymed: TYMED_HGLOBAL;
  );

type
  TTextDataObject = class(TDataObject)
  private
    FText: String;
  protected
    function GetMedium(const FormatEtc: TFormatEtc; var Medium: TStgMedium;
      CreateMedium: Boolean): HResult; override;
  public
    constructor Create;
    property Text: String read FText write FText;
  end;

  IDropTargetEvents = interface
    procedure TargetEnter(const DataObj: IDataObject; KeyState: Longint;
      Point: TPoint; var Effect: Longint);
    procedure TargetOver(const DataObj: IDataObject; KeyState: Longint;
      Point: TPoint; var Effect: Longint);
    procedure TargetDrop(const DataObj: IDataObject; KeyState: Longint;
      Point: TPoint; var Effect: Longint);
    procedure TargetLeave(const DataObj: IDataObject);
  end;

  TEventsDropTarget = class(TDropTarget)
  public
    Events: IDropTargetEvents;
    // override
    procedure DoDragEnter(const DataObj: IDataObject; KeyState: Longint;
      Point: TPoint; var Effect: Longint); override;
    procedure DoDragOver(const DataObj: IDataObject; KeyState: Longint;
      Point: TPoint; var Effect: Longint); override;
    procedure DoDragLeave(const DataObj: IDataObject); override;
    procedure DoDragDrop(const DataObj: IDataObject; KeyState: Longint;
      Point: TPoint; var Effect: Longint); override;
    destructor Destroy; override;
  end;

procedure HandleToFileNames(Handle: THandle; Strings: TStrings);

implementation


{ TTextDataObject }

constructor TTextDataObject.Create;
begin
  inherited Create; // TFormatEtcList.Create
  // 生まれながらにして TextFormatEtc を知っている仕様とする
  FormatList.Add(TextFormatEtc);
end;

function TTextDataObject.GetMedium(const FormatEtc: TFormatEtc; var Medium: TStgMedium;
  CreateMedium: Boolean): HResult;
var
  hMem: HGLOBAL;
  Buffer: PChar;
begin
  if not CreateMedium then
  begin
    Result := E_NOTIMPL;
    Exit;
  end;
  // get
  hMem := GlobalAlloc(GHND, Length(FText) + 1);
  if hMem <> 0 then
  begin
    Buffer := GlobalLock(hMem);
    StrCopy(Buffer, PChar(FText));
    GlobalUnlock(hMem);
    // copy
    Medium.hGlobal := hMem;
    Medium.tymed   := FormatEtc.tymed;
    Result := S_OK
  end
  else
    Result := STG_E_MEDIUMFULL;
end;

procedure HandleToFileNames(Handle: THandle; Strings: TStrings);
var
  I, J, K: Integer;
  Buffer: PChar;
begin
  Strings.Clear;
  Buffer := nil;
  I := DragQueryFile(Handle, $FFFFFFFF, Buffer, 0);
  if I > 0 then
    for J := 0 to I - 1 do
    begin
      K := DragQueryFile(Handle, J, Buffer, 0);
      Buffer := StrAlloc(K + 1);
      DragQueryFile(Handle, J, Buffer, K + 1);
      Strings.Add(StrPas(Buffer));
      StrDispose(Buffer);
    end;
end;


{ TEventsDropTarget }

(*
  IDropTargetEvents 型フィールドデータ Events を持っている。
  Events に IDropTargetEvents の実装が代入されている場合、
  IDropTargetEvents のメソッドを呼び出す仕様。
  本来のイベントハンドラ FOnDropxxxx は呼び出さない。
*)

destructor TEventsDropTarget.Destroy;
begin
  Events := nil;
  inherited Destroy;
end;

procedure TEventsDropTarget.DoDragEnter(const DataObj: IDataObject;
  KeyState: Longint; Point: TPoint; var Effect: Longint);
begin
  if Assigned(Events) then
    Events.TargetEnter(DataObj, KeyState, Point, Effect);
end;

procedure TEventsDropTarget.DoDragOver(const DataObj: IDataObject;
  KeyState: Longint; Point: TPoint; var Effect: Longint);
begin
  if Assigned(Events) then
    Events.TargetOver(DataObj, KeyState, Point, Effect);
end;

procedure TEventsDropTarget.DoDragLeave(const DataObj: IDataObject);
begin
  if Assigned(Events) then
    Events.TargetLeave(DataObj);
end;

procedure TEventsDropTarget.DoDragDrop(const DataObj: IDataObject;
  KeyState: Longint; Point: TPoint; var Effect: Longint);
begin
  if Assigned(Events) then
    Events.TargetDrop(DataObj, KeyState, Point, Effect);
end;


initialization
  OleInitialize(nil);
finalization
  OleUninitialize;
end.
