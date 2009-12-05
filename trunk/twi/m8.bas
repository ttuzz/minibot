'(
   Программа для приема пакетов по i2c, использет хардварный TWI.
   ВНИМАНИЕ, ОБЩИЕ ВЫЗОВЫ НЕ ПОДДЕРЖИВАЮТСЯ,
   ФЛАГ TWCG ДОЛЖЕН ВСЕГДА НАХОДИТСЯ В СБРОШЕННОМ СОСТОЯНИИ
')
$regfile = "m88def.dat"
$crystal = 7372800
$baud = 9600
Config Serialin = Buffered , Size = 20

' Настройка модуля
Const Twi_slave_adr = &B01110000                            ' !!содержимое TWAR!!, адрес слейва (7бит+[1 бит TWCG]), TWCG (нулевой бит) должен быть сброшен, т.е. не распознаем общий вызов(адрес 0x00)

Dim Twi_busy As Bit                                         ' флаг занятости модуля приемом/передачей

Const Max_msg_len = 10                                      ' максимальный размер буфера(пакета)
   Const Msg_expect_len = 3                                 ' ожидаемый размер принятого сообщения. если не равен текущему на момент окончания приема, то сообщение отбрасывается
   Dim Msg(max_msg_len) As Byte
   Dim Msg_len As Byte                                      ' текущий размер буфера(пакета)
   Dim Msg_new As Bit                                       ' флаг нового сообщения

Const Max_out_len = 10                                      ' максимальный размер буфера отправки
   Dim Msg_out(max_out_len) As Byte                         ' буфер отправки
   Dim Msg_out_len As Byte                                  ' текущий размер буфера отправки

Dim Twi_status As Byte                                      ' статус регистра TWSR
On Twi Twi_int_slave                                        ' конфигурация прерывания
Enable Twi


'!!!!
' пример заполнения сообщения для передачи
   Msg_out(1) = "B"                                         ' данные
   Msg_out(2) = "T"                                         'обратный порядок байт
   Msg_out(3) = "S"
   Msg_out_len = 3                                          ' размер
'!!!!

' Инициализация ведомого
Gosub Twi_init_slave

' Светодиод отладки
Config Pind.7 = Output : Led Alias Portd.7 : Led = 0

Enable Interrupts

Print "M88 twi test"
Do
   Led = Twi_busy                                           ' диод показывает состояние приема/передачи по TWI
   If Msg_new = 1 Then                                      ' если принят новый пакет
      Reset Msg_new                                         ' очистить флаг
      Print "message: " ; Chr(msg(1)) ; " " ; Chr(msg(2)) ; " " ; Chr(msg(3))       ' вывести первые три байта
   End If
   Waitms 10
Loop

End

' TWI инициализация слейв - приемник, слейв - передатчик (зависит от старт-пакета)
Twi_init_slave:
   Reset Msg_new                                            ' очищаем пакет
   Msg_len = 0
   Reset Twi_busy
   Twsr = 0                                                 ' очищаем статус, частота обмена = fclk/(16 + 2*TWBR*4^TWPS), для ведомого состояние регистров безразлично
   Twdr = &HFF                                              ' обнуляем данные
   Twar = Twi_slave_adr                                     ' устанавливаем адрес слейва
   Reset Twar.twgce                                         ' запрет распознавания общего адреса

   Set Twcr.twea                                            ' разрешение автоматической генерации подтверждения
   Reset Twcr.twsta
   Reset Twcr.twsto
   Set Twcr.twen                                            ' разрешение работы модуля
   Set Twcr.twie                                            ' разрешаем прерывания
Return

Twi_int_slave:
   Twi_status = Twsr And &HF8                               ' отбрасываем 3 лишних байта [-,TWSP1,TWSP2]
   Select Case Twi_status
   ' статусы приемника
   Case &H60:                                               ' адресованы SLA+W пакетом
      Msg_len = 0
      Reset Msg_new
      Set Twi_busy
      Reset Twcr.twsto                                      ' будет послан ACK
      Set Twcr.twea
   Case &H80:                                               ' адресованы, был принят байт данных и послан ACK
      If Msg_len < Max_msg_len Then                         ' приняли байт (их может быть много)
         Incr Msg_len
         Msg(msg_len) = Twdr
      End If
      If Msg_len <> Max_msg_len Then                        ' в буффер поместится следующий байт?
         Reset Twcr.twsto                                   ' ещё можем принимать данные, будет послан ACK
         Set Twcr.twea
      Else
         Reset Twcr.twsto                                   ' больше данных невозможно принять, будет послан NACK
         Reset Twcr.twea                                    '   прием адресного пакета заканчивается до тех пор, пока не будет сформирован стоп/повстарт на шине(побочный эффект)
      End If
   Case &H88:                                               ' адресованы, был принят байт данных, не помещающийся в буффер, т.е. послан NACK
      Reset Twcr.twsta                                      ' переключение в режим неадресованного ведомого
      Reset Twcr.twsto
      Set Twcr.twea
      Reset Twi_busy
   Case &HA0:                                               ' стоп или повстарт в то время, когда адресованы
      If Msg_len = Msg_expect_len Then                      ' принятые данные соотвествуют по размеру пакету?
         Set Msg_new                                        ' принятые данные - новое сообщение
      Else
         Reset Msg_new
      End If
      Reset Twcr.twsta                                      ' переход в режим неадресованного ведомого, распознавание SLA пакетов разрешено
      Reset Twcr.twsto
      Set Twcr.twea
      Reset Twi_busy
' статусы передатчика
   Case &HA8:                                               ' адресованы SLA+R пакетом
      Set Twi_busy
      Goto Twi_int_slave_state_b8
   Case &HB8:                                               ' был передан очередной байт данных и получен ACK (или только будет передан байт, если пришли из состояния &HA8)
Twi_int_slave_state_b8:
      If Msg_out_len = 0 Then                               ' данных для передачи нет?
         Twdr = &HFF                                        ' загрузили байт-заглушку, такое значение всегда принимает мастер, если приемник оключен
         Reset Twcr.twsto                                   ' это последний байт, NACK должен быть принят
         Reset Twcr.twea
      Else
         Twdr = Msg_out(msg_out_len)                           ' загрузили байт данных
         Decr Msg_out_len
         If Msg_out_len = 0 Then
            Reset Twcr.twsto                                   ' это последний байт, NACK должен быть принят
            Reset Twcr.twea
         Else
            Reset Twcr.twsto                                   ' будет послан очередной байт данных
            Set Twcr.twea
         End If
      End If
   Case &HC0:                                               ' был передан последний байт данных и получен NACK (конец передачи)
      Reset Twcr.twsta                                      ' переходим в режим неадресованного ведомого, разрешено распознавание вызовов
      Reset Twcr.twsto
      Set Twcr.twea
      Reset Twi_busy
   Case &HC8:                                               ' был передан последний байт данных и получен ACK (также означает, после последнего байта мастер хочет ещё один)
      Reset Twcr.twsta                                      ' переключение в режим неадресованного ведомого, разрешено распознавание вызовов
      Reset Twcr.twsto
      Set Twcr.twea
' общие состояния
   Case &HF8:                                               ' неопределенность состояния, в прерывании никогда не произойдет
   Case &H00:                                               ' ошибка на шине
      Reset Twcr.twsta
      Set Twcr.twsto
      Set Twcr.twea
      Reset Twi_busy
   Case Else:                                               ' неверный режим работы (например, если разрешено распознавание общих вызовов, которое не поддерживается!)
      'Twcr = &B01000100                                     ' перегрузили шину
   End Select
Return