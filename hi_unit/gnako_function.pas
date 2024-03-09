unit gnako_function;

interface

uses
  Windows, SysUtils, dnako_import, dnako_import_types;

// �Ȃł����ɕK�v�Ȋ֐���ǉ�����
procedure RegistCallbackFunction(bokanHandle: Integer);

// �ȈՕ`�惋�[�`��
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
  SetLength(FBuffer,FCapacity+1);//+1���Ȃ��ƁA�w�肳�ꂽ�e�ʕ��g���Ȃ�����
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
  begin // ���e���I�[���瓪�ɖ߂��Ă��Ă���
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
      MessageBoxA(0, PAnsiChar(s), '�Ȃł������s�G���[', MB_OK or MB_ICONWARNING);
    end else
    begin
      //
      MessageBox(0, '�G���[���b�Z�[�W�͂���܂���B', '�Ȃł������s�G���[', MB_OK or MB_ICONWARNING);
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
    height,     // �t�H���g�̍���
    0,          // ������
    0,          // �p�x
    0,          // �x�[�X���C���Ƃw���Ƃ̊p�x
    FW_REGULAR, // �t�H���g�̑���
    0,          // �C�^���b�N��
    0,          // �A���_�[���C��
    0,          // �ł�������
    SHIFTJIS_CHARSET,         // �����Z�b�g
    OUT_DEFAULT_PRECIS,       // �o�͐��x
    CLIP_DEFAULT_PRECIS,      // �N���b�s���O���x
    PROOF_QUALITY,            // �o�͕i��
    FIXED_PITCH or FF_MODERN, // �s�b�`�ƃt�@�~���[
    PAnsiChar(face)               // ���̖�
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
  // (1) �����̎擾
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;

  // ���O�̋L��
  printLogBuf.Add(hi_str(p));
  printLogBuf.Add(#13#10);
  hi_setStr(printLog, printLogBuf.Text);

  y := nako_var2int(baseY);
  
  r := Bokan.GetRect;
  r.Left := var2int(baseX);
  r.Top  := y;

  // (2) ����
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

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_regEvent(h: DWORD): PHiValue; stdcall;
var
  a, b, s: PHiValue;
  w: TWinEvent;
begin
  // (1) �����̎擾
  a := nako_getFuncArg(h, 0); // �E�B���h�E���b�Z�[�W
  b := nako_getFuncArg(h, 1); // ID
  s := nako_getFuncArg(h, 2); // �C�x���g��

  // (2) ����
  w := TWinEvent.Create;
  w.Msg        := nako_var2int(a);
  w.NotifyCode := -1;
  w.GuiID      := nako_var2int(b);
  w.EventName  := hi_str(s);
  eventList.Add(w);

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_regEventEx(h: DWORD): PHiValue; stdcall;
var
  msg, code, id, s: PHiValue;
  w: TWinEvent;
begin
  // (1) �����̎擾
  msg  := nako_getFuncArg(h, 0); // �E�B���h�E���b�Z�[�W
  code := nako_getFuncArg(h, 1); // �ʒm�R�[�h
  id   := nako_getFuncArg(h, 2); // ID
  s    := nako_getFuncArg(h, 3); // �C�x���g��

  // (2) ����
  w := TWinEvent.Create;
  w.Msg        := nako_var2int(msg );
  w.NotifyCode := nako_var2int(code);
  w.GuiID      := nako_var2int(id  );
  w.EventName  := hi_str(s);
  eventList.Add(w);

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_cls(h: DWORD): PHiValue; stdcall;
var
  p: PHiValue;
  c: Integer;
begin
  // (1) �����̎擾
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;

  c := nako_var2int(p);
  // RRGGBB�ɕϊ�
  c := RGB2Color(c);

  // (2) ����
  Bokan.ClearScreen(c);
  //
  FlagRepaint := True;

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_move(h: DWORD): PHiValue; stdcall;
var
  x, y: PHiValue;
begin
  // (1) �����̎擾
  x := nako_getFuncArg(h, 0);
  y := nako_getFuncArg(h, 1);

  // (2) ����
  nako_varCopyData(x, baseX);
  nako_varCopyData(y, baseY);

  Bokan.Canvas.CMoveTo(nako_var2int(x), nako_var2int(y));

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
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
  // (1) �����̎擾
  x1 := nako_getFuncArg(h, 0);
  y1 := nako_getFuncArg(h, 1);
  x2 := nako_getFuncArg(h, 2);
  y2 := nako_getFuncArg(h, 3);

  // (2) ����
  if (x1=nil)or(y1=nil) then
  begin
    // ��{�_����̕`��
    i1 := nako_var2int(baseX);
    i2 := nako_var2int(baseY);
    i3 := nako_var2int(x2);
    i4 := nako_var2int(y2);
  end else
  begin
    // ��{�_����̕`��
    i1 := nako_var2int(x1);
    i2 := nako_var2int(y1);
    i3 := nako_var2int(x2);
    i4 := nako_var2int(y2);
  end;

  //EZ_Line(Bokan.Canvas.Handle, i1, i2, i3, i4, );
  getPenBrush;
  Bokan.Canvas.CMoveTo(i1, i2);
  Bokan.Canvas.CLineTo(i3, i4);

  // �ĕ`��̎w��
  FlagRepaint := True;

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_rectangle(h: DWORD): PHiValue; stdcall;
var
  x1, y1, x2, y2: PHiValue;
  i1, i2, i3, i4: Integer;
begin
  // (1) �����̎擾
  x1 := nako_getFuncArg(h, 0);
  y1 := nako_getFuncArg(h, 1);
  x2 := nako_getFuncArg(h, 2);
  y2 := nako_getFuncArg(h, 3);

  // (2) ����
  i1 := nako_var2int(x1);
  i2 := nako_var2int(y1);
  i3 := nako_var2int(x2);
  i4 := nako_var2int(y2);

  getPenBrush;
  Rectangle(Bokan.Canvas.Handle, i1, i2, i3, i4);

  // �ĕ`��̎w��
  FlagRepaint := True;

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_circle(h: DWORD): PHiValue; stdcall;
var
  x1, y1, x2, y2: PHiValue;
  i1, i2, i3, i4: Integer;
begin
  // (1) �����̎擾
  x1 := nako_getFuncArg(h, 0);
  y1 := nako_getFuncArg(h, 1);
  x2 := nako_getFuncArg(h, 2);
  y2 := nako_getFuncArg(h, 3);

  // (2) ����
  i1 := nako_var2int(x1);
  i2 := nako_var2int(y1);
  i3 := nako_var2int(x2);
  i4 := nako_var2int(y2);

  getPenBrush;
  Ellipse(Bokan.Canvas.Handle, i1, i2, i3, i4);

  // �ĕ`��̎w��
  FlagRepaint := True;

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_roundrect(h: DWORD): PHiValue; stdcall;
var
  x1, y1, x2, y2, m1, m2: PHiValue;
  i1, i2, i3, i4, i5, i6: Integer;
begin
  // (1) �����̎擾
  x1 := nako_getFuncArg(h, 0);
  y1 := nako_getFuncArg(h, 1);
  x2 := nako_getFuncArg(h, 2);
  y2 := nako_getFuncArg(h, 3);
  m1 := nako_getFuncArg(h, 4);
  m2 := nako_getFuncArg(h, 5);

  // (2) ����
  i1 := nako_var2int(x1);
  i2 := nako_var2int(y1);
  i3 := nako_var2int(x2);
  i4 := nako_var2int(y2);
  i5 := nako_var2int(m1);
  i6 := nako_var2int(m2);

  getPenBrush;
  RoundRect(Bokan.Canvas.Handle, i1, i2, i3, i4, i5, i6);

  // �ĕ`��̎w��
  FlagRepaint := True;
  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_poly(h: DWORD): PHiValue; stdcall;
var
  ps: PHiValue;
  s: AnsiString;
  x, y, cnt: Integer;
  pts: Array [0..63] of TPoint;
begin
  // (1) �����̎擾
  ps := nako_getFuncArg(h, 0);

  // (2) ����
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

  // �ĕ`��̎w��
  FlagRepaint := True;
  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
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
  // (1) �����̎擾
  x := nako_getFuncArg(h, 0);
  y := nako_getFuncArg(h, 1);
  s := nako_getFuncArg(h, 2);

  // (2) �ȗ����̕⊮
  if (x=nil)or(y=nil) then
  begin
    x := baseX;
    y := baseY;
  end;

  xx := var2int(x);
  yy := var2int(y);
  ss := hi_str(s); // �t�@�C����

  //todo: �r���摜���[�h
  // (3) ����
{
HDC hdc;
HBITMAP hbmp = (HBITMAP)LoadImage( NULL, �htest,bmp�h, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE );
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
  // ���
  DeleteDC(hdcbmp);
  DeleteObject(hBmp);

  // �ĕ`��̎w��
  FlagRepaint := True;
  // (4) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_stop(h: DWORD): PHiValue; stdcall;
begin
  // (1) �����̎擾
  // (2) ����
  nako_stop;
  InvalidateRect(Bokan.Canvas.Handle, nil, True);

  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_closeWindow(h: DWORD): PHiValue; stdcall;
begin
  // (1) �����̎擾
  // (2) ����
  nako_stop;
  DestroyWindow(Bokan.WindowHandle);
  // (3) ���ʂ̑��
  Result := nil; // �����Ԃ��Ȃ��ꍇ�� nil
end;

function cmd_getDC(h: DWORD): PHiValue; stdcall;
begin
  // (1) �����̎擾
  // (2) ����
  // (3) ���ʂ̑��
  Result := hi_newInt(Integer(bokan.Canvas.Handle)); // �����Ԃ��Ȃ��ꍇ�� nil
end;



// �Ȃł����ɕK�v�Ȋ֐���ǉ�����
procedure RegistCallbackFunction(bokanHandle: Integer);

  procedure _init_font;
  begin
    baseX         := nako_getVariable('��{X');
    baseY         := nako_getVariable('��{Y');
    baseFont      := nako_getVariable('��������');
    baseFontSize  := nako_getVariable('�����T�C�Y');
    penColor      := nako_getVariable('���F');
    brushColor    := nako_getVariable('�h��F');
    penWidth      := nako_getVariable('����');
    penStyle      := nako_getVariable('���X�^�C��');
    brushStyle    := nako_getVariable('�h��X�^�C��');
    pLPARAM       := nako_getVariable('LPARAM');
    pWPARAM       := nako_getVariable('WPARAM');
    printLog      := nako_getVariable('�\�����O');
    pEventReturn  := nako_getVariable('�C�x���g�߂�l');
  end;

  var ctag: array [1000..1300] of Byte;

  procedure _initTag;
  var i: Integer;
  begin
    for i := low(ctag) to high(ctag) do ctag[i] := 0;
  end;

  procedure _checkTag(tag: Integer; name: AnsiString);
  begin
    if ctag[tag] <> 0 then raise Exception.CreateFmt('[�V�X�e�����ߒǉ��Ń^�O�̏d��] tag=%d name=%s',[tag, name]);
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

  //todo 0: �V�X�e�����ߒǉ�
  //<�O���t�B�b�N����>
  //+�Ȉ�GUI�p����(gnako.exe)
  //-�`��
  AddIntVar('��{X', 10, 1000, '�`��p��{���W��X','���ق�X');
  AddIntVar('��{Y', 10, 1001, '�`��p��{���W��Y','���ق�Y');
  AddStrVar('��������', '�l�r�@�S�V�b�N', 1002,'�`��p��{�t�H���g','�������傽��');
  AddIntVar('�����T�C�Y', 12, 1003, '�`��p��{�t�H���g�T�C�Y','����������');
  AddIntVar('������',    3, 1004, '�}�`�̉��̐��̑���','����ӂƂ�');
  AddIntVar('���F',      0, 1005, '�}�`�̉��̐��̐F','���񂢂�');
  AddIntVar('�h��F',    0, 1006, '�}�`�̓h��F','�ʂ肢��');
  AddStrVar('���X�^�C��',   '����', 1007, '�}�`�̉��̐��̃X�^�C���B������Ŏw��B�u����|�_��|�j���v','���񂷂�����');
  AddStrVar('�h��X�^�C��', '����', 1008, '�}�`�̓h��X�^�C���B������Ŏw��B�u�ׂ�|����|�i�q�v','�ʂ肷������');

  AddFunc('�\��', '{=?}S��|S��', 1100, @cmd_print, '��ʂɕ�����S��\������', '�Ђ傤��');
  AddFunc('��ʃN���A', '{����=$FFFFFF}RGB��', 1101, @cmd_cls, '��ʂ��J���[�R�[�h($RRGGBB)�ŃN���A����B�������ȗ�����Ɣ��F�ŏ���������B','���߂񂭂肠');
  AddFunc('�ړ�', 'X,Y��', 1102,@cmd_move,'�`��̊�{���W��X,Y�ɕύX����','���ǂ�');
  AddFunc('MOVE', 'X,Y', 1103,@cmd_move,'�`��̊�{���W��X,Y�ɕύX����','MOVE');
  AddFunc('��', '{=?}X1,{=?}Y1,X2,Y2|X1,Y1����X2,Y2��', 1104,@cmd_line,'��ʂɐ��������B������X1,Y1���ȗ�����Ɗ�{X,��{Y�̍��W������������B','����');
  AddFunc('LINE', '{=?}X1,{=?}Y1,X2,Y2', 1105,@cmd_line,'��ʂɐ��������B������X1,Y1���ȗ�����Ɗ�{X,��{Y�̍��W������������B','LINE');
  AddFunc('�l�p',  'X1,Y1,X2,Y2', 1106,@cmd_rectangle,'��ʂɒ����`��`���B','������');
  AddFunc('BOX',   'X1,Y1,X2,Y2', 1107,@cmd_rectangle,'��ʂɒ����`��`���B','BOX');
  AddFunc('�~',    'X1,Y1,X2,Y2', 1108,@cmd_circle,'��ʂɉ~��`���B','����');
  AddFunc('CIRCLE','X1,Y1,X2,Y2', 1109,@cmd_circle,'��ʂɉ~��`���B','CIRCLE');
  AddFunc('�p�ێl�p','X1,Y1,X2,Y2,X3,Y3', 1110,@cmd_roundrect,'��ʂɊp�̊ۂ������`��`���BX3,Y3�ɂ͊ۂ̓x�������w��B','���ǂ܂邵����');
  AddFunc('ROUNDBOX','X1,Y1,X2,Y2,X3,Y3', 1111,@cmd_roundrect,'��ʂɊp�̊ۂ������`��`���BX3,Y3�ɂ͊ۂ̓x�������w��B','ROUNDBOX');
  AddFunc('���p�`','S��|S��', 1112,@cmd_poly,'��ʂɑ��p�`��`���BS�ɂ͍��W�̈ꗗ�𕶎���ŗ^����B��)�u10,10,10,20,20,20�v','����������');
  AddFunc('POLY','S', 1113,@cmd_poly,'��ʂɑ��p�`��`���BS�ɂ͍��W�̈ꗗ�𕶎���ŗ^����B��)�u10,10,10,20,20,20�v','POLY');
  AddFunc('�摜�\��','{=?}X,{=?}Y��S��', 1114,@cmd_loadPic,'�t�@�C��S���摜��\������B(X,Y)�ֈړ��B�������','�������Ђ傤��');
  AddStrVar('�\�����O', '', 1115, '�\���������e���L�^�����', '�Ђ傤���낮');
  AddFunc('���DC�擾','', 1116,@cmd_getDC,'��͂ւ̕`��p�̃f�o�C�X�R���e�L�X�g���擾����','�ڂ���DC����Ƃ�');

  //-�C�x���g
  AddIntVar('�C���X�^���X�n���h��', HInstance, 1200, '�C���X�^���X�n���h��', '���񂷂��񂷂͂�ǂ�');
  AddIntVar('��̓n���h��', bokanHandle, 1201, '��͂̃E�B���h�E�n���h��','�ڂ���͂�ǂ�');
  AddFunc('�C�x���g�o�^', 'MSG��ID��{������}S��', 1202, @cmd_regEvent,'�E�B���h�E���b�Z�[�WMSG��ID(��ʂȂ���-1)�̃C�x���g��S�œo�^����B','���ׂ�ƂƂ��낭');
  AddFunc('�C�x���g�ڍדo�^', 'MSG��CODE��ID��{������}S��', 1206, @cmd_regEventEx,'�E�B���h�E���b�Z�[�WMSG�̒ʒm�R�[�hCODE(��ʂȂ���-1)��ID(��ʂȂ���-1)���C�x���g��S�œo�^����B','���ׂ�Ƃ��傤�����Ƃ��낭');
  AddFunc('�ҋ@',       '', 1203, @cmd_stop,'�v���O�����̎��s���~�߃C�x���g��҂B','������');
  AddFunc('�I���', '', 1204, @cmd_closeWindow, '��͂���ăv���O�����̎��s���I��������B','�����');//���\�b�h�̏㏑��
  AddFunc('�����', '', 1205, @cmd_closeWindow, '��͂���ăv���O�����̎��s���I��������B','�����');//���\�b�h�̏㏑��
  AddIntVar('LPARAM', 0, 1208, '�C�x���g���Ă΂ꂽ�Ƃ��ɐݒ肳���','LPARAM');
  AddIntVar('WPARAM', 0, 1209, '�C�x���g���Ă΂ꂽ�Ƃ��ɐݒ肳���','WPARAM');
  AddIntVar('�C�x���g�߂�l', 0, 1210, '�C�x���g�̖߂�l��ݒ肵�����Ƃ��Ɏw�肷��','���ׂ�Ƃ��ǂ肿');
  AddFunc('�I��', '', 1211, @cmd_closeWindow, '��͂���ăv���O�����̎��s���I��������B','���イ��傤');//���\�b�h�̏㏑��

  //</�O���t�B�b�N����>


  _init_font;
end;


initialization
  printLogBuf := TRingBufferString.Create(PRINT_LOG_SIZE);

finalization
  printLogBuf.Free;
end.
