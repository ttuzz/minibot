'камень
$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 9600
Config Serialin = Buffered , Size = 20

'делаю супермегабиг+ стек
$hwstack = 128
$swstack = 128
$framesize = 128

'библиотеки AVR-DOS и SD
$include "Config_MMC.bas"
$include "Config_AVR-DOS.BAS"

'светодиоды
Config Pinc.4 = Output : Led_r1 Alias Portc.4
Config Pinc.5 = Output : Led_g1 Alias Portc.5
Config Pinc.6 = Output : Led_r2 Alias Portc.6
Config Pinc.7 = Output : Led_g2 Alias Portc.7

      Print "MiniBot v.2 is configured"
      Led_g1 = 1
      Enable Interrupts
'///**********MINIBOT CONFIGS**********

'Declare Sub Get_file(filename As String)
'Declare Sub Print_file(filename As String)
Declare Sub File_print()
Declare Sub Uue_encode_print()
Declare Sub Uue_decode()


Gbdoserror = Initfilesystem(1)

Dim S As String * 32
Dim Packet(32) As Byte At S Overlay
Dim D As String * 33
Dim W As Word

'Dim S2 As String * 10 At S Overlay

Do

   Print Chr(10) ; Chr(13) ;
   Print ">: " ;

   'X ^ 16 + X ^ 15 + X ^ 2 + 1  - crc16

   Waitms 6
   Clear Serialin

   'Packet(1) = "C"
   'Packet(2) = "a"
   'Packet(3) = "t"
   'Packet(4) = "C"
   'Packet(5) = "a"
   'Packet(6) = "t"
   'Uue_encode_print


   'S = "Emptystring"
   'Packet(1) = "S"
   'Packet(2) = "T"
   'Packet(3) = "A"
   'Packet(4) = "R"
   'Packet(5) = "T"
   'Packet(13) = "A"
   'Packet(12) = "A"
   'Print S ; "," ; Hex(packet(11)) ; "," ; Hex(packet(12)) ; "," ; Hex(packet(13)) :

   'Packet(1) = "1"
   'Packet(2) = "2"
   'Packet(3) = "3"
   'Print Hex(crc8(packet(1) , 3))

   Packet(1) = Waitkey()
   If Packet(1) = "C" Then Call File_print()
'(
   Ucsrb.rxen = 0
   S = Base64dec(s)
   S = Base64enc(s)
   Ucsrb.rxen = 1
')
Loop




Sub Uue_encode_print()
'Использует глобальный пакет, т.е. переменные глобального ввода!!
'Использует свою модификацию print!!
' (количество троебайтий-1) =)
   Const _amount = 7                                        '8*3=24 байта инфы

   Local B_buf As Byte : Local L_buf As Long : Local L_buf2 As Long
   Local Index As Byte : Local I As Byte : Local K As Byte

   For I = 0 To _amount
      Index = I * 3
      'первый, второй и третий байты
      Incr Index : L_buf = Packet(index) : Shift L_buf , Left , 8
      Incr Index : L_buf = L_buf + Packet(index) : Shift L_buf , Left , 8
      Incr Index : L_buf = L_buf + Packet(index)
      'кодирование
      L_buf2 = L_buf
      For K = 3 To 0 Step -1
         Index = K * 6
         Shift L_buf2 , Right , Index
         B_buf = L_buf2
         B_buf = B_buf And &B00111111
         B_buf = B_buf + 32
         Printbin B_buf
         L_buf2 = L_buf
'( крутой код
         B_buf = L_buf : B_buf = B_buf And &B00111111 : B_buf = B_buf + 32
         Printbin B_buf
         Shift L_buf , Right , 6
')
      Next
   Next
End Sub

Sub Uue_decode_tofile()
'Использует глобальный пакет, т.е. переменные глобального ввода!!
'Использует свою модификацию print!!


End Sub

