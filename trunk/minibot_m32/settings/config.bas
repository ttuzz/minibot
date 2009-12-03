'(
Description : Файл описания сборки
Description : программы шлюз -контроллера для робототехнической платформы
Description : МиниБот 2.1
Release Date : 2009 -01 -11
Version : 1.0
Author : Josef Franz Vogel - парсер входной строки
Author : galex1981 - код для работы с IR пультом
Author : MiBBiM - всё остальное
')

'**Константы железячной сборки**
' содержит константы, описывающие комлпектность платформы
Const Exist_engines = 1                                     ' моторы
Const Exist_sd = 1                                          ' карта памяти
Const Exist_speaker = 1                                     ' динамик
Const Exist_encoders = 0                                    ' энкодеры
Const Exist_linesensors = 0                                 ' датчики линии
Const Exist_mega88 = 0                                      ' сопроцессор Mega88
   Const Exist_sharp = 0                                    ' дальномер sharp
   Const Exist_servos = 0                                   ' сервы
Const Exist_display = 0                                     ' дисплей от телефона nokia 3510i

'**Константы софтовой сборки**
' содержит константы, описывающие софтовую сборку
Const Language = 1                                          ' язык вывода ошибок
Const Need_ir_commands = 1                                  ' нужно ли принимать RC5 команды
Const Need_logging_display = 0                              ' нужно ли вести лог на дисплее
Const Need_logging_speaker = 0                              ' нужно ли произносить результаты голосом
Const Need_logging_sd = 0                                   ' нужно ли вести лог на карточке
   Const Logging_sd_filename = "log.txt"
Const Need_extended_errors = 0                              ' нужно ли выводить помимо кода ошибки ещё и её текст

'**Базовая конфигурация**

'фусибиты контроллера Mega32
'$prog &HFF , &HAE , &HC9 , &H00
$regfile = "m32DEF.dat"
$crystal = 7372800

'hardware-UART
$baud = 115200
Config Serialin = Buffered , Size = 20

'стек
$hwstack = 32
$swstack = 32
$framesize = 32

'вачдог таймер(нужно после софт перезагрузки)
Stop Watchdog

'светодиоды(конфигурация ИК светодиода ниже)
Config Pinc.4 = Output : Led_r1 Alias Portc.4
Config Pinc.5 = Output : Led_g1 Alias Portc.5
Config Pinc.6 = Output : Led_r2 Alias Portc.6
Config Pinc.7 = Output : Led_g2 Alias Portc.7

'кнопка
Config Pind.2 = Input : Button Alias Pind.2

'питание
Config Pinb.2 = Input : Power_in Alias Pinb.2

'!!!АЦП конфигурировать непосредственно перед измерением и не раньше!!!
'Config Adc = Single , Prescaler = Auto , Reference = Internal       '2.56V

#if Need_ir_commands = 1
   'обработка команд RC5
   Config Int1 = Falling
   On Int1 Learn_rc5
   Enable Int1
   Config Rc5 = Pind.3
#endif

'**Дополнительная конфигурация***

#if Exist_engines = 1
   'ШИМ управление двигателями
   Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down
   Config Pinc.2 = Output : Motor_left_dir Alias Portc.2    ' DrL
   Config Pinc.3 = Output : Motor_right_dir Alias Portc.3   ' DrR
   Config Pind.4 = Output : Motor_left_speed Alias Pwm1b    'PWM L
   Config Pind.5 = Output : Motor_right_speed Alias Pwm1a   'PWM R

   'останов
   Motor_left_dir = 0 : Motor_right_dir = 0
   Motor_left_speed = 0 : Motor_right_speed = 0
#endif

#if Exist_display = 1
   ' библиотека для Nokia 3510i
   $include "nokialcd.lbx"
   ' инициализация пинов
   Config Graphlcd = Color , Controlport = Portc , Rs = 4 , Cs = 5 , Scl = 7 , Sda = 6
   ' размеры дисплея
   Const Display_width = 98
   Const Display_height = 67
   ' частоиспользуемые цвета
   Const Blue = &B00000011                                  'predefined contants are making programming easier
   Const Yellow = &B11111100
   Const Red = &B11100000
   Const Green = &B00011100
   Const Black = &B00000000
   Const White = &B11111111
   Const Brightgreen = &B00111110
   Const Darkgreen = &B00010100
   Const Darkred = &B10100000
   Const Darkblue = &B00000010
   Const Brightblue = &B00011111
   Const Orange = &B11111000
   ' шрифт
   $include "include\font_color_rus.font"
   Setfont Font_color_rus
   Const Font_height = 8
   ' константы для косячной работы pset, используются в функции Print_picture_to_display
      ' нужны для задания координатной сетки (которая смещена для библиотеки от дисплея nokia 3510i)
      Const Row_begin = -1
      Const Col_begin = -1
      Const Row_end = 65
      Const Col_end = 96
   ' константы для режима консоли (см. процедуру Print_to_display)
      Const Display_x_pos = 3                               ' смещение строк по оси X
      Const Display_text_foreground_color = Black
   ' очистка
   Cls
