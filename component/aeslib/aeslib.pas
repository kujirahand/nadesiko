(* Unit:     AESLib.pas
   Interface to the AES functions written by Brian Gladman

   © J. Rathlev, IEAP, Uni-Kiel, (rathlev(a)physik.uni-kiel.de)

   Acknowledgements:
     AES functions from http://fp.gladman.plus.com/index.htm

   The contents of this file may be used under the terms of the
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1.1 - Dec. 2005
   Vers. 1.2 - Jan. 2006
   Vers. 1.3 - Mar. 2006
   Vers. 1.4 - Apr. 2006
   Vers. 1.5 - Jun. 2006 - Callback parameter changed
   Vers. 1.6 - Jul. 2006 - Property KeyMode added

   Field lengths (in bytes) versus File Encryption Mode (0 < KeyMode < 4)
      KeyMode   Password  Key            Salt  MAC  Overhead
      1         <32       16 (128 bit)   8     10   18
      2         <48       24 (192 bit)   12    10   22
      3         >=48      32 (256 bit)   16    10   26

  *)

unit AesLib;


interface

uses Windows, Classes, SysUtils, EftGlobal;

const
  defCryptBufSize = 256*1024;
  BlockSize = 16;               // see aes.h
  KsLength = 4*BlockSize;
  SaltMax = 16;
  MacMax = 32;
  MacLength = 10;
  MaxKeyLength = 32;            // see filenc.h
  MaxPwdLength = 128;
  PwdVerLength = 2;
  KeyingIterarations = 1000;
  ShaBlockSize = 64;            // see sha1.h
  ShaDigestSize = 20;
  ShaLength = 23;
  PrngPoolLen  = 256;           // see prng.h
  PrngMinMix = 20;
  PrngPoolSize = ShaDigestSize*((PrngPoolLen-1) div ShaDigestSize +1);
  AesContextSize = 4*KsLength+4*3;
  HMacContextSize = ShaBlockSize+4*ShaLength+sizeof(integer);
  PrngContextSize = 2*PrngPoolSize+sizeof(integer)+sizeof(pointer);
  FCryptContextSize = 2*BlockSize+AesContextSize+HMacContextSize+3*sizeof(integer);

  // Saltlength depends on mode (password length)
  SaltLength : array [1..3] of cardinal = (8,12,16);

type
  TPrngContext = packed array[0..PrngContextSize-1] of byte;
  TSaltBuf = packed array[0..SaltMax-1] of byte;
  TMacBuffer = packed array[0..MacMax-1] of char;
  TFCryptContext = packed array[0..FCryptContextSize-1] of byte;
  TAesContext = packed array[0..AesContextSize-1] of byte;
  THMacContext = packed array[0..HMacContextSize-1] of byte;
  TPwdVerifier = packed array[0..PwdVerLength-1] of char;

  TCrypt = class (TObject)
  protected
    FMode       : integer;
    FCryptCtx   : TFCryptContext;
    FPwd        : string;
    CBufSize    : cardinal;
    CBuffer     : array of byte;
  public
    constructor Create (Password : string; ABufSize : integer);
    destructor Destroy; override;
    function GetHeaderSize : integer;
    function GetTrailerSize : integer;
    property KeyMode  : integer read FMode;
    end;

  TEncryption = class (TCrypt)
  private
    FPrngCtx    : TPrngContext;
    FOnProgress : TProgressEvent;
  protected
    procedure DoProgress (AAction : TFileAction; ACount : int64);
  public
    constructor Create (Password : string; ABufSize : integer);
    destructor Destroy; override;
    procedure EncryptBlock (var Buffer; BLen : cardinal);
    function WriteHeader (sDest : TStream) : boolean;
    function WriteTrailer (sDest : TStream) : boolean;
    function EncryptStream (sSource,sDest : TStream) : boolean;
    procedure DecryptBlock (var Buffer; BLen : cardinal);
    function ReadHeader (sSource : TStream) : boolean;
    function ReadTrailer (sSource : TStream): boolean;
    function DecryptStream (sSource,sDest: TStream; SLength : int64) : boolean;
    property OnProgress : TProgressEvent read FOnProgress write FOnProgress;
    end;

{ ---------------------------------------------------------------------------- }
implementation

{$L fileenc.obj}
{$L aescrypt.obj}
{$L aeskey.obj}
{$L aestab.obj}
{$L pwd2key.obj}
{$L prng.obj}
{$L hmac.obj}
{$L sha1.obj}

type
  TEntropyFunction = function (var Buffer; Len : cardinal) : integer;

  TLongInteger = record
    case integer of
    0: (AsInt64   : int64);
    1: (Lo,Hi     : Cardinal);
    2: (Cardinals : array [0..1] of Cardinal);
    3: (Words     : array [0..3] of Word);
    4: (Bytes     : array [0..7] of Byte);
    end;

