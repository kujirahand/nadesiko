unit dll_date_function;

interface

uses
  Windows, SysUtils;

procedure RegistFunction;

implementation

uses dll_plugin_helper, dnako_import, dnako_import_types, Variants, qreki,
  DateUtils;


function cmd_qreki(h: DWORD): PHiValue; stdcall;
var
  s: string;
  dt: TDateTime; y,m,d: Word;
  q: TRecQreki;
begin
  s := getArgStr(h, 0, True);
  try
    dt := VarToDateTime(s);
    DecodeDate(dt, y, m, d);
    q := calc_kyureki(y, m, d);
    if q.uruu = 0 then
      Result := hi_newStr(Format('%0.2d/%0.2d/%0.2d',[q.q_yaer, q.q_mon, q.q_day]))
    else
      Result := hi_newStr(Format('%0.2d/閏%0.2d/%0.2d',[q.q_yaer, q.q_mon, q.q_day]));
  except
    Result := nil;
  end;
end;

function cmd_rokuyou(h: DWORD): PHiValue; stdcall;
var
  s: string;
  dt: TDateTime; y,m,d: Word;
begin
  s := getArgStr(h, 0, True);
  try
    dt := VarToDateTime(s);
    DecodeDate(dt, y, m, d);
    s := get_rokuyouStr(y,m,d);
    Result := hi_newStr(s);
  except
    Result := nil;
  end;
end;

function cmd_24sekki(h: DWORD): PHiValue; stdcall;
var
  s: string;
  dt: TDateTime; y,m,d: Word;
begin
  s := getArgStr(h, 0, True);
  try
    dt := VarToDateTime(s);
    DecodeDate(dt, y, m, d);
    s := get_24sekki(y,m,d);
    Result := hi_newStr(s);
  except
    Result := nil;
  end;
end;

function cmd_hinoeto(h: DWORD): PHiValue; stdcall;
var
  s: string;
  dt: TDateTime; y,m,d: Word;
begin
  s := getArgStr(h, 0, True);
  try
    dt := VarToDateTime(s);
    DecodeDate(dt, y, m, d);
    s := Calc_hino_eto(y,m,d);
    Result := hi_newStr(s);
  except
    Result := nil;
  end;
end;


function cmd_nennoeto(h: DWORD): PHiValue; stdcall;
var
  s: string;
  dt: TDateTime; y,m,d: Word;
begin
  s := getArgStr(h, 0, True);
  try
    dt := VarToDateTime(s);
    DecodeDate(dt, y, m, d);
  except
    y := StrToIntDef(s, 0);
  end;
  if y <= 0 then
  begin
    Result := nil;
  end else
  begin
    s := Calc_nenno_eto(y);
    Result := hi_newStr(s);
  end;
end;

function cmd_mjd(h: DWORD): PHiValue; stdcall;
var
  s: string;
  dt: TDateTime; y,m,d: Word;
  res: Integer;
begin
  s := getArgStr(h, 0, True);
  try
    dt := VarToDateTime(s);
    DecodeDate(dt, y, m, d);
    res := Trunc(YMDT2JD(y,m,d,12,0,0))-2400000;
    Result := hi_newInt(res);
  except
    Result := nil;
  end;
end;

function cmd_seiza(h: DWORD): PHiValue; stdcall;
var
  s, ret: string;
  d: TDateTime;
  yyyy,mm,dd, hh, nn, ss, ms: WORD;
