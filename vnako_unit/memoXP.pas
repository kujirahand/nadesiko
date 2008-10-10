unit memoXP;
{
  ------------------------------------------
  XPのThemeを適用すると, 全てが UNICODE として扱われるため選択範囲がおかしくなる
  不具合を解消するためのユニット
  ------------------------------------------
  製作: クジラ飛行机 (hima@xw.chu.jp)
  更新履歴
  2003/10/21 ver.1.00
  2005/04/11 ver.1.01 なでしこ用に改良。
}
interface

uses
  Windows, Messages, SysUtils, StdCtrls
  {$IFDEF VER150},themes{$ENDIF}
  ;

type

  TSelection = record
    StartPos, EndPos: Integer;
  end;
  
  TMemoXP = class(TMemo)
  private
    procedure SetSelText(Value: string);
    function GetSelectionB: TSelection;
  protected
    function GetSelStart: Integer; reintroduce; override;
    function GetSelLength: Integer; reintroduce; override;
    function GetSelText: string; reintroduce; override;
    procedure SetSelStart(Value: Integer); reintroduce; override;
    procedure SetSelLength(Value: Integer); reintroduce; override;
    // CaretPos
    function GetCaretPos: TPoint; reintroduce; override;
    procedure SetCaretPos(const Value: TPoint); reintroduce; override;
  published
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelText: string read GetSelText write SetSelText;
    property CaretPos: TPoint read GetCaretPos write SetCaretPos;
  end;

  TEditXP = class(TEdit)
  private
    procedure SetSelText(Value: string);
    function GetSelectionB: TSelection;
  protected
    function GetSelStart: Integer; override;
    function GetSelLength: Integer; override;
    function GetSelText: string; override;
    procedure SetSelStart(Value: Integer); override;
    procedure SetSelLength(Value: Integer); override;
  published
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelText: string read GetSelText write SetSelText;
  end;


function IsXp: Boolean;

implementation


function IsXp: Boolean;
var
  major,minor: LongInt;
  Info: TOSVersionInfo;
begin
(*
  {$IFDEF VER150}
  Result := ThemeServices.ThemesEnabled;
  {$ELSE}
  Result := False; //警告: Delphi7 でしか XP Theme スタイルの判別ができない
  {$ENDIF}
*)
  // はじめは、ＸＰのＸＰスタイルの時だけ、半角全角の区別が変わるのかと思ったら
  // ＸＰのクラシックスタイルでもＵＮＩＣＯＤＥを使うという事が発覚。
  Result := False;

  Info.dwOSVersionInfoSize := SizeOf(Info);
  GetVersionEx(Info);
  Major := Info.dwMajorVersion ;
  Minor := Info.dwMinorVersion ;
  if (Major = 5) then
  begin
    if Minor = 0 then Exit;
    Result := True; // XP or Later
  end;
  if (Major >= 6) then
  begin
    Result := True;
  end;
end;

function m2b(v: Integer; s: string): Integer;
var p: PChar; i: Integer;
begin
  // Unicode の Index から Byte の Index への変換
  Result := 0;
  if v=0 then Exit;

  i := 0;
  p := PChar(s);
  while p^ <> #0 do begin
    if i = v then Break;
    if p^ in LeadBytes then
    begin
      Inc(Result, 2); Inc(p, 2);
    end else
    begin
      Inc(Result); Inc(p);
    end;
    Inc(i);
  end;
end;


function b2m(v: Integer; s: string): Integer;
var
  p: PChar;
  i: Integer;
begin
  Result := 0;
  if v = 0 then Exit;
  i := 0;
  p := PChar(s);
  while p^ <> #0 do
  begin
    if v <= i then Break;
    if p^ in LeadBytes then
    begin
      Inc(i, 2); Inc(p, 2);
    end else
    begin
      Inc(i, 1); Inc(p);
    end;
    Inc(Result);
  end;
end;

{ TMemoXP }

function TMemoXP.GetCaretPos: TPoint;
var
  s: string;
begin
  Result := inherited GetCaretPos;
  if IsXP then
  begin
    s := Lines.Strings[Result.Y];
    Result.X := m2b(Result.X, s);
  end;
end;

