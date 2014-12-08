unit BRegExp;

//=====================================================================
// BRegExp.pas : Borland Delphi 用 BREGEXP.DLL 利用ユニット
//
// BREGEXP.DLL は、http://www.hi-ho.or.jp/~babaq/ にて公開されている
// Perl5互換の正規表現エンジン BREGEXP.DLL を Borland Delphi から利用
// するためのユニットファイルです。Delphi 3 で作成しましたが、32bit
// 版の Delphi および C++ Builder で動作可能と思います。
//
// BREGEXP.DLL の利用条件などは、同ホームページをご参照下さい。有用な
// ライブラリを無償で提供下さっている babaq さんに感謝するとともに、
// 今後のご活躍を期待しています。
//
// 本ユニットの著作権については、とやかく言うつもりはありません。好きな
// ようにお使い下さい。ただし、利用に当たってはご自分の責任の下にお願
// いします。本ユニットに関して osamu@big.or.jp は何ら責任を負うことは
// 無いものとします。
//
// 本ユニットは、 DLL とともに配布されているヘッダファイル及び、上記ホーム
// ページで行われたユーザサポートのログファイルをもとに作成されました。
// お気づきの点などありましたら、osamu@big.or.jp まで電子メールにて
// お知らせ下されば、気分次第ではなんらかの対処をする可能性があります。(^_^;
//
// 使用方法については付属のヘルプファイルをご覧下さい。
//=====================================================================
//               2001/04/14版      osamu@big.or.jp
// 本家のドキュメントのバージョンアップに伴い発覚していたバグを修正
//
//               2001/09/18版      kujirahand.com
//                                 動的に使えるように Create を追加。
//=====================================================================
{
[使い方]

var s: AnsiString;
    i: Integer;

begin

    s:='123;456;789';

    brx.Match('m/;(+);/',s);

    Memo1.Text := brx.Text;

        // '123'

        // '456'

        // '789'


    brx.Split('m/;/',s,1000);

    Memo1.Text := brx.Text

        // '123'

        // '456'

        // '789'

    brx.Subst('s/(+)/"$1"/g',s);

    Memo1.Lines.Add(s);

        // '"123";"456";"789"'

    brx.Trans('tr/;/,/',s);

    Memo1.Lines.Add(s);

        // '"123","456","789"'

end;
}



interface

uses Windows,SysUtils, Classes;

//=====================================================================
// 本家 BREGEXP.H と、サポートホームページのドキュメントより
// BREGEXP.DLL と直結した宣言
//=====================================================================

const
BREGEXP_ERROR_MAX= 80;  // エラーメッセージの最大長

DLL_BREGEXP = 'BREGEXP.DLL';
//DLL_BREGEXP = 'bregonig.dll';

type
PPAnsiChar=^PAnsiChar;
TBRegExpRec=packed record
    outp: PAnsiChar;        // 置換え結果先頭ポインタ
    outendp: PAnsiChar;     // 置換え結果末尾ポインタ
    splitctr: Integer;  // split 結果カウンタ
    splitp: PPAnsiChar;     // split 結果ポインタポインタ
    rsv1: Integer;      // 予約済み
    parap: PAnsiChar;       // コマンド文字列先頭ポインタ ('s/xxxxx/yy/gi')
    paraendp: PAnsiChar;    // コマンド文字列末尾ポインタ
    transtblp: PAnsiChar;   // tr テーブルへのポインタ
    startp: PPAnsiChar;     // マッチした文字列への先頭ポインタ
    endp: PPAnsiChar;       // マッチした文字列への末尾ポインタ
    nparens: Integer;   // match/subst 中の括弧の数
