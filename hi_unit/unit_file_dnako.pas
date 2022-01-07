unit unit_file_dnako;
//------------------------------------------------------------------------------
// �t�@�C�����o�͂Ɋւ���ėp�I�ȃ��j�b�g(mini)
// [�쐬] �N�W����s��
// [�A��] http://kujirahand.com
// [���t] 2004/07/28
//
interface

uses
  {$IFDEF Win32}
  Windows,
  {$ELSE}
  Classes,
  {$ENDIF}
  SysUtils, hima_types;

type
  TWindowState = (wsNormal, wsMinimized, wsMaximized);

// ������Ƀt�@�C���̓��e��S���J��
function FileLoadAll(Filename: string): AnsiString;

// ������Ƀt�@�C���̓��e��S����������
procedure FileSaveAll(s:AnsiString; Filename: string);

implementation

uses
  unit_windows_api, unit_string;

// ������Ƀt�@�C���̓��e��S���J��
function FileLoadAll(Filename: string): AnsiString;
{$IFDEF Win32}
var
  f: THandle;
  size, rsize: DWORD;
  err: string;
begin
  // open
  f := CreateFile(
        PChar(Filename),
        GENERIC_READ,
        FILE_SHARE_READ,
        nil,
        OPEN_EXISTING,
        FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN,
        0);
  if f = INVALID_HANDLE_VALUE then
  begin
    err := '�t�@�C��"' + string(Filename) + '"���J���܂���B' + GetLastErrorStr;
    raise EInOutError.Create(err);
  end;
  try
    // set pointer
    SetFilePointer(f, 0, nil, FILE_BEGIN); // ���߂���[���̈ʒu��
    // read
    size := GetFileSize(f, nil); // 4G �ȉ�����
    SetLength(Result, size);
    if not ReadFile(f, Result[1], size, rsize, nil) then
    begin // ���s
      raise EInOutError.Create('�t�@�C��"' + string(Filename) + '"�̓ǂݎ��Ɏ��s���܂����B' + GetLastErrorStr);
    end;
  finally
    // close
    CloseHandle(f);
  end;
end;
{$ELSE}
var
  s: TStringList;
begin
  s := TStringList.Create;
  s.LoadFromFile(Filename);
  Result := s.Text;
  s.Free;
end;
{$ENDIF}

// ������Ƀt�@�C���̓��e��S����������
procedure FileSaveAll(s:AnsiString; Filename: string);
{$IFDEF Win32}
var
  f: THandle;
  size, rsize: DWORD;
begin
  // open
  f := CreateFile(
        PChar(Filename),
        GENERIC_WRITE, 0, nil,
        CREATE_ALWAYS,
        FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN, 0);
  if f = INVALID_HANDLE_VALUE then
    raise EInOutError.Create(
      '�t�@�C��"' + string(Filename) + '"���J���܂���B' +
      GetLastErrorStr);
  try
    // set pointer
    SetFilePointer(f, 0, nil, FILE_BEGIN); // ���߂���[���̈ʒu��
    // write
    size := Length(s);
    if size > 0 then
    begin
      if not WriteFile(f, s[1], size, rsize, nil) then
      begin // ���s
        raise EInOutError.Create(
          '�t�@�C��"' + string(Filename) + '"�̓ǂݎ��Ɏ��s���܂����B' +
          GetLastErrorStr);
      end;
    end;
  finally
    // close
    CloseHandle(f);
  end;
end;
{$ELSE}
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  sl.Text := s;
  sl.SaveToFile(Filename);
  sl.Free;
end;
{$ENDIF}

end.
