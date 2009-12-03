$regfile = "m32DEF.dat"
$crystal = 7372800                                          '11059200
$baud = 115200
$hwstack = 128
$swstack = 128
$framesize = 128

'Display Pin  =>    AVR Pin
'            1 Reset            C6
'            2 CS               C5
'            3 GND              GND
'            4 Sdata            C4
'            5 Sclk             C3
'            6 Vdigital         Vdd (3 Volt)
'            7 Vbooster         Vdd (3 Volt)
'            8 Vlcd
Config Pinc.4 = Output : Reset_lcd Alias Portc.4
Config Pinc.5 = Output : Cs Alias Portc.5
Config Pinc.6 = Output : Sdata Alias Portc.6
Config Pinc.7 = Output : Sclk Alias Portc.7

'----------------Программа работы с экраном от нокии 3510i----------------------
'---------------Одна строка по горизонтали занимает 98 точек--------------------
'------------------------Всего в дисплее 67 строк-------------------------------
'---------------------------Итого  6566 байт------------------------------------
'В режиме Doublesize=1 экран выводит 8 по горизонтали и 4 строки по вертикали

Const Lcd_cmd = 0
Const Lcd_prm = 1
'Ddrc = &B11111111
Dim Lcd_doublesize As Byte , Temp As Byte , Temp1 As Byte
Dim Lcd_posx As Byte
Dim Lcd_posy As Byte
Dim Lcd_fcolor As Byte
Dim Lcd_bcolor As Byte
Dim Digit As Byte , Dsa As Byte

Declare Sub Lcd_cls
Declare Sub Display_setup
Declare Sub Lcd_setcolor(byval Forecolor As Byte , Byval Backcolor As Byte)
Declare Sub Lcd_sendbyte(byval Lcd_command As Byte , Byval Lcd_data As Byte)
Declare Sub Lcd_setframe(byval Lcd_left As Byte , Byval Lcd_top As Byte , Byval Lcd_width As Byte , Byval Lcd_height As Byte)
Declare Sub Lcd_locate(byval Lcd_x As Byte , Byval Lcd_y As Byte)
Declare Sub Lcd_print(byval Lcd_text As String)
'-------------------------------------------------------------------------------
Call Display_setup
Call Lcd_setcolor(&Hff , &H00)                              'Установим цвет точки и цвет фона
Call Lcd_cls                                                '
'Начало работы программы

Do
'Dsa = Inkey()
Call Lcd_locate(1 , 1)
Call Lcd_print( "ABCDEFGHIJKLMN" )

Call Lcd_locate(1 , 2)                                      'x,y
Call Lcd_print( "OPQRSTUVWXYZ" )

Print "123123"


Loop









'-------------------------------------------------------------------------------
'-------------------------------------------------------------------------------
'-------------------------------------------------------------------------------
'-----------------------------------Подпрограммы--------------------------------

Sub Lcd_cls

Local R As Integer
   Call Lcd_setframe(0 , 0 , 97 , 67)
   For R = 1 To 6566
      Call Lcd_sendbyte(lcd_prm , Lcd_bcolor)
   Next

End Sub

Sub Lcd_setcolor(byval Forecolor As Byte , Byval Backcolor As Byte)

   Lcd_fcolor = Forecolor
   Lcd_bcolor = Backcolor

End Sub


'-----------Подпрограмма отправки данных либо команды в LCD---------------------
Sub Lcd_sendbyte(byval Lcd_command As Byte , Byval Lcd_data As Byte)
   Reset Cs
   If Lcd_command = Lcd_cmd Then
     'команда
     Cs = 0                                                 '

     Sdata = 0
     Sclk = 0                                               '
     Sdata = 1

   Else
      'данные
      Cs = 0                                                '

      Sdata = 0
      Sclk = 1                                              '
      Sdata = 1

   End If

   Shiftout Sdata , Sclk , Lcd_data , Msbl

   Set Cs

End Sub
'-------------------Выбор кусочка экрана----------------------
Sub Lcd_setframe(byval Lcd_left As Byte , Byval Lcd_top As Byte , Byval Lcd_width As Byte , Byval Lcd_height As Byte)

   Call Lcd_sendbyte(lcd_cmd , &H2A)
   Call Lcd_sendbyte(lcd_prm , Lcd_left)
   Call Lcd_sendbyte(lcd_prm , Lcd_width)

   Call Lcd_sendbyte(lcd_cmd , &H2B)
   Call Lcd_sendbyte(lcd_prm , Lcd_top)
   Call Lcd_sendbyte(lcd_prm , Lcd_height)

   Call Lcd_sendbyte(lcd_cmd , &H2C)                        '