{ ---------------------------------------------------------------------------- }
// entry points for included object files
function fcrypt_init (Mode : integer; const Pwd : PChar; PwdLen : cardinal; const Salt;
              var PwdVerifier : TPwdVerifier; var CryptContext : TFCryptContext) : integer; external;
procedure fcrypt_encrypt (var Data; DataLen : cardinal; var CryptContext : TFCryptContext); external;
procedure fcrypt_decrypt (var Data; DataLen : cardinal; var CryptContext : TFCryptContext); external;
function fcrypt_end (var MacBuf; const CryptContext : TFCryptContext) : integer; external;

function aes_set_encrypt_key (const Key : PChar; KeyLen : cardinal; var AesContext : TAesContext) : cardinal; external;
function aes_set_decrypt_key (const Key : PChar; KeyLen : cardinal; var AesContext : TAesContext) : cardinal; external;
function aes_encrypt_block (const Ib; var Ob; const AesContext : TAesContext) : cardinal; external;
function aes_decrypt_block (const Ib; var Ob; const AesContext : TAesContext) : cardinal; external;

procedure prng_init (Fun : TEntropyFunction; var PrngContext : TPrngContext); external;
procedure prng_rand (var Data; DataLen : cardinal; var PrngContext : TPrngContext); external;
procedure prng_end (var PrngContext : TPrngContext); external;

procedure hmac_sha1_begin (var HMacContext : THMacContext); external;
procedure hmac_sha1_key (const Key : PChar; KeyLen : cardinal; var HMacContext : THMacContext); external;
procedure hmac_sha1_data (const Data : PChar; DataLen : cardinal; var HMacContext : THMacContext); external;
procedure hmac_sha1_end (const Mac : PChar; MacLen : cardinal; var HMacContext : THMacContext); external;

procedure derive_key (const Pwd : PChar; PwdLen : cardinal; const Salt; SaltLen,Iter : cardinal;
             var Key; KeyLen : cardinal); external;

{ ---------------------------------------------------------------------------- }
// replacement for C library functions
procedure _memset (var Dest; Value,Count : integer); cdecl;
begin
  FillChar (Dest,Count,chr(Value));
  end;

procedure _memcpy (var Dest; const Source; Count : integer); cdecl;
begin
  Move (Source,Dest,Count);
  end;

{ ---------------------------------------------------------------------------- }
// Entropy function for "prng"
function Entropy (var Buffer; Len : cardinal) : integer;
var
  Value : Int64;
  i     : integer;  
begin
  // use Windows performance counter as entropie function
  // if not available use the tick count instead (only 4 low bytes)
  if not QueryPerformanceCounter(Value) then Value:=GetTickCount;
  if Len<8 then i:=Len else i:=8;
  Move (Value,Buffer,i);
  Result:=i;
  end;

{ ---------------------------------------------------------------------------- }
function AesEncKey (KeyStr : string; KeyLen : cardinal; var AesContext : TAesContext) : cardinal;
begin
  result:=aes_set_encrypt_key(PChar(KeyStr),KeyLen,AesContext);
  end;

function AesDecKey (KeyStr : string; KeyLen : cardinal; var AesContext : TAesContext) : cardinal;
begin
  result:=aes_set_decrypt_key(PChar(KeyStr),KeyLen,AesContext);
  end;

function AesEncBlk (const AesContext : TAesContext; const Ib; var Ob) : cardinal;
begin
  result:=aes_encrypt_block(PChar(Ib),PChar(Ob),AesContext);
  end;

function AesDecBlk (const AesContext : TAesContext; const Ib; var Ob) : cardinal;
begin
  result:=aes_decrypt_block(PChar(Ib),PChar(Ob),AesContext);
  end;

{ ---------------------------------------------------------------------------- }
// expand short passwords
function ExpandPwd (KeyStr : string; KeyLen : Integer) : string;
begin
  if length(KeyStr)>0 then begin
    repeat
      KeyStr:=KeyStr+KeyStr;
      until length(KeyStr)>KeyLen;
    Result:=copy(KeyStr,1,KeyLen);
    end
  else Result:='';
  end;

{ ---------------------------------------------------------------------------- }
// Crypt object
constructor TCrypt.Create (Password : string; ABufSize : integer);
begin
  inherited Create;
  FPwd:=Password; CBufSize:=ABufSize;
  SetLength(CBuffer,CBufSize);
//  if length(FPwd)<8 then FPwd:=ExpandPwd(FPwd,8);
  if length(FPwd)<32 then FMode:=1
  else if length(FPwd)<48 then FMode:=2
  else FMode:=3;
  end;

destructor TCrypt.Destroy;
begin
  CBuffer:=nil;
  inherited Destroy;
  end;

function TCrypt.GetHeaderSize : integer;
begin
  Result:=SaltLength[FMode]+PwdVerLength;
  end;