Sub File_print()
' UUE кодирование
   Const _soh = &H01                                        'Start of header
   Const _eop = &H17                                        'End of packet
   Const _eot = &H04                                        'End of Transmission
   Const _ack = &H06                                        'Acknowledge
   Const _nack = &H15                                       'Not Acknowledge
   Const _c = &H43                                          'ASCII "C"
   Const _can = &H18                                        'Cancel transmittion
   Const Filename = "lb.bmp"
   Const File = 14
   Local Pack_amount As Long
   Local I As Long : Local K As Byte : Local Pack_modul As Byte
   Local Pack_number1 As Byte : Local Pack_number2 As Byte : Local Pack_crc8 As Byte
   Local Inp_key As Byte

   Led_r1 = 1
   Open Filename For Binary As #file
   If Gbdoserror <> 0 Then
      Led_r2 = 1
      Print "Error"
      Print
   End If
   Clear Serialin                                           'очищаю буфер ввода
   I = Filelen(filename)
   Print "filelen:" ; I
   Pack_amount = I \ 24                                     'количество пакетов по 128 байт
   Pack_modul = Pack_amount * 24
   Pack_modul = I - Pack_modul                              'остаток данных

   Pack_number1 = 1
   If Pack_amount <> 0 Then
      Led_g2 = 1
      For I = 1 To Pack_amount
         For K = 1 To 24
            Get #file , Packet(k)
         Next
         Pack_number2 = &HFF - Pack_number1                 'в   сумме pack_number1+pack_number2=0xFF
         Pack_crc8 = Crc8(packet(1) , 24)                   'контрольная сумма base64 строки
Transieve:
         Ucsrb.rxen = 0
            Printbin _soh ; Pack_number1 ; Pack_number2
            Uue_encode_print                                'кодирую + вывожу
            Printbin Pack_crc8 ; _eop
               While Ucsra.udre = 0
               Wend
               Waitms 6
               Clear Serialin
         Ucsrb.rxen = 1
         'ВВЕСТИ ПРОВЕРКУ НА ВООБЩЕ ЛЕВЫЙ СИМВОЛ
         Inp_key = Waitkey()                                'ответ
         Select Case Inp_key
         Case _ack:
            If Pack_number1 <> 255 Then
               Incr Pack_number1
            Else
               Pack_number1 = 0
            End If
         Case _nack:
            Goto Transieve
         Case _can:
            Goto Transieve3
         End Select
      Next
   End If
   If Pack_modul <> 0 Then                                  'передаю остаток
      For I = 1 To Pack_modul
         Get #file , Packet(i)
      Next
      Incr Pack_modul                                       'заполняю нулями
      For I = Pack_modul To 24
         Packet(i) = 0
      Next
      Pack_number2 = &HFF - Pack_number1                    'в сумме pack_number1+pack_number2=0xFF
      Pack_crc8 = Crc8(packet(1) , 24)                      'контрольная сумма base64 строки
Transieve2:
      Ucsrb.rxen = 0
            Printbin _soh ; Pack_number1 ; Pack_number2
            Uue_encode_print                                'кодирую + вывожу
            Printbin Pack_crc8 ; _eop
               While Ucsra.udre = 0
               Wend
               Clear Serialin
      Ucsrb.rxen = 1
      Inp_key = Waitkey()                                   'ответ
      Select Case Inp_key
      Case _ack:
         If Pack_number1 <> 255 Then
            Incr Pack_number1
         Else
            Pack_number1 = 0
         End If
      Case _nack:
         Goto Transieve2
      Case _can:
         Goto Transieve3
      End Select
   End If
Transieve3:                                                 'передаю признак конца передачи
   Ucsrb.rxen = 0
      Printbin _eot
         While Ucsra.udre = 0
         Wend
         Clear Serialin
   Ucsrb.rxen = 1
   Inp_key = Waitkey()                                      'ответ
   If Inp_key <> _ack Then                                  'если пакет не передан
      Goto Transieve3
   End If
   Close #file
   'ВНИМАНИЕ, ПАКОСТЬ
         End
   'ВНИМАНИЕ, ПАКОСТЬ
End Sub

