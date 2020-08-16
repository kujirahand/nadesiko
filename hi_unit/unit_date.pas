unit unit_date;

interface
uses
  WIndows, SysUtils, DateUtils, unit_string, Variants;



{TDateTime���A�a��ɕϊ�����}
function DateToWareki(d: TDateTime): AnsiString;
// ������(���t)��a��ɕϊ�����
function DateToWarekiS(d: AnsiString): AnsiString;
{���t�̉��Z ex)�R������ IncDate('2001/10/30','0/3/0') �O���O IncDate('2001/1/1','-0/0/3')}
function IncDate(BaseDate: TDateTime; AddDate: AnsiString): TDateTime;
{���Ԃ̉��Z ex)�R���Ԍ� IncTime('15:0:0','3:0:0') �O�b�O IncTime('12:45:0','-0:0:3')}
function IncTime(BaseTime: TDateTime; AddTime: AnsiString): TDateTime;
function StrToDateEx(str: AnsiString): TDateTime;
{����A�a��ɑΉ��������t�ϊ��p�֐�}
function StrToDateStr(str: AnsiString): AnsiString;

function UNIXTimeToDelphiDateTime(UnixTime: LongWord): TDateTime;
function DelphiDateTimeToUNIXTime(DelphiTime : TDateTime): LongWord;

implementation

function UNIXTimeToDelphiDateTime(UnixTime: LongWord): TDateTime;
var
  TimeZoneInformation: TTimeZoneInformation;
begin
  GetTimeZoneInformation(TimeZoneInformation);
  Result := UnixDateDelta +
    (UnixTime/(24*3600)) -
    ((TimeZoneInformation.Bias) / (24 * 60));
end;

function DelphiDateTimeToUNIXTime(DelphiTime : TDateTime): LongWord;
var
  TimeZoneInformation: TTimeZoneInformation;
begin
  GetTimeZoneInformation(TimeZoneInformation);

  Result :=
    Round((DelphiTime - UnixDateDelta +
      (TimeZoneInformation.Bias / (24*60))) * SecsPerDay);
end;


{����A�a��ɑΉ��������t�ϊ��p�֐�}
function StrToDateStr(str: AnsiString): AnsiString;
begin
    Result:='';
    if str='' then Exit;
    Result := AnsiString(FormatDateTime(
        'yyyy/mm/dd',
        StrToDateEx(str)
    ));
end;

function StrToDateEx(str: AnsiString): TDateTime;
begin
    Result := Now;
    str := convToHalf(str);
    if str='' then Exit;
    if PosA('.',str)>0 then begin
      // ���l�ɕϊ��ł��邩�e�X�g
      try
        StrToFloatA(str);
      except
        // �G���[�Ȃ� yyyy.mm.dd �`������
        str := JReplaceA(str,'.','/');
      end;
    end;
    Result := VarToDateTime(str);
end;

{���Ԃ̉��Z ex)�R���Ԍ� IncTime('15:0:0','3:0:0') �O�b�O IncTime('12:45:0','-0:0:3')}
function IncTime(BaseTime: TDateTime; AddTime: AnsiString): TDateTime;
var
    flg: AnsiString;
    hh,nn,ss: Word;
begin
    // �f���t�@�C�̕W���֐����g���悤�ɕύX 2003/2/19
    // ���������������f
    flg := Copy(AddTime,1,1);
    if (flg='-')or(flg='+') then Delete(AddTime, 1,1);

    hh := StrToIntDef(string(getToken_s(AddTime,':')),0);
    nn := StrToIntDef(string(getToken_s(AddTime,':')),0);
    ss := StrToIntDef(string(AddTime), 0);
    if flg <> '-' then
    begin
      Result := IncHour(BaseTime, hh);
      Result := IncMinute(Result, nn);
      Result := IncSecond(Result, ss);
    end else
    begin
      Result := IncHour(BaseTime, hh*-1);
      Result := IncMinute(Result, nn*-1);
      Result := IncSecond(Result, ss*-1);
      if(Result<0)then Result := IncHour(Result, 24);
    end;
end;

{���t�̉��Z ex)�R������ IncDate('2001/10/30','0/3/0') �O���O IncDate('2001/1/1','-0/0/3')}
function IncDate(BaseDate: TDateTime; AddDate: AnsiString): TDateTime;
var
    flg: AnsiString;
    yy,mm,dd: Word;
