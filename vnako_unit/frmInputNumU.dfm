object frmInputNum: TfrmInputNum
  Left = 224
  Top = 256
  BorderStyle = bsDialog
  Caption = #25968#20516#12420#24335#12398#20837#21147
  ClientHeight = 154
  ClientWidth = 452
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object lblInfo: TLabel
    Left = 8
    Top = 8
    Width = 165
    Height = 12
    Caption = #12354#12354#12354#12354#12354#12354#12354#12354#12354#12354#12354#12354#12354#12354#12354
  end
  object edtMain: TEdit
    Left = 8
    Top = 32
    Width = 361
    Height = 27
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = #65325#65331' '#12468#12471#12483#12463
    Font.Style = []
    ImeMode = imClose
    ParentFont = False
    TabOrder = 0
    Text = '777'
    OnKeyPress = edtMainKeyPress
  end
  object Panel1: TPanel
    Left = 8
    Top = 72
    Width = 433
    Height = 41
    BevelOuter = bvLowered
    TabOrder = 2
    object Button2: TButton
      Tag = 1
      Left = 8
      Top = 8
      Width = 25
      Height = 25
      Caption = '1'
      TabOrder = 1
      TabStop = False
      OnClick = BbtnNumClick
    end
    object Button3: TButton
      Tag = 2
      Left = 32
      Top = 8
      Width = 25
      Height = 25
      Caption = '2'
      TabOrder = 2
      TabStop = False
      OnClick = BbtnNumClick
    end
    object Button4: TButton
      Tag = 3
      Left = 56
      Top = 8
      Width = 25
      Height = 25
      Caption = '3'
      TabOrder = 3
      TabStop = False
      OnClick = BbtnNumClick
    end
    object Button5: TButton
      Tag = 4
      Left = 80
      Top = 8
      Width = 25
      Height = 25
      Caption = '4'
      TabOrder = 4
      TabStop = False
      OnClick = BbtnNumClick
    end
    object Button6: TButton
      Tag = 5
      Left = 104
      Top = 8
      Width = 25
      Height = 25
      Caption = '5'
      TabOrder = 5
      TabStop = False
      OnClick = BbtnNumClick
    end
    object Button7: TButton
      Tag = 6
      Left = 128
      Top = 8
      Width = 25
      Height = 25
      Caption = '6'
      TabOrder = 6
      TabStop = False
      OnClick = BbtnNumClick
    end
    object Button8: TButton
      Tag = 7
      Left = 152
      Top = 8
      Width = 25
      Height = 25
      Caption = '7'
      TabOrder = 7
      TabStop = False
      OnClick = BbtnNumClick
    end
    object Button9: TButton
      Tag = 8
      Left = 176
      Top = 8
      Width = 25
      Height = 25
      Caption = '8'
      TabOrder = 8
      TabStop = False
      OnClick = BbtnNumClick
    end
    object Button10: TButton
      Tag = 9
      Left = 200
      Top = 8
      Width = 25
      Height = 25
      Caption = '9'
      TabOrder = 9
      TabStop = False
      OnClick = BbtnNumClick
    end
    object btnPlus: TButton
      Left = 256
      Top = 8
      Width = 25
      Height = 25
      Caption = #65291
      TabOrder = 10
      TabStop = False
      OnClick = BbtnNumClick
    end
    object btnMinus: TButton
      Left = 280
      Top = 8
      Width = 25
      Height = 25
      Caption = #65293
      TabOrder = 11
      TabStop = False
      OnClick = BbtnNumClick
    end
    object btnMul: TButton
      Left = 304
      Top = 8
      Width = 25
      Height = 25
      Caption = #215
      TabOrder = 12
      TabStop = False
      OnClick = BbtnNumClick
    end
    object btnDiv: TButton
      Left = 328
      Top = 8
      Width = 25
      Height = 25
      Caption = #247
      TabOrder = 13
      TabStop = False
      OnClick = BbtnNumClick
    end
    object btnMod: TButton
      Left = 352
      Top = 8
      Width = 25
      Height = 25
      Caption = #65285
      TabOrder = 15
      TabStop = False
      OnClick = BbtnNumClick
    end
    object btnEq: TButton
      Left = 376
      Top = 8
      Width = 25
      Height = 25
      Caption = #65309
      TabOrder = 14
      TabStop = False
      OnClick = btnCalcClick
    end
    object Button1: TButton
      Left = 224
      Top = 8
      Width = 25
      Height = 25
      Caption = '0'
      TabOrder = 0
      TabStop = False
      OnClick = BbtnNumClick
    end
  end
  object btnOk: TButton
    Left = 256
    Top = 120
    Width = 121
    Height = 25
    Caption = #27770#23450' (&O)'
    TabOrder = 3
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 384
    Top = 120
    Width = 59
    Height = 25
    Caption = #21462#28040'(&C)'
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object btnUp: TButton
    Left = 370
    Top = 24
    Width = 23
    Height = 21
    Caption = #9650
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    TabStop = False
    OnClick = btnUpClick
  end
  object btnHint: TButton
    Left = 8
    Top = 120
    Width = 25
    Height = 25
    Caption = '?'
    TabOrder = 7
    OnClick = btnHintClick
  end
  object btnDown: TButton
    Left = 370
    Top = 44
    Width = 23
    Height = 21
    Caption = #9660
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    TabStop = False
    OnClick = btnDownClick
  end
  object btnCalc: TButton
    Left = 392
    Top = 24
    Width = 49
    Height = 41
    Caption = #35336#31639'(&C)'
    TabOrder = 1
    OnClick = btnCalcClick
  end
  object btnClear: TButton
    Left = 408
    Top = 80
    Width = 25
    Height = 25
    Hint = #25968#20516#12420#24335#12434#12463#12522#12450#12375#12414#12377
    Caption = #65315
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
    TabStop = False
    OnClick = btnClearClick
  end
end
