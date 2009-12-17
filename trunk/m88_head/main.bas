'$prog &HFF , &HE0 , &HDD , &HF9                             ' для минибота 2.x
$regfile = "m88DEF.dat"
$crystal = 7372800
$baud = 115200
$hwstack = 64
$swstack = 64
$framesize = 64

' Голова
Config Adc = Single , Prescaler = Auto , Reference = Internal       'опора 2.04В
   Dim дистанция As Word
   Dim дифф As Integer

Config Servos = 1 , Servo1 = Portb.2 , Reload = 20
   Config Pinb.2 = Output
'Config Timer1 = Pwm , Pwm = 10 , Prescale = 64 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down
'   Servo1 Alias Pwm1b
   'Config Pinb.2 = Output
   Dim пеленг As Byte
   Dim расстояния(7) As Word
   Dim буфер As Byte

' Связь
Dim Text As String * 15                                     'строка для отправки/приема (длина строки 15 символов)
Dim Text_tmp As String * 15
Dim Txt_ As Byte

'Enable Urxc
On Urxc Getchar                                             'переопределяем прерывание приема usart


Waitms 1000
Print
Print "Start Mega88 MiniBot 2.1"
Enable Interrupts                                           'разрешаем прерывания


Do
   основной_цикл:
   Gosub сканирование
Loop

Getchar:
   Txt_ = Inkey()
   If Txt_ > 13 Then                                        'если пришел не служебный символ
      Text_tmp = Chr(txt_)
      Text = Text + Text_tmp
   End If
   If Txt_ = 13 Then                                        'нажали ввод
         'строка в Text принята
   End If
   If Text = "M88_Scan_on" Then Gosub сканирование
   If Text = "M88_Scan_off" Then Gosub сканирование_стоп
Return

сканирование:
Do
   For пеленг = 35 To 65 Step 5
     Servo(1) = пеленг
     'Servo1 = пеленг
     Waitms 50
     Gosub Sharp
   Next
   For пеленг = 65 To 35 Step -5
     Servo(1) = пеленг
     'Servo1 = пеленг
     Waitms 50
     Gosub Sharp
   Next
Loop
Return

сканирование_стоп:
   Servo(1) = 50
   'Servo1 = пеленг
   Goto основной_цикл
Return

Sharp:
  Const порог_срабатывания = 70
   Start Adc
   дистанция = Getadc(0) : дистанция = Getadc(0) : дистанция = Getadc(0)
   Stop Adc
   буфер = пеленг - 30 : буфер = буфер \ 5
   дифф = дистанция - расстояния(буфер)
   дифф = Abs(дифф)
   расстояния(буфер) = дистанция
   If дифф > порог_срабатывания Then
      Print Chr(13);
      дистанция = дистанция / 10
      Print пеленг ; "-" ; дистанция ;
   End If
Return