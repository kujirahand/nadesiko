unit HReplfm;

{$I heverdef.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, HTSearch;

type
  TFormReplace = class(TForm)
    btnOK: TBitBtn;
    btnAll: TBitBtn;
    Label1: TLabel;
    RadioGroup1: TRadioGroup;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Label2: TLabel;
    btnCancel: TBitBtn;
    btnHelp: TBitBtn;
    GroupBox1: TGroupBox;
    chkWholeWord: TCheckBox;
    chkMatchCase: TCheckBox;
    chkNoMatchZenkaku: TCheckBox;
    chkIncludeCRLF: TCheckBox;
    chkReplaceConfirm: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnAllClick(Sender: TObject);
  private
    FSearchValue: String;
    FReplaceValue: String;
    FSearchOptions: TSearchOptions;
    function GetOptions: TSearchOptions;
    procedure ComboUpdate;
    procedure ReadReg;
    procedure WriteReg;
  public
    class function Execute(var SearchValue, ReplaceValue: String;
      var Options: TSearchOptions): Boolean;
  end;

var
  FormReplace: TFormReplace;

implementation

{$R *.DFM}

uses
  Registry;

const
  SearchItemsMax = 32;

class function TFormReplace.Execute(var SearchValue, ReplaceValue: String;
    var Options: TSearchOptions): Boolean;
var
  MR: TModalResult;
begin
  Result := False;
  SearchValue := '';
  ReplaceValue := '';
  Options := [];
  with TFormReplace.Create(Application) do
  try
    MR := ShowModal;
    if ((MR = mrOk) or (MR = 8)) and
       (FSearchValue <> '') and (FReplaceValue <> '') then
    begin
      Result := True;
      SearchValue := FSearchValue;
      ReplaceValue := FReplaceValue;
      Options := GetOptions;
    end;
  finally
    Free;
  end;
end;

procedure TFormReplace.FormShow(Sender: TObject);
begin
  FSearchValue := '';
  FReplaceValue := '';
  FSearchOptions := [];
  ReadReg;
  chkReplaceConfirm.Checked := True;
  if ComboBox1.Items.Count > 0 then
    ComboBox1.ItemIndex := 0;
  ComboBox2.Text := '';
  ComboBox1.SetFocus;
end;

function TFormReplace.GetOptions: TSearchOptions;
begin
  Result := FSearchOptions;
  if chkWholeWord.Checked then
    Include(Result, sfrWholeWord);
  if chkMatchCase.Checked then
    Include(Result, sfrMatchCase);
  if chkNoMatchZenkaku.Checked then
    Include(Result, sfrNoMatchZenkaku);
  if chkReplaceConfirm.Checked then
    Include(Result, sfrReplaceConfirm);
  if RadioGroup1.ItemIndex = 1 then
    Include(Result, sfrDown);
  if chkIncludeCRLF.Checked then
  begin
    Include(Result, sfrIncludeCRLF);
    Include(Result, sfrIncludeSpace);
  end;
end;

procedure TFormReplace.ComboUpdate;
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
          break;
        end;
      Items.Insert(0,FSearchValue);
      if Items.Count > SearchItemsMax then
        Items.Delete(Items.Count - 1);
      Text := FSearchValue;
    end;
  end;
  with ComboBox2 do
  begin
    if Text <> '' then
    begin
      FReplaceValue := Text;
      for I := 0 to Items.Count - 1 do
        if Items[I] = Text then
        begin
          Items.Delete(I);
          break;
        end;
      Items.Insert(0, FReplaceValue);
      if Items.Count > SearchItemsMax then
        Items.Delete(Items.Count - 1);
      Text := FReplaceValue;
    end;
  end;
  WriteReg;
end;

procedure TFormReplace.ReadReg;
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
    ComboBox2.Items.Text := Reg.ReadString('ReplaceItems', 'Text', '');
  finally
    Reg.Free;
  end;
end;

procedure TFormReplace.WriteReg;
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
    Reg.WriteString('ReplaceItems', 'Text', ComboBox2.Items.Text);
  finally
    Reg.Free;
  end;
end;

procedure TFormReplace.btnOKClick(Sender: TObject);
begin
  ComboUpdate;
  Include(FSearchOptions, sfrReplace);
end;

procedure TFormReplace.btnAllClick(Sender: TObject);
begin
  ComboUpdate;
  Include(FSearchOptions, sfrReplaceAll);
end;

end.

