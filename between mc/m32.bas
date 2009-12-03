$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 9600

$hwstack = 64
$swstack = 64
$framesize = 64

Open "comc.1:9600,8,n,1" For Output As #11


Dim S As String * 20

Do
   Print ">" ;
   Input S
   Print #11 , S
Loop


Print "done"





