unit unit_rewrite_icon;

// �Q�l) Delphi Tips & Tricks (����EXE�i���s�j�t�@�C���̃A�C�R�������ւ���)
// http://www.geocities.jp/asumaroyuumaro/program/tips/ExeIconChange.html
// 
// UpdateResource() �̌��E���ۂ�
// EXE�ɂ���ăp�����[�^�̐ݒ��ς���K�v������
//
(** ���ۂ̎g�p��
------------------------------------
var
  p: TIconChanger;
begin
  p := TIconChanger.Create;
  p.change('a.exe', 'icon.ico');
  p.Free;
end;
------------------------------------
*)
interface
uses
  Windows, SysUtils, Classes, Graphics;

type
  //���\�[�X�A�C�R���p TIconRec
  TIconResInfo =packed record
    Width   : Byte;
    Height  : Byte;
    Colors  : Word;
    Plane   : Word;
    BitCount: Word;
    DIBSize : DWord;
    ID      : Word; //TIconRec�͂�����LongInt�łQ�o�C�g���Ⴄ
  end;
  PIconResInfo =^TIconResInfo;

  //EnumResourceProc�Ŏ擾�������\�[�XID��ێ����Ă������R�[�h
  TResourceName =packed record
   FString: Boolean; //True�Ȃ烊�\�[�X���������� False�Ȃ琔�lID
   RTID  : PChar;
   RTName: string;
  end;
  PResourceName =^TResourceName;

  TIconChanger = class
  public
    //�ύX�Ώۂ̎��s�t�@�C���ƁA�}�������A�C�R���t�@�C���̃p�X
    ExeName, IconName: string;
  private
    function SwitchResourceIcon(Resname: PChar):Boolean;
  public
    function Change(ExePath, IconPath: string): Boolean;
  end;

implementation

{ TIconChanger }

function EnumResNameProc(hFile: THandle; ResType: PChar;
  ResStr: PChar; pResname: PResourceName):LongBool; stdcall;
begin
  //�͂��߂Ɍ��������O���[�v�A�C�R�����X�V�ΏۂƂ���
  if HiWord(Cardinal(ResStr)) =0 then
  begin
    //��ʂQ�o�C�g�� 0�Ȃ�ID(���l)
    pResName^.RTID :=ResStr;
    pResName^.FString :=False;
  end
  else begin
    //����ȊO�͕�����ւ̃|�C���^
    pResName^.RTName :=ResStr;
    pResName^.FString :=True;
  end;
  //�񋓏I��
  Result :=False;
end;


function TIconChanger.Change(ExePath, IconPath: string): Boolean;
var
  hFile  : THandle;
  ResName :TResourceName;
begin
  Self.ExeName  := ExePath;
  Self.IconName := IconPath;

  hFile := LoadLibraryEx(PChar(ExeName), 0,
                        LOAD_LIBRARY_AS_DATAFILE or
                        LOAD_WITH_ALTERED_SEARCH_PATH);
  try
    if hFile <> 0 then
    begin
      EnumResourceNames(hFile, RT_GROUP_ICON, @EnumResNameProc, LPARAM(@Resname));
    end;
  finally
    FreeLibrary(hFile);
  end;

  if ResName.FString then
  begin
    ResName.RTID :=PChar(ResName.RTName);
  end;
  Result :=SwitchResourceIcon(ResName.RTID);
end;

function TIconChanger.SwitchResourceIcon(Resname: PChar):Boolean;
const
  sizeCI =Sizeof(TCursororIcon);
  sizeIR =Sizeof(TIconRec);
  ID_LANG =1041;  //���{��̌��ꎯ�ʎq
var
  hUpdate: THandle;
  ms: TMemoryStream;
  fs: TFileStream;
  Buf: PByteArray;
  i: integer;
  pInfo: PIconRec;
  CI: TCursororIcon;
  IR: array of TIconResInfo;
  icon_id: Integer;
begin
  Result :=False;
  if not FileExists(Exename) then
  begin
    raise Exception.Create('���s�t�@�C����������܂���B');
  end;
  if not FileExists(Iconname) then
  begin
    raise Exception.Create('�A�C�R���t�@�C����������܂���B');
  end;

  //���\�[�X�̍X�V���J�n�@�������Ŋ����̃��\�[�X�̍폜���w��
  hUpdate :=BeginUpdateResource(PChar(ExeName), False);
  if hUpdate = 0 then Exit;

  fs :=TFileStream.Create(IconName, fmOpenRead);
  try
    Buf :=AllocMem(fs.Size);
    try
     //�A�C�R���t�@�C���̓��e���o�b�t�@�ɃR�s�[
     fs.ReadBuffer(Buf^, fs.Size);
     //TCursororIcon ���R�[�h��g�ݗ���
     CI.Reserved :=0;
     CI.wType    :=1;
     CI.Count    :=PCursororIcon(Buf).Count;

     //�A�C�R���̐����� TIconResInfo��p��
     SetLength(IR, CI.Count);

     for i :=0 to CI.Count -1 do
     begin
       //TIconResInfo ���R�[�h��g�ݗ���
       pInfo := @Buf[sizeCI + sizeIR * i];
       IR[i].Width  :=pInfo.Width;
       IR[i].Height :=pInfo.Height;
       IR[i].Colors :=pInfo.Colors;
       IR[i].Plane  :=pInfo.Reserved1;
       IR[i].BitCount :=pInfo.Reserved2;
       IR[i].DIBSize  :=pInfo.DIBSize;
       icon_id        := i + 3;
       IR[i].ID       := icon_id;
       //��Ɋe�A�C�R����DIB�����s�t�@�C���ɒǉ�
       UpdateResource(hUpdate, RT_ICON, PChar(icon_id), ID_Lang,
                      @Buf[pInfo.DIBOffset], pInfo.DIBSize);
     end;

     ms :=TMemoryStream.Create;
     try
       //�O���[�v�A�C�R���f�[�^���X�g���[���ɍ���Ď��s�t�@�C���ɒǉ�
       //(�������g�ݗ��Ă�TCursororIcon + TIconResInfo x �A�C�R����)
       ms.WriteBuffer(CI, sizeCI);
       ms.WriteBuffer(IR[0], sizeIR * CI.Count);
       if not UpdateResource(hUpdate, RT_GROUP_ICON, Resname,
                              ID_LANG, ms.Memory, ms.Size) then Exit;
       //�X�V���I��
       if EndUpdateResource(hUpdate, False) then
       begin
        //�����܂ł���΂��Ԃ񐬌�
        Result :=True;
       end;
     finally
       ms.Free;
     end;
    finally
      FreeMem(Buf);
    end;
  finally
    fs.Free;
  end;
end;


end.
