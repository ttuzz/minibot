' Release Date 2009-01-11
' Driver and AVR-DOS must be configured first in main program
' author Josef Franz V?gel
' author: MiBBiM

'**********MINIBOT CONFIGS**********
'фусибиты
$prog &HFF , &HE4 , &HD9 , &H00

'камень
$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 115200
Config Serialin = Buffered , Size = 20

'делаю супермегабиг+ стек
$hwstack = 128
$swstack = 128
$framesize = 128

'библиотеки AVR-DOS и SD
$include "Config_MMC.bas"
$include "Config_AVR-DOS.BAS"

'если перезагрузились софтово(через собачку)
Stop Watchdog

'светодиоды
Config Pinc.4 = Output : Led_r1 Alias Portc.4
Config Pinc.5 = Output : Led_g1 Alias Portc.5
Config Pinc.6 = Output : Led_r2 Alias Portc.6
Config Pinc.7 = Output : Led_g2 Alias Portc.7

'двигатели с ШИМом
Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down
Config Pinc.2 = Output : Drl Alias Portc.2                  ' DrL
Config Pinc.3 = Output : Drr Alias Portc.3                  ' DrR
Config Pind.4 = Output                                      'PWM L
Config Pind.5 = Output                                      'PWM R

'останавливаю двигатели
Drl = 0
Drr = 0
Pwm1a = 0
Pwm1b = 0

'прием ИК-команд
Config Rc5 = Pind.2

      Wait 2

      Print "MiniBot v.2 is configured"

      Led_g1 = 1

      Enable Interrupts
'///**********MINIBOT CONFIGS**********


'**********INTERPRETER VARS**********
'interpreter configs
Const Cpno = 0
Const Cpyes = 1
Const Cptoken_max = 6                                       ' Count of Tokens in USER-Input
Const Cpstrsep = ","                                        ' Blank: Separator between tokens
Const Cpcinput_len = 150                                    ' max. length of user-Input
Const Ctoken_len = 16                                       'max. length of token


Dim Gstoken As String * Ctoken_len                          ' holds current token
Dim Gspcinput As String * Cpcinput_len                      ' holds user-input
Dim Gbposstrparts(cptoken_max) As Byte                      ' for analysing user-input
Dim Gblenstrparts(cptoken_max) As Byte                      '
Dim Gbcnttoken As Byte                                      ' found tokens in user-input
Dim Gbtoken_actual As Byte                                  ' actual handled token of user-input
Dim Gbpcinputerror As Byte                                  ' holds error-code during analysing user-input

'interpreter subs
Declare Sub Avr_dos
Declare Sub Docommand()

Declare Sub Extracttoken()
Declare Function Getnexttokenstr(byval Pblen_max As Byte ) As String
Declare Function Getnexttokenlong(byval Plmin As Long , Byval Plmax As Long ) As Long

Declare Sub Printdoserror()
Declare Sub Printparametererrorl(plparamlow As Long , Plparamhigh As Long)
Declare Sub Printparametercounterror(byval Psparm_anzahl As String)

Declare Sub Printprompt()

Declare Sub Printdriveerror()
Declare Sub Printfilesysteminfo()

'my subs
Declare Sub Decodebase64()
'///**********INTERPRETER VARS**********


Call Avr_dos
End


Sub Avr_dos
Gspcinput = ""

Print "AVR-DOS: Ready for commands"
Do
   Print Chr(10) ; Chr(13) ;
   Print "Command: " ;

   Waitms 6
   Clear Serialin

   Input Gspcinput Noecho
   Print Chr(10) ; Chr(13) ;

   Docommand
   Gspcinput = ""
Loop

End Sub


Sub Docommand
   ' interpretes the user-input and execute
   ' Local variables
   Local Lbyte1 As Byte , Lbyte2 As Byte
   Local Lint1 As Integer
   Local Lword1 As Word
   Local Llong1 As Long , Llong2 As Long
   Local Lsingle1 As Single

   Extracttoken                                             ' token analysing

   Gbtoken_actual = 0                                       ' reset to beginn of line (first token)
   Gbpcinputerror = Cpno

   If Gbcnttoken > 0 Then                                   ' is there any input


      Gstoken = Getnexttokenstr(ctoken_len)                 ' get first string-token = command
      Gstoken = Ucase(gstoken)                              ' all uppercase

      Select Case Gstoken

'=======================================================================
                                                             ' File System apps

         Case "CFCHECK"                                     ' check Compactflash Card
              Lbyte1 = Drivecheck()
              If Lbyte1 = 0 Then
                  Print "OK"
              End If
              Printdriveerror

         Case "FS"                                          ' Init File System
         Print "In FS Case"

            If Gbcnttoken = 2 Then
               Llong1 = Getnexttokenlong(0 , 3)
               Lbyte1 = Llong1
               Lbyte2 = Initfilesystem(lbyte1)
               If Lbyte2 <> 0 Then
                  Print "Error at file system init"
               Else
                  Printfilesysteminfo
               End If

            Else
               Printparametercounterror "1 "
            End If

         Case "DISKSIZE"
            Llong1 = Disksize()
            Print Llong1

         Case "ERROR"                                       'выводит инфо о последней ошибке
            Printdoserror
            Print "Error printed"

