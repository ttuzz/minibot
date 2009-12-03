$prog &HFF , &HAD , &HD7 , &HF8                             ' ��� ���������
'$prog &HFF , &HE0 , &HDD , &HF9                             ' ��� �������� 2.0
'27mhz 250kbps

$hwstack = 32
$swstack = 10
$framesize = 40

$regfile = "m88DEF.dat"
$baud = 115200
$crystal = 7372800


Config Pinb.5 = Output : Zb_sck Alias Portb.5 : Zb_sck = 0
Config Pinb.3 = Output : Zb_mosi Alias Portb.3 : Zb_mosi = 0
Config Pinb.1 = Output : Zb_cs Alias Portb.1 : Zb_cs = 1    ' ��� ���������
'Config Pinb.0 = Output : Zb_cs Alias Portb.0 : Zb_cs = 1    ' ��� ������� 2.0
Config Pind.2 = Input : Gdo2 Alias Pind.2
Config Pind.3 = Input : Gdo0 Alias Pind.3


Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Clockrate = 128 , Polarity = Low , Phase = 0

'� ����������� �� ���������� (� 1 �� 0)
Config Int1 = Falling

On Urxc Getchar                                             '�������������� ���������� �� �������� �� usart
On Int1 Getradio

Enable Interrupts                                           '��������� ����������
Enable Urxc
Enable Int1

Spiinit

Const �������_res = &H30
Const �������_fstxon = &H31
Const �������_xoff = &H32
Const �������_cal = &H33
Const �������_rx = &H34
Const �������_tx = &H35
Const �������_idle = &H36
Const �������_afc = &H37
Const �������_wor = &H38
Const �������_pwd = &H39
Const �������_frx = &H3A
Const �������_ftx = &H3B
Const �������_worrst = &H3C
Const �������_nop = &H3D

Const �������_fsctrl1 = &H0B
Const �������_fsctrl0 = &H0C
Const �������_freq2 = &H0D                                  '���������� ��� ���������� �����
Const �������_freq1 = &H0E                                  '���������� ��� ���������������
Const �������_freq0 = &H0F                                  '���������� ��� ���������� �����
Const �������_mdmcfg4 = &H10
Const �������_mdmcfg3 = &H11
Const �������_mdmcfg2 = &H12
Const �������_mdmcfg1 = &H13
Const �������_mdmcfg0 = &H14
Const �������_channr = &H0A
Const �������_deviatn = &H15
Const �������_frend1 = &H21
Const �������_frend0 = &H22
Const �������_mcsm2 = &H16
Const �������_mcsm1 = &H17
Const �������_mcsm0 = &H18
Const �������_foccfg = &H19
Const �������_bscfg = &H1A
Const �������_agcctrl2 = &H1B
Const �������_agcctrl1 = &H1C
Const �������_agcctrl0 = &H1D
Const �������_fscal3 = &H23
Const �������_fscal2 = &H24
Const �������_fscal1 = &H25
Const �������_fscal0 = &H26
Const �������_fstest = &H29
Const �������_test2 = &H2C
Const �������_test1 = &H2D
Const �������_test0 = &H2E
Const �������_iocfg2 = &H00
Const �������_iocfg1 = &H01
Const �������_iocfg0 = &H02
Const �������_pktctrl1 = &H07
Const �������_pktctrl0 = &H08
Const �������_addr = &H09
Const �������_pktlen = &H06
Const �������_fifothr = &H03
Const �������_patable = &H3E
Const �������_txfifo = &H3F
Const �������_rxbytes = &HFB
Const �������_rxfifob = &HFF

Waitms 250                                                  '#1 , "Start"
Ucsr0b.rxen0 = 0
Print "Start"
Ucsr0b.rxen0 = 1

Dim �� As Byte
Dim ������� As Byte
Dim ������� As Byte
Dim ����� As Byte
Dim ����� As Byte
Dim ����� As Byte
Dim ������ As Byte
Dim ��������1 As Byte


Dim Text As String * 15                                     '������ ��� ��������/������
Dim Text_priem As String * 15                               '����� ������������ ������
Dim Text_tmp As String * 15
Dim Txt_ As Byte
Dim S As Byte
Dim Ss As Byte
Dim I As Byte
Dim X As Integer
Dim ����� As Byte
Dim Isread As Byte                                          '���������� ������ ��2500


'����� ��� ��������� �������
Gosub ������������������

'�������� ��� �������� � �������� �� ���������
������� = �������_res : Gosub ��������������

'�������������� ������� FSCTRL (��������� �����������)
'Print #1 , "FSCTRL"
������� = �������_fsctrl1 : ����� = &H09 : Gosub ���������������������       ''08    '06
������� = �������_fsctrl0 : ����� = &H00 : Gosub ���������������������       '00

