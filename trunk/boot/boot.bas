'----------------------------------------------------------------
'                          (c) 1995-2007, MCS
'                        Bootloader.bas
'  This sample demonstrates how you can write your own bootloader
'  in BASCOM BASIC
'  VERSION 2 of the BOOTLOADER. The waiting for the NAK is stretched
'  further a bug was resolved for the M64/M128 that have a big page size
'-----------------------------------------------------------------
'This sample will be extended to support other chips with bootloader
'The loader is supported from the IDE

$crystal = 7372800                                          '8000000
$baud = 115200                                              '38400                                             'this loader uses serial com
' Не использовать буферизованный ввод, ибо прерывания ЗАПРЕЩЕНЫ

$regfile = "m32def.dat"

' процедуры
Declare Sub Chr_print(byval S As Byte)

' mega32
$loader = $3c00                                             ' 1024 слова занимает бут
Const Maxwordbit = 6                                        ' Z6 is maximum bit
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0


Const Maxword =(2 ^ Maxwordbit) * 2                         ' 128
Const Maxwordshift = Maxwordbit + 1

' Используемые переменные
Dim Bstatus As Byte , Bretries As Byte , Bblock As Byte , Bblocklocal As Byte
Dim Bcsum1 As Byte , Bcsum2 As Byte , Buf(128) As Byte , Csum As Byte
Dim J As Byte , Spmcrval As Byte                            ' self program command byte value

Dim Z As Long                                               ' Z указатель
Dim Vl As Byte , Vh As Byte                                 ' Два байта будут использованы для данных
Dim Wrd As Word , Page As Word                              ' Адреса страницы и слова
Dim Bkind As Byte , Bstarted As Byte

Disable Interrupts                                          ' Прерывания не используются!!!


'Waitms 100                                                  'wait 100 msec sec
'We start with receiving a file. The PC must send this binary file

' Константы для управляющих символов
Const Nak = &H15
Const Ack = &H06
Const Can = &H18

' Светодиод для индикации процесса. Мигающий красный - прошивка, горящий зеленый - успешное завершение
Config Pinc.4 = Output : Led_r1 Alias Portc.4 : Led_r1 = 0
Config Pinc.5 = Output : Led_g1 Alias Portc.5 : Led_g1 = 0

'$timeout = 400000                                           ' Таймаут для выхода
' Если лоадер сбоит, увеличиваем значение таймаута

Bretries = 5                                                ' Пробуем 5 раз
Testfor123:
Bstatus = Waitkey()                                         'wait for the loader to send a byte

If Bstatus = 123 Then                                       ' "{", 0x7B
   Call Chr_print(ack)
   Bkind = 0                                                ' Переход в режим FLASH лодера, Bkind = 0
   Goto Loader
Elseif Bstatus = 124 Then                                   ' "|"
   Call Chr_print(ack)
   Bkind = 1                                                ' Переход в режим EPPROM лодера, Bkind = 1
   Goto Loader
Elseif Bstatus <> 0 Then
   Decr Bretries
   If Bretries <> 0 Then Goto Testfor123                    ' Неверный символ, пробуем ещё раз
End If

For J = 1 To 10                                             ' Простая индикация того, что мы переходим по нормальному ресет вектору 0x0000
   Toggle Led_r1 : Waitms 100
Next
Goto _reset                                                 ' Переход по адресу 0x0000 на начало программы


' Процедура лоадера, реализует Xmodem-checksum
Loader:
  Do
     Bstatus = Waitkey()
  Loop Until Bstatus = 125                                  ' Очистка буфера


  For J = 1 To 3                                            ' Простая индикация того, что мы переходим по нормальному ресет вектору 0x0000 (!!!) или таки прошли в бутлоадер??
     Toggle Led_r1 : Waitms 50
  Next

  If Bkind = 0 Then                                         ' Если в режиме FLASH программатора
     Spmcrval = 3 : Gosub Do_spm                            ' стирание страницы по адресу Z
     Spmcrval = 17 : Gosub Do_spm                           ' разрешить доступ к RWW памяти (стирание буфера)
  End If


Bretries = 10                                               ' Количество попыток

