'$prog &HFF , &HBD , &HC9 , &H00
$regfile = "m32def.dat"                                     ' файл спецификации Меги32
$crystal = 7372800                                          ' указываем на какой частоте будем работать
$baud = 115200
$hwstack = 64
$swstack = 64
$framesize = 64
$include "pult.bas"

Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down
Config Pinc.2 = Output : направление_левый Alias Portc.2    'ногу сконфигурировали как выход и обозвали Drl
Config Pinc.3 = Output : направление_правый Alias Portc.3   'ногу сконфигурировали как выход и обозвали Drr
Config Pind.4 = Output                                      'ногу ШИМа левого движка сконфигурировали как выход
Config Pind.5 = Output                                      'ногу ШИМа правого движка сконфигурировали как выход
Const вперед = 1
Const назад = 0
Const точка_останова = 50
скорость_левый Alias Pwm1b : скорость_правый Alias Pwm1a

Config Pinc.4 = Output : диод1_красный Alias Portc.4
Config Pinc.5 = Output : диод1_зеленый Alias Portc.5
Config Pinc.6 = Output : диод2_красный Alias Portc.6
Config Pinc.7 = Output : диод2_зеленый Alias Portc.7
   Const зажечь = 1
   Const потушить = 0

Config Pind.2 = Input : кнопка Alias Pind.2
Config Pinb.2 = Input : питание Alias Pinb.2

Config Pina.2 = Input : бампер_л Alias Pina.2               ' бампер левый
Config Pina.6 = Input : бампер_п Alias Pina.6               ' бампер правый
   Const нажат = 0
   Const отжат = 1

Config Pina.1 = Output : пылесос Alias Porta.1 : Reset пылесос       ' пылесос
Config Pind.7 = Output : динамик Alias Portd.7 : Reset динамик       ' динамик

' Прерывание по спаду уровня для обработки команд RC5
Config Int1 = Falling
On Int1 принять_команду_пульта
Enable Int1
Config Rc5 = Pind.3

' Прерывание отсчета времени таймера2
Config Timer2 = Timer , Prescale = 64
On Ovf2 таймер2
Enable Timer2

' Прерывание по приходу символа по уарту
Enable Urxc
On Urxc получить_символ                                     'переопределяем прерывание приема usart
   Dim In_string As String * 50                             'строка для приема
   Dim In_key As Byte                                       ' текущий принятый символ
   Dim In_buf As String * 10                                ' буфер-строка для парсинга принятых символов


' Глобальные переменные
Dim команда_пульта_адрес As Byte , команда_пульта As Byte
Dim Adc_temp As Word , Akb As Single
Dim Errbyte As Byte

Dim состояние_робота As Byte
   Const управление_пультом = 1
   Const движение_улиткой = 2
   Const поиск_станции = 3
   состояние_робота = 0

' Отсчет времени
Dim тики_таймера As Byte

' Конвеер выполнения
Dim команда_предыдущая As Byte
   Dim команда_количество As Byte                           ' сколько раз повторен прием одной и той же команды

' Свободное блуждание
Dim направление_движения As Byte
   Const стоп = 2                                           ' вперед и назад уже обозначены, смотри выше
   направление_движения = стоп


' Процедуры
Declare Sub выполнить_команду()
   Dim флаг As Byte
      Const команда_пуста = 0
      Const команда_старт = 1
Declare Sub двигаться_улиткой()
Declare Sub искать_станцию()
Declare Sub улитка_ожидание(byval период As Word)
Declare Sub обработка_бамперов()
   Dim расстояния(7) As Word
   Dim буфер As Byte


' Связь
Declare Sub Printf(byref S As String)
   Dim Text As String * 50                                  ' буфер-строка для отправки (нужна из-за недопустимости вложенных функция)


диод2_зеленый = зажечь

' Запуск
Enable Interrupts

Waitms 200
Text = "Start MiniBot v2.1" : Call Printf(text)

старт:
Text = "in begin" : Call Printf(text)
Do
   Select Case состояние_робота
      Case движение_улиткой:
         Disable Int1
         команда_пульта = Btn_power : Gosub выполнить_команду       ' ставим в режим парковки
         Enable Int1
         Gosub двигаться_улиткой
      Case поиск_станции:
         Disable Int1
         команда_пульта = Btn_power : Gosub выполнить_команду       ' ставим в режим парковки
         Enable Int1
         Gosub искать_станцию
      Case управление_пультом:
         Disable Int1
         команда_пульта = Btn_ok : Gosub выполнить_команду  ' снимаем с режима парковки
         Enable Int1
         Text = "in_ir_control" : Call Printf(text)
         Do
            Call обработка_бамперов
         Loop
      Case Else
         ' первый запуск, ставим в режим парковки
         Disable Int1
         команда_пульта = Btn_power : Gosub выполнить_команду       ' ставим в режим парковки, управление с пульта
         состояние_робота = управление_пультом
         Enable Int1
         Text = "in_parking_mode" : Call Printf(text)
         Do
            Call обработка_бамперов
         Loop
   End Select
Loop

принять_команду_пульта:
   Disable Int1
   тики_таймера = 0
   Enable Interrupts
   Getrc5(команда_пульта_адрес , команда_пульта)
   Enable Interrupts
   If команда_пульта_адрес = Ir_adress And команда_пульта <> 255 Then       ' используется пульт Минибота с кодом адреса = 0
      команда_пульта = команда_пульта And &B01111111
      'Print Chr(12);
      'Print "IR_Address - " ; команда_пульта_адрес
      Text = "IR_command - " + Str(команда_пульта) : Call Printf(text)
      If команда_пульта = команда_предыдущая Then           ' считаем сколько уже раз приняли команду
         Incr команда_количество
      Else
         команда_количество = 0
         команда_предыдущая = команда_пульта
      End If
      Text = "amount" + Str(команда_количество) : Call Printf(text)
      Call выполнить_команду
   End If
   ' обработка команды
   Gifr = Gifr Or &B10000000                                'Clear Flag Int1
   Enable Int1
   If флаг = команда_старт Then
      Goto старт
   End If
