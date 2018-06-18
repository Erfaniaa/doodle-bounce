unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Graphics, Controls, Forms,
  Dialogs, GIFImg, ExtCtrls, ImgList, pngimage, MPlayer, StdCtrls, ActnList,
  PlatformDefaultStyleActnCtrls, ActnMan, ComCtrls, Classes, Math,
  LMDCustomNImage, LMDNImage, LMDBaseControl, LMDBaseGraphicControl,
  LMDGraphicControl, LMDBaseImage, LMDCustomLImage, LMDLImage, Unit2, Unit3, MainMenu;

type
  TForm1 = class(TForm)
    Background: TImage;
    DoodleMan: TImage;
    MediaPlayer1: TMediaPlayer;
    Timer1: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Paused: TImage;
    Explosion: TImage;
    Timer2: TTimer;
    Timer3: TTimer;
    Bullet: TShape;
    Timer4: TTimer;
    Button1: TButton;
    Timer5: TTimer;
    DoodleMan2: TImage;
    Timer6: TTimer;
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure Button1KeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure Timer4Timer(Sender: TObject);
    procedure Timer5Timer(Sender: TObject);
    procedure Timer6Timer(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TStage = record
    A, B: Word;
  end;

const
  Gravity = 9.8 / 2;
  Di = 6{+};
  DT = 34{-2};
  drLeft = 1;
  drRight = 2;
  drUp = 3;
  M = 2;
  StageCount1 = 100;
  StageCount: array [1..3] of Word = (StageCount1, StageCount1 div M, StageCount1 div (M + 3));
  JumpSpeed: array [1..2] of Real = (31.5, 40);
  Colors: array [1..2, 0..3] of TColor = ((clNavy, clGreen, clRed, clWebOrange), (clYellow, clWhite, clYellow, clWebOrange));
  {PicsMode, Using, DoodleDir}
  //Pictures2: array [1..2, 0..1, 1..3] of string = ((('Doodlepics/Doodle Left.png', 'Doodlepics/Doodle Up 2.png'), ('Doodlepics/Winter/Background.gif', 'Doodlepics/Winter/Doodle Right.png', 'Doodlepics/Winter/Doodle Left.png', 'Doodlepics/Winter/Doodle Up 2.png')), (('Doodlepics/Background 2.gif', 'Doodlepics/Doodle Spring Right 2.png', 'Doodlepics/Doodle Spring Left 2.png', 'Doodlepics/Doodle Up 2.png'), ('Doodlepics/Winter/Background.gif', 'Doodlepics/Winter/Doodle Spring Right 2.png', 'Doodlepics/Winter/Doodle Spring Left 2.png', 'Doodlepics/Winter/Doodle Up 2.png')));
  Pictures: array [1..2, 1..2 + 1, 1..3] of string = ((('Doodlepics/Doodle Left.png', 'Doodlepics/Doodle Right.png', 'Doodlepics/Doodle Up 2.png'), ('Doodlepics/Doodle Spring Left 2.png', 'Doodlepics/Doodle Spring Right 2.png', 'Doodlepics/Doodle Up 2.png'), ('Doodlepics/Doodle Rocket Left.png', 'Doodlepics/Doodle Rocket Right.png', 'Doodlepics/Doodle Up 2.png')), (('Doodlepics/Winter/Doodle Left.png', 'Doodlepics/Winter/Doodle Right.png', 'Doodlepics/Winter/Doodle Up 2.png'), ('Doodlepics/Winter/Doodle Spring Left 2.png', 'Doodlepics/Winter/Doodle Spring Right 2.png', 'Doodlepics/Winter/Doodle Up 2.png'), ('Doodlepics/Winter/Doodle Rocket Left.png', 'Doodlepics/Winter/Doodle Rocket Right.png', 'Doodlepics/Doodle Up 2.png')));
  BackGrounds: array [1..2] of string = ('Doodlepics/Background 2.gif', 'Doodlepics/Winter/Background.gif');
  WidthDis: array [1..2] of Word = (0, 20);
  PicsMode = 2;
  MaxSpeed = 14 - 1;
  DecValue = 0.835;
  MinJump = 14;
  StageDif = 0;
  MoveAccel = 0.30;
  VMultiplier = 0.925;
  UseNone = 1;
  UseSpring = 2;
  UseRocket = 3;

var
  Form1: TForm1;
  //Form4: TForm4;
  X, Y: Real;
  VX, VY, VY0: Real;
  DoodleDir: Integer;
  Teta, V: Real;
  YDif, MaxHeight, MaxHeight2, MaxStage, JumpCount, EnemyNum, SpringNum, HoleNum, ApprHole, RocketNum, Using: Integer;
  Jumped, Started, MoveToLeft, MoveToRight: Boolean;
  Stage: array [1..3, 1..StageCount1] of TShape;
  Enemy: array [1..StageCount1 div (M + 3)] of TImage;
  Spring: array [1..StageCount1 div (M + 5)] of TImage;
  Hole: array [1..StageCount1 div (M + 5)] of TImage;
  Rocket: array [1..StageCount1 div (M + 5)] of TImage;

implementation

{var
  Form2: TForm2;
  Form3: TForm3;
  Form4: TForm4;}

{$R *.dfm}

function IsStopped: TStage;
var
  I, J: Integer;
begin
  Result.A := 0;
  Result.B := 0;
  with Form1 do
  begin
    for J := 1 to 3 do
      for I := 1{MaxStage} to StageCount[J]{MaxStage + 30} do
        if (Stage[J, I].Visible) and (Stage[J, I].Top >= 20) and (Stage[J, I].Top < Form1.ClientHeight) then
        begin
          case DoodleDir of
            drRight:
              if (DoodleMan.Left + DoodleMan.Picture.Width - 17 >= Stage[J, I].Left{ + 2}) and (DoodleMan.Left + WidthDis[PicsMode] <= Stage[J, I].Left + Stage[J, I]{.Picture}.Width) and (Stage[J, I].Top - DoodleMan.Top >= DoodleMan.Picture.Height - 2) and (Stage[J, I].Top - DoodleMan.Top <= DoodleMan.Picture.Height + 15) and (DoodleMan.Top + DoodleMan.Height - VY / Di > Stage[J, I].Top) then
              begin
                Result.A := J;
                Result.B := I;
                Break;
              end;
            drLeft:
              if (DoodleMan.Left + DoodleMan.Picture.Width - WidthDis[PicsMode] >= Stage[J, I].Left{ + 2}) and (DoodleMan.Left + 17 <= Stage[J, I].Left + Stage[J, I]{.Picture}.Width) and (Stage[J, I].Top - DoodleMan.Top >= DoodleMan.Picture.Height - 2) and (Stage[J, I].Top - DoodleMan.Top <= DoodleMan.Picture.Height + 15) and (DoodleMan.Top + DoodleMan.Height - VY / Di > Stage[J, I].Top) then
              begin
                Result.A := J;
                Result.B := I;
                Break;
              end;
            drUp:
              if (DoodleMan.Left + DoodleMan.Picture.Width >= Stage[J, I].Left{ + 2}) and (DoodleMan.Left <= Stage[J, I].Left + Stage[J, I]{.Picture}.Width) and (Stage[J, I].Top - DoodleMan.Top >= DoodleMan.Picture.Height - 2) and (Stage[J, I].Top - DoodleMan.Top <= DoodleMan.Picture.Height + 15) and (DoodleMan.Top + DoodleMan.Height - VY / Di > Stage[J, I].Top) then
              begin
                Result.A := J;
                Result.B := I;
                Break;
              end;
          end;
        end;
  end;
end;

function ApproachEnemy: Word;
var
  I: Integer;
begin
  Result := 0;
  with Form1 do
  begin
    for I := 1 to EnemyNum do
      if (Enemy[I].Top >= 0) and (Enemy[I].Top >= 20) and (Enemy[I].Top < Form1.ClientHeight) and (Enemy[I].Visible) and (Enemy[I].Top > 38) then
      begin
        case DoodleDir of
          drRight:
            if (DoodleMan.Left + DoodleMan.Picture.Width{ - 17 } - 10 >= Enemy[I].Left{ + 2}) and (DoodleMan.Left + WidthDis[PicsMode] <= Enemy[I].Left + Enemy[I]{.Picture}.Width) and (DoodleMan.Top - Enemy[I].Top <= Enemy[I].Height - 9) and (Enemy[I].Top - DoodleMan.Top <= DoodleMan.Picture.Height + 5) and (((VY < 0) and (DoodleMan.Top + DoodleMan.Height {- VY / Di }> Enemy[I].Top)) or ((VY > 0) and (DoodleMan.Top {- VY / Di }< Enemy[I].Top + Enemy[I].Height))) then
            begin
              Result := I;
              Break;
            end;
          drLeft:
            if (DoodleMan.Left + DoodleMan.Picture.Width - WidthDis[PicsMode] >= Enemy[I].Left{ + 2}) and (DoodleMan.Left {+ 17} + 10 <= Enemy[I].Left + Enemy[I]{.Picture}.Width) and (DoodleMan.Top - Enemy[I].Top <= Enemy[I].Height - 9) and (Enemy[I].Top - DoodleMan.Top <= DoodleMan.Picture.Height + 5) and (((VY < 0) and (DoodleMan.Top + DoodleMan.Height {- VY / Di }> Enemy[I].Top)) or ((VY > 0) and (DoodleMan.Top {- VY / Di }< Enemy[I].Top + Enemy[I].Height))) then
            begin
              Result := I;
              Break;
            end;
          drUp:
            if (DoodleMan.Left + DoodleMan.Picture.Width >= Enemy[I].Left{ + 2}) and (DoodleMan.Left {+ 17} <= Enemy[I].Left + Enemy[I]{.Picture}.Width) and (DoodleMan.Top - Enemy[I].Top <= Enemy[I].Height) and (Enemy[I].Top - DoodleMan.Top <= DoodleMan.Picture.Height + 5) and (((VY < 0) and (DoodleMan.Top + DoodleMan.Height {- VY / Di }> Enemy[I].Top)) or ((VY > 0) and (DoodleMan.Top {- VY / Di }< Enemy[I].Top + Enemy[I].Height))) then
            begin
              Result := I;
              Break;
            end;
        end;
      end;
  end;
end;

function HitEnemy: Word;
var
  I: Integer;
begin
  Result := 0;
  with Form1 do
  begin
    for I := 1 to EnemyNum do
      if (Enemy[I].Top >= 20) and (Enemy[I].Top < Form1.ClientHeight) and (Enemy[I].Visible) then
        if (Bullet.Left + Bullet.Width - 3 >= Enemy[I].Left) and (Bullet.Left + 3 <= Enemy[I].Left + Enemy[I].Width) and (Bullet.Top <= Enemy[I].Top + Enemy[I].Height - 2) then
        begin
          Result := I;
          Enemy[I].Visible := False;
          Break;
        end;
  end;
end;

function TakeSpring: Word;
var
  I: Integer;
begin
  Result := 0;
  //if not Using = UseSpring then
    with Form1 do
    begin
      for I := 1 to SpringNum do
        if (Spring[I].Top >= 0) and (Spring[I].Top >= 20) and (Spring[I].Top < Form1.ClientHeight) and (Spring[I].Visible) then
        begin
          case DoodleDir of
            drRight:
              if (DoodleMan.Left + DoodleMan.Picture.Width - 17{  - 10} >= Spring[I].Left{ + 2}) and (DoodleMan.Left + WidthDis[PicsMode] <= Spring[I].Left + Spring[I]{.Picture}.Width) and (DoodleMan.Top <= Spring[I].Top + Spring[I].Height) and (Spring[I].Top + Spring[I].Height - DoodleMan.Top <= DoodleMan.Height + Spring[I].Height) and (((VY < 0) and (DoodleMan.Top + DoodleMan.Height {- VY / Di }> Spring[I].Top)) or ((VY > 0) and (DoodleMan.Top {- VY / Di }< Spring[I].Top + Spring[I].Height))) then
              begin
                Result := I;
                Spring[I].Visible := False;
                Break;
              end;
            drLeft:
              if (DoodleMan.Left + DoodleMan.Picture.Width - WidthDis[PicsMode] >= Spring[I].Left{ + 2}) and (DoodleMan.Left + 17{ + 10} <= Spring[I].Left + Spring[I]{.Picture}.Width) and (DoodleMan.Top <= Spring[I].Top + Spring[I].Height) and (Spring[I].Top + Spring[I].Height - DoodleMan.Top <= DoodleMan.Height + Spring[I].Height) and (((VY < 0) and (DoodleMan.Top + DoodleMan.Height {- VY / Di }> Spring[I].Top)) or ((VY > 0) and (DoodleMan.Top {- VY / Di }< Spring[I].Top + Spring[I].Height))) then
              begin
                Result := I;
                Spring[I].Visible := False;
                Break;
              end;
            drUp:
              if (DoodleMan.Left + DoodleMan.Picture.Width >= Spring[I].Left{ + 2}) and (DoodleMan.Left {+ 17} <= Spring[I].Left + Spring[I]{.Picture}.Width) and (DoodleMan.Top <= Spring[I].Top + Spring[I].Height) and (Spring[I].Top + Spring[I].Height - DoodleMan.Top <= DoodleMan.Height + Spring[I].Height) and (((VY < 0) and (DoodleMan.Top + DoodleMan.Height {- VY / Di }> Spring[I].Top)) or ((VY > 0) and (DoodleMan.Top {- VY / Di }< Spring[I].Top + Spring[I].Height))) then
              begin
                Result := I;
                Spring[I].Visible := False;
                Break;
              end;
          end;
        end;
    end;
end;

function TakeRocket: Word;
var
  I: Integer;
begin
  Result := 0;
  //if not Using = UseRocket then
    with Form1 do
    begin
      for I := 1 to RocketNum do
        if (Rocket[I].Top >= 0) and (Rocket[I].Top >= 20) and (Rocket[I].Top < Form1.ClientHeight) and (Rocket[I].Visible) then
        begin
          case DoodleDir of
            drRight:
              if (DoodleMan.Left + DoodleMan.Picture.Width - 17{  - 10} >= Rocket[I].Left{ + 2}) and (DoodleMan.Left + WidthDis[PicsMode] <= Rocket[I].Left + Rocket[I]{.Picture}.Width) and (DoodleMan.Top <= Rocket[I].Top + Rocket[I].Height) and (Rocket[I].Top + Rocket[I].Height - DoodleMan.Top <= DoodleMan.Height + Rocket[I].Height) and (((VY < 0) and (DoodleMan.Top + DoodleMan.Height {- VY / Di }> Rocket[I].Top)) or ((VY > 0) and (DoodleMan.Top {- VY / Di }< Rocket[I].Top + Rocket[I].Height))) then
              begin
                Result := I;
                Rocket[I].Visible := False;
                Break;
              end;
            drLeft:
              if (DoodleMan.Left + DoodleMan.Picture.Width - WidthDis[PicsMode] >= Rocket[I].Left{ + 2}) and (DoodleMan.Left + 17{ + 10} <= Rocket[I].Left + Rocket[I]{.Picture}.Width) and (DoodleMan.Top <= Rocket[I].Top + Rocket[I].Height) and (Rocket[I].Top + Rocket[I].Height - DoodleMan.Top <= DoodleMan.Height + Rocket[I].Height) and (((VY < 0) and (DoodleMan.Top + DoodleMan.Height {- VY / Di }> Rocket[I].Top)) or ((VY > 0) and (DoodleMan.Top {- VY / Di }< Rocket[I].Top + Rocket[I].Height))) then
              begin
                Result := I;
                Rocket[I].Visible := False;
                Break;
              end;
            drUp:
              if (DoodleMan.Left + DoodleMan.Picture.Width >= Rocket[I].Left{ + 2}) and (DoodleMan.Left {+ 17} <= Rocket[I].Left + Rocket[I]{.Picture}.Width) and (DoodleMan.Top <= Rocket[I].Top + Rocket[I].Height) and (Rocket[I].Top + Rocket[I].Height - DoodleMan.Top <= DoodleMan.Height + Rocket[I].Height) and (((VY < 0) and (DoodleMan.Top + DoodleMan.Height {- VY / Di }> Rocket[I].Top)) or ((VY > 0) and (DoodleMan.Top {- VY / Di }< Rocket[I].Top + Rocket[I].Height))) then
              begin
                Result := I;
                Rocket[I].Visible := False;
                Break;
              end;
          end;
        end;
    end;
end;

function ApproachHole: Word;
var
  I: Integer;
begin
  Result := 0;
  with Form1 do
  begin
    for I := 1 to HoleNum do
      if (Hole[I].Top >= 20) and (Hole[I].Top >= 20) and (Hole[I].Top < Form1.ClientHeight) and (Hole[I].Visible) then
        if (DoodleMan.Left + DoodleMan.Width div 2 > Hole[I].Left) and (DoodleMan.Left + DoodleMan.Width div 2 < Hole[I].Left + Hole[I].Width) and (DoodleMan.Top + DoodleMan.Height div 2 > Hole[I].Top) and (DoodleMan.Top + DoodleMan.Height div 2 < Hole[I].Top + Hole[I].Height) then
          Result := I;
  end;
end;

procedure Jump (X, Y: Integer; Teta, V: Real; YDif: Integer);
const
	G = 9.8;
var
	BX, BY: Real;
  VX, VY, VY0: Real;
begin
	BX := X;
  BY := Y;
  Teta := Teta * Pi / 180;
  VX := Cos (Teta) * V;
  VY := Sin (Teta) * V;
  VY0 := VY;
  while (VY > -VY0) or (BY <= Y + YDif) do
  begin
    VY := VY - G / 1000;
  	BX := BX + VX / 1000;
    BY := BY - VY / 1000;
    Form1.Doodleman.Left := Round (X + BX);
    Form1.Doodleman.Top := Round (Y + BY);
    if (BY < Y + YDif) and (VY <= 0) then
    	break;
    //Sleep (10);
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if not Started then
  begin
    X := Doodleman.Left;
    Y := Doodleman.Top;
    Timer1.Interval := Round (30 / DT);
    Timer2.Interval := Timer1.Interval * 60;
    Timer1.Enabled := True;
    Label2.Visible := False;
    Started := True;
    if PicsMode = 2 then
      Explosion.Picture.LoadFromFile ('Doodlepics/Winter/Explosion.gif');
    Button1.Enabled := False;
    Button1.Visible := False;
  end;
end;

procedure TForm1.Button1KeyPress(Sender: TObject; var Key: Char);
begin
  if not Started then
  begin
    X := Doodleman.Left;
    Y := Doodleman.Top;
    Timer1.Interval := Round (30 / DT);
    Timer2.Interval := Timer1.Interval * 60;
    Timer1.Enabled := True;
    Label2.Visible := False;
    Started := True;
    if PicsMode = 2 then
      Explosion.Picture.LoadFromFile ('Doodlepics/Winter/Explosion.gif');
    Button1.Enabled := False;
    Button1.Visible := False;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  //MediaPlayer1.Open;
  MaxStage := 1;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Timer1.Enabled) or (Key = VK_ESCAPE) then
  begin
    case Key of
      VK_UP:
      begin
        if (Bullet.Tag <> 0) and (Using = UseNone) then
        begin
          DoodleDir := drUp;
          DoodleMan.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
          DoodleMan2.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
          Bullet.Left := DoodleMan.Left + DoodleMan.Width div 2 - Bullet.Width div 2;
          Bullet.Top := DoodleMan.Top - Bullet.Height div 2 - 8;
          Bullet.Tag := 0;
          Timer3.Interval := {Timer1.Interval * 200}85;
          Timer3.Enabled := True;
        end;
      end;
      VK_LEFT:
      begin
        MoveToLeft := True;
        MoveToRight := False;
      end;
      VK_RIGHT:
      begin
        MoveToLeft := False;
        MoveToRight := True;
      end;
      VK_ESCAPE:
      begin
        if Started then
        begin
          Timer1.Enabled := not Timer1.Enabled;
          Paused.Visible := not Paused.Visible;
        end;
      end;
    end;
  end;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Timer1.Enabled then
    case Key of
      VK_LEFT: MoveToLeft := False;
      VK_RIGHT: MoveToRight := False;
    end;
