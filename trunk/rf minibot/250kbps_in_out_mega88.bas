$prog &HFF , &HAD , &HD7 , &HF8                             ' для мегаплаты
'$prog &HFF , &HE0 , &HDD , &HF9                             ' для минибота 2.0
'27mhz 250kbps

$hwstack = 32
$swstack = 10
$framesize = 40

$regfile = "m88DEF.dat"
$baud = 115200
$crystal = 7372800


Config Pinb.5 = Output : Zb_sck Alias Portb.5 : Zb_sck = 0
Config Pinb.3 = Output : Zb_mosi Alias Portb.3 : Zb_mosi = 0
Config Pinb.1 = Output : Zb_cs Alias Portb.1 : Zb_cs = 1    ' для мегаплаты
'Config Pinb.0 = Output : Zb_cs Alias Portb.0 : Zb_cs = 1    ' для МиниБот 2.0
Config Pind.2 = Input : Gdo2 Alias Pind.2
Config Pind.3 = Input : Gdo0 Alias Pind.3


Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Clockrate = 128 , Polarity = Low , Phase = 0

'С повышающего на понижающий (с 1 до 0)
Config Int1 = Falling

On Urxc Getchar                                             'переопределяем прерывание на передачу по usart
On Int1 Getradio

Enable Interrupts                                           'разрешаем прерывания
Enable Urxc
Enable Int1

Spiinit

Const Команда_res = &H30
Const Команда_fstxon = &H31
Const Команда_xoff = &H32
Const Команда_cal = &H33
Const Команда_rx = &H34
Const Команда_tx = &H35
Const Команда_idle = &H36
Const Команда_afc = &H37
Const Команда_wor = &H38
Const Команда_pwd = &H39
Const Команда_frx = &H3A
Const Команда_ftx = &H3B
Const Команда_worrst = &H3C
Const Команда_nop = &H3D

Const Регистр_fsctrl1 = &H0B
Const Регистр_fsctrl0 = &H0C
Const Регистр_freq2 = &H0D                                  'подстройка при калибровке платы
Const Регистр_freq1 = &H0E                                  'подстройка при калибровкеплаты
Const Регистр_freq0 = &H0F                                  'подстройка при калибровке платы
Const Регистр_mdmcfg4 = &H10
Const Регистр_mdmcfg3 = &H11
Const Регистр_mdmcfg2 = &H12
Const Регистр_mdmcfg1 = &H13
Const Регистр_mdmcfg0 = &H14
Const Регистр_channr = &H0A
Const Регистр_deviatn = &H15
Const Регистр_frend1 = &H21
Const Регистр_frend0 = &H22
Const Регистр_mcsm2 = &H16
Const Регистр_mcsm1 = &H17
Const Регистр_mcsm0 = &H18
Const Регистр_foccfg = &H19
Const Регистр_bscfg = &H1A
Const Регистр_agcctrl2 = &H1B
Const Регистр_agcctrl1 = &H1C
Const Регистр_agcctrl0 = &H1D
Const Регистр_fscal3 = &H23
Const Регистр_fscal2 = &H24
Const Регистр_fscal1 = &H25
Const Регистр_fscal0 = &H26
Const Регистр_fstest = &H29
Const Регистр_test2 = &H2C
Const Регистр_test1 = &H2D
Const Регистр_test0 = &H2E
Const Регистр_iocfg2 = &H00
Const Регистр_iocfg1 = &H01
Const Регистр_iocfg0 = &H02
Const Регистр_pktctrl1 = &H07
Const Регистр_pktctrl0 = &H08
Const Регистр_addr = &H09
Const Регистр_pktlen = &H06
Const Регистр_fifothr = &H03
Const Регистр_patable = &H3E
Const Регистр_txfifo = &H3F
Const Регистр_rxbytes = &HFB
Const Регистр_rxfifob = &HFF

Waitms 250                                                  '#1 , "Start"
Ucsr0b.rxen0 = 0
Print "Start"
Ucsr0b.rxen0 = 1

