unit qreki;

//-----------------------------------------------------------------------
// 旧暦計算ライブラリ
// 作者：クジラ飛行机（2005/04/27）http://www.kujirahand.com
//-----------------------------------------------------------------------
// オリジナルのスクリプトは高野氏のAWKです。下記より入手できます。
// http://www.vector.co.jp/soft/dos/personal/se016093.html
//-----------------------------------------------------------------------
// オリジナルよりの改良点：
// 2017年の計算誤差をDB参照により修正
// 但し、旧暦2033年の計算誤差は、そのまま
// 検証年:2017,2005

// 旧暦変換の問題 @955
// https://nadesi.com/cgi/bug/index.php?m=thread&threadid=955

interface

uses SysUtils, Classes, Windows;

type
  TRecQreki = record
    q_yaer, uruu, q_mon, q_day: Integer;
  end;
  TRecGreki = record
    year, mon, day, hour, min, sec: Integer;
  end;
  TRecChu = record
    d1, d2: Extended;
  end;

//-------------------------------------------------------
// 六曜算出関数
function get_rokuyou(_year: Integer; _mon: Integer; _day: Integer): Integer;
function get_rokuyouStr(y,m,d:Integer):string;
// 24節気を求める
function get_24sekki(_year,_mon,_day: Integer): string;
// 新暦に対応する、旧暦を求める。
function calc_kyureki(_year,_mon,_day: Integer): TRecQreki;
// 干支
function Calc_hino_eto(y,m,d: Integer): string;
function Calc_nenno_eto(y: Integer): string;

//-------------------------------------------------------
// 下請け用:::
// 年月日、時分秒（世界時）からユリウス日（JD）を計算する
function YMDT2JD(_year,_month,_day,_hour,_min,_sec: Integer): Extended;
// ユリウス日（JD）から年月日、時分秒（世界時）を計算する
function JD2YMDT(_JD: Extended): TRecGreki;
// 中気の時刻を求める
function calc_chu(_tm: Extended): TRecChu;
// 直前の二分二至の時刻を求める
function before_nibun(_tm:Extended): TRecChu;
// 朔の計算
function calc_saku(_tm: Extended):Extended;
// 太陽の黄経 λsun を計算する
function LONGITUDE_SUN(_t:Extended):Extended;
// 月の黄経 λmoon を計算する
function LONGITUDE_MOON(_t:Extended): Extended;
//  角度の正規化を行う。すなわち引数の範囲を ０≦θ＜３６０ にする。
function NORMALIZATION_ANGLE(_angle: Extended):Extended;

implementation

//-----------------------------------------------------------------------
// 円周率の定義と（角度の）度からラジアンに変換する係数の定義
//-----------------------------------------------------------------------
const _PI = 3.141592653589793238462;
const _k  = _PI/180.0;
const sekki24: array [0..23] of string = (
  '春分','清明','穀雨','立夏','小満','芒種','夏至','小暑','大暑','立秋','処暑','白露',
  '秋分','寒露','霜降','立冬','小雪','大雪','冬至','小寒','大寒','立春','雨水','啓蟄'
  );
const rokuyou_s: array [0..5] of string = (
  '大安', '赤口', '先勝', '友引', '先負', '仏滅'
  );

const eto10: array [0..9] of string = (
  '甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'
  );
const eto12: array [0..11] of string = (
    '子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'
  );

//十干十二支　甲(きのえ) 乙(きのと) 丙(ひのえ) 丁(ひのと) 戊(つちのえ) 己(つちのと) 庚(かのえ) 辛(かのと) 壬(みずのえ) 癸(みずのと）
function Calc_hino_eto(y,m,d: Integer): string;
var
  jd, e,t: Integer;
begin
  jd := Trunc(YMDT2JD(y,m,d,0,0,0));
  e := Trunc((jd div 2) Mod 5) * 2 + (jd Mod 2);
  t := Trunc((jd - 10) Mod 12);
  Result := eto10[e] + eto12[t];
end;

function Calc_nenno_eto(y: Integer): string;
var
  e,t: Integer;
begin
  y := y - 4;
  e := (y mod 10);
  t := (y mod 12);
  Result := eto10[e] + eto12[t];
end;


//=====================================
// 六曜算出関数
//
// 引数：新暦年月日
// 戻値：0:大安 1:赤口 2:先勝 3:友引 4:先負 5:仏滅
//
//=====================================
function get_rokuyou(_year: Integer; _mon: Integer; _day: Integer): Integer;
var
  rec: TRecQreki;
begin
	rec := calc_kyureki(_year,_mon,_day);
	Result := (rec.q_mon + rec.q_day) mod 6;
end;
function get_rokuyouStr(y,m,d:Integer):string;
begin
  Result := rokuyou_s[get_rokuyou(y,m,d)];
end;

