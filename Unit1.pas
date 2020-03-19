unit Unit1;
{-------------------------------------------------------------------------------
  测试 TCP 打洞。

  首先测试 IdTCPServer 和 IdTCPClient 能够打开相同的端口。

  测试结果：
  1. 首先设置 Server 和 Client 的 ReuseSocket := True;
  2. 设置 Server 的 DefaultPort 和 Bindings 里面针对网卡的 IP 的 PORT 为同样的 63344
  3. 设置 IdTCPClient1 的 BoundPort 为 63344，和 Server 相同。
  4. 启动，打开 Server 监听；
  5. 开始 Client 向 Server 发起连接，成功。说明 Client 可以打开和 Server 相同的端口。
  6. Client 向该端口发字符串；并读字符串。在 Server.OnExecute 里面写一个回送代码。
     实际测试发现，Client 能够收到自己发出去的字符串，而 Server.OnExcute 没有触发。
     说明 Client 打开的本地端口的确是 Server 打开的本地监听端口。


  要打洞的话，一个客户端需要：
  1. 一个 Client 去连接打洞用的中间 Server；
  2. 一个本地 Server 用于等待来自 Peer 的 Client 的连接；
  3. 一个 Client 用于去连接 Peer 的 Server。要连接多个 Peer 就需要多个这样的 Client。
  4. 连接中间服务器的 Client 和用于接收来自 Peer 的连接请求的本地 IdTCPServer 必须是占用相同端口。

  原理：A客户端本地的 Client 连接中间服务器，使得中间服务器知道该客户端的 TCP 端口（这个端口可能是 NAT 的） ；
        当 Peer（B客户端） 要连接这个A客户端，它从服务器知道的是 A 客户端的端口，B去向这个端口发起连接；
        此时，A客户端的 IdTCPServer 也同时打开监听的也是这个端口，因此B客户端可以连上这个端口。

  目前的测试看来，采用 IdTCP 控件来实现上述需求，在 WINDOWS 底下是可以成立的。

  测试方法：这个测试需要3台电脑。两个客户端和一个中间服务器。
-------------------------------------------------------------------------------}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdCustomTCPServer, IdTCPServer,
  IdContext;

type
  TForm1 = class(TForm)
    IdTCPClient1: TIdTCPClient;
    Button1: TButton;
    IdTCPServer1: TIdTCPServer;
    Memo1: TMemo;
    IdTCPClient2: TIdTCPClient;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure FormCreate(Sender: TObject);
    procedure IdTCPServer1Connect(AContext: TIdContext);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  IdTCPClient1.Connect;

end;

procedure TForm1.Button2Click(Sender: TObject);
var
  S: string;
begin
  IdTCPClient1.IOHandler.WriteLn('abc22');
  S := IdTCPClient1.IOHandler.ReadLn();
  Memo1.Lines.Add(S);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  IdTCPClient1.Disconnect;

  Sleep(200);
  IdTCPServer1.Active := False;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  IdTCPServer1.Active := True;
end;

procedure TForm1.IdTCPServer1Connect(AContext: TIdContext);
begin
  TThread.Synchronize(nil,
  procedure
  begin
    Memo1.Lines.Add(AContext.Binding.PeerIP);
  end

  );
end;

procedure TForm1.IdTCPServer1Execute(AContext: TIdContext);
var
  S: string;
begin
  //
  S := AContext.Connection.IOHandler.ReadLn();
  S := 'From Server: ' + S;
  AContext.Connection.IOHandler.WriteLn(S);

end;

end.
