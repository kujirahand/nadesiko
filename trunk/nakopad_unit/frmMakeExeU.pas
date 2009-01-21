unit frmMakeExeU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, fileDrop;

type
  TfrmMakeExe = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    lstFiles: TListBox;
    Label1: TLabel;
    btnAddFiles: TButton;
    btnOK: TButton;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    btnIzon: TButton;
    btnClear: TButton;
    btnHelp: TButton;
    GroupBox1: TGroupBox;
    chkAngou: TCheckBox;
    chkIncludeDLL: TCheckBox;
    chkAngou3: TCheckBox;
    groupIcon: TGroupBox;
    imgIcon: TImage;
    dlgOpenIcon: TOpenDialog;
    procedure btnAddFilesClick(Sender: TObject);
    procedure FileDropFileDrop(Sender: TObject; Num: Integer;
      Files: TStrings; X, Y: Integer);
    procedure btnOKClick(Sender: TObject);
    procedure btnIzonClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure chkIncludeDLLClick(Sender: TObject);
    procedure imgIconClick(Sender: TObject);
  private
    { Private 宣言 }
    flagIconChange: Boolean;
    IconFile: string;
    procedure addIncludeFile(s: string);
  public
    { Public 宣言 }
    fdrop: TFileDrop;
  end;

var
  frmMakeExe: TfrmMakeExe;

implementation

uses frmNakopadU, unit_pack_files, StrUnit, gui_benri, Masks,
  unit_rewrite_icon;

{$R *.dfm}

procedure TfrmMakeExe.btnAddFilesClick(Sender: TObject);
var
  i: Integer;
begin
  if dlgOpen.Execute = False then Exit;
  for i := 0 to dlgOpen.Files.Count - 1 do
  begin
    addIncludeFile(dlgOpen.Files.Strings[i]);
  end;
end;

procedure TfrmMakeExe.FileDropFileDrop(Sender: TObject; Num: Integer;
  Files: TStrings; X, Y: Integer);
var
  i: Integer;
  s: string;
begin
  for i := 0 to Files.Count - 1 do
  begin
    s := Files.Strings[i];
    addIncludeFile(s);
  end;
end;


procedure TfrmMakeExe.btnOKClick(Sender: TObject);
var
  f,s: string;
  p: TFileMixWriter;
  i: Integer;
  tempExe: string;

  procedure _rewriteicon;
  var
    p: TIconChanger;
  begin
    if not flagIconChange then Exit;
    if frmNakopad.FNakoIndex = NAKO_CNAKO then Exit;
    //---
    p := TIconChanger.Create;
    try
      p.Change(tempExe, IconFile);
    finally
      p.Free;
    end;
  end;

  procedure _copyPlugins;
  var
    s, txt, src, des, desDir: string;
    l: TStringList;
    i: Integer;
  begin
    if chkIncludeDLL.Checked then Exit;
    desDir := ExtractFilePath(f) + 'plug-ins\';

    ReadTextFile(frmNakopad.ReportFile, txt);
    GetToken('[plug-ins]', txt);
    s := GetToken('[', txt);
    l := TStringList.Create;
    l.Text := s;
    for i := 0 to l.Count - 1 do
    begin
      s := Trim(l.Strings[i]);
      src := s;
      des := desDir + ExtractFileName(s);
      if FileExists(src) then
      begin
        ForceDirectories(ExtractFilePath(des));
        SHFileCopy(src, des);
      end;
    end;
    l.Free;
    // dnako.dll のコピー
    src := AppPath + 'plug-ins\dnako.dll';
    ForceDirectories(desDir);
    des := desDir + 'dnako.dll';
    SHFileCopy(src, des);
  end;

  function _angouka: string;
  begin
    if chkAngou3.Checked then
    begin
      Result := '3';
    end else
    if chkAngou.Checked then
    begin
      Result := '2';
    end else
    begin
      Result := '0';
    end;
  end;