//=====================================
// 新暦に対応する、旧暦を求める。
//
// 呼び出し時にセットする変数
// 引　数　year : 計算する日付
//         mon
//         day
//
// 戻り値　kyureki : 答えの格納先（配列に答えをかえす）
//         　　  kyureki[0] : 旧暦年
//         　　  kyureki[1] : 平月／閏月 flag .... 平月:0 閏月:1
//         　　  kyureki[2] : 旧暦月
//         　　  kyureki[3] : 旧暦日
//
//=====================================
function calc_kyureki_tmp(_year,_mon,_day: Integer): TRecQreki;
var
  _lap, _tm, _tm0: Extended;
  c: TRecChu;
  _a: TRecGreki;
  i, j, _state: Integer;
  _saku   : array [0..12] of Extended;
  _m, _chu: array [0..11, 0..2] of Extended;
begin
  // ２０１７年２月２６日～同３月２７日までの誤差を補正
  // データベースを使用(http://koyomi.vis.ne.jp/)
  if _year = 2017 then
  begin
    Result.q_yaer := 2017;
    if (_mon = 2)and(26 <= _day)and(_day <= 28) then begin
      Result.q_mon := 2;
      Result.q_day := 1 + (_day - 26);
      Exit;
    end else
    if (_mon = 3)and(1 <= _day)and(_day <= 27) then begin
      Result.q_mon := 2;
      Result.q_day := 4 + (_day - 1);
      Exit;
    end;
  end;

  // 配列を初期化
  for i := 0 to 11 do
    for j := 0 to 2 do
    begin
      _m[i,   j] := 0;
      _chu[i, j] := 0;
    end;

	_tm0 := YMDT2JD(_year, _mon, _day, 0, 0, 0);

  // 計算対象の直前にあたる二分二至の時刻を求める
  // chu[0,0]:二分二至の時刻  chu[0,1]:その時の太陽黄経
  c := before_nibun(_tm0);
	_chu[0,0] := c.d1;
  _chu[0,1] := c.d2;

  // 中気の時刻を計算（４回計算する）
  // chu[i,0]:中気の時刻  chu[i,1]:太陽黄経
	for i := 1 to 3 do
  begin
    c := calc_chu(_chu[i-1, 0]+32.0);
  	_chu[i,0] := c.d1;
    _chu[i,1] := c.d2;
	end;

  //  計算対象の直前にあたる二分二至の直前の朔の時刻を求める
	_saku[0] := calc_saku(_chu[0, 0]);

  // 朔の時刻を求める
  for i := 1 to 4 do
  begin
		_tm := _saku[i-1];
		_tm := _tm + 30.0;
		_saku[i] := calc_saku(_tm);

    // 前と同じ時刻を計算した場合（両者の差が26日以内）には、初期値を
    // +33日にして再実行させる。
		if( abs(int(_saku[i-1])-int(_saku[i])) <= 26.0 )then begin
			_saku[i] := calc_saku(_saku[i-1]+35.0);
		end;
	end;

  // saku[1]が二分二至の時刻以前になってしまった場合には、朔をさかのぼり過ぎ
  // たと考えて、朔の時刻を繰り下げて修正する。
  // その際、計算もれ（saku[4]）になっている部分を補うため、朔の時刻を計算
  // する。（近日点通過の近辺で朔があると起こる事があるようだ...？）
  if( int(_saku[1]) <= int(_chu[0,0]) )then begin
		for i:=0 to 4 do begin
			_saku[i]:=_saku[i+1];
		end;
		_saku[4] := calc_saku(_saku[3]+35.0);
	end

  // saku[0]が二分二至の時刻以後になってしまった場合には、朔をさかのぼり足
  // りないと見て、朔の時刻を繰り上げて修正する。
  // その際、計算もれ（saku[0]）になっている部分を補うため、朔の時刻を計算
  // する。（春分点の近辺で朔があると起こる事があるようだ...？）
	else if( int(_saku[0]) > int(_chu[0,0]) )then begin
		for i := 4 downto 1 do begin
			_saku[i] := _saku[i-1];
		end;
		_saku[0] := calc_saku(_saku[0]-27.0);
	end;

  // 閏月検索Ｆｌａｇセット
  // （節月で４ヶ月の間に朔が５回あると、閏月がある可能性がある。）
  // lap=0:平月  lap=1:閏月
	if(int(_saku[4]) <= int(_chu[3, 0]) )then begin
		_lap := 1;
	end else begin
		_lap := 0;
	end;

  //-----------------------------------------------------------------------
  // 朔日行列の作成
  // m[i,0] ... 月名（1:正月 2:２月 3:３月 ....）
  // m[i,1] ... 閏フラグ（0:平月 1:閏月）
  // m[i,2] ... 朔日のjd
	_m[0,0] := Trunc(_chu[0, 1]/30.0) + 2;
	if( _m[0, 1] > 12 )then
  begin
		_m[0,0] := _m[0,0] - 12;
	end;
	_m[0,2] := Trunc(_saku[0]);
	_m[0,1] := 0;

	for i := 1 to 4 do
  begin
		if ((_lap = 1)and(i <> 1)) then
    begin
			if ( Trunc(_chu[i-1, 0]) <= Trunc(_saku[i-1]) ) or
         ( Trunc(_chu[i-1, 0]) >= Trunc(_saku[i  ]) ) then
      begin
				_m[i-1, 0] := _m[i-2, 0];
				_m[i-1, 1] := 1;
				_m[i-1, 2] := Trunc(_saku[i-1]);
				_lap := 0;
			end;
		end;
		_m[i, 0] := _m[i-1, 0] + 1;
		if( _m[i, 0] > 12 )then
    begin
			_m[i, 0] := _m[i, 0] - 12;
		end;
		_m[i, 2] := Trunc(_saku[i]);
		_m[i, 1] := 0;
	end;

  //-----------------------------------------------------------------------
  // 朔日行列から旧暦を求める。
  // (ref) https://nadesi.com/cgi/bug/?m=thread&threadid=955
  // 雪乃☆雫さんの修正パッチを適用 
  //-----------------------------------------------------------------------
  j := 4;
  for i := 0 to 4 do
  begin
	if(Trunc(_tm0) < Trunc(_m[i, 2]))then
    begin
        j := i - 1;
		Break;
	end else
    if(Trunc(_tm0) = Trunc(_m[i, 2])) then
    begin
        j := i;
		Break;
    end;
  end;
  Result.uruu  := Trunc(_m[j, 1]);
  Result.q_mon := Trunc(_m[j, 0]);
  Result.q_day := Trunc(_tm0) - Trunc(_m[j, 2]) + 1;
  //writeln('debug>', Trunc(_tm0),'-',Trunc(_m[j, 2]));

  // 旧暦年の計算
  // （旧暦月が10以上でかつ新暦月より大きい場合には、
  //   まだ年を越していないはず...）
	_a := JD2YMDT(_tm0);
	Result.q_yaer := _a.year;
	if(Result.q_mon > 9)and(Result.q_mon > _a.mon)then
  begin
    Result.q_yaer := Result.q_yaer - 1;
	end;
