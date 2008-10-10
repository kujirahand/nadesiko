unit unit_dll_helper;
// -----------------------------------------------------------------------------
// プラグインのDLL読み込みをサポートするユニット
// -----------------------------------------------------------------------------

interface

uses
  SysUtils;

function NakoDLlLoadLibrary(dllname:string): THandle;

implementation

function NakoDLlLoadLibrary(dllname:string): THandle;
begin
  Result := 0;
end;

end.
