(*********************************************************************

  heStringList.pas

  start  2001/07/25
  update 2002/08/31

  Copyright (c) 2001 本田勝彦 <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  TEditor 内部で利用される文字列リストの基底クラスの基底クラス

**********************************************************************)

unit heStringList;

{$I heverdef.inc}

interface

uses
  Classes;

type
  PheStringItem = ^TheStringItem;
  TheStringItem = record
    FString: String;
    FDataStr: String;
    FData: Pointer;
    FItem: Pointer;
    FItem2: Pointer;
  end;

const
  heStringItemSize = SizeOf(TheStringItem);
  heMaxListSize = Maxint div heStringItemSize;

type
  PheStringItemList = ^TheStringItemList;
  TheStringItemList = array[0..heMaxListSize - 1] of TheStringItem;

  TheStringList = class(TStrings)
  private
    FList: PheStringItemList;
    FCount: Integer;
    FCapacity: Integer;
    FUpdateCount: Integer;
    FOnChange: TNotifyEvent;
    FOnChanging: TNotifyEvent;
    procedure ExchangeItems(Index1, Index2: Integer);
    procedure Grow;
    procedure InsertItem(Index: Integer; const S: string);
    function GetData(Index: Integer): Pointer;
    procedure PutData(Index: Integer; Data: Pointer);
    function GetDataStr(Index: Integer): String;
    procedure PutDataStr(Index: Integer; Data: String);
    function GetItem(Index: Integer): Pointer;
    procedure PutItem(Index: Integer; Item: Pointer);
    function GetItem2(Index: Integer): Pointer;
    procedure PutItem2(Index: Integer; Item: Pointer);
  protected
    procedure Changed; virtual;
    procedure Changing; virtual;
    {$IFDEF COMP2}
    procedure Error(const Msg: string; Data: Integer);
    {$ENDIF}
    function Get(Index: Integer): string; override;
    function GetCapacity: Integer; {$IFDEF COMP3_UP} override;{$ENDIF}
    function GetCount: Integer; override;
    procedure Put(Index: Integer; const S: string); override;
    procedure SetCapacity(NewCapacity: Integer); {$IFDEF COMP3_UP} override;{$ENDIF}
    procedure SetUpdateState(Updating: Boolean); override;
  public
    destructor Destroy; override;
    function Add(const S: string): Integer; override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Exchange(Index1, Index2: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;
    {$IFDEF COMP2}
    property Capacity: Integer read GetCapacity write SetCapacity;
    {$ENDIF}
    property Datas[Index: Integer]: Pointer read GetData write PutData;
    property DataStrings[Index: Integer]: String read GetDataStr write PutDataStr;
    property Items[Index: Integer]: Pointer read GetItem write PutItem;
    property Items2[Index: Integer]: Pointer read GetItem2 write PutItem2;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
  end;


implementation

{ TheStringList }

{$IFNDEF COMP6_UP}
  {$IFDEF COMP3_UP}
    // D3, D4, D5
    uses
      Consts;
  {$ELSE}
    // D2
    uses
      heStrConsts;
    const
      SListIndexError = heStringList_ListIndexError; // 'リストのインデックスが範囲を超えています'; // D2
  {$ENDIF}
{$ELSE}
    // D6..
    uses
      heStrConsts;
    const
      SListIndexError = heStringList_ListIndexError; // 'リストのインデックスが範囲を超えています'; // D6
{$ENDIF}

destructor TheStringList.Destroy;
begin
  FOnChange := nil;
  FOnChanging := nil;
  inherited Destroy;
  if FCount <> 0 then
    Finalize(FList^[0], FCount);
  FCount := 0;
  SetCapacity(0);
end;

function TheStringList.GetData(Index: Integer): Pointer;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SListIndexError, Index);
  Result := FList^[Index].FData;
end;

procedure TheStringList.PutData(Index: Integer; Data: Pointer);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SListIndexError, Index);
  FList^[Index].FData := Data;
end;

function TheStringList.GetDataStr(Index: Integer): String;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SListIndexError, Index);
  Result := FList^[Index].FDataStr;
end;

procedure TheStringList.PutDataStr(Index: Integer; Data: String);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SListIndexError, Index);
  FList^[Index].FDataStr := Data;
end;

function TheStringList.GetItem(Index: Integer): Pointer;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SListIndexError, Index);
  Result := FList^[Index].FItem;
end;

procedure TheStringList.PutItem(Index: Integer; Item: Pointer);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SListIndexError, Index);
  FList^[Index].FItem := Item;
end;