end;
function calc_kyureki(_year,_mon,_day: Integer): TRecQreki;
var s1, s2, s3: Integer;
begin
  // 旧暦が間違った日付を出力する問題 (@955)
  // https://nadesi.com/cgi/bug/index.php?m=thread&threadid=955
  Result := calc_kyureki_tmp(_year, _mon, _day);
  // 計算間違いを調べる
  if Result.q_day > 30 then begin // 明らかな間違い
    Inc(Result.q_mon);
    Result.q_day := Result.q_day - 29;
  end;
  // 2033年問題
  if _year = 2033 then
  begin
    s1 := _mon * 100 + _day;
    s2 := 825;
    s3 := 1221;
    if (s2 <= s1) and (s1 <= s3) then begin
      Result.uruu := 0;
      Result.q_mon := Result.q_mon + 1;
    end;
  end;
end;

//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
// 中気の時刻を求める
//
// 呼び出し時にセットする変数
// tm ........ 計算対象となる時刻（ユリウス日）
// chu ....... 戻り値を格納する配列のポインター
// i ......... 戻り値を格納する配列の要素番号
// 戻り値 .... 中気の時刻、その時の黄経を配列で渡す
//
//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
function calc_chu(_tm: Extended): TRecChu;
var
  _tm1,_tm2,_t,_rm_sun0,_rm_sun,_delta_t1,_delta_t2,_delta_rm: Extended;
begin
//-----------------------------------------------------------------------
//時刻引数を分解する
//-----------------------------------------------------------------------
	_tm1 := int( _tm );
	_tm2 := _tm - _tm1;

//-----------------------------------------------------------------------
// JST :=:=> DT （補正時刻:=0.0sec と仮定して計算）
//-----------------------------------------------------------------------
	_tm2 := _tm2 - 9.0/24.0;

//-----------------------------------------------------------------------
// 中気の黄経 λsun0 を求める
//-----------------------------------------------------------------------
	_t:=(_tm2+0.5) / 36525.0;
	_t:=_t + (_tm1-2451545.0) / 36525.0;
	_rm_sun := LONGITUDE_SUN( _t );

	_rm_sun0 := 30.0*int(_rm_sun/30.0);

//-----------------------------------------------------------------------
// 繰り返し計算によって中気の時刻を計算する
// （誤差が±1.0 sec以内になったら打ち切る。）
//-----------------------------------------------------------------------
  _delta_t1 := 0.0;
  _delta_t2 := 1.0;
  while (abs( _delta_t1 + _delta_t2 ) > ( 1.0 / 86400.0 )) do begin

//-----------------------------------------------------------------------
// λsun を計算
//-----------------------------------------------------------------------
		_t :=(_tm2+0.5) / 36525.0;
		_t :=_t + (_tm1-2451545.0) / 36525.0;
		_rm_sun := LONGITUDE_SUN( _t );

//-----------------------------------------------------------------------
// 黄経差 Δλ＝λsun －λsun0
//-----------------------------------------------------------------------
		_delta_rm := _rm_sun - _rm_sun0 ;

