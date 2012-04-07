unit hima_error;

interface
//{$DEFINE ERROR_LOG}


uses
  Windows, SysUtils, Classes, hima_types, mmsystem;

type
  // デバッグ.ソースコード情報 32 bit
  TDebugInfo = packed record
    Flag    : Byte; // 未使用
    FileNo  : Byte; // 0..255
    LineNo  : WORD; // 0..65535
  end;

  EHimaSyntax = class(Exception)
  public
    constructor Create(FileNo, LineNo: Integer; Msg: AnsiString; Args: array of const); overload;
    constructor Create(DInfo: TDebugInfo; Msg: AnsiString; Args: array of const); overload;
  end;
  EHimaRuntime = class(EHimaSyntax)
  end;

const
  // 引数なしのメッセージ
  ERR_NOPAIR_STRING   = '文字列「」が対応していません。';
  ERR_NOPAIR_STRING2  = '文字列『』が対応していません。';
  ERR_NOPAIR_STRING3  = '文字列 "..." が対応していません。';
  ERR_NOPAIR_STRING4  = '文字列 `...` が対応していません。';
  ERR_NOPAIR_COMMENT  = 'コメント /* ... */ が対応していません。';
  ERR_NOPAIR_KAKU     = '配列要素 [...] が対応していません。';
  ERR_NOPAIR_KAKKO    = 'カッコ (...) が対応していません。';
  ERR_NOPAIR_NAMI     = '波カッコ｛...｝が対応していません。';
  ERR_INVALID_SIKI    = '計算式の項が正しく読み取れません。';
  ERR_SYNTAX          = '文法のエラー。';
  ERR_STACK_OVERFLOW  = '再帰スタックが許容限度を超えました。';
  ERR_SECURITY        = 'セキュリティエラー。';
  // 引数つきのメッセージ
  ERR_S_SOURCE_DUST   = 'プログラム中に未定義の文字『%s』があります。';
  ERR_S_UNDEFINED     = '未定義の単語『%s』があります。';
  ERR_S_UNDEF_OPTION  = '『%s』は未定義の実行オプションです。';
  ERR_S_UNDEF_MARK    = '突然記号『%s』があります。単体では意味を持ちません。';
  ERR_S_UNDEF_GROUP   = '『%s』はグループとして定義されていません。';
  ERR_S_SYNTAX        = '文法エラー。この位置で『%s』は使えません。';
  ERR_S_STRICT_UNDEF  = '未定義の単語『%s』があります。厳密に宣言してください。';
  ERR_S_VARINIT_UNDEF = '単語『%s』が初期化されずに使われました。';
  ERR_S_VAR_ELEMENT   = '変数『%s』の要素が読み取れません。';
  ERR_S_DEF_FUNC      = '関数『%s』の宣言に文法の間違いがあります。';
  ERR_S_DEF_GROUP     = 'グループ『%s』の宣言に文法の間違いがあります。';
  ERR_S_DEF_VAR       = '変数『%s』の定義が間違っています。';
  ERR_S_DLL_FUNCTION_EXEC = 'DLL関数『%s』の実行中にエラーが起きました。';
  ERR_S_FUNCTION_EXEC = '関数『%s』の実行中にエラーが起きました。';
  ERR_S_CALL_FUNC     = '関数『%s』の呼び出しで文法の間違いがあります。';
  // 引数が２つのメッセージ
  ERR_SS_FUNC_ARG     = '関数『%s』の引数『%s』が不足しています。';
  ERR_SS_UNDEF_GROUP  = 'グループ『%s』にはメンバー『%s』が存在しません。語句を確認してください。';

  //----------------------------------------------------------------------------
  // 実行中のエラー(引数なし）
  ERR_RUN_CALC        = '計算中に計算式の誤りを見つけました。';
  // 実行中のエラー（実行あり）
  ERR_S_RUN_VALUE     = '変数『%s』の値が取得できません。';

var
  HimaErrorMessage: AnsiString;
  HimaFileList: TStringList; // ひまわりで使うファイルの管理用

function setSourceFileName(fname: string): Integer; // ソースファイルを登録する
function ErrFmt(FileNo, LineNo: Integer; Msg: AnsiString; Args: array of const): AnsiString;

procedure debugi(i:Integer);
procedure debugs(s: AnsiString);

var useErrorLog:Boolean = False; // <--- for DEBUG
var FileErrLog: TextFile;
procedure errLog(s: AnsiString);

