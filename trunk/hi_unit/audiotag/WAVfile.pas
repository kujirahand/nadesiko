{ *************************************************************************** }
{                                                                             }
{ Audio Tools Library (Freeware)                                              }
{ Class TWAVfile - for extracting information from WAV file header            }
{                                                                             }
{ Copyright (c) 2001,2002 by Jurgen Faul                                      }
{ E-mail: jfaul@gmx.de                                                        }
{ http://jfaul.de/atl                                                         }
{                                                                             }
{ Version 1.2 (14 January 2002)                                               }
{   - Fixed bug with calculating of duration                                  }
{   - Some class properties added/changed                                     }
{                                                                             }
{ Version 1.1 (9 October 2001)                                                }
{   - Fixed bug with WAV header detection                                     }
{                                                                             }
{ Version 1.0 (31 July 2001)                                                  }
{   - Info: channel mode, sample rate, bits per sample, file size, duration   }
{                                                                             }
{ *************************************************************************** }

unit WAVfile;

interface

uses
  Classes, SysUtils, sMediaTag;

const
  { Format type names }
  WAV_FORMAT_UNKNOWN = 'Unknown';
  WAV_FORMAT_PCM = 'Windows PCM';
  WAV_FORMAT_ADPCM = 'Microsoft ADPCM';
  WAV_FORMAT_ALAW = 'A-LAW';
  WAV_FORMAT_MULAW = 'MU-LAW';
  WAV_FORMAT_DVI_IMA_ADPCM = 'DVI/IMA ADPCM';
  WAV_FORMAT_MP3 = 'MPEG Layer III';

  { Used with ChannelModeID property }
  WAV_CM_MONO = 1;                                      { Index for mono mode }
  WAV_CM_STEREO = 2;                                  { Index for stereo mode }

  { Channel mode names }
  WAV_MODE: array [0..2] of string = ('Unknown', 'Mono', 'Stereo');

type
  { Class TWAVfile }
  TWAVfile = class(TsMediaTag)
    private
      { Private declarations }
      FValid: Boolean;
      FFormatID: Word;
      FChannelNumber: Byte;
      FSampleRate: Cardinal;
      FBytesPerSecond: Cardinal;
      FBlockAlign: Word;
      FBitsPerSample: Byte;
      FSampleNumber: Integer;
      FHeaderSize: Word;
      FFileSize: Cardinal;
      procedure FResetData;
      function FGetFormat: string;
      function FGetChannelMode: string;
      function FGetDuration: Double;
    public
      { Public declarations }
      constructor Create; override;                           { Create object }
      function ReadFromFile(const FileName: string): Boolean; OverRide;   { Load header }
    published
      property Valid: Boolean read FValid;             { True if header valid }
      property FormatID: Word read FFormatID;              { Format type code }
      property Format: string read FGetFormat;             { Format type name }
      property ChannelNumber: Byte read FChannelNumber;  { Number of channels }
      property ChannelMode: string read FGetChannelMode;  { Channel mode name }
      property SampleRate: Cardinal read FSampleRate;      { Sample rate (hz) }
      property BytesPerSecond: Cardinal read FBytesPerSecond;  { Bytes/second }
      property BlockAlign: Word read FBlockAlign;           { Block alignment }
      property BitsPerSample: Byte read FBitsPerSample;         { Bits/sample }
      property HeaderSize: Word read FHeaderSize;       { Header size (bytes) }
      property FileSize: Cardinal read FFileSize;         { File size (bytes) }
      property Duration: Double read FGetDuration;       { Duration (seconds) }
  end;


type
  { WAV file header data }
  WAVRecord = record
    { RIFF file header }
    RIFFHeader: array [1..4] of Char;                        { Must be "RIFF" }
    FileSize: Integer;                           { Must be "RealFileSize - 8" }
    WAVEHeader: array [1..4] of Char;                        { Must be "WAVE" }
    { Format information }
    FormatHeader: array [1..4] of Char;                      { Must be "fmt " }
    FormatSize: Integer;                                        { Format size }
    FormatID: Word;                                        { Format type code }
    ChannelNumber: Word;                                 { Number of channels }
    SampleRate: Integer;                                   { Sample rate (hz) }
    BytesPerSecond: Integer;                                   { Bytes/second }
    BlockAlign: Word;                                       { Block alignment }
    BitsPerSample: Word;                                        { Bits/sample }
    DataHeader: array [1..4] of Char;                         { Can be "data" }
    SampleNumber: Integer;                     { Number of samples (optional) }
  end;

function HeaderIsValid(const WAVData: WAVRecord): Boolean;


implementation

const
  DATA_CHUNK = 'data';                                        { Data chunk ID }

{ ********************* Auxiliary functions & procedures ******************** }

function ReadWAV(const FileName: string; var WAVData: WAVRecord): Boolean;
var
  SourceFile: file;
begin
  try
    Result := true;
    { Set read-access and open file }
    AssignFile(SourceFile, FileName);
    FileMode := 0;
    Reset(SourceFile, 1);
    { Read header }
    BlockRead(SourceFile, WAVData, 40);
    if HeaderIsValid(WAVData) then
    begin
      { Read number of samples if exists }
      if WAVData.DataHeader <> DATA_CHUNK then
      begin
        Seek(SourceFile, WAVData.FormatSize + 28);
        BlockRead(SourceFile, WAVData.SampleNumber, 4);
      end;
    end else
    begin
      Result := False;
    end;
    CloseFile(SourceFile);
  except
    { Error }
    Result := false;
  end;
end;

{ --------------------------------------------------------------------------- }

function HeaderIsValid(const WAVData: WAVRecord): Boolean;
begin
  Result := true;
  { Header validation }
  if WAVData.RIFFHeader <> 'RIFF' then Result := false;
  if WAVData.WAVEHeader <> 'WAVE' then Result := false;
  if WAVData.FormatHeader <> 'fmt ' then Result := false;
  if (WAVData.ChannelNumber <> WAV_CM_MONO) and
    (WAVData.ChannelNumber <> WAV_CM_STEREO) then Result := false;
end;

{ ********************** Private functions & procedures ********************* }

procedure TWAVfile.FResetData;
begin
  { Reset all data }
  FValid := false;
  FFormatID := 0;
  FChannelNumber := 0;
  FSampleRate := 0;
  FBytesPerSecond := 0;
  FBlockAlign := 0;
  FBitsPerSample := 0;
  FSampleNumber := 0;
  FHeaderSize := 0;
  FFileSize := 0;
end;

{ --------------------------------------------------------------------------- }

function TWAVfile.FGetFormat: string;
begin
  { Get format type name }
  case FFormatID of
    1: Result := WAV_FORMAT_PCM;
    2: Result := WAV_FORMAT_ADPCM;
    6: Result := WAV_FORMAT_ALAW;
    7: Result := WAV_FORMAT_MULAW;
    17: Result := WAV_FORMAT_DVI_IMA_ADPCM;
    85: Result := WAV_FORMAT_MP3;
  else
    Result := '';
  end;
end;

{ --------------------------------------------------------------------------- }

function TWAVfile.FGetChannelMode: string;
begin
  { Get channel mode name }
  Result := WAV_MODE[FChannelNumber];
end;

{ --------------------------------------------------------------------------- }

function TWAVfile.FGetDuration: Double;
begin
  { Get duration }
  Result := 0;
  if FValid then
  begin
    if (FSampleNumber = 0) and (FBytesPerSecond > 0) then
      Result := (FFileSize - FHeaderSize) / FBytesPerSecond;
    if (FSampleNumber > 0) and (FSampleRate > 0) then
      Result := FSampleNumber / FSampleRate;
  end;
end;

{ ********************** Public functions & procedures ********************** }

constructor TWAVfile.Create;
begin
  { Create object }
  inherited;
  FResetData;
end;

{ --------------------------------------------------------------------------- }

function TWAVfile.ReadFromFile(const FileName: string): Boolean;
var
  WAVData: WAVRecord;
begin
  { Reset and load header data from file to variable }
  FResetData;
  FillChar(WAVData, SizeOf(WAVData), 0);
  Result := ReadWAV(FileName, WAVData);
  { Process data if loaded and header valid }
  if (Result) and (HeaderIsValid(WAVData)) then
  begin
    FValid := true;
    { Fill properties with header data }
    FFormatID := WAVData.FormatID;
    FChannelNumber := WAVData.ChannelNumber;
    FSampleRate := WAVData.SampleRate;
    FBytesPerSecond := WAVData.BytesPerSecond;
    FBlockAlign := WAVData.BlockAlign;
    FBitsPerSample := WAVData.BitsPerSample;
    FSampleNumber := WAVData.SampleNumber;
    if WAVData.DataHeader = DATA_CHUNK then FHeaderSize := 44
    else FHeaderSize := WAVData.FormatSize + 40;
    FFileSize := WAVData.FileSize + 8;
    if FHeaderSize > FFileSize then FHeaderSize := FFileSize;
    FFileFormat := 'WAV';
  end else
  begin
    Result := False;
  end;
end;

end.
