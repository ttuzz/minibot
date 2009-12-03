' Release Date 2009-01-11
' Driver and AVR-DOS must be configured first in main program
' author Josef Franz V?gel
' author: MiBBiM

'**********MINIBOT CONFIGS**********
'фусибиты
'$prog &HFF , &HE4 , &HD9 , &H00

'камень
$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 115200
Config Serialin = Buffered , Size = 20

'делаю супермегабиг+ стек
$hwstack = 64
$swstack = 64
$framesize = 64

'светодиоды
Config Pinc.4 = Output : Led_r1 Alias Portc.4
Config Pinc.5 = Output : Led_g1 Alias Portc.5
Config Pinc.6 = Output : Led_r2 Alias Portc.6
Config Pinc.7 = Output : Led_g2 Alias Portc.7

'двигатели с ШИМом
Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down
Config Timer0 = Timer , Prescale = 8
Pwm1a = 0
Pwm1b = 0
Config Pinc.2 = Output : Drl Alias Portc.2                  ' DrL
Config Pinc.3 = Output : Drr Alias Portc.3                  ' DrR
Config Pind.4 = Output                                      'PWM L
Config Pind.5 = Output                                      'PWM R
Config Pind.3 = Input                                       'приемник бампера
Config Pind.6 = Output : Led_ir Alias Portd.6               'ик локаторы, светодиоды
Config Pina.2 = Input : Enc_l Alias Pina.2                  'фототранзистор


Dim Cnt As Byte
Cnt = 0
On Ovf0 Tim0_isr

      Print "MiniBot v.2 is configured"
      Led_g1 = 1
      Led_ir = 1
      Enable Timer0
      Stop Timer0
      Enable Interrupts
'///**********MINIBOT CONFIGS**********

Do
   If Enc_l = 1 Then
      Led_r2 = 1
   Else
      Led_r2 = 0
   End If
Loop

Tim0_isr:
   'Cnt = Cnt + 1
   'If Cnt = 12 Then
   '   Toggle Portd.6
   '   Cnt = 0
   'End If
Return

End