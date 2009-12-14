program MB_servo_distance;

uses
  Forms,
  unitMain in 'unitMain.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
