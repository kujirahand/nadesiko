unit qreki;

//-----------------------------------------------------------------------
// ����v�Z���C�u����
// ��ҁF�N�W����s���i2005/04/27�jhttp://www.kujirahand.com
//-----------------------------------------------------------------------
// �I���W�i���̃X�N���v�g�͍��쎁��AWK�ł��B���L������ł��܂��B
// http://www.vector.co.jp/soft/dos/personal/se016093.html
//-----------------------------------------------------------------------
// �I���W�i�����̉��Ǔ_�F
// 2017�N�̌v�Z�덷��DB�Q�Ƃɂ��C��
// �A���A����2033�N�̌v�Z�덷�́A���̂܂�
// ���ؔN:2017,2005

// ����ϊ��̖�� @955
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
// �Z�j�Z�o�֐�
function get_rokuyou(_year: Integer; _mon: Integer; _day: Integer): Integer;
function get_rokuyouStr(y,m,d:Integer):string;
// 24�ߋC�����߂�
function get_24sekki(_year,_mon,_day: Integer): string;
// �V��ɑΉ�����A��������߂�B
function calc_kyureki(_year,_mon,_day: Integer): TRecQreki;
// ���x
function Calc_hino_eto(y,m,d: Integer): string;
function Calc_nenno_eto(y: Integer): string;

//-------------------------------------------------------
// �������p:::
// �N�����A�����b�i���E���j���烆���E�X���iJD�j���v�Z����
function YMDT2JD(_year,_month,_day,_hour,_min,_sec: Integer): Extended;
// �����E�X���iJD�j����N�����A�����b�i���E���j���v�Z����
function JD2YMDT(_JD: Extended): TRecGreki;
// ���C�̎��������߂�
function calc_chu(_tm: Extended): TRecChu;
// ���O�̓񕪓񎊂̎��������߂�
function before_nibun(_tm:Extended): TRecChu;
// ��̌v�Z
function calc_saku(_tm: Extended):Extended;
// ���z�̉��o ��sun ���v�Z����
function LONGITUDE_SUN(_t:Extended):Extended;
// ���̉��o ��moon ���v�Z����
function LONGITUDE_MOON(_t:Extended): Extended;
//  �p�x�̐��K�����s���B���Ȃ킿�����͈̔͂� �O���Ɓ��R�U�O �ɂ���B
function NORMALIZATION_ANGLE(_angle: Extended):Extended;

implementation

//-----------------------------------------------------------------------
// �~�����̒�`�Ɓi�p�x�́j�x���烉�W�A���ɕϊ�����W���̒�`
//-----------------------------------------------------------------------
const _PI = 3.141592653589793238462;
const _k  = _PI/180.0;
const sekki24: array [0..23] of string = (
  '�t��','����','���J','����','����','䊎�','�Ď�','����','�友','���H','����','���I',
  '�H��','���I','���~','���~','����','���','�~��','����','�劦','���t','�J��','�[�'
  );
const rokuyou_s: array [0..5] of string = (
  '���', '�Ԍ�', '�揟', '�F��', '�敉', '����'
  );

const eto10: array [0..9] of string = (
  '�b', '��', '��', '��', '��', '��', '�M', '�h', '�p', '�'
  );
const eto12: array [0..11] of string = (
    '�q', '�N', '��', '�K', '�C', '��', '��', '��', '�\', '��', '��', '��'
  );

