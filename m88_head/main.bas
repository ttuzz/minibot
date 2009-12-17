'$prog &HFF , &HE0 , &HDD , &HF9                             ' для минибота 2.x

$regfile = "m88DEF.dat"
$crystal = 7372800
$baud = 115200
'Config Serialin = Buffered , Size = 10

$hwstack = 64
$swstack = 64
$framesize = 64

Enable Interrupts                                           'разрешаем прерывания
'Enable Urxc
On Urxc Getchar                                             'переопределяем прерывание приема usart

Config Adc = Single , Prescaler = Auto                      'опора 2,04В

Dim Дистанция As Word
   Dim Дифф As Integer

Dim Text As String * 15                                     'строка для отправки/приема (длина строки 15 символов)
Dim Text_tmp As String * 15
Dim Txt_ As Byte

Config Servos = 1 , Servo1 = Portb.2 , Reload = 20
Config Pinb.2 = Output
Dim Пеленг As Byte

Dim Расстояния(7) As Word
Dim Буфер As Byte

Enable Interrupts

Waitms 1000
Print
Print "Start Mega88 MiniBot 2.1"


'Config Pinb.2 = Input

'Gosub Считывание_расстояний
Do
   Основной_цикл:
   Gosub Сканирование
Loop

Сканирование:
Do
   For Пеленг = 35 To 65 Step 5
     Servo(1) = Пеленг
     Waitms 40
     Gosub Sharp
   Next
   'For Пеленг = 65 To 35 Step -5
   '  Servo(1) = Пеленг
   '  Waitms 15
   '  Gosub Sharp
   'Next
Loop
Return

'(
Считывание_расстояний:
   Start Adc
   Буфер = 1
   For Пеленг = 35 To 65 Step 5
     Servo(1) = Пеленг
     Waitms 40
     Дистанция = Getadc(0) : Дистанция = Getadc(0) : Дистанция = Getadc(0)
     Расстояния(Буфер) = Дистанция : Incr Буфер
   Next
   Stop Adc
   ' вывод
   Print "Dist: " ;
   For Буфер = 1 To 7
      Print Расстояния(Буфер) ; " ";
   Next
   Print
Return
')

Сканирование_стоп:
   Servo(1) = 50
   Goto Основной_цикл
Return

Getchar:
   Txt_ = Inkey()
   If Txt_ > 13 Then                                        'если пришел не служебный символ
      Text_tmp = Chr(txt_)
      Text = Text + Text_tmp
   End If
   If Txt_ = 13  Then'нажали ввод
         'строка в Text принята
   End If
   If Text = "M88_Scan_on" Then Gosub Сканирование
   If Text = "M88_Scan_off" Then Gosub Сканирование_стоп
Return

Sharp:
   Const Граница = 70
   Start Adc
   Дистанция = Getadc(0) : Дистанция = Getadc(0) : Дистанция = Getadc(0)
   Stop Adc
   Буфер = Пеленг - 30 : Буфер = Буфер \ 5
   Дифф = Дистанция - Расстояния(Буфер)
   Дифф = Abs(Дифф)
   Расстояния(Буфер) = Дистанция
   If Дифф > Граница Then
      Print Chr(13);
      Дистанция = Дистанция / 10
      Print Пеленг ; "-" ; Дистанция ;
   End If
   '(
   If Буфер = 7 Then
      Print Дистанция ;
      Waitms 200                                            ' задержка на посмотреть
      Print Chr(13);
   Else
      Print Дистанция ; " " ;
   End If
   ')
'(
   Дистанция = Дистанция - Граница
   If Дистанция > Расстояния(Буфер) Then
      Дистанция = Дистанция + Граница : Дистанция = Дистанция / 10
      Print Chr(13);
      Print Пеленг ; "-" ; Дистанция ;
   End If
')
Return