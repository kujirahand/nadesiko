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
      Result := hi_newStr(Format('%0.2d/�[%0.2d/%0.2d',[q.q_yaer, q.q_mon, q.q_day]));
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
�R�r���i12/22 - 1/19���j
���r���i1/20 - 2/18���j
�����i2/19 - 3/20���j
���r���i3/21 - 4/19���j
�������i4/20 - 5/20���j
�o�q��(5/21 - 6/21��)
�I���i6/22 - 7/22���j
���q���i7/23 - 8/22���j
�������i8/23 - 9/22���j
�V�����i9/23 - 10/23���j
嶍��i10/24 - 11/22���j
�ˎ���i11/23 - 12/21���j
�R�r���i12/22 - 1/19���j
}
  case mm of
    1:
      begin
        if dd <= 19 then ret := '�R�r��' else ret := '���r��';
      end;
    2:
      begin
        if dd <= 18 then ret := '���r��' else ret := '����';
      end;
    3:
      begin
        if dd <= 20 then ret := '����' else ret := '���r��';
      end;
    4:
      begin
        if dd <= 19 then ret := '���r��' else ret := '������';
      end;
    5:
      begin
        if dd <= 20 then ret := '������' else ret := '�o�q��';
      end;
    6:
      begin
        if dd <= 21 then ret := '�o�q��' else ret := '�I��';
      end;
    7:
      begin
        if dd <= 22 then ret := '�I��' else ret := '���q��';
      end;
    8:
      begin
        if dd <= 22 then ret := '���q��' else ret := '������';
      end;
    9:
      begin
        if dd <= 22 then ret := '������' else ret := '�V����';
      end;
    10:
      begin
        if dd <= 23 then ret := '�V����' else ret := '嶍�';
      end;
    11:
      begin
        if dd <= 22 then ret := '嶍�' else ret := '�ˎ��';
      end;
    12:
      begin
        if dd <= 21 then ret := '�ˎ��' else ret := '�R�r��';
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
  
  b[0] := '�K�[�l�b�g' ;
  b[1] := '�A���V�X�g';
  b[2] := '�A�N�A�}����';
  b[3] := '�_�C�������h' ;
  b[4] := '�G�������h' ;
  b[5] := '�^��' ;
  b[6] := '���r�[' ;
  b[7] := '�T�[�h�j�b�N�X' ;
  b[8] := '�T�t�@�C�A' ;
  b[9] := '�I�p�[��' ;
  b[10] := '�g�p�[�Y' ;
  b[11] := '�g���R��' ;

  Result := hi_newStr(b[mm-1]);
end;

procedure RegistFunction;
begin
  //:::::::4600-4650
  //todo: ���߂̒�`
  //<����>

  //+���t(nakodate.dll)
  //-���t
  AddFunc('����ϊ�','{=?}S��|S��|S��',4600,cmd_qreki,'���tS������ɕϊ����ĕԂ��B����2033�N�ɖ�肠��B������https://github.com/snowdrops89/Qreki_nako/','���イ�ꂫ�ւ񂩂�');
  AddFunc('�Z�j�擾','{=?}S��|S��|S��',4601,cmd_rokuyou,'���tS�̘Z�j�Ԃ��B','�낭�悤����Ƃ�');
  AddFunc('��\�l�ߋC�擾','{=?}S��|S��|S��',4602,cmd_24sekki,'���tS�̓�\�l�ߋC��Ԃ��B','�ɂ��イ��񂹂�������Ƃ�');
  AddFunc('���m���x�擾','{=?}S��|S��|S��',4603,cmd_hinoeto,'���tS�̓��̊��x��Ԃ��B','�Ђ̂��Ƃ���Ƃ�');
  AddFunc('�N�m���x�擾','{=?}S��|S��|S��',4604,cmd_nennoeto,'���tS�̔N�̊��x��Ԃ��B','�˂�̂��Ƃ���Ƃ�');
  AddFunc('�C�������E�X���擾','{=?}S��|S��|S��',4605,cmd_mjd,'���tS����C�������E�X����Ԃ��B','���イ������肤���т���Ƃ�');
  AddFunc('�\�񐯍��擾','{=?}S��|S��|S��',4606,cmd_seiza,'���tS����\�񐯍���Ԃ��B','���イ�ɂ���������Ƃ�');
  AddFunc('�a���Ύ擾','{=?}S��|S��|S��',4607,cmd_tanjouseki,'���tS����a���΂�Ԃ��B','���񂶂傤��������Ƃ�');

  //</����>
end;

end.
