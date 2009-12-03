' Release Date 2009-01-11
' Driver and AVR-DOS must be configured first in main program
' author: MiBBiM

'**********MINIBOT CONFIGS**********
'????????
$prog &HFF , &HE4 , &HD9 , &H00

'??????
$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 9600
Config Serialin = Buffered , Size = 10

'????? ????????????+ ????
$hwstack = 64
$swstack = 64
$framesize = 64

$include "Config_MMC.bas"
$include "Config_AVR-DOS.BAS"

Dim S As String * 30

Dim Berrorcode As Byte
Berrorcode = Initfilesystem(0)
If Berrorcode > 0 Then
   Print "Fat Error: " ; Berrorcode
Else
   Print "FAT Initiated"
End If




Open "1.bat" For Input As #1
Open "2.bat" For Append As #2 'открываю ддля дозаписи

Print "1.bat includes"
Do
   Line Input #1 , S
   Print S
Loop Until Eof(#1) <> 0


Print "wrtie to 2.bat"
Print #2 , "some string"
Print #2 , "other string"
Close #2

Open "2.bat" For Input As #2
Print "2.bat includes"
Do
   Line Input #2 , S
   Print S
Loop Until Eof(#2) <> 0
Close #2
Close #1


Do
Loop