implementation

uses hima_string, unit_string, hima_variable, hima_system;

var
  HimaLog: AnsiString = '';

procedure debugi(i:Integer);
var s: AnsiString;
begin
  s := IntToStrA(i);
  MessageBoxA(0, PAnsiChar(s), 'debug', MB_OK);
end;
procedure debugs(s: AnsiString);
begin
  MessageBoxA(0, PAnsiChar(s), 'debug', MB_OK);
end;

function setSourceFileName(fname: string): Integer;
begin
  Result := HimaFileList.IndexOf(fname);
  if Result < 0 then
  begin
    Result := HimaFileList.Add(fname);
  end;
end;

var last_err_result : AnsiString = '';
var last_err_file   : AnsiString = '';

function ErrFmt(FileNo, LineNo: Integer; Msg: AnsiString; Args: array of const): AnsiString;
var
  fname, s, file_info: AnsiString;
const
  err_h    = '[エラー] ';
  err_same = '前回と同様の理由でエラー。';
begin
  //=== ファイル名の取得
  if FileNo < 0 then
  begin
    fname := '評価式';
  end else
  begin
    // ファイル名を得る
    if FileNo < HimaFileList.Count then
    begin
      try
        fname := AnsiString(ExtractFileName(HimaFileList.Strings[FileNo]));
      except fname := ''; end;
    end else
    begin
      fname := '評価式';
    end;
  end;
  //=== エラーメッセージと引数を組み合わせる
  try
    s := FormatA(Msg, Args);
  except
    s := Msg;
  end;

  //=== ファイル番号とエラーメッセージを組み立てる
  file_info := fname + '(' + IntToStrA(LineNo) + '): ';

  // 重複する部分を削除

  if last_err_result <> '' then // 前回との完全重複を削除
  begin
    s := JReplaceA(s, last_err_result, '');
  end;

  if (Copy(s, 1, Length(err_h))=err_h) then // head
  begin
    getToken_s(s, ':'); // ヘッダをばっさり切り取る
  end;

  s := TrimA(s);
  if (s = '')and(HimaErrorMessage <> '') then
  begin
    s := err_same;
  end;

  //-------------------
  // 結果を返す
  Result := err_h + file_info + s;
  last_err_result := Result;

  // もしエラーメッセージ中で重複がなければ追加
  if (Pos(Result, HimaErrorMessage) = 0) then
  begin
    if PosA(err_same, Result) > 0 then // 同じだが前回と違う行なら出力
    begin
      if last_err_file = file_info then Exit;
    end;
    HimaErrorMessage := HimaErrorMessage + Result + #13#10;
    last_err_file := file_info;
  end;

end;

var
  LogTime: DWORD;
  fOpen: Boolean = False;

function TempDir: string;
var
 TempTmp: Array [0..MAX_PATH] of Char;
begin
 GetTempPath(MAX_PATH, TempTmp);
 Result:= string(TempTmp);
 if Copy(Result,Length(Result),1)<>'\' then Result := Result + '\';
end;

procedure errLog(s: AnsiString);
var
  logname: string;
begin
  if not useErrorLog then Exit;
  if not fOpen then
  begin
    logname := string(TempDir + 'nakolog_' + FormatDateTime('hhnnss',Now) + '.txt');
    AssignFile(FileErrLog, logname);
    Rewrite(FileErrLog);
    LogTime := timeGetTime;
    fOpen := True;
  end;
  Writeln(
    FileErrLog,
    Format('%0.5d',[(timeGetTime-LogTime)]) + ':' + string(s)
  );
end;

{ EHimaSyntax }

constructor EHimaSyntax.Create(FileNo, LineNo: Integer; Msg: AnsiString;
  Args: array of const);
begin
  inherited Create(
    string(ErrFmt(FileNo, LineNo, (Msg), Args))
  );
  hi_setStr(HiSystem.ErrMsg, HimaErrorMessage);
end;

constructor EHimaSyntax.Create(DInfo: TDebugInfo; Msg: AnsiString;
  Args: array of const);
begin
  inherited Create(string(ErrFmt(DInfo.FileNo, DInfo.LineNo, Msg, Args)));
  hi_setStr(HiSystem.ErrMsg, HimaErrorMessage);
end;

initialization
  HimaFileList := TStringList.Create;

finalization
  FreeAndNil(HimaFileList);
  if useErrorLog then CloseFile(FileErrLog);


end.
