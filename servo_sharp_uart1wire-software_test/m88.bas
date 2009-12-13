$regfile = "m88DEF.dat"
$baud = 9600
$crystal = 7372800

$hwstack = 32
$swstack = 10
$framesize = 40

Const Exist_servos = 1                                      ' нужно выставлять количество
Const Exist_distance_sensor = 1                             ' есть или нет

#if Exist_servos <> 0
   Config Servos = 1 , Servo1 = Portb.2 , Reload = 10
      Config Pinb.2 = Output
#endif

#if Exist_distance_sensor <> 0
   'Config Adc = Single , Prescaler = Auto , Reference = Internal       '!!!!_1.1V в МЕГЕ88!!!!!
   Config Adc = Single , Prescaler = Auto , Reference = Avcc       '!!!!_1.1V в МЕГЕ88!!!!!
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
' управление дальномером
Declare Sub Get_distance(byref S As String)

Dim S As String * 20
Dim C As String * 1

Enable Interrupts
Do
   Call Input_m32(s)
   Print "m32_send: " ; S
   C = Mid(s , 1 , 1)
   Select Case C
   Case "s":
      Call Set_servo(s)
   Case "d":
      Call Get_distance(s)
   Case Else
      S = "nrc" : Call Print_m32(s)                         ' not recognition
   End Select
Loop

Sub Input_m32(byref S As String)
   Local Bit_count As Byte , Byte_count As Byte
   Local Buf As Byte

   'Config Pinc.0 = Output
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
      Timer0 = 0
      'Portc.0 = 1
      'Portc.0 = 0
      Bit_count = 0
      Buf = 0
      While Bit_count < 8
         'Portc.0 = 1
         Buf = Buf + Pinc.4
         Rotate Buf , Right , 1
         Incr Bit_count
         Timer2 = 0
         'Portc.0 = 0
            While Timer2 < Timerload_after_bit
            Wend
      Wend
      Mid(s , Byte_count , 1) = Buf
      Stop Timer2
   Wend
   Incr Byte_count
   Mid(s , Byte_count , 1) = Chr(0)
End Sub

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
   Start Adc
      Select Case Number
      Case 1:
         Value = Getadc(1)
      Case 2:
         Value = Getadc(number)
      Case Else:
         S = "nck" : Call Print_m32(s)
         Exit Sub
      End Select
   Stop Adc
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

Sub Print_m32(byref S As String)
   Open "comc.4:9600,8,n,1" For Output As #10
      Disable Timer0
         Print #10 , S ;
      Enable Timer0
   Close #10
End Sub