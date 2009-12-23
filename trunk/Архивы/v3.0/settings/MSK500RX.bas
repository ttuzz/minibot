'-------------------------------------------------
' BASCOM AVR CC2500 register constants
' Make in SmartRF 6.9.1
'-------------------------------------------------
Const Cc2500_iocfg2 = &H0E
Const Cc2500_iocfg1 = &H2E
Const Cc2500_iocfg0 = &H06
Const Cc2500_fifothr = &H07
Const Cc2500_sync1 = &HD3
Const Cc2500_sync0 = &H91
Const Cc2500_pktlen = &HFF                                  '63
Const Cc2500_pktctrl1 = &H04                                'append_status = 0
Const Cc2500_pktctrl0 = &H45
Const Cc2500_addr = &H00
Const Cc2500_channr = &H00
Const Cc2500_fsctrl1 = &H09
Const Cc2500_fsctrl0 = &H00
Const Cc2500_freq2 = &H5A
Const Cc2500_freq1 = &H1c
Const Cc2500_freq0 = &H71
Const Cc2500_mdmcfg4 = &H2D
Const Cc2500_mdmcfg3 = &H2F
Const Cc2500_mdmcfg2 = &H73
Const Cc2500_mdmcfg1 = &H22
Const Cc2500_mdmcfg0 = &HE5
Const Cc2500_deviatn = &H01
Const Cc2500_mcsm2 = &H07
Const Cc2500_mcsm1 = &H30
Const Cc2500_mcsm0 = &H18
Const Cc2500_foccfg = &H1D
Const Cc2500_bscfg = &H1C
Const Cc2500_agcctrl2 = &HC7
Const Cc2500_agcctrl1 = &H00
Const Cc2500_agcctrl0 = &HB2
Const Cc2500_frend1 = &HB6
Const Cc2500_frend0 = &H10
Const Cc2500_fscal3 = &HEA
Const Cc2500_fscal2 = &H0A
Const Cc2500_fscal1 = &H00
Const Cc2500_fscal0 = &H11
Const Cc2500_rcctrl1 = &H41
Const Cc2500_rcctrl0 = &H00
Const Cc2500_fstest = &H59
Const Cc2500_ptest = &H7F                                   ' для того чтобы юзать analog temperature sensor (data sheet)
Const Cc2500_agctst = &H3F
Const Cc2500_test2 = &H88
Const Cc2500_test1 = &H31
Const Cc2500_test0 = &H0B
'PA table - таблица мощностей
Dim Cc_patable(8) As Byte
Cc_patable(1) = &HFE
Cc_patable(2) = &HFE
Cc_patable(3) = &HFE
Cc_patable(4) = &HFE
Cc_patable(5) = &HFE
Cc_patable(6) = &HFE
Cc_patable(7) = &HFE
Cc_patable(8) = &HFE