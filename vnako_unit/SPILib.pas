// SusiePlugIn export library for Delphi
// Copyright(C)'2000 buin2gou
// 
// ���̃R���|�[�l���g�͎��R�Ɏg�p���Ă�����č\���܂���
// �]�ځE���ς����R�ł��B�s�̃\�t�g�Ɏg�p���Ă����C�����e�B
// �̐����͐�΂ɂ��肦�܂���B�����K�v����܂���B

unit SPILib;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  // TPictureInfo
  PPictureInfo = ^TPictureInfo;
  TPictureInfo = packed record
    Left:       Longint;
    Top:        Longint;
    Width:      Longint;
    Height:     Longint;
    x_Density:  Word;
    y_Density:  Word;
    colorDepth: Smallint;
    hInfo:      HLOCAL;
  end;

  // TFileInfo
  PFileInfo = ^TFileInfo;
  TFileInfo = record
    Method:    array[0..7] of Char;
    Position:  Longint;
    CompSize:  Longint;
    FileSize:  Longint;
    TimeStamp: Longint;
    Path:      array[0..199] of Char;
    FileName:  array[0..199] of Char;
    CRC:       Longint;
  end;

  PFIleInfoArray=^TFIleInfoArray;
  TFIleInfoArray=array[0..512] of TFileInfo;

  // TProgressCallback(Callback function)
  TProgressCallback = function(nNum, nDenom: Integer; lData: Longint): Integer;stdcall;

    // Plug-in�Ɋւ�����𓾂�
  FGetPluginInfo =function(InfoNo: Integer; Buf: PChar; BufLen: Integer): Integer; stdcall;
    // �W�J�\��(�Ή����Ă���)�t�@�C���`�������ׂ�
  FIsSupported   =function(FileName: PChar; DW: DWORD): Integer; stdcall;
    // �摜�t�@�C���Ɋւ�����𓾂�
  FGetPictureInfo=function(Buf: PChar; Len: Longint; Flag: Integer;var PictureInfo: TPictureInfo): Integer; stdcall;
    // �摜��W�J����
  FGetPicture    =function(Buf: PChar; Len: Longint; Flag: Integer;var HBInfo: HLOCAL; var HBm: HLOCAL;ProgressCallback: TProgressCallback; lData: Longint): Integer; stdcall;
    // �v���r���[�E�J�^���O�\���p�摜�k���W�J���[�e�B��
  FGetPreview    =function(Buf: PChar; Len: Longint; Flag: Integer;var HBInfo: HLOCAL; var HBm: HLOCAL;ProgressCallback: TProgressCallback; lData: Longint): Integer; stdcall;

  //�A�[�J�C�u�֌W

    // �A�[�J�C�u���̂��ׂẴt�@�C���̏����擾����
  FGetArchiveInfo=function(Buf: PChar; Len: Longint; Flag: Integer;var PictureInfoHandle: HLocal): Integer; stdcall;
    // �A�[�J�C�u���̎w�肵���t�@�C���̏����擾����
  FGetFileInfo   =function(Buf: PChar; Len: Longint; FileName: PChar; Flag: Integer;var FileInfo: TFileInfo): Integer; stdcall;
    // �A�[�J�C�u���̃t�@�C�����擾����
  FGetFile       =function(Src: PChar; Len: Longint; Dest: PChar; Flag: Integer;ProgressCallback: TProgressCallback; lData: Longint): Integer; stdcall;
    // Plug-in�ݒ�_�C�A���O�\��
  FConfigurationDlg=function (Parent: HWND; fnc: Integer): Integer; stdcall;


  //�摜�v���O�C��
  PPicPlug=^TPicPlug;
  TPicPlug=record
      //�c�k�k�̃n���h��
      DllHandle :THandle;

      //�v���O�C���f�[�^
      sPath     :AnsiString;
      sVersion  :AnsiString;
      sFinleInfo:AnsiString;
      sFileExt  :AnsiString;
      sFileType :AnsiString;

      //�֐�
      GetPluginInfo   :FGetPluginInfo;
      IsSupported     :FIsSupported;
      GetPictureInfo  :FGetPictureInfo;
      GetPicture      :FGetPicture;
      GetPreview      :FGetPreview;
      ConfigurationDlg:FConfigurationDlg;
  end;

  //�A�[�J�C�u�v���O�C��
  PArcPlug=^TArcPlug;
  TArcPlug=record
      //�c�k�k�̃n���h��
      DllHandle :THandle;

      //�v���O�C���f�[�^
      sPath     :AnsiString;
      sVersion  :AnsiString;
      sFinleInfo:AnsiString;
      sFileExt  :AnsiString;
      sFileType :AnsiString;

      //�֐�
      GetPluginInfo :FGetPluginInfo;
      IsSupported   :FIsSupported;
      GetArchiveInfo:FGetArchiveInfo;
      GetFileInfo   :FGetFileInfo;
      GetFile       :FGetFile;
      ConfigurationDlg:FConfigurationDlg;
  end;



