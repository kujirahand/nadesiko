object frmNakopad: TfrmNakopad
  Left = 198
  Top = 138
  Width = 823
  Height = 574
  Caption = 'frmNakopad'
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  Menu = mnusMain
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object splitPanel: TSplitter
    Left = 217
    Top = 29
    Height = 467
  end
  object pageLeft: TPageControl
    Left = 0
    Top = 29
    Width = 217
    Height = 467
    ActivePage = sheetAction
    Align = alLeft
    MultiLine = True
    TabOrder = 0
    OnChange = pageLeftChange
    OnChanging = pageLeftChanging
    object sheetAction: TTabSheet
      Caption = #34892#21205
      object panelActionBody: TPanel
        Left = 0
        Top = 0
        Width = 209
        Height = 423
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object splitterActPanel: TSplitter
          Left = 0
          Top = 264
          Width = 209
          Height = 3
          Cursor = crVSplit
          Align = alTop
        end
        object lstAction: TListBox
          Left = 0
          Top = 0
          Width = 209
          Height = 264
          Style = lbOwnerDrawFixed
          Align = alTop
          ItemHeight = 16
          TabOrder = 0
          OnClick = lstActionClick
          OnDblClick = lstActionDblClick
          OnDrawItem = lstActionDrawItem
        end
        object webAction: TUIWebBrowser
          Left = 0
          Top = 267
          Width = 209
          Height = 156
          Align = alClient
          TabOrder = 1
          IeNoContext = False
          IeNO3DBORDER = False
          IeSCROLL_hidden = False
          IeDontSCRIPT = False
          IeEnableAccelerator = True
          IeNoBehavior = False
          IeAutoComplete = False
          DownLoadControl = [CS_Images, CS_Videos, CS_BGSounds]
          ControlData = {
            4C0000009A150000201000000000000000000000000000000000000000000000
            000000004C000000000000000000000001000000E0D057007335CF11AE690800
            2B2E12620A000000000000004C0000000114020000000000C000000000000046
            8000000000000000000000000000000000000000000000000000000000000000
            00000000000000000100000000000000000000000000000000000000}
        end
      end
    end
    object sheetFind: TTabSheet
      Caption = #26908#32034
      ImageIndex = 1
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 209
        Height = 423
        Align = alClient
        BevelOuter = bvLowered
        TabOrder = 0
        object Panel3: TPanel
          Left = 1
          Top = 1
          Width = 207
          Height = 96
          Align = alTop
          TabOrder = 0
          object cmbFind: TComboBox
            Left = 8
            Top = 8
            Width = 193
            Height = 20
            AutoComplete = False
            ItemHeight = 0
            PopupMenu = popFind
            TabOrder = 0
            OnEnter = cmbFindEnter
            OnKeyPress = cmbFindKeyPress
          end
          object btnFind: TButton
            Left = 8
            Top = 30
            Width = 57
            Height = 19
            Caption = #26908#32034'(&F)'
            TabOrder = 1
            OnClick = btnFindClick
          end
          object chkFindTop: TCheckBox
            Left = 8
            Top = 56
            Width = 185
            Height = 17
            Caption = #34892#38957#12363#12425#22987#12414#12427#12418#12398
            TabOrder = 2
          end
          object btnFindSort: TButton
            Left = 72
            Top = 30
            Width = 57
            Height = 19
            Caption = #20006#26367'(&S)'
            TabOrder = 3
            OnClick = btnFindSortClick
          end
          object chkFindZenHan: TCheckBox
            Left = 8
            Top = 72
            Width = 193
            Height = 17
            Caption = #20840#35282#21322#35282#12434#21306#21029#12377#12427
            TabOrder = 4
          end
        end
        object lstFind: TListBox
          Left = 1
          Top = 97
          Width = 207
          Height = 325
          Style = lbOwnerDrawFixed
          Align = alClient
          ItemHeight = 16
          PopupMenu = popListFind
          TabOrder = 1
          OnDblClick = lstFindDblClick
          OnDrawItem = lstFindDrawItem
        end
      end
    end
    object sheetGroup: TTabSheet
      Caption = #65400#65438#65433#65392#65420#65439
      ImageIndex = 2
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 209
        Height = 423
        Align = alClient
        BevelOuter = bvLowered
        TabOrder = 0
        object Panel5: TPanel
          Left = 1
          Top = 1
          Width = 207
          Height = 80
          Align = alTop
          TabOrder = 0
          object btnGroupEnum: TButton
            Left = 8
            Top = 32
            Width = 57
            Height = 17
            Caption = #21015#25369'(&E)'
            TabOrder = 0
            OnClick = btnGroupEnumClick
          end
          object chkGroupInclude: TCheckBox
            Left = 8
            Top = 56
            Width = 193
            Height = 17
            Caption = #21462#12426#36796#12416#12501#12449#12452#12523#12418#26908#32034#12377#12427
            Checked = True
            State = cbChecked
            TabOrder = 1
          end
          object cmbGroup: TComboBox
            Left = 8
            Top = 8
            Width = 193
            Height = 20
            AutoComplete = False
            ItemHeight = 0
            PopupMenu = popFind
            TabOrder = 2
            OnEnter = cmbGroupEnter
            OnKeyPress = cmbGroupKeyPress
          end
          object btnGroupSort: TButton
            Left = 72
            Top = 32
            Width = 57
            Height = 17
            Caption = #20006#26367'(&S)'
            TabOrder = 3
            OnClick = btnGroupSortClick
          end
        end
        object Panel6: TPanel
          Left = 1
          Top = 81
          Width = 207
          Height = 341
          Align = alClient
          TabOrder = 1
          object Splitter1: TSplitter
            Left = 1
            Top = 89
            Width = 205
            Height = 3
            Cursor = crVSplit
            Align = alTop
          end
          object lstGroup: TListBox
            Left = 1
            Top = 1
            Width = 205
            Height = 88
            Style = lbOwnerDrawFixed
            Align = alTop
            DragMode = dmAutomatic
            ItemHeight = 16
            PopupMenu = popTabList
            TabOrder = 0
            OnClick = lstGroupClick
            OnDblClick = lstGroupDblClick
            OnDrawItem = lstFindDrawItem
          end
          object lstMember: TListBox
            Tag = 1
            Left = 1
            Top = 92
            Width = 205
            Height = 219
            Style = lbOwnerDrawVariable
            Align = alClient
            DragMode = dmAutomatic
            ItemHeight = 16
            PopupMenu = popTabList
            TabOrder = 1
            OnDblClick = lstMemberDblClick
            OnDrawItem = lstFindDrawItem
            OnKeyDown = lstMemberKeyDown
          end
          object pnlGroupFilter: TPanel
            Left = 1
            Top = 311
            Width = 205
            Height = 29
            Align = alBottom
            BevelOuter = bvLowered
            TabOrder = 2
            OnResize = pnlGroupFilterResize
            object Label1: TLabel
              Left = 8
              Top = 8
              Width = 47
              Height = 12
              Caption = #32094#36796#12415'(&I)'
              FocusControl = edtGroupFilter
            end
            object edtGroupFilter: TEdit
              Left = 58
              Top = 4
              Width = 117
              Height = 20
              TabOrder = 0
              OnChange = edtGroupFilterChange
              OnKeyPress = edtGroupFilterKeyPress
            end
          end
        end
      end
    end
    object sheetTree: TTabSheet
      Caption = #21629#20196#19968#35239
      ImageIndex = 5
      object Splitter3: TSplitter
        Left = 0
        Top = 201
        Width = 209
        Height = 3
        Cursor = crVSplit
        Align = alTop
      end
      object treeCmd: TTreeView
        Left = 0
        Top = 0
        Width = 209
        Height = 201
        Align = alTop
        Images = imgsTab
        Indent = 19
        ReadOnly = True
        TabOrder = 0
        OnClick = treeCmdClick
        OnKeyPress = treeCmdKeyPress
      end
      object viewCmd: TListView
        Left = 0
        Top = 204
        Width = 209
        Height = 219
        Align = alClient
        Columns = <>
        DragMode = dmAutomatic
        LargeImages = imgsTab
        ReadOnly = True
        PopupMenu = popCmd
        TabOrder = 1
        OnClick = viewCmdClick
        OnDblClick = viewCmdDblClick
        OnKeyDown = viewCmdKeyDown
      end
    end
    object sheetCmd: TTabSheet
      Caption = #21629#20196#26908#32034
      ImageIndex = 3
      object Panel7: TPanel
        Left = 0
        Top = 0
        Width = 209
        Height = 423
        Align = alClient
        BevelOuter = bvLowered
        TabOrder = 0
        object Splitter6: TSplitter
          Left = 1
          Top = 348
          Width = 207
          Height = 3
          Cursor = crVSplit
          Align = alBottom
        end
        object Panel8: TPanel
          Left = 1
          Top = 1
          Width = 207
          Height = 67
          Align = alTop
          TabOrder = 0
          object btnCmdEnum: TButton
            Left = 8
            Top = 32
            Width = 57
            Height = 17
            Caption = #21015#25369'(&E)'
            TabOrder = 0
            OnClick = btnCmdEnumClick
          end
          object chkCmdWildcard: TCheckBox
            Left = 72
            Top = 32
            Width = 121
            Height = 17
            Caption = #12527#12452#12523#12489#12459#12540#12489#26908#32034
            TabOrder = 1
          end
          object cmbCmd: TComboBox
            Left = 8
            Top = 8
            Width = 193
            Height = 20
            AutoComplete = False
            ItemHeight = 0
            PopupMenu = popFind
            TabOrder = 2
            OnEnter = cmbCmdEnter
            OnKeyPress = cmbCmdKeyPress
          end
          object chkCmdDescript: TCheckBox
            Left = 72
            Top = 48
            Width = 121
            Height = 17
            Caption = #35299#35500#25991#12418#26908#32034#12377#12427
            TabOrder = 3
          end
        end
        object lstCmd: TListBox
          Left = 1
          Top = 68
          Width = 207
          Height = 280
          Style = lbOwnerDrawVariable
          Align = alClient
          DragMode = dmAutomatic
          ItemHeight = 16
          PopupMenu = popCmd
          TabOrder = 1
          OnClick = lstCmdClick
          OnDblClick = lstCmdDblClick
          OnDrawItem = lstFindDrawItem
          OnKeyPress = lstCmdKeyPress
        end
        object Panel13: TPanel
          Left = 1
          Top = 351
          Width = 207
          Height = 71
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 2
          object Panel14: TPanel
            Left = 0
            Top = 54
            Width = 207
            Height = 17
            Align = alBottom
            BevelOuter = bvLowered
            TabOrder = 0
            object lblLinkToWebMan: TLabel
              Left = 4
              Top = 5
              Width = 75
              Height = 11
              Cursor = crHandPoint
              Caption = 'Web'#12391#35443#12375#12367#35211#12427
              Font.Charset = SHIFTJIS_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
              Font.Style = [fsUnderline]
              ParentFont = False
              OnClick = lblLinkToWebManClick
            end
            object lblLinkToLocalMan: TLabel
              Left = 90
              Top = 5
              Width = 97
              Height = 11
              Cursor = crHandPoint
              Caption = #12525#12540#12459#12523#12391#35443#12375#12367#35211#12427
              Font.Charset = SHIFTJIS_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
              Font.Style = [fsUnderline]
              ParentFont = False
              OnClick = lblLinkToLocalManClick
            end
          end
          object memCommand: TRichEdit
            Left = 0
            Top = 0
            Width = 207
            Height = 54
            Align = alClient
            Color = clInfoBk
            PlainText = True
            ReadOnly = True
            ScrollBars = ssVertical
            TabOrder = 1
          end
        end
      end
    end
    object sheetVar: TTabSheet
      Caption = #22793#25968#38306#25968
      ImageIndex = 4
      object Panel9: TPanel
        Left = 0
        Top = 0
        Width = 209
        Height = 81
        Align = alTop
        BevelOuter = bvLowered
        TabOrder = 0
        object btnVarEnum: TButton
          Left = 8
          Top = 32
          Width = 57
          Height = 17
          Caption = #22793#25968#21015#25369
          TabOrder = 0
          OnClick = btnVarEnumClick
        end
        object cmbVar: TComboBox
          Left = 8
          Top = 8
          Width = 193
          Height = 20
          AutoComplete = False
          ItemHeight = 0
          PopupMenu = popFind
          TabOrder = 1
          OnEnter = cmbVarEnter
        end
        object btnVarSort: TButton
          Left = 72
          Top = 32
          Width = 57
          Height = 17
          Caption = #20006#26367'(&S)'
          TabOrder = 2
          OnClick = btnVarSortClick
        end
        object chkVarLocal: TCheckBox
          Left = 8
          Top = 56
          Width = 129
          Height = 17
          Caption = #12525#12540#12459#12523#22793#25968#12418#21015#25369
          Checked = True
          State = cbChecked
          TabOrder = 3
        end
        object btnFuncEnum: TButton
          Left = 136
          Top = 32
          Width = 57
          Height = 19
          Caption = #38306#25968#21015#25369
          TabOrder = 4
          OnClick = btnFuncEnumClick
        end
        object btnVarClear: TButton
          Left = 152
          Top = 56
          Width = 41
          Height = 17
          Caption = #12463#12522#12450
          TabOrder = 5
          OnClick = btnVarClearClick
        end
      end
      object lstVar: TListBox
        Left = 0
        Top = 81
        Width = 209
        Height = 342
        Style = lbOwnerDrawFixed
        Align = alClient
        DragMode = dmAutomatic
        ItemHeight = 16
        PopupMenu = popTabList
        TabOrder = 1
        OnDblClick = lstVarDblClick
        OnDrawItem = lstFindDrawItem
      end
    end
    object sheetGui: TTabSheet
      Caption = 'GUI'
      ImageIndex = 6
      object panelGUI: TPanel
        Left = 0
        Top = 33
        Width = 209
        Height = 390
        Align = alClient
        TabOrder = 0
        object Splitter4: TSplitter
          Left = 1
          Top = 105
          Width = 207
          Height = 3
          Cursor = crVSplit
          Align = alTop
        end
        object lstGuiType: TListBox
          Left = 1
          Top = 1
          Width = 207
          Height = 104
          Align = alTop
          ItemHeight = 12
          TabOrder = 0
          OnClick = lstGuiTypeClick
        end
        object lstGuiProperty: TListBox
          Left = 1
          Top = 108
          Width = 207
          Height = 281
          Style = lbOwnerDrawFixed
          Align = alClient
          DragMode = dmAutomatic
          ItemHeight = 14
          TabOrder = 1
          OnClick = lstGuiPropertyClick
          OnDblClick = lstGuiPropertyDblClick
          OnDrawItem = lstGuiPropertyDrawItem
        end
      end
      object panelGuiTop: TPanel
        Left = 0
        Top = 0
        Width = 209
        Height = 33
        Align = alTop
        BevelOuter = bvLowered
        TabOrder = 1
        OnResize = panelGuiTopResize
        object edtGuiFind: TEdit
          Left = 8
          Top = 8
          Width = 193
          Height = 20
          PopupMenu = popGUIFind
          TabOrder = 0
          OnChange = edtGuiFindChange
        end
      end
    end
    object sheetDesignProp: TTabSheet
      Caption = #65411#65438#65403#65438#65394#65437
      ImageIndex = 7
      object Panel10: TPanel
        Left = 0
        Top = 0
        Width = 209
        Height = 423
        Align = alClient
        BevelOuter = bvLowered
        TabOrder = 0
        object Panel12: TPanel
          Left = 1
          Top = 1
          Width = 207
          Height = 32
          Align = alTop
          TabOrder = 0
          OnResize = Panel12Resize
          object cmbParts: TComboBox
            Left = 5
            Top = 5
            Width = 196
            Height = 22
            AutoComplete = False
            Style = csOwnerDrawFixed
            ItemHeight = 16
            TabOrder = 0
            OnChange = cmbPartsChange
          end
        end
        object propGui: TValueListEditor
          Left = 1
          Top = 33
          Width = 207
          Height = 389
          Align = alClient
          TabOrder = 1
          OnEditButtonClick = propGuiEditButtonClick
          OnGetEditText = propGuiGetEditText
          OnKeyPress = propGuiKeyPress
          OnSelectCell = propGuiSelectCell
          ColWidths = (
            110
            91)
        end
      end
    end
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 807
    Height = 29
    ButtonHeight = 26
    ButtonWidth = 27
    Caption = 'ToolBar1'
    EdgeBorders = [ebBottom]
    Flat = True
    Images = imgsMain
    TabOrder = 1
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Caption = 'ToolButton1'
      ImageIndex = 0
      OnClick = mnuNewClick
    end
    object toolOpenRecent: TToolButton
      Left = 27
      Top = 0
      Caption = 'toolOpenRecent'
      DropdownMenu = popRecent
      ImageIndex = 1
      Style = tbsDropDown
      OnClick = mnuOpenClick
    end
    object ToolButton3: TToolButton
      Left = 71
      Top = 0
      Caption = 'ToolButton3'
      ImageIndex = 2
      OnClick = mnuSaveClick
    end
    object ToolButton4: TToolButton
      Left = 98
      Top = 0
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 3
      Style = tbsSeparator
    end
    object ToolButton5: TToolButton
      Left = 106
      Top = 0
      Caption = 'ToolButton5'
      ImageIndex = 3
      OnClick = mnuUndoClick
    end
    object ToolButton13: TToolButton
      Left = 133
      Top = 0
      Width = 8
      Caption = 'ToolButton13'
      ImageIndex = 10
      Style = tbsSeparator
    end
    object ToolButton6: TToolButton
      Left = 141
      Top = 0
      Caption = 'ToolButton6'
      ImageIndex = 4
      OnClick = mnuCutClick
    end
    object ToolButton7: TToolButton
      Left = 168
      Top = 0
      Caption = 'ToolButton7'
      ImageIndex = 5
      OnClick = mnuCopyClick
    end
    object ToolButton8: TToolButton
      Left = 195
      Top = 0
      Caption = 'ToolButton8'
      ImageIndex = 6
      OnClick = mnuPasteClick
    end
    object ToolButton9: TToolButton
      Left = 222
      Top = 0
      Width = 9
      Caption = 'ToolButton9'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object toolRun: TToolButton
      Left = 231
      Top = 0
      Caption = 'toolRun'
      ImageIndex = 7
      OnClick = mnuRunClick
    end
    object toolStop: TToolButton
      Left = 258
      Top = 0
      Caption = 'toolStop'
      ImageIndex = 8
      OnClick = mnuStopClick
    end
    object toolPause: TToolButton
      Left = 285
      Top = 0
      Caption = 'toolPause'
      ImageIndex = 9
      OnClick = mnuPauseClick
    end
    object ToolButton14: TToolButton
      Left = 312
      Top = 0
      Width = 8
      Caption = 'ToolButton14'
      ImageIndex = 10
      Style = tbsSeparator
    end
  end
  object Status: TStatusBar
    Left = 0
    Top = 496
    Width = 807
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 90
      end
      item
        Width = 640
      end>
    PopupMenu = popupStatus
    OnClick = StatusClick
    OnDblClick = StatusDblClick
  end
  object tabsMain: TTabControl
    Left = 220
    Top = 29
    Width = 587
    Height = 467
    Align = alClient
    Style = tsFlatButtons
    TabOrder = 3
    Tabs.Strings = (
      'FILE1'
      'FILE2'
      'FILE3')
    TabIndex = 0
    OnDrawTab = tabsMainDrawTab
    object pageMain: TPageControl
      Left = 4
      Top = 26
      Width = 579
      Height = 437
      ActivePage = tabSource
      Align = alClient
      TabOrder = 0
      TabPosition = tpBottom
      OnChange = pageMainChange
      object tabSource: TTabSheet
        Caption = #12477#12540#12473
        object splitEdit: TSplitter
          Left = 0
          Top = 0
          Width = 571
          Height = 2
          Cursor = crVSplit
          Align = alTop
        end
        object splitLR: TSplitter
          Left = 3
          Top = 2
          Height = 410
        end
        object edtA: TEditorEx
          Left = 0
          Top = 2
          Width = 571
          Height = 0
          Cursor = crIBeam
          Align = alTop
          Caret.AutoCursor = True
          Caret.AutoIndent = True
          Caret.BackSpaceUnIndent = True
          Caret.Cursors.DefaultCursor = crIBeam
          Caret.Cursors.DragSelCursor = crDrag
          Caret.Cursors.DragSelCopyCursor = 1959
          Caret.Cursors.InSelCursor = crDefault
          Caret.Cursors.LeftMarginCursor = 1958
          Caret.Cursors.TopMarginCursor = crDefault
          Caret.FreeCaret = True
          Caret.FreeRow = False
          Caret.InTab = False
          Caret.KeepCaret = False
          Caret.LockScroll = False
          Caret.NextLine = False
          Caret.PrevSpaceIndent = False
          Caret.RowSelect = True
          Caret.SelDragMode = dmManual
          Caret.SelMove = True
          Caret.SoftTab = False
          Caret.Style = csDefault
          Caret.TabIndent = False
          Caret.TabSpaceCount = 8
          Caret.TokenEndStop = False
          Font.Charset = SHIFTJIS_CHARSET
          Font.Color = clBlack
          Font.Height = -12
          Font.Name = 'FixedSys'
          Font.Style = []
          HitStyle = hsSelect
          Imagebar.DigitWidth = 8
          Imagebar.LeftMargin = 2
          Imagebar.MarkWidth = 0
          Imagebar.RightMargin = 2
          Imagebar.Visible = True
          Lines.Strings = (
            'edtA')
          Marks.EofMark.Color = clGray
          Marks.EofMark.Visible = False
          Marks.RetMark.Color = clGray
          Marks.RetMark.Visible = False
          Marks.WrapMark.Color = clGray
          Marks.WrapMark.Visible = False
          Marks.HideMark.Color = clGray
          Marks.HideMark.Visible = False
          Marks.Underline.Color = clGray
          Marks.Underline.Visible = False
          Margin.Character = 0
          Margin.Left = 19
          Margin.Line = 0
          Margin.Top = 2
          Leftbar.BkColor = clSilver
          Leftbar.Color = clBlack
          Leftbar.Column = 4
          Leftbar.Edge = True
          Leftbar.LeftMargin = 8
          Leftbar.RightMargin = 4
          Leftbar.ShowNumber = True
          Leftbar.ShowNumberMode = nmRow
          Leftbar.Visible = False
          Leftbar.ZeroBase = False
          Leftbar.ZeroLead = False
          PopupMenu = popupMain
          ReadOnly = False
          Ruler.BkColor = clSilver
          Ruler.Color = clBlack
          Ruler.Edge = True
          Ruler.GaugeRange = 10
          Ruler.MarkColor = clBlack
          Ruler.Visible = False
          ScrollBars = ssNone
          Speed.CaretVerticalAc = 2
          Speed.InitBracketsFull = False
          Speed.PageVerticalRange = 2
          Speed.PageVerticalRangeAc = 2
          TabOrder = 0
          UndoListMax = 64
          View.Brackets = <>
          View.Colors.Ank.BkColor = clNone
          View.Colors.Ank.Color = clNone
          View.Colors.Ank.Style = []
          View.Colors.Comment.BkColor = clNone
          View.Colors.Comment.Color = clNone
          View.Colors.Comment.Style = []
          View.Colors.DBCS.BkColor = clNone
          View.Colors.DBCS.Color = clNone
          View.Colors.DBCS.Style = []
          View.Colors.Hit.BkColor = clNone
          View.Colors.Hit.Color = clNone
          View.Colors.Hit.Style = []
          View.Colors.Int.BkColor = clNone
          View.Colors.Int.Color = clNone
          View.Colors.Int.Style = []
          View.Colors.Mail.BkColor = clNone
          View.Colors.Mail.Color = clNone
          View.Colors.Mail.Style = []
          View.Colors.Reserve.BkColor = clNone
          View.Colors.Reserve.Color = clNone
          View.Colors.Reserve.Style = []
          View.Colors.Select.BkColor = clNavy
          View.Colors.Select.Color = clWhite
          View.Colors.Select.Style = []
          View.Colors.Str.BkColor = clNone
          View.Colors.Str.Color = clNone
          View.Colors.Str.Style = []
          View.Colors.Symbol.BkColor = clNone
          View.Colors.Symbol.Color = clNone
          View.Colors.Symbol.Style = []
          View.Colors.Url.BkColor = clNone
          View.Colors.Url.Color = clNone
          View.Colors.Url.Style = []
          View.ControlCode = False
          View.Mail = False
          View.Url = False
          WantReturns = True
          WantTabs = True
          WordWrap = False
          WrapOption.FollowRetMark = False
          WrapOption.FollowPunctuation = False
          WrapOption.FollowStr = #12289#12290#65292#65294#12539#65311#65281#12443#12444#12541#12542#12445#12446#12293#12540#65289#65341#65373#12301#12303'!),.:;?]}'#65377#65379#65380#65381#65392#65438#65439
          WrapOption.Leading = False
          WrapOption.LeadStr = #65288#65339#65371#12300#12302'([{'#65378
          WrapOption.PunctuationStr = #12289#12290#65292#65294',.'#65377#65380
          WrapOption.WordBreak = False
          WrapOption.WrapByte = 80
          OnChange = edtBChange
          OnClick = edtBClick
          OnDblClick = edtBDblClick
          OnDragDrop = edtBDragDrop
          OnDragOver = edtBDragOver
          OnKeyDown = edtBKeyDown
          OnKeyPress = edtBKeyPress
          OnKeyUp = edtBKeyUp
          OnMouseDown = edtBMouseDown
          OnDropFiles = edtBDropFiles
          ExMarks.DBSpaceMark.Color = clGray
          ExMarks.DBSpaceMark.Visible = False
          ExMarks.SpaceMark.Color = clGray
          ExMarks.SpaceMark.Visible = False
          ExMarks.TabMark.Color = clGray
          ExMarks.TabMark.Visible = True
          ExMarks.FindMark.Color = clGray
          ExMarks.FindMark.Visible = False
          ExMarks.Hit.BkColor = clNone
          ExMarks.Hit.Color = clNone
          ExMarks.Hit.Style = []
          ExMarks.ParenMark.Color = clGray
          ExMarks.ParenMark.Visible = False
          ExMarks.CurrentLine.Color = clGray
          ExMarks.CurrentLine.Visible = False
          ExMarks.DigitLine.Color = clGray
          ExMarks.DigitLine.Visible = False
          ExMarks.ImageLine.Color = clGray
          ExMarks.ImageLine.Visible = False
          ExMarks.Img0Line.Color = clGray
          ExMarks.Img0Line.Visible = False
          ExMarks.Img1Line.Color = clGray
          ExMarks.Img1Line.Visible = False
          ExMarks.Img2Line.Color = clGray
          ExMarks.Img2Line.Visible = False
          ExMarks.Img3Line.Color = clGray
          ExMarks.Img3Line.Visible = False
          ExMarks.Img4Line.Color = clGray
          ExMarks.Img4Line.Visible = False
          ExMarks.Img5Line.Color = clGray
          ExMarks.Img5Line.Visible = False
          ExMarks.EvenLine.Color = clGray
          ExMarks.EvenLine.Visible = False
          ExSearchOptions = []
          VerticalLines = <>
        end
        object edtB: TEditorEx
          Left = 6
          Top = 2
          Width = 565
          Height = 410
          Cursor = crIBeam
          Align = alClient
          Caret.AutoCursor = True
          Caret.AutoIndent = False
          Caret.BackSpaceUnIndent = True
          Caret.Cursors.DefaultCursor = crIBeam
          Caret.Cursors.DragSelCursor = crDrag
          Caret.Cursors.DragSelCopyCursor = 1959
          Caret.Cursors.InSelCursor = crDefault
          Caret.Cursors.LeftMarginCursor = 1958
          Caret.Cursors.TopMarginCursor = crDefault
          Caret.FreeCaret = True
          Caret.FreeRow = False
          Caret.InTab = False
          Caret.KeepCaret = False
          Caret.LockScroll = False
          Caret.NextLine = False
          Caret.PrevSpaceIndent = False
          Caret.RowSelect = True
          Caret.SelDragMode = dmManual
          Caret.SelMove = True
          Caret.SoftTab = False
          Caret.Style = csDefault
          Caret.TabIndent = False
          Caret.TabSpaceCount = 8
          Caret.TokenEndStop = False
          Font.Charset = SHIFTJIS_CHARSET
          Font.Color = clBlack
          Font.Height = -12
          Font.Name = 'FixedSys'
          Font.Style = []
          HitStyle = hsSelect
          Imagebar.DigitWidth = 8
          Imagebar.LeftMargin = 2
          Imagebar.MarkWidth = 0
          Imagebar.RightMargin = 2
          Imagebar.Visible = True
          ImageMarks = imgsTab
          Lines.Strings = (
            'edtB')
          Marks.EofMark.Color = clGray
          Marks.EofMark.Visible = False
          Marks.RetMark.Color = clGray
          Marks.RetMark.Visible = False
          Marks.WrapMark.Color = clGray
          Marks.WrapMark.Visible = False
          Marks.HideMark.Color = clGray
          Marks.HideMark.Visible = False
          Marks.Underline.Color = clGray
          Marks.Underline.Visible = False
          Margin.Character = 0
          Margin.Left = 12
          Margin.Line = 0
          Margin.Top = 2
          Leftbar.BkColor = clSilver
          Leftbar.Color = clBlack
          Leftbar.Column = 3
          Leftbar.Edge = True
          Leftbar.LeftMargin = 2
          Leftbar.RightMargin = 3
          Leftbar.ShowNumber = True
          Leftbar.ShowNumberMode = nmRow
          Leftbar.Visible = True
          Leftbar.ZeroBase = False
          Leftbar.ZeroLead = False
          PopupMenu = popupMain
          ReadOnly = False
          Ruler.BkColor = clSilver
          Ruler.Color = clBlack
          Ruler.Edge = True
          Ruler.GaugeRange = 10
          Ruler.MarkColor = clBlack
          Ruler.Visible = True
          ScrollBars = ssNone
          Speed.CaretVerticalAc = 2
          Speed.InitBracketsFull = False
          Speed.PageVerticalRange = 2
          Speed.PageVerticalRangeAc = 2
          TabOrder = 1
          UndoListMax = 64
          View.Brackets = <>
          View.Colors.Ank.BkColor = clNone
          View.Colors.Ank.Color = clNone
          View.Colors.Ank.Style = []
          View.Colors.Comment.BkColor = clNone
          View.Colors.Comment.Color = clNone
          View.Colors.Comment.Style = []
          View.Colors.DBCS.BkColor = clNone
          View.Colors.DBCS.Color = clNone
          View.Colors.DBCS.Style = []
          View.Colors.Hit.BkColor = clNone
          View.Colors.Hit.Color = clNone
          View.Colors.Hit.Style = []
          View.Colors.Int.BkColor = clNone
          View.Colors.Int.Color = clNone
          View.Colors.Int.Style = []
          View.Colors.Mail.BkColor = clNone
          View.Colors.Mail.Color = clNone
          View.Colors.Mail.Style = []
          View.Colors.Reserve.BkColor = clNone
          View.Colors.Reserve.Color = clNone
          View.Colors.Reserve.Style = []
          View.Colors.Select.BkColor = clNavy
          View.Colors.Select.Color = clWhite
          View.Colors.Select.Style = []
          View.Colors.Str.BkColor = clNone
          View.Colors.Str.Color = clNone
          View.Colors.Str.Style = []
          View.Colors.Symbol.BkColor = clNone
          View.Colors.Symbol.Color = clNone
          View.Colors.Symbol.Style = []
          View.Colors.Url.BkColor = clNone
          View.Colors.Url.Color = clNone
          View.Colors.Url.Style = []
          View.ControlCode = False
          View.Mail = False
          View.Url = False
          WantReturns = True
          WantTabs = True
          WordWrap = False
          WrapOption.FollowRetMark = False
          WrapOption.FollowPunctuation = False
          WrapOption.FollowStr = #12289#12290#65292#65294#12539#65311#65281#12443#12444#12541#12542#12445#12446#12293#12540#65289#65341#65373#12301#12303'!),.:;?]}'#65377#65379#65380#65381#65392#65438#65439
          WrapOption.Leading = False
          WrapOption.LeadStr = #65288#65339#65371#12300#12302'([{'#65378
          WrapOption.PunctuationStr = #12289#12290#65292#65294',.'#65377#65380
          WrapOption.WordBreak = False
          WrapOption.WrapByte = 80
          OnCaretMoved = edtBCaretMoved
          OnChange = edtBChange
          OnClick = edtBClick
          OnDblClick = edtBDblClick
          OnDragDrop = edtBDragDrop
          OnDragOver = edtBDragOver
          OnKeyDown = edtBKeyDown
          OnKeyPress = edtBKeyPress
          OnKeyUp = edtBKeyUp
          OnMouseDown = edtBMouseDown
          OnMouseUp = edtBMouseUp
          OnDropFiles = edtBDropFiles
          ExMarks.DBSpaceMark.Color = clSilver
          ExMarks.DBSpaceMark.Visible = True
          ExMarks.SpaceMark.Color = clSilver
          ExMarks.SpaceMark.Visible = True
          ExMarks.TabMark.Color = clGray
          ExMarks.TabMark.Visible = True
          ExMarks.FindMark.Color = clGray
          ExMarks.FindMark.Visible = False
          ExMarks.Hit.BkColor = clNone
          ExMarks.Hit.Color = clNone
          ExMarks.Hit.Style = []
          ExMarks.ParenMark.Color = clGray
          ExMarks.ParenMark.Visible = False
          ExMarks.CurrentLine.Color = clGray
          ExMarks.CurrentLine.Visible = False
          ExMarks.DigitLine.Color = clGray
          ExMarks.DigitLine.Visible = False
          ExMarks.ImageLine.Color = clGray
          ExMarks.ImageLine.Visible = False
          ExMarks.Img0Line.Color = clGray
          ExMarks.Img0Line.Visible = False
          ExMarks.Img1Line.Color = clGray
          ExMarks.Img1Line.Visible = False
          ExMarks.Img2Line.Color = clGray
          ExMarks.Img2Line.Visible = False
          ExMarks.Img3Line.Color = clGray
          ExMarks.Img3Line.Visible = False
          ExMarks.Img4Line.Color = clGray
          ExMarks.Img4Line.Visible = False
          ExMarks.Img5Line.Color = clGray
          ExMarks.Img5Line.Visible = False
          ExMarks.EvenLine.Color = clGray
          ExMarks.EvenLine.Visible = False
          ExSearchOptions = []
          VerticalLines = <>
        end
        object panelOtehon: TPanel
          Left = 0
          Top = 2
          Width = 3
          Height = 410
          Align = alLeft
          BevelOuter = bvNone
          Caption = 'panelOtehon'
          TabOrder = 2
          object edtC: TEditorEx
            Left = 0
            Top = 0
            Width = 3
            Height = 275
            Cursor = crIBeam
            Align = alClient
            Caret.AutoCursor = True
            Caret.AutoIndent = False
            Caret.BackSpaceUnIndent = True
            Caret.Cursors.DefaultCursor = crIBeam
            Caret.Cursors.DragSelCursor = crDrag
            Caret.Cursors.DragSelCopyCursor = 1959
            Caret.Cursors.InSelCursor = crDefault
            Caret.Cursors.LeftMarginCursor = 1958
            Caret.Cursors.TopMarginCursor = crDefault
            Caret.FreeCaret = True
            Caret.FreeRow = False
            Caret.InTab = False
            Caret.KeepCaret = False
            Caret.LockScroll = False
            Caret.NextLine = False
            Caret.PrevSpaceIndent = False
            Caret.RowSelect = True
            Caret.SelDragMode = dmManual
            Caret.SelMove = True
            Caret.SoftTab = False
            Caret.Style = csDefault
            Caret.TabIndent = False
            Caret.TabSpaceCount = 8
            Caret.TokenEndStop = False
            Fountain = NadesikoFountain
            Font.Charset = SHIFTJIS_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'FixedSys'
            Font.Style = []
            HitStyle = hsSelect
            Imagebar.DigitWidth = 8
            Imagebar.LeftMargin = 2
            Imagebar.MarkWidth = 0
            Imagebar.RightMargin = 2
            Imagebar.Visible = False
            Marks.EofMark.Color = clGray
            Marks.EofMark.Visible = False
            Marks.RetMark.Color = clGray
            Marks.RetMark.Visible = False
            Marks.WrapMark.Color = clGray
            Marks.WrapMark.Visible = False
            Marks.HideMark.Color = clGray
            Marks.HideMark.Visible = False
            Marks.Underline.Color = clGray
            Marks.Underline.Visible = False
            Margin.Character = 0
            Margin.Left = 4
            Margin.Line = 0
            Margin.Top = 2
            Leftbar.BkColor = clSilver
            Leftbar.Color = clBlack
            Leftbar.Column = 2
            Leftbar.Edge = True
            Leftbar.LeftMargin = 1
            Leftbar.RightMargin = 1
            Leftbar.ShowNumber = True
            Leftbar.ShowNumberMode = nmRow
            Leftbar.Visible = True
            Leftbar.ZeroBase = False
            Leftbar.ZeroLead = False
            PopupMenu = popupMain
            ReadOnly = False
            Ruler.BkColor = clSilver
            Ruler.Color = clBlack
            Ruler.Edge = True
            Ruler.GaugeRange = 10
            Ruler.MarkColor = clBlack
            Ruler.Visible = True
            ScrollBars = ssVertical
            Speed.CaretVerticalAc = 2
            Speed.InitBracketsFull = False
            Speed.PageVerticalRange = 2
            Speed.PageVerticalRangeAc = 2
            TabOrder = 0
            UndoListMax = 64
            View.Brackets = <>
            View.Colors.Ank.BkColor = clNone
            View.Colors.Ank.Color = clNone
            View.Colors.Ank.Style = []
            View.Colors.Comment.BkColor = clNone
            View.Colors.Comment.Color = clNone
            View.Colors.Comment.Style = []
            View.Colors.DBCS.BkColor = clNone
            View.Colors.DBCS.Color = clNone
            View.Colors.DBCS.Style = []
            View.Colors.Hit.BkColor = clNone
            View.Colors.Hit.Color = clNone
            View.Colors.Hit.Style = []
            View.Colors.Int.BkColor = clNone
            View.Colors.Int.Color = clNone
            View.Colors.Int.Style = []
            View.Colors.Mail.BkColor = clNone
            View.Colors.Mail.Color = clNone
            View.Colors.Mail.Style = []
            View.Colors.Reserve.BkColor = clNone
            View.Colors.Reserve.Color = clNone
            View.Colors.Reserve.Style = []
            View.Colors.Select.BkColor = clNavy
            View.Colors.Select.Color = clWhite
            View.Colors.Select.Style = []
            View.Colors.Str.BkColor = clNone
            View.Colors.Str.Color = clNone
            View.Colors.Str.Style = []
            View.Colors.Symbol.BkColor = clNone
            View.Colors.Symbol.Color = clNone
            View.Colors.Symbol.Style = []
            View.Colors.Url.BkColor = clNone
            View.Colors.Url.Color = clNone
            View.Colors.Url.Style = []
            View.ControlCode = False
            View.Mail = False
            View.Url = False
            WantReturns = True
            WantTabs = True
            WordWrap = False
            WrapOption.FollowRetMark = False
            WrapOption.FollowPunctuation = False
            WrapOption.FollowStr = #12289#12290#65292#65294#12539#65311#65281#12443#12444#12541#12542#12445#12446#12293#12540#65289#65341#65373#12301#12303'!),.:;?]}'#65377#65379#65380#65381#65392#65438#65439
            WrapOption.Leading = False
            WrapOption.LeadStr = #65288#65339#65371#12300#12302'([{'#65378
            WrapOption.PunctuationStr = #12289#12290#65292#65294',.'#65377#65380
            WrapOption.WordBreak = False
            WrapOption.WrapByte = 80
            OnChange = edtBChange
            OnClick = edtBClick
            OnDblClick = edtBDblClick
            OnDrawLine = edtCDrawLine
            OnDragDrop = edtBDragDrop
            OnDragOver = edtBDragOver
            OnKeyDown = edtBKeyDown
            OnKeyPress = edtBKeyPress
            OnKeyUp = edtBKeyUp
            OnMouseDown = edtBMouseDown
            OnDropFiles = edtBDropFiles
            ExMarks.DBSpaceMark.Color = clSilver
            ExMarks.DBSpaceMark.Visible = True
            ExMarks.SpaceMark.Color = clSilver
            ExMarks.SpaceMark.Visible = True
            ExMarks.TabMark.Color = clGray
            ExMarks.TabMark.Visible = True
            ExMarks.FindMark.Color = clGray
            ExMarks.FindMark.Visible = False
            ExMarks.Hit.BkColor = clNone
            ExMarks.Hit.Color = clNone
            ExMarks.Hit.Style = []
            ExMarks.ParenMark.Color = clGray
            ExMarks.ParenMark.Visible = False
            ExMarks.CurrentLine.Color = clGray
            ExMarks.CurrentLine.Visible = False
            ExMarks.DigitLine.Color = clGray
            ExMarks.DigitLine.Visible = False
            ExMarks.ImageLine.Color = clGray
            ExMarks.ImageLine.Visible = False
            ExMarks.Img0Line.Color = clGray
            ExMarks.Img0Line.Visible = False
            ExMarks.Img1Line.Color = clGray
            ExMarks.Img1Line.Visible = False
            ExMarks.Img2Line.Color = clGray
            ExMarks.Img2Line.Visible = False
            ExMarks.Img3Line.Color = clGray
            ExMarks.Img3Line.Visible = False
            ExMarks.Img4Line.Color = clGray
            ExMarks.Img4Line.Visible = False
            ExMarks.Img5Line.Color = clGray
            ExMarks.Img5Line.Visible = False
            ExMarks.EvenLine.Color = clGray
            ExMarks.EvenLine.Visible = False
            ExSearchOptions = []
            VerticalLines = <>
          end
          object panelOtehonBottom: TPanel
            Left = 0
            Top = 275
            Width = 3
            Height = 135
            Align = alBottom
            BevelOuter = bvLowered
            TabOrder = 1
            object panelDiff: TPanel
              Left = 1
              Top = 1
              Width = 1
              Height = 32
              Align = alTop
              BevelOuter = bvLowered
              TabOrder = 0
              object btnDiff: TButton
                Left = 6
                Top = 3
                Width = 121
                Height = 26
                Caption = #35443#32048#12394#27604#36611
                TabOrder = 0
                OnClick = btnDiffClick
              end
            end
            object edtDiff: TEditorEx
              Left = 1
              Top = 33
              Width = 1
              Height = 101
              Cursor = crIBeam
              Align = alClient
              Caret.AutoCursor = True
              Caret.AutoIndent = False
              Caret.BackSpaceUnIndent = True
              Caret.Cursors.DefaultCursor = crIBeam
              Caret.Cursors.DragSelCursor = crDrag
              Caret.Cursors.DragSelCopyCursor = 1959
              Caret.Cursors.InSelCursor = crDefault
              Caret.Cursors.LeftMarginCursor = 1958
              Caret.Cursors.TopMarginCursor = crDefault
              Caret.FreeCaret = True
              Caret.FreeRow = False
              Caret.InTab = False
              Caret.KeepCaret = False
              Caret.LockScroll = False
              Caret.NextLine = False
              Caret.PrevSpaceIndent = False
              Caret.RowSelect = True
              Caret.SelDragMode = dmManual
              Caret.SelMove = True
              Caret.SoftTab = False
              Caret.Style = csDefault
              Caret.TabIndent = False
              Caret.TabSpaceCount = 8
              Caret.TokenEndStop = False
              Font.Charset = SHIFTJIS_CHARSET
              Font.Color = clBlack
              Font.Height = -12
              Font.Name = 'FixedSys'
              Font.Style = []
              HitStyle = hsSelect
              Imagebar.DigitWidth = 8
              Imagebar.LeftMargin = 2
              Imagebar.MarkWidth = 0
              Imagebar.RightMargin = 2
              Imagebar.Visible = False
              Marks.EofMark.Color = clGray
              Marks.EofMark.Visible = False
              Marks.RetMark.Color = clGray
              Marks.RetMark.Visible = False
              Marks.WrapMark.Color = clGray
              Marks.WrapMark.Visible = False
              Marks.HideMark.Color = clGray
              Marks.HideMark.Visible = False
              Marks.Underline.Color = clGray
              Marks.Underline.Visible = False
              Margin.Character = 0
              Margin.Left = 4
              Margin.Line = 0
              Margin.Top = 2
              Leftbar.BkColor = clSilver
              Leftbar.Color = clBlack
              Leftbar.Column = 2
              Leftbar.Edge = False
              Leftbar.LeftMargin = 1
              Leftbar.RightMargin = 1
              Leftbar.ShowNumber = False
              Leftbar.ShowNumberMode = nmRow
              Leftbar.Visible = False
              Leftbar.ZeroBase = False
              Leftbar.ZeroLead = False
              PopupMenu = popupMain
              ReadOnly = False
              Ruler.BkColor = clSilver
              Ruler.Color = clBlack
              Ruler.Edge = False
              Ruler.GaugeRange = 10
              Ruler.MarkColor = clBlack
              Ruler.Visible = False
              ScrollBars = ssVertical
              Speed.CaretVerticalAc = 2
              Speed.InitBracketsFull = False
              Speed.PageVerticalRange = 2
              Speed.PageVerticalRangeAc = 2
              TabOrder = 1
              UndoListMax = 64
              View.Brackets = <>
              View.Colors.Ank.BkColor = clNone
              View.Colors.Ank.Color = clNone
              View.Colors.Ank.Style = []
              View.Colors.Comment.BkColor = clNone
              View.Colors.Comment.Color = clNone
              View.Colors.Comment.Style = []
              View.Colors.DBCS.BkColor = clNone
              View.Colors.DBCS.Color = clNone
              View.Colors.DBCS.Style = []
              View.Colors.Hit.BkColor = clNone
              View.Colors.Hit.Color = clNone
              View.Colors.Hit.Style = []
              View.Colors.Int.BkColor = clNone
              View.Colors.Int.Color = clNone
              View.Colors.Int.Style = []
              View.Colors.Mail.BkColor = clNone
              View.Colors.Mail.Color = clNone
              View.Colors.Mail.Style = []
              View.Colors.Reserve.BkColor = clNone
              View.Colors.Reserve.Color = clNone
              View.Colors.Reserve.Style = []
              View.Colors.Select.BkColor = clNavy
              View.Colors.Select.Color = clWhite
              View.Colors.Select.Style = []
              View.Colors.Str.BkColor = clNone
              View.Colors.Str.Color = clNone
              View.Colors.Str.Style = []
              View.Colors.Symbol.BkColor = clNone
              View.Colors.Symbol.Color = clNone
              View.Colors.Symbol.Style = []
              View.Colors.Url.BkColor = clNone
              View.Colors.Url.Color = clNone
              View.Colors.Url.Style = []
              View.ControlCode = False
              View.Mail = False
              View.Url = False
              WantReturns = True
              WantTabs = True
              WordWrap = False
              WrapOption.FollowRetMark = False
              WrapOption.FollowPunctuation = False
              WrapOption.FollowStr = #12289#12290#65292#65294#12539#65311#65281#12443#12444#12541#12542#12445#12446#12293#12540#65289#65341#65373#12301#12303'!),.:;?]}'#65377#65379#65380#65381#65392#65438#65439
              WrapOption.Leading = False
              WrapOption.LeadStr = #65288#65339#65371#12300#12302'([{'#65378
              WrapOption.PunctuationStr = #12289#12290#65292#65294',.'#65377#65380
              WrapOption.WordBreak = False
              WrapOption.WrapByte = 80
              OnChange = edtBChange
              OnClick = edtBClick
              OnDblClick = edtBDblClick
              OnDragDrop = edtBDragDrop
              OnDragOver = edtBDragOver
              OnKeyDown = edtBKeyDown
              OnKeyPress = edtBKeyPress
              OnKeyUp = edtBKeyUp
              OnMouseDown = edtBMouseDown
              OnDropFiles = edtBDropFiles
              ExMarks.DBSpaceMark.Color = clSilver
              ExMarks.DBSpaceMark.Visible = True
              ExMarks.SpaceMark.Color = clSilver
              ExMarks.SpaceMark.Visible = False
              ExMarks.TabMark.Color = clGray
              ExMarks.TabMark.Visible = True
              ExMarks.FindMark.Color = clGray
              ExMarks.FindMark.Visible = False
              ExMarks.Hit.BkColor = clNone
              ExMarks.Hit.Color = clNone
              ExMarks.Hit.Style = []
              ExMarks.ParenMark.Color = clGray
              ExMarks.ParenMark.Visible = False
              ExMarks.CurrentLine.Color = clGray
              ExMarks.CurrentLine.Visible = False
              ExMarks.DigitLine.Color = clGray
              ExMarks.DigitLine.Visible = False
              ExMarks.ImageLine.Color = clGray
              ExMarks.ImageLine.Visible = False
              ExMarks.Img0Line.Color = clGray
              ExMarks.Img0Line.Visible = False
              ExMarks.Img1Line.Color = clGray
              ExMarks.Img1Line.Visible = False
              ExMarks.Img2Line.Color = clGray
              ExMarks.Img2Line.Visible = False
              ExMarks.Img3Line.Color = clGray
              ExMarks.Img3Line.Visible = False
              ExMarks.Img4Line.Color = clGray
              ExMarks.Img4Line.Visible = False
              ExMarks.Img5Line.Color = clGray
              ExMarks.Img5Line.Visible = False
              ExMarks.EvenLine.Color = clGray
              ExMarks.EvenLine.Visible = False
              ExSearchOptions = []
              VerticalLines = <>
            end
          end
        end
      end
      object tabDesign: TTabSheet
        Caption = #12487#12470#12452#12531
        ImageIndex = 1
        object Splitter5: TSplitter
          Left = 442
          Top = 0
          Height = 412
          Align = alRight
        end
        object panelDesign: TPanel
          Left = 0
          Top = 0
          Width = 442
          Height = 412
          Align = alClient
          BevelInner = bvRaised
          BevelOuter = bvLowered
          TabOrder = 0
          OnMouseDown = panelDesignMouseDown
          object edtDesignDescript: TLabel
            Left = 24
            Top = 24
            Width = 306
            Height = 12
            Caption = #8251#21491#12398#12522#12473#12488#12434#12480#12502#12523#12463#12522#12483#12463#12377#12427#12392'GUI'#37096#21697#12434#25407#20837#12391#12365#12414#12377#12290
            Color = clBtnText
            Font.Charset = SHIFTJIS_CHARSET
            Font.Color = clBtnText
            Font.Height = -12
            Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
            Font.Style = []
            ParentColor = False
            ParentFont = False
            Transparent = True
          end
          object track: TTrackBox
            Left = 16
            Top = 80
            Width = 105
            Height = 105
            PopupMenu = popupDesign
            Visible = False
            OnMouseUp = trackMouseUp
            TrackColor = clBlack
            TrackLineVisible = True
            TrackSizeEnable = True
          end
        end
        object panelTools: TPanel
          Left = 445
          Top = 0
          Width = 126
          Height = 412
          Align = alRight
          TabOrder = 1
          object Panel11: TPanel
            Left = 1
            Top = 1
            Width = 124
            Height = 32
            Align = alTop
            BevelOuter = bvLowered
            Caption = #12497#12540#12484#12398#25407#20837
            TabOrder = 0
          end
          object lstInsertParts: TListBox
            Left = 1
            Top = 33
            Width = 124
            Height = 378
            Align = alClient
            ItemHeight = 12
            TabOrder = 1
            OnDblClick = lstInsertPartsDblClick
          end
        end
      end
    end
  end
  object mnusMain: TMainMenu
    Left = 272
    Top = 128
    object F1: TMenuItem
      Caption = #12501#12449#12452#12523'(&F)'
      object mnuNew: TMenuItem
        Caption = #26032#35215'(&N)'
        OnClick = mnuNewClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mnuOpen: TMenuItem
        Caption = #38283#12367'(&O)...'
        ShortCut = 16463
        OnClick = mnuOpenClick
      end
      object mnuOpenRecent: TMenuItem
        Caption = #26368#36817#38283#12356#12383#12501#12449#12452#12523'(&R)'
      end
      object mnuOpenSample: TMenuItem
        Caption = #12469#12531#12503#12523#12501#12457#12523#12480#12434#38283#12367
        OnClick = mnuOpenSampleClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object mnuSave: TMenuItem
        Caption = #20445#23384'(&S)'
        ShortCut = 16467
        OnClick = mnuSaveClick
      end
      object mnuSaveAs: TMenuItem
        Caption = #21517#21069#12434#12388#12369#12390#20445#23384'(&A)...'
        OnClick = mnuSaveAsClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object mnuMakeExe: TMenuItem
        Caption = #23455#34892#12501#12449#12452#12523#20316#25104'(&M)...'
        OnClick = mnuMakeExeClick
      end
      object mnuMakeBatchFile: TMenuItem
        Caption = #12496#12483#12481#12501#12449#12452#12523#20316#25104'(&B)..'
        OnClick = mnuMakeBatchFileClick
      end
      object mnuMakeInstaller: TMenuItem
        Caption = #12452#12531#12473#12488#12540#12521#12540#12398#20316#25104'['#12487#12521#12483#12463#12473#29256'](&I)...'
        Enabled = False
        Visible = False
        OnClick = mnuMakeInstallerClick
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object N31: TMenuItem
        Caption = #20837#21147#25991#23383#12467#12540#12489'(&M)'
        object mnuInCodeAuto: TMenuItem
          Caption = #33258#21205#21028#21029
          OnClick = mnuInCodeAutoClick
        end
        object N36: TMenuItem
          Caption = '-'
        end
        object JIS1: TMenuItem
          Caption = 'JIS'
          OnClick = JIS1Click
        end
        object EUC1: TMenuItem
          Caption = 'EUC'
          OnClick = EUC1Click
        end
        object N32: TMenuItem
          Caption = '-'
        end
        object UTF8N1: TMenuItem
          Caption = 'UTF-8N'
          OnClick = UTF8N1Click
        end
        object UTF81: TMenuItem
          Caption = 'UTF-8'
          OnClick = UTF81Click
        end
      end
      object O1: TMenuItem
        Caption = #20986#21147#25991#23383#12467#12540#12489'(&O)'
        object mnuOutSJIS: TMenuItem
          AutoCheck = True
          Caption = 'SHIFT-JIS'
          Checked = True
          GroupIndex = 1
          RadioItem = True
          OnClick = mnuOutSJISClick
        end
        object N37: TMenuItem
          Caption = '-'
          GroupIndex = 1
        end
        object mnuOutJIS: TMenuItem
          AutoCheck = True
          Caption = 'JIS'
          GroupIndex = 1
          RadioItem = True
          OnClick = mnuOutJISClick
        end
        object mnuOutEUC: TMenuItem
          AutoCheck = True
          Caption = 'EUC'
          GroupIndex = 1
          RadioItem = True
          OnClick = mnuOutEUCClick
        end
        object mnuOutUTF8N: TMenuItem
          AutoCheck = True
          Caption = 'UTF-8N'
          GroupIndex = 1
          RadioItem = True
          OnClick = mnuOutUTF8NClick
        end
      end
      object N38: TMenuItem
        Caption = #20986#21147#25913#34892#12467#12540#12489'(&R)'
        object mnuRetCRLF1: TMenuItem
          AutoCheck = True
          Caption = 'CR+LF'
          Checked = True
          GroupIndex = 2
          RadioItem = True
          OnClick = mnuRetCRLF1Click
        end
        object mnuRetCR1: TMenuItem
          AutoCheck = True
          Caption = 'CR'
          GroupIndex = 2
          RadioItem = True
          OnClick = mnuRetCR1Click
        end
        object mnuRetLF1: TMenuItem
          AutoCheck = True
          Caption = 'LF'
          GroupIndex = 2
          RadioItem = True
          OnClick = mnuRetLF1Click
        end
      end
      object N35: TMenuItem
        Caption = '-'
      end
      object mnuClose: TMenuItem
        Caption = #38281#12376#12427'(&C)'
        OnClick = mnuCloseClick
      end
    end
    object E1: TMenuItem
      Caption = #32232#38598'(&E)'
      object mnuUndo: TMenuItem
        Caption = #20803#12395#25147#12377'(&Z)'
        ShortCut = 16474
        OnClick = mnuUndoClick
      end
      object mnuRedo: TMenuItem
        Caption = #12420#12426#30452#12377'(&Y)'
        ShortCut = 16473
        OnClick = mnuRedoClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mnuCut: TMenuItem
        Caption = #20999#12426#21462#12426'(&X)'
        ShortCut = 16472
        OnClick = mnuCutClick
      end
      object mnuCopy: TMenuItem
        Caption = #12467#12500#12540'(&C)'
        ShortCut = 16451
        OnClick = mnuCopyClick
      end
      object mnuPaste: TMenuItem
        Caption = #36028#12426#20184#12369'(&X)'
        ShortCut = 16470
        OnClick = mnuPasteClick
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object mnuSelectAll: TMenuItem
        Caption = #12377#12409#12390#36984#25246'(&A)'
        ShortCut = 16449
        OnClick = mnuSelectAllClick
      end
      object N8: TMenuItem
        Caption = '-'
      end
      object N10: TMenuItem
        AutoHotkeys = maManual
        AutoLineReduction = maManual
        Caption = #12375#12362#12426'(&S)'
        object N11: TMenuItem
          Caption = #35352#37682
          object mnuBM1: TMenuItem
            Tag = 1
            Caption = '1'
            ShortCut = 24625
            OnClick = mnuBM1Click
          end
          object mnuBM2: TMenuItem
            Tag = 2
            Caption = '2'
            ShortCut = 24626
            OnClick = mnuBM1Click
          end
          object mnuBM3: TMenuItem
            Tag = 3
            Caption = '3'
            ShortCut = 24627
            OnClick = mnuBM1Click
          end
          object mnuBM4: TMenuItem
            Tag = 4
            Caption = '4'
            ShortCut = 24628
            OnClick = mnuBM1Click
          end
          object mnuBM5: TMenuItem
            Tag = 5
            Caption = '5'
            ShortCut = 24629
            OnClick = mnuBM1Click
          end
        end
        object N12: TMenuItem
          Caption = #12472#12515#12531#12503
          object mnuBJ1: TMenuItem
            Tag = 1
            Caption = '1'
            ShortCut = 16433
            OnClick = mnuBJ1Click
          end
          object mnuBJ2: TMenuItem
            Tag = 2
            Caption = '2'
            ShortCut = 16434
            OnClick = mnuBJ1Click
          end
          object mnuBJ3: TMenuItem
            Tag = 3
            Caption = '3'
            ShortCut = 16435
            OnClick = mnuBJ1Click
          end
          object mnuBJ4: TMenuItem
            Tag = 4
            Caption = '4'
            ShortCut = 16436
            OnClick = mnuBJ1Click
          end
          object mnuBJ5: TMenuItem
            Tag = 5
            Caption = '5'
            ShortCut = 16437
            OnClick = mnuBJ1Click
          end
        end
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object mnuIndentRight: TMenuItem
        AutoHotkeys = maManual
        AutoLineReduction = maManual
        Caption = #12452#12531#12487#12531#12488#8594
        ShortCut = 24649
        OnClick = mnuIndentRightClick
      end
      object mnuIndentLeft: TMenuItem
        AutoHotkeys = maManual
        AutoLineReduction = maManual
        Caption = #12452#12531#12487#12531#12488#8592
        ShortCut = 24661
        OnClick = mnuIndentLeftClick
      end
      object mnuIndentRightSpace: TMenuItem
        Caption = #21322#35282#12473#12506#12540#12473'1'#12388#25407#20837
        ShortCut = 24655
        OnClick = mnuIndentRightSpaceClick
      end
      object N21: TMenuItem
        Caption = '-'
      end
      object mnuInsLine: TMenuItem
        Caption = #21306#20999#12426#32218#12434#25407#20837'(&L)'
        ShortCut = 16460
        OnClick = mnuInsLineClick
      end
      object N63: TMenuItem
        Caption = '-'
      end
      object mnuInsertTemplate: TMenuItem
        Caption = #12486#12531#12503#12524#12540#12488#12434#25407#20837'..'
        ShortCut = 24652
        OnClick = mnuInsertTemplateClick
      end
      object mnuSaveAsTemplate: TMenuItem
        Caption = #12486#12531#12503#12524#12540#12488#12392#12375#12390#20445#23384'..'
        OnClick = mnuSaveAsTemplateClick
      end
    end
    object F2: TMenuItem
      Caption = #26908#32034'(&S)'
      object mnuFind: TMenuItem
        Caption = #26908#32034'...(&F)'
        ShortCut = 16454
        OnClick = mnuFindClick
      end
      object mnuFindNext: TMenuItem
        Caption = #27425#12434#26908#32034'(&N)'
        ShortCut = 114
        OnClick = mnuFindNextClick
      end
      object N22: TMenuItem
        Caption = '-'
      end
      object mnuGotoLine: TMenuItem
        Caption = #25351#23450#34892#12408#31227#21205
        ShortCut = 115
        OnClick = mnuGotoLineClick
      end
      object N52: TMenuItem
        Caption = '-'
      end
      object mnuReplace: TMenuItem
        Caption = #32622#25563'...(&R)'
        ShortCut = 16466
        OnClick = mnuReplaceClick
      end
      object N62: TMenuItem
        Caption = '-'
      end
      object mnuHokan: TMenuItem
        Caption = #21336#35486#35036#23436'...'
        ShortCut = 16416
        OnClick = mnuHokanClick
      end
      object mnuEnumUserFunction: TMenuItem
        Caption = #38306#25968#19968#35239#12434#21015#25369
        ShortCut = 16459
        OnClick = mnuEnumUserFunctionClick
      end
      object mnuEnumUserVar: TMenuItem
        Caption = #22793#25968#19968#35239#12434#21015#25369
        ShortCut = 24651
        OnClick = mnuEnumUserVarClick
      end
    end
    object V1: TMenuItem
      Caption = #34920#31034'(&V)'
      object mnuSplitEdit: TMenuItem
        Caption = #12456#12487#12451#12479#20998#21106
        OnClick = mnuSplitEditClick
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object mnuViewLeftPanel: TMenuItem
        Caption = #24038#12479#12502#12497#12493#12523
        Checked = True
        OnClick = mnuViewLeftPanelClick
      end
      object N49: TMenuItem
        Caption = '-'
      end
      object N50: TMenuItem
        Caption = #34920#31034#20999#12426#26367#12360
        object mnuViewEdit: TMenuItem
          Caption = #12456#12487#12451#12479#12434#34920#31034
          ShortCut = 8315
          OnClick = mnuViewEditClick
        end
        object mnuViewCmdTab: TMenuItem
          Caption = #21629#20196#19968#35239#12479#12502#12434#34920#31034
          ShortCut = 8314
          OnClick = mnuViewCmdTabClick
        end
        object mnuViewFindTab: TMenuItem
          Caption = #26908#32034#12479#12502#12434#34920#31034
          ShortCut = 8313
          OnClick = mnuViewFindTabClick
        end
      end
      object N64: TMenuItem
        Caption = '-'
      end
      object mnuDiffView: TMenuItem
        Caption = #12362#25163#26412#34920#31034#29992#12456#12487#12451#12479
        OnClick = mnuDiffViewClick
      end
      object mnuFirstShow: TMenuItem
        Caption = #12394#12391#12375#12371#12398#12399#12376#12417#12395
        OnClick = mnuFirstShowClick
      end
    end
    object R1: TMenuItem
      Caption = #23455#34892'(&R)'
      object mnuRun: TMenuItem
        Caption = #23455#34892'(&R)'
        ShortCut = 116
        OnClick = mnuRunClick
      end
      object N16: TMenuItem
        Caption = '-'
      end
      object mnuStop: TMenuItem
        Caption = #20572#27490'(&S)'
        ShortCut = 117
        OnClick = mnuStopClick
      end
      object mnuPause: TMenuItem
        Caption = #19968#26178#20572#27490'(&P)'
        OnClick = mnuPauseClick
      end
      object N19: TMenuItem
        Caption = '-'
      end
      object mnuDebugLineNo: TMenuItem
        Caption = #23455#34892#12375#12390#12356#12427#34892#12434#36861#36321
        OnClick = mnuDebugLineNoClick
      end
      object S2: TMenuItem
        Caption = #23455#34892#36895#24230'(&D)...'
        object mnuRunSpeed0: TMenuItem
          Caption = #26368#36895#23455#34892
          OnClick = mnuRunSpeed0Click
        end
        object N29: TMenuItem
          Caption = '-'
        end
        object mnuRunSpeed30: TMenuItem
          Tag = 10
          Caption = #12422#12387#12367#12426#23455#34892
        end
        object mnuRunSpeed100: TMenuItem
          Tag = 50
          Caption = #12373#12425#12395#12422#12387#12367#12426#23455#34892
          OnClick = mnuRunSpeed0Click
        end
        object mnuRunSpeed300: TMenuItem
          Tag = 100
          Caption = #12373#12425#12395#12373#12425#12395#12422#12387#12367#12426#23455#34892
          OnClick = mnuRunSpeed0Click
        end
      end
      object N48: TMenuItem
        Caption = '-'
      end
      object mnuStopAll: TMenuItem
        Caption = #12392#12395#12363#12367#20840#37096#32066#20102
        OnClick = mnuStopAllClick
      end
    end
    object mnuTools: TMenuItem
      Caption = #12484#12540#12523'(&T)'
    end
    object mnuDesign: TMenuItem
      Caption = #12487#12470#12452#12531'(&D)'
      Visible = False
      object N58: TMenuItem
        Caption = #37096#21697#32232#38598
        object mnuDesignDel: TMenuItem
          Caption = #36984#25246#37096#21697#12434#21066#38500
          OnClick = mnuDesignDelClick
        end
      end
      object N61: TMenuItem
        Caption = '-'
      end
      object mnuInsButton: TMenuItem
        Caption = #12508#12479#12531#25407#20837
        OnClick = mnuInsButtonClick
      end
      object mnuInsLabel: TMenuItem
        Caption = #12521#12505#12523#25407#20837
        OnClick = mnuInsLabelClick
      end
      object mnuInsBar: TMenuItem
        Caption = #12496#12540#25407#20837
        OnClick = mnuInsBarClick
      end
      object mnuInsCheck: TMenuItem
        Caption = #12481#12455#12483#12463#25407#20837
        OnClick = mnuInsCheckClick
      end
      object N53: TMenuItem
        Caption = '-'
      end
      object mnuInsEdit: TMenuItem
        Caption = #12456#12487#12451#12479#25407#20837
        OnClick = mnuInsEditClick
      end
      object mnuInsMemo: TMenuItem
        Caption = #12513#12514#25407#20837
        OnClick = mnuInsMemoClick
      end
      object mnuInsTEdit: TMenuItem
        Caption = 'T'#12456#12487#12451#12479#25407#20837
        OnClick = mnuInsTEditClick
      end
      object N54: TMenuItem
        Caption = '-'
      end
      object mnuInsList: TMenuItem
        Caption = #12522#12473#12488#25407#20837
        OnClick = mnuInsListClick
      end
      object mnuInsGrid: TMenuItem
        Caption = #12464#12522#12483#12489#25407#20837
        OnClick = mnuInsGridClick
      end
      object mnuInsPanel: TMenuItem
        Caption = #12497#12493#12523#25407#20837
        OnClick = mnuInsPanelClick
      end
      object N55: TMenuItem
        Caption = '-'
      end
      object mnuInsImage: TMenuItem
        Caption = #12452#12513#12540#12472#25407#20837
        OnClick = mnuInsImageClick
      end
      object mnuInsAnime: TMenuItem
        Caption = #12450#12491#12513#25407#20837
        OnClick = mnuInsAnimeClick
      end
    end
    object S1: TMenuItem
      Caption = #35373#23450'(&O)'
      object N17: TMenuItem
        Caption = #12394#12391#12375#12371#23455#34892#26041#24335'...'
        object mnuNakoV: TMenuItem
          Caption = #27161#28310'GUI - vnako.exe'
          OnClick = mnuNakoVClick
        end
        object mnuNakoG: TMenuItem
          Caption = #31777#26131'GUI - gnako.exe'
          OnClick = mnuNakoGClick
        end
        object mnuNakoC: TMenuItem
          Caption = #12467#12531#12477#12540#12523' - cnako.exe'
          OnClick = mnuNakoCClick
        end
        object N59: TMenuItem
          Caption = '-'
        end
        object mnuInsRunMode: TMenuItem
          Caption = #29694#22312#12398#23455#34892#12514#12540#12489#12434#12459#12540#12477#12523#20301#32622#12395#25407#20837
          OnClick = mnuInsRunModeClick
        end
      end
      object mnuRunAs: TMenuItem
        Caption = #23455#34892#12395#31649#29702#32773#27177#38480#12434#12388#12369#12427
        OnClick = mnuRunAsClick
      end
      object mnuRunTest: TMenuItem
        Caption = #12486#12473#12488#12395#12388#12356#12390
        object mnuTestMode: TMenuItem
          Caption = #12300#12486#12473#12488#12301#12363#12425#22987#12414#12427#38306#25968#12398#12415#12434#23455#34892#12377#12427
          OnClick = mnuTestModeClick
        end
        object mnuTestModeHelp: TMenuItem
          Caption = #12288#12288#8593#12486#12473#12488#12514#12540#12489#12395#38306#12377#12427#35500#26126#12434#35211#12427
          OnClick = mnuTestModeHelpClick
        end
        object N40: TMenuItem
          Caption = '-'
        end
        object mnuRunNakoTest: TMenuItem
          Caption = #12394#12391#12375#12371#12398#21205#20316#12486#12473#12488
          OnClick = mnuRunNakoTestClick
        end
      end
      object N20: TMenuItem
        Caption = '-'
      end
      object mnuKanrenduke: TMenuItem
        Caption = #38306#36899#20184#12369'(&R)...'
        OnClick = mnuKanrendukeClick
      end
      object N26: TMenuItem
        Caption = '-'
      end
      object N27: TMenuItem
        Caption = #34920#31034#12479#12502'...'
        object mnuViewSheetAction: TMenuItem
          Caption = #34892#21205#12479#12502
          Checked = True
          OnClick = mnuViewSheetActionClick
        end
        object mnuViewSheetGroup: TMenuItem
          Caption = #12464#12523#12540#12503#12479#12502
          Checked = True
          OnClick = mnuViewSheetGroupClick
        end
        object mnuViewSheetTree: TMenuItem
          Caption = #21629#20196#19968#35239#12479#12502
          Checked = True
          OnClick = mnuViewSheetTreeClick
        end
      end
      object mnuImeOn: TMenuItem
        Caption = #36215#21205#26178'IME'#12434#12458#12531#12395
        Checked = True
        OnClick = mnuImeOnClick
      end
      object mnuUseNewWindow: TMenuItem
        Caption = #26032#12375#12367#38283#12367#12392#12365#26032#35215#12454#12451#12531#12489#12454#12434#20351#12358
        Checked = True
        OnClick = mnuUseNewWindowClick
      end
      object mnuInsCmdNeedArg: TMenuItem
        Caption = #21629#20196#12398#25407#20837#26178#24341#25968#12434#20184#12369#12427
        OnClick = mnuInsCmdNeedArgClick
      end
      object mnuColorBlack: TMenuItem
        Caption = #37197#33394#12395#40658#12434#29992#12356#12427
        OnClick = mnuColorBlackClick
      end
      object mnuShowBlank: TMenuItem
        Caption = #12502#12521#12531#12463#25991#23383#12434#26126#31034#12377#12427
        OnClick = mnuShowBlankClick
      end
      object mnuInsDebug: TMenuItem
        Caption = #24038#12496#12540#12463#12522#12483#12463#12391#12300#12487#12496#12483#12464#12301#12434#25407#20837#12377#12427
        OnClick = mnuInsDebugClick
      end
      object N60: TMenuItem
        Caption = '-'
      end
      object mnuOpenSettingDir: TMenuItem
        Caption = #12394#12391#12375#12371#20491#20154#35373#23450#12501#12457#12523#12480#12434#38283#12367
        OnClick = mnuOpenSettingDirClick
      end
      object N30: TMenuItem
        Caption = '-'
      end
      object N41: TMenuItem
        Caption = #12456#12487#12451#12479#35373#23450'...'
        object mnuEditFont: TMenuItem
          Caption = #34920#31034#12501#12457#12531#12488#22793#26356'(&F)...'
          OnClick = mnuEditFontClick
        end
      end
      object mnuColorMode: TMenuItem
        Caption = #30528#33394#35215#21063'...'
        object mnuCol_nako: TMenuItem
          Caption = #12394#12391#12375#12371
          OnClick = mnuCol_javaClick
        end
        object mnuCol_hmw: TMenuItem
          Tag = 1
          Caption = #12402#12414#12431#12426
          OnClick = mnuCol_javaClick
        end
        object N33: TMenuItem
          Caption = '-'
          OnClick = mnuCol_javaClick
        end
        object mnuCol_Text: TMenuItem
          Tag = 2
          Caption = #12486#12461#12473#12488
          OnClick = mnuCol_javaClick
        end
        object mnuCol_htm: TMenuItem
          Tag = 3
          Caption = 'HTML'
          OnClick = mnuCol_javaClick
        end
        object N34: TMenuItem
          Caption = '-'
          OnClick = mnuCol_javaClick
        end
        object mnuCol_pl: TMenuItem
          Tag = 4
          Caption = 'Perl'
          OnClick = mnuCol_javaClick
        end
        object mnuCol_pas: TMenuItem
          Tag = 5
          Caption = 'Delphi'
          OnClick = mnuCol_javaClick
        end
        object mnuCol_java: TMenuItem
          Tag = 6
          Caption = 'Java'
          OnClick = mnuCol_javaClick
        end
        object mnuCol_cpp: TMenuItem
          Tag = 7
          Caption = 'C++'
          OnClick = mnuCol_javaClick
        end
      end
      object N57: TMenuItem
        Caption = '-'
      end
      object mnuRegDelux: TMenuItem
        Caption = #12487#12521#12483#12463#12473#29256#12398#30331#37682
        OnClick = mnuRegDeluxClick
      end
    end
    object H1: TMenuItem
      Caption = #12504#12523#12503'(&H)'
      object mnuMan: TMenuItem
        Caption = #12510#12491#12517#12450#12523'(&M)'
        OnClick = mnuManClick
      end
      object mnuWordHelp: TMenuItem
        Caption = #12459#12540#12477#12523#12398#21336#35486#12395#12388#12356#12390
        ShortCut = 112
        OnClick = mnuWordHelpClick
      end
      object N18: TMenuItem
        Caption = '-'
      end
      object mnuShowNadesikoHistory: TMenuItem
        Caption = #26356#26032#23653#27508#12434#35211#12427
        OnClick = mnuShowNadesikoHistoryClick
      end
      object mnuAbout: TMenuItem
        Caption = #12300#12394#12391#12375#12371#12301#12395#12388#12356#12390
        OnClick = mnuAboutClick
      end
    end
  end
  object NadesikoFountain: TNadesikoFountain
    FileExtList.Strings = (
      '.nako'
      '.txt')
    Brackets = <
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clGreen
        ItemColor.Style = []
        LeftBracket = '{'
        RightBracket = '}'
      end
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clNavy
        ItemColor.Style = []
        LeftBracket = #12300
        RightBracket = #12301
      end
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clNavy
        ItemColor.Style = []
        LeftBracket = #12302
        RightBracket = #12303
      end
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clNavy
        ItemColor.Style = []
        LeftBracket = '`'
        RightBracket = '`'
      end
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clNavy
        ItemColor.Style = []
        LeftBracket = '"'
        RightBracket = '"'
      end
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clGreen
        ItemColor.Style = []
        LeftBracket = '/*'
        RightBracket = '*/'
      end>
    Reserve.BkColor = clNone
    Reserve.Color = clNavy
    Reserve.Style = []
    ReserveWordList.Strings = (
      #12456#12521#12540
      #12371#12371
      #12381#12428
      #12418#12375
      #12523#12540#12503
      #36949
      #22238
      #30435#35222
      #38291
      #32368
      #26465#20214#20998#23696
      #32154
      #20195#20837
      #25244
      #21453#24489
      #24517#35201
      #19981#35201
      #22793#25968
      #22793#25968#23459#35328
      #25147)
    Ank.BkColor = clNone
    Ank.Color = clNone
    Ank.Style = []
    AsmBlock.BkColor = clNone
    AsmBlock.Color = clNone
    AsmBlock.Style = []
    Comment.BkColor = clNone
    Comment.Color = clGreen
    Comment.Style = []
    DBCS.BkColor = clNone
    DBCS.Color = clNone
    DBCS.Style = []
    Int.BkColor = clNone
    Int.Color = clNavy
    Int.Style = []
    Str.BkColor = clNone
    Str.Color = clNavy
    Str.Style = []
    Symbol.BkColor = clNone
    Symbol.Color = clTeal
    Symbol.Style = []
    Josi.BkColor = clNone
    Josi.Color = clMaroon
    Josi.Style = []
    DefLine.BkColor = clNone
    DefLine.Color = clFuchsia
    DefLine.Style = [fsBold]
    Member.BkColor = clNone
    Member.Color = clPurple
    Member.Style = []
    Left = 704
    Top = 64
  end
  object edtProp: TEditorExProp
    Color = clWindow
    Caret.AutoCursor = True
    Caret.AutoIndent = False
    Caret.BackSpaceUnIndent = True
    Caret.Cursors.DefaultCursor = crIBeam
    Caret.Cursors.DragSelCursor = crDrag
    Caret.Cursors.DragSelCopyCursor = 1959
    Caret.Cursors.InSelCursor = crDefault
    Caret.Cursors.LeftMarginCursor = 1958
    Caret.Cursors.TopMarginCursor = crDefault
    Caret.FreeCaret = False
    Caret.FreeRow = False
    Caret.InTab = False
    Caret.KeepCaret = False
    Caret.LockScroll = False
    Caret.NextLine = True
    Caret.PrevSpaceIndent = False
    Caret.RowSelect = True
    Caret.SelDragMode = dmAutomatic
    Caret.SelMove = True
    Caret.SoftTab = False
    Caret.Style = csDefault
    Caret.TabIndent = False
    Caret.TabSpaceCount = 4
    Caret.TokenEndStop = False
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #65325#65331' '#12468#12471#12483#12463
    Font.Style = []
    HitStyle = hsSelect
    Imagebar.DigitWidth = 4
    Imagebar.LeftMargin = 2
    Imagebar.MarkWidth = 1
    Imagebar.RightMargin = 2
    Imagebar.Visible = True
    Leftbar.BkColor = clSilver
    Leftbar.Color = clBlack
    Leftbar.Column = 3
    Leftbar.Edge = True
    Leftbar.LeftMargin = 2
    Leftbar.RightMargin = 2
    Leftbar.ShowNumber = True
    Leftbar.ShowNumberMode = nmRow
    Leftbar.Visible = True
    Leftbar.ZeroBase = False
    Leftbar.ZeroLead = False
    Margin.Character = 0
    Margin.Left = 10
    Margin.Line = 1
    Margin.Top = 2
    Marks.EofMark.Color = clGray
    Marks.EofMark.Visible = True
    Marks.RetMark.Color = clGray
    Marks.RetMark.Visible = False
    Marks.WrapMark.Color = clGray
    Marks.WrapMark.Visible = False
    Marks.HideMark.Color = clGray
    Marks.HideMark.Visible = False
    Marks.Underline.Color = clGray
    Marks.Underline.Visible = True
    Ruler.BkColor = clSilver
    Ruler.Color = clBlack
    Ruler.Edge = True
    Ruler.GaugeRange = 10
    Ruler.MarkColor = clBlack
    Ruler.Visible = True
    ScrollBars = ssBoth
    Speed.CaretVerticalAc = 2
    Speed.InitBracketsFull = False
    Speed.PageVerticalRange = 2
    Speed.PageVerticalRangeAc = 2
    View.Brackets = <>
    View.Colors.Ank.BkColor = clNone
    View.Colors.Ank.Color = clNone
    View.Colors.Ank.Style = []
    View.Colors.Comment.BkColor = clNone
    View.Colors.Comment.Color = clNone
    View.Colors.Comment.Style = []
    View.Colors.DBCS.BkColor = clNone
    View.Colors.DBCS.Color = clNone
    View.Colors.DBCS.Style = []
    View.Colors.Hit.BkColor = clNone
    View.Colors.Hit.Color = clNone
    View.Colors.Hit.Style = []
    View.Colors.Int.BkColor = clNone
    View.Colors.Int.Color = clNone
    View.Colors.Int.Style = []
    View.Colors.Mail.BkColor = clNone
    View.Colors.Mail.Color = clNone
    View.Colors.Mail.Style = []
    View.Colors.Reserve.BkColor = clNone
    View.Colors.Reserve.Color = clNone
    View.Colors.Reserve.Style = []
    View.Colors.Select.BkColor = clNavy
    View.Colors.Select.Color = clWhite
    View.Colors.Select.Style = []
    View.Colors.Str.BkColor = clNone
    View.Colors.Str.Color = clNone
    View.Colors.Str.Style = []
    View.Colors.Symbol.BkColor = clNone
    View.Colors.Symbol.Color = clNone
    View.Colors.Symbol.Style = []
    View.Colors.Url.BkColor = clNone
    View.Colors.Url.Color = clNone
    View.Colors.Url.Style = []
    View.ControlCode = False
    View.Mail = False
    View.Url = False
    WordWrap = False
    WrapOption.FollowRetMark = False
    WrapOption.FollowPunctuation = False
    WrapOption.FollowStr = #12289#12290#65292#65294#12539#65311#65281#12443#12444#12541#12542#12445#12446#12293#12540#65289#65341#65373#12301#12303'!),.:;?]}'#65377#65379#65380#65381#65392#65438#65439
    WrapOption.Leading = False
    WrapOption.LeadStr = #65288#65339#65371#12300#12302'([{'#65378
    WrapOption.PunctuationStr = #12289#12290#65292#65294',.'#65377#65380
    WrapOption.WordBreak = False
    WrapOption.WrapByte = 80
    ExMarks.DBSpaceMark.Color = clGray
    ExMarks.DBSpaceMark.Visible = False
    ExMarks.SpaceMark.Color = clGray
    ExMarks.SpaceMark.Visible = False
    ExMarks.TabMark.Color = clGray
    ExMarks.TabMark.Visible = True
    ExMarks.FindMark.Color = clGray
    ExMarks.FindMark.Visible = False
    ExMarks.Hit.BkColor = clNone
    ExMarks.Hit.Color = clNone
    ExMarks.Hit.Style = []
    ExMarks.ParenMark.Color = clGray
    ExMarks.ParenMark.Visible = False
    ExMarks.CurrentLine.Color = clGray
    ExMarks.CurrentLine.Visible = False
    ExMarks.DigitLine.Color = clGray
    ExMarks.DigitLine.Visible = False
    ExMarks.ImageLine.Color = clGray
    ExMarks.ImageLine.Visible = False
    ExMarks.Img0Line.Color = clGray
    ExMarks.Img0Line.Visible = False
    ExMarks.Img1Line.Color = clGray
    ExMarks.Img1Line.Visible = False
    ExMarks.Img2Line.Color = clGray
    ExMarks.Img2Line.Visible = False
    ExMarks.Img3Line.Color = clGray
    ExMarks.Img3Line.Visible = False
    ExMarks.Img4Line.Color = clGray
    ExMarks.Img4Line.Visible = False
    ExMarks.Img5Line.Color = clGray
    ExMarks.Img5Line.Visible = False
    ExMarks.EvenLine.Color = clGray
    ExMarks.EvenLine.Visible = False
    ExSearchOptions = []
    VerticalLines = <>
    Left = 336
    Top = 128
  end
  object imgsMain: TImageList
    Height = 20
    Width = 20
    Left = 368
    Top = 128
    Bitmap = {
      494C01010A000E00040014001400FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000500000005000000001002000000000000064
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000042840000428400004284000042840000428400004284000042
      8400004284000042840000428400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000004284000042
      8400000000000000000000000000000000000042840000428400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00004A8CCE004A8CCE008CFFFF008CFFFF008CFFFF008CFFFF008CFFFF008CFF
      FF008CFFFF008CFFFF0000428400004284000000000000000000000000000000
      000000000000000000000000000000000000000000004A8CCE0052FFFF0000E7
      E7000042840000000000000000004A8CCE0052FFFF0000E7E700004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00004A8CCE0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FF
      FF0073FFFF0073FFFF0073FFFF00004284000000000000000000000000000000
      000000000000000000000000000000000000000000004A8CCE0052FFFF0052FF
      FF000042840000000000000000004A8CCE0052FFFF0052FFFF00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00004A8CCE0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FF
      FF0073FFFF0073FFFF0073FFFF00004284000000000000000000000000000000
      000000000000000000000000000000000000000000004A8CCE0052FFFF0052FF
      FF000042840000000000000000004A8CCE0052FFFF0052FFFF00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00004A8CCE0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FF
      FF0073FFFF0073FFFF0073FFFF00004284000000000000000000000000000000
      000000000000000000000000000000000000000000004A8CCE0052FFFF0052FF
      FF000042840000000000000000004A8CCE0052FFFF0052FFFF00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00004A8CCE0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FF
      FF0073FFFF0073FFFF0073FFFF00004284000000000000000000000000000000
      000000000000000000000000000000000000000000004A8CCE0052FFFF0052FF
      FF000042840000000000000000004A8CCE0052FFFF0052FFFF00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00004A8CCE0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FF
      FF0073FFFF0073FFFF0073FFFF00004284000000000000000000000000000000
      000000000000000000000000000000000000000000004A8CCE0052FFFF0052FF
      FF000042840000000000000000004A8CCE0052FFFF0052FFFF00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00004A8CCE0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FF
      FF0073FFFF0073FFFF0073FFFF00004284000000000000000000000000000000
      000000000000000000000000000000000000000000004A8CCE0052FFFF0052FF
      FF000042840000000000000000004A8CCE0052FFFF0052FFFF00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00004A8CCE0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FF
      FF0073FFFF0073FFFF0073FFFF00004284000000000000000000000000000000
      000000000000000000000000000000000000000000004A8CCE0052FFFF0052FF
      FF000042840000000000000000004A8CCE0052FFFF0052FFFF00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00004A8CCE008CFFFF008CFFFF008CFFFF008CFFFF008CFFFF008CFFFF008CFF
      FF008CFFFF008CFFFF008CFFFF00004284000000000000000000000000000000
      000000000000000000000000000000000000000000004A8CCE008CFFFF0052FF
      FF000042840000000000000000004A8CCE008CFFFF0052FFFF00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00004A8CCE004A8CCE00ADFFFF00ADFFFF00ADFFFF00ADFFFF00ADFFFF00ADFF
      FF00ADFFFF00ADFFFF004A8CCE00004284000000000000000000000000000000
      000000000000000000000000000000000000000000004A8CCE008CFFFF008CFF
      FF000042840000000000000000004A8CCE008CFFFF008CFFFF00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000004A8CCE004A8CCE004A8CCE004A8CCE004A8CCE004A8CCE004A8C
      CE004A8CCE004A8CCE004A8CCE00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000004A8CCE004A8C
      CE00000000000000000000000000000000004A8CCE004A8CCE00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000428400004284000042
      8400004284000042840000428400004284000042840000428400004284000042
      8400004284000042840000428400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000428400000000000000000000000000000000000000
      0000000000000042840000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000007B9CBD00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF0000428400000000000000000000000000000000000000
      0000000000000000000000000000000000000042840000428400004284000042
      8400004284000042840000428400004284000042840000428400004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000004284005A84AD00004284000000000000000000000000000000
      0000004284005A84AD0000428400000000000000000000000000000000000000
      000000000000000000000000000000000000000000007B9CBD00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF0000428400000000000000000000000000000000000000
      0000000000000000000000000000000000007B9CBD00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00004284000000
      00000000000000000000396B9C0018528C0018528C0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000004284005A84AD00000000005A84AD000042840000000000000000000042
      84005A84AD00000000005A84AD00004284000000000000000000000000000000
      000000000000000000000000000000000000000000007B9CBD00BDE7FF00BDE7
      FF007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9C
      BD00BDE7FF00BDE7FF0000428400000000000000000000000000000000000000
      0000000000000000000000000000000000007B9CBD00BDE7FF007B9CBD007B9C
      BD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD00BDE7FF00004284000000
      00000000000000000000396B9C0073FFFF00396B9C00396B9C0018528C000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000042
      84005A84AD000000000000000000000000000042840000000000000000000042
      84000000000000000000000000005A84AD000042840000000000000000000000
      000000428400004284000042840000428400004284007B9CBD00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF0000428400000000000000000000428400004284000042
      8400004284000042840000428400004284007B9CBD00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00004284000000
      00000000000000000000396B9C0073FFFF0073FFFF0073FFFF00396B9C00396B
      9C0018528C000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000042
      84005A84AD005A84AD00000000005A84AD000042840000000000000000000042
      84005A84AD00000000005A84AD005A84AD000042840000000000000000000000
      00007B9CBD00BDE7FF00BDE7FF00BDE7FF00BDE7FF007B9CBD00BDE7FF00A5FF
      FF007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9C
      BD00BDE7FF00BDE7FF0000428400000000007B9CBD00D6FFFF00D6FFFF00D6FF
      FF00D6FFFF00D6FFFF00D6FFFF00D6FFFF007B9CBD00BDE7FF007B9CBD007B9C
      BD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD00BDE7FF00004284000000
      00000000000000000000396B9C0073FFFF0073FFFF0073FFFF0073FFFF0073FF
      FF00396B9C00396B9C0018528C00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000428400004284005A84AD00004284000042840000000000000000000042
      8400004284005A84AD0000428400004284000000000000000000000000000000
      00007B9CBD00BDE7FF00BDE7FF00BDE7FF00BDE7FF007B9CBD00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF0000428400000000007B9CBD00D6FFFF00D6FFFF00D6FF
      FF00D6FFFF00D6FFFF00D6FFFF00D6FFFF007B9CBD00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00004284000000
      00000000000000000000396B9C0073FFFF0073FFFF0073FFFF0073FFFF0073FF
      FF0073FFFF0073FFFF00396B9C00396B9C0018528C0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000428400004284000000000000428400004284000000
      0000004284000042840000000000000000000000000000000000000000000000
      00007B9CBD00BDE7FF00BDE7FF00BDE7FF00BDE7FF007B9CBD00BDE7FF00BDE7
      FF007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9C
      BD00BDE7FF00BDE7FF0000428400000000007B9CBD00D6FFFF00D6FFFF00D6FF
      FF00D6FFFF00D6FFFF00D6FFFF00D6FFFF007B9CBD00BDE7FF007B9CBD007B9C
      BD007B9CBD00BDE7FF00BDE7FF00004284000042840000428400004284000000
      00000000000000000000396B9C0073FFFF0073FFFF0073FFFF0073FFFF0073FF
      FF0073FFFF0073FFFF0073FFFF0073FFFF00396B9C00396B9C0018528C000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000428400004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007B9CBD00BDE7FF00BDE7FF00BDE7FF00BDE7FF007B9CBD00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF0000428400000000007B9CBD00D6FFFF00D6FFFF00D6FF
      FF00D6FFFF00D6FFFF00D6FFFF00D6FFFF007B9CBD00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00004284007B9CBD0000428400000000000000
      00000000000000000000396B9C0073FFFF0073FFFF0073FFFF0073FFFF0073FF
      FF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF00396B9C00396B
      9C00000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000428400BDE7FF00BDE7FF000042
      8400000000000000000000000000000000000000000000000000000000000000
      00007B9CBD00BDE7FF00BDE7FF00BDE7FF00BDE7FF007B9CBD00BDE7FF00BDE7
      FF007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9C
      BD00BDE7FF00BDE7FF0000428400000000007B9CBD00D6FFFF00D6FFFF00D6FF
      FF00D6FFFF00D6FFFF00D6FFFF00D6FFFF007B9CBD00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00004284000042840000000000000000000000
      00000000000000000000396B9C0073FFFF0073FFFF0073FFFF0073FFFF0073FF
      FF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF00396B
      9C0018528C000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000428400BDE7FF0000428400004284007BBD
      FF00004284000000000000000000000000000000000000000000000000000000
      00007B9CBD00BDE7FF00BDE7FF00BDE7FF00BDE7FF007B9CBD00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF0000428400000000007B9CBD00D6FFFF00D6FFFF00D6FF
      FF00D6FFFF00D6FFFF00D6FFFF00D6FFFF007B9CBD007B9CBD007B9CBD007B9C
      BD007B9CBD007B9CBD007B9CBD00004284000000000000000000000000000000
      00000000000000000000396B9C0073FFFF0073FFFF0073FFFF0073FFFF0073FF
      FF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FF
      FF00396B9C000000000000000000000000000000000000000000000000000000
      0000000000000000000000428400BDE7FF000042840000000000000000000042
      84007BBDFF000042840000000000000000000000000000000000000000000000
      00007B9CBD00BDE7FF00BDE7FF00BDE7FF00BDE7FF007B9CBD00BDE7FF00BDE7
      FF007B9CBD007B9CBD007B9CBD007B9CBD00BDE7FF00BDE7FF00004284000042
      8400004284000042840000428400000000007B9CBD00D6FFFF00D6FFFF00D6FF
      FF00D6FFFF00D6FFFF00D6FFFF00D6FFFF00D6FFFF00D6FFFF00D6FFFF00D6FF
      FF00D6FFFF00D6FFFF00D6FFFF00004284000000000000000000000000000000
      00000000000000000000396B9C0073FFFF0073FFFF0073FFFF0073FFFF0073FF
      FF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF00396B
      9C00000000000000000000000000000000000000000000000000000000000000
      00000000000000428400BDE7FF00004284000000000000000000000000000000
      0000004284007BBDFF0000428400000000000000000000000000000000000000
      00007B9CBD00BDE7FF00BDE7FF00BDE7FF00BDE7FF007B9CBD00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00004284007B9C
      BD007B9CBD000042840000000000000000007B9CBD00D6FFFF00D6FFFF00D6FF
      FF00D6FFFF00D6FFFF00D6FFFF00D6FFFF00D6FFFF00D6FFFF00D6FFFF00D6FF
      FF00D6FFFF00D6FFFF00D6FFFF00004284000000000000000000000000000000
      00000000000000000000396B9C0073FFFF0073FFFF0073FFFF0073FFFF0073FF
      FF0073FFFF0073FFFF0073FFFF0073FFFF0073FFFF00396B9C00396B9C000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000428400BDE7FF00004284000000000000000000000000000000
      0000004284007BBDFF0000428400000000000000000000000000000000000000
      00007B9CBD00BDE7FF00BDE7FF00BDE7FF00BDE7FF007B9CBD00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00004284007B9C
      BD00004284000000000000000000000000007B9CBD00D6FFFF00D6FFFF00D6FF
      FF00D6FFFF00D6FFFF00D6FFFF00D6FFFF00D6FFFF00D6FFFF00D6FFFF00D6FF
      FF00D6FFFF00D6FFFF00D6FFFF00004284000000000000000000000000000000
      00000000000000000000396B9C0073FFFF0073FFFF0073FFFF0073FFFF0073FF
      FF0073FFFF0073FFFF0073FFFF00396B9C00396B9C0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000428400BDE7FF0000428400000000000000000000000000000000000000
      000000000000004284007BBDFF00004284000000000000000000000000000000
      00007B9CBD00BDE7FF00BDE7FF00BDE7FF00BDE7FF007B9CBD00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00004284000042
      8400000000000000000000000000000000007B9CBD00FFFFFF00D6FFFF0000C6
      C60000C6C60000C6C60000C6C60000C6C60000C6C60000C6C60000C6C60000C6
      C60000C6C600D6FFFF00D6FFFF00004284000000000000000000000000000000
      00000000000000000000396B9C0073FFFF0073FFFF0073FFFF0073FFFF0073FF
      FF0073FFFF00396B9C00396B9C00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000428400BDE7FF0000428400000000000000000000000000000000000000
      000000000000004284007BBDFF00004284000000000000000000000000000000
      00007B9CBD00BDE7FF00BDE7FF00BDE7FF00BDE7FF007B9CBD007B9CBD007B9C
      BD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD00004284000000
      0000000000000000000000000000000000007B9CBD00FFFFFF00D6FFFF0000C6
      C600A5FFFF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CE
      FF0000C6C600D6FFFF00D6FFFF00004284000000000000000000000000000000
      00000000000000000000396B9C00ADFFFF00ADFFFF00ADFFFF00ADFFFF00396B
      9C00396B9C000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000042
      8400BDE7FF000042840000000000000000000000000000000000000000000000
      00000000000000000000004284007BBDFF000042840000000000000000000000
      00007B9CBD00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00004284007B9CBD000042840000000000000000000000
      0000000000000000000000000000000000007B9CBD00FFFFFF00FFFFFF00FFFF
      FF0000C6C600FFFFFF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0000C6
      C600D6FFFF00D6FFFF00D6FFFF00004284000000000000000000000000000000
      00000000000000000000396B9C00C6FFFF00C6FFFF00396B9C00396B9C000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000042
      8400BDE7FF000042840000000000000000000000000000000000000000000000
      00000000000000000000004284007BBDFF000042840000000000000000000000
      00007B9CBD00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF0000428400004284000000000000000000000000000000
      000000000000000000000000000000000000000000007B9CBD007B9CBD007B9C
      BD007B9CBD0000C6C600FFFFFF00A5FFFF00A5FFFF0010CEFF0000C6C6007B9C
      BD007B9CBD007B9CBD007B9CBD00000000000000000000000000000000000000
      00000000000000000000396B9C00396B9C00396B9C0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000004284000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000004284000000000000000000000000000000
      00007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9C
      BD007B9CBD007B9CBD0000428400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000C6C60000C6C600FFFFFF00FFFFFF0000C6C60000C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000C6C60000C6C60000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000004284000042
      8400004284000042840000428400004284000042840000428400004284000042
      8400004284000042840000428400004284000042840000428400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000004284000042
      8400004284000042840000428400004284000042840000428400004284000042
      8400004284000042840000428400004284000042840000428400004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000007B9CBD00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF0000428400000000000000
      0000000000000042840000428400004284000042840000428400004284000042
      8400004284000042840000428400004284000042840000428400004284000000
      00000000000000000000000000000000000000000000004284007B9CBD00396B
      9C0000396B0000396B0000396B0000396B0000396B0000396B0000396B00396B
      9C00ADDEFF00ADDEFF00ADDEFF00ADDEFF00396B9C007B9CBD00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000007B9CBD00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF0000428400000000000000
      0000000000007B9CBD00004284005A84AD005A84AD005A84AD0018528C005A84
      AD0018528C005A84AD0018528C005A84AD0018528C005A84AD00004284000042
      84000000000000000000000000000000000000000000004284007B9CBD00396B
      9C0000396B0000396B0000396B0000396B0000396B0000396B0000396B00396B
      9C00ADDEFF00ADDEFF00ADDEFF00ADDEFF00396B9C007B9CBD00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000007B9CBD00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF0000428400000000000000
      0000000000007B9CBD009CD6FF00004284005A84AD005A84AD005A84AD001852
      8C005A84AD0018528C005A84AD0018528C005A84AD0018528C005A84AD001852
      8C000042840000000000000000000000000000000000004284007B9CBD00396B
      9C0000396B0000396B0000396B0000396B0000396B0000396B0000396B00396B
      9C00ADDEFF00ADDEFF00ADDEFF00ADDEFF00396B9C007B9CBD00004284000000
      0000000000000000000000000000004284000042840000428400004284000042
      8400004284000042840000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000007B9CBD00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF0000428400000000000000
      0000000000007B9CBD009CD6FF009CD6FF00004284005A84AD005A84AD005A84
      AD005A84AD005A84AD005A84AD005A84AD005A84AD005A84AD005A84AD005A84
      AD005A84AD0000428400000000000000000000000000004284007B9CBD00396B
      9C0000396B0000396B0000396B0000396B0000396B0000396B0000396B00396B
      9C00ADDEFF00ADDEFF00ADDEFF00ADDEFF00396B9C007B9CBD00004284000000
      0000000000000000000000000000004284007B9CBD005A84AD005A84AD005A84
      AD00004284000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000007B9CBD00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF0000428400000000000000
      0000000000007B9CBD009CD6FF009CD6FF009CD6FF00004284005A84AD005A84
      AD005A84AD005A84AD005A84AD005A84AD005A84AD005A84AD005A84AD005A84
      AD005A84AD005A84AD00004284000000000000000000004284007B9CBD00396B
      9C00396B9C00396B9C00396B9C00396B9C00396B9C00396B9C00396B9C00396B
      9C00396B9C00396B9C00396B9C00396B9C00396B9C007B9CBD00004284000000
      000000000000000000000000000000428400ADDEFF00ADDEFF007B9CBD000042
      8400000000000000000000000000000000000000000000000000000000000000
      00005A84AD0000000000000000000000000000000000000000007B9CBD00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF0000428400000000000000
      0000000000007B9CBD009CD6FF009CD6FF009CD6FF009CD6FF00004284000042
      8400004284000042840000428400004284000042840000428400004284000042
      84000042840000428400004284000042840000000000004284007B9CBD007B9C
      BD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9C
      BD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD00004284000000
      000000000000000000000000000000428400ADDEFF00ADDEFF00004284005A84
      AD00000000000000000000000000000000000000000000000000000000000000
      0000004284005A84AD00000000000000000000000000000000007B9CBD00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF0039FFFF0039FFFF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF0000428400000000000000
      0000000000007B9CBD009CD6FF009CD6FF009CD6FF009CD6FF009CD6FF009CD6
      FF009CD6FF009CD6FF009CD6FF009CD6FF009CD6FF009CD6FF00004284000000
      00000000000000000000000000000000000000000000004284007B9CBD007B9C
      BD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9C
      BD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD00004284000000
      000000000000000000000000000000428400BDE7FF0000428400000000000042
      84005A84AD000000000000000000000000000000000000000000000000000000
      000000000000004284005A84AD000000000000000000000000007B9CBD00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF0039FFFF00BDE7FF00BDE7FF0039FF
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF0000428400000000000000
      0000000000007B9CBD009CD6FF009CD6FF009CD6FF009CD6FF009CD6FF009CD6
      FF00396B9C009CD6FF009CD6FF009CD6FF009CD6FF009CD6FF00004284000000
      00000000000000000000000000000000000000000000004284007B9CBD00396B
      9C00396B9C00396B9C00396B9C00396B9C00396B9C00396B9C00396B9C00396B
      9C00396B9C00396B9C00396B9C00396B9C00396B9C007B9CBD00004284000000
      0000000000000000000000000000004284000042840000000000000000000000
      0000004284005A84AD0000000000000000000000000000000000000000000000
      000000000000004284005A84AD000000000000000000000000007B9CBD00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF0039FFFF00BDE7FF00BDE7FF0039FF
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF0000428400000000000000
      0000000000007B9CBD009CD6FF009CD6FF009CD6FF009CD6FF009CD6FF009CD6
      FF009CD6FF00396B9C009CD6FF009CD6FF009CD6FF009CD6FF00004284000000
      00000000000000000000000000000000000000000000004284007B9CBD00396B
      9C00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDE
      FF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00396B9C007B9CBD00004284000000
      0000000000000000000000000000004284000000000000000000000000000000
      000000000000004284005A84AD00000000000000000000000000000000000000
      000000000000004284005A84AD000000000000000000000000007B9CBD00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF0039FFFF0039FFFF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF0000428400000000000000
      0000000000007B9CBD009CD6FF009CD6FF009CD6FF009CD6FF009CD6FF009CD6
      FF009CD6FF009CD6FF00396B9C009CD6FF009CD6FF009CD6FF00004284000000
      00000000000000000000000000000000000000000000004284007B9CBD00396B
      9C00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDE
      FF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00396B9C007B9CBD00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000004284005A84AD000000000000000000000000000000
      00005A84AD0000428400000000000000000000000000000000007B9CBD00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF0000428400000000000000
      0000000000007B9CBD007B9CBD009CD6FF009CD6FF009CD6FF007B9CBD007B9C
      BD007B9CBD007B9CBD007B9CBD00396B9C007B9CBD007B9CBD00004284000000
      00000000000000000000000000000000000000000000004284007B9CBD00396B
      9C00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDE
      FF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00396B9C007B9CBD00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000004284005A84AD005A84AD005A84AD005A84
      AD000042840000000000000000000000000000000000000000007B9CBD00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF0000428400000000000000
      000000000000000000007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD000000
      000000000000000000000000000000000000396B9C0000000000000000000000
      00000000000000000000000000000000000000000000004284007B9CBD00396B
      9C00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDE
      FF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00396B9C007B9CBD00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000042840000428400004284000042
      84000000000000000000000000000000000000000000000000007B9CBD00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF000042840000428400004284000042840000428400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000396B9C00000000000000
      0000396B9C0000000000000000000000000000000000004284007B9CBD00396B
      9C00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDE
      FF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00396B9C007B9CBD00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000007B9CBD00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF0000428400396B9C00396B9C000042840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000396B9C00396B
      9C00396B9C0000000000000000000000000000000000004284007B9CBD00396B
      9C00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDE
      FF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00396B9C007B9CBD00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000007B9CBD00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF0000428400396B9C00004284000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000396B9C00396B
      9C00396B9C0000000000000000000000000000000000004284007B9CBD00396B
      9C00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDE
      FF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00396B9C007B9CBD00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000007B9CBD00BDE7
      FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7FF00BDE7
      FF00BDE7FF000042840000428400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000396B9C00396B9C00396B
      9C00396B9C0000000000000000000000000000000000004284007B9CBD00396B
      9C00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00ADDE
      FF00ADDEFF00ADDEFF00ADDEFF00ADDEFF00396B9C007B9CBD00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000007B9CBD007B9C
      BD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9CBD007B9C
      BD007B9CBD000042840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000428400004284000042
      8400004284000042840000428400004284000042840000428400004284000042
      8400004284000042840000428400004284000042840000428400004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000050000000500000000100010000000000C00300000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FFFFFFFFFF00000000000000FFFFFFFFFF00000000000000FFFFFFFFFF000000
      00000000FFFFFFFFFF00000000000000F801FFCF3F00000000000000F000FF86
      1F00000000000000F000FF861F00000000000000F000FF861F00000000000000
      F000FF861F00000000000000F000FF861F00000000000000F000FF861F000000
      00000000F000FF861F00000000000000F000FF861F00000000000000F000FF86
      1F00000000000000F000FF861F00000000000000F801FFCF3F00000000000000
      FFFFFFFFFF00000000000000FFFFFFFFFF00000000000000FFFFFFFFFF000000
      00000000FFFFFFFFFF00000000000000FFFFFF8001FFFFFFFFFF0000FDFBFF80
      01FF001FFFFF0000F8F1FF8001FF001C7FFF0000F264FF8001FF001C1FFF0000
      E76E70000180001C07FF0000E26470000100001C01FF0000F060F0000100001C
      007F0000FC93F0000100001C001F0000FF9FF0000100003C000F0000FF0FF000
      0100007C00070000FE07F000010000FC00070000FC63F000010000FC000F0000
      F8F1F000030000FC001F0000F8F1F000070000FC007F0000F1F8F0000F0000FC
      01FF0000F1F8F0001F0000FC07FF0000E3FC70007F0000FC1FFF0000E3FC7000
      FF8001FC7FFF0000F7FEF001FFF81FFFFFFF0000FFFFFFFFFFFE7FFFFFFF0000
      FFFFFFFFFFFFFFFFFFFF0000C0003FFFFFC0001FFFFF0000C00038001F80001F
      FFFF0000C00038000F80001FFFFF0000C00038000780001E03FF0000C0003800
      0380001E07FF0000C00038000180001E0FF70000C00038000080001E0FF30000
      C00038001F80001E27F90000C00038001F80001E73F90000C00038001F80001E
      F9F90000C00038001F80001FFCF30000C00038001F80001FFE070000C0003C1F
      7F80001FFF0F0000C0003FFFB780001FFFFF0000C0007FFFC780001FFFFF0000
      C000FFFFC780001FFFFF0000C001FFFF8780001FFFFF0000C003FFFFFF80001F
      FFFF0000FFFFFFFFFFFFFFFFFFFF000000000000000000000000000000000000
      000000000000}
  end
  object dlgOpen: TOpenDialog
    DefaultExt = 'nako'
    Filter = 
      #12394#12391#12375#12371#12501#12449#12452#12523'(*.nako)|*.nako|'#12486#12461#12473#12488#12501#12449#12452#12523'(*.txt)|*.txt|'#12377#12409#12390'(*.*)|*.*|HTML|' +
      '*.htm;*.html|Delphi(*.pas;*.dpr)|*.pas;*.dpr|Perl(*.cgi;*.pl;*.p' +
      'm;*pod)|*.pl;*.cgi;*.pm;*.pod|Java|*.java|C++|*.cpp;*.c;*.h'
    Left = 304
    Top = 160
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'nako'
    Filter = 
      #12394#12391#12375#12371#12501#12449#12452#12523'(*.nako)|*.nako|'#12486#12461#12473#12488#12501#12449#12452#12523'(*.txt)|*.txt|'#12377#12409#12390'(*.*)|*.*|HTML|' +
      '*.htm;*.html|Delphi(*.pas;*.dpr)|*.pas;*.dpr|Perl(*.cgi;*.pl)|*.' +
      'pl;*.cgi|Java|*.java|C++|*.cpp;*.c;*.h'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 272
    Top = 160
  end
  object popupMain: TPopupMenu
    Left = 240
    Top = 128
    object popUndo: TMenuItem
      Caption = #20803#12395#25147#12377'(&Z)'
      OnClick = mnuUndoClick
    end
    object N13: TMenuItem
      Caption = '-'
    end
    object popCut: TMenuItem
      Caption = #20999#12426#21462#12426'(&X)'
      OnClick = mnuCutClick
    end
    object popCopy: TMenuItem
      Caption = #12467#12500#12540'(&C)'
      OnClick = mnuCopyClick
    end
    object popPaste: TMenuItem
      Caption = #36028#12426#20184#12369'(&V)'
      OnClick = mnuPasteClick
    end
    object N14: TMenuItem
      Caption = '-'
    end
    object popSelectAll: TMenuItem
      Caption = #12377#12409#12390#36984#25246'(&A)'
      OnClick = mnuSelectAllClick
    end
    object N15: TMenuItem
      Caption = '-'
    end
    object popIndentRight: TMenuItem
      Caption = #12452#12531#12487#12531#12488#8594
      OnClick = mnuIndentRightClick
    end
    object popIndentLeft: TMenuItem
      Caption = #12452#12531#12487#12531#12488#8592
      OnClick = mnuIndentLeftClick
    end
    object N28: TMenuItem
      Caption = '-'
    end
    object N44: TMenuItem
      Caption = #12375#12362#12426
      object N45: TMenuItem
        Caption = #35352#37682
        object popBookmark1: TMenuItem
          Tag = 1
          Caption = '1'
          OnClick = mnuBM1Click
        end
        object popBookmark2: TMenuItem
          Tag = 2
          Caption = '2'
          OnClick = mnuBM1Click
        end
        object popBookmark3: TMenuItem
          Tag = 3
          Caption = '3'
          OnClick = mnuBM1Click
        end
      end
      object N46: TMenuItem
        Caption = #12472#12515#12531#12503
        object popGoBookmark1: TMenuItem
          Tag = 1
          Caption = '1'
          OnClick = mnuBJ1Click
        end
        object popGoBookmark2: TMenuItem
          Tag = 2
          Caption = '2'
          OnClick = mnuBJ1Click
        end
        object popGoBookmark3: TMenuItem
          Tag = 3
          Caption = '3'
          OnClick = mnuBJ1Click
        end
      end
    end
    object N42: TMenuItem
      Caption = #21629#20196#26908#32034
      object mnuFindRuigigo: TMenuItem
        Caption = #39006#32681#35486#26908#32034
        OnClick = mnuFindRuigigoClick
      end
      object popFindSelectWord: TMenuItem
        Caption = #36984#25246#35486#12434'WEB'#12391#26908#32034
        OnClick = popFindSelectWordClick
      end
    end
  end
  object popRecent: TPopupMenu
    Left = 240
    Top = 160
  end
  object popFind: TPopupMenu
    Left = 240
    Top = 192
    object popFindCut: TMenuItem
      Caption = #20999#12426#21462#12426'(&X)'
      ShortCut = 16472
      OnClick = popFindCutClick
    end
    object popFindCopy: TMenuItem
      Caption = #12467#12500#12540'(&C)'
      ShortCut = 16451
      OnClick = popFindCopyClick
    end
    object popFindPaste: TMenuItem
      Caption = #36028#12426#20184#12369'(&V)'
      ShortCut = 16470
      OnClick = popFindPasteClick
    end
  end
  object popListFind: TPopupMenu
    Left = 336
    Top = 160
    object popListFindGoto: TMenuItem
      AutoHotkeys = maManual
      AutoLineReduction = maManual
      Caption = #23550#35937#34892#12408#39131#12406'(&G)'
      OnClick = popListFindGotoClick
    end
    object N24: TMenuItem
      Caption = '-'
    end
    object N23: TMenuItem
      AutoHotkeys = maManual
      AutoLineReduction = maManual
      Caption = #12375#12362#12426#12395#30331#37682'(&R)'
      object popListFindMem1: TMenuItem
        Tag = 1
        Caption = '1'
        OnClick = popListFindMem1Click
      end
      object popListFindMem2: TMenuItem
        Tag = 2
        Caption = '2'
        OnClick = popListFindMem1Click
      end
      object popListFindMem3: TMenuItem
        Tag = 3
        Caption = '3'
        OnClick = popListFindMem1Click
      end
      object popListFindMem4: TMenuItem
        Tag = 4
        Caption = '4'
        OnClick = popListFindMem1Click
      end
      object popListFindMem5: TMenuItem
        Tag = 5
        Caption = '5'
        OnClick = popListFindMem1Click
      end
    end
  end
  object popTabList: TPopupMenu
    OnPopup = popTabListPopup
    Left = 240
    Top = 224
    object popTabListIns: TMenuItem
      Caption = #12456#12487#12451#12479#12408#25407#20837'(&I)'
      OnClick = popTabListInsClick
    end
    object N25: TMenuItem
      Caption = '-'
    end
    object popTabListGoto: TMenuItem
      Caption = #23550#35937#34892#12408#39131#12406'(&G)'
      OnClick = popTabListGotoClick
    end
    object N43: TMenuItem
      Caption = '-'
    end
    object popFindDefine: TMenuItem
      Caption = #23450#32681#12434#26908#32034
      OnClick = popFindDefineClick
    end
  end
  object XPManifest1: TXPManifest
    Left = 272
    Top = 192
  end
  object popCmd: TPopupMenu
    Left = 240
    Top = 256
    object mnuLookWeb: TMenuItem
      Caption = #21629#20196#12398#35299#35500#12434#35211#12427'(Web)'
      ShortCut = 112
      OnClick = mnuLookWebClick
    end
    object N56: TMenuItem
      Caption = '-'
    end
    object mnuViewMan: TMenuItem
      Caption = #35443#12375#12356#35299#35500#12434#35211#12427'(local)'
      ShortCut = 8304
      OnClick = mnuViewManClick
    end
    object mnuSayCmdDescript: TMenuItem
      Caption = #21629#20196#12398#35500#26126#12434#35328#12358
      OnClick = mnuSayCmdDescriptClick
    end
    object N39: TMenuItem
      Caption = '-'
    end
    object popInsCmd: TMenuItem
      Caption = #21629#20196#12434#12456#12487#12451#12479#12408#25407#20837'(&I)'
      OnClick = popInsCmdClick
    end
    object mnuCopyCmd: TMenuItem
      Caption = #21629#20196#12434#12463#12522#12483#12503#12508#12540#12489#12395#12467#12500#12540
      ShortCut = 16451
      OnClick = mnuCopyCmdClick
    end
  end
  object dlgFont: TFontDialog
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = []
    Options = []
    Left = 304
    Top = 192
  end
  object imgsTab: TImageList
    Left = 304
    Top = 128
    Bitmap = {
      494C01010C000E00040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000004000000001002000000000000040
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000848484008484
      8400848484008484840084848400848484008484840084848400848484008484
      84008484840084848400848484008484840000000000FF000000848484008484
      8400848484008484840084848400848484008484840084848400848484008484
      84008484840084848400848484008484840000000000FF000000848484008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484008484840084848400848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF000000FF00FF00FF000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF008484840084848400FF000000FF00FF00FF000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF008484840084848400FF000000FF00FF00FF000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084848400848484000000000000000000000000000000
      0000000000000000000000428400004284000042840000428400000000000000
      00000000000000000000000000000000000000000000FF000000FFFFFF00FFFF
      FF00FFFFFF0084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0084848400FF00FF00FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0084848400FF00FF00FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00848484000000000000000000000000000000
      00000042840000428400007BFF00007BFF00007BFF00007BFF00004284000042
      84000000000000000000000000000000000000000000FF000000FFFFFF00FFFF
      FF008400000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0084848400FF00FF00FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0084848400FF00FF00FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00848484000000000000000000000000000042
      8400007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF000042840000000000000000000000000000000000FF000000FFFFFF008400
      0000840000008400000084000000840000008400000084000000840000008400
      00008400000084000000FFFFFF0084848400FF00FF00FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0084848400FF00FF00FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00848484000000000000000000000000000042
      8400007BFF00007BFF006BFFFF006BFFFF006BFFFF006BFFFF00007BFF00007B
      FF000042840000000000000000000000000000000000FF000000FFFFFF00FFFF
      FF008400000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0084848400FF00FF00FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      FF00FFFFFF00FFFFFF00FFFFFF0084848400FF00FF00FF000000FFFFFF00FFFF
      FF00FFFFFF0084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0084848400000000000000000000428400007B
      FF00007BFF006BFFFF00007BFF006BFFFF006BFFFF00007BFF006BFFFF00007B
      FF00007BFF0000428400000000000000000000000000FF000000FFFFFF00FFFF
      FF00FFFFFF0084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0084848400FF00FF00FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      FF000000FF00FFFFFF00FFFFFF0084848400FF00FF00FF000000FFFFFF00FFFF
      FF008400000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0084848400000000000000000000428400007B
      FF00007BFF006BFFFF006BFFFF006BFFFF006BFFFF006BFFFF006BFFFF00007B
      FF00007BFF0000428400000000000000000000000000FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      FF00FFFFFF00FFFFFF00FFFFFF0084848400FF00FF00FF000000FFFFFF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF00FFFFFF0084848400FF00FF00FF000000FFFFFF008400
      0000840000008400000084000000840000008400000084000000840000008400
      00008400000084000000FFFFFF0084848400000000000000000000428400007B
      FF00007BFF006BFFFF006BFFFF006BFFFF006BFFFF006BFFFF006BFFFF00007B
      FF00007BFF0000428400000000000000000000000000FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      FF000000FF00FFFFFF00FFFFFF0084848400FF00FF00FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      FF000000FF00FFFFFF00FFFFFF0084848400FF00FF00FF000000FFFFFF00FFFF
      FF008400000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0084848400000000000000000000428400007B
      FF00007BFF006BFFFF00007BFF006BFFFF006BFFFF00007BFF006BFFFF00007B
      FF00007BFF0000428400000000000000000000000000FF000000FFFFFF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF00FFFFFF0084848400FF00FF00FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      FF00FFFFFF00FFFFFF00FFFFFF0084848400FF00FF00FF000000FFFFFF00FFFF
      FF00FFFFFF0084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00848484000000000000000000000000000042
      8400007BFF00007BFF006BFFFF006BFFFF006BFFFF006BFFFF00007BFF00007B
      FF000042840000000000000000000000000000000000FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      FF000000FF00FFFFFF00FFFFFF0084848400FF00FF00FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0084848400FF00FF00FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00848484000000000000000000000000000042
      8400007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF000042840000000000000000000000000000000000FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      FF00FFFFFF00FFFFFF00FFFFFF0084848400FF00FF00FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0084848400FF00FF00FF000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00848484000000000000000000000000000000
      00000042840000428400007BFF00007BFF00007BFF00007BFF00004284000042
      840000000000000000000000000000000000FF000000FF00FF00FF000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF008484840084848400FF000000FF00FF00FF000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF008484840084848400FF000000FF00FF00FF000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084848400848484000000000000000000000000000000
      0000000000000000000000428400004284000042840000428400000000000000
      00000000000000000000000000000000000000000000FF000000848484008484
      8400848484008484840084848400848484008484840084848400848484008484
      84008484840084848400848484008484840000000000FF000000848484008484
      8400848484008484840084848400848484008484840084848400848484008484
      84008484840084848400848484008484840000000000FF000000848484008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484008484840084848400848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000004284000042
      8400004284000042840000428400004284000042840000428400004284000042
      8400004284000042840000000000000000000000000000428400004284000042
      8400004284000042840000428400004284000042840000428400004284000042
      8400004284000042840000428400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000005A84AD0010CE
      FF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CE
      FF0010CEFF00004284000000000000000000000000005A84AD0010CEFF0010CE
      FF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CE
      FF0010CEFF0010CEFF0000428400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000005A84AD0010CE
      FF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CE
      FF0010CEFF00004284000000000000000000000000005A84AD0010CEFF0000A5
      FF0000A5FF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CE
      FF0010CEFF0010CEFF0000428400000000000000000000000000000000000000
      0000004284000042840000428400007BFF00007BFF0000428400004284000042
      8400000000000000000000000000000000000000000000000000000000000000
      000000FFFF0000FFFF0000FFFF00FF000000FF00000000FFFF0000FFFF0000FF
      FF000000000000000000000000000000000000000000000000005A84AD0010CE
      FF0010CEFF0000A5FF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CE
      FF0010CEFF00004284000000000000000000000000005A84AD0010CEFF0010CE
      FF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CE
      FF0010CEFF0010CEFF0000428400000000000000000000000000000000000042
      8400007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF000042840000000000000000000000000000000000000000000000000000FF
      FF00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000FFFF0000000000000000000000000000000000000000005A84AD0010CE
      FF0010CEFF0000A5FF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CE
      FF0010CEFF00004284000000000000000000000000005A84AD005A84AD005A84
      AD005A84AD005A84AD005A84AD0010CEFF0010CEFF0000428400004284000042
      8400004284000042840000428400000000000000000000000000000000000042
      8400007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF000042840000000000000000000000000000000000000000000000000000FF
      FF00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000FFFF0000000000000000000000000000000000000000005A84AD0010CE
      FF0010CEFF0000A5FF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CE
      FF0010CEFF000042840000000000000000000000000000000000000000000000
      000000000000000000005A84AD0010CEFF0010CEFF0000428400000000000000
      0000000000000000000000000000000000000000000000000000000000000042
      8400007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF000042840000000000000000000000000000000000000000000000000000FF
      FF00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000FFFF0000000000000000000000000000000000000000005A84AD0010CE
      FF0000A5FF0000A5FF0000A5FF0010CEFF0010CEFF0010CEFF0010CEFF0010CE
      FF0010CEFF000042840000000000000000000000000000000000000000000000
      000000000000000000005A84AD0010CEFF0010CEFF0000428400000000000000
      000000000000000000000000000000000000000000000000000000000000007B
      FF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF00007BFF00000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF00000000000000000000000000000000000000000000005A84AD0010CE
      FF0010CEFF0000A5FF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CE
      FF0010CEFF000042840000000000000000000000000000000000000000000000
      000000000000000000005A84AD0010CEFF0010CEFF0000428400000000000000
      000000000000000000000000000000000000000000000000000000000000007B
      FF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF00007BFF00000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF00000000000000000000000000000000000000000000005A84AD0010CE
      FF0000A5FF0000A5FF0000A5FF0010CEFF0010CEFF0010CEFF0010CEFF0010CE
      FF0010CEFF000042840000000000000000000000000000000000000000000000
      000000000000000000005A84AD0010CEFF0010CEFF0000428400000000000000
      0000000000000000000000000000000000000000000000000000000000000042
      8400007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF000042840000000000000000000000000000000000000000000000000000FF
      FF00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000FFFF0000000000000000000000000000000000000000005A84AD0010CE
      FF0010CEFF0000A5FF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CE
      FF0010CEFF000042840000000000000000000000000000000000000000000000
      000000000000000000005A84AD0010CEFF0010CEFF0000428400000000000000
      0000000000000000000000000000000000000000000000000000000000000042
      8400007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF000042840000000000000000000000000000000000000000000000000000FF
      FF00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000FFFF0000000000000000000000000000000000000000005A84AD0010CE
      FF0010CEFF0000A5FF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CE
      FF0010CEFF000042840000000000000000000000000000000000000000000000
      000000000000000000005A84AD0010CEFF0010CEFF0000428400000000000000
      0000000000000000000000000000000000000000000000000000000000000042
      8400007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF000042840000000000000000000000000000000000000000000000000000FF
      FF00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000FFFF0000000000000000000000000000000000000000005A84AD0010CE
      FF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CE
      FF0010CEFF000042840000000000000000000000000000000000000000000000
      000000000000000000005A84AD0010CEFF0010CEFF0000428400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000004284000042840000428400007BFF00007BFF0000428400004284000042
      8400000000000000000000000000000000000000000000000000000000000000
      000000FFFF0000FFFF0000FFFF00FF000000FF00000000FFFF0000FFFF0000FF
      FF000000000000000000000000000000000000000000000000005A84AD0010CE
      FF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CEFF0010CE
      FF0010CEFF000042840000000000000000000000000000000000000000000000
      000000000000000000005A84AD0010CEFF0010CEFF0000428400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000005A84AD005A84
      AD005A84AD005A84AD005A84AD005A84AD005A84AD005A84AD005A84AD005A84
      AD005A84AD000042840000000000000000000000000000000000000000000000
      000000000000000000005A84AD005A84AD005A84AD0000428400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000428400004284000042840000428400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000042840000428400004284000042840000428400004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000428400004284000042
      8400004284000042840000428400004284000042840000428400004284000042
      8400004284000042840000428400000000000000000000000000000000000000
      0000000000000000000000428400007BFF00007BFF0000428400000000000000
      000000000000000000000000000000000000000000000000000073FFFF000000
      0000000000000042840052FFFF0052FFFF0052FFFF0052FFFF00004284000000
      00000000000073FFFF0000000000000000000000000000000000004284000042
      8400004284000042840000428400004284000042840000428400004284000042
      840000428400004284000000000000000000000000005A84AD00BDFFFF0094EF
      EF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EF
      EF0094EFEF0094EFEF0000428400000000000000000000000000000000000000
      0000000000000000000000428400007BFF00007BFF0000428400000000000000
      00000000000000000000000000000000000000000000000000000000000073FF
      FF00000000000042840052FFFF0052FFFF0052FFFF0052FFFF00004284000000
      000073FFFF0000000000000000000000000000000000000000005A84AD00007B
      FF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF00007BFF00004284000000000000000000000000005A84AD00BDFFFF0094EF
      EF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EF
      EF0094EFEF0094EFEF0000428400000000000000000000000000000000000000
      0000000000000000000000428400007BFF00007BFF0000428400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000042840052FFFF0052FFFF0052FFFF0052FFFF00004284000000
      00000000000000000000000000000000000000000000000000005A84AD00007B
      FF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF00007BFF00004284000000000000000000000000005A84AD00BDFFFF0094EF
      EF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EF
      EF0094EFEF0094EFEF0000428400000000000000000000000000000000000000
      0000000000000000000000428400007BFF00007BFF0000428400000000000000
      0000000000000000000000000000000000000000000000428400004284000042
      8400004284000042840052FFFF0052FFFF0052FFFF0052FFFF00004284000042
      84000042840000428400004284000000000000000000000000005A84AD00007B
      FF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF00007BFF00004284000000000000000000000000005A84AD00BDFFFF0094EF
      EF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EF
      EF0094EFEF0094EFEF0000428400000000000000000000428400004284000042
      8400004284000042840000428400007BFF00007BFF0000428400004284000042
      840000428400004284000042840000000000000000004A8CCE0052FFFF0052FF
      FF0052FFFF0052FFFF0052FFFF0052FFFF0052FFFF0052FFFF0052FFFF0052FF
      FF0052FFFF0052FFFF00004284000000000000000000000000005A84AD00007B
      FF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF00007BFF00004284000000000000000000000000005A84AD00BDFFFF0094EF
      EF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EF
      EF0094EFEF0094EFEF000042840000000000000000005A84AD00007BFF00007B
      FF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF00007BFF00007BFF000042840000000000000000004A8CCE0052FFFF0052FF
      FF0052FFFF0052FFFF0052FFFF0052FFFF0052FFFF0052FFFF0052FFFF0052FF
      FF0052FFFF0052FFFF00004284000000000000000000000000005A84AD00007B
      FF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF00007BFF00004284000000000000000000000000005A84AD00BDFFFF0094EF
      EF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EF
      EF0094EFEF0094EFEF000042840000000000000000005A84AD00007BFF00007B
      FF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF00007BFF00007BFF000042840000000000000000004A8CCE0052FFFF0052FF
      FF0052FFFF0052FFFF0052FFFF0052FFFF0052FFFF0052FFFF0052FFFF0052FF
      FF0052FFFF0052FFFF00004284000000000000000000000000005A84AD00007B
      FF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF00007BFF00004284000000000000000000000000005A84AD00BDFFFF0094EF
      EF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EF
      EF0094EFEF0094EFEF000042840000000000000000005A84AD005A84AD005A84
      AD005A84AD005A84AD005A84AD00007BFF00007BFF0000428400004284000042
      840000428400004284000042840000000000000000004A8CCE00ADFFFF00ADFF
      FF00ADFFFF00ADFFFF0052FFFF0052FFFF0052FFFF0052FFFF0052FFFF0052FF
      FF0052FFFF0052FFFF00004284000000000000000000000000005A84AD00007B
      FF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007BFF00007B
      FF00007BFF00004284000000000000000000000000005A84AD00BDFFFF0094EF
      EF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EFEF0094EF
      EF0094EFEF0094EFEF0000428400000000000000000000000000000000000000
      000000000000000000005A84AD00007BFF00007BFF0000428400000000000000
      000000000000000000000000000000000000000000004A8CCE004A8CCE004A8C
      CE004A8CCE004A8CCE0052FFFF0052FFFF0052FFFF0052FFFF00004284000042
      84000042840000428400004284000000000000000000000000005A84AD005A84
      AD00007BFF00007BFF0000428400004284000042840000428400004284000042
      840000428400004284000000000000000000000000005A84AD00BDFFFF00BDFF
      FF00BDFFFF00BDFFFF00BDFFFF00BDFFFF00BDFFFF00BDFFFF00BDFFFF00BDFF
      FF00BDFFFF00BDFFFF0000428400000000000000000000000000000000000000
      000000000000000000005A84AD00007BFF00007BFF0000428400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000004A8CCE0052FFFF0052FFFF0052FFFF0052FFFF00004284000000
      0000000000000000000000000000000000000000000000000000000000005A84
      AD00007BFF00007BFF0000428400000000000000000000000000000000000000
      000000000000000000000000000000000000000000005A84AD005A84AD005A84
      AD00BDFFFF0094EFEF0000428400004284000042840000428400004284000042
      8400004284000042840000428400000000000000000000000000000000000000
      000000000000000000005A84AD00007BFF00007BFF0000428400000000000000
      00000000000000000000000000000000000000000000000000000000000073FF
      FF00000000004A8CCE0052FFFF0052FFFF0052FFFF0052FFFF00004284000000
      000073FFFF000000000000000000000000000000000000000000000000005A84
      AD005A84AD005A84AD0000428400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000005A84
      AD00BDFFFF00BDFFFF0000428400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000005A84AD00007BFF00007BFF0000428400000000000000
      000000000000000000000000000000000000000000000000000073FFFF000000
      0000000000004A8CCE00ADFFFF00ADFFFF00ADFFFF00ADFFFF00004284000000
      00000000000073FFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000005A84
      AD005A84AD005A84AD0000428400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000005A84AD005A84AD005A84AD0000428400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000004A8CCE004A8CCE004A8CCE004A8CCE004A8CCE00004284000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000400000000100010000000000000200000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFFFFFFFFFF800080008000FFFF
      000000000000FC3F800000000000F00F800000000000E007800000000000E007
      800000000000C003800000000000C003800000000000C003800000000000C003
      800000000000E007800000000000E007800000000000F00F000000000000FC3F
      800080008000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0038001FFFFFFFF
      C0038001FFFFFFFFC0038001F00FF00FC0038001E007E007C0038001E007E007
      C003FC3FE007E007C003FC3FE007E007C003FC3FE007E007C003FC3FE007E007
      C003FC3FE007E007C003FC3FE007E007C003FC3FF00FF00FC003FC3FFFFFFFFF
      C003FC3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC3FF81FFFFF8001
      FC3FD81BC0038001FC3FE817C0038001FC3FF81FC0038001FC3F8001C0038001
      80018001C003800180018001C003800180018001C003800180018001C0038001
      FC3F8001C0038001FC3FF81FE1FF8001FC3FE817E1FFE1FFFC3FD81BFFFFE1FF
      FC3FF81FFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object DelphiFountain1: TDelphiFountain
    FileExtList.Strings = (
      '.dpr'
      '.inc'
      '.pas')
    Brackets = <
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clGray
        ItemColor.Style = []
        LeftBracket = '{'
        RightBracket = '}'
      end
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clGray
        ItemColor.Style = []
        LeftBracket = '(*'
        RightBracket = '*)'
      end>
    Reserve.BkColor = clNone
    Reserve.Color = clBlack
    Reserve.Style = [fsBold]
    ReserveWordList.Strings = (
      'absolute'
      'abstract'
      'and'
      'array'
      'as'
      'asm'
      'assembler'
      'automated'
      'begin'
      'case'
      'cdecl'
      'class'
      'const'
      'constructor'
      'default'
      'destructor'
      'dispid'
      'dispinterface'
      'div'
      'do'
      'downto'
      'dynamic'
      'else'
      'end'
      'except'
      'export'
      'exports'
      'external'
      'far'
      'file'
      'finalization'
      'finally'
      'for'
      'forward'
      'function'
      'goto'
      'if'
      'implementation'
      'in'
      'inherited'
      'initialization'
      'inline'
      'interface'
      'is'
      'label'
      'library'
      'message'
      'mod'
      'near'
      'nil'
      'nodefault'
      'not'
      'object'
      'of'
      'or'
      'out'
      'overload'
      'override'
      'packed'
      'pascal'
      'private'
      'procedure'
      'program'
      'property'
      'protected'
      'public'
      'published'
      'raise'
      'readonly'
      'record'
      'register'
      'repeat'
      'resident'
      'resourcestring'
      'safecall'
      'set'
      'shl'
      'shr'
      'stdcall'
      'stored'
      'string'
      'then'
      'threadvar'
      'to'
      'try'
      'type'
      'unit'
      'until'
      'uses'
      'var'
      'virtual'
      'while'
      'with'
      'writeonly'
      'xor')
    Ank.BkColor = clNone
    Ank.Color = clBlack
    Ank.Style = []
    AsmBlock.BkColor = clNone
    AsmBlock.Color = clGreen
    AsmBlock.Style = []
    Comment.BkColor = clNone
    Comment.Color = clGreen
    Comment.Style = []
    DBCS.BkColor = clNone
    DBCS.Color = clOlive
    DBCS.Style = []
    Int.BkColor = clNone
    Int.Color = clNavy
    Int.Style = []
    Str.BkColor = clNone
    Str.Color = clNavy
    Str.Style = []
    Symbol.BkColor = clNone
    Symbol.Color = clBlue
    Symbol.Style = []
    Left = 736
    Top = 64
  end
  object HTMLFountain1: THTMLFountain
    FileExtList.Strings = (
      '.htm'
      '.html')
    Brackets = <
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clMaroon
        ItemColor.Style = []
        LeftBracket = '<!--'
        RightBracket = '-->'
      end>
    Reserve.BkColor = clNone
    Reserve.Color = clBlack
    Reserve.Style = [fsBold]
    ReserveWordList.Strings = (
      '/BODY'
      '/HEAD'
      '/HTML'
      'BODY'
      'HEAD'
      'HTML')
    Ampersand.BkColor = clNone
    Ampersand.Color = clBlue
    Ampersand.Style = []
    Mail.BkColor = clNone
    Mail.Color = clBlue
    Mail.Style = [fsUnderline]
    Str.BkColor = clNone
    Str.Color = clRed
    Str.Style = []
    TagAttribute.BkColor = clNone
    TagAttribute.Color = clNavy
    TagAttribute.Style = []
    TagAttributeValue.BkColor = clNone
    TagAttributeValue.Color = clGreen
    TagAttributeValue.Style = []
    TagColor.BkColor = clNone
    TagColor.Color = clNavy
    TagColor.Style = []
    TagElement.BkColor = clNone
    TagElement.Color = clMaroon
    TagElement.Style = []
    Url.BkColor = clNone
    Url.Color = clBlue
    Url.Style = [fsUnderline]
    Left = 736
    Top = 96
  end
  object CppFountain1: TCppFountain
    FileExtList.Strings = (
      '.c'
      '.cpp'
      '.h'
      '.hpp')
    Brackets = <
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clGreen
        ItemColor.Style = []
        LeftBracket = '/*'
        RightBracket = '*/'
      end>
    Reserve.BkColor = clNone
    Reserve.Color = clBlack
    Reserve.Style = []
    ReserveWordList.Strings = (
      'asm'
      'auto'
      'break'
      'case'
      'catch'
      'char'
      'class'
      'const'
      'continue'
      'default'
      'delete'
      'do'
      'double'
      'else'
      'enum'
      'extern'
      'float'
      'for'
      'friend'
      'goto'
      'if'
      'inline'
      'int'
      'long'
      'new'
      'operator'
      'private'
      'protected'
      'public'
      'register'
      'return'
      'short'
      'signed'
      'sizeof'
      'static'
      'struct'
      'switch'
      'template'
      'this'
      'throw'
      'try'
      'typedef'
      'union'
      'unsigned'
      'virtual'
      'void'
      'volatile'
      'while')
    Ank.BkColor = clNone
    Ank.Color = clNone
    Ank.Style = []
    Comment.BkColor = clNone
    Comment.Color = clGreen
    Comment.Style = []
    DBCS.BkColor = clNone
    DBCS.Color = clNone
    DBCS.Style = []
    Int.BkColor = clNone
    Int.Color = clNavy
    Int.Style = []
    Str.BkColor = clNone
    Str.Color = clNavy
    Str.Style = []
    Symbol.BkColor = clNone
    Symbol.Color = clNavy
    Symbol.Style = []
    PreProcessor.BkColor = clNone
    PreProcessor.Color = clPurple
    PreProcessor.Style = []
    Left = 736
    Top = 128
  end
  object JavaFountain1: TJavaFountain
    FileExtList.Strings = (
      '.class'
      '.java')
    Brackets = <
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clGreen
        ItemColor.Style = []
        LeftBracket = '/*'
        RightBracket = '*/'
      end>
    Reserve.BkColor = clNone
    Reserve.Color = clBlack
    Reserve.Style = []
    ReserveWordList.Strings = (
      'abstract'
      'boolean'
      'break'
      'byte'
      'case'
      'catch'
      'char'
      'class'
      'const'
      'continue'
      'default'
      'do'
      'double'
      'else'
      'extends'
      'final'
      'finally'
      'float'
      'for'
      'goto'
      'if'
      'implements'
      'import'
      'instanceof'
      'int'
      'interface'
      'long'
      'native'
      'new'
      'package'
      'private'
      'protected'
      'public'
      'return'
      'short'
      'static'
      'super'
      'switch'
      'synchronized'
      'this'
      'throw'
      'throws'
      'transient'
      'try'
      'void'
      'volatile'
      'while')
    Ank.BkColor = clNone
    Ank.Color = clNone
    Ank.Style = []
    Comment.BkColor = clNone
    Comment.Color = clGreen
    Comment.Style = []
    DBCS.BkColor = clNone
    DBCS.Color = clNone
    DBCS.Style = []
    Int.BkColor = clNone
    Int.Color = clNavy
    Int.Style = []
    Str.BkColor = clNone
    Str.Color = clNavy
    Str.Style = []
    Symbol.BkColor = clNone
    Symbol.Color = clBlue
    Symbol.Style = []
    Left = 736
    Top = 160
  end
  object PerlFountain1: TPerlFountain
    FileExtList.Strings = (
      '.cgi'
      '.pl'
      '.pm'
      '.pod')
    Brackets = <>
    Reserve.BkColor = clNone
    Reserve.Color = clBlack
    Reserve.Style = [fsBold]
    ReserveWordList.Strings = (
      'cmp'
      'do'
      'else'
      'elsif'
      'eq'
      'for'
      'foreach'
      'ge'
      'gt'
      'if'
      'le'
      'lt'
      'ne'
      'package'
      'require'
      'return'
      'sub'
      'unless'
      'until'
      'use'
      'while')
    Ampersand.BkColor = clNone
    Ampersand.Color = clNavy
    Ampersand.Style = []
    Ank.BkColor = clNone
    Ank.Color = clNone
    Ank.Style = []
    BackQuotation.BkColor = clNone
    BackQuotation.Color = clNavy
    BackQuotation.Style = []
    Comment.BkColor = clNone
    Comment.Color = clGreen
    Comment.Style = []
    DBCS.BkColor = clNone
    DBCS.Color = clNone
    DBCS.Style = []
    DoubleQuotation.BkColor = clNone
    DoubleQuotation.Color = clNavy
    DoubleQuotation.Style = []
    Here.BkColor = clNone
    Here.Color = clNavy
    Here.Style = []
    HereHtml = True
    Int.BkColor = clNone
    Int.Color = clBlue
    Int.Style = []
    LiteralQuotation.BkColor = clNone
    LiteralQuotation.Color = clNavy
    LiteralQuotation.Style = []
    Pattern.BkColor = clNone
    Pattern.Color = clGreen
    Pattern.Style = []
    PerlVar.BkColor = clNone
    PerlVar.Color = clMaroon
    PerlVar.Style = []
    SingleQuotation.BkColor = clNone
    SingleQuotation.Color = clNavy
    SingleQuotation.Style = []
    Symbol.BkColor = clNone
    Symbol.Color = clBlue
    Symbol.Style = []
    TagAttribute.BkColor = clNone
    TagAttribute.Color = clMaroon
    TagAttribute.Style = []
    TagAttributeValue.BkColor = clNone
    TagAttributeValue.Color = clGreen
    TagAttributeValue.Style = []
    TagColor.BkColor = clNone
    TagColor.Color = clMaroon
    TagColor.Style = []
    TagElement.BkColor = clNone
    TagElement.Color = clPurple
    TagElement.Style = []
    Left = 736
    Top = 192
  end
  object HimawariFountain1: THimawariFountain
    FileExtList.Strings = (
      '.hmw'
      '.txt')
    Brackets = <
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clMaroon
        ItemColor.Style = []
        LeftBracket = '{'
        RightBracket = '}'
      end
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clMaroon
        ItemColor.Style = []
        LeftBracket = #65371
        RightBracket = #65373
      end
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clNavy
        ItemColor.Style = []
        LeftBracket = #12300
        RightBracket = #12301
      end
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clNavy
        ItemColor.Style = []
        LeftBracket = #12302
        RightBracket = #12303
      end
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clNavy
        ItemColor.Style = []
        LeftBracket = '`'
        RightBracket = '`'
      end
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clNavy
        ItemColor.Style = []
        LeftBracket = '"'
        RightBracket = '"'
      end
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clMaroon
        ItemColor.Style = []
        LeftBracket = '/*'
        RightBracket = '*/'
      end>
    Reserve.BkColor = clNone
    Reserve.Color = clNone
    Reserve.Style = [fsBold]
    ReserveWordList.Strings = (
      #12356#12356#12360
      #12458#12501
      #12362#12431#12426
      #12362#12431#12427
      #12458#12531
      #12461#12515#12531#12475#12523
      #12381#12428
      #12394#12425
      #12394#12425#12400
      #12399#12356
      #12402#12414#12431#12426#12377#12427
      #12418#12375
      #36949
      #22238
      #32368
      #35328
      #32066
      #32154
      #20195#20837
      #25244
      #21453#24489
      #34920#31034
      #25147)
    Ank.BkColor = clNone
    Ank.Color = clNone
    Ank.Style = []
    AsmBlock.BkColor = clNone
    AsmBlock.Color = clNone
    AsmBlock.Style = []
    Comment.BkColor = clNone
    Comment.Color = clMaroon
    Comment.Style = []
    DBCS.BkColor = clNone
    DBCS.Color = clNone
    DBCS.Style = []
    Int.BkColor = clNone
    Int.Color = clGreen
    Int.Style = []
    Str.BkColor = clNone
    Str.Color = clNavy
    Str.Style = []
    Symbol.BkColor = clNone
    Symbol.Color = clBlue
    Symbol.Style = []
    DefLine.BkColor = clNone
    DefLine.Color = clRed
    DefLine.Style = [fsBold]
    Member.BkColor = clNone
    Member.Color = clBlue
    Member.Style = []
    Left = 736
    Top = 224
  end
  object popupStatus: TPopupMenu
    Left = 240
    Top = 288
    object WEB2: TMenuItem
      Caption = #26368#26032#12398#35299#35500#12434#12415#12427'(WEB)'
      OnClick = WEB2Click
    end
    object popStatus: TMenuItem
      Caption = #35443#32048#12394#35299#35500#12434#12415#12427'('#12525#12540#12459#12523')'
      OnClick = popStatusClick
    end
    object N47: TMenuItem
      Caption = '-'
    end
    object popStatusDescriptInBox: TMenuItem
      Caption = #35299#35500#12434#12508#12483#12463#12473#12395#34920#31034
      OnClick = popStatusDescriptInBoxClick
    end
  end
  object NadesikoFountainBlack: TNadesikoFountain
    FileExtList.Strings = (
      '.nako'
      '.txt')
    Brackets = <
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clLime
        ItemColor.Style = []
        LeftBracket = '{'
        RightBracket = '}'
      end
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clYellow
        ItemColor.Style = []
        LeftBracket = #12300
        RightBracket = #12301
      end
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clYellow
        ItemColor.Style = []
        LeftBracket = #12302
        RightBracket = #12303
      end
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clYellow
        ItemColor.Style = []
        LeftBracket = '`'
        RightBracket = '`'
      end
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clYellow
        ItemColor.Style = []
        LeftBracket = '"'
        RightBracket = '"'
      end
      item
        ItemColor.BkColor = clNone
        ItemColor.Color = clSilver
        ItemColor.Style = []
        LeftBracket = '/*'
        RightBracket = '*/'
      end>
    Reserve.BkColor = clNone
    Reserve.Color = clAqua
    Reserve.Style = []
    ReserveWordList.Strings = (
      #12356#12356#12360
      #12456#12521#12540
      #12458#12501
      #12362#12431#12426
      #12362#12431#12427
      #12458#12531
      #12461#12515#12531#12475#12523
      #12464#12523#12540#12503
      #12381#12428
      #12490#12487#12471#12467
      #12394#12425
      #12394#12425#12400
      #12399#12356
      #12495#12483#12471#12517
      #12418#12375
      #12523#12540#12503
      #36949
      #22238
      #30435#35222
      #38291
      #32368
      #35328
      #23455#25968
      #32066
      #26465#20214#20998#23696
      #25968#20516
      #25972#25968
      #32154
      #20195#20837
      #37197#21015
      #25244
      #21453#24489
      #24517#35201
      #34920#31034
      #19981#35201
      #25991#23383#21015
      #22793#25968
      #22793#25968#23459#35328
      #25147)
    Ank.BkColor = clNone
    Ank.Color = clWhite
    Ank.Style = []
    AsmBlock.BkColor = clNone
    AsmBlock.Color = clNone
    AsmBlock.Style = []
    Comment.BkColor = clNone
    Comment.Color = clSilver
    Comment.Style = []
    DBCS.BkColor = clNone
    DBCS.Color = clNone
    DBCS.Style = []
    Int.BkColor = clNone
    Int.Color = clFuchsia
    Int.Style = []
    Str.BkColor = clNone
    Str.Color = clYellow
    Str.Style = []
    Symbol.BkColor = clNone
    Symbol.Color = clAqua
    Symbol.Style = []
    Josi.BkColor = clNone
    Josi.Color = clLime
    Josi.Style = []
    DefLine.BkColor = clNone
    DefLine.Color = clFuchsia
    DefLine.Style = [fsBold]
    Member.BkColor = clNone
    Member.Color = clSilver
    Member.Style = []
    Left = 704
    Top = 96
  end
  object AppEvent: TApplicationEvents
    OnIdle = AppEventIdle
    Left = 272
    Top = 224
  end
  object popupActDesc: TPopupMenu
    Left = 240
    Top = 320
    object popActDescCopy: TMenuItem
      Caption = #12467#12500#12540
      ShortCut = 16451
      OnClick = popActDescCopyClick
    end
    object N51: TMenuItem
      Caption = '-'
    end
    object popActDescMore: TMenuItem
      Caption = #12373#12425#12395#35443#12375#12367'('#12525#12540#12459#12523')'
      OnClick = popActDescMoreClick
    end
    object popLookWeb: TMenuItem
      Caption = #12373#12425#12395#35443#12375#12367'(WEB)'
      OnClick = popLookWebClick
    end
  end
  object popupDesign: TPopupMenu
    Left = 400
    Top = 128
    object mnuDesignDelete: TMenuItem
      Caption = #21066#38500
      OnClick = mnuDesignDeleteClick
    end
  end
  object dlgOpenTemplate: TOpenDialog
    DefaultExt = '.txt'
    Filter = #12486#12461#12473#12488#12501#12449#12452#12523'|*.nako;*.txt;*.bat|'#20840#12390'|*.*'
    Left = 272
    Top = 256
  end
  object dlgSaveTemplate: TSaveDialog
    DefaultExt = '.txt'
    Filter = #12486#12461#12473#12488#24418#24335'|*.nako;*.txt;*.bat|'#12377#12409#12390'|*.*'
    Left = 272
    Top = 288
  end
  object dlgSaveBatchFile: TSaveDialog
    DefaultExt = '.bat'
    Filter = #12496#12483#12481#12501#12449#12452#12523'|*.bat|'#20840#12390'|*.*'
    Left = 272
    Top = 320
  end
  object popGUIFind: TPopupMenu
    Left = 240
    Top = 352
    object popGUIFindCopy: TMenuItem
      Caption = #12467#12500#12540
      ShortCut = 16451
      OnClick = popGUIFindCopyClick
    end
    object popGUIPaste: TMenuItem
      Caption = #36028#12426#20184#12369
      ShortCut = 16470
      OnClick = popGUIPasteClick
    end
  end
  object timerShowWeb: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = timerShowWebTimer
    Left = 368
    Top = 160
  end
end
