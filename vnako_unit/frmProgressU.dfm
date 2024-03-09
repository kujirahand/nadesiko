object frmProgress: TfrmProgress
  Left = 192
  Top = 114
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = #32076#36942
  ClientHeight = 65
  ClientWidth = 329
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  object lblCaption: TLabel
    Left = 8
    Top = 8
    Width = 313
    Height = 12
    AutoSize = False
    Caption = '***'
  end
  object lblInfo: TLabel
    Left = 8
    Top = 48
    Width = 313
    Height = 12
    Alignment = taRightJustify
    AutoSize = False
    Caption = '-'
  end
  object prog: TProgressBar
    Left = 8
    Top = 24
    Width = 273
    Height = 17
    TabOrder = 0
  end
  object btnCalcel: TButton
    Left = 284
    Top = 22
    Width = 41
    Height = 20
    Caption = #20013#27490
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = btnCalcelClick
  end
end
