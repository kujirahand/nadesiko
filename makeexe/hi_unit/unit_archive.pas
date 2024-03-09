unit unit_archive;

// ���k�𓀂̂��߂̃��j�b�g

interface

uses
  Windows, SysUtils, hima_types, Zip32, UnZip32, unit_file;

// UNLHA32.DLL ���g�������k��
procedure lha_compress(srcFile, desFile: string);
procedure lha_extract(srcFile, desFile: string);
procedure lha_makeSFX(src, des: string);

// UNZIP32.DLL / ZIP32/DLL ���g�������k��
procedure zip_compress(srcFile, desFile: string);
procedure zip_extract(srcFile, desFile: string);

// cab32.dll
procedure cab_compress(srcFile, desFile: string);
procedure cab_extract(srcFile, desFile: string);

// 7-zip32.dll
procedure zip7_compress(srcFile, desFile: string);
procedure zip7_extract(srcFile, desFile: string);

// Yz1
procedure yz1_compress(srcFile, desFile: string);
procedure yz1_extract(srcFile, desFile: string);
procedure unyz1_extract(srcFile, desFile: string);



var
  LhaOption   : string = '-a1 -r2 -x1 -l0 -jp1 -o2 -ji0 -n0';
  UnlhaOption : string = '-a1 -r2 -x1 -jp1 -c0 -m1';
  SfxOption   : string = '-x1 -r2 -gx0 -gw4';

type
  TArchieveFunc = function (const hWnd: HWND; szCmdLine: PChar; szOutput: PChar; dwSize: DWORD): Integer; stdcall;

var
  Cab      : TArchieveFunc;
  SevenZip : TArchieveFunc;
  Yz1      : TArchieveFunc;
  UnYz1    : TArchieveFunc;

// for DLL
function UnlhaCommand   (command: string): string;
function SevenZipCommand(command: string): string;
function CabCommand     (command: string): string;
function Yz1Command     (command: string): string;
function Unyz1Command   (command: string): string;

//
procedure UnlhaCreate;
procedure UnlhaFree;
function Cab32Load: Boolean;
function Cab32Free: Boolean;
function SevenZip32Load: Boolean;
function SevenZip32Free: Boolean;
function Yz1Load: Boolean;
function Yz1Free: Boolean;
//
function LoadLibrary(fname: string): HMODULE;

var ArchiveWinHandle: HWND = 0; // MainWindowHandle ��ݒ肷��
var PATH_ARCHIVE_DLL: string = '';

implementation


var
  Cab32Handle   : THandle = 0;
  SevenZipHandle: THandle = 0;
  UnlhaHandle   : THandle = 0;
  Yz1Handle     : THandle = 0;
  UnYz1Handle   : THandle = 0;

const
  SevenZipDllName = '7-zip32.dll';

function LoadLibrary(fname: string): HMODULE;
var
  f: string;
begin
  // load
  if PATH_ARCHIVE_DLL <> '' then
  begin
    f := PATH_ARCHIVE_DLL + fname;
    Result := Windows.LoadLibrary(PChar(f));
    if (Result > HINSTANCE_ERROR) then Exit;
  end;
  // load
  Result := Windows.LoadLibrary(PChar(fname));
  // error ?
  if (Result <= HINSTANCE_ERROR) then
  begin
    // load apppath
    f := ExtractFilePath(ParamStr(0)) + fname;
    Result := Windows.LoadLibrary(PChar(f));
    if (Result <= HINSTANCE_ERROR) then
    begin
      // load apppath + plug-ins
      f := ExtractFilePath(ParamStr(0)) + 'plug-ins\' + fname;
      Result := Windows.LoadLibrary(PChar(f));
      if (Result <= HINSTANCE_ERROR) then
      begin
        // error
      end;
    end;
  end;
end;

{MainWindowHandle �𓾂�}
function getMainWinHandle: HWND;
begin
  if ArchiveWinHandle = 0 then
  begin
    // ArchiveWinHandle := GetForegroundWindow;
  end;
  Result := ArchiveWinHandle;
end;

