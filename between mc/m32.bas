$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 9600

$hwstack = 64
$swstack = 64
$framesize = 64

Open "comc.1:9600,8,n,1" For Output As #12
Open "comc.0:9600,8,n,1" For Input As #11

Config Servos = 1 , Servo1 = Portb.0 , Reload = 10
Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down


Dim S As String * 20

Do

   Print ">" ;
   Input S
   Print #12 , S

   Print "out:";
   Input #11 , S
   Print S
Loop


Print "done"