//�\���\��x�@�b(���̂�) ��(���̂�) ��(�Ђ̂�) ��(�Ђ̂�) ��(���̂�) ��(���̂�) �M(���̂�) �h(���̂�) �p(�݂��̂�) �(�݂��̂Ɓj
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
// �Z�j�Z�o�֐�
//
// �����F�V��N����
// �ߒl�F0:��� 1:�Ԍ� 2:�揟 3:�F�� 4:�敉 5:����
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
// �V��ɑΉ�����A��������߂�B
//
// �Ăяo�����ɃZ�b�g����ϐ�
// ���@���@year : �v�Z������t
//         mon
//         day
//
// �߂�l�@kyureki : �����̊i�[��i�z��ɓ������������j
//         �@�@  kyureki[0] : ����N
//         �@�@  kyureki[1] : �����^�[�� flag .... ����:0 �[��:1
//         �@�@  kyureki[2] : ���
//         �@�@  kyureki[3] : �����
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
  // �Q�O�P�V�N�Q���Q�U���`���R���Q�V���܂ł̌덷��␳
  // �f�[�^�x�[�X���g�p(http://koyomi.vis.ne.jp/)
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

  // �z���������
  for i := 0 to 11 do
    for j := 0 to 2 do
    begin
      _m[i,   j] := 0;
      _chu[i, j] := 0;
    end;

	_tm0 := YMDT2JD(_year, _mon, _day, 0, 0, 0);

  // �v�Z�Ώۂ̒��O�ɂ�����񕪓񎊂̎��������߂�
  // chu[0,0]:�񕪓񎊂̎���  chu[0,1]:���̎��̑��z���o
  c := before_nibun(_tm0);
	_chu[0,0] := c.d1;
  _chu[0,1] := c.d2;

  // ���C�̎������v�Z�i�S��v�Z����j
  // chu[i,0]:���C�̎���  chu[i,1]:���z���o
	for i := 1 to 3 do
  begin
    c := calc_chu(_chu[i-1, 0]+32.0);
  	_chu[i,0] := c.d1;
    _chu[i,1] := c.d2;
	end;

  //  �v�Z�Ώۂ̒��O�ɂ�����񕪓񎊂̒��O�̍�̎��������߂�
	_saku[0] := calc_saku(_chu[0, 0]);

  // ��̎��������߂�
  for i := 1 to 4 do
  begin
		_tm := _saku[i-1];
		_tm := _tm + 30.0;
		_saku[i] := calc_saku(_tm);

    // �O�Ɠ����������v�Z�����ꍇ�i���҂̍���26���ȓ��j�ɂ́A�����l��
    // +33���ɂ��čĎ��s������B
		if( abs(int(_saku[i-1])-int(_saku[i])) <= 26.0 )then begin
			_saku[i] := calc_saku(_saku[i-1]+35.0);
		end;
	end;

  // saku[1]���񕪓񎊂̎����ȑO�ɂȂ��Ă��܂����ꍇ�ɂ́A��������̂ڂ�߂�
  // ���ƍl���āA��̎������J�艺���ďC������B
  // ���̍ہA�v�Z����isaku[4]�j�ɂȂ��Ă��镔����₤���߁A��̎������v�Z
  // ����B�i�ߓ��_�ʉ߂̋ߕӂō񂪂���ƋN���鎖������悤��...�H�j
  if( int(_saku[1]) <= int(_chu[0,0]) )then begin
		for i:=0 to 4 do begin
			_saku[i]:=_saku[i+1];
		end;
		_saku[4] := calc_saku(_saku[3]+35.0);
	end

  // saku[0]���񕪓񎊂̎����Ȍ�ɂȂ��Ă��܂����ꍇ�ɂ́A��������̂ڂ葫
  // ��Ȃ��ƌ��āA��̎������J��グ�ďC������B
  // ���̍ہA�v�Z����isaku[0]�j�ɂȂ��Ă��镔����₤���߁A��̎������v�Z
  // ����B�i�t���_�̋ߕӂō񂪂���ƋN���鎖������悤��...�H�j
	else if( int(_saku[0]) > int(_chu[0,0]) )then begin
		for i := 4 downto 1 do begin
			_saku[i] := _saku[i-1];
		end;
		_saku[0] := calc_saku(_saku[0]-27.0);
	end;

  // �[�������e�������Z�b�g
  // �i�ߌ��łS�����̊Ԃɍ񂪂T�񂠂�ƁA�[��������\��������B�j
  // lap=0:����  lap=1:�[��
	if(int(_saku[4]) <= int(_chu[3, 0]) )then begin
		_lap := 1;
	end else begin
		_lap := 0;
	end;

  //-----------------------------------------------------------------------
  // ����s��̍쐬
  // m[i,0] ... �����i1:���� 2:�Q�� 3:�R�� ....�j
  // m[i,1] ... �[�t���O�i0:���� 1:�[���j
  // m[i,2] ... �����jd
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
  // ����s�񂩂狌������߂�B
  // (ref) https://nadesi.com/cgi/bug/?m=thread&threadid=955
  // ��T��������̏C���p�b�`��K�p 
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

  // ����N�̌v�Z
  // �i�����10�ȏ�ł��V����傫���ꍇ�ɂ́A
  //   �܂��N���z���Ă��Ȃ��͂�...�j
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
  // ����Ԉ�������t���o�͂����� (@955)
  // https://nadesi.com/cgi/bug/index.php?m=thread&threadid=955
  Result := calc_kyureki_tmp(_year, _mon, _day);
  // �v�Z�ԈႢ�𒲂ׂ�
  if Result.q_day > 30 then begin // ���炩�ȊԈႢ
    Inc(Result.q_mon);
    Result.q_day := Result.q_day - 29;
  end;
  // 2033�N���
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
// ���C�̎��������߂�
//
// �Ăяo�����ɃZ�b�g����ϐ�
// tm ........ �v�Z�ΏۂƂȂ鎞���i�����E�X���j
// chu ....... �߂�l���i�[����z��̃|�C���^�[
// i ......... �߂�l���i�[����z��̗v�f�ԍ�
// �߂�l .... ���C�̎����A���̎��̉��o��z��œn��
//
//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
function calc_chu(_tm: Extended): TRecChu;
var
  _tm1,_tm2,_t,_rm_sun0,_rm_sun,_delta_t1,_delta_t2,_delta_rm: Extended;
