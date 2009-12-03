'$prog &HFF , &HBD , &HC9 , &H00
$regfile = "m32def.dat"                                     ' ���� ������������ ����32
$crystal = 7372800                                          ' ��������� �� ����� ������� ����� ��������
$baud = 115200

$include "pult.bas"

Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down
Config Pinc.2 = Output : Drl Alias Portc.2                  '���� ���������������� ��� ����� � �������� Drl
Config Pinc.3 = Output : Drr Alias Portc.3                  '���� ���������������� ��� ����� � �������� Drr
Config Pind.4 = Output                                      '���� ���� ������ ������ ���������������� ��� �����
Config Pind.5 = Output                                      '���� ���� ������� ������  ���������������� ��� �����

Config Pinc.4 = Output : Led_1red Alias Portc.4
Config Pinc.5 = Output : Led_1green Alias Portc.5
Config Pinc.6 = Output : Led_2red Alias Portc.6
Config Pinc.7 = Output : Led_2green Alias Portc.7

Config Pind.2 = Input : Knopka Alias Pind.2
Config Pinb.2 = Input : Power_in Alias Pinb.2

Config Pind.7 = Output : Portd.7 = 0                        ' �������

' ���������� �� ����� ������ ��� ��������� ������ RC5
Config Int1 = Falling
On Int1 Learn_rc5
Enable Int1
Config Rc5 = Pind.3

' ���������� ����������
Dim Speed As Byte : Speed = 250
Dim Address_rc5 As Byte , Command_rc5 As Byte
Dim Adc_temp As Word , Akb As Single
Dim Errbyte As Byte
Dim ����������� As Byte                                     ' 0=����, 1=�����, 2=�����

' ���������
Declare Sub Processcommand()

' ������
Enable Interrupts

Waitms 200
Print "Start MiniBot v2.1"


'Gosub ����� : Waitms 1000
'Gosub ����� : Waitms 1000
'Gosub ����� : Waitms 1000
'Gosub ������ : Waitms 1000


Do
   Idle
Loop


�����:
   Drl = 0 : Drr = 0 : Pwm1b = 0 : Pwm1a = 0 : Waitms 10
   Gosub ���� : Waitms 10
   ����������� = 1
   Drl = 1 : Drr = 0 : Pwm1b = Speed : Pwm1a = Speed
Return

�����:
   Drl = 0 : Drr = 0 : Pwm1b = 0 : Pwm1a = 0 : Waitms 10
   Gosub ���� : Waitms 500
   ����������� = 2
   Drl = 0 : Drr = 1 : Pwm1b = Speed : Pwm1a = Speed
Return

�����:
   Drl = 0 : Drr = 0 : Pwm1b = 0 : Pwm1a = 0 : Waitms 10
   Drl = 0 : Drr = 0 : Pwm1b = Speed : Pwm1a = Speed : Waitms 100
   If ����������� = 1 Then Gosub �����
   If ����������� = 2 Then Gosub �����
   If ����������� = 0 Then Gosub ����
Return

������:
   Drl = 0 : Drr = 0 : Pwm1b = 0 : Pwm1a = 0 : Waitms 10
   Drl = 1 : Drr = 1 : Pwm1b = Speed : Pwm1a = Speed : Waitms 100
   If ����������� = 1 Then Gosub �����
   If ����������� = 2 Then Gosub �����
   If ����������� = 0 Then Gosub ����
Return

����:
   Drl = 0 : Drr = 0 : Pwm1b = 0 : Pwm1a = 0:
   ����������� = 0
Return


Learn_rc5:
   Disable Int1
   Enable Interrupts
   Getrc5(address_rc5 , Command_rc5)
   Enable Interrupts
   If Address_rc5 <> 255 And Command_rc5 <> 255 Then
      Command_rc5 = Command_rc5 And &B01111111
      Print Chr(12);
      Print "IR_Address - " ; Address_rc5
      Print "IR_command - " ; Command_rc5
   End If
  ' ��������� �������
  'Gosub Processcommand
  Gifr = Gifr Or &B10000000                                 'Clear Flag Int1
  Enable Int1
Return

Sub Processcommand()
   Select Case Command_rc5
      Case 32:
         Gosub �����
      Case 33:
         Gosub �����
      Case 17:
         Gosub �����
      Case 16:
         Gosub ������
      Case 12:
         Gosub ����
      Case Else:
         ' �� ���� �� ����������������� ������
   End Select
End Sub