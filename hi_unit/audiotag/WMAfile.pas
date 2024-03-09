{ *************************************************************************** }
{                                                                             }
{ Audio Tools Library (Freeware)                                              }
{ Class TWMAfile - for extracting information from WMA file header            }
{                                                                             }
{ Copyright (c) 2001,2002 by Jurgen Faul                                      }
{ E-mail: jfaul@gmx.de                                                        }
{ http://jfaul.de/atl                                                         }
{                                                                             }
{ Version 1.0 (29 April 2002)                                                 }
{   - Support for Windows Media Audio (versions 7, 8)                         }
{   - File info: file size, channel mode, sample rate, duration, bit rate     }
{   - WMA tag info: title, artist, album, track, year, genre, comment         }
{                                                                             }
{ *************************************************************************** }

unit WMAfile;

interface

uses
  Classes, SysUtils, sMediaTag;

const
  { Channel modes }
  WMA_CM_UNKNOWN = 0;                                               { Unknown }
  WMA_CM_MONO = 1;                                                     { Mono }
  WMA_CM_STEREO = 2;                                                 { Stereo }

  { Channel mode names }
  WMA_MODE: array [0..2] of string = ('Unknown', 'Mono', 'Stereo');

type
  { Class TWMAfile }
  TWMAfile = class(TsMediaTag)
    private
      { Private declarations }
      FValid: Boolean;
      FFileSize: Integer;
      FChannelModeID: Byte;
      FSampleRate: Integer;
      FDuration: Double;
      FBitRate: Integer;
      FTitle: WideString;
      FArtist: WideString;
      FAlbum: WideString;
      FTrack: Integer;
      FYear: WideString;
      FGenre: WideString;
      FComment: WideString;
      procedure FResetData;
      function FGetChannelMode: string;
    public
      { Public declarations }
      constructor Create; override;                           { Create object }
      function ReadFromFile(const FileName: string): Boolean; OverRide;     { Load data }
    published
      property Valid: Boolean read FValid;               { True if valid data }
      property FileSize: Integer read FFileSize;          { File size (bytes) }
      property ChannelModeID: Byte read FChannelModeID;   { Channel mode code }
      property ChannelMode: string read FGetChannelMode;  { Channel mode name }
      property SampleRate: Integer read FSampleRate;       { Sample rate (hz) }
      property Duration: Double read FDuration;          { Duration (seconds) }
      property BitRate: Integer read FBitRate;              { Bit rate (kbit) }
      property Title: WideString read FTitle;                    { Song title }
      property Artist: WideString read FArtist;                 { Artist name }
      property Album: WideString read FAlbum;                    { Album name }
      property Track: Integer read FTrack;                     { Track number }
      property Year: WideString read FYear;                            { Year }
      property Genre: WideString read FGenre;                    { Genre name }
      property Comment: WideString read FComment;                   { Comment }
  end;

implementation

uses jconvert;

const
  { Object IDs }
  WMA_HEADER_ID =
    #48#38#178#117#142#102#207#17#166#217#0#170#0#98#206#108;
  WMA_FILE_PROPERTIES_ID =
    #161#220#171#140#71#169#207#17#142#228#0#192#12#32#83#101;
  WMA_STREAM_PROPERTIES_ID =
    #145#7#220#183#183#169#207#17#142#230#0#192#12#32#83#101;
  WMA_CONTENT_DESCRIPTION_ID =
    #51#38#178#117#142#102#207#17#166#217#0#170#0#98#206#108;
  WMA_EXTENDED_CONTENT_DESCRIPTION_ID =
    #64#164#208#210#7#227#210#17#151#240#0#160#201#94#168#80;

  { Max. number of supported comment fields }
  WMA_FIELD_COUNT = 7;

  { Names of supported comment fields }
  WMA_FIELD_NAME: array [1..WMA_FIELD_COUNT] of WideString =
    ('WM/TITLE', 'WM/AUTHOR', 'WM/ALBUMTITLE', 'WM/TRACK', 'WM/YEAR',
     'WM/GENRE', 'WM/DESCRIPTION');

  { Max. number of characters in tag field }
  WMA_MAX_STRING_SIZE = 250;

type
  { Object ID }
  ObjectID = array [1..16] of Char;

  { Tag data }
  TagData = array [1..WMA_FIELD_COUNT] of WideString;

  { File data - for internal use }
  FileData = record
    FileSize: Integer;                                    { File size (bytes) }
    MaxBitRate: Integer;                                { Max. bit rate (bps) }
    Channels: Word;                                      { Number of channels }
    SampleRate: Integer;                                   { Sample rate (hz) }
    ByteRate: Integer;                                            { Byte rate }
    Tag: TagData;                                       { WMA tag information }
  end;

{ ********************* Auxiliary functions & procedures ******************** }

function ReadFieldString(const Source: TStream; DataSize: Word): WideString;
var
  i: Integer;
  FieldData: string;
begin
  { Read field data and convert to Unicode string }
  Result := '';
  // by kujira
  // ����ň��S...�T�C�Y������Ȃ�
  SetLength(FieldData, DataSize);
  Source.ReadBuffer(FieldData[1], DataSize);
  // to UNICODE
  i := 1;
  while i < DataSize do
  begin
    Result := Result + WideChar( Ord(FieldData[i]) + (Ord(FieldData[i+1])shl 8) );
    Inc(i, 2);
  end;
end;

{ --------------------------------------------------------------------------- }

procedure ReadTagStandard(const Source: TStream; var Tag: TagData);
var
  Iterator: Integer;
  FieldSize: array [1..5] of Word;
  FieldValue: WideString;
begin
  { Read standard tag data }
  Source.ReadBuffer(FieldSize, SizeOf(FieldSize));
  for Iterator := 1 to 5 do
    if FieldSize[Iterator] > 0 then
    begin
      { Read field value }
      FieldValue := ReadFieldString(Source, FieldSize[Iterator]);
      { Set corresponding tag field if supported }
      case Iterator of
        1: Tag[1] := FieldValue;
        2: Tag[2] := FieldValue;
        4: Tag[7] := FieldValue;
      end;
    end;
end;

{ --------------------------------------------------------------------------- }

procedure ReadTagExtended(const Source: TStream; var Tag: TagData);
var
  Iterator1, Iterator2, FieldCount, FieldSize, DataSize, DataType: Word;
  FieldName, FieldValue: WideString;
begin
  { Read extended tag data }
  // �C�� by kujira
  Source.ReadBuffer(FieldCount, SizeOf(FieldCount)); // 2 byte
  for Iterator1 := 1 to FieldCount do
  begin
    { Read field name }
    Source.ReadBuffer(FieldSize, SizeOf(FieldSize)); // 2 byte
    FieldName := ReadFieldString(Source, FieldSize);
    { Read value data type }
    Source.ReadBuffer(DataType, SizeOf(DataType));
    { read value size } // �C��
    Source.ReadBuffer(DataSize, SizeOf(DataSize));
    { Read field value only if string }{
		# Value types from ASF spec:
		# 0 = unicode string
		# 1 = BYTE array
		# 2 = BOOL (32 bit)
		# 3 = DWORD (32 bit)
		# 4 = QWORD (64 bit)
		# 5 = WORD (16 bit)                }
    //
    if DataType = 0 then
    begin
      FieldValue := ReadFieldString(Source, DataSize);
    end
    else begin
      Source.Seek(DataSize, soFromCurrent);
    end;
    { Set corresponding tag field if supported }
    for Iterator2 := 1 to WMA_FIELD_COUNT do
      if UpperCase(Trim(FieldName)) = WMA_FIELD_NAME[Iterator2] then
        Tag[Iterator2] := FieldValue;
  end;
end;

{ --------------------------------------------------------------------------- }

procedure ReadObject(const ID: ObjectID; Source: TStream; var Data: FileData);
begin
  { Read data from header object if supported }
  if ID = WMA_FILE_PROPERTIES_ID then
  begin
    { Read file properties }
    Source.Seek(80, soFromCurrent);
    Source.ReadBuffer(Data.MaxBitRate, SizeOf(Data.MaxBitRate));
  end;
  if ID = WMA_STREAM_PROPERTIES_ID then
  begin
    { Read stream properties }
    Source.Seek(60, soFromCurrent);
    Source.ReadBuffer(Data.Channels, SizeOf(Data.Channels));
    Source.ReadBuffer(Data.SampleRate, SizeOf(Data.SampleRate));
    Source.ReadBuffer(Data.ByteRate, SizeOf(Data.ByteRate));
  end;
  if ID = WMA_CONTENT_DESCRIPTION_ID then
  begin
    { Read standard tag data }
    Source.Seek(4, soFromCurrent);
    ReadTagStandard(Source, Data.Tag);
  end;
  if ID = WMA_EXTENDED_CONTENT_DESCRIPTION_ID then
  begin
    { Read extended tag data }
    Source.Seek(4, soFromCurrent);
    ReadTagExtended(Source, Data.Tag);
  end;
end;

{ --------------------------------------------------------------------------- }

function ReadData(const FileName: string; var Data: FileData): Boolean;
var
  Source: TFileStream;
  ID: ObjectID;
  Iterator, ObjectCount, ObjectSize, Position: Integer;
begin
  { Read file data }
  try
    Source := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    Data.FileSize := Source.Size;
    { Check for existing header }
    Source.ReadBuffer(ID, SizeOf(ID));
    if ID = WMA_HEADER_ID then
    begin
      Source.Seek(8, soFromCurrent);
      Source.ReadBuffer(ObjectCount, SizeOf(ObjectCount));
      Source.Seek(2, soFromCurrent);
      { Read all objects in header and get needed data }
      for Iterator := 1 to ObjectCount do
      begin
        Position := Source.Position;
        Source.ReadBuffer(ID, SizeOf(ID));
        Source.ReadBuffer(ObjectSize, SizeOf(ObjectSize));
        ReadObject(ID, Source, Data);
        Source.Seek(Position + ObjectSize, soFromBeginning);
      end;
    end;
    Source.Free;
    Result := true;
  except
    Result := false;
  end;
end;

{ --------------------------------------------------------------------------- }

function IsValid(const Data: FileData): Boolean;
begin
  { Check for data validity }
  Result :=
    (Data.MaxBitRate > 0) and (Data.MaxBitRate < 320000) and
    ((Data.Channels = WMA_CM_MONO) or (Data.Channels = WMA_CM_STEREO)) and
    (Data.SampleRate >= 8000) and (Data.SampleRate <= 96000) and
    (Data.ByteRate > 0) and (Data.ByteRate < 40000);
end;

{ --------------------------------------------------------------------------- }

function ExtractTrack(const TrackString: WideString): Integer;
var
  Value, Code: Integer;
begin
  { Extract track from string }
  Result := 0;
  Val(TrackString, Value, Code);
  if Code = 0 then Result := Value;
end;

{ ********************** Private functions & procedures ********************* }

procedure TWMAfile.FResetData;
begin
  { Reset variables }
  FValid := false;
  FFileSize := 0;
  FChannelModeID := WMA_CM_UNKNOWN;
  FSampleRate := 0;
  FDuration := 0;
  FBitRate := 0;
  FTitle := '';
  FArtist := '';
  FAlbum := '';
  FTrack := 0;
  FYear := '';
  FGenre := '';
  FComment := '';
end;

{ --------------------------------------------------------------------------- }

function TWMAfile.FGetChannelMode: string;
begin
  { Get channel mode name }
  Result := WMA_MODE[FChannelModeID];
end;

{ ********************** Public functions & procedures ********************** }

constructor TWMAfile.Create;
begin
  { Create object }
  inherited;
  FResetData;
end;

{ --------------------------------------------------------------------------- }

function TWMAfile.ReadFromFile(const FileName: string): Boolean;
var
  Data: FileData;
begin
  { Reset variables and load file data }
  FResetData;
  FillChar(Data, SizeOf(Data), 0);
  Result := ReadData(FileName, Data);
  { Process data if loaded and valid }
  if Result and IsValid(Data) then
  begin
    FValid := true;
    { Fill properties with loaded data }
    FFileSize := Data.FileSize;
    FChannelModeID := Data.Channels;
    FSampleRate := Data.SampleRate;
    FDuration := Data.FileSize * 8 / Data.MaxBitRate;
    FBitRate := Data.ByteRate * 8 div 1000;
    FTitle := Trim(Data.Tag[1]);
    FArtist := Trim(Data.Tag[2]);
    FAlbum := Trim(Data.Tag[3]);
    FTrack := ExtractTrack(Trim(Data.Tag[4]));
    FYear := Trim(Data.Tag[5]);
    FGenre := Trim(Data.Tag[6]);
    FComment := Trim(Data.Tag[7]);
    FFileFormat := 'WMA';
  end else
  begin
    Result := False;
  end;
end;

end.
