unit Unit1;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, StdCtrls;

type
	TForm1 = class(TForm)
		GroupBox1: TGroupBox;
		OpenDialog1: TOpenDialog;
		GroupBox2: TGroupBox;
		Edit2: TEdit;
		GroupBox3: TGroupBox;
		Edit3: TEdit;
		GroupBox4: TGroupBox;
		Edit4: TEdit;
		GroupBox5: TGroupBox;
		Edit5: TEdit;
		Memo1: TMemo;
		Button1: TButton;
		Button2: TButton;
		Edit1: TEdit;
		procedure Button1Click(Sender: TObject);
		procedure Button2Click(Sender: TObject);
	private
		{ Private êÈåæ }
	public
		{ Public êÈåæ }
	end;

var
	Form1: TForm1;

implementation

{$R *.dfm}

uses
	sMEdiaTagReader;

procedure TForm1.Button1Click(Sender: TObject);
var
	tag: TsMediaTagReader;
	list: TStringList;
	i: Integer;
begin
	tag := TsMediaTagReader.Create();
	try
		OpenDialog1.Execute();
		tag.LoadFromFile(OpenDialog1.FileName);
		Edit1.Text := tag['Title'];
		Edit2.Text := tag['Artist'];
		Edit3.Text := tag['Album'];
		Edit4.Text := tag['Year'];
		Edit5.Text := tag['Comment'];
		list := tag.EnumProperties();
		list.Sort();
		Memo1.Lines.Clear();
		for i := 0 to list.Count-1 do begin
			Memo1.Lines.Append('=-=-=-=-=-=-=-=-=');
			Memo1.Lines.Append(list[i]);
			Memo1.Lines.Append('=-=-=-=-=-=-=-=-=');
			Memo1.Lines.Append(tag[list[i]]);
			Memo1.Lines.Append('');
		end;
		self.Caption := OpenDialog1.FileName;
		Button2.Enabled := True;
	finally
		tag.Free();
	end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
	tag: TsMediaTagReader;
begin
	tag := TsMediaTagReader.Create();
	try
		tag.LoadFromFile(self.Caption);
		tag['Title'] := Edit1.Text;
		tag['Artist'] := Edit2.Text;
		tag['Album'] := Edit3.Text;
		tag['Year'] := Edit4.Text;
		tag['Comment'] := Edit5.Text;
		if tag.SaveToFile(self.Caption) then ShowMessage('èëÇ´çûÇ›Ç‹ÇµÇΩ');
	finally
		tag.Free();
	end;
end;

end.
