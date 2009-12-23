' Для работы функций необходимо как минимум +64 байт hwstack и +32 байт swstack
' Изза вложености функций. Максимум 2 вложености. Я не пересчитывал но параметры выставлял наверняка
' Если есть свободное время - пересчитайте максимальное для каждого значение и выставьте.
'$hwstack = 64                                               ' необходимо для передачи параметров
'$swstack = 32                                               ' прочего функциям... иначе не работает
 
Dim Cc_send_buffer(256) As Byte , Cc_recv_buffer(256) As Byte       ' буферы приема и передачи
Dim Cc_chip_status As Byte : Cc_chip_status = 0
Dim Cc_rssi_status As Word : Cc_rssi_status = 0
Dim Cc_rssi As Integer : Cc_rssi = 0
 
Declare Sub Cc_calc_rssi()                                  'расчет rssi согласно datasheet
Declare Sub Cc_reset()                                      'reset сс2500
Declare Sub Cc_power_up_reset()                             'reset на включение
Declare Sub Cc_rf_write_settings()                          'запись параметров в чип
Declare Sub Cc_spi_write_patable()                          'запись patable
 
Declare Sub Cc_spi_send_strobe(byval Command As Byte)       'посылка strobe команды
 
Declare Sub Cc_spi_write_register(byval Addr As Byte , Byval Value As Byte)
Declare Sub Cc_spi_write_register_burst(byval Addr As Byte , Byval Count As Byte)
 
Declare Sub Cc_spi_read_register_burst(byval Addr As Byte , Byval Count As Byte)
Declare Function Cc_spi_read_status(byval Status_register As Byte) As Byte
Declare Function Cc_spi_read_register(byval Addr As Byte) As Byte
 
Declare Sub Cc_rf_send_packet()
 
Declare Function Cc_rf_receive_packet() As Byte             'если result = 0 то режим будет idle и нет пакета
Declare Function Cc_rf_receive_packet_int06() As Byte       'если result = 0 то режим будет idle и нет пакета
 
