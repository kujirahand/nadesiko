object frmInputList: TfrmInputList
  Left = 192
  Top = 114
  Caption = #38917#30446#35352#20837
  ClientHeight = 291
  ClientWidth = 451
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDefault
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object panelBase: TPanel
    Left = 0
    Top = 250
    Width = 451
    Height = 41
    Align = alBottom
    TabOrder = 0
    OnResize = panelBaseResize
    object panelBtn: TPanel
      Left = 280
      Top = 5
      Width = 177
      Height = 34
      BevelOuter = bvNone
      TabOrder = 0
      object btnOk: TButton
        Left = 6
        Top = 3
        Width = 99
        Height = 25
        Caption = #27770#23450' (&O)'
        TabOrder = 0
        OnClick = btnOkClick
      end
      object btnClose: TButton
        Left = 112
        Top = 3
        Width = 57
        Height = 25
        Caption = #21462#28040' (&C)'
        TabOrder = 1
        OnClick = btnCloseClick
      end
    end
  end
  object veList: TValueListEditor
    Left = 0
    Top = 0
    Width = 451
    Height = 250
    Align = alClient
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #65325#65331' '#12468#12471#12483#12463
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnDrawCell = veListDrawCell
    OnEditButtonClick = veListEditButtonClick
    OnEnter = veListEnter
    OnExit = veListExit
    OnKeyPress = veListKeyPress
    OnKeyUp = veListKeyUp
    OnMouseDown = veListMouseDown
    OnSelectCell = veListSelectCell
    ColWidths = (
      150
      295)
  end
  object dlgOpen: TOpenDialog
    Left = 48
    Top = 40
  end
  object dlgColor: TColorDialog
    Left = 80
    Top = 40
  end
  object MainMenu1: TMainMenu
    Left = 144
    Top = 40
    object F1: TMenuItem
      Caption = #12501#12449#12452#12523'(&F)'
      object mnuReset: TMenuItem
        Caption = #21021#26399#21270'(&N)'
        ShortCut = 16462
        OnClick = mnuResetClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mnuOpen: TMenuItem
        Caption = #38283#12367'(&O)'
        ShortCut = 16463
        OnClick = mnuOpenClick
      end
      object mnuSave: TMenuItem
        Caption = #20445#23384'(&S)'
        ShortCut = 16467
        OnClick = mnuSaveClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mnuCopyAsText: TMenuItem
        Caption = #38917#30446#19968#35239#12434#12486#12461#12473#12488#12392#12375#12390#12467#12500#12540
        ShortCut = 16466
        OnClick = mnuCopyAsTextClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object C1: TMenuItem
        Caption = #38281#12376#12427'(&C)'
        OnClick = C1Click
      end
    end
  end
  object dlgSave: TSaveDialog
    Left = 112
    Top = 40
  end
end
