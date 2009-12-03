'(
Description : ���� �������� ������
Description : ��������� ���� -����������� ��� ����������������� ���������
Description : ������� 2.1
Release Date : 2009 -01 -11
Version : 1.0
Author : Josef Franz Vogel - ������ ������� ������
Author : galex1981 - ��� ��� ������ � IR �������
Author : MiBBiM - �� ���������
')

'**��������� ���������� ������**
' �������� ���������, ����������� ������������� ���������
Const Exist_engines = 1                                     ' ������
Const Exist_sd = 1                                          ' ����� ������
Const Exist_speaker = 1                                     ' �������
Const Exist_encoders = 0                                    ' ��������
Const Exist_linesensors = 0                                 ' ������� �����
Const Exist_mega88 = 0                                      ' ����������� Mega88
   Const Exist_sharp = 0                                    ' ��������� sharp
   Const Exist_servos = 0                                   ' �����
Const Exist_display = 0                                     ' ������� �� �������� nokia 3510i

'**��������� �������� ������**
' �������� ���������, ����������� �������� ������
Const Language = 1                                          ' ���� ������ ������
Const Need_ir_commands = 1                                  ' ����� �� ��������� RC5 �������
Const Need_logging_display = 0                              ' ����� �� ����� ��� �� �������
Const Need_logging_speaker = 0                              ' ����� �� ����������� ���������� �������
Const Need_logging_sd = 0                                   ' ����� �� ����� ��� �� ��������
   Const Logging_sd_filename = "log.txt"
Const Need_extended_errors = 0                              ' ����� �� �������� ������ ���� ������ ��� � � �����

'**������� ������������**

'�������� ����������� Mega32
'$prog &HFF , &HAE , &HC9 , &H00
$regfile = "m32DEF.dat"
$crystal = 7372800

'hardware-UART
$baud = 115200
Config Serialin = Buffered , Size = 20

'����
$hwstack = 32
$swstack = 32
$framesize = 32

'������ ������(����� ����� ���� ������������)
Stop Watchdog

'����������(������������ �� ���������� ����)
Config Pinc.4 = Output : Led_r1 Alias Portc.4
Config Pinc.5 = Output : Led_g1 Alias Portc.5
Config Pinc.6 = Output : Led_r2 Alias Portc.6
Config Pinc.7 = Output : Led_g2 Alias Portc.7

'������
Config Pind.2 = Input : Button Alias Pind.2

'�������
Config Pinb.2 = Input : Power_in Alias Pinb.2

'!!!��� ��������������� ��������������� ����� ���������� � �� ������!!!
'Config Adc = Single , Prescaler = Auto , Reference = Internal       '2.56V

#if Need_ir_commands = 1
   '��������� ������ RC5
   Config Int1 = Falling
   On Int1 Learn_rc5
   Enable Int1
   Config Rc5 = Pind.3
#endif

'**�������������� ������������***

#if Exist_engines = 1
   '��� ���������� �����������
   Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down
   Config Pinc.2 = Output : Motor_left_dir Alias Portc.2    ' DrL
   Config Pinc.3 = Output : Motor_right_dir Alias Portc.3   ' DrR
   Config Pind.4 = Output : Motor_left_speed Alias Pwm1b    'PWM L
   Config Pind.5 = Output : Motor_right_speed Alias Pwm1a   'PWM R

   '�������
   Motor_left_dir = 0 : Motor_right_dir = 0
   Motor_left_speed = 0 : Motor_right_speed = 0
#endif

#if Exist_display = 1
   ' ���������� ��� Nokia 3510i
   $include "nokialcd.lbx"
   ' ������������� �����
   Config Graphlcd = Color , Controlport = Portc , Rs = 4 , Cs = 5 , Scl = 7 , Sda = 6
   ' ������� �������
   Const Display_width = 98
   Const Display_height = 67
   ' ����������������� �����
   Const Blue = &B00000011                                  'predefined contants are making programming easier
   Const Yellow = &B11111100
   Const Red = &B11100000
   Const Green = &B00011100
   Const Black = &B00000000
   Const White = &B11111111
   Const Brightgreen = &B00111110
   Const Darkgreen = &B00010100
   Const Darkred = &B10100000
   Const Darkblue = &B00000010
   Const Brightblue = &B00011111
   Const Orange = &B11111000
   ' �����
   $include "include\font_color_rus.font"
   Setfont Font_color_rus
   Const Font_height = 8
   ' ��������� ��� �������� ������ pset, ������������ � ������� Print_picture_to_display
      ' ����� ��� ������� ������������ ����� (������� ������� ��� ���������� �� ������� nokia 3510i)
      Const Row_begin = -1
      Const Col_begin = -1
      Const Row_end = 65
      Const Col_end = 96
   ' ��������� ��� ������ ������� (��. ��������� Print_to_display)
      Const Display_x_pos = 3                               ' �������� ����� �� ��� X
      Const Display_text_foreground_color = Black
   ' �������
   Cls
