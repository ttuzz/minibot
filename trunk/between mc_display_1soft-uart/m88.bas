$regfile = "m88DEF.dat"
$baud = 9600
$crystal = 7372800

$hwstack = 64
$swstack = 64
$framesize = 64

Const Exist_servos = 1                                      ' нужно выставлять количество
Const Exist_distance_sensor = 1                             ' есть или нет

#if Exist_servos <> 0
   Config Servos = 1 , Servo1 = Portb.2 , Reload = 10
      Config Pinb.2 = Output
#endif


Declare Sub Input_m32(byref S As String)
   #if Exist_servos <> 0
      Const Timerload_after_start = 135                     'baudrate = 9600, prescaler = 8
      Const Timerload_after_bit = 77
   #else
      Const Timerload_after_start = 144                     'baudrate = 9600, prescaler = 8
      Const Timerload_after_bit = 83
   #endif
   Const Bytes_amount = 3                                   ' количество байт для приема
Declare Sub Print_m32(byref S As String)


Dim S As String * 20
Dim C As String * 1

Dim Count As Byte : Count = 0

Dim W As Word

Enable Interrupts

Do
   Call Input_m32(s)
   If Mid(s , 1 , 1) = "a" And Mid(s , 3 , 1) = "k" Then
      C = Mid(s , 2 , 1)
      Count = Asc(c)
      Incr Count
      If Count = 0 Then
         Count = 1
      End If
      Mid(s , 2 , 1) = Chr(count) : Call Print_m32(s)
   Else
      S = "nrc" : Call Print_m32(s)
   End If
Loop


Sub Input_m32(byref S As String)
   Local Bit_count As Byte , Byte_count As Byte
   Local Buf As Byte

   Config Pinc.4 = Input

   Config Timer2 = Timer , Prescale = 8
   Stop Timer2

   Byte_count = 0
   While Byte_count < Bytes_amount
      Incr Byte_count
      Bitwait Pinc.4 , Reset
      Start Timer2
      Timer2 = 0
         While Timer2 < Timerload_after_start
         Wend
      Timer2 = 0
      Bit_count = 0
      Buf = 0
      While Bit_count < 8
         Buf = Buf + Pinc.4
         Rotate Buf , Right , 1
         Incr Bit_count
         Timer2 = 0
            While Timer2 < Timerload_after_bit
            Wend
      Wend
      Mid(s , Byte_count , 1) = Buf
      Stop Timer2
   Wend
   Incr Byte_count
   Mid(s , Byte_count , 1) = Chr(0)
End Sub

Sub Print_m32(byref S As String)
   Open "comc.4:9600,8,n,1" For Output As #10
      Disable Timer0
         Print #10 , S ;
      Enable Timer0
   Close #10
End Sub