//-----------------------------------------------------------------------
// Δλの引き込み範囲（±180°）を逸脱した場合には、補正を行う
//-----------------------------------------------------------------------
		if( _delta_rm > 180.0 )then begin
			_delta_rm := _delta_rm - 360.0;
		end else if( _delta_rm < -180.0 )then begin
			_delta_rm := _delta_rm + 360.0;
		end;

//-----------------------------------------------------------------------
// 時刻引数の補正値 Δt
// delta_t := delta_rm * 365.2 / 360.0;
//-----------------------------------------------------------------------
		_delta_t1 := int(_delta_rm * 365.2 / 360.0);
		_delta_t2 := _delta_rm * 365.2 / 360.0;
		_delta_t2 := _delta_t2 - _delta_t1;

//-----------------------------------------------------------------------
// 時刻引数の補正
// tm -:= delta_t;
//-----------------------------------------------------------------------
		_tm1 := _tm1 - _delta_t1;
		_tm2 := _tm2 - _delta_t2;
		if(_tm2 < 0)then begin
			_tm2 := _tm2 + 1.0;
      _tm1 := _tm1 - 1.0;
		end;
	end;

//-----------------------------------------------------------------------
// 戻り値の作成
// chu[i,0]:時刻引数を合成するのと、DT => JST 変換を行い、戻り値とする
// （補正時刻:=0.0sec と仮定して計算）
// chu[i,1]:黄経
//-----------------------------------------------------------------------
	Result.d1 := _tm2+9.0/24.0;
	Result.d1 := Result.d1 + _tm1;
	Result.d2 := _rm_sun0;
end;

//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
// 直前の二分二至の時刻を求める
//
// 呼び出し時にセットする変数
// tm ........ 計算対象となる時刻（ユリウス日）
// nibun ..... 戻り値を格納する配列のポインター
// 戻り値 .... 二分二至の時刻、その時の黄経を配列で渡す
// （戻り値の渡し方がちょっと気にくわないがまぁいいや。）
//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
function before_nibun(_tm:Extended): TRecChu;
var
	_tm1,_tm2,_t,_rm_sun0,_rm_sun,_delta_t1,_delta_t2,_delta_rm: Extended;
begin

//-----------------------------------------------------------------------
//時刻引数を分解する
//-----------------------------------------------------------------------
	_tm1 := int( _tm );
	_tm2 := _tm - _tm1;

//-----------------------------------------------------------------------
// JST :=:=> DT （補正時刻:=0.0sec と仮定して計算）
//-----------------------------------------------------------------------
	_tm2 := _tm2 - 9.0/24.0;

//-----------------------------------------------------------------------
// 直前の二分二至の黄経 λsun0 を求める
//-----------------------------------------------------------------------
	_t:=(_tm2+0.5) / 36525.0;
	_t:=_t + (_tm1-2451545.0) / 36525.0;
	_rm_sun := LONGITUDE_SUN( _t );
	_rm_sun0:=90*int(_rm_sun/90.0);

//-----------------------------------------------------------------------
// 繰り返し計算によって直前の二分二至の時刻を計算する
// （誤差が±1.0 sec以内になったら打ち切る。）
//-----------------------------------------------------------------------
	//for( _delta_t2 := 1.0 ; abs( _delta_t1+_delta_t2 ) > ( 1.0 / 86400.0 ) ; )begin
  _delta_t1 := 0.0;
  _delta_t2 := 1.0;
  while( abs( _delta_t1 + _delta_t2 ) > ( 1.0 / 86400.0 ) ) do begin

//-----------------------------------------------------------------------
// λsun を計算
//-----------------------------------------------------------------------
		_t:=(_tm2+0.5) / 36525.0;
		_t:=_t + (_tm1-2451545.0) / 36525.0;
		_rm_sun:=LONGITUDE_SUN( _t );

//-----------------------------------------------------------------------
// 黄経差 Δλ＝λsun －λsun0
//-----------------------------------------------------------------------
		_delta_rm := _rm_sun - _rm_sun0 ;

//-----------------------------------------------------------------------
// Δλの引き込み範囲（±180°）を逸脱した場合には、補正を行う
//-----------------------------------------------------------------------
		if( _delta_rm > 180.0 )then begin
			_delta_rm := _delta_rm - 360.0;
		end else if( _delta_rm < -180.0)then begin
			_delta_rm :=_delta_rm + 360.0;
		end;

//-----------------------------------------------------------------------
// 時刻引数の補正値 Δt
// delta_t := delta_rm * 365.2 / 360.0;
//-----------------------------------------------------------------------
		_delta_t1 := int(_delta_rm * 365.2 / 360.0);
		_delta_t2 := _delta_rm * 365.2 / 360.0;
		_delta_t2 := _delta_t2 - _delta_t1;

//-----------------------------------------------------------------------
// 時刻引数の補正
// tm -:= delta_t;
//-----------------------------------------------------------------------
		_tm1 := _tm1 - _delta_t1;
		_tm2 := _tm2 - _delta_t2;
		if(_tm2 < 0)then begin
			_tm2 := _tm2 + 1.0;
      _tm1 := _tm1 - 1.0;
		end;

	end;

