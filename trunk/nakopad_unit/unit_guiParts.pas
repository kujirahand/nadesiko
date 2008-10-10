unit unit_guiParts;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls;

type
  TNGuiProp = class
    name    : string;
    value   : string;
    vtype   : string;
    sel     : string;
  end;

  TNGuiPropList = class
  private
    FList: TList;
    function GetItems(Prop: string): TNGuiProp;
    function ReadCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure LoadFromFile(fname: string);
    procedure Add(name: string; value: string; vtype: string; sel: string = '');
    property Items[Prop: string]: TNGuiProp read GetItems;
    function Get(Index: Integer): TNGuiProp;
    property Count:Integer read ReadCount;
    function GetAsText: string;
    procedure SetAsText(V: string);
    function IndexOf(name: string): Integer;
    procedure Delete(name: string);
    property Text:string read GetAsText write SetAsText;
  end;

  TNGuiParts = class(TShape)
  private
    function GetItems(name: string): TNGuiProp;
  protected
    FParent: TNGuiparts;
  public
    propList: TNGuiPropList;
    bMouse: Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
    procedure Obj2Prop; virtual;
    procedure Prop2Obj; virtual;
    function getItemsAsInt(name: string; def: Integer): Integer;
    property Items[name: string]: TNGuiProp read GetItems;
  end;

  TNGuiList = class
  public
    FList: TList;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Add(p: TNGuiParts);
    function Get(Index: Integer): TNGuiParts;
    procedure Delete(name: string);
    function IndexOf(name: string): Integer;
    function Find(name: string): TNGuiParts;
  end;

  TNGuiForm = class(TNGuiParts)
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  end;

  TNGuiButton = class(TNGuiParts)
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  end;

  TNGuiEdit = class(TNGuiParts)
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  end;

  TNGuiListParts = class(TNGuiParts)
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  end;

  TNGuiCombo = class(TNGuiParts)
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  end;

  TNGuiLabel = class(TNGuiParts)
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  end;

  TNGuiCheck = class(TNGuiParts)
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  end;

  TNGuiMemo = class(TNGuiParts)
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  end;

  TNGuiBar = class(TNGuiParts)
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  end;

  TNGuiTEditor = class(TNGuiParts)
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  end;

  TNGuiGrid = class(TNGuiListParts)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TNGuiImage = class(TNGuiParts)
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  end;

  TNGuiAnime = class(TNGuiImage)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TNGuiPanel = class(TNGuiParts)
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  end;

implementation

uses StrUnit, Types;

{ TNGuiPropList }

procedure TNGuiPropList.Add(name, value, vtype: string; sel: string);
var
  v: TNGuiProp;
begin
  v := TNGuiProp.Create;
  v.name := name;
  v.value := value;
  v.vtype := vtype;
  v.sel   := sel;
  Self.FList.Add(v);
end;

procedure TNGuiPropList.Clear;
var
  i: Integer;
  v: TNGuiProp;
begin
  for i := 0 to Self.FList.Count - 1 do
  begin
    v := Self.FList.Items[i];
    FreeAndNil(v);
  end;
  FList.Clear;
end;

constructor TNGuiPropList.Create;
begin
  FList := TList.Create;
  Add('種類', 'ボタン', '文字列');
  Add('名前', '名無し', '文字列');
  Add('X', '0', '数値');
  Add('Y', '0', '数値');
  Add('W', '64', '数値');
  Add('H', '32', '数値');
end;

procedure TNGuiPropList.Delete(name: string);
var
  i: Integer;
  p: TNGuiProp;
begin
  i := IndexOf(name);
  if i >= 0 then
  begin
    p := Self.Get(i);
    FList.Delete(i);
    FreeAndNil(p);
  end;
end;

destructor TNGuiPropList.Destroy;
begin
  FreeAndNil(FList);
  inherited;
end;

function TNGuiPropList.Get(Index: Integer): TNGuiProp;
begin
  Result := FList.Items[Index];
end;

function TNGuiPropList.GetAsText: string;
var
  i: Integer;
  p: TNGuiProp;
