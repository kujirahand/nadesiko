unit unit_fpc;

interface

type
  HWND = Integer;

function timeGetTime: DWORD;
function GetLastError(): Integer;

implementation

uses
  SysUtils;

function timeGetTime: DWORD;
begin
  Result := GetTickCount64;
end;

function GetLastError(): Integer;
begin
  Result := 0;
end;



end.


