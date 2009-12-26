'$prog &HFF , &HE0 , &HDD , &HF9                             ' ��� �������� 2.x
$regfile = "m88DEF.dat"
$crystal = 7372800
$baud = 115200
$hwstack = 64
$swstack = 64
$framesize = 64

' ������
Config Adc = Single , Prescaler = Auto , Reference = Internal       '������� ����� 2.04�
   Dim ��������� As Word
      Dim �����_��������� As Byte

   Dim ���� As Integer

'Config Servos = 1 , Servo1 = Portb.2 , Reload = 20
'   Config Pinb.2 = Output
Config Timer1 = Pwm , Pwm = 10 , Prescale = 64 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down
   Servo1 Alias Pwm1b
   Config Pinb.2 = Output
   Dim ������ As Byte
   Dim ����������(5) As Word
   Dim �����_������� As Byte
   Dim ����������� As Byte
      Const �� = 0
      Const ��� = 1
   ����������� = ���

' ������� � ���������
Declare Sub Printf(byval S As String)
   Dim Text As String * 50                                  ' �����-������ ��� �������� (����� ��-�� �������������� ��������� �������)

' �����
Enable Urxc
On Urxc Getchar                                             '�������������� ���������� ������ usart
   Dim In_string As String * 50                             '������ ��� ������
   Dim In_key As Byte                                       ' ������� �������� ������

Servo1 = 75
'Servo(1) = 50
Waitms 1000
   Call Printf( "start minibot mega88" )
   Call Printf( "test")

Enable Interrupts                                           '��������� ����������


Do
   ��������_����:
   If ����������� = �� Then Gosub ������������
Loop

Getchar:
   In_key = Inkey()
   If In_key <> 13 And In_key <> 10 Then                    ' ��������� ���� �� �������� ����� ������
         In_string = In_string + Chr(in_key)
   Else                                                     'in_string �������� �������� ������
      If In_string = "on" Then ����������� = ��
      If In_string = "off" Then ����������� = ���
      If In_string = "ctr" Then Servo1 = 75                 'Servo(1) = 50               'Servo1 = 75
      In_string = ""
   End If
Return

������������:
Do
   �����_������� = 0
   For ������ = 65 To 85 Step 5                             ' ����� 75
      Incr �����_�������
      Servo1 = ������
      'Servo(1) = ������
      Waitms 150
      Gosub Sharp
   Next
   For ������ = 85 To 65 Step -5
      Servo1 = ������
      'Servo(1) = ������
      Waitms 150
      Gosub Sharp
      Decr �����_�������
   Next
Loop Until ����������� = ���
Servo1 = 75
'Servo(1) = ������
Return

Sharp:
  Const �����_������������ = 10
   Start Adc
   ��������� = Getadc(0) : ��������� = Getadc(0) : ��������� = Getadc(0)
      ��������� = 0
      For �����_��������� = 1 To 10
         ��������� = ��������� + Getadc(0)
      Next
      ��������� = ��������� \ 10
   Stop Adc
   ���� = ��������� - ����������(�����_�������)
   ���� = Abs(����)
   If ���� > �����_������������ Then
      ����������(�����_�������) = ���������
      ��������� = ��������� / 10
      Text = Str(�����_�������) + "-" + Str(���������) : Call Printf(text)
   End If
Return

Sub Printf(byval S As String)
   Local I As Byte
   Local Len1 As Byte
   Local Buf As String * 1
   Reset Ucsr0b.rxen0
   Len1 = Len(s)
   For I = 1 To Len1
      Bitwait Ucsr0a.udre0 , Set                            ' ������ �������, ����� ����� ��������� ����� ������
      Buf = Mid(s , I , 1)
      Udr0 = Asc(buf)
   Next
      Bitwait Ucsr0a.udre0 , Set
      Udr0 = 13
      Bitwait Ucsr0a.udre0 , Set
      Udr0 = 10
      Set Ucsr0a.txc0                                       ' ������ ���� ����������
      Bitwait Ucsr0a.txc0 , Set                             ' ��� ���� ���������� �� �������� ���� ����� (�� ����������� ������, �� UDR)
   Set Ucsr0b.rxen0
End Sub