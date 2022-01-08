unit unit_eml;

interface
uses
  SysUtils, Classes, Windows, WinSock, WSockUtils, CommCtrl;

type
  TEmlHeader = class; // �O���錾

  // EML�𐶐�����N���X
  // MultiPart�Ή� (EML �̒��� EML������q��ɔz�u�\)
  TEmlHeaderRec = class
  private
    FName: string;
    FValue: string;
    FModify: Boolean;
    procedure getSubKeys;
    procedure SetName(const Value: string);
    procedure SetValue(const Value: string); // ���
  public
    subkeys: TEmlHeader;
    constructor Create;
    destructor Destroy; override;
    function getSubValue(key: string): string;
    function GetAsEml: string;
    property Name: string read Fname write SetName;
    property Value: string read Fvalue write SetValue;
  end;

  // (�g����)
  // TEmlHeader.Items['name'] := value;
  TEmlHeader = class
  private
    list: TList;
    function GetItem(key: string): string;
    procedure SetItem(key: string; const Value: string);
    function GetAsText: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; virtual;
    procedure Delete(key: string); virtual;
    function Add(name, value: string): Integer;
    function FindPtr(key: string): TEmlHeaderRec;
    function FindIndex(key: string): Integer;
    function Get(Index: Integer): TEmlHeaderRec;
    procedure DeleteI(Index: Integer);
    property Items[key:string]: string read GetItem write SetItem; default;
    function GetSub(key: string; subkey: string): string;
    function GetDecodeValue(key: string): string;
    function GetDateTime(key: string): TDateTime;
    function Count: Integer;
    property Text:string read GetAsText;
  end;

  TEmlType = (typeMixed, typeText, typeHtml, typeApplication, typeImage);
  TEml = class
  private
    list: TList;
    FParent: TEml;
    procedure BodySaveAsText(fname: string);
    function GetBodyAsSJIS: string;
    procedure ReadHeaderBody(Lines: TStringList); // EML�̉��
  public
    EmlType: TEmlType;
    Header: TEmlHeader;
    Body: TStringList;
    Boundary: string;
    constructor Create(Parent: TEml);
    destructor Destroy; override;
    // �}���`�p�[�g(�ǂ�)
    function GetParts(Index: Integer): TEml;
    function GetPartsCount: Integer;
    function GetTextBody: string; // �e�L�X�g�Ƃ��Ď擾�ł���p�[�c�𓾂�
    function GetAttachFilename: string;
    function GetPartTypeList: string;
    procedure BodySaveAsAttachment(fname: string);
    // �}���`�p�[�g(����)
    procedure Clear; virtual;
    procedure Delete(i: Integer);
    procedure Move(Index, ToIndex: Integer);
    function CreateBoundary: string;
    // �}���`�p�[�g�i�����j
    function Add(eml: TEml): Integer;
    function AddAttachmentFile(fname: string): Integer; // �Y�t�t�@�C��������
    function AddTextPart(text: string): Integer; // �e�L�X�g�{��������
    function AddHtmlPart(html: string): Integer; // HTML���[��������
    // EML�̓ǂݍ��ݏ���
    procedure LoadFromFile(fname: string);
    procedure BodyDecodeAndSave(fname: string);
    // EML�̏������ݏ���
    procedure SaveToFile(fname: string);
    function GetAsEml: TStringList;
    //--------------------
    // �Ȉ՗��p
    procedure SetEmlEasy(from, rcptto, subject, body, files, html, cc, addHead: string);
    property Parent: TEml read FParent;
  end;

function GetMailDate(Date: TDateTime): string;
function MailDate2DateTime(MailDate: string): TDateTime;

procedure StrWriteFile(fname: string; txt: string);
function StrReadFile(fname: string): string;
function CheckDot(s: TStringList): TStringList;
function ExtractMailAddress(s: string; hasTag: Boolean = True): string;
function CreateMessageID(from: string): string;


implementation

uses unit_string, jconvert, jconvertex, DateUtils,
  md5, nadesiko_version;

var
  FEmlId: Integer = 0;