begin
  Result := '';
  for i := 0 to FList.Count - 1 do
  begin
    p := FList.Items[i];
    Result := Result + p.name + ':' + p.vtype + '=' + p.value + #13#10;
  end;
end;

function TNGuiPropList.GetItems(Prop: string): TNGuiProp;
var
  i: Integer;
  p: TNGuiProp;
begin
  Result := nil;
  for i := 0 to FList.Count - 1 do
  begin
    p := FList.Items[i];
    if p.name = Prop then
    begin
      Result := p;
      Break;
    end;
  end;
  if Result = nil then
  begin
    p := TNGuiProp.Create;
    p.name := Prop;
    p.value := '';
    p.vtype := '文字列';
    Result := p;
  end;
end;

function TNGuiPropList.IndexOf(name: string): Integer;
var
  i: Integer;
  p: TNGuiProp;
begin
  Result := -1;
  for i := 0 to FList.Count - 1 do
  begin
    p := FList.Items[i];
    if p = nil then Continue;
    if p.name = name then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TNGuiPropList.LoadFromFile(fname: string);
begin
  //
end;

function TNGuiPropList.ReadCount: Integer;
begin
  Result := FList.Count;
end;

procedure TNGuiPropList.SetAsText(V: string);
var
  i: Integer;
  s: TStringList;
  n, vv: string;
begin
  s := TStringList.Create;
  s.Text := V;
  for i := 0 to s.Count - 1 do
  begin
    vv := s.Strings[i];
    n := GetToken('=', vv);
    n := GetToken(':', n);
    Items[n].value := vv;
  end;
  s.Free;
end;

{ TNGuiParts }


constructor TNGuiParts.Create(AOwner: TComponent);
begin
  inherited;
  Self.FParent := TNGuiparts(AOwner);
  propList := TNGuiPropList.Create;
  Self.Width := 64;
  Self.Height := 32;
  bMouse := False;
end;

destructor TNGuiParts.Destroy;
begin
  Self.Parent := nil;
  Self.Visible := False;
  FreeAndNil(propList);
  inherited;
end;



procedure TNGuiParts.Paint;
var
  r: TRect;
  s: string;
begin
  inherited;
  r := GetClientRect;
  //
  s := propList.Items['テキスト'].value;
  if s = '' then s := propList.Items['名前'].value;
  DrawFrameControl(Self.Canvas.Handle, r, DFC_BUTTON,	DFCS_BUTTONPUSH);
  Canvas.Brush.Style := bsClear;
  Canvas.Font.Color  := clBtnText;
  DrawText(Self.Canvas.Handle, PChar(s), Length(s), r, DT_CENTER or DT_SINGLELINE	or DT_VCENTER);
end;

procedure TNGuiParts.Obj2Prop;
begin
  // size
  propList.Items['X'].value := IntToStr(Left);
  propList.Items['Y'].value := IntToStr(Top);
  propList.Items['W'].value := IntToStr(Width);
  propList.Items['H'].value := IntToStr(Height);
end;

procedure TNGuiParts.Prop2Obj;
begin
  Left    := StrToIntDef(propList.Items['X'].value, Left);
  Top     := StrToIntDef(propList.Items['Y'].value, Top);
  Width   := StrToIntDef(propList.Items['W'].value, Width);
  Height  := StrToIntDef(propList.Items['H'].value, Height);
end;

function TNGuiParts.GetItems(name: string): TNGuiProp;
begin
  Result := propList.Items[name];
end;

function TNGuiParts.getItemsAsInt(name: string; def: Integer): Integer;
var
  s: string;
begin
  s := Items[name].value;
  Result := StrToIntDef(s, def);
end;

{ TNGuiList }

procedure TNGuiList.Add(p: TNGuiParts);
begin
  FList.Add(p);
end;

procedure TNGuiList.Clear;
var
  i: Integer;
  p: TNGuiParts;
begin
  for i := 0 to FList.Count - 1 do
  begin
    p := FList.Items[i];
    FreeAndNil(p);
  end;
  FList.Clear;