{Windows�t�H���_�𓾂�}
function WinDir:string;
var
  TempWin:array[0..MAX_PATH] of Char;
begin
  GetWindowsDirectory(TempWin,MAX_PATH);
  Result:=StrPas(TempWin);
  if Copy(Result,Length(Result),1)<>'\' then Result := Result + '\';
end;

{System�t�H���_�𓾂�}
function SysDir:string;
var
  TempSys:array[0..MAX_PATH] of Char;
begin
  GetSystemDirectory(TempSys,MAX_PATH);
  Result:=StrPas(TempSys);
  if Copy(Result,Length(Result),1)<>'\' then Result := Result + '\';
end;



function Cab32Load: Boolean;
begin
  Cab32Handle := LoadLibrary('cab32.dll');
  Result      := (Cab32Handle > HINSTANCE_ERROR);
  if Result = False then
  begin
    Cab32Handle := 0;
    Exit;
  end;
  Cab := GetProcAddress(Cab32Handle, 'Cab');
end;

function Cab32Free: Boolean;
begin
  Result := FreeLibrary(Cab32Handle);
end;

function Yz1Load: Boolean;
begin
  Yz1Handle := LoadLibrary('yz1.dll');
  Result      := (Yz1Handle > HINSTANCE_ERROR);
  if Result = False then
  begin
    Yz1Handle := 0;
    Exit;
  end;
  Yz1 := GetProcAddress(Yz1Handle, 'Yz1');
end;

function Yz1Free: Boolean;
begin
  Result := FreeLibrary(Yz1Handle);
end;

function UnYz1Load: Boolean;
begin
  UnYz1Handle := LoadLibrary('unyz1.dll');
  Result      := (UnYz1Handle > HINSTANCE_ERROR);
  if Result = False then
  begin
    UnYz1Handle := 0;
    Exit;
  end;
  UnYz1 := GetProcAddress(UnYz1Handle, 'UnYz1');
end;

function UnYz1Free: Boolean;
begin
  Result := FreeLibrary(Yz1Handle);
end;

function SevenZip32Load: Boolean;
begin
  Result := True;
  if SevenZipHandle <> 0 then Exit;
  SevenZipHandle := LoadLibrary(SevenZipDllName);
  Result         := (SevenZipHandle > HINSTANCE_ERROR);
  if Result = False then
  begin
    SevenZipHandle := 0;
    Exit;
  end;
  SevenZip := GetProcAddress(SevenZipHandle, 'SevenZip');
end;
function SevenZip32Free: Boolean;
begin
  Result := FreeLibrary(SevenZipHandle);
  if Result then
  begin
    SevenZipHandle := 0;
    SevenZip := nil;
  end;
end;


//------------------------------------------------------------------------------
// UnlhaCommand �̂��߂̊֐�

var
  Unlha: function(const _hwnd: HWND; _szCmdLine: pchar; _szOutput: pchar; const _wSize: longint): integer; stdcall;

function GetBasePath(srcFiles: THStringList): string;
var
  min: string;
  i: Integer;
  FlagContinue: Boolean;
  s: string;
begin
  if srcFiles.Count = 0 then begin Result := ''; Exit; end;

  min := ExtractFilePath(srcFiles.Strings[0]);
  while (min <> '') do
  begin
    FlagContinue := False;
    for i := 0 to srcFiles.Count - 1 do
    begin
      s := ExtractFilePath(srcFiles.Strings[i]);
      if Copy(s,1,Length(min)) <> min then
      begin
        FlagContinue := True;
        min := ExtractFilePath(min);
        Break;
      end;
    end;
    if FlagContinue=False then Break;
  end;
  Result := min;
end;

procedure DeleteBasePath(srcFiles: THStringList; basePath: string);
var
  i: Integer;
  s: string;
begin
  for i:=0 to srcFiles.Count-1 do
  begin
    s := srcFiles.Strings[i];
    if Copy(s, 1, Length(basePath)) = basePath then
    begin
      System.Delete(s, 1, Length(basePath));
      srcFiles.Strings[i] := s;
    end;
  end;
end;

