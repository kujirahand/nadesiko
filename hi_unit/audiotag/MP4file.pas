unit MP4file;
interface

uses
  Windows, SysUtils, Classes, sMediaTag, TypInfo;

type
	TMP4file = class(TsMediaTag)
  private
    FDuration: Double;
    FTrack: Integer;
    FSampleRate: Integer;
    FTime: WideString;
    FAlbum: WideString;
    FArtist: WideString;
    FComment: WideString;
    FGenre: WideString;
    FTitle: WideString;
    FYear: WideString;
    FEncoder: WideString;
    FComposer: WideString;
    FTempo: WideString;
    function parse_container(fs: TFileStream; level, size: Integer): Boolean;
    function parse_atom(fs: TFileStream; level: Integer): Boolean;
    function parse_data(fs: TFileStream; level, size: Integer; id: string): Boolean;
    function parse_mvhd(fs: TFileStream; level, size: Integer): Boolean;
  public
		constructor Create; override;
		destructor Destroy; override;
		function ReadFromFile(const FileName: string): Boolean; override;
		function RemoveFromFile(const FileName: string): Boolean; override;
		function SaveToFile(const FileName: string): Boolean; override;
  published
    property SampleRate: Integer read FSampleRate;       { Sample rate (hz) }
    property Duration: Double read FDuration;          { Duration (seconds) }
    property Title: WideString read FTitle;                    { Song title }
    property Artist: WideString read FArtist;                 { Artist name }
    property Album: WideString read FAlbum;                    { Album name }
    property Track: Integer read FTrack;                     { Track number }
    property Year: WideString read FYear;                            { Year }
    property Genre: WideString read FGenre;                    { Genre name }
    property Comment: WideString read FComment;                   { Comment }
    property Time: WideString read FTime;
    property Tempo: WideString read FTempo;
    property Encoder: WideString read FEncoder;
    property Composer: WideString read FComposer;
	end;

  TMP4AtomHeader = packed record
    case Byte of
    0:(
      size: DWORD; // 4 byte
      id: array [0..3] of Char;
    );
    1:(
      szLo: DWORD;
      szHi: DWORD;
    );
  end;
  TMP4AtomDataHead = packed record
    size: DWORD;
    atom: array [0..3] of Char;
    dtype: DWORD;
    data: DWORD;
  end;

implementation

uses jconvertex, jconvert;

function SwapDWord(a: DWORD): DWORD;
var
  b1, b2, b3, b4: Byte;
begin
  b1 := a and $FF;
  b2 := (a shr  8) and $FF;
  b3 := (a shr 16) and $FF;
  b4 := (a shr 24) and $FF;
  Result := (b1 shl 24) or (b2 shl 16) or (b3 shl 8) or b4;
end;

{ TMP4file }

constructor TMP4file.Create;
begin
  inherited;

end;

destructor TMP4file.Destroy;
begin

  inherited;
end;

function TMP4file.parse_atom(fs: TFileStream; level: Integer): Boolean;
var
  i, size: Integer;
  id, s: string;
  head: TMP4AtomHeader;