Do
  Bstarted = 0                                              ' Мы ещё не стартовали
  Csum = 0                                                  ' Чексумма = 0 при старте
  Call Chr_print(nak)                                       ' Первый раз шлем nack
  Do
    Bstatus = Waitkey()                                     ' Ждем статус-байт
    Select Case Bstatus
       Case 1:                                              ' Начало заголовка, PC готов слать данные
            Incr Bblocklocal                                'increase local block count
            Csum = 1                                        'checksum is 1
            Bblock = Waitkey() : Csum = Csum + Bblock       'get block
            Bcsum1 = Waitkey() : Csum = Csum + Bcsum1       'get checksum first byte
            For J = 1 To 128                                'get 128 bytes
              Buf(j) = Waitkey() : Csum = Csum + Buf(j)
            Next
            Bcsum2 = Waitkey()                              'get second checksum byte
            If Bblocklocal = Bblock And Bcsum2 = Csum Then  'are the blocks and the checksum the same?
               Gosub Writepage                              'yes go write the page
               Call Chr_print(ack)                          'acknowledge
            Else
               Call Chr_print(nak)                          'blocks do not match, so send nack
            End If
       Case 4:                                              ' end of transmission , file is transmitted
             If Wrd > 0 And Bkind = 0 Then                  'if there was something left in the page
                 Wrd = 0                                    'Z pointer needs wrd to be 0
                 Spmcrval = 5 : Gosub Do_spm                'write page
                 Spmcrval = 17 : Gosub Do_spm               ' re-enable page
             End If
             Call Chr_print(ack)                            ' send ack and ready

             Led_g1 = 1                                     ' simple indication that we are finished and ok
             Waitms 20
             Goto _reset                                    ' start new program
       Case Can:                                            ' PC aborts transmission
             Goto _reset                                    ' ready
       Case Else
          Exit Do                                           ' no valid data
    End Select
  Loop
  If Bretries > 0 Then                                      'attempte left?
     Waitms 1000
     Decr Bretries                                          'decrease attempts
  Else
     Goto _reset                                            'reset chip
  End If
Loop


'(
Spmcrval:
1 - запись регистровой пары R0 : R1 в Z
3 - стирание страницы по адресу Z
5 - запись страницы по адресу Z
17 - разрешить доступ к Rww памяти(стирание буфера)

')

'write one or more pages
Writepage:
 If Bkind = 0 Then                                          ' FLASH лоадер
   For J = 1 To 128 Step 2                                  'we write 2 bytes into a page
      Vl = Buf(j) : Vh = Buf(j + 1)                         'get Low and High bytes
      lds r0, {vl}                                          'store them into r0 and r1 registers
      lds r1, {vh}
      Spmcrval = 1 : Gosub Do_spm                           'write value into page at word address
      Wrd = Wrd + 2                                         ' word address increases with 2 because LS bit of Z is not used
      If Wrd = Maxword Then                                 ' page is full
          Wrd = 0                                           'Z pointer needs wrd to be 0
          Spmcrval = 5 : Gosub Do_spm                       'write page
          Spmcrval = 17 : Gosub Do_spm                      ' re-enable page

          Page = Page + 1                                   'next page
          Spmcrval = 3 : Gosub Do_spm                       ' erase  next page
          Spmcrval = 17 : Gosub Do_spm                      ' re-enable page
      End If
   Next

 Else                                                       ' EEPROM лоадер
     For J = 1 To 128
       Writeeeprom Buf(j) , Wrd
       Wrd = Wrd + 1
     Next
 End If
 Toggle Led_r1 : Waitms 10 : Toggle Led_r1                  'indication that we write
Return


Do_spm:
  Bitwait Spmcsr.0 , Reset                                  ' check for previous SPM complete
  Bitwait Eecr.1 , Reset                                    'wait for eeprom

  Z = Page                                                  'make equal to page
  Shift Z , Left , Maxwordshift                             'shift to proper place
  Z = Z + Wrd                                               'add word
  lds r30,{Z}
  lds r31,{Z+1}

  #if _romsize > 65536
      lds r24,{Z+2}
      sts rampz,r24                                         ' we need to set rampz also for the M128
  #endif

  Spmcsr = Spmcrval                                         'assign register
  spm                                                       'this is an asm instruction
  nop
  nop
Return


Sub Chr_print(byval S As Byte)
   Reset Ucsrb.rxen
      Bitwait Ucsra.udre , Set
      Udr = S
      Set Ucsra.txc                                         ' очищаю флаг прерывания
      Bitwait Ucsra.txc , Set                               ' жду пока передатчик не передаст весь пакет (из внутреннего буфера, не UDR)
   Set Ucsrb.rxen
End Sub