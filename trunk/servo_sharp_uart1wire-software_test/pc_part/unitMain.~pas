unit unitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, BCPort, XPMan, StdCtrls, Spin, ExtCtrls, ComCtrls;

type
  TfrmMain = class(TForm)
    XPManifest: TXPManifest;
    com: TBComPort;
    cb_com_baudrate: TComboBox;
    cb_com_port: TComboBox;
    gb_ComSettings: TGroupBox;
    btn_com_refresh: TButton;
    tmr: TTimer;
    btn_Author: TButton;
    btn_enable_control: TButton;
    tb_servo: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    lbl_servo: TLabel;
    ProgressBar1: TProgressBar;
    Label3: TLabel;
    lbl_distance: TLabel;
   procedure FormCreate(Sender: TObject);
    procedure cb_com_portChange(Sender: TObject);
    procedure cb_com_baudrateChange(Sender: TObject);
    procedure tmrTimer(Sender: TObject);
    procedure btn_com_refreshClick(Sender: TObject);
    procedure btn_AuthorClick(Sender: TObject);
    procedure comRxChar(Sender: TObject; Count: Integer);
    procedure btn_enable_controlClick(Sender: TObject);
    procedure tb_servoChange(Sender: TObject);
  private
    { Private declarations }
    function is_request(): boolean;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;
  com_can_send: boolean = false;
  com_receive: string;
  com_servo_to_send: string = '';

implementation

{$R *.dfm}
             
procedure TfrmMain.FormCreate(Sender: TObject);
begin
  EnumComPorts(cb_com_port.Items);
  with cb_com_port do
    ItemIndex := Items.IndexOf(com.Port);
  with cb_com_baudrate do
    ItemIndex := Items.IndexOf('115200');
  cb_com_baudrateChange(Sender);
  cb_com_portChange(Sender);
end;

procedure TfrmMain.cb_com_portChange(Sender: TObject);
begin
  try
    com.Port := cb_com_port.Text;
  except
    ShowMessage('Порт не установлен!');
  end;
end;

procedure TfrmMain.cb_com_baudrateChange(Sender: TObject);
begin
  try   // ломает чонить поумнее писать
    if cb_com_baudrate.Text = '9600' then com.BaudRate := br9600;
    if cb_com_baudrate.Text = '115200' then com.BaudRate := br115200;
  except
    showmessage('Скорость не установлена!');
  end;
end;
procedure TfrmMain.tmrTimer(Sender: TObject);
var
  s: string;  // строка для отправки
begin
  if com_can_send then
  begin
    if com_servo_to_send <> '' then
    begin
      com.WriteStr(com_servo_to_send + #13#10);
      com_servo_to_send := '';
      com_can_send := false;
    end;
  end;


  // начальная инициализация команды, пример:'S40 0D 02 04B0 05 05B0 P'+#13;
  {
  s := 'S40 0D ';
  for i := 0 to lb_tasks.Items.Count-1 do with tasks[i] do
    if (T >= time_from) and (T <= time_to) then
    begin
      if T = time_to then // при расчетах по промежуткам неизбежно накапливается
        x := pos_to       // ошибка, которую я устраняю на последнем шаге задачи
      else begin
        dx := (pos_to - pos_from) div ((time_to-time_from) div tmr.Interval);
        x := pos_from + ( (T - time_from) div (tmr.Interval) ) * dx;
      end;
      s := s + inttohex(servo,2) + ' ' + inttohex(x, 4) + ' ';
    end;
  // если есть что отправлять, то дополняю до команды и отправляю
  if s <> 'S40 0D ' then //
    com.WriteStr(s + 'P' + #13);
  // если все задачи кончились
  if T = T_max then
  begin
    tmr.Enabled := false;
    interface_en_dis();
    try
      com.Close
    except
      ShowMessage('Невожможно закрыть порт!');
      close()
    end;
  end;
  T := T + tmr.Interval;
  }
end;

procedure TfrmMain.btn_com_refreshClick(Sender: TObject);
begin
  EnumComPorts(cb_com_port.Items);
  cb_com_port.ItemIndex := 0;
end;

procedure TfrmMain.btn_AuthorClick(Sender: TObject);
begin
  ShowMessage('Автор: MiBBiM, специально для roboforum.ru');
end;

procedure TfrmMain.comRxChar(Sender: TObject; Count: Integer);
var
  buf: string;
begin
  com.ReadStr(buf, count);
  com_receive := com_receive + buf;   
  com_can_send := is_request();
end;

function TfrmMain.is_request(): boolean;
var
  i: byte;
begin
  i := pos(':>', com_receive);
  result := false;
  if i <> 0 then
  begin
    com_receive := '';
    result := true;
  end;
end;

{
function Tfrm_main.wait_for_request(time: byte = 25): boolean;
var
  i: byte;
begin
  result := true;
  i := 1;
  while pos(INT_ENTER, com_receive) = 0 do
  begin
    inc(i);
    sleep(10)
  end;
  if i >= time then
  begin
    ShowMessage('Интервал ожидания предложения ввода истек,' + #13#10 +
                'перезагрузите минибот');
    com.Close;
    result := false;
  end;
end;
}
procedure TfrmMain.btn_enable_controlClick(Sender: TObject);
begin
  if not com.Open then
  begin
    ShowMessage('Невозможно открыть порт!');
    exit;
  end;
  com_receive := '';
  com_servo_to_send := '';
  tmr.Enabled := true;
  com.WriteStr(#13#10);

  // интерфейс
  com_can_send := false;
  btn_com_refresh.Enabled := false;
  btn_Author.Enabled := false;
  btn_enable_control.Enabled := false;
  cb_com_baudrate.Enabled := false;
  cb_com_port.Enabled := false;
end;

procedure TfrmMain.tb_servoChange(Sender: TObject);
begin
  com_servo_to_send := 's1' + inttostr(tb_servo.Position);
  lbl_servo.Caption := inttostr(tb_servo.Position);
  label2.Caption := com_servo_to_send;
end;

end.
