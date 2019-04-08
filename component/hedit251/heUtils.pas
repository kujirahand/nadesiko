(*********************************************************************

  heUtils.pas

  start  2001/03/17
  update 2003/11/28

  Copyright (c) 1998,2003 �{�c���F <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  TEditor �ŗ��p�����֐��E�葱���Q�ƒ萔�y�ѕϐ����L�q����Ă���

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
  AnsiCopy .......... Copy �̂Q�o�C�g�Ή���
  AnsiCopyE ......... AnsiCopy ���̂Q�iTEditor ��`�I��̈�d�l�j
  AnsiCopyW ......... AnsiCopy ���̂R
  AnsiDelete ........ Delete �̂Q�o�C�g�Ή���
  AnsiDeleteE ....... AnsiDelete ���̂Q�iTEditor ��`�I��̈�d�l�j
  AnsiDeleteW ....... AnsiDelete ���̂R
  CharSetToStr ...... TCharSet �� ������ɕϊ�����
  IndexChar ......... �������� Index �ɂ���P������Ԃ�
  IncludeCharCount .. ������ S ���� Index �����ڂ܂łɑ��݂��� C �̐���Ԃ�
  IsDBCS1 ........... S �� Index �Ԗڂ��S�p�P�o�C�g�ڂ��ǂ����̔���
  IsDBCS2 ........... S �� Index �Ԗڂ��S�p�Q�o�C�g�ڂ��ǂ����̔���
  IsInclude ......... SubStr �� S ���ɑ��݂��邩�ǂ�����Ԃ��i�啶������������ʂ���j
  IsMail ............ ������ S �̒��� MailChars �ō\������镶����Ƃ����
                      ���� @ . �̃p�^�[�����������ꍇ�ɐ^��Ԃ��B
                      StartPos �ɂ͔��������ʒu�AStrLength �ɂ͒���������
  IsUrl ............. ������ S �̒��� 'http:', 'https:', 'ftp:', 'www.' ��
                      �܂ޕ����񂪂������ꍇ�^��Ԃ�
                      StartPos �ɂ͔��������ʒu�AStrLength �ɂ͒���������
  Max ............... �傫�����̒l��Ԃ�
  Min ............... ���������̒l��Ԃ�
  StrToCharSet ...... ������� TCharSet �ɕϊ�����B�S�p�����͖��������
  StrToStrings ...... ������ Value �� #13#10 �Ő؂蕪���� Strings �Ɋi�[����
  TabbedTrimRight ... �^�u����菜���Ȃ� TrimRight
  TopSpace .......... ������̑O�̕����̃X�y�[�X����Ԃ��B�S�p�X�y�[�X��
                      �J�E���g����B������ '' �̏ꍇ�� -1 ��Ԃ��B
  TrimLeftDBCS ...... �S�p�X�y�[�X����菜�� TrimLeft
  ChangeStrings ..... Dest �� Index ���� Dr �s���폜���� Index ��
                      Source ��}������
  DeleteStrings ..... Strings �� Index ���� Count �s���폜����
  InsertStrings ..... Dest �� Index �� Source ��}������

  HCursorToString ... 'crRightArrow', 'crDragSelCopy' ��Ԃ� CursorToString
  HStringToCursor ... crRightArrow, crDragSelCopy ��Ԃ� StringToCursor
  HGetCursorValues .. 'crRightArrow', 'crDragSelCopy' ���n���Ă���� GetCursorValues

  DrawDotLine ....... �P�_�j����`�悷��B
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
  Copy �̂Q�o�C�g�����Ή���
  Index ���S�p�����̂Q�o�C�g�ڂ̏ꍇ�͂P�i�߂�
  Index + Count - 1 ���S�p�P�o�C�g�ڂ̏ꍇ�͂P�߂�
  Index..Index + Count - 1 �� 1..Length(S) �Əd�Ȃ�������������
  ��������
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
  Copy �̂Q�o�C�g�����Ή��ł��̂Q�iTEditor ��`�I��̈�d�l�j
  Index ���S�p�����̂Q�o�C�g�ڂ̏ꍇ�͂P�i�߂�
  Index + Count - 1 ���S�p�P�o�C�g�ڂ̏ꍇ�͂P�i�߂�
  Index..Index + Count - 1 �� 1..Length(S) �Əd�Ȃ�������������
  ��������
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
  Copy �̂Q�o�C�g�����Ή��ł��̂R
  Index ���S�p�����̂Q�o�C�g�ڂ̏ꍇ�͂P�߂�
  Index + Count - 1 ���S�p�P�o�C�g�ڂ̏ꍇ�͂P�i�߂�
  Index..Index + Count - 1 �� 1..Length(S) �Əd�Ȃ�������������
  ��������
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
  Delete �̂Q�o�C�g�����Ή���
  Index ���S�p�����̂Q�o�C�g�ڂ̏ꍇ�͂P�i�߂�
  Index + Count - 1 ���S�p�P�o�C�g�ڂ̏ꍇ�͂P�߂�
  Index..Index + Count - 1 �� 1..Length(S) �Əd�Ȃ��Ă��镔��������
  �폜����
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
  Delete �̂Q�o�C�g�����Ή��ł��̂Q�iTEditor ��`�I��̈�d�l�j
  Index ���S�p�����̂Q�o�C�g�ڂ̏ꍇ�͂P�i�߂�
  Index + Count - 1 ���S�p�P�o�C�g�ڂ̏ꍇ�͂P�i�߂�
  Index..Index + Count - 1 �� 1..Length(S) �Əd�Ȃ��Ă��镔��������
  �폜����
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
  Delete �̂Q�o�C�g�����Ή��ł��̂R
  Index ���S�p�����̂Q�o�C�g�ڂ̏ꍇ�͂P�߂�
  Index + Count - 1 ���S�p�P�o�C�g�ڂ̏ꍇ�͂P�i�߂�
  Index..Index + Count - 1 �� 1..Length(S) �Əd�Ȃ��Ă��镔��������
  �폜����
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
  CharSet �𕶎���ɕϊ�����
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
  S ���� Index �����ڂ܂łɂ��� C �̐���Ԃ�
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
  S �� Index �Ԗڂ��S�p�P�o�C�g�ڂ��ǂ����̔���
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
  S �� Index �Ԗڂ��S�p�Q�o�C�g�ڂ��ǂ����̔���
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
  S ��� Index �ɂ���P������Ԃ�
*)
begin
  if (Index < 1) or (Length(S) < Index) then
    Result := Char(0)
  else
    Result := S[Index];
end;

function IsInclude(Substr: String; S: String): Boolean;
(*
  SubStr �� S �Ɋ܂܂�Ă���ꍇ�� True ��Ԃ�
  �啶���������͋�ʂ����
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
  S �̒��� MailChars �ō\������镶����Ƃ���ɑ��� @ . �p�^�[��
  ���������ꍇ�ɐ^��Ԃ��B
  StartPos �ɂ͔��������ʒu�AStrLength �ɂ͒���������
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
  S �̒��� 'http:', 'https:', 'ftp:', 'www.' ���܂ޕ����񂪂������ꍇ
  �^��Ԃ��B
  StartPos �ɂ͔��������ʒu�AStrLength �ɂ͒���������
  nifty:FDELPHI/MES/16/00685 H-Triton ����̔������Q�l�ɂ����Ē����܂����B
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
  ������� TCharSet �ɕϊ�����B�S�p�����͖��������
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
  Value �� #13#10 �Ő؂蕪���āAStrings �֊i�[����
  Value ���� #10 ���J�E���g���ĕK�v�ȍs�����m�ۂ��Ă���
  Strings �Ƀf�[�^���Z�b�g����
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
        // #13#10 �ł͂Ȃ��s���ȃf�[�^�̂��߂�
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
 �^�u����菜���Ȃ� TrimRight
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
  ������ S �̑O�̕����̃X�y�[�X����Ԃ��B�S�p�X�y�[�X���J�E���g����
  S = '' �̎��� -1 ��Ԃ�
  S �ɂ̓^�u��W�J�����������n������
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
  �S�p�X�y�[�X����菜�� TrimLeft
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
  Dest �� Index �̈ʒu�� Source ��}���o���邾���̗̈��
  �m�ۂ��Ă���A���̗̈�� Source �ōX�V����
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
  Strings �� Index �̈ʒu���� Count ���̍s�����폜����
  Count ���̗̈���ړ�������A�s�v�ɂȂ��� Count ���̖������폜����
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
  Dest �� Index ���� Dr �s���폜���Ă��� Index �̈ʒu�� Source ��}������
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
//  Canvas �� X, Y �ɒ��� L �� Color, BkColor �ɂ��P�_�j����`�悷��
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
    FBkColor: TColor; // �w�i�F
    FColor: TColor;   // �_���̐F
    FLine: TBitmap;   // �_�����`�悳�ꂽ�r�b�g�}�b�v
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

