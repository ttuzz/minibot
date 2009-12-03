{******************************************************************************}
{*                                                                            *}
{*  Модуль для подсчета некоторых распространенных вариантов CRC8/16/32/64    *}
{*  (с) 2008 Дмитрий Муратов (dvmuratov@yandex.ru)                            *}
{*  Версия 1.0  06/01/2008                                                    *}
{*                                                                            *}
{******************************************************************************}

unit CRC;

interface

uses Windows, sysutils;

const

////////////////////////////////////////////////////////////////////////////////
//                                 CRC8                                       //
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//  Имя алгоритма               : CRC8-SMBUS                                  //
//  Стандарты                   : ATM HEC, SMBUS                              //
//  Где используется            : ATM HEC, SMBUS                              //
//  Иннициализирующее значение  : $00                                         //
//  Выходная XOR маска          : $00                                         //
//  Входные данные              : не инвертируются                            //
//  Выходной CRC перед XOR      : не инвертируются                            //
//  Значение полинома           : $07 (Зеркальное значение = $E0)             //
//  Полином                     : x^8 + x^2 + x + 1                           //
//  Значение для '123456789'    : $F4                                         //
////////////////////////////////////////////////////////////////////////////////

  CRC8_SMBUS_POLYNOM           = $07;

////////////////////////////////////////////////////////////////////////////////
//  Имя алгоритма               : CRC8-DALLAS-MAXIM                           //
//  Стандарты                   : 1-Wire bus                                  //
//  Где используется            : 1-Wire bus                                  //
//  Иннициализирующее значение  : $00                                         //
//  Выходная XOR маска          : $00                                         //
//  Входные данные              : инвертируются                               //
//  Выходной CRC перед XOR      : инвертируется                               //
//  Значение полинома           : $31 (Зеркальное значение = $8C)             //
//  Полином                     : x^8 + x^5 + x^4 + 1                         //
//  Значение для '123456789'    : $A1                                         //
////////////////////////////////////////////////////////////////////////////////

  CRC8_DALLAS_MAXIM_POLYNOM  = $31;
  CRC8_MY  = $8C;

////////////////////////////////////////////////////////////////////////////////
//                                 CRC16                                      //
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//  Имя алгоритма               : CRC-16(Standard), CRC16-IBM, CRC-16-BISYNCH //
//  Стандарты                   : ITU X.25/T.30                               //
//  Где используется            : IBM BISYNCH, LHA, PKPAK, ZOO                //
//  Иннициализирующее значение  : $0000                                       //
//  Выходная XOR маска          : $0000                                       //
//  Входные данные              : инвертируются                               //
//  Выходной CRC перед XOR      : инвертируется                               //
//  Значение полинома           : $8005 (Зеркальное значение = $A001)         //
//  Полином                     : x^16 + x^15 + x^2 + 1                       //
//  Значение для '123456789'    : $BB3D                                       //
////////////////////////////////////////////////////////////////////////////////

  CRC16_STANDART_POLYNOM     = $8005;

////////////////////////////////////////////////////////////////////////////////
//  Имя алгоритма               : CRC-16-CCITT                                //
//  Стандарты                   : ITU-TSS CRC-16 X.25-CCITT                   //
//  Где используется            : ADCCP, IMB SDLC, ISO HDLC, V.41, 3GPP, PPP, //
//                                Bluetooth, IrDA и др.                       //
//  Иннициализирующее значение  : $FFFF                                       //
//  Выходная XOR маска          : $0000                                       //
//  Входные данные              : не инвертируются                            //
//  Выходной CRC перед XOR      : не инвертируется                            //
//  Значение полинома           : $1021 (Зеркальное значение = $8408)         //
//  Полином                     : x^16 + x^12 + x^5 + 1                       //
//  Значение для '123456789'    : $29B1                                       //
////////////////////////////////////////////////////////////////////////////////

  CRC16_CCITT_POLYNOM        = $1021;

////////////////////////////////////////////////////////////////////////////////
//  Имя алгоритма               : CRC16-XMODEM (?????)                        //
//  Стандарты                   : ITU-T V.41                                  //
//  Где используется            : XMODEM, PPP                                 //
//  Иннициализирующее значение  : $0000                                       //
//  Выходная XOR маска          : $0000                                       //
//  Входные данные              : не инвертируются                            //
//  Выходной CRC перед XOR      : не инвертируется                            //
//  Значение полинома           : $1021 (Зеркальное значение = $8408)         //
//  Полином                     : x^16 + x^15 + x^2 + 1                       //
//  Значение для '123456789'    : $31C3                                       //
////////////////////////////////////////////////////////////////////////////////

  CRC16_XMODEM_POLYNOM       = $1021;