Dim Сч As Byte
Dim Команда As Byte
Dim Регистр As Byte
Dim Число As Byte
Dim Адрес As Byte
Dim Ответ As Byte
Dim Статус As Byte
Dim ВремБайт1 As Byte


Dim Text As String * 15                                     'строка для отправки/приема
Dim Text_priem As String * 15                               'копия отправляемой строки
Dim Text_tmp As String * 15
Dim Txt_ As Byte
Dim S As Byte
Dim Ss As Byte
Dim I As Byte
Dim X As Integer
Dim Длина As Byte
Dim Isread As Byte                                          'разрешение чтения сс2500


'Сброс при включении питания
Gosub СброситьПередатчик

'Сбросить все регистры в значения по умолчанию
Команда = Команда_res : Gosub ПослатьКоманду

'Инициализируем регистр FSCTRL (параметры синтезатора)
'Print #1 , "FSCTRL"
Регистр = Регистр_fsctrl1 : Число = &H09 : Gosub ИнициализируемРегистр       ''08    '06
Регистр = Регистр_fsctrl0 : Число = &H00 : Gosub ИнициализируемРегистр       '00

'Инициализируем регистр FREQ (базовая несущая частота)
'Print #1 , "FREQ"
Регистр = Регистр_freq2 : Число = &H5A : Gosub ИнициализируемРегистр       '5B
Регистр = Регистр_freq1 : Число = &H1C : Gosub ИнициализируемРегистр       '75
Регистр = Регистр_freq0 : Число = &H71 : Gosub ИнициализируемРегистр       'D4

'Инициализируем регистр MDMCFG (конфигурация модема)
'Print #1 , "MDMCFG"
Регистр = Регистр_mdmcfg4 : Число = &H2D : Gosub ИнициализируемРегистр       ''86   '8B
Регистр = Регистр_mdmcfg3 : Число = &H2F : Gosub ИнициализируемРегистр       ''75   'ED
Регистр = Регистр_mdmcfg2 : Число = &H73 : Gosub ИнициализируемРегистр       ''03   '73
Регистр = Регистр_mdmcfg1 : Число = &H22 : Gosub ИнициализируемРегистр       ''22   'C2
Регистр = Регистр_mdmcfg0 : Число = &HE5 : Gosub ИнициализируемРегистр       ''e5   'EC

'Инициализируем регистр CHANNR (номер канала)
'Print #1 , "CHANNR"
Регистр = Регистр_channr : Число = &H00 : Gosub ИнициализируемРегистр

'Инициализируем регистр DEVIATN (девиация)
'Print #1 , "DEVIATN"
Регистр = Регистр_deviatn : Число = &H01 : Gosub ИнициализируемРегистр       ''43  '00

'Инициализируем регистр FREND
'Print #1 , "FREND"
Регистр = Регистр_frend1 : Число = &HB6 : Gosub ИнициализируемРегистр       ''56    '56
Регистр = Регистр_frend0 : Число = &H10 : Gosub ИнициализируемРегистр       '10

'Инициализируем регистр MCSM (конфигурация автомата контроля радио)
'Print #1 , "MCSM"
Регистр = Регистр_mcsm2 : Число = &H07 : Gosub ИнициализируемРегистр
Регистр = Регистр_mcsm1 : Число = &H30 : Gosub ИнициализируемРегистр
Регистр = Регистр_mcsm0 : Число = &H18 : Gosub ИнициализируемРегистр

'Инициализируем регистр FOCCFG (компенсация сдвига частоты)
'Print #1 , "FOCCFG"
Регистр = Регистр_foccfg : Число = &H1D : Gosub ИнициализируемРегистр       ''16    '16

'Инициализируем регистр BSCFG (конфигурация битовой синхронизации)
'Print #1 , "BSCFG"
Регистр = Регистр_bscfg : Число = &H1C : Gosub ИнициализируемРегистр       ''6C      '6c

'Инициализируем регистр AGCCTRL (параметры малошумящих усилителей и порог чувствительности компаратора)
'Print #1 , "AGCCTRL"
Регистр = Регистр_agcctrl2 : Число = &HC7 : Gosub ИнициализируемРегистр       ''03   '43
Регистр = Регистр_agcctrl1 : Число = &H00 : Gosub ИнициализируемРегистр       ''40  '40
Регистр = Регистр_agcctrl0 : Число = &HB2 : Gosub ИнициализируемРегистр       ''91  '91

