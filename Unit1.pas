unit Unit1;
{-------------------------------------------------------------------------------
  ���� TCP �򶴡�

  ���Ȳ��� IdTCPServer �� IdTCPClient �ܹ�����ͬ�Ķ˿ڡ�

  ���Խ����
  1. �������� Server �� Client �� ReuseSocket := True;
  2. ���� Server �� DefaultPort �� Bindings ������������� IP �� PORT Ϊͬ���� 63344
  3. ���� IdTCPClient1 �� BoundPort Ϊ 63344���� Server ��ͬ��
  4. �������� Server ������
  5. ��ʼ Client �� Server �������ӣ��ɹ���˵�� Client ���Դ򿪺� Server ��ͬ�Ķ˿ڡ�
  6. Client ��ö˿ڷ��ַ����������ַ������� Server.OnExecute ����дһ�����ʹ��롣
     ʵ�ʲ��Է��֣�Client �ܹ��յ��Լ�����ȥ���ַ������� Server.OnExcute û�д�����
     ˵�� Client �򿪵ı��ض˿ڵ�ȷ�� Server �򿪵ı��ؼ����˿ڡ�


  Ҫ�򶴵Ļ���һ���ͻ�����Ҫ��
  1. һ�� Client ȥ���Ӵ��õ��м� Server��
  2. һ������ Server ���ڵȴ����� Peer �� Client �����ӣ�
  3. һ�� Client ����ȥ���� Peer �� Server��Ҫ���Ӷ�� Peer ����Ҫ��������� Client��
  4. �����м�������� Client �����ڽ������� Peer ����������ı��� IdTCPServer ������ռ����ͬ�˿ڡ�

  ԭ��A�ͻ��˱��ص� Client �����м��������ʹ���м������֪���ÿͻ��˵� TCP �˿ڣ�����˿ڿ����� NAT �ģ� ��
        �� Peer��B�ͻ��ˣ� Ҫ�������A�ͻ��ˣ����ӷ�����֪������ A �ͻ��˵Ķ˿ڣ�Bȥ������˿ڷ������ӣ�
        ��ʱ��A�ͻ��˵� IdTCPServer Ҳͬʱ�򿪼�����Ҳ������˿ڣ����B�ͻ��˿�����������˿ڡ�

  Ŀǰ�Ĳ��Կ��������� IdTCP �ؼ���ʵ������������ WINDOWS �����ǿ��Գ����ġ�

  ���Է��������������Ҫ3̨���ԡ������ͻ��˺�һ���м��������
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
