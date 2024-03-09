unit fileLoader;
// ���@���F�����t�@�C�����P�̃t�@�C���ɂ܂Ƃ߂邽�߂̃��j�b�g
// ��@�ҁF�N�W����s��(http://kujirahand.com)
// ���J���F2001/10/21     

interface  
uses
  SysUtils, Classes, Windows, LoadHash;
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

  TFileMixFileHeader = packed record
    FileName : Array [0..255] of Char;
    FilePos  : DWORD;
    FileLen  : DWORD;
    Comp     : Byte;    // 0=�񈳏k 1=XOR�ňÍ��� 2=�ȈՈ��k(������)
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
  public
    theHeader: TFileMixHeader;
    hash: THash;
    TempFile: string;
  public
    constructor Create(const FName: string);
    destructor Destroy; override;
    function ReadFile(const FName: string; var ms: TMemoryStream): Boolean;
    function ReadAndSaveToFile(const ReadName, SaveName: string): Boolean;
    function ReadFileAsString(const FName: string; var str: String): Boolean;
    procedure SaveToDataFile(const fname: string);
    procedure debug;
  end;

{�f���~�^������܂ł̒P���؂�o���B}
function GetToken(const delimiter: String; var str: string): String;
function JPosEx(const sub, str:string; idx:Integer): Integer;
{�ȒP�ȈÍ���������}
procedure DoXor(var ms: TMemoryStream);

{���s�t�@�C���փ��\�[�X�̖��ߍ��݁^�ǂݍ���}
function WritePackExeFile(outFileName, exeFileName, packFileName: string): Boolean;
function ReadPackExeFile(FileName:String; var xQDA:TMemoryStream):Boolean;


implementation

uses CipherUnit,StrUnit;

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

function ReadPackExeFile(FileName:String; var xQDA:TMemoryStream):Boolean;
//�Q�l�F�����󍆂̐��X�̖��
//<!-- saved from url=(0060)http://members.jcom.home.ne.jp/buin2gou/delphi/DelphiFAQ.htm -->
var
  exe:TFileStream;
  FixUp,v,pebase:Integer;
  buf:Char;
begin
  Result := False;
  exe:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyWrite);
  try

    exe.Position:=0;
    exe.ReadBuffer(buf,2);

    if (buf<>'M') and (buf<>'m') then exit; // ���܂��� ZM �`���͂Ȃ����炢�����ǁE�E�E�B

    exe.Position:=$3c;
    pebase:=0;
    exe.ReadBuffer(pebase,2); // PE�w�b�_�ʒu
    exe.Position:=pebase;
    v:=0;
    exe.ReadBuffer(v,2); // 'PE'
    exe.Position:=pebase+6;
    v:=0;
    exe.ReadBuffer(v,1); // Object Count
    exe.Position:=pebase+(v-1)*40 + $f8 + 16;
    exe.ReadBuffer(Fixup,4); // Phys. size
    exe.Position:=pebase+ (v-1)*40 + $f8 + 20;
    exe.ReadBuffer(v,4); // Phys. offset

    Fixup:=FixUp+v;
    exe.Position:=Fixup;

    //Q���Č����̂́ASPGGDK���AQDA���g���Ă��邩��BQ�́A�w�b�_�T���ŁA
    //�w�b�_�ɍ��킹�Ĉꕶ���ς��Ă��������BEFF��������AE�ŁB
    //�f�[�^�������ꍇ�́A���̏������Ď��ŕt������ŁA�����Ă����C�ł��B
    //����������G���[�ł܂��邯�ǁB
    //mine: �Ђ܂��ł́AfMix �� f ���ȁH
    buf := #0;
    while buf<>'f' do begin
         If exe.Read(buf,1)=0 then exit;//�f�[�^���Ȃ����False��Ԃ��I
    end;

    exe.Position:=FixUp;

    xQDA.CopyFrom(EXE,EXE.Size-FixUp);//�f�[�^������؂肾��
    xQDA.Position:=0;

    Result:=True;//�����I

  finally
    exe.Free;
  end;
end;


procedure DoXor(var ms: TMemoryStream);
var
    cip: TCipher;
const
	key = '>����@����`!<<<';
