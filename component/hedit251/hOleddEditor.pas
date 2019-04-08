(*********************************************************************

  TOleddEditor ver 1.40

  start  2001/12/08
  update 2003/10/03

  Copyright (c) 2001-2003 �{�c���F <katsuhiko.honda@nifty.ne.jp>
  --------------------------------------------------------------------

  OLE Drag & Drop ���������ꂽ�ATEditor �̊g���R���|�[�l���g�B
  Delphi 4 �ȍ~�ŃR���p�C�����ĉ������B

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
  // OLE Drag&Drop �󂯓���I�u�W�F�N�g���쐬
  FDropTarget := TEventsDropTarget.Create;
  // CF_HDROP �ɑΉ�
  FDropTarget.FormatList.Add(FilesFormatEtc);
  // CF_TEXTP �ɑΉ�
  FDropTarget.FormatList.Add(TextFormatEtc);
  // ���g�� IDropTargetEvents �̎����Ƃ��đ������
  FDropTarget.Events := Self; // �� Delphi 3 �ł͂����ŃG���[�ɂȂ�܂��B
  // Windows �ɓo�^
  RegisterDragDrop(Handle, FDropTarget);
end;

procedure TOleddEditor.CleanupOledd;
begin
  // �o�^����
  RevokeDragDrop(Handle);
  // �Q�Ƃ�j�����邱�Ƃ� TDropTarget �I�u�W�F�N�g��j������B
  FDropTarget := nil;
end;

procedure TOleddEditor.RestoreRowCol;
begin
  // �L�����b�g�ʒu�𕜊�������
  SetRowCol(FStoreRow, FStoreCol);
end;

procedure TOleddEditor.StoreRowCol;
begin
  // �L�����b�g�ʒu��ۑ�����
  FStoreRow := Row;
  FStoreCol := Col;
end;

procedure TOleddEditor.PointToCaret(Point: TPoint);
var
  R, C: Integer;
begin
  // �L�����b�g���ړ�����
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
    �e�L�X�g�f�[�^�̃h���b�v�����B���L�����ɂ���ď����𕪊򂳂���
    �E�I��̈���ւ̃h���b�v���ǂ���
    �E���g�ɂ��f�[�^���ǂ���
    �E�R���g���[���L�[��������Ă��邩�ǂ���
  *)
  // FCaretUndo ���X�V
  FCaretUndo := False;
  // ������f�[�^���擾
  Buffer := StrPas(PChar(GlobalLock(Drop)));
  GlobalUnlock(Drop);
  // �h���b�v���ꂽ Row, Col ���擾
  Point := ScreenToClient(Point);
  PosToRowCol(Point.X, Point.Y, R, C, True);
  // ���ʂƂ��ꂼ��̏���
  if IsSelectedArea(R, C) then
  begin
    // �I��̈���ւ̃h���b�v
    // �I����Ԃ��������đ��l�̃f�[�^�ł���Α}������
    // ���g�̃f�[�^�̏ꍇ�͉��������ɏI��
    CleanSelection;
    if not SelfData then
      SelText := Buffer;
  end
  else
    // �I��̈�O�ւ̃h���b�v
    if SelfData then
      // �����̃f�[�^
      if ControlKey then
      begin
        // �R���g���[���L�[��������Ă���
        CleanSelection;
        SelText := Buffer;
      end
      else
      begin
        // �R���g���[���L�[��������Ă��Ȃ�
        // �Y���ʒu�փL�����b�g���ړ����Ă�����ۂ� Row, Col �ʒu��
        // MoveSelection ����B
        SetRowCol(R, C);
        MoveSelection(Row, Col);
      end
    else
    begin
      // ���l�̃f�[�^
      CleanSelection;
      SelText := Buffer;
    end;
end;

procedure TOleddEditor.WMLButtonDown(var Message: TWMLButtonDown);
begin
  // inherited �ɂ���ăL�����b�g���I��̈�̒��Ɉړ����Ă��܂��̂ŁA
  // ���������ɕۑ����Ă���
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
  // �{�^�������ŁACaret.SelDragMode �� dmManual �ɐݒ肳��Ă��āA
  // ���݂̃L�����b�g�ʒu���I��̈���ɂ���ꍇ������������B
  if (Button = mbLeft) and (Caret.SelDragMode = dmManual) and CanSelDrag and
     (LeftMargin <= X) and IsSelectedArea(Row, Col) then
  begin
    // �}�E�X�L���v�`�����������
    SendMessage(Handle, WM_LBUTTONUP, 0, 0);
    // SelText ��ێ������邽�߁A��U TTextDataObject �^�I�u�W�F�N�g��
    // �������A�f�[�^���Z�b�g������� IDataObject �^�ϐ��ɑ������B
    TextDataObject := TTextDataObject.Create;
    TextDataObject.Text := SelText;
    DataObject := TextDataObject;
    DropSource := TDropSource.Create;
    // ���g�̃f�[�^���ǂ����𔻕ʂ��鏈���p�ɎQ�Ƃ�ێ�����B
    FSourceObject := DataObject;
    // �L�����b�g�����ɖ߂����߂̃f�[�^���擾
    FCaretUndo := True;
    try
      // Ole Drag �̊J�n
      DoDragDrop(DataObject, DropSource, DROPEFFECT_COPY or DROPEFFECT_MOVE, Effect);
    finally
      DropSource := nil;
      DataObject := nil;
      FSourceObject := nil;
    end;
    // �{���Ȃ炱���� Effect �𔻕ʂ��đI��̈�̃N���A�A���͍폜���s�����A
    // DropText ���\�b�h�Ɏ�������Ă���B
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
    FDropTarget ���m���Ă���t�H�[�}�b�g�ɂ���� DataObj ����f�[�^��
    �擾�ł����ꍇ�ɂ�����������B
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
  // �I��̈�ƃh���b�O�ɂ��L�����b�g�̈ړ��ɂ��A�I��̈��
  // �L�����b�g�ʒu�̕s������������邽�߁A�L�����b�g�ʒu��ێ�����B
  // �����ō쐬���� DataObj �̏ꍇ�� WM_LBUTTONDOWN ���b�Z�[�W�n���h����
  // �擾�ς�
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
  // �L�����b�g�̈ړ�
  // SetFocus; // fsMDIChile �t�H�[����ł͋@�\���Ȃ��ꍇ������B
  Windows.SetFocus(Handle);
  PointToCaret(ScreenToClient(Point));
  // Effect �̍X�V
  if FSourceObject = DataObj then
    // ���g�ɂ���č쐬���ꂽ�f�[�^�̏ꍇ�̏���
    if KeyState and MK_CONTROL <> 0 then
      // �R���g���[���L�[��������Ă���
      Effect := DROPEFFECT_COPY
    else
      // �R���g���[���L�[��������Ă��Ȃ�
      Effect := DROPEFFECT_MOVE
  else
    // ���l�ɂ��f�[�^
    Effect := DROPEFFECT_COPY;
end;

end.
