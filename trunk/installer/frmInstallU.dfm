object frmNakoInstaller: TfrmNakoInstaller
  Left = 193
  Top = 130
  BorderStyle = bsDialog
  Caption = 'Installer'
  ClientHeight = 388
  ClientWidth = 470
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object Panel1: TPanel
    Left = 0
    Top = 336
    Width = 470
    Height = 52
    Align = alBottom
    TabOrder = 0
    object btnPrev: TButton
      Left = 288
      Top = 8
      Width = 75
      Height = 33
      Caption = #25147#12427'(&P)'
      TabOrder = 0
      OnClick = btnPrevClick
    end
    object btnNext: TButton
      Left = 376
      Top = 8
      Width = 75
      Height = 33
      Caption = #27425#12408'(&N)'
      TabOrder = 1
      OnClick = btnNextClick
    end
  end
  object pages: TPageControl
    Left = 0
    Top = 0
    Width = 470
    Height = 336
    ActivePage = tabUninstall
    Align = alClient
    MultiLine = True
    ParentShowHint = False
    ShowHint = False
    TabOrder = 1
    object tabStart: TTabSheet
      Caption = #12399#12376#12417#12395
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 462
        Height = 309
        Align = alClient
        BevelOuter = bvLowered
        TabOrder = 0
        object lblWebSite: TLabel
          Left = 16
          Top = 272
          Width = 80
          Height = 12
          Caption = #35443#32048'WEB'#12469#12452#12488':'
          Font.Charset = SHIFTJIS_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
          Font.Style = [fsItalic]
          ParentFont = False
        end
        object lblAboutLink: TLabel
          Left = 16
          Top = 288
          Width = 433
          Height = 12
          Cursor = crHandPoint
          AutoSize = False
          Caption = 'http://nadesi.com/'
          Color = clBtnFace
          Font.Charset = SHIFTJIS_CHARSET
          Font.Color = clBlue
          Font.Height = -12
          Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
          Font.Style = [fsUnderline]
          ParentColor = False
          ParentFont = False
          OnClick = lblAboutLinkClick
        end
        object edtAbout: TRichEdit
          Left = 16
          Top = 16
          Width = 425
          Height = 225
          BorderStyle = bsNone
          Color = clBtnFace
          Lines.Strings = (
            #26085#26412#35486#12503#12525#12464#12521#12511#12531#12464#35328#35486#12300#12394#12391#12375#12371#12301
            #12475#12483#12488#12450#12483#12503#12434#34892#12356#12414#12377#12290)
          TabOrder = 0
        end
      end
    end
    object tabLicense: TTabSheet
      Caption = #21033#29992#35215#32004
      ImageIndex = 1
      object GroupBox1: TGroupBox
        Left = 8
        Top = 8
        Width = 441
        Height = 241
        TabOrder = 0
        object edtLicense: TRichEdit
          Left = 8
          Top = 16
          Width = 425
          Height = 217
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 0
        end
      end
      object radioLicenseOK: TRadioButton
        Left = 16
        Top = 256
        Width = 113
        Height = 17
        Caption = #21516#24847#12377#12427'(&A)'
        TabOrder = 1
        OnClick = radioLicenseOKClick
      end
      object radioLicenseNG: TRadioButton
        Left = 16
        Top = 280
        Width = 113
        Height = 17
        Caption = #21516#24847#12375#12394#12356'(&U)'
        Checked = True
        TabOrder = 2
        TabStop = True
        OnClick = radioLicenseNGClick
      end
    end
    object tabOption: TTabSheet
      Caption = #35373#23450
      ImageIndex = 2
      object groupPath: TGroupBox
        Left = 8
        Top = 8
        Width = 441
        Height = 65
        Caption = 'Path'
        TabOrder = 0
        object edtDir: TEdit
          Left = 16
          Top = 24
          Width = 377
          Height = 20
          TabOrder = 0
        end
        object btnDir: TButton
          Left = 392
          Top = 24
          Width = 25
          Height = 20
          Caption = '...'
          TabOrder = 1
          OnClick = btnDirClick
        end
      end
      object groupOption: TGroupBox
        Left = 8
        Top = 88
        Width = 441
        Height = 209
        Caption = 'Option'
        TabOrder = 1
        object lblPleaseSetOption: TLabel
          Left = 16
          Top = 24
          Width = 350
          Height = 12
          Caption = #8251#36890#24120#12399#22793#26356#12398#24517#35201#12399#12354#12426#12414#12379#12435#12364#12289#24517#35201#12394#12425#35373#23450#12434#22793#26356#12391#12365#12414#12377#12290
          Font.Charset = SHIFTJIS_CHARSET
          Font.Color = clNavy
          Font.Height = -12
          Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
          Font.Style = []
          ParentFont = False
        end
        object chkDesktop: TCheckBox
          Left = 16
          Top = 56
          Width = 377
          Height = 17
          Caption = #12487#12473#12463#12488#12483#12503#12395#12471#12519#12540#12488#12459#12483#12488#12434#20316#12427
          TabOrder = 0
        end
        object chkQuickLaunch: TCheckBox
          Left = 16
          Top = 80
          Width = 377
          Height = 17
          Caption = #12463#12452#12483#12463#36215#21205#12395#30331#37682#12377#12427
          TabOrder = 1
        end
        object chkExt: TCheckBox
          Left = 16
          Top = 152
          Width = 377
          Height = 17
          Caption = #38306#36899#12389#12369#12434#34892#12358
          TabOrder = 2
        end
        object chkSendTo: TCheckBox
          Left = 16
          Top = 176
          Width = 377
          Height = 17
          Caption = #12300#36865#12427#12301#12513#12491#12517#12540#12395#30331#37682#12377#12427
          TabOrder = 3
        end
        object ChkStartup: TCheckBox
          Left = 16
          Top = 128
          Width = 377
          Height = 17
          Caption = #12525#12464#12458#12531#12375#12383#12425#24120#12395#23455#34892#12377#12427
          TabOrder = 4
        end
        object chkAllUsers: TCheckBox
          Left = 16
          Top = 104
          Width = 385
          Height = 17
          Caption = #20840#12390#12398#12518#12540#12470#12540#12391#21033#29992#12377#12427
          TabOrder = 5
        end
      end
    end
    object tabProcess: TTabSheet
      Caption = #20966#29702#20013
      ImageIndex = 3
      object GroupBox4: TGroupBox
        Left = 8
        Top = 8
        Width = 441
        Height = 289
        TabOrder = 0
        object lblWaitAMoment: TLabel
          Left = 16
          Top = 24
          Width = 289
          Height = 12
          Caption = #12452#12531#12473#12488#12540#12523#20316#26989#12434#34892#12387#12390#12356#12414#12377#12290#12375#12400#12425#12367#12362#24453#12385#12367#12384#12373#12356#12290
        end
        object bar2: TProgressBar
          Left = 16
          Top = 64
          Width = 361
          Height = 17
          TabOrder = 0
        end
        object btnStopInstall: TButton
          Left = 384
          Top = 48
          Width = 41
          Height = 33
          Caption = #20013#26029
          TabOrder = 1
          OnClick = btnStopInstallClick
        end
        object bar1: TProgressBar
          Left = 16
          Top = 48
          Width = 361
          Height = 9
          TabOrder = 2
        end
        object edtLog: TMemo
          Left = 16
          Top = 120
          Width = 409
          Height = 153
          Color = clBtnFace
          TabOrder = 3
          Visible = False
        end
        object btnShowLog: TButton
          Left = 352
          Top = 96
          Width = 75
          Height = 25
          Caption = '>>'
          TabOrder = 4
          OnClick = btnShowLogClick
        end
      end
    end
    object tabEnd: TTabSheet
      Caption = #23436#20102
      ImageIndex = 4
      object GroupBox5: TGroupBox
        Left = 8
        Top = 8
        Width = 441
        Height = 289
        TabOrder = 0
        object lblCompleteMsg: TLabel
          Left = 16
          Top = 32
          Width = 147
          Height = 12
          Caption = #12452#12531#12473#12488#12540#12523#12364#23436#20102#12375#12414#12375#12383#12290
        end
        object chkLaunchAfterInstall: TCheckBox
          Left = 16
          Top = 248
          Width = 361
          Height = 17
          Caption = #12371#12428#12363#12425#36215#21205#12377#12427
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
      end
    end
    object tabUninstall: TTabSheet
      Caption = #12450#12531#12452#12531#12473#12488#12540#12523
      ImageIndex = 5
      object GroupBox6: TGroupBox
        Left = 8
        Top = 8
        Width = 441
        Height = 289
        TabOrder = 0
        object lblRemoveFiles: TLabel
          Left = 16
          Top = 24
          Width = 193
          Height = 12
          Caption = #12450#12531#12452#12531#12473#12488#12540#12523#20316#26989#12434#34892#12387#12390#12356#12414#12377#12290
        end
        object ubar1: TProgressBar
          Left = 16
          Top = 48
          Width = 409
          Height = 9
          TabOrder = 0
        end
        object ubar2: TProgressBar
          Left = 16
          Top = 64
          Width = 409
          Height = 17
          TabOrder = 1
        end
        object btnShowDetailUninstall: TButton
          Left = 348
          Top = 96
          Width = 75
          Height = 25
          Caption = '>>'
          TabOrder = 2
          OnClick = btnShowDetailUninstallClick
        end
        object edtLogU: TMemo
          Left = 16
          Top = 120
          Width = 409
          Height = 153
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 3
          Visible = False
        end
      end
    end
  end
  object timerUninstall: TTimer
    Enabled = False
    Interval = 100
    OnTimer = timerUninstallTimer
    Left = 232
    Top = 96
  end
end
