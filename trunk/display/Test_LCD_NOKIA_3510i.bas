$regfile = "m32DEF.dat"
$crystal = 7372800                                          '11059200
$baud = 1200
$hwstack = 128
$swstack = 128
$framesize = 128
Config Serialin = Buffered , Size = 20
Enable Interrupts

$lib "nokialcd.lbx"
'библиотеки AVR-DOS и SD
$include "Config_MMC.bas"
$include "Config_AVR-DOS.BAS"
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

Gbdoserror = Initfilesystem(0)



Dim Color As Byte
Dim I As Integer
Dim K As Integer

Const Filename1 = "lb.bmp"
Const Filename2 = "lc.bmp"

Cls
Pset -1 , -1 , Black
Pset 10 -1 , -1 , Black
Wait 5

Cls
Open Filename1 For Binary As #4
Do
For I = -1 To 65
   For K = -1 To 96
      Get #4 , Color
      Pset K , I , Color
   Next
Next
Loop Until Eof(#4) <> 0
Close #4

Wait 10

Cls
Open Filename2 For Binary As #4
Do
For I = -1 To 65
   For K = -1 To 96
      Get #4 , Color
      Pset K , I , Color
   Next
Next
Loop Until Eof(#4) <> 0

End


'(
For I = -1 To 96
   For K = -1 To 65
      Pset I , K , Red
   Next
Next

Pset -1 , -1 , Black
Pset 96 , 65 , Black
')

'(
Dim Buf As Integer
Buf = 0

Do
   For I = 0 To 66
      For K = 0 To 97
         Get #4 , Color
      Next
   Next
   Pset Buf , 5 , Red
   Incr Buf
Loop Until Eof(#4) <> 0

Do
   Get #4 , Buf
   Ocr2 = Buf
   Waitus Delay_us
Loop Until Eof(#4) <> 0
')


'Cls

'Setfont Color_exo
'Lcdat 0 , 0 , "0123 minibot" , Red , Green
'Wait 10


'$include "Color_exoRus.font"