////////////////////////////////////////////////////////////////////////////////
//                                 CRC32                                      //
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//  Имя алгоритма               : CRC-32(Standard)                            //
//  Стандарты                   : ISO 3309, ITU-T V.42,ANSI X3.66,FIPS PUB 71 //
//  Где используется            : ZIP, RAR, Ethernet, AUTODIN II, FDDI и др.  //
//  Иннициализирующее значение  : $FFFFFFFF                                   //
//  Выходная XOR маска          : $FFFFFFFF                                   //
//  Входные данные              : инвертируются                               //
//  Выходной CRC перед XOR      : инвертируется                               //
//  Значение полинома           : $04C11DB7 (Зеркальное значение = $EDB88320) //
//  Полином                     : x^32 + x^26 + x^23 + x^22 + x^16 + x^12 +   //
//                                x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + //
//                                x + 1                                       //
//  Значение для '123456789'    : $CBF43926                                   //
////////////////////////////////////////////////////////////////////////////////

  CRC32_STANDART_POLYNOM     = $04C11DB7;

////////////////////////////////////////////////////////////////////////////////
//  Имя алгоритма               : CRC-32C (Guy Castagnoli)                    //
//  Стандарты                   : ??                                          //
//  Где используется            : ??                                          //
//  Иннициализирующее значение  : $FFFFFFFF                                   //
//  Выходная XOR маска          : $FFFFFFFF                                   //
//  Входные данные              : инвертируются                               //
//  Выходной CRC перед XOR      : инвертируется                               //
//  Значение полинома           : $1EDC6F41 (Зеркальное значение = $82F63B78) //
//  Полином                     : x^32 + x^28 + x^27 + x^26 + x^25 + x^23 +   //
//                                x^22 + x^20 + x^19 + x^18 + x^14 + x^13 +   //
//                                x^11 + x^10 + x^9 + x^8 + x^6 + 1           //
//  Значение для '123456789'    : $E3069283                                   //
////////////////////////////////////////////////////////////////////////////////

  CRC32C_POLYNOM             = $1EDC6F41;

////////////////////////////////////////////////////////////////////////////////
//                                 CRC64                                      //
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//  Имя алгоритма               : CRC-64-ISO                                  //
//  Стандарты                   : HDLC - ISO 3309                             //
//  Где используется            : HDLC - ISO 3309                             //
//  Иннициализирующее значение  : $0                                          //
//  Выходная XOR маска          : $0                                          //
//  Входные данные              : инвертируются                               //
//  Выходной CRC перед XOR      : инвертируется                               //
//  Значение полинома           : $000000000000001B                           //
//                                (Зеркальное значение = $D800000000000000)   //
//  Полином                     : x^64 + x^4 + x^3 + x + 1                    //
//  Значение для '123456789'    : $46A5A9388A5BEFFE                           //
////////////////////////////////////////////////////////////////////////////////

  CRC64_ISO_POLYNOM          = $000000000000001B;

type

  TCRC8Table = array[Byte] of Byte;
  TCRC16Table = array[Byte] of Word;
  TCRC32Table = array[Byte] of Cardinal;
  TCRC64Table = array[Byte] of Int64;

var

  CRC8Table: TCRC8Table;
  CRC16Table: TCRC16Table;
  CRC32Table: TCRC32Table;
  CRC64Table: TCRC64Table;

//------------------------------------------------------------------------------

procedure GenerateCRC8Table(Polynom: Byte);
function CalculateCrc8(const Data; const DataLen: Cardinal; const Initial: Byte): Byte;
procedure GenerateCRC8TableReverse(Polynom: byte);
function CalculateCrc8Reverse(const Data; const DataLen: Cardinal; const Initial: Byte): Byte;

//------------------------------------------------------------------------------

procedure GenerateCRC16Table(Polynom: WORD);
function CalculateCrc16(const Data; const DataLen: Cardinal; const Initial: WORD): WORD;
procedure GenerateCRC16TableReverse(Polynom: WORD);
function CalculateCrc16Reverse(const Data; const DataLen: Cardinal; const Initial: WORD): WORD;

