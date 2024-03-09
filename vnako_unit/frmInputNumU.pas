unit frmInputNumU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TfrmInputNum = class(TForm)
    lblInfo: TLabel;
    edtMain: TEdit;
    btnCalc: TButton;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    btnPlus: TButton;
    btnMinus: TButton;
    btnMul: TButton;
    btnDiv: TButton;
    btnOk: TButton;
    btnCancel: TButton;
    btnEq: TButton;
    btnMod: TButton;
    btnUp: TButton;
    btnDown: TButton;
    btnHint: TButton;
    btnClear: TButton;
    procedure BbtnNumClick(Sender: TObject);
    procedure btnCalcClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnHintClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure edtMainKeyPress(Sender: TObject; var Key: Char);
    procedure btnClearClick(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
    res: Boolean;
  end;

var
  frmInputNum: TfrmInputNum;

implementation

uses dnako_import, dnako_import_types;

{$R *.dfm}

procedure TfrmInputNum.BbtnNumClick(Sender: TObject);
var
  cap: string;
begin
  cap := TButton(Sender).Caption;
  if edtMain.Text = '0' then edtMain.Text := '';
  edtMain.Text := edtMain.Text + cap;
end;

procedure TfrmInputNum.btnCalcClick(Sender: TObject);
var
  s: string;
  ret: PHiValue;
begin
  // 計算
  s := edtMain.Text;
  if nako_evalEx(PAnsiChar(s), ret) then
  begin
    edtMain.Text := hi_str(ret);
  end;
end;

procedure TfrmInputNum.btnOkClick(Sender: TObject);
begin
  btnCalcClick(nil);
  res := True;
  Close;
end;

procedure TfrmInputNum.btnCancelClick(Sender: TObject);
begin
  res := False;
  Close;
end;

procedure TfrmInputNum.FormShow(Sender: TObject);
begin
  res := False;
end;

procedure TfrmInputNum.btnHintClick(Sender: TObject);
begin
  ShowMessage('数字や計算式が入力できます。'#13#10+
  '計算機能は、カッコ(..)やSINやCOSなどの関数も使えます。');
end;

procedure TfrmInputNum.btnUpClick(Sender: TObject);
begin
  edtMain.Text := edtMain.Text + '+1';
  btnCalcClick(nil);
end;

procedure TfrmInputNum.btnDownClick(Sender: TObject);
begin
  edtMain.Text := edtMain.Text + '-1';
  btnCalcClick(nil);
end;

procedure TfrmInputNum.edtMainKeyPress(Sender: TObject; var Key: Char);
var
  i: Integer;
  f: Boolean;
  s: string;
begin
  if Key = #13 then
  begin
    Key := #0;
    f := True;
    for i := 2 to Length(edtMain.Text) do
    begin
      s := Copy(edtMain.Text,i,1);
      if (('0' <= s) and ( s <= '9')) or (s = '.') then
      begin
        Continue;
      end;
      f := False;
      Break;
    end;
    if f = False then
      btnCalcClick(nil)
    else
      btnOkClick(nil);
  end;
end;

procedure TfrmInputNum.btnClearClick(Sender: TObject);
begin
  edtMain.Clear;
end;

end.