end;

constructor TNGuiList.Create;
begin
  FList := TList.Create;
end;

procedure TNGuiList.Delete(name: string);
var
  p: TNGuiParts;
  i: Integer;
begin
  i := IndexOf(name);
  if i >= 0 then
  begin
    p := FList.Items[i];
    FList.Delete(i);
    p.Visible := False;
    FreeAndNil(p);
  end;
end;

destructor TNGuiList.Destroy;
begin
  FreeAndNil(FList);
  inherited;
end;

function TNGuiList.Find(name: string): TNGuiParts;
var
  i: Integer;
  p: TNGuiParts;
begin
  Result := nil;
  for i := 0 to FList.Count - 1 do
  begin
    p := FList.Items[i];
    if p.propList.Items['名前'].value = name then
    begin
      Result := p;
      Break;
    end;
  end;
end;

function TNGuiList.Get(Index: Integer): TNGuiParts;
begin
  Result := FList.Items[Index];
end;

function TNGuiList.IndexOf(name: string): Integer;
var
  i: Integer;
  p: TNGuiParts;
begin
  Result := -1;
  for i := 0 to FList.Count - 1 do
  begin
    p := FList.Items[i];
    if p.propList.Items['名前'].value = name then
    begin
      Result := i;
      Break;
    end;
  end;
end;

{ TNGuiForm }

constructor TNGuiForm.Create(AOwner: TComponent);
begin
  inherited;
  Self.Width  := 640;
  Self.Height := 400;
  Self.propList.Items['種類'].value     := 'フォーム';
  Self.propList.Add('タイトル','なでしこ','文字列');
  propList.Add('クリックした時','', 'イベント');
  propList.Add('ダブルクリックした時','', 'イベント');
end;


procedure TNGuiForm.Paint;
begin
  inherited;

  with Self.Canvas do
  begin
    Brush.Color := clWhite;
    Brush.Style := bsSolid;
    Pen.Color := clBtnShadow;
    Pen.Width := 1;
    Pen.Style := psDot;
    Rectangle(
      0,
      0,
      Self.Width,
      Self.Height);
  end;
end;


{ TNGuiButton }

constructor TNGuiButton.Create(AOwner: TComponent);
begin
  inherited;
  propList.Add('テキスト','', '文字列');
  propList.Items['種類'].value := 'ボタン';
  propList.Add('クリックした時','','イベント');
end;

procedure TNGuiButton.Paint;
var
  r: TRect;
  s: string;
begin
  r := GetClientRect;
  //
  s := propList.Items['テキスト'].value;
  DrawFrameControl(Self.Canvas.Handle, r, DFC_BUTTON,	DFCS_BUTTONPUSH);
  Canvas.Brush.Style := bsClear;
  Canvas.Font.Color  := clBtnText;
  DrawText(Self.Canvas.Handle, PChar(s), Length(s), r, DT_CENTER or DT_SINGLELINE	or DT_VCENTER);
end;

{ TNGuiEdit }

constructor TNGuiEdit.Create(AOwner: TComponent);
begin
  inherited;
  propList.Items['種類'].value := 'エディタ';
  // prop
  propList.Add('テキスト','', '文字列');
  // event
  propList.Add('クリックした時','', 'イベント');
  propList.Add('ダブルクリックした時','', 'イベント');
  propList.Add('変更した時','', 'イベント');
  propList.Add('キー押した時','', 'イベント');
  propList.Add('キー離した時','', 'イベント');
  propList.Add('キータイピング時','', 'イベント');
end;


procedure TNGuiEdit.Paint;
var
  r: TRect;
  s: string;
begin
  r := GetClientRect;
  //
  s := propList.Items['テキスト'].value;

  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := clWhite;
  Canvas.Rectangle(r);
  DrawEdge(Self.Canvas.Handle, r, BDR_SUNKENOUTER or BDR_SUNKENINNER, BF_RECT);

  Canvas.Brush.Style := bsClear;
  Canvas.Font.Color  := clBtnText;
  r.Left := 4;
  r.Top  := 4;
  DrawText(Self.Canvas.Handle, PChar(s), Length(s), r, DT_LEFT or DT_SINGLELINE);
