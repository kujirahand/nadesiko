unit EasyMasks;
{---------------------------------------------------------------
作成者：クジラ飛行机( http://kujirahand.com )
作成日：2002/04/11
修正日：2003/07/26  "s*" で "s" がマッチしないバグ

解　説：

簡単なワイルドカードのマッチクラス

ワイルドカードの意味

* 任意の複数文字
? 任意の１文字
----------------------------------------------------------------}

interface
uses
  SysUtils;

type
  TEasyMask = class
  private
    si : Integer; // FStr  のインデックス
    mi : Integer; // FMask のインデックス
    function CheckChar: Boolean;
    function SubMatch : Boolean;
  public
    FStr     : WideString;
    FMask    : WideString;
    function Match : Boolean;
  end;

// Delphi の MatchesMask 準拠(大文字小文字を区別しない)
function MatchesMask(const FileName, Masks: string) : Boolean;
//(大文字小文字を区別する)
function MatchesMask2(const FileName, Masks: string) : Boolean;

implementation

function MatchesMask2(const FileName, Masks: string) : Boolean;
var
  e: TEasyMask;
begin
  e := TEasyMask.Create ;
  try
    e.FStr  := string(FileName);
    e.FMask := string(Masks);
    Result := e.Match ;
  finally
    e.Free ;
  end;
end;

{ TEasyMask }

function TEasyMask.CheckChar: Boolean;
var
  ss, ms: WideChar;
  tsi, tmi, i: Integer;

  procedure Next;
  begin
    Inc(si);
    Inc(mi);
  end;

  procedure subWildCard;
  var
    str2, mask2: WideString;
  begin
    Inc(mi); // * をスキップ

    tsi := si; tmi := mi;
    i := 0;
    while True do
    begin
      mi := tmi;
      si := tsi + i;

      str2  := Copy(FStr,  si, Length(FStr)  - si + 1);
      mask2 := Copy(FMask, mi, Length(FMask) - mi + 1);

      if MatchesMask2(str2, mask2) then
      begin
        Result := True; Exit;
      end;

      if si > Length(FStr) then
      begin
        Result := False;
        Exit;
      end;
      Inc(i);
    end;
  end;

begin
  // デフォルトは、TRUE
  Result := True;

  // それぞれ INDEX にある１文字を得る
  if si <= Length(FStr)  then ss := FStr[si]  else ss := #0;
  if mi <= Length(FMask) then ms := FMask[mi] else ms := #0;

  // 合致しているか？
  if ss=ms then // Equal
  begin
    Next; Exit;
  end;

  if ms='?' then // ?
  begin
    Next; Exit;
  end;

  if ms='*' then // *
  begin
    subWildCard; Exit;
  end;

  Result := False;
end;

function TEasyMask.Match: Boolean;
begin
  si := 1;
  mi := 1;
  Result := SubMatch;
end;

function TEasyMask.SubMatch: Boolean;
begin
  Result := True;

  while (Result) do
  begin
    if (mi > Length(FMask)) and (si > Length(FStr)) then
    begin
      Break;
    end;
    Result := CheckChar;
  end;
end;


function MatchesMask(const FileName, Masks: string) : Boolean;
var m: TEasyMask;
begin
  m := TEasyMask.Create ;
  try
    m.FStr  := FileName;
    m.FMask := Masks;

    m.FStr  := UpperCase(m.FStr);
    m.FMask := UpperCase(m.FMask);
    Result  := m.Match ;
  finally
      m.Free ;
  end;
end;

end.
