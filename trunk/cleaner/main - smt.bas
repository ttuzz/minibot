$regfile = "m32DEF.dat"
$crystal = 8000000
$hwstack = 32
$swstack = 10
$framesize = 40

Portc = &B11111111
Config Pinc.2 = Output : Левый_назад Alias Portc.2
Config Pinc.3 = Output : Правый_назад Alias Portc.3

Porta = &B00000000
Config Pina.0 = Input : Левый_датчик Alias Pina.0
Config Pina.1 = Input : Правый_датчик Alias Pina.1
Config Pina.3 = Input : Передний_датчик Alias Pina.3        'была проблема с контактом на PINA.2, по этому не по порядку

Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down

Const Нажат = 1 : Const Light = 0
Dim Минимальная_скорость As Integer
Dim Максимальная_скорость As Integer
Dim Скорость_левого As Integer

Минимальная_скорость = 150
Максимальная_скорость = 255
Скорость_левого = Минимальная_скорость

Dim Период As Long
Dim Увеличение As Long
Период = 50
Увеличение = 1

Левый_назад = 0
Правый_назад = 0

Do
   Скорость_левого = Минимальная_скорость                   'left
   Pwm1a = Максимальная_скорость                            'right
   Gosub Двигаться_по_спирали
   Gosub Двигаться_вперед
Loop
End

Двигаться_по_спирали:
   While Скорость_левого < Максимальная_скорость
      Pwm1b = Скорость_левого
      Gosub Время_ожидания
      Скорость_левого = Скорость_левого + Увеличение
   Wend
Return

Двигаться_вперед:
   Dim Счетчик_движения_вперед As Integer
   Счетчик_движения_вперед = 3                              '3 sec
   While Счетчик_движения_вперед >= 0
      Pwm1b = Максимальная_скорость
      Pwm1a = Максимальная_скорость
      Gosub Время_ожидания
      Decr Счетчик_движения_вперед
   Wend
        Pwm1b = 0 : Pwm1a = 0
 Return

Время_ожидания:
Dim Count As Long
Count = Период
While Count > 0
      If Правый_датчик <> Нажат And Левый_датчик <> Нажат And Передний_датчик <> Нажат Then
         Decr Count
         Waitms 20
      Else
         Pwm1b = Максимальная_скорость : Pwm1a = Максимальная_скорость
         If Передний_датчик = Нажат Then
               Левый_назад = 1
               Правый_назад = 1
               Wait 1
               Левый_назад = 0
               Wait 1
               Правый_назад = 0
         Elseif Правый_датчик = Нажат Then
               Левый_назад = 1
               Правый_назад = 0
               Waitms 500
               Левый_назад = 0
         Elseif Левый_датчик = Нажат Then
               Левый_назад = 0
               Правый_назад = 1
               Waitms 500
               Правый_назад = 0
         End If
         Скорость_левого = Максимальная_скорость
         Return
      End If
Wend
Return
