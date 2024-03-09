unit nakopad_types;

interface
uses
  SysUtils, Classes;

type
  TKeyValue = class
  public
    key   : string;
    value : TStringList;
    tag   : Integer;
    constructor Create;
    destructor  Destroy; override;
  end;
  
  TKeyValueList = class(TList)
  public
    procedure Clear; override;
    function FindKey(key: string): TKeyValue;
  end;

implementation

{ TKeyValue }

constructor TKeyValue.Create;
begin
  value := TStringList.Create;
end;

destructor TKeyValue.Destroy;
begin
  value.Free;
  inherited;
end;

{ TKeyValueList }

procedure TKeyValueList.Clear;
var
  i: Integer;
  p: TKeyValue;
begin
  for i := 0 to Count - 1 do
  begin
    p := Items[i];
    FreeAndNil(p);
  end;
  inherited Clear;
end;

function TKeyValueList.FindKey(key: string): TKeyValue;
var
  i: Integer;
  p: TKeyValue;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    p := Items[i];
    if key = p.key then
    begin
      Result := p;
      Break;
    end;
  end;
end;

end.