function TMemoXP.GetSelectionB: TSelection;
begin
  SendMessage(Handle, EM_GETSEL, Longint(@Result.StartPos), Longint(@Result.EndPos));
  Result.StartPos := m2b(Result.StartPos, Text);
  Result.EndPos   := m2b(Result.EndPos, Text);
end;

function TMemoXP.GetSelLength: Integer;
var
  sel: TSelection;
begin
  if not IsXP then
  begin
    Result := inherited GetSelLength;
  end else
  begin
    sel := GetSelectionB;
    Result := sel.EndPos - sel.StartPos ;
  end;
end;


function TMemoXP.GetSelStart: Integer;
begin
  Result := inherited GetSelStart;
  if IsXP then Result := m2b(Result, Text);
end;

function TMemoXP.GetSelText: string;
var
  sel: TSelection;
begin
  if not IsXP then
  begin
    Result := inherited GetSelText;
  end else
  begin
    sel := GetSelectionB;
    Result := Copy(Text, sel.StartPos + 1, sel.EndPos - sel.StartPos);
  end;
end;



procedure TMemoXP.SetCaretPos(const Value: TPoint);
var
  v: TPoint;
begin
  if IsXP then
  begin
    v := Value;
    v.X := b2m(v.X, Lines.Strings[v.Y]);
  end;
  inherited SetCaretPos(v);
end;

procedure TMemoXP.SetSelLength(Value: Integer);
var
  fromPos, toPos: Integer;
begin
  if not IsXP then
  begin
    inherited SetSelLength(Value);
  end else
  begin
    fromPos := GetSelStart ;
    toPos   := fromPos + Value;
    fromPos := b2m(fromPos, Text);
    toPos   := b2m(toPos, Text);

    SendMessage(Handle, EM_SETSEL, fromPos, toPos);
    SendMessage(Handle, EM_SCROLLCARET, 0,0);
  end;
end;

procedure TMemoXP.SetSelStart(Value: Integer);
begin
  if IsXP then Value := b2m(Value, Text);
  inherited SetSelStart(Value);
end;

procedure TMemoXP.SetSelText(Value: string);
begin
  SendMessage(Handle, EM_REPLACESEL, 0, Longint(PChar(Value)));
end;

{ TEditXP }


function TEditXP.GetSelectionB: TSelection;
begin
  SendMessage(Handle, EM_GETSEL, Longint(@Result.StartPos), Longint(@Result.EndPos));
  Result.StartPos := m2b(Result.StartPos, Text);
  Result.EndPos   := m2b(Result.EndPos, Text);
end;

function TEditXP.GetSelLength: Integer;
var
  sel: TSelection;
begin
  if not IsXP then
  begin
    Result := inherited GetSelLength;
  end else
  begin
    sel := GetSelectionB;
    Result := sel.EndPos - sel.StartPos ;
  end;
end;

function TEditXP.GetSelStart: Integer;
begin
  Result := inherited GetSelStart;
  if IsXP then Result := m2b(Result, Text);
end;

function TEditXP.GetSelText: string;
var
  sel: TSelection;
begin
  if not IsXP then
  begin
    Result := inherited GetSelText;
  end else
  begin
    sel := GetSelectionB;
    Result := Copy(Text, sel.StartPos + 1, sel.EndPos - sel.StartPos);
  end;
end;

procedure TEditXP.SetSelLength(Value: Integer);
var
  fromPos, toPos: Integer;
begin
  if not IsXP then
  begin
    inherited SetSelLength(Value);
  end else
  begin
    fromPos := GetSelStart ;
    toPos   := fromPos + Value;
    fromPos := b2m(fromPos, Text);
    toPos   := b2m(toPos, Text);

    SendMessage(Handle, EM_SETSEL, fromPos, toPos);
    SendMessage(Handle, EM_SCROLLCARET, 0,0);
  end;
end;

procedure TEditXP.SetSelStart(Value: Integer);
begin
  if IsXP then Value := b2m(Value, Text);
  inherited SetSelStart(Value);
end;

procedure TEditXP.SetSelText(Value: string);
begin
  SendMessage(Handle, EM_REPLACESEL, 0, Longint(PChar(Value)));
end;

end.
