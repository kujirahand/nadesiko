program exectext;

{$APPTYPE GUI}

uses
  Windows,
  SysUtils,
  Classes;


procedure go(f: string);
var
  s: string;
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.LoadFromFile(f);
    s := Trim(sl.Text);
    WinExec(PChar(s), SW_SHOW);
  finally
    sl.Free;
  end;
end;


var
  ProgramDir: string;
  config: string;
  f: string;
begin
  config := ParamStr(0);
  config := StringReplace(config, '.exe', '.conf', []);
  if FileExists(config) then begin
    go(config);
  end else begin
    ProgramDir:= ExtractFilePath(ParamStr(0));
    f := ProgramDir + 'exectext.conf';
    if FileExists(f) then begin
      go(f);
    end else begin
        MessageBox(0, 'No config', 'No Config', MB_OK);
    end;
  end;
end.