//-----------------------------------------------------------------------
// 戻り値の作成
// nibun[0,0]:時刻引数を合成するのと、DT :=:=> JST 変換を行い、戻り値とする
// （補正時刻:=0.0sec と仮定して計算）
// nibun[0,1]:黄経
//-----------------------------------------------------------------------
  Result.d1 := _tm2+9.0/24.0;
	Result.d1 := Result.d1 + _tm1;
	Result.d2 := _rm_sun0;

end;

//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
// 朔の計算
// 与えられた時刻の直近の朔の時刻（JST）を求める
//
// 呼び出し時にセットする変数
// tm ........ 計算対象となる時刻（ユリウス日）
// 戻り値 .... 朔の時刻
//
// ※ 引数、戻り値ともユリウス日で表し、時分秒は日の小数で表す。
//
//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
function calc_saku(_tm: Extended):Extended;
var
  _lc: Integer;
  _t,_tm1,_tm2,_rm_sun,_rm_moon,_delta_rm,_delta_t1,_delta_t2: Extended;
begin

//-----------------------------------------------------------------------
// ループカウンタのセット
//-----------------------------------------------------------------------
	_lc := 1;

//-----------------------------------------------------------------------
//時刻引数を分解する
//-----------------------------------------------------------------------
	_tm1 := int( _tm );
	_tm2 := _tm - _tm1;

//-----------------------------------------------------------------------
// JST :=:=> DT （補正時刻:=0.0sec と仮定して計算）
//-----------------------------------------------------------------------
	_tm2 :=_tm2 - 9.0/24.0;

//-----------------------------------------------------------------------
// 繰り返し計算によって朔の時刻を計算する
// （誤差が±1.0 sec以内になったら打ち切る。）
//-----------------------------------------------------------------------
  _delta_t1 := 0.0;
  _delta_t2 := 1.0;
	while( abs( _delta_t1+_delta_t2 ) > ( 1.0 / 86400.0 ) ) do begin

//-----------------------------------------------------------------------
// 太陽の黄経λsun ,月の黄経λmoon を計算
// t := (tm - 2451548.0 + 0.5)/36525.0;
//-----------------------------------------------------------------------
		_t:=(_tm2+0.5) / 36525.0;
		_t:=_t + (_tm1-2451545.0) / 36525.0;
		_rm_sun  := LONGITUDE_SUN( _t );
		_rm_moon := LONGITUDE_MOON( _t );

//-----------------------------------------------------------------------
// 月と太陽の黄経差Δλ
// Δλ＝λmoon－λsun
//-----------------------------------------------------------------------
		_delta_rm := _rm_moon - _rm_sun ;

//-----------------------------------------------------------------------
// ループの１回目（lc:=1）で delta_rm < 0.0 の場合には引き込み範囲に
// 入るように補正する
//-----------------------------------------------------------------------
		if( (_lc = 1) and (_delta_rm < 0.0) ) then
    begin
			_delta_rm := NORMALIZATION_ANGLE( _delta_rm );
		end
//-----------------------------------------------------------------------
//   春分の近くで朔がある場合（0 ≦λsun≦ 20）で、月の黄経λmoon≧300 の
//   場合には、Δλ＝ 360.0 － Δλ と計算して補正する
//-----------------------------------------------------------------------
		else if( (_rm_sun >= 0) and (_rm_sun <= 20) and (_rm_moon >= 300) ) then
    begin
			_delta_rm := NORMALIZATION_ANGLE( _delta_rm );
			_delta_rm := 360.0 - _delta_rm;
		end
//-----------------------------------------------------------------------
// Δλの引き込み範囲（±40°）を逸脱した場合には、補正を行う
//-----------------------------------------------------------------------
		else if( abs( _delta_rm ) > 40.0 ) then begin
			_delta_rm := NORMALIZATION_ANGLE( _delta_rm );
		end;

//-----------------------------------------------------------------------
// 時刻引数の補正値 Δt
// delta_t := delta_rm * 29.530589 / 360.0;
//-----------------------------------------------------------------------
		_delta_t1 := int(_delta_rm * 29.530589 / 360.0);
		_delta_t2 := _delta_rm * 29.530589 / 360.0;
		_delta_t2 := _delta_t2 - _delta_t1;

//-----------------------------------------------------------------------
// 時刻引数の補正
// tm -:= delta_t;
//-----------------------------------------------------------------------
		_tm1 := _tm1 - _delta_t1;
		_tm2 := _tm2 - _delta_t2;
		if(_tm2 < 0.0)then begin
			_tm2 := _tm2 + 1.0; _tm1 := _tm1 - 1.0;
		end;

//-----------------------------------------------------------------------
// ループ回数が15回になったら、初期値 tm を tm-26 とする。
//-----------------------------------------------------------------------
		if((_lc = 15) and (abs( _delta_t1+_delta_t2 ) > ( 1.0 / 86400.0 )) )then begin
			_tm1 := int( _tm-26 );
			_tm2 := 0;
		end