end;

procedure TForm1.FormShow(Sender: TObject);
var
  I: Integer;
  Y: Integer;
  J: Integer;
begin
  {Form2.Show;
  Form3.Show;
  Form4.Show;}
  Randomize;
  Using := UseNone;
  Background.Picture.LoadFromFile (BackGrounds[PicsMode]);
  Doodleman.Picture.LoadFromFile (Pictures[PicsMode, Using, 2]);
  Doodleman2.Picture.LoadFromFile (Pictures[PicsMode, Using, 2]);
  Label1.Font.Color := Colors[PicsMode, 0];
  Label2.Font.Color := Colors[PicsMode, 0];
  Y := Form1.ClientHeight {- Random (20)} - 16;
  J := 1;
  for I := 1 to StageCount[J] do
  begin
    Stage[J, I] := TShape.Create(Self);
    Stage[J, I].Parent := Self;
    //Stage[I].Picture.LoadFromFile('Doodlepics/Platform Green.gif');
    Stage[J, I].Width := 50 + Random (12);
    Stage[J, I].Height := 16;
    Stage[J, I].Left := 1 + Random ((Form1.ClientWidth) - Stage[J, I].Width);
    Stage[J, I].Top := Y;
    //Stage[I].Transparent := True;
    Stage[J, I].Brush.Color := Colors[PicsMode, J];
    Dec (Y, Random (84) + 20);
    if PicsMode = 1 then
    begin
      Label1.BringToFront;
      Label2.BringToFront;
    end;
    Bullet.BringToFront;
    DoodleMan2.BringToFront;
    DoodleMan.BringToFront;
    Paused.BringToFront;
  end;
  J := 2;
  for I := 1 to StageCount[J] do
  begin
    Stage[J, I] := TShape.Create(Self);
    Stage[J, I].Parent := Self;
    //Stage[I].Picture.LoadFromFile('Doodlepics/Platform Green.gif');
    Stage[J, I].Width := 50 + Random (12);
    Stage[J, I].Height := 16;
    Stage[J, I].Left := Form1.ClientWidth - Stage[J - 1, M * I].Left - Stage[J - 1, M * I].Width;
    Stage[J, I].Top := Stage[J - 1, M * I].Top;
    //Stage[I].Transparent := True;
    Stage[J, I].Brush.Color := Colors[PicsMode, J];
    if PicsMode = 1 then
    begin
      Label1.BringToFront;
      Bullet.BringToFront;
      Label2.BringToFront;
    end
    else
      Bullet.BringToFront;
    DoodleMan2.BringToFront;
    DoodleMan.BringToFront;
    Paused.BringToFront;
    if ((Stage[J, I].Left + Stage[J, I].Width >= Stage[J - 1, M * I].Left) and (Stage[J, I].Left + Stage[J, I].Width <= Stage[J - 1, M * I].Left + Stage[J - 1, M * I].Width)) or ((Stage[J, I].Left >= Stage[J - 1, M * I].Left) and (Stage[J, I].Left <= Stage[J - 1, M * I].Left + Stage[J - 1, M * I].Width)) or (I mod 5 = 0) then
      Stage[J, I].Visible := False
    else
      if Random (8) = 0 then
      begin
        Inc (SpringNum);
        Spring[SpringNum] := TImage.Create (Self);
        Spring[SpringNum].Parent := Self;
        Spring[SpringNum].Picture.LoadFromFile ('Doodlepics\Spring.png');
        Spring[SpringNum].Left := Stage[J, I].Left + 5 + Random (6);
        Spring[SpringNum].Top := Stage[J, I].Top - Spring[SpringNum].Picture.Height;
        Spring[SpringNum].Transparent := True;
        Spring[SpringNum].AutoSize := True;
        Spring[SpringNum].Stretch:= True;
      end
      else
        if Random (6) = 0 then
        begin
          Inc (RocketNum);
          Rocket[RocketNum] := TImage.Create (Self);
          Rocket[RocketNum].Parent := Self;
          Rocket[RocketNum].Picture.LoadFromFile ('Doodlepics\Rocket.png');
          Rocket[RocketNum].Left := Stage[J, I].Left + 5 + Random (6);
          Rocket[RocketNum].Top := Stage[J, I].Top - Rocket[RocketNum].Picture.Height;
          Rocket[RocketNum].Transparent := True;
          Rocket[RocketNum].AutoSize := True;
          Rocket[RocketNum].Stretch:= True;
        end;
    Stage[J, I].Top := Stage[J, I].Top + StageDif - Random (StageDif * 2 + 1);
  end;
  J := 3;
  for I := 1 to StageCount[J] do
  begin
    Stage[J, I] := TShape.Create(Self);
    Stage[J, I].Parent := Self;
    //Stage[I].Picture.LoadFromFile('Doodlepics/Platform Green.gif');
    Stage[J, I].Width := 50 + Random (12);
    Stage[J, I].Height := 16;
    Stage[J, I].Left := Form1.ClientWidth - Stage[J - 2, (M + 3) * I].Left - Stage[J - 2, (M + 3) * I].Width;
    Stage[J, I].Top := Stage[J - 2, (M + 3) * I].Top;
    //Stage[I].Transparent := True;
    Stage[J, I].Brush.Color := Colors[PicsMode, J];
    if ((Stage[J, I].Left + Stage[J, I].Width >= Stage[J - 2, (M + 3) * I].Left) and (Stage[J, I].Left + Stage[J, I].Width <= Stage[J - 2, (M + 3) * I].Left + Stage[J - 2, (M + 3) * I].Width)) or ((Stage[J, I].Left >= Stage[J - 2, (M + 3) * I].Left) and (Stage[J, I].Left <= Stage[J - 2, (M + 3) * I].Left + Stage[J - 2, (M + 3) * I].Width)) then
    begin
      Stage[J, I].Visible := False;
      if Random (2) = 0 then
      begin
        Inc (HoleNum);
        Hole[HoleNum] := TImage.Create (Self);
        Hole[HoleNum].Parent := Self;
        Hole[HoleNum].Picture.LoadFromFile ('Doodlepics\Hole 2.gif');
        Hole[HoleNum].Left := Stage[J, I].Left + Hole[HoleNum].Picture.Width div 2;
        Hole[HoleNum].Top := Stage[J, I].Top - Hole[HoleNum].Picture.Height div 2;
        Hole[HoleNum].Transparent := True;
        Hole[HoleNum].AutoSize := True;
        while (((Stage[J - 2, (M + 3) * I].Left + Stage[J - 2, (M + 3) * I].Width >= Hole[HoleNum].Left) and (Stage[J - 2, (M + 3) * I].Left + Stage[J - 2, (M + 3) * I].Width <= Hole[HoleNum].Left + Hole[HoleNum].Width)) or ((Stage[J - 2, (M + 3) * I].Left >= Hole[HoleNum].Left) and (Stage[J - 2, (M + 3) * I].Left <= Hole[HoleNum].Left + Hole[HoleNum].Width))) do
          Stage[J - 2, (M + 3) * I].Left := 1 + Random ((Form1.ClientWidth) - Stage[J - 2, (M + 3) * I].Width);
      end;
    end
    else
      if Random (4) = 0 then
      begin
        Stage[J, I].Left := Stage[J, I].Left - 40;
        Inc (EnemyNum);
        Enemy[EnemyNum] := TImage.Create (Self);
        Enemy[EnemyNum].Parent := Self;
        Enemy[EnemyNum].Picture.LoadFromFile ('Doodlepics\Yeti Monster 2.gif');
        Enemy[EnemyNum].Left := Stage[J, I].Left;
        Enemy[EnemyNum].Top := Stage[J, I].Top - Enemy[EnemyNum].Picture.Height;
        Enemy[EnemyNum].Transparent := True;
        Enemy[EnemyNum].AutoSize := True;
        Enemy[EnemyNum].Stretch:= True;
        {Enemy[EnemyNum].Height := Round (Enemy[EnemyNum].Height * Stage[J, I].Width / Enemy[EnemyNum].Width);
        Enemy[EnemyNum].Width :=  Stage[J, I].Width;}
        Stage[J, I].Width := 80;
        while ((Stage[J, I].Left + Stage[J, I].Width >= Stage[J - 2, (M + 3) * I].Left) and (Stage[J, I].Left + Stage[J, I].Width <= Stage[J - 2, (M + 3) * I].Left + Stage[J - 2, (M + 3) * I].Width)) or ((Stage[J, I].Left >= Stage[J - 2, (M + 3) * I].Left) and (Stage[J, I].Left <= Stage[J - 2, (M + 3) * I].Left + Stage[J - 2, (M + 3) * I].Width)) do
        begin
          Stage[J, I].Left := 1 + Random ((Form1.ClientWidth) - Stage[J, I].Width);
          Enemy[EnemyNum].Left := Stage[J, I].Left;
        end;
      end;
    if PicsMode = 1 then
    begin
      Label1.BringToFront;
      Label2.BringToFront;
    end;
    Bullet.BringToFront;
    DoodleMan2.BringToFront;
    DoodleMan.BringToFront;
    Paused.BringToFront;
    Stage[J, I].Top := Stage[J, I].Top + StageDif - Random (StageDif * 2 + 1);
  end;
  {DoodleMan.Left := Stage[1, 1].Left + Stage[1, 1].Width div 2 - DoodleMan.Width div 2;
  DoodleMan.Top := Stage[1, 1].Top - DoodleMan.Height;
  DoodleMan2.Left := Stage[1, 1].Left + Stage[1, 1].Width div 2 - DoodleMan2.Width div 2;
  DoodleMan2.Top := Stage[1, 1].Top - DoodleMan2.Height;}
  I := Stage[1, 1].Left + Stage[1, 1].Width div 2 - ClientWidth div 2;
  if I < 0 then
    Inc (I, ClientWidth - DoodleMan.Width);
  if I + DoodleMan.Width div 2 <= ClientWidth div 2 then
  begin
    DoodleDir := drRight;
    Doodleman.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
    Doodleman2.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
  end
  else
  begin
    DoodleDir := drLeft;
    Doodleman.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
    Doodleman2.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
  end;
  DoodleMan.Left := I;
  DoodleMan.Top := ClientHeight - DoodleMan.Height;
  DoodleMan2.Left := I;
  DoodleMan2.Top := ClientHeight - DoodleMan2.Height;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  I, J, HeightDif: Integer;
  Flr: TStage;
