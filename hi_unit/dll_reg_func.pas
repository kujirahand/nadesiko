unit dll_reg_func;

interface
uses
  windows, dnako_import, dnako_import_types, dll_plugin_helper,
  unit_pack_files, SysUtils, Classes, shellapi, registry, inifiles,
  shlobj, Variants, ActiveX, hima_types, messages, nadesiko_version;

const
  NAKOFILE_DLL_VERSION = NADESIKO_VER;


procedure RegistFunction;

implementation

uses unit_windows_api, unit_string, hima_stream, StrUnit,
  mini_file_utils, unit_archive, LanUtil, unit_text_file, ComObj,
  unit_kanrenduke,
  EasyMasks;


procedure RegSetRoot(r: TRegistry; hiv: string);
begin
  if hiv = 'HKEY_CLASSES_ROOT'  then r.RootKey := HKEY_CLASSES_ROOT else
  if hiv = 'HKEY_CURRENT_USER'  then r.RootKey := HKEY_CURRENT_USER else
  if hiv = 'HKEY_LOCAL_MACHINE' then r.RootKey := HKEY_LOCAL_MACHINE else
  if hiv = 'HKEY_USERS'         then r.RootKey := HKEY_USERS else
  if hiv = 'HKEY_PERFORMANCE_DATA'  then r.RootKey := HKEY_PERFORMANCE_DATA else
  if hiv = 'HKEY_CURRENT_CONFIG'    then r.RootKey := HKEY_CURRENT_CONFIG else
  if hiv = 'HKEY_DYN_DATA'    then r.RootKey := HKEY_DYN_DATA       else
  raise Exception.Create('���W�X�g���p�X"'+hiv+'"�͊J���܂���B');
end;

