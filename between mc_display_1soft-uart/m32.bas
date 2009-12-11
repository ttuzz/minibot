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

Setfont Color_exo
Const Font_height = 8
Const Display_height = 67
Dim Y_pos As Byte
Y_pos = 0
Cls


Declare Sub Input_m88(byref S As String)
   Const Timerload_after_start = 144                        'baudrate = 9600, prescaler = 8
   Const Timerload_after_bit = 83
   Const Bytes_amount = 3                                   ' количество байт для приема


Dim S As String * 20
Dim C As String * 1
Enable Interrupts
Dim Count As Byte : Count = 1
Dim W As Word

Waitms 70
Do
   Open "comc.1:9600,8,n,1" For Output As #10
      Print #10 , "a" ; Chr(count) ; "k" ;
   Close #10
   Call Input_m88(s)
      C = Mid(s , 2 , 1)
      Count = Asc(c)

   S = "> " + Str(count)
   Print "m32: " ; S
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

Sub Input_m88(byref S As String)
   Local Bit_count As Byte , Byte_count As Byte
   Local Buf As Byte

   Config Pinc.1 = Input

   Config Timer0 = Timer , Prescale = 8
   Stop Timer0

   Byte_count = 0
   While Byte_count < Bytes_amount
      Incr Byte_count
      Bitwait Pinc.1 , Reset
      Start Timer0
      Timer0 = 0
         While Timer0 < Timerload_after_start
         Wend
      Timer0 = 0
      Bit_count = 0
      Buf = 0
      While Bit_count < 8
         Buf = Buf + Pinc.1
         Rotate Buf , Right , 1
         Incr Bit_count
         Timer0 = 0
            While Timer0 < Timerload_after_bit
            Wend
      Wend
      Mid(s , Byte_count , 1) = Buf
      Stop Timer0
   Wend
   Incr Byte_count
   Mid(s , Byte_count , 1) = Chr(0)
End Sub