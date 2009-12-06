$regfile = "m88DEF.dat"
$baud = 9600
$crystal = 7372800

$hwstack = 64
$swstack = 64
$framesize = 64

'Config Servos = 1 , Servo1 = Portb.2 , Reload = 10 , Timer = Timer1


'Open "comc.4:9600,8,n,1" For Input As #11
Open "comc.5:2400,8,n,1" For Output As #10


Dim S As String * 20

Dim Buf As Byte : Buf = 0

Enable Interrupts

Do
'   Input #11 , Buf
'   Print Buf
'   Incr Buf
'   Waitms 2                                                 ' обязательна небольшая задержка!
'   Print #10 , Buf
   Wait 1
   Print #10 , Buf
   Incr Buf
Loop


'(
   Print "out:";
   Input #11 , S
   Print S

   Input ">" , S
   Print #10 , S
')