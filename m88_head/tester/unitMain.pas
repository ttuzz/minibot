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
    btn_Author: TButton;
    btn_enable_control: TButton;
    pb_dist1: TProgressBar;
    pb_dist2: TProgressBar;
    pb_dist3: TProgressBar;
    pb_dist4: TProgressBar;
    pb_dist5: TProgressBar;
    btn_on: TButton;
    btn_off: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    mem_terminal: TMemo;
   procedure FormCreate(Sender: TObject);
    procedure cb_com_portChange(Sender: TObject);
    procedure cb_com_baudrateChange(Sender: TObject);
    procedure btn_com_refreshClick(Sender: TObject);
    procedure btn_AuthorClick(Sender: TObject);
    procedure comRxChar(Sender: TObject; Count: Integer);
    procedure btn_enable_controlClick(Sender: TObject);
    procedure btn_onClick(Sender: TObject);
    procedure btn_offClick(Sender: TObject);
    procedure mem_terminalKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    procedure distance_parse(s: string);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;
  com_receive: string;

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
  s: string;
  i: word;
begin
  com.ReadStr(buf, count);
  com_receive := com_receive + buf;
  i := pos(#13#10, com_receive);
  if i <> 0 then
  begin
    s := copy(com_receive, 1, i-1);
    distance_parse(s);
    mem_terminal.Lines.Append(s);
    delete(com_receive, 1, i+1);
  end;
end;

procedure TfrmMain.distance_parse(s: string);
var
  angle: byte;
  value: word;
  i: byte;
begin
  i := pos('-', s);
  if i = 2 then
    try
      angle := strtoint(copy(s,1,1));
      value := strtoint(copy(s,3,length(s)-2));
    except
      exit;
    end;
  if (angle < 1) or (angle > 5) then exit;
  if (value < 1) or (value > 150) then exit;
  case angle of
  1:
  begin
    pb_dist1.Position := value;
    label1.Caption := inttostr(value);
  end;
  2:
  begin
    pb_dist2.Position := value;
    label2.Caption := inttostr(value);
  end;
  3:
  begin
    pb_dist3.Position := value;
    label3.Caption := inttostr(value);
  end;
  4:
  begin
    pb_dist4.Position := value;
    label4.Caption := inttostr(value);
  end;
  5:
  begin
    pb_dist5.Position := value;
    label5.Caption := inttostr(value);
  end;
  end;
end;


procedure TfrmMain.btn_enable_controlClick(Sender: TObject);
begin
  if not com.Open then
  begin
    ShowMessage('Невозможно открыть порт!');
    exit;
  end;
  com_receive := '';

  // интерфейс
  btn_com_refresh.Enabled := false;
  btn_Author.Enabled := false;
  btn_enable_control.Enabled := false;
  cb_com_baudrate.Enabled := false;
  cb_com_port.Enabled := false;
end;

procedure TfrmMain.btn_onClick(Sender: TObject);
begin
  if com.Connected then
    com.WriteStr('on'+#13#10);
end;

procedure TfrmMain.btn_offClick(Sender: TObject);
begin
  if com.Connected then
    com.WriteStr('off'+#13#10);
end;

procedure TfrmMain.mem_terminalKeyPress(Sender: TObject; var Key: Char);
begin
  if key = chr(vk_return) then
  begin
    mem_terminal.Clear;
    key := #0;
  end;
end;

end.