//------------------------------------------------------------------------------

procedure GenerateCRC32Table(Polynom: Cardinal);
function CalculateCrc32(const Data; const DataLen: Cardinal; const Initial: Cardinal): Cardinal;
procedure GenerateCRC32TableReverse(Polynom: Cardinal);
function CalculateCrc32Reverse(const Data; const DataLen: Cardinal; const Initial: Cardinal): Cardinal;

//------------------------------------------------------------------------------

procedure GenerateCRC64Table(Polynom: Int64);
function CalculateCrc64(const Data; const DataLen: Cardinal; const Initial: Int64): Int64;
procedure GenerateCRC64TableReverse(Polynom: Int64);
function CalculateCrc64Reverse(const Data; const DataLen: Cardinal; const Initial: Int64): Int64;

// CRC8 SMBUS functions --------------------------------------------------------

procedure GenerateCRC8TableSMBUS;
function CalculateCrc8SMBUS(const Data; const DataLen: Cardinal): byte;

// CRC8 DALLAS/MAXIM functions -------------------------------------------------

procedure GenerateCRC8TableDALLAS;
function CalculateCrc8DALLAS(const Data; const DataLen: Cardinal): byte;

// CRC16 Standart functions ----------------------------------------------------

procedure GenerateCRC16TableStandart;
function CalculateCrc16Standart(const Data; const DataLen: Cardinal): WORD;

// CRC16 CCITT functions -------------------------------------------------------

procedure GenerateCRC16TableCCITT;
function CalculateCrc16CCITT(const Data; const DataLen: Cardinal): WORD;

// CRC16 X-Modem functions -----------------------------------------------------

procedure GenerateCRC16TableXModem;
function CalculateCrc16XModem(const Data; const DataLen: Cardinal): WORD;

// CRC32 Standart functions ----------------------------------------------------

procedure GenerateCRC32TableStandart;
function CalculateCrc32Standart(const Data; const DataLen: Cardinal): Cardinal;

// CRC32C functions ------------------------------------------------------------

procedure GenerateCRC32TableC;
function CalculateCrc32C(const Data; const DataLen: Cardinal): Cardinal;

// CRC64ISO functions ----------------------------------------------------------

procedure GenerateCRC64TableISO;
function CalculateCrc64ISO(const Data; const DataLen: Cardinal): Int64;

// Polynom functions -----------------------------------------------------------

function InvertPolynom8(Polynom: Byte): Byte;
function InvertPolynom16(Polynom: WORD): WORD;
function InvertPolynom32(Polynom: Cardinal): Cardinal;
function InvertPolynom64(Polynom: Int64): Int64;

//------------------------------------------------------------------------------

procedure SelfTestModule;

//------------------------------------------------------------------------------

implementation

//------------------------------------------------------------------------------

function ReverseBits(Bits: integer; BitCount: integer): integer;
var
  i, j: integer;
  k: integer;
begin
  result := 0;
  j := 1;
  i := 1 shl (BitCount - 1);
  for k := 0 to BitCount - 1 do
    begin
      if (Bits and i) = i then
        result := result or j;
      j := j shl 1;
      i := i shr 1;
    end;
end;

//------------------------------------------------------------------------------

function ReverseBits64(Value: Int64): Int64;
begin
  TULargeInteger(Result).LowPart := ReverseBits(TULargeInteger(Value).HighPart, 32);
  TULargeInteger(Result).HighPart := ReverseBits(TULargeInteger(Value).LowPart, 32);
end;

//------------------------------------------------------------------------------

function InvertPolynom8(Polynom: byte): byte;
begin
  result := ReverseBits(Polynom, 8);
end;

//------------------------------------------------------------------------------

function InvertPolynom16(Polynom: WORD): WORD;
begin
  result := ReverseBits(Polynom, 16);
end;

//------------------------------------------------------------------------------

function InvertPolynom32(Polynom: Cardinal): Cardinal;
begin
  result := ReverseBits(Polynom, 32);
end;

//------------------------------------------------------------------------------

function InvertPolynom64(Polynom: Int64): Int64;
begin
  result := ReverseBits64(Polynom);
end;

//------------------------------------------------------------------------------

procedure GenerateCRC8Table(Polynom: byte);
var
  i, j: integer;
