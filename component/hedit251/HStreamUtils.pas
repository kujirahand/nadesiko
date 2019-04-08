(*********************************************************************

  HStreamUtils.pas

  start  2000/12/24
  update 2001/07/25

  Copyright (c) 2000,2001 �{�c���F <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  TComponent ���ۂ��� TStream �֕ۑ����A���邽�߂̎葱��
  TStream �����W�X�g���֕ۑ����A���邽�߂̎葱��
  TStream �� TStrings ����� ini �t�@�C���֕ۑ����A���邽�߂̎葱��
  ���L�q����Ă���B

**********************************************************************)

unit HStreamUtils;

{$I heverdef.inc}

interface

uses
  SysUtils, Windows, Classes, Controls, IniFiles, Registry;

procedure ComponentToStream(Instance: TComponent; Stream: TStream);
procedure StreamToComponent(Stream: TStream; Instance: TComponent);
procedure StreamToStrings(Stream: TStream; Strings: TStrings);
procedure StringsToStream(Strings: TStrings; Stream: TStream);
procedure IniReadStream(Stream: TStream; const IniFileName, Section, Ident: String);
procedure IniWriteStream(Stream: TStream; const IniFileName, Section, Ident: String);
procedure RegReadStream(Stream: TStream; const Root, Section, Ident: String);
procedure RegWriteStream(Stream: TStream; const Root, Section, Ident: String);

implementation

(*
  �ȉ��� ComponentToStream, StreamToComponent ��
  nifty:FDELPHI/MES/10/2168 �́A�Z�p�O�[ ���� ( CXE02604 ) ��
  �������Q�l�ɂ����Ē����܂���
*)

(*
  StreamToComponent, ComponentToStream �葱���ł́A�C�x���g�n���h���̐ݒ�
  ��A�E�B���h�D�n���h�����Đ�������K�v������ ScrollBars �v���p�e�B�Ȃ�
  ��ۑ��E���A���邽�߂ɁA�����œn���ꂽ�R���|�[�l���g����U�j�����A�X�g
  ���[���f�[�^���琶�������R���|�[�l���g���Y���R���|�[�l���g�� Owner ��
  ����āu����ւ��v�Ă��炤�Ƃ�������������Ă���B

  TFountain �Ȃǂ̑��̃R���|�[�l���g�ɐڑ����ė��p����R���|�[�l���g�ł́A
  Notification �̎d�g�݂𗘗p���Ă���̂ŁA�j�����ꂽ���_�Őڑ����ؒf��
  ��Ă��܂��B���̂悤�ȃR���|�[�l���g�ɑ΂��ẮATStoreComponent �e
  ���\�b�h�Ŏg���Ă��� TStream.WriteComponent, ReadComponent ���\�b�h
  �𗘗p���邱�ƁB

  StreamToComponent, ComponentToStream �葱���ɂ��X�g���[���f�[�^��
  TStream.WriteComponent, ReadComponent ���\�b�h�ɂ��f�[�^�͑��݂�
  �ǂݏ������邱�Ƃ��\�ł���B
*)

procedure ComponentToStream(Instance: TComponent; Stream: TStream);
var
  Writer: TWriter;
begin
  // TStream.WriteDescendent
  Writer := TWriter.Create(Stream, 4096);
  try
    // TWriter.WriteDescendent
    Writer.RootAncestor := nil;
    Writer.Ancestor := nil;
    // �C�x���g�n���h���̐ݒ��ۑ����邽�߂ɁA�n���h���̏��L�҂�
    // ���� Owner �� Writer.Root �ɐݒ肷��
    // cf Classes.pas
    // TWriter.WriteProperty, WriteMethodProp, IsDefaultValue
    if Instance.Owner = nil then
      Writer.Root := Instance
    else
      Writer.Root := Instance.Owner;
    Writer.WriteSignature;
    Writer.WriteComponent(Instance);
    // TReader.ReadComponents ���Ō�� ReadListEnd �����s����̂ŁA
    // �f�[�^�T�C�Y�����킹�邽�߂� WriteListEnd �����s����B
    Writer.WriteListEnd;
  finally
    Writer.Free;
  end;
end;

(*
  ���L StreamToComponent �ŗ��p����� TReader.ReadComponents �ł́A
  ReadComponent ���\�b�h���s�� ReadListEnd ���\�b�h�����s���Ă���B
  ��L ComponentToStream �ł́A���̎d�l�ɍ��킹�邽�߁AWriteComponent
  ���\�b�h���s�� WriteListEnd ���\�b�h�����s���Ă���B
  �������ATStream.WriteComponent �ō쐬���ꂽ�X�g���[���f�[�^�ɂ�
  ���̍Ō�̂P�o�C�g�����݂��Ȃ��̂ŁA���L StreamToComponent �ŏ��������
  EReadError ����������B

  TStream.WriteComponent �ō쐬���ꂽ�f�[�^�̍Ō�� 00 00 �ł���
  ComponentToStream �ō쐬���ꂽ�f�[�^�̍Ō��      00 00 00 �ƂȂ�B
                                             �P�o�C�g����/^^

  StreamToComponent �ł� TStream.WriteComponent �ɂ���č쐬���ꂽ
  �f�[�^�������o����悤�ɁAReadComponents ���\�b�h�ɓn�� TReadComponentsProc
  �^���\�b�h���ŁATReader �̃X�g���[���|�W�V�������P�o�C�g�߂����Ƃɂ���B
  ���̃��\�b�h�� ReadComponents �ŁAReadComponent ���s��AReadListEnd ���s�O
  �ɌĂяo�����B
*)

//  TReader.ReadComponents �𗘗p���邽�߂̃N���X  //////////////////
type
  TComponentReciever = class(TObject)
  protected
    FReader: TReader;
    FStream: TStream;
  public
    constructor Create(Reader: TReader; Stream: TStream);
    procedure ComponentsProc(Component: TComponent);
  end;

constructor TComponentReciever.Create(Reader: TReader; Stream: TStream);
begin
  FReader := Reader;
  FStream := Stream;
end;

procedure TComponentReciever.ComponentsProc(Component: TComponent);
begin
  if (FReader <> nil) and (FStream <> nil) and
     (FReader.Position = FStream.Size) then
    FReader.Position := FReader.Position - 1;
end;
/////////////////////////////////////////////////////////////////////

procedure StreamToComponent(Stream: TStream; Instance: TComponent);
var
  I: Integer;
  Reader: TReader;
  AOwner, AParent: TComponent;
  List: TStringList;
  Reciever: TComponentReciever;

  procedure PushNames(Component: TComponent; List: TStrings);
  var
    I: Integer;
  begin
    List.Add(Component.Name);
    Component.Name := '';
    if Component is TWinControl then
      for I := 0 to TWinControl(Component).ControlCount - 1 do
        PushNames(TWinControl(Component).Controls[I], List);
  end;

  procedure PopNames(Component: TComponent; List: TStrings;
    var Index: Integer);
  var
    I: Integer;
  begin
    Component.Name := List[Index];
    Inc(Index);
    if Component is TWinControl then
      for I := 0 to TWinControl(Component).ControlCount - 1 do
        PopNames(TWinControl(Component).Controls[I], List, Index);
  end;

begin

  (*
    TReader.ReadComponents �֓n����P������ AOwner ���A�X�g���[������
    ���������R���|�[�l���g�̃N���X�𑍂Ēm���Ă��Ȃ��Ɨ�O������
    �����̂ŁAComponent.Owner ��n���B����ɂ���ăC�x���g�n���h��
    �����A�����B
    cf Classes.pas TReader.ReadComponent, CreateComponent, FindFieldClass
  *)

  if Instance.Owner = nil then
    AOwner := Instance
  else
    AOwner := Instance.Owner;
  if Instance is TWinControl then
    AParent := TWinControl(Instance).Parent
  else
    AParent := Instance;
  List := TStringList.Create;
  try
    PushNames(Instance, List);
    try
      Reader := TReader.Create(Stream, 4096);
      try
        Reciever := TComponentReciever.Create(Reader, Stream);
        try
          Reader.ReadComponents(AOwner, AParent, Reciever.ComponentsProc);
        finally
          Reciever.Free;
        end;
      finally
        Reader.Free;
      end;
      Instance.Free;
    except
      I := 0;
      PopNames(Instance, List, I);
    end;
  finally
    List.Free;
  end;
end;

procedure StreamToStrings(Stream: TStream; Strings: TStrings);
const
  LineByte = 64;
var
  B: Byte;
  S: String;
begin
  Strings.BeginUpdate;
  try
    Strings.Clear;
    S := '';
    while Stream.Read(B, SizeOf(B)) > 0 do
    begin
      S := S + IntToHex(B, 2);
      if Length(S) >= LineByte then
      begin
        Strings.Add(S);
        S := '';
      end;
    end;
    if S <> '' then
      Strings.Add(S);
  finally
    Strings.EndUpdate;
  end;
end;

procedure StringsToStream(Strings: TStrings; Stream: TStream);
var
  I: Integer;
  S: String;
  B: Byte;
begin
  for I := 0 to Strings.Count - 1 do
  begin
    S := Strings[I];
    while Length(S) > 0 do
    begin
      B := StrToIntDef('$' + Copy(S, 1, 2), 0);
      Stream.Write(B, SizeOf(B));
      Delete(S, 1, 2);
    end;
  end;
end;

procedure IniWriteStream(Stream: TStream; const IniFileName, Section, Ident: String);
var
  List: TStringList;
  Count, I: Integer;
  Ini: TIniFile;
begin
  List := TStringList.Create;
  try
    StreamToStrings(Stream, List);
    Ini := TIniFile.Create(IniFileName);
    try
      Count := StrToIntDef(Ini.ReadString(Section, Ident + '_c', '0'), 0);
      if Count > List.Count then
      begin
        for I := Count - 1 downto List.Count do
          Ini.DeleteKey(Section, Ident + '_d' + IntToStr(I));
        if List.Count = 0 then
          Ini.DeleteKey(Section, Ident + '_c');
      end;
      if List.Count > 0 then
      begin
        Ini.WriteString(Section, Ident + '_c', IntToStr(List.Count));
        for I := 0 to List.Count - 1 do
          Ini.WriteString(Section, Ident + '_d' + IntToStr(I), List[I]);
      end;
    finally
      Ini.Free;
    end;
  finally
    List.Free;
  end;
end;

procedure IniReadStream(Stream: TStream; const IniFileName, Section, Ident: String);
var
  Ini: TIniFile;
  List: TStringList;
  I, C: Integer;
begin
  Ini := TIniFile.Create(IniFileName);
  try
    List := TStringList.Create;
    try
      C := StrToIntDef(Ini.ReadString(Section, Ident + '_c', '0'), 0);
      if C > 0 then
      begin
        for I := 0 to C - 1 do
          List.Add(Ini.ReadString(Section, Ident + '_d' + IntToStr(I), ''));
        StringsToStream(List, Stream);
      end;
    finally
      List.Free;
    end;
  finally
    Ini.Free;
  end;
end;

//  TRegistry �� protected �ȃ��\�b�h�ɃA�N�Z�X���邽�߂̐錾  //////
type
  TStreamReg = class(TRegIniFile);
/////////////////////////////////////////////////////////////////////

procedure RegWriteStream(Stream: TStream; const Root, Section, Ident: String);
var
  Reg: TStreamReg;
  Key, OldKey: HKEY;
  Ms: TMemoryStream;
begin
  Reg := TStreamReg.Create(Root);
  try
    Reg.CreateKey(Section);
    Key := Reg.GetKey(Section);
    if Key <> 0 then
    try
      OldKey := Reg.CurrentKey;
      Reg.SetCurrentKey(Key);
      try
        Ms := TMemoryStream.Create;
        try
          Ms.CopyFrom(Stream, Stream.Size);
          Ms.Position := 0;
          Reg.WriteBinaryData(Ident, Ms.Memory^, Ms.Size);
        finally
          Ms.Free;
        end;
      finally
        Reg.SetCurrentKey(OldKey);
      end;
    finally
      RegCloseKey(Key);
    end;
  finally
    Reg.Free;
  end;
end;

procedure RegReadStream(Stream: TStream; const Root, Section, Ident: String);
var
  Reg: TStreamReg;
  Info: TRegDataInfo;
  Key, OldKey: HKEY;
  Ms: TMemoryStream;
begin
  Reg := TStreamReg.Create(Root);
  try
    Reg.CreateKey(Section);
    Key := Reg.GetKey(Section);
    if Key <> 0 then
    try
      OldKey := Reg.CurrentKey;
      Reg.SetCurrentKey(Key);
      try
        if Reg.GetDataInfo(Ident, Info) then
        begin
          Ms := TMemoryStream.Create;
          try
            Ms.SetSize(Info.DataSize);
            Reg.ReadBinaryData(Ident, Ms.Memory^, Info.DataSize);
            Ms.Position := 0;
            Stream.CopyFrom(Ms, Info.DataSize);
          finally
            Ms.Free;
          end;
        end;
      finally
        Reg.SetCurrentKey(OldKey);
      end;
    finally
      RegCloseKey(Key);
    end;
  finally
    Reg.Free;
  end;
end;

end.

