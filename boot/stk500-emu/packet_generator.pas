unit packet_generator;

interface
  uses Classes, SysUtils;

  type TData = array of byte;
  type TPacket = class(TObject)
    constructor create(source: string);
    destructor free;
  private
    firmware: TMemoryStream;
    _is_end: boolean;
    number: byte;
    
    function convert_one_string(s: string): TData;
    procedure convert_hex(source: string; var dest: TMemoryStream);
  public
    function next: string;
    function cancel: string;
    function is_end: boolean;
    function amount: word;              // �� ������������ ��� ������! ������ � �������� ����������!
    function firmware_overload: boolean;
  end;
implementation

function TPacket.convert_one_string(s: string): TData;
// ������ ������ intel hex �����
// �������� ��� ������, ����������� ������� �� ������������
var
  len: array of byte;
  s_len: string;
  i: byte;
begin
  delete(s, 1, 1);
  setlength(result,0);
  setlength(len,1);
  s_len := copy(s,1,2);
  if s_len = '00' then          // ��������� ������, ��� ������
    exit;
  delete(s,1,8);
  HexToBin(pchar(s_len), pchar(len), 1);
  setlength(result,16);
  HexToBin(pchar(s), pchar(result), len[0]);
  for i := len[0] to 15 do             // ��������� 0xFF ���� ����������
    result[i] := $FF;
end;

procedure TPacket.convert_hex(source: string; var dest: TMemoryStream);
// ��������� ������ ������ � ���� dest
// ������� ������ �� ������� k*128, �������� � ����� 0xFF
// ����� ��� ������� ���������
var
  finp: TStringList;
  data: TData;
  i: word;
  k: byte;
begin
  finp := TStringList.Create;
  finp.LoadFromFile(source);            // ��������� ������ �����
  dest := TMemoryStream.Create;         // ��������
  for i := 0 to finp.Count-1 do
  begin
    data := convert_one_string(finp[i]);      // ���������� ��������� ������
    if length(data) <> 0 then                 // �������� � �������� ����
      for k := 0 to high(data) do
        dest.WriteBuffer(data[k], 1);
  end;
  i := $FF;
  while dest.Size mod 128 <> 0 do      // ��������� 0xFF � ����� �����
    dest.WriteBuffer(i, 1);
  dest.Position := 0;
  setlength(data,0);
end;

constructor TPacket.create(source: string);
begin
  convert_hex(source, firmware);
  _is_end := false;
  number := 1;
  //firmware.SaveToFile('c:\123123');
end;

destructor TPacket.free;
begin
  firmware.Free;
end;

function TPacket.next: string;
// ���������� ��������� �����
var
  csum: byte;
  i: byte;
begin
  if firmware.position <> firmware.size then
  begin
    result := #1;                         // ��������� �����
    result := result + chr(number);       // ����� ������
    result := result + chr(number+1);     // ������ ���� ��������
                                          // ������
    setlength(result, length(result)+128);
    csum := 2*(number + 1);
    for i := 1+3 to 128+3 do              // ����� �� ���������
    begin
      firmware.ReadBuffer(result[i], 1);
      inc(csum, ord(result[i]));
    end;
    result := result + chr(csum);         // ������ ���� ��������
    result := result + #13;
    inc(number);
  end else begin                          // ��������� ����� ����������
    result := #4 + #13;
    _is_end := true;
  end;
end;

function TPacket.is_end: boolean;
begin
  result := _is_end;
end;

function TPacket.cancel: string;
// ���������� ����-�����
begin
  result := #$18 + #13;
end;

function TPacket.firmware_overload: boolean;
begin
  result := firmware.Size > $3BFF;       // 0x3BFF ��� 15359
end;

function TPacket.amount: word;
begin
  result := (firmware.Size div 128) + 1; // +1 ��������� ����� ��������
end;

end.