begin
  for i := 0 to 255 do
    begin
      CRC8Table[i] := i;
      for j := 0 to 7 do
        begin
          if (CRC8Table[i] and $80) <> 0 then
            CRC8Table[i]:=(CRC8Table[i] shl 1) xor Polynom
          else
            CRC8Table[i] := CRC8Table[i] shl 1;
        end;
      CRC8Table[i] := CRC8Table[i] and $ff;
    end;
end;

//------------------------------------------------------------------------------

function CalculateCrc8(const Data; const DataLen: Cardinal; const Initial: Byte): Byte;
var
  i: integer;
  PData: ^Byte;
begin
  Result := Initial;
  PData := @Data;
  for i := 1 to DataLen do
    begin
      Result := (Result shl 8) xor CRC8Table[PData^ xor Result and $ff];
      inc(PData);
    end;
  Result := Result and $ff;
end;

//------------------------------------------------------------------------------

function CalculateCrc8Reverse(const Data; const DataLen: Cardinal; const Initial: Byte): Byte;
var
  i: integer;
  PData: ^Byte;
begin
  Result := Initial;
  PData := @Data;
  for i := 1 to DataLen do
    begin
      Result:=(Result shr 8) xor CRC8Table[PData^ xor Result and $ff];
      inc(PData);
    end;
end;

//------------------------------------------------------------------------------

procedure GenerateCRC8TableReverse(Polynom: byte);
var
  i, j: integer;
begin
  for i := 0 to 255 do
    begin
      CRC8Table[i] := i;
      for j := 0 to 7 do
        begin
          if (CRC8Table[i] and $01) <> 0 then
            CRC8Table[i]:=(CRC8Table[i] shr 1) xor Polynom
          else
            CRC8Table[i] := CRC8Table[i] shr 1;
        end;
    end;
end;

//------------------------------------------------------------------------------

procedure GenerateCRC16Table(Polynom: WORD);
var
  i, j: integer;
begin
  for i := 0 to 255 do
    begin
      CRC16Table[i] := i shl 8;
      for j := 0 to 7 do
        begin
          if (CRC16Table[i] and $8000) <> 0 then
            CRC16Table[i]:=(CRC16Table[i] shl 1) xor Polynom
          else
            CRC16Table[i] := CRC16Table[i] shl 1;
        end;
      CRC16Table[i] := CRC16Table[i] and $ffff;
    end;
end;

//------------------------------------------------------------------------------

procedure GenerateCRC16TableReverse(Polynom: WORD);
var
  i, j: integer;
begin
  for i := 0 to 255 do
    begin
      CRC16Table[i] := i;
      for j := 0 to 7 do
        begin
          if (CRC16Table[i] and $0001) <> 0 then
            CRC16Table[i]:=(CRC16Table[i] shr 1) xor Polynom
          else
            CRC16Table[i] := CRC16Table[i] shr 1;
        end;
    end;
end;

//------------------------------------------------------------------------------

function CalculateCrc16(const Data; const DataLen: Cardinal; const Initial: WORD): WORD;
var
  i: integer;
  PData: ^Byte;
begin
  Result := Initial;
  PData := @Data;
  for i := 1 to DataLen do
    begin
      Result := (Result shl 8) xor CRC16Table[PData^ xor (Result shr 8) and $ff];
      inc(PData);
    end;
  Result := Result and $ffff;
end;

//------------------------------------------------------------------------------

function CalculateCrc16Reverse(const Data; const DataLen: Cardinal; const Initial: WORD): WORD;
var
  i: integer;
  PData: ^Byte;
begin
  Result := Initial;
  PData := @Data;
  for i := 1 to DataLen do
    begin
      Result := (Result shr 8) xor CRC16Table[PData^ xor Result and $ff];
      inc(PData);
    end;
end;

//------------------------------------------------------------------------------

procedure GenerateCRC32Table(Polynom: Cardinal);
var
  i, j: integer;
begin
  for i := 0 to 255 do
    begin
      CRC32Table[i] := i shl 24;
      for j := 0 to 7 do
        begin
          if (CRC32Table[i] and $80000000) <> 0 then
            CRC32Table[i]:=(CRC32Table[i] shl 1) xor Polynom
          else
            CRC32Table[i] := CRC32Table[i] shl 1;
        end;
      CRC32Table[i] := CRC32Table[i] and $ffffffff;
    end;
end;

//------------------------------------------------------------------------------