end;
pTBRegExpRec=^TBRegExpRec;
(*
function BMatch(str, target, targetendp: PAnsiChar;
                var rxp: pTBRegExpRec; msg: PAnsiChar): Boolean; cdecl;
    external 'bregexp.dll';
function BSubst(str, target, targetendp: PAnsiChar;
                var rxp: pTBRegExpRec; msg: PAnsiChar): Boolean; cdecl;
    external 'bregexp.dll';
function BTrans(str, target, targetendp: PAnsiChar;
                var rxp: pTBRegExpRec; msg: PAnsiChar): Boolean; cdecl;
    external 'bregexp.dll';
function BSplit(str, target, targetendp: PAnsiChar; limit: Integer;
                var rxp: pTBRegExpRec; msg: PAnsiChar): Boolean; cdecl;
    external 'bregexp.dll';
procedure BRegFree(rx: pTBRegExpRec); cdecl;
    external 'bregexp.dll' name 'BRegfree';
function BRegExpVersion: PAnsiChar; cdecl;
    external 'bregexp.dll' name 'BRegexpVersion';
*)
//=====================================================================
// TBRegExp : BREGEXP.DLL の機能をカプセル化するオブジェクト
//=====================================================================

type
EBRegExpError=class(Exception) end;
TBRegExpMode=(brxNone, brxMatch, brxSplit);
TBRegExp=class(TObject)
  private
    BMatch:function(str, target, targetendp: PAnsiChar;
                var rxp: pTBRegExpRec; msg: PAnsiChar): Integer; cdecl;
    BSubst:function(str, target, targetendp: PAnsiChar;
                var rxp: pTBRegExpRec; msg: PAnsiChar): Integer; cdecl;
    BTrans:function(str, target, targetendp: PAnsiChar;
                var rxp: pTBRegExpRec; msg: PAnsiChar): Integer; cdecl;
    BSplit:function(str, target, targetendp: PAnsiChar; limit: Integer;
                var rxp: pTBRegExpRec; msg: PAnsiChar): Integer; cdecl;
    BRegFree:procedure(rx: pTBRegExpRec); cdecl;
    BRegExpVersion:function: PAnsiChar; cdecl;
  private
    Mode: TBRegExpMode;
    pTargetString: PAnsiChar;
    pBRegExp: PTBRegExpRec;
    function GetMatchPos: Integer;
    function GetMatchLength: Integer;
    function GetSplitCount: Integer;
    function GetSplitStrings(index: Integer): AnsiString;
    function GetMatchStrings(index:Integer): AnsiString;
    function GetMatchCount: Integer;
    function GetCount: Integer;
    function GetStrings(index: Integer): AnsiString;
    function GetLastCommand: AnsiString;
    function GetText: AnsiString;
    procedure CheckCommand(const Command: AnsiString);
    function GetBRegExpOutpuStr: AnsiString;
  public
    hDll:THandle;
    constructor Create;
    destructor Destroy; override;
  public
    function Match(const Command, TargetString: AnsiString): Boolean;
    function Subst(const Command: AnsiString; var TargetString: AnsiString): Boolean;
    function Split(const Command, TargetString: AnsiString; Limit: Integer): Boolean;
    function Trans(const Command: AnsiString;var TargetString: AnsiString): Boolean;
    property LastCommand: AnsiString read GetLastCommand;
    property MatchPos: Integer read GetMatchPos;
    property MatchLength: Integer read GetMatchLength;
    property Count: Integer read GetCount;
    property Strings[index: Integer]: AnsiString read GetStrings; default;
    property Text: AnsiString read GetText;
end;

//=====================================================================

var PATH_BREGEXP_DLL: string = DLL_BREGEXP;

function bregMatch(s, pat, opt: AnsiString; matches: TStringList = nil): Boolean;

implementation

uses Masks, unit_string, mini_file_utils;

const CBOOL_FALSE = 0;


function bregMatch(s, pat, opt: AnsiString; matches: TStringList = nil): Boolean;
var
  re: TBRegExp;
  i: Integer;
