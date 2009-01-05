unit frmExeListU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmExe = class(TForm)
    lstExe: TListBox;
    Panel1: TPanel;
    btnContinue: TButton;
    btnKill: TButton;
    btnUpdate: TButton;
    procedure btnContinueClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnKillClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
    function checkExe:Boolean;
  end;

var
  frmExe: TfrmExe;

implementation

uses unit_process32, frmInstallU, unit_getmsg;

{$R *.dfm}

procedure TfrmExe.btnContinueClick(Sender: TObject);
begin
  if checkExe = False then
  begin
    ShowMessage('申し訳ありません。'#13#10+
      '終了させないとインストールに失敗する可能性があります。'#13#10+
      'お手数ですが、終了させるか強制終了させてください。');
    Exit;
  end;
end;

procedure TfrmExe.FormShow(Sender: TObject);
begin
  try
    lstExe.ItemIndex := 0;
  except
  end;
end;

procedure TfrmExe.btnKillClick(Sender: TObject);
var
  pid: THandle;
  name: string;
begin
  if lstExe.ItemIndex < 0 then Exit;
  name := lstExe.Items.Strings[lstExe.ItemIndex];
  pid := GetPidFromName(name);
  if pid > 0 then
  begin
    if DeleteProcess(pid) then
    begin
    end;
  end;
  sleep(100);
  Application.ProcessMessages;
  sleep(100);
  //
  if checkExe then
  begin
    Close;
  end;
end;

function TfrmExe.checkExe:Boolean;
var
  i: Integer;
  s,list: string;
  sl: TStringList;
begin
  list := '';
  Result := True;
  sl := GetProcessList;
  for i := 1 to 999 do
  begin
    s := frmNakoInstaller.ini.ReadString('checkexe', IntToStr(i), '');
    if s = '' then Break;
    // check
    if sl.IndexOf(s) >= 0 then
    begin
      Result := False;
      list := list + s + #13#10;
    end;
  end;
  FreeAndNil(sl);
  if Result = false then
  begin
    lstExe.Items.Text := list;
    lstExe.ItemIndex := 0;
  end;
end;

procedure TfrmExe.btnUpdateClick(Sender: TObject);
begin
  if checkExe then Close;
end;

procedure TfrmExe.FormCreate(Sender: TObject);
begin
  btnUpdate.Caption := getMsg('Update List');
  btnKill.Caption := getMsg('Kill App');
  btnContinue.Caption := getMsg('Continue App');
  Self.Caption := getMsg('Please Quit Application');
end;

end.
