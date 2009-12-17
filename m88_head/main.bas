'$prog &HFF , &HE0 , &HDD , &HF9                             ' ��� �������� 2.x
$regfile = "m88DEF.dat"
$crystal = 7372800
$baud = 115200
$hwstack = 64
$swstack = 64
$framesize = 64

' ������
Config Adc = Single , Prescaler = Auto , Reference = Internal       '����� 2.04�
   Dim ��������� As Word
   Dim ���� As Integer

Config Servos = 1 , Servo1 = Portb.2 , Reload = 20
   Config Pinb.2 = Output
'Config Timer1 = Pwm , Pwm = 10 , Prescale = 64 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down
'   Servo1 Alias Pwm1b
   'Config Pinb.2 = Output
   Dim ������ As Byte
   Dim ����������(7) As Word
   Dim ����� As Byte

' �����
Dim Text As String * 15                                     '������ ��� ��������/������ (����� ������ 15 ��������)
Dim Text_tmp As String * 15
Dim Txt_ As Byte

'Enable Urxc
On Urxc Getchar                                             '�������������� ���������� ������ usart


Waitms 1000
Print
Print "Start Mega88 MiniBot 2.1"
Enable Interrupts                                           '��������� ����������


Do
   ��������_����:
   Gosub ������������
Loop

Getchar:
   Txt_ = Inkey()
   If Txt_ > 13 Then                                        '���� ������ �� ��������� ������
      Text_tmp = Chr(txt_)
      Text = Text + Text_tmp
   End If
   If Txt_ = 13 Then                                        '������ ����
         '������ � Text �������
   End If
   If Text = "M88_Scan_on" Then Gosub ������������
   If Text = "M88_Scan_off" Then Gosub ������������_����
Return

������������:
Do
   For ������ = 35 To 65 Step 5
     Servo(1) = ������
     'Servo1 = ������
     Waitms 50
     Gosub Sharp
   Next
   For ������ = 65 To 35 Step -5
     Servo(1) = ������
     'Servo1 = ������
     Waitms 50
     Gosub Sharp
   Next
Loop
Return

������������_����:
   Servo(1) = 50
   'Servo1 = ������
   Goto ��������_����
Return

Sharp:
  Const �����_������������ = 70
   Start Adc
   ��������� = Getadc(0) : ��������� = Getadc(0) : ��������� = Getadc(0)
   Stop Adc
   ����� = ������ - 30 : ����� = ����� \ 5
   ���� = ��������� - ����������(�����)
   ���� = Abs(����)
   ����������(�����) = ���������
   If ���� > �����_������������ Then
      Print Chr(13);
      ��������� = ��������� / 10
      Print ������ ; "-" ; ��������� ;
   End If
Return