function TheStringList.GetItem2(Index: Integer): Pointer;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SListIndexError, Index);
  Result := FList^[Index].FItem2;
end;

procedure TheStringList.PutItem2(Index: Integer; Item: Pointer);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SListIndexError, Index);
  FList^[Index].FItem2 := Item;
end;

function TheStringList.Add(const S: string): Integer;
begin
  Result := FCount;
  InsertItem(Result, S);
end;

procedure TheStringList.Changed;
begin
  if (FUpdateCount = 0) and Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TheStringList.Changing;
begin
  if (FUpdateCount = 0) and Assigned(FOnChanging) then
    FOnChanging(Self);
end;

procedure TheStringList.Clear;
begin
  if FCount <> 0 then
  begin
    Changing;
    Finalize(FList^[0], FCount);
    FCount := 0;
    SetCapacity(0);
    Changed;
  end;
end;

procedure TheStringList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SListIndexError, Index);
  Changing;
  Finalize(FList^[Index]);
  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(TheStringItem));
  Changed;
end;

{$IFDEF COMP2}
procedure TheStringList.Error(const Msg: string; Data: Integer);

  function ReturnAddr: Pointer;
  asm
          MOV     EAX,[EBP+4]
  end;

begin
  raise EStringListError.CreateFmt(Msg, [Data]) at ReturnAddr;
end;
{$ENDIF}

procedure TheStringList.Exchange(Index1, Index2: Integer);
begin
  if (Index1 < 0) or (Index1 >= FCount) then
    Error(SListIndexError, Index1);
  if (Index2 < 0) or (Index2 >= FCount) then
    Error(SListIndexError, Index2);
  Changing;
  ExchangeItems(Index1, Index2);
  Changed;
end;

procedure TheStringList.ExchangeItems(Index1, Index2: Integer);
var
  Temp: Integer;
  Item1, Item2: PheStringItem;
begin
  Item1 := @FList^[Index1];
  Item2 := @FList^[Index2];
  Temp := Integer(Item1^.FString);
  Integer(Item1^.FString) := Integer(Item2^.FString);
  Integer(Item2^.FString) := Temp;
  Temp := Integer(Item1^.FDataStr);
  Integer(Item1^.FDataStr) := Integer(Item2^.FDataStr);
  Integer(Item2^.FDataStr) := Temp;
  Temp := Integer(Item1^.FData);
  Integer(Item1^.FData) := Integer(Item2^.FData);
  Integer(Item2^.FData) := Temp;
  Temp := Integer(Item1^.FItem);
  Integer(Item1^.FItem) := Integer(Item2^.FItem);
  Integer(Item2^.FItem) := Temp;
  Temp := Integer(Item1^.FItem2);
  Integer(Item1^.FItem2) := Integer(Item2^.FItem2);
  Integer(Item2^.FItem2) := Temp;
end;

function TheStringList.Get(Index: Integer): string;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SListIndexError, Index);
  Result := FList^[Index].FString;
end;

function TheStringList.GetCapacity: Integer;
begin
  Result := FCapacity;
end;

function TheStringList.GetCount: Integer;
begin
  Result := FCount;
end;

procedure TheStringList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then
    Delta := FCapacity div 4
  else
    if FCapacity > 8 then
      Delta := 16
    else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

procedure TheStringList.Insert(Index: Integer; const S: string);
begin
  if (Index < 0) or (Index > FCount) then
    Error(SListIndexError, Index);
  InsertItem(Index, S);
end;

procedure TheStringList.InsertItem(Index: Integer; const S: string);
begin
  Changing;
  if FCount = FCapacity then
    Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1],
      (FCount - Index) * SizeOf(TheStringItem));
  with FList^[Index] do
  begin
    Pointer(FString) := nil;
    Pointer(FDataStr) := nil;
    FData := nil;
    FItem := nil;
    FItem2 := nil;
    FString := S;
  end;
  Inc(FCount);
  Changed;
end;

procedure TheStringList.Put(Index: Integer; const S: string);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SListIndexError, Index);
  Changing;
  FList^[Index].FString := S;
  Changed;
end;

procedure TheStringList.SetCapacity(NewCapacity: Integer);
begin
  ReallocMem(FList, NewCapacity * SizeOf(TheStringItem));
  FCapacity := NewCapacity;
end;

procedure TheStringList.SetUpdateState(Updating: Boolean);
begin
  if Updating then
  begin
    Changing;
    Inc(FUpdateCount);
  end
  else
  begin
    Dec(FUpdateCount);
    Changed;
  end;
end;

end.
