$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 9600

$hwstack = 64
$swstack = 64
$framesize = 64


Dim S As String * 20
   Dim Arr(20) As Byte At S Overlay
   Dim Substr As String * 18 At Arr(3) Overlay

S = "abcd"
Do
   Print Chr(12);
   Print "sub: " ; Substr
   Print "s: " ; S

   Input "input: " , Substr
   Mid(s , 1 , 2) = "u>"
   Print S
Loop



