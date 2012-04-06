unit cnako_function;

interface

uses
  Windows
  {$IFDEF CNAKOEX}
  ,hima_variable
  ,hima_system
  {$ELSE}
  ,dnako_import
  ,dnako_import_types
  {$ENDIF}
  ;

const
  CNAKO_MODE_EXE = 0;
  CNAKO_MODE_CON = 1;
  CNAKO_MODE_CGI = 2;

procedure console_addCommand;

function nako_eval_str(src: AnsiString): PHiValue;
procedure nako_eval_str2(src: AnsiString);

function getMode: Integer;
procedure setMode(mode: Integer);
procedure cout(s: AnsiString);

implementation

uses
  {$IFDEF CNAKOEX}
  SysUtils;
  {$ELSE}
  dll_plugin_helper
  ,SysUtils;
  {$ENDIF}

type
  TRingBufferString = class
    private
      FCapacity: integer;
      FFront: integer;
      FBack: integer;
      FBuffer: array of char;
      procedure SetText(const str: AnsiString);
      function GetText: AnsiString;
    public
      procedure Add(const str: AnsiString);
      property Capacity:integer read FCapacity;
      property Text: AnsiString read GetText write SetText;
      constructor Create(maxsize:integer);
  end;

const
  PRINT_LOG_SIZE = 65535;

var
  printLog: PHiValue;
  cnakoMode: PHiValue;
  printLogBuf: TRingBufferString;

constructor TRingBufferString.Create(maxsize:integer);
begin
  FCapacity := maxsize;
  SetLength(FBuffer,FCapacity+1);//+1しないと、指定された容量分使えないため
  FFront := 0;
  FBack := 0;
end;

function TRingBufferString.GetText: AnsiString;
begin
  if FFront = FBack then
    Result := ''
  else if FFront < FBack then
  begin
    SetLength(Result,FBack-FFront);
    Move(FBuffer[FFront],Result[1],FBack-FFront);
  end else
  begin // 内容が終端から頭に戻ってきている
    SetLength(Result,FCapacity-FFront+1+FBack);
    Move(FBuffer[FFront],Result[1],FCapacity-FFront+1);
    Move(FBuffer[0],Result[FCapacity-FFront+1+1],FBack);
  end;
end;

procedure TRingBufferString.SetText(const str: AnsiString);
begin
  FFront := 0;
  if Length(str) < FCapacity then
  begin
    Move(str[1],FBuffer[0],Length(str));
    FBack := Length(str) + 1;
  end
  else
  begin
    Move(str[Length(str)-FCapacity-1],FBuffer[0],FCapacity);
    FBack := FCapacity + 1;
  end;
end;

procedure TRingBufferString.Add(const str: AnsiString);
var
  len,front:Integer;
begin
  len := Length(str);
  if len > FCapacity then
  begin
    front := Length(str)-FCapacity+1;
    len := FCapacity;
  end
  else
    front := 1;

  if FFront <= FBack then // --F---B--
  begin
    if FCapacity - FBack + 1 >= len then // --F---B*-
    begin
      Move(str[front],FBuffer[Fback],len);
      Inc(FBack,len);
    end
    else // *-F---B**
    begin
      Move(str[front],FBuffer[Fback],FCapacity-FBack+1);
      Move(str[front+FCapacity-FBack+1],FBuffer[0],len-(FCapacity-FBack+1));
      FBack := len-(FCapacity-FBack+1);
      if FBack > FFront then FFront := (FBack + 1)mod(FCapacity+1);
    end;
  end else // --B---F--
  begin
    if FCapacity - FBack + 1 >= len then // --B**-F--
    begin
      Move(str[front],FBuffer[Fback],len);
      Inc(FBack,len);
      if FBack > FFront then FFront := (FBack + 1)mod(FCapacity+1);
    end
    else // *-B***F**
    begin
      Move(str[front],FBuffer[Fback],FCapacity-FBack+1);
      Move(str[front+FCapacity-FBack+1],FBuffer[0],len-(FCapacity-FBack+1));
      FBack := len-(FCapacity-FBack+1);
      FFront := (FBack + 1)mod(FCapacity+1);
    end;
  end;
end;

function getMode: Integer;
var s: AnsiString;
begin
  s := hi_str(cnakomode) + 'EXE';

  case s[2] of
    'X': Result := CNAKO_MODE_EXE;
    'O': Result := CNAKO_MODE_CON;
    'G': Result := CNAKO_MODE_CGI;
    else Result := CNAKO_MODE_EXE;
  end;
end;

procedure setMode(mode: Integer);
begin
  case mode of
  CNAKO_MODE_EXE:
    begin
      hi_setStr(cnakomode, 'EXE');
    end;
  CNAKO_MODE_CON:
    begin
      hi_setStr(cnakomode, 'CON');
    end;
  CNAKO_MODE_CGI:
    begin
      hi_setStr(cnakomode, 'CGI');
    end;
  end;
end;

