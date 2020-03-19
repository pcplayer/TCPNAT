object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'TCP '#25171#27934#30340#20013#38388#26381#21153#22120
  ClientHeight = 391
  ClientWidth = 692
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Edit1: TEdit
    Left = 24
    Top = 32
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '3346'
  end
  object Button1: TButton
    Left = 168
    Top = 30
    Width = 75
    Height = 25
    Caption = #28608#27963#26381#21153#22120
    TabOrder = 1
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 0
    Top = 164
    Width = 692
    Height = 227
    Align = alBottom
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object Memo2: TMemo
    Left = 0
    Top = 75
    Width = 692
    Height = 89
    Align = alBottom
    Lines.Strings = (
      'Memo2')
    TabOrder = 3
  end
  object Button2: TButton
    Left = 432
    Top = 30
    Width = 75
    Height = 25
    Caption = #36830#25509#23458#25143#31471
    TabOrder = 4
    OnClick = Button2Click
  end
  object IdTCPServer1: TIdTCPServer
    Bindings = <>
    DefaultPort = 0
    OnConnect = IdTCPServer1Connect
    OnExecute = IdTCPServer1Execute
    Left = 272
    Top = 112
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 344
    Top = 200
  end
  object IdTCPClient1: TIdTCPClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    Left = 352
    Top = 24
  end
end
