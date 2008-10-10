unit unit_dbt;

interface

uses
  Windows;

type
  TDEV_BROADCAST_HDR = packed record
    dbch_size       : ULONG;
    dbch_devicetype : ULONG;
    dbch_reserved   : ULONG;
  end;
  PDEV_BROADCAST_HDR = ^TDEV_BROADCAST_HDR;

  TDEV_BROADCAST_VOLUME = packed record
    dbcv_size       : ULONG;
    dbcv_devicetype : ULONG;
    dbcv_reserved   : ULONG;
    dbcv_unitmask   : ULONG;
    dbcv_flags      : WORD; // USHORT
  end;
  PDEV_BROADCAST_VOLUME = ^TDEV_BROADCAST_VOLUME;const  DBT_DEVICEARRIVAL               = $8000  ; // system detected a new device  DBT_DEVICEQUERYREMOVE           = $8001  ; // wants to remove, may fail
  DBT_DEVICEQUERYREMOVEFAILED     = $8002  ; // removal aborted
  DBT_DEVICEREMOVEPENDING         = $8003  ; // about to remove, still avail.
  DBT_DEVICEREMOVECOMPLETE        = $8004  ; // device is gone
  DBT_DEVICETYPESPECIFIC          = $8005  ; // type specific event

  DBT_DEVTYP_OEM                  = $00000000  ; // oem-defined device type
  DBT_DEVTYP_DEVNODE              = $00000001  ; // devnode number
  DBT_DEVTYP_VOLUME               = $00000002  ; // logical volume
  DBT_DEVTYP_PORT                 = $00000003  ; // serial, parallel
  DBT_DEVTYP_NET                  = $00000004  ; // network resource
  DBTF_MEDIA      = $0001          ; // media comings and goings  DBTF_NET        = $0002          ; // network volume
implementation

end.