type
  TSpiLib32 = class(TComponent)
  private
    { Private �錾 }

    //�v���O�C�����X�g
    PicList:TList;
    ArcList:TList;
    //�ϐ�
    ARCfilters:AnsiString;
    PICfilters:AnsiString;

    APIL      :TStrings;
    SPIL      :TStrings;


  protected
    { Protected �錾 }
  public
    { Public �錾 }


    //�����E�J��
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    //�v���O�C���ǂݍ��݁E�J��
    procedure LoadPlugIn(Dir: AnsiString);
    procedure LoadPlugInArc(Dir: AnsiString);
    procedure FreePlugIn;

    //�摜�ǂݍ��݊֐�
    procedure LoadFromStream(Stream:TStream;BMP:TBitmap);
    procedure LoadFromFile(FileName: AnsiString;BMP:TBitmap);
    procedure LoadFromMemory(Buf: PChar; Len: Longint;BMP:TBitmap);

    {
    //�A�[�J�C�u����摜��ǂݏo��
    procedure LoadFromStreamArcPic(Stream,Stream2:TStream;BMP:TBitmap);
    procedure LoadFromFileArcPic(ARCName,PicName: AnsiString;BMP:TBitmap);
    }
    //�A�[�J�C�u����t�@�C�������̂܂܃Z�[�u����
    procedure SaveToFile(ArcFIleName,FileName: AnsiString);
    procedure SaveToStream(FileName,ArcFileName: AnsiString;Stream:TStream);
    procedure SaveToMemory(Buf: PChar;FIleName,ArcFileName: AnsiString);

    //�v���O�C���̃��X�g
    procedure ListArc(List:TStrings;bClear:Boolean);
    procedure ListPic(List:TStrings;bClear:Boolean);

    //�A�[�J�C�u���t�@�C���̃��X�g
    procedure ArcFileList(ArcFileName: AnsiString;List:TStrings);

    //�T�|�[�g���Ă邩
    function SupportArcFile(FIleName: AnsiString):Boolean;
    function SupportPicFile(FIleName: AnsiString):Boolean; // by Mine
    function SupportPicFileList: AnsiString;
  published
    { Published �錾 }
    //�v���p�e�B
    property  AFilter: AnsiString read ARCFilters;
    property  PFilter: AnsiString read PICFilters;
    property  ArcPlugInList:TStrings read APIL;
    property  PicPlugInList:TStrings read SPIL;

  end;

procedure Register;

implementation

const
	SearchAttr = faReadOnly + faSysFile + faArchive;


procedure Register;
begin
  RegisterComponents('buin2gou', [TSpiLib32]);
end;

constructor TSpiLib32.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);

  //���X�g�̃N���G�C�g
  ArcList:=TList.Create;
  PicList:=TList.Create;

  //�v���O�C�����
  APIL:=TStringList.Create;
  SPIL:=TStringList.Create;

  APIL.Clear;
  SPIL.Clear;

