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

' Связь
Dim Text As String * 50                                     'строка для отправки/приема (длина строки 15 символов)
Dim Text_tmp As String * 50
Dim Txt_ As Byte

' Функции и процедуры
Declare Sub Printf(byval S As String)

Enable Urxc
On Urxc Getchar                                             'переопределяем прерывание приема usart


Waitms 1000


'      Print "Start Mega88 MiniBot 2.1"
'      'Waitms 1
'      Ucsr0b.rxen0 = 1
'   Text = Chr(10)
'   Call Printf(text)
'   Text = "start minibot mega88" + Chr(13)
   Call Printf( "start minibot mega88" )
'   Text = Chr(10)
'   Call Printf(text)
   Call Printf( "test")

Enable Interrupts                                           'разрешаем прерывания


Do
   основной_цикл:
   'Gosub сканирование
Loop

Getchar:
   Txt_ = Inkey()
   If Txt_ > 13 Then                                        'если пришел не служебный символ
      Text_tmp = Text_tmp + Chr(txt_)
   End If
   If Txt_ = 13 Then                                        'нажали ввод
         'строка в Text принята
   End If
   If Text_tmp = "on" Then Gosub сканирование
   If Text_tmp = "off" Then Gosub сканирование_стоп
   If Mid(text_tmp , 1 , 2) = "on" Then Gosub сканирование
Return

сканирование:
Do
   Text = "adcd" : Call Printf(text)
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
Loop
Return

сканирование_стоп:
   'Servo(1) = 50
   Servo1 = пеленг
   Goto основной_цикл
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
      Text = Chr(13) + Str(пеленг) + "-" + Str(дистанция) : Call Printf(text)
   End If
Return

'(

Void Usart_transmit(unsigned Char Data )
{
 / * Wait For Empty Transmit Buffer * /
While(!(ucsrna &(1 << Udren)) )
;
 / * Put Data Into Buffer , Sends The Data * /
Udrn = Data;
}
')

Sub Printf(byval S As String)
   Local I As Byte
   Local Len1 As Byte
   Local Buf As String * 1
   Reset Ucsr0b.rxen0
      While Ucsr0a.udre0 = 0
      Wend
      Udr0 = 10
   Len1 = Len(s)
   For I = 1 To Len1
      While Ucsr0a.udre0 = 0
      Wend
      Buf = Mid(s , I , 1)
      Udr0 = Asc(buf)
   Next
      While Ucsr0a.udre0 = 0
      Wend
      Udr0 = 13
   Set Ucsr0b.rxen0
End Sub