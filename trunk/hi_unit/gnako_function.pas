unit gnako_function;

interface

uses
  Windows, SysUtils, dnako_import, dnako_import_types;

// なでしこに必要な関数を追加する
procedure RegistCallbackFunction(bokanHandle: Integer);

// 簡易描画ルーチン
procedure EZ_Rectangle(dc: HDC; x1, y1, x2, y2: Integer; penWidth, penColor, brushColor: Integer);
procedure EZ_Line(dc: HDC; x1,y1, x2, y2: Integer; penWidth, penColor: Integer);
procedure EZ_Circle(dc: HDC; x1,y1,x2,y2: Integer; penWidth, penColor: Integer; brushColor: Integer);
procedure EZ_TextOut(dc: HDC; x, y: Integer; text: AnsiString; face: AnsiString; height: Integer);
//
function EZ_SetWindowText(h: HWND; txt: AnsiString): Boolean;
procedure getPenBrush;
procedure getFont;
function nako_eval_str(src: AnsiString): PHiValue;

var
  pLPARAM       : PHiValue = nil;
  pWPARAM       : PHiValue = nil;
  pEventReturn  : PHiValue = nil;


implementation

uses
  gnako_window, unit_string;

type
  TRingBufferString = class
    private
      FCapacity: integer;
      FFront: integer;
      FBack: integer;
      FBuffer: array of AnsiChar;
      procedure SetText(const str:string);
      function GetText:string;
    public
      procedure Add(const str:string);
      property Capacity:integer read FCapacity;
      property Text:string read GetText write SetText;
      constructor Create(maxsize:integer);
  end;

const
  PRINT_LOG_SIZE = 65535;

var
  baseX: PHiValue;
  baseY: PHiValue;
  baseFont: PHiValue;
  baseFontSize: PHiValue;
  penWidth,
  penColor,
  penStyle,
  brushColor,
  brushStyle,
  printLog: PHiValue;
  printLogBuf: TRingBufferString;

constructor TRingBufferString.Create(maxsize:integer);
begin
  FCapacity := maxsize;
  SetLength(FBuffer,FCapacity+1);//+1しないと、指定された容量分使えないため
  FFront := 0;
  FBack := 0;
end;

function TRingBufferString.GetText:string;
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

procedure TRingBufferString.SetText(const str:string);
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

procedure TRingBufferString.Add(const str:string);
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
      MessageBoxA(0, PAnsiChar(s), 'なでしこ実行エラー', MB_OK or MB_ICONWARNING);
    end else
    begin
      //
      MessageBox(0, 'エラーメッセージはありません。', 'なでしこ実行エラー', MB_OK or MB_ICONWARNING);
    end;
    //nako_continue;
  end;

end;


function RGB2Color(c: Integer): Integer;
var
  r,g,b:Byte;
begin
  // RR GG BB
  // BB GG RR
  r := (c shr 16) and $FF;
  g := (c shr 8 ) and $FF;
  b := (c       ) and $FF;
  Result := RGB(r, g, b);
end;

procedure EZ_Line(dc: HDC; x1,y1, x2, y2: Integer; penWidth, penColor: Integer);
var
  hp, hp_old: HPEN;
begin
  hp := CreatePen(PS_SOLID, penWidth, penColor);
  hp_old := SelectObject(dc, hp);
  MoveToEx(dc, x1, y1, nil);
  LineTo(dc, x2,y2);
  SelectObject(dc, hp_old);
  DeleteObject(hp);
end;

procedure EZ_Rectangle(dc: HDC; x1, y1, x2, y2: Integer; penWidth, penColor, brushColor: Integer);
var
  hp, hp_old: HPEN;
  hb, hb_old: HBRUSH;
begin
  // CREATE OBJECT
  hp := CreatePen(PS_SOLID, penWidth, penColor);
  hp_old := SelectObject(dc, hp);
  hb := CreateSolidBrush(brushColor);
  hb_old := SelectObject(dc, hb);
  // DRAW
  Rectangle(dc, x1,y1,x2,y2);
  // RESET
  SelectObject(dc, hp_old);
  SelectObject(dc, hb_old);
  // DELETE
  DeleteObject(hp);
  DeleteObject(hb);
end;