function sys_registry_open(args: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
  r: TRegistry;
  path: string;
  hiv: string;
begin
  a := nako_getFuncArg(args, 0);

  path := hi_str(a);
  hiv  := getToken_s(path, '\'); path := '\'+ path;

  r := TRegistry.Create;

  RegSetRoot(r, hiv);
  r.OpenKey(path, True);

  Result := hi_var_new;
  hi_setInt(Result, Integer(r));
end;

function sys_registry_write(args: DWORD): PHiValue; stdcall;
var
  h,s,a: PHiValue;
  r: TRegistry;
begin
  //H��S��A��
  h := nako_getFuncArg(args, 0);
  s := nako_getFuncArg(args, 1);
  a := nako_getFuncArg(args, 2);

  r := TRegistry(hi_int(h));
  r.WriteString(hi_str(s), hi_str(a));

  Result := nil;
end;

function sys_reg_easy_write(args: DWORD): PHiValue; stdcall;
var
  key, hiv, value, s: string;
  r: TRegistry;
begin
  // KEY��V��S��
  key   := getArgStr(args, 0, True);
  value := getArgStr(args, 1);
  s     := getArgStr(args, 2);
  //
  r := TRegistry.Create;
  try
    hiv := GetToken('\', key); key := '\' + key;
    RegSetRoot(r, hiv);
    if r.OpenKey(key, True) then
    begin
      r.WriteString(value, s);
    end;
  finally
    r.Free;
  end;
  Result := nil;
end;

function sys_reg_easy_read(args: DWORD): PHiValue; stdcall;
var
  key, hiv, value, s: string;
  r: TRegistry;
begin
  // KEY��V����
  key   := getArgStr(args, 0, True);
  value := getArgStr(args, 1);
  s     := getArgStr(args, 2);
  //
  Result := nil;
  r := TRegistry.Create;
  try
    hiv := GetToken('\', key); key := '\' + key;
    RegSetRoot(r, hiv);
    if r.OpenKey(key, False) then
    begin
      Result := hi_newStr(r.ReadString(value));
    end;
  finally
    r.Free;
  end;
end;

function sys_registry_writeInt(args: DWORD): PHiValue; stdcall;
var
  h,s,a: PHiValue;
  r: TRegistry;
begin
  //H��S��A��
  h := nako_getFuncArg(args, 0);
  s := nako_getFuncArg(args, 1);
  a := nako_getFuncArg(args, 2);

  r := TRegistry(hi_int(h));
  r.WriteInteger(hi_str(s), hi_int(a));

  Result := nil;
end;

function sys_registry_deleteKey(args: DWORD): PHiValue; stdcall;
var
  h,s: PHiValue;
  r: TRegistry;
begin
  //H��S��
  h := nako_getFuncArg(args, 0);
  s := nako_getFuncArg(args, 1);

  r := TRegistry(hi_int(h));
  r.DeleteKey(hi_str(s));

  Result := nil;
end;

function sys_registry_deleteVal(args: DWORD): PHiValue; stdcall;
var
  h,s: PHiValue;
  r: TRegistry;
begin
  //H��S��
  h := nako_getFuncArg(args, 0);
  s := nako_getFuncArg(args, 1);

  r := TRegistry(hi_int(h));
  r.DeleteValue(hi_str(s));

  Result := nil;
end;

function sys_registry_EnumKeys(args: DWORD): PHiValue; stdcall;
var
  h: PHiValue;
  r: TRegistry;
  sl: TStringList;
begin
  //H��S��
  h := nako_getFuncArg(args, 0);

  r := TRegistry(hi_int(h));
  sl := TStringList.Create;
  r.GetKeyNames(sl);

  Result := hi_newStr(sl.Text);
  sl.Free;
end;

function sys_registry_EnumValues(args: DWORD): PHiValue; stdcall;
var
  h: PHiValue;
  r: TRegistry;
  sl: TStringList;
begin
  //H��S��
  h := nako_getFuncArg(args, 0);

  r := TRegistry(hi_int(h));
  sl := TStringList.Create;
  r.GetValueNames(sl);

  Result := hi_newStr(sl.Text);
  sl.Free;
end;

function sys_registry_KeyExists(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  r: TRegistry;
  path, hiv: string;
begin
  s := nako_getFuncArg(args, 0);

  path := hi_str(s);
  hiv  := getToken_s(path, '\'); path := '\'+ path;

  r := TRegistry.Create;
  try
    RegSetRoot(r, hiv);
    Result := hi_var_new;
    hi_setBool(Result, r.KeyExists(path));
  finally
    r.Free;
  end;
end;

function sys_SHChangeNotify(args: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  SHChangeNotify(
    SHCNE_ASSOCCHANGED,
    SHCNF_FLUSHNOWAIT,
    nil,
    nil);
end;


const
  KEY_TILE_WALLPAPER  = 'TileWallpaper';
  KEY_STYLE_WALLPAPER = 'WallpaperStyle';

function sys_ChangeWallpaper(args: DWORD): PHiValue; stdcall;
var
  fname: string;
begin
  Result := nil;
  // ---
  fname := getArgStr(args, 0, True);
  if fname = '' then fname := #0;
  // wallpaper
  SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, PChar(fname),
    SPIF_UPDATEINIFILE or SPIF_SENDWININICHANGE);
end;

function sys_ChangeWallpaperStyle(args: DWORD): PHiValue; stdcall;
var
  pat, fname: string;
  reg: TRegistry;
begin
  Result := nil;
  // ---
  pat := getArgStr(args, 0, True);
  // ---
  //***HKEY_CURRENT_USER\Control Panel\Desktop
  // style
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey('Control Panel\Desktop',False);
    if pat = '����' then
    begin
      reg.WriteString(KEY_TILE_WALLPAPER,  '0');
      reg.WriteString(KEY_STYLE_WALLPAPER, '0');
    end else
    if pat = '�^�C��' then
    begin
      reg.WriteString(KEY_TILE_WALLPAPER,  '1');
      reg.WriteString(KEY_STYLE_WALLPAPER, '0');
    end else
    if pat = '�g��' then
    begin
      reg.WriteString(KEY_TILE_WALLPAPER,  '0');
      reg.WriteString(KEY_STYLE_WALLPAPER, '2');
    end else
    begin
      // ����
      reg.WriteString(KEY_TILE_WALLPAPER,  '0');
      reg.WriteString(KEY_STYLE_WALLPAPER, '0');
    end;
    fname := reg.ReadString('Wallpaper');
    if fname = '' then fname := #0;
    // wallpaper
    SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, PChar(fname),
      SPIF_UPDATEINIFILE or SPIF_SENDWININICHANGE);

  finally
    reg.Free;
  end;
end;


function sys_getWallpaper(args: DWORD): PHiValue; stdcall;
var
  fname: string;
  reg: TRegistry;
begin

  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey('Control Panel\Desktop',False);
    fname := reg.ReadString('Wallpaper');
    Result := hi_newStr(fname);

  finally
    reg.Free;
  end;
end;


function sys_getWallpaperStyle(args: DWORD): PHiValue; stdcall;
var
  s, pat, tile, style: string;
  reg: TRegistry;
begin

  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey('Control Panel\Desktop',False);

    tile  := reg.ReadString(KEY_TILE_WALLPAPER);
    style := reg.ReadString(KEY_STYLE_WALLPAPER);

    s := tile + style;
    if s = '00' then pat := '����'    else
    if s = '10' then pat := '�^�C��'  else
    if s = '02' then pat := '�g��'    else pat := '����';

    Result := hi_newStr(pat);

  finally
    reg.Free;
  end;
end;

function sys_registry_read(args: DWORD): PHiValue; stdcall;
var
  h, s: PHiValue;
  r: TRegistry;
begin
  //H��S��
  h := nako_getFuncArg(args, 0);
  s := nako_getFuncArg(args, 1);

  r := TRegistry(hi_int(h));

  Result := hi_var_new;
  hi_setStr(Result, r.ReadString(hi_str(s)));
end;

function sys_registry_readInt(args: DWORD): PHiValue; stdcall;
var
  h, s: PHiValue;
  r: TRegistry;
begin
  //H��S��
  h := nako_getFuncArg(args, 0);
  s := nako_getFuncArg(args, 1);

  r := TRegistry(hi_int(h));
  Result := hi_var_new;
  hi_setInt(Result, r.ReadInteger(hi_str(s)));
end;


function sys_registry_read_bin(args: DWORD): PHiValue; stdcall;
var
  h: Integer;
  s, buf: string;
  cnt: Integer;
  r: TRegistry;
begin
  //H, S, CNT
  h   := getArgInt(args, 0, True);
  s   := getArgStr(args, 1, False);
  cnt := getArgInt(args, 2, False);
  //
  SetLength(buf, cnt);
  //
  r := TRegistry(Pointer(h));
  r.ReadBinaryData(s, buf[1], cnt);
  //
  Result := hi_newStr(buf);
end;
function sys_registry_write_bin(args: DWORD): PHiValue; stdcall;
var
  h   : Integer;
  s   : string;
  v   : string;
  cnt : Integer;
  r   : TRegistry;
begin
  // H��S��V��CNT��
  h   := getArgInt(args, 0, True);
  s   := getArgStr(args, 1, False);
  v   := getArgStr(args, 2, False);
  cnt := getArgInt(args, 3, False);
  //
  if (Length(v) < cnt) then
  begin
    cnt := Length(v);
  end;
  //
  Result := nil;
  r := TRegistry(Pointer(h));
  r.WriteBinaryData(s, v[1], cnt);
end;


function sys_registry_close(args: DWORD): PHiValue; stdcall;
var
  a: PHiValue;
  r: TRegistry;
begin
  a := nako_getFuncArg(args, 0);

  r := TRegistry(hi_int(a));
  r.CloseKey;
  r.Free;

  Result := nil;
end;

function sys_ini_open(args: DWORD): PHiValue; stdcall;
var
  s: PHiValue; ss: string;
  i: TIniFile;
begin
  // 1)����
  s := nako_getFuncArg(args, 0);

  // �p�X���ȗ����ꂽ��A��̓p�X�ɂ���
  ss := hi_str(s);
  dll_plugin_helper._getEmbedFile(ss); // �����\�Ȃ���s�t�@�C��������o��

  if ExtractFileDrive(ss) = '' then
  begin
    if not FileExists(ExpandFileName(WinDir + ss)) then
      ss :=ExpandFileName(hi_str(nako_getVariable('��̓p�X')) + ss);
  end;

  // 2)INI
  i := TIniFile.Create(ss);
  // 3)����
  Result := hi_newInt(Integer(i));
end;
function sys_ini_close(args: DWORD): PHiValue; stdcall;
var
  h: PHiValue;
begin
  // 1)����
  h := nako_getFuncArg(args, 0);
  // 2)INI
  TIniFile(hi_int(h)).Free;
  // 3)����
  Result := nil;
end;
function sys_ini_read(args: DWORD): PHiValue; stdcall;
var
  h,a,b: PHiValue;
  s: string;
begin
  // 1)����
  h := nako_getFuncArg(args, 0);
  a := nako_getFuncArg(args, 1);
  b := nako_getFuncArg(args, 2);
  // 2)INI
  s := TIniFile(hi_int(h)).ReadString(hi_str(a),hi_str(b), '');
  // 3)����
  Result := hi_newStr(s);
end;
function sys_ini_write(args: DWORD): PHiValue; stdcall;
var
  h,a,b,s: PHiValue;
begin
  // 1)����
  h := nako_getFuncArg(args, 0);
  a := nako_getFuncArg(args, 1);
  b := nako_getFuncArg(args, 2);
  s := nako_getFuncArg(args, 3);
  // 2)INI
  TIniFile(hi_int(h)).WriteString(hi_str(a),hi_str(b),hi_str(s));
  // 3)����
  Result := nil;
end;
function sys_kanrenduke(args: DWORD): PHiValue; stdcall;
var
  ext, app: string;
begin
  Result := nil;
  ext := getArgStr(args, 0, True);
  app := getArgStr(args, 1, False);
  Kanrenduke(ext, app);
end;
function sys_kanrendukekaijo(args: DWORD): PHiValue; stdcall;
var
  ext: string;
begin
  Result := nil;
  ext := getArgStr(args, 0, True);
  KanrendukeKaijo(ext);
end;

const
  KEY_USER_DESKTOP = '\Control Panel\Desktop';

function sys_getScr(args: DWORD): PHiValue; stdcall;
var
  reg: TRegistry;
  scr: string;
begin
  Result := nil;
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey(KEY_USER_DESKTOP, False) then
    begin
      scr := reg.ReadString('SCRNSAVE.EXE');
      reg.CloseKey;
      Result := hi_newStr(scr);
    end;
  finally
    FreeAndNil(reg);
  end;
end;


function sys_runScr(args: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  PostMessage(HWND_BROADCAST, WM_SYSCOMMAND, SC_SCREENSAVE, 0);
end;

function sys_setScr(args: DWORD): PHiValue; stdcall;
var
  reg: TRegistry;
  scr: string;
begin
  Result := nil;
  scr := getArgStr(args, 0, True);
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey(KEY_USER_DESKTOP, True) then
    begin
      if scr = '' then
      begin
        reg.WriteString('SCRNSAVE.EXE', '');
        reg.WriteInteger('ScreenSaveActive', 0);
      end else
      begin
        reg.WriteString('SCRNSAVE.EXE', scr);
        reg.WriteInteger('ScreenSaveActive', 1);
      end;
      reg.CloseKey;
    end else
    begin
      raise Exception.Create('�X�N���[���Z�C�o�[��ݒ�ł��܂���B');
    end;
  finally
    FreeAndNil(reg);
  end;
end;

function sys_getScrTime(args: DWORD): PHiValue; stdcall;
var
  reg: TRegistry;
  timer: Integer;
begin
  Result := nil;
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey(KEY_USER_DESKTOP, False) then
    begin
      timer := StrToIntDef(reg.ReadString('ScreenSaveTimeOut'), 0);
      reg.CloseKey;
      Result := hi_newInt(timer);
    end;
  finally
    FreeAndNil(reg);
  end;
end;

function sys_setScrTime(args: DWORD): PHiValue; stdcall;
var
  reg: TRegistry;
  timer: String;
begin
  Result := nil;
  timer := IntToStr(getArgInt(args, 0, True));
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey(KEY_USER_DESKTOP, True) then
    begin
      reg.WriteString('ScreenSaveTimeOut', timer);
      reg.CloseKey;
    end else
    begin
      raise Exception.Create('�X�N���[���Z�C�o�[�҂����Ԃ�ݒ�ł��܂���B');
    end;
  finally
    FreeAndNil(reg);
  end;
end;




procedure RegistFunction;

  function RuntimeDir: string;
  begin
    Result := ExtractFilePath(ParamStr(0));
  end;

begin
  //<����>
  //+���W�X�g��/INI�t�@�C��(nakoreg.dll)
  //-���W�X�g��
  AddFunc  ('���W�X�g���J��','S��', 580, sys_registry_open,'���W�X�g���p�XS���J���ăn���h����Ԃ�','�ꂶ���Ƃ�Ђ炭');
  AddFunc  ('���W�X�g������','H��|H��', 581, sys_registry_close,'���W�X�g���̃n���h��H�����','�ꂶ���Ƃ�Ƃ���');
  AddFunc  ('���W�X�g������','H��S��A��', 582, sys_registry_write,'���W�X�g���̃n���h��H���g���ăL�[S�ɕ�����A������','�ꂶ���Ƃ肩��');
  AddFunc  ('���W�X�g����������','H��S��A��', 583, sys_registry_writeInt,'���W�X�g���̃n���h��H���g���ăL�[S�ɐ���A������','�ꂶ���Ƃ肹����������');
  AddFunc  ('���W�X�g���L�[�폜','H��S��', 584, sys_registry_deleteKey,'���W�X�g���̃n���h��H���g���ăL�[S���폜����','�ꂶ���Ƃ肫�[��������');
  AddFunc  ('���W�X�g���l�폜','H��S��', 585, sys_registry_deleteVal,'���W�X�g���̃n���h��H���g���ĒlS���폜����','�ꂶ���Ƃ肠������������');
  AddFunc  ('���W�X�g���L�[��','H��', 586, sys_registry_enumKeys,'���W�X�g���̃n���h��H�̃L�[����񋓂���','�ꂶ���Ƃ肫�[�������');
  AddFunc  ('���W�X�g���l��','H��', 587, sys_registry_enumValues,'���W�X�g���̃n���h��H���g���Ēl��񋓂���','�ꂶ���Ƃ肠�����������');
  AddFunc  ('���W�X�g���ǂ�','H��S��', 588, sys_registry_read,'���W�X�g���̃n���h��H���g����S��ǂ�ŕԂ�','�ꂶ���Ƃ���');
  AddFunc  ('���W�X�g�������ǂ�','H��S��', 589, sys_registry_readInt,'���W�X�g���̃n���h��H���g���Đ���S��ǂ�ŕԂ�','�ꂶ���Ƃ肹���������');
  AddFunc  ('���W�X�g���L�[����','S��|S��', 590, sys_registry_KeyExists,'���W�X�g���̃L�[S�����݂��邩���ׂ�B','�ꂶ���Ƃ肫�[���񂴂�');
  AddFunc  ('���W�X�g���l�ݒ�','KEY��V��S��|V��S��', 657, sys_reg_easy_write,'���W�X�g���L�[KEY�̒lV�ɕ�����S���������ށB�n���h������s�v�ŁB','�ꂶ���Ƃ肠���������Ă�');
  AddFunc  ('���W�X�g���l�擾','KEY��V����|V��', 658, sys_reg_easy_read,'���W�X�g���L�[KEY�̒lV�̒l��ǂށB�n���h������s�v�ŁB','�ꂶ���Ƃ肠��������Ƃ�');
  AddFunc  ('���W�X�g���o�C�i���ǂ�','{=?}H��S��CNT��', 670, sys_registry_read_bin,'���W�X�g���̃n���h��H�������ĒlS��CNT�o�C�g�ǂށB','�ꂶ���Ƃ�΂��Ȃ���');
  AddFunc  ('���W�X�g���o�C�i������','{=?}H��S��V��CNT��', 671, sys_registry_write_bin,'���W�X�g���̃n���h��H�������ĒlS�Ƀf�[�^V��CNT�o�C�g�ǂށB','�ꂶ���Ƃ�΂��Ȃ肩��');
  //-INI�t�@�C��
  AddFunc  ('INI�J��','F��', 591, sys_ini_open,'INI�t�@�C��F���J���ăn���h����Ԃ�','INI�Ђ炭');
  AddFunc  ('INI����','H��|H��', 592, sys_ini_close,'INI�t�@�C���̃n���h��H�����','INI�Ƃ���');
  AddFunc  ('INI�ǂ�','H��A��B��', 593, sys_ini_read,'INI�t�@�C���̃n���h��H�ŃZ�N�V�����`�̃L�[�a��ǂށB','INI���');
  AddFunc  ('INI����','H��A��B��S��|', 594, sys_ini_write,'INI�t�@�C���̃n���h��H�ŃZ�N�V�����`�̃L�[�a�ɒl�r�������B','INI����');
  //-�V�F��
  AddFunc  ('�֘A�t���V�X�e���ʒm','', 650, sys_SHChangeNotify,'�֘A�t���̍X�V���V�X�e���ɒʒm����B','������Â������Ăނ���');
  AddFunc  ('�֘A�t��','S��A��|A��', 655, sys_kanrenduke,'�g���qS���A�v���P�[�V����A�Ɗ֘A�t������','������Â�');
  AddFunc  ('�֘A�t������','S��|S��', 656, sys_kanrendukekaijo,'�g���qS�̊֘A�t������������','������Â���������');
  //-�ǎ�
  AddFunc  ('�ǎ��ݒ�','{=?}F��|F��', 651, sys_ChangeWallpaper,'�摜�t�@�C��F�ɕǎ���ύX����B','���ׂ��݂����Ă�');
  AddFunc  ('�ǎ��擾','', 652, sys_getWallpaper,'�ǎ��̃t�@�C�������擾����B','���ׂ��݂���Ƃ�');
  AddFunc  ('�ǎ��X�^�C���ݒ�','{=?}A��|A��', 653, sys_ChangeWallpaperStyle,'�ǎ��̃X�^�C��A(����|�g��|�^�C��)�ɕύX����','���ׂ��݂������邹���Ă�');
  AddFunc  ('�ǎ��X�^�C���擾','', 654, sys_getWallpaperStyle,'�ǎ��̃X�^�C�����擾����B','���ׂ��݂������邵��Ƃ�');
  //-�X�N���[���Z�[�o�[
  AddFunc  ('�X�N���[���Z�C�o�[�擾','', 681, sys_getScr,'�X�N���[���Z�C�o�[�̃t�@�C�������擾����B','������[�񂹂��΁[����Ƃ�');
  AddFunc  ('�X�N���[���Z�C�o�[�ݒ�','{=?}FILE��|FILE��', 682, sys_setScr,'�X�N���[���Z�C�o�[�Ƃ��ăt�@�C����FILE��ݒ肷��B','������[�񂹂��΁[�����Ă�');
  AddFunc  ('�X�N���[���Z�C�o�[�҂����Ԏ擾','', 683, sys_getScrTime,'�X�N���[���Z�C�o�[�̑҂����Ԃ�b�Ŏ擾����B','������[�񂹂��΁[�܂������񂵂�Ƃ�');
  AddFunc  ('�X�N���[���Z�C�o�[�҂����Ԑݒ�','{=?}V��|V��', 684, sys_setScrTime,'�X�N���[���Z�C�o�[�̑҂����Ԃ�V�b�ɐݒ肷��B','������[�񂹂��΁[�܂������񂹂��Ă�');
  AddFunc  ('�X�N���[���Z�C�o�[�N��','', 685, sys_runScr,'�ݒ肳��Ă���X�N���[���Z�C�o�[���N������','������[�񂹂��΁[���ǂ�');
  //</����>
end;


end.
