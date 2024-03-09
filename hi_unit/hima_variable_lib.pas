unit hima_variable_lib;

// �Ђ܂Q���L�̌^�ł��� PHiValue �Ɋւ��鏈�����܂Ƃ߂�����

interface

uses
  hima_variable, hima_variable_ex;


// ������ str �� ������ splitter �ŕ����Ĕz��`���� PHiValue �ɕԂ�
function hi_split(str, splitter: PHiValue): PHiValue;

implementation

uses hima_string, unit_string;

// ������ str �� ������ splitter �ŕ����Ĕz��`���� PHiValue �ɕԂ�
function hi_split(str, splitter: PHiValue): PHiValue;
var
  s,  kugiri, res: AnsiString;
  p: PHiValue;
begin
  s := hi_str(str);
  kugiri := hi_str(splitter);

  // �z��Ƃ��ĕԂ�
  Result := hi_var_new;
  hi_ary_create(Result);

  // ��؂菈��
  while (s <> '') do
  begin
    res := getToken_s(s, kugiri);
    p := hi_var_new;
    hi_setStr(p, res);
    hi_ary(Result).Add(p);
  end;
end;

end.
