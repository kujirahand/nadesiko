{
 A portion for MT19937 to delphi base on mt19937ar.c, please read
 the original description:
/* A C-program for MT19937, with initialization improved 2002/1/26.*/
/* Coded by Takuji Nishimura and Makoto Matsumoto.                 */

/* Before using, initialize the state by using init_genrand(seed)  */
/* or init_by_array(init_key, key_length).                         */

/* This library is free software.                                  */
/* This library is distributed in the hope that it will be useful, */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of  */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.            */

/* Copyright (C) 1997, 2002 Makoto Matsumoto and Takuji Nishimura. */
/* Any feedback is very welcome.                                   */
/* http://www.math.keio.ac.jp/matumoto/emt.html                    */
/* email: matumoto@math.keio.ac.jp                                 */
here is a example show how to use the object :
procedure TForm1.Button3Click(Sender: TObject);
var
  i: integer;
  x: Tmt19937;
begin
  x:=Tmt19937.Create([$123,$234,$345,$456]);
  //x:=Tmt19937.Create(19650218);
  for i:=1 to 1000 do Memo1.Lines.Add(IntTostr(x.val32));
  for i:=1 to 1000 do Memo1.Lines.Add(floatTostr(x.real2));
  x.Free;
end;
}
unit mt19937; // íuÇ´ä∑Ç¶ Random ä÷êî
{$Q-}{$R-}
interface
const
  fmask=$ffffffff;
  Upper_Mask=$80000000;
  Lower_mask=$7fffffff;
  mag01 : array[0..1] of cardinal=(0,$9908b0df);
  N=624;
type
  Tmt19937 = class(TObject)
{ private methods }
private
  M, mti  : smallint;
  Mt   : array[0..N-1] of cardinal;
  firsttime : boolean;
{ public methods }
public
  constructor Create(s: cardinal); overload;
  constructor Create(init_key: array of cardinal); overload;
  procedure init_genrand(s:cardinal);
  procedure init_by_ary(init_key: array of cardinal);
  procedure Randomize(seed: cardinal = 0); // ìKìñÇ…èâä˙âªÇµÇƒÇ≠ÇÍÇÈä÷êî
  function  val32 : cardinal;
  function  val31 : longint;
  function  real1 : double;
  function  real2 : double;
  function  real3 : double;
  function  res53 : double;
  function Random(N: Longint): Longint;
end;

// singleton support by mine.kujira (http://nadesi.com)
function RandomMT: Tmt19937;

implementation

// for singleton
uses
{$IFDEF Win32}
  Windows
{$ELSE}
  sysutils
{$ENDIF}
;

var Fmt19937: Tmt19937 = nil;

function MT19937RandomizeValue: Cardinal;
{$IFDEF Win32}
var
  Counter: Int64;
begin
  if QueryPerformanceCounter(Counter) then
    Result := Counter
  else
    Result := GetTickCount;
end;
{$ELSE}
begin
  Result := GetTickCount64();
end;
{$ENDIF}

function RandomMT: Tmt19937;
begin
  if Fmt19937 = nil then Fmt19937 := Tmt19937.Create(MT19937RandomizeValue);
  Result := Fmt19937;
end;


{ initialize the objet with a zeroed seed }
procedure Tmt19937.init_genrand(s:cardinal);
begin
  Mt[0]:=s and fmask;
  mti:=1;
  while mti< N Do
  begin
    Mt[mti]:=(1812433253*(Mt[mti-1] xor (Mt[mti-1] shr 30))+Cardinal(mti));
    Mt[mti]:=Mt[mti] and fmask;
    inc(mti);
  end;
end;

procedure Tmt19937.init_by_ary;
var
  i,j,k,key_length : smallint;
begin
  if firsttime then init_genrand(19650218);
  i:=1;
  j:=0;
  key_length:=high(init_key)+1;
  k:=key_length;
  if N>k then k:=N;
  while k>0 Do
  begin
    Mt[i]:=(Mt[i] xor ((Mt[i-1] xor (Mt[i-1] shr 30))*1664525))+init_key[j]+Cardinal(j);
    Mt[i]:=Mt[i] and fmask;
    inc(i);
    inc(j);
    if i>=N then
    begin
      Mt[0]:=Mt[N-1];
      i:=1;
    end;
    if j>=key_length then j:=0;
    k:=k-1;
  end;
  k:=N-1;
  while K>0 Do
  begin
    Mt[i]:=(Mt[i] xor ((Mt[i-1] xor (Mt[i-1] shr 30))*1566083941))-Cardinal(i);
    Mt[i]:=Mt[i] and fmask;
    i:=i+1;
    if (i>=N) then
    begin
      Mt[0]:=Mt[N-1];
      i:=1;
    end;
    k:=k-1;
  end;
  Mt[0]:=$80000000;
end;

constructor Tmt19937.Create(s: cardinal);
begin
  M:=397;
  mti:=M+1;
  firsttime:=true;
  init_genrand(s);
end;

constructor Tmt19937.Create(init_key: array of cardinal);
begin
  create(19650218);
  firsttime:=false;
  init_by_ary(init_key);
  firsttime:=true;
end;

function Tmt19937.val32;
var
  y : cardinal;
  kk : integer;

begin
  if mti>=N  then
  begin
    if mti=(N+1) then init_genrand(5489);
    for kk:=0 to N-M-1 do
    begin
      y:=(Mt[kk] and Upper_Mask) or (Mt[kk+1] and Lower_mask);
      Mt[kk]:=Mt[kk+M] xor (y shr 1) xor mag01[y and 1];
    end;
    kk := N-M-1;
    while kk<n-1 do
    begin
      y:=(Mt[kk] and Upper_Mask) or (Mt[kk+1] and Lower_mask);
      Mt[kk]:=Mt[kk+(M-N)] xor (y shr 1) xor mag01[y and 1];
      kk:=kk+1;
    end;
    y:=(Mt[N-1] and Upper_Mask) or (Mt[0] and Lower_mask);
    Mt[N-1]:=Mt[M-1] xor (y shr 1) xor mag01[y and 1];
    mti:=0;
  end;

  y:=Mt[mti];
  mti:=mti+1;
  y:=y xor (y shr 11);
  y:=y xor ((y shl 7) and $9d2c5680);
  y:=y xor ((y shl 15) and $efc60000);
  y:=y xor (y shr 18);
  result:=y;
end;
function Tmt19937.val31 : Longint;
begin
  result:=val32 shr 1;
end;
function Tmt19937.real1;
begin
  result:=val32*(1.0/4294967295.0);
end;
function Tmt19937.real2;
begin
  result:=val32*(1.0/4294967296.0);
end;
function Tmt19937.real3;
begin
  result:=(val32+0.5)*(1.0/4294967296.0);
end;
function Tmt19937.res53;
var
  a,b : cardinal;
begin
  a:=val32 shr 5;
  b:=val32 shr 6;
  result:=(a*67108864.0+b)*(1.0/9007199254740992.0);
end;

procedure Tmt19937.Randomize(seed: cardinal);
begin
  if seed = 0 then
  begin
    init_genrand(MT19937RandomizeValue)
  end else
  begin
    init_genrand(seed);
  end;
end;

function Tmt19937.Random(N: Integer): Longint;
begin
  if N <> 0 then
  begin
    Result := (val31 mod N); // ä€ÇﬂÇƒÇµÇ‹Ç§
  end else
  begin
    Result := 0;
  end;
end;

initialization

finalization
  if Fmt19937 <> nil then Fmt19937.Free;

end.
