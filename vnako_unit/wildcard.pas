unit wildcard;
(*------------------------------------------------------------------------------
���C���h�J�[�h�ɂ��}�b�` (VB �� "Like"��ʌ݊�)

Mineaki Yamamoto (mine@text2music.com) http://www.text2music.com
2002/02/15 ver.1.00
--------------------------------------------------------------------------------
*** WildCard ***

?         : �C�ӂ̂P����
*         : �C�ӂ̕�������(0�����ȏ�)
#         : �C�ӂ̐����P����
[str]    : str �Ɏw�肵�������̂ǂꂩ�P����
[!str]  : str �Ɏw�肵���ȊO�̕����̂ǂꂩ�P����
[*str]  : str �Ɏw�肵��������0��ȏ�̌J��Ԃ�(!�̕��p��)
[+str]  : str �Ɏw�肵��������1��ȏ�̌J��Ԃ�(!�̕��p��)
[=ab|cd]: ab �� cd �̂ǂ��炩�̕�����
(str)   : str �Ƀ}�b�`����������� PickupStr �ɔ����o��

\ : �V�[�P���X�L���A\\ \* \? �ŁA�񕶎��ڂ̕�����\��
    \n=���s \t=�^�u
================================================================================
(��)
pattern          str                Result    PickStr
---------------- ------------------ --------- -----------------
ab?d             abcd               True
no.##-####       no.12-3456         True
*cde             abcde              True
(*�X)            �A�C�X             True      �A�C�X
[A-Z]eer         Beer               True
[!A-Z]eer        Beer               False
([*��-��])��     ����               True      ��
[+��-��]s        s                  False
([=�����܂���|�a����])���߂łƂ� �a�������߂łƂ� True �a����
================================================================================
*** FUNCTION ***

function WildMatch(pattern, var str: string): String;

    ���C���h�J�[�h�ɂ�镶����̃}�b�`���O���s���܂��B
    �}�b�`�����Ƃ���܂ł��A���ʂɕԂ��܂��B�}�b�`���Ȃ������ꍇ�́A�u�v���A
    �Ԃ��܂��B�}�b�`�����c��̕�����́Astr�ɕԂ���܂��B


function WildMatchEx(pattern:string; var str: string; pickupStr: TStringList;
    CompleteCheck:Boolean): Boolean;

    pickupStr�ɂ́A(str)�ɂ�锲���o���������񂪃Z�b�g����܂��B
    CompleteCheck���AFalse�ɂ���ƁA������̂����ŁA�p�^�[���Ƀ}�b�`���Ă��Ȃ�
    �c��̕������Astr�ɕԂ��܂��B

*** CLASS ***

TWString ���A���̃��C���h�J�[�h���g�����}�b�`�̃��C���֐��ł��B

var
    pattern, s: TWString;
begin
    pattern := TWString.Create('([*��-��])���߂łƂ�') ;
    s := TWString.Create('�����܂��Ă��߂łƂ��������܂��B');
    if pattern.Match(s) then
    begin
        ShowMessage('TRUE:'+pattern.PickupStr.Text);
    end else begin
        ShowMessage('FALSE');
    end;

    s.Free;
    pattern.Free;
end;

------------------------------------------------------------------------------*)

interface
uses
  Classes, SysUtils;

