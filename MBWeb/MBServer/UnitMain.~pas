unit UnitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, XPMan, Sockets,
  WinSock, ExtCtrls{для определения ip WinSock}, UnitServer;

type
  TfrmMain = class(TForm)
    XPManifest: TXPManifest;
    mInp: TMemo;
    btnActivate: TButton;
    label_MyIP: TLabel;
    tmr_IP: TTimer;
    gbRemote: TGroupBox;
    ed_rem_pass: TEdit;
    Label2: TLabel;
    ed_rem_port: TEdit;
    Label1: TLabel;
    Edit1: TEdit;
    iserver: TTcpServer;
    Button1: TButton;
    function GetLocalIP: string;
    procedure btnActivateClick(Sender: TObject);
    procedure iserverAccept(Sender: TObject;
      ClientSocket: TCustomIpClient);
    procedure tmr_IPTimer(Sender: TObject);
    procedure en_dis_interface(Enable: boolean = true);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
    // названия для кнопки
  btnActivate_enable = 'Запустить';
  btnActivate_disable = 'Остановить';
var
  frmMain: TfrmMain;
  server_active: boolean = false;

implementation

{$R *.dfm}

function TfrmMain.GetLocalIP: string;
const WSVer = $101;
var
  wsaData: TWSAData;
  P: PHostEnt;
  Buf: array [0..127] of Char;
begin
  Result := '';
  if WSAStartup(WSVer, wsaData) = 0 then begin
    if GetHostName(@Buf, 128) = 0 then begin
      P := GetHostByName(@Buf);
      if P <> nil then Result := iNet_ntoa(PInAddr(p^.h_addr_list^)^);
    end;
    WSACleanup;
  end;
end;

procedure TfrmMain.btnActivateClick(Sender: TObject);
// запуск сервера
begin
  with iserver do if Active then
  begin
    en_dis_interface;
    Active := false;
    exit;
  end;

  with iserver do try
    LocalPort := '5000';
    Active := true;
    en_dis_interface(false);
  except
    showmessage('Ошибка подключения!');
    iserver.Close;
    en_dis_interface;
    exit;
  end;
  client.pass := ed_rem_pass.Text;    // сбрасываю клиента
  client.session_id := '';
end;

procedure TfrmMain.iserverAccept(Sender: TObject;
  ClientSocket: TCustomIpClient);
// если пришло сообщение
begin
  to_send := inttostr(random(1001)); //строка для отправки
  with ClientSocket do
    Sendln( reciever.parse(Receiveln, RemoteHost) );

  with reciever do  ;
    if to_log <> '' then mInp.Lines.Append(to_log);
end;

procedure TfrmMain.tmr_IPTimer(Sender: TObject);
begin
  label_MyIP.Caption := GetLocalIP;
end;

procedure TfrmMain.en_dis_interface(Enable: boolean);
// активирует/деактивирует интерфейс поле остановки/запуска сервера
  procedure change(c: TControl; enable: boolean);
  begin
    c.Enabled := enable;
  end;
begin
  with btnActivate do
    if Enable then
      Caption := btnActivate_enable
    else
      Caption := btnActivate_disable;
  change(ed_rem_pass, enable);
  change(ed_rem_port, enable);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  en_dis_interface;
  label_MyIP.Caption := GetLocalIP;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  try
    iserver.Close;
    while iserver.Listening do
      Application.ProcessMessages;
    sleep(100);   // ждем, пока сервер закроет сокет
  finally end;
end;

end.

