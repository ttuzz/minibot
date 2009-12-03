' author: MiBBiM
'**********MINIBOT CONFIGS**********
'фусибиты
'$prog &HFF , &HE4 , &HD9 , &H00

'камень
$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 115200
Config Serialin = Buffered , Size = 20

'делаю супермегабиг+ стек
$hwstack = 64
$swstack = 64
$framesize = 64

Config Pinc.6 = Output : Led_r2 Alias Portc.6
Config Pinc.7 = Output : Led_g2 Alias Portc.7

Led_r2 = 1
'$lib "lcd-pcf8833.lbx"
'$lib "nokialcd.lbx"

$lib "LCD-Nokia3510i_EPSON.LBX"

Wait 2
Led_r2 = 0

Config Portc.5 = Output
Config Portc.4 = Output
Config Portc.7 = Output
Config Portc.6 = Output

Wait 2


Led_r2 = 1
'$lib "lcd-pcf8833.lbx"
'Config Graphlcd = Color , Controlport = Portc , Cs = 5 , Rs = 4 , Scl = 7 , Sda = 6
Config Graphlcd = Color , Controlport = Portc , Cs = 5 , Reset = 4 , Scl = 7 , Sda = 6
Wait 2
Led_r2 = 0


Config Portd.7 = Output : Reset Portd.7
      Wait 2
      Print "MiniBot v.2 is configured"
      Enable Interrupts
'///**********MINIBOT CONFIGS**********


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

Led_g2 = 1

'clear the display
Cls

'create a cross
Line(0 , 0) -(130 , 130) , Blue
Line(130 , 0) -(0 , 130) , Red
Wait 2

'select a font
Setfont Font16x16

'and show some text
Lcdat 100 , 0 , "12345678" , Blue , Yellow
Wait 2

'make a circle
Circle(30 , 30) , 10 , Blue
Wait 2

'make a box
Box(10 , 30) -(60 , 100) , Red


'set some pixels
Pset 32 , 110 , Black
Pset 38 , 110 , Black
Pset 35 , 112 , Black

Led_g2 = 0

End

'our font
$include "font16x16.font"