'(
Sub File_print()
' UUE кодирование
   Const _soh = &H01                                        'Start of header
   Const _eop = &H17                                        'End of packet
   Const _eot = &H04                                        'End of Transmission
   Const _ack = &H06                                        'Acknowledge
   Const _nack = &H15                                       'Not Acknowledge
   Const _c = &H43                                          'ASCII "C"
   Const _can = &H18                                        'Cancel transmittion
   Const Filename = "lb.bmp"
   Const File = 14
   Local Pack_amount As Long
   Local I As Long : Local K As Byte : Local Pack_modul As Byte
   Local Pack_number1 As Byte : Local Pack_number2 As Byte : Local Pack_crc8 As Byte
   Local Inp_key As Byte

   Led_r1 = 1
   Open Filename For Binary As #file
   If Gbdoserror <> 0 Then
      Led_r2 = 1
      Print "Error"
      Print
   End If
   Clear Serialin                                           'очищаю буфер ввода
   I = Filelen(filename)
   Print "filelen:" ; I
   Pack_amount = I \ 24                                     'количество пакетов по 128 байт
   Pack_modul = Pack_amount * 24
   Pack_modul = I - Pack_modul                              'остаток данных

   Pack_number1 = 1
   If Pack_amount <> 0 Then
      Led_g2 = 1
      For I = 1 To Pack_amount
         For K = 1 To 24
            Get #file , Packet(k)
         Next
         Pack_number2 = &HFF - Pack_number1                 'в   сумме pack_number1+pack_number2=0xFF
         Pack_crc8 = Crc8(packet(1) , 24)                   'контрольная сумма base64 строки
Transieve:
         Ucsrb.rxen = 0
            Printbin _soh ; Pack_number1 ; Pack_number2
            Uue_encode_print                                'кодирую + вывожу
            Printbin Pack_crc8 ; _eop
               While Ucsra.udre = 0
               Wend
               Waitms 6
               Clear Serialin
         Ucsrb.rxen = 1
         'ВВЕСТИ ПРОВЕРКУ НА ВООБЩЕ ЛЕВЫЙ СИМВОЛ
         Inp_key = Waitkey()                                'ответ
         Select Case Inp_key
         Case _ack:
            If Pack_number1 <> 255 Then
               Incr Pack_number1
            Else
               Pack_number1 = 0
            End If
         Case _nack:
            Goto Transieve
         Case _can:
            Goto Transieve3
         End Select
      Next
   End If
   If Pack_modul <> 0 Then                                  'передаю остаток
      For I = 1 To Pack_modul
         Get #file , Packet(i)
      Next
      Incr Pack_modul                                       'заполняю нулями
      For I = Pack_modul To 24
         Packet(i) = 0
      Next
      Pack_number2 = &HFF - Pack_number1                    'в сумме pack_number1+pack_number2=0xFF
      Pack_crc8 = Crc8(packet(1) , 24)                      'контрольная сумма base64 строки
Transieve2:
      Ucsrb.rxen = 0
            Printbin _soh ; Pack_number1 ; Pack_number2
            Uue_encode_print                                'кодирую + вывожу
            Printbin Pack_crc8 ; _eop
               While Ucsra.udre = 0
               Wend
               Clear Serialin
      Ucsrb.rxen = 1
      Inp_key = Waitkey()                                   'ответ
      Select Case Inp_key
      Case _ack:
         If Pack_number1 <> 255 Then
            Incr Pack_number1
         Else
            Pack_number1 = 0
         End If
      Case _nack:
         Goto Transieve2
      Case _can:
         Goto Transieve3
      End Select
   End If
Transieve3:                                                 'передаю признак конца передачи
   Ucsrb.rxen = 0
      Printbin _eot
         While Ucsra.udre = 0
         Wend
         Clear Serialin
   Ucsrb.rxen = 1
   Inp_key = Waitkey()                                      'ответ
   If Inp_key <> _ack Then                                  'если пакет не передан
      Goto Transieve3
   End If
   Close #file
   'ВНИМАНИЕ, ПАКОСТЬ
         End
   'ВНИМАНИЕ, ПАКОСТЬ
End Sub
')

