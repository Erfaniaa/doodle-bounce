unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, LMDControl, LMDCustomControl, LMDCustomPanel, LMDCustomBevelPanel,
  LMDBaseEdit, LMDCustomMemo, LMDMemo, Grids, StdCtrls, LMDPNGImage, ExtCtrls,
  LMDCustomNImage, LMDNImage, LMDBaseControl, LMDBaseGraphicControl,
  LMDGraphicControl, LMDBaseImage, LMDCustomLImage, LMDLImage, GIFImg;

type
  TForm2 = class(TForm)
    Background: TImage;
    Player1: TLabel;
    Player2: TLabel;
    Player4: TLabel;
    Player3: TLabel;
    Player5: TLabel;
    Score5: TLabel;
    Score1: TLabel;
    Score2: TLabel;
    Score3: TLabel;
    Score4: TLabel;
    Image1: TImage;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TScore = record
    Name: string;
    Value: Int64;
  end;

var
  Form2: TForm2;
  F: TextFile;
  I: Integer;
  Player, Score: string;
  Scores: array [1..10000] of TScore;

implementation

{$R *.dfm}

procedure TForm2.FormShow(Sender: TObject);
begin
  if FileExists ('High Scores.DoodleJump') then
  begin
    AssignFile (F, 'High Scores.DoodleJump');
    Reset (F);
    while not EOF (F) do
    begin
      Inc (I);
      Readln (F, Player);
      Readln (F, Score);
      Scores[I].Name := Player;
      Scores[I].Value := StrToInt (Score);
      case I of
        1:
        begin
          Player1.Caption := Player;
          Score1.Caption := Score;
        end;
        2:
        begin
          Player2.Caption := Player;
          Score2.Caption := Score;
        end;
        3:
        begin
          Player3.Caption := Player;
          Score3.Caption := Score;
        end;
        4:
        begin
          Player4.Caption := Player;
          Score4.Caption := Score;
        end;
        5:
        begin
          Player5.Caption := Player;
          Score5.Caption := Score;
        end;
      end;
    end;
    CloseFile (F);
  end;
end;

end.
