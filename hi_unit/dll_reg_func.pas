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
  raise Exception.Create('レジストリパス"'+hiv+'"は開けません。');
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
  //HでSのAを
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
  // KEYのVにSを
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
  // KEYのVから
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
  //HでSのAを
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
  //HでSの
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
  //HでSの
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
  //HでSの
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
  //HでSの
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
    if pat = '中央' then
    begin
      reg.WriteString(KEY_TILE_WALLPAPER,  '0');
      reg.WriteString(KEY_STYLE_WALLPAPER, '0');
    end else
    if pat = 'タイル' then
    begin
      reg.WriteString(KEY_TILE_WALLPAPER,  '1');
      reg.WriteString(KEY_STYLE_WALLPAPER, '0');
    end else
    if pat = '拡大' then
    begin
      reg.WriteString(KEY_TILE_WALLPAPER,  '0');
      reg.WriteString(KEY_STYLE_WALLPAPER, '2');
    end else
    begin
      // 中央
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
    if s = '00' then pat := '中央'    else
    if s = '10' then pat := 'タイル'  else
    if s = '02' then pat := '拡大'    else pat := '中央';

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
  //HでSの
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
  //HでSの
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
  // HでSにVをCNTで
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
  // 1)引数
  s := nako_getFuncArg(args, 0);

  // パスが省略されたら、母艦パスにする
  ss := hi_str(s);
  dll_plugin_helper._getEmbedFile(ss); // もし可能なら実行ファイルから取り出す

  if ExtractFileDrive(ss) = '' then
  begin
    if not FileExists(ExpandFileName(WinDir + ss)) then
      ss :=ExpandFileName(hi_str(nako_getVariable('母艦パス')) + ss);
  end;

  // 2)INI
  i := TIniFile.Create(ss);
  // 3)結果
  Result := hi_newInt(Integer(i));
end;
function sys_ini_close(args: DWORD): PHiValue; stdcall;
var
  h: PHiValue;
begin
  // 1)引数
  h := nako_getFuncArg(args, 0);
  // 2)INI
  TIniFile(hi_int(h)).Free;
  // 3)結果
  Result := nil;
end;
function sys_ini_read(args: DWORD): PHiValue; stdcall;
var
  h,a,b: PHiValue;
  s: string;
begin
  // 1)引数
  h := nako_getFuncArg(args, 0);
  a := nako_getFuncArg(args, 1);
  b := nako_getFuncArg(args, 2);
  // 2)INI
  s := TIniFile(hi_int(h)).ReadString(hi_str(a),hi_str(b), '');
  // 3)結果
  Result := hi_newStr(s);
end;
function sys_ini_write(args: DWORD): PHiValue; stdcall;
var
  h,a,b,s: PHiValue;
