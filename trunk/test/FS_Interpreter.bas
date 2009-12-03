' Release Date 2006-03-11
' Driver and AVR-DOS must be configured first in main program

' Constants and variables for File System Interpreter (Shell)

$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 9600
Config Serialin = Buffered , Size = 20

$hwstack = 128
$swstack = 128
$framesize = 128

Enable Interrupts

$include "Config_MMC.bas"
$include "Config_AVR-DOS.BAS"

Const Cpno = 0                                              '
Const Cpyes = 1
Const Cptoken_max = 10                                      ' Count of Tokens in USER-Input
Const Cpstrsep = ","                                        ' Blank: Separator between tokens
Const Cpcinput_len = 80                                     ' max. length of user-Input

Dim Transferbuffer_write As Word
Dim Erampointer As Word
Dim Gstestline As String * 100
Dim Gstestline64 As String * 64 At Gstestline Overlay
Dim Gstoken As String * 100
Dim Gspcinput As String * 100                               ' holds user-input
Dim Gbposstrparts(cptoken_max) As Byte                      ' for analysing user-input
Dim Gblenstrparts(cptoken_max) As Byte                      '
Dim Gbcnttoken As Byte                                      ' found tokens in user-input
Dim Gbtoken_actual As Byte                                  ' actual handled token of user-input
Dim Gbpcinputerror As Byte                                  ' holds error-code during analysing user-input
Dim Gbpcinputpointer As Byte                                ' string-pointer during user-input

Dim Gldumpbase As Long
Dim Gwtemp1 As Word , Gbtemp1 As Byte
Dim Gword1 As Word
Dim Bsec As Byte , Bmin As Byte , Bhour As Byte , Bday As Byte , Bmonth As Byte , Byear As Byte
Dim Gbinp As Byte                                           ' holds user input

Declare Sub Avr_dos
Declare Sub Docommand()
Declare Sub Extracttoken()
Declare Function Getnexttokenstr(byval Pblen_max As Byte ) As String
Declare Function Getnexttokenlong(byval Plmin As Long , Byval Plmax As Long ) As Long
Declare Sub Printparametererrorl(plparamlow As Long , Plparamhigh As Long)
Declare Sub Printparametercounterror(byval Psparm_anzahl As String)
Declare Sub Getinput(byval Pbbyte As Byte)
Declare Sub Printprompt()
Declare Function Getlongfrombuffer(pbsramarray As Byte , Byval Pbpos As Word) As Long
Declare Function Getwordfrombuffer(pbsramarray As Byte , Byval Pbpos As Word) As Word
Declare Sub Sramdump(pwsrampointer As Word , Byval Pwlength As Word , Plbase As Long)
Declare Sub Eramdump(pwerampointer As Word , Byval Pwlength As Word )
Declare Sub Printdoserror()
Declare Sub Directory(pstr1 As String)
'Declare Sub Directory1(pstr1 As String , Pdays As Word)
Declare Sub Delete(pstr1 As String)
Declare Function Printfile(psname As String) As Byte
Declare Function Dumpfile(psname As String) As Byte
Declare Sub Printfileinfo(pbfilenr As Byte)
Declare Sub Printdriveerror()
Declare Sub Printdirinfo()
Declare Sub Printfatinfo()
Declare Sub Printfilesysteminfo()
Declare Sub Typewildcard(pstr1 As String)


Call Avr_dos
End


Sub Avr_dos
Gbpcinputpointer = 1
Gspcinput = ""
Erampointer = 0

Print "AVR-DOS: Ready for commands"
Printprompt
Do
  Gbinp = Inkey()                                           ' get user input
  If Gbinp <> 0 Then                                        ' something typed in?
      If Gbinp = 27 Then                                    ' use ESC for exit from interpreter
         Exit Do
      End If
      Getinput Gbinp                                        ' give input to interpreter
  End If
Loop                                                        ' do forever

Print "EXIT from AVR-DOS Shell"                             'forever do nothing
Do
Loop

End Sub



Sub Getinput(pbbyte As Byte)
   ' stores bytes from user and wait for CR (&H13)
   Select Case Pbbyte
      Case &H0A                                             ' do nothing
      Case &H0D                                             ' Line-end?
         Print Chr(&H0d) ; Chr(&H0a) ;
         Docommand                                          ' analyse command and execute
         Gbpcinputpointer = 1                               ' reset for new user-input
         Gspcinput = ""
         Printprompt
      Case &H08                                             ' backspace ?
         If Gbpcinputpointer > 1 Then
            Print Chr(&H08);
            Decr Gbpcinputpointer
         End If
      Case Else                                             ' store user-input
         If Gbpcinputpointer <= Cpcinput_len Then
            Mid(gspcinput , Gbpcinputpointer , 1) = Pbbyte
            Incr Gbpcinputpointer
            Mid(gspcinput , Gbpcinputpointer , 1) = &H00    ' string-terminator
            Print Chr(pbbyte);                              ' echo back to user
         End If
   End Select
End Sub


