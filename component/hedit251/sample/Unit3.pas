unit Unit3;

interface

uses
  Classes, Forms, heClasses, heFountain, HEdtProp, DelphiFountain,
  HTMLFountain;

type
  TProps = class(TDataModule)
    DelphiFountain1: TDelphiFountain;
    HTMLFountain1: THTMLFountain;
    EditorProp_Delphi: TEditorProp;
    EditorProp_HTML: TEditorProp;
    EditorProp_Default: TEditorProp;
    procedure PropsCreate(Sender: TObject);
  public
    function Fountain(const FileExt: String): TFountain;
    function EditorProp(const FileExt: String): TEditorProp;
    procedure WriteIni;
    procedure ReadIni;
  end;

var
  Props: TProps;

implementation

{$R *.DFM}

uses
  SysUtils;

(*
  EditorProp_Delphi は DelphiFountain1 に対応するファイル拡張子と
  プロパティが設定されている。
  EditorProp_HTML は同様に HTMLFountain1 に対応している。
  EditorProp_Default は、それ以外のファイルが開かれた時のデフォルトの設定。
*)

function TProps.Fountain(const FileExt: String): TFountain;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ComponentCount - 1 do
    if (Components[I] is TFountain) and
       TFountain(Components[I]).HasExt(FileExt) then
    begin
      Result := TFountain(Components[I]);
      Exit;
    end;
end;

function TProps.EditorProp(const FileExt: String): TEditorProp;
var
  I: Integer;
begin
  Result := EditorProp_Default;
  if FileExt = '' then
    Exit;
  for I := 0 to ComponentCount - 1 do
    if (Components[I] is TEditorProp) and
       TEditorProp(Components[I]).HasExt(FileExt) then
    begin
      Result := TEditorProp(Components[I]);
      Exit;
    end;
end;

procedure TProps.WriteIni;
var
  I: Integer;
begin
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TStoreComponent then
      TStoreComponent(Components[I]).WriteIni(
        ChangeFileExt(Application.ExeName, '.ini'),
        Components[I].Name, 'prop');
end;

procedure TProps.ReadIni;
var
  I: Integer;
begin
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TStoreComponent then
      TStoreComponent(Components[I]).ReadIni(
        ChangeFileExt(Application.ExeName, '.ini'),
        Components[I].Name, 'prop');
end;

procedure TProps.PropsCreate(Sender: TObject);
begin
  ReadIni;
end;

end.

