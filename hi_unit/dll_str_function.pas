unit dll_str_function;

interface
uses
  windows, dnako_import, dnako_import_types, dll_plugin_helper;

const NAKOSTR_DLL_VERSION = '1.5041';
procedure RegistFunction;

implementation

uses jconvert, jconvertex, StrUnit, hima_types, wildcard, md5,
  CrcUtils, unit_string, SysUtils, Classes, wildcard2,
  nkf, unit_blowfish, SHA1, crypt, mini_file_utils, aeslib, EftGlobal,
  unit_sha256;

function NkfConvertStr(ins, option: string; IsUTF16:Boolean) : string;
begin
  Result := nkf.NkfConvertStr(ins, option, IsUTF16);
end;

function getNakoStrDllVersion(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(NAKOSTR_DLL_VERSION);
end;

function sys_toSJIS(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_newStr(NkfConvertStr(hi_str(s), '--sjis', False));
end;

// old function
{
function sys_nkf(args: DWORD): PHiValue; stdcall;
var
  s: string;
  a, b: string;
  fa,fb: Integer;

  function toCode(s: string): Integer;
  begin
    s := LowerCase(s);
    if s = 'sjis'       then Result := SJIS_OUT else
    if s = 'shift_jis'  then Result := SJIS_OUT else
    if s = 'jis'        then Result := JIS_OUT  else
    if s = 'euc'        then Result := EUC_OUT  else
    if s = 'utf8'       then Result := UTF8_OUT else
    if s = 'utf-8'      then Result := UTF8_OUT else
    if s = 'utf8n'      then Result := UTF8N_OUT else
    if s = 'utf-8n'     then Result := UTF8N_OUT else
    if s = 'unicode'    then Result := UNILE_IN else
    Result := -1;
  end;

begin
  // (1) �����̎擾
  s := getArgStr(args,0, True);
  a := getArgStr(args,1);
  b := getArgStr(args,2);
  // (2) �f�[�^�̏���
  fa := toCode(a);
  fb := toCode(b);

  // (3) �߂�l��ݒ�
  Result := hi_newStr(ConvertJCode(s, fb, fa));
end;
}
{
    --ic=<input_codeset --oc=<output_codeset>>
        ���́E�o�͂̊����R�[�h�n���w�肵�܂��B

        ISO-2022-JP
            ������ JIS �R�[�h�B-j, -J �Ɠ����B

        ISO-2022-JP-1
            RFC 2237 �ɒ�߂�ꂽ�`���B JIS X 0212 ���܂ށB

        ISO-2022-JP-3
            RFC 2237 �ɒ�߂�ꂽ�`���B JIS X 0213 ���܂ށB

        EUC-JP
            EUC �R�[�h�B-e, -E �Ɠ����B

        EUC-JISX0213
            �����W���� JIS X 0213:2000 ��p���� EUC-JP�B

        EUC-JIS-2004
            �����W���� JIS X 0213:2004 ��p���� EUC-JP�B

        eucJP-ascii
            �I�[�v���O���[�v���{�x���_���c���`���� eucJP-ascii�B -x
            ���Öق̂����Ɏw�肳���B

        eucJP-ms
            �I�[�v���O���[�v���{�x���_���c���`���� euc-JPms�B -x
            ���Öق̂����Ɏw�肳���B

        CP51932
            Micorosft Code Page 51932�B -x ���Öق̂����Ɏw�肳���B

        Shift_JIS
            Shift_JIS�B -s, -S �Ɠ����B

        Shift_JISX0213
            �����W���� JIS X 0213:2000 ��p���� Shift_JIS�B

        Shift_JIS-2004
            �����W���� JIS X 0213:2004 ��p���� Shift_JIS�B

        CP932
            Micorosft Code Page 932�B -x ���Öق̂����Ɏw�肳���B

        UTF-8 UTF-8N
            BOM ������ UTF-8�B -w, -W �Ɠ����B

        UTF-8-BOM
            BOM �t���� UTF-8�B-w8 �܂��� -W �Ɠ����B

        UTF8-MAC
            UTF8-MAC�B�݊��������ꂽ�Ђ炪�ȁE�J�^�J�i�����������܂��B

        UTF-16 UTF-16BE-BOM
            BOM �L��� Big Endian �� UTF-16�B -w16B, -W16B �Ɠ����B

        UTF-16BE
            BOM ������ Big Endian �� UTF-16�B -w16B0. -W16B �Ɠ����B

        UTF-16LE-BOM
            BOM �L��� Little Endian �� UTF-16�B -w16L, -W16L �Ɠ����B

        UTF-16LE
            BOM ������ Little Endian �� UTF-16�B -w16L0, -W16L �Ɠ����B

}
function sys_nkf(args: DWORD): PHiValue; stdcall;
var
  s, res: string;
  a, b: string;
  isUTF16: Boolean;

begin
  // (1) �����̎擾
  s := getArgStr(args,0, True); // target
  a := getArgStr(args,1);       // incode
  b := getArgStr(args,2);       // outcode
  // (2) �ϊ�
  a := nkf_easy_code(a);
  b := nkf_easy_code(b);
  if UpperCase(b) = 'UTF-16' then isUTF16 := True else isUTF16 := False;
  res := NkfConvertStr(s, Format('--ic=%s --oc=%s',[a, b]), isUTF16);
  // (3) �߂�l��ݒ�
  Result := hi_newStr(PAnsiChar(res+#0));
end;


function sys_nkf32(args: DWORD): PHiValue; stdcall;
var
  ins, opt, res: string;
begin
  // (1) �����̎擾
  ins := getArgStr(args,0, True);
  opt := getArgStr(args,1);
  // (2) �f�[�^�̏���
  res := NkfConvertStr(ins, opt, True);
  // (3) �߂�l��ݒ�
  Result := hi_newStr(res);
end;


function sys_toUTF8(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  // Result := hi_newStr(ConvertJCode(hi_str(s), UTF8_OUT));
  Result := hi_newStr(Trim(NkfConvertStr(hi_str(s), '-w8', False)));
end;
function sys_toUTF8N(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  //Result := hi_newStr(ConvertJCode(hi_str(s), UTF8N_OUT));
  Result := hi_newStr(Trim(NkfConvertStr(hi_str(s), '-w80', False)));
end;

function sys_toUNICODE(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  //Result := hi_newStr(ConvertJCode(hi_str(s), UNILE_OUT));
  Result := hi_newStr(NkfConvertStr(hi_str(s), '-w16L0', True));
end;

function sys_toEUC(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  //Result := hi_newStr(ConvertJCode(hi_str(s), EUC_OUT));
  Result := hi_newStr(NkfConvertStr(hi_str(s), '-e', False));
end;

function sys_toJIS(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  //Result := hi_newStr(ConvertJCode(hi_str(s), JIS_OUT));
  Result := hi_newStr(NkfConvertStr(hi_str(s), '-j', False));
end;

function sys_toUTF8_SJIS(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_var_new;
  hi_setStr(Result, Utf8Tosjis(hi_str(s)));
  //Result := hi_newStr(NkfConvertStr(hi_str(s), '--ic=UTF-8 --oc=CP932'));
end;

function sys_toSJIS_UTF8(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_var_new;
  hi_setStr(Result, sjisToUtf8(hi_str(s)));
  //Result := hi_newStr(NkfConvertStr(hi_str(s), '--ic=CP932 -w8'));
end;

function sys_toUTF8N_SJIS(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_var_new;
  hi_setStr(Result, Utf8NTosjis(hi_str(s)));
  //Result := hi_newStr(NkfConvertStr(hi_str(s), '--ic=UTF-8N --oc=CP932'));
end;

function sys_toSJIS_UTF8N(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_var_new;
  hi_setStr(Result, sjisToUtf8N(hi_str(s)));
  //Result := hi_newStr(NkfConvertStr(hi_str(s), '--ic=CP932 -w80'));
end;


function sys_checkCode(args: DWORD): PHiValue; stdcall;
var
  str: string;
  ret: string;
begin
  // (1) �����̎擾
  str := getArgStr(args, 0, True);
  // (2) �f�[�^�̏���
  ret := NkfGuessCode(str);
  // (3) �߂�l��ݒ�
  Result := hi_newStr(ret);
end;

function sys_Base64Encode(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_var_new;
  hi_setStr(Result, EncodeBase64(hi_str(s)));
end;
function sys_Base64Decode(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_var_new;
  hi_setStr(Result, DecodeBase64(hi_str(s)));
end;
function sys_URLEncode(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_var_new;
  hi_setStr(Result, jconvert.URLEncode(hi_str(s),True));
end;
function sys_URLDecode(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_var_new;
  hi_setStr(Result, URLDecode(hi_str(s)));
end;
function sys_HEXEncode(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_var_new;
  hi_setStr(Result, HEXEncode(hi_str(s)));
end;

function sys_HEXDecode(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_var_new;
  hi_setStr(Result, HEXDecode(hi_str(s)));
end;

function x_wsse_header(user, password:string): string;
var
  // s: TStringStream;
  wsse: string;
  nonce: string;
  created: string;
  passwordDigest: string;
begin
  {WSSE�F�ؗp�̕���������}
  //created                          //T12:00:00+09:00��
  created := FormatDateTime('yyyy-mm-dd', Now) + 'T' + FormatDateTime('hh:nn:ss+09:00',Now);
  //nonce
  nonce := SHA1StringHex(created + IntToHex(Random(MaxInt), 8));
  //passwordDigest
  passwordDigest := SHA1StringBin(nonce + created + password);
  //wsse
  wsse := Format('X-WSSE: UsernameToken Username="%s", PasswordDigest="%s", Nonce="%s", Created="%s"',
                 [user, EncodeBase64(passwordDigest), EncodeBase64(nonce), created]);
  Result := wsse;
end;


function sys_wsse(args: DWORD): PHiValue; stdcall;
var
  s, user, pass: string;
begin
  user := getArgStr(args, 0, True);
  pass := getArgStr(args, 1);
  s := x_wsse_header(user, pass);
  Result := hi_newStr(s);
end;


function sys_entity_encode(args: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  s := getArgStr(args, 0, True);
  Result := hi_newStr(EntityEncode(s));
end;

function sys_entity_decode(args: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  s := getArgStr(args, 0, True);
  Result := hi_newStr(EntityDecode(s));
end;


function sys_DeleteTag(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_newStr(DeleteTag(hi_str(s)));
end;

function GetTags_ary(html:string; tag: string): PHiValue;
var
  s: string;
begin
  Result := hi_var_new;
  nako_ary_create(Result);

  while html <> '' do
  begin
    s := GetTag(html, tag);
    if s <> '' then begin
      nako_ary_add(Result, hi_newStr(s));
    end;
  end;
end;

function sys_getTags(args: DWORD): PHiValue; stdcall;
var
  s, a: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  a := nako_getFuncArg(args, 1);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := GetTags_ary(hi_str(s),hi_str(a));
end;
function sys_getTagTrees(args: DWORD): PHiValue; stdcall;
var
  ps, pa: PHiValue;
  s: string;
  tags: TStringList;
  i: Integer;
begin
  // (1) �����̎擾
  ps := nako_getFuncArg(args, 0);
  pa := nako_getFuncArg(args, 1);
  if ps = nil then ps := nako_getSore;
  Result := nil;

  // (2) �f�[�^�̏���
  s := hi_str(ps);
  tags := SplitChar('/', hi_str(pa));
  for i := 0 to tags.Count - 1 do
  begin
    if i = (tags.Count-1) then // �Ō�̂P��
    begin
      Result := GetTags_ary(s, tags.Strings[i]);
    end else
    begin
      s := GetTags(s, tags.Strings[i]);
      //'<'���X�y�[�X�ɒu�������āA���̃^�O���o���ɂ��̃^�O������������Ȃ��悤�ɂ���
      //(div/div�Ȃǂ̂悤�ȓ����^�O�̊K�w�\���ɑΉ����邽��)
      if Length(s) > 0 then s[1]:=' ';
    end;
  end;
  tags.Free;
end;
function sys_tagAttribute(args: DWORD): PHiValue; stdcall;
var
  s, a, b: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  a := nako_getFuncArg(args, 1);
  b := nako_getFuncArg(args, 2);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_newStr(GetTagAttribute(hi_str(s), hi_str(a), hi_str(b), False));
end;

function sys_tagAttributeList(args: DWORD): PHiValue; stdcall;
var
  s, a: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  a := nako_getFuncArg(args, 1);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_newStr(GetTagAttribute(hi_str(s), hi_str(a), '', True));
end;

function sys_getLink(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  a, img, ss: string;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s = nil then s := nako_getSore;
  ss := hi_str(s);

  // (2) �f�[�^�̏���
  a   := GetTagAttribute(ss, 'A', 'href');
  img := GetTagAttribute(ss, 'IMG', 'src');

  // (3) �߂�l��ݒ�
  Result := hi_newStr(a+img);
end;

function sys_absolutePath(args: DWORD): PHiValue; stdcall;
var
  s, a: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  a := nako_getFuncArg(args, 1);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_newStr(getAbsolutePath(hi_str(s), hi_str(a), '/'));
end;

function sys_getBasePath(args: DWORD): PHiValue; stdcall;
var
  s: string;
  i, start, last: Integer;
begin
  // (1) �����̎擾
  s := getArgStr(args, 0, True);
  // (2) �f�[�^�̏���
  start := Pos('://', s); if start > 0 then start := start + 3;
  last := 0;
  if start <> 0 then
  begin
    for i := start to Length(s) do
    begin
      if s[i] = '/' then last := i;
    end;
  end;

  if last = 0 then
  begin
    // �X�v���b�^�[���Ȃ�
    // http://... ���Ȃ��ꍇ
    if start = 0 then s := ''; // ��{�p�X�͋�ł���
  end else
  begin
    s := Copy(s, 1, last);
  end;

  // (3) �߂�l��ݒ�
  Result := hi_newStr(s);
end;

function sys_getUrlFilename(args: DWORD): PHiValue; stdcall;
var
  s: string;
  i, start, last: Integer;
begin
  // (1) �����̎擾
  s := getArgStr(args, 0, True);

  s := getToken_s(s, '?'); // http://xxx/xxx/xxx?a=b&c=d&e=f

  // (2) �f�[�^�̏���
  start := Pos('://', s); if start > 0 then start := start + 3;
  last := 0;
  if start <> 0 then
  begin
    for i := start to Length(s) do
    begin
      if s[i] = '/' then last := i;
    end;
  end;

  if last = 0 then
  begin
    // �X�v���b�^�[���Ȃ�
    // http://... ���Ȃ��ꍇ
    if start = 0 then s := ''; // ��{�p�X�͋�ł���
  end else
  begin
    s := Copy(s, last+1, Length(s));
  end;

  // (3) �߂�l��ݒ�
  Result := hi_newStr(s);
end;

function sys_getUrlDomain(args: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  // (1) �����̎擾
  s := getArgStr(args, 0, True);

  // http://xxx:port/xxx/xxx?a=b&c=d&e=f
  //--------------------------
  // �v���g�R���������폜
  getToken_s(s, '//');
  // �f�B���N�g���܂ł�؂���
  s := getToken_s(s, '/');
  // �|�[�g�ԍ�������ΐ؂���
  s := getToken_s(s, ':');

  // (3) �߂�l��ݒ�
  Result := hi_newStr(s);
end;


function sys_toHira(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_newStr(convToHiragana(hi_str(s)));
end;
function sys_toKata(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_newStr(convToKatakana(hi_str(s)));
end;
function sys_toHankaku(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_newStr(convToHalf(hi_str(s)));
end;
function sys_toZenkaku(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_newStr(convToFull(hi_str(s)));
end;
function sys_toHankaku2(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_newStr(convToHalfAnk(hi_str(s)));
end;
function sys_toUpper(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_newStr(UpperCaseEx(hi_str(s)));
end;
function sys_toLower(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_newStr(LowerCaseEx(hi_str(s)));
end;
function sys_toHurigana(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) �����̎擾
  s := nako_getFuncArg(args, 0);
  if s=nil then s := nako_getSore;
  // (2) �f�[�^�̏���
  // (3) �߂�l��ݒ�
  Result := hi_newStr(ConvToHurigana(hi_str(s), nako_getMainWindowHandle));
end;
function sys_cutline(args: DWORD): PHiValue; stdcall;
var
  s, a: PHiValue;
  res: string;
begin
  s := nako_getFuncArg(args, 0); if s = nil then s := nako_getSore;
  a := nako_getFuncArg(args, 1);
  res := CutLine(hi_str(s), hi_int(a), 4);
  Result := hi_newStr(res);
end;
function sys_toRomaji(args: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  s := getArgStr(args, 0, True);
  Result := hi_newStr(KanaToRomaji(s));
end;
function sys_toRomaji2Kana(args: DWORD): PHiValue; stdcall;
var
  s: string;
begin
  s := getArgStr(args, 0, True);
  Result := hi_newStr(RomajiToKana(s));
end;




function StrXor(s:string; key: string): string;

  //------------------------------------------------------------------------------
  // �Ȉ՗������[�`��
  const MAXRNDWORD = 8;
  const init_seed : array [0..MAXRNDWORD-1] of DWORD = ($2378164a, $8478acde, $8f7daf98, $3786daa4, $83748adf, $3428dafa, $89237da1, $3789fda1);
  var rnd_seed  : array [0..MAXRNDWORD-1] of DWORD;

  procedure InitRand;
  var
    i: Integer;
  begin
    for i := 0 to MAXRNDWORD-1 do
      rnd_seed[i] := init_seed[i];
  end;

  function ERand(N: DWORD): DWORD;
  var
    i, r0, r1: Integer;
  begin
    r0 := (rnd_seed[2] shl 7)  + (rnd_seed[3] shr 25);
    r1 := (rnd_seed[6] shl 26) + (rnd_seed[7] shr 6);

    for i := MAXRNDWORD-1 downto 1 do
    begin
      rnd_seed[i] := rnd_seed[i-1];
    end;
    rnd_seed[0] := r0 xor r1;

    Result := rnd_seed[0] mod N;
  end;
  //------------------------------------------------------------------------------

var
  i: Integer;
  b: Byte;
begin
  InitRand;
  if key = '' then key := '_YoNg yUan, wO_ aI youzI';

  for i := 1 to Length(s) do
  begin
    b := Ord(key[i mod Length(key) + 1]) xor ERand(256);
    s[i] := Chr( Ord(s[i]) xor b );
  end;
  Result := s;

end;
//------------------------------------------------------------------------------

function sys_easy_angouka(args: DWORD): PHiValue; stdcall;
var
  ps, pk: PHiValue;
  s, key, res: string;
begin
  ps := nako_getFuncArg(args, 0);
  pk := nako_getFuncArg(args, 1);
  s   := hi_str(ps);
  key := hi_str(pk);

  res := s;
  res := StrXor(res, key);
  res := EncodeBase64(res);
  Result := hi_newStr(res);
end;

function sys_easy_angou_kaijo(args: DWORD): PHiValue; stdcall;
var
  ps, pk: PHiValue;
  s, key, res: string;
begin
  ps := nako_getFuncArg(args, 0);
  pk := nako_getFuncArg(args, 1);
  s   := hi_str(ps);
  key := hi_str(pk);

  res := s;
  res := DecodeBase64(res);
  res := StrXor(res, key);
  Result := hi_newStr(res);
end;


function sys_blowfish_enc(args: DWORD): PHiValue; stdcall;
var
  res, key, s: string;
begin
  s   := getArgStr(args, 0, True);
  key := getArgStr(args, 1);
  res := BlowfishEnc(s, key);
  Result := hi_newStr(res);
end;

function sys_blowfish_dec(args: DWORD): PHiValue; stdcall;
var
  res, key, s: string;
begin
  s   := getArgStr(args, 0, True);
  key := getArgStr(args, 1);
  res := BlowfishDec(s, key);
  Result := hi_newStr(res);
end;


function sys_md5(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(
    md5.MD5Print(md5.MD5String( getArgStr(args, 0, True) ))
  );
end;

function sys_sha1(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(
    SHA1StringHex( getArgStr(args, 0, True))
  );
end;
function sys_sha256(args: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(
    LowerCase(_GetSHA256( getArgStr(args, 0, True)))
  );
end;

function sys_md5file(args: DWORD): PHiValue; stdcall;
var
  f: string;
begin
  f := getArgStr(args, 0, True);
  if not FileExists(f) then raise Exception.Create('�t�@�C��"'+f+'"��������܂���B');
  Result := hi_newStr(MD5FileS( f ));
end;

function sys_sha1file(args: DWORD): PHiValue; stdcall;
var
  f: string;
begin
  f := getArgStr(args, 0, True);
  if not FileExists(f) then raise Exception.Create('�t�@�C��"'+f+'"��������܂���B');
  Result := hi_newStr(SHA1StringHexFile(f));
end;

function sys_crypt(args: DWORD): PHiValue; stdcall;
var
  res, salt, s: AnsiString;
begin
  s   := getArgStr(args, 0, True);
  salt := getArgStr(args, 1);
  res := _crypt(PAnsiChar(s), PAnsiChar(salt));
  Result := hi_newStr(res);
end;

function sys_crc32(args: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
  crc32: TCrc32;
begin
  ps := nako_getFuncArg(args, 0);
  if ps = nil then ps := nako_getSore;

  crc32 := TCrc32R.Create(CRC32_ITU_T, True);
  crc32.Reset;
  crc32.Update(hi_str(ps));
  Result := hi_newFloat(crc32.Value);
  crc32.Free;
end;

function sys_crc16i(args: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
  crc16: TCrc16;
begin
  ps := nako_getFuncArg(args, 0);
  if ps = nil then ps := nako_getSore;

  crc16 := TCrc16R.Create(CRC16_ITU_T, False);
  crc16.Reset;
  crc16.Update(hi_str(ps));
  Result := hi_newInt(crc16.Value);
  crc16.Free;
end;

function sys_crc16a(args: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
  crc16: TCrc16;
begin
  ps := nako_getFuncArg(args, 0);
  if ps = nil then ps := nako_getSore;

  crc16 := TCrc16R.Create(CRC16_ASCII, False);
  crc16.Reset;
  crc16.Update(hi_str(ps));
  Result := hi_newInt(crc16.Value);
  crc16.Free;
end;

function sys_wildMatch(args: DWORD): PHiValue; stdcall;
var
  a, b: PHiValue;
  pat, s, src, res: string;
  pickup: TStringList;
begin
  Result := hi_var_new;

  // (1) �����̎擾
  a   := nako_getFuncArg(args, 0);
  b   := nako_getFuncArg(args, 1);
  if a = nil then a := nako_getSore;

  // (2) �f�[�^�̏���
  s   := hi_str(a);
  pat := hi_str(b);

  pickup := TStringList.Create;
  try
    try
      //res := WildMatch(pat, s, pickup);
      src := s;
      if IsTopMatch(s, pat, pickup) then
      begin
        // �}�b�`����������Ԃ�
        res := Copy(src, 1, Length(src) - Length(s));
      end else
      begin
        // �}�b�`���Ȃ��������̂ł��̂܂�
        s := src;
        res := '';
        pickup.Clear;
      end;
    except on e: Exception do
      raise Exception.Create('�w'+pat+'�x�Ń}�b�`�ł��܂���B' + e.Message);
    end;
    // (3) �߂�l�̐ݒ�
    // res + pickup
    if (pickup = nil)or(pickup.Count = 0) then
    begin
      hi_setStr(Result, res);
    end else
    begin
      hi_setStr(Result, res+#13#10+pickup.Text);
    end;
    // �c��
    hi_setStr(a, s);
  finally
    pickup.Free;
  end;
end;


function sys_wildMatchBool(args: DWORD): PHiValue; stdcall;
var
  v: PHiValue;
  pickup: TStringList;
  a, b: string;
begin
  // (1) �����̎擾
  a := getArgStr(args, 0, True);
  b := getArgStr(args, 1, False);

  // (2) �f�[�^�̏���
  pickup := nil;
  if wildcard2.IsMatch(a, b, pickup) then
  begin
    Result := hi_newBool(True);
    v := nako_getVariable('���o������');
    hi_setStr(v, pickup.Text);
  end else
  begin
    Result := hi_newBool(False);
  end;
  FreeAndNil(pickup);
end;


function sys_wildcard_replace(args: DWORD): PHiValue; stdcall;
var
  s, a, b: string;
begin
  // (1) �����̎擾
  s := getArgStr(args, 0, True);
  a := getArgStr(args, 1, False);
  b := getArgStr(args, 2, False);

  // (2) �f�[�^�̏���
  Result := hi_newStr( wildcard2.WildReplace(s, a, b, True) );
end;

function sys_wildcard_replace_one(args: DWORD): PHiValue; stdcall;
var
  s, a, b: string;
begin
  // (1) �����̎擾
  s := getArgStr(args, 0, True);
  a := getArgStr(args, 1, False);
  b := getArgStr(args, 2, False);

  // (2) �f�[�^�̏���
  Result := hi_newStr( wildcard2.WildReplace(s, a, b, False) );
end;

function sys_wildcard_split(args: DWORD): PHiValue; stdcall;
var
  s, a: string;
  sl: TStringList;
  i: Integer;
begin
  // (1) �����̎擾
  s := getArgStr(args, 0, True);
  a := getArgStr(args, 1, False);

  // (2) �f�[�^�̏���
  sl := WildSplit(s, a);
  try
    Result := hi_var_new;
    nako_ary_create(Result);
    for i := 0 to sl.Count - 1 do
    begin
      nako_ary_add(Result, hi_newStr(sl.Strings[i]));
    end;
  finally
    sl.Free;
  end;
end;

function sys_wildcard_match(args: DWORD): PHiValue; stdcall;
var
  a, b, v: PHiValue;
  pickup: TStringList;
begin
  // (1) �����̎擾
  a   := nako_getFuncArg(args, 0);
  b   := nako_getFuncArg(args, 1);
  if a = nil then a := nako_getSore;

  // (2) �f�[�^�̏���
  pickup := nil;

  Result := hi_newStr( wildcard2.WildSubMatch(hi_str(a), hi_str(b), pickup) );

  v := nako_getVariable('���o������');
  hi_setStr(v, pickup.Text);

  FreeAndNil(pickup);
end;

function sys_wildcard_getToken(args: DWORD): PHiValue; stdcall;
var
  a, b, v: PHiValue;
  pickup: TStringList;
  s: string;
begin
  // (1) �����̎擾
  a   := nako_getFuncArg(args, 0);
  b   := nako_getFuncArg(args, 1);
  if a = nil then a := nako_getSore;

  // (2) �f�[�^�̏���
  pickup := nil;
  try
    // ���C���h�J�[�h�Ńg�[�N���؂�o��
    s := hi_str(a);
    Result := hi_newStr( wildcard2.WildGetToken(s, hi_str(b), pickup) );

    // �c��̕�����؂���
    hi_setStr(a, s);

    // ���肾��������Β��o������ɃZ�b�g
    v := nako_getVariable('���o������');
    hi_setStr(v, pickup.Text);
  finally
    FreeAndNil(pickup);
  end;
end;

function sys_trimKakomi(args: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
  s: string;
begin
  // (1) �����̎擾
  ps := nako_getFuncArg(args, 0);
  if ps = nil then ps := nako_getSore;
  s := trimCoupleFlag(hi_str(ps));
  // (2) �f�[�^�̏���
  Result := hi_newStr(s);
end;


function AES_EncryptStr(InputStr, MyPassword: string): string;
var
  sSource,sDest : TStringStream;
begin
  Result := '';
  sSource := TStringStream.Create(InputStr);
  sDest   := TStringStream.Create('');
  try
    with TEncryption.Create(MyPassword, defCryptBufSize) do
    begin
      if EncryptStream(sSource, sDest) then begin
        Result := sDest.DataString;
      end else
      begin
        raise Exception.Create('AES Encrypt Error!');
      end;
    end;
  finally
    FreeAndNil(sSource);
    FreeAndNil(sDest);
  end;
end;

function AES_DecryptStr(InputStr, MyPassword: string): string;
var
  sSource: TStringStream;
  sDest  : TStringStream;
begin
  Result := '';
  sSource := TStringStream.Create(InputStr);
  sDest   := TStringStream.Create('');
  try
    with TEncryption.Create(MyPassword, defCryptBufSize) do
    begin
      if DecryptStream(sSource, sDest, sSource.Size) then begin
        //
        Result := sDest.DataString;
      end else
      begin
        raise Exception.Create('Decrypt Error!');
      end;
    end;
  finally
    FreeAndNil(sSource);
    FreeAndNil(sDest);
  end;
end;


function sys_aes_crypt(args: DWORD): PHiValue; stdcall;
var
  res, s, key: string;
begin
  s   := getArgStr(args, 0, True);
  key := getArgStr(args, 1);
  res := AES_EncryptStr(s, key);
  Result := hi_newStr(res);
end;
function sys_aes_decrypt(args: DWORD): PHiValue; stdcall;
var
  res, s, key: string;
begin
  s   := getArgStr(args, 0, True);
  key := getArgStr(args, 1);
  res := AES_DecryptStr(s, key);
  Result := hi_newStr(res);
end;

procedure RegistFunction;
begin
  //todo: �֐��̓o�^
  //<���`����>
  //+���`����(nakostr.dll)
  //-�����R�[�h�ϊ�
  AddFunc  ('SJIS�ϊ�','{������=?}S��',700, sys_toSJIS,'������S��SJIS�ɕϊ����ĕԂ�','SJIS�ւ񂩂�','nkf32.dll');
  AddFunc  ('EUC�ϊ�','{������=?}S��',701, sys_toEUC,'������S��EUC�ɕϊ����ĕԂ�','EUC�ւ񂩂�','nkf32.dll');
  AddFunc  ('JIS�ϊ�','{������=?}S��',702, sys_toJIS,'������S��JIS�ɕϊ����ĕԂ�','JIS�ւ񂩂�','nkf32.dll');
  AddFunc  ('UTF8_SJIS�ϊ�','{������=?}S��',703, sys_toUTF8_SJIS,'UTF8�̕�����S��SJIS�ɕϊ����ĕԂ�','UTF8_SJIS�ւ񂩂�','nkf32.dll');
  AddFunc  ('SJIS_UTF8�ϊ�','{������=?}S��',704, sys_toSJIS_UTF8,'SJIS�̕�����S��UTF8�ɕϊ����ĕԂ�','SJIS_UTF8�ւ񂩂�','nkf32.dll');
  AddFunc  ('UTF8N_SJIS�ϊ�','{������=?}S��',705, sys_toUTF8N_SJIS,'UTF8N�̕�����S��SJIS�ɕϊ����ĕԂ�','UTF8N_SJIS�ւ񂩂�','nkf32.dll');
  AddFunc  ('SJIS_UTF8N�ϊ�','{������=?}S��',706, sys_toSJIS_UTF8N,'SJIS�̕�����S��UTF8N�ɕϊ����ĕԂ�','SJIS_UTF8N�ւ񂩂�','nkf32.dll');
  AddFunc  ('�����R�[�h����','{������=?}S��|S��|S����',707, sys_checkCode,'������S�̕����R�[�h�𒲂ׂĕԂ��B(ASCII/BIN/SJIS/JIS/EUC/UTF-8/UTF-8N/UNILE/UNIBE)�̂����ꂩ��Ԃ��B','�������[�ǂ��傤��','nkf32.dll');
  AddFunc  ('UTF8�ϊ�','{������=?}S��',708, sys_toUTF8,'������S��UTF8�ɕϊ����ĕԂ�','UTF8�ւ񂩂�','nkf32.dll');
  AddFunc  ('UTF8N�ϊ�','{������=?}S��',709, sys_toUTF8N,'������S��UTF8N�ɕϊ����ĕԂ�','UTF8�ւ񂩂�','nkf32.dll');
  AddFunc  ('UNICODE�ϊ�','{������=?}S��',718, sys_toUNICODE,'������S��UNICODE�ɕϊ����ĕԂ�','UNICODE�ւ񂩂�','nkf32.dll');
  AddFunc  ('�����R�[�h�ϊ�','{������=?}S��A����B��',719, sys_nkf,'������S�𕶎��R�[�hA(sjis|jis|euc|utf8|utf8n|unicode|�C�ӂ�NKF�R�[�h)����B�ւƕϊ����ĕԂ��B','�������[�ǂւ񂩂�','nkf32.dll');
  AddFunc  ('NKF�ϊ�','{������=?}S��OPT��|S��OPT����', 740, sys_nkf32,'������S��NKF�I�v�V����OPT�ŕϊ����ĕԂ��B','NKF�ւ񂩂�','nkf32.dll');
  //-�S�p���p�J�i�ϊ�
  AddFunc  ('���ȕϊ�','{������=?}S��',710, sys_toHira,'������S���Ђ炪�Ȃɕϊ����ĕԂ�','���Ȃւ񂩂�');
  AddFunc  ('�J�^�J�i�ϊ�','{������=?}S��',711, sys_toKata,'������S���J�^�J�i�ɕϊ����ĕԂ�','�������Ȃւ񂩂�');
  AddFunc  ('���p�ϊ�','{������=?}S��',712, sys_toHankaku,'������S�𔼊p�ɕϊ����ĕԂ�','�͂񂩂��ւ񂩂�');
  AddFunc  ('�S�p�ϊ�','{������=?}S��',713, sys_toZenkaku,'������S��S�p�ɕϊ����ĕԂ�','���񂩂��ւ񂩂�');
  AddFunc  ('�p�����p�ϊ�','{������=?}S��',714, sys_toHankaku2,'������S���p�����������𔼊p�ɕϊ����ĕԂ�','���������͂񂩂��ւ񂩂�');
  AddFunc  ('�啶���ϊ�','{������=?}S��',715, sys_toUpper,'������S��啶���ɕϊ����ĕԂ�','���������ւ񂩂�');
  AddFunc  ('�������ϊ�','{������=?}S��',716, sys_toLower,'������S���������ɕϊ����ĕԂ�','�������ւ񂩂�');
  AddFunc  ('�����ǂݎ擾','{������=?}S��|S��',717, sys_toHurigana,'����S�̂ӂ肪�Ȃ�IME���擾����(�R���\�[����ł͋@�\���Ȃ�)','���񂶂�݂���Ƃ�');
  AddFunc  ('�J�i���[�}���ϊ�','{������=?}S��|S����',722, sys_toRomaji,'������S�ɂ���J�^�J�i�����[�}���ɕϊ�����','���Ȃ�[�܂��ւ񂩂�');
  AddFunc  ('���[�}���J�i�ϊ�','{������=?}S��|S����',723, sys_toRomaji2Kana,'������S�ɂ��郍�[�}�����J�^�J�i�ɕϊ�����','��[�܂����Ȃւ񂩂�');
  //-�G���R�[�h
  AddFunc  ('BASE64�G���R�[�h','{������=?}S��',730, sys_Base64Encode,'������S��BASE64�ɕϊ����ĕԂ�','BASE64���񂱁[��');
  AddFunc  ('BASE64�f�R�[�h','{������=?}S��',731, sys_Base64Decode,'BASE64�f�[�^S�𕜌����ĕԂ�','BASE64�ł��[��');
  AddFunc  ('URL�G���R�[�h','{������=?}S��',732, sys_URLEncode,'������S��URL�G���R�[�h���ĕԂ�','URL���񂱁[��');
  AddFunc  ('URL�f�R�[�h','{������=?}S��',733, sys_URLDecode,'S��URL�f�R�[�h���ĕԂ�','URL�ł��[��');
  AddFunc  ('HEX�G���R�[�h','{������=?}S��',734, sys_HEXEncode,'������S��HEX�G���R�[�h���ĕԂ�','HEX���񂱁[��');
  AddFunc  ('HEX�f�R�[�h','{������=?}S��',735, sys_HEXDecode,'S��HEX�f�R�[�h���ĕԂ�','HEX�ł��[��');
  AddFunc  ('WSSE�w�b�_����','USER��PASSWORD����', 736, sys_wsse, 'AtomAPI�̂��߂�USER��PASSWORD����X-WSSE�w�b�_�𐶐����ĕԂ��B','WSSE�ւ�����������');
  AddFunc  ('HTML�G���e�B�e�B�ϊ�','{������=?}S��|S����|S��', 737, sys_entity_encode, '������S��HTML�G���e�B�e�B�ɕϊ����ĕԂ�','HTML����Ă��Ă��ւ񂩂�');
  AddFunc  ('HTML�G���e�B�e�B����','{������=?}S��|S����|S��', 738, sys_entity_decode, '������S��HTML�G���e�B�e�B���當���ɕ������ĕԂ�','HTML����Ă��Ă��ӂ�����');
  //-HTML/XML����
  AddFunc  ('�^�O�폜','{������=?}S����|S��',750, sys_DeleteTag,'S�̃^�O���폜','������������');
  AddFunc  ('�^�O�؂�o��','{������=?}S����A��|S��A��|',751, sys_getTags,'S����A�̃^�O��؂���','�������肾��');
  AddFunc  ('�^�O�����擾','{������=?}S��A����B��|S��',752,sys_tagAttribute,'S����^�OA�̑���B�����o��','����������������Ƃ�');
  AddFunc  ('�K�w�^�O�؂�o��','{������=?}S����A��|S��A��|',755, sys_getTagTrees,'S�������K�w���̃^�OA��؂���B�Ⴆ�΁whead/title�x�witem/link�x�Ȃ�','���������������肾��');
  AddFunc  ('�^�O�����ꗗ�擾','{������=?}S����A��|S��',756, sys_tagAttributeList,'S����^�OA�ɂ��鑮�����n�b�V���`���Ŏ擾����B','������������������񂵂�Ƃ�');
  AddFunc  ('HTML�����N���o','{������=?}S����|S��',753, sys_getLink,'S����HTML�̃����N(A,IMG�^�O)�𒊏o���ĕԂ�','HTML��񂭂��イ�����');
  AddFunc  ('URL�W�J','{������=?}A��B��',754, sys_absolutePath,'���΃p�XA����{�p�XB�łt�q�k��W�J����','URL�Ă񂩂�');
  AddFunc  ('URL��{�p�X���o','{������=?}URL����|URL��|URL��',757, sys_getBasePath,'URL�����{�p�X�𒊏o���ĕԂ�','URL���ق�ς����イ�����');
  AddFunc  ('URL�t�@�C�������o','{������=?}URL����|URL��|URL��',758, sys_getUrlFilename,'URL����t�@�C���������𒊏o���ĕԂ�','URL�ӂ�����߂����イ�����');
  AddFunc  ('URL�h���C�������o','{������=?}URL����|URL��|URL��',759, sys_getUrlDomain,'URL����h���C�����̕����𒊏o���ĕԂ�','URL�ǂ߂���߂����イ�����');
  //-�s����
  AddFunc  ('�s����','{������=?}S��A��',780, sys_cutline, '������S��A���Ő܂�Ԃ��悤�ɏo�͂���','���傤���낦');
  //-���C���h�J�[�h
  AddFunc  ('��v','{=?}A��B��|A��B��', 791, sys_wildMatchBool,'�w���C���h�J�[�h��v�x�Ɠ����B������A���p�^�[��B�Ɗ��S�Ɉ�v���邩���ׁA�͂�(=1)��������(=0)��Ԃ��B�J�b�R�Ŋ���ƕϐ��w���o������x�֒��o�B','������');
  AddFunc  ('���C���h�J�[�h��v','{=?}A��B��|A��B��', 797, sys_wildMatchBool,'������A���p�^�[��B�Ɋ��S�Ƀ}�b�`���邩���ׁA�͂�(=1)��������(=0)�ŕԂ��B�J�b�R�Ŋ���ƕϐ��w���o������x�֒��o�B','�킢��ǂ��[�ǂ�����');
  AddFunc  ('���C���h�J�[�h�u��','{=?}S��A��B��|A����B��', 793, sys_wildcard_replace,'������S�ɂ���p�^�[��A�𕶎���B�Ƀ��C���h�J�[�h�Œu������B�@�\��VB��ʌ݊��B','�킢��ǂ��[�ǂ�����');
  AddFunc  ('���C���h�J�[�h�P�u��','{=?}S��A��B��|A����B��', 794, sys_wildcard_replace_one,'������S�ɂ���p�^�[��A�𕶎���B�Ƀ��C���h�J�[�h�łP�x�����u������B�@�\��VB��ʌ݊��B','�킢��ǂ��[�ǂ��񂿂���');
  AddFunc  ('���C���h�J�[�h��؂�','{=?}S��A��', 796, sys_wildcard_split,'������S���p�^�[��A�ŋ�؂��Ĕz��ϐ��Ƃ��ĕԂ��B','�킢��ǂ��[�ǂ�����');
  AddFunc  ('���C���h�J�[�h�}�b�`','{=?}A��B��|A��B��', 798, sys_wildcard_match,'������A���p�^�[��B�ɕ����I�ɂł��}�b�`����΁A�}�b�`���镔����Ԃ��B�J�b�R�Ŋ���ƕϐ��w���o������x�֒��o�B','�킢��ǂ��[�ǂ܂���');
  AddFunc  ('���C���h�J�[�h�؂���','{�Q�Ɠn��=?}S��A�܂ł�|S��A�܂�|S��A��', 799, sys_wildcard_getToken,'������S�̃p�^�[��A�܂ł�؂����ĕԂ��B�؂���ꂽ�����͕�����S����폜�����B�J�b�R�Ŋ���ƕϐ��w���o������x�֒��o�B','�킢��ǂ��[�ǂ���Ƃ�');
  //AddStrVar('���o������', '', 795, '�w���K�\���}�b�`�x��w���C���h�J�[�h��v�x���ߌ�ɃJ�b�R�Ŋ��������������o�����������B','���イ����������');
  //-�ȈՈÍ���
  AddFunc  ('�ȈՈÍ���',    'S��KEY��',   781, sys_easy_angouka,'������S��KEY�ňÍ��������ĕԂ��B','���񂢂��񂲂���');
  AddFunc  ('�ȈՈÍ�������','S��KEY��',   782, sys_easy_angou_kaijo,'�Í�������������S��KEY�ňÍ����������ĕԂ��B','���񂢂��񂲂�����������');
  AddFunc  ('BLOWFISH�Í���', 'S��KEY��', 720, sys_blowfish_enc,'������S��KEY��BLOWSH�Í��������ĕԂ��B','BLOWFISH���񂲂���');
  AddFunc  ('BLOWFISH������', 'S��KEY��', 721, sys_blowfish_dec,'������S��KEY��BLOWSH�Í����������ĕԂ��B','BLOWFISH�ӂ�������');
  AddFunc  ('CRYPT�Í���',    'S��SALT��',   788, sys_crypt,'������S�֎�SALT��Unix�݊���CRYPT(DES)�Í��������ĕԂ��B','CRYPT���񂲂���');
  AddFunc  ('AES�Í���',      'S��KEY��',   789, sys_aes_crypt,'������S��KEY��AES�Í��������ĕԂ��B','AES���񂲂���');
  AddFunc  ('AES������',      'S��KEY��',   790, sys_aes_decrypt,'������S��KEY��AES�̈Í��𕜍����ĕԂ��B','AES�ӂ�������');

  //-�`�F�b�N�T��
  AddFunc  ('MD5�擾',  '{=?}S����|S��|S��',  783, sys_md5,     '�o�C�i��S���������̓��̊m�F�Ɏg����MD5������(HEX�`��)��Ԃ��B','MD5����Ƃ�');
  AddFunc  ('CRC32�擾','{=?}S����|S��|S��',  784, sys_crc32,   '�o�C�i��S����CRC32�������Ԃ��B','CRC32����Ƃ�');
  AddFunc  ('CRC16�擾','{=?}S����|S��|S��',  785, sys_crc16a,  '�o�C�i��S����CRC16(ASCII)�������Ԃ��B','CRC16����Ƃ�');
  AddFunc  ('CRC16I�擾','{=?}S����|S��|S��', 786, sys_crc16i,  '�o�C�i��S����CRC16(ITU_T)�������Ԃ��B','CRC16I����Ƃ�');
  AddFunc  ('SHA1�擾',  '{=?}S����|S��|S��', 787, sys_sha1,    '�o�C�i��S���������̓��̊m�F�Ɏg����SHA-1������(HEX�`��)��Ԃ��B','SHA1����Ƃ�');
  AddFunc  ('SHA256�擾','{=?}S����|S��|S��', 779, sys_sha256,  '�o�C�i��S���������̓��̊m�F�Ɏg����SHA-256������(HEX�`��)��Ԃ��B','SHA256����Ƃ�');
  AddFunc  ('MD5�t�@�C���擾',  '{=?}FILE����|FILE��', 801, sys_md5file,  'FILE���������̓��̊m�F�Ɏg����MD5������(HEX�`��)��Ԃ��B','MD5�ӂ����邵��Ƃ�');
  AddFunc  ('SHA1�t�@�C���擾', '{=?}FILE����|FILE��', 802, sys_sha1file, 'FILE���������̓��̊m�F�Ɏg����SHA-1������(HEX�`��)��Ԃ��B','SHA1�ӂ����邵��Ƃ�');
  //-���`�x��
  AddFunc  ('�͂݃g����','{=?}S��|S����|S��|S��', 792, sys_trimKakomi,'������S�ɂ���`S`��wS�x�Ȃǂ̈͂݋L���������ĕԂ��B','�����݂Ƃ��');
  //-nakostr.dll
  AddFunc  ('NAKOSTR_DLL�o�[�W����','',800, getNakoStrDllVersion,'nakostr.dll�̃o�[�W������Ԃ�','NAKOSTR_DLL�΁[�����');
    //</���`����>
end;

end.
