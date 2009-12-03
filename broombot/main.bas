'$prog &HFF , &HBD , &HC9 , &H00
$regfile = "m32def.dat"                                     ' ���� ������������ ����32
$crystal = 7372800                                          ' ��������� �� ����� ������� ����� ��������
$baud = 115200

$include "pult.bas"

Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down
Config Pinc.2 = Output : �����������_����� Alias Portc.2    '���� ���������������� ��� ����� � �������� Drl
Config Pinc.3 = Output : �����������_������ Alias Portc.3   '���� ���������������� ��� ����� � �������� Drr
Config Pind.4 = Output                                      '���� ���� ������ ������ ���������������� ��� �����
Config Pind.5 = Output                                      '���� ���� ������� ������  ���������������� ��� �����
Const ������ = 0
Const ����� = 1
Const �����_�������� = 50
��������_����� Alias Pwm1b
��������_������ Alias Pwm1a

Config Pinc.4 = Output : ����1_������� Alias Portc.4
Config Pinc.5 = Output : ����1_������� Alias Portc.5
Config Pinc.6 = Output : ����2_������� Alias Portc.6
Config Pinc.7 = Output : ����2_������� Alias Portc.7
Const ������ = 1
Const �������� = 0

Config Pind.2 = Input : ������ Alias Pind.2
Config Pinb.2 = Input : ������� Alias Pinb.2

Config Pind.7 = Output : Portd.7 = 0 : ������� Alias Portd.7       ' �������

' ���������� �� ����� ������ ��� ��������� ������ RC5
Config Int1 = Falling
On Int1 �������_�������_������
Enable Int1
Config Rc5 = Pind.3

' ���������� ����������
Dim �������_������_����� As Byte , �������_������ As Byte
Dim Adc_temp As Word , Akb As Single
Dim Errbyte As Byte

Dim ���������_������ As Byte
   Const ����������_������� = 1
   Const ��������_������� = 2
   Const �����_������� = 3
   ���������_������ = 0

' ���������
Declare Function ���������_�������() As Byte
   Const �������_����� = 1
Declare Sub ���������_�������()
Declare Sub ������_�������()
Declare Sub ������_��������(byval ������ As Word)

����2_������� = ������

' ������
Enable Interrupts

Waitms 200
Print "Start MiniBot v2.1"

�����:
Do
   Select Case ���������_������
      Case ��������_�������:
         Disable Int1
         �������_������ = Btn_power : Gosub ���������_�������       ' ������ � ����� ��������
         Enable Int1
         Gosub ���������_�������
      Case �����_�������:
         Disable Int1
         �������_������ = Btn_power : Gosub ���������_�������       ' ������ � ����� ��������
         Enable Int1
         Gosub ������_�������
      Case ����������_�������:
         Disable Int1
         �������_������ = Btn_ok : Gosub ���������_�������  ' ������� � ������ ��������
         Enable Int1
         Idle
      Case Else
         ' ������ ������, ������ � ����� ��������
         Disable Int1
         �������_������ = Btn_power : Gosub ���������_�������       ' ������ � ����� ��������, ���������� � ������
         ���������_������ = ����������_�������
         Enable Int1
         Idle
   End Select
Loop

Sub ���������_�������()
' ��������� ��������
   Dim I As Byte
   Local ���������_�������� As Integer
   Const ������_��������_�������� = 10
   Const ������_��������������� = 10
   Const ������_�����_�������� = 50
' ��������
   Do
      For I = �����_�������� To 255 Step ������_��������_��������
         �����������_����� = ������ : �����������_������ = ������
         ���������_�������� = I + ������_���������������
         ��������_����� = ���������_��������
         ���������_�������� = I - ������_���������������
         ��������_������ = ���������_��������
         Call ������_��������(������_�����_��������)
      Next
   Loop
End Sub

Sub ������_��������(byval ������ As Word)
' �������
   Const ����� = 0
   Const ����� = 1
   �����_������ Alias Pind.2
   ������_������ Alias Pind.2
   �����������_������ Alias Pind.2
   While ������ > 0
      If ������_������ = ����� And �����_������ = ����� And �����������_������ = ����� Then
         Waitms 20
      Else
         ��������_����� = 255 : ��������_������ = 255
         If �����������_������ = ����� Then
            �����������_����� = �����
            �����������_������ = �����
            Wait 1
            �����������_����� = ������
            Wait 1
            �����������_������ = ������
         Elseif ������_������ = ����� Then
            �����������_����� = �����
            �����������_������ = ������
            Waitms 500
         Elseif �����_������ = ����� Then
            �����������_����� = ������
            �����������_������ = �����
            Waitms 500
         End If
      End If
      Decr ������
   Wend
End Sub

Sub ������_�������()
End Sub

