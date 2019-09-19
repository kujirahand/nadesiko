object frmWebDialog: TfrmWebDialog
  Left = 209
  Top = 144
  Width = 546
  Height = 433
  Caption = 'Web'#12480#12452#12450#12525#12464
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object browser: TWebBrowser
    Left = 0
    Top = 0
    Width = 530
    Height = 360
    Align = alClient
    TabOrder = 0
    OnBeforeNavigate2 = browserBeforeNavigate2
    OnDocumentComplete = browserDocumentComplete
    ControlData = {
      4C000000C7360000352500000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126202000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object pnl: TPanel
    Left = 0
    Top = 360
    Width = 530
    Height = 35
    Align = alBottom
    TabOrder = 1
    OnResize = pnlResize
    object btnOK: TButton
      Left = 376
      Top = 6
      Width = 75
      Height = 25
      Caption = 'OK(&O)'
      TabOrder = 0
      OnClick = btnOKClick
    end
  end
end
