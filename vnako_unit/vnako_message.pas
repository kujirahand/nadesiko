unit vnako_message;

interface
uses
  Classes, SysUtils, Messages;

const
  WM_VNAKO            = WM_USER + $3000;
  WM_VNAKO_STOP       = WM_VNAKO + 1;
  WM_VNAKO_BREAK      = WM_VNAKO + 2;
  WM_VNAKO_BREAK_ALL  = WM_VNAKO + 3;

implementation

end.