begin
//-----------------------------------------------------------------------
//���������𕪉�����
//-----------------------------------------------------------------------
	_tm1 := int( _tm );
	_tm2 := _tm - _tm1;

//-----------------------------------------------------------------------
// JST :=:=> DT �i�␳����:=0.0sec �Ɖ��肵�Čv�Z�j
//-----------------------------------------------------------------------
	_tm2 := _tm2 - 9.0/24.0;

//-----------------------------------------------------------------------
// ���C�̉��o ��sun0 �����߂�
//-----------------------------------------------------------------------
	_t:=(_tm2+0.5) / 36525.0;
	_t:=_t + (_tm1-2451545.0) / 36525.0;
	_rm_sun := LONGITUDE_SUN( _t );

	_rm_sun0 := 30.0*int(_rm_sun/30.0);

//-----------------------------------------------------------------------
// �J��Ԃ��v�Z�ɂ���Ē��C�̎������v�Z����
// �i�덷���}1.0 sec�ȓ��ɂȂ�����ł��؂�B�j
//-----------------------------------------------------------------------
  _delta_t1 := 0.0;
  _delta_t2 := 1.0;
  while (abs( _delta_t1 + _delta_t2 ) > ( 1.0 / 86400.0 )) do begin

//-----------------------------------------------------------------------
// ��sun ���v�Z
//-----------------------------------------------------------------------
		_t :=(_tm2+0.5) / 36525.0;
		_t :=_t + (_tm1-2451545.0) / 36525.0;
		_rm_sun := LONGITUDE_SUN( _t );

//-----------------------------------------------------------------------
// ���o�� ���Ɂ���sun �|��sun0
//-----------------------------------------------------------------------
		_delta_rm := _rm_sun - _rm_sun0 ;

//-----------------------------------------------------------------------
// ���ɂ̈������ݔ͈́i�}180���j����E�����ꍇ�ɂ́A�␳���s��
//-----------------------------------------------------------------------
		if( _delta_rm > 180.0 )then begin
			_delta_rm := _delta_rm - 360.0;
		end else if( _delta_rm < -180.0 )then begin
			_delta_rm := _delta_rm + 360.0;
		end;

//-----------------------------------------------------------------------
// ���������̕␳�l ��t
// delta_t := delta_rm * 365.2 / 360.0;
//-----------------------------------------------------------------------
		_delta_t1 := int(_delta_rm * 365.2 / 360.0);
		_delta_t2 := _delta_rm * 365.2 / 360.0;
		_delta_t2 := _delta_t2 - _delta_t1;

//-----------------------------------------------------------------------
// ���������̕␳
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
// �߂�l�̍쐬
// chu[i,0]:������������������̂ƁADT => JST �ϊ����s���A�߂�l�Ƃ���
// �i�␳����:=0.0sec �Ɖ��肵�Čv�Z�j
// chu[i,1]:���o
//-----------------------------------------------------------------------
	Result.d1 := _tm2+9.0/24.0;
	Result.d1 := Result.d1 + _tm1;
	Result.d2 := _rm_sun0;
end;

