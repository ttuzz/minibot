$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 115200
Config Serialin = Buffered , Size = 20

$include "Config_MMC.bas"
$include "Config_AVR-DOS.BAS"

Enable Interrupts

Dim B As Byte

Dim Berrorcode As Byte
Berrorcode = Initfilesystem(1)
If Berrorcode > 0 Then
   Print "Fat Error: " ; Berrorcode
Else
   Print "FAT Init"
End If

Config Pind.7 = Output

Config Timer2 = Pwm , Pwm = On , Prescale = 1 , Compare Pwm = Clear Down
'Config Timer2 = Pwm , Prescale = 1 , Pwm = On , Compare = Toggle

'On Oc2 Oc2_int

Dim File As String * 20
File = "test3.wav"
Open File For Binary As #2


Start Timer2
'Enable Oc2

Do
   Waitus 50
   Get #2 , B
   Ocr2 = B
Loop Until Eof(#2) <> 0

'F = 1
'Do
'   If I > 59000 Then Goto Endwav
'Loop
'Endwav:
'F = 0

Print "End Wav"

'Disable Oc2
Stop Timer2

Close #2

Do
Loop




'For I = 1 To 59084
'   Waitus 50
'   Get #2 , B
'   Ocr2 = B
'Next

'Do
'   If I > 59000 Then Goto Endwav
'Loop
'Endwav:

'Oc2_int:
   'Incr F
   'If F < 5 Then Goto End_int
   'F = 0
'   If F = 0 Then Goto End_int
'   Incr I
'   Get #2 , B
'   Ocr2 = B
'   Print B
'End_int:
'Return
'Return