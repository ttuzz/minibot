' Release Date 2009-01-11
' Driver and AVR-DOS must be configured first in main program
' author Josef Franz V?gel
' author: MiBBiM

'**********MINIBOT CONFIGS**********
'фусибиты
$prog &HFF , &HE4 , &HD9 , &H00

'камень
$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 115200
Config Serialin = Buffered , Size = 20

'делаю супермегабиг+ стек
$hwstack = 64
$swstack = 64
$framesize = 64

'библиотеки AVR-DOS и SD
$include "Config_MMC.bas"
$include "Config_AVR-DOS.BAS"

'если перезагрузились софтово(через собачку)
Stop Watchdog

'светодиоды
Config Pinc.4 = Output : Led_r1 Alias Portc.4
Config Pinc.5 = Output : Led_g1 Alias Portc.5
Config Pinc.6 = Output : Led_r2 Alias Portc.6
Config Pinc.7 = Output : Led_g2 Alias Portc.7

'двигатели с ШИМом
Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down
Pwm1a = 89
Pwm1b = 89
'Config Pinc.2 = Output : Drl Alias Portc.2                  ' DrL
'Config Pinc.3 = Output : Drr Alias Portc.3                  ' DrR
'Config Pind.4 = Output                                      'PWM L
'Config Pind.5 = Output                                      'PWM R

'останавливаю двигатели



      Wait 2

      Print "MiniBot v.2 is configured"

      Led_g1 = 1

      Enable Interrupts
'///**********MINIBOT CONFIGS**********

Do
Loop