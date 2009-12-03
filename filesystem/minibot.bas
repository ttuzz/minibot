'**********MINIBOT CONFIGS**********
'фусибиты
$prog &HFF , &HE4 , &HD9 , &H00

'камень
$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 9600
Config Serialin = Buffered , Size = 20

'делаю супермегабиг+ стек
$hwstack = 128
$swstack = 128
$framesize = 128

'библиотеки AVR-DOS и SD
$include "Config_MMC.bas"
$include "Config_AVR-DOS.BAS"

      Waitms 500
      Print "MiniBot v.2 is configured"
      Enable Interrupts
'///**********MINIBOT CONFIGS**********


'**********INTERPRETER VARS**********
'interpreter configs
Const Cpno = 0
Const Cpyes = 1
Const Cptoken_max = 6                                       ' Count of Tokens in USER-Input
Const Cpstrsep = ","                                        ' Blank: Separator between tokens
Const Cpcinput_len = 25                                     ' max. length of user-Input
Const Ctoken_len = 20                                       'max. length of token


Dim Gstoken As String * Ctoken_len                          ' holds current token
Dim Gspcinput As String * Cpcinput_len                      ' holds user-input
Dim Gbposstrparts(cptoken_max) As Byte                      ' for analysing user-input
Dim Gblenstrparts(cptoken_max) As Byte                      '
Dim Gbcnttoken As Byte                                      ' found tokens in user-input
Dim Gbtoken_actual As Byte                                  ' actual handled token of user-input
Dim Gbpcinputerror As Byte                                  ' holds error-code during analysing user-input
Dim Gstestline As String * 100

'interpreter subs
Declare Sub Avr_dos
Declare Sub Docommand()

Declare Sub Extracttoken()
Declare Function Getnexttokenstr(byval Pblen_max As Byte ) As String
Declare Function Getnexttokenlong(byval Plmin As Long , Byval Plmax As Long ) As Long

Declare Sub Printdoserror()
Declare Sub Printparametererrorl(plparamlow As Long , Plparamhigh As Long)
Declare Sub Printparametercounterror(byval Psparm_anzahl As String)

'Declare Sub Delete(pstr1 As String)

Declare Sub Printdriveerror()
Declare Sub Printfilesysteminfo()
Declare Sub Directory(pstr1 As String)

'my subs
Dim Gldumpbase As Long
Dim Gword1 As Word
Declare Sub Test_file(filename As String)
Declare Sub Print_file(filename As String)
Declare Sub Get_file(filename As String)
Declare Function Dumpfile(psname As String) As Byte
Declare Sub Sramdump(pwsrampointer As Word , Byval Pwlength As Word , Plbase As Long)
'///**********INTERPRETER VARS**********


'(СМОТРЕТЬ ЗДЕСЬ КОД И ДЕКОД ИЗ BASE64
СДЕЛАТЬ СЕГОДНЯ ПРОВЕРКУ
  - ВСЕ РАБОТАЕТ
Dim Buf As Byte

Do
   Waitms 6
   Clear Serialin
   Input ">" , Gspcinput
   Extracttoken                                             ' token analysing
   Gbtoken_actual = 0                                       ' reset to beginn of line (first token)
   Gbpcinputerror = Cpno
   Gstoken = Getnexttokenstr(ctoken_len)                    ' get first string-token = command
   Gstoken = Ucase(gstoken)

   Select Case Gstoken
      Case "ENC"
         Gstoken = Getnexttokenstr(ctoken_len)
         Gstoken = Trim(gstoken)
         Print "Encoding string"
         Print "'" ; Base64enc(gstoken) ; "'"
      Case "DEC"
         Gstoken = Getnexttokenstr(ctoken_len)
         'Gstoken = Trim(gstoken)
         Print "Decoding string '" ; Gstoken ; "'"
         Print "'" ; Base64dec(gstoken) ; "'"
   End Select
Loop
')

'Call Avr_dos
'End


Sub Avr_dos
Gspcinput = ""

Print "AVR-DOS: Ready for commands"
Do
   Print Chr(10) ; Chr(13) ;
   Print "> " ;

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

      Select Case Gstoken                                   ' File System apps
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

         Case "PRINT"                                       ' Directory
           If Gbcnttoken = 2 Then
            Gstoken = Getnexttokenstr(12)
            Gstoken = Trim(gstoken)
            Call Print_file(gstoken)
           Else
              Printparametercounterror "0 or 1 "
           End If

         Case "TEST"                                        ' Directory
           If Gbcnttoken = 2 Then
            Gstoken = Getnexttokenstr(12)
            Gstoken = Trim(gstoken)
            Print "Test file '" ; Gstoken ; "'"
            Gstoken = "test.wav"
            Call Test_file(gstoken)
           Else
              Printparametercounterror "0 or 1 "
           End If

         Case "DISKFREE"
            If Gbcnttoken = 1 Then
               Llong1 = Diskfree()
               Print Llong1
            End If

         Case "DISKSIZE"
            If Gbcnttoken = 1 Then
               Llong1 = Disksize()
               Print Llong1
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


       Case Else
            Print "Command '" ; Gspcinput ; "' not recognized"
      End Select

   End If
End Sub

