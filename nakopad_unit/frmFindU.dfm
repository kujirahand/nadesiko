object frmFind: TfrmFind
  Left = 393
  Top = 258
  BorderStyle = bsDialog
  Caption = #26908#32034#12480#12452#12450#12525#12464
  ClientHeight = 74
  ClientWidth = 352
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object Label1: TLabel
    Left = 7
    Top = 11
    Width = 41
    Height = 12
    Caption = #26908#32034'(&W)'
  end
  object cmbFind: TComboBox
    Left = 56
    Top = 8
    Width = 201
    Height = 20
    AutoComplete = False
    ItemHeight = 12
    PopupMenu = popupFind
    TabOrder = 0
    OnKeyPress = cmbFindKeyPress
  end
  object btnFind: TButton
    Left = 264
    Top = 8
    Width = 73
    Height = 25
    Caption = #26908#32034'(&F)'
    TabOrder = 1
    OnClick = btnFindClick
  end
  object btnClose: TButton
    Left = 264
    Top = 40
    Width = 73
    Height = 25
    Caption = #65399#65388#65437#65406#65433'(&C)'
    TabOrder = 2
    OnClick = btnCloseClick
  end
  object popupFind: TPopupMenu
    Left = 120
    Top = 24
    object popCopy: TMenuItem
      Caption = #12467#12500#12540'(&C)'
      ShortCut = 16451
      OnClick = popCopyClick
    end
    object popCut: TMenuItem
      Caption = #20999#12426#21462#12426'(&X)'
      ShortCut = 16472
      OnClick = popCutClick
    end
    object popPaste: TMenuItem
      Caption = #36028#12426#20184#12369'(&V)'
      ShortCut = 16470
      OnClick = popPasteClick
    end
  end
end
