unit frmCalendarU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TfrmCalendar = class(TForm)
    grdCal: TMonthCalendar;
    edtDate: TDateTimePicker;
    btnOk: TButton;
    procedure edtDateChange(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure grdCalClick(Sender: TObject);
    procedure edtDateKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
    Res: Boolean;
    ResultStr: string;
    procedure setInitValue(s: string; sv: TDate = 0);
  end;

var
  frmCalendar: TfrmCalendar;

implementation

{$R *.dfm}

procedure TfrmCalendar.btnOkClick(Sender: TObject);
begin
  ResultStr := FormatDateTime('yyyy/mm/dd', edtDate.Date);
  Res := True;
  Close;
end;

procedure TfrmCalendar.edtDateChange(Sender: TObject);
begin
  grdCal.Date := edtDate.Date;
end;

procedure TfrmCalendar.edtDateKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    btnOkClick(nil);
  end;
end;

procedure TfrmCalendar.FormCreate(Sender: TObject);
begin
  setInitValue('', Now);
end;

procedure TfrmCalendar.FormShow(Sender: TObject);
begin
  ResultStr := '';
  Res := False;
end;

procedure TfrmCalendar.grdCalClick(Sender: TObject);
begin
  edtDate.Date := grdCal.Date;
end;

procedure TfrmCalendar.setInitValue(s: string; sv: TDate);
begin
  if s <> '' then
  begin
    try
      sv := VarToDateTime(s);
    except
      sv := Now;
    end;
  end;
  if sv = 0 then sv := Now;
  grdCal.Date := sv;
  edtDate.Date := sv;
end;

end.
