' Release Date 2009-01-11
' Driver and AVR-DOS must be configured first in main program
' author Josef Franz V?gel
' author: MiBBiM

'**********MINIBOT CONFIGS**********
'камень
$regfile = "m8DEF.dat"
$crystal = 7372800
$baud = 9600
Config Serialin = Buffered , Size = 20

Config Servos = 1 , Servo1 = Portc.0 , Reload = 20
Config Portc.0 = Output

'делаю супермегабиг+ стек
$hwstack = 64
$swstack = 64
$framesize = 64

      Waitms 250

      Print "MiniBot v.2 is configured"

      Enable Interrupts
'///**********MINIBOT CONFIGS**********

Do
   ' крайние положения задавать константами
   'Servo(1) = 38                                            '-90 или 1мс
   'Servo(1) = 79                                            '+90 или 2мс
   Servo(1) = 38
   Waitms 500
   Dim I As Byte
   For I = 40 To 79
      Servo(1) = I
      Waitms 250
   Next
   Wait 1
Loop