const
  E_MONTH: array [1..12] of string = (
  'Jan' , 'Feb' , 'Mar' , 'Apr' , 'May' , 'Jun' ,
  'Jul' , 'Aug' , 'Sep' , 'Oct' , 'Nov' , 'Dec');
  E_WEEK: array [1..7] of string = (
  'Sun','Mon','Tue','Wed','Thu','Fri','Sat'
  );
  E_WEEK2: array [1..7] of string = (
  'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'
  );
{
(1) Sun, 06 Nov 1994 08:49:37 GMT
(2) Sunday, 06-Nov-94 08:49:37 GMT
(3) Sun Nov  6 08:49:37 1994
(4) 5 Jun 2005 08:08:08  ���j���ȗ��^
---
Fri, 17 Dec 2004 18:25:05 +0900 (JST)
Fri, 10 Dec 2004 19:20:12 +0900
Thu, 28 Jul 2005 10:00:00 +0900 (JST)

}
function MailDate2DateTime(MailDate: string): TDateTime;
var
  yy,mm,dd,hh,nn,ss: WORD;
  s,week: string;

  function getMonth(s: string): Integer;
  var i : Integer;
  begin
    Result := -1;
    for i := Low(E_MONTH) to High(E_MONTH) do
    begin
      if UpperCase(s) = UpperCase(E_MONTH[i]) then
      begin
        Result := i; Break;
      end;
    end;
    if Result < 0 then
    begin
      Result := StrToIntDef(s, -1);
    end;
  end;

  function isWeek(s: string): Boolean;
  var i : Integer;
  begin
    Result := False;
    s := Trim(UpperCase(s));
    for i := 1 to 7 do
    begin
      if s = UpperCase(E_WEEK[i]) then
      begin
        Result := True; Exit;
      end;
      if s = UpperCase(E_WEEK2[i]) then
      begin
        Result := True; Exit;
      end;
    end;
  end;

begin
  // �j����؂�
  if Pos(',', MailDate) = 0 then
  begin // (3) �̃p�^�[��
    week := getToken_s(MailDate, ' ');
  end else
  begin
    week := getToken_s(MailDate, ',');
  end;
  // �T�����Ȃ��ꍇ���ǂ߂�悤��
  if not isWeek(week) then MailDate := week + ' ' + MailDate;

  MailDate := Trim(JReplace_(MailDate, '-', ' '));
  // ���t
  s := getChars_s(MailDate, ['0'..'9']);
  if s <> '' then
  begin
    // ���t
    dd := StrToInt(s);
    MailDate := Trim(MailDate);
    s  := Trim(getToken_s(MailDate, ' '));
    // ��
    mm := getMonth(s);
  end else
  begin
    // ��
    s  := Trim(getToken_s(MailDate, ' '));
    mm := getMonth(s);
    // ���t
    s  := Trim(getToken_s(MailDate, ' '));
    dd := getMonth(s);
  end;
  // �N
  s  := Trim(getToken_s(MailDate, ' '));
  yy := getMonth(s);
  if yy < 1900 then Inc(yy, 2000); // 2000�N
  // ����
  MailDate := Trim(JReplace_(MailDate, ':', ' '));
  // ��
  s  := Trim(getToken_s(MailDate, ' '));
  hh := getMonth(s);
  // ��
  s  := Trim(getToken_s(MailDate, ' '));
  nn := getMonth(s);
  // �b
  s  := Trim(getToken_s(MailDate, ' '));
  ss := getMonth(s);
  //TDateTime: ���� 1899 �N 12 �� 30 ������̌o�ߓ���
  if(yy > 1900)and(mm >= 1)and(dd >= 1)and{(hh >= 0)and(nn >= 0)and(ss >= 0)and}
    (mm <= 12)and(dd <= 31)and(hh <= 24)and(nn <= 59)and(ss <= 59) then
  begin
    try
      Result := EncodeDateTime(yy, mm, dd, hh, nn, ss, 0);
    except
      Result := 0;
    end;
  end else
  begin
    Result := 0;
  end;
end;

function GetMailDate(Date: TDateTime): string;
var
  week: Integer;
  yy,mm,dd, hh,nn,ss, msec: WORD;
begin
  week := DayOfWeek(Date);
  DecodeDate(Date, yy,mm,dd);
  DecodeTime(Date, hh,nn,ss, msec);
  Result := Format('%s, %0.2d %s %d %d:%d:%d +0900',
    [E_WEEK[week], dd, E_MONTH[mm], yy, hh, nn, ss ]);
end;

procedure StrWriteFile(fname: string; txt: string);
var
  f: TFileStream;
begin
  f := TFileStream.Create(fname, fmCreate);
  try
    if txt = '' then Exit;
    f.Write(txt[1], Length(txt));
  finally
    f.Free;
  end;
end;

function StrReadFile(fname: string): string;
var
  f: TFileStream;
begin
  f := TFileStream.Create(fname, fmOpenRead);
  try
    if f.Size > 0 then
    begin
      SetLength(Result, f.Size);
      f.Read(Result[1], f.Size);
    end;
  finally
    f.Free;
  end;
end;

function CheckDot(s: TStringList): TStringList;
var
  i: Integer;
begin
  for i := 0 to s.Count - 1 do
  begin
    if s.Strings[i] = '.' then
    begin
      s.Strings[i] := '..';
    end;
  end;
  Result := s;
end;

function ExtractMailAddress(s: string; hasTag: Boolean): string;
var
  i: Integer;
  name, mail: string;