'=============================================================================
                                                      'minibot apps

       Case "LEDON"                                         ' Led On
           If Gbcnttoken = 2 Then
               Gstoken = Getnexttokenstr(2)
               Gstoken = Trim(gstoken)
               Select Case Gstoken
                  Case "r1" : Led_r1 = 1
                  Case "r2" : Led_r2 = 1
                  Case "g1" : Led_g1 = 1
                  Case "g2" : Led_g2 = 1
                  Case Else : Print "Wrong Identifier"
               End Select
               Print "Ok"
           Else
              Printparametercounterror " 1 "
           End If

       Case "LEDOFF"                                        ' Led Off
           If Gbcnttoken = 2 Then
               Gstoken = Getnexttokenstr(2)
               Gstoken = Trim(gstoken)
               Select Case Gstoken
                  Case "r1" : Led_r1 = 0
                  Case "r2" : Led_r2 = 0
                  Case "g1" : Led_g1 = 0
                  Case "g2" : Led_g2 = 0
                  Case Else : Print "Wrong Identifier"
               End Select
               Print "Ok"
           Else
              Printparametercounterror " 1 "
           End If

       Case "GO"                                            'GO L,R,pwm1B,pwm1A
           If Gbcnttoken = 5 Then
               If Getnexttokenlong(0 , 1) = 0 Then
                  Drl = 0
               Else                                         'dirl
                  Drl = 1
               End If

               If Getnexttokenlong(0 , 1) = 0 Then
                  Drr = 0
               Else                                         'dirr
                  Drr = 1
               End If

               Llong1 = Getnexttokenlong(0 , 255)
               Llong2 = Getnexttokenlong(0 , 255)

               'convert
               Lbyte1 = Llong1
               Lbyte2 = Llong2

               Pwm1b = Lbyte1                               'pwml
               Pwm1a = Lbyte2                               'pwmr
           Else
              Printparametercounterror " 4 "
           End If

       Case "GETRC5"                                        'RC5
           Getrc5(lbyte1 , Lbyte2)
           If Lbyte1 <> 255 And Lbyte2 <> 255 Then
               Lbyte2 = Lbyte2 And &B01111111
               Print Chr(12);
               Print "Address - " ; Lbyte1
               Print "Command - " ; Lbyte2
           Else
               Print "Wrong RC5 Code"
           End If

       Case "RESET"                                         'SoftReset
           Print "Reloading..."
           Config Watchdog = 128
           Start Watchdog
           Wait 3

       Case "BATTERY"
           Start Adc
           Lword1 = Getadc(7) : Lword1 = Getadc(7) : Lword1 = Getadc(7):
           Stop Adc
           Lsingle1 = Lword1 / 235
           Print "Battery state - " ; Fusing(lsingle1 , "#.###") ; "V"

       Case "VER"
           Print "Version - Test version"

       Case "FRECEIVE"
           If Gbcnttoken = 3 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)
               Llong2 = Getnexttokenlong(1 , 2147483647)

               Open Gstoken For Binary As #2

               Print "ready"
               Waitms 1
               For Llong1 = 1 To Llong2
                  Clear Serialin
                  Input Gspcinput Noecho
                  Print Chr(10) ; Chr(13) ;

                  Decodebase64

                  Put #2 , Gspcinput

                  If Gbdoserror <> 0 Then
                     Printdoserror
                     Close #2
                     Exit For
                  Else
                     Print "ok"
                     Waitms 1
                  End If

               'Exit For
               Next

               Close #2

               Print "done"

           Else
              Printparametercounterror " 2 "
           End If

       Case "FTRANSMIT"
           If Gbcnttoken = 2 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)

               Llong2 = Filelen(gstoken)
               Llong2 = Llong2 \ 150
               Llong2 = Llong2 + 1

               Open Gstoken For Binary As #2

               Print "file:"
               For Llong1 = 1 To Llong2

                  Get #2 , Gspcinput

                  If Gbdoserror <> 0 Then
                     Printdoserror
                     Close #2
                     Exit For
                  End If

                  Print Gspcinput
               Next

               Close #2

               Print "done"
           Else
              Printparametercounterror "1 "
           End If



       Case Else

            Print "Command '" ; Gspcinput ; "' not recognized"

      End Select

   End If
End Sub




