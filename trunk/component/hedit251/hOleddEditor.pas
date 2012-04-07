(*********************************************************************

  TOleddEditor ver 1.40

  start  2001/12/08
  update 2003/10/03

  Copyright (c) 2001-2003 本田勝彦 <katsuhiko.honda@nifty.ne.jp>
  --------------------------------------------------------------------

  OLE Drag & Drop が実装された、TEditor の拡張コンポーネント。
  Delphi 4 以降でコンパイルして下さい。

**********************************************************************)

unit hOleddEditor;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls,
  HEditor,
  ActiveX,     // IDataObject, IDropSource, RegisterDragDrop, RevokeDragDrop,
               // DoDragDrop, DROPEFFECT_xxxx
  ShellApi,    // HDROP
  hOledd,      // TDropTarget
  hOleddUtils; // TTextDataObject, FilesFormatEtc, TextFormatEtc, HandleToFilenames

type
  TDropFilesEvent = procedure (Sender: TObject; Drop, KeyState: Longint;
      Point: TPoint) of Object;

  TOleddEditor = class(TEditor, IDropTargetEvents)
  private
    FOnDropFiles: TDropFilesEvent;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMCreate(var Message: TWMCreate); message WM_CREATE;
    procedure WMDestroy(var Message: TWMDestroy); message WM_DESTROY;
  protected
    FCaretUndo: Boolean;
    FDropTarget: TEventsDropTarget;
    FSourceObject: IDataObject;
    FStoreCol: Integer;
    FStoreRow: Integer;
    procedure CleanupOledd; virtual;
    procedure DoDropFiles(Drop: HDrop; KeyState: Longint; Point: TPoint); virtual;
    procedure DropText(Drop: HGLOBAL; SelfData, ControlKey: Boolean; Point: TPoint); virtual;
    procedure InitOledd; virtual;
    procedure PointToCaret(Point: TPoint); virtual;
    procedure RestoreRowCol; virtual;
    procedure StoreRowCol; virtual;
    // override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  public
    // IDropTargetEvents
    procedure TargetDrop(const DataObj: IDataObject; KeyState: Longint;
      Point: TPoint; var Effect: Longint); virtual;
    procedure TargetEnter(const DataObj: IDataObject; KeyState: Longint;
      Point: TPoint; var Effect: Longint); virtual;
    procedure TargetLeave(const DataObj: IDataObject); virtual;
    procedure TargetOver(const DataObj: IDataObject; KeyState: Longint;
      Point: TPoint; var Effect: Longint); virtual;
  published
    property OnDropFiles: TDropFilesEvent read FOnDropFiles write FOnDropFiles;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TEditor', [TOleddEditor]);
end;

procedure TOleddEditor.WMCreate(var Message: TWMCreate);
begin
  inherited;
  if not (csDesigning in ComponentState) then
    InitOledd;
end;

procedure TOleddEditor.WMDestroy(var Message: TWMDestroy);
begin
  if not (csDesigning in ComponentState) then
    CleanupOledd;
  inherited;
end;

procedure TOleddEditor.InitOledd;
begin
  // OLE Drag&Drop 受け入れオブジェクトを作成
  FDropTarget := TEventsDropTarget.Create;
  // CF_HDROP に対応
  FDropTarget.FormatList.Add(FilesFormatEtc);
  // CF_TEXTP に対応
  FDropTarget.FormatList.Add(TextFormatEtc);
  // 自身を IDropTargetEvents の実装として代入する
  FDropTarget.Events := Self; // ※ Delphi 3 ではここでエラーになります。
  // Windows に登録
  RegisterDragDrop(Handle, FDropTarget);
end;

procedure TOleddEditor.CleanupOledd;
begin
  // 登録解除
  RevokeDragDrop(Handle);
  // 参照を破棄することで TDropTarget オブジェクトを破棄する。
  FDropTarget := nil;
end;

procedure TOleddEditor.RestoreRowCol;
begin
  // キャレット位置を復活させる
  SetRowCol(FStoreRow, FStoreCol);
end;

procedure TOleddEditor.StoreRowCol;
begin
  // キャレット位置を保存する
  FStoreRow := Row;
  FStoreCol := Col;
end;

procedure TOleddEditor.PointToCaret(Point: TPoint);
var
  R, C: Integer;
begin
  // キャレットを移動する
  PosToRowCol(Point.X, Point.Y, R, C, True);
  SetRowCol(R, C);
end;

procedure TOleddEditor.DoDropFiles(Drop: HDrop; KeyState: Longint;
  Point: TPoint);
begin
  if Assigned(FOnDropFiles) then
    FOnDropFiles(Self, Drop, KeyState, ScreenToClient(Point));
end;

procedure TOleddEditor.DropText(Drop: HGLOBAL; SelfData,
  ControlKey: Boolean; Point: TPoint);
var
  R, C: Integer;
  Buffer: String;