'Инициализируем регистр FSCAL (параметры калибровки синтезатора)
'Print #1 , "FSCAL"
Регистр = Регистр_fscal3 : Число = &HEA : Gosub ИнициализируемРегистр       ''A9
Регистр = Регистр_fscal2 : Число = &H0A : Gosub ИнициализируемРегистр       ''0A
Регистр = Регистр_fscal1 : Число = &H00 : Gosub ИнициализируемРегистр       ''00
Регистр = Регистр_fscal0 : Число = &H11 : Gosub ИнициализируемРегистр       ''11

'Инициализируем регистр FSTEST (конфигурация битовой синхронизации)
'Print #1 , "FSTEST"
Регистр = Регистр_fstest : Число = &H59 : Gosub ИнициализируемРегистр

'Инициализируем регистр TEST (параметры малошумящих усилителей и порог чувствительности компаратора)
'Print #1 , "TEST"
Регистр = Регистр_test2 : Число = &H88 : Gosub ИнициализируемРегистр       ''81  '81
Регистр = Регистр_test1 : Число = &H31 : Gosub ИнициализируемРегистр       ''35   '35
Регистр = Регистр_test0 : Число = &H0B : Gosub ИнициализируемРегистр       '0B

'Инициализируем регистр IOCFG2 (функция вывода GDO2)
'Print #1 , "IOCFG2"
Регистр = Регистр_iocfg2 : Число = &H0E : Gosub ИнициализируемРегистр

'Инициализируем регистр IOCFG0 (функция вывода GDO0)
'Print #1 , "IOCFG0"
Регистр = Регистр_iocfg0 : Число = &H06 : Gosub ИнициализируемРегистр

'Инициализируем регистр PKTCTRL (параметры пакета)
'Print #1 , "PKTCTRL"
Регистр = Регистр_pktctrl1 : Число = &H04 : Gosub ИнициализируемРегистр       '04
Регистр = Регистр_pktctrl0 : Число = &H45 : Gosub ИнициализируемРегистр       ''05

'Инициализируем регистр ADDR (адрес устройства)
'Print #1 , "ADDR"
Регистр = Регистр_addr : Число = &H00 : Gosub ИнициализируемРегистр

'Инициализируем регистр PKTLEN (длина пакета)
'Print #1 , "PKTLEN"
Регистр = Регистр_pktlen : Число = &HFF : Gosub ИнициализируемРегистр

'Инициализируем регистр FIFOTHR (граница сигнализации переполнения ФИФО)
'Print #1 , "FIFOTHR"
Регистр = Регистр_fifothr : Число = &H07 : Gosub ИнициализируемРегистр

'Заполняем таблицу мощностей
'Print "PATABLE"
Регистр = Регистр_patable
Zb_cs = 0
'Мощность приемо-передатчика
Число = &H44 : Gosub ЗаписатьВТаблицуМощностей              '44  '46   'HBF 'FB
Zb_cs = 1
Регистр = Регистр_patable
Zb_cs = 0
Gosub ПрочитатьИзТаблицыМощностей

Zb_cs = 1
Text = ""
Isread = 1                                                  'по умолчанию читаем эфир

'Переводим передатчик в режим IDLE
Команда = Команда_idle : Gosub ПослатьКоманду
'Обнулим FIFO RX
Команда = Команда_frx : Gosub ПослатьКоманду
'Обнулим FIFO TX
Команда = Команда_ftx : Gosub ПослатьКоманду

'команда по умолчанию
Команда = Команда_rx : Gosub ПослатьКоманду
Do

