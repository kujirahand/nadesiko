unit frmSelectButtonU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

const
  MAX_SELECT_BUTTON = 50;

type
  TfrmSelectButton = class(TForm)
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private 宣言 }
    button: array [0..MAX_SELECT_BUTTON-1] of TButton;
    procedure ClearButton;
    procedure ButtonClick(Sender: TObject);
  public
    { Public 宣言 }
    Result : string;
    IsCancel: Boolean;
    procedure MakeButton(msg,sel:string);
  end;

var
  frmSelectButton: TfrmSelectButton;

implementation

uses vnako_function, frmNakoU;

{$R *.dfm}

procedure TfrmSelectButton.ButtonClick(Sender: TObject);
begin
    Result := TButton(Sender).Caption ;
    IsCancel := False;
    Close;

end;

procedure TfrmSelectButton.ClearButton;
var
    i:Integer;
begin
    for i:=0 to MAX_SELECT_BUTTON-1 do
    begin
        if button[i] <> nil then
            button[i].Free;
        button[i] := nil;
    end;
end;

procedure TfrmSelectButton.FormCreate(Sender: TObject);
var
    i: Integer;
begin
    IsCancel := True;
    for i:=0 to MAX_SELECT_BUTTON-1 do
    begin
        button[i] := nil;
    end;
end;

procedure TfrmSelectButton.FormShow(Sender: TObject);
begin
    IsCancel := True;
end;

procedure TfrmSelectButton.MakeButton(msg, sel: string);
var
    sl: TSTringList;
    i,btn_height, btn_width,j,L: Integer;
begin
    Result:='';
    Caption := 'ボタン選択' ;
    getFont(Label1.Canvas);
    Font := Label1.Canvas.Font ;
    Label1.Caption := msg;
    btn_height := Trunc(Label1.Canvas.TextHeight('Z') * 2) ;
    sl := TStringList.Create;
    try
        sl.Text := Trim(sel);
        ClearButton;

        btn_width := 30;
        while sl.Count > MAX_SELECT_BUTTON do sl.Delete(sl.Count - 1); // 最大個数以下に抑える

        for i:=0 to sl.Count -1 do
        begin
            j := Label1.Canvas.TextWidth( sl.Strings[i] );
            if j > btn_width then btn_width := j;
        end;
        btn_width := Trunc(btn_width * 1.3);
        if Label1.Width < btn_width then
        begin
            Self.ClientWidth := 16 + BTN_WIDTH;
            L := 8;
        end else begin
            Self.ClientWidth := 16 + Label1.Width;
            L := (ClientWidth - btn_width) div 2;
        end;

        if (btn_width * sl.Count * 1.1) < (frmNako.Width * 0.8)then
        begin
            //横に表示
            for i:=0 to sl.Count -1 do
            begin
                button[i] := TButton.Create(Self);
                button[i].Parent := Self;
                button[i].Width := BTN_WIDTH;
                button[i].Height := Trunc(BTN_HEIGHT * 0.8);
                button[i].Left := Trunc(8 + btn_width * i * 1.1);
                button[i].Top := Label1.Top * 2 + Label1.Height{BTN_HEIGHT};
                button[i].Caption := sl.Strings[i];
                button[i].Font := Label1.Font;
                button[i].Visible := True;
                button[i].Show;
                button[i].OnClick := ButtonClick;
            end;
            if sl.Count = 1 then
                Self.ClientWidth := Trunc(16 + btn_width)
            else
                Self.ClientWidth := Trunc(16 + btn_width * sl.Count * 1.1);

            if (Label1.Width+Label1.Left) > Self.ClientWidth then
            begin
                Self.ClientWidth := Label1.Width + 8 + Label1.Left;
            end;
            Self.ClientHeight := BTN_HEIGHT + (Label1.Top * 2)+ Label1.Height;
            Top := (Screen.Height - Self.Height) div 2;
            Left := (Screen.Width - Self.Width) div 2;
        end else
        begin
            //縦に表示
            for i:=0 to sl.Count -1 do
            begin
                button[i] := TButton.Create(Self);
                button[i].Parent := Self;
                button[i].Width := BTN_WIDTH;
                button[i].Height := Trunc(BTN_HEIGHT * 0.8);
                button[i].Left := L;
                button[i].Top := (Label1.Top * 2)+ Label1.Height + i * BTN_HEIGHT;
                button[i].Caption := sl.Strings[i];
                button[i].Font := Label1.Font;
                button[i].Visible := True;
                button[i].Show;
                button[i].OnClick := ButtonClick;
            end;
            Self.ClientHeight := (Label1.Top*2 + Label1.Height + BTN_HEIGHT * (sl.Count));
            Top := (Screen.Height - Self.Height) div 2;
            Left := (Screen.Width - Self.Width) div 2;
            if Top < 0 then Top := 0;
        end;
    finally
        sl.Free;
    end;
end;

end.
