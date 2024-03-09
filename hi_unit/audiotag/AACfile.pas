{ *************************************************************************** }
{                                                                             }
{ Audio Tools Library (Freeware)                                              }
{ Class TAACfile - for manipulating with AAC file information                 }
{                                                                             }
{ Uses:                                                                       }
{   - Class TID3v1                                                            }
{   - Class TID3v2                                                            }
{                                                                             }
{ Copyright (c) 2001,2002 by Jurgen Faul                                      }
{ E-mail: jfaul@gmx.de                                                        }
{ http://jfaul.de/atl                                                         }
{                                                                             }
{ Version 1.0 (2 October 2002)                                                }
{   - Support for AAC files with ADIF or ADTS header                          }
{   - File info: file size, type, channels, sample rate, bit rate, duration   }
{   - Class TID3v1: reading & writing support for ID3v1 tags                  }
{   - Class TID3v2: reading & writing support for ID3v2 tags                  }
{                                                                             }
{ *************************************************************************** }

unit AACfile;

interface

uses
  Classes, SysUtils, ID3v1, ID3v2, sMediaTag;

const
  { Header type codes }
  AAC_HEADER_TYPE_UNKNOWN = 0;                                      { Unknown }
  AAC_HEADER_TYPE_ADIF = 1;                                            { ADIF }
  AAC_HEADER_TYPE_ADTS = 2;                                            { ADTS }

  { Header type names }
  AAC_HEADER_TYPE: array [0..2] of string =
    ('Unknown', 'ADIF', 'ADTS');

  { MPEG version codes }
  AAC_MPEG_VERSION_UNKNOWN = 0;                                     { Unknown }
  AAC_MPEG_VERSION_2 = 1;                                            { MPEG-2 }
  AAC_MPEG_VERSION_4 = 2;                                            { MPEG-4 }

  { MPEG version names }
  AAC_MPEG_VERSION: array [0..2] of string =
    ('Unknown', 'MPEG-2', 'MPEG-4');

  { Profile codes }
  AAC_PROFILE_UNKNOWN = 0;                                          { Unknown }
  AAC_PROFILE_MAIN = 1;                                                { Main }
  AAC_PROFILE_LC = 2;                                                    { LC }
  AAC_PROFILE_SSR = 3;                                                  { SSR }
  AAC_PROFILE_LTP = 4;                                                  { LTP }

  { Profile names }
  AAC_PROFILE: array [0..4] of string =
    ('Unknown', 'AAC Main', 'AAC LC', 'AAC SSR', 'AAC LTP');

  { Bit rate type codes }
  AAC_BITRATE_TYPE_UNKNOWN = 0;                                     { Unknown }
  AAC_BITRATE_TYPE_CBR = 1;                                             { CBR }
  AAC_BITRATE_TYPE_VBR = 2;                                             { VBR }

  { Bit rate type names }
  AAC_BITRATE_TYPE: array [0..2] of string =
    ('Unknown', 'CBR', 'VBR');

type
  { Class TAACfile }
  TAACfile = class(TsMediaTag)
    private
      { Private declarations }
      FFileSize: Integer;
      FHeaderTypeID: Byte;
      FMPEGVersionID: Byte;
      FProfileID: Byte;
      FChannels: Byte;
      FSampleRate: Integer;
      FBitRate: Integer;
      FBitRateTypeID: Byte;
      FID3v1: TID3v1;
      FID3v2: TID3v2;
      procedure FResetData;
      function FGetHeaderType: string;
      function FGetMPEGVersion: string;
      function FGetProfile: string;
      function FGetBitRateType: string;
      function FGetDuration: Double;
      function FIsValid: Boolean;
      function FRecognizeHeaderType(const Source: TFileStream): Byte;
      procedure FReadADIF(const Source: TFileStream);
      procedure FReadADTS(const Source: TFileStream);
    public
      { Public declarations }
      constructor Create; override;                           { Create object }
      destructor Destroy; override;                          { Destroy object }
      function ReadFromFile(const FileName: string): Boolean; OverRide;   { Load header }
    published
      property ID3v1: TID3v1 read FID3v1;                    { ID3v1 tag data }
      property ID3v2: TID3v2 read FID3v2;                    { ID3v2 tag data }
      property FileSize: Integer read FFileSize;          { File size (bytes) }
      property HeaderTypeID: Byte read FHeaderTypeID;      { Header type code }
      property HeaderType: string read FGetHeaderType;     { Header type name }
      property MPEGVersionID: Byte read FMPEGVersionID;   { MPEG version code }
      property MPEGVersion: string read FGetMPEGVersion;  { MPEG version name }
      property ProfileID: Byte read FProfileID;                { Profile code }
      property Profile: string read FGetProfile;               { Profile name }
      property Channels: Byte read FChannels;            { Number of channels }
      property SampleRate: Integer read FSampleRate;       { Sample rate (hz) }
      property BitRate: Integer read FBitRate;             { Bit rate (bit/s) }
      property BitRateTypeID: Byte read FBitRateTypeID;  { Bit rate type code }
      property BitRateType: string read FGetBitRateType; { Bit rate type name }
      property Duration: Double read FGetDuration;       { Duration (seconds) }
      property Valid: Boolean read FIsValid;             { True if data valid }
  end;

implementation

const
  { Sample rate values }
  SAMPLE_RATE: array [0..15] of Integer =
    (96000, 88200, 64000, 48000, 44100, 32000,
    24000, 22050, 16000, 12000, 11025, 8000, 0, 0, 0, 0);

{ ********************* Auxiliary functions & procedures ******************** }

function ReadBits(Source: TFileStream; Position, Count: Integer): Integer;
var
  Buffer: array [1..4] of Byte;
begin
  { Read a number of bits from file at the given position }
  Source.Seek(Position div 8, soFromBeginning);
  Source.Read(Buffer, SizeOf(Buffer));
  Result :=
    Buffer[1] * $1000000 +
    Buffer[2] * $10000 +
    Buffer[3] * $100 +
    Buffer[4];
  Result := (Result shl (Position mod 8)) shr (32 - Count);
end;

{ ********************** Private functions & procedures ********************* }

procedure TAACfile.FResetData;
begin
  { Reset all variables }
  FFileSize := 0;
  FHeaderTypeID := AAC_HEADER_TYPE_UNKNOWN;
  FMPEGVersionID := AAC_MPEG_VERSION_UNKNOWN;
  FProfileID := AAC_PROFILE_UNKNOWN;
  FChannels := 0;
  FSampleRate := 0;
  FBitRate := 0;
  FBitRateTypeID := AAC_BITRATE_TYPE_UNKNOWN;
  FID3v1.ResetData;
  FID3v2.ResetData;
end;

{ --------------------------------------------------------------------------- }

function TAACfile.FGetHeaderType: string;
begin
  { Get header type name }
  Result := AAC_HEADER_TYPE[FHeaderTypeID];
end;

{ --------------------------------------------------------------------------- }

function TAACfile.FGetMPEGVersion: string;
begin
  { Get MPEG version name }
  Result := AAC_MPEG_VERSION[FMPEGVersionID];
end;

{ --------------------------------------------------------------------------- }

function TAACfile.FGetProfile: string;
begin
  { Get profile name }
  Result := AAC_PROFILE[FProfileID];
end;

{ --------------------------------------------------------------------------- }

function TAACfile.FGetBitRateType: string;
begin
  { Get bit rate type name }
  Result := AAC_BITRATE_TYPE[FBitRateTypeID];
end;

{ --------------------------------------------------------------------------- }

function TAACfile.FGetDuration: Double;
begin
  { Calculate duration time }
  if FBitRate = 0 then Result := 0
  else Result := 8 * (FFileSize - ID3v2.Size) / FBitRate;
end;

{ --------------------------------------------------------------------------- }

function TAACfile.FIsValid: Boolean;
begin
  { Check for file correctness }
  Result := (FHeaderTypeID <> AAC_HEADER_TYPE_UNKNOWN) and
    (FChannels > 0) and (FSampleRate > 0) and (FBitRate > 0);
end;

{ --------------------------------------------------------------------------- }

function TAACfile.FRecognizeHeaderType(const Source: TFileStream): Byte;
var
  Header: array [1..4] of Char;
begin
  { Get header type of the file }
  Result := AAC_HEADER_TYPE_UNKNOWN;
  Source.Seek(FID3v2.Size, soFromBeginning);
  Source.Read(Header, SizeOf(Header));
  if Header[1] + Header[2] + Header[3] + Header[4] = 'ADIF' then
    Result := AAC_HEADER_TYPE_ADIF
  else if (Byte(Header[1]) = $FF) and (Byte(Header[1]) and $F0 = $F0) then
    Result := AAC_HEADER_TYPE_ADTS;
end;

{ --------------------------------------------------------------------------- }

procedure TAACfile.FReadADIF(const Source: TFileStream);
var
  Position: Integer;
begin
  { Read ADIF header data }
  Position := FID3v2.Size * 8 + 32;
  if ReadBits(Source, Position, 1) = 0 then Inc(Position, 3)
  else Inc(Position, 75);
  if ReadBits(Source, Position, 1) = 0 then
    FBitRateTypeID := AAC_BITRATE_TYPE_CBR
  else
    FBitRateTypeID := AAC_BITRATE_TYPE_VBR;
  Inc(Position, 1);
  FBitRate := ReadBits(Source, Position, 23);
  if FBitRateTypeID = AAC_BITRATE_TYPE_CBR then Inc(Position, 51)
  else Inc(Position, 31);
  FMPEGVersionID := AAC_MPEG_VERSION_4;
  FProfileID := ReadBits(Source, Position, 2) + 1;
  Inc(Position, 2);
  FSampleRate := SAMPLE_RATE[ReadBits(Source, Position, 4)];
  Inc(Position, 4);
  Inc(FChannels, ReadBits(Source, Position, 4));
  Inc(Position, 4);
  Inc(FChannels, ReadBits(Source, Position, 4));
  Inc(Position, 4);
  Inc(FChannels, ReadBits(Source, Position, 4));
  Inc(Position, 4);
  Inc(FChannels, ReadBits(Source, Position, 2));
end;

{ --------------------------------------------------------------------------- }

procedure TAACfile.FReadADTS(const Source: TFileStream);
var
  Frames, TotalSize, Position: Integer;
begin
  { Read ADTS header data }
  Frames := 0;
  TotalSize := 0;
  repeat
    Inc(Frames);
    Position := (FID3v2.Size + TotalSize) * 8;
    if ReadBits(Source, Position, 12) <> $FFF then break;
    Inc(Position, 12);
    if ReadBits(Source, Position, 1) = 0 then
      FMPEGVersionID := AAC_MPEG_VERSION_4
    else
      FMPEGVersionID := AAC_MPEG_VERSION_2;
    Inc(Position, 4);
    FProfileID := ReadBits(Source, Position, 2) + 1;
    Inc(Position, 2);
    FSampleRate := SAMPLE_RATE[ReadBits(Source, Position, 4)];
    Inc(Position, 5);
    FChannels := ReadBits(Source, Position, 3);
    if FMPEGVersionID = AAC_MPEG_VERSION_4 then Inc(Position, 9)
    else Inc(Position, 7);
    Inc(TotalSize, ReadBits(Source, Position, 13));
    Inc(Position, 13);
    if ReadBits(Source, Position, 11) = $7FF then
      FBitRateTypeID := AAC_BITRATE_TYPE_VBR
    else
      FBitRateTypeID := AAC_BITRATE_TYPE_CBR;
    if FBitRateTypeID = AAC_BITRATE_TYPE_CBR then break;
  until (Frames = 1000) or (Source.Size <= FID3v2.Size + TotalSize);
  FBitRate := Round(8 * TotalSize / 1024 / Frames * FSampleRate);
end;

{ ********************** Public functions & procedures ********************** }

constructor TAACfile.Create;
begin
  { Create object }
  FID3v1 := TID3v1.Create;
  FID3v2 := TID3v2.Create;
  FResetData;
  inherited;
end;

{ --------------------------------------------------------------------------- }

destructor TAACfile.Destroy;
begin
  { Destroy object }
  FID3v1.Free;
  FID3v2.Free;
  inherited;
end;

{ --------------------------------------------------------------------------- }

function TAACfile.ReadFromFile(const FileName: string): Boolean;
var
  Source: TFileStream;
begin
  { Read data from file }
  Result := false;
  FResetData;
  { At first search for tags, then try to recognize header type }
  if (FID3v2.ReadFromFile(FileName)) and (FID3v1.ReadFromFile(FileName)) then
  begin
    try
      Source := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
      FFileSize := Source.Size;
      FHeaderTypeID := FRecognizeHeaderType(Source);
      { Read header data }
      if FHeaderTypeID = AAC_HEADER_TYPE_ADIF then FReadADIF(Source);
      if FHeaderTypeID = AAC_HEADER_TYPE_ADTS then FReadADTS(Source);
      Source.Free;
      FFileFormat := 'AAC';
      Result := True;
    except
    end;
  end else
  begin
    Result := False;
  end;
end;

end.