type

  //----------------------------------------------------------------------------
  // TWString class
  TWString = class; //�Q�Ɨp

  TWSeq = class(TObject)
  public
    parent: TWString;
    function IsMatch(p: TWString): Boolean; virtual; abstract;
    function GetAsString: string; virtual; abstract;
  end;
  TWSeqArray = array of TWSeq;

  PWRange = ^TWRange;
  TWRange = record
    fFrom: Integer;
    fTo:   integer;
  end;

  TWString = class
  private
    FStr: TWSeqArray;
    FIndex: Integer;
    PickupEnabled: Boolean;
    procedure SetString(s: string);
    function GetString: string;
    function GetArray(Index: Integer): TWSeq;
    function subMatch(s: TWString): Boolean; // Match �ŗ��p���鉺�����֐�
  public
    PickupStr: TStringList;
    PickupRange: TWRange;
    constructor Create; overload;
    constructor Create(str: string); overload;
    destructor Destroy; override;
    procedure Clear;
    procedure First;
    function Next: TWSeq;
    procedure Prev;
    function EqualStr(s: TWString): Boolean;
    function Match(s: TWString): Boolean;
    function MatchNext(s: TWString): Boolean;
    function Mid(Index, Count: Integer): string;//Index�Ԗڂ̕�������ACount����
    property AsString: string read GetString write SetString;
    property AsArray[Index: Integer]: TWSeq read GetArray;
    property Index: Integer read FIndex;
    function GetLength: Integer;
  end;

  //----------------------------------------------------------------------------
  // TWSeq ����̔h���N���X(�������p)
  TWChar = class(TWSeq)
  public
    ch: array [0..1] of Char;
    constructor Create(var p: PChar);
    function GetAsString: string; override;
    function IsMatch(p: TWString): Boolean; override;
  end;

  TWQuestion = class(TWSeq)
    function GetAsString: string; override;
    function IsMatch(p: TWString): Boolean; override;
  end;

  TWAsterisk = class(TWSeq)
    function GetAsString: string; override;
    function IsMatch(p: TWString): Boolean; override;
  end;

  // [*0-9] [a-z] �Ȃǂ̊��ʃR�}���h
  TRepeatMode = (rmOff, rmAsterisk, rmPlus, rmEqual);
  TWKakko = class(TWSeq)
  private
    RangeList: TList;
    NegativeMode: Boolean;
    RepeatMode: TRepeatMode;
    SelectList: TStringList;
  public
    constructor Create(var p: PChar);
    destructor Destroy; override;
    function GetAsString: string; override;
    function IsMatch(p: TWString): Boolean; override;
  end;

  TWNumber = class(TWSeq)
    function GetAsString: string; override;
    function IsMatch(p: TWString): Boolean; override;
  end;

  TWPickupFrom = class(TWSeq)
    function GetAsString: string; override;
    function IsMatch(p: TWString): Boolean; override;
  end;
  TWPickupTo = class(TWSeq)
    function GetAsString: string; override;
    function IsMatch(p: TWString): Boolean; override;
  end;

//----------------------------------------------------------------------------
// match
function WildMatchEx(pattern:string; var str: string; pickupStr: TStringList; CompleteCheck:Boolean): Boolean;
function WildMatch(pattern: string; var str: string; pickupStr: TStringList):string;
function WildMatchFilename(fname, pattern: string):Boolean;
function WildMatchE(pattern: string; str: string):string;

implementation

uses
  StrUnit;

function WildMatchFilename(fname, pattern: string):Boolean;
begin
  if fname = '' then
  begin
    Result := False;
    Exit;
  end;
  Result := (WildMatchE(pattern, fname) = fname);
end;

function WildMatchE(pattern: string; str: string):string;
begin
  Result := WildMatch(pattern, str, nil);
end;

function WildMatch(pattern: string; var str: string; pickupStr: TStringList):string;
var
  pw,sw: TWString ;
