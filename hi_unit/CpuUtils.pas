unit CpuUtils;
{
TCpuUsage component
2002.10.28
vivas@terra.dti.ne.jp
}

interface

uses
  Windows, Messages, SysUtils, Classes, Registry;

type
  TNtQuerySystemInformation = function(SystemInformationClass: UINT; SystemInformation: Pointer; SystemInformationLength: ULONG; ReturnLength: PULONG): Integer; stdcall;

  TCpuUsage = class(TComponent)
  private
    FHandle: THandle;
    FInfoSize: Integer;
    FReg: TRegistry;
    FOldIdleTime: LARGE_INTEGER;
    FOldSystemTime: LARGE_INTEGER;
    FNumOfProcessors: Byte;
    NtQuerySystemInformation: TNtQuerySystemInformation;
    function GetValue: Byte;
  protected
    function GetNt: Byte; virtual;
    function Get9x: Byte; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Reset; dynamic;
    property Value: Byte read GetValue;
  end;

procedure Register;

implementation

const
  DATAKEY = 'KERNEL\CPUUsage';

type
  _SYSTEM_PERFORMANCE_INFORMATION = record
    IdleTime: LARGE_INTEGER;
    // Reserved: array [0..75] of DWORD;
    Reserved: array [0..87] of DWORD;
  end;
  PSystemPerformanceInformation = ^TSystemPerformanceInformation;
  TSystemPerformanceInformation = _SYSTEM_PERFORMANCE_INFORMATION;

  _SYSTEM_BASIC_INFORMATION = record
    Reserved1: array [0..23] of Byte;
    Reserved2: array [0..3] of Pointer;
    NumberOfProcessors: UCHAR;
  end;
  PSystemBasicInformation = ^TSystemBasicInformation;
  TSystemBasicInformation = _SYSTEM_BASIC_INFORMATION;

  _SYSTEM_TIME_INFORMATION = record
    KeBootTime: LARGE_INTEGER;
    KeSystemTime: LARGE_INTEGER;
    ExpTimeZoneBias: LARGE_INTEGER;
    CurrentTimeZoneId: ULONG;
  end;
  PSystemTimeInformation = ^TSystemTimeInformation;
  TSystemTimeInformation = _SYSTEM_TIME_INFORMATION;

constructor TCpuUsage.Create(AOwner: TComponent);
var
  BaseInfo: TSystemBasicInformation;
begin
  inherited;

  FHandle := LoadLibrary('ntdll.dll');
  if FHandle <> 0 then begin
    Reset;
    NtQuerySystemInformation := GetProcAddress(FHandle, 'NtQuerySystemInformation');
    if @NtQuerySystemInformation <> nil then begin
      if NtQuerySystemInformation(0, @BaseInfo, SizeOf(BaseInfo), nil) = NO_ERROR then
        FNumOfProcessors := BaseInfo.NumberOfProcessors
      else
        FHandle := 0;
    end else
      FHandle := 0;
  end;
  FInfoSize := 312;
end;

destructor TCpuUsage.Destroy;
var
  Value: Integer;
begin
  if FHandle <> 0 then
    if not FreeLibrary(FHandle) then
      raise Exception.Create('ntdllƒ‰ƒCƒuƒ‰ƒŠ‚Ì‰ð•ú‚ÉŽ¸”s‚µ‚Ü‚µ‚½');

  if FReg <> nil then
    with FReg do begin
      RootKey := HKEY_DYN_DATA;
      if OpenKey('\PerfStats\StopStat', False) then
        ReadBinaryData(DATAKEY, Value, SizeOf(Value));
      Free;
    end;

  inherited;

end;

procedure TCpuUsage.Reset;
begin
  FOldIdleTime.QuadPart := 0;
  FOldSystemTime.QuadPart := 0;

end;

function TCpuUsage.GetNt: Byte;
var
  PerfInfo: TSystemPerformanceInformation;
  TimeInfo: TSystemTimeInformation;
  IdleTime: INT64;
  SystemTime: INT64;
begin
  Result := 0;

  if NtQuerySystemInformation(3, @TimeInfo, SizeOf(TimeInfo), nil) <> NO_ERROR then
    Exit;

  if NtQuerySystemInformation(2, @PerfInfo, FInfoSize, nil) <> NO_ERROR then
  begin
    FInfoSize := 312 + 360 - FInfoSize;
    if NtQuerySystemInformation(2, @PerfInfo, FInfoSize, nil) <> NO_ERROR then
      Exit;
  end;

  if FOldIdleTime.QuadPart <> 0 then begin
    IdleTime := PerfInfo.IdleTime.QuadPart - FOldIdleTime.QuadPart;
    SystemTime := TimeInfo.KeSystemTime.QuadPart - FOldSystemTime.QuadPart;
    try
      Result := Trunc(100.0 - (IdleTime / SystemTime) * 100.0 / FNumOfProcessors);
    except
      Result := 0;
    end;
  end;

  FOldIdleTime := PerfInfo.IdleTime;
  FOldSystemTime := TimeInfo.KeSystemTime;

end;

function TCpuUsage.Get9x: Byte;
var
  Value: Integer;
begin
  Result := 0;

  if FReg = nil then begin
    FReg := TRegistry.Create(KEY_READ);
    with FReg do begin
      RootKey := HKEY_DYN_DATA;
      if OpenKey('\PerfStats\StartStat', False) then
        ReadBinaryData(DATAKEY, Value, SizeOf(Value))
      else
        Exit;
    end;
  end;

  with FReg do begin
    if OpenKey('\PerfStats\StatData', False) then
      if ReadBinaryData(DATAKEY, Value, SizeOf(Value)) = SizeOf(Value) then
        Result := Value;
  end;

end;

function TCpuUsage.GetValue: Byte;
begin
  if FHandle = 0 then begin // Win9x
    Result := Get9x;
  end else begin // WinNT
    Result := GetNt;
  end;

end;

procedure Register;
begin
  RegisterComponents('Samples', [TCpuUsage]);
end;

end.