End Sub
'-----------------------------Инициализация дисплея-----------------------------
Sub Display_setup

   Reset Reset_lcd                                          'hard Reset
   Waitms 5
   Set Reset_lcd

   Set Cs
   Set Sclk
   Set Sdata

   Call Lcd_sendbyte(lcd_cmd , &H01)                        'Software Reset
   Waitms 5

   Call Lcd_sendbyte(lcd_cmd , &H11)                        'Sleep out

   Call Lcd_sendbyte(lcd_cmd , &H25)                        'Contrast
   Call Lcd_sendbyte(lcd_prm , 63)

   Call Lcd_sendbyte(lcd_cmd , &H29)                        'Display ON

   Call Lcd_sendbyte(lcd_cmd , &H03)                        'Booster voltage ON
   Waitms 40

   Call Lcd_sendbyte(lcd_cmd , &H3A)                        'Interface pixel format 8 bit
   Call Lcd_sendbyte(lcd_prm , &H02)

   Call Lcd_sendbyte(lcd_cmd , &H2D)                        'Colour set
   'Green
   Restore Setup_data
   For Temp = 1 To 20
   Read Temp1
   Call Lcd_sendbyte(lcd_prm , Temp1)
   Next Temp

   Call Lcd_sendbyte(lcd_cmd , &H2C)

   Lcd_doublesize = 0
   Lcd_posx = 1
   Lcd_posy = 1
   End Sub

'----------------Подпрограмма перекодировки строки в код из еепрома-------------
 Sub Lcd_print(byval Lcd_text As String)

Local R As Integer
Local A As Byte
Local B As Byte
Local C As Long
Local D As Byte
Local E As Byte
Local F As Byte
Local G As Long
Local Zeichen As String * 10

   Call Lcd_sendbyte(lcd_cmd , &H36)                        '
   Call Lcd_sendbyte(lcd_prm , &B00100000)

   Call Lcd_sendbyte(lcd_cmd , &H2C)                        '

   For R = 1 To Len(lcd_text)

      Zeichen = Mid(lcd_text , R , 1)                       'Hole char
      G = Asc(zeichen)                                      '
      G = G - 32
      G = G * 5

      Readeeprom B , G

      Call Lcd_locate(lcd_posx , Lcd_posy)

      A = 8                                                 '1.linie frei
      'If Lcd_doublesize = 1 Then A = 32
      'If Lcd_doublesize = 2 Then A = 16
      While A > 0
         Call Lcd_sendbyte(lcd_prm , Lcd_bcolor)
         Decr A
      Wend


      For F = 1 To 5
         C = 1
         While C > 0
            D = B                                           '
            For E = 1 To 8
               A = D And 1
               If A = 1 Then
                  Call Lcd_sendbyte(lcd_prm , Lcd_fcolor)
                  Else
                  Call Lcd_sendbyte(lcd_prm , Lcd_bcolor)
               End If
               Shift D , Right , 1
            Next
            Decr C
         Wend
         G = G + 1
         Readeeprom B , G
      Next

      Incr Lcd_posx

         If Lcd_posx > 16 Then
            Lcd_posx = 1
            Incr Lcd_posy
            If Lcd_posy > 8 Then Lcd_posy = 1
         End If


   Next

   Call Lcd_sendbyte(lcd_cmd , &H36)                        '
   Call Lcd_sendbyte(lcd_prm , 0)

   Call Lcd_sendbyte(lcd_cmd , &H2C)                        'команда записи в память

End Sub

'-------------------------------------------------------------------------------
'установим координаты
'-------------------------------------------------------------------------------
Sub Lcd_locate(byval Lcd_x As Byte , Byval Lcd_y As Byte)

Local A As Byte
Local B As Byte
Local C As Byte
Local D As Byte

   Lcd_posx = Lcd_x
   Lcd_posy = Lcd_y

      A = Lcd_x - 1
      A = A * 6
      C = A + 5
      B = Lcd_y - 1
      B = B * 8
      B = B + 2
      D = B + 7


   Call Lcd_setframe(a , B , C , D)

End Sub

