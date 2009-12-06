'(
Potrzebuje Emulator Ds18b20 Na Atmega8 - Mam Na Pc Program Do Odczytu Temp I Chcialem W Tym Programie Dodac Inne Parametry(np Wilgotnosc ) Ale Nie Zmieniajac Programu - W Scrachpadzie Bede Wisylal Inne Dane Nie Temperature.(w Bajtach Temperatury Lub Bajtach Uzytkownika Wolnych 2szt) Aktualnie Uzywam "lampomitari" , Ale Napisalem Przerobke Programu Tempsense Z Sdk Tmex Dallasa W Delphi Aby Miec Mozliwosc Kontroli Wszystkich Bajtow Nie Tylko Temperatury.
No I Algorytm Dallasa Jest Wielowatkowy I Dodatkowo Obciazenie Procesora Jest Rzedu 2 -4% , A Nie Jak W Lampomitati 95 -100%.
Program Tempsense Adaptowalem Tak Ze Dziala Z Ds18b20 I Zapisuje Dane W Konwencji(zgodnie Z) Standardem Lampomitari - Przydatne Do Analizy Zmian Przebiegu Wykresow.
Do Testowania Uzywam Tez Ibutton Viewer32.



Znalazlem Kilka Rozwiazan W Sieci I Probuje Jakos Przystosowac Do Atmega8 - Najpierw Kupilem Potem Sie Okazalo Ze Sa Gotowe Rozwiazania W C / Asm / Bascom Na Pic , Attiny Lub Atmega88

Najprosciej Bylo By Chyba Adaptowac Wersje Z Atmega88 Ale Jest W W Cv Avr - Nie Znam C , Pozatym Nie Potrafie Wybrac Programatora Zgodnego Z Moim - Mam Podrobke Stk200 Na Lpt - A Tam Tylko Opcje Usb Lub Rs232 Podobnie Jak Avr Studio I Gcc.(czy Mozna Cos Z Tym Zrobicprint )

Znalazlem Rozwiazanie [bascom] Na Attiny I Atmega32 - Przerabiam Na Atmega8 - No I Mam Problem Z Poprawnym Wyslaniem Scrachpad .

Numer Seryjny Jest Odczytywany Poprawnie.

Jak Wyglada Procedura Wyslania Scratchpadu Ze Strony Slave Print Print Print Print Print

Wysylam Przez Sendbyte I Przez Senid I Nicprint
')
'****************************************************************
'* Name : Tiny_DS2450.BAS *
'* Author : Vladimir I. Yershov *
'* *
'* Date : 21.12.2008 *
'* Version : 1.0 *
'* Notes : Firmware for Tiny and Mega AVR to emulate Dallas *
'* DS2450 1-Wire Quad A/D Converter *
'* : *
'****************************************************************

$regfile = "M88DEF.DAT"
$crystal = 12000000                                         ' orginalnie 8 mhz

Config Adc = Single , Prescaler = Auto                      ' nie uzywane bo ds18b20 a nie ds2450
Config Timer0 = Timer , Prescale = 64


Const Dqpin = 2
Const Ipin = 0                                              ' value in DDRB for input
Const Opin = 1                                              ' value in DDRB for output

Timer Alias Tcnt0

Dq Alias Pind.dqpin

' Commands
Const Search_rom = &HF0
Const Skip_rom = &HCC
Const Match_rom = &H55
Const Read_rom = &H33
Const Writemem = &H55
Const Convert = &H3C
Const Read_mem = &HAA
Const Bootload = &HEE
Const Write_epr = &HE0
Const Convertt = &H44                                       'dodane ds18b20
Const Readscratchpad = &HBE                                 'dodane ds18b20
Const Recalle2 = &HB8
' Timings

Const Owpresent = 150                                       ' 60us < OWPresent < 240us
Const Owpause = 50                                          ' 15us < OWPause < 60us
Const Owstrobe = 10                                         ' org 15 od 9 rusza ' read Dq value after Owstrobe us '12 '10 4MHz 12 8 MHz
Const Owdata = 17
' Org 25 od 10 sie pojawia
' Valid output data for Owdata us '20 '15 '12 '7 12

' Timer Delays

