$regfile = "m16DEF.dat"
$crystal = 4000000
$baud = 115200

'двигатели с ШИМом
Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down
Config Pind.4 = Output : Config Pind.5 = Output             'PWM
Pwm1a = 0 : Pwm1b = 0

Portc = 0
Config Pinc.0 = Output : Config Pinc.1 = Output
Config Pinc.2 = Output : Config Pinc.3 = Output

Const M_stop = &H00
Const Ml_forw = &H08 : Const Ml_backw = &H04
Const Mr_forw = &H02 : Const Mr_backw = &H01

Declare Sub Led_set(byval B As Byte)
Declare Sub Led_reset(byval B As Byte)

Gosub Led_config

Config Adc = Single , Prescaler = Auto , Reference = Internal



Dim Speed As Byte
Dim Value As Long
Dim I As Byte

'Portc = Ml_forw Or Mr_forw
'Pwm1a = 255 : Pwm1b = 255

Const Threshold = 900

                                                                                               
Start Adc

Do
   For I = 0 To 7
      Value = Getadc(i)
      If Value > Threshold Then
         Call Led_set(i)
      Else
         Call Led_reset(i)
      End If
      Waitms 10
   Next


'(
' св диоды
   For Speed = 0 To 7
      Call Led_set(speed)
      Wait 1
      Call Led_reset(speed)
   Next

   For Speed = 7 To 0 Step -1
      Call Led_set(speed)
      Wait 1
      Call Led_reset(speed)
   Next
')
'(
' моторы
   Portc = Ml_forw Or Mr_forw
   For Speed = 75 To 255
      Pwm1b = Speed
      Pwm1a = Speed
      Waitms 250
   Next
   Waitms 500

   For Speed = 255 To 75 Step -1
      Pwm1b = Speed
      Pwm1a = Speed
      Waitms 250
   Next
   Waitms 500

   Portc = Ml_backw Or Mr_backw
   For Speed = 75 To 255
      Pwm1b = Speed
      Pwm1a = Speed
      Waitms 250
   Next
   Waitms 500

   For Speed = 255 To 75 Step -1
      Pwm1b = Speed
      Pwm1a = Speed
      Waitms 250
   Next
   Waitms 500
')
Loop

Sub Led_set(byval B As Byte)
   Select Case B
   Case 0:
      Set Portd.0
   Case 1:
      Set Portd.1
   Case 2:
      Set Portd.2
   Case 3:
      Set Portd.3
   Case 4:
      Set Portb.0
   Case 5:
      Set Portb.1
   Case 6:
      Set Portd.6
   Case 7:
      Set Portd.7
   End Select
End Sub

Sub Led_reset(byval B As Byte)
   Select Case B
   Case 0:
      Reset Portd.0
   Case 1:
      Reset Portd.1
   Case 2:
      Reset Portd.2
   Case 3:
      Reset Portd.3
   Case 4:
      Reset Portb.0
   Case 5:
      Reset Portb.1
   Case 6:
      Reset Portd.6
   Case 7:
      Reset Portd.7
   End Select
End Sub

Led_config:
   ' отключаю USART
   Reset Ucsrb.rxen
   Reset Ucsrb.txen
   Config Pind.0 = Output : Config Pind.1 = Output : Config Pind.2 = Output
   Config Pind.3 = Output : Config Pinb.0 = Output : Config Pinb.1 = Output
   Config Pind.6 = Output : Config Pind.7 = Output
Return






