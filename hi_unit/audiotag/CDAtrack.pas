{ *************************************************************************** }
{                                                                             }
{ Audio Tools Library (Freeware)                                              }
{ Class TCDAtrack - for getting information for CDA track                     }
{                                                                             }
{ Copyright (c) 2001,2002 by Jurgen Faul                                      }
{ E-mail: jfaul@gmx.de                                                        }
{ http://jfaul.de/atl                                                         }
{                                                                             }
{ Version 1.0 (4 November 2002)                                               }
{   - Using cdplayer.ini                                                      }
{   - Track info: title, artist, album, duration, track number, position      }
{                                                                             }
{ *************************************************************************** }

unit CDAtrack;

interface

uses
  Classes, SysUtils, IniFiles, sMediaTag;

type
  { Class TCDAtrack }
  TCDAtrack = class(TsMediaTag)
    private
      { Private declarations }
      FValid: Boolean;
      FTitle: WideString;
      FArtist: WideString;
      FAlbum: WideString;
      FDuration: Double;
      FTrack: Word;
      FPosition: Double;
      procedure FResetData;
    public
      { Public declarations }
      constructor Create; override;                           { Create object }
      function ReadFromFile(const FileName: string): Boolean; OverRide;     { Load data }
    published
      property Valid: Boolean read FValid;             { True if valid format }
      property Title: WideString read FTitle;                    { Song title }
      property Artist: WideString read FArtist;                 { Artist name }
      property Album: WideString read FAlbum;                    { Album name }
      property Duration: Double read FDuration;          { Duration (seconds) }
      property Track: Word read FTrack;                        { Track number }
      property Position: Double read FPosition;    { Track position (seconds) }
  end;

implementation

type
  { CDA track data }
  TrackData = packed record
    RIFFHeader: array [1..4] of Char;                         { Always "RIFF" }
    FileSize: Integer;                            { Always "RealFileSize - 8" }
    CDDAHeader: array [1..8] of Char;                     { Always "CDDAfmt " }
    FormatSize: Integer;                                          { Always 24 }
    FormatID: Word;                                                { Always 1 }
    TrackNumber: Word;                                         { Track number }
    Serial: Integer;              { CD serial number (stored in cdplayer.ini) }
    PositionHSG: Integer;                      { Track position in HSG format }
    DurationHSG: Integer;                      { Track duration in HSG format }
    PositionRB: Integer;                  { Track position in Red-Book format }
    DurationRB: Integer;                  { Track duration in Red-Book format }
    Title: string;                                               { Song title }
    Artist: string;                                             { Artist name }
    Album: string;                                               { Album name }
  end;

{ ********************* Auxiliary functions & procedures ******************** }

function ReadData(const FileName: string; var Data: TrackData): Boolean;
var
  Source: TFileStream;
  CDData: TIniFile;
begin
  { Read track data }
  Result := false;
  try
    Source := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    Source.Read(Data, 44);
    Source.Free;
    Result := true;
    { Try to get song info }
    CDData := TIniFile.Create('cdplayer.ini');
    Data.Title := CDData.ReadString(IntToHex(Data.Serial, 2),
      IntToStr(Data.TrackNumber), '');
    Data.Artist := CDData.ReadString(IntToHex(Data.Serial, 2),
      'artist', '');
    Data.Album := CDData.ReadString(IntToHex(Data.Serial, 2),
      'title', '');
    CDData.Free;
  except
  end;
end;

{ --------------------------------------------------------------------------- }

function IsValid(const Data: TrackData): Boolean;
begin
  { Check for format correctness }
  Result := (Data.RIFFHeader = 'RIFF') and (Data.CDDAHeader = 'CDDAfmt ');
end;

{ ********************** Private functions & procedures ********************* }

procedure TCDAtrack.FResetData;
begin
  { Reset variables }
  FValid := false;
  FTitle := '';
  FArtist := '';
  FAlbum := '';
  FDuration := 0;
  FTrack := 0;
  FPosition := 0;
end;

{ ********************** Public functions & procedures ********************** }

constructor TCDAtrack.Create;
begin
  { Create object }
  inherited;
  FResetData;
end;

{ --------------------------------------------------------------------------- }

function TCDAtrack.ReadFromFile(const FileName: string): Boolean;
var
  Data: TrackData;
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
    FTitle := Data.Title;
    FArtist := Data.Artist;
    FAlbum := Data.Album;
    FDuration := Data.DurationHSG / 75;
    FTrack := Data.TrackNumber;
    FPosition := Data.PositionHSG / 75;
    FFileFormat := 'CDA';
  end else
  begin
    Result := False;
  end;
end;

end.
