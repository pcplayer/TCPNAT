object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 144
    Top = 240
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 416
    Top = 32
    Width = 185
    Height = 89
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object Button2: TButton
    Left = 272
    Top = 240
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 2
    OnClick = Button2Click
  end
  object IdTCPClient1: TIdTCPClient
    BoundIP = '192.168.6.8'
    BoundPort = 63344
    ConnectTimeout = 0
    Host = '192.168.6.8'
    IPVersion = Id_IPv4
    Port = 63344
    ReadTimeout = -1
    ReuseSocket = rsTrue
    Left = 376
    Top = 136
  end
  object IdTCPServer1: TIdTCPServer
    Bindings = <
      item
        IP = '192.168.6.8'
        Port = 63344
      end>
    DefaultPort = 63344
    OnConnect = IdTCPServer1Connect
    ReuseSocket = rsTrue
    OnExecute = IdTCPServer1Execute
    Left = 192
    Top = 64
  end
  object IdTCPClient2: TIdTCPClient
    BoundIP = '192.168.6.8'
    BoundPort = 3335
    ConnectTimeout = 0
    Host = '192.168.6.8'
    IPVersion = Id_IPv4
    Port = 63344
    ReadTimeout = -1
    ReuseSocket = rsTrue
    Left = 400
    Top = 216
  end
end