begin
  re := TBRegExp.Create;

  // レポートに追加
  // load check
  if re.hDll = 0 then raise Exception.Create('Bregexp.dllがありません。WEBより入手してください。');

  // match
  try
    if Copy(pat,1,1) <> 'm' then
    begin
      pat := JReplaceA(pat, '#', '\#');
      if s =''then //空文字マッチのゴミ対策
      begin
        if (Length(pat) > 0)and(pat[1] = '^') then
        begin
          Delete(pat,1,1);
          pat := 'm#^.' + pat + '#' + opt;
        end
        else
          pat := 'm#.' + pat + '#' + opt;
      end
      else
        pat := 'm#' + pat + '#' + opt;
    end;

    Result := re.Match(pat, s);
    if not Result then
    begin
      Exit; // マッチしなかったら抜ける
    end;
    if matches = nil then Exit;
    for i := 0 to re.GetCount - 1 do
    begin
      matches.Add(AnsiString(re.GetStrings(i)));
    end;
  finally
    FreeAndNil(re);
  end;

end;

//=====================================================================

destructor TBRegExp.Destroy;
begin
    if pBRegExp<>nil then
        BRegFree(pBRegExp);
    inherited Destroy;
end;

//=====================================================================
// 前回のコマンド文字列を返す

function TBRegExp.GetLastCommand: AnsiString;
var len: Integer;
begin
    if pBRegExp=nil then begin
        Result:= '';
    end else begin
        len:= Integer(pBRegExp^.paraendp)-Integer(pBRegExp^.parap);
        SetLength(Result, len);
        Move(pBRegExp^.parap^, Result[1], len);
    end;
end;

//=====================================================================
// 前回と異なるコマンドであればキャッシュをクリアする内部手続き

procedure TBRegExp.CheckCommand(const Command: AnsiString);
var p,q: PAnsiChar;
begin
    if pBRegExp=nil then Exit;
    p:= pBRegExp.parap - 1;
    q:= PAnsiChar(@Command[1]) - 1;
    repeat
        Inc(p);
        Inc(q);
        if p^<>q^ then begin
            BRegFree(pBRegExp);
            pBRegExp:= nil;
            Break;
        end;
    until p^=#0;
end;

//=====================================================================

function TBRegExp.Match(const Command, TargetString: AnsiString): Boolean;
var ErrorString: AnsiString;
    i: Integer;
begin
    CheckCommand(Command);
    SetLength(ErrorString, BREGEXP_ERROR_MAX);
    Mode:=brxNone;
    if TargetString='' then begin // エラー回避
        i:=0;
        Result:=BMatch(
            PAnsiChar(Command),
            PAnsiChar(@i),
            PAnsiChar(@i)+1,    
            pBRegExp,
            PAnsiChar(ErrorString)) <> CBOOL_FALSE;
    end else begin
        Result:=BMatch(
            PAnsiChar(Command),
            PAnsiChar(TargetString),
            PAnsiChar(TargetString)+Length(TargetString),
            pBRegExp,
            PAnsiChar(ErrorString)) <> CBOOL_FALSE;
    end;
    SetLength(ErrorString, StrLen(PAnsiChar(ErrorString)));
    if ErrorString<>'' then
        raise EBRegExpError.Create(string(ErrorString));

    if Result then Mode:= brxMatch;
    pTargetString:= PAnsiChar(TargetString);
end;

//=====================================================================

function TBRegExp.Subst(const Command: AnsiString;
                        var TargetString: AnsiString): Boolean;
var
    TextBuffer: AnsiString;
    ErrorString: AnsiString;
    ep,sp: PPAnsiChar;
    i, len: Integer;
