unit crc16_procs;
{******************************************************************************}
{*  Модуль для подсчета CRC16                                                 *}
{*  Основан на коде crc.pas Дмитрия Муратова (dvmuratov@yandex.ru)            *}
{******************************************************************************}


interface

{
Имя алгоритма               : XMODEM-CRC
Стандарты                   : ITU-T V.41
Где используется            : XMODEM-CRC, PPP
Иннициализирующее значение  : $0000
Выходная XOR маска          : $0000
Входные данные              : не инвертируются
Выходной CRC перед XOR      : не инвертируется
Значение полинома           : $1021 (Зеркальное значение = $8408)
Полином                     : x^16 + x^15 + x^2 + 1
Значение для '123456789'    : $31C3
}

const
  CRC16_XMODEM_POLYNOM       = $1021;
type
  TCRC16Table = array[Byte] of Word;
var
  CRC16Table: TCRC16Table;
  
procedure GenerateCRC16TableXModem;
function CalculateCrc16XModem(const Data; const DataLen: Cardinal): WORD;

implementation

procedure GenerateCRC16TableXModem;
var
  i, j: integer;
begin
  for i := 0 to 255 do
    begin
      CRC16Table[i] := i shl 8;
      for j := 0 to 7 do
        begin
          if (CRC16Table[i] and $8000) <> 0 then
            CRC16Table[i]:=(CRC16Table[i] shl 1) xor CRC16_XMODEM_POLYNOM
          else
            CRC16Table[i] := CRC16Table[i] shl 1;
        end;
      CRC16Table[i] := CRC16Table[i] and $ffff;
    end;
end;

function CalculateCrc16XModem(const Data; const DataLen: Cardinal): WORD;
var
  i: integer;
  PData: ^Byte;
begin
  Result := 0;
  PData := @Data;
  for i := 1 to DataLen do
    begin
      Result := (Result shl 8) xor CRC16Table[PData^ xor (Result shr 8) and $ff];
      inc(PData);
    end;
  Result := Result and $ffff;
end;

initialization
  GenerateCRC16TableXModem;
end.