#endif

#if Exist_speaker = 1
   '������������� ��������
   Config Pind.7 = Output : Portd.7 = 0
   Speaker Alias Portd.7
   #if Need_logging_speaker = 1
      '���������-��������� �������� ����������
      '��������� ����, 10 ����, ����� � ��������� 0..10
      ' ����� ������� � ERRCODES.BAS
      Const Sound_welcome = 11
      Const Sound_wrong_input = 12
      '� ������
   #endif
#endif

#if Exist_encoders = 1 Or Exist_linesensors = 1
   '�� ����������
   Config Pind.6 = Output : Led_ir Alias Portd.6
   Led_ir = 0
#endif

#if Exist_encoders = 1
   '������������ ����� ��� ���������
   '��������(_m) � �������������� ���� (_a) ������ ��������
   Config Pina.2 = Input : Encoder_left_m Alias Pina.2
   Config Pina.6 = Input : Encoder_left_a Alias Pina.6
   '��������(_m) � �������������� ���� (_a) ������� ��������
   Config Pina.1 = Input : Encoder_right_m Alias Pina.1
   Config Pina.5 = Input : Encoder_right_a Alias Pina.5
#endif

#if Exist_linesensors = 1
   '������� �����
   Config Pina.0 = Input : Linesensor_1 Alias Pina.0
   Config Pina.3 = Input : Linesensor_2 Alias Pina.3
   Config Pina.4 = Input : Linesensor_3 Alias Pina.4
#endif

#if Exist_sd = 1
   '������������� �������� �������(AVR-DOS � SD)
   $include "settings\config_MMC.bas"
   $include "settings\config_DOS.BAS"
#endif

'**����**
'������������ �����
Const Cptoken_max = 6                                       '������������ ���������� �������
Const Cpstrsep = ","                                        '����������� ������� (����� ������� � �����)
Const Cpcinput_len = 20                                     ' �� ������ 20!!!(��. ������������� Print_ew) ����� ����������������� �����(������� *.bat �����)
Const Ctoken_len = 12                                       '������������ ����� ������ ������

'��������� ���������
Const Now_logging = 0                                       '��� � ���� (������� ���������, ���� ���� sd-����� ���)
Const Now_recording = 1                                     '������ � *.bat
Const Now_playing = 2                                       '������������ *.bat

'��������� ���������� ����������
'  ��� ������� ������
Dim Gstoken As String * Ctoken_len                          '�������� ������� �����
Dim Gspcinput As String * Cpcinput_len                      '�������� ���������������� ����(*.bat, uart)
Dim Gbposstrparts(cptoken_max) As Byte                      '������, �������� ����������
Dim Gblenstrparts(cptoken_max) As Byte                      '  � ������������ ������
Dim Gbcnttoken As Byte                                      '���������� ��������� �������
Dim Gbtoken_actual As Byte                                  '����� �������� ������(����� ��� ��������� ����������)
Dim Gbpcinputerror As Byte                                  '������ � ���������������� �����
'**/����**

'**���������� ����������, ����������� ��� ����������� ����������������
Dim State As Byte : State = Now_logging                     ' ��������� �����

#if Need_ir_commands = 1
   Dim Ir_command_adress As Byte , Ir_command As Byte       ' ������� � ������ RC5
#endif

#if Exist_sd = 1
   'Dim File As Byte : File = 0                              ' ����� ����� ��� ������ ��� ���������������(*.bat) - ������� ����� ������� (������������ ��� ������ ��-������)
   Const File = 10                                          ' ��������� ������������ ��������� ����-������
   Dim Text_filename As String * 12                         ' ��� ������� �����, ��. ��������� ��� ������ � ����+������������
   Dim Mult_filename As String * 12                         ' ��� ������� ����������� �����
#endif

#if Exist_encoders = 1
   Dim Encoder_left As Long : Encoder_left = 0              ' ������� ������ ��������
   Dim Encoder_right As Long : Encoder_right = 0            ' ������� ������� ��������
#endif

#if Exist_display = 1
   Dim Display_y_pos As Byte : Display_y_pos = 0
#endif



Dim Strfile As String * 10                                  ' ��� ����� ��� ������

Dim Strf1 As String * 1                                     ' ������ ������������ ����� �����
Dim Strf2 As String * 1

Dim Gspcinput1 As String * Cpcinput_len                     ' ����� ��������� ������ ��� ������ � ����
Dim Speed As Byte
Speed = 1