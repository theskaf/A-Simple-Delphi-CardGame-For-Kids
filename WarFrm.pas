unit WarFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls;

type
  TfrmWar = class(TForm)
    Image1: TImage;
    btnOk: TButton;
    procedure btnOkClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;



//var
  //frmWar: TfrmWar;

implementation

{$R *.dfm}

procedure TfrmWar.btnOkClick(Sender: TObject);
begin
  self.Close;
end;

procedure TfrmWar.FormResize(Sender: TObject);
begin
  ClientHeight := 255;
  ClientWidth  := 342;
end;

end.
