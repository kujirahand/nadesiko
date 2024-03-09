object frmNakopad: TfrmNakopad
  Left = 193
  Top = 108
  Width = 810
  Height = 556
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
    Height = 462
  end
  object pageLeft: TPageControl
    Left = 0
    Top = 29
    Width = 217
    Height = 462
    ActivePage = sheetDesignProp
    Align = alLeft
    MultiLine = True
    TabOrder = 0
    OnChange = pageLeftChange
    OnChanging = pageLeftChanging
    object sheetAction: TTabSheet
      Caption = #34892#21205
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 209
        Height = 418
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Splitter2: TSplitter
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
        object edtAction: TRichEdit
          Left = 0
          Top = 267
          Width = 209
          Height = 151
          Align = alClient
          Color = clBtnFace
          Font.Charset = SHIFTJIS_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = #65325#65331' '#12468#12471#12483#12463
          Font.Style = []
          ParentFont = False
          PlainText = True
          PopupMenu = popupActDesc
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 1
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
        Height = 418
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
            ItemHeight = 12
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
          Height = 320
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
        Height = 418
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
            ItemHeight = 12
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
          Height = 336
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
            Height = 243
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
        Height = 214
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
        Height = 418
        Align = alClient
        BevelOuter = bvLowered
        TabOrder = 0
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
            ItemHeight = 12
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
          Height = 349
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
          ItemHeight = 12
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
        Height = 337
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
      object Panel11: TPanel
        Left = 0
        Top = 0
        Width = 209
        Height = 418
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
          Height = 309
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
    end
    object sheetDesignProp: TTabSheet
      Caption = #65411#65438#65403#65438#65394#65437
      ImageIndex = 7
      object Label1: TLabel
        Left = 8
        Top = 8
        Width = 139
        Height = 12
        Caption = #8251#12371#12398#12506#12540#12472#12399#24037#20107#20013#12391#12377
      end
    end
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 802
    Height = 29
    ButtonHeight = 26
    ButtonWidth = 27
    Caption = 'ToolBar1'
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
      Left = 65
      Top = 0
      Caption = 'ToolButton3'
      ImageIndex = 2
      OnClick = mnuSaveClick
    end
    object ToolButton4: TToolButton
      Left = 92
      Top = 0
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 3
      Style = tbsSeparator
    end
    object ToolButton5: TToolButton
      Left = 100
      Top = 0
      Caption = 'ToolButton5'
      ImageIndex = 3
      OnClick = mnuUndoClick
    end
    object ToolButton13: TToolButton
      Left = 127
      Top = 0
      Width = 8
      Caption = 'ToolButton13'
      ImageIndex = 10
      Style = tbsSeparator
    end
    object ToolButton6: TToolButton
      Left = 135
      Top = 0
      Caption = 'ToolButton6'
      ImageIndex = 4
      OnClick = mnuCutClick
    end
    object ToolButton7: TToolButton
      Left = 162
      Top = 0
      Caption = 'ToolButton7'
      ImageIndex = 5
      OnClick = mnuCopyClick
    end
    object ToolButton8: TToolButton
      Left = 189
      Top = 0
      Caption = 'ToolButton8'
      ImageIndex = 6
      OnClick = mnuPasteClick
    end
    object ToolButton9: TToolButton
      Left = 216
      Top = 0
      Width = 8
      Caption = 'ToolButton9'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object toolRun: TToolButton
      Left = 224
      Top = 0
      Caption = 'toolRun'
      ImageIndex = 7
      OnClick = mnuRunClick
    end
    object toolStop: TToolButton
      Left = 251
      Top = 0
      Caption = 'toolStop'
      ImageIndex = 8
      OnClick = mnuStopClick
    end
    object toolPause: TToolButton
      Left = 278
      Top = 0
      Caption = 'toolPause'
      ImageIndex = 9
      OnClick = mnuPauseClick
    end
    object ToolButton14: TToolButton
      Left = 305
      Top = 0
      Width = 8
      Caption = 'ToolButton14'
      ImageIndex = 10
      Style = tbsSeparator
    end
  end
  object Status: TStatusBar
    Left = 0
    Top = 491
    Width = 802
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 80
      end
      item
        Width = 640
      end>
    PopupMenu = popupStatus
    OnClick = StatusClick
    OnDblClick = StatusDblClick
  end
  object pcMain: TPageControl
    Left = 220
    Top = 29
    Width = 582
    Height = 462
    ActivePage = tabDesign
    Align = alClient
    TabOrder = 3
    TabPosition = tpBottom
    object tabSource: TTabSheet
      Caption = #12477#12540#12473
      object splitEdit: TSplitter
        Left = 0
        Top = 0
        Width = 574
        Height = 3
        Cursor = crVSplit
        Align = alTop
      end
      object edtA: TEditorEx
        Left = 0
        Top = 3
        Width = 574
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
        Left = 0
        Top = 3
        Width = 574
        Height = 434
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
    end
    object tabDesign: TTabSheet
      Caption = #12487#12470#12452#12531
      ImageIndex = 1
      object panelDesign: TPanel
        Left = 0
        Top = 0
        Width = 574
        Height = 437
        Align = alClient
        BevelOuter = bvLowered
        TabOrder = 0
        object shapeBack: TShape
          Left = 1
          Top = 1
          Width = 572
          Height = 435
          Align = alClient
          Brush.Color = clInactiveCaption
          Pen.Style = psDot
        end
        object track: TTrackBox
          Left = 352
          Top = 248
          Width = 105
          Height = 105
          Visible = False
          TrackColor = clBlack
          TrackLineVisible = True
          TrackSizeEnable = True
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
      object N21: TMenuItem
        Caption = '-'
      end
      object mnuInsLine: TMenuItem
        Caption = #21306#20999#12426#32218#12434#25407#20837'(&L)'
        ShortCut = 16460
        OnClick = mnuInsLineClick
      end
      object mnuHokan: TMenuItem
        Caption = #21336#35486#35036#23436'...'
        ShortCut = 16416
        OnClick = mnuHokanClick
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
        Caption = #23455#34892#12375#12390#12356#12427#34892#12434#12434#36861#36321
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
      0000000000003600000028000000500000005000000001001000000000000032
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000410041
      0041004100410041004100410041004100000000000000000000000000000000
      0000000000000041004100000000000000000041004100000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000029662966F17F
      F17FF17FF17FF17FF17FF17FF17F004100410000000000000000000000000000
      000000002966EA7F80730041000000002966EA7F807300410000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000002966EE7FEE7F
      EE7FEE7FEE7FEE7FEE7FEE7FEE7FEE7F00410000000000000000000000000000
      000000002966EA7FEA7F0041000000002966EA7FEA7F00410000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000002966EE7FEE7F
      EE7FEE7FEE7FEE7FEE7FEE7FEE7FEE7F00410000000000000000000000000000
      000000002966EA7FEA7F0041000000002966EA7FEA7F00410000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000002966EE7FEE7F
      EE7FEE7FEE7FEE7FEE7FEE7FEE7FEE7F00410000000000000000000000000000
      000000002966EA7FEA7F0041000000002966EA7FEA7F00410000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000002966EE7FEE7F
      EE7FEE7FEE7FEE7FEE7FEE7FEE7FEE7F00410000000000000000000000000000
      000000002966EA7FEA7F0041000000002966EA7FEA7F00410000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000002966EE7FEE7F
      EE7FEE7FEE7FEE7FEE7FEE7FEE7FEE7F00410000000000000000000000000000
      000000002966EA7FEA7F0041000000002966EA7FEA7F00410000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000002966EE7FEE7F
      EE7FEE7FEE7FEE7FEE7FEE7FEE7FEE7F00410000000000000000000000000000
      000000002966EA7FEA7F0041000000002966EA7FEA7F00410000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000002966EE7FEE7F
      EE7FEE7FEE7FEE7FEE7FEE7FEE7FEE7F00410000000000000000000000000000
      000000002966EA7FEA7F0041000000002966EA7FEA7F00410000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000002966F17FF17F
      F17FF17FF17FF17FF17FF17FF17FF17F00410000000000000000000000000000
      000000002966F17FEA7F0041000000002966F17FEA7F00410000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000029662966F57F
      F57FF57FF57FF57FF57FF57FF57F296600410000000000000000000000000000
      000000002966F17FF17F0041000000002966F17FF17F00410000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000029662966
      2966296629662966296629662966296600000000000000000000000000000000
      0000000000002966296600000000000000002966296600000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000410041004100410041004100410041004100410041004100410041
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000041
      0000000000000000000000000041000000000000000000000000000000000000
      000000006F5E977F977F977F977F977F977F977F977F977F977F977F977F0041
      0000000000000000000000000000000000000041004100410041004100410041
      0041004100410041000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000410B56
      0041000000000000000000410B56004100000000000000000000000000000000
      000000006F5E977F977F977F977F977F977F977F977F977F977F977F977F0041
      0000000000000000000000000000000000006F5E977F977F977F977F977F977F
      977F977F977F0041000000000000A74D43454345000000000000000000000000
      000000000000000000000000000000000000000000000000000000410B560000
      0B5600410000000000410B5600000B5600410000000000000000000000000000
      000000006F5E977F977F6F5E6F5E6F5E6F5E6F5E6F5E6F5E6F5E977F977F0041
      0000000000000000000000000000000000006F5E977F6F5E6F5E6F5E6F5E6F5E
      6F5E6F5E977F0041000000000000A74DEE7FA74DA74D43450000000000000000
      00000000000000000000000000000000000000000000000000410B5600000000
      000000410000000000410000000000000B560041000000000000004100410041
      004100416F5E977F977F977F977F977F977F977F977F977F977F977F977F0041
      0000000000410041004100410041004100416F5E977F977F977F977F977F977F
      977F977F977F0041000000000000A74DEE7FEE7FEE7FA74DA74D434500000000
      00000000000000000000000000000000000000000000000000410B560B560000
      0B5600410000000000410B5600000B560B5600410000000000006F5E977F977F
      977F977F6F5E977FF47F6F5E6F5E6F5E6F5E6F5E6F5E6F5E6F5E977F977F0041
      00006F5EFA7FFA7FFA7FFA7FFA7FFA7FFA7F6F5E977F6F5E6F5E6F5E6F5E6F5E
      6F5E6F5E977F0041000000000000A74DEE7FEE7FEE7FEE7FEE7FA74DA74D4345
      0000000000000000000000000000000000000000000000000000004100410B56
      0041004100000000004100410B560041004100000000000000006F5E977F977F
      977F977F6F5E977F977F977F977F977F977F977F977F977F977F977F977F0041
      00006F5EFA7FFA7FFA7FFA7FFA7FFA7FFA7F6F5E977F977F977F977F977F977F
      977F977F977F0041000000000000A74DEE7FEE7FEE7FEE7FEE7FEE7FEE7FA74D
      A74D434500000000000000000000000000000000000000000000000000000041
      00410000004100410000004100410000000000000000000000006F5E977F977F
      977F977F6F5E977F977F6F5E6F5E6F5E6F5E6F5E6F5E6F5E6F5E977F977F0041
      00006F5EFA7FFA7FFA7FFA7FFA7FFA7FFA7F6F5E977F6F5E6F5E6F5E977F977F
      0041004100410041000000000000A74DEE7FEE7FEE7FEE7FEE7FEE7FEE7FEE7F
      EE7FA74DA74D4345000000000000000000000000000000000000000000000000
      00000000004100410000000000000000000000000000000000006F5E977F977F
      977F977F6F5E977F977F977F977F977F977F977F977F977F977F977F977F0041
      00006F5EFA7FFA7FFA7FFA7FFA7FFA7FFA7F6F5E977F977F977F977F977F977F
      00416F5E00410000000000000000A74DEE7FEE7FEE7FEE7FEE7FEE7FEE7FEE7F
      EE7FEE7FEE7FA74DA74D00000000000000000000000000000000000000000000
      00000041977F977F0041000000000000000000000000000000006F5E977F977F
      977F977F6F5E977F977F6F5E6F5E6F5E6F5E6F5E6F5E6F5E6F5E977F977F0041
      00006F5EFA7FFA7FFA7FFA7FFA7FFA7FFA7F6F5E977F977F977F977F977F977F
      0041004100000000000000000000A74DEE7FEE7FEE7FEE7FEE7FEE7FEE7FEE7F
      EE7FEE7FEE7FEE7FA74D43450000000000000000000000000000000000000000
      0041977F00410041EF7E004100000000000000000000000000006F5E977F977F
      977F977F6F5E977F977F977F977F977F977F977F977F977F977F977F977F0041
      00006F5EFA7FFA7FFA7FFA7FFA7FFA7FFA7F6F5E6F5E6F5E6F5E6F5E6F5E6F5E
      0041000000000000000000000000A74DEE7FEE7FEE7FEE7FEE7FEE7FEE7FEE7F
      EE7FEE7FEE7FEE7FEE7FA74D0000000000000000000000000000000000000041
      977F0041000000000041EF7E00410000000000000000000000006F5E977F977F
      977F977F6F5E977F977F6F5E6F5E6F5E6F5E977F977F00410041004100410041
      00006F5EFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7F
      0041000000000000000000000000A74DEE7FEE7FEE7FEE7FEE7FEE7FEE7FEE7F
      EE7FEE7FEE7FEE7FA74D0000000000000000000000000000000000000041977F
      004100000000000000000041EF7E0041000000000000000000006F5E977F977F
      977F977F6F5E977F977F977F977F977F977F977F977F00416F5E6F5E00410000
      00006F5EFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7F
      0041000000000000000000000000A74DEE7FEE7FEE7FEE7FEE7FEE7FEE7FEE7F
      EE7FEE7FA74DA74D00000000000000000000000000000000000000000041977F
      004100000000000000000041EF7E0041000000000000000000006F5E977F977F
      977F977F6F5E977F977F977F977F977F977F977F977F00416F5E004100000000
      00006F5EFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7FFA7F
      0041000000000000000000000000A74DEE7FEE7FEE7FEE7FEE7FEE7FEE7FEE7F
      A74DA74D000000000000000000000000000000000000000000000041977F0041
      0000000000000000000000000041EF7E004100000000000000006F5E977F977F
      977F977F6F5E977F977F977F977F977F977F977F977F00410041000000000000
      00006F5EFF7FFA7F0063006300630063006300630063006300630063FA7FFA7F
      0041000000000000000000000000A74DEE7FEE7FEE7FEE7FEE7FEE7FA74DA74D
      00000000000000000000000000000000000000000000000000000041977F0041
      0000000000000000000000000041EF7E004100000000000000006F5E977F977F
      977F977F6F5E6F5E6F5E6F5E6F5E6F5E6F5E6F5E6F5E00410000000000000000
      00006F5EFF7FFA7F0063F47F227F227F227F227F227F227F227F0063FA7FFA7F
      0041000000000000000000000000A74DF57FF57FF57FF57FA74DA74D00000000
      0000000000000000000000000000000000000000000000000041977F00410000
      00000000000000000000000000000041EF7E00410000000000006F5E977F977F
      977F977F977F977F977F977F977F00416F5E0041000000000000000000000000
      00006F5EFF7FFF7FFF7F0063FF7F227F227F227F227F227F0063FA7FFA7FFA7F
      0041000000000000000000000000A74DF87FF87FA74DA74D0000000000000000
      0000000000000000000000000000000000000000000000000041977F00410000
      00000000000000000000000000000041EF7E00410000000000006F5E977F977F
      977F977F977F977F977F977F977F004100410000000000000000000000000000
      000000006F5E6F5E6F5E6F5E0063FF7FF47FF47F227F00636F5E6F5E6F5E6F5E
      0000000000000000000000000000A74DA74DA74D000000000000000000000000
      0000000000000000000000000000000000000000000000000000004100000000
      00000000000000000000000000000000004100000000000000006F5E6F5E6F5E
      6F5E6F5E6F5E6F5E6F5E6F5E6F5E004100000000000000000000000000000000
      00000000000000000000000000630063FF7FFF7F006300630000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000630063000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000410041004100410041
      0041004100410041004100410041004100410041004100000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000041004100410041004100410041004100410041004100410041
      0041004100410041000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000006F5E977F977F977F977F
      977F977F977F977F977F977F977F977F977F977F004100000000000000410041
      0041004100410041004100410041004100410041004100410000000000000000
      0000000000416F5EA74DE034E034E034E034E034E034E034A74D757F757F757F
      757FA74D6F5E0041000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000006F5E977F977F977F977F
      977F977F977F977F977F977F977F977F977F977F00410000000000006F5E0041
      0B560B560B5643450B5643450B5643450B5643450B5600410041000000000000
      0000000000416F5EA74DE034E034E034E034E034E034E034A74D757F757F757F
      757FA74D6F5E0041000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000006F5E977F977F977F977F
      977F977F977F977F977F977F977F977F977F977F00410000000000006F5E537F
      00410B560B560B5643450B5643450B5643450B5643450B564345004100000000
      0000000000416F5EA74DE034E034E034E034E034E034E034A74D757F757F757F
      757FA74D6F5E0041000000000000000000410041004100410041004100410000
      000000000000000000000000000000000000000000006F5E977F977F977F977F
      977F977F977F977F977F977F977F977F977F977F00410000000000006F5E537F
      537F00410B560B560B560B560B560B560B560B560B560B560B560B5600410000
      0000000000416F5EA74DE034E034E034E034E034E034E034A74D757F757F757F
      757FA74D6F5E0041000000000000000000416F5E0B560B560B56004100000000
      000000000000000000000000000000000000000000006F5E977F977F977F977F
      977F977F977F977F977F977F977F977F977F977F00410000000000006F5E537F
      537F537F00410B560B560B560B560B560B560B560B560B560B560B560B560041
      0000000000416F5EA74DA74DA74DA74DA74DA74DA74DA74DA74DA74DA74DA74D
      A74DA74D6F5E004100000000000000000041757F757F6F5E0041000000000000
      000000000000000000000B56000000000000000000006F5E977F977F977F977F
      977F977F977F977F977F977F977F977F977F977F00410000000000006F5E537F
      537F537F537F0041004100410041004100410041004100410041004100410041
      0041000000416F5E6F5E6F5E6F5E6F5E6F5E6F5E6F5E6F5E6F5E6F5E6F5E6F5E
      6F5E6F5E6F5E004100000000000000000041757F757F00410B56000000000000
      0000000000000000000000410B5600000000000000006F5E977F977F977F977F
      977F977FE77FE77F977F977F977F977F977F977F00410000000000006F5E537F
      537F537F537F537F537F537F537F537F537F537F537F00410000000000000000
      0000000000416F5E6F5E6F5E6F5E6F5E6F5E6F5E6F5E6F5E6F5E6F5E6F5E6F5E
      6F5E6F5E6F5E004100000000000000000041977F0041000000410B5600000000
      00000000000000000000000000410B560000000000006F5E977F977F977F977F
      977FE77F977F977FE77F977F977F977F977F977F00410000000000006F5E537F
      537F537F537F537F537FA74D537F537F537F537F537F00410000000000000000
      0000000000416F5EA74DA74DA74DA74DA74DA74DA74DA74DA74DA74DA74DA74D
      A74DA74D6F5E004100000000000000000041004100000000000000410B560000
      00000000000000000000000000410B560000000000006F5E977F977F977F977F
      977FE77F977F977FE77F977F977F977F977F977F00410000000000006F5E537F
      537F537F537F537F537F537FA74D537F537F537F537F00410000000000000000
      0000000000416F5EA74D757F757F757F757F757F757F757F757F757F757F757F
      757FA74D6F5E0041000000000000000000410000000000000000000000410B56
      00000000000000000000000000410B560000000000006F5E977F977F977F977F
      977F977FE77FE77F977F977F977F977F977F977F00410000000000006F5E537F
      537F537F537F537F537F537F537FA74D537F537F537F00410000000000000000
      0000000000416F5EA74D757F757F757F757F757F757F757F757F757F757F757F
      757FA74D6F5E0041000000000000000000000000000000000000000000000041
      0B5600000000000000000B56004100000000000000006F5E977F977F977F977F
      977F977F977F977F977F977F977F977F977F977F00410000000000006F5E6F5E
      537F537F537F6F5E6F5E6F5E6F5E6F5EA74D6F5E6F5E00410000000000000000
      0000000000416F5EA74D757F757F757F757F757F757F757F757F757F757F757F
      757FA74D6F5E0041000000000000000000000000000000000000000000000000
      00410B560B560B560B560041000000000000000000006F5E977F977F977F977F
      977F977F977F977F977F977F977F977F977F977F004100000000000000006F5E
      6F5E6F5E6F5E6F5E00000000000000000000A74D000000000000000000000000
      0000000000416F5EA74D757F757F757F757F757F757F757F757F757F757F757F
      757FA74D6F5E0041000000000000000000000000000000000000000000000000
      000000410041004100410000000000000000000000006F5E977F977F977F977F
      977F977F977F977F977F977F0041004100410041004100000000000000000000
      0000000000000000000000000000000000000000A74D00000000A74D00000000
      0000000000416F5EA74D757F757F757F757F757F757F757F757F757F757F757F
      757FA74D6F5E0041000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000006F5E977F977F977F977F
      977F977F977F977F977F977F0041A74DA74D0041000000000000000000000000
      00000000000000000000000000000000000000000000A74DA74DA74D00000000
      0000000000416F5EA74D757F757F757F757F757F757F757F757F757F757F757F
      757FA74D6F5E0041000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000006F5E977F977F977F977F
      977F977F977F977F977F977F0041A74D00410000000000000000000000000000
      00000000000000000000000000000000000000000000A74DA74DA74D00000000
      0000000000416F5EA74D757F757F757F757F757F757F757F757F757F757F757F
      757FA74D6F5E0041000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000006F5E977F977F977F977F
      977F977F977F977F977F977F0041004100000000000000000000000000000000
      0000000000000000000000000000000000000000A74DA74DA74DA74D00000000
      0000000000416F5EA74D757F757F757F757F757F757F757F757F757F757F757F
      757FA74D6F5E0041000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000006F5E6F5E6F5E6F5E6F5E
      6F5E6F5E6F5E6F5E6F5E6F5E0041000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000410041004100410041004100410041004100410041004100410041
      0041004100410041000000000000000000000000000000000000000000000000
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
      object mnuGetSelectWordID: TMenuItem
        Caption = #36984#25246#35486#12398'ID'#12434#12463#12522#12483#12503#12508#12540#12489#12395#12467#12500#12540
        OnClick = mnuGetSelectWordIDClick
      end
      object popWebWriteSample: TMenuItem
        Caption = #36984#25246#35486#12398#12469#12531#12503#12523#12434'WEB'#12395#26360#12365#36796#12416
        OnClick = popWebWriteSampleClick
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
    object popInsCmd: TMenuItem
      Caption = #21629#20196#12434#12456#12487#12451#12479#12408#25407#20837'(&I)'
      OnClick = popInsCmdClick
    end
    object mnuCopyCmd: TMenuItem
      Caption = #21629#20196#12434#12463#12522#12483#12503#12508#12540#12489#12395#12467#12500#12540
      ShortCut = 16451
      OnClick = mnuCopyCmdClick
    end
    object mnuSayCmdDescript: TMenuItem
      Caption = #21629#20196#12398#35500#26126#12434#35328#12358
      OnClick = mnuSayCmdDescriptClick
    end
    object N39: TMenuItem
      Caption = '-'
    end
    object mnuViewMan: TMenuItem
      Caption = #35443#12375#12356#35299#35500#12434#35211#12427
      ShortCut = 112
      OnClick = mnuViewManClick
    end
    object mnuLookWeb: TMenuItem
      Caption = 'WEB'#12391#35443#12375#12356#35299#35500#12434#35211#12427
      ShortCut = 8304
      OnClick = mnuLookWebClick
    end
    object N40: TMenuItem
      Caption = '-'
    end
    object WEB1: TMenuItem
      Caption = 'WEB'#12467#12510#12531#12489
      object mnuWebWriteSample: TMenuItem
        Caption = 'WEB'#12395#12469#12531#12503#12523#12434#26360#12365#36796#12416
        ShortCut = 16471
        OnClick = mnuWebWriteSampleClick
      end
      object mnuWebWriteLink: TMenuItem
        Caption = #26360#12365#36796#12415#26178#12522#12531#12463#12392#12375#12390#12467#12500#12540
        ShortCut = 24643
        OnClick = mnuWebWriteLinkClick
      end
    end
  end
  object dlgFont: TFontDialog
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = []
    Options = [fdFixedPitchOnly]
    Left = 304
    Top = 192
  end
  object imgsTab: TImageList
    Left = 304
    Top = 128
    Bitmap = {
      494C01010C000E00040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000004000000001001000000000000020
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000001F0010421042104210421042
      10421042104210421042104210421042104200001F0010421042104210421042
      10421042104210421042104210421042104200001F0010421042104210421042
      1042104210421042104210421042104210420000000000000000000000000000
      0000000000000000000000000000000000001F001F7C1F00FF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7F104210421F001F7C1F00FF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7F104210421F001F7C1F00FF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7F104210420000000000000000000000000041
      00410041004100000000000000000000000000001F00FF7FFF7FFF7F1000FF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F10421F7C1F00FF7FFF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F10421F7C1F00FF7FFF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F1042000000000000000000410041E07D
      E07DE07DE07D00410041000000000000000000001F00FF7FFF7F10001000FF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F10421F7C1F00FF7FFF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F10421F7C1F00FF7FFF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F10420000000000000041E07DE07DE07D
      E07DE07DE07DE07DE07D004100000000000000001F00FF7F1000100010001000
      1000100010001000100010001000FF7F10421F7C1F00FF7FFF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F10421F7C1F00FF7FFF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F10420000000000000041E07DE07DED7F
      ED7FED7FED7FE07DE07D004100000000000000001F00FF7FFF7F10001000FF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F10421F7C1F00FF7FFF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7F007CFF7FFF7FFF7F10421F7C1F00FF7FFF7FFF7F1000FF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F1042000000000041E07DE07DED7FE07D
      ED7FED7FE07DED7FE07DE07D00410000000000001F00FF7FFF7FFF7F1000FF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F10421F7C1F00FF7FFF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7F007C007CFF7FFF7F10421F7C1F00FF7FFF7F10001000FF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F1042000000000041E07DE07DED7FED7F
      ED7FED7FED7FED7FE07DE07D00410000000000001F00FF7FFF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7F007CFF7FFF7FFF7F10421F7C1F00FF7F007C007C007C007C
      007C007C007C007C007C007C007CFF7F10421F7C1F00FF7F1000100010001000
      1000100010001000100010001000FF7F1042000000000041E07DE07DED7FED7F
      ED7FED7FED7FED7FE07DE07D00410000000000001F00FF7FFF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7F007C007CFF7FFF7F10421F7C1F00FF7FFF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7F007C007CFF7FFF7F10421F7C1F00FF7FFF7F10001000FF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F1042000000000041E07DE07DED7FE07D
      ED7FED7FE07DED7FE07DE07D00410000000000001F00FF7F007C007C007C007C
      007C007C007C007C007C007C007CFF7F10421F7C1F00FF7FFF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7F007CFF7FFF7FFF7F10421F7C1F00FF7FFF7FFF7F1000FF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F10420000000000000041E07DE07DED7F
      ED7FED7FED7FE07DE07D004100000000000000001F00FF7FFF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7F007C007CFF7FFF7F10421F7C1F00FF7FFF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F10421F7C1F00FF7FFF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F10420000000000000041E07DE07DE07D
      E07DE07DE07DE07DE07D004100000000000000001F00FF7FFF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7F007CFF7FFF7FFF7F10421F7C1F00FF7FFF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F10421F7C1F00FF7FFF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F1042000000000000000000410041E07D
      E07DE07DE07D0041004100000000000000001F001F7C1F00FF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7F104210421F001F7C1F00FF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7F104210421F001F7C1F00FF7FFF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7FFF7FFF7F104210420000000000000000000000000041
      00410041004100000000000000000000000000001F0010421042104210421042
      10421042104210421042104210421042104200001F0010421042104210421042
      10421042104210421042104210421042104200001F0010421042104210421042
      1042104210421042104210421042104210420000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000410041004100410041
      0041004100410041004100410041000000000000004100410041004100410041
      0041004100410041004100410041004100000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000B56227F227F227F227F
      227F227F227F227F227F227F00410000000000000B56227F227F227F227F227F
      227F227F227F227F227F227F227F004100000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000B56227F227F227F227F
      227F227F227F227F227F227F00410000000000000B56227F807E807E227F227F
      227F227F227F227F227F227F227F004100000000000000000000004100410041
      E07DE07D00410041004100000000000000000000000000000000E07FE07FE07F
      1F001F00E07FE07FE07F0000000000000000000000000B56227F227F807E227F
      227F227F227F227F227F227F00410000000000000B56227F227F227F227F227F
      227F227F227F227F227F227F227F004100000000000000000041E07DE07DE07D
      E07DE07DE07DE07DE07D0041000000000000000000000000E07F1F001F001F00
      1F001F001F001F001F00E07F000000000000000000000B56227F227F807E227F
      227F227F227F227F227F227F00410000000000000B560B560B560B560B560B56
      227F227F00410041004100410041004100000000000000000041E07DE07DE07D
      E07DE07DE07DE07DE07D0041000000000000000000000000E07F1F001F001F00
      1F001F001F001F001F00E07F000000000000000000000B56227F227F807E227F
      227F227F227F227F227F227F0041000000000000000000000000000000000B56
      227F227F00410000000000000000000000000000000000000041E07DE07DE07D
      E07DE07DE07DE07DE07D0041000000000000000000000000E07F1F001F001F00
      1F001F001F001F001F00E07F000000000000000000000B56227F807E807E807E
      227F227F227F227F227F227F0041000000000000000000000000000000000B56
      227F227F0041000000000000000000000000000000000000E07DE07DE07DE07D
      E07DE07DE07DE07DE07DE07D0000000000000000000000001F001F001F001F00
      1F001F001F001F001F001F00000000000000000000000B56227F227F807E227F
      227F227F227F227F227F227F0041000000000000000000000000000000000B56
      227F227F0041000000000000000000000000000000000000E07DE07DE07DE07D
      E07DE07DE07DE07DE07DE07D0000000000000000000000001F001F001F001F00
      1F001F001F001F001F001F00000000000000000000000B56227F807E807E807E
      227F227F227F227F227F227F0041000000000000000000000000000000000B56
      227F227F00410000000000000000000000000000000000000041E07DE07DE07D
      E07DE07DE07DE07DE07D0041000000000000000000000000E07F1F001F001F00
      1F001F001F001F001F00E07F000000000000000000000B56227F227F807E227F
      227F227F227F227F227F227F0041000000000000000000000000000000000B56
      227F227F00410000000000000000000000000000000000000041E07DE07DE07D
      E07DE07DE07DE07DE07D0041000000000000000000000000E07F1F001F001F00
      1F001F001F001F001F00E07F000000000000000000000B56227F227F807E227F
      227F227F227F227F227F227F0041000000000000000000000000000000000B56
      227F227F00410000000000000000000000000000000000000041E07DE07DE07D
      E07DE07DE07DE07DE07D0041000000000000000000000000E07F1F001F001F00
      1F001F001F001F001F00E07F000000000000000000000B56227F227F227F227F
      227F227F227F227F227F227F0041000000000000000000000000000000000B56
      227F227F00410000000000000000000000000000000000000000004100410041
      E07DE07D00410041004100000000000000000000000000000000E07FE07FE07F
      1F001F00E07FE07FE07F0000000000000000000000000B56227F227F227F227F
      227F227F227F227F227F227F0041000000000000000000000000000000000B56
      227F227F00410000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000B560B560B560B560B56
      0B560B560B560B560B560B560041000000000000000000000000000000000B56
      0B560B5600410000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000041
      0041004100410000000000000000000000000000000000000000000000410041
      0041004100410041000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000004100410041004100410041
      0041004100410041004100410041004100000000000000000000000000000041
      E07DE07D004100000000000000000000000000000000EE7F000000000041EA7F
      EA7FEA7FEA7F004100000000EE7F000000000000000000410041004100410041
      00410041004100410041004100410000000000000B56F77FB277B277B277B277
      B277B277B277B277B277B277B277004100000000000000000000000000000041
      E07DE07D0041000000000000000000000000000000000000EE7F00000041EA7F
      EA7FEA7FEA7F00410000EE7F000000000000000000000B56E07DE07DE07DE07D
      E07DE07DE07DE07DE07DE07D00410000000000000B56F77FB277B277B277B277
      B277B277B277B277B277B277B277004100000000000000000000000000000041
      E07DE07D0041000000000000000000000000000000000000000000000041EA7F
      EA7FEA7FEA7F004100000000000000000000000000000B56E07DE07DE07DE07D
      E07DE07DE07DE07DE07DE07D00410000000000000B56F77FB277B277B277B277
      B277B277B277B277B277B277B277004100000000000000000000000000000041
      E07DE07D0041000000000000000000000000000000410041004100410041EA7F
      EA7FEA7FEA7F004100410041004100410000000000000B56E07DE07DE07DE07D
      E07DE07DE07DE07DE07DE07D00410000000000000B56F77FB277B277B277B277
      B277B277B277B277B277B277B277004100000000004100410041004100410041
      E07DE07D004100410041004100410041000000002966EA7FEA7FEA7FEA7FEA7F
      EA7FEA7FEA7FEA7FEA7FEA7FEA7F00410000000000000B56E07DE07DE07DE07D
      E07DE07DE07DE07DE07DE07D00410000000000000B56F77FB277B277B277B277
      B277B277B277B277B277B277B2770041000000000B56E07DE07DE07DE07DE07D
      E07DE07DE07DE07DE07DE07DE07D0041000000002966EA7FEA7FEA7FEA7FEA7F
      EA7FEA7FEA7FEA7FEA7FEA7FEA7F00410000000000000B56E07DE07DE07DE07D
      E07DE07DE07DE07DE07DE07D00410000000000000B56F77FB277B277B277B277
      B277B277B277B277B277B277B2770041000000000B56E07DE07DE07DE07DE07D
      E07DE07DE07DE07DE07DE07DE07D0041000000002966EA7FEA7FEA7FEA7FEA7F
      EA7FEA7FEA7FEA7FEA7FEA7FEA7F00410000000000000B56E07DE07DE07DE07D
      E07DE07DE07DE07DE07DE07D00410000000000000B56F77FB277B277B277B277
      B277B277B277B277B277B277B2770041000000000B560B560B560B560B560B56
      E07DE07D004100410041004100410041000000002966F57FF57FF57FF57FEA7F
      EA7FEA7FEA7FEA7FEA7FEA7FEA7F00410000000000000B56E07DE07DE07DE07D
      E07DE07DE07DE07DE07DE07D00410000000000000B56F77FB277B277B277B277
      B277B277B277B277B277B277B277004100000000000000000000000000000B56
      E07DE07D0041000000000000000000000000000029662966296629662966EA7F
      EA7FEA7FEA7F004100410041004100410000000000000B560B56E07DE07D0041
      00410041004100410041004100410000000000000B56F77FF77FF77FF77FF77F
      F77FF77FF77FF77FF77FF77FF77F004100000000000000000000000000000B56
      E07DE07D0041000000000000000000000000000000000000000000002966EA7F
      EA7FEA7FEA7F0041000000000000000000000000000000000B56E07DE07D0041
      00000000000000000000000000000000000000000B560B560B56F77FB2770041
      0041004100410041004100410041004100000000000000000000000000000B56
      E07DE07D0041000000000000000000000000000000000000EE7F00002966EA7F
      EA7FEA7FEA7F00410000EE7F0000000000000000000000000B560B560B560041
      0000000000000000000000000000000000000000000000000B56F77FF77F0041
      0000000000000000000000000000000000000000000000000000000000000B56
      E07DE07D004100000000000000000000000000000000EE7F000000002966F57F
      F57FF57FF57F004100000000EE7F000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000B560B560B560041
      0000000000000000000000000000000000000000000000000000000000000B56
      0B560B5600410000000000000000000000000000000000000000000029662966
      2966296629660041000000000000000000000000000000000000000000000000
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
    Left = 24
    Top = 352
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
end
