unit unit_tree_list;

interface

uses
  Windows, SysUtils, Classes, ComCtrls, CsvUtils2, Controls, Messages;

type
  THiTreeNode = class
  public
    Obj: TTreeNode;
    IDStr: string;
    function GetTreePath: string;
    function GetTreePathText: string;
  end;

  THiTreeNodeList = class(TList)
  public
    procedure Clear; override;
    function FindID(IDStr: string): Integer;
    function FindIDNode(IDStr: string): THiTreeNode;
  end;

  THiTreeView = class(TTreeView)
  private
    FHoverTime : Cardinal;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    FOnMouseHover : TMouseEvent;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseHover(var Msg: TMessage); message WM_MOUSEHOVER;
    function getItemIndex: Integer;
    procedure setItemIndex(const Value: Integer);
    function getSelectedID: string;
    procedure setSelectedID(const Value: string);
  public
    dropPath: string;
    list: THiTreeNodeList;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetSelectPath(path: string);
    property ItemIndex: Integer read getItemIndex write setItemIndex;
    property SelectedID: string read getSelectedID write setSelectedID;
    procedure ChangeText(nodeid_text: string);
    procedure ChangePic(nodeid_v: string);
    procedure ChangeSelectPic(nodeid_v: string);
    procedure DeleteID(id: string);
    procedure ExpandAllID(id: string);
    procedure CollapseAllID(id: string);
    procedure ExpandID(id: string);
    procedure CollapseID(id: string);
    function GetParentID(id: string): string;
    function GetChildrenID(id: string): string;
    function GetExpanded(id: string): boolean;
    procedure Clear; virtual;
    property HoverTime:Cardinal read FHoverTime write FHoverTime;
    property OnMouseEnter:TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave:TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseHover:TMouseEvent  read FOnMouseHover write FOnMouseHover;
  end;

function TreeToCsv(tree: THiTreeView): string;
procedure CsvToTree(tree: THiTreeView; csvText: string; ClearMode: Boolean);

implementation

uses StrUnit,Forms;

function TreeToCsv(tree: THiTreeView): string;
var
  i: Integer;
  n: THiTreeNode;
begin
  Result := '';
  for i := 0 to tree.Items.Count - 1 do
  begin
    n := tree.Items.Item[i].Data;
    // parent
    if n.Obj.Parent <> nil then
    begin
      Result := Result + THiTreeNode(n.Obj.Parent.Data).IDStr;
    end;
    Result := Result + ',';
    // self ID
    Result := Result + n.IDStr + ',';
    // text
    Result := Result + '"' + n.Obj.Text + '",';
    // pic
    Result := Result + IntToStr(n.Obj.ImageIndex) + ',';
    // sel pic
    Result := Result + IntToStr(n.Obj.SelectedIndex) + #13#10;
  end;
end;

procedure CsvToTree(tree: THiTreeView; csvText: string; ClearMode: Boolean);
var
  n, nParent: THiTreeNode;
  i, cnt: Integer;
  csv: TCsvSheet;
  sParent, sId, sText: string;
  oldParent: array [0..30] of string;
  iPic, iPicSel: Integer;

  function _count(s: string): Integer;
  var i : Integer;
  begin
    Result := 0;
    for i := 1 to Length(s) do
    begin
      if s[i] = '-' then Inc(Result);
    end;
  end;

begin
  csv := TCsvSheet.Create;
  csv.AsText := csvText;
  for i := 0 to High(oldParent) do oldParent[i] := '';
  if tree = nil then raise Exception.Create('ツリーが特定されていません');
  
  tree.Items.BeginUpdate;
  try
    if ClearMode then
    begin
      tree.Clear;
    end;
    for i := 0 to csv.Count - 1 do
    begin
      // 親識別名,ノード識別名,テキスト,画像番号,選択画像番号
      sParent := Trim(convToHalfAnk(csv.Cells[0, i]));
      sId := Trim(convToHalfAnk(csv.Cells[1, i]));
      sText := Trim(csv.Cells[2, i]);
      iPic    := StrToIntDef(Trim(csv.Cells[3,i]), -1);
      iPicSel := StrToIntDef(Trim(csv.Cells[4,i]), -1);
      //---
      if Copy(sParent,1,1) = '#' then Continue;
      if sParent = 'なし' then sParent := '';
      if (sId <> '')and(sText = '') then sText := sId;
      //---
      if Copy(sParent,1,1) = '-' then
      begin
        cnt := _count(sParent);
        sParent := oldParent[cnt-1];
        oldParent[cnt] := sId;
      end else
      begin
        oldParent[0] := sId;
      end;

      // エラーチェック
      if sID = '' then Continue;
      if tree.list.FindIDNode(sID) <> nil then raise Exception.Create(sId + 'は既に使われているノードIDです。');
      // 基本ノード情報
      n := THiTreeNode.Create;
      n.IDStr := sId;
      if sParent = '' then
      begin
        n.Obj := tree.Items.AddChild(nil, sText);
      end else
      begin
        nParent := tree.list.FindIDNode(sParent);
        if nParent = nil then raise Exception.Create(sId + 'の親' + sParent + 'が見当たりません。');
        n.Obj := tree.Items.AddChild(nParent.Obj, sText);
      end;
      n.Obj.Data := n;
      n.Obj.ImageIndex := iPic;
      n.Obj.SelectedIndex := iPicSel;
      tree.list.Add(n);
    end;

  finally
    tree.Items.EndUpdate;
  end;
