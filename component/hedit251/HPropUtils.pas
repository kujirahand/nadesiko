(*********************************************************************

  HPropUtils.pas

  start  2001/02/24
  update 2001/07/25

  Copyright (c) 2001 �{�c���F <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  �I�u�W�F�N�g�̃v���p�e�B�����s���^���𗘗p���đ��삷�邽�߂�
  �葱�����L�q����Ă���B

**********************************************************************)

unit HPropUtils;

{$I heverdef.inc}

interface

uses
  SysUtils, Classes, TypInfo;

type
  TGetPropProc = procedure (Instance: TObject; pInfo: PPropInfo;
    tInfo: PTypeInfo) of Object;
(*
  EnumProperties ���񋓂���v���p�e�B���󂯎�邽�߂̃��\�b�h�̌^�錾�B
  tInfo: PTypeInfo �� pInfo.PropType^ �Ŏ擾�o���邪�A�c�Q�̏ꍇ��
  pInfo.PropType �ƂȂ�̂ŁA���̌^�̃��\�b�h����������s�x
  {$IFDEF VER90} �̔��ʂ��s���ώG��������邽�߁AEnumProperties �Ŏ擾
  �������̂��󂯎��d�l�Ƃ���B
  Instance ... �v���p�e�B�����L����I�u�W�F�N�g�ւ̎Q��
  pInfo ...... pInfo.Name �Ńv���p�e�B�̖��O���擾�o����B
  tInfo ...... tInfo.Name �Ō^�̖��O ex TColor, String ��
               tInfo.Kind �Ō^�̎�� ex tkClass, tkInteger ���擾�o����
*)

procedure EnumProperties(Instance: TPersistent; TypeKinds: TTypeKinds;
  Proc: TGetPropProc);

procedure AssignProperties(Source, Dest: TPersistent; TypeKinds: TTypeKinds);

implementation

procedure EnumProperties(Instance: TPersistent; TypeKinds: TTypeKinds;
  Proc: TGetPropProc);
(*
  Instance �� published & TypeKinds �ȃv���p�e�B��񋓂���B
  ���̃v���p�e�B�� TPersistent �ȃI�u�W�F�N�g�̏ꍇ�́A�ċA�I�ɏ�������B
  ���̃I�u�W�F�N�g�� TCollection �̏ꍇ�́AItems.Count �̃��[�v�ŏ�������B
  TypeKinds �ɂ͈��������^�̃^�C�v���w�肷��
  [tkClass]           �N���X�^�̃v���p�e�B�̂ݏ�������
  tkAny               ���ׂĂ̌^�̃v���p�e�B�i�C�x���g���܂ށj
  tkMethods           �C�x���g�ɑ΂��邷�ׂĂ̌^�̃v���p�e�B
  tkProperties        ��C�x���g�v���p�e�B�ɑ΂��邷�ׂĂ̌^
*)
var
  PropList: PPropList;
  tInfo: PTypeInfo;
  Count, I, J: Integer;
  PropInstance: TObject;
begin
  Count := GetPropList(Instance.ClassInfo, TypeKinds, nil);
  GetMem(PropList, Count * SizeOf(PPropInfo));
  try
    GetPropList(Instance.ClassInfo, TypeKinds, PropList);
    // PropList �̊e���ڂ� PPropInfo
    for I := 0 to Count - 1 do
    begin
      {$IFDEF COMP2}
      tInfo := PropList[I].PropType;
      {$ELSE}
      tInfo := PropList[I].PropType^;
      {$ENDIF}
      Proc(Instance, PropList[I], tInfo);
      if tInfo.Kind = tkClass then
      begin
        PropInstance := TObject(GetOrdProp(Instance, PropList[I]));
        if PropInstance is TPersistent then
        begin
          EnumProperties(TPersistent(PropInstance), TypeKinds, Proc);
          if PropInstance is TCollection then
            for J := 0 to TCollection(PropInstance).Count - 1 do
              EnumProperties(TCollection(PropInstance).Items[J], TypeKinds, Proc);
        end;
      end;
    end;
  finally
    FreeMem(PropList, Count * SizeOf(PPropInfo));
  end;
end;

procedure AssignProperties(Source, Dest: TPersistent; TypeKinds: TTypeKinds);
(*
  Source �� published �ȃv���p�e�B�l�� Dest �փR�s�[����
  Source, Dest �͓����^���ADest �� Source ����h�����ꂽ�^�łȂ����
  �Ȃ�Ȃ��B�݊����̖����^�̃C���X�^���X��n���Ɨ�O����������B
  TypeKinds �ɂ̓R�s�[�������^�̃^�C�v���w�肷��
  [tkClass, tkString] �N���X�^�ƕ�����^�̃v���p�e�B�̂ݏ�������
  tkAny               ���ׂĂ̌^�̃v���p�e�B�i�C�x���g���܂ށj
  tkMethods           �C�x���g�ɑ΂��邷�ׂĂ̌^�̃v���p�e�B
  tkProperties        ��C�x���g�v���p�e�B�ɑ΂��邷�ׂĂ̌^
*)
var
  PropList: PPropList;
  I, Count: Integer;
begin
  Count := GetPropList(Source.ClassInfo, TypeKinds, nil);
  GetMem(PropList, Count * SizeOf(PPropInfo));
  try
    GetPropList(Source.ClassInfo, TypeKinds, PropList);
    for I := 0 to Count - 1 do
      {$IFDEF COMP2}
      case PropList[I].PropType.Kind of
      {$ELSE}
      case PropList[I].PropType^.Kind of
      {$ENDIF}
        tkFloat:
          SetFloatProp(
            Dest, PropList[I], GetFloatProp(Source, PropList[I]));
        tkInteger, tkChar, tkEnumeration, tkSet, tkClass:
          SetOrdProp(
            Dest, PropList[I], GetOrdProp(Source, PropList[I]));
        tkMethod:
          SetMethodProp(
            Dest, PropList[I], GetMethodProp(Source, PropList[I]));
        tkString:
          SetStrProp(
            Dest, PropList[I], GetStrProp(Source, PropList[I]));
        { ? tkArray, tkRecord, tkInterface, tkInt64, tkDynArray ? }
      end;
  finally
    FreeMem(PropList, Count * SizeOf(PPropInfo));
  end;
end;


end.
