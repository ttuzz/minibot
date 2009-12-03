object frm_main: Tfrm_main
  Left = 223
  Top = 597
  Width = 656
  Height = 366
  Caption = 'MBTransiver'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 488
    Top = 184
    Width = 32
    Height = 13
    Caption = 'Label1'
  end
  object gb_com_settings: TGroupBox
    Left = 488
    Top = 248
    Width = 153
    Height = 81
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1087#1086#1088#1090#1072
    TabOrder = 0
    object cb_com_port: TComboBox
      Left = 8
      Top = 24
      Width = 73
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = cb_com_portChange
    end
    object cb_com_baudrate: TComboBox
      Left = 8
      Top = 52
      Width = 73
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 1
      TabOrder = 1
      Text = '115200'
      OnChange = cb_com_baudrateChange
      Items.Strings = (
        '9600'
        '115200')
    end
    object btn_com_refresh: TButton
      Left = 87
      Top = 25
      Width = 58
      Height = 19
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      TabOrder = 2
      OnClick = btn_com_refreshClick
    end
    object btn_Author: TButton
      Left = 87
      Top = 53
      Width = 58
      Height = 19
      Caption = #1040#1074#1090#1086#1088
      TabOrder = 3
      OnClick = btn_AuthorClick
    end
  end
  object btn_recieve_file: TButton
    Left = 488
    Top = 208
    Width = 89
    Height = 25
    Caption = #1055#1088#1080#1085#1103#1090#1100' '#1092#1072#1081#1083
    TabOrder = 1
    OnClick = btn_recieve_fileClick
  end
  object m: TMemo
    Left = 8
    Top = 8
    Width = 473
    Height = 321
    ScrollBars = ssBoth
    TabOrder = 2
    WordWrap = False
  end
  object btn_ack: TButton
    Left = 488
    Top = 40
    Width = 89
    Height = 25
    Caption = 'btn_ack'
    TabOrder = 3
    OnClick = command_transmit
  end
  object btn_nack: TButton
    Left = 488
    Top = 72
    Width = 89
    Height = 25
    Caption = 'btn_nack'
    TabOrder = 4
    OnClick = command_transmit
  end
  object btn_C: TButton
    Left = 488
    Top = 8
    Width = 89
    Height = 25
    Caption = 'btn_C'
    TabOrder = 5
    OnClick = command_transmit
  end
  object Button4: TButton
    Left = 488
    Top = 104
    Width = 89
    Height = 25
    Caption = 'Button4'
    TabOrder = 6
    OnClick = Button4Click
  end
  object btn_open: TButton
    Left = 584
    Top = 8
    Width = 57
    Height = 233
    Caption = 'btn_open'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 7
    OnClick = btn_openClick
  end
  object Edit1: TEdit
    Left = 176
    Top = 304
    Width = 289
    Height = 21
    TabOrder = 8
    Text = 'Edit1'
  end
  object Button1: TButton
    Left = 488
    Top = 136
    Width = 89
    Height = 25
    Caption = 'Button1'
    TabOrder = 9
    OnClick = Button1Click
  end
  object XPManifest: TXPManifest
    Left = 48
    Top = 104
  end
  object com: TBComPort
    BaudRate = br9600
    ByteSize = bs8
    InBufSize = 2048
    OutBufSize = 2048
    Parity = paNone
    Port = 'COM4'
    SyncMethod = smThreadSync
    StopBits = sb1
    Timeouts.ReadInterval = -1
    Timeouts.ReadTotalMultiplier = 0
    Timeouts.ReadTotalConstant = 0
    Timeouts.WriteTotalMultiplier = 100
    Timeouts.WriteTotalConstant = 1000
    OnRxChar = comRxChar
    Left = 16
    Top = 104
  end
end
