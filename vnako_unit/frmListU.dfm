object frmList: TfrmList
  Left = 352
  Top = 243
  Width = 406
  Height = 325
  Caption = #32094#36796#12415#36984#25246
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 390
    Height = 30
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    OnResize = TopPanelResize
    object edtMain: TEdit
      Left = 4
      Top = 3
      Width = 329
      Height = 24
      BevelOuter = bvNone
      Font.Charset = SHIFTJIS_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnChange = edtMainChange
      OnKeyUp = edtMainKeyUp
    end
    object btnOk: TButton
      Left = 335
      Top = 3
      Width = 52
      Height = 23
      Caption = 'OK(&O)'
      TabOrder = 1
      OnClick = btnOkClick
    end
  end
  object lstItem: TListBox
    Left = 0
    Top = 30
    Width = 390
    Height = 257
    Align = alClient
    BevelInner = bvSpace
    BevelOuter = bvSpace
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = []
    ItemHeight = 16
    ParentFont = False
    TabOrder = 1
    OnDblClick = lstItemDblClick
    OnKeyDown = lstItemKeyDown
    OnKeyPress = lstItemKeyPress
  end
  object timerFocus: TTimer
    Enabled = False
    Interval = 100
    OnTimer = timerFocusTimer
    Left = 8
    Top = 40
  end
end