begin
  s := Trim(s);
  // "xxxx" <aaa@xxx.jp> �� "xxxx"���폜
  if Copy(s,1,1) = '"' then
  begin
    System.Delete(s,1,1); //
    i := Pos('"', s);
    name := Copy(s,1,i-1);
    System.Delete(s,1,i);
    mail := s;
  end;
  // <xxx@xxx.jp>��<>���폜
  i := JPos('<',s);
  if i > 0 then
  begin
    //name := Copy(s,1,i-1);
    //mail := Copy(s,i,Length(s));
    getToken_s(s, '<');
    mail := getToken_s(s, '>');
  end else
  begin
    name := '';
    mail := s;
    mail := getToken_s(mail, ',');
    mail := getToken_s(mail, #13);
  end;
  // mail
  mail := Trim(mail);
  if hasTag and (mail <> '') then mail := '<' + mail + '>';
  Result := mail;
end;

{ TEmlHeader }

function TEmlHeader.Add(name, value: string): Integer;
var
  p: TEmlHeaderRec;
begin
  p := TEmlHeaderRec.Create;
  p.name := name;
  p.value := value;
  Result := list.Add(p);
end;

procedure TEmlHeader.Clear;
var
  i: Integer;
  p: TEmlHeaderRec;
begin
  for i := 0 to list.Count - 1 do
  begin
    p := list.Items[i];
    FreeAndNil(p);
  end;
  list.Clear;
end;

function TEmlHeader.Count: Integer;
begin
  Result := list.Count;
end;

constructor TEmlHeader.Create;
begin
  list := TList.Create;
end;

procedure TEmlHeader.Delete(key: string);
var
  i: Integer;
  p: TEmlHeaderRec;
begin
  i := FindIndex(key);
  p := list.Items[i];
  FreeAndNil(p);
  list.Delete(i);
end;

procedure TEmlHeader.DeleteI(Index: Integer);
var
  p: TEmlHeaderRec;
begin
  p := list.Items[Index];
  FreeAndNil(p);
  list.Delete(Index);
end;

destructor TEmlHeader.Destroy;
begin
  Clear;
  FreeAndNil(list);
  inherited;
end;

function TEmlHeader.FindIndex(key: string): Integer;
var
  i: Integer;
  p: TEmlHeaderRec;
begin
  Result := -1;

  key := UpperCase(key);

  for i := 0 to list.Count - 1 do
  begin
    p := list.Items[i];
    if UpperCase(p.name) = key then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TEmlHeader.FindPtr(key: string): TEmlHeaderRec;
var
  i: Integer;
begin
  i := FindIndex(key);
  if i >= 0 then
  begin
    Result := list[i];
  end else
  begin
    Result := nil;
  end;
end;

function TEmlHeader.Get(Index: Integer): TEmlHeaderRec;
begin
  Result := list.Items[Index];
end;

function TEmlHeader.GetDateTime(key: string): TDateTime;
var
  s: string;
begin
  s := Items[key];
  Result := MailDate2DateTime(s);
end;

function TEmlHeader.GetDecodeValue(key: string): string;
begin
  Result := Items[key];
  Result := DecodeHeaderStringMultiLine(Result);
end;

function TEmlHeader.GetItem(key: string): string;
var
  p: TEmlHeaderRec;
begin
  p := FindPtr(key);
  if p = nil then
  begin
    Result := '';
  end else
  begin
    Result := p.value;
  end;
end;

function TEmlHeader.GetSub(key, subkey: string): string;
var
  p: TEmlHeaderRec;
begin
  Result := '';
  p := FindPtr(key);
  if p <> nil then
  begin
    Result := p.getSubValue(subkey);
  end;
end;

procedure TEmlHeader.SetItem(key: string; const Value: string);
var
  p: TEmlHeaderRec;
begin
  p := FindPtr(key);
  if p = nil then
  begin
    p := TEmlHeaderRec.Create;
    p.name := key;
    list.Add(p);
  end;
  p.value := Value;
end;

function TEmlHeader.GetAsText: string;
var
  i: Integer;
  e: TEmlHeaderRec;
begin
  Result := '';
  for i := 0 to Count - 1 do
  begin
    e := Get(i);
    Result := Result + e.GetAsEml + #13#10;
  end;
end;

{ TEml }

function TEml.Add(eml: TEml): Integer;
begin
  eml.FParent := Self;
  Result := list.Add(eml);
end;

function TEml.AddAttachmentFile(fname: string): Integer;
var
  eml: TEml;
  s, ext, ctype, name: string;
begin
  try
    s := StrReadFile(fname);
  except
    raise Exception.Create('�Y�t�t�@�C��"' + fname + '"���J���܂���B');
  end;

  //-- MIME Content-Type �̐ݒ�
  ext := LowerCase(ExtractFileExt(fname));
  if (ext = '.jpg')or(ext = '.jpeg') then ctype := 'image/jpeg' else
  if (ext = '.png') then ctype := 'image/jpeg' else
  if (ext = '.html')or(ext = '.htm') then ctype := 'text/html' else
  if (ext = '.gif') then ctype := 'image/jpeg' else
  begin
    ctype := 'application/octet-stream';
  end;
  //--
  name := ExtractFileName(fname);
  name := Trim(CreateHeaderStringEx(name));
  //
  eml := TEml.Create(Self);
  eml.Body.Text := EncodeBase64R(s,#13#10);
  eml.Header.Items['Content-Type'] := ctype + '; name="' + name + '"';
  eml.Header.Items['Content-Disposition'] := 'attachment; filename="'+name+'"';
  eml.Header.Items['Content-Transfer-Encoding'] := 'base64';
  //
  Result := Self.Add(eml);
end;

function TEml.AddHtmlPart(html: string): Integer;
var
  eml: TEml;
begin
  //-- MIME Content-Type �̐ݒ�
  eml := TEml.Create(Self);
  eml.Body.Text := sjis2jis83(html);
  eml.Header.Items['Content-Type'] := 'text/html; charset="iso-2022-jp"';
  eml.Header.Items['Content-Transfer-Encoding'] := '7bit';
  Result := Self.Add(eml);
end;

function TEml.AddTextPart(text: string): Integer;
var
  eml: TEml;
begin
  //-- MIME Content-Type �̐ݒ�
  eml := TEml.Create(Self);
  eml.Body.Text := sjis2jis83(text);
  eml.Header.Items['Content-Type'] := 'text/plain; charset="iso-2022-jp"';
  eml.Header.Items['Content-Transfer-Encoding'] := '7bit';
  Result := Self.Add(eml);
end;

procedure TEml.BodyDecodeAndSave(fname: string);
begin
  // Content-Type �𒲂ׂ�
  case EmlType of
    typeMixed: raise Exception.Create('mixed�^�C�v�̂��ߕۑ��ł��܂���B');
    typeText :       BodySaveAsText(fname);
    typeApplication: BodySaveAsAttachment(fname);
    typeImage:       BodySaveAsAttachment(fname);
    else       raise Exception.Create('�{�̂���̂��ߕۑ��ł��܂���B');
  end;
end;

function CheckFilename(fname: string): string;
const
  fchars: TSysCharSet = ['0'..'9','a'..'z','A'..'Z','!','#','$','%','(',')',
                    '-','=','~','@','.','_', '\', ' ',':','+'];
var
  i: Integer;
begin
  i := 1;
  while i <= Length(fname) do
  begin
    begin
      if Ord(fname[i]) > $7F then
      begin
        Result := Result + fname[i]; Inc(i);
        Result := Result + fname[i]; Inc(i);
        continue;
      end else
      if CharInSet(fname[i], fchars) then Result := Result + fname[i]
                                     else Result := Result + '_';
      Inc(i);

    end;
  end;
end;

procedure TEml.BodySaveAsAttachment(fname: string);
var
  ctype : string;
  enc   : string;
begin
  // �ۑ�����...GetAttachFilename()..�œ�����

  //---------------------------
  // �{�̂̃f�R�[�h
  //---------------------------
  // �G���R�[�h�^�C�v�𓾂�
  ctype := LowerCase(Header.GetSub('Content-Type',''));
  ctype := getToken_s(ctype, '/');
  enc := LowerCase(Header.Items['Content-Transfer-Encoding']);

  // �e�L�X�g?
  if ctype = 'text' then
  begin
    BodySaveAsText(fname);
    Exit;
  end;

  fname := CheckFilename(fname);

  // �G���R�[�h
  if enc = 'base64' then
  begin
    StrWriteFile(fname, DecodeBase64(Body.Text));
  end else
  if enc = 'quoted-printable' then
  begin
    StrWriteFile(fname, DecodeQuotedPrintable(Body.Text));
  end else
  if ctype = 'message' then
  begin
    // message/rfc822���Amessage/partial�B�Ƃ肠�������ŕۑ��B
    StrWriteFile(fname, Body.Text);
  end else
  begin
    raise Exception.Create('����`�̃G���R�[�h����');
  end;
end;

procedure TEml.BodySaveAsText(fname: string);
begin
  fname := CheckFilename(fname);
  StrWriteFile(fname, GetBodyAsSJIS);
end;

procedure TEml.Clear;
var
  i: Integer;
  p: TEml;
begin
  for i := 0 to list.Count - 1 do
  begin
    p := list.Items[i];
    FreeAndNil(p);
  end;
  list.Clear;
  //
  header.Clear;
end;

constructor TEml.Create(Parent: TEml);
begin
  list     := TList.Create;
  header   := TEmlHeader.Create;
  Body     := TStringList.Create;
  Boundary := '';
  EmlType  := typeText;
  FParent  := Parent;
end;

function TEml.CreateBoundary: string;
var
  s: string;
  yy,mm,dd,hh,nn,ss, msec: WORD;
begin
  DecodeDateTime(Now,yy,mm,dd,hh,nn,ss,msec);
  // OE����Boundary���g��
  s := Format('%.4d_%.4x_%.2x%.2d%.2d.%.2d%.2d%.2d%.3d',
    [
      FEmlID, ($FFFF and GetCurrentThreadId),
      ($FF and yy),mm,dd,
      hh,nn,ss,msec
    ]);
  Result := '----=_NextPart_' + s;
  // Boundary �� Inc ����
  Inc(FEmlID);
end;

procedure TEml.Delete(i: Integer);
var
  p: TEml;
begin
  p := list.Items[i];
  FreeAndNil(p);
  list.Delete(i);
end;

destructor TEml.Destroy;
begin
  Clear;
  FreeAndNil(Body);
  FreeAndNil(list);
  FreeAndNil(header);
  inherited;
end;

function TEml.GetAsEml: TStringList;
var
  i: Integer;
  h: TEmlHeaderRec;
  e: TEml;
  sl: TStringList;
begin
  Result := TStringList.Create;

  // Boundary ���g���ꍇ�Z�b�g
  if list.Count > 0 then
  begin
    Self.EmlType := typeMixed;
    Self.Boundary := CreateBoundary; // �V���� Boundary ���Z�b�g
    Header.Items['MIME-Version'] := '1.0';
    Header.Items['Content-Type'] := 'multipart/mixed; boundary="' +
      Self.Boundary + '"';
  end;

  // �܂��w�b�_���Z�b�g����
  for i := 0 to Header.Count - 1 do
  begin
    h := Header.Get(i);
    Result.Add(h.GetAsEml);
  end;

  Result.Add(''); // HEADER �� BODY �̋��E

  // �{�̂��Z�b�g����
  if Self.EmlType = typeMixed then
  begin
    // EML ����������
    for i := 0 to list.Count - 1 do
    begin
      // Boundary
      Result.Add('--'+Self.Boundary);
      // EML
      e := list.Items[i];
      sl := e.GetAsEml;
      try
        Result.AddStrings(sl);
      finally
        sl.Free;
      end;
    end;
    Result.Add('--'+Self.Boundary + '--'); // �I�[
  end else
  begin
    // ��������
    Result.AddStrings(CheckDot(Body));
  end;

end;

function TEml.GetAttachFilename: string;
var
  filename: string;
begin
  //---------------------------
  // �Y�t�t�@�C���̕ۑ�
  //---------------------------
  // �ۑ����𓾂�
  filename := Header.GetSub('Content-Disposition', 'filename');
  if filename = '' then filename := Header.GetSub('Content-type', 'name');
  // �t�@�C�����̃f�R�[�h
  filename := DecodeHeaderStringMultiLine(filename);
  //filename := CheckFilename(filename);
  Result := filename;
end;

function TEml.GetBodyAsSJIS: string;
var
  chars: string;
  enc: string;
  txt: string;

  procedure iso_2022_jp;
  begin
    // �ł��邾�� SHIFT_JIS ��
    Result := jis2sjis( txt );
  end;

  procedure euc_jp;
  begin
    // �ł��邾�� SHIFT_JIS ��
    Result := euc2sjis( txt );
  end;

  procedure shift_jis;
  begin
    Result := txt;
  end;

  procedure utf_8;
  begin
    Result := Utf8NTosjis( txt );
  end;

  procedure unsupport;
  begin
    Result := ConvertJCode(txt, SJIS_OUT);
    //Result := Body.Text;
  end;

begin
  //----------------------------------------------------------------------------
  // �����R�[�h���m�F
  chars := LowerCase(Header.GetSub('Content-Type', 'Charset'));
  enc   := LowerCase(Header.GetItem('Content-Transfer-Encoding'));
  txt   := Body.Text;

  if enc = 'base64' then txt := DecodeBase64(txt) else
  if enc = 'quoted-printable' then txt := DecodeQuotedPrintable(txt);


  if (chars = 'iso-2022-jp')  then iso_2022_jp      else // JIS
  if (chars = 'euc-jp')       then euc_jp           else
  if (chars = 'shift_jis')    then shift_jis        else
  if (chars = 'utf-8')        then utf_8            else

  if (chars = 'gb2312')       then unsupport        else // CHINESE
  if (chars = 'us-ascii')     then iso_2022_jp      else // ENGLISH
  unsupport
end;

function TEml.GetParts(Index: Integer): TEml;
begin
  Result := list.Items[Index];
end;

function TEml.GetPartsCount: Integer;
begin
  Result := list.Count;
end;

function TEml.GetPartTypeList: string;
var
  i: Integer;
  p: TEml;
  s: string;
begin
  Result := '';
  for i := 0 to list.Count - 1 do
  begin
    p := list.Items[i];
    case p.EmlType of
      typeMixed       : s := '�}���`�p�[�g';
      typeText        : s := '�e�L�X�g';
      typeImage       : s := '�摜';
      typeApplication : s := '�Y�t�t�@�C��';
      else s := '�s��';
    end;
    Result := Result + s + #13#10;
  end;
end;

function TEml.GetTextBody: string;
var
  i: Integer;
  e: TEml;
begin
  Result := '';
  // �������g�� typeText �Ȃ� Body ��Ԃ�
  if self.EmlType = typeText then
  begin
    Result := GetBodyAsSJIS;
    Exit;
  end else
  // �}���`�p�[�g�̏ꍇ�� typeText �̂��̂�Ђ��[���炭�����ĕԂ�
  if self.EmlType = typeMixed then
  for i := 0 to list.Count - 1 do
  begin
    e := list.Items[i];
    Result := Result + e.GetTextBody + #13#10#13#10;
  end;
end;

procedure TEml.LoadFromFile(fname: string);
var
  ss: TStringList;
begin
  Clear;
  ss := TStringList.Create;
  try
    ss.LoadFromFile(fname);
    ReadHeaderBody(ss);
  finally
    ss.Free;
  end;
end;

procedure TEml.Move(Index, ToIndex: Integer);
begin
  list.Move(Index, ToIndex);
end;

procedure TEml.ReadHeaderBody(Lines: TStringList);
var
  i: Integer;
  s, sub, name, value: string;

  procedure ReadMixed;
  var
    j: Integer;
    sl: TStringList;
    e: TEml;
    line: string;
  begin
    Self.Boundary := Trim(Header.GetSub('Content-Type','boundary'));

    // boundary �� '' �ł����Ȃ� ������ '--' ����؂�L���ɂ��邩��
    // if Self.Boundary = '' then raise Exception.Create('�����h�L�������g�ŋ�؂肪��������܂���B');

    if Lines.Count <= i then Exit;
    if Trim(Lines.Strings[i]) = '' then Inc(i);
    if Trim(Lines.Strings[i]) = '--' + Self.Boundary then Inc(i);

    sl := TStringList.Create;

    // ��؂蕶���܂ł𓾂�
    for j := i to Lines.Count - 1 do
    begin
      line := Lines.Strings[j];
      if line = '--'+Self.Boundary then // boundary��؂�
      begin
        if sl.Count > 0 then
        begin
          e := TEml.Create(Self);
          e.ReadHeaderBody(sl);
          Self.Add(e);
          sl.Clear;
        end;
      end else
      if line = '--' + Self.Boundary + '--' then // boundary�I�[
      begin
        Break;
      end else
      begin // boundary �ɂ���؂�ł��I�[�ł��Ȃ��Ƃ��͖{���Ƃ��Ēǉ�
        sl.Add(line);
      end;
    end;
    // �Ō�ɒǉ�
    if sl.Count > 0 then
    begin
      e := TEml.Create(Self);
      e.ReadHeaderBody(sl);
      Self.Add(e);
    end;
    sl.Free;
  end;

  procedure ReadOther;
  var j: Integer;
  begin
    if Lines.Count <= i then Exit;
    if Trim(Lines[i]) = '' then Inc(i);

    Body.Clear;
    for j := i to Lines.Count - 1 do
    begin
      Body.Add(Lines[j]);
    end;
  end;

begin
  // Read HEADER
  i := 0;
  while i < Lines.Count do
  begin
    s := Lines.Strings[i];
    if s = '' then Break; // �w�b�_�I���

    // �w�b�_���ƒl�𓾂�
    name  := getToken_s(s, ':');
    if Copy(s,1,1) = ' ' then System.Delete(s,1,1);
    value := s; // Trim(s); �w�b�_�ɒ���JIS���������ꍇ���邩��
    Inc(i);

    // ����������
    while i < Lines.Count do
    begin
      s := Lines.Strings[i];
      if (s = '')or(not(CharInSet(s[1], [' ',#9]))) then Break;
      value := value + #13#10 + s; // �����Ɏ擾
      Inc(i);
    end;

    // �w�b�_��ǉ�
    Header.Add(name, value);
  end;

  // Contetnt-Type
  s := LowerCase(Header.GetSub('Content-Type', ''));
  sub := getToken_s(s, '/');
  if sub = 'multipart'   then Self.EmlType := typeMixed       else
  if sub = 'application' then Self.EmlType := typeApplication else
  if sub = 'audio'       then Self.EmlType := typeApplication else
  if sub = 'message'     then Self.EmlType := typeApplication else
  if sub = 'image'       then Self.EmlType := typeImage       else
                              Self.EmlType := typeText;
  // Read BODY
  case Self.EmlType of
    typeMixed: readMixed;
    else begin
      readOther;
    end;
  end;

end;

procedure TEml.SaveToFile(fname: string);
var
  s: TStringList;
begin
  // TO FILE
  s := GetAsEml;
  try
    s.SaveToFile(fname);
  finally
    s.Free;
  end;
end;

function CreateMessageID(from: string): string;
const rc: string = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
var
  s, sRnd, user, domain: string;
  i: Integer;
begin
  domain := Trim(ExtractMailAddress(from));
  domain := JReplace(domain, '<','');
  domain := JReplace(domain, '>','');
  user := Trim(getToken_s(domain, '@'));
  // �K���ȃ����_���v�f
  sRnd := '';
  for i := 1 to 4 do sRnd := sRnd + rc[1+Random(Length(rc))];
  // ����
  s := FormatDateTime('yyyymmddhhnnssz',Now) + '.' + // ����
    IntToHex(GetCurrentProcessId,1) + sRnd + '.' +
    UpperCase(user) + '@' + domain;
  //
  Result := '<' + s + '>';
end;

procedure TEml.SetEmlEasy(from, rcptto, subject, body, files, html, cc, addHead: string);
var
  s, sh: TStringList;
  i: Integer;
  key, val: string;
begin
  Clear;
  //--- addHead --- (�n�b�V���`�� key=val\nkey=val... ���p�[�X)
  sh := TStringList.Create;
  sh.Text := addHead;
  for i := 0 to sh.Count - 1 do
  begin
    val := sh.Strings[i];
    key := Trim(getToken_s(val, '='));
    if key = '' then Continue;
    Self.Header[key] := val;
  end;
  sh.Free;
  //------------------------------------------------------
  Self.Header['From']     := CreateHeaderStringMail(from);
  Self.Header['To']       := CreateHeaderStringMail(rcptto);
  Self.Header['Subject']  := Trim(CreateHeaderStringEx(subject));
  Self.Header['Date']     := GetMailDate(Now);
  Self.Header['Content-Type'] := 'text/plain; charset="iso-2022-jp"';
  if Self.Header['Reply-To'] = '' then Self.Header['Reply-To'] := ExtractMailAddress(from);
  if (cc <> '') then Self.Header['Cc'] := CreateHeaderStringMail(cc); // set to CC
  //-- �ǉ��w�b�_�ł��w�肳�ꂻ���ȕ���
  if Self.Header['X-Priority'] = '' then Self.Header['X-Priority'] := '3';
  if Self.Header['X-Mailer'  ] = '' then Self.Header['X-Mailer'  ] := 'Nadesiko ver.' + NADESIKO_VER;
  if Self.Header['Message-Id'] = '' then Self.Header['Message-Id'] := CreateMessageID(from);
  // --- ����
  // mailfrom �ɏ������A�h���X
  if (Self.Header['Return-Path'] = '')or(Self.Header['Return-Path'] = '<>') then Self.Header['Return-Path'] := ExtractMailAddress(from);
  //
  if (files = '')and(html = '') then
  begin
    Self.Body.Text := sjis2jis83(body);
    Exit;
  end;
  // �Y�t�t�@�C��������Ƃ�
  Self.AddTextPart(body);

  // �Y�t�t�@�C���̐���
  s := TStringList.Create;
  s.Text := files;
  for i := 0 to s.Count - 1 do
  begin
    Self.AddAttachmentFile(s.Strings[i]);
  end;
  s.Free;

  // HTML���[���̓Y�t
  if html <> '' then
  begin
    Self.AddHtmlPart(html);
  end;
end;

{ TEmlHeaderRec }

constructor TEmlHeaderRec.Create;
begin
  FName   := '';
  FValue  := '';
  FModify := False;
  subkeys := nil;
end;

destructor TEmlHeaderRec.Destroy;
begin
  FreeAndNil(subkeys);
  inherited;
end;

function TEmlHeaderRec.GetAsEml: string;
begin
  Result := FName + ': ' + Trim(FValue);
end;

procedure TEmlHeaderRec.getSubKeys;
var
  p: PChar;
  s: string;
  mainVal: string;
  subKey: string;
  subVal: string;
  subKeyIndex: Integer;
  subValueExtend: boolean;
  subValueEncode: string;
  subValueLang: string;
  oldSubKey: string;
  oldSubVal: string;

  procedure skipSpace2(var p: PChar);
  begin
    while CharInSet(p^, [#9, ' ', #13, #10]) do Inc(p);
  end;

begin
  FModify := False;
  s := value;
  //
  mainVal := Trim(getToken_s(s, ';'));
  s := Trim(s);
  if s = '' then
  begin // �T�u�L�[�����݂��Ȃ��ꍇ
    FreeAndNil(subkeys);
    Exit;
  end;

  // �T�u�L�[�����
  subkeys := TEmlHeader.Create;
  subkeys.Add('', mainVal);

  oldSubKey:='';
  // �T�u�L�[�̉�͏���
  p := PChar(s);
  skipSpace2(p);
  while p^ <> #0 do
  begin
    subValueExtend := false;
    subKeyIndex := -1;
    // name
    subKey := getChars(p, ['a'..'z','A'..'Z','-','/','_']);
    // *
    if p^ = '*' then
    begin
      // * ���X�L�b�v
      Inc(p);
      if CharInSet(p^, ['0'..'9']) then
      begin
        // �A�Ԃ��X�L�b�v
        subKeyIndex := StrToInt(getChars(p, ['0'..'9']));
        if p^ = '*' then
        begin
          // * ���X�L�b�v
          Inc(p);
          subValueExtend := true;
        end;
      end else
        subValueExtend := true;
    end;

    if (oldSubKey<>'') and ((oldSubKey<>subKey) or (subKeyIndex = -1)) then
    begin
      if subValueEncode<>'' then
      begin
        oldSubVal := '=?'+subValueEncode+'?B?'+EncodeBase64(oldSubVal)+'?=';
      end else
      begin
        oldSubVal := '=?X-UNKNOWN?B?'+EncodeBase64(oldSubVal)+'?=';
      end;
      subkeys.Add(oldSubKey, oldSubVal);
      oldSubKey:='';
    end;

    // =
    skipSpace2(p);
    if p^ = '=' then // =' ���X�L�b�v
      Inc(p)
    else begin // �l�̂Ȃ��T�u�L�[...(���Ă���ꍇ���Ȃ�Ƃ�����j
      subkeys.Add(subkey, '');
      while CharInSet(p^, [';',#13,#10,#9]) do Inc(p);
      Continue;
    end;
    skipSpace2(p);
    // name�̍Ō��'*'���t���Ă����ꍇ�̍ŏ��̒f�Ђ̓G���R�[�h�ƌ��ꂪ����
    if (subKeyIndex=0) or (subKeyIndex=-1) then
    begin
      subValueEncode := '';
      if subValueExtend then
      begin
        subValueEncode := getChars(p, ['0'..'9','a'..'z','A'..'Z','-','/','_']);
        if p^ = #39 then
        begin
          inc(p);
          subValueLang :=  getChars(p, ['0'..'9','a'..'z','A'..'Z','-','/','_']);
          if p^ = #39 then
            inc(p);
        end;
      end;
    end;
    // "value"
    if p^ = '"' then
    begin
      Inc(p);
      subVal := getTokenStr(p, '"'); // ���s�������Ă��l���擾�\
    end else
    begin
      subVal := getTokenChB(p, [';',#13,#10]);
    end;
    // name�̍Ō��'*'���t���Ă����ꍇ�̓G���R�[�h���Ă���
    if subValueExtend then
    begin
      subVal := DecodeQuotedPrintable(jReplace(subVal,'%','='));
    end;
    if p^ = ';' then
    begin
      while CharInSet(p^, [';',' ',#13,#10,#9]) do Inc(p);
    end else
      while CharInSet(p^, [';',#13,#10,#9]) do Inc(p);
    if subKeyIndex = -1 then
      subkeys.Add(subKey, subVal)
    else
    if subKeyIndex = 0 then
    begin
      oldSubKey:=subKey;
      oldSubVal:=subVal;
    end else
      oldSubVal:=oldSubVal+subVal;
  end;

  if oldSubKey<>'' then
  begin
    if subValueEncode<>'' then
    begin
      oldSubVal := '=?'+subValueEncode+'?B?'+EncodeBase64(oldSubVal)+'?=';
    end else
    begin
      oldSubVal := '=?X-UNKNOWN?B?'+EncodeBase64(oldSubVal)+'?=';
    end;
    subkeys.Add(oldSubKey, oldSubVal);
  end;

end;

function TEmlHeaderRec.getSubValue(key: string): string;
begin
  // �T�u�L�[�̉�͂��I����Ă��邩�H
  if FModify then getSubKeys;

  // �T�u�L�[�����݂��Ȃ��ꍇ
  if (key = '')and(subkeys = nil) then
  begin
    Result := value; Exit;
  end;

  // �T�u�L�[���擾
  Result := '';
  if subkeys <> nil then
  begin
    Result := subkeys.Items[key];
  end;
end;


procedure TEmlHeaderRec.SetName(const Value: string);
begin
  FName := Value;
  FModify := True;
end;

procedure TEmlHeaderRec.SetValue(const Value: string);
begin
  FValue := Value;
  FModify := True;
end;


end.
