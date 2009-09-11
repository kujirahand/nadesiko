AesLib Vers. 1.6
================

© J. Rathlev, IEAP, Uni-Kiel, (rathlev(a)physik.uni-kiel.de)

AesLib.pas is a Delphi interface to the AES encryption routines from
Brian Gladman (http://fp.gladman.plus.com/index.htm). These routines
are used to encrypt and decrypt Zip archives (http://www.winzip.com/aes_info.htm).

The library functions support
  - Generating of a salt value
  - Password verification
  - Generating of authentication code
  - Encryption of a stream
  - Decryption of a stream

The package includes the following files:

AesLib.pas         - Delphi unit with interface to B. Gladmans C routines
fileenc.obj        - compiled C routines (see below)
aescrypt.obj
aeskey.obj
aestab.obj
pwd2key.obj
prng.obj
hmac.obj
sha1.obj
readme.txt         - this file

[sample]
CTest.dpr          - Delphi sample program how to use the library
CTest.res
CTMain.pas
CTMain.dfm

[sources]
fileenc.h          - original file from B.Gladman
fileenc.c          - original file from B.Gladman
aes.h              - original file from B.Gladman
aesopt.h           - modified file from B.Gladman (decryption set)
aescrypt.c         - original file from B.Gladman
aeskey.c           - original file from B.Gladman
aestab.c           - original file from B.Gladman
pwd2key.h          - original file from B.Gladman
pwd2key.c          - original file from B.Gladman
prng.h             - original file from B.Gladman
prng.c             - original file from B.Gladman
hmac.h             - original file from B.Gladman
hmac.c             - original file from B.Gladman
sha1.h             - original file from B.Gladman
sha1.c             - modified file from B.Gladman (little endian set)
bcc.cmd            - batch file to compile with Borland C-compiler

All routines were compiled with the free Borland C-compiler 5.5 using the
included batch file. Function calls are set to use fastcall calling convention
for passing parameters in registers.

J. Rathlev, Jul. 2006

