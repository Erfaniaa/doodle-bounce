program DoodleBounce;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Form2},
  Unit3 in 'Unit3.pas' {Form3},
  MainMenu in 'MainMenu.pas' {Form4};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'RiseFashion™ Doodle Bounce';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
