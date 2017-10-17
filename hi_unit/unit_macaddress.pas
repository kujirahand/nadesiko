unit unit_macaddress;

interface

uses
  SysUtils;

type
  RPC_STATUS = longint;
  TGuid = packed record
    Data1: longint;
    Data2: word;
    Data3: word;
    Data4: array [0..7] of byte;
  end;
  TUuid = TGuid;

function UuidCreate(var Uuid: TUuid): RPC_STATUS; stdcall;
  external 'RPCRT4.DLL' name 'UuidCreate';

function GetMacAddress: string;

implementation

function GetMacAddress: string;
var
  i: integer;
  uuid: TUuid;
begin
  UuidCreate(uuid);
  result := inttohex(uuid.Data4[2], 2);
  for i := 3 to 7 do
    result := result + ':' + inttohex(uuid.Data4[i], 2);
end;


end.
