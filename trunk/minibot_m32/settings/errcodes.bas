'(
Файл содержит текстовые описания ошибок , хранимые в еппром
0 - без ошибки
Const Cpnoerror = 0                                         'Нет ошибки
1...100 включительно - ошибки Avr -dos

')

'ошибки файловой системы
'(

Const Cpendoffile = 1                                       'Попытка чтения файла за пределами его конца
Const Cpnombr = 17                                          'Сектор 0 на диске не является главной загрузочной записью (MBR)
Const Cpnopbr = 18                                          'Таблица секторов(Partition Sector) недоступна
Const Cpfilesystemnotsupported = 19                         'Неподдерживаемая файловая система, поддерживается только FAT16 и FAT32
Const Cpsectorsizenotsupported = 20                         'Неподдерживаемый размер сектора, поддерживаются сектора 512 Байт.
Const Cpsectorsperclusternotsupported = 21                  'Подддерживаются только 1, 2, 4, 8, 16, 32, 64 секторов в кластере. Это нормальные значения для отформатированного раздела. Экзотические размеры кластера, не делящиеся нацело на 2, не поддерживаются
Const Cpcountofclustersnotsupported = 22                    'Данное количество разделов не поддерживается (поддерживается только 1 или 2 раздела)"Count of FAT (valid is 1 or 2) not supported (will be renamed with one of next release)"
Const Cpnonextcluster = 33                                  'Следующий кластер файла недоступен "Error in file cluster chain"
Const Cpnofreecluster = 34                                  'Нет свободных кластеров"(cluster)", диск заполнен
Const Cpclustererror = 35                                   'Ошибка чтения кластера файла "Error in file cluster chain"
Const Cpnofreedirentry = 49                                 'Директория заполнена "Directory full"
Const Cpfileexist = 50                                      'Такой файл уже существует (неверное имя при переименовании)"(сам придумал)"
Const Cpfiledeletenotallowed = 51                           'Удаление файла запрещено его атрибутами (файл скрытый, системный или только для чтения)
Const Cpsubdirectorynotempty = 52                           'Невозможно удалить каталог, он не пуст.
Const Cpsubdirectoryerror = 53                              'General error at handling with sub-directory
Const Cpnoasubdirectory = 54                                'Имя не соотвествует каталогу, это файл.
Const Cpnofreefilenumber = 65                               'Нет свободных идентификаторов файлового потока (возможно открыть не более 255 файлов одновременно)
Const Cpfilenotfound = 66                                   'Файл не найден
Const Cpfilenumbernotfound = 67                             'Такой идентификатор файлового потока не существует
Const Cpfileopennohandle = 68                               'Все идентификаторы файлового потока неверны "All file handles occupied"
Const Cpfileopenhandleinuse = 69                            'Такой идентификатор файлового потока уже используется, невозможно создать новый поток с таким идентификатором
Const Cpfileopenshareconflict = 70                          'Невозможно получить доступ к файлу(напр, одновременне открытие для записи и чтения)
Const Cpfileinuse = 71                                      'Невозможно удалить файл, использующийся в данный момент
Const Cpfilereadonly = 72                                   'Невозможно произвести запись, файл только для чтения.
Const Cpfilenowildcardallowed = 73                          'Специальные символы(WildCards) не разрешены при использовании данной функции
Const Cpfilenumberinvalid = 74                              'Файловый идентификатор не поддерживается (напр, 0)
Const Cpfilepositionerror = 97                              'Позиция курсора неверна ("сам придумал")
Const Cpfileaccesserror = 98                                'Функция не может выполнятся в текущем режиме открытия файла
Const Cpinvalidfileposition = 99                            'Новая позиция курсора неверна (отрицательное значение или 0) "в описании идентификаторов сказано что нумерация с нуля. кто же прав?"
Const Cpfilesizetogreat = 100                               'Размер файла слишком большой для использования функции BLoad
')
'ошибки шлюза
Const Cpparametercount = 101                                'Неверное количество параметров в пользовательском вводе
Const Cpparameter = 102                                     'Неверный параметр функции (аргумент не влезает в пределы)
Const Cpextracterror = 103                                  'Неверная комманда (не распознана, возможно, её использование не включено в сборку)
