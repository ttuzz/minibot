unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin;

type
  TForm1 = class(TForm)
    se: TSpinEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  i: cardinal;
  buf: byte;
  f1,f2: TFileStream;
begin
  //
  if FileExists('sin.wav') then
    DeleteFile('sin.wav');
  f1 := TFileStream.Create('t12.wav', fmOpenRead);
  f2 := TFileStream.Create('sin.wav', fmCreate);

  for i := 0 to 44 do
  begin
    f1.ReadBuffer(buf,1);
    f2.WriteBuffer(buf,1);
  end;

  for i := 1 to 44000 do
  begin
    buf := round(127.5 + 127.5 * sin(i*se.Value/12000) );
    f2.WriteBuffer(buf, 1);
  end;
  f1.Free;
  f2.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  if FileExists('sin.wav') then
    DeleteFile('sin.wav');
end;

end.
