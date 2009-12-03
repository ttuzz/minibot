'(
������� ���������� ���� -�����������
')
'**�������� �����������**
$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 115200

'����������� �������
$include "settings\config.bas"
$include "settings\errcodes.bas"
$include "settings\pult.bas"
$include "include\subs.bas"

Declare Sub Docommand()

' ������ ��
#if Exist_sd = 1
   '����� �������� �����
   Gbdoserror = Drivecheck()
   If Gbdoserror <> 0 Then
      Led_r1 = 1
      Led_r2 = 1
      End
   End If

   Gbdoserror = Initfilesystem(1)
   If Gbdoserror <> 0 Then
      Led_r1 = 1
      Led_r2 = 1
      End
   End If
   ' ����� ����� ������� ��� ����� �������� ��������� � ������������
   Text_filename = Logging_sd_filename
#endif

'** ������ **
Mult_filename = "welc.mbi" : Call Print_picture_to_display
Gspcinput = "Start Minibot" : Call Print_ew(gspcinput)
Mult_filename = "welc.wav" : Call Print_to_speaker
Wait 1

Clear Serialin
Cls
Led_g1 = 1

Enable Interrupts


'������ ��������� ����� �����
Gspcinput = "Ready for commands" : Call Print_ew(gspcinput)

Loop_start:
Do
   If State = Now_playing Or State = Now_recording Then
      Goto Loop_start
      '����� ������ ����� �������� ������� �� ����� � ����� �����������
   End If

   Print Chr(10) ; Chr(13) ;
   Print "com: " ;
   Waitms 6
   Clear Serialin

   Input Gspcinput Noecho
   Print Chr(10) ; Chr(13) ;

   Docommand
   Gspcinput = ""
Loop

Sub Docommand
'(
������� ���������� �������
')
   Local Lbyte1 As Byte , Lbyte2 As Byte
   Local Lint1 As Integer
   Local Lword1 As Word
   Local Llong1 As Long , Llong2 As Long
   Local Lsingle1 As Single

   Extracttoken                                             '��������� ������
   If Gbcnttoken = 0 Then                                   '� ���� �� ��� ���������?
      Goto Loop_start
   End If

   '�������!!(�)
   Gstoken = Getnexttokenstr(ctoken_len)                    '�������� ������ ����� - ��������
   Gstoken = Ucase(gstoken)                                 '��������� �����

   Select Case Gstoken                                      '������� ��������
   Case "FS"                                                ' Init File System
      Print "In FS Case"
      If Gbcnttoken = 2 Then
         Llong1 = Getnexttokenlong(0 , 3)
         Lbyte1 = Llong1
      Else
         Call Print_error(cpparametercount)
      End If
   Case Else
      Call Print_error(cpextracterror)
   End Select
End Sub


$include "include\interrupts.bas"


End