unit unit_rewrite_icon;

// 参考) Delphi Tips & Tricks (既存EXE（実行）ファイルのアイコンを入れ替える)
// http://www.geocities.jp/asumaroyuumaro/program/tips/ExeIconChange.html
// 
// UpdateResource() の限界っぽい
// EXEによってパラメータの設定を変える必要がある
//
(** 実際の使用例
------------------------------------
var
  p: TIconChanger;
begin
  p := TIconChanger.Create;
  p.change('a.exe', 'icon.ico');
  p.Free;
end;
------------------------------------
*)
interface
uses
  Windows, SysUtils, Classes, Graphics;

type
  //リソースアイコン用 TIconRec
  TIconResInfo =packed record
    Width   : Byte;
    Height  : Byte;
    Colors  : Word;
    Plane   : Word;
    BitCount: Word;
    DIBSize : DWord;
    ID      : Word; //TIconRecはここがLongIntで２バイト分違う
  end;
  PIconResInfo =^TIconResInfo;

  //EnumResourceProcで取得したリソースIDを保持しておくレコード
  TResourceName =packed record
   FString: Boolean; //Trueならリソース名が文字列 Falseなら数値ID
   RTID  : PChar;
   RTName: string;
  end;
  PResourceName =^TResourceName;

  TIconChanger = class
  public
    //変更対象の実行ファイルと、挿入されるアイコンファイルのパス
    ExeName, IconName: string;
  private
    function SwitchResourceIcon(Resname: PChar):Boolean;
  public
    function Change(ExePath, IconPath: string): Boolean;
  end;

implementation

{ TIconChanger }

function EnumResNameProc(hFile: THandle; ResType: PChar;
  ResStr: PChar; pResname: PResourceName):LongBool; stdcall;
begin
  //はじめに見つかったグループアイコンを更新対象とする
  if HiWord(Cardinal(ResStr)) =0 then
  begin
    //上位２バイトが 0ならID(数値)
    pResName^.RTID :=ResStr;
    pResName^.FString :=False;
  end
  else begin
    //それ以外は文字列へのポインタ
    pResName^.RTName :=ResStr;
    pResName^.FString :=True;
  end;
  //列挙終了
  Result :=False;
end;


function TIconChanger.Change(ExePath, IconPath: string): Boolean;
var
  hFile  : THandle;
  ResName :TResourceName;
begin
  Self.ExeName  := ExePath;
  Self.IconName := IconPath;

  hFile := LoadLibraryEx(PChar(ExeName), 0,
                        LOAD_LIBRARY_AS_DATAFILE or
                        LOAD_WITH_ALTERED_SEARCH_PATH);
  try
    if hFile <> 0 then
    begin
      EnumResourceNames(hFile, RT_GROUP_ICON, @EnumResNameProc, LPARAM(@Resname));
    end;
  finally
    FreeLibrary(hFile);
  end;

  if ResName.FString then
  begin
    ResName.RTID :=PChar(ResName.RTName);
  end;
  Result :=SwitchResourceIcon(ResName.RTID);
end;

function TIconChanger.SwitchResourceIcon(Resname: PChar):Boolean;
const
  sizeCI =Sizeof(TCursororIcon);
  sizeIR =Sizeof(TIconRec);
  ID_LANG =1041;  //日本語の言語識別子
var
  hUpdate: THandle;
  ms: TMemoryStream;
  fs: TFileStream;
  Buf: PByteArray;
  i: integer;
  pInfo: PIconRec;
  CI: TCursororIcon;
  IR: array of TIconResInfo;
  icon_id: Integer;
begin
  Result :=False;
  if not FileExists(Exename) then
  begin
    raise Exception.Create('実行ファイルが見つかりません。');
  end;
  if not FileExists(Iconname) then
  begin
    raise Exception.Create('アイコンファイルが見つかりません。');
  end;

  //リソースの更新を開始　第二引数で既存のリソースの削除を指定
  hUpdate :=BeginUpdateResource(PChar(ExeName), False);
  if hUpdate = 0 then Exit;

  fs :=TFileStream.Create(IconName, fmOpenRead);
  try
    Buf :=AllocMem(fs.Size);
    try
     //アイコンファイルの内容をバッファにコピー
     fs.ReadBuffer(Buf^, fs.Size);
     //TCursororIcon レコードを組み立て
     CI.Reserved :=0;
     CI.wType    :=1;
     CI.Count    :=PCursororIcon(Buf).Count;

     //アイコンの数だけ TIconResInfoを用意
     SetLength(IR, CI.Count);

     for i :=0 to CI.Count -1 do
     begin
       //TIconResInfo レコードを組み立て
       pInfo := @Buf[sizeCI + sizeIR * i];
       IR[i].Width  :=pInfo.Width;
       IR[i].Height :=pInfo.Height;
       IR[i].Colors :=pInfo.Colors;
       IR[i].Plane  :=pInfo.Reserved1;
       IR[i].BitCount :=pInfo.Reserved2;
       IR[i].DIBSize  :=pInfo.DIBSize;
       icon_id        := i + 3;
       IR[i].ID       := icon_id;
       //先に各アイコンのDIBを実行ファイルに追加
       UpdateResource(hUpdate, RT_ICON, PChar(icon_id), ID_Lang,
                      @Buf[pInfo.DIBOffset], pInfo.DIBSize);
     end;

     ms :=TMemoryStream.Create;
     try
       //グループアイコンデータをストリームに作って実行ファイルに追加
       //(さっき組み立てたTCursororIcon + TIconResInfo x アイコン数)
       ms.WriteBuffer(CI, sizeCI);
       ms.WriteBuffer(IR[0], sizeIR * CI.Count);
       if not UpdateResource(hUpdate, RT_GROUP_ICON, Resname,
                              ID_LANG, ms.Memory, ms.Size) then Exit;
       //更新を終了
       if EndUpdateResource(hUpdate, False) then
       begin
        //ここまでくればたぶん成功
        Result :=True;
       end;
     finally
       ms.Free;
     end;
    finally
      FreeMem(Buf);
    end;
  finally
    fs.Free;
  end;
end;


end.