�������_�������_������:
   Disable Int1
   Enable Interrupts
   Getrc5(�������_������_����� , �������_������)
   Enable Interrupts
   Dim ���� As Byte
   If �������_������_����� = Ir_adress And �������_������ <> 255 Then       ' ������������ ����� �������� � ����� ������ = 0
      �������_������ = �������_������ And &B01111111
      Print Chr(12);
      'Print "IR_Address - " ; �������_������_�����
      Print "IR_command - " ; �������_������
   End If
   ' ��������� �������
   ���� = ���������_�������()
   Gifr = Gifr Or &B10000000                                'Clear Flag Int1
   Enable Int1
   If ���� = �������_����� Then
      Goto �����
   End If
Return

Function ���������_�������()
   Const ��������_�������� = 20
   Local ���������_�������� As Integer
   Local ������������_�������� As Byte : ������������_�������� = 0
   Select Case �������_������
   ' ������� ��������
      Case Btn_up:
         If ���������_������ <> ����������_������� Then
            ���������_������� = ������������_��������
            Exit Function
         End If
         ���������_�������� = ��������_����� + ��������_������       ' ����������� �������� ��������
         ���������_�������� = ���������_�������� \ 2
         ��������_����� = ���������_�������� : ��������_������ = ���������_��������
         If �����������_����� = ����� And �����������_������ = ����� Then       ' �������� ������ ��� �����
            ���������_�������� = ��������_������ - ��������_��������
            If ���������_�������� < �����_�������� Then
               �����������_����� = ������ : �����������_������ = ������
               ��������_����� = �����_�������� : ��������_������ = �����_��������
            Else
               ��������_����� = ���������_�������� : ��������_������ = ���������_��������
            End If
         Else
            ���������_�������� = ��������_������ + ��������_��������
            If ���������_�������� > 255 Then
               ���������_�������� = 255
            End If
            ��������_����� = ���������_�������� : ��������_������ = ���������_��������
         End If
      Case Btn_down:
         If ���������_������ <> ����������_������� Then
            ���������_������� = ������������_��������
            Exit Function
         End If
         If ��������_����� = �����_�������� Or ��������_������ = �����_�������� Then       ' ���� ����� ����� ����� �� ���������� ���������
            �����������_����� = ����� : �����������_������ = �����
         End If
         ���������_�������� = ��������_����� + ��������_������       ' ����������� �������� ��������
         ���������_�������� = ���������_�������� \ 2
         ��������_����� = ���������_�������� : ��������_������ = ���������_��������
         If �����������_����� = ������ And �����������_������ = ������ Then       ' �������� ������ ��� �����
            ���������_�������� = ��������_������ - ��������_��������
            If ���������_�������� < �����_�������� Then
               �����������_����� = ����� : �����������_������ = �����
               ��������_����� = �����_�������� : ��������_������ = �����_��������
            Else
               ��������_����� = ���������_�������� : ��������_������ = ���������_��������
            End If
         Else
            ���������_�������� = ��������_������ + ��������_��������
            If ���������_�������� > 255 Then
               ���������_�������� = 255
            End If
            ��������_����� = ���������_�������� : ��������_������ = ���������_��������
         End If
      Case Btn_left:
         If ���������_������ <> ����������_������� Then
            ���������_������� = ������������_��������
            Exit Function
         End If
         ���������_�������� = ��������_����� + ��������_��������
         If ���������_�������� < 255 Then
            ��������_����� = ���������_��������
         Else
            ��������_����� = 255
            ���������_�������� = ��������_������ - ��������_��������
            If ���������_�������� > �����_�������� Then
               ��������_������ = ���������_��������
            Else
               ��������_������ = �����_��������
            End If
         End If
      Case Btn_right:
         If ���������_������ <> ����������_������� Then
            ���������_������� = ������������_��������
            Exit Function
         End If
         ���������_�������� = ��������_������ + ��������_��������
         If ���������_�������� < 255 Then
            ��������_������ = ���������_��������
         Else
            ��������_������ = 255
            ���������_�������� = ��������_����� - ��������_��������
            If ���������_�������� > �����_�������� Then
               ��������_����� = ���������_��������
            Else
               ��������_����� = �����_��������
            End If
         End If
      Case Btn_ok:
         If ���������_������ <> ����������_������� Then
            Exit Sub
         End If
         �����������_����� = ������ : �����������_������ = ������
         ��������_����� = �����_�������� : ��������_������ = �����_��������
      Case Btn_power:
         ' �������� ��� ��������, ����� ��������� ���� � ���������_������ = 0, �.�. ����� ������
         �����������_����� = ������ : �����������_������ = ������
         ��������_����� = 0 : ��������_������ = 0
   ' ������� ���������
      Case Btn_s:
         ���������_������ = ����������_�������
         ������������_�������� = �������_�����
         ���������_������� =  ������������_��������
      Case Btn_p
         ���������_������ = ��������_�������
         ������������_�������� = �������_�����
         ���������_������� =  ������������_��������
      Case Btn_f:
         ���������_������ = �����_�������
         ������������_�������� = �������_�����
         ���������_������� =  ������������_��������
      Case Else:
         ' �� ���� �� ����������������� ������
   End Select
End Function