$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 9600

$hwstack = 64
$swstack = 64
$framesize = 64


$lib "i2c_twi.lbx"                                          ' библиотека для хардварного TWI, мастер

                                                     ' we need to set the pins in the proper state
Config Twi = 50000                                          ' wanted clock frequency
Config Scl = Portc.0                                        ' линия клока
Config Sda = Portc.1                                        ' лииния данных
I2cinit

'will set TWBR and TWSR
'Twbr = 12 'bit rate register
'Twsr = 0 'pre scaler bits


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


Setfont Color_exo
Const Font_height = 8
Const Display_height = 67
Dim Y_pos As Byte
Y_pos = 0
Cls

Dim B(3) As Byte
Dim R(5) As Byte
Dim S As String * 20

Enable Interrupts

Do

   B(1) = "S"
   B(2) = "W"                                               ' Servo Write Byte
   B(3) = "B"
   I2csend &B01110000 , B(1) , 3                            ' send the value
   Print "Error : " ; Err                                   ' show error status
   Print "--sended"
   Waitms 100

'(
   R(1) = &HFF
   'I2creceive &B01110000 , R(1) , 0 , 3
   S = ">" + "'" + Chr(r(1)) + Chr(r(2)) + Chr(r(3)) + "' " + Str(err)
   Lcdat Y_pos , 1 , S , Black , White
   Y_pos = Y_pos + Font_height
   Y_pos = Y_pos + Font_height
   If Y_pos > Display_height Then
      Y_pos = 0
      Cls
   Else
      Y_pos = Y_pos - Font_height
   End If
   Waitms 500
')
Loop

$include "Color_exoRus.font"