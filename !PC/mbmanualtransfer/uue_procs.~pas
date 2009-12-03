unit uue_procs;

interface

function test_Encode_UUE(value: string): string;
function Encode_UUE(value: string): string;
function Decode_UUE(value: string): string;

implementation

function test_Encode_UUE(value: string): string;
  function convert(buf: cardinal): string;
  var
    k, b: byte;
  begin
    result := '';
    for k := 1 to 4 do
    begin
      b := buf;
      b := (b and 63) + 32;
      result := result + chr(b);
      buf := buf shr 6;      
    end;
  end;
var
  len: word;
  amount: word;
  modul: byte;
  buf: cardinal;
  i: word;
  index: word;
begin
  len := length(value);
  amount := len div 3;
  modul := len mod 3;
  result := '';

  for i := 0 to amount-1 do
  begin
    buf := ord(value[i*3+1]) shl 8;
    buf := (buf + ord(value[i*3+2])) shl 8;
    buf := buf + ord(value[i*3+3]);
    result := result + convert(buf);
  end;

  case modul of
    1: buf := ord(value[len]) shl 16;
    2: buf := (ord(value[len]) shl 16) + (ord(value[len-1]) shl 8);
    0: exit;
  end;
  result := result + convert(buf);
end;

function Encode_UUE(value: string): string;
  function convert(buf: cardinal): string;
  begin
    result :=          chr((buf and (63 shl 18)) shr 18 + 32);
    result := result + chr((buf and (63 shl 12)) shr 12 + 32);
    result := result + chr((buf and (63 shl  6)) shr  6 + 32);
    result := result + chr(buf and 63 + 32);
  end;
var
  len: word;
  amount: word;
  modul: byte;
  buf: cardinal;
  i: word;
begin
  len := length(value);
  amount := len div 3;
  modul := len mod 3;
  result := '';

  for i := 0 to amount-1 do
  begin
    buf := (ord(value[3*i+1]) shl 16) + (ord(value[3*i+2]) shl 8)
           + ord(value[3*i+3]);
    result := result + convert(buf);
  end;

  case modul of
    1: buf := ord(value[len]) shl 16;
    2: buf := (ord(value[len]) shl 16) + (ord(value[len-1]) shl 8);
    0: exit;
  end;
  result := result + convert(buf);
end;

function Decode_UUE(value: string): string;
  function deconvert(value: string): string;
  var
    buf: cardinal;
  begin
    buf :=       (ord(value[1])-32) shl 18;
    buf := buf + (ord(value[2])-32) shl 12;
    buf := buf + (ord(value[3])-32) shl  6;
    buf := buf + (ord(value[4])-32);
    setlength(result,3);
    result[1] := chr( (buf and $00FF0000) shr 16 );
    result[2] := chr( (buf and $0000FF00) shr  8 );
    result[3] := chr( (buf and $000000FF) );
  end;
var
  len: word;
  amount: word;
  modul: byte;
  buf: string;
  i: word;
begin
  len := length(value);
  amount := len div 4;
  for i := 0 to amount-1 do
  begin
    buf := copy(value, i*4+1, 4);
    result := result + deconvert(buf);
  end;
end;

end.
