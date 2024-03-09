unit jconvertex;

// Ｍ＆Ｉ様の作ったユニットです
// http://member.nifty.ne.jp/m-and-i/tips/jconex.htm より参照：感謝！
// 一部改変 クジラ飛行机(2005/01/28)

interface

uses
  Windows, SysUtils, jconvert, Classes;

const
  UNILE_IN   = 7; // Unicode Little Endian(Intel CPU)
  UNIBE_IN   = 8; // Unicode Big Endian
  UTF8_IN    = 9; // UTF8(TTF8NのBOM付き)
  UTF8N_IN   = 10;// UTF8N

  UNILE_OUT  = 7;
  UNIBE_OUT  = 8;
  UTF8_OUT   = 9;
  UTF8N_OUT  = 10;

// 拡張文字コードチェック
function InCodeCheckEx(const s: AnsiString): integer;
// UNICODE(Little Endian)をSJISに変換する
function uniLETosjis(const s: PWideChar): string;
function uniLETosjis2(const s: string): string; // 文字列型で与えられたUNICODEをsjisに変換
// UNICODE(Big Endian)をSJISに変換する
function uniBETosjis(const s: PWideChar): string;
function uniBETosjis2(const s: string): string;
// UTF8をSJISに変換する
function Utf8Tosjis(const s: String): string;
// UTF8NをSJISに変換する
function Utf8NTosjis(const s: String): string;

// SJISをUNICODE(LE)に変換する
procedure sjisToUniLE(var ms: TMemoryStream; const s: string);
function sjisToUniLE2(const s: string): string;
// SJISをUNICODE(BE)に変換する
procedure sjisToUniBE(var ms: TMemoryStream; const s: string);
function sjisToUniBE2(const s: string): string;
// SJISをUNICODE(UTF8)に変換する
function sjisToUtf8(const s: string): string;
// SJISをUNICODE(UTF8N)に変換する
function sjisToUtf8N(const s: string): string;


implementation

