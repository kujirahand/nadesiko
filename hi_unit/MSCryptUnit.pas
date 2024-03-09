unit MSCryptUnit;
{
-------------------------
����F�N�W����s�� (2004/01/09)

2004/01/21 �S�ʓI�ɉ��� wcrypy2 ���j�b�g���g�����Ƃɂ���

-------------------------

�y�T�v�z
  Windows CryptoAPI �� ���b�p�[

�y������z
  Windows NT: Requires version 4.0 or later.
  Windows: Requires Windows 95 OSR2 or later
	 (or Windows 95 with IE 3.02 or later).

}
interface
uses
  Classes,
  SysUtils,
  Windows,
  wcrypt2;

const
  NTE_NO_KEY = $8009000D;

type
  TCipherMode = (cmBlock, cmStream);

  EMSCryptAPI = class(Exception);
  TMSCryptAPI = class(TObject)
  private
    hProv     : HCRYPTPROV;
    hKey      : HCRYPTKEY;
    hXchgKey  : HCRYPTKEY;
    hHash     : HCRYPTHASH;

    ENCRYPT_ALGORITHM   : DWORD;
    ENCRYPT_BLOCK_SIZE  : DWORD;
    KEY_LENGTH : DWORD;

    pbKeyBlob     : PBYTE;
    dwKeyBlobLen  : DWORD;

    pbBuffer    : PBYTE;
    dwBlockLen  : DWORD;
    dwBufferLen : DWORD;
    dwCount     : DWORD;

    endof : Boolean;

    FMode: TCipherMode;
    FErrorCode: Integer;
    FErrorStr: string;

    FInit: Boolean;
    procedure InitAll;
    procedure ClearAll;
    function GetErrorStr: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure InitCrypt; // --- CSP �P�x�������s����� OK
    function Encrypt(
      inputStream: TStream;
      const password: string;
      outputStream: TStream) : boolean;
    function Decrypt(
      inputStream: TStream;
      const password: string;
      outputStream: TStream) : boolean;
    procedure SetMode(Value: TCipherMode);
    property Mode: TCipherMode read FMode write SetMode;
    property ErrorStr: string read GetErrorStr;

  end;

function GetLastErrorStr(ErrorCode: Integer): String;

//EncryptEasy ��C�R�[�h�̒񋟂́Atomo ����B����
//DecryptEasy
function EncryptEasy(source: string; password: string): string;
function DecryptEasy(source: string; password: string): string;

implementation

const
  BUFFER_SIZE = 100{KB} * 1024;
  DEFAULT_PASSWORD = 'adfhw902nvdfw9023e2jdvadkl2930';

function EncryptEasy(source: string; password: string): string;
var
  buf: string;
  hProv: HCRYPTPROV;
  hPwdHash: HCRYPTHASH;
  hKey: HCRYPTKEY;
  source_len: Integer;
  len: Integer;
  mem_in: TMemoryStream;
  mem_out: TMemoryStream;
begin
  // �����̃`�F�b�N
  Result := '';
  if password = '' then password := DEFAULT_PASSWORD;
  if source = '' then Exit;

  // ��Ɨp�o�b�t�@�̊m��
  SetLength(buf, BUFFER_SIZE);

  //Crypt API �̏�����
  if (not CryptAcquireContext(@hProv, nil, MS_DEF_PROV, PROV_RSA_FULL, 0)) then
  begin
    if (not CryptAcquireContext(@hProv, nil, MS_DEF_PROV, PROV_RSA_FULL, CRYPT_NEWKEYSET)) then
    begin
      // ���s
      raise Exception.Create('�Í����ŏ������Ɏ��s');
    end;
  end;

  // �n�b�V���̏�����
  CryptCreateHash(hProv, CALG_MD5, 0, 0, @hPwdHash);
  CryptHashData(hPwdHash, @password[1], Length(password), 0); // Pascal �� string �� �v�f�ԍ��� 1 ����
  CryptDeriveKey(hProv, CALG_RC2, hPwdHash, 0, @hKey);
  try
    // �J��Ԃ��Í���
    mem_in := TMemoryStream.Create ;
    mem_out := TMemoryStream.Create ;
    try
      mem_in.Write(source[1], Length(source));
      mem_in.Position := 0;
      source_len := Length(source);
      repeat
        len := mem_in.Read(buf[1], BUFFER_SIZE div 2);
        Dec(source_len, len);
        CryptEncrypt(hKey, 0, TRUE, 0, @buf[1], @len, BUFFER_SIZE);
        mem_out.Write(buf[1], len);
      until (source_len <= 0);
      mem_out.Position := 0;
      SetLength(Result, mem_out.Size);
      mem_out.Read(Result[1], mem_out.Size);
    finally
      mem_in.Free ;
      mem_out.Free ;
    end;
  finally
    CryptDestroyKey(hKey);
    CryptDestroyHash(hPwdHash);
    CryptReleaseContext(hProv, 0);
  end;
end;

function DecryptEasy(source: string; password: string): string;
var
  buf: string;
  hProv: HCRYPTPROV;
  hPwdHash: HCRYPTHASH;
  hKey: HCRYPTKEY;
  source_len: Integer;
  len: Integer;
  mem_in: TMemoryStream;
  mem_out: TMemoryStream;
begin
  // �����̃`�F�b�N
  Result := '';
  if password = '' then password := DEFAULT_PASSWORD;
  if source = '' then Exit;

  // ��Ɨp�o�b�t�@�̊m��
  SetLength(buf, BUFFER_SIZE);

  //Crypt API �̏�����
  if (not CryptAcquireContext(@hProv, nil, MS_DEF_PROV, PROV_RSA_FULL, 0)) then
  begin
    if (not CryptAcquireContext(@hProv, nil, MS_DEF_PROV, PROV_RSA_FULL, CRYPT_NEWKEYSET)) then
    begin
      // ���s
      raise Exception.Create('�Í����ŏ������Ɏ��s');
    end;
  end;

  // �n�b�V���̏�����
  CryptCreateHash(hProv, CALG_MD5, 0, 0, @hPwdHash);
  CryptHashData(hPwdHash, @password[1], Length(password), 0); // Pascal �� string �� �v�f�ԍ��� 1 ����
  CryptDeriveKey(hProv, CALG_RC2, hPwdHash, 0, @hKey);
  try
    // �J��Ԃ��Í���
    mem_in := TMemoryStream.Create ;
    mem_out := TMemoryStream.Create ;
    try
      mem_in.Write(source[1], Length(source));
      mem_in.Position := 0;
      source_len := Length(source);
      repeat
        len := mem_in.Read(buf[1], BUFFER_SIZE);
        Dec(source_len, len);
        CryptDecrypt(hKey, 0, TRUE, 0, @buf[1], @len);
        mem_out.Write(buf[1], len);
      until (source_len <= 0);
      mem_out.Position := 0;
      SetLength(Result, mem_out.Size);
      mem_out.Read(Result[1], mem_out.Size);
    finally
      mem_in.Free ;
      mem_out.Free ;
    end;
  finally
    CryptDestroyKey(hKey);
    CryptDestroyHash(hPwdHash);
    CryptReleaseContext(hProv, 0);
  end;
end;


function GetLastErrorStr(ErrorCode: Integer): String;
const
  MAX_MES = 512;
var
  Buf: PChar;
begin
  Buf := AllocMem(MAX_MES);
  try
    FormatMessage(Format_Message_From_System, Nil, ErrorCode,
                  (SubLang_Default shl 10) + Lang_Neutral,
                  Buf, MAX_MES, Nil);
  finally
    Result := Buf;
    FreeMem(Buf);
  end;
end;


{ TMSCryptAPI }

constructor TMSCryptAPI.Create;
begin
  FInit := False;
  Mode := cmBlock;
  //Mode := cmStream;
end;

destructor TMSCryptAPI.Destroy;
begin
  ClearAll ;
  inherited;
end;

function TMSCryptAPI.Encrypt(inputStream: TStream; const password: string;
  outputStream: TStream): boolean;
begin
  InitAll ;
  Result := False;
  try
    // �f�t�H���g�L�[�R���e�i�̃n���h���𓾂�
    if not CryptAcquireContext(@hProv,nil, MS_DEF_PROV, PROV_RSA_FULL,0) then
    begin
      raise Exception.Create('CryptAcquireContext');
    end;
    if password = '' then
    begin
      // �p�X���[�h���Ȃ���΁A�����_���L�[���g���ĈÍ���
      // �L�[�n���h���𓾂�
      if not CryptGenKey(hProv, ENCRYPT_ALGORITHM, CRYPT_EXPORTABLE,@hKey) then
      begin
        raise Exception.Create('CryptGenKey');
      end;
      // �����L�[�̃n���h���𓾂�
      if not CryptGetUserKey(hProv,AT_KEYEXCHANGE,@hXchgKey) then
      begin
        raise Exception.Create('CryptGenKey(AT_KEYEXCHANGE)');
      end;
      // �v�Z(Calculate the key blob length and alloc a memory pool.)
      if not CryptExportKey(hKey,hXchgKey,SIMPLEBLOB,0,nil,@dwKeyBlobLen) then
      begin
        raise Exception.Create('CryptExportKey');
      end;
      // �������̎擾
      try
        GetMem(pbKeyBlob, dwKeyBlobLen);
      except
        on EOutOfMemory do raise;
      end;
      // Export session key in key blob.
      if not CryptExportKey(hKey,hXchgKey,SIMPLEBLOB,0,pbKeyBlob,@dwKeyBlobLen) then
      begin
        raise Exception.Create('CryptExportKey');
      end;
      // �����L�[�̔j�� : Free the handle used for exchange keys.
      CryptDestroyKey(hXchgKey);
      hXchgKey := 0;
      // �o��
      outputStream.WriteBuffer(dwKeyBlobLen, 1);
      outputStream.WriteBuffer(pbKeyBlob^, dwKeyBlobLen);
    end else
    begin
      // �p�X���[�h��p���ĈÍ�������
      // �n�b�V���n���h���𓾂�
      if not CryptCreateHash(hProv,CALG_MD5,0,0,@hHash) then
      begin
        raise Exception.Create('CryptCreateHash');
      end;
      // �p�X���[�h���n�b�V������ : Hashing on password value.
      if not CryptHashData(hHash,PBYTE(password), Length(password),0) then
      begin
        raise Exception.Create('CryptHashData');
      end;
      // �n�b�V���𓾂� Derive session key from hash.
      if not CryptDeriveKey(hProv, ENCRYPT_ALGORITHM, hHash, CRYPT_EXPORTABLE, @hKey) then
      begin
        raise Exception.Create('CryptDeriveKey');
      end;
      // �n�b�V���n���h���̔j��
      CryptDestroyHash(hHash);
      hHash := 0;
    end;

    // Block of bytes for ciphering, block is a multiple of ENCRYPT_BLOCK_SIZE.
    dwBlockLen := 1000 - 1000 mod ENCRYPT_BLOCK_SIZE;

    // If using a block cipher you must add ENCRYPT_BLOCK_SIZE.
    if ENCRYPT_BLOCK_SIZE > 1 then dwBufferLen := dwBlockLen + ENCRYPT_BLOCK_SIZE
                              else dwBufferLen := dwBlockLen;

    // �������̎擾
    try
      GetMem(pbBuffer,dwBufferLen);
    except
      on EOutOfMemory do raise;
    end;

    // �Í���
    repeat
      dwCount := inputStream.Read(pbBuffer^, dwBlockLen);
      Endof   := (dwCount < dwBlockLen);
      if not CryptEncrypt(hKey, 0, Endof, 0, pbBuffer, @dwCount, dwBufferLen) then
      begin
        raise Exception.Create('CryptEncrypt');
      end;
      outputStream.Write(pbBuffer^, dwCount);
    until Endof;
    Result := True;
    ClearAll;
  except
    // ��O���N�����Ƃ�
    on e: Exception do
    begin
      FErrorCode := GetLastError ;
      FErrorStr  := e.Message;
      // ���������N���A���Ĕ�����
      ClearAll;
      Exit;
    end;
  end;
end;

function TMSCryptAPI.Decrypt(inputStream: TStream; const password: string;
  outputStream: TStream): boolean;
begin
  InitAll;
  Result := False;
  try
    // �f�t�H���g�L�[�R���e�i�̃n���h���𓾂�
    if not CryptAcquireContext(@hProv,nil,nil, PROV_RSA_FULL,0) then
    begin
      raise Exception.Create('CryptAcquireContext');
    end;
    if password = '' then
    begin
      // �p�X���[�h���Ȃ���΁A�L�[��ǂ�
      inputStream.Read(dwKeyBlobLen, 1);
      try
        GetMem(pbKeyBlob, dwKeyBlobLen);
      except
        on EOutOfMemory do ClearAll;
      end;
      inputStream.Read(pbKeyBlob^, dwKeyBlobLen);
      // Import Key Blob in CSP.
      if not CryptImportKey(hProv, pbKeyBlob, dwKeyBlobLen,0,0,@hKey) then
      begin
        raise Exception.Create('CryptImportKey');
      end;
    end else
    begin
      // Decrypt with a session key derived from password.
      // Build Hash.
      if not CryptCreateHash(hProv,CALG_MD5,0,0,@hHash) then
      begin
        raise Exception.Create('CryptCreateHash');
      end;
      // Obtain hash data from password.
      if not CryptHashData(hHash, PBYTE(password), Length(password),0) then
      begin
        raise Exception.Create('CryptHashData');
      end;
      // Derive session key from hash.
      if not CryptDeriveKey(hProv,ENCRYPT_ALGORITHM,hHash,0,@hKey) then
      begin
        raise Exception.Create('CryptDeriveKey');
      end;
      // Destroy hash.
      CryptDestroyHash(hHash);
      hHash := 0;
    end;

    // Block of bytes for ciphering, block is a multiple of ENCRYPT_BLOCK_SIZE.
    dwBlockLen := 1000 - 1000 mod ENCRYPT_BLOCK_SIZE;

    // If using a block cipher you must add ENCRYPT_BLOCK_SIZE.
    if ENCRYPT_BLOCK_SIZE > 1 then dwBufferLen := dwBlockLen + ENCRYPT_BLOCK_SIZE
                              else dwBufferLen := dwBlockLen;

    // �������̎擾
    try
      GetMem(pbBuffer, dwBufferLen);
    except
      on EOutOfMemory do ClearAll;
    end;

    // Decrypt source file and write in destination file.
    repeat
      // Read until dwBlockLen bytes from source file.
      dwCount := inputStream.Read(pbBuffer^, dwBlockLen);
      Endof   := (dwCount < dwBlockLen);
      // Decrypt data.
      if not CryptDecrypt(hKey, 0, Endof, 0, pbBuffer, @dwCount) then
      begin
        raise Exception.Create('CryptDecrypt');
      end;
      outputStream.Write(pbBuffer^,dwCount);
    until Endof;

    Result := True;
    ClearAll;
  except
    // ��O���N�����Ƃ�
    on e: Exception do
    begin
      FErrorCode := GetLastError ;
      FErrorStr  := e.Message;
      // ���������N���A���Ĕ�����
      ClearAll;
      Exit;
    end;
  end;
end;

procedure TMSCryptAPI.InitAll;
begin
  hProv := 0;
  hKey := 0;
  hXchgKey := 0;
  hHash := 0;
  pbKeyBlob := nil;
  pbBuffer := nil;
  dwKeyBlobLen := 0;
  endof := False;
  KEY_LENGTH := 128;
end;

procedure TMSCryptAPI.InitCrypt;
var
  hProv:  HCRYPTPROV;
  hKey:   HCRYPTKEY;
begin
  if FInit then Exit;

  //�f�t�H���g�L�[�R���e�i�̃n���h�����擾����
  if not CryptAcquireContext(@hProv, nil, MS_DEF_PROV, PROV_RSA_FULL, 0) then
  begin
    //�����f�t�H���g�L�[�R���e�i�����������ꍇ�A�f�t�H���g�L�[�R���e�i�����
    if not CryptAcquireContext(@hProv, nil, MS_DEF_PROV, PROV_RSA_FULL, CRYPT_NEWKEYSET) then
    begin
      raise EMSCryptAPI.Create('CryptAcquireContext : '+GetLastErrorStr(GetLastError));
    end;
  end;

  //�����L�[�̃n���h�����擾����
  if not CryptGetUserKey(hProv, AT_SIGNATURE, @hKey) then
  begin
    if (GetLastError = NTE_NO_KEY) then
    begin
      //�����L�[�̃y�A�����
      if not CryptGenKey(hProv, AT_SIGNATURE, 0, @hKey) then
      begin
        // �L�[�n���h���̍쐬�Ɏ��s
        raise EMSCryptAPI.Create('CryptGenKey(AT_SIGNATURE) : ' + GetLastErrorStr(GetLastError));
      end else
      begin
        CryptDestroyKey(hKey);
      end;
    end else
    begin
      // �L�[�n���h���̎擾�Ɏ��s
      raise EMSCryptAPI.Create('CryptGetUserKey(AT_SIGNATURE) : ' + GetLastErrorStr(GetLastError));
    end;
  end;

  //�����L�[�̃n���h�����擾����
  if not CryptGetUserKey(hProv, AT_KEYEXCHANGE, @hKey) then
  begin
    if(GetLastError = NTE_NO_KEY) then
    begin
      //�����L�[�̃y�A�����
      if not CryptGenKey(hProv, AT_KEYEXCHANGE, 0, @hKey) then
      begin
        raise EMSCryptAPI.Create('CryptGetUserKey(AT_KEYEXCHANGE) : ' + GetLastErrorStr(GetLastError));
      end else
      begin
        CryptDestroyKey(hKey);
      end;
    end else
    begin
      raise EMSCryptAPI.Create('CryptGetUserKey(AT_KEYEXCHANGE) : ' + GetLastErrorStr(GetLastError));
    end;
  end;

  CryptReleaseContext(hProv,0);
  FInit := True;
end;

function TMSCryptAPI.GetErrorStr: string;
begin
  Result := FErrorStr + ':' + GetLastErrorStr(FErrorCode); 
end;

procedure TMSCryptAPI.SetMode(Value: TCipherMode);
begin
  case Value of
    cmBlock :
      begin
        FMode := cmBlock;
        ENCRYPT_ALGORITHM := CALG_RC2;
        ENCRYPT_BLOCK_SIZE := 8;
      end;
    cmStream :
      begin
        FMode := cmStream;
        ENCRYPT_ALGORITHM := CALG_RC4;
        ENCRYPT_BLOCK_SIZE := 1;
      end;
  end;
end;

procedure TMSCryptAPI.ClearAll;
begin
  if pbKeyBlob <> nil then Dispose(pbKeyBlob);
  if pbBuffer  <> nil then Dispose(pbBuffer);

  pbKeyBlob := nil;
  pbBuffer  := nil;

  {Destroy Session Key.}
  if boolean(hKey)      then CryptDestroyKey(hKey);
  {Close Exchange Key.}
  if boolean(hXchgKey)  then CryptDestroyKey(hXchgKey);
  {Destroy Hash.}
  if boolean(hHash)     then CryptDestroyHash(hHash);
  {Close CSP Handle.}
  if boolean(hProv)     then CryptReleaseContext(hProv,0);
end;

end.
