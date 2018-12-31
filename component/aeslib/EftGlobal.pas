(* Global types, constants and subroutines for
   ExtFileTools, AesLib, FtpFileTools

   © J. Rathlev, IEAP, Uni-Kiel, (rathlev(a)physik.uni-kiel.de)

   The contents of this file may be used under the terms of the
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1.0 - Jun. 2006
   *)

unit EftGlobal;

interface

type
  TFileAction = (acNone,acCopy,acCompress,acUnCompress,acEncrypt,acDecrypt,acVerify,acFtpWrite,acFtpRead);
  TProgressEvent = procedure(Sender: TObject; AAction : TFileAction; ACount: int64) of object;

const
  // error codes
  errOK         = 0;
  errFileCreate = 1;
  errFileOpen   = 2;
  errFileClose  = 3;
  errFileRead   = 4;
  errFileWrite  = 5;
  errFileAttr   = 6;
  errFileFull   = 7;
  errFileGZip   = 8;  // ill. GZip header
  errFileCheck  = 9;  // corrupt copied or packed file
  errFileECrypt = 10; // error encrypting file
  errFileDCrypt = 11; // error decrypting file
  errFileVerify = 12; // verify error
  errFtpRead    = 24; // error reading via FTP
  errFtpWrite   = 25; // error writing via FTP
  errFtpConnect = 26; // connection error on FTP
  errUserBreak  = $100; // process stopped bei user
  errAllCodes   = $0FFF;

  errCopy      = $1000;
  errGZip      = $2000;
  errGUnzip    = $3000;
  errZip       = $4000;
  errEncrypt   = $5000;
  errDecrypt   = $6000;
  errAllTypes  = $F000;

// get error message
function GetCopyErrMsg (AError : integer) : string;

implementation

{ ------------------------------------------------------------------- }
// get error message
function GetCopyErrMsg (AError : integer) : string;
var
  s : string;
begin
  case AError and errAllCodes of
  errFileCreate : s:='Create file error';
  errFileOpen   : s:='Open file error';
  errFileClose  : s:='Close file error';
  errFileRead   : s:='Read file error';
  errFileWrite  : s:='Write file error';
  errFileAttr   : s:='Set file attr. error';
  errFileFull   : s:='Low disk space';
  errFileGZip   : s:='Illegal GZip header';
  errFileCheck  : s:='Corrupt file';
  errFileECrypt : s:='Encryption error';
  errFileDCrypt : s:='Decryption error';
  errFileVerify : s:='Verify error';
  errFtpRead    : s:='FTP read error';
  errFtpWrite   : s:='FTP write error';
  errFtpConnect : s:='FTP connection failed';
  errUserBreak  : s:='Terminated by user';
  else s:='Unknown error';  // should not happen
    end;
  case AError and errAllTypes of
  errCopy       : s:=s+' (Copy)';
  errGZip       : s:=s+' (GZip)';
  errGUnzip     : s:=s+' (GUnzip)';
  errZip        : s:=s+' (Zip)';
  errEnCrypt    : s:=s+' (Encrypt)';
  errDeCrypt    : s:=s+' (Decrypt)';
    end;
  Result:=s;
  end;

end.
 
