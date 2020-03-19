unit Unit1;
{--------------------------------------------------------------------------------------
  TCP 打洞的中间服务器。简单服务器，功能：
  1. 记住客户端的 IP/PORT；
  2. 收到客户端的打洞命令，寻找另外一个客户，将打洞命令发过去。并将另外一个客户的 IP/PORT 发过去。

  因此，简化测试下，只需要一条服务器端命令。即作为客户端发给服务器的命令，也作为服务器发给客户端的命令。
  为了简化命令解析，这里直接将参数封装为对象，将对象序列化为 JSON 后直接发送字符串。

  服务器端流程：
  1. 每个 PEER 有一个自己的编号。连接服务器成功后，发送命令给服务器声明自己的编号。因为是测试，这里编号使用整数。
  2. 收到A客户端命令，解析为对象后，查看 Peer 的编号。将此命令转发给对方 Peer亦即B客户端，里面的 IP/PORT 替换为A客户端的。
  3. 将 B 客户端的 IP/PORT 发送给 A 客户端。

  客户端流程：
  1. 收到来自服务器的命令，解析命令后，向命令里面的 IP/PORT 发起连接。


  pcplayer 2020-3-15
--------------------------------------------------------------------------------------}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdContext, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdTCPServer, CommandObj, Vcl.StdCtrls, Vcl.ExtCtrls,
  IdTCPConnection, IdTCPClient;

type
  TForm1 = class(TForm)
    IdTCPServer1: TIdTCPServer;
    Edit1: TEdit;
    Button1: TButton;
    Memo1: TMemo;
    Memo2: TMemo;
    Timer1: TTimer;
    IdTCPClient1: TIdTCPClient;
    Button2: TButton;
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure Button1Click(Sender: TObject);
    procedure IdTCPServer1Connect(AContext: TIdContext);
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    function ParseCmdString(const Cmd: string): TMyCommand;
    function FindPeer(const Numb: Integer; var IP: string; var Port: Word; var BContext: TIdContext): Boolean;

    procedure ShowConnections;
    procedure DoConnectPeerByClient(const PeerIP: string; const PeerPort: Word);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses REST.Json;


