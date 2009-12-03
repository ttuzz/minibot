object frmMain: TfrmMain
  Left = 584
  Top = 497
  Width = 638
  Height = 309
  Caption = #1050#1086#1085#1074#1077#1088#1090#1077#1088
  Color = clBtnFace
  Constraints.MinHeight = 309
  Constraints.MinWidth = 638
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    630
    279)
  PixelsPerInch = 96
  TextHeight = 13
  object m_Out: TMemo
    Left = 8
    Top = 8
    Width = 385
    Height = 265
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      #1056#1077#1079#1091#1083#1100#1090#1072#1090)
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object gb_Settings: TGroupBox
    Left = 400
    Top = 8
    Width = 225
    Height = 265
    Anchors = [akTop, akRight, akBottom]
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 16
      Width = 57
      Height = 13
      Caption = #1048#1084#1103' '#1092#1072#1081#1083#1072
    end
    object Label2: TLabel
      Left = 8
      Top = 56
      Width = 130
      Height = 13
      Caption = #1050#1086#1101#1092#1092#1080#1094#1080#1077#1085#1090' '#1091#1084#1085#1086#1078#1077#1085#1080#1103
    end
    object vle_Info: TValueListEditor
      Left = 8
      Top = 136
      Width = 209
      Height = 121
      GridLineWidth = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goAlwaysShowEditor, goThumbTracking]
      ScrollBars = ssNone
      Strings.Strings = (
        #1056#1072#1079#1084#1077#1088'='
        #1055#1077#1088#1077#1088#1077#1075#1091#1083#1080#1088#1086#1074#1082#1072'='
        '~'#1096#1080#1084' '#1076#1086'='
        '~'#1096#1080#1084' '#1087#1086#1089#1083#1077'='
        '')
      TabOrder = 0
      TitleCaptions.Strings = (
        #1050#1083#1102#1095
        #1047#1085#1072#1095#1077#1085#1080#1077)
      ColWidths = (
        98
        105)
    end
    object btn_Do: TButton
      Left = 8
      Top = 104
      Width = 209
      Height = 25
      Caption = #1055#1088#1077#1086#1073#1088#1072#1079#1086#1074#1072#1090#1100
      TabOrder = 1
      OnClick = btn_DoClick
    end
    object ed_filename: TEdit
      Left = 8
      Top = 32
      Width = 209
      Height = 21
      TabOrder = 2
      Text = 'test.wav'
    end
    object ed_increase: TEdit
      Left = 8
      Top = 72
      Width = 209
      Height = 21
      TabOrder = 3
      Text = '1,0'
      OnChange = ed_increaseChange
    end
  end
  object XPManifest1: TXPManifest
    Left = 112
    Top = 64
  end
end
