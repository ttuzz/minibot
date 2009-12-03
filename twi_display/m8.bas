'(
  Программа для приема 3х байтных пакетов через Twi
')

$regfile = "M88def.dat"
$crystal = 7372800
$baud = 9600
Config Serialin = Buffered , Size = 20

Waitms 100

Const Max_buf_len = 10                                      ' максимальный размер буфера(пакета)
Dim Buf(max_buf_len) As Byte
Dim Buf_len As Byte                                         ' текущий размер буфера(пакета)

Dim Buf_to_send(max_buf_len) As Byte                        ' отправка
Dim Buf_to_send_len As Byte                                 ' размер отправки

Dim New_msg As Byte                                         ' флаг нового пакета

Dim Twi_control As Byte
Dim Twi_status As Byte
Dim Twi_data As Byte

Enable Twi
On Twi Twi_int_slave

'!!!!
' пакет для передачи и его размер
   Buf_to_send(1) = "B"
   Buf_to_send(2) = "T"                                     'Servo Transmit Byte, обратный порядок байт
   Buf_to_send(3) = "S"
   Buf_to_send_len = 3
'!!!!

' TWI init
Gosub Twi_init_slave

Enable Interrupts

Print "M8 twi test"
Do
   ' если принят новый пакет
    If New_msg = 1 Then
        New_msg = 0                                         ' очистить флаг
        'Print "message: " ; chr(Buf(1)) ; " " ; Buf(2) ; " " ; Buf(3)       ' вывести первые три байта
        Print "message: " ; Chr(buf(1)) ; " " ; Chr(buf(2)) ; " " ; Chr(buf(3))
    End If
    Waitms 10
Loop

End

' TWI инициализация слейв - приемник, слейв - передатчик (зависит от старт-пакета)
Twi_init_slave:
   Const Twi_slave_adr = &B01110000                         ' адрес слейва (7бит!!!!, наш адрес), TWCG (нулевой бит) сброшен, не распознаем общий вызов(адрес 0x00)
   Twi_data = 0
   New_msg = 0                                              ' очищаем пакет
   Buf_len = 0
   Twsr = 0                                                 ' очищаем статус, частота обмена = fclk/(16 + 2*TWBR*4^TWPS), для ведомого состояние регистров безразлично
   Twdr = &HFF                                              ' обнуляем данные
   Twar = Twi_slave_adr                                     ' устанавливаем адрес слейва
   Reset Twar.twgce                                         ' запрет распознавания общего адреса
   Set Twcr.twen                                            ' разрешение работы модуля
   Set Twcr.twea                                            ' разрешение автоматической генерации подтверждения
   Set Twcr.twint                                           '!!!ВНИМАНИЕ!!!сбрасываем флаг прерывания
   Set Twcr.twie                                            ' разрешаем прерывания
Return

Twi_int_slave:
   Twi_status = Twsr And &HF8                               ' отбрасываем 3 лишних байта [-,TWSP1,TWSP2]
   Select Case Twi_status
   ' статусы приемника
      Case &H60 :                                           ' адресованы SLA+W пакетом
         Buf_len = 0
         New_msg = 0
         Reset Twcr.twsto
         Set Twcr.twea
         'Twcr = &B11000100
      Case &H80:                                            ' приняли байт (их может быть много)
         If Buf_len < Max_buf_len Then
            Incr Buf_len
            Buf(buf_len) = Twdr
            Reset Twcr.twsto
            Set Twcr.twea
         End If
      Case &HA0 :                                           'старт или повстарт в то время, когда устройство адресовано
         ' здесь надо бы начать передавать данные
         ' ежели приняли три байта, то выходим
         If Buf_len = 3 Then
            New_msg = 1                                     ' флаг нового сообщения установлен
         Else
            New_msg = 0                                     ' флаг нового сообщения сброшен
         End If
         Reset Twcr.twsta                                   ' ждем следующий байт и надеемся что их больше не будет =)
         Reset Twcr.twsto                                   ' но по совести надо NACK отсылать
         Set Twcr.twea
         'Twcr = &B11000100

      Case &H88 :                                           ' устройство уже адресовано, был неверно принят байт данных и послан NACK
      Case &HF8 :                                           ' просто пакость в регистрах
      Case &H00 :                                           ' ошибка на шине
         Reset Twcr.twsta
         Set Twcr.twsto
         Set Twcr.twea
         'Twcr = &B11010100
   ' статусы передатчика
      Case &HA8:                                            ' адресованы SLA+R пакетом
         If Buf_to_send_len = 0 Then
            Buf_to_send_len = 2
         End If
            Goto Loop_b8
      Case &HB8:                                            ' был передан очередной байт данных и получен ACK
         ' здесь если передать нечего, то стоп-сигнал (можно взять из состояния $C8)
Loop_b8:
         Twdr = Buf_to_send(buf_to_send_len)                ' загрузили байт данных
         Decr Buf_to_send_len
         If Buf_to_send_len > 0 Then
            Reset Twcr.twsta
            Reset Twcr.twsto                                ' передаем очередной байт данных
            Set Twcr.twea
         Else
            Reset Twcr.twsta
            Reset Twcr.twsto                                ' передаем последний байт данных
            Reset Twcr.twea
         End If
      Case &HC0:                                            ' был передан последний байт данных и получен NACK (конец передачи)
         Reset Twcr.twsta
         Reset Twcr.twsto                                   ' переходим в режим неадресованного ведомого, разрешено распознавание вызовов
         Set Twcr.twea
      Case &HC8:                                            ' после последнего байта мастер хочет ещё один (после передачи получен ACK)
         Set Twcr.twsto                                     ' переключение в режим неадресованного ведомого, послали STOP
         Reset Twcr.twsta
         Set Twcr.twea
      Case Else:                                            'неверный режим работы
         Twcr = &B01000100                                  ' перегрузили шину
   End Select
Return