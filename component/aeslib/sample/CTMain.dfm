object Form1: TForm1
  Left = 452
  Top = 402
  Width = 336
  Height = 173
  Caption = 'Test for Aes-Encryption-Library'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 5
    Top = 8
    Width = 45
    Height = 13
    Caption = 'Filename:'
  end
  object FileBtn: TSpeedButton
    Left = 295
    Top = 23
    Width = 26
    Height = 26
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000120B0000120B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555555555
      5555555555555555555555555555555555555555555555555555555555555555
      555555555555555555555555555555555555555FFFFFFFFFF555550000000000
      55555577777777775F55500B8B8B8B8B05555775F555555575F550F0B8B8B8B8
      B05557F75F555555575F50BF0B8B8B8B8B0557F575FFFFFFFF7F50FBF0000000
      000557F557777777777550BFBFBFBFB0555557F555555557F55550FBFBFBFBF0
      555557F555555FF7555550BFBFBF00055555575F555577755555550BFBF05555
      55555575FFF75555555555700007555555555557777555555555555555555555
      5555555555555555555555555555555555555555555555555555}
    NumGlyphs = 2
    OnClick = FileBtnClick
  end
  object Label4: TLabel
    Left = 5
    Top = 55
    Width = 49
    Height = 13
    Caption = 'Password:'
  end
  object edtFiles: TEdit
    Left = 5
    Top = 25
    Width = 281
    Height = 21
    TabOrder = 0
  end
  object btnQuit: TButton
    Left = 245
    Top = 100
    Width = 76
    Height = 31
    Caption = 'Quit'
    TabOrder = 4
    OnClick = btnQuitClick
  end
  object btnEncrypt: TButton
    Left = 70
    Top = 100
    Width = 76
    Height = 31
    Caption = 'Encrypt'
    TabOrder = 2
    OnClick = btnEncryptClick
  end
  object edtPwd: TEdit
    Left = 5
    Top = 70
    Width = 316
    Height = 21
    TabOrder = 1
  end
  object btnDecrypt: TButton
    Left = 155
    Top = 100
    Width = 76
    Height = 31
    Caption = 'Decrypt'
    TabOrder = 3
    OnClick = btnDecryptClick
  end
  object OpenDialog: TOpenDialog
    Left = 195
    Top = 40
  end
end
