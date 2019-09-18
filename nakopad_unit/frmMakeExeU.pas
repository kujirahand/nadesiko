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
    { Private �錾 }
    flagIconChange: Boolean;
    IconFile: string;
    procedure addIncludeFile(s: string);
  public
    { Public �錾 }
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
  tempExe, temporaryExe, mainfile, packfile: string;

  procedure _rewriteicon(exefile: string);
  var
    p: TIconChanger;
  begin
    if not flagIconChange then Exit;
    if frmNakopad.FNakoIndex = NAKO_CNAKO then Exit;
    //---
    p := TIconChanger.Create;
    try
      p.Change(exefile, IconFile);
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
    // dnako.dll �̃R�s�[
    src := AppPath + 'plug-ins\dnako.dll';
    ForceDirectories(desDir);
    des := desDir + 'dnako.dll';
    SHFileCopy(src, des);
  end;

  function _angouka: string;
  begin
    if chkAngou3.Checked then
    begin
      Result := '6'; // <--- �Í��� �V�o�[�W����(�\�[�X����J�o�[�W����)
    end else
    if chkAngou.Checked then
    begin
      Result := '5'; // <--- �ɂ��Í���
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
    ShowMessage('�����^�C�����㏑�����邱�Ƃ͂ł��܂���B'); Exit;
  end;

  // ����t�@�C�������
  p := TFileMixWriter.Create;
  mainfile := getOriginalFileName(TempDir, 'main.nako');
  frmNakopad.edtActive.Lines.SaveToFile(mainfile);
  p.FileList.Add(mainfile+'=nadesiko.nako='+_angouka);
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
  packfile := getOriginalFileName(TempDir, 'nakpac.bin');
  p.SaveToFile(packfile);
  p.Free;

  // �ۑ�
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

  temporaryExe := TempDir + 'nako' + FormatDateTime('yymmddhhnnsszzz', Now) + '.exe';
  CopyFile(PChar(tempExe),PChar(temporaryExe), False);
  _rewriteIcon(temporaryExe);
  WritePackExeFile(f, temporaryExe, packfile);

  // ��n��
  DeleteFile(temporaryExe);
  DeleteFile(mainfile);
  DeleteFile(packfile);
  
  //=========================
  // �ˑ��t�@�C���̃R�s�[
  _copyPlugins;

  if chkIncludeDLL.Checked then
  begin
    ShowMessage('���s�t�@�C�����쐬���܂����B'#13#10+
      '���I�Ȗ��߁w�i�f�V�R����x�Ȃǂŗ��p���Ă��閽�߂�����΁A'#13#10+
      '�ēx�A���s�t�@�C���쐬���s���蓮�Ńt�@�C����ǉ����Ă��������B'#13#10);
  end else
  begin
    ShowMessage(
      '���s�t�@�C�����쐬���܂����B'#13#10+
      '���s�t�@�C���� "dnako.dll"�ɉ��� "plug-ins"�t�H���_��z�z���Ă��������B'#13#10+
      '�ڂ����̓w���v���������������B');
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
    ShowMessage('�W��GUI�Ńv���O���������s����ƃ��|�[�g���쐬����܂��B');
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
  // ���|�[�g�����邩�m�F����
  if not FileExists(frmNakopad.ReportFile) then
  begin
    ShowMessage(
      '���s�t�@�C���쐬�̑O�ɕK����x�̓v���O���������s�����Ă��������B'#13#10+
      '���s�ɂ��v���O�C���ˑ����|�[�g��������������܂��B');
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
  // DLL������
  if not frmNakopad.isDelux then
  begin
    ShowMessage('���݂܂���B�f���b�N�X�ł݂̂̋@�\�ł��B');
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
  // �O�̂��ߐ����͊ɂ����Ă���
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
    ShowMessage('���݂܂���B�A�C�R���̕ύX�̓f���b�N�X�ł݂̂̋@�\�ł��B');
    Exit;
  end;
  if not dlgOpenIcon.Execute then Exit;
  imgIcon.Picture.LoadFromFile(dlgOpenIcon.FileName);
  flagIconChange := True;
  IconFile := dlgOpenIcon.FileName;
end;

end.
