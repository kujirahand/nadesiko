unit CommonMemoryUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Dialogs;

type
TCommonMemory = class(TObject)
private
  FMemPtr:pointer;
  FSize:integer;
protected
  procedure Open(AllocSize:integer);virtual;abstract;
  procedure Close;virtual;abstract;
public
  constructor Create(hTarget:HWND;AllocSize:integer);virtual;abstract;
  procedure ZeroClear;virtual;abstract;
  procedure Write(offset:integer;Source:pointer;Length:integer);virtual;abstract;
  procedure Read(offset:integer;Destination:pointer;Length:integer);virtual;abstract;
  procedure ReOpen(ReAllocSize:integer);virtual;abstract;
  property MemPtr:pointer read FMemPtr;
  property Size:integer read FSize;
end;

function GetCommonMemory(hTarget:HWND;AllocSize:integer):TCommonMemory;

implementation

//------------------------------------------------------

type
TCommMemNT = class(TCommonMemory)
private
  FhProcess:THandle;
  FdwProcessId:DWORD;
protected
  procedure Open(AllocSize:integer);override;
  procedure Close;override;
public
  constructor Create(hTarget:HWND;AllocSize:integer);override;
  destructor Destroy;override;
  procedure ZeroClear;override;
  procedure Write(offset:integer;Source:pointer;Length:integer);override;
  procedure Read(offset:integer;Destination:pointer;Length:integer);override;
  procedure ReOpen(ReAllocSize:integer);override;
end;

//------------------------------------------------------

TCommMem9X = class(TCommonMemory)
private
  FHandle:THandle;
protected
  procedure Open(AllocSize:integer);override;
  procedure Close;override;
public
  constructor Create(hTarget:HWND;AllocSize:integer);override;
  destructor Destroy;override;
  procedure ZeroClear;override;
  procedure Write(offset:integer;Source:pointer;Length:integer);override;
  procedure Read(offset:integer;Destination:pointer;Length:integer);override;
  procedure ReOpen(ReAllocSize:integer);override;
end;

//------------------------------------------------------

function GetCommonMemory(hTarget:HWND;AllocSize:integer):TCommonMemory;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    result := TCommMemNT.Create(hTarget,AllocSize)
  else
    result := TCommMem9X.Create(hTarget,AllocSize);
end;

//------------------------------------------------------

{ TCommMemNT }

constructor TCommMemNT.Create(hTarget: HWND; AllocSize: integer);
begin
  GetWindowThreadProcessId(hTarget,@FdwProcessId);
  FhProcess := OpenProcess(PROCESS_VM_OPERATION or PROCESS_VM_READ or
                          PROCESS_VM_WRITE,false,FdwProcessId);
  Open(AllocSize);
  FSize := AllocSize;
end;

destructor TCommMemNT.Destroy;
begin
  Close;
  CloseHandle(FhProcess);
  inherited;
end;

procedure TCommMemNT.Open(AllocSize: integer);
type
  TFuncAlloc = function (hProcess: THandle; lpAddress: Pointer;
      dwSize, flAllocationType: DWORD; flProtect: DWORD): Pointer; stdcall;
var
  Handle:THandle;
  FuncAlloc:TFuncAlloc;
begin
  Handle := LoadLibrary('kernel32.dll');
  @FuncAlloc := GetProcAddress(Handle,'VirtualAllocEx');


  FMemPtr := FuncAlloc(FhProcess,nil,AllocSize,
                           MEM_RESERVE or MEM_COMMIT,PAGE_READWRITE);

  FreeLibrary(Handle);
end;

procedure TCommMemNT.Close;
type
  TFuncFree = function (hProcess: THandle; lpAddress: Pointer;
                           dwSize, dwFreeType: DWORD): Pointer; stdcall;
var
  Handle:THandle;
  FuncFree:TFuncFree;
begin
  Handle := LoadLibrary('kernel32.dll');
  @FuncFree := GetProcAddress(Handle,'VirtualFreeEx');

  FuncFree(FhProcess,FMemPtr,0,MEM_RELEASE);

  FreeLibrary(Handle);
end;

procedure TCommMemNT.ReOpen(ReAllocSize: integer);
var
  ptr:pointer;
begin
  GetMem(ptr,FSize);
  Read(0,ptr,FSize);
  Close;
  Open(ReAllocSize);
  if FSize <= ReAllocSize then
    Write(0,ptr,FSize)
  else
    Write(0,ptr,ReAllocSize);
  FreeMem(ptr);
  FSize := ReAllocSize;
end;

procedure TCommMemNT.Read(offset: integer; Destination: pointer;
                                                      Length: integer);
var
  numRead:DWORD;
begin
  if (offset+Length)>FSize then begin
    ShowMessage('読み込み範囲がサイズを超えています');
    exit;
  end;

  ReadProcessMemory(FhProcess,pointer(integer(FMemPtr)+offset),Destination,
                                                              Length,numRead);
end;


procedure TCommMemNT.Write(offset: integer; Source: pointer;
                                                    Length: integer);
var
  numWrite:DWORD;
begin
  if (offset+Length)>FSize then begin
    ShowMessage('書き込み範囲がサイズを超えています');
    exit;
  end;

  WriteProcessMemory(FhProcess,pointer(integer(FMemPtr)+offset),Source,
                                                           Length,numWrite);
end;

procedure TCommMemNT.ZeroClear;
var
  ptr:pointer;
begin
  GetMem(ptr,FSize);
  ZeroMemory(ptr,FSize);
  Write(0,ptr,FSize);
  FreeMem(ptr);
end;

//------------------------------------------------------

{ TCommMem9X }

constructor TCommMem9X.Create(hTarget:HWND;AllocSize: integer);
begin
  Open(AllocSize);
  FSize := AllocSize;
end;

destructor TCommMem9X.Destroy;
begin
  Close;
  inherited;
end;

procedure TCommMem9X.ZeroClear;
begin
  ZeroMemory(FMemPtr,FSize);
end;

procedure TCommMem9X.Open(AllocSize: integer);
begin
  FHandle := CreateFileMapping($FFFFFFFF,nil,PAGE_READWRITE,0,AllocSize,nil);
  FMemPtr := MapViewOfFile(FHandle,FILE_MAP_ALL_ACCESS,0,0,0);
end;

procedure TCommMem9X.Close;
begin
  UnmapViewOfFile(FMemPtr);
  CloseHandle(FHandle);
  FHandle := 0;
end;

procedure TCommMem9X.ReOpen(ReAllocSize: integer);
var
  ptr:pointer;
begin
  if FHandle = 0 then
    Open(ReAllocSize)
  else begin
    GetMem(ptr,FSize);
    CopyMemory(ptr,FMemPtr,FSize);
    Close;
    Open(ReAllocSize);
    if FSize <= ReAllocSize then
      CopyMemory(FMemPtr,ptr,FSize)
    else
      CopyMemory(FMemPtr,ptr,ReAllocSize);
    FreeMem(ptr);
    FSize := ReAllocSize;
  end;
end;

procedure TCommMem9X.Read(offset: integer; Destination: pointer;Length: integer);
begin
  if (offset+Length)>FSize then begin
    ShowMessage('読み込み範囲がサイズを超えています');
    exit;
  end;

  CopyMemory(Destination,pointer(integer(FMemPtr)+offset),Length);
end;

procedure TCommMem9X.Write(offset: integer; Source: pointer;Length: integer);
begin
  if (offset+Length)>FSize then begin
    ShowMessage('書き込み範囲がサイズを超えています');
    exit;
  end;

  CopyMemory(pointer(integer(FMemPtr)+offset),Source,Length);
end;

end.
