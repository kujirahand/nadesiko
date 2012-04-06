object frmInput: TfrmInput
  Left = 192
  Top = 114
  BorderStyle = bsDialog
  Caption = #36074#21839
  ClientHeight = 105
  ClientWidth = 385
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 12
  object lblCaption: TLabel
    Left = 8
    Top = 8
    Width = 265
    Height = 12
    Caption = #12354#12356#12358#12360#12362#12363#12365#12367#12369#12371#12373#12375#12377#12379#12381#12383#12385#12388#12390#12392#12394#12395#12396#12397#12398
  end
  object edtMain: TEdit
    Left = 8
    Top = 40
    Width = 369
    Height = 23
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #65325#65331' '#12468#12471#12483#12463
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnKeyPress = edtMainKeyPress
  end
  object Panel1: TPanel
    Left = 0
    Top = 73
    Width = 385
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Panel2: TPanel
      Left = 160
      Top = 0
      Width = 217
      Height = 33
      BevelOuter = bvNone
      TabOrder = 0
      object btnOK: TButton
        Left = 6
        Top = 0
        Width = 107
        Height = 25
        Caption = #27770#23450'(&O)'
        TabOrder = 0
        OnClick = btnOKClick
      end
      object btnCancel: TButton
        Left = 126
        Top = 0
        Width = 75
        Height = 25
        Caption = #21462#28040'(&C)'
        TabOrder = 1
        OnClick = btnCancelClick
      end
    end
  end
  object timerLimit: TTimer
    Enabled = False
    OnTimer = timerLimitTimer
    Left = 184
    Top = 56
  end
end