'constant`s for cc2500
'------------------------------------------------------------------------------------------------------
' CC2500 STROBE, CONTROL AND STATUS REGSITER
Const Ccxxx0_iocfg2 = &H00                                  ' GDO2 output pin configuration
Const Ccxxx0_iocfg1 = &H01                                  ' GDO1 output pin configuration
Const Ccxxx0_iocfg0 = &H02                                  ' Gdo0 Output Pin Configuration
Const Ccxxx0_fifothr = &H03                                 ' Rx Fifo And Tx Fifo Thresholds
Const Ccxxx0_sync1 = &H04                                   ' Sync word, high byte
Const Ccxxx0_sync0 = &H05                                   ' Sync word, low byte
Const Ccxxx0_pktlen = &H06                                  ' Packet Length
Const Ccxxx0_pktctrl1 = &H07                                ' Packet Automation Control
Const Ccxxx0_pktctrl0 = &H08                                ' Packet Automation Control
Const Ccxxx0_addr = &H09                                    ' Device address
Const Ccxxx0_channr = &H0A                                  ' Channel number
Const Ccxxx0_fsctrl1 = &H0B                                 ' Frequency synthesizer control
Const Ccxxx0_fsctrl0 = &H0C                                 ' Frequency synthesizer control
Const Ccxxx0_freq2 = &H0D                                   ' Frequency control word, high byte
Const Ccxxx0_freq1 = &H0E                                   ' Frequency control word, middle byte
Const Ccxxx0_freq0 = &H0F                                   ' Frequency control word, low byte
Const Ccxxx0_mdmcfg4 = &H10                                 ' Modem configuration
Const Ccxxx0_mdmcfg3 = &H11                                 ' Modem configuration
Const Ccxxx0_mdmcfg2 = &H12                                 ' Modem configuration
Const Ccxxx0_mdmcfg1 = &H13                                 ' Modem configuration
Const Ccxxx0_mdmcfg0 = &H14                                 ' Modem configuration
Const Ccxxx0_deviatn = &H15                                 ' Modem deviation setting
Const Ccxxx0_mcsm2 = &H16                                   ' Main Radio Control State Machine configuration
Const Ccxxx0_mcsm1 = &H17                                   ' Main Radio Control State Machine configuration
Const Ccxxx0_mcsm0 = &H18                                   ' Main Radio Control State Machine configuration
Const Ccxxx0_foccfg = &H19                                  ' Frequency Offset Compensation configuration
Const Ccxxx0_bscfg = &H1A                                   ' Bit Synchronization configuration
Const Ccxxx0_agcctrl2 = &H1B                                ' AGC control
Const Ccxxx0_agcctrl1 = &H1C                                ' AGC control
Const Ccxxx0_agcctrl0 = &H1D                                ' AGC control
Const Ccxxx0_worevt1 = &H1E                                 ' High byte Event 0 timeout
Const Ccxxx0_worevt0 = &H1F                                 ' Low byte Event 0 timeout
Const Ccxxx0_worctrl = &H20                                 ' Wake On Radio control
Const Ccxxx0_frend1 = &H21                                  ' Front end RX configuration
Const Ccxxx0_frend0 = &H22                                  ' Front end TX configuration
Const Ccxxx0_fscal3 = &H23                                  ' Frequency synthesizer calibration
Const Ccxxx0_fscal2 = &H24                                  ' Frequency synthesizer calibration
Const Ccxxx0_fscal1 = &H25                                  ' Frequency synthesizer calibration
Const Ccxxx0_fscal0 = &H26                                  ' Frequency synthesizer calibration
Const Ccxxx0_rcctrl1 = &H27                                 ' RC oscillator configuration
Const Ccxxx0_rcctrl0 = &H28                                 ' RC oscillator configuration
Const Ccxxx0_fstest = &H29                                  ' Frequency synthesizer calibration control
Const Ccxxx0_ptest = &H2A                                   ' Production test
Const Ccxxx0_agctest = &H2B                                 ' AGC test
Const Ccxxx0_test2 = &H2C                                   ' Various test settings
Const Ccxxx0_test1 = &H2D                                   ' Various test settings
Const Ccxxx0_test0 = &H2E                                   ' Various test settings
'------------------------------------------------------------------------------------------------------
' Strobe 14 commands
Const Ccxxx0_sres = &H30                                    ' Reset chip.
Const Ccxxx0_sfstxon = &H31                                 ' Enable and calibrate frequency synthesizer (if MCSM0.FS_AUTOCAL=1).
Const Ccxxx0_sxoff = &H32                                   ' Turn off crystal oscillator.
Const Ccxxx0_scal = &H33                                    ' Calibrate frequency synthesizer and turn it off
Const Ccxxx0_srx = &H34                                     ' Enable RX. Perform calibration first if coming from IDLE and
Const Ccxxx0_stx = &H35                                     ' In IDLE state: Enable TX. Perform calibration first if
Const Ccxxx0_sidle = &H36                                   ' Exit RX / TX, turn off frequency synthesizer and exit
Const Ccxxx0_safc = &H37                                    ' Perform AFC adjustment of the frequency synthesizer
Const Ccxxx0_swor = &H38                                    ' Start automatic RX polling sequence (Wake-on-Radio)
Const Ccxxx0_spwd = &H39                                    ' Enter power down mode when CSn goes high.
Const Ccxxx0_sfrx = &H3A                                    ' Flush the RX FIFO buffer.
Const Ccxxx0_sftx = &H3B                                    ' Flush the TX FIFO buffer.
Const Ccxxx0_sworrst = &H3C                                 ' Reset real time clock.
Const Ccxxx0_snop = &H3D                                    ' No operation. May be used to pad strobe commands to two
'------------------------------------------------------------------------------------------------------
' status bytes
Const Ccxxx0_partnum = &H30
Const Ccxxx0_version = &H31
Const Ccxxx0_freqest = &H32
Const Ccxxx0_lqi = &H33
Const Ccxxx0_rssi = &H34
Const Ccxxx0_marcstate = &H35
Const Ccxxx0_wortime1 = &H36
Const Ccxxx0_wortime0 = &H37
Const Ccxxx0_pktstatus = &H38
Const Ccxxx0_vco_vc_dac = &H39
Const Ccxxx0_txbytes = &H3A
Const Ccxxx0_rxbytes = &H3B
Const Ccxxx0_patable = &H3E
Const Ccxxx0_fifo = &H3F
 
Gosub __main
 
'Расчет RSSI по даташиту.
'Для указания нужного OFFSET см data sheet стр.31 для вашей скорости.
Sub Cc_calc_rssi()
   Local L_tmp As Byte
 
   L_tmp = Cc_spi_read_status(ccxxx0_rssi)
   Cc_rssi = L_tmp
   If Cc_rssi >= 128 Then Cc_rssi = Cc_rssi - 256
   Cc_rssi = Cc_rssi / 2
   Cc_rssi = Cc_rssi - 71
End Sub
 
Sub Cc_rf_send_packet()
   Disable Interrupts
   Local Length_packet As Byte , I_l As Byte
 
   Length_packet = Cc_send_buffer(1)
   Decr Cc_send_buffer(1)
   Call Cc_spi_send_strobe(ccxxx0_sidle)
   Call Cc_spi_send_strobe(ccxxx0_sftx)
   Call Cc_spi_write_register_burst(ccxxx0_fifo , Length_packet)
   Call Cc_spi_send_strobe(ccxxx0_stx)
   While Gdo0 = 0
   Wend
   While Gdo0 = 1
   Wend
   Enable Interrupts
