'(
$regfile = "m8DEF.dat"
$baud = 9600
$crystal = 7372800

$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space


Dim S As String * 20

Do
   Print "out:";
   Input #10 , S
   Print S
Loop

Print "done"
')

$regfile = "m8DEF.dat"                                      ' the used chip
$crystal = 7372800                                          ' frequency used
$baud = 9600                                                ' brauchen wir nicht
Config Serialin = Buffered , Size = 20


Waitms 100

' TWI init
Gosub Twi_init_slave

' ïîðòû äëÿ ñåðâ
'Config Portb.1 = Output
'Config Portb.2 = Output
'Config Portd = Output

Const Maxanzahlbyte = 10                                    ' Wenn mehr Zeichen kommen werden diese verworfen !
Dim Messagebuf(maxanzahlbyte) As Byte
Dim Anzahlbuf As Byte                                       ' Anzahl Zeichen die gesendet wurden

Dim Neuemsg As Byte                                         ' zeigt an wenn eine neue Message gültig ist

Dim Twi_control As Byte                                     ' Controlregister lokale kopie
Dim Twi_status As Byte
Dim Twi_data As Byte

Const Eigene_slave_adr = &B01110000                         ' Adresse evtl. Anpassen

Config Pinb.2 = Output
Reset Portb.2

' wegen der Servos, TWI braucht das hier nicht
Enable Interrupts

Twi_data = 0
Neuemsg = 0                                                 ' Paket ungültig
Anzahlbuf = 0                                               ' Anzahl empfangener Bytes

Do

    ' schauen ob TWINT gesetzt ist
    Twi_control = Twcr And &H80                             ' Bit7 von Controlregister

    If Twi_control = &H80 Then
        Twi_status = Twsr And &HF8                          ' Status

        Select Case Twi_status

            ' Slave Adress received, wir sind gemeint !
            Case &H60 :
                Twcr = &B11000100                           ' TWINT löschen, erzeugt ACK
                Anzahlbuf = 0
                Neuemsg = 0                                 ' Flag für Message ungültig

            ' Byte mit ACK
            Case &H80 :
                If Anzahlbuf < Maxanzahlbyte Then
                    Incr Anzahlbuf                          ' zähler +1
                    Messagebuf(anzahlbuf) = Twdr
                End If
                Twcr = &B11000100                           ' TWINT löschen, erzeugt ACK

            ' Stop oder restart empfangen
            Case &HA0 :
                Twcr = &B11000100                           ' TWINT löschen, erzeugt ACK
                ' es müssen 3 Byte sein, damit das Paket OK ist
                If Anzahlbuf = 3 Then
                    Neuemsg = 1                             ' Flag für Message gültig
                Else
                    Neuemsg = 0                             ' Flag für Message ungültig
                End If
                Print "message: " ; Chr(messagebuf(1)) ; " " ; Messagebuf(2) ; " " ; Messagebuf(3)

            ' letztes Byte mit NACK, brauchen wir nicht
            Case &H88 :
            Case &HF8 :
            ' Fehler, dann reset TWI
            Case &H00 :
                Twcr = &B11010100                           ' TWINT löschen, reset TWI

            ' was anderes empfangen, sollte nicht vorkommen
            Case Else :
                Twcr = &B11000100                           ' TWINT löschen, erzeugt ACK

        End Select

    End If

    ' ein gültiges Paket angekommen
    If Neuemsg = 1 Then
        Neuemsg = 0                                         ' Flag wieder löschen
        'Print "message: " ; Messagebuf(1) ; Messagebuf(2) ; Messagebuf(3)
        ' nur wenn das erste Zeichen ein "S" ist tun wir was damit !
        If Messagebuf(1) = "S" Then
            'Servo(messagebuf(2)) = Messagebuf(3)
            Print "servo message: " ; Messagebuf(1) ; Messagebuf(2) ; Messagebuf(3)
            Set Portb.2
            'Sound Portb.0 , 300 , 450                  ' Roger-BEEP
        End If
    End If

    Waitms 10

Loop

End

' TWI als slave aktivieren
Twi_init_slave:
    Twsr = 0                                                ' status und Prescaler auf 0
    Twdr = &HFF                                             ' default
    Twar = Eigene_slave_adr                                 ' Slaveadresse setzen
    Twcr = &B01000100                                       ' TWI aktivieren, ACK einschalten
Return