begin
    TextBuffer := '';
    CheckCommand(Command);
    Result:=False;
    if TargetString='' then Exit;
    TextBuffer:= TargetString;  // ( ) を正しく返すためにテキストを保存する
    UniqueString(TextBuffer);
    SetLength(ErrorString, BREGEXP_ERROR_MAX);
    Mode:=brxNone;
    Result:=BSubst(
        PAnsiChar(Command),
        PAnsiChar(TargetString),
        PAnsiChar(TargetString)+Length(TargetString),
        pBRegExp,
        PAnsiChar(ErrorString)) <> CBOOL_FALSE;
    SetLength(ErrorString,StrLen(PAnsiChar(ErrorString)));
    if ErrorString<>'' then
        raise EBRegExpError.Create(string(ErrorString));

    if Result then begin // ( ) の結果を正しく返すため
        sp:=pBRegExp^.startp;
        ep:=pBRegExp^.endp;
        len := Integer(TextBuffer) - Integer(TargetString);
        for i:=0 to GetMatchCount-1 do begin
            Inc(ep^, len);
            Inc(sp^, len);
            Inc(sp);
            Inc(ep);
        end;
        //
        TargetString := GetBRegExpOutpuStr;
        Mode:=brxMatch;
    end;
end;

//=====================================================================

function TBRegExp.Trans(const Command: AnsiString;
                        var TargetString: AnsiString): Boolean;
var ErrorString: AnsiString;
begin
    CheckCommand(Command);
    Mode:=brxNone;
    if TargetString='' then // エラー回避
        TargetString:= #0;
    SetLength(ErrorString, BREGEXP_ERROR_MAX);
    Result:=BTrans(
        PAnsiChar(Command),
        PAnsiChar(TargetString),
        PAnsiChar(TargetString)+Length(TargetString),
        pBRegExp,
        PAnsiChar(ErrorString)) <> CBOOL_FALSE;
    SetLength(ErrorString,StrLen(PAnsiChar(ErrorString)));
    if ErrorString<>'' then
        raise EBRegExpError.Create(string(ErrorString));
    if Result then TargetString:=GetBRegExpOutpuStr;
end;

//=====================================================================

function TBRegExp.Split(const Command, TargetString: AnsiString;
                        Limit: Integer): Boolean;
var ErrorString: AnsiString;
    t: AnsiString;
begin
    CheckCommand(Command);
    SetLength(ErrorString, BREGEXP_ERROR_MAX);
    Mode:=brxNone;
    if TargetString='' then begin // エラー回避
        t:= #0;
        Result:=BSplit(
            PAnsiChar(Command),
            PAnsiChar(t),
            PAnsiChar(t)+1,
            Limit,
            pBRegExp,
            PAnsiChar(ErrorString)) <> CBOOL_FALSE;
    end else begin
        Result:=BSplit(
            PAnsiChar(Command),
            PAnsiChar(TargetString),
            PAnsiChar(TargetString)+Length(TargetString),
            Limit,
            pBRegExp,
            PAnsiChar(ErrorString)) <> CBOOL_FALSE;
    end;
    SetLength(ErrorString,StrLen(PAnsiChar(ErrorString)));
    if ErrorString<>'' then
        raise EBRegExpError.Create(string(ErrorString));
    Mode:=brxSplit;
end;

//=====================================================================

function TBRegExp.GetMatchPos: Integer;
begin
    if Mode<>brxMatch then
        raise EBRegExpError.Create('no match pos');
    Result:=Integer(pBRegExp.startp^)-Integer(pTargetString)+1;
end;

//=====================================================================

function TBRegExp.GetMatchLength: Integer;
begin
    if Mode<>brxMatch then
        raise EBRegExpError.Create('no match length');
    Result:=Integer(pBRegExp.endp^)-Integer(pBRegExp.startp^);
end;

//=====================================================================

function TBRegExp.GetCount: Integer;
begin
    Result:=0;
    case Mode of
    brxNone:
        {raise EBRegExpError.Create('no count now')};// エラーは出さない
    brxMatch:
        Result:=GetMatchCount;
    brxSplit:
        Result:=GetSplitCount;
    end;
end;

//=====================================================================

function TBRegExp.GetMatchCount: Integer;
begin
    if (pBRegExp <> nil) then
    begin
      Result:= pBRegExp^.nparens+1;
    end else begin
      Result := 0;
    end;
