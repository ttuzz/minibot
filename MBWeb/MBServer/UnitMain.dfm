object frmMain: TfrmMain
  Left = 670
  Top = 798
  Width = 577
  Height = 219
  Caption = 'MBServer'
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
  object gbRemote: TGroupBox
    Left = 368
    Top = 8
    Width = 193
    Height = 145
    Caption = #1044#1086#1089#1090#1091#1087
    TabOrder = 2
    object Label2: TLabel
      Left = 8
      Top = 16
      Width = 38
      Height = 13
      Caption = #1055#1072#1088#1086#1083#1100
    end
    object label_MyIP: TLabel
      Left = 8
      Top = 116
      Width = 85
      Height = 21
      Caption = 'label_myip'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -18
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label1: TLabel
      Left = 8
      Top = 64
      Width = 25
      Height = 13
      Caption = #1055#1086#1088#1090
    end
    object ed_rem_pass: TEdit
      Left = 8
      Top = 32
      Width = 121
      Height = 21
      TabOrder = 0
      Text = #1055#1072#1088#1086#1083#1100
    end
    object ed_rem_port: TEdit
      Left = 8
      Top = 80
      Width = 121
      Height = 21
      ReadOnly = True
      TabOrder = 1
      Text = '5000'
    end
  end
  object mInp: TMemo
    Left = 8
    Top = 8
    Width = 353
    Height = 145
    TabOrder = 0
  end
  object btnActivate: TButton
    Left = 372
    Top = 157
    Width = 75
    Height = 25
    Caption = 'btnActivate'
    TabOrder = 1
    OnClick = btnActivateClick
  end
  object Edit1: TEdit
    Left = 8
    Top = 160
    Width = 265
    Height = 21
    TabOrder = 3
    Text = 'Edit1'
  end
  object Button1: TButton
    Left = 280
    Top = 160
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 4
  end
  object XPManifest: TXPManifest
    Left = 24
    Top = 40
  end
  object tmr_IP: TTimer
    Interval = 5000
    OnTimer = tmr_IPTimer
    Left = 88
    Top = 40
  end
  object iserver: TTcpServer
    OnAccept = iserverAccept
    Left = 56
    Top = 40
  end
end
