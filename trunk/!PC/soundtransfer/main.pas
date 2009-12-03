unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  Tfrm_Main = class(TForm)
    img_graph: TImage;
    tb_pos: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure graph_draw();
    procedure graph_init(filename: string);
    function graph_get_pixel(pos: cardinal): byte;
    procedure graph_free();
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function find_next_cutoff(): cardinal;
    procedure tb_posChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  compression: word = 1;
  cutoff: byte = 127;
var
  frm_Main: Tfrm_Main;
  f: TFileStream;
  is_ok: boolean = false;
  old_pos: cardinal;
implementation

{$R *.dfm}

procedure Tfrm_Main.FormCreate(Sender: TObject);
begin
  with img_graph.Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(ClipRect);
  end;
  graph_init('sin.wav');
  if not is_ok then
    close;
end;

procedure Tfrm_Main.graph_draw;
var
  i: cardinal;
  b: byte;
  pos: cardinal;
begin
  f.Position := tb_pos.Position * img_graph.Width;
  old_pos := 0;
  with img_graph.Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(ClipRect);
    //Pen.Color := clAqua;
    MoveTo(0, cutoff);
    LineTo(Width, cutoff);
    //brush.Color := clBlack;
    Pen.Color := clRed;
    f.ReadBuffer(b, 1);
    MoveTo(0, b);
    for i := 1 to img_graph.Width - 1 do
    begin
    pen.Width := 1;
      Pen.Color := clRed;
      f.ReadBuffer(b, 1);
      LineTo(i, b);
      MoveTo(i,b);

      pen.Color := clBlack;
      pos := find_next_cutoff;
      //Ellipse(pos+i-3,cutoff-3,pos+i+3,cutoff+3);

      pen.Color := clOlive;
      pen.Width := 2;
      if graph_get_pixel(old_pos + 2) < cutoff then
        if (abs(pos - old_pos) > 10) then
        begin
          Rectangle(old_pos+i, 128, pos+i, 5);
          pen.Color := clWhite;
          MoveTo(old_pos+i+1, cutoff);
          LineTo(pos+i-1, cutoff);
          MoveTo(i,b);
        end;
      old_pos := pos;
    end;
  end;
end;

procedure Tfrm_Main.graph_init(filename: string);
// инициализирует файл
begin
  if not FileExists(filename) then
    exit;
  try
    f := TFileStream.Create(filename, fmOpenRead);
    f.Position := 0;
    tb_pos.Min := 0;
    tb_pos.Max := f.Size div (img_graph.Width*compression);
    tb_pos.Position := 0;
  except
    f.free;
    ShowMessage('Invalid file');
    exit;
  end;
  is_ok := true;
end;

procedure Tfrm_Main.graph_free;
// освобождает системные ресурсы при выходе
begin
  if is_ok then
  try
    f.Free;
  except
    close;
  end;
end;

procedure Tfrm_Main.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  graph_free;
end;

procedure Tfrm_Main.tb_posChange(Sender: TObject);
begin
  graph_draw;
end;

function Tfrm_Main.find_next_cutoff: cardinal;
const
  error: byte = 3;
var
  old: cardinal;
  b: byte;
  higher: boolean;
  lower : boolean;
begin
  old := f.Position;
  f.Position := f.Position - 1;
  f.ReadBuffer(b, 1);
  higher := b > cutoff;
  if higher then
    repeat
      f.ReadBuffer(b, 1);
    until (b <= cutoff) or (f.Position = f.Size)
  else
    repeat
      f.ReadBuffer(b, 1);
    until (b >= cutoff) or (f.Position = f.Size);
  result := f.Position-old;
  f.Position := old;
end;


function Tfrm_Main.graph_get_pixel(pos: cardinal): byte;
var
  old: cardinal;
  b: byte;
  higher: boolean;
  lower : boolean;
begin
  old := f.Position;
  f.Position := f.Position + pos;
  f.ReadBuffer(b, 1);
  f.Position := old;
  result := b;
end;

end.