Sub Docommand
   ' interpretes the user-input and execute
   ' Local variables
   Local Lbyte1 As Byte , Lbyte2 As Byte , Lbyte3 As Byte , Lbyte4 As Byte , Lbyte5 As Byte , Lbyte6 As Byte
   Local Lint1 As Integer , Lint2 As Integer , Lint3 As Integer , Lint4 As Integer
   Local Lword1 As Word , Lword2 As Word , Lword3 As Word , Lword4 As Word
   Local Llong1 As Long , Llong2 As Long , Llong3 As Long , Llong4 As Long , Llong5 As Long , Llong6 As Long , Llong7 As Long
   Local Lsingle1 As Single
   Local Lbpos As Byte

   Local Lblen As Byte

   Gldumpbase = 0
   Extracttoken                                             ' token analysing
   Gbtoken_actual = 0                                       ' reset to beginn of line (first token)
   Gbpcinputerror = Cpno
   Gwtemp1 = 1
   If Gbcnttoken > 0 Then                                   ' is there any input

      Gstoken = Getnexttokenstr(70)                         ' get first string-token = command
      Gstoken = Ucase(gstoken)                              ' all uppercase

      Select Case Gstoken

         Case "CFRESET"                                     ' Reset Compactflash Card
              Lbyte1 = Drivereset()
              If Lbyte1 = 0 Then
                  Print "OK"
              End If
              Printdriveerror

         Case "CFINIT"                                      ' init Compactflash Card
              Lbyte1 = Driveinit()
              If Lbyte1 = 0 Then
                  Print "OK"
              End If
              Printdriveerror

         Case "CFCHECK"                                     ' check Compactflash Card
              Lbyte1 = Drivecheck()
              If Lbyte1 = 0 Then
                  Print "OK"
              End If
              Printdriveerror

         Case "ET"                                          ' Fill Memory with Text
            If Gbcnttoken > 1 Then
               Lbyte1 = Gbposstrparts(2)
               Do
                 Gstoken = Mid(gspcinput , Lbyte1 , 1)
                 Lbyte2 = Asc(gstoken)
                 Writeeeprom Lbyte2 , Erampointer
                 Incr Erampointer
                 If Lbyte2 = 0 Then                         ' String Terminator
                    Exit Do
                 End If
                 Incr Lbyte1
               Loop Until Erampointer > &HFFF
           End If

         Case "MP"                                          ' Memory Pointer for MB and MT
              If Gbcnttoken = 2 Then
                 Llong1 = Getnexttokenlong(0 , 511)
                 If Gbpcinputerror = Cpno Then
                    Transferbuffer_write = Llong1
                 End If
              Else
                  Printparametercounterror "1 "
              End If

         Case "EP"                                          ' Memory Pointer for MB and MT
              If Gbcnttoken = 2 Then
                 Llong1 = Getnexttokenlong(0 , &H1000)
                 If Gbpcinputerror = Cpno Then
                    Erampointer = Llong1
                 End If
              Else
                  Printparametercounterror "1 "
              End If

         Case "EB"                                          'Fill Memory with Same Byte
            If Gbcnttoken > 1 Then
               For Lbyte1 = 2 To Gbcnttoken
                   Llong1 = Getnexttokenlong(0 , 255)
                   If Gbpcinputerror = Cpno Then
                      Lbyte2 = Llong1
                      Writeeeprom Lbyte2 , Erampointer
                      Incr Erampointer
                      If Erampointer > &HFFF Then
                         Exit For
                      End If
                   Else
                      Exit For
                   End If
               Next
            End If
'=======================================================================
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


         Case "DIR"                                         ' Directory
           If Gbcnttoken = 1 Then
               Gstoken = "*.*"
               Directory Gstoken
           Elseif Gbcnttoken = 2 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)
               Directory Gstoken
           Else
              Printparametercounterror "0 or 1 "
           End If

    '     Case "DIRT"                                       ' Directory
    '      If Gbcnttoken = 1 Then
    '          Gstoken = "*.*"
    '          Lword1 = 7
    '          Directory1 Gstoken , Lword1
    '      Elseif Gbcnttoken = 3 Then
    '          Gstoken = Getnexttokenstr(12)
    '          Gstoken = Trim(gstoken)
    '          Llong1 = Getnexttokenlong(0 , 1000)
    '          Lword1 = Llong1
    '          Directory1 Gstoken , Lword1
    '      Else
    '         Printparametercounterror "0 or 1 "
    '      End If

          Case "DIR$"                                       ' Directory
           If Gbcnttoken = 1 Then
               Gstestline = Dir()
               Print Gstestline
               Printdoserror
           Elseif Gbcnttoken = 2 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)
               Gstestline = Dir(gstoken)
               Print Gstestline
               Printdoserror
           Else
              Printparametercounterror "0 or 1 "
           End If

         Case "FILEDATETIMEB"
           If Gbcnttoken = 1 Then
               Bsec = Filedatetime()
               If Gbdoserror = 0 Then
                  Print Byear ; " " ; Bmonth ; " " ; Bday ; " " ; Bhour ; " " ; Bmin ; " " ; Bsec
               Else
                  Printdoserror
               End If
           Elseif Gbcnttoken = 2 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)
               Bsec = Filedatetime(gstoken)
               If Gbdoserror = 0 Then
                  Print Byear ; " " ; Bmonth ; " " ; Bday ; " " ; Bhour ; " " ; Bmin ; " " ; Bsec
               Else
                  Printdoserror
               End If
           Else
              Printparametercounterror "0 or 1 "
           End If

         Case "FILEDATETIMES"
           If Gbcnttoken = 1 Then
               Gstestline = Filedatetime()
               Print Gstestline
               Printdoserror
           Elseif Gbcnttoken = 2 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)
               Gstestline = Filedatetime(gstoken)
               Print Gstestline
               Printdoserror
           Else
              Printparametercounterror "0 or 1 "
           End If

         Case "FILELEN"
           If Gbcnttoken = 1 Then
               Llong1 = Filelen()
               Print Llong1
               Printdoserror
           Elseif Gbcnttoken = 2 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)
               Llong1 = Filelen(gstoken)
               Print Llong1
               Printdoserror
           Else
              Printparametercounterror "0 or 1 "
           End If


         Case "GETATTR"
           If Gbcnttoken = 1 Then
