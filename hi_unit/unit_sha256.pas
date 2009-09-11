// SHA256
// General Function Library  Copyright (C) 2000,2001 SYN All Rights Reserved.
// Delphi Code Ko-Ta
//
// original name - unit uSha256
//
//コンパイルオプション
{$OVERFLOWCHECKS OFF}

unit unit_sha256;

interface

uses SysUtils,Classes;

type
  DWORD=Cardinal;
  PBYTE=^BYTE;
  PDWORD=^DWORD;
  
const
  SHA256_HASH=8;
  SHA256_BLOCK=16;
  SHA256_WORK=64;
  SHA256_BUFFER_SIZE=SHA256_BLOCK*4;

const
  c_dwInitH:array[0..SHA256_HASH-1] of DWORD = (
    $6a09e667, $bb67ae85, $3c6ef372, $a54ff53a, $510e527f, $9b05688c, $1f83d9ab, $5be0cd19
  );
  c_dwK:array[0..SHA256_WORK-1] of DWORD = (
    $428a2f98, $71374491, $b5c0fbcf, $e9b5dba5, $3956c25b, $59f111f1, $923f82a4, $ab1c5ed5,
    $d807aa98, $12835b01, $243185be, $550c7dc3, $72be5d74, $80deb1fe, $9bdc06a7, $c19bf174, 
    $e49b69c1, $efbe4786, $0fc19dc6, $240ca1cc, $2de92c6f, $4a7484aa, $5cb0a9dc, $76f988da, 
    $983e5152, $a831c66d, $b00327c8, $bf597fc7, $c6e00bf3, $d5a79147, $06ca6351, $14292967, 
    $27b70a85, $2e1b2138, $4d2c6dfc, $53380d13, $650a7354, $766a0abb, $81c2c92e, $92722c85, 
    $a2bfe8a1, $a81a664b, $c24b8b70, $c76c51a3, $d192e819, $d6990624, $f40e3585, $106aa070, 
    $19a4c116, $1e376c08, $2748774c, $34b0bcb5, $391c0cb3, $4ed8aa4a, $5b9cca4f, $682e6ff3, 
    $748f82ee, $78a5636f, $84c87814, $8cc70208, $90befffa, $a4506ceb, $bef9a3f7, $c67178f2
  );

type
  TSHA256Table=packed record
    x : array[0..SHA256_HASH-1] of DWORD;
  end;

type TSha256=class
  protected
    m_dwH:array [0..SHA256_HASH-1] of DWORD;
    m_dwLNumBits:DWORD;
    m_dwHNumBits:DWORD;
    m_aBlock:array [0..SHA256_BLOCK-1] of DWORD;
    m_nNumChr:DWORD;

    procedure Generate;
    function  ReverseEndian(x: DWORD): DWORD;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure   Init;
    procedure   Load(pBuffer:PBYTE; dwSIze:DWORD);
    procedure   Final;
    function    GetDigest:String;
    function    GetTable:TSHA256Table;
  end;

//関数
function _GetSHA256(ss:TStream; size:INT64):String; overload;
function _GetSHA256(ptr:Pointer; size:DWORD):String; overload;
function _GetSHA256(str: string): String; overload;

implementation

function _GetSHA256(ss:TStream; size:INT64):String;
const _MoveSize=1024*1024*2;
var
  ms : TMemoryStream;
  SHA256 : TSHA256;
  s,rs : Integer;
  ptr : PBYTE;
begin
  RESULT := '';
  if (size<0)then exit;

  ms := TmemoryStream.Create;
  ms.SetSize(_MoveSize);
  ptr := ms.Memory;

  SHA256 := TSHA256.Create;
  SHA256.Init;

  s := size;
  while (s>0)do
  begin
    if (s<_MoveSize)then
      rs := s
    else
      rs := _MoveSize;

    ss.Read(ptr^,rs);
    SHA256.Load(ptr,rs);

    s := s - rs;
  end;

  SHA256.Final;
  RESULT := SHA256.GetDigest;
  SHA256.Free;

  ms.Free;
end;

function _GetSHA256(ptr:Pointer; size:DWORD):String;
const _MoveSize=1024*1024;
var
  SHA256 : TSHA256;