begin
  YDif := 1000;
  if ((VY > -VY0) or (Y <= Y + YDif)) and (not ((Y > Y + YDif) and (VY <= 0))) then
  begin
    if MoveToLeft then
    begin
      if JumpCount > 0 then
        JumpCount := JumpCount - 6;
      if JumpCount < 0 then
        JumpCount := 0;
      if VX > -MaxSpeed then
        VX := VX - MoveAccel;
    end;
    if MoveToRight then
    begin
      if JumpCount > 0 then
        JumpCount := JumpCount - 6;
      if JumpCount < 0 then
        JumpCount := 0;
      if VX < MaxSpeed then
        VX := VX + MoveAccel;
    end;
    VX := VX * VMultiplier;
    if Using = UseRocket then
    begin
      if DoodleMan.Top + DoodleMan.Height < Form1.ClientHeight / 2 then
        VY := 9
      else
        VY := 15;
      if DoodleMan.Top + DoodleMan.Height < 0 then
        VY := VY - (Gravity / Di) * 3;
    end
    else
      VY := VY - Gravity / Di;
    X := X + VX;
    Y := Y - Round (VY) / Di;
    Doodleman.Left := Round (X);
    Doodleman.Top := Round (Y);
    Doodleman2.Left := Round (X);
    Doodleman2.Top := Round (Y);
    if X < -Doodleman.Width then
      X := X + ClientWidth;
    if X > ClientWidth then
      X := -Doodleman.Width;
  end;
  Flr := IsStopped;
  if (Using < UseRocket) and ((((VY <= 0) or (not Jumped)) and (Flr.B <> 0)) or ((DoodleMan.Top >= Form1.ClientHeight - DoodleMan.Picture.Height) and (not Jumped))) then
  begin
    VX := Cos (DegToRad (90)) * JumpSpeed[Using];
    VY := Sin (DegToRad (90)) * JumpSpeed[Using];
    if Flr.A = 3 then
    begin
      VX := Cos (DegToRad (90)) * (JumpSpeed[Using] + 10);
      VY := Sin (DegToRad (90)) * (JumpSpeed[Using] + 10);
    end;
    if (Flr.A > 1) then
    begin
      Stage[Flr.A, Flr.B].Visible := False;
      Explosion.Visible := True;
      Explosion.Left := Stage[Flr.A, Flr.B].Left;
      Explosion.Top := Stage[Flr.A, Flr.B].Top;
      Timer2.Enabled := True;
    end;
    VY := VY - JumpCount * DecValue;
    if VY >= MinJump then
      Inc (JumpCount);
    //MediaPlayer1.Play;
  end;
  if ((Round (VX) <> 0) and (DoodleDir <> drUp)) or (Using <> UseNone) then
  begin
    if VX > 0 then
    begin
      DoodleDir := drRight;
      Doodleman.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
      Doodleman2.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
    end;
    if VX <= 0 then
    begin
      DoodleDir := drLeft;
      Doodleman.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
      Doodleman2.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
    end;
  end;
  if MaxHeight < Form1.ClientHeight - Doodleman.Top - DoodleMan.Height then
    MaxHeight := Form1.ClientHeight - Doodleman.Top - DoodleMan.Height;
  //MaxHeight := Form1.ClientHeight - Doodleman.Top;
  if MaxStage < Flr.B then
    MaxStage := Flr.B;
  case Using of
    UseNone: HeightDif := ((Form1.ClientHeight - Doodleman.Top - DoodleMan.Height) - (Form1.ClientHeight div 2)) div 30;
    UseSpring: HeightDif := ((Form1.ClientHeight - Doodleman.Top - DoodleMan.Height) - (Form1.ClientHeight div 2)) div 20;
    UseRocket: HeightDif := ((Form1.ClientHeight - Doodleman.Top - DoodleMan.Height) - (Form1.ClientHeight div 2)) div 15;
  end;
  if DoodleMan.Top + DoodleMan.Height < Form1.ClientHeight / 2 then
  begin
    for J := 1 to 3 do
    begin
      //BY := Form1.ClientHeight / 2;
      if HeightDif > 0 then
        Jumped := True;
      for I := 1 to StageCount[J] do
        if (Stage[J, I].Top < ClientHeight) and (Stage[J, I].Visible) then
          Stage[J, I].Top := Stage[J, I].Top + HeightDif;
      {if Explosion.Visible then
        Explosion.Top := Explosion.Top + ((Form1.ClientHeight - Doodleman.Top - DoodleMan.Height) - (Form1.ClientHeight div 2)) div 40;}
      MaxHeight2 := MaxHeight2 + HeightDif;
    end;
    for I := 1 to EnemyNum do
      if (Enemy[I].Top < ClientHeight) and (Enemy[I].Visible) then
        Enemy[I].Top := Enemy[I].Top + HeightDif;
    for I := 1 to SpringNum do
      if (Spring[I].Top < ClientHeight) and (Spring[I].Visible) then
        Spring[I].Top := Spring[I].Top + HeightDif;
    for I := 1 to HoleNum do
      if (Hole[I].Top < ClientHeight) then
        Hole[I].Top := Hole[I].Top + HeightDif;
    for I := 1 to RocketNum do
      if (Rocket[I].Top < ClientHeight) and (Rocket[I].Visible) then
        Rocket[I].Top := Rocket[I].Top + HeightDif;
  end;
  if MaxHeight2 = 0 then
    Label1.Caption := IntToStr (MaxHeight div 4)
  else
    Label1.Caption := IntToStr (MaxHeight2 div 4 + MaxHeight div 4);
  if (Using < UseRocket) and (((DoodleMan.Top >= Form1.ClientHeight + 1) and Jumped) or (ApproachEnemy <> 0) or (ApproachHole <> 0)) then
  begin
    Label2.Left := 72;
    Label2.Caption := 'Game over';
    Label2.Visible := True;
    Timer1.Enabled := False;
    ApprHole := ApproachHole;
    Timer5.Enabled := ApproachHole <> 0;
  end;
  if (DoodleMan.Top + DoodleMan.Height < Stage[1, StageCount[1]].Top) then
  begin
    Label2.Left := 83;
    Label2.Caption := 'You win';
    Label2.Visible := True;
    Timer1.Enabled := False;
  end;
  if TakeSpring <> 0 then
  begin
    Using := UseSpring;
    Timer1.Interval := Round (30 / (DT + 12));
    Timer4.Enabled := True;
  end
  else
    Timer1.Interval := Round (30 / DT);
  if TakeRocket <> 0 then
  begin
    Using := UseRocket;
    Timer1.Interval := Round (30 / (DT + 20));
    Timer6.Enabled := True;
  end
  else
    Timer1.Interval := Round (30 / DT);
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  Explosion.Visible := False;
  Timer2.Enabled := False;