begin
	cip := TCipher.Create ;
    try
    	ms.Position := 0;
        cip.CopyFrom(ms, ms.Size);
		cip.AllXOR(key);
        ms.Clear;
        ms.CopyFrom(cip, cip.Size);
    finally
    	cip.Free;
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
	FileList := TStringList.Create;
end;

destructor TFileMixWriter.Destroy;
begin
  inherited;
	FileList.Free;
end;

function TFileMixWriter.SaveToFile(const FName: string): Boolean;
var
	fileHeader: TFileMixFileHeader;
    mixHeader: TFileMixHeader;
    fs: TFileStream;
    ms: TMemoryStream;
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
	  fs := TFileStream.Create(FName, fmCreate);
    try
    try
        fs.Seek(0, soFromBeginning);
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
                name := UpperCaseEx(gettoken('=',s));
                for j:=0 to 255 do FileName[j] := #0;
                StrLCopy(@FileName[0],PChar(name), 255); // filename
                Comp := StrToIntDef(s,0);
                ms := TMemoryStream.Create ;
                try
                    //�t�@�C���Ǎ�
                	  ms.LoadFromFile(readName);
                    if comp=1 then DoXor(ms);
                    FileLen  := ms.Size;
                    FilePos  := fs.Position ;
                    //��������
                    fs.Seek( (sizeof(mixHeader) + i * sizeof(fileHeader)), soFromBeginning); //header REWRITE***
                    fs.Write(fileHeader, sizeof(fileHeader));
                    fs.Seek(FilePos, soFromBeginning);
                    ms.Seek(0, soFromBeginning);
                    fs.CopyFrom(ms, ms.Size);
                    fs.Seek(FilePos+FileLen, soFromBeginning);
                finally
                	ms.Free;
                end;
            end;
        end;
        //�w�b�_�̏�������
        mixHeader.FileSize := fs.Size ;
        fs.Seek(0, soFromBeginning);
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
    fileHead: TFileMixFileHeader;
    i: Integer;
    hn: THashNode;
begin
    TempFile := FName;
	hash := THash.Create ;
    fs := TFileStream.Create(FName, fmOpenRead);
    fs.Seek(0,0);
	fs.Read(theHead, sizeof(theHead));
    if StrLComp(@theHead.HeaderID[0], 'fMix', 4) <> 0 then raise EReadError.CreateFmt('"%s"�́ATFileMixHeader�ł͌`�����Ⴄ���ߓǂ߂܂���B',[FName]);
 	for i:=0 to theHead.FileCount -1 do
    begin
    	fs.Read(fileHead, sizeof(fileHead));
		hn := THashNode.Create(string(PCHar(@fileHead.FileName[0])), fileHead.FilePos, fileHead.FileLen, fileHead.Comp);
        Hash.Add(hn);
    end;
end;

procedure TFileMixReader.debug;
begin
	hash.Debug ;
end;

destructor TFileMixReader.Destroy;
begin
  inherited;
	hash.Free;
    fs.Free;
end;

function TFileMixReader.ReadAndSaveToFile(const ReadName,
  SaveName: string): Boolean;
var
	ms: TMemoryStream;
begin
	Result := ReadFile(ReadName, ms);
    if Result = True then
    begin
    	ms.SaveToFile(SaveName);
    	ms.Free;
    end;
end;

function TFileMixReader.ReadFile(const FName: string;
  var ms: TMemoryStream): Boolean;
var
	hn: THashNode;
begin
	Result := False;
    hn := Hash.Find(UpperCaseEx(FName));
    if hn = nil then Exit;
    try
        ms := TMemoryStream.Create ;
        fs.Seek(hn.pos, soFromBeginning);
        ms.Seek(0, soFromBeginning);
        ms.CopyFrom(fs, hn.len);
        if hn.comp = 1 then
            DoXor(ms);
        Result := True;
    except
    end;
end;


function TFileMixReader.ReadFileAsString(const FName: string;
  var str: String): Boolean;
var m:TMemoryStream;
begin
	Result := ReadFile(Fname, m);
  if Result then
  begin
    SetLength(str, m.Size);
    m.Seek(0, soFromBeginning);
    m.Read(str[1], m.Size);
    //str[m.Size+1] := #0;
    //str := string(PChar(str));
  end;
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

end.
