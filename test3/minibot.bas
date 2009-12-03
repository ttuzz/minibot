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

Config Pind.7 = Output
Config Pind.6 = Output
Config Timer2 = Pwm , Pwm = On , Prescale = 1 , Compare Pwm = Clear Down
'On Ovf2 Tick

Assr = &H00
Tccr2 = &H79
Tcnt2 = &H00


'Enable Ovf2
'Start Timer2
Enable Interrupts
'Ocr2 = 1

Dim Lbyte1 As Byte
Lbyte1 = Initfilesystem(0)
Open "test.wav" For Binary As #4

Do
   Get #4 , Lbyte1
   Ocr2 = Lbyte1
   Waitus 50
Loop Until Eof(#4) <> 0

Tick:
   'Portd.6 = 1
   'Waitus 100
   'Portd.6 = 0
Return


'Do
'   Waitus 50
'   Get #4 , Lbyte1
'   Ocr2 = Lbyte1
'Loop Until Eof(#4) <> 0
'Stop Timer2
'Close #4