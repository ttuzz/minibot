'(
Файл содержит все процедуры по работе с перифирией
')

'функция print на дисплей, уарт, карточку

'описатели процедур
' разбор строки, описатели tokens.bas
Declare Sub Extracttoken()
Declare Function Getnexttokenstr(byval Pblen_max As Byte ) As String
Declare Function Getnexttokenlong(byval Plmin As Long , Byval Plmax As Long ) As Long

' вывод на дисплей, в лог/батник, уарт, динамик (перед использованием инициализировать файл на карточке)
Declare Sub Print_to_display(s As String)                   ' прямая печать на дисплей в консольном режиме
Declare Sub Print_ew(s As String , Byval Direct As Byte)    ' print_everywhere вывод строки всюду
Declare Sub Print_error(byval Number As Byte)               ' вывод ошибки всюду

' работа с карточкой и мультимедиа (именя файлов соответственно text_filename и mult_filename)
Declare Sub Print_to_text_file(s As String)                 ' печатает строку в лог
Declare Sub Print_to_speaker()                              ' выводит на динамик файл
Declare Sub Print_picture_to_display()                      ' прямая печать из файла в дисплей пикчи в формате mbi

Declare Sub Processcommand()                                'Обработка комманд ИК пульта
Declare Sub Writecommands()                                 'Запись комманд ИК пульта
Declare Sub Readcommands()                                  'Чтение комманд ИК пульта
Declare Sub Batchrun()                                      'Программный обработчик команды


Sub Print_to_speaker()
' выводит на динамик вавчик
' здесь нужно конфигурироват таймер
#if Exist_speaker = 1
   Open Mult_filename For Input As #file
   If Gbdoserror <> 0 Then
      Close #file
      Exit Sub
   End If
   ' здесь конфигурирую таймер и вывожу звук
   Close #file
#endif
End Sub

Sub Print_to_display(s As String)
' печатает на дисплей в режиме консоли
#if Exist_display = 1
   Lcdat Display_y_pos , Display_x_pos , S , Display_text_foreground_color , White
   Display_y_pos = Display_y_pos + Font_height
   Display_y_pos = Display_y_pos + Font_height
   If Display_y_pos > Display_height Then
      Display_y_pos = 0
      Cls
   Else
      Display_y_pos = Display_y_pos - Font_height
   End If
#endif
End Sub

Sub Print_picture_to_display()
' печатает пикчу на дисплей из файла
' имя файла - mult_filename должно быть задано заранее!!!
#if Exist_sd = 1 And Exist_display = 1
   Open Mult_filename For Input As #file
   If Gbdoserror <> 0 Then
      Close #file
      Exit Sub
   End If
   Local I As Byte : Local K As Byte : Local Buf As Byte
   For I = Row_begin To Row_end
      For K = Col_begin To Col_end
         Get #file , Buf
         Pset K , I , Buf
      Next
   Next
   Close #file
#endif
End Sub

Sub Print_to_text_file(s As String)
' печатает строку S в текстовый файл text_filename(лог или что-нибудь ещё)
' имя файла - text_filename
#if Exist_sd = 1
   Open Text_filename For Append As #file
   If Gbdoserror <> 0 Then
      Close #file
      Exit Sub
   End If
   Print #file , S
   Close #file
#endif
End Sub

Sub Print_ew(s As String, byval direct as byte)
' печатает на дисплей, в уарт и в лог/батник
' делает ощутимую задержку на прорисовку дисплея,
' чтобы дождаться опустошения буфера
   If Direct = P_u Or Direct = P_d_u Or Direct = P_u_l Or Direct = P_d_u_l Then
      Reset Ucsrb.rxen
         Print S
      Set Ucsrb.rxen
   End If
   If Direct = P_d Or Direct = P_d_u Or Direct = P_d_l Or Direct = P_d_u_l Then
      Call Print_to_display(s)
   End If
   If Direct = P_l Or Direct = P_d_l Or Direct = P_u_l Or Direct = P_d_u_l Then
      Call Print_to_text_file(s)
   End If
End Sub

Sub Print_error(byval Number As Byte)
' Выводит код ошибки на все известные устройства.
' Также может вывести её расширенное описание
' ИМЯ ФАЙЛА ДЛЯ ЛОГА УЖЕ ДОЛЖНО БЫТЬ ЗАДАНО, НУЖНА ПРОЦЕДУРА ДЛЯ СМЕНЫ РЕЖИМОВ(которая меняет имя текущего открытого файла) ОТДЕЛЬНАЯ
#if Need_extended_errors = 0
   Local S As String * 4 : S = "?" + Str(number)
#else
   Local S As String * 20 : S = "?" + Str(number) + " "     'здесь добавить описатель ошибки
#endif
   Reset Ucsrb.rxen
      Print S
      #if Need_logging_display = 1
         Call Print_to_display(s)
      #endif
      #if Need_logging_sd = 1 And Exist_sd = 1
         If State = Now_logging Then                        ' если текущий режим - не запись батника и не запись его воспроизведения
            Call Print_to_textfile(s)                       ' напечатать в текущий файл
         End If
      #endif
      #if Need_logging_speaker = 1
         S = "err" + Str(number) + ".wav"
         Mult_filename = S : Call Print_to_speaker
      #endif
   Set Ucsrb.rxen
End Sub

$include "include\tokens.bas"                               'функции для работы с токенами