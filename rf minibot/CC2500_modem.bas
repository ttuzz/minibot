Const Is_minibot = 1
   ' 1 - Минибот
   ' 0 - мегаплата



#if Is_minibot = 1
   '$prog &HFF , &HE0 , &HDD , &HF9                           ' для минибота 2.0
   Config Pinb.0 = Output : Zb_cs Alias Portb.0 : Zb_cs = 1 ' для МиниБот 2.0
   Config Pinb.2 = Output : Servo Alias Portb.2 : Reset Servo
   Const Cc2500_freq2 = &H5A
   Const Cc2500_freq1 = &H1C
   Const Cc2500_freq0 = &H71
#elseif Is_minibot = 0
   '$prog &HFF , &HAD , &HD7 , &HF8                           ' для мегаплаты
   Config Pinb.1 = Output : Zb_cs Alias Portb.1 : Zb_cs = 1 ' для мегаплаты
   'Config Pinc.0 = Output : 'led Alias Portc.0 : 'led = 1
   Const Cc2500_freq2 = &H5A
   Const Cc2500_freq1 = &H1C
   Const Cc2500_freq0 = &H71
#endif
   Const Transmit_buffer_size = 256                         ' размер буфера для передачи
   Const Receive_buffer_size = 256                          ' размер буфера для према

$regfile = "m88DEF.dat"
$baud = 115200
$crystal = 7372800
$hwstack = 64
$swstack = 64

Config Pind.2 = Input : Gdo2 Alias Pind.2
Config Pind.3 = Input : Gdo0 Alias Pind.3
Config Pinb.5 = Output : Zb_sck Alias Portb.5 : Zb_sck = 0
Config Pinb.4 = Input : Zb_miso Alias Pinb.4
Config Pinb.3 = Output : Zb_mosi Alias Portb.3 : Zb_mosi = 0

Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Clockrate = 128 , Polarity = Low , Phase = 0
Spiinit

$include "settings\MSK500RX.bas"
$include "include\cc2500.bas"

On Int1 Gdo0_int1
On Urxc Getchar                                             'переопределяем прерывание на передачу по usart
Config Int1 = Falling
Enable Int1
Enable Urxc
Disable Interrupts

' процедуры
Declare Sub Print_chr(byval S As Byte)

Dim I As Byte
Dim Recvstat As Byte , Comchar As Byte , Buf_count As Byte

'Checksum
Dim Recv_csum As Byte , Recv_recv_csum As Byte , Trans_csum As Byte

Call Cc_spi_read_register_burst(ccxxx0_patable , 8)

Call Cc_spi_send_strobe(ccxxx0_srx)

Buf_count = 1
Trans_csum = 1

Enable Interrupts

Wait 7

Call Print_chr(&H40)

Do

Loop

'отправка
Getchar:
   Comchar = Inkey()
   Incr Buf_count
   Cc_send_buffer(buf_count) = Comchar
   Trans_csum = Trans_csum + Comchar
   #if Is_minibot = 0
      Call Print_chr(comchar)
   #endif

   If Comchar = 13 Then
      ''led = 0
      Incr Buf_count
      Cc_send_buffer(buf_count) = Trans_csum

      Cc_send_buffer(1) = Buf_count
      Call Cc_rf_send_packet()
      Call Cc_spi_send_strobe(ccxxx0_sidle)
      Call Cc_spi_send_strobe(ccxxx0_srx)

      Buf_count = 1
      Trans_csum = 1
      ''led = 1
   End If
Return

Gdo0_int1:
   Disable Interrupts
   ''led = 0
   Recvstat = Cc_rf_receive_packet_int06()
   If Recvstat = 1 Then
      Recv_recv_csum = Cc_recv_buffer(cc_recv_buffer(1))
      Decr Cc_recv_buffer(1)
      Recv_csum = 1                                         ' начало подсчета чексуммы
      For I = 2 To Cc_recv_buffer(1)
         Recv_csum = Recv_csum + Cc_recv_buffer(i)          ' для каждого байта посылки, кроме чексум-байта
      Next
      If Recv_recv_csum = Recv_csum Then                    ' если чексуммы совпадают
         For I = 2 To Cc_recv_buffer(1)
            Call Print_chr(cc_recv_buffer(i))
         Next I
      End If
   Else
      Call Cc_spi_send_strobe(ccxxx0_srx)
   End If
   ''led = 1
      Call Cc_spi_send_strobe(ccxxx0_sidle)
      Call Cc_spi_send_strobe(ccxxx0_sfrx)
      Call Cc_spi_send_strobe(ccxxx0_srx)
   Enable Interrupts
   Eifr = 2
Return

Sub Print_chr(byval S As Byte)
   Reset Ucsr0b.rxen0
      Bitwait Ucsr0a.udre0 , Set
      Udr = S
      Set Ucsr0a.txc0                                       ' очищаю флаг прерывания
      Bitwait Ucsr0a.txc0 , Set                             ' жду пока передатчик не передаст весь пакет (из внутреннего буфера, не UDR)
   Set Ucsr0b.rxen0
End Sub