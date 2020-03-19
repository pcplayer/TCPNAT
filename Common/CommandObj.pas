unit CommandObj;
{--------------------------------------------------------------------------------------
  用于命令的对象。
--------------------------------------------------------------------------------------}
interface

uses System.SysUtils, System.Variants, System.Classes;

type
  TCmd = (cmdNull, cmdHello, cmdCallPeer);

  TMyCommand = class
  private
    FCmd: TCmd;
    FNumb: Integer;
    FIP: string;
    FPort: Word;
    FPeerIP: string;
    FPeerPort: Word;
  public
    property Cmd: TCmd read FCmd write FCmd;
    property Numb: Integer read FNumb write FNumb;
    property IP: string read FIP write FIP;
    property Port: Word read FPort write FPort;
    property PeerIP: string read FPeerIP write FPeerIP;
    property PeerPort: word read FPeerPort write FPeerPort;
  end;

implementation

end.