procedure UnlhaCreate;
var
  h: THandle;
  p: TFarProc;
begin
  h := LoadLibrary('UNLHA32.DLL');
  if h < HINSTANCE_ERROR then begin
    UnlhaHandle := 0;
    raise Exception.Create('UNLHA32.DLL��������܂���B�C���X�g�[�����Ă��������B');
  end else begin
    p := GetProcAddress(h, 'Unlha');
    if p <> nil then @Unlha := p;
    UnlhaHandle := h;
  end;
end;

procedure UnlhaFree;
begin
  if UnlhaHandle <> 0 then FreeLibrary(UnlhaHandle);
end;

function UnlhaCommand(command: string): string;
begin
  UnlhaCreate;
  try
    try
      SetLength(Result, 1024);
      UnLha(getMainWinHandle, PChar(command), PChar(Result), 1023);
      Result := string(PChar(Result));
      if Pos('error', LowerCase(Result)) > 0 then
      begin
        MessageBox(getMainWinHandle, PChar(Result), 'Unlha32.dll���', MB_OK);
      end;
    except
      raise Exception.Create('Unlha32.dll�G���[:'+Result);
    end;
  finally
    UnLhaFree;
  end;
end;

procedure lha_compress(srcFile, desFile: string);
var
  cmd, basePath, fs : string;
  srcFiles : THStringList;
  i: Integer;
begin
  srcFiles := THStringList.Create ;
  try
    srcFiles.Text := srcFile ;

    // basePath ��T��
    basePath := GetBasePath(srcFiles);

    // bathpath �����
    DeleteBasePath(srcFiles, basePath);

    // �t�@�C���̈ꗗ��Ԃ�
    fs := '';
    for i := 0 to srcFiles.Count - 1 do
    begin
      fs := fs + '"' + srcFiles.Strings[i] + '" ';
    end;

    //cmd := a -a1 -r2 -x1 -jp1 "���ɖ�" "��f�B���N�g��" "�p�X��"
    cmd := 'a '+LhaOption+' "'+desFile+'" "'+basePath+'" '+fs;
    UnlhaCommand(cmd);
  finally
    srcFiles.Free;
  end;
end;

procedure lha_extract(srcFile, desFile: string);
var
  cmd: string;
begin
  cmd := 'e '+ UnlhaOption + ' "'+srcFile+'" "'+desFile+'"';
  UnlhaCommand(cmd);
end;

procedure lha_makeSFX(src, des: string);
var
  flagDeleteSrc: Boolean;
  cmd,fp,fn: string;
begin
  flagDeleteSrc := False;

  //SFX�́A�܂��ALZH������Ă����Ă���ϊ�����
  if UpperCase(ExtractFileExt(src)) <> '.LZH' then
  begin
    fp := ExtractFilePath(des);
    fn := ExtractFileName(des);
    fn := ChangeFileExt(fn,'.lzh');
    lha_compress(src, fp + fn);
    flagDeleteSrc := True;
    src := fp + fn;
  end else
  begin
    fp := ExtractFilePath(src);
    fn := ExtractFileName(src);
  end;

  fn := ChangeFileExt(fn,'');
  cmd := 's -gw "'+fp+fn+'" "'+fp+'" -gr"'+ExtractFileName(des)+'" '+SfxOption;

  UnlhaCommand(cmd);

  // ��Еt��������
  if flagDeleteSrc then
  begin
    DeleteFile(src);
  end;

end;

//------------------------------------------------------------------------------
// Zip32.dll �̂��߂̊֐�
{----------------------------------------------------------------------------------}
function DummyPrint(Buffer: PChar; Size: LongWord): Integer; stdcall;
begin
  if Buffer <> nil then
  begin
    if StrPos(Buffer, 'error') <> nil then
      MessageBox(UnlhaHandle, Buffer, 'Zip32.dll����̏��', MB_OK);
  end;
  Result := Size;
end;
{----------------------------------------------------------------------------------}
function DummyPassword(P: PChar; N: Integer; M, Name: PChar): Integer; stdcall;
begin
  Result := 1;