Const T1reset = 60                                          'T1us * 490 Min Reset width
Const Timeout = 120                                         'T1us * 970 Max Reset width

' Allocate variables

Dim I As Byte
Dim B As Byte
Dim C As Byte

Dim Inmask As Byte
Dim Readout As Byte
Dim Addrlo As Byte
Dim Adcnum As Byte
Dim Addtemp As Byte

Dim Myrom(8) As Byte
Dim Mytemp(9) As Byte

Dim Crc16_hi As Byte
Dim Crc16_lo As Byte

Dim Ram(32) As Byte
Dim Ramw(16) As Word                                        ' At ' Ram(8) Overlay
Dim Ad_result As Word
Dim Bytedat As Byte
Dim Wreg As Byte

Dim Tstval As Byte
Dim Temp As Byte
Dim Templ As Byte
Dim Temph As Byte
Dim Tempw As Word At Templ Overlay

Dim Overresol As Byte
Dim Oversample As Byte
Dim Overcount As Byte
Dim Overshift As Byte
Dim Normshift As Byte

Dim Bitdat As Bit

Enable Interrupts
Enable Timer0
On Timer0 Isr Nosave

Restore Myrom
For Addrlo = 1 To 8
Read B
Myrom(addrlo) = B
Next Addrlo

Restore Mytemp
For Addtemp = 1 To 9
Read C
Mytemp(addtemp) = C
Next Addtemp

Stop Timer0


Print "start"                                               ' version info

Waitms 500
'-----------------------------------

Mainloop:
Waitreset:

Disable Interrupts
Timer = 0

Waitfall:

L1:
sbis pind, DqPin
rjmp L1
L2:
sbic pind, DqPin
rjmp L2
Timer = 0
Start Timer0

Rwaitrise:

L01:
sbic pind, DqPin
rjmp L01
L02:
sbis pind, DqPin
rjmp L02

Stop Timer0

If Timer < T1reset Then Goto Waitreset
If Timer > Timeout Then Goto Waitreset
' print "reset " ' w terminalu sprawdzam czy przechodzi

Sendpresense:

Waitus Owpause
Ddrd.dqpin = Opin
Waitus Owpresent
Ddrd.dqpin = Ipin
Timer = 0
Enable Interrupts

Readb:
Gosub Readbyte
Readb1:
'print Bytedat
'Gosub Mainloop ' w terminalu sprawdzam o co pyta czy przechodzi
If Bytedat = Match_rom Then Goto Matchrom
If Bytedat = Read_rom Then Goto Readrom
If Bytedat = Search_rom Then Goto Sendrom
If Bytedat = Skip_rom Then Goto Funct
If Bytedat = Convertt Then Goto Pomiarth
If Bytedat = Readscratchpad Then Print "sp"                 'Goto Sendscratchpad raczej tu sie nie pojawi

Goto Readb
End




Isr:
Spl = &H5F
Sph = 1

If Dq = 0 Then
Timer = T1reset

Goto Rwaitrise
Else
Goto Waitreset
End If

Return
'-------------------------------
Readrom:
For B = 1 To 8
Bytedat = Myrom(b)
Gosub Sendbyte
Next B
Goto Readb
'----------------------------------
Matchrom:
For B = 1 To 8
Gosub Readbyte
If Bytedat <> Myrom(b) Then Goto Mainloop
Next B
Funct:
Gosub Readbyte

If Bytedat = Recalle2 Then Goto Mainloop

If Bytedat = Readscratchpad Then Goto Sendscratchpad

If Bytedat = Convertt Then Goto Pomiarth

If Bytedat = Convert Then Goto Conversion

If Bytedat = Read_mem Then Goto Readmem

If Bytedat = Writemem Then Goto Write_mem

If Bytedat = Bootload Then Goto Fwupgrade

' Print Bytedat ' ds18b20v46.delph7 najpier mowi przepisz schpad do ram
' HB8 (184) a potem podaj HBE (190) schpad strata czasu
' nie rob nic wroc do wreset

', trzeba zoptymalizowac kod ds18b20v46






' If Bytedat = Write_epr Then Goto Writeepr

Goto Readb1
'----------------------------------------
Fwupgrade:
Gosub Sendbyte
jmp 0

Readmem:
Crc16_lo = 0
Crc16_hi = 0
B = 0