//-----------------------------------------------------------------------
// 初期値を補正したにも関わらず、振動を続ける場合には初期値を答えとして
// 返して強制的にループを抜け出して異常終了させる。
//-----------------------------------------------------------------------
		else if ( _lc > 30 ) and (abs( _delta_t1+_delta_t2 ) > ( 1.0 / 86400.0 )) then begin
			_tm1:=_tm;_tm2:=0;
			Break;
		end;
    Inc(_lc);
	end;

//-----------------------------------------------------------------------
// 時刻引数を合成するのと、DT :=:=> JST 変換を行い、戻り値とする
// （補正時刻:=0.0sec と仮定して計算）
//-----------------------------------------------------------------------

	Result := _tm2+_tm1+9.0/24.0;
end;

//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
//  角度の正規化を行う。すなわち引数の範囲を ０≦θ＜３６０ にする。
//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
function NORMALIZATION_ANGLE(_angle: Extended):Extended;
var
  _angle1,_angle2: Extended;
begin

	if( _angle < 0.0 )then begin
		_angle1 := -_angle;
		_angle2 := int( _angle1 / 360.0 );
		_angle1 := _angle1 - 360.0 * _angle2;
		_angle1 := 360.0 - _angle1;
	end else begin
		_angle1 := int( _angle / 360.0 );
		_angle1 := _angle - 360.0 * _angle1;
	end;

	Result := _angle1;
end;

//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
// 太陽の黄経 λsun を計算する
//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
function LONGITUDE_SUN(_t:Extended):Extended;
var
	_th,_ang: Extended;
begin

//-----------------------------------------------------------------------
// 摂動項の計算
//-----------------------------------------------------------------------
	_ang := NORMALIZATION_ANGLE(  31557.0 * _t + 161.0 );
	_th :=      0.0004 * cos( _k*_ang );
	_ang := NORMALIZATION_ANGLE(  29930.0 * _t +  48.0 );
	_th := _th + 0.0004 * cos( _k*_ang );
	_ang := NORMALIZATION_ANGLE(   2281.0 * _t + 221.0 );
	_th := _th + 0.0005 * cos( _k*_ang );
	_ang := NORMALIZATION_ANGLE(    155.0 * _t + 118.0 );
	_th := _th + 0.0005 * cos( _k*_ang );
	_ang := NORMALIZATION_ANGLE(  33718.0 * _t + 316.0 );
	_th := _th + 0.0006 * cos( _k*_ang );
	_ang := NORMALIZATION_ANGLE(   9038.0 * _t +  64.0 );
	_th := _th + 0.0007 * cos( _k*_ang );
	_ang := NORMALIZATION_ANGLE(   3035.0 * _t + 110.0 );
	_th := _th + 0.0007 * cos( _k*_ang );
	_ang := NORMALIZATION_ANGLE(  65929.0 * _t +  45.0 );
	_th := _th + 0.0007 * cos( _k*_ang );
	_ang := NORMALIZATION_ANGLE(  22519.0 * _t + 352.0 );
	_th := _th + 0.0013 * cos( _k*_ang );
	_ang := NORMALIZATION_ANGLE(  45038.0 * _t + 254.0 );
	_th := _th + 0.0015 * cos( _k*_ang );
	_ang := NORMALIZATION_ANGLE( 445267.0 * _t + 208.0 );
	_th := _th + 0.0018 * cos( _k*_ang );
	_ang := NORMALIZATION_ANGLE(     19.0 * _t + 159.0 );
	_th := _th + 0.0018 * cos( _k*_ang );
	_ang := NORMALIZATION_ANGLE(  32964.0 * _t + 158.0 );
	_th := _th + 0.0020 * cos( _k*_ang );
	_ang := NORMALIZATION_ANGLE(  71998.1 * _t + 265.1 );
	_th := _th + 0.0200 * cos( _k*_ang );
	_ang := NORMALIZATION_ANGLE(  35999.05 * _t + 267.52 );
	_th := _th - 0.0048 * _t * cos( _k*_ang ) ;
	_th := _th + 1.9147     * cos( _k*_ang ) ;

//-----------------------------------------------------------------------
// 比例項の計算
//-----------------------------------------------------------------------
	_ang := NORMALIZATION_ANGLE( 36000.7695 * _t );
	_ang := NORMALIZATION_ANGLE( _ang + 280.4659 );
	_th  := NORMALIZATION_ANGLE( _th + _ang );

	Result := _th;
end;

//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
// 月の黄経 λmoon を計算する
//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
function LONGITUDE_MOON(_t:Extended): Extended;
var _th,_ang: Extended;
begin

