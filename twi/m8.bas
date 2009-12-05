'(
   ��������� ��� ������ ������� �� i2c, ��������� ���������� TWI.
   ��������, ����� ������ �� ��������������,
   ���� TWCG ������ ������ ��������� � ���������� ���������
')
$regfile = "m88def.dat"
$crystal = 7372800
$baud = 9600
Config Serialin = Buffered , Size = 20

' ��������� ������
Const Twi_slave_adr = &B01110000                            ' !!���������� TWAR!!, ����� ������ (7���+[1 ��� TWCG]), TWCG (������� ���) ������ ���� �������, �.�. �� ���������� ����� �����(����� 0x00)

Dim Twi_busy As Bit                                         ' ���� ��������� ������ �������/���������

Const Max_msg_len = 10                                      ' ������������ ������ ������(������)
   Const Msg_expect_len = 3                                 ' ��������� ������ ��������� ���������. ���� �� ����� �������� �� ������ ��������� ������, �� ��������� �������������
   Dim Msg(max_msg_len) As Byte
   Dim Msg_len As Byte                                      ' ������� ������ ������(������)
   Dim Msg_new As Bit                                       ' ���� ������ ���������

Const Max_out_len = 10                                      ' ������������ ������ ������ ��������
   Dim Msg_out(max_out_len) As Byte                         ' ����� ��������
   Dim Msg_out_len As Byte                                  ' ������� ������ ������ ��������

Dim Twi_status As Byte                                      ' ������ �������� TWSR
On Twi Twi_int_slave                                        ' ������������ ����������
Enable Twi


'!!!!
' ������ ���������� ��������� ��� ��������
   Msg_out(1) = "B"                                         ' ������
   Msg_out(2) = "T"                                         '�������� ������� ����
   Msg_out(3) = "S"
   Msg_out_len = 3                                          ' ������
'!!!!

' ������������� ��������
Gosub Twi_init_slave

' ��������� �������
Config Pind.7 = Output : Led Alias Portd.7 : Led = 0

Enable Interrupts

Print "M88 twi test"
Do
   Led = Twi_busy                                           ' ���� ���������� ��������� ������/�������� �� TWI
   If Msg_new = 1 Then                                      ' ���� ������ ����� �����
      Reset Msg_new                                         ' �������� ����
      Print "message: " ; Chr(msg(1)) ; " " ; Chr(msg(2)) ; " " ; Chr(msg(3))       ' ������� ������ ��� �����
   End If
   Waitms 10
Loop

End

' TWI ������������� ����� - ��������, ����� - ���������� (������� �� �����-������)
Twi_init_slave:
   Reset Msg_new                                            ' ������� �����
   Msg_len = 0
   Reset Twi_busy
   Twsr = 0                                                 ' ������� ������, ������� ������ = fclk/(16 + 2*TWBR*4^TWPS), ��� �������� ��������� ��������� �����������
   Twdr = &HFF                                              ' �������� ������
   Twar = Twi_slave_adr                                     ' ������������� ����� ������
   Reset Twar.twgce                                         ' ������ ������������� ������ ������

   Set Twcr.twea                                            ' ���������� �������������� ��������� �������������
   Reset Twcr.twsta
   Reset Twcr.twsto
   Set Twcr.twen                                            ' ���������� ������ ������
   Set Twcr.twie                                            ' ��������� ����������
Return

Twi_int_slave:
   Twi_status = Twsr And &HF8                               ' ����������� 3 ������ ����� [-,TWSP1,TWSP2]
   Select Case Twi_status
   ' ������� ���������
   Case &H60:                                               ' ���������� SLA+W �������
      Msg_len = 0
      Reset Msg_new
      Set Twi_busy
      Reset Twcr.twsto                                      ' ����� ������ ACK
      Set Twcr.twea
   Case &H80:                                               ' ����������, ��� ������ ���� ������ � ������ ACK
      If Msg_len < Max_msg_len Then                         ' ������� ���� (�� ����� ���� �����)
         Incr Msg_len
         Msg(msg_len) = Twdr
      End If
      If Msg_len <> Max_msg_len Then                        ' � ������ ���������� ��������� ����?
         Reset Twcr.twsto                                   ' ��� ����� ��������� ������, ����� ������ ACK
         Set Twcr.twea
      Else
         Reset Twcr.twsto                                   ' ������ ������ ���������� �������, ����� ������ NACK
         Reset Twcr.twea                                    '   ����� ��������� ������ ������������� �� ��� ���, ���� �� ����� ����������� ����/�������� �� ����(�������� ������)
      End If
   Case &H88:                                               ' ����������, ��� ������ ���� ������, �� ������������ � ������, �.�. ������ NACK
      Reset Twcr.twsta                                      ' ������������ � ����� ��������������� ��������
      Reset Twcr.twsto
      Set Twcr.twea
      Reset Twi_busy
   Case &HA0:                                               ' ���� ��� �������� � �� �����, ����� ����������
      If Msg_len = Msg_expect_len Then                      ' �������� ������ ������������ �� ������� ������?
         Set Msg_new                                        ' �������� ������ - ����� ���������
      Else
         Reset Msg_new
      End If
      Reset Twcr.twsta                                      ' ������� � ����� ��������������� ��������, ������������� SLA ������� ���������
      Reset Twcr.twsto
      Set Twcr.twea
      Reset Twi_busy
' ������� �����������
   Case &HA8:                                               ' ���������� SLA+R �������
      Set Twi_busy
      Goto Twi_int_slave_state_b8
   Case &HB8:                                               ' ��� ������� ��������� ���� ������ � ������� ACK (��� ������ ����� ������� ����, ���� ������ �� ��������� &HA8)
Twi_int_slave_state_b8:
      If Msg_out_len = 0 Then                               ' ������ ��� �������� ���?
         Twdr = &HFF                                        ' ��������� ����-��������, ����� �������� ������ ��������� ������, ���� �������� �������
         Reset Twcr.twsto                                   ' ��� ��������� ����, NACK ������ ���� ������
         Reset Twcr.twea
      Else
         Twdr = Msg_out(msg_out_len)                           ' ��������� ���� ������
         Decr Msg_out_len
         If Msg_out_len = 0 Then
            Reset Twcr.twsto                                   ' ��� ��������� ����, NACK ������ ���� ������
            Reset Twcr.twea
         Else
            Reset Twcr.twsto                                   ' ����� ������ ��������� ���� ������
            Set Twcr.twea
         End If
      End If
   Case &HC0:                                               ' ��� ������� ��������� ���� ������ � ������� NACK (����� ��������)
      Reset Twcr.twsta                                      ' ��������� � ����� ��������������� ��������, ��������� ������������� �������
      Reset Twcr.twsto
      Set Twcr.twea
      Reset Twi_busy
   Case &HC8:                                               ' ��� ������� ��������� ���� ������ � ������� ACK (����� ��������, ����� ���������� ����� ������ ����� ��� ����)
      Reset Twcr.twsta                                      ' ������������ � ����� ��������������� ��������, ��������� ������������� �������
      Reset Twcr.twsto
      Set Twcr.twea
' ����� ���������
   Case &HF8:                                               ' ���������������� ���������, � ���������� ������� �� ����������
   Case &H00:                                               ' ������ �� ����
      Reset Twcr.twsta
      Set Twcr.twsto
      Set Twcr.twea
      Reset Twi_busy
   Case Else:                                               ' �������� ����� ������ (��������, ���� ��������� ������������� ����� �������, ������� �� ��������������!)
      'Twcr = &B01000100                                     ' ����������� ����
   End Select
Return