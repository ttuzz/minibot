'(
Файл содержит все процедуры, связанные с прерываниями
')
Learn_rc5:
   Disable Int1
   Enable Interrupts
   Getrc5(Ir_command_adress , Ir_command)
   Enable Interrupts
   If Ir_command_adress <> Ir_adress And Ir_command <> 255 Then
      Ir_command = Ir_command And &B01111111
      'Print Chr(12);
      'Print "Address - " ; Ir_command_adress
      'Print "Command - " ; Ir_command
   End If

  'Gosub Processcommand
  'If Isremember = 3 Then Gosub Writecommands
  'If Isplay = 3 Then Gosub Readcommands

  Gifr = Gifr Or &B10000000                                 'Clear Flag Int1
  Enable Int1
Return