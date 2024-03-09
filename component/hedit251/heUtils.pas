(*********************************************************************

  heUtils.pas

  start  2001/03/17
  update 2003/11/28

  Copyright (c) 1998,2003 本田勝彦 <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  TEditor で利用される関数・手続き群と定数及び変数が記述されている

**********************************************************************)

unit heUtils;

{$I heverdef.inc}

interface

{$R HEDITOR}

uses
  SysUtils, Windows, Classes, Controls, Forms, Graphics, heClasses;

const
  RightArrowCursorIdent = 'crRightArrow';
  RightArrowCursorResourceIdent = 'RightArrow';
  DragSelCopyCursorIdent = 'crDragSelCopy';
  DragSelCopyCursorResourceIdent = 'DragSelCopy';

var
  crRightArrow: TCursor = (1958);
  crDragSelCopy: TCursor = (1959);

  CF_BOXTEXT: Word; // RegisterClipboardFormat('TEditor Box Type'); cf Initialization section

  MailChars: TCharSet = ['!', '$'..'&', '*', ','..'9', ';', '=', '?'..'Z', '^'..'_', 'a'..'z', '~'];
  UrlChars: TCharSet = ['#', '%', '&', '+', '-', '.', '/', '0'..'9', ':', '=', '?', 'A'..'Z', '_', 'a'..'z', '~'];

  {$IFDEF COMP2}
  LeadBytes: set of Char = [#$81..#$9F, #$E0..#$FC];
  {$ENDIF}

type
  TDefaultMarkRange = 0..15;

const
  DefaultMarkIdents: array[TDefaultMarkRange] of PChar =
    ('DD00', 'DD01', 'DD02', 'DD03','DD04', 'DD05', 'DD06', 'DD07',
     'DD08', 'DD09', 'DM00', 'DM01','DM02', 'DM03', 'DM04', 'DM05');

  DefaultDigitWidth = 8;
  DefaultDigitHeight = 11;
  DefaultMarkWidth = 11;
  DefaultMarkHeight = 11;

var
  DefaultDigits: TImageList;
  DefaultMarks: TImageList;

(*
  AnsiCopy .......... Copy の２バイト対応版
  AnsiCopyE ......... AnsiCopy その２（TEditor 矩形選択領域仕様）
  AnsiCopyW ......... AnsiCopy その３
  AnsiDelete ........ Delete の２バイト対応版
  AnsiDeleteE ....... AnsiDelete その２（TEditor 矩形選択領域仕様）
  AnsiDeleteW ....... AnsiDelete その３
  CharSetToStr ...... TCharSet を 文字列に変換する
  IndexChar ......... 文字列上の Index にある１文字を返す
  IncludeCharCount .. 文字列 S 内の Index 文字目までに存在する C の数を返す
  IsDBCS1 ........... S の Index 番目が全角１バイト目かどうかの判別
  IsDBCS2 ........... S の Index 番目が全角２バイト目かどうかの判別
  IsInclude ......... SubStr が S 内に存在するかどうかを返す（大文字小文字を区別する）
  IsMail ............ 文字列 S の中に MailChars で構成される文字列とそれに
                      続く @ . のパターンがあった場合に真を返す。
                      StartPos には発見した位置、StrLength には長さが入る
  IsUrl ............. 文字列 S の中に 'http:', 'https:', 'ftp:', 'www.' を
                      含む文字列があった場合真を返す
                      StartPos には発見した位置、StrLength には長さが入る
  Max ............... 大きい方の値を返す
  Min ............... 小さい方の値を返す
  StrToCharSet ...... 文字列を TCharSet に変換する。全角文字は無視される
  StrToStrings ...... 文字列 Value を #13#10 で切り分けて Strings に格納する
  TabbedTrimRight ... タブを取り除かない TrimRight
  TopSpace .......... 文字列の前の部分のスペース数を返す。全角スペースも
                      カウントする。文字列が '' の場合は -1 を返す。
  TrimLeftDBCS ...... 全角スペースも取り除く TrimLeft
  ChangeStrings ..... Dest の Index から Dr 行を削除して Index へ
                      Source を挿入する
  DeleteStrings ..... Strings の Index から Count 行を削除する
  InsertStrings ..... Dest の Index へ Source を挿入する

  HCursorToString ... 'crRightArrow', 'crDragSelCopy' を返す CursorToString
  HStringToCursor ... crRightArrow, crDragSelCopy を返す StringToCursor
  HGetCursorValues .. 'crRightArrow', 'crDragSelCopy' も渡してくれる GetCursorValues

  DrawDotLine ....... １点破線を描画する。
*)

function AnsiCopy(S: String; var Index, Count: Integer): String;
function AnsiCopyE(S: String; var Index, Count: Integer): String;
function AnsiCopyW(S: String; var Index, Count: Integer): String;
function AnsiDelete(var S: String; Index, Count: Integer): Integer;
function AnsiDeleteE(var S: String; Index, Count: Integer): Integer;
function AnsiDeleteW(var S: String; Index, Count: Integer): Integer;
function CharSetToStr(CharSet: TCharSet): String;
function IncludeCharCount(S: String; C: Char; Index: Integer): Integer;
function IndexChar(S: String; Index: Integer): Char;
function IsDBCS1(S: String; Index: Integer): Boolean;
function IsDBCS2(S: String; Index: Integer): Boolean;
function IsInclude(Substr: String; S: String): Boolean;
function IsMail(const S: String; var StartPos, StrLength: Integer): Boolean;
function IsUrl(const S: String; var StartPos, StrLength: Integer): Boolean;
function Max(X, Y: Integer): Integer;
function Min(X, Y: Integer): Integer;
function StrToCharSet(const S: String): TCharSet;
procedure StrToStrings(const Value: String; Strings: TStrings);
function TabbedTrimRight(const S: String): String;
function TopSpace(S: String): Integer;
function TrimLeftDBCS(const S: String): String;
procedure ChangeStrings(Source, Dest: TStrings; Index, Dr: Integer);
procedure DeleteStrings(Strings: TStrings; Index, Count: Integer);
procedure InsertStrings(Source, Dest: TStrings; Index: Integer);

function HCursorToString(Cursor: TCursor): string;
function HStringToCursor(const S: string): TCursor;
procedure HGetCursorValues(Proc: TGetStrProc);

procedure DrawDotLine(Canvas: TCanvas; SX, Y, EX: Integer; Color, BkColor: TColor);

implementation


{$IFDEF COMP4_UP}
uses
  ImgList; // for rtBitmap
{$ENDIF}


function AnsiCopy(S: String; var Index, Count: Integer): String;
(*
  Copy の２バイト文字対応版
  Index が全角文字の２バイト目の場合は１つ進める
  Index + Count - 1 が全角１バイト目の場合は１つ戻す
  Index..Index + Count - 1 が 1..Length(S) と重なった部分だけを
  処理する
*)
var
  L, LastIndex: Integer;
begin
  Result := '';
  L := Length(S);
  LastIndex := Index + Count - 1;
  if ((Index < 1) and (LastIndex < 1)) or
     ((L < Index) and (L < LastIndex)) then
    Exit;
  if IsDBCS2(S, Index) then
    Inc(Index);
  if IsDBCS1(S, LastIndex) then
    Dec(LastIndex);
  Count := Max(0, LastIndex - Index + 1);
  Result := Copy(S, Index, Count);
end;

function AnsiCopyE(S: String; var Index, Count: Integer): String;
(*
  Copy の２バイト文字対応版その２（TEditor 矩形選択領域仕様）
  Index が全角文字の２バイト目の場合は１つ進める
  Index + Count - 1 が全角１バイト目の場合は１つ進める
  Index..Index + Count - 1 が 1..Length(S) と重なった部分だけを
  処理する
*)
var
  L, LastIndex: Integer;
begin
  Result := '';
  L := Length(S);
  LastIndex := Index + Count - 1;
  if ((Index < 1) and (LastIndex < 1)) or
     ((L < Index) and (L < LastIndex)) then
    Exit;
  if IsDBCS2(S, Index) then
    Inc(Index);
  if IsDBCS1(S, LastIndex) then
    Inc(LastIndex);
  Count := Max(0, LastIndex - Index + 1);
  Result := Copy(S, Index, Count);
end;

function AnsiCopyW(S: String; var Index, Count: Integer): String;
(*
  Copy の２バイト文字対応版その３
  Index が全角文字の２バイト目の場合は１つ戻す
  Index + Count - 1 が全角１バイト目の場合は１つ進める
  Index..Index + Count - 1 が 1..Length(S) と重なった部分だけを
  処理する
*)
var
  L, LastIndex: Integer;
begin
  Result := '';
  L := Length(S);
  LastIndex := Index + Count - 1;
  if ((Index < 1) and (LastIndex < 1)) or
     ((L < Index) and (L < LastIndex)) then
    Exit;
  if IsDBCS2(S, Index) then
    Dec(Index);
  if IsDBCS1(S, LastIndex) then
    Inc(LastIndex);
  Count := Max(0, LastIndex - Index + 1);
  Result := Copy(S, Index, Count);
end;

function AnsiDelete(var S: String; Index, Count: Integer): Integer;
(*
  Delete の２バイト文字対応版
  Index が全角文字の２バイト目の場合は１つ進める
  Index + Count - 1 が全角１バイト目の場合は１つ戻す
  Index..Index + Count - 1 が 1..Length(S) と重なっている部分だけを
  削除する
*)
var
  L, LastIndex: Integer;
begin
  Result := 0;
  L := Length(S);
  LastIndex := Index + Count - 1;
  if ((Index < 1) and (LastIndex < 1)) or
     ((L < Index) and (L < LastIndex)) then
    Exit;
  if IsDBCS2(S, Index) then
    Inc(Index);
  if IsDBCS1(S, LastIndex) then
    Dec(LastIndex);
  Result := Max(0, LastIndex - Index + 1);
  if 0 < Result then
    Delete(S, Index, Result);
end;

function AnsiDeleteE(var S: String; Index, Count: Integer): Integer;
(*
  Delete の２バイト文字対応版その２（TEditor 矩形選択領域仕様）
  Index が全角文字の２バイト目の場合は１つ進める
  Index + Count - 1 が全角１バイト目の場合は１つ進める
  Index..Index + Count - 1 が 1..Length(S) と重なっている部分だけを
  削除する
*)
var
  L, LastIndex: Integer;
begin
  Result := 0;
  L := Length(S);
  LastIndex := Index + Count - 1;
  if ((Index < 1) and (LastIndex < 1)) or
     ((L < Index) and (L < LastIndex)) then
    Exit;
  if IsDBCS2(S, Index) then
    Inc(Index);
  if IsDBCS1(S, LastIndex) then
    Inc(LastIndex);
  Result := Max(0, LastIndex - Index + 1);
  if 0 < Result then
    Delete(S, Index, Result);
end;

function AnsiDeleteW(var S: String; Index, Count: Integer): Integer;
(*
  Delete の２バイト文字対応版その３
  Index が全角文字の２バイト目の場合は１つ戻す
  Index + Count - 1 が全角１バイト目の場合は１つ進める
  Index..Index + Count - 1 が 1..Length(S) と重なっている部分だけを
  削除する
*)
var
  L, LastIndex: Integer;
begin
  Result := 0;
  L := Length(S);
  LastIndex := Index + Count - 1;
  if ((Index < 1) and (LastIndex < 1)) or
     ((L < Index) and (L < LastIndex)) then
    Exit;
  if IsDBCS2(S, Index) then
    Dec(Index);
  if IsDBCS1(S, LastIndex) then
    Inc(LastIndex);
  Result := Max(0, LastIndex - Index + 1);
  if 0 < Result then
    Delete(S, Index, Result);
end;

function CharSetToStr(CharSet: TCharSet): String;
(*
  CharSet を文字列に変換する
*)
var
  C: Char;
begin
  Result := '';
  for C := Low(Char) to High(Char) do
    if C in CharSet then
      Result := Result + C;
end;

function IncludeCharCount(S: String; C: Char; Index: Integer): Integer;
(*
  S 内の Index 文字目までにある C の数を返す
*)
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to Min(Length(S), Index) do
    if S[I] = C then
      Inc(Result);
end;

function IsDBCS1(S: String; Index: Integer): Boolean;
(*
  S の Index 番目が全角１バイト目かどうかの判別
*)
var
  I, L: Integer;
begin
  Result := False;
  L := Length(S);
  I := 1;
  while (I <= L) and (I <= Index) do
  begin
    if S[I] in LeadBytes then
      if I = Index then
      begin
        Result := True;
        Exit;
      end
      else
        Inc(I);
    Inc(I);
  end;
end;

function IsDBCS2(S: String; Index: Integer): Boolean;
(*
  S の Index 番目が全角２バイト目かどうかの判別
*)
var
  I, L: Integer;
begin
  Result := False;
  L := Length(S);
  I := 1;
  while (I <= L) and (I <= Index) do
  begin
    if S[I] in LeadBytes then
    begin
      Inc(I);
      if I = Index then
      begin
        Result := True;
        Exit;
      end;
    end;
    Inc(I);
  end;
end;

function IndexChar(S: String; Index: Integer): Char;
(*
  S 上の Index にある１文字を返す
*)
begin
  if (Index < 1) or (Length(S) < Index) then
    Result := Char(0)
  else
    Result := S[Index];
end;

function IsInclude(Substr: String; S: String): Boolean;
(*
  SubStr が S に含まれている場合は True を返す
  大文字小文字は区別される
*)
var
  I, J, SL, L: Integer;
begin
  Result := False;
  SL := Length(SubStr);
  L := Length(S);
  if (SL = 0) or (SL > L) then
    Exit;
  I := 1;
  while I <= L do
  begin
    for J := 1 to SL do
    begin
      if SubStr[J] <> S[I + J - 1] then
        Break
      else
        if J = SL then
        begin
          Result := True;
          Exit;
        end;
    end;
    if S[I] in LeadBytes then
      Inc(I);
    Inc(I);
  end;
end;

function IsMail(const S: String; var StartPos, StrLength: Integer): Boolean;
(*
  S の中に MailChars で構成される文字列とそれに続く @ . パターン
  があった場合に真を返す。
  StartPos には発見した位置、StrLength には長さが入る
*)
var
  L: Integer;
  Is64: Boolean;
  Buffer, P, SavePtr: PChar;
begin
  Result := False;
  StartPos := 0;
  StrLength := 0;
  L := Length(S);
  if L = 0 then
    Exit;
  GetMem(Buffer, L + 1);
  try
    Move(S[1], Buffer[0], L);
    Buffer[L] := #0;
    P := Buffer;
    while P^ <> #0 do
    begin
      if P^ in (MailChars - ['@']) then
      begin
        SavePtr := P;
        Is64 := False;
        while (P^ <> #0) and (P^ in MailChars) do
        begin
          if P^ = '@' then
            Is64 := True;
          if Is64 and (P^ = '.') then
            Result := True;
          Inc(P);
        end;
        if Result then
        begin
          StartPos := SavePtr - Buffer + 1;
          StrLength := P - SavePtr;
          Break;
        end
        else
          P := SavePtr;
      end;
      Inc(P);
    end;
  finally
    FreeMem(Buffer, L + 1);
  end;
end;

function IsUrl(const S: String; var StartPos, StrLength: Integer): Boolean;
(*
  S の中に 'http:', 'https:', 'ftp:', 'www.' を含む文字列があった場合
  真を返す。
  StartPos には発見した位置、StrLength には長さが入る
  nifty:FDELPHI/MES/16/00685 H-Triton さんの発言を参考にさせて頂きました。
*)
var
  L: Integer;
  Buffer, P: PChar;

  function CheckUrl(const S: String): Boolean;
  var
    L, I: Integer;
    SavePtr: PChar;
  begin
    Result := False;
    L := Length(S);
    SavePtr := P;
    I := 1;
    while I <= L do
      if P^ = S[I] then
        if I = L then
        begin
          Result := True;
          IsUrl := True;
          while P^ in UrlChars do
            Inc(P);
          StartPos := SavePtr - Buffer + 1;
          StrLength := P - SavePtr;
          Break;
        end
        else
        begin
          Inc(P);
          Inc(I);
        end
      else
      begin
        P := SavePtr;
        Break;
      end;
  end;

begin
  Result := False;
  StartPos := 0;
  StrLength := 0;
  L := Length(S);
  if L = 0 then Exit;
  GetMem(Buffer, L + 1);
  try
    Move(S[1], Buffer[0], L);
    Buffer[L] := #0;
    P := Buffer;
    while P^ <> #0 do
    begin
      case P^ of
        'h': if CheckUrl('http:') or CheckUrl('https:') then Break;
        'f': if CheckUrl('ftp:') then Break;
        'w': if CheckUrl('www.') then Break;
      end;
      Inc(P);
    end;
  finally
    FreeMem(Buffer, L + 1);
  end;
end;

function Max(X, Y: Integer): Integer;
begin
  Result := X;
  if Y > X then Result := Y;
end;

function Min(X, Y: Integer): Integer;
begin
  Result := X;
  if X > Y then Result := Y;
end;

function StrToCharSet(const S: String): TCharSet;
(*
  文字列を TCharSet に変換する。全角文字は無視される
*)
var
  I, L: Integer;
begin
  Result := [];
  I := 1;
  L := Length(S);
  while I <= L do
  begin
    if S[I] in LeadBytes then
      Inc(I)
    else
      Result := Result + [S[I]];
    Inc(I);
  end;
end;

procedure StrToStrings(const Value: String; Strings: TStrings);
(*
  Value を #13#10 で切り分けて、Strings へ格納する
  Value 内の #10 をカウントして必要な行数を確保してから
  Strings にデータをセットする
*)
var
  P, Start: PChar;
  S: String;
  LineCount, I: Integer;
begin
  Strings.BeginUpdate;
  try
    Strings.Clear;
    if Value = '' then
      Exit;
    LineCount := 0;
    for I := 1 to Length(Value) do
      if Value[I] = #10 then
        Inc(LineCount);
    if Value[Length(Value)] <> #10 then
      Inc(LineCount);
    for I := 0 to LineCount - 1 do
      Strings.Add('');
    I := 0;
    P := Pointer(Value);
    if P <> nil then
      while P^ <> #0 do
      begin
        Start := P;
        while not (P^ in [#0, #10, #13]) do
          Inc(P);
        SetString(S, Start, P - Start);
        // #13#10 ではない不正なデータのために
        if I <= Strings.Count - 1 then
          Strings[I] := S
        else
          Strings.Add(S);
        Inc(I);
        if P^ = #13 then
          Inc(P);
        if P^ = #10 then
          Inc(P);
      end;
  finally
    Strings.EndUpdate;
  end;
end;

function TabbedTrimRight(const S: String): String;
(*
 タブを取り除かない TrimRight
*)
var
  I: Integer;
begin
  I := Length(S);
  while (I > 0) and (S[I] <= #$20) and (S[I] <> #$09) do Dec(I);
  Result := Copy(S, 1, I);
end;

function TopSpace(S: String): Integer;
(*
  文字列 S の前の部分のスペース数を返す。全角スペースもカウントする
  S = '' の時は -1 を返す
  S にはタブを展開した文字列を渡すこと
*)
var
  I, L: Integer;
begin
  Result := -1;
  if S = '' then
    Exit;
  Result := 0;
  L := Length(S);
  I := 1;
  while I <= L do
  begin
    if (S[I] = #$81) and (S[I + 1] = #$40) then
    begin
      Inc(Result, 2);
      Inc(I);
    end
    else
      if S[I] = #$20 then
        Inc(Result)
      else
        Exit;
    Inc(I);
  end;
end;

function TrimLeftDBCS(const S: String): String;
(*
  全角スペースも取り除く TrimLeft
*)
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  while I <= L do
    if S[I] <= #$20 then
      Inc(I)
    else
      if (S[I] = #$81) and (S[I + 1] = #$40) then
        Inc(I, 2)
      else
        Break;
  Result := Copy(S, I, Maxint);
end;

procedure InsertStrings(Source, Dest: TStrings; Index: Integer);
(*
  Dest の Index の位置に Source を挿入出来るだけの領域を
  確保してから、その領域を Source で更新する
*)
var
  C, I, Idx: Integer;
begin
  Dest.BeginUpdate;
  try
    C := Source.Count;
    Idx := Dest.Count - 1;
    // allocate
    for I := 0 to C - 1 do
      Dest.Add('');
    // move
    for I := Idx downto Index do
    begin
      Dest[I + C] := Dest[I];
      Dest.Objects[I + C] := Dest.Objects[I];
    end;
    // update
    for I := 0 to C - 1 do
    begin
      Dest[I + Index] := Source[I];
      Dest.Objects[I + Index] := Source.Objects[I];
    end;
  finally
    Dest.EndUpdate;
  end;
end;

procedure DeleteStrings(Strings: TStrings; Index, Count: Integer);
(*
  Strings の Index の位置から Count 分の行数を削除する
  Count 分の領域を移動した後、不要になった Count 分の末尾を削除する
*)
var
  I: Integer;
begin
  if Index > Strings.Count - 1 then
    Exit;
  Strings.BeginUpdate;
  try
    // move
    for I := Index + Count to Strings.Count - 1 do
      if I - Count >= 0 then
      begin
        Strings[I - Count] := Strings[I];
        Strings.Objects[I - Count] := Strings.Objects[I];
      end;
    // delete
    for I := 0 to Count - 1 do
      if Strings.Count > 0 then
        Strings.Delete(Strings.Count - 1);
  finally
    Strings.EndUpdate;
  end;
end;

procedure ChangeStrings(Source, Dest: TStrings; Index, Dr: Integer);
(*
  Dest の Index から Dr 行を削除してから Index の位置に Source を挿入する
*)
var
  I, Ir, Idx: Integer;
begin
  Dest.BeginUpdate;
  try
    Ir := Source.Count;
    if Dr > Ir then
      DeleteStrings(Dest, Index, Dr - Ir)
    else
      if Dr < Ir then
      begin
        Idx := Dest.Count - 1;
        // allocate
        for I := 0 to Ir - Dr - 1 do
          Dest.Add('');
        // move
        for I := Idx downto Index + Dr do
        begin
          Dest[I + Ir - Dr] := Dest[I];
          Dest.Objects[I + Ir - Dr] := Dest.Objects[I];
        end;
      end;
    // put
    for I := 0 to Ir - 1 do
    begin
      if Index + I > Dest.Count - 1 then
        Dest.Add('');
      Dest[Index + I] := Source[I];
      Dest.Objects[Index + I] := Source.Objects[I];
    end;
  finally
    Dest.EndUpdate;
  end;
end;


{ Cursors functions }

function HCursorToString(Cursor: TCursor): string;
begin
  if Cursor = crRightArrow then
    Result := RightArrowCursorIdent
  else
    if Cursor = crDragSelCopy then
      Result := DragSelCopyCursorIdent
    else
      CursorToIdent(Cursor, Result);
end;

function HStringToCursor(const S: string): TCursor;
begin
  if AnsiCompareText(RightArrowCursorIdent, S) = 0 then
    Result := crRightArrow
  else
    if AnsiCompareText(DragSelCopyCursorIdent, S) = 0 then
      Result := crDragSelCopy
    else
      Result := StringToCursor(S);
end;

procedure HGetCursorValues(Proc: TGetStrProc);
begin
  GetCursorValues(Proc);
  Proc(RightArrowCursorIdent);
  Proc(DragSelCopyCursorIdent);
end;


// DrawDotLine //////////////////////////////////////////////////////

type
  TLineDDAParam = record
    Canvas: TCanvas;
    Color: TColor;
    Flag: Boolean;
  end;

procedure LineDDAProc(X, Y: Integer; var P: TLineDDAParam) stdcall;
begin
  if P.Flag then
    SetPixel(P.Canvas.Handle, X, Y, P.Color);
  P.Flag := not P.Flag;
end;

procedure DotLine(Canvas: TCanvas; X, Y, L: Integer; Color, BkColor: TColor);
//  Canvas の X, Y に長さ L の Color, BkColor による１点破線を描画する
var
  P: TLineDDAParam;
begin
  Canvas.Pen.Mode := pmCopy;
  Canvas.Brush.Color := BkColor;
  Canvas.FillRect(Rect(X, Y, X + L, Y + 1));
  P.Canvas := Canvas;
  P.Color := Color;
  P.Flag := True;
  LineDDA(X, Y, X + L, Y, @LineDDAProc, LPARAM(@P));
end;

type
  TDotLineItem = class(TCollectionItem)
  protected
    FBkColor: TColor; // 背景色
    FColor: TColor;   // 点線の色
    FLine: TBitmap;   // 点線が描画されたビットマップ
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Equal(AColor, ABkColor: TColor): Boolean;
    procedure Paint;
    property Line: TBitmap read FLine;
    property BkColor: TColor read FBkColor write FBkColor;
    property Color: TColor read FColor write FColor;
  end;

  TDotLineCollection = class(TCollection)
  protected
    function GetDotLineItem(Index: Integer): TDotLineItem;
  public
    constructor Create;
    function Add: TDotLineItem;
    function LineBitmap(AColor, ABkColor: TColor): TBitmap;
    property DotLineItems[Index: Integer]: TDotLineItem read GetDotLineItem;
  end;


{ TDotLineItem }

constructor TDotLineItem.Create(Collection: TCollection);
begin
  FLine := TBitmap.Create;
  FLine.Height := 1;
  FLine.Width := Screen.Width;
  inherited Create(Collection);
end;

destructor TDotLineItem.Destroy;
begin
  FLine.Free;
  inherited Destroy;
end;

procedure TDotLineItem.Assign(Source: TPersistent);
begin
  if Source is TDotLineItem then
  begin
    FLine.Assign(TDotLineItem(Source).FLine);
    FBkColor := TDotLineItem(Source).FBkColor;
    FColor := TDotLineItem(Source).FColor;
  end
  else
    inherited Assign(Source);
end;

function TDotLineItem.Equal(AColor, ABkColor: TColor): Boolean;
begin
  Result := (FColor = AColor) and (FBkColor = ABkColor);
end;

procedure TDotLineItem.Paint;
begin
  DotLine(FLine.Canvas, 0, 0, FLine.Width, FColor, FBkColor);
end;


{ TDotLineCollection }

constructor TDotLineCollection.Create;
begin
  inherited Create(TDotLineItem);
end;

function TDotLineCollection.Add: TDotLineItem;
begin
  Result := TDotLineItem(inherited Add);
end;

function TDotLineCollection.GetDotLineItem(Index: Integer): TDotLineItem;
begin
  Result := TDotLineItem(inherited GetItem(Index));
end;

function TDotLineCollection.LineBitmap(AColor, ABkColor: TColor): TBitmap;
var
  I: Integer;
  Item: TDotLineItem;
begin
  for I := 0 to Count - 1 do
    if DotLineItems[I].Equal(AColor, ABkColor) then
    begin
      Result := DotLineItems[I].Line;
      Exit;
    end;
  Item := Add;
  Item.Color := AColor;
  Item.BkColor := ABkColor;
  Item.Paint;
  Result := Item.Line;
end;


var
  DotLines: TDotLineCollection;

procedure DrawDotLine(Canvas: TCanvas; SX, Y, EX: Integer; Color, BkColor: TColor);
begin
  Canvas.CopyRect(Rect(SX, Y, EX + 1, Y + 1),
    DotLines.LineBitmap(Color, BkColor).Canvas, Rect(0, 0, EX - SX + 1, 1));
end;


// initialization //////////////////////////////////////////

procedure RegisterClipboard;
begin
  CF_BOXTEXT := RegisterClipboardFormat('TEditor Box Type');
end;

procedure LoadCursors;
begin
  Screen.Cursors[crRightArrow] := LoadCursor(HInstance, PChar(RightArrowCursorResourceIdent));
  Screen.Cursors[crDragSelCopy] := LoadCursor(HInstance, PChar(DragSelCopyCursorResourceIdent));
end;

procedure LoadDigitsAndMarks;
var
  I: Integer;
begin
  DefaultDigits := TImageList.CreateSize(DefaultDigitWidth, DefaultDigitHeight);
  DefaultMarks := TImageList.CreateSize(DefaultMarkWidth, DefaultMarkHeight);
  for I := Low(TDefaultMarkRange) to High(TDefaultMarkRange) do
    if I <= 9 then
      DefaultDigits.ResourceLoad(rtBitmap, DefaultMarkIdents[I], clRed)
    else
      DefaultMarks.ResourceLoad(rtBitmap, DefaultMarkIdents[I], clWhite);
end;

procedure FreeDigitsAndMarks;
begin
  DefaultDigits.Free;
  DefaultMarks.Free;
end;

initialization
  RegisterClipboard;
  LoadCursors;
  LoadDigitsAndMarks;
  DotLines := TDotLineCollection.Create;

finalization
  FreeDigitsAndMarks;
  DotLines.Free;

end.