#endif

#if Exist_speaker = 1
   'инициализация динамика
   Config Pind.7 = Output : Portd.7 = 0
   Speaker Alias Portd.7
   #if Need_logging_speaker = 1
      'константы-описатели звуковых фрагментов
      'константы цифр, 10 штук, лежат в диапазоне 0..10
      ' БУДЕМ ХРАНИТЬ В ERRCODES.BAS
      Const Sound_welcome = 11
      Const Sound_wrong_input = 12
      'и другие
   #endif
#endif

#if Exist_encoders = 1 Or Exist_linesensors = 1
   'ик излучатель
   Config Pind.6 = Output : Led_ir Alias Portd.6
   Led_ir = 0
#endif

#if Exist_encoders = 1
   'конфигурирую входы для энкодеров
   'основной(_m) и дополнительный вход (_a) левого энкодера
   Config Pina.2 = Input : Encoder_left_m Alias Pina.2
   Config Pina.6 = Input : Encoder_left_a Alias Pina.6
   'основной(_m) и дополнительный вход (_a) правого энкодера
   Config Pina.1 = Input : Encoder_right_m Alias Pina.1
   Config Pina.5 = Input : Encoder_right_a Alias Pina.5
#endif

#if Exist_linesensors = 1
   'датчики линии
   Config Pina.0 = Input : Linesensor_1 Alias Pina.0
   Config Pina.3 = Input : Linesensor_2 Alias Pina.3
   Config Pina.4 = Input : Linesensor_3 Alias Pina.4
#endif

#if Exist_sd = 1
   'инициализация файловой системы(AVR-DOS и SD)
   $include "settings\config_MMC.bas"
   $include "settings\config_DOS.BAS"
#endif

'**Шлюз**
'конфигурация шлюза
Const Cptoken_max = 6                                       'максимальное количество токенов
Const Cpstrsep = ","                                        'разделитель токенов (после второго и далее)
Const Cpcinput_len = 20                                     ' НЕ МЕНЬШЕ 20!!!(см. использование Print_ew) длина пользовательского ввода(включая *.bat файлы)
Const Ctoken_len = 12                                       'максимальная длина одного токена

'константы состояния
Const Now_logging = 0                                       'лог в файл (обычное состояние, даже если sd-карты нет)
Const Now_recording = 1                                     'запись в *.bat
Const Now_playing = 2                                       'проигрывание *.bat

'описатели глобальных переменных
'  для парсера строки
Dim Gstoken As String * Ctoken_len                          'содержит текущий токен
Dim Gspcinput As String * Cpcinput_len                      'содержит пользовательский ввод(*.bat, uart)
Dim Gbposstrparts(cptoken_max) As Byte                      'буферы, хранящие информацию
Dim Gblenstrparts(cptoken_max) As Byte                      '  о распарсенной строке
Dim Gbcnttoken As Byte                                      'количество найденных токенов
Dim Gbtoken_actual As Byte                                  'номер текущего токена(нужен для получения следующего)
Dim Gbpcinputerror As Byte                                  'ошибка в пользовательском вводе
'**/Шлюз**

'**Аппаратные переменные, необходимые для обеспечения функциональности
Dim State As Byte : State = Now_logging                     ' состояние шлюза

#if Need_ir_commands = 1
   Dim Ir_command_adress As Byte , Ir_command As Byte       ' команда с пульта RC5
#endif

#if Exist_sd = 1
   'Dim File As Byte : File = 0                              ' номер файла для записи или воспроизведения(*.bat) - прибить после доводки (используется для записи ик-команд)
   Const File = 10                                          ' константа едиственного открытого файл-хэндла
   Dim Text_filename As String * 12                         ' имя нужного файла, см. процедуры для записи в файл+логгирования
   Dim Mult_filename As String * 12                         ' имя нужного мультимедиа файла
#endif

#if Exist_encoders = 1
   Dim Encoder_left As Long : Encoder_left = 0              ' позиция левого энкодера
   Dim Encoder_right As Long : Encoder_right = 0            ' позиция правого энкодера
#endif

#if Exist_display = 1
   Dim Display_y_pos As Byte : Display_y_pos = 0
#endif



Dim Strfile As String * 10                                  ' Имя файла для записи

Dim Strf1 As String * 1                                     ' строки формирования имени файла
Dim Strf2 As String * 1

Dim Gspcinput1 As String * Cpcinput_len                     ' копия командной строки для записи в файл
Dim Speed As Byte
Speed = 1