//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
// ���O�̓񕪓񎊂̎��������߂�
//
// �Ăяo�����ɃZ�b�g����ϐ�
// tm ........ �v�Z�ΏۂƂȂ鎞���i�����E�X���j
// nibun ..... �߂�l���i�[����z��̃|�C���^�[
// �߂�l .... �񕪓񎊂̎����A���̎��̉��o��z��œn��
// �i�߂�l�̓n������������ƋC�ɂ���Ȃ����܂�������B�j
//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
function before_nibun(_tm:Extended): TRecChu;
var
	_tm1,_tm2,_t,_rm_sun0,_rm_sun,_delta_t1,_delta_t2,_delta_rm: Extended;
begin

//-----------------------------------------------------------------------
//���������𕪉�����
//-----------------------------------------------------------------------
	_tm1 := int( _tm );
	_tm2 := _tm - _tm1;

//-----------------------------------------------------------------------
// JST :=:=> DT �i�␳����:=0.0sec �Ɖ��肵�Čv�Z�j
//-----------------------------------------------------------------------
	_tm2 := _tm2 - 9.0/24.0;

//-----------------------------------------------------------------------
// ���O�̓񕪓񎊂̉��o ��sun0 �����߂�
//-----------------------------------------------------------------------
	_t:=(_tm2+0.5) / 36525.0;
	_t:=_t + (_tm1-2451545.0) / 36525.0;
	_rm_sun := LONGITUDE_SUN( _t );
	_rm_sun0:=90*int(_rm_sun/90.0);

//-----------------------------------------------------------------------
// �J��Ԃ��v�Z�ɂ���Ē��O�̓񕪓񎊂̎������v�Z����
// �i�덷���}1.0 sec�ȓ��ɂȂ�����ł��؂�B�j
//-----------------------------------------------------------------------
	//for( _delta_t2 := 1.0 ; abs( _delta_t1+_delta_t2 ) > ( 1.0 / 86400.0 ) ; )begin
  _delta_t1 := 0.0;
  _delta_t2 := 1.0;
  while( abs( _delta_t1 + _delta_t2 ) > ( 1.0 / 86400.0 ) ) do begin

//-----------------------------------------------------------------------
// ��sun ���v�Z
//-----------------------------------------------------------------------
		_t:=(_tm2+0.5) / 36525.0;
		_t:=_t + (_tm1-2451545.0) / 36525.0;
		_rm_sun:=LONGITUDE_SUN( _t );

//-----------------------------------------------------------------------
// ���o�� ���Ɂ���sun �|��sun0
//-----------------------------------------------------------------------
		_delta_rm := _rm_sun - _rm_sun0 ;

//-----------------------------------------------------------------------
// ���ɂ̈������ݔ͈́i�}180���j����E�����ꍇ�ɂ́A�␳���s��
//-----------------------------------------------------------------------
		if( _delta_rm > 180.0 )then begin
			_delta_rm := _delta_rm - 360.0;
		end else if( _delta_rm < -180.0)then begin
			_delta_rm :=_delta_rm + 360.0;
		end;

//-----------------------------------------------------------------------
// ���������̕␳�l ��t
// delta_t := delta_rm * 365.2 / 360.0;
//-----------------------------------------------------------------------
		_delta_t1 := int(_delta_rm * 365.2 / 360.0);
		_delta_t2 := _delta_rm * 365.2 / 360.0;
		_delta_t2 := _delta_t2 - _delta_t1;

//-----------------------------------------------------------------------
// ���������̕␳
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
// �߂�l�̍쐬
// nibun[0,0]:������������������̂ƁADT :=:=> JST �ϊ����s���A�߂�l�Ƃ���
// �i�␳����:=0.0sec �Ɖ��肵�Čv�Z�j
// nibun[0,1]:���o
//-----------------------------------------------------------------------
  Result.d1 := _tm2+9.0/24.0;
	Result.d1 := Result.d1 + _tm1;
	Result.d2 := _rm_sun0;

end;

//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
// ��̌v�Z
// �^����ꂽ�����̒��߂̍�̎����iJST�j�����߂�
//
// �Ăяo�����ɃZ�b�g����ϐ�
// tm ........ �v�Z�ΏۂƂȂ鎞���i�����E�X���j
// �߂�l .... ��̎���
//
// �� �����A�߂�l�Ƃ������E�X���ŕ\���A�����b�͓��̏����ŕ\���B
//
//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
function calc_saku(_tm: Extended):Extended;
var
  _lc: Integer;
  _t,_tm1,_tm2,_rm_sun,_rm_moon,_delta_rm,_delta_t1,_delta_t2: Extended;
begin