function TCrypt.GetTrailerSize : integer;
begin
  Result:=MacLength;
  end;

{ ---------------------------------------------------------------------------- }
// Encryption object
constructor TEncryption.Create (Password : string; ABufSize : integer);
begin
  inherited Create (Password,ABufSize);
  prng_init (Entropy,FPrngCtx);
  FOnProgress:=nil;
  end;

destructor TEncryption.Destroy;
begin
  prng_end (FPrngCtx);
  inherited Destroy;
  end;

{ ------------------------------------------------------------------- }
procedure TEncryption.DoProgress (AAction : TFileAction; ACount : int64);
begin
  if Assigned(FOnProgress) then FOnProgress(Self,AAction,ACount);
  end;

procedure TEncryption.EncryptBlock (var Buffer; BLen : cardinal);
begin
  fcrypt_encrypt(Buffer,BLen,FCryptCtx);
  end;

function TEncryption.WriteHeader (sDest : TStream) : boolean;
var
  SaltBuf     : TSaltBuf;
  FPwdVer     : TPwdVerifier;
begin
  prng_rand (SaltBuf,SaltLength[FMode],FPrngCtx);
  fcrypt_init (FMode,PChar(FPwd),length(FPwd),SaltBuf,FPwdVer,FCryptCtx);
  try
    // write salt value
    sDest.Write (SaltBuf,SaltLength[FMode]);
    // write password verifier
    sDest.Write (FPwdVer,PwdVerLength);
    result:=true;
  except
    result:=false;
    end;
  end;

function TEncryption.WriteTrailer (sDest : TStream) : boolean;
var
  MacBuf : TMacBuffer;
begin
  FillChar(MacBuf,MacMax,0);
  fcrypt_end (MacBuf,FCryptCtx);
  try
    sDest.Write(MacBuf,MacLength);
    result:=true;
  except
    result:=false;
    end;
  end;

function TEncryption.EncryptStream (sSource,sDest : TStream) : boolean;
var
  NRead    : cardinal;
  Total    : int64;
begin
  Result:=false; Total:=0;
  if WriteHeader (sDest) then begin
    repeat
      try
        NRead:=sSource.Read(CBuffer[0],CBufSize);
        inc(Total,NRead);
        DoProgress(acEncrypt,Total);
        EncryptBlock (CBuffer[0],NRead);
        sDest.Write(CBuffer[0],NRead);
      except
        Exit;
        end;
      until (NRead<CBufSize);
    Result:=WriteTrailer (sDest);
    end;
  end;

{ ---------------------------------------------------------------------------- }
// Decryption object
procedure TEncryption.DecryptBlock (var Buffer; BLen : cardinal);
begin
  fcrypt_decrypt(Buffer,BLen,FCryptCtx);
  end;

function TEncryption.ReadHeader (sSource : TStream) : boolean;
var
  SaltBuf     : TSaltBuf;
  FPV1,FPV2   : TPwdVerifier;
begin
  try
    // read salt value
    sSource.Read(SaltBuf,SaltLength[FMode]);
    fcrypt_init (FMode,PChar(FPwd),length(FPwd),SaltBuf,FPV1,FCryptCtx);
    // read password verifier
    sSource.Read (FPV2,PwdVerLength);
    // adjust stream length of encrypted data
    result:=FPV1=FPV2;
  except
    result:=false;
    end;
  end;

function TEncryption.ReadTrailer (sSource : TStream) : boolean;
var
  MB1,MB2 : TMacBuffer;
begin
  FillChar(MB1,MacMax,0); FillChar(MB2,MacMax,0);
  fcrypt_end (MB1,FCryptCtx);
  try
    sSource.Read(MB2,MacLength);
    result:=MB1=MB2;
  except
    result:=false;
    end;
  end;

function TEncryption.DecryptStream (sSource,sDest: TStream; SLength : int64) : boolean;
var
  NRead    : cardinal;
  Total    : int64;
begin
  result:=false; Total:=0;
  DoProgress(acCopy,-sSource.Size);
  if ReadHeader (sSource) then begin
    SLength:=SLength-SaltLength[FMode]-PwdVerLength-MacLength;
    repeat
      if SLength<CBufSize then NRead:=SLength
      else NRead:=CBufSize;
      try
        NRead:=sSource.Read(CBuffer[0],NRead);
        inc(Total,NRead);
        DoProgress(acDecrypt,NRead);
        DecryptBlock (CBuffer[0],NRead);
        if NRead>=0 then begin
          if assigned(sDest) then sDest.Write(CBuffer[0],NRead);
          SLength:=SLength-NRead;
          end;
      except
        Exit;
        end;
      until (SLength<=0);
    result:=ReadTrailer (sSource);
    end;
  end;

{ ---------------------------------------------------------------------------- }

end.