'(
Sub File_print()
'base64 работает
   Const _soh = &H01                                        'Start of header
   Const _eop = &H17                                        'End of packet
   Const _eot = &H04                                        'End of Transmission
   Const _ack = &H06                                        'Acknowledge
   Const _nack = &H15                                       'Not Acknowledge
   Const _c = &H43                                          'ASCII "C"
   Const _can = &H18                                        'Cancel transmittion
   Const Filename = "lb.bmp"
   Const File = 14
   Local Pack_amount As Long
   Local I As Long : Local K As Long : Local Pack_modul As Byte
   Local Pack_number1 As Byte : Local Pack_number2 As Byte : Local Pack_crc16 As Word
   Local Inp_key As Byte

   Led_r1 = 1
   Open Filename For Binary As #file
   If Gbdoserror <> 0 Then
      Led_r2 = 1
      Print "Error"
      Print
   End If
   Clear Serialin                                           'очищаю буфер ввода
   Pack_amount = Filelen(filename)
   Pack_amount = Pack_amount \ 24                           'количество пакетов по 128 байт
   Pack_modul = Pack_amount Mod 24                          'остаток данных
   Pack_number1 = 1
   If Pack_amount <> 0 Then
      Led_g2 = 1
      For I = 1 To Pack_amount
         For K = 1 To 24
            Get #file , Packet(k)
            Print Hex(packet(k));
         Next
         Print
         Packet(25) = 0                                     'символ конца строки
         'Print "symbol AA is: '" ; Chr(&Haa) ; "'"
         'Print "string is: '" ; S ; "'"

         D = Base64enc(s)                                   'кодирую для передачи
         'Print
         'Print "base64: '" ; D ; "'"
         Pack_number2 = &HFF - Pack_number1                 'в сумме pack_number1+pack_number2=0xFF
         Pack_crc16 = Crc16(packet(1) , 24)                 'контрольная сумма base64 строки
         Rotate Pack_crc16 , Left , 8
Transieve:
         Ucsrb.rxen = 0
            Printbin _soh ; Pack_number1 ; Pack_number2
            Print D ;
            Printbin Pack_crc16 ; _eop
               While Ucsra.udre = 0
               Wend
               Waitms 6
               Clear Serialin
         Ucsrb.rxen = 1
         'ВВЕСТИ ПРОВЕРКУ НА ВООБЩЕ ЛЕВЫЙ СИМВОЛ
         Inp_key = Waitkey()                                'ответ
         Select Case Inp_key
         Case _ack:
            If Pack_number1 <> 255 Then
               Incr Pack_number1
            Else
               Pack_number1 = 0
            End If
         Case _nack:
            Goto Transieve
         Case _can:
            Goto Transieve3
         End Select
      Next
   End If
   If Pack_modul <> 0 Then                                  'передаю остаток
      For I = 1 To Pack_modul
         Get #file , Packet(i)
      Next
      Incr Pack_modul
      Packet(pack_modul) = 0                                'символ конца строки
      S = Base64enc(s)                                      'кодирую для передачи
      Pack_number2 = &HFF - Pack_number1                    'в сумме pack_number1+pack_number2=0xFF
      I = Len(s)                                            'длина base64 пакета
      Pack_crc16 = Crc16(packet(1) , I)                     'контрольная сумма base64 строки
      Rotate Pack_crc16 , Left , 8
Transieve2:
      Ucsrb.rxen = 0
            Printbin _soh ; Pack_number1 ; Pack_number2
            Print S ;
            Printbin Pack_crc16 ; _eop
               While Ucsra.udre = 0
               Wend
               Clear Serialin
      Ucsrb.rxen = 1
      Inp_key = Waitkey()                                   'ответ
      Select Case Inp_key
      Case _ack:
         If Pack_number1 <> 255 Then
            Incr Pack_number1
         Else
            Pack_number1 = 0
         End If
      Case _nack:
         Goto Transieve2
      Case _can:
         Goto Transieve3
      End Select
   End If
