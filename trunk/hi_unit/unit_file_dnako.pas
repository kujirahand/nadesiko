unit unit_file_dnako;
//------------------------------------------------------------------------------
// ファイル入出力に関する汎用的なユニット(mini)
// [作成] クジラ飛行机
// [連絡] http://kujirahand.com
// [日付] 2004/07/28
//
interface

uses
  Windows, SysUtils, hima_types;

type
  TWindowState = (wsNormal, wsMinimized, wsMaximized);

// 文字列にファイルの内容を全部開く
function FileLoadAll(Filename: string): string;

// 文字列にファイルの内容を全部書き込む
procedure FileSaveAll(s, Filename: string);

implementation

uses
  unit_windows_api, unit_string;

// 文字列にファイルの内容を全部開く
function FileLoadAll(Filename: string): string;
var
  f: THandle;
  size, rsize: DWORD;
begin
  // open
  f := CreateFile(PChar(Filename), GENERIC_READ, FILE_SHARE_READ, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN,0);
  if f = INVALID_HANDLE_VALUE then
    raise EInOutError.Create('ファイル"' + Filename + '"が開けません。' + GetLastErrorStr);
  try
    // set pointer
    SetFilePointer(f, 0, nil, FILE_BEGIN); // 初めからゼロの位置に

    // read
    size := GetFileSize(f, nil); // 4G 以下限定
    SetLength(Result, size);
    if not ReadFile(f, Result[1], size, rsize, nil) then
    begin // 失敗
      raise EInOutError.Create('ファイル"' + Filename + '"の読み取りに失敗しました。' + GetLastErrorStr);
    end;
  finally
    // close
    CloseHandle(f);
  end;
end;

// 文字列にファイルの内容を全部書き込む
procedure FileSaveAll(s, Filename: string);
var
  f: THandle;
  size, rsize: DWORD;
begin
  // open
  f := CreateFile(PChar(Filename), GENERIC_WRITE, 0, nil,
    CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN,0);
  if f = INVALID_HANDLE_VALUE then
    raise EInOutError.Create('ファイル"' + Filename + '"が開けません。' + GetLastErrorStr);
  try
    // set pointer
    SetFilePointer(f, 0, nil, FILE_BEGIN); // 初めからゼロの位置に

    // write
    size := Length(s);
    if size > 0 then
    begin
      if not WriteFile(f, s[1], size, rsize, nil) then
      begin // 失敗
        raise EInOutError.Create('ファイル"' + Filename + '"の読み取りに失敗しました。' + GetLastErrorStr);
      end;
    end;
  finally
    // close
    CloseHandle(f);
  end;
end;

end.