procedure EZ_Circle(dc: HDC; x1,y1,x2,y2: Integer; penWidth, penColor: Integer; brushColor: Integer);
var
  hp, hp_old: HPEN;
  hb, hb_old: HBRUSH;
begin
  // CREATE OBJECT
  hp := CreatePen(PS_SOLID, penWidth, penColor);
  hp_old := SelectObject(dc, hp);
  hb := CreateSolidBrush(brushColor);
  hb_old := SelectObject(dc, hb);
  // DRAW
  Ellipse(dc, x1,y1,x2,y2);
  // RESET
  SelectObject(dc, hp_old);
  SelectObject(dc, hb_old);
  // DELETE
  DeleteObject(hp);
  DeleteObject(hb);
end;

function EZ_CreateFont(face: AnsiString; height: Integer): HFONT;
begin
  Result := CreateFontA(
    height,     // フォントの高さ
    0,          // 文字幅
    0,          // 角度
    0,          // ベースラインとＸ軸との角度
    FW_REGULAR, // フォントの太さ
    0,          // イタリック体
    0,          // アンダーライン
    0,          // 打ち消し線
    SHIFTJIS_CHARSET,         // 文字セット
    OUT_DEFAULT_PRECIS,       // 出力精度
    CLIP_DEFAULT_PRECIS,      // クリッピング精度
    PROOF_QUALITY,            // 出力品質
    FIXED_PITCH or FF_MODERN, // ピッチとファミリー
    PAnsiChar(face)               // 書体名
  );
end;

procedure EZ_TextOut(dc: HDC; x, y: Integer; text: AnsiString; face: AnsiString; height: Integer);
var
  hf, hf_old: HFONT;
begin
  hf := EZ_CreateFont(face, height);
  hf_old := SelectObject(dc, hf);
  TextOutA(dc, x, y, PAnsiChar(text), Length(text));
  SelectObject(dc, hf_old);
  DeleteObject(hf);
end;

function EZ_SetWindowText(h: HWND; txt: AnsiString): Boolean;
var
  p: PAnsiChar;
begin
  GetMem(p, Length(txt)+1);
  try
    StrLCopy(p, PAnsiChar(txt), Length(txt));
    Result := SetWindowText(h, p);
  finally
    FreeMem(p);
  end;
end;

function var2int(p: PHiValue): Integer;
begin
  Result := nako_var2int(p);
end;

