unit unit_text_file;

interface

uses
  SysUtils, Classes;

type
  // �o�b�t�@�����O�̂���FileStream
  TKTextFileStream = class(TFileStream)
  private
    FBuf          : AnsiString;
    FReadBufSize  : Integer;
    FEOF          : Boolean;
    preEOF        : Boolean;
  public
    constructor Create(const FileName: AnsiString; Mode: Word);
    destructor Destroy; override;
    function ReadLn: AnsiString;
    property ReadBufSize: Integer read FReadBufSize write FReadBufSize;
    property EOF: Boolean read FEOF;
  end;

  TKTextFileE = class
  private
    fh: TextFile;
    function GetEOF: Boolean;
  public
    constructor Create(const FileName: AnsiString; Mode: Word);
    destructor Destroy; override;
    function ReadLn: AnsiString;
    property EOF: Boolean read GetEOF;
  end;

implementation

uses unit_string;

{ TKTextFileStream }

constructor TKTextFileStream.Create(const FileName: AnsiString; Mode: Word);
begin
  inherited Create(string(FileName), Mode);
  FReadBufSize := 4096 * 2; // �K��
  FBuf := ''; // �o�b�t�@�Ȃ�
  FEOF := False;
  preEOF := False;
end;

destructor TKTextFileStream.Destroy;
begin
  inherited;
end;

function TKTextFileStream.ReadLn: AnsiString;
var
  i: Integer;
  tmp, retcode: AnsiString;

  procedure ReadNewBuf;
  var sz: Integer; prebuf: AnsiString;
  begin
    // �V�K�o�b�t�@�T�C�Y���m��
    SetLength(FBuf, FReadBufSize);
    // �o�b�t�@�����ς��Ƀf�[�^��ǂ�
    sz := Self.Read(FBuf[1], FReadBufSize);


    if sz < FReadBufSize then
    begin
      preEof := True;
    end else
    begin
      preEof := False;
    end;
    if sz > 0 then
    begin
      SetLength(FBuf, sz);
      if (sz > 1)and(FBuf[sz] in [#13,#10]) then // ���E�ɉ��s������΂���Ƀo�b�t�@��ǂ�
      begin
        SetLength(prebuf, FReadBufSize);
        sz := Self.Read(prebuf[1], FReadBufSize);
        if sz > 0 then
        begin
          SetLength(prebuf, sz);
          FBuf := FBuf + prebuf;
        end;
      end;
    end else
    begin
      FBuf := '';
    end;
  end;

  function findRetCode(s: AnsiString): Integer;
  var
    i: Integer;
  begin
    Result := 0;
    i := 1;
    while (i <= Length(s)) do
    begin
      if s[i] in SJISLeadBytes then
      begin
        Inc(i,2); Continue;
      end else
      if s[i] in [#13,#10] then
      begin
        Result := i;
        if Copy(s,i,2) = #13#10 then
        begin
          retcode := #13#10;
        end else
        begin
          retcode := s[1];
        end;
        Break;
      end;
      Inc(i);
    end;
  end;

begin
  Result := ''; retcode := #13#10;
  if (Length(FBuf) <= 0) then
  begin
    // �V�K�o�b�t�@�ǂݎ��
    ReadNewBuf;
  end;

  // �o�b�t�@���ɉ��s�����邩�H
  i := findRetCode(FBuf);
  while (i = 0) do // �o�b�t�@���ɉ��s���Ȃ�
  begin
    // �V�K�o�b�t�@�̓ǂݎ��
    tmp := FBuf; ReadNewBuf; FBuf := tmp + FBuf;
    i := findRetCode(FBuf);
    if (i = 0)and(preEOF)and(FBuf = '') then Break;
    if preEof then Break;
  end;
  // ���s�܂Ő؂���
  if (i > 0) then
  begin
    // ���s�̑O�܂ł𓾂�
    Result := Result + Copy(FBuf, 1, (i-1));
    // ���s�̌�܂Ńo�b�t�@����폜
    FBuf := Copy(FBuf, i + Length(retcode), Length(FBuf));
  end else
  begin
    Result := FBuf; // �S��
    FBuf   := '';
  end;

  if preEOF and (FBuf = '') then
  begin
    FEOF := True;
  end;
end;

{ TKTextFileE }

constructor TKTextFileE.Create(const FileName: AnsiString; Mode: Word);
begin
  Assign(fh, string(FileName));
  if (Mode = fmCreate)or(Mode = fmOpenWrite) then
  begin
    Rewrite(fh);
  end else
  begin
    Reset(fh);
  end;
end;

destructor TKTextFileE.Destroy;
begin
  Close(fh);
  inherited;
end;

function TKTextFileE.GetEOF: Boolean;
begin
  Result := System.Eof(fh);
end;

function TKTextFileE.ReadLn: AnsiString;
begin
  System.Readln(fh, Result);
end;

end.