begin
  RESULT := '';
  if (size=0)then exit;

  SHA256 := TSHA256.Create;
  SHA256.Init;
  SHA256.Load(ptr,size);
  SHA256.Final;
  RESULT := SHA256.GetDigest;
  SHA256.Free;
end;

function _GetSHA256(str: string): String; overload;
const _MoveSize=1024*1024;
var
  SHA256 : TSHA256;
begin
  RESULT := '';
  if (str='')then exit;

  SHA256 := TSHA256.Create;
  SHA256.Init;
  SHA256.Load(PBYTE(str), Length(str));
  SHA256.Final;
  RESULT := SHA256.GetDigest;
  SHA256.Free;
end;



{ TSha256 }

constructor TSha256.Create;
begin
  Init;
end;

destructor TSha256.Destroy;
begin

end;

procedure TSha256.Final;
var
  cZero,cOne : BYTE;
  dwHNumBits,dwLNumBits : DWORD;
begin
  cZero := $00;
  cOne  := $80;

  dwHNumBits := ReverseEndian(m_dwHNumBits);
  dwLNumBits := ReverseEndian(m_dwLNumBits);

  Load(@cOne, 1);
  while (m_nNumChr <> SHA256_BUFFER_SIZE - 8)do Load(@cZero, 1);

  Load(PBYTE(@dwHNumBits), 4);
  Load(PBYTE(@dwLNumBits), 4);
end;

procedure TSha256.Generate;
  function s0(x:DWORD):DWORD;
  asm
    //RESULT := Rotate(x,2) xor Rotate(x,13) xor Rotate(x,22);
    mov eax,x;   //※ eax=xのため省略可。

    mov ecx,eax;  mov edx,eax;
    ror eax,2;    ror ecx,13;    ror edx,22;
    xor eax,ecx;
    xor eax,edx;
  end;
  function s1(x:DWORD):DWORD;
  asm
    //RESULT := Rotate(x,6) xor Rotate(x,11) xor Rotate(x,25);
    mov eax,x;   //※ eax=xのため省略可。

    mov ecx,eax;  mov edx,eax;
    ror eax,6;    ror ecx,11;    ror edx,25;
    xor eax,ecx;
    xor eax,edx;
  end;
  function ss0(x:DWORD):DWORD;
  asm
    //RESULT := Rotate(x,7) xor Rotate(x,18) xor (x shr 3);
    mov eax,x;   //※ eax=xのため省略可。

    mov ecx,eax;  mov edx,eax;
    ror eax,7;    ror ecx,18;    shr edx,3;
    xor eax,ecx;
    xor eax,edx;
  end;
  function ss1(x:DWORD):DWORD;
  asm
    //RESULT := Rotate(x,17) xor Rotate(x, 19) xor (x shr 10);
    mov eax,x;   //※ eax=xのため省略可。

    mov ecx,eax;  mov edx,eax;
    ror eax,17;   ror ecx,19;    shr edx,10;
    xor eax,ecx;
    xor eax,edx;
  end;
  function Ch(x,y,z:DWORD):DWORD;
  asm
    //RESULT := (x and (y xor z)) xor z;
    mov eax,x;  //※ eax=x/edx=y/ecx=zのため省略可。
    mov edx,y;
    mov ecx,z;

    xor edx,ecx;
    and eax,edx;
    xor eax,ecx;
  end;
  function Maj(x,y,z:DWORD):DWORD;
  asm
    //RESULT := (x and (y or z)) or (y and z);
    mov eax,x;  //※ eax=x/edx=y/ecx=zのため省略可。
    mov edx,y;
    mov ecx,z;
    
    push ebx;
    mov  ebx,edx;
    or   edx,ecx;  and  ebx,ecx;
    and  eax,edx;
    or   eax,ebx;
    pop  ebx;
  end;
type
  THashRecord=array[0..15] of DWORD;
  PHashRecord=^THashRecord;
var
  i : Integer;
  W : array[0..SHA256_WORK-1] of DWORD;
  Hash : array[0..SHA256_WORK + SHA256_HASH - 1] of DWORD;
  pHash : PDWORD;
  pHashRec : PHashRecord;
  dwT1, dwT2 : DWORD;
