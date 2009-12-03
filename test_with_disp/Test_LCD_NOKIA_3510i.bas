$regfile = "m32DEF.dat"
$crystal = 7372800                                          '11059200
$baud = 115200
$hwstack = 128
$swstack = 128
$framesize = 128
Config Serialin = Buffered , Size = 20
Enable Interrupts

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

Dim Color As Byte
Dim I As Integer
Dim K As Integer


Setfont Color_exo
Cls
' делаем софтварный уарт
Const U_inp = 11
Const U_output = 12

Open "comc.1:9600,8,n,1" For Input As #10
Open "comc.0:9600,8,n,1" For Output As #11

'Open "comc.0:9600,8,n,1" For Input As #10
'Open "comc.1:9600,8,n,1" For Output As #11




Dim S As String * 20
Const Font_height = 8
Const Display_height = 67
Dim Y_pos As Byte
Y_pos = 0
Cls

Dim Pos As Byte
Do
'(
   In put Pos , Noecho
   Print #11 , Pos
   Waitms 100
')
   Input #10 , Pos , Noecho
   'Print Pos

   Lcdat Y_pos , 1 , Pos , Black , White
   Y_pos = Y_pos + Font_height
   Y_pos = Y_pos + Font_height
   If Y_pos > Display_height Then
      Y_pos = 0
      Cls
   Else
      Y_pos = Y_pos - Font_height
   End If

Loop

$include "Color_exoRus.font"