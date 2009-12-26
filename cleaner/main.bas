'$prog &HFF , &HBD , &HC9 , &H00
$regfile = "m32def.dat"                                     ' ���� ������������ ����32
$crystal = 7372800                                          ' ��������� �� ����� ������� ����� ��������
$baud = 115200
$hwstack = 64
$swstack = 64
$framesize = 64
$include "pult.bas"

Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down
Config Pinc.2 = Output : �����������_����� Alias Portc.2    '���� ���������������� ��� ����� � �������� Drl
Config Pinc.3 = Output : �����������_������ Alias Portc.3   '���� ���������������� ��� ����� � �������� Drr
Config Pind.4 = Output                                      '���� ���� ������ ������ ���������������� ��� �����
Config Pind.5 = Output                                      '���� ���� ������� ������ ���������������� ��� �����
Const ������ = 1
Const ����� = 0
Const �����_�������� = 50
��������_����� Alias Pwm1b : ��������_������ Alias Pwm1a

Config Pinc.4 = Output : ����1_������� Alias Portc.4
Config Pinc.5 = Output : ����1_������� Alias Portc.5
Config Pinc.6 = Output : ����2_������� Alias Portc.6
Config Pinc.7 = Output : ����2_������� Alias Portc.7
   Const ������ = 1
   Const �������� = 0

Config Pind.2 = Input : ������ Alias Pind.2
Config Pinb.2 = Input : ������� Alias Pinb.2

Config Pina.2 = Input : ������_� Alias Pina.2               ' ������ �����
Config Pina.6 = Input : ������_� Alias Pina.6               ' ������ ������
   Const ����� = 0
   Const ����� = 1

Config Pina.1 = Output : ������� Alias Porta.1 : Reset �������       ' �������
Config Pind.7 = Output : ������� Alias Portd.7 : Reset �������       ' �������

' ���������� �� ����� ������ ��� ��������� ������ RC5
Config Int1 = Falling
On Int1 �������_�������_������
Enable Int1
Config Rc5 = Pind.3

' ���������� ������� ������� �������2
Config Timer2 = Timer , Prescale = 64
On Ovf2 ������2
Enable Timer2

' ���������� �� ������� ������� �� �����
Enable Urxc
On Urxc ��������_������                                     '�������������� ���������� ������ usart
   Dim In_string As String * 50                             '������ ��� ������
   Dim In_key As Byte                                       ' ������� �������� ������
   Dim In_buf As String * 10                                ' �����-������ ��� �������� �������� ��������


' ���������� ����������
Dim �������_������_����� As Byte , �������_������ As Byte
Dim Adc_temp As Word , Akb As Single
Dim Errbyte As Byte

Dim ���������_������ As Byte
   Const ����������_������� = 1
   Const ��������_������� = 2
   Const �����_������� = 3
   ���������_������ = 0

' ������ �������
Dim ����_������� As Byte

' ������� ����������
Dim �������_���������� As Byte
   Dim �������_���������� As Byte                           ' ������� ��� �������� ����� ����� � ��� �� �������

' ��������� ���������
Dim �����������_�������� As Byte
   Const ���� = 2                                           ' ������ � ����� ��� ����������, ������ ����
   �����������_�������� = ����


' ���������
Declare Sub ���������_�������()
   Dim ���� As Byte
      Const �������_����� = 0
      Const �������_����� = 1
Declare Sub ���������_�������()
Declare Sub ������_�������()
Declare Sub ������_��������(byval ������ As Word)
Declare Sub ���������_��������()
   Dim ����������(7) As Word
   Dim ����� As Byte


' �����
Declare Sub Printf(byref S As String)
   Dim Text As String * 50                                  ' �����-������ ��� �������� (����� ��-�� �������������� ��������� �������)


����2_������� = ������

' ������
Enable Interrupts

Waitms 200
Text = "Start MiniBot v2.1" : Call Printf(text)

�����:
Text = "in begin" : Call Printf(text)
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
         Text = "in_ir_control" : Call Printf(text)
         Do
            Call ���������_��������
         Loop
      Case Else
         ' ������ ������, ������ � ����� ��������
         Disable Int1
         �������_������ = Btn_power : Gosub ���������_�������       ' ������ � ����� ��������, ���������� � ������
         ���������_������ = ����������_�������
         Enable Int1
         Text = "in_parking_mode" : Call Printf(text)
         Do
            Call ���������_��������
         Loop
   End Select
Loop

�������_�������_������:
   Disable Int1
   ����_������� = 0
   Enable Interrupts
   Getrc5(�������_������_����� , �������_������)
   Enable Interrupts
   If �������_������_����� = Ir_adress And �������_������ <> 255 Then       ' ������������ ����� �������� � ����� ������ = 0
      �������_������ = �������_������ And &B01111111
      'Print Chr(12);
      'Print "IR_Address - " ; �������_������_�����
      Text = "IR_command - " + Str(�������_������) : Call Printf(text)
      If �������_������ = �������_���������� Then           ' ������� ������� ��� ��� ������� �������
         Incr �������_����������
      Else
         �������_���������� = 0
         �������_���������� = �������_������
      End If
      Text = "amount" + Str(�������_����������) : Call Printf(text)
      Call ���������_�������
   End If
   ' ��������� �������
   Gifr = Gifr Or &B10000000                                'Clear Flag Int1
   Enable Int1
   If ���� = �������_����� Then
      Goto �����
   End If
