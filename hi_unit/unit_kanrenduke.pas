unit unit_kanrenduke;

interface

uses
  SysUtils, Windows, Registry;

// �֘A�t�����s��
function Kanrenduke(ext, app: string; description: string = ''): Boolean;
// �֘A�t������������
function KanrendukeKaijo(ext: string): Boolean;

implementation

function Kanrenduke(ext, app: string; description: string = ''): Boolean;
var
  reg: TRegistry;
  extKey, oldKey: string;
begin
  Result := True;
  //
  ext := LowerCase(ext);
  if Copy(ext,1,1) <> '.' then ext := '.' + ext;
  extKey := 'Nadesiko' + ext;
  //
  reg := TRegistry.Create;
  try
    //--- �g���q�̃G���g��
    reg.RootKey := HKEY_CLASSES_ROOT;
    if not reg.OpenKey(ext, True) then
    begin
      Result := False; Exit;
    end;
    if reg.ValueExists('') then
    begin
      oldKey := reg.ReadString('');
      if oldKey <> extKey then // ���ɃL�[������Αޔ����Ă���
      begin
        reg.WriteString('oldKey', oldKey);
      end;
    end;
    reg.WriteString('', extKey);
    reg.CloseKey;
    //---------------------------------------------
    //--- �g���q����
    if not reg.OpenKey(extKey, True) then begin Result := False; Exit; end;
    if description <> '' then reg.WriteString('', description);
    reg.CloseKey;
    // �f�t�H���g�A�C�R��
    if not reg.OpenKey(extKey + '\DefaultIcon', True) then begin Result := False; Exit; end;
    reg.WriteString('','"' + app + '"');
    reg.CloseKey;
    // �A�v���̊֘A�t��
    if not reg.OpenKey(extKey + '\shell\open\command', True) then begin Result := False; Exit; end;
    reg.WriteString('','"' + app + '" "%1"');
    reg.CloseKey;
  finally
    reg.Free;
  end;
end;

function KanrendukeKaijo(ext: string): Boolean;
var
  reg: TRegistry;
  oldKey, extKey: string;
begin
  Result := True;
  //
  ext := LowerCase(ext);
  if Copy(ext,1,1) <> '.' then ext := '.' + ext;
  extKey := 'Nadesiko' + ext;
  //
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CLASSES_ROOT;
    if not reg.KeyExists(extKey) then Exit;
    reg.DeleteKey(extKey);
    // old�����邩�H
    if not reg.OpenKey(ext, False) then Exit;
    if reg.ValueExists('oldKey') then
    begin
      oldKey := reg.ReadString('oldKey');
      reg.DeleteValue('oldKey');
      reg.WriteString('', oldKey);
    end else
    begin
      // old���Ȃ���΃G���g�����̂��폜���Ă��܂�
      reg.DeleteKey(ext);
    end;
  finally
    reg.Free;
  end;
end;

end.
