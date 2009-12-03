unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XPMan, StdCtrls, CheckLst, BCPort,
  base64_procs{процедуры для base64},
  crc16_procs{процедуры для crc16};

type
  comm = (_soh = $01, _eop = $17, _eot = $04, _ack = $06, _nack = $15);

type
  packet = record
    soh: byte;
    number1: byte;                                                          
    number2: byte;
    data: array[1..128] of byte;
    crc1: byte;
    crc2: byte;
  end;


type
  Tfrm_main = class(TForm)
    XPManifest: TXPManifest;
    gb_files: TGroupBox;
    gb_tools: TGroupBox;
    lb_files: TListBox;
    gb_com_settings: TGroupBox;
    cb_com_port: TComboBox;
    cb_com_baudrate: TComboBox;
    btn_com_refresh: TButton;
    btn_Author: TButton;
    com: TBComPort;
    dlg_save: TSaveDialog;
    dlg_open: TOpenDialog;
    btn_recieve_file: TButton;
    btn_refresh_files: TButton;
    procedure btn_AuthorClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure cb_com_baudrateChange(Sender: TObject);
    procedure cb_com_portChange(Sender: TObject);
    procedure btn_com_refreshClick(Sender: TObject);
    procedure comRxChar(Sender: TObject; Count: Integer);
    function wait_for_request(time: byte = 25): boolean;
    procedure btn_recieve_fileClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  // константы интерфейса обмена
  INT_PREFIX: string = ':';   // начало передачи
  INT_ENTER: string = '>';    // предложение ввода
  INT_POSTFIX: string = '::'; // конец передачи
  INT_CR: string = #13#10;

  // константы доступных комманд
  COMM_FILESYSTEM_ACTIVATE: string = 'fs 0';
  COMM_GET_FILE_LIST: string = 'dir';

var
  frm_main: Tfrm_main;
  com_receive: string;

implementation

{$R *.dfm}

procedure Tfrm_main.btn_AuthorClick(Sender: TObject);
begin
  ShowMessage('Автор: MiBBiM, специально для minibot.ru при участии roboforum.ru');
end;

procedure Tfrm_main.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not com.Connected;
  if not CanClose then
    showmessage('Идет отправка, подождите.');
end;

procedure Tfrm_main.FormCreate(Sender: TObject);
begin
  EnumComPorts(cb_com_port.Items);
  with cb_com_port do
    ItemIndex := Items.IndexOf(com.Port);
  with cb_com_baudrate do
    ItemIndex := Items.IndexOf('115200');
  cb_com_baudrateChange(Sender);
  cb_com_portChange(Sender);
end;

procedure Tfrm_main.cb_com_baudrateChange(Sender: TObject);
begin
  try   // ломает чонить поумнее писать
    if cb_com_baudrate.Text = '9600' then com.BaudRate := br9600;
    if cb_com_baudrate.Text = '115200' then com.BaudRate := br115200;
  except
    showmessage('Скорость не установлена!');
  end;
end;

procedure Tfrm_main.cb_com_portChange(Sender: TObject);
begin
  try
    com.Port := cb_com_port.Text;
  except
    ShowMessage('Порт не установлен!');
  end;
end;

procedure Tfrm_main.btn_com_refreshClick(Sender: TObject);
begin
  EnumComPorts(cb_com_port.Items);
  cb_com_port.ItemIndex := 0;
end;


procedure Tfrm_main.comRxChar(Sender: TObject; Count: Integer);
var
  buf: string;
begin
  com.ReadStr(buf, count);
  com_receive := com_receive + buf;
end;

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

procedure Tfrm_main.btn_recieve_fileClick(Sender: TObject);
var
  s: string;
  i: byte;
begin
  //if myred = comm(255) then
   // lb_files.Items.Append(inttostr(ord(myred)));
{  // открываю ком порт
  if not com.Open then
  begin
    ShowMessage('Невозможно открыть порт!');
    exit;
  end;
  com_receive := '';

  //}
  {
  setlength(s, 128);
  for i := 1 to 127 do
    s[i] := chr($AA);
  s[128] := chr($ED);

  lb_files.Items.Append('CRC is: ' + IntToHex(CalculateCrc16XModem(s[1], 128), 4));
  }
end;

end.
          {

procedure TfrmMain.btn_tasks_saveClick(Sender: TObject);
var
  dir: string;
begin
  // проверяю, а есть ли чего сохранять
  if lb_tasks.Count = 0 then
  begin
    ShowMessage('Нечего сохранять!');
    exit;
  end;
  dir := Application.ExeName;
  delete(dir, LastDelimiter('\', dir)+1, length(dir)-LastDelimiter('\', dir));
  dlg_save.InitialDir := dir;
  if dlg_save.Execute then
  begin
    dir := dlg_save.FileName;
    if FileExists(dir) then
      if mrCancel = MessageDlg('Файл существует. Перезаписать?',
        mtConfirmation,[mbOk, mbCancel], 0) then
          exit;
    if copy(dir, length(dir)-2, 3) <> 'ors' then
      dir := dir + '.ors';
    tasks_save(dir);
  end;
end;

procedure TfrmMain.btn_tasks_loadClick(Sender: TObject);
var
  dir: string;
begin
  dir := Application.ExeName;
  delete(dir, LastDelimiter('\', dir)+1, length(dir)-LastDelimiter('\', dir));
  dlg_open.InitialDir := dir;
  if dlg_open.Execute then
  begin
    dir := dlg_open.FileName;
    if not FileExists(dir) then
    begin
      ShowMessage('Такого файла не существует!');
      exit;
    end;
    tasks_load(dir);
  end;
end;        }
