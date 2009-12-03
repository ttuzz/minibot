program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {f},
  crc16_procs in 'crc16_procs.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tf, f);
  Application.Run;
end.
