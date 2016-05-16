library nako_filemaker;

uses
  Windows,
  SysUtils,
  ComObj,
  ActiveX,
  Variants,
  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas';

//------------------------------------------------------------------------------
// 登録する関数
//------------------------------------------------------------------------------

var FMApp:Variant;
var FMDocs:Variant;
var FMFile:Variant;

const ID_FMPRO_APP = 'FMPRO.Application';

procedure init_filemaker;
begin
  if VarIsNull(FMApp) then
  begin
    try
      FMApp := GetActiveOleObject(ID_FMPRO_APP);
    except
      on E: EOleSysError do
      begin
        FMApp := CreateOleObject(ID_FMPRO_APP);
      end;
    end;
    FMDocs := FMApp.Documents;
    FMApp.Visible := True;
  end;
end;

function fmOpen(h: DWORD): PHiValue; stdcall;
var
  fname, userid, pass: string;
begin
  fname   := getArgStr(h, 0, True);
  userid  := getArgStr(h, 1);
  pass    := getArgStr(h, 2);
  init_filemaker;
  FMFile := FMDocs.Open(WideString(fname),WideString(userid),WideString(pass));
  Result := nil;
end;

function fmDoScript(h: DWORD): PHiValue; stdcall;
var
  scr: string;
  v: Variant;
begin
  scr := getArgStr(h, 0, True);
  v := FMFile.DoFMScript(scr);
  //
  Result := nil;
  if VarIsStr(v) then
  begin
    Result := hi_newStr(VarToStr(v));
  end;
  v := Unassigned;
end;

function fmQuit(h: DWORD): PHiValue; stdcall;
begin
  FMApp.Quit;
  FMFile := Unassigned;
  FMDocs := Unassigned;
  FMApp := Unassigned;
  Result := nil;
end;


function fmCloseDoc(h: DWORD): PHiValue; stdcall;
begin
  FMFile.Close;
  FMFile := Unassigned;
  Result := nil;
end;

//------------------------------------------------------------------------------
// プラグインとして必要な関数一覧
//------------------------------------------------------------------------------
// 設定するプラグインの情報
const S_PLUGIN_INFO = 'FileMaker ライブラリ by クジラ飛行机';

function PluginVersion: DWORD; stdcall;
begin
  Result := 2; //プラグイン自身のバージョン
end;

procedure ImportNakoFunction; stdcall;
begin
  // 関数を追加する例
  //<命令>
  //+FileMaker操作(nako_filemaker)
  //-FileMaker操作
  AddFunc('FILEMAKER開く','{=?}FILEをUSERとPASSWORDで',7350,fmOpen,'FileMakerのファイルを開く(そのときUSERとPASSWORDを指定する)','FILEMAKERひらく');
  AddFunc('FILEMAKERスクリプト実行','{=?}SCRIPTを',7351,fmDoScript,'FileMakerのスクリプトを実行する(「FILEMAKER開く」で開いておく必要があります)','FILEMAKERすくりぷとじっこう');
  AddFunc('FILEMAKER終了','',7352,fmQuit,'FileMakerを終了させる','FILEMAKERしゅうりょう');
  AddFunc('FILEMAKERファイル閉じる','',7353,fmCloseDoc,'FileMakerのドキュメントを閉じる','FILEMAKERふぁいるとじる');
  //</命令>
end;

//------------------------------------------------------------------------------
// 決まりきった情報
function PluginRequire: DWORD; stdcall; //なでしこプラグインバージョン
begin
  Result := 2;
end;
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
begin
  Result := Length(S_PLUGIN_INFO);
  if (str <> nil)and(len > 0) then
  begin
    StrLCopy(str, S_PLUGIN_INFO, len);
  end;
end;
procedure PluginInit(Handle: DWORD); stdcall;
begin
  OleInitialize(nil);
  dnako_import_initFunctions(Handle);
  FMApp := Null;
  FMDocs := Null;
  FMFile := Null;
end;

function PluginFin: DWORD; stdcall;
begin
  Result := 0;
  if not VarIsNull(FMApp) then
  begin
    FMFile := Unassigned;
    FMDocs := Unassigned;
    FMApp := Unassigned;
  end;
  OleUninitialize;
end;

//------------------------------------------------------------------------------
// 外部にエクスポートとする関数の一覧(Delphiで必要)
exports
  ImportNakoFunction,
  PluginInfo,
  PluginVersion,
  PluginRequire,
  PluginInit,
  PluginFin;

{
initialization
  OleInitialize(nil);
finalization
  OleUninitialize;
}

begin
end.