end;
{----------------------------------------------------------------------------------}
function DummyComment(Buffer: PChar): PChar; stdcall;
begin
  Result := Buffer;
end;
{----------------------------------------------------------------------------------}
procedure SetDummyInitFunctions(var Z:TZipUserFunctions);
begin
  { prepare ZipUserFunctions structure }
  with Z do
  begin
    @Print     := @DummyPrint;
    @Comment   := @DummyPassword;
    @Password  := @DummyComment;
  end;
  { send it to dll }
  ZpInit(Z);
end;
{----------------------------------------------------------------------------------}
procedure ZipFiles(FileName : string; FileList: THStringList);
var
  i        : integer;
  ZipRec   : TZCL;
  ZUF      : TZipUserFunctions;
begin

  { precaution }
  if Trim(FileName) = '' then Exit;
  if FileList.Count <= 0 then Exit;

  { initialize the dll with dummy functions }
  SetDummyInitFunctions(ZUF);


  { number of files to zip }
  ZipRec.argc := FileList.Count;

  { name of zip file - allocate room for null terminated string  }
  GetMem(ZipRec.lpszZipFN, Length(FileName) + 1 );
  ZipRec.lpszZipFN := StrPCopy( ZipRec.lpszZipFN, FileName);


  { dynamic array allocation }
  SetLength(ZipRec.FNV, ZipRec.argc );

  { copy the file names from FileList to ZipRec.FNV dynamic array }
  for i := 0 to ZipRec.argc - 1 do
  begin
    GetMem(ZipRec.FNV[i], Length(FileList[i]) + 1 );
    StrPCopy( ZipRec.FNV[i], FileList[i]);
  end;

  { send the data to the dll }
  ZpArchive(ZipRec);


  { release the memory for the file list }
  for i := (ZipRec.argc - 1) downto 0 do
    FreeMem(ZipRec.FNV[i], Length(FileList[i]) + 1 );

  { release the memory for the ZipRec.FNV dynamic array
    NOTE : This line actually is useless.
           Dynamic arrays are lifitime managed, just like long strings.
           They released when they live scope}
  ZipRec.FNV := nil;

  { release the memory for the FileName }
  FreeMem(ZipRec.lpszZipFN, Length(FileName) + 1 );

end;

function apppath: string;
begin
  Result := ExtractFilePath(ParamStr(0));
end;

