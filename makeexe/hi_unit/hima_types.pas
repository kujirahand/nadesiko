unit hima_types;

// �Ђ܂Q�Ŏg�����X�g��n�b�V�����`��������

interface

uses
  Windows, SysUtils;

type
  //----------------------------------------------------------------------------
  // ���X�g
  //----------------------------------------------------------------------------

  TPtrArray = Array of Pointer;

  // ���z�N���X�i���X�g�ɍŒ�K�v�ȃ��\�b�h���`��������)
  THListBase = class(TObject)
  protected
    FCount: Integer;
  public
    // ��{���\�b�h
    procedure Clear; virtual; abstract;
    procedure Delete(Index: Integer); virtual; abstract;
    property Count: Integer read FCount;
  end;

  // ���X�g�\�[�g�p
  THListSortCompare = function (A, B: Pointer): Integer; // A>B �Ȃ�0�ȏ�

  // �ėp��y���X�g(�����Ŕz��𗘗p)
  THList = class(THListBase)
  private
    function GetItem(Index: Integer): Pointer;
    procedure SetItem(Index: Integer; const Value: Pointer);
  protected
    FArray: TPtrArray;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; override;
    procedure Grow(size: Integer); // ��C�Ƀ��X�g��L�΂�
    function Add(Item: Pointer): Integer;
    function AddNum(Item: DWORD): Integer;
    procedure Delete(Index: Integer); override;
    property Items[Index: Integer]:Pointer read GetItem write SetItem;
    function GetAsNum(Index: Integer): DWORD;
    procedure Push(Item: Pointer);
    function Pop: Pointer;
    procedure Reverse;
    procedure Random;
    procedure Exchange(I, J: Integer); virtual;// ����ւ�
    procedure Move(CurIndex, NewIndex: Integer); virtual;
    procedure Insert(Index: Integer; Item: Pointer);
    procedure QuickSort(comp: THListSortCompare);
    procedure MergeSort(comp: THListSortCompare);
    procedure Assign(a: THList);
  end;

  // ���X�g�J�����Ɏ����I�ɒǉ������N���X��������郊�X�g
  THObjectList = class(THList)
  private
    function GetObject(Index: Integer): TObject;
    procedure SetObject(Index: Integer; const Value: TObject);
  public
    procedure Clear; override;
    procedure ClearNotFree;
    destructor Destroy; override;
    function Add(Item: TObject): Integer;
    procedure Delete(Index: Integer); override;
    procedure DeleteNotFree(Index: Integer);
    property Objects[Index: Integer]:TObject read GetObject write SetObject;
  end;

  // �����񏈗��N���X
  THStringList = class(THList)
  private
    function getStrings(Index: Integer): string;
    procedure setString(Index: Integer; const Value: string);
    function getText: string;
    procedure setText(const Value: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; override;
    procedure Insert(Index: Integer; s: string);
    function Add(str: string): Integer;
    procedure Delete(Index: Integer); override;
    function IndexOf(key: string): Integer;
    procedure SplitText(S: string; Separator: string);
    procedure Move(CurIndex, NewIndex: Integer); override;
    property Strings[Index: Integer]: string read getStrings write setString; default;
    property Text: string read getText write setText;
    procedure AddStringList(s: THStringList);
    // file
    procedure LoadFromFile(Filename: string);
    procedure SaveToFile(Filename: string);
  end;

function CountStrLine(s: string): Integer;

//------------------------------------------------------------------------------
// HASH (Linked List) KEY = STRING
//------------------------------------------------------------------------------
const
  MAX_HASH_TABLE = 61; // �f���ɂ���̂��ǂ������ł��B(31,37,41,43,47,53,59,61,67...)
  HASH_KEY_NIL = '(NIL)';

type
  // �n�b�V��(�A�C�e��)
  THHashItem = class
  protected
    LinkNext : THHashItem;
  public
    Key      : string;
    constructor Create;
  end;

  // �|�C���^�n�b�V��
  THPtrHashItem = class(THHashItem)
  public
    Ptr: Pointer;
  end;

  // �S�Ẵn�b�V�������񂷂�R�[���o�b�N�֐�(���ʂ�FALSE�Ȃ�r���ŏ��񒆎~)
  THashEachFunction = function (item: THHashItem): Boolean of object;

  THHash = class
  private
    FTable: array of THHashItem;
    FCount: Integer;
    function GetHashKeyNo(key: string): Integer;
    function GetItem(Key: string): THHashItem;
    procedure SetItem(Key: string; const Value: THHashItem);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; virtual;
    procedure Add(Item: THHashItem);
    procedure DeleteKey(key: string);
    property Items[Key: string]: THHashItem read GetItem write SetItem;
    procedure Each(func: THashEachFunction);
    property Count: Integer read FCount;
  end;

//------------------------------------------------------------------------------
// HASH (Linked List) KEY = INTEGER
//------------------------------------------------------------------------------
const
  MAX_HASH_INT_TABLE = 32;

type
  PHIDHashItem = ^THIDHashItem;
  THIDHashItem = record
    Key:    Integer;
    Value:  Pointer;
    Link: PHIDHashItem;
  end;

  TIdHashEachFunction = function (item: PHIDHashItem; ptr: Pointer): Boolean of object;

  THIDHash = class
  private
    FCount: Integer;
    FTable: Array of PHIDHashItem;
    function getItem(Key: Integer): PHIDHashItem;
    procedure setItem(Key: Integer; const Value: PHIDHashItem);
    function getHashNo(Key: Integer): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; virtual;
    property Items[Key: Integer]: PHIDHashItem read getItem write setItem;
    procedure Each(func: TIdHashEachFunction; ptr: Pointer);
    property Count: Integer read FCount;
  end;


implementation

uses unit_string, mt19937;

{ THList }

function THList.Add(Item: Pointer): Integer;
var i: Integer;
begin
  i := FCount;
  Items[i] := Item;
  Result := i;
end;

function THList.AddNum(Item: DWORD): Integer;
begin
  Result := Add( Pointer(Item) );
end;

procedure THList.Assign(a: THList);
var
  i: Integer;
begin
  Clear;
  FCount := a.FCount;
  SetLength(FArray, FCount);
  for i := 0 to a.Count - 1 do
  begin
    FArray[i] := a.FArray[i];
  end;
end;

procedure THList.Clear;
begin
  FCount := 0;
end;

constructor THList.Create;
begin
  Grow(10); // �����T�C�Y
  FCount := 0;
end;

procedure THList.Delete(Index: Integer);
var
  i: Integer;
begin
  if FCount <= Index then Exit; // �͈͊O�͍폜���Ȃ�
  if FCount <= 1 then
  begin
    FArray[0] := nil;
    FCount := 0; Exit;
  end;
  if (FCount-1) = Index then // �Ō�̃A�C�e���Ȃ瑍�J�E���g��1���炷������OK
  begin
    //-------------------------
    // ���Ƃ��� delete 1 �̏ꍇ
    // 01 (2)
    // 0
    FArray[Index] := nil;
    Dec(FCount); Exit;
  end;
  //-------------------------
  // ���Ƃ��� delete 3 �̏ꍇ
  // 012345 (6)
  // 012|45
  // 01245*
  //System.Move(FArray[Index+1], FArray[Index], (FCount - Index - 1) * SizeOf(Pointer));

  for i := Index to FCount - 2 do
  begin
    FArray[i] := FArray[i + 1];
  end;
  FArray[FCount-1] := nil;
  Dec(FCount);
end;

destructor THList.Destroy;
begin
  Clear;
  inherited;
end;

procedure THList.Exchange(I, J: Integer);
var
  tmp: Pointer;
begin
  tmp := Items[I];
  Items[I] := Items[J];
  Items[J] := tmp;
end;

function THList.GetAsNum(Index: Integer): DWORD;
begin
  Result := DWORD( GetItem(Index) );
end;

function THList.GetItem(Index: Integer): Pointer;
begin
  if (Index >= FCount)or(Index < 0) then
  begin
    raise ERangeError.CreateFmt('�z��̗v�f��(=%d)�𒴂����w��(=%d)������܂��B',
      [FCount,Index]);
  end;
  if Index >= Length(FArray) then
  begin
    Result := nil;
  end else
  begin
    Result := FArray[Index];
  end;
end;

procedure THList.Grow(size: Integer);
var
  nowSize: Integer;
  i: Integer;
begin
  if size > Length(FArray) then
  begin
    nowSize := Length(FArray);
    SetLength(FArray, size + 20);
    //----------------------
    // Grow �����珉����
    for i := nowSize to High(FArray) do
    begin
      FArray[i] := nil;
    end;
  end;
end;


procedure THList.Insert(Index: Integer; Item: Pointer);
var
  newArray: TPtrArray;
  i: Integer;
begin
  if Index >= FCount then
  begin
    // �ǉ�
    FCount := Index + 1;
  end else
  begin
    // �}��
    Inc(FCount);
  end;
  SetLength(newArray, FCount);
  for i := 0 to High(newArray) do newArray[i] := nil;
  
  // 0 1 2 3 4 5 6 7 8 9
  // 0 * 1 2 3 4 5 6 7 8 9

  // �O���R�s�[
  for i := 0 to Index - 1 do
  begin
    if i < Length(FArray) then
      newArray[i] := FArray[i];
  end;

  // �{�̂��R�s�[
  newArray[Index] := Item;

  // �����R�s�[
  for i := Index to FCount - 2 do
  begin
    if i < Length(FArray) then
      newArray[i+1] := FArray[i];
  end;

  //Finalize(FArray);
  FArray := nil;
  FArray := newArray; // COPY
end;

procedure THList.MergeSort(comp: THListSortCompare);

  procedure merge(a1, a2, a: THList);
  var i, j: Integer;
  begin
    i := 0; j := 0;
    while(i < a1.Count)or(j < a2.Count)do
    begin
      if (j >= a2.Count)or
         ( (i < a1.Count)and(comp(a1.Items[i], a2.Items[j]) < 0) ) then
      begin
        a.Items[i + j] := a1.Items[i]; Inc(i);
      end else
      begin
        a.Items[i + j] := a2.Items[j]; Inc(j);
      end;
    end;
  end;

  procedure msort(a: THList);
  var
    m,n,i: Integer;
    a1, a2: THList;
  begin
    if (a.Count <= 1) then Exit;
    m := a.Count div 2;
    n := a.Count - m;
    // left
    a1 := THList.Create;
    a1.Grow(m); a1.FCount := m;
    for i := 0 to m - 1 do a1.FArray[i] := a.FArray[i];
    // right
    a2 := THList.Create;
    a2.Grow(n); a2.FCount := n;
    for i := 0 to n - 1 do a2.FArray[i] := a.FArray[m+i];
    //
    msort(a1);
    msort(a2);
    merge(a1,a2,a);

    THList(a1).Clear; FreeAndNil(a1);
    THList(a2).Clear; FreeAndNil(a2);
  end;

begin
  if Count = 0 then Exit;
  msort(Self);
end;

procedure THList.Move(CurIndex, NewIndex: Integer);
var
  tmp: Pointer;
begin
  tmp := Items[CurIndex];
  Self.Delete(CurIndex);
  Insert(NewIndex, tmp);
end;

function THList.Pop: Pointer;
begin
  if FCount <= 0 then
  begin
    Result := nil;
    Exit;
  end;
  Result := Items[FCount-1];
  Dec(FCount);
end;

procedure THList.Push(Item: Pointer);
begin
  Add(Item);
end;

procedure THList.QuickSort(comp: THListSortCompare);

  //����łȂ��A�����A�X�^�b�N���ʏ���
  procedure subQuickSort(First, Last:Integer);//�N�C�b�N�\�[�g by 97/12/07(��) 19:09 �ׂ�(BYI15773) �l ����
  var
    I, J: Integer;
    T   : Pointer;
  begin
    repeat
      I := First;
      J := Last;
      T := Items[(I + J) div 2]; // ����
      repeat
        while Comp(Items[I],T) < 0 do Inc(I);
        while Comp(Items[J],T) > 0 do Dec(J);
        if I <= J then
        begin
          Exchange(I, J);
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if First < J then subQuickSort(First, J);
      First := I;
    until I >= Last;
  end;

begin
  if Count = 0 then Exit;
  subQuickSort(0, FCount-1);
end;

procedure THList.Random;
var
  i, j, k: Integer;
  tmp: Pointer;
begin
  for k := 0 to 2 do // �O�̂��߉��x���V���b�t��
  for i := 0 to Count - 1 do
  begin
    j := mt19937.RandomMT.Random(Count);
    tmp := FArray[i];
    FArray[i] := FArray[j];
    FArray[j] := tmp;
  end;
end;

procedure THList.Reverse;
var
  i: Integer;
  p: Pointer;
  a,b: Integer;
begin
  for i := 0 to (FCount div 2) - 1 do
  begin
    a := i;
    b := FCount - 1 - i;
    //
    p := FArray[a];
    FArray[a] := FArray[b];
    FArray[b] := p;
  end;
end;

procedure THList.SetItem(Index: Integer; const Value: Pointer);
begin
  // �����z��͈̔͂𒴂��Ă�����g������
  if Index >= FCount then
  begin
    FCount := Index + 1;
    Grow(FCount);
  end;
  FArray[Index] := Value;
end;



{ THObjectList }

function THObjectList.Add(Item: TObject): Integer;
begin
  Result := inherited Add(Item);
end;

procedure THObjectList.Clear;
var
  i: Integer;
  p: TObject;
begin
  for i := 0 to FCount - 1 do
  begin
    p := Items[i];
    if p <> nil then FreeAndNil(p);
  end;
  inherited;
end;

procedure THObjectList.ClearNotFree;
begin
  inherited Clear;
end;

procedure THObjectList.Delete(Index: Integer);
var
  o: TObject;
begin
  o := Items[Index];
  FreeAndNil(o);
  inherited Delete(Index);
end;

procedure THObjectList.DeleteNotFree(Index: Integer);
begin
  inherited Delete(Index);
end;

destructor THObjectList.Destroy;
begin
  Clear;
  inherited;
end;

function THObjectList.GetObject(Index: Integer): TObject;
begin
  Result := Items[Index];
end;

procedure THObjectList.SetObject(Index: Integer; const Value: TObject);
var
  o: TObject;
begin
  o := Items[Index];
  o.Free;
  Items[Index] := Value;
end;

{ THStringList }

function THStringList.Add(str: string): Integer;
var
  p: PString;
begin
  New(p);
  p^ := str;
  Result := inherited Add(p);
end;

procedure THStringList.AddStringList(s: THStringList);
var
  i: Integer;
begin
  for i := 0 to s.Count - 1 do
  begin
    Self.Add( s.Strings[i] );
  end;
end;

procedure THStringList.Clear;
var
  i: Integer;
  p: PString;
begin
  for i := 0 to FCount - 1 do
  begin
    p := Items[i];
    Dispose(p);
  end;
  inherited;
end;

constructor THStringList.Create;
begin
end;

procedure THStringList.Delete(Index: Integer);
var
  p: PString;
begin
  p := Items[Index];
  Dispose(p);
  inherited Delete(Index);
end;

destructor THStringList.Destroy;
begin
  inherited;
end;

function THStringList.getStrings(Index: Integer): string;
var
  p: PString;
begin
  p := Items[Index];
  Result := p^;
end;

function THStringList.getText: string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to FCount - 1 do
    Result := Result + Strings[i] + #13#10;
end;

function THStringList.IndexOf(key: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to FCount - 1 do
  begin
    if Strings[i] = key then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure THStringList.Insert(Index: Integer; s: string);
var
  p: PString;
begin
  New(p);
  p^ := s;
  inherited Insert(Index, p);  
end;

procedure THStringList.LoadFromFile(Filename: string);
var
  f: TextFile;
  line: string;
begin
  AssignFile(f, Filename);
  try
    Reset(f);
    while not EOF(f) do
    begin
      Readln(f, line);
      Add(line);
    end;
  finally
    CloseFile(f);
  end;
end;

procedure THStringList.Move(CurIndex, NewIndex: Integer);
begin
  inherited Move(CurIndex, NewIndex);
end;

procedure THStringList.SaveToFile(Filename: string);
var
  f: TextFile;
  i: Integer;
  line: string;
begin
  AssignFile(f, Filename);
  try
    Rewrite(f);
    for i := 0 to FCount - 1 do
    begin
      line := Strings[i];
      Writeln(f, line);
    end;
  finally
    CloseFile(f);
  end;
end;

procedure THStringList.setString(Index: Integer; const Value: string);
var
  p: PString;
begin
  p := Items[Index];
  p^ := Value;
end;

procedure THStringList.setText(const Value: string);
var
  s: string;
  p: PChar;
begin
  Clear;
  p := PChar(Value);
  while p^ <> #0 do
  begin
    s := getTokenStr(p, #13#10);
    Add(s);
  end;
end;


procedure THStringList.SplitText(S, Separator: string);
var
  v: string;
begin
  while S <> '' do
  begin
    v := getToken_s(S, Separator);
    Add(v);
  end;
end;

function CountStrLine(s: string): Integer;
var
  ss: THStringList;
begin
  ss := THStringList.Create;
  ss.Text := s;
  Result := ss.Count;
  ss.Free;
end;

{ THHash }

procedure THHash.Add(Item: THHashItem);
begin
  SetItem(Item.Key, Item);
end;

procedure THHash.Clear;
var
  i: Integer;
  p, pn: THHashItem;
begin
  // �e�[�u�����N���A���� nil ��������
  for i := 0 to High(FTable) do
  begin
    p := FTable[i];
    if p = nil then Continue;
    while p <> nil do
    begin
      pn := p;
      p := p.LinkNext;
      FreeAndNil(pn);
    end;
  end;
  FCount := 0;
end;

constructor THHash.Create;
var
  i: Integer;
begin
  // �n�b�V���e�[�u���̍쐬
  SetLength(FTable, MAX_HASH_TABLE);

  // ������
  for i := 0 to High(FTable) do FTable[i] := nil;

  // �n�b�V����
  FCount := 0;
end;

procedure THHash.DeleteKey(key: string);
var
  n: Integer;
  p, pr: THHashItem;
begin
  if key = '' then key := HASH_KEY_NIL;
  n := GetHashKeyNo(key);
  p := FTable[n]; pr := nil;
  while (p <> nil) do
  begin
    if key = p.Key then
    begin
      // �폜�O�̃����N���Ȃ���
      if pr <> nil then pr.LinkNext := p.LinkNext else FTable[n] := nil;
      FreeAndNil(p);
      Dec(FCount);
      Break;
    end else
    begin
      pr := p;
      p  := p.LinkNext;
    end;
  end;
end;

destructor THHash.Destroy;
begin
  Clear;
  inherited;
end;

function THHash.GetHashKeyNo(key: string): Integer;
var
  i, iTo: Integer;
begin
  if key = '' then raise Exception.Create('�n�b�V���̃L�[�ɋ󔒂��w�肳��܂����B');
  Result := 0;
  iTo := Length(key);
  if iTo > 8 then iTo := 8;
  for i := 1 to iTo do Result := (Result shl 1) + Ord(key[i]);
  Result := Result mod MAX_HASH_TABLE; // �e�[�u���T�C�Y�Ɏ��܂�悤��
end;

function THHash.GetItem(Key: string): THHashItem;
var
  no: Integer;
  p: THHashItem;
begin
  Result := nil;
  if Key = '' then Key := HASH_KEY_NIL;
  no := GetHashKeyNo(Key);
  p := FTable[no];
  if p = nil then Exit;
  while p <> nil do
  begin
    if p.Key = Key then
    begin
      Result := p; Exit;
    end;
    p := p.LinkNext;
  end;
end;

procedure THHash.Each(func: THashEachFunction);
var
  i: Integer;
  p: THHashItem;
begin
  for i := 0 to High(FTable) do
  begin
    p := FTable[i];
    if p = nil then Continue;
    while p <> nil do
    begin
      if func(p) = False then Exit;
      p := p.LinkNext;
    end;
  end;
end;

procedure THHash.SetItem(Key: string; const Value: THHashItem);
var
  no: Integer;
  p, pr: THHashItem;
  FlagReplace: Boolean;
begin
  if Key = '' then Key := HASH_KEY_NIL;

  no := GetHashKeyNo(Key);
  if FTable[no] = nil then
  begin
    Value.LinkNext := nil; // ���� nil
    FTable[no] := Value;
  end else
  begin
    p := FTable[no];
    pr := nil;
    FlagReplace := False;
    while (p.LinkNext <> nil) do
    begin
      if p.Key = Key then
      begin
        // �f�[�^��u������
        if pr <> nil then pr.LinkNext := Value; // �O
        Value.LinkNext := p.LinkNext;           // ��
        FlagReplace := True;
        Break;
      end;
      pr := p;
      p  := p.LinkNext;
    end;
    if not FlagReplace then
    begin
      p.LinkNext := Value;
      Value.LinkNext := nil;
      Inc(FCount);
    end;
  end;
end;

{ THHashItem }

constructor THHashItem.Create;
begin
  LinkNext := nil;
end;


{ THIDHash }

procedure THIDHash.Clear;
var
  i: Integer;
  p, pp: PHIDHashItem;
begin
  if FCount = 0 then Exit; //�@���X�g����Ȃ�`�F�b�N���Ȃ�
  
  for i := 0 to High(FTable) do
  begin
    p := FTable[i];
    while p <> nil do
    begin
      if p.Link <> nil then
      begin
        pp := p;
        p := p.Link;
        Dispose(pp); // ���g��������Ď���
      end else
      begin
        Dispose(p); // ���g��������Ĕ�����
        p := nil;
      end;
    end;
    FTable[i] := nil;
  end;
  FCount := 0;
end;

constructor THIDHash.Create;
var
  i: Integer;
begin
  FCount := 0;
  SetLength(FTable, MAX_HASH_INT_TABLE);
  for i := 0 to High(FTable) do FTable[i] := nil;
end;

destructor THIDHash.Destroy;
begin
  Clear;
  inherited;
end;

function THIDHash.getHashNo(Key: Integer): Integer;
begin
  Result := Key mod MAX_HASH_INT_TABLE;
end;

function THIDHash.getItem(Key: Integer): PHIDHashItem;
var
  no: Integer;
  p: PHIDHashItem;
begin
  Result := nil;
  if Key <= 0 then Exit;
  no := getHashNo(Key);
  p  := FTable[no];
  while p <> nil do
  begin
    if p.Key = Key then
    begin
      Result := p; Break;
    end;
    p := p.Link;
  end;
end;

procedure THIDHash.Each(func: TIdHashEachFunction; ptr: Pointer);
var
  i: Integer;
  p: PHIDHashItem;
begin
  for i := 0 to High(FTable) do
  begin
    p := FTable[i];
    while p <> nil do
    begin
      try
        if func(p, ptr) = False then Break;
      except
        p := nil;
        Break;
      end;
      p := p.Link;
    end;
  end;
end;

procedure THIDHash.setItem(Key: Integer; const Value: PHIDHashItem);
var
  no: Integer;
  p, pp, pn: PHIDHashItem;
begin
  no := getHashNo(Key);
  p  := FTable[no]; pp := nil;

  while p <> nil do
  begin
    if p.Key = Key then
    begin
      // �u������
      pn := p.Link;
      Dispose(p);
      if pp = nil then FTable[no] := Value else pp.Link := Value;
      Value.Link := pn;
      Exit;
    end;
    pp := p;
    p := p.Link;
  end;

  // �����e�[�u���� Key �͖�������
  if pp = nil then FTable[no] := Value else pp.Link := Value;
  Value.Link := nil;
  Inc(FCount);
end;

end.
