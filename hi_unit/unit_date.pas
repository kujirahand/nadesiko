unit unit_date;

interface
uses
  WIndows, SysUtils, DateUtils, unit_string, Variants;



{TDateTimeを、和暦に変換する}
function DateToWareki(d: TDateTime): AnsiString;
// 文字列(日付)を和暦に変換する
function DateToWarekiS(d: AnsiString): AnsiString;
{日付の加算 ex)３ヵ月後 IncDate('2001/10/30','0/3/0') 三日前 IncDate('2001/1/1','-0/0/3')}
function IncDate(BaseDate: TDateTime; AddDate: AnsiString): TDateTime;
{時間の加算 ex)３時間後 IncTime('15:0:0','3:0:0') 三秒前 IncTime('12:45:0','-0:0:3')}
function IncTime(BaseTime: TDateTime; AddTime: AnsiString): TDateTime;
function StrToDateEx(str: AnsiString): TDateTime;
{西暦、和暦に対応した日付変換用関数}
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


{西暦、和暦に対応した日付変換用関数}
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
    if PosA('.',str)>0 then str := JReplaceA(str,'.','/');
    Result := VarToDateTime(str);
end;

{時間の加算 ex)３時間後 IncTime('15:0:0','3:0:0') 三秒前 IncTime('12:45:0','-0:0:3')}
function IncTime(BaseTime: TDateTime; AddTime: AnsiString): TDateTime;
var
    flg: AnsiString;
    hh,nn,ss: Word;
begin
    // デルファイの標準関数を使うように変更 2003/2/19
    // 足すか引くか判断
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

{日付の加算 ex)３ヵ月後 IncDate('2001/10/30','0/3/0') 三日前 IncDate('2001/1/1','-0/0/3')}
function IncDate(BaseDate: TDateTime; AddDate: AnsiString): TDateTime;
var
    flg: AnsiString;
    yy,mm,dd: Word;
begin
    // デルファイの標準関数を使うように変更 2003/2/19
    // 足すか引くかの判断
    flg := Copy(AddDate,1,1);
    if (flg='-')or(flg='+') then Delete(AddDate, 1,1);

    // 足す日付を分解する
    yy := StrToIntDef(string(getToken_s(AddDate,'/')),0);
    mm := StrToIntDef(string(getToken_s(AddDate,'/')),0);
    dd := StrToIntDef(string(AddDate), 0);
    if flg <> '-' then
    begin
      // 足す
      Result := IncYear(BaseDate, yy);
      Result := IncMonth(Result, mm);
      Result := IncDay(Result, dd);
    end else
    begin
      // 引く
      Result := IncYear(BaseDate, yy*-1);
      Result := IncMonth(Result, mm*-1);
      Result := IncDay(Result, dd*-1);
    end;
end;


const
  MEIJI  = 1868; //* 修正 2003/09/28
  TAISYO = 1912;
  SYOWA  = 1926;
  HEISEI = 1989;

{TDateTimeを、和暦に変換する}
function DateToWareki(d: TDateTime): AnsiString;
var y, yy, mm, dd: Word; sy: AnsiString;
begin
    DecodeDate(d, yy, mm, dd);
    if ((MEIJI<=yy)and(yy<TAISYO))or((TAISYO=yy)and((mm<=6)or((mm=7)and(dd<=30)))) then
    begin
        y := yy-MEIJI+1;
        if y=1 then sy := '元年' else sy := IntToStrA(y)+'年';
        Result := FormatA('明治'+sy+'%d月%d日',[mm,dd]);
    end else
    if ((TAISYO<=yy)and(yy<SYOWA))or((SYOWA=yy)and((mm<=11)or((mm=12)and(dd<=25)))) then
    begin
        y := yy-TAISYO+1;
        if y=1 then sy := '元年' else sy := IntToStrA(y)+'年';
        Result := FormatA('大正'+sy+'%d月%d日',[mm,dd]);
    end else
    if ((SYOWA<=yy)and(yy<HEISEI))or((HEISEI=yy)and((mm=1)and(dd<=7))) then
    begin
        y := yy-SYOWA+1;
        if y=1 then sy := '元年' else sy := IntToStrA(y)+'年';
        Result := FormatA('昭和'+sy+'%d月%d日',[mm,dd]);
    end else
    if (HEISEI<=yy) then
    begin
        y := yy-HEISEI+1;
        if y=1 then sy := '元年' else sy := IntToStrA(y)+'年';
        Result := FormatA('平成'+sy+'%d月%d日',[mm,dd]);
    end;
end;

function DateToWarekiS(d: AnsiString): AnsiString;
var y, yy: Word; sy: AnsiString;
begin
    // 単純に西暦だけが指定されたか調査
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
        if y=1 then sy := '元年' else sy := IntToStrA(y)+'年';
        Result := '明治'+sy;
    end else
    if (TAISYO<=yy)and(yy<SYOWA) then
    begin
        y := yy-TAISYO+1;
        if y=1 then sy := '元年' else sy := IntToStrA(y)+'年';
        Result := '大正'+sy;
    end else
    if (SYOWA<=yy)and(yy<HEISEI) then
    begin
        y := yy-SYOWA+1;
        if y=1 then sy := '元年' else sy := IntToStrA(y)+'年';
        Result := '昭和'+sy;
    end else
    if (HEISEI<=yy) then
    begin
        y := yy-HEISEI+1;
        if y=1 then sy := '元年' else sy := IntToStrA(y)+'年';
        Result := '平成'+sy;
    end;
end;

end.
