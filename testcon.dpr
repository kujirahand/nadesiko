program testcon;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  wildcard2 in 'hi_unit\wildcard2.pas',
  unit_string2 in 'hi_unit\unit_string2.pas';

var
  pickup: TStringList = nil;
  str: string = '';
begin
  TestAll;
  //---
  writeln('ok');
  readln;
end.
