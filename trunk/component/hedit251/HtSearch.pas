{******************************************************************}
{                                                                  }
{  function SearchText                                             }
{                                                                  }
{  Start  : 1997/07/05                                             }
{  UpDate : 2001/07/25                                             }
{                                                                  }
{  Copyright  (C)  –{“cŸ•F  <vyr01647@niftyserve.or.jp>           }
{                                                                  }
{  Delphi 1.0 CD-ROM Delphi\Demos\TextDemo\Search.Pas@‚ğ—˜—p      }
{  TextLine: PChar ‚Æ Start, Length ‚ğ“n‚µ‚ÄA                     }
{  Œ©‚Â‚©‚Á‚½ê‡‚Íæ“ª‚©‚ç‚ÌƒoƒCƒg”‚ğ Start ‚É“ü‚ê‚Ä             }
{  True ‚ğ•Ô‚·                                                     }
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
   '@', 'I', 'h', '”', '', '“', '•', 'f',  // 20
   'i', 'j', '–', '{', 'C', '|', 'D', '^',  // 28
   '‚O', '‚P', '‚Q', '‚R', '‚S', '‚T', '‚U', '‚V',  // 30
   '‚W', '‚X', 'F', 'G', 'ƒ', '', '„', 'H',  // 38
   '—', '‚`', '‚a', '‚b', '‚c', '‚d', '‚e', '‚f',  // 40
   '‚g', '‚h', '‚i', '‚j', '‚k', '‚l', '‚m', '‚n',  // 48
   '‚o', '‚p', '‚q', '‚r', '‚s', '‚t', '‚u', '‚v',  // 50
   '‚w', '‚x', '‚y', 'm', '', 'n', 'O', 'Q',  // 58
   'M', '‚', '‚‚', '‚ƒ', '‚„', '‚…', '‚†', '‚‡',  // 60
   '‚ˆ', '‚‰', '‚Š', '‚‹', '‚Œ', '‚', '‚', '‚',  // 68
   '‚', '‚‘', '‚’', '‚“', '‚”', '‚•', '‚–', '‚—',  // 70
   '‚˜', '‚™', '‚š', 'o', 'b', 'p', 'P', #$7F,  // 78
   #$80, #$81, #$82, #$83, #$84, #$85, #$86, #$87,  // 80
   #$88, #$89, #$8A, #$8B, #$8C, #$8D, #$8E, #$8F,  // 88
   #$90, #$91, #$92, #$93, #$94, #$95, #$96, #$97,  // 90
   #$98, #$99, #$9A, #$9B, #$9C, #$9D, #$9E, #$9F,  // 98
   #$A0, 'B', 'u', 'v', 'A', 'D', 'ƒ’', 'ƒ@',  // A0
   'ƒB', 'ƒD', 'ƒF', 'ƒH', 'ƒƒ', 'ƒ…', 'ƒ‡', 'ƒb',  // A8
   '[', 'ƒA', 'ƒC', 'ƒE', 'ƒG', 'ƒI', 'ƒJ', 'ƒL',  // B0
   'ƒN', 'ƒP', 'ƒR', 'ƒT', 'ƒV', 'ƒX', 'ƒZ', 'ƒ\',  // B8
   'ƒ^', 'ƒ`', 'ƒc', 'ƒe', 'ƒg', 'ƒi', 'ƒj', 'ƒk',  // C0
   'ƒl', 'ƒm', 'ƒn', 'ƒq', 'ƒt', 'ƒw', 'ƒz', 'ƒ}',  // C8
   'ƒ~', 'ƒ€', 'ƒ', 'ƒ‚', 'ƒ„', 'ƒ†', 'ƒˆ', 'ƒ‰',  // D0
   'ƒŠ', 'ƒ‹', 'ƒŒ', 'ƒ', 'ƒ', 'ƒ“', 'J', 'K',  // D8
   #$E0, #$E1, #$E2, #$E3, #$E4, #$E5, #$E6, #$E7,  // E0
   #$E8, #$E9, #$EA, #$EB, #$EC, #$ED, #$EE, #$EF,  // E8
   #$F0, #$F1, #$F2, #$F3, #$F4, #$F5, #$F6, #$F7,  // F0
   #$F8, #$F9, #$FA, #$FB, #$FC, #$FD, #$FE, #$FF); // F8


(*
ˆÈ‰º‚ÍA—Úàú‚³‚ñ(KHB05271)ì‚Ì HenkanJ.pas ‚ğƒ‚ƒfƒBƒtƒ@ƒC‚µ‚½‚à‚Ì

(1)
end else if s[1] in [#$a6..#$af,#$b1..#$df] then begin
                                        «
end else if s[1] in [#$a6..#$af,#$b1..#$dd] then begin

‚Æ‚µA'Ş'(#$DE), 'ß'(#$DF) ‚ğ‹L†‚Æ‚µ‚Äˆ—‚·‚é‚±‚Æ‚ÅAJK‚É•ÏŠ·
‚³‚ê‚é‚æ‚¤‚É‚µ‚½B

(2)
‚æ‚Á‚Ä if Kana[S[1]] = 0 then ‚Ìˆ—‚Ííœ‚µ‚½B

(3)
uƒ”v‚Ìˆ—‚ğ’Ç‰Á

(4)
‚Ü‚½Aif S[1] in ['0'..'9', 'A'..'Z', 'a'..'z'] then ˆÈ‰º‚Ì
ƒJƒ^ƒJƒiˆÈŠO‚Ì•¶šˆ—‚ÍAã‹L DBCSCharArray ‚©‚çæ“¾‚·‚é‚æ‚¤‚É‚µ‚½B
*)

  Kana: array[#$A6..#$DF] of Byte =
  ($72,$21,
   $23,$25,$27,$29,$63,$65,$67,$43,
   $00,$22,$24,$26,$28,$2A,$AB,$AD, // $00 #$B0 °
   $AF,$B1,$B3,$B5,$B7,$B9,$BB,$BD,
   $BF,$C1,$C4,$C6,$C8,$4A,$4B,$4C,
   $4D,$4E,$CF,$D2,$D5,$D8,$DB,$5E,
   $5F,$60,$61,$62,$64,$66,$68,$69,
   $6A,$6B,$6C,$6D,$6F,$73,$00,$00); // $00 #$DE Ş  #$DF ß

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
    if S[1] in LeadBytes then   // ‘SŠp•¶š
    begin
      Result := Result + Copy(S, 1, 2);
      Delete(S, 1, 2);
    end
    else                                       // ”¼Šp•¶š
      if S[1] in [#$A6..#$AF, #$B1..#$DD] then // ¦..¯, ±..İ
      begin
        W := $2500 + (Kana[S[1]] and $7F);
        if (Kana[S[1]] and $80) = 0 then       // ßŞ ‚ªˆÓ–¡‚ğ‚È‚³‚È‚¢
        begin
          if (Length(S) > 1) and (S[1] = #$B3) and (S[2] = #$DE) then
          begin
            Result := Result + 'ƒ”';           // ³Ş ‚Ìˆ—
            Delete(S, 1, 2);
          end
          else
          begin
            Result := Result + DBCSCharArray[S[1]];
            Delete(S, 1, 1);
          end;
        end
        else                                    // ßŞ ‚ªˆÓ–¡‚ğ‚È‚·
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
      begin                                     // ‹L†
        Result := Result + DBCSCharArray[S[1]];
        Delete(S, 1, 1);
      end;
  end;
end;

(*
2001/01/16 AnsiUpperCase ‚É‚·‚×‚Ä‚Ì‘SŠp•¶š‚ğ‚P•¶š‚¸‚Â“n‚µ‚ÄA
ˆÙ‚È‚Á‚½•¶š‚ª•Ô‚³‚ê‚é•¶šˆê——

8281: ‚ 8260: ‚`  83BF: ƒ¿ 839F: ƒŸ  8470: „p 8440: „@  EEEF: îï 8754: ‡T
8282: ‚‚ 8261: ‚a  83C0: ƒÀ 83A0: ƒ   8471: „q 8441: „A  EEF0: îğ 8755: ‡U
8283: ‚ƒ 8262: ‚b  83C1: ƒÁ 83A1: ƒ¡  8472: „r 8442: „B  EEF1: îñ 8756: ‡V
8284: ‚„ 8263: ‚c  83C2: ƒÂ 83A2: ƒ¢  8473: „s 8443: „C  EEF2: îò 8757: ‡W
8285: ‚… 8264: ‚d  83C3: ƒÃ 83A3: ƒ£  8474: „t 8444: „D  EEF3: îó 8758: ‡X
8286: ‚† 8265: ‚e  83C4: ƒÄ 83A4: ƒ¤  8475: „u 8445: „E  EEF4: îô 8759: ‡Y
8287: ‚‡ 8266: ‚f  83C5: ƒÅ 83A5: ƒ¥  8476: „v 8446: „F  EEF5: îõ 875A: ‡Z
8288: ‚ˆ 8267: ‚g  83C6: ƒÆ 83A6: ƒ¦  8477: „w 8447: „G  EEF6: îö 875B: ‡[
8289: ‚‰ 8268: ‚h  83C7: ƒÇ 83A7: ƒ§  8478: „x 8448: „H  EEF7: î÷ 875C: ‡\
828A: ‚Š 8269: ‚i  83C8: ƒÈ 83A8: ƒ¨  8479: „y 8449: „I  EEF8: îø 875D: ‡]
828B: ‚‹ 826A: ‚j  83C9: ƒÉ 83A9: ƒ©  847A: „z 844A: „J
828C: ‚Œ 826B: ‚k  83CA: ƒÊ 83AA: ƒª  847B: „{ 844B: „K
828D: ‚ 826C: ‚l  83CB: ƒË 83AB: ƒ«  847C: „| 844C: „L
828E: ‚ 826D: ‚m  83CC: ƒÌ 83AC: ƒ¬  847D: „} 844D: „M
828F: ‚ 826E: ‚n  83CD: ƒÍ 83AD: ƒ­  847E: „~ 844E: „N
8290: ‚ 826F: ‚o  83CE: ƒÎ 83AE: ƒ®
8291: ‚‘ 8270: ‚p  83CF: ƒÏ 83AF: ƒ¯  8480: „€ 844F: „O
8292: ‚’ 8271: ‚q  83D0: ƒĞ 83B0: ƒ°  8481: „ 8450: „P
8293: ‚“ 8272: ‚r  83D1: ƒÑ 83B1: ƒ±  8482: „‚ 8451: „Q
8294: ‚” 8273: ‚s  83D2: ƒÒ 83B2: ƒ²  8483: „ƒ 8452: „R
8295: ‚• 8274: ‚t  83D3: ƒÓ 83B3: ƒ³  8484: „„ 8453: „S
8296: ‚– 8275: ‚u  83D4: ƒÔ 83B4: ƒ´  8485: „… 8454: „T
8297: ‚— 8276: ‚v  83D5: ƒÕ 83B5: ƒµ  8486: „† 8455: „U
8298: ‚˜ 8277: ‚w  83D6: ƒÖ 83B6: ƒ¶  8487: „‡ 8456: „V
8299: ‚™ 8278: ‚x                     8488: „ˆ 8457: „W
829A: ‚š 8279: ‚y                     8489: „‰ 8458: „X
                                      848A: „Š 8459: „Y
                                      848B: „‹ 845A: „Z
                                      848C: „Œ 845B: „[
                                      848D: „ 845C: „\
                                      848E: „ 845D: „]
                                      848F: „ 845E: „^
                                      8490: „ 845F: „_
                                      8491: „‘ 8460: „`
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
  Pattern, Text ‚©‚çn‚Ü‚é‘SŠp‚P•¶š‚ª“¯‚¶‚©‚Ç‚¤‚©‚ğ”»•Ê‚·‚éB

  EPattern, Text ‚ª LeadBytes ‚©‚Ç‚¤‚©‚Ì”»•Ê‚Ís‚Á‚Ä‚¢‚È‚¢B
  E‘å•¶š¬•¶š‚Í‹æ•Ê‚³‚ê‚È‚¢B
  EPattern ‚Í AnsiUpperCase ‚É‚æ‚Á‚Ä‘å•¶š‰»‚³‚ê‚½‘SŠp•¶š—ñ‚Ö‚Ì
    ƒ|ƒCƒ“ƒ^‚Å‚ ‚é‚±‚ÆB
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
        #$82: // ‚..‚š
          if T2 in [#$81..#$9A] then Result := P2 = LDBAlpha2[T2];
        #$83: // ƒ¿..ƒÖ
          if T2 in [#$BF..#$D6] then Result := P2 = LDBOmega2[T2];
        #$84:
          case T2 of
            #$70..#$7E: // „p..„~
              Result := P2 = LDBRussia21[T2];
            #$80..#$91: // „€..„‘
              Result := P2 = LDBRussia22[T2];
          end;
      end
  else
    if (P1 = #$87) and (T1 = #$EE) and (T2 in [#$EF..#$F8]) then
      // ‡T.. ‡]
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
    // ˆêŒê‚Ìæ“ª‚ğŒ©‚Ä‚¢‚é‚Æ‚«‚ÍˆÚ“®‚¹‚¸‚É^‚ğ•Ô‚·
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
          // ‘SŠp‚QƒoƒCƒg–Ú‚©A³, ¶..Ä, Ê..Î + Şß
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
      // SC = 0 ‚Ì
      // Direction =  1 ... ÅŒã‚ÌˆêŒê
      // Direction = -1 ... ƒoƒbƒtƒ@‚Ìæ“ª
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

        if sfrNoMatchZenkaku in Options then // ‘SŠpE”¼Šp‚ğ‹æ•Ê‚µ‚È‚¢
          if sfrMatchCase in Options then    // ‘å•¶š¬•¶š‚ğ‹æ•Ê‚·‚é
            if DBCSBuffer then
              MatchChar := (Pattern[P] = Result[I + C]) and
                           (Pattern[P + 1] = Result[I + C + 1])
            else
            begin                            // ‘SŠp‚É•ÏŠ·‚µ‚Ä”»•Ê
              // ³, ¶..Ä, Ê..Î + Şß
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
          else                               // ‘å•¶š¬•¶š‚ğ‹æ•Ê‚µ‚È‚¢
            if DBCSBuffer then               // ‘SŠp“¯m‚Ì”»•Ê
              MatchChar := EqualWChar(@Pattern[P], Result + I + C)
            else
            begin                            // ‘SŠp‚É•ÏŠ·‚µ‚Ä”äŠr
              // ³, ¶..Ä, Ê..Î + Şß
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
              if (S[1] = #$82) and           // ‘å•¶šƒ}ƒbƒv‚Å”»•Ê
                 (S[2] in [#$81..#$9A]) then // ‚..‚š
                MatchChar := (Pattern[P] = #$82) and
                             (Pattern[P + 1] = LDBAlpha2[S[2]])
              else
                MatchChar := (Pattern[P] = S[1]) and
                             (Pattern[P + 1] = S[2]);
            end
        else                                 // ‘SŠpE”¼Šp‚ğ‹æ•Ê‚·‚é
          if sfrMatchCase in Options then    // ‘å•¶š¬•¶š‚ğ‹æ•Ê‚·‚é
            if DBCSBuffer then
              MatchChar := DBCSPattern and
                           (Pattern[P] = Result[I + C]) and
                           (Pattern[P + 1] = Result[I + C + 1])
            else
              MatchChar := Pattern[P] = Result[I + C]
          else                               // ‘å•¶š¬•¶š‚ğ‹æ•Ê‚µ‚È‚¢
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
    //  Info.Length ‚Í SearchBuf “à‚ÅƒZƒbƒg‚³‚ê‚é
    Info.Start := P - TextLine;
    Result := True;
  end;
end;

function SearchStrings(Strings: TStrings; var Info: TStringsSearchInfo;
  const SearchString: String; Options: TSearchOptions): Boolean;
(*
  TStrings ‚É‘Î‚µ‚ÄŒŸõ‚ğs‚¤ŠÖ”B
  Info.Line ..... ŒŸõ‚ğŠJn‚·‚és”Ô†i‚Oƒx[ƒXj‚ğw’è‚·‚éB
  Info.Column ... ŒŸõ‚ğŠJn‚·‚éŒ…”Ô†i‚Oƒx[ƒXj‚ğw’è‚·‚éB
                  ‘I‘ğó‘Ô‚Ìê‡‚ÍA‘I‘ğ—ÌˆæI’[‚ğ“n‚·‚±‚ÆB
  Info.Length ... ”­Œ©‚µ‚½‚Æ‚«‚Ì•¶š—ñ’·‚³‚ªŠi”[‚³‚ê‚éB

  ã•ûŒüŒŸõ‚É‚Í‘Î‰‚µ‚Ä‚¢‚È‚¢B‚Ü‚½ sfrIncludeCRLF ‚à–³‹‚³‚ê‚éB
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
  // ‘å•¶šƒe[ƒuƒ‹
  for Ch := Low(UpperCharMap) to High(UpperCharMap) do
    UpperCharMap[Ch] := Ch;
  CharUpperBuff(PChar(@UpperCharMap), SizeOf(UpperCharMap));
end.

