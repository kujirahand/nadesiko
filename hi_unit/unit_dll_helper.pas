unit unit_dll_helper;
// -----------------------------------------------------------------------------
// �v���O�C����DLL�ǂݍ��݂��T�|�[�g���郆�j�b�g
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
