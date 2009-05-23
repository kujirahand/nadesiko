unit kuBenri;

interface

uses
  Windows, SysUtils, Classes;

function JoinStr(list:TStringList; delimiter: string): string;
function DumpStr(raw: RawByteString): string;
function GetLastErrorStr(ErrorCode: Integer): String;
function YesNoDialog(Question: string; Title: string = ''; Handle: THandle = 0): Boolean;

implementation

function YesNoDialog(Question: string; Title: string = ''; Handle: THandle = 0): Boolean;
var
  i: Integer;
begin
  if Title = '' then Title := '‚¨‘I‚Ñ‚­‚¾‚³‚¢';
  i := MessageBox(Handle, PWideChar(Question), PWideChar(Title), MB_YESNO or MB_ICONQUESTION);
  Result := (i = ID_YES);
end;

function GetLastErrorStr(ErrorCode: Integer): String;
const
  MAX_MES = 1024;
var
  Buf: PChar;
begin
  Buf := AllocMem(MAX_MES);
  try
    FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, ErrorCode,
                  MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                  Buf, MAX_MES, nil);
  finally
    Result := Buf;
    FreeMem(Buf);
  end;
end;

function JoinStr(list:TStringList; delimiter: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to list.Count - 1 do
  begin
    Result := Result + list.Strings[i];
    if i <> (list.Count - 1) then
    begin
      Result := Result + delimiter;
    end;
  end;
end;

function DumpStr(raw: RawByteString): string;
var
  i: Integer;
const
  LineCount = 16;
begin
  Result := '';
  for i := 1 to Length(raw) do
  begin
    Result := Result + '$' + IntToHex(Ord(raw[i]), 2);
    Result := Result + '[' + string(raw[i]) + ']';
    //
    if (i Mod LineCount) = (LineCount - 1) then
    begin
      Result := Result + #13#10;
    end else
    begin
      Result := Result + ',';
    end;
  end;
end;

end.
