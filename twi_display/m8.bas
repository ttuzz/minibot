'(
  ��������� ��� ������ 3� ������� ������� ����� Twi
')

$regfile = "M88def.dat"
$crystal = 7372800
$baud = 9600
Config Serialin = Buffered , Size = 20

Waitms 100

Const Max_buf_len = 10                                      ' ������������ ������ ������(������)
Dim Buf(max_buf_len) As Byte
Dim Buf_len As Byte                                         ' ������� ������ ������(������)

Dim Buf_to_send(max_buf_len) As Byte                        ' ��������
Dim Buf_to_send_len As Byte                                 ' ������ ��������

Dim New_msg As Byte                                         ' ���� ������ ������

Dim Twi_control As Byte
Dim Twi_status As Byte
Dim Twi_data As Byte

Enable Twi
On Twi Twi_int_slave

'!!!!
' ����� ��� �������� � ��� ������
   Buf_to_send(1) = "B"
   Buf_to_send(2) = "T"                                     'Servo Transmit Byte, �������� ������� ����
   Buf_to_send(3) = "S"
   Buf_to_send_len = 3
'!!!!

' TWI init
Gosub Twi_init_slave

Enable Interrupts

Print "M8 twi test"
Do
   ' ���� ������ ����� �����
    If New_msg = 1 Then
        New_msg = 0                                         ' �������� ����
        'Print "message: " ; chr(Buf(1)) ; " " ; Buf(2) ; " " ; Buf(3)       ' ������� ������ ��� �����
        Print "message: " ; Chr(buf(1)) ; " " ; Chr(buf(2)) ; " " ; Chr(buf(3))
    End If
    Waitms 10
Loop

End

' TWI ������������� ����� - ��������, ����� - ���������� (������� �� �����-������)
Twi_init_slave:
   Const Twi_slave_adr = &B01110000                         ' ����� ������ (7���!!!!, ��� �����), TWCG (������� ���) �������, �� ���������� ����� �����(����� 0x00)
   Twi_data = 0
   New_msg = 0                                              ' ������� �����
   Buf_len = 0
   Twsr = 0                                                 ' ������� ������, ������� ������ = fclk/(16 + 2*TWBR*4^TWPS), ��� �������� ��������� ��������� �����������
   Twdr = &HFF                                              ' �������� ������
   Twar = Twi_slave_adr                                     ' ������������� ����� ������
   Reset Twar.twgce                                         ' ������ ������������� ������ ������
   Set Twcr.twen                                            ' ���������� ������ ������
   Set Twcr.twea                                            ' ���������� �������������� ��������� �������������
   Set Twcr.twint                                           '!!!��������!!!���������� ���� ����������
   Set Twcr.twie                                            ' ��������� ����������
Return

Twi_int_slave:
   Twi_status = Twsr And &HF8                               ' ����������� 3 ������ ����� [-,TWSP1,TWSP2]
   Select Case Twi_status
   ' ������� ���������
      Case &H60 :                                           ' ���������� SLA+W �������
         Buf_len = 0
         New_msg = 0
         Reset Twcr.twsto
         Set Twcr.twea
         'Twcr = &B11000100
      Case &H80:                                            ' ������� ���� (�� ����� ���� �����)
         If Buf_len < Max_buf_len Then
            Incr Buf_len
            Buf(buf_len) = Twdr
            Reset Twcr.twsto
            Set Twcr.twea
         End If
      Case &HA0 :                                           '����� ��� �������� � �� �����, ����� ���������� ����������
         ' ����� ���� �� ������ ���������� ������
         ' ����� ������� ��� �����, �� �������
         If Buf_len = 3 Then
            New_msg = 1                                     ' ���� ������ ��������� ����������
         Else
            New_msg = 0                                     ' ���� ������ ��������� �������
         End If
         Reset Twcr.twsta                                   ' ���� ��������� ���� � �������� ��� �� ������ �� ����� =)
         Reset Twcr.twsto                                   ' �� �� ������� ���� NACK ��������
         Set Twcr.twea
         'Twcr = &B11000100

      Case &H88 :                                           ' ���������� ��� ����������, ��� ������� ������ ���� ������ � ������ NACK
      Case &HF8 :                                           ' ������ ������� � ���������
      Case &H00 :                                           ' ������ �� ����
         Reset Twcr.twsta
         Set Twcr.twsto
         Set Twcr.twea
         'Twcr = &B11010100
   ' ������� �����������
      Case &HA8:                                            ' ���������� SLA+R �������
         If Buf_to_send_len = 0 Then
            Buf_to_send_len = 2
         End If
            Goto Loop_b8
      Case &HB8:                                            ' ��� ������� ��������� ���� ������ � ������� ACK
         ' ����� ���� �������� ������, �� ����-������ (����� ����� �� ��������� $C8)
Loop_b8:
         Twdr = Buf_to_send(buf_to_send_len)                ' ��������� ���� ������
         Decr Buf_to_send_len
         If Buf_to_send_len > 0 Then
            Reset Twcr.twsta
            Reset Twcr.twsto                                ' �������� ��������� ���� ������
            Set Twcr.twea
         Else
            Reset Twcr.twsta
            Reset Twcr.twsto                                ' �������� ��������� ���� ������
            Reset Twcr.twea
         End If
      Case &HC0:                                            ' ��� ������� ��������� ���� ������ � ������� NACK (����� ��������)
         Reset Twcr.twsta
         Reset Twcr.twsto                                   ' ��������� � ����� ��������������� ��������, ��������� ������������� �������
         Set Twcr.twea
      Case &HC8:                                            ' ����� ���������� ����� ������ ����� ��� ���� (����� �������� ������� ACK)
         Set Twcr.twsto                                     ' ������������ � ����� ��������������� ��������, ������� STOP
         Reset Twcr.twsta
         Set Twcr.twea
      Case Else:                                            '�������� ����� ������
         Twcr = &B01000100                                  ' ����������� ����
   End Select
Return