function cmd_print(h: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  y: Integer;
  str: AnsiString;
  r: TRect;
begin
  // (1) 引数の取得
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;

  // ログの記憶
  printLogBuf.Add(hi_str(p));
  printLogBuf.Add(#13#10);
  hi_setStr(printLog, printLogBuf.Text);

  y := nako_var2int(baseY);
  
  r := Bokan.GetRect;
  r.Left := var2int(baseX);
  r.Top  := y;

  // (2) 処理
  getFont;
  str := hi_str(p);
  y := y + DrawText(
    Bokan.Canvas.Handle,
    PAnsiChar(str),
    Length(str),
    r,
    DT_LEFT or DT_NOPREFIX or DT_WORDBREAK
  );

  nako_int2var(y, baseY);
  FlagRepaint := True;

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_regEvent(h: DWORD): PHiValue; stdcall;
var
  a, b, s: PHiValue;
  w: TWinEvent;
begin
  // (1) 引数の取得
  a := nako_getFuncArg(h, 0); // ウィンドウメッセージ
  b := nako_getFuncArg(h, 1); // ID
  s := nako_getFuncArg(h, 2); // イベント名

  // (2) 処理
  w := TWinEvent.Create;
  w.Msg        := nako_var2int(a);
  w.NotifyCode := -1;
  w.GuiID      := nako_var2int(b);
  w.EventName  := hi_str(s);
  eventList.Add(w);

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_regEventEx(h: DWORD): PHiValue; stdcall;
var
  msg, code, id, s: PHiValue;
  w: TWinEvent;
begin
  // (1) 引数の取得
  msg  := nako_getFuncArg(h, 0); // ウィンドウメッセージ
  code := nako_getFuncArg(h, 1); // 通知コード
  id   := nako_getFuncArg(h, 2); // ID
  s    := nako_getFuncArg(h, 3); // イベント名

  // (2) 処理
  w := TWinEvent.Create;
  w.Msg        := nako_var2int(msg );
  w.NotifyCode := nako_var2int(code);
  w.GuiID      := nako_var2int(id  );
  w.EventName  := hi_str(s);
  eventList.Add(w);

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_cls(h: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  c: Integer;
begin
  // (1) 引数の取得
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;

  c := nako_var2int(p);
  // RRGGBBに変換
  c := RGB2Color(c);

  // (2) 処理
  Bokan.ClearScreen(c);
  //
  FlagRepaint := True;

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_move(h: DWORD): PHiValue; stdcall;
var
  x, y: PHiValue;
begin
  // (1) 引数の取得
  x := nako_getFuncArg(h, 0);
  y := nako_getFuncArg(h, 1);

  // (2) 処理
  nako_varCopyData(x, baseX);
  nako_varCopyData(y, baseY);

  Bokan.Canvas.CMoveTo(nako_var2int(x), nako_var2int(y));

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

procedure getPenBrush;
begin
  Bokan.Canvas.CSelectPen(hi_str(penStyle), var2int(penWidth), RGB2Color(var2int(penColor)));
  Bokan.Canvas.CSelectBrush(hi_str(brushStyle), RGB2Color(var2int(brushColor)));
end;

procedure getFont;
begin
  Bokan.Canvas.CSelectFont(hi_str(baseFont), nako_var2int(baseFontSize));
end;

function cmd_line(h: DWORD): PHiValue; stdcall;
var
  x1, y1, x2, y2: PHiValue;
  i1, i2, i3, i4: Integer;
begin
  // (1) 引数の取得
  x1 := nako_getFuncArg(h, 0);
  y1 := nako_getFuncArg(h, 1);
  x2 := nako_getFuncArg(h, 2);
  y2 := nako_getFuncArg(h, 3);

  // (2) 処理
  if (x1=nil)or(y1=nil) then
  begin
    // 基本点からの描画
    i1 := nako_var2int(baseX);
    i2 := nako_var2int(baseY);
    i3 := nako_var2int(x2);
    i4 := nako_var2int(y2);
  end else
  begin
    // 基本点からの描画
    i1 := nako_var2int(x1);
    i2 := nako_var2int(y1);
    i3 := nako_var2int(x2);
    i4 := nako_var2int(y2);
  end;

  //EZ_Line(Bokan.Canvas.Handle, i1, i2, i3, i4, );
  getPenBrush;
  Bokan.Canvas.CMoveTo(i1, i2);
  Bokan.Canvas.CLineTo(i3, i4);

  // 再描画の指示
  FlagRepaint := True;

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_rectangle(h: DWORD): PHiValue; stdcall;
var
  x1, y1, x2, y2: PHiValue;
  i1, i2, i3, i4: Integer;
begin
  // (1) 引数の取得
  x1 := nako_getFuncArg(h, 0);
  y1 := nako_getFuncArg(h, 1);
  x2 := nako_getFuncArg(h, 2);
  y2 := nako_getFuncArg(h, 3);

  // (2) 処理
  i1 := nako_var2int(x1);
  i2 := nako_var2int(y1);
  i3 := nako_var2int(x2);
  i4 := nako_var2int(y2);

  getPenBrush;
  Rectangle(Bokan.Canvas.Handle, i1, i2, i3, i4);

  // 再描画の指示
  FlagRepaint := True;

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_circle(h: DWORD): PHiValue; stdcall;
var
  x1, y1, x2, y2: PHiValue;
  i1, i2, i3, i4: Integer;
begin
  // (1) 引数の取得
  x1 := nako_getFuncArg(h, 0);
  y1 := nako_getFuncArg(h, 1);
  x2 := nako_getFuncArg(h, 2);
  y2 := nako_getFuncArg(h, 3);

  // (2) 処理
  i1 := nako_var2int(x1);
  i2 := nako_var2int(y1);
  i3 := nako_var2int(x2);
  i4 := nako_var2int(y2);

  getPenBrush;
  Ellipse(Bokan.Canvas.Handle, i1, i2, i3, i4);

  // 再描画の指示
  FlagRepaint := True;

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_roundrect(h: DWORD): PHiValue; stdcall;
var
  x1, y1, x2, y2, m1, m2: PHiValue;
  i1, i2, i3, i4, i5, i6: Integer;
begin
  // (1) 引数の取得
  x1 := nako_getFuncArg(h, 0);
  y1 := nako_getFuncArg(h, 1);
  x2 := nako_getFuncArg(h, 2);
  y2 := nako_getFuncArg(h, 3);
  m1 := nako_getFuncArg(h, 4);
  m2 := nako_getFuncArg(h, 5);

  // (2) 処理
  i1 := nako_var2int(x1);
  i2 := nako_var2int(y1);
  i3 := nako_var2int(x2);
  i4 := nako_var2int(y2);
  i5 := nako_var2int(m1);
  i6 := nako_var2int(m2);

  getPenBrush;
  RoundRect(Bokan.Canvas.Handle, i1, i2, i3, i4, i5, i6);

  // 再描画の指示
  FlagRepaint := True;
  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_poly(h: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
  s: AnsiString;
  x, y, cnt: Integer;
  pts: Array [0..63] of TPoint;
begin
  // (1) 引数の取得
  ps := nako_getFuncArg(h, 0);

  // (2) 処理
  cnt := 0;
  s := hi_str(ps);
  while s <> '' do begin
    x := StrToIntDef(getToken_s(s, ','), 0);
    y := StrToIntDef(getToken_s(s, ','), 0);
    pts[cnt].X := x;
    pts[cnt].Y := y;
    Inc(cnt);
  end;

  getPenBrush;
  Polygon(Bokan.Canvas.Handle, pts, cnt);

  // 再描画の指示
  FlagRepaint := True;
  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_loadPic(h: DWORD): PHiValue; stdcall;
var
  s, x, y: PHiValue;
  xx, yy: Integer;
  ss: AnsiString;

  hBmp: HBITMAP;
  bitmap: tagBITMAP;
  hdcbmp, holdbmp: HDC;
begin
  // (1) 引数の取得
  x := nako_getFuncArg(h, 0);
  y := nako_getFuncArg(h, 1);
  s := nako_getFuncArg(h, 2);

  // (2) 省略時の補完
  if (x=nil)or(y=nil) then
  begin
    x := baseX;
    y := baseY;
  end;

  xx := var2int(x);
  yy := var2int(y);
  ss := hi_str(s); // ファイル名

  //todo: 途中画像ロード
  // (3) 処理
{
HDC hdc;
HBITMAP hbmp = (HBITMAP)LoadImage( NULL, ”test,bmp”, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE );
BITMAP bitmap;
GetObject( hbmp, sizeof(bitmap), &bitmap );
HDChdcbmp = CreateCompatibleDC( hdc );
HBITMAP holdbmp = (HBITMAP)SelectObject( hdcbmp, hbmp );
BitBlt( hdc, 0, 0, bitmap.bmWidth, bitmap.bmHeight, hdcbmp, 0, 0, SRCCOPY );
SelectObject( hdcbmp, holdbmp );
}
  hBmp := LoadImageA(0, PAnsiChar(ss), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE);
  GetObject(hBmp, sizeof(bitmap), @bitmap);
  hdcbmp := CreateCompatibleDC(Bokan.Canvas.Handle);
  holdbmp := SelectObject(hdcbmp, hbmp);
  BitBlt(Bokan.Canvas.Handle, xx, yy, bitmap.bmWidth, bitmap.bmHeight, hdcbmp, 0, 0, SRCCOPY);
  SelectObject(hdcbmp, holdbmp);
  // 解放
  DeleteDC(hdcbmp);
  DeleteObject(hBmp);

  // 再描画の指示
  FlagRepaint := True;
  // (4) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_stop(h: DWORD): PHiValue; stdcall;
begin
  // (1) 引数の取得
  // (2) 処理
  nako_stop;
  InvalidateRect(Bokan.Canvas.Handle, nil, True);

  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_closeWindow(h: DWORD): PHiValue; stdcall;
begin
  // (1) 引数の取得
  // (2) 処理
  nako_stop;
  DestroyWindow(Bokan.WindowHandle);
  // (3) 結果の代入
  Result := nil; // 何も返さない場合は nil
end;

function cmd_getDC(h: DWORD): PHiValue; stdcall;
begin
  // (1) 引数の取得
  // (2) 処理
  // (3) 結果の代入
  Result := hi_newInt(Integer(bokan.Canvas.Handle)); // 何も返さない場合は nil
end;



// なでしこに必要な関数を追加する
procedure RegistCallbackFunction(bokanHandle: Integer);

  procedure _init_font;
  begin
    baseX         := nako_getVariable('基本X');
    baseY         := nako_getVariable('基本Y');
    baseFont      := nako_getVariable('文字書体');
    baseFontSize  := nako_getVariable('文字サイズ');
    penColor      := nako_getVariable('線色');
    brushColor    := nako_getVariable('塗り色');
    penWidth      := nako_getVariable('線太');
    penStyle      := nako_getVariable('線スタイル');
    brushStyle    := nako_getVariable('塗りスタイル');
    pLPARAM       := nako_getVariable('LPARAM');
    pWPARAM       := nako_getVariable('WPARAM');
    printLog      := nako_getVariable('表示ログ');
    pEventReturn  := nako_getVariable('イベント戻り値');
  end;

  var ctag: array [1000..1300] of Byte;

  procedure _initTag;
  var i: Integer;
  begin
    for i := low(ctag) to high(ctag) do ctag[i] := 0;
  end;

  procedure _checkTag(tag: Integer; name: AnsiString);
  begin
    if ctag[tag] <> 0 then raise Exception.CreateFmt('[システム命令追加でタグの重複] tag=%d name=%s',[tag, name]);
    ctag[tag] := 1;
  end;

  procedure AddFunc(name, argStr: AnsiString; tag: Integer; func: THimaSysFunction;
    kaisetu, yomigana: AnsiString);
  begin
    _checkTag(tag, name);
    nako_addFunction(PAnsiChar(name), PAnsiChar(argStr), func, tag);
  end;

  procedure AddStrVar(name, value: AnsiString; tag: Integer; kaisetu,
    yomigana: AnsiString);
  begin
    _checkTag(tag, name);
    nako_addStrVar(PAnsiChar(name), PAnsiChar(value), tag);
  end;

  procedure AddIntVar(name: AnsiString; value, tag: Integer; kaisetu,
    yomigana: AnsiString);
  begin
    _checkTag(tag, name);
    nako_addIntVar(PAnsiChar(name), value, tag);
  end;

begin
  _initTag;

  //todo 0: システム命令追加
  //<グラフィック命令>
  //+簡易GUI用命令(gnako.exe)
  //-描画
  AddIntVar('基本X', 10, 1000, '描画用基本座標のX','きほんX');
  AddIntVar('基本Y', 10, 1001, '描画用基本座標のY','きほんY');
  AddStrVar('文字書体', 'ＭＳ　ゴシック', 1002,'描画用基本フォント','もじしょたい');
  AddIntVar('文字サイズ', 12, 1003, '描画用基本フォントサイズ','もじさいず');
  AddIntVar('線太さ',    3, 1004, '図形の縁の線の太さ','せんふとさ');
  AddIntVar('線色',      0, 1005, '図形の縁の線の色','せんいろ');
  AddIntVar('塗り色',    0, 1006, '図形の塗り色','ぬりいろ');
  AddStrVar('線スタイル',   '実線', 1007, '図形の縁の線のスタイル。文字列で指定。「実線|点線|破線」','せんすたいる');
  AddStrVar('塗りスタイル', '透明', 1008, '図形の塗りスタイル。文字列で指定。「べた|透明|格子」','ぬりすたいる');

  AddFunc('表示', '{=?}Sを|Sと', 1100, @cmd_print, '画面に文字列Sを表示する', 'ひょうじ');
  AddFunc('画面クリア', '{整数=$FFFFFF}RGBで', 1101, @cmd_cls, '画面をカラーコード($RRGGBB)でクリアする。引数を省略すると白色で初期化する。','がめんくりあ');
  AddFunc('移動', 'X,Yへ', 1102,@cmd_move,'描画の基本座標をX,Yに変更する','いどう');
  AddFunc('MOVE', 'X,Y', 1103,@cmd_move,'描画の基本座標をX,Yに変更する','MOVE');
  AddFunc('線', '{=?}X1,{=?}Y1,X2,Y2|X1,Y1からX2,Y2へ', 1104,@cmd_line,'画面に線を引く。引数のX1,Y1を省略すると基本X,基本Yの座標から線を引く。','せん');
  AddFunc('LINE', '{=?}X1,{=?}Y1,X2,Y2', 1105,@cmd_line,'画面に線を引く。引数のX1,Y1を省略すると基本X,基本Yの座標から線を引く。','LINE');
  AddFunc('四角',  'X1,Y1,X2,Y2', 1106,@cmd_rectangle,'画面に長方形を描く。','しかく');
  AddFunc('BOX',   'X1,Y1,X2,Y2', 1107,@cmd_rectangle,'画面に長方形を描く。','BOX');
  AddFunc('円',    'X1,Y1,X2,Y2', 1108,@cmd_circle,'画面に円を描く。','えん');
  AddFunc('CIRCLE','X1,Y1,X2,Y2', 1109,@cmd_circle,'画面に円を描く。','CIRCLE');
  AddFunc('角丸四角','X1,Y1,X2,Y2,X3,Y3', 1110,@cmd_roundrect,'画面に角の丸い長方形を描く。X3,Y3には丸の度合いを指定。','かどまるしかく');
  AddFunc('ROUNDBOX','X1,Y1,X2,Y2,X3,Y3', 1111,@cmd_roundrect,'画面に角の丸い長方形を描く。X3,Y3には丸の度合いを指定。','ROUNDBOX');
  AddFunc('多角形','Sの|Sで', 1112,@cmd_poly,'画面に多角形を描く。Sには座標の一覧を文字列で与える。例)「10,10,10,20,20,20」','たかっけい');
  AddFunc('POLY','S', 1113,@cmd_poly,'画面に多角形を描く。Sには座標の一覧を文字列で与える。例)「10,10,10,20,20,20」','POLY');
  AddFunc('画像表示','{=?}X,{=?}YへSを', 1114,@cmd_loadPic,'ファイルSより画像を表示する。(X,Y)へ移動。した後に','がぞうひょうじ');
  AddStrVar('表示ログ', '', 1115, '表示した内容が記録される', 'ひょうじろぐ');
  AddFunc('母艦DC取得','', 1116,@cmd_getDC,'母艦への描画用のデバイスコンテキストを取得する','ぼかんDCしゅとく');

  //-イベント
  AddIntVar('インスタンスハンドル', HInstance, 1200, 'インスタンスハンドル', 'いんすたんすはんどる');
  AddIntVar('母艦ハンドル', bokanHandle, 1201, '母艦のウィンドウハンドル','ぼかんはんどる');
  AddFunc('イベント登録', 'MSGにIDの{文字列}Sを', 1202, @cmd_regEvent,'ウィンドウメッセージMSGをID(区別なしは-1)のイベント名Sで登録する。','いべんととうろく');
  AddFunc('イベント詳細登録', 'MSGのCODEにIDを{文字列}Sで', 1206, @cmd_regEventEx,'ウィンドウメッセージMSGの通知コードCODE(区別なしは-1)にID(区別なしは-1)をイベント名Sで登録する。','いべんとしょうさいとうろく');
  AddFunc('待機',       '', 1203, @cmd_stop,'プログラムの実行を止めイベントを待つ。','たいき');
  AddFunc('終わる', '', 1204, @cmd_closeWindow, '母艦を閉じてプログラムの実行を終了させる。','おわる');//メソッドの上書き
  AddFunc('おわり', '', 1205, @cmd_closeWindow, '母艦を閉じてプログラムの実行を終了させる。','おわり');//メソッドの上書き
  AddIntVar('LPARAM', 0, 1208, 'イベントが呼ばれたときに設定される','LPARAM');
  AddIntVar('WPARAM', 0, 1209, 'イベントが呼ばれたときに設定される','WPARAM');
  AddIntVar('イベント戻り値', 0, 1210, 'イベントの戻り値を設定したいときに指定する','いべんともどりち');
  AddFunc('終了', '', 1211, @cmd_closeWindow, '母艦を閉じてプログラムの実行を終了させる。','しゅうりょう');//メソッドの上書き

  //</グラフィック命令>


  _init_font;
end;


initialization
  printLogBuf := TRingBufferString.Create(PRINT_LOG_SIZE);

finalization
  printLogBuf.Free;
end.
