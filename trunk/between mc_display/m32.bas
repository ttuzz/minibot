$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 9600

$hwstack = 64
$swstack = 64
$framesize = 64


$lib "nokialcd.lbx"
Config Graphlcd = Color , Controlport = Portc , Rs = 4 , Cs = 5 , Scl = 7 , Sda = 6
Const Blue = &B00000011                                     'predefined contants are making programming easier
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

'Open "comc.1:9600,8,n,1" For Output As #12
'Open "comc.1:2400,8,n,1" For Input As #11
Open "comc.0:2400,8,n,1" For Input As #11
'Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down
'Config Rc5 = Pind.3                                         ' нагружаю таймеры

Setfont Color_exo
Const Font_height = 8
Const Display_height = 67
Dim Y_pos As Byte
Y_pos = 0
Cls


Dim S As String * 20
Dim Transfer_counter As Byte , Buf As Byte

Transfer_counter = 0
Buf = 0

Enable Interrupts

Do
   Waitms 1000
Disable Interrupts
   'Print #12 , Transfer_counter
   Input #11 , Buf
   'Incr Transfer_counter
   'decr Buf
Enable Interrupts

   S = "> " + Str(buf)
   Lcdat Y_pos , 1 , S , Black , White
   Y_pos = Y_pos + Font_height
   Y_pos = Y_pos + Font_height
   If Y_pos > Display_height Then
      Y_pos = 0
      Cls
   Else
      Y_pos = Y_pos - Font_height
   End If
   Print S
   Waitms 500
Loop


$include "Color_exoRus.font"





'(
   Print ">" ;
   Input S
Disable Interrupts
   Print #12 , S

   Print "out:";
   Input #11 , S
   Print S
Enable Interrupts
')