begin
  Result := True;

  // read header
  fs.Read(head, sizeof(head));
  size := SwapDWord(head.size);

  // get size
  if size = 1 then
  begin
    // extended size
    if fs.Read(head, sizeof(head)) < sizeof(head) then raise Exception.Create('ヘッダが読めませんでした。');
    size := (SwapDWord(head.szHi) shl 32) + SwapDWord(head.szLo) - 16;
  end else
  begin
    size := size - 8;
  end;

  // check size
  if size <= 0 then Exit;

  // check id
  s := head.id; id := '';
  for i := 1 to Length(s) do
  begin
    if s[i] in ['a'..'z', 'A'..'Z'] then
      id := id + s[i];
  end;
  id := UpperCase(id) + '/';
  if Pos(id, 'AART/AKID/ALB/APID/ATID/ART/CMT/CNID/COVR/CPIL/CPRT/DAY/DISK/GEID/GEN/GNRE/GRP/NAM/PLID/RTNG/TMPO/TOO/TRKN/WRT/') > 0 then
  begin
    System.Delete(id, Length(id), 1);
    parse_data(fs, level, size, id);
    Exit;
  end else
  if Pos(id, 'MDAT/META/MVHD/STSD/') > 0 then // other atoms
  begin
    if id = 'MDAT/' then
    begin
      fs.Seek(size, soCurrent);
    end else
    if id = 'META/' then
    begin
      // META has a version field
      fs.Seek(4, soCurrent); // +4
      parse_container(fs, level, size - 4);
    end else
    if id = 'MVHD/' then
    begin
      parse_mvhd(fs, level, size);
    end else
    begin
      fs.Seek(size, soCurrent);
    end;
    Exit;
  end else
  if Pos(id, 'ILST/MDIA/MINF/MOOV/STBL/TRAK/UDTA/') > 0 then
  begin
    parse_container(fs, level, size);
    Exit;
  end;
  // else ... skip data
  fs.Seek(size, soFromCurrent);
  ;
end;

function TMP4file.parse_container(fs: TFileStream; level,
  size: Integer): Boolean;
var
  endPos: Integer;
begin
  Result := True;
  endPos := fs.Position + size;
  level := level + 1;
  //
  while fs.Position < endPos do
  begin
    if parse_atom(fs, level) = False then Exit;
  end;
end;

function TMP4file.parse_data(fs: TFileStream; level, size: Integer;
  id: string): Boolean;
var
  dat: string;
  head: TMP4AtomDataHead;
  v, v2: Int64;
  checkSize: Int64;
begin
  Result := True;
  if size < 16 then
  begin
    fs.Seek(size, soCurrent); Exit;
  end;
  // data のヘッダを読む
  fs.Read(head, sizeof(head));
  head.size := SwapDWord(head.size);
  checkSize := head.size - sizeof(head); // AtomDataHead
  head.dtype := SwapDWord(head.dtype) and $FF;

  // data 本体を読む
  if checkSize < 0 then Exit;
  SetLength(dat, checkSize);
  fs.Read(dat[1], checkSize); // size check は省略

  // dtype で判別
  case head.dtype of
  0:// 16bit int data
    begin
      if id = 'TRKN' then
      begin
        v2 := 0;
        case checkSize of
          2: v := (Ord(dat[1]) shl 8) + (Ord(dat[2]));
          4: v := (Ord(dat[1]) shl 24) + (Ord(dat[2]) shl 16) + (Ord(dat[3]) shl 8) + (Ord(dat[4]));
          8:
            begin
              v  := (Ord(dat[1]) shl 24) + (Ord(dat[2]) shl 16) + (Ord(dat[3]) shl 8) + (Ord(dat[4]));
              v2 := (Ord(dat[5]) shl 8)  + (Ord(dat[6]));
              // 最後の２バイトはいつも00なんでかしら？
            end;
          else begin
            v := Ord(dat[1]);
          end;
        end;
        ElseProp.Add('TRKN' + '=' + IntToStr(v));
        ElseProp.Add('TrackCount' + '=' + IntToStr(v2));
        FTrack := Integer(v);
      end else
      begin
        case checkSize of
          1: v := Ord(dat[1]);
          2: v := (Ord(dat[1]) shl 8) + (Ord(dat[2]));
          4: v := (Ord(dat[1]) shl 24) + (Ord(dat[2]) shl 16) + (Ord(dat[3]) shl 8) + (Ord(dat[4]));
          else begin
            if CheckSize > 4 then
            begin
              v := (Ord(dat[1]) shl 24) + (Ord(dat[2]) shl 16) + (Ord(dat[3]) shl 8) + (Ord(dat[4]));
            end else
            begin
              v := Ord(dat[1]);
            end;
          end;
        end;
        ElseProp.Add(id + '=' + IntToStr(v));
      end;
    end;
  1:// Char data
    begin
      dat := ConvertJCode(dat, SJIS_OUT); // shift-jisに変換
      ElseProp.Add(id + '=' + dat);
    end;
  21: // ByteData
    begin
      //TypInfo.SetPropValue(Self, id, dat);
      ElseProp.Add(id + '=' + dat);
    end;
  end;