Loop
                                                   '''                                                      '
'Процедуры
СброситьПередатчик:
   Zb_sck = 1
   Zb_mosi = 0
   Zb_cs = 0
   Waitus 1
   Zb_cs = 1
   Waitus 40
Return

ПослатьКоманду:
   Zb_cs = 0
   Статус = Spimove(Команда)
   Zb_cs = 1
   Waitms 1
Return

ПрочитатьРегистр:
   ВремБайт1 = Регистр + 128
   Zb_cs = 0
   Статус = Spimove(ВремБайт1)
   Ответ = Spimove(0)
   Zb_cs = 1
Return

ПрочитатьСтатус:
   Zb_cs = 0
   Статус = Spimove(Регистр)
   Ответ = Spimove(0)
   Zb_cs = 1
Return

ИнициализируемРегистр:
   Zb_cs = 0
   Статус = Spimove(Регистр)
   Ответ = Spimove(Число)
   ВремБайт1 = Регистр + 128
   Статус = Spimove(ВремБайт1)
   Ответ = Spimove(0)
   Zb_cs = 1
Return

ЗаписатьВТаблицуМощностей:
   Статус = Spimove(Регистр)
   Ответ = Spimove(Число)
Return

ПрочитатьИзТаблицыМощностей:
   ВремБайт1 = Регистр + 128
   Статус = Spimove(ВремБайт1)
   Ответ = Spimove(0)
Return

ОтправитьДанные:
  Isread = 0
  'Переводим передатчик в режим IDLE
  Команда = Команда_idle : Gosub ПослатьКоманду
  'Обнулим Fifo Tx
  Команда = Команда_ftx : Gosub ПослатьКоманду

  'Заполняем буфер TX

  Zb_cs = 0
  Команда = Регистр_txfifo Or &H40 : Статус = Spimove(Команда)
  Команда = 2 : Статус = Spimove(Команда)
  Команда = 0 : Статус = Spimove(Команда)


  Команда = Ss : Статус = Spimove(Команда)
  Zb_cs = 1

  Команда = Команда_tx : Gosub ПослатьКоманду
  'Waitms 1
  Text = ""
  Waitms 100
  Isread = 1
  '''
  'Переводим передатчик в режим IDLE
  Команда = Команда_idle : Gosub ПослатьКоманду
  'Обнулим FIFO TX
  Команда = Команда_ftx : Gosub ПослатьКоманду
Return

ПринятьДанные:
Text_priem = ""
   '1 длина
   '2 канал
   '3-n пакет
   If Isread = 0 Then Goto Zbok

   Регистр = Регистр_rxbytes : Gosub ПрочитатьСтатус
   If Статус = 0 Then Goto Zbok
   Zb_cs = 0
   Команда = Регистр_rxfifob : Статус = Spimove(Команда)
   Статус = Spimove(Команда)                                ': Print Hex(Статус);
   Длина = Статус - 1
   Статус = Spimove(Команда)                                ': Print Hex(Статус) ; "-";     '  #1 ,
   For I = 1 To Длина
      Статус = Spimove(Команда)
      Text_tmp = Chr(Статус)
      Text_priem = Text_priem + Text_tmp                    '  #1 ,данные
   Next
   Статус = Spimove(Команда)                                'Print Hex(Статус);
   Статус = Spimove(Команда)                                'Print Hex(Статус)
   Zb_cs = 1
   Ucsr0b.rxen0 = 0
   Print Text_priem;                                        '  #1 ,данные
   Print
   Ucsr0b.rxen0 = 1

Zbok:
'Переводим передатчик в режим Idle
Команда = Команда_idle : Gosub ПослатьКоманду
'Обнулим Fifo Rx
Команда = Команда_frx : Gosub ПослатьКоманду
''''команда по умолчанию
Команда = Команда_rx : Gosub ПослатьКоманду
Zbok1:
Return

'отправка
Getchar:
   Txt_ = Inkey()
   Ss = Txt_:
   Gosub ОтправитьДанные
Return

'получили данные от сс2500
Getradio:
   'прием
   If Gdo0 = 0 And Isread = 1 Then
      Gosub ПринятьДанные
      'Переводим передатчик в режим Idle
      Команда = Команда_idle : Gosub ПослатьКоманду
      'Обнулим Fifo Rx
      Команда = Команда_frx : Gosub ПослатьКоманду
      'команда по умолчанию
      Команда = Команда_rx : Gosub ПослатьКоманду
   End If
   Eifr = 2
Return