begin
    pw := TWString.Create ;
    sw := TWString.Create ;
    try
        pw.AsString := pattern;
        sw.AsString := JReplace(str,'\','\\',True);// \ �̓V�[�P���X�ƔF�������̂ŁB
        if pw.Match(sw) then
        begin
            str := sw.Mid(sw.Index+1, sw.GetLength - sw.Index);
            Result := sw.Mid(1, sw.Index);
            if pickupStr<>nil then
            begin
                pickupStr.Assign(pw.PickupStr);
            end;
        end else begin
            Result := '';
        end;
    finally
        pw.Free;
        sw.Free;
    end;
end;

function WildMatchEx(pattern:string; var str: string; pickupStr: TStringList; CompleteCheck:Boolean): Boolean;
var
    pw,sw: TWString ;
begin
    pw := TWString.Create ;
    sw := TWString.Create ;
    try
        pw.AsString := pattern;
        sw.AsString := JReplace(str,'\','\\',True);// \ �̓V�[�P���X�ƔF�������̂ŁB
        Result := pw.Match(sw);
        if CompleteCheck=True then
        begin
            if sw.Index <> (sw.GetLength) then
            begin
                Result := False;
            end
        end else
        begin
            str := sw.Mid(sw.Index+1, sw.GetLength - sw.Index);
        end;

        if pickupStr<>nil then
        begin
            pickupStr.Assign(pw.PickupStr);
        end;
    finally
        pw.Free;
        sw.Free;
    end;
end;




{ TWChar }

constructor TWChar.Create(var p: PChar);
begin
    if p^ in LeadBytes then
    begin
        ch[0] := p^; Inc(p);
        ch[1] := p^; Inc(p);
    end else
    begin
        ch[0] := p^; Inc(p);
        ch[1] := #0;
    end;
end;

function TWChar.GetAsString: string;
begin
    if ch[1] = #0 then
        Result := ch[0]
    else
        Result := ch[0] + ch[1];
end;


function TWChar.IsMatch(p: TWString): Boolean;
var
    c: TWSeq;
begin
    Result := False;

    c := p.Next ;
    if c=nil then Exit;

    if (c.GetAsString) = GetAsString then
    begin
        Result := True;
    end;
end;

{ TWString }

procedure TWString.Clear;
var
    i: Integer;
begin
    for i:=0 to High(FStr) do
        FStr[i].Free;
    FStr := nil;

    FIndex := 0;
    PickupStr.Clear;

end;

constructor TWString.Create;
begin
    FStr := nil;
    FIndex := 0;
    PickupStr := TStringList.Create;
    PickupEnabled := True;
    PickupRange.fTo := -1;
end;

constructor TWString.Create(str: string);
begin
    Create;
    SetString(str);
end;

destructor TWString.Destroy;
begin
    inherited;
    Clear;
    FStr := nil;
    PickupStr.Free;
end;

function TWString.EqualStr(s: TWString): Boolean;
begin
    if GetString = s.GetString then
        Result := True
    else
        Result := False;
end;

procedure TWString.First;
begin
    FIndex := 0;
end;

function TWString.GetArray(Index: Integer): TWSeq;
begin
    if Index > High(FStr) then
    begin
        Result := nil;
        Exit;
    end;
    Result := FStr[Index];
end;

function TWString.GetLength: Integer;
begin
    Result := High(FStr)+1;
end;

function TWString.GetString: string;
var
    i: Integer;
begin
    Result := '';
    for i:=0 to High(FStr) do
    begin
        Result := Result + FStr[i].GetAsString;
    end;
end;


function TWString.Match(s: TWString): Boolean;
begin
    First ;
    s.First ;
    PickupStr.Clear;

    Result := subMatch(s);
end;

function TWString.MatchNext(s: TWString): Boolean;
begin
    PickupStr.Clear;
    Result := subMatch(s);
end;

function TWString.Mid(Index, Count: Integer): string;
var
    i,toIndex, len: Integer;
    w: TWSeq;
begin
    Result := '';
    len := GetLength ;
    Dec(Index);
    if (Index > len)or(Index<0) then Exit;

    toIndex := Index + Count -1;
    if toIndex > (len-1) then toIndex := len-1;

    for i:=Index to toIndex do
    begin
        w := AsArray[i];
        if w<>nil then Result := Result + w.GetAsString;
    end;
end;

function TWString.Next: TWSeq;
begin
    Result := GetArray(FIndex);
    Inc(FIndex);
end;

procedure TWString.Prev;
begin
    Dec(FIndex);
    if FIndex<0 then FIndex := 0;
end;

procedure TWString.SetString(s: string);
var
  p,ps: PChar;
  idx: Integer;
  ss: string;
begin
    if FStr <> nil then Clear;
    SetLength(FStr, Length(s));// �K���Ȓ�����\�ߊm��

    idx := 0;
    p := PChar(s);
    while p^ <> #0 do
    begin
        if p^ in LeadBytes then
        begin
            FStr[idx] := TWChar.Create(p) ;
        end else
        begin
            case p^ of
                '?':
                    begin
                        FStr[idx] := TWQuestion.Create;
                        Inc(p);
                    end;
                '*':
                    begin
                        FStr[idx] := TWAsterisk.Create ;
                        Inc(p);
                    end;
                '#':
                    begin
                        FStr[idx] := TWNumber.Create ;
                        Inc(p);
                    end;
                '[':
                    begin
                        FStr[idx] := TWKakko.Create(p);
                    end;
                '\':
                    begin
                        Inc(p); // skip '\'
                        if p^ = 'n' then
                        begin
                            Inc(p);
                            ss := #13#10; ps := PChar(ss);
                            FStr[idx] := TWChar.Create(ps);
                            FStr[idx].parent := Self; Inc(idx);
                            FStr[idx] := TWChar.Create(ps);
                        end else
                        if p^ = 't' then
                        begin
                            Inc(p);
                            ss := #9; ps := PChar(ss);
                            FStr[idx] := TWChar.Create(ps);
                        end else
                            FStr[idx] := TWChar.Create(p);
                    end;
                '(':
                    begin
                        FStr[idx] := TWPickupFrom.Create;
                        Inc(p);
                    end;
                ')':
                    begin
                        FStr[idx] := TWPickupTo.Create;
                        Inc(p);
                    end;
                else
                    begin
                        FStr[idx] := TWChar.Create(p);
                    end;
            end;//of case
        end;
        FStr[idx].parent := Self;
        Inc(idx);
    end;
    SetLength(FStr, idx);//�؂肻�낦��
end;

function TWString.subMatch(s: TWString): Boolean;
var
    c: TWSeq ;
begin
    Result := False;
    while True do
    begin
        // �`�F�b�N����P������ c �ɓ���
        c := Next ;
        if c=nil then Break;

        // �}�b�`���Ȃ���΁A������
        if c.IsMatch(s) = False then Exit;
    end;
    Result := True;
end;

{ TWKakko }

constructor TWKakko.Create(var p: PChar);

    procedure getSelectList;
    var
        s: string; ps: PChar; i,j,m,len, mlen: Integer;
    begin
        SelectList := TStringList.Create ;

        s := StrUnit.GetTokenChars([']'], p);
        ps := PChar(s);
        while ps^ <> #0 do
        begin
            SelectList.Add(
                StrUnit.GetTokenChars(['|'], ps)
            );
        end;
        //�������Ń\�[�g
        for i:=0 to SelectList.Count -1 do
        begin
            m := i; mlen := 999;
            for j:=i+1 to SelectList.Count -1 do
            begin
                len := Length(SelectList.Strings[j]);
                if mlen > len then
                begin
                    m := j;
                    mlen := len;
                end;
            end;
            SelectList.Move(m, 0);
        end;
    end;

    procedure setRange;
    var
        pr: PWRange;
        cFrom, cTo: Integer;
    begin
        Inc(p); // skip '['

        if p^ = '!' then // �ے蕶���H
        begin
            NegativeMode := True;
            Inc(p);
        end else begin
            NegativeMode := False;
        end;

        RepeatMode := rmOff;
        if p^ = '*' then // 0��ȏ�̌J��Ԃ����[�h��?
        begin
            RepeatMode := rmAsterisk;
            Inc(p);
        end else
        if p^ = '+' then // 1��ȏ�̌J��Ԃ����[�h��?
        begin
            RepeatMode := rmPlus;
            Inc(p);
        end else
        if p^ = '=' then
        begin
            RepeatMode := rmEqual ;
            Inc(p);
            getSelectList;
            Exit;
        end;

        while not(p^ in [#0, ']']) do
        begin
            cFrom := Ord(p^);
            if p^ in LeadBytes then//�Q�o�C�g�`�F�b�N
            begin
                Inc(p);
                cFrom := (cFrom shl 8) + Ord(p^);
                Inc(p);
            end else
            begin
                Inc(p);
            end;
            if (Chr(cFrom) <> '\') And (p^ = '-') then
            begin
                Inc(p); // skip '-'
                cTo := Ord(p^);
                if p^ in LeadBytes then
                begin
                    Inc(p);
                    cTo := (cTo shl 8) + Ord(p^);
                    Inc(p);
                end else begin
                    Inc(p);
                end;
            end else begin
                if Chr(cFrom) = '\' then
                begin
                    case p^ of
                        't':
                            begin
                                cFrom := 9;
                                cTo := cFrom;
                                Inc(p);
                            end;
                        'n':
                            begin
                                cFrom := 10;
                                cTo   := 13;
                                Inc(p);
                            end;
                        '\':
                            begin
                                cFrom := Ord('\');
                                cTo   := cFrom;
                                Inc(p);
                            end;
                        else begin
                            cFrom := Ord(p^);
                            cTo   := cFrom;
                            Inc(p);
                            //raise Exception.Create('���C���h�J�[�h��[ ]����\�L�����g���Ƃ��́A\t,\n����������Ă��܂���B');
                        end;
                    end;
                end else
                    cTo := cFrom; // �͈͂Ȃ�
            end;
            New(pr);
            //from < to �ɑ�����
            if cFrom < cTo then
            begin
                pr^.fFrom := cFrom;
                pr^.fTo := cTo;
            end else begin
                pr^.fFrom := cTo;
                pr^.fTo := cFrom;
            end;
            RangeList.Add(pr);
        end;//of while
        if p^ = ']' then Inc(p);
    end;

begin
    SelectList := nil;
    RangeList := TList.Create;
    RepeatMode := rmOff;
    NegativeMode := False;

    setRange;
end;

destructor TWKakko.Destroy;
var
    i: Integer;
    pr: PWRange;
begin
    inherited;
    //
    for i:=0 to RangeList.Count-1 do
    begin
        pr := RangeList.Items[i];
        if pr<>nil then Dispose(pr);
    end;
    RangeList.Free;
    if SelectList <> nil then SelectList.Free;
end;

function TWKakko.GetAsString: string;
begin
    Result := '[...]';// dummy string
end;

function TWKakko.IsMatch(p: TWString): Boolean;
var
    c: TWSeq;

    function subIsMatch: Boolean;
    var
        s: string;
        i, code: Integer;
        pr: PWRange ;
    begin
        Result := False;

        c := p.Next ;
        if c=nil then Exit;
        s := c.GetAsString ; // ��r�Ώە���
        if s='' then Exit;

        code := Asc(s);
        for i:=0 to RangeList.Count -1 do
        begin
            pr := RangeList.Items[i];
            if (pr^.fFrom <= code) and (code <= pr^.fTo) then
            begin
                Result := True;
                Break;
            end;
        end;
        if Result = False then p.Prev ; // �}�b�`���Ȃ�������Ώ���߂�

        if NegativeMode then Result := not Result;
    end;

    function subRepMode: Boolean;
    var
        c, cp: TWSeq;
        idx: Integer;
    begin
        Result := False;

        idx := parent.Index;
        c := parent.Next;
        if c<>nil then
        begin
            if (c.ClassType = TWPickupFrom)or(c.ClassType = TWPickupTo) then c:=parent.Next ;
            if c<>nil then
                if c.ClassType <> TWChar then
                begin
                    raise Exception.Create('���C���h�J�[�h[*...]�ɑ����ă��C���h�J�[�h���������Ƃ͏o���܂���B');
                end;
        end;
        parent.FIndex := idx;
        while True do
        begin
            cp := p.Next; p.Prev ;
            if cp=nil then Break;
            if c<>nil then if cp.GetAsString = c.GetAsString then Break;
            if not subIsMatch then Break;
            Result := True;
        end;
    end;

    function subSelect: Boolean;
    var
        i,idx,len: Integer;
        s1,s2: string;
    begin
        Result := False;
        idx := p.Index + 1;
        for i:=0 to SelectList.Count -1 do
        begin
            s1 := SelectList.Strings[i];
            len := JLength(s1);
            s2 := p.Mid(idx, len);
            if s1 = s2 then
            begin
                Inc(p.FIndex, len);
                Result := True;
                Break;
            end;
        end;
    end;

begin
    Result := False;
    case RepeatMode of
        rmOff: Result := subIsMatch;
        rmAsterisk:
            begin
                subRepMode;
                Result := True; //��������TRUE
            end;
        rmPlus:
            begin
                Result := subRepMode;
            end;
        rmEqual:
            begin
                Result := subSelect;
            end;
    end;
end;

{ TWQuestion }

function TWQuestion.GetAsString: string;
begin
    Result := '?';
end;

function TWQuestion.IsMatch(p: TWString): Boolean;
begin
    p.Next ; // ���ł��P��������
    Result := True;
end;

{ TWAsterisk }

function TWAsterisk.GetAsString: string;
begin
    Result := '*';
end;

function TWAsterisk.IsMatch(p: TWString): Boolean;
var
    patIndex, sIndex: Integer;
    IsPickupShift: Boolean;
    c: TWSeq;
begin
    Result := False;

    patIndex := parent.FIndex ;
    sIndex   := p.FIndex ;

    if (patIndex = parent.GetLength) then // �Ōオ "*"
    begin
        p.FIndex := p.GetLength ;
        Result := True;
        Exit;
    end else
    if(patIndex = parent.GetLength-1)
        and(parent.FStr[patIndex].ClassType = TWPickupTo)then // �Ōオ "*)"
    begin
        p.FIndex := p.GetLength ;
        parent.FIndex := parent.GetLength ;
        Result := True;
        TWPickupTo(parent.FStr[patIndex]).IsMatch(p);
        Exit;
    end;

    IsPickupShift := False;
    c := parent.Next ;
    if c<>nil then
    begin
        if c.ClassNameIs('TWPickupFrom') then IsPickupShift := True;
    end;
    parent.PickupEnabled := False;

    while True do
    begin
        parent.FIndex := patIndex;
        p.FIndex := sIndex;
        Result := parent.subMatch(p);
        if Result then
        begin
            parent.FIndex := patIndex;
            p.FIndex := sIndex;
            Break;
        end;
        if IsPickupShift then
        begin
            parent.PickupRange.fFrom := sIndex;
        end;
        Inc(sIndex);
        if p.GetLength < sIndex then Break;
    end;

    parent.PickupEnabled := True;
end;

{ TWNumber }

function TWNumber.GetAsString: string;
begin
    Result := '#';
end;

function TWNumber.IsMatch(p: TWString): Boolean;
var
    c: TWSeq;
    s: string;
begin
    Result := False;

    c := p.Next ;// 1��������
    if c=nil then Exit;

    s := c.GetAsString;
    if s='' then Exit;

    if s[1] in ['0'..'9'] then Result := True;
end;


{ TWPickupFrom }

function TWPickupFrom.GetAsString: string;
begin
    Result := '(';
end;

function TWPickupFrom.IsMatch(p: TWString): Boolean;
begin
    parent.PickupRange.fFrom := p.FIndex ; //�I������Ă���͈͂��L������
    Result := True;
end;

{ TWPickupTo }

function TWPickupTo.GetAsString: string;
begin
    Result := ')';
end;

function TWPickupTo.IsMatch(p: TWString): Boolean;
var
    i1,i2: Integer;
begin
    Result := True;
    if parent.PickupEnabled = False then Exit;

    i1 := parent.PickupRange.fFrom ;
    i2 := p.Index ;
    if parent.PickupRange.fTo >= i2 then Exit; //���Ƀs�b�N�A�b�v�ς݂Ȃ甲����
    parent.PickupRange.fTo := i2;

    parent.PickupStr.Add(
        p.Mid(i1+1, i2-i1)
    );
end;

end.
