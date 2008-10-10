unit gnako_gdi;

interface

uses
  Windows;

type
  THGdiObject = class
  private
    FHandle: HGDIOBJ;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    property Handle: HGDIOBJ read FHandle;
  end;

  THCanvas = class
  private
    FHandle: HDC;
    FHandleAllocated : Boolean;
    FFont: HFONT;
    FPen: HPEN;
    FBrush: HBrush;
    function GetHandle: HDC;
    procedure SetHandle(const Value: HDC);
  public
    constructor Create;
    destructor Destroy; override;
    procedure ClearHandle; virtual;
    function CSelectObject(NewObj: HGDIOBJ): HGDIOBJ;
    procedure CBitBlt(DesDC: HDC; dx, dy, dw, dh: Integer);
    procedure CRectangle(x1,y1,x2,y2: Integer);
    procedure CPatBlt(x,y,w,h:Integer; Rop: DWORD);
    procedure CMoveTo(x, y: Integer);
    procedure CLineTo(x, y: Integer);
    procedure CSelectFont(face: string; size: Integer);
    procedure CSelectPen(Style: string; Width, Color: Integer);
    procedure CSelectBrush(Style: string; Color: Integer);
    property HandleAllocated: Boolean read FHandleAllocated;
    property Handle:HDC read GetHandle write SetHandle;
  end;

  THBitmap = class(THGdiObject)
  private
    FWidth, FHeight: Integer;
    FHCanvas: THCanvas;
    procedure SetHeight(const Value: Integer);
    procedure SetWidth(const Value: Integer);
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Resize(NewWidth, NewHeight: Integer);
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;
    property Canvas: THCanvas read FHCanvas;
  end;


implementation

{ THBitmap }

constructor THBitmap.Create;
begin
  inherited;
  FWidth  := 0;
  FHeight := 0;
  FHCanvas := THCanvas.Create;
end;

destructor THBitmap.Destroy;
begin
  FHCanvas.Free;
  DeleteObject(FHandle);
  inherited;
end;

procedure THBitmap.Resize(NewWidth, NewHeight: Integer);
var
  dc: HDC;
  memBM: HBITMAP;
  NewCanvas: THCanvas;
begin
  if (NewWidth = 0)or(NewHeight = 0) then Exit;

  if FHandle = 0 then
  begin
    // 初めての作成
    dc := GetDC(0);

    // ディスプレイに即した Bitmap を作成
    FHandle := CreateCompatibleBitmap(dc, NewWidth, NewHeight);
    FHCanvas.CSelectObject(FHandle);
    FHCanvas.CPatBlt(0,0,NewWidth,NewHeight, WHITENESS);

    // 解放
    ReleaseDC(0, dc);
  end else
  begin
    // 既存のキャンバスを破棄して作る
    dc := GetDC(0);

    // コピー元の作成
    NewCanvas := THCanvas.Create;
    NewCanvas.SetHandle(CreateCompatibleDC(dc));
    memBM := CreateCompatibleBitmap(dc, NewWidth, NewHeight);
    NewCanvas.CSelectObject(memBM);
    NewCanvas.CPatBlt(0,0,NewWidth,NewHeight, WHITENESS);

    // コピー
    FHCanvas.CBitBlt(NewCanvas.Handle, 0, 0, FWidth, FHeight);
    FHCanvas.Free;
    FHCanvas := NewCanvas;

    ReleaseDC(0, dc);
  end;
end;

procedure THBitmap.SetHeight(const Value: Integer);
begin
  FHeight := Value;
  Resize(FWidth, FHeight);
end;

procedure THBitmap.SetWidth(const Value: Integer);
begin
  FWidth := Value;
  Resize(FWidth, FHeight);
end;

{ THCanvas }

procedure THCanvas.CBitBlt(DesDC: HDC; dx, dy, dw, dh: Integer);
begin
  BitBlt(DesDC, dx, dy, dw, dh, Handle, 0, 0, SRCCOPY);
end;

procedure THCanvas.ClearHandle;
begin
  if FHandleAllocated then DeleteDC(FHandle);
end;

procedure THCanvas.CLineTo(x, y: Integer);
begin
  LineTo(Handle, x, y);
end;

procedure THCanvas.CMoveTo(x, y: Integer);
begin
  MoveToEx(Handle, x, y, nil);
end;

procedure THCanvas.CPatBlt(x, y, w, h: Integer; Rop: DWORD);
begin
  PatBlt(Handle, x, y, w, h, Rop);
end;

function EZ_CreateFont(face: string; height: Integer): HFONT;
begin
  Result := CreateFont(
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
    PChar(face)               // 書体名
  );
end;

constructor THCanvas.Create;
begin
  FHandle := 0;
  FHandleAllocated := False;
end;

procedure THCanvas.CRectangle(x1, y1, x2, y2: Integer);
begin
  Rectangle(Handle, x1, y1, x2, y2);
end;

procedure THCanvas.CSelectBrush(Style: string; Color: Integer);
var
  old, tmp: HBRUSH;
  tag: tagLOGBRUSH;
begin
  tmp    := FBrush;

  if Style = 'べた' then
  begin
    tag.lbStyle := BS_SOLID;
    tag.lbColor := Color;
  end else
  if Style = '透明' then
  begin
    tag.lbStyle := BS_NULL;
  end else
  if Style = '格子' then
  begin
    tag.lbStyle := BS_HATCHED;
    tag.lbColor := Color;
    tag.lbHatch := HS_CROSS;
  end;

  FBrush := CreateBrushIndirect(tag);
  old    := CSelectObject(FBrush);
  if old = tmp then DeleteObject(old);
end;

procedure THCanvas.CSelectFont(face: string; size: Integer);
var
  f,h: HFONT;
begin
  f := FFont;
  FFont  := EZ_CreateFont(face, size);
  h := CSelectObject(FFont);
  if h = f then DeleteObject(h); // 自分で作ったFONTなら削除
end;

function THCanvas.CSelectObject(NewObj: HGDIOBJ): HGDIOBJ;
begin
  Result := SelectObject(Handle, NewObj);
end;

procedure THCanvas.CSelectPen(Style: string; Width, Color: Integer);
var
  old, tmp: HPen;
begin
  tmp  := FPen;
  if Style = '実線' then
  begin
    FPen := CreatePen(PS_SOLID, Width, Color);
  end else
  if Style = '点線' then
  begin
    FPen := CreatePen(PS_DOT, Width, Color);
  end else
  if Style = '破線' then
  begin
    FPen := CreatePen(PS_DASH, Width, Color);
  end;
  old  := CSelectObject(FPen);
  if (old = tmp) then DeleteObject(old);
end;

destructor THCanvas.Destroy;
begin
  DeleteObject(FFont);

  ClearHandle;
  inherited;
end;

function THCanvas.GetHandle: HDC;
begin
  if not FHandleAllocated then
  begin
    FHandleAllocated := True;
    FHandle := CreateCompatibleDC(0);
  end;
  Result := FHandle;
end;

procedure THCanvas.SetHandle(const Value: HDC);
begin
  ClearHandle;
  FHandle := Value;
  FHandleAllocated := (Value <> 0);
end;

{ THGdiObject }

constructor THGdiObject.Create;
begin
  //
  FHandle := 0;
end;

destructor THGdiObject.Destroy;
begin
  DeleteObject(FHandle);
  inherited;
end;

end.
