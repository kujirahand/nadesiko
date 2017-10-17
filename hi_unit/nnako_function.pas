unit nnako_function;

interface

uses
  Windows,Dialogs
  ,dnako_import
  ,dnako_import_types;

procedure none_addCommand;

function nako_eval_str(src: AnsiString): PHiValue;
procedure nako_eval_str2(src: AnsiString);

implementation

uses
  dll_plugin_helper
  ,SysUtils;

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

function nako_eval_str(src: AnsiString): PHiValue;
var
  len: Integer;
  s: AnsiString;
begin
  Result := nil;
  if nako_evalEx(PAnsiChar(src), Result) = False then
  begin
    len := nako_getError(nil, 0);
    if len > 0 then
    begin
      SetLength(s, len + 1);
      nako_getError(PAnsiChar(s), len);
      //writeln(0, PAnsiChar(s), 'なでしこ実行エラー', MB_OK or MB_ICONWARNING);
      ShowMessage(s);
    end else
    begin
      //(0, 'エラーメッセージはありません。', 'なでしこ実行エラー', MB_OK or MB_ICONWARNING);
    end;
    //nako_continue;
  end;
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

  // (2) 命令の処理
  // ログの追加
  printLogBuf.Add(hi_str(s));
  printLogBuf.Add(#13#10);
  hi_setStr(printLog, printLogBuf.Text);

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
  // ログの追加
  printLogBuf.Add(s);
  printLogBuf.Add(#13#10);
  hi_setStr(printLog, printLogBuf.Text);

  // (3) 結果の設定
  Result := nil;
end;

procedure checkShortcut;
begin
  printLog  := nako_getVariable('表示ログ');
end;

procedure none_addCommand;
begin
  //todo: 命令追加
  //<命令>
  //+コンソール用(nnako.exe)
  //-コンソール
  AddFunc('表示','{文字列=?}Sを|Sと',3000, con_print,'画面に文字Ｓを表示する。','ひょうじ');
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
