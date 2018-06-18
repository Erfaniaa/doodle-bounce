unit MainMenu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GIFImg, ExtCtrls{, Unit1};

type
  TForm4 = class(TForm)
    Background: TImage;
    Play: TImage;
    Scores: TImage;
    Options: TImage;
    procedure PlayClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  //Form1: TForm1;
  Form4: TForm4;

implementation

{$R *.dfm}

procedure TForm4.PlayClick(Sender: TObject);
begin
  //Form1.Visible := True;
  //Form4.Visible := False;
end;

end.
