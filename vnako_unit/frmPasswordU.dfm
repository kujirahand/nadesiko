object frmPassword: TfrmPassword
  Left = 260
  Top = 256
  BorderStyle = bsDialog
  Caption = #12497#12473#12527#12540#12489#20837#21147
  ClientHeight = 90
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
  object btnOk: TButton
    Left = 120
    Top = 56
    Width = 83
    Height = 25
    Caption = #27770#23450' (&O)'
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnClose: TButton
    Left = 208
    Top = 56
    Width = 65
    Height = 25
    Caption = #21462#28040' (&C)'
    TabOrder = 2
    OnClick = btnCloseClick
  end
end