end;

procedure TForm1.Timer3Timer(Sender: TObject);
var
  HittedEnemy: Word;
begin
  Timer3.Enabled := Timer1.Enabled;
  if not Timer3.Enabled then
    Exit;
  HittedEnemy := HitEnemy;
  if VX > 0 then
  begin
    Doodleman.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
    Doodleman2.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
    DoodleDir := drRight;
  end;
  if VX <= 0 then
  begin
    Doodleman.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
    Doodleman2.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
    DoodleDir := drLeft;
  end;
  Timer3.Interval := Timer1.Interval;
  if (HittedEnemy = 0) and (Bullet.Top + Bullet.Height >= 0) then
  begin
    Bullet.Top := Bullet.Top - 5;
    Bullet.Visible := True;
  end
  else
  begin
    Bullet.Tag := 1;
    Timer3.Enabled := False;
    Bullet.Visible := False;
  end;
end;

procedure TForm1.Timer4Timer(Sender: TObject);
begin
  if Timer1.Enabled then
  begin
    Using := UseNone;
    Timer4.Enabled := False;
    if VX > 0 then
    begin
      Doodleman.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
      Doodleman2.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
      DoodleDir := drRight;
    end;
    if VX <= 0 then
    begin
      Doodleman.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
      Doodleman2.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
      DoodleDir := drLeft;
    end;
  end;
