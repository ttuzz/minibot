$regfile = "m32DEF.dat"
$crystal = 8000000
$hwstack = 32
$swstack = 10
$framesize = 40

Portc = &B11111111
Config Pinc.2 = Output : �����_����� Alias Portc.2
Config Pinc.3 = Output : ������_����� Alias Portc.3

Porta = &B00000000
Config Pina.0 = Input : �����_������ Alias Pina.0
Config Pina.1 = Input : ������_������ Alias Pina.1
Config Pina.3 = Input : ��������_������ Alias Pina.3        '���� �������� � ��������� �� PINA.2, �� ����� �� �� �������

Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down

Const ����� = 1 : Const Light = 0
Dim �����������_�������� As Integer
Dim ������������_�������� As Integer
Dim ��������_������ As Integer

�����������_�������� = 150
������������_�������� = 255
��������_������ = �����������_��������

Dim ������ As Long
Dim ���������� As Long
������ = 50
���������� = 1

�����_����� = 0
������_����� = 0

Do
   ��������_������ = �����������_��������                   'left
   Pwm1a = ������������_��������                            'right
   Gosub ���������_��_�������
   Gosub ���������_������
Loop
End

���������_��_�������:
   While ��������_������ < ������������_��������
      Pwm1b = ��������_������
      Gosub �����_��������
      ��������_������ = ��������_������ + ����������
   Wend
Return

���������_������:
   Dim �������_��������_������ As Integer
   �������_��������_������ = 3                              '3 sec
   While �������_��������_������ >= 0
      Pwm1b = ������������_��������
      Pwm1a = ������������_��������
      Gosub �����_��������
      Decr �������_��������_������
   Wend
        Pwm1b = 0 : Pwm1a = 0
 Return

�����_��������:
Dim Count As Long
Count = ������
While Count > 0
      If ������_������ <> ����� And �����_������ <> ����� And ��������_������ <> ����� Then
         Decr Count
         Waitms 20
      Else
         Pwm1b = ������������_�������� : Pwm1a = ������������_��������
         If ��������_������ = ����� Then
               �����_����� = 1
               ������_����� = 1
               Wait 1
               �����_����� = 0
               Wait 1
               ������_����� = 0
         Elseif ������_������ = ����� Then
               �����_����� = 1
               ������_����� = 0
               Waitms 500
               �����_����� = 0
         Elseif �����_������ = ����� Then
               �����_����� = 0
               ������_����� = 1
               Waitms 500
               ������_����� = 0
         End If
         ��������_������ = ������������_��������
         Return
      End If
Wend
Return
