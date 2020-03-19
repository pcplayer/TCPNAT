unit Unit2;
{--------------------------------------------------------------------------------------
  TCP punching test client app.

  1. 每个客户端一个整数编号。
  2. 客户端向服务器端发起连接后，声明自己。
  3. 客户端向服务器请求连接另外一个 Peer。
  4. 客户端收到来自服务器的请求连接命令，解析命令里面的 Peer，向对方发起连接。
  5. 客户端自己的 TCP 服务器，接收来自对方的连接。
  6. 测试需要：客户端连接 Peer 成功后，发送一个字符串。收到对方来的字符串，显示它。字符串包含自己的编号。


  pcplayer 2020-3-15
--------------------------------------------------------------------------------------}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdTCPConnection, IdTCPClient,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer, Vcl.StdCtrls,
  CommandObj, Vcl.ExtCtrls, IdContext;

type
  TForm2 = class(TForm)
    IdTCPServer1: TIdTCPServer;
    IdTCPClient1: TIdTCPClient;
    IdTCPClient2: TIdTCPClient;
    EditPort: TEdit;
    Button1: TButton;
    EditIP: TEdit;
    GroupBox1: TGroupBox;
    EditServerIP: TEdit;
    EditServerPort: TEdit;
    Button2: TButton;
    GroupBox2: TGroupBox;
    EditNumb: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    EditPeerNumb: TLabeledEdit;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button3Click(Sender: TObject);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure IdTCPServer1Connect(AContext: TIdContext);
  private
    { Private declarations }
    FMyExit: Boolean;

    procedure WriteLog(const S: string);
    procedure ReadCmdFromServer;
    procedure ConnectPeer(const PeerIP: string; const PeerPort: Word);
    procedure SendHelloToPeer(const Hello: string);
    procedure ReadCmdFromPeer;

    procedure RequestPeer(const PeerNumb: Integer);
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses REST.Json, System.Threading;

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
var
  AIP: string;
  APort: Word;
begin
  AIP := EditIP.Text;
  APort := StrToInt(EditPort.Text);

  with IdTCPServer1.Bindings.Add do
  begin
    IP := AIP;
    Port := APort;
  end;
//
  IdTCPServer1.DefaultPort := APort;
  IdTCPServer1.Active := True;

  //用于连接服务器
  IdTCPClient1.BoundIP := AIP;
  IdTCPClient1.BoundPort := APort;

  //用于连接 Peer
  IdTCPClient2.BoundIP := AIP;
  IdTCPClient2.BoundPort := APort;
end;

procedure TForm2.Button2Click(Sender: TObject);
var
  Cmd: TMyCommand;
  S: string;
begin
  //连接服务器
//  if IdTCPClient1.Connected then
//  begin
//    FMyExit := True;
//    IdTCPClient1.Disconnect;
//  end;

  IdTCPClient1.Host := EditServerIP.Text;
  IdTCPClient1.Port := StrToInt(EditServerPort.Text);

  IdTCPClient1.ConnectTimeout := 1000;
  IdTCPClient1.Connect;

  //发命令
  Cmd := TMyCommand.Create;
  try
    Cmd.Cmd := TCmd.cmdHello;
    Cmd.Numb := StrToInt(EditNumb.Text);

    S := TJSon.ObjectToJsonString(Cmd);

    IdTCPCLient1.IOHandler.WriteLn(S);

    //开启读，异步
    TTask.Run(
      procedure
      begin
        Self.ReadCmdFromServer;
      end
    );
  finally
    Cmd.Free;
  end;
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
  Self.RequestPeer(StrToInt(EditPeerNumb.Text));
end;

procedure TForm2.ConnectPeer(const PeerIP: string; const PeerPort: Word);
var
  Cmd: TMyCommand;
  S: string;
begin
  try
    if IdTCPClient2.Connected then IdTCPClient2.Disconnect;

    Self.WriteLog('IdTCPClient2 开始向 Peer 发起连接');
    IdTCPClient2.Host := PeerIP;
    IdTCPClient2.Port := PeerPort;
    IdTCPClient2.ConnectTimeout := 3000;
    IdTCPClient2.Connect;
    Memo1.Lines.Add('连接对方 Peer 成功！');

    // 发送一条消息给 Peer

