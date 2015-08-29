program exectext;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  Classes;

var
  f, s: string;
  sl: TStringList;
  i: Integer;
  ProgramDir: String;
begin
  ProgramDir:= ExtractFilePath(ParamStr(0));
  f := ProgramDir + 'exectext.conf';
  if FileExists(f) then
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
  //Readln;
end.
