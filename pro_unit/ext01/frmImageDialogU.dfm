object frmImageDialog: TfrmImageDialog
  Left = 282
  Top = 240
  Width = 494
  Height = 377
  Caption = #30011#20687
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
  object img: TImage
    Left = 0
    Top = 0
    Width = 478
    Height = 306
    Align = alClient
    Proportional = True
    Stretch = True
  end
  object pnl: TPanel
    Left = 0
    Top = 306
    Width = 478
    Height = 33
    Align = alBottom
    TabOrder = 0
    OnResize = pnlResize
    object btnOK: TButton
      Left = 395
      Top = 4
      Width = 75
      Height = 25
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnOKClick
    end
  end
end
