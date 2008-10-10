object frmAbout: TfrmAbout
  Left = 268
  Top = 223
  BorderStyle = bsDialog
  Caption = #12394#12391#12375#12371#12456#12487#12451#12479#12395#12388#12356#12390
  ClientHeight = 332
  ClientWidth = 436
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object Panel1: TPanel
    Left = 0
    Top = 289
    Width = 436
    Height = 43
    Align = alBottom
    TabOrder = 0
    object btnOK: TButton
      Left = 336
      Top = 8
      Width = 91
      Height = 25
      Caption = #30906#23450'(&O)'
      TabOrder = 0
      OnClick = btnOKClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 436
    Height = 289
    Align = alClient
    TabOrder = 1
    object Shape1: TShape
      Left = 8
      Top = 8
      Width = 419
      Height = 273
      Pen.Color = clGray
      Pen.Style = psDot
    end
    object Label1: TLabel
      Left = 256
      Top = 264
      Width = 166
      Height = 12
      Caption = #35069#20316': '#12463#12472#12521#39131#34892#26426#12288#12367#12376#12425#12399#12435#12393
      Transparent = True
    end
    object imgMain: TImage
      Left = 16
      Top = 16
      Width = 405
      Height = 241
    end
  end
end
