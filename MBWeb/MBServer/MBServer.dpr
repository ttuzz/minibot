program MBServer;

uses
  Forms,
  UnitMain in 'UnitMain.pas' {frmMain},
  UnitServer in 'UnitServer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