end;

{ TNGuiLabel }

constructor TNGuiLabel.Create(AOwner: TComponent);
begin
  inherited;
  propList.Add('テキスト','', '文字列');
  propList.Items['種類'].value := 'ラベル';
  propList.Add('クリックした時','', 'イベント');
  propList.Add('ダブルクリックした時','', 'イベント');
end;


procedure TNGuiLabel.Paint;
var
  r: TRect;
  s: string;
begin
  r := GetClientRect;

  s := propList.Items['テキスト'].value;

  Canvas.Pen.Style := psDot;
  Canvas.Pen.Color := clGray;
  
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := clWhite;
  Canvas.Rectangle(r);

  Canvas.Brush.Style := bsClear;
  Canvas.Font.Color  := clBtnText;
  r.Left := 4;
  r.Top  := 4;
  DrawText(Self.Canvas.Handle, PChar(s), Length(s), r, DT_LEFT or DT_SINGLELINE);
end;

{ TNGuiMemo }

constructor TNGuiMemo.Create(AOwner: TComponent);
begin
  inherited;
  propList.Items['種類'].value := 'メモ';
  // prop
  propList.Add('テキスト','', '文字列');
  propList.Add('スクロールバー','', '文字列','縦|横|縦横');
  // event
  propList.Add('クリックした時','', 'イベント');
  propList.Add('ダブルクリックした時','', 'イベント');
  propList.Add('変更した時','', 'イベント');
  propList.Add('キー押した時','', 'イベント');
  propList.Add('キー離した時','', 'イベント');
  propList.Add('キータイピング時','', 'イベント');
end;


procedure TNGuiMemo.Paint;
var
  r: TRect;
  s: string;
begin
  r := GetClientRect;
  //
  s := propList.Items['テキスト'].value;

  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := clWhite;
  Canvas.Rectangle(r);
  DrawEdge(Self.Canvas.Handle, r, BDR_SUNKENOUTER or BDR_SUNKENINNER, BF_RECT);

  Canvas.Brush.Style := bsClear;
  Canvas.Font.Color  := clBtnText;
  r.Left := 4;
  r.Top  := 4;
  DrawText(Self.Canvas.Handle, PChar(s), Length(s), r, DT_LEFT or DT_SINGLELINE);
end;

{ TNGuiBar }

constructor TNGuiBar.Create(AOwner: TComponent);
begin
  inherited;
  propList.Items['種類'].value := 'バー';
  // prop
  propList.Add('値','0', '数値');
  propList.Add('最小値','0', '数値');
  propList.Add('最大値','100', '数値');
  propList.Add('向き','横', '文字列','縦|横');
  // event
  propList.Add('変更した時','', 'イベント');

end;

procedure TNGuiBar.Paint;
var
  r: TRect;
  s: string;
begin
  r := GetClientRect;
  //
  s := propList.Items['向き'].value;
  // body
  DrawFrameControl(Self.Canvas.Handle, r, DFC_BUTTON,	DFCS_BUTTONPUSH);
  // left
  if s = '横' then
  begin
    r.Right := 16;
    DrawFrameControl(Self.Canvas.Handle, r, DFC_SCROLL,	DFCS_SCROLLLEFT);
    // right
    r := GetClientRect;
    r.Left := r.Right - 16;
    DrawFrameControl(Self.Canvas.Handle, r, DFC_SCROLL,	DFCS_SCROLLRIGHT);
  end else
  begin
    r.Bottom := 16;
    DrawFrameControl(Self.Canvas.Handle, r, DFC_SCROLL,	DFCS_SCROLLUP);
    // right
    r := GetClientRect;
    r.Top := r.Bottom - 16;
    DrawFrameControl(Self.Canvas.Handle, r, DFC_SCROLL,	DFCS_SCROLLDOWN);
  end;
end;

{ TNGuiTEditor }

