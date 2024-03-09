library nakoctrl;

uses
  FastMM4 in 'FastMM4.pas',
  Windows, SysUtils, Classes,
  unit_string in 'hi_unit\unit_string.pas',
  hima_types in 'hi_unit\hima_types.pas',
  mt19937 in 'hi_unit\mt19937.pas',

  dll_plugin_helper in 'hi_unit\dll_plugin_helper.pas',
  dnako_import in 'hi_unit\dnako_import.pas',
  dnako_import_types in 'hi_unit\dnako_import_types.pas',
  StrUnit in 'hi_unit\strunit.pas',
  dll_ctrl_function in 'hi_unit\dll_ctrl_function.pas',
  vbfunc in 'hi_unit\vbfunc.pas',
  EasyMasks in 'hi_unit\EasyMasks.pas',
  WinRestartUnit in 'hi_unit\WinRestartUnit.pas',
  unit_ctrl in 'hi_unit\unit_ctrl.pas',
  CpuUtils in 'hi_unit\CpuUtils.pas',
  unit_process32 in 'hi_unit\unit_process32.pas',
  HotKeyManager in 'hi_unit\HotKeyManager.pas',
  hima_hotkey_manager in 'hi_unit\hima_hotkey_manager.pas',
  CommonMemoryUnit in 'hi_unit\CommonMemoryUnit.pas';

//------------------------------------------------------------------------------
// Plug-in import function
procedure ImportNakoFunction; stdcall;
begin
  RegistFunction;
end;

//------------------------------------------------------------------------------
// �v���O�C���̏��
function PluginInfo(str: PChar; len: Integer): Integer; stdcall;
const STR_INFO = '���̃\�t�g����v���O�C�� by �N�W����s��';
begin
  Result := Length(STR_INFO);
  if (str <> nil)and(len > 0) then
  begin
    StrLCopy(str, STR_INFO, len);
  end;
end;

//------------------------------------------------------------------------------
// �v���O�C���̃o�[�W����
function PluginVersion: DWORD; stdcall;
begin
  Result := 2;
end;

//------------------------------------------------------------------------------
// �Ȃł����v���O�C���o�[�W����
function PluginRequire: DWORD; stdcall;
begin
  Result := 2;
end;

procedure PluginInit(Handle: DWORD); stdcall;
begin
  dnako_import_initFunctions(Handle);
end;
function PluginFin: DWORD; stdcall;
begin
  Result := 0;
end;

exports
  ImportNakoFunction,
  PluginInfo,
  PluginVersion,
  PluginRequire,
  PluginInit;

begin
end.
