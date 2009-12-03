unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, XPMan, crc16_procs{процедуры для crc16};

type
  Tf = class(TForm)
    m: TMemo;
    XPManifest1: TXPManifest;
    b: TButton;
    Button1: TButton;
    procedure bClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  f: Tf;

implementation

{$R *.dfm}

procedure Tf.bClick(Sender: TObject);
var
  sout: string;
  i: word;
  b: byte;
  v: byte;
  c: byte;
begin
  with m.Lines do for i := 0 to Count-1 do
  begin
    b := pos(#9, Strings[i]);
    if b = 0 then continue;
    //const name = var
    sout := 'Const ';
    v := strtoint(copy(Strings[i], 1, b-2));
    inc(b);
    c := b;
    while strings[i][c] <> #9 do
      inc(c);
    sout := sout + copy(Strings[i], b, c-b) + ' = ' + inttostr(v);
    sout := sout + ' ''' + copy(strings[i], c+1, length(strings[i])-c);
    Strings[i] := sout;   
  end;
end;

function StringToHex(S: String): String;
var I: Integer;
begin
  Result:= '';
  for I := 1 to length (S) do
    Result:= Result+IntToHex(ord(S[i]),2);
end;

procedure Tf.Button1Click(Sender: TObject);
var
  s: string;
  substr: string;
  i,k: byte;
  crc: word;
begin
  s :='0101FEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'+
  'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'+
  'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'+
  'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAED8EED';
  m.Lines[0] := copy(s, 1,2);
  m.Lines.Append(copy(s, 3,4));
  m.Lines.Append(copy(s, 7, 256));
  m.Lines.Append(copy(s, 263, 4));
  m.Lines.Append('');
  {
  s := copy(s, 7, 256);

  for i := 0 to 127 do
    m.Lines.Append('Packet(' + inttostr(i+1) + ') = &H' + copy(s, 1+i*2, 2));
  
  for i := 0 to 127 do
    m.Lines.Append('s[' + inttostr(i+1) + '] := chr($' + copy(s, 1+i*2, 2) + ');');}
  setlength(s, 128);

s[1] := chr($AA);
s[2] := chr($AA);
s[3] := chr($AA);
s[4] := chr($AA);
s[5] := chr($AA);
s[6] := chr($AA);
s[7] := chr($AA);
s[8] := chr($AA);
s[9] := chr($AA);
s[10] := chr($AA);
s[11] := chr($AA);
s[12] := chr($AA);
s[13] := chr($AA);
s[14] := chr($AA);
s[15] := chr($AA);
s[16] := chr($AA);
s[17] := chr($AA);
s[18] := chr($AA);
s[19] := chr($AA);
s[20] := chr($AA);
s[21] := chr($AA);
s[22] := chr($AA);
s[23] := chr($AA);
s[24] := chr($AA);
s[25] := chr($AA);
s[26] := chr($AA);
s[27] := chr($AA);
s[28] := chr($AA);
s[29] := chr($AA);
s[30] := chr($AA);
s[31] := chr($AA);
s[32] := chr($AA);
s[33] := chr($AA);
s[34] := chr($AA);
s[35] := chr($AA);
s[36] := chr($AA);
s[37] := chr($AA);
s[38] := chr($AA);
s[39] := chr($AA);
s[40] := chr($AA);
s[41] := chr($AA);
s[42] := chr($AA);
s[43] := chr($AA);
s[44] := chr($AA);
s[45] := chr($AA);
s[46] := chr($AA);
s[47] := chr($AA);
s[48] := chr($AA);
s[49] := chr($AA);
s[50] := chr($AA);
s[51] := chr($AA);
s[52] := chr($AA);
s[53] := chr($AA);
s[54] := chr($AA);
s[55] := chr($AA);
s[56] := chr($AA);
s[57] := chr($AA);
s[58] := chr($AA);
s[59] := chr($AA);
s[60] := chr($AA);
s[61] := chr($AA);
s[62] := chr($AA);
s[63] := chr($AA);
s[64] := chr($AA);
s[65] := chr($AA);
s[66] := chr($AA);
s[67] := chr($AA);
s[68] := chr($AA);
s[69] := chr($AA);
s[70] := chr($AA);
s[71] := chr($AA);
s[72] := chr($AA);
s[73] := chr($AA);
s[74] := chr($AA);
s[75] := chr($AA);
s[76] := chr($AA);
s[77] := chr($AA);
s[78] := chr($AA);
s[79] := chr($AA);
s[80] := chr($AA);
s[81] := chr($AA);
s[82] := chr($AA);
s[83] := chr($AA);
s[84] := chr($AA);
s[85] := chr($AA);
s[86] := chr($AA);
s[87] := chr($AA);
s[88] := chr($AA);
s[89] := chr($AA);
s[90] := chr($AA);
s[91] := chr($AA);
s[92] := chr($AA);
s[93] := chr($AA);
s[94] := chr($AA);
s[95] := chr($AA);
s[96] := chr($AA);
s[97] := chr($AA);
s[98] := chr($AA);
s[99] := chr($AA);
s[100] := chr($AA);
s[101] := chr($AA);
s[102] := chr($AA);
s[103] := chr($AA);
s[104] := chr($AA);
s[105] := chr($AA);
s[106] := chr($AA);
s[107] := chr($AA);
s[108] := chr($AA);
s[109] := chr($AA);
s[110] := chr($AA);
s[111] := chr($AA);
s[112] := chr($AA);
s[113] := chr($AA);
s[114] := chr($AA);
s[115] := chr($AA);
s[116] := chr($AA);
s[117] := chr($AA);
s[118] := chr($AA);
s[119] := chr($AA);
s[120] := chr($AA);
s[121] := chr($AA);
s[122] := chr($AA);
s[123] := chr($AA);
s[124] := chr($AA);
s[125] := chr($AA);
s[126] := chr($AA);
s[127] := chr($AA);
s[128] := chr($ED); 

  //GenerateCRC16TableXModem;
  crc := CalculateCrc16XModem(s[1], 128);
  m.Lines.Append('CRC is: ' + IntToHex(crc, 4));
end;

end.
