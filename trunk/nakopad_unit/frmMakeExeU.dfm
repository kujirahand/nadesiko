object frmMakeExe: TfrmMakeExe
  Left = 226
  Top = 199
  Width = 594
  Height = 307
  Caption = #23455#34892#12501#12449#12452#12523#12398#20316#25104
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object Panel1: TPanel
    Left = 0
    Top = 208
    Width = 578
    Height = 62
    Align = alBottom
    TabOrder = 0
    object btnOK: TButton
      Left = 8
      Top = 24
      Width = 97
      Height = 33
      Caption = #20316#25104'(&O)'
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnIzon: TButton
      Left = 112
      Top = 24
      Width = 65
      Height = 33
      Caption = #20381#23384#30906#35469
      TabOrder = 1
      OnClick = btnIzonClick
    end
    object btnHelp: TButton
      Left = 184
      Top = 24
      Width = 65
      Height = 33
      Caption = #12504#12523#12503'(&H)'
      TabOrder = 2
      OnClick = btnHelpClick
    end
    object chkAngou: TCheckBox
      Left = 264
      Top = 8
      Width = 161
      Height = 17
      Caption = #26263#21495#21270#12375#12390#26801#21253
      TabOrder = 3
    end
    object chkAngou3: TCheckBox
      Left = 264
      Top = 24
      Width = 265
      Height = 17
      Caption = #24375#21147#12395#26263#21495#21270#12375#12390#26801#21253'('#12487#12521#12483#12463#12473#29256#12398#12415')'
      Enabled = False
      TabOrder = 4
    end
    object chkIncludeDLL: TCheckBox
      Left = 264
      Top = 40
      Width = 289
      Height = 17
      Caption = #12503#12521#12464#12452#12531#12434#23455#34892#12501#12449#12452#12523#12395#26801#21253'('#12487#12521#12483#12463#12473#29256#12398#12415')'
      Enabled = False
      TabOrder = 5
      OnClick = chkIncludeDLLClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 578
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 210
      Height = 12
      Caption = #26801#21253#12375#12383#12356#12501#12449#12452#12523#12434#12489#12525#12483#12503#12375#12390#12367#12384#12373#12356#12290
    end
    object btnAddFiles: TButton
      Left = 224
      Top = 3
      Width = 49
      Height = 20
      Caption = #36861#21152'...'
      TabOrder = 0
      OnClick = btnAddFilesClick
    end
    object btnClear: TButton
      Left = 520
      Top = 3
      Width = 49
      Height = 20
      Caption = #12463#12522#12450
      TabOrder = 1
      OnClick = btnClearClick
    end
  end
  object lstFiles: TListBox
    Left = 0
    Top = 25
    Width = 578
    Height = 183
    Align = alClient
    ItemHeight = 12
    TabOrder = 2
  end
  object dlgOpen: TOpenDialog
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Left = 224
    Top = 88
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'exe'
    Filter = #23455#34892#12501#12449#12452#12523'(*.exe)|*.exe|'#12377#12409#12390'|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 256
    Top = 88
  end
end
