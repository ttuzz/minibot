'(
���� �������� ��� ��������� �� ������ � ����������
')

'������� print �� �������, ����, ��������

'��������� ��������
' ������ ������, ��������� tokens.bas
Declare Sub Extracttoken()
Declare Function Getnexttokenstr(byval Pblen_max As Byte ) As String
Declare Function Getnexttokenlong(byval Plmin As Long , Byval Plmax As Long ) As Long

' ����� �� �������, � ���/������, ����, ������� (����� �������������� ���������������� ���� �� ��������)
Declare Sub Print_to_display(s As String)                   ' ������ ������ �� ������� � ���������� ������
Declare Sub Print_ew(s As String , Byval Direct As Byte)    ' print_everywhere ����� ������ �����
Declare Sub Print_error(byval Number As Byte)               ' ����� ������ �����

' ������ � ��������� � ����������� (����� ������ �������������� text_filename � mult_filename)
Declare Sub Print_to_text_file(s As String)                 ' �������� ������ � ���
Declare Sub Print_to_speaker()                              ' ������� �� ������� ����
Declare Sub Print_picture_to_display()                      ' ������ ������ �� ����� � ������� ����� � ������� mbi

Declare Sub Processcommand()                                '��������� ������� �� ������
Declare Sub Writecommands()                                 '������ ������� �� ������
Declare Sub Readcommands()                                  '������ ������� �� ������
Declare Sub Batchrun()                                      '����������� ���������� �������


Sub Print_to_speaker()
' ������� �� ������� ������
' ����� ����� �������������� ������
#if Exist_speaker = 1
   Open Mult_filename For Input As #file
   If Gbdoserror <> 0 Then
      Close #file
      Exit Sub
   End If
   ' ����� ������������ ������ � ������ ����
   Close #file
#endif
End Sub

Sub Print_to_display(s As String)
' �������� �� ������� � ������ �������
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
' �������� ����� �� ������� �� �����
' ��� ����� - mult_filename ������ ���� ������ �������!!!
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
' �������� ������ S � ��������� ���� text_filename(��� ��� ���-������ ���)
' ��� ����� - text_filename
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
' �������� �� �������, � ���� � � ���/������
' ������ �������� �������� �� ���������� �������,
' ����� ��������� ����������� ������
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
' ������� ��� ������ �� ��� ��������� ����������.
' ����� ����� ������� � ����������� ��������
' ��� ����� ��� ���� ��� ������ ���� ������, ����� ��������� ��� ����� �������(������� ������ ��� �������� ��������� �����) ���������
#if Need_extended_errors = 0
   Local S As String * 4 : S = "?" + Str(number)
#else
   Local S As String * 20 : S = "?" + Str(number) + " "     '����� �������� ��������� ������
#endif
   Reset Ucsrb.rxen
      Print S
      #if Need_logging_display = 1
         Call Print_to_display(s)
      #endif
      #if Need_logging_sd = 1 And Exist_sd = 1
         If State = Now_logging Then                        ' ���� ������� ����� - �� ������ ������� � �� ������ ��� ���������������
            Call Print_to_textfile(s)                       ' ���������� � ������� ����
         End If
      #endif
      #if Need_logging_speaker = 1
         S = "err" + Str(number) + ".wav"
         Mult_filename = S : Call Print_to_speaker
      #endif
   Set Ucsrb.rxen
End Sub

$include "include\tokens.bas"                               '������� ��� ������ � ��������