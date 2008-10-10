unit hima_hotkey_manager;

interface
uses
  SysUtils, Classes, HotKeyManager;

type
  THiHotkey = class(THotKeyManager)
  private
    FEventList: TStringList;
    procedure HotKeyPressed(HotKey: Cardinal; Index: Word);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure AddHotKeyEvent(key: string; event: string);
    procedure RemoveHotKeyEvent(key: string);
  end;

implementation

uses dll_plugin_helper, dnako_import, hima_types, dnako_import_types;

{ THiHotkey }

procedure THiHotkey.AddHotKeyEvent(key, event: string);
var
  h: Cardinal;
begin
  FEventList.Values[key] := event;
  h := TextToHotKey(key, True);
  AddHotKey(h);
end;

constructor THiHotkey.Create(AOwner: TComponent);
begin
  inherited;
  FEventList := TStringList.Create;
  OnHotKeyPressed := HotKeyPressed;
end;

destructor THiHotkey.Destroy;
begin
  FEventList.Free;
  inherited;
end;

procedure THiHotkey.HotKeyPressed(HotKey: Cardinal; Index: Word);
var
  v, s: string;
  p: PHiValue;
begin
  s := HotKeyToText(HotKey, True);
  v := FEventList.Values[s];
  if v <> '' then
  begin
    p := nako_eval(PChar(v));
    nako_var_free(p);
  end;
end;

procedure THiHotkey.RemoveHotKeyEvent(key: string);
var
  h: Cardinal;
begin
  h := TextToHotKey(key, True);
  RemoveHotKey(h);
  FEventList.Values[key] := '';
end;

end.