end;

{ THiTreeView }

procedure THiTreeView.ChangePic(nodeid_v: string);
var
  nid: string;
  n: THiTreeNode;
begin
  // nodeid = value のテキストから nodeid を得て、text を設定する
  nid := GetToken('=', nodeid_v);
  n := list.FindIDNode(nid);
  if n = nil then raise Exception.Create(nid+'がツリーに見当たりません。');
  n.Obj.ImageIndex := StrToIntDef(Trim(nodeid_v), -1);
end;

procedure THiTreeView.ChangeSelectPic(nodeid_v: string);
var
  nid: string;
  n: THiTreeNode;
begin
  // nodeid = value のテキストから nodeid を得て、text を設定する
  nid := GetToken('=', nodeid_v);
  n := list.FindIDNode(nid);
  if n = nil then raise Exception.Create(nid+'がツリーに見当たりません。');
  n.Obj.SelectedIndex := StrToIntDef(Trim(nodeid_v), -1);
end;

procedure THiTreeView.ChangeText(nodeid_text: string);
var
  nid: string;
  n: THiTreeNode;
begin
  // nodeid = value のテキストから nodeid を得て、text を設定する
  nid := GetToken('=', nodeid_text);
  n := list.FindIDNode(nid);
  if n = nil then raise Exception.Create(nid+'がツリーに見当たりません。');
  n.Obj.Text := Trim(nodeid_text);
end;

procedure THiTreeView.Clear;
begin
  list.Clear;
  Self.Items.Clear;
end;

procedure THiTreeView.CollapseID(id: string);
var
  n: THiTreeNode;
begin
  n := list.FindIDNode(id);
  if n = nil then Exit;
  n.Obj.Collapse(False);
end;

procedure THiTreeView.CollapseAllID(id: string);
var
  n: THiTreeNode;
begin
  n := list.FindIDNode(id);
  if n = nil then Exit;
  n.Obj.Collapse(True);
end;

constructor THiTreeView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  list := THiTreeNodeList.Create;
end;

procedure THiTreeView.DeleteID(id: string);
var
  n: THiTreeNode;

  procedure del(n: TTreeNode);
  var cn: TTreeNode; no: THiTreeNode;
  begin
    if n = nil then Exit;
    // 自分以下を消す
    while n.Count > 0 do
    begin
      cn := n.Item[0];
      del(cn);
    end;
    // 自分を消す
    // 関連付けられている拡張データを得る
    no := THiTreeNode(n.Data) ;
    // リストから拡張データを消す
    Self.list.Remove(no);
    // 拡張データを解放する
    FreeAndNil(no);
    // 自身を消す
    n.Data := nil;
    n.Delete;
  end;

begin
  n := list.FindIDNode(id);
  if n = nil then raise Exception.Create('"'+id+'"がノードに見つかりません。');

  // 自分以下のオブジェクトを削除
  del(n.Obj);
end;

destructor THiTreeView.Destroy;
begin
  FreeAndNil(list);
  inherited;
end;

procedure THiTreeView.ExpandID(id: string);
var
  n: THiTreeNode;
begin
  n := list.FindIDNode(id);
  if n = nil then Exit;
  n.Obj.Expand(False);
end;

procedure THiTreeView.ExpandAllID(id: string);
var
  n: THiTreeNode;
begin
  n := list.FindIDNode(id);
  if n = nil then Exit;
  n.Obj.Expand(True);
end;

function THiTreeView.GetChildrenID(id: string): string;
var
  n, c: THiTreeNode;
  i: Integer;
begin
  Result := '';
  n := list.FindIDNode(id);
  if n = nil then Exit;
  for i := 0 to n.Obj.Count - 1 do
  begin
    c := THiTreeNode(n.Obj.Item[i].Data);
    Result := Result + c.IDStr + #13#10;
  end;
  Result := Trim(Result);