end;

procedure TForm1.Timer5Timer(Sender: TObject);
begin
  DoodleMan.AutoSize := False;
  DoodleMan2.AutoSize := False;
  if (DoodleMan.Width > 1) and (DoodleMan.Height > 1) then
  begin
    DoodleMan.Width := DoodleMan.Width - 1;
    DoodleMan.Height := DoodleMan.Height - 1;
    DoodleMan.Left := DoodleMan.Left + ((Hole[ApprHole].Left + Hole[ApprHole].Width div 2) - (DoodleMan.Left + DoodleMan.Width div 2)) div 5;
    DoodleMan.Top := DoodleMan.Top + ((Hole[ApprHole].Top + Hole[ApprHole].Height div 2) - (DoodleMan.Top + DoodleMan.Height div 2)) div 5;
    DoodleMan2.Width := DoodleMan2.Width - 1;
    DoodleMan2.Height := DoodleMan2.Height - 1;
    DoodleMan2.Left := DoodleMan2.Left + ((Hole[ApprHole].Left + Hole[ApprHole].Width div 2) - (DoodleMan2.Left + DoodleMan2.Width div 2)) div 5;
    DoodleMan2.Top := DoodleMan2.Top + ((Hole[ApprHole].Top + Hole[ApprHole].Height div 2) - (DoodleMan2.Top + DoodleMan2.Height div 2)) div 5;
  end
  else
    Timer5.Enabled := False;
end;

procedure TForm1.Timer6Timer(Sender: TObject);
begin
  if Timer1.Enabled then
  begin
    Using := UseNone;
    Timer6.Enabled := False;
    if VX > 0 then
    begin
      Doodleman.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
      Doodleman2.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
      DoodleDir := drRight;
    end;
    if VX < 0 then
    begin
      Doodleman.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
      Doodleman2.Picture.LoadFromFile (Pictures[PicsMode, Using, DoodleDir]);
      DoodleDir := drLeft;
    end;
  end;
end;

end.
