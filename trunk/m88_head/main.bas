'$prog &HFF , &HE0 , &HDD , &HF9                             ' ��� �������� 2.x

$regfile = "m88DEF.dat"
$crystal = 7372800
$baud = 115200
'Config Serialin = Buffered , Size = 10

$hwstack = 64
$swstack = 64
$framesize = 64

Enable Interrupts                                           '��������� ����������
'Enable Urxc
On Urxc Getchar                                             '�������������� ���������� ������ usart

Config Adc = Single , Prescaler = Auto                      '����� 2,04�

Dim ��������� As Word
   Dim ���� As Integer

Dim Text As String * 15                                     '������ ��� ��������/������ (����� ������ 15 ��������)
Dim Text_tmp As String * 15
Dim Txt_ As Byte

Config Servos = 1 , Servo1 = Portb.2 , Reload = 20
Config Pinb.2 = Output
Dim ������ As Byte

Dim ����������(7) As Word
Dim ����� As Byte

Enable Interrupts

Waitms 1000
Print
Print "Start Mega88 MiniBot 2.1"


'Config Pinb.2 = Input

'Gosub ����������_����������
Do
   ��������_����:
   Gosub ������������
Loop

������������:
Do
   For ������ = 35 To 65 Step 5
     Servo(1) = ������
     Waitms 40
     Gosub Sharp
   Next
   'For ������ = 65 To 35 Step -5
   '  Servo(1) = ������
   '  Waitms 15
   '  Gosub Sharp
   'Next
Loop
Return

'(
����������_����������:
   Start Adc
   ����� = 1
   For ������ = 35 To 65 Step 5
     Servo(1) = ������
     Waitms 40
     ��������� = Getadc(0) : ��������� = Getadc(0) : ��������� = Getadc(0)
     ����������(�����) = ��������� : Incr �����
   Next
   Stop Adc
   ' �����
   Print "Dist: " ;
   For ����� = 1 To 7
      Print ����������(�����) ; " ";
   Next
   Print
Return
')

������������_����:
   Servo(1) = 50
   Goto ��������_����
Return

Getchar:
   Txt_ = Inkey()
   If Txt_ > 13 Then                                        '���� ������ �� ��������� ������
      Text_tmp = Chr(txt_)
      Text = Text + Text_tmp
   End If
   If Txt_ = 13  Then'������ ����
         '������ � Text �������
   End If
   If Text = "M88_Scan_on" Then Gosub ������������
   If Text = "M88_Scan_off" Then Gosub ������������_����
Return

Sharp:
   Const ������� = 70
   Start Adc
   ��������� = Getadc(0) : ��������� = Getadc(0) : ��������� = Getadc(0)
   Stop Adc
   ����� = ������ - 30 : ����� = ����� \ 5
   ���� = ��������� - ����������(�����)
   ���� = Abs(����)
   ����������(�����) = ���������
   If ���� > ������� Then
      Print Chr(13);
      ��������� = ��������� / 10
      Print ������ ; "-" ; ��������� ;
   End If
   '(
   If ����� = 7 Then
      Print ��������� ;
      Waitms 200                                            ' �������� �� ����������
      Print Chr(13);
   Else
      Print ��������� ; " " ;
   End If
   ')
'(
   ��������� = ��������� - �������
   If ��������� > ����������(�����) Then
      ��������� = ��������� + ������� : ��������� = ��������� / 10
      Print Chr(13);
      Print ������ ; "-" ; ��������� ;
   End If
')
Return