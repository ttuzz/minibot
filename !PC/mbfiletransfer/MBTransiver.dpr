program MBTransiver;

uses
  Forms,
  Main in 'Main.pas' {frm_main},
  base64_procs in 'base64_procs.pas',
  crc16_procs in 'crc16_procs.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tfrm_main, frm_main);
  Application.Run;
end.
