object frmNako: TfrmNako
  Left = 193
  Top = 131
  Width = 606
  Height = 407
  Caption = #12394#12391#12375#12371
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDefaultPosOnly
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnPaint = FormPaint
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object timerRunScript: TTimer
    Enabled = False
    Interval = 1
    OnTimer = timerRunScriptTimer
    Left = 176
    Top = 40
  end
  object AppEvent: TApplicationEvents
    OnActivate = AppEventActivate
    OnDeactivate = AppEventDeactivate
    OnIdle = AppEventIdle
    OnMinimize = AppEventMinimize
    OnRestore = AppEventRestore
    Left = 144
    Top = 40
  end
  object dlgFont: TFontDialog
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = []
    Options = []
    Left = 16
    Top = 40
  end
  object dlgColor: TColorDialog
    Left = 48
    Top = 40
  end
  object dlgPrinter: TPrinterSetupDialog
    Left = 80
    Top = 40
  end
end
