unit UnitServer;

interface

type TCommand = (comm_auth, comm_request, comm_send, comm_wrong);

type
  TReciever = class(TObject)
  {  to_log: string;
    to_send: string;   }
    function parse(line: string; ip: string): string;             // ������������ �������� ������
  private
    function find_comm(line: string): TCommand;                   // ���� ������� � ������
    function do_comm_auth(line: string): string;                  // ������������ ������ ��������������
    function do_command_request(line: string): string;            // ������������ ������ ������
    function do_command_send(line: string): string;               // ������������ ����(�������� �� ������� �������) ������
    function do_command_wrong(): string;                          // ������������ �������� �������
    function verify_id(line: string; comm: TCommand): boolean;    // ��������� �������� session_id ������������������� �������
    function get_id(line: string; comm: TCommand): string;        // �������� session_id �� ������
end;

type
  TClient = record
    session_id: string;
    pass: string;
end;

const
    // �������� ������
  auth    = '#AUTH';
  request = '#REQUEST';
  send    = '#SEND';
  valid   = '#VALID';
  invalid = '#INVALID';
var
  reciever: TReciever;
  client: TClient;
  to_log: string;
  to_send: string;
implementation

uses Classes;
  {
var
  to_log: string;
  to_send: string;
 }

function TReciever.parse(line: string; ip: string): string;
// ��������� ��������� ������
var
  comm: TCommand;
begin
  to_log := ip + ': ';
  
  comm := find_comm(line);
  case comm of
    comm_auth:    line := do_comm_auth(line);
    comm_request: line := do_command_request(line);
    comm_send:    line := do_command_send(line);
    comm_wrong:   line := do_command_wrong;
  end;

  result := line;  
end;

function TReciever.find_comm(line: string): TCommand;
// ���������, ���� �� ���� ���� ������� � ������
  function ch_c(source, comm: string): boolean; // �������� ��������
  begin
    try
      result := copy(source, 1, length(comm)) = comm;
    except
      result := false;
    end;
  end;
begin
  result := comm_wrong;
  if ch_c(line, auth)     then result := comm_auth;
  if ch_c(line, request)  then result := comm_request;
  if ch_c(line, send)     then result := comm_send;
end;
  
function TReciever.do_comm_auth(line: string): string;
var
  buf: string;
begin
  result := valid;
  to_log := to_log + '������ �������������� ';
  // �������� ������
  buf := copy(line, length(line)-length(client.pass)+1,
  length(client.pass));
  if buf <> client.pass then result := invalid;
  // �������� session_id
  buf := get_id(line, comm_auth);
  if buf = '' then result := invalid;
  // ���� ������ ��� ��������, �� ����������� �������
  if result = valid then
  begin
    client.session_id := buf;
    to_log := to_log + '- �������';
  end else
    to_log := to_log + '- ���������';
end;

function TReciever.do_command_request(line: string): string;
begin
  if not verify_id(line, comm_request) then
  begin
    to_log := to_log + '������������������ ������ ������';
    result := invalid;
    exit;
  end;
  result := valid + ':' + to_send;  // ������ ������
  to_send := '';                    // ������ �����
  to_log := '';                     // � ��� ������ �� ���� ��������
end;

function TReciever.do_command_send(line: string): string;
begin
//
end;

function TReciever.do_command_wrong: string;
begin
  result := invalid;
  to_log := to_log + '�������� ������';
end;

function TReciever.verify_id(line: string; comm: TCommand): boolean;
begin
  result := get_id(line, comm) = client.session_id;
end;

function TReciever.get_id(line: string; comm: TCommand): string;
// �������� session_id �� �������� ������ (�.�. ������, � ������� ���� �������)
const
  SESSION_ID_LENGTH = 32;
var
  buf: string;
begin
  case comm of        // comm_wrong �� �����������!!
    comm_auth:    buf := auth;
    comm_request: buf := request;
    comm_send:    buf := send;
  end;
  // �������� session_id
  try
    result := copy(line, length(buf)+2, SESSION_ID_LENGTH);
  except
    result := '';
  end;
end;

end.