function Use7zip32: Boolean;
begin
  Result := True;
  if FileExists(apppath + 'plug-ins\' + SevenZipDllName) then Exit;
  if FileExists(apppath + SevenZipDllName) then Exit;
  if FileExists(WinDir + SevenZipDllName) then Exit;
  if FileExists(SysDir + SevenZipDllName) then Exit;
  Result := False;
end;

procedure zip_compress(srcFile, desFile: string);
var
  opts: ZPOPT;
  srcFiles, fs, tmp: THStringList;
  basePath, s: string;
  i: Integer;
begin
  if Use7zip32 then
  begin
    zip7_compress(srcFile, desFile);
    Exit;
  end;

  // DLL�̓��I���[�h
  if Zip32Load = False then
  begin
    raise Exception.Create('ZIP���k�p��DLL���C���X�g�[������Ă��܂���B');
  end;


  //-------------------
  // �I�v�V�����̐ݒ�
  //-------------------
  ZeroMemory(@opts, Sizeof(opts));
  opts.fLevel := '6'; // ���x�ƈ��k�o�����X���Ƃ���
  opts.fVerbose := True;
  opts.fIncludeDate := True;
  opts.fExtra := True;
  opts.fSuffix := True;

  srcFiles := THStringList.Create;
  fs       := THStringList.Create;
  try
    srcFiles.Text := srcFile;
    basePath := GetBasePath(srcFiles);
    GetShortPathName( PChar(basePath), opts.szRootDir, sizeof(opts.szRootDir));
    if not ZpSetOptions(opts) then MessageBox(0, 'error', 'Error setting Zip Options', MB_OK);

    // �t�H���_�ȉ��̈��k�ɂ͑Ή�������
    for i := 0 to srcFiles.Count - 1 do
    begin
      s := srcFiles.Strings[i];
      if DirectoryExists(s) then
      begin
        if Copy(s, Length(s), 1) <> '\' then s := s + '\*';
        tmp := EnumAllFiles(s);
        fs.AddStringList(tmp);
        tmp.Free;
      end else
      begin
        fs.Add(s);
      end;
    end;
    srcFiles.Clear;
    // �x�[�X�p�X�𔲂�
    DeleteBasePath(fs, basePath);

    ZipFiles(desFile, fs);
  finally
    fs.Free;
    srcFiles.Free;
  end;

  // DLL�̊J��
  Zip32Free;

end;





{----------------------------------------------------------------------------------}
{----------------------------------------------------------------------------------}
function DllPassword(P: PChar; N: Integer; M, Name: PChar): integer; stdcall;
begin
  Result := 1;
end;
{----------------------------------------------------------------------------------}
function DllService(CurFile: PChar; Size: ULONG): integer; stdcall;
begin
  Result := 0;
  //MessageBox(UnlhaHandle, CurFile, 'Unzip.dll���', MB_OK);
end;
{----------------------------------------------------------------------------------}
function DllReplace(FileName: PChar): integer; stdcall;
begin
  Result := 1;
end;
{----------------------------------------------------------------------------------}
{ �����o�͂���ꍇ

procedure DllMessage(UnCompSize : ULONG;
                     CompSize   : ULONG;
                     Factor     : UINT;
                     Month      : UINT;
                     Day        : UINT;
                     Year       : UINT;
                     Hour       : UINT;
                     Minute     : UINT;
                     C          : Char;
                     FileName   : PChar;
                     MethBuf    : PChar;
                     CRC        : ULONG;
                     Crypt      : Char); stdcall;
const
  sFormat = '%7u  %7u %4s  %02u-%02u-%02u  %02u:%02u  %s%s';
  cFactor = '%s%d%%';
  cFactor100 = '100%%';
var
  S       : string;
  sFactor : string;
  Sign    : Char;
begin
  if (CompSize > UnCompSize) then Sign := '-' else Sign := ' ';

  if (Factor = 100)
  then sFactor := cFactor100
  else sFactor := Format(cFactor, [Sign, Factor]);

  S := Format(sFormat, [UnCompSize, CompSize, sFactor, Month, Day, Year, Hour, Minute, C, FileName]);
  MessageBox(UnlhaHandle, PChar(S), 'Unzip.dll���', MB_OK);
end;
}

procedure DllMessage(UnCompSize : ULONG;
                     CompSize   : ULONG;
                     Factor     : UINT;
                     Month      : UINT;
                     Day        : UINT;
                     Year       : UINT;
                     Hour       : UINT;
                     Minute     : UINT;
                     C          : Char;
                     FileName   : PChar;
                     MethBuf    : PChar;
                     CRC        : ULONG;
                     Crypt      : Char); stdcall;
begin
  Exit;
end;


{----------------------------------------------------------------------------------}
procedure Set_UserFunctions(var Z:TUserFunctions);
begin
  { prepare TUserFunctions structure }
  with Z do
  begin
    @Print                  := @DummyPrint;
    @Sound                  := nil;
    @Replace                := @DllReplace;
    @Password               := @DllPassword;
    @SendApplicationMessage := @DllMessage;
    @ServCallBk             := @DllService;
  end;
end;


procedure zip_extract(srcFile, desFile: string);
var
  UF : TUserFunctions;
  Opt  : TDCL;
begin
  if Trim(srcFile) = '' then Exit;
  if Trim(desFile) = '' then Exit;

  if Use7zip32 then
  begin
    zip7_extract(srcFile, desFile);
    Exit;
  end;

  // �c�k�k���I���[�h
  if Unzip32Load = False then
  begin
    raise Exception.Create('ZIP�𓀗p��DLL���C���X�g�[������Ă��܂���B');
  end;

  { set user functions }
  Set_UserFunctions(UF);

  { set unzip operation options }
  ZeroMemory(@Opt, Sizeof(Opt));
  Opt.nDFlag := 1; // path �t�œW�J
  Opt.fPrivilege := 1;
  Opt.lpszZipFN         := PChar(srcFile);
  Opt.lpszExtractDir    := PChar(desFile);
  Opt.nTFlag := 0;
  ForceDirectories(desFile);

  { extract }
  Wiz_SingleEntryUnzip(0,    { number of file names being passed }
                       nil,  { file names to be unarchived }
                       0,    { number of "file names to be excluded from processing" being  passed }
                       nil,  { file names to be excluded from the unarchiving process }
                       Opt,  { pointer to a structure with the flags for setting the  various options }
                       UF);  { pointer to a structure that contains pointers to user functions }

  // �c�k�k�J��
  Unzip32Free;

end;



//------------------------------------------------------------------------------
// CAB
function CabCommand(command: string): string;
begin
  if not Cab32Load then raise Exception.Create('Cab32.dll��������܂���B�C���X�g�[�����Ă��������B');
  try
    SetLength(Result, 1024);
    Cab(getMainWinHandle, PChar(command), PChar(Result), 1023);
    Result := string(PChar(Result));
    if Pos('error', LowerCase(Result)) > 0 then
    begin
      MessageBox(getMainWinHandle, PChar(Result), 'Cab32.dll���', MB_OK);
    end;
  except
    raise Exception.Create('Cab32.dll �G���[:'+Result);
  end;
  Cab32Free;
end;

function SevenZipCommand(command: string): string;
begin
  if not SevenZip32Load then raise Exception.Create('7-zip.dll/7-zip32.dll��������܂���B');
  try
    SetLength(Result, 1024);
    SevenZip(getMainWinHandle, PChar(command), PChar(Result), 1023);
    Result := string(PChar(Result));
    if Pos('error', LowerCase(Result)) > 0 then
    begin
      MessageBox(getMainWinHandle, PChar(Result), '7-zip32.dll���', MB_OK);
    end;
  except
    raise Exception.Create('7-zip32.dll �G���[:'+Result);
  end;
  SevenZip32Free;
end;

//------------------------------------------------------------------------------
// Yz1
function Yz1Command(command: string): string;
begin
  if not Yz1Load then raise Exception.Create('Yz1.dll��������܂���B�C���X�g�[�����Ă��������B');
  try
    SetLength(Result, 1024);
    Yz1(getMainWinHandle, PChar(command), PChar(Result), 1023);
    Result := string(PChar(Result));
    if Pos('error', LowerCase(Result)) > 0 then
    begin
      MessageBox(getMainWinHandle, PChar(Result), 'Yz1.dll���', MB_OK);
    end;
  except
    raise Exception.Create('Yz1.dll �G���[:'+Result);
  end;
  Yz1Free;
end;

function UnYz1Command(command: string): string;
begin
  if not UnYz1Load then raise Exception.Create('unyz1.dll��������܂���B�C���X�g�[�����Ă��������B');
  try
    SetLength(Result, 1024);
    UnYz1(getMainWinHandle, PChar(command), PChar(Result), 1023);
    Result := string(PChar(Result));
    if Pos('error', LowerCase(Result)) > 0 then
    begin
      MessageBox(getMainWinHandle, PChar(Result), 'unyz1.dll���', MB_OK);
    end;
  except
    raise Exception.Create('unyz1.dll �G���[:'+Result);
  end;
  UnYz1Free;
end;


procedure cab_compress(srcFile, desFile: string);
var
  s, cmd, basePath, fs : string;
  srcFiles : THStringList;
  i: Integer;
begin
  srcFiles := THStringList.Create ;
  try
    srcFiles.Text := srcFile ;

    // basePath ��T��
    basePath := GetBasePath(srcFiles);

    // �t�H���_���w�肳��Ă���ꍇ�� * �𑫂�
    for i := 0 to srcFiles.Count - 1 do
    begin
      s := srcFiles.Strings[i];
      if DirectoryExists(s) then
      begin
        if Copy(s,Length(s),1) <> '\' then s := s + '\';
        s := s + '*';
        srcFiles.Strings[i] := s;
      end;
    end;

    // bathpath �����
    DeleteBasePath(srcFiles, basePath);

    // �t�@�C���̈ꗗ��Ԃ�
    fs := '';
    for i := 0 to srcFiles.Count - 1 do
    begin
      fs := fs + '"' + srcFiles.Strings[i] + '" ';
    end;

    //cmd := a -a1 -r2 -x1 -jp1 "���ɖ�" "��f�B���N�g��" "�p�X��"
    cmd := '-a -r "'+desFile+'" "'+basePath+'" '+fs;
    CabCommand(cmd);
  finally
    srcFiles.Free;
  end;
end;

procedure cab_extract(srcFile, desFile: string);
var
  cmd: string;
begin
  cmd := '-x "'+srcFile+'" "'+desFile+'"';
  CabCommand(cmd);
end;

procedure zip7_compress(srcFile, desFile: string);
var
  s, cmd, basePath, fs : string;
  srcFiles : THStringList;
  i: Integer;
begin
  srcFiles := THStringList.Create ;
  try
    srcFiles.Text := srcFile ;

    // basePath ��T��
    basePath := GetBasePath(srcFiles);

    // �t�H���_���w�肳��Ă���ꍇ�� * �𑫂�
    for i := 0 to srcFiles.Count - 1 do
    begin
      s := srcFiles.Strings[i];
      if DirectoryExists(s) then
      begin
        if Copy(s,Length(s),1) <> '\' then s := s + '\';
        s := s + '*';
        srcFiles.Strings[i] := s;
      end;
    end;

    // bathpath �����
    DeleteBasePath(srcFiles, basePath);

    // �t�@�C���̈ꗗ��Ԃ�
    fs := '';
    for i := 0 to srcFiles.Count - 1 do
    begin
      fs := fs + '"' + srcFiles.Strings[i] + '" ';
    end;

    //cmd := a -a1 -r2 -x1 -jp1 "���ɖ�" "��f�B���N�g��" "�p�X��"
    //
    cmd := 'a -tzip -r "'+desFile+'" "'+basePath+'" '+fs;
    SevenZipCommand(cmd);
  finally
    srcFiles.Free;
  end;
end;

procedure zip7_extract(srcFile, desFile: string);
var
  cmd: string;
begin
  cmd := 'x "'+srcFile+'" -o"'+desFile+'"';
  SevenZipCommand(cmd);
end;

procedure yz1_compress(srcFile, desFile: string);
var
  s, cmd, basePath, fs : string;
  srcFiles : THStringList;
  i: Integer;
begin
  srcFiles := THStringList.Create ;
  try
    srcFiles.Text := srcFile ;

    // basePath ��T��
    basePath := GetBasePath(srcFiles);

    // �t�H���_���w�肳��Ă���ꍇ�� * �𑫂�
    for i := 0 to srcFiles.Count - 1 do
    begin
      s := srcFiles.Strings[i];
      if DirectoryExists(s) then
      begin
        if Copy(s,Length(s),1) <> '\' then s := s + '\';
        s := s + '*';
        srcFiles.Strings[i] := s;
      end;
    end;

    // bathpath �����
    DeleteBasePath(srcFiles, basePath);

    // �t�@�C���̈ꗗ��Ԃ�
    fs := '';
    for i := 0 to srcFiles.Count - 1 do
    begin
      fs := fs + '"' + srcFiles.Strings[i] + '" ';
    end;

    //cmd := a -a1 -r2 -x1 -jp1 "���ɖ�" "��f�B���N�g��" "�p�X��"
    cmd := '-a -r "'+desFile+'" "'+basePath+'" '+fs;
    Yz1Command(cmd);
  finally
    srcFiles.Free;
  end;
end;

procedure yz1_extract(srcFile, desFile: string);
var
  cmd: string;
begin
  cmd := '-x "'+srcFile+'" "'+desFile+'"';
  Yz1Command(cmd);
end;

procedure unyz1_extract(srcFile, desFile: string);
var
  cmd: string;
begin
  cmd := '-x "'+srcFile+'" "'+desFile+'"';
  UnYz1Command(cmd);
end;


end.
