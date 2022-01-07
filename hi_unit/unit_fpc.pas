unit unit_fpc;

interface

type
  HWND = Integer;

function timeGetTime: DWORD;

implementation

uses
  SysUtils;

function timeGetTime: DWORD;
begin
  Result := GetTickCount64;
end;

end.