Transieve3:                                                 'передаю признак конца передачи
   Ucsrb.rxen = 0
      Printbin _eot
         While Ucsra.udre = 0
         Wend
         Clear Serialin
   Ucsrb.rxen = 1
   Inp_key = Waitkey()                                      'ответ
   If Inp_key <> _ack Then                                  'если пакет не передан
      Goto Transieve3
   End If
   Close #file
   'ВНИМАНИЕ, ПАКОСТЬ
         End
   'ВНИМАНИЕ, ПАКОСТЬ
End Sub
')
'(
Sub File_print()
   Const _soh = &H01                                        'Start of header
   Const _eop = &H17                                        'End of packet
   Const _eot = &H04                                        'End of Transmission
   Const _ack = &H06                                        'Acknowledge
   Const _nack = &H15                                       'Not Acknowledge
   Const _c = &H43                                          'ACII "C"
   Const _can = &H18
   Const Filename = "lb.bmp"
   Const File = 14
   Local Pack_amount As Long
   Local I As Long : Local K As Long : Local Pack_modul As Byte
   Local Pack_number1 As Byte : Local Pack_number2 As Byte : Local Pack_crc16 As Word
   Local Inp_key As Byte

   Led_r1 = 1
   Open Filename For Binary As #file
   Clear Serialin                                           'очищаю буфер ввода
   Pack_amount = Filelen(filename)
   Pack_amount = Pack_amount \ 128                          'количество пакетов по 128 байт
   Pack_modul = Pack_amount Mod 128                         'остаток данных
   Pack_number1 = 1
   If Pack_amount <> 0 Then

      For I = 1 To Pack_amount
         For K = 1 To 128
            Get #file , Packet(i)
         Next
         Pack_number2 = &HFF - Pack_number1                 'в сумме pack_number1+pack_number2=0xFF
         Pack_crc16 = Crc16(packet(1) , 128)                'контрольная сумма base64 строки
         Rotate Pack_crc16 , Left , 8
Transieve:
         Ucsrb.rxen = 0
            Printbin _soh ; Pack_number1 ; Pack_number2
            Printbin Packet(1) ; 128
            Printbin Pack_crc16
            While Ucsra.udre = 0
               Led_r2 = 1
            Wend
            Led_g2 = 1
            Clear Serialin
         Ucsrb.rxen = 1
         Inp_key = Waitkey()                                'ответ
         If Inp_key <> _ack Then                            'если пакет не передан
            Goto Transieve
         Else
            If Pack_number1 <> 255 Then
               Incr Pack_number1
            Else
               Pack_number1 = 0
            End If
         End If
      Next
   End If

   If Pack_modul <> 0 Then                                  'передаю остаток
      For I = 1 To Pack_modul
         Get #file , Packet(i)
      Next
      Incr Pack_modul
      For I = Pack_modul To 128
         Packet(i) = &H1A
      Next
      Pack_number2 = &HFF - Pack_number1                    'в сумме pack_number1+pack_number2=0xFF
      Pack_crc16 = Crc16(packet(1) , 128)                   'контрольная сумма base64 строки
      Rotate Pack_crc16 , Left , 8
Transieve2:
      Ucsrb.rxen = 0
            Printbin _soh ; Pack_number1 ; Pack_number2
            Printbin Packet(1) ; 128
            Printbin Pack_crc16
      Ucsrb.rxen = 1

      Clear Serialin
      Inp_key = Waitkey()                                   'ответ
      If Inp_key <> _ack Then                               'если пакет не передан
         Goto Transieve2
      End If
   End If

Transieve3:                                                 'передаю признак конца передачи
   Ucsrb.rxen = 0
      Printbin _eot
   Ucsrb.rxen = 1
   Waitms 1
   Clear Serialin
   Inp_key = Waitkey()                                      'ответ
   If Inp_key <> _ack Then                                  'если пакет не передан
      Goto Transieve3
   End If
   Close #file
   'ВНИМАНИЕ, ПАКОСТЬ
         End
   'ВНИМАНИЕ, ПАКОСТЬ
End Sub

')


'(
   Ucsr0b.rxen0 = 0
   Print Text_priem;                                        '  #1 ,данные
   Print
   Ucsr0b.rxen0 = 1
