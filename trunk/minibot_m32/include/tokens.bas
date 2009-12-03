
'функции парсинга строки + вывода ошибок
Sub Extracttoken
'(
Разбивает строку на подстроки -токены.
Конфигурацию токенов и их ограницуения смотри в файле "config.bas"
Основные переменные:
Gspcinput : строка пользовательского ввода
Cnttoken : количество токенов
Posstrparts : массив позиции начала каждого токена
Lenstrparts : размер в байтах(символах) каждого токена
')
   Local Lstrlen As Byte
   Local Lparseend As Byte
   Local Lpos1 As Byte , Lpos2 As Byte
   'очистка массивов
   For Gbcnttoken = 1 To Cptoken_max
      Gbposstrparts(gbcnttoken) = 0 : Gblenstrparts(gbcnttoken) = 0
   Next

   Gbcnttoken = 0
   Gspcinput = Trim(gspcinput)
   Lstrlen = Len(gspcinput)                                 'получение длины строки
   If Lstrlen = 0 Then                                      'если строка пуста
      Gbtoken_actual = 0                                    'устанавливаем номер актуального токена
      Exit Sub
   End If
   Lparseend = 0
   Lpos1 = 0
   For Gbcnttoken = 1 To Cptoken_max
      Incr Lpos1
      If Gbcnttoken = 1 Then
         Lpos2 = Instr(lpos1 , Gspcinput , " ")             'поиск следующего разделителя (пробел)
      Else
         Lpos2 = Instr(lpos1 , Gspcinput , Cpstrsep)        'поиск следующего разделителя (запятая)
      End If
      If Lpos2 = 0 Then                                     'если больше ничего не найдено
         Lpos2 = Lstrlen : Incr Lpos2 : Lparseend = 1
      End If
      Gblenstrparts(gbcnttoken) = Lpos2 - Lpos1             'длина токена
      Gbposstrparts(gbcnttoken) = Lpos1

      If Lparseend = 1 Then
         Exit For
      End If
      Lpos1 = Lpos2
   Next
   Gbtoken_actual = 0                                       'устанавливаем номер актуального токена
End Sub


Function Getnexttokenstr(byval Pblen_max As Byte ) As String
'(
Возвращает следующий токен из пользовательского ввода в формате строки.
Обрезка пробелов не осуществляется
')
   Local Lbpos As Byte
   Local Lblen As Byte
   Incr Gbtoken_actual                                      'увеличивает номер текущего токена
   Lbpos = Gbposstrparts(gbtoken_actual)                    'получает позицию начала токена
   Lblen = Gblenstrparts(gbtoken_actual)                    'и его размер
   If Lblen > Pblen_max Then Lblen = Pblen_max              'слишком большой?
   Getnexttokenstr = Mid(gspcinput , Lbpos , Lblen)         'возвращает строку
End Function


Function Getnexttokenlong(byval Plmin As Long , Byval Plmax As Long ) As Long
'(
Возвращает следующий токен из пользовательского ввода в формате числа
в пределах:
Plmin : граница -минимум
Plmax : граница -максимум
')
   Local Lbpos As Byte
   Local Lblen As Byte
   Local Lstoken As String * 12
   Incr Gbtoken_actual                                      'увеличиваем номер текущего токена
   Lbpos = Gbposstrparts(gbtoken_actual)                    'получает позицию начала токена
   Lblen = Gblenstrparts(gbtoken_actual)                    'и его размер
   If Lblen > 12 Then Lblen = 12                            'слишком большой?
   Lstoken = Mid(gspcinput , Lbpos , Lblen)
   Lstoken = Ltrim(lstoken)
   If Mid(lstoken , 1 , 1) = "$" Then                       'HEX число?
      Mid(lstoken , 1 , 1) = " "
      Lstoken = Ltrim(lstoken)
      Getnexttokenlong = Hexval(lstoken)
   Else
      Getnexttokenlong = Val(lstoken)
   End If
   Select Case Getnexttokenlong                             'проверка границ
      Case Plmin To Plmax                                   'проверка пройдена, выход
      Case Else
      Call Print_error(cpparameter)                         'ошибка
   End Select
End Function