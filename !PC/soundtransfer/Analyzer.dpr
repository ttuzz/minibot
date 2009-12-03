program Analyzer;

uses
  Forms,
  main in 'main.pas' {frm_Main};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tfrm_Main, frm_Main);
  Application.Run;
end.
