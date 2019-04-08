unit unit_pack_files;
//
// ���s�t�@�C���Ƀ��\�[�X����������������ʂ������j�b�g
//

interface

uses
  Windows, SysUtils, Classes, hima_types, hima_stream
  {$IFDEF DELUX_VERSION}
  ,unit_pack_files_pro
  {$ENDIF}
  ;

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
    HeaderID : Array [0..3] of AnsiChar;  // �K�� "fMix"
    FormatVersion : Byte;             // ���́A1�̂�
    FileCount : Word;                 // �t�@�C���̐�
    FileSize : DWORD;                 // �w�b�_���܂߂��t�@�C���S�̂̃T�C�Y
  end;

  PFileMixFileHeader = ^TFileMixFileHeader;
  TFileMixFileHeader = packed record
    FileName : Array [0..255] of AnsiChar;
    FilePos  : DWORD;
    FileLen  : DWORD;
    Comp     : Byte;    // 0=�񈳏k 1=XOR�ňÍ��� 2=�Í��� 3=���͈Í��� 4=���͈Í���2
  end;

  TFileMixWriter = class
  public
    FileList: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    function AddFile(const FName, ArchieveName: string; compress: BYTE{0:off 1:easy}): Integer;
    function SaveToFile(const FName: string): Boolean;
  end;

  TFileMixReader = class
  private
    fs: TFileStream;
    fList: THList;
  public
    theHeader: TFileMixHeader;
    TempFile: string;
    autoDelete: Boolean;
    procedure AutoDeleteTempFile;
  public
    constructor Create(const FName: string);
    destructor Destroy; override;
    function ReadFile(const FName: string; var ms: TMemoryStream; IsUser: Boolean = False): Boolean;
    function ReadAndSaveToFile(const ReadName, SaveName: string; IsUser: Boolean = False): Boolean;
    function ReadFileAsString(const FName: string; var str: AnsiString; IsUser: Boolean = False): Boolean;
    function EnumFiles: THStringList;
    procedure SaveToDataFile(const fname: string);
    procedure ExtractAllFile(const dir: string; ext: string = '');
    procedure Extract(info: PFileMixFileHeader; ms: TMemoryStream);
    procedure ExtractPatternFiles(const outdir: string; pattern: string; overwrite:Boolean = True);
    function Find(const FName: string): PFileMixFileHeader;
    procedure debug;
  end;

//
var FileMixReader: TFileMixReader = nil;
var FileMixReaderSelfCreate: Boolean = False;

{�ȒP�ȈÍ���������}
procedure DoXor(var ms: TMemoryStream);
procedure DoAngou(var ms: TMemoryStream);
procedure DoAngou3(var ms: TMemoryStream; enc:Boolean);
procedure DoAngou4(var ms: TMemoryStream; enc:Boolean);
procedure DoAngou5(var ms: TMemoryStream; enc:Boolean);
{$IFDEF DELUX_VERSION}
// define [unit_pack_files_pro.pas] ---> Delux version
{$ELSE}
procedure DoAngou6(var ms: TMemoryStream; enc:Boolean);
{$ENDIF}