Gosub Crc_update                                            ' ByteDat = ReadMem

Gosub Readbyte
Addrlo = Bytedat
Gosub Crc_update                                            ' ByteDat = AddrLo

Gosub Readbyte
Gosub Crc_update                                            ' ByteDat = AddrHi
Readloop:
Bytedat = Ram(addrlo + 1)

Gosub Sendbyte
Gosub Crc_update

Incr Addrlo
Incr B

If B = 8 Then Goto Exitreadmem
Goto Readloop
Exitreadmem:
B = 0

Bytedat = Crc16_lo Xor &HFF
Gosub Sendbyte
Bytedat = Crc16_hi Xor &HFF
Gosub Sendbyte

Crc16_lo = 0
Crc16_hi = 0

If Addrlo < 31 Then Goto Readloop

Goto Mainloop

'----------------------------------------
Write_mem:
Crc16_lo = 0 : Crc16_hi = 0

Gosub Crc_update                                            'Bytedat = Writemem

Gosub Readbyte
Addrlo = Bytedat
Gosub Crc_update                                            ' AddrLo

Gosub Readbyte
Gosub Crc_update                                            ' AddrLo

Gosub Readbyte
Ram(addrlo + 1) = Bytedat
Gosub Crc_update                                            ' MemByte

Bytedat = Crc16_lo Xor &HFF
Gosub Sendbyte

Bytedat = Crc16_hi Xor &HFF
Gosub Sendbyte

Bytedat = Ram(addrlo + 1)
Gosub Sendbyte
' ====== END OF FIRST PASS ===========
Writememloop:
Incr Addrlo
Crc16_hi = 0
Crc16_lo = Addrlo                                           ' low (Crc16) = Addrlo

Gosub Readbyte
Ram(addrlo + 1) = Bytedat
Gosub Crc_update

Bytedat = Crc16_lo Xor &HFF
Gosub Sendbyte

Bytedat = Crc16_hi Xor &HFF
Gosub Sendbyte

Bytedat = Ram(addrlo + 1)
Gosub Sendbyte

If Addrlo < 31 Then Goto Writememloop

Goto Mainloop

' =============
Conversion:
Crc16_lo = 0 : Crc16_hi = 0
Gosub Crc_update                                            'ByteDat = Convert

Gosub Readbyte                                              'ByteDat = InMask
Gosub Crc_update

Gosub Readbyte                                              'ByteDat = ReadOut
Gosub Crc_update

Bytedat = Crc16_lo Xor &HFF
Gosub Sendbyte

Bytedat = Crc16_hi Xor &HFF
Gosub Sendbyte

Overresol = 12                                              ' Desired Oversample Resolution
Overshift = Overresol - 10                                  ' Shift Left After Oversampling
Normshift = 6 - Overshift
Oversample = 4 ^ Overshift


For Adcnum = 1 To 4
Ramw(adcnum) = 0
Next Adcnum

Start Adc
For Overcount = 1 To Oversample
For Adcnum = 1 To 4
B = Adcnum - 1
Ad_result = Getadc(b)
Ramw(adcnum) = Ramw(adcnum) + Ad_result
Next Adcnum
Next Overcount
For Adcnum = 1 To 4
Shift Ramw(adcnum) , Right , Overshift
Shift Ramw(adcnum) , Left , Normshift
Next Adcnum

Exit_case:

Stop Adc

Goto Mainloop
'======================================================
Crc_update:

Wreg = Bytedat
Wreg = Wreg Xor Crc16_lo
Temp = Wreg
Wreg = Crc16_hi
Crc16_lo = Wreg
Wreg = 0

If Temp.0 = 1 Then Wreg = &HCC

If Temp.1 = 1 Then Wreg = Wreg Xor &H8D

If Temp.2 = 1 Then Wreg = Wreg Xor &H0F

If Temp.3 = 1 Then Wreg = Wreg Xor &H0A

Crc16_hi = Wreg
Wreg = Wreg And &HF0
Crc16_hi = Crc16_hi Xor Wreg
Crc16_lo = Crc16_lo Xor Wreg
Wreg = 0

If Crc16_hi.3 = 1 Then Wreg = &HCC