end;

destructor TSpiLib32.Destroy;
begin

  FreePlugIn;

  //���X�g�̊J��
  ArcList.Free;
  PicList.Free;

  //�v���O�C�����
  APIL.Free;
  SPIL.Free;

  Inherited;
end;

procedure TSpiLib32.LoadPlugIn(Dir: AnsiString);
var SR  :TSearchRec;
    Re  :Integer;
    s   : AnsiString;
    pPo :Pointer;
    pPic:PPicPlug;
    buf :PChar;
    List:TStringList;
    i   :Integer;
    bOk :Boolean;
begin
 //������
 PICfilters:='';
 GetMem(buf,256);

 //�w��f�B���N�g���������ɃZ�b�g
 List:=TStringList.Create;
 List.Clear;


 Re:=FindFirst(Dir+'*.SPI', SearchAttr, SR);
 try
   while Re=0 do begin
         //�c�k�k�̃t���p�X�𓾂�
         s:=Dir + StrPas(SR.FindData.cFileName);

         List.Add(s);
         //����
         Re:=FindNext(SR);
   end;
 finally
   FindClose(SR);
 end;


 for i:=0 to List.COunt-1 do begin
   s:=List[i];

   bOK:=True;
   //�c�k�k�̓ǂݍ��݁E�擾
   New(pPic);

   pPic.DllHandle:=LoadLibrary(PChar(s));
   If pPic.DllHandle<>0 then begin
     //�֐��̃A�h���X���擾
     pPo:=GetProcAddress(pPic.DllHandle,'GetPluginInfo');
     If pPo<>nil then begin
        //�A�[�J�C�u�v���O�C�����摜�v���O�C����������
        @pPic.GetPluginInfo:=pPo;
        pPic.GetPluginInfo(0,buf,255);
        s:=AnsiString(buf);


        If s='00IN' then begin
           //�摜�v���O�C���擾


           //�v���O�C�����̎擾
           @pPic.GetPluginInfo:=pPo;

           pPic.GetPluginInfo(0,buf,255);
           pPic.sFinleInfo:=AnsiString(buf);

           pPic.GetPluginInfo(1,buf,255);
           pPic.sVersion:=AnsiString(buf);

           pPic.GetPluginInfo(2,buf,255);
           pPic.sFileExt:=AnsiString(buf);

           pPic.GetPluginInfo(3,buf,255);
           pPic.sFileType:=AnsiString(buf);

           pPic.sPath:=dir;

           //�֐��̎擾
           @pPic.GetPicture      :=GetProcAddress(pPic.DllHandle,'GetPicture');
           @pPic.GetPictureInfo  :=GetProcAddress(pPic.DllHandle,'GetPictureInfo');
           @pPic.GetPreview      :=GetProcAddress(pPic.DllHandle,'GetPreview');
           @pPic.IsSupported     :=GetProcAddress(pPic.DllHandle,'IsSupported');
           @pPic.ConfigurationDlg:=GetProcAddress(pPic.DllHandle,'ConfigurationDlg');

           PicList.Add(pPic);
           PicFIlters:=PicFilters+pPic.sFileExt+';';

         end else begin
           bOK:=False;
         end;
      end else begin
         bOK:=False;
      end;
   end else begin
      bOK:=False;
   end;

   If not bOK then begin
      //�c�k�k���J��
      FreeLibrary(pPic.DllHandle);
      DisPose(pPic);
   end;
  end;
  List.Free;
  FreeMEM(buf);

  ListPic(SPIL,False);


end;

procedure TSpiLib32.LoadPlugInArc(Dir: AnsiString);
var SR  :TSearchRec;
    Re  :Integer;
    s   : AnsiString;
    pPo :Pointer;
    pArc:PArcPlug;
    buf :PChar;
    List:TStringList;
    i   :Integer;
    bOk :Boolean;