'               lByte1 = GetAttr()
               Print Bin(lbyte1)
               Printdoserror
           Elseif Gbcnttoken = 2 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)
               Lbyte1 = Getattr(gstoken)
               Print Bin(lbyte1)
               Printdoserror
           Else
              Printparametercounterror "0 or 1 "
           End If

         Case "TYPE"                                        ' Type ASCII-file (sector by sector)
           If Gbcnttoken = 2 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)
               'Lbyte1 = Printfile(gstoken)
               Typewildcard Gstoken
               'Printdoserror
           Else
              Printparametercounterror "1 "
           End If

        Case "DUMP"                                         ' Dump file
           If Gbcnttoken = 2 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)
               Lbyte1 = Dumpfile(gstoken)
               Printdoserror
           Else
              Printparametercounterror "1 "
           End If


         Case "FOO"                                         ' File open for Output
            If Gbcnttoken > 1 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)
               If Gbcnttoken > 2 Then
                  Llong1 = Getnexttokenlong(1 , 255)
                  Lbyte2 = Llong1
                  Open Gstoken For Output As #lbyte2
               Else
                  Lbyte2 = Freefile()
                  Open Gstoken For Output As #lbyte2
               End If
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print "File# = " ; Lbyte2
               End If
           Else
              Printparametercounterror "1 "
           End If

         Case "FOI"                                         ' File open for Input
            If Gbcnttoken > 1 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)
               If Gbcnttoken > 2 Then
                  Llong1 = Getnexttokenlong(1 , 255)
                  Lbyte2 = Llong1
                  Open Gstoken For Input As #lbyte2
               Else
                  Lbyte2 = Freefile()
                  Open Gstoken For Input As #lbyte2
               End If
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print "File# = " ; Lbyte2
               End If
           Else
              Printparametercounterror "1 "
           End If


        Case "FOB"                                          ' File open for Binary
            If Gbcnttoken > 1 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)
               If Gbcnttoken > 2 Then
                  Llong1 = Getnexttokenlong(1 , 255)
                  Lbyte2 = Llong1
                  Open Gstoken For Binary As #lbyte2
               Else
                  Lbyte2 = Freefile()
                  Open Gstoken For Binary As #lbyte2
               End If
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print "File# = " ; Lbyte2
               End If
           Else
              Printparametercounterror "1 "
           End If

        Case "FOA"                                          ' File open for Append
            If Gbcnttoken > 1 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)
               If Gbcnttoken > 2 Then
                  Llong1 = Getnexttokenlong(1 , 255)
                  Lbyte2 = Llong1
                  Open Gstoken For Append As #lbyte2
               Else
                  Lbyte2 = Freefile()
                  Open Gstoken For Append As #lbyte2
               End If
               If Gbdoserror = 0 Then
                  Print "File# = " ; Lbyte2
               Else
                  Printdoserror
               End If
            Else
              Printparametercounterror "1 "
            End If

       Case "RL"                                            ' File line input
            If Gbcnttoken = 2 Then
               Llong1 = Getnexttokenlong(1 , 255)           ' file#
               Lbyte1 = Llong1
               If Gbpcinputerror = Cpno Then
                  Line Input #lbyte1 , Gstestline
                  If Gbdoserror <> 0 Then
                     Printdoserror
                  Else
                     Print Gstestline
                  End If
                End If
            Else
               Printparametercounterror "1 "
            End If

        Case "LOC"                                          ' File Location last read/write
             If Gbcnttoken = 2 Then
                Llong1 = Getnexttokenlong(1 , 255)
                If Gbpcinputerror = Cpno Then
                   Lbyte1 = Llong1
                   Llong2 = Loc(#lbyte1)
                   If Gbdoserror = 0 Then
                      Print Llong2
                   Else
                      Printdoserror
                   End If
                End If
             End If

        Case "LOF"                                          ' File Length
             If Gbcnttoken = 2 Then
                Llong1 = Getnexttokenlong(1 , 255)
                If Gbpcinputerror = Cpno Then
                   Lbyte1 = Llong1
                   Llong2 = Lof(#lbyte1)
                   If Gbdoserror = 0 Then
                      Print Llong2
                   Else
                       Printdoserror
                   End If
                End If
             Else
                Printparametercounterror "1 "
             End If

        Case "SEEK"                                         ' next byte position to read/write in file
             If Gbcnttoken = 2 Then
                Llong1 = Getnexttokenlong(1 , 255)
                If Gbpcinputerror = Cpno Then
                   Lbyte1 = Llong1
                   Llong2 = Seek(#lbyte1)
                   If Gbdoserror = 0 Then
                      Print Llong2
                   Else
                       Printdoserror
                   End If
                End If
             Elseif Gbcnttoken = 3 Then
                Llong1 = Getnexttokenlong(1 , 255)
                Llong2 = Getnexttokenlong(1 , 2000000000)
                If Gbpcinputerror = Cpno Then
                   Lbyte1 = Llong1
                   Seek #lbyte1 , Llong2
                   Printdoserror
                End If
             Else
                Printparametercounterror "1 or 2 "
             End If

         Case "DEL"                                         ' delete file
            If Gbcnttoken = 1 Then
               Gstoken = "*.*"
               Delete Gstoken
           Elseif Gbcnttoken = 2 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)
               Delete Gstoken
           Else
              Printparametercounterror "0 or 1 "
           End If

         Case "WL"                                          ' Write line to file
            If Gbcnttoken = 3 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               Gstoken = Getnexttokenstr(70)
               Gstestline = Ltrim(gstoken) : Print #lbyte1 , Gstestline
               Printdoserror
            Else
               Printparametercounterror "1 "
            End If

         Case "WLM"                                         ' write multiple lines to file
            If Gbcnttoken = 5 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Llong2 = Getnexttokenlong(1 , 100000)
               Llong3 = Getnexttokenlong(1 , 1000000)
               Lbyte1 = Llong1
               Gstoken = Getnexttokenstr(70) : Gstoken = Ltrim(gstoken)
               If Gbpcinputerror = Cpno Then
                  For Llong4 = Llong2 To Llong3
                     Gstestline = Gstoken + " "
                     Gstestline = Gstoken + Str(llong4)

                    Print #lbyte1 , Gstestline
                    If Gbdoserror <> 0 Then
                       Printdoserror
                       Exit For
                    End If
                  Next
               End If
            Else
               Printparametercounterror "4 "
            End If

         Case "CLOSE"                                       ' Close file
            If Gbcnttoken = 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               Close #lbyte1
               Printdoserror
            Else
               Printparametercounterror "1 "
            End If

         Case "FLUSH"                                       ' flush file
            Lbyte2 = 0
            If Gbcnttoken = 1 Then
               Flush
            Elseif Gbcnttoken = 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               Flush #lbyte1

            Else
               Printparametercounterror "0 or 1 "
            End If
            Printdoserror

         Case "BSAVE"                                       ' save SRAM to file
            If Gbcnttoken = 4 Then
                Gstoken = Getnexttokenstr(12)               ' Filename
                Llong1 = Getnexttokenlong(0 , &HFFFF)       ' Start
                Llong2 = Getnexttokenlong(1 , &HFFFF)       ' Length
                Lword1 = Llong1 : Lword2 = Llong2
                If Gbpcinputerror = Cpno Then
                    Bsave Gstoken , Lword1 , Lword2
                    Printdoserror
                End If
             Else
               Printparametercounterror "3 "
            End If

        Case "BLOAD"                                        ' load SRAM with file content
            If Gbcnttoken = 3 Then
                Gstoken = Getnexttokenstr(12)               ' Filename
                Llong1 = Getnexttokenlong(0 , &HFFFF)       ' Start
                Lword1 = Llong1
                If Gbpcinputerror = Cpno Then
                    Llong2 = Varptr(gbdoserror)
                    Llong2 = Llong2 + C_filesystemsramsize
                    If Llong2 > Llong1 Then
                        Print "Command rejected, because it overwrites AVR-DOS in SRAM"
                    Else
                        Bload Gstoken , Lword1
                    End If
                    Printdoserror
                End If
             Else
               Printparametercounterror "2 "
            End If

        Case "FILEATTR"                                     ' File open mode
            If Gbcnttoken = 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               Lbyte2 = Fileattr(lbyte1)
               If Lbyte2 <> 0 Then
                  Print Lbyte2
               Else
                  Printdoserror
               End If
            Else
               Printparametercounterror "1 "
            End If

        Case "FREEFILE"                                     ' File open mode
            If Gbcnttoken = 1 Then
               Lbyte2 = Freefile()
               If Lbyte2 <> 0 Then
                  Print Lbyte2
               Else
                  Printdoserror
               End If
            Else
               Printparametercounterror "no "
            End If

        Case "EOF"                                          ' File open mode
            If Gbcnttoken = 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               Lbyte2 = Eof(#lbyte1)
               If Gbdoserror = 0 Then
                  Print Lbyte2
               Else
                  Printdoserror
               End If
            Else
               Printparametercounterror "1 "
            End If


         Case "PUTL"
            If Gbcnttoken > 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Llong2 = Getnexttokenlong( -10000000 , 10000000)
               Lbyte1 = Llong1
               If Gbcnttoken > 3 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Put #lbyte1 , Llong2 , Llong3
               Else
                  Put #lbyte1 , Llong2
               End If
               Printdoserror
            Else
               Printparametercounterror "2 or 3 "
            End If

         Case "GETL"
            If Gbcnttoken > 1 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               If Gbcnttoken > 2 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Get #lbyte1 , Llong2 , Llong3
               Else
                  Get #lbyte1 , Llong2
               End If
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print Llong2
               End If
            Else
               Printparametercounterror "1 or 2 "
            End If


         Case "PUTB"
            If Gbcnttoken > 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Llong2 = Getnexttokenlong(0 , 255)
               Lbyte1 = Llong1
               Lbyte3 = Llong2
               If Gbcnttoken > 3 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Put #lbyte1 , Lbyte3 , Llong3
               Else
                  Put #lbyte1 , Lbyte3
               End If
               Printdoserror
            Else
               Printparametercounterror "2 or 3 "
            End If

         Case "GETB"
            If Gbcnttoken > 1 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               If Gbcnttoken > 2 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Get #lbyte1 , Lbyte3 , Llong3
               Else
                  Get #lbyte1 , Lbyte3
               End If
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print Lbyte3
               End If
            Else
               Printparametercounterror "1 or 2 "
            End If

         Case "PUTI"
            If Gbcnttoken > 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Llong2 = Getnexttokenlong( -32767 , 32767)
               Lbyte1 = Llong1
               Lint1 = Llong2
               If Gbcnttoken > 3 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Put #lbyte1 , Lint1 , Llong3
               Else
                  Put #lbyte1 , Lint1
               End If
               Printdoserror
            Else
               Printparametercounterror "2 or 3 "
            End If

         Case "PUTW"
            If Gbcnttoken > 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Llong2 = Getnexttokenlong(0 , 65635)
               Lbyte1 = Llong1
               Lword1 = Llong2
               If Gbcnttoken > 3 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Put #lbyte1 , Lword1 , Llong3
               Else
                  Put #lbyte1 , Lword1
               End If
               Printdoserror
            Else
               Printparametercounterror "2 or 3 "
            End If

         Case "GETI"
            If Gbcnttoken > 1 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               If Gbcnttoken > 2 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Get #lbyte1 , Lint1 , Llong3
               Else
                  Get #lbyte1 , Lint1
               End If
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print Lint1
               End If
            Else
               Printparametercounterror "1 or 2 "
            End If

         Case "GETW"
            If Gbcnttoken > 1 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               If Gbcnttoken > 2 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Get #lbyte1 , Lword1 , Llong3
               Else
                  Get #lbyte1 , Lword1
               End If
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print Lword1
               End If
            Else
               Printparametercounterror "1 or 2 "
            End If

         Case "PUTS"
            If Gbcnttoken > 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Gstoken = Getnexttokenstr(70) : Gstoken = Trim(gstoken) : Lsingle1 = Val(gstoken)
               Lbyte1 = Llong1
               If Gbcnttoken > 3 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Put #lbyte1 , Lsingle1 , Llong3
               Else
                  Put #lbyte1 , Lsingle1
               End If
               Printdoserror
            Else
               Printparametercounterror "2 or 3 "
            End If

         Case "GETS"
            If Gbcnttoken > 1 Then

               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               If Gbcnttoken > 2 Then
                  Llong3 = Getnexttokenlong(1 , 10000000)
                  Get #lbyte1 , Lsingle1 , Llong3
               Else
                  Get #lbyte1 , Lsingle1
               End If
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print Lsingle1
               End If
            Else
               Printparametercounterror "1 or 2 "
            End If

         Case "PUTT"
            If Gbcnttoken > 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Gstoken = Getnexttokenstr(70) : Gstoken = Trim(gstoken)
               Lbyte1 = Llong1
               If Gbcnttoken > 3 Then
                  Llong3 = Getnexttokenlong(1 , 100000000)
                  Llong4 = Getnexttokenlong(1 , 255)
                  Put #lbyte1 , Gstoken , Llong3 , Llong4
               Else
                  Put #lbyte1 , Gstoken
               End If
               Printdoserror
            Else
               Printparametercounterror "2 or 3 "
            End If

         Case "GETT"
            If Gbcnttoken > 1 Then
               Gstoken = ""
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               If Gbcnttoken > 2 Then
                  Llong3 = Getnexttokenlong(1 , 100000000)
                  Llong4 = Getnexttokenlong(1 , 255)
                  Get #lbyte1 , Gstoken , Llong3 , Llong4
               Else
                  Get #lbyte1 , Gstoken
               End If
               If Gbdoserror <> 0 Then
                  Printdoserror
               Else
                  Print Gstoken
               End If
            Else
               Printparametercounterror "1 or 2 "
            End If

  '       Case "TIME"
   '         If Gbcnttoken = 1 Then
    '           Print Time$
     '       Elseif Gbcnttoken = 2 Then
      '         Time$ = Getnexttokenstr(8)
       '     Else
        '       Printparametercounterror "0 or 1"
         '   End If

'         Case "DATE"
 '
  '          If Gbcnttoken = 1 Then
   '            Print Date$
    '        Elseif Gbcnttoken = 2 Then
     '          Date$ = Getnexttokenstr(8)
      '      End If

         Case "DISKFREE"
            If Gbcnttoken = 1 Then
               Llong1 = Diskfree()
               Print Llong1
            End If

         Case "DISKSIZE"
            Llong1 = Disksize()
            Print Llong1

         Case "FILEINFO"
            If Gbcnttoken = 2 Then
                Llong1 = Getnexttokenlong(1 , 255)
                Lbyte1 = Llong1
                If Gbpcinputerror = Cpno Then
                  Printfileinfo Lbyte1
                End If
            Else
               Printparametercounterror "1"
            End If

         Case "DIRINFO"

            Printdirinfo

         Case "FATINFO"

            Printfatinfo

         Case "FSINFO"
            Printfilesysteminfo

         Case "ERROR"
            Printdoserror
            Print "Error printed"

         Case "RESET"

            Goto 0

         Case "FIND"                                        ' find line in file, which starts with specified text
                                                    '
            If Gbcnttoken = 2 Then
               Llong1 = Getnexttokenlong(1 , 255)
               Lbyte1 = Llong1
               Lbyte2 = 0
               Lbyte3 = Eof(#lbyte1)
               If Lbyte3 = 0 Then
                  Do
                     Llong1 = Seek(#lbyte1)
                     Line Input #lbyte1 , Gstestline

                     If Mid(gstestline , 1 , 1) = " " Then
                        Lbyte2 = 1
                        Seek #lbyte1 , Llong1
                        Exit Do
                     End If
                  Loop Until Eof(#lbyte1) <> 0
               End If
               If Lbyte2 = 1 Then
                  Print "Found at position " ; Llong1
               Else
                  Print "not found"
               End If
               Printdoserror
            Else
               Printparametercounterror "1 "
            End If

        Case "MKDIR"                                        ' File open for Output

            If Gbcnttoken > 1 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)

               Mkdir Gstoken


               If Gbdoserror <> 0 Then
                  Printdoserror
               End If
           Else
              Printparametercounterror "1 "
           End If

        Case "CHDIR"                                        ' File open for Output

            If Gbcnttoken > 1 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)

               Chdir Gstoken

               If Gbdoserror <> 0 Then
                  Printdoserror
               End If
           Else
              Printparametercounterror "1 "
           End If


       Case "RMDIR"                                         ' File open for Output

            If Gbcnttoken > 1 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)

               Rmdir Gstoken

               If Gbdoserror <> 0 Then
                  Printdoserror
               End If
           Else
              Printparametercounterror "1 "
           End If


       Case "NAME"                                          ' File open for Output

            If Gbcnttoken > 2 Then
               Gstoken = Getnexttokenstr(12)
               Gstoken = Trim(gstoken)
               Gstestline = Getnexttokenstr(12)
               Gstestline = Trim(gstestline)

               Name Gstoken As Gstestline

               If Gbdoserror <> 0 Then
                  Printdoserror
               End If
           Else
              Printparametercounterror "1 "
           End If


         Case Else

            Print "Command '" ; Gspcinput ; "' not recognized"

      End Select

      If Transferbuffer_write > 511 Then
         Transferbuffer_write = 0
      End If

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
         Print "    " ;
'         Print Spc(lbPos) ; ' bug in 1.11.7.4 using SPC() in SW-Uart
         Gstestline = Space(lbpos) : Print Gstestline ;
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


Sub Printprompt()
    Print
    Print Hex(transferbuffer_write) ; ">" ;
End Sub


Function Getlongfrombuffer(pbsramarray As Byte , Byval Pbpos As Word) As Long
   ' Extract a Long-Value from a Byte-Array
   ' pbSRAMArray: Byte-array, from which the Long-value should be extracted
   ' pbPos: Position, at which the Long-Value starts (0-based)
   Loadadr Pbsramarray , Z
   Loadadr Pbpos , X
   ld r24, x+
   ld r25, x+
   add zl, r24
   adc zh, r25
   Loadadr Getlongfrombuffer , X
   !Call _ZXMem4_copy
End Function


Function Getwordfrombuffer(pbsramarray As Byte , Byval Pbpos As Word) As Word
   ' Extract a Word-value from a Byte-Array
   ' pbSRAMArray: Byte-array, from which the Word-value should be extracted
   ' pbPos: Position, at which the Word-Value starts (0-based)
   Loadadr Pbsramarray , Z
   Loadadr Pbpos , X
   ld r24, x+
   ld r25, x+
   add zl, r24
   adc zh, r25
   Loadadr Getwordfrombuffer , X
   ldi r24, 2
   !Call _ZXMem_copy
End Function


Sub Sramdump(pwsrampointer As Word , Byval Pwlength As Word , Plbase As Long)
    ' Dump a Part of SRAM to Print-Output #1
    ' pwSRAMPointer: (Word) Variable which holds the address of SRAM to dump
    ' pwLength: (Word) Count of Bytes to be dumped (1-based)
    Local Lsdump As String * 16
    Local Lbyte1 As Byte , Lbyte2 As Byte
    Local Lword1 As Word , Lword2 As Word
    Local Llong1 As Long

    If Pwlength > 0 Then
      Decr Pwlength
      For Lword1 = 0 To Pwlength
         Lword2 = Lword1 Mod 8
         If Lword2 = 0 Then
            If Lword1 > 0 Then
               Print " " ;
            End If
         End If
         Lword2 = Lword1 Mod 16
         If Lword2 = 0 Then
            If Lword1 > 0 Then
               Print "  " ; Lsdump
            End If
            Llong1 = Plbase + Lword1
            Print Hex(llong1) ; "  " ;
            Lsdump = "                "
            Lbyte2 = 1
         End If
         Lbyte1 = Inp(pwsrampointer)
         Incr Pwsrampointer
         Print Hex(lbyte1) ; " " ;
         If Lbyte1 > 31 Then
            Mid(lsdump , Lbyte2 , 1) = Lbyte1
         Else
             Mid(lsdump , Lbyte2 , 1) = "."
         End If
         Incr Lbyte2
      Next
      Print "   " ; Lsdump
    End If
    Incr Pwlength
    Plbase = Plbase + Pwlength
End Sub

Sub Eramdump(pwerampointer As Word , Byval Pwlength As Word)
    ' Dump a Part of ERAM to Print-Output #1
    ' pwERAMPointer: (Word) Variable which holds the address of ERAM to dump
    ' pwLength: (Word) Count of Bytes to be dumped (1-based)
    Local Lsdump As String * 16
    Local Lbyte1 As Byte , Lbyte2 As Byte
    Local Lword1 As Word , Lword2 As Word

    If Pwlength > 0 Then
      Decr Pwlength
      For Lword1 = 0 To Pwlength
         Lword2 = Lword1 Mod 8
         If Lword2 = 0 Then
            If Lword1 > 0 Then
               Print " " ;
            End If
         End If
         Lword2 = Lword1 Mod 16
         If Lword2 = 0 Then
            If Lword1 > 0 Then
               Print "  " ; Lsdump
            End If
            Print Hex(lword1) ; "  " ;
            Lsdump = "                "
            Lbyte2 = 1
         End If
         Readeeprom Lbyte1 , Pwerampointer
         Incr Pwerampointer
         Print Hex(lbyte1) ; " " ;
         If Lbyte1 > 31 Then
            Mid(lsdump , Lbyte2 , 1) = Lbyte1
         Else
             Mid(lsdump , Lbyte2 , 1) = "."
         End If
         Incr Lbyte2
      Next
      Print "   " ; Lsdump
    End If
End Sub



' -----------------------------------------------------------------------------
' copy Memory from (Z) nach (X)
' counts of bytes in r24
_zxmem4_copy:
   ldi r24, 4
_zxmem_copy:
   ld r25, z+
   st x+, r25
   dec r24
   brne _ZXMem_copy
   ret




' Declaration of Functions

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



'Declare Sub Directory(pStr1 as String)
' Read and print Directory, Filename, Date, Time, Size
' Input Filename in form "name.ext"
Sub Directory(pstr1 As String)
   Local Lfilename As String * 12                           ' hold file name for print
   Local Lwcounter As Word , Lfilesizesum As Long           ' for summary
   Local Lbyte1 As Byte , Llong1 As Long
   Lwcounter = 0 : Lfilesizesum = 0
   Lfilename = Dir(pstr1)
   While Lfilename <> ""
      Print Lfilename;
      Lbyte1 = 14 - Len(lfilename)
      'Print spc(lByte1); Bug in 1.11.7.4  on soft-uart
      Gstestline = Space(lbyte1) : Print Gstestline ;

      Llong1 = Filelen()
      Print Filedate() ; " " ; Filetime() ; " " ;
'      lByte1 = getAttr()
      If Lbyte1.4 = 1 Then
         Print "Dir"
      Else
         Print Llong1
      End If
      Incr Lwcounter : Lfilesizesum = Lfilesizesum + Llong1
      Lfilename = Dir()
   Wend
   Print Lwcounter ; " File(s) found with " ; Lfilesizesum ; " Byte(s)"
End Sub


Sub Delete(pstr1 As String)
   Local Lfilename As String * 12 , Lbyte1 As Byte          ' hold file name for print
   Lfilename = Dir(pstr1)
   While Lfilename <> ""
'      lByte1 = GetAttr()
      If Lbyte1.4 = 0 Then
         Print "Delete File: " ; Lfilename
         Kill Lfilename
      End If
      Lfilename = Dir()
   Wend
End Sub




Sub Typewildcard(pstr1 As String)
   Local Lfilename As String * 12                           ' hold file name for print
   Local Lbyte1 As Byte , Lbyte2 As Byte
   Lbyte2 = 0
   Lfilename = Dir(pstr1)
   If Lfilename = "" Then
      Print "No File found for " ; Pstr1
      Exit Sub
   End If
   While Lfilename <> ""
      Print "File " ; Lfilename ; " is printed ..."
      Lbyte1 = Printfile(lfilename)
      Print " "
      Lfilename = Dir()
      Incr Lbyte2
   Wend
   Print Lbyte2 ; " Files printed"
End Sub




'Declare Sub Directory1(pStr1 as String , pDays as Word)

' Read and print Directory and show Filename, Date, Time, Size
' for all files matching pStr1 and create/update younger than pDays
'Sub Directory1(pstr1 As String , Pdays As Word)
'   Local Lfilename As String * 12                           ' hold file name for print
'   Local Lwcounter As Word , Lfilesizesum As Long           ' for summary
'   Local Lwnow As Word , Lwdays As Word
'   Local Lsec As Byte , Lmin As Byte , Lhour As Byte , Lday As Byte , Lmonth As Byte , Lyear As Byte
'   Print "Listing of all Files matching " ; Pstr1 ; " and  create/last update date within " ; Pdays ; " days"
'   Lwnow = Sysday()
'   Lwcounter = 0 : Lfilesizesum = 0
'   Lfilename = Dir(pstr1)
'   While Lfilename <> ""
'      Lsec = Filedatetime()
'      Lwdays = Lwnow - Sysday(lday)                         ' Days between Now and last File Update
'      If Lwdays <= Pdays Then                               ' days smaller than desired with parameter
'         Print Lfilename ; Filedate() ; " " ; Filetime() ; " " ; Filelen()
'         Incr Lwcounter : Lfilesizesum = Filelen() + Lfilesizesum
'      End If
'      Lfilename = Dir()
'   Wend
'   Print Lwcounter ; " File(s) found with " ; Lfilesizesum ; " Byte(s)"
'End Sub



'Declare Function PrintFile(psName as String) as Byte
' Print File Sector by Sector
Function Printfile(psname As String) As Byte
$external _getfreefilenumber , _normfilename , _openfile , _loadfilebufferstatusyz , _addrfilebuffer2x
$external _loadnextfilesector , _closefilehandle , _cleardoserror
Local Lstr1 As String * 1 , Lstr2 As String * 1
   !call _GetFreeFileNumber                                 ' to get free file# in r24
   brcs _PrintFileEnd                                       ' Error?; if C-set
   push r24                                                 ' File#
   Loadadr Psname , X
   !call _NormFileName                                      ' Result: Z-> Normalized name
   pop r24                                                  ' File#
   ldi r25, cpFileOpenInput                                 ' Read only and archive-bit allowed
   !call _OpenFile                                          ' Search file, set File-handle and load first sector
   brcs _PrintFileEnd                                       ' Error?; if C-set
   sbiw yl, 2                                               ' If Openfile OK! then (Y-2), (Y-1) -> Filehandle
_printfile2:
   !call  _LoadFileBufferStatusYZ                           ' Someting to read?
   sbrc r24, dEOF                                           ' End of File?
   rjmp _PrintFile3
   !call _addrFileBuffer2X                                  ' put String (sector) start now in X
'   !call _SendString0                   ' X at sector-buffer basis
' trick to fool Print #1 to print 512 long string
   st Y+2, xl
   st Y+3, xh
   Print Lstr1 ;                                            ' Address pointer is shifted one position
                                         ' because of using Y-pointer for AVR-DOS

   !call _LoadNextFileSector_Position
   brcc _PrintFile2                                         ' Loop to print next sector; irregular Error if C-set
_printfile3:
   !call _CloseFileHandle_Y
   adiw yl, 2                                               ' Restore Y
   !call _ClearDOSError
_printfileend:
   Loadadr Printfile , X
   st X, r25                                                ' give Error code back

End Function


'Declare Function DumpFile(psName as String) as Byte

Function Dumpfile(psname As String) As Byte
   Gldumpbase = 0
   !call _GetFreeFileNumber                                 ' to get free file# in r24
   brcs _DumpFileEnd                                        ' Error?; if C-set
   push r24                                                 ' File#
   Loadadr Psname , X
   !call _NormFileName                                      ' Result: Z-> Normalized name
   pop r24                                                  ' File#
   ldi r25, cpFileOpenInput                                 ' Read only and archive-bit allowed
   !call _OpenFile                                          ' Search file, set File-handle and load first sector
   brcs _DumpFileEnd                                        ' Error?; if C-set
   sbiw yl, 2                                               ' If Openfile OK! then (Y-2), (Y-1) -> Filehandle
_dumpfile2:
   !call  _LoadFileBufferStatusYZ                           ' Someting to read?
   sbrc r24, dEOF                                           ' End of File?
   rjmp _DumpFile3
   !call _addrFileBuffer2X
   Loadadr Gword1 , Z
   st Z+, xl
   st Z+, xh
   Sramdump Gword1 , 512 , Gldumpbase
   !call _LoadNextFileSector_Position
   brcc _DumpFile2                                          ' Loop to Dump next sector; irregular Error if C-set
_dumpfile3:
   !call _CloseFileHandle_Y
   adiw yl, 2                                               ' Restore Y
   !call _ClearDOSError
_dumpfileend:
   Loadadr Dumpfile , X
   st X, r25                                                ' give Error code back
End Function







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

Sub Printdirinfo()
   Local Lwtemp1 As Word , Lltemp1 As Long
    Print "Dir first Sector#: " ; Gldirfirstsectornumber
    Print "Free Dir Entry#:   " ; Gwfreedirentry
    Print "Free Dir Sector#   " ; Glfreedirsectornumber
    Print "Dir0 File name     " ; Gsdir0tempfilename
    Print "Dir0 Entry         " ; Gwdir0entry
    Print "Dir0 Sector#       " ; Gldir0sectornumber
    Print "File Name          " ; Gstempfilename
    Print "Dir Entry#         " ; Gwdirentry
    Print "Dir Sector#        " ; Gldirsectornumber
    Print "Dir buffer status  " ; Bin(gbdirbufferstatus)
    Lltemp1 = 0
    Lwtemp1 = Varptr(gbdirbuffer(1))
    Sramdump Lwtemp1 , 512 , Lltemp1
End Sub

Sub Printfatinfo()
   Local Lwtemp1 As Word , Lltemp1 As Long
#if Csepfathandle = 1
   Print "FAT Sector#        " ; Glfatsectornumber
   Print "FAT buffer status  " ; Bin(gbfatbufferstatus)
   Lwtemp1 = Varptr(gbfatbuffer(1))
   Lltemp1 = 0
   Sramdump Lwtemp1 , 512 , Lltemp1
#else
    Print "Directory and FAT handled with on buffer"
    Print "Dir Entry#         " ; Gwdirentry
    Print "Dir Sector#        " ; Gldirsectornumber
    Print "Dir buffer status  " ; Bin(gbdirbufferstatus)
    Lltemp1 = 0
    Lwtemp1 = Varptr(gbdirbuffer(1))
    Sramdump Lwtemp1 , 512 , Lltemp1
#endif


End Sub


Sub Printfileinfo(pbfilenr As Byte)
  Local Lltemp1 As Long
  Local Lbfilenumber As Byte
  Local Lbfilemode As Byte
  Local Lwfiledirentry As Word
  Local Llfiledirsectornumber As Long
  Local Llfilefirstcluster As Long
  Local Llfilesize As Long
  Local Llfileposition As Long
  Local Llfilesectornumber As Long
  Local Lbfilebufferstatus As Byte
  Local Lwfilebufferaddress As Word
  Loadadr Pbfilenr , X
  ld r24, X
  !Call _GetFileHandle
  brcc PrintFileInfo1
  rjmp PrintFileInfoError
Printfileinfo1:
   Loadadr Lbfilenumber , X
   ldi r24, 25
   !Call _Mem_Copy
   Loadadr Lwfilebufferaddress , X
   st X+, zl
   st X+, zh
   Print "Handle#:        " ; Lbfilenumber
   Print "Open mode:      " ; Bin(lbfilemode)
   Print "Dir Entry#:     " ; Lwfiledirentry
   Print "Dir Sector#:    " ; Llfiledirsectornumber
   Print "First Cluster#: " ; Llfilefirstcluster
   Print "Size:           " ; Llfilesize
   Print "Position:       " ; Llfileposition
   Print "Sector#:        " ; Llfilesectornumber
   Print "Buffer Status:  " ; Bin(lbfilebufferstatus)
   Lltemp1 = 0
   Sramdump Lwfilebufferaddress , 512 , Lltemp1
   Exit Sub
Printfileinfoerror:
   Print "No Filehandle for " ; Pbfilenr ; " found"
End Sub