begin
  // 1)引数
  h := nako_getFuncArg(args, 0);
  a := nako_getFuncArg(args, 1);
  b := nako_getFuncArg(args, 2);
  s := nako_getFuncArg(args, 3);
  // 2)INI
  TIniFile(hi_int(h)).WriteString(hi_str(a),hi_str(b),hi_str(s));
  // 3)結果
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
      raise Exception.Create('スクリーンセイバーを設定できません。');
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
      raise Exception.Create('スクリーンセイバー待ち時間を設定できません。');
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
  //<命令>
  //+レジストリ/INIファイル(nakoreg.dll)
  //-レジストリ
  AddFunc  ('レジストリ開く','Sの', 580, sys_registry_open,'レジストリパスSを開いてハンドルを返す','れじすとりひらく');
  AddFunc  ('レジストリ閉じる','Hの|Hを', 581, sys_registry_close,'レジストリのハンドルHを閉じる','れじすとりとじる');
  AddFunc  ('レジストリ書く','HでSにAを', 582, sys_registry_write,'レジストリのハンドルHを使ってキーSに文字列Aを書く','れじすとりかく');
  AddFunc  ('レジストリ整数書く','HでSにAを', 583, sys_registry_writeInt,'レジストリのハンドルHを使ってキーSに整数Aを書く','れじすとりせいすうかく');
  AddFunc  ('レジストリキー削除','HでSを', 584, sys_registry_deleteKey,'レジストリのハンドルHを使ってキーSを削除する','れじすとりきーさくじょ');
  AddFunc  ('レジストリ値削除','HでSを', 585, sys_registry_deleteVal,'レジストリのハンドルHを使って値Sを削除する','れじすとりあたいさくじょ');
  AddFunc  ('レジストリキー列挙','Hで', 586, sys_registry_enumKeys,'レジストリのハンドルHのキー名を列挙する','れじすとりきーれっきょ');
  AddFunc  ('レジストリ値列挙','Hで', 587, sys_registry_enumValues,'レジストリのハンドルHを使って値を列挙する','れじすとりあたいれっきょ');
  AddFunc  ('レジストリ読む','HでSを', 588, sys_registry_read,'レジストリのハンドルHを使ってSを読んで返す','れじすとりよむ');
  AddFunc  ('レジストリ整数読む','HでSを', 589, sys_registry_readInt,'レジストリのハンドルHを使って整数Sを読んで返す','れじすとりせいすうよむ');
  AddFunc  ('レジストリキー存在','Sが|Sに', 590, sys_registry_KeyExists,'レジストリのキーSが存在するか調べる。','れじすとりきーそんざい');
  AddFunc  ('レジストリ値設定','KEYのVにSを|VへSの', 657, sys_reg_easy_write,'レジストリキーKEYの値Vに文字列Sを書き込む。ハンドル操作不要版。','れじすとりあたいせってい');
  AddFunc  ('レジストリ値取得','KEYのVから|Vを', 658, sys_reg_easy_read,'レジストリキーKEYの値Vの値を読む。ハンドル操作不要版。','れじすとりあたいしゅとく');
  AddFunc  ('レジストリバイナリ読む','{=?}HのSをCNTで', 670, sys_registry_read_bin,'レジストリのハンドルHをつかって値SをCNTバイト読む。','れじすとりばいなりよむ');
  AddFunc  ('レジストリバイナリ書く','{=?}HのSにVをCNTで', 671, sys_registry_write_bin,'レジストリのハンドルHをつかって値SにデータVをCNTバイト読む。','れじすとりばいなりかく');
  //-INIファイル
  AddFunc  ('INI開く','Fの', 591, sys_ini_open,'INIファイルFを開いてハンドルを返す','INIひらく');
  AddFunc  ('INI閉じる','Hの|Hを', 592, sys_ini_close,'INIファイルのハンドルHを閉じる','INIとじる');
  AddFunc  ('INI読む','HでAのBを', 593, sys_ini_read,'INIファイルのハンドルHでセクションＡのキーＢを読む。','INIよむ');
  AddFunc  ('INI書く','HでAのBにSを|', 594, sys_ini_write,'INIファイルのハンドルHでセクションＡのキーＢに値Ｓを書く。','INIかく');
  //-シェル
  AddFunc  ('関連付けシステム通知','', 650, sys_SHChangeNotify,'関連付けの更新をシステムに通知する。','かんれんづけしすてむつうち');
  AddFunc  ('関連付け','SをAに|Aへ', 655, sys_kanrenduke,'拡張子SをアプリケーションAと関連付けする','かんれんづけ');
  AddFunc  ('関連付け解除','Sを|Sの', 656, sys_kanrendukekaijo,'拡張子Sの関連付けを解除する','かんれんづけかいじょ');
  //-壁紙
  AddFunc  ('壁紙設定','{=?}Fに|Fへ', 651, sys_ChangeWallpaper,'画像ファイルFに壁紙を変更する。','かべがみせってい');
  AddFunc  ('壁紙取得','', 652, sys_getWallpaper,'壁紙のファイル名を取得する。','かべがみしゅとく');
  AddFunc  ('壁紙スタイル設定','{=?}Aに|Aへ', 653, sys_ChangeWallpaperStyle,'壁紙のスタイルA(中央|拡大|タイル)に変更する','かべがみすたいるせってい');
  AddFunc  ('壁紙スタイル取得','', 654, sys_getWallpaperStyle,'壁紙のスタイルを取得する。','かべがみすたいるしゅとく');
  //-スクリーンセーバー
  AddFunc  ('スクリーンセイバー取得','', 681, sys_getScr,'スクリーンセイバーのファイル名を取得する。','すくりーんせいばーしゅとく');
  AddFunc  ('スクリーンセイバー設定','{=?}FILEを|FILEに', 682, sys_setScr,'スクリーンセイバーとしてファイル名FILEを設定する。','すくりーんせいばーせってい');
  AddFunc  ('スクリーンセイバー待ち時間取得','', 683, sys_getScrTime,'スクリーンセイバーの待ち時間を秒で取得する。','すくりーんせいばーまちじかんしゅとく');
  AddFunc  ('スクリーンセイバー待ち時間設定','{=?}Vを|Vに', 684, sys_setScrTime,'スクリーンセイバーの待ち時間をV秒に設定する。','すくりーんせいばーまちじかんせってい');
  AddFunc  ('スクリーンセイバー起動','', 685, sys_runScr,'設定されているスクリーンセイバーを起動する','すくりーんせいばーきどう');
  //</命令>
end;


end.
