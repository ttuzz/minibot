' Release Date 2009-01-11
' Driver and AVR-DOS must be configured first in main program
' author: MiBBiM

'**********MINIBOT CONFIGS**********
'фусибиты
$prog &HFF , &HE4 , &HD9 , &H00

'камень
$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 115200
Config Serialin = Buffered , Size = 10

'делаю супермегабиг+ стек
$hwstack = 64
$swstack = 64
$framesize = 64

$include "Config_MMC.bas"
$include "Config_AVR-DOS.BAS"

'светодиоды
Config Pinc.4 = Output : Led_r1 Alias Portc.4
Config Pinc.5 = Output : Led_g1 Alias Portc.5
Config Pinc.6 = Output : Led_r2 Alias Portc.6
Config Pinc.7 = Output : Led_g2 Alias Portc.7

'двигатели с ШИМом
Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare B Pwm = Clear Down
Config Pinc.2 = Output : Drl Alias Portc.2                  ' DrL
Config Pind.4 = Output                                      'PWM L

'останавливаю двигатели
Drl = 0
Pwm1b = 0

      Waitms 500
      Print "MiniBot v.2 is configured"
      Led_g1 = 1
      Start Timer1
      Enable Interrupts
'///**********MINIBOT CONFIGS**********


Dim B As Byte

'Do
'   Waitus 125
'   B = Inkey()
'   Pwm1b = B
'Loop

Dim Berrorcode As Byte
Berrorcode = Initfilesystem(0)
If Berrorcode > 0 Then
   Print "Fat Error: " ; Berrorcode
   Led_r2 = 1
Else
   Print "FAT Init"
End If


'Dim L As Long
'L = Filelen( "1.wav")
'If L > 199000 Then
'   Led_g2 = 1
'Else
'   Led_r2 = 1
'End If

Open "1.wav" For Binary As #1

Do
   Do
      Waitus 50                                             'проигрывание 8кгц
      Get #1 , B
      Pwm1b = B
   Loop Until Eof(#1) <> 0
   Pwm1b = 1
   Wait 1
   Seek #1 , Pwm1b
Loop



Dim I As Long
Dim S As String * 10
Dim L As Byte
   Print "com: " ;
   Waitms 6

   Clear Serialin
   Input S Noecho
   Print Chr(10) ; Chr(13) ;
                                           'прием файла
   If S = "ok" Then
      Led_g2 = 1
      Waitms 6

      Kill "1.wav"

      Open "1.wav" For Binary As #1

      For I = 1 To 2000000
         B = Waitkey()
         Put #1 , B
      Next

      Close #1
      Led_r2 = 1
   End If

Do
Loop