//-----------------------------------------------------------------------
// 摂動項の計算
//-----------------------------------------------------------------------
  _ang := NORMALIZATION_ANGLE( 2322131.0  * _t + 191.0  );
   _th :=     0.0003 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(    4067.0  * _t +  70.0  );
   _th := _th +0.0003 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  549197.0  * _t + 220.0  );
   _th := _th +0.0003 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE( 1808933.0  * _t +  58.0  );
   _th := _th +0.0003 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  349472.0  * _t + 337.0  );
   _th := _th +0.0003 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  381404.0  * _t + 354.0  );
   _th := _th +0.0003 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  958465.0  * _t + 340.0  );
   _th := _th +0.0003 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(   12006.0  * _t + 187.0  );
   _th := _th +0.0004 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(   39871.0  * _t + 223.0  );
   _th := _th +0.0004 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  509131.0  * _t + 242.0  );
   _th := _th +0.0005 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE( 1745069.0  * _t +  24.0  );
   _th := _th +0.0005 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE( 1908795.0  * _t +  90.0  );
   _th := _th +0.0005 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE( 2258267.0  * _t + 156.0  );
   _th := _th +0.0006 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  111869.0  * _t +  38.0  );
   _th := _th +0.0006 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(   27864.0  * _t + 127.0  );
   _th := _th +0.0007 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  485333.0  * _t + 186.0  );
   _th := _th +0.0007 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  405201.0  * _t +  50.0  );
   _th := _th +0.0007 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  790672.0  * _t + 114.0  );
   _th := _th +0.0007 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE( 1403732.0  * _t +  98.0  );
   _th := _th +0.0008 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  858602.0  * _t + 129.0  );
   _th := _th +0.0009 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE( 1920802.0  * _t + 186.0  );
   _th := _th +0.0011 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE( 1267871.0  * _t + 249.0  );
   _th := _th +0.0012 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE( 1856938.0  * _t + 152.0  );
   _th := _th +0.0016 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  401329.0  * _t + 274.0  );
   _th := _th +0.0018 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  341337.0  * _t +  16.0  );
   _th := _th +0.0021 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(   71998.0  * _t +  85.0  );
   _th := _th +0.0021 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  990397.0  * _t + 357.0  );
   _th := _th +0.0021 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  818536.0  * _t + 151.0  );
   _th := _th +0.0022 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  922466.0  * _t + 163.0  );
   _th := _th +0.0023 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(   99863.0  * _t + 122.0  );
   _th := _th +0.0024 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE( 1379739.0  * _t +  17.0  );
   _th := _th +0.0026 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  918399.0  * _t + 182.0  );
   _th := _th +0.0027 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(    1934.0  * _t + 145.0  );
   _th := _th +0.0028 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  541062.0  * _t + 259.0  );
   _th := _th +0.0037 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE( 1781068.0  * _t +  21.0  );
   _th := _th +0.0038 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(     133.0  * _t +  29.0  );
   _th := _th +0.0040 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE( 1844932.0  * _t +  56.0  );
   _th := _th +0.0040 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE( 1331734.0  * _t + 283.0  );
   _th := _th +0.0040 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  481266.0  * _t + 205.0  );
   _th := _th +0.0050 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(   31932.0  * _t + 107.0  );
   _th := _th +0.0052 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  926533.0  * _t + 323.0  );
   _th := _th +0.0068 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  449334.0  * _t + 188.0  );
   _th := _th +0.0079 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  826671.0  * _t + 111.0  );
   _th := _th +0.0085 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE( 1431597.0  * _t + 315.0  );
   _th := _th +0.0100 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE( 1303870.0  * _t + 246.0  );
   _th := _th +0.0107 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  489205.0  * _t + 142.0  );
   _th := _th +0.0110 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE( 1443603.0  * _t +  52.0  );
   _th := _th +0.0125 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(   75870.0  * _t +  41.0  );
   _th := _th +0.0154 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  513197.9  * _t + 222.5  );
   _th := _th +0.0304 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  445267.1  * _t +  27.9  );
   _th := _th +0.0347 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  441199.8  * _t +  47.4  );
   _th := _th +0.0409 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  854535.2  * _t + 148.2  );
   _th := _th +0.0458 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE( 1367733.1  * _t + 280.7  );
   _th := _th +0.0533 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  377336.3  * _t +  13.2  );
   _th := _th +0.0571 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(   63863.5  * _t + 124.2  );
   _th := _th +0.0588 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  966404.0  * _t + 276.5  );
   _th := _th + 0.1144 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(   35999.05 * _t +  87.53 );
   _th := _th + 0.1851 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  954397.74 * _t + 179.93 );
   _th := _th + 0.2136 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  890534.22 * _t + 145.7  );
   _th := _th + 0.6583 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE(  413335.35 * _t +  10.74 );
   _th := _th + 1.2740 * cos( _k*_ang );
  _ang := NORMALIZATION_ANGLE( 477198.868 * _t + 44.963 ); 
   _th := _th + 6.2888 * cos( _k*_ang );

//-----------------------------------------------------------------------
// 比例項の計算
//-----------------------------------------------------------------------
  _ang := NORMALIZATION_ANGLE(  481267.8809 * _t );
  _ang := NORMALIZATION_ANGLE(  _ang + 218.3162 );
  _th  := NORMALIZATION_ANGLE(  _th  +  _ang );

  Result := (_th);