If Temp.4 = 1 Then Wreg = Wreg Xor &HCC

If Temp.5 = 1 Then Wreg = Wreg Xor &HD8

If Temp.6 = 1 Then Wreg = Wreg Xor &HF0

If Temp.7 = 1 Then Wreg = Wreg Xor &HA0

Crc16_hi = Crc16_hi Xor Wreg
Wreg = 1

If Crc16_hi.7 = 1 Then Crc16_lo = Crc16_lo Xor Wreg

Return
'---------------------------------
'================================
Readbyte:
For I = 0 To 7

L11:
sbis pind, DqPin
rjmp L11
L12:
sbic pind, DqPin
rjmp L12
Timer = 256 - T1reset
Start Timer0
Rotate Bytedat , Right
Waitus Owstrobe
Bytedat.7 = Dq
Next I
Stop Timer0
Return
'----------------------------------
Sendbyte:
Adcnum = Bytedat
For I = 0 To 7

L21:
sbis pind, DqPin
rjmp L21
L22:
sbic pind, DqPin
rjmp L22
Timer = 256 - T1reset
Start Timer0

If Bytedat.0 = 0 Then Ddrd.dqpin = Opin
Waitus Owdata
Ddrd.dqpin = Ipin

Rotate Bytedat , Right

Next I
Bytedat = Adcnum
Stop Timer0
Return
'-----------------------------------
Sendrom:
' Stop Timer0
For I = 1 To 8
Bytedat = Myrom(i)
For B = 0 To 7
'----------------------------
Sendcbit1:

L31:
sbis pind, DqPin                                            'wH
rjmp L31
L32:
sbic pind, DqPin                                            'wL
rjmp L32

If Bytedat.0 = 0 Then Ddrd.dqpin = Opin
Waitus Owdata
Ddrd.dqpin = Ipin
'----------------------------
Sendcbit2:

L41:
sbis pind, DqPin
rjmp L41
L42:
sbic pind, DqPin
rjmp L42

If Bytedat.0 = 1 Then Ddrd.dqpin = Opin
Waitus Owdata
Ddrd.dqpin = Ipin

'--------------------------
Readcbit:

L51:
sbis pind, DqPin
rjmp L51
L52:
sbic pind, DqPin
rjmp L52

Waitus Owstrobe

Bitdat = Dq

'-------------------------
If Bitdat <> Bytedat.0 Then Goto Mainloop
Rotate Bytedat , Right
Next B
Next I

Goto Readb

Pomiarth:

' Print "pomiar th" ' mam 500ms czasu lub 720 lub moge mierzyc przed detekcja resetu nie wiem kiedy
'Ddrd.dqpin = Ipin
'Waitms 200
Goto Mainloop

Sendscratchpad:
'zrobilem tak bo jak pobieram dane z bytedat = mytemp(i)
' to jako pierwszy bajt wyskakuje mi ostatni bajt myrom(I) nie wiem dlaczebo - bug bascoma czy co
'for c = 0 to 8 ' 9 bajtow ostatni crc8
'bytedat = mytemp(c) ' tablica zawierajaca fikcyjny scrachpad z crc8
'gosub sendbyte
'Next c ' dodalem nawet zmienna c myslac ze mili sie z b


' tak sa prawidlowo przypisane bajty chyba ze maja byc w odwrotnej kolejnosci

'poczekaj na ramke
Bytedat = &H77
'Print Bytedat
Gosub Sendrom
Bytedat = &H01
Gosub Sendbyte
' , Print Bytedat
Bytedat = &H00
Gosub Sendbyte
Bytedat = &H00
Gosub Sendbyte
Bytedat = &H7F
Gosub Sendbyte
Bytedat = &HFF
Gosub Sendbyte
Bytedat = &H09
Gosub Sendbyte
Bytedat = &H10
Gosub Sendbyte
Bytedat = &H00
'Print "wyslane"

' czy moze reab ?'Print "sp"
Goto Mainloop


End



Myrom:
Data &H28 , &H71 , &H2E , &HBA , &H00 , &H00 , &H00 , &H61

Mytemp:
Data &H77 , &H01 , &H00 , &H00 , &H7F , &HFF , &H09 , &H10 , &H00
' 1 2 3 4 5 6 7 8 9crc