unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ExtDlgs, XPMan;

type
  TfrmMain = class(TForm)
    mbi_preview: TImage;
    bmp_preview: TImage;
    Label1: TLabel;
    Label2: TLabel;
    btn_do_encode: TButton;
    dlg_open: TOpenPictureDialog;
    XPManifest: TXPManifest;
    
    function color_encode(r: byte; g: byte; b: byte): byte;
    function color_decode(color: byte): TColor;
    procedure btn_do_encodeClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    function ExtractFileNameEx(FileName: string; ShowExtension: Boolean): string;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}


{ TfrmMain }
function TfrmMain.color_decode(color: byte): TColor;
// декодирует проебразованный цвет
// использует разделение на сегменты цвета (8 для красн и зел, 4 - для син)
// вход: R8G8B8
// выход: R3G3B2
var
  r,g,b: byte;
  segment: byte;
begin
  segment := 256 div 7;
  r := (color shr 5) * segment;
  g := ((color and $1C) shr 2) * segment;
  segment := 256 div 3;
  b := (color and $03) * segment;

  result := RGB(r,g,b);
end;

function TfrmMain.color_encode(r: byte; g:byte; b:byte): byte;
// кодирует цвет
// использует разделение на сегменты цвета (8 для красн и зел, 4 - для син)
// вход: R8G8B8
// выход: R3G3B2
var
  segment: byte;
  value: byte;
begin
  segment := 256 div 8;
  value := (r div segment) shl 5;
  result := value;
  value := (g div segment) shl 2;
  result := result or value;

  segment := 256 div 4;
  value := b div segment;
  result := result or value;
end;

procedure TfrmMain.btn_do_encodeClick(Sender: TObject);
var
  i,k: byte;
  buf: byte;
  col: longint;
  dir: string;    // для хранения имени файла
  file_out: TFileStream;
begin
  // открываю файл
  getdir(0, dir);
  dlg_open.InitialDir := dir;
  if not dlg_open.Execute then
    exit;
    
  try
    bmp_preview.Picture.LoadFromFile(dlg_open.FileName);
  except
    MessageBox(0,'Неверное имя файла', 'Ошибка!', MB_ICONWARNING);
    frmMain.FormShow(Sender);
    exit;
  end;

  // вывод на предпросмотр
  for i := 0 to 66 do
    for k := 0 to 97 do with bmp_preview.Canvas do
    begin
      col := ColorToRGB(Pixels[k,i]);
      mbi_preview.Canvas.Pixels[k,i] :=
        color_decode(
          color_encode(col, col shr 8, col shr 16));
    end;

  // вывод в выходной файл
  dir := dlg_open.FileName;    // получаю имя файла
  delete(dir, pos(ExtractFileNameEx(dlg_open.FileName, true), dlg_open.FileName),
    length(ExtractFileNameEx(dlg_open.FileName, true)));  // =))
  try
    file_out := TFileStream.Create(
      dir+ExtractFileNameEx(dlg_open.FileName, false)+'.mbi', fmCreate);
  except
    MessageBox(0,'Невозможно создать выходной файл', 'Ошибка!', MB_ICONERROR);
    frmMain.FormShow(Sender);
    exit;
  end;
  
  for i := 0 to 66 do
    for k := 0 to 97 do with bmp_preview.Canvas do
    begin
      col := ColorToRGB(Pixels[k,i]);
      buf := color_encode(col, col shr 8, col shr 16);
      file_out.WriteBuffer(buf, 1);
    end;
  file_out.Free;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  with bmp_preview.Canvas do
    FillRect(ClipRect);
  with mbi_preview.Canvas do
    FillRect(ClipRect);
end;

function TfrmMain.ExtractFileNameEx(FileName: string; ShowExtension: Boolean): string;
//Функция возвращает имя файла, без или с его расширением.

//ВХОДНЫЕ ПАРАМЕТРЫ
//FileName - имя файла, которое надо обработать
//ShowExtension - если TRUE, то функция возвратит короткое имя файла
// (без полного пути доступа к нему), с расширением этого файла, иначе,возвратит
  // короткое имя файла, без расширения этого файла.
var
  I: Integer;
  S, S1: string;
begin
  //Определяем длину полного имени файла
  I := Length(FileName);
  //Если длина FileName <> 0, то
  if I <> 0 then
  begin
    //С конца имени параметра FileName ищем символ "\"
    while (FileName[i] <> '\') and (i > 0) do
      i := i - 1;
    // Копируем в переменную S параметр FileName начиная после последнего
    // "\", таким образом переменная S содержит имя файла с расширением, но без
    // полного пути доступа к нему
    S := Copy(FileName, i + 1, Length(FileName) - i);
    i := Length(S);
    //Если полученная S = '' то фукция возвращает ''
    if i = 0 then
    begin
      Result := '';
      Exit;
    end;
    //Иначе, получаем имя файла без расширения
    while (S[i] <> '.') and (i > 0) do
      i := i - 1;
    //... и сохраням это имя файла в переменную s1
    S1 := Copy(S, 1, i - 1);
    //если s1='' то , возвращаем s1=s
    if s1 = '' then
      s1 := s;
    //Если было передано указание функции возвращать имя файла с его
    // расширением, то Result = s,
    //если без расширения, то Result = s1
    if ShowExtension = TRUE then
      Result := s
    else
      Result := s1;
  end
    //Иначе функция возвращает ''
  else
    Result := '';
end;

end.
