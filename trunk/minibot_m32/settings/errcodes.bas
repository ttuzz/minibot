'(
���� �������� ��������� �������� ������ , �������� � ������
0 - ��� ������
Const Cpnoerror = 0                                         '��� ������
1...100 ������������ - ������ Avr -dos

')

'������ �������� �������
'(

Const Cpendoffile = 1                                       '������� ������ ����� �� ��������� ��� �����
Const Cpnombr = 17                                          '������ 0 �� ����� �� �������� ������� ����������� ������� (MBR)
Const Cpnopbr = 18                                          '������� ��������(Partition Sector) ����������
Const Cpfilesystemnotsupported = 19                         '���������������� �������� �������, �������������� ������ FAT16 � FAT32
Const Cpsectorsizenotsupported = 20                         '���������������� ������ �������, �������������� ������� 512 ����.
Const Cpsectorsperclusternotsupported = 21                  '��������������� ������ 1, 2, 4, 8, 16, 32, 64 �������� � ��������. ��� ���������� �������� ��� ������������������ �������. ������������ ������� ��������, �� ��������� ������ �� 2, �� ��������������
Const Cpcountofclustersnotsupported = 22                    '������ ���������� �������� �� �������������� (�������������� ������ 1 ��� 2 �������)"Count of FAT (valid is 1 or 2) not supported (will be renamed with one of next release)"
Const Cpnonextcluster = 33                                  '��������� ������� ����� ���������� "Error in file cluster chain"
Const Cpnofreecluster = 34                                  '��� ��������� ���������"(cluster)", ���� ��������
Const Cpclustererror = 35                                   '������ ������ �������� ����� "Error in file cluster chain"
Const Cpnofreedirentry = 49                                 '���������� ��������� "Directory full"
Const Cpfileexist = 50                                      '����� ���� ��� ���������� (�������� ��� ��� ��������������)"(��� ��������)"
Const Cpfiledeletenotallowed = 51                           '�������� ����� ��������� ��� ���������� (���� �������, ��������� ��� ������ ��� ������)
Const Cpsubdirectorynotempty = 52                           '���������� ������� �������, �� �� ����.
Const Cpsubdirectoryerror = 53                              'General error at handling with sub-directory
Const Cpnoasubdirectory = 54                                '��� �� ������������ ��������, ��� ����.
Const Cpnofreefilenumber = 65                               '��� ��������� ��������������� ��������� ������ (�������� ������� �� ����� 255 ������ ������������)
Const Cpfilenotfound = 66                                   '���� �� ������
Const Cpfilenumbernotfound = 67                             '����� ������������� ��������� ������ �� ����������
Const Cpfileopennohandle = 68                               '��� �������������� ��������� ������ ������� "All file handles occupied"
Const Cpfileopenhandleinuse = 69                            '����� ������������� ��������� ������ ��� ������������, ���������� ������� ����� ����� � ����� ���������������
Const Cpfileopenshareconflict = 70                          '���������� �������� ������ � �����(����, ������������ �������� ��� ������ � ������)
Const Cpfileinuse = 71                                      '���������� ������� ����, �������������� � ������ ������
Const Cpfilereadonly = 72                                   '���������� ���������� ������, ���� ������ ��� ������.
Const Cpfilenowildcardallowed = 73                          '����������� �������(WildCards) �� ��������� ��� ������������� ������ �������
Const Cpfilenumberinvalid = 74                              '�������� ������������� �� �������������� (����, 0)
Const Cpfilepositionerror = 97                              '������� ������� ������� ("��� ��������")
Const Cpfileaccesserror = 98                                '������� �� ����� ���������� � ������� ������ �������� �����
Const Cpinvalidfileposition = 99                            '����� ������� ������� ������� (������������� �������� ��� 0) "� �������� ��������������� ������� ��� ��������� � ����. ��� �� ����?"
Const Cpfilesizetogreat = 100                               '������ ����� ������� ������� ��� ������������� ������� BLoad
')
'������ �����
Const Cpparametercount = 101                                '�������� ���������� ���������� � ���������������� �����
Const Cpparameter = 102                                     '�������� �������� ������� (�������� �� ������� � �������)
Const Cpextracterror = 103                                  '�������� �������� (�� ����������, ��������, � ������������� �� �������� � ������)