constructor TNGuiTEditor.Create(AOwner: TComponent);
begin
  inherited;
  propList.Items['種類'].value := 'Tエディタ';
  // prop
  propList.Add('テキスト','', '文字列');
  propList.Add('スクロールバー','', '文字列','縦|横|縦横');
  // event
  propList.Add('クリックした時','', 'イベント');
  propList.Add('ダブルクリックした時','', 'イベント');
  propList.Add('変更した時','', 'イベント');
  propList.Add('キー押した時','', 'イベント');
  propList.Add('キー離した時','', 'イベント');
  propList.Add('キータイピング時','', 'イベント');
end;

procedure TNGuiTEditor.Paint;
var
  r: TRect;
  s: string;
begin
  r := GetClientRect;
  //
  s := propList.Items['テキスト'].value;

  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := clWhite;
  Canvas.Rectangle(r);
  DrawEdge(Self.Canvas.Handle, r, BDR_SUNKENOUTER or BDR_SUNKENINNER, BF_RECT);

  Canvas.Brush.Style := bsClear;
  Canvas.Font.Color  := clBtnText;
  r.Left := 4;
  r.Top  := 4;
  DrawText(Self.Canvas.Handle, PChar(s), Length(s), r, DT_LEFT or DT_SINGLELINE);
end;

{ TNGuiGrid }

constructor TNGuiGrid.Create(AOwner: TComponent);
begin
  inherited;
  propList.Items['種類'].value := 'グリッド';
  // prop
  propList.Add('アイテム','', '文字列');
  // event
  propList.Add('クリックした時','', 'イベント');
  propList.Add('ダブルクリックした時','', 'イベント');
  propList.Add('変更した時','', 'イベント');
  propList.Add('キー押した時','', 'イベント');
  propList.Add('キー離した時','', 'イベント');
  propList.Add('キータイピング時','', 'イベント');
end;


{ TNGuiImage }

constructor TNGuiImage.Create(AOwner: TComponent);
begin
  inherited;
  propList.Items['種類'].value := 'イメージ';
  // prop
  propList.Add('画像','', '文字列');
  // event
  propList.Add('クリックした時','', 'イベント');
  propList.Add('ダブルクリックした時','', 'イベント');
  propList.Add('マウス押した時','', 'イベント');
  propList.Add('マウス移動した時','', 'イベント');
  propList.Add('マウス離した時','', 'イベント');

end;

procedure TNGuiImage.Paint;
var
  r: TRect;
  s: string;
begin
  r := GetClientRect;

  s := propList.Items['名前'].value;

  Canvas.Pen.Style := psDot;
  Canvas.Pen.Color := clGray;
  Canvas.Brush.Style := bsClear;
  Canvas.Rectangle(r);

  Canvas.Brush.Style := bsClear;
  Canvas.Font.Color  := clBtnText;
  r.Left := 4;
  r.Top  := 4;
  DrawText(Self.Canvas.Handle, PChar(s), Length(s), r, DT_LEFT or DT_SINGLELINE);
end;

{ TNGuiAnime }

constructor TNGuiAnime.Create(AOwner: TComponent);
begin
  inherited;
  propList.Items['種類'].value := 'アニメ';
  // prop
  propList.Add('画像','', '文字列');
  propList.Add('再生回数','1', '文字列');
  propList.Add('表示間隔','500', '数値');
  propList.Add('ボタンモード','0', '数値');

  // event
  propList.Add('クリックした時','', 'イベント');
  propList.Add('ダブルクリックした時','', 'イベント');
  propList.Add('マウス押した時','', 'イベント');
  propList.Add('マウス移動した時','', 'イベント');
  propList.Add('マウス離した時','', 'イベント');
end;

{ TNGuiPanel }

constructor TNGuiPanel.Create(AOwner: TComponent);
begin
  inherited;
  propList.Items['種類'].value := 'パネル';
  // prop

  // event
  propList.Add('クリックした時','', 'イベント');
  propList.Add('ダブルクリックした時','', 'イベント');
  propList.Add('マウス押した時','', 'イベント');
  propList.Add('マウス移動した時','', 'イベント');
  propList.Add('マウス離した時','', 'イベント');