{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  IdTCPServer1.DefaultPort := StrToInt(Edit1.Text);
  IdTCPServer1.Active := True;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  PeerIP: string;
  PeerPort: Word;
  AList: TList;
  BContext: TIdContext;
begin
{------------------------------------------------------------------------------
  当只有一个客户端连过来，这里采用一个 TIdTCPClient 连回去。这样测试是否可以反向通过该客户端的 NAT

------------------------------------------------------------------------------}
  if IdTCPServer1.Contexts.Count <> 1 then Exit;

  AList := IdTCPServer1.Contexts.LockList;
  try
    BContext := TIdContext(AList.Items[0]);

    PeerPort := BContext.Connection.Socket.Binding.PeerPort;
    PeerIP := BContext.Connection.Socket.Binding.PeerIP;

    Self.DoConnectPeerByClient(PeerIP, PeerPort);
  finally
    IdTCPServer1.Contexts.UnlockList;
  end;
end;

procedure TForm1.DoConnectPeerByClient(const PeerIP: string; const PeerPort: Word);
begin
  if IdTCPClient1.Connected then IdTCPClient1.Disconnect;

  Memo1.Lines.Add('客户端 PeerIP = ' + PeerIP + '; PeerPort = ' + PeerPort.ToString);
  IdTCPClient1.Host := PeerIP;
  IdTCPClient1.Port := PeerPort;
  IdTCPClient1.ConnectTimeout := 1000;

  IdTCPClient1.Connect;

  Self.Memo1.Lines.Add('反向连接客户端成功');
  IdTCPClient1.IOHandler.WriteLn('Hello, This is from Server side back connection');
  Memo1.Lines.Add( IdTCPClient1.IOHandler.ReadLn());
  IdTCPClient1.Disconnect;
end;

function TForm1.FindPeer(const Numb: Integer; var IP: string;
  var Port: Word; var BContext: TIdContext): Boolean;
var
  i: Integer;
  Obj: TMyCommand;
  AList: TList;
  AContext: TIdContext;
begin
  AList := IdTCPServer1.Contexts.LockList;
  try
    for i := 0 to AList.Count -1 do
    begin
      AContext := TIdContext(AList.Items[i]);

      if Assigned(AContext.Data) then
      begin
        if AContext.Data is TMyCommand then
        begin
          Obj := TMyCommand(AContext.Data);
          Result := (Obj.Numb = Numb);
          if Result then
          begin
            IP := Obj.IP;
            Port := Obj.Port;
            BContext := AContext;
            Break;
          end;
        end;
      end;
    end;
  finally
    IdTCPServer1.Contexts.UnlockList;
  end;
end;

procedure TForm1.IdTCPServer1Connect(AContext: TIdContext);
var
  IP: string;
  Port: Word;
begin
  IP := AContext.Connection.Socket.Binding.PeerIP;
  Port := AContext.Connection.Socket.Binding.PeerPort;

  TThread.Synchronize(nil,
    procedure
    begin
      Memo1.Lines.Add('连接，客户端 IP = ' + IP + '; 客户端Port = ' + IntToStr(Port));
    end

  );
end;

procedure TForm1.IdTCPServer1Execute(AContext: TIdContext);
var
  S: string;
  ACmdObj: TMyCommand;
  BContext: TIdContext;

  PeerIP: string;
  PeerPort: Word;
  AData: TObject;
begin
  S := AContext.Connection.IOHandler.ReadLn();

  TThread.Synchronize(nil,
    procedure
    begin
      Memo1.Lines.Add(S);
    end
  );

  ACmdObj := nil;
  ACmdObj := Self.ParseCmdString(S);
  if not Assigned(ACmdObj) then Exit;

  case ACmdObj.Cmd of
    TCmd.cmdNull:
    begin
      FreeAndNil(ACmdObj);
    end;

    //向服务器声明自己的编号.
    TCmd.cmdHello:
    begin
      AData := AContext.Data;
      if Assigned(AData) then FreeAndNil(AData);

      ACmdObj.IP := AContext.Connection.Socket.Binding.PeerIP;
      ACmdObj.Port := AContext.Connection.Socket.Binding.PeerPort;
      AContext.Data := ACmdObj;   //把自己挂上去。
    end;

    //请求连接 B 客户端
    TCmd.cmdCallPeer:
    begin
      //命令是请求B，则里面的编号代表B的编号
      if Self.FindPeer(ACmdObj.Numb, PeerIP, PeerPort, BContext) then
      begin

        //将搜出来的 B 的 IP/PORT 发送回A
        ACmdObj.PeerIP := PeerIP;
        ACmdObj.PeerPort := PeerPort;
        S := TJSON.ObjectToJSONString(ACmdObj);
        AContext.Connection.IOHandler.WriteLn(S);

        //将命令发送给 B
        ACmdObj.Numb := TMyCommand(AContext.Data).Numb;
        ACmdObj.PeerIP := TMyCommand(AContext.Data).IP;
        ACmdObj.PeerPort := TMyCommand(AContext.Data).Port;
        S := TJSON.ObjectToJSONString(ACmdObj);
        BContext.Connection.IOHandler.WriteLn(S);
      end;
    end;
  end;
end;

function TForm1.ParseCmdString(const Cmd: string): TMyCommand;
begin
  try
    Result :=  TJSON.JSONtoObject<TMyCommand>(Cmd);
  except

  end;
end;

procedure TForm1.ShowConnections;
var
  i: Integer;
  Obj: TMyCommand;
  AList: TList;
  AContext: TIdContext;
  Numb: Integer;
  S: string;
begin
  Memo2.Lines.Clear;

  if not IdTCPServer1.Active then Exit;


  AList := IdTCPServer1.Contexts.LockList;
  try
    for I := 0 to (AList.Count - 1) do
    begin
      Numb := 0;
      S := '';
      AContext := TIdContext(AList.Items[i]);
      if Assigned(AContext.Data) then
      begin
        Numb := TMyCommand(AContext.Data).Numb;
      end;

      S := Numb.ToString + ' : ' + AContext.Binding.PeerIP + ' : ' + AContext.Binding.PeerPort.ToString;

      TThread.Synchronize(nil,
      procedure
      begin
        Memo2.Lines.Add(S);
      end
      );

    end;

  finally
    IdTCPServer1.Contexts.UnlockList;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  ShowConnections;
end;

end.