Sub Extracttoken
' Counts the Token in the Input-String: gsPCInput
' following variable and arrays are filled
' cntToken: Cont of Token
' PosStrParts: positions, where the tokens start
' LenStrParts: Count of bytes of each token

   Local Lstrlen As Byte
   Local Lparseend As Byte
   Local Lpos1 As Byte , Lpos2 As Byte
   ' Init arrays with 0
   For Gbcnttoken = 1 To Cptoken_max
      Gbposstrparts(gbcnttoken) = 0 : Gblenstrparts(gbcnttoken) = 0
   Next

   Gbcnttoken = 0
   Gspcinput = Trim(gspcinput)
   Lstrlen = Len(gspcinput)                                 ' how long is string
   If Lstrlen = 0 Then                                      'no Input ?
      Exit Sub
   End If
   Lparseend = 0
   Lpos1 = 0
   For Gbcnttoken = 1 To Cptoken_max
      Incr Lpos1
      If Gbcnttoken = 1 Then
         Lpos2 = Instr(lpos1 , Gspcinput , " ")             ' find next blank
      Else
         Lpos2 = Instr(lpos1 , Gspcinput , Cpstrsep)        ' After command look with strSep
      End If
      If Lpos2 = 0 Then                                     ' no more found?
         Lpos2 = Lstrlen : Incr Lpos2 : Lparseend = 1
      End If
      Gblenstrparts(gbcnttoken) = Lpos2 - Lpos1             ' Lenght of token
      Gbposstrparts(gbcnttoken) = Lpos1

      If Lparseend = 1 Then
         Exit For
      End If
      Lpos1 = Lpos2
   Next
End Sub


Function Getnexttokenstr(byval Pblen_max As Byte ) As String
   ' Returns next String-token from Input
   ' Parameter: pbLen_Max: Limit for string-length
   Local Lbpos As Byte
   Local Lblen As Byte
   Incr Gbtoken_actual                                      ' switch to new/next token
   Lbpos = Gbposstrparts(gbtoken_actual)                    ' at which position in string
   Lblen = Gblenstrparts(gbtoken_actual)                    ' how long
   If Lblen > Pblen_max Then Lblen = Pblen_max              ' to long?
   Getnexttokenstr = Mid(gspcinput , Lbpos , Lblen)         ' return string
End Function


Function Getnexttokenlong(byval Plmin As Long , Byval Plmax As Long ) As Long
   ' returns a Long-Value from next Token and check for inside lower and upper limit
   ' plMin: minimum limit for return-value
   ' plMax: maximum limit for return-value
   Local Lbpos As Byte
   Local Lblen As Byte
   Local Lstoken As String * 12
   Incr Gbtoken_actual                                      ' switch to new/next token
   Lbpos = Gbposstrparts(gbtoken_actual)                    ' at which position in string
   Lblen = Gblenstrparts(gbtoken_actual)                    ' how long
   If Lblen > 12 Then Lblen = 12                            ' to long?
   Lstoken = Mid(gspcinput , Lbpos , Lblen)
   Lstoken = Ltrim(lstoken)
   If Mid(lstoken , 1 , 1) = "$" Then                       ' Is input a HEX vlue?
      Mid(lstoken , 1 , 1) = " "
      Lstoken = Ltrim(lstoken)
      Getnexttokenlong = Hexval(lstoken)
   Else
      Getnexttokenlong = Val(lstoken)
   End If
   Select Case Getnexttokenlong                             ' check for limits
      Case Plmin To Plmax                                   ' within limits, noting to do
      Case Else
         Gbpcinputerror = Cpyes                             ' Set Error Sign
         Print "    "
         Print "^ " ; "Parameter Error ";
         Printparametererrorl Plmin , Plmax                 ' with wanted limits
   End Select
End Function


Sub Printparametercounterror(byval Psparm_anzahl As String * 10)
   ' User message for wrong count of parameter
   Print "? " ; Psparm_anzahl ; " " ; "Parameter " ; "expected "
End Sub

Sub Printparametererrorl(plparamlow As Long , Plparamhigh As Long)
   ' Print Limits at wrong Input - value
   Print " [ " ; Plparamlow ; " ] - [ " ; Plparamhigh ; " ] " ; "expected "
End Sub


' Print DOS Error Number
Sub Printdoserror()
   If Gbdoserror > 0 Then
      Print "DOS Error: " ; Gbdoserror
   End If
   If Gbdriveerror > 0 Then
      Printdriveerror
   End If
End Sub

Sub Printdriveerror()
   If Gbdriveerror > 0 Then
      Print "Drive Error: " ; Gbdriveerror
      Print "Drive Status:" ; Bin(gbdrivestatusreg)
      Print "Drive Debug: " ; Gbdrivedebug
   End If
End Sub


Sub Printfilesysteminfo()
   Print "File System:         " ; Gbfilesystem
   Print "File System Status:  " ; Gbfilesystemstatus
   Print "FAT first Sector:    " ; Glfatfirstsector
   Print "Number of FATs:      " ; Gbnumberoffats
   Print "Sectors per FAT:     " ; Glsectorsperfat
   Print "Root first Sector:   " ; Glrootfirstsector
   Print "Root Entries:        " ; Gwrootentries
   Print "Data first Sector:   " ; Gldatafirstsector
   Print "Sectors per Cluster: " ; Gbsectorspercluster
   Print "Highest Cluster#:    " ; Glmaxclusternumber
   Print "Start check Cluster# " ; Gllastsearchedcluster
End Sub

Sub Decodebase64()

End Sub