object frmMemo: TfrmMemo
  Left = 192
  Top = 114
  Width = 536
  Height = 434
  Caption = #12513#12514
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object Status: TStatusBar
    Left = 0
    Top = 356
    Width = 520
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object panelBase: TPanel
    Left = 0
    Top = 323
    Width = 520
    Height = 33
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 1
    OnResize = panelBaseResize
    object Label1: TLabel
      Left = 8
      Top = 10
      Width = 24
      Height = 12
      Caption = #26908#32034
    end
    object panelBtn: TPanel
      Left = 336
      Top = 1
      Width = 193
      Height = 33
      BevelOuter = bvNone
      TabOrder = 0
      object btnOK: TButton
        Left = 7
        Top = 4
        Width = 98
        Height = 25
        Caption = #27770#23450'(&O)'
        TabOrder = 0
        OnClick = btnOKClick
      end
      object btnCancel: TButton
        Left = 112
        Top = 4
        Width = 73
        Height = 25
        Caption = #21462#28040'(&C)'
        TabOrder = 1
        OnClick = btnCancelClick
      end
    end
    object edtFind: TEdit
      Left = 40
      Top = 8
      Width = 121
      Height = 20
      TabOrder = 1
      OnKeyPress = edtFindKeyPress
    end
    object btnFindNext: TButton
      Left = 160
      Top = 8
      Width = 28
      Height = 21
      Caption = #27425
      TabOrder = 2
      OnClick = btnFindNextClick
    end
    object btnFindPrev: TButton
      Left = 187
      Top = 8
      Width = 28
      Height = 21
      Caption = #21069
      TabOrder = 3
      OnClick = btnFindPrevClick
    end
  end
  object edtMain: TEditorEx
    Left = 0
    Top = 0
    Width = 520
    Height = 323
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
    Caret.FreeCaret = False
    Caret.FreeRow = False
    Caret.InTab = False
    Caret.KeepCaret = True
    Caret.LockScroll = False
    Caret.NextLine = True
    Caret.PrevSpaceIndent = True
    Caret.RowSelect = True
    Caret.SelDragMode = dmManual
    Caret.SelMove = True
    Caret.SoftTab = True
    Caret.Style = csDefault
    Caret.TabIndent = True
    Caret.TabSpaceCount = 4
    Caret.TokenEndStop = False
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = #65325#65331' '#12468#12471#12483#12463
    Font.Style = []
    HitStyle = hsSelect
    Imagebar.DigitWidth = 2
    Imagebar.LeftMargin = 0
    Imagebar.MarkWidth = 0
    Imagebar.RightMargin = 2
    Imagebar.Visible = True
    Marks.EofMark.Color = clGray
    Marks.EofMark.Visible = False
    Marks.RetMark.Color = clGray
    Marks.RetMark.Visible = True
    Marks.WrapMark.Color = clGray
    Marks.WrapMark.Visible = False
    Marks.HideMark.Color = clGray
    Marks.HideMark.Visible = False
    Marks.Underline.Color = clGray
    Marks.Underline.Visible = False
    Margin.Character = 0
    Margin.Left = 8
    Margin.Line = 0
    Margin.Top = 2
    Leftbar.BkColor = clWhite
    Leftbar.Color = clGray
    Leftbar.Column = 2
    Leftbar.Edge = True
    Leftbar.LeftMargin = 2
    Leftbar.RightMargin = 2
    Leftbar.ShowNumber = True
    Leftbar.ShowNumberMode = nmRow
    Leftbar.Visible = True
    Leftbar.ZeroBase = False
    Leftbar.ZeroLead = False
    PopupMenu = popEdit
    ReadOnly = False
    Ruler.BkColor = clWhite
    Ruler.Color = clGray
    Ruler.Edge = True
    Ruler.GaugeRange = 10
    Ruler.MarkColor = clBlack
    Ruler.Visible = True
    ScrollBars = ssBoth
    Speed.CaretVerticalAc = 2
    Speed.InitBracketsFull = False
    Speed.PageVerticalRange = 2
    Speed.PageVerticalRangeAc = 2
    TabOrder = 2
    UndoListMax = 64
    View.Brackets = <>
    View.Colors.Ank.BkColor = clNone
    View.Colors.Ank.Color = clNone
    View.Colors.Ank.Style = []
    View.Colors.Comment.BkColor = clNone
    View.Colors.Comment.Color = clBlue
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
    View.Colors.Mail.Color = clNavy
    View.Colors.Mail.Style = [fsUnderline]
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
    View.Colors.Url.Color = clNavy
    View.Colors.Url.Style = [fsUnderline]
    View.Commenter = '>'
    View.ControlCode = False
    View.HexPrefix = '$'
    View.Mail = True
    View.Quotation = '"'
    View.Url = True
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
    OnDblClick = edtMainDblClick
    OnMouseWheel = edtMainMouseWheel
    ExMarks.DBSpaceMark.Color = clGray
    ExMarks.DBSpaceMark.Visible = False
    ExMarks.SpaceMark.Color = clGray
    ExMarks.SpaceMark.Visible = False
    ExMarks.TabMark.Color = clGray
    ExMarks.TabMark.Visible = False
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
  object dlgSave: TSaveDialog
    DefaultExt = 'txt'
    Filter = #12486#12461#12473#12488'(*.txt)|*.txt|'#12377#12409#12390'(*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 40
    Top = 8
  end
  object dlgOpen: TOpenDialog
    DefaultExt = 'txt'
    Filter = #12486#12461#12473#12488'(*.txt)|*.txt|'#12377#12409#12390'(*.*)|*.*'
    Left = 8
    Top = 8
  end
  object MainMenu1: TMainMenu
    Left = 72
    Top = 8
    object mnuFile: TMenuItem
      Caption = #12501#12449#12452#12523'(&F)'
      object mnuOpen: TMenuItem
        Caption = #38283#12367'(&O)'
        ShortCut = 16463
        OnClick = mnuOpenClick
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object mnuSave: TMenuItem
        Caption = #20445#23384'(&S)'
        ShortCut = 16467
        OnClick = mnuSaveClick
      end
      object N4: TMenuItem
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
        Caption = #20803#12395#25147#12377'(&U)'
        ShortCut = 16474
        OnClick = mnuUndoClick
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
        Caption = #36028#12426#20184#12369'(&V)'
        ShortCut = 16470
        OnClick = mnuPasteClick
      end
      object mnuPasteQuote: TMenuItem
        Caption = #24341#29992#12375#12390#36028#12426#20184#12369
        OnClick = mnuPasteQuoteClick
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object mnuSelAll: TMenuItem
        Caption = #12377#12409#12390#36984#25246'(&A)'
        ShortCut = 16449
        OnClick = mnuSelAllClick
      end
    end
    object F2: TMenuItem
      Caption = #27231#33021'(&U)'
      object mnuFind: TMenuItem
        Caption = #26908#32034'(&F)'
        ShortCut = 16454
        OnClick = mnuFindClick
      end
      object mnuFindNext: TMenuItem
        Caption = #27425#12434#26908#32034
        ShortCut = 114
        OnClick = mnuFindNextClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object mnuReplace: TMenuItem
        Caption = #32622#25563'(&R)'
        ShortCut = 16466
        OnClick = mnuReplaceClick
      end
    end
    object F1: TMenuItem
      Caption = #34920#31034'(&V)'
      object mnuFont: TMenuItem
        Caption = #12501#12457#12531#12488'(&F)'
        ShortCut = 16454
        OnClick = mnuFontClick
      end
      object mnuOrikaesi: TMenuItem
        Caption = '72'#26689#12391#25240#12426#36820#12377
        OnClick = mnuOrikaesiClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mnuCountLen: TMenuItem
        Caption = #25991#23383#25968#30906#35469
        ShortCut = 115
        OnClick = mnuCountLenClick
      end
      object N10: TMenuItem
        Caption = '-'
      end
      object mnuAlwaysTop: TMenuItem
        Caption = #26368#21069#38754#34920#31034
        OnClick = mnuAlwaysTopClick
      end
    end
    object H1: TMenuItem
      Caption = #12504#12523#12503'(&H)'
      object mnuFindGoole: TMenuItem
        Caption = #36984#25246#35486#21477#12434'Google'#12391#26908#32034
        ShortCut = 112
        OnClick = mnuFindGooleClick
      end
      object mnuAbout: TMenuItem
        Caption = #12371#12398#12456#12487#12451#12479#12395#12388#12356#12390
        OnClick = mnuAboutClick
      end
    end
  end
  object dlgFont: TFontDialog
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = []
    Left = 104
    Top = 8
  end
  object popEdit: TPopupMenu
    Left = 136
    Top = 8
    object popCopy: TMenuItem
      Caption = #12467#12500#12540'(&C)'
      OnClick = mnuCopyClick
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object popCut: TMenuItem
      Caption = #20999#12426#21462#12426'(&X)'
      OnClick = mnuCutClick
    end
    object popPaste: TMenuItem
      Caption = #36028#12426#20184#12369'(&V)'
      OnClick = mnuPasteClick
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object mnuOpenApp: TMenuItem
      Caption = #38306#36899#20184#12369#12391#23455#34892
      OnClick = mnuOpenAppClick
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object popSelAll: TMenuItem
      Caption = #12377#12409#12390#36984#25246'(&A)'
      OnClick = mnuSelAllClick
    end
  end
  object dlgFind: TFindDialog
    Options = [frDown, frHideMatchCase, frHideWholeWord, frHideUpDown]
    OnFind = dlgFindFind
    Left = 176
    Top = 8
  end
  object dlgReplace: TReplaceDialog
    FindText = 'uuuu'
    Options = [frDown, frDisableMatchCase, frDisableUpDown, frDisableWholeWord]
    OnFind = dlgFindFind
    ReplaceText = 'u'
    OnReplace = dlgReplaceReplace
    Left = 208
    Top = 8
  end
end