begin
  (*
    テキストデータのドロップ処理。下記条件によって処理を分岐させる
    ・選択領域内へのドロップかどうか
    ・自身によるデータかどうか
    ・コントロールキーが押されているかどうか
  *)
  // FCaretUndo を更新
  FCaretUndo := False;
  // 文字列データを取得
  Buffer := StrPas(PChar(GlobalLock(Drop)));
  GlobalUnlock(Drop);
  // ドロップされた Row, Col を取得
  Point := ScreenToClient(Point);
  PosToRowCol(Point.X, Point.Y, R, C, True);
  // 判別とそれぞれの処理
  if IsSelectedArea(R, C) then
  begin
    // 選択領域内へのドロップ
    // 選択状態を解除して他人のデータであれば挿入する
    // 自身のデータの場合は何もせずに終了
    CleanSelection;
    if not SelfData then
      SelText := Buffer;
  end
  else
    // 選択領域外へのドロップ
    if SelfData then
      // 自分のデータ
      if ControlKey then
      begin
        // コントロールキーが押されている
        CleanSelection;
        SelText := Buffer;
      end
      else
      begin
        // コントロールキーが押されていない
        // 該当位置へキャレットを移動してから実際の Row, Col 位置へ
        // MoveSelection する。
        SetRowCol(R, C);
        MoveSelection(Row, Col);
      end
    else
    begin
      // 他人のデータ
      CleanSelection;
      SelText := Buffer;
    end;
end;

procedure TOleddEditor.WMLButtonDown(var Message: TWMLButtonDown);
begin
  // inherited によってキャレットが選択領域の中に移動してしまうので、
  // それよりも先に保存しておく
  StoreRowCol;
  inherited;
end;

procedure TOleddEditor.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  TextDataObject: TTextDataObject;
  DataObject: IDataObject;
  DropSource: IDropSource;
  Effect: Longint;
begin
  inherited MouseDown(Button, Shift, X, Y);
  // ボタンが左で、Caret.SelDragMode が dmManual に設定されていて、
  // 現在のキャレット位置が選択領域内にある場合だけ処理する。
  if (Button = mbLeft) and (Caret.SelDragMode = dmManual) and CanSelDrag and
     (LeftMargin <= X) and IsSelectedArea(Row, Col) then
  begin
    // マウスキャプチャを解放する
    SendMessage(Handle, WM_LBUTTONUP, 0, 0);
    // SelText を保持させるため、一旦 TTextDataObject 型オブジェクトを
    // 生成し、データをセットした後で IDataObject 型変数に代入する。
    TextDataObject := TTextDataObject.Create;
    TextDataObject.Text := SelText;
    DataObject := TextDataObject;
    DropSource := TDropSource.Create;
    // 自身のデータかどうかを判別する処理用に参照を保持する。
    FSourceObject := DataObject;
    // キャレットを元に戻すためのデータを取得
    FCaretUndo := True;
    try
      // Ole Drag の開始
      DoDragDrop(DataObject, DropSource, DROPEFFECT_COPY or DROPEFFECT_MOVE, Effect);
    finally
      DropSource := nil;
      DataObject := nil;
      FSourceObject := nil;
    end;
    // 本来ならここで Effect を判別して選択領域のクリア、又は削除を行うが、
    // DropText メソッドに実装されている。
    if FCaretUndo then
      RestoreRowCol;
  end;
end;


// IDropTargetEvents ////////////////////////////////////////////////

procedure TOleddEditor.TargetDrop(const DataObj: IDataObject; KeyState: Longint;
  Point: TPoint; var Effect: Longint);
var
  I: Integer;
  Medium: TStgMedium;
begin
  (*
    FDropTarget が知っているフォーマットによって DataObj からデータを
    取得できた場合にだけ処理する。
  *)
  for I := 0 to FDropTarget.FormatList.Count - 1 do
    if DataObj.GetData(FDropTarget.FormatList.Formats[I], Medium) = S_OK then
    begin
      try
        case FDropTarget.FormatList.Formats[I].cfFormat of
          CF_HDROP:
            DoDropFiles(Medium.hGlobal, KeyState, Point);
          CF_TEXT:
            DropText(Medium.hGlobal, FSourceObject = DataObj,
              KeyState and MK_CONTROL <> 0, Point);
        end;
      finally
        ReleaseStgMedium(Medium);
      end;
      Break;
    end;
end;

procedure TOleddEditor.TargetEnter(const DataObj: IDataObject; KeyState: Longint;
  Point: TPoint; var Effect: Longint);
begin
  // 選択領域とドラッグによるキャレットの移動による、選択領域と
  // キャレット位置の不整合を回避するため、キャレット位置を保持する。
  // 自分で作成した DataObj の場合は WM_LBUTTONDOWN メッセージハンドラで
  // 取得済み
  if FSourceObject <> DataObj then
    StoreRowCol;
  TargetOver(DataObj, KeyState, Point, Effect);
end;

procedure TOleddEditor.TargetLeave(const DataObj: IDataObject);
begin
  RestoreRowCol;
  SendMessage(Handle, WM_KILLFOCUS, 0, 0);
end;

procedure TOleddEditor.TargetOver(const DataObj: IDataObject; KeyState: Longint;
  Point: TPoint; var Effect: Longint);
begin
  // キャレットの移動
  // SetFocus; // fsMDIChile フォーム上では機能しない場合がある。
  Windows.SetFocus(Handle);
  PointToCaret(ScreenToClient(Point));
  // Effect の更新
  if FSourceObject = DataObj then
    // 自身によって作成されたデータの場合の処理
    if KeyState and MK_CONTROL <> 0 then
      // コントロールキーが押されている
      Effect := DROPEFFECT_COPY
    else
      // コントロールキーが押されていない
      Effect := DROPEFFECT_MOVE
  else
    // 他人によるデータ
    Effect := DROPEFFECT_COPY;
end;

end.