Sub Test_file(filename As String)
   Local Bbuf As Byte
   Local I As Byte
   Const File1 = 14
   Open Filename For Binary As #file1
   I = 1
   Do
      Get #file1 , Bbuf
      Print Bbuf ; " " ;
      If I = 20 Then
         Print Chr(13) ; Chr(10);
         I = 1
      End If
      Incr I
   Loop Until Eof(#file1) <> 0
   Print "::"
End Sub


Function Dumpfile(psname As String) As Byte
$external _getfreefilenumber , _normfilename , _openfile , _loadfilebufferstatusyz , _addrfilebuffer2x
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

Sub Print_file(filename As String)
'Gspcinput = 20 bytes
   Const Max_len = 20                                       'максимальная длина ответа, исключая префикс и crc8
   Const Prefix = ":"
   Const Postfix = "::"                                     'символ(строка) конца передачи. важно, чтобы не использовались символы base64
   Local I As Byte
   Local Bbuf As Byte
   File Alias 14
   Sbuf Alias Gspcinput
   Open Filename For Binary As #file
   If Gbdoserror = 0 Then
      Sbuf = ""
      I = 1
      Do
         Get #file , Bbuf
         If I < Max_len Then
            Mid(sbuf , I , 1) = Bbuf
         Else                                               'данные (строка) готовы для отправки
            Print Prefix ; Base64enc(sbuf)                  'отправляется префикс+(при кодировании на каждыые 3байта добавляется ещё 1)+контрольная сумма(1байт)
            I = 1
            'Sbuf = ""
         End If
         Incr I
      Loop Until Eof(#file) <> 0
      If Sbuf <> "" Then                                    'если последний кусочек не отослали
         Print Prefix ; Base64enc(sbuf)
      End If
      Sbuf = ""
      Print Postfix                                         'передаю символ конца передачи
      Close #file
   Else
      Print "?81"
   End If
End Sub

Sub Get_file(filename As String)
'ВНИМАНИЕ, СИМВОЛ ПРИЕМА ДАННЫХ = ">"
'СИМВОЛ ТУПОЙ СТРОКИ = "?"
'А НАФИГА ВЕРИФИКАЦИЯ ВВОДА-ТО? МОЖНО И БЕЗ CRC8
'Gspcinput = 20 bytes
   'Const M_len = 20                                       'максимальная длина приема
   Const Redy = ">"
   Const Error = "?"
   'Const Postfix = "::"                                     'символ(строка) конца передачи. важно, чтобы не использовались символы base64
   Local I As Byte
   Local Bbuf As Byte
   Local Bbuf2 As Byte
   'File Alias 14
   'Sbuf Alias Gspcinput
   Close #file
   Open Filename For Binary As #file
   If Gbdoserror = 0 Then
         Print Redy ;
         Waitms 6
         Clear Serialin
         Input Sbuf Noecho
         Bbuf2 = Len(sbuf)
         Decr Bbuf2
         Bbuf = Right(sbuf , 1)                             'сохраняю чексумму и исключаю из строки
         Sbuf = Left(sbuf , Bbuf2)
         Sbuf = Base64dec(sbuf)                             'декод из base64
'(
   продолжаем торжество , нужно Sbuf перегнать в файл
')

   Else
      Print "?81"
   End If
End Sub

Sub Directory(pstr1 As String)
   Local Lfilename As String * 12                           ' hold file name for print
   Local Lwcounter As Word , Lfilesizesum As Long           ' for summary
   Local Lbyte1 As Byte , Llong1 As Long
   Lwcounter = 0 : Lfilesizesum = 0
   Lfilename = Dir(pstr1)
   While Lfilename <> ""
      Print ":" ; Lfilename;
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
   Print ":" ; Lwcounter ; " File(s) found with " ; Lfilesizesum ; " Byte(s)"
End Sub

'Sub Delete(pstr1 As String)
'   Local Lfilename As String * 12 , Lbyte1 As Byte          ' hold file name for print
'   Lfilename = Dir(pstr1)
'   While Lfilename <> ""
'      lByte1 = GetAttr()
'      If Lbyte1.4 = 0 Then
'         Print "Delete File: " ; Lfilename
'         Kill Lfilename
'      End If
'      Lfilename = Dir()
'   Wend
'End Sub


' standart function down here
'=====================================================
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



Sub Printdoserror()
   If Gbdoserror > 0 Then
      Print "DOS Error: " ; Gbdoserror
   End If
   If Gbdriveerror > 0 Then
      Printdriveerror
   End If
End Sub

Sub Printparametercounterror(byval Psparm_anzahl As String * 10)
   ' User message for wrong count of parameter
   Print "? " ; Psparm_anzahl ; " " ; "Parameter " ; "expected "
End Sub

Sub Printparametererrorl(plparamlow As Long , Plparamhigh As Long)
   ' Print Limits at wrong Input - value
   Print " [ " ; Plparamlow ; " ] - [ " ; Plparamhigh ; " ] " ; "expected "
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

Sub Printdriveerror()
   If Gbdriveerror > 0 Then
      Print "Drive Error: " ; Gbdriveerror
      Print "Drive Status:" ; Bin(gbdrivestatusreg)
      Print "Drive Debug: " ; Gbdrivedebug
   End If
End Sub


'       Case "FRECEIVE"
'           If Gbcnttoken = 3 Then
'               Gstoken = Getnexttokenstr(12)
''               Gstoken = Trim(gstoken)
'               Llong2 = Getnexttokenlong(1 , 2147483647)
'
'               Open Gstoken For Binary As #2
'
'               Print "ready"
'               Waitms 1
'               For Llong1 = 1 To Llong2
'                  Clear Serialin
'                  Input Gspcinput Noecho
'                  Print Chr(10) ; Chr(13) ;
'
'                  Put #2 , Gspcinput
'
'                  If Gbdoserror <> 0 Then
 '                    Printdoserror
'                     Close #2
'                     Exit For
'                  Else
'                     Print "ok"
'                     Waitms 1
'                  End If
'
'               'Exit For
'               Next
'
'               Close #2
'
'               Print "done"
'
'           Else
'              Printparametercounterror " 2 "
'           End If
'
'       Case "FTRANSMIT"
'           If Gbcnttoken = 2 Then
'               Gstoken = Getnexttokenstr(12)
'               Gstoken = Trim(gstoken)
''           End If