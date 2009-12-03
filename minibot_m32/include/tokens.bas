
'������� �������� ������ + ������ ������
Sub Extracttoken
'(
��������� ������ �� ��������� -������.
������������ ������� � �� ������������ ������ � ����� "config.bas"
�������� ����������:
Gspcinput : ������ ����������������� �����
Cnttoken : ���������� �������
Posstrparts : ������ ������� ������ ������� ������
Lenstrparts : ������ � ������(��������) ������� ������
')
   Local Lstrlen As Byte
   Local Lparseend As Byte
   Local Lpos1 As Byte , Lpos2 As Byte
   '������� ��������
   For Gbcnttoken = 1 To Cptoken_max
      Gbposstrparts(gbcnttoken) = 0 : Gblenstrparts(gbcnttoken) = 0
   Next

   Gbcnttoken = 0
   Gspcinput = Trim(gspcinput)
   Lstrlen = Len(gspcinput)                                 '��������� ����� ������
   If Lstrlen = 0 Then                                      '���� ������ �����
      Gbtoken_actual = 0                                    '������������� ����� ����������� ������
      Exit Sub
   End If
   Lparseend = 0
   Lpos1 = 0
   For Gbcnttoken = 1 To Cptoken_max
      Incr Lpos1
      If Gbcnttoken = 1 Then
         Lpos2 = Instr(lpos1 , Gspcinput , " ")             '����� ���������� ����������� (������)
      Else
         Lpos2 = Instr(lpos1 , Gspcinput , Cpstrsep)        '����� ���������� ����������� (�������)
      End If
      If Lpos2 = 0 Then                                     '���� ������ ������ �� �������
         Lpos2 = Lstrlen : Incr Lpos2 : Lparseend = 1
      End If
      Gblenstrparts(gbcnttoken) = Lpos2 - Lpos1             '����� ������
      Gbposstrparts(gbcnttoken) = Lpos1

      If Lparseend = 1 Then
         Exit For
      End If
      Lpos1 = Lpos2
   Next
   Gbtoken_actual = 0                                       '������������� ����� ����������� ������
End Sub


Function Getnexttokenstr(byval Pblen_max As Byte ) As String
'(
���������� ��������� ����� �� ����������������� ����� � ������� ������.
������� �������� �� ��������������
')
   Local Lbpos As Byte
   Local Lblen As Byte
   Incr Gbtoken_actual                                      '����������� ����� �������� ������
   Lbpos = Gbposstrparts(gbtoken_actual)                    '�������� ������� ������ ������
   Lblen = Gblenstrparts(gbtoken_actual)                    '� ��� ������
   If Lblen > Pblen_max Then Lblen = Pblen_max              '������� �������?
   Getnexttokenstr = Mid(gspcinput , Lbpos , Lblen)         '���������� ������
End Function


Function Getnexttokenlong(byval Plmin As Long , Byval Plmax As Long ) As Long
'(
���������� ��������� ����� �� ����������������� ����� � ������� �����
� ��������:
Plmin : ������� -�������
Plmax : ������� -��������
')
   Local Lbpos As Byte
   Local Lblen As Byte
   Local Lstoken As String * 12
   Incr Gbtoken_actual                                      '����������� ����� �������� ������
   Lbpos = Gbposstrparts(gbtoken_actual)                    '�������� ������� ������ ������
   Lblen = Gblenstrparts(gbtoken_actual)                    '� ��� ������
   If Lblen > 12 Then Lblen = 12                            '������� �������?
   Lstoken = Mid(gspcinput , Lbpos , Lblen)
   Lstoken = Ltrim(lstoken)
   If Mid(lstoken , 1 , 1) = "$" Then                       'HEX �����?
      Mid(lstoken , 1 , 1) = " "
      Lstoken = Ltrim(lstoken)
      Getnexttokenlong = Hexval(lstoken)
   Else
      Getnexttokenlong = Val(lstoken)
   End If
   Select Case Getnexttokenlong                             '�������� ������
      Case Plmin To Plmax                                   '�������� ��������, �����
      Case Else
      Call Print_error(cpparameter)                         '������
   End Select
End Function