procedure cout(s: AnsiString);
begin
  case getMode of
  CNAKO_MODE_EXE:
    begin
      Writeln(s);
    end;
  CNAKO_MODE_CON:
    begin
      Writeln(s);
    end;
  CNAKO_MODE_CGI:
    begin
      Writeln('Content-type: text/html'#13#10#13#10+s);
    end;
  end;
end;


function nako_eval_str(src: AnsiString): PHiValue;
{$IFNDEF CNAKOEX}
var
  len: Integer;
  s: AnsiString;
{$ENDIF}
begin
  {$IFNDEF CNAKOEX}
  Result := nil;
  if nako_evalEx(PAnsiChar(src), Result) = False then
  begin
    len := nako_getError(nil, 0);
    if len > 0 then
    begin
      SetLength(s, len + 1);
      nako_getError(PAnsiChar(s), len);
      //writeln(0, PAnsiChar(s), 'なでしこ実行エラー', MB_OK or MB_ICONWARNING);
      cout(s);
    end else
    begin
      //(0, 'エラーメッセージはありません。', 'なでしこ実行エラー', MB_OK or MB_ICONWARNING);
      cout('[エラー] エラーメッセージはありません。');
    end;
    //nako_continue;
  end;
  {$ELSE}
  try
    Result := HiSystem.Eval(src);
  except
    Result := nil;
  end;
  {$ENDIF}
end;

procedure nako_eval_str2(src: AnsiString);
var
  v: PHiValue;
begin
  v := nako_eval_str(src);
  nako_var_free(v);
end;

function con_print(arg: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(arg, 0); // 0 番目の引数を得る
  if s = nil then s := nako_getSore; // nil(省略されてる)ならば、それの値を得る

  // ログの追加
  printLogBuf.Add(hi_str(s));
  printLogBuf.Add(#13#10);
  hi_setStr(printLog, printLogBuf.Text);

  // (2) 命令の処理
  writeln(string(hi_str(s)));

  // (3) 結果の設定
  Result := nil;
end;

function con_out(arg: DWORD): PHiValue; stdcall;
var
  s: AnsiString;
begin
  // (1) 引数の取得
  s := getArgStr(arg, 0, True);

  // (2) 命令の処理
  write(s);
  // ログの追加
  printLogBuf.Add(s);
  printLogBuf.Add(#13#10);
  hi_setStr(printLog, printLogBuf.Text);

  // (3) 結果の設定
  Result := nil;
end;

function con_stop(arg: DWORD): PHiValue; stdcall;
begin
  readln;
  Result := nil;
end;

function con_input(arg: DWORD): PHiValue; stdcall;
var
  len: DWORD;
  s: AnsiString;
  h: THandle;
begin
  // (1) 引数の取得
  len := getArgInt(arg, 0);
  // (2) 命令の処理
  if len > 0 then
  begin
    SetLength(s, len);
    //ReadConsole(GetStdHandle(STD_INPUT_HANDLE), @s[1], len, len, nil);
    h := GetStdHandle(STD_INPUT_HANDLE);
    ReadFile(h, s[1], len, len, nil);
    {for i := 1 to len do
    begin
      System.read(c);
      s[i] := c;
      //if ((i-1) mod 16) = 0 then write(#13#10);
      //write(IntToHex(ord(c),2),'-');
    end;}
  end;
  // (3) 結果の設定
  Result := nako_var_new(nil);
  hi_setStr(Result, s);
end;

function con_readln(arg: DWORD): PHiValue; stdcall;
var
  s: PHiValue;
  a: AnsiString;
begin
  // (1) 引数の取得
  s := nako_getFuncArg(arg, 0); // 0 番目の引数を得る
  if s = nil then s := nako_getSore;

  // (2) 命令の処理
  writeln(hi_str(s));
  readln(a);

  // (3) 結果の設定
  Result := nako_var_new(nil);
  hi_setStr(Result, a);
end;


procedure checkShortcut;
begin
  printLog  := nako_getVariable('表示ログ');
  cnakoMode := nako_getVariable('CNAKOモード');
end;

procedure console_addCommand;
begin
  //todo: 命令追加
  //<命令>
  //+コンソール用(cnako.exe)
  //-コンソール
  AddFunc('表示','{文字列=?}Sを|Sと',3000, con_print,'画面に文字Ｓを表示する。','ひょうじ');
  AddFunc('待機','',3001, con_stop,'エンターキーが押されるまで実行を待機する。','たいき');
  AddFunc('入力','{文字列=?}Sと|Sを|Sの',3002, con_readln,'画面に質問Ｓを表示しコンソールから入力を１行得る。','にゅうりょく');
  AddFunc('標準入力取得','CNTの',3003, con_input,'CNTバイトの標準入力を取得する。','ひょうじゅんにゅうりょくしゅとく');
  AddStrVar('CNAKOモード','CON',3004, 'コンソールの実行モードを変更する(EXE/CON/CGI) EXEだとエラー表示後に待機する。','CNAKOもーど');
  AddStrVar('表示ログ','',3005, '『表示』命令で表示した内容を保持する','ひょうじろぐ');
  AddFunc('継続表示','{文字列=?}Sを|Sと',3006, con_out,'画面に文字Ｓを表示する。改行なしで出力する。','けいぞくひょうじ');
  //</命令>

  //名前思案中

  checkShortcut;
end;

initialization
  printLogBuf := TRingBufferString.Create(PRINT_LOG_SIZE);

finalization
  printLogBuf.Free;
end.
