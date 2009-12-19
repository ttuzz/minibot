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
   Dim ���� As Integer

'Config Servos = 1 , Servo1 = Portb.2 , Reload = 20
'   Config Pinb.2 = Output
Config Timer1 = Pwm , Pwm = 10 , Prescale = 64 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down
   Servo1 Alias Pwm1b
   Config Pinb.2 = Output
   Dim ������ As Byte
   Dim ����������(7) As Word
   Dim ����� As Byte

' �����
Dim Text As String * 50                                     '������ ��� ��������/������ (����� ������ 15 ��������)
Dim Text_tmp As String * 50
Dim Txt_ As Byte

' ������� � ���������
Declare Sub Printf(byval S As String)

Enable Urxc
On Urxc Getchar                                             '�������������� ���������� ������ usart


Waitms 1000


'      Print "Start Mega88 MiniBot 2.1"
'      'Waitms 1
'      Ucsr0b.rxen0 = 1
'   Text = Chr(10)
'   Call Printf(text)
'   Text = "start minibot mega88" + Chr(13)
   Call Printf( "start minibot mega88" )
'   Text = Chr(10)
'   Call Printf(text)
   Call Printf( "test")

Enable Interrupts                                           '��������� ����������


Do
   ��������_����:
   'Gosub ������������
Loop

Getchar:
   Txt_ = Inkey()
   If Txt_ > 13 Then                                        '���� ������ �� ��������� ������
      Text_tmp = Text_tmp + Chr(txt_)
   End If
   If Txt_ = 13 Then                                        '������ ����
         '������ � Text �������
   End If
   If Text_tmp = "on" Then Gosub ������������
   If Text_tmp = "off" Then Gosub ������������_����
   If Mid(text_tmp , 1 , 2) = "on" Then Gosub ������������
Return

������������:
Do
   Text = "adcd" : Call Printf(text)
   For ������ = 35 To 65 Step 5
     'Servo(1) = ������
     Servo1 = ������
     Waitms 50
     Gosub Sharp
   Next
   For ������ = 65 To 35 Step -5
     'Servo(1) = ������
     Servo1 = ������
     Waitms 50
     Gosub Sharp
   Next
Loop
Return

������������_����:
   'Servo(1) = 50
   Servo1 = ������
   Goto ��������_����
Return

Sharp:
  Const �����_������������ = 100
   Start Adc
   ��������� = Getadc(0) : ��������� = Getadc(0) : ��������� = Getadc(0)
   Stop Adc
   ����� = ������ - 30 : ����� = ����� \ 5
   ���� = ��������� - ����������(�����)
   ���� = Abs(����)
   ����������(�����) = ���������
   If ���� > �����_������������ Then
      ��������� = ��������� / 10
      Text = Chr(13) + Str(������) + "-" + Str(���������) : Call Printf(text)
   End If
Return

'(

Void Usart_transmit(unsigned Char Data )
{
 / * Wait For Empty Transmit Buffer * /
While(!(ucsrna &(1 << Udren)) )
;
 / * Put Data Into Buffer , Sends The Data * /
Udrn = Data;
}
')

Sub Printf(byval S As String)
   Local I As Byte
   Local Len1 As Byte
   Local Buf As String * 1
   Reset Ucsr0b.rxen0
      While Ucsr0a.udre0 = 0
      Wend
      Udr0 = 10
   Len1 = Len(s)
   For I = 1 To Len1
      While Ucsr0a.udre0 = 0
      Wend
      Buf = Mid(s , I , 1)
      Udr0 = Asc(buf)
   Next
      While Ucsr0a.udre0 = 0
      Wend
      Udr0 = 13
   Set Ucsr0b.rxen0
End Sub