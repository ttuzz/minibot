$regfile = "m8DEF.dat"
$baud = 9600
$crystal = 7372800

$hwstack = 32
$swstack = 10
$framesize = 40

'Config Serialin = Buffered , Size = 10
Config Pind.0 = Output
Portd.0 = 0


Open "comc.5:9600,8,n,1" For Input As #10

Dim S As String * 20

Do
   Print "out:";
   Input #10 , S
   Print S
Loop

Print "done"
