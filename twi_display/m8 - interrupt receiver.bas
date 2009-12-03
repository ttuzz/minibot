'(
  Программа для приема 3х байтных пакетов через TWI
')

$regfile = "M8def.dat"
$crystal = 7372800
$baud = 9600
Config Serialin = Buffered , Size = 20

Waitms 100

Const Max_buf_len = 10                                      ' максимальный размер буфера(пакета)
Dim Buf(max_buf_len) As Byte
Dim Buf_len As Byte                                         ' текущий размер буфера(пакета)

Dim New_msg As Byte                                         ' флаг нового пакета

Dim Twi_control As Byte
Dim Twi_status As Byte
Dim Twi_data As Byte

Enable Twi
On Twi Twi_int_slave

' TWI init
Gosub Twi_init_slave

Enable Interrupts

Print "M8 twi test"
Do
   ' если принят новый пакет
    If New_msg = 1 Then
        New_msg = 0                                         ' очистить флаг
        Print "message: " ; Buf(1) ; " " ; Buf(2) ; " " ; Buf(3)       ' вывести первые три байта
    End If
    Waitms 10
Loop

End

' TWI инициализация слейв - приемник, слейв - передатчик (зависит от старт-пакета)
Twi_init_slave:
   Const Twi_slave_adr = &B01110000                         ' адрес слейва (наш адрес), TWCG (нулевой бит) сброшен, не распознаем общий вызов(адрес 0x00)
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
      Case &H60 :                                           ' адресованы
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
         Reset Twcr.twsta                                   ' освобождаем шину
         Reset Twcr.twsto
         Set Twcr.twea
         'Twcr = &B11000100

      Case &H88 :                                           ' устройство уже адресовано, был неверно принят байт данных и послан NACK
      Case &HF8 :                                           ' просто пакость в регистрах
      Case &H00 :                                           ' ошибка на шине
         Reset Twcr.twsta
         Set Twcr.twsto
         Set Twcr.twea
         'Twcr = &B11010100
      Case Else:
         Twcr = &B01000100                                  ' перегрузили шину
   End Select
Return