begin
  s := getArgStr(h, 0, True);
  d := VarToDateTime(s);
  DecodeDateTime(d, yyyy, mm, dd, hh, nn, ss, ms);
{
山羊座（12/22 - 1/19生）
水瓶座（1/20 - 2/18生）
魚座（2/19 - 3/20生）
牡羊座（3/21 - 4/19生）
牡牛座（4/20 - 5/20生）
双子座(5/21 - 6/21生)
蟹座（6/22 - 7/22生）
獅子座（7/23 - 8/22生）
乙女座（8/23 - 9/22生）
天秤座（9/23 - 10/23生）
蠍座（10/24 - 11/22生）
射手座（11/23 - 12/21生）
山羊座（12/22 - 1/19生）
}
  case mm of
    1:
      begin
        if dd <= 19 then ret := '山羊座' else ret := '水瓶座';
      end;
    2:
      begin
        if dd <= 18 then ret := '水瓶座' else ret := '魚座';
      end;
    3:
      begin
        if dd <= 20 then ret := '魚座' else ret := '牡羊座';
      end;
    4:
      begin
        if dd <= 19 then ret := '牡羊座' else ret := '牡牛座';
      end;
    5:
      begin
        if dd <= 20 then ret := '牡牛座' else ret := '双子座';
      end;
    6:
      begin
        if dd <= 21 then ret := '双子座' else ret := '蟹座';
      end;
    7:
      begin
        if dd <= 22 then ret := '蟹座' else ret := '獅子座';
      end;
    8:
      begin
        if dd <= 22 then ret := '獅子座' else ret := '乙女座';
      end;
    9:
      begin
        if dd <= 22 then ret := '乙女座' else ret := '天秤座';
      end;
    10:
      begin
        if dd <= 23 then ret := '天秤座' else ret := '蠍座';
      end;
    11:
      begin
        if dd <= 22 then ret := '蠍座' else ret := '射手座';
      end;
    12:
      begin
        if dd <= 21 then ret := '射手座' else ret := '山羊座';
      end;
  end;

  Result := hi_newStr(ret);
end;

function cmd_tanjouseki(h: DWORD): PHiValue; stdcall;
var
  s: string;
  d: TDateTime;
  yyyy,mm,dd, hh, nn, ss, ms: WORD;
  b: array [0..11] of string;

begin
  s := getArgStr(h, 0, True);
  d := VarToDateTime(s);
  DecodeDateTime(d, yyyy, mm, dd, hh, nn, ss, ms);
  
  b[0] := 'ガーネット' ;
  b[1] := 'アメシスト';
  b[2] := 'アクアマリン';
  b[3] := 'ダイヤモンド' ;
  b[4] := 'エメラルド' ;
  b[5] := '真珠' ;
  b[6] := 'ルビー' ;
  b[7] := 'サードニックス' ;
  b[8] := 'サファイア' ;
  b[9] := 'オパール' ;
  b[10] := 'トパーズ' ;
  b[11] := 'トルコ石' ;

  Result := hi_newStr(b[mm-1]);
end;

procedure RegistFunction;
begin
  //:::::::4600-4650
  //todo: 命令の定義
  //<命令>

  //+日付(nakodate.dll)
  //-日付
  AddFunc('旧暦変換','{=?}Sを|Sで|Sの',4600,cmd_qreki,'日付Sを旧暦に変換して返す。旧暦2033年に問題あり。推奨→https://github.com/snowdrops89/Qreki_nako/','きゅうれきへんかん');
  AddFunc('六曜取得','{=?}Sを|Sで|Sの',4601,cmd_rokuyou,'日付Sの六曜返す。','ろくようしゅとく');
  AddFunc('二十四節気取得','{=?}Sを|Sで|Sの',4602,cmd_24sekki,'日付Sの二十四節気を返す。','にじゅうよんせっきしゅとく');
  AddFunc('日ノ干支取得','{=?}Sを|Sで|Sの',4603,cmd_hinoeto,'日付Sの日の干支を返す。','ひのえとしゅとく');
  AddFunc('年ノ干支取得','{=?}Sを|Sで|Sの',4604,cmd_nennoeto,'日付Sの年の干支を返す。','ねんのえとしゅとく');
  AddFunc('修正ユリウス日取得','{=?}Sを|Sで|Sの',4605,cmd_mjd,'日付Sから修正ユリウス日を返す。','しゅうせいゆりうすびしゅとく');
  AddFunc('十二星座取得','{=?}Sを|Sで|Sの',4606,cmd_seiza,'日付Sから十二星座を返す。','じゅうにせいざしゅとく');
  AddFunc('誕生石取得','{=?}Sを|Sで|Sの',4607,cmd_tanjouseki,'日付Sから誕生石を返す。','たんじょうせきしゅとく');

  //</命令>
end;

end.
