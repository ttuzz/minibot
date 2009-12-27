object frmMain: TfrmMain
  Left = 756
  Top = 570
  BorderStyle = bsSingle
  Caption = 'MB_servo_distance'
  ClientHeight = 350
  ClientWidth = 296
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 312
    Width = 12
    Height = 13
    Caption = '35'
  end
  object Label2: TLabel
    Left = 32
    Top = 312
    Width = 12
    Height = 13
    Caption = '35'
  end
  object Label3: TLabel
    Left = 56
    Top = 312
    Width = 12
    Height = 13
    Caption = '35'
  end
  object Label4: TLabel
    Left = 80
    Top = 312
    Width = 12
    Height = 13
    Caption = '35'
  end
  object Label5: TLabel
    Left = 104
    Top = 312
    Width = 12
    Height = 13
    Caption = '35'
  end
  object gb_ComSettings: TGroupBox
    Left = 128
    Top = 240
    Width = 161
    Height = 105
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
    object btn_enable_control: TButton
      Left = 8
      Top = 76
      Width = 137
      Height = 21
      Caption = #1055#1086#1076#1082#1083#1102#1095#1080#1090#1100#1089#1103
      TabOrder = 4
      OnClick = btn_enable_controlClick
    end
  end
  object pb_dist1: TProgressBar
    Tag = 1
    Left = 8
    Top = 8
    Width = 17
    Height = 300
    Min = 35
    Max = 102
    Orientation = pbVertical
    Position = 35
    TabOrder = 1
  end
  object pb_dist2: TProgressBar
    Tag = 2
    Left = 32
    Top = 8
    Width = 17
    Height = 300
    Min = 35
    Max = 102
    Orientation = pbVertical
    Position = 35
    TabOrder = 2
  end
  object pb_dist3: TProgressBar
    Tag = 3
    Left = 56
    Top = 8
    Width = 17
    Height = 300
    Min = 35
    Max = 102
    Orientation = pbVertical
    Position = 35
    TabOrder = 3
  end
  object pb_dist4: TProgressBar
    Tag = 4
    Left = 80
    Top = 8
    Width = 17
    Height = 300
    Min = 35
    Max = 102
    Orientation = pbVertical
    Position = 35
    TabOrder = 4
  end
  object pb_dist5: TProgressBar
    Tag = 5
    Left = 104
    Top = 8
    Width = 17
    Height = 300
    Min = 35
    Max = 102
    Orientation = pbVertical
    Position = 35
    TabOrder = 5
  end
  object mem_terminal: TMemo
    Left = 128
    Top = 8
    Width = 161
    Height = 225
    ScrollBars = ssVertical
    TabOrder = 6
    OnKeyPress = mem_terminalKeyPress
  end
  object btn_off: TButton
    Left = 64
    Top = 328
    Width = 57
    Height = 17
    Caption = 'off'
    TabOrder = 7
    OnClick = btn_offClick
  end
  object btn_on: TButton
    Left = 8
    Top = 328
    Width = 57
    Height = 17
    Caption = 'on'
    TabOrder = 8
    OnClick = btn_onClick
  end
  object XPManifest: TXPManifest
    Left = 8
    Top = 8
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
    Left = 40
    Top = 8
  end
end
