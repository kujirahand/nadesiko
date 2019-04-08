(*********************************************************************

  heClasses.pas

  start  2000/12/24
  update 2001/07/29

  Copyright (c) 2000,2001 �{�c���F <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------

**********************************************************************)

unit heClasses;

{$I heverdef.inc}

interface

uses
  SysUtils, Classes;

type
  TCharSet = set of Char;

  TStoreComponent = class(TComponent)
  public
    procedure ReadIni(const IniFileName, Section, Ident: String);
    procedure WriteIni(const IniFileName, Section, Ident: String);
    procedure ReadReg(const Root, Section, Ident: String);
    procedure WriteReg(const Root, Section, Ident: String);
  end;

  TFileExtComponent = class(TStoreComponent)
  private
    FFileExtList: TStringList;
  protected
    function CreateSortedList: TStringList; virtual;
    procedure InitFileExtList; virtual;
    procedure SetFileExtList(Value: TStringList); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function HasExt(const FileExt: String): Boolean; virtual;
  published
    property FileExtList: TStringList read FFileExtList write SetFileExtList;
  end;

  TNotifyPersistent = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
  protected
    FUpdateCount: Integer;
    procedure Changed; virtual;
  public
    procedure BeginUpdate; virtual;
    procedure EndUpdate; virtual;
    procedure ChangedProc(Sender: TObject); virtual;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TNotifyCollection = class(TCollection)
  private
    FOnChange: TNotifyEvent;
  protected
    FOwner: TPersistent;
    function GetOwner: TPersistent; {$IFDEF COMP3_UP} override; {$ENDIF}
    procedure Update(Item: TCollectionItem); override;
  public
    procedure ChangedProc(Sender: TObject); virtual;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  PMethod = ^TMethod;
  TMethodList = class(TList)
  public
    destructor Destroy; override;
    procedure Clear; {$IFDEF TLIST_CLEAR_VIRTUAL} override; {$ENDIF}
    procedure Add(Method: TMethod); virtual;
    procedure Remove(Method: TMethod); virtual;
  end;

  TNotifyEventList = class(TNotifyPersistent)
  private
    FList: TMethodList;
  protected
    FOwner: TPersistent;
    function GetOwner: TPersistent; {$IFDEF COMP3_UP} override; {$ENDIF}
    procedure Changed; override;
  public
    constructor Create(AOwner: TPersistent);
    destructor Destroy; override;
    procedure Add(Event: TNotifyEvent); virtual;
    procedure Remove(Event: TNotifyEvent); virtual;
  end;


implementation

uses
  HStreamUtils;


{  TStoreComponent }

(*
  ReadIni, WriteIni, ReadReg, WriteReg ���\�b�h�ŃR�����g�A�E�g����Ă���
  StreamToComponent, ComponentToStream �葱���� HStreamUtils.pas �ɋL�q
  ����Ă���B

  StreamToComponent, ComponentToStream �葱���ł́A�C�x���g�n���h���̐ݒ�
  ��A�E�B���h�D�n���h�����Đ�������K�v������ ScrollBars �v���p�e�B�Ȃ�
  ��ۑ��E���A���邽�߂ɁA�����œn���ꂽ�R���|�[�l���g����U�j�����A�X�g
  ���[���f�[�^���琶�������R���|�[�l���g���Y���R���|�[�l���g�� Owner ��
  ����āu����ւ��v�Ă��炤�Ƃ�������������Ă���B

  TFountain �Ȃǂ̑��̃R���|�[�l���g�ɐڑ����ė��p����R���|�[�l���g�ł́A
  Notification �̎d�g�݂𗘗p���Ă���̂ŁA�j�����ꂽ���_�Őڑ����ؒf��
  ��Ă��܂��B

  �ȉ��̃��\�b�h�ł́A�j������邱�Ƃ̂Ȃ��X�g���[���f�[�^����̍X�V��
  �������Ă���� TStream.WriteComponent, ReadComponent ���\�b�h�𗘗p
  ���邱�Ƃɂ���B

  TStoreComponent �̔h���N���X�ŁA�C�x���g�n���h���̐ݒ���ۑ��E���A����
  �K�v���������Ƃ��́AStreamToComponent, ComponentToStream �葱���𗘗p
  ���邱�ƁB
*)

procedure TStoreComponent.ReadIni(const IniFileName, Section, Ident: String);
var
  Ms: TMemoryStream;
begin
  Ms := TMemoryStream.Create;
  try
    IniReadStream(Ms, IniFileName, Section, Ident);
    if Ms.Size > 0 then
    begin
      Ms.Position := 0;
      // StreamToComponent(Ms, Self);
      Ms.ReadComponent(Self);
    end;
  finally
    Ms.Free;
  end;
end;

procedure TStoreComponent.WriteIni(const IniFileName, Section, Ident: String);
var
  Ms: TMemoryStream;
begin
  Ms := TMemoryStream.Create;
  try
    // ComponentToStream(Self, Ms);
    Ms.WriteComponent(Self);
    Ms.Position := 0;
    IniWriteStream(Ms, IniFileName, Section, Ident);
  finally
    Ms.Free;
  end;
end;

procedure TStoreComponent.ReadReg(const Root, Section, Ident: String);
var
  Ms: TMemoryStream;
begin
  Ms := TMemoryStream.Create;
  try
    RegReadStream(Ms, Root, Section, Ident);
    if Ms.Size > 0 then
    begin
      Ms.Position := 0;
      // StreamToComponent(Ms, Self);
      Ms.ReadComponent(Self);
    end;
  finally
    Ms.Free;
  end;
end;

procedure TStoreComponent.WriteReg(const Root, Section, Ident: String);
var
  Ms: TMemoryStream;
begin
  Ms := TMemoryStream.Create;
  try
    // ComponentToStream(Self, Ms);
    Ms.WriteComponent(Self);
    Ms.Position := 0;
    RegWriteStream(Ms, Root, Section, Ident);
  finally
    Ms.Free;
  end;
end;


{ TFileExtComponent }

constructor TFileExtComponent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFileExtList := CreateSortedList;
  InitFileExtList;
end;

destructor TFileExtComponent.Destroy;
begin
  FFileExtList.Free;
  inherited Destroy;
end;

function TFileExtComponent.CreateSortedList: TStringList;
begin
  Result := TStringList.Create;
  Result.Sorted := True;
  Result.Duplicates := dupIgnore;
end;

procedure TFileExtComponent.SetFileExtList(Value: TStringList);
begin
  FFileExtList.Assign(Value);
end;

procedure TFileExtComponent.InitFileExtList;
begin
end;

function TFileExtComponent.HasExt(const FileExt: String): Boolean;
var
  I: Integer;
begin
  Result := FFileExtList.Find(FileExt, I);
end;


{ TNotifyPersistent }

procedure TNotifyPersistent.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TNotifyPersistent.EndUpdate;
begin
  Dec(FUpdateCount);
  Changed;
end;

procedure TNotifyPersistent.Changed;
begin
  if (FUpdateCount = 0) and Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNotifyPersistent.ChangedProc(Sender: TObject);
begin
  if Sender <> Self then
    Changed;
end;


{ TNotifyCollection }

function TNotifyCollection.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TNotifyCollection.ChangedProc(Sender: TObject);
begin
  if Sender <> Self then
    Changed;
end;

procedure TNotifyCollection.Update(Item: TCollectionItem);
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;


{ TMethodList }

destructor TMethodList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TMethodList.Clear;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Dispose(PMethod(Items[I]));
  inherited Clear;
end;

procedure TMethodList.Add(Method: TMethod);
var
  P: PMethod;
begin
  New(P);
  P.Code := Method.Code;
  P.Data := Method.Data;
  inherited Add(P);
end;

procedure TMethodList.Remove(Method: TMethod);
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
  if (PMethod(Items[I]).Code = Method.Code) and
     (PMethod(Items[I]).Data = Method.Data) then
  begin
    Dispose(PMethod(Items[I]));
    Delete(I);
    Exit;
  end;
end;


{ TNotifyEventList }

constructor TNotifyEventList.Create(AOwner: TPersistent);
begin
  FList := TMethodList.Create;
  FOwner := AOwner;
end;

destructor TNotifyEventList.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TNotifyEventList.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TNotifyEventList.Changed;
var
  I: Integer;
  Method: TMethod;
begin
  if FUpdateCount = 0 then
    for I := 0 to FList.Count - 1 do
    begin
      Method.Code := PMethod(FList[I]).Code;
      Method.Data := PMethod(FList[I]).Data;
      TNotifyEvent(Method)(GetOwner);
    end;
end;

procedure TNotifyEventList.Add(Event: TNotifyEvent);
begin
  FList.Add(TMethod(Event));
end;

procedure TNotifyEventList.Remove(Event: TNotifyEvent);
begin
  FList.Remove(TMethod(Event));
end;


end.

