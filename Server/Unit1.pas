unit Unit1;
{--------------------------------------------------------------------------------------
  TCP �򶴵��м���������򵥷����������ܣ�
  1. ��ס�ͻ��˵� IP/PORT��
  2. �յ��ͻ��˵Ĵ����Ѱ������һ���ͻ������������ȥ����������һ���ͻ��� IP/PORT ����ȥ��

  ��ˣ��򻯲����£�ֻ��Ҫһ�����������������Ϊ�ͻ��˷��������������Ҳ��Ϊ�����������ͻ��˵����
  Ϊ�˼��������������ֱ�ӽ�������װΪ���󣬽��������л�Ϊ JSON ��ֱ�ӷ����ַ�����

  �����������̣�
  1. ÿ�� PEER ��һ���Լ��ı�š����ӷ������ɹ��󣬷�������������������Լ��ı�š���Ϊ�ǲ��ԣ�������ʹ��������
  2. �յ�A�ͻ����������Ϊ����󣬲鿴 Peer �ı�š���������ת�����Է� Peer�༴B�ͻ��ˣ������ IP/PORT �滻ΪA�ͻ��˵ġ�
  3. �� B �ͻ��˵� IP/PORT ���͸� A �ͻ��ˡ�

  �ͻ������̣�
  1. �յ����Է������������������������������ IP/PORT �������ӡ�


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
  ��ֻ��һ���ͻ������������������һ�� TIdTCPClient ����ȥ�����������Ƿ���Է���ͨ���ÿͻ��˵� NAT

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

  Memo1.Lines.Add('�ͻ��� PeerIP = ' + PeerIP + '; PeerPort = ' + PeerPort.ToString);
  IdTCPClient1.Host := PeerIP;
  IdTCPClient1.Port := PeerPort;
  IdTCPClient1.ConnectTimeout := 1000;

  IdTCPClient1.Connect;

  Self.Memo1.Lines.Add('�������ӿͻ��˳ɹ�');
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
      Memo1.Lines.Add('���ӣ��ͻ��� IP = ' + IP + '; �ͻ���Port = ' + IntToStr(Port));
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

    //������������Լ��ı��.
    TCmd.cmdHello:
    begin
      AData := AContext.Data;
      if Assigned(AData) then FreeAndNil(AData);

      ACmdObj.IP := AContext.Connection.Socket.Binding.PeerIP;
      ACmdObj.Port := AContext.Connection.Socket.Binding.PeerPort;
      AContext.Data := ACmdObj;   //���Լ�����ȥ��
    end;

    //�������� B �ͻ���
    TCmd.cmdCallPeer:
    begin
      //����������B��������ı�Ŵ���B�ı��
      if Self.FindPeer(ACmdObj.Numb, PeerIP, PeerPort, BContext) then
      begin

        //���ѳ����� B �� IP/PORT ���ͻ�A
        ACmdObj.PeerIP := PeerIP;
        ACmdObj.PeerPort := PeerPort;
        S := TJSON.ObjectToJSONString(ACmdObj);
        AContext.Connection.IOHandler.WriteLn(S);

        //������͸� B
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