')

'(
Sub Get_file(filename As String)
'ВНИМАНИЕ, СИМВОЛ ПРИЕМА ДАННЫХ = ">"
'СИМВОЛ ТУПОЙ СТРОКИ = "?"
'А НАФИГА ВЕРИФИКАЦИЯ ВВОДА-ТО? МОЖНО И БЕЗ CRC8
'Gspcinput = 20 bytes
   'Const M_len = 20                                       'максимальная длина приема
   Const Redy = ">"
   Const Error = "?"
   'Const Postfix = "::"                                     'символ(строка) конца передачи. важно, чтобы не использовались символы base64
   Local I As Byte
   Local Bbuf As Byte
   Local Bbuf2 As Byte
   'File Alias 14
   'Sbuf Alias Gspcinput
   Close #file
   Open Filename For Binary As #file
   If Gbdoserror = 0 Then
         Print Redy ;
         Waitms 6
         Clear Serialin
         Input Sbuf Noecho
         Bbuf2 = Len(sbuf)
         Decr Bbuf2
         Bbuf = Right(sbuf , 1)                             'сохраняю чексумму и исключаю из строки
         Sbuf = Left(sbuf , Bbuf2)
         Sbuf = Base64dec(sbuf)                             'декод из base64

  ' продолжаем торжество , нужно Sbuf перегнать в файл


   Else
      Print "?81"
   End If
End Sub


