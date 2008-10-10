object frmSay: TfrmSay
  Left = 192
  Top = 114
  Hint = #21491#12463#12522#12483#12463#12391#12513#12491#12517#12540#12364#20986#12414#12377#12290
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #12513#12483#12475#12540#12472
  ClientHeight = 90
  ClientWidth = 188
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = popSay
  Position = poMainFormCenter
  ShowHint = True
  OnCreate = FormCreate
  OnDblClick = FormDblClick
  OnDestroy = FormDestroy
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 12
  object panelBottom: TPanel
    Left = 0
    Top = 59
    Width = 188
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnOK: TButton
      Left = 7
      Top = 0
      Width = 75
      Height = 25
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnNg: TButton
      Left = 87
      Top = 0
      Width = 75
      Height = 25
      Caption = 'NG'
      TabOrder = 1
      OnClick = btnNgClick
    end
  end
  object btnMore: TButton
    Left = 152
    Top = 32
    Width = 33
    Height = 17
    Caption = #35443#32048
    TabOrder = 1
    Visible = False
    OnClick = btnMoreClick
  end
  object popSay: TPopupMenu
    Left = 8
    Top = 8
    object popToMemo: TMenuItem
      Caption = #12513#12514#30011#38754#12391#38283#12367
      OnClick = popToMemoClick
    end
    object mnuCopy: TMenuItem
      Caption = #12513#12483#12475#12540#12472#12434#12467#12500#12540
      OnClick = mnuCopyClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object popCancel: TMenuItem
      Caption = #12461#12515#12531#12475#12523'(&C)'
      OnClick = popCancelClick
    end
  end
  object timerLimit: TTimer
    Enabled = False
    OnTimer = timerLimitTimer
    Left = 40
    Top = 8
  end
end
