$regfile = "m32DEF.dat"
$crystal = 7372800
$baud = 9600

'$hwstack = 64
'$swstack = 64
'$framesize = 64


$lib "i2c_twi.lbx"                                          ' ���������� ��� ����������� TWI, ������

Config Scl = Portc.0                                        ' ����� �����
Config Sda = Portc.1                                        ' ������ ������

'CONFIG COM1 = baud , synchrone=0|1,parity=none|disabled|even|odd,stopbits=1|2,databits=4|6|7|8|9,clockpol=0|1
Config Com1 = Dummy , Synchrone = 1 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

I2cinit                                                     ' we need to set the pins in the proper state
Config Twi = 20000                                          ' wanted clock frequency
'will set TWBR and TWSR
'Twbr = 12 'bit rate register
'Twsr = 0 'pre scaler bits


Dim S As String * 20
Dim B(10) As Byte
Dim R(10) As Byte

Waitms 150
Do
   Waitms 10
   Print "TWI master>" ;
   Input S

   B(1) = "S"
   B(2) = "W"                                               ' Servo Write Byte
   B(3) = "B"
   I2csend &B01110000 , B(1) , 3                            ' send the value
   Print "-error : " ; Err                                  ' show error status
   Print "--sended"

   R(4) = &H01
   R(5) = &H02
   I2creceive &B01110000 , R(1) , 0 , 3
   Print "message: " ; Chr(r(1)) ; " " ; Chr(r(2)) ; " " ; Chr(r(3))
   Print "-error: " ; Err
   Print "--received"
Loop