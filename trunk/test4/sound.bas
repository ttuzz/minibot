'$prog &HFF , &HBD , &HC9 , &H00       ' generated. Take care that the chip supports all fuse bytes.
$regfile = "m32def.dat"                                     ' файл спецификации Меги32
$crystal = 7372800                                          ' указываем на какой частоте будем работать
$baud = 115200                                              ' указываем скорость на которой будет работать уарт

'$include "Config ports.bas"
'$include "Sound.bas"
'+библиотеки авр доса и карточки
'$include "Config_MMC.bas"
'$include "Config_AVR-DOS.BAS"

Dim Speed As Byte : Speed = 250
Dim Address_rc5 As Byte , Command_rc5 As Byte
Dim Adc_temp As Word , Akb As Single
Dim Errbyte As Byte


Print "Start MiniBot v2.0"
Print "ready"
Config Timer0 = Timer , Prescale = 64

On Timer0 Tick
Enable Interrupts
Enable Timer0

Const Cel = 32                                              ' 1/1
Const Sem = 16                                              ' 1/2
Const Qv = 8                                                ' 1/4
Const D_cr = 6                                              ' 3/16
Const Cr = 4                                                ' 1/8
Const Qu = 2                                                ' 1/16
Const Sq = 1                                                ' 1/32

Const C1 = 17                                               ' 262 -> До
Const Cis1 = 31                                             ' 278 -> До Диез
Const D1 = 43                                               ' 294 -> Ре
Const Dis1 = 56                                             ' 312 -> Ре Диез
Const E1 = 67                                               ' 330 -> Ми
Const F1 = 77                                               ' 350 -> Фа
Const Fis1 = 87                                             ' 370 -> Фа Диез
Const G1 = 97                                               ' 392 -> Соль
Const Gis1 = 106                                            ' 416 -> Соль Диез
Const A1 = 114                                              ' 440 -> Ля
Const Ais1 = 122                                            ' 467 -> Ля Диез
Const B1 = 130                                              ' 495 -> Си

Const C2 = 137                                              ' 523 -> До
Const Cis2 = 143                                            ' 554 -> До Диез
Const D2 = 150                                              ' 588 -> Ре
Const Dis2 = 156                                            ' 623 -> Ре Диез
Const E2 = 161                                              ' 660 -> Ми
Const F2 = 167                                              ' 699 -> Фа
Const Fis2 = 171                                            ' 741 -> Фа Диез
Const G2 = 176                                              ' 785 -> Соль
Const Gis2 = 180                                            ' 830 -> Соль Диез
Const A2 = 184                                              ' 880 -> Ля
Const B2 = 192                                              ' 988 -> Си

Const C3 = 196                                              ' 1048 -> До
Const Cis3 = 199                                            ' 1112 -> До Диез
Const D3 = 202                                              ' 1176 -> Ре
Const Dis3 = 204                                            ' 1248 -> Ре Диез
Const E3 = 207                                              ' 1320 -> Ми
Const F3 = 210                                              ' 1400 -> Фа
Const Fis3 = 213                                            ' 1480 -> Фа Диез

Const Silence = 0


Const C24_laenge = 101
Dim C240(101) As Byte
C240(1) = Silence
C240(2) = A1
C240(3) = Silence
C240(4) = A1
C240(5) = A1
C240(6) = C2
C240(7) = B1
C240(8) = A1
C240(9) = E2
C240(10) = Silence
C240(11) = E1
C240(12) = E1
C240(13) = Gis1
C240(14) = Fis1
C240(15) = E1
C240(16) = A1
C240(17) = Silence
C240(18) = A1
C240(19) = A1
C240(20) = C2
C240(21) = B1
C240(22) = A1
C240(23) = E2
C240(24) = E1
C240(25) = Silence
C240(26) = A1
C240(27) = Silence
C240(28) = A1
C240(29) = A1
C240(30) = C2
C240(31) = B1
C240(32) = A1
C240(33) = E2
C240(34) = Silence
C240(35) = E1
C240(36) = E1
C240(37) = Gis1
C240(38) = Fis1
C240(39) = E1
C240(40) = A1
C240(41) = Silence
C240(42) = A1
C240(43) = A1
C240(44) = C2
C240(45) = B1
C240(46) = A1
C240(47) = E2
C240(48) = E1
C240(49) = Silence
C240(50) = A2
C240(51) = Silence
C240(52) = A2
C240(53) = A2
C240(54) = C3
C240(55) = B2
C240(56) = G2
C240(57) = F2
C240(58) = Silence
C240(59) = D2
C240(60) = D2
C240(61) = F2
C240(62) = E2
C240(63) = D2
C240(64) = G2
C240(65) = Silence
C240(66) = G2
C240(67) = G2
C240(68) = A2
C240(69) = G2
C240(70) = F2
C240(71) = E2
C240(72) = Silence
C240(73) = C2
C240(74) = C2
C240(75) = E2
C240(76) = D2
C240(77) = E2
C240(78) = F2
C240(79) = Silence
C240(80) = B1
C240(81) = B1
C240(82) = D2
C240(83) = C2
C240(84) = B1
C240(85) = E2
C240(86) = Silence
C240(87) = A1
C240(88) = A1
C240(89) = C2
C240(90) = B1
C240(91) = A1
C240(92) = F1
C240(93) = Silence
C240(94) = Dis2
C240(95) = E1
C240(96) = E2
C240(97) = D2
C240(98) = B1
C240(99) = A1
C240(100) = A1
C240(101) = Silence


