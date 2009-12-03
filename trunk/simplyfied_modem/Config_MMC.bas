'-------------------------------------------------------------------------------
'                         config_MMC.BAS
'               Config File for MMC Flash Cards Driver
'        (c) 2003-2005 , MCS Electronics / Vögel Franz Josef
'-------------------------------------------------------------------------------
' Place MMC.LIB in the LIB-Path of BASCOM-AVR installation
'
'Connection as following
'MMC    M32
'1      MMC_CS PORTB.4
'2      MOSI PORTB.5
'3      GND
'4      +3.3V
'5      CLOCK PORTB.7
'6      GND
'7      MISO, PORTB.6

' you can vary MMC_CS on HW-SPI and all pins on SOFT-SPI, check settings
' ========== Start of user definable range =====================================

' you can use HW-SPI of the AVR (recommended) or a driver build in Soft-SPI, if
' the HW-SPI of the AVR is occupied by an other SPI-Device with different settings

' Declare here you SPI-Mode
' using HW-SPI:     cMMC_Soft = 0
' not using HW_SPI: cMMC_Soft = 1

Const Cmmc_soft = 0

#if Cmmc_soft = 0

' --------- Start of Section for HW-SPI ----------------------------------------

   ' define Chip-Select Pin
   Config Pinb.4 = Output                                   ' define here Pin for CS of MMC/SD Card
   Mmc_cs Alias Portb.4
   Set Mmc_cs

   ' Define here SS Pin of HW-SPI of the CPU (f.e. Pinb.0 on M128)
   ' If an other Pin than SS is used for MMC_SS, SS must be set to OUTPUT and high for proper work of SPI
   ' otherwise AVR starts SPI-SLAVE if SS-Pin is INPUT and goes to LOW
   Config Pinb.4 = Output                                   ' define here Pin of SPI SS
   Spi_ss Alias Portb.4
   Set Spi_ss                                               ' Set SPI-SS to Output and High por Proper work of
                                                            ' SPI as Master

   ' HW-SPI is configured to highest Speed
   Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = High , Phase = 1 , Clockrate = 4 , Noss = 1
'   Spsr = 1                                       ' Double speed on ATMega128
   Spiinit                                                  ' Init SPI

' --------- End of Section for HW-SPI ------------------------------------------

#else                                                       ' Config here SPI pins, if not using HW SPI

' --------- Start of Section for Soft-SPI --------------------------------------

   ' Chip Select Pin  => Pin 1 of MMC/SD
   Config Pinb.4 = Output
   Mmc_cs Alias Portb.4
   Set Mmc_cs

   ' MOSI - Pin  => Pin 2 of MMC/SD
   Config Pinb.5 = Output
   Set Pinb.5
   Mmc_portmosi Alias Portb
   Bmmc_mosi Alias 2

   ' MISO - Pin  => Pin 7 of MMC/SD
   Config Pinb.6 = Input
   Mmc_portmiso Alias Pinb
   Bmmc_miso Alias 3

   ' SCK - Pin  => Pin 1 of MMC/SD
   Config Pinb.7 = Output
   Set Pinb.7
   Mmc_portsck Alias Portb
   Bmmc_sck Alias 1

' --------- End of Section for Soft-SPI ----------------------------------------

#endif

' ========== End of user definable range =======================================


' Error
Const Cperrdrivereset = 225                                 ' Error response Byte at Reset command
Const Cperrdriveinit = 226                                  ' Error response Byte at Init Command
Const Cperrdrivereadcommand = 227                           ' Error response Byte at Read Command
Const Cperrdrivewritecommand = 228                          ' Error response Byte at Write Command
Const Cperrdrivereadresponse = 229                          ' No Data response Byte from MMC at Read
Const Cperrdrivewriteresponse = 230                         ' No Data response Byte from MMC at Write
Const Cperrdrive = 231
Const Cperrdrivenotsupported = 232                          ' return code for DriveGetIdentity, not supported yet

Waitms 1                                                    ' Wait some time before initialising MMC/SD
Dim Gbdriveerror As Byte                                    ' General Driver Error register
Dim Gbdriveerrorreg As Byte                                 ' Driver load Error-Register of HD in case of error
Dim Gbdrivestatusreg As Byte                                ' Driver load Status-Register of HD on case of error
Dim Gbdrivedebug As Byte
$lib "MMC.LIB"                                              ' link driver library
$external _mmc
Gbdriveerror = Driveinit()                                  ' Init MMC/SD Card