end;

function TMP4file.parse_mvhd(fs: TFileStream; level,
  size: Integer): Boolean;
var
  data: string;
  version: Byte;
  scale, duration, hi, lo: DWORD;
  secs: Extended;
  mm, ss, ms: Integer;
begin
  Result := True;
  if size < 0 then Exit;
  // read data
  SetLength(data, size);
  fs.Read(data[1], size);
  if size < 32 then Exit;
  // read version
  version := Ord(data[1]);
  if version = 0 then
  begin
    Move(data[13], scale, 4);
    Move(data[17], duration, 4);
    scale := SwapDWord(scale);
    duration := SwapDWord(duration);
  end else
  if version = 1 then
  begin
    Move(data[21], scale, 4);
    Move(data[25], hi, 4);
    Move(data[29], lo, 4);
    scale := SwapDWord(scale);
    hi := SwapDWord(hi);
    lo := SwapDWord(lo);
    duration := (hi shl 32) + lo;
  end else
  ;
  // set mvhd
  secs := duration / scale;
  mm := Trunc(secs / 60);
  ss := Trunc(secs - mm * 60);
  ms := Trunc(0.5 + 1000 *(secs - Trunc(secs)));
  //
  ElseProp.Add('SECS=' + IntToStr(Trunc(0.5 + secs)));
  ElseProp.Add('MM=' + IntToStr(mm));
  ElseProp.Add('SS=' + IntToStr(ss));
  ElseProp.Add('MS=' + IntToStr(ms));
  //
  FTime := Format('%02d:%02d',[mm, Trunc(secs - mm*60)]);
  FDuration := secs;
end;

function TMP4file.ReadFromFile(const FileName: string): Boolean;
var
  fs: TFileStream;
  ahead: TMP4AtomHeader;
begin
  Result := False;
  fs := TFileStream.Create(FileName, fmOpenRead);
  try
  try
    // check MP4 TOP header
    fs.Position := 0;
    fs.Read(ahead, sizeof(ahead)); // 8 byte
    if LowerCase(ahead.id) <> 'ftyp' then
    begin
      //raise Exception.Create('MP4形式ではありません！');
      Exit;
    end;
    // read container
    fs.Position := 0;
    parse_container(fs, 0, fs.Size);
    Result := True;
    FFileFormat := 'M4A';
    //-------------------
    FAlbum  := ElseProp.Values['ALB'];
    FArtist := ElseProp.Values['ART'];
    FYear   := ElseProp.Values['DAY'];
    FGenre  := ElseProp.Values['GNRE'];
    if FGenre = '' then FGenre := ElseProp.Values['GEN'];
    FTitle  := ElseProp.Values['NAM'];
    FComment:= ElseProp.Values['CMT'];
    FTrack  := StrToIntDef(ElseProp.Values['TRKN'], 0);
    FTempo  := ElseProp.Values['TMPO'];
    FEncoder := ElseProp.Values['TOO'];
    FComposer := ElseProp.Values['WRT'];
    //FSampleRate := Trunc(0.5 + StrToIntDef(ElseProp.Values['SIZE'],0) / (StrToIntDef(ElseProp.Values['MM'],0)*60+StrToIntDef(ElseProp.Values['SS'],0)+StrToIntDef(ElseProp.Values['MS'],0)/1000)*128);
  except
  end;
  finally
    fs.Free;
  end;
end;

function TMP4file.RemoveFromFile(const FileName: string): Boolean;
begin
  Result := False;
end;

function TMP4file.SaveToFile(const FileName: string): Boolean;
begin
  Result := False;
end;

end.
