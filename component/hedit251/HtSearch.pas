{******************************************************************}
{                                                                  }
{  function SearchText                                             }
{                                                                  }
{  Start  : 1997/07/05                                             }
{  UpDate : 2001/07/25                                             }
{                                                                  }
{  Copyright  (C)  �{�c���F  <vyr01647@niftyserve.or.jp>           }
{                                                                  }
{  Delphi 1.0 CD-ROM Delphi\Demos\TextDemo\Search.Pas�@�𗘗p      }
{  TextLine: PChar �� Start, Length ��n���āA                     }
{  ���������ꍇ�͐擪����̃o�C�g���� Start �ɓ����             }
{  True ��Ԃ�                                                     }
{                                                                  }
{******************************************************************}

unit HTSearch;

{$I heverdef.inc}

interface

uses
  SysUtils, Windows, Classes, StdCtrls, Dialogs;

const
  WordDelimiters: set of Char = [#$0..#$FF] -
    ['a'..'z','A'..'Z','1'..'9','0',#$81..#$9F,#$E0..#$FC, #$A6..#$DF];

type
  TSearchOption = (sfrDown, sfrMatchCase, sfrWholeWord,
    sfrNoMatchZenkaku, sfrReplace, sfrReplaceAll, sfrReplaceConfirm,
    sfrIncludeCRLF, sfrIncludeSpace, sfrWholeFile);
  TSearchOptions = set of TSearchOption;
  TSearchInfo = record
    Start, Length: Integer;
  end;

function SearchText( TextLine: PChar;
                     var Info: TSearchInfo;
                     const SearchString: String;
                     Options: TSearchOptions): Boolean;

type
  TStringsSearchInfo = record
    Line: Integer;
    Column: Integer;
    Length: Integer;
  end;

function SearchStrings(Strings: TStrings; var Info: TStringsSearchInfo;
  const SearchString: String; Options: TSearchOptions): Boolean;

implementation

type
  TCharMap = array[Char] of Char;
  String2 = String[2];

var
  UpperCharMap: TCharMap;
  Ch: Char; // for initialization section

const
  {$IFDEF COMP2}
  LeadBytes: set of Char = [#$81..#$9F, #$E0..#$FC];
  {$ENDIF}

  DBCSCharArray: array[Char] of String2 =
  (#$00, #$01, #$02, #$03, #$04, #$05, #$06, #$07,  // 00
   #$08, #$09, #$0A, #$0B, #$0C, #$0D, #$0E, #$0F,  // 08
   #$10, #$11, #$12, #$13, #$14, #$15, #$16, #$17,  // 10
   #$18, #$19, #$1A, #$1B, #$1C, #$1D, #$1E, #$1F,  // 18
   '�@', '�I', '�h', '��', '��', '��', '��', '�f',  // 20
   '�i', '�j', '��', '�{', '�C', '�|', '�D', '�^',  // 28
   '�O', '�P', '�Q', '�R', '�S', '�T', '�U', '�V',  // 30
   '�W', '�X', '�F', '�G', '��', '��', '��', '�H',  // 38
   '��', '�`', '�a', '�b', '�c', '�d', '�e', '�f',  // 40
   '�g', '�h', '�i', '�j', '�k', '�l', '�m', '�n',  // 48
   '�o', '�p', '�q', '�r', '�s', '�t', '�u', '�v',  // 50
   '�w', '�x', '�y', '�m', '��', '�n', '�O', '�Q',  // 58
   '�M', '��', '��', '��', '��', '��', '��', '��',  // 60
   '��', '��', '��', '��', '��', '��', '��', '��',  // 68
   '��', '��', '��', '��', '��', '��', '��', '��',  // 70
   '��', '��', '��', '�o', '�b', '�p', '�P', #$7F,  // 78
   #$80, #$81, #$82, #$83, #$84, #$85, #$86, #$87,  // 80
   #$88, #$89, #$8A, #$8B, #$8C, #$8D, #$8E, #$8F,  // 88
   #$90, #$91, #$92, #$93, #$94, #$95, #$96, #$97,  // 90
   #$98, #$99, #$9A, #$9B, #$9C, #$9D, #$9E, #$9F,  // 98
   #$A0, '�B', '�u', '�v', '�A', '�D', '��', '�@',  // A0
   '�B', '�D', '�F', '�H', '��', '��', '��', '�b',  // A8
   '�[', '�A', '�C', '�E', '�G', '�I', '�J', '�L',  // B0
   '�N', '�P', '�R', '�T', '�V', '�X', '�Z', '�\',  // B8
   '�^', '�`', '�c', '�e', '�g', '�i', '�j', '�k',  // C0
   '�l', '�m', '�n', '�q', '�t', '�w', '�z', '�}',  // C8
   '�~', '��', '��', '��', '��', '��', '��', '��',  // D0
   '��', '��', '��', '��', '��', '��', '�J', '�K',  // D8
   #$E0, #$E1, #$E2, #$E3, #$E4, #$E5, #$E6, #$E7,  // E0
   #$E8, #$E9, #$EA, #$EB, #$EC, #$ED, #$EE, #$EF,  // E8
   #$F0, #$F1, #$F2, #$F3, #$F4, #$F5, #$F6, #$F7,  // F0
   #$F8, #$F9, #$FA, #$FB, #$FC, #$FD, #$FE, #$FF); // F8


(*
�ȉ��́A��������(KHB05271)��� HenkanJ.pas �����f�B�t�@�C��������

(1)
end else if s[1] in [#$a6..#$af,#$b1..#$df] then begin
                                        ��
end else if s[1] in [#$a6..#$af,#$b1..#$dd] then begin

�Ƃ��A'�'(#$DE), '�'(#$DF) ���L���Ƃ��ď������邱�ƂŁA�J�K�ɕϊ�
�����悤�ɂ����B

(2)
����� if Kana[S[1]] = 0 then �̏����͍폜�����B

(3)
�u���v�̏�����ǉ�

(4)
�܂��Aif S[1] in ['0'..'9', 'A'..'Z', 'a'..'z'] then �ȉ���
�J�^�J�i�ȊO�̕��������́A��L DBCSCharArray ����擾����悤�ɂ����B
*)

  Kana: array[#$A6..#$DF] of Byte =
  ($72,$21,
   $23,$25,$27,$29,$63,$65,$67,$43,
   $00,$22,$24,$26,$28,$2A,$AB,$AD, // $00 #$B0 �
   $AF,$B1,$B3,$B5,$B7,$B9,$BB,$BD,
   $BF,$C1,$C4,$C6,$C8,$4A,$4B,$4C,
   $4D,$4E,$CF,$D2,$D5,$D8,$DB,$5E,
   $5F,$60,$61,$62,$64,$66,$68,$69,
   $6A,$6B,$6C,$6D,$6F,$73,$00,$00); // $00 #$DE �  #$DF �

function JisToSJis(N:WORD):WORD; register; assembler;
asm
    add  ax,0a17eh ; shr  ah,1      ; jb  @1
    cmp  al,0deh   ; sbb  al,5eh
@1: xor  ah,0e0h
end;

function WordToChar(N: Word):String;
begin
  Result := Char(Hi(N)) + Char(Lo(N))
end;

function HankToZen(S: String): String;
var
  W: Word;
begin
  Result := '';
  while Length(S) > 0 do
  begin
    if S[1] in LeadBytes then   // �S�p����
    begin
      Result := Result + Copy(S, 1, 2);
      Delete(S, 1, 2);
    end
    else                                       // ���p����
      if S[1] in [#$A6..#$AF, #$B1..#$DD] then // �..�, �..�
      begin
        W := $2500 + (Kana[S[1]] and $7F);
        if (Kana[S[1]] and $80) = 0 then       // �� ���Ӗ����Ȃ��Ȃ�
        begin
          if (Length(S) > 1) and (S[1] = #$B3) and (S[2] = #$DE) then
          begin
            Result := Result + '��';           // �� �̏���
            Delete(S, 1, 2);
          end
          else
          begin
            Result := Result + DBCSCharArray[S[1]];
            Delete(S, 1, 1);
          end;
        end
        else                                    // �� ���Ӗ����Ȃ�
        begin
          if (Length(S) > 1) and (S[2] in [#$DE, #$DF]) then
          begin
            W := W + 1 + (Ord(S[2]) and 1);
            Delete(S, 2, 1);
          end;
          Result := Result + WordToChar(JisToSJis(W));
          Delete(S, 1, 1)
        end;
      end
      else
      begin                                     // �L��
        Result := Result + DBCSCharArray[S[1]];
        Delete(S, 1, 1);
      end;
  end;
end;

(*
2001/01/16 AnsiUpperCase �ɂ��ׂĂ̑S�p�������P�������n���āA
�قȂ����������Ԃ���镶���ꗗ

8281: �� 8260: �`  83BF: �� 839F: ��  8470: �p 8440: �@  EEEF: �� 8754: �T
8282: �� 8261: �a  83C0: �� 83A0: ��  8471: �q 8441: �A  EEF0: �� 8755: �U
8283: �� 8262: �b  83C1: �� 83A1: ��  8472: �r 8442: �B  EEF1: �� 8756: �V
8284: �� 8263: �c  83C2: �� 83A2: ��  8473: �s 8443: �C  EEF2: �� 8757: �W
8285: �� 8264: �d  83C3: �� 83A3: ��  8474: �t 8444: �D  EEF3: �� 8758: �X
8286: �� 8265: �e  83C4: �� 83A4: ��  8475: �u 8445: �E  EEF4: �� 8759: �Y
8287: �� 8266: �f  83C5: �� 83A5: ��  8476: �v 8446: �F  EEF5: �� 875A: �Z
8288: �� 8267: �g  83C6: �� 83A6: ��  8477: �w 8447: �G  EEF6: �� 875B: �[
8289: �� 8268: �h  83C7: �� 83A7: ��  8478: �x 8448: �H  EEF7: �� 875C: �\
828A: �� 8269: �i  83C8: �� 83A8: ��  8479: �y 8449: �I  EEF8: �� 875D: �]
828B: �� 826A: �j  83C9: �� 83A9: ��  847A: �z 844A: �J
828C: �� 826B: �k  83CA: �� 83AA: ��  847B: �{ 844B: �K
828D: �� 826C: �l  83CB: �� 83AB: ��  847C: �| 844C: �L
828E: �� 826D: �m  83CC: �� 83AC: ��  847D: �} 844D: �M
828F: �� 826E: �n  83CD: �� 83AD: ��  847E: �~ 844E: �N
8290: �� 826F: �o  83CE: �� 83AE: ��
8291: �� 8270: �p  83CF: �� 83AF: ��  8480: �� 844F: �O
8292: �� 8271: �q  83D0: �� 83B0: ��  8481: �� 8450: �P
8293: �� 8272: �r  83D1: �� 83B1: ��  8482: �� 8451: �Q
8294: �� 8273: �s  83D2: �� 83B2: ��  8483: �� 8452: �R
8295: �� 8274: �t  83D3: �� 83B3: ��  8484: �� 8453: �S
8296: �� 8275: �u  83D4: �� 83B4: ��  8485: �� 8454: �T
8297: �� 8276: �v  83D5: �� 83B5: ��  8486: �� 8455: �U
8298: �� 8277: �w  83D6: �� 83B6: ��  8487: �� 8456: �V
8299: �� 8278: �x                     8488: �� 8457: �W
829A: �� 8279: �y                     8489: �� 8458: �X
                                      848A: �� 8459: �Y
                                      848B: �� 845A: �Z
                                      848C: �� 845B: �[
                                      848D: �� 845C: �\
                                      848E: �� 845D: �]
                                      848F: �� 845E: �^
                                      8490: �� 845F: �_
                                      8491: �� 8460: �`
*)

const
  LDBAlpha2: array[#$81..#$9A] of Char =
  (#$60, #$61, #$62, #$63, #$64, #$65, #$66, #$67, #$68, #$69,
   #$6A, #$6B, #$6C, #$6D, #$6E, #$6F, #$70, #$71, #$72, #$73,
   #$74, #$75, #$76, #$77, #$78, #$79);

  LDBOmega2: array[#$BF..#$D6] of Char =
  (#$9F, #$A0, #$A1, #$A2, #$A3, #$A4, #$A5, #$A6, #$A7, #$A8,
   #$A9, #$AA, #$AB, #$AC, #$AD, #$AE, #$AF, #$B0, #$B1, #$B2,
   #$B3, #$B4, #$B5, #$B6);

  LDBRussia21: array[#$70..#$7E] of Char =
  (#$40, #$41, #$42, #$43, #$44, #$45, #$46, #$47, #$48, #$49,
   #$4A, #$4B, #$4C, #$4D, #$4E);

  LDBRussia22: array[#$80..#$91] of Char =
  (#$4F, #$50, #$51, #$52, #$53, #$54, #$55, #$56, #$57, #$58,
   #$59, #$5A, #$5B, #$5C, #$5D, #$5E, #$5F, #$60);

  LDBArabic2: array[#$EF..#$F8] of Char =
  (#$54, #$55, #$56, #$57, #$58, #$59, #$5A, #$5B, #$5C, #$5D);

function EqualWChar(Pattern, Text: PChar): Boolean;
(*
  Pattern, Text ����n�܂�S�p�P�������������ǂ����𔻕ʂ���B

  �EPattern, Text �� LeadBytes ���ǂ����̔��ʂ͍s���Ă��Ȃ��B
  �E�啶���������͋�ʂ���Ȃ��B
  �EPattern �� AnsiUpperCase �ɂ���đ啶�������ꂽ�S�p������ւ�
    �|�C���^�ł��邱�ƁB
*)
var
  P1, P2, T1, T2: Char;
begin
  Result := False;
  P1 := Pattern^;
  P2 := (Pattern + 1)^;
  T1 := Text^;
  T2 := (Text + 1)^;
  if P1 = T1 then
    if P2 = T2 then
      Result := True
    else
      case T1 of
        #$82: // ��..��
          if T2 in [#$81..#$9A] then Result := P2 = LDBAlpha2[T2];
        #$83: // ��..��
          if T2 in [#$BF..#$D6] then Result := P2 = LDBOmega2[T2];
        #$84:
          case T2 of
            #$70..#$7E: // �p..�~
              Result := P2 = LDBRussia21[T2];
            #$80..#$91: // ��..��
              Result := P2 = LDBRussia22[T2];
          end;
      end
  else
    if (P1 = #$87) and (T1 = #$EE) and (T2 in [#$EF..#$F8]) then
      // �T.. �]
      Result := P2 = LDBArabic2[T2];
end;

function SearchBuf(  Buf: PChar;
                     var Info: TSearchInfo;
                     SearchString: String;
                     Options: TSearchOptions): PChar;
var
  SC, BufLen, I, P, C, Extend, L, CharLen: Integer;
  Direction: ShortInt;
  Pattern: String;
  S: String2;
  DBCSPattern, DBCSBuffer, MatchChar, IsDakuten: Boolean;
  AttrBuffer: PChar;

  function FindNextWordStart(var BufPtr: PChar): Boolean;
  begin
    // ���̐擪�����Ă���Ƃ��͈ړ������ɐ^��Ԃ�
    if (Direction = 1) and not (BufPtr^ in WordDelimiters) and
       ((BufPtr = Buf) or
        ((BufPtr > Buf) and (Buf[BufPtr - Buf - 1] in WordDelimiters))) then
    begin
      Result := True;
      Exit;
    end;

    while (SC > 0) and
          ((Direction = 1) xor (BufPtr^ in WordDelimiters)) do
    begin
      Inc(BufPtr, Direction);
      Dec(SC);
    end;
    while (SC > 0) and
          ((Direction = -1) xor (BufPtr^ in WordDelimiters)) do
    begin
      Inc(BufPtr, Direction);
      Dec(SC);
    end;
    Result := SC >= 0;
    if (Direction = -1) and (BufPtr^ in WordDelimiters) then
    begin   { back up one char, to leave ptr on first non delim }
      Dec(BufPtr, Direction);
      Inc(SC);
    end;
    if AttrBuffer[BufPtr - Buf] = '2' then
    begin
      Inc(BufPtr, Direction);
      Dec(SC);
    end;
  end;

begin
  Result := nil;
  BufLen := StrLen(Buf);
  if (Info.Start < 0) or (Info.Start > BufLen) or (Info.Length < 0) then
    Exit;
  Pattern := SearchString;
  if not (sfrMatchCase in Options) then
    Pattern := AnsiUpperCase(Pattern);
  L := Length(Pattern);
  CharLen := 0;
  if sfrNoMatchZenkaku in Options then
  begin
    Pattern := HankToZen(Pattern);
    L := Length(Pattern);
    I := 1;
    while I <= L do
    begin
      if Pattern[I] in LeadBytes then
        Inc(I);
      Inc(I);
      Inc(CharLen);
    end;
  end;

  AttrBuffer := StrAlloc(BufLen + 1);
  try
    I := 0;
    while I < BufLen do
    begin
      if Buf[I] in LeadBytes then
      begin
        Move('12', AttrBuffer[I], 2);
        Inc(I);
      end
      else
        AttrBuffer[I] := '0';
      Inc(I);
    end;

    if sfrDown in Options then
    begin
      Direction := 1;
      Inc(Info.Start, Info.Length);
      if (Info.Start < BufLen) and (AttrBuffer[Info.Start] = '2') then
        Inc(Info.Start);
      if sfrNoMatchZenkaku in Options then
        SC := BufLen - Info.Start - CharLen
      else
        SC := BufLen - Info.Start - L;
      if SC < 0 then
        Exit;
      if Info.Start + SC > BufLen then
        Exit;
    end
    else
    begin
      Direction := -1;
      if not (sfrNoMatchZenkaku in Options) then
        Dec(Info.Start, L)
      else
        while CharLen > 0 do
        begin
          Dec(Info.Start);
          // �S�p�Q�o�C�g�ڂ��A�, �..�, �..� + ��
          if (Info.Start > 0) and
             ((AttrBuffer[Info.Start] = '2') or
              ((Buf[Info.Start] in [#$DE..#$DF]) and
               (Buf[Info.Start - 1] in [#$B3, #$B6..#$C4, #$CA..#$CE]))) then
            Dec(Info.Start);
          Dec(CharLen);
        end;
      if (Info.Start >= 0) and (AttrBuffer[Info.Start] = '2') then
        Dec(Info.Start);
      SC := Info.Start;
    end;
    if (Info.Start < 0) or (Info.Start > BufLen) then
      Exit;
    Result := PChar(@Buf[Info.Start]);

    //  search
    while SC >= 0 do
    begin
      // SC = 0 �̎�
      // Direction =  1 ... �Ō�̈��
      // Direction = -1 ... �o�b�t�@�̐擪
      if (sfrWholeWord in Options) and (SC > 0) then
        if not FindNextWordStart(Result) then Break;

      I := 0; // hit counter
      C := 0; // crlf, space counter
      P := 1; // pointer to Pattern
      while True do
      begin
        DBCSPattern := Pattern[P] in LeadBytes;
        DBCSBuffer := Result[I + C] in LeadBytes;
        IsDakuten := False;

        if sfrNoMatchZenkaku in Options then // �S�p�E���p����ʂ��Ȃ�
          if sfrMatchCase in Options then    // �啶������������ʂ���
            if DBCSBuffer then
              MatchChar := (Pattern[P] = Result[I + C]) and
                           (Pattern[P + 1] = Result[I + C + 1])
            else
            begin                            // �S�p�ɕϊ����Ĕ���
              // �, �..�, �..� + ��
              if (Result[I + C] in [#$B3, #$B6..#$C4, #$CA..#$CE]) and
                 (Result[I + C + 1] in [#$DE..#$DF]) then
              begin
                S := HankToZen(Result[I + C] +
                               Result[I + C + 1]);
                IsDakuten := True;
              end
              else
                S := DBCSCharArray[Result[I + C]];
              MatchChar := (Pattern[P] = S[1]) and
                           (Pattern[P + 1] = S[2]);
            end
          else                               // �啶������������ʂ��Ȃ�
            if DBCSBuffer then               // �S�p���m�̔���
              MatchChar := EqualWChar(@Pattern[P], Result + I + C)
            else
            begin                            // �S�p�ɕϊ����Ĕ�r
              // �, �..�, �..� + ��
              if (Result[I + C] in [#$B3, #$B6..#$C4, #$CA..#$CE]) and
                 (Result[I + C + 1] in [#$DE..#$DF]) then
              begin
                S := HankToZen(Result[I + C] +
                               Result[I + C + 1]);
                IsDakuten := True;
              end
              else
                S := DBCSCharArray[Result[I + C]];
              // MatchChar := EqualWChar(@Pattern[P], @S);
              if (S[1] = #$82) and           // �啶���}�b�v�Ŕ���
                 (S[2] in [#$81..#$9A]) then // ��..��
                MatchChar := (Pattern[P] = #$82) and
                             (Pattern[P + 1] = LDBAlpha2[S[2]])
              else
                MatchChar := (Pattern[P] = S[1]) and
                             (Pattern[P + 1] = S[2]);
            end
        else                                 // �S�p�E���p����ʂ���
          if sfrMatchCase in Options then    // �啶������������ʂ���
            if DBCSBuffer then
              MatchChar := DBCSPattern and
                           (Pattern[P] = Result[I + C]) and
                           (Pattern[P + 1] = Result[I + C + 1])
            else
              MatchChar := Pattern[P] = Result[I + C]
          else                               // �啶������������ʂ��Ȃ�
            if DBCSBuffer then
              MatchChar := EqualWChar(@Pattern[P], Result + I + C)
            else
              MatchChar := Pattern[P] = UpperCharMap[Result[I + C]];
        if not MatchChar then
        begin
          Extend := 0;
          if I > 0 then
            if (sfrIncludeCRLF in Options) and
               (Result[I + C] in [#$0D, #$0A]) then
              Extend := 1
            else
              if (sfrIncludeSpace in Options) and
                 (Result[I + C] in [#$20, #$09]) then
                Extend := 1
              else
                if (sfrIncludeSpace in Options) and
                   (Result[I + C] = #$81) and
                   (Result[I + C + 1] = #$40) then
                  Extend := 2;
          if Extend > 0 then
          begin
            Inc(C, Extend);
            Continue;
          end
          else
            Break;
        end
        else
        begin
          Inc(I, Byte(DBCSBuffer or IsDakuten) + 1);
          Inc(P, Byte(DBCSPattern) + 1);
          if P > L then
            if (not (sfrWholeWord in Options)) or
               (SC = 0) or
               (Result[I + C] in WordDelimiters) then
            begin
              Info.Length := I + C;
              Exit;
            end
            else
              Break;
        end;
      end;
      Inc(Result, Direction);
      Dec(SC);
      if AttrBuffer[Result - Buf] = '2' then
      begin
        Inc(Result, Direction);
        Dec(SC);
      end;
    end;
    Result := nil;
  finally
    StrDispose(AttrBuffer);
  end;
end;

function SearchText( TextLine: PChar;
                     var Info: TSearchInfo;
                     const SearchString: String;
                     Options: TSearchOptions): Boolean;
var
  P: PChar;
begin
  Result := False;
  if (Length(SearchString) = 0) or (StrLen(TextLine) = 0) then
    Exit;
  P := SearchBuf(TextLine, Info, SearchString, Options);
  if P <> nil then
  begin
    //  Info.Length �� SearchBuf ���ŃZ�b�g�����
    Info.Start := P - TextLine;
    Result := True;
  end;
end;

function SearchStrings(Strings: TStrings; var Info: TStringsSearchInfo;
  const SearchString: String; Options: TSearchOptions): Boolean;
(*
  TStrings �ɑ΂��Č������s���֐��B
  Info.Line ..... �������J�n����s�ԍ��i�O�x�[�X�j���w�肷��B
  Info.Column ... �������J�n���錅�ԍ��i�O�x�[�X�j���w�肷��B
                  �I����Ԃ̏ꍇ�́A�I��̈�I�[��n�����ƁB
  Info.Length ... ���������Ƃ��̕����񒷂����i�[�����B

  ����������ɂ͑Ή����Ă��Ȃ��B�܂� sfrIncludeCRLF �����������B
*)
var
  SearchInfo: TSearchInfo;
//  S: String;
  I: Integer;
begin
  Result := False;
  Options := Options + [sfrDown] - [sfrIncludeCRLF];
  SearchInfo.Length := 0;
  for I := Info.Line to Strings.Count - 1 do
  begin
    if I = Info.Line then
      SearchInfo.Start := Info.Column
    else
      SearchInfo.Start := 0;
    if SearchText(PChar(Strings[I]), SearchInfo, SearchString, Options) then
    begin
      Info.Line := I;
      Info.Column := SearchInfo.Start;
      Info.Length := SearchInfo.Length;
      Result := True;
      Break;
    end;
  end;
end;

initialization
  // �啶���e�[�u��
  for Ch := Low(UpperCharMap) to High(UpperCharMap) do
    UpperCharMap[Ch] := Ch;
  CharUpperBuff(PChar(@UpperCharMap), SizeOf(UpperCharMap));
end.