'�������������� ������� FREQ (������� ������� �������)
'Print #1 , "FREQ"
������� = �������_freq2 : ����� = &H5A : Gosub ���������������������       '5B
������� = �������_freq1 : ����� = &H1C : Gosub ���������������������       '75
������� = �������_freq0 : ����� = &H71 : Gosub ���������������������       'D4

'�������������� ������� MDMCFG (������������ ������)
'Print #1 , "MDMCFG"
������� = �������_mdmcfg4 : ����� = &H2D : Gosub ���������������������       ''86   '8B
������� = �������_mdmcfg3 : ����� = &H2F : Gosub ���������������������       ''75   'ED
������� = �������_mdmcfg2 : ����� = &H73 : Gosub ���������������������       ''03   '73
������� = �������_mdmcfg1 : ����� = &H22 : Gosub ���������������������       ''22   'C2
������� = �������_mdmcfg0 : ����� = &HE5 : Gosub ���������������������       ''e5   'EC

'�������������� ������� CHANNR (����� ������)
'Print #1 , "CHANNR"
������� = �������_channr : ����� = &H00 : Gosub ���������������������

'�������������� ������� DEVIATN (��������)
'Print #1 , "DEVIATN"
������� = �������_deviatn : ����� = &H01 : Gosub ���������������������       ''43  '00

'�������������� ������� FREND
'Print #1 , "FREND"
������� = �������_frend1 : ����� = &HB6 : Gosub ���������������������       ''56    '56
������� = �������_frend0 : ����� = &H10 : Gosub ���������������������       '10

'�������������� ������� MCSM (������������ �������� �������� �����)
'Print #1 , "MCSM"
������� = �������_mcsm2 : ����� = &H07 : Gosub ���������������������
������� = �������_mcsm1 : ����� = &H30 : Gosub ���������������������
������� = �������_mcsm0 : ����� = &H18 : Gosub ���������������������

'�������������� ������� FOCCFG (����������� ������ �������)
'Print #1 , "FOCCFG"
������� = �������_foccfg : ����� = &H1D : Gosub ���������������������       ''16    '16

'�������������� ������� BSCFG (������������ ������� �������������)
'Print #1 , "BSCFG"
������� = �������_bscfg : ����� = &H1C : Gosub ���������������������       ''6C      '6c

'�������������� ������� AGCCTRL (��������� ����������� ���������� � ����� ���������������� �����������)
'Print #1 , "AGCCTRL"
������� = �������_agcctrl2 : ����� = &HC7 : Gosub ���������������������       ''03   '43
������� = �������_agcctrl1 : ����� = &H00 : Gosub ���������������������       ''40  '40
������� = �������_agcctrl0 : ����� = &HB2 : Gosub ���������������������       ''91  '91

'�������������� ������� FSCAL (��������� ���������� �����������)
'Print #1 , "FSCAL"
������� = �������_fscal3 : ����� = &HEA : Gosub ���������������������       ''A9
������� = �������_fscal2 : ����� = &H0A : Gosub ���������������������       ''0A
������� = �������_fscal1 : ����� = &H00 : Gosub ���������������������       ''00
������� = �������_fscal0 : ����� = &H11 : Gosub ���������������������       ''11

'�������������� ������� FSTEST (������������ ������� �������������)
'Print #1 , "FSTEST"
������� = �������_fstest : ����� = &H59 : Gosub ���������������������

'�������������� ������� TEST (��������� ����������� ���������� � ����� ���������������� �����������)
'Print #1 , "TEST"
������� = �������_test2 : ����� = &H88 : Gosub ���������������������       ''81  '81
������� = �������_test1 : ����� = &H31 : Gosub ���������������������       ''35   '35
������� = �������_test0 : ����� = &H0B : Gosub ���������������������       '0B

'�������������� ������� IOCFG2 (������� ������ GDO2)
'Print #1 , "IOCFG2"
������� = �������_iocfg2 : ����� = &H0E : Gosub ���������������������

'�������������� ������� IOCFG0 (������� ������ GDO0)
'Print #1 , "IOCFG0"
������� = �������_iocfg0 : ����� = &H06 : Gosub ���������������������

'�������������� ������� PKTCTRL (��������� ������)
'Print #1 , "PKTCTRL"
������� = �������_pktctrl1 : ����� = &H04 : Gosub ���������������������       '04
������� = �������_pktctrl0 : ����� = &H45 : Gosub ���������������������       ''05

'�������������� ������� ADDR (����� ����������)
'Print #1 , "ADDR"
������� = �������_addr : ����� = &H00 : Gosub ���������������������

'�������������� ������� PKTLEN (����� ������)
'Print #1 , "PKTLEN"
������� = �������_pktlen : ����� = &HFF : Gosub ���������������������

'�������������� ������� FIFOTHR (������� ������������ ������������ ����)
'Print #1 , "FIFOTHR"
������� = �������_fifothr : ����� = &H07 : Gosub ���������������������

'��������� ������� ���������
'Print "PATABLE"
������� = �������_patable
Zb_cs = 0
'�������� ������-�����������
����� = &H44 : Gosub �������������������������              '44  '46   'HBF 'FB
Zb_cs = 1
������� = �������_patable
Zb_cs = 0
Gosub ���������������������������

Zb_cs = 1
Text = ""
Isread = 1                                                  '�� ��������� ������ ����

'��������� ���������� � ����� IDLE
������� = �������_idle : Gosub ��������������
'������� FIFO RX
������� = �������_frx : Gosub ��������������
'������� FIFO TX
������� = �������_ftx : Gosub ��������������

'������� �� ���������
������� = �������_rx : Gosub ��������������
Do

Loop
                                                   '''                                                      '
'���������
������������������:
   Zb_sck = 1
   Zb_mosi = 0
   Zb_cs = 0
   Waitus 1
   Zb_cs = 1
   Waitus 40
Return

��������������:
   Zb_cs = 0
   ������ = Spimove(�������)
   Zb_cs = 1
   Waitms 1
Return

����������������:
   ��������1 = ������� + 128
   Zb_cs = 0
   ������ = Spimove(��������1)
   ����� = Spimove(0)
   Zb_cs = 1
Return

���������������:
   Zb_cs = 0
   ������ = Spimove(�������)
   ����� = Spimove(0)
   Zb_cs = 1
Return

���������������������:
   Zb_cs = 0
   ������ = Spimove(�������)
   ����� = Spimove(�����)
   ��������1 = ������� + 128
   ������ = Spimove(��������1)
   ����� = Spimove(0)
   Zb_cs = 1
Return

�������������������������:
   ������ = Spimove(�������)
   ����� = Spimove(�����)
Return

���������������������������:
   ��������1 = ������� + 128
   ������ = Spimove(��������1)
   ����� = Spimove(0)
Return

���������������:
  Isread = 0
  '��������� ���������� � ����� IDLE
  ������� = �������_idle : Gosub ��������������
  '������� Fifo Tx
  ������� = �������_ftx : Gosub ��������������

  '��������� ����� TX

  Zb_cs = 0
  ������� = �������_txfifo Or &H40 : ������ = Spimove(�������)
  ������� = 2 : ������ = Spimove(�������)
  ������� = 0 : ������ = Spimove(�������)


  ������� = Ss : ������ = Spimove(�������)
  Zb_cs = 1

  ������� = �������_tx : Gosub ��������������
  'Waitms 1
  Text = ""
  Waitms 100
  Isread = 1
  '''
  '��������� ���������� � ����� IDLE
  ������� = �������_idle : Gosub ��������������
  '������� FIFO TX
  ������� = �������_ftx : Gosub ��������������
Return

�������������:
Text_priem = ""
   '1 �����
   '2 �����
   '3-n �����
   If Isread = 0 Then Goto Zbok

   ������� = �������_rxbytes : Gosub ���������������
   If ������ = 0 Then Goto Zbok
   Zb_cs = 0
   ������� = �������_rxfifob : ������ = Spimove(�������)
   ������ = Spimove(�������)                                ': Print Hex(������);
   ����� = ������ - 1
   ������ = Spimove(�������)                                ': Print Hex(������) ; "-";     '  #1 ,
   For I = 1 To �����
      ������ = Spimove(�������)
      Text_tmp = Chr(������)
      Text_priem = Text_priem + Text_tmp                    '  #1 ,������
   Next
   ������ = Spimove(�������)                                'Print Hex(������);
   ������ = Spimove(�������)                                'Print Hex(������)
   Zb_cs = 1
   Ucsr0b.rxen0 = 0
   Print Text_priem;                                        '  #1 ,������
   Print
   Ucsr0b.rxen0 = 1

Zbok:
'��������� ���������� � ����� Idle
������� = �������_idle : Gosub ��������������
'������� Fifo Rx
������� = �������_frx : Gosub ��������������
''''������� �� ���������
������� = �������_rx : Gosub ��������������
Zbok1:
Return

'��������
Getchar:
   Txt_ = Inkey()
   Ss = Txt_:
   Gosub ���������������
Return

'�������� ������ �� ��2500
Getradio:
   '�����
   If Gdo0 = 0 And Isread = 1 Then
      Gosub �������������
      '��������� ���������� � ����� Idle
      ������� = �������_idle : Gosub ��������������
      '������� Fifo Rx
      ������� = �������_frx : Gosub ��������������
      '������� �� ���������
      ������� = �������_rx : Gosub ��������������
   End If
   Eifr = 2
Return