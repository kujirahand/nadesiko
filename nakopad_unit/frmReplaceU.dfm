object frmReplace: TfrmReplace
  Left = 352
  Top = 261
  BorderStyle = bsDialog
  Caption = #32622#25563
  ClientHeight = 108
  ClientWidth = 398
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 12
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 63
    Height = 12
    Caption = #26908#32034#35486#21477'(&F)'
  end
  object Label2: TLabel
    Left = 8
    Top = 40
    Width = 64
    Height = 12
    Caption = #32622#25563#35486#21477'(&R)'
  end
  object cmbFind: TComboBox
    Left = 80
    Top = 8
    Width = 225
    Height = 20
    AutoComplete = False
    ItemHeight = 12
    PopupMenu = PopupMenu1
    TabOrder = 0
  end
  object cmbReplace: TComboBox
    Left = 80
    Top = 40
    Width = 225
    Height = 20
    AutoComplete = False
    ItemHeight = 12
    PopupMenu = PopupMenu1
    TabOrder = 1
  end
  object btnFind: TButton
    Left = 312
    Top = 8
    Width = 75
    Height = 25
    Caption = #26908#32034'(&N)'
    TabOrder = 2
    OnClick = btnFindClick
  end
  object btnReplace: TButton
    Left = 312
    Top = 40
    Width = 75
    Height = 25
    Caption = #32622#25563'(&H)'
    TabOrder = 3
    OnClick = btnReplaceClick
  end
  object btnReplaceAll: TButton
    Left = 224
    Top = 72
    Width = 75
    Height = 25
    Caption = #20840#32622#25563'(&A)'
    TabOrder = 4
    OnClick = btnReplaceAllClick
  end
  object chkSelection: TCheckBox
    Left = 8
    Top = 72
    Width = 137
    Height = 17
    Caption = #36984#25246#31684#22258#12434#23550#35937#12392#12377#12427
    TabOrder = 5
  end
  object btnCancel: TButton
    Left = 312
    Top = 72
    Width = 75
    Height = 25
    Caption = #65399#65388#65437#65406#65433'(&C)'
    TabOrder = 6
    OnClick = btnCancelClick
  end
  object PopupMenu1: TPopupMenu
    Left = 192
    Top = 56
    object popCopy: TMenuItem
      Caption = #12467#12500#12540
      ShortCut = 16451
      OnClick = popCopyClick
    end
    object popCut: TMenuItem
      Caption = #20999#12426#21462#12426
      ShortCut = 16472
      OnClick = popCutClick
    end
    object popPaste: TMenuItem
      Caption = #36028#12426#20184#12369
      ShortCut = 16470
      OnClick = popPasteClick
    end
  end
end
