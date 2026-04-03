object frmOutputLog: TfrmOutputLog
  Left = 0
  Top = 0
  Caption = 'GetIt Output Log'
  ClientHeight = 860
  ClientWidth = 1120
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  TextHeight = 16
  object mmoOutput: TMemo
    Left = 0
    Top = 0
    Width = 1120
    Height = 819
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 819
    Width = 1120
    Height = 41
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      1120
      41)
    object btnExport: TButton
      Left = 10
      Top = 8
      Width = 130
      Height = 25
      Caption = 'Export Text File...'
      TabOrder = 0
      OnClick = btnExportClick
    end
    object btnClear: TButton
      Left = 146
      Top = 8
      Width = 90
      Height = 25
      Caption = 'Clear'
      TabOrder = 1
      OnClick = btnClearClick
    end
    object btnClose: TButton
      Left = 1024
      Top = 8
      Width = 85
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Close'
      TabOrder = 2
      OnClick = btnCloseClick
    end
  end
  object dlgSaveLog: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'Text files (*.txt)|*.txt|All files (*.*)|*.*'
    Left = 264
    Top = 152
  end
end
