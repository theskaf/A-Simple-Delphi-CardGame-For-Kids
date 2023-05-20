unit MainDtm;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Dialogs,
  Winapi.Windows;


type
  TdtmMain = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
    procedure firstInitPart;
    function assColorz(n: Integer): TColor;
  end;


  TCard = record
    Rank: integer;
    Name: string;
    Index: integer;
  end;




var
  dtmMain: TdtmMain;
  //Cards: TList<TCard>;





implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdtmMain }

function TdtmMain.assColorz(n: Integer): TColor; //uses Vcl.Graphics
(* Using it like that:
var
  myColor: TColor;
begin
  myColor := assColorz(2); // returns ... color
end; *)
begin
  case n of //uses Winapi.Windows for RGB:
    2: Result := RGB(220, 220, 220); // Gainsboro (light grey)
    3: Result := RGB(255, 255, 0); // Yellow
    4: Result := RGB(154, 205, 50); // Yellow-green
    5: Result := RGB(255, 215, 0); //Yellow-orange
    6: Result := RGB(0, 128, 0); //Green
    7: Result := RGB(255, 165, 0); //Orange
    8: Result := RGB(0, 128, 128); //Blue-green
    9: Result := RGB(0, 0, 255); //Blue
    10: Result := RGB(255, 69, 0); //Red-orange
    11: Result := RGB(255, 0, 0); //Red
    12: Result := RGB(138, 43, 226); //Blue-purple
    13: Result := RGB(204, 50, 153); //Red-purple
    14: Result := RGB(128, 0, 128); //Purple
    15: Result := RGB(128, 128, 128); //Grey
  else
    raise Exception.Create('Invalid input argument');
  end;
end;

procedure TdtmMain.firstInitPart;
begin
//
end;





end.
