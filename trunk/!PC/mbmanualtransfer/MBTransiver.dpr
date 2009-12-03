program MBTransiver;

uses
  Forms,
  Main in 'Main.pas' {frm_main},
  terminal_stuff in 'terminal_stuff.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tfrm_main, frm_main);
  Application.Run;
end.
