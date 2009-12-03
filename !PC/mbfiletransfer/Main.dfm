object frm_main: Tfrm_main
  Left = 1075
  Top = 667
  Width = 481
  Height = 384
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
  object gb_files: TGroupBox
    Left = 8
    Top = 16
    Width = 217
    Height = 273
    Caption = #1044#1086#1089#1090#1091#1087#1085#1099#1077' '#1092#1072#1081#1083#1099
    TabOrder = 0
    object lb_files: TListBox
      Left = 8
      Top = 16
      Width = 201
      Height = 249
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object gb_tools: TGroupBox
    Left = 264
    Top = 64
    Width = 185
    Height = 169
    Caption = #1048#1085#1089#1090#1088#1091#1084#1077#1085#1090#1099
    TabOrder = 1
    object btn_recieve_file: TButton
      Left = 16
      Top = 56
      Width = 105
      Height = 25
      Caption = #1055#1088#1080#1085#1103#1090#1100' '#1092#1072#1081#1083
      TabOrder = 0
      OnClick = btn_recieve_fileClick
    end
    object btn_refresh_files: TButton
      Left = 16
      Top = 24
      Width = 105
      Height = 25
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100'  '#1089#1087#1080#1089#1086#1082
      TabOrder = 1
    end
  end
  object gb_com_settings: TGroupBox
    Left = 240
    Top = 256
    Width = 153
    Height = 81
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1087#1086#1088#1090#1072
    TabOrder = 2
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
  object XPManifest: TXPManifest
    Left = 416
    Top = 16
  end
  object com: TBComPort
    BaudRate = br115200
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
    Left = 384
    Top = 16
  end
  object dlg_save: TSaveDialog
    Filter = #1057#1094#1077#1085#1072#1088#1080#1080' OR '#1089#1077#1082#1074#1077#1085#1089#1086#1088#1072', *.ors|*.ors'
    Title = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1089#1094#1077#1085#1072#1088#1080#1081
    Left = 312
    Top = 16
  end
  object dlg_open: TOpenDialog
    Filter = #1057#1094#1077#1085#1072#1088#1080#1080' OR '#1089#1077#1082#1074#1077#1085#1089#1086#1088#1072', *.ors|*.ors'
    Title = #1054#1090#1082#1088#1099#1090#1100' '#1089#1094#1077#1085#1072#1088#1080#1081
    Left = 344
    Top = 16
  end
end
