object frmExe: TfrmExe
  Left = 192
  Top = 132
  Width = 456
  Height = 290
  Caption = #20197#19979#12398#12450#12503#12522#12465#12540#12471#12519#12531#12434#32066#20102#12373#12379#12390#12367#12384#12373#12356#12290
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object lstExe: TListBox
    Left = 0
    Top = 0
    Width = 440
    Height = 212
    Align = alClient
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = []
    ItemHeight = 16
    ParentFont = False
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 212
    Width = 440
    Height = 41
    Align = alBottom
    TabOrder = 1
    object Button1: TButton
      Left = 312
      Top = 8
      Width = 115
      Height = 25
      Caption = #20966#29702#32153#32154
      TabOrder = 0
      OnClick = Button1Click
    end
    object btnKill: TButton
      Left = 232
      Top = 8
      Width = 67
      Height = 25
      Caption = #24375#21046#32066#20102
      TabOrder = 1
      OnClick = btnKillClick
    end
    object btnUpdate: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = #12522#12473#12488#26356#26032
      TabOrder = 2
      OnClick = btnUpdateClick
    end
  end
end
