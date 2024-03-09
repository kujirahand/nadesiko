unit EasyMasks;
{---------------------------------------------------------------
�쐬�ҁF�N�W����s��( mine@text2music.com )
�쐬���F2002/04/11
�C�����F2003/07/26  "s*" �� "s" ���}�b�`���Ȃ��o�O

���@���F

�ȒP�ȃ��C���h�J�[�h�̃}�b�`�N���X

���C���h�J�[�h�̈Ӗ�

* �C�ӂ̕�������
? �C�ӂ̂P����
----------------------------------------------------------------}

interface
uses
  SysUtils;

type
  TEasyMask = class
  private
    si : Integer; // FStr  �̃C���f�b�N�X
    mi : Integer; // FMask �̃C���f�b�N�X
    function CheckChar: Boolean;
    function SubMatch : Boolean;
  public
    FStr     : WideString;
    FMask    : WideString;
    function Match : Boolean;
  end;

// Delphi �� MatchesMask ����(�啶������������ʂ��Ȃ�)
function MatchesMask(const FileName, Masks: string) : Boolean;
//(�啶������������ʂ���)
function MatchesMask2(const FileName, Masks: string) : Boolean;

implementation

function MatchesMask2(const FileName, Masks: string) : Boolean;
var
  e: TEasyMask;
begin
  e := TEasyMask.Create ;
  try
    e.FStr  := FileName;
    e.FMask := Masks;
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
    Inc(mi); // * ���X�L�b�v

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
  // �f�t�H���g�́ATRUE
  Result := True;

  // ���ꂼ�� INDEX �ɂ���P�����𓾂�
  if si <= Length(FStr)  then ss := FStr[si]  else ss := #0;
  if mi <= Length(FMask) then ms := FMask[mi] else ms := #0;

  // ���v���Ă��邩�H
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
