'----------------------------------------------------------------
'                          (c) 1995-2007, MCS
'                        Bootloader.bas
'  This sample demonstrates how you can write your own bootloader
'  in BASCOM BASIC
'  VERSION 2 of the BOOTLOADER. The waiting for the NAK is stretched
'  further a bug was resolved for the M64/M128 that have a big page size
'-----------------------------------------------------------------
'This sample will be extended to support other chips with bootloader
'The loader is supported from the IDE

$crystal = 7372800
$baud = 115200                                              'this loader uses serial com
'It is VERY IMPORTANT that the baud rate matches the one of the boot loader
'do not try to use buffered com as we can not use interrupts

$regfile = "m32def.dat"
Const Loaderchip = 32

#if Loaderchip = 32                                         ' Mega32
    $loader = $3c00                                         ' 1024 words
    Const Maxwordbit = 6                                    'Z6 is maximum bit                                   '
    Config Com1 = 115200 , Synchrone = 1 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
#endif


Const Maxword =(2 ^ Maxwordbit) * 2                         '128
Const Maxwordshift = Maxwordbit + 1
Const Cdebug = 0                                            ' leave this to 0

#if Cdebug
   Print Maxword
   Print Maxwordshift
#endif



'Dim the used variables
Dim Bstatus As Byte , Bretries As Byte , Bblock As Byte , Bblocklocal As Byte
Dim Bcsum1 As Byte , Bcsum2 As Byte , Buf(128) As Byte , Csum As Byte
Dim J As Byte , Spmcrval As Byte                            ' self program command byte value

Dim Z As Long                                               'this is the Z pointer word
Dim Vl As Byte , Vh As Byte                                 ' these bytes are used for the data values
Dim Wrd As Word , Page As Word                              'these vars contain the page and word address
Dim Bkind As Byte , Bstarted As Byte


Disable Interrupts                                          'we do not use ints


'Waitms 100                                                  'wait 100 msec sec
'We start with receiving a file. The PC must send this binary file

'some constants used in serial com
Const Nak = &H15
Const Ack = &H06
Const Can = &H18

'we use some leds as indication in this sample , you might want to remove it
Config Pinc.4 = Output : Led_r1 Alias Portc.4
Config Pinc.7 = Output : Led_g2 Alias Portc.7
Led_r1 = 1
$timeout = 400000
Wait 1                                                      'we use a timeout
Led_r1 = 0
'When you get LOADER errors during the upload, increase the timeout value
'for example at 16 Mhz, use 200000

Bretries = 5                                                'we try 5 times
Testfor123:
#if Cdebug
    Print "Try " ; Bretries
    Print "Wait"
#endif
Waitms 6                                                    'wait
Bstatus = Waitkey()                                         'wait for the loader to send a byte
#if Cdebug
   Print "Got "
#endif

Print Chr(bstatus);

If Bstatus = 123 Then                                       'did we received value 123 ?
   Bkind = 0                                                'normal flash loader
   Goto Loader
Elseif Bstatus = 124 Then                                   ' EEPROM
   Bkind = 1                                                ' EEPROM loader
   Goto Loader
Elseif Bstatus <> 0 Then
   Decr Bretries
   If Bretries <> 0 Then Goto Testfor123                    'we test again
End If

For J = 1 To 100                                            'this is a simple indication that we start the normal reset vector
   Toggle Led_r1 : Waitms 100
Next
Led_r1 = 0

#if Cdebug
  Print "RESET"
#endif
Goto _reset                                                 'goto the normal reset vector at address 0


'this is the loader routine. It is a Xmodem-checksum reception routine
Loader:

  For J = 1 To 100                                          'this is a simple indication that we start the normal reset vector
     Toggle Led_g2 : Waitms 100
  Next

  Goto _reset
Return

'How you need to use this program:
'1- compile this program
'2- program into chip with sample elctronics programmer
'3- select MCS Bootloader from programmers
'4- compile a new program for example M88.bas
'5- press F4 and reset your micro
' the program will now be uploaded into the chip with Xmodem Checksum
' you can write your own loader.too
'A stand alone command line loader is also available


'How to call the bootloader from your program without a reset ???
'Do
'   Print "test"
'   Waitms 1000
'   If Inkey() = 27 Then
'      Print "boot"
'      Goto &H1C00
'   End If
'Loop

'The GOTO will do the work, you need to specify the correct bootloader address
'this is the same as the $LOADER statement.