Return

получить_символ:
   Toggle диод1_зеленый
   In_key = Inkey()
   If In_key <> 13 And In_key <> 10 Then                    ' принимаем пока не встретим конец строки
         In_string = In_string + Chr(in_key)
   Else                                                     'in_string содержит принятую строку
      'if In_string = "on" Then сканировать = да
      'if In_string = "off" Then сканировать = нет
      'Mid(in_string , 1 , 1) = "-" ' отладочный вывод
      If Mid(in_string , 2 , 1) = "-" Then                  ' приняли состояние серв
         In_buf = Mid(in_string , 1 , 1) + Chr(0)
         буфер = Val(in_buf)
         In_key = Len(in_string) - 2
         In_buf = Mid(in_string , 3 , In_key) + Chr(0)
         расстояния(буфер) = Val(in_buf)
      End If
      In_string = ""
   End If
Return

таймер2:
   ' count = 120, если выводятся IR_command and IR_Address
   ' count = 120, если выводится ir_command
   If тики_таймера < 120 Then
      Incr тики_таймера
      диод1_красный = зажечь
   Else
      диод1_красный = потушить
      If состояние_робота = управление_пультом Then
         Disable Int1
         Select Case направление_движения
         Case вперед : команда_пульта = Btn_up
         Case назад : команда_пульта = Btn_down
         Case стоп : команда_пульта = Btn_ok
         End Select
         Call выполнить_команду()
         команда_количество = 0
         Enable Int1
      End If
   End If
Return

Sub двигаться_улиткой()
'
End Sub

Sub улитка_ожидание(byval период As Word)
'
End Sub

Sub искать_станцию()
'
End Sub

Sub обработка_бамперов()
'
End Sub

Sub выполнить_команду()
   флаг = команда_пуста
   Select Case команда_пульта
   ' команды движения
      Case Btn_up:
         направление_левый = вперед : направление_правый = вперед
         скорость_левый = 200 : скорость_правый = 200
         направление_движения = вперед
         состояние_робота = управление_пультом
      Case Btn_down:
         направление_левый = назад : направление_правый = назад
         скорость_левый = 200 : скорость_правый = 200
         направление_движения = назад
         состояние_робота = управление_пультом
      Case Btn_left:
         Select Case команда_количество
         Case 0 To 3 :
            скорость_левый = 0 : скорость_правый = 200
         Case 3 To 5 :
            скорость_левый = 0 : скорость_правый = 230
         Case 6 To 255 :
            скорость_левый = 0 : скорость_правый = 255
         End Select
         состояние_робота = управление_пультом
      Case Btn_right:
         Select Case команда_количество
         Case 0 To 3 :
            скорость_левый = 200 : скорость_правый = 0
         Case 3 To 5 :
            скорость_левый = 230 : скорость_правый = 0
         Case 6 To 255 :
            скорость_левый = 255 : скорость_правый = 0
         End Select
         состояние_робота = управление_пультом
      Case Btn_ok:
         направление_левый = вперед : направление_правый = вперед
         скорость_левый = 0 : скорость_правый = 0
         направление_движения = стоп
         состояние_робота = управление_пультом
      Case Btn_power:
         ' ПОДУМАТЬ НАД РЕЖИМАМИ, может возращать бота в состояние_робота = 0, т.е. точку старта
         направление_левый = вперед : направление_правый = вперед
         скорость_левый = 0 : скорость_правый = 0
         состояние_робота = 0
         направление_движения = стоп
         флаг = команда_старт
   ' команды состояния
      Case Btn_1:
         ' свободное блуждание по таблице маркова
         'состояние_робота = управление_пультом
         'флаг = команда_старт
      Case Btn_2:
         состояние_робота = движение_улиткой
         флаг = команда_старт
      Case Btn_3:
         состояние_робота = поиск_станции
         флаг = команда_старт
      Case Btn_s:
         Toggle пылесос
      Case Btn_tv:
         'отправка сигнала меге88
         Text = "on" : Call Printf(text)
      Case Btn_av:
         ' отправка сигнала меге88
         Text = "off" : Call Printf(text)
      Case Btn_sleep:
         ' ВНИМАНИЕ!! КНОПКА ДЛЯ ОТЛАДКИ И ТОЛЬКО
         If расстояния(1) > 100 Then Toggle диод2_красный
      Case Else:
         ' ни одна из вышеперечисленных кнопок
   End Select
End Sub


Sub Printf(byval S As String)
   Local Cnt As Byte
   Local Len1 As Byte
   Local Buf As String * 1
   Reset Ucsrb.rxen
   Len1 = Len(s)
   For Cnt = 1 To Len1
      Bitwait Ucsra.udre , Set                              ' ожидаю момента, когда можно загрузить новые данные
      Buf = Mid(s , Cnt , 1)
      Udr = Asc(buf)
   Next
      Bitwait Ucsra.udre , Set
      Udr = 13
      Bitwait Ucsra.udre , Set
      Udr = 10
      Set Ucsra.txc                                         ' очищаю флаг прерывания
      Bitwait Ucsra.txc , Set                               ' жду пока передатчик не передаст весь пакет (из внутреннего буфера, не UDR)
   Set Ucsrb.rxen
End Sub