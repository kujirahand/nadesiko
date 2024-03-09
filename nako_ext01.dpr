library nako_ext01;

uses
  FastMM4 in 'FastMM4.pas',
  Windows, SysUtils, Classes,
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',

  Graphics,
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  unit_string2 in 'hi_unit\unit_string2.pas',
  frmWebDialogU in 'pro_unit\ext01\frmWebDialogU.pas',
  frmImageDialogU in 'pro_unit\ext01\frmImageDialogU.pas' {frmImageDialog},
  GldPng in 'component\gldpng\gldpng.pas';

// path を追加すること

//------------------------------------------------------------------------------
// 以下関数
//------------------------------------------------------------------------------

function nako_dlg_web(h: DWORD): PHiValue; stdcall;
var
  f: TfrmWebDialog;
  url: string;
begin
  Result := nil;
  url := getArgStr(h, 0, True);
  f := TfrmWebDialog.Create(nil);
  try
    try
      f.browser.Navigate(url);
    except
      try
        Sleep(500);
        f.browser.Navigate(url);
      except
        f.browser.Navigate('about:blank');
      end;
    end;
    f.ShowModal;
  finally
    FreeAndNil(f);
  end;
end;

function nako_dlg_img(h: DWORD): PHiValue; stdcall;
var
  fn: string;
  f: TfrmImageDialog;
begin
  Result := nil;
  fn := getArgStr(h, 0, True);
  f := TfrmImageDialog.Create(nil);
  try
    f.img.Picture.LoadFromFile(fn);
    f.img.Repaint;
    f.ShowModal;
  finally
    f.Free;
  end;
end;


//------------------------------------------------------------------------------
// 以下絶対に必要な関数
//------------------------------------------------------------------------------
// 関数追加用
procedure ImportNakoFunction; stdcall;
begin
  // なでしこシステムに関数を追加
  // nako_ext01.dll,6570-6599
  // <命令>
  //+事務拡張パック[事務自動化パックのみ](nako_qrcode.dll)
  //-ダイアログ
  AddFunc('WEBダイアログ表示', 'URLの', 6590, nako_dlg_web, '簡易ブラウザのダイアログを表示しURLを表示する。', 'WEBだいあろぐひょうじ');
  AddFunc('画像ダイアログ表示', 'FILEの', 6591, nako_dlg_img, '画像を表示するダイアログを表示し、画像ファイルFILEを表示する。', 'WEBだいあろぐひょうじ');
  // </命令>
end;

//------------------------------------------------------------------------------
// プラグインの情報
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
const STR_INFO = 'ext01コードプラグイン by クジラ飛行机';
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