function CalculateCrc32(const Data; const DataLen: Cardinal; const Initial: Cardinal): Cardinal;
var
  i: integer;
  PData: ^Byte;
begin
  Result := Initial;
  PData := @Data;
  for i := 1 to DataLen do
    Result := (Result shl 8) xor Crc32Table[PData^ xor (Result shr 24) and $ff];
  Result := Result and $ffffffff;    
end;

//------------------------------------------------------------------------------

procedure GenerateCRC32TableReverse(Polynom: Cardinal);
var
  i, j: integer;
begin
  for i := 0 to 255 do
    begin
      CRC32Table[i] := i;
      for j := 0 to 7 do
        begin
          if (CRC32Table[i] and $00000001) <> 0 then
            CRC32Table[i]:=(CRC32Table[i] shr 1) xor Polynom
          else
            CRC32Table[i] := CRC32Table[i] shr 1;
        end;
    end;
end;

//------------------------------------------------------------------------------

function CalculateCrc32Reverse(const Data; const DataLen: Cardinal; const Initial: Cardinal): Cardinal;
var
  i: integer;
  PData: ^Byte;
begin
  Result := Initial;
  PData := @Data;
  for i := 1 to DataLen do
    begin
      Result := (Result shr 8) xor Crc32Table[PData^ xor Result and $ff];
      inc(PData);
    end;
end;

//------------------------------------------------------------------------------

procedure GenerateCRC64Table(Polynom: Int64);
var
  i, j: integer;
begin
  for i := 0 to 255 do
    begin
      CRC64Table[i] := Int64(i) shl 56;
      for j := 0 to 7 do
        begin
          if (CRC64Table[i] and $8000000000000000) <> 0 then
            CRC64Table[i]:=(CRC64Table[i] shl 1) xor Polynom
          else
            CRC64Table[i] := CRC64Table[i] shl 1;
        end;
      CRC64Table[i] := CRC64Table[i] and $ffffffffffffffff;
    end;
end;

//------------------------------------------------------------------------------

function CalculateCrc64(const Data; const DataLen: Cardinal; const Initial: Int64): Int64;
var
  i: integer;
  PData: ^Byte;
begin
  Result := Initial;
  PData := @Data;
  for i := 1 to DataLen do
    begin
      Result := (Result shl 8) xor CRC64Table[PData^ xor (Result shr 56) and $ff];
      inc(PData);
    end;
  Result := Result and $ffffffffffffffff;
end;

//------------------------------------------------------------------------------

procedure GenerateCRC64TableReverse(Polynom: Int64);
var
  i, j: integer;
begin
  for i := 0 to 255 do
    begin
      CRC64Table[i] := i;
      for j := 0 to 7 do
        begin
          if (CRC64Table[i] and $0000000000000001) <> 0 then
            CRC64Table[i]:=(CRC64Table[i] shr 1) xor Polynom
          else
            CRC64Table[i] := CRC64Table[i] shr 1;
        end;
    end;
end;

//------------------------------------------------------------------------------

function CalculateCrc64Reverse(const Data; const DataLen: Cardinal; const Initial: Int64): Int64;
var
  i: integer;
  PData: ^Byte;
begin
  Result := Initial;
  PData := @Data;
  for i := 1 to DataLen do
    begin
      Result:=(Result shr 8) xor CRC64Table[PData^ xor Result and $ff];
      inc(PData);
    end;
end;

//------------------------------------------------------------------------------

procedure GenerateCRC8TableSMBUS;
begin
  GenerateCRC8Table(CRC8_SMBUS_POLYNOM);
end;

//------------------------------------------------------------------------------

function CalculateCrc8SMBUS(const Data; const DataLen: Cardinal): byte;
begin
  result := CalculateCrc8(Data, DataLen, 0)
end;

//------------------------------------------------------------------------------

procedure GenerateCRC8TableDALLAS;
begin
  GenerateCRC8TableReverse(InvertPolynom8(CRC8_DALLAS_MAXIM_POLYNOM));
end;

//------------------------------------------------------------------------------

function CalculateCrc8DALLAS(const Data; const DataLen: Cardinal): byte;
begin
  result := CalculateCrc8Reverse(Data, DataLen, 0)
end;

//------------------------------------------------------------------------------

procedure GenerateCRC16TableStandart;
begin
  GenerateCRC16TableReverse(InvertPolynom16(CRC16_STANDART_POLYNOM));