end;

procedure TNGuiPanel.Paint;
begin
  inherited;

end;

{ TNGuiCheck }

constructor TNGuiCheck.Create(AOwner: TComponent);
begin
  inherited;
  propList.Items['種類'].value := 'チェック';
  propList.Add('値','', '数値');
  propList.Add('テキスト','', '文字列');
  propList.Add('クリックした時','','イベント');
end;

procedure TNGuiCheck.Paint;
var
  r: TRect;
  s: string;
begin
  r := GetClientRect;
  r.Left := 20;
  //
  s := propList.Items['テキスト'].value;
  DrawFrameControl(Self.Canvas.Handle, RECT(0,0,16,16), DFC_BUTTON,	DFCS_BUTTONCHECK);
  Canvas.Brush.Style := bsClear;
  Canvas.Font.Color  := clBtnText;
  DrawText(Self.Canvas.Handle, PChar(s), Length(s), r, DT_LEFT or DT_SINGLELINE	or DT_TOP);
end;

{ TNGuiListParts }

constructor TNGuiListParts.Create(AOwner: TComponent);
begin
  inherited;
  propList.Items['種類'].value := 'リスト';
  // prop
  propList.Add('テキスト','', '文字列');
  propList.Add('アイテム','', '文字列');
  // event
  propList.Add('クリックした時','', 'イベント');
  propList.Add('ダブルクリックした時','', 'イベント');
  propList.Add('変更した時','', 'イベント');
  propList.Add('キー押した時','', 'イベント');
  propList.Add('キー離した時','', 'イベント');
  propList.Add('キータイピング時','', 'イベント');
end;

procedure TNGuiListParts.Paint;
var
  r: TRect;
  s: string;
begin
  r := GetClientRect;
  //
  s := propList.Items['テキスト'].value;

  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := clWhite;
  Canvas.Rectangle(r);
  DrawEdge(Self.Canvas.Handle, r, BDR_SUNKENOUTER or BDR_SUNKENINNER, BF_RECT);

  Canvas.Brush.Style := bsClear;
  Canvas.Font.Color  := clBtnText;
  r.Left := 4;
  r.Top  := 4;
  DrawText(Self.Canvas.Handle, PChar(s), Length(s), r, DT_LEFT or DT_SINGLELINE);
end;

{ TNGuiCombo }

constructor TNGuiCombo.Create(AOwner: TComponent);
begin
  inherited;
  propList.Items['種類'].value := 'コンボ';
  // prop
  propList.Add('テキスト','', '文字列');
  propList.Add('アイテム','', '文字列');
  // event
  propList.Add('クリックした時','', 'イベント');
  propList.Add('ダブルクリックした時','', 'イベント');
  propList.Add('変更した時','', 'イベント');
  propList.Add('キー押した時','', 'イベント');
  propList.Add('キー離した時','', 'イベント');
  propList.Add('キータイピング時','', 'イベント');
end;

procedure TNGuiCombo.Paint;
var
  r: TRect;
  s: string;
begin
  inherited;
  r := GetClientRect;
  //
  s := propList.Items['テキスト'].value;
  Self.Canvas.Brush.Style := bsSolid;
  Self.Canvas.Brush.Color := clWhite;
  Self.Canvas.Rectangle(r);
  DrawEdge(Self.Canvas.Handle, r, BDR_SUNKENOUTER or BDR_SUNKENINNER,	BF_RECT);
  Canvas.Brush.Style := bsClear;
  Canvas.Font.Color  := clBtnText;
  r.Left := 4;
  r.Top := 4;
  DrawText(Self.Canvas.Handle, PChar(s), Length(s), r, DT_LEFT or DT_SINGLELINE	or DT_TOP);
  // thumb
  r.Left := r.Right - 16;
  r.Top := 0;
  DrawFrameControl(Self.Canvas.Handle, r, DFC_BUTTON,	DFCS_BUTTONPUSH);
end;

end.




