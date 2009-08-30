unit nkf;
(*-------------------------------------------------------------------------
NKF32.DLLを使用するためのUnit for Delphi 2.0

NKF32PAS.PAS Ver.1.0 (c)1996 A.Nakata 
(anakata@mix.or.jp, SGR03043@niftyserve.or.jp)

基本的に著作者財産権主張せず。
(ほとんどnkf32.dll付属のnkf32.hをコンバートするだけだから)
転載および他プログラムでの使用を歓迎。
これ単独での販売を除き商利用(Shareware含む)も可、ただし連絡希望。

各API個別の使用方法についてはnkf32.dllに付属のnkfdll.txtを参照されたし。

本Unitで独自に付加したインターフェースとして
・function NkfEnabled : boolean;
  nkf32.dllのロードに成功している場合true,さもなくばfalseを返す
・function NkfConvertStr(ins, option : string) : string;
  delphiのPascal形式文字列をnkf.dllで変換して返す
がある。

USE_EXCEPTION を定義してコンパイルした場合には、nkf32.dllのロード
に失敗した状態でAPIを呼び出そうとすると例外を発生するようになっている。
定義しない場合にはエラーは単にmessageboxで表示する。

コード記述例:
--------^
procedure TForm1.Button1Click(Sender : TObject);
var
  buff : string;
begin
  buff.setlength(memo1.gettextlen + 1);
  memo1.gettextbuf(buff, buff.length);
  memo1.settextbuf(NkfConvertStr(buff, '-s'));
end;
--------$

Sept-30-'96 Ver.1.0
  最初のバージョン
  元にしたヘッダファイルはnkf32.h version 1.00のものである。

独り言: 単純作業三度(^^;
-------------------------------------------------------------------------*)

//{$DEFINE USE_EXCEPTION}

interface
uses
  Windows;

var
  (* ドキュメント上の呼出規約はPASCALとなっているが、実際にはSTDCALL *)
  GetNkfVersion : procedure (version : pchar); stdcall;
  SetNkfOption  : function  (option : pchar) : integer; stdcall;
  NkfConvert    : procedure (outs, ins : pchar); stdcall;
  NkfConvertSafe: function  (outs:PChar;outbuflen:Dword;bytesret:pdword;const ins:Pchar;inbuflen:dword):bool; stdcall;
  GetNkfGuess   : function  (outStr: pchar; outLen:DWORD; retLen:PDWORD): BOOL; stdcall;

const nkfdll = 'nkf32.dll';
var   path_nkf32_dll:string = nkfdll;

procedure NkfInit;
function NkfEnabled : boolean;
function NkfConvertStr(ins, option : string; IsUTF16:Boolean) : string;
function nkf_easy_code(s: string): string;
function NkfGuessCode(instr: string): string;


implementation

uses sysutils, mini_file_utils;

//sjis|jis|euc|utf8|utf8n|unicode
function nkf_easy_code(s: string): string;
var us: string;
begin
  us := LowerCase(s);
  if us = 'sjis'      then s := 'CP932';
  if us = 'shiftjis'  then s := 'CP932';
  if us = 'shift-jis' then s := 'CP932';
  if us = 'euc'       then s := 'EUC-JP';
  if us = 'jis'       then s := 'ISO-2022-JP';
  if us = 'utf8'      then s := 'UTF-8';
  if us = 'utf8n'     then s := 'UTF-8N';
  if us = 'unicode'   then s := 'UTF-16';
  Result := s;
end;

function NkfGuessCode(instr: string): string;
var
  str: string;
  ret: string;
  retLen: DWORD;
begin
  str := instr;
  NkfConvertStr(str, '-g', False);
  // 結果を取得
  SetLength(ret, 256);
  GetNkfGuess(PChar(ret), 256, @retLen);
  ret := Trim(Copy(ret,1,retLen));
  if LowerCase(ret) = 'utf-8' then
  begin
    // BOMがあるかどうか調べる
    if Copy(str,1,3) <> #$EF+#$BB+#$BF then
    begin
      ret := 'UTF-8N';
    end;
  end;
  Result := ret;
end;


procedure ShowError(Func : string);
var
  s : string;
begin
  s := Func + ': NKF.DLL not loaded';
  s := s + '.';
{$IFDEF USE_EXCEPTION}
  raise Exception.Create(s);
{$ELSE}
  messagebox(0, pchar(s), 'PANIC!!', MB_ICONSTOP);
{$ENDIF}
end;


var
  hNkf    : THandle   = 0;
  p       : TFarProc  = nil;
  Enabled : Boolean   = False;

procedure FaultGetNkfVersion(version : pchar); stdcall;
begin
  ShowError('GetNkfVersion');
end;

function FaultSetNkfOption(option : pchar) : integer; stdcall;
begin
  result := 0;
  ShowError('SetNkfOption');
end;

procedure FaultNkfConvert(outs, ins : pchar); stdcall;
begin
  ShowError('NkfConvert');
end;

function  FaultNkfConvertSafe(outs:PChar;outbuflen:Dword;bytesret:pdword;const ins:Pchar;inbuflen:dword):bool; stdcall;
begin
  Result := false;
  bytesret^:=0;
  ShowError('NkfConvertSafe');
end;

function NkfEnabled : boolean;
begin
  NkfInit;
  result := Enabled;
end;

function NkfConvertStr(ins, option: string; IsUTF16:Boolean) : string;
var
  ret:dword;
begin
  NkfInit;
  if ins = '' then
  begin
    Result := '';
    Exit;
  end;
  SetNkfOption(pchar(option));
  Result := '';
  ret:=0   ;
  SetLength(Result, Length(ins) * 6 + 3); (* worst case in SJIS to JIS convert *)
  ZeroMemory(PChar(Result), Length(Result));
  NkfConvertSafe(PChar(result),Length(result),@ret,PChar(ins),Length(ins));

  Delete(result,ret+1,Length(result));
end;

procedure NkfInit;
begin

  Enabled := false;
  GetNkfVersion := FaultGetNkfVersion;
  SetNkfOption := FaultSetNkfOption;
  NkfConvert := FaultNkfConvert;
  NkfConvertSafe := FaultNkfConvertSafe;
  path_nkf32_dll := FindDLLFile('nkf32.dll');
  hNkf := Loadlibrary(PChar(path_nkf32_dll));
  if hNkf = 0 then
  begin
    hNkf := Loadlibrary(nkfdll);
  end;

  if hNkf >= 32 then begin
    p := GetProcAddress(hNkf, 'GetNkfVersion');
    if p <> nil then @GetNkfVersion := p;
    p := GetProcAddress(hNkf, 'SetNkfOption');
    if p <> nil then @SetNkfOption := p;
    p := GetProcAddress(hNkf, 'NkfConvert');
    if p <> nil then @NkfConvert := p;
    p := GetProcAddress(hNkf, 'NkfConvertSafe');
    if p <> nil then @NkfConvertSafe := p;
    p := GetProcAddress(hNkf, 'GetNkfGuessA');
    if p <> nil then @GetNkfGuess := p;
    Enabled := true;
  end;
end;

procedure NkfFinalize;
begin
  if hNkf >= 32 then
    FreeLibrary(hNkf);
end;

initialization
  // 動的にインポートするのを止めた
  // 命令を実行した時だけインポート

finalization
  NkfFinalize;

end.