end;

//------------------------------------------------------------------------------

procedure GenerateCRC16TableCCITT;
begin
  GenerateCRC16Table(CRC16_CCITT_POLYNOM);
end;

//------------------------------------------------------------------------------

function CalculateCrc16Standart(const Data; const DataLen: Cardinal): WORD;
begin
  result := CalculateCrc16Reverse(Data, DataLen, 0)
end;

//------------------------------------------------------------------------------

function CalculateCrc16CCITT(const Data; const DataLen: Cardinal): WORD;
begin
  result := CalculateCrc16(Data, DataLen, $FFFF);
end;

//------------------------------------------------------------------------------

procedure GenerateCRC16TableXModem;
begin
  GenerateCRC16Table(CRC16_XMODEM_POLYNOM);
end;

//------------------------------------------------------------------------------

function CalculateCrc16XModem(const Data; const DataLen: Cardinal): WORD;
begin
  result := CalculateCrc16(Data, DataLen, 0)
end;

//------------------------------------------------------------------------------

procedure GenerateCRC32TableStandart;
begin
  GenerateCRC32TableReverse(InvertPolynom32(CRC32_STANDART_POLYNOM));
end;

//------------------------------------------------------------------------------

function CalculateCrc32Standart(const Data; const DataLen: Cardinal): Cardinal;
begin
  result := CalculateCrc32Reverse(Data, DataLen, $FFFFFFFF) xor $FFFFFFFF
end;

//------------------------------------------------------------------------------

procedure GenerateCRC32TableC;
begin
  GenerateCRC32TableReverse(InvertPolynom32(CRC32C_POLYNOM));
end;

//------------------------------------------------------------------------------

function CalculateCrc32C(const Data; const DataLen: Cardinal): Cardinal;
begin
  result := CalculateCrc32Reverse(Data, DataLen, $FFFFFFFF) xor $FFFFFFFF
end;

//------------------------------------------------------------------------------

procedure GenerateCRC64TableISO;
begin
  GenerateCRC64TableReverse(InvertPolynom64(CRC64_ISO_POLYNOM));
end;

//------------------------------------------------------------------------------

function CalculateCrc64ISO(const Data; const DataLen: Cardinal): Int64;
begin
  result := CalculateCrc64Reverse(Data, DataLen, $0000000000000000)
end;

//------------------------------------------------------------------------------

procedure SelfTestModule;
const
  TestString = '123456789';
begin
  // CRC8SMBUS
  GenerateCRC8TableSMBUS;
  if CalculateCrc8SMBUS(TestString[1], Length(TestString)) <> $F4 then
    MessageBox(0, 'CRC8SMBUS test failed!', '', 0);

  // CRC8DALLASMAXIM
  GenerateCRC8TableDALLAS;
  if CalculateCrc8DALLAS(TestString[1], Length(TestString)) <> $A1 then
    MessageBox(0, 'CRC8DALLAS test failed!', '', 0);

  // CRC16
  GenerateCRC16TableStandart;
  if CalculateCrc16Standart(TestString[1], Length(TestString)) <> $BB3D then
    MessageBox(0, 'CRC16 test failed!', '', 0);

  // CRC16CCITT
  GenerateCRC16TableCCITT;
  if CalculateCrc16CCITT(TestString[1], Length(TestString)) <> $29B1 then
    MessageBox(0, 'CRC16CCITT test failed!', '', 0);

  // CRC16XModem
  GenerateCRC16TableXModem;
  if CalculateCrc16XModem(TestString[1], Length(TestString)) <> $31C3 then
    MessageBox(0, 'CRC16XModem test failed!', '', 0);

  // CRC32Standart
  GenerateCRC32TableStandart;
  if CalculateCrc32Standart(TestString[1], Length(TestString)) <> $CBF43926 then
    MessageBox(0, 'CRC32Standart test failed!', '', 0);

  // CRC32C
  GenerateCRC32TableC;
  if CalculateCrc32C(TestString[1], Length(TestString)) <> $E3069283 then
    MessageBox(0, 'CRC32C test failed!', '', 0);

  // CRC64ISO
  GenerateCRC64TableISO;
  if CalculateCrc64ISO(TestString[1], Length(TestString)) <> $46A5A9388A5BEFFE then
    MessageBox(0, 'CRC64ISO test failed!', '', 0);
end;

//------------------------------------------------------------------------------

end.