End Sub
 
Function Cc_rf_receive_packet() As Byte
   Local L_tmp1 As Byte
 
   L_tmp1 = Cc_chip_status And &H70                         ' если не в RX режиме то включаем его
   If L_tmp1 <> &H10 Then Call Cc_spi_send_strobe(ccxxx0_srx)
 
   While Gdo0 = 0                                           'Wait for GDO0 to be set -> sync received
   Wend
   While Gdo0 = 1                                           'Wait for GDO0 to be cleared -> end of packet
   Wend
   Cc_rf_receive_packet = Cc_rf_receive_packet_int06()      'получаем пакет
End Function
 
' Уже нахожусь в RX статусе и пакет уже получен в FIFO буфере
Function Cc_rf_receive_packet_int06() As Byte
   Local L_tmp As Byte , L_byte As Byte
 
   Cc_rf_receive_packet_int06 = 0
   L_byte = Cc_spi_read_status(ccxxx0_rxbytes)
   L_tmp = L_byte And &H80
   If L_tmp = 0 Then                                        'если переполнен буфер нахрен такой буфер
      L_tmp = L_byte And &H7F
      If L_tmp > 0 Then                                     'MCSM1.CRC_AUTOFLUSH = 1 APPEND_STATUS = 0
         Call Cc_spi_read_register_burst(ccxxx0_fifo , L_tmp)
'         Call Cc_calc_rssi()
         Incr Cc_recv_buffer(1)
         Cc_rf_receive_packet_int06 = 1
      End If
   Else
      Call Cc_spi_send_strobe(ccxxx0_sidle)
      Call Cc_spi_send_strobe(ccxxx0_sfrx)                  'нужно очистить буфер приема
   End If
End Function
 
Sub Cc_rf_write_settings()
   Call Cc_spi_write_register(ccxxx0_fsctrl1 , Cc2500_fsctrl1)
   Call Cc_spi_write_register(ccxxx0_fsctrl0 , Cc2500_fsctrl0)
 
   Call Cc_spi_write_register(ccxxx0_freq2 , Cc2500_freq2)
   Call Cc_spi_write_register(ccxxx0_freq1 , Cc2500_freq1)
   Call Cc_spi_write_register(ccxxx0_freq0 , Cc2500_freq0)
 
   Call Cc_spi_write_register(ccxxx0_mdmcfg4 , Cc2500_mdmcfg4)
   Call Cc_spi_write_register(ccxxx0_mdmcfg3 , Cc2500_mdmcfg3)
   Call Cc_spi_write_register(ccxxx0_mdmcfg2 , Cc2500_mdmcfg2)
   Call Cc_spi_write_register(ccxxx0_mdmcfg1 , Cc2500_mdmcfg1)
   Call Cc_spi_write_register(ccxxx0_mdmcfg0 , Cc2500_mdmcfg0)
 
   Call Cc_spi_write_register(ccxxx0_channr , Cc2500_channr)
   Call Cc_spi_write_register(ccxxx0_deviatn , Cc2500_deviatn)
 
   Call Cc_spi_write_register(ccxxx0_frend1 , Cc2500_frend1)
   Call Cc_spi_write_register(ccxxx0_frend0 , Cc2500_frend0)
 
   Call Cc_spi_write_register(ccxxx0_mcsm2 , Cc2500_mcsm2)
   Call Cc_spi_write_register(ccxxx0_mcsm1 , Cc2500_mcsm1)
   Call Cc_spi_write_register(ccxxx0_mcsm0 , Cc2500_mcsm0)
 
   Call Cc_spi_write_register(ccxxx0_foccfg , Cc2500_foccfg)
   Call Cc_spi_write_register(ccxxx0_bscfg , Cc2500_bscfg)
 
   Call Cc_spi_write_register(ccxxx0_agcctrl2 , Cc2500_agcctrl2)
   Call Cc_spi_write_register(ccxxx0_agcctrl1 , Cc2500_agcctrl1)
   Call Cc_spi_write_register(ccxxx0_agcctrl0 , Cc2500_agcctrl0)
 
   Call Cc_spi_write_register(ccxxx0_fscal3 , Cc2500_fscal3)
   Call Cc_spi_write_register(ccxxx0_fscal2 , Cc2500_fscal2)
   Call Cc_spi_write_register(ccxxx0_fscal1 , Cc2500_fscal1)
   Call Cc_spi_write_register(ccxxx0_fscal0 , Cc2500_fscal0)
 
   Call Cc_spi_write_register(ccxxx0_rcctrl1 , Cc2500_rcctrl1)
   Call Cc_spi_write_register(ccxxx0_rcctrl0 , Cc2500_rcctrl0)
 
   Call Cc_spi_write_register(ccxxx0_ptest , Cc2500_ptest)
   'call Cc_spi_write_register(ccxxx0_fstest , Cc2500_fstest)
   Call Cc_spi_write_register(ccxxx0_test2 , Cc2500_test2)
   Call Cc_spi_write_register(ccxxx0_test1 , Cc2500_test1)
   Call Cc_spi_write_register(ccxxx0_test0 , Cc2500_test0)
 
   Call Cc_spi_write_register(ccxxx0_fifothr , Cc2500_fifothr)
 
   Call Cc_spi_write_register(ccxxx0_iocfg2 , Cc2500_iocfg2)
  ' Call Cc_spi_write_register(ccxxx0_iocfg1 , Cc2500_iocfg1)
   Call Cc_spi_write_register(ccxxx0_iocfg0 , Cc2500_iocfg0)
 
   Call Cc_spi_write_register(ccxxx0_sync1 , Cc2500_sync1)
   Call Cc_spi_write_register(ccxxx0_sync0 , Cc2500_sync0)
   Call Cc_spi_write_register(ccxxx0_pktctrl1 , Cc2500_pktctrl1)
   Call Cc_spi_write_register(ccxxx0_pktctrl0 , Cc2500_pktctrl0)
   Call Cc_spi_write_register(ccxxx0_addr , Cc2500_addr)
   Call Cc_spi_write_register(ccxxx0_pktlen , Cc2500_pktlen)
