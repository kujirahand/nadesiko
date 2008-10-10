library nako_qrcode;

uses
  Windows,
  SysUtils,
  Classes,
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  unit_qrcode in 'pro_unit\unit_qrcode.pas',
  QRCode in 'pro_unit\QRCODE.PAS',
  unit_string2 in 'hi_unit\unit_string2.pas';

//------------------------------------------------------------------------------
// 以下関数
//------------------------------------------------------------------------------

function qr_make(h: DWORD): PHiValue; stdcall;
var
  code,
  fname: string;
  bairitu: Integer;
begin
  Result  := nil;
  code    := getArgStr(h, 0, True );
  fname   := getArgStr(h, 1, False);
  bairitu := getArgInt(h, 2, False);
  qr_makeCode(PChar(code), PChar(fname), bairitu);
end;
function qr_setOption(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  qr_option := getArgStr(h, 0);
end;
function qr_setVersion(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  qr_version := getArgInt(h, 0);
end;
function qr_makeStr(h: DWORD): PHiValue; stdcall;
var
  code,
  ret: string;
  qr: TQRCode;
begin
  Result  := nil;
  code    := getArgStr(h, 0, True );
  qr := TQRCode.Create(nil);
  try
    qr_setOpt(qr, code);
    ret := qr.PBM.Text;
    ret := JReplace_(ret, ' ','');
    getToken_s(ret, #13#10);
    getToken_s(ret, #13#10);
    Result := hi_newStr(ret);
  finally
    FreeAndNil(qr);
  end;
end;

//------------------------------------------------------------------------------
// 以下絶対に必要な関数
//------------------------------------------------------------------------------
// 関数追加用
procedure ImportNakoFunction; stdcall;
begin
  // なでしこシステムに関数を追加
  // nako_qrcode.dll,6560-6569
  // <命令>
  //+バーコード[デラックス版のみ](nako_qrcode.dll)
  //-QRコード
  AddFunc('QRコード作成', 'CODEをFILEへBAIRITUの', 6560, qr_make, 'CODEをFILEへ倍率BAIRITUの大きさで作成する。', 'QRコードさくせい');
  AddFunc('QRコードオプション設定', 'Sの', 6561, qr_setOption,  '', 'QRこーどおぷしょんせってい');
  AddFunc('QRコードバージョン設定', 'Vの', 6562, qr_setVersion, '', 'QRこーどばーじょんせってい');
  AddFunc('QRコード文字列取得', 'CODEの|CODEを', 6563, qr_makeStr, 'CODEを0と1の文字列でしゅとくする', 'QRコードもじれつしゅとく');
  // </命令>
end;

//------------------------------------------------------------------------------
// プラグインの情報
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
const STR_INFO = 'QRコードプラグイン by クジラ飛行机';
begin
  Result := Length(STR_INFO);
  if (str <> nil)and(len > 0) then
  begin
    StrLCopy(str, STR_INFO, len);
  end;
end;

//------------------------------------------------------------------------------
// プラグインのバージョン
function PluginVersion: DWORD; stdcall;
begin
  Result := 2; // プラグイン自体のバージョン
end;

//------------------------------------------------------------------------------
// なでしこプラグインバージョン
function PluginRequire: DWORD; stdcall;
begin
  Result := 2; // 必ず2を返すこと
end;

procedure PluginInit(Handle: DWORD); stdcall;
begin
  dnako_import_initFunctions(Handle);
end;
function PluginFin: DWORD; stdcall;
begin
  Result := 0;
end;



exports
  ImportNakoFunction,
  PluginInfo,
  PluginVersion,
  PluginRequire,
  PluginInit;


begin
end.
