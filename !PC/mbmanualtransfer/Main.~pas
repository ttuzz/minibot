unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XPMan, StdCtrls, CheckLst, BCPort,
  //base64_procs  {процедуры для base64},
  //crc,
  ///crc16_procs   {процедуры для crc16},
  //uue_procs     {процедуры для uue},
  terminal_stuff {процедуры для UUE, crc8};

type
  TComm = (
  _soh = $01,     // start of ttransmission
  _eop = $17,     // end of packet
  _eot = $04,     // end of transmission
  _c = $43,       // ASCII 'C'
  _ack = $06,     // acknowledge
  _nack = $15,    // not acknowledge
  _can = $18      // cancel transmit
  );

type
  TData = array of byte;

type
  Tfrm_main = class(TForm)
    XPManifest: TXPManifest;
    gb_com_settings: TGroupBox;
    cb_com_port: TComboBox;
    cb_com_baudrate: TComboBox;
    btn_com_refresh: TButton;
    btn_Author: TButton;
    com: TBComPort;
    btn_recieve_file: TButton;
    m: TMemo;
    btn_ack: TButton;
    btn_nack: TButton;
    btn_C: TButton;
    Button4: TButton;
    btn_open: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Button1: TButton;
    procedure btn_AuthorClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure cb_com_baudrateChange(Sender: TObject);
    procedure cb_com_portChange(Sender: TObject);
    procedure btn_com_refreshClick(Sender: TObject);
    procedure comRxChar(Sender: TObject; Count: Integer);
    function wait_for_request(time: byte = 25): boolean;
    procedure btn_recieve_fileClick(Sender: TObject);
    procedure btn_openClick(Sender: TObject);
    procedure command_transmit(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
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

  // константы, возвращаемые функциями
  RESULT_NOTHING : string = '#NOTHING';

var
  frm_main: Tfrm_main;
  com_receive: string;
  packet_number: byte = 1;

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
    ItemIndex := Items.IndexOf('9600');
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

function get_packet(var inp: string): string;
// извлекает пакет из входной строки
var
  packet_begin, packet_end: word;
begin
  packet_begin := pos(chr(ord(_soh)), inp);   // ищу начало пакета
  if packet_begin = 0 then
  begin
    result := RESULT_NOTHING;
    exit;
  end;
  packet_end := pos(chr(ord(_eop)), inp);     // ищу конец пакета
  if (packet_end = 0) or (packet_end-packet_begin < 3) then // если номер приравнялся к символу конца пакета
  begin
    result := RESULT_NOTHING;
    exit;
  end;

  result := copy(inp, packet_begin, packet_end-packet_begin+1);
  delete(inp, packet_begin, packet_end-packet_begin+1);
end;

function parse_packet(packet: string; expected_packet_number: byte; var data: TData): boolean;
// извлекает данные из пакета-строки packet
// и ожидаемым номером expected_packet_number
// возвращаемое значение - правильность пакета
// !!!не проверяет символы начала-конца пакета!!!
var
  buf: string;
  len: word;
  crc8: word;
  i: word;
begin
  result := false;
  setlength(data, 0);
  len := length(packet);
  if ord(packet[2]) + ord(packet[3]) <> $FF then       // корректность номера
    exit;
  if ord(packet[2]) <> expected_packet_number then    // нужный пакет?
    exit;
  // проверки пройдены, извлекаю base64 представление данных
  buf := copy(packet, 4, len-5);
  //buf := DecodeBase64(buf);
  buf := Decode_UUE(buf);
  // считаю crc16 данных
  crc8 := calc_crc8(buf);
  // проверяю crc16

  if crc8 <> ord(packet[len-1]) then
    exit;
  // пакет верен, вывожу данные
  result := true;
  len := length(buf);
  setlength(data, len);
  for i := 0 to len-1 do
    data[i] := ord(buf[i+1]);
end;

function transform_packet(packet: string): string;
begin
  result := '_soh';
  delete(packet, 1, 1);
  result := result + '_' + inttostr(ord(packet[1])) + '_' + inttostr(ord(packet[2]))+'_''';
  delete(packet, 1, 2);
  result := result + copy(packet, 1, length(packet)-2) +'''_'+ IntToHex(ord(packet[length(packet)-1]), 2) + '_eop';
end;

procedure Tfrm_main.comRxChar(Sender: TObject; Count: Integer);
var
  buf: string;
  data: TData;
  i: word;
begin
  com.ReadStr(buf, count);
  com_receive := com_receive + buf;

  // извлечение целых пакетов
  buf := get_packet(com_receive);
  if buf <> RESULT_NOTHING then
  begin
    m.Lines.Append('Packet is: ''' + transform_packet(buf) + '''; length:' + inttostr(length(buf)));
    if not parse_packet(buf, packet_number, data) then
      m.Lines.Append('not parsed')
    else begin
      buf := '';
      for i := 0 to high(data) do
        buf := buf + IntToHex(data[i], 2);
      m.Lines.Append('--data is: ''' + buf + '''');
      inc(packet_number);
    end;
  end;
  //m.Lines.Text := com_receive;
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

procedure Tfrm_main.btn_openClick(Sender: TObject);
begin
  if not com.Connected then
  begin
    if not com.Open then
      ShowMessage('не могу открыть порт');
  end else
    if not com.Close then
      ShowMessage('не могу закрыть порт');
  if com.Connected then
    btn_open.Caption := 'conn'
  else
    btn_open.Caption := 'disconn';
  com_receive := '';
end;

procedure Tfrm_main.command_transmit(Sender: TObject);
var
  b_out: char;
begin
  if (Sender as TButton).Name = 'btn_ack' then
    b_out := chr(ord(_ack));
  if (Sender as TButton).Name = 'btn_nack' then
  begin
    b_out := chr(ord(_nack));
    dec(packet_number);
  end;
  if (Sender as TButton).Name = 'btn_C' then
    b_out := chr(ord('C'));
    
  if com.Connected then
    com.Write(b_out, 1);
end;

procedure Tfrm_main.Button4Click(Sender: TObject);
var
  s: string;
  buf: string;
  i: byte;
  data: TData;
begin
{  buf :=  EncodeBase64('ЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄ');
  buf := 'qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq';
  m.Lines.Append( buf );
  m.Lines.Append(DecodeBase64(buf));

  m.Lines.Append(chr($AA));
  s := '';
  for i := 1 to 32 do
    s := s + 'q';
  s := EncodeBase64(s);
  buf := '';
  for i := 1 to 32 do
    buf := buf + IntToHex(ord(s[i]),2);
  m.Lines.Append(buf);

 setlength(s, 128);
  for i := 1 to 127 do
    s[i] := chr($AA);
  s[128] := chr($ED);

  lb_files.Items.Append('CRC is: ' + IntToHex(CalculateCrc16XModem(s[1], 128), 4));
}
//'CAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'#$D#$A'symbol AA is: 'Є''#$D#$A'string is: 'ЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄЄ''#$D#$A#$D#$A'base64: 'qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq''#$D#$A#1#1'юqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq‚H'#$17
  buf := com_receive;
  s := get_packet(buf);
  m.Lines.Append(s);
  if s <> RESULT_NOTHING then
    if not parse_packet(s, 1, data) then
      label1.Caption := 'false'
    else
      label1.Caption := 'true';
  buf := '';
  for i := 0 to high(data) do
    buf := buf + chr(data[i]);
  m.Lines.Append(buf);

  
end;

procedure Tfrm_main.Button1Click(Sender: TObject);
var
  p: string;
  s: string;
  i: byte;
  sub: string;
  crc16: word;
begin
{  p := chr(ord(_soh)) + chr(1) + chr(254);
  s := 'So, it works';
  crc16 := CalculateCrc16XModem(s[1], length(s));
  sub := EncodeBase64(s);

  p := p + sub + chr(hi(crc16)) + chr(lo(crc16)) + chr(ord(_eop));
  com_receive := p;}
  {
  p := 'ABCs';
  p := DecodeBase64(p);
  s := EncodeBase64(p);
  edit1.Text := s;
  //DecodeBase64(chr(crc16));
  }

  p := Encode_UUE('CatCat');
  s := test_Encode_UUE('CatCat');
  edit1.Text := p;
  //edit1.Text := s;
  
  setlength(p, 10);
  //#1#1'юJJ: JJJJJJJJJJJJJJJJJJJJJJJJMKJJБ'#$17
  // 'JJJ JJJJJJJJJJJJJJJJJJJJJJJJMKJJ'
  {
  setlength(p, 24);
  for i := 2 to 23 do
    p[i] := chr($AA);
  p[1] := chr($01);
  p[24] := chr($ED);

  edit1.Text := Encode_UUE(p);
  label1.Caption := inttohex(calc_crc8(p), 2);
   }
  
  //GenerateCRC8Tablereverse(CRC8_MY);
  //CalculateCrc8Reverse(p[1], length(p), 0)

  //edit1.Text := inttohex(  calc_crc8(p), 2);
  //edit1.Text := inttohex(  CalculateCrc8reverse(p[1], length(p), 0), 2);
  
  //edit1.Text := DecodeBase64(EncodeBase64('1'));
end;

end.
