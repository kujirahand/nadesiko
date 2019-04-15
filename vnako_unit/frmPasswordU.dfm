object frmPassword: TfrmPassword
  Left = 260
  Top = 256
  BorderStyle = bsDialog
  Caption = #12497#12473#12527#12540#12489#20837#21147
  ClientHeight = 89
  ClientWidth = 281
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object lblCaption: TLabel
    Left = 8
    Top = 8
    Width = 18
    Height = 12
    Caption = '***'
  end
  object edtMain: TEdit
    Left = 8
    Top = 32
    Width = 265
    Height = 20
    ImeMode = imClose
    PasswordChar = '*'
    TabOrder = 0
    OnKeyPress = edtMainKeyPress
  end
  object Panel1: TPanel
    Left = 0
    Top = 57
    Width = 281
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Panel2: TPanel
      Left = 72
      Top = 0
      Width = 209
      Height = 32
      BevelOuter = bvNone
      TabOrder = 0
      object btnOk: TButton
        Left = 6
        Top = 0
        Width = 123
        Height = 25
        Caption = #27770#23450'(&O)'
        TabOrder = 0
        OnClick = btnOkClick
      end
      object btnClose: TButton
        Left = 136
        Top = 0
        Width = 65
        Height = 25
        Caption = #21462#28040'(&C)'
        TabOrder = 1
      end
    end
  end
end