end;

//=====================================================================

function TBRegExp.GetSplitCount: Integer;
begin
    if (pBRegExp <> nil) then
    begin
      Result:=pBRegExp^.splitctr;
    end else begin
      Result := 0;
    end;
end;

//=====================================================================

function TBRegExp.GetStrings(index: Integer): AnsiString;
begin
    Result:='';
    case Mode of
    brxNone:
        raise EBRegExpError.Create('no strings now');
    brxMatch:
        Result:=GetMatchStrings(index);
    brxSplit:
        Result:=GetSplitStrings(index);
    end;
end;

//=====================================================================

function TBRegExp.GetMatchStrings(index:Integer): AnsiString;
var
  sp,ep: PPAnsiChar;
  len: Integer;
begin
    Result:='';
    if (index<0) or (index>=GetMatchCount) then
        raise EBRegExpError.Create('index out of range');
    sp:=pBRegExp^.startp; Inc(sp, index);
    ep:=pBRegExp^.endp;   Inc(ep, index);
    len := Integer(ep^) - Integer(sp^);
    SetLength(Result, len);
    Move(sp^^, Result[1], len);
end;

//=====================================================================

function TBRegExp.GetSplitStrings(index:Integer): AnsiString;
var p: PPAnsiChar;
    sp,ep: PAnsiChar;
begin
    if (index<0) or (index>=GetSplitCount) then
        raise EBRegExpError.Create('index out of range');
    p:=pBRegExp^.splitp;
    Inc(p,index*2); sp:=p^;
    Inc(p);         ep:=p^;
    SetLength(Result,Integer(ep)-Integer(sp));
    Move(sp^,PAnsiChar(Result)^,Integer(ep)-Integer(sp));
end;

//=====================================================================

constructor TBRegExp.Create;
var
  p:TFarProc;
begin
  { DLL の動的呼び出し }
  PATH_BREGEXP_DLL := FindDLLFile(DLL_BREGEXP);
  hDll := LoadLibrary(PChar(PATH_BREGEXP_DLL));
  if hDll <= 0 then
  begin
    hDll := LoadLibrary(DLL_BREGEXP);
  end;
  if hDll<>0 then begin
    p := GetProcAddress(hDll, 'BMatch');
    if p<>nil then  @BMatch := p;
    p := GetProcAddress(hDll, 'BSubst');
    if p<>nil then  @BSubst := p;
    p := GetProcAddress(hDll, 'BTrans');
    if p<>nil then  @BTrans := p;
    p := GetProcAddress(hDll, 'BSplit');
    if p<>nil then  @BSplit := p;
    p := GetProcAddress(hDll, 'BRegfree');
    if p<>nil then  @BRegfree := p;
    p := GetProcAddress(hDll, 'BRegexpVersion');
    if p<>nil then  @BRegexpVersion := p;
  end;
end;

function TBRegExp.GetText: AnsiString;
var i: Integer;
begin
  Result:='';
  case Mode of
  brxNone:
      {raise EBRegExpError.Create('no strings now')};//マッチしない

  brxMatch:
    begin
          for i:=0 to GetMatchCount-1 do
          begin
            Result:=Result + GetMatchStrings(i) + #13#10;
          end;
      end;
  brxSplit:
    begin
          for i:=0 to GetSplitCount-1 do
          begin
            Result := Result + GetSplitStrings(i) + #13#10;
          end;
      end;
  end;
end;

function TBRegExp.GetBRegExpOutpuStr: AnsiString;
var
  len: Integer;
  tmp: AnsiString;
begin
  len := (pBregExp^.outendp - pBregExp^.outp) + 1;
  SetLength(tmp, len);
  Move(pBregExp^.outp^, tmp[1], len);
  Result := Copy(tmp, 1, StrLen(PChar(tmp)));
end;


end.

