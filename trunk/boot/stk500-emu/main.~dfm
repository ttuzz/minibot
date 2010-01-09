object frm_main: Tfrm_main
  Left = 344
  Top = 188
  BorderStyle = bsSingle
  Caption = #1055#1088#1086#1096#1080#1074#1072#1083#1100#1097#1080#1082' v1.0'
  ClientHeight = 80
  ClientWidth = 392
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lb_progress: TLabel
    Left = 176
    Top = 60
    Width = 34
    Height = 19
    Caption = '00%'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lb_port: TLabel
    Left = 8
    Top = 8
    Width = 72
    Height = 13
    Caption = 'COM4, 115200'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lb_author: TLabel
    Left = 312
    Top = 8
    Width = 72
    Height = 13
    Caption = #1040#1074#1090#1086#1088': MiBBiM'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object pb_progress: TProgressBar
    Left = 8
    Top = 24
    Width = 377
    Height = 33
    TabOrder = 0
  end
  object XPManifest: TXPManifest
    Left = 272
    Top = 24
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
    Left = 240
    Top = 24
  end
end
