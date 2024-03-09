object frmFirst: TfrmFirst
  Left = 192
  Top = 133
  Width = 432
  Height = 269
  BorderIcons = [biSystemMenu]
  Caption = #12394#12391#12375#12371#12398#12399#12376#12417#12395
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object Panel1: TPanel
    Left = 0
    Top = 194
    Width = 416
    Height = 37
    Align = alBottom
    TabOrder = 0
    object chkNoMore: TCheckBox
      Left = 8
      Top = 8
      Width = 121
      Height = 17
      Caption = #27425#22238#12399#34920#31034#12375#12394#12356
      TabOrder = 0
      OnClick = chkNoMoreClick
    end
  end
  object lstFirst: TListBox
    Left = 0
    Top = 0
    Width = 416
    Height = 194
    Style = lbOwnerDrawFixed
    Align = alClient
    ItemHeight = 25
    TabOrder = 1
    OnDblClick = lstFirstDblClick
    OnDrawItem = lstFirstDrawItem
  end
end
