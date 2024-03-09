library nako_zip;

uses
  Windows,
  SysUtils,
  Classes,
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  unit_zip in 'unit_zip.pas',
  StrUnit2 in 'strunit2.pas';

//------------------------------------------------------------------------------
// 以下関数
//------------------------------------------------------------------------------

function zip_open(h: DWORD): PHiValue; stdcall;
begin
  Result  := nil;
  ZipDB.LoadFromFile(getArgStr(h,0));
end;
function zip_close(h: DWORD): PHiValue; stdcall;
begin
  Result  := nil;
  ZipDBFree;
end;

function zip_code_find(h: DWORD): PHiValue; stdcall;
begin
  //ZIP番号検索 --> 住所で番号を検索
  Result  := hi_newStr(ZipDB.FindZipCode(getArgStr(h,0),getArgStr(h,1),getArgStr(h,2)));
end;
function zip_addr_find(h: DWORD): PHiValue; stdcall;
begin
  //ZIP住所検索 --> 番号で住所を検索
  Result  := hi_newStr(ZipDB.FindZipAddr(getArgStr(h,0)));
end;
function zip_conv(h: DWORD): PHiValue; stdcall;
begin
  Result  := nil;
  ZipDB.LoadFromCsvFile(getArgStr(h,0), nil);
  ZipDB.SaveToFile(getArgStr(h,1));
end;
function zip_open_csv(h: DWORD): PHiValue; stdcall;
begin
  Result  := nil;
  ZipDB.LoadFromCsvFile(getArgStr(h,0), nil);
end;

function zip_getAllKen(h: DWORD): PHiValue; stdcall;
begin
  Result  := hi_newStr(ZipDB.getAllKen);
end;
function zip_getAllShi(h: DWORD): PHiValue; stdcall;
begin
  Result  := hi_newStr(ZipDB.getAllShi(getArgStr(h,0)));
end;
function zip_getAllCho(h: DWORD): PHiValue; stdcall;
begin
  Result  := hi_newStr(ZipDB.getAllCho(getArgStr(h,0),getArgStr(h,1)));
end;

//------------------------------------------------------------------------------
// 以下絶対に必要な関数
//------------------------------------------------------------------------------
// 関数追加用
procedure ImportNakoFunction; stdcall;
begin
  // なでしこシステムに関数を追加
  AddFunc('ZIPデータ開く', 'Fで|Fの|Fから', 0, zip_open, '郵便番号データファイルを開く。', '');
  AddFunc('ZIPデータCSV開く', 'Fで|Fの|Fから', 0, zip_open_csv, '郵便局のページで配布しているCSVデータをデータファイルとして開く。(読み込みに長時間を要する)', '');
  AddFunc('ZIP閉じる', '', 0, zip_close, '', '');
  //
  AddFunc('ZIP住所検索', 'ZIPで|ZIPを|ZIPの', 0, zip_addr_find, '', 'ZIPじゅうしょけんさく');
  AddFunc('ZIP番号検索', 'KEN,SHI,CHOの', 0, zip_code_find, '', 'ZIPばんごうけんさく');
  AddFunc('ZIPデータ作成', 'CSVからFへ|CSVをFに', 0, zip_conv, '', '');
  //
  AddFunc('ZIP都道府県取得', '', 0, zip_getAllKen, '', '');
  AddFunc('ZIP市区取得', 'KENの', 0, zip_getAllShi, '', '');
  AddFunc('ZIP町村取得', 'KEN,SHIの', 0, zip_getAllCho, '', '');
end;

//------------------------------------------------------------------------------
// プラグインの情報
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
const STR_INFO = '郵便番号プラグイン by クジラ飛行机';
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
  Result := 1; // プラグイン自体のバージョン・・・適当でＯＫ
end;

//------------------------------------------------------------------------------
// なでしこプラグインバージョン
function PluginRequire: DWORD; stdcall;
begin
  Result := 1; // 必ず１を返すこと
end;


exports
  ImportNakoFunction,
  PluginInfo,
  PluginVersion,
  PluginRequire;


begin
end.
