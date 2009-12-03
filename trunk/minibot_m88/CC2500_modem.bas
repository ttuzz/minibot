' ПРОША ДЛЯ МИНИБОТА MEGA8
'$prog &HFF , &HE0 , &HDD , &HF9                             ' для минибота 2.0

$regfile = "m88DEF.dat"
$baud = 115200
$crystal = 7372800
$hwstack = 64
$swstack = 32

Config Pinc.0 = Output : Led Alias Portc.0 : Led = 1

Config Pinb.0 = Output : Zb_cs Alias Portb.0 : Zb_cs = 1    ' для МиниБот 2.0

Config Pind.2 = Input : Gdo2 Alias Pind.2
Config Pind.3 = Input : Gdo0 Alias Pind.3
Config Pinb.5 = Output : Zb_sck Alias Portb.5 : Zb_sck = 0
Config Pinb.4 = Input : Zb_miso Alias Pinb.4
Config Pinb.3 = Output : Zb_mosi Alias Portb.3 : Zb_mosi = 0

Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Clockrate = 128 , Polarity = Low , Phase = 0
Spiinit

$include "settings\MSK500RX.bas"
$include "include\cc2500.bas"

'On Int1 Gdo0_int1
'On Urxc Getchar                                             'переопределяем прерывание на передачу по usart
Config Int1 = Falling
'Enable Int1
'Enable Urxc
Disable Interrupts

Dim I As Byte
Dim Recvstat As Byte , Comchar As Byte , Buf_count As Byte

Call Cc_spi_read_register_burst(ccxxx0_patable , 8)

Call Cc_spi_send_strobe(ccxxx0_srx)

Buf_count = 1

' делаем софтварный уарт
Const U_input = 11
Const U_output = 12

Open "comc.5:9600,8,n,1" For Input As #10
Open "comc.4:9600,8,n,1" For Output As #u_output



'Open "comc.4:9600,8,n,1" For Input As #10
'Open "comc.5:9600,8,n,1" For Output As #11

'Config Servos = 1 , Servo1 = Portb.2 , Reload = 10

Enable Interrupts

Dim Count As Byte
Dim Pos As Byte
'Servo(1) = 0
'Servo(2) = 0
'Waitms 500
'(
For Count = 80 To 160
   Servo(1) = Count
   Servo(2) = Count
   Waitms 100
Next
')
'Config Pinc.2 = Output
'Portc.2 = 1


Do
'(
   For Count = 0 To 100
      Print #u_output , Count
      Waitms 500
   Next
   Waitms 500
')
'(
   For Count = 0 To 100
      Servo(1) = Count
      Waitms 250
   Next
   Wait 1
   For Count = 100 To 0 Step -1
      Servo(1) = Count
      Waitms 250
   Next
   Wait 1
')
'(
   Input #10 , Pos , Noecho
   If Pos = 10 Then
      Portc.2 = 1
   Else
      Portc.2 = 0
   End If
   Servo(1) = Pos
   Servo(2) = Pos
')
   For Count = 0 To 100
      Print #u_output , Count
      Waitms 500
      'Servo(1) = Count + 60
   Next
   Waitms 500
Loop

'отправка
Getchar:
   Comchar = Inkey()
   If Comchar = 13 Then
      Led = 0
      Cc_send_buffer(1) = Buf_count
      Call Cc_rf_send_packet()
      Call Cc_spi_send_strobe(ccxxx0_sidle)
      Call Cc_spi_send_strobe(ccxxx0_srx)
   Ucsr0b.rxen0 = 0
      For I = 1 To Buf_count
         Print Chr(cc_send_buffer(i)) ;
      Next I
      Print
   Ucsr0b.rxen0 = 1
      Buf_count = 1
      Led = 1
   Else
      Incr Buf_count
      Cc_send_buffer(buf_count) = Comchar
   End If
Return

Gdo0_int1:
   Disable Interrupts
   Led = 0
   Recvstat = Cc_rf_receive_packet_int06()
   If Recvstat = 1 Then
   Ucsr0b.rxen0 = 0
      For I = 2 To Cc_recv_buffer(1)
         Print Chr(cc_recv_buffer(i)) ;
      Next I
   Ucsr0b.rxen0 = 1
   Else
      Call Cc_spi_send_strobe(ccxxx0_srx)
   End If
   Led = 1
      Call Cc_spi_send_strobe(ccxxx0_sidle)
      Call Cc_spi_send_strobe(ccxxx0_sfrx)
      Call Cc_spi_send_strobe(ccxxx0_srx)
   Enable Interrupts
   Eifr = 2
Return