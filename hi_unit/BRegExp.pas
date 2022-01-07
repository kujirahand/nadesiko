unit BRegExp;

//=====================================================================
// BRegExp.pas : Borland Delphi �p BREGEXP.DLL ���p���j�b�g
//
// BREGEXP.DLL �́Ahttp://www.hi-ho.or.jp/~babaq/ �ɂČ��J����Ă���
// Perl5�݊��̐��K�\���G���W�� BREGEXP.DLL �� Borland Delphi ���痘�p
// ���邽�߂̃��j�b�g�t�@�C���ł��BDelphi 3 �ō쐬���܂������A32bit
// �ł� Delphi ����� C++ Builder �œ���\�Ǝv���܂��B
//
// BREGEXP.DLL �̗��p�����Ȃǂ́A���z�[���y�[�W�����Q�Ɖ������B�L�p��
// ���C�u�����𖳏��Œ񋟉������Ă��� babaq ����Ɋ��ӂ���ƂƂ��ɁA
// ����̂���������҂��Ă��܂��B
//
// �{���j�b�g�̒��쌠�ɂ��ẮA�Ƃ₩����������͂���܂���B�D����
// �悤�ɂ��g���������B�������A���p�ɓ������Ă͂������̐ӔC�̉��ɂ���
// �����܂��B�{���j�b�g�Ɋւ��� osamu@big.or.jp �͉���ӔC�𕉂����Ƃ�
// �������̂Ƃ��܂��B
//
// �{���j�b�g�́A DLL �ƂƂ��ɔz�z����Ă���w�b�_�t�@�C���y�сA��L�z�[��
// �y�[�W�ōs��ꂽ���[�U�T�|�[�g�̃��O�t�@�C�������Ƃɍ쐬����܂����B
// ���C�Â��̓_�Ȃǂ���܂�����Aosamu@big.or.jp �܂œd�q���[���ɂ�
// ���m�点������΁A�C������ł͂Ȃ�炩�̑Ώ�������\��������܂��B(^_^;
//
// �g�p���@�ɂ��Ă͕t���̃w���v�t�@�C���������������B
//=====================================================================
//               2001/04/14��      osamu@big.or.jp
// �{�Ƃ̃h�L�������g�̃o�[�W�����A�b�v�ɔ������o���Ă����o�O���C��
//
//               2001/09/18��      kujirahand.com
//                                 ���I�Ɏg����悤�� Create ��ǉ��B
//=====================================================================
{
[�g����]

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

uses
  {$IFDEF Win32}
  Windows,
  {$ENDIF}
  SysUtils, Classes;

//=====================================================================
// �{�� BREGEXP.H �ƁA�T�|�[�g�z�[���y�[�W�̃h�L�������g���
// BREGEXP.DLL �ƒ��������錾
//=====================================================================

const
BREGEXP_ERROR_MAX= 80;  // �G���[���b�Z�[�W�̍ő咷

DLL_BREGEXP = 'BREGEXP.DLL';
//DLL_BREGEXP = 'bregonig.dll';

type
PPAnsiChar=^PAnsiChar;
TBRegExpRec=packed record
    outp: PAnsiChar;        // �u�������ʐ擪�|�C���^
    outendp: PAnsiChar;     // �u�������ʖ����|�C���^
    splitctr: Integer;  // split ���ʃJ�E���^
    splitp: PPAnsiChar;     // split ���ʃ|�C���^�|�C���^
    rsv1: Integer;      // �\��ς�
    parap: PAnsiChar;       // �R�}���h������擪�|�C���^ ('s/xxxxx/yy/gi')
    paraendp: PAnsiChar;    // �R�}���h�����񖖔��|�C���^
    transtblp: PAnsiChar;   // tr �e�[�u���ւ̃|�C���^
    startp: PPAnsiChar;     // �}�b�`����������ւ̐擪�|�C���^
    endp: PPAnsiChar;       // �}�b�`����������ւ̖����|�C���^
    nparens: Integer;   // match/subst ���̊��ʂ̐�
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
// TBRegExp : BREGEXP.DLL �̋@�\���J�v�Z��������I�u�W�F�N�g
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

uses EasyMasks, unit_string, mini_file_utils;

const CBOOL_FALSE = 0;


function bregMatch(s, pat, opt: AnsiString; matches: TStringList = nil): Boolean;
var
  re: TBRegExp;
  i: Integer;
  pat2: String;

  function escPat(pat, opt: string): string;
  begin
      pat := JReplaceA(pat, '#', '\#');
      pat := 'm#' + pat + '#' + opt;
      Result := pat;
  end;

begin
  re := TBRegExp.Create;

  // ���|�[�g�ɒǉ�
  // load check
  if re.hDll = 0 then raise Exception.Create('Bregexp.dll������܂���BWEB�����肵�Ă��������B');

  // match
  try
    // movie�΍�
    if Copy(pat,1,1) = 'm' then
    begin
      pat2 := pat + ' ';
      if pat2[2] in ['/','#','$','%','~','@'] then
      begin
        // pass
      end else begin
        pat := escPat(pat, opt);
      end;
    end else if Copy(pat,1,1) <> 'm' then
    begin
      pat := JReplaceA(pat, '#', '\#');
      if s =''then //�󕶎��}�b�`�̃S�~�΍�
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
      Exit; // �}�b�`���Ȃ������甲����
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
// �O��̃R�}���h�������Ԃ�

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
// �O��ƈقȂ�R�}���h�ł���΃L���b�V�����N���A��������葱��

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
    if TargetString='' then begin // �G���[���
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
    TextBuffer:= TargetString;  // ( ) �𐳂����Ԃ����߂Ƀe�L�X�g��ۑ�����
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

    if Result then begin // ( ) �̌��ʂ𐳂����Ԃ�����
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
    if TargetString='' then // �G���[���
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
    if TargetString='' then begin // �G���[���
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
        {raise EBRegExpError.Create('no count now')};// �G���[�͏o���Ȃ�
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
  { DLL �̓��I�Ăяo�� }
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
      {raise EBRegExpError.Create('no strings now')};//�}�b�`���Ȃ�

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
  len := (pBregExp^.outendp - pBregExp^.outp);
  SetLength(tmp, len);
  Move(pBregExp^.outp^, tmp[1], len);
  Result := tmp;
end;


end.

