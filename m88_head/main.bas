'$prog &HFF , &HE0 , &HDD , &HF9                             ' для минибота 2.x
$regfile = "m88DEF.dat"
$crystal = 7372800
$baud = 115200
$hwstack = 64
$swstack = 64
$framesize = 64

' Голова
Config Adc = Single , Prescaler = Auto , Reference = Internal       'внешняя опора 2.04В
   Dim дистанция As Word
   Dim дифф As Integer

'Config Servos = 1 , Servo1 = Portb.2 , Reload = 20
'   Config Pinb.2 = Output
Config Timer1 = Pwm , Pwm = 10 , Prescale = 64 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down
   Servo1 Alias Pwm1b
   Config Pinb.2 = Output
   Dim пеленг As Byte
   Dim расстояния(7) As Word
   Dim буфер As Byte
   Dim сканировать As Byte
      Const да = 0
      Const нет = 1
   сканировать = нет

' Функции и процедуры
Declare Sub Printf(byval S As String)
   Dim Text As String * 50                                  ' буфер-строка для отправки (нужна из-за недопустимости вложенных функция)

' Связь
Enable Urxc
On Urxc Getchar                                             'переопределяем прерывание приема usart
   Dim In_string As String * 50                             'строка для приема
   Dim In_key As Byte                                       ' текущий принятый символ

Waitms 1000
   Call Printf( "start minibot mega88" )
   Call Printf( "test")

Enable Interrupts                                           'разрешаем прерывания


Do
   основной_цикл:
   If сканировать = да Then Gosub сканирование
Loop

Getchar:
   In_key = Inkey()
   If In_key <> 13 And In_key <> 10 Then                    ' принимаем пока не встретим конец строки
         In_string = In_string + Chr(in_key)
   Else                                                     'in_string содержит принятую строку
      If In_string = "on" Then сканировать = да
      If In_string = "off" Then сканировать = нет
      In_string = ""
   End If
Return

сканирование:
Do
   For пеленг = 35 To 65 Step 5
     'Servo(1) = пеленг
     Servo1 = пеленг
     Waitms 50
     Gosub Sharp
   Next
   For пеленг = 65 To 35 Step -5
     'Servo(1) = пеленг
     Servo1 = пеленг
     Waitms 50
     Gosub Sharp
   Next
Loop Until сканировать = нет
'Servo(1) = 50
Servo1 = 50
Return

Sharp:
  Const порог_срабатывания = 100
   Start Adc
   дистанция = Getadc(0) : дистанция = Getadc(0) : дистанция = Getadc(0)
   Stop Adc
   буфер = пеленг - 30 : буфер = буфер \ 5
   дифф = дистанция - расстояния(буфер)
   дифф = Abs(дифф)
   расстояния(буфер) = дистанция
   If дифф > порог_срабатывания Then
      дистанция = дистанция / 10
      Text = Str(буфер) + "-" + Str(дистанция) : Call Printf(text)
   End If
Return

Sub Printf(byval S As String)
   Local I As Byte
   Local Len1 As Byte
   Local Buf As String * 1
   Reset Ucsr0b.rxen0
   Len1 = Len(s)
   For I = 1 To Len1
      Bitwait Ucsr0a.udre0 , Set                            ' ожидаю момента, когда можно загрузить новые данные
      Buf = Mid(s , I , 1)
      Udr0 = Asc(buf)
   Next
      Bitwait Ucsr0a.udre0 , Set
      Udr0 = 13
      Bitwait Ucsr0a.udre0 , Set
      Udr0 = 10
      Set Ucsr0a.txc0                                       ' очищаю флаг прерывания
      Bitwait Ucsr0a.txc0 , Set                             ' жду пока передатчик не передаст весь пакет (из внутреннего буфера, не UDR)
   Set Ucsr0b.rxen0
End Sub