begin
 //������
 ARCfilters:='';

 GetMem(buf,256);

 //�w��f�B���N�g���������ɃZ�b�g
 List:=TStringList.Create;
 Re:=FindFirst(Dir+'*.SPI', SearchAttr, SR);
 try
   while Re=0 do begin
         //�c�k�k�̃t���p�X�𓾂�
         s:=Dir + StrPas(SR.FindData.cFileName);

         List.Add(s);
         //����
         Re:=FindNext(SR);
   end;
 finally
   FindClose(SR);
 end;

 for i:=0 to List.COunt-1 do begin
   s:=List[i];


   bOK:=True;
   //�c�k�k�̓ǂݍ��݁E�擾
   New(pArc);
   pArc.DllHandle:=LoadLibrary(PChar(s));
   If pArc.DllHandle<>0 then begin
     //�֐��̃A�h���X���擾
     pPo:=GetProcAddress(pArc.DllHandle,'GetPluginInfo');
     If pPo<>nil then begin
        //�A�[�J�C�u�v���O�C�����摜�v���O�C����������
        @pArc.GetPluginInfo:=pPo;
        pArc.GetPluginInfo(0,buf,255);
        s:=AnsiString(buf);

        If s='00AM' then begin
           //�A�[�J�C�u�v���O�C���擾

           //�v���O�C�����̎擾
           @pArc.GetPluginInfo:=pPo;

           pArc.GetPluginInfo(0,buf,255);
           pArc.sFinleInfo:=AnsiString(buf);

           pArc.GetPluginInfo(1,buf,255);
           pArc.sVersion:=AnsiString(buf);

           pArc.GetPluginInfo(2,buf,255);
           pArc.sFileExt:=AnsiString(buf);

           pArc.GetPluginInfo(3,buf,255);
           pArc.sFileType:=AnsiString(buf);

           //�֐��̎擾
           @pARC.GetArchiveInfo  :=GetProcAddress(pArc.DllHandle,'GetArchiveInfo');
           @pARC.GetFile         :=GetProcAddress(pArc.DllHandle,'GetFile');
           @pARC.GetFileInfo     :=GetProcAddress(pArc.DllHandle,'GetFileInfo');
           @pARC.IsSupported     :=GetProcAddress(pArc.DllHandle,'IsSupported');
           @pARC.ConfigurationDlg:=GetProcAddress(pArc.DllHandle,'ConfigurationDlg');

           ArcList.Add(pArc);
           ArcFIlters:=ArcFilters+pArc.sFileExt+';';
         end else begin
           bOK:=False;
         end;
      end else begin
         bOK:=False;
      end;
   end else begin
      bOK:=False;
   end;

   If not bOK then begin
      //�c�k�k���J��
      FreeLibrary(pArc.DllHandle);
      DisPose(pArc);
   end;
  end;
  List.Free;
  FreeMEM(buf);

  //���X�g����
  ListArc(APIL,False);

end;


procedure TSpiLib32.FreePlugIn;
var i,imax:Integer;
    pPic  :PPicPlug;
    pArc  :PArcPlug;
begin

  //�摜�v���O�C���J��
  imax:=PicList.Count;
  If imax>0 then begin
     for i:=0 to imax-1 do begin
         pPic:=PicList.Items[i];
         FreeLibrary(pPic.DLLHandle);
         DisPose(pPic);
     end;
  end;

  //�A�[�J�C�u�v���O�C���J��
  imax:=ArcList.Count;
  If imax>0 then begin
     for i:=0 to imax-1 do begin
         pArc:=ArcList.Items[i];
         FreeLibrary(pArc.DLLHandle);
         DisPose(pARC);
     end;
  end;
end;

procedure TSpiLib32.LoadFromStream(Stream:TStream;BMP:TBitmap);
var ms:TMemoryStream;
begin

 //��X�������X�g���[���𐶐�
 ms:=TMemoryStream.Create;
 try
  //���������烍�[�h�B
  ms.LoadFromStream(Stream);
  LoadFromMemory(ms.Memory,Stream.Size,BMP);
 finally
  ms.Free;
 end;


