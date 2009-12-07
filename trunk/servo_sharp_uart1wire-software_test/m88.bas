$regfile = "m88DEF.dat"
$baud = 9600
$crystal = 7372800

$hwstack = 32
$swstack = 10
$framesize = 40

Config Servos = 1 , Servo1 = Portb.0 , Reload = 10 , Timer = Timer2

Open "comc.4:9600,8,n,1" For Output As #10

Dim S As String * 20

Do
'(
   Print "out:";
   Input #11 , S
   Print S

   Input ">" , S
   Print #10 , S
')
   Print #10 , "USUE" ;
   Printbin &B01010101
   Waitms 50
Loop
