object Form1: TForm1
  Left = 340
  Top = 170
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderStyle = bsSingle
  Caption = 'Form1'
  ClientHeight = 384
  ClientWidth = 355
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  Position = poDefaultSizeOnly
  PixelsPerInch = 96
  TextHeight = 12
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 355
    Height = 37
    Caption = 'Title'
    TabOrder = 0
    DesignSize = (
      355
      37)
    object Edit1: TEdit
      Left = 2
      Top = 12
      Width = 349
      Height = 23
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
    end
  end
  object Button1: TButton
    Left = 207
    Top = 360
    Width = 75
    Height = 25
    Caption = #38283#12367
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 282
    Top = 360
    Width = 75
    Height = 25
    Caption = #26360#12365#36796#12416
    Enabled = False
    TabOrder = 2
    OnClick = Button2Click
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 40
    Width = 355
    Height = 35
    Caption = 'Artist'
    TabOrder = 3
    DesignSize = (
      355
      35)
    object Edit2: TEdit
      Left = 4
      Top = 12
      Width = 347
      Height = 19
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
    end
  end
  object GroupBox3: TGroupBox
    Left = 0
    Top = 78
    Width = 355
    Height = 35
    Caption = 'Album'
    TabOrder = 4
    DesignSize = (
      355
      35)
    object Edit3: TEdit
      Left = 4
      Top = 12
      Width = 347
      Height = 20
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
    end
  end
  object GroupBox4: TGroupBox
    Left = 0
    Top = 116
    Width = 355
    Height = 35
    Caption = 'Year'
    TabOrder = 5
    DesignSize = (
      355
      35)
    object Edit4: TEdit
      Left = 4
      Top = 12
      Width = 347
      Height = 20
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
    end
  end
  object GroupBox5: TGroupBox
    Left = 0
    Top = 152
    Width = 355
    Height = 35
    Caption = 'Comment'
    TabOrder = 6
    DesignSize = (
      355
      35)
    object Edit5: TEdit
      Left = 4
      Top = 12
      Width = 347
      Height = 20
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 186
    Width = 355
    Height = 173
    ScrollBars = ssVertical
    TabOrder = 7
  end
  object OpenDialog1: TOpenDialog
    Left = 26
    Top = 326
  end
end