end;

procedure TSpiLib32.LoadFromMemory(Buf: PChar; Len: Longint;BMP:TBitmap);
var
    pHBm    :HGLOBAL;
    pHBInfo :HGLOBAL;
    pHBmP   :Pointer;
    pHBInfoP:Pointer;
    pbmi    :^TBitmapInfo;
    pPic    :PPicPlug;
    i       :Integer;
begin



    for i:=0 to PicList.Count-1 do begin
        pPic:=PicList.Items[i];

        //�Ή��摜���`�F�b�N
        If pPic.IsSupported(nil,DWORD(buf))<>0 then begin

           pPic.GetPicture(buf,len, $001, pHBInfo, pHBm,nil,0);

           try
               //�r�b�g�}�b�v�̓ǂݍ���
               pHBmP   :=GlobalLock(pHBm);
               pHBInfoP:=GlobalLock(pHBInfo);
               pbmi    :=pHBInfoP;

               //�T�C�Y�̐ݒ�
               Bmp.Width :=pbmi^.bmiHeader.biWidth;
               Bmp.Height:=pbmi^.bmiHeader.biHeight;

               //�]��
               SetDiBits(Bmp.Canvas.Handle,Bmp.Handle,0,pbmi^.bmiHeader.biHeight,pHBmP, pbmi^,DIB_RGB_COLORS);
           finally
             GlobalUnlock(pHBm);
             GlobalUnlock(pHBInfo);
             GlobalFree(pHBm);
             GlobalFree(pHBInfo);
           end;
           break;
        end;
    end;
end;


procedure TSpiLib32.LoadFromFile(FileName: AnsiString;BMP:TBitmap);
var Stream:TMemoryStream;
begin

    Stream:=TMemorySTream.Create;
    try
      Stream.LoadFromFile(FileName);
      LoadFromStream(Stream,BMP);
    finally
      Stream.Free;
    end;
end;

procedure TSpiLib32.SaveToFile(ArcFIleName,FileName: AnsiString);
var ms:TMemoryStream;
begin

   ms :=TMemoryStream.Create;
   try
     SaveToStream(FileName,ArcFileName,ms);
     ms.SaveToFile(FileName);
   finally
     ms.Free;
   end;
end;

procedure TSpiLib32.SaveToStream(FileName,ArcFileName: AnsiString;Stream:TStream);
var ms:TMemoryStream;
begin

  ms:=TMemoryStream.Create;
  try
    ms.LoadFromStream(Stream);
    SaveToMemory(ms.Memory,FileName,ArcFileName);
  finally
    ms.Free;
  end;
end;

procedure TSpiLib32.SaveToMemory(Buf: PChar;FIleName,ArcFileName: AnsiString);
var i   :Integer;
    pArc:pArcPlug;
    finf:TFileInfo;
begin

    for i:=0 to ARCList.Count-1 do begin
        pArc:=ArcList.Items[i];

        //�Ή��摜���`�F�b�N
        If pArc.IsSupported(nil,DWORD(buf))<>0 then begin

           pArc.GetFileInfo(PChar(FileName),SizeOf(FileName),PChar(ArcFileName),0,finf);

           pArc.GetFile(PChar(FileName),finf.Position,buf,$001,nil,0);

           break;
        end;
    end;
end;

function TSpiLib32.SupportArcFile(FIleName: AnsiString):Boolean;
var i,j :Integer;
    pArc:pArcPlug;
    ms  :TMemoryStream;
begin

  Result:=False;

  ms:=TMemoryStream.Create;
  try
    ms.LoadFromFile(FileName);

    for i:=0 to ARCList.Count-1 do begin
        pArc:=ArcList.Items[i];

        //�Ή��摜���`�F�b�N
        j:=pArc.IsSupported(nil,DWORD(MS.Memory));

        If j<>0 then begin
           Result:=True;
           break;
        end;
    end;
  finally
    ms.Free;
  end;