End Sub
 
Sub Cc_power_up_reset()
   Zb_cs = 1
   Waitus 1
   Zb_cs = 0
   Waitus 1
   Zb_cs = 1
   Waitus 42
   Call Cc_reset()
End Sub
 
Sub Cc_reset()
   Zb_cs = 0
   Cc_chip_status = Spimove(ccxxx0_sres)
   Zb_cs = 1
End Sub
 
Sub Cc_spi_send_strobe(byval Command As Byte)
   Zb_cs = 0
   While Zb_miso = 1
   Wend
   Cc_chip_status = Spimove(command)
   Zb_cs = 1
End Sub
 
Sub Cc_spi_write_register_burst(byval Addr As Byte , Byval Count As Byte)
   Local L_i As Byte
 
   Zb_cs = 0
   While Zb_miso = 1
   Wend
   Addr = Addr Or &H40
   Cc_chip_status = Spimove(addr)
   For L_i = 1 To Count
      Addr = Spimove(cc_send_buffer(l_i))
   Next L_i
   Zb_cs = 1
End Sub
 
Sub Cc_spi_write_register(byval Addr As Byte , Byval Value As Byte)
   Zb_cs = 0
   While Zb_miso = 1
   Wend
   Cc_chip_status = Spimove(addr)
   Addr = Spimove(value)
   Zb_cs = 1
End Sub
 
Sub Cc_spi_read_register_burst(byval Addr As Byte , Byval Count As Byte)
   Local L_i As Byte
 
   Zb_cs = 0
   While Zb_miso = 1
   Wend
   Addr = Addr Or &HC0
   Cc_chip_status = Spimove(addr)
   For L_i = 1 To Count
      Cc_recv_buffer(l_i) = Spimove(0)
   Next L_i
   Zb_cs = 1
End Sub
 
Function Cc_spi_read_register(byval Addr As Byte) As Byte
   Zb_cs = 0
   While Zb_miso = 1
   Wend
   Addr = Addr Or &H80
   Cc_chip_status = Spimove(addr)
   Cc_spi_read_register = Spimove(0)
   Zb_cs = 1
End Function
 
Function Cc_spi_read_status(byval Status_register As Byte) As Byte
   Zb_cs = 0
   While Zb_miso = 1
   Wend
   Status_register = Status_register Or &HC0
   Cc_chip_status = Spimove(status_register)
   Cc_spi_read_status = Spimove(0)
   Zb_cs = 1
End Function
 
Sub Cc_spi_write_patable()
   Local L_tmp As Byte
 
   Call Cc_spi_send_strobe(ccxxx0_sidle)
   For L_tmp = 1 To 8
      Cc_send_buffer(l_tmp) = Cc_patable(l_tmp)
   Next L_tmp
   Call Cc_spi_write_register_burst(ccxxx0_patable , 8)
   Call Cc_spi_send_strobe(ccxxx0_scal)
End Sub
 
__main:
 
Call Cc_power_up_reset()
Call Cc_rf_write_settings()
Call Cc_spi_write_patable()
Wait 1