Return

��������_������:
   Toggle ����1_�������
   In_key = Inkey()
   If In_key <> 13 And In_key <> 10 Then                    ' ��������� ���� �� �������� ����� ������
         In_string = In_string + Chr(in_key)
   Else                                                     'in_string �������� �������� ������
      'if In_string = "on" Then ����������� = ��
      'if In_string = "off" Then ����������� = ���
      'Mid(in_string , 1 , 1) = "-" ' ���������� �����
      If Mid(in_string , 2 , 1) = "-" Then                  ' ������� ��������� ����
         In_buf = Mid(in_string , 1 , 1) + Chr(0)
         ����� = Val(in_buf)
         In_key = Len(in_string) - 2
         In_buf = Mid(in_string , 3 , In_key) + Chr(0)
         ����������(�����) = Val(in_buf)
      End If
      In_string = ""
   End If
Return

������2:
   ' count = 120, ���� ��������� IR_command and IR_Address
   ' count = 120, ���� ��������� ir_command
   If ����_������� < 120 Then
      Incr ����_�������
      ����1_������� = ������
   Else
      ����1_������� = ��������
      If ���������_������ = ����������_������� Then
         Disable Int1
         Select Case �����������_��������
         Case ������ : �������_������ = Btn_up
         Case ����� : �������_������ = Btn_down
         Case ���� : �������_������ = Btn_ok
         End Select
         Call ���������_�������()
         �������_���������� = 0
         Enable Int1
      End If
   End If
Return

Sub ���������_�������()
'
End Sub

Sub ������_��������(byval ������ As Word)
'
End Sub

Sub ������_�������()
'
End Sub

Sub ���������_��������()
'
End Sub

Sub ���������_�������()
   ���� = �������_�����
   Select Case �������_������
   ' ������� ��������
      Case Btn_up:
         �����������_����� = ������ : �����������_������ = ������
         ��������_����� = 200 : ��������_������ = 200
         �����������_�������� = ������
         ���������_������ = ����������_�������
      Case Btn_down:
         �����������_����� = ����� : �����������_������ = �����
         ��������_����� = 200 : ��������_������ = 200
         �����������_�������� = �����
         ���������_������ = ����������_�������
      Case Btn_left:
         Select Case �������_����������
         Case 0 To 3 :
            ��������_����� = 0 : ��������_������ = 200
         Case 3 To 5 :
            ��������_����� = 0 : ��������_������ = 230
         Case 6 To 255 :
            ��������_����� = 0 : ��������_������ = 255
         End Select
         ���������_������ = ����������_�������
      Case Btn_right:
         Select Case �������_����������
         Case 0 To 3 :
            ��������_����� = 200 : ��������_������ = 0
         Case 3 To 5 :
            ��������_����� = 230 : ��������_������ = 0
         Case 6 To 255 :
            ��������_����� = 255 : ��������_������ = 0
         End Select
         ���������_������ = ����������_�������
      Case Btn_ok:
         �����������_����� = ������ : �����������_������ = ������
         ��������_����� = 0 : ��������_������ = 0
         �����������_�������� = ����
         ���������_������ = ����������_�������
      Case Btn_power:
         ' �������� ��� ��������, ����� ��������� ���� � ���������_������ = 0, �.�. ����� ������
         �����������_����� = ������ : �����������_������ = ������
         ��������_����� = 0 : ��������_������ = 0
         ���������_������ = 0
         �����������_�������� = ����
         ���� = �������_�����
   ' ������� ���������
      Case Btn_1:
         ' ��������� ��������� �� ������� �������
         '���������_������ = ����������_�������
         '���� = �������_�����
      Case Btn_2:
         ���������_������ = ��������_�������
         ���� = �������_�����
      Case Btn_3:
         ���������_������ = �����_�������
         ���� = �������_�����
      Case Btn_s:
         Toggle �������
      Case Btn_tv:
         '�������� ������� ����88
         Text = "on" : Call Printf(text)
      Case Btn_av:
         ' �������� ������� ����88
         Text = "off" : Call Printf(text)
      Case Btn_sleep:
         ' ��������!! ������ ��� ������� � ������
         If ����������(1) > 100 Then Toggle ����2_�������
      Case Else:
         ' �� ���� �� ����������������� ������
   End Select
End Sub


Sub Printf(byval S As String)
   Local Cnt As Byte
   Local Len1 As Byte
   Local Buf As String * 1
   Reset Ucsrb.rxen
   Len1 = Len(s)
   For Cnt = 1 To Len1
      Bitwait Ucsra.udre , Set                              ' ������ �������, ����� ����� ��������� ����� ������
      Buf = Mid(s , Cnt , 1)
      Udr = Asc(buf)
   Next
      Bitwait Ucsra.udre , Set
      Udr = 13
      Bitwait Ucsra.udre , Set
      Udr = 10
      Set Ucsra.txc                                         ' ������ ���� ����������
      Bitwait Ucsra.txc , Set                               ' ��� ���� ���������� �� �������� ���� ����� (�� ����������� ������, �� UDR)
   Set Ucsrb.rxen
End Sub