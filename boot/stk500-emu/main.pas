unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, XPMan, ComCtrls, ExtCtrls, BCPort,
  {!}packet_generator{!};

type
  Tfrm_main = class(TForm)
    pb_progress: TProgressBar;
    XPManifest: TXPManifest;
    lb_progress: TLabel;
    lb_port: TLabel;
    com: TBComPort;
    lb_author: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure comRxChar(Sender: TObject; Count: Integer);
    function send_command(comm: char; answer: char): boolean;
    function send_packet(packet: string): boolean;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  ack: char = chr($06);
  nak: char = chr($15);
  timeout: word = 1500;
var
  frm_main: Tfrm_main;
  filename: string;
  com_receive: string;

implementation

{$R *.dfm}

procedure wait_ms(ms: word);
var
  start_time: TDateTime;
  is_timeout: boolean;
begin
  start_time := Time;
  repeat
    Application.ProcessMessages;
    is_timeout := (Time-start_time)*24*3600*1000 > ms;
  until (com_receive <> '') or is_timeout;
end;

function Tfrm_main.send_packet(packet: string): boolean;
// ���������� �����, ���������� true � ������ �����
var
  i: word;
  start_time: TDateTime;
  is_timeout: boolean;
begin
  result := false;
  com_receive := '';
  com.WriteStr(packet);
  start_time := Time;                           // ������� �����, ���� ���
  repeat
    Application.ProcessMessages;
    i := pos(packet, com_receive);
    is_timeout := (Time-start_time)*24*3600*1000 > timeout;
  until (i <> 0) or is_timeout;
  if is_timeout then                            // ���� ��� �� ������
    exit;                                           // ��������� ����� false
  delete(com_receive, 1, i+length(packet)-1);   // ������� ��� �� ������
  // ������� ������� ������������ �������
  start_time := Time;
  repeat
    Application.ProcessMessages;
    is_timeout := (Time-start_time)*24*3600*1000 > timeout;
  until (com_receive <> '') or is_timeout;
  if is_timeout then
    exit;
  if com_receive[1] = ack then
    result := true;    
end;

function Tfrm_main.send_command(comm: char; answer: char): boolean;
// �������� ���� ������, answer ���� ack, ���� nak.
// ���������� true � ������ ���������� answer � ���������� ������
var
  is_ack: boolean;
  is_nak: boolean;
  start_time: TDateTime;
  is_timeout: boolean;
begin
  com_receive := '';
  com.WriteStr(comm + #13);
  start_time := Time;
  repeat
    is_ack := pos(ack, com_receive) <> 0;
    is_nak := pos(nak, com_receive) <> 0;
    is_timeout := (Time-start_time)*24*3600*1000 > timeout;
    Application.ProcessMessages;
  until (is_ack or is_nak) or is_timeout;
  result := is_ack and (answer = ack);
  result := result or (is_nak and (answer = nak));
end;

procedure Tfrm_main.comRxChar(Sender: TObject; Count: Integer);
var
  buf: string;
begin
  com.ReadStr(buf, Count);
  com_receive := com_receive + buf;
end;   

procedure Tfrm_main.FormActivate(Sender: TObject);
// ����� �������������� ��������
// ����������� ���������� ������� � ����������� OnCreate!
var
  packet: TPacket;
  diff: single;
  d_progress: single;
begin
  // ���������� � ������
  com_receive := '';
  with pb_progress do
    Position := Min;
  try
    // �������������� �����
    packet := TPacket.create(filename);
    if packet.firmware_overload then            // �������� �� ����� ���������?
      raise Exception.Create('�������� ������ ���������');

    // ��������� ����, ���� �� ���������, �� ��������� ��������� �� ����������
    com.Open;
      com.WriteStr('boot' + #13);
      wait_ms(250);
    // ������ ������ �������� + ������� ������
    if not send_command(#123, ack) then
      raise Exception.Create('�� ������� ����� � ����� ��������');
    if not send_command(#125, nak) then
      raise Exception.Create('�� ������� ����� � ����� ��������');

    // ���� ������
    diff := (pb_progress.Max - pb_progress.Min) / packet.amount;
    d_progress := pb_progress.Min;
    while not packet.is_end do
    begin
      if not send_packet(packet.next) then
      begin
        com.WriteStr(packet.cancel + packet.cancel + packet.cancel);
        raise Exception.Create('�������� ������������� ������, ����������� ����������');
      end;
      d_progress := d_progress + diff;
      pb_progress.Position := round(d_progress);
      with pb_progress do
        lb_progress.Caption := FormatCurr('##', round(Position/(Max-Min)*100)) + '%';
    end;
    packet.free;
  except
    on e: Exception do
    begin
      ShowMessage(e.Message);
      try
        com.Close;
      except
        ShowMessage('���������� ������� com-����. ���������� ������ ����������');
      end;
      Application.Terminate;
    end;
  end;
  ShowMessage('���������������� ��������� �������');
  Application.Terminate;  
end;

function pos_ex(substr: string): byte;
var
  found: boolean;
begin
  result := 0;
  found := false;
  repeat
    inc(result);
    found := pos(substr, paramstr(result)) = 1;
  until (result = ParamCount) or found;
  if not found then
    result := 0;
end;

procedure Tfrm_main.FormCreate(Sender: TObject);
var
  i: byte;
begin
  // ����������� ���������� ��������� ������
  try
    if pos_ex('-dATMEGA32') = 0 then
      raise Exception.Create('�������������� ������ ATMega32');
    if pos_ex('-ms') = 0 then
      raise Exception.Create('�������������� ������ ���������������� ����� ����������������');
    if pos_ex('-pf') = 0 then
      raise Exception.Create('�������������� ������ ������ FLASH ������');
    i := pos_ex('-c');
    if pos_ex('-c') = 0 then
      raise Exception.Create('COM-���� �� �����')
    else begin
      com.Port := UpperCase(copy(ParamStr(i), 3, length(ParamStr(i))-2));
      lb_port.Caption := com.port + ', ' + inttostr(115200);
    end;
    i := pos_ex('-if');
    if i = 0 then
      raise Exception.Create('�� ����� ���� �������� ��� FLASH ������')
    else begin
      if not FileExists(copy(ParamStr(i), 4, length(paramstr(i))-3)) then
        raise Exception.Create('����  �������� �� ����������');
      filename := copy(ParamStr(i), 4, length(paramstr(i))-3);
    end;
  except
    on e: Exception do
    begin
      ShowMessage(e.Message);
      Halt;
    end;
  end;
end;

end.
