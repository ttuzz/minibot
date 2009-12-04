$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 9600

'$hwstack = 64
'$swstack = 64
'$framesize = 64


$lib "i2c_twi.lbx"                                          ' библиотека для хардварного TWI, мастер

Config Scl = Portc.0                                        ' линия клока
Config Sda = Portc.1                                        ' лииния данных

'CONFIG COM1 = baud , synchrone=0|1,parity=none|disabled|even|odd,stopbits=1|2,databits=4|6|7|8|9,clockpol=0|1
Config Com1 = Dummy , Synchrone = 1 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

I2cinit                                                     ' we need to set the pins in the proper state
Config Twi = 400000                                         ' wanted clock frequency
'will set TWBR and TWSR
'Twbr = 12 'bit rate register
'Twsr = 0 'pre scaler bits


Dim S As String * 20
Dim B(3) As Byte
Dim R(5) As Byte
Do
   Print "TWI master>" ;
   Input S

   B(1) = "S"
   B(2) = "W"                                               ' Servo Write Byte
   B(3) = "B"
   I2csend &B01110000 , B(1) , 3                            ' send the value
   Print "Error : " ; Err                                   ' show error status
   Print "--sended"
   Waitms 100

   R(1) = &HFF
   I2creceive &B01110000 , R(1) , 0 , 3
   'I2creceive &B01110000 , R(1) , R(2) , R(3)
   Print "message: " ; Chr(r(1)) ; " " ; Chr(r(2)) ; " " ; Chr(r(3))
   Print "error: " ; Err
   Print "--received"
   Waitms 100
Loop