// 拡張文字コードチェック
// UNICODEとUTF8をチェックし、そのどれらでもなかった場合には
// jconvertのInCodeCheckを戻り値にする
(*
function InCodeCheckEx(const s: string): integer;
var
  index, c, size: Integer;
  utfk: Boolean;
begin
  size := Length(s);
  { Size = 0 }
  if size = 0 then
  begin
    Result := BINARY;
    Exit;
  end;
  { Unicodeをチェックする }
  { 先頭のBOMしかチェックしていないので誤作動の可能性あり }
  if (size >= 2 ) then
  begin
    { UNICODE(Little Endian)チェック }
    if (s[1] = #$FF) and (s[2] = #$FE) then
    begin
      Result := UNILE_IN;
      Exit;
    end;
    { UNICODE(Big Endian)チェック }
    if (s[1] = #$FE) and (s[2] = #$FF) then
    begin
      Result := UNIBE_IN;
      Exit;
    end;
  end;
  { UTF-8をチェックする }
  if size > 3 then
  begin
    { UTF-8N(BOMあり)チェック }
    { 先頭のBOMしかチェックしていないので誤作動の可能性あり }
    if (s[1] = #$EF) and (s[2] = #$BB) and (s[3] = #$BF) then
    begin
      Result := UTF8_IN;
      Exit;
    end;
  end;
  {UTF-8(BOMなし)チェック}
  index := 1;
  utfk := False;
  while (index <= STRICT_CHECK_LEN) and (index < size - 4) do
  begin
    c := Ord(s[index]);
    if (c in [$C0..$DF]) or (c > $EF) then
    begin
      utfk := False;
      Break;
    end;
    if c in [0..$7F] then
    begin
      ;
    end else if c = $E0 then
    begin
      Inc(index);
      c := Ord(s[index]);
      if c in [$A0..$BF] then
      begin
        Inc(index);
        c := Ord(s[index]);
        if c in [$80..$BF] then
          utfk := True
        else begin
          utfk := False;
          Break;
        end;
      end else begin
        utfk := False;
        Break;
      end;
    end else if c in [$E1..$EF] then
    begin
      Inc(index);
      c := Ord(s[index]);
      if c in [$80..$BF] then
      begin
        Inc(index);
        c := Ord(s[index]);
        if c in [$80..$BF] then
          utfk := True
        else begin
          utfk := False;
          Break;
        end;
      end else begin
        utfk := False;
        Break;
      end;
    end else begin
      utfk := False;
      Break;
    end;
    Inc(index);
  end;
  { 漢字があったらUTF }
  if utfk then
    Result := UTF8N_IN
  { UnicdeでもUTF8でもなければJconvertでチェック }
  else
    Result := InCodeCheck(s);
end;
*) // 本家のチェック

//クジラ式チェック
//以下のＷＥＢを参考にした
//http://www.gprj.net/dev/tips/other/kanji.shtml

function InCodeCheckEx(const s: AnsiString): Integer;
var
  i, rMax, rMaxV, maxLen, sLen: Integer;
  FlagUTF8Bom: Boolean;
  FlagStrict: Boolean; // 文字コードが確定したかどうか
  rate: array [0..10] of Integer;

  procedure IncRate(code, v: Integer);
  begin
    rate[code] := rate[code] + v;
  end;

  procedure check_ISO2022JP;
  begin
    // ISO-2022-JPのチェック
    { 1    2    3
      0x1B 0x24 0x40       JIS X 0208-1978
      0x1B 0x24 0x42       JIS X 0208-1983
      0x1B 0x24 0x28 0x44  JIS X 0208-1990
      0x1B 0x24 0x28 0x4F  JIS X 0213:2000 1面
      0x1B 0x24 0x28 0x50  JIS X 0213:2000 2面
      0x1B 0x24 0x42       JIS X 0208-1990
      0x1B 0x26 0x40       JIS X 0208-1990
      0x1B 0x28 0x49       JIS X 0201-1976 片仮名
      0x1B 0x28 0x42       ASCII
      0x1B 0x28 0x4A       JIS X 0201-1976 Roman Set
      0x1B 0x28 0x48       JIS X 0201-1976 Roman Set
    }

    if (i+3) <= slen then
    begin

      if s[i] = #$1B{ESC} then
      begin
        case s[i+1] of
          #$24:
            begin
              case s[i+2] of
                #$40: Result := JIS78_IN;
                #$42: Result := JIS83_IN;
                #$44: Result := JIS83_IN; // 本当は JIS90 だけど
                else  Result := JIS83_IN;
              end;
            end;
          #$28:
            begin
              Result := JIS78_IN; // 本当は JIS76 だけど
            end;
          #$26:
            begin
              Result := JIS83_IN; // 本当は JIS90 だけど
            end;
          else
            begin
              FlagStrict := True;
              Exit;
            end;
        end;
        FlagStrict := True;
      end;

    end;
  end;

  procedure check_UTF8;
  var
    cb: Byte;
    temp: Integer;

    function chk(count: Integer): Boolean;
    var k: Integer; b: Byte;
    begin
      Result := False;
      if (i+count) > slen then Exit;
      // check
      for k := 1 to count do
      begin
        b := Ord(s[i + k]);
        if not ( ($80 <= b) and (b <= $BF) ) then
        begin
          rate[UTF8N_IN] := 0; // 可能性が低い
          Exit; // False
        end;
      end;
      // ok
      Result := True;
      Exit;
    end;

  begin
    // UTF-8 のチェック
    if not( (#$C0 <= s[i])and(s[i] <= #$FD) ) then Exit; // 可能性がない

    temp := i;

    // BOMか？
    if Copy(s, i, 3) = #$EF+#$BB+#$BF then
    begin
      FlagUTF8Bom := True;
      Inc(i, 3);
      if i > sLen then Exit; // FALSE
    end;

    // UTF-8 の１バイト目(可変)
    // 第1バイトを見て0xC0<->0xFD内であればUTF-8の強い可能性
    // 第2バイト以降を指定されたサイズ分0x80<->0xBFの範囲内かどうかチェック
    // 2バイト以降は、0x80<->0xBF になる
    {
    AND 0xFC ... 5バイト(RFC2279(破棄RFC))
    AND 0xF8 ... 4バイト
    AND 0xF0 ... 3バイト
    AND 0xE0 ... 2バイト
    AND 0xC0 ... 1バイト(先頭バイトが文字をあらわす)
    }

    while i <= maxLen do // 繰り返し可能性をチェック
    begin
      IncRate(UTF8N_IN, 1); //

      // 1バイト目をチェック
      cb := Ord(s[i]);
      if (cb and $FC) = $FC then
      begin
        if chk(5) = False then Exit; // False
        Result := UTF8N_IN;
        Inc(i); Inc(i, 5);
      end else
      if (cb and $F8) = $F8 then
      begin
        if chk(4) = False then Exit; // False
        Result := UTF8N_IN;
        Inc(i); Inc(i, 4);
      end else
      if (cb and $F0) = $F0 then
      begin
        if chk(3) = False then Exit; // False
        Result := UTF8N_IN;
        Inc(i); Inc(i, 3);
      end else
      if (cb and $E0) = $E0 then
      begin
        if chk(2) = False then Exit; // False
        Result := UTF8N_IN;
        Inc(i); Inc(i, 2);
      end else
      if (cb and $C0) = $C0 then
      begin
        //if chk(1) = False then Exit; // False
        Result := UTF8N_IN;
        Inc(i); Inc(i);
      end else
      // 1 バイト
      begin
        if cb < $80 then
        begin
          Inc(i);
        end else
        begin
          i := temp;
          FlagStrict := False;
          Exit;
        end;
      end;
    end;
    //
  end;

  procedure check_EUC;
  begin
    { EUC
      第1バイト         0xA1<->0xFE
      第2バイト         0x8E(1バイト目) + 0xA1<->0xDF
      半角カナ          0xA4(1バイト目) + 0xA1<->0xF3
      全角かな(あ～ん)  0xA5(1バイト目) + 0xA1<->0xF6
      全角カナ(ア～ン)  0x8F(1バイト目) + 0xA1<->0xFE(2・3バイト目)
      補助漢字 0xA1<->0xFE
      --------------------
    }
    {
      EUC 半角カナのチェック

    第1バイトが0x8Eで第2バイトが0xA1<->0xDFな場合はEUC半角カナの強い可能性
    ただし既に他の文字コードの強い可能性ありと判断されてない場合に限る
    第2バイトがEUC半角カナ範囲外で0x80<->0xA0であるならばSJIS(確定)
    以上に当てはまらない場合は不明コード

    }
    if ((i+2) > slen) then Exit;
    // 半角カナの可能性
    if (s[i] = #$8E) then
    begin
      // SJIS かも？
      if s[i+1] in [#$80..#$A0] then
      begin
        // SJIS確定
        Result := SJIS_IN;
        FlagStrict := True;
        Exit;
      end;
      if s[i+1] in [#$A1..#$DF] then // 強い可能性
      begin
        // EUCカナの可能性 ... 確定しない
        Result := EUC_IN;
        IncRate(EUC_IN, 2);
      end;
    end;
    {
    第1バイトが0x8Fで第2・3バイトが0xA1<->0xFEな場合はEUC補助漢字の強い可能性
    ただし既に他の文字コードの強い可能性ありと判断されてない場合に限る
    第2・3バイトどちらかが0xFD・0xFEであるならばEUC補助漢字(確定)
    第2・3バイトがEUC補助漢字範囲外で0x80<->0xA0であるならばSJIS(確定)
    以上に当てはまらない場合は不明コード
    }
    // ＥＵＣ補助漢字の可能性
    if (s[i] = #$8F)and((i+3) <= slen) then
    begin
      if (s[i+1] in [#$A1..#$FE])and((s[i+2] in [#$A1..#$FE])) then
      begin
        Result := EUC_IN; // EUCの可能性
        IncRate(EUC_IN,1);

        // 確定するか？
        if (s[i+1] in [#$FD,#$FE]) or (s[i+2] in [#$FD,#$FE]) then
        begin
          FlagStrict := True; Exit;
        end;
      end;
    end;
    //

  end;

  procedure check_SJIS;
  begin
    // SJIS
    // 0x80<->0xA0であるならばSJISで確定
    if s[i] in [#$80..#$A0] then
    begin
      FlagStrict := True;
      Result := SJIS_IN;
      Exit;
    end;
    // 1byte目
    if s[i] in [#$81..#$9F,#$E0..#$EF] then
    begin
      IncRate(SJIS_IN, 1);
      // 2byte目
      if (i+1) <= slen then
      begin
        if s[i+1] in [#$40..#$7E, #$80..#$FC] then
        begin
          IncRate(SJIS_IN,1);
        end;
      end;
    end;
    {
    0xA1<->0xDFが出た場合はSJIS半角カナ・EUC全角かな・カナの強い可能性
    ただし既に他の文字コードの強い可能性と判断されてない場合に限る
    第1バイトが0xA4か0xA5で第2バイトが[かな]0xA1<->0xF3[カナ]0xA1<->0xF6であるならば
    EUC全角ひらがな・カタカナの弱い可能性
    第2バイトをチェックして0xE0<->0xFEであるならばEUCの強い可能性で0xFD・0xFEの場合はEUC(確定)
    第2バイトが存在しない場合はSJISの強い可能性
    以上に当てはまらない場合はSJIS半角カナの強い可能性
    }
    if (i+1) > slen then
    begin
      // 第２バイトが存在しない
      if s[i] in [#$A1..#$DF] then
      begin
        Result := SJIS_IN; FlagStrict := True; // 半角カナで決定
      end;
      Exit;
    end;
    // SJIS 半角カナの判定
    if s[i] in [#$A1..#$DF] then // SJIS半角カナ or EUC全角かな・カナの可能性
    begin
      IncRate(SJIS_IN, 1);
      if (s[i] in [#$A4,#$A5])and(s[i+1] in [#$A1..#$F6]) then // EUC全角ひらがな・カタカナの弱い可能性
      begin
        IncRate(EUC_IN,1);
      end else
      if s[i+1] in [#$E0..#$FE] then //EUCの強い可能性
      begin
        IncRate(EUC_IN,1);
        Result := EUC_IN;
        if s[i+1] in [#$FD,#$FE] then
        begin
          FlagStrict := True; Exit;
        end;
      end else
      begin
        IncRate(SJIS_IN,1);
        Result := SJIS_IN; // 可能性がある
      end;
    end;
  end;

  procedure check_UNICODE;
  begin
    { Unicodeをチェックする }
    { 先頭のBOMしかチェックしていないので誤作動の可能性あり }
    if (sLen >= 2 ) then
    begin
      { UNICODE(Little Endian)チェック }
      if (s[1] = #$FF) and (s[2] = #$FE) then
      begin
        Result := UNILE_IN;
        FlagStrict := True;
      end;
      { UNICODE(Big Endian)チェック }
      if (s[1] = #$FE) and (s[2] = #$FF) then
      begin
        Result := UNIBE_IN;
        FlagStrict := True;
      end;
    end;
  end;

begin
  Result := BINARY;
  if s = '' then Exit;

  // 調査初期設定
  maxLen := Length(s);
  sLen   := maxLen;
  if maxLen > STRICT_CHECK_LEN then maxLen := STRICT_CHECK_LEN;
  FlagUTF8Bom := False;
  FlagStrict  := False; // 文字コードが確定したかどうか


  // UNICODE の判定は手抜き
  check_UNICODE;

  // 全てASCIIかも？
  FlagStrict := True;
  for i := 1 to maxLen do
  begin
    if not(Ord(s[i]) in [$21..$7E]) then
    begin
      FlagStrict := False;
      Break;
    end;
  end;
  if FlagStrict then
  begin
    Result := ASCII; Exit;
  end;


  // 本格調査開始
  FlagStrict := False;
  for i := 0 to High(rate) do
  begin
    rate[i] := 0;
  end;
  
  i := 1;
  while i <= maxLen do
  begin
    // JIS は確定する
    check_ISO2022JP;
    if FlagStrict then Exit;

    // UTF-8/UTF-8N
    check_UTF8;

    // UNICODE
    check_UNICODE;
    if FlagStrict then Exit;

    // EUCカナ・補助
    check_EUC;
    if FlagStrict then Exit;

    // SJIS
    check_SJIS;
    if FlagStrict then Exit;

    // EUC判定
    {0xA1<->0xFEの場合はEUCの強い可能性で0xFD・0xFEの場合はEUC(確定)}
    if s[i] in [#$A1..#$FE] then
    begin
      Result := EUC_IN;
      IncRate(EUC_IN,1);
      if s[i] in [#$FD,#$FE] then Exit; // EUC確定
    end;

    Inc(i);
  end;

  // ここで可能性テスト
  // 可能性があっても決定しなかった場合
  // 一番確率が高いものを採用
  rMax := ASCII; rMaxV := 0;
  for i := 0 to High(rate) do
  begin
    if rate[i] > rMaxV then
    begin
      rMax := i; rMaxV := rate[i];
    end;
  end;
  Result := rMax;

  if Result = UTF8N_IN then
  begin
    // BOM でチェック
    if FlagUTF8Bom then
    begin
      Result := UTF8_IN;
    end else
    begin
      Result := UTF8N_IN;
    end;
  end;

end;


function UniLETosjis(const s: PWideChar): string;
begin
  Result := WideCharToString(s);
end;

function uniLETosjis2(const s: string): string; // 文字列型で与えられたUNICODEをsjisに変換
begin
  if s <> '' then
  begin
    Result := WideCharToString(@s[1]);
  end else
  begin
    Result := '';
  end;
end;

function uniBETosjis2(const s: string): string;
begin
  if s <> '' then
  begin
    Result := UniBETosjis(@s[1]);
  end else
  begin
    Result := '';
  end;
end;


function UniBETosjis(const s: PWideChar): string;
var
  Pc: PChar;
  c: char;
  n: integer;
begin
  Pc := PChar(s);
  n := 0;
  while True do
  begin
    if (Pc[n] = #0) and (Pc[n+1] = #0) then
      Break;
    c := Pc[n];
    Pc[n] := Pc[n+1];
    Pc[n+1] := c;
    Inc(n, 2);
  end;
  Result := WideCharToString(PWideChar(Pc));
end;

procedure sjisToUniLE(var ms: TMemoryStream; const s: string);
var
  PWs: PWideChar;
  Len: integer;
begin
  if not Assigned(ms) then
    raise Exception.Create('無効なMemoryStream.');
  Len := Length(s) * 2;
  PWs := AllocMem(Len + 2);
  try
    StringToWideChar(s, PWs, Len);
    ms.Write(#$FF#$FE, 2);
    ms.Write(PWs^, Length(Pws) * 2);
  finally
    FreeMem(PWs);
  end;
end;

function sjisToUniLE2(const s: string): string;
var
  i, len, sLen: Integer;
begin
  sLen := Length(s);
  len := sLen * 2;
  SetLength(Result, len + 2);
  StringToWideChar(s, @Result[1], len);
  // 長さを測る
  len := 2;
  for i := 0 to sLen-1 do
  begin
    if Result[i*2+1] = #0 then // 1 バイト目が0ならば終端
    begin
      len := i*2; Break;
    end;
  end;
  Result := Copy(Result, 1, len);
  Result := #$FF#$FE + Result;
end;

function sjisToUniBE2(const s: string): string;
var
  m: TMemoryStream;
begin
  m := TMemoryStream.Create;
  try
    sjisToUniBe(m, s);
    SetLength(Result, m.Size);
    m.Position := 0;
    if m.Size > 0 then
    begin
      m.Write(Result[1], m.Size);
    end else
    begin
      Result := '';
    end;
  finally
    m.Free;
  end;
end;

procedure sjisToUniBE(var ms: TMemoryStream; const s: string);
var
  PWs: PWideChar;
  Pc: PChar;
  len, n: integer;
  Tc: Char;
begin
  if not Assigned(ms) then
    raise Exception.Create('無効なMemoryStream.');
  Len := Length(s) * 2;
  PWs := AllocMem(Len + 2);
  try
    StringToWideChar(s, PWs, Len);
    Pc := PChar(PWs);
    n := 0;
    while n < len do
    begin
      Tc := (Pc+n)^;
      (Pc+n)^ := (Pc+n+1)^;
      (Pc+n+1)^ := Tc;
      Inc(n, 2);
    end;
    ms.Write(#$FE#$FF, 2);
    ms.Write(PWs^, Length(Pws) * 2);
  finally
    FreeMem(PWs);
  end;
end;

function Utf8NTosjis(const s: string): string;
{
var
  Len: integer;
  OutStr: PWideChar;
  SIn, SOut: string;
}
begin
  Result := Utf8ToAnsi(s); // Delphi 8 標準の関数
  {

  Result := '';
  // ゴミ防止
  SIn := S + #0#0;
  Len := MultiByteToWideChar(CP_UTF8, 0, PChar(SIn), Length(SIn), nil, 0);
  if Len = 0 then
    raise Exception.Create('UTF8の文字列変換に失敗しました.');
  // Lenで良いはずだが、なぜかエラーとなるため２倍
  OutStr := AllocMem(Len * 2);
  try
    MultiByteToWideChar(CP_UTF8, 0, PChar(SIn), Length(SIn), OutStr, Len);
    WideCharToStrVar(OutStr, SOut);
    Result := SOut;
  finally
    FreeMem(OutStr);
  end;

  }
end;

function Utf8Tosjis(const s: string): string;
var
  s2: string;
begin
  s2 := s;
  // #$EF#$BB#$BFがあるか判別
  if Copy(s2,1,3) = #$EF#$BB#$BF then
  begin
    Delete(s2, 1, 3);
  end;
  Result := Utf8NTosjis(s2);
end;

function SjisToUtf8N(const s: string): string;
{
var
  Len: integer;
  InStr: PWideChar;
  OutStr: PChar;
}
begin
  Result := AnsiToUtf8(s); // Delphi 8 標準の関数
{
  Result := '';
  Len := Length(s) * 2 + 2;
  InStr := AllocMem(Len);
  try
    StringToWideChar(s, InStr, Len);
    OutStr := AllocMem(Len);
    try
      WideCharToMultiByte(CP_UTF8, 0, InStr, Length(InStr) * 2, OutStr, Len, nil, nil);
      Result := OutStr;
    finally
      FreeMem(OutStr);
    end;
  finally
    FreeMem(InStr);
  end;
}
end;

function SjisToUtf8(const s: string): string;
begin
  Result := #$EF#$BB#$BF + SjisToUtf8N(s);
end;

end.

