' Release Date 2009-01-11
' Driver and AVR-DOS must be configured first in main program
' author: MiBBiM

'**********MINIBOT CONFIGS**********

''$prog &HFF , &HAE , &HC9 , &H00

$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 9600

$include "Config_MMC.bas"
$include "Config_AVR-DOS.BAS"

Config Serialin = Buffered , Size = 10

$hwstack = 64
$swstack = 64
$framesize = 64

Config Pind.7 = Output
Config Pind.6 = Output
Declare Sub Music_play(byval Filename As String)

Enable Interrupts

'Timer/Counter 2 initialization
'Clock source: System Clock
'Clock value: 7372,800 kHz
'Prescaler = 1
'Mode: Fast PWM top=FFh
'OC2 output: Inverted PWM
Assr = &H00
Tccr2 = &H79
Tcnt2 = &H00

'Timer(s)/Counter(s) Interrupt(s) initialization
'overflow2 interrupt
'Timsk = &H40

'определяю устройства в системе
Const Exist_sd = 1
Const Exist_music = 1

Gbdoserror = Initfilesystem(1)
Do
   Call Music_play( "t12.wav")
   
Loop

#if Exist_sd And Exist_music
Sub Music_play(byval Filename As String)
   Const Delay_us = 0                                       ' выбирается опытным путем
   Local Buf As Byte
   Open Filename For Binary As #4
   Do
      Get #4 , Buf
      Ocr2 = Buf
      Waitus Delay_us
   Loop Until Eof(#4) <> 0
End Sub
#endif