Decode:
Select Case Digit
Case 0 : Call Lcd_print( "0")
Case 1 : Call Lcd_print( "1")
Case 2 : Call Lcd_print( "2")
Case 3 : Call Lcd_print( "3")
Case 4 : Call Lcd_print( "4")
Case 5 : Call Lcd_print( "5")
Case 6 : Call Lcd_print( "6")
Case 7 : Call Lcd_print( "7")
Case 8 : Call Lcd_print( "8")
Case 9 : Call Lcd_print( "9")
End Select
Return



Setup_data:
  Data &H00 , &H02 , &H04 , &H06 , &H09 , &H0B , &H0D , &H0F
  Data &H00 , &H02 , &H04 , &H06 , &H09 , &H0B , &H0D , &H0F
  Data &H00 , &H04 , &H0B , &H0F

$eeprom
Data &H00 , &H00 , &H00 , &H00 , &H00                       ' "(space)"
Data &H00 , &H06 , &H5F , &H06 , &H00                       ' "!"
Data &H07 , &H03 , &H00 , &H07 , &H03 ' """
Data &H24 , &H7E , &H24 , &H7E , &H24                       ' "#"
Data &H24 , &H2B , &H6A , &H12 , &H00                       ' "$"
Data &H63 , &H13 , &H08 , &H64 , &H63                       ' "%"
Data &H36 , &H49 , &H56 , &H20 , &H50                       ' "&"
Data &H00 , &H07 , &H03 , &H00 , &H00                       ' "'"
'40
Data &H00 , &H3E , &H41 , &H00 , &H00                       ' "("
Data &H00 , &H41 , &H3E , &H00 , &H00                       ' ")"
Data &H08 , &H3E , &H1C , &H3E , &H08                       ' "*"
Data &H08 , &H08 , &H3E , &H08 , &H08                       ' "+"
Data &H00 , &HE0 , &H60 , &H00 , &H00                       ' ","
Data &H08 , &H08 , &H08 , &H08 , &H08                       ' "-"
Data &H00 , &H60 , &H60 , &H00 , &H00                       ' "."
Data &H20 , &H10 , &H08 , &H04 , &H02                       ' "/"
Data &H3E , &H51 , &H49 , &H45 , &H3E                       ' "0"
Data &H00 , &H42 , &H7F , &H40 , &H00                       ' "1"
'50
Data &H62 , &H51 , &H49 , &H49 , &H46                       ' "2"
Data &H22 , &H49 , &H49 , &H49 , &H36                       ' "3"
Data &H18 , &H14 , &H12 , &H7F , &H10                       ' "4"
Data &H2F , &H49 , &H49 , &H49 , &H31                       ' "5"
Data &H3C , &H4A , &H49 , &H49 , &H30                       ' "6"
Data &H01 , &H71 , &H09 , &H05 , &H03                       ' "7"
Data &H36 , &H49 , &H49 , &H49 , &H36                       ' "8"
Data &H06 , &H49 , &H49 , &H29 , &H1E                       ' "9"
Data &H00 , &H6C , &H6C , &H00 , &H00                       ' ":"
Data &H00 , &HEC , &H6C , &H00 , &H00                       ' ";"
'60
Data &H08 , &H14 , &H22 , &H41 , &H00                       ' "<"
Data &H24 , &H24 , &H24 , &H24 , &H24                       ' "="
Data &H00 , &H41 , &H22 , &H14 , &H08                       ' ">"
Data &H02 , &H01 , &H59 , &H09 , &H06                       ' "?"
Data &H3E , &H41 , &H5D , &H55 , &H1E                       ' "@"
Data &H7E , &H09 , &H09 , &H09 , &H7E                       ' "A"
Data &H7F , &H49 , &H49 , &H49 , &H36                       ' "B"
Data &H3E , &H41 , &H41 , &H41 , &H22                       ' "C"
Data &H7F , &H41 , &H41 , &H41 , &H3E                       ' "D"
Data &H7F , &H49 , &H49 , &H49 , &H41                       ' "E"
'70
Data &H7F , &H09 , &H09 , &H09 , &H01                       ' "F"
Data &H3E , &H41 , &H49 , &H49 , &H7A                       ' "G"
Data &H7F , &H08 , &H08 , &H08 , &H7F                       ' "H"
Data &H00 , &H41 , &H7F , &H41 , &H00                       ' "I"
Data &H30 , &H40 , &H40 , &H40 , &H3F                       ' "J"
Data &H7F , &H08 , &H14 , &H22 , &H41                       ' "K"
Data &H7F , &H40 , &H40 , &H40 , &H40                       ' "L"
Data &H7F , &H02 , &H04 , &H02 , &H7F                       ' "M"
Data &H7F , &H02 , &H04 , &H08 , &H7F                       ' "N"
Data &H3E , &H41 , &H41 , &H41 , &H3E                       ' "O"
Data &H7F , &H09 , &H09 , &H09 , &H06                       ' "P"
'80
Data &H3E , &H41 , &H51 , &H21 , &H5E                       ' "Q"
Data &H7F , &H09 , &H09 , &H19 , &H66                       ' "R"
Data &H26 , &H49 , &H49 , &H49 , &H32                       ' "S"
Data &H01 , &H01 , &H7F , &H01 , &H01                       ' "T"
Data &H3F , &H40 , &H40 , &H40 , &H3F                       ' "U"
Data &H1F , &H20 , &H40 , &H20 , &H1F                       ' "V"
Data &H3F , &H40 , &H3C , &H40 , &H3F                       ' "W"
Data &H63 , &H14 , &H08 , &H14 , &H63                       ' "X"
Data &H07 , &H08 , &H70 , &H08 , &H07                       ' "Y"
Data &H71 , &H49 , &H45 , &H43 , &H00                       ' "Z"
Data &H00 , &H7F , &H41 , &H41 , &H00                       ' "["
'90
Data &H02 , &H04 , &H08 , &H10 , &H20                       ' "\"
Data &H00 , &H41 , &H41 , &H7F , &H00                       ' "]"
Data &H04 , &H02 , &H01 , &H02 , &H04                       ' "^"
Data &H80 , &H80 , &H80 , &H80 , &H80                       ' "_"
Data &H00 , &H03 , &H07 , &H00 , &H00                       ' "`"
Data &H20 , &H54 , &H54 , &H54 , &H78                       ' "a"
Data &H7F , &H44 , &H44 , &H44 , &H38                       ' "b"
Data &H38 , &H44 , &H44 , &H44 , &H28                       ' "c"
Data &H38 , &H44 , &H44 , &H44 , &H7F                       ' "d"
Data &H38 , &H54 , &H54 , &H54 , &H18                       ' "e"
Data &H08 , &H7E , &H09 , &H09 , &H00                       ' "f"
'100
Data &H18 , &HA4 , &HA4 , &HA4 , &H7C                       ' "g"
Data &H7F , &H04 , &H04 , &H78 , &H00                       ' "h"
Data &H00 , &H00 , &H7D , &H00 , &H00                       ' "i"
Data &H40 , &H80 , &H84 , &H7D , &H00                       ' "j"
Data &H7F , &H10 , &H28 , &H44 , &H00                       ' "k"
Data &H00 , &H00 , &H7F , &H40 , &H00                       ' "l"
Data &H7C , &H04 , &H18 , &H04 , &H78                       ' "m"
Data &H7C , &H04 , &H04 , &H78 , &H00                       ' "n"
Data &H38 , &H44 , &H44 , &H44 , &H38                       ' "o"
Data &HFC , &H44 , &H44 , &H44 , &H38                       ' "p"
Data &H38 , &H44 , &H44 , &H44 , &HFC                       ' "q"
'110
Data &H44 , &H78 , &H44 , &H04 , &H08                       ' "r"
Data &H08 , &H54 , &H54 , &H54 , &H20                       ' "s"
Data &H04 , &H3E , &H44 , &H24 , &H00                       ' "t"
Data &H3C , &H40 , &H20 , &H7C , &H00                       ' "u"
Data &H1C , &H20 , &H40 , &H20 , &H1C                       ' "v"
Data &H3C , &H60 , &H30 , &H60 , &H3C                       ' "w"
Data &H6C , &H10 , &H10 , &H6C , &H00                       ' "x"
Data &H9C , &HA0 , &H60 , &H3C , &H00                       ' "y"
Data &H64 , &H54 , &H54 , &H4C , &H00                       ' "z"
Data &H08 , &H3E , &H41 , &H41 , &H00                       ' "{"
'120
Data &H00 , &H00 , &H7F , &H00 , &H00                       ' "|"
Data &H00 , &H41 , &H41 , &H3E , &H08                       ' "}"
Data &H02 , &H01 , &H02 , &H01 , &H00                       ' "~"

Data &H3F , &H21 , &H21 , &H21 , &H21                       ' "["
Data &H21 , &H21 , &H21 , &H21 , &H21
Data &H21 , &H21 , &H21 , &H21 . &H3F                       ' "]"
Data &H3F , &H3F , &H3F , &H3F , &H3F
Data &H3F , &H00 , &H00 , &H00 , &H00