begin
  if not dlgSave.Execute then Exit;
  f := dlgSave.FileName;
  if f='' then Exit;
  if
    (UpperCase(ExtractFileName(f)) = 'VNAKO.EXE') or
    (UpperCase(ExtractFileName(f)) = 'GNAKO.EXE') or
    (UpperCase(ExtractFileName(f)) = 'CNAKO.EXE')
  then begin
    ShowMessage('ランタイムを上書きすることはできません。'); Exit;
  end;

  // 梱包ファイルを作る
  p := TFileMixWriter.Create;
  frmNakopad.edtActive.Lines.SaveToFile(AppPath+'packfile.nako');
  p.FileList.Add(AppPath+'packfile.nako=nadesiko.nako='+_angouka);
  case frmNakopad.FNakoIndex of
    NAKO_VNAKO:
      begin
        p.FileList.Add(AppPath+'lib\vnako.nako=vnako.nako='+_angouka);
      end;
    NAKO_GNAKO:
      begin
        p.FileList.Add(AppPath+'lib\gnako.nako=gnako.nako='+_angouka);
        p.FileList.Add(AppPath+'lib\windows.nako=windows.nako='+_angouka);
      end;
    NAKO_CNAKO:
      begin
      end;
  end;
  for i := 0 to lstFiles.Count - 1 do
  begin
    s:=lstFiles.Items.Strings[i];
    p.FileList.Add(s+'='+ExtractFileName(s)+'='+_angouka);
  end;
  p.SaveToFile(AppPath+'packfile.bin');
  p.Free;

  // 保存
  case frmNakopad.FNakoIndex of
    NAKO_VNAKO:
      begin
        tempExe := AppPath + 'vnako.exe';
      end;
    NAKO_GNAKO:
      begin
        tempExe := AppPath + 'gnako.exe';
      end;
    NAKO_CNAKO:
      begin
        tempExe := AppPath + 'cnako.exe';
      end;
  end;

  _rewriteIcon;
  WritePackExeFile(f, tempExe, AppPath+'packfile.bin');

  //=========================
  // 依存ファイルのコピー
  _copyPlugins;

  if chkIncludeDLL.Checked then
  begin
    ShowMessage('実行ファイルを作成しました。'#13#10+
      '動的な命令『ナデシコする』などで利用している命令があれば、'#13#10+
      '再度、実行ファイル作成を行い手動でファイルを追加してください。'#13#10);
  end else
  begin
    ShowMessage(
      '実行ファイルを作成しました。'#13#10+
      '実行ファイルと "dnako.dll"に加え "plug-ins"フォルダを配布してください。'#13#10+
      '詳しくはヘルプをご覧ください。');
  end;

  //===
  Close;
end;

procedure TfrmMakeExe.btnIzonClick(Sender: TObject);
var
  s: string;
begin
  s := frmNakopad.ReportFile;
  if FileExists(s) then
  begin
    OpenApp(s);
  end else
  begin
    ShowMessage('標準GUIでプログラムを実行するとレポートが作成されます。');
  end;
end;

procedure TfrmMakeExe.btnClearClick(Sender: TObject);
begin
  lstFiles.Clear;
end;

procedure TfrmMakeExe.btnHelpClick(Sender: TObject);
begin
  OpenApp(AppPath + 'doc\reference\function\1-2-convexe.htm');
end;

procedure TfrmMakeExe.FormShow(Sender: TObject);
begin
  // レポートがあるか確認する
  if not FileExists(frmNakopad.ReportFile) then
  begin
    ShowMessage(
      '実行ファイル作成の前に必ず一度はプログラムを実行させてください。'#13#10+
      '実行によりプラグイン依存レポートが自動生成されます。');
  end;
end;

procedure TfrmMakeExe.FormCreate(Sender: TObject);
begin
  fdrop := TFileDrop.Create(self);
  fdrop.Control := lstFiles;
  fdrop.OnFileDrop := FileDropFileDrop;
  flagIconChange := False;
end;

procedure TfrmMakeExe.chkIncludeDLLClick(Sender: TObject);

  procedure _addPlugins(IsRemoveMode:Boolean);
  var
    s, txt, src: string;
    l: TStringList;
    i,j: Integer;
  begin
    ReadTextFile(frmNakopad.ReportFile, txt);
    GetToken('[plug-ins]', txt);
    s := GetToken('[', txt);
    l := TStringList.Create;
    l.Text := s + #13#10 + AppPath + 'plug-ins\dnako.dll';
    for i := 0 to l.Count - 1 do
    begin
      s := Trim(l.Strings[i]);
      src := s;
      if IsRemoveMode then
      begin
        j := lstFiles.Items.IndexOf(src);
        lstFiles.Items.Delete(j);
      end else
      begin
        if not FileExists(src) then
        begin
          src := AppPath + 'plug-ins\' + src;
        end;
        if FileExists(src) then
        begin
          if lstFiles.Items.IndexOf(src) < 0 then
            lstFiles.Items.Add(src);
        end;
      end;
    end;
    l.Free;
  end;

begin
  // DLLを梱包
  if not frmNakopad.isDelux then
  begin
    ShowMessage('すみません。デラックス版のみの機能です。');
    Exit;
  end;
  if chkIncludeDLL.Checked then
  begin
    _addPlugins(False);
  end else
  begin
    _addPlugins(True);
  end;
end;

procedure TfrmMakeExe.addIncludeFile(s: string);
begin
  if DirectoryExists(s) then
  begin
    Exit;
  end;
  // 念のため制限は緩くしておく
  // if not frmNakopad.isDelux then
  // begin
  //   if MatchesMask(s, '*.dll') then Exit;
  // end;
  if lstFiles.Items.IndexOf(s) < 0 then
    lstFiles.Items.Add(s);
end;

procedure TfrmMakeExe.imgIconClick(Sender: TObject);
begin
  if not frmNakopad.isDelux then
  begin
    ShowMessage('すみません。アイコンの変更はデラックス版のみの機能です。');
    Exit;
  end;
  if not dlgOpenIcon.Execute then Exit;
  imgIcon.Picture.LoadFromFile(dlgOpenIcon.FileName);
  flagIconChange := True;
  IconFile := dlgOpenIcon.FileName;
end;

end.
