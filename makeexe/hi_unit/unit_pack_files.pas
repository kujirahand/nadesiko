unit unit_pack_files;
//
// ���s�t�@�C���Ƀ��\�[�X����������������ʂ������j�b�g
//

interface

uses
  Windows, SysUtils, hima_types, hima_stream;

{
  TFileMixReader
    FORMAT:

    TFileMixHeader

    [(FileCount)
      TFileMixFileHeader
    ]

    [(FileCount)
      FileData
    ]


//*** �啶���A����������ʂ��Ȃ��ŁA�܂Ƃ߂�
}
type
  TFileMixHeader = packed record
    HeaderID : Array [0..3] of Char;  // �K�� "fMix"
    FormatVersion : Byte;             // ���́A1�̂�
    FileCount : Word;                 // �t�@�C���̐�
    FileSize : DWORD;                 // �w�b�_���܂߂��t�@�C���S�̂̃T�C�Y
  end;

  PFileMixFileHeader = ^TFileMixFileHeader;
  TFileMixFileHeader = packed record
    FileName : Array [0..255] of Char;
    FilePos  : DWORD;
    FileLen  : DWORD;
    Comp     : Byte;    // 0=�񈳏k 1=XOR�ňÍ��� 2=�Í���
  end;

  TFileMixWriter = class
  public
    FileList: THStringList;
  public
    constructor Create;
    destructor Destroy; override;
    function AddFile(const FName, ArchieveName: string; compress: BYTE{0:off 1:easy}): Integer;
    function SaveToFile(const FName: string): Boolean;
  end;

  TFileMixReader = class
  private
    fs: THFileStream;
    fList: THList;
  public
    theHeader: TFileMixHeader;
    TempFile: string;
  public
    constructor Create(const FName: string);
    destructor Destroy; override;
    function ReadFile(const FName: string; var ms: THMemoryStream; IsUser: Boolean = False): Boolean;
    function ReadAndSaveToFile(const ReadName, SaveName: string; IsUser: Boolean = False): Boolean;
    function ReadFileAsString(const FName: string; var str: String; IsUser: Boolean = False): Boolean;
    procedure SaveToDataFile(const fname: string);
    procedure ExtractAllFile(const dir: string);
    procedure Extract(info: PFileMixFileHeader; ms: THMemoryStream);
    procedure debug;
  end;

//
var FileMixReader: TFileMixReader = nil;
var FileMixReaderSelfCreate: Boolean = False;

{�ȒP�ȈÍ���������}
procedure DoXor(var ms: THMemoryStream);