end;

//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
// 年月日、時分秒（世界時）からユリウス日（JD）を計算する
//
// ※ この関数では、グレゴリオ暦法による年月日から求めるものである。
//    （ユリウス暦法による年月日から求める場合には使用できない。）
//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
function YMDT2JD(_year,_month,_day,_hour,_min,_sec: Integer): Extended;
var
  _jd, _t: Integer;
begin
	if( _month < 3.0 )then
  begin
		Dec(_year);
    Inc(_month, 12);
	end;

	_jd := Trunc( 365.25 * _year );
	Inc(_jd, Trunc( _year / 400.0 ));
	Dec(_jd, Trunc( _year / 100.0 ));
	Inc(_jd, Trunc( 30.59 * ( _month-2.0 ) ));
	Inc(_jd, 1721088);
	Inc(_jd, _day);

	_t  := Trunc(_sec / 3600.0);
	Inc(_t, Trunc(_min / 60.0));
	Inc(_t, Trunc(_hour));
	_t  := Trunc(_t / 24.0);

	_jd := _jd + _t;

	Result := _jd;
end;

//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
// ユリウス日（JD）から年月日、時分秒（世界時）を計算する
//
// 戻り値の配列TIME[]の内訳
// TIME[0] ... 年  TIME[1] ... 月  TIME[2] ... 日
// TIME[3] ... 時  TIME[4] ... 分  TIME[5] ... 秒
//
// ※ この関数で求めた年月日は、グレゴリオ暦法によって表されている。
//
//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
function JD2YMDT(_JD: Extended): TRecGreki;
var
  _x0,_x1,_x2,_x3,_x4,_x5,_x6,_tm:Extended;
begin
	_x0 := int( _JD+68570.0);
	_x1 := int( _x0/36524.25 );
	_x2 := _x0 - int( 36524.25*_x1 + 0.75 );
	_x3 := int( ( _x2+1 )/365.2425 );
	_x4 := _x2 - int( 365.25*_x3 )+31.0;
	_x5 := int( int(_x4) / 30.59 );
	_x6 := int( int(_x5) / 11.0 );

  Result.day  := Trunc(_x4 - int( 30.59*_x5 ));
  Result.mon  := Trunc(_x5 - 12*_x6 + 2);
  Result.year := Trunc(100*( _x1-49 ) + _x3 + _x6);

// 2月30日の補正
	if(Result.mon=2) and (Result.day > 28)then
  begin
		if(Result.year mod 100 = 0) and (Result.year mod 400 = 0) then
    begin
			Result.day:=29;
		end else if(Result.year mod 4 = 0)then begin
			Result.day:=29;
		end else begin
			Result.day:=28;
		end;
	end;

	_tm := 86400.0*( _JD - int( _JD ) );
	Result.hour := Trunc( _tm/3600.0 );
	Result.min  := Trunc( (_tm - 3600.0*Result.hour)/60.0 );
	Result.sec  := Trunc( _tm - 3600.0*Result.hour - 60*Result.min );
end;

//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
// 今日が２４節気かどうか調べる
//
// 引数　 .... 計算対象となる年月日　_year _mon _day
//
// 戻り値 .... ２４節気の名称
//
//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
function get_24sekki(_year,_mon,_day: Integer): string;
var
	_tm, _tm1,_tm2,_t,_rm_sun_today,_rm_sun_today0,
  _rm_sun_tommorow,_rm_sun_tommorow0: Extended;
begin

//-----------------------------------------------------------------------
// ２４節気の定義
//-----------------------------------------------------------------------

	_tm := YMDT2JD(_year,_mon,_day,0,0,0);

//-----------------------------------------------------------------------
//時刻引数を分解する
//-----------------------------------------------------------------------
	_tm1 := int( _tm );
	_tm2 := _tm - _tm1;
	_tm2 := _tm2 - 9.0/24.0;
	_t:=(_tm2+0.5) / 36525.0;
	_t:=_t + (_tm1-2451545.0) / 36525.0;

	//今日の太陽の黄経
	_rm_sun_today := LONGITUDE_SUN( _t );

	_tm := _tm + 1;
	_tm1 := int(_tm);
	_tm2 := _tm - _tm1;
	_tm2 := _tm2 - 9.0/24.0;
	_t:=(_tm2+0.5) / 36525.0;
	_t:=_t + (_tm1-2451545.0) / 36525.0;

	//明日の太陽の黄経
	_rm_sun_tommorow := LONGITUDE_SUN(_t);

	//
	_rm_sun_today0   := 15.0 * int(_rm_sun_today / 15.0);
	_rm_sun_tommorow0 := 15.0 * int(_rm_sun_tommorow / 15.0);

	if(_rm_sun_today0 <> _rm_sun_tommorow0)then begin
		Result := sekki24[Trunc(_rm_sun_tommorow0) div 15];
	end else begin
		Result := '';
	end;
end;

end.
