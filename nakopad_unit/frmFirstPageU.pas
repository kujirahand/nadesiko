unit frmFirstPageU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmFirst = class(TForm)
    Panel1: TPanel;
    chkNoMore: TCheckBox;
    lstFirst: TListBox;
    procedure chkNoMoreClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lstFirstDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lstFirstDblClick(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

const
  FFirstGuide = 'tools\first.txt';

var
  frmFirst: TfrmFirst;

implementation

uses frmNakopadU, StrUnit;

{$R *.dfm}

procedure TfrmFirst.chkNoMoreClick(Sender: TObject);
begin
  frmNakopad.IniMain.WriteBool(
    'frmFirst', 'NoMorePage', chkNoMore.Checked);
end;

procedure TfrmFirst.FormShow(Sender: TObject);
begin
  frmNakopad.selectFileLoadAppOrUser(FFirstGuide, lstFirst.Items);
end;

procedure TfrmFirst.lstFirstDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  c: TCanvas;
  n, txt: string;
  x: Integer;
begin
  txt := lstFirst.Items.Strings[Index];
  n := GetToken(',', txt);
  c := lstFirst.Canvas;
  x := 10;
  if (Copy(n,1,1) = '+') then begin
    c.Brush.Color := RGB(255,200,200);
    c.Font.Color := clWhite;
  end else begin
    x := 30;
    c.Brush.Color := clWhite;
    c.Pen.Color := clBlue;
  end;
  c.Pen.Style := psSolid;
  c.Pen.Width := 1;
  c.Pen.Color := clWhite;
  c.Rectangle(Rect);
  c.Font.Color := clBlue;
  c.TextOut(Rect.Left+3+x, Rect.Top + 3, n);
  //
  
end;

procedure TfrmFirst.lstFirstDblClick(Sender: TObject);
var
  i: Integer;
  s: string;
begin
  i := lstFirst.ItemIndex;
  if (i < 0) then Exit;
  s := lstFirst.Items[i];
  if (s = '') then exit;
  GetToken(',', s);
  s := Trim(s);
  frmNakopad.RunTool(s);
end;

end.