//-----------------------------------------------------------------------
// ���[�v�J�E���^�̃Z�b�g
//-----------------------------------------------------------------------
	_lc := 1;

//-----------------------------------------------------------------------
//���������𕪉�����
//-----------------------------------------------------------------------
	_tm1 := int( _tm );
	_tm2 := _tm - _tm1;

//-----------------------------------------------------------------------
// JST :=:=> DT �i�␳����:=0.0sec �Ɖ��肵�Čv�Z�j
//-----------------------------------------------------------------------
	_tm2 :=_tm2 - 9.0/24.0;

//-----------------------------------------------------------------------
// �J��Ԃ��v�Z�ɂ���č�̎������v�Z����
// �i�덷���}1.0 sec�ȓ��ɂȂ�����ł��؂�B�j
//-----------------------------------------------------------------------
  _delta_t1 := 0.0;
  _delta_t2 := 1.0;
	while( abs( _delta_t1+_delta_t2 ) > ( 1.0 / 86400.0 ) ) do begin

//-----------------------------------------------------------------------
// ���z�̉��o��sun ,���̉��o��moon ���v�Z
// t := (tm - 2451548.0 + 0.5)/36525.0;
//-----------------------------------------------------------------------
		_t:=(_tm2+0.5) / 36525.0;
		_t:=_t + (_tm1-2451545.0) / 36525.0;
		_rm_sun  := LONGITUDE_SUN( _t );
		_rm_moon := LONGITUDE_MOON( _t );

//-----------------------------------------------------------------------
// ���Ƒ��z�̉��o������
// ���Ɂ���moon�|��sun
//-----------------------------------------------------------------------
		_delta_rm := _rm_moon - _rm_sun ;

//-----------------------------------------------------------------------
// ���[�v�̂P��ځilc:=1�j�� delta_rm < 0.0 �̏ꍇ�ɂ͈������ݔ͈͂�
// ����悤�ɕ␳����
//-----------------------------------------------------------------------
		if( (_lc = 1) and (_delta_rm < 0.0) ) then
    begin
			_delta_rm := NORMALIZATION_ANGLE( _delta_rm );
		end
//-----------------------------------------------------------------------
//   �t���̋߂��ō񂪂���ꍇ�i0 ����sun�� 20�j�ŁA���̉��o��moon��300 ��
//   �ꍇ�ɂ́A���Ɂ� 360.0 �| ���� �ƌv�Z���ĕ␳����
//-----------------------------------------------------------------------
		else if( (_rm_sun >= 0) and (_rm_sun <= 20) and (_rm_moon >= 300) ) then
    begin
			_delta_rm := NORMALIZATION_ANGLE( _delta_rm );
			_delta_rm := 360.0 - _delta_rm;
		end
//-----------------------------------------------------------------------
// ���ɂ̈������ݔ͈́i�}40���j����E�����ꍇ�ɂ́A�␳���s��
//-----------------------------------------------------------------------
		else if( abs( _delta_rm ) > 40.0 ) then begin
			_delta_rm := NORMALIZATION_ANGLE( _delta_rm );
		end;

//-----------------------------------------------------------------------
// ���������̕␳�l ��t
// delta_t := delta_rm * 29.530589 / 360.0;
//-----------------------------------------------------------------------
		_delta_t1 := int(_delta_rm * 29.530589 / 360.0);
		_delta_t2 := _delta_rm * 29.530589 / 360.0;
		_delta_t2 := _delta_t2 - _delta_t1;

//-----------------------------------------------------------------------
// ���������̕␳
// tm -:= delta_t;
//-----------------------------------------------------------------------
		_tm1 := _tm1 - _delta_t1;
		_tm2 := _tm2 - _delta_t2;
		if(_tm2 < 0.0)then begin
			_tm2 := _tm2 + 1.0; _tm1 := _tm1 - 1.0;
		end;

//-----------------------------------------------------------------------
// ���[�v�񐔂�15��ɂȂ�����A�����l tm �� tm-26 �Ƃ���B
//-----------------------------------------------------------------------
		if((_lc = 15) and (abs( _delta_t1+_delta_t2 ) > ( 1.0 / 86400.0 )) )then begin
			_tm1 := int( _tm-26 );
			_tm2 := 0;
		end

