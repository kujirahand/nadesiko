unit MemCheck;
(*

�v���W�F�N�g�\�[�X�� Uses �߂̈�ԍŏ��� MemCheck ��ǉ�����B��ԍŏ��ɒǉ����Ȃ��ƃv���O����������ɓ��삵�Ȃ��Ȃ�܂��B 
�X�^�b�N�g���[�X�@�\���g�p����ɂ͈ȉ��̎������K�v������܂��B

�v���W�F�N�g�I�v�V�����̃R���p�C���^�u�́u�X�^�b�N�t���[���̐����v�� ON �ɂ���B 
�v���W�F�N�g�I�v�V�����̃����J�^�u�́uTD32�f�o�b�O�����܂߂�v�� ON �ɂ���B 
�v���W�F�N�g�I�v�V�����̃f�B���N�g���^�����^�u�̏����� MemCheckStackTrace ��ǉ�����B
��������Ȃ��Ə]���̃��������[�N�񐔃`�F�b�J�[�ɂȂ�܂��B 
�v���W�F�N�g�\�[�X�� MemCheckInstallExceptionHandler �֐����Ăяo���ė�O�n���h����o�^����B���������[�N�������`�F�b�N�������̂Ȃ�Εs�v�B 
�܂��v���W�F�N�g�I�v�V�����̃f�B���N�g���^�����^�u�Ō����p�X�Ɂu$(DELPHI)\Source\VCL�v��ǉ����邱�Ƃ� VCL �\�[�X�R�[�h�����ǐՂł���悤�ɂȂ�܂��B 


*)
interface

{$DEFINE MemCheckStackTrace}


uses Windows;

type
  TMemCheckGetExceptInfoFunc = procedure(Obj: TObject; var Message: string;
    var ExceptionRecord: PExceptionRecord);

  TMemCheckSetExceptMessageFunc = procedure(Obj: TObject; const NewMessage: string);

procedure MemCheckInstallExceptionHandler(GetExceptInfo: TMemCheckGetExceptInfoFunc;
  SetExceptMessage: TMemCheckSetExceptMessageFunc);

implementation

function Max(A,B: Integer): Integer;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function Min(A,B: Integer): Integer;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

const
  HexTbl: array[0..15] of Char = ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

function IntToStr(val: Integer): string;
var
  sign: Boolean;
begin
  Result := '';
  sign := val<0;
  val := Abs(val);

  while val<>0 do
  begin
    Result := HexTbl[val mod 10] + Result;
    val := val div 10;
  end;

  if sign then
    Result := '-' + Result;
end;

function IntToStr2(val, minLen: Integer): string;
var
  sign: Boolean;
begin
  Result := '';
  sign := val<0;
  val := Abs(val);

  while val<>0 do
  begin
    Result := HexTbl[val mod 10] + Result;
    val := val div 10;
  end;

  while Length(Result)<minLen do
    Result := '0' + Result;

  if sign then
    Result := '-' + Result;
end;

function IntToHex(val: DWORD; minLen: Integer): string;
begin
  Result := '';
  while val<>0 do
  begin
    Result := HexTbl[val and $F] + Result;
    val := val shr 4;
  end;

  while Length(Result)<minLen do
    Result := '0' + Result;
end;

type
  PPointer = ^Pointer;

  PArrayByte = ^TArrayByte;
  TArrayByte = array[0..10000] of Byte;

  PArrayPointer = ^TArrayPointer;
  TArrayPointer = array[0..10000] of Pointer;

  PArrayWord = ^TArrayWord;
  TArrayWord = array[0..10000] of Word;

  TLineInfo = record
    Line: Integer;
    Address: Integer;
  end;

  PUnitInfo = ^TUnitInfo;
  TUnitInfo = record
    Name: string[64];
    LineList: array of TLineInfo;
    StartAddress: Integer;
    EndAddress: Integer;
  end;

  PRoutineInfo = ^TRoutineInfo;
  TRoutineInfo = record
    Name: string[64];
    Address: Integer;
    Length: Integer;
    UnitInfo: PUnitInfo;
  end;

  PMemBlockHeader = ^TMemBlockHeader;
  TMemBlockHeader = record
    Left: PMemBlockHeader;
    Right: PMemBlockHeader;
    Size: Integer;
    StackFrame: array[0..31] of Pointer;
    StackFrameCount: Integer;
  end;

type
  TDebugInfomation = class
  private
    FUnitInfoList: array of TUnitInfo;
    FUnitInfoListCount: Integer;
    FRoutineInfoList: array of TRoutineInfo;
    FRoutineInfoListCount: Integer;
  public
    procedure Load(const FileName: string);
    function SearchUnitFromAddress(Address: Integer): PUnitInfo;
    function SearchLineFromAddress(UnitInfo: PUnitInfo; Address: Integer): Integer;
    function SearchRoutineFromAddress(Address: Integer): PRoutineInfo;
  end;

function TDebugInfomation.SearchUnitFromAddress(Address: Integer): PUnitInfo;
var
  i: Integer;
begin
  Result := nil;
  for i:=0 to FUnitInfoListCount-1 do
    if (FUnitInfoList[i].StartAddress<=Address) and (FUnitInfoList[i].EndAddress>Address) then
    begin
      Result := @FUnitInfoList[i];
      Exit;
    end;
end;

function TDebugInfomation.SearchLineFromAddress(UnitInfo: PUnitInfo; Address: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i:=Length(UnitInfo.LineList)-1 downto 0 do
    if UnitInfo.LineList[i].Address<=Address then
    begin
      Result := UnitInfo.LineList[i].Line;
      Exit;
    end;
end;

function TDebugInfomation.SearchRoutineFromAddress(Address: Integer): PRoutineInfo;
var
  i: Integer;
begin
  Result := nil;
  for i:=0 to FRoutineInfoListCount-1 do
    if (Address>=FRoutineInfoList[i].Address) and (Address<FRoutineInfoList[i].Address+FRoutineInfoList[i].Length) then
    begin
      Result := @FRoutineInfoList[i];
      Exit;
    end;
end;

procedure TDebugInfomation.Load(const FileName: string);
var
  SourceFile: file of Byte;

  function Load_TD32: Boolean;
  type
    TTD32_DebugInfoHeader = packed record
      Magic: array[0..3] of Char;
      Size: Longint;
    end;

    TTD32_FileListHeader = packed record
      HeaderSize: Word;
      FileHeaderSize: Word;
      FileCount: Word;
    end;

    TTD32_FileHeader = packed record
      FileType: Word;
      _1: Word;
      Offset: Longint;
      Size: Longint;
    end;

    TTD32_SymbolHeader = packed record
      HeaderSize: Word;
      SymbolType: Word;
      _1: Longint;
      _2: Longint;
      _3: Longint;
      CodeLength: Longint;
      _4: Longint;
      _5: Longint;
      CodeAddress: Longint;
      _6: Longint;
      _7: Longint;
      NameIndex: Longint;
    end;

    TTD32_UnitListHeader = packed record
      UnitCount: Word;
      _1: Word;
      UnitList: array[0..0] of Longint;
    end;

    TTD32_UnitHeader = packed record
      _1: Word;
      NameIndex: Longint;
      LineList: array[0..0] of Integer;
    end;

    TTD32_UnitLineHeader = packed record
      _1: Word;
      Count: Word;
      OffsetList: array[0..0] of Integer;
    end;
  var
    Header: TTD32_DebugInfoHeader;
    FileListHeader: TTD32_FileListHeader;
    DebugInfoBasePos, DebugInfoBasePos2: Integer;
    FileHeaderBuf: array of Byte;
    FileHeader: ^TTD32_FileHeader;
    TextBuf: array of Char;
    TextBufP: PChar;
    TextList: array of PChar;
    FileDataBuf: array of Byte;
    FileDataBufPos: Integer;
    i, j, n, Address: Integer;
    SymbolHeader: ^TTD32_SymbolHeader;
    UnitListHeader: ^TTD32_UnitListHeader;
    UnitHeader: ^TTD32_UnitHeader;
    UnitLineHeader: ^TTD32_UnitLineHeader;
    CurrentUnit: PUnitInfo;
  begin
    Result := False;

    {  �t�@�C���̍Ō�̃w�b�_���`�F�b�N  }
    Seek(SourceFile, FileSize(SourceFile)-SizeOf(Header));
    BlockRead(SourceFile, Header, SizeOf(Header));
    if (Header.Magic<>'FB09') and (Header.Magic<>'FB0A') or (Header.Size<=0) then Exit;

    DebugInfoBasePos := FilePos(SourceFile) - Header.Size;

    {  �f�o�b�O���̎n�܂�̃w�b�_���`�F�b�N  }
    Seek(SourceFile, DebugInfoBasePos);
    BlockRead(SourceFile, Header, SizeOf(Header));
    if (Header.Magic<>'FB09') and (Header.Magic<>'FB0A') or (Header.Size<=0) then Exit;

    DebugInfoBasePos2 := DebugInfoBasePos + Header.Size;

    {  �e�t�@�C���̃w�b�_�����[�h  }
    Seek(SourceFile, DebugInfoBasePos2);
    BlockRead(SourceFile, FileListHeader, SizeOf(FileListHeader));

    SetLength(FileHeaderBuf, FileListHeader.FileHeaderSize * FileListHeader.FileCount);

    Seek(SourceFile, DebugInfoBasePos2 + FileListHeader.HeaderSize);
    BlockRead(SourceFile, FileHeaderBuf[0], Length(FileHeaderBuf));

    {  �܂��e�L�X�g�����[�h }
    for i:=0 to FileListHeader.FileCount-1 do
    begin
      FileHeader := @FileHeaderBuf[i*FileListHeader.FileHeaderSize];
      if FileHeader.FileType=$0130 then
      begin
        {  �e�L�X�g  }
        SetLength(TextBuf, FileHeader.Size);

        Seek(SourceFile, DebugInfoBasePos+FileHeader.Offset);
        BlockRead(SourceFile, TextBuf[0], Length(TextBuf));

        {  �e�L�X�g�̃��X�g���\�z  }
        SetLength(TextList, PLongint(@TextBuf[0])^);
        TextBufP := @TextBuf[4];
        for j:=0 to Length(TextList)-1 do
        begin
          TextList[j] := @TextBufP[1];
          Inc(TextBufP, Ord(TextBufP[0])+2);
        end;
      end;
    end;

    {  �e��������[�h  }
    for i:=0 to FileListHeader.FileCount-1 do
    begin
      FileHeader := @FileHeaderBuf[i*FileListHeader.FileHeaderSize];
      if FileHeader.Size<=0 then Continue;

      if FileHeader.FileType=$0125 then
      begin
        {  �V���{�����  }
        SetLength(FileDataBuf, FileHeader.Size);

        Seek(SourceFile, DebugInfoBasePos+FileHeader.Offset);
        BlockRead(SourceFile, FileDataBuf[0], Length(FileDataBuf));

        FileDataBufPos := 4;
        while FileDataBufPos<=FileHeader.Size-SizeOf(TTD32_SymbolHeader) do
        begin
          SymbolHeader := @FileDataBuf[FileDataBufPos];
          if ((SymbolHeader.SymbolType=$205) or (SymbolHeader.SymbolType=$204)) and (SymbolHeader.NameIndex>0) then
          begin
            if FRoutineInfoListCount mod 1024=0 then
              SetLength(FRoutineInfoList, Length(FRoutineInfoList)+1024);

            FRoutineInfoList[FRoutineInfoListCount].Name := TextList[SymbolHeader.NameIndex-1];
            FRoutineInfoList[FRoutineInfoListCount].Address := SymbolHeader.CodeAddress;
            FRoutineInfoList[FRoutineInfoListCount].Length := SymbolHeader.CodeLength;
            FRoutineInfoList[FRoutineInfoListCount].UnitInfo := nil;
            Inc(FRoutineInfoListCount);
          end;

          Inc(FileDataBufPos, SymbolHeader.HeaderSize+2);
        end;
      end else
      if FileHeader.FileType=$0127 then
      begin
        {  ���j�b�g���  }
        SetLength(FileDataBuf, FileHeader.Size);

        Seek(SourceFile, DebugInfoBasePos+FileHeader.Offset);
        BlockRead(SourceFile, FileDataBuf[0], Length(FileDataBuf));

        UnitListHeader := @FileDataBuf[0];
        for j:=0 to UnitListHeader.UnitCount-1 do
        begin
          UnitHeader := @FileDataBuf[UnitListHeader.UnitList[j]];
          if UnitHeader.NameIndex>0 then
          begin
            if FUnitInfoListCount mod 16=0 then
              SetLength(FUnitInfoList, Length(FUnitInfoList)+16);
            CurrentUnit := @FUnitInfoList[FUnitInfoListCount];
            Inc(FUnitInfoListCount);

            CurrentUnit.Name := TextList[UnitHeader.NameIndex-1];
            CurrentUnit.StartAddress := MaxInt;
            CurrentUnit.EndAddress := 0;

            {  �f�B���N�g�������폜  }
            for n:=Length(CurrentUnit.Name) downto 1 do
              if CurrentUnit.Name[n]='\' then
              begin
                CurrentUnit.Name := Copy(CurrentUnit.Name, n+1, MaxInt);
                Break;
              end;

            {  �s�ԍ����  }
            UnitLineHeader := @FileDataBuf[UnitHeader.LineList[0]];

            SetLength(CurrentUnit.LineList, UnitLineHeader.Count);
            for n:=0 to UnitLineHeader.Count-1 do
            begin
              Address := UnitLineHeader.OffsetList[n];
              CurrentUnit.StartAddress := Min(CurrentUnit.StartAddress, Address);
              CurrentUnit.EndAddress := Max(CurrentUnit.EndAddress, Address);
              CurrentUnit.LineList[n].Line := PArrayWord(@UnitLineHeader.OffsetList[UnitLineHeader.Count])[n];
              CurrentUnit.LineList[n].Address := Address;
            end;
          end;
        end;
      end;
    end;

    Result := True;
  end;

var
  OldFileMode: Byte;
  i: Integer;
begin
  OldFileMode:= FileMode;
  FileMode:= 0;
  try
    AssignFile(SourceFile, FileName);
    try
      Reset(SourceFile);
      Load_TD32;
    finally
      CloseFile(SourceFile);
    end;
  finally
    FileMode := OldFileMode;
  end;

  {  �e���[�`���̃A�h���X���烆�j�b�g������  }
  for i:=1 to FRoutineInfoListCount-1 do
    FRoutineInfoList[i].UnitInfo := SearchUnitFromAddress(FRoutineInfoList[i].Address);
end;

var
  GetMemCount: Integer;
  OldMemMgr: TMemoryManager;
  Lock: TRTLCriticalSection;

{$IFDEF MemCheckStackTrace}
const
  DebugLogSepText = '---------------------------------------------------------------';

var
  DebugInfo: TDebugInfomation;

  ImageBaseAddress: Integer = $400000;

  LastMemBlock: PMemBlockHeader = nil;

  FatalErrorFlag: Boolean = False;
  DebugLogFileName: string[255];
  DebugLogFileNameFirstFlag: Boolean = True;

var
  AppAtom: TAtom = 0;

{$I-}
procedure PutDebugLog(const Text: string);
const
  CRLF: array[0..1] of Char = #13#10;
var
  F: file of Byte;
  FileNewFlag: Boolean;

  procedure PutDebugLog2(const Text: string);
  begin
    BlockWrite(F, Text[1], Length(Text));
    BlockWrite(F, CRLF, SizeOf(CRLF));
  end;

begin
  if DebugLogFileName='' then Exit;

  FileNewFlag := False;
  {if AppAtom=0 then
  begin
    if GlobalFindAtom(PChar(ParamStr(0)))=0 then
      FileOpenMode := True;
    AppAtom := GlobalAddAtomA(PChar(ParamStr(0)));
  end;}

  AssignFile(F, DebugLogFileName);
  try                     
    if FileNewFlag then            
    begin
      Rewrite(F);
      if IOResult<>0 then
        Exit;
    end else
    begin
      Reset(F);
      if IOResult<>0 then
      begin
        Rewrite(F);
        if IOResult<>0 then
          Exit;
        FileNewFlag := True;
      end;
    end;
    
    Seek(F, FileSize(F));

    if FileNewFlag then
    begin
      PutDebugLog2(ParamStr(0));
      PutDebugLog2('');
      PutDebugLog2(DebugLogSepText);
    end;

    PutDebugLog2(Text);
  finally
    CloseFile(F);
  end;
end;
{$I+}

procedure EndPutDebugLog;
begin
  if AppAtom<>0 then
    GlobalDeleteAtom(AppAtom);
end;

procedure PutDebugLogHeader(const Text: string);
var
  SystemTime: TSystemTime;
  TimeText: string;
begin
  GetLocalTime(SystemTime);

  TimeText := IntToStr2(SystemTime.wYear, 4)+'/'+IntToStr2(SystemTime.wMonth, 2)+'/'+IntToStr2(SystemTime.wDay, 2)+' '+
    IntToStr(SystemTime.wHour)+':'+IntToStr2(SystemTime.wMinute, 2)+':'+IntToStr2(SystemTime.wSecond, 2);

  PutDebugLog(TimeText + ' #' + IntToHex(GetCurrentProcessId, 8) + ' - ' + Text);
end;

procedure PutDebugLogSep;
begin
  PutDebugLog(DebugLogSepText);
end;

procedure InitImageBaseAddress;
var
  NTHeader: PImageFileHeader;
  NTOptHeader: PImageOptionalHeader;
begin
  NTHeader:= PImageFileHeader(Cardinal(PImageDosHeader(HInstance)._lfanew) + HInstance + 4); {SizeOf(IMAGE_NT_SIGNATURE) = 4}
  NTOptHeader:= PImageOptionalHeader(Cardinal(NTHeader) + IMAGE_SIZEOF_FILE_HEADER);
  ImageBaseAddress := HInstance + NTOptHeader.BaseOfCode;
end;

procedure LoadDebugInfo;
begin
  DebugInfo := TDebugInfomation.Create;
  DebugInfo.Load(ParamStr(0));


end;

procedure UnLoadDebugInfo;
var
  Block: PMemBlockHeader;
begin
  DebugInfo.Free;
  DebugInfo := nil;

  while LastMemBlock<>nil do
  begin
    Block := LastMemBlock.Right;
    OldMemMgr.FreeMem(LastMemBlock);
    LastMemBlock := Block;
  end;
end;

procedure TraceStackFrame(var Block: TMemBlockHeader; Offset: Integer; EBP: Pointer);
var
  Address: Integer;
  OrgEBP: Pointer;
begin
  Block.StackFrameCount := 0;

  OrgEBP := EBP;
  while True do
  begin
    {  4�o�C�g���E�ɔz�u����Ă���K�v������  }
    if DWORD(EBP) and 3<>0 then Exit;

    {  ���Ȃ��Ƃ�8�o�C�g����ɓǂ߂�K�v������  }
    if IsBadReadPtr(EBP, 12) then Exit;

    {  �֐��A�h���X�擾  }
    Address := PInteger(DWORD(EBP)+4)^-ImageBaseAddress-1;
    if Address<0 then Exit;

    {  �֐����擾 }
    if Offset=0 then
    begin
      Block.StackFrame[Block.StackFrameCount] := PPointer(Integer(OrgEBP)+8)^;
      Inc(Block.StackFrameCount);
      if Block.StackFrameCount>=High(Block.StackFrame) then Exit;
    end;

    if Offset<=0 then
    begin
      Block.StackFrame[Block.StackFrameCount] := PPointer(DWORD(EBP)+4)^;
      Inc(Block.StackFrameCount);
      if Block.StackFrameCount>=High(Block.StackFrame) then Exit;
    end;

    Dec(Offset);

    {  ���̃X�^�b�N�t���[���ֈړ�  }
    EBP := PPointer(EBP)^;
  end;
end;

function GetRoutineInfoText(RoutineInfo: PRoutineInfo; Address: Integer): string;
begin
  if RoutineInfo.UnitInfo<>nil then
    Result := RoutineInfo.UnitInfo.Name + '('+IntToStr(DebugInfo.SearchLineFromAddress(RoutineInfo.UnitInfo, Address))+')'+' : '+RoutineInfo.Name+' �֐�'
  else
    Result := '�s���ȃt�@�C�� : ' + RoutineInfo.Name + ' �֐�';
end;

function TraceMemBlockStackFrame(const Block: TMemBlockHeader): string;
var
  IsAnsiString: Boolean;

  function TraceMemBlockStackFrame_FuncList(const Block: TMemBlockHeader): string;
  var
    i: Integer;
    Address: Integer;
    RoutineInfo: PRoutineInfo;
  begin
    Result := '';
    for i:=0 to Block.StackFrameCount-1 do
    begin
      Address := Integer(Block.StackFrame[i])-ImageBaseAddress-1;
      if Address<0 then Break;

      RoutineInfo := DebugInfo.SearchRoutineFromAddress(Address);
      if RoutineInfo=nil then Continue;

      if RoutineInfo.Name='@NewAnsiString' then
        IsAnsiString := True;

      Result := Result + '  ' + GetRoutineInfoText(RoutineInfo, Address) + #13#10;
    end;
  end;

  function DumpBinaryData(Buffer: PByte; BufSize: Integer): string;
  var
    i: Integer;
  begin
    Result := '';
    for i:=0 to BufSize-1 do
    begin
      Result := Result + HexTbl[Buffer^ shr 4];
      Result := Result + HexTbl[Buffer^ and $F];
      Inc(Buffer);
    end;
  end;

var
  i: Integer;
  s, TraceText: string;
  P: PByte;
begin
  Result := '';

  IsAnsiString := False;
  TraceText := TraceMemBlockStackFrame_FuncList(Block);

  {  �u���b�N�̎�މ��  }
  if Block.StackFrame[0]=Pointer(Integer(@TObject.NewInstance)+9) then
    s := TObject(Integer(@Block)+SizeOf(TMemBlockHeader)).ClassName + ' �N���X'
  else if IsAnsiString then
    s := '������(AnsiString)'
  else
    s := '�s��';

  Result := Result + '���: ' + s + #13#10;
  Result := Result + '�T�C�Y: ' + IntToStr(Block.Size) + ' �o�C�g' + #13#10;

  {  �f�[�^���_���v����  }
  Result := Result + '�o�C�i��:' + #13#10;
  i := Min(Block.Size, 1024);
  P := Pointer(Integer(@Block)+SizeOf(TMemBlockHeader));
  while i>0 do
  begin
    Result := Result + '  '+DumpBinaryData(P, Min(i, 32)) + #13#10;
    Inc(P, Min(i, 32));
    Dec(i, 32);
  end;
  Result := Result + #13#10;

  {  �X�^�b�N�t���[�� }
  Result := Result + TraceText;
end;

procedure AllocBlock(var Block: PMemBlockHeader; Size: Integer; EBP: Pointer);
begin
  Block.Size := Size;

  try
    if IsMultiThread then EnterCriticalSection(Lock);

    {  �����N���X�g�ɓo�^  }
    Block.Left := nil;
    Block.Right := LastMemBlock;
    if LastMemBlock<>nil then LastMemBlock.Left := Block;
    LastMemBlock := Block;

    {  �m�ۉ񐔂��P����  }
    Inc(GetMemCount);
  finally
    if IsMultiThread then LeaveCriticalSection(Lock);
  end;

  {  �X�^�b�N�t���[�����  }
  Block.StackFrameCount := 0;
  TraceStackFrame(Block^, 1, EBP);

  Inc(PByte(Block), SizeOf(TMemBlockHeader));
end;

procedure DeallocBlock(var Block: PMemBlockHeader);
begin
  Dec(PByte(Block), SizeOf(TMemBlockHeader));

  try
    if IsMultiThread then EnterCriticalSection(Lock);

    {  �m�ۉ񐔂��P���炷  }
    Dec(GetMemCount);

    {  �����N���X�g����폜  }
    if Block.Left<>nil then Block.Left.Right := Block.Right;
    if Block.Right<>nil then Block.Right.Left := Block.Left;
    if LastMemBlock=Block then LastMemBlock := Block.Right;
  finally
    if IsMultiThread then LeaveCriticalSection(Lock);
  end;
end;

function GetEBP: Pointer; assembler; register;
asm
  mov eax,ebp
end;

function NewGetMem(Size: Integer): Pointer;
begin
  if Size>0 then
  begin
    Result := OldMemMgr.GetMem(Size+SizeOf(TMemBlockHeader));
    AllocBlock(PMemBlockHeader(Result), Size, GetEBP);
  end else
    Result := nil;
end;

function NewFreeMem(P: Pointer): Integer;
begin
  if P<>nil then
  begin
    DeallocBlock(PMemBlockHeader(P));
    Result := OldMemMgr.FreeMem(P);
  end else
    Result := 0;
end;

function NewReallocMem(P: Pointer; Size: Integer): Pointer;
begin
  if P<>nil then
    DeallocBlock(PMemBlockHeader(P));

  Result := OldMemMgr.ReallocMem(P, Size+SizeOf(TMemBlockHeader));

  if Result<>nil then
    AllocBlock(PMemBlockHeader(Result), Size, GetEBP);
end;

var
  OldExceptObjProc: Pointer;
  GetExceptInfoFunc: TMemCheckGetExceptInfoFunc;
  SetExceptMessageFunc: TMemCheckSetExceptMessageFunc;

function MyGetExceptionObject(P: PExceptionRecord): Pointer;
type
  TExceptObjProc = function(P: PExceptionRecord): Pointer;
var
  EBP: Pointer;
  Address: Integer;
  TraceList: array[0..31] of Integer;
  TraceListCount: Integer;
  ExceptionRecord: PExceptionRecord;
  RoutineInfo: PRoutineInfo;
  i: Integer;
  Text: string;
begin
  ExceptObjProc := OldExceptObjProc;
  try
    {  �X�^�b�N�t���[�����g���[�X����  }
    EBP := GetEBP;
    if IsBadReadPtr(EBP, 4) then
    begin
      Result := TExceptObjProc(OldExceptObjProc)(P);
      Exit;
    end;
    EBP := PPointer(EBP)^;

    if IsBadReadPtr(EBP, 4) then
    begin
      Result := TExceptObjProc(OldExceptObjProc)(P);
      Exit;
    end;
    EBP := PPointer(EBP)^;

    if IsBadReadPtr(EBP, 4) then
    begin
      Result := TExceptObjProc(OldExceptObjProc)(P);
      Exit;
    end;
    EBP := PPointer(EBP)^;

    TraceListCount := 0;
    while True do
    begin
      {  4�o�C�g���E�ɔz�u����Ă���K�v������  }
      if DWORD(EBP) and 3<>0 then Break;

      {  ���Ȃ��Ƃ�8�o�C�g����ɓǂ߂�K�v������  }
      if IsBadReadPtr(EBP, 12) then Break;

      {  �֐��A�h���X�擾  }
      Address := PInteger(DWORD(EBP)+4)^-ImageBaseAddress-1;
      if Address<0 then Break;

      {  �֐����擾 }
      TraceList[TraceListCount] := Address;
      Inc(TraceListCount);

      {  ���̃X�^�b�N�t���[���ֈړ�  }
      EBP := PPointer(EBP)^;
    end;

    {  ���� ExceptObjProc ���Ăяo��  }
    Result := TExceptObjProc(OldExceptObjProc)(P);

    {  ��O�̏����ڍ׉�����  }
    Text := '';
    ExceptionRecord := nil;
    GetExceptInfoFunc(Result, Text, ExceptionRecord);

    if Text<>'' then
    begin
      if (Copy(Text, Length(Text)-1, 2)<>'�B') and (Copy(Text, Length(Text), 1)<>'.') then
        Text := Text + '.';
    end;
    Text := Text + #13#10#13#10;

    if ExceptionRecord<>nil then
    begin
      FatalErrorFlag := True;

      Address := Integer(ExceptionRecord.ExceptionAddress)-ImageBaseAddress-1;
      RoutineInfo := DebugInfo.SearchRoutineFromAddress(Address);
      if RoutineInfo<>nil then
        Text := Text + #13#10 + GetRoutineInfoText(RoutineInfo, Address) + #13#10;
    end;

    for i:=0 to TraceListCount-1 do
    begin
      RoutineInfo := DebugInfo.SearchRoutineFromAddress(TraceList[i]);
      if RoutineInfo=nil then Break;
      Text := Text + GetRoutineInfoText(RoutineInfo, TraceList[i]) + #13#10;
    end;

    for i:=Length(Text) to 1 do
      if not (Text[i] in [#13, #10]) then
      begin
        Text := Copy(Text, 1, i);
        Break;
      end;

    if Assigned(SetExceptMessageFunc) then
      SetExceptMessageFunc(Result, Text);

    {  ���O�ɋL�^����  }
    try
      if IsMultiThread then EnterCriticalSection(Lock);

      PutDebugLogHeader(TObject(Result).ClassName + ' ��O���������܂����B');
      PutDebugLog('');
      PutDebugLog(Text);
      PutDebugLogSep;
    finally
      if IsMultiThread then LeaveCriticalSection(Lock);
    end;
  finally
    ExceptObjProc := @MyGetExceptionObject;
  end;
end;

procedure MemCheckInstallExceptionHandler(GetExceptInfo: TMemCheckGetExceptInfoFunc;
  SetExceptMessage: TMemCheckSetExceptMessageFunc);
begin
  GetExceptInfoFunc := GetExceptInfo;
  SetExceptMessageFunc := SetExceptMessage;

  OldExceptObjProc := ExceptObjProc;
  ExceptObjProc := @MyGetExceptionObject;
end;

procedure AppStart;
var
  i: Integer;
  Flag: Boolean;
begin
  {  ���O�̃t�@�C�����擾  }
  DebugLogFileName := ParamStr(0);
  Flag := False;
  for i:=Length(DebugLogFileName) downto 1 do
  begin
    if DebugLogFileName[i]='.' then
    begin
      DebugLogFileName := Copy(DebugLogFileName, 1, i) + 'log';
      Flag := True;
      Break;
    end;
  end;
  if not Flag then
    DebugLogFileName := DebugLogFileName + '.log';

  {  ���O�o��  }
  PutDebugLogHeader('�v���O�������N�����܂����B');
  PutDebugLogSep;
end;

procedure AppExit;
var
  s: string;
  Block: PMemBlockHeader;
begin
  s := '';

  {  ���������[�N��񃌃|�[�g  }
  if GetMemCount>0 then
  begin
    PutDebugLogHeader(IntToStr(GetMemCount) + ' �񃁃����[��������Y��Ă��܂��B');
    PutDebugLog('');
    PutDebugLog('');

    Block := LastMemBlock;
    while Block<>nil do
    begin
      PutDebugLog(TraceMemBlockStackFrame(Block^));
      Block := Block.Right;
    end;

    PutDebugLogSep;

    if s<>'' then s := s + #13#13 + '---------------------------------------------------------' + #13#10;
    s := s + IntToStr(GetMemCount) + ' �񃁃����[��������Y��Ă��܂��B';

    FatalErrorFlag := True;
  end;

  PutDebugLogHeader('�v���O�������I�����܂����B');
  PutDebugLogSep;

  {  �x���\��  }
  if FatalErrorFlag then
  begin
    if s<>'' then s := s + #13#13 + '---------------------------------------------------------' + #13#10;
    s := s + '����̎g�p�Œv���I�ȃG���[(���������[�N�Ȃ�)�������������Ƃ�����܂��B' + #13#10#13#10;

    if DebugLogFileName<>'' then
      s := s + DebugLogFileName + ' ���J�����֑���ƌ����������ł���ꍇ������܂��B'
    else
      s := s + '�G���[�̃��O�� '+DebugLogFileName+' �ɏo�͂��悤�Ƃ��܂������o���܂���ł����B';

    if DebugLogFileName<>'' then
      MessageBox(0, PChar(s), '�x��', MB_OK or MB_ICONEXCLAMATION)
    else
      MessageBox(0, PChar(s), '�x��', MB_OK or MB_ICONEXCLAMATION);
  end;
end;

{$ELSE}

function NewGetMem(Size: Integer): Pointer;
begin
  Result := OldMemMgr.GetMem(Size);

  if Result<>nil then
  begin
    try
      if IsMultiThread then EnterCriticalSection(Lock);
      Inc(GetMemCount);
    finally
      if IsMultiThread then LeaveCriticalSection(Lock);
    end;
  end;
end;

function NewFreeMem(P: Pointer): Integer;
begin
  Result := OldMemMgr.FreeMem(P);

  if P<>nil then
  begin
    try
      if IsMultiThread then EnterCriticalSection(Lock);
      Dec(GetMemCount);
    finally
      if IsMultiThread then LeaveCriticalSection(Lock);
    end;
  end;
end;

function NewReallocMem(P: Pointer; Size: Integer): Pointer;
begin
  Result := OldMemMgr.ReallocMem(P, Size);

  if P<>Result then
  begin
    try
      if IsMultiThread then EnterCriticalSection(Lock);
      if P<>nil then Dec(GetMemCount);
      if Result<>nil then Inc(GetMemCount);
    finally
      if IsMultiThread then LeaveCriticalSection(Lock);
    end;
  end;
end;

procedure MemCheckInstallExceptionHandler(GetExceptInfo: TMemCheckGetExceptInfoFunc;
  SetExceptMessage: TMemCheckSetExceptMessageFunc);
begin
end;

{$ENDIF}

const
  NewMemMgr: TMemoryManager = (
  GetMem: NewGetMem;
  FreeMem: NewFreeMem;
  ReallocMem: NewReallocMem);

initialization
  InitializeCriticalSection(Lock);

{$IFDEF MemCheckStackTrace}
  InitImageBaseAddress;
  LoadDebugInfo;
{$ENDIF}

  GetMemoryManager(OldMemMgr);
  SetMemoryManager(NewMemMgr);

{$IFDEF MemCheckStackTrace}
  AppStart;
{$ENDIF}
finalization
  SetMemoryManager(OldMemMgr);

{$IFDEF MemCheckStackTrace}
  AppExit;
  UnLoadDebugInfo;
  DebugInfo.Free;
{$ELSE}
  if GetMemCount>0 then
    MessageBox(0, PChar(IntToStr(GetMemCount)+' �񃁃����[��������Y��Ă��܂�'), '�������[���[�N�G���[', MB_OK or MB_ICONEXCLAMATION);
{$ENDIF}

  DeleteCriticalSection(Lock);

{$IFDEF MemCheckStackTrace}
  EndPutDebugLog;
{$ENDIF}
end.



