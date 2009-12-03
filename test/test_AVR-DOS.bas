$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 19200
Config Serialin = Buffered , Size = 20
Waitms 250 : Print "Код скомпилирован  " ; Version()

'$hwstack = 128
'$swstack = 128
'$framesize = 128

Enable Interrupts

$include "Config_MMC.bas"
$include "Config_AVR-DOS.BAS"

Dim Berrorcode As Byte
Berrorcode = Initfilesystem(1)
If Berrorcode > 0 Then
   Print "Ошибка FAT: " ; Berrorcode
Else
   Print "FAT проинициализирован"
End If

Print Gbdoserror
'
'Print "Открываю файл"

'Dim S As String * 12
'Open "country.txt" For Input As #2
'Do
'   Line Input #2 , S
'  Print S
'Loop Until Eof(#2) <> 0
'Close #2

'Print Bin(getattr( "country.txt"))

'Print "Готово"




Do
Loop