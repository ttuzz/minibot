' Release Date 2009-01-11
' Driver and AVR-DOS must be configured first in main program
' author: MiBBiM

'**********MINIBOT CONFIGS**********
'????????
$prog &HFF , &HE4 , &HD9 , &H00

'??????
$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 9600
Config Serialin = Buffered , Size = 10

'????? ????????????+ ????
$hwstack = 64
$swstack = 64
$framesize = 64

$include "Config_MMC.bas"
$include "Config_AVR-DOS.BAS"

'Config Timer2 = Pwm , Pwm = On , Prescale = 1 , Compare Pwm = Clear Down

Config Timer0 = Timer , Prescale = 1
On Ovf0 Tick

Config Pind.7 = Output : Pinout Alias Portd.7
Pinout = 0

      Waitms 500
      Print "MiniBot v.2 is configured"
      Enable Timer0
      Enable Interrupts

Dim Value As Byte
Dim Pwm1 As Byte

Pwm1 = 0

Dim Berrorcode As Byte
Berrorcode = Initfilesystem(0)
If Berrorcode > 0 Then
   Print "Fat Error: " ; Berrorcode
Else
   Print "FAT Init"
End If

Open "test.wav" For Binary As #1
Start Timer0
Do
   Do
      Waitus 50                                             '???????????? 8???
      Get #1 , Value
   Loop Until Eof(#1) <> 0
   Value = 1
   Wait 1
   Seek #1 , Value
Loop


Tick:
Incr Pwm
If Pwm > Value Then
   Pinout = 0
End If

If Pwm = 255 Then
   Pwm = 0
   Pinout = 1
End If

Return