object frmHukidasi: TfrmHukidasi
  Left = 192
  Top = 114
  BorderStyle = bsNone
  Caption = #21561#12365#20986#12375
  ClientHeight = 136
  ClientWidth = 211
  Color = clInfoBk
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  PopupMenu = popMain
  OnClick = FormClick
  OnClose = FormClose
  OnCreate = FormCreate
  OnDblClick = FormDblClick
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnKeyDown = FormKeyDown
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 12
  object popMain: TPopupMenu
    Left = 40
    Top = 8
    object btnClose: TMenuItem
      Caption = #38281#12376#12427'(&C)'
      OnClick = btnCloseClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object N2: TMenuItem
      Caption = #12513#12483#12475#12540#12472#12434#12467#12500#12540
      OnClick = N2Click
    end
  end
end