Dim C241(101) As Byte
C241(1) = Sq
C241(2) = Qv
C241(3) = Cr
C241(4) = Cr
C241(5) = Cr
C241(6) = Cr
C241(7) = Cr
C241(8) = Cr
C241(9) = Qv
C241(10) = Cr
C241(11) = Cr
C241(12) = Cr
C241(13) = Cr
C241(14) = Cr
C241(15) = Cr
C241(16) = Qv
C241(17) = Cr
C241(18) = Cr
C241(19) = Cr
C241(20) = Cr
C241(21) = Cr
C241(22) = Cr
C241(23) = Sem
C241(24) = Qv
C241(25) = Qv
C241(26) = Qv
C241(27) = Cr
C241(28) = Cr
C241(29) = Cr
C241(30) = Cr
C241(31) = Cr
C241(32) = Cr
C241(33) = Qv
C241(34) = Cr
C241(35) = Cr
C241(36) = Cr
C241(37) = Cr
C241(38) = Cr
C241(39) = Cr
C241(40) = Qv
C241(41) = Cr
C241(42) = Cr
C241(43) = Cr
C241(44) = Cr
C241(45) = Cr
C241(46) = Cr
C241(47) = Sem
C241(48) = Qv
C241(49) = Qv
C241(50) = Qv
C241(51) = Cr
C241(52) = Cr
C241(53) = Cr
C241(54) = Cr
C241(55) = Cr
C241(56) = Cr
C241(57) = Qv
C241(58) = Cr
C241(59) = Cr
C241(60) = Cr
C241(61) = Cr
C241(62) = Cr
C241(63) = Cr
C241(64) = Qv
C241(65) = Cr
C241(66) = Cr
C241(67) = Cr
C241(68) = Cr
C241(69) = Cr
C241(70) = Cr
C241(71) = Qv
C241(72) = Cr
C241(73) = Cr
C241(74) = Cr
C241(75) = Cr
C241(76) = Cr
C241(77) = Cr
C241(78) = Qv
C241(79) = Cr
C241(80) = Cr
C241(81) = Cr
C241(82) = Cr
C241(83) = Cr
C241(84) = Cr
C241(85) = Qv
C241(86) = Cr
C241(87) = Cr
C241(88) = Cr
C241(89) = Cr
C241(90) = Cr
C241(91) = Cr
C241(92) = Qv
C241(93) = Cr
C241(94) = Cr
C241(95) = Cr
C241(96) = Cr
C241(97) = Cr
C241(98) = Cr
C241(99) = Sem
C241(100) = Qv
C241(101) = Qv


Dim Lang As Byte
Dim T1reload As Byte
Dim Index As Byte
Index = 1
Dim I As Word

Config Pind.7 = Output
Portd.7 = 0


Do
   Gosub Sound_1
Loop


Sound_1:
   Lang = C241(index)
   T1reload = C240(index)
   For I = Lang To 0 Step -1
     Waitms 20
   Next
   Incr Index
   If Index > C24_laenge Then Index = 1
   T1reload = Silence
   Waitms 5
Return

Tick:
   Timer0 = T1reload
   If T1reload = Silence Or Portd.7 = 1 Then
      Portd.7 = 0
   Else
      Portd.7 = 1
   End If
Return