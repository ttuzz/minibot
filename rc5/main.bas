$regfile = "m32def.dat"                                     ' файл спецификации Меги32
$crystal = 7372800                                          ' указываем на какой частоте будем работать
$baud = 9600

$include "pult.bas"

' Прерывание по спаду уровня для обработки команд RC5
Config Int1 = Falling
On Int1 Learn_rc5
Enable Int1
   Dim Address_rc5 As Byte , Command_rc5 As Byte
' Процедуры
Declare Sub Processcommand()

Config Pinc.5 = Output : Led_g1 Alias Portc.5
Config Pinc.6 = Output : Led_r2 Alias Portc.6

Dim Count As Byte : Count = 0

' Запуск
Enable Interrupts

On Ovf2 Tick
   Config Timer2 = Timer , Prescale = 64
   Enable Timer2

Do
Loop

Tick:
   ' count = 120, если выводятся IR_command and IR_Address
   ' сщгте = 120, если выводится ir_command
   If Count < 120 Then
      Incr Count
      Led_r2 = 1
   Else
      Led_r2 = 0
   End If
Return

Learn_rc5:
   Disable Int1
   Led_g1 = 1
   Count = 0

   Config Rc5 = Pind.3
   Enable Interrupts
   'Enable Timer0
   Getrc5(address_rc5 , Command_rc5)
   'Disable Timer0
   Enable Interrupts

   If Address_rc5 <> 255 And Command_rc5 <> 255 Then
      Command_rc5 = Command_rc5 And &B01111111
      Print Chr(12);
      'Print "IR_Address - " ; Address_rc5
      Print "IR_command - " ; Command_rc5
   End If
  ' обработка команды
  'Gosub Processcommand
  Gifr = Gifr Or &B10000000                                 'Clear Flag Int1
  Led_g1 = 0
  Enable Int1
Return

Sub Processcommand()

End Sub