//-----------------------------------------------------------------------
// �����l��␳�����ɂ��ւ�炸�A�U���𑱂���ꍇ�ɂ͏����l�𓚂��Ƃ���
// �Ԃ��ċ����I�Ƀ��[�v�𔲂��o���Ĉُ�I��������B
//-----------------------------------------------------------------------
		else if ( _lc > 30 ) and (abs( _delta_t1+_delta_t2 ) > ( 1.0 / 86400.0 )) then begin
			_tm1:=_tm;_tm2:=0;
			Break;
		end;
    Inc(_lc);
	end;

//-----------------------------------------------------------------------
// ������������������̂ƁADT :=:=> JST �ϊ����s���A�߂�l�Ƃ���
// �i�␳����:=0.0sec �Ɖ��肵�Čv�Z�j
//-----------------------------------------------------------------------

	Result := _tm2+_tm1+9.0/24.0;
end;

//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
//  �p�x�̐��K�����s���B���Ȃ킿�����͈̔͂� �O���Ɓ��R�U�O �ɂ���B
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
// ���z�̉��o ��sun ���v�Z����
//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
function LONGITUDE_SUN(_t:Extended):Extended;
var
	_th,_ang: Extended;
begin

//-----------------------------------------------------------------------
// �ۓ����̌v�Z
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
// ��ፀ�̌v�Z
//-----------------------------------------------------------------------
	_ang := NORMALIZATION_ANGLE( 36000.7695 * _t );
	_ang := NORMALIZATION_ANGLE( _ang + 280.4659 );
	_th  := NORMALIZATION_ANGLE( _th + _ang );

	Result := _th;
end;

//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
// ���̉��o ��moon ���v�Z����
//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
function LONGITUDE_MOON(_t:Extended): Extended;
var _th,_ang: Extended;
begin

//-----------------------------------------------------------------------
// �ۓ����̌v�Z
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
// ��ፀ�̌v�Z
//-----------------------------------------------------------------------
  _ang := NORMALIZATION_ANGLE(  481267.8809 * _t );
  _ang := NORMALIZATION_ANGLE(  _ang + 218.3162 );
  _th  := NORMALIZATION_ANGLE(  _th  +  _ang );

  Result := (_th);
end;

//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
// �N�����A�����b�i���E���j���烆���E�X���iJD�j���v�Z����
//
// �� ���̊֐��ł́A�O���S���I��@�ɂ��N�������狁�߂���̂ł���B
//    �i�����E�X��@�ɂ��N�������狁�߂�ꍇ�ɂ͎g�p�ł��Ȃ��B�j
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
// �����E�X���iJD�j����N�����A�����b�i���E���j���v�Z����
//
// �߂�l�̔z��TIME[]�̓���
// TIME[0] ... �N  TIME[1] ... ��  TIME[2] ... ��
// TIME[3] ... ��  TIME[4] ... ��  TIME[5] ... �b
//
// �� ���̊֐��ŋ��߂��N�����́A�O���S���I��@�ɂ���ĕ\����Ă���B
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

// 2��30���̕␳
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
// �������Q�S�ߋC���ǂ������ׂ�
//
// �����@ .... �v�Z�ΏۂƂȂ�N�����@_year _mon _day
//
// �߂�l .... �Q�S�ߋC�̖���
//
//:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
function get_24sekki(_year,_mon,_day: Integer): string;
var
	_tm, _tm1,_tm2,_t,_rm_sun_today,_rm_sun_today0,
  _rm_sun_tommorow,_rm_sun_tommorow0: Extended;
begin

//-----------------------------------------------------------------------
// �Q�S�ߋC�̒�`
//-----------------------------------------------------------------------

	_tm := YMDT2JD(_year,_mon,_day,0,0,0);

//-----------------------------------------------------------------------
//���������𕪉�����
//-----------------------------------------------------------------------
	_tm1 := int( _tm );
	_tm2 := _tm - _tm1;
	_tm2 := _tm2 - 9.0/24.0;
	_t:=(_tm2+0.5) / 36525.0;
	_t:=_t + (_tm1-2451545.0) / 36525.0;

	//�����̑��z�̉��o
	_rm_sun_today := LONGITUDE_SUN( _t );

	_tm := _tm + 1;
	_tm1 := int(_tm);
	_tm2 := _tm - _tm1;
	_tm2 := _tm2 - 9.0/24.0;
	_t:=(_tm2+0.5) / 36525.0;
	_t:=_t + (_tm1-2451545.0) / 36525.0;

	//�����̑��z�̉��o
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
