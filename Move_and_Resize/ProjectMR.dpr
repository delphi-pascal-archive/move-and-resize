program ProjectMR;

uses
  Forms,
  UnitMR1 in 'UnitMR1.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