begin
  for i:=0 to SHA256_BLOCK-1 do
    W[i] := ReverseEndian(m_aBlock[i]);

  for i:=SHA256_BLOCK to SHA256_WORK-1 do
    W[i] := ss1(W[i - 2]) + W[i - 7] + ss0(W[i - 15]) + W[i - 16];

  for i:=0 to SHA256_HASH-1 do
    Hash[SHA256_WORK + i] := m_dwH[i];
  
  pHash := @Hash[SHA256_WORK];
  for i:=0 to SHA256_WORK-1 do
  begin
    dec(pHash);  //pHash--;
    pHashRec := PHashRecord(pHash);

    dwT1 := pHashRec^[8] + s1(pHashRec^[5]) + Ch(pHashRec^[5], pHashRec^[6], pHashRec^[7]) + c_dwK[i] + W[i];
    dwT2 := s0(pHashRec^[1]) + Maj(pHashRec^[1], pHashRec^[2], pHashRec^[3]);
    pHashRec^[0] := dwT1 + dwT2;
    pHashRec^[4] := pHashRec^[4] + dwT1;
  end;

  pHashRec := PHashRecord(pHash);
  for i:=0 to SHA256_HASH-1 do
    m_dwH[i] := m_dwH[i] + pHashRec[i];
end;

function TSha256.GetDigest: String;
var
  i : Integer;
begin
  RESULT := '';
  for i:=0 to SHA256_HASH-1 do
    RESULT := RESULT + IntToHex(m_dwH[i],8);
end;

function TSha256.GetTable: TSHA256Table;
var
  i : Integer;
begin
  for i:=0 to SHA256_HASH-1 do
    RESULT.x[i] := m_dwH[i];
end;

procedure TSha256.Init;
var
  i : Integer;
begin
  for i:=0 to SHA256_HASH-1 do
    m_dwH[i] := c_dwInitH[i];

  m_dwLNumBits := 0;
  m_dwHNumBits := 0;
  m_nNumChr := 0;
end;

procedure TSha256.Load(pBuffer: PBYTE; dwSIze: DWORD);
var
  dwLNumBits,dwReadSize:DWORD;
  pBlock:PBYTE;
  s : DWORD;
begin
  if (dwSize=0)then exit;

  dwLNumBits := (m_dwLNumBits + (dwSize shl 3));

  if(dwLNumBits < m_dwLNumBits)then m_dwHNumBits := m_dwHNumBits + 1;
  m_dwHNumBits := m_dwHNumBits + (dwSize shr 29);
  m_dwLNumBits := dwLNumBits;

  pBlock := @m_aBlock[0];

  while(dwSize > 0)do
  begin
    s := SHA256_BUFFER_SIZE - m_nNumChr;
    if (dwSize < s)then
      dwReadSize := dwSize
    else
      dwReadSize := s;

    move(pBuffer^,PBYTE(DWORD(pBlock)+m_nNumChr)^,dwReadSize);

    m_nNumChr := m_nNumChr + dwReadSize;
    inc(pBuffer,dwReadSize);
    dwSize := dwSize - dwReadSize;

    if(m_nNumChr = SHA256_BUFFER_SIZE)then
    begin
      Generate;
      m_nNumChr:=0;
    end;
  end;
end;

function TSha256.ReverseEndian(x: DWORD): DWORD;
asm
  //RESULT := (x shl 24) or ((x and $0000ff00) shl 8) or ((x and $00ff0000) shr 8) or (x shr 24);
  mov  eax,x;      //※ eax=xのため省略可。

  //a1=(x shl 24) or (x shr 24)
  mov ecx,eax;  mov edx,eax;
  shl ecx,24;   shr edx,24;
  or  ecx,edx;

  //a2=((x and $0000ff00) shl 8) or ((x and $00ff0000) shr 8)
                      mov edx,eax;
  and eax,$0000FF00;  and edx,$00FF0000;
  shl eax,8;          shr edx,8;
  or  eax,edx;

  //RESULT=a2 or a1
  or  eax,ecx;
end;

end.
