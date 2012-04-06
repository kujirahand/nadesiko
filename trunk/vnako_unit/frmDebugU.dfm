object frmDebug: TfrmDebug
  Left = 196
  Top = 130
  Caption = #12487#12496#12483#12464
  ClientHeight = 319
  ClientWidth = 433
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
  object Splitter1: TSplitter
    Left = 0
    Top = 185
    Width = 433
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  object panelBottom: TPanel
    Left = 0
    Top = 278
    Width = 433
    Height = 41
    Align = alBottom
    TabOrder = 0
    OnResize = panelBottomResize
    object btnContinue: TButton
      Left = 120
      Top = 8
      Width = 99
      Height = 25
      Caption = #32154#12369#12427'(&C)'
      TabOrder = 0
      OnClick = btnContinueClick
    end
    object btnStep: TButton
      Left = 8
      Top = 8
      Width = 99
      Height = 25
      Caption = #12473#12486#12483#12503#23455#34892'(&E)'
      TabOrder = 1
      OnClick = btnStepClick
    end
    object btnClose: TButton
      Left = 328
      Top = 8
      Width = 97
      Height = 25
      Caption = #32066#20102'(&O)'
      TabOrder = 2
      OnClick = btnCloseClick
    end
  end
  object grdVar: TStringGrid
    Left = 0
    Top = 33
    Width = 433
    Height = 152
    Align = alTop
    ColCount = 3
    DefaultColWidth = 128
    DefaultRowHeight = 20
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect]
    PopupMenu = popDebug
    TabOrder = 1
    OnDblClick = grdVarDblClick
    ColWidths = (
      128
      77
      397)
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 433
    Height = 33
    Align = alTop
    TabOrder = 2
    object Label1: TLabel
      Left = 8
      Top = 11
      Width = 39
      Height = 12
      Caption = #26908#32034'(&F)'
    end
    object edtFind: TEdit
      Left = 56
      Top = 8
      Width = 161
      Height = 20
      TabOrder = 0
    end
    object btnFind: TButton
      Left = 219
      Top = 9
      Width = 33
      Height = 17
      Caption = #26908#32034
      TabOrder = 1
      OnClick = btnFindClick
    end
    object chkViewLineNo: TCheckBox
      Left = 264
      Top = 8
      Width = 153
      Height = 17
      Caption = #12456#12487#12451#12479#12398#23455#34892#34892#12434#34920#31034
      TabOrder = 2
      OnClick = chkViewLineNoClick
    end
  end
  object panelSrc: TPanel
    Left = 0
    Top = 188
    Width = 433
    Height = 90
    Align = alClient
    TabOrder = 3
    object Panel4: TPanel
      Left = 1
      Top = 1
      Width = 431
      Height = 19
      Align = alTop
      BevelOuter = bvLowered
      TabOrder = 0
      object lblInfo: TLabel
        Left = 6
        Top = 4
        Width = 18
        Height = 12
        Caption = '***'
        Color = clBtnFace
        Font.Charset = SHIFTJIS_CHARSET
        Font.Color = clBtnText
        Font.Height = -12
        Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Transparent = True
        OnClick = lblInfoClick
      end
    end
    object panelSrcEdit: TPanel
      Left = 1
      Top = 20
      Width = 431
      Height = 69
      Align = alClient
      BevelOuter = bvNone
      Caption = 's'
      TabOrder = 1
    end
  end
  object popDebug: TPopupMenu
    Left = 200
    Top = 152
    object N1: TMenuItem
      Caption = #12456#12487#12451#12479#12395#34920#31034'(&E)'
    end
  end
  object MainMenu1: TMainMenu
    Left = 232
    Top = 152
    object E1: TMenuItem
      Caption = #35413#20385'(&E)'
      object mnuEval: TMenuItem
        Caption = #24335#12434#35413#20385#12377#12427'(&E)'
        OnClick = mnuEvalClick
      end
    end
    object S1: TMenuItem
      Caption = #34920#31034#12473#12467#12540#12503'(&S)'
      object mnuScopeLocal: TMenuItem
        Caption = #12525#12540#12459#12523#12473#12467#12540#12503
        OnClick = mnuScopeLocalClick
      end
      object mnuScopeGlobal: TMenuItem
        Caption = #12464#12525#12540#12496#12523#12473#12467#12540#12503
        OnClick = mnuScopeGlobalClick
      end
      object mnuScopeUser: TMenuItem
        Caption = #12518#12540#12470#12540#12473#12467#12540#12503
        OnClick = mnuScopeUserClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mnuScopeGlobalLocal: TMenuItem
        Caption = #12377#12409#12390#12398#12473#12467#12540#12503
        OnClick = mnuScopeGlobalLocalClick
      end
    end
    object T1: TMenuItem
      Caption = #31278#39006'(&T)'
      object mnuEnumFunc: TMenuItem
        Caption = #38306#25968#12434#21015#25369
        OnClick = mnuEnumFuncClick
      end
      object mnuEnumGroup: TMenuItem
        Caption = #12464#12523#12540#12503#12434#21015#25369
        OnClick = mnuEnumGroupClick
      end
      object mnuEnumVar: TMenuItem
        Caption = #22793#25968#12434#21015#25369
        Checked = True
        OnClick = mnuEnumVarClick
      end
    end
  end
end
