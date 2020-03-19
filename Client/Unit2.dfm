object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'TCP '#25171#27934#23458#25143#31471
  ClientHeight = 486
  ClientWidth = 656
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox2: TGroupBox
    Left = 35
    Top = 24
    Width = 254
    Height = 127
    Caption = 'Local Param'
    TabOrder = 0
    object Label1: TLabel
      Left = 144
      Top = 27
      Width = 24
      Height = 13
      Caption = #32534#21495
    end
    object Button1: TButton
      Left = 135
      Top = 81
      Width = 97
      Height = 25
      Caption = #28608#27963#26412#22320#31471#21475
      TabOrder = 0
      OnClick = Button1Click
    end
    object EditIP: TEdit
      Left = 30
      Top = 56
      Width = 99
      Height = 21
      TabOrder = 1
      Text = '192.168.6.8'
    end
    object EditPort: TEdit
      Left = 30
      Top = 83
      Width = 99
      Height = 21
      TabOrder = 2
      Text = '3467'
    end
    object EditNumb: TEdit
      Left = 32
      Top = 24
      Width = 97
      Height = 21
      TabOrder = 3
      Text = '123'
    end
  end
  object GroupBox1: TGroupBox
    Left = 365
    Top = 31
    Width = 244
    Height = 105
    Caption = #26381#21153#22120
    TabOrder = 1
    object EditServerIP: TEdit
      Left = 24
      Top = 24
      Width = 121
      Height = 21
      TabOrder = 0
      Text = '185.228.184.142'
    end
    object EditServerPort: TEdit
      Left = 24
      Top = 64
      Width = 121
      Height = 21
      OEMConvert = True
      TabOrder = 1
      Text = '3346'
    end
    object Button2: TButton
      Left = 151
      Top = 64
      Width = 75
      Height = 25
      Caption = #36830#25509
      TabOrder = 2
      OnClick = Button2Click
    end
  end
  object Memo1: TMemo
    Left = 35
    Top = 246
    Width = 560
    Height = 232
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object EditPeerNumb: TLabeledEdit
    Left = 40
    Top = 176
    Width = 121
    Height = 21
    EditLabel.Width = 52
    EditLabel.Height = 13
    EditLabel.Caption = 'Peer Numb'
    TabOrder = 3
    Text = '233'
  end
  object Button3: TButton
    Left = 167
    Top = 174
    Width = 75
    Height = 25
    Caption = #35831#27714#36830#25509
    TabOrder = 4
    OnClick = Button3Click
  end
  object IdTCPServer1: TIdTCPServer
    Bindings = <>
    DefaultPort = 0
    OnConnect = IdTCPServer1Connect
    ReuseSocket = rsTrue
    OnExecute = IdTCPServer1Execute
    Left = 64
    Top = 360
  end
  object IdTCPClient1: TIdTCPClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    ReuseSocket = rsTrue
    Left = 176
    Top = 360
  end
  object IdTCPClient2: TIdTCPClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    ReuseSocket = rsTrue
    Left = 280
    Top = 360
  end
end