Sub Print_file(filename As String)
'Gspcinput = 20 bytes
   Const Max_len = 20                                       'максимальная длина ответа, исключая префикс и crc8
   Const Prefix = ":"
   Const Postfix = "::"                                     'символ(строка) конца передачи. важно, чтобы не использовались символы base64
   Local I As Byte
   Local Bbuf As Byte
   File Alias 14
   Sbuf Alias Gspcinput
   Open Filename For Binary As #file
   If Gbdoserror = 0 Then
      Sbuf = ""
      I = 1
      Do
         Get #file , Bbuf
         If I < Max_len Then
            Mid(sbuf , I , 1) = Bbuf
         Else                                               'данные (строка) готовы для отправки
            Print Prefix ; Base64enc(sbuf)                  'отправляется префикс+(при кодировании на каждыые 3байта добавляется ещё 1)+контрольная сумма(1байт)
            I = 1
            'Sbuf = ""
         End If
         Incr I
      Loop Until Eof(#file) <> 0
      If Sbuf <> "" Then                                    'если последний кусочек не отослали
         Print Prefix ; Base64enc(sbuf)
      End If
      Sbuf = ""
      Print Postfix                                         'передаю символ конца передачи
      Close #file
   Else
      Print "?81"
   End If
End Sub
')



'(
Const Maxword =(2 ^ Maxwordbit) * 2                         '128
Const Maxwordshift = Maxwordbit + 1


$crystal = 8000000
$baud = 57600                                               'this loader uses serial com
'It is VERY IMPORTANT that the baud rate matches the one of the boot loader
'do not try to use buffered com as we can not use interrupts
'Dim the used variables
Dim Bstatus As Byte , Bretries As Byte , Bblock As Byte , Bblocklocal As Byte
Dim Bcsum1 As Byte , Bcsum2 As Byte , Buf(128) As Byte , Csum As Byte
Dim J As Byte , Spmcrval As Byte                            ' self program command byte value
Dim Z As Word                                               'this is the Z pointer word
Dim Vl As Byte , Vh As Byte                                 ' these bytes are used for the data values
Dim Wrd As Byte , Page As Byte                              'these vars contain the page and word address
'Mega 88 : 32 words, 128 pages

Disable Interrupts                                          'we do not use ints
Waitms 1000                                                 'wait 1 sec
'We start with receiving a file. The PC must send this binary file
'some constants used in serial com
Const Nak = &H15
Const Ack = &H06
Const Can = &H18
'we use some leds as indication in this sample , you might want to remove it
Config Portb = Output
Portb = 255                                                 'the stk200 has inverted logic for the leds
$timeout = 1000000                                          'we use a timeout
'Do
 Bstatus = Waitkey()                                        'wait for the loader to send a byte
Print Chr(bstatus);
If Bstatus = 123 Then                                       'did we received value 123 ?
    Goto Loader
End If
'Loop


For J = 1 To 10                                             'this is a simple indication that we start the normal reset vector
  Toggle Portb : Waitms 100
Next
Goto _reset                                                 'goto the normal reset vector at address 0


'this is the loader routine. It is a Xmodem-checksum reception routine
Loader:
For J = 1 To 3                                              'this is a simple indication that we start the normal reset vector
  Toggle Portb : Waitms 500
Next
Spmcrval = 3 : Gosub Do_spm                                 ' erase  the first page
Spmcrval = 17 : Gosub Do_spm                                ' re-enable page
Bretries = 10                                               'number of retries
Do
 Csum = 0                                                   'checksum is 0 when we start
Print Chr(nak);                                             ' firt time send a nack
Do
   Bstatus = Waitkey()                                      'wait for statuse byte
  Select Case Bstatus
      Case 1:                                               ' start of heading, PC is ready to send
          Incr Bblocklocal                                  'increase local block count
           Csum = 1                                         'checksum is 1
           Bblock = Waitkey() : Csum = Csum + Bblock        'get block
           Bcsum1 = Waitkey() : Csum = Csum + Bcsum1        'get checksum first byte
          For J = 1 To 128                                  'get 128 bytes
             Buf(j) = Waitkey() : Csum = Csum + Buf(j)
          Next
           Bcsum2 = Waitkey()                               'get second checksum byte
          If Bblocklocal = Bblock Then                      'are the blocks the same?
              If Bcsum2 = Csum Then                         'is the checksum the same?
                Gosub Writepage                             'yes go write the page
                Print Chr(ack);                             'acknowledge
              Else                                          'no match so send nak
                Print Chr(nak);
              End If
          Else
              Print Chr(nak);                               'blocks do not match
          End If
      Case 4:                                               ' end of transmission , file is transmitted
            Print Chr(ack);                                 ' send ack and ready
            Portb.3 = 0                                     ' simple indication that we are finished and ok
            Goto _reset                                     ' start new program
      Case &H18:                                            ' PC aborts transmission
            Goto _reset                                     ' ready
      Case Else
        Exit Do                                             ' no valid data
  End Select
Loop
If Bretries > 0 Then                                        'attempte left?
    Waitms 1000
    Decr Bretries                                           'decrease attempts
Else
    Goto _reset                                             'reset chip
End If
Loop

'write one or more pages
Writepage:

  For J = 1 To 128 Step 2                                   'we write 2 bytes into a page
     Vl = Buf(j) : Vh = Buf(j + 1)                          'get Low and High bytes
    lds r0, {vl}                                            'store them into r0 and r1 registers
    lds r1, {vh}
     Spmcrval = 1 : Gosub Do_spm                            'write value into page at word address
     Wrd = Wrd + 2                                          ' word address increases with 2 because LS bit of Z is not used
    If Wrd = Maxword Then                                   ' page is full
         Wrd = 0                                            'Z pointer needs wrd to be 0
         Spmcrval = 5 : Gosub Do_spm                        'write page
         Page = Page + 1                                    'next page
         Spmcrval = 3 : Gosub Do_spm                        ' erase  next page
         Spmcrval = 17 : Gosub Do_spm                       ' re-enable page
    End If
  Next
  Toggle Portb.2 : Waitms 10 : Toggle Portb.2               'indication that we write
Return

Do_spm:
Bitwait Spmcsr.selfprgen , Reset                            ' check for previous SPM complete
Bitwait Eecr.eepe , Reset                                   'wait for eeprom

 Z = Page                                                   'make equal to page
Shift Z , Left , Maxwordshift                               'shift to proper place
 Z = Z + Wrd                                                'add word
lds r30,{Z}
lds r31,{Z+1}

 Spmcsr = Spmcrval                                          'assign register
spm                                                         'this is an asm instruction
nop
nop
Return
')