//    Cmd := TMyCommand.Create;
//    Cmd.Numb := StrToInt(EditNumb.Text);
//    Cmd.Cmd := TCmd.cmdHello;

    Self.SendHelloToPeer('Hello, ');

    //开启读线程
    TTask.Run(
      procedure
      begin
        Self.ReadCmdFromPeer;
      end
    );
  except
  end;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FMyExit := True;

  if IdTCPClient1.Connected then IdTCPClient1.Disconnect;
  if IdTCPServer1.Active then IdTCPServer1.Active := False;
  if IdTCPClient2.Connected then IdTCPClient2.Disconnect;

end;

procedure TForm2.IdTCPServer1Connect(AContext: TIdContext);
begin
  Self.WriteLog('有来自 Peer 的新连接');
end;

procedure TForm2.IdTCPServer1Execute(AContext: TIdContext);
var
  S: string;
begin
  S := AContext.Connection.IOHandler.ReadLn();
  if S <> '' then
  begin
    Self.WriteLog(S);

    S := 'From Peer Server, Numb = ' + EditNumb.Text + ' : ' + S;

    AContext.Connection.IOHandler.WriteLn(S);    //收到 Peer 发来的消息，回送。
  end;
end;

procedure TForm2.ReadCmdFromPeer;
var
  S: string;
begin
  //在线程中执行
  if IdTCPClient2.Connected then
  begin
    IdTCPClient2.ReadTimeout := 500;

    while not Self.FMyExit do
    begin
      S := IdTCPClient2.IOHandler.ReadLn();
      if S = '' then Continue;
      
      TThread.Synchronize(nil,
      procedure
      begin
        Memo1.Lines.Add(S);
      end
      );
    end;
  end;
end;

procedure TForm2.ReadCmdFromServer;
var
  S: string;
  Cmd: TMyCommand;
begin
  IdTCPClient1.ReadTimeout := 1000;
  FMyExit := False;
  while not FMyExit do
  begin
    try
      S := IdTCPClient1.IOHandler.ReadLn();
      if S = '' then Continue;

      Self.WriteLog('收到来自服务器的命令：');
      Self.WriteLog(S);

      Cmd := nil;
      try
        Cmd := TJSON.JSONtoObject<TMyCommand>(S);
      except
        Continue;
      end;

      if Assigned(Cmd) then
      begin
        if Cmd.Cmd = TCmd.cmdCallPeer then
        begin
          //向对方发起打洞连接.
          Self.WriteLog('开始向 Peer 发起连接');
          TTask.Run(
          procedure
          begin
            Self.ConnectPeer(Cmd.PeerIP, Cmd.PeerPort);
          end
          );
        end;
      end;
    except
    end;
  end;

  Self.WriteLog('和服务器的连接被断开');
end;

procedure TForm2.RequestPeer(const PeerNumb: Integer);
var
  Cmd: TMyCommand;
  S: string;
begin
  //请求连接 Peer， 发命令给 Server

  if not IdTCPClient1.Connected  then
  begin
    Memo1.Lines.Add('尚未连接服务器');
    Exit;
  end;

  Cmd := TMyCommand.Create;
  try
    Cmd.Cmd := TCmd.cmdCallPeer;
    Cmd.Numb := PeerNumb;

    S := TJSON.ObjectToJsonString(Cmd);
    IdTCPClient1.IOHandler.WriteLn(S);

    Self.WriteLog('请求连接 Peer;');
    Self.WriteLog('发送: ' + S);
  finally
    Cmd.Free;
  end;
end;

procedure TForm2.SendHelloToPeer(const Hello: string);
var
  Cmd: string;
begin
  Cmd := Hello + ': MyNumb = ' + EditNumb.Text;

  if IdTCPClient2.Connected then
  begin
    IdTCPClient2.IOHandler.WriteLn(Cmd);

    TThread.Synchronize(nil,
    procedure
    begin
      Memo1.Lines.Add('发送给 Peer: ' + Cmd);
    end
    );

  end;
end;

procedure TForm2.WriteLog(const S: string);
begin
  TThread.Synchronize(nil,
  procedure
  begin
    Memo1.Lines.Add(S);
  end
  );
end;

end.
