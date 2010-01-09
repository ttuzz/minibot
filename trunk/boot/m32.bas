$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 115200

$hwstack = 64
$swstack = 64
$framesize = 64

Config Pinc.4 = Output : Led_r1 Alias Portc.4 : Led_r1 = 0
Config Pinc.5 = Output : Led_g1 Alias Portc.5 : Led_g1 = 0
Config Pinc.6 = Output : Led_r2 Alias Portc.6 : Led_r2 = 0
Config Pinc.7 = Output : Led_g2 Alias Portc.7 : Led_g2 = 0
Config Pind.2 = Input : Button Alias Pind.2

Dim S As String * 20
   Dim Arr(20) As Byte At S Overlay
   Dim Substr As String * 18 At Arr(3) Overlay

' процедуры
Declare Sub Printf(byval S As String)
   Dim Text As String * 50

S = "abcd"
Do
   'Input S Noecho
   'Print "'" ; S ; "'"
   'Call Printf( "")
   'Mid(s , 1 , 1) = "'"
   'Call Printf(s)
   If Button = 0 Then Goto &H3C00
   Toggle Led_g2
   Toggle Led_r1
   Waitms 500
Loop


Sub Printf(byval S As String)
   Local Cnt As Byte
   Local Len1 As Byte
   Local Buf As String * 1
   Reset Ucsrb.rxen
   Len1 = Len(s)
   For Cnt = 1 To Len1
      Bitwait Ucsra.udre , Set                              ' ожидаю момента, когда можно загрузить новые данные
      Buf = Mid(s , Cnt , 1)
      Udr = Asc(buf)
   Next
      Bitwait Ucsra.udre , Set
      Udr = 13
      Bitwait Ucsra.udre , Set
      Udr = 10
      Set Ucsra.txc                                         ' очищаю флаг прерывания
      Bitwait Ucsra.txc , Set                               ' жду пока передатчик не передаст весь пакет (из внутреннего буфера, не UDR)
   Set Ucsrb.rxen
End Sub