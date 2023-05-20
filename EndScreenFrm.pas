unit EndScreenFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.StdCtrls;

type
  TfrmEndScreen = class(TForm)
    imgLoss: TImage;
    btnYes: TButton;
    btnCancel: TButton;
    imgWinnn: TImage;
    lblMsg: TLabel;
    lblAsk: TLabel;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnYesClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FuserChoice, FopenCondition: Integer;
  public
    //userChoice, openCondition: Integer;
	  property userChoice: Integer read FuserChoice write FuserChoice;
	  property openCondition: Integer read FopenCondition write FopenCondition;
  end;

//var
  //frmEndScreen: TfrmEndScreen;

implementation

{$R *.dfm}

procedure TfrmEndScreen.btnCancelClick(Sender: TObject);
begin
  userChoice := 2;
  Self.Close;
end;

procedure TfrmEndScreen.btnYesClick(Sender: TObject);
begin
  userChoice := 1;
  Self.Close;
end;

procedure TfrmEndScreen.FormCreate(Sender: TObject);
begin
{
  if openCondition = 1 then //win
  begin
    imgWinnn.Visible := True;
    imgWinnn.Left := 0;
    imgWinnn.Top := 0;
    imgWinnn.Width := 480;
    imgWinnn.Height := 329;
    imgLoss.Visible := False;
    imgLoss.Left := 0;
    imgLoss.Top := 0;
    imgLoss.Width := 1;
    imgLoss.Height := 1;
    Self.Caption := '   Κέρδισες!1!!!1!!ένα!!!!!!1!!   ';
    lblMsg.Caption := 'Μπράβο, ήσουν εξαιρετικά καλ@ στο να κάνεις κλικ το κουμπί. Θες να παίξεις κι άλλο παιχνίδι;';
  end;
  if openCondition = -1 then //loose
  begin
    imgLoss.Visible := True;
    imgLoss.Left := 0;
    imgLoss.Top := 0;
    imgLoss.Width := 480;
    imgLoss.Height := 329;
    imgWinnn.Visible := False;
    imgWinnn.Left := 0;
    imgWinnn.Top := 0;
    imgWinnn.Width := 1;
    imgWinnn.Height := 1;
    Self.Caption := '            Έχασες :(             ';
    lblMsg.Caption := 'Δεν πειράζει, μπορεί να είσαι καλ@ στο μπαρμπούτι ή τους σβώλους. Θες να παίξεις κι άλλο παιχνίδι;';
  end;
}
end;

procedure TfrmEndScreen.FormResize(Sender: TObject);
begin
  ClientHeight := 400;
  ClientWidth  := 480;
end;

procedure TfrmEndScreen.FormShow(Sender: TObject);
begin
  if openCondition = 1 then //win
  begin
    imgWinnn.Visible := True;
    imgWinnn.Left := 0;
    imgWinnn.Top := 0;
    imgWinnn.Width := 480;
    imgWinnn.Height := 329;
    imgLoss.Visible := False;
    imgLoss.Left := 0;
    imgLoss.Top := 0;
    imgLoss.Width := 1;
    imgLoss.Height := 1;
    Self.Caption := '   Κέρδισες!1!!!1!!ένα!!!!!!1!!   ';
    lblMsg.Caption := 'Μπράβο, ήσουν εξαιρετικά καλ@ στο να κάνεις κλικ το κουμπί.';
    lblMsg.Left := (ClientWidth - lblMsg.Width) div 2;
  end;
  if openCondition = -1 then //loose
  begin
    imgLoss.Visible := True;
    imgLoss.Left := 0;
    imgLoss.Top := 0;
    imgLoss.Width := 480;
    imgLoss.Height := 329;
    imgWinnn.Visible := False;
    imgWinnn.Left := 0;
    imgWinnn.Top := 0;
    imgWinnn.Width := 1;
    imgWinnn.Height := 1;
    Self.Caption := '            Έχασες :(             ';
    lblMsg.Caption := 'Δεν πειράζει, μπορεί να είσαι καλ@ στο μπαρμπούτι ή τους σβώλους.';
    lblMsg.Left := (ClientWidth - lblMsg.Width) div 2;
  end;
end;

procedure TfrmEndScreen.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//  userChoice
end;

end.
