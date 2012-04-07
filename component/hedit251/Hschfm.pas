unit HSchfm;

{$I heverdef.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, HTSearch;

type
  TFormSearch = class(TForm)
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    Label1: TLabel;
    RadioGroup1: TRadioGroup;
    ComboBox1: TComboBox;
    btnHelp: TBitBtn;
    GroupBox1: TGroupBox;
    chkMatchCase: TCheckBox;
    chkWholeWord: TCheckBox;
    chkNoMatchZenkaku: TCheckBox;
    chkIncludeCRLF: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    FSearchValue: String;
    function GetOptions: TSearchOptions;
    procedure ReadReg;
    procedure WriteReg;
  public
    class function Execute(var SearchValue: String; var Options:
        TSearchOptions): Boolean;
  end;

var
  FormSearch: TFormSearch;

implementation

{$R *.DFM}

uses
  Registry;

const
  SearchItemsMax = 32;

class function TFormSearch.Execute(var SearchValue: String; var Options:
    TSearchOptions): Boolean;
begin
  Result := False;
  SearchValue := '';
  Options := [];
  with TFormSearch.Create(Application) do
  try
    if (ShowModal = mrOk) and (FSearchValue <> '') then
    begin
      Result := True;
      SearchValue := FSearchValue;
      Options := GetOptions;
    end;
  finally
    Free;
  end;
end;

procedure TFormSearch.FormShow(Sender: TObject);
begin
  FSearchValue := '';
  ReadReg;
  if ComboBox1.Items.Count > 0 then
    ComboBox1.ItemIndex := 0;
  ComboBox1.SetFocus;
end;

function TFormSearch.GetOptions: TSearchOptions;
begin
  Result := [];
  if chkWholeWord.Checked then
    Include(Result, sfrWholeWord);
  if chkMatchCase.Checked then
    Include(Result, sfrMatchCase);
  if chkNoMatchZenkaku.Checked then
    Include(Result, sfrNoMatchZenkaku);
  if RadioGroup1.ItemIndex = 1 then
    Include(Result, sfrDown);
  if chkIncludeCRLF.Checked then
  begin
    Include(Result, sfrIncludeCRLF);
    Include(Result, sfrIncludeSpace);
  end;
end;

procedure TFormSearch.btnOKClick(Sender: TObject);
var
  I: Integer;
begin
  with ComboBox1 do
  begin
    if Text <> '' then
    begin
      FSearchValue := Text;
      for I := 0 to Items.Count - 1 do
        if Items[I] = Text then
        begin
          Items.Delete(I);
          Break;
        end;
      Items.Insert(0, FSearchValue);
      if Items.Count > SearchItemsMax then
        Items.Delete(Items.Count - 1);
      Text := FSearchValue;
    end;
  end;
  WriteReg;
end;

procedure TFormSearch.ReadReg;
var
  Reg: TRegIniFile;
begin
  Reg := TRegIniFile.Create(
         '\Software\katsuhiko.honda\Delphi\TStrings Property Editor');
  try
    ChkMatchCase.Checked := Reg.ReadBool('Options', 'MatchCase', False);
    ChkWholeWord.Checked := Reg.ReadBool('Options', 'WholeWord', False);
    ChkNoMatchZenkaku.Checked := Reg.ReadBool('Options', 'NoMatchZenkaku', False);
    ChkIncludeCRLF.Checked := Reg.ReadBool('Options', 'IncludeCRLF', False);
    RadioGroup1.ItemIndex := Reg.ReadInteger('Options', 'Direction', 1);
    ComboBox1.Items.Text := Reg.ReadString('SearchItems', 'Text', '');
  finally
    Reg.Free;
  end;
end;

procedure TFormSearch.WriteReg;
var
  Reg: TRegIniFile;
begin
  Reg := TRegIniFile.Create(
         '\Software\katsuhiko.honda\Delphi\TStrings Property Editor');
  try
    Reg.WriteBool('Options', 'MatchCase', ChkMatchCase.Checked);
    Reg.WriteBool('Options', 'WholeWord', ChkWholeWord.Checked);
    Reg.WriteBool('Options', 'NoMatchZenkaku', ChkNoMatchZenkaku.Checked);
    Reg.WriteBool('Options', 'IncludeCRLF', ChkIncludeCRLF.Checked);
    Reg.WriteInteger('Options', 'Direction', RadioGroup1.ItemIndex);
    Reg.WriteString('SearchItems', 'Text', ComboBox1.Items.Text);
  finally
    Reg.Free;
  end;
end;

end.