begin
    // �f���t�@�C�̕W���֐����g���悤�ɕύX 2003/2/19
    // �������������̔��f
    flg := Copy(AddDate,1,1);
    if (flg='-')or(flg='+') then Delete(AddDate, 1,1);

    // �������t�𕪉�����
    yy := StrToIntDef(string(getToken_s(AddDate,'/')),0);
    mm := StrToIntDef(string(getToken_s(AddDate,'/')),0);
    dd := StrToIntDef(string(AddDate), 0);
    if flg <> '-' then
    begin
      // ����
      Result := IncYear(BaseDate, yy);
      Result := IncMonth(Result, mm);
      Result := IncDay(Result, dd);
    end else
    begin
      // ����
      Result := IncYear(BaseDate, yy*-1);
      Result := IncMonth(Result, mm*-1);
      Result := IncDay(Result, dd*-1);
    end;
end;


const
  MEIJI  = 1868; //* �C�� 2019/04/15
  TAISYO = 1912;
  SYOWA  = 1926;
  HEISEI = 1989;
  REIWA  = 2019;

{TDateTime���A�a��ɕϊ�����}
function DateToWareki(d: TDateTime): AnsiString;
var y, yy, mm, dd: Word; sy: AnsiString;
begin
    DecodeDate(d, yy, mm, dd);
    if ((MEIJI<=yy)and(yy<TAISYO))or((TAISYO=yy)and((mm<=6)or((mm=7)and(dd<=30)))) then
    begin
        y := yy-MEIJI+1;
        if y=1 then sy := '���N' else sy := IntToStrA(y)+'�N';
        Result := FormatA('����'+sy+'%d��%d��',[mm,dd]);
    end else
    if ((TAISYO<=yy)and(yy<SYOWA))or((SYOWA=yy)and((mm<=11)or((mm=12)and(dd<=25)))) then
    begin
        y := yy-TAISYO+1;
        if y=1 then sy := '���N' else sy := IntToStrA(y)+'�N';
        Result := FormatA('�吳'+sy+'%d��%d��',[mm,dd]);
    end else
    if ((SYOWA<=yy)and(yy<HEISEI))or((HEISEI=yy)and((mm=1)and(dd<=7))) then
    begin
        y := yy-SYOWA+1;
        if y=1 then sy := '���N' else sy := IntToStrA(y)+'�N';
        Result := FormatA('���a'+sy+'%d��%d��',[mm,dd]);
    end else
    if ((HEISEI<=yy)and(yy<REIWA))or((REIWA=yy)and(mm<5)) then
    begin
        y := yy-HEISEI+1;
        if y=1 then sy := '���N' else sy := IntToStrA(y)+'�N';
        Result := FormatA('����'+sy+'%d��%d��',[mm,dd]);
    end else
    if (REIWA<=yy) then
    begin
        y := yy-REIWA+1;
        if y=1 then sy := '���N' else sy := IntToStrA(y)+'�N';
        Result := FormatA('�ߘa'+sy+'%d��%d��',[mm,dd]);
    end;
end;

function DateToWarekiS(d: AnsiString): AnsiString;
var y, yy: Word; sy: AnsiString;
begin
    // �P���ɐ�������w�肳�ꂽ������
    d := convToHalf(d);
    if IsNumber(d) then
    begin
      yy := StrToIntDefA(d, 0);
      if yy < MEIJI then begin Result := ''; Exit; end;
    end else
    begin
      Result := DateToWareki(StrToDateEx(d)); Exit;
    end;

    if (MEIJI<=yy)and(yy<TAISYO) then
    begin
        y := yy-MEIJI+1;
        if y=1 then sy := '���N' else sy := IntToStrA(y)+'�N';
        Result := '����'+sy;
    end else
    if (TAISYO<=yy)and(yy<SYOWA) then
    begin
        y := yy-TAISYO+1;
        if y=1 then sy := '���N' else sy := IntToStrA(y)+'�N';
        Result := '�吳'+sy;
    end else
    if (SYOWA<=yy)and(yy<HEISEI) then
    begin
        y := yy-SYOWA+1;
        if y=1 then sy := '���N' else sy := IntToStrA(y)+'�N';
        Result := '���a'+sy;
    end else
    if (HEISEI<=yy)and(yy<REIWA) then
    begin
        y := yy-HEISEI+1;
        if y=1 then sy := '���N' else sy := IntToStrA(y)+'�N';
        Result := '����'+sy;
    end else
    if (REIWA<=yy) then
    begin
        y := yy-REIWA+1;
        if y=1 then sy := '���N' else sy := IntToStrA(y)+'�N';
        Result := '�ߘa'+sy;
    end;
end;

end.