end;

function THiTreeView.getItemIndex: Integer;
begin
  if Self.Selected = nil then
  begin
    Result := -1; Exit;
  end;
  Result := Self.list.FindID(THiTreeNode(Self.Selected.Data).IDStr);
end;

function THiTreeView.GetExpanded(id: string): Boolean;
var
  n: THiTreeNode;
begin
  Result := false;
  n := list.FindIDNode(id);
  if (n = nil) then Exit;
  Result := n.Obj.Expanded; // 開閉状態
end;

function THiTreeView.GetParentID(id: string): string;
var
  n: THiTreeNode;
begin
  Result := '';
  n := list.FindIDNode(id);
  if (n = nil) or (n.Obj.Parent = nil)then Exit;
  n := THiTreenode(n.Obj.Parent.Data); // 親
  if n = nil then Exit;
  Result := n.IDStr;
end;

function THiTreeView.getSelectedID: string;
begin
  if self.Selected = nil then
  begin
    Result := '';
  end else
  begin
    Result := THiTreeNode(self.Selected.Data).IDStr;
  end;
end;


procedure THiTreeView.setItemIndex(const Value: Integer);
begin
  if list.Count >= Value then Exit;
  if Value < 0 then
  begin
    Self.Selected := nil; Exit;
  end;
  Self.Selected := THiTreeNode(list.Items[Value]).Obj;
end;

procedure THiTreeView.setSelectedID(const Value: string);
var
  n: THiTreeNode;
begin
  n := list.FindIDNode(Value);
  if n <> nil then n.Obj.Selected := True;
end;

procedure THiTreeView.SetSelectPath(path: string);
var
  n, c, ok: TTreeNode;
  sl: TStringList;
  name: string;
  i, j: Integer;
begin
  sl := SplitChar('\', path);
  try
    n := Self.TopItem;
    for i := 0 to sl.Count - 1 do
    begin
      name := sl.Strings[i];
      if name = '' then Break;
      ok := nil;
      for j := 0 to n.Count - 1 do
      begin
        c := n.Item[j];
        if c.Text = name then begin ok := c; Break; end;
      end;
      if ok = nil then Exit;// 一致なし
      n := ok;
    end;
    n.Selected := True;
  finally
    sl.Free;
  end;
end;

procedure THiTreeView.CMMouseEnter(var Msg:TMessage);
var
  tme:TTrackMouseEvent;
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(self);
  tme.cbSize := sizeof(tme);
  tme.dwFlags := TME_HOVER;
  tme.hwndTrack := Handle;
  tme.dwHoverTime := FHoverTime;
  TrackMouseEvent(tme);
end;

procedure THiTreeView.CMMouseLeave(var Msg:TMessage);
begin
  if (Msg.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure THiTreeView.WMMouseHover(var Msg:TMessage);
begin
  if Assigned(FOnMouseHover) then
  begin
    with TWMMouse(Msg) do
      FOnMouseHover(Self,mbLeft,KeysToShiftState(Keys),XPos,YPos);
  end;
end;

{ THiTreeNodeList }

procedure THiTreeNodeList.Clear;
var
  i: Integer;
  n: THiTreeNode;
begin
  for i := 0 to Count - 1 do
  begin
    n := Items[i];
    FreeAndNil(n);
  end;
  inherited;
end;

function THiTreeNodeList.FindID(IDStr: string): Integer;
var
  i: Integer;
  n: THiTreeNode;
begin
  Result := -1;
  for i := 0 to Count - 1 do
  begin
    n := Self.Items[i];
    if n = nil then Continue;
    if n.IDStr = IDStr then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function THiTreeNodeList.FindIDNode(IDStr: string): THiTreeNode;
var
  i: Integer;
begin
  Result := nil;
  i := FindID(IDStr);
  if i < 0 then Exit;
  Result := Self.Items[i];
end;

{ THiTreeNode }

function THiTreeNode.GetTreePath: string;

  function getPath(n: TTreeNode): string;
  begin
    if n = nil then Exit;
    Result := getPath(n.Parent) + THiTreeNode(n.Data).IDStr + '\';
  end;

begin
  Result := getPath(Self.Obj);
end;

function THiTreeNode.GetTreePathText: string;

  function getPath(n: TTreeNode): string;
  begin
    if n = nil then Exit;
    Result := getPath(n.Parent) + n.Text+ '\';
  end;

begin
  Result := getPath(Self.Obj);
end;

end.
