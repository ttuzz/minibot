$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 115200

$hwstack = 64
$swstack = 64
$framesize = 64

Declare Sub Input_m88(byref S As String)
   Const Timerload_after_start = 144                        'baudrate = 9600, prescaler = 8
   Const Timerload_after_bit = 83
   Const Bytes_amount = 3                                   ' количество байт для приема
Declare Sub Print_m88(byref S As String)


Dim S As String * 20
   Dim Arr(10) As Byte At S Overlay
   Dim Substr As String * 15 At Arr(3) Overlay
Dim C As String * 1
Enable Interrupts
Dim Count As Byte : Count = 1
Dim W As Word
Dim Transmit As String * 6

Waitms 70
Do
   Waitms 10
   Reset Ucsrb.rxen
      Print ":>" ;                                          'Lcdat 1 , 1 , S , Black , White
      Waitms 6
   Set Ucsrb.rxen

   Input S Noecho
   Reset Ucsrb.rxen
      Print "--you entered: '" ; S ; "'"
   Set Ucsrb.rxen
   If Mid(s , 1 , 1) = "s" Then
      Transmit = Mid(s , 1 , 2)
      W = Val(substr)
      Transmit = Transmit + Chr(w) : Call Print_m88(transmit)
      Call Input_m88(s)
      Print "::" ; S
   End If
   If Mid(s , 1 , 1) = "d" Then
      Transmit = Mid(s , 1 , 2) + "k" : Call Print_m88(transmit)
      Call Input_m88(s)
         C = Mid(s , 2 , 1) : W = Asc(c) : Shift W , Left , 8
         C = Mid(s , 3 , 1) : W = W + Asc(c)
         C = Mid(s , 1 , 1)
         Select Case C
         Case "a":
         Case "b":
            W = W And &H00FF
         Case "c":
            W = W And &HFF00
         Case "d":
            W = 0
         End Select
         Print "::" ; W
   End If
   Waitms 500
Loop


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

Sub Print_m88(byref S As String)
   Open "comc.1:9600,8,n,1" For Output As #10
      Disable Timer0
         Print #10 , S ;
      Enable Timer0
   Close #10
End Sub

'(
      S = "a" + Chr(count) + "k" : Call Print_m88(s)
      Call Input_m88(s)
         C = Mid(s , 2 , 1)
         Count = Asc(c)
      S = "> " + Str(count)
   'Reset Ucsrb.rxen
      Print S
   'Set Ucsrb.rxen
')