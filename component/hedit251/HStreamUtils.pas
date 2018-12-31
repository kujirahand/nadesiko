(*********************************************************************

  HStreamUtils.pas

  start  2000/12/24
  update 2001/07/25

  Copyright (c) 2000,2001 本田勝彦 <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  TComponent を丸ごと TStream へ保存復帰するための手続き
  TStream をレジストリへ保存復帰するための手続き
  TStream を TStrings を介して ini ファイルへ保存復帰するための手続き
  が記述されている。

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
  以下の ComponentToStream, StreamToComponent は
  nifty:FDELPHI/MES/10/2168 の、六角三房 さん ( CXE02604 ) の
  発言を参考にさせて頂きました
*)

(*
  StreamToComponent, ComponentToStream 手続きでは、イベントハンドラの設定
  や、ウィンドゥハンドルを再生成する必要がある ScrollBars プロパティなど
  を保存・復帰するために、引数で渡されたコンポーネントを一旦破棄し、スト
  リームデータから生成したコンポーネントを該当コンポーネントの Owner に
  よって「入れ替え」てもらうという方式を取っている。

  TFountain などの他のコンポーネントに接続して利用するコンポーネントでは、
  Notification の仕組みを利用しているので、破棄された時点で接続が切断さ
  れてしまう。このようなコンポーネントに対しては、TStoreComponent 各
  メソッドで使われている TStream.WriteComponent, ReadComponent メソッド
  を利用すること。

  StreamToComponent, ComponentToStream 手続きによるストリームデータと
  TStream.WriteComponent, ReadComponent メソッドによるデータは相互に
  読み書きすることが可能である。
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
    // イベントハンドラの設定を保存するために、ハンドラの所有者で
    // ある Owner を Writer.Root に設定する
    // cf Classes.pas
    // TWriter.WriteProperty, WriteMethodProp, IsDefaultValue
    if Instance.Owner = nil then
      Writer.Root := Instance
    else
      Writer.Root := Instance.Owner;
    Writer.WriteSignature;
    Writer.WriteComponent(Instance);
    // TReader.ReadComponents が最後に ReadListEnd を実行するので、
    // データサイズを合わせるために WriteListEnd を実行する。
    Writer.WriteListEnd;
  finally
    Writer.Free;
  end;
end;

(*
  下記 StreamToComponent で利用される TReader.ReadComponents では、
  ReadComponent メソッド実行後 ReadListEnd メソッドを実行している。
  上記 ComponentToStream では、その仕様に合わせるため、WriteComponent
  メソッド実行後 WriteListEnd メソッドを実行している。
  しかし、TStream.WriteComponent で作成されたストリームデータには
  この最後の１バイトが存在しないので、下記 StreamToComponent で処理すると
  EReadError が発生する。

  TStream.WriteComponent で作成されたデータの最後は 00 00 であり
  ComponentToStream で作成されたデータの最後は      00 00 00 となる。
                                             １バイト多い/^^

  StreamToComponent では TStream.WriteComponent によって作成された
  データも処理出来るように、ReadComponents メソッドに渡す TReadComponentsProc
  型メソッド内で、TReader のストリームポジションを１バイト戻すことにする。
  このメソッドは ReadComponents で、ReadComponent 実行後、ReadListEnd 実行前
  に呼び出される。
*)

//  TReader.ReadComponents を利用するためのクラス  //////////////////
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
    TReader.ReadComponents へ渡す第１引数の AOwner が、ストリームから
    生成されるコンポーネントのクラスを総て知っていないと例外が生成
    されるので、Component.Owner を渡す。これによってイベントハンドラ
    も復帰される。
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

//  TRegistry の protected なメソッドにアクセスするための宣言  //////
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