{���s�t�@�C���փ��\�[�X�̖��ߍ��݁^�ǂݍ���}
function WritePackExeFile(outFileName, exeFileName, packFileName: string): Boolean;
function ReadPackExeFile(FileName: string; xQDA:TMemoryStream; RealRead: Boolean = True):Boolean;

{�p�b�N�t�@�C����OPEN����}
function OpenPackFile(packExeFile: string): Boolean;

{�I���W�i���ꎞ�t�@�C�����̎擾}
function getOriginalFileName(dirname, header: AnsiString): AnsiString;

// ���ߍ��܂ꂽ�t�@�C�������o���Ĉ����̃t�@�C����������������
function getEmbedFile(var fname: AnsiString):Boolean;

implementation

uses mini_file_utils, unit_string, EasyMasks,
  nadesiko_version, Math;

var AutoDeletePackFile: string = '';

{�I���W�i���ꎞ�t�@�C�����̎擾}
function getOriginalFileName(dirname, header: AnsiString): AnsiString;
begin
  if dirname='' then dirname := AnsiString(TempDir);
  SetLength(Result, MAX_PATH);
  GetTempFileNameA(PAnsiChar(dirname), PAnsiChar(header), 0, PAnsiChar(Result));
  SetLength(Result,StrLen(PAnsiChar(Result)));
end;


function OpenPackFile(packExeFile: string): Boolean;
var
  mem: TMemoryStream;
  fname: string;
  guid: TGUID;
begin
  Result := False;

  if FileMixReader = nil then
  begin

    mem := TMemoryStream.Create ;
    try
      try

        //===========================================
        // ���g���� pack �t�@�C�������o��
        Result := ReadPackExeFile(packExeFile, mem);
        if Result = False then Exit;
        if mem.Size = 0 then Exit;

        // pack�t�@�C���W�J�p�e���|�����t�@�C���擾
        //fname := getOriginalFileName('', 'NAK');
        CreateGUID(guid);
        fname := TempDir + '~nako_' + GUIDToString(guid) + '.pack';
        mem.SaveToFile(fname);
        AutoDeletePackFile := fname;

        //===========================================
        // MixFile ��ǂݍ���
        FileMixReader := TFileMixReader.Create(fname);
        FileMixReaderSelfCreate := (FileMixReader <> nil);
        FileMixReaderSelfCreate := True;
        Result := True;
      except
        on e:Exception do
          raise Exception.Create(
            string(
              '�t�@�C���̓W�J�Ɏ��s���܂����B'+
              e.Message+
              #13#10+'temp://' +
              fname
            ));
      end;
    finally
      mem.Free;
    end;
  end;
end;


function WritePackExeFile(outFileName, exeFileName, packFileName: string): Boolean;
var
  OutFile, SSTTC, PackFile: TFileStream;
begin
  Result := False;
  try
    OutFile:=TFileStream.Create(outFileName, fmCreate);//�o��EXE
    SSTTC:=TFileStream.Create(exeFileName, fmOpenRead or fmShareDenyWrite);
    PackFile:=TFileStream.Create(packFileName, fmOpenRead or fmShareDenyWrite);
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

function ReadPackExeFile(FileName: string; xQDA:TMemoryStream; RealRead: Boolean = True):Boolean;
//�Q�l�F�����󍆂̐��X�̖��
//<!-- saved from url=(0060)http://members.jcom.home.ne.jp/buin2gou/delphi/DelphiFAQ.htm -->
var
  FixUp, v, pebase : Integer;
  exe : TFileStream;
  buf : AnsiChar;
begin
  Result := False;
  // �t�@�C�����̂����݂��Ȃ���Ύ��s
  if FileExists(string(FileName)) = False then
  begin
    Result := False; Exit;
  end;
  // EXE�t�@�C����ǂ�
  exe := TFileStream.Create(FileName, fmOpenRead or SysUtils.fmShareDenyNone);
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
    FreeAndNil(exe);
  end;
end;

// �ȈՈÍ����i���[�U�[���������ł���j
procedure DoXor(var ms: TMemoryStream);
var
  p: PByte;
  i: Integer;
  xorb: Byte;

const
  pat: array [0..6] of AnsiChar = 'tOmo<sK';

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
procedure DoAngou(var ms: TMemoryStream);
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
  pat: array [0..21] of AnsiChar = 'KF4J7F54R4X2K5P8594HQN';

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

var key3real: AnsiString = '';

// �ȈՈÍ�������3�i���s���̂ݓW�J���������^���[�U�[����̓W�J�͎��s����j
procedure DoAngou3(var ms: TMemoryStream; enc:Boolean);
var
  p: PByte;
  i: Integer;
  xorb: Byte;

const
  pat: array [0..199] of Byte = (
    85,141,123,226,210,143,102,5,106,245,106,211,180,20,157,183,
    234,111,227,126,32,67,255,208,47,193,254,162,202,109,187,190,
    31,253,204,8,180,66,23,15,11,185,197,168,194,145,111,65,
    163,46,238,128,101,157,171,138,19,115,59,141,150,219,138,146,
    250,1,113,218,247,111,52,52,93,136,247,128,245,202,25,104,
    205,178,56,96,135,202,190,172,248,60,171,77,236,222,34,191,
    149,196,213,184,76,116,159,100,224,165,201,99,26,250,104,62,
    195,86,23,19,5,106,119,218,248,202,67,244,203,159,27,169,
    84,191,229,81,174,221,91,18,139,159,204,7,135,255,35,205,
    118,53,109,238,97,88,149,120,247,51,0,249,87,252,38,254,
    15,77,87,135,233,145,58,139,222,191,49,207,251,150,232,158,
    103,61,168,64,79,155,28,11,108,52,193,148,124,168,38,186,
    188,47,243,77,230,29,98,184);

  function rand:Byte;
  var i: Integer;
  begin
    i := Random(256);
    Result := i and $FF;
  end;

begin
  // �擪���������擾
  p := ms.Memory;
  RandSeed := ms.Size;

  // �ȈՈÍ����̂��߂̃L�[
  for i := 0 to ms.Size - 1 do
  begin
    xorb := pat[i mod 200];
    p^ := (p^ xor xorb) xor rand;
    Inc(p);
  end;
end;

// �ȈՈÍ�������4�i���s���̂ݓW�J���������^���[�U�[����̓W�J�͎��s����j
procedure DoAngou4(var ms: TMemoryStream; enc:Boolean);
var
  p: PByte;
  i: Integer;
  xorb: Byte;

const
  pat: array [0..72] of Byte = (
    $54,$65,$9A,$E5,$C8,$01,$02,$55,$B9,$FC,$9C,$E0,$23,$6D,$A4,$26,$C0,$CE,$C7,
    $03,$27,$A6,$C2,$17,$9B,$87,$C2,$3F,$CB,$B7,$C5,$0E,$B5,$B9,$74,$37,$83,$85,
    $ED,$DD,$AF,$F7,$E2,$16,$15,$70,$EE,$2E,$C8,$10,$0D,$30,$76,$66,$AD,$17,$8F,
    $F7,$C0,$78,$F6,$4F,$C2,$CE,$D3,$CB,$EF,$AB,$E2,$BA,$AA,$69,$B9
  );

  function rand:Byte;
  var i: Integer;
  begin
    i := Random(256);
    Result := i and $FF;
  end;

begin
  // �擪���������擾
  p := ms.Memory;
  RandSeed := ms.Size;

  // �ȈՈÍ����̂��߂̃L�[
  for i := 0 to ms.Size - 1 do
  begin
    xorb := pat[i mod 73];
    p^ := (p^ xor xorb) xor rand;
    Inc(p);
  end;
end;

// �ȈՈÍ�������5�i���s���̂ݓW�J���������^���[�U�[����̓W�J�͎��s����j
procedure DoAngou5(var ms: TMemoryStream; enc:Boolean);
var
  p: PByte;
  i, len: Integer;
  xorb: Byte;
const
  pat:string = 'eoNOM5hjGrbZCYVCaGq1';
  function rand:Byte;
  var i: Integer;
  begin
    i := Random(256);
    Result := i;
  end;
begin
  p := ms.Memory;
  RandSeed := ms.Size;
  len := Length(pat);
  
  // �ȈՈÍ����̂��߂̃L�[
  for i := 0 to ms.Size - 1 do
  begin
    xorb := Ord(pat[i mod len]);
    p^ := (p^ xor xorb) xor rand;
    Inc(p);
  end;
end;

{$IFDEF DELUX_VERSION}
  // define [unit_pack_files_pro.pas]
  // ---> Delux version
{$ELSE}
procedure DoAngou6(var ms: TMemoryStream; enc:Boolean);
begin
  raise Exception.Create('[ERROR] DELUX VERSION ONLY!!');
end;
{$ENDIF}


function JPosEx(const sub, str: AnsiString; idx:Integer): Integer;
var
    p, sub_p, temp: PAnsiChar; len: Integer;
begin
    Result := 0;
    if Length(str) < idx then Exit;
    temp := PAnsiChar(str); p:= temp;
    Inc(p, idx-1);
    sub_p := PAnsiChar(sub);
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
function GetToken(const delimiter: AnsiString; var str: AnsiString): AnsiString; overload;
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

{$IFDEF UNICODE}
function GetToken(const delimiter: string; var str: string): string; overload;
var
    i: Integer;
begin
    i := Pos(delimiter, str);
    if i=0 then
    begin
        Result := str;
        str := '';
        Exit;
    end;
    Result := Copy(str, 1, i-1);
    Delete(str,1,i + Length(delimiter) -1);
end;
{$ENDIF}

{ TFileMixWriter }

function TFileMixWriter.AddFile(const FName,
  ArchieveName: string;  compress: BYTE): Integer;
begin
  Result := FileList.Add(FName + '=' + ArchieveName + '=' +IntToStr(compress));
end;

constructor TFileMixWriter.Create;
begin
  FileList := TStringList.Create;
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
    fs: TFileStream;
    ms: TMemoryStream;
    i,j: Integer;
    s, readName, name: string;
    aname: AnsiString;
begin
    Result := False;
    with mixHeader do
    begin
        HeaderID := 'fMix';
        FormatVersion := 1;
        FileCount := FileList.Count ;
        FileSize := 0; //��ŏ�������
    end;
    fs := TFileStream.Create(FName, fmCreate);
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
                aname := AnsiString(name);
                StrLCopy(@FileName[0],PAnsiChar(aname), 255); // filename
                Comp := StrToIntDef(string(s),0);
                ms := TMemoryStream.Create ;
                try
                    //�t�@�C���Ǎ�
                    ms.LoadFromFile(readName);
                    if comp=1 then DoXor(ms) else
                    if comp=2 then DoAngou(ms) else
                    if comp=3 then DoAngou3(ms, True) else
                    if comp=4 then DoAngou4(ms, True) else
                    if comp=5 then DoAngou5(ms, True) else
                    if comp=6 then DoAngou6(ms, True) else
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
    i: Integer;
    p: PFileMixFileHeader;
begin
    autoDelete := True;
    TempFile := FName;
    fList := THList.Create ;
    fs := TFileStream.Create(FName, fmOpenRead or fmShareDenyNone);
    fs.Seek(0,soBeginning);
    fs.Read(theHeader, sizeof(theHeader));
    if StrLComp(@theHeader.HeaderID[0], 'fMix', 4) <> 0 then raise EInOutError.CreateFmt('"%s"�́ATFileMixHeader�ł͌`�����Ⴄ���ߓǂ߂܂���B',[FName]);
    // �t�@�C�����̓ǂݍ���
    for i:=0 to theHeader.FileCount -1 do
    begin
        New(p);
        fs.Read(p^, sizeof(tfileMixFileHeader));
        fList.Add(p);
    end;
end;

procedure TFileMixReader.debug;
begin
end;

procedure TFileMixReader.AutoDeleteTempFile;
begin
  if autoDelete then
  begin
    if FileExists(string(TempFile)) then
      DeleteFile(string(TempFile));
  end;
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
  AutoDeleteTempFile;
  inherited;
end;

procedure TFileMixReader.Extract(info: PFileMixFileHeader; ms: TMemoryStream);
begin
  // �f�[�^�̎��o��
  try
    ms.Clear;
    fs.Seek(info.FilePos, soBeginning);
    ms.Seek(0, Classes.soBeginning);
    ms.CopyFrom(fs, info.FileLen);
    if info.Comp = 1 then DoXor(ms) else
    if info.Comp = 2 then DoAngou(ms) else
    if info.Comp = 3 then DoAngou3(ms, False) else
    if info.Comp = 4 then DoAngou4(ms, False) else
    if info.Comp = 5 then DoAngou5(ms, False) else
    if info.Comp = 6 then DoAngou6(ms, False) else
    ;
  except
  end;
end;

procedure TFileMixReader.ExtractAllFile(const dir: string; ext: string = '');
var
  i: Integer;
  p: PFileMixFileHeader;
  ms: TMemoryStream;
  f, ext2: string;
begin
  ForceDirectories(string(dir));
  for i := 0 to fList.Count - 1 do
  begin
    p := fList.Items[i];
    f := string(AnsiString(p.FileName));
    ext2 := (ExtractFileExt(string(f)));
    if (ext = '')or(ext = ext2) then
    begin
      ms := TMemoryStream.Create;
      try
        Extract(p, ms);
        ms.SaveToFile(dir + string(AnsiString(p.FileName)));
      finally
        ms.Free;
      end;
    end;
  end;
end;

function TFileMixReader.ReadAndSaveToFile(const ReadName,
  SaveName: string; IsUser: Boolean): Boolean;
var
  ms: TMemoryStream;
begin
  Result := ReadFile(ReadName, ms, IsUser);
  if Result = True then
  begin
    ms.SaveToFile(SaveName);
    ms.Free;
  end;
end;

function TFileMixReader.ReadFile(const FName: string;
  var ms: TMemoryStream; IsUser: Boolean): Boolean;
var
  pf: PFileMixFileHeader;
begin
  Result := False;
  ms := nil;
  // �t�@�C�����̌���
  pf := Find(FName);
  if pf = nil then Exit;
  // �f�[�^�̎��o��
  try
    ms := TMemoryStream.Create ;
    fs.Seek(pf.FilePos, soBeginning);
    ms.Seek(0, soBeginning);
    ms.CopyFrom(fs, pf.FileLen);
    if pf.Comp = 0 then begin
      // nothing to do
    end else if pf.Comp = 1 then DoXor(ms) else
    if (pf.Comp >= 2) then
    begin
      if IsUser then
      begin
        Result := False;
        raise Exception.Create('���[�U�[����ɂ��ǂݏ����͂ł��܂���B');
        Exit;
      end else
      begin
        if pf.Comp = 2 then DoAngou(ms) else
        if pf.Comp = 3 then DoAngou3(ms, False) else
        if pf.Comp = 4 then DoAngou4(ms, False) else
        if pf.Comp = 5 then DoAngou5(ms, False) else
        if pf.Comp = 6 then DoAngou6(ms, False) else
        ;
      end;
    end else
    begin
      raise Exception.Create('���Ή��̃p�b�N�t�@�C���`���ł�');
    end;
    ;
    Result := True;
  finally
    // ms �͈����Ƃ��Ė߂��̂ŉ�����Ă̓_���I�I
    // ms.free
  end;
end;


function TFileMixReader.ReadFileAsString(const FName: string;
  var str: AnsiString; IsUser: Boolean): Boolean;
var
  m:TMemoryStream;
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
    //str := string(PAnsiChar(str));
  end;
  FreeAndNil(m);
end;

procedure TFileMixReader.SaveToDataFile(const fname: string);
var
  mem: TMemoryStream;
begin
  mem := TMemoryStream.Create ;
  try
    fs.Position := 0;
    mem.CopyFrom(fs, fs.Size);
    mem.SaveToFile(fname);
  finally
    mem.Free;
  end;
end;

function TFileMixReader.EnumFiles: THStringList;
var
  i: Integer;
  p: PFileMixFileHeader;
  f: AnsiString;
begin
  Result := THStringList.Create;
  for i := 0 to fList.Count - 1 do
  begin
    p := fList.Items[i];
    f := p.FileName;
    Result.Add(f);
  end;
end;

function getFileSize(fname: string): Cardinal;
var
  Rec : TSearchRec;
begin
  { �t�@�C���̌��� }
  if FindFirst(string(fname), faAnyFile, Rec) = 0 then
  begin
    { �T�C�Y�̎擾 }
    Result := Rec.Size;
    FindClose(Rec);
  end else
  begin
    Result := 0;
  end;
end;

procedure TFileMixReader.ExtractPatternFiles(const outdir: string; pattern: string; overwrite:Boolean = True);
var
  i: Integer;
  p: PFileMixFileHeader;
  dir, f: string;
  ms: TMemoryStream;
begin
  dir := CheckPathYen(outdir);
  ForceDirectories(string(dir));
  for i := 0 to fList.Count - 1 do
  begin
    p := fList.Items[i];
    f := string(AnsiString(p.FileName));
    if MatchesMask(string(f), string(pattern)) then
    begin
      if overwrite = False then
      begin
        if FileExists(string(dir + f)) then
        begin
          if getFileSize(dir + f) = p.FileLen then Continue;
        end;
      end;
      ms := TMemoryStream.Create;
      try
        Extract(p, ms);
        try
          ms.SaveToFile(dir + f);
        except
          //
        end;
      finally
        FreeAndNil(ms);
      end;
    end;
  end;
end;

function TFileMixReader.Find(const FName: string): PFileMixFileHeader;
var
  p: PFileMixFileHeader;
  i: Integer;
  fname_a: AnsiString;
begin
  Result := nil;
  // �t�@�C�����̌���
  fname_a := AnsiString(UpperCase(FName));
  for i := 0 to fList.Count - 1 do
  begin
    p := fList.Items[i];
    if UpperCaseA(p.FileName) = fname_a then
    begin
      Result := p;
      Break;
    end;
  end;
end;

function getEmbedFile(var fname: AnsiString):Boolean;
var
  f: string;
  readf, savef: string;
  tmp: string;
begin
  Result := False;
  if unit_pack_files.FileMixReader <> nil then
  begin
    // �W�J��
    f := (ParamStr(0)) + '?' + string(fname);
    f := JReplace(f, ':', '');
    f := JReplace(f, '\', '.');
    f := JReplace(f, '?', '\');

    tmp := (TempDir) + 'com.nadesi.dll.dnako.embed\' + f;
    if FileExists(string(tmp)) then
    begin
      fname := AnsiString(tmp);
      Result := True;
      Exit;
    end;
    ForceDirectories(string(ExtractFilePath(string(tmp))));
    readf := string(fname);
    savef := string(tmp);
    // debugs('read:' + readf + #13 + 'save:' + savef);
    if unit_pack_files.FileMixReader.ReadAndSaveToFile(readf, savef, True) then
    begin
      fname := AnsiString(savef);
      Result := True;
    end;
  end;
end;


initialization
  FileMixReader := nil;

finalization
begin
  if FileMixReaderSelfCreate then
  begin
    try
      FreeAndNil(FileMixReader);
    except
    end;
  end;
  if AutoDeletePackFile <> '' then
  begin
    if FileExists(string(AutoDeletePackFile)) then
     begin
      DeleteFile(string(AutoDeletePackFile));
     end;
  end;
end;

end.