end;

procedure TSpiLib32.ArcFileList(ArcFileName: AnsiString;List:TStrings);
var i,j :Integer;
    pArc:pArcPlug;
    LMem:HLOCAL;
    ms  :TMemoryStream;
    PInf:PFileInfoArray;
    AllCount:Integer;
    TInf:TFileInfo;
begin

  ms:=TMemoryStream.Create;
  try
    ms.LoadFromFile(ArcFileName);

    for i:=0 to ARCList.Count-1 do begin
        pArc:=ArcList.Items[i];
        //�Ή��摜���`�F�b�N
        If pArc.IsSupported(nil,DWORD(ms.Memory))<>0 then begin

           pArc.GetArchiveInfo(MS.Memory,MS.Size,0,LMEM);

           //LMEM�����b�N���擾
           PInf:=LocalLock(LMEM);
           try
            ALLCount:=LocalSize(LMEM) div SizeOf(TFileInfo);

            for j:=0 to ALLCount do begin
                If PInf^[j].Method[0]=#0 then break;

                TInf:=PInf[j];

                List.Add(TInf.FileName);

            end;
           finally
             LocalUnLock(LMEM);
           end;
           break;
        end;
    end;
  finally
    ms.Free;
  end;
end;



procedure TSpiLib32.ListArc(List:TStrings;bClear:Boolean);
var i   :Integer;
    pArc:PArcPlug;
    buf :PChar;
begin

   //�o�b�t�@���擾
   GetMem(buf,256);

   //���X�g�̃N���A
   If bClear then List.Clear;

   for i:=0 to ARCList.Count-1 do begin
       //�A�[�J�C�u�v���O�C�������擾
       pArc:=ArcList.Items[i];

       //�v���O�C���f�[�^��ǂݏo��
       pArc.GetPluginInfo(1,buf,255);
       List.Add(buf);
   end;

   //�o�b�t�@���J��
   FreeMem(buf);

end;

procedure TSpiLib32.ListPic(List:TStrings;bClear:Boolean);
var i   :Integer;
    pPic:PPicPlug;
    buf :PChar;
begin

   //�o�b�t�@���擾
   GetMem(buf,256);

   //���X�g�̃N���A
   If bClear then List.Clear;

   for i:=0 to PicList.Count-1 do begin
       //�A�[�J�C�u�v���O�C�������擾
       pPic:=PicList.Items[i];

       //�v���O�C���f�[�^��ǂݏo��
       pPic.GetPluginInfo(1,buf,255);
       List.Add(buf);
   end;

   //�o�b�t�@���J��
   FreeMem(buf);

end;


function TSpiLib32.SupportPicFile(FileName: AnsiString): Boolean;
var i :Integer;
    pPic:PPicPlug;
    ext, s, token: AnsiString;

    function GetToken(const delimiter: AnsiString; var str: AnsiString): AnsiString;
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

begin
    ext := UpperCase(ExtractFileExt(FIleName));
    Result:=False;
    for i:=0 to PicList.Count-1 do
    begin
        pPic:=PicList.Items[i];

        //�Ή��摜���`�F�b�N
        s := UpperCase(pPic.sFileExt);
        while True do
        begin
            token := GetToken(';', s);
            if ExtractFileExt(token) = ext then
            begin
                Result := True; Break;
            end;
            if s = '' then Break;

        end;
    end;
end;

function TSpiLib32.SupportPicFileList: AnsiString;
var i :Integer;
    pPic:PPicPlug;
    ext, s, token: AnsiString;

begin
    Result := '';
    for i:=0 to PicList.Count-1 do
    begin
      pPic:=PicList.Items[i];
      s := Trim(UpperCase(pPic.sFileExt));
      Result := Result + s + ';';
    end;
    if Copy(Result,Length(Result),1)=';' then System.Delete(s, Length(s), 1);
end;

end.
