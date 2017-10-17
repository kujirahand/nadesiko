{ *************************************************************************** }
{                                                                             }
{ Audio Tools Library (Freeware)                                              }
{ Class TFLACfile - for manipulating with FLAC file information               }
{                                                                             }
{ Uses:                                                                       }
{   - Class TID3v1                                                            }
{   - Class TID3v2                                                            }
{                                                                             }
{ Copyright (c) 2001,2002 by Jurgen Faul                                      }
{ E-mail: jfaul@gmx.de                                                        }
{ http://jfaul.de/atl                                                         }
{                                                                             }
{ Version 1.0 (13 August 2002)                                                }
{   - Info: channels, sample rate, bits/sample, file size, duration, ratio    }
{   - Class TID3v1: reading & writing support for ID3v1 tags                  }
{   - Class TID3v2: reading & writing support for ID3v2 tags                  }
{                                                                             }
{ *************************************************************************** }

unit FLACfile;

interface

uses
  Classes, SysUtils, ID3v1, ID3v2, sMediaTag;

type
  { Class TFLACfile }
  TFLACfile = class(TsMediaTag)
    private
      { Private declarations }
      FChannels: Byte;
      FSampleRate: Integer;
      FBitsPerSample: Byte;
      FFileLength: Integer;
      FSamples: Integer;
      FID3v1: TID3v1;
      FID3v2: TID3v2;
      procedure FResetData;
      function FIsValid: Boolean;
      function FGetDuration: Double;
      function FGetRatio: Double;
    public
      { Public declarations }
      constructor Create; override;                           { Create object }
      destructor Destroy; override;                          { Destroy object }
      function ReadFromFile(const FileName: string): Boolean; OverRide;   { Load header }
    published
      property Channels: Byte read FChannels;            { Number of channels }
      property SampleRate: Integer read FSampleRate;       { Sample rate (hz) }
      property BitsPerSample: Byte read FBitsPerSample;     { Bits per sample }
      property FileLength: Integer read FFileLength;    { File length (bytes) }
      property Samples: Integer read FSamples;            { Number of samples }
      property ID3v1: TID3v1 read FID3v1;                    { ID3v1 tag data }
      property ID3v2: TID3v2 read FID3v2;                    { ID3v2 tag data }
      property Valid: Boolean read FIsValid;           { True if header valid }
      property Duration: Double read FGetDuration;       { Duration (seconds) }
      property Ratio: Double read FGetRatio;          { Compression ratio (%) }
  end;

implementation

{ ********************** Private functions & procedures ********************* }

procedure TFLACfile.FResetData;
begin
  { Reset data }
  FChannels := 0;
  FSampleRate := 0;
  FBitsPerSample := 0;
  FFileLength := 0;
  FSamples := 0;
  FID3v1.ResetData;
  FID3v2.ResetData;
end;

{ --------------------------------------------------------------------------- }

function TFLACfile.FIsValid: Boolean;
begin
  { Check for right FLAC file data }
  Result :=
    (FChannels > 0) and
    (FSampleRate > 0) and
    (FBitsPerSample > 0) and
    (FSamples > 0);
end;

{ --------------------------------------------------------------------------- }

function TFLACfile.FGetDuration: Double;
begin
  { Get song duration }
  if FIsValid then
    Result := FSamples / FSampleRate
  else
    Result := 0;
end;

{ --------------------------------------------------------------------------- }

function TFLACfile.FGetRatio: Double;
begin
  { Get compression ratio }
  if FIsValid then
    Result := FFileLength / (FSamples * FChannels * FBitsPerSample / 8) * 100
  else
    Result := 0;
end;

{ ********************** Public functions & procedures ********************** }

constructor TFLACfile.Create;
begin
  { Create object }
  inherited;
  FID3v1 := TID3v1.Create;
  FID3v2 := TID3v2.Create;
  FResetData;
end;

{ --------------------------------------------------------------------------- }

destructor TFLACfile.Destroy;
begin
  { Destroy object }
  FID3v1.Free;
  FID3v2.Free;
  inherited;
end;

{ --------------------------------------------------------------------------- }

function TFLACfile.ReadFromFile(const FileName: string): Boolean;
var
  SourceFile: file;
  Hdr: array [1..26] of Byte;
begin
  { Reset and load header data from file to array }
  FResetData;
  FillChar(Hdr, SizeOf(Hdr), 0);
  try
    Result := true;
    { Set read-access and open file }
    AssignFile(SourceFile, FileName);
    FileMode := 0;
    Reset(SourceFile, 1);
    { Read header data }
    BlockRead(SourceFile, Hdr, SizeOf(Hdr));
    FFileLength := FileSize(SourceFile);
    CloseFile(SourceFile);
    { Process data if loaded and header valid }
    if Hdr[1] + Hdr[2] + Hdr[3] + Hdr[4] = 342 then
    begin
      FChannels := Hdr[21] shr 1 and $7 + 1;
      FSampleRate := Hdr[19] shl 12 + Hdr[20] shl 4 + Hdr[21] shr 4;
      FBitsPerSample := Hdr[21] and 1 shl 4 + Hdr[22] shr 4 + 1;
      FSamples := Hdr[23] shl 24 + Hdr[24] shl 16 + Hdr[25] shl 8 + Hdr[26];
      FFileFormat := 'FRAC';
    end else
    begin
      Result := False;
    end;
  except
    { Error }
    Result := false;
  end;
end;

end.
