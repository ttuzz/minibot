$regfile = "m88DEF.dat"
$baud = 115200
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
' управление серво
Declare Sub Set_servo(byref S As String)
Declare Sub Get_distance(byref S As String)


Dim S As String * 20
Dim Transmit As String * 20


Dim Count As Byte : Count = 0
Dim W As Word

Enable Interrupts

Do
   '(
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
')
   Call Input_m32(s)
   If Mid(s , 1 , 1) = "s" Then
      Call Set_servo(s)
   Else
      If Mid(s , 1 , 1) = "d" Then
         'S = "dsa" : Call Print_m32(s)
         Call Get_distance(s)
      Else
         S = "nrc" : Call Print_m32(s) ' not recognition
      End If
   End If
Loop

Sub Set_servo(byref S As String)
#if Exist_servos <> 0
   Local Number As Byte , Value As Byte
   Local Symb As String * 1
   Symb = Mid(s , 2 , 1) : Number = Val(symb)
   Symb = Mid(s , 3 , 1) : Value = Asc(symb)
   If Number > Exist_servos Then
      S = "nck" : Call Print_m32(s)
   Else
      Servo(number) = Value
      S = "ack" : Call Print_m32(s)
   End If
#endif
End Sub

Sub Get_distance(byref S As String)
#if Exist_distance_sensor <> 0
   Local Value As Word , Symb As String * 1 , Number As Byte
   Local B1 As Byte , B2 As Byte
   Symb = Mid(s , 2 , 1) : Number = Val(symb)
   'Config Adc = Single , Prescaler = Auto , Reference = Avcc
   'Config Adc = Single , Prescaler = Auto , Reference = Internal       '!!!!_1.1V в МЕГЕ88!!!!!
   Start Adc
      Select Case Number
      Case 1:
         Value = Getadc(1)
      Case 2:
         Value = Getadc(number)
      Case Else:
         S = "nck" : Call Print_m32(s)
         Stop Adc
         Exit Sub
      End Select
   Stop Adc
   Reset Adcsr.aden
   Didr0 = 0                                                ' включаем цифровые буферы
   S = "ack"
   B1 = High(value) : Mid(s , 2 , 1) = Chr(b1)
   B2 = Low(value) : Mid(s , 3 , 1) = Chr(b2)
   If B1 = 0 And B2 = 0 Then
      S = "dck"
   Else
      If B1 = 0 Then
         Mid(s , 1 , 2) = "bc"
      End If
      If B2 = 0 Then
         Mid(s , 1 , 1) = "c"
         Mid(s , 3 , 1) = "k"
      End If
   End If
   Call Print_m32(s)
#endif
End Sub

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