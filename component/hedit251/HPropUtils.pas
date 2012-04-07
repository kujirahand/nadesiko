(*********************************************************************

  HPropUtils.pas

  start  2001/02/24
  update 2001/07/25

  Copyright (c) 2001 本田勝彦 <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  オブジェクトのプロパティを実行時型情報を利用して操作するための
  手続きが記述されている。

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
  EnumProperties が列挙するプロパティを受け取るためのメソッドの型宣言。
  tInfo: PTypeInfo は pInfo.PropType^ で取得出来るが、Ｄ２の場合は
  pInfo.PropType となるので、この型のメソッドを実装する都度
  {$IFDEF VER90} の判別を行う煩雑さを避けるため、EnumProperties で取得
  したものを受け取る仕様とする。
  Instance ... プロパティを所有するオブジェクトへの参照
  pInfo ...... pInfo.Name でプロパティの名前が取得出来る。
  tInfo ...... tInfo.Name で型の名前 ex TColor, String が
               tInfo.Kind で型の種類 ex tkClass, tkInteger が取得出来る
*)

procedure EnumProperties(Instance: TPersistent; TypeKinds: TTypeKinds;
  Proc: TGetPropProc);

procedure AssignProperties(Source, Dest: TPersistent; TypeKinds: TTypeKinds);

implementation

procedure EnumProperties(Instance: TPersistent; TypeKinds: TTypeKinds;
  Proc: TGetPropProc);
(*
  Instance の published & TypeKinds なプロパティを列挙する。
  そのプロパティが TPersistent なオブジェクトの場合は、再帰的に処理する。
  そのオブジェクトが TCollection の場合は、Items.Count のループで処理する。
  TypeKinds には扱いたい型のタイプを指定する
  [tkClass]           クラス型のプロパティのみ処理する
  tkAny               すべての型のプロパティ（イベントを含む）
  tkMethods           イベントに対するすべての型のプロパティ
  tkProperties        非イベントプロパティに対するすべての型
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
    // PropList の各項目は PPropInfo
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
  Source の published なプロパティ値を Dest へコピーする
  Source, Dest は同じ型か、Dest は Source から派生された型でなければ
  ならない。互換性の無い型のインスタンスを渡すと例外が発生する。
  TypeKinds にはコピーしたい型のタイプを指定する
  [tkClass, tkString] クラス型と文字列型のプロパティのみ処理する
  tkAny               すべての型のプロパティ（イベントを含む）
  tkMethods           イベントに対するすべての型のプロパティ
  tkProperties        非イベントプロパティに対するすべての型
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
