program stk500;

uses
  Forms,
  main in 'main.pas' {frm_main},
  packet_generator in 'packet_generator.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tfrm_main, frm_main);
  Application.Run;
end.