{���s�t�@�C���փ��\�[�X�̖��ߍ��݁^�ǂݍ���}
function WritePackExeFile(outFileName, exeFileName, packFileName: string): Boolean;
function ReadPackExeFile(FileName:String; xQDA:THMemoryStream; RealRead: Boolean = True):Boolean;

{�p�b�N�t�@�C����OPEN����}
function OpenPackFile(packExeFile: string): Boolean;

{�I���W�i���ꎞ�t�@�C�����̎擾}
function getOriginalFileName(dirname, header: string): string;

implementation

{�I���W�i���ꎞ�t�@�C�����̎擾}
function getOriginalFileName(dirname, header: string): string;
var
  i: Integer;
  fname,s,ext: string;

  function TempDir:string;
  var
   TempTmp:array[0..MAX_PATH] of Char;
  begin
   GetTemppath(MAX_PATH,TempTmp);
   Result:=StrPas(TempTmp);
   if Copy(Result,Length(Result),1)<>'\' then Result := Result + '\';
  end;

begin
    if dirname='' then dirname := TempDir;
    i   := 1;
    s   := header;
    ext := ExtractFileExt(header);
    s   := Copy(s,1, Length(s)-Length(ext));
    if Copy(dirname,Length(dirname),1)<>'\' then dirname := dirname + '\';
    while True do
    begin
        fname := dirname + s + IntToStr(i) + ext;
        if FileExists(fname) = False then
        begin
            Result := fname; Break;
        end;
        Inc(i);
    end;
end;


function OpenPackFile(packExeFile: string): Boolean;
var
  mem: THMemoryStream;
  fname: string;
begin
  Result := False;

  if FileMixReader = nil then
  begin

    mem := THMemoryStream.Create ;
    try
      try

        //===========================================
        // ���g���� pack �t�@�C�������o��
        Result := ReadPackExeFile(packExeFile, mem);
        if Result = False then Exit;
        if mem.Size = 0 then Exit;

        // pack�t�@�C���W�J�p�e���|�t�@�C���擾
        fname := getOriginalFileName('', 'TMP.TMP');
        mem.SaveToFile(fname);

        //===========================================
        // MixFile ��ǂݍ���
        FileMixReader := TFileMixReader.Create(fname);
        FileMixReaderSelfCreate := (FileMixReader <> nil);

        //���p���ׂ�
        //nako_setPackFilePtr(FileMixReader);

        Result := True;

      except
        on e:Exception do
          raise Exception.Create('�t�@�C���̓W�J�Ɏ��s���܂����B'+e.Message);
      end;
    finally
      mem.Free;
    end;

  end;
end;


function WritePackExeFile(outFileName, exeFileName, packFileName: string): Boolean;
var
  OutFile, SSTTC, PackFile: THFileStream;
begin
  Result := False;
  try
    OutFile:=THFileStream.Create(outFileName, fmCreate);//�o��EXE
    SSTTC:=THFileStream.Create(exeFileName, fmOpenRead or fmShareDenyWrite);
    PackFile:=THFileStream.Create(packFileName, fmOpenRead or fmShareDenyWrite);
    //�����ݒ��i�����j
    OutFile.CopyFrom(SSTTC, SSTTC.Size);//�����^�C�����s�t�@�C��
    OutFile.CopyFrom(PackFile, PackFile.Size);//�Q�[���f�[�^�A�[�J�C�u

    SSTTC.Free;
    PackFile.Free;
    OutFile.Free;
  except
    Exit;
  end;
  Result := True;
end;

function ReadPackExeFile(FileName:String; xQDA:THMemoryStream; RealRead: Boolean = True):Boolean;
//�Q�l�F�����󍆂̐��X�̖��
//<!-- saved from url=(0060)http://members.jcom.home.ne.jp/buin2gou/delphi/DelphiFAQ.htm -->
var
  FixUp, v, pebase : Integer;
  exe : THFileStream;
  buf : Char;
begin
  Result := False;
  // �t�@�C�����̂����݂��Ȃ���Ύ��s
  if FileExists(FileName) = False then
  begin
    Result := False; Exit;
  end;
  // EXE�t�@�C����ǂ�
  exe := THFileStream.Create(FileName,fmOpenRead or fmShareDenyWrite);
  try
    // EXE�t�@�C���̃w�b�_�擪�𒲂ׂ�
    exe.Position := 0;
    exe.ReadBuffer(buf, SizeOf(buf));
    if (buf<>'M') and (buf<>'m') then Exit; // ���s�t�@�C���ł͂Ȃ�
    // PE�w�b�_�𒲂ׂ�
    exe.Position := $3c;
    pebase := 0;
    exe.ReadBuffer(pebase, 2); // PE�w�b�_�ʒu
    exe.Position := pebase;
    v:=0;
    exe.ReadBuffer(v, 2); // 'PE'
    exe.Position := pebase + 6;
    v:=0;
    exe.ReadBuffer(v, 1); // Object Count
    exe.Position := pebase + (v-1) * 40 + $f8 + 16;
    exe.ReadBuffer(Fixup, 4); // Phys. size
    exe.Position := pebase + (v-1) * 40 + $f8 + 20;
    exe.ReadBuffer(v, 4); // Phys. offset

    Fixup := FixUp + v;
    exe.Position := Fixup;

    // ���������f�[�^�̃w�b�_�̂P�����ڂ�T��
    buf := #0;
    while buf<>'f' do
    begin
      if exe.Read(buf,1)=0 then Exit; // �f�[�^���Ȃ����False��Ԃ��I
    end;

    exe.Position := FixUp;

    if RealRead then // ���ۂɓǂݍ��ޏꍇ
    begin
      xQDA.CopyFrom(EXE, EXE.Size - FixUp);//�f�[�^������؂肾��
      xQDA.Position := 0;
    end;
    
    Result := True;//�����I

  finally
    exe.Free;
  end;
end;

// �ȈՈÍ����i���[�U�[���������ł���j
procedure DoXor(var ms: THMemoryStream);
var
  p: PByte;
  i: Integer;
  xorb: Byte;

const
  pat: array [0..6] of Char = 'tOmo<sK';

begin
  // �擪���������擾
  p := ms.Memory;

  // �ȈՈÍ����̂��߂̃L�[
  for i := 0 to ms.Size - 1 do
  begin
    xorb := (ord(pat[i mod 7])) and $FF;
    p^ := p^ xor xorb;
    Inc(p);
  end;
end;

// �ȈՈÍ������̂Q�i���s���̂ݓW�J���������^���[�U�[����̓W�J�͎��s����j
procedure DoAngou(var ms: THMemoryStream);
var
  p: PByte;
  i: Integer;
  xorb: Byte;

  //------------------------------------------------------------------------------
  // �Ȉ՗������[�`��
  const MAXRNDWORD = 8;
  const init_seed : array [0..MAXRNDWORD-1] of DWORD = ($2378164a, $8478acde, $8f7daf98, $3786daa4, $83748adf, $3428dafa, $89237da1, $3789fda1);
  var rnd_seed  : array [0..MAXRNDWORD-1] of DWORD;

  procedure InitRand;
  var
    i: Integer;
  begin
    for i := 0 to MAXRNDWORD-1 do
      rnd_seed[i] := init_seed[i];
  end;

  function ERand(N: DWORD): DWORD;
  var
    i, r0, r1: Integer;
  begin
    r0 := (rnd_seed[2] shl 7)  + (rnd_seed[3] shr 25);
    r1 := (rnd_seed[6] shl 26) + (rnd_seed[7] shr 6);

    for i := MAXRNDWORD-1 downto 1 do
    begin
      rnd_seed[i] := rnd_seed[i-1];
    end;
    rnd_seed[0] := r0 xor r1;

    Result := rnd_seed[0] mod N;
  end;
  //------------------------------------------------------------------------------

const
  pat: array [0..21] of Char = 'KF4J7F54R4X2K5P8594HQN';

begin
  // �擪���������擾
  p := ms.Memory;

  InitRand;

  // �ȈՈÍ����̂��߂̃L�[
  for i := 0 to ms.Size - 1 do
  begin
    xorb := ( ord(pat[i mod 22]) ) and $FF;
    p^ := (p^ xor xorb) xor ERand(256);
    Inc(p);
  end;
end;


function JPosEx(const sub, str:string; idx:Integer): Integer;
var
    p, sub_p, temp: PChar; len: Integer;
begin
    Result := 0;
    if Length(str) < idx then Exit;
    temp := PChar(str); p:= temp;
    Inc(p, idx-1);
    sub_p := PChar(sub);
    len := Length(sub);
    while p^ <> #0 do
    begin
      if StrLComp(sub_p, p, len)=0 then
        begin
          Result := (p - temp) + 1;
          Exit;
        end;
      if p^ in SysUtils.LeadBytes then Inc(p,2) else Inc(p);
    end;
end;


{�f���~�^������܂ł̒P���؂�o���B}
function GetToken(const delimiter: String; var str: string): String;
var
    i: Integer;
begin
    i := JPosEx(delimiter, str,1);
    if i=0 then
    begin
        Result := str;
        str := '';
        Exit;
    end;
    Result := Copy(str, 1, i-1);
    Delete(str,1,i + Length(delimiter) -1);
end;

{ TFileMixWriter }

function TFileMixWriter.AddFile(const FName,
  ArchieveName: string;  compress: BYTE): Integer;
begin
  Result := FileList.Add(FName + '=' + ArchieveName + '=' +IntToStr(compress));
end;

constructor TFileMixWriter.Create;
begin
  FileList := THStringList.Create;
end;

destructor TFileMixWriter.Destroy;
begin
  FileList.Free;
  inherited;
end;

function TFileMixWriter.SaveToFile(const FName: string): Boolean;
var
    fileHeader: TFileMixFileHeader;
    mixHeader: TFileMixHeader;
    fs: THFileStream;
    ms: THMemoryStream;
    i,j: Integer;
    s, readName, name: string;
begin
    Result := False;
    with mixHeader do
    begin
        HeaderID := 'fMix';
        FormatVersion := 1;
        FileCount := FileList.Count ;
        FileSize := 0; //��ŏ�������
    end;
    fs := THFileStream.Create(FName, fmCreate);
    try
    try
        fs.Seek(0, soBeginning);
        fs.Write(mixHeader, SizeOf(mixHeader)); // write Header********
        for i:=0 to FileList.Count-1 do         // write dummy data********
        begin
            fs.Write(fileHeader, sizeof(fileHeader))
        end;
        for i:=0 to FileList.Count -1 do
        begin
            with fileHeader do
            begin
                s := FileList.Strings[i];
                readName := GetToken('=', s);
                name := UpperCase(gettoken('=',s));
                for j:=0 to 255 do FileName[j] := #0;
                StrLCopy(@FileName[0],PChar(name), 255); // filename
                Comp := StrToIntDef(s,0);
                ms := THMemoryStream.Create ;
                try
                    //�t�@�C���Ǎ�
                    ms.LoadFromFile(readName);
                    if comp=1 then DoXor(ms) else
                    if comp=2 then DoAngou(ms) else
                    ;
                    FileLen  := ms.Size;
                    FilePos  := fs.Position ;
                    //��������
                    fs.Seek( (sizeof(mixHeader) + i * sizeof(fileHeader)), soBeginning); //header REWRITE***
                    fs.Write(fileHeader, sizeof(fileHeader));
                    fs.Seek(FilePos, soBeginning);
                    ms.Seek(0, soBeginning);
                    fs.CopyFrom(ms, ms.Size);
                    fs.Seek(FilePos+FileLen, soBeginning);
                finally
                	ms.Free;
                end;
            end;
        end;
        //�w�b�_�̏�������
        mixHeader.FileSize := fs.Size ;
        fs.Seek(0, soBeginning);
        fs.Write(mixHeader, SizeOf(mixHeader));
    except
    	Exit;
    end;
    finally
    	fs.Free;
    end;
    Result := True;
end;

{ TFileMixReader }

constructor TFileMixReader.Create(const FName: string);
var
    theHead: TFileMixHeader;
    i: Integer;
    p: PFileMixFileHeader;
begin
    TempFile := FName;
    fList := THList.Create ;
    fs := THFileStream.Create(FName, fmOpenRead);
    fs.Seek(0,soBeginning);
    fs.Read(theHead, sizeof(theHead));
    if StrLComp(@theHead.HeaderID[0], 'fMix', 4) <> 0 then raise EInOutError.CreateFmt('"%s"�́ATFileMixHeader�ł͌`�����Ⴄ���ߓǂ߂܂���B',[FName]);
    // �t�@�C�����̓ǂݍ���
    for i:=0 to theHead.FileCount -1 do
    begin
        New(p);
        fs.Read(p^, sizeof(tfileMixFileHeader));
        fList.Add(p);
    end;
end;

procedure TFileMixReader.debug;
begin
end;

destructor TFileMixReader.Destroy;
var
  i: Integer;
  p: PFileMixFileHeader;
begin
  for i := 0 to fList.Count - 1 do
  begin
    p := fList.Items[i];
    Dispose(p);
  end;
  FreeAndNil(fList);
  FreeAndNil(fs);
  inherited;
end;

procedure TFileMixReader.Extract(info: PFileMixFileHeader; ms: THMemoryStream);
begin
  // �f�[�^�̎��o��
  try
    ms.Clear;
    fs.Seek(info.FilePos, soBeginning);
    ms.Seek(0, soBeginning);
    ms.CopyFrom(fs, info.FileLen);
    if info.Comp = 1 then DoXor(ms) else
    if info.Comp = 2 then
    begin
      DoAngou(ms);
    end;
  except
  end;
end;

procedure TFileMixReader.ExtractAllFile(const dir: string);
var
  i: Integer;
  p: PFileMixFileHeader;
  ms: THMemoryStream;
begin
  ForceDirectories(dir);
  for i := 0 to fList.Count - 1 do
  begin
    p := fList.Items[i];
    ms := THMemoryStream.Create;
    try
      Extract(p, ms);
      ms.SaveToFile(dir + p.FileName);
    finally
      ms.Free;
    end;
  end;
end;

function TFileMixReader.ReadAndSaveToFile(const ReadName,
  SaveName: string; IsUser: Boolean): Boolean;
var
  ms: THMemoryStream;
begin
  Result := ReadFile(ReadName, ms);
  if Result = True then
  begin
    ms.SaveToFile(SaveName);
    ms.Free;
  end;
end;

function TFileMixReader.ReadFile(const FName: string;
  var ms: THMemoryStream; IsUser: Boolean): Boolean;
var
  p, pf: PFileMixFileHeader;
  i: Integer;
begin
  Result := False;

  // �t�@�C�����̌���
  pf := nil;
  for i := 0 to fList.Count - 1 do
  begin
    p := fList.Items[i];
    if UpperCase(p.FileName) = UpperCase(FName) then begin pf := p; Break; end;
  end;
  if pf = nil then Exit;

  // �f�[�^�̎��o��
  try
    ms := THMemoryStream.Create ;
    fs.Seek(pf.FilePos, soBeginning);
    ms.Seek(0, soBeginning);
    ms.CopyFrom(fs, pf.FileLen);
    if pf.Comp = 1 then DoXor(ms) else
    if pf.Comp = 2 then
    begin
      if IsUser then
      begin
        Result := False;
        Exit;
      end else
      begin
        DoAngou(ms);
      end;
    end;
    Result := True;
  except
  end;
end;


function TFileMixReader.ReadFileAsString(const FName: string;
  var str: String; IsUser: Boolean): Boolean;
var
  m:THMemoryStream;
begin
  // �������̓ǂݍ���
  m := nil;
  Result := ReadFile(Fname, m, IsUser);
  if Result then
  begin
    // ������ɃR�s�[
    SetLength(str, m.Size);
    m.Seek(0, soBeginning);
    m.Read(str[1], m.Size);
    //str[m.Size+1] := #0;
    //str := string(PChar(str));
  end;
  FreeAndNil(m);
end;

procedure TFileMixReader.SaveToDataFile(const fname: string);
var
  mem: THMemoryStream;
begin
  mem := THMemoryStream.Create ;
  try
    fs.Position := 0;
    mem.CopyFrom(fs, fs.Size);
    mem.SaveToFile(fname);
  finally
    mem.Free;
  end;
end;

initialization
  FileMixReader := nil;

finalization
  if FileMixReaderSelfCreate then
  begin
    FreeAndNil(FileMixReader);
  end;

end.

