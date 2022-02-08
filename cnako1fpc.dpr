program cnako1fpc;

{$IFDEF Win32}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  // MemCheck in 'MemCheck.pas',
  {$IFDEF Win32}
  Windows,
  BRegExp in 'hi_unit\BRegExp.pas',
  nako_dialog_function2 in 'hi_unit\nako_dialog_function2.pas',
  {$ELSE}
  unit_fpc in 'hi_unit\unit_fpc.pas',
  {$ENDIF}
  SysUtils,
  hima_system in 'hi_unit\hima_system.pas',
  hima_types in 'hi_unit\hima_types.pas',
  unit_string in 'hi_unit\unit_string.pas',
  hima_parser in 'hi_unit\hima_parser.pas',
  hima_error in 'hi_unit\hima_error.pas',
  hima_string in 'hi_unit\hima_string.pas',
  hima_variable in 'hi_unit\hima_variable.pas',
  hima_token in 'hi_unit\hima_token.pas',
  unit_file in 'hi_unit\unit_file.pas',
  unit_windows_api in 'hi_unit\unit_windows_api.pas',
  hima_variable_ex in 'hi_unit\hima_variable_ex.pas',
  hima_function in 'hi_unit\hima_function.pas',
  unit_pack_files in 'hi_unit\unit_pack_files.pas',
  hima_stream in 'hi_unit\hima_stream.pas',
  mini_file_utils in 'hi_unit\mini_file_utils.pas',
  hima_variable_lib in 'hi_unit\hima_variable_lib.pas',
  mini_func in 'hi_unit\mini_func.pas',
  unit_date in 'hi_unit\unit_date.pas',
  unit_file_dnako in 'hi_unit\unit_file_dnako.pas',
  nako_dialog_const in 'hi_unit\nako_dialog_const.pas',
  common_function in 'hi_unit\common_function.pas',
  unit_text_file in 'hi_unit\unit_text_file.pas',
  mt19937 in 'hi_unit\mt19937.pas',
  unit_pack_files_pro in 'pro_unit\unit_pack_files_pro.pas',
  EasyMasks in 'hi_unit\EasyMasks.pas',
  wildcard in 'hi_unit\wildcard.pas',
  wildcard2 in 'hi_unit\wildcard2.pas';

function cmd_print(args: THiArray): PHiValue; stdcall;
var
  s: PHiValue;
  str: string;
begin
  s := args.Items[0];

  if s = nil then s := HiSystem.Sore;
  str := hi_str(s);
  //MessageBox(0, PChar(str), 'test', MB_OK);
  WriteLn(str);
  Result := nil;
end;

function cmd_test(args: THiArray): PHiValue; stdcall;
var
  a: PHiValue;
begin
  a := args.Items[0];
  Result := hi_newStr('test');
  if a <> nil then hi_setStr(a,'test');
end;

function sys_loadEveryLine(args: THiArray): PHiValue; stdcall;
var
  v, f: PHiValue;
  fname, s: string;
  h: TKTextFileStream;
begin
  // (1) 引数の取得
  v := args.Items[0]; // ハンドル
  f := args.Items[1]; // ファイル名

  v := hi_getLink(v);
  fname := hi_str(f);

  // (2) データの処理

  // (3) 戻り値を設定 // Create したハンドルは 『反復』構文の中で自動的に閉じる
  h := TKTextFileStream.Create(fname, fmOpenRead or fmShareDenyWrite);

  s := 'TKTextFileStream::' + IntToStr(Integer(h));

  Result := hi_newStr(s);

  // v に格納
  if v <> nil then
  begin
    hi_setStr(v, s);
  end;
end;

//------------------------------------------------------------------------------
begin
  // run
  HiSystem.AddFunction('表示','{=?}Sを|Sと|Sで', cmd_print, 880000);
  HiSystem.AddFunction('言う','{=?}Sを|Sと|Sで', cmd_print, 880001);
  HiSystem.AddFunction('毎行読む','{参照渡し 変数=?}AにFを', sys_loadEveryLine, 880002);
  HiSystem.AddSystemFileCommand;
  HiSystem.LoadPlugins;

  if ParamCount > 0 then
  begin
    HiSystem.LoadFromFile(ParamStr(1));
    HiSystem.Run2;
  end;

  // 破棄確認
  FreeAndNil(FHiSystem);
  //
  //